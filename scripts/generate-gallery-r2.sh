#!/bin/bash
set -euo pipefail

echo "=== 开始生成相册数据 ==="

# 设置输出目录和文件
DATA_DIR="_data"
OUTPUT_FILE="${DATA_DIR}/gallery.yml"

# 确保 _data 目录存在
echo "创建 ${DATA_DIR} 目录..."
mkdir -p "${DATA_DIR}"
if [ ! -d "${DATA_DIR}" ]; then
    echo "错误：无法创建 ${DATA_DIR} 目录"
    exit 1
fi
echo "✓ ${DATA_DIR} 目录已就绪"

# 读取配置（如果环境变量没设置，从 _config.yml 读取）
if [ -z "${R2_PUBLIC_URL:-}" ]; then
    echo "从 _config.yml 读取 R2_PUBLIC_URL..."
    R2_PUBLIC_URL=$(grep -A5 'r2_gallery:' _config.yml | grep 'public_url:' | sed 's/.*public_url: *"\(.*\)"/\1/' | tr -d ' ')
fi

if [ -z "${R2_PREFIX:-}" ]; then
    echo "从 _config.yml 读取 R2_PREFIX..."
    R2_PREFIX=$(grep -A5 'r2_gallery:' _config.yml | grep 'prefix:' | sed 's/.*prefix: *"\(.*\)"/\1/' | tr -d ' ')
fi

echo "R2_PUBLIC_URL: ${R2_PUBLIC_URL}"
echo "R2_PREFIX: ${R2_PREFIX}"

# 检查必需的环境变量
echo "检查环境变量..."
: "${R2_ACCOUNT_ID:?缺少 R2_ACCOUNT_ID}"
: "${R2_ACCESS_KEY_ID:?缺少 R2_ACCESS_KEY_ID}"
: "${R2_SECRET_ACCESS_KEY:?缺少 R2_SECRET_ACCESS_KEY}"
: "${R2_BUCKET_NAME:?缺少 R2_BUCKET_NAME}"
: "${R2_PUBLIC_URL:?缺少 R2_PUBLIC_URL}"
echo "✓ 环境变量检查通过"

# 写入 YAML 文件头
echo "生成 ${OUTPUT_FILE}..."
cat > "${OUTPUT_FILE}" << EOF
# 此文件由 scripts/generate-gallery-r2.sh 自动生成
# 生成时间: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
# 请不要手动编辑

EOF

# 调用 AWS CLI 获取图片列表
echo "连接 R2 获取图片列表..."
ENDPOINT="https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com"

# 获取对象列表（捕获错误）
TEMP_FILE=$(mktemp)
if ! aws s3api list-objects-v2 \
    --bucket "${R2_BUCKET_NAME}" \
    --prefix "${R2_PREFIX}" \
    --endpoint-url "${ENDPOINT}" \
    --query "Contents[].{Key: Key, LastModified: LastModified}" \
    --output json > "${TEMP_FILE}" 2>&1; then
    echo "错误：AWS CLI 执行失败"
    cat "${TEMP_FILE}"
    rm -f "${TEMP_FILE}"
    exit 1
fi

# 用 Python 解析并追加到 YAML 文件
python3 << EOF
import json
import re
import sys

# 支持的图片格式
SUPPORTED_EXTS = re.compile(r'\.(jpg|jpeg|png|gif|webp|avif)$', re.IGNORECASE)

try:
    with open('${TEMP_FILE}', 'r') as f:
        data = json.load(f)
except Exception as e:
    print(f"错误：无法解析 JSON - {e}", file=sys.stderr)
    sys.exit(1)

if not data:
    print("警告：R2 桶中没有找到任何对象", file=sys.stderr)
    # 写入提示信息
    with open('${OUTPUT_FILE}', 'a') as f:
        f.write("# 没有找到任何图片\n")
        f.write("# 请在 R2 桶中上传图片后重新运行此脚本\n")
    sys.exit(0)

# 过滤出图片
photos = [item for item in data if SUPPORTED_EXTS.search(item['Key'])]
if not photos:
    print("警告：没有找到图片文件（支持 jpg/png/gif/webp/avif）", file=sys.stderr)
    with open('${OUTPUT_FILE}', 'a') as f:
        f.write("# 没有找到支持的图片文件\n")
    sys.exit(0)

# 按修改时间倒序排序（最新的在前）
photos.sort(key=lambda x: x['LastModified'], reverse=True)

# 写入 YAML 内容
count = 0
with open('${OUTPUT_FILE}', 'a') as f:
    for photo in photos:
        key = photo['Key']
        filename = key.rsplit('/', 1)[-1]
        name = filename.rsplit('.', 1)[0]
        # 美化标题：替换特殊字符
        title = name.replace('-', ' ').replace('_', ' ').replace('%20', ' ')
        url = '${R2_PUBLIC_URL}/' + key
        
        f.write(f'- title: "{title}"\n')
        f.write(f'  image: "{url}"\n')
        f.write(f'  key: "{key}"\n')
        f.write('\n')
        count += 1

print(f"✓ 成功生成 {count} 张图片的相册数据", file=sys.stderr)
EOF

# 清理临时文件
rm -f "${TEMP_FILE}"

# 统计结果
COUNT=$(grep -c '^- title:' "${OUTPUT_FILE}" 2>/dev/null || echo "0")
echo "=================================="
echo "相册数据生成完成！"
echo "输出文件: ${OUTPUT_FILE}"
echo "图片数量: ${COUNT}"
echo "=================================="

if [ "${COUNT}" -eq 0 ]; then
    echo "⚠️  警告：没有生成任何图片，请检查 R2 桶中是否有图片"
    exit 1
fi

echo "✓ 脚本执行成功"
