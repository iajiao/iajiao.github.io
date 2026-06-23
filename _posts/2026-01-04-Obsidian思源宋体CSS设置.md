---
title: Obsidian思源宋体CSS设置
subtitle: 大爱思源宋体
tags:
  - 网络
date: 2026-06-23
header-img: img/post-bg-4.jpg
layout: post
catalog: true
share: true
---
思源宋体是我近两年比较钟爱的字体，个人网站和Obsidian都是思源宋体。

为了能在Obsidian中使用思源宋体，需要采用CSS代码设置。为了确保Pc版Obsidian页面和个人网站宽度保持一致，需要Obsidian页面宽度CSS代码。

经过摸索和研究，终于成功了！以下是两段代码，留存备用参考。

## 一、Obsidian PC版使用思源宋体CSS代码

```
 @import url('https://www.unpkg.com/font-online/fonts/SourceHanSans/SourceHanSans-Normal.otf');
 
.cm-sizer{ /* Screen version */ font-family:'Georgia', 'Source Han Serif SC','Noto Serif SC', serif; font-style:Normal; font-size:21px; line-height:35px; font-weight:200; letter-spacing: -1px; /* 设置字母间距为2像素 */ }
```

## 二、Obsidian PC版设置页面宽度CSS代码

body {
 --file-line-width: 660px; 
 }
## 三、2026年6月23日优化代码

主要优化方向：
1.阅读模式、编辑模式和源码模式，都实现了思源宋体显示。
2.obsidian界面基本和网页界面保持一致。
3.引进了国内镜像的网络字体。
4.隐藏了笔记属性。

