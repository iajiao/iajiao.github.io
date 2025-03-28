---
catalog: true
date: '2025-03-16'
header-img: img/post-bg-3.jpg
image_hashes: []
layout: post
notion_id: 1b87d276-8542-8017-a8c5-cb3dbfa9be6d
subtitle: 让 notion 作为 jekyll 后台
tags:
- 网络
title: Notion to Github工作流代码
---

本站通过Jekyll 技术搭建在Github。GitHub非常稳定，但没后台，更新起来非常麻烦。之前曾使用Obsidian 作 Github 后台。虽然Obsidian堪称神器，但仅限于电脑端。在安卓手机上，不仅难以操作，而且启动速度很慢。最近，Notion 在安卓端用起来特别顺手，同步不用操心，而且移动端 App 尚可。 突发奇想：能否用Notion作后台，实现与Github的互动呢？答案是肯定的！


# 更新日志


- 1.0


在Deepseek的帮助下，经过10个小时开发！准确得说，是在罗马输球后大半夜睡不着的几个小时里以及次日小半个白天，通过编写 Github Action代码，实现了Notion与Github的梦幻互动。这个版本主要实现了Notion数据库内容从 Notion 到 Github 的同步，相当于给Github搭建的jekyll网站构建了一个高水平的后台文章管理系统。


- 1.1


然而，我的需求并非只是同步，我还想实现增量同步提高效率，通过 Notion管理文档，以便执行删除和更新等操作，还想提高代码运行效率。经过周五晚间和周六全天尝试，终于成功了！这个版本简称 V2。除 DeepSeek 外，Kimi在代码完善的过程中也提供了巨大的帮助，主要是 DeepSeek容易出现幻觉，代码前后一致性差一些，特别是代码融合时会漏掉内容，运行经常出错，Kimi 好很多。


- 1.2


这几天，突然发现图片的访问链接会变化，而且速度很不稳定，不断的在amazon和github之间切换，时好时坏，非常影响访问速度，如何解决？这个版本，主要就是解决了Notion图片访问速度的问题，现在采用了cloudflare进行CDN加速，快了很多。在这里，同样要鸣谢Kimi。


- 1.3


采用Cloudflare给图片加速之后，发现图片访问依然有些偏慢，仔细检查之后发现，图片的尺寸太大，动辄四五兆的图片，在网站上展示还是有些吃力，那么现在的解决思路就是压缩图片，并把原来的PNG格式通过JPG格式展示出来，成功解决了图片加载偏慢的问题。另外，对增量同步逻辑也有了修改，通过比对上次同步时间和文章最后修改时间，来决定文章是否需要更新，避免每次大面积更新文章，提高了效率。


- 1.4


突然发现，图床仓库增加了很多图片，点开一看，全部都是重复图片。这才发现每次同步，数据库里的图片都会经历一遍下载、上传、压缩、加速流程，不仅造成仓库里面图片杂乱，也增加了资源消耗和运行时间。经过几天时间的测试更新，新版代码出炉。这个版本主要解决了多余图片的清理问题，变更了清理逻辑，增量同步更完善。


