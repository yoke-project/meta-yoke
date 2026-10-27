#!/usr/bin/env python3
"""Boots an image of this layer under QEMU and reads, on its serial console, what the cases of the image
ask: inside the build host ci/image.sh starts, with the build's own QEMU, through runqemu.

Prints one line per fact, `<name> <value>`, which ci/image-build.sh reads; a fact never read is absent.

Usage: boot.py <build directory> <machine> <image> <screendump path> [application|service]
  the form the image runs, application unless named, decides what is read
"""
import os
import re
import socket
import sys
import time

import pexpect

build, machine, image, screendump = sys.argv[1:5]
form = sys.argv[5] if len(sys.argv) > 5 else "application"
monitor = os.path.join(build, "qemu-monitor.sock")
account = "station"
prompt = "BOOT# "


def fact(name, value):
    print(f"{name} {value}", flush=True)


# What systemd writes to a terminal around a session, and colours: neither is a command's output.
terminal = re.compile(r"\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)|\x1b\[[0-9;?]*[A-Za-z]")


def run(console, command, timeout=60):
    """What a command printed on the console and its exit status, the prompt being one of the script's own.
    The terminal echoes nothing, so what comes before the status is the command's output alone."""
    console.sendline(f"{command}; echo \"status=$?\"")
    # The serial console ends a line with more than one carriage return.
    console.expect(r"status=(\d+)\r*\n", timeout=timeout)
    out = terminal.sub("", console.before.decode(errors="replace")).replace("\r", "")
    status = int(console.match.group(1))
    console.expect_exact(prompt, timeout=timeout)
    return out.strip(), status


def as_account(command):
    """A command run as the account, with its user manager's runtime directory, as a signed-in user has it."""
    return (f"su -s /bin/sh {account} -c 'XDG_RUNTIME_DIR=/run/user/$(id -u {account}) "
            f"DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u {account})/bus {command}'")


def screendump_of_display():
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
        s.connect(monitor)
        s.settimeout(30)
        s.recv(4096)
        s.sendall(f"screendump {screendump}\n".encode())
        time.sleep(3)


def read_the_application():
    """The application form: the first boot, the account, its guardian, and the instance it brought up."""
    out, status = run(console, "systemctl show -p Result --value yoke-example-first-boot.service")
    fact("first-boot", out or "unknown")
    # The account lingers: its user manager runs with no session of its own.
    linger, _ = run(console, f"loginctl show-user {account} -p Linger --value")
    state, _ = run(console, f"loginctl show-user {account} -p State --value")
    fact("account", f"{linger}/{state}" if linger and state else "unknown")
    # The user manager holds a session of its own, of the class manager; a sign-in is a session of the class user.
    out, status = run(console, f"for s in $(loginctl show-user {account} -p Sessions --value); do "
                               "loginctl show-session $s -p Class --value; done | grep -c '^user'")
    fact("signed-in", out or "unknown")
    out, status = run(console, as_account("systemctl --user is-active yoke-guardian.service"))
    fact("guardian", out.splitlines()[-1] if out else "unknown")

    # The guardian brings the instance up in its own time: its Core answers once it has.
    deadline = time.time() + 600
    while True:
        out, status = run(console, as_account("yoke core status --instance station")
                          + " | grep -cE '\"ready\": *true'", timeout=120)
        # The count is the last line: the manager says on its own line why nothing answers yet.
        ready = out.splitlines()[-1] == "1" if out else False
        if ready or time.time() > deadline:
            break
        time.sleep(10)
    fact("core-ready", "yes" if ready else "no")
    out, status = run(console, as_account("yoke instance show station") + " | grep -E '^(id|desired_state):' | tr -d ' ' | tr '\\n' ' '")
    fact("instance", out.replace(" ", "/") or "unknown")
    for unit in ("acquire", "panel"):
        out, status = run(console, as_account(f"yoke core read unit {unit} --instance station")
                          + " | grep -m1 -oE '\"state\": *\"[A-Za-z]+\"' | cut -d'\"' -f4")
        fact(f"unit-{unit}", out or "unknown")

    # The service form's unit is in the image, and nothing here asked for it.
    out, status = run(console, "systemctl is-enabled yoke.service")
    fact("service-unit", out.splitlines()[-1] if out else "unknown")


