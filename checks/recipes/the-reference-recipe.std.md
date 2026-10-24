# The reference recipe

| | |
| --- | --- |
| **Feature** | `yoke-reference` has a recipe that builds, from a commit of its repository, the example application's units that run on the host — `acquire`, the `instrument` that plays its spectrometer, the LVGL panel — and the Go clock, with every module they depend on pinned by its checksum, offline once fetched: the panel against the C family's library and the LVGL the image provides, with its framebuffer driver; each program in a package of its own |
| **Planning item** | yoke-project/meta-yoke#23 |

## meta-yoke:the-reference-recipe.01 — the recipe pins a commit of the repository, and every dependency by its checksum

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §What a recipe pins, and what offline means · prj_structure/40 E2 |
| **Level** | L1 |
| **Method** | check |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a clean checkout |
| **Action** | read the recipe of `yoke-reference`, the module list and the licence list it requires, and what the layer appends to LVGL's recipe |
| **Expected** | the recipe's own source is the repository `yoke-project/yoke-reference` by git, on `main`, at a full commit; every other source is a module named in the module list, each with a `sha256sum`; the licence list names a licence file of every module; the recipe takes the C family and LVGL from the layers; and the layer asks LVGL for its Linux framebuffer driver |

## meta-yoke:the-reference-recipe.02 — the reference recipe builds the example's host units and the clock, each in a package

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §meta-yoke, and what its recipes do · prj_structure/40 E3 · prj_structure/40 E2 |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the build of `the-layer.04`, for `qemux86-64` and `qemuarm64` |
| **Action** | fetch `yoke-reference`; build it with the network off; list what its packages hold |
| **Expected** | `yoke-reference-acquire`, `yoke-reference-instrument`, `yoke-reference-clock` and `yoke-reference-panel` each hold their program under `/usr/libexec/yoke-reference/`, built for the machine's architecture; `acquire`'s package also holds its Manifest; the panel links LVGL's shared library, which the image's LVGL package provides |
