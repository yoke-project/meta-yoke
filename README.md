# meta-yoke

## What it is

The Yocto Project layer for Yoke: the recipes that build Yoke's programs and libraries into an
embedded Linux image with BitBake, each from the source archive of a release, pinned by its checksum.

It is a layer of the Yocto Project's `wrynose` series. It is not where Yoke is built for development:
each repository builds itself with its own verbs, and this layer only describes how an image integrator builds what was released.

## What is where

| Path | What it holds |
| --- | --- |
| `conf/layer.conf` | The layer's configuration: the collection `yoke`, compatible with `wrynose`, depending on `core`, `openembedded-layer` and `meta-python` |
| `recipes-yoke/yoke/` | `yoke`: the Core, the manager, the guardian and the authentication program for a device; the composer and the conformance suite for a workstation; the packaging inputs, among them the guardian's user unit; and the composer for the build host |
| `recipes-yoke/yoke-sdk-*/`, `recipes-yoke/python3-yoke-*/` | The five families: the C, C++ and Rust libraries for building against, the Python libraries for a device, the Go family's harnesses for a workstation |
| `recipes-yoke/yoke-reference/` | The example's units that run on the host, the Go clock, and `com.yoke.station.device`, the example as a device runs it alone, composed in the build; the Plugins and the panel installed where the service form reads them, and the example's service composition for an administrator |
| `recipes-graphics/lvgl/` | What the LVGL panel needs of the layers' LVGL: its framebuffer driver, and its library linked as it builds it |
| `recipes-yoke/yoke-example-host/`, `recipes-yoke/yoke-example-service/`, `recipes-yoke/images/` | The two images this layer is tested with, one per form. In the application form, a host of the example whose first boot installs it and whose account's guardian brings it up; it needs the distro features `systemd` and `pam`. In the service form, a host that installs the example's composition, links the conventional path to it and enables `yoke.service`, which the init system starts. Tests of the layer, not products |
| `checks/`, `ci/` | This repository's own checks, and the scripts continuous integration runs; `ci/image.sh` builds an image with the layer, in a build host it defines and at the revisions `ci/layers.lock` pins, and boots it under QEMU |

## Working on it

[`just`](https://just.systems) 1.58.0 or newer. `just develop` also puts the published verification
tool, `yoke-verify`, on the `PATH`, which `just test` needs. The `Containerfile` builds a container
with the runner.

| Command | What it does |
| --- | --- |
| `just build` | Says there is nothing to build yet |
| `just test` | Runs the checks, and checks each description against its tests |
| `just lint` | Parses every shell script |
| `just fmt` | Says there is nothing to format yet |
| `just develop` | Verifies the installed `just` against a floor, given as `just develop 1.58.0`, and installs `yoke-verify` |
| `just release` | Says there is nothing to publish yet |

An image is built and booted with `ci/image.sh [machine ...]` — `qemux86-64` and `qemuarm64` unless named —
which needs Podman and keeps the layers' checkouts, the downloads and the shared state under `~/.cache/meta-yoke`
(or `YOKE_YOCTO_CACHE`). A cold build of both machines takes hours and tens of gigabytes. Continuous
integration runs it on a self-hosted runner labelled `yoke`, for every push to `main` and for a proposed
change from this repository, never from a fork.

## Where the depth is

The documentation at [docs.yoke-project.dev](https://docs.yoke-project.dev/): the
[reference](https://docs.yoke-project.dev/reference/) for what the programs are, and the
[contributors' section](https://docs.yoke-project.dev/contributing/) for how the work is done.

## Licence

MIT, in [`LICENSE`](LICENSE), as Yocto Project layers carry.
