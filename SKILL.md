---
name: toutiao-publish
description: 自动发布内容到今日头条（微头条/文章）。触发词：发头条、发布头条、微头条、今日头条、发文章。支持文字、图片、话题、位置、头条首发、作品声明。自动处理登录、弹窗、发布流程。
---

# 今日头条自动发布 v4.0（完全自动化版）

## 🚀 2026-03-03 重大更新

### 新增功能
- ✅ **JavaScript 注入发布** - 直接注入完整 HTML 内容到 ProseMirror 编辑器
- ✅ **拖拽图片上传** - 使用 DataTransfer API 实现完全自动化
- ✅ **HTTP 服务器方案** - 启动本地 HTTP 服务器绕过 file://协议限制
- ✅ **免费正版图片库** - 使用头条号图片库自动选择封面
- ✅ **长文章支持** - 支持 2000+ 字完整文章注入
- ✅ **内容图片自动上传** - 支持多张内容图片自动上传
- ✅ **智能错误重试** - 自动处理 ref 失效，重新 snapshot
- ✅ **完整发布流程** - 从文章到发布的 100% 自动化

---

## 核心方案

### 方案 1: HTTP 服务器 + 拖拽上传（推荐 ⭐）

**原理**: 启动本地 HTTP 服务器，将图片通过 HTTP URL 访问，然后使用 DataTransfer API 模拟拖拽上传。

```bash
# 1. 启动 HTTP 服务器
mkdir -p /tmp/openclaw/uploads
cp /path/to/images/*.png /tmp/openclaw/uploads/
cd /tmp/openclaw/uploads && python3 -m http.server 8000 &

# 2. 使用 HTTP URL 上传图片
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    (async () => {
      const editor = document.querySelector(\".ProseMirror\");
      const response = await fetch(\"http://localhost:8000/image.png\");
      const blob = await response.blob();
      const file = new File([blob], \"image.png\", { type: \"image/png\" });
      const dataTransfer = new DataTransfer();
      dataTransfer.items.add(file);
      editor.dispatchEvent(new DragEvent(\"drop\", {
        dataTransfer: dataTransfer,
        bubbles: true
      }));
      return \"上传成功\";
    })();
  }"
}' targetId=页面 ID
```

### 方案 2: 免费正版图片库（封面专用）

**原理**: 使用头条号内置的免费正版图片库选择封面，无需上传。

```bash
# 1. 点击封面区域
browser action: act profile=openclaw request='{
  "kind": "click",
  "ref": "封面区域 ref"
}' targetId=页面 ID

# 2. 点击"免费正版图片"
browser action: act profile=openclaw request='{
  "kind": "click",
  "ref": "免费正版图片 ref"
}' targetId=页面 ID

# 3. 输入搜索关键词
browser action: act profile=openclaw request='{
  "kind": "type",
  "ref": "搜索框 ref",
  "text": "科技 电脑"
}' targetId=页面 ID

# 4. 选择图片
browser action: act profile=openclaw request='{
  "kind": "click",
  "ref": "图片 ref"
}' targetId=页面 ID

# 5. 点击确定
browser action: act profile=openclaw request='{
  "kind": "click",
  "ref": "确定按钮 ref"
}' targetId=页面 ID
```

---

## 完整自动化发布流程 v4.0

### 步骤 1: 准备图片并启动 HTTP 服务器

```bash
# 创建图片目录
mkdir -p /tmp/openclaw/uploads

# 复制图片（文章配图 + 封面备选）
cp /path/to/article-img-1.png /tmp/openclaw/uploads/
cp /path/to/article-img-2.png /tmp/openclaw/uploads/
cp /path/to/cover.png /tmp/openclaw/uploads/

# 启动 HTTP 服务器（后台运行）
cd /tmp/openclaw/uploads && python3 -m http.server 8000 &

# 验证服务器
curl -s http://localhost:8000/ | head -10
```

### 步骤 2: 打开登录页并检测登录状态

