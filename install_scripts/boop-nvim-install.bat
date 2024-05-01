@echo off

SET install_target="%~dp0..\bin\boop.exe"
SET repo="gmvi/Boop.nvim"
SET tag="v0.1.0-beta.2"

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && SET OS=32BIT || SET OS=64BIT

:: Not supporting 32-bit windows
IF %OS%==64BIT (SET platform="Win64") ELSE (exit /b 132)

::for /f "tokens=3" %%i in ('reg Query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber') do SET Build=%%i
:: Not supporting Windows XP for prebuilt binary download
::IF %Build% LSS 7000 (exit /b 107)

SET prebuilt_bin_url="https://github.com/%repo%/releases/download/%tag%/boop-%platform%.exe"
:: Windows 10+ comes with curl, and prior version are deprecated;
:: but older 64-bit Windows should work, so try to download if curl.exe is available.
where curl.exe >NUL 2>NUL
IF NOT ERRORLEVEL 1 (
    REM : Forcing %install_target% into a %% to enable %%~dp
    for %%F in (%install_target%) do mkdir %%~dpF
    curl.exe -Lso "%install_target%" "%prebuilt_bin_url%"
) ELSE (
    exit /b 107
)

