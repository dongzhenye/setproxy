#!/bin/bash
# 一键配置终端代理
# 使用方法: source setup-proxy.sh

echo "🚀 开始配置macOS终端代理..."
echo ""

# 项目目录（setup-proxy.sh现在在根目录）
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📁 项目目录: $PROJECT_DIR"
echo ""

# 1. 设置当前会话的环境变量
echo "1️⃣ 设置环境变量..."
# 内置 proxy-on.sh 的逻辑
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

# 2. 配置 zsh
echo "2️⃣ 配置 zsh..."
ZSHRC_FILE="$HOME/.zshrc"
PROXY_MARKER="# === macOS 终端代理配置 ==="

# 检查是否已经配置过
if ! grep -q "$PROXY_MARKER" "$ZSHRC_FILE" 2>/dev/null; then
    echo "正在添加到 ~/.zshrc..."
    {
        echo ""
        echo "$PROXY_MARKER"
        cat "$PROJECT_DIR/configs/zshrc-proxy"
        echo "$PROXY_MARKER"
    } >> "$ZSHRC_FILE"
    echo "✅ zsh配置已添加"
else
    echo "ℹ️  zsh配置已存在，跳过"
fi
echo ""

# 3. 配置 Git 代理
echo "3️⃣ 配置 Git 代理..."
bash "$PROJECT_DIR/configs/gitconfig-proxy" on
echo ""

# 4. 检查 npm 代理
echo "4️⃣ 检查 npm 代理..."
if command -v npm > /dev/null; then
    current_proxy=$(npm config get proxy 2>/dev/null)
    if [ "$current_proxy" = "http://127.0.0.1:7890" ]; then
        echo "ℹ️  npm代理已正确配置，跳过"
    else
        bash "$PROJECT_DIR/configs/npmrc-proxy" on
    fi
else
    echo "⚠️  npm未安装，跳过npm代理配置"
fi
echo ""

# 5. 配置 pip 代理
echo "5️⃣ 配置 pip 代理..."
if command -v pip > /dev/null || command -v pip3 > /dev/null; then
    bash "$PROJECT_DIR/configs/pip-proxy" on
else
    echo "⚠️  pip未安装，跳过pip代理配置"
fi
echo ""

# 6. 设置脚本可执行权限
echo "6️⃣ 设置脚本权限..."
chmod +x "$PROJECT_DIR/configs/"*
echo "✅ 脚本权限已设置"
echo ""

# 7. 运行代理检查
echo "7️⃣ 运行代理检查..."
# 内置 check-proxy.sh 的逻辑
echo "🔍 代理连接检查"
echo "=================="

# 检查环境变量
echo "📋 环境变量状态:"
echo "  HTTP_PROXY: ${HTTP_PROXY:-未设置}"
echo "  HTTPS_PROXY: ${HTTPS_PROXY:-未设置}"
echo "  ALL_PROXY: ${ALL_PROXY:-未设置}"
echo ""

# 检查代理端口
echo "🔌 代理端口检查:"
if lsof -i :7890 > /dev/null 2>&1; then
    echo "  ✅ 端口7890正在监听 (Clash正在运行)"
else
    echo "  ❌ 端口7890未监听 (请检查Clash是否运行)"
fi
echo ""

# 检查公网IP地址
echo "📍 公网IP检测:"
if command -v curl > /dev/null; then
    # 尝试获取IP信息
    ip_info=$(curl -s --connect-timeout 5 --max-time 10 https://ipinfo.io 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$ip_info" ]; then
        ip=$(echo "$ip_info" | grep -o '"ip": *"[^"]*"' | cut -d'"' -f4)
        country=$(echo "$ip_info" | grep -o '"country": *"[^"]*"' | cut -d'"' -f4)
        city=$(echo "$ip_info" | grep -o '"city": *"[^"]*"' | cut -d'"' -f4)
        echo "  IP地址: $ip"
        echo "  位置: $city, $country"
    else
        # 备用方案
        ip=$(curl -s --connect-timeout 5 --max-time 10 https://ifconfig.me 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$ip" ]; then
            echo "  IP地址: $ip"
        else
            echo "  ⚠️  无法获取IP地址"
        fi
    fi
else
    echo "  ⚠️  curl命令不可用，跳过IP检测"
fi
echo ""

# 检查网络连接
echo "🌐 网络连接测试:"
if command -v curl > /dev/null; then
    echo -n "  Google: "
    if curl -s -I --connect-timeout 5 --max-time 10 https://google.com > /dev/null 2>&1; then
        echo "✅ 连接成功"
    else
        echo "❌ 连接失败"
    fi
    
    echo -n "  GitHub: "
    if curl -s -I --connect-timeout 5 --max-time 10 https://github.com > /dev/null 2>&1; then
        echo "✅ 连接成功"
    else
        echo "❌ 连接失败"
    fi
    
    echo -n "  YouTube: "
    if curl -s -I --connect-timeout 5 --max-time 10 https://youtube.com > /dev/null 2>&1; then
        echo "✅ 连接成功 (代理工作正常)"
    else
        echo "❌ 连接失败"
    fi
else
    echo "  ⚠️  curl命令不可用，跳过网络测试"
fi
echo ""

# 检查工具配置
echo "🔧 工具配置检查:"

# Git代理检查
if command -v git > /dev/null; then
    git_http_proxy=$(git config --global http.proxy 2>/dev/null)
    git_https_proxy=$(git config --global https.proxy 2>/dev/null)
    if [ "$git_http_proxy" = "http://127.0.0.1:7890" ] && [ "$git_https_proxy" = "http://127.0.0.1:7890" ]; then
        echo "  ✅ Git代理配置正确"
    else
        echo "  ❌ Git代理配置异常"
    fi
else
    echo "  ⚠️  Git未安装"
fi

# npm代理检查
if command -v npm > /dev/null; then
    npm_proxy=$(npm config get proxy 2>/dev/null)
    if [ "$npm_proxy" = "http://127.0.0.1:7890" ]; then
        echo "  ✅ npm代理配置正确"
    else
        echo "  ❌ npm代理配置异常"
    fi
else
    echo "  ⚠️  npm未安装"
fi

echo ""
echo "🎉 代理配置完成！"
echo ""
echo "📝 使用说明:"
echo "  开启代理: proxy-on"
echo "  关闭代理: proxy-off"
echo "  检查状态: proxy-status"
echo "  测试连接: proxy-test"
echo ""
echo "💡 提示: 重启终端或执行 'source ~/.zshrc' 以使用别名命令" 