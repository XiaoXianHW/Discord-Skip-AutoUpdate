@echo off
setlocal enabledelayedexpansion

echo.
echo.
echo.
echo.
echo.
echo.

echo ------------------------------
echo Find Discord installation Path
set discordPath="%LOCALAPPDATA%\Discord"
if exist !discordPath! (
    echo Discord Path: !discordPath!
) else (
    echo Discord installation directory not detected
    pause
	exit /b
)

set discordRoamingPath="%USERPROFILE%\AppData\Roaming\discord"
if exist !discordRoamingPath! (
    echo Discord userdata: !discordRoamingPath!
) else (
    echo Discord is missing the main file, please start Discord once normally, and then run it again
    pause
	exit /b
)

echo ------------------------------
echo Find app.asar file...
if not exist app.asar (
    echo The app.asar file is not found in the current directory, start downloading from Github...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/XiaoXianHW/Discord-Skip-AutoUpdate/releases/download/AppAsar/app.asar' -OutFile 'app.asar'"

    for %%I in (app.asar) do set fileSize=%%~zI
	
    if not !fileSize!==6173488 (
        echo app.asar is incomplete and needs to be re-downloaded by itself.
        pause
		exit /b
    )
)
echo app.asar is ready

echo ------------------------------
echo Checking Discord progress...
tasklist | findstr /i "Discord.exe" >nul
if not errorlevel 1 (
    echo Please close the Discord process before running this install.bat
    pause
	exit /b
)
echo Discord is not running

echo ------------------------------
echo Update Discord's app.asar...
for /d %%a in ("!discordPath!\app-*") do (
    set discordAppDir=%%a
    break
)

if defined discordAppDir (
    copy /Y app.asar "!discordAppDir!\resources\"
    echo app.asar has been replaced by !discordAppDir!\resources\
) else (
    echo Discord's app-* directory not found
    pause
	exit /b
)

echo ------------------------------
echo Copy Modules to Discord user path...

for /f "tokens=2 delims=-" %%b in ("!discordAppDir!") do (
    set "versionNumber=%%b"
)

set "sourceDir=!discordPath!\app-!versionNumber!\modules"
set "destDir=!discordRoamingPath!\!versionNumber!\modules"

for /d %%c in ("!sourceDir!\*") do (
    for /d %%d in ("%%c\*") do (
        echo Copy: %%d -> !destDir!\%%~nd
        xcopy /E /I "%%d" "!destDir!\%%~nd\"
    )
)
echo.
echo Modules copied

echo ------------------------------
echo Updating Discord start menu shortcuts...

set startMenuLink="%APPDATA%\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
if exist !startMenuLink! (
    del !startMenuLink!
)
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('!startMenuLink!'); $Shortcut.TargetPath = '!discordAppDir!\Discord.exe'; $Shortcut.Save()"

echo Updating the Discord desktop shortcut...
for /f "tokens=2*" %%a in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop') do set desktopPath=%%b
set desktopLink="!desktopPath!\Discord.lnk"
if exist "!desktopLink!" (
    del "!desktopLink!"
)
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('!desktopLink!'); $Shortcut.TargetPath = '!discordAppDir!\Discord.exe'; $Shortcut.Save()"

echo The Discord shortcut has been updated.

echo ------------------------------
echo Discord-Skip-AutoUpdate install Success!

pause
