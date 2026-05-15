#!/bin/bash
set -euo pipefail

CONFIG_FILE="_config.yml"
R2_PUBLIC_URL="${R2_PUBLIC_URL:-$(grep -A5 'r2_gallery:' "$CONFIG_FILE" | grep 'public_url:' | sed 's/.*public_url: *"\(.*\)"/\1/' | tr -d ' ')}"
R2_PREFIX="${R2_PREFIX:-$(grep -A5 'r2_gallery:' "$CONFIG_FILE" | grep 'prefix:' | sed 's/.*prefix: *"\(.*\)"/\1/' | tr -d ' ')}"

: "${R2_ACCOUNT_ID:?请设置 R2_ACCOUNT_ID}"
: "${R2_ACCESS_KEY_ID:?请设置 R2_ACCESS_KEY_ID}"
: "${R2_SECRET_ACCESS_KEY:?请设置 R2_SECRET_ACCESS_KEY}"
: "${R2_BUCKET_NAME:?请设置 R2_BUCKET_NAME}"
: "${R2_PUBLIC_URL:?请设置 R2_PUBLIC_URL}"

OUTPUT="_data/gallery.yml"
ENDPOINT="https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com"
SUPPORTED_EXT="jpg|jpeg|png|gif|webp|avif"

mkdir -p _data
echo "# 自动生成，请勿手动编辑" > "$OUTPUT"
echo "" >> "$OUTPUT"

aws s3api list-objects-v2 \
  --bucket "$R2_BUCKET_NAME" \
  --prefix "$R2_PREFIX" \
  --endpoint-url "$ENDPOINT" \
  --query "Contents[].{Key: Key, LastModified: LastModified}" \
  --output json 2>/dev/null | \
python3 -c "
import json, sys, re
data = json.load(sys.stdin)
if not data: sys.exit(0)
ext_pattern = re.compile(r'\.($SUPPORTED_EXT)$', re.IGNORECASE)
photos = [item for item in data if ext_pattern.search(item['Key'])]
photos.sort(key=lambda x: x['LastModified'], reverse=True)
for photo in photos:
    key = photo['Key']
    name = key.rsplit('/', 1)[-1].rsplit('.', 1)[0]
    title = name.replace('-', ' ').replace('_', ' ')
    url = '${R2_PUBLIC_URL}/' + key
    print(f'- title: \"{title}\"')
    print(f'  image: \"{url}\"')
    print(f'  key: \"{key}\"')
    print()
" >> "$OUTPUT"
