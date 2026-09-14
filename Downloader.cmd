@echo off
chcp 65001 >nul
setlocal
title Downloader

set "params=--force-overwrites --quiet --progress --ignore-errors --windows-filenames"
set "params_aria2=--force-overwrites --quiet --progress --ignore-errors --windows-filenames --downloader aria2c"
set "outpath=%cd%"

:: Получаем URL из буфера обмена
for /f "usebackq delims=" %%i in (`powershell -noprofile -command "Get-Clipboard"`) do set "ClipboardData=%%i"

if not defined ClipboardData (
    echo Clipboard is empty
    pause
    exit /b
)

if "%1"=="audio" goto audio
if "%1"=="audio-aria2c" goto audio_aria
if "%1"=="video" goto video
if "%1"=="video" goto video1440
if "%1"=="video" goto video2160
if "%1"=="video-aria2c" goto video_aria
if "%1"=="image" goto image

echo No mode specified (audio/video)
pause
exit /b


:video
title Downloading video
echo Downloading video URL: %ClipboardData%

yt-dlp ^
--yes-playlist ^
--embed-metadata ^
-o "%outpath%\%%(playlist_title|.)s\%%(title)s.%%(ext)s" ^
-f "bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/best" ^
%params% ^
"%ClipboardData%"

goto end

:video1440
title Downloading video
echo Downloading video URL: %ClipboardData%

yt-dlp ^
--yes-playlist ^
--embed-metadata ^
-o "%outpath%\%%(playlist_title|.)s\%%(title)s.%%(ext)s" ^
-f "bestvideo[ext=mp4][height<=1440]+bestaudio[ext=m4a]/best" ^
%params% ^
"%ClipboardData%"

goto end

:video2160
title Downloading video
echo Downloading video URL: %ClipboardData%

yt-dlp ^
--yes-playlist ^
--embed-metadata ^
-o "%outpath%\%%(playlist_title|.)s\%%(title)s.%%(ext)s" ^
-f "bestvideo[ext=mp4][height<=2160]+bestaudio[ext=m4a]/best" ^
%params% ^
"%ClipboardData%"

goto end

:video_aria
title Downloading video (aria2c)
echo Downloading video (aria2c)...

yt-dlp ^
--yes-playlist ^
--embed-metadata ^
-o "%outpath%\%%(playlist_title|.)s\%%(title)s.%%(ext)s" ^
-f "bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/best" ^
%params_aria2% ^
"%ClipboardData%"

goto end


:audio
title Downloading audio
echo Downloading URL: %ClipboardData%

yt-dlp ^
--yes-playlist ^
--extract-audio ^
--audio-format m4a ^
--audio-quality 0 ^
--embed-metadata ^
--embed-thumbnail ^
-o "%outpath%\%%(playlist_title|.)s\%%(title)s.%%(ext)s" ^
%params% ^
"%ClipboardData%"

goto end


:audio_aria
title Downloading audio (aria2c)
echo Downloading audio (aria2c)...

yt-dlp ^
--yes-playlist ^
--extract-audio ^
--audio-format m4a ^
--audio-quality 0 ^
--embed-metadata ^
--embed-thumbnail ^
-o "%outpath%\%%(playlist_title|.)s\%%(title)s.%%(ext)s" ^
%params_aria2% ^
"%ClipboardData%"

goto end


:image
title Downloading images
echo Downloading images URL: %ClipboardData%

gallery-dl "%ClipboardData%" --dest "%outpath%"

goto end


:end
echo.
echo Done.
endlocal