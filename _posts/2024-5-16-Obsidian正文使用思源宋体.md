---
layout: post
title: Obsidian正文使用思源宋体
subtitle: 大爱思源宋体
date: 2024-05-16
author: Ajiao
header-img: img/post-bg-4.jpg
catalog: true
tags:
  - 网络
---

在**外观设置**中选择**css片段**，具体内容如下：

```
@import url('https://www.unpkg.com/font-online/fonts/SourceHanSans/SourceHanSans-Normal.otf');

.cm-sizer{ /* Screen version */ font-family:'Georgia', 'Source Han Serif SC','Noto Serif SC', serif; font-style:Normal; font-size:21px; line-height:35px; font-weight:200; letter-spacing: -1px; /* 设置字母间距为2像素 */ }

body {
--file-line-width: 660px; 
}
```