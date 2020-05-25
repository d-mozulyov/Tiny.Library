@echo off
call compiler "win32" "sources.txt" "..\c\"
call compiler "win64" "sources.txt" "..\c\"
call compiler "mac32" "sources.txt" "..\c\"
call compiler "mac64" "sources.txt" "..\c\"
call compiler "linux32" "sources.txt" "..\c\"
call compiler "linux64" "sources.txt" "..\c\"
call compiler "android32" "sources.txt" "..\c\"
call compiler "android64" "sources.txt" "..\c\"
call compiler "ios32" "sources.txt" "..\c\"
call compiler "ios64" "sources.txt" "..\c\"
pause