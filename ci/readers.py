"""What a boot of Yoke alone reads on a console, in either form: shared by ci/boot.py, which boots the image
under QEMU, and ci/board.py, which reads it on a real board, so that both read the same facts.

A reader is given `run`, which sends one command to the console and returns what it printed and its exit
status, and `fact`, which states one fact by name.
"""
import re

# What systemd writes to a terminal around a session, and colours: neither is a command's output.
terminal = re.compile(r"\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)|\x1b\[[0-9;?]*[A-Za-z]")


def run_on(console, prompt, command, timeout=60):
    """What a command printed on the console and its exit status, the prompt being one of the script's own.
    The terminal echoes nothing, so what comes before the status is the command's output alone."""
    console.sendline(f"{command}; echo \"status=$?\"")
    # The serial console ends a line with more than one carriage return.
    console.expect(r"status=(\d+)\r*\n", timeout=timeout)
    out = terminal.sub("", console.before.decode(errors="replace")).replace("\r", "")
    status = int(console.match.group(1))
    console.expect_exact(prompt, timeout=timeout)
    return out.strip(), status


def as_account(account, command):
    """A command run as the account, with its user manager's runtime directory, as a signed-in user has it."""
    return (f"su -s /bin/sh {account} -c 'XDG_RUNTIME_DIR=/run/user/$(id -u {account}) "
            f"DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u {account})/bus {command}'")


def read_yoke_alone(run, fact, account):
    """Yoke alone in the application form: the account, its guardian, no instance, and no service form."""
    linger, _ = run(f"loginctl show-user {account} -p Linger --value")
    state, _ = run(f"loginctl show-user {account} -p State --value")
    fact("account", f"{linger}/{state}" if linger and state else "unknown")
    out, status = run(f"for s in $(loginctl show-user {account} -p Sessions --value); do "
                      "loginctl show-session $s -p Class --value; done | grep -c '^user'")
    fact("signed-in", out or "unknown")
    out, status = run(as_account(account, "systemctl --user is-enabled yoke-guardian.service"))
    fact("guardian-enabled", out.splitlines()[-1] if out else "unknown")
    # With no instance the guardian has nothing to watch, and exits: it ran if it is running, or ended well.
    state = {}
    for name in ("ActiveState", "Result", "ExecMainStatus", "ExecMainExitTimestampMonotonic"):
        out, status = run(as_account(account, f"systemctl --user show yoke-guardian.service -p {name} --value"))
        state[name] = out.splitlines()[-1] if out else ""
    ran = state["ActiveState"] == "active" or (state["Result"] == "success" and state["ExecMainStatus"] == "0"
                                               and state["ExecMainExitTimestampMonotonic"] not in ("", "0"))
    fact("guardian", "ran" if ran else "/".join(state.values()) or "unknown")
    out, status = run(as_account(account, "yoke instance list") + " | grep -c .")
    fact("instances", out.splitlines()[-1] if out else "unknown")
    out, status = run("systemctl is-enabled yoke.service")
    fact("service-unit", out.splitlines()[-1] if out else "unknown")


def read_yoke_alone_as_a_service(run, fact):
    """Yoke alone in the service form: the unit waits, with no deployment, and the Core's configuration."""
    out, status = run("systemctl is-enabled yoke.service")
    fact("service-enabled", out.splitlines()[-1] if out else "unknown")
    out, status = run("test -e /etc/yoke/deployment.yaml && echo present || echo absent")
    fact("deployment", out.splitlines()[-1] if out else "unknown")
    out, status = run("test -f /etc/yoke/core.yaml && echo present || echo absent")
    fact("core-config", out.splitlines()[-1] if out else "unknown")
