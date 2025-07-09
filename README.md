# macOS 终端代理配置指南

## 🚀 5分钟快速配置

### 核心问题
虽然Clash for Windows已经开启系统代理，但**macOS终端默认不会自动使用系统代理**。

### 一键解决方案
```bash
# 执行一键配置脚本
source scripts/setup-proxy.sh
```

## 📱 日常使用

### 基础操作
```bash
# 开启代理
source scripts/proxy-on.sh

# 关闭代理
source scripts/proxy-off.sh

# 检查代理状态
./scripts/check-proxy.sh
```

### 验证配置
```bash
# 测试网络连接
curl -I https://google.com

# 检查环境变量
echo $HTTP_PROXY
```

## 📁 文件说明

| 文件 | 用途 |
|------|------|
| `scripts/setup-proxy.sh` | 一键配置脚本 |
| `scripts/proxy-on.sh` | 开启代理 |
| `scripts/proxy-off.sh` | 关闭代理 |
| `scripts/check-proxy.sh` | 检查代理状态 |

## 🔧 配置详情

### 代理服务器信息
- HTTP/HTTPS代理：127.0.0.1:7890
- 支持工具：终端环境变量、git、npm、pip

## 🔥 常见问题

### 1. 终端无法访问海外服务
```bash
source scripts/proxy-on.sh
```

### 2. git 推送/拉取失败
```bash
bash configs/gitconfig-proxy on
```

### 3. 检查代理状态
```bash
./scripts/check-proxy.sh
```

## 💡 注意事项

1. **代理端口**：确保Clash for Windows使用7890端口
2. **网络切换**：更换网络环境时重新执行 `source scripts/proxy-on.sh`

## 📚 更多帮助

- 新手指南：[QUICK_START.md](QUICK_START.md)

## 许可证

MIT License 