<%@ language=VBScript %>
<%
	num1=session("num_click2009cp")
	num1=num1+1
	'num1=session("num_click2009cp")
	session("num_click2009cp")=num1
	Response.write(""&num1&"")
	
%>
