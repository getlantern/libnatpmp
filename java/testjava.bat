@echo off
set JAVA=java
set JAVAC=javac
REM notice the semicolon for Windows.  Write once, run ... oh nevermind
set CP=natpmp_win32.jar;.

%JAVAC% -cp "%CP%" TestJava.java || exit 1
%JAVA% -cp "%CP%" TestJava 12345 UDP || exit 1
