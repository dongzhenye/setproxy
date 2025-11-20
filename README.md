# setproxy - macOS 终端代理配置工具

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-macOS-blue.svg)](https://www.apple.com/macos/)
[![Shell](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)

一键解决 macOS 终端不走代理的问题，支持所有主流代理工具。

## 🎯 支持的代理工具

✅ **Clash** / **ClashX** / **Clash for Windows**  
✅ **V2Ray** / **V2RayX** / **V2RayU**  
✅ **Surge** / **Shadowsocks** / **ShadowsocksX**  
✅ **Trojan** / **Quantumult X**  
✅ 任何支持 HTTP/HTTPS/SOCKS5 代理的工具

## 🚀 快速开始（默认直连更安全）

- 核心问题：终端不会自动用系统代理；TUN 模式或直连时不应强制导出代理。
- 默认行为：**off**（直连），只写入命令别名，不导出代理、不改工具。

```bash
# 1. 克隆项目
git clone https://github.com/dongzhenye/setproxy.git
cd setproxy

# 2. 按场景执行（setproxy.sh/on/off 持久化）
# 直连或 TUN（系统代理关闭时推荐）
./setproxy.sh off

# 系统代理场景，按需为工具同步
./setproxy.sh on --with git,npm,pip      # 示例：我自己的常用组合
# 或全工具
./setproxy.sh on --all

# 如是非交互环境、安全起见请显式确认
# ./setproxy.sh on --with git,npm --force

# 重复执行 setproxy on/off 会直接覆盖标记区（无确认）；仅旧配置/非交互场景需 --force

# 查看状态/测试（不改配置）
./setproxy.sh status
./setproxy.sh test

# 首次执行后，如需当前 shell 立即可用别名，请：
source ~/.zshrc
```

## 📱 日常使用（持久化开关）

```bash
# 开启代理（持久化 + 同步当前会话）
proxy-on --with git,npm,pip   # 等同于 setproxy on --with ...

# 关闭代理（持久化 + 清理当前会话）
proxy-off --all               # 仅在需要同步关闭工具时加 --with/--all

# 检查代理状态（持久化优先，额外展示当前 env）
proxy-status

# 测试代理连接（按当前状态测试，不假定开启）
proxy-test
```

### 验证配置
```bash
# 查看代理状态
proxy-status

# 测试代理连接
proxy-test

# 手动检查环境变量
echo $HTTP_PROXY
```

## 📁 项目结构

```
setproxy/
├── README.md              # 使用说明
├── setproxy.sh            # 核心命令入口（on/off/status/test）
├── setup-proxy.sh         # 兼容入口，转发到 setproxy.sh
└── configs/               # 配置文件模板（安装后复制到 ~/.setproxy）
    ├── zshrc-proxy        # 核心命令别名，调用 setproxy.sh
    ├── gitconfig-proxy    # Git代理配置
    ├── npmrc-proxy        # npm代理配置
    ├── pip-proxy          # pip代理配置
    ├── go-proxy           # Go代理配置
    ├── docker-proxy       # Docker代理配置
    └── cargo-proxy        # Cargo代理配置
```

## 🔧 配置详情

- **默认端口**：127.0.0.1:7890，可用 `--port` 或环境变量 `SETPROXY_PORT` 覆盖。  
- **支持工具**（可选同步）：git / npm / pip / go / docker / cargo（通过 `--with` 或 `--all`）。  
- **兼容系统**：macOS (zsh终端)。

### 自定义代理端口

```bash
# 临时覆盖
SETPROXY_PORT=8080 ./setproxy.sh on --with git
# 或直接指定
./setproxy.sh on --port 8080 --with git,npm
```

## 🎯 场景速览

- **系统代理已开**：`setproxy on --with git,npm,pip`（按需列工具）；若全部同步用 `--all`。  
- **TUN/直连**：`setproxy off`（默认）；不改工具，避免强制走本地端口。  
- **仅工具清理**：`setproxy off --with git,npm,pip`（核心 off，工具同步关）。

## 🔧 故障排除

### 1. 命令不生效
```bash
source ~/.zshrc        # 重新加载别名与标记区
./setproxy.sh status   # 看持久化状态与当前 env 是否一致
```

### 2. 代理无法连接
```bash
# 检查代理服务是否运行（替换为你的端口）
lsof -i :7890

# 如果使用自定义端口，检查环境变量/参数
echo $SETPROXY_PORT

# 重新开关
proxy-off
proxy-on --with git
proxy-test
```

## ❓ 常见问题 (FAQ)

### Q: 为什么终端不走系统代理？
A: macOS 终端不会自动读取系统代理，需要通过环境变量导出。setproxy 负责持久化导出/清除，并可按需同步工具配置。

### Q: 如何选择命令？
A: 系统代理开 → `setproxy on --with ...`；TUN/直连 → `setproxy off`；若仅关工具 → `setproxy off --with ...`。

### Q: 支持哪些代理端口？
A: 默认 7890，可用 `--port` 或 `SETPROXY_PORT` 覆盖。

### Q: proxy-on 和 proxy_on 有什么区别？
A: 行为一致，`proxy-on`/`proxy-off` 推荐；下划线仅为兼容别名。

### Q: 如何确认代理是否生效？
A: `proxy-status` 查看持久化 + env；`proxy-test` 测试出口 IP 与常见站点连通性。

### Q: 可以同时使用多个代理工具吗？
A: 可以，但同一时间只能有一个工具监听代理端口。确保只运行一个代理工具，或配置它们使用不同端口。

### Q: 为什么 npm/pip 还是很慢？
A: 
1. 确认代理已开启：`proxy-status`
2. 检查代理工具是否正常运行
3. 某些包可能需要额外配置镜像源

### Q: 如何在新终端窗口自动开启代理？
A: 编辑 `~/.zshrc`，找到 setproxy 配置部分，取消注释最后的自动代理行。

## 💡 注意事项

1. **代理端口**：默认使用7890端口（支持Clash、V2Ray等主流工具）。如需修改端口，请参考上方"自定义代理端口"部分
2. **网络切换**：更换网络环境时重新执行 `proxy-on`
3. **首次使用**：如果命令不生效，执行 `source ~/.zshrc` 重新加载

## 🔧 支持的工具配置

- 核心命令：proxy-on/off/status/test（持久化开关，等同于 `setproxy.sh`）。
- 工具同步：通过 `--with` 列出需要同步的工具，或 `--all` 一键全选（git/npm/pip/go/docker/cargo）。无参数时仅切核心，不动工具。
- 常用示例：`proxy-on --with git,npm,pip`。

## 🧭 工具脚本约定

- 统一日志：前缀 `[git]` / `[npm]` / ...，使用简短中文文案，默认无 emoji。
- 幂等对称：on/off 配置对称，不重复插入；未安装的工具脚本会提示/跳过。
- 安全写入：敏感文件写前备份（如 Docker/Cargo），失败时明确报错；支持 dry-run。
- 可观测：on/off 后回显当前工具配置，便于确认是否生效。

## 🗑️ 卸载

如需完全卸载配置：

```bash
# 1. 从 ~/.zshrc 中删除 setproxy 标记区
python3 - <<'PY'
import re, pathlib
path = pathlib.Path.home()/".zshrc"
if path.exists():
    data = path.read_text()
    pattern = re.compile(r'# BEGIN setproxy.*?# END setproxy\n?', re.S)
    path.write_text(re.sub(pattern,'',data))
PY

# 2. 删除 Git 代理配置（如有）
git config --global --unset http.proxy
git config --global --unset https.proxy

# 3. 删除 npm 代理配置（如有）
npm config delete proxy
npm config delete https-proxy

# 4. 删除 pip 配置文件（如已创建）
rm -f ~/.pip/pip.conf

# 5. 清理用户目录副本
rm -rf ~/.setproxy
```

## 系统要求

- macOS 10.15 或更高版本
- zsh（macOS 默认 shell）
- 基础命令行工具：curl、lsof、git（通过 Xcode Command Line Tools 安装）

## 维护者

- **作者**：Dong Zhenye
- **联系**：通过 [GitHub Issues](https://github.com/dongzhenye/setproxy/issues) 联系

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

[MIT License](LICENSE) 
