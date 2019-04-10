rem download and run
rem curl https://raw.githubusercontent.com/posiyans/scrips/master/windows/chocolatey/soft_bat.bat --output %TEMP%\start.bat && %TEMP%\start.bat

@echo off
set /P AllowInsecureGuestAuth='Allow Insecure Guest Auth???'
IF "%AllowInsecureGuestAuth%" == "y" (
    set /P localbat='Start local.bat??'
)
set /P officeStandart='install word,excel,powerpoint and outlook??'
IF NOT "%officeStandart%" == "y" (
  set /P office='install word,excel,powerpoint??'
)
set /P all='install adoreader, Foxitreader, chocolateygui, radmin-server?!'

IF "%all%" == "y" (
  set adobe=y
  set foxit=y
  set gui=y
  set radmin=y
) ELSE (
  set /P adobe='install adoreader?'
  set /P foxit='install Foxitreader?'
  set /P gui='install chocolateygui?'
  set /P radmin='install radmin-server?'
)
pause
IF "%AllowInsecureGuestAuth%" == "y" (
    reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation /v AllowInsecureGuestAuth /t reg_dword /d 00000001 /f
    reg add HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters /v AllowInsecureGuestAuth /t reg_dword /d 00000001 /f
)
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
choco install classic-shell -y
choco install firefox -y
choco install winrar -y
choco install googlechrome  -y
choco install fsviewer -y
IF "%radmin%" == "y" (
  choco install radmin-server -y
)
IF "%gui%" == "y" (
  choco install chocolateygui -y
)
IF "%adobe%" == "y" (
  choco install adobereader -y
)
IF "%foxit%" == "y" (
  choco install foxitreader -y
)
IF "%office%" == "y" (
  choco install microsoft-office-deployment -Parameters "/64bit /DisableUpdate:TRUE /Language:ru-ru /Product:Word2019Retail,Excel2019Retail,PowerPoint2019Retail" -y
)
IF "%officeStandart%" == "y" (
  choco install microsoft-office-deployment -Parameters "/64bit /DisableUpdate:TRUE /Language:ru-ru /Product:Word2019Retail,Excel2019Retail,PowerPoint2019Retail,Outlook2019Retail" -y
)

IF "%localbat%" == "y" (
    \\files\it\soft\install\start.bat
)
pause
