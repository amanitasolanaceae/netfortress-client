@echo off
set LOGFILE=manifest.txt
call :LOG > %LOGFILE%
exit /B

:LOG
dir /b /s /a:-D | findstr /v /i "\.txt$"