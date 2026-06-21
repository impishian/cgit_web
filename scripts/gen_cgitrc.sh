#!/bin/sh
set -eu

ROOT="${1:-$HOME/github}"
OWNER="${USER:-$(id -un)}"

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
ROOT_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"

cat <<EOF
css=/assets/cgit.css
logo=/assets/cgit.png
js=/assets/cgit.js
virtual-root=/cgit.cgi/

root-title=Local Repos
root-desc=Repos on this machine

head-include=$ROOT_DIR/config/head-include.html
source-filter=$ROOT_DIR/filters/syntax-highlighting.py
about-filter=$ROOT_DIR/filters/about-formatting.sh
#email-filter=lua:$ROOT_DIR/filters/email-gravatar.lua
#auth-filter=lua:$ROOT_DIR/filters/simple-authentication.lua

enable-remote-branches=1

enable-filter-overrides=1
enable-follow-links=1
enable-html-serving=1
enable-subject-links=1
enable-tree-linenumbers=1
side-by-side-diffs=1
local-time=1
noplainemail=1

enable-index-owner=1
enable-index-links=1
enable-commit-graph=1
enable-blame=1
enable-log-filecount=1
enable-log-linecount=1
enable-http-clone=0

readme=:README.md
readme=:README

cache-root=/tmp/cgit
cache-size=128
cache-dynamic-ttl=5
cache-repo-ttl=5
cache-root-ttl=5
cache-scanrc-ttl=15
cache-static-ttl=-1
cache-snapshot-ttl=5
EOF

find "$ROOT" -mindepth 2 -maxdepth 3 -type d -name .git | sort | while IFS= read -r gitdir; do
  worktree="$(dirname "$gitdir")"
  name="$(basename "$worktree")"

  cat <<EOF
repo.url=$name
repo.path=$gitdir
repo.desc=$name
repo.owner=$OWNER

EOF
done