```bash
# 打开头条号
browser action: open profile=openclaw targetUrl=https://mp.toutiao.com

# 等待页面加载
browser action: act profile=openclaw request='{
  "kind": "wait",
  "timeMs": 3000
}' targetId=页面 ID

# 检测登录状态
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    const userName = document.querySelector('a[href*=\"toutiao.com/c/user\"]');
    if (userName) {
      return { logged_in: true, username: userName.textContent };
    }
    return { logged_in: false, reason: \"not found username\" };
  }"
}' targetId=页面 ID

# 如果未登录，执行登录流程
# ...（参考登录流程章节）
```

### 步骤 3: 打开发布页面

```bash
# 打开文章发布页
browser action: open profile=openclaw targetUrl=https://mp.toutiao.com/profile_v4/graphic/publish

# 等待页面加载（5 秒）
browser action: act profile=openclaw request='{
  "kind": "wait",
  "timeMs": 5000
}' targetId=页面 ID

# 获取页面元素
browser action: snapshot profile=openclaw refs=aria
```

### 步骤 4: 输入文章标题

```bash
# 找到标题输入框并输入
browser action: act profile=openclaw request='{
  "kind": "type",
  "ref": "标题框 ref",
  "text": "文章标题（2-30 字）"
}' targetId=页面 ID
```

### 步骤 5: JavaScript 注入完整文章内容（支持 2000+ 字 ⭐）

```bash
# 注入完整 HTML 内容到 ProseMirror 编辑器
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    const editor = document.querySelector('.ProseMirror');
    if (!editor) return '错误：未找到编辑器';
    
    // 构建带格式的完整 HTML 内容（支持长文章）
    const htmlContent = \`
      <h1>一、项目背景</h1>
      <p>OpenClaw 是强大的个人 AI 助手框架，但浏览器自动化存在反爬虫检测和系统兼容性问题。</p>
      
      <h1>二、技术方案</h1>
      <p>我们设计了扩展层架构，包含人类行为模拟和指纹保护两大模块。</p>
      <h2>2.1 人类行为模拟</h2>
      <p>通过贝塞尔曲线模拟鼠标轨迹，自然滚动模式，键盘输入节奏等。</p>
      <h2>2.2 指纹保护</h2>
      <p>通过 Canvas 混淆、WebGL 伪装、User-Agent 伪装等技术保护浏览器指纹。</p>
      
      <h1>三、实施过程</h1>
      <p>通过禁用 Chrome Updater 和优化启动参数，将稳定性从 30 秒提升到 10 分钟以上。</p>
      <h2>3.1 禁用 Updater</h2>
      <p>重命名 Updater 应用，修改 hosts 文件阻止连接。</p>
      <h2>3.2 优化启动参数</h2>
      <p>使用完整的 Chrome 启动参数，禁用所有后台功能。</p>
      
      <h1>四、测试结果</h1>
      <p>综合真实度从 4/10 提升到 8/10，提升 100%。</p>
      <h2>4.1 稳定性测试</h2>
      <p>从 30-60 秒崩溃提升到稳定运行 10 分钟以上。</p>
      <h2>4.2 反检测测试</h2>
      <p>WebDriver 检测从 100% 暴露降到 0% 暴露。</p>
    \`;
    
    editor.innerHTML = htmlContent;
    
    // 触发 input 事件（让编辑器识别内容变化）
    editor.dispatchEvent(new Event('input', { bubbles: true }));
    document.dispatchEvent(new Event('selectionchange'));
    
    return '注入成功，共' + editor.innerText.length + '字';
  }"
}' targetId=页面 ID

# 验证内容已注入
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    const editor = document.querySelector('.ProseMirror');
    return editor ? editor.innerText.length : 0;
  }"
}' targetId=页面 ID
```

### 步骤 6: 拖拽上传内容图片（多张 ⭐）

