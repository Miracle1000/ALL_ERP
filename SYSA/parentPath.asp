<!--#include file="dll/dllvarname.asp"-->
<%
On Error Resume Next
'缓存检测
Response.clear
response.CharSet = "utf-8"
If Err.number <> 0 Then 
	Response.write "<html><body>CHACEER</body></html><!--" & err.Description & "-->"
	Response.end
End If

'父路径检测
p = server.mappath("../default.asp")
If Err.number <> 0 Then  
	Response.write "<html><body>ERROR</body></html><!--" & err.Description & "-->"
	Response.End
End If

'组件检测
Set obj = server.createobject(ZBRLibDLLNameSN & ".Library")
If Err.number <> 0 Then  
	Response.write "<html><body>DLLERR</body></html><!--" & err.Description & "-->"
	Response.End
End if
Set obj = Nothing

Response.write "<html><body></body></html>"
%>