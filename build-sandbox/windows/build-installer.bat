@echo off

rem Setup build envirnment
set CWD=%~dp0
set SRCDIR=%CWD%
set SIGNTOOL=C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin\signtool.exe
set SIGN_KEY=%CWD%\td_codesigncert_export.pfx
set SIGN_PASS="sgfocus111#"

rem Prepare installation directory
set DSTDIR=%CWD%\qthybrid-app-installer\windows\packages\com.mystaff.mystaffclient

rmdir %DSTDIR%\data /s /q
rem mkdir %DSTDIR%
%SRCDIR%\unzip -d %DSTDIR% %SRCDIR%\install-qthybrid-app\mystaff-client-windows.zip 

cd %DSTDIR%
ren mystaff-client data
if exist "%SIGN_KEY%" (
    for %%i in (data\*.exe) do (
        echo Signing %%i
        "%SIGNTOOL%" sign /f "%SIGN_KEY%" /p "%SIGN_PASS%" /t "http://timestamp.globalsign.com/scripts/timstamp.dll" /du "http://www.timedoctor.com" "%%i"
    )
)

cd %SRCDIR%\install-qthybrid-app
call %CWD%\qthybrid-app-installer\windows\build.bat

if exist "%SIGN_KEY%" (
    for %%i in (setup-mystaff-client-*.exe) do (
        echo Signing %%i
        "%SIGNTOOL%" sign /f "%SIGN_KEY%" /p "%SIGN_PASS%" /t "http://timestamp.globalsign.com/scripts/timstamp.dll" /du "http://www.timedoctor.com" "%%i"
    )
)
