#!/bin/bash
# 开启代理环境变量
# 使用方法: source scripts/proxy-on.sh

# 代理服务器配置
PROXY_HOST="127.0.0.1"
PROXY_PORT="7890"
PROXY_URL="http://${PROXY_HOST}:${PROXY_PORT}"

# 设置环境变量
export HTTP_PROXY="${PROXY_URL}"
export HTTPS_PROXY="${PROXY_URL}"
export ALL_PROXY="${PROXY_URL}"
export http_proxy="${PROXY_URL}"
export https_proxy="${PROXY_URL}"
export all_proxy="${PROXY_URL}"

# 设置不代理的地址
export NO_PROXY="localhost,127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,100.64.0.0/10,17.0.0.0/8,169.254.0.0/16,224.0.0.0/4,240.0.0.0/4"
export no_proxy="${NO_PROXY}"

echo "✅ 代理已开启"
echo "HTTP_PROXY: ${HTTP_PROXY}"
echo "HTTPS_PROXY: ${HTTPS_PROXY}"
echo "ALL_PROXY: ${ALL_PROXY}"
echo ""
echo "测试命令: curl -I https://google.com" 