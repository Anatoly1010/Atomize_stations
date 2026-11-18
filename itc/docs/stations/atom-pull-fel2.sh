#!/bin/bash
# atom-pull: update Atomize, Atomize_treatment and Atomize_stations on the ITC PC (fel2).
#
#   atom-pull            from GitHub (connect the PC to the internet first)
#   atom-pull bundles    offline: from the bundles in ~/sources/bundles
#   atom-pull <folder>   offline: from the bundles in another folder (a USB stick)

SRC=${ATOM_SRC:-~/sources}
PY=${ATOM_PY:-$SRC/atomize_venv/bin/python}
WHEELS=$SRC/wheels
FROM=${1:-github}
[ "$FROM" = bundles ] && FROM=$SRC/bundles
PIP="$PY -m pip install --no-index --find-links $WHEELS -e"

# repo  branch  folder to install  pyproject.toml to watch
REPOS=(
    "Atomize            master  Atomize                  pyproject.toml"
    "Atomize_treatment  main    Atomize_treatment        pyproject.toml"
    "Atomize_stations   main    Atomize_stations/itc     itc/pyproject.toml"
)

if [ "$FROM" != github ] && [ ! -d "$FROM" ]; then
    echo "atom-pull: no folder $FROM"; exit 1
fi
if pgrep -f 'atomize-itc|atomize\.main|atomize\.treatment|control_center|epr-auto' >/dev/null; then
    echo "atom-pull: Atomize or a protocol is running; close it first."; exit 1
fi
if [ -f "$FROM/SHA256SUMS" ]; then
    (cd "$FROM" && sha256sum --quiet -c SHA256SUMS) || { echo "atom-pull: bundle checksums do not match"; exit 1; }
fi

failed=0
for line in "${REPOS[@]}"; do
    read -r repo branch install toml <<< "$line"
    dir=$SRC/$repo
    if [ "$FROM" = github ]; then
        source=origin
    else
        source=$FROM/$repo.bundle
        [ -f "$source" ] || { echo "== $repo: no bundle, skipped"; continue; }
    fi
    echo "== $repo"
    if [ ! -d "$dir" ]; then
        if [ "$FROM" = github ]; then
            git clone -q -b "$branch" "https://github.com/Anatoly1010/$repo.git" "$dir" || { failed=1; continue; }
        else
            git clone -q -b "$branch" "$source" "$dir" || { failed=1; continue; }
            git -C "$dir" remote set-url origin "https://github.com/Anatoly1010/$repo.git"
        fi
        old=none
    else
        old=$(git -C "$dir" rev-parse HEAD)
        git -C "$dir" fetch -q "$source" "+$branch:refs/remotes/origin/$branch" || { failed=1; continue; }
        if [ "$(git -C "$dir" rev-parse --abbrev-ref HEAD)" != "$branch" ]; then
            echo "   not on $branch, not updated"; failed=1; continue
        fi
        if ! out=$(git -C "$dir" merge -q --ff-only "origin/$branch" 2>&1); then
            echo "   not updated:"; echo "$out" | sed 's/^/   /'
            failed=1; continue
        fi
    fi
    new=$(git -C "$dir" rev-parse HEAD)
    edits=$(git -C "$dir" status --short --untracked-files=no)
    if [ "$old" = "$new" ]; then
        echo "   up to date at $(git -C "$dir" log --oneline -1)"
    else
        [ "$old" != none ] && git -C "$dir" log --oneline "$old..$new" | sed 's/^/   /'
        if [ "$old" = none ] || ! git -C "$dir" diff --quiet "$old" "$new" -- "$toml"; then
            [ "$old" = none ] && echo "   new: installing" || echo "   $toml changed: reinstalling"
            $PIP "$SRC/$install" 2>&1 | grep -E 'Successfully|ERROR' | sed 's/^/   /'
            [ "${PIPESTATUS[0]}" -eq 0 ] || failed=1
        fi
    fi
    [ -n "$edits" ] && { echo "   local edits kept:"; echo "$edits" | sed 's/^/   /'; }
done

echo "== installed"
$PY -m pip list 2>/dev/null | grep -i '^atomize'
[ $failed -eq 0 ] && echo "atom-pull: done" || { echo "atom-pull: some repos were not updated (see above)"; exit 1; }
