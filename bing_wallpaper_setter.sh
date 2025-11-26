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

# 2. 解析 JSON 数据 (使用 sed 进行简单解析，如果系统安装了 jq 会更可靠)
# 提取 url 和 startdate，并进行 URL 转换 (UHD)
IMAGE_URL_PATH=$(echo "$JSON_DATA" | sed -E 's/.*"url":"([^"]+)".*/\1/' | sed 's/1920x1080/UHD/')
START_DATE=$(echo "$JSON_DATA" | sed -E 's/.*"startdate":"([^"]+)".*/\1/')
IMAGE_TITLE=$(echo "$JSON_DATA" | sed -E 's/.*"title":"([^"]+)".*/\1/' | sed 's/[/:\\]/_/g') # 清理标题中的斜杠和冒号

FULL_IMAGE_URL="${BING_BASE_URL}${IMAGE_URL_PATH}"
FILE_NAME="${START_DATE}_${IMAGE_TITLE}.jpg"
FILE_PATH="${WALLPAPER_DIR}/${FILE_NAME}"

echo "📌 今日壁纸：${IMAGE_TITLE}"
echo "🔗 下载 URL：${FULL_IMAGE_URL}"

# 3. 下载壁纸
if [ -f "$FILE_PATH" ]; then
    echo "🖼 壁纸已存在：${FILE_NAME}"
else
    echo "⬇️ 正在下载壁纸..."
    curl -s -L -o "$FILE_PATH" "$FULL_IMAGE_URL"

    if [ $? -ne 0 ]; then
        echo "❌ 下载壁纸失败。"
        exit 1
    fi
    echo "📁 保存到：${FILE_PATH}"
fi

# 4. 设置为 macOS 壁纸 (使用您验证可行的 System Events 循环)
echo "🔄 正在设置壁纸..."

# AppleScript 变量需要处理路径中的引号，虽然 bing 标题通常不会有，但预防性处理
ESCAPED_PATH=$(echo "$FILE_PATH" | sed 's/"/\\"/g')

osascript -e "set picturePath to POSIX file \"$ESCAPED_PATH\"" \
          -e 'tell application "System Events"' \
          -e 'repeat with theDesktop in every desktop' \
          -e 'set picture of theDesktop to picturePath' \
          -e 'end repeat' \
          -e 'end tell'

if [ $? -eq 0 ]; then
    echo "✅ 壁纸已成功应用到所有屏幕。"
else
    echo "❌ 设置壁纸失败。"
fi

# --------------------

exit 0
