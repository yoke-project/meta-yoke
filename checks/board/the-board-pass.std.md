# The board pass

| | |
| --- | --- |
| **Feature** | `ci/board.py` drives a real board's serial console as `ci/boot.py` drives QEMU's: a person writes the image to the board's medium and powers it on, and the script waits for the kernel and a login, reads the facts the QEMU boot reads for that form, photographs the board's display through a video capture device named by its name, measures how long each stage took, and writes the record — what the person did, what the script read, the photograph and the console's log; the `board` workflow runs it on the runner the board is wired to, and only when a person starts it |
| **Planning item** | yoke-project/meta-yoke#39 |

## meta-yoke:the-board-pass.01 — in the application form, the script reads the board as QEMU's boot is read, and writes the record

| Field | Value |
| --- | --- |
| **Cites** | testing/20 §The board pass · arch/25-guardian/02 §How it comes to be running |
| **Level** | L1 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a fake board on a pseudo-terminal: it prints a kernel's first line, then a login, then answers as a shell whose `loginctl`, `systemctl`, `su` and `yoke` say what `yoke-image` says; a fake capture device named `UGREEN 25773` beside one named `HP HD Camera`, and a stand-in for `ffmpeg` that writes the frame it is asked for, showing a screen with something drawn |
| **Action** | run `ci/board.py` for the form `yoke`, the person's act stated as the image written |
| **Expected** | it exits 0; its lines carry the facts `the-yoke-image.02` reads, `account=yes/lingering signed-in=0 guardian-enabled=enabled guardian=ran instances=0 service-unit=disabled`, `display-first drawn`, `display drawn` and `pass  meta-yoke:the-board-pass.05`; the record holds the act as stated, the facts, the seconds to the kernel, to the login and to the system running, the photograph taken from `UGREEN 25773` and never from the camera, and the console's log |

## meta-yoke:the-board-pass.02 — in the service form, the script reads the facts of the service form

| Field | Value |
| --- | --- |
| **Cites** | testing/20 §The board pass · arch/00-system/02 §The service form on disk |
| **Level** | L1 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the fake board of `.01`, answering as `yoke-service-image` does |
| **Action** | run `ci/board.py` for the form `yoke-service` |
| **Expected** | it exits 0; its lines carry `system=running service-enabled=disabled deployment=absent core-config=present`, `display drawn` and `pass  meta-yoke:the-board-pass.06`; the record holds the photograph and the timings as in `.01` |

## meta-yoke:the-board-pass.03 — with no capture device of the name given, the display is said absent and the pass fails

| Field | Value |
| --- | --- |
| **Cites** | testing/20 §The board pass |
| **Level** | L1 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the fake board of `.01`; video devices named `HP HD Camera` and `Logitech Webcam C930e` only |
| **Action** | run `ci/board.py` for the form `yoke`, naming the capture device `UGREEN` |
| **Expected** | it exits 1; the fact `display` is `absent`, `meta-yoke:the-board-pass.05` fails naming the display, and nothing was asked of `ffmpeg` |

## meta-yoke:the-board-pass.04 — a board that shows no login in time stops the pass, saying where and after how long

| Field | Value |
| --- | --- |
| **Cites** | testing/20 §The board pass |
| **Level** | L1 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a fake board that prints a kernel's first line and nothing after it |
| **Action** | run `ci/board.py` for the form `yoke` with a login timeout of two seconds |
| **Expected** | it exits 1; the record says the pass stopped waiting for the login, after the kernel, and the seconds it waited; `meta-yoke:the-board-pass.05` fails |

## meta-yoke:the-board-pass.05 — on the board, the application form's image boots into an account whose guardian has run

| Field | Value |
| --- | --- |
| **Cites** | testing/20 §The board pass · arch/25-guardian/02 §How it comes to be running |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | machine: qemu · deployment form: service |
| **Label** | blocking |
| **Precondition** | `yoke-image` for `raspberrypi5`, built from the layer at the head, written by a person to the board's card; the board's serial console and its display's capture device wired to the runner |
| **Action** | the person powers the board on; the `board` workflow reads its console |
| **Expected** | the board boots to a login; the facts are those of `the-yoke-image.02` — the account `apps` lingers with no one signed in, its guardian is enabled and has run, it has no instance, `yoke.service` is disabled — and the display is photographed, and something is drawn on it |

## meta-yoke:the-board-pass.06 — on the board, the service form's image boots with the service form's unit waiting

| Field | Value |
| --- | --- |
| **Cites** | testing/20 §The board pass · arch/00-system/02 §The service form on disk |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | machine: qemu · deployment form: application |
| **Label** | blocking |
| **Precondition** | `yoke-service-image` for `raspberrypi5`, built from the layer at the head, written by a person to the board's card; the console and the capture device as in `.05` |
| **Action** | the person powers the board on; the `board` workflow reads its console |
| **Expected** | the board boots to a login with the system running; the facts are those of `the-yoke-image.03` — `yoke.service` disabled, no `/etc/yoke/deployment.yaml`, `/etc/yoke/core.yaml` present — and the display is photographed, and something is drawn on it |

## meta-yoke:the-board-pass.07 — the board workflow is started by hand alone, on the runner beside the board, and hands its record over

| Field | Value |
| --- | --- |
| **Cites** | testing/20 §The board pass · testing/40 §A record |
| **Level** | L1 |
| **Method** | check |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a clean checkout |
| **Action** | read `.github/workflows/board.yml` |
| **Expected** | it is started by `workflow_dispatch` alone, naming the form and what was written to the medium; it runs on `[self-hosted, board]`; it runs `ci/board.py`, keeps its case's line and the form, assembles the record with `ci/record.sh L5 board` and hands the record and what the pass wrote over as artifacts, those two steps run whatever the pass decided |

## meta-yoke:the-board-pass.08 — a serial port that goes with the board's power is opened again, and the pass goes on

| Field | Value |
| --- | --- |
| **Cites** | testing/20 §The board pass |
| **Level** | L1 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a fake board whose port, when powered, says a few NULs and is gone, then comes back under the same name before the kernel's first line, as a USB serial port powered by the board does |
| **Action** | run `ci/board.py` for the form `yoke` against the port's name |
| **Expected** | it exits 0 and its case passes: the script opened the port again and read the boot as in `.01`; and the board workflow's step that runs it fails when the case fails, its exit status being the script's and not the last command's in a pipe |

## meta-yoke:the-board-pass.09 — a display with nothing drawn is lit again once, said so, and fails if it stays so

| Field | Value |
| --- | --- |
| **Cites** | testing/20 §The board pass |
| **Level** | L1 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the fake board of `.01`; a capture that shows, in turn, the capture device's own *no signal* screen and then a drawn one; and captures that show *no signal*, or black, every time |
| **Action** | run `ci/board.py` for the form `yoke` against each |
| **Expected** | the frame is read after the capture device has had seconds to lock, and classed `drawn`, `blank` or `no signal`; one not drawn makes the script set the board's display mode again from its console — blanking the framebuffer and unblanking it — and photograph once more; the first passes with `display-first no signal` and `display drawn`, both photographs asked; the others exit 1 with `display no signal` and `display blank` and the case failing on the display — a capture device that loses the signal when the board's power goes is lit again, and said to have been, and a display that shows nothing never passes |
