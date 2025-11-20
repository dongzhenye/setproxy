#!/bin/bash
# 通用函数和配置（被各工具脚本复用）
set -euo pipefail

extract_port_from_url() {
  local url="$1"
  python3 - "$url" <<'PY'
import sys, urllib.parse
url = sys.argv[1]
try:
    parsed = urllib.parse.urlsplit(url if "://" in url else "http://" + url)
    if parsed.port:
        print(parsed.port)
except Exception:
    pass
PY
}

# 获取代理端口（优先读取当前会话）
get_proxy_port() {
  local port="7890"  # 默认端口

  # 优先：显式端口（CI/命令行兼容）
  if [ -n "${SETPROXY_PORT:-}" ]; then
    port="$SETPROXY_PORT"
  # 其次：当前会话已设置的 PROXY_URL（如 setproxy --port）
  elif [ -n "${PROXY_URL:-}" ]; then
    local parsed_port
    parsed_port="$(extract_port_from_url "$PROXY_URL" || true)"
    [ -n "$parsed_port" ] && port="$parsed_port"
  # 再次：用户配置文件
  elif [ -f "$HOME/.setproxy/proxy.conf" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.setproxy/proxy.conf"
    [ -n "${PROXY_PORT:-}" ] && port="$PROXY_PORT"
  # 最后：项目默认配置
  elif [ -f "$(dirname "${BASH_SOURCE[0]}")/proxy.conf" ]; then
    # shellcheck source=/dev/null
    source "$(dirname "${BASH_SOURCE[0]}")/proxy.conf"
    [ -n "${PROXY_PORT:-}" ] && port="$PROXY_PORT"
  fi

  echo "$port"
}

# 获取代理URL（优先使用当前会话已有值）
get_proxy_url() {
  if [ -n "${PROXY_URL:-}" ]; then
    echo "$PROXY_URL"
  else
    echo "http://127.0.0.1:$(get_proxy_port)"
  fi
}
