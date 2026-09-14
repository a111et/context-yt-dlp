@echo off

del /s /f /q "%windir%\Downloader.ico"
del /s /f /q "%windir%\Downloader.cmd"

reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\background\shell\Downloader" /f