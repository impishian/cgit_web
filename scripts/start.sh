#!/bin/bash

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
ROOT_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

current_user="$(id -un 2>/dev/null || printf '%s' "${USER:-}")"
template_conf="$(mktemp "${TMPDIR:-/tmp}/mini_httpd.XXXXXX.conf")"

prepare_cgit_cache() {
  local cache_root cache_size i slot entry name

  cache_root="$(awk -F= '$1 == "cache-root" { print $2; exit }' "$ROOT_DIR/config/cgitrc")"
  cache_size="$(awk -F= '$1 == "cache-size" { print $2; exit }' "$ROOT_DIR/config/cgitrc")"

  if [[ -z "$cache_root" || -z "$cache_size" || "$cache_size" -le 0 ]]; then
    return
  fi

  mkdir -p "$cache_root"
  i=0
  while [[ "$i" -lt "$cache_size" ]]; do
    printf -v slot '%08x' "$i"
    mkdir -p "$cache_root/$slot"
    i=$((i + 1))
  done

  for entry in "$cache_root"/[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]; do
    [[ -d "$entry" ]] || continue
    name="${entry##*/}"
    if (( 16#$name >= cache_size )); then
      rm -rf "$entry"
    fi
  done
}

prepare_cgit_cache

"$SCRIPT_DIR/stop.sh"

sed \
  -e "s#__ROOT_DIR__#$ROOT_DIR#g" \
  -e "s#__RUN_USER__#$current_user#g" \
  "$ROOT_DIR/config/mini_httpd.conf" > "$template_conf"

trap 'rm -f "$template_conf"' EXIT

perl -MPOSIX=setsid -e '
  defined(my $pid = fork) or die "fork1: $!";
  exit if $pid;
  setsid() or die "setsid: $!";
  defined($pid = fork) or die "fork2: $!";
  exit if $pid;
  open STDIN, "<", "/dev/null" or die "stdin: $!";
  open STDOUT, ">", "/dev/null" or die "stdout: $!";
  open STDERR, ">>", "/tmp/mini_httpd.err" or die "stderr: $!";
  exec @ARGV or die "exec: $!";
' "$ROOT_DIR/bin/mini_httpd" -C "$template_conf" -D

sleep 1
