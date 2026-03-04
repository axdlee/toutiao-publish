#!/bin/bash
# publish-toutiao.sh - 今日头条自动发布脚本 v6.0
# 用法：./publish-toutiao.sh "标题" "正文内容" "图片关键词" "封面关键词"

set -e

# ============ 参数配置 ============
TITLE="${1:-默认标题}"
CONTENT="${2:-默认内容}"
IMAGE_KEYWORD="${3:-科技}"
COVER_KEYWORD="${4:-科技}"

echo "========================================"
echo "  今日头条自动发布脚本 v6.0"
echo "========================================"
echo "标题：$TITLE"
echo "图片关键词：$IMAGE_KEYWORD"
echo "封面关键词：$COVER_KEYWORD"
echo "========================================"

# ============ 步骤 1: 打开发布页面 ============
echo "[1/8] 打开发布页面..."
browser open https://mp.toutiao.com/profile_v4/graphic/publish
browser act request='{"kind": "wait", "timeMs": 5000}'

# ============ 步骤 2: 获取 snapshot ============
echo "[2/8] 获取页面元素..."
SNAPSHOT_RESULT=$(browser snapshot refs=aria)
echo "Snapshot 获取完成"

# ============ 步骤 3: 输入标题 ============
echo "[3/8] 输入标题..."
# 注意：ref 需要从 snapshot 中获取，这里使用示例 ref
# 实际使用时需要根据 snapshot 结果替换 ref
browser act request="{
  \"kind\": \"type\",
  \"ref\": \"标题框 ref\",
  \"text\": \"$TITLE\"
}"
echo "标题输入完成"

# ============ 步骤 4: 注入正文内容 ============
echo "[4/8] 注入正文内容..."
browser act request="{
  \"kind\": \"evaluate\",
  \"fn\": \"() => {
    const editor = document.querySelector('.ProseMirror');
    if (!editor) return '错误：未找到编辑器';
    
    // 注入内容
    editor.innerHTML = \`$CONTENT\`;
    
    // 触发完整事件序列
    editor.dispatchEvent(new Event('input', { bubbles: true }));
    editor.dispatchEvent(new Event('selectionchange', { bubbles: true }));
    editor.dispatchEvent(new CompositionEvent('compositionend', {
      bubbles: true,
      data: editor.innerText
    }));
    
    return '内容注入完成，共' + editor.innerText.length + '字';
  }"
}"
echo "正文注入完成"

# ============ 步骤 5: 插入 AI 推荐图片 ============
echo "[5/8] 插入 AI 推荐图片..."

# 点击 AI 创作按钮
browser act request='{
  "kind": "click",
  "ref": "AI 创作 ref"
}'

# 等待 AI 面板加载
browser act request='{"kind": "wait", "timeMs": 3000}'

# 输入关键词
browser act request="{
  \"kind\": \"type\",
  \"ref\": \"AI 输入框 ref\",
  \"text\": \"$IMAGE_KEYWORD\"
}"

# 等待推荐图片加载
browser act request='{"kind": "wait", "timeMs": 5000}'

# 点击推荐图片（可多次点击插入多张）
browser act request='{
  "kind": "click",
  "ref": "推荐图片 ref"
}'

# 关闭 AI 面板
browser act request='{
  "kind": "click",
  "ref": "关闭 AI 面板 ref"
}'

echo "AI 推荐图片插入完成"

# ============ 步骤 6: 设置封面图片 ============
echo "[6/8] 设置封面图片..."

# 点击封面替换按钮
browser act request='{
  "kind": "click",
  "ref": "封面区域 ref"
}'

# 点击免费正版图片
browser act request='{
  "kind": "click",
  "ref": "免费正版图片 ref"
}'

# 输入搜索关键词
browser act request="{
  \"kind\": \"type\",
  \"ref\": \"搜索框 ref\",
  \"text\": \"$COVER_KEYWORD\"
}"

# 等待搜索结果
browser act request='{"kind": "wait", "timeMs": 3000}'

# 选择第一张图片
browser act request='{
  "kind": "click",
  "ref": "第一张图片 ref"
}'

# 点击确定
browser act request='{
  "kind": "click",
  "ref": "确定按钮 ref"
}'

# 等待封面上传完成
browser act request='{"kind": "wait", "timeMs": 3000}'

echo "封面图片设置完成"

# ============ 步骤 7: 设置声明 ============
echo "[7/8] 设置声明..."

# 勾选头条首发
browser act request='{
  "kind": "evaluate",
  "fn": "() => {
    const elements = document.querySelectorAll(\"[role=\\\"checkbox\\\"], .checkbox\");
    for (let el of elements) {
      if (el.textContent && el.textContent.includes(\"头条首发\")) {
        el.click();
        return \"已勾选头条首发\";
      }
    }
    return \"未找到头条首发选项\";
  }"
}'

# 选择作品声明（个人观点）
browser act request='{
  "kind": "evaluate",
  "fn": "() => {
    const elements = document.querySelectorAll(\"[role=\\\"radio\\\"], .radio, [cursor=\\\"pointer\\\"]\");
    for (let el of elements) {
      if (el.textContent && el.textContent.includes(\"个人观点\")) {
        el.click();
        return \"已选择作品声明\";
      }
    }
    return \"未找到声明选项\";
  }"
}'

# 勾选引用 AI（如适用）
browser act request='{
  "kind": "evaluate",
  "fn": "() => {
    const elements = document.querySelectorAll(\"[role=\\\"checkbox\\\"], .checkbox\");
    for (let el of elements) {
      if (el.textContent && el.textContent.includes(\"引用 AI\")) {
        el.click();
        return \"已勾选引用 AI\";
      }
    }
    return \"未找到引用 AI 选项\";
  }"
}'

echo "声明设置完成"

# ============ 步骤 8: 发布 ============
echo "[8/8] 发布..."

# 点击预览并发布
browser act request='{
  "kind": "evaluate",
  "fn": "() => {
    const buttons = Array.from(document.querySelectorAll(\"button\"));
    const publishBtn = buttons.find(b => b.textContent.includes(\"预览并发布\"));
    if (publishBtn) {
      publishBtn.scrollIntoView();
      publishBtn.click();
      return \"已点击预览并发布\";
    }
    return \"未找到发布按钮\";
  }"
}'

# 等待预览页面加载
browser act request='{"kind": "wait", "timeMs": 3000}'

# 获取确认发布按钮 snapshot
browser snapshot refs=aria

# 点击确认发布
browser act request='{
  "kind": "evaluate",
  "fn": "() => {
    const buttons = Array.from(document.querySelectorAll(\"button\"));
    const confirmBtn = buttons.find(b =>
      b.textContent.includes(\"确认发布\") ||
      b.textContent.includes(\"立即发布\")
    );
    if (confirmBtn) {
      confirmBtn.click();
      return \"已确认发布\";
    }
    return \"未找到确认按钮\";
  }"
}'

# 等待发布完成
browser act request='{"kind": "wait", "timeMs": 5000}'

# ============ 验证发布结果 ============
echo "验证发布结果..."
RESULT=$(browser act request='{
  "kind": "evaluate",
  "fn": "() => {
    const url = window.location.href;
    if (url.includes(\"/manage/content\") || url.includes(\"/graphic/articles\")) {
      return { success: true, message: \"发布成功！\" };
    }
    if (url.includes(\"/publish\")) {
      return { success: false, message: \"仍在发布页面\" };
    }
    return { success: \"unknown\", url: url };
  }"
}')

echo "发布结果：$RESULT"

# ============ 完成 ============
echo "========================================"
echo "  发布完成！"
echo "========================================"
