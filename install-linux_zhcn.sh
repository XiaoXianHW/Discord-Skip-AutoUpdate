#!/bin/bash

echo "-------------------------------"
echo "查找Discord安装路径"

discordPath="/usr/share/discord"
if [ -d "$discordPath" ]; then
    echo "Discord 安装: $discordPath"
else
    echo "未检测到Discord安装目录
    exit 1
fi

if [ -d "$discordPath/modules" ]; then
    echo "Discord Modules: $discordPath/modules"
else
    echo "Discord缺少主要文件，请先完整启动一次Discord后再次运行"
    exit 1
fi

echo "-------------------------------"
echo "检测app.asar文件..."
if [ ! -f "app.asar" ]; then
    echo "当前目录下没有找到app.asar文件，开始从Github下载..."
    sudo wget 'https://github.com/XiaoXianHW/Discord-Skip-AutoUpdate/releases/download/AppAsar/app-linux.asar' -O app.asar

    fileSize=$(sudo stat -c%s "app.asar")
    if [ $fileSize -ne 6173526 ]; then
        echo "app.asar不完整，需要自行重新下载。"
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

echo "Discord未在运行"

echo "-------------------------------"
echo "更新Discord的app.asar..."

if [ -d "$discordPath" ]; then
    sudo cp app.asar "$discordPath/resources/"
    echo "app.asar已替换至 $discordPath/resources/"
else
    echo "没有找到 /usr/share"
    exit 1
fi

echo "-------------------------------"
echo "Discord-Skip-AutoUpdate更新成功!"

