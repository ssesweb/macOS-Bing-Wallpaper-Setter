#!/bin/zsh

# --- 配置 ---
BING_JSON_URL="https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=zh-CN"
BING_BASE_URL="https://www.bing.com"
WALLPAPER_DIR="$HOME/Pictures/BingWallpapers"
# --------------------

# 创建保存目录
mkdir -p "$WALLPAPER_DIR"

echo "⏳ 正在获取今日 Bing 壁纸信息..."

# 1. 获取 JSON 数据
JSON_DATA=$(curl -s "$BING_JSON_URL")

if [ $? -ne 0 ] || [ -z "$JSON_DATA" ]; then
    echo "❌ 获取壁纸 JSON 失败，请检查网络连接。"
    exit 1
fi

# 2. 解析 JSON 数据
IMAGE_URL_PATH=$(echo "$JSON_DATA" | sed -E 's/.*"url":"([^"]+)".*/\1/' | sed 's/1920x1080/UHD/')
START_DATE=$(echo "$JSON_DATA" | sed -E 's/.*"startdate":"([^"]+)".*/\1/')
IMAGE_TITLE=$(echo "$JSON_DATA" | sed -E 's/.*"title":"([^"]+)".*/\1/')
IMAGE_COPYRIGHT=$(echo "$JSON_DATA" | sed -E 's/.*"copyright":"([^"]+)".*/\1/')

# 清理版权信息中的特殊字符，用于文件名
CLEAN_COPYRIGHT=$(echo "$IMAGE_COPYRIGHT" | sed 's/[/:\\*?<>|]/-/g' | sed 's/"//g')

# 提取图片描述（版权信息的第一部分）
IMAGE_DESCRIPTION=$(echo "$IMAGE_COPYRIGHT" | cut -d',' -f1 | sed 's/[/:\\*?<>|]/-/g')

FULL_IMAGE_URL="${BING_BASE_URL}${IMAGE_URL_PATH}"

# 使用描述+日期作为文件名，既保持唯一性又便于识别
FILE_NAME="${IMAGE_DESCRIPTION}_${START_DATE}.jpg"
FILE_PATH="${WALLPAPER_DIR}/${FILE_NAME}"

echo "📌 今日壁纸：${IMAGE_TITLE}"
echo "📝 图片描述：${IMAGE_DESCRIPTION}"
echo "🔗 下载 URL：${FULL_IMAGE_URL}"

# 3. 检查是否已存在相同描述的壁纸（无论日期）
echo "🔍 检查是否已存在相同壁纸..."
EXISTING_FILE=$(find "$WALLPAPER_DIR" -name "*${IMAGE_DESCRIPTION}*" -type f | head -n1)

if [ -n "$EXISTING_FILE" ]; then
    echo "🖼 壁纸已存在：$(basename "$EXISTING_FILE")"
    FILE_PATH="$EXISTING_FILE"  # 使用已存在的文件路径
else
    echo "⬇️ 正在下载新壁纸..."
    curl -s -L -o "$FILE_PATH" "$FULL_IMAGE_URL"

    if [ $? -ne 0 ]; then
        echo "❌ 下载壁纸失败。"
        exit 1
    fi
    echo "📁 保存到：${FILE_PATH}"
fi

# 4. 设置为 macOS 壁纸
echo "🔄 正在设置壁纸..."

ESCAPED_PATH=$(echo "$FILE_PATH" | sed 's/"/\\"/g')

osascript -e "set picturePath to POSIX file \"$ESCAPED_PATH\"" \
          -e 'tell application "System Events"' \
          -e 'repeat with theDesktop in every desktop' \
          -e 'set picture of theDesktop to picturePath' \
          -e 'end repeat' \
          -e 'end tell'

if [ $? -eq 0 ]; then
    echo "✅ 壁纸已成功应用到所有屏幕。"
    echo "💡 图片信息: $IMAGE_COPYRIGHT"
else
    echo "❌ 设置壁纸失败。"
fi

# --------------------

exit 0
