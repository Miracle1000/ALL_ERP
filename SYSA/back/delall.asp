<%@ language=VBScript %>
<%
ZBRLibDLLNameSN = "ZBRLib3205"
Set zblog = server.createobject(ZBRLibDLLNameSN & ".ZBSysLog")
zblog.init me
'ZBRLibDLLNameSN = "ZBRLib3205"
Function EnCrypt(m)
Dim bc : Set bc = server.createobject(ZBRLibDLLNameSN & ".Base64Class")
EnCrypt = bc.EnCrypt(m & "") : Set bc = nothing
end function
Function DeCrypt(m)
Dim bc : Set bc = server.createobject(ZBRLibDLLNameSN & ".Base64Class")
DeCrypt = bc.DeCrypt(m & "") : Set bc = nothing
end function
Function pwurl(ByVal theNumber)
If isnumeric(theNumber)=False Then pwurl = "" : Exit Function
If LCase(typename(Sdk))<>"commclass" Then
Dim sdktmp :Set sdktmp = server.createobject(ZBRLibDLLNameSN & ".CommClass")
pwurl = sdktmp.VBL.EncodeNum(CLng(theNumber), server)
Set sdktmp = Nothing
else
pwurl = ZBRuntime.Sdk.VBL.EncodeNum(CLng(theNumber), server)
end if
end function
Function deurl(theNumber)
If Len(theNumber&"") > 0 Then
If InStr(theNumber,"%")>0 Then
Dim b64 : Set b64 = server.createobject(ZBRLibDLLNameSN & ".Base64Class")
theNumber = b64.UrlDecodeByUtf8(theNumber)
Set b64 = nothing
end if
Dim v : v = ZBRuntime.Sdk.VBL.DecodeNum(theNumber & "") & ""
if v ="" Or isnumeric(v) = False then
deurl="-1"
else
deurl=v
end if
end if
end function
call ProxyUserCheck()
function IsNumeric(byval v)
dim r :  r = ""
if len(v & "")=0 then IsNumeric = false : exit function
on error resume next
r  = replace((v & ""),",","")*1
IsNumeric = len(r & "") >0
end function
function zbcdbl(byval v)
if len(v & "") = 0 or IsNumeric(v & "")=False then  zbcdbl = 0 : exit function
zbcdbl = cdbl(v)
end function
If Application("dis_sql_safe_check") = "" Then
If comSqlSafeCheck = False Then
if instr(lcase(request.ServerVariables("URL")),"checkin2.asp") > 0 Then
Response.clear
end if
Response.end
end if
end if
Sub ShowErrorMsg(ByVal title, ByVal code, ByVal errmsg)
Dim c : On Error Resume Next
Set c = server.createobject(ZBRLibDLLNameSN & ".CommClass")
Dim vp : vp = ""
vp = c.getvirpath
Response.clear
If InStr(lcase(code),"<script>") > 0 Then
Response.write Replace(code, "@virpath", vp)
else
Response.write "<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'/><title>系统信息</title><style>.r{color:red}</style><link href='" & vp & "inc/cskt.css' rel='stylesheet' "&_
"type='text/css'/></head><body><table width='100%'  border='0' align='center' cellpadding='0' cellspacing='0' bgcolor='#FFFFFF'><tr><td width='100%' valign='top'>" &_
"<table width='100%' border='0' cellpadding='0' cellspacing='0' background='" & vp & "images/m_mpbg.gif'>" &_
"<tr><td class='place'>" & title & "</td><td>&nbsp;</td><td align='right'>&nbsp;</td><td width='3'><img src='" & vp & "images/m_mpr.gif' width='3' height='32' /></td></tr></table></td></tr>" &_
"<tr><td style='border-top:1px solid #c0ccdd'><div style='padding:20px;line-height:24px'>"
Response.write Replace(code, "@virpath", vp)
If Len(errmsg) > 0 Then
Response.write "<div id='errordiv' style='background-color:#f2f2f2;color:blue;font-family:arial,宋体;margin:10px auto;text-align:center;border:1px dotted #ccc;padding:10px;width:50%;display:none'>异常描述：" & errmsg & "</div>"
end if
Response.write "</td></td></tr></table><table width='100%' cellspacing='0' style='border-top:1px solid #c0ccdd'><tr><td class='page'>&nbsp;</td></tr></table><script>function showerror(){var box=document.getElementById(""errordiv"").style;box.display=box.display==""none""?""block"":""none""}</script></body></html>"
end if
Response.end
Set c = nothing
end sub
Sub InitSysRuntimeVar
Set ZBRuntime = server.createobject(ZBRLibDLLNameSN & ".Library")
If ZBRuntime.SplitVersion <3173 Then Response.write "<br><br><br><br><center style='color:red;font-size:12px'>系统提示：运行库组件版本不正确。</center>" : Response.end
if ZBRuntime.loadOK=False  Then
Set sdk = server.createobject(ZBRLibDLLNameSN & ".CommClass")
Call ZBRuntime.setDefLCID(Session)
sdk.init me
else
If InStr(lcase(request.ServerVariables("URL")),"index2.asp") = 0 Then
ShowErrorMsg "","<script>top.window.location.href ='@virpathindex2.asp?id2=8'</script>",""
else
ShowErrorMsg  "系统加载失败", "<center style='color:red'>系统运行组件未获取到正确的签名信息.</center>",""
end if
end if
end sub
function comSqlSafeCheck
dim disCheckUrl , disSqlCheck , i
disCheckUrl = "contract/moban_dy.asp|contract/moban_dy2.asp|email/creatAttach.asp"
disCheckUrl = split(disCheckUrl,"|")
for i = 0 to ubound( disCheckUrl )
if instr(lcase(request.ServerVariables("URL")),disCheckUrl(i)) > 0 Then
comSqlSafeCheck = true
exit function
end if
next
Dim fromurl : fromurl = Replace(Request.ServerVariables("Http_Referer"),"""","\""")
dim keydatas,keylist,Sql_Post,ii, SqlKeys,hsQ
keydatas = "'|exec |insert |select |delete |update |truncate |execute |shell |union |drop |create |<script|alert |confirm |eval "
SqlKeys = Array( vbtab,  vbcr,  vblf,  "(",  "--", "/*")
keylist = split(keydatas,"|")
Dim n1,  n2,  n3
If Request.QueryString<>"" Then
For Each qname In Request.QueryString
n1 = Request.QueryString(qname)
For ii=0 To Ubound(keylist)
n2 = keylist(ii)
hsQ = instr(lcase(n1),lcase(n2))>0
For  n3 = 0 To ubound(SqlKeys)
If hsQ = True Then  Exit for
hsQ  =  instr(lcase(n1), lcase(Replace(n2 &""," ", SqlKeys(n3))))>0
next
if  hsQ  Then
Response.clear
response.charset="UTF-8"
Response.write "<script>alert('请不要使用非法字符(A)！');if(this.parent && this.parent!=this && this.parent.location.href==""" & fromurl & """){}else{history.back(-1)}</Script>"
comSqlSafeCheck = false
exit function
end if
next
next
end if
If InStr(lcase(request.servervariables("CONTENT_TYPE") & ""),lcase("multipart/form-data"))=0  then
If Request.Form<>"" Then
For Each postname In Request.Form
n1 = Request.Form(postname)
For ii=0 To Ubound(keylist)
n2 = keylist(ii)
if len(n1&"")>1 then
hsQ = instr(lcase(n1&""),lcase(n2&""))>0
else
hsQ =false
end if
For  n3 = 0 To ubound(SqlKeys)
If hsQ = True Then  Exit for
hsQ  =  instr(lcase(n1), lcase(Replace(n2 &""," ", SqlKeys(n3))))>0
next
if  hsQ  Then
Response.clear
response.charset="UTF-8"
Response.write "<script>alert('请不要使用非法字符(B)');if(this.parent && this.parent!=this && this.parent.location.href==""" & fromurl & """){}else{history.back(-1)}</Script>"
comSqlSafeCheck = false
exit function
end if
next
next
end if
end if
comSqlSafeCheck = true
end function
public ZBRuntime, Sdk
Call InitSysRuntimeVar
Class ExcelCollocation
Public Function Create()
on error resume next
Set m_xlsobj_app  = Server.CreateObject("Excel.Application")
If Err.number <> 0 Then
Response.clear
Response.write sdk.Res.html("msg_excel_err")
conn.close : cn.close : Response.end
end if
end function
Private Sub Class_Terminate()
on error resume next
If LCase(typename(conn)) = "connection" Then conn.close : Set conn = nothing
if LCase(typename(m_xlsobj_app)) = "application" Then
Dim fs , fp : fp = server.mappath("../out/outerror_tmp_" & session("personzbintel2007") & ".xls")
Set fs = server.createobject("Scripting.FileSystemObject")
If Not fs Is Nothing then
If fs.FileExists(fp) Then fs.DeleteFile fp  , true
If Not fs.FileExists(fp) Then m_xlsobj_app.Worksheets(1).SaveAs fp
m_xlsobj_app.Quit
Set m_xlsobj_app = Nothing : Set fs = nothing
end if
end if
end sub
End Class
Dim ec_obj , m_xlsobj_app
Set ec_obj = New ExcelCollocation
Function GetExcelApplication
Call ec_obj.Create()
Set GetExcelApplication = m_xlsobj_app
end function
Function ClientClosedExit
If response.isClientconnected = false Then
Err.raise 4908, "xlscc.asp", "客户端已经断开，触发Clientconnected判断机制，抛出常规性错误。"
else
ClientClosedExit = true
end if
end function
Function JmgToUrl(url)
If InStr(url,"?") > 0 Then
url = url & "&asize=" & Abs(Len(request.form & request.querystring) > 0) & "&u=" &  server.htmlencode(LCase(request.servervariables("url")))
end if
Response.redirect url
end function
Function checkSuperDog(ByVal cnobj, ByVal vPath , ByVal ismobile)
on error resume next
Dim redirectURL , message
redirectURL = "" : message = ""
Dim tb_vcsc, DogApp, rs, dllpathmd5
tb_vcsc = ""
dllpathmd5 = ZBRuntime.DLLPath_MD5
If Len(dllpathmd5) > 0 Then
dllpathmd5 = " where  vpath='" & dllpathmd5 & "'"
end if
Err.clear
If cnobj.Execute("select count(1) where EXISTS(SELECT id FROM dbo.SysObjects WHERE ID = object_id(N'M_content') AND OBJECTPROPERTY(ID, 'IsTable') = 1)")(0) > 0 Then
If cnobj.Execute("select 1 from syscolumns where id = OBJECT_ID(N'[dbo].[M_content]') and name='vpath'").EOF Then
cnobj.Execute "ALTER TABLE dbo.M_content ADD vpath varchar(50) NULL"
end if
Set rs = cnobj.Execute("select top 1 vcsc from M_content " & dllpathmd5)
If Not rs.EOF Then tb_vcsc = rs(0)
rs.close
end if
If tb_vcsc = "" Then
redirectURL = vPath & "manager/setactive.asp?msg=本地注册凭证失效"
message = "本地注册凭证失效"
else
tb_vcsc = StrReverse(Left(tb_vcsc, 9)) & StrReverse(Right(tb_vcsc, 23))
tb_vcsc = Mid(tb_vcsc, 6, 16)
If ZBRuntime.MC(61000) Then
Set DogApp = server.CreateObject("SuperDog.DogApplication")
If Err.Number <> 0 Then
redirectURL = vPath & "check_log.asp?status=1" '"1.创建SuperDog组件失败,请注册: regsvr32 dog_com_windows.dll"
message = getJmgStatus(1)
else
If (Nothing Is DogApp) Then
redirectURL = vPath & "check_log.asp?status=1" '"1.创建SuperDog组件失败,请注册: regsvr32 dog_com_windows.dll"
message = getJmgStatus(1)
else
If Err.Number <> 0 Then
redirectURL = vPath & "check_log.asp?status=1" '"1.创建SuperDog组件失败,请注册: regsvr32 dog_com_windows.dll"
message = getJmgStatus(1)
else
Dim FeatuerID, Dog
Set FeatuerID = DogApp.Feature(1)
Set Dog = DogApp.Dog(FeatuerID)
Dim scope
scope = "<?xml version=""1.0"" encoding=""UTF-8"" ?><dogscope><license_manager hostname =""localhost"" /></dogscope>"
'Dim scope
Dim VendorCode1, VendorCode2, VendorCode3
VendorCode1 ="rZIi6W3U5qKtIUZNTjSSgnhned/2ai8+E0R0NBzKbAJXC54ZGmWT6KxwW27xD1AAqNSGgkqq2vLKZw8H58QaVhSY09qxrACJswOaYydxdLtPynyrGcpOvvXgQQBtnQTdsn/aJD+SIcGRu+E0tXpExTbE5bblEy2H97Lo8uwTEM/vYCtheUo6wug5xulAxI71tRUorfpngzn"
'Dim VendorCode1, VendorCode2, VendorCode3
VendorCode3 = "KzclLlNKmiU9pTIkRRyUqlzFtcEnhEjwamZxKCqp1ppaom0A5X72DEDnSMBg0rdCayaxJh/VrqtRv2Wujjx5acac1r+N7aaCjNiUer5X7ZExbWWIcRNxxwgFLZNALO5FliaHyopyWg4RQTbGGyZKdZ3RfiZJdfJLu0PApMQN+8ersyK2m7LMSY8eZc83D1vTX8BoZWY/HXvOsju2M039UnKUU+v00tdeT5/xhB3fNe6RSjcZXa/ZofLDQzHOj/2xRIAGISJ0JtQivr5jsgOQuhjJk9PthL5eFzYL+pYA0zdMIP5C42Go7MgAZSPLwMiEIOuyIeLep9ZR5iRcBl1fVyVjyaCVrn9Qt+Glcpj0lziam3SsGnl1WdXxM6yEc0nmmVrr0DSA=="
'Dim VendorCode1, VendorCode2, VendorCode3
VendorCode2 = "Yi4m7PAjeQ4n7FGAPxnO63MrESMHczwVh9uod/MbrU7RYOiM90y6Cu9lNBpibp1LDERxDWctlxBEldMry6QLEG705q6ie6aQncWu9evLTsmkMsw4PDWoowCwyW431Wzc/+8EAk6gLkA2m6Jkf+Qooqu5Q5UQlJvDa8BQZqU7Lx2ZRqI3RGW7APIqWGFk1Bdrvedg16+zHL6/J9V7b5+KBAq9cAreJhcLN8WZ1yID1RZ5gDqSDu25Yajso92uXyN+M65WmMatEPxD4pZbUPRTxGrCRghIYzzWjpWRbg1ZVyyOT4RJpgu/9dF1UqooTD+jrT/VA121EYPt2FyMMYtVINiUH1LumPukUPH2s0D6Lk8UhNEvckutzCZtZ+ipswOzEac"
'Dim VendorCode1, VendorCode2, VendorCode3
Dim status, DogFile
status = Dog.LoginScope(VendorCode1 & VendorCode2 & VendorCode3, scope)
If Not Dog.IsLoggedIn Then
redirectURL = vPath & "check_log.asp?status=" & status
message = getJmgStatus(status)
else
Set DogFile = Dog.GetFile(65524)
If IsNull(DogFile) Then
redirectURL = vPath & "check_log.asp?status=111" '"111.获取superDog空间内容失败"
message = getJmgStatus(111)
else
Dim Size: Set Size = DogFile.FileSize
If Size.status <> 0 Then
redirectURL = vPath & "check_log.asp?status=" & Size.status
message = getJmgStatus(Size.status)
else
Dim superDog_text : superDog_text = Trim(Replace(Replace(DogFile.ReadString,vbcr,""),vblf,""))
If LCase(superDog_text) <> REMD5(LCase(tb_vcsc)) Then
redirectURL = vPath & "check_log.asp?status=1000" '"1000.SuperDog硬件与该系统不匹配"
message = getJmgStatus(1000)
end if
end if
end if
If Len(redirectURL)>0 Then Dog.Logout
end if
end if
end if
end if
Set DogApp = Nothing
end if
end if
On Error GoTo 0
If ismobile = True Then
If Len(message)>0 Then
app.mobile.document.body.CreateModel("message","").Text = message
Call App.mobile.flush
Response.end
end if
else
If Len(redirectURL)>0 Then
'Call retrieveSys(vPath)
'Call JmgToUrl(redirectURL)
end if
end if
end function
Function REMD5(str)
Dim tStr, s, i
If Trim(str) = "" Or IsNull(str) Then Exit Function
For i = 1 To Len(str)
s = Mid(str, i, 1)
Select Case s:
Case "0": s = "f"
Case "1": s = "e"
Case "2": s = "d"
Case "3": s = "c"
Case "4": s = "b"
Case "5": s = "a"
Case "6": s = "9"
Case "7": s = "8"
Case "8": s = "7"
Case "9": s = "6"
Case "a": s = "5"
Case "b": s = "4"
Case "c": s = "3"
Case "d": s = "2"
Case "e": s = "1"
Case "f": s = "0"
End Select
tStr = tStr & s
next
REMD5 = tStr
end function
Function retrieveSys(ByVal vPath)
on error resume next
application.contents.removeall
Session.Abandon
end function
Function getJmgStatus(ByVal status)
Dim s : s = ""
Select Case status
Case 1:
s = "错误号0001，创建服务器加密锁组件失败，请尝试通过注册命令“regsvr32 dog_com_windows.dll”解决该问题。"
Case 7:
s = "错误号0007，未找到服务器加密锁。"
Case 30:
s = "错误号0030，签名验证失败。"
Case 31:
s = "错误号0031，特征不可用。"
Case 50:
s = "错误号0050，不能找到与范围匹配的特征。"
Case 111:
s = "错误号0111，获取服务器加密锁内容失败。"
Case 400
s = "错误号0400，未找到API的动态库，请确认DLL是否正确的安装在System32或目录中。"
Case 1000:
s = "错误号1000，服务器加密锁与该系统不匹配。"
Case else
s = status & ".访问服务器错误。"
End Select
getJmgStatus = s
end function
sub ProxyUserCheck()
on error resume next
dim rs , sessionid, sdk, cnn
'if len(Application("_ZBM_Lib_Cache") & "") = 0 then
'Dim z : Set z = server.createobject(ZBRLibDLLNameSN & ".Library")
'z.GetLibrary "ZBIntel2013CheckBitString"
'end if
if len(session("personzbintel2007") & "") > 0  and len(session("adminokzbintel") & "")>0 then
exit sub
end if
sessionid = request.Cookies("ASP.NET_SessionId")
if len(sessionid & "") = 0 then exit sub
Set sdk = server.createobject(ZBRLibDLLNameSN & ".CommClass")
sdk.TryReloadUserByRedis
if len(session("personzbintel2007") & "") > 0  and len(session("adminokzbintel") & "")>0 then
set sdk = nothing
exit sub
end if
set cnn = server.CreateObject("adodb.connection")
cnn.Open sdk.database.ConnectionText
set rs = cnn.execute("select uid from UniqueLogin where  abs(datediff(n, LastActiveTime, getdate()))<15 and status='1' and sessionId='" &  replace(sessionid,"'","") & "'")
if rs.eof = false then
session("personzbintel2007") = rs(0).value
session("adminokzbintel")="true2006chen"
end if
rs.close
set rs = nothing
cnn.Close
set cnn = nothing
err.Clear
end sub
Sub TryLoadSysInfo
if  len(application("sys.info.configindex") & "")=0 then
Dim z : Set z = server.createobject(ZBRLibDLLNameSN & ".Library")
call z.LoadDBSysInfo
set z = nothing
end if
end sub
call TryLoadSysInfo
Const XUNJIA_SIZE = 100
Function GetAjaxRequest
Dim s : GetAjaxRequest = false
For Each s In Request.ServerVariables
If s = "HTTP_A_S_T_ISAJAX" Then GetAjaxRequest = True : Exit function
next
end function
sub ConflictProcHandle
If isAjaxRequest Then Exit Sub
Err.clear
on error resume next
if len(request.form & "") > 0 Then
If Err.number = 0 Then Exit Sub
end if
If Err.number <> 0 Then
On Error GoTo 0
sdk.showmsg "提示信息", "<div style='padding:20px;color:red'>由于您提交到服务器的数据量可能过大，导致页面无法打开，请联系系统管理员，调整站点IIS相关配置解决该问题。</div>"
conn.close
Response.end
end if
Dim exiturl : exiturl = Split("planall,content,telhy,tongji",",")
Dim i, url : url = geturl()
For i= 0 To ubound(exiturl)
If InStr(1, url, exiturl(i), 1)>0 Then Exit sub
next
on error resume next
Dim cftManger: Set cftManger = Nothing
Set cftManger = server.createobject(ZBRLibDLLNameSN & ".ConflictManger")
If cftManger Is Nothing Then Err.clear: Exit Sub
If IsObject(sdk) = False Then
Set sdk = server.createobject(ZBRLibDLLNameSN & ".CommClass")
sdk.init me
end if
If cftManger.ConflictProc(sdk) = False then
Set cftManger = nothing
call db_close : Response.end
else
ConflictPageUrllist = cftManger.ConflictPageUrllist
end if
Set cftManger = nothing
end sub
function GetConnectionText()
Dim txt : txt = Application("_sys_connection")
if len(txt) = 0 Then txt = sdk.database.ConnectionText
server_1 = Application("_sys_sql_svr")
sql_1 = Application("_sys_sql_db")
user_1 = Application("_sys_db_user")
pw_1 = Application("_sys_db_pass")
getConnectionText = txt
end function
function GetHttpType
dim loginurl
loginurl = session("clientloginurl")
if instr(1, loginurl, "https://", 1)>0 then
GetHttpType = "https"
else
GetHttpType = "http"
end if
end function
sub Response_redirect(url)
on error resume next
conn.close
Response.redirect url
call db_close : Response.end
end sub
function GetHl(ByVal bz, ByVal dvalue)
If isdate(dvalue) = False Then GetHl = 1: Exit function
GetHl = sdk.setup.Gethl(CStr(bz), CDate(dvalue))
end function
sub close_list(args)
on error resume next
call add_logs (args)
conn.close:set conn=Nothing
dim s : s = right("00" & action1,2)
dim isbill, isreport
if s="添加" or s="修改" or s="详情" then
isbill = true
isreport = false
else
if typename(page_count)<>"Empty" then
isreport = true
isbill = false
end if
end if
if isbill then Response.write "<script>window.RegBillUISkin();</script>"
if isreport then Response.write "<script>window.RegReportUISkin();</script>"
end sub
sub db_close()
on error resume next
If typename(conn) <> "Empty" And typename(conn) <> "Nothing" then
conn.close:Set conn = Nothing
end if
end sub
function FormatnumberSub(x1,x2,x3)
if x1<>"" and x2<>"" then
FormatnumberSub=Formatnumber(x1,x2,x3)
else
FormatnumberSub=""
end if
end function
function colorWork(ByVal s)
s=replace(s,"潜在客户","<font class='greenFont'>潜在客户</font>")
s=replace(s,"重点客户","<font class='redFont'>重点客户</font>")
s=replace(s,"老客户","<font class='orgFont'>老客户</font>")
s=replace(s,"初次接触","<font class='greenFont1'>初次接触</font>")
s=replace(s,"多次接触","<font class='greenFont2'>多次接触</font>")
colorWork=s
end function
function Format_Time(s_Time, n_Flag)
Select Case n_Flag
Case 1: Format_Time = sdk.VBL.Format(s_Time, "yyyy-MM-dd hh:nn:ss")
'Select Case n_Flag
Case 2: Format_Time = sdk.VBL.Format(s_Time, "yyyy-MM-dd")
'Select Case n_Flag
Case 3: Format_Time = sdk.VBL.Format(s_Time, "hh:nn:ss")
Case 4: Format_Time = sdk.VBL.Format(s_Time, "yyyy年MM月dd日")
Case 5: Format_Time = sdk.VBL.Format(s_Time, "yyyyMMdd")
Case 6: Format_Time = sdk.VBL.Format(s_Time, "yyyyMMddhhnnss")
End Select
end function
sub CreateSqlConnection
Set conn = server.CreateObject("adodb.connection")
conn.commandtimeout=1200
conn.open getConnectionText()
sdk.InitRegDBOK
If Application("__nosqlcahace")="1" Then conn.execute "DBCC DROPCLEANBUFFERS"
conn.CursorLocation = 3
conn.execute "SET ANSI_WARNINGS OFF"
if err.number<>0 then
Response.write "<script>top.location=""" & GetVirPath & "index4.asp?msg=" & server.urlencode(Err.description) & """;</script>"
Call db_close() : Response.end()
end if
end sub
Sub SqlLockSniffer()
Dim url , uid
url = request.servervariables("url")
If Len(url) > 150 Then url = Left(url,150)
url = Replace(url, "'","''")
uid = sdk.user & ""
If Len(uid) = 0 Or isnumeric(uid) =  False Then  uid = 0
conn.Execute "exec sp_killlock 1 ,0,'" & url & "'," & uid
end sub
sub error(message)
Response.write "<script>alert('" & Replace(message & "","'","\'") & "');history.back();window.close();</script>"
call db_close : Response.end
end sub
function ReturnUrl()
ReturnUrl=replace( split(geturl() & "?","?")(1) ,"%20","")
end function
function iif(byval cv,byval ov1,byval ov2)
if cv then iif=ov1 : exit function
iif=ov2
end function
function CNull(ByVal value, ByVal rpv1, ByVal rpv2)
if value & "" = rpv1 & "" Then CNull = rpv2 : Exit function
CNull = value
end function
Function GetStringLen(Str)
on error resume next
Dim Wd,I,Size
Size = conn.execute("select DATALENGTH('"& Str &"') as r")(0)
if err.number > 0 then Size = len(Str)
GetStringLen = Size
end function
function ShowSignImage(ByVal catename, ByVal cateid, ByVal billdate)
If catename&""="" Then catename = ""
If cateid&""="" Then cateid = 0
If billdate&""="" Then billdate = Date
cateid = CLng(cateid)
ShowSignImage = ZBRuntime.SDK.DHL.ShowSignImage(cateid, billdate, catename, Application, request, Server,  conn)
end function
Function GetIdentity(ByVal tableName,ByVal fieldName,ByVal addPerson,ByVal connStr)
Dim r : r = sdk.setup.GetIdentity(tableName,fieldName,addPerson)
if r = 0 then err.raise 908, "GetIdentity", sdk.LastError
GetIdentity = r
end function
Function strSubtraction(strOri, strComb, strSplit) '从集合中剔除一个元素, 如：strSubtraction("a,b,c","b",",")="a,c"
Dim f_str : f_str = Replace(strSplit&strOri&strSplit, strSplit&strComb&strSplit, strSplit)
If Left(f_str, Len(strSplit)) = strSplit Then f_str = Right(f_str, Len(f_str) - Len(strSplit))
'Dim f_str : f_str = Replace(strSplit&strOri&strSplit, strSplit&strComb&strSplit, strSplit)
If Right(f_str, Len(strSplit)) = strSplit Then f_str = Left(f_str, Len(f_str) - Len(strSplit))
'Dim f_str : f_str = Replace(strSplit&strOri&strSplit, strSplit&strComb&strSplit, strSplit)
strSubtraction = f_str
end function
Sub clearBHTempRec(bhConfigId,dbconn)
dbconn.execute "delete BHTempTable where configId="&bhConfigId&" and addCate=" & sdk.user
end sub
dim  LongRequestObj
Set LongRequestObj = nothing
Function LongRequest(byval urlparams)
Dim longurlid : longurlid = CLng("0" & request.querystring("__sys_LongUrlParamsID"))
Dim vvvv  :  vvvv = request.querystring(urlparams)
If Len(vvvv) >0  Then LongRequest = vvvv : Exit Function
If LongRequestObj Is Nothing Then
Dim rs   :  Set rs = conn.execute("select ParamsData from erp_sys_UrlBigParamCaches where ID=" & longurlid )
If rs.eof = False Then
Dim json  :   json   = rs(0).value & ""
If Len(json) > 0 Then
Dim p :  Set p = server.createobject("MSScriptControl.ScriptControl")
p.Language = "jscript"
set  LongRequestObj = p.Eval("(" & json & ")")
Set p = Nothing
end if
end if
rs.close
set rs = nothing
end if
If Not LongRequestObj Is Nothing Then
Dim o
For Each o in LongRequestObj
If LCase(o.n) = LCase(urlparams) Then
LongRequest = o.v
end if
next
end if
end function
function  CreatefilterSqlLongRquest(byval filtersql)
dim uid , rs, b64, SrcSign
SrcSign = request.ServerVariables("URL")
set b64 =  sdk.base64
uid = session("personzbintel2007")
conn.execute "delete erp_sys_UrlBigParamCaches where userid=" & uid &" and SrcSign='"& SrcSign &"'"
set rs = server.CreateObject("adodb.recordset")
rs.Open "select * from erp_sys_UrlBigParamCaches where ID<0",  conn, 1,  3
rs.AddNew
rs.Fields("userid").value = uid
rs.Fields("indate").value = now
rs.Fields("SrcSign").value = SrcSign
rs.Fields("ParamsData").value =  "[{n:""afv_existssql"",v:""urlencode.utf8:" & Server.URLEncode(filtersql) & """}]"
rs.update
CreatefilterSqlLongRquest = rs("id").value
rs.close
set rs = nothing
end function
Function shortKey
dim urls , p , i, mshortKey : mshortKey = ""
urls = replace(request.ServerVariables("PATH_TRANSLATED"),server.mappath(sysCurrPath),"")
urls = split(urls ,"\")
for i = 1 to ubound(urls) - 1
'urls = split(urls ,"\")
p = p & left(urls(i),1) & right(urls(i),1) & "_"
next
mshortKey = p & replace(replace(urls(ubound(urls)),".asp","",1,-1,1),".","")
'p = p & left(urls(i),1) & right(urls(i),1) & "_"
shortKey = mshortKey
end  Function
Sub addDefaultScript()
Response.write "<script type=""text/javascript"" src=""" & sysCurrPath & "Script/" & shortKey & ".js""></script>"
end sub
sub InitSystemVars
hl_dot = sdk.info.hlNumber
num1_dot = sdk.Info.floatNumber
num_dot_xs = sdk.Info.moneyNumber
CommPrice_dot_num = sdk.Info.CommPriceDotNum
SalesPrice_dot_num = sdk.Info.SalesPriceDotNum
StorePrice_dot_num = sdk.Info.StorePriceDotNum
FinancePrice_dot_num = sdk.Info.FinancePriceDotNum
title_xtjm = sdk.Info.title
num_timeout = sdk.Info.TimeoutNumber
num_cpmx_yl = sdk.info.MaxLinesNumber
discount_dot_num = sdk.Info.DiscountNumber
discount_max_value = sdk.Info.MaxDiscountValue
percentWithDot=sdk.getSqlValue("select num1 from setjm3 where ord=20171221", 2)
session.timeout=num_timeout
end sub
function getint(v): getint = sdk.TryNumber(v,0) : end function
function getip: getip = sdk.vbl.getip(request): end function
function getvirpath: getvirpath = sdk.getvirpath: end function
function geturl: geturl = sdk.vbl.geturl(request): end function
function browser: browser = sdk.vbl.getbrowser(request): end function
function getattr(k): getattr = sdk.setup.attributes(k & ""): end function
function setattr(k,nv): sdk.setup.attributes(k & "") = nv & "": end function
function operationsystem: operationsystem = sdk.vbl.getos(request): end function
function getkulastid(k_id): getkulastid = sdk.setup.getkulastid(k_id): end function
function htmlarea(strcontent)
htmlarea=Replace(sdk.setup.htmlarea(strcontent), "<tr>","<tr style='background-color:transparent'>",1,1)
'function htmlarea(strcontent)
end function
function acccanmodify(urd): acccanmodify=sdk.setup.acccanmodify(clng(urd)) : end function
function getcanminus(byval bankid): getcanminus=sdk.setup.getcanminus(clng(bankid)): end function
function conver(tmpvalue): conver=replace(trim(tmpvalue & ""),"'","''"): end function
function isallowhandle(ByVal cid,ctime,typ): If cid&""="" Then cid=0 : End If : isallowhandle=sdk.setup.isallowhandle(CLng(cid),ctime,CLng(typ)) : end function
function checkpurview(alls, items): checkpurview = sdk.setup.checkpurview(alls & "", items & "") : end function
function forwardparams(exs,xtype):forwardparams=sdk.setup.forwardparams(exs&"",clng(xtype),server,request): end function
sub add_logs(byval args): call sdk.setup.add_logs(application, session, request, server, args, action1): end sub
function GetERPVersion: GetERPVersion=clng("0" & Replace(split(sdk.info.version & "","(")(0), ".", "")) : end function
Function FormatInput(str)
If Len(str&"") = 0 Then Exit Function
Dim temp : temp = Replace(str,"""","&quot;") : FormatInput = temp
end function
Function GetSetJm3Value(keysign,  nullvalue)
If isnumeric(nullvalue) And Len(nullvalue & "")>0 then
GetSetJm3Value = sdk.setup.GetSetjm3(keysign, nullvalue)
else
GetSetJm3Value = sdk.setup.GetSetjm3Text(keysign, CLng("0" & nullvalue) )
end if
end function
Function GetPowerValue(ByRef qxopenv, ByRef qxintrov, ByVal sort1,  ByVal sort2)
Dim rs : set rs= conn.execute("select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=" & sort1 & " and sort2=" & sort2 & "")
if rs.eof  Then     qxopenv=0  :  qxintrov="-222" :   rs.close :  Exit Function
qxopenv = rs("qx_open").value : qxintrov=rs("qx_intro").value
rs.close  : set rs=nothing
end function
function CNumberList(byval listvalue)
dim r, i , n :  r = ""
listvalue = split(replace(listvalue & ""," ",""), ",")
for i = 0 to ubound(listvalue)
n = listvalue(i)
if len(n)>0 and isnumeric(n) then
if len(r)>0 then r = r & ","
r = r & n
end if
next
CNumberList = r
end function
function GetUserIdsByOrgsID(byval w1)
dim sql , ids
ids = ""
sql = "select x.id  from orgs_parts x inner join (" & _
"  select fullids from orgs_parts  where '," + replace(w1, " ","") + ",%'  like '%,' + cast(ID as varchar(12)) + ',%'" & _
") y on charindex(y.fullids+',',  x.fullids+',')=1"
set rs = conn.execute(sql)
while rs.eof = false
if len(ids)>0 then ids =  ids & ","
ids = ids & rs(0).value
rs.movenext
wend
rs.close
if len(ids) = 0 then ids = "-1"
ids = ids & rs(0).value
ids = "select ord from gate where orgsid in ("& ids &")"
GetUserIdsByOrgsID = ids
end function
Class regExistsFilesProxy
Public cn, conn
public function init
Set cn = server.CreateObject("adodb.connection")
cn.open Application("_sys_connection")
Set conn = cn
Set init = Server.createobject(ZBRLibDLLNameSN & ".commClass")
init.init me
end function
Public Sub cls
cn.close
Set cn = Nothing
Set conn = Nothing
Set sdk = nothing
end sub
End Class
Sub writeCommHeaderJScript
Dim szmx: szmx = sdk.Attributes("uizoom")
If szmx="" Then szmx = "1"
Response.write "" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "        var getIEVer = function () {" & vbcrlf & "            var browser = navigator.appName;" & vbcrlf & "                if(window.ActiveXObject && top.document.compatMode==""BackCompat"") {return 5;}" & vbcrlf & "             var b_version = navigator.appVersion;" & vbcrlf & "             var version = b_version.split("";"");" & vbcrlf & "               if(document.documentMode && isNaN(document.documentMode)==false) { return document.documentMode; }" & vbcrlf & "              if (window.ActiveXObject) {" & vbcrlf & "                     var v = version[1].replace(/[ ]/g, """");" & vbcrlf & "                   if (v == ""MSIE10.0"") {return 10;}" & vbcrlf & "                        if (v == ""MSIE9.0"") {return 9;}" & vbcrlf & "                   if (v == ""MSIE8.0"") {return 8;}" & vbcrlf & "                   if (v == ""MSIE7.0"") {return 7;}" & vbcrlf & "                   if (v == ""MSIE6.0"") {return 6;}" & vbcrlf & "                   if (v == ""MSIE5.0"") {return 5;" & vbcrlf & "                    } else {return 11}" & vbcrlf & "         }" & vbcrlf & "               else {" & vbcrlf & "                  return 100;" & vbcrlf & "             }" & vbcrlf & "       };" & vbcrlf & "      try{ document.getElementsByTagName(""html"")[0].className = ""IE"" + getIEVer() ; } catch(exa){}" & vbcrlf & "        window.uizoom = "
'If szmx="" Then szmx = "1"
Response.write szmx
Response.write ";" & vbcrlf & "    if( (top==window ||  (top.app && top.app.IeVer>=100) ) && uizoom!=1){document.write(""<style>body{position:relative;zoom:"" + window.uizoom + ""}</style>"");}" & vbcrlf & "  window.sysConfig = {BrandIndex:"""
'Response.write szmx
Response.write application("sys.info.configindex")
Response.write """, floatnumber:"
Response.write num1_dot
Response.write ",moneynumber:"
Response.write num_dot_xs
Response.write ",CommPriceDotNum:"
Response.write CommPrice_dot_num
Response.write ",SalesPriceDotNum:"
Response.write SalesPrice_dot_num
Response.write ",StorePriceDotNum:"
Response.write StorePrice_dot_num
Response.write ",FinancePriceDotNum:"
Response.write FinancePrice_dot_num
Response.write ",discountMaxLimit:"
Response.write DISCOUNT_MAX_VALUE
Response.write ",discountDotNum:"
Response.write DISCOUNT_DOT_NUM
Response.write ",hlDotNum:"
Response.write hl_dot
Response.write ",percentDotNum:"
Response.write percentWithDot
Response.write "};" & vbcrlf & "   window.sysCurrPath = """
Response.write sysCurrPath
Response.write """;" & vbcrlf & "        window.currUser = """
Response.write sdk.user
Response.write """;" & vbcrlf & "        window.SessionId ="""
Response.write session("SessionID")
Response.write """;" & vbcrlf & "        window.nowTime = """
Response.write now()
Response.write """;" & vbcrlf & "        window.nowDate = """
Response.write date()
Response.write """;" & vbcrlf & "        window.syssoftversion = """
Response.write Application("__sys_soft_ver")
Response.write """" & vbcrlf & " window.currForm = """
if len(request.form) < 1000 then Response.write replace(request.form,"""","\""")
Response.write """;" & vbcrlf & "        window.currQueryString = """
Response.write replace(replace(request.querystring,"\","\\"),"""","\""")
Response.write """;" & vbcrlf & "        window.ConflictPageUrllist = """
Response.write ConflictPageUrllist
Response.write """; //冲突的页面" & vbcrlf & "   "
Dim PATH_INFO : PATH_INFO = Request.ServerVariables("PATH_INFO")
if instr(1,PATH_INFO,"/tongji/",1)>0 or instr(1,PATH_INFO,"/out/",1)>0 then
Response.write "" & vbcrlf & "     window.isGatherListPage=1;" & vbcrlf & "      "
end if
Response.write "" & vbcrlf & "     document.title="""
Response.write replace(title_xtjm,"""","\""")
Response.write """" & vbcrlf & "</script>" & vbcrlf & ""
end sub
Function IsNetProduce()
Dim jm2017112116 : jm2017112116 = GetSetJm3Value(2017112116, 0)
if ZBRuntime.MC(35000) = False  And ZBRuntime.MC(18100)=false Then
jm2017112116 = -1
'if ZBRuntime.MC(35000) = False  And ZBRuntime.MC(18100)=false Then
else
If ZBRuntime.MC(35000) = False Then
jm2017112116 = 0
ElseIf  ZBRuntime.MC(18100)=false and ZBRuntime.MC(18600)=false Then
jm2017112116 = 1
end if
end if
IsNetProduce = jm2017112116
end function
Response.Charset="UTF-8"
'IsNetProduce = jm2017112116
Response.ExpiresAbsolute = Now() - 1
'IsNetProduce = jm2017112116
Response.Expires = 0
Response.CacheControl = "no-cache"
'Response.Expires = 0
Response.AddHeader "Pragma", "No-Cache"
'Response.Expires = 0
Dim sysCurrPath : sysCurrPath = SDK.GetVirPath
Dim conn, server_1, user_1, pw_1, sql_1, ConflictPageUrllist, title_xtjm, hl_dot,percentWithDot, IsAjaxRequest
Dim num1_dot,num_dot_xs,num_timeout,num_cpmx_yl,discount_max_value,discount_dot_num,CommPrice_dot_num,SalesPrice_dot_num,StorePrice_dot_num,FinancePrice_dot_num
IsAjaxRequest = GetAjaxRequest()
Call ConflictProcHandle
Call CreateSqlConnection
If sdk.Setup.UserLoginCheck = False Then
Response.end
else
if conn.Execute("select 1 from gate with(nolock) where del=1 and ord=" & CLng("0" & session("personzbintel2007")) ).eof then
Response.write "<script>alert(""账号已经删除或冻结，请重新登录！"");top.location.href ='" & sdk.GetVirPath & "index2.asp';</script>"
end if
end if
Call checkSuperDog(conn, "../", False)
Call InitSystemVars
If Len(Application("systemstate")&"")>0 Then
If Application("systemstate")="2" And Application("systemlockid")<>sdk.user Then
Response.write "<script>alert(""系统维护中，请稍后再试！""); </script>"
call db_close : Response.end
end if
end if
set rs2t=server.CreateObject("adodb.recordset")
sql2t="select sort1,qx_open,w1,w2,w3 from power2  where cateid="&session("personzbintel2007")&" and sort1 in(1,2,3,4) and qx_open=1"
rs2t.open sql2t,conn,1,1
While rs2t.eof = False
zzjg_open_1_1=rs2t("qx_open") : zzjg_sort1=rs2t("sort1")
zzjg_w1_list=rs2t("w1")
zzjg_w2_list=rs2t("w2")
zzjg_w3_list=rs2t("w3")
If zzjg_open_1_1&"" = "1" Then
If Trim(replace(zzjg_w1_list&"",",",""))="" Or Trim(replace(zzjg_w2_list&"",",",""))="" Or Trim(replace(zzjg_w3_list&"",",",""))="" Then
If Trim(replace(zzjg_w1_list&"",",","")) = "" Then zzjg_w1_list = "-222"
If Trim(replace(zzjg_w2_list&"",",","")) = "" Then zzjg_w2_list = "-222"
If Trim(replace(zzjg_w3_list&"",",","")) = "" Then zzjg_w3_list = "-222"
conn.execute("update power2 set w1='"& zzjg_w1_list &"', w2='"& zzjg_w2_list &"', w3='"& zzjg_w3_list &"'  where cateid="&session("personzbintel2007")&" and sort1="& zzjg_sort1)
end if
end if
rs2t.movenext
wend
rs2t.close
set rs2t=Nothing
Dim tp: tp=0
set rs2t=server.CreateObject("adodb.recordset")
sql2t="select qx_open from power where ord="& sdk.user &" and sort1=74 and sort2=12"
rs2t.open sql2t,conn,1,1
if not rs2t.eof Then tp = 1-Abs(rs2t("qx_open")=0)
'rs2t.open sql2t,conn,1,1
rs2t.close
set rs2t=nothing
session("sys_userlastvistime") = now()
If HasSysTongJiJoinPage & "" = "1" Then Call DoSysTongJiJoinPageProc(0)
If IsAjaxRequest=False Then
dim bigsystemtype : bigsystemtype = ""
if application("sys.info.configindex")  = "3" then
bigsystemtype = ".mozi"
end if
Response.write "<!Doctype html><html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""X-UA-Compatible"" content =""IE=edge,chrome=1"">" & vbcrlf & "<meta name=""vs_targetSchema"" content=""http://schemas.microsoft.com/intellisense/ie5""/>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html;charset=UTF-8"">" & vbcrlf & "<meta name=""format-detection"" content=""telephone=no"">" & vbcrlf & ""
'bigsystemtype = ".mozi"
call WriteCommHeaderJScript
Response.write "" & vbcrlf & "<script type=""text/javascript"" src='"
Response.write sysCurrPath
Response.write "inc/dateid.js?ver="
Response.write Application("sys.info.jsver")
Response.write "'></script>" & vbcrlf & "<script type=""text/javascript"" src='"
Response.write sysCurrPath
Response.write "inc/setup.js?ver="
Response.write Application("sys.info.jsver")
Response.write "'></script>" & vbcrlf & "<script type=""text/javascript"" src="""
Response.write sysCurrPath
Response.write "inc/jQuery-1.7.2.min.js?ver="
Response.write sysCurrPath
Response.write Application("sys.info.jsver")
Response.write """></script>" & vbcrlf & ""
Response.write "" & vbcrlf & "<script type=""text/javascript"" src="""
Response.write sysCurrPath
Response.write "inc/UiSkinV3179"
Response.write bigsystemtype
Response.write ".js?ver="
Response.write Application("sys.info.jsver")
Response.write """></script>" & vbcrlf & "<script type=""text/javascript"" src="""
Response.write sysCurrPath
Response.write "Script/inc_setup.js?ver="
Response.write Application("sys.info.jsver")
Response.write """></script>" & vbcrlf & ""
If request.querystring("__fReclst")="1" Then
Response.write "<style>input.anybutton, input.anybutton2 {display:none} </style>"
Response.write "<script defer src='" & sysCurrPath & "back/autohidecontentbtn.js?ver=" & Application("sys.info.jsver") & "'></script>"
end if
Response.write "<script type=""text/javascript"" src=""" & sysCurrPath & "inc/jquery-autobh.js?ver=" & Application("sys.info.jsver") & """></script>" & vbcrlf
Response.write "</head>"
end if
dim AppDataVersion : AppDataVersion= Application("sys.info.jsver")
AppDataVersion = split(AppDataVersion&".",".")(0)
if AppDataVersion&""="" then AppDataVersion = "3100"
if len(AppDataVersion)>4 then  AppDataVersion = left(AppDataVersion, 4)
Response.write "" & vbcrlf & "<noscript></noscript>"

function getPicUrl(str)
getPicUrl = getFileNames(str)
end function
function getPicUrlForMoban(str)
getPicUrlForMoban = getFileNames(str)
end function
Function RegExp_Execute(patrn, strng)
Dim regEx, Match, Matches,values
Set regEx = New RegExp
regEx.Pattern = patrn
regEx.IgnoreCase = true
regEx.Global = True
Set Matches = regEx.Execute(strng)
For Each Match in Matches
if values="" then
values=values&Match.Value
else
values=values&","&Match.Value
end if
next
RegExp_Execute = values
end function
Function RegexReplace(strv, reg)
If Len(Trim(strv & "")) = 0 Then  RegexReplace = strv : Exit function
Dim regEx: Set regEx = New RegExp
Dim match, matches, path
regEx.IgnoreCase = True
regEx.Global = True
on error resume next
regEx.pattern = reg
Set matches = regEx.Execute(strv)
If Err.number <> 0 Then
Dim errtxt : errtxt = Err.description
On Error GoTo 0
Err.raise 908, "zbintel", "正则表达式执行错误，" & errtxt & "，表达式描述：" & strv
end if
For Each match In matches
path = regEx.Replace(match.Value, "$3")
If RegexReplace & "" = "" Then
RegexReplace = path
else
RegexReplace = RegexReplace & "," & path
end if
next
end function
Function getFileNames(strng)
Dim pattern, values, result
pattern = "<img[^>]+?src=(\""|\')([^\'\""]+)\/(UE\d+\.[A-Za-z0-9]+)\1[^>]*>"
'Dim pattern, values, result
values = RegexReplace(strng, pattern)
result = RegexReplace(strng, Replace(pattern, "UE", ""))
If result & "" <> "" Then
If values & "" = "" Then
values = result
else
values = values & "," & result
end if
end if
pattern = "<a[^>]+?href=(\""|\')([^\'\""]+)\/(UE\d+\.[A-Za-z0-9]+)\1[^>]*>.+<\/a>"
values = values & "," & result
result = RegexReplace(strng, pattern)
If result & "" <> "" Then
If values & "" = "" Then
values = result
else
values = values & "," & result
end if
end if
result = RegexReplace(strng, Replace(pattern, "UE", ""))
If result & "" <> "" Then
If values & "" = "" Then
values = result
else
values = values & "," & result
end if
end if
getFileNames = values
end function
Function DeleteFile(file)
exit function
dim fso
Set fso = CreateObject("scripting.filesystemobject")
if fso.FileExists(server.MapPath(file)) then
fso.DeleteFile (server.MapPath(file)),True
end if
Set fso = nothing
end function
Function DeleteRedundancyFile(keyName,Picurls)
Dim picUrl,picUrlArray,x
picUrl = sdk.attributes(physicalRef)
if picUrl <> "" then
picUrlArray = split(picUrl,",")
for x = 0 to ubound(picUrlArray)
If InStr(Picurls,picUrlArray(x)) = 0 Then
DeleteFile("../edit/upimages/"&picUrlArray(x))
end if
next
end if
sdk.attributes(physicalRef) = ""
end function
Dim isReged : isReged = False
Sub regExistsFiles(sdk,intro3)
Dim hasconn, cnproxy, oldsdk
hasconn = false
on error resume next
hasconn = Not conn Is Nothing
On Error GoTo 0
If hasconn = False Then
Set cnproxy = New regExistsFilesProxy
cnproxy.init
Set oldsdk = sdk
Set sdk = cnproxy.init
end if
intro3 = intro3 & ""
Dim exists_Pics,physicalRef,refMd5
physicalRef = Request.ServerVariables("URL")
If physicalRef & "" <> "" Then
physicalRef = Split(physicalRef,"?")(0)
else
physicalRef = "/UnknowPage/"
end if
physicalRef = Mid(physicalRef, InStrRev(physicalRef, "/", InStrRev(physicalRef, "/") - 1))
physicalRef = "/UnknowPage/"
If isReged = False Then
session("EFile-" & physicalRef) = ""
'If isReged = False Then
sdk.attributes("EFile-" & physicalRef) = ""
'If isReged = False Then
isReged = True
end if
session("EFile-" & physicalRef) = getPicUrl(intro3)
isReged = True
exists_Pics = sdk.attributes("EFile-" & physicalRef)
'isReged = True
If Len(exists_Pics) = 0 Then
sdk.attributes("EFile-" & physicalRef) = session("EFile-" & physicalRef)
'If Len(exists_Pics) = 0 Then
else
sdk.attributes("EFile-" & physicalRef) = exists_Pics & "," & session("EFile-" & physicalRef)
'If Len(exists_Pics) = 0 Then
end if
If hasconn =  False Then
cnproxy.cls
Set cnproxy = Nothing
Set sdk = oldsdk
end if
end sub

ZBRLibDLLNameSN = "ZBRLib3205"
Class customFieldClass
Public dbname
Public Key
Public show
Public name
Public point
Public enter
Public sort2
Public required
Public extra
Public isformat
Public sorttype
Public search
Public import
Public export
Public census
End Class
Function GetFields(sort)
If sort&""="" Then sort = 1
Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
Dim rs ,sql, field
sql = "select (case when isnull(name,'')='' then oldname else name end ) as name,(case when show>0 then 1 else 0 end) as show,(case when Required>0 then 1 else 0 end ) as Required ,"&_
"   gate1 ,point ,enter, sort2,extra , format ,type , fieldName "&_
"   from setfields where sort="& sort &" order by sort2, order1 asc "
set rs = conn.execute(sql)
While rs.eof = False
Set field = New customFieldClass
With field
.dbname = rs("fieldName").value
.Key    = rs("gate1").value
.show   = (rs("show").value = "1")
.name   = rs("name").value
.point  = (rs("point").value = "1" And rs("show").value = "1")
.enter  = (rs("enter").value = "1" And rs("show").value = "1")
.sort2  = CInt(rs("sort2").value)
.required=(rs("required").value = "1" And rs("show").value = "1")
.extra  = rs("extra").value&""
.isformat=(rs("format").value = "1" And rs("show").value = "1")
.sorttype   = CInt(rs("type").value)
End With
fields.add field
rs.movenext
wend
rs.close
Set GetFields = fields
end function
Function hasOpenZdy(sort)
If sort&""="" Then sort = 1
hasOpenZdy = (conn.execute("select 1 from zdy where sort1="& sort &" and set_open = 1 ").eof = false)
end function
Function GetZdyFields(sort)
If sort&""="" Then sort = 1
Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
Dim rs ,sql, field
sql = "select * from zdy where sort1="& sort &" order by gate1 asc "
set rs = conn.execute(sql)
While rs.eof = False
Set field = New customFieldClass
With field
.dbname = rs("name").value
.Key    = rs("id").value
.show   = (rs("set_open").value = "1")
.name   = rs("title").value
.point  = (rs("ts").value = "1" And rs("set_open").value = "1")
.enter  = (rs("jz").value = "1" And rs("set_open").value = "1")
.required=(rs("bt").value = "1" And rs("set_open").value = "1")
.extra  = rs("gl").value
.sorttype   = CInt(rs("sort").value)
.search = (rs("js").value = "1" And rs("set_open").value = "1")
.import = (rs("dr").value = "1" And rs("set_open").value = "1")
.export = (rs("dc").value = "1" And rs("set_open").value = "1")
.census = (rs("tj").value = "1" And rs("set_open").value = "1")
End With
fields.add field
rs.movenext
wend
rs.close
Set GetZdyFields = fields
end function
Function hasOpenExtra(sort)
If sort&""="" Then sort = 1
hasOpenExtra = (conn.execute("select 1 from ERP_CustomFields where TName="& sort &" and IsUsing=1 and del=1 ").eof = False)
end function
Function GetExtraFields(sort)
If sort&""="" Then sort = 1
Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
Dim rs ,sql, field
sql = "select f.id,f.IsUsing ,f.FType,f.FName,f.MustFillin, ((case f.FType when 1 then 'danh_' when 2 then 'duoh_' when 3 then 'date_' when 4 then 'Numr_' when 5 then 'beiz_' when 6 then 'IsNot_' else 'meju_' end ) + cast(f.id as varchar(20)) ) as dbname,f.CanSearch,f.CanInport ,f.CanExport, f.CanStat  from ERP_CustomFields f where f.TName="& sort &" and f.del=1 order by f.FOrder asc "
set rs = conn.execute(sql)
While rs.eof = False
Set field = New customFieldClass
With field
.dbname = rs("dbname").value
.Key    = rs("id").value
.show   = rs("IsUsing").value
.name   = rs("FName").value
.required=(rs("MustFillin").value And rs("IsUsing").value)
.extra  = rs("id").value
.sorttype   = CInt(rs("FType").value)
.search = (rs("CanSearch").value  And rs("IsUsing").value )
.import = (rs("CanInport").value  And rs("IsUsing").value )
.export = (rs("CanExport").value  And rs("IsUsing").value )
.census = (rs("CanStat").value  And rs("IsUsing").value )
End With
fields.add field
rs.movenext
wend
rs.close
Set GetExtraFields = fields
end function
Dim checkmustcontentPersons
Function getbacktel(ord,v2,needtype)
getbacktel =  getbackteldata(ord,v2,needtype, 1)
end function
Function getbacktelForTmp(ord,v2,needtype)
getbacktelForTmp =  getbackteldata(ord,v2,needtype, 2)
end function
Function getbackteldata(ord,v2,needtype, dtype)
Dim f_rs,f_sql,remind,reminddays,tord,n,backday,cansum,sql_result
Dim basesql
n=0
If needtype>0 Then
If needtype=3 Then sql_result=" and backdays<=3 "
If needtype=7 Then sql_result=" and backdays<=7  and backdays>3 "
If needtype=10 Then sql_result=" and backdays<=10 and backdays>7 "
If needtype=15 Then sql_result=" and backdays<=15 and backdays>10 "
If needtype=999999 Then sql_result=" and backdays>15 "
else
sql_result=" and canremind=1 and  backdays<=reminddays "
end if
basesql = "select ord into #tmpbacktel from dbo.erp_sale_getBackList('" & v2 & "',0) a where a.cateid in (" & ord & ")  " & sql_result
If dtype = 1 Then
getbackteldata = Replace(basesql,"into #tmpbacktel"," ")
Exit Function
else
conn.execute basesql
end if
end function
Function getTelList(ord,v2)
Dim f_sql,f_rs,v,v1, m
If len(ord) = 0 Then
f_sql = "select x.ord from dbo.erp_sale_getWillReplyList('" & v2 & "',0) x"
else
f_sql = "select x.ord from dbo.erp_sale_getWillReplyList('" & v2 & "',0) x where x.cateid in (" & ord & ")"
end if
Set f_rs=conn.execute(f_sql)
Do While Not f_rs.eof
If v1="" Then
v1=f_rs(0).value
else
v1=v1 & "," & f_rs(0).value
end if
f_rs.movenext
Loop
f_rs.close : Set f_rs=Nothing
getTelList=v1
end function
sub error(message)
Response.write "" & vbcrlf & "     <script>alert('"
Response.write message
Response.write "');if(!parent.window.iswork){history.back()}</script>" & vbcrlf & "        "
call db_close : Response.end
end sub
Function GetSortBtFields(byval sort, byval sort1)
Dim list : Set list = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
Dim MustContentType : MustContentType = 0
Dim currgate2 : currgate2 = 0
Dim rs ,sql
Set rs =  conn.execute("select isnull(MustContentType,0) as MustContentType, gate2 from sort5 where sort1=" & sort & " and ord=" & sort1)
if rs.eof= False Then
MustContentType = rs("MustContentType").value
currgate2 = rs("gate2").value
end if
rs.close
sql = "select musthas, MustContentType, isnull(mustContent,'') as mustContent,isnull(mustRole,'') as mustRole, isnull(mustzdy,'') as mustzdy, isnull(mustkz_zdy,'') as mustkz_zdy  from sort5  where sort1=" & sort
if MustContentType = 2 Then
sql = sql & " and (gate2 >" & currgate2 & " or ord=" & sort1 & ") and MustContentType > 0 "
elseif MustContentType = 1 then
sql = sql & " and ord =" & sort1
else
sql = sql & " and 1=0 "
end if
Dim amustcontent :amustcontent = ""
Dim amustrole : amustrole = ""
Dim amustzdy : amustzdy = ""
Dim amustkz_zdy : amustkz_zdy = ""
Dim C : C = ""
Dim R : R = ""
Dim Z : Z = ""
Dim K : K = ""
set rs = conn.execute(sql)
While rs.eof= False
C = rs("mustContent").value
R = rs("mustRole").value
Z = rs("mustzdy").value
K = rs("mustkz_zdy").value
if Len(C)> 0 Then
if Len(amustcontent)> 0 Then  amustcontent = amustcontent & ","
amustcontent = amustcontent & Replace(C ," ", "")
end if
if Len(R) > 0 Then
if len(amustrole) > 0 Then amustrole = amustrole & ","
amustrole = amustrole & Replace(R ," ", "")
end if
if len(Z)> 0 Then
if len(amustzdy)> 0 then amustzdy = amustzdy & ","
amustzdy = amustzdy & Replace(Z ," ", "")
end if
if Len(K)>0 Then
if len(amustkz_zdy) > 0 Then amustkz_zdy = amustkz_zdy & ","
amustkz_zdy = amustkz_zdy & Replace(K ," ", "")
end if
rs.movenext
wend
rs.close
list.Add amustcontent
list.Add amustrole
list.Add amustzdy
list.Add amustkz_zdy
Set GetSortBtFields = list
end function
Function CustomStageWatchs(byval ID , isCurrentNext, sort, sort1, type_ChangeSort, id_ChangeSort, intro_ChangeSort)
Dim rs
Dim v1 : v1 = ""
Dim v2 : v2 = ""
Dim v3 : v3 = ""
Dim v4 : v4 = ""
Dim list
Set list = GetSortBtFields(sort, sort1)
v1 = checkmustcontent(list.item(0), list.item(1),ID)
v2 = checkrole(list.item(1),list.item(0),ID)
v3 = checkzdy(list.item(2),ID)
v4 = checkkz_zdy(list.item(3), ID)
if Len(v1 & v2 & v3 & v4)> 0 Then
Dim s : s = IntToStr(1 ,v1, v2 , v3 , v4)
CustomStageWatchs ="本阶段有必填项未填写，请填写后再保存！" & s & ""
Exit Function
end if
If isCurrentNext = False Then CustomStageWatchs = "" : Exit Function
Call saveSort5change(ID, sort, sort1, type_ChangeSort, id_ChangeSort , intro_ChangeSort)
Set rs = conn.execute("select s.ord, s.sort1, s.sort2, isnull(s.mustHas,0) as  mustHas, s.gate2,s.AutoNext from sort5 s inner join tel t on t.sort=s.sort1 and t.ord=" & id & " and gate2<(select gate2 from sort5 where ord=t.sort1) order by gate2 desc")
Do While rs.eof = False
if rs("AutoNext") = "1" Then
sort = rs("sort1")
sort1 = rs("ord")
Set list = GetSortBtFields(sort, sort1)
v1 = checkmustcontent(list.item(0), list.item(1),ID)
v2 = checkrole(list.item(1),list.item(0),ID)
v3 = checkzdy(list.item(2),ID)
v4 = checkkz_zdy(list.item(3), ID)
if Len(v1 & v2 & v3 & v4)=0 Then
Call saveSort5change(ID, sort, sort1, 0, 0, "系统自动跳转")
else
Exit Do
end if
else
Exit Do
end if
if rs("mustHas").value = "1" Then  Exit Do
rs.movenext
Loop
rs.close
CustomStageWatchs = ""
end function
Function  Sort1FieldsTest(ord, sort, sort1)
Sort1FieldsTest = False
Dim returnStr : returnStr= CustomStageWatchs(ord, False , sort, sort1, 1, ord ,"")
If Len(returnStr)>0 Then
Error returnStr
end if
Sort1FieldsTest = true
end function
Function autoSkipSort(ord,sort,sort1,reason,reasonid,nosortmode,slient,intro)
autoSkipSort=True
Dim presort,presort1,gate2,tgate2
Dim f_rs,n
n=0
Dim mustcontent,mustrole,mustzdy,mustkz_zdy,Aend,autonext,autonext1
Dim amustcontent,amustrole,amustzdy,amustkz_zdy,mustContentType
Dim mustcon_tip,mustrole_tip,mustzdy_tip,mustkz_tip,isbt,namelist
Aend=0
If Len(ord&"")=0 Then ord=0
If Len(sort&"")=0 Then sort=0
If Len(sort1&"")=0 Then sort1=0
Set f_rs=conn.execute("select isnull(sort,0) as sort,isnull(sort1,0) as sort1 from tel where ord="&ord)
If f_rs.eof=False Then
presort=f_rs(0).value
presort1=f_rs(1).value
else
presort=0 : presort1=0 : autoSkipSort=False : Exit function
end if
f_rs.close
If Len(presort&"")=0 Then presort=0
If Len(presort1&"")=0 Then presort1=0
If nosortmode Then sort=presort : sort1=presort1
Dim returnStr : returnStr= CustomStageWatchs(ord ,True , sort, sort1, reason , reasonid ,intro)
if Len(returnStr) > 0 And slient = True Then
If ismobileApp = False Then Error returnStr
autoSkipSort = False
Exit function
end if
autoSkipSort = True
end function
Function getnextsort(sort,sort1)
Dim Frs,Fsql
Set Frs=conn.execute("select * from sort5 where sort1="&sort&" and ord<>" & sort1 & " and gate2<=(select gate2 from sort5 where sort1="&sort&" and ord="&sort1&") order by gate2 desc")
If Frs.eof=False Then
getnextsort=Frs("ord")
else
getnextsort=0
end if
Frs.close : Set Frs=nothing
end function
Function saveSort5change(ord,sort,sort1,reason,reasonid,Fintro)
Dim state : state = "0"
Dim rs , sql
Dim oldsort : oldsort = 0
Dim oldsort1 : oldsort1 = 0
Set rs =conn.execute("select top 1 isnull(sort,0) as sort,isnull(sort1,0) as sort1 from tel where ord=" & ord)
If rs.eof = False Then
oldsort = rs("sort")
oldsort1 =rs("sort1")
end if
rs.close
if oldsort1<>sort1 or sort<0 Then
if sort < 0 Then
sort = oldsort
sort1 = oldsort1
state = "0"
else
state = getstate(oldsort,oldsort1,sort,sort1,ord)
end if
end if
sql = "insert into tel_sort_change_log(tord,sort3,preSort,preSort1,newSort,newSort1,cateid,cateid2,cateid3,reason,reasonid,intro,state,date2,date7,cateadd) " &_
"select ord ,sort3,sort,sort1,'"  & sort &  "','"  & sort1 &"',cateid , cateid2 ,cateid3,'" & reason &"','" & reasonid & "','" & Fintro & "','" & state & "',date2,getdate()," & session("personzbintel2007") &  " from tel where ord = " & ord
conn.execute(sql)
If state<>"0" Then conn.execute("update tel set sort=" & sort &",sort1="  & sort1 & " where ord=" & ord)
end function
Function getstate(psort,psort1,nsort,nsort1,ord)
Dim f_rs ,sortSql
If psort1=0 And nsort1<>0 Then
getstate=1
Exit Function
end if
If psort&""<>nsort&"" Then
sortSql="set nocount on;"&_
"select identity(int,1,1) as id1,cast(ord as int) as ord into #sort4 from (select top 100000000 ord from sort4 order by gate1 desc) a ;"&_
"select * from #sort4 where ord=" & nsort & " and id1>(select id1 from #sort4 where ord=" & psort & ");"&_
"drop table #sort4;set nocount off;"
Set f_rs=conn.execute(sortSql)
If f_rs.eof=false Then
getstate=1
else
getstate=-1
getstate=1
end if
Exit Function
end if
if psort1&""=nsort1&"" then getstate=0 : exit function
If Len(psort&"")=0 Then psort=0
If Len(psort1&"")=0 Then psort1=0
If Len(nsort1&"")=0 Then nsort1=0
sortSql="set nocount on;"&_
"select identity(int,1,1) as id1,cast(ord as int) as ord,sort1 into #sort5 from (select top 100000000 ord,sort1 from sort5 where sort1=" & psort & " order by gate2 desc) a;"&_
"select * from #sort5 where ord=" & nsort1 & " and id1>(select id1 from #sort5 where ord=" & psort1 & ");"&_
"drop table #sort5;set nocount off;"
Set f_rs=conn.execute(sortSql)
If f_rs.eof=false Then
getstate=1
else
getstate=-1
getstate=1
end if
f_rs.close : Set f_rs=Nothing
end function
Function getContentName(value,isid)
Dim v,s,i
v=Split("6,7,8,9,10,11,12,13,14,15,25,27,28,18,19,20,21,23,24,22,92,93,94,95,96,97,98,99,100",",")
s=Split("来源,区域,行业,价值,网址,到款,地址,邮编,法人,注册资本,籍贯,部门,职务,家庭电话,办公电话,手机,传真,QQ,MSN,电子邮件,联系人,客户电话,客户传真,客户邮件,已联系,建立项目,已报价,已成交,关联售后",",")
If isid=True And value&""<>"" Then
For i=0 To ubound(v)
If value&""=v(i)&"" Then getContentName=s(i) : Exit For : Exit Function
next
else
For i=0 To ubound(s)
If value&""=s(i)&"" Then getContentName=v(i) : Exit For : Exit Function
next
end if
end function
Function patchrep(strs,str1)
Dim allstr,tstr,f_i
If Len(str1&"")=0 Then patchrep=strs : Exit Function
If Len(strs&"")=0 Then patchrep=str1 : Exit Function
allstr = strs & "," & str1
allstr = Replace(allstr," ","")
tstr = Split(allstr,",")
allstr=""
For f_i=0 To ubound(tstr)
If InStr(1,"," & allstr & ",","," & tstr(f_i) & ",",1)=0 Then
If allstr="" then
allstr=tstr(f_i)
else
allstr=allstr & "," &tstr(f_i)
end if
end if
next
patchrep=allstr
end function
Function patchrep2(strs,str1)
Dim allstr,tstr,f_i
If Len(str1&"")=0 Then patchrep2="" : Exit Function
If Len(strs&"")=0 Then patchrep2="" : Exit Function
allstr = Replace(str1," ","")
tstr = Split(allstr,",")
allstr=""
For f_i=0 To ubound(tstr)
If InStr(1,"," & strs & ",","," & tstr(f_i) & ",",1)>0 Then
If allstr="" then
allstr=tstr(f_i)
else
allstr=allstr & "," &tstr(f_i)
end if
end if
next
patchrep2=allstr
end function
Function ifarray(obj)
If Not isArray(obj) Then ifarray=False
Dim v,n
v=Err.number
on error resume next
n=ubound(obj)
If Abs(Err.number)<>Abs(v) Then
ifarray=False
else
ifarray=True
end if
Err.number=v
On Error GoTo 0
end function
Sub showlyEndMsg(ByVal msg)
Response.write"<script language=javascript>window.alert(""" & Replace( msg, """", "\""" ) & """);if(parent.window.iswork){}else{history.back();}</script>"
call db_close
Response.end
end sub
Function WatchCustomNumber(ByVal gord, byval addnum, ByVal IsAdd)
Dim rs, uid
uid = gord  & ""
If uid = "" Or uid = "0" Then
Exit Function
end if
Dim hasly_all, hasly_day, hasly_day_add,  hasly_all_add
Dim openA1, openA2, openB1, openB2, NumA, NumB
openA1 = 0 : openA2 = 0 : openB1 = 0 : openB2 = 0 : NumA = 0 : NumB = 0
Set rs = conn.execute("select isnull(sum(case datediff(d,date2,getdate()) when 0 then 1 else 0 end),0) as v1 , count(1) as v2, isnull(sum(case cateid when cateadd then (case datediff(d,date2,getdate()) when 0 then 1 else 0 end) else 0 end),0) as v3, isnull(sum(case cateid when cateadd then 1 else 0end),0) as v4 from tel where cateid = "  & uid & " and sort3=1 and isnull(sp,0)=0 and del=1")
If rs.eof = False then
hasly_day = rs(0).value
hasly_all = rs(1).value
hasly_day_add = rs(2).value
hasly_all_add = rs(3).value
end if
rs.close
Set rs = conn.execute("select isnull(intro,'0'), isnull(extra,'0') from setopen  where sort1=25")
If rs.eof = False then
openA1 = rs(0).value
openA2 = rs(1).value
end if
rs.close
Set rs = conn.execute("select isnull(intro,'0'), isnull(extra,'0') from setopen  where sort1=37")
If rs.eof = False then
openB1 = rs(0).value
openB2 = rs(1).value
end if
rs.close
Set rs = conn.execute("select isnull(num_4,0) as maxnum,isnull(num_ly,0) as maxly from gate where ord=" & uid)
If rs.eof = False Then
NumA = rs(0).value
numB = rs(1).value
end if
rs.close
If openA1 >= 1 Then
If openA2 = 1 Then
If hasly_all + addnum > NumA Then
'If openA2 = 1 Then
WatchCustomNumber = "账号最多可以领用" & NumA & "个客户，已领用了" & hasly_all & "个，最多还可领用" & (NumA-hasly_all) & "个客户！"
'If openA2 = 1 Then
Exit Function
end if
else
If IsAdd = 1 Then addnum = 0
If (hasly_all - hasly_all_add) + addnum > NumA Then
'If IsAdd = 1 Then addnum = 0
WatchCustomNumber = "账号最多可以领用" & NumA & "个客户，已领用了" & (hasly_all-hasly_all_add) & "个，最多还可领用" & (NumA-hasly_all + hasly_all_add) & "个客户！"
'If IsAdd = 1 Then addnum = 0
Exit Function
end if
end if
end if
If openB1 >= 1 Then
If openB2 = 1 Then
If hasly_day + addnum > numB Then
'If openB2 = 1 Then
WatchCustomNumber = "账号今日最多可以领用" & numB & "个客户，已领用了" & hasly_day & "个，最多还可领用" & (numB-hasly_day) & "个客户！"
'If openB2 = 1 Then
Exit Function
end if
else
If IsAdd = 1 Then addnum = 0
If (hasly_day - hasly_day_add) + addnum > numB Then
'If IsAdd = 1 Then addnum = 0
WatchCustomNumber = "账号今日最多可以领用" & numB & "个客户，已领用了" & (hasly_day-hasly_day_add) & "个，最多还可领用" & (numB-hasly_day + hasly_day_add) & "个客户！"
'If IsAdd = 1 Then addnum = 0
Exit Function
end if
end if
end if
WatchCustomNumber = ""
end function
sub check_tel_applynum(ByVal gord, byval addnum, ByVal IsAdd)
message = WatchCustomNumber(gord ,addnum,IsAdd)
If Len(message)> 0 Then
showlyEndMsg message
Exit sub
end if
end sub
Sub salesChangeLog(tord,gord,reason,reasonchildren,f_intro)
If Len(gord & "") = 0 Then gord = "-1"
'Sub salesChangeLog(tord,gord,reason,reasonchildren,f_intro)
Dim sql
sql = " insert into [tel_sales_change_log](tord,sort3,sort,sort1,precateid,newcateid,cateid,date2,date7,reason,reasonchildren,replynum,intro) " &_
"select ord,sort3,sort,sort1,(case when  '"& reason &"'='1' then 0 else cateid end) as precateid,(case when '"& reason &"'='5' then cateid4 else "& gord &" end) as  newcateid ,'" & session("personzbintel2007") & "' as cateid ,isnull(date2,getdate()) as date2 ,getdate() as date7, '"& reason &"' as reason,'" & reasonchildren &"' as reasonchildren ,(select count(1) from reply where ord2=tel.ord) as replynum,'" & f_intro &"' as intro from tel where ord in (" & tord & ") and (('"& reason &"'<>'1' and isnull(cateid,0)<>"& gord &") or '"& reason &"'='1' ) "
conn.execute(sql)
end sub
Function getOption(HourOrMinute)
Dim v,vi
If HourOrMinute="Hour" Then
For vi=0 To 23
If vi<10 Then
v=v & "<option value='0" & vi & "'>0" & vi & "</option>"
else
v=v & "<option value='" & vi & "'>" & vi & "</option>"
end if
next
ElseIf HourOrMinute="Minute" Then
For vi=0 To 55
If (vi Mod 5)=0 then
If vi<10 Then
v=v & "<option value='0" & vi & "'>0" & vi & "</option>"
else
v=v & "<option value='" & vi & "'>" & vi & "</option>"
end if
end if
next
end if
getOption = v
end function
Function isbool(mustcon, strc)
If InStr(1, "," & mustcon & ",", "," & strc & ",", 1) > 0 Then
isbool = True
else
isbool = False
end if
end function
Function isnuul(boolc, isint, strc)
Dim ReturnB
ReturnB = False
If boolc Then
If isint > 0 Then
If strc&"" = "0" Then ReturnB = True
else
If Len(strc&"") = 0 Then ReturnB = True
end if
end if
isnuul = ReturnB
end function
Function GetFieldID(ByVal name)
Select Case UCase(Trim(name))
Case "来源"               : GetFieldID = 6
Case "区域"               : GetFieldID = 7
Case "行业"               : GetFieldID = 8
Case "价值"               : GetFieldID = 9
Case "网址"               : GetFieldID = 10
Case "到款"               : GetFieldID = 11
Case "地址"               : GetFieldID = 12
Case "邮编"               : GetFieldID = 13
Case "法人"               : GetFieldID = 14
Case "注册资本" : GetFieldID = 15
Case "家庭电话" : GetFieldID = 18
Case "办公电话" : GetFieldID = 19
Case "手机"               : GetFieldID = 20
Case "传真"               : GetFieldID = 21
Case "电子邮件" : GetFieldID = 22
Case "QQ"         : GetFieldID = 23
Case "MSN"                : GetFieldID = 24
Case "籍贯"               : GetFieldID = 25
Case "部门"               : GetFieldID = 27
Case "职务"               : GetFieldID = 28
Case "联系人"     : GetFieldID = 92
Case "客户电话" : GetFieldID = 93
Case "客户传真" : GetFieldID = 94
Case "客户邮件" : GetFieldID = 95
Case "已联系"     : GetFieldID = 96
Case "已项目"     : GetFieldID = 97
Case "已报价"     : GetFieldID = 98
Case "已合同"     : GetFieldID = 99
Case "已收回"     : GetFieldID = 100
End select
end function
Function checkmustcontent(ByVal mustcon,  ByVal mustrole, byval tord)
checkmustcontent = checkmustcontentBase(mustcon, mustrole, tord, mustcon)
end function
Function checkmustcontentBase(ByVal mustcon,  ByVal mustrole, byval tord, ByVal allmustcon)
Dim Rs, StrR,i,fields,fields1, fid, sql,person_ord
StrR=""
Set rs=conn.execute("select top 1 isnull(ly,0),isnull(area,0),isnull(trade,0),isnull(jz,0),len(isnull(url,'')),len(isnull(hk_xz,0)),len(isnull(address,'')),len(isnull(zip,'')),(case when len(isnull(faren,''))>0 or sort2=2 then 1 else 0 end),(case when isnull(zijin,0)>0 or sort2=2 then 1 else 0 end),len(isnull(phone,'')),len(isnull(fax,'')),len(isnull(email,'')) from tel where ord="&tord&"")
If Not rs.eof Then
fields=Split("来源,区域,行业,价值,网址,到款,地址,邮编,法人,注册资本,客户电话,客户传真,客户邮件",",")
For i=0 To ubound(fields)
fid = GetFieldID(fields(i))
If isnuul(isbool(mustcon, fid),1,rs(i)) Then
StrR = StrR & "," & fid
end if
next
end if
rs.close
person_ord = ""
If Len(session("tel_person")&"")>0 And isnumeric(session("tel_person")&"") Then
person_ord = " and ord ="&session("tel_person")
end if
Set rs=conn.execute("select len(isnull(jg,'')),len(isnull(part1,'')),len(isnull(job,'')),len(isnull(phone,'')),len(isnull(phone2,'')),len(isnull(mobile,'')),len(isnull(fax,'')),len(isnull(email,'')),len(isnull(qq,'')),len(isnull(MSN,'')), name,role from person where del<>2 and company="&tord&" "&person_ord)
checkmustcontentPersons = ""
Dim itemstr, itemv
While rs.eof = False
itemstr = ""
If isbool(mustcon,GetFieldID("联系人")) Or isbool(mustrole, rs("role").value) then
fields1=Split("籍贯,部门,职务,办公电话,家庭电话,手机,传真,电子邮件,QQ,MSN",",")
For i=0 To ubound(fields1)
itemv = GetFieldID(fields1(i))
If isnuul(isbool(mustcon,itemv),1, rs(i)) Then
itemstr = itemstr & "," & itemv
If InStr(1, "," & strR & "," , "," & itemv & ",", 1) = 0 Then
strR = strR & "," & itemv
end if
If Len(itemstr) > 0 Then
itemstr = itemstr & ","
end if
itemstr = itemstr & itemv
end if
next
If Len(checkmustcontentPersons) > 0 Then
checkmustcontentPersons = checkmustcontentPersons & "|"
end if
checkmustcontentPersons = checkmustcontentPersons & itemstr
end if
rs.movenext
wend
rs.close
If isbool(mustcon, GetFieldID("联系人")) Then
If conn.execute("select 1 from person a where del<>2 and company=" & tord&" "&person_ord).eof Then
strR = strR & "," & GetFieldID("联系人")
end if
end if
If isbool(mustcon, GetFieldID("已联系")) Then
Dim resultok
resultok = True
If conn.execute("select top 1 1 from reply a inner join tel b on a.ord=b.ord and a.cateid=b.cateid and a.date7 > b.date2 and a.del=1 and a.ord =" & tord).eof=True Then
resultok =  false
strR = strR & "," & GetFieldID("已联系")
end if
If resultok And Len(mustrole)>0 Then
arrRole=Split(mustrole,",")
For i=0 To ubound(arrRole)
sql = "select 1 from reply a inner join person b on a.del=1 and a.sort1=8 and a.ord2=b.ord " &_
" and b.del<>2 and b.role='"&arrrole(i)&"' and b.company="& tord &" "&Replace(person_ord,"ord","b.ord") &_
" and b.company=a.ord inner join tel c on a.ord=c.ord and a.date7 > c.date2"
If conn.execute(sql).eof=True Then
strR = strR & "," & GetFieldID("已联系")
resultok = false
Exit For
end if
next
end if
If resultok then
If isbool(allmustcon, GetFieldID("联系人")) Then
sql = "select 1 from person a inner join tel c on a.company=c.ord and a.del<>2 and c.ord=" & tord &" "&Replace(person_ord,"ord","a.ord") &_
" left join reply b on a.ord=b.ord2 and b.sort1=8 and b.del<>2 and b.date7>c.date2 " &_
" where b.ord is null"
If conn.execute(sql).eof = false Then
strR = strR & "," & GetFieldID("已联系")
resultok = false
end if
end if
end if
end if
If isbool(mustcon, GetFieldID("已项目")) Then
sql = "select top 1 1 from chance where isnull(sp,0)=0 and cateid=(select top 1 cateid from tel where ord="&tord&") and del=1 and charindex('," & tord & ",',','+company+',')>0"
'If isbool(mustcon, GetFieldID("已项目")) Then
If conn.execute(sql).eof= True Then
strR = strR & "," & GetFieldID("已项目")
end if
end if
If isbool(mustcon, GetFieldID("已报价")) Then
sql = "select top 1 1 from price where del=1 and isnull(status,-1) in (-1,1) and cateid=(select top 1 cateid from tel where ord="&tord&") and company=" & tord
'If isbool(mustcon, GetFieldID("已报价")) Then
If conn.execute(sql).eof=True Then
strR = strR & "," & GetFieldID("已报价")
end if
end if
If isbool(mustcon, GetFieldID("已合同")) Then
sql = "select top 1 1 from contract where isnull(sp,0)=0 and cateid=(select top 1 cateid from tel where ord="&tord&") and del=1 and company=" & tord
If conn.execute(sql).eof=True Then
strR = strR & "," & GetFieldID("已合同")
end if
end if
If isbool(mustcon, GetFieldID("已收回")) Then
sql = "select top 1 1 from tousu where del=1 and cateid=(select top 1 cateid from tel where ord="&tord&") and company=" & tord
If conn.execute(sql).eof=True then
strR = strR & "," & GetFieldID("已收回")
end if
end if
checkmustcontentBase=StrR
end function
Function checkkz_zdy(kzmustcon,tord)
Dim v ,i, strR
strR = ""
v=kzmustcon
v=Replace(v," ","")
If v<>"" Then
v=Split(v,",")
For i=0 To ubound(v)
If isnumeric(v(i)) Then
If conn.execute("select top 1 1 from ERP_CustomValues where FieldsId=" & v(i) & " and OrderId=" & tord & " and isnull(Fvalue,'')<>''").eof=True Then strR = strR & "," & v(i)
end if
next
end if
checkkz_zdy=strR
end function
Function checkzdy(zdymustcon,tord)
Dim v, i, strR
strR = ""
v=zdymustcon
v=Replace(v," ","")
If v<>"" Then
v=Split(v,",")
For i=0 To ubound(v)
If isnumeric(v(i)) Then
If conn.execute("select top 1 1 from tel where isnull(zdy" & v(i) & ",'')<>'' and ord=" & tord ).eof=True Then strR = strR & "," & v(i)
end if
next
end if
checkzdy=strR
end function
Function checkrole(mustrole,mustcon,tord)
Dim strR,v,i,n
v=mustrole
If Len(v&"")>0 Then
v=Split(v,",")
For i=0 To ubound(v)
n=Trim(v(i))
If Len(n&"")=0 Or isnumeric(n)=False Then n=0
If isbool(mustcon,96) Then
If conn.execute("select top 1 1 from person where isnull(role,0)>0 and role=" & n & " and del<>2 and company=" & tord &" and ord in(select ord2 from reply where sort1=8 and del=1)").eof=True Then strR = strR & "," & n
else
If conn.execute("select top 1 1 from person where isnull(role,0)>0 and role=" & n & " and del<>2 and company=" & tord ).eof=True Then strR = strR & "," & n
end if
next
end if
checkrole=strR
end function
Function IntToStr(intType,mustConStr,mustRoleStr,mustZdyStr,mustKzStr)
Dim intlist,nameList,nameList1,nameList2,rss
intlist=""
nameList=""
If intType=1 Then
If Len(Trim(mustConStr))>0 Then
intlist=mustConStr
If Left(intlist,1)="," Then intlist=Right(mustConStr,Len(mustConStr)-1)
'intlist=mustConStr
Set rss=conn.execute("select gate1,(case when isnull(name,'')='' then oldname else name end ) as name,isnull(show,0) as show,point,enter,format from setfields where gate1 in ( 6,7,8,9,10,11,12,13,14,15,25,27,28,18,19,20,21,23,24,22) order by gate1")
Do While Not rss.eof
If isbool(mustConStr,rss(0)) Then nameList2=nameList2 & "【"&rss(1)&"】"
If (isbool(mustConStr,93) And rss(0)=19) Or (isbool(mustConStr,94) And rss(0)=21) Or (isbool(mustConStr,95) And rss(0)=22) Then nameList1=nameList1 & "【"&rss(1)&"（客户）】"
rss.movenext
Loop
rss.close : Set rss=Nothing
nameList=nameList & nameList1
If isbool(mustConStr,92) Then nameList=nameList & "【联系人】"
nameList=nameList & nameList2
end if
If Len(Trim(mustRoleStr))>0 Then nameList=nameList & getmustContent("select ord,sort1 from sort9 where 1=1",1,"ord","sort1",mustRoleStr)
If Len(Trim(mustZdyStr))>0 Then nameList=nameList & getmustContent("select id,title,name,sort,gl from zdy where sort1=1 and set_open=1 order by gate1 asc",2,"id","title",mustZdyStr)
If Len(Trim(mustKzStr))>0 Then nameList=nameList & getmustContent("select id,fname from ERP_CustomFields where TName=1 and IsUsing=1 and del=1 order by FOrder asc",3,"id","fname",mustKzStr)
If Len(Trim(mustConStr))>0 Then
If isbool(mustConStr,96) Then nameList=nameList & "【已联系】"
If isbool(mustConStr,97) Then nameList=nameList & "【建立项目】"
If isbool(mustConStr,98) Then nameList=nameList & "【已报价】"
If isbool(mustConStr,99) Then nameList=nameList & "【已成交】"
If isbool(mustConStr,100) Then nameList=nameList & "【关联售后】"
end if
end if
If nameList<>"" Then nameList="\n必填项有：" & nameList
IntToStr=nameList
end function
Public Function getmustContent(sql,keyid,ids,names,model_id)
Dim f_rs,s
Set f_rs=conn.execute(sql)
Do While Not f_rs.eof
If isbool(model_id,f_rs(ids)) then
s = s & "【" & f_rs(names) & "】"
end if
f_rs.movenext
Loop
f_rs.close : Set f_rs=nothing
getmustContent=s
end function
Function canGetCompany(tel_ord,neednum, canly, needsort, intro , needGetApply ,condition,limitsort1,limitsort2,limitsort3,limitsort4,limitsort5,limitsort6,limitsort7,limitsort8,limitsort9, needGetTel, cateid4,sort,sort1,ly,jz,trade,area,zdy5,zdy6, needzdy, ishaszdy5, ishaszdy6)
Dim islingy,telrs,rs1 , rss ,rss1
islingy=True
If Len(tel_ord&"") = 0 Then
canGetCompany = islingy
Exit Function
end if
If needGetTel = True Then
set telrs=conn.execute("select * from tel where ord="& tel_ord &" ")
If telrs.eof = False Then
cateid4 = telrs("cateid4")
sort=telrs("sort")
sort1=telrs("sort1")
ly=telrs("ly")
jz=telrs("jz")
trade=telrs("trade")
area=telrs("area")
zdy5=telrs("zdy5")
zdy6=telrs("zdy6")
end if
telrs.close
end if
If cateid4&"" = "" Then cateid4 = 0
If neednum = True Then
If Len(WatchCustomNumber(member2, 1, 0))>0 Then islingy=False
else
islingy = canly
end if
If islingy = False Then
canGetCompany = islingy
Exit Function
end if
If needsort = True Then
intro = 0
set rs1=conn.execute("select isnull(intro,0) as intro from setopen where sort1=39 and isnull(intro,0)>0")
If rs1.eof = False Then
intro=rs1("intro")
end if
rs1.close
end if
Dim lysql, qysql
If intro>0 Then
If intro=2 Then
lysql=" and cateid=0"
qysql=" and ord =0 "
else
lysql=" and cateid="& cateid4 &" "
qysql=" and ord = " & cateid4 &" "
end if
If needGetApply Then
Set rss=conn.execute("select * from tel_apply where 1=1 " & lysql )
If Not rss.eof Then
condition=rss("condition")
limitsort1=rss("limitsort1")
limitsort2=rss("limitsort2")
limitsort3=rss("limitsort3")
limitsort4=rss("limitsort4")
limitsort5=rss("limitsort5")
limitsort6=rss("limitsort6")
If limitsort6&""="" Then limitsort6 = 0
limitsort7=rss("limitsort7")
limitsort8=rss("limitsort8")
limitsort9=rss("limitsort9")
else
canGetCompany = islingy
Exit Function
end if
rss.close
end if
Dim isfl : isfl=False
If limitsort1&""<>"" And Len(sort&"")>0 And sort&""<>"0" Then
If InStr(","&Replace(limitsort1," ","")&",",","&sort&",")>0 Then isfl=True
ElseIf condition=1 Then
isfl=True
ElseIf Len(limitsort1&"")>0 and (Len(sort&"")=0 Or sort&""="0") Then
isfl=True
end if
Dim isgj : isgj=False
If limitsort2&""<>"" And Len(sort1&"")>0 And sort1&""<>"0" Then
If InStr(","&Replace(limitsort2," ","")&",",","&sort1&",")>0 Then isgj=True
ElseIf condition=1 Then
isgj=True
ElseIf Len(limitsort2&"")>0 and (Len(sort1&"")=0 Or sort1&""="0") Then
isgj=True
end if
Dim isly : isly=False
If limitsort3&""<>"" And Len(ly&"")>0 And ly&""<>"0" Then
If InStr(","&Replace(limitsort3," ","")&",",","&ly&",")>0 Then isly=True
ElseIf condition=1 Then
isly=True
ElseIf Len(limitsort3&"")>0 and (Len(ly&"")=0 Or ly&""="0") Then
isly=True
end if
Dim isjz : isjz=False
If limitsort4&""<>"" And jz&""<>"0" And Len(jz&"")>0 Then
If InStr(","&Replace(limitsort4," ","")&",",","&jz&",")>0 Then isjz=True
ElseIf condition=1 Then
isjz=True
ElseIf Len(limitsort4&"")>0 and (Len(jz&"")=0 Or jz&""="0") Then
isjz=True
end if
Dim ishy : ishy=False
If limitsort5&""<>"" And Len(trade&"")>0 And trade&""<>"0"  Then
If InStr(","&Replace(limitsort5," ","")&",",","&trade&",")>0 Then ishy=True
ElseIf condition=1 Then
ishy=True
ElseIf Len(limitsort5&"")>0 and (Len(trade&"")>0 Or trade&""="0") Then
ishy=True
end if
Dim isqy : isqy=False
If limitsort6=1 And Len(area&"")>0 And area&""<>"0" Then
If conn.execute("select count(id) from tel_area where sort=2 and area="& area &" " & qysql)(0)>0 Then isqy=True
ElseIf condition=1 Then
isqy=True
ElseIf limitsort6=1 and (Len(area&"")=0 Or area&""="0") Then
isqy=True
end if
If needzdy = True Then
ishaszdy5 = (conn.execute("select 1 from zdy where sort1=1 and set_open=1 and name='zdy5' ").eof = false)
ishaszdy6 = (conn.execute("select 1 from zdy where sort1=1 and set_open=1 and name='zdy6' ").eof = false)
end if
Dim iszdy5 : iszdy5=False
If ishaszdy5 Then
If limitsort7&""<>"" And Len(zdy5&"")>0 And zdy5&""<>"0" Then
If InStr(","&Replace(limitsort7," ","")&",",","&zdy5&",")>0 Then iszdy5=True
ElseIf condition=1 Then
iszdy5=True
ElseIf Len(limitsort7&"")>0 and (Len(zdy5&"")=0 Or zdy5&""="0") Then
iszdy5=True
end if
ElseIf condition=1 Then
iszdy5=True
end if
Dim iszdy6 : iszdy6=False
If ishaszdy6 Then
If limitsort8&""<>"" And Len(zdy6&"")>0 And zdy6&""<>"0" Then
If InStr(","&Replace(limitsort8," ","")&",",","&zdy6&",")>0 Then iszdy6=True
ElseIf condition=1 Then
iszdy6=True
ElseIf Len(limitsort8&"")>0 And (Len(zdy6&"")=0 Or zdy6&""="0") Then
iszdy6=True
end if
ElseIf condition=1 Then
iszdy6=True
end if
Dim iskz : iskz=False
If limitsort9&""<>"" Then
Dim kz_zdyfields()
Dim kz_zdyValue()
reDim kz_zdyfields(0)
reDim kz_zdyValue(0)
Dim j : j=0
Dim iskz_zdy : iskz_zdy=False
Set rss1=conn.execute("select id,FValue from ERP_CustomFields f left join (select FieldsID,o.id as FValue from ERP_CustomValues v inner join ERP_CustomOptions o on v.FValue=o.cvalue and o.del=1 where v.OrderID='"& tel_ord &"') a on a.FieldsID = f.id where TName=1 and FType=7 and IsUsing=1 and del=1 order by FOrder asc ")
While Not rss1.eof
iskz_zdy=True
redim Preserve kz_zdyfields(j)
redim Preserve kz_zdyValue(j)
kz_zdyfields(j)=rss1("id")
kz_zdyValue(j)=Trim(rss1("FValue"))
j=j+1
'kz_zdyValue(j)=Trim(rss1("FValue"))
rss1.movenext
wend
rss1.close
If iskz_zdy Then
Dim r , strlm,strlm2 ,strlm_one ,kz_zdy ,kz_id ,kz_str
strlm=Split(limitsort9,"||")
strlm2=Split(limitsort9,"||")
For r=0 To ubound(strlm)
strlm_one=strlm(r)
If strlm_one<>"" Then
kz_zdy=Split(strlm_one,":")
strlm2(r)=kz_zdy(0)
strlm(r)=kz_zdy(1)
end if
next
kz_id=Join(strlm2,",")
kz_str=Join(strlm,",")
For r=0 To ubound(kz_zdyfields)
If InStr(","&Replace(kz_id," ",""),","&kz_zdyfields(r)&",")>0 Then
If InStr(","&Replace(kz_str," ",""),","&kz_zdyValue(r)&",")>0 Or (Len(kz_zdyValue(r))=0 Or kz_zdyValue(r)&""="0") Then
iskz=True
If condition=0 Then Exit For
else
iskz=False
If condition=1 Then Exit For
end if
end if
next
ElseIf condition=1 Then
iskz=True
end if
ElseIf condition=1 Then
iskz=True
end if
If len(limitsort1&"")=0 and len(limitsort2&"")=0 and len(limitsort3&"")=0 and len(limitsort4&"")=0 and len(limitsort5&"")=0 and (len(limitsort6&"")=0 or limitsort6="0") and len(limitsort7&"")=0 and len(limitsort8&"")=0 and len(limitsort9&"")=0 Then
else
If condition=1 Then
If isfl And isgj And isly And isjz And ishy And isqy And iszdy5 And iszdy6 And iskz Then
else
islingy=False
end if
else
If (isfl and isgj) Or isly Or isjz Or ishy Or isqy Or iszdy5 Or iszdy6 Or iskz Then
else
islingy=False
end if
end if
end if
end if
canGetCompany = islingy
end function
Function ismobileApp()
ismobileApp = InStr(Trim(Request.ServerVariables("CONTENT_TYPE")), "application/zsml")>0 Or InStr(Trim(Request.ServerVariables("CONTENT_TYPE")) , "application/json")>0 Or Request.QueryString("__mobile2_debug") = "1"
end function
Function WatchCustomExtent(byval uid ,ByVal ID)
Dim r : r = true
Dim order1 : order1 = 0
Dim rs
Dim resort : resort = ""
Dim resort1: resort1= ""
Dim rely : rely =""
Dim rejz: rejz = ""
Dim retrade: retrade =""
Dim rearea: rearea =""
Dim rezdy5: rezdy5 = ""
Dim rezdy6: rezdy6 = ""
Dim rekz : rekz = ""
Dim telarea : telarea = ""
if ID> 0 Then
Set rs = conn.execute("select a.*, b.sex,b.name as person,b.part1,b.job,b.mobile,b.QQ,b.email,b.phone2,b.msn from tel a left join person b on a.person=b.ord where a.ord=" & id )
If rs.eof = False Then
order1=rs("order1").value
resort=rs("sort")
resort1=rs("sort1")
rely=rs("ly")
rejz=rs("jz")
retrade=rs("trade")
rearea=rs("area")
rezdy5=rs("zdy5")
rezdy6=rs("zdy6")
telarea = rs("area")
end if
rs.close
Set rs = conn.execute("select id,CValue from ERP_CustomOptions where CFID in (select id from ERP_CustomFields where TName=1 and IsUsing=1 and del=1 and FType=7) and  CValue=(select top 1 FValue from ERP_CustomValues where  FieldsID=ERP_CustomOptions.CFID and OrderID="& id & " )")
While rs.eof=False
If Len(rekz)>0 Then rekz = rekz & ","
rekz = rekz & rs("id")
rs.movenext
wend
rs.close
end if
If order1<>1 Then
Dim intro : intro = 0
Set rs = conn.execute("select isnull(intro,0) as intro from setopen where sort1=39 and isnull(intro,0)>0")
If rs.eof = False Then
intro = rs("intro").value
else
WatchCustomExtent = True
Exit Function
end if
rs.close
Dim lysql: lySql = " and cateid=" & uid &  " and isnull(del,1)=1 "
Dim qysql: qysql = " and ord=" & uid
if intro = 2 Then
lySql = " and cateid=0"
qysql = " and ord=0 "
end if
Dim condition :condition = 0
Set rs = conn.execute("select * from tel_apply where 1=1 " & lySql)
If rs.eof = True Then
WatchCustomExtent = True
Exit Function
else
condition = rs("condition").value
Dim sort , sort1 ,ly,jz,trade ,area ,zdy5 , zdy6
If ismobileApp = True Then
sort = Split(app.mobile("sort1"),",")(0)
sort1 = Split(app.mobile("sort1"),",")(1)
ly = app.mobile("ly")
jz = app.mobile("jz")
trade = app.mobile("trade")
area = app.mobile("area")
zdy5 = app.mobile("zdy5")
zdy6 = app.mobile("zdy6")
else
sort = request("sort")
sort1 = request("sort1")
ly = request("ly")
jz = request("jz")
trade = request("trade")
area =  request("area")
zdy5 = request("zdy5")
zdy6 = request("zdy6")
end if
Dim fields : Set fields = GetFields(1)
Dim isfl : isfl = tel_canLy(condition, rs("limitsort1").value & "", sort, resort , fields.GetItemByDBname("sort").show)
Dim isgj : isgj = tel_canLy(condition, rs("limitsort2").value & "", sort1, resort1, fields.GetItemByDBname("sort1").show)
Dim isly : isly = tel_canLy(condition, rs("limitsort3").value & "", ly, rely, fields.GetItemByDBname("ly").show)
Dim isjz : isjz = tel_canLy(condition, rs("limitsort4").value & "", jz, rejz, fields.GetItemByDBname("jz").show)
Dim ishy : ishy = tel_canLy(condition, rs("limitsort5").value & "", trade, retrade, fields.GetItemByDBname("trade").show)
Dim isqy : isqy = false
if Len(area&"") = 0 then area = telarea
if rs("limitsort6")= 1 and Len(area)>0 Then
isqy = (conn.execute("select top 1 id from tel_area where sort=2 and area=" & area & qysql &"").eof =False )
if area= rearea Then isqy = true
elseif rs("limitsort6") = 0 and Len(area)= 0 And fields.GetItemByDBname("area").show=True Then
isqy = true
ElseIf condition=1 Then
isqy = true
end if
Dim zdyfields : Set zdyfields = GetZdyFields(1)
Dim iszdy5 : iszdy5 = tel_canLy(condition, rs("limitsort7").value & "", zdy5, rezdy5, zdyfields.GetItemByDBname("zdy5").show )
Dim iszdy6 : iszdy6 = tel_canLy(condition, rs("limitsort8").value & "", zdy6, rezdy6, zdyfields.GetItemByDBname("zdy6").show )
Dim limitsort9 : limitsort9 = rs("limitsort9").value & ""
Dim iskz : iskz = ExtendedLy(condition, limitsort9, rekz)
if Len(rs("limitsort1")&"")>0 Or Len(rs("limitsort2")&"")>0 Or Len(rs("limitsort3")&"")>0 Or Len(rs("limitsort4")&"")>0 Or Len(rs("limitsort5")&"")>0 Or rs("limitsort6")=1 Or Len(rs("limitsort7")&"")>0 Or Len(rs("limitsort8")&"")>0 Or Len(limitsort9&"")>0 Then
if condition = 1 Then
if isfl = false Or isgj = false or isly = false or isjz = false or ishy = false or isqy = false or iszdy5 = false or iszdy6 = false or iskz = False Then r = false
else
if (isfl and isgj) = false and isly = false and isjz = false and ishy = false and isqy = false and iszdy5 = false and iszdy6 = False and iskz = False Then r = false
end if
end if
end if
rs.close
end if
WatchCustomExtent = r
end function
Function tel_canLy(ByVal typeCondition ,byval limit ,byval  newValue , byval oldValue , byval show)
Dim r : r = false
limit = Replace(limit , " ", "")
if Len(limit) > 0 And Len(newValue) > 0 Then
if Len(oldValue)> 0 Then  limit = limit & "," & oldValue
if instr("," & limit & "," , "," & newValue & ",") > 0 Then  r = true
elseif  Len(limit) > 0 and Len(newValue)= 0 and show Then
r = true
elseif typeCondition = 1 Then
r = true
end if
tel_canLy = r
end function
Function ExtendedLy(ByVal typeCondition, Byref limit ,ByVal oldValue)
Dim i
Dim r : r = False
If Len(limit)>0 Then
Dim kz_id : kz_id = ""
Dim kz_str : kz_str = ""
Dim strlm : strlm = Split(limit ,"or")
For i = 0 To ubound(strlm)
if Len(strlm(i))> 0 Then
if len(kz_id)> 0 Then kz_id = kz_id & ","
if len(kz_str)> 0 Then kz_str = kz_str & ","
kz_id = kz_id & Split(strlm(i) ,":")(0)
kz_str = kz_str & Split(strlm(i) ,":")(1)
end if
if Len(oldValue)> 0 Then kz_str = kz_str & "," & oldValue
next
Dim extrafields : Set extrafields = GetExtraFields(1)
Dim OID , hasKz , field
hasKz = False
For i = 0 To extrafields.count-1
'hasKz = False
Set field = extrafields.item(i)
If field.show = True And field.sorttype = 7 Then
If ismobileApp = True Then
OID = app.mobile("meju_" & field.Key )
else
OID = request("meju_" & field.Key )
end if
if instr("," & kz_id & ",","," & field.Key & ",") > 0 Then
hasKz = True
if instr("," & kz_str & ",","," & OID & ",") > 0 Or Len(OID)=0 Then
r = true
if typeCondition = 0 Then Exit For
else
r = false
if typeCondition = 1 Then Exit For
end if
end if
end if
next
If hasKz = False Then
limit = ""
If typeCondition = 1 Then r = True
end if
elseif typeCondition = 1 Then
r = true
end if
ExtendedLy= r
end function
Function CustomReviewWatchs(id)
Dim r : r = False
Dim rs , rss
Dim fields : Set fields = GetFields(1)
if id = 0 or ( id > 0 And conn.execute("select ord from tel where ord='" & id & "' and (datediff(d,getdate(),date1)>=0 or isnull(sp,0)<>0) ").eof= False ) Then
Dim condition :condition = 0
Set rs= conn.execute("select * from tel_review ")
If rs.eof = False Then
condition = rs("condition").value
Dim sort , sort1 ,ly,jz,trade ,area ,zdy5 , zdy6
If ismobileApp = True Then
sort = Split(app.mobile("sort1"),",")(0)
sort1 = Split(app.mobile("sort1"),",")(1)
ly = app.mobile("ly")
jz = app.mobile("jz")
trade = app.mobile("trade")
area = app.mobile("area")
zdy5 = app.mobile("zdy5")
zdy6 = app.mobile("zdy6")
else
sort = request("sort")
sort1 = request("sort1")
ly = request("ly")
jz = request("jz")
trade = request("trade")
area =  request("area")
zdy5 = request("zdy5")
zdy6 = request("zdy6")
end if
Dim isfl : isfl = hasReview(condition, rs("limitsort1")&"", sort, fields.GetItemByDBname("sort").show)
Dim isgj : isgj = hasReview(condition, rs("limitsort2")&"", sort1, fields.GetItemByDBname("sort1").show)
Dim isly : isly = hasReview(condition, rs("limitsort3")&"", ly, fields.GetItemByDBname("ly").show)
Dim isjz : isjz = hasReview(condition, rs("limitsort4")&"", jz, fields.GetItemByDBname("jz").show)
Dim ishy : ishy = hasReview(condition, rs("limitsort5")&"", trade, fields.GetItemByDBname("trade").show)
Dim isqy : isqy = false
if rs("limitsort6")= 1 Then
if Len(area)>0 Then
isqy = (conn.execute("select top 1 id from tel_area where sort=1 and area=" & area &"").eof =False )
elseif condition= 1 And fields.GetItemByDBname("area").show=False Then
isqy = True
end if
Elseif condition= 1 Then
isqy = True
end if
Dim zdyfields : Set zdyfields = GetZdyFields(1)
Dim iszdy5 : iszdy5 = hasReview(condition, rs("limitsort7")&"", zdy5,  zdyfields.GetItemByDBname("zdy5").show )
Dim iszdy6 : iszdy6 = hasReview(condition, rs("limitsort8")&"", zdy6, zdyfields.GetItemByDBname("zdy6").show )
Dim limitsort9 : limitsort9 = rs("limitsort9")&""
Dim iskz : iskz = ExtendedReview(condition, limitsort9)
if Len(rs("limitsort1")&"")>0 Or Len(rs("limitsort2")&"")>0 Or Len(rs("limitsort3")&"")>0 Or Len(rs("limitsort4")&"")>0 Or Len(rs("limitsort5")&"")>0 Or rs("limitsort6")=1 Or Len(rs("limitsort7")&"")>0 Or Len(rs("limitsort8")&"")>0 Or Len(limitsort9&"")>0 Then
if condition = 1 Then
if isfl and isgj and isly and isjz and ishy and isqy and iszdy5 and iszdy6 and iskz Then  r = true
else
if (isfl and isgj) or isly or isjz or ishy or isqy or iszdy5 or iszdy6 or iskz Then  r = true
end if
end if
end if
end if
CustomReviewWatchs = r
end function
Function hasReview(ByVal condition , ByVal limit , ByVal newValue ,ByVal show)
Dim r : r = false
limit = Replace(limit, " ", "")
if Len(limit) > 0 Then
if Len(newValue) > 0 Then
If instr("," & limit & "," , "," & newValue & ",") > 0  Then  r = true
elseif show=False and condition = 1 Then
r = true
end if
elseif condition=1 Then
r = True
end if
hasReview = r
end function
Function ExtendedReview(ByVal typeCondition, Byref limit)
Dim r ,i ,field
r = False
If Len(limit)>0 Then
Dim kz_id : kz_id = ""
Dim kz_str : kz_str = ""
Dim strlm : strlm = Split(limit ,"or")
For i = 0 To ubound(strlm)
if Len(strlm(i))> 0 Then
if len(kz_id)> 0 Then kz_id = kz_id & ","
if len(kz_str)> 0 Then kz_str = kz_str & ","
kz_id = kz_id & Split(strlm(i) ,":")(0)
kz_str = kz_str & Split(strlm(i) ,":")(1)
end if
next
Dim extrafields : Set extrafields = GetExtraFields(1)
Dim OID , hasKz
hasKz = False
For i = 0 To extrafields.count-1
'hasKz = False
Set field = extrafields.item(i)
If field.show = True And field.sorttype = 7 Then
If ismobileApp = True Then
OID = app.mobile("meju_" & field.Key )
else
OID = request("meju_" & field.Key )
end if
if instr("," & kz_id & ",","," & field.Key & ",") > 0 Then
hasKz = True
if instr("," & kz_str & ",","," & OID & ",") > 0 and Len(OID)>0 Then
r = true
if typeCondition = 0 Then Exit For
else
r = false
if typeCondition = 1 Then Exit For
end if
end if
end if
next
If hasKz = False Then
limit = ""
If typeCondition = 1 Then r = True
end if
elseif typeCondition = 1 Then
r = true
end if
ExtendedReview = r
end function
Public pub_cf,KZ_LIMITID
Function getExtended(TName,ord)
Call showExtended(TName,ord,3,1,1)
end function
function ShowExtendedByProductGroup(byval TName,byval ord,byval columns, byval col1, byval col2 ,byval isIntro ,byval bzstr ,byval tsstr ,byval oldZdySort ,byval readonly,byval zdygroupid)
if zdygroupid = 0 then zdygroupid = -1
dim rss
Response.write "" & vbcrlf & "       <tr class=""top accordion"" id=""cpBasezdygroup"">" & vbcrlf & "      <td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "           <div  class=""accordion-bar-tit"" style=""padding-top:6px;"">" & vbcrlf & "                   自定义字段 <span class=""accordion-arrow-down""></span>" & vbcrlf & "             </div>" &vbcrlf & "          <div onclick=""app.stopDomEvent();return false"" style=""float:left;padding:5px"">" & vbcrlf & "              &nbsp;" & vbcrlf & "          "
if readonly then
dim wsql : wsql = " and  ord="  & clng(zdygroupid)
if zdygroupid = -1 then wsql=" and tagdata='1' "
'dim wsql : wsql = " and  ord="  & clng(zdygroupid)
set rss = conn.execute("select ord, sort1, tagdata from sortonehy where gate2=63 and ord=" & zdygroupid)
if rss.eof = false then
Response.write rss("sort1").value
end if
rss.close
else
Response.write "" & vbcrlf & "              <select name=""zdygroupid"" style=""min-width:100px"" onchange=""refreshProductGroupArea("
rss.close
Response.write ord
Response.write ", this)"">" & vbcrlf & "                  "
set rss = conn.execute("select ord, (case tagdata when '1' then '' else sort1 end) as sort1, tagdata from sortonehy where gate2=63 order by gate1 desc")
while rss.eof = false
tagdata = rss("tagdata").value
sortord =rss("ord").value
if tagdata = "1" then sortord = 0
if zdygroupid = sortord then
Response.write "<option value='" & sortord & "' selected>" & rss("sort1").value & "</option>"
else
Response.write "<option value='" & sortord & "'>" & rss("sort1").value & "</option>"
end if
rss.movenext
wend
rss.close
Response.write "" & vbcrlf & "              </select>" & vbcrlf & "               <script>" & vbcrlf & "                        function refreshProductGroupArea(billord,  sbox ){" & vbcrlf & "                              var  x = new XMLHttpRequest();" & vbcrlf & "                          x.open(""Get"", window.sysCurrPath + ""inc/GetExtended.ProductGroup.asp?t="" + (new Date()).getTime() + ""&billord="" + billord + ""&groupid="" + sbox.value,  false)" & vbcrlf & "                          x.send();" & vbcrlf & "                               var html = x.responseText;" & vbcrlf & "                              x = null;" & vbcrlf & "                               var myrow = $(""#cpBasezdygroup"");" & vbcrlf & "                         var currgprow = $(""tr.zdyrowgroup1"");" & vbcrlf & "                             currgprow.remove(); "& vbcrlf & "                               if(html.length>0 && html.indexOf(""<tr"")>=0) " & vbcrlf & "                              {" & vbcrlf & "                                               myrow.after(html)" & vbcrlf & "                               }" & vbcrlf & "                               if(window.BillExtSN){" & vbcrlf & "                                   window.BillExtSN.BindKeys = undefined;" & vbcrlf & "                                  jQuery(""input[type=text]"").unbind(""blur"", window.BillExtSN.Refresh).bind(""blur"", window.BillExtSN.Refresh);" & vbcrlf & "                                       jQuery(""input[type=checkbox]"").unbind(""click"", window.BillExtSN.Refresh).bind(""click"", window.BillExtSN.Refresh);" & vbcrlf & "                                     jQuery(""input[type=radio]"").unbind(""click"", window.BillExtSN.Refresh).bind(""click"", window.BillExtSN.Refresh)" & vbcrlf & "                                   jQuery(""select"").unbind(""change"", window.BillExtSN.Refresh).bind(""change"", window.BillExtSN.Refresh);" & vbcrlf & "                                 jQuery(""textarea"").unbind(""blur"", window.BillExtSN.Refresh).bind(""blur"", window.BillExtSN.Refresh);" & vbcrlf &"                                  var data = [];" & vbcrlf & "                                  var CatchFields = [];" & vbcrlf & "                                   var frm = document.getElementsByTagName(""form"")[0];" & vbcrlf & "                                       if (!frm) { return; }" & vbcrlf & "                                   var boxs = jQuery(frm).serializeArray();" & vbcrlf & "                                        for (var i = boxs.length - 1; i >= 0; i--) {" & vbcrlf & "                                           if (i > 0 && boxs[i].name == boxs[i - 1].name) {" & vbcrlf & "                                                        boxs[i - 1].value = boxs[i - 1].value + "","" + boxs[i].value;" & vbcrlf & "                                                      boxs[i].name = """";" & vbcrlf & "                                                } else {" & vbcrlf & "                                                        var n = boxs[i].name;" & vbcrlf & "                                                   var box = document.getElementsByName(n)[0];" & vbcrlf & "                                                        if (box.tagName == ""SELECT"") {" & vbcrlf & "                                                            boxs.push({ name: boxs[i].name + ""_selectvalue"", value: (boxs[i].value + """") });" & vbcrlf & "                                                            boxs[i].value = box.options[box.options.selectedIndex].text;" & vbcrlf & "                                                    }" & vbcrlf & "               }" & vbcrlf & "                                       }" & vbcrlf & "                                       for (var i = 0; i < boxs.length; i++) {" & vbcrlf & "                                         var ibox = boxs[i];" & vbcrlf & "                                             var n = ibox.name;" & vbcrlf & "                                              if (n) {" & vbcrlf & "                                                        CatchFields.push(n);" & vbcrlf & "                                                    if (ibox.value.length < 200) { //200字限制" & vbcrlf & "                                                         data.push(n + ""="" + encodeURIComponent(encodeURIComponent(ibox.value)));" & vbcrlf & "                                                  } else {" & vbcrlf & "                                                                data.push(n + ""="");" & vbcrlf & "                                                       }" & vbcrlf & "                                               }" & vbcrlf & "                                       }" & vbcrlf & "                                       data.push(""__CatchFields="" + encodeURIComponent(CatchFields.join(""|"")));" & vbcrlf & "                                  data.push(""__BillTypeId="" + window.BillExtSN.CodeType);" & vbcrlf & "                                   var xhttp = window.XMLHttpRequest ? (new XMLHttpRequest()):(new ActiveXObject(""Microsoft.XMLHTTP""));" & vbcrlf & "                                      xhttp.open(""POST"", ((window.sysCurrPath ? (window.sysCurrPath + ""../"") : window.SysConfig.VirPath) + ""SYSN/view/comm/GetBHValue.ashx?GB2312=1""), false);" & vbcrlf & "                                      xhttp.setRequestHeader(""content-type"", ""application/x-www-form-urlencoded"");" & vbcrlf & "                                        xhttp.send(data.join(""&""));" & vbcrlf & "                                       var obj = eval(""("" + xhttp.responseText + "")"");" & vbcrlf &                                   "  window.BillExtSN.BindKeys = obj.keys; "& vbcrlf &                                   " //window.BillExtSN.ReBindEvt();" & vbcrlf &                         " }" & vbcrlf &                       " } "& vbcrlf &               " </script> "& vbcrlf & ""
end if
Response.write "" & vbcrlf & "              </div>" & vbcrlf & "  </tr>" & vbcrlf & "   "
call ShowExtendedByKZZDY( TName, ord, columns,  col1,  col2 , false , bzstr , tsstr , oldZdySort , readonly, zdygroupid)
call ShowExtendedByKZZDY( TName, ord, 1,  col1,  columns*2-1 , true , bzstr , tsstr , oldZdySort , readonly, zdygroupid)
end function
function ShowExtendedByKZZDY(byval TName,byval ord,byval columns, byval col1, byval col2 ,byval isIntro ,byval bzstr ,byval tsstr ,byval oldZdySort ,byval readonly,byval zdygroupid)
dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7 , introsql
dim  num1, i_jm, j_jm, c_Value,colstr1,colstr2,rssort,moneyDigits,numDigits,priceDigits
set rssort=conn.execute("select num1 from setjm3 where ord=1")
if not rssort.eof then
moneyDigits=rssort(0)
else
moneyDigits=2
end if
set rssort=conn.execute("select num1 from setjm3 where ord=2019042802")
if not rssort.eof then
priceDigits=rssort(0)
else
priceDigits=2
end if
set rssort=conn.execute("select num1 from setjm3 where ord=88")
if not rssort.eof then
numDigits=rssort(0)
else
numDigits=2
end if
If col1>1 Then colstr1= " colspan='"&col1&"'"
If col2>1 Then colstr2= " colspan='"&col2&"'"
if TName=1001 or ord=-1 Then columns=2
'If col2>1 Then colstr2= " colspan='"&col2&"'"
If ord = "" Then ord=0
if isIntro=false then
introsql = " and uitype<>13  "
else
introsql = " and uitype=13  "
end if
dim id, FName , dname , UiType,MustFillin,TextLen
set rs_kz_zdy=server.CreateObject("adodb.recordset")
sql="select *,case Id when 1 then 7 when 2 then 8 when 3 then 9 when 4 then 10 when 5 then 11 when 6 then 12 else Id end zdyid, 0 as mustshow, ' ' as arename  "
sql = sql + " from sys_sdk_BillFieldInfo where billtype="& TName &" and ListType='0' and isused = 1 "& introsql & " and ProductZdyGroupId=" & clng(zdygroupid)
sql = sql + " order by RootDataType desc, Showindex "
rs_kz_zdy.open sql,conn,1,1
num1=rs_kz_zdy.RecordCount
i_jm=0
j_jm=1
if rs_kz_zdy.eof = False then
Response.write("<tr class='zdyrowgroup" + cstr(abs(zdygroupid*1>0)) + "'>")
'if rs_kz_zdy.eof = False then
do until rs_kz_zdy.eof
if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
Response.write("</tr><tr class='zdyrowgroup" + cstr(abs(zdygroupid*1>0)) + "'>")
'if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
j_jm=j_jm+1
'if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
end if
c_Value=""
id = rs_kz_zdy("zdyid")
FName = rs_kz_zdy("title")
dname = rs_kz_zdy("dbname")
UiType = rs_kz_zdy("UiType")
MustFillin = rs_kz_zdy("MustFillin")
netid = rs_kz_zdy("id")
TextLen = rs_kz_zdy("TextLen")
Response.write "" & vbcrlf & "                     <td width=""11%"" align=""right"" "
Response.write colstr1
Response.write ">"
Response.write FName
Response.write "：</td>" & vbcrlf & "                      <td width=""22%"" "
if i_jm=num1-1  then
Response.write "：</td>" & vbcrlf & "                      <td width=""22%"" "
Response.write "colspan="""
Response.write col2+(col1+col2)*(j_jm*columns-num1)
Response.write "colspan="""
Response.write """ "
else
Response.write colstr2
end if
Response.write ">" & vbcrlf & "                    "
if instr(dname,"ext")>0 then
zid = replace(dname&"","ext","")
Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="& zid &" and OrderID="&ord&" and OrderID>0 ")
If rs_kz_zdy_88.eof = False  Then c_Value=rs_kz_zdy_88("FValue")
rs_kz_zdy_88.close
if readonly then
select case UiType
case 31 :
Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
Response.write replace(c_Value,",","->")
Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
Response.write "</span>"
case 2 :
Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
Response.write getExtendedValue(c_Value,numDigits)
Response.write "</span>"
case 3 :
Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
Response.write getExtendedValue(c_Value,moneyDigits)
Response.write "</span>"
case 3000 :
Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
Response.write getExtendedValue(c_Value,priceDigits)
Response.write "</span>"
Case Else:
Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
Response.write c_Value
Response.write "</span>"
end select
else
c_Value=replace(replace(c_Value&"","""","&#34;"),"'","&#39;")
select case UiType
case 0 :
Response.write "" & vbcrlf & "                                     <input name=""danh_"
Response.write zid
Response.write """ type=""text"" size=""15"" id=""danh_"
Response.write zid
Response.write """ value="""
Response.write c_Value
Response.write """ dataType=""Limit"" "
if MustFillin=1  then
Response.write " min=""1""  msg=""必须在1到"
Response.write TextLen
Response.write "个字符之间""  "
else
Response.write " msg=""长度不能超过"
Response.write TextLen
Response.write "个字"" "
end if
Response.write "  max="
Response.write TextLen
Response.write " maxlength=""4000"">" & vbcrlf & "                                     "
case 1:
Response.write "" & vbcrlf & "                                     <input class=""resetDataPickerBg"" readonly name=""date_"
Response.write zid
Response.write """ value="""
Response.write c_Value
Response.write """ size=""15"" id=""daysOfMonthPos"" onmouseup=""toggleDatePicker('daysOfMonth_"
Response.write zid
Response.write "','date_"
Response.write zid
Response.write "')"" dataType=""Limit"" "
if MustFillin=1 then
Response.write " min=""1"" "
end if
Response.write " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:93px;width:111px;;background-repeat:no-repeat;""> <div id=""daysOfMonth_"
Response.write " min=""1"" "
Response.write zid
Response.write """ style=""POSITION:absolute""></div>" & vbcrlf & "                                  "
case 2:
Response.write "" & vbcrlf & "                                     <input name=""Numr_"
Response.write zid
Response.write """ type=""text"" value="""
Response.write c_Value
Response.write """ size=""15"" id=""Numr_"
Response.write zid
Response.write """ onpropertychange=""formatData(this,'number')"" dataType=""Limit"" "
if MustFillin=1 then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                                  "
case 3:
Response.write "" & vbcrlf & "                                     <input name=""danh_"
Response.write zid
Response.write """ type=""text"" value="""
Response.write c_Value
Response.write """ size=""15"" id=""Numr_"
Response.write zid
Response.write """ onpropertychange=""formatData(this,'money')""  dataType=""Limit"" "
if MustFillin=1 then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                                  "
case 36:
Response.write "" & vbcrlf & "                                     <input name=""danh_"
Response.write zid
Response.write """ type=""text"" value="""
Response.write c_Value
Response.write """ size=""15"" id=""Numr_"
Response.write zid
Response.write """  onpropertychange=""formatData(this,'int')""   dataType=""Limit"" "
if MustFillin=1 then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                                  "
case 3000:
Response.write "" & vbcrlf & "                                     <input name=""danh_"
Response.write zid
Response.write """ type=""text"" value="""
Response.write c_Value
Response.write """ size=""15"" id=""Numr_"
Response.write zid
Response.write """ onpropertychange=""formatData(this,'CommPrice')"" dataType=""Limit"" "
if MustFillin=1 then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                                  "
case 4:
Response.write "" & vbcrlf & "                                     <select name=""IsNot_"
Response.write zid
Response.write """ id=""IsNot_"
Response.write zid
Response.write """  dataType=""Limit"" "
if MustFillin=1 then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                                   <option value=""是"" "
If c_Value="是" then
Response.write "selected"
end if
Response.write ">是</option>" & vbcrlf & "                                 <option value=""否"" "
If c_Value="否" then
Response.write "selected"
end if
Response.write ">否</option>" & vbcrlf & "                                 </select>" & vbcrlf & "                                       "
case 5:
Response.write "" & vbcrlf & "                                     <select name=""meju_"
Response.write zid
Response.write """ id=""meju_"
Response.write zid
Response.write """  dataType=""Limit"" "
if MustFillin=1 then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                                   "
xxsql = "select t1.id, t1.CValue from (select id,CValue from ERP_CustomOptions x  where CFID="& zid &") t1 "
xxsql = xxsql & " inner join  (select [text], ShowIndex  from  sys_sdk_BillFieldOptionsSource where  Stoped=0 and FieldId=" & netid & "  ) t2  " &_
" on t1.CValue = t2.[text]  order by t2.showindex "
set rs7=conn.execute(xxsql)
do until rs7.eof
Response.write "" & vbcrlf & "                                             <option value="""
Response.write rs7("id")
Response.write """ "
If rs7("CValue")&""=c_Value&"" then
Response.write "selected"
end if
Response.write ">"
Response.write rs7("CValue")
Response.write "</option>" & vbcrlf & "                                            "
rs7.movenext
loop
rs7.close
Response.write "" & vbcrlf & "                                 </select>" & vbcrlf & "                                   "
case 54:
cixx = 0
xxsql = "select t1.id, t1.CValue from (select id,CValue from ERP_CustomOptions x  where CFID="& zid &") t1 "
xxsql = xxsql & " inner join  (select [text], ShowIndex  from  sys_sdk_BillFieldOptionsSource where  Stoped=0 and FieldId=" & netid & "  ) t2  " &_
" on t1.CValue = t2.[text]  order by t2.showindex "
set rs7=conn.execute(xxsql)
do until rs7.eof
Response.write "" & vbcrlf & "                                                      <input name=""danh_"
Response.write zid
Response.write """ id=""danh_"
Response.write zid
Response.write "_"
Response.write cixx
Response.write """ "
if  instr("," & c_value   & ",", "," & rs7("CValue").value & ",")>0 then Response.write "checked"
Response.write "  type=""checkbox"" value="""
Response.write replace(rs7("CValue").value & "", """","&#34")
Response.write """ >" & vbcrlf & "                                                       <label for=""danh_"
Response.write zid
Response.write "_"
Response.write cixx
Response.write """>"
Response.write replace(rs7("CValue").value & "", """","&#34")
Response.write "</label>" & vbcrlf & "                                             "
cixx = cixx +1
Response.write "</label>" & vbcrlf & "                                             "
rs7.movenext
loop
rs7.close
case 31:
Response.write "" & vbcrlf & "                                     <select name=""danh_"
Response.write zid
Response.write """ id=""danh_"
Response.write zid
Response.write """  dataType=""Limit"" "
if MustFillin=1 then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                                   "
exitsgp = false
ptxt = ""
xxsql =  "select  [Text] as cvalue, deep  from sys_sdk_BillFieldOptionsSource a "
xxsql = xxsql & " where  Stoped=0 and FieldId=" & netid & " "
xxsql = xxsql & " and ( ParentId=0 or exists(select 1 from  sys_sdk_BillFieldOptionsSource b where a.ParentId=b.id and b.Stoped=0) )"
xxsql = xxsql & " order by ShowIndex "
set rs7=conn.execute(xxsql)
do until rs7.eof
if rs7("deep").value=0 then
if exitsgp then Response.write "</optgroup>"
Response.write " <optgroup label=""" &  rs7("cvalue")  & """>"
ptxt  = rs7("cvalue").value
exitsgp = true
else
myvalue = ptxt & "," & rs7("CValue")
Response.write "" & vbcrlf & "                                             <option value="""
Response.write myvalue
Response.write """ "
If myvalue&""=c_Value&"" then
Response.write "selected"
end if
Response.write ">"
Response.write rs7("CValue")
Response.write "</option>" & vbcrlf & "                                            "
end if
rs7.movenext
loop
rs7.close
if exitsgp then Response.write "</optgroup>"
Response.write "" & vbcrlf & "                                 </select>" & vbcrlf & "                                   "
case 10:
Response.write "" & vbcrlf & "                        <textarea name=""duoh_"
Response.write zid
Response.write """ id=""duoh_"
Response.write zid
Response.write """ style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px;padding-left:4px;"" onfocus=""this.style.height=this.scrollHeight"" onpropertychange=""this.style.height=this.scrollHeight"" dataType=""Limit"" "
Response.write zid
if MustFillin=1 then
Response.write " min=""1""   msg=""必须在1到"
Response.write TextLen
Response.write "个字符之间"" "
else
Response.write " msg=""长度不能超过"
Response.write TextLen
Response.write "个字"" "
end if
Response.write " max="
Response.write TextLen
Response.write ">"
Response.write c_Value
Response.write "</textarea>" & vbcrlf & "                        "
case 13:
Response.write "" & vbcrlf & "                        <textarea name=""beiz_"
Response.write zid
Response.write """ id=""beiz_"
Response.write zid
Response.write """ dataType=""Limit"" "
If MustFillin=1 Then
Response.write "min=""1"""
end if
Response.write "" & vbcrlf & "                            max=""4000""  msg=""备注长度不能超过4000个字"" style=""display:none;"" cols=""1"" rows=""1"">"
if c_Value<>"" then Response.write c_Value End if
Response.write "</textarea>" & vbcrlf & "                                  <IFRAME ID=""eWebEditor_"
Response.write zid
Response.write """ SRC=""../edit/ewebeditor.asp?id=beiz_"
Response.write zid
Response.write "&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""300"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME>" & vbcrlf & "                        "
end select
end if
else
dim tbname : tbname = ""
select case TName
case 16001 : tbname = "product"
end select
if ord<>0 then
c_Value = sdk.getSqlValue("select "& dname &" from "& tbname & " where ord="& ord,"")
if UiType<>0 and len(c_Value)>0 and readonly then
c_Value = sdk.getSqlValue("select sort1 from sortonehy where ord= "& c_Value,"")
end if
end if
if readonly then
Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
Response.write c_Value
Response.write "</span>"
else
if UiType=0 then
c_Value=replace(replace(c_Value&"","""","&#34;"),"'","&#39;")
Response.write "" & vbcrlf & "                        <input name="""
Response.write dname
Response.write """ type=""text"" size=""20"" id="""
Response.write dname
Response.write """ value="""
Response.write c_Value
Response.write """ "
if CheckPurview(tsstr,dname)=True then
Response.write "onChange=""callServer_ts('"
Response.write id
Response.write "','"
Response.write dname
Response.write "');"""
end if
Response.write " dataType=""Limit"" "
if  CheckPurview(bzstr,dname)=True or MustFillin=1  then
Response.write " min=""1"" "
end if
Response.write "  max=""200""  msg=""必须在1到200个字符之间"">" & vbcrlf & "                        "
else
Response.write "" & vbcrlf & "                        <select name="""
Response.write dname
Response.write """ "
if CheckPurview(tsstr,dname)=True then
Response.write "onChange=""callServer_ts('"
Response.write id
Response.write "','"
Response.write dname
Response.write "');"""
end if
Response.write " id="""
Response.write dname
Response.write """   dataType=""Limit"" "
if  CheckPurview(btstr,dname)=True  then
Response.write " min=""1"" "
end if
Response.write "  max=""50""  msg=""长度不能超过50个字"">" & vbcrlf & "                        "
dim gl : gl = sdk.getSqlValue("select gl from zdy where sort1= "& oldZdySort & " and name='"& dname &"' ",0)
set rs7=server.CreateObject("adodb.recordset")
sql7="select ord,sort1 from sortonehy where gate2="& gl &" order by gate1 desc "
rs7.open sql7,conn,1,1
do until rs7.eof
Response.write "" & vbcrlf & "                            <option value="""
Response.write rs7("ord")
Response.write """ "
if rs7("ord").value &""=c_Value&"" then
Response.write "selected"
end if
Response.write " >"
Response.write rs7("sort1")
Response.write "</option>" & vbcrlf & "                            "
rs7.movenext
loop
rs7.close
set rs7=nothing
Response.write "" & vbcrlf & "                        </select>" & vbcrlf & "                        "
end if
end if
end if
Response.write " <span id=""test"
Response.write id
Response.write """ class=""red"">"
if  (MustFillin=1 or CheckPurview(bzstr,dname)=true) and readonly=false Then
Response.write "*"
end if
Response.write "</span>" & vbcrlf & "                      </td>" & vbcrlf & "                   "
i_jm=i_jm+1
Response.write "</span>" & vbcrlf & "                      </td>" & vbcrlf & "                   "
rs_kz_zdy.movenext
loop
Response.write("</tr>")
end if
rs_kz_zdy.close
set rs_kz_zdy=nothing
end function
Function showExtended(TName,ord,columns,col1,col2)
dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7
dim  num1, i_jm, j_jm, c_Value,colstr1,colstr2
If col1>1 Then colstr1= " colspan='"&col1&"'"
If col2>1 Then colstr2= " colspan='"&col2&"'"
if TName=1001 or ord=-1 Then columns=2
'If col2>1 Then colstr2= " colspan='"&col2&"'"
If ord = "" Then ord=0
set rs_kz_zdy=server.CreateObject("adodb.recordset")
sql="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 and FType<>'5' order by FOrder asc "
rs_kz_zdy.open sql,conn,1,1
num1=rs_kz_zdy.RecordCount
i_jm=0
j_jm=1
if rs_kz_zdy.eof = False then
Response.write("<tr>")
do until rs_kz_zdy.eof
if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
Response.write("</tr><tr>")
j_jm=j_jm+1
Response.write("</tr><tr>")
end if
c_Value=""
Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy("id")&" and OrderID="&ord&" and OrderID>0 ")
If rs_kz_zdy_88.eof = False  Then c_Value=rs_kz_zdy_88("FValue")
rs_kz_zdy_88.close
Response.write "" & vbcrlf & "                      <td width=""11%"" align=""right"" "
Response.write colstr1
Response.write ">"
Response.write rs_kz_zdy("FName")
Response.write "：</td>" & vbcrlf & "                       <td width=""22%"" "
if i_jm=num1-1  then
Response.write "：</td>" & vbcrlf & "                       <td width=""22%"" "
Response.write "colspan="""
Response.write col2+(col1+col2)*(j_jm*columns-num1)
Response.write "colspan="""
Response.write """ "
else
Response.write colstr2
end if
Response.write ">" & vbcrlf & "                     "
if rs_kz_zdy("FType")="1" Then
Response.write "" & vbcrlf & "                              <input name=""danh_"
Response.write rs_kz_zdy("id")
Response.write """ type=""text"" size=""15"" id=""danh_"
Response.write rs_kz_zdy("id")
Response.write """ value="""
Response.write c_Value
Response.write """ dataType=""Limit"" "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1""  msg=""必须在1到200个字符之间""  "
else
Response.write " msg=""长度不能超过200个字"" "
end if
Response.write "  max=""200"" maxlength=""4000"">" & vbcrlf & "                             "
Elseif rs_kz_zdy("FType")="2" then
Response.write "" & vbcrlf & "                              <textarea name=""duoh_"
Response.write rs_kz_zdy("id")
Response.write """ id=""duoh_"
Response.write rs_kz_zdy("id")
Response.write """ style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px;padding-left:4px;"" onfocus=""this.style.height=this.scrollHeight"" onpropertychange=""this.style.height=this.scrollHeight"" dataType=""Limit"" "
Response.write rs_kz_zdy("id")
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1""   msg=""必须在1到500个字符之间"" "
else
Response.write " msg=""长度不能超过500个字"" "
end if
Response.write " max=""500"">"
Response.write c_Value
Response.write "</textarea>" & vbcrlf & "                           "
elseif rs_kz_zdy("FType")="3" Then
Response.write "" & vbcrlf & "                              <input class=""resetDataPickerBg"" readonly name=""date_"
Response.write rs_kz_zdy("id")
Response.write """ value="""
Response.write c_Value
Response.write """ size=""15"" id=""daysOfMonthPos"" onmouseup=""toggleDatePicker('daysOfMonth_"
Response.write rs_kz_zdy("id")
Response.write "','date_"
Response.write rs_kz_zdy("id")
Response.write "')"" dataType=""Limit"" "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:93px;width:111px;;background-repeat:no-repeat;""> <div id=""daysOfMonth_"
Response.write " min=""1"" "
Response.write rs_kz_zdy("id")
Response.write """ style=""POSITION:absolute""></div>" & vbcrlf & "                           "
ElseIf rs_kz_zdy("FType")="4" then
Response.write "" & vbcrlf & "                              <input name=""Numr_"
Response.write rs_kz_zdy("id")
Response.write """ type=""text"" value="""
Response.write c_Value
Response.write """ size=""15"" id=""Numr_"
Response.write rs_kz_zdy("id")
Response.write """ onkeyup=value=value.replace(/[^\d\.]/g,'') dataType=""Limit"" "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                           "
ElseIf rs_kz_zdy("FType")="6" then
Response.write "" & vbcrlf & "                              <select name=""IsNot_"
Response.write rs_kz_zdy("id")
Response.write """ id=""IsNot_"
Response.write rs_kz_zdy("id")
Response.write """  dataType=""Limit"" "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                            <option value=""是"" "
If c_Value="是" then
Response.write "selected"
end if
Response.write ">是</option>" & vbcrlf & "                          <option value=""否"" "
If c_Value="否" then
Response.write "selected"
end if
Response.write ">否</option>" & vbcrlf & "                          </select>" & vbcrlf & "                               "
else
Response.write "" & vbcrlf & "                              <select name=""meju_"
Response.write rs_kz_zdy("id")
Response.write """ id=""meju_"
Response.write rs_kz_zdy("id")
Response.write """  dataType=""Limit"" "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                           "
set rs7=conn.execute("select id,CValue from ERP_CustomOptions where CFID="&rs_kz_zdy("id")&" order by id asc ")
do until rs7.eof
Response.write "" & vbcrlf & "                                     <option value="""
Response.write rs7("id")
Response.write """ "
If rs7("CValue")&""=c_Value&"" then
Response.write "selected"
end if
Response.write ">"
Response.write rs7("CValue")
Response.write "</option>" & vbcrlf & "                                    "
rs7.movenext
loop
rs7.close
Response.write "" & vbcrlf & "                        </select>" & vbcrlf & "                            "
end if
if  rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then
Response.write " <span class=""red"">*</span>"
end if
Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
i_jm=i_jm+1
Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
rs_kz_zdy.movenext
loop
Response.write("</tr>")
end if
rs_kz_zdy.close
set rs_kz_zdy=nothing
end function
Function showExtended2(TName,ord,columns,col1,col2)
dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7
dim  num1, i_jm, j_jm, c_Value,colstr1,colstr2
If col1>1 Then colstr1= " colspan='"&col1&"'"
If col2>1 Then colstr2= " colspan='"&col2&"'"
if TName=1001 or ord=-1 Then columns=2
'If col2>1 Then colstr2= " colspan='"&col2&"'"
set rs_kz_zdy=server.CreateObject("adodb.recordset")
sql="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 and FType<>'5' order by FOrder asc "
rs_kz_zdy.open sql,conn,1,1
num1=rs_kz_zdy.RecordCount
i_jm=0
j_jm=1
if rs_kz_zdy.eof = False then
Response.write("<tr>")
do until rs_kz_zdy.eof
if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
Response.write("</tr><tr>")
j_jm=j_jm+1
Response.write("</tr><tr>")
end if
c_Value=""
Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy("id")&" and OrderID="&ord&" and OrderID>0 ")
If rs_kz_zdy_88.eof = False  Then c_Value=rs_kz_zdy_88("FValue")
rs_kz_zdy_88.close
Response.write "" & vbcrlf & "                     <td align=""right"" "
Response.write colstr1
Response.write ">"
Response.write rs_kz_zdy("FName")
Response.write "：</td>" & vbcrlf & "                      <td "
if i_jm=num1-1  then
Response.write "：</td>" & vbcrlf & "                      <td "
Response.write "colspan="""
Response.write col2+(col1+col2)*(j_jm*columns-num1)
Response.write "colspan="""
Response.write """ "
else
Response.write colstr2
end if
Response.write ">" & vbcrlf & "                    "
if rs_kz_zdy("FType")="1" Then
Response.write "" & vbcrlf & "                             <input name=""danh_"
Response.write rs_kz_zdy("id")
Response.write """ type=""text"" size=""15"" id=""danh_"
Response.write rs_kz_zdy("id")
Response.write """ value="""
Response.write c_Value
Response.write """ dataType=""Limit"" "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"" maxlength=""4000"">" & vbcrlf & "                            "
Elseif rs_kz_zdy("FType")="2" then
Response.write "" & vbcrlf & "                             <textarea name=""duoh_"
Response.write rs_kz_zdy("id")
Response.write """ id=""duoh_"
Response.write rs_kz_zdy("id")
Response.write """ style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px"" onfocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" dataType=""Limit"" "
Response.write rs_kz_zdy("id")
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write " max=""500""  msg=""必须在1到500个字符"">"
Response.write c_Value
Response.write "</textarea>" & vbcrlf & "                          "
elseif rs_kz_zdy("FType")="3" Then
Response.write "" & vbcrlf & "                             <input readonly name=""date_"
Response.write rs_kz_zdy("id")
Response.write """ value="""
Response.write c_Value
Response.write """ size=""15"" id=""daysOfMonthPos"" onmouseup=""toggleDatePicker('daysOfMonth_"
Response.write rs_kz_zdy("id")
Response.write "','date_"
Response.write rs_kz_zdy("id")
Response.write "')"" dataType=""Limit"" "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:right;background-repeat:no-repeat;""> <div id=""daysOfMonth_"
Response.write " min=""1"" "
Response.write rs_kz_zdy("id")
Response.write """ style=""POSITION:absolute""></div>" & vbcrlf & "                          "
ElseIf rs_kz_zdy("FType")="4" then
Response.write "" & vbcrlf & "                             <input name=""Numr_"
Response.write rs_kz_zdy("id")
Response.write """ type=""text"" value="""
Response.write c_Value
Response.write """ size=""15"" id=""Numr_"
Response.write rs_kz_zdy("id")
Response.write """ onkeyup=value=value.replace(/[^\d\.]/g,'') dataType=""Limit"" "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                          "
ElseIf rs_kz_zdy("FType")="6" then
Response.write "" & vbcrlf & "                             <select name=""IsNot_"
Response.write rs_kz_zdy("id")
Response.write """ id=""IsNot_"
Response.write rs_kz_zdy("id")
Response.write """  dataType=""Limit"" "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                           <option value=""是"" "
If c_Value="是" then
Response.write "selected"
end if
Response.write ">是</option>" & vbcrlf & "                         <option value=""否"" "
If c_Value="否" then
Response.write "selected"
end if
Response.write ">否</option>" & vbcrlf & "                         </select>" & vbcrlf & "                               "
else
Response.write "" & vbcrlf & "                             <select name=""meju_"
Response.write rs_kz_zdy("id")
Response.write """ id=""meju_"
Response.write rs_kz_zdy("id")
Response.write """  dataType=""Limit"" "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                           "
set rs7=conn.execute("select id,CValue from ERP_CustomOptions where CFID="&rs_kz_zdy("id")&" order by id asc ")
do until rs7.eof
Response.write "" & vbcrlf & "                                     <option value="""
Response.write rs7("id")
Response.write """ "
If rs7("CValue")&""=c_Value&"" then
Response.write "selected"
end if
Response.write ">"
Response.write rs7("CValue")
Response.write "</option>" & vbcrlf & "                                    "
rs7.movenext
loop
rs7.close
Response.write "" & vbcrlf & "                        </select>" & vbcrlf & "                            "
end if
if  rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then
Response.write " <span class=""red"">*</span>"
end if
Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
i_jm=i_jm+1
Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
rs_kz_zdy.movenext
loop
Response.write("</tr>")
end if
rs_kz_zdy.close
set rs_kz_zdy=nothing
end function
Function getExtendedDeal(TName,ord,repID)
Call showExtendedDeal(TName,ord,3,1,1,repID)
end function
Function showExtendedDeal(TName,ord,columns,col1,col2,repID)
dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7
dim  num1, i_jm, j_jm, c_Value,colstr1,colstr2
If col1>1 Then colstr1= " colspan='"&col1&"'"
If col2>1 Then colstr2= " colspan='"&col2&"'"
columns = 2
set rs_kz_zdy=server.CreateObject("adodb.recordset")
sql="select * from Copy_CustomFields where TName="&TName&" AND RepairOrder = "&repID&" "& KZ_LIMITID &" and FType<>5 and IsUsing=1 and del=1 order by FOrder asc "
rs_kz_zdy.open sql,conn,1,1
num1=rs_kz_zdy.RecordCount
i_jm=0
j_jm=1
if rs_kz_zdy.eof = False then
Response.write("<tr>")
do until rs_kz_zdy.eof
if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
Response.write("</tr><tr>")
j_jm=j_jm+1
Response.write("</tr><tr>")
end if
c_Value=""
Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy("id")&" and OrderID="&ord&" ")
If rs_kz_zdy_88.eof = False  Then c_Value=rs_kz_zdy_88("FValue")
rs_kz_zdy_88.close
Response.write "" & vbcrlf & "                     <td width=""11%"" align=""right"" "
Response.write colstr1
Response.write ">"
Response.write rs_kz_zdy("FName")
Response.write "：</td>" & vbcrlf & "                      <td width=""22%"" "
if i_jm=num1-1  then
Response.write "：</td>" & vbcrlf & "                      <td width=""22%"" "
Response.write "colspan="""
Response.write col2+(col1+col2)*(j_jm*columns-num1)
Response.write "colspan="""
Response.write """ "
else
Response.write colstr2
end if
Response.write ">" & vbcrlf & "                    "
if rs_kz_zdy("FType")="1" Then
Response.write "" & vbcrlf & "                             <input name=""danh_"
Response.write rs_kz_zdy("id")
Response.write """ type=""text"" size=""15"" id=""danh_"
Response.write rs_kz_zdy("id")
Response.write """ value="""
Response.write c_Value
Response.write """ dataType=""Limit"" "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"" maxlength=""4000"">" & vbcrlf & "                            "
Elseif rs_kz_zdy("FType")="2" then
Response.write "" & vbcrlf & "                             <textarea name=""duoh_"
Response.write rs_kz_zdy("id")
Response.write """ id=""duoh_"
Response.write rs_kz_zdy("id")
Response.write """ style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px;padding-left:4px;"" onfocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" dataType=""Limit"" "
Response.write rs_kz_zdy("id")
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write " max=""500""  msg=""必须在1到500个字符"">"
Response.write c_Value
Response.write "</textarea>" & vbcrlf & "                          "
Elseif rs_kz_zdy("FType")="5" then
Response.write "" & vbcrlf & "                             <textarea name=""beiz_"
Response.write rs_kz_zdy("id")
Response.write """ id=""beiz_"
Response.write rs_kz_zdy("id")
Response.write """ style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px;padding-left:4px;"" onfocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" dataType=""Limit"" "
Response.write rs_kz_zdy("id")
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write " max=""4000""  msg=""必须在1到4000个字符"">"
Response.write c_Value
Response.write "</textarea>" & vbcrlf & "                          "
elseif rs_kz_zdy("FType")="3" Then
Response.write "" & vbcrlf & "                             <input readonly name=""date_"
Response.write rs_kz_zdy("id")
Response.write """ value="""
Response.write c_Value
Response.write """ size=""15"" id=""daysOfMonthPos"" onmouseup=""toggleDatePicker('daysOfMonth_"
Response.write rs_kz_zdy("id")
Response.write "','date_"
Response.write rs_kz_zdy("id")
Response.write "')"" dataType=""Limit"" "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:right;background-repeat:no-repeat;""> <div id=""daysOfMonth_"
Response.write " min=""1"" "
Response.write rs_kz_zdy("id")
Response.write """ style=""POSITION:absolute""></div>" & vbcrlf & "                          "
ElseIf rs_kz_zdy("FType")="4" then
Response.write "" & vbcrlf & "                             <input name=""Numr_"
Response.write rs_kz_zdy("id")
Response.write """ type=""text"" value="""
Response.write c_Value
Response.write """ size=""15"" id=""Numr_"
Response.write rs_kz_zdy("id")
Response.write """ onkeyup=value=value.replace(/[^\d\.]/g,'') dataType=""Limit"" "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                  "
ElseIf rs_kz_zdy("FType")="6" then
Response.write "" & vbcrlf & "                             <select name=""IsNot_"
Response.write rs_kz_zdy("id")
Response.write """ id=""IsNot_"
Response.write rs_kz_zdy("id")
Response.write """  dataType=""Limit"" "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                           <option value=""是"" "
If c_Value="是" then
Response.write "selected"
end if
Response.write ">是</option>" & vbcrlf & "                         <option value=""否"" "
If c_Value="否" then
Response.write "selected"
end if
Response.write ">否</option>" & vbcrlf & "                         </select>" & vbcrlf & "                               "
else
Response.write "" & vbcrlf & "                             <select name=""meju_"
Response.write rs_kz_zdy("id")
Response.write """ id=""meju_"
Response.write rs_kz_zdy("id")
Response.write """  dataType=""Limit"" "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
Response.write " min=""1"" "
end if
Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                           "
set rs7=conn.execute("select id,CValue from ERP_CustomOptions where CFID="&rs_kz_zdy("id")&" order by id asc ")
do until rs7.eof
Response.write "" & vbcrlf & "                                     <option value="""
Response.write rs7("id")
Response.write """ "
If rs7("CValue")&""=c_Value&"" then
Response.write "selected"
end if
Response.write ">"
Response.write rs7("CValue")
Response.write "</option>" & vbcrlf & "                                    "
rs7.movenext
loop
rs7.close
Response.write "" & vbcrlf & "                        </select>" & vbcrlf & "                            "
end if
if  rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then
Response.write " <span class=""red"">*</span>"
end if
Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
i_jm=i_jm+1
Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
rs_kz_zdy.movenext
loop
Response.write("</tr>")
end if
rs_kz_zdy.close
set rs_kz_zdy=nothing
end function
Function showExtendedBzDeal(TName,ord, repID,col1,col2)
Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
if TName=1001 or ord=-1 Then col2=3
'Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
If col1>1 Then colstr1= " colspan='"&col1&"'"
If col2>1 Then colstr2= " colspan='"&col2&"'"
Set rs_kz_zdy_8=server.CreateObject("adodb.recordset")
rs_kz_zdy_8.open "select * from Copy_CustomFields where IsUsing=1 and TName="&TName&" AND RepairOrder = "&repID&" "& KZ_LIMITID &" and FType='5' order by FOrder asc",conn,1,1
If Not rs_kz_zdy_8.eof Then
Do While Not rs_kz_zdy_8.eof
If Len(rs_kz_zdy_8("FName")&"") > 0 then
c_Value=""
Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy_8("id")&" and OrderID="&ord&" ")
If Not rs_kz_zdy_88.eof Then c_Value=rs_kz_zdy_88("FValue")
rs_kz_zdy_88.close
Response.write "" & vbcrlf & "                         <tr>" & vbcrlf & "                                    <td "
Response.write colstr1
Response.write "><div align=""right"">"
If (rs_kz_zdy_8("MustFillin") Or Len(KZ_LIMITID&"")>0 ) And (rs_kz_zdy_8("FType")=1 Or rs_kz_zdy_8("FType")=2 Or rs_kz_zdy_8("FType")=4) then
Response.write " &nbsp;<span class=""red"">*&nbsp;</span>"
end if
Response.write rs_kz_zdy_8("FName")
Response.write "：</div></td>" & vbcrlf & "                                    <td "
Response.write colstr2
Response.write "><textarea name=""beiz_"
Response.write rs_kz_zdy_8("id")
Response.write """ id=""beiz_"
Response.write rs_kz_zdy_8("id")
Response.write """ dataType=""Limit""  " & vbcrlf & "                    "
If Len(KZ_LIMITID&"")>0 Then
Response.write "min=""1"""
end if
Response.write "" & vbcrlf & "                    max=""4000""  msg=""备注长度不能超过4000个字"" style=""display:none;"" cols=""1"" rows=""1"">"
if c_Value<>"" then Response.write c_Value End if
Response.write "</textarea>" & vbcrlf & "                              <IFRAME ID=""eWebEditor_"
Response.write rs_kz_zdy_8("id")
Response.write """ SRC=""../edit/ewebeditor.asp?id=beiz_"
Response.write rs_kz_zdy_8("id")
Response.write "&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""300"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME></td>" & vbcrlf & "                         </tr>" & vbcrlf & "                       "
end if
rs_kz_zdy_8.movenext
loop
end if
rs_kz_zdy_8.close
Set rs_kz_zdy_8=Nothing
end function
Function getExtended2(TName,ord,ly_str)
columns=3
if TName=1001 or ord=-1 Then columns=2
'columns=3
set rs_kz_zdy=server.CreateObject("adodb.recordset")
sql="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 and FType<>'5' order by FOrder asc "
rs_kz_zdy.open sql,conn,1,1
num1=rs_kz_zdy.RecordCount
i_jm=0
j_jm=1
if Not rs_kz_zdy.eof then
Response.write("<tr>")
do until rs_kz_zdy.eof
if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
Response.write("</tr><tr>")
j_jm=j_jm+1
end if
c_Value=""
Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy("id")&" and OrderID="&ord&" ")
If Not rs_kz_zdy_88.eof Then c_Value=rs_kz_zdy_88("FValue")
rs_kz_zdy_88.close
Response.write "<td width='11%' align='right'>"&rs_kz_zdy("FName")&"：</td><td width='22%' "
if i_jm=num1-1  Then Response.write "colspan="&(1+2*(j_jm*columns-num1))&" "
Response.write "<td width='11%' align='right'>"&rs_kz_zdy("FName")&"：</td><td width='22%' "
Response.write ">"
if rs_kz_zdy("FType")="1" Then
Response.write "<input name='danh_"&rs_kz_zdy("id")&"' type='text' size='15' id='danh_"&rs_kz_zdy("id")&"' value='"&c_Value&"' dataType='Limit' "
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
Response.write " max='500'  msg='必须在1到500个字符' maxlength='4000'>"
Elseif rs_kz_zdy("FType")="2" Then
Response.write "<textarea name='duoh_"&rs_kz_zdy("id")&"' id='duoh_"&rs_kz_zdy("id")&"' style='overflow-y:hidden;word-break:break-all;width:160px;height:22px;padding-left:4px;' onfocus='this.style.posHeight=this.scrollHeight' onpropertychange='this.style.posHeight=this.scrollHeight' dataType='Limit' "
'Elseif rs_kz_zdy("FType")="2" Then
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
Response.write " max='500'  msg='必须在1到500个字符'>"&c_Value&"</textarea>"
elseif rs_kz_zdy("FType")="3" Then
Response.write "<input readonly name='date_"&rs_kz_zdy("id")&"' value='"&c_Value&"' size='15' id='daysOfMonthPos' onmouseup=""toggleDatePicker('daysOfMonth_"&rs_kz_zdy("id")&"','date_"&rs_kz_zdy("id")&"')"" dataType='Limit' "
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
Response.write " max='500' msg='请选择日期' style='background-image:url(../images/datePicker.gif);background-position:right;background-repeat:no-repeat;'> <div id='daysOfMonth_"&rs_kz_zdy("id")&"' style='POSITION:absolute'></div>"
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
ElseIf rs_kz_zdy("FType")="4" then
Response.write "<input name='Numr_"&rs_kz_zdy("id")&"' type='text' value='"&c_Value&"' size='15' id='Numr_"&rs_kz_zdy("id")&"' onkeyup=value=value.replace(/[^\d\.]/g,'') dataType='Limit' "
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1'  "
Response.write " max='500'  msg='必须在1到500个字符' >"
ElseIf rs_kz_zdy("FType")="6" then
Response.write "<select name='IsNot_"&rs_kz_zdy("id")&"' id='IsNot_"&rs_kz_zdy("id")&"'  dataType='Limit' "
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
Response.write " max='500'  msg='必须在1到500个字符'>"
Response.write "<option value='是' "
If c_Value="是" Then Response.write " selected "
Response.write ">是</option>"
Response.write "<option value='否' "
If c_Value="否" Then Response.write " selected "
Response.write ">否</option>"
Response.write "</select>"
else
Response.write "<select name='meju_"&rs_kz_zdy("id")&"' id='meju_"&rs_kz_zdy("id")&"'  dataType='Limit' "
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
Response.write " max='500'  msg='必须在1到500个字符'>"
Response.write "<option value=''></option>"
ly_sql=""
If c_Value<>"" And ly_str&""<>"" Then ly_str=ly_str&","&c_Value
If ly_str&""<>"" Then ly_sql=" and id in ("&ly_str&")"
set rs7=conn.execute("select id,CValue from ERP_CustomOptions where CFID="&rs_kz_zdy("id")&" "&ly_sql&" order by id asc ")
do until rs7.eof
Response.write "<option value='"&rs7("id")&"' "
If rs7("CValue")&""=c_Value&"" Then Response.write " selected "
Response.write ">"&rs7("CValue")&"</option>"
rs7.movenext
loop
rs7.close
Response.write "</select>"
end if
if  (rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0) And (rs_kz_zdy("FType")=1 Or rs_kz_zdy("FType")=2 Or rs_kz_zdy("FType")=4)  Then Response.write " &nbsp;<span class='red'>*</span>"
Response.write "</td>"
i_jm=i_jm+1
Response.write "</td>"
rs_kz_zdy.movenext
loop
Response.write("</tr>")
end if
rs_kz_zdy.close
set rs_kz_zdy=nothing
end function
Function getExtended1(TName,ord)
Call showExtended1(TName,ord,1,1,5)
end function
Function showExtended1(TName,ord,columns ,col1,col2)
Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
if TName=1001 or ord=-1 Then col2=3
'Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
If col1>1 Then colstr1= " colspan='"&col1&"'"
If col2>1 Then colstr2= " colspan='"&col2&"'"
Set rs_kz_zdy_8=server.CreateObject("adodb.recordset")
rs_kz_zdy_8.open "select * from ERP_CustomFields where IsUsing=1 and TName="&TName&" "& KZ_LIMITID &" and FType='5' order by FOrder asc",conn,1,1
If Not rs_kz_zdy_8.eof Then
Do While Not rs_kz_zdy_8.eof
c_Value=""
Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy_8("id")&" and OrderID="&ord&" ")
If Not rs_kz_zdy_88.eof Then c_Value=rs_kz_zdy_88("FValue")
rs_kz_zdy_88.close
Response.write "" & vbcrlf & "                      <tr>" & vbcrlf & "                            <td width=""11%"" "
Response.write colstr1
Response.write "><div align=""right"">"
If (rs_kz_zdy_8("MustFillin") Or Len(KZ_LIMITID&"")>0 ) And (rs_kz_zdy_8("FType")=1 Or rs_kz_zdy_8("FType")=2 Or rs_kz_zdy_8("FType")=4) then
Response.write " &nbsp;<span class=""red"">*&nbsp;</span>"
end if
Response.write rs_kz_zdy_8("FName")
Response.write "：</div></td>" & vbcrlf & "                         <td "
Response.write colstr2
Response.write "><textarea name=""beiz_"
Response.write rs_kz_zdy_8("id")
Response.write """ id=""beiz_"
Response.write rs_kz_zdy_8("id")
Response.write """ dataType=""Limit""  " & vbcrlf & "                "
If Len(KZ_LIMITID&"")>0 Then
Response.write "min=""1"""
end if
Response.write "" & vbcrlf & "                max=""4000""  msg=""备注长度不能超过4000个字"" style=""display:none;"" cols=""1"" rows=""1"">"
if c_Value<>"" then Response.write c_Value End if
Response.write "</textarea>" & vbcrlf & "                           <IFRAME ID=""eWebEditor_"
Response.write rs_kz_zdy_8("id")
Response.write """ SRC=""../edit/ewebeditor.asp?id=beiz_"
Response.write rs_kz_zdy_8("id")
Response.write "&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""300"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME></td>" & vbcrlf & "                     </tr>" & vbcrlf & "                   "
rs_kz_zdy_8.movenext
loop
end if
rs_kz_zdy_8.close
Set rs_kz_zdy_8=Nothing
end function
Function showExtended3(TName,ord,columns ,col1,col2)
Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
if TName=1001 or ord=-1 Then col2=3
'Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
If col1>1 Then colstr1= " colspan='"&col1&"'"
If col2>1 Then colstr2= " colspan='"&col2&"'"
Set rs_kz_zdy_8=server.CreateObject("adodb.recordset")
rs_kz_zdy_8.open "select * from ERP_CustomFields where IsUsing=1 and TName="&TName&" "& KZ_LIMITID &" and FType='5' order by FOrder asc",conn,1,1
If Not rs_kz_zdy_8.eof Then
Do While Not rs_kz_zdy_8.eof
c_Value=""
Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy_8("id")&" and OrderID="&ord&" ")
If Not rs_kz_zdy_88.eof Then c_Value=rs_kz_zdy_88("FValue")
rs_kz_zdy_88.close
Response.write "" & vbcrlf & "                     <tr>" & vbcrlf & "                            <td "
Response.write colstr1
Response.write "><div align=""right"">"
If (rs_kz_zdy_8("MustFillin") Or Len(KZ_LIMITID&"")>0 ) And (rs_kz_zdy_8("FType")=1 Or rs_kz_zdy_8("FType")=2 Or rs_kz_zdy_8("FType")=4) then
Response.write " &nbsp;<span class=""red"">*&nbsp;</span>"
end if
Response.write rs_kz_zdy_8("FName")
Response.write "：</div></td>" & vbcrlf & "                                <td "
Response.write colstr2
Response.write "><textarea name=""beiz_"
Response.write rs_kz_zdy_8("id")
Response.write """ id=""beiz_"
Response.write rs_kz_zdy_8("id")
Response.write """ dataType=""Limit""  " & vbcrlf & "                "
If Len(KZ_LIMITID&"")>0 Then
Response.write "min=""1"""
end if
Response.write "" & vbcrlf & "                max=""4000""  msg=""备注长度不能超过4000个字"" style=""display:none;"" cols=""1"" rows=""1"">"
if c_Value<>"" then Response.write c_Value End if
Response.write "</textarea>" & vbcrlf & "                          <IFRAME ID=""eWebEditor_"
Response.write rs_kz_zdy_8("id")
Response.write """ SRC=""../edit/ewebeditor.asp?id=beiz_"
Response.write rs_kz_zdy_8("id")
Response.write "&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""300"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME></td>" & vbcrlf & "                     </tr>" & vbcrlf & "                   "
rs_kz_zdy_8.movenext
loop
end if
rs_kz_zdy_8.close
Set rs_kz_zdy_8=Nothing
end function
Function saveExtended(TName,ord)
Dim rs_kz_zdy, FValue, OID, sql, id, rs0, rs1
set rs_kz_zdy=server.CreateObject("adodb.recordset")
sql="select *,(select uitype from sys_sdk_BillFieldInfo m where m.billtype=16001 and m.dbname='ext' +cast(t.id as varchar(12)) ) as utype from ERP_CustomFields t where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 order by FOrder asc "
'set rs_kz_zdy=server.CreateObject("adodb.recordset")
rs_kz_zdy.open sql,conn,1,1
If not rs_kz_zdy.eof Then
Do While Not rs_kz_zdy.eof
id=rs_kz_zdy("id")
if rs_kz_zdy("FType")="1" Then
if rs_kz_zdy("utype")="54" then
FValue=replace(Trim(request.Form("danh_"&id)),", ",",")
else
FValue=Trim(request.Form("danh_"&id))
end if
ElseIf rs_kz_zdy("FType")="2" then
FValue=Trim(request.Form("duoh_"&id))
ElseIf rs_kz_zdy("FType")="3" then
FValue=Trim(request.Form("date_"&id))
ElseIf rs_kz_zdy("FType")="4"  then
FValue=Trim(request.Form("Numr_"&id))
ElseIf rs_kz_zdy("FType")="5" then
FValue=Trim(request.Form("beiz_"&id))
ElseIf rs_kz_zdy("FType")="6" then
FValue=Trim(request.Form("IsNot_"&id))
else
OID=Trim(request.Form("meju_"&id))
If OID="" Then OID=0
Set rs1=server.CreateObject("adodb.recordset")
rs1.open "select CValue from ERP_CustomOptions where id="&OID,conn,1,1
If rs1.eof Then
FValue=""
else
FValue=rs1("CValue")
end if
rs1.close
Set rs1=nothing
end if
Set rs0=server.CreateObject("adodb.recordset")
rs0.open "select top 1 * from ERP_CustomValues where FieldsID="&id&" and OrderID="&ord&" ",conn,1,1
If rs0.eof Then
If FValue<>"" And not IsNull(FValue) Then
conn.execute "insert into ERP_CustomValues(FieldsID,OrderID,FValue) values("&id&","&ord&",N'"&FValue&"')"
end if
else
conn.execute "update ERP_CustomValues set FValue=N'"&FValue&"' where FieldsID="&id&" and OrderID="&ord&" "
end if
rs0.close
Set rs0=nothing
rs_kz_zdy.movenext
loop
end if
rs_kz_zdy.close
Set rs_kz_zdy=Nothing
end function
Function searchExtended(TName,col)
Dim sqldate
Dim rs_kz_zdy_2 : set rs_kz_zdy_2=server.CreateObject("adodb.recordset")
Dim sql2 : sql2="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 and CanSearch=1 order by FOrder asc "
Dim str33,id,danh_1,danh_2,Numr_1,Numr_2,beiz_1,beiz_2,IsNot_1,meju_1,duoh_1,duoh_2,date_1,date_2
rs_kz_zdy_2.open sql2,conn,1,1
if rs_kz_zdy_2.eof then
else
str33=""
do until rs_kz_zdy_2.eof
id=rs_kz_zdy_2("id")
If rs_kz_zdy_2("FType")="1" Then
danh_1=request("danh_"&id&"_1")
danh_2=request("danh_"&id&"_2")
str33=str33+"&danh_"&id&"_1="+danh_1
'danh_2=request("danh_"&id&"_2")
str33=str33+"&danh_"&id&"_2="+danh_2
'danh_2=request("danh_"&id&"_2")
If danh_2<>"" Then
If danh_1=1 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& danh_2 &"%')"
'If danh_1=1 Then
Elseif danh_1=2 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue not like '%"& danh_2 &"%')"
'Elseif danh_1=2 Then
Elseif danh_1=3 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& danh_2 &"')"
'Elseif danh_1=3 Then
Elseif danh_1=4 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue<>'"& danh_2 &"')"
'Elseif danh_1=4 Then
Elseif danh_1=5 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '"& danh_2 &"%')"
'Elseif danh_1=5 Then
Elseif danh_1=6 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& danh_2 &"')"
'Elseif danh_1=6 Then
end if
end if
ElseIf rs_kz_zdy_2("FType")="2" Then
duoh_1=request("duoh_"&id&"_1")
duoh_2=request("duoh_"&id&"_2")
str33=str33+"&duoh_"&id&"_1="+duoh_1
'duoh_2=request("duoh_"&id&"_2")
str33=str33+"&duoh_"&id&"_2="+duoh_2
'duoh_2=request("duoh_"&id&"_2")
If duoh_2<>"" Then
If duoh_1=1 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& duoh_2 &"%')"
'If duoh_1=1 Then
Elseif duoh_1=2 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue not like '%"& duoh_2 &"%')"
'Elseif duoh_1=2 Then
Elseif duoh_1=3 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& duoh_2 &"')"
'Elseif duoh_1=3 Then
Elseif duoh_1=4 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue<>'"& duoh_2 &"')"
'Elseif duoh_1=4 Then
Elseif duoh_1=5 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '"& duoh_2 &"%')"
'Elseif duoh_1=5 Then
Elseif duoh_1=6 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& duoh_2 &"')"
'Elseif duoh_1=6 Then
end if
end if
ElseIf rs_kz_zdy_2("FType")="3" Then
date_1=request("date_"&id&"_1")
date_2=request("date_"&id&"_2")
str33=str33+"&date_"&id&"_1="+date_1
'date_2=request("date_"&id&"_2")
str33=str33+"&date_"&id&"_2="+date_2
'date_2=request("date_"&id&"_2")
If date_1<>"" or date_2<>"" Then
If date_1<>"" Then
sqldate=" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime) end)>=cast('"& date_1 &"'as datetime)"
'If date_1<>"" Then
end if
If date_2<>"" Then
sqldate=sqldate&" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime) end)<=cast('"& date_2 &"' as datetime)"
'If date_2<>"" Then
end if
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&""&sqldate&")"
'If date_2<>"" Then
end if
ElseIf rs_kz_zdy_2("FType")="4" Then
Numr_1=request("Numr_"&id&"_1")
Numr_2=request("Numr_"&id&"_2")
str33=str33+"&Numr_"&id&"_1="+Numr_1
'Numr_2=request("Numr_"&id&"_2")
str33=str33+"&Numr_"&id&"_2="+Numr_2
'Numr_2=request("Numr_"&id&"_2")
If Numr_2<>"" Then
If Numr_1=1 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& Numr_2 &"%')"
'If Numr_1=1 Then
Elseif Numr_1=2 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue not like '%"& Numr_2 &"%')"
'Elseif Numr_1=2 Then
Elseif Numr_1=3 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& Numr_2 &"')"
'Elseif Numr_1=3 Then
Elseif Numr_1=4 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue<>'"& Numr_2 &"')"
'Elseif Numr_1=4 Then
Elseif Numr_1=5 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '"& Numr_2 &"%')"
'Elseif Numr_1=5 Then
Elseif Numr_1=6 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& Numr_2 &"')"
'Elseif Numr_1=6 Then
end if
end if
ElseIf rs_kz_zdy_2("FType")="5" Then
beiz_1=request("beiz_"&id&"_1")
beiz_2=request("beiz_"&id&"_2")
str33=str33+"&beiz_"&id&"_1="+beiz_1
'beiz_2=request("beiz_"&id&"_2")
str33=str33+"&beiz_"&id&"_2="+beiz_2
beiz_2=request("beiz_"&id&"_2")
If beiz_2<>"" Then
If beiz_1=1 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& beiz_2 &"%')"
'If beiz_1=1 Then
Elseif beiz_1=2 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue not like '%"& beiz_2 &"%')"
'Elseif beiz_1=2 Then
Elseif beiz_1=3 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& beiz_2 &"')"
'Elseif beiz_1=3 Then
Elseif beiz_1=4 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue<>'"& beiz_2 &"')"
'Elseif beiz_1=4 Then
Elseif beiz_1=5 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '"& beiz_2 &"%')"
'Elseif beiz_1=5 Then
Elseif beiz_1=6 Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& beiz_2 &"')"
'Elseif beiz_1=6 Then
end if
end if
ElseIf rs_kz_zdy_2("FType")="6" Then
IsNot_1=request("IsNot_"&id&"_1")
str33=str33+"&IsNot_"&id&"_1="+IsNot_1
'IsNot_1=request("IsNot_"&id&"_1")
If IsNot_1<>"" Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& IsNot_1 &"')"
'If IsNot_1<>"" Then
end if
else
meju_1=request("meju_"&id&"_1")
str33=str33+"&meju_"&id&"_1="+Server.Urlencode(meju_1)
'meju_1=request("meju_"&id&"_1")
If meju_1<>"" Then
str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& meju_1 &"')"
'If meju_1<>"" Then
end if
end if
rs_kz_zdy_2.movenext
Loop
end if
rs_kz_zdy_2.close
Set rs_kz_zdy_2=Nothing
pub_cf=str33
end function
Function Show_Extended_By_Type(TName,typ,ord,columns)
Dim rs_kz_zdy, rs_kz_zdy_88, num1, i_jm, j_jm, classNamezdy, c_Value,sql,showWhere
if columns="" or columns=0 then
columns=3
else
columns=cint(columns)
end if
if typ="" then
typ=0
end if
set rs_kz_zdy=server.CreateObject("adodb.recordset")
sql="select * from ERP_CustomFields where TName='"&TName&"' and IsUsing=1 and del = 1 and FType in("&typ&") order by FOrder asc "
rs_kz_zdy.open sql,conn,1,1
num1=rs_kz_zdy.RecordCount
i_jm=0
j_jm=1
if Not rs_kz_zdy.eof then
do until rs_kz_zdy.eof
classNamezdy=""
If rs_kz_zdy("FType")=5 Then classNamezdy="ywcss2"
If i_jm=0 Then Response.write("<tr class='"&classNamezdy&"'>")
if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
Response.write("</tr><tr class='"&classNamezdy&"'>")
j_jm=j_jm+1
Response.write("</tr><tr class='"&classNamezdy&"'>")
end if
Set rs_kz_zdy_88=server.CreateObject("adodb.recordset")
rs_kz_zdy_88.open "select case when b.ftype=3 and isnull(FValue,'')<>'' then convert(varchar(10),isnull(FValue,''),120) else isnull(FValue,'') end FValue from ERP_CustomValues a inner join ERP_CustomFields b on a.fieldsid = b.id where a.FieldsID='"&rs_kz_zdy("id")&"' and a.OrderID='"&ord&"' ",conn,1,1
If Not rs_kz_zdy_88.eof Then
c_Value=rs_kz_zdy_88("FValue")
if rs_kz_zdy("FType")=2 then
c_Value=replace(c_Value&"",Chr(13)&Chr(10),"<br>")
end if
else
c_Value=""
end if
rs_kz_zdy_88.close
Set rs_kz_zdy_88=nothing
Response.write "" & vbcrlf & "                     <td align=""right"" height=""25"">"
Response.write rs_kz_zdy("FName")
Response.write "：</td>" & vbcrlf & "                      <td "
if i_jm=num1-1  then
Response.write "：</td>" & vbcrlf & "                      <td "
Response.write "colspan="""
Response.write 1+2*(j_jm*columns-num1)
Response.write "colspan="""
Response.write """"
end if
Response.write " class=""gray ewebeditorImg"">&nbsp;"
Response.write c_Value
Response.write "</td>" & vbcrlf & "                        "
i_jm=i_jm+1
Response.write "</td>" & vbcrlf & "                        "
rs_kz_zdy.movenext
loop
Response.write("</tr>")
end if
rs_kz_zdy.close
set rs_kz_zdy=nothing
end function
Function Show_Extended_By_TypeDeal(TName,typ,ord,columns,repID)
Dim rs_kz_zdy, rs_kz_zdy_88, num1, i_jm, j_jm, classNamezdy, c_Value,sql,showWhere
if columns="" or columns=0 then
columns=3
else
columns=cint(columns)
end if
if typ="" then
typ=0
end if
set rs_kz_zdy=server.CreateObject("adodb.recordset")
sql="select * from Copy_CustomFields where TName='"&TName&"' AND RepairOrder = "&repID&" and IsUsing=1 and del = 1 and FType in("&typ&") order by FOrder asc "
rs_kz_zdy.open sql,conn,1,1
num1=rs_kz_zdy.RecordCount
i_jm=0
j_jm=1
if Not rs_kz_zdy.eof then
do until rs_kz_zdy.eof
classNamezdy=""
If rs_kz_zdy("FType")=5 Then classNamezdy="ywcss2"
If i_jm=0 Then Response.write("<tr class='"&classNamezdy&"'>")
if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
Response.write("</tr><tr class='"&classNamezdy&"'>")
j_jm=j_jm+1
Response.write("</tr><tr class='"&classNamezdy&"'>")
end if
Set rs_kz_zdy_88=server.CreateObject("adodb.recordset")
rs_kz_zdy_88.open "select isnull(FValue,'') FValue from ERP_CustomValues where FieldsID='"&rs_kz_zdy("id")&"' and OrderID='"&ord&"' ",conn,1,1
If Not rs_kz_zdy_88.eof Then
c_Value=rs_kz_zdy_88("FValue")
if rs_kz_zdy("FType")=2 then
c_Value=replace(c_Value&"",Chr(13)&Chr(10),"<br>")
end if
else
c_Value=""
end if
rs_kz_zdy_88.close
Set rs_kz_zdy_88=nothing
Response.write "" & vbcrlf & "                     <td align=""right"" height=""25"">"
Response.write rs_kz_zdy("FName")
Response.write "：</td>" & vbcrlf & "                      <td "
if i_jm=num1-1  then
Response.write "：</td>" & vbcrlf & "                      <td "
Response.write "colspan="""
Response.write 1+2*(j_jm*columns-num1)
Response.write "colspan="""
Response.write """"
end if
Response.write " class=""gray ewebeditorImg"">"
Response.write c_Value
Response.write "&nbsp;</td>" & vbcrlf & "                  "
i_jm=i_jm+1
Response.write "&nbsp;</td>" & vbcrlf & "                  "
rs_kz_zdy.movenext
loop
Response.write("</tr>")
end if
rs_kz_zdy.close
set rs_kz_zdy=nothing
end function
Function Show_Extended_By_TypeDealBZ(TName,typ,ord,columns,repID)
Dim rs_kz_zdy, rs_kz_zdy_88, num1, i_jm, j_jm, classNamezdy, c_Value,sql,showWhere
if columns="" or columns=0 then
columns=3
else
columns=cint(columns)
end if
if typ="" then
typ=0
end if
set rs_kz_zdy=server.CreateObject("adodb.recordset")
sql="select * from Copy_CustomFields where TName='"&TName&"' AND RepairOrder = "&repID&" and IsUsing=1 and del = 1 and FType in("&typ&") order by FOrder asc "
rs_kz_zdy.open sql,conn,1,1
num1=rs_kz_zdy.RecordCount
i_jm=0
j_jm=1
if Not rs_kz_zdy.eof then
do until rs_kz_zdy.eof
classNamezdy=""
If rs_kz_zdy("FType")=5 Then classNamezdy="ywcss2"
Response.write("<tr class='"&classNamezdy&"'>")
Set rs_kz_zdy_88=server.CreateObject("adodb.recordset")
rs_kz_zdy_88.open "select isnull(FValue,'') FValue from ERP_CustomValues where FieldsID='"&rs_kz_zdy("id")&"' and OrderID='"&ord&"' ",conn,1,1
If Not rs_kz_zdy_88.eof Then
c_Value=rs_kz_zdy_88("FValue")
if rs_kz_zdy("FType")=2 then
c_Value=replace(c_Value&"",Chr(13)&Chr(10),"<br>")
end if
else
c_Value=""
end if
rs_kz_zdy_88.close
Set rs_kz_zdy_88=nothing
Response.write "" & vbcrlf & "                     <td align=""right"" height=""25"">"
Response.write rs_kz_zdy("FName")
Response.write "：</td>" & vbcrlf & "                        <td colspan="""
Response.write columns
Response.write """ class=""gray ewebeditorImg"">"
Response.write c_Value
Response.write "&nbsp;</td>" & vbcrlf & "                    "
i_jm=i_jm+1
Response.write "&nbsp;</td>" & vbcrlf & "                    "
Response.write("</tr>")
rs_kz_zdy.movenext
loop
end if
rs_kz_zdy.close
set rs_kz_zdy=nothing
end function
Function Show_Extended_By_Type2(TName,typ,ord,columns,sort1,filed1)
Dim rs_kz_zdy, rs_kz_zdy_88, num1, i_jm, j_jm, classNamezdy, c_Value, FVID
if columns="" or columns=0 then
columns=3
else
columns=cint(columns)
end if
if typ="" then
typ=0
end if
set rs_kz_zdy=server.CreateObject("adodb.recordset")
sql="select * from ERP_CustomFields where TName='"&TName&"' and IsUsing=1 and del=1 and FType in("&typ&") order by FOrder asc "
rs_kz_zdy.open sql,conn,1,1
num1=rs_kz_zdy.RecordCount
i_jm=0
j_jm=1
if Not rs_kz_zdy.eof then
do until rs_kz_zdy.eof
classNamezdy=""
If rs_kz_zdy("FType")=5 Then classNamezdy="ywcss2"
If i_jm=0 Then Response.write("<tr class='"&classNamezdy&"'>")
if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
Response.write("</tr><tr class='"&classNamezdy&"'>")
j_jm=j_jm+1
Response.write("</tr><tr class='"&classNamezdy&"'>")
end if
Set rs_kz_zdy_88=server.CreateObject("adodb.recordset")
rs_kz_zdy_88.open "select isnull(FValue,'') FValue,id from ERP_CustomValues where FieldsID='"&rs_kz_zdy("id")&"' and OrderID='"&ord&"' ",conn,1,1
If Not rs_kz_zdy_88.eof Then
c_Value=rs_kz_zdy_88("FValue")
FVID = rs_kz_zdy_88("id")
if rs_kz_zdy("FType")=2 then
c_Value=replace(c_Value&"",Chr(13)&Chr(10),"<br>")
end if
else
c_Value=""
end if
rs_kz_zdy_88.close
Set rs_kz_zdy_88=Nothing
If FVID&"" = "" Then FVID=0
Response.write "" & vbcrlf & "                      <td align=""right"" height=""25"">"
Response.write rs_kz_zdy("FName")
Response.write "：</td>" & vbcrlf & "                       <td "
if i_jm=num1-1  then
Response.write "：</td>" & vbcrlf & "                       <td "
Response.write "colspan="""
Response.write 1+2*(j_jm*columns-num1)
Response.write "colspan="""
Response.write """"
end if
Response.write " class=""gray ewebeditorImg"">"
If rs_kz_zdy("FType")=5 Then
If c_Value&""<>"" Then
Dim arr_img
arr_img = split(c_Value,"<img",-1,1)
'Dim arr_img
if ubound(arr_img)>0 then
Response.write "" & vbcrlf & "                                              <a href=""javascript:;"" onClick=""window.open('info.asp?ord="
Response.write app.base64.pwurl(FVID)
Response.write "&sort1="
Response.write sort1
Response.write "&sort2="
Response.write filed1
Response.write "','neww6768999in','width=' + 1600 + ',height=' + 800 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=0,top=150');return false;"" onMouseOver=""window.status='none';return true;"" title=""放大查看"">"
Response.write filed1
Response.write c_Value
Response.write "</a>" & vbcrlf & "                           "
else
Response.write(c_Value)
end if
end if
else
Response.write c_Value
end if
Response.write "&nbsp;</td>" & vbcrlf & "                   "
i_jm=i_jm+1
Response.write "&nbsp;</td>" & vbcrlf & "                   "
rs_kz_zdy.movenext
loop
Response.write("</tr>")
end if
rs_kz_zdy.close
set rs_kz_zdy=nothing
end function
Function Del_Extended_Value(TName,ord)
if ord="" Then ord=0
sql="delete from ERP_CustomValues where id in(select b.id from ERP_CustomFields  a " _
& " left join ERP_CustomValues b on a.id=b.fieldsid " _
& " where a.tname='"&TName&"' and b.orderid in("&ord&")) "
conn.execute(sql)
end function
Function Show_Search_Extended(TName)
set rs_kz_zdy_2=server.CreateObject("adodb.recordset")
sql2="select * from ERP_CustomFields where TName='"&TName&"' and IsUsing=1 and del=1 and CanSearch=1 order by FOrder asc "
rs_kz_zdy_2.open sql2,conn,1,1
if rs_kz_zdy_2.eof then
else
do until rs_kz_zdy_2.eof
Response.write "" & vbcrlf & "                     <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td align=""right"">"
Response.write rs_kz_zdy_2("FName")
Response.write "：</td>" & vbcrlf & "                      <td align=""left"">" & vbcrlf & "                 "
If rs_kz_zdy_2("FType")="1" then
Response.write "" & vbcrlf & "                             <select name=""danh_"
Response.write rs_kz_zdy_2("id")
Response.write "_1"">" & vbcrlf & "                              <option value=""1"">包含</option>" & vbcrlf & "                           <option value=""2"">不包含</option>" & vbcrlf & "                         <option value=""3"">等于</option>" & vbcrlf & "                           <option value=""4"">不等于</option>" & vbcrlf & "                         <option value=""5"">以..开始</option>" & vbcrlf & "                               <option value=""6"">以..结束</option>" & vbcrlf & "                             </select>" & vbcrlf & "                               <input name=""danh_"
Response.write rs_kz_zdy_2("id")
Response.write "_2"" type=""text"" size=""15"">" & vbcrlf & "                            "
ElseIf rs_kz_zdy_2("FType")="2" Then
Response.write "" & vbcrlf & "                             <select name=""duoh_"
Response.write rs_kz_zdy_2("id")
Response.write "_1"">" & vbcrlf & "                              <option value=""1"">包含</option>" & vbcrlf & "                           <option value=""2"">不包含</option>" & vbcrlf & "                         <option value=""3"">等于</option>" & vbcrlf & "                           <option value=""4"">不等于</option>" & vbcrlf & "                         <option value=""5"">以..开始</option>" & vbcrlf & "                               <option value=""6"">以..结束</option>" & vbcrlf & "                             </select>" & vbcrlf & "                               <input name=""duoh_"
Response.write rs_kz_zdy_2("id")
Response.write "_2"" type=""text"" size=""15"">" & vbcrlf & "                            "
ElseIf rs_kz_zdy_2("FType")="3" then
Response.write "" & vbcrlf & "                             <INPUT name=""date_"
Response.write rs_kz_zdy_2("id")
Response.write "_1"" size=""11""  id=""date_"
Response.write rs_kz_zdy_2("id")
Response.write "_1"" onmouseup=toggleDatePicker(""paydate1div_"
Response.write rs_kz_zdy_2("id")
Response.write """,""date.date_"
Response.write rs_kz_zdy_2("id")
Response.write "_1"")><DIV id=""paydate1div_"
Response.write rs_kz_zdy_2("id")
Response.write """ style=""POSITION: absolute"" name =""paydate1div_"
Response.write rs_kz_zdy_2("id")
Response.write """></DIV>&nbsp;-&nbsp;<INPUT name=""date_"
Response.write rs_kz_zdy_2("id")
Response.write rs_kz_zdy_2("id")
Response.write "_2"" size=""11"" id=""date_"
Response.write rs_kz_zdy_2("id")
Response.write "_2"" onmouseup=toggleDatePicker(""paydate2div_"
Response.write rs_kz_zdy_2("id")
Response.write """,""date.date_"
Response.write rs_kz_zdy_2("id")
Response.write "_2"")><DIV id=""paydate2div_"
Response.write rs_kz_zdy_2("id")
Response.write """ style=""POSITION: absolute"" name =""paydate2div_"
Response.write rs_kz_zdy_2("id")
Response.write """></DIV>" & vbcrlf & "                          "
ElseIf rs_kz_zdy_2("FType")="4" then
Response.write "" & vbcrlf & "                             <select name=""Numr_"
Response.write rs_kz_zdy_2("id")
Response.write "_1"">" & vbcrlf & "                              <option value=""1"">包含</option>" & vbcrlf & "                           <option value=""2"">不包含</option>" & vbcrlf & "                         <option value=""3"">等于</option>" & vbcrlf & "                           <option value=""4"">不等于</option>" & vbcrlf & "                         <option value=""5"">以..开始</option>" & vbcrlf & "                               <option value=""6"">以..结束</option>" & vbcrlf & "                             </select>" & vbcrlf & "                               <input name=""Numr_"
Response.write rs_kz_zdy_2("id")
Response.write "_2"" type=""text"" size=""15"">" & vbcrlf & "                            "
ElseIf rs_kz_zdy_2("FType")="5" then
Response.write "" & vbcrlf & "                             <select name=""beiz_"
Response.write rs_kz_zdy_2("id")
Response.write "_1"">" & vbcrlf & "                              <option value=""1"">包含</option>" & vbcrlf & "                           <option value=""2"">不包含</option>" & vbcrlf & "                         <option value=""3"">等于</option>" & vbcrlf & "                           <option value=""4"">不等于</option>" & vbcrlf & "                         <option value=""5"">以..开始</option>" & vbcrlf & "                               <option value=""6"">以..结束</option>" & vbcrlf & "                             </select>" & vbcrlf & "                               <input name=""beiz_"
Response.write rs_kz_zdy_2("id")
Response.write "_2"" type=""text"" size=""15"">" & vbcrlf & "                            "
ElseIf rs_kz_zdy_2("FType")="6" then
Response.write "" & vbcrlf & "                             <select name=""IsNot_"
Response.write rs_kz_zdy_2("id")
Response.write "_1"">" & vbcrlf & "                              <option value="""">选择</option>" & vbcrlf & "                            <option value=""是"">是</option>" & vbcrlf & "                            <option value=""否"">否</option>" & vbcrlf & "                            </select>" & vbcrlf & "                               "
else
Response.write "" & vbcrlf & "                             <select name=""meju_"
Response.write rs_kz_zdy_2("id")
Response.write "_1"">" & vbcrlf & "                              <option value="""">选择</option>" & vbcrlf & "                            "
Set rs_kz_zdy_8=server.CreateObject("adodb.recordset")
rs_kz_zdy_8.open "select * from ERP_CustomOptions where CFID="&rs_kz_zdy_2("id")&" ",conn,1,1
If Not rs_kz_zdy_8.eof Then
Do While Not rs_kz_zdy_8.eof
Response.write "" & vbcrlf & "                                             <option value="""
Response.write rs_kz_zdy_8("CValue")
Response.write """>"
Response.write rs_kz_zdy_8("CValue")
Response.write "</option>" & vbcrlf & "                                            "
rs_kz_zdy_8.movenext
Loop
end if
rs_kz_zdy_8.close
Set rs_kz_zdy_8=nothing
Response.write "" & vbcrlf & "                             </select>" & vbcrlf & "                               "
end if
Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
rs_kz_zdy_2.movenext
loop
end if
rs_kz_zdy_2.close
set rs_kz_zdy_2=Nothing
end function
Function Show_Search_Extended_Simple(TName)
set rs_kz_zdy_2=server.CreateObject("adodb.recordset")
sql2="select * from ERP_CustomFields where TName='"&TName&"' and IsUsing=1 and del=1 and CanSearch=1 order by FOrder asc "
rs_kz_zdy_2.open sql2,conn,1,1
if rs_kz_zdy_2.eof =False then
do until rs_kz_zdy_2.eof
Response.write "" & vbcrlf & "                     <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td align=""right"">"
Response.write rs_kz_zdy_2("FName")
Response.write "：</td>" & vbcrlf & "                      <td align=""left"">" & vbcrlf & "                 "
Select Case rs_kz_zdy_2("FType")
Case "1" :
Response.write "" & vbcrlf & "                             <input name=""danh_"
Response.write rs_kz_zdy_2("id")
Response.write """ type=""text"" size=""15"">" & vbcrlf & "                              "
Case "2" :
Response.write "" & vbcrlf & "                             <input name=""duoh_"
Response.write rs_kz_zdy_2("id")
Response.write """ type=""text"" size=""15"">" & vbcrlf & "                              "
Case "3" :
Response.write "" & vbcrlf & "                             <INPUT name=""date_"
Response.write rs_kz_zdy_2("id")
Response.write "_1"" size=""11""  id=""date_"
Response.write rs_kz_zdy_2("id")
Response.write "_1"" onmouseup=toggleDatePicker(""paydate1div_"
Response.write rs_kz_zdy_2("id")
Response.write """,""date.date_"
Response.write rs_kz_zdy_2("id")
Response.write "_1"")><DIV id=""paydate1div_"
Response.write rs_kz_zdy_2("id")
Response.write """ style=""POSITION: absolute"" name =""paydate1div_"
Response.write rs_kz_zdy_2("id")
Response.write """></DIV>&nbsp;-&nbsp;<INPUT name=""date_"
Response.write rs_kz_zdy_2("id")
Response.write rs_kz_zdy_2("id")
Response.write "_2"" size=""11"" id=""date_"
Response.write rs_kz_zdy_2("id")
Response.write "_2"" onmouseup=toggleDatePicker(""paydate2div_"
Response.write rs_kz_zdy_2("id")
Response.write """,""date.date_"
Response.write rs_kz_zdy_2("id")
Response.write "_2"")><DIV id=""paydate2div_"
Response.write rs_kz_zdy_2("id")
Response.write """ style=""POSITION: absolute"" name =""paydate2div_"
Response.write rs_kz_zdy_2("id")
Response.write """></DIV>" & vbcrlf & "                          "
Case "4" :
Response.write "" & vbcrlf & "                             <input name=""Numr_"
Response.write rs_kz_zdy_2("id")
Response.write """ type=""text"" size=""15"">" & vbcrlf & "                              "
Case "5" :
Response.write "" & vbcrlf & "                             <input name=""beiz_"
Response.write rs_kz_zdy_2("id")
Response.write """ type=""text"" size=""15"">" & vbcrlf & "                              "
Case "6" :
Response.write "" & vbcrlf & "                             <select name=""IsNot_"
Response.write rs_kz_zdy_2("id")
Response.write """>" & vbcrlf & "                                <option value="""">选择</option>" & vbcrlf & "                            <option value=""是"">是</option>" & vbcrlf & "                            <option value=""否"">否</option>" & vbcrlf & "                            </select>" & vbcrlf & "                               "
Case Else
Response.write "" & vbcrlf & "                             <select name=""meju_"
Response.write rs_kz_zdy_2("id")
Response.write """>" & vbcrlf & "                                <option value="""">选择</option>" & vbcrlf & "                            "
Set rs_kz_zdy_8=server.CreateObject("adodb.recordset")
rs_kz_zdy_8.open "select * from ERP_CustomOptions where CFID="&rs_kz_zdy_2("id")&" ",conn,1,1
If Not rs_kz_zdy_8.eof Then
Do While Not rs_kz_zdy_8.eof
Response.write "" & vbcrlf & "                                             <option value="""
Response.write rs_kz_zdy_8("CValue")
Response.write """>"
Response.write rs_kz_zdy_8("CValue")
Response.write "</option>" & vbcrlf & "                                            "
rs_kz_zdy_8.movenext
Loop
end if
rs_kz_zdy_8.close
Set rs_kz_zdy_8=nothing
Response.write "" & vbcrlf & "                             </select>" & vbcrlf & "                               "
End Select
Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
rs_kz_zdy_2.movenext
loop
end if
rs_kz_zdy_2.close
set rs_kz_zdy_2=Nothing
end function
Function searchExtended_Simple(TName,keycode)
Dim rs_kz_zdy_2 ,searchsql
set rs_kz_zdy_2=server.CreateObject("adodb.recordset")
Dim sql2 : sql2="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 and CanSearch=1 order by FOrder asc "
Dim str33,id,danh,Numr,beiz,IsNot_1,meju,duoh,date_1,date_2
rs_kz_zdy_2.open sql2,conn,1,1
if rs_kz_zdy_2.eof=False then
str33=""
do until rs_kz_zdy_2.eof
id=rs_kz_zdy_2("id")
Select Case rs_kz_zdy_2("FType")
Case "1" :
danh=request("danh_"&id&"")
str33=str33+"&danh_"&id&"="+danh
'danh=request("danh_"&id&"")
If danh<>"" Then
searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& danh &"%')"
'If danh<>"" Then
end if
Case "2" :
duoh=request("duoh_"&id&"")
str33=str33+"&duoh_"&id&"="+duoh
'duoh=request("duoh_"&id&"")
If duoh<>"" Then
searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& duoh &"%')"
'If duoh<>"" Then
end if
Case "3" :
date_1=request("date_"&id&"_1")
date_2=request("date_"&id&"_2")
str33=str33+"&date_"&id&"_1="+date_1
'date_2=request("date_"&id&"_2")
str33=str33+"&date_"&id&"_2="+date_2
'date_2=request("date_"&id&"_2")
If date_1<>"" or date_2<>"" Then
Dim sqldate
If date_1<>"" Then
sqldate=" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime) end)>=cast('"& date_1 &"'as datetime)"
'If date_1<>"" Then
end if
If date_2<>"" Then
sqldate=sqldate&" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime) end)<=cast('"& date_2 &"' as datetime)"
'If date_2<>"" Then
end if
searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" "&sqldate&")"
'If date_2<>"" Then
end if
Case "4" :
Numr=request("Numr_"&id&"")
str33=str33+"&Numr_"&id&"="+Numr
'Numr=request("Numr_"&id&"")
If Numr<>"" Then
searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& Numr &"%')"
'If Numr<>"" Then
end if
Case "5" :
beiz=request("beiz_"&id&"")
str33=str33+"&beiz_"&id&"="+beiz
'beiz=request("beiz_"&id&"")
If beiz<>"" Then
searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& beiz &"%')"
'If beiz<>"" Then
end if
Case "6" :
IsNot_1=request("IsNot_"&id&"")
str33=str33+"&IsNot_"&id&"_1="+IsNot_1
'IsNot_1=request("IsNot_"&id&"")
If IsNot_1<>"" Then
searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& IsNot_1 &"')"
'If IsNot_1<>"" Then
end if
Case Else
meju=request("meju_"&id&"")
str33=str33+"&meju_"&id&"="+Server.Urlencode(meju)
'meju=request("meju_"&id&"")
If meju<>"" Then
searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& meju &"')"
'If meju<>"" Then
end if
End Select
rs_kz_zdy_2.movenext
Loop
end if
rs_kz_zdy_2.close
Set rs_kz_zdy_2=Nothing
pub_cf=str33
searchExtended_Simple=searchsql
end function
Sub Export_xls_Extended(TName,typ,cols,columns,ord)
IF typ=1 then
set rs_kz_zdy=server.CreateObject("adodb.recordset")
kz_sql="select 1 from erp_customFields  where TName='"&TName&"'  and IsUsing=1 and del=1 and canExport=1 order by FOrder asc"
rs_kz_zdy.open kz_sql,conn,1,1
do while not rs_kz_zdy.eof
xlApplication.ActiveSheet.columns(columns).columnWidth=15
xlApplication.ActiveSheet.columns(columns).HorizontalAlignment=3
rs_kz_zdy.movenext
columns=columns+1
'rs_kz_zdy.movenext
loop
rs_kz_zdy.close
set rs_kz_zdy=nothing
ElseIf typ=2 then
set rs_kz_zdy=server.CreateObject("adodb.recordset")
kz_sql="select FName from erp_customFields  where TName='"&TName&"' and IsUsing=1 and del=1 and canExport=1 order by FOrder asc"
rs_kz_zdy.open kz_sql,conn,1,1
do while not rs_kz_zdy.eof
xlWorksheet.Cells(1,columns).Value = rs_kz_zdy("FName")
xlWorksheet.Cells(1,columns).font.Size=10
xlWorksheet.Cells(1,columns).font.bold=true
rs_kz_zdy.movenext
columns=columns+1
rs_kz_zdy.movenext
loop
rs_kz_zdy.close
set rs_kz_zdy =nothing
ElseIf typ=3 then
set rs_kz_zdy=server.CreateObject("adodb.recordset")
kz_sql="select b.FValue from erp_customFields a left join (select fieldsid,fvalue,orderid from erp_customValues where orderid='"&ord&"') b " _
& " on b.fieldsid=a.id where a.TName='"&TName&"' and a.IsUsing=1 and a.canExport=1 order by a.FOrder asc"
rs_kz_zdy.open kz_sql,conn,1,1
do while not rs_kz_zdy.eof
xlWorksheet.Cells(1+cols,columns).Value = rs_kz_zdy("FValue")
'do while not rs_kz_zdy.eof
xlWorksheet.Cells(1+cols,columns).font.Size=10
'do while not rs_kz_zdy.eof
rs_kz_zdy.movenext
columns=columns+1
rs_kz_zdy.movenext
loop
rs_kz_zdy.close
set rs_kz_zdy=nothing
end if
end sub
Function dyExtended(TName,columns)
set rs_kz_zdy=server.CreateObject("adodb.recordset")
kz_sql="select * from ERP_CustomFields where TName="&TName&" and IsUsing=1 and del=1 order by FOrder asc "
rs_kz_zdy.open kz_sql,conn,1,1
num1=rs_kz_zdy.RecordCount
i_jm=0
j_jm=1
if rs_kz_zdy.eof then
else
Response.write("<table width='100%' border='0' cellpadding='0' cellspacing='0' id='content2' bgcolor='#000000'>")
Response.write("<tr>")
do until rs_kz_zdy.eof
if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
Response.write("</tr><tr>")
j_jm=j_jm+1
Response.write("</tr><tr>")
end if
Response.write "" & vbcrlf & "                     <td width=""42%"" height=""27"" "
if i_jm=num1-1  then
Response.write "" & vbcrlf & "                     <td width=""42%"" height=""27"" "
Response.write "colspan="""
Response.write 1+2*(j_jm*columns-num1)
Response.write "colspan="""
Response.write """"
end if
Response.write ">" & vbcrlf & "                            {"
Response.write rs_kz_zdy("fname")
Response.write ":<span title=""点击复制"
Response.write rs_kz_zdy("fname")
Response.write """ id=""zdy"
Response.write rs_kz_zdy("id")
Response.write """ onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_"
Response.write rs_kz_zdy("id")
Response.write "_E</span>}" & vbcrlf & "                   " & vbcrlf & "                        </td>" & vbcrlf & "                   "
i_jm=i_jm+1
rs_kz_zdy.movenext
loop
Response.write("</tr>")
Response.write("</table>")
end if
rs_kz_zdy.close
set rs_kz_zdy=nothing
end function
Function dyMxExtended(TName,columns)
set rs_kz_zdy=server.CreateObject("adodb.recordset")
If TName = 28 Then
kz_sql="select a.id,a.fname,b.sort1 from ERP_CustomFields a inner join sortonehy b on b.ord+200000 = a.tname and b.gate2=3001 and b.del=1 and b.isStop = 0 and a.FType<>'5' and a.id>0 ORDER BY FOrder asc,a.id "
'If TName = 28 Then
else
kz_sql="select * from ERP_CustomFields where TName="&TName&" and IsUsing=1 and del=1 order by FOrder asc "
end if
rs_kz_zdy.open kz_sql,conn,1,1
num1=rs_kz_zdy.RecordCount
i_jm=0
j_jm=1
if rs_kz_zdy.eof then
else
Response.write("<table width='100%' border='0' cellpadding='0' cellspacing='0' id='content2' bgcolor='#000000'>")
Response.write("<tr>")
do until rs_kz_zdy.eof
if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
Response.write("</tr><tr>")
j_jm=j_jm+1
Response.write("</tr><tr>")
end if
Response.write "" & vbcrlf & "                     <td width=""42%"" height=""27"" "
if i_jm=num1-1  then
Response.write "" & vbcrlf & "                     <td width=""42%"" height=""27"" "
Response.write "colspan="""
Response.write 1+2*(j_jm*columns-num1)
Response.write "colspan="""
Response.write """"
end if
Response.write ">" & vbcrlf & "                            {"
Response.write rs_kz_zdy("fname")
Response.write "["
Response.write rs_kz_zdy("sort1")
Response.write "]：<span title=""点击复制"
Response.write rs_kz_zdy("fname")
Response.write """ id=""zdy"
Response.write rs_kz_zdy("id")
Response.write """ onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">Extended_"
Response.write rs_kz_zdy("id")
Response.write "_E</span>}" & vbcrlf & "                   " & vbcrlf & "                        </td>" & vbcrlf & "                   "
i_jm=i_jm+1
rs_kz_zdy.movenext
loop
Response.write("</tr>")
Response.write("</table>")
end if
rs_kz_zdy.close
set rs_kz_zdy=nothing
end function
Function dyExtended_kz(TName,columns)
Response.write "" & vbcrlf & "     <table width='100%' border='0' cellpadding='4' cellspacing='1' id='content2' bgcolor='#C0CCDD'>" & vbcrlf & "         <tr class=top><td colspan="""
Response.write columns
Response.write """><strong>【公共字段】</strong></td></tr>" & vbcrlf & "         <td width=""33%"" height=""27"">{税号:<span title=""点击复制税号"" id=""zdy_taxno"" onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_taxno_E</span>}</td>" & vbcrlf & "           "
If columns = 1 Then Response.write "</tr><tr>"
Response.write "" & vbcrlf & "             <td width=""33%"" height=""27"">{公司地址:<span title=""点击复制公司地址"" id=""zdy_addr"" onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_addr_E</span>}</td>" & vbcrlf & "             "
If 2 mod columns = 0 Then Response.write "</tr><tr>"
Response.write "" & vbcrlf & "             <td width=""33%"" height=""27"">{公司电话:<span title=""点击复制公司电话"" id=""zdy_phone"" onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_phone_E</span>}</td>" & vbcrlf & "           "
If 3 mod columns = 0 Then Response.write "</tr><tr>"
Response.write "" & vbcrlf & "             <td width=""33%"" height=""27"">{开户行:<span title=""点击复制开户行"" id=""zdy_bank"" onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_bank_E</span>}</td>" & vbcrlf & "         "
If 4 mod columns = 0 Then Response.write "</tr><tr>"
Response.write "" & vbcrlf & "             <td width=""33%"" height=""27"">{开户行账号:<span title=""点击复制开户行账号"" id=""zdy_account"" onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_account_E</span>}</td>" & vbcrlf & "           "
If 5 mod columns = 0 Then
Response.write "</tr>"
else
Response.write "<td colspan="&(columns-(5 mod columns))&"></td></tr>"
Response.write "</tr>"
end if
Set rs =conn.execute("select ord,sort1 from sortonehy where gate2="&TName&" and isnull(id1,0)=0")
If rs.eof= False Then
While rs.eof = False
set rs_kz_zdy=server.CreateObject("adodb.recordset")
kz_sql="select * from ERP_CustomFields where TName="&(rs("ord")*1+100000)&" and IsUsing=1 and del=1 order by FOrder asc "
'set rs_kz_zdy=server.CreateObject("adodb.recordset")
rs_kz_zdy.open kz_sql,conn,1,1
if rs_kz_zdy.eof= False Then
Response.write "<tr class=top><td colspan="""
Response.write columns
Response.write """><strong>【"
Response.write rs("sort1")
Response.write "】</strong></td></tr>"
num1 = 0
do until rs_kz_zdy.eof
If num1 Mod columns = 0 Then Response.write "<tr>"
Response.write "" & vbcrlf & "                                              <td width=""33%"" height=""27"">" & vbcrlf & "                                                        {"
Response.write rs_kz_zdy("fname")
Response.write ":<span title=""点击复制"
Response.write rs_kz_zdy("fname")
Response.write """ id=""zdy"
Response.write rs_kz_zdy("id")
Response.write """ onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_"
Response.write rs_kz_zdy("id")
Response.write "_E</span>}                                    " & vbcrlf & "                                                </td>" & vbcrlf & "                                           "
num1=num1+1
If num1 Mod columns = 0 Then Response.write "</tr>"
rs_kz_zdy.movenext
Loop
If num1 Mod columns > 0  Then Response.write "<td colspan="&columns-(num1 Mod columns)&"></td></tr>"
'Loop
end if
rs_kz_zdy.close
set rs_kz_zdy=Nothing
rs.movenext
wend
end if
rs.close
Response.write "" & vbcrlf & "      </table>" & vbcrlf & "        "
end function
Function isUsingExtend(TName)
Dim rs,sql
Set rs = server.CreateObject("adodb.recordset")
sql =        "SELECT TOP 1 ID FROM ERP_CustomFields WHERE TName = "& TName &" AND IsUsing=1 AND del=1 AND FType <> '5' " &_
"UNION " &_
"SELECT TOP 1 ID FROM zdy WHERE sort1 = "& TName &" AND set_open = 1"
rs.open sql,conn,1,1
If Not rs.Eof Then
isUsingExtend = True
else
isUsingExtend = False
end if
rs.close
set rs = nothing
end function
Function getExtendedCount(TName)
getExtendedCount = sdk.getSqlValue("select count(1) from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1", 0)
end function
Function showExtended_byListHeader(TName, ord, classStr)
dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7
sql="select FName from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 order by FOrder asc "
set rs_kz_zdy=server.CreateObject("adodb.recordset")
rs_kz_zdy.open sql,conn,1,1
While rs_kz_zdy.eof = False
Response.write "" & vbcrlf & "              <td width=""11%"" align=""center"" "
Response.write classStr
Response.write ">"
Response.write rs_kz_zdy("FName")
Response.write "</td>" & vbcrlf & " "
rs_kz_zdy.movenext
wend
rs_kz_zdy.close
Set rs_kz_zdy = Nothing
end function
Function showExtended_byLIsttdStr(TName, ord, classStr)
dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7, retStr
retStr = ""
sql="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 order by FOrder asc "
set rs_kz_zdy=server.CreateObject("adodb.recordset")
rs_kz_zdy.open sql,conn,1,1
While rs_kz_zdy.eof = False
retStr = retStr & "<td height=""30"" width=""10%"" class="""& classStr &""">"
if rs_kz_zdy("FType")="1" Then
retStr = retStr & "<input name=""danh_"& rs_kz_zdy("id") &""" type=""text"" size=""15"" id=""danh_"& rs_kz_zdy("id") &""" value="""& c_Value &""" dataType=""Limit"""
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then retStr = retStr & " min=""1"""
retStr = retStr & " max=""500""  msg=""必须在1到500个字符"" maxlength=""4000"">"
Elseif rs_kz_zdy("FType")="2" then
retStr = retStr & "<textarea name=""duoh_"& rs_kz_zdy("id") &""" id=""duoh_"& rs_kz_zdy("id") &""" style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px"" onfocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" dataType=""Limit"""
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then retStr = retStr & " min=""1"" "
retStr = retStr & "max=""500""  msg=""必须在1到500个字符"">"& c_Value &"</textarea>"
elseif rs_kz_zdy("FType")="3" Then
retStr = retStr & "<input readonly name=""date_"& rs_kz_zdy("id") &""" value="""& c_Value &""" size=""15"" id=""daysOfMonthPos"" onmouseup=""toggleDatePicker('daysOfMonth_"& rs_kz_zdy("id") &"','date_"& rs_kz_zdy("id") &"')"" dataType=""Limit"""
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then retStr = retStr & " min=""1"""
retStr = retStr & " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:right;background-repeat:no-repeat;""> <div id=""daysOfMonth_"& rs_kz_zdy("id") &""" style=""POSITION:absolute""></div>"
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then retStr = retStr & " min=""1"""
ElseIf rs_kz_zdy("FType")="4" then
retStr = retStr & "<input name=""Numr_"& rs_kz_zdy("id") &""" type=""text"" value="""& c_Value &""" size=""8"" id=""Numr_"& rs_kz_zdy("id") &""" onkeyup=""value=value.replace(/[^\d\.]/g,'')"" dataType=""Limit"""
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then retStr = retStr & " min=""1"" "
retStr = retStr & "max=""500""  msg=""必须在1到500个字符"" >"
Elseif rs_kz_zdy("FType")="5" then
retStr = retStr & "<textarea name=""beiz_"& rs_kz_zdy("id") &""" id=""beiz_"& rs_kz_zdy("id") &""" style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px"" onfocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" dataType=""Limit"""
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then retStr = retStr & " min=""1"""
retStr = retStr & "max=""500""  msg=""必须在1到500个字符"">"& c_Value &"</textarea>"
ElseIf rs_kz_zdy("FType")="6" then
retStr = retStr & "<select name=""IsNot_"& rs_kz_zdy("id") &""" id=""IsNot_"& rs_kz_zdy("id") &"""  dataType=""Limit"""
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then retStr = retStr & " min=""1"""
retStr = retStr & " max=""500""  msg=""必须在1到500个字符"">"
retStr = retStr & "<option value=""是"""
If c_Value="是" Then retStr = retStr & " selected"
retStr = retStr & ">是</option>"
retStr = retStr & "<option value=""否"""
If c_Value="否" Then retStr = retStr & "selected"
retStr = retStr & ">否</option>"
retStr = retStr & "</select>"
ElseIf rs_kz_zdy("FType")="7" then
retStr = retStr & "<select name=""meju_" & rs_kz_zdy("id") &""" id=""meju_"& rs_kz_zdy("id") &"""  dataType=""Limit"""
if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then retStr = retStr & " min=""1"""
retStr = retStr & " max=""500""  msg=""必须在1到500个字符"">"
set rs7=conn.execute("select id,CValue from ERP_CustomOptions where CFID="&rs_kz_zdy("id")&" order by id asc ")
do until rs7.eof
retStr = retStr & "<option value="""& rs7("id") &""""
If rs7("CValue")=c_Value Then retStr = retStr & " selected"
retStr = retStr & ">"& rs7("CValue") &"</option>"
rs7.movenext
loop
rs7.close
retStr = retStr & "</select>"
end if
if  rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then
retStr = retStr & "&nbsp;<span class=""red"">*</span>"
end if
retStr = retStr & "</td>"
rs_kz_zdy.movenext
wend
rs_kz_zdy.close
Set rs_kz_zdy = Nothing
showExtended_byLIsttdStr = retStr
end function
Function getExtendedValue(c_Value,priceDigits)
if c_Value ="" then
getExtendedValue=""
else
getExtendedValue=FormatNumber(zbcdbl(c_Value),priceDigits,-1,0,0)
getExtendedValue=""
end if
end function

dim showHtMoney, showCB, showFyMoney, showThMoney, showSkMoney
showHtMoney = 0
showCB = 0
showFyMoney = 0
showThMoney = 0
showSkMoney = 0
If instr(Lcase(request.ServerVariables("URL")),"sysa/mobilephone/")=0 Then
If ZBRuntime.MC(6000) Or ZBRuntime.MC(7000) Then showHtMoney = 1
If ZBRuntime.MC(17003) Then showCB = 1
If ZBRuntime.MC(27000) Then showFyMoney = 1
If ZBRuntime.MC(8000) Then showThMoney = 1
If ZBRuntime.MC(23000) Or ZBRuntime.MC(23001) Then showSkMoney = 1
end if
function getHtYhhMoney(htord)
dim rs, yhhMoney
yhhMoney = 0
If ZBRuntime.MC(6000) Or ZBRuntime.MC(7000) Then
set rs = conn.execute("select isnull(money2,money1) money2 from contract WITH(NOLOCK) where ord="& htord)
if rs.eof = false then
yhhMoney = cdbl(rs("money2"))
end if
rs.close
set rs = nothing
end if
if yhhMoney&"" = "" then yhhMoney = 0 else yhhMoney = cdbl(yhhMoney)
getHtYhhMoney = yhhMoney
end function
function getHtTaxValue(htord)
dim rs, taxValue
taxValue = 0
If ZBRuntime.MC(6000) Or ZBRuntime.MC(7000) Then
set rs = conn.execute("select case when b.invoiceMode=1 and isnull(b.dataversion,3100)<3179 then cast(b.money2/(1+isnull(b.taxRate,1)/100) as decimal(25,12))*cast(isnull(b.taxRate,1)/100 as decimal(25,12))  else sum(a.taxValue*isnull(c.hl,1)) end taxValue from contractlist a WITH(NOLOCK) inner join contract b on a.contract = b.ord left join hl c on c.bz = b.bz and b.date3 = c.date1 where a.del=1 and a.contract="&htord&" group by b.invoiceMode,b.money2,b.taxRate,b.dataversion")
if rs.eof = false then
taxValue = rs("taxValue")
end if
rs.close
set rs = nothing
end if
if taxValue&"" = "" then taxValue = 0 else taxValue = cdbl(taxValue)
getHtTaxValue = taxValue
end function
function getHtJinjiaMoney(htord)
dim rs, money1
money1 = 0
set rs = conn.execute("select sum(tpricejy) tpricejy from contractlist WITH(NOLOCK) where del=1 and contract="& htord)
if rs.eof = false then
money1 =zbcdbl( rs("tpricejy"))
end if
rs.close
set rs = nothing
if money1&"" = "" then money1 = 0 else money1 = cdbl(money1)
getHtJinjiaMoney = money1
end function
function getHtThTaxValue(htord)
dim rs, sql, taxValue
taxValue = 0
If ZBRuntime.MC(8000) Then
sql = "select isnull(SUM(thl.taxValue),0) * isnull(h.hl,1) taxValue "&_
"   FROM contractth th WITH(NOLOCK)  "&_
"   INNER JOIN contractthlist thl WITH(NOLOCK) ON thl.caigou=th.ord AND th.del=1 and thl.del=1 and thl.contract="& htord &" "&_
"   INNER JOIN contractlist ctl WITH(NOLOCK) ON thl.contractlist=ctl.id AND thl.contract=ctl.contract "&_
"   INNER JOIN contract ct WITH(NOLOCK) ON ctl.contract=ct.ord "&_
"   left JOIN hl h WITH(NOLOCK) ON ct.bz = h.bz and ct.date3 = h.date1 "&_
"   GROUP by thl.contract,isnull(h.hl,1)"
set rs = conn.execute(sql)
if rs.eof = false then
taxValue = rs("taxValue")
end if
rs.close
set rs = nothing
end if
if taxValue&"" = "" then taxValue = 0 else taxValue = cdbl(taxValue)
getHtThTaxValue = taxValue
end function
Function OutStore_Cost(contract_ord)
dim rs1, sql1, money_cpall : money_cpall=0
if trim(contract_ord)<>"" and isnumeric(trim(contract_ord)) then
sql1 = "select "&_
"   isnull(sum( isnull(k.finamoney,0) ),0) money1 " &_
"   from kuoutlist2 k WITH(NOLOCK) "&_
"   where (k.sort1=1 or k.sort1=4) and k.contract="&contract_ord&" and k.del=1 "
set rs1 = server.CreateObject("adodb.recordset")
rs1.open sql1,conn,1,1
if not rs1.eof then
money_cpall = cdbl(rs1("money1"))
end if
rs1.close
set rs1=nothing
end if
if money_cpall&"" = "" then money_cpall = 0 else money_cpall = cdbl(money_cpall)
OutStore_Cost= money_cpall
end function
Function OutStore_Th_Cost(contract_ord)
dim rs1, rs7, sql1, sql7
if trim(contract_ord)<>"" and isnumeric(trim(contract_ord)) then
dim money_cpall : money_cpall=0
sql1="select c.price1,d.num1,c.kuinlist from kuoutlist2 c WITH(NOLOCK),contractthlist d WITH(NOLOCK),contractth e WITH(NOLOCK) where e.del=1 and d.del=1 and e.ord=d.caigou and c.id=d.kuoutlist2 and d.contract="&contract_ord &" and c.del=1"
set rs1 = server.CreateObject("adodb.recordset")
rs1.open sql1,conn,1,1
if not rs1.eof then
do until rs1.eof
if rs1("kuinlist")<>"" and rs1("kuinlist")<>"0"  then
sql7 = "select ROUND(REPLACE(price1,',',''),8) from kuinlist WITH(NOLOCK) where id="&rs1("kuinlist")&" and del=1"
set rs7 = server.CreateObject("adodb.recordset")
rs7.open sql7,conn,1,1
if rs7.eof then
money_cpall=money_cpall+cdbl(rs1("price1")) * cdbl(rs1("num1"))
'if rs7.eof then
else
money_cpall=money_cpall+cdbl(rs7("price1")) * cdbl(rs1("num1"))
'if rs7.eof then
end if
rs7.close
set rs7=nothing
else
money_cpall=money_cpall+cdbl(rs1("price1")) * cdbl(rs1("num1"))
set rs7=nothing
end if
rs1.movenext
loop
end if
rs1.close
set rs1=nothing
if money_cpall&"" = "" then money_cpall = 0 else money_cpall = cdbl(money_cpall)
OutStore_Th_Cost= money_cpall
end if
end function
function getHtPaybacktype(htord)
dim rs, paybacktype
paybacktype = 0
set rs = conn.execute("select paybacktype from contract WITH(NOLOCK) where ord="& htord)
if rs.eof = false then
paybacktype = rs("paybacktype")
end if
rs.close
set rs = nothing
getHtPaybacktype = paybacktype
end function
function getHtProCb(htord)
dim rs, rs1, sql1, money_cpall, paybacktype
money_cpall = 0
If ZBRuntime.MC(17003) Then
sql1 = "select isnull(sum(d.finamoney) ,0) as money1 "&_
"from kuoutlist2 d WITH(NOLOCK) "&_
"INNER JOIN kuout k WITH(NOLOCK) ON k.ord=d.kuout "&_
"where k.sort1 in (1,4) and k.order1="& htord &" and d.del=1 "
set rs1 = server.CreateObject("adodb.recordset")
rs1.open sql1,conn,1,1
if rs1.eof = false then
money_cpall=money_cpall+CDbl(rs1("money1"))
'if rs1.eof = false then
end if
rs1.close
set rs1=nothing
paybacktype = getHtPaybacktype(htord)
if paybacktype&"" = "1" then
money_cpall = OutStore_Cost(htord)
end if
end if
if money_cpall&"" = "" then money_cpall = 0 else money_cpall = cdbl(money_cpall)
getHtProCb = money_cpall
end function
function getHtProCbX(htord, ftype)
dim rs, rs1, sql1, money_cpall
money_cpall = 0
Select Case ftype
Case ""
money_cpall = getHtProCb(htord)
case "jinjia"
money_cpall=getHtJinjiaMoney(htord)
End Select
if money_cpall&"" = "" then money_cpall = 0 else money_cpall = cdbl(money_cpall)
getHtProCbX = money_cpall
end function
function getHtFyMoney(htord)
dim rs1, sql1, money_fyall
money_fyall = 0
If ZBRuntime.MC(27000) Then
sql1 = "select isnull(sum(a.money1*isnull(b.hl,1)),0) as money1 from pay a WITH(NOLOCK) inner join f_pay c with(nolock) on c.id = a.fid and c.del=1 left join hl b WITH(NOLOCK) on a.bz = b.bz and convert(varchar(10),a.date1,120)=convert(varchar(10),b.date1,120) where a.contract="&htord&" and a.del=1 and a.complete=3 "
set rs1 = server.CreateObject("adodb.recordset")
rs1.open sql1,conn,1,1
if rs1.eof = false then
money_fyall=cdbl(rs1("money1"))
end if
rs1.close
set rs1=nothing
end if
if money_fyall&"" = "" then money_fyall = 0 else money_fyall = cdbl(money_fyall)
getHtFyMoney = money_fyall
end function
function getHtThMoney(htord)
dim rs1, sql1, total_th
total_th = 0
If ZBRuntime.MC(8000) Then
sql1 = "select SUM(isnull(cld.money1,thl.money1)*dbo.gethl(thl.bz,thl.date1,getdate())) from contractth th WITH(NOLOCK) INNER JOIN contractthlist thl WITH(NOLOCK) ON thl.caigou=th.ord AND th.del=1 and thl.del=1 and thl.contract="&htord&" left join contractthListDetail cld on cld.contractthlist=thl.id and cld.thtype='GOODS' group by thl.contract"
'"select isnull(sum(a.money2*isnull(c.hl,1)),0),isnull(sum(a.money2),0) from contractthListDetail a inner join contractthlist b on a.contractthlist = b.id and b.del=1 left join hl c on c.bz = b.bz and convert(varchar(10),c.date1,120) = convert(varchar(10),b.date1,120) where a.contract="&htord&" and a.del=1"
set rs1 = server.CreateObject("adodb.recordset")
rs1.open sql1,conn,1,1
if rs1.eof = false then
total_th=cdbl(rs1(0))
end if
rs1.close
set rs1=nothing
end if
if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
getHtThMoney = total_th
end function
function getHtSTMoney(htord)
dim rs, stmoney, sql
stmoney = 0
if htord&""="" then htord = 0 else htord = cdbl(htord)
if htord>0 then
sql = "select isnull((select SUM(thl.money1*dbo.gethl(thl.bz,thl.date1,getdate())) from contractth th WITH(NOLOCK) INNER JOIN contractthlist thl WITH(NOLOCK) ON thl.caigou=th.ord AND th.del=1 and thl.del=1 and thl.contract="&htord&" group by thl.contract),0) - "&_
"isnull((select isnull(sum(a.money2*dbo.gethl(b.bz,b.date3,getdate())),0) from contractthListDetail a WITH(NOLOCK)" &_
"inner join contractth b WITH(NOLOCK) on a.contractth = b.ord and b.del=1 and isnull(b.sp,0)=0 "&_
"and a.thtype='GOODS' and a.contract=" & htord &"),0)"
set rs = conn.execute(sql)
if rs.eof = false then
stmoney = rs(0)
end if
end if
if stmoney&""="" then stmoney = 0 else stmoney = cdbl(stmoney)
getHtSTMoney = stmoney
end function
function getHtThYbzMoney(htord)
dim rs1, sql1, total_th_ybz
total_th_ybz = 0
If ZBRuntime.MC(8000) Then
sql1 = "select SUM(thl.money1) from contractth th WITH(NOLOCK) INNER JOIN contractthlist thl WITH(NOLOCK) ON thl.caigou=th.ord AND th.del=1 and thl.del=1 and thl.contract="&htord&" group by thl.contract"
'"select isnull(sum(a.money2*isnull(c.hl,1)),0),isnull(sum(a.money2),0) from contractthListDetail a inner join contractthlist b on a.contractthlist = b.id and b.del=1 left join hl c on c.bz = b.bz and convert(varchar(10),c.date1,120) = convert(varchar(10),b.date1,120) where a.contract="&htord&" and a.del=1"
set rs1 = server.CreateObject("adodb.recordset")
rs1.open sql1,conn,1,1
if rs1.eof = false then
total_th_ybz=rs1(0)
end if
rs1.close
set rs1=nothing
end if
if total_th_ybz&"" = "" then total_th_ybz = 0 else total_th_ybz = cdbl(total_th_ybz)
getHtThYbzMoney = total_th_ybz
end function
function getHtThCost(htord)
dim rs1, sql1, total_th_cost, paybacktype
total_th_cost = 0
If ZBRuntime.MC(8000) Then
sql1 = "select (case a.paybacktype when 1 then  " & vbcrlf &_
"  (select isnull(sum(c.price1*d.num1),0) from kuoutlist2 c WITH(NOLOCK),contractthlist d WITH(NOLOCK),contractth e WITH(NOLOCK) where e.del=1 and d.caigou=e.ord and c.del=1 and d.del=1 and c.id=d.kuoutlist2 and d.contract=a.ord) " & vbcrlf &_
"else   " & vbcrlf &_
"  (select SUM(ISNULL((CASE ISNULL(c.kuinlist,0) WHEN 0 THEN c.price1*d.num1 ELSE ROUND(REPLACE(r.price1,',',''),8)*d.num1 END),c.price1*d.num1)) " & vbcrlf &_
"  FROM kuoutlist2 c WITH(NOLOCK) INNER JOIN contractthlist d WITH(NOLOCK) ON c.id=d.kuoutlist2 and c.del=1 and d.del=1 " & vbcrlf &_
"  INNER JOIN contractth e WITH(NOLOCK) ON e.del=1 and e.ord=d.caigou and d.contract=a.ord " & vbcrlf &_
"  LEFT JOIN kuinlist r WITH(NOLOCK) ON r.id=c.kuinlist AND r.del=1) " & vbcrlf &_
"end)  from contract a WITH(NOLOCK) where a.ord="& htord
set rs1 = conn.execute(sql1)
if rs1.eof = false then
total_th_cost=rs1(0)
end if
rs1.close
set rs1=nothing
end if
if total_th_cost&"" = "" then total_th_cost = 0 else total_th_cost = cdbl(total_th_cost)
getHtThCost = total_th_cost
end function
function getHtThJinJiaCost(htord)
dim rs1, sql1, total_th_cost, paybacktype
total_th_cost = 0
If ZBRuntime.MC(8000) Then
sql1 = "select isnull(sum(c.pricejy*d.num1),0) "&_
"from contract a WITH(NOLOCK) "&_
"inner join contractthlist d WITH(NOLOCK) on d.contract=a.ord "&_
"inner join contractth e WITH(NOLOCK) on d.caigou=e.ord "&_
"inner join contractlist c WITH(NOLOCK) on c.id=d.contractlist "&_
"where e.del=1 and c.del=1 and d.del=1 and a.ord="& htord
set rs1 = conn.execute(sql1)
if rs1.eof = false then
total_th_cost=rs1(0)
end if
rs1.close
set rs1=nothing
end if
if total_th_cost&"" = "" then total_th_cost = 0 else total_th_cost = cdbl(total_th_cost)
getHtThJinJiaCost = total_th_cost
end function
function getHtDzMoney(htord)
dim rs, money_hkall,sql
money_hkall = 0
If ZBRuntime.MC(23000) Or ZBRuntime.MC(23001) Then
sql = "select (case isnull(a.importPayback,0) when 1 then isnull(a.money1,0) else isnull(k.money1,0) end) money1 "&_
"   from contract a WITH(NOLOCK) "&_
"   left join (select p.contract, isnull(sum(p.money1*dbo.gethl(c.bz,isnull(p.date5,c.date3),getdate())),0) as money1 "&_
"from payback p WITH(NOLOCK) inner join contract c WITH(NOLOCK) on p.contract=c.ord and p.del=1 and p.complete='3' and p.completeType<>7 and p.contract="& htord &" group by p.contract"&_
"   ) k on k.contract=a.ord where a.ord="& htord &""
set rs = conn.execute(sql)
if rs.eof = false then
money_hkall =zbcdbl( rs("money1"))
end if
rs.close
set rs = nothing
end if
if money_hkall&"" = "" then money_hkall = 0 else money_hkall = cdbl(money_hkall)
getHtDzMoney = money_hkall
end function
function getHtDzYMoney(htord)
dim rs, money_hkall
money_hkall = 0
If ZBRuntime.MC(23000) Or ZBRuntime.MC(23001) Then
set rs = conn.execute("select isnull(sum(p.money1),0) as money1 from payback p WITH(NOLOCK) inner join contract c WITH(NOLOCK) on p.contract=c.ord and p.contract="& htord &" and p.del=1 and p.complete='3' and p.CompleteType<>7")
if rs.eof = false then
money_hkall =zbcdbl( rs("money1"))
end if
rs.close
set rs = nothing
end if
if money_hkall&"" = "" then money_hkall = 0 else money_hkall = cdbl(money_hkall)
getHtDzYMoney = money_hkall
end function
function getHtBackMLMoney(htord)
dim rs, mlmoney
mlmoney = 0
If ZBRuntime.MC(23000) Or ZBRuntime.MC(23001) Then
set rs = conn.execute("select isnull(sum(p.money1),0) as money1 from payback p WITH(NOLOCK) inner join contract c WITH(NOLOCK) on p.contract=c.ord and p.contract="& htord &" and p.del=1 and p.complete='3' and p.CompleteType=7")
if rs.eof = false then
mlmoney =zbcdbl( rs("money1"))
end if
rs.close
set rs = nothing
end if
if mlmoney&"" = "" then mlmoney = 0 else mlmoney = cdbl(mlmoney)
getHtBackMLMoney = mlmoney
end function
Function GetSetopenValue(keysign,  nullvalue)
dim rs, ret
ret = ""
if keysign&""<>"" then
set rs = conn.execute("select intro from setopen WITH(NOLOCK) where sort1="& keysign)
If rs.eof = false then
ret = rs("intro")
end if
end if
if ret&"" = "" then ret = nullvalue
GetSetopenValue = ret
end function
function getHtMlMoney(htord)
dim mlMoney, num2018030701
mlMoney = 0
if htord &"" = "" then htord = 0
if htord>0 then
num2018030701 = GetSetopenValue(2018030701, 2)
select case num2018030701&""
case "1"
mlMoney = getHtYhhMoney(htord) - getHtTaxValue(htord) + getHtThTaxValue(htord) - getHtProCb(htord) -getHtFyMoney(htord) -getHtThMoney(htord) + getHtThCost(htord)
'case "1"
case "2"
mlMoney = getHtYhhMoney(htord) - getHtProCb(htord) -getHtFyMoney(htord) -getHtThMoney(htord) + getHtThCost(htord)
'case "2"
case "3"
mlMoney = getHtDzMoney(htord) - getHtTaxValue(htord) + getHtThTaxValue(htord) - getHtProCb(htord) -getHtFyMoney(htord) -getHtSTMoney(htord) + getHtThCost(htord)
'case "3"
case "4"
mlMoney = getHtDzMoney(htord) - getHtProCb(htord) -getHtFyMoney(htord) -getHtSTMoney(htord) + getHtThCost(htord)
'case "4"
end select
end if
getHtMlMoney = mlMoney
end function
function getHtMlMoneyX(htord,ftype)
dim mlMoney, num2018030701
mlMoney = 0
if htord &"" = "" then htord = 0
if htord>0 then
num2018030701 = GetSetopenValue(2018030701, 2)
Select Case ftype
Case "" : mlMoney = getHtMlMoney(htord)
Case Else:
select case num2018030701&""
case "1"
mlMoney = getHtYhhMoney(htord) - getHtTaxValue(htord) + getHtThTaxValue(htord) - getHtProCbX(htord,ftype) -getHtFyMoney(htord) -getHtThMoney(htord) + getHtThJinJiaCost(htord)
'case "1"
case "2"
mlMoney = getHtYhhMoney(htord) - getHtProCbX(htord,ftype) -getHtFyMoney(htord) -getHtThMoney(htord) + getHtThJinJiaCost(htord)
'case "2"
case "3"
mlMoney = getHtDzMoney(htord) - getHtTaxValue(htord) + getHtThTaxValue(htord) - getHtProCbX(htord,ftype) -getHtFyMoney(htord) -getHtSTMoney(htord) + getHtThJinJiaCost(htord)
'case "3"
case "4"
mlMoney = getHtDzMoney(htord) - getHtProCbX(htord,ftype) -getHtFyMoney(htord) -getHtSTMoney(htord) + getHtThJinJiaCost(htord)
'case "4"
end select
End Select
end if
getHtMlMoneyX = mlMoney
end function
function getHtMlMoney2(ByVal formulaIdx, ByVal htMoney, ByVal dzMoney, ByVal taxValue, ByVal thTaxValue, ByVal proCb, ByVal fyMoney, ByVal thMoney, ByVal sthMoney, ByVal thCost)
dim mlMoney
mlMoney = 0
if formulaIdx &"" = "" then formulaIdx = 0 else formulaIdx = cdbl(formulaIdx)
if htMoney &"" = "" then htMoney = 0 else htMoney = cdbl(htMoney)
if dzMoney &"" = "" then dzMoney = 0 else dzMoney = cdbl(dzMoney)
if taxValue &"" = "" then taxValue = 0 else taxValue = cdbl(taxValue)
if thTaxValue &"" = "" then thTaxValue = 0 else thTaxValue = cdbl(thTaxValue)
if proCb &"" = "" then proCb = 0 else proCb = cdbl(proCb)
if fyMoney &"" = "" then fyMoney = 0 else fyMoney = cdbl(fyMoney)
if thMoney &"" = "" then thMoney = 0 else thMoney = cdbl(thMoney)
if sthMoney &"" = "" then sthMoney = 0 else sthMoney = cdbl(sthMoney)
if thCost &"" = "" then thCost = 0 else thCost = cdbl(thCost)
if formulaIdx>0 then
select case formulaIdx&""
case "1"
mlMoney = htMoney - taxValue + thTaxValue - proCb -fyMoney -thMoney + thCost
'case "1"
case "2"
mlMoney = htMoney - proCb -fyMoney -thMoney + thCost
'case "2"
case "3"
mlMoney = dzMoney - taxValue + thTaxValue - proCb -fyMoney - sthMoney + thCost
'case "3"
case "4"
mlMoney = dzMoney - proCb -fyMoney - sthMoney + thCost
'case "4"
end select
end if
getHtMlMoney2 = mlMoney
end function
function getHtMlRate(htord)
dim money2, mlRate, total_th,  num2018030701
mlRate = 0 : total_th = 0
num2018030701 = GetSetopenValue(2018030701, 2)
if htord &"" = "" then htord = 0
select case num2018030701&""
case "1", "2":
money2 = getHtYhhMoney(htord)
total_th = getHtThMoney(htord)
case "3", "4":
money2 = getHtDzMoney(htord)
total_th = getHtSTMoney(htord)
end select
if money2&"" = "" then money2 = 0 else money2 = cdbl(money2)
if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
if money2<>0 and (money2-total_th)<>0 then
'if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
mlRate=getHtMlMoney(htord)*100/(CDbl(money2)-CDbl(total_th))
'if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
end if
if mlRate&"" = "" then mlRate = 0
getHtMlRate = mlRate
end function
function getHtMlRateX(htord, ftype)
dim money2, mlRate, total_th,  num2018030701
mlRate = 0 : total_th = 0
num2018030701 = GetSetopenValue(2018030701, 2)
if htord &"" = "" then htord = 0
select case num2018030701&""
case "1", "2":
money2 = getHtYhhMoney(htord)
total_th = getHtThMoney(htord)
case "3", "4":
money2 = getHtDzMoney(htord)
total_th = getHtSTMoney(htord)
end select
if money2&"" = "" then money2 = 0 else money2 = cdbl(money2)
if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
if money2<>0 and (money2-total_th)<>0 then
'if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
mlRate=getHtMlMoneyX(htord, ftype)*100/(CDbl(money2)-CDbl(total_th))
'if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
end if
if mlRate&"" = "" then mlRate = 0
getHtMlRateX = mlRate
end function
function getHtMlRate2(ByVal htord, ByVal mlMoney)
dim money2, mlRate, total_th,  num2018030701
mlRate = 0 : total_th = 0
if htord &"" = "" then htord = 0
if mlMoney &"" = "" then mlMoney = 0 else mlMoney = cdbl(mlMoney)
num2018030701 = GetSetopenValue(2018030701, 2)
'if htord &"" = "" then htord = 0
select case num2018030701&""
case "1", "2":
money2 = getHtYhhMoney(htord)
total_th = getHtThMoney(htord)
case "3", "4":
money2 = getHtDzMoney(htord)
total_th = getHtSTMoney(htord)
end select
if money2&"" = "" then money2 = 0 else money2 = cdbl(money2)
if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
if money2<>0 and (money2-total_th)<>0 then
'if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
mlRate=mlMoney*100/(CDbl(money2)-CDbl(total_th))
end if
if mlRate&"" = "" then mlRate = 0
getHtMlRate2 = mlRate
end function
function getHtMlRate3(ByVal formulaIdx, ByVal mlMoney, ByVal htMoney, ByVal dzMoney, ByVal thMoney, ByVal sthMoney)
dim money2, mlRate, moneyTotal
mlRate = 0 : moneyTotal = 0
if formulaIdx &"" = "" then formulaIdx = 0 else formulaIdx = cdbl(formulaIdx)
if formulaIdx>0 then
if mlMoney &"" = "" then mlMoney = 0 else mlMoney = cdbl(mlMoney)
if htMoney &"" = "" then htMoney = 0 else htMoney = cdbl(htMoney)
if dzMoney &"" = "" then dzMoney = 0 else dzMoney = cdbl(dzMoney)
if thMoney &"" = "" then thMoney = 0 else thMoney = cdbl(thMoney)
if sthMoney &"" = "" then sthMoney = 0 else sthMoney = cdbl(sthMoney)
select case formulaIdx
case 1, 2 : moneyTotal = htMoney
case 3, 4 :
moneyTotal = dzMoney : thMoney = sthMoney
end select
if moneyTotal<>0 And (moneyTotal-thMoney)<>0 then
'end select
mlRate=mlMoney*100/(moneyTotal-thMoney)
'end select
else
mlRate=0
end if
end if
getHtMlRate3 = mlRate
end function
function getHtMlMoneySql(ByVal formulaIdx, ByVal htMoneyField, ByVal dzMoneyField, ByVal taxValueField, ByVal thTaxValueField, ByVal proCbField, ByVal fyMoneyField, ByVal thMoneyField, ByVal sthMoneyField, ByVal thCostField)
dim headerSql
headerSql = ""
if formulaIdx>0 then
select case formulaIdx&""
case "1"
headerSql = htMoneyField &" - "& taxValueField &" + "& thTaxValueField &" - "& proCbField &" - "& fyMoneyField &" - "& thMoneyField &" + "& thCostField
'case "1"
case "2"
headerSql = htMoneyField &" - "& proCbField &" - "& fyMoneyField &" - "& thMoneyField &" + "& thCostField
'case "2"
case "3"
headerSql = dzMoneyField &" - "& taxValueField &" + "& thTaxValueField &" - "& proCbField &" - "& fyMoneyField &" - "& sthMoneyField &" + "& thCostField
'case "3"
case "4"
headerSql = dzMoneyField &" - "& proCbField &" - "& fyMoneyField &" - "& sthMoneyField &" + "& thCostField
'case "4"
end select
else
headerSql = "0"
end if
getHtMlMoneySql = "("& headerSql &")"
end function
function getHtMlRateSql(ByVal formulaIdx, ByVal mlMoneyField, ByVal htMoneyField, ByVal dzMoneyField, ByVal thMoneyField, ByVal sthMoneyField)
dim headerSql, moneyTotalField
headerSql = "" : moneyTotalField = ""
if formulaIdx &"" = "" then formulaIdx = 0 else formulaIdx = cdbl(formulaIdx)
if formulaIdx>0 then
select case formulaIdx
case 1, 2 : moneyTotalField = htMoneyField
case 3, 4 :
moneyTotalField = dzMoneyField : thMoneyField = sthMoneyField
end select
headerSql = "(CASE WHEN ( ("& moneyTotalField &"-"& thMoneyField &")<>0) THEN (cast("& mlMoneyField &" *100 as decimal(25,12))/("& moneyTotalField &"-"& thMoneyField &")) ELSE 0 END)"
'end select
else
headerSql = "0"
end if
getHtMlRateSql = headerSql
end function
function mlMoneySql(tjtabName, formulaIdx)
dim sql
sql = ""
select case tjtabName
case "product_gather"
sql = getHtMlMoneySql(formulaIdx, "出库总额_DONUM_DOSUM", "到账金额_DONUM_DOSUM", "税额_DONUM_DOSUM", "退货税额_DONUM_ID", "出库成本_DONUM_DOSUM","0","退货总额_DONUM_DOSUM", "实退货金额_DONUM_ID", "退货成本_DONUM_DOSUM")
case "product_ProfitsList"
sql = getHtMlMoneySql(formulaIdx, "销售总额_DONUM_DOSUM", "到账金额_DONUM_DOSUM", "税额_DONUM_DOSUM", "退货税额_DONUM_ID", "成本总价_DONUM_DOSUM","0","退货总额_DONUM_DOSUM", "实退货金额_DONUM_ID", "退货成本_DONUM_DOSUM")
case "kh_jx7"
sql = getHtMlMoneySql(formulaIdx, "contractTotal", "htDzMoney", "taxTotal", "thTaxTotal", "productCost","payTotal","thTotal", "sthTotal", "thCost")
end select
mlMoneySql = sql
end function
function mlRateMoneySql(tjtabName, formulaIdx)
dim sql
sql = ""
select case tjtabName
case "product_gather"
sql = getHtMlRateSql(formulaIdx, mlMoneySql(tjtabName, formulaIdx),"出库总额_DONUM_DOSUM", "到账金额_DONUM_DOSUM", "退货总额_DONUM_DOSUM", "实退货金额_DONUM_ID")
case "product_ProfitsList"
sql = getHtMlRateSql(formulaIdx, mlMoneySql(tjtabName, formulaIdx),"销售总额_DONUM_DOSUM", "到账金额_DONUM_DOSUM", "退货总额_DONUM_DOSUM", "实退货金额_DONUM_ID")
end select
mlRateMoneySql = sql
end function
function htdzMoneySql(tjtabName, str_Result)
dim sql
sql = ""
select case tjtabName
case "product_gather", "product_ProfitsList"
sql = ",ISNULL((case "& showSkMoney &" when 1  then ( " & vbcrlf &_
"""      select isnull(sum( (case when c.paybackMode=2 then pl.money1*dbo.gethl(c.bz,isnull(p.date5,c.date3),getdate())   when c.paybackMode=0 or (c.paybackMode=1 and htl.id<>maxdetial.id) then 0  else p.money1*dbo.gethl(c.bz,isnull(p.date5,c.date3),getdate()) end )),0) as money1 from payback p inner join contract c on p.contract=c.ord and p.del=1 and p.complete='3' inner join contractlist htl on  htl.contract=c.ord and htl.del=1 and htl.ord=a.ord and htl.unit=b.ord  INNER JOIN kuoutlist2 ki WITH(NOLOCK) ON ki.contractlist=htl.id and ki.sort1=1 and ki.del=1 and ki.ord=htl.ord "& iif(tjtabName = "product_ProfitsList","and ki.id = d.id","" )&" inner join kuout on ki.kuout=kuout.ord "& replace(replace(str_Result,"d.","ki."),"ki.sort1","kuout.sort1") &" inner join (select max(id) id,contract from contractlist where del=1 group by contract) maxdetial on maxdetial.contract = c.ord  left join paybacklist pl on pl.payback=p.ord and  pl.contractlist=htl.id  and pl.product=htl.ord  and pl.product=a.ord " & vbcrlf &_
") else 0 end),0) AS 到账金额_DONUM_DOSUM"
case "salesProfit_1"
sql = ",htDzMoney=ISNULL((case "& showSkMoney &" when 1  then ( " & vbcrlf &_
"  select isnull(sum(p.money1*dbo.gethl(e.bz,isnull(p.date5,e.date3),getdate())),0) as money1 from payback p inner join contract e on p.contract=e.ord and e.cateid=a.ord and p.del=1 and p.complete='3' "& str_Result &" " & vbcrlf &_
") else 0 end),0) "
case "kh_jx7"
sql = "    left join ("&_
"          select p.contract,isnull((case "& showSkMoney &" when 1  then (sum(p.money1*dbo.gethl(c.bz,isnull(p.date5,c.date3),getdate()))) else 0 end),0) as payMoney from payback p inner join contract c on p.contract=c.ord and p.del=1 and p.complete='3' group by p.contract " & vbcrlf &_
"  ) c on c.contract=y.ord "
end select
htdzMoneySql = sql
end function
function taxValueSql(tjtabName, str_Result)
dim sql
sql = ""
select case tjtabName
case "product_gather", "product_ProfitsList"
sql = ",ISNULL((case "& showHtMoney &" when 1  then ( " & vbcrlf &_
"                            ""      select ISNULL(SUM(htl.price1*ki.num1*(htl.taxRate*0.01) * isnull(h.hl,1)),0) from contractlist htl INNER JOIN contract ht ON ht.del=1 AND htl.del=1 AND htl.contract=ht.ord AND htl.ord=a.ord and htl.unit=b.ord INNER JOIN kuoutlist2 ki on ki.contractlist=htl.id and ki.sort1=1 and ki.del=1 and ki.ord=htl.ord "& iif(tjtabName = "product_ProfitsList","and ki.id = d.id","" )&" inner join kuout on ki.kuout=kuout.ord "& str_Result &"  left JOIN hl h WITH(NOLOCK) ON ht.bz = h.bz and ht.date3 = h.date1 " & vbcrlf &_
") else 0 end),0) AS 税额_DONUM_DOSUM "
case "salesProfit_1"
sql = ",taxTotal=isnull((case "& showHtMoney &" when 1  then ( " & vbcrlf &_
"  select ISNULL(SUM(htl.taxValue * isnull(h.hl,1)),0) from contractlist htl INNER JOIN contract e ON e.del=1 and htl.contract=e.ord AND htl.del=1 AND e.cateid=a.ord left JOIN hl h WITH(NOLOCK) ON e.bz = h.bz and e.date3 = h.date1 where 1=1 "& str_Result &" group by e.cateid" & vbcrlf &_
") else 0 end),0) "
case "salesProfit_2"
sql = ",taxTotal=isnull((case "& showHtMoney &" when 1  then (" & vbcrlf &_
"select sum(htl.taxValue * isnull(h.hl,1)) taxValue from contractlist htl INNER JOIN contract e ON e.del=1 and htl.contract=e.ord left JOIN hl h WITH(NOLOCK) ON e.bz = h.bz and e.date3 = h.date1 where htl.del=1 and htl.contract=a.ord " & vbcrlf &_
") else 0 end),0) "
case "kh_jx7"
sql = "select htl.contract,sum(htl.taxValue * isnull(h.hl,1)) taxValue from contractlist htl inner join contract y on y.del=1 and htl.del=1 and htl.contract=y.ord left JOIN hl h WITH(NOLOCK) ON y.bz = h.bz and y.date3 = h.date1 " & str_Result &" group by htl.contract "
end select
taxValueSql = sql
end function
function thTaxValueSql(tjtabName, str_Result)
dim sql
sql = ""
select case tjtabName
case "product_gather", "product_ProfitsList"
sql = ",ISNULL((case "& showThMoney &" when 1  then ( " & vbcrlf &_
"  select ISNULL(SUM(thl.num1 * (CASE ISNULL(ctl.num1,0) WHEN 0 THEN 0 ELSE ctl.taxValue/ctl.num1 END)) ,0)  " & vbcrlf &_
"  FROM contractth th   " & vbcrlf &_
"  INNER JOIN contractthlist thl ON thl.caigou=th.ord AND th.del=1 and thl.del=1  " & vbcrlf &_
"   INNER JOIN CONTRACT ht ON ht.ord = thl.contract " & vbcrlf &_
"  INNER JOIN contractlist ctl ON thl.contractlist=ctl.id AND thl.contract=ctl.contract "  & vbcrlf &_
"  INNER JOIN kuoutlist2 ki on ki.contractlist=ctl.id and ki.sort1=1 and ki.del=1 and ki.ord=ctl.ord "& iif(tjtabName = "product_ProfitsList","and ki.id = d.id","" )&" inner join kuout on ki.kuout=kuout.ord "& str_Result &"  " & vbcrlf &_
"  WHERE thl.ord=a.ord and thl.unit=b.ord " & vbcrlf &_
") else 0 end),0) AS 退货税额_DONUM_ID "
case "salesProfit_1"
sql = ",thTaxTotal=isnull((case "& showThMoney &" when 1  then ( " & vbcrlf &_
"  select ISNULL(SUM(thl.num1 * (CASE ISNULL(ctl.num1,0) WHEN 0 THEN 0 ELSE ctl.taxValue/ctl.num1 END)) ,0)  " & vbcrlf &_
"  FROM contractth th   " & vbcrlf &_
"  INNER JOIN contractthlist thl ON thl.caigou=th.ord AND th.del=1 and thl.del=1  " & vbcrlf &_
"  INNER JOIN contractlist ctl ON thl.contractlist=ctl.id AND thl.contract=ctl.contract " & vbcrlf &_
"  INNER JOIN contract e ON ctl.contract=e.ord "& str_Result &" " & vbcrlf &_
"  WHERE e.cateid=a.ord " & vbcrlf &_
") else 0 end),0)"
case "salesProfit_2"
sql = ",thTaxTotal=isnull((case "& showThMoney &" when 1  then (" & vbcrlf &_
"select SUM(thl.num1 * (CASE ISNULL(ctl.num1,0) WHEN 0 THEN 0 ELSE ctl.taxValue/ctl.num1 END)) taxValue "& vbcrlf &_
"FROM contractth th  "& vbcrlf &_
"INNER JOIN contractthlist thl ON thl.caigou=th.ord AND th.del=1 and thl.del=1 and thl.contract=a.ord "& vbcrlf &_
"INNER JOIN contractlist ctl ON thl.contractlist=ctl.id AND thl.contract=ctl.contract "& vbcrlf &_
"GROUP by thl.contract " & vbcrlf &_
") else 0 end),0) "
end select
thTaxValueSql = sql
end function
function thMoneySql(tjtabName, str_Result)
dim sql
sql = ""
if str_Result&"" = "" then str_Result = ""
select case tjtabName
case "salesProfit_1"
sql = ",thTotal=ISNULL((case "& showThMoney &" when 1  then (select SUM(thl.money1*dbo.gethl(thl.bz,thl.date1,getdate())) from contractth th INNER JOIN contractthlist thl ON thl.caigou=th.ord AND th.del=1 and thl.del=1 inner join contract e on thl.contract=e.ord and e.del=1 and e.cateid=a.ord "& str_Result &") else 0 end),0) "
case "kh_jx7"
sql = "ISNULL((case "& showThMoney &" when 1  then (select isnull(sum(money2),0) as money2 from contractth where company=x.ord and del=1 "&str_Result&") else 0 end),0)"
end select
thMoneySql = sql
end function
function sthMoneySql(tjtabName, str_Result)
dim sql
sql = ""
select case tjtabName
case "product_gather", "product_ProfitsList"
sql = ",ISNULL((case "& showThMoney &" when 1  then ( " & vbcrlf &_
"  ISNULL((select SUM(thl.money1*dbo.gethl(thl.bz,thl.date1,getdate())) from contractth th INNER JOIN contractthlist thl ON thl.caigou=th.ord AND th.del=1 and thl.del=1 and thl.ord=a.ord and thl.unit=b.ord " & vbcrlf &_
"  INNER JOIN kuoutlist2 ki on ki.contractlist=thl.contractlist and ki.sort1=1 and ki.del=1 and ki.ord=thl.ord inner join kuout on ki.kuout=kuout.ord "& str_Result &" ),0) -  " & vbcrlf &_
"  ISNULL((select isnull(sum(thd.money2*dbo.gethl(th.bz,th.date3,getdate())),0) from contractthListDetail thd  " & vbcrlf &_
"  inner join contractth th on thd.contractth = th.ord and th.del=1 and th.sp=0  " & vbcrlf &_
"  and thd.thtype='GOODS' and thd.ord=a.ord and thd.unit=b.ord " & vbcrlf &_
"  INNER JOIN kuoutlist2 ki on ki.contractlist=thd.contractlist and ki.sort1=1 and ki.del=1 and ki.ord=thd.ord inner join kuout on ki.kuout=kuout.ord "& str_Result &"  " & vbcrlf &_
"),0) ) else 0 end),0) AS 实退货金额_DONUM_ID  "
case "salesProfit_1"
sql = ",sthTotal=ISNULL((case "& showThMoney &" when 1  then ( " & vbcrlf &_
"  ISNULL((select SUM(thl.money1*dbo.gethl(thl.bz,thl.date1,getdate())) from contractth th INNER JOIN contractthlist thl ON thl.caigou=th.ord AND th.del=1 and thl.del=1 inner join contract e on thl.contract=e.ord and e.del=1 and e.cateid=a.ord "& str_Result &"),0) -  " & vbcrlf &_
"sql = "",sthTotal=ISNULL((case ""& showThMoney &"" when 1  then ( """ & vbcrlf &_
"ISNULL((select isnull(sum(thd.money2*dbo.gethl(th.bz,th.date3,getdate())),0) from contractthListDetail thd "  & vbcrlf &_
"  inner join contractth th on thd.contractth = th.ord and th.del=1 and isnull(th.sp,0)=0 " & vbcrlf &_
"  inner join contract e on thd.contract=e.ord and e.del=1 and e.cateid=a.ord "& str_Result &" " & vbcrlf &_
"  and thd.thtype='GOODS'),0) ) else 0 end),0)  "
case "kh_jx7"
sql = "ISNULL((case "& showThMoney &" when 1  then (sum(isnull(thmoney1,0)-isnull(thmoney2,0))) else 0 end),0)"
'case "kh_jx7"
end select
sthMoneySql = sql
end function
function tdTaxValueHtml(tjtabName, outExcel, formulaIdx, taxValue, thTaxValue)
dim ret
ret = ""
if formulaIdx&"" = "" then formulaIdx = 2
if taxValue&"" = "" then taxValue = 0 else taxValue = cdbl(taxValue)
if thTaxValue&"" = "" then thTaxValue = 0 else thTaxValue = cdbl(thTaxValue)
select case formulaIdx
case 1, 3
if outExcel = 0 then
ret = "<div title=""合同税额："& Formatnumber(taxValue,num_dot_xs,-1) &"&#13;退货税额："& Formatnumber(thTaxValue,num_dot_xs,-1) &""">"& Formatnumber((taxValue - thTaxValue),num_dot_xs,-1) &"</div>"
'if outExcel = 0 then
else
ret = Formatnumber((taxValue - thTaxValue),num_dot_xs,-1)
'if outExcel = 0 then
end if
case 2, 4
if outExcel = 0 then
ret = "<div >"& Formatnumber(taxValue,num_dot_xs,-1) &"</div>"
'if outExcel = 0 then
else
ret = Formatnumber(taxValue,num_dot_xs,-1)
'if outExcel = 0 then
end if
end select
tdTaxValueHtml = ret
end function
function tdThMoneyHtml(tjtabName, outExcel, formulaIdx, thMoney, sthMoney)
dim ret
ret = ""
if formulaIdx&"" = "" then formulaIdx = 2
if thMoney&"" = "" then thMoney = 0 else thMoney = cdbl(thMoney)
if sthMoney&"" = "" then sthMoney = 0 else sthMoney = cdbl(sthMoney)
select case formulaIdx
case 1, 2
if outExcel = 0 then
ret = "<div>"& Formatnumber(thMoney,num_dot_xs,-1) &"</div>"
'if outExcel = 0 then
else
ret = Formatnumber(thMoney,num_dot_xs,-1)
'if outExcel = 0 then
end if
case 3, 4
if outExcel = 0 then
ret = "<div title=""退货总额："& Formatnumber(thMoney,num_dot_xs,-1) &"&#13;未退款退货总额："& Formatnumber((thMoney-sthMoney),num_dot_xs,-1) &""">"& Formatnumber(sthMoney,num_dot_xs,-1) &"</div>"
'if outExcel = 0 then
else
ret = Formatnumber(sthMoney,num_dot_xs,-1)
'if outExcel = 0 then
end if
end select
tdThMoneyHtml = ret
end function
Function SubBillCount(htord)
dim rs, sql, ret
ret = 0
sql = "SELECT ISNULL(SUM(t.num1),0) num1 FROM ( "&_
"  SELECT TOP 1 1 num1 FROM kuout WITH(NOLOCK) WHERE del=1 AND sort1 IN(1,4) AND order1="& htord &" "&_
"  UNION ALL  "&_
"  SELECT TOP 1 1 num1 FROM kuoutlist kl WITH(NOLOCK) inner join kuout k WITH(NOLOCK) on k.ord = kl.kuout WHERE k.del=1 AND k.sort1 IN(1,4) AND kl.Fromid="& htord &" "&_
"  UNION ALL  "&_
"  SELECT TOP 1 1 num1 FROM send a WITH(NOLOCK) LEFT JOIN kuout b WITH(NOLOCK) ON b.ord=a.kuout WHERE a.del=1 AND ISNULL(b.sort1,0) IN(0,1,4) AND a.order1="& htord &" "&_
"  UNION ALL  "&_
"  SELECT TOP 1 1 num1 FROM payback WITH(NOLOCK) WHERE del=1 AND contract="& htord &" "&_
"  UNION ALL  "&_
"  SELECT TOP 1 1 num1 FROM paybackInvoice WITH(NOLOCK) WHERE del=1 AND fromType='CONTRACT' AND fromid="& htord &" "&_
") t"
ret = conn.execute(sql)(0)
SubBillCount = ret
end function
Function SubBillCount2(htord, con)
dim rs, sql, ret
ret = 0
sql = "SELECT ISNULL(SUM(t.num1),0) num1 FROM ( "&_
"  SELECT TOP 1 1 num1 FROM kuout WITH(NOLOCK) WHERE del=1 AND sort1 IN(1,4) AND order1="& htord &" "&_
"  UNION ALL  "&_
"  SELECT TOP 1 1 num1 FROM payback WITH(NOLOCK) WHERE del=1 AND contract="& htord &" "&_
"  UNION ALL  "&_
"  SELECT TOP 1 1 num1 FROM paybackInvoice WITH(NOLOCK) WHERE del=1 AND fromType='CONTRACT' AND fromid="& htord &" "&_
"  UNION ALL "&_
"  SELECT TOP 1 1 num1 FROM contractth a WITH(NOLOCK) "&_
"  INNER JOIN contractthlist b WITH(NOLOCK) ON b.caigou=a.ord AND a.del IN(1,3) AND ISNULL(a.sp,0)<>-1 AND b.del=1 AND b.contract="& htord &" "&_
"  SELECT TOP 1 1 num1 FROM contractth a WITH(NOLOCK) "&_
"  UNION ALL "&_
"  SELECT TOP 1 1 num1 FROM payout2 a WITH(NOLOCK)  "&_
"  INNER join contractth b WITH(NOLOCK) on a.contractth=b.ord  "&_
"  inner join ( "&_
"          SELECT contractth,contract  "&_
"          FROM contractthlistDetail WITH(NOLOCK) where contract>0 and (thtype='MONEY' or thtype='GOODS_MONEY')  "&_
"          GROUP by contractth,contract "&_
"  ) k ON K.contractth = b.ord  "&_
"  where a.del=1 and k.contract="& htord &" "&_
"  UNION ALL "&_
"  SELECT TOP 1 1 num1 FROM pay WITH(NOLOCK) WHERE del=1 AND complete in(3,0) AND contract="& htord &" "&_
") t"
ret = con.execute(sql)(0)
SubBillCount2 = ret
end function
Function GetContractBz(htord)
dim rs, ret
ret = 0
Set rs = conn.execute("select bz from contract WITH(NOLOCK) where ord="& htord)
If rs.eof = False Then
bz = rs("bz")
end if
rs.close
set rs = nothing
If bz&"" = "" Then bz = 0
ret = bz
GetContractBz = ret
end function
Function GetHzKpHtInvoiceType(htord)
dim rs, ret
ret = 0
Set rs = conn.execute("select isnull(invoicePlanType,0) invoicePlanType from contract WITH(NOLOCK) where invoiceMode=1 and ord="& htord)
If rs.eof = False Then
ret = rs("invoicePlanType")
end if
rs.close
set rs = nothing
GetHzKpHtInvoiceType = ret
end function
function IsOpenContractModifyTactics
set Modifyrs=server.CreateObject("adodb.recordset")
sql="select intro from setopen where sort1=2020021801"
Modifyrs.open sql,conn,1,1
if Modifyrs.eof then
num2020021801=0
else
num2020021801=Modifyrs("intro")
end if
Modifyrs.close
set Modifyrs=Nothing
IsOpenContractModifyTactics = (num2020021801="1")
end function
Function CheckBillCanDelete(chkType, htords, htcateids)
dim rs, rs2, sql, ret, nowCate, open_7_3, intro_7_3, open_32_3, intro_32_3, open_33_3, intro_33_3, isGoOn, cateids, canDelOrds
ret = "ALL" : canDelOrds = ""
nowCate = session("personzbintel2007")
If nowCate&"" = "" Then nowCate = 0
If htords&"" = "" Then htords = 0
if htcateids&"" = "" then
Set rs = conn.execute("select distinct cateid from contract where ord in("& htords &")")
While rs.eof = False
if htcateids&""<>"" then htcateids = htcateids &","
htcateids = htcateids & rs("cateid")
rs.movenext
wend
rs.close
set rs = nothing
end if
If htcateids&"" = "" Then htcateids = 0
cateids = ""
Select Case chkType
Case "payback"
sql = "select top 1 1 from payback where del=1 and complete<3 and contract in("& htords &") "
isGoOn = (conn.execute(sql).eof=false)
if isGoOn then
set rs = conn.execute("select qx_open,qx_intro from power WITH(NOLOCK) where ord="&nowCate&" and sort1=7 and sort2=3")
if rs.eof = false then
open_7_3=rs("qx_open") : intro_7_3=rs("qx_intro")
end if
rs.close
set rs=nothing
If open_7_3&"" = "" Then open_7_3 = 0
If intro_7_3&"" = "" Then intro_7_3 = "-222" Else intro_7_3 = replace(intro_7_3&""," ","")
If open_7_3&"" = "" Then open_7_3 = 0
if open_7_3=3 then
isGoOn = True
elseif open_7_3=1 then
isGoOn = False
Set rs = conn.execute("SELECT ISNULL(STUFF((SELECT ','+CAST(a.cateid AS VARCHAR(10)) FROM (SELECT id,CAST(short_str AS INT) cateid FROM dbo.split('"& intro_7_3 &"',',')) a INNER JOIN (SELECT id,CAST(short_str AS INT) cateid FROM dbo.split('"& htcateids &"',',')) b ON a.cateid=b.cateid AND a.cateid>0 for xml path('')),1,1,''),'') ")
If rs.eof = False Then
if rs(0)&""<>"" then
cateids = rs(0)&""
isGoOn = True
end if
end if
rs.close
set rs = nothing
else
isGoOn = False
end if
if isGoOn and conn.execute("select 1 from home_usConfig where name='Payback_Invoice_Voucher_Constraint' and nvalue=1").eof=false then
if  conn.execute("select 1 from payback pb inner join dbo.collocation c on c.del=1 and c.sort1 = 6 AND c.clstype = 6009 AND pb.ord = c.erpOrd  where pb.contract in ("& htords &") and pb.del=1 and pb.complete <3 ").eof=false then
isGoOn = False
end if
end if
if isGoOn then
isGoOn = False
If cateids&"" = "" Then cateids = "0"
sql = "SELECT ISNULL(STUFF((select ','+cast(ord as varchar(15)) from payback where del=1 and complete<3 and contract in("& htords &") and ('"& cateids &"'='0' or cateid in("& cateids &")) for xml path('')),1,1,''),'') "
'If cateids&"" = "" Then cateids = "0"
set rs = conn.execute(sql)
If rs.eof = False Then
if rs(0)&""<>"" then
canDelOrds = rs(0)&""
isGoOn = True
end if
end if
rs.close
set rs = nothing
end if
end if
if isGoOn then
ret = canDelOrds
else
ret = "False"
end if
case "paybackInvoice"
sql = "select top 1 1 from paybackinvoice where del=1 and isinvoiced=0 and fromType='CONTRACT' and fromid in ("& htords &") "
isGoOn = (conn.execute(sql).eof=false)
if isGoOn then
set rs = conn.execute("select qx_open,qx_intro from power WITH(NOLOCK) where ord="&nowCate&" and sort1=7001 and sort2=3")
if rs.eof = false then
open_7001_3=rs("qx_open") : intro_7001_3=rs("qx_intro")
end if
rs.close
set rs=nothing
If open_7001_3&"" = "" Then open_7001_3 = 0
If intro_7001_3&"" = "" Then intro_7001_3 = "-222" Else intro_7001_3 = replace(intro_7001_3&""," ","")
'If open_7001_3&"" = "" Then open_7001_3 = 0
if open_7001_3=3 then
isGoOn = True
elseif open_7001_3=1 then
isGoOn = False
Set rs = conn.execute("SELECT ISNULL(STUFF((SELECT ','+CAST(a.cateid AS VARCHAR(10)) FROM (SELECT id,CAST(short_str AS INT) cateid FROM dbo.split('"& intro_7001_3 &"',',')) a INNER JOIN (SELECT id,CAST(short_str AS INT) cateid FROM dbo.split('"& htcateids &"',',')) b ON a.cateid=b.cateid AND a.cateid>0 for xml path('')),1,1,''),'') ")
If rs.eof = False Then
if rs(0)&""<>"" then
cateids = rs(0)&""
isGoOn = True
end if
end if
rs.close
set rs = nothing
else
isGoOn = False
end if
if isGoOn then
isGoOn = False
If cateids&"" = "" Then cateids = "0"
sql = "SELECT ISNULL(STUFF((select ','+cast(id as varchar(15)) from paybackinvoice where del=1 and isinvoiced=0 and fromType='CONTRACT' and fromid in("& htords &") and ('"& cateids &"'='0' or cateid in("& cateids &")) for xml path('')),1,1,''),'') "
'If cateids&"" = "" Then cateids = "0"
set rs = conn.execute(sql)
If rs.eof = False Then
if rs(0)&""<>"" then
canDelOrds = rs(0)&""
isGoOn = True
end if
end if
rs.close
set rs = nothing
end if
end if
if isGoOn then
ret = canDelOrds
else
ret = "False"
end if
Case "kuout"
isGoOn = True
If sdk.getSqlValue("select count(1) from kuout where del=1 and complete1<3 and sort1 in(1,4) and order1 in("& htords &")" , 0)&"" = "0" Then
isGoOn = False
end if
if isGoOn then
set rs = conn.execute("select qx_open,qx_intro from power WITH(NOLOCK) where ord="&nowCate&" and sort1=32 and sort2=3")
if rs.eof = false then
open_32_3=rs("qx_open") : intro_32_3=rs("qx_intro")
end if
rs.close
set rs=nothing
If open_32_3&"" = "" Then open_32_3 = 0
If intro_32_3&"" = "" Then intro_32_3 = "-222" Else intro_32_3 = replace(intro_32_3&""," ","")
'If open_32_3&"" = "" Then open_32_3 = 0
If open_32_3 = 3 Then
isGoOn = True
ElseIf open_32_3 = 1 Then
isGoOn = True
else
isGoOn = False
end if
if isGoOn then
isGoOn = False
Set rs = conn.execute("SELECT ISNULL(STUFF((SELECT ','+cast(ord as varchar(15)) from kuout where del=1 and complete1<3 and sort1 in(1,4) and order1 in("& htords &") and ("& open_32_3 &"=3 or ("& open_32_3 &"=1 and charindex(','+cast(cateid as varchar(10))+',',',"& intro_32_3 &",')>0)) for xml path('')),1,1,''),'')")
If rs.eof = False Then
if rs(0)&""<>"" then
canDelOrds = rs(0)&""
isGoOn = True
end if
end if
rs.close
set rs = nothing
Set rs = conn.execute("select top 1 1 from kuout where del=1 and sort1 in(1,4) and order1 in("& htords &") and ord not in(SELECT distinct a.kuout FROM kuoutlist2 a WITH(NOLOCK) INNER JOIN contractthlist b WITH(NOLOCK) ON b.kuoutlist2=a.id AND b.del=1 INNER JOIN contractth c WITH(NOLOCK) ON c.ord=b.caigou AND c.del IN(1,3) AND ISNULL(c.sp,0)<>-1INNER JOIN kuout d WITH(NOLOCK) on a.kuout=d.ord AND d.del=1 AND d.sort1 in(1,4) and d.order1 in("& htords &"))")
isGoOn = True
end if
end if
if isGoOn then
ret = canDelOrds
else
ret = "False"
end if
Case "send"
isGoOn = True
If sdk.getSqlValue("select count(1) from sendlist s inner join kuout k on k.ord=s.kuout and s.del=1 and s.complete1=0 and k.sort1 in(1,4) and k.order1 in("& htords &")" , 0)&"" = "0" Then
isGoOn = False
end if
if isGoOn then
set rs = conn.execute("select qx_open,qx_intro from power WITH(NOLOCK) where ord="&nowCate&" and sort1=33 and sort2=3")
if rs.eof = false then
open_33_3=rs("qx_open") : intro_33_3=rs("qx_intro")
end if
rs.close
set rs=nothing
If open_33_3&"" = "" Then open_33_3 = 0
If intro_33_3&"" = "" Then intro_33_3 = "-222" Else intro_33_3 = replace(intro_33_3&""," ","")
'If open_33_3&"" = "" Then open_33_3 = 0
If open_33_3 = 3 Then
isGoOn = True
ElseIf open_33_3 = 1 Then
isGoOn = True
'Set rs = conn.execute("SELECT top 1 1 FROM (SELECT id,CAST(short_str AS INT) cateid FROM dbo.split('"& intro_33_3 &"',',')) a INNER JOIN (select distinct s.cateid from send s inner join kuout k on k.ord=s.kuout and s.del=1 and k.sort1 in(1,4) and k.order1 in("& htords &")) b on a.cateid=b.cateid AND a.cateid>0")
else
isGoOn = False
end if
end if
If isGoOn Then
isGoOn = False
Set rs = conn.execute("SELECT ISNULL(STUFF((SELECT ','+cast(s.ord as varchar(15)) from send s inner join sendlist st on st.send=s.ord inner join kuout k on k.ord=st.kuout and s.del=1 and s.complete1=0 and k.sort1 in(1,4) and k.order1 in("& htords &") and ("& open_33_3 &"=3 or ("& open_33_3 &"=1 and charindex(','+cast(s.cateid as varchar(10))+',',',"& intro_33_3 &",')>0)) group by s.ord for xml path('')),1,1,''),'')")
isGoOn = False
If rs.eof = False Then
if rs(0)&""<>"" then
canDelOrds = rs(0)&""
isGoOn = True
end if
end if
rs.close
set rs = nothing
end if
if isGoOn then
ret = canDelOrds
else
ret = "False"
end if
End Select
if ret&"" = "" then ret = "False"
CheckBillCanDelete = ret
end function
function IsCanDeleteCheckPayback(cn , PaybackID)
if cn.execute("select 1 from home_usConfig where name='Payback_Invoice_Voucher_Constraint' and nvalue=1").eof=false then
if cn.execute("select 1 from payback pb inner join dbo.collocation c on c.del=1 and c.sort1 = 6 AND c.clstype = 6009 AND pb.ord = c.erpOrd  where pb.ord="& PaybackID &" and pb.del=1 and pb.complete <3 ").eof=false then
IsCanDeleteCheckPayback = false
exit function
end if
end if
IsCanDeleteCheckPayback = true
end function
function ExistsLeftMoneyForInvoice(cn,contractID)
ExistsLeftMoneyForInvoice = (cn.execute("select c.ord,c.company "&_
"  from contract c  "&_
"  left join ( "&_
"      select contract, count(1) as invoiceMxCount ,sum(money1) as money1,sum(num1) as num1  "&_
"      from contractlist  "&_
"      where del=1 and isnull(invoicetype,0)>0 and contract = "& contractID &" "&_
"      group by contract  "&_
"  ) m on m.contract = c.ord "&_
"  left join ( "&_
"      select p.fromid as contract, sum((case when isnull(p.RedJoinId,0)>0 then -1 else 1 end) * p.money1 + isnull(pl.money1,0)) as money1 "&_
"  left join ( "&_
"      from paybackinvoice p "&_
"      left join (select paybackinvoice,sum(money1) as money1 from paybackinvoice_list where contractlist<=0 and del=1 group by paybackinvoice) pl on p.id = pl.paybackinvoice "&_
"      where p.del=1 and p.isinvoiced<>3 and p.fromtype='CONTRACT' and p.fromId = "& contractID &"  "&_
"      group by p.fromid  "&_
"  ) i on i.contract = c.ord "&_
"  left join ( "&_
"      select p.fromid as contract, sum((case when isnull(p.RedJoinId,0)>0 then -1 else 1 end) * pl.num1) as num1 "&_
"  left join ( "&_
"      from paybackinvoice p "&_
"      inner join paybackinvoice_list  pl on p.id = pl.paybackinvoice and pl.contractlist>0 "&_
"      where p.del=1 and p.isinvoiced<>3 and p.fromtype='CONTRACT' and p.fromId = "& contractID &"  "&_
"      group by p.fromid  "&_
"  ) j on j.contract = c.ord "&_
"  left join ( "&_
"      select isnull(sum(d.money2),0) as thmoney,l.contract "&_
"      from contractthListDetail d  "&_
"      inner join contractlist l on l.id=d.contractlist  "&_
"      inner join contractthlist tl on tl.id=d.contractthlist  "&_
"      inner join contractth ct on ct.ord=tl.caigou and ct.del=1 and ct.sp=0  "&_
"      where d.del=1 and (isnull(d.thtype,'') = 'GOODS' or isnull(d.thtype,'') = 'GOODS_MONEY' or isnull(d.thtype,'') = 'MONEY')  "&_
"      group by l.contract "&_
"  ) th on th.contract = c.ord "&_
"  where c.ord="& contractID &"  and c.del=1 and c.isTerminated=0 and isnull(c.importInvoice,0)=0 and c.invoicemode<>0 "&_
"     and m.money1 - isnull(c.yhmoney,0) - isnull(i.money1,0) - ISNULL(th.thmoney,0)>0 and (c.invoicemode=1 or (c.invoicemode=2 and isnull(m.num1,0)-isnull(j.num1,0)>0) )").eof=false)
end function

ord=request("ord")
list1=request("list1")
list2=request("list2")
bank=request("bank")
url=request("url")
dim actinon1 , canDelete
Str_Result1=""
canDelete = True
uid = session("personzbintel2007")
isDeleteMainTable = False
conn.execute("create table #RelaList(id int,voucher int,account int)")
Dim rs : Set rs = conn.execute("select top 0 0 id,0 account, 0 voucher")
Select case ord
Case "tel"
Set rs = conn.execute("exec [erp_rela_finance_GetAssistIDs] "& session("personzbintel2007") &", 1,'1,2', 'select ord from tel where del=2','"& Application("__saas__company") &"'")
Case "chance"
Set rs = conn.execute("exec [erp_rela_finance_GetAssistIDs] "& session("personzbintel2007") &", 1,'5', 'select ord from chance where del=2','"& Application("__saas__company") &"'" )
Case "product"
Set rs = conn.execute("exec [erp_rela_finance_GetAssistIDs] "& session("personzbintel2007") &", 1,'6', 'select ord from product where del=2','"& Application("__saas__company") &"'" )
Case "payout3"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select ord from payout3 where del=2',44004, 10, '10007,10008,10010' ")
Case "kuout"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select ord from kuout where del=2',62001, 12, '' ")
Case "paybackinvoice"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select id from paybackinvoice  where del=2 ',6, 6, '6005,6007' ")
Case "payback"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select ord from payback  where del=2 ',1, 6, '6003,6006,6009' ")
Case "payout"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select ord from payout where del=2',44003, 10, '10003,10004,10009' ")
Case "payout2"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select ord from payout2 where del=2 ',8, 6, '6004,6008,6010' ")
Case "bankout3"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select id from bankout3  where del=2',12, 10, '' ")
Case "bankin3"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select id from bankin3  where del=2 ',13, 6, '6002' ")
Case "bankout2"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select id from bankout2  where del=2',11, 10, '' ")
case "bankin2"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select id from bankin2  where del=2',9, 6, '6001' ")
Case "paybx"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select id from paybx where del=2',40, 8, '' ")
Case "payjk"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select id from payjk where del=2',50, 8, '8009' ")
Case "pay"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select id from pay where del=2',4, 8, '8010' ")
Case "kuin"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select ord from kuin where del=2',61001, 11, '' ")
Case "wages"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select id from wages  where del=2',3, 7, '' ")
Case "bankin"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select id from bankin where del=2',7, 5, '5001' ")
Case "bankout"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select id from bankout where del=2',10, 5, '5002' ")
Case "bankmove"
Set rs = conn.execute(" exec [erp_rela_finance_GetCollectionIDs] "& uid &", 1, 'select id from bankmove where del=2',5, 5, '5003' ")
End Select
While rs.eof=False
conn.execute("insert into #RelaList(id)values(" & rs("id").value & ") ")
rs.movenext
wend
rs.close
noDel = ""
if ord&""="contract" then
Set rs = conn.execute("select ord from "&ord&" Where del=2 ")
While rs.eof = False
if SubBillCount(rs("ord"))>0 then
noDel = noDel & iif(noDel&""="","",",") & rs("ord")
end if
rs.movenext
wend
rs.close
set rs = nothing
end if
set rs=server.CreateObject("adodb.recordset")
if ord="wages" then
conn.Execute("Delete  wageslist where wages in (select id from wages where del=2 and id not in (select id from #RelaList))")
conn.Execute("Delete  bank where sort=3 and gl2 in (select id from wages where del=2 and id not in (select id from #RelaList))")
conn.Execute("Delete  sp_intro where sort1=10 and ord in (select id from wages where del=2 and id not in (select id from #RelaList))")
sql="delete from Wages_Relation where WageId in (select id from wages where del=2 and id not in (select id from #RelaList))"
conn.execute sql
conn.execute("Delete wages where del=2 and id not in (select id from #RelaList)")
isDeleteMainTable=True
elseif ord="bankin" then
conn.Execute("Delete bank where sort=7 and gl2 in (select id from bankin where del=2 and id not in (select id from #RelaList))")
conn.execute("Delete bankin where del=2 and id not in (select id from #RelaList)")
isDeleteMainTable=True
elseif ord="bankout" then
conn.Execute("Delete bank where sort=10 and gl2 in (select id from bankout where del=2 and id not in (select id from #RelaList))")
conn.execute("Delete bankout where del=2 and id not in (select id from #RelaList)")
isDeleteMainTable=True
elseif ord="bankmove" then
conn.Execute("Delete bank where (sort=5 or sort=6) and gl2 in (select id from bankmove where del=2 and id not in (select id from #RelaList))")
conn.execute("Delete bankmove where del=2 and id not in (select id from #RelaList)")
isDeleteMainTable=True
elseif ord="bankin2" Then
Str_Result1 = " and  isnull(payout2,0)=0 "
conn.Execute("Delete bank where sort=9 and gl2 in (select id from bankin2 where del=2 and isnull(payout2,0)=0 and id not in (select id from #RelaList))")
conn.execute("Delete bankin2 where del=2 and id not in (select id from #RelaList)")
isDeleteMainTable=True
elseif ord="bankin3" then
conn.Execute("Delete bank where sort=13 and gl2 in (select id from bankin3 where del=2 and id not in (select id from #RelaList))")
conn.execute("Delete bankin3 where del=2 and id not in (select id from #RelaList)")
isDeleteMainTable=True
elseif ord="bankout2" Then
Str_Result1 = " and  isnull(payout3,0)=0 "
conn.Execute("Delete bank where sort=11 and gl2 in (select id from bankout2 where del=2 and isnull(payout3,0)=0 and id not in (select id from #RelaList))")
conn.execute("Delete bankout2 where del=2 and id not in (select id from #RelaList)")
isDeleteMainTable=True
elseif ord="payback" Then
conn.Execute "Delete paybacklist where del=2 and payback in (" & vbcrlf &_
"select a.ord from payback a " & vbcrlf &_
"left join contract b on a.contract=b.ord " & vbcrlf &_
"where a.del=2 and isnull(b.wxUserId,0)=0  and a.ord not in (select id from #RelaList) " & vbcrlf &_
")"
conn.Execute "update paybacklist set del=5 where del=2 and payback in (" & vbcrlf &_
"select a.ord from payback a " & vbcrlf &_
"left join contract b on a.contract=b.ord " & vbcrlf &_
"where a.del=2 and isnull(b.wxUserId,0)>0  and a.ord not in (select id from #RelaList)" & vbcrlf &_
")"
conn.Execute "Delete bank where sort=1 and gl2 in (select id from payback where del=2 and ord in (" & vbcrlf &_
"select a.ord from payback a " & vbcrlf &_
"left join contract b on a.contract=b.ord " & vbcrlf &_
"where a.del=2 and isnull(b.wxUserId,0)=0  and a.ord not in (select id from #RelaList)" & vbcrlf &_
"))"
conn.execute "Delete bankin4 where payback in (select ord from payback where del=2 and title='余额付款' and ord in (" & vbcrlf &_
"select a.ord from payback a " & vbcrlf &_
"left join contract b on a.contract=b.ord " & vbcrlf &_
"where a.del=2 and isnull(b.wxUserId,0)=0 and a.ord not in (select id from #RelaList) " & vbcrlf &_
"))"
conn.execute "Delete bankin4_list where payback in (select ord from payback where del=2 and title='余额付款' and ord in (" & vbcrlf &_
"select a.ord from payback a " & vbcrlf &_
"left join contract b on a.contract=b.ord " & vbcrlf &_
"where a.del=2 and isnull(b.wxUserId,0)=0  and a.ord not in (select id from #RelaList)" & vbcrlf &_
"))"
elseif ord="paybackinvoice" Then
conn.Execute("Delete paybackinvoice_list where del=2 and paybackinvoice in (" & vbcrlf &_
"select id from paybackinvoice a " & vbcrlf &_
"left join contract b on a.fromType='CONTRACT' and a.fromId=b.ord " & vbcrlf &_
"where a.del=2 and isnull(b.wxUserId,0) = 0  and id not in (select id from #RelaList)" & vbcrlf &_
")")
conn.Execute("update paybackinvoice_list set del=5 where del=2 and paybackinvoice in (" & vbcrlf &_
"select id from paybackinvoice a " & vbcrlf &_
"left join contract b on a.fromType='CONTRACT' and a.fromId=b.ord " & vbcrlf &_
"where a.del=2 and isnull(b.wxUserId,0) = 0  and id not in (select id from #RelaList)" & vbcrlf &_
")")
conn.execute("Delete sys_sdk_BillFieldValue where BillType=43005 and BillID in (select id from paybackinvoice where del=2 and id not in (select id from #RelaList)) ")
conn.execute("delete from paybackinvoice where del=2 and id not in (select id from #RelaList)")
isDeleteMainTable = True
elseif ord="bankout3" then
conn.Execute("Delete bank where sort=12 and gl2 in (select id from bankout3 where del=2  and id not in (select id from #RelaList))")
conn.execute("Delete bankout3 where del=2 and id not in (select id from #RelaList)")
isDeleteMainTable=True
elseif ord="payout" then
conn.Execute("Delete plan_fk where del=2 and ord in(select planfkid from payout where del=2 and ord not in (select id from #RelaList)) ") '
conn.Execute("Delete bank where sort=2 and gl2 in (select ord from payout where del=2 and ord not in (select id from #RelaList))")
conn.execute("Delete bankout4 where payout in (select ord from payout where del=2 and title='余额付款' and ord not in (select id from #RelaList))")
conn.execute("Delete payout where del=2 and ord not in (select id from #RelaList)")
isDeleteMainTable=True
elseif ord="payout2" then
conn.Execute("Delete bank where sort=8 and gl2 in (select ord from payout2 where del=2 and ord not in (select id from #RelaList))")
conn.Execute("Delete bankin2 where payout2 in (select ord from payout2 where del=2 and ord not in (select id from #RelaList))") '
conn.Execute("Delete payout2 where del=2 and ord not in (select id from #RelaList)")
isDeleteMainTable = True
elseif ord="payout3" Then
conn.Execute("Delete bank where sort=14 and gl2 in (select ord from payout3 where del=2) and gl2 not in (select id from #RelaList)")
conn.execute "Delete bankout2 where isnull(payout3,0) in (select ord from payout3 where del=2)  and isnull(payout3,0) not in (select id from #RelaList) " '
conn.execute("delete from payout3 where del=2 and ord not in (select id from #RelaList)")
ElseIf ord="paysq" Then
intro_old = ""
Set rs = conn.execute("select remark from " & ord & " where del=2")
While rs.eof = False
intro_old = intro_old & rs(0)
rs.movenext
wend
rs.close
set rs = nothing
picUrl = getPicUrl(intro_old)
if picUrl <> "" then
picUrlArray = split(picUrl,",")
for x = 0 to ubound(picUrlArray)
DeleteFile("../edit/upimages/"&picUrlArray(x))
next
end if
conn.Execute("Delete paysqlist where fid in (select id from paysq where del=2)")
ElseIf ord="paybx" Then
conn.execute("delete paybxlist where bxid in (select id from paybx where del=2 and id not in (select id from #RelaList)) ")
conn.execute("delete dk where bxid in (select id from paybx where del=2 and id not in (select id from #RelaList)) ")
conn.execute("Delete paybx where del=2 and id not in (select id from #RelaList)")
conn.execute "delete from bank where del=2 and sort=40 and gl not in (select id from #RelaList)"
isDeleteMainTable=True
ElseIf ord="chance" Then
conn.Execute("Delete chancelist where chance in (select ord from chance where del=2 and ord not in (select id from #RelaList))")
conn.Execute("delete from replyjh where ord in (select ord from chance where del=2 and ord not in (select id from #RelaList))")
conn.execute("delete chance where del=2 and ord not in (select id from #RelaList)")
elseif ord="person" Then
searchtype=request("searchtype")
C=request("C")
m1=request("ret")
m2=request("ret2")
Str_Result1=""
if m1<>"" then
Str_Result1 = " and deldate>='"&m1&"' "
end if
if m2<>"" then
Str_Result1 = Str_Result1 & " and deldate<='"&m2&"' "
end if
If searchtype<>"" And C<>"" Then
If searchtype="0" Then
Str_Result1 = Str_Result1 & " and company in(select ord from tel where charindex('"&C&"',name)>0) "
ElseIf searchtype="1" Then
Str_Result1 = Str_Result1 & " and charindex('"&C&"',name)>0 "
ElseIf searchtype="2" Then
Str_Result1 = Str_Result1 & " and charindex('"&C&"',phone)>0 "
ElseIf searchtype="3" Then
Str_Result1 = Str_Result1 & " and charindex('"&C&"',mobile)>0 "
ElseIf searchtype="4" Then
Str_Result1 = Str_Result1 & " and charindex('"&C&"',mobile2)>0 "
ElseIf searchtype="5" Then
Str_Result1 = Str_Result1 & " and charindex('"&C&"',email)>0 "
ElseIf searchtype="6" Then
Str_Result1 = Str_Result1 & " and charindex('"&C&"',qq)>0 "
ElseIf searchtype="7" Then
Str_Result1 = Str_Result1 & " and charindex('"&C&"',address)>0 "
end if
else
searchtype="0"
end if
sql="update MMsg_User set person = null where person in (select ord from person where del=2 "&Str_Result1&") "
conn.Execute(sql)
conn.Execute("delete from reply where sort1=8 and ord in (select ord from person where del=2 "&Str_Result1&")")
elseif ord="price" then
conn.execute("delete pricebz where price in (select ord from price where del=2) or price not in (select ord from price)")
conn.execute("Delete replybj where ord in (select ord from price where del=2)")
conn.execute("Delete sys_sdk_BillFieldValue where (BillId in (select ord from price where del=2) or BillId not in (select ord from price)) and BillType=13001 ")
conn.Execute("delete [sp_ApprovalInstance] where  gate2 = 13001 and (PrimaryKeyID in (select ord from price where del=2) or not exists(select 1 from price where ord = PrimaryKeyID))")
conn.Execute("delete [sp_Intro] where  sort1 = 13001 and (ord in (select ord from price where del=2) or not exists(select 1 from price where ord = sp_Intro.ord) )")
elseif ord="contractth" then
conn.execute("delete contractthbz where contractth in (select ord from contractth ctt where del=2 and not exists (select contractth from payout2 where  contractth=ctt.ord union all select fromid from paybackinvoice where  fromtype='ContractTH' and fromid=ctt.ord union all select Caigou from kuin where sort1=2 and Caigou=ctt.ord)) or contractth not in (select ord from contractth)")
conn.execute("delete contractthlistDetail where contractth in (select ord from contractth ctt where del=2 and not exists (select contractth from payout2 where  contractth=ctt.ord union all select fromid from paybackinvoice where  fromtype='ContractTH' and fromid=ctt.ord union all select Caigou from kuin where sort1=2 and Caigou=ctt.ord)) or contractth not in (select ord from contractth)")
ElseIf ord="tousu" Then
conn.execute("Delete replyts where ord in (select ord from tousu where del=2)")
ElseIf ord="jzds" Then
intro_old = ""
Set rs = conn.execute("select remark from jzds where del=2")
While rs.eof = False
intro_old = intro_old & rs(0)
rs.movenext
wend
rs.close
set rs = nothing
picUrl = getPicUrl(intro_old)
if picUrl <> "" then
picUrlArray = split(picUrl,",")
for x = 0 to ubound(picUrlArray)
DeleteFile("../edit/upimages/"&picUrlArray(x))
next
end if
conn.execute("Delete replyds where ord in (select id from jzds where del=2)")
ElseIf ord="notebook" Then
intro_old = ""
Set rs = conn.execute("select intro from " & ord & " where del=2")
While rs.eof = False
intro_old = intro_old & rs(0)
rs.movenext
wend
rs.close
set rs = nothing
picUrl = getPicUrl(intro_old)
if picUrl <> "" then
picUrlArray = split(picUrl,",")
for x = 0 to ubound(picUrlArray)
DeleteFile("../edit/upimages/"&picUrlArray(x))
next
end if
ElseIf ord="product" Then
Set rs=conn.execute("select * from product where del=2")
While Not rs.eof
Set rss=conn.execute("select dbo.check_product("&rs("ord")&") as sid")
If Not rss.eof Then
If rs7("sid")="" Then
conn.execute("delete from product where ord="&rs("ord")&"  and ord not in (select id from #RelaList)")
conn.execute("delete jiage where product="&rs("ord")&"  and product not in (select id from #RelaList) ")
conn.execute "delete ERP_CustomValues where id in (select b.id from ERP_CustomFields  a " _
& " left join ERP_CustomValues b on a.id=b.fieldsid " _
& " where a.tname=21 and b.orderid='"&rs("ord")&"'  and b.orderid not in (select id from #RelaList)) "
end if
end if
rss.close
picUrl = getPicUrl(rs("intro3"))
if picUrl <> "" then
picUrlArray = split(picUrl,",")
for x = 0 to ubound(picUrlArray)
DeleteFile("../edit/upimages/"&picUrlArray(x))
next
end if
rs.movenext
wend
rs.close
Set rs=Nothing
ElseIf ord="learntz" Or ord="learnhd" Then
Set rs=conn.execute("select * from "&ord&" where del=2")
While Not rs.eof
picUrl = getPicUrl(rs("intro"))
if picUrl <> "" then
picUrlArray = split(picUrl,",")
for x = 0 to ubound(picUrlArray)
DeleteFile("../edit/upimages/"&picUrlArray(x))
next
end if
rs.movenext
wend
rs.close
Set rs=Nothing
If ord="learnhd" Then
conn.Execute("Delete replyhd Where ord in (select ord from learnhd Where del=2)")
conn.Execute("Delete huifu Where sort in (select ord from learnhd Where del=2)")
end if
ElseIf ord="repair_sl" Then
Set rs=conn.execute("select * from "&ord&" where del=2")
While Not rs.eof
picUrl = getPicUrl(rs("intro"))
if picUrl <> "" then
picUrlArray = split(picUrl,",")
for x = 0 to ubound(picUrlArray)
DeleteFile("../edit/upimages/"&picUrlArray(x))
next
end if
rs.movenext
wend
rs.close
Set rs=Nothing
conn.Execute("Delete from repair_sl where del=2")
conn.Execute("Delete from repair_sl_list where del=2")
conn.Execute("Delete from repair_sl_jian where del=2")
conn.Execute("Delete from repair_kulist where del=2 and sort1=1")
ElseIf ord="kujh" Then
conn.Execute("Delete kuhhlist where kuhh in (select ord from kuhh where  kujh in ( select ord from kujh where del=2))")
ElseIf ord="send" Then
conn.Execute("Delete telalt where fh1 in (select ord from send where del=2)")
ElseIf ord="caigouQC" Then
B=request("B")
C=trim(request("C"))
sql2 = ""
if C&""<>"" then
select case B
case "zjzt" : sql2 = sql2 + " and  title like '%"& C &"%'"
'select case B
case "zjbh" : sql2 = sql2 + " and  qcid like '%"& C &"%'"
'select case B
case "cpmc" : sql2 = sql2 + " and  productid in(select ord from product where title like '%"& C &"%' and del=1) "
'select case B
case "cpbh" : sql2 = sql2 + " and  productid in(select ord from product where order1 like '%"& C &"%' and del=1) "
'select case B
case "cpxh" : sql2 = sql2 + " and  productid in(select ord from product where type1 like '%"& C &"%' and del=1) "
'select case B
end select
end if
set rs = conn.execute("select id,intro, QCReport from caigouQC Where del=2 "& sql2)
if rs.eof then
qcord_old = ""
intro_old=""
report_old=""
else
qcord_old = ""
intro_old=""
report_old=""
while not rs.eof
qcord_old = qcord_old & rs("id") &" "
intro_old=intro_old&rs("intro")
report_old=report_old&rs("QCReport")
rs.movenext
wend
end if
rs.close
set rs=nothing
picUrl = getPicUrl(intro_old)
if picUrl <> "" then
picUrlArray = split(picUrl,",")
for x = 0 to ubound(picUrlArray)
DeleteFile("../edit/upimages/"&picUrlArray(x))
next
end if
picUrl2 = getPicUrl(report_old)
if picUrl2 <> "" then
picUrlArray2 = split(picUrl2,",")
for x = 0 to ubound(picUrlArray2)
DeleteFile("../edit/upimages/"&picUrlArray2(x))
next
end if
if qcord_old&""<>"" then
qcord_old = replace(trim(qcord_old)," ",",")
conn.execute "delete caigouQC where id in("& qcord_old &")"
conn.execute "delete caigouQClist where del=2 and caigouQC in("& qcord_old &")"
end if
ElseIf ord="budget" Then
conn.execute "delete sp_intro where sort1=62 and ord in (select ord from budget where del=2)"
conn.execute "delete budgetlist where pid in (select ord from budget where del=2)"
conn.execute "delete budget where del=2 "
ElseIf ord = "kuzz" Then
conn.execute "delete kuzz where del=2 and isnull(isnew,0) = 0 "
ElseIf ord="tel" Then
tit_1=request.querystring("tit_1")
sear=request.querystring("sear")
str_Result = ""
if tit_1="F2" Then str_Result=str_Result+"and name like '%"& sear &"%'"
str_Result = ""
if tit_1="S2" Then str_Result=str_Result+"and pym like '%"& sear &"%'"
str_Result = ""
if tit_1="Y2" Then str_Result=str_Result+"and khid like '%"& sear &"%'"
str_Result = ""
if tit_1="G2" Then str_Result=str_Result+"and phone like '%"& sear &"%'"
str_Result = ""
if tit_1="P2" Then str_Result=str_Result+"and fax like '%"& sear &"%'"
str_Result = ""
if tit_1="J2" Then str_Result=str_Result+"and address like '%"& sear &"%'"
str_Result = ""
if tit_1="T2" Then str_Result=str_Result+"and intro like '%"& sear &"%'"
str_Result = ""
conn.begintrans
conn.execute "Delete sortFieldsContent where sort=1 and ord in (select ord from tel where del=2 and ord not in (select id from #RelaList) " & str_Result & ")"
conn.execute "Delete reply where ord in (select ord from tel where del=2 and ord not in (select id from #RelaList) " & str_Result & ")"
conn.execute "Delete importantMsg where t_ord in (select ord from tel where del=2 and ord not in (select id from #RelaList) " & str_Result & ")"
conn.execute "Delete tel_sales_change_log where tord in (select ord from tel where del=2 and ord not in (select id from #RelaList) " & str_Result & ")"
conn.execute "Delete tel_sort_change_log where tord in (select ord from tel where del=2 and ord not in (select id from #RelaList) " & str_Result & ")"
call Del_Extended_Value(1,"select ord from tel where del=2  and ord not in (select id from #RelaList)" & str_Result & "") '
set rsdel=conn.execute("select intro from tel where  intro like '%edit/upimages/%' and del=2  " & str_Result & "")
if err.number=0 then
while rsdel.eof = false
intro2=rsdel(0)
picUrl = getPicUrl(intro2)
if picUrl<>"" then
picUrlArray2 = split(picUrl,",")
for x = 0 to ubound(picUrlArray2)
DeleteFile("../edit/upimages/"&picUrlArray2(x))
next
end if
rsdel.movenext
wend
else
err.clear
end if
conn.execute "delete tel where del=2  and ord not in (select id from #RelaList) " & str_Result & ""
conn.committrans
ElseIf ord = "payjk" Or ord="pay" Then
conn.execute("Delete "& ord & " where del=2 and id not in (select id from #RelaList)")
isDeleteMainTable=True
ElseIf ord = "kuin" Then
action1="入库清空"
conn.execute("UPDATE M2_SerialNumberList SET status=0 WHERE id IN (SELECT sn.SerialID FROM  S2_SerialNumberRelation sn INNER JOIN kuin ON sn.BillID=kuin.ord AND sn.BillType='61001' AND kuin.del=2 and BillListType=1 AND BillID in (select ord from kuin where del=2 and ord not in (select id from #RelaList)))")
conn.execute("Delete S2_SerialNumberRelation  WHERE id IN (SELECT sn.id FROM  S2_SerialNumberRelation sn INNER JOIN kuin ON sn.BillID=kuin.ord AND sn.BillType='61001' AND kuin.del=2 and BillListType=1  AND BillID in (select ord from kuin where del=2 and ord not in (select id from #RelaList)))")
conn.execute("Delete kuinlist where del=2 and kuin in (select ord from kuin where del=2 and ord not in (select id from #RelaList))")
conn.execute "update ku set status=3 where status=2 and kuinlist in (select id from kuinlist where del=2 and kuin not in (select id from #RelaList))"
conn.Execute("delete [sp_ApprovalInstance] where  gate2 = 61001 and (PrimaryKeyID in (select ord from kuin where del=2 and ord not in (select id from #RelaList) ) or not exists(select 1 from kuin where ord = PrimaryKeyID))")
conn.Execute("delete [sp_Intro] where  sort1 = 61001 and (ord in (select ord from kuin where del=2 and ord not in (select id from #RelaList) ) or not exists(select 1 from kuin where ord = sp_Intro.ord) )")
conn.execute("Delete sys_sdk_BillFieldValue where BillType=61001 and BillID in (select ord from kuin where del=2 and ord not in (select id from #RelaList)) ")
conn.execute("Delete kuin where del=2 and ord not in (select id from #RelaList)")
isDeleteMainTable=True
else
if ord="caigou" or ord="contract" Or ord="caigouth" or ord="xunjia" then
sql="select intro,ord from "&ord&" Where del=2 "& iif(ord="contract"," and charindex(','+cast(ord as varchar(15))+',',',"& noDel &",')=0","")
'if ord="caigou" or ord="contract" Or ord="caigouth" or ord="xunjia" then
if ord="xunjia" then
sql="select id,''intro from "&ord&" Where del=2 "
end if
conn.cursorlocation = 3
rs.open sql,conn,1,1
if err.number=0 then
if rs.eof then
intro_old=""
else
intro_old=""
selectid=""
while rs.eof = false
intro_old=intro_old&rs("intro")
if ord="contract" then
sql="select intro2 from contractbz where contract="&rs("ord")&" "
set rsdel=conn.execute(sql)
if err.number=0 then
while rsdel.eof = false
intro2=rsdel(0)
picUrl = getPicUrl(intro2)
if picUrl<>"" then
picUrlArray2 = split(picUrl,",")
for x = 0 to ubound(picUrlArray2)
DeleteFile("../edit/upimages/"&picUrlArray2(x))
next
end if
rsdel.movenext
wend
else
err.clear
end if
sql="select intro from contractlist where contract="&rs("ord")&" "
set rsdel=conn.execute(sql)
if err.number=0 then
while rsdel.eof = false
intro=rsdel(0)
picUrl = getPicUrl(intro)
if picUrl<>"" then
picUrlArray3 = split(picUrl,",")
for x = 0 to ubound(picUrlArray3)
DeleteFile("../edit/upimages/"&picUrlArray3(x))
next
end if
rsdel.movenext
wend
else
err.clear
end if
Set rss=conn.execute("select isnull(event1,0) as event1 from contract where ord="&rs("ord")&" ")
if not rss.eof then
set rs1=conn.execute("select * from contract Where del<>2 and event1="&rss("event1")&" ")
if rs1.eof then
conn.execute("Update price set complete=0 where ord="&rss("event1")&"")
end if
rs1.close
end if
rss.close
sql="delete payback where contract in (select ord from contract where ord = " & rs("ord") & " and isnull(wxUserId,0) = 0) and complete<>3 "
conn.Execute(sql)
sql="update payback set del=5 where contract in (select ord from contract where ord = " & rs("ord") & " and isnull(wxUserId,0) > 0) and complete<>3 "
conn.Execute(sql)
sql="delete plan_hk where contract="& rs("ord") &" and ord not in (select planhkid from payback where contract="& rs("ord") &") "
conn.Execute(sql)
elseif ord="xunjia" then
sql="update  price set complete=1   from  price left join xunjia on xunjia.price=price.ord where xunjia.id in("&rs("id")&")"
conn.Execute(sql)
sql="update  pricelist set del=2   from  price inner join pricelist on pricelist.price=price.ord left join xunjia on xunjia.price=price.ord where pricelist.del=1 and xunjia.id in("&rs("id")&")"
conn.Execute(sql)
elseif ord="caigou" then
sql="select intro2 from caigoubz where caigou="&rs("ord")&" "
set rsdel=conn.execute(sql)
if err.number=0 then
while rsdel.eof = false
intro2=rsdel(0)
picUrl = getPicUrl(intro2)
if picUrl<>"" then
picUrlArray2 = split(picUrl,",")
for x = 0 to ubound(picUrlArray2)
DeleteFile("../edit/upimages/"&picUrlArray2(x))
next
end if
rsdel.movenext
wend
else
err.clear
end if
sql="select intro from caigoulist where caigou="&rs("ord")&" "
set rsdel=conn.execute(sql)
if err.number=0 then
while rsdel.eof = false
intro=rsdel(0)
picUrl = getPicUrl(intro)
if picUrl<>"" then
picUrlArray3 = split(picUrl,",")
for x = 0 to ubound(picUrlArray3)
DeleteFile("../edit/upimages/"&picUrlArray3(x))
next
end if
rsdel.movenext
wend
else
err.clear
end if
end if
rs.movenext
wend
picUrl = getPicUrl(intro_old)
if picUrl <> "" then
picUrlArray = split(picUrl,",")
for x = 0 to ubound(picUrlArray)
DeleteFile("../edit/upimages/"&picUrlArray(x))
next
end if
If ord="contract" Then
conn.execute("delete contractbz where contract in (select ord from contract where del=2 and isnull(wxUserId,0) = 0) or contract not in (select ord from contract)")
conn.execute("update contractbz set del=5 where contract in (select ord from contract where del=2 and isnull(wxUserId,0) > 0)")
conn.Execute("delete [sp_ApprovalInstance] where  gate2 = 11001 and (PrimaryKeyID in (select ord from contract where del=2) or not exists(select 1 from contract where ord = PrimaryKeyID))")
ElseIf ord="caigou" Then
conn.execute("delete caigoubz where caigou in (select ord from caigou where del=2) or caigou not in (select ord from caigou)")
conn.Execute("delete [sp_ApprovalInstance] where  gate2 = 73001 and (PrimaryKeyID in (select ord from caigou where del=2) or not exists(select 1 from caigou where ord = PrimaryKeyID))")
ElseIf ord="caigouth" Then
conn.execute("delete caigouthbz where caigouth in (select ord from caigouth where del=2) or caigouth not in (select ord from caigouth)")
end if
end if
else
err.clear
end if
rs.close
set rs=nothing
end if
end if
if list1="reply" then
action1="洽谈进展清空"
If ord<>"tel" then
sql="delete from reply where sort1=1 and ord not in (select ord from tel)"
conn.Execute(sql)
end if
end if
if bank<>"" then
action1="银行账户清空"
conn.execute "delete bank where sort="&bank&" and del=2"
end if
if list1<>"" And list1<>"reply" And ord <> "tel" And ord<>"payout3" And ord<>"chance" And list1 <> "contractlist" And isDeleteMainTable = False then
if(list1="kuoutlist")then
sql="delete "&list1&" where del=2 and kuout not in (select id from #RelaList)"
conn.Execute(sql)
else
if(list1="contractthlist")then
sql="delete cttl from "&list1&" cttl where cttl.del=2 and  not exists (select contractth from payout2 where  contractth=cttl.caigou union all select fromid from paybackinvoice where  fromtype='ContractTH' and fromid=cttl.caigou union all select Caigou from kuin where sort1=2 and Caigou=cttl.caigou) "
else
sql="delete "&list1&" where del=2 "
end if
conn.Execute(sql)
end if
ElseIf list1 = "contractlist" then
conn.Execute "delete contractlist where del=2 and contract in (select ord from contract where isnull(wxUserId,0)=0 and del=2 and charindex(','+cast(ord as varchar(15))+',',',"& noDel &",')=0)"
'ElseIf list1 = "contractlist" then
conn.Execute "update contractlist set del=5 where del=2 and contract in (select ord from contract where isnull(wxUserId,0)>0 and del=2 and charindex(','+cast(ord as varchar(15))+',',',"& noDel &",')=0)"
'ElseIf list1 = "contractlist" then
end if
if list2<>"" And isDeleteMainTable = False then
if(list2="kuoutlist2")then
sql="delete "&list2&" where del=2 and kuout not in (select id from #RelaList)"
conn.Execute(sql)
else
sql="delete "&list2&" where del=2"
conn.Execute(sql)
end if
end if
if ord<>"caigouQC" And ord <> "tel" And ord <> "contract" And ord <> "product" And ord<>"chance" And isDeleteMainTable = False then
if(ord="kuout")then
conn.Execute("delete [sp_ApprovalInstance] where  gate2 = 62001 and (PrimaryKeyID in (select ord from kuout where del=2 and ord not in (select id from #RelaList) ) or not exists(select 1 from kuout where ord = PrimaryKeyID))")
conn.Execute("delete [sp_Intro] where  sort1 = 62001 and (ord in (select ord from kuout where del=2 and ord not in (select id from #RelaList) ) or not exists(select 1 from kuout where ord = sp_Intro.ord) )")
conn.execute("Delete sys_sdk_BillFieldValue where BillType=62001 and BillID in (select ord from "&ord&" where del=2 and ord not in (select id from #RelaList)) ")
sql="delete "&ord&" where del=2 and ord not in (select id from #RelaList)"
conn.Execute(sql)
elseif (ord="contractth") then
sql="delete ctt from contractth ctt where ctt.del=2 and not exists(select contractth from payout2 where contractth=ctt.ord union all select fromid from paybackinvoice where fromtype='ContractTH' and fromid=ctt.ord union all select Caigou from kuin where sort1=2 and Caigou=ctt.ord)"
conn.Execute(sql)
elseif (ord="caigou") then
conn.execute("Delete sys_sdk_BillFieldValue where BillType=73001 and BillID in (select ord from "&ord&" where del=2"&Str_Result1&") ")
conn.Execute("delete "&ord&" where del=2"&Str_Result1)
elseif (ord="send") then
conn.execute("Delete sys_sdk_BillFieldValue where BillType=68001 and BillID in (select ord from "&ord&" where del=2"&Str_Result1&") ")
conn.Execute("delete "&ord&" where del=2"&Str_Result1)
else
sql="delete "&ord&" where del=2"&Str_Result1
conn.Execute(sql)
end if
ElseIf ord = "contract" Then
conn.execute "delete sys_sdk_BillFieldValue where BillType=11001 and BillId in (select ord from contract where del=2 and isnull(wxUserId,0)=0 and charindex(','+cast(ord as varchar(15))+',',',"& noDel &",')=0)"
'ElseIf ord = "contract" Then
conn.execute "delete contract where del=2 and isnull(wxUserId,0)=0 and charindex(','+cast(ord as varchar(15))+',',',"& noDel &",')=0"
'ElseIf ord = "contract" Then
conn.execute "update contract set del=5 where del=2 and isnull(wxUserId,0)>0 and charindex(','+cast(ord as varchar(15))+',',',"& noDel &",')=0"
'ElseIf ord = "contract" Then
ElseIf ord = "payback" Then
conn.execute "delete payback where del=2 and ord in (" & vbcrlf &_
"select a.ord from payback a " & vbcrlf &_
"left join contract b on a.contract=b.ord " & vbcrlf &_
"where a.del=2 and isnull(b.wxUserId,0)=0  and a.ord not in (select id from #RelaList)" & vbcrlf &_
")"
conn.execute "update payback set del=5 " & vbcrlf &_
"where del=2 and ord in (" & vbcrlf &_
"select a.ord from payback a " & vbcrlf &_
"left join contract b on a.contract=b.ord " & vbcrlf &_
"where a.del=2 and isnull(b.wxUserId,0)>0  and a.ord not in (select id from #RelaList) " & vbcrlf &_
")"
end if
if ord="notebook" then
action1="备忘录清空"
elseif ord="caigouth" then
action1="采购退货清空"
elseif ord="caigou" then
action1="采购清空"
elseif ord="caigou_yg" then
action1="预购清空"
elseif ord="caigouQC" then
action1="来料质检清空"
elseif ord="payout3" then
action1="采购退款清空"
elseif ord="call" then
action1="来电清空"
elseif ord="chance" then
action1="项目清空"
elseif ord="contract" then
action1="合同清空"
elseif ord="cuku" then
action1="出库清空"
elseif ord="repair_sl" then
action1="维修受理清空"
elseif ord="bankout" then
action1="出账清空"
elseif ord="kumove" then
action1="调拨清空"
elseif ord="jzds" then
action1="对手清空"
elseif ord="send" then
action1="发货清空"
elseif ord="learnhd" then
action1="工作互动清空"
elseif ord="kuzz" then
action1="组装清空"
elseif ord="kujh" then
action1="借货清空"
elseif ord="payback" then
action1="回款清空"
elseif ord="payout" then
action1="付款清空"
elseif ord="payout2" then
action1="退款清空"
elseif ord="bankout3" then
action1="供应商退预付款清空"
elseif ord="bankin3" then
action1="客户退预收款清空"
elseif ord="bankout2" then
action1="供应商预付款清空"
elseif ord="bankin2" then
action1="客户预收款清空"
elseif ord="learntz" then
action1="公告清空"
elseif ord="paybx" then
action1="费用报销清空"
elseif ord="paysq" then
action1="费用申请清空"
elseif ord="kupd" then
action1="盘点清空"
elseif ord="person" then
action1="联系人清空"
elseif ord="price" then
action1="报价清空"
elseif ord="kuin" then
action1="入库清空"
elseif ord="kuout" then
action1="出库清空"
elseif ord="bankin" then
action1="入账清空"
elseif ord="tel" then
action1="客户清空"
elseif ord="tongxunlu" then
action1="通讯录清空"
elseif ord="tousu" then
action1="售后清空"
elseif ord="contractth" then
action1="退货清空"
elseif ord="wages" then
action1="工资清空"
elseif ord="xunjia" then
action1="询价清空"
elseif ord="bankmove" then
action1="转账清空"
elseif ord="tel" then
action1="客户回收站清空"
ElseIf ord="budget" Then
action1="预算回收站清空"
end if
call close_list(2)
Call ReturnPage
Sub ReturnPage
Select Case ord&""
Case "caigouQC"
B=request("B")
C=trim(request("C"))
Response.redirect ""&url&"?B="& B &"&C="& C
Case "contract"
Response.redirect ""&url&"?noDel="& noDel
Case Else
Response.redirect ""&url&""
End Select
Response.end
end sub

%>
