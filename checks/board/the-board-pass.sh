#!/usr/bin/env bash
# The checks described by the-board-pass.std.md that run ci/board.py against a fake board, on a
# pseudo-terminal; the cases on the board itself are ci/board.py's own.

bp_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# bp_stand_ins <dir> <form>: the commands the fake board's shell finds first, saying what the form's image says.
bp_stand_ins() {
  local dir="$1" form="$2"
  mkdir -p "$dir"
  cat > "$dir/loginctl" <<'EOF'
#!/bin/sh
case "$*" in
  *"-p Linger"*) echo yes ;;
  *"-p State"*) echo lingering ;;
  *"-p Sessions"*) echo "" ;;
esac
EOF
  cat > "$dir/id" <<'EOF'
#!/bin/sh
echo 1000
EOF
  cat > "$dir/su" <<'EOF'
#!/bin/sh
# su -s /bin/sh <account> -c <command>
shift 3; [ "$1" = "-c" ] && exec sh -c "$2"
EOF
  cat > "$dir/yoke" <<'EOF'
#!/bin/sh
exit 0
EOF
  if [[ "$form" == yoke ]]; then
    cat > "$dir/systemctl" <<'EOF'
#!/bin/sh
case "$*" in
  "is-system-running --wait") echo running ;;
  "is-enabled yoke.service") echo disabled ;;
  "--user is-enabled yoke-guardian.service") echo enabled ;;
  *"-p ActiveState"*) echo inactive ;;
  *"-p Result"*) echo success ;;
  *"-p ExecMainStatus"*) echo 0 ;;
  *"-p ExecMainExitTimestampMonotonic"*) echo 4211873 ;;
esac
EOF
  else
    cat > "$dir/systemctl" <<'EOF'
#!/bin/sh
case "$*" in
  "is-system-running --wait") echo running ;;
  "is-enabled yoke.service") echo disabled ;;
