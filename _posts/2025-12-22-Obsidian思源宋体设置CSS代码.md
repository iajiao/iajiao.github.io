---
catalog: true
date: '2025-12-22'
header-img: img/post-bg-4.jpg
image_hashes: []
layout: post
notion_id: 2d17d276-8542-8175-9450-cdf0db388b99
subtitle: 大爱思源宋体
tags:
- 网络
title: Obsidian思源宋体设置CSS代码
---

思源宋体是我近两年比较钟爱的字体，个人网站和Obsidian都是思源宋体。


为了能在Obsidian中使用思源宋体，需要采用CSS代码设置。为了确保Pc版Obsidian页面和个人网站宽度保持一致，需要Obsidian页面宽度CSS代码。


经过摸索和研究，终于成功了！以下是两段代码，留存备用参考。


## 一、Obsidian PC版使用思源宋体CSS代码


@import url('https://www.unpkg.com/font-online/fonts/SourceHanSans/SourceHanSans-Normal.otf');


.cm-sizer{ /* Screen version / font-family:'Georgia', 'Source Han Serif SC','Noto Serif SC', serif; font-style:Normal; font-size:21px; line-height:35px; font-weight:200; letter-spacing: -1px; / 设置字母间距为2像素 */ }


## 二、Obsidian PC版设置页面宽度CSS代码


body {
--file-line-width: 660px;
}