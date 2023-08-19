#!/bin/bash

echo "-------------------------------"
echo "查找Discord安装路径"

discordPath="/Applications/Discord.app/Contents"
if [ -d "$discordPath" ]; then
    echo "Discord 安装: $discordPath"
else
    echo "未检测到Discord安装目录"
    exit 1
fi

discordVersionDir=$(ls "$HOME/Library/Application Support/discord" | grep -E '^[0-9.]+$' | sort -V | tail -n1)
discordModules="$HOME/Library/Application Support/discord/$discordVersionDir/modules"

if [ -d "$discordModules" ]; then
    echo "Discord Modules: $discordModules"
else
    echo "Discord缺少主要文件，请先完整启动一次Discord后再次运行"
    exit 1
fi

echo "-------------------------------"
echo "检测app.asar文件..."
if [ ! -f "app.asar" ]; then
    echo "当前目录下没有找到app.asar文件，开始从Github下载..."
    sudo curl -L 'https://github.com/XiaoXianHW/Discord-Skip-AutoUpdate/releases/download/AppAsar/app-macos.asar' -o app.asar

    fileSize=$(stat -f%z "app.asar")
    if [ $fileSize -ne 6173564 ]; then
        echo "app.asar不完整，需要自行重新下载"
        exit 1
    fi
fi

echo "app.asar已就绪"

echo "-------------------------------"
echo "检查Discord进程..."
if pgrep "Discord" > /dev/null; then
    echo "请关闭Discord进程后再运行本脚本"
    exit 1
fi

echo "Discord 未在运行"

echo "-------------------------------"
echo "备份app.asar..."
originalAsar="$discordPath/Resources/app.asar"
if [ -f "$originalAsar" ]; then
    sudo mv "$originalAsar" "$discordPath/Resources/app.asar.bak"
    echo "已备份app.asar: $discordPath/Resources/app.asar.bak"
else
    echo "app.asar文件不存在，跳过备份步骤"
fi

echo "-------------------------------"
echo "更新Discord的app.asar..."

if [ -d "$discordPath" ]; then
    sudo cp app.asar "$discordPath/Resources/"
    echo "app.asar已替换至 $discordPath/Resources/"
else
    echo "没有找到Discord文件: /Applications"
    exit 1
fi

echo "-------------------------------"
echo "Discord-Skip-AutoUpdate更新成功!"