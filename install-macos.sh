#!/bin/bash

echo "-------------------------------"
echo "Find Discord Path"

discordPath="/Applications/Discord.app/Contents"
if [ -d "$discordPath" ]; then
    echo "Discord Path: $discordPath"
else
    echo "Discord installation directory not detected"
    exit 1
fi

discordVersionDir=$(ls "$HOME/Library/Application Support/discord" | grep -E '^[0-9.]+$' | sort -V | tail -n1)
discordModules="$HOME/Library/Application Support/discord/$discordVersionDir/modules"

if [ -d "$discordModules" ]; then
    echo "Discord Modules: $discordModules"
else
    echo "Discord is missing the main file, please start Discord once normally, and then run it again"
    exit 1
fi

echo "-------------------------------"
echo "Find app.asar file..."
if [ ! -f "app.asar" ]; then
    echo "The app.asar file is not found in the current directory, start downloading from Github..."
    sudo curl -L 'https://github.com/XiaoXianHW/Discord-Skip-AutoUpdate/releases/download/AppAsar/app-macos.asar' -o app.asar

    fileSize=$(stat -f%z "app.asar")
    if [ $fileSize -ne 6173564 ]; then
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
originalAsar="$discordPath/Resources/app.asar"
if [ -f "$originalAsar" ]; then
    sudo mv "$originalAsar" "$discordPath/Resources/app.asar.bak"
    echo "Original app.asar has been backed up as $discordPath/Resources/app.asar.bak"
else
    echo "Original app.asar not found, skipping backup step"
fi

echo "-------------------------------"
echo "Update Discord's app.asar..."

if [ -d "$discordPath" ]; then
    sudo cp app.asar "$discordPath/Resources/"
    echo "app.asar has been replaced in $discordPath/Resources/"
else
    echo "Discord executable not found in /Applications"
    exit 1
fi

echo "-------------------------------"
echo "Discord-Skip-AutoUpdate installation Success!"