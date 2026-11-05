#!/usr/bin/env python3
"""A board the board pass cannot tell from a real one, on a pseudo-terminal: it prints a kernel's first line
and a login, then answers each line it is sent as a shell would, the commands found first in the stand-ins
directory. It prints the terminal's path on its first line, and runs until it is powered off or killed.

Usage: fake_board.py <stand-ins directory> <root> [silent]
  root is where the board's /etc is; silent prints the kernel's line and nothing after it.
"""
import os
import pty
import re
import subprocess
import sys
import time
import tty

stand_ins, root = sys.argv[1], sys.argv[2]
silent = len(sys.argv) > 3 and sys.argv[3] == "silent"

master, slave = pty.openpty()
tty.setraw(slave)
print(os.ttyname(slave), flush=True)


def say(text):
    os.write(master, text.replace("\n", "\r\n").encode())


def lines():
    """Each line the script sends, as it is sent."""
    pending = b""
    while True:
        pending += os.read(master, 4096)
        while b"\r" in pending or b"\n" in pending:
            line, pending = re.split(rb"\r\n?|\n", pending, maxsplit=1)
            yield line.decode(errors="replace")


time.sleep(1)
say("\nRPi: BOOTLOADER release VERSION:fake\n[    0.000000] Booting Linux on physical CPU 0x0000000000 [0x414fd0b1]\n")
if silent:
    while True:
        time.sleep(60)
time.sleep(1)
say("\nOpenEmbedded nodistro.0 raspberrypi5 ttyAMA10\n\nraspberrypi5 login: ")

prompt = "root@raspberrypi5:~# "
env = dict(os.environ, PATH=f"{stand_ins}:{os.environ['PATH']}")
for line in lines():
    if not line.strip():
        say(prompt)
        continue
    if line == "root" and prompt.startswith("root@"):
        say(prompt)
        continue
    set_prompt = re.search(r"PS1='([^']*)''([^']*)'", line)
    if set_prompt:
        prompt = set_prompt.group(1) + set_prompt.group(2)
        say(prompt)
        continue
    if line.strip() == "poweroff":
        say("\n[   42.000000] reboot: Power down\n")
        time.sleep(1)
        os.close(master)
        sys.exit(0)
    # The board's /etc is the fake's root's.
    command = line.replace("/etc/yoke", f"{root}/etc/yoke")
    done = subprocess.run(["sh", "-c", command], env=env, capture_output=True, text=True)
    say(done.stdout + done.stderr + prompt)
