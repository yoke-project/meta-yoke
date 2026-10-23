# yoke's recipe

| | |
| --- | --- |
| **Feature** | `yoke`'s recipe builds a release from its source archive and the archive of its module dependencies, each pinned by the digest the release manifest carries, with the network off and no C, into one package per artifact: the runtime (the Core, the manager, the guardian, the authentication program), the tooling (the composer, the conformance suite) and the packaging inputs; the verification tool in none |
| **Planning item** | yoke-project/meta-yoke#18 |

## meta-yoke:the-yoke-recipe.01 — the recipe pins what the release published, and fetches nothing else

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §What a recipe pins, and what offline means · prj_structure/40 E2 |
| **Level** | L1 |
| **Method** | check |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | a clean checkout |
| **Action** | read the recipe of `yoke` |
| **Expected** | its sources are the release's source archive and modules archive, at the release's download path for its version, each with a `sha256sum`, and nothing else; it builds with `CGO_ENABLED` 0, the module dependencies from `vendor/` and the module proxy off |

## meta-yoke:the-yoke-recipe.02 — the recipe builds offline into one package per artifact

| Field | Value |
| --- | --- |
| **Cites** | prj_structure/97 §meta-yoke, and what its recipes do · prj_structure/40 E3 · prj_structure/40 E2 |
| **Level** | L5 |
| **Method** | test |
| **Not applicable in** | — |
| **Label** | blocking |
| **Precondition** | the build of `the-layer.04`, for `qemux86-64` and `qemuarm64` |
| **Action** | fetch `yoke`; build it with the network off; list what each of its packages holds |
| **Expected** | `yoke-core`, `yoke`, `yoke-guardian` and `yoke-auth` each hold the one program they are named after, and `yoke-compose` and `yoke-conformance` theirs; `yoke-packaging` holds the systemd unit, the tmpfiles and sysusers files and `/etc/yoke/core.yaml`; each program is statically linked for the machine's architecture; and no package holds `yoke-verify` |
