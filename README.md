# meta-yoke

## What it is

The Yocto Project layer for Yoke: the recipes that build Yoke's programs and libraries into an
embedded Linux image with BitBake, each from the source archive of a release, pinned by its checksum.

It holds no recipe yet. It is not where Yoke is built for development: each repository builds itself
with its own verbs, and this layer only describes how an image integrator builds what was released.

## What is where

| Path | What it holds |
| --- | --- |
| `checks/`, `ci/` | This repository's own checks, and the scripts continuous integration runs |

The recipes will sit under `recipes-*/` directories, as the Yocto Project lays a layer out.

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

## Where the depth is

The documentation at [docs.yoke-project.dev](https://docs.yoke-project.dev/): the
[reference](https://docs.yoke-project.dev/reference/) for what the programs are, and the
[contributors' section](https://docs.yoke-project.dev/contributing/) for how the work is done.

## Licence

MIT, in [`LICENSE`](LICENSE), as Yocto Project layers carry.
