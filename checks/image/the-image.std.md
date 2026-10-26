# The image

| | |
| --- | --- |
| **Feature** | an image of the runtime packages, the packaging inputs and the example, built with this layer and booted under QEMU on `qemux86-64` and `qemuarm64`: the example as a device runs it alone is composed in the build, by the composer built for the build host, and installed at the first boot as an application of an account the image holds; the account's user manager runs at boot, and starts the guardian with the unit `yoke` ships; the guardian brings the instance up, its `acquire` bound to an `instrument` the image runs as a device of its own; the LVGL panel draws to the emulated framebuffer; an operator reads the instance's state; the tooling packages are not in it |
| **Planning item** | yoke-project/meta-yoke#24 |

## meta-yoke:the-image.01 — the image says what a host of the example holds, and states nothing `yoke` owns

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §meta-yoke, and what its recipes do · prj_structure/80 · arch/25-guardian/02 · arch/10-manager/07 §Creating an instance, and naming it |
| **Level** | L1 |
| **Method** | check |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a clean checkout |
| **Action** | read the image's recipe, the recipe of the example's host, and `ci/image-build.sh` |
| **Expected** | the image installs the example's host and no tooling package — neither `yoke-compose` nor `yoke-conformance`; the example's host requires the distro features `systemd` and `pam`, under which the account's user manager runs, and depends on the runtime packages, the packaging inputs, the example's package and `instrument`; the layer writes no unit of the guardian's, and enables the one `yoke` ships for the account; the first-boot unit, ordered before the account's user manager, installs the package with `yoke app install`, creates the instance running with `yoke instance create --running` and enables it with `yoke instance enable`, and starts nothing itself — the guardian's unit brings it up; the image is what `ci/image-build.sh` builds |

## meta-yoke:the-image.02 — the image holds a host of the example, and no tooling

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §meta-yoke, and what its recipes do · prj_structure/40 E2 · testing/20 §The levels |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the build of `the-layer.05`, for `qemux86-64` and `qemuarm64` |
| **Action** | read the image's manifest; unpack the example's package |
| **Expected** | the image holds `yoke`, `yoke-core`, `yoke-guardian`, `yoke-packaging`, `yoke-reference-instrument`, the example's package and LVGL, and neither `yoke-compose`, `yoke-conformance` nor any family's harness; the example's package holds one application package, `com.yoke.station.device`, built for the machine's architecture: its `acquire` and `panel` are programs for that architecture |

## meta-yoke:the-image.03 — the image boots into a host whose guardian brings the instance up

| Field | Value |
| --- | --- |
| **Cites** | arch/25-guardian/02 · testing/20 §The levels · prj_structure/40 E2 |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the image of `.02`, for each machine; QEMU built by the same build |
| **Action** | boot the image under QEMU; on its serial console, wait for the first boot to end; as the account, read the guardian's unit, the instance, and the Core's status through the manager |
| **Expected** | for each machine the image boots to a login; the first-boot unit ends successfully; the account's `yoke-guardian.service` is active, started by the account's user manager with no one signed in; the instance `station` is pinned to `com.yoke.station.device` and wants to run; its Core answers `yoke core status`, and its units `acquire` and `panel` are running |

## meta-yoke:the-image.04 — the LVGL panel draws to the emulated framebuffer

| Field | Value |
| --- | --- |
| **Cites** | testing/20 §The levels · prj_structure/97 §meta-yoke, and what its recipes do |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the boot of `.03`, for each machine, with the instance's units running |
| **Action** | take a screendump of QEMU's display |
| **Expected** | the screendump is not of one colour: something has drawn to the framebuffer the panel binds |
