#!/bin/bash
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

# Allow an explicit override, but default to the config in this site's config dir.
CGIT_CONFIG_PATH="${CGIT_CONFIG:-$SCRIPT_DIR/config/cgitrc}"
CGIT_REAL="$SCRIPT_DIR/bin/cgit.real"

if [ ! -r "$CGIT_CONFIG_PATH" ]; then
  printf 'Status: 500 Internal Server Error\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\ncgit config not found or not readable: %s\n' "$CGIT_CONFIG_PATH"
  exit 0
fi

if [ ! -x "$CGIT_REAL" ]; then
  printf 'Status: 500 Internal Server Error\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\ncgit binary not found or not executable: %s\n' "$CGIT_REAL"
  exit 0
fi

export CGIT_CONFIG="$CGIT_CONFIG_PATH"

# Keep the standard system path first so git stays available even under a stripped CGI env.
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin${PATH:+:$PATH}"

exec "$CGIT_REAL"
