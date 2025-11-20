#!/bin/bash
# setproxy: manage terminal proxy exports and tool configs (on/off/status/test)
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_DIR="$HOME/.setproxy"
ZSHRC_FILE="$HOME/.zshrc"
BEGIN_MARK="# BEGIN setproxy"
END_MARK="# END setproxy"
DEFAULT_PORT="${SETPROXY_PORT:-7890}"
NO_PROXY_DEFAULT="localhost,127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,100.64.0.0/10,17.0.0.0/8,169.254.0.0/16,224.0.0.0/4,240.0.0.0/4"
SUPPORTED_TOOLS=(git npm pip go docker cargo)

log() { echo "[$(date +%H:%M:%S)] $*"; }
err() { echo "ERROR: $*" >&2; exit 1; }

usage() {
  cat <<EOF
用法: setproxy.sh <on|off|status|test|help> [选项]
  --port <port>            指定代理端口（默认: ${DEFAULT_PORT}）
  --with <t1[,t2,...]>     指定需要同步开关的工具（可重复传入，支持: ${SUPPORTED_TOOLS[*]})
  --all                    核心+所有工具；与 --with 同时传将报错
  --force                  非交互覆盖旧配置/旧片段
  --dry-run                仅打印计划，不修改
  --help                   查看帮助

说明:
- 核心开关 on/off 持久化到 ~/.zshrc 标记区，并同步当前会话 env。
- 工具仅在显式传入 --with/--all 时执行对应 on/off；核心 off 默认不动工具。
- 安装后别名 setproxy/proxy-on/proxy-off 行为一致，接受相同参数。
EOF
}

join_by() { local IFS="$1"; shift; echo "$*"; }

copy_if_changed() {
  local src="$1" dst="$2"
  if [ -f "$dst" ] && command cmp -s "$src" "$dst"; then
    return
  fi
  command cp -f "$src" "$dst"
}

ensure_user_dir() {
  mkdir -p "$USER_DIR"
  for f in common.sh zshrc-proxy gitconfig-proxy npmrc-proxy pip-proxy go-proxy docker-proxy cargo-proxy; do
    if [ -f "$PROJECT_DIR/configs/$f" ]; then
      copy_if_changed "$PROJECT_DIR/configs/$f" "$USER_DIR/$f"
    fi
  done
  copy_if_changed "$PROJECT_DIR/setproxy.sh" "$USER_DIR/setproxy.sh"
}

is_tool_supported() {
  local t="$1"
  for x in "${SUPPORTED_TOOLS[@]}"; do
    [[ "$x" == "$t" ]] && return 0
  done
  return 1
}

parse_with_list() {
  local raw="$1"; shift || true
  local items=()
  IFS=',' read -r -a parts <<< "$raw"
  for p in "${parts[@]}"; do
    [ -z "$p" ] && continue
    items+=("$p")
  done
  echo "${items[@]}"
}

dedup_tools() {
  local seen="" out=() t
  for t in "$@"; do
    if [[ " $seen " != *" $t "* ]]; then
      out+=("$t"); seen="$seen $t"
    fi
  done
  echo "${out[@]}"
}

require_interaction_or_force() {
  local message="$1"
  if $FORCE; then
    return 0
  fi
  if [ -t 0 ]; then
    read -r -p "$message [y/N]: " ans
    [[ "$ans" == "y" || "$ans" == "Y" ]] || err "已中止。"
  else
    err "$message (非交互环境请使用 --force)"
  fi
}

detect_legacy_files() {
  local need_clean=false
  if [ -f "$HOME/.proxy_config" ]; then
    log "检测到旧文件: ~/.proxy_config"
    need_clean=true
  fi
  if grep -q "proxy_config" "$ZSHRC_FILE" 2>/dev/null; then
    log "检测到 ~/.zshrc 中引用了 proxy_config"
    need_clean=true
  fi
  if $need_clean; then
    if $DRY_RUN; then
      log "[dry-run] 检测到旧配置，将清理 ~/.proxy_config 及 ~/.zshrc 引用"
    else
      require_interaction_or_force "检测到旧配置，是否清理并继续? "
      rm -f "$HOME/.proxy_config"
      # 移除 zshrc 中的相关引用
      python3 - "$ZSHRC_FILE" "$BEGIN_MARK" "$END_MARK" <<'PY'
import sys,re
path=sys.argv[1]
pattern=re.compile(r'.*proxy_config.*\n')
data=open(path).read()
new=re.sub(pattern,'',data)
open(path,'w').write(new)
PY
    fi
  fi
}

