#!/bin/bash
set -euxo pipefail

echo "=== 脚本开始执行 ==="

CONFIG_FILE="_config.yml"

# 读取配置
R2_PUBLIC_URL="${R2_PUBLIC_URL:-$(grep -A5 'r2_gallery:' "$CONFIG_FILE" | grep 'public_url:' | sed 's/.*public_url: *"\(.*\)"/\1/' | tr -d ' ')}"
R2_PREFIX="${R2_PREFIX:-$(grep -A5 'r2_gallery:' "$CONFIG_FILE" | grep 'prefix:' | sed 's/.*prefix: *"\(.*\)"/\1/' | tr -d ' ')}"

echo "R2_PUBLIC_URL: ${R2_PUBLIC_URL}"
echo "R2_PREFIX: ${R2_PREFIX}"

# 检查必需的环境变量
: "${R2_ACCOUNT_ID:?请设置 R2_ACCOUNT_ID}"
: "${R2_ACCESS_KEY_ID:?请设置 R2_ACCESS_KEY_ID}"
: "${R2_SECRET_ACCESS_KEY:?请设置 R2_SECRET_ACCESS_KEY}"
: "${R2_BUCKET_NAME:?请设置 R2_BUCKET_NAME}"
: "${R2_PUBLIC_URL:?请设置 R2_PUBLIC_URL}"

OUTPUT="_data/gallery.yml"
ENDPOINT="https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com"
SUPPORTED_EXT="jpg|jpeg|png|gif|webp|avif"

mkdir -p _data

# 写入 YAML 文件头
cat > "$OUTPUT" << EOF
# 此文件由 generate-gallery-r2.sh 自动生成
# 生成时间: $(date)

EOF

echo "正在从 R2 获取图片列表..."

# 使用临时文件存储 JSON 输出
TEMP_JSON=$(mktemp)

# 获取 R2 对象列表
aws s3api list-objects-v2 \
  --bucket "$R2_BUCKET_NAME" \
  --prefix "$R2_PREFIX" \
  --endpoint-url "$ENDPOINT" \
  --query "Contents[].{Key: Key, LastModified: LastModified}" \
  --output json > "$TEMP_JSON" 2>&1

# 使用 Python 处理并追加到 YAML 文件
python3 << EOF >> "$OUTPUT"
import json, re, os
from datetime import datetime

with open('$TEMP_JSON', 'r') as f:
    data = json.load(f)

if not data:
    print('# 没有找到任何图片')
    exit(0)

ext_pattern = re.compile(r'\.($SUPPORTED_EXT)$', re.IGNORECASE)
photos = [item for item in data if ext_pattern.search(item['Key'])]
photos.sort(key=lambda x: x['LastModified'], reverse=True)

count = 0
for photo in photos:
    key = photo['Key']
    filename = key.rsplit('/', 1)[-1]
    name = filename.rsplit('.', 1)[0]
    title = name.replace('-', ' ').replace('_', ' ').replace('%20', ' ')
    url = '${R2_PUBLIC_URL}/' + key
    print(f'- title: "{title}"')
    print(f'  image: "{url}"')
    print(f'  key: "{key}"')
    print()
    count += 1

# 输出统计信息到 stderr，不影响 YAML
print(f'共 {count} 张图片', file=sys.stderr)
EOF

# 清理临时文件
rm -f "$TEMP_JSON"

COUNT=$(grep -c '^- title:' "$OUTPUT" 2>/dev/null || echo "0")
echo "=== 生成完成: 共 ${COUNT} 张照片 ==="
