<%
dim maxv, lasttime
maxv =  request.Form("maxv")
uid = session("personzbintel2007")
lasttime = session("sys_userlastvistime")
'
if len(lasttime) = 0 or len(uid) = 0 or isnumeric(uid) = false or len(maxv) = 0 or  isnumeric(maxv) = false  then
    session("personzbintel2007") = ""
    response.write "1"
   response.Cookies("sys_isutimeout") = 0   '
    response.end
end if

'
if abs(datediff("s",lasttime,now)) > maxv*1 then
    session("personzbintel2007") = ""
    session("sys_userlastvistime") = now
    response.Cookies("sys_isutimeout") = 1
    response.write "1"
else
    response.Cookies("sys_isutimeout") = 0
    response.Write "0=[maxv=" & maxv & "] lasttime={" & lasttime & "} now=" & now  & "   dt=" & abs(datediff("s",lasttime,now)) 
end if
%>