esac
EOF
  fi
  chmod +x "$dir"/*
}

# bp_video <dir> <name>...: a video4linux class with one capture node per name, and its metadata node.
bp_video() {
  local dir="$1" n=0 name; shift
  for name in "$@"; do
    mkdir -p "$dir/video$n" "$dir/video$((n + 1))"
    echo "$name" > "$dir/video$n/name"; echo 0 > "$dir/video$n/index"
    echo "$name" > "$dir/video$((n + 1))/name"; echo 1 > "$dir/video$((n + 1))/index"
    n=$((n + 2))
  done
}

# bp_ffmpeg <dir>: a stand-in that writes the frame it is asked for, and notes how it was asked.
bp_ffmpeg() {
  cat > "$1/ffmpeg" <<'EOF'
#!/bin/sh
echo "$*" >> "$(dirname "$0")/ffmpeg.asked"
for last; do :; done
printf 'PNG' > "$last"
EOF
  chmod +x "$1/ffmpeg"
}

# bp_pass <dir> <form> <capture name> <fake board's mode> [timeout args...]: the fake board started, the
# script run against it; its lines in <dir>/lines, its exit status in <dir>/status.
bp_pass() {
  local dir="$1" form="$2" capture="$3" mode="$4"; shift 4
  mkdir -p "$dir/root/etc/yoke" "$dir/out" "$dir/bin"
  [[ "$form" == yoke-service ]] && echo "state_dir: /var/lib/yoke" > "$dir/root/etc/yoke/core.yaml"
  bp_stand_ins "$dir/stand-ins" "$form"
  bp_ffmpeg "$dir/bin"
  python3 "$bp_root/checks/board/fake_board.py" "$dir/stand-ins" "$dir/root" $mode > "$dir/port" 2> "$dir/board.err" &
  local board=$! waited=0
  until [[ -s "$dir/port" ]] || (( waited++ > 50 )); do sleep 0.1; done
  python3 "$bp_root/ci/board.py" --form "$form" --port "$(head -1 "$dir/port")" --capture "$capture" \
    --video-root "$dir/video" --ffmpeg "$dir/bin/ffmpeg" --out "$dir/out" \
    --wrote "yoke-image-raspberrypi5.rootfs.wic.bz2, written to the card" "$@" > "$dir/lines" 2>&1
  echo $? > "$dir/status"
  kill "$board" 2>/dev/null; wait "$board" 2>/dev/null
  return 0
}

bp_has() { grep -qF -- "$2" "$1" || { echo "$(basename "$1") does not hold: $2"; return 1; }; }

# std: meta-yoke:the-board-pass.01
check_the_board_pass_reads_the_application_form() {
  local dir; dir="$(mktemp -d)"
  bp_video "$dir/video" "HP HD Camera" "UGREEN 25773"
  bp_pass "$dir" yoke UGREEN ""
  [[ "$(cat "$dir/status")" == 0 ]] || { echo "the pass exited $(cat "$dir/status"): $(tail -5 "$dir/lines")"; return 1; }
  local each
  for each in "account yes/lingering" "signed-in 0" "guardian-enabled enabled" "guardian ran" "instances 0" \
              "service-unit disabled" "display taken" "pass  meta-yoke:the-board-pass.05"; do
    bp_has "$dir/lines" "$each" || return 1
  done
  bp_has "$dir/out/yoke.acts" "yoke-image-raspberrypi5.rootfs.wic.bz2, written to the card" || return 1
  bp_has "$dir/out/yoke.facts" "guardian ran" || return 1
  for each in kernel login running; do
    grep -qE "^$each [0-9]+(\.[0-9]+)?$" "$dir/out/yoke.timings" || { echo "no seconds to the $each"; return 1; }
  done
  [[ -s "$dir/out/yoke-display.png" ]] || { echo "no photograph"; return 1; }
  grep -q "/dev/video2" "$dir/bin/ffmpeg.asked" || { echo "the photograph was not taken from UGREEN's node"; return 1; }
  grep -q "/dev/video0" "$dir/bin/ffmpeg.asked" && { echo "the camera was asked"; return 1; }
  bp_has "$dir/out/yoke-console.log" "Booting Linux" || return 1
}

# std: meta-yoke:the-board-pass.02
check_the_board_pass_reads_the_service_form() {
  local dir; dir="$(mktemp -d)"
  bp_video "$dir/video" "UGREEN 25773"
  bp_pass "$dir" yoke-service UGREEN ""
  [[ "$(cat "$dir/status")" == 0 ]] || { echo "the pass exited $(cat "$dir/status"): $(tail -5 "$dir/lines")"; return 1; }
  local each
  for each in "system running" "service-enabled disabled" "deployment absent" "core-config present" \
              "display taken" "pass  meta-yoke:the-board-pass.06"; do
    bp_has "$dir/lines" "$each" || return 1
  done
  [[ -s "$dir/out/yoke-service-display.png" ]] || { echo "no photograph"; return 1; }
  grep -qE "^running [0-9]" "$dir/out/yoke-service.timings" || { echo "no seconds to the system running"; return 1; }
}

# std: meta-yoke:the-board-pass.03
check_with_no_capture_device_the_display_is_absent() {
  local dir; dir="$(mktemp -d)"
  bp_video "$dir/video" "HP HD Camera" "Logitech Webcam C930e"
  bp_pass "$dir" yoke UGREEN ""
  [[ "$(cat "$dir/status")" == 1 ]] || { echo "the pass exited $(cat "$dir/status")"; return 1; }
  bp_has "$dir/lines" "display absent" || return 1
  grep -qE "^FAIL  meta-yoke:the-board-pass.05 — .*display" "$dir/lines" || { echo "the case does not fail on the display"; return 1; }
  [[ ! -e "$dir/bin/ffmpeg.asked" ]] || { echo "ffmpeg was asked: $(cat "$dir/bin/ffmpeg.asked")"; return 1; }
}

# std: meta-yoke:the-board-pass.04
check_a_board_with_no_login_stops_the_pass() {
  local dir; dir="$(mktemp -d)"
  bp_video "$dir/video" "UGREEN 25773"
  bp_pass "$dir" yoke UGREEN silent --login-timeout 2
  [[ "$(cat "$dir/status")" == 1 ]] || { echo "the pass exited $(cat "$dir/status")"; return 1; }
  grep -qE "^stopped waiting for the login, after the kernel, [0-9]+(\.[0-9]+)? s" "$dir/lines" \
    || { echo "the pass does not say where it stopped: $(tail -3 "$dir/lines")"; return 1; }
  grep -qE "^FAIL  meta-yoke:the-board-pass.05" "$dir/lines" || { echo "the case does not fail"; return 1; }
}

# std: meta-yoke:the-board-pass.07
check_the_board_workflow_is_started_by_hand_alone() {
  local wf="$bp_root/.github/workflows/board.yml"
  [[ -f "$wf" ]] || { echo "no board workflow"; return 1; }
  python3 - "$wf" <<'PY' || return 1
import re, sys
text = open(sys.argv[1]).read()
on = re.search(r"(?ms)^on:\n(.*?)^\S", text)
if not on or re.findall(r"(?m)^  (\w+):", on.group(1)) != ["workflow_dispatch"]:
    raise SystemExit("it is started by something other than workflow_dispatch")
for each in ("form:", "wrote:", "runs-on: [self-hosted, board]", "ci/board.py", "ci/record.sh L5 board", "upload-artifact"):
    if each not in text:
        raise SystemExit(f"it does not hold {each}")
if len(re.findall(r"(?m)^\s*if: always\(\)", text)) < 2:
    raise SystemExit("the record's steps do not run whatever the pass decided")
PY
}
