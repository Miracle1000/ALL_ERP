md "%~dp0SYSA\bin\"  /s /e /y
xcopy "%~dp0bin"  "%~dp0SYSA\bin\" /s /e /y
copy "%~dp0Global.asax"  "%~dp0SYSA\Global.asax" /y
pause