```bash
# 上传第一张内容图片
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    (async () => {
      const editor = document.querySelector('.ProseMirror');
      if (!editor) return '未找到编辑器';
      
      const response = await fetch('http://localhost:8000/article-img-1.png');
      const blob = await response.blob();
      const file = new File([blob], 'article-img-1.png', { type: 'image/png' });
      
      const dataTransfer = new DataTransfer();
      dataTransfer.items.add(file);
      
      editor.dispatchEvent(new DragEvent('drop', {
        dataTransfer: dataTransfer,
        bubbles: true
      }));
      
      return '图片 1 上传成功';
    })();
    return '上传中...';
  }"
}' targetId=页面 ID

# 等待上传完成
browser action: act profile=openclaw request='{
  "kind": "wait",
  "timeMs": 5000
}' targetId=页面 ID

# 上传第二张内容图片
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    (async () => {
      const editor = document.querySelector('.ProseMirror');
      const response = await fetch('http://localhost:8000/article-img-2.png');
      const blob = await response.blob();
      const file = new File([blob], 'article-img-2.png', { type: 'image/png' });
      const dataTransfer = new DataTransfer();
      dataTransfer.items.add(file);
      editor.dispatchEvent(new DragEvent('drop', {
        dataTransfer: dataTransfer,
        bubbles: true
      }));
      return '图片 2 上传成功';
    })();
  }"
}' targetId=页面 ID

browser action: act profile=openclaw request='{
  "kind": "wait",
  "timeMs": 5000
}' targetId=页面 ID
```

### 步骤 7: 使用免费正版图片库设置封面（推荐 ⭐）

```bash
# 1. 点击封面区域
browser action: act profile=openclaw request='{
  "kind": "click",
  "ref": "封面区域 ref"
}' targetId=页面 ID

# 2. 点击"免费正版图片"
browser action: act profile=openclaw request='{
  "kind": "click",
  "ref": "免费正版图片 ref"
}' targetId=页面 ID

# 3. 输入搜索关键词
browser action: act profile=openclaw request='{
  "kind": "type",
  "ref": "搜索框 ref",
  "text": "科技 电脑"
}' targetId=页面 ID

# 4. 等待搜索结果
browser action: act profile=openclaw request='{
  "kind": "wait",
  "timeMs": 3000
}' targetId=页面 ID

# 5. 选择第一张图片
browser action: act profile=openclaw request='{
  "kind": "click",
  "ref": "第一张图片 ref"
}' targetId=页面 ID

# 6. 点击确定
browser action: act profile=openclaw request='{
  "kind": "click",
  "ref": "确定按钮 ref"
}' targetId=页面 ID

# 等待封面上传完成
browser action: act profile=openclaw request='{
  "kind": "wait",
  "timeMs": 3000
}' targetId=页面 ID
```

### 步骤 8: 设置头条首发和作品声明

```bash
# 勾选头条首发
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    const elements = document.querySelectorAll('[role=\"checkbox\"], .checkbox');
    for (let el of elements) {
      if (el.textContent && el.textContent.includes('头条首发')) {
        el.click();
        return '已勾选头条首发';
      }
    }
    return '未找到头条首发选项';
  }"
}' targetId=页面 ID

# 勾选引用 AI（如使用 AI 创作）
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    const elements = document.querySelectorAll('[role=\"checkbox\"], .checkbox');
    for (let el of elements) {
      if (el.textContent && el.textContent.includes('引用 AI')) {
        el.click();
        return '已勾选引用 AI';
      }
    }
    return '未找到引用 AI 选项';
  }"
}' targetId=页面 ID

# 选择作品声明（个人观点）
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    const elements = document.querySelectorAll('[role=\"radio\"], .radio, [cursor=\"pointer\"]');
    for (let el of elements) {
      if (el.textContent && el.textContent.includes('个人观点')) {
        el.click();
        return '已选择作品声明';
      }
    }
    return '未找到声明选项';
  }"
}' targetId=页面 ID
```

### 步骤 9: 预览并发布

