@echo off
@
@rem This will ...
@
setlocal
echo **********************
set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_181
echo JAVA_HOME is set to:
echo %JAVA_HOME%
echo **********************
set ANT_OPTS=-Xms3G -Xmx3G
echo ANT_OPTS is set to:
echo %ANT_OPTS%
echo **********************
set PATH=c:\Oracle\instantclient_11_2;%PATH%
echo PATH is set to:
echo %PATH%
echo **********************
c:\Oracle\apache-ant-1.10.5\bin\ant %*
endlocal
@echo on