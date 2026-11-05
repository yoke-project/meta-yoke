#!/usr/bin/env python3
"""The board pass (testing/20): reads a real board's serial console as ci/boot.py reads QEMU's, and writes
the record of one form's boot. A person has written the form's image to the board's medium; the script
waits for the person to power the board on, for the kernel and a login, reads the facts ci/readers.py
reads, photographs the display through a video capture device named by its name, and powers the board
off. The person's part is the medium and the power, never a result.

Prints one line per fact, `<name> <value>`, then the case's line, `pass  <id>` or `FAIL  <id> — <why>`.
Writes into --out, per form: <form>.acts, <form>.facts, <form>.timings, <form>-display.png and
<form>-console.log. Exits 0 when the case passes.

Usage: board.py --form yoke|yoke-service --wrote <what the person wrote to the medium> [--port /dev/ttyACM0]
  [--capture UGREEN] [--out DIR] [--kernel-timeout S] [--login-timeout S] [--running-timeout S]
"""
import argparse
import datetime
import os
import re
import subprocess
import sys
import termios
import time
import tty

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from readers import read_yoke_alone, read_yoke_alone_as_a_service, run_on  # noqa: E402

# The facts each form's case asks: the QEMU boot's (checks/image/the-yoke-image.std.md), and the display.


# std: meta-yoke:the-board-pass.05
def the_application_form_boots_into_an_account_whose_guardian_has_run():
    return "meta-yoke:the-board-pass.05", {
        "account": "yes/lingering", "signed-in": "0", "guardian-enabled": "enabled", "guardian": "ran",
        "instances": "0", "service-unit": "disabled", "display": "taken"}


# std: meta-yoke:the-board-pass.06
def the_service_form_boots_with_its_unit_waiting():
    return "meta-yoke:the-board-pass.06", {
        "system": "running", "service-enabled": "disabled", "deployment": "absent", "core-config": "present",
        "display": "taken"}


CASES = {"yoke": the_application_form_boots_into_an_account_whose_guardian_has_run,
         "yoke-service": the_service_form_boots_with_its_unit_waiting}
ACCOUNT = "apps"
PROMPT = "BOARD# "


class Stopped(Exception):
    pass


class Console:
    """A serial console with what ci/readers.py asks of one: sendline, expect, expect_exact, before, match.
    Every byte read is kept in the console's log."""

    def __init__(self, port, log):
        self.port = port
        self.fd = self._open()
        self.log = log
        self.pending = b""
        self.before = b""
        self.match = None

    def sendline(self, line):
        os.write(self.fd, line.encode() + b"\r")

    def _open(self):
        fd = os.open(self.port, os.O_RDWR | os.O_NOCTTY)
        if os.isatty(fd):
            tty.setraw(fd)
            attrs = termios.tcgetattr(fd)
            attrs[4] = attrs[5] = termios.B115200
            termios.tcsetattr(fd, termios.TCSANOW, attrs)
        return fd

    def _read(self, deadline):
        import select
        try:
            ready, _, _ = select.select([self.fd], [], [], max(0.0, min(1.0, deadline - time.monotonic())))
            data = os.read(self.fd, 4096) if ready else None
        except OSError:
            data = b""
        if data is None:
            return
        if not data:
            # A USB serial port powered by the board goes with its power and comes back under its name: it is
            # opened again, and what was being waited for is still waited for, until the deadline.
            try:
                os.close(self.fd)
            except OSError:
                pass
            self.log.write(b"\n[board.py: the port went away; opening it again]\n")
            while True:
                try:
                    self.fd = self._open()
                    return
                except OSError:
                    if time.monotonic() >= deadline:
                        raise TimeoutError("the port did not come back")
                    time.sleep(0.2)
        self.log.write(data)
        self.log.flush()
        self.pending += data

    def expect(self, pattern, timeout=60):
        regex = re.compile(pattern.encode() if isinstance(pattern, str) else pattern)
        deadline = time.monotonic() + timeout
        while True:
            m = regex.search(self.pending)
            if m:
                self.before, self.match = self.pending[:m.start()], m
                self.pending = self.pending[m.end():]
                return m
            if time.monotonic() >= deadline:
                raise TimeoutError(pattern)
            self._read(deadline)

    def expect_exact(self, text, timeout=60):
        return self.expect(re.escape(text), timeout)


def capture_node(video_root, name):
    """The capture node of the video device whose name holds `name`, the lowest such, or None: a device is
    chosen by its name and never by its number, which changes, and no other device is ever opened."""
    found = []
    for entry in os.listdir(video_root) if os.path.isdir(video_root) else []:
        try:
            with open(os.path.join(video_root, entry, "name")) as f:
                device = f.read().strip()
            with open(os.path.join(video_root, entry, "index")) as f:
                index = f.read().strip()
        except OSError:
            continue
        number = re.fullmatch(r"video(\d+)", entry)
        if number and name in device and index == "0":
            found.append(int(number.group(1)))
    return f"/dev/video{min(found)}" if found else None


