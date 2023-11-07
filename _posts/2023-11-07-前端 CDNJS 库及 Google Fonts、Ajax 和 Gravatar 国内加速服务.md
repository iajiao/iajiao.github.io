---
layout:     post
title:     Google font 加速访问
subtitle:   前端 CDNJS 库及 Google Fonts、Ajax 和 Gravatar 国内加速服务
date:       2023-11-07
author:     BY
header-img: img/post-bg-4.png
catalog:   true
tags:
    - 网络
---

Via:[烧饼博客](https://u.sb/css-cdn/)

由于某些众所周知的原因，好多开源的 JS 库采用的国外 CDN 托管方式在国内访问速度不如人意。所以我们特意制作了这个公益项目，托管了 CDNJS 的所有开源 JS 库以及反代了 Google Fonts、Ajax 和 Gravatar。

## 1.CDNJS 开源 JS 库
我们采用的方法是每天定时同步 CDNJS 的 Github

所有的 JS/CSS 库可以在这儿找到您需要的链接

https://cdnjs.loli.net/ajax/libs/

如果您使用 cdnjs.com 只需要替换 cdnjs.cloudflare.com 为 cdnjs.loli.net 即可，如


```
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
```

替换成


```
<script src="https://cdnjs.loli.net/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
```

CDNJS 的 API 开发文档请摸这里

## 2.Google Fonts
我们采用的方法是万能的 Nginx 反代 + 关键词替换

使用的时候，您只需要替换 fonts.googleapis.com 为 fonts.loli.net 即可，如


```
<link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet">
```

替换成


```
<link href='https://fonts.loli.net/css?family=Open+Sans' rel='stylesheet'>
```

如果需要 Material icons，把


```
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
```

替换成


```
<link href="https://fonts.loli.net/icon?family=Material+Icons" rel="stylesheet">
```

如果需要 Early Access，把

```
@import url(https://fonts.googleapis.com/earlyaccess/notosanskannada.css);
```
替换成
```
@import url(https://fonts.loli.net/earlyaccess/notosanskannada.css);
```
如果需要下载单个字体，您只需要把 fonts.gstatic.com 替换成 gstatic.loli.net 或 themes.googleusercontent.com 替换成 themes.loli.net 即可

比如
```

https://fonts.gstatic.com/s/opensans/v14/K88pR3goAWT7BTt32Z01mxJtnKITppOI_IvcXXDNrsc.woff2
```
替换成

```
https://gstatic.loli.net/s/opensans/v14/K88pR3goAWT7BTt32Z01mxJtnKITppOI_IvcXXDNrsc.woff2
```
或者

```
https://themes.googleusercontent.com/static/fonts/anonymouspro/v3/Zhfjj_gat3waL4JSju74E-V_5zh5b-_HiooIRUBwn1A.ttf
```
替换成

```
https://themes.loli.net/static/fonts/anonymouspro/v3/Zhfjj_gat3waL4JSju74E-V_5zh5b-_HiooIRUBwn1A.ttf
```
Google Fonts 的 API 文档请摸这里

##  3.Google 前端公共库
方法同上，直接替换 ajax.googleapis.com 为 ajax.loli.net 即可，如
```
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
```
替换成
```
<script type="text/javascript" src="https://ajax.loli.net/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
```
Google 前端库 API 开发文档摸这儿

## 4.Gravatar 头像
方法还是同上，直接替换 *.gravatar.com 为 gravatar.loli.net 即可，如
```
https://secure.gravatar.com/avatar/8406d089bc81b664a2610b8d214c1428
```
替换成
```
https://gravatar.loli.net/avatar/8406d089bc81b664a2610b8d214c1428
```
## 5.赞助商
国内外 CDN，GeoDNS、域名、SSL 证书等基础服务均由 Riven Cloud 赞助

## 6.加速域名列表
所有国内加速服务的域名列表如下，您只需要修改程序里的原域名即可

 **原域名	| 加速域名 | 制作方法**
> cdnjs.cloudflare.com	cdnjs.loli.net	每日同步 Github
> ajax.googleapis.com	ajax.loli.net	Nginx 反代
> fonts.googleapis.com	fonts.loli.net	Nginx 反代
> fonts.gstatic.com	gstatic.loli.net	Nginx 反代
> themes.googleusercontent.com	themes.loli.net	Nginx 反代
> secure.gravatar.com	gravatar.loli.net	Nginx 反代 如果遇到任何问题，请联系我们

***注意：***个别国内的网络环境可能无法使用本服务，我们也暂时没有办法解决这个问题，请自行检查或更换运营商。
