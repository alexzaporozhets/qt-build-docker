@echo off

rem Setup build envirnment
set CWD=%~dp0
set SRCDIR=%CWD%
set SIGNTOOL=C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin\signtool.exe
set BITROCKCUSTOMIZE=C:\Program Files (x86)\BitRock InstallBuilder Professional 9.5.5\autoupdate\bin\customize.exe
set BITROCKBUILDER=C:\Program Files (x86)\BitRock InstallBuilder Professional 9.5.5\bin\builder-cli.exe
set SIGN_KEY=%CWD%\td_codesigncert_export.pfx
set SIGN_PASS="sgfocus111#"

rem Prepare installation directory
set DSTDIR=%CWD%\qthybrid-app-installer-bitrock

rmdir %DSTDIR%\output /s /q
mkdir %DSTDIR%\output

rmdir %DSTDIR%\mystaff-client /s /q
rem mkdir %DSTDIR%
%SRCDIR%\unzip -d %DSTDIR% %SRCDIR%\install-qthybrid-app\mystaff-client-windows-deployed.zip

set /p VERSION=<%DSTDIR%\mystaff-client\version

cd %DSTDIR%
if exist "%SIGN_KEY%" (
    for %%i in (mystaff-client\*.exe) do (
        echo Signing %%i
        "%SIGNTOOL%" sign /f "%SIGN_KEY%" /p "%SIGN_PASS%" /t "http://timestamp.globalsign.com/scripts/timstamp.dll" /du "http://www.timedoctor.com" "%%i"
    )
)

rem *** Generating the main installer package
"%BITROCKBUILDER%" build %CWD%\qthybrid-app-installer-bitrock\install-windows.xml windows --license %CWD%\qthybrid-app-installer-bitrock\license.xml --setvars v3_product_version=%VERSION%

if exist "output\setup-mystaff-client-%VERSION%-windows.exe" (
    copy "output\setup-mystaff-client-%VERSION%-windows.exe" "output\setup-mystaff-client-latest-windows.exe"
)

if exist "%SIGN_KEY%" (
    for %%i in (output\setup-mystaff-client-*.exe) do (
        echo Signing %%i
        "%SIGNTOOL%" sign /f "%SIGN_KEY%" /p "%SIGN_PASS%" /t "http://timestamp.globalsign.com/scripts/timstamp.dll" /du "http://www.timedoctor.com" "%%i"
    )
)

cd %CWD%
if exist "%DSTDIR%\output\setup-mystaff-client-%VERSION%-windows.exe" (
    mkdir "%CWD%\installs\installer-bitrock"
    move /Y "%DSTDIR%\output\setup-mystaff-client-*.exe" "%CWD%\installs\installer-bitrock"
    copy %DSTDIR%\mystaff-client\version "%CWD%\installs\"    
)
