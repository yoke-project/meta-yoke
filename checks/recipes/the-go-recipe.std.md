# The Go recipe

| | |
| --- | --- |
| **Feature** | the Go family has a recipe that builds the family's harnesses from the module it publishes, `github.com/yoke-project/yoke-sdk-go`, with the Yocto series' Go and with every module they depend on pinned module by module, offline once fetched: it shows the module builds alone, in a package for a workstation, and installs nothing on a device |
| **Planning item** | yoke-project/meta-yoke#22 |

## meta-yoke:the-go-recipe.01 — the recipe pins the module its family published, and every dependency by its checksum

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §What a recipe pins, and what offline means · prj_structure/40 E2 |
| **Level** | L1 |
| **Method** | check |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a clean checkout |
| **Action** | read the recipe of `yoke-sdk-go`, the module list it requires and the licence list it requires |
| **Expected** | the recipe's own source is the module `github.com/yoke-project/yoke-sdk-go` at its version, as the Go proxy serves it, with a `sha256sum`; it builds with Go's class; every other source is a module named in the module list, each with a `sha256sum` of its own; the licence list names a licence file of every module the harnesses are built from; and nothing is fetched from anywhere else |

## meta-yoke:the-go-recipe.02 — the Go recipe builds the harnesses, for a workstation

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §meta-yoke, and what its recipes do · prj_structure/40 E3 · prj_structure/40 E2 |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the build of `the-layer.04`, for `qemux86-64` and `qemuarm64` |
| **Action** | fetch `yoke-sdk-go`; build it with the network off; list what its packages hold, and what the image holds |
| **Expected** | the package `yoke-sdk-go` holds the plugin, interface and administrative harnesses, `yoke-go-plugin-harness`, `yoke-go-interface-harness` and `yoke-go-admin-harness`, as programs for the machine's architecture; no package of the recipe holds a library or a header; and the image holds no package of the recipe |
