---
catalog: true
date: '2025-03-16'
header-img: img/post-bg-3.jpg
layout: post
notion_id: 1b87d276-8542-8017-a8c5-cb3dbfa9be6d
subtitle: 让 notion 作为 jekyll 后台
tags:
- 网络
title: Notion to Github 工作流代码开发
---

我的博客使用Jekyll 技术，建立在Github Pages上。GitHub非常稳定，但没有后台，更新起来非常麻烦。之前我曾使用Obsidian 作为 Github 后台。虽然Obsidian堪称神器，但仅限于电脑端。在安卓手机上，不仅难以操作，而且启动速度很慢。


最近，我发现Notion 在安卓端用起来特别顺手，主要是不用配置同步，而且移动端 App 尚可。 突发奇想：能否用Notion作为博客后台，实现与Github的互动呢？答案是肯定的！


# v1 版本出炉


在Deepseek的帮助下，经过大约10个小时的努力，或者说是开发吧！准确得说是：罗马输球后睡不着的大半个晚上，以及小半个白天，终于通过编写 Github Action代码，实现了Notion与Github的互动，简称 V1 版本，主要实现了博客内容从 Notion 到 Github 的同步。


```yaml
name: Notion to Jekyll Sync v1
on:
  schedule:
    - cron: "0 12 * * *"  # 每天 UTC 时间 12 点自动同步
  workflow_dispatch:       # 支持手动触发

jobs:
  sync-notion-pages:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Python 3.10
        uses: actions/setup-python@v4
        with:
          python-version: "3.10"

      - name: Install dependencies
        run: |
          pip install \
            notion-client==2.2.0 \
            python-frontmatter==1.0.0 \
            requests==2.31.0 \
            mdutils==1.5.0 \
            --index-url https://pypi.tuna.tsinghua.edu.cn/simple \
            --trusted-host pypi.tuna.tsinghua.edu.cn \
            --no-cache-dir

      - name: Convert Notion pages to Jekyll posts
        env:
          NOTION_TOKEN: ${{ secrets.NOTION_TOKEN }}
          NOTION_DATABASE_ID: ${{ secrets.NOTION_DATABASE_ID }}
        run: |
          cat << 'EOF' > notion_to_jekyll.py
          import os
          import logging
          from notion_client import Client
          import frontmatter
          from mdutils import MdUtils
          import requests

          logging.basicConfig(level=logging.INFO)
          logger = logging.getLogger(__name__)

          def get_page_content(page_id):
              """通过 Notion API 获取页面内容（含递归子块解析）"""
              try:
                  blocks = []
                  client = Client(auth=os.environ["NOTION_TOKEN"])
                  result = client.blocks.children.list(block_id=page_id)
                  while True:
                      blocks.extend(result.get("results", []))
                      if not result.get("has_more"):
                          break
                      result = client.blocks.children.list(
                          block_id=page_id,
                          start_cursor=result.get("next_cursor")
                      )
                  return "\n\n".join([_parse_block(b) for b in blocks])  # 修改点：双换行拼接
              except Exception as e:
                  logger.error(f"获取内容失败: {str(e)}")
                  return ""

          def _parse_block(block):
              """解析 Notion 块为 Markdown（支持更多类型）"""
              type_ = block["type"]
              content = block[type_]
              text = "".join([t["plain_text"] for t in content.get("rich_text", [])])
              
              # 段落与标题处理
              if type_ == "paragraph":
                  return text + "\n"  # 修改点：追加换行
              elif type_ == "heading_1":
                  return f"# {text}\n"
              elif type_ == "heading_2":
                  return f"## {text}\n"
              elif type_ == "heading_3":
                  return f"### {text}\n"
              elif type_ == "bulleted_list_item":
                  return f"- {text}\n"
              elif type_ == "numbered_list_item":
                  return f"1. {text}\n"
              # 图片处理
              elif type_ == "image":
                  url = content.get("external", {}).get("url") or content.get("file", {}).get("url")
                  return f"![]({url})\n"
              # 代码块处理
              elif type_ == "code":
                  code = "\n".join([t["plain_text"] for t in content["rich_text"]])
                  return f"```{content['language']}\n{code}\n```\n"
              # 引用块处理
              elif type_ == "quote":
                  return f"> {text}\n"
              return ""

          def main():
              notion = Client(auth=os.environ["NOTION_TOKEN"])
              database_id = os.environ["NOTION_DATABASE_ID"]

              try:
                  pages = notion.databases.query(
                      database_id,
                      filter={"property": "Status", "select": {"equals": "Published"}}
                  ).get("results", [])
              except Exception as e:
                  logger.error(f"数据库查询失败: {str(e)}")
                  return

              for page in pages:
                  try:
                      # 提取基础字段
                      title = page["properties"]["Title"]["title"][0]["plain_text"].strip()
                      date_str = page["properties"]["Date"]["date"]["start"].split("T")[0]

                      # 修改点：Header Image 字段处理
                      header_img = page["properties"].get("Header-img", {}).get("rich_text", [{}])[0].get("plain_text", "").strip()
                      
                      subtitle = page["properties"].get("Subtitle", {}).get("rich_text", [{}])[0].get("plain_text", "").strip()
                      catalog = page["properties"].get("Catalog", {}).get("checkbox", False)
                      tags = [tag["name"] for tag in page["properties"].get("Tags", {}).get("multi_select", [])]

                      content = get_page_content(page["id"])
                      post = frontmatter.Post(content)
                      post["title"] = title
                      post["subtitle"] = subtitle
                      post["date"] = date_str
                      post["layout"] = "post"
                      post["header-img"] = header_img  # 确保这里字段名与配置一致
                      post["catalog"] = catalog
                      post["tags"] = tags

                      filename = f"_posts/{date_str}-{title.replace(' ', '-')}.md"
                      with open(filename, "w", encoding="utf-8") as f:
                          f.write(frontmatter.dumps(post))
                      logger.info(f"成功生成: {filename}")

                  except Exception as e:
                      logger.error(f"处理失败: {str(e)} (Page ID: {page['id']})")

          if __name__ == "__main__":
              main()
          EOF

          python notion_to_jekyll.py

      - name: Commit changes
        uses: stefanzweifel/git-auto-commit-action@v4
        with:
          commit_message: "Auto-sync from Notion"
          file_pattern: "_posts/*"

```


