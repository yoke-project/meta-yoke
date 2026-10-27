# The service image

| | |
| --- | --- |
| **Feature** | an image of the runtime packages, the packaging inputs and the example as a device runs it, in the service form, built with this layer and booted under QEMU on `qemux86-64` and `qemuarm64`: the reference recipe's packages put the Plugin's Manifest and executable and the panel where the service form reads them, as a distribution's would; the image's host is the administrator, installing the example's composition in `/etc/yoke/deployments/`, linking the conventional path to it and enabling `yoke.service`; the init system starts the deployment at boot, its `acquire` bound to an `instrument` the image runs as a device of its own; the LVGL panel draws to the emulated framebuffer; the tooling packages and the guardian are not in it |
| **Planning item** | yoke-project/meta-yoke#34 |

## meta-yoke:the-service-image.01 — the image says what a service host of the example holds, and states nothing `yoke` owns

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §meta-yoke, and what its recipes do · arch/00-system/02 §The service form on disk · arch/97-trace/07 §The composition document |
| **Level** | L1 |
| **Method** | check |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a clean checkout |
| **Action** | read the service image's recipe and the recipe of the example's service host |
| **Expected** | the image installs the service host and no tooling package; the host depends on the runtime, the inputs, `acquire`'s and the panel's packages, `instrument` and the example's composition, and not on the guardian; it installs its composition at `/etc/yoke/deployments/station.yaml`, links `/etc/yoke/deployment.yaml` to it, and enables `yoke.service` by a preset read before `yoke-packaging`'s; it writes no unit of `yoke`'s; the unit running `instrument` is ordered before `yoke.service` |

## meta-yoke:the-service-image.02 — the service image holds a deployment of the example, and no tooling

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §meta-yoke, and what its recipes do · prj_structure/40 E2 · testing/20 §The levels |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the build of `the-layer.05`, for `qemux86-64` and `qemuarm64` |
| **Action** | read the service image's manifest |
| **Expected** | the image holds `yoke`, `yoke-core`, `yoke-packaging`, `yoke-reference-acquire`, `yoke-reference-panel`, `yoke-reference-instrument`, `yoke-reference-station-service` and LVGL, and neither `yoke-compose`, `yoke-conformance`, `yoke-guardian` nor any family's harness |

## meta-yoke:the-service-image.03 — the init system starts the deployment, and its Core runs the example

| Field | Value |
| --- | --- |
| **Cites** | arch/97-trace/07 §Starting it · arch/00-system/02 §The service form on disk · testing/20 §The levels |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the image of `.02`, for each machine; QEMU built by the same build |
| **Action** | boot the image under QEMU; on its serial console, as root, read the init system's unit, the composition in force, and the deployment through the manager |
| **Expected** | for each machine the image boots to a login; `yoke.service` is enabled and active; `/etc/yoke/deployment.yaml` links to `deployments/station.yaml`, which is the example's own composition unchanged; `yoke service status` says the instance answers and is ready; its units `acquire` and `panel` are `Running` |

## meta-yoke:the-service-image.04 — the LVGL panel draws to the emulated framebuffer, as a service

| Field | Value |
| --- | --- |
| **Cites** | testing/20 §The levels · prj_structure/97 §meta-yoke, and what its recipes do |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the boot of `.03`, for each machine, with the deployment's units running |
| **Action** | take a screendump of QEMU's display |
| **Expected** | most of the screendump is light, as the panel's theme draws and neither a console nor QEMU's own message is |
