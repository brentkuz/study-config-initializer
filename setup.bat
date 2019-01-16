powershell.exe Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

cd /D "%~dp0"

@Reg Add "HKCU\Software\Classes\Directory\shell\InitializeStudyConfig" /VE /D "Initialize &Study &Config" /F >Nul
@Reg Add "HKCU\Software\Classes\Directory\shell\InitializeStudyConfig\command" /VE /D "powershell.exe %CD%\Initialize-Config.ps1 \"%%L\"" /F >Nul









