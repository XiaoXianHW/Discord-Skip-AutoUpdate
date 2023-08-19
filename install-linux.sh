#!/bin/bash

echo "-------------------------------"
echo "Find Discord Path"

discordPath="/usr/share/discord"
if [ -d "$discordPath" ]; then
    echo "Discord Path: $discordPath"
else
    echo "Discord installation directory not detected"
    exit 1
fi

if [ -d "$discordPath/modules" ]; then
    echo "Discord Modules: $discordPath/modules"
else
    echo "Discord is missing the main file, please start Discord once normally, and then run it again"
    exit 1
fi

echo "-------------------------------"
echo "Find app.asar file..."
if [ ! -f "app.asar" ]; then
    echo "The app.asar file is not found in the current directory, start downloading from Github..."
    sudo wget 'https://github.com/XiaoXianHW/Discord-Skip-AutoUpdate/releases/download/AppAsar/app-linux.asar' -O app.asar

    fileSize=$(sudo stat -c%s "app.asar")
    if [ $fileSize -ne 6173526 ]; then
        echo "app.asar is incomplete and needs to be re-downloaded by itself."
        exit 1
    fi
fi

echo "app.asar is ready"

echo "-------------------------------"
echo "Checking Discord process..."
if pgrep "Discord" > /dev/null; then
    echo "Please close the Discord process before running this script"
    exit 1
fi

echo "Discord is not running"

echo "-------------------------------"
echo "Backup original app.asar..."
originalAsar="$discordPath/resources/app.asar"
if [ -f "$originalAsar" ]; then
    sudo mv "$originalAsar" "$discordPath/resources/app.asar.bak"
    echo "Original app.asar has been backed up as $discordPath/resources/app.asar.bak"
else
    echo "Original app.asar not found, skipping backup step"
fi

echo "-------------------------------"
echo "Update Discord's app.asar..."

if [ -d "$discordPath" ]; then
    sudo cp app.asar "$discordPath/resources/"
    echo "app.asar has been replaced in $discordPath/resources/"
else
    echo "Discord executable not found in /usr/share"
    exit 1
fi

echo "-------------------------------"
echo "Discord-Skip-AutoUpdate installation Success!"

