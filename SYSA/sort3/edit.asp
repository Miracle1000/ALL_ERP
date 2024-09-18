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

Response.write vbcrlf

ZBRLibDLLNameSN = "ZBRLib3205"
function isInteger(para)
dim str
dim l,i
if isNUll(para) then
isInteger=false
exit function
end if
str=cstr(para)
if trim(str)="" then
isInteger=false
exit function
end if
l=len(str)
for i=1 to l
if mid(str,i,1)>"9" or mid(str,i,1)<"0" then
isInteger=false
exit function
end if
next
isInteger=true
if err.number<>0 then err.clear
end function
function IsValidEmail(email)
dim names, name, i, c
IsValidEmail = true
names = Split(email, "@")
if UBound(names) <> 1 then
IsValidEmail = false
exit function
end if
for each name in names
if Len(name) <= 0 then
IsValidEmail = false
exit function
end if
for i = 1 to Len(name)
c = Lcase(Mid(name, i, 1))
if InStr("abcdefghijklmnopqrstuvwxyz_-.", c) <= 0 and not IsNumeric(c) then
c = Lcase(Mid(name, i, 1))
IsValidEmail = false
exit function
end if
next
if Left(name, 1) = "." or Right(name, 1) = "." then
IsValidEmail = false
exit function
end if
next
if InStr(names(1), ".") <= 0 then
IsValidEmail = false
exit function
end if
i = Len(names(1)) - InStrRev(names(1), ".")
exit function
if i <> 2 and i <> 3 then
IsValidEmail = false
exit function
end if
if InStr(email, "..") > 0 then
IsValidEmail = false
end if
end function
Function HTMLEncode(fString)
if not isnull(fString) Then
fString = replace(fString, ">", "&gt;")
fString = replace(fString, "<", "&lt;")
fString = Replace(fString, CHR(32), "&nbsp;")
fString = Replace(fString, CHR(34), "&quot;")
fString = Replace(fString, CHR(39), "&#39;")
fString = Replace(fString, CHR(13) & CHR(10), "<br>")
fString = Replace(fString, CHR(13), "<br>")
fString = Replace(fString, CHR(10), "<br>")
HTMLEncode = fString
end if
end function
Function HTMLDecode(fString)
if not isnull(fString) Then
fString = replace(fString, "&gt;", ">")
fString = replace(fString, "&lt;", "<")
fString = Replace(fString, "&nbsp;",CHR(32))
fString = Replace(fString, "&quot;",CHR(34))
fString = Replace(fString, "&#39;",CHR(39))
fString = Replace(fString, "<br>",CHR(13) & CHR(10))
fString = Replace(fString, "<br>",CHR(13))
fString = Replace(fString, "<br>",CHR(10))
HTMLDecode = fString
end if
end function

