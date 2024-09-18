<%
function GetHttpType
	dim loginurl 
	loginurl = session("clientloginurl") 
	if instr(1, loginurl, "https://", 1)>0 then
			GetHttpType = "https"
	else
			GetHttpType = "http"
	end if 
end function

Dim fso, size, fpath, host
fpath = server.mappath("zbintelsetup.exe")
If  Request.ServerVariables("Server_Port") = 80 then
	host = GetHttpType() &  "://" &  request.servervariables("Http_Host") & Request.ServerVariables("url")
Else
	host = GetHttpType() &  "://" &  request.servervariables("Http_Host") & ":" & Request.ServerVariables("Server_Port") & Request.ServerVariables("url")
End if
host = Replace(host,"/ocx/down.asp","",1,-1,1)
Call Response.AddHeader("Content-Disposition","attachment;filename=zbintelsetup.exe")
Call Response.AddHeader("content-type","application/octet-stream")
call Response.AddHeader("Accept-Ranges", "bytes")
Call Response.AddHeader("Pragma","No-Cache")
set fso = server.createobject("Scripting.FileSystemObject")
size =fso.GetFile(fpath).Size
Call Response.AddHeader("content-length", size*1 + Len("#split#" & host) + 1)
Set fso = Nothing 
%>
<!--#include file="zbintelsetup.exe"-->
<%
Response.write "#split#" & host & " "
%>