existing_block() {
  if [ -f "$ZSHRC_FILE" ]; then
    awk "/$BEGIN_MARK/{flag=1;print}/$END_MARK/{print;flag=0}" "$ZSHRC_FILE"
  fi
}

render_block() {
  local state="$1" port="$2"
  local proxy_url="http://127.0.0.1:${port}"
  cat <<EOF
$BEGIN_MARK
# Managed by setproxy
if [ -f "$HOME/.setproxy/zshrc-proxy" ]; then
  source "$HOME/.setproxy/zshrc-proxy"
fi
# setproxy state: $state
EOF
  if [ "$state" = "on" ]; then
    cat <<EOF
export PROXY_URL="$proxy_url"
export HTTP_PROXY="$proxy_url"
export HTTPS_PROXY="$proxy_url"
export ALL_PROXY="socks5://127.0.0.1:${port}"
export http_proxy="$proxy_url"
export https_proxy="$proxy_url"
export all_proxy="socks5://127.0.0.1:${port}"
export NO_PROXY="$NO_PROXY_DEFAULT"
export no_proxy="$NO_PROXY_DEFAULT"
EOF
  else
    cat <<'EOF'
# proxies are disabled (core off)
unset PROXY_URL HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy NO_PROXY no_proxy
EOF
  fi
  echo "$END_MARK"
}

write_zshrc_block() {
  local block="$1"
  $DRY_RUN && { log "[dry-run] 不写入 ~/.zshrc"; return; }
  python3 - "$ZSHRC_FILE" "$BEGIN_MARK" "$END_MARK" "$block" <<'PY'
import sys,re
zshrc,begin,end,block=sys.argv[1:]
try:
    data=open(zshrc).read()
except FileNotFoundError:
    data=""
pattern=re.compile(re.escape(begin)+r".*?"+re.escape(end)+r"\n?",re.S)
if re.search(pattern,data):
    data=re.sub(pattern,block.strip()+"\n",data)
else:
    if data and not data.endswith("\n"):
        data+="\n"
    data+=block.strip()+"\n"
open(zshrc,'w').write(data)
PY
}

persisted_state() {
  local state="none"
  if [ -f "$ZSHRC_FILE" ]; then
    if awk "/$BEGIN_MARK/{flag=1;next}/$END_MARK/{flag=0}flag" "$ZSHRC_FILE" | grep -q "setproxy state: on"; then
      state="on"
    elif awk "/$BEGIN_MARK/{flag=1;next}/$END_MARK/{flag=0}flag" "$ZSHRC_FILE" | grep -q "setproxy state: off"; then
      state="off"
    fi
  fi
  echo "$state"
}

extract_persisted_port() {
  if [ -f "$ZSHRC_FILE" ]; then
    awk "/$BEGIN_MARK/{flag=1;next}/$END_MARK/{flag=0}flag" "$ZSHRC_FILE" | grep -Eo "127\\.0\\.0\\.1:[0-9]+" | head -n1 | cut -d: -f2
  fi
}

apply_env_on() {
  local port="$1" proxy_url="http://127.0.0.1:${port}"
  export PROXY_URL="$proxy_url"
  export HTTP_PROXY="$proxy_url"
  export HTTPS_PROXY="$proxy_url"
  export ALL_PROXY="socks5://127.0.0.1:${port}"
  export http_proxy="$proxy_url"
  export https_proxy="$proxy_url"
  export all_proxy="$proxy_url"
  export NO_PROXY="$NO_PROXY_DEFAULT"
  export no_proxy="$NO_PROXY_DEFAULT"
}

apply_env_off() {
  unset PROXY_URL HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy NO_PROXY no_proxy
}

run_tool() {
  local tool="$1" state="$2"
  local script_name=""
  case "$tool" in
    git) script_name="gitconfig-proxy" ;;
    npm) script_name="npmrc-proxy" ;;
    pip) script_name="pip-proxy" ;;
    go) script_name="go-proxy" ;;
    docker) script_name="docker-proxy" ;;
    cargo) script_name="cargo-proxy" ;;
    *) script_name="" ;;
  esac
  if [ -z "$script_name" ]; then
    log "跳过 $tool，不支持的工具"
    return
  fi
  local script="$USER_DIR/$script_name"
  if [ ! -x "$script" ]; then
    log "跳过 $tool，脚本不存在: $script"
    return
  fi
  $DRY_RUN && { log "[dry-run] $tool -> $state"; return; }
  bash "$script" "$state"
}

