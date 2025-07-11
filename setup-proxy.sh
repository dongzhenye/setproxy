#!/bin/bash
# 一键配置终端代理
# 使用方法: source setup-proxy.sh [options]
# 环境变量: PROXY_PORT=8080 source setup-proxy.sh

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载或创建配置文件
CONFIG_FILE="$PROJECT_DIR/configs/proxy.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    # 创建默认配置
    echo "# setproxy 配置文件" > "$CONFIG_FILE"
    echo "# 默认代理端口（如需修改请编辑此文件）" >> "$CONFIG_FILE"
    echo "PROXY_PORT=7890" >> "$CONFIG_FILE"
    PROXY_PORT=7890
fi

# 允许环境变量覆盖配置文件
if [ -n "$SETPROXY_PORT" ]; then
    PROXY_PORT="$SETPROXY_PORT"
    echo "使用自定义端口: $PROXY_PORT"
fi

# 显示帮助信息
show_help() {
    echo "使用方法: source setup-proxy.sh [选项]"
    echo ""
    echo "选项:"
    echo "  --minimal    仅安装核心功能（proxy命令）"
    echo "  --with-git   包含Git代理配置"
    echo "  --with-npm   包含npm代理配置"
    echo "  --with-pip   包含pip代理配置"
    echo "  --with-go    包含Go代理配置"
    echo "  --with-docker 包含Docker代理配置"
    echo "  --with-cargo 包含Rust/Cargo代理配置"
    echo "  --recommended 安装推荐配置（核心+Git+npm+pip）"
    echo "  --all        安装所有配置"
    echo "  --help       显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  source setup-proxy.sh --recommended          # 推荐配置（核心+Git+npm+pip）"
    echo "  source setup-proxy.sh --minimal              # 最小配置（仅核心）"
    echo "  source setup-proxy.sh --with-git --with-npm  # 自定义组合"
    echo "  source setup-proxy.sh --all                  # 安装所有"
    return 0
}

# 解析参数
# 默认推荐配置
INSTALL_GIT=true
INSTALL_NPM=true
INSTALL_PIP=true
INSTALL_GO=false
INSTALL_DOCKER=false
INSTALL_CARGO=false

# 检查是否有参数（除了--help）
HAS_ARGS=false
for arg in "$@"; do
    if [[ "$arg" != "--help" ]]; then
        HAS_ARGS=true
        break
    fi
done

# 如果有参数，则默认不安装任何额外组件
if [[ "$HAS_ARGS" == "true" ]]; then
    INSTALL_GIT=false
    INSTALL_NPM=false
    INSTALL_PIP=false
    INSTALL_GO=false
    INSTALL_DOCKER=false
    INSTALL_CARGO=false
fi

for arg in "$@"; do
    case $arg in
        --minimal)
            # 保持所有为false
            ;;
        --with-git)
            INSTALL_GIT=true
            ;;
        --with-npm)
            INSTALL_NPM=true
            ;;
        --with-pip)
            INSTALL_PIP=true
            ;;
        --with-go)
            INSTALL_GO=true
            ;;
        --with-docker)
            INSTALL_DOCKER=true
            ;;
        --with-cargo)
            INSTALL_CARGO=true
            ;;
        --recommended)
            INSTALL_GIT=true
            INSTALL_NPM=true
            INSTALL_PIP=true
            INSTALL_GO=false
            INSTALL_DOCKER=false
            INSTALL_CARGO=false
            ;;
        --all)
            INSTALL_GIT=true
            INSTALL_NPM=true
            INSTALL_PIP=true
            INSTALL_GO=true
            INSTALL_DOCKER=true
            INSTALL_CARGO=true
            ;;
        --help)
            show_help
            return 0
            ;;
    esac
done

echo "🚀 开始配置macOS终端代理..."
echo ""

echo "📁 项目目录: $PROJECT_DIR"
echo "🔧 代理端口: $PROXY_PORT"
echo ""

