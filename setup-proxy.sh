#!/bin/bash
# 一键配置终端代理
# 使用方法: source setup-proxy.sh

echo "🚀 开始配置macOS终端代理..."
echo ""

# 项目目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📁 项目目录: $PROJECT_DIR"
echo ""

# 1. 配置 zsh
echo "1️⃣ 配置 zsh..."
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

# 2. 配置 Git 代理
echo "2️⃣ 配置 Git 代理..."
if command -v git > /dev/null; then
    bash "$PROJECT_DIR/configs/gitconfig-proxy" on
else
    echo "⚠️  Git未安装，跳过Git代理配置"
fi
echo ""

# 3. 配置 npm 代理
echo "3️⃣ 配置 npm 代理..."
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

# 4. 配置 pip 代理
echo "4️⃣ 配置 pip 代理..."
if command -v pip > /dev/null || command -v pip3 > /dev/null; then
    bash "$PROJECT_DIR/configs/pip-proxy" on
else
    echo "⚠️  pip未安装，跳过pip代理配置"
fi
echo ""

# 5. 设置脚本可执行权限
echo "5️⃣ 设置脚本权限..."
chmod +x "$PROJECT_DIR/configs/"*
echo "✅ 脚本权限已设置"
echo ""

# 6. 加载配置并运行检查
echo "6️⃣ 加载配置并测试..."
echo ""

# 加载 zshrc 配置（包含所有代理命令）
source "$PROJECT_DIR/configs/zshrc-proxy"

# 开启代理（当前会话）
proxy-on
echo ""

# 运行完整的代理测试
proxy-test

echo ""
echo "🎉 代理配置完成！"
echo ""
echo "📝 使用说明:"
echo "  开启代理: proxy-on 或 proxy_on"
echo "  关闭代理: proxy-off 或 proxy_off"
echo "  检查状态: proxy-status 或 proxy_status"
echo "  测试连接: proxy-test 或 proxy_test"
echo ""
echo "💡 提示: 重启终端或执行 'source ~/.zshrc' 以在新会话中使用"