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

## 🚀 5分钟快速配置

### 核心问题
虽然代理客户端（如Clash、V2Ray、Surge等）已经开启系统代理，但**macOS终端默认不会自动使用系统代理**。

### 一键解决方案

```bash
# 1. 克隆项目
git clone https://github.com/dongzhenye/setproxy.git
cd setproxy

# 2. 执行配置脚本（根据需求选择）
source setup-proxy.sh --recommended  # 推荐：Git+npm+pip（默认）
source setup-proxy.sh --minimal      # 最小：仅核心proxy命令
source setup-proxy.sh --all          # 完整：包含Go/Docker/Cargo
source setup-proxy.sh --help         # 查看所有选项
```

## 📱 日常使用

```bash
# 开启代理（支持两种写法）
proxy-on    # 或 proxy_on

# 关闭代理
proxy-off   # 或 proxy_off

# 检查代理状态
proxy-status  # 或 proxy_status

# 测试代理连接（显示IP地址和位置）
proxy-test    # 或 proxy_test
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
├── setup-proxy.sh         # 一键配置脚本
└── configs/               # 配置文件模板
    ├── zshrc-proxy        # 核心proxy命令
    ├── gitconfig-proxy    # Git代理配置
    ├── npmrc-proxy        # npm代理配置
    ├── pip-proxy          # pip代理配置
    ├── go-proxy           # Go代理配置
    ├── docker-proxy       # Docker代理配置
    └── cargo-proxy        # Cargo代理配置
```

## 🔧 配置详情

- **代理服务器**：127.0.0.1:7890
- **支持工具**：终端环境变量、git、npm、pip
- **兼容系统**：macOS (zsh终端)

## 🎯 使用场景

### 日常开发
```bash
# 开始工作
proxy-on

# 进行开发工作
npm install
git push origin main
pip install requests

# 结束工作（可选）
proxy-off
```

### 网络环境切换
```bash
# 切换到新网络环境后
proxy-off
proxy-on
proxy-test
```

## 🔧 故障排除

### 1. 命令不生效
```bash
# 重新加载配置
source ~/.zshrc
```

### 2. 代理无法连接
```bash
# 检查代理服务是否运行
lsof -i :7890

# 重新开启代理
proxy-off
proxy-on
proxy-test
```

## 💡 注意事项

1. **代理端口**：默认使用7890端口（支持Clash、V2Ray等主流工具）。如需修改端口，请编辑相应配置文件
2. **网络切换**：更换网络环境时重新执行 `proxy-on`
3. **首次使用**：如果命令不生效，执行 `source ~/.zshrc` 重新加载

## 🔧 支持的工具配置

### 核心功能
- **终端命令**：proxy-on/off/status/test

### 推荐配置（默认安装）
- **Git**：版本控制
- **npm**：Node.js 包管理
- **pip**：Python 包管理

### 扩展配置（可选）
- **Go**：Go 语言开发（含 GOPROXY 镜像）
- **Docker**：容器开发
- **Cargo**：Rust 开发

使用 `source setup-proxy.sh --help` 查看所有安装选项。

## 🗑️ 卸载

如需完全卸载配置：

```bash
# 1. 从 ~/.zshrc 中删除配置
sed -i '' '/# === macOS 终端代理配置 ===/,/# === macOS 终端代理配置 ===/d' ~/.zshrc

# 2. 删除 Git 代理配置
git config --global --unset http.proxy
git config --global --unset https.proxy

# 3. 删除 npm 代理配置（如已安装）
npm config delete proxy
npm config delete https-proxy

# 4. 删除 pip 配置文件（如已创建）
rm -f ~/.pip/pip.conf
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