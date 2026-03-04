# toutiao-publish - 今日头条自动发布技能

<div align="center">

**自动发布内容到今日头条（微头条/文章）**

[![Version](https://img.shields.io/badge/version-6.0.0-blue.svg)](https://clawhub.ai/toutiao-publish)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-Skill-orange.svg)](https://openclaw.ai)

</div>

---

## 📖 简介

toutiao-publish 是一个用于自动发布内容到今日头条的 OpenClaw 技能。支持完整的文章发布流程，包括标题输入、内容注入、图片上传、封面设置、声明勾选和自动发布。

### ✨ 核心特性

- ✅ **AI 推荐图片插入正文** ⭐ - 智能推荐相关图片并自动插入文章
- ✅ **免费正版图片库设置封面** ⭐ - 使用头条号图片库自动选择封面
- ✅ **完整 JavaScript 内容注入** - 支持富文本格式完整注入
- ✅ **自动化发布流程** - 标题→正文→图片→封面→声明→发布 全流程自动化
- ✅ **错误处理和重试机制** - 自动处理 ref 失效，重新 snapshot
- ✅ **长文章支持** - 支持 2000+ 字完整文章注入
- ✅ **智能声明** - 自动勾选头条首发和引用 AI

---

## 🚀 快速开始

### 前置要求

- OpenClaw v2.0+
- Node.js 18+
- Python 3.8+
- 今日头条账号（已登录）
- 浏览器配置（Chrome/Chromium）

### 安装

```bash
# 从 ClawHub 安装
clawhub install toutiao-publish

# 或手动安装
git clone https://github.com/axdlee/toutiao-publish.git
cp -r toutiao-publish ~/.openclaw/workspace/skills/
```

### 基本使用

```bash
# 一键发布示例
./publish-toutiao.sh "文章标题" "正文内容..." "科技 电脑" "科技"

# 发头条（自动识别意图）
发头条，标题"我的第一篇文章"，内容"这是正文内容..."

# 发布完整文章
发布头条文章，标题"OpenClaw 自动化实战"，内容文件 article.md，配图 img1.png img2.png

# 使用 AI 创作
用 AI 帮我写一篇关于技术的文章并发布到头条
```

---

## 📚 使用场景

- **自动发布技术文章** - 技术博客、教程、实战分享
- **自动发布新闻资讯** - 热点新闻、行业资讯、快讯
- **自动发布 AI 生成内容** - AI 创作的文章、报告、分析

---

## 🔧 配置说明

### 浏览器配置

- 需要 Chrome 或 Chromium 浏览器
- 支持 CDP (Chrome DevTools Protocol) 连接
- 建议使用独立浏览器配置文件

### 图片配置

- **正文图片**: 支持 AI 推荐自动插入
- **封面图片**: 使用免费正版图片库，需设置搜索关键词
- 图片路径支持 HTTP 服务器方案

### 发布配置

- 需要预先登录头条号
- 首次使用需手动完成登录流程
- 支持自动勾选声明（头条首发、引用 AI）

---

## 📝 功能详解

### 1. 文章注入

支持完整的 HTML 格式注入到 ProseMirror 编辑器：

```javascript
const htmlContent = `
  <h1>一、项目背景</h1>
  <p>正文内容...</p>
  <h1>二、技术方案</h1>
  <h2>2.1 技术细节</h2>
  <p>详细内容...</p>
`;
editor.innerHTML = htmlContent;
```

### 2. AI 推荐图片插入 ⭐

自动分析文章内容，推荐相关图片并插入正文：

```bash
# 自动分析关键词并推荐图片
# 从免费图片库选择合适图片
# 自动插入到文章合适位置
```

### 3. 封面设置

使用头条号免费正版图片库：

```bash
# 点击封面区域
# 点击"免费正版图片"
# 输入搜索关键词（如"科技 电脑"）
# 选择图片
# 点击确定
```

### 4. 自动化发布流程

完整流程自动化：

1. 输入标题
2. 注入文章内容
3. AI 推荐并插入图片
4. 设置封面（免费正版图片库）
5. 勾选声明（头条首发 + 引用 AI）
6. 预览并发布

---

## ⚠️ 已知限制

- **正文图片暂不支持本地上传** - 目前仅支持 AI 推荐和在线图片
- **ref 是动态的** - 需每次 snapshot 获取最新 ref
- **需要头条号已登录状态** - 首次使用需手动登录
- **浏览器配置要求** - 需要支持 CDP 的浏览器

---

## 🐛 故障排查

### 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 发布按钮不可点击 | 内容不完整 | 检查标题、正文、封面是否完整 |
| 提示"内容太少" | 正文字数不足 | 增加到 200 字以上 |
| ref 找不到 | 页面已变化 | 重新 snapshot 获取新 ref |
| 图片推荐失败 | 关键词不匹配 | 调整搜索关键词或手动选择 |

### 调试技巧

```bash
# 检查 CDP 连接
agent-browser --cdp 9222 eval "document.title"

# 检查编辑器状态
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => document.querySelector(\".ProseMirror\").innerText.length"
}'
```

---

## 📄 更新日志

详细更新日志请查看 [RELEASE-NOTES.md](RELEASE-NOTES.md)

### v6.0.0 (2026-03-04)

- ⭐ 新增 AI 推荐图片插入正文功能
- ⭐ 新增免费正版图片库设置封面
- ✅ 完整 JavaScript 内容注入
- ✅ 自动化发布流程优化
- ✅ 错误处理和重试机制增强

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📞 联系方式

- **作者**: axdlee
- **GitHub**: [@axdlee](https://github.com/axdlee)

---

<div align="center">

**如果这个项目对你有帮助，请给一个 ⭐ Star！**

Made with ❤️ by axdlee

</div>
