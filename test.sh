#!/bin/bash
# 简单自检（以 dry-run 为主，避免改动真实环境）
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "1) dry-run 开启代理（指定工具）"
bash "$ROOT/setproxy.sh" on --with git,npm,pip --port 7890 --dry-run

echo "2) dry-run 关闭代理（全工具）"
bash "$ROOT/setproxy.sh" off --all --force --dry-run

echo "3) 状态查看"
bash "$ROOT/setproxy.sh" status || true

echo "4) 测试命令（不阻塞，即便失败也继续）"
set +e
bash "$ROOT/setproxy.sh" test || true
set -e

echo "✅ 自检脚本完成"
