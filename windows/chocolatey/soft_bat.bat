@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
@echo off
set /P office='install word,excel,powerpoint?'
IF NOT "%office%" == "y" (
  set /P officeStandart='install Standard2019Volume?'
)
set /P all='install adoreader, Foxitreader, chocolateygui?!'
IF "%all%" == "y" (
  set adobe=y
  set foxit=y
  set gui=y
) ELSE (
  set /P adobe='install adoreader?'
  set /P foxit='install Foxitreader?'
  set /P gui='install chocolateygui?'
)
pause
choco install classic-shell -y
choco install firefox -y
choco install winrar -y
choco install googlechrome  -y
choco install radmin-server -y
choco install fsviewer -y
if "%gui%" == "y" (
  choco install chocolateygui -y
)
if "%adobe%" == "y" (
  choco install adobereader -y
)
if "%foxit%" == "y" (
  choco install foxitreader -y
)
if "%office%" == "y" (
  choco install microsoft-office-deployment -Parameters "/64bit /DisableUpdate:TRUE /Language:ru-ru /Product:Word2019Retail,Excel2019Retail,PowerPoint2019Retail" -y
)
if "%officeStandart%" == "y" (
  choco install microsoft-office-deployment -Parameters "/64bit /DisableUpdate:TRUE /Language:ru-ru /Product:Standard2019Volume" -y
)
pause
