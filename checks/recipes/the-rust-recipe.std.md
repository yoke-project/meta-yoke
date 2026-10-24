# The Rust recipe

| | |
| --- | --- |
| **Feature** | the Rust family has a recipe that builds the crate it publishes, `yoke-sdk`, with the Yocto series' Rust and with every dependency its lock names pinned crate by crate, offline once fetched: the library, in a development package; the family installs nothing on a device |
| **Planning item** | yoke-project/meta-yoke#20 |

## meta-yoke:the-rust-recipe.01 — the recipe pins the crate its family published, and every dependency by its checksum

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §What a recipe pins, and what offline means · prj_structure/40 E2 |
| **Level** | L1 |
| **Method** | check |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a clean checkout |
| **Action** | read the recipe of `yoke-sdk-rust` and the crate list it requires |
| **Expected** | the recipe's own source is the crate `yoke-sdk` at its version on crates.io, with a `sha256sum`; it builds with Cargo's class; every other source is a crate on crates.io, named in the crate list, each with a `sha256sum` of its own; and nothing is fetched from anywhere else |

## meta-yoke:the-rust-recipe.02 — the Rust recipe builds the library, in a development package

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §meta-yoke, and what its recipes do · prj_structure/40 E3 · prj_structure/40 E2 |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the build of `the-layer.04`, for `qemux86-64` and `qemuarm64` |
| **Action** | fetch `yoke-sdk-rust`; build it with the network off; list what its packages hold |
| **Expected** | the development package holds the crate's library, `libyoke_sdk-*.rlib`, under the Rust library directory, with objects for the machine's architecture; and no package of the recipe holds a program — a device takes nothing from the family |
