%windir%\system32\iisreset.exe /stop
%windir%\system32\regsvr32.exe "%~dp0ZBRLib3205.dll" -s
%windir%\SysWOW64\regsvr32.exe "%~dp0ZBRLib3205.dll" -s
%windir%\system32\regsvr32.exe "%~dp0ZSMLLibrary.dll" -s
%windir%\SysWOW64\regsvr32.exe "%~dp0ZSMLLibrary.dll" -s 
%windir%\system32\regsvr32.exe "%~dp0TLBINF32.DLL" -s
%windir%\SysWOW64\regsvr32.exe "%~dp0TLBINF32.DLL" -s
%windir%\Microsoft.NET\Framework\v4.0.30319\RegAsm.exe  /codebase  "%~dp0ZBXML.dll"
%windir%\Microsoft.NET\Framework\v4.0.30319\RegAsm.exe  /codebase  "%~dp0..\..\.extra_dlls\ZBSession.dll"
%windir%\Microsoft.NET\Framework\v4.0.30319\RegAsm.exe "%~dp0..\..\.extra_dlls\ZBAspRedis.dll"   /tlb:ZBAspRedis.tlb /codebase 
copy "%~dp0sqlite\x64\SQLite.Interop.dll" "%windir%\system32\SQLite.Interop.dll"
copy "%~dp0sqlite\x86\SQLite.Interop.dll" "%windir%\syswow64\SQLite.Interop.dll"
copy "%~dp0ZBLib\ZBCommLib_x86.dll" "%windir%\syswow64\ZBCommLib_x86.dll"
copy "%~dp0ZBLib\ZBCommLib_x64.dll" "%windir%\system32\ZBCommLib_x64.dll"
%windir%\system32\regsvr32.exe "%~dp0ZBCodeExt.dll" -s
%windir%\SysWOW64\regsvr32.exe "%~dp0ZBCodeExt.dll" -s
%windir%\system32\regsvr32.exe "%~dp0ZBA3205001.dll" -s
%windir%\SysWOW64\regsvr32.exe "%~dp0ZBA3205001.dll" -s
%windir%\system32\iisreset.exe /start
echo "DLL Reg Completed!"