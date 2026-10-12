@echo off
setlocal
set "MAVEN_WRAPPER_PS1=%~dp0.mvn\wrapper\maven-wrapper.ps1"
if not exist "%MAVEN_WRAPPER_PS1%" (
  echo Maven Wrapper script not found: "%MAVEN_WRAPPER_PS1%"
  exit /b 1
)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%MAVEN_WRAPPER_PS1%" %*
exit /b %ERRORLEVEL%