# 显示安装计划
echo "📋 安装计划:"
echo "  ✅ 核心功能 (proxy命令)"
[[ "$INSTALL_GIT" == "true" ]] && echo "  ✅ Git 代理配置" || echo "  ⏭️  Git 代理配置 (跳过)"
[[ "$INSTALL_NPM" == "true" ]] && echo "  ✅ npm 代理配置" || echo "  ⏭️  npm 代理配置 (跳过)"
[[ "$INSTALL_PIP" == "true" ]] && echo "  ✅ pip 代理配置" || echo "  ⏭️  pip 代理配置 (跳过)"
[[ "$INSTALL_GO" == "true" ]] && echo "  ✅ Go 代理配置" || echo "  ⏭️  Go 代理配置 (跳过)"
[[ "$INSTALL_DOCKER" == "true" ]] && echo "  ✅ Docker 代理配置" || echo "  ⏭️  Docker 代理配置 (跳过)"
[[ "$INSTALL_CARGO" == "true" ]] && echo "  ✅ Cargo 代理配置" || echo "  ⏭️  Cargo 代理配置 (跳过)"
echo ""

# 询问确认（如果不是最小安装）
ANY_INSTALL=false
[[ "$INSTALL_GIT" == "true" || "$INSTALL_NPM" == "true" || "$INSTALL_PIP" == "true" || "$INSTALL_GO" == "true" || "$INSTALL_DOCKER" == "true" || "$INSTALL_CARGO" == "true" ]] && ANY_INSTALL=true

if [[ "$ANY_INSTALL" == "true" ]]; then
    echo -e "${YELLOW}是否继续？ (y/n)${NC} \c"
    read -n 1 confirm
    echo ""
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "已取消安装"
        return 1
    fi
fi
echo ""

# 1. 创建配置目录和文件
echo "1️⃣ 设置配置文件..."
SETPROXY_CONFIG_DIR="$HOME/.setproxy"
mkdir -p "$SETPROXY_CONFIG_DIR"

# 复制配置文件到用户目录
if [ ! -f "$SETPROXY_CONFIG_DIR/proxy.conf" ]; then
    cp "$CONFIG_FILE" "$SETPROXY_CONFIG_DIR/proxy.conf"
    echo "✅ 配置文件已创建: $SETPROXY_CONFIG_DIR/proxy.conf"
else
    # 更新端口设置
    if grep -q "PROXY_PORT=" "$SETPROXY_CONFIG_DIR/proxy.conf"; then
        sed -i '' "s/PROXY_PORT=.*/PROXY_PORT=$PROXY_PORT/" "$SETPROXY_CONFIG_DIR/proxy.conf"
    else
        echo "PROXY_PORT=$PROXY_PORT" >> "$SETPROXY_CONFIG_DIR/proxy.conf"
    fi
    echo "✅ 配置文件已更新"
fi

# 复制通用函数库到用户目录
if [ -f "$PROJECT_DIR/configs/common.sh" ]; then
    cp "$PROJECT_DIR/configs/common.sh" "$SETPROXY_CONFIG_DIR/common.sh"
    echo "✅ 通用函数库已复制: $SETPROXY_CONFIG_DIR/common.sh"
fi
echo ""

# 2. 配置 zsh（核心功能）
echo "2️⃣ 配置核心功能..."
ZSHRC_FILE="$HOME/.zshrc"
PROXY_MARKER="# === macOS 终端代理配置 ==="

if ! grep -q "$PROXY_MARKER" "$ZSHRC_FILE" 2>/dev/null; then
    echo "正在添加到 ~/.zshrc..."
    {
        echo ""
        echo "$PROXY_MARKER"
        cat "$PROJECT_DIR/configs/zshrc-proxy"
        echo "$PROXY_MARKER"
    } >> "$ZSHRC_FILE"
    echo "✅ 核心功能已配置"
else
    echo "ℹ️  核心功能已存在，跳过"
fi
echo ""

# 3. 配置 Git 代理（可选）
if [[ "$INSTALL_GIT" == "true" ]]; then
    echo "3️⃣ 配置 Git 代理..."
    if command -v git > /dev/null; then
        bash "$PROJECT_DIR/configs/gitconfig-proxy" on
    else
        echo "⚠️  Git未安装，跳过配置"
    fi
    echo ""
fi

