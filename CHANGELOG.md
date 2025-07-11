# 更新日志

所有重要的更改都将记录在此文件中。

本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/) 规范。

## [未发布]

### 新增
- 支持 IP 地址和地理位置检测
- 添加 proxy_test 等下划线命令别名
- 支持更多代理工具（V2Ray、Surge、Shadowsocks等）
- 添加开源项目标准文件（LICENSE、CONTRIBUTING.md等）

### 改进
- 通用化代理工具引用，不再限定于特定工具
- 优化错误提示信息
- 改进网络连接测试（添加 YouTube 测试）

## [1.0.0] - 2025-01-11

### 新增
- 初始版本发布
- 一键配置终端代理环境
- 支持 Git、npm、pip 代理配置
- 提供便捷的代理管理命令（proxy-on/off/status/test）
- 自动检测代理服务状态
- 完整的中文文档

### 特性
- 支持 macOS 系统
- 基于 zsh shell
- 默认端口 7890（可自定义）
- 智能 NO_PROXY 配置