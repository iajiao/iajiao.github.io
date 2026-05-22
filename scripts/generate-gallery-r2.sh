#!/bin/bash
set -euxo pipefail

echo "=== 脚本开始执行 ==="
echo "当前时间: $(date)"
echo "当前目录: $(pwd)"

CONFIG_FILE="_config.yml"

# 从环境变量或 _config.yml 读取配置
echo "读取配置..."

R2_PUBLIC_URL="${R2_PUBLIC_URL:-$(grep -A5 'r2_gallery:' "$CONFIG_FILE" | grep 'public_url:' | sed 's/.*public_url: *"\(.*\)"/\1/' | tr -d ' ')}"
R2_PREFIX="${R2_PREFIX:-$(grep -A5 'r2_gallery:' "$CONFIG_FILE" | grep 'prefix:' | sed 's/.*prefix: *"\(.*\)"/\1/' | tr -d ' ')}"

echo "R2_PUBLIC_URL: ${R2_PUBLIC_URL}"
echo "R2_PREFIX: ${R2_PREFIX}"

# 检查必需的环境变量
echo "检查环境变量..."
: "${R2_ACCOUNT_ID:?请设置 R2_ACCOUNT_ID}"
: "${R2_ACCESS_KEY_ID:?请设置 R2_ACCESS_KEY_ID}"
: "${R2_SECRET_ACCESS_KEY:?请设置 R2_SECRET_ACCESS_KEY}"
: "${R2_BUCKET_NAME:?请设置 R2_BUCKET_NAME}"
: "${R2_PUBLIC_URL:?请设置 R2_PUBLIC_URL}"

echo "环境变量检查通过"

OUTPUT="_data/gallery.yml"
ENDPOINT="https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com"
SUPPORTED_EXT="jpg|jpeg|png|gif|webp|avif"

echo "ENDPOINT: ${ENDPOINT}"
echo "BUCKET: ${R2_BUCKET_NAME}"
echo "OUTPUT: ${OUTPUT}"

# 创建 _data 目录
mkdir -p _data

# 写入 YAML 文件头
echo "# 此文件由 generate-gallery-r2.sh 自动生成" > "$OUTPUT"
echo "# 生成时间: $(date)" >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "正在从 R2 获取图片列表..."

# 列出并处理图片
aws s3api list-objects-v2 \
  --bucket "$R2_BUCKET_NAME" \
  --prefix "$R2_PREFIX" \
  --endpoint-url "$ENDPOINT" \
  --query "Contents[].{Key: Key, LastModified: LastModified}" \
  --output json 2>&1 | \
python3 -c "
import json, sys, re, os

# 读取输入
data = json.load(sys.stdin)
print(f'DEBUG: 从 R2 获取到 {len(data) if data else 0} 个对象', file=sys.stderr)

if not data:
    print('DEBUG: 没有找到任何对象', file=sys.stderr)
    sys.exit(0)

# 支持的图片扩展名
ext_pattern = re.compile(r'\.(jpg|jpeg|png|gif|webp|avif)$', re.IGNORECASE)

# 过滤出图片
photos = [item for item in data if ext_pattern.search(item['Key'])]
print(f'DEBUG: 过滤后得到 {len(photos)} 张图片', file=sys.stderr)

if not photos:
    print('DEBUG: 没有找到图片文件', file=sys.stderr)
    sys.exit(0)

# 按修改时间倒序排列
photos.sort(key=lambda x: x['LastModified'], reverse=True)

# 输出 YAML
for photo in photos:
    key = photo['Key']
    filename = key.rsplit('/', 1)[-1]
    name = filename.rsplit('.', 1)[0]
    # 替换特殊字符为空格
    title = name.replace('-', ' ').replace('_', ' ')
    # 拼接完整 URL
    url = os.environ.get('R2_PUBLIC_URL', '') + '/' + key
    print(f'- title: \"{title}\"')
    print(f'  image: \"{url}\"')
    print(f'  key: \"{key}\"')
    print()

print(f'DEBUG: 成功输出 {len(photos)} 张图片', file=sys.stderr)
" >> "$OUTPUT" 2>&1

# 检查 Python 脚本的退出码
PYTHON_EXIT=$?
if [ $PYTHON_EXIT -ne 0 ]; then
    echo "错误: Python 脚本执行失败，退出码: $PYTHON_EXIT"
    exit $PYTHON_EXIT
fi

# 统计生成的图片数量
COUNT=$(grep -c '^- title:' "$OUTPUT" 2>/dev/null || echo "0")
echo "=== 生成完成 ==="
echo "Gallery 生成完成: 共 ${COUNT} 张照片"
echo "输出文件位置: ${OUTPUT}"

# 显示前 3 行作为预览
echo "=== 输出文件预览 ==="
head -n 10 "$OUTPUT" || echo "文件为空"

echo "=== 脚本执行完毕 ==="
