#!/bin/bash
# 简单的功能测试脚本

echo "🧪 测试代理配置功能..."
echo ""

# 测试 source 命令
echo "1. 测试配置加载..."
if source configs/zshrc-proxy 2>/dev/null; then
    echo "   ✅ 配置文件加载成功"
else
    echo "   ❌ 配置文件加载失败"
    exit 1
fi

# 测试命令是否存在
echo ""
echo "2. 测试命令可用性..."
commands=("proxy-on" "proxy-off" "proxy-status" "proxy-test" "proxy_on" "proxy_off" "proxy_status" "proxy_test")
for cmd in "${commands[@]}"; do
    if type $cmd &>/dev/null; then
        echo "   ✅ $cmd 命令可用"
    else
        echo "   ❌ $cmd 命令不可用"
    fi
done

# 测试代理开关
echo ""
echo "3. 测试代理开关功能..."
proxy-off >/dev/null 2>&1
if [ -z "$HTTP_PROXY" ]; then
    echo "   ✅ proxy-off 正常工作"
else
    echo "   ❌ proxy-off 未能清除环境变量"
fi

proxy-on >/dev/null 2>&1
if [ "$HTTP_PROXY" = "http://127.0.0.1:7890" ]; then
    echo "   ✅ proxy-on 正常工作"
else
    echo "   ❌ proxy-on 未能设置环境变量"
fi

echo ""
echo "✨ 基础功能测试完成！"