```
/* =========================================
  引入网络字体 (国内 360 镜像源)
========================================= */
@import url('https://fonts.useso.com/css2?family=Noto+Serif+SC:wght@400;700&display=swap');

/* =========================================
  排版核心规则 (去掉首行缩进版本)
========================================= */

body {
    /* 【中文】思源宋体网络版，【英文】Georgia，【数字】Times New Roman */
    --font-text-theme: "Noto Serif SC", "Georgia", "Times New Roman", "source-han-serif-sc", "SimSun", "宋体", serif;
    
    --font-size-paper: 21px;
    --line-height-paper: 35.007px;
    --text-ink: #000000; 
    --bg-color: #ffffff; 
}

/* 2. 核心正文样式 */
.markdown-source-view.mod-cm6 .cm-line,
.markdown-reading-view .markdown-preview-view p {
    font-family: var(--font-text-theme) !important;
    font-size: var(--font-size-paper) !important;
    line-height: var(--line-height-paper) !important;
    color: var(--text-ink) !important;
    font-weight: 400 !important;
    text-align: left !important;
    letter-spacing: 0 !important; /* 字间距 0，极度紧密 */
    text-indent: 0 !important; 
}

/* 3. 列表项保持正常 */
.markdown-reading-view .markdown-preview-view li,
.markdown-source-view.mod-cm6 .cm-line.cm-hmd-list {
    text-indent: 0 !important; 
    letter-spacing: 0 !important; /* 列表项字间距 0 */
}

/* 4. 强制正文中的数字使用 Times New Roman */
.markdown-source-view.mod-cm6 .cm-number,
.markdown-reading-view .markdown-preview-view .cm-number {
    font-family: "Times New Roman", "Georgia", serif !important;
}

/* 5. 代码块与内联代码 */
.markdown-source-view.mod-cm6 .cm-line.cm-hmd-codeblock,
.markdown-reading-view .markdown-preview-view code,
.cm-s-obsidian span.cm-inline-code {
    font-family: "Consolas", "Monaco", "JetBrains Mono", monospace !important;
    font-size: 17px !important;
    line-height: 1.6 !important;
    color: #000000 !important;
    background-color: #f5f5f5 !important;
    text-indent: 0 !important;
    /* 代码块通常保持自身的等宽字体间距，不强行设 0，避免挤在一起 */
}

/* 6. 标题字体与排版 */
.markdown-source-view.mod-cm6 .cm-header,
.markdown-reading-view .markdown-preview-view h1,
.markdown-reading-view .markdown-preview-view h2,
.markdown-reading-view .markdown-preview-view h3,
.markdown-reading-view .markdown-preview-view h4,
.markdown-reading-view .markdown-preview-view h5,
.markdown-reading-view .markdown-preview-view h6 {
    font-family: var(--font-text-theme) !important;
    color: #000000 !important;
    font-weight: 700 !important;
    text-indent: 0 !important;
}

/* ================================================================
   【布局控制区】700px 居中
   ================================================================ */

/* 1. 兜底：强制外层容器居中 */
.markdown-preview-view,
.markdown-source-view.mod-cm6 .cm-scroller,
.markdown-reading-view .markdown-preview-view {
    display: flex !important;
    flex-direction: column !important;
    align-items: center !important;
    padding: 0 !important;
}

/* 2. 强制内容块自身居中并锁定 700px */
.markdown-reading-view .markdown-preview-view.is-readable-line-width .markdown-preview-section,
.markdown-source-view.mod-cm6.is-readable-line-width .cm-content,
.markdown-reading-view .markdown-preview-view:not(.is-readable-line-width) .markdown-preview-section,
.markdown-reading-view .markdown-preview-view .markdown-preview-section {
    max-width: 695px !important; 
    width: 100% !important;
    margin: 0 auto !important;   
    padding: 20px 0 40px 0 !important;
}

/* 3. 修复标题区域 */
.markdown-reading-view .markdown-preview-view .page-header,
.markdown-source-view.mod-cm6 .cm-line .page-header,
.inline-title,
.markdown-reading-view .markdown-preview-view h1 {
    max-width: 700px !important;
    width: 100% !important;
    margin: 0 auto 5px auto !important;
    padding: 0 !important;
}

/* 4. 隐藏错位的【笔记属性】栏 */
.metadata-container,
.metadata-properties,
.metadata-properties-title {
    display: none !important;
}

/* 5. 纯白背景 */
body, .workspace, .view-content, 
.markdown-source-view, .markdown-reading-view,
.markdown-source-view.mod-cm6 .cm-content,
.markdown-reading-view .markdown-preview-view,
.markdown-source-view.mod-cm6 .cm-scroller {
    background-color: var(--bg-color) !important;
}

/* ================================================================
   6. 手机端智能适配优化
   ================================================================ */
@media screen and (max-width: 768px) {
    
    .markdown-source-view.mod-cm6 .cm-line,
    .markdown-reading-view .markdown-preview-view p,
    .markdown-reading-view .markdown-preview-view li {
        font-size: 17px !important; 
        line-height: 28px !important;
        letter-spacing: 0 !important; /* 手机端同样字间距 0 */
    }

    /* 手机端取消 700px 限制 */
    .markdown-reading-view .markdown-preview-view.is-readable-line-width .markdown-preview-section,
    .markdown-source-view.mod-cm6.is-readable-line-width .cm-content,
    .markdown-reading-view .markdown-preview-view:not(.is-readable-line-width) .markdown-preview-section,
    .markdown-reading-view .markdown-preview-view .markdown-preview-section {
        max-width: 100% !important; 
        width: 100% !important;
        margin: 0 !important;
        padding: 10px 15px 20px 15px !important;
    }
    
    /* 手机端标题区域撑满 */
    .markdown-reading-view .markdown-preview-view .page-header,
    .markdown-source-view.mod-cm6 .cm-line .page-header,
    .inline-title {
        max-width: 100% !important;
        margin: 0 auto 5px auto !important;
        padding: 0 15px !important;
    }

    .markdown-source-view.mod-cm6 .cm-line.cm-hmd-codeblock,
    .markdown-reading-view .markdown-preview-view code {
        font-size: 14px !important;
        line-height: 1.5 !important;
    }
    
    .markdown-source-view.mod-cm6 .cm-header,
    .markdown-reading-view .markdown-preview-view h1,
    .markdown-reading-view .markdown-preview-view h2,
    .markdown-reading-view .markdown-preview-view h3,
    .markdown-reading-view .markdown-preview-view h4 {
        font-size: 22px !important;
    }
}
```