# v2 版本出炉


然而，我的需求并非仅仅只是同步，我还想实现增量同步提高效率，通过 Notion管理文档，以便执行删除和更新等操作，还想提高代码运行效率。经过周五晚间和周六全天的尝试，终于成功了！这个版本简称 V2。


除 DeepSeek 外，Kimi在代码完善的过程中也提供了巨大的帮助，主要是 DeepSeek容易出现幻觉，代码前后一致性差一些，特别是代码融合时会漏掉内容，运行经常出错，Kimi 好很多。


```yaml
name: Notion to Jekyll Sync v2
on:
  schedule:
    - cron: "0 12 * * *"  # 每天 UTC 时间 12 点自动同步
  workflow_dispatch:       # 支持手动触发

jobs:
  sync-notion-pages:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Python 3.10
        uses: actions/setup-python@v4
        with:
          python-version: "3.10"

      - name: Install dependencies
        run: |
          pip install --cache-dir=/tmp/pip-cache \
            notion-client==2.2.0 \
            python-frontmatter==1.0.0 \
            requests==2.31.0 \
            mdutils==1.5.0 \
            --index-url https://pypi.tuna.tsinghua.edu.cn/simple \
            --trusted-host pypi.tuna.tsinghua.edu.cn

      - name: Convert Notion pages to Jekyll posts
        env:
          NOTION_TOKEN: ${{ secrets.NOTION_TOKEN }}
          NOTION_DATABASE_ID: ${{ secrets.NOTION_DATABASE_ID }}
        run: |
          cat << 'EOF' > notion_to_jekyll.py
          import os
          import logging
          import json
          from datetime import datetime
          from notion_client import Client
          import frontmatter
          from mdutils import MdUtils
          import requests
          import glob
          import shutil

          logging.basicConfig(level=logging.INFO)
          logger = logging.getLogger(__name__)

          # 读取上次同步的时间戳
          def get_last_sync_time():
              try:
                  with open('.last_sync.txt', 'r') as f:
                      return datetime.fromisoformat(f.read().strip())
              except:
                  return None

          # 保存本次同步的时间戳
          def save_last_sync_time():
              with open('.last_sync.txt', 'w') as f:
                  f.write(datetime.now().isoformat())

          def get_page_content(page_id):
              """通过 Notion API 获取页面内容（含递归子块解析）"""
              try:
                  blocks = []
                  client = Client(auth=os.environ["NOTION_TOKEN"])
                  result = client.blocks.children.list(block_id=page_id)
                  while True:
                      blocks.extend(result.get("results", []))
                      if not result.get("has_more"):
                          break
                      result = client.blocks.children.list(
                          block_id=page_id,
                          start_cursor=result.get("next_cursor")
                      )
                  return "\n\n".join([_parse_block(b) for b in blocks])  # 修改点：双换行拼接
              except Exception as e:
                  logger.error(f"获取内容失败: {str(e)}")
                  return ""

          def _parse_block(block):
              """解析 Notion 块为 Markdown（支持更多类型）"""
              type_ = block["type"]
              content = block[type_]
              text = "".join([t["plain_text"] for t in content.get("rich_text", [])])
              
              # 段落与标题处理
              if type_ == "paragraph":
                  return text + "\n"  # 修改点：追加换行
              elif type_ == "heading_1":
                  return f"# {text}\n"
              elif type_ == "heading_2":
                  return f"## {text}\n"
              elif type_ == "heading_3":
                  return f"### {text}\n"
              elif type_ == "bulleted_list_item":
                  return f"- {text}\n"
              elif type_ == "numbered_list_item":
                  return f"1. {text}\n"
              # 图片处理
              elif type_ == "image":
                  url = content.get("external", {}).get("url") or content.get("file", {}).get("url")
                  return f"![]({url})\n"
              # 代码块处理
              elif type_ == "code":
                  code = "\n".join([t["plain_text"] for t in content["rich_text"]])
                  return f"```{content['language']}\n{code}\n```\n"
              # 引用块处理
              elif type_ == "quote":
                  return f"> {text}\n"
              return ""

          def main():
              notion = Client(auth=os.environ["NOTION_TOKEN"])
              database_id = os.environ["NOTION_DATABASE_ID"]
              last_sync = get_last_sync_time()

              try:
                  # 查询所有已发布文章
                  pages = notion.databases.query(
                      database_id,
                      filter={"property": "Status", "select": {"equals": "Published"}}
                  ).get("results", [])
              except Exception as e:
                  logger.error(f"数据库查询失败: {str(e)}")
                  return

              local_posts = {}
              notion_ids_in_notion = set()
              # 读取本地_posts目录中的所有文章
              for post_file in glob.glob("_posts/*.md"):
                  with open(post_file, 'r', encoding='utf-8') as f:
                      post = frontmatter.load(f)
                      if "notion_id" in post:
                          local_posts[post["notion_id"]] = post_file

              for page in pages:
                  try:
                      page_id = page["id"]
                      notion_ids_in_notion.add(page_id)

                      # 提取基础字段
                      title = page["properties"]["Title"]["title"][0]["plain_text"].strip() if page["properties"]["Title"]["title"] else ""
                      date_str = page["properties"]["Date"]["date"]["start"].split("T")[0] if page["properties"]["Date"]["date"] else ""

                      # 修改点：Header Image 字段处理
                      header_img = page["properties"].get("Header-img", {}).get("rich_text", [{}])[0].get("plain_text", "").strip() if page["properties"].get("Header-img", {}).get("rich_text") else ""
                      
                      subtitle = page["properties"].get("Subtitle", {}).get("rich_text", [{}])[0].get("plain_text", "").strip() if page["properties"].get("Subtitle", {}).get("rich_text") else ""
                      tags = [tag["name"] for tag in page["properties"].get("Tags", {}).get("multi_select", [])]

                      content = get_page_content(page["id"])
                      post = frontmatter.Post(content)
                      post["title"] = title
                      post["subtitle"] = subtitle
                      post["date"] = date_str
                      post["layout"] = "post"
                      post["header-img"] = header_img  # 确保这里字段名与配置一致
                      post["catalog"] = True  # 手动设置 catalog 为 true
                      post["tags"] = tags
                      post["notion_id"] = page_id  # 添加 Notion ID 字段

                      # 根据 Notion ID 检查是否已经存在对应的本地文件
                      if page_id in local_posts:
                          # 如果存在，更新现有文件
                          filename = local_posts[page_id]
                          with open(filename, "w", encoding="utf-8") as f:
                              f.write(frontmatter.dumps(post))
                          logger.info(f"更新文章: {filename}")
                      else:
                          # 如果不存在，创建新文件
                          filename = f"_posts/{date_str}-{title.replace(' ', '-')}.md"
                          with open(filename, "w", encoding="utf-8") as f:
                              f.write(frontmatter.dumps(post))
                          logger.info(f"创建新文章: {filename}")

                  except Exception as e:
                      logger.error(f"处理失败: {str(e)} (Page ID: {page['id']})")

              # 删除本地未被处理的文章（即Notion中已删除的文章）
              for notion_id, post_file in local_posts.items():
                  if notion_id not in notion_ids_in_notion:
                      try:
                          os.remove(post_file)
                          logger.info(f"删除本地文章: {post_file}")
                      except Exception as e:
                          logger.error(f"删除文章失败: {str(e)} (File: {post_file})")

              save_last_sync_time()

          if __name__ == "__main__":
              main()
          EOF

          python notion_to_jekyll.py

      - name: Commit changes
        uses: stefanzweifel/git-auto-commit-action@v4
        with:
          commit_message: "Auto-sync from Notion"
          file_pattern: "_posts/* .last_sync.txt"

```