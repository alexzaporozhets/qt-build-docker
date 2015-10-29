@echo off

rem Setup paths for Qt 5.4.2 library
set QTDIR=C:\Qt5\5.4.2-vs2010
set PATH=C:\OpenSSL\bin;C:\OpenCV.2410\build\x86\vc10\bin\;%QTDIR%\5.4\msvc2010_opengl\bin\;%QTDIR%\Tools\QtCreator\bin\;%PATH%

rem Setup paths fo default MSVS 2010 installation
set INCLUDE=C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\INCLUDE;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\include;
set LIB=C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\LIB;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\lib;C:\OpenCV.2410\build\x86\vc10\lib
set LIBPATH=C:\Windows\Microsoft.NET\Framework\v4.0.30319;C:\Windows\Microsoft.NET\Framework\v3.5;C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\LIB;
set PATH=C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\;C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\BIN;C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\Tools;C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\VCPackages;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\bin\NETFX 4.0 Tools;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\bin;%PATH%

rem Setup build envirnment
set CWD=%cd%
set SRCDIR=%CWD%\qthybrid-app
set /p SRCVER=<%SRCDIR%\mystaff-client\version
set TARGET=mystaff-client

echo "%PATH%"
echo "%CWD%"
echo "%SRCDIR%"
echo "%SRCVER%"

rmdir %CWD%\build-qthybrid-app /s /q
mkdir %CWD%\build-qthybrid-app

cd %CWD%\build-qthybrid-app

rem Configure sources for build
qmake -r -spec win32-msvc2010 %SRCDIR%\qthybrid-app.pro
if "%errorlevel%" NEQ "0" (
    echo "Configure failed!!!"
    cd %CWD%
    exit 1
) 

rem make 
jom.exe -f Makefile release
if "%errorlevel%" NEQ "0" (
    echo "Build failed!!!"
    cd %CWD%
    exit 2
) 

cd %CWD%

rem Prepare installation directory
set DSTDIR=%CWD%\install-qthybrid-app\%TARGET%
rmdir %DSTDIR% /s /q
mkdir %DSTDIR%

if exist "%CWD%\install-dir-template-windows.zip" (
    %CWD%\unzip -d %DSTDIR% %CWD%\install-dir-template-windows.zip
    if "%errorlevel%" NEQ "0" (
        cd %CWD%
        exit 3
    ) 
)

rem copy mystaff client files
cd %CWD%\build-qthybrid-app

rem Copy SQLCipher plugin
xcopy 3rdparty\sqlcipher\release\sqldrivers\*.dll %DSTDIR%\sqldrivers\*.* /D /Y /S /F
if "%errorlevel%" NEQ "0" (
    cd %CWD%
    exit 4
) 

rem Copy mystaff client version file
xcopy %SRCDIR%\mystaff-client\version %DSTDIR%\*.* /Y /S /F
if "%errorlevel%" NEQ "0" (
    cd %CWD%
    exit 5
)

rem Copy mystaff client executible file
xcopy mystaff-client\release\*.exe  %DSTDIR%\*.* /Y /S /F
if "%errorlevel%" NEQ "0" (
    cd %CWD%
    exit 5
) 

rem Copy internal libraries which are required for mystaff client
for %%i in (qntp qtsingleapplication) do (
    xcopy 3rdparty\%%i\release\*.dll  %DSTDIR%\*.dll /D /Y /S /F
    if "%errorlevel%" NEQ "0" (
        cd %CWD%
        exit 7
    ) 
)

rem Pack mystaff client 
cd %CWD%/install-qthybrid-app
%CWD%\zip -9 -r mystaff-client-windows.zip %TARGET%
if "%errorlevel%" NEQ "0" (
    cd %CWD%
    exit 8
) 


if exist "%CWD%\install-dir-qt5runtime-windows.zip" (
    %CWD%\unzip -d %DSTDIR% %CWD%\install-dir-qt5runtime-windows.zip
    if "%errorlevel%" NEQ "0" (
        cd %CWD%
        exit 3
    ) 
)

if exist "%CWD%\install-dir-qt5runtime-windows.zip" (
    %CWD%\unzip -d %DSTDIR% %CWD%\install-dir-opencvruntime-windows.zip
    if "%errorlevel%" NEQ "0" (
        cd %CWD%
        exit 3
    ) 
)

rem Deploy Qt library
windeployqt.exe --release %DSTDIR%\mystaff.exe 

rem Pack mystaff client 
cd %CWD%/install-qthybrid-app
%CWD%\zip -9 -r mystaff-client-windows-deployed.zip %TARGET%
if "%errorlevel%" NEQ "0" (
    cd %CWD%
    exit 8
) 

cd %CWD%\build-qthybrid-app

rem Copy SQLCipher plugin PDB file
xcopy 3rdparty\sqlcipher\release\sqldrivers\*.pdb %DSTDIR%\sqldrivers\*.* /D /Y /S /F
if "%errorlevel%" NEQ "0" (
    cd %CWD%
    exit 9
) 

rem Copy mystaff client PDB file
xcopy mystaff-client\vc*.pdb  %DSTDIR%\*.* /Y /S /F
xcopy mystaff-client\release\*.pdb  %DSTDIR%\*.* /Y /S /F
if "%errorlevel%" NEQ "0" (
    cd %CWD%
    exit 10
) 

rem Copy internal libraries which are required for mystaff client
for %%i in (qntp qtsingleapplication) do (
    xcopy 3rdparty\%%i\release\*.pdb  %DSTDIR%\*.pdb /D /Y /S /F
    if "%errorlevel%" NEQ "0" (
        cd %CWD%
        exit 11
    ) 
)

rem Pack mystaff client PDB files
rem forfiles /s /m *.txt /c "cmd /c echo @relpath"
cd %CWD%/install-qthybrid-app
%CWD%\zip -9 -r mystaff-client-pdb-windows.zip %TARGET% -i *.pdb 
if "%errorlevel%" NEQ "0" (
    cd %CWD%
    exit 12
) 

cd %CWD%

echo "%CWD%\install-qthybrid-app\mystaff-client-windows.zip"
REM echo "      install-qthybrid-app\mystaff-client-pdb-windows.zip"
exit 0