status_cmd() {
  local p_state="$(persisted_state)"
  local port="$(extract_persisted_port)"
  local env_state="off"
  [ -n "$HTTP_PROXY" ] && env_state="on"
  if [ "$p_state" = "none" ]; then
    echo "持久化状态: 未配置 (端口: --)"
  else
    echo "持久化状态: $p_state (端口: ${port:---})"
  fi
  echo "当前会话:    $env_state (HTTP_PROXY: ${HTTP_PROXY:---})"
}

test_cmd() {
  ensure_user_dir
  # 复用当前环境执行连通性探测
  local ip=$(curl -s --connect-timeout 5 --max-time 8 https://ipinfo.io/ip 2>/dev/null || true)
  [ -n "$ip" ] && echo "出口 IP: $ip" || echo "出口 IP: <获取失败>"
  for target in https://google.com https://github.com https://youtube.com; do
    printf "%-18s" "$target"
    if curl -s -I --connect-timeout 5 --max-time 8 "$target" >/dev/null 2>&1; then
      echo "✅"
    else
      echo "❌"
    fi
  done
}

main() {
  local command="$1"; shift || true
  case "$command" in
    on|off|status|test|help) ;;
    "" )
      usage
      exit 0
      ;;
    *) err "未知命令: $command" ;;
  esac

  FORCE=false
  DRY_RUN=false
  PORT="$DEFAULT_PORT"
  DECLARED_TOOLS=()
  USE_ALL=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --port)
        PORT="$2"; shift 2;;
      --with)
        tools=($(parse_with_list "$2"))
        DECLARED_TOOLS+=("${tools[@]}")
        shift 2;;
      --all)
        USE_ALL=true; shift;;
      --force)
        FORCE=true; shift;;
      --dry-run)
        DRY_RUN=true; shift;;
      --help|-h)
        usage; exit 0;;
      *)
        err "未知参数: $1"
        ;;
    esac
  done

  if $USE_ALL && [ "${#DECLARED_TOOLS[@]}" -gt 0 ]; then
    err "--all 不能与 --with 同时使用"
  fi

  if [ "$command" = "help" ]; then
    usage; exit 0
  fi

  ensure_user_dir

  if [ "$command" = "status" ]; then
    status_cmd; exit 0
  fi
  if [ "$command" = "test" ]; then
    status_cmd
    test_cmd
    exit 0
  fi

  detect_legacy_files

  local tools_to_use=()
  if $USE_ALL; then
    tools_to_use=("${SUPPORTED_TOOLS[@]}")
  elif [ "${#DECLARED_TOOLS[@]}" -gt 0 ]; then
    tools_to_use=($(dedup_tools "${DECLARED_TOOLS[@]}"))
    # 校验工具合法性
    invalid=()
    for t in "${tools_to_use[@]}"; do
      if ! is_tool_supported "$t"; then
        invalid+=("$t")
      fi
    done
    if [ "${#invalid[@]}" -gt 0 ]; then
      err "不支持的工具: $(join_by ', ' "${invalid[@]}")。支持: ${SUPPORTED_TOOLS[*]}"
    fi
  fi

  local current_block="$(existing_block)"
  if [ "$command" != "status" ] && [ "$command" != "test" ] && [ -n "$current_block" ]; then
    echo "检测到现有 setproxy 片段："
    echo "$current_block"
    if $DRY_RUN; then
      log "[dry-run] 将覆盖上述片段并应用 setproxy $command"
    else
      log "覆盖现有 setproxy 片段并应用 setproxy $command"
    fi
  fi

  local block="$(render_block "$command" "$PORT")"
  log "写入 ~/.zshrc 标记区 (状态: $command, 端口: $PORT)"
  write_zshrc_block "$block"

  if [ "$command" = "on" ]; then
    apply_env_on "$PORT"
  else
    apply_env_off
  fi

  if [ "${#tools_to_use[@]}" -gt 0 ]; then
    for t in "${tools_to_use[@]}"; do
      run_tool "$t" "$command"
    done
  fi

  log "完成 setproxy $command"
  if ! $DRY_RUN; then
    log "提示：别名 setproxy/proxy-* 需重新打开终端或执行 'source ~/.zshrc' 后生效"
  fi
}

main "$@"
