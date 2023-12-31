---
layout: post
title: 修改Host解决Github访问难题
subtitle: Github无法访问，怎么办？
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

![](https://img-blog.csdnimg.cn/20210530001706605.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3l3OTk5OTk=,size_16,color_FFFFFF,t_70#pic_center)
#### 修改配置文件

在C:\Windows\System32\drivers\etc文件夹下修改或者添加host
(路径应该是这样C:\Windows\System32\drivers\etc\host)：

一般格式 ip+空格+github.com，切记不要加www
> 192.30.255.112  github.com git 
185.31.16.184 github.global.ssl.fastly.net  12

#### 刷新配置

打开cmd 输入 ipconfig /flushdns 刷新网络
>ipconfig /flushdns
