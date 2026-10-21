# The layer

| | |
| --- | --- |
| **Feature** | `meta-yoke` is a layer of the Yocto Project's newest long-term series, `wrynose`: its configuration names its collection, the series it is compatible with and the layers it depends on; it is tested in a build pinned by revision, which fetches first and then builds with the network off; an image is built with it on a runner of the project's own, for every change from this repository and never for one from a fork |
| **Planning item** | yoke-project/meta-yoke#17 |

## meta-yoke:the-layer.01 — the layer says what it is, what it works with and what it needs

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §meta-yoke, and what its recipes do · prj_structure/85 §The series |
| **Level** | L1 |
| **Method** | check |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a clean checkout |
| **Action** | read `conf/layer.conf` |
| **Expected** | it names the collection `yoke`, finds recipes under `recipes-*/`, declares itself compatible with `wrynose` and with no other series, and depends on `core` and `openembedded-layer` — the layer that carries gRPC, protobuf-c and LVGL |

## meta-yoke:the-layer.02 — the build it is tested in is pinned

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §What a recipe pins, and what offline means · prj_structure/40 E1 |
| **Level** | L1 |
| **Method** | check |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a clean checkout |
| **Action** | read `ci/layers.lock` and the scripts that build an image |
| **Expected** | the lock names BitBake, `openembedded-core` and `meta-openembedded`, each by a full commit; the scripts check each one out at that commit and at no branch, and the build host is a container this repository defines — so a build tomorrow is the build of today |

## meta-yoke:the-layer.03 — an image is built on the project's runner, and never for a stranger's change

| Field | Value |
| --- | --- |
| **Cites** | testing/20 §The levels · prj_structure/95 §Continuous integration |
| **Level** | L1 |
| **Method** | check |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a clean checkout |
| **Action** | read the workflow that builds an image |
| **Expected** | it runs on a self-hosted runner, for every push to the default branch and for a proposed change only when that change comes from this repository — a change from a fork would run its own code on the runner's host; every command is a script under `ci/`; and it hands over a record at L5 whatever the build decided |

## meta-yoke:the-layer.04 — the layer is taken into a build of the series

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §meta-yoke, and what its recipes do · prj_structure/85 §The series |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a build of the layers the lock names, in the container this repository defines |
| **Action** | add the layer; list the build's layers; parse every recipe |
| **Expected** | the layer is listed by its collection, `yoke`, from this layer's directory; the parse ends with no error, and nothing is said about the layer being incompatible with the series |

## meta-yoke:the-layer.05 — an image builds with the layer, offline once fetched

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §What a recipe pins, and what offline means · prj_structure/40 E2 · testing/20 §The levels |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the build of `.04`, for `qemux86-64` and for `qemuarm64`, with `systemd` as the init system |
| **Action** | fetch everything the image needs; then build the image with the network off |
| **Expected** | for each machine the fetch ends, and the image builds with no task reaching the network — the property a distribution building from source needs, shown rather than stated |
