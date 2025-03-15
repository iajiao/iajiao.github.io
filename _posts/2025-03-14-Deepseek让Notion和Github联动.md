---
catalog: true
date: '2025-03-14'
header-img: img/post-bg-4.jpg
layout: post
notion_id: 1b67d276-8542-802f-8185-cf8ed45aa470
subtitle: 用Notion作为Github后台
tags:
- 网络
title: Deepseek让Notion和Github联动
---

Github Pages是我的博客载体，使用的程序是Jekyll，GitHub非常稳定，但博客没有后台，更新非常麻烦。之前，曾使用了一段时间Obsidian。Obsidian堪称神器，但只限于电脑端。在安卓手机端，非常难用，而且启动速度很慢。


凑巧，最近使用Notion比较顺手，那能不能用Notion作为博客后台，与Github实现互动呢？答案：可以。在Deepseek的帮助下，差不多用了10个小时左右，终于实现了Notion与Github的梦幻联动。


虽然，现在还不完美，但毕竟能用了。还有些少许的问题，随后再抽时间，慢慢更新吧。


代码如下：


```yaml
name: Notion to Jekyll Sync
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
pointer
```