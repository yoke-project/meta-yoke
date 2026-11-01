# Yoke alone, in an image

| | |
| --- | --- |
| **Feature** | the layer builds an image of Yoke alone in each form — the runtime, the packaging inputs and nothing an application adds — and the forms' kas files name them, so that a reader who follows the documentation builds and boots the images continuous integration does: in the application form, an account that hosts applications, lingers and has its guardian enabled, with no application installed; in the service form, the runtime and the inputs with `yoke.service` left disabled until a deployment is put in place |
| **Planning item** | yoke-project/meta-yoke#42 |

## meta-yoke:the-yoke-image.01 — the images hold Yoke and nothing an application adds

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §meta-yoke, and what its recipes do · arch/25-guardian/02 §How it comes to be running · arch/00-system/02 §The service form on disk |
| **Level** | L1 |
| **Method** | check |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a clean checkout |
| **Action** | read the recipes of the two images, the recipe of the application form's host, and `kas/application.yml` and `kas/service.yml` |
| **Expected** | `yoke-image` installs `yoke-host`, which requires the distro features `systemd` and `pam`, creates the account `apps` in the group `yoke-apps`, makes it linger, enables the guardian's unit `yoke` ships for it and writes no unit of its own, and depends on `yoke`, `yoke-core`, `yoke-guardian` and `yoke-packaging`; `yoke-service-image` installs `yoke`, `yoke-core` and `yoke-packaging` and enables nothing; neither image nor the host names a tooling package or anything of the example; `kas/application.yml` names `yoke-image` and `kas/service.yml` names `yoke-service-image` |

## meta-yoke:the-yoke-image.02 — the application form's image boots into an account whose guardian runs

| Field | Value |
| --- | --- |
| **Cites** | arch/25-guardian/02 · testing/20 §The levels |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the build of `the-layer.05`, for `qemux86-64` and `qemuarm64`; QEMU built by the same build |
| **Action** | read the image's manifest; boot the image under QEMU and, on its serial console, read the account, its guardian's unit, its instances and `yoke.service` |
| **Expected** | the image holds `yoke`, `yoke-core`, `yoke-guardian` and `yoke-packaging`, and neither `yoke-compose`, `yoke-conformance` nor any package of the example; for each machine it boots to a login; the account `apps` lingers with no one signed in; its `yoke-guardian.service` is active; it has no instance; and `yoke.service` stays disabled |

## meta-yoke:the-yoke-image.03 — the service form's image boots with the service form's unit waiting

| Field | Value |
| --- | --- |
| **Cites** | arch/00-system/02 §The service form on disk · testing/20 §The levels |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the build of `the-layer.05`, for `qemux86-64` and `qemuarm64`; QEMU built by the same build |
| **Action** | read the image's manifest; boot the image under QEMU and, on its serial console, read `yoke.service`, the deployment link and the Core's configuration |
| **Expected** | the image holds `yoke`, `yoke-core` and `yoke-packaging`, and neither `yoke-guardian`, `yoke-compose`, `yoke-conformance` nor any package of the example; for each machine it boots to a login with the system running; `yoke.service` is disabled; `/etc/yoke/deployment.yaml` does not exist; `/etc/yoke/core.yaml` does — the host waits for a deployment, which an application adds |
