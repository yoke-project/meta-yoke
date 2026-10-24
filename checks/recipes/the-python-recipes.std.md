# The Python recipes

| | |
| --- | --- |
| **Feature** | the Python family has recipes for the two packages a Python Plugin unit or interface client imports: `yoke-proto`, its definitions generated again with the Yocto series' generator from the definitions module, since generated Python imports only on the protobuf and gRPC that generated it, and `yoke-sdk`, the wheel its family published; each pinned by its checksum, built offline once fetched, in a package a device can install |
| **Planning item** | yoke-project/meta-yoke#21 |

## meta-yoke:the-python-recipes.01 — each recipe pins what its family published, and the definitions module by its checksum

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §What a recipe pins, and what offline means · prj_structure/40 E2 |
| **Level** | L1 |
| **Method** | check |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a clean checkout |
| **Action** | read the recipes of `python3-yoke-proto` and `python3-yoke-sdk`, and the layer's configuration |
| **Expected** | `python3-yoke-sdk` fetches the wheel `yoke_sdk` at its version from PyPI, and nothing else; `python3-yoke-proto` fetches the wheel `yoke_proto` at its version from PyPI and the definitions module at the same version from the Go proxy, and nothing else; each source is pinned by a `sha256sum`; `python3-yoke-proto` takes the series' gRPC generator, `python3-grpcio-tools-native`; and the layer depends on `meta-python`, which carries it |

## meta-yoke:the-python-recipes.02 — the Python recipes build the libraries, in packages a device installs

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §meta-yoke, and what its recipes do · prj_structure/40 E3 · prj_structure/40 E2 |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the build of `the-layer.04`, for `qemux86-64` and `qemuarm64` |
| **Action** | fetch `python3-yoke-proto` and `python3-yoke-sdk`; build them with the network off; list what their packages hold, and read their generated modules |
| **Expected** | `python3-yoke-sdk` holds the package `yoke_sdk` in the series' site-packages; `python3-yoke-proto` holds the package `yoke` there, every generated module of which names the protobuf and gRPC versions of the series, not those the published wheel was generated with; each package holds its licence and its notice; and neither holds a program |
