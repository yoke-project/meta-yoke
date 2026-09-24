# The six verbs every repository defines.
# A verb with nothing to do says so in one line, so a fan-out can tell a gap from a statement.

# Build this repository's codebase.
build:
    @echo "build: nothing to build in meta-yoke yet"

# Run this repository's own checks, with no sibling present.
test:
    #!/usr/bin/env bash
    # A run leaves its results where the record writer reads them, whatever it decided.
    set -uo pipefail
    mkdir -p .results
    date -u +%Y-%m-%dT%H:%M:%SZ > .results/started
    status=0
    bash checks/run.sh | tee .results/checks.txt || status=1
    date -u +%Y-%m-%dT%H:%M:%SZ > .results/finished
    exit "$status"

# This repository's static checks.
lint:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    bash -n checks/run.sh checks/*/*.sh ci/*.sh
    echo "lint: every shell script parses"

# This repository has nothing a formatter reads yet; the verb says so.
fmt:
    @echo "fmt: nothing to format in meta-yoke yet"

# Verify the toolchain against the floor the workspace's fan-out passes.
develop floor="":
    #!/usr/bin/env bash
    set -euo pipefail
    found="$(just --version | awk '{print $2}')"
    if [[ -z "{{floor}}" ]]; then
        echo "develop: no floor given, so none verified — the workspace passes it; found just $found"
        exit 0
    fi
    if ! [[ "{{floor}}" =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
        echo "develop: '{{floor}}' is not a version; pass it as \`just develop 1.58.0\`"
        exit 1
    fi
    lowest="$(printf '%s\n%s\n' "{{floor}}" "$found" | sort -V | head -n 1)"
    if [[ "$lowest" != "{{floor}}" ]]; then
        echo "develop: just {{floor}} or newer is needed; found just $found"
        exit 1
    fi
    echo "develop: just $found meets the floor {{floor}}"

# Publish into this repository's ecosystem, one manifest line per publication.
release:
    @echo "release: nothing to publish from meta-yoke yet"