def main():
    p = argparse.ArgumentParser(description="The board pass: one form's boot on a real board.")
    p.add_argument("--form", choices=sorted(CASES), required=True)
    p.add_argument("--wrote", required=True, help="what the person wrote to the board's medium")
    p.add_argument("--port", default="/dev/ttyACM0")
    p.add_argument("--capture", default="UGREEN", help="a part of the capture device's name")
    p.add_argument("--video-root", default="/sys/class/video4linux")
    p.add_argument("--ffmpeg", default="ffmpeg")
    p.add_argument("--out", default="board-record")
    # Measured on a Raspberry Pi 5 on 2026-11-05 — the login 7.3 s after the kernel's first line, the system
    # running 3.3 s after the login — and widened about tenfold. The kernel's wait is the person's: the board
    # is powered on after the script starts.
    p.add_argument("--kernel-timeout", type=float, default=600)
    p.add_argument("--login-timeout", type=float, default=60)
    p.add_argument("--running-timeout", type=float, default=120)
    a = p.parse_args()

    os.makedirs(a.out, exist_ok=True)
    form = a.form
    case, wanted = CASES[form]()
    facts = {}
    record_facts = open(os.path.join(a.out, f"{form}.facts"), "w")

    def fact(name, value):
        facts[name] = value
        print(f"{name} {value}", flush=True)
        record_facts.write(f"{name} {value}\n")
        record_facts.flush()

    timings = open(os.path.join(a.out, f"{form}.timings"), "w")
    with open(os.path.join(a.out, f"{form}.acts"), "w") as acts:
        acts.write(f"wrote the medium: {a.wrote}\n")
        acts.write(f"powered the board on: after {datetime.datetime.now().astimezone().isoformat(timespec='seconds')}, "
                   "when the script waited for the kernel\n")
    print(f"waiting for the board on {a.port}: power it on now", flush=True)

    log = open(os.path.join(a.out, f"{form}-console.log"), "wb")
    console = Console(a.port, log)
    started = time.monotonic()
    stage, previous = "the kernel", "the power"
    stopped = None
    try:
        console.expect(r"Booting Linux", timeout=a.kernel_timeout)
        timings.write(f"kernel {time.monotonic() - started:.1f}\n")
        stage, previous = "the login", "the kernel"
        console.expect(r"login: ", timeout=a.login_timeout)
        timings.write(f"login {time.monotonic() - started:.1f}\n")
        stage, previous = "the shell", "the login"
        console.sendline("root")
        console.expect(r"# ", timeout=60)
        # The prompt is set in two halves, so the echo of this line is not taken for it.
        half = len(PROMPT) // 2
        console.sendline(f"stty -echo; export PS1='{PROMPT[:half]}''{PROMPT[half:]}' SYSTEMD_COLORS=0 SYSTEMD_PAGER=")
        console.expect_exact(PROMPT, timeout=60)

        def run(command, timeout=60):
            return run_on(console, PROMPT, command, timeout)

        stage, previous = "the system running", "the shell"
        out, _ = run("systemctl is-system-running --wait", timeout=a.running_timeout)
        timings.write(f"running {time.monotonic() - started:.1f}\n")
        fact("system", out.splitlines()[-1] if out else "unknown")
        stage, previous = "the facts", "the system running"
        if form == "yoke":
            read_yoke_alone(run, fact, ACCOUNT)
        else:
            read_yoke_alone_as_a_service(run, fact)
    except (TimeoutError, OSError) as e:
        stopped = f"stopped waiting for {stage}, after {previous}, {time.monotonic() - started:.1f} s"
        print(stopped, flush=True)
        with open(os.path.join(a.out, f"{form}.stopped"), "w") as f:
            f.write(stopped + "\n")
    timings.close()

    # The display, as a person sees it: one frame from the capture device, a second after it is opened.
    node = capture_node(a.video_root, a.capture)
    display = "absent"
    if node and stopped is None:
        photograph = os.path.join(a.out, f"{form}-display.png")
        done = subprocess.run([a.ffmpeg, "-hide_banner", "-loglevel", "error", "-f", "v4l2", "-video_size",
                               "1920x1080", "-i", node, "-ss", "1", "-frames:v", "1", "-y", photograph],
                              capture_output=True, text=True)
        display = "taken" if done.returncode == 0 and os.path.getsize(photograph) > 0 else "failed"
    elif node is None:
        display = "absent"
    else:
        display = "not taken"
    fact("display", display)

    if stopped is None:
        # Powered off, so that the person can take the medium out.
        try:
            console.sendline("poweroff")
            console.expect(r"reboot: Power down|Power down", timeout=120)
        except (TimeoutError, OSError):
            pass
    log.close()
    record_facts.close()

    wrong = [f"{name} is {facts.get(name, 'not read')}, not {value}" for name, value in wanted.items()
             if facts.get(name) != value]
    if stopped:
        wrong.insert(0, stopped)
    print(f"pass  {case}" if not wrong else f"FAIL  {case} — {'; '.join(wrong)}", flush=True)
    return 0 if not wrong else 1


if __name__ == "__main__":
    sys.exit(main())
