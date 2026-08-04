---
title: Obsidian思源宋体CSS设置
subtitle: 大爱思源宋体
tags:
  - 网络
date: 2026-08-04
header-img: img/post-bg-4.jpg
layout: post
catalog: true
share: true
---
---
思源宋体是我近两年钟爱的字体，个人网站和Obsidian都是思源宋体。为了能在Obsidian使用思源宋体，需要设置CSS代码。为了确保Obsidian在PC端页面和个人网站宽度保持一致，还需要Obsidian页面宽度CSS代码。

## 更新日志

### 20260803

在小红书上刷到了开源项目obsidian quiet notes，非常欣赏作者理念。在作者源代码基础上，引入思源宋体，并调整字体到21px，更加容易阅读。

### 20260623

1.阅读模式、编辑模式和源码模式，都实现了思源宋体显示。
2.obsidian界面基本和网页界面保持一致。
3.引进了国内镜像的网络字体。
4.隐藏了笔记属性。

---
## 代码内容
```

@import url('https://fonts.useso.com/css2?family=Noto+Serif+SC:wght@400;700&display=swap');

/* ---------- 颜色：全局变量，适合在整个 Obsidian 里生效 ---------- */
.theme-light {
  --text-normal: #323232;
  --text-muted: #6b6b6b;
  --background-primary: #ffffff;
  --code-background: #f3f3f3;
  --text-highlight-bg: #ffffb4;
  --blockquote-background-color: transparent;
  --blockquote-color: #676a6f;
  --blockquote-border-color: #bfc2c4;
  --h1-color: #2a2a2a;
  --h2-color: #2a2a2a;
  --tbl-header-bg: #f3f3f3;
  --tbl-border: #e6e6e6;
}

.theme-dark {
  --text-normal: #d6d3cd;
  --text-muted: #8a8a8a;
  --background-primary: #1c1c1b;
  --code-background: #2a2a28;
  --text-highlight-bg: #8a7d3c;
  --tbl-header-bg: #2a2a28;
  --tbl-border: #3a3a38;
}

/* ---------- 正文排版：只作用在笔记正文区域 ---------- */
.markdown-source-view.mod-cm6,
.markdown-rendered {
  --font-text-size: 21px;
  --font-text: "Noto Serif SC", "Georgia", "Source Han Serif SC", "SimSun", sans-serif;
  --line-height-normal: 1.8;
  --p-spacing: 1.7em;
  --h1-size: 1.6em;
  --h1-weight: 700;
  --h2-size: 1.3em;
  --h2-weight: 650;
  --h3-size: 1.12em;
  --h3-weight: 600;
  --h4-size: 1em;
  --h4-weight: 600;
  --heading-spacing: 1.9em;
}

/* ---------- 编辑器行距 ---------- */
.markdown-source-view.mod-cm6 .cm-line {
  padding-top: 0.28em;
  padding-bottom: 0.28em;
}

/* ---------- 中文字距 ---------- */
.markdown-source-view.mod-cm6 .cm-line,
.markdown-rendered p,
.markdown-rendered li,
.markdown-rendered h1,
.markdown-rendered h2,
.markdown-rendered h3 {
  letter-spacing: 0.03em;
}

/* ---------- 下划线：限定正文区域 ---------- */
.markdown-rendered u,
.markdown-source-view u {
  text-decoration-thickness: 1px;
  text-underline-offset: 2px;
}

/* ---------- 表格：限定正文区域 ---------- */
.markdown-rendered table,
.markdown-source-view table {
  border-collapse: collapse;
  border: 1px solid var(--tbl-border);
}

.markdown-rendered th,
.markdown-rendered td,
.markdown-source-view th,
.markdown-source-view td {
  font-size: 0.92em !important;
  padding: 7px 14px !important;
  border: 1px solid var(--tbl-border);
  line-height: 1.6;
}

.markdown-rendered th,
.markdown-source-view th,
.markdown-rendered td:first-child,
.markdown-source-view td:first-child {
  background: var(--tbl-header-bg) !important;
  font-weight: 600;
}

.markdown-rendered td:focus,
.markdown-rendered th:focus,
.markdown-source-view td:focus-within,
.markdown-source-view th:focus-within {
  box-shadow: inset 0 0 0 1px #323232;
  outline: none;
}

/* ---------- 分隔线：限定正文区域 ---------- */
.markdown-rendered hr,
.markdown-source-view .cm-hr {
  border: none !important;
  border-top: 1px solid var(--tbl-border) !important;
  height: 0 !important;
  background: none !important;
}

/* ---------- 高亮：限定正文区域 ---------- */
.markdown-rendered mark {
  background: var(--text-highlight-bg);
}

/* ---------- 引用块 ---------- */
.markdown-rendered blockquote {
  background: transparent;
  color: var(--blockquote-color);
  border-left: 3px solid var(--blockquote-border-color);
}

```
