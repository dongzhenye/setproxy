#!/bin/bash
# 兼容入口：转发到新版 setproxy.sh（参数模型以 setproxy.sh 为准）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/setproxy.sh" "$@"
