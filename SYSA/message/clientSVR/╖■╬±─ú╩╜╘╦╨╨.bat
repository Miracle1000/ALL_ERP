net stop zbintelSVR
"%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe" /u %~dp0zbintelSVR.exe
"%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe" %~dp0zbintelSVR.exe
net start zbintelSVR
cls
echo "Æô¶¯Íê³É"
