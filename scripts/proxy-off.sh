#!/bin/bash
# 关闭代理环境变量
# 使用方法: source scripts/proxy-off.sh

# 清除环境变量
unset HTTP_PROXY
unset HTTPS_PROXY
unset ALL_PROXY
unset http_proxy
unset https_proxy
unset all_proxy
unset NO_PROXY
unset no_proxy

echo "🔴 代理已关闭"
echo "所有代理环境变量已清除" 