@echo off
set "curpath=%~dp0"

winget install yt-dlp.yt-dlp
winget install aria2.aria2
winget install mikf.gallery-dl

copy /Y "%curpath%\Downloader.ico" "%windir%\Downloader.ico"
copy /Y "%curpath%\Downloader.cmd" "%windir%\Downloader.cmd"

reg import "%curpath%\Downloader.reg"