def read_the_service():
    """The service form: the init system's unit, the composition in force, and the deployment it started."""
    out, status = run(console, "systemctl is-enabled yoke.service")
    fact("service-enabled", out.splitlines()[-1] if out else "unknown")
    out, status = run(console, "readlink /etc/yoke/deployment.yaml")
    fact("deployment", out or "unknown")
    out, status = run(console, "cmp -s /etc/yoke/deployments/station.yaml "
                               "/usr/share/yoke-reference/compositions/station-device.yaml && echo same || echo differs")
    fact("composition", out.splitlines()[-1] if out else "unknown")
    # The init system starts the deployment at boot; it answers once its Core is ready.
    deadline = time.time() + 600
    while True:
        out, status = run(console, "yoke service status", timeout=120)
        ready = "instance: answers, and is ready" in out
        if ready or time.time() > deadline:
            break
        time.sleep(10)
    fact("service-active", "yes" if "is active" in out else "no")
    fact("core-ready", "yes" if ready else "no")
    for unit in ("acquire", "panel"):
        out, status = run(console, f"yoke core read unit {unit}"
                                   " | grep -m1 -oE '\"state\": *\"[A-Za-z]+\"' | cut -d'\"' -f4")
        fact(f"unit-{unit}", out or "unknown")


env = dict(os.environ)
# runqemu draws nothing: QEMU's display is kept for the screendump the monitor takes, and shown nowhere.
qemuparams = f"-display none -monitor unix:{monitor},server,nowait"
kvm = "kvm" if machine == "qemux86-64" and os.access("/dev/kvm", os.W_OK) else ""
# The kernel's console stays off the framebuffer, so what the display shows is what the panel drew.
bootparams = "fbcon=map:9"
# In snapshot the boot writes nothing back: the image a later run boots is the one the build deployed.
command = (f"runqemu {machine} {image} ext4 slirp serialstdio snapshot {kvm} "
           f"qemuparams=\"{qemuparams}\" bootparams=\"{bootparams}\"")
fact("command", command.replace(" ", "_"))
console = pexpect.spawn("bash", ["-c", command], cwd=build, env=env, timeout=60)
console.logfile_read = open(os.path.join(build, f"boot-{machine}.log" if form == "application" else f"boot-{machine}-{form}.log"), "wb")

try:
    # Under emulation an arm64 boot takes minutes; the first boot also installs the application.
    console.expect(r"login:", timeout=1800)
    fact("login", "yes")
    console.sendline("root")
    console.expect(r"# ", timeout=60)
    # The prompt is set in two halves, so the echo of this line is not taken for it.
    half = len(prompt) // 2
    console.sendline(f"stty -echo; export PS1='{prompt[:half]}''{prompt[half:]}' SYSTEMD_COLORS=0 SYSTEMD_PAGER=")
    console.expect_exact(prompt, timeout=60)

    out, status = run(console, "systemctl is-system-running --wait", timeout=600)
    fact("system", out.splitlines()[-1] if out else "unknown")
    if form == "service":
        read_the_service()
    else:
        read_the_application()

    # The panel draws once it is running; the display is read after it has had time to.
    time.sleep(10)
    screendump_of_display()
    fact("screendump", "taken" if os.path.exists(screendump) else "absent")
except pexpect.exceptions.ExceptionPexpect as e:
    fact("stopped", type(e).__name__)
finally:
    # What the account's services said, kept in the boot's log for whoever reads a failure.
    try:
        if form == "service":
            run(console, "journalctl -b --no-pager -u yoke.service | tail -150", timeout=120)
        else:
            run(console, f"journalctl -b --no-pager _UID=$(id -u {account}) | tail -150", timeout=120)
            run(console, as_account(f"yoke instance show {account}"), timeout=120)
    except pexpect.exceptions.ExceptionPexpect:
        pass
    console.sendline("poweroff")
    try:
        console.expect(pexpect.EOF, timeout=300)
    except pexpect.exceptions.ExceptionPexpect:
        console.terminate(force=True)
