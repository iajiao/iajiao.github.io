---
layout: post
title: 修改hpst解决github访问难题
subtitle: 
date: 2023-12-31
author: Ajiao
header-img: img/post-bg-3.jpg
catalog: true
tags:
  - 学习
---
### Github访问不上，怎么办？

#### 找到解析时间最短的地址

> [Ping.cn](https://www.ping.cn/dns/github.com)

点击DNS查询，点击A记录，查找解析时间最短的网址。
#### 修改配置文件

在C:\Windows\System32\drivers\etc文件夹下修改或者添加host
(路径应该是这样C:\Windows\System32\drivers\etc\host)：

> 一般格式 ip+空格+github.com，切记不要加www
192.30.255.112  github.com git 
185.31.16.184 github.global.ssl.fastly.net  12

#### 刷新配置

打开cmd 输入 ipconfig /flushdns 刷新网络
>ipconfig /flushdns
