<!--#include file="dll/dllvarname.asp"-->
<%
if request.QueryString("msg")="timeformatcheck" then
	Dim obj 
	Set obj = server.createobject(ZBRLibDLLNameSN & ".Library")  '此代码用于 ASP 初始化 DB.asp信息,  初始化 application("sys.info.configindex") 等参数
	set obj = nothing
	response.write "window.DBInfoInited=1;"
	response.End
end if
Response.redirect "../sysn/view/init/default.ashx"
%>