# macOS-Bing-Wallpaper-Setter
简易的设置必应每日壁纸 A shell script to automatically download and set daily Bing wallpaper on all macOS screens.

## 🖼 macOS 必应每日壁纸自动设置工具 (多屏幕兼容)


**`macOS-Bing-Wallpaper-Setter`** 是一个轻量级的 Shell 脚本，用于自动下载每日最新的 Bing 壁纸，并将其设置为 macOS 桌面背景。它特别优化了在**多显示器 (Multi-Screen)** 和 **多桌面空间 (Multiple Spaces)** 环境下的兼容性。

### ✨ 特性

* **多屏兼容：** 使用 `osascript` 循环遍历所有桌面实例 (`repeat with theDesktop in every desktop`)，确保在多个显示器和所有桌面空间上都能成功设置壁纸。
* **全自动下载：** 通过 Bing 官方 API 获取最新的壁纸 URL，并优先下载 **UHD (超高清)** 版本。
* **去重机制：** 如果当日壁纸已下载，则跳过下载，直接应用，节省时间和带宽。
* **Shell 原生实现：** 仅依赖 macOS 自带的 `curl` 和 `osascript`，无需安装 Python 或其他第三方依赖（如 `requests` 或 `jq`）。

### 🚀 使用方法

#### 1. 克隆或下载脚本

您可以将此脚本下载到您本地的任意目录。

**Bash**

```
# 建议下载到您的 ~/bin 目录或类似的工具目录
git clone https://github.com/ssesweb/macOS-Bing-Wallpaper-Setter.git
cd macOS-Bing-Wallpaper-Setter
```

#### 2. 授予执行权限

确保脚本拥有执行权限：

**Bash**

```
chmod +x bing_wallpaper_setter.sh
```

#### 3. 手动运行测试

您可以先运行一次脚本进行测试：

**Bash**

```
./bing_wallpaper_setter.sh
```

### ⚙️ 设置自动化 (推荐: 使用“快捷指令”)

为了实现您设定的“连接到指定 Wi-Fi 触发”功能，您可以使用 macOS 的 **“快捷指令” (Shortcuts)** 应用。

**步骤：**

1. 打开 macOS 上的 **“快捷指令”** 应用。
2. 切换到顶部的 **“自动化” (Automation)** 标签页。
3. 点击 **“新建自动化” (New Automation)** 或右上角的  **`+` 号** 。
4. 在触发器列表中，选择  **“Wi-Fi”** 。
5. 配置触发器：
   
   * **何时：** 选择  **“连接时” (When connected)** 。
   * **网络：** 选择您指定的 Wi-Fi 名称（例如您的家庭或办公室 Wi-Fi）。
6. 在动作 (Actions) 编辑区：
   
   * 搜索 **“运行 Shell 脚本” (Run Shell Script)** 动作并添加。
   * 在脚本框中，输入您的脚本的 **绝对路径** ：
   
   **Bash**
   
   ```
   /Users/tongli/Work/bing_wallpaper/bing_wallpaper_setter.sh
   ```
7. 确保底部的 **“运行时询问” (Ask Before Running)** 选项被 **关闭** ，以实现完全自动化。
8. 保存自动化。

这样，每当您的 Mac 连接到指定的 Wi-Fi 网络时，系统将自动运行脚本，更新您的多屏幕桌面壁纸。

### 📄 脚本依赖

* macOS (原生支持 `osascript`)
* `curl` (用于下载壁纸和获取 JSON 数据)
