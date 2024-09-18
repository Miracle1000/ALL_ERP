<%@ language=VBScript %>
<%
	ZBRLibDLLNameSN = "ZBRLib3205"
	Sub ToSetActiveUrl(ByVal msg)
		ZBRuntime=""
		Response.redirect "manager/setactive.asp?msg=" & server.urlencode(msg)
	end sub
	function getCliIP()
		dim ips
		ips = Request.ServerVariables("HTTP_X_FORWARDED_FOR") & ""
		If ips = "" Then ips = Request.ServerVariables("REMOTE_ADDR")
		if ips = "::1" then  ips = "127.0.0.1"
		If InStr(ips, ",") Then ips = Split(ips, ",")(0)
		getCliIP=ips
	end function
	Sub LoadMobileInfo
		on error resume next
		Dim z : Set z = server.createobject(ZBRLibDLLNameSN & ".Library")
		If Err.number <> 0 Then Call ShowErrorMsg ("系统无法运行", "环境初始化异常（P001）。", Err.description)
		If z.SplitVersion <3179 Then Call ShowErrorMsg ("系统启动失败", "<center class='r'>环境初始化异常（P005），<a onclick='showerror()' style='color:red' href='javascript:'><u>点击查看详情</u></a>。</center>", "运行库组件版本不正确。")
		z.GetLibrary "ZBIntel2013CheckBitString"
		If Err.number <> 0 Then Call ShowErrorMsg ("系统无法运行", "环境初始化异常（P002）。", Err.description)
		If z.Status <> 0 Then session("lastactiveerror") = Err.description & Chr(1) & z.Status & Chr(1) & z.checkvalue: ToSetActiveUrl "activeerror"
		If z.CheckFlag <> 0 Then  session("lastactiveerror") = Err.description & Chr(1) & "0" & Chr(1) & z.CheckFlag: ToSetActiveUrl "activeerror"
		Set z = Nothing
	end sub
	'Call LoadMobileInfo
	ZBRLibDLLNameSN = "ZBRLib3205"
	Set zblog = server.createobject(ZBRLibDLLNameSN & ".ZBSysLog")
	zblog.init me
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
	ZBRLibDLLNameSN = "ZBRLib3205"
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
'if v ="" Or isnumeric(v) = False then
			else
				deurl=v
			end if
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
	Response.AddHeader "X-UA-Compatible","IE=7"
	session.timeout=120
	dim conn,server_1,user_1,pw_1,sql_1
	function getConnectionText()
		Dim txt : txt = Application("_sys_connection")
		if len(txt) = 0 Then txt = sdk.database.ConnectionText
		server_1 = Application("_sys_sql_svr")
		sql_1 = Application("_sys_sql_db")
		user_1 = Application("_sys_sql_uid")
		pw_1 = Application("_sys_sql_pwd")
		getConnectionText = txt
	end function
	session("sys_userlastvistime") = now
	Sub InitConnection
		on error resume next
		Set conn = server.CreateObject("adodb.connection")
		conn.open getConnectionText()
		conn.CursorLocation = 3
		dim errmsg
		if err.number<>0 then
			Response.redirect "index4.asp"
		end if
	end sub
	Call InitConnection
	Call checkSuperDog(conn, "" , False)
	Function IsMustAutoSetup
		Set conn = server.CreateObject("adodb.connection")
		conn.open getConnectionText()
		conn.CursorLocation = 3
		If conn.execute("select count(id) from dbo.syscolumns where id = object_id('dbo.setjm3')").fields(0).value <5 Then
			IsMustAutoSetup = true
			Exit function
		end if
		If conn.execute("select count(id) from dbo.syscolumns where id = object_id('dbo.setjm')").fields(0).value <8 Then
			IsMustAutoSetup = true
			Exit function
		end if
		isMustAutoSetup = false
	end function
	If  isMustAutoSetup = True Then
		Response.clear
		Response.write "<meta http-equiv='content-type' content='text/html;charset=UTF-8'><center><br><br><br><span style='font-size:12px;color:red'>温馨提示：数据库表还未还原，请手动还原后再进行此操作。</span><br><br><br><a href='update/exec.asp' style='font-size:12px;color:blue;display:none' id='aaa'>忽略此问题强制继续</a></center><div style='position:absolute;top:0px;left:0px;width:20px;height:20px' ondblclick='aaa.style.display=""block""'>&nbsp;</div>"
		Response.end
		Response.redirect "update/exec.asp"
	end if
	sub error(message)
		Response.write "" & vbcrlf & "<script>alert('"
		Response.write message
		Response.write "');history.back();</script><script>window.close();</script>" & vbcrlf & ""
		call db_close : Response.end
	end sub
	Private Function getIP()
		Dim strIPAddr
		If Request.ServerVariables("HTTP_X_FORWARDED_FOR") = "" OR InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), "unknown") > 0 Then
			strIPAddr = Request.ServerVariables("REMOTE_ADDR")
		ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ",") > 0 Then
			strIPAddr = Mid(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), 1, InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ",")-1)
'ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ",") > 0 Then
		ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ";") > 0 Then
			strIPAddr = Mid(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), 1, InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ";")-1)
'ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ";") > 0 Then
		else
			strIPAddr = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
		end if
		If Trim(strIPAddr) = "::1" Then
			GetIP = "127.0.0.1"
		else
			GetIP = Trim(Mid(strIPAddr, 1, 30))
		end if
	end function
	Function GetUrl()
		Dim ScriptAddress,Servername,qs
		ScriptAddress = CStr(Request.ServerVariables("SCRIPT_NAME"))
		Servername = CStr(Request.ServerVariables("Server_Name"))
		qs=Request.QueryString
		if qs<>"" then
			GetUrl = ScriptAddress &"?"&qs
		else
			GetUrl = ScriptAddress
		end if
	end function
	function operationsystem()
		dim agent
		agent = Request.ServerVariables("HTTP_USER_AGENT")
		if Instr(agent,"NT 5.2")>0 then
			SystemVer="Windows Server 2003"
		elseif Instr(agent,"NT 5.1")>0 then
			SystemVer="Windows XP"
		elseif Instr(agent,"NT 5.0")>0 then
			SystemVer="Windows 2000"
		elseif Instr(agent,"NT 4.0")>0 or Instr(agent,"NT 3.1")>0 or Instr(agent,"NT 3.5")>0 or Instr(agent,"NT 3.51 ")>0 then
			SystemVer="老版本Windows NT4"
		elseif Instr(agent,"4.9")>0 then
			SystemVer="Windows ME"
		elseif Instr(agent,"98")>0 then
			SystemVer="Windows 98"
		elseif Instr(agent,"95")>0 then
			SystemVer="Windows 95"
		elseif Instr(agent,"Vista")>0 then
			SystemVer="Windows Vista"
		elseif Instr(agent,"Windows 7")>0 then
			SystemVer="Windows 7"
		elseif Instr(agent,"Windows 8")>0 then
			SystemVer="Windows 8"
		elseif Instr(agent,"Server 2008 R2")>0 then
			SystemVer="Windows Server 2008 R2"
		elseif Instr(agent,"Server 2008")>0 then
			SystemVer="Windows Server 2008"
		elseif Instr(agent,"Server 2010")>0 then
			SystemVer="Windows Server 2010"
		elseif Instr(agent,"NT 6.2")>0 then
			SystemVer="Windows Slate"
		elseif Instr(agent,"CE")>0 then
			SystemVer="Windows CE"
		elseif Instr(agent,"PE")>0 then
			SystemVer="Windows PE"
		else
			SystemVer=""
		end if
		operationsystem=SystemVer
	end function
	function browser()
		dim agent
		agent = Request.ServerVariables("HTTP_USER_AGENT")
		if Instr(agent,"MSIE 6.0")>0 then
			browserVer="Internet Explorer 6.0"
		elseif Instr(agent,"MSIE 5.5")>0 then
			browserVer="Internet Explorer 5.5"
		elseif Instr(agent,"MSIE 5.01")>0 then
			browserVer="Internet Explorer 5.01"
		elseif Instr(agent,"MSIE 5.0")>0 then
			browserVer="Internet Explorer 5.00"
		elseif Instr(agent,"MSIE 4.0")>0 then
			browserVer="Internet Explorer 4.0"
		elseif Instr(agent,"TencentTraveler")>0 then
			browserVer="腾讯 TT"
		elseif Instr(agent,"Firefox")>0 then
			browserVer="Firefox"
		elseif Instr(agent,"Opera")>0 then
			browserVer="Opera"
		elseif Instr(agent,"Wap")>0 then
			browserVer="Wap浏览器"
		elseif Instr(agent,"Maxthon")>0 then
			browserVer="Maxthon"
		elseif Instr(agent,"MSIE 7.0")>0 then
			browserVer="Internet Explorer 7.0"
		elseif Instr(agent,"MSIE 8.0")>0 then
			browserVer="Internet Explorer 8.0"
		else
			browserVer=""
		end if
		browser=browserVer
	end function
	Sub db_close
		on error resume next
		If typename(conn) <> "Empty" And typename(conn) <> "Nothing" then
			conn.close
			Set conn = Nothing
		end if
	end sub
	sub close_list(args)
		open_rz_system = Application("_open_rz_system")
		if len(open_rz_system) = 0 then
			set rs3=server.CreateObject("adodb.recordset")
			sql3="select intro from setjm where ord=802"
			rs3.open sql3,conn,1,1
			if rs3.eof then
				open_rz_system=0
			else
				open_rz_system=rs3("intro")
			end if
			Application("_open_rz_system")=open_rz_system
			rs3.close
			set rs3=nothing
		end if
		if open_rz_system="1" then
			dim action_url,type_sys,type_brower
			dim uid
			uid = session("personzbintel2007")
			if isnumeric(uid) = false then uid = 0
			uid = uid
			action_url=GetUrl()
			action_url=replace(action_url,"'","''")
			type_sys=operationsystem()
			type_brower=browser()
			type_login=args
			sqlStr="Insert Into action_list(username,name,page1,time_login,type_sys,type_brower,type_login,ip,action1) values("
			sqlStr=sqlStr & uid & ",'"
			sqlStr=sqlStr & session("name2006chen") & "','"
			sqlStr=sqlStr & action_url & "', getdate(),'"
			sqlStr=sqlStr & type_sys & "','"
			sqlStr=sqlStr & type_brower & "',"
			sqlStr=sqlStr & type_login & ",'"
			sqlStr=sqlStr & getIP() & "','"
			sqlStr=sqlStr & action1 & "')"
			Conn.execute(sqlStr)
		end if
		conn.close
		set conn=nothing
	end sub
	sub addUserlog(args)
		dim action_url,type_sys,type_brower
		dim uid
		uid = session("personzbintel2007")
		if isnumeric(uid) = false then uid = 0
		uid = uid
		action_url=GetUrl()
		action_url=replace(action_url,"'","''")
		type_sys=operationsystem()
		type_brower=browser()
		type_login=args
		sqlStr="Insert Into action_list(username,name,page1,time_login,type_sys,type_brower,type_login,action1) values("
		sqlStr=sqlStr & uid & ",'"
		sqlStr=sqlStr & session("name2006chen") & "','"
		sqlStr=sqlStr & action_url & "','"
		sqlStr=sqlStr & now & "','"
		sqlStr=sqlStr & type_sys & "','"
		sqlStr=sqlStr & type_brower & "',"
		sqlStr=sqlStr & type_login & ",'"
		sqlStr=sqlStr & action1 & "')"
		on error resume next
		Conn.execute(sqlStr)
	end sub
	sub Response_redirect(url)
		on error resume next
		call db_close
		Response.redirect url
	end sub
	sql="if not exists(select * from syscolumns where id=object_id('setjm3') and name='intro') "&_
	"alter table setjm3 add intro nvarchar(50)"
	conn.execute sql
	set rs3=server.CreateObject("adodb.recordset")
	sql3="select intro from setjm3  where ord=6"
	rs3.open sql3,conn,1,1
	if rs3.eof then
		title_xtjm=""
	else
		title_xtjm=rs3("intro")
	end if
	rs3.close
	set rs3=nothing
	Sub CZBRuntimeStatus()
		if not isObject(ZBRuntime) then
			Call ToSetActiveUrl("环境初始化异常")
			Exit sub
		end if
		select case ZBRuntime.status
		case "-100"
