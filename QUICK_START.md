# 快速开始指南

## 📋 仓库结构

```
proxy_config/
├── README.md              # 详细使用说明
├── QUICK_START.md         # 快速开始指南（本文件）
├── ADVANCED.md            # 高级配置和技巧
├── .gitignore             # Git忽略文件
├── scripts/               # 脚本目录
│   ├── setup-proxy.sh     # 一键配置脚本
│   ├── proxy-on.sh        # 开启代理环境变量
│   ├── proxy-off.sh       # 关闭代理环境变量
│   └── check-proxy.sh     # 检查代理状态
└── configs/               # 配置文件目录
    ├── zshrc-proxy        # zsh 代理配置
    ├── gitconfig-proxy    # git 代理配置
    ├── npmrc-proxy        # npm 代理配置
    └── pip-proxy          # Python pip 代理配置
```

## 🚀 5分钟快速配置

### 1. 一键配置（推荐）
```bash
# 克隆或下载仓库到本地
# 执行一键配置脚本
source scripts/setup-proxy.sh
```

### 2. 手动配置
```bash
# 开启当前会话代理
source scripts/proxy-on.sh

# 配置git代理
bash configs/gitconfig-proxy on

# 配置pip代理（如果需要）
bash configs/pip-proxy on
```

## 📱 常用命令

### 基础操作
```bash
# 开启代理
source scripts/proxy-on.sh

# 关闭代理
source scripts/proxy-off.sh

# 检查代理状态
./scripts/check-proxy.sh
```

### 应用特定配置
```bash
# 配置/取消Git代理
bash configs/gitconfig-proxy on/off

# 配置/取消npm代理
bash configs/npmrc-proxy on/off

# 配置/取消pip代理
bash configs/pip-proxy on/off
```

## ✅ 验证配置

### 1. 检查环境变量
```bash
echo $HTTP_PROXY
echo $HTTPS_PROXY
echo $ALL_PROXY
```

### 2. 测试网络连接
```bash
curl -I https://google.com
```

### 3. 运行完整检查
```bash
./scripts/check-proxy.sh
```

## 🎯 使用场景

### 场景1：临时开启代理
```bash
# 开启代理
source scripts/proxy-on.sh

# 执行需要代理的命令
curl -I https://google.com
git clone https://github.com/user/repo.git
npm install some-package

# 关闭代理
source scripts/proxy-off.sh
```

### 场景2：长期使用代理
```bash
# 执行一键配置
source scripts/setup-proxy.sh

# 重启终端或重新加载配置
source ~/.zshrc

# 现在可以使用别名命令
proxy-on    # 开启代理
proxy-off   # 关闭代理
proxy-test  # 测试代理连接
```

### 场景3：项目开发
```bash
# 在项目目录中
cd my-project

# 开启代理
proxy-on

# 安装依赖
npm install
pip install -r requirements.txt

# 推送代码
git push origin main
```

## 🔧 故障排除

### 问题1：命令未找到
```bash
# 解决方案：设置执行权限
chmod +x scripts/*.sh configs/*
```

### 问题2：代理无法连接
```bash
# 检查Clash是否运行
lsof -i :7890

# 检查系统代理设置
scutil --proxy

# 重新开启代理
source scripts/proxy-on.sh
```

### 问题3：Git推送失败
```bash
# 配置Git代理
bash configs/gitconfig-proxy on

# 或者使用SSH而非HTTPS
git remote set-url origin git@github.com:user/repo.git
```

## 💡 提示和技巧

### 1. 永久配置
一键配置脚本会自动将代理配置添加到 `~/.zshrc`，这样每次开启终端都可以使用别名命令。

### 2. 别名命令
配置完成后，可以使用以下别名：
- `proxy-on`: 开启代理
- `proxy-off`: 关闭代理
- `proxy-status`: 查看代理状态
- `proxy-test`: 测试代理连接

### 3. 智能代理
可以在 `~/.zshrc` 中启用智能代理功能，自动检测Clash是否运行并开启代理。

### 4. 不同环境
可以为不同的网络环境创建不同的代理配置。

## 📚 进阶学习

- 阅读 [README.md](README.md) 了解详细配置说明
- 根据需要修改脚本和配置文件

## 🤝 贡献和反馈

如果您在使用过程中遇到问题或有改进建议，欢迎：
1. 提交Issue
2. 创建Pull Request
3. 分享使用心得

## 📄 许可证

MIT License - 可自由使用和修改 