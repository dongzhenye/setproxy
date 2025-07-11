#!/bin/bash
# 通用函数和配置

# 获取代理端口
get_proxy_port() {
    local port="7890"  # 默认端口
    
    # 1. 优先使用环境变量
    if [ -n "$SETPROXY_PORT" ]; then
        port="$SETPROXY_PORT"
    # 2. 其次使用用户配置文件
    elif [ -f "$HOME/.setproxy/proxy.conf" ]; then
        source "$HOME/.setproxy/proxy.conf"
        [ -n "$PROXY_PORT" ] && port="$PROXY_PORT"
    # 3. 最后使用项目配置文件
    elif [ -f "$(dirname "${BASH_SOURCE[0]}")/proxy.conf" ]; then
        source "$(dirname "${BASH_SOURCE[0]}")/proxy.conf"
        [ -n "$PROXY_PORT" ] && port="$PROXY_PORT"
    fi
    
    echo "$port"
}

# 获取代理URL
get_proxy_url() {
    echo "http://127.0.0.1:$(get_proxy_port)"
}