<%
response.charset="UTF-8"
Dim ac, obj, cmd
cmd = request.querystring("cmd")
ac  = request.querystring("ac")
' Select Case LCase(cmd)
' 	Case "":  response.Redirect "../SYSN/view/init/keeper.ashx?" & request.QueryString
' 	Case "starthang":  response.Redirect "../SYSN/view/init/keeper.ashx?" & request.QueryString
' 	Case "stophang":   response.Redirect "../SYSN/view/init/keeper.ashx?" & request.QueryString
' 	Case "clearzbnetu": Response.cookies("ZBNETU") = "": Response.write("<script>parent.parent.onfrmload();</script>")
' End Select
%>