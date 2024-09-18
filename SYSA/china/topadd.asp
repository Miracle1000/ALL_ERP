<%@ language=VBScript %>
<%
	if session("top1zbintel2007")="1" then
		ids="../../SYSN/view/magr/Accountlist.ashx"
	else
		ids="../manager/pw.asp"
	end if
	Response.redirect ids
	
%>
