chcp 65001
@echo off
setlocal enabledelayedexpansion

echo.
echo.
echo.
echo.
echo.
echo.

echo ------------------------------
echo 查找Discord安装路径
set discordPath="%LOCALAPPDATA%\Discord"
if exist !discordPath! (
    echo Discord安装: !discordPath!
) else (
    echo 未检测到Discord安装目录
    pause
	exit /b
)

set discordRoamingPath="%USERPROFILE%\AppData\Roaming\discord"
if exist !discordRoamingPath! (
    echo Discord用户: !discordRoamingPath!
) else (
    echo Discord缺少主要文件，请先完整启动一次Discord后再次运行
    pause
	exit /b
)

echo ------------------------------
echo 检测app.asar文件...
if not exist app.asar (
    echo 当前目录下没有找到app.asar文件，开始从Github下载...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/XiaoXianHW/Discord-Skip-AutoUpdate/releases/download/AppAsar/app-win.asar' -OutFile 'app.asar'"

    for %%I in (app.asar) do set fileSize=%%~zI
	
    if not !fileSize!==6173488 (
        echo app.asar不完整，需要自行重新下载。
        pause
		exit /b
    )
)
echo app.asar已就绪

echo ------------------------------
echo 检查Discord进程...
tasklist | findstr /i "Discord.exe" >nul
if not errorlevel 1 (
    echo 请关闭Discord进程后再运行本脚本
    pause
	exit /b
)
echo Discord未在运行

echo ------------------------------
echo 更新Discord的app.asar...
for /d %%a in ("!discordPath!\app-*") do (
    set discordAppDir=%%a
    break
)

if defined discordAppDir (
    copy /Y app.asar "!discordAppDir!\resources\"
    echo app.asar已替换至!discordAppDir!\resources\
) else (
    echo 没有找到Discord的app-*目录
    pause
	exit /b
)

echo ------------------------------
echo 复制Modules到Discord用户路径...

for /f "tokens=2 delims=-" %%b in ("!discordAppDir!") do (
    set "versionNumber=%%b"
)

set "sourceDir=!discordPath!\app-!versionNumber!\modules"
set "destDir=!discordRoamingPath!\!versionNumber!\modules"

for /d %%c in ("!sourceDir!\*") do (
    for /d %%d in ("%%c\*") do (
        echo 正在复制: %%d -> !destDir!\%%~nd
        xcopy /E /I "%%d" "!destDir!\%%~nd\"
    )
)
echo.
echo Modules复制完成

echo ------------------------------
echo 更新Discord开始菜单快捷方式...

set startMenuLink="%APPDATA%\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
if exist !startMenuLink! (
    del !startMenuLink!
)
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('!startMenuLink!'); $Shortcut.TargetPath = '!discordAppDir!\Discord.exe'; $Shortcut.Save()"

echo 更新Discord桌面快捷方式...
for /f "tokens=2*" %%a in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop') do set desktopPath=%%b
set desktopLink="!desktopPath!\Discord.lnk"
if exist "!desktopLink!" (
    del "!desktopLink!"
)
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('!desktopLink!'); $Shortcut.TargetPath = '!discordAppDir!\Discord.exe'; $Shortcut.Save()"

echo Discord快捷方式已更新。

echo ------------------------------
echo Discord-Skip-AutoUpdate已应用

pause