'select case ZBRuntime.status
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1100）")
		case "-300"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1100）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1300）")
		case "-1"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1300）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1001）")
		case "-2"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1001）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1002）")
		case "-301"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1002）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1301）")
		case "-302"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1301）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1302）")
		case "-303"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1302）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1303）")
		case "-4"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1303）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1004）")
		case "-12"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1004）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：1012）")
		end Select
	end sub
	Sub ZBRunTimeRunStatus(ByVal chkcode)
		select case ZBRuntime.VChs(chkcode)
		case "-1"
'select case ZBRuntime.VChs(chkcode)
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：2001）")
		case "-2"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：2001）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：2002）")
		case "-3"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：2002）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：2003）")
		case "-4"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：2003）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：2004）")
		end select
		select case ZBRuntime.CheckFlag
		case "-10"
'select case ZBRuntime.CheckFlag
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：3010）")
		case "-1"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：3010）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：3001）")
		case "-2"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：3001）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：3002）")
		case "-3"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：3002）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：3003）")
		case "-4"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：3003）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：3004）")
		case "-5"
		'Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：3004）")
		Call ToSetActiveUrl("激活失败！请联系专属客服确认您的身份！（错误号：3005）")
		end Select
	end sub
	Response.write "" & vbcrlf & "<NOSCRIPT><IFRAME   SRC=*.html></IFRAME></NOSCRIPT>"
	function checkVersionCode(tmpvcode)
		if tmpvcode="" or len(tmpvcode)<>32 then
			Session.Abandon()
			Response.write "" & vbcrlf & "<script language=""javascript"">top.location=""index6.asp?p=1&ps="
			Response.write server.URLEncode("请输入数字签名!")
			Response.write """;</script>" & vbcrlf & ""
			Response.end
		end if
		sqlfunc="select * from sort7 where substring(sort1,6,16)='" & zbintelEncode(mid(tmpvcode,6,16),2) & "'"
		set rsfunc=conn.execute(sqlfunc)
		if rsfunc.eof then
			Session.Abandon()
			Response.write "" & vbcrlf & "<script language=""javascript"">top.location=""index6.asp?p=1&ps="
			Response.write server.URLEncode("请输入数字签名!")
			Response.write """;</script>" & vbcrlf & ""
			Response.end
		end if
	end function
	Public Function MD5(sMessage)
		Dim b64 : Set b64 = server.createobject(ZBRLibDLLNameSN & ".base64Class")
		MD5 = b64.md5(sMessage & "")
		Set b64 = Nothing
	end function
	function CheckPower2010(strori,strsub)
		if instr(1,","&cstr(strori&"")&",",","&cstr(trim(strsub&""))&",",1)>0 then
			CheckPower2010=true
		else
			CheckPower2010=false
		end if
	end function
	function powerdetail(sort1,sort2)
		set rs7=server.CreateObject("adodb.recordset")
		sql7="select * from power where ord="&session("personzbintel2007")&" and sort1="&sort1&" and sort2="&sort2
		rs7.open sql7,conn,1,1
		if not rs7.eof then
			if rs7("qx_open")=0 then
				tp=false
			else
				tp=true
			end if
		end if
		rs7.close
		set rs7=nothing
		powerdetail=tp
	end function
	function openPower(x1,x2)
		if x1<>"" and x2<>"" then
			set rs1=server.CreateObject("adodb.recordset")
			sql1="select qx_open from power  where ord="&session("personzbintel2007")&" and sort1="&x1&" and sort2="&x2&""
			rs1.open sql1,conn,1,1
			if rs1.eof then
				openPower=0
			else
				openPower=rs1("qx_open")
			end if
			rs1.close
			set rs1=nothing
		else
			openPower=0
		end if
	end function
	function introPower(x1,x2)
		if x1<>"" and x2<>"" then
			set rs1=server.CreateObject("adodb.recordset")
			sql1="select qx_intro from power  where ord="&session("personzbintel2007")&" and sort1="&x1&" and sort2="&x2&""
			rs1.open sql1,conn,1,1
			if rs1.eof then
				introPower=0
			else
				introPower=rs1("qx_intro")
			end if
			rs1.close
			set rs1=nothing
		else
			introPower=0
		end if
	end function
	function PurviewPower(AllPurviews,strPurview)
		if isNull(AllPurviews) or AllPurviews="" or strPurview="" then
			PurviewPower=False
			exit function
		end if
		PurviewPower=False
		if instr(AllPurviews,",")>0 then
			dim arrPurviews,i77
			arrPurviews=split(AllPurviews,",")
			for i77=0 to ubound(arrPurviews)
				if trim(arrPurviews(i77))=strPurview then
					PurviewPower=True
					exit for
				end if
			next
		else
			if AllPurviews=strPurview then
				PurviewPower=True
			end if
		end if
	end function
	function PowerStr(x1,x2)
		if x1<>"" and x2<>"" then
			if openPower(x1,x2)=3 or PurviewPower(introPower(x1,x2),trim(session("personzbintel2007")))=True then
				PowerStr=true
			else
				PowerStr=false
			end if
		else
			PowerStr=false
		end if
	end function
	function PowerAllPerson(x1,x2)
		PowerAllPerson=false
		if x1<>"" and x2<>"" then
			set rs1=server.CreateObject("adodb.recordset")
			sql1="select qx_open from power  where ord="&session("personzbintel2007")&" and sort1="&x1&" and sort2="&x2&""
			rs1.open sql1,conn,1,1
			if rs1.eof then
				PowerAllPerson=false
			else
				if rs1("qx_open")=3 then
					PowerAllPerson=true
				else
					PowerAllPerson=false
				end if
			end if
			rs1.close
			set rs1=nothing
		else
			PowerAllPerson=false
		end if
	end function
	function getPowerIntro(s1, s2)
		dim sql ,r , rs
		sql = "select case a.qx_open when 3 then '' when 1 then (case ql.sort when 3 then qx_intro when 1 then '' end) else '-222' end from power a inner join qxlblist ql on ql.sort1=" & s1 & " and ql.sort2=" & s2 & " where a.sort1 = " & s1 & " and a.sort2 = " & s2 & " and ord=" & session("personzbintel2007")
		set rs = conn.execute(sql)
		if not rs.eof then
			r = rs.fields(0).value
			if len(r) > 0 then
				r =  replace("" & r & ""," ","")
				while instr(r,",,") > 0
					r = replace(r,",,",",")
				wend
				r = replace(replace(replace("x" & r & "x","x,",""),",x",""),"x","")
			end if
			GetPowerIntro = r
		else
			GetPowerIntro = "-222"
			'GetPowerIntro = r
		end if
		rs.close
		set rs = nothing
	end function
	Function CSql(ByVal v)
		csql = Replace(v,"'","''")
	end function
	response.charset="UTF-8"
	'csql = Replace(v,"'","''")
    'response.write "RIH" : response.end
	dim rs,sql,i77,servername,urlkh,user,pass,yzm,guid,miyao,chinese
	conn.cursorlocation = 3
	dim actinon1
	action1="登录系统"
	application("_ZBM_Lib_isDebug")=""
	Call CZBRuntimeStatus
	DriveName = Left(Server.MapPath("."),3)
	' Set chkFSO = Server.createobject(ZBRLibDLLNameSN & ".CommFileClass")
	' DriveInfo = Abs(chkFSO.GetDiskVolume(DriveName))
	Set chkFSO = nothing
	chkcode=ucase(md5(DriveInfo&"-z@8"))
	'Set chkFSO = nothing
	'Call ZBRunTimeRunStatus(chkcode)
	UniqueName="zbintel@123" 'ZBRuntime.sUid
	session("UniqueName")=UniqueName
	dim lgsignkey
	function CErrSub(errid,   errmsg)
		response.Clear
		response.CharSet = "utf-8"
		'response.Clear
		response.BinaryWrite sdk.base64.UnicodeToUtf8("{result: " & errid & ",  message:""" & errmsg & """}")
		on error resume next
		conn.close
		Response.end
	end function
	function getloginSession(sessiondata, key)
		dim rs : rs = split(sessionData & "", chr(2))
		for i=0 to ubound(rs)
			dim item
			item = split(rs(i), chr(1))
			if lcase(item(0)) = lcase(key) then getloginSession = item(1) : exit function
		next
		getloginSession = ""
	end function
	sub RefreshSdkJsCssVer
		dim rs, skintimesign
		set rs = conn.execute("select nvalue from home_usconfig where name='sys.last.skintime'")
		if rs.eof = false then skintimesign = rs(0).value & ""
		rs.close
		dim sdklastf :  sdklastf  = sdk.file.GetLastTime(server.MapPath("../bin/ZBServices.sdk.dll"))
		if len(skintimesign)>0 then  skintimesign = "." & skintimesign
		Application("sys.info.jsver")  = replace(sdk.info.version & "", ".", "")  & "." & replace(replace(replace(sdklastf,"-",""),":","")," ",".")  & skintimesign
		'if len(skintimesign)>0 then  skintimesign = "." & skintimesign
		Application("sys.info.cdkey")  = ZBRuntime.cdk & ""
	end sub
	if request.QueryString("__msgid") = "refreshskin" then
		response.Clear
		call RefreshSdkJsCssVer
		Response.write "{""result"":""ok"", ""newcssversion"": """ & Application("sys.info.jsver") & """}"
		conn.close
		Response.end
	end if
    
	If len(request.Form("systemType") & "")> 0 Then
		Application("sys.info.systemtype")= request.Form("systemType")
	end if
	If Len(Trim(Application("sys.info.systemtype") & "")) = 0   Then
		Application("sys.info.systemtype") = 1
	end if
	lgsignkey = request.Form("sign")
	if instr(lgsignkey,"a9c212a32d2a")=0 then
		call CErrSub(41,  "sign参数无效 ("  +lgsignkey + ")" )
'if instr(lgsignkey,"a9c212a32d2a")=0 then
	end if
	session("clientloginurl") = request.Form("loginUrl")
	lgdatas = split(lgsignkey, "a9c212a32d2a")
	userid = clng(lgdatas(1))
	conn.cursorlocation = 3
	set rs = conn.execute("select  ord,username,jmgou, name, cateid, top1, time_login, sessionData from gate with(nolock) where ord=" & userid & " and del=1")
	if rs.eof  then
		call CErrSub(42,  "用户不存在")
		Response.end
	end if
    
	time_login = sdk.vbl.format( cdate(rs("time_login").value), "yyyy-MM-dd HH:mm:ss")
	'Response.end
	if md5(time_login & "tt") <> lgdatas(0) then
		call CErrSub(43,  "sign参数失效")
	end if
	sessionData = rs("sessionData").value & ""
	userid=rs("ord").value
	User = rs("username").value
	cnName = rs("name").value
	rs_cateid =  rs("cateid").value
	rs_top1 = rs("top1").value
	rs.close
	set rs = nothing
	if abs(datediff("s", time_login, now))> 30 then
		call CErrSub(43,  "验证信息已超时")
	end if
	conn.execute "update  gate set time_login='" & sdk.vbl.Format(DateAdd("s", 1, cdate(time_login)), "yyyy-MM-dd HH:mm:ss") & "' where ord=" & userid
	'call CErrSub(43,  "验证信息已超时")
	session("jmgou")= getloginSession(sessionData, "jmgou" )
	session("isjmg") = getloginSession(sessionData, "isjmg" )
	session("jmgpwd")= getloginSession(sessionData, "jmgpwd" )
	session("usermac")=getloginSession(sessionData, "usermac" )
	session("userip")= getCliIP()
	userip = session("userip")
	set tmprs_alpi=conn.execute("select isnull(num1,0) from setjm3 with(nolock) where ord=6001 and cateid=" & userid)
	if not tmprs_alpi.eof then
		Session("isAllowPasteImage")=tmprs_alpi(0)
	else
		Session("isAllowPasteImage")=0
	end if
	tmprs_alpi.close
	set tmprs_alpi=nothing
	If cnName&"" = "" Then cnName = ""
	session("personzbintel2007") = userid
	session("name2006chen")=Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(cnName&"","/",""),"""",""),"'",""),"\",""),":",""),"*",""),"?",""),"<",""),">",""),"|","")
	session("cateidzbintel")= rs_cateid
	session("adminokzbintel")="true2006chen"
	session("top1zbintel2007")=rs_top1
	session("cateidzbintel2")=""
	session("UniqueName")=UniqueName
	session("UniquePwd")=md5(left(UniqueName,8)&"zbintel807")
	if len(Application("sys.info.jsver") & "") = 0 then
		call RefreshSdkJsCssVer
	end if
	Call setPersonAge(userid)
	conn.execute "declare @t datetime; set @t=getdate();EXEC P_HrKQ_WriteAttendanceRecord " & session("personzbintel2007") & ",@t,'"&userip&"','',0,1"
	conn.execute "update gate set MobVisitToken='' where ord=" & session("personzbintel2007")
	conn.execute "delete home_usConfig where charindex('UserLoginSign_' ,name)=1"
	conn.execute "delete home_usConfig where  name like '%.asp%'  and charindex('/',name)>1  and [uid]=" & session("personzbintel2007")
	conn.execute "delete home_usConfig where len(isnull(tvalue,''))=0 and nvalue=0 and uid>0"
	randomize
	Dim tm : tm = CLng(rnd*899999+100000)
	'randomize
	sdk.init me
	if (Application("sys_debug") & "") = "1" then session("top1zbintel2007") = "1"
	call close_list(2)
	on error resume next
	zblog.tryRecoverSession
	ZBRuntime.LoadDBSysInfo '防止 Application("sys.info.configindex") 出现异常，此处再加载一次
	On Error GoTo 0
	Dim gurl
	call CErrSub(0,  "SYSA端登录成功")
	Sub setPersonAge(userid)
		If  sdk.glAttribute("checkin2.SetPersonAge.Runed") = "1" Then Exit Sub
		sdk.glAttribute("checkin2.SetPersonAge.Runed") = "1"
		conn.execute("update person set age=DATEDIFF(YY,year1,getdate()) where year1<>'' and ISDATE(year1)=1")
		conn.execute("update hr_person set age=DATEDIFF(YY,birthday,getdate()) where birthday is not null and ISDATE(birthday)=1")
	end sub
	
%>
