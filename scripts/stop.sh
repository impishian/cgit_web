pidfile=/tmp/mini_httpd.pid

if [[ -f "$pidfile" ]]; then
  kill "$(cat "$pidfile")" 2>/dev/null || true
  rm -f "$pidfile"
else
  pkill mini_httpd || true
fi
