---
layout: post
title: Obsidian+Git维护Hexo博客
subtitle: 转载自知乎专栏：晚阳Crown
date: 2023-12-22
author: Ajiao
header-img: img/post-bg-4.jpg
catalog: true
tags:
  - 工作
---
## 0.简介

Obsidian是一款非常强大的Markdown编辑器与知识管理工具，得益于其优秀的笔记双向链接与检索功能、以及丰富的插件生态，能让我们高效地写文章与维护我们的博客。

## 1.Obsidian知识库创建

首先将我们的博客作为一个Obsidian知识库打开：

![](https://pic2.zhimg.com/80/v2-808349d23432c729b1fa252b2adb871d_1440w.webp)

![](https://pic3.zhimg.com/80/v2-c542e5b253d91ee2a630868d0361992e_1440w.webp)

打开成功后，你根目录会生成一个`.obsidian`文件夹，它的作用是记录了你的设置以及在这个知识库里装的一些插件，在别的设备打开这个知识库就不用重新配置了

![](https://pic3.zhimg.com/80/v2-e2253f987e637a13f227783fb84329b2_1440w.webp)

如果你已经有一个库了，也可以像我一样，直接把博客丢进来

![](https://pic2.zhimg.com/80/v2-d16ac4cb8fb538fb8b31c5c52a8bbdcd_1440w.webp)

## 2.忽略多余的文件

我们主要是编辑和管理Markdown文件，所以一些多余的文件要忽略掉，这样在知识库里搜索文件、关键字时才不会搜索到多余的，也能有效提高检索效率。

打开 设置>文件与链接>Exclude Files

![](https://pic4.zhimg.com/80/v2-900528397ed2e28d7872167e5901b58f_1440w.webp)

文章都在source下，所以只保留source，其它的忽略掉

![](https://pic2.zhimg.com/80/v2-4d76f6eb3bb872b1e8c802ed8b09bf59_1440w.webp)

## 3.博客文章管理

### 3.1 新建文章

新建Markdown文件就很方便了：

![](https://pic1.zhimg.com/80/v2-aa0ec13a5cdb5bfbcc28904458bccbd0_1440w.webp)

可以设置下新建Markdown文件生成的位置：

![](https://pic1.zhimg.com/80/v2-d8fc7fd0bee9ee215cb94684709bd0f4_1440w.webp)

### 3.2 快速插入Front-matter模板

Obsidian有一个模板功能，允许我们预先写好一些内容模板，写文章时可以随时快捷插入。

在核心插件中开启模板功能：

![](https://pic4.zhimg.com/80/v2-742004f56bb75d5f27cf1da51c4258ab_1440w.webp)

打开模板插件的设置界面，设置模板文件夹位置以及日期格式：

![](https://pic1.zhimg.com/80/v2-2133f7667b1acb270601c427f3238bf0_1440w.webp)

编写Front-matter模板：

![](https://pic1.zhimg.com/80/v2-efebbbce47c7eee75f43deba12201ed4_1440w.webp)

在左侧菜单栏中点插入模板：

![动图封面](https://pic4.zhimg.com/v2-4ccd75ba7f6b8ffa7f613a4b4c8e2ce7_b.jpg)

### 3.3 发布文章

发布文章到博客，也就是把写好的文章移动到`source/_posts`目录下即可：

![动图封面](https://pic4.zhimg.com/v2-6e1cc2122f673539e4c7787852530677_b.jpg)

## 4.Obsidian Git插件的使用

Obsidian知识库多端同步，我之前一直用的方案是OnDrive，除了.obsidian文件夹下个别文件会出现冲突以外，各方面都挺不错的。但是现在加入了Hexo博客后，冲突恐怕会更多，OnDrive没法处理，显然用Git来管理会更好，还有Hexo博客要部署到服务器一般也是用Git。

得益于Obsidian强大的插件生态，我们可以在Obsidian中直接操作Git，用到的是一款社区插件，叫做Obsidian Git

### 4.1 安装

先设置里启用社区插件功能，然后再搜索安装即可：

![](https://pic1.zhimg.com/80/v2-46d6e7afc88693366d1072ccc5d9415c_1440w.webp)

要确保知识库是一个Git仓库，打开才不会报如下错误：

![](https://pic2.zhimg.com/80/v2-992f92898fc66c7ed35c765891aec9dd_1440w.webp)

### 4.2 忽略配置

根目录创建一个`.gitignore`，忽略掉`.obsidian/workspace`

![](https://pic4.zhimg.com/80/v2-9e0180eee5f0181ce2d560415b432c4f_1440w.webp)

Hexo博客目录下创建`.gitignore`

![](https://pic4.zhimg.com/80/v2-9518869b4437dc34dc4e98672abfebc3_1440w.webp)

```text
.DS_Store
Thumbs.db
db.json
*.log
node_modules/
public/
.deploy*/
_multiconfig.yml
```

### 4.3 使用

打开插件设置界面，可以修改一下自动提交和手动提交的日志，我设置的是主机名+日期：

![](https://pic4.zhimg.com/80/v2-d0cbb2096d0d00b7ce9bae0a0be12d7f_1440w.webp)

在提交信息设置里，可以修改主机名和日期格式，修改完成后点Preview可以预览提交信息：

![](https://pic1.zhimg.com/80/v2-ed85b2cfd96b49fb585ce6c53540546c_1440w.webp)

快捷键`Ctrl + P`打开命令面板，输入open source control view启用可视化操作面板：

![](https://pic3.zhimg.com/80/v2-89cdeae0243f8408942f907f6e408c16_1440w.webp)

然后在右侧菜单栏就可以看到操作面板了：

![](https://pic2.zhimg.com/80/v2-f66914a218aef13bfd13a8f5fc2a11e9_1440w.webp)

一般操作就是：保存所有>提交>推送，就可以更新到Git服务器了，如下图顺序

![](https://pic4.zhimg.com/80/v2-502923ac636c2656ff988688bfd3530f_1440w.webp)

启用自动拉取功能，每次打开知识库就会自动拉取：

![](https://pic2.zhimg.com/80/v2-113deb621682d3dd75469f0cecb31bd5_1440w.webp)

如果在使用过程中有报错的话，`Ctrl+Shift+I`在控制台里可以查看详细日志，所有插件的日志都可以在这里看到：

![](https://pic3.zhimg.com/80/v2-eb9244e2e9af2e310d219ac95c429cae_1440w.webp)

## 5.自动更新Front-matter分类信息

前文我们实现了Front-matter模板的快速插入，但是有些变量如categories还是需要手动维护。结合Obsidian，最好的方案就是我们通过文件夹来对文章进行分类，然后自动生成和更新Front-matter的分类信息。

### 5.1 hexo-auto-category安装与配置

这里我们使用的是[hexo-auto-category](https://link.zhihu.com/?target=https%3A//github.com/xu-song/hexo-auto-category)这个基于文件夹自动分类的插件，安装：

```bash
npm install hexo-auto-category --save
```

在站点配置文件中添加配置：

```text
# Generate categories from directory-tree
# Dependencies: https://github.com/xu-song/hexo-auto-category
# depth: the max_depth of directory-tree you want to generate, should > 0

auto_category:
 enable: true
 depth:
```

### 5.2 利用Git钩子函数触发更新

这个插件只有执行`hexo generate`时才会去读取文件夹并更新所有文章的Front-matter分类信息，所以我们可以利用[Git的钩子函数](https://link.zhihu.com/?target=https%3A//git-scm.com/book/zh/v2/%25E8%2587%25AA%25E5%25AE%259A%25E4%25B9%2589-Git-Git-%25E9%2592%25A9%25E5%25AD%2590%23_git_hooks)，在commit的时候先执行下`hexo generate`，这样就能实现自动更新了。

在`.git/hooks`目录下新建一个`pre-commit`文件，也可以执行`touch pre-commit`命令新建该文件：

![](https://pic1.zhimg.com/80/v2-1af4421003f60d164d14afae8964bcc4_1440w.webp)

可以先在该文件中写入`echo hello world!`，然后执行`sh pre-commit`或者`./pre-commit`测试钩子能不能正常执行：

![](https://pic1.zhimg.com/80/v2-7eab3c1ef7cf009a98e3535265cd3560_1440w.webp)

没问题后，将如下命令写到文件里：

```bash
#!/bin/sh
cd Blog && hexo generate && git add .
```

1. 由于我的博客不是在根目录，所以需要`cd Blog`进入到博客目录再执行`hexo generate`
2. 之所以后面追加`git add .`，是因为generate后，所有文章的Front-matter信息会更新，所以要将所有修改重新添加进来
3. 注意第一行一定要加上`#!/bin/sh`，这个不是注释！

## 6.快捷操作

Obsidian中通过URL可以访问链接或打开文件，所以我们可以在根目录创建一个Markdown文件，相当于我们知识库的主页，把一些常用的链接放这里，方便快速访问：

![](https://pic4.zhimg.com/80/v2-cb70d5af53d3dca16d3307715734311b_1440w.webp)

> **在写URL的时候要注意：如果路径有空格的话，要替换为%20**

### 6.1 快捷打开站点或主题配置文件

站点配置文件和主题配置文件是我们DIY博客经常要编辑的两个文件，在Obsidian中没法编辑yml文件，可以通过URL来打开yml文件，会自动调用默认的编辑器打开。

在主页Markdown中，按Ctrl+K插入链接，写入我们两个配置文件所在的相对路径：

```bash
[打开站点配置文件](Blog/_config.yml)
[打开主题配置文件](Blog/themes/butterfly4.3.1/_config.yml)

# 或者写成Obsidian URI的形式
[打开站点配置文件](obsidian://open?file=Blog/_config.yml)
[打开主题配置文件](obsidian://open?file=Blog/themes/butterfly4.3.1/_config.yml)
```

效果演示：

![动图封面](https://pic3.zhimg.com/v2-5cb70e380f63d3f9b6efa2ffcfcfd31e_b.jpg)

### 6.2 快捷运行博客

我们还可以运行bat文件来执行一些命令，比如运行我们的博客了。

在我们的Hexo博客目录下，创建一个`RunBlog.bat`文件，写入以下命令：

```bash
start http://localhost:4000/
hexo s
```

然后在我们的主页添加链接：

```bash
[运行博客](Blog/RunBlog.bat)

# 或者
[运行博客](obsidian://open?file=Blog/RunBlog.bat)
```

效果演示：（测试完成后，按两次Ctrl+C关闭）

![动图封面](https://pic1.zhimg.com/v2-d4a743b77ff755ed02fc2c190ac5d4f0_b.jpg)

### 6.3 优化方案

### 6.3.1 嵌入文件

觉得链接太小了不好点击？Obsidian嵌入文件完美解决，只需在链接前加上感叹号!（注意嵌入文件的链接就不能用Obsidian URI的形式了）

```text
![打开站点配置文件](Blog/_config.yml)
![打开主题配置文件](Blog/themes/butterfly4.3.1/_config.yml)
![运行博客](Blog/RunBlog.bat)
```

是不是瞬间舒服多了？

![](https://pic4.zhimg.com/80/v2-784ad18ff3fd1d1d5234dfc806aaadcb_1440w.webp)

### 6.3.2 Button插件

除了嵌入文件外，别忘了Obsidian还有强大的社区插件库，Button插件也可以满足需求：

![](https://pic3.zhimg.com/80/v2-4dc1f7c123d2159595d5901873eb39be_1440w.webp)

Ctrl+P打开命令面板，搜索并打开Button Maker：

![](https://pic3.zhimg.com/80/v2-b8cd4039fa0bbc4f0260b772d3df59be_1440w.webp)

设置按钮信息：

- 按钮类型（也就是功能）选择Link - open a url or uri
- 链接可以使用`file://`或者[Obsidian URI](https://link.zhihu.com/?target=https%3A//help.obsidian.md/Advanced%2Btopics/Using%2Bobsidian%2BURI)，这个时候后者的好处就体现出来了，因为`file://`只能用绝对路径，例如`file://C:\Users\GavinCrown\Desktop\SecondBrain\Blog\_config.yml`，意味着每换一台设备你的链接就得改一次。

![](https://pic3.zhimg.com/80/v2-8e5afcf7cbb01f7eedf328e12ca9c1a6_1440w.webp)

设置完成后，点Insert Button就可以将按钮插入到当前Markdown文件中：

![](https://pic2.zhimg.com/80/v2-01d3ab2eb668643b1c1b4fb213691a45_1440w.webp)

![](https://pic3.zhimg.com/80/v2-c510b06e38c7f8db8cd078af788bf87a_1440w.webp)

### 6.3.3 Shell commands插件

再介绍个终极优化方案，之前我们执行命令是通过运行bat文件，而Shell commands可以在Obsidian中设置好命令，并通过Obsidian的命令面板或快捷键快速运行。

![](https://pic4.zhimg.com/80/v2-a579b34c2402729861c2be558bdfb247_1440w.webp)

在插件设置面板中添加命令：

![](https://pic3.zhimg.com/80/v2-f4b041dd0aaf01f3a86e2718462547ca_1440w.webp)

运行博客：

- Shell commands没有显示终端窗口的功能，所以需要我们启动powershell再传入命令
- 有了终端窗口我们才可以在窗口中按Ctrl + C关闭Hexo服务，否则它会一直占用端口

```bash
start powershell '-NoExit -Command start http://localhost:4000 ; cd Blog ; hexo s'
```

打开站点和主题配置文件：

```text
start Blog/_config.yml
start Blog/themes/butterfly4.3.1/_config.yml
```

然后修改默认执行环境为PowerShell 5：

![](https://pic1.zhimg.com/80/v2-3561fa18b0ba16fa41444591b01fd26c_1440w.webp)

点这个按钮可以执行测试我们的命令：

![](https://pic3.zhimg.com/80/v2-c204e805f9e56f69849284e950d50832_1440w.webp)

如果你遇到了这个错误：`hexo:无法加载文件 C:\Users\xxx\AppData\Roaming\npm\hexo.ps1，因为在此系统上禁止运行脚本。`只需在Windows设置>更新和安全>开发者选项，找到PowerShell，点下应用即可：

![](https://pic4.zhimg.com/80/v2-114a5d6d9c9c05a44c0838a578488d27_1440w.webp)

Ctrl+P打开命令面板，输入Shell commands即可找到我们定义好的命令：

![](https://pic3.zhimg.com/80/v2-cb7def9bfb09a1f311d588116168593e_1440w.webp)

可以为每个命令设置下别名，就是在命令面板显示的名字：

![](https://pic1.zhimg.com/80/v2-bd8b6dc91a000281e82f6e409974931c_1440w.webp)

![](https://pic3.zhimg.com/80/v2-044211d6000cee24a31a0ba2a0fa5a76_1440w.webp)

在Hotkeys面板中为我们的命令设置好快捷键，就可以通过快捷键快速执行命令了：

![](https://pic1.zhimg.com/80/v2-53ea25309ccc79fdaabdabfa9bbaf658_1440w.webp)

## 7.参考

[Hexo + Obsidian + Git 完美的博客部署与编辑方案>EsunR-Blog](https://link.zhihu.com/?target=https%3A//blog.esunr.xyz/2022/07/e9b42b453d9f.html)