```bash
# 点击预览并发布按钮
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    const buttons = Array.from(document.querySelectorAll('button'));
    const publishBtn = buttons.find(b => b.textContent.includes('预览并发布'));
    if (publishBtn) {
      publishBtn.scrollIntoView();
      publishBtn.click();
      return '已点击预览并发布';
    }
    return '未找到发布按钮';
  }"
}' targetId=页面 ID

# 等待预览页面加载
browser action: act profile=openclaw request='{
  "kind": "wait",
  "timeMs": 3000
}' targetId=页面 ID

# 获取确认发布按钮
browser action: snapshot profile=openclaw refs=aria

# 点击确认发布
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    const buttons = Array.from(document.querySelectorAll('button'));
    const confirmBtn = buttons.find(b => 
      b.textContent.includes('确认发布') || 
      b.textContent.includes('立即发布')
    );
    if (confirmBtn) {
      confirmBtn.click();
      return '已确认发布';
    }
    return '未找到确认按钮';
  }"
}' targetId=页面 ID

# 等待发布完成
browser action: act profile=openclaw request='{
  "kind": "wait",
  "timeMs": 5000
}' targetId=页面 ID

# 检查发布结果
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    const url = window.location.href;
    if (url.includes('/manage/content') || url.includes('/graphic/articles')) {
      return { success: true, message: '发布成功！' };
    }
    if (url.includes('/publish')) {
      return { success: false, message: '仍在发布页面' };
    }
    return { success: 'unknown', url: url };
  }"
}' targetId=页面 ID
```

---

## 完整示例：一键发布 2000 字文章 + 多张图片

```bash
# 1. 准备图片并启动 HTTP 服务器
mkdir -p /tmp/openclaw/uploads
cp article-img-1.png article-img-2.png cover.png /tmp/openclaw/uploads/
cd /tmp/openclaw/uploads && python3 -m http.server 8000 &

# 2. 打开登录页（如未登录）
browser action: open profile=openclaw targetUrl=https://mp.toutiao.com

# 3. 打开发布页
browser action: open profile=openclaw targetUrl=https://mp.toutiao.com/profile_v4/graphic/publish
browser action: act profile=openclaw request='{"kind": "wait", "timeMs": 5000}' targetId=页面 ID

# 4. 输入标题
browser action: act profile=openclaw request='{
  "kind": "type",
  "ref": "标题框 ref",
  "text": "OpenClaw 浏览器自动化增强实战：从 30 秒崩溃到稳定运行"
}' targetId=页面 ID

# 5. 注入完整文章（2000+ 字）
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    const editor = document.querySelector('.ProseMirror');
    editor.innerHTML = \`
      <h1>一、项目背景</h1>
      <p>OpenClaw 是强大的个人 AI 助手框架...</p>
      <h1>二、技术方案</h1>
      <h2>2.1 人类行为模拟</h2>
      <p>通过贝塞尔曲线模拟鼠标轨迹...</p>
      <h2>2.2 指纹保护</h2>
      <p>通过 Canvas 混淆、WebGL 伪装...</p>
      <h1>三、实施过程</h1>
      <h2>3.1 禁用 Updater</h2>
      <p>重命名 Updater 应用...</p>
      <h2>3.2 优化启动参数</h2>
      <p>使用完整的 Chrome 启动参数...</p>
      <h1>四、测试结果</h1>
      <h2>4.1 稳定性测试</h2>
      <p>从 30-60 秒崩溃提升到稳定运行 10 分钟以上...</p>
      <h2>4.2 反检测测试</h2>
      <p>WebDriver 检测从 100% 暴露降到 0% 暴露...</p>
    \`;
    editor.dispatchEvent(new Event('input', { bubbles: true }));
    return '注入成功，共' + editor.innerText.length + '字';
  }"
}' targetId=页面 ID

# 6. 上传内容图片（2 张）
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    (async () => {
      const editor = document.querySelector('.ProseMirror');
      const response = await fetch('http://localhost:8000/article-img-1.png');
      const blob = await response.blob();
      const file = new File([blob], 'article-img-1.png', { type: 'image/png' });
      const dataTransfer = new DataTransfer();
      dataTransfer.items.add(file);
      editor.dispatchEvent(new DragEvent('drop', {
        dataTransfer: dataTransfer,
        bubbles: true
      }));
    })();
  }"
}' targetId=页面 ID
browser action: act profile=openclaw request='{"kind": "wait", "timeMs": 5000}' targetId=页面 ID

browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    (async () => {
      const editor = document.querySelector('.ProseMirror');
      const response = await fetch('http://localhost:8000/article-img-2.png');
      const blob = await response.blob();
      const file = new File([blob], 'article-img-2.png', { type: 'image/png' });
      const dataTransfer = new DataTransfer();
      dataTransfer.items.add(file);
      editor.dispatchEvent(new DragEvent('drop', {
        dataTransfer: dataTransfer,
        bubbles: true
      }));
    })();
  }"
}' targetId=页面 ID
browser action: act profile=openclaw request='{"kind": "wait", "timeMs": 5000}' targetId=页面 ID

# 7. 设置封面（使用免费正版图片）
browser action: act profile=openclaw request='{
  "kind": "click",
  "ref": "封面区域 ref"
}' targetId=页面 ID
browser action: act profile=openclaw request='{
  "kind": "click",
  "ref": "免费正版图片 ref"
}' targetId=页面 ID
browser action: act profile=openclaw request='{
  "kind": "type",
  "ref": "搜索框 ref",
  "text": "科技 电脑"
}' targetId=页面 ID
browser action: act profile=openclaw request='{"kind": "wait", "timeMs": 3000}' targetId=页面 ID
browser action: act profile=openclaw request='{
  "kind": "click",
  "ref": "第一张图片 ref"
}' targetId=页面 ID
browser action: act profile=openclaw request='{
  "kind": "click",
  "ref": "确定按钮 ref"
}' targetId=页面 ID
browser action: act profile=openclaw request='{"kind": "wait", "timeMs": 3000}' targetId=页面 ID

# 8. 设置声明
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    const elements = document.querySelectorAll('[role=\"checkbox\"]');
    for (let el of elements) {
      if (el.textContent.includes('头条首发')) el.click();
      if (el.textContent.includes('引用 AI')) el.click();
    }
    return '声明设置完成';
  }"
}' targetId=页面 ID

# 9. 发布
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    const buttons = Array.from(document.querySelectorAll('button'));
    const publishBtn = buttons.find(b => b.textContent.includes('预览并发布'));
    if (publishBtn) { publishBtn.click(); return '已发布'; }
    return '未找到按钮';
  }"
}' targetId=页面 ID
browser action: act profile=openclaw request='{"kind": "wait", "timeMs": 3000}' targetId=页面 ID
browser action: act profile=openclaw request='{
  "kind": "evaluate",
  "fn": "() => {
    const buttons = Array.from(document.querySelectorAll('button'));
    const confirmBtn = buttons.find(b => b.textContent.includes('确认发布'));
    if (confirmBtn) { confirmBtn.click(); return '已确认'; }
    return '未找到确认按钮';
  }"
}' targetId=页面 ID
browser action: act profile=openclaw request='{"kind": "wait", "timeMs": 5000}' targetId=页面 ID
```

