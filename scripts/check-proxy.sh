#!/bin/bash
# 检查代理状态
# 使用方法: ./scripts/check-proxy.sh

echo "================================"
echo "🔍 代理状态检查"
echo "================================"

# 检查环境变量
echo "📋 环境变量:"
echo "HTTP_PROXY: ${HTTP_PROXY:-未设置}"
echo "HTTPS_PROXY: ${HTTPS_PROXY:-未设置}"
echo "ALL_PROXY: ${ALL_PROXY:-未设置}"
echo "NO_PROXY: ${NO_PROXY:-未设置}"
echo ""

# 检查系统代理设置
echo "🖥️ 系统代理设置:"
scutil --proxy | grep -E "(HTTPEnable|HTTPProxy|HTTPPort|HTTPSEnable|HTTPSProxy|HTTPSPort)"
echo ""

# 检查git代理配置
echo "🔧 Git代理配置:"
echo "HTTP代理: $(git config --global --get http.proxy || echo '未设置')"
echo "HTTPS代理: $(git config --global --get https.proxy || echo '未设置')"
echo ""

# 检查npm代理配置
echo "📦 npm代理配置:"
echo "HTTP代理: $(npm config get proxy || echo '未设置')"
echo "HTTPS代理: $(npm config get https-proxy || echo '未设置')"
echo ""

# 检查代理连接
echo "🌐 代理连接测试:"
if command -v curl > /dev/null; then
    echo "测试Google连接..."
    if curl -I --connect-timeout 5 https://google.com 2>/dev/null | head -1; then
        echo "✅ 连接成功"
    else
        echo "❌ 连接失败"
    fi
else
    echo "curl命令不可用，跳过连接测试"
fi

echo ""
echo "================================" 