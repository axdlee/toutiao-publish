# toutiao-publish - 今日头条自动发布技能

<div align="center">

**自动发布内容到今日头条（微头条/文章）**

[![Version](https://img.shields.io/badge/version-4.0.0-blue.svg)](https://clawhub.ai/toutiao-publish)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-Skill-orange.svg)](https://openclaw.ai)

</div>

---

## 📖 简介

toutiao-publish 是一个用于自动发布内容到今日头条的 OpenClaw 技能。支持完整的文章发布流程，包括标题输入、内容注入、图片上传、封面设置、声明勾选和自动发布。

### ✨ 核心特性

- ✅ **长文章支持** - 支持 2000+ 字完整文章注入
- ✅ **自动图片上传** - 使用拖拽 API 自动上传内容图片
- ✅ **HTTP 服务器方案** - 绕过 file://协议限制
- ✅ **免费正版图片库** - 使用头条号图片库自动选择封面
- ✅ **智能声明** - 自动勾选头条首发和引用 AI
- ✅ **完整自动化** - 从登录到发布 100% 自动化
- ✅ **错误重试** - 自动处理 ref 失效，重新 snapshot

---

## 🚀 快速开始

### 前置要求

- OpenClaw v2.0+
- Node.js 18+
- Python 3.8+
- 今日头条账号（已登录）

### 安装

```bash
# 通过 clawhub 安装
clawhub install toutiao-publish

# 或手动安装
git clone https://github.com/axdlee/toutiao-publish.git
cp -r toutiao-publish ~/.openclaw/workspace/skills/
```

### 基本使用

```bash
# 发头条（自动识别意图）
发头条，标题"我的第一篇文章"，内容"这是正文内容..."

# 发布完整文章
发布头条文章，标题"OpenClaw 自动化实战"，内容文件 article.md，配图 img1.png img2.png

# 使用 AI 创作
用 AI 帮我写一篇关于技术的文章并发布到头条
```

### 高级用法

```bash
# 启动 HTTP 服务器（用于图片上传）
mkdir -p /tmp/openclaw/uploads
cp images/*.png /tmp/openclaw/uploads/
cd /tmp/openclaw/uploads && python3 -m http.server 8000 &

# 使用完整流程
1. 打开 https://mp.toutiao.com/profile_v4/graphic/publish
2. 输入标题
3. 注入文章内容
4. 上传图片（拖拽 API）
5. 设置封面（免费正版图片库）
6. 勾选声明（头条首发 + 引用 AI）
7. 预览并发布
```

---

## 📚 功能详解

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

### 2. 图片上传

使用 DataTransfer API 实现拖拽上传：

```javascript
const response = await fetch('http://localhost:8000/image.png');
const blob = await response.blob();
const file = new File([blob], 'image.png', { type: 'image/png' });
const dataTransfer = new DataTransfer();
dataTransfer.items.add(file);
editor.dispatchEvent(new DragEvent('drop', {
  dataTransfer: dataTransfer,
  bubbles: true
}));
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

---

## 🔧 技术架构

```
toutiao-publish/
├── SKILL.md              # 技能文档（本文件）
├── README.md             # 使用说明
├── package.json          # 包配置
├── LICENSE               # 许可证
└── examples/             # 使用示例
    ├── basic.md          # 基础用法
    └── advanced.md       # 高级用法
```

### 核心技术

| 技术 | 用途 | 说明 |
|------|------|------|
| ProseMirror | 编辑器 | 头条号使用的富文本编辑器 |
| DataTransfer API | 图片上传 | 模拟拖拽上传 |
| HTTP Server | 图片访问 | 绕过 file://协议限制 |
| CDP | 浏览器控制 | Chrome DevTools Protocol |

---

## 📝 使用示例

### 示例 1：发布简单文章

```bash
# 准备内容
echo "# 我的文章\n\n这是正文内容..." > article.md

# 发布
发头条，标题"我的第一篇文章"，内容文件 article.md
```

### 示例 2：发布带配图的文章

```bash
# 准备图片
mkdir -p /tmp/openclaw/uploads
cp img1.png img2.png /tmp/openclaw/uploads/

# 启动 HTTP 服务器
cd /tmp/openclaw/uploads && python3 -m http.server 8000 &

# 发布
发布头条文章，标题"技术分享"，内容文件 article.md，配图 img1.png img2.png
```

### 示例 3：使用 AI 创作

```bash
# 使用 AI 生成内容并发布
用 AI 帮我写一篇关于浏览器自动化的文章，发布到头条，标题"OpenClaw 实战"
```

---

## ⚠️ 注意事项

1. **图片路径** - 使用 HTTP 服务器方案时，确保图片在 `/tmp/openclaw/uploads/` 目录下
2. **文章长度** - 建议文章长度在 200-3000 字之间
3. **图片数量** - 建议 2-6 张配图
4. **封面设置** - 必须设置封面才能发布
5. **声明勾选** - 使用 AI 创作时请勾选"引用 AI"

---

## 🐛 故障排查

### 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 图片上传失败 | HTTP 服务器未启动 | 检查 `python3 -m http.server 8000` 是否运行 |
| 发布按钮不可点击 | 内容不完整 | 检查标题、正文、封面是否完整 |
| 提示"内容太少" | 正文字数不足 | 增加到 200 字以上 |
| ref 找不到 | 页面已变化 | 重新 snapshot 获取新 ref |

### 调试技巧

```bash
# 检查 HTTP 服务器
curl http://localhost:8000/

# 检查 CDP 连接
agent-browser --cdp 9222 eval "document.title"

# 检查编辑器状态
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => document.querySelector(\".ProseMirror\").innerText.length"
}'
```

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

- **作者**: 李小东
- **GitHub**: [@axdlee](https://github.com/axdlee)
- **Email**: xdlee110@gmail.com

---

## 🙏 致谢

- [OpenClaw](https://openclaw.ai) - AI 助手框架
- [ClawHub](https://clawhub.ai) - 技能市场
- [今日头条](https://www.toutiao.com) - 内容平台

---

<div align="center">

**如果这个项目对你有帮助，请给一个 ⭐ Star！**

Made with ❤️ by 李小东

</div>