# 3. 配置 npm 代理（可选）
if [[ "$INSTALL_NPM" == "true" ]]; then
    echo "4️⃣ 配置 npm 代理..."
    if command -v npm > /dev/null; then
        current_proxy=$(npm config get proxy 2>/dev/null)
        if [ "$current_proxy" = "http://127.0.0.1:7890" ]; then
            echo "ℹ️  npm代理已正确配置，跳过"
        else
            bash "$PROJECT_DIR/configs/npmrc-proxy" on
        fi
    else
        echo "⚠️  npm未安装，跳过配置"
    fi
    echo ""
fi

# 4. 配置 pip 代理（可选）
if [[ "$INSTALL_PIP" == "true" ]]; then
    echo "5️⃣ 配置 pip 代理..."
    if command -v pip > /dev/null || command -v pip3 > /dev/null; then
        bash "$PROJECT_DIR/configs/pip-proxy" on
    else
        echo "⚠️  pip未安装，跳过配置"
    fi
    echo ""
fi

# 5. 配置 Go 代理（可选）
if [[ "$INSTALL_GO" == "true" ]]; then
    echo "6️⃣ 配置 Go 代理..."
    if command -v go > /dev/null; then
        bash "$PROJECT_DIR/configs/go-proxy" on
    else
        echo "⚠️  Go未安装，跳过配置"
    fi
    echo ""
fi

# 6. 配置 Docker 代理（可选）
if [[ "$INSTALL_DOCKER" == "true" ]]; then
    echo "7️⃣ 配置 Docker 代理..."
    if command -v docker > /dev/null; then
        bash "$PROJECT_DIR/configs/docker-proxy" on
    else
        echo "⚠️  Docker未安装，跳过配置"
    fi
    echo ""
fi

# 7. 配置 Cargo 代理（可选）
if [[ "$INSTALL_CARGO" == "true" ]]; then
    echo "8️⃣ 配置 Cargo 代理..."
    if command -v cargo > /dev/null; then
        bash "$PROJECT_DIR/configs/cargo-proxy" on
    else
        echo "⚠️  Cargo未安装，跳过配置"
    fi
    echo ""
fi

# 8. 设置脚本可执行权限
echo "9️⃣ 设置脚本权限..."
chmod +x "$PROJECT_DIR/configs/"*
echo "✅ 脚本权限已设置"
echo ""

# 9. 加载配置并运行检查
echo "🔟 加载配置并测试..."
echo ""

# 加载 zshrc 配置
source "$PROJECT_DIR/configs/zshrc-proxy"

# 开启代理（当前会话）
proxy-on
echo ""

# 运行代理测试
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

# 显示额外配置提示
ANY_SKIPPED=false
[[ "$INSTALL_GIT" == "false" || "$INSTALL_NPM" == "false" || "$INSTALL_PIP" == "false" || "$INSTALL_GO" == "false" || "$INSTALL_DOCKER" == "false" || "$INSTALL_CARGO" == "false" ]] && ANY_SKIPPED=true

if [[ "$ANY_SKIPPED" == "true" ]]; then
    echo "💡 可选配置:"
    [[ "$INSTALL_GIT" == "false" ]] && echo "  - Git: 运行 'bash $PROJECT_DIR/configs/gitconfig-proxy on'"
    [[ "$INSTALL_NPM" == "false" ]] && echo "  - npm: 运行 'bash $PROJECT_DIR/configs/npmrc-proxy on'"
    [[ "$INSTALL_PIP" == "false" ]] && echo "  - pip: 运行 'bash $PROJECT_DIR/configs/pip-proxy on'"
    [[ "$INSTALL_GO" == "false" ]] && echo "  - Go: 运行 'bash $PROJECT_DIR/configs/go-proxy on'"
    [[ "$INSTALL_DOCKER" == "false" ]] && echo "  - Docker: 运行 'bash $PROJECT_DIR/configs/docker-proxy on'"
    [[ "$INSTALL_CARGO" == "false" ]] && echo "  - Cargo: 运行 'bash $PROJECT_DIR/configs/cargo-proxy on'"
    echo ""
fi

echo "💡 提示: 重启终端或执行 'source ~/.zshrc' 以在新会话中使用"