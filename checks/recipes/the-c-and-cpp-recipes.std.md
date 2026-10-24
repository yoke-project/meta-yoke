# The C and C++ recipes

| | |
| --- | --- |
| **Feature** | each of the C and C++ families has a recipe that builds the family's source release, pinned by its digest, with CMake against the gRPC, protobuf and protobuf-c the layers provide: the library in its package, and in a development package its headers, its CMake configuration and its `pkg-config` file; neither family installs a program |
| **Planning item** | yoke-project/meta-yoke#19 |

## meta-yoke:the-c-and-cpp-recipes.01 — each recipe pins the release its family published, and fetches nothing else but the definitions C++ generates again

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §What a recipe pins, and what offline means · prj_structure/97 §The definitions, and the four families that are not Go · prj_structure/40 E2 |
| **Level** | L1 |
| **Method** | check |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a clean checkout |
| **Action** | read the recipes of `yoke-sdk-c` and `yoke-sdk-cpp` |
| **Expected** | each one's first source is its family's source archive, at the release's download path for its version, with a `sha256sum`; C's is its only source, and C++'s only other is the definitions module at the Go proxy's path for the version its record pins, with a `sha256sum` of its own, since generated C++ compiles only against the protobuf that generated it; each takes the libraries it links from the layers — gRPC and protobuf-c for C, gRPC and protobuf for C++ — rather than from the archive, and C++ its generators too, protoc and gRPC's plugin |

## meta-yoke:the-c-and-cpp-recipes.02 — the C recipe builds the library, and a development package for building against it

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §meta-yoke, and what its recipes do · prj_structure/40 E3 · prj_structure/40 E2 |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the build of `the-layer.04`, for `qemux86-64` and `qemuarm64` |
| **Action** | fetch `yoke-sdk-c`; build it with the network off; list what its packages hold |
| **Expected** | the library is in the static development package, as an archive of objects for the machine's architecture; the development package holds the public headers, the CMake configuration with its version and its targets, and the `pkg-config` file; and no package of the recipe holds a program |

## meta-yoke:the-c-and-cpp-recipes.03 — the C++ recipe builds the library, and a development package for building against it

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §meta-yoke, and what its recipes do · prj_structure/40 E3 · prj_structure/40 E2 |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the build of `the-layer.04`, for `qemux86-64` and `qemuarm64` |
| **Action** | fetch `yoke-sdk-cpp`; build it with the network off; list what its packages hold |
| **Expected** | the library is in the static development package, as an archive of objects for the machine's architecture; the development package holds the public headers, the CMake configuration with its version and its targets, and the `pkg-config` file; and no package of the recipe holds a program — the harnesses and the case programs are the repository's own build, not what a consumer installs |
