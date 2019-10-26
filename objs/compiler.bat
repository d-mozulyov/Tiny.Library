@echo off
setlocal enabledelayedexpansion

set platform=%~1
set file=%~2
set folder=%~3
set target=unknown
set flags=-c -O3

if "%platform%"=="win32" (
  set target=i386-windows-gnu -mno-sse
) else if "%platform%"=="win64" (
  set target=x86_64-windows-gnu
) else if "%platform%"=="linux32" (
  set target=i386-linux-gnu -mno-sse
) else if "%platform%"=="linux64" (
  set target=x86_64-linux-gnu
) else if "%platform%"=="mac32" (
  set target=i386-darwin-gnu -mno-sse
) else if "%platform%"=="mac64" (
  set target=x86_64-macos-gnu
) else if "%platform%"=="android32" (
  set target=armv7-a-linux-android -mthumb
) else if "%platform%"=="android64" (
  set target=aarch64-linux-android
) else if "%platform%"=="ios32" (
  set target=armv7-a-darwin-gnu -mthumb
) else if "%platform%"=="ios64" (
  set target=arm64-darwin-gnu
) else (
  echo error: unknown platform "%platform%"
  goto :done
)

if not exist "%file%" (
  echo error: compiled filed "%file%" not found
  goto :done
)

echo platform "%platform%":
if not exist "%platform%\" mkdir %platform%

set fileext=
for %%f in ("%file%") do set fileext=%%~xf
if "%fileext%"==".txt" (
  for /F "tokens=*" %%a in (%file%) do call :compile %%a
) else (
  call :compile %file%
)
goto :done

:compile
set sourcefile=%folder%%1
set targetfile=%platform%\%~n1.o
echo %sourcefile%
if not exist "%sourcefile%" (
  echo error: file not found!
  goto :eof
)

call clang -target %target% %flags% "%sourcefile%" -o"%targetfile%"
if "%platform%"=="win32" (
  coff2omf %targetfile%
  omf2d %targetfile%
)

goto :eof


:done