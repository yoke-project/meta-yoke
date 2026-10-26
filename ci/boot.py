#!/usr/bin/env python3
"""Boots an image of this layer under QEMU and reads, on its serial console, what the cases of the image
ask: inside the build host ci/image.sh starts, with the build's own QEMU, through runqemu.

Prints one line per fact, `<name> <value>`, which ci/image-build.sh reads; a fact never read is absent.

Usage: boot.py <build directory> <machine> <image> <screendump path>
"""
import os
import re
import socket
import sys
import time

import pexpect

build, machine, image, screendump = sys.argv[1:5]
monitor = os.path.join(build, "qemu-monitor.sock")
account = "station"
prompt = "BOOT# "


def fact(name, value):
    print(f"{name} {value}", flush=True)


def run(console, command, timeout=60):
    """What a command printed on the console and its exit status, the prompt being one of the script's own."""
    console.sendline(f"{command}; echo \"status=$?\"")
    console.expect(r"status=(\d+)\r?\n", timeout=timeout)
    out = console.before.decode(errors="replace")
    status = int(console.match.group(1))
    console.expect_exact(prompt, timeout=timeout)
    # The echo of the command is the first line.
    return "\n".join(out.splitlines()[1:]).strip(), status


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


env = dict(os.environ)
# runqemu draws nothing: QEMU's display is kept for the screendump the monitor takes, and shown nowhere.
qemuparams = f"-display none -monitor unix:{monitor},server,nowait"
kvm = "kvm" if machine == "qemux86-64" and os.access("/dev/kvm", os.W_OK) else ""
# The kernel's console stays off the framebuffer, so what the display shows is what the panel drew.
bootparams = "fbcon=map:9"
command = (f"runqemu {machine} {image} ext4 slirp serialstdio {kvm} "
           f"qemuparams=\"{qemuparams}\" bootparams=\"{bootparams}\"")
fact("command", command.replace(" ", "_"))
console = pexpect.spawn("bash", ["-c", command], cwd=build, env=env, timeout=60)
console.logfile_read = open(os.path.join(build, f"boot-{machine}.log"), "wb")

try:
    # Under emulation an arm64 boot takes minutes; the first boot also installs the application.
    console.expect(r"login:", timeout=1800)
    fact("login", "yes")
    console.sendline("root")
    console.expect(r"# ", timeout=60)
    console.sendline(f"export PS1='{prompt}'")
    console.expect_exact(prompt, timeout=60)

    out, status = run(console, "systemctl is-system-running --wait", timeout=600)
    fact("system", out.splitlines()[-1] if out else "unknown")
    out, status = run(console, "systemctl show -p Result --value yoke-example-first-boot.service")
    fact("first-boot", out or "unknown")
    out, status = run(console, "loginctl show-user " + account + " -p Linger -p State --value | tr '\\n' ' '")
    fact("account", out.replace(" ", "/") or "unknown")
    out, status = run(console, "who | wc -l")
    fact("signed-in", out or "unknown")
    out, status = run(console, as_account("systemctl --user is-active yoke-guardian.service"))
    fact("guardian", out or "unknown")

    # The guardian brings the instance up in its own time: its Core answers once it has.
    deadline = time.time() + 600
    while True:
        out, status = run(console, as_account("yoke core status --instance station")
                          + " | grep -c '\"ready\": true'", timeout=120)
        if out == "1" or time.time() > deadline:
            break
        time.sleep(10)
    fact("core-ready", "yes" if out == "1" else "no")
    out, status = run(console, as_account("yoke instance show station") + " | grep -E '^(id|desired_state):' | tr -d ' ' | tr '\\n' ' '")
    fact("instance", out.replace(" ", "/") or "unknown")
    for unit in ("acquire", "panel"):
        out, status = run(console, as_account(f"yoke core read unit {unit} --instance station")
                          + " | grep -m1 -oE '\"state\": \"[A-Za-z]+\"' | cut -d'\"' -f4")
        fact(f"unit-{unit}", out or "unknown")

    # The panel draws once it is running; the display is read after it has had time to.
    time.sleep(10)
    screendump_of_display()
    fact("screendump", "taken" if os.path.exists(screendump) else "absent")
except pexpect.exceptions.ExceptionPexpect as e:
    fact("stopped", type(e).__name__)
finally:
    console.sendline("poweroff")
    try:
        console.expect(pexpect.EOF, timeout=300)
    except pexpect.exceptions.ExceptionPexpect:
        console.terminate(force=True)