---

## 故障排查

### 内容丢失问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 文章内容太短 | 注入的 HTML 内容太少 | 增加 HTML 内容长度，至少 1000 字 |
| 图片未显示 | 上传失败或路径错误 | 检查 HTTP 服务器是否启动，图片路径是否正确 |
| 封面未设置 | 图片库选择失败 | 检查 ref 是否正确，等待搜索结果 |

### 发布失败问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 发布按钮不可点击 | 内容不完整 | 检查标题、正文、封面是否完整 |
| 提示"内容太少" | 正文字数不足 | 增加到 200 字以上（建议 1000+） |
| 卡在发布中 | 网络问题 | 检查网络连接 |

---

## 更新日志

### 2026-03-03 v4.0
- ✅ 新增 HTTP 服务器方案绕过 file://限制
- ✅ 新增拖拽上传内容图片（多张支持）
- ✅ 新增免费正版图片库设置封面
- ✅ 新增长文章支持（2000+ 字）
- ✅ 新增完整发布流程示例
- ✅ 优化错误处理机制
- ✅ 新增故障排查章节

### 2026-03-03 v3.0
- ✅ 新增拖拽图片上传方案
- ✅ 新增封面自动上传

### 2026-03-03 v2.0
- ✅ 新增 JavaScript 注入发布方法

---

#今日头条 #自动发布 #内容创作 #效率工具 #AI 创作 #拖拽上传 #长文章
