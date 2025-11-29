#!/bin/zsh

# --- 配置 ---
BING_JSON_URL="https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=zh-CN"
BING_BASE_URL="https://www.bing.com"
WALLPAPER_DIR="$HOME/Pictures/BingWallpapers"
# --------------------

# 检查 jq 是否安装
if ! command -v jq &> /dev/null
then
    echo "❌ 错误：未找到 jq 命令。请安装 jq 以进行健壮的 JSON 解析（例如：brew install jq）"
    # 如果不安装 jq，可以使用下面的 sed/awk 替代方案，但建议使用 jq
    # exit 1 
fi

# 创建保存目录
mkdir -p "$WALLPAPER_DIR"

echo "⏳ 正在获取今日 Bing 壁纸信息..."

# 1. 获取 JSON 数据
JSON_DATA=$(curl -s "$BING_JSON_URL")

if [ $? -ne 0 ] || [ -z "$JSON_DATA" ]; then
    echo "❌ 获取壁纸 JSON 失败，请检查网络连接。"
    exit 1
fi

# 2. 解析 JSON 数据 (使用 jq)
# 提取所需字段
if command -v jq &> /dev/null; 键，然后
    # 使用 jq 提取字段
    ITEM=$(echo "$JSON_DATA" | jq -r '.images[0]')
    
    # 提取 url 并替换 1920x1080 为 UHD
    IMAGE_URL_PATH=$(echo "$ITEM" | jq -r '.url' | sed 's/1920x1080/UHD/')
    # 提取 startdate
    START_DATE=$(echo "$ITEM" | jq -r '.startdate')
    # 提取 title
    IMAGE_TITLE=$(echo "$ITEM" | jq -r '.title')
    # 提取 copyright (图片描述)
    IMAGE_COPYRIGHT=$(echo "$ITEM" | jq -r '.copyright')
else
    # 备用：如果无 jq，使用 sed（易错，不推荐）
    echo "⚠️ 正在使用 sed 进行 JSON 解析，如果标题包含特殊字符可能失败。"
    IMAGE_URL_PATH=$(echo "$JSON_DATA" | sed -E 's/.*"url":"([^"]+)".*/\1/' | sed 's/1920x1080/UHD/')
    START_DATE=$(echo "$JSON_DATA" | sed -E 's/.*"startdate":"([^"]+)".*/\1/')
    IMAGE_TITLE=$(echo "$JSON_DATA" | sed -E 's/.*"title":"([^"]+)".*/\1/')
    IMAGE_COPYRIGHT=$(echo "$JSON_DATA" | sed -E 's/.*"copyright":"([^"]+)".*/\1/')
fi

# 3. 构造文件名
# 清理文件名中的非法字符 (斜杠, 冒号, 问号, 反斜杠等)
CLEAN_TITLE=$(echo "${IMAGE_TITLE}_${IMAGE_COPYRIGHT}" | tr -d '\n' | sed 's/[/:\?\\*<>"|]/-/g') 

# 最终文件名：日期_清理后的标题和描述.jpg
# 使用 title + copyright 确保唯一性，解决同一天内容更新的问题
FILE_NAME="${START_DATE}_${CLEAN_TITLE}.jpg"
FULL_IMAGE_URL="${BING_BASE_URL}${IMAGE_URL_PATH}"
FILE_PATH="${WALLPAPER_DIR}/${FILE_NAME}"

echo "📌 今日壁纸："
echo "   - 日期: ${START_DATE}"
echo "   - 标题: ${IMAGE_TITLE}"
echo "   - 描述: ${IMAGE_COPYRIGHT}"
echo "🔗 下载 URL：${FULL_IMAGE_URL}"
echo "📂 文件名：${FILE_NAME}"

# 4. 下载壁纸
if [ -f "$FILE_PATH" ]; then
    echo "🖼 壁纸已存在：${FILE_NAME}"
    echo "▶️ 跳过下载，直接设置壁纸。"
else
    echo "⬇️ 正在下载壁纸..."
    curl -s -L -o "$FILE_PATH" "$FULL_IMAGE_URL"

    if [ $? -ne 0 ]; then
        echo "❌ 下载壁纸失败。"
        exit 1
    fi
    echo "📁 保存到：${FILE_PATH}"
fi

# 5. 设置为 macOS 壁纸
echo "🔄 正在设置壁纸..."

# AppleScript 变量需要处理路径中的引号
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
