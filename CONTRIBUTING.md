# 贡献指南

感谢您对本项目的关注！我们欢迎任何形式的贡献。

## 如何贡献

### 报告问题

1. 在 [Issues](https://github.com/dongzhenye/setproxy/issues) 中搜索是否已有相似问题
2. 创建新 Issue 时请包含：
   - macOS 版本
   - 使用的代理工具（Clash/V2Ray/Surge等）
   - 错误信息或截图
   - 复现步骤

### 提交代码

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的修改 (`git commit -m 'feat: add some amazing feature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 代码规范

- Shell 脚本使用 `#!/bin/bash` 开头
- 保持代码简洁，添加必要的注释
- 错误处理要友好，给出明确的提示
- 保持中文文档的准确性

### Commit 规范

请使用以下格式：
- `feat:` 新功能
- `fix:` 修复bug
- `docs:` 文档更新
- `style:` 代码格式调整
- `refactor:` 代码重构
- `test:` 测试相关
- `chore:` 构建过程或辅助工具的变动

## 开发建议

- 测试您的修改在不同的代理工具下是否正常工作
- 确保脚本在 macOS 不同版本上的兼容性
- 保持向后兼容性

## 问题讨论

如有任何问题，欢迎在 Issues 中讨论！