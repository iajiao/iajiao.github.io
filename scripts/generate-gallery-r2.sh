#!/bin/bash
set -euxo pipefail

echo "=== 开始生成相册数据 ==="

# 切换到仓库根目录
cd "${GITHUB_WORKSPACE:-$(pwd)}"
echo "当前工作目录: $(pwd)"

# 设置路径
DATA_DIR="${GITHUB_WORKSPACE:-$(pwd)}/_data"
OUTPUT_FILE="${DATA_DIR}/gallery.yml"

echo "数据目录: ${DATA_DIR}"
echo "输出文件: ${OUTPUT_FILE}"

# 创建 _data 目录
mkdir -p "${DATA_DIR}"
ls -la "${DATA_DIR}"

# 写入 YAML 文件头
cat > "${OUTPUT_FILE}" << EOF
# 此文件由 scripts/generate-gallery-r2.sh 自动生成
# 生成时间: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

EOF

echo "文件头已写入"

# 获取配置（如果环境变量没设置，使用默认值）
R2_PUBLIC_URL="${R2_PUBLIC_URL:-https://img.ajiao.eu.org}"
R2_PREFIX="${R2_PREFIX:-Pic/}"

echo "R2_PUBLIC_URL: ${R2_PUBLIC_URL}"
echo "R2_PREFIX: ${R2_PREFIX}"

# 检查环境变量
: "${R2_ACCOUNT_ID:?缺少 R2_ACCOUNT_ID}"
: "${R2_ACCESS_KEY_ID:?缺少 R2_ACCESS_KEY_ID}"
: "${R2_SECRET_ACCESS_KEY:?缺少 R2_SECRET_ACCESS_KEY}"
: "${R2_BUCKET_NAME:?缺少 R2_BUCKET_NAME}"

ENDPOINT="https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com"
echo "连接 R2: ${ENDPOINT}"

# 获取图片列表
TEMP_FILE=$(mktemp)
aws s3api list-objects-v2 \
    --bucket "${R2_BUCKET_NAME}" \
    --prefix "${R2_PREFIX}" \
    --endpoint-url "${ENDPOINT}" \
    --query "Contents[].{Key: Key, LastModified: LastModified}" \
    --output json > "${TEMP_FILE}"

echo "AWS 命令执行完成"

# **关键修复：导出环境变量供 Python 使用**
export OUTPUT_FILE
export R2_PUBLIC_URL
export TEMP_FILE

# 用 Python 处理并追加到文件
python3 << 'EOF'
import json, re, sys, os

# 从环境变量获取路径
output_file = os.environ.get('OUTPUT_FILE')
r2_public_url = os.environ.get('R2_PUBLIC_URL')
temp_file = os.environ.get('TEMP_FILE')

print(f"Python: 输出文件 = {output_file}", file=sys.stderr)
print(f"Python: 临时文件 = {temp_file}", file=sys.stderr)

if not output_file or not temp_file:
    print("错误: 缺少必要的环境变量", file=sys.stderr)
    sys.exit(1)

try:
    with open(temp_file, 'r') as f:
        data = json.load(f)
except Exception as e:
    print(f"错误: 无法读取 JSON - {e}", file=sys.stderr)
    sys.exit(1)

if not data:
    print("错误: R2 中没有找到任何对象", file=sys.stderr)
    sys.exit(1)

# 支持的图片格式
ext_pattern = re.compile(r'\.(jpg|jpeg|png|gif|webp|avif)$', re.IGNORECASE)
# 过滤出图片，排除文件夹（以 / 结尾的）
photos = [item for item in data 
          if ext_pattern.search(item['Key']) and not item['Key'].endswith('/')]

if not photos:
    print("错误: 没有找到图片文件", file=sys.stderr)
    sys.exit(1)

# 按修改时间倒序排序
photos.sort(key=lambda x: x['LastModified'], reverse=True)

count = 0
with open(output_file, 'a') as f:
    for photo in photos:
        key = photo['Key']
        filename = key.rsplit('/', 1)[-1]
        name = filename.rsplit('.', 1)[0]
        title = name.replace('-', ' ').replace('_', ' ')
        url = f"{r2_public_url}/{key}"
        f.write(f'- title: "{title}"\n')
        f.write(f'  image: "{url}"\n')
        f.write(f'  key: "{key}"\n')
        f.write('\n')
        count += 1

print(f"成功写入 {count} 张图片", file=sys.stderr)
EOF

# 检查 Python 执行结果
PYTHON_EXIT=$?
if [ $PYTHON_EXIT -ne 0 ]; then
    echo "错误: Python 脚本执行失败"
    rm -f "${TEMP_FILE}"
    exit $PYTHON_EXIT
fi

# 清理临时文件
rm -f "${TEMP_FILE}"

echo "=== 文件写入完成 ==="
echo "输出文件内容预览："
head -n 20 "${OUTPUT_FILE}"

COUNT=$(grep -c '^- title:' "${OUTPUT_FILE}" || echo "0")
echo "=================================="
echo "成功写入 ${COUNT} 张图片"
echo "=================================="

if [ "${COUNT}" -eq 0 ]; then
    echo "警告: 没有写入任何图片"
    exit 1
fi
