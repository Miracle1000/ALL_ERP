<%@ language=VBScript %>
<%
session("RSA_ALL") = ""
If Len(request.querystring) > 0 then'
Response.redirect "../sysn/view/init/login.ashx?" & request.querystring
else
Response.redirect "../sysn/view/init/login.ashx"
end if

%>