dim ord,sortone,name,ord37
ord=request("ord")
If ord&""="" Then ord = 0
Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "    <meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "    <title>"
'If ord&""="" Then ord = 0
Response.write title_xtjm
Response.write "</title>" & vbcrlf & "    <link href=""../inc/cskt.css?ver="
Response.write Application("sys.info.jsver")
Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "    <style type=""text/css"">" & vbcrlf & "        <!--" & vbcrlf & "        body {" & vbcrlf & "            margin-top: 0px;" & vbcrlf & "        }" & vbcrlf & "        -->" & vbcrlf & "         .top_btns input.anybutton{margin-bottom:-2px;}" & vbcrlf & "        .resetGroupTableBg td::after,.resetGroupTableBg td::before{display:none!important;}" & vbcrlf & "        input.anybutton[type='button']:focus{" & vbcrlf & "            border:none;" & vbcrlf & "        }" & vbcrlf & "    </style>" & vbcrlf & "    <script language=""JavaScript"" type=""text/JavaScript"">" & vbcrlf & "<!--" & vbcrlf & "    function MM_jumpMenu(targ, selObj, restore) { //v3.0" & vbcrlf & "        eval(targ + "".location=\'"" + selObj.options[selObj.selectedIndex].value + ""\'"");" & vbcrlf & "        if (restore) selObj.selectedIndex = 0;" & vbcrlf & "    }" & vbcrlf & "" & vbcrlf & "    function setEnable(id, isStop) {" & vbcrlf & "        if (document.getElementById(""sID""+id).value==""停用"") {" & vbcrlf & "                      "
'Response.write Application("sys.info.jsver")
If ord <> 34 And ord <> 47 And ord <> 25 And ord <> 83 And ord <> 85  And ord <> 3001 And ord <> 100 And ord <> 157 And ord <> 158  And ord <> 54001 And ord <> 54002 And ord <> 54003 And ord <> 54004 And ord <> 54005 And ord <> 54006  And ord <> 45001 And ord <> 45002 And ord <> 57000 And ord <> 57010 And ord <> 57005 And ord <> 57006 And ord <> 57007 And ord <> 63  Then
Response.write "" & vbcrlf & "                              if (!confirm(""停用产品单位,修改产品时可能影响该单位对应的价格策略!是否继续操作?"")) { return false; };" & vbcrlf & "                             "
end if
If ord = 47 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此接件类型吗?"")){ return false;}" & vbcrlf & "                         "
elseIf ord = 3001 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此质检方案吗?"")){ return false;}" & vbcrlf & "                         "
ElseIf ord = 85 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用奖罚分类吗?"")){return false;}" & vbcrlf & "                            "
ElseIf ord = 83 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此快递公司吗?"")){return false;}" & vbcrlf & "                          "
ElseIf ord = 100 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此报废原因吗?"")){return false;}" & vbcrlf & "                "
ElseIf ord = 25 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用预购分类吗?"")){return false;}" & vbcrlf & "                            "
ElseIf ord = 157 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此退料原因吗?"")){return false;}" & vbcrlf & "                          "
ElseIf ord = 158 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此废料原因吗?"")){return false;}" & vbcrlf & "                          "
ElseIf ord = 54001 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此不合格原因吗?"")){return false;}" & vbcrlf & "                                "
ElseIf ord = 54002 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此报废原因吗?"")){return false;}" & vbcrlf & "                          "
ElseIf ord = 54003 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此质检等级吗?"")){return false;}" & vbcrlf & "                          "
ElseIf ord = 54004 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此不合格原因吗?"")){return false;}" & vbcrlf & "                                "
ElseIf ord = 54005 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此质检等级吗?"")){return false;}" & vbcrlf & "                          "
ElseIf ord = 45001 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此直接入账分类吗?"")){return false;}" & vbcrlf & "                              "
ElseIf ord = 45002 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此直接出账分类吗?"")){return false;}" & vbcrlf & "                              "
ElseIf ord = 57000 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此分组吗?"")){return false;}" & vbcrlf & "                "
ElseIf ord = 57010 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用吗?"")){return false;}" & vbcrlf & "                            "
ElseIf ord = 57005 Then
Response.write "" & vbcrlf & "                    if(!confirm(""您确定要停用此不合格原因吗?"")){return false;}" & vbcrlf & "                          "
ElseIf ord = 57006 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此报废原因吗?"")){return false;}" & vbcrlf & "                          "
ElseIf ord = 57007 Then
Response.write "" & vbcrlf & "                              if(!confirm(""您确定要停用此质检等级吗?"")){return false;}" & vbcrlf & "                "
ElseIf ord = 63 Then
Response.write "" & vbcrlf & "                              if (!confirm(""您确定要停用此字段自定义分组吗?"")) { return false; }" & vbcrlf & "                "
end if
Response.write "" & vbcrlf & "              }" & vbcrlf & "               "
If ord=47 Then
Response.write "" & vbcrlf & "                      if (document.getElementById(""sID""+id).value==""启用"") {" & vbcrlf & "                              if(!confirm(""您确定要启用此接件类型吗?"")){return false;}" & vbcrlf & "          }" & vbcrlf & "               "
'If ord=47 Then
ElseIf ord = 57000 Then
Response.write "" & vbcrlf & "                if (document.getElementById(""sID""+id).value==""启用"") {" & vbcrlf & "                    if(!confirm(""您确定要启用此分组吗?"")){return false;}" & vbcrlf & "              }" & vbcrlf & "        "
'ElseIf ord = 57000 Then
ElseIf ord = 57010 Then
Response.write "" & vbcrlf & "                if (document.getElementById(""sID""+id).value==""启用"") {" & vbcrlf & "            if(!confirm(""您确定要启用吗?"")){return false;}" & vbcrlf & "        }" & vbcrlf & "           "
'ElseIf ord = 57010 Then
end if
Response.write "" & vbcrlf & "        if (id.length == 0) { return false; };" & vbcrlf & "" & vbcrlf & "        var url = ""setPUEnable.asp?id="" + id + ""&timestamp="" + new Date().getTime() + ""&date1="" + Math.round(Math.random() * 100);" & vbcrlf & "        xmlHttp.open(""GET"", url, false);" & vbcrlf & "xmlHttp.onreadystatechange = function () {" & vbcrlf & "            refState(id);" & vbcrlf & "        };" & vbcrlf & "        xmlHttp.send(null);" & vbcrlf & "    }" & vbcrlf & "" & vbcrlf & "    function refState(id) {" & vbcrlf & "        var objTD = document.getElementById(""tdID"" + id);" & vbcrlf & "        var objBT = document.getElementById(""sID"" + id);" & vbcrlf & "        if (xmlHttp.readyState < 4) {" & vbcrlf & "            objTD.innerHTML = ""loading..."";" & vbcrlf & "        }" & vbcrlf & "        if (xmlHttp.readyState == 4) {" & vbcrlf & "            var response = xmlHttp.responseText;" & vbcrlf & "            objTD.innerHTML = response;" & vbcrlf & "            if (response.indexOf(""启用"")>= 0) {" & vbcrlf & "                objBT.value = ""停用"";" & vbcrlf & "            }" & vbcrlf & "            else {" & vbcrlf & "                objBT.value = ""启用"";" & vbcrlf & "            }" & vbcrlf & "            " & vbcrlf & "            xmlHttp.abort();" & vbcrlf & "        }" & vbcrlf & "    }" & vbcrlf & "//-->" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "    </script>" & vbcrlf & "</head>" & vbcrlf & "" & vbcrlf & "<body bgcolor=""#ebebeb"">" & vbcrlf & "    "
'ElseIf ord = 57010 Then
Function Disabled()'
Dim useCountSql,useCount, invoiceType
useCount=0 : invoiceType = rs("id")
Select Case ord
Case 11
useCountSql="select count(*) from tel where trade="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 13,17
useCountSql="select count(*) from tel where ly="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 14
useCountSql="select count(*) from tel where jz="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 19
useCountSql="select count(*) from tel where credit="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 25
useCountSql="select count(*) from caigou_yg where sort1="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 31
useCountSql="select count(*) from sp where gate2=2 and sptype="& invoiceType'
useCount1=conn.Execute(useCountSql)(0)'
useCountSql="select count(*) from contract where sort="& invoiceType&" and del<>5"'
useCount2=conn.Execute(useCountSql)(0)'
useCount=useCount1+useCount2
'useCount2=conn.Execute(useCountSql)(0)'
Case 34
useCountSql="select count(1) from (select top 1 1 num from contractlist where del<>7 and invoiceType ="& invoiceType &" "&_
"  union all  select top 1 2 num  from caigoulist where del<>7 and invoiceType ="& invoiceType &" "&_
"  union all  select top 1 3 num  from xunjialist where del<>7 and invoiceType ="& invoiceType &" "&_
"  union all  select top 1 4 num  from M2_OutOrderlists where del<>7 and invoiceType ="& invoiceType &") t"
useCount=conn.Execute(useCountSql)(0)'
Case 45
useCountSql="select count(*) from repair_sl where del<>7 and jiedai = "& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 46
useCountSql="select count(*) from repair_sl where del<>7 and jinji = "& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 47
useCountSql="select count(b.id) from repair_sl_jian a inner join repair_sl_list b on a.repair_sl_list=b.id and b.del<>7 where a.del<>7 and a.sortid1= "& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
case 63
useCountSql="select count(id) from sys_sdk_BillFieldInfo where ProductZdyGroupId= "& invoiceType '
useCount=conn.Execute(useCountSql)(0)'
Case 71
useCountSql="select count(*) from sp where gate2 in (73001) and sptype="& invoiceType'
useCount1=conn.Execute(useCountSql)(0)'
useCountSql="select count(*) from caigou where sort="& invoiceType'
useCount2=conn.Execute(useCountSql)(0)'
useCount=useCount1+useCount2
'useCount2=conn.Execute(useCountSql)(0)'
Case 78
useCountSql="select count(*) from caigouQClist where QCRank="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 79
useCountSql="select count(*) from document where C_Level="& invoiceType'
useCount=conn.Execute(useCountSql)(0)
Case 80
useCountSql="select count(*) from shop_goods where sortonehy="& invoiceType'
useCount=conn.Execute(useCountSql)(0)
Case 85
useCountSql="select count(*) from M2_RewardPunish where RPClass="& invoiceType'
useCount=conn.Execute(useCountSql)(0)
Case 94 '
useCountSql="select count(*) from M2_MachineInfo where del=1 and cls="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 97 '
useCountSql="select count(*) from M2_WorkingFlows where del=1 and WFclass="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 98 '
useCountSql="select count(*) from reply where del=1 and sort98="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 99 '
useCountSql="select count(*) from M2_WorkingProcedures where del=1 and Wclass="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 100 '
useCountSql="select count(1) from M2_ProcedureProgres where del=1 and CHARINDEX(','+isnull(reason,'0')+',',',"&invoiceType&",')>0 "
'Case 100 '
useCount=conn.Execute(useCountSql)(0)'
Case 1080 '
useCountSql="select count(*) from gate where workPosition="& invoiceType
useCount=conn.Execute(useCountSql)(0)'
Case 5029 '
useCountSql="select count(*) from design where sort1="& invoiceType
useCount=conn.Execute(useCountSql)(0)'
Case 5030 '
useCountSql="select count(*) from design where level="& invoiceType
useCount=conn.Execute(useCountSql)(0)'
Case 8004 '
useCountSql="select count(*) from sale_knowledge where del = 1 and modeID = "& invoiceType
useCount=conn.Execute(useCountSql)(0)'
Case 10001 '
useCountSql="select count(*) from paybx where del = 1 and bxType = "& invoiceType
useCount=conn.Execute(useCountSql)(0)'
Case 3001 '
useCountSql="select count(*) from caigouqc where del<>2 and isnull(qc_id,0) = "& invoiceType
useCount=conn.Execute(useCountSql)(0)'
Case 157 '
useCountSql="select count(*) from M2_MaterialRegisterLists where del=1 and reason="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 158 '
useCountSql="select count(*) from M2_MaterialRegisterLists where del=1 and reason="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 54001 '
useCountSql="select count(*) from M2_QualityTestingLists where del=1 and bhgOpinion = "& invoiceType
useCount=conn.Execute(useCountSql)(0)'
Case 54002 '
useCountSql="select count(*) from M2_QualityTestingLists where del=1 and BFOpinion="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 54003 '
useCountSql="select count(*) from M2_QualityTestingLists where del=1 and QualityLevel="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 54004 '
useCountSql="select count(*) from M2_QualityTestingLists where del=1 and bhgOpinion="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 54005 '
useCountSql="select count(*) from M2_QualityTestingLists where del=1 and QualityLevel="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 45001 '
useCountSql="select count(*) from bankin where del=1 and typeord="& invoiceType'
useCount=conn.Execute(useCountSql)(0)
Case 45002 '
useCountSql="select count(*) from bankout where del=1 and typeord="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 57005 '
useCountSql="select count(*) from M2_GXQualityTestingResult where bhgOpinion = "& invoiceType
useCount=conn.Execute(useCountSql)(0)'
Case 57006 '
useCountSql="select count(*) from M2_GXQualityTestingResult where BFOpinion="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 57007 '
useCountSql="select count(*) from M2_GXQualityTestingResult where QualityLevel="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 57000 '
useCountSql="select count(*) from M2_QCProject where GroupID="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 57010 '
useCountSql="select count(*) from M2_QCProject where Unit="& invoiceType'
useCount=conn.Execute(useCountSql)(0)'
Case 13001 '
useCountSql="select isnull((select top 1 1 from price where sort1="& invoiceType &"),0)"
useCount=conn.Execute(useCountSql)(0)'
if useCount = 0 then '
useCount=conn.Execute("select isnull((select top 1 1 from sp_ApprovalRules where gate2=13001 and sptype=" & invoiceType &"),0)")(0)
end if
End Select
If useCount>0 Then Disabled="Disabled Title='当前对应项有数据，不能进行删除操作。'"
end function
function chkDisabled(ord,id)
dim intCount
if id="" or ord="" then exit function
select case ord & ""
Case "33"
chkDisabled = iif(conn.execute("select top 1 1 from sortonehy where id1=-23160 and id=" & id).eof = False," disabled=""disabled"" ","")
'Case "33"
case "61" '
intCount=conn.execute("select case when exists(select 1 from kuinlist where unit="&id&") then 1 else 0 end")(0) '
if intCount=1 then chkDisabled=" disabled=""disabled"" ":exit function
intCount=conn.execute("select case when exists(select 1 from ku where unit="&id&") then 1 else 0 end")(0) '
'if intCount=1 then chkDisabled=" disabled=""disabled"" ":exit function
intCount=conn.execute("select case when exists(select 1 from kuoutlist where unit="&id&") then 1 else 0 end")(0) '
'if intCount=1 then chkDisabled=" disabled=""disabled"" ":exit function
intCount=conn.execute("select case when exists(select 1 from kuoutlist2 where unit="&id&") then 1 else 0 end")(0) '
'if intCount=1 then chkDisabled=" disabled=""disabled"" ":exit Function
case else
end select
end function
set rs=server.CreateObject("adodb.recordset")
sql="select title from zdy where gl="&ord&" "
rs.open sql,conn,1,1
if rs.eof then
zdy_zd=""
else
zdy_zd=rs("title")
end if
rs.close
sql="select numv from erp_sys_temp_attr where [key]='是否开启票据类型'"
rs.open sql,conn,1,1
if rs.eof then
ord37 = "0"
else
ord37 = Cstr(rs("numv"))
end if
rs.close
set rs=Nothing
If ord = 37 Then
Response.write "" & vbcrlf & "    <script src=""../Script/s3_edit.js?ver="
Response.write Application("sys.info.jsver")
Response.write """ language=""javascript"" type=""text/javascript""></script>" & vbcrlf & "    "
end if
Select Case ord
Case 11 : name="客户行业"
Case 12 : name="过滤关键词"
Case 13 : name="客户来源"
Case 14 : name="客户价值"
Case 15 : name="威胁级别"
Case 16 : name="企业性质"
Case 17 : name="供应商分类"
Case 18 : name="供应商级别"
Case 19 : name="信用等级"
Case 21 : name="项目状态"
Case 23 : name="项目来源"
Case 24 : name="项目分类"
Case 25 : name="预购分类"
Case 31 : name="合同分类"
Case 32 : name="合同状态"
Case 33 : name="支付方式"
Case 34 : name="票据类型"
Case 35 : name="退货分类"
Case 36 : name="退货状态"
Case 37 : name="票据来源"
Case 41 : name="费用分类"
Case 45 : name="接待方式"
Case 46 : name="紧急程度"
Case 47 : name="接件类型"
Case 51 : name="售后分类"
Case 52 : name="紧急程度"
Case 53 : name="处理结果"
Case 54 : name="处理时间"
Case 55 : name="售后方式"
Case 56 : name="回访方式"
Case 57 : name="回访状态"
Case 58 : name="关怀方式"  '
Case 59 : name="关怀类型"  '
Case 61 : name="产品单位"  :  conn.close :  Response.redirect "../../SYSN/view/sales/product/UnitSetting.ashx"
Case 62 : name="工序要素"
Case 63 : name="产品自定义分组"
case 71 : name="采购分类"
case 75 : name="采购退货分类"
case 76 : name="采购退货状态"
case 78 : name="质检等级"
case 79 : name="机密级别"
case 81 : name="发货方式"
case 82 : name="包装方式"
case 83 : name="快递公司"
case 85 : name="奖罚分类"
case 91 : name="公告分类"
case 92 : name="导航分类"
case 93 : name="工作互动分类"
case 94 : name="设备分类"
case 97 : name="工艺流程分类"
case 98 : name="跟进方式"
case 99: name="工序分类"
case 100: name="报废原因"
case 8004 : name="知识库级别" '
case 1080 : name="岗位名称"
Case 10001 : name = "费用报销分类"
Case 80 : name  = "商品分类" '
Case 5029 : name="设计分类"
Case 5030 : name="设计等级"
Case 3001 : name = "质检方案"
Case 157 : name = "退料原因"
Case 158 : name = "废料原因"
Case 54001 : name = "不合格原因"
Case 54002 : name = "报废原因"
Case 54003 : name = "质检等级"
Case 54004 : name = "不合格原因"
Case 54005 : name = "质检等级"
Case 45001 : name = "直接入账分类"
Case 45002 : name = "直接出账分类"
Case 57000 : name = "质检项分组"
Case 57010 : name = "质检项单位"
Case 57005 : name = "不合格原因"
Case 57006 : name = "报废原因"
Case 57007 : name = "质检等级"
Case 13001 : name = "报价分类"
Case Else
if ord>100 and ord<200 Then name=zdy_zd
End Select
Response.write "" & vbcrlf & "    <table width=""100%"" border=""0"" align=""left"" cellpadding=""0"" cellspacing=""0"" bordercolor=""#E2E2E1"" bgcolor=""#FFFFFF"">" & vbcrlf & "        <tr>" & vbcrlf & "            <td width=""100%"" valign=""top"">" & vbcrlf & "                <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif""> "& vbcrlf & "                    <tr> "& vbcrlf &"                         <td class=""place"">"
if ord=45 or ord=46 or ord=47 then Response.write("受理单")
Response.write name
Response.write "设置</td>" & vbcrlf & "                        <td class='top_btns'>" & vbcrlf & "                            "
if (ord = 37) then
Response.write "" & vbcrlf & "                            <input type=""radio"" class=""invoice_sorce_open_close"" name=""RadioGroup1"" value=""1"" "
If(ord37 = "1") then
Response.write  "checked"
end if
Response.write ">开启" & vbcrlf & "                        <input type=""radio"" class=""invoice_sorce_open_close"" name=""RadioGroup1"" value=""0"" "
If(ord37 = "0") then
Response.write  "checked"
end if
Response.write ">关闭" & vbcrlf & "                        <input type=""button"" name=""Submit86"" value=""确定"" class=""anybutton"" onclick=""getCshild()"" /><span id=""MyMessageInfo""></span>" & vbcrlf & "                            "
else
Response.write "&nbsp;"
end if
Response.write "" & vbcrlf & "                        </td>" & vbcrlf & "                        <td align=""right"">" & vbcrlf & "                            "
addname = name
if ord=63 then addname="分组"
if (ord <> 37  or ord37 = "1" ) and ord<>83 And ord<>54003 And ord<>54005 then
Response.write "" & vbcrlf & "                            <input type=""button"" name=""Submit32"" value=""添加"
Response.write addname
Response.write """ class=""anybutton addnew_btn"" onclick=""javascript:window.open('add.asp?ord="
Response.write pwurl(ord)
Response.write "','newwin','width=' + 700 + ',height=' + 450 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')"" />" & vbcrlf & "                            "
'Response.write pwurl(ord)
end if
Response.write "" & vbcrlf & "                        </td>" & vbcrlf & "                                                <td align=""right"">" & vbcrlf & "                            "
if (ord= 54003 Or ord= 54005) and ord<>83 then
Response.write "" & vbcrlf & "                            <input type=""button"" name=""Submit32"" value="""
Response.write name
Response.write "添加"" class=""anybutton addnew_btn"" onclick=""javascript:window.open('add.asp?ord="
Response.write pwurl(ord)
Response.write "','newwin','width=' + 700 + ',height=' + 400 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')"" />" & vbcrlf & "                            "
'Response.write pwurl(ord)
end if
Response.write "" & vbcrlf & "                        </td>" & vbcrlf & "                        <td width=""3"">" & vbcrlf & "                            <img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "                    </tr>" & vbcrlf & "                </table>" & vbcrlf &"" & vbcrlf & "                <table width=""100%"" border=""1"" borderColor=""#ccc"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"" class=""resetTableBtn"">" & vbcrlf & "                    <tr border=""1"" class=""top resetGroupTableBg tableHeadBg"">" & vbcrlf & "        <td width=""30%"" style=""background:transparent;"">" & vbcrlf & "                            <div align=""center""><strong>"
select case ord
case 63 : Response.write "分组名称"
case else: Response.write name
end select
Response.write "</strong></div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
if (ord = 37) then
Response.write "" & vbcrlf & "                        <td width=""15%"">" & vbcrlf & "                            <div align=""center""><strong>期初余额</strong></div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
ElseIf ord=61 Or ord=25 Or ord=85 Or ord=157 Or ord=158 then
Response.write "" & vbcrlf & "                        <td width=""15%"">" & vbcrlf & "                            <div align=""center""><strong>启用状态</strong></div>" & vbcrlf & "                        </td>" & vbcrlf & "                                             "
ElseIf ord=54001 Or ord=54002 Or ord=54003  Or ord=54004 Or ord=54005 Or ord=157 Or ord=158 Or ord=57000 Or ord=57010 Or ord=57005 Or ord=57006 Or ord=57007 then
Response.write "" & vbcrlf & "                        <td width=""15%"">" & vbcrlf & "                            <div align=""center""><strong>启用状态</strong></div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
ElseIf ord=19 then
Response.write "" & vbcrlf & "                        <td width=""15%"">" & vbcrlf & "                            <div align=""center""><strong>信用金额</strong></div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
end if
If ord=34 then
Response.write "" & vbcrlf & "                        <td width=""6%"">" & vbcrlf & "                            <div align=""center""><strong>税率</strong></div>" & vbcrlf & "                        </td>" & vbcrlf & "                        <td width=""6%"">" & vbcrlf & "                            <div align=""center""><strong>价税分离</strong></div>" & vbcrlf & "                        </td>" & vbcrlf & "                        <td width=""10%"">" & vbcrlf & "                            <div align=""center""><strong>启用状态</strong></div>" & vbcrlf & "                        </td>" & vbcrlf & "              <td width=""10%"">" & vbcrlf & "                            <div align=""center""><strong>发票最大金额</strong></div>" & vbcrlf & "                        </td>" & vbcrlf & "                        <td width=""10%"">" & vbcrlf & "                            <div align=""center""><strong>发票最大明细</strong></div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
ElseIf ord=47 Or ord=83 Or ord=3001 Or ord=100 Then
Response.write "" & vbcrlf & "                        <td width=""10%"">" & vbcrlf & "                            <div align=""center""><strong>启用状态</strong></div>" & vbcrlf & "                        </td>" & vbcrlf & "                                             "
ElseIf ord=1080 then
Response.write "" & vbcrlf & "                        <td width=""15%"">" & vbcrlf & "                            <div align=""center""><strong>定额能力</strong></div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
end if
If ord=71 then
Response.write "" & vbcrlf & "                        <td width=""10%"">" & vbcrlf & "                            <div align=""center""><strong>简称</strong></div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
end if
Response.write "" & vbcrlf & "                         <td width=""10%"">" & vbcrlf & "                            <div align=""center""><strong>重要指数</strong></div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
If ord=46 Or ord=25 Then
Response.write "" & vbcrlf & "                        <td width=""10%"">" & vbcrlf & "                            <div align=""center""><strong>代表颜色</strong></div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
end if
Response.write "" & vbcrlf & "                        <td width=""25%"">" & vbcrlf & "                            <div align=""center""><strong>操作</strong>　</div>" & vbcrlf & "                        </td>" & vbcrlf & "                    </tr>" & vbcrlf & "                    "
CurrPage=clng(Request("CurrPage"))
set rs=server.CreateObject("adodb.recordset")
Select Case ord
Case 34:
sql = "select a.*,b.taxRate,b.adTax,b.maxAmount,b.maxCount from sortonehy a inner join invoiceConfig b on a.id = b.typeid where gate2='"&ord&"' and Del = 1 order by gate1 desc,isnull(id1,0) asc, a.id desc"
Case 37:
sql = "select * from sortonehy where gate2='"&ord&"' and Del = 1 order by gate1 desc"
Case 33:
sql="select * from sortonehy where gate2='"&ord&"'" & iif(ZBRuntime.MC(76000),""," and isnull(id1,0)<>-23160") & " order by gate1 desc,id"
'Case 33:
case 45001:
sql="select * from sortonehy where gate2='"&ord&"' ORDER BY isStop ,gate1 DESC ,id DESC "
case 45002:
sql="select * from sortonehy where gate2='"&ord&"' ORDER BY isStop ,gate1 DESC ,id DESC "
Case else
sql="select * from sortonehy where gate2='"&ord&"' order by gate1 desc" & iif(ord=1080,",ord"," ,ord desc")
End Select
rs.open sql,conn,3,1
if rs.RecordCount<=0 then
Response.write "<table align='center'><tr><td  align='center'>没有信息!</td></tr></table>"
else
i=0
rs.PageSize=20
PageCount=clng(rs.PageCount)
if CurrPage<=0 or CurrPage="" Then CurrPage=1
if CurrPage>=PageCount Then CurrPage=PageCount
BookNum=rs.RecordCount
rs.absolutePage = CurrPage
do until rs.eof
sort1=Replace(Replace(rs("sort1"),">","&gt;"),"<","&lt;")
isStop=rs("isStop")
id1=rs("id1")
if isNull(isStop) then isStop=0
If rs("gate2")="33" Then '
dispstr=""
If rs("sort1")="余额付款" Or id1 = -23160 Then  dispstr=" disabled='disabled' "
dispstr=""
end if
If rs("gate2")="63" Then '
dispstr=""
If rs("tagData")="1" Then  dispstr=" style='display:none' "
end if
isDefaultInvoiceType = false
If ord=34 And id1=-65535 Then isDefaultInvoiceType = true
isDefaultInvoiceType = false
Response.write "" & vbcrlf & "                    <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                        <td class=""name"">" & vbcrlf & "                            <div align="""
If ord=47 Then Response.write "left" Else Response.write "center"
Response.write """ style="""
If isDefaultInvoiceType Then Response.write "color:red"
Response.write """>"
Response.write sort1
Response.write "</div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
if (ord = 37) then
Response.write "" & vbcrlf & "                        <td class=""name"">" & vbcrlf & "                            <div align=""center"">"
Response.write rs("NowMoney")
Response.write "</div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
ElseIf ord=61  Or ord=25 Or ord=85 Or ord=157 Or ord=158 Then
Response.write "" & vbcrlf & "                        <td class=""name"" id=""tdID"
Response.write rs("id")
Response.write """>" & vbcrlf & "                            <div align=""center""><span "
if isStop=1 then
Response.write "style=""color:#CC0000"" "
else
Response.write "style=""color:#009933"" "
end if
Response.write ">"
if isStop=1 then
Response.write "停用"
else
Response.write "启用</span>"
end if
Response.write "</div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
ElseIf ord=45001  or ord=45002 Then
Response.write "" & vbcrlf & "                    <td class=""name"" id=""tdID"
Response.write rs("id")
Response.write """ style=""display:none"">" & vbcrlf & "                        <div align=""center""><span "
if isStop=1 then
Response.write "style=""color:#CC0000"" "
else
Response.write "style=""color:#009933"" "
end if
Response.write ">"
if isStop=1 then
Response.write "停用"
else
Response.write "启用</span>"
end if
Response.write "</div>" & vbcrlf & "                    </td>" & vbcrlf & "                    "
ElseIf ord=19 then
NowMoney = rs("NowMoney")
Response.write "<td>" & vbcrlf & "                            <div align=""center"">RMB"
Response.write Formatnumber(NowMoney,num_dot_xs,-1)
'Response.write "<td>" & vbcrlf & "                            <div align=""center"">RMB"
Response.write "</div>" & vbcrlf & "                        </td>" & vbcrlf & "                                             "
ElseIf ord=54001  Or ord=54002 Or ord=54003 Or ord=54004 Or ord=54005 Or ord=57000 Or ord=57010 Or ord=57005 Or ord=57006 Or ord=57007 Then
Response.write "" & vbcrlf & "                        <td class=""name"" id=""tdID"
Response.write rs("id")
Response.write """>" & vbcrlf & "                            <div align=""center""><span "
if isStop=1 then
Response.write "style=""color:#CC0000"" "
else
Response.write "style=""color:#009933"" "
end if
Response.write ">"
if isStop=1 then
Response.write "停用"
else
Response.write "启用</span>"
end if
Response.write "</div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
end if
If ord=34 Then
Response.write "" & vbcrlf & "                        <td class=""name"">" & vbcrlf & "                            <div align=""center"">"
Response.write Formatnumber(rs("taxRate"),num_dot_xs,-1)
Response.write "</div>" & vbcrlf & "                        </td>" & vbcrlf & "                        <td class=""name"">" & vbcrlf & "                            <div align=""center"">"
If rs("adTax").value=0 then
Response.write "否"
else
Response.write "是"
end if
Response.write "</div>" & vbcrlf & "                        </td>" & vbcrlf & "                        <td class=""name"" id=""tdID"
Response.write rs("id")
Response.write """>" & vbcrlf & "                            <div align=""center"">" & vbcrlf & "                                <span "
if isStop=1 then
Response.write "style=""color:#CC0000"" "
else
Response.write "style=""color:#009933"" "
end if
Response.write ">"
if isStop=1 then
Response.write "停用"
else
Response.write "启用"
end if
Response.write "</span>" & vbcrlf & "                            </div>" & vbcrlf & "                        </td>" & vbcrlf & "                        <td class=""name"">" & vbcrlf & "                            <div align=""center"">"
Response.write Formatnumber(rs("maxAmount"),num_dot_xs,-1)
Response.write "</div>" & vbcrlf & "                        </td>" & vbcrlf & "                        <td class=""name"">" & vbcrlf & "                            <div align=""center"">"
Response.write rs("maxCount")
Response.write "</div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
Elseif ord=47 Or ord=83 Or ord=3001 Or ord=100 Then
Response.write "" & vbcrlf & "                        <td id=""tdID"
Response.write rs("id")
Response.write """>" & vbcrlf & "                            <div align=""center"">" & vbcrlf & "                                <span "
if isStop=1 then
Response.write "style=""color:#CC0000"" "
else
Response.write "style=""color:#009933"" "
end if
Response.write ">"
If isStop&""="0" Then
Response.write "启用"
else
Response.write "停用"
end if
Response.write "</span>" & vbcrlf & "                            </div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
Elseif ord=1080 Then
NowMoney = rs("NowMoney")
if NowMoney&""="" then NowMoney = 0
Response.write "<td>" & vbcrlf & "                            <div align=""center"">"
Response.write Formatnumber(NowMoney,1,-1)
'Response.write "<td>" & vbcrlf & "                            <div align=""center"">"
Response.write "</div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
end if
If ord=71 Then
Response.write "" & vbcrlf & "                        <td class=""name"">" & vbcrlf & "                            <div align=""center"">"
Response.write rs("color")
Response.write "</div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
end if
Response.write "" & vbcrlf & "                        <td class=""name"">" & vbcrlf & "                            <div align=""center"">"
Response.write rs("gate1")
Response.write "</div>" & vbcrlf & "                        </td>" & vbcrlf & "                       "
If ord=46  Or ord=25 Then
Response.write "" & vbcrlf & "                        <td>" & vbcrlf & "                            <div align=""center"">" & vbcrlf & "                                "
color = ""
If rs("color")<>"" Then
color = rs("color")
else
color = "#2f496e"
end if
Response.write "" & vbcrlf & "                                <span style=""border: 1px; background: "
Response.write color
Response.write """>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" & vbcrlf & "                            </div>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
end if
Response.write "" & vbcrlf & "                        <td height=""25"" align=""center"" valign=""middle"" class=""func"">" & vbcrlf & "                            "
If ord=47 Or ord= 3001 Then
Response.write "" & vbcrlf & "                            <input type=""button"" value=""详情"" onclick=""javascript:window.open('detail.asp?id="
Response.write rs("id")
Response.write "&ord="
Response.write ord
Response.write "','newwincon','width=' + 700 + ',height=' + 400 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=200,top=150')"" />" & vbcrlf & "                            "
'Response.write ord
end if
If rs("gate2")=61 Then
dispstr = ""
If rs("id1") = 1000010 Then dispstr = "disabled"
end if
if ord=61 Or ord=34 Or ord=47 Or ord=25 Or ord=85  Or ord=83 Or ord=3001 Or ord=100 Or ord=157 Or ord=158 Or ord=54001 Or ord=54002 Or ord=54003 Or ord=54004 Or ord=54005  Or ord=45001 Or ord=45002 Or ord=57000 Or ord=57010 Or ord=57005 Or ord=57006 Or ord=57007 Then
Response.write "" & vbcrlf & "                            <input type=""button"" "
If isDefaultInvoiceType Then Response.write "disabled"
Response.write " name=""setEnable"" value="""
if isStop=1 then
Response.write "启用"
else
Response.write "停用"
end if
Response.write """ onclick=""javascript:setEnable('"
Response.write rs("id")
Response.write "','"
Response.write isStop
Response.write "');"" id=""sID"
Response.write rs("id")
Response.write """ />"
end if
Response.write "" & vbcrlf & "                            <input type=""button"" "
Response.write chkDisabled(ord,rs("id"))
Response.write " name=""Submit3c"" value=""修改"" onclick=""javascript:window.open('correct.asp?id="
Response.write pwurl(rs("id").value)
Response.write "&ord="
Response.write pwurl(ord)
Response.write "','newwincor','width=' + 700 + ',height=' + 400 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')"" />" & vbcrlf & "                            "
'Response.write pwurl(ord)
if ord=93 Then
Response.write "" & vbcrlf & "                            <input type=""button"" name=""Submitdel"" value=""删除"" onclick=""if(confirm('您确定要删除吗？')){window.location.href='delete.asp?ord="
Response.write rs("id")
Response.write "&CurrPage="
Response.write CurrPage
Response.write "&id="
Response.write ord
Response.write "';}"" />" & vbcrlf & "                            "
ElseIf ord<>83 Then
wxFlag = rs("id1")
If zbruntime.mc("75000") And ord=55 And wxFlag = "1000000" Then dispstr = "disabled='disabled'"
Response.write "" & vbcrlf & "                            <input type=""button"" "
Response.write dispstr
Response.write Disabled
If isDefaultInvoiceType Then Response.write "disabled"
Response.write chkDisabled(ord,rs("id"))
Response.write " name=""Submitdel"" value=""删除"" onclick=""if(confirm('您确定要删除吗？')){window.location.href='delete.asp?ord="
Response.write rs("id")
Response.write "&CurrPage="
Response.write CurrPage
Response.write "&id="
Response.write ord
Response.write "'}"" />"
end if
Response.write "" & vbcrlf & "                        </td>" & vbcrlf & "                    </tr>" & vbcrlf & "                    "
dispstr=""
i=i+1
'dispstr=""
if i>=rs.PageSize then exit do
rs.movenext
loop
Response.write "" & vbcrlf & "                </table>" & vbcrlf & "            </td>" & vbcrlf & "        </tr>" & vbcrlf & "        <tr>" & vbcrlf & "            <td class=""page"">" & vbcrlf & "                <table width=""100%"" border=""0"" align=""left"">" & vbcrlf & "                    <tr>" & vbcrlf & "                        <td width=""10%"" height=""30"">" & vbcrlf & "                            <div align=""center""></div>" & vbcrlf & "                        </td>" & vbcrlf & "                        <td>&nbsp;</td>" & vbcrlf & "                        <td width=""79%"">" & vbcrlf & "   <div align=""right"">" & vbcrlf & "                                "
Response.write rs.RecordCount
Response.write "个 | "
Response.write currpage
Response.write "/"
Response.write rs.pagecount
Response.write "页 | &nbsp;"
Response.write rs.pagesize
Response.write "条信息/页&nbsp;&nbsp;" & vbcrlf & "          "
if currpage=1 then
Response.write "" & vbcrlf & "                                <input type=""button"" name=""Submit4"" value=""首页"" class=""page"" />" & vbcrlf & "                                <input type=""button"" name=""Submit42"" value=""上一页"" class=""page"" />" & vbcrlf & "                                "
else
Response.write "" & vbcrlf & "                                <input type=""button"" name=""Submit4"" value=""首页"" class=""page"" onclick=""window.location.href='edit.asp?ord="
Response.write ord
Response.write "&currPage="
Response.write  1
Response.write "'"" />" & vbcrlf & "                                <input type=""button"" name=""Submit42"" value=""上一页"" onclick=""window.location.href='edit.asp?ord="
Response.write ord
Response.write "&currPage="
Response.write  currpage -1
'Response.write "&currPage="
Response.write "'"" class=""page"" />" & vbcrlf & "                                "
end if
if currpage=rs.pagecount then
Response.write "" & vbcrlf & "                                <input type=""button"" name=""Submit43"" value=""下一页"" class=""page"" />" & vbcrlf & "                                <input type=""button"" name=""Submit44"" value=""尾页"" class=""page"" />" & vbcrlf & "                                "
else
Response.write "" & vbcrlf & "                                <input type=""button"" name=""Submit43"" value=""下一页"" onclick=""window.location.href='edit.asp?ord="
Response.write ord
Response.write "&currPage="
Response.write  currpage + 1
'Response.write "&currPage="
Response.write "'"" class=""page"" />" & vbcrlf & "                                <input type=""button"" name=""Submit43"" value=""尾页"" onclick=""window.location.href='edit.asp?ord="
Response.write ord
Response.write "&currPage="
Response.write  rs.PageCount
Response.write "'"" class=""page"" />" & vbcrlf & "                                "
end if
Response.write "" & vbcrlf & "                            </div>" & vbcrlf & "                        </td>" & vbcrlf & "                    </tr>" & vbcrlf & "                    <script src=""../Script/s3_edit_1.js?ver="
Response.write Application("sys.info.jsver")
Response.write """ language=""javascript""></script>" & vbcrlf & "                </table>" & vbcrlf & "                "
end if
rs.close
set rs=nothing
conn.close
set conn=nothing
Response.write "" & vbcrlf & "            </td>" & vbcrlf & "        </tr>" & vbcrlf & "    </table>" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""

%>
