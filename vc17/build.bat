@echo off
setlocal ENABLEDELAYEDEXPANSION

REM Uso: build.bat [Release|Debug]
set CONFIG=%1
if "%CONFIG%"=="" set CONFIG=Release

echo [OTClient] Build via MSBuild (Config=%CONFIG%)

REM Localiza MSBuild via vswhere, se disponível
set VSWHERE="%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set MSBUILD=
if exist %VSWHERE% (
  for /f "usebackq tokens=*" %%i in (`%VSWHERE% -latest -products * -requires Microsoft.Component.MSBuild -property installationPath`) do set VSPATH=%%i
  if not "%VSPATH%"=="" (
    set MSBUILD="%VSPATH%\MSBuild\Current\Bin\MSBuild.exe"
  )
)

if "%MSBUILD%"=="" (
  REM fallback para MSBuild no PATH
  set MSBUILD=MSBuild.exe
)

echo Usando MSBuild: %MSBUILD%
"%MSBUILD%" "%~dp0otclient.sln" /m /p:Configuration=%CONFIG% /p:Platform=x64
if errorlevel 1 (
  echo Build falhou.
  exit /b 1
)

echo Build concluido com sucesso.
exit /b 0