# 完整代码


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
            Pillow==9.3.0 \
            python-dateutil==2.8.2 \
            --index-url https://pypi.tuna.tsinghua.edu.cn/simple \
            --trusted-host pypi.tuna.tsinghua.edu.cn

      - name: Convert Notion pages to Jekyll posts
        env:
          NOTION_TOKEN: ${{ secrets.NOTION_TOKEN }}
          NOTION_DATABASE_ID: ${{ secrets.NOTION_DATABASE_ID }}
          PERSONAL_TOKEN: ${{ secrets.PERSONAL_TOKEN }}
        run: |
          cat << 'EOF' > notion_to_jekyll.py
          import os
          import logging
          import json
          from datetime import datetime
          from dateutil import parser  # 用于解析 Notion 的时间格式
          from notion_client import Client
          import frontmatter
          from mdutils import MdUtils
          import requests
          import glob
          import shutil
          import base64
          import hashlib
          from PIL import Image
          from io import BytesIO

          logging.basicConfig(level=logging.INFO)
          logger = logging.getLogger(__name__)

          # 读取上次同步的时间戳
          def get_last_sync_time():
              try:
                  with open('.last_sync.txt', 'r') as f:
                      # 假设本地时间戳是UTC时间
                      return datetime.fromisoformat(f.read().strip()).replace(tzinfo=None)
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
                  original_url = content.get("external", {}).get("url") or content.get("file", {}).get("url")
                  if not original_url:
                      return ""
                  
                  # 生成唯一的文件名，改为 jpg 格式
                  file_name = hashlib.md5(original_url.encode()).hexdigest() + ".jpg"
                  
                  # 下载图片
                  try:
                      response = requests.get(original_url)
                      response.raise_for_status()
                  except requests.exceptions.RequestException as e:
                      logger.error(f"下载图片失败: {str(e)}")
                      return f"![]({original_url})\n"
                  
                  # 将图片转换为 JPG 格式并压缩
                  try:
                      image = Image.open(BytesIO(response.content))
                      image = image.convert("RGB")  # 确保是 RGB 模式
                      
                      # 压缩图片
                      image.thumbnail((1920, 1080))  # 调整大小以压缩
                      image_bytes = BytesIO()
                      image.save(image_bytes, format="JPEG", quality=85)
                      image_content = image_bytes.getvalue()
                  except Exception as e:
                      logger.error(f"图片格式转换失败: {str(e)}")
                      return f"![]({original_url})\n"
                  
                  # 上传图片到当前仓库的 img/in-post 目录
                  try:
                      # 使用 GitHub API 上传文件
                      github_token = os.environ["PERSONAL_TOKEN"]
                      repo = os.environ["GITHUB_REPOSITORY"]  # 当前仓库
                      branch = "master"  # 设置为 master 分支
                      
                      # 使用 GitHub API 创建或更新文件
                      headers = {
                          "Authorization": f"token {github_token}",
                          "Accept": "application/vnd.github.v3+json"
                      }
                      url = f"https://api.github.com/repos/{repo}/contents/img/in-post/{file_name}"
                      data = {
                          "message": f"Add image {file_name}",
                          "content": base64.b64encode(image_content).decode(),
                          "branch": branch
                      }
                      response = requests.put(url, headers=headers, json=data)
                      response.raise_for_status()
                  except Exception as e:
                      logger.error(f"上传图片到 GitHub 失败: {str(e)}")
                      return f"![]({original_url})\n"
                  
                  # 使用 Cloudflare 加速后的链接
                  cdn_url = f"https://ajiao.eu.org/img/in-post/{file_name}"
                  return f"![]({cdn_url})\n"
              # 代码块处理
              elif type_ == "code":
                  code = "\n".join([t["plain_text"] for t in content["rich_text"]])
                  return f"```{content['language']}\n{code}\n```\n"
              # 引用块处理
              elif type_ == "quote":
                  return f"> {text}\n"
              return ""

          def delete_unused_images(old_image_hashes, new_image_hashes):
              """删除不再需要的图片"""
              for old_image_hash in old_image_hashes:
                  if old_image_hash not in new_image_hashes:
                      image_path = f"img/in-post/{old_image_hash}"
                      if os.path.exists(image_path):
                          os.remove(image_path)
                          logger.info(f"删除旧图片: {image_path}")
                          # 同步删除 GitHub 仓库中的图片
                          try:
                              github_token = os.environ["PERSONAL_TOKEN"]
                              repo = os.environ["GITHUB_REPOSITORY"]
                              branch = "master"
                              headers = {
                                  "Authorization": f"token {github_token}",
                                  "Accept": "application/vnd.github.v3+json"
                              }
                              url = f"https://api.github.com/repos/{repo}/contents/img/in-post/{old_image_hash}"
                              data = {
                                  "message": f"Remove image {old_image_hash}",
                                  "sha": get_file_sha(old_image_hash),
                                  "branch": branch
                              }
                              response = requests.delete(url, headers=headers, json=data)
                              response.raise_for_status()
                          except Exception as e:
                              logger.error(f"删除旧图片失败: {str(e)} (Image: {old_image_hash})")

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

              # 用于记录所有被引用的图片
              used_images = set()

              for page in pages:
                  try:
                      page_id = page["id"]
                      notion_ids_in_notion.add(page_id)

                      # 获取notion页面的最后修改时间
                      last_edited_time_str = page["last_edited_time"]
                      # 使用 dateutil 解析时间，并移除时区信息
                      last_edited_time = parser.isoparse(last_edited_time_str).replace(tzinfo=None)
                      
                      # 如果上次同步时间为空，或者notion页面的最后修改时间晚于上次同步时间，则需要更新
                      if last_sync is None or last_edited_time > last_sync:
                          # 提取基础字段
                          title = page["properties"]["Name"]["title"][0]["plain_text"].strip() if page["properties"]["Name"]["title"] else ""
                          date_str = page["properties"]["Date"]["date"]["start"].split("T")[0] if page["properties"]["Date"]["date"] else ""
                          header_img = page["properties"].get("Header-img", {}).get("select", {}).get("name", "") if page["properties"].get("Header-img", {}).get("select") else ""
                          subtitle = page["properties"].get("Subtitle", {}).get("rich_text", [{}])[0].get("plain_text", "").strip() if page["properties"].get("Subtitle", {}).get("rich_text") else ""
                          tags = [tag["name"] for tag in page["properties"].get("Tags", {}).get("multi_select", [])]

                          content = get_page_content(page["id"])
                          post = frontmatter.Post(content)
                          post["title"] = title
                          post["subtitle"] = subtitle
                          post["date"] = date_str
                          post["layout"] = "post"
                          post["header-img"] = header_img
                          post["catalog"] = True
                          post["tags"] = tags
                          post["notion_id"] = page_id

                          # 提取文章中使用的图片哈希值
                          image_hashes = []
                          for block in content.split('\n'):
                              if '![](' in block:
                                  url = block.split('![](')[1].split(')')[0]
                                  if url.startswith('https://ajiao.eu.org/img/in-post/'):
                                      image_hash = url.split('/')[-1]
                                      image_hashes.append(image_hash)
                                      used_images.add(image_hash)

                          post["image_hashes"] = image_hashes  # 记录文章使用的图片哈希值

                          # 根据 Notion ID 检查是否已经存在对应的本地文件
                          if page_id in local_posts:
                              filename = local_posts[page_id]
                              # 读取旧的文章，获取旧的图片哈希值
                              with open(filename, 'r', encoding='utf-8') as f:
                                  old_post = frontmatter.load(f)
                                  old_image_hashes = old_post.get("image_hashes", [])
                              # 删除旧的但不在新的文章中的图片
                              delete_unused_images(old_image_hashes, image_hashes)
                              # 更新文章
                              with open(filename, "w", encoding="utf-8") as f:
                                  f.write(frontmatter.dumps(post))
                              logger.info(f"更新文章: {filename}")
                          else:
                              filename = f"_posts/{date_str}-{title.replace(' ', '-')}.md"
                              with open(filename, "w", encoding="utf-8") as f:
                                  f.write(frontmatter.dumps(post))
                              logger.info(f"创建新文章: {filename}")
                      else:
                          logger.info(f"文章未修改，跳过更新: {page_id}")
                  except Exception as e:
                      logger.error(f"处理失败: {str(e)} (Page ID: {page['id']})")

              # 删除本地未被处理的文章（即Notion中已删除的文章）
              for notion_id, post_file in local_posts.items():
                  if notion_id not in [page["id"] for page in pages]:
                      try:
                          # 读取文章的 Front Matter，获取图片哈希值并删除对应的图片
                          with open(post_file, 'r', encoding='utf-8') as f:
                              post = frontmatter.load(f)
                              image_hashes = post.get("image_hashes", [])
                          # 删除图片
                          delete_unused_images(image_hashes, [])
                          os.remove(post_file)
                          logger.info(f"删除本地文章: {post_file}")
                      except Exception as e:
                          logger.error(f"删除文章失败: {str(e)} (File: {post_file})")

              save_last_sync_time()

          def get_file_sha(file_name):
              """获取文件的 SHA 值"""
              try:
                  github_token = os.environ["PERSONAL_TOKEN"]
                  repo = os.environ["GITHUB_REPOSITORY"]
                  branch = "master"
                  headers = {
                      "Authorization": f"token {github_token}",
                      "Accept": "application/vnd.github.v3+json"
                  }
                  url = f"https://api.github.com/repos/{repo}/contents/img/in-post/{file_name}"
                  response = requests.get(url, headers=headers)
                  response.raise_for_status()
                  return response.json().get("sha")
              except Exception as e:
                  logger.error(f"获取文件 SHA 值失败: {str(e)}")
                  return None

          if __name__ == "__main__":
              main()
          EOF

          python notion_to_jekyll.py

      - name: Pull remote changes
        run: |
          git config --global user.email "your-email@example.com"
          git config --global user.name "Your Name"
          git pull origin master

      - name: Commit changes
        uses: stefanzweifel/git-auto-commit-action@v4
        with:
          commit_message: "Auto-sync from Notion"
          file_pattern: "_posts/* .last_sync.txt img/in-post/*"

```