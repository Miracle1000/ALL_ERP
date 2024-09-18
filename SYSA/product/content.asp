<%@ language=VBScript %>
<%
	If request.querystring("__cmd")="qrcode" Then
		Response.write "<body style='background-color:white'><div style='text-align:center'><img src='" & request.querystring("imgurl") & "'></div>"
'If request.querystring("__cmd")="qrcode" Then
		Response.end
	end if
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
	
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_1=0
		intro_21_1=0
	else
		open_21_1=rs1("qx_open")
		intro_21_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_14=0
		intro_21_14=0
	else
		open_21_14=rs1("qx_open")
		intro_21_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=2"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_2=0
		intro_21_2=0
	else
		open_21_2=rs1("qx_open")
		intro_21_2=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_3=0
		intro_21_3=0
	else
		open_21_3=rs1("qx_open")
		intro_21_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_7=0
		intro_21_7=0
	else
		open_21_7=rs1("qx_open")
		intro_21_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_8=0
		intro_21_8=0
	else
		open_21_8=rs1("qx_open")
		intro_21_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=9"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_9=0
		intro_21_9=0
	else
		open_21_9=rs1("qx_open")
		intro_21_9=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_10=0
		intro_21_10=0
	else
		open_21_10=rs1("qx_open")
		intro_21_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_11=0
		intro_21_11=0
	else
		open_21_11=rs1("qx_open")
		intro_21_11=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_13=0
	else
		open_21_13=rs1("qx_open")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=18"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_18=0
		intro_21_18=0
	else
		open_21_18=rs1("qx_open")
		intro_21_18=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=20"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_20=0
		intro_21_20=0
	else
		open_21_20=rs1("qx_open")
		intro_21_20=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=21 and sort2=21"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_21=0
	else
		open_21_21=rs1("qx_open")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=21 and sort2=22"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_22=0
	else
		open_21_22=rs1("qx_open")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=1 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_1_1=0
		intro_1_1=0
	else
		open_1_1=rs1("qx_open")
		intro_1_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=1 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_1_14=0
		intro_1_14=0
	else
		open_1_14=rs1("qx_open")
		intro_1_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=23 and sort2=2"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_23_2=0
		intro_23_2=0
	else
		open_23_2=rs1("qx_open")
		intro_23_2=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_26_1=0
		intro_26_1=0
	else
		open_26_1=rs1("qx_open")
		intro_26_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=21"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_21=0
		intro_22_21=0
	else
		open_22_21=rs1("qx_open")
		intro_22_21=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_26_14=0
		intro_26_14=0
	else
		open_26_14=rs1("qx_open")
		intro_26_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	if open_21_1=3 then
		list=""
	elseif open_21_1=1 then
		list="and addcate in ("&intro_21_1&")"
	else
		list="and addcate=0"
	end if
	Str_Result="where del=1 "&list&""
	Str_Result2="and del=1 "&list&""
	
	ZBRLibDLLNameSN = "ZBRLib3205"
	Sub noCache
		Response.ExpiresAbsolute = #2000-01-01#
'Sub noCache
		Response.AddHeader "pragma", "no-cache"
'Sub noCache
		Response.AddHeader "cache-control", "private, no-cache, must-revalidate"
'Sub noCache
	end sub
	Sub echo(Byval str)
		Response.write(str)
		response.Flush()
	end sub
	Sub die(Byval str)
		if not isNul(str) then
			echo str
		end if
		call db_close : Response.end()
	end sub
	Function IsNum(Str)
		IsNum=False
		If Str<>"" then
			If RegTest(Str,"^[\d]+$")=True Then
'If Str<>"" then
				IsNum=True
			end if
		end if
	end function
	Function IsMoney(Str)
		IsMoney=False
		If Str<>"" then
			If RegTest(Str,"^[\d]+\.?[\d]+?$")=True Then
'If Str<>"" then
				IsMoney=True
			end if
		end if
	end function
	Function IsNegMoney(Str)
		IsNegMoney=False
		If Str<>"" then
			If RegTest(Str,"^\-[\d]+\.?[\d]+?$")=True Then
'If Str<>"" then
				IsNegMoney=True
			end if
		end if
	end function
	Function isNul(Byval str)
		if isnull(str) then
			isNul = true : exit function
		else
			if isarray(str) then isNul = false : exit function
			if str= "" then
				isNul = true : exit function
			else
				isNul = false : exit function
			end if
		end if
	end function
	Sub closers(byval rsobj)
		if isobject(rsobj) then
			rsobj.close
			set rsobj =nothing
		end if
	end sub
	Function getrsval(Byval sqlstr)
		dim rs
		set rs = conn.execute (sqlstr)
		if rs.eof then
			getrsval = ""
		else
			If isnumeric(rs(0)) Then
				getrsval = zbcdbl(rs(0))
			else
				getrsval = rs(0)
			end if
		end if
		call closers(rs)
	end function
	Function getrs(Byval sqlstr)
		set getrs = server.CreateObject("adodb.recordset")
		getrs.open sqlstr ,conn,1,3
	end function
	Function getrsArray(Byval sqlstr)
		set rsobj = getrs(sqlstr)
		if not rsobj.eof then
			getrsArray = rsobj.getrows
		end if
		call closers(rsobj)
	end function
	Function closeconn
		if isobject(conn) then
			conn.close
			set conn =nothing
		end if
	end function
	Function jsStr(Byval str)
		jsStr = "<script language=""JavaScript"" type=""text/javascript"">"&str&"</script>"
	end function
	Function alert(Byval str)
		alert = jsStr("alert("""&str&""")")
	end function
	Function alertgo(Byval str,Byval url)
		alertgo = alert(str)&jsStr("location.href="""&url&"""")
	end function
	Function confirm(Byval str,Byval url1,Byval url2)
		confirm = jsstr("if(confirm("""&str&""")){location.href="""&url1&"""}else{location.href="""&url2&"""}")
	end function
	Function jsPageGo(Byval page)
		if isnumeric(page) then
			jsPageGo = jsStr("history.go("&page&")")
		else
			jsPageGo = jsStr("location.href="""&page&"""")
		end if
	end function
	Function Historyback(msg)
		Historyback=JavaScriptSet("alert('"& msg &"');history.go(-1)")
'Function Historyback(msg)
	end function
	Function jspageback
		jspageback = jsPageGo(-1)
'Function jspageback
	end function
	Function JavaScriptSet(str)
		JavaScriptSet = "<script language=""JavaScript"" type=""text/javascript"">"&str&"</script>"
	end function
	function CloseSelf(msg)
		CloseSelf=JavaScriptSet("try{alert('"&Replace(msg,"'","")&"'); window.opener=null;window.open('','_self');window.close();}catch(e){}")
	end function
	function ReloadCloseSelf(msg)
		ReloadCloseSelf=JavaScriptSet("alert('"&Replace(msg,"'","")&"'); try{window.opener.location.reload();}catch(e1){} try{window.opener=null;window.open('','_self');window.close();}catch(e){}")
	end function
	function strLength(str)
		on error resume next
		dim WINNT_CHINESE
		WINNT_CHINESE    = (len("中国")=2)
		if WINNT_CHINESE then
			dim l,t,c
			dim i
			l=len(str)
			t=l
			for i=1 to l
				c=asc(mid(str,i,1))
				if c<0 then c=c+65536
'c=asc(mid(str,i,1))
				if c>255 then
					t=t+1
'if c>255 then
				end if
			next
			strLength=t
		else
			strLength=len(str)
		end if
		if err.number<>0 then err.clear
	end function
	function checkphone(str,num_code)
		dim arr_num,tmpnum,tmparr,areacode
		dim i
		if trim(str)="" or isnull(str) then exit function
		str=replace(replace(str,"/","-"),"\","-")
'if trim(str)="" or isnull(str) then exit function
		arr_num=split(str,"-")
'if trim(str)="" or isnull(str) then exit function
		tmpnum=""
		for i=0 to ubound(arr_num)
			tmparr=arr_num(i)
			if i=0 then
				if left(tmparr,1)="0" and (len(tmparr)=3 or len(tmparr)=4) then
					areacode=tmparr
				else
					tmpnum=tmparr
				end if
			else
				if left(tmparr,3)="400" or left(tmparr,3)="800" then
					areacode=""
				elseif left(str,1)="1" and len(str)=11 then
					areacode=""
				end if
				if tmpnum="" then
					tmpnum=tmparr
				else
					tmpnum=tmpnum & "-" & tmparr
				end if
			end if
		next
		if areacode=num_code then areacode=""
		checkphone=areacode & tmpnum
	end function
	function strFreMobil(strMobil)
		strFreMobil=""
		Set rs = server.CreateObject("adodb.recordset")
		for i=4 to 11
			sql="select areacode  from MOBILEAREA where shortno like ''+substring('"&strMobil&"', 1, "&i&")+'%'"
'for i=4 to 11
			rs.open sql,conn,3,1
			if not rs.eof then
				if rs.recordcount=1 then
					strFreMobil=rs("areacode")
					rs.close
					exit for
				else
					strFreMobil=""
				end if
			else
				strFreMobil=""
			end if
			rs.close
		next
		set rs=nothing
	end function
	function fenjiNum(StrNum)
		StrNum=replace(StrNum,"-",",,,,,,,,,,")
'function fenjiNum(StrNum)
		fenjiNum=StrNum
	end function
	function unfenjiNum(StrNum)
		StrNum=replace(StrNum,",,,,,,,,,,","-")
'function unfenjiNum(StrNum)
		unfenjiNum=StrNum
	end function
	Function RegTest(a,p)
		Dim reg
		RegTest=false
		Set reg = New RegExp
		reg.pattern=p
		reg.IgnoreCase = True
		If reg.test(a)Then
			RegTest=true
		else
			RegTest=false
		end if
	end function
	Function RegReplace(s,p,strReplace)
		Dim r
		Set r =New RegExp
		r.Pattern = p
		r.IgnoreCase = True
		r.Global = True
		RegReplace=r.replace(s,strReplace)
	end function
	Function GetRegExpCon(strng,patrn)
		Dim regEx, Match, Matches,RetStr
		RetStr=""
		Set regEx = New RegExp
		regEx.Pattern = patrn          ' 设置模式。'"\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
'Set regEx = New RegExp
		regEx.IgnoreCase = True
		regEx.Global = True
		Set Matches = regEx.Execute(strng)
		For Each Match In Matches
			if RetStr="" then
				RetStr=Match.Value
			else
				RetStr=RetStr&"$"&Match.Value
			end if
		next
		GetRegExpCon = RetStr
	end function
	function unPhone(StrNum)
		sqlci = "select callPreNum from gate where ord="&session("personzbintel2007")&""
		Set Rsci = server.CreateObject("adodb.recordset")
		Rsci.open sqlci,conn,1,1
		num_pre1=rsci("callPreNum")
		rsci.close
		set rsci=nothing
		if num_pre1<>"" then
			StrNum=RegReplace(StrNum,"^"&num_pre1&",","")
		end if
		if  RegTest(StrNum,"^0(13[0-9]|14[0-9]|15[^4]|17[0-9]|18[0-9])\d{8}$") then
			StrNum=RegReplace(StrNum,"^"&num_pre1&",","")
			StrNum=RegReplace(StrNum,"^0","")
		end if
		StrNum=unfenjiNum(StrNum)
		unPhone=StrNum
	end function
	sub strCheckBH(bhid,table,strBhID,str)
		if strBhID<>"" then
			Err.Clear
			set rs=server.CreateObject("adodb.recordset")
			sqlStr="select "&bhid&" from "&table&" where del<>7 and "&bhid&"='"&strBhID&"'"
			rs.open sqlStr,conn,1,1
			if not rs.eof then
				Response.write"<script language=javascript>alert('该"&str&"编号已存在！请返回重试');window.history.back(-1);</script>"
'if not rs.eof then
				call db_close : Response.end
			end if
			rs.close
			set rs=nothing
		end if
	end sub
	function getPersonSex(nameX,sexX)
		getPersonSex=""
		if nameX<>"" and sexX<>"" then
			if sexX="男" then
				getPersonSex=left(nameX,1)&"先生"
			elseif sexX="女" then
				getPersonSex=left(nameX,1)&"小姐"
			else
				getPersonSex=nameX
			end if
		else
			getPersonSex=nameX
		end if
	end function
	function getPersonJob(nameX,jobX)
		getPersonJob=""
		if nameX<>"" and jobX<>"" then
			if jobX<>"" then
				getPersonJob=left(nameX,1)&jobX
			else
				getPersonJob=nameX
			end if
		else
			getPersonJob=nameX
		end if
	end function
	function getNameJob(nameX,jobX)
		getNameJob=""
		if nameX<>"" and jobX<>"" then
			if jobX<>"" then
				getNameJob=nameX&jobX
			else
				getNameJob=nameX
			end if
		else
			getNameJob=nameX
		end if
	end function
	function isMobile(num1)
		isMobile=false
		if num1<>"" then
			isMobile=RegTest(num1,"^(13[0-9]|14[0-9]|15[^4]|16[0-9]|17[0-9]|18[0-9]|19[0-9])\d{8}$")
'if num1<>"" then
		else
			isMobile=false
		end if
	end function
	function myReplace(fString)
		myString=""
		if fString<>"" then
			myString=Replace(fString,"&","&amp;")
			myString=Replace(myString,"<","&lt;")
			myString=Replace(myString,">","&gt;")
			myString=Replace(myString,"&nbsp;","")
			myString=Replace(myString,chr(13),"")
			myString=Replace(myString,chr(10),"")
			myString=Replace(myString,chr(32),"&nbsp")
			myString=Replace(myString,chr(9),"")
			myString=Replace(myString,chr(39),"")
			myString=Replace(myString,chr(34),"&quot;")
			myString=Replace(myString,chr(8),"")
			myString=Replace(myString,chr(11),"")
			myString=Replace(myString,chr(12),"")
			myString=Replace(myString,Chr(32),"")
			myString=Replace(myString,Chr(26),"")
			myString=Replace(myString,Chr(27),"")
		end if
		myReplace=myString
	end function
	Function RemoveHTML(strHTML)
		Dim objRegExp, Match, Matches
		Set objRegExp = New Regexp
		objRegExp.IgnoreCase = True
		objRegExp.Global = True
		objRegExp.Pattern = "<.+?>"
'objRegExp.Global = True
		Set Matches = objRegExp.Execute(strHTML)
		For Each Match in Matches
			strHtml=Replace(strHTML,Match.Value,"")
		next
		RemoveHTML=strHTML
		Set objRegExp = Nothing
	end function
	Function getTitle(str,byVal lens)
		if isnull(str) then getTitle="":exit function
		if str="" then
			getTitle="":exit function
		else
			dim str1
			str1=str
			str1=RemoveHTML(str1)
			if len(str1)=0 and len(str)>0 then str1="."
			if str1<>"" then
				str1=myReplace(str1)
				if str1<>"" then str1=replace(replace(replace(replace(replace(replace(str1,"&amp;nbsp;",""),"&amp;quot;",""),"&amp;amp;",""),"&amp;lt;",""),"&amp;gt;",""),"&nbsp","")
				if len(str)>lens then
					str1=left(str1,lens)&"."
				else
					str1=left(str1,lens)
				end if
			end if
			getTitle=str1
		end if
	end function
	Function getFirstName(str)
		getFirstName=""
		if str<>"" then
			strXing="欧阳|太史|端木|上官|司马|东方|独孤|南宫|万俟|闻人|夏侯|诸葛|尉迟|公羊|赫连|澹台|皇甫|宗政|濮阳|公冶|太叔|申屠|公孙|慕容|仲孙|钟离|长孙|宇文|司徒|鲜于|司空|闾丘|子车|亓官|司寇|巫马|公西|颛孙|壤驷|公良|漆雕|乐正|宰父|谷梁|拓跋|夹谷|轩辕|令狐|段干|百里|呼延|东郭|南门|羊舌|微生|公户|公玉|公仪|梁丘|公仲|公上|公门|公山|公坚|左丘|公伯|西门|公祖|第五|公乘|贯丘|公皙|南荣|东里|东宫|仲长|子书|子桑|即墨|达奚|褚师|吴铭"
			if instr(strXing,left(str,2))>0 then
				getFirstName=left(str,2)
			else
				getFirstName=left(str,1)
			end if
		else
			getFirstName=""
		end if
	end function
	Function NongliMonth(m)
		If m>=1 And m<=12 Then
			MonthStr=",正,二,三,四,五,六,七,八,九,十,十一,腊"
			MonthStr=Split(MonthStr,",")
			NongliMonth=MonthStr(m)
		else
			NongliMonth=m
		end if
	end function
	Function NongliDay(d)
		If d>=1 And d<=30 Then
			DayStr=",初一,初二,初三,初四,初五,初六,初七,初八,初九,初十,十一,十二,十三,十四,十五,十六,十七,十八,十九,二十,廿一,廿二,廿三,廿四,廿五,廿六,廿七,廿八,廿九,三十"
			DayStr=Split(DayStr,",")
			NongliDay=DayStr(d)
		else
			NongliDay=d
		end if
	end function
	Function htmlspecialchars(str)
		if len(str&"") = 0 then
			exit function
		end if
		str = Replace(str, "&", "&amp;")
		str = Replace(str, "&amp;#", "&#")
		str = Replace(str, "<", "&lt;")
		str = Replace(str, ">", "&gt;")
		str = Replace(str, """", "&quot;")
		htmlspecialchars = str
	end function
	function isEmail(num1)
		isEmail=false
		if num1<>"" then
			isEmail=RegTest(num1,"^$|^(\w{0,10}\[)?\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*(\])?$")
'if num1<>"" then
			if isEmail=false then
				isEmail=RegTest(num1,"^$|^([a-zA-Z0-9_\u4e00-\u9fa5]+\[)?\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*(\])?\;(([a-zA-Z0-9_\u4e00-\u9fa5]+\[)?\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*(\])?)*$")
			end if
		else
			isEmail=false
		end if
	end function
	function isobjinstalled(strclassstring)
		on error resume next
		isobjinstalled = false
		err = 0
		dim xtestobj
		set xtestobj = server.createobject(strclassstring)
		if 0 = err then isobjinstalled = true
		set xtestobj = nothing
		err = 0
	end function
	function DelAttach(sql_at)
		set rs_At=server.CreateObject("adodb.recordset")
		rs_At.open sql_at, conn,1,1
		if not rs_At.eof then
			FileName_At=server.MapPath(rs_At(0))
			set fso_At=server.CreateObject("scripting.filesystemobject")
			if fso_At.FileExists(FileName_At) then
				fso_At.DeleteFile FileName_At
			end if
			set fso_At=nothing
		end if
		rs_At.close
		set rs_At=nothing
	end function
	function DelAllAttach(sql_at)
		set rs_At=server.CreateObject("adodb.recordset")
		rs_At.open sql_at, conn,1,1
		if not rs_At.eof then
			do while not rs_At.eof
				FileName_At=server.MapPath(rs_At(0))
				set fso_At=server.CreateObject("scripting.filesystemobject")
				if fso_At.FileExists(FileName_At) then
					fso_At.DeleteFile FileName_At
				end if
				set fso_At=nothing
				rs_At.movenext
			loop
		end if
		rs_At.close
		set rs_At=nothing
	end function
	function getGateName(id)
		getGateName=""
		if id<>"" and isnumeric(id) then
			set rs_Gate=server.CreateObject("adodb.recordset")
			sql_Gate="select name from gate where  ord="&id&""
			rs_Gate.open sql_Gate,conn,1,1
			if not rs_Gate.eof then
				getGateName=rs_Gate("name")
			end if
			rs_Gate.close
			set rs_Gate=nothing
		end if
	end function
	function getSorceName(id)
		getSorceName="无"
		if id<>"" and isnumeric(id) then
			set rs_Gate=server.CreateObject("adodb.recordset")
			sql_Gate="select sort1 from gate1 where  ord="&id&""
			rs_Gate.open sql_Gate,conn,1,1
			if not rs_Gate.eof then
				getSorceName=rs_Gate("sort1")
			end if
			rs_Gate.close
			set rs_Gate=nothing
		end if
	end function
	function getSorce2Name(id)
		getSorce2Name="无"
		if id<>"" and isnumeric(id) then
			set rs_Gate=server.CreateObject("adodb.recordset")
			sql_Gate="select sort2 from gate2 where  ord="&id&""
			rs_Gate.open sql_Gate,conn,1,1
			if not rs_Gate.eof then
				getSorce2Name=rs_Gate("sort1")
			end if
			rs_Gate.close
			set rs_Gate=nothing
		end if
	end function
	function getUidSorceName(id)
		getUidSorceName="无"
		if id<>"" and isnumeric(id) then
			set rs_Gate=server.CreateObject("adodb.recordset")
			sql_Gate="select a.sort1 from gate1 a inner join gate b on a.ord=b.sorce where  b.ord="&id&" "
			rs_Gate.open sql_Gate,conn,1,1
			if not rs_Gate.eof then
				getUidSorceName=rs_Gate("sort1")
			end if
			rs_Gate.close
			set rs_Gate=nothing
		end if
	end function
	function getUidSorce2Name(id)
		getUidSorce2Name="无"
		if id<>"" and isnumeric(id) then
			set rs_Gate=server.CreateObject("adodb.recordset")
			sql_Gate="select a.sort2 from gate2 a inner join gate b on a.ord=b.sorce2 where  b.ord="&id&" "
			rs_Gate.open sql_Gate,conn,1,1
			if not rs_Gate.eof then
				getUidSorce2Name=rs_Gate("sort2")
			end if
			rs_Gate.close
			set rs_Gate=nothing
		end if
	end function
	function TbCompanyName(id)
		TbCompanyName=""
		if id<>"" and isnumeric(id) then
			set rs_Gate=server.CreateObject("adodb.recordset")
			sql_Gate="select name from tel where  ord="&id&""
			rs_Gate.open sql_Gate,conn,1,1
			if not rs_Gate.eof then
				TbCompanyName=rs_Gate("name")
			end if
			rs_Gate.close
			set rs_Gate=nothing
		end if
	end function
	function TbPersonName(id)
		TbPersonName=""
		if id<>"" and isnumeric(id) then
			set rs_Gate=server.CreateObject("adodb.recordset")
			sql_Gate="select name from person where  ord="&id&""
			rs_Gate.open sql_Gate,conn,1,1
			if not rs_Gate.eof then
				TbPersonName=rs_Gate("name")
			end if
			rs_Gate.close
			set rs_Gate=nothing
		end if
	end function
	function zbintelEmailEncode(inputstr,inputtype,rdNum)
		tmpstr=""
		if inputtype=1 then
			for i=1 to len(inputstr)
				tmpstr=tmpstr&emailgetChar(mid(inputstr,i,1),inputtype,rdNum)
			next
		else
			inputstr=replace(inputstr,"%","$")
			inputstr=replace(inputstr,"*","$")
			inputstr=replace(inputstr,"#","$")
			inputstr=replace(inputstr,"@","$")
			inputstr=replace(inputstr,"a","$")
			inputstr=replace(inputstr,"b","$")
			inputstr=replace(inputstr,"c","$")
			inputstr=replace(inputstr,"d","$")
			inputstr=replace(inputstr,"e","$")
			inputstr=replace(inputstr,"f","$")
			inputstr=replace(inputstr,"g","$")
			inputstr=replace(inputstr,"h","$")
			inputstr=replace(inputstr,"i","$")
			inputstr=replace(inputstr,"j","$")
			inputstr=replace(inputstr,"k","$")
			inputstr=replace(inputstr,"l","$")
			inputstr=replace(inputstr,"m","$")
			inputstr=replace(inputstr,"n","$")
			if instr(inputstr,"$")>0 then
				arrStr=split(inputstr,"$")
				for i=0 to Ubound(arrStr)-1
					arrStr=split(inputstr,"$")
					Response.write(arrStr(i)&"<br/>")
					tmpstr=tmpstr&Chr(arrStr(i)-rdNum)
					Response.write(arrStr(i)&"<br/>")
				next
			end if
		end if
		zbintelEmailEncode=tmpstr
	end function
	function emailgetChar(inputchar,chartype,rdNum)
		if inputchar<>"" then
			emailgetChar=(asc(inputchar)+rdNum)&randomStr(1)
'if inputchar<>"" then
		else
			emailgetChar=""
		end if
	end function
	Function randomStr(intLength)
		strSeed = "$%*#@abcdefghijklmn"
		seedLength = Len(strSeed)
		Str = ""
		Randomize
		For i = 1 To intLength
			Str = Str + Mid(strSeed, Int(seedLength * Rnd) + 1, 1)
'For i = 1 To intLength
		next
		randomStr = Str
	end function
	function urldecode(encodestr)
		newstr=""
		havechar=false
		lastchar=""
		for i=1 to len(encodestr)
'char_c=mid(encodestr,i,1)
			if char_c="+" then
				char_c=mid(encodestr,i,1)
				newstr=newstr & " "
			elseif char_c="%" then
				next_1_c=mid(encodestr,i+1,2)
'elseif char_c="%" then
				next_1_num=cint("&H" & next_1_c)
				if havechar then
					havechar=false
					newstr=newstr & chr(cint("&H" & lastchar & next_1_c))
				else
					if abs(next_1_num)<=127 then
						newstr=newstr & chr(next_1_num)
					else
						havechar=true
						lastchar=next_1_c
					end if
				end if
				i=i+2
				lastchar=next_1_c
			else
				newstr=newstr & char_c
			end if
		next
		urldecode=newstr
	end function
	function UTF2GB(UTFStr)
		if instr(UTFStr,"%")>0 then
			for Dig=1 to len(UTFStr)
				if mid(UTFStr,Dig,1)="%" then
					if len(UTFStr) >= Dig+8 then
'if mid(UTFStr,Dig,1)="%" then
						GBStr=GBStr & ConvChinese(mid(UTFStr,Dig,9))
						Dig=Dig+8
						GBStr=GBStr & ConvChinese(mid(UTFStr,Dig,9))
					else
						GBStr=GBStr & mid(UTFStr,Dig,1)
					end if
				else
					GBStr=GBStr & mid(UTFStr,Dig,1)
				end if
			next
			UTF2GB=GBStr
		else
			UTF2GB=UTFStr
		end if
		if UTF2GB="" then UTF2GB=UTFStr
	end function
	function ConvChinese(x)
		A=split(mid(x,2),"%")
		i=0
		j=0
		for i=0 to ubound(A)
			A(i)=c16to2(A(i))
		next
		for i=0 to ubound(A)-1
			A(i)=c16to2(A(i))
			DigS=instr(A(i),"0")
			Unicode=""
			for j=1 to DigS-1
				Unicode=""
				if j=1 then
					A(i)=right(A(i),len(A(i))-DigS)
'if j=1 then
					Unicode=Unicode & A(i)
				else
					i=i+1
					Unicode=Unicode & A(i)
					A(i)=right(A(i),len(A(i))-2)
'Unicode=Unicode & A(i)
'Unicode=Unicode & A(i)
				end if
			next
			if len(c2to16(Unicode))=4 then
				ConvChinese=ConvChinese & chrw(int("&H" & c2to16(Unicode)))
			else
				ConvChinese=ConvChinese & chr(int("&H" & c2to16(Unicode)))
			end if
		next
	end function
	function c2to16(x)
		i=1
		for i=1 to len(x) step 4
			c2to16=c2to16 & hex(c2to10(mid(x,i,4)))
		next
	end function
	function c2to10(x)
		c2to10=0
		if x="0" then exit function
		i=0
		for i= 0 to len(x) -1
			i=0
			if mid(x,len(x)-i,1)="1" then c2to10=c2to10+2^(i)
			i=0
		next
	end function
	function c16to2(x)
		i=0
		for i=1 to len(trim(x))
			tempstr= c10to2(cint(int("&h" & mid(x,i,1))))
			do while len(tempstr)<4
				tempstr="0" & tempstr
			loop
			c16to2=c16to2 & tempstr
		next
	end function
	function c10to2(x)
		mysign=sgn(x)
		x=abs(x)
		DigS=1
		do
			if x<2^DigS then
				exit do
			else
				DigS=DigS+1
				exit do
			end if
		loop
		tempnum=x
		i=0
		for i=DigS to 1 step-1
			i=0
			if tempnum>=2^(i-1) then
				i=0
				tempnum=tempnum-2^(i-1)
				i=0
				c10to2=c10to2 & "1"
			else
				c10to2=c10to2 & "0"
			end if
		next
		if mysign=-1 then c10to2="-" & c10to2
		c10to2=c10to2 & "0"
	end function
	Function checkFolder(folderpath)
		If CheckDir(folderpath) = false Then
			MakeNewsDir(folderpath)
		end if
	end function
	Function CheckDir(FolderPath)
		folderpath=Server.MapPath(".")&"\"&folderpath
		Set fso= CreateObject("Scripting.FileSystemObject")
		If fso.FolderExists(FolderPath) then
			CheckDir = True
		else
			CheckDir = False
		end if
		Set fso= nothing
	end function
	Function MakeNewsDir(foldername)
		dim fs0
		Set fso= CreateObject("Scripting.FileSystemObject")
		Set fs0= fso.CreateFolder(foldername)
		Set fso = nothing
	end function
	sub jsBack(str)
		Response.write("<script language='javascript' type='text/javascript'>alert('"&str&"');history.back()</script>")
		call db_close : Response.end
	end sub
	sub jsLocat(str,url)
		Response.write("<script language='javascript' type='text/javascript'>alert('"&str&"');window.location.href='"&url&"';</script>")
		call db_close : Response.end
	end sub
	sub jsLocat2(str,url)
		Response.write("<script language='javascript' type='text/javascript'>alert('"&str&"');window.parent.location.href='"&url&"';</script>")
		call db_close : Response.end
	end sub
	sub jsAlert(msg)
		Response.write("<script language='javascript' type='text/javascript'>alert('"& replace(msg,"'","\'") &"');</script>")
		on error resume next
		conn.close
		call db_close : Response.end
	end sub
	function DateZeros(str)
		if isnumeric(str) then
			if str<10 then
				DateZeros="0"&str
			else
				DateZeros=str
			end if
		else
			DateZeros=str
		end if
	end function
	Function CLngIP1(asNewIP)
		Dim lnResults
		Dim lnIndex
		Dim lnIpAry
		lnIpAry = Split(asNewIP, ".", 4)
		For lnIndex = 0 To 3
			If Not lnIndex = 3 Then lnIpAry(lnIndex) = lnIpAry(lnIndex) * (256 ^ (3 - lnIndex))
'For lnIndex = 0 To 3
			lnResults = lnResults * 1 + lnIpAry(lnIndex)
'For lnIndex = 0 To 3
		next
		if lnResults="" then lnResults=0
		CLngIP1 = lnResults
	end function
	Function CWebHost()
		serverUrl=Request.ServerVariables("Http_Host")
		CWebHost=false
		if RegTest(serverUrl,"^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*(\:[0-9]*)?\/*[0-9]*$") then
			CWebHost=false
			if instr(serverUrl,":")>0 then serverUrl=split(serverUrl,":")(0)
			if (CLngIP1(serverUrl)>=3232235520 and CLngIP1(serverUrl)<=3232301055) or (CLngIP1(serverUrl)>=167772160 and CLngIP1(serverUrl)<=184549375) or (CLngIP1(serverUrl)>=2130706432 and CLngIP1(serverUrl)<=2147483647) or CLngIP1(serverUrl)=0  then
				CWebHost=false
			else
				CWebHost=true
			end if
		else
			CWebHost=true
		end if
	end function
	sub checkMod(table,dataid,id,val)
		set rs9=server.CreateObject("adodb.recordset")
		sql="select "&dataid&" from "&table&" where  "&dataid&"="&id&" and ModifyStamp='"&val&"'"
		rs9.open sql,conn,1,1
		if  rs9.eof then
			call jsBack("此单据在您编辑过程中已有其他人进行了操作，请返回刷新重试！")
			call db_close : Response.end
		end if
		rs9.close
		set rs9=nothing
	end sub
	Function CheckLocalFileExist(ByVal file_dir)
		If Len(file_dir)=0 Then CheckLocalFileExist = False : Exit Function
		Dim fs : Set fs = Server.createobject(ZBRLibDLLNameSN & ".CommFileClass")
		CheckLocalFileExist = fs.ExistsFile(server.mappath(file_dir))
		Set fs = Nothing
	end function
	Function FormatTime(s_Time)
		Dim y, m, d
		FormatTime = ""
		if s_Time="" then Exit Function
		s_Time=replace(s_Time," ","")
		if instr(s_Time,"$")>0 then
			arr_time=split(s_Time,"$")
			for i=0 to ubound(arr_time)
				If IsDate(arr_time(i)) = False Then arr_time(i) = Date
				y = cstr(year(arr_time(i)))
				m = cstr(month(arr_time(i)))
				d = cstr(day(arr_time(i)))
				if timeList="" then
					timeList=y&"-"&m & "-" & d
'if timeList="" then
				else
					timeList=timeList&"$"&y&"-"&m & "-" & d
'if timeList="" then
				end if
			next
			FormatTime =timeList
		else
			If IsDate(s_Time) = False Then Exit Function
			y = cstr(year(s_Time))
			m = cstr(month(s_Time))
			d = cstr(day(s_Time))
			FormatTime =y&"-"&m & "-" & d
			d = cstr(day(s_Time))
		end if
	end function
	Function HrGetDateUnit(id)
		If id="" Then
			HrGetDateUnit =""
			Exit Function
		else
			select case id
			case 1
			HrGetDateUnit ="年"
			case 2
			HrGetDateUnit ="季"
			case 3
			HrGetDateUnit ="月"
			case 4
			HrGetDateUnit ="周"
			case 5
			HrGetDateUnit ="日"
			case else
			HrGetDateUnit =""
			end select
		end if
	end function
	function ReplaceSQL(str)
		if str<>"" and isnull(str)=false then
			str=trim(replace(str,"'","&#39"))
			str=trim(replace(str,"""","&#34"))
		end if
		ReplaceSQL=str
	end function
	function SaveRequestUrl(str)
		SaveRequestUrl=ReplaceSQL(request.QueryString(str))
	end function
	function SaveRequestForm(str)
		SaveRequestForm=ReplaceSQL(request.form(str))
	end function
	function SaveRequest(str)
		SaveRequest=ReplaceSQL(request(str))
	end function
	Function SaveRequestUrlNum(Str)
		Dim Num
		Num=ReplaceSQL(Request.QueryString(Str))
		If IsNum(Num)=False Then Num=0
		SaveRequestUrlNum=Num
	end function
	function RandomName()
		randomize
		RandomName=chr(int(rnd*26)+65)&chr(int(rnd*26)+65)&chr(int(rnd*26)+65)&chr(int(rnd*26)+65)&year(now)&month(now)&day(now)&second(now)&int(second(now)*rnd)+100
		randomize
	end function
	function GetFileEx(str)
		if instr(str,".")>0 then
			ArrStr=split(str,".")
			GetFileEx=ArrStr(ubound(ArrStr))
		else
			GetFileEx=""
		end if
	end function
	function TodayFolderName()
		TodayFolderName=year(now)&month(now)&day(now)
	end function
	function getGateBH(id)
		getGateBH=""
		if id<>"" and isnumeric(id) then
			set rsbh=server.CreateObject("adodb.recordset")
			sql="select  userbh  from hr_person where userID="&id&""
			rsbh.open sql,conn,1,1
			if not rsbh.eof then
				getGateBH=rsbh("userbh")
			end if
			rsbh.close
			set rsbh=nothing
		end if
	end function
	function GetFullSort(theTable,sortID,filed_id1, filed_sort1, filed_keyId, mark)
		if theTable&""<>"" then
			If sortID&"" = "" Then sortID = 0
			if filed_id1&"" = "" then filed_id1 = "id1"
			if filed_sort1&"" = "" then filed_sort1 = "sort1"
			if filed_keyId&"" = "" then filed_keyId = "id"
			if mark&"" = "" then mark = "-"
'if filed_keyId&"" = "" then filed_keyId = "id"
			dim rsf, rst, sortStr, id1, sort1
			sortStr=""
			Set rsf = conn.execute("select "& filed_id1 &","& filed_sort1 &" from "& theTable &" where "& filed_keyId &"=" & sortID)
			If rsf.Eof = False Then
				id1 = rsf(0)
				sort1 = TRIM(rsf(1))
				sortStr = sort1
				Dim sort_i
				For sort_i = 1 To 20
					Set rst=conn.execute("select "& filed_id1 &","& filed_sort1 &" from "& theTable &" where "& filed_keyId &"=" & id1)
					If rst.eof = true Then Exit For
					sortStr = TRIM(rst(1))& mark & sortStr
					id1 = rst(0)
					rst.Close
					Set rst = Nothing
				next
			end if
			rsf.Close
			Set rsf = Nothing
			GetFullSort = sortStr
		end if
	end function
	function formatNumB(numf,num1)
		if numf&""<>"" then
			if numf>1 then
				formatNumB = round(numf,num1)
			elseif numf>0 and numf<1 then
				numf2 = cstr(round(numf,num1))
				if left(numf2,1)="." then
					formatNumB = "0"& round(numf,num1)
				elseif left(numf2,2)="-." then
					formatNumB = "0"& round(numf,num1)
					formatNumB = "-0"& round(numf,num1)
					formatNumB = "0"& round(numf,num1)
				else
					formatNumB = round(numf,num1)
				end if
			else
				formatNumB = round(numf,num1)
			end if
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
	Function HTMLEncode2(fString)
		if not isnull(fString) Then
			fString = Replace(fString, CHR(32), "&nbsp;")
			fString = Replace(fString, CHR(34), "&quot;")
			fString = Replace(fString, CHR(39), "&#39;")
			fString = Replace(fString, CHR(13) & CHR(10), "<br>")
			fString = Replace(fString, CHR(13), "<br>")
			fString = Replace(fString, CHR(10), "<br>")
			HTMLEncode2 = fString
		end if
	end function
	Function HTMLDecode(fString)
		if not isnull(fString) Then
			fString = replace(fString, "&gt;", ">")
			fString = replace(fString, "&lt;", "<")
			fString = Replace(fString, "&nbsp;",CHR(32) )
			fString = Replace(fString, "&quot;",CHR(34) )
			fString = Replace(fString, "&#39;",CHR(39) )
			fString = Replace(fString, "<br>",CHR(13) & CHR(10))
			fString = Replace(fString, "<br>",CHR(13))
			fString = Replace(fString, "<br>",CHR(10))
			HTMLDecode = fString
		end if
	end function
	Function getKindsOfPrices(m_includeTax,priceValue,invoiceType)
		Dim pricesFun(2),rsFun,sqlFun
		pricesFun(0) = priceValue
		pricesFun(1) = priceValue
		pricesFun(2) = priceValue
		getKindsOfPrices = pricesFun
		If Len(Trim(invoiceType)&"")="0" Or invoiceType = 0 then
			sqlFun = "select b.* from sortonehy a,invoiceConfig b where b.typeid=a.id and a.gate2=34 and a.id1=-65535"
'If Len(Trim(invoiceType)&"")="0" Or invoiceType = 0 then
		else
			sqlFun = "select b.* from sortonehy a,invoiceConfig b where b.typeid=a.id and a.id =" & invoiceType
		end if
		Set rsFun = conn.execute(sqlFun)
		If rsFun.eof Then
			Exit Function
		else
			Err.clear
			on error resume next
			If m_includeTax = 1 Then
				pricesFun(1) = CDbl(priceValue)
				pricesFun(0) = CDbl(priceValue)/(1+ cdbl(rsFun("taxRate"))*0.01)
				pricesFun(1) = CDbl(priceValue)
				If Err.number <> 0 Then  pricesFun(0) = pricesFun(1)
			Else
				pricesFun(0) = CDbl(priceValue)
				pricesFun(1) = CDbl(priceValue) * (1  + cdbl(rsFun("taxRate"))* 0.01 )
				pricesFun(0) = CDbl(priceValue)
				If Err.number <> 0 Then  pricesFun(1) = pricesFun(0)
			end if
			On Error GoTo 0
			pricesFun(2) = CDbl(rsFun("taxRate"))
		end if
		rsFun.close
		getKindsOfPrices = pricesFun
	end function
	Function getGateLTable(sql2)
		Dim rs2
		If sql2&""<>"" Then
			Set rs2 = conn.execute("exec erp_comm_UsersTreeBase '"& sql2 &"',0")
			If rs2.eof = False Then
				conn.execute("if exists(select top 1 1 from tempdb..sysobjects where name='tempdb..#gate') drop table #gate; create table #gate(id int identity(1,1) not null, ord int, name nvarchar(200), orgstype int, deep int) ")
				While rs2.eof = False
					if rs2("NodeText")&"" = "" then
						t_NodeText=""
					else
						t_NodeText=rs2("NodeText")
						t_NodeText=Replace(t_NodeText,"'","''")
					end if
					conn.execute("insert into #gate(ord, name, orgstype, deep) values("& rs2("NodeId") &",'"& t_NodeText &"',"& rs2("orgstype") &","& rs2("NodeDeep") &")")
					rs2.movenext
				wend
			end if
			rs2.close
			Set rs2 = Nothing
		end if
	end function
	Function GetProductPic(proID)
		Dim rs,sql,temp
		If Len(proID&"") = 0 Then proID = 0
		sql = "SELECT TOP 1 fpath FROM sys_upload_res WHERE source = 'productPic' AND id1 = "& proID &" AND id2 = 1"
		set rs = conn.execute(sql)
		If Not rs.Eof Then
			temp = "<div align='center'><a  href='../edit/upimages/product/"& rs(0) &"' target='_blank'><img style='vertical-align: middle;' border='0' src=""../edit/upimages/product/"& Replace(rs(0),".","_s.") &"""></a></div>"
'If Not rs.Eof Then
		else
			temp = ""
		end if
		rs.close
		set rs = nothing
		GetProductPic = temp
	end function
	Function showImageBarCode(stype ,v , code,title)
		Dim s ,imgurl
		If stype=2 Then
			imgurl = "../code2/view.asp?sn=view&ct=46&data=CLDJ:"& v &"&width=120&errorh=3"
			s = "<a href='javascript:void(0)' onclick=""javascript:window.open('../code2/viewImage.asp?title="& server.urlencode(code) &"&imgurl=" & server.urlencode(imgurl) & "','imgurl_2','width=' + 320 + ',height=' + 320 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')""><img width='30' title='合同编号二维码' src='"& imgurl &"' style='padding-top:10px;cursor:pointer'></a>"
			imgurl = "../code2/view.asp?sn=view&ct=46&data=CLDJ:"& v &"&width=120&errorh=3"
		else
			imgurl = "../code2/viewCode.asp?codeType=128&data=HTID:"& v &"&height=60"
			s = "<div style='width:auto; display:inline-block !important; *zoom:1; display:inline; '><div style='text-align:center'><a href='javascript:void(0)' onclick=""javascript:window.open('../code2/viewImage.asp?codeType=128&title="& server.urlencode(code) &"&imgurl=" & server.urlencode(imgurl) & "&t="&now()&"','imgurl_1','width=' + 320 + ',height=' + 320 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')""><img  height='30' title='"&title&"' src='"& imgurl &"' style='cursor:pointer;'></a></div><div style='text-align:center'>"&v&"</div></div>"
			imgurl = "../code2/viewCode.asp?codeType=128&data=HTID:"& v &"&height=60"
		end if
		showImageBarCode = s
	end function
	function GetCpimg()
		sql = "select num1 from setjm3 where ord=20190823"
		set rs=conn.execute(sql)
		if not rs.eof then
			GetCpimg=rs(0)
		else
			conn.execute "insert into setjm3(ord,num1) values(20190823,0)"
			GetCpimg=0
		end if
		rs.close
		set rs=Nothing
	end function
	function GetAssistUnitTactics()
		sql = "select nvalue from home_usConfig where name='AssistUnitTactics' "
		set rsGetAssistUnitTactics=conn.execute(sql)
		if not rsGetAssistUnitTactics.eof then
			GetAssistUnitTactics=rsGetAssistUnitTactics(0)
		else
			conn.execute "insert into home_usConfig(name,nvalue,uid) values('AssistUnitTactics',0,0) "
			GetAssistUnitTactics=0
		end if
		rsGetAssistUnitTactics.close
		set rsGetAssistUnitTactics=Nothing
	end function
	function GetConversionUnitTactics()
		sql = "select nvalue from home_usConfig where name='ConversionUnitTactics' "
		set rsGetConversionUnitTactics=conn.execute(sql)
		if not rsGetConversionUnitTactics.eof then
			GetConversionUnitTactics=rsGetConversionUnitTactics(0)
		else
			conn.execute "insert into home_usConfig(name,nvalue,uid) values('ConversionUnitTactics',0,0) "
			GetConversionUnitTactics=0
		end if
		rsGetConversionUnitTactics.close
		set rsGetConversionUnitTactics=Nothing
	end function
	function ConvertUnitData(ProductID,OldUnit,NewUnit,Num)
		sql = "select (cast(" & Num & " as decimal(25,12)) * cast(a.bl/b.bl as decimal(25,12))  ) as num "&_
		"          from erp_comm_unitRelation a  "&_
		"          inner join erp_comm_unitRelation b on a.ord=b.ord and b.unit = " & NewUnit &_
		"          where a.ord =" & ProductID & " and a.unit = " & OldUnit
		if OldUnit = 0 then sql = "select " & Num & " as num "
		set rsConvertUnitData=conn.execute(sql)
		if not rsConvertUnitData.eof then
			ConvertUnitData=rsConvertUnitData(0)
		else
			ConvertUnitData=0
		end if
		rsConvertUnitData.close
		set rsConvertUnitData=Nothing
	end function
	function GetHistoryAssistUnit(ord)
		set rsGetHistoryAssistUnit= conn.execute("select nvalue from home_usConfig where  name='productDefaultAssistUnit_"&ord&"'  and isnull(uid, 0) =0")
		if rsGetHistoryAssistUnit.eof=false then
			if not rsGetHistoryAssistUnit(0)&"" = "" then
				GetHistoryAssistUnit = rsGetHistoryAssistUnit(0)
			else
				GetHistoryAssistUnit=0
			end if
			rsGetHistoryAssistUnit.close
			set rsGetHistoryAssistUnit=Nothing
		end if
	end function
	Sub SetHistoryAssistUnit(ord,assistUnit)
		if GetAssistUnitTactics()=1 then
			set rsSetHistoryAssistUnit = conn.execute("select * from home_usConfig where name='productDefaultAssistUnit_"&ord&"'")
			if rsSetHistoryAssistUnit.eof then
				conn.execute("insert into home_usConfig(nvalue,name,uid) values('"&assistUnit&"','productDefaultAssistUnit_"&ord&"',0)")
			else
				conn.execute("update home_usConfig set nvalue ='"&assistUnit&"' where name = 'productDefaultAssistUnit_"&ord&"'")
			end if
			rsSetHistoryAssistUnit.close
			set rsSetHistoryAssistUnit=Nothing
		end if
	end sub
	function IsDeletePayout2(ords)
		sql = "select top 1 1 from payout2 where CompleteType=8 and ord in ("&ords&") "
		set rs11=conn.execute(sql)
		IsDeletePayout2=rs11.eof
		rs11.close
		set rs11=Nothing
	end function
	function IsDeletePayout2Bybankin2(payout2)
		sql = "select top 1 1 from bankin2 where Payout2 in ("&payout2&") and money_left<money1"
		set rs11=conn.execute(sql)
		IsDeletePayout2Bybankin2=rs11.eof
		rs11.close
		set rs11=Nothing
	end function
	function IsOpenVoucherCForSKInvoice
		IsOpenVoucherCForSKInvoice = (sdk.GetSqlValue("select 1 from home_usConfig where name='Payback_Invoice_Voucher_Constraint' and nvalue=1" ,"0")="1")
	end function
	function IsOpenVoucherCForFKInvoice
		IsOpenVoucherCForFKInvoice = (sdk.GetSqlValue("select 1 from home_usConfig where name='Payout_Invoice_Voucher_Constraint' and nvalue=1" ,"0")="1")
	end function
	function IsOpenVoucherCForXTK
		IsOpenVoucherCForXTK = (sdk.GetSqlValue("select 1 from home_usConfig where name='Payout2_ContractTH_Voucher_Constraint' and nvalue=1" ,"0")="1")
	end function
	function IsOpenVoucherCForCTK
		IsOpenVoucherCForCTK = (sdk.GetSqlValue("select 1 from home_usConfig where name='Payout3_CaigouTH_Voucher_Constraint' and nvalue=1" ,"0")="1")
	end function
	
	dim open_26_1,intro_26_1,kh_list
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_26_1=0
		intro_26_1=0
	else
		open_26_1=rs1("qx_open")
		intro_26_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_26_14=0
		intro_26_14=0
	else
		open_26_14=rs1("qx_open")
		intro_26_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=2"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_26_2=0
		intro_26_2=0
	else
		open_26_2=rs1("qx_open")
		intro_26_2=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_26_3=0
		intro_26_3=0
	else
		open_26_3=rs1("qx_open")
		intro_26_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=5"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_26_5=0
		intro_26_5=0
	else
		open_26_5=rs1("qx_open")
		intro_26_5=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_26_7=0
		intro_26_7=0
	else
		open_26_7=rs1("qx_open")
		intro_26_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_26_8=0
		intro_26_8=0
	else
		open_26_8=rs1("qx_open")
		intro_26_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_26_10=0
		intro_26_10=0
	else
		open_26_10=rs1("qx_open")
		intro_26_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=2 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_2_1=0
		intro_2_1=0
	else
		open_2_1=rs1("qx_open")
		intro_2_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=2 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_2_14=0
		intro_2_14=0
	else
		open_2_14=rs1("qx_open")
		intro_2_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=2 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_2_13=0
		intro_2_13=0
	else
		open_2_13=rs1("qx_open")
		intro_2_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	if open_26_1=3 then
		list=""
	elseif open_26_1=1 then
		list="and cateid in ("&intro_26_1&")"
	else
		list="and cateid=0"
	end if
	dim rs,sql,Str_Result1,Str_Result2
	Str_Result1="where del=1 and sort3=2 "&list&""
	Str_Result2="and del=1 and sort3=2  "&list&""
	
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
			GetPowerIntro = r
		end if
		rs.close
		set rs = nothing
	end function
	
	Public Function GetCurrHomeUrl(ByRef cn)
		Dim u()
		Dim dvr
		dvr = sdk.setup.GetSetjm3Text(2015102301, 0)
		If InStr(dvr, ".") > 0 Then
			GetCurrHomeUrl = dvr&"/sysa"
		else
			GetCurrHomeUrl = app.homeurl&""
		end if
	end function
	Function CurrQrCodeImageUrl(rs , frss, appHomeUrl , ByVal ord)
		Dim logo, bgcolor, color, errhandle, width, height, data, entype, removeHtmlData
		Dim t
		on error resume next
		t = LCase(typename(cn))
		If t <> "connection" Then
			Set cn = conn
		end if
		On Error GoTo 0
		If rs.eof = False Then
			logo = rs("logo").value & ""
			bgcolor = rs("bgcolor").value
			color = rs("color").value
			errhandle = rs("errhandle").value
			width = rs("width").value
			height = rs("height").value
			entype = rs("entype").value
		else
			CurrQrCodeImageUrl = ""
			Exit function
		end if
		Dim billType
		If entype = 1 Then
			data = appHomeUrl & "/code2/view.asp?V" & app.Format(ord, "00000000")
		else
			Dim src, uValue, utype
			While frss.eof = False
				uValue = frss("uValue").value&""
				utype = frss("utype").value
				uname = frss("uname").value
				billType  = frss("billType").value &""
				If Len( uValue & "") > 0 Then
					If Len(data)  > 0 Then data = data & vbcrlf
					If utype = 4 Or utype = 9 Then
						src = uValue
						If isnumeric(src) Then
							src = appHomeUrl & "/sdk/bill.upload.asp?V" & app.base64.RsaEncode(src)
						end if
						uValue = src
					ElseIf utype = 6 Then
						tempValue= ""
						If uValue&""  = "1" Then
							tempValue= "是"
						elseIf not uValue&""  = "1" Then
							tempValue="否"
						end if
						uValue = tempValue
					ElseIf utype = 7 Then
						if len(uValue&"")>0 and isdate(uValue&"") then
							uValue = replace(FormatDateTime(uValue)&"","/","-")
'if len(uValue&"")>0 and isdate(uValue&"") then
						else
							uValue = ""
						end if
					ElseIf utype = 10 Then
						uValue=RemoveHTML(uValue&"")
					elseif uname = "流水号" then
						if len(billType)>0 and billType<>"0" then uValue = "B" & billType & uValue
					end if
					uname =uname & "："
					if frss("isShow").value="1" then uname=""
					data = data & uname & uValue
				end if
				frss.movenext
			wend
		end if
		CurrQrCodeImageUrl = appHomeUrl & "/code2/view.asp?errorh=" & errhandle & "&clr=" & server.urlencode(color) & "&bclr=" & server.urlencode(bgcolor) & "&data=" & server.urlencode(data) & "&width=" & width & "&logo=" & server.urlencode(logo)
	end function
	Function GetQrCodeImageUrl(ByVal ord)
		Dim logo, bgcolor, color, errhandle, width, height, data, entype, rs, removeHtmlData
		Dim t
		on error resume next
		t = LCase(typename(cn))
		If t <> "connection" Then
			Set cn = conn
		end if
		On Error GoTo 0
		Set rs = cn.execute("select  b.entype , a.logo, a.bgcolor, a.color, a.errhandle, a.width, a.height from C2_CodeItems a left join C2_CodeTypes b on a.ctype=b.id where a.id=" & ord)
		If rs.eof = False Then
			logo = rs("logo").value & ""
			bgcolor = rs("bgcolor").value
			color = rs("color").value
			errhandle = rs("errhandle").value
			width = rs("width").value
			height = rs("height").value
			entype = rs("entype").value
		else
			GetQrCodeImageUrl = ""
			rs.close
			Exit function
		end if
		rs.close
		Dim appHomeUrl,billType : appHomeUrl = GetCurrHomeUrl(cn)
		If entype = 1 Then
			data = appHomeUrl & "/code2/view.asp?V" & app.Format(ord, "00000000")
		else
			Dim src, url, uValue, utype
			Set rs = cn.execute("select a.*, b.utype,b.isShow ,ISNULL(ci.billType,'') billType from C2_CodeItemsFields a INNER JOIN dbo.C2_CodeItems ci ON ci.id = a.codeId left join C2_CodeTypeFields b on a.ftypeid=b.id  LEFT JOIN dbo.C2_CodeTypes ct ON b.cTypeId=ct.id  where a.codeid=" & ord & " ORDER BY CASE when ISNULL(ct.fromSys,2) = 2 then a.gate1 end, case when ct.fromSys != 2 then a.gate1 end desc , b.id ")
			While rs.eof = False
				uValue = rs("uValue").value&""
				utype = rs("utype").value
				uname = rs("uname").value
				billType  = rs("billType").value &""
				If Len( uValue & "") > 0 Then
					If Len(data)  > 0 Then data = data & vbcrlf
					If utype = 11 Or utype = 12 Then
						src = uValue
						If isnumeric(src) Then
							src = appHomeUrl & "/sdk/bill.upload.asp?V" & app.base64.RsaEncode(src)
						end if
						uValue = src
					ElseIf utype = 4 Then
						tempValue= ""
						If uValue&""  = "1" Then
							tempValue= "是"
						elseIf not uValue&""  = "1" Then
							tempValue="否"
						end if
						uValue = tempValue
					ElseIf utype = 1 Then
						if len(uValue&"")>0 and isdate(uValue&"") then
							uValue = replace(FormatDateTime(uValue)&"","/","-")
'if len(uValue&"")>0 and isdate(uValue&"") then
						else
							uValue = ""
						end if
					ElseIf utype = 2 Then
						uValue=FormatNumber(uValue,num1_dot,-1)
'ElseIf utype = 2 Then
					ElseIf utype = 3 Then
						uValue=FormatNumber(uValue,num_dot_xs,-1)
'ElseIf utype = 3 Then
					ElseIf utype = 3000 Then
						uValue=Formatnumber(uValue,SalesPrice_dot_num,-1)
'ElseIf utype = 3000 Then
					ElseIf utype = 13 Then
						uValue=RemoveHTML(uValue&"")
					elseif uname = "流水号" then
						if len(billType)>0 and billType<>"0" then uValue = "B" & billType & uValue
					ElseIf utype = 31 Then
						uValue = replace(uValue,",","->")
'ElseIf utype = 31 Then
					end if
					uname =uname & "："
					if rs("isShow").value="1" then uname=""
					data = data & uname & uValue
				end if
				rs.movenext
			wend
			rs.close
		end if
		GetQrCodeImageUrl = appHomeUrl & "/code2/view.asp?errorh=" & errhandle & "&clr=" & server.urlencode(color) & "&bclr=" & server.urlencode(bgcolor) & "&data=" & server.urlencode(data) & "&width=" & width & "&logo=" & server.urlencode(logo)
	end function
	Function GetQrCodeHtml(ByVal ord)
		Dim html
		html = "<div style='position:relative;border:0px solid red;wdith:auto'>"
		html = html & "<img id='commqrcodeimage' src='" & GetQrCodeImageUrl(ord) & "'>"
		html = html & "</div>"
		GetQrCodeHtml = html
	end function
	Function RemoveHTML(strHTML)
		Dim objRegExp, Match, Matches
		Set objRegExp = New Regexp
		objRegExp.IgnoreCase = True
		objRegExp.Global = True
		objRegExp.Pattern = "<.+?>"
'objRegExp.Global = True
		Set Matches = objRegExp.Execute(strHTML)
		For Each Match in Matches
			strHtml=Replace(strHTML,Match.Value,"")
		next
		RemoveHTML=strHTML
		Set objRegExp = Nothing
	end function
	
	Function getConnection()
		Dim connText
		if request.querystring("updateconnection")="1" then
			Application("_sys_connection") = ""
		end if
		connText = Application("_sys_connection") & ""
		If Len(connText) = 0 Then
			connText =  getConnectionText()
		end if
		Set conn = server.CreateObject("adodb.connection")
		on error resume next
		conn.open (connText)
		conn.cursorlocation = 3
		conn.CommandTimeout = 600
		if abs(err.number) > 0 then
			Response.write "数据库链接失败 - [" & err.Description & "]"
'if abs(err.number) > 0 then
			call AppEnd
		end if
		Set getConnection = conn
	end function
	Function GetPrintNum(sort,ord)
		Dim cn : Set cn = getConnection()
		If sort&"" = "" Then sort = 0
		If ord&"" = "" Then ord = 0
		Dim rs_Print : Set rs_Print = cn.execute ("select count(1) as PrintNum from PrinterInfo where sort = " & sort & " and formID = " & ord)
		GetPrintNum = rs_Print("PrintNum")
		rs_Print.close
		Set rs_Print = nothing
	end function
	Function GetPrintInfo(cn, datatype , ord , rType)
		Dim rs , times ,csStr , statusStr
		Set rs = cn.execute("select times from printtimes where datatype ="& datatype &" and ord=" & ord)
		If rs.eof = False Then
			statusStr = "<font color=green>[已打印]</font>"
			times =  rs("times").value
		else
			statusStr = "<font color=red>[未打印]</font>"
			times = 0
		end if
		rs.close
		Set rs=Nothing
		Dim withs : withs = 84+8*Len(times)
		Set rs=Nothing
		If rType=2 Then
			csStr = "<input type='button' name='btnPrint1' value='打印记录("& times &"次)'   onClick='javascript:window.open(""../Manufacture/inc/PrinterRrcorderList.asp?formid="& sdk.base64.pwurl(ord)&"&sort="& datatype &""",""newwin88"",""width="" + 900 + "",height="" + 500 + "",fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150"")'  class='anybutton' />"
		else
			csStr = times
		end if
		If rType = 1 Then
			GetPrintInfo = statusStr
		else
			GetPrintInfo = csStr
		end if
	end function
	Function SavePrintInfo(cn)
		dim id, formid, html, rs, [sort], ord, ord1  ,isSum,count
		id = request("id")
		formid = request("ord")
		[sort] = request("sort")
		isSum = request("isSum")
		If isSum&""="" Then isSum = 0
		count = request("count")
		If count&""="" Then count = 0
		html= ""
		if len(formid) = 0 then exit Function
		if len(id) = 0 or isnumeric(id)=0 then exit Function
		if len(sort) = 0 or isnumeric(sort)=0 then exit Function
		Dim oldcount : oldcount = GetPrintInfo(cn,[sort],formid,3)
		If cdbl(oldcount)-CDbl(count)<>0 And count>=0 Then
'Dim oldcount : oldcount = GetPrintInfo(cn,[sort],formid,3)
			SavePrintInfo = "count"
			exit Function
		end if
		on error resume next
		cn.begintrans
		formid = split(formid,",")
		for i = 0 to ubound(formid)
			if isnumeric(formid(i)) Then
				If cn.execute("select 1 from printtimes where datatype ="& [sort] &" and ord=" & formid(i)).eof=true Then
					cn.execute("insert into printtimes (datatype , ord ,times)values ("& [sort] &","& formid(i) &",1) ")
				else
					cn.execute("update printtimes set times = times + 1 where datatype ="& [sort] &" and ord=" & formid(i))
					cn.execute("insert into printtimes (datatype , ord ,times)values ("& [sort] &","& formid(i) &",1) ")
				end if
				cn.execute("insert into PrinterInfo (templateID, formID, sort, html, addCate, addDate,isSum,isOld) values (" & id & ", " & formid(i) & ", " & [sort] & ", '" & html & "', " & session("personzbintel2007") & ", '" & now() & "','"& isSum &"',1)")
				ord = GetIdentity("PrinterInfo","id","addcate","")
				cn.execute ("update PrinterInfo set ord = id where id = " & ord)
				cn.execute ("insert into PrinterHistory (PrinterInfoID, PrintCate, PrintDate) values (" & ord & ", " & session("personzbintel2007") & ", '" & now() & "')")
				ord1 = GetIdentity("PrinterHistory","id","PrintCate","")
				cn.execute ("update PrinterHistory set ord = id where id = " & ord1)
			end if
		next
		if err.number <> 0 Then
			cn.RollBackTrans
			SavePrintInfo = "false"
		else
			cn.CommitTrans
			SavePrintInfo = "true"
		end if
	end function
	sub Prt_add_logs(args,action1,sort)
		Dim rs3
		open_rz_system = Application("_open_rz_system")
		if len(open_rz_system) = 0 then
			set rs3=server.CreateObject("adodb.recordset")
			sql3="select intro from setjm where ord=802"
			rs3.open sql3,cn,1,1
			if rs3.eof then
				open_rz_system=0
			else
				open_rz_system=rs3("intro")
			end if
			Application("_open_rz_system")=open_rz_system
			rs3.close
			set rs3=nothing
		end if
		if open_rz_system="1" Then
			dim action_url,type_sys,type_brower,title
			If isnumeric(sort) Then
				set rs3=server.CreateObject("adodb.recordset")
				sql3="select title from PrintTemplate_Type where ord = " & sort
				rs3.open sql3,cn,1,1
				if rs3.eof then
					title=""
				else
					title=rs3("title")
				end if
				rs3.close
				set rs3=nothing
			end if
			action_url=GetUrl()
			action_url=replace(action_url,"'","''")
			type_sys=operationsystem()
			type_brower=browser()
			type_login=args
			sqlStr="Insert Into action_list(username,name,page1,time_login,type_sys,type_brower,type_login,action1) values("
			sqlStr=sqlStr & session("personzbintel2007") & ",'"
			sqlStr=sqlStr & session("name2006chen") & "','"
			sqlStr=sqlStr & action_url & "','"
			sqlStr=sqlStr & now & "','"
			sqlStr=sqlStr & type_sys & "','"
			sqlStr=sqlStr & type_brower & "',"
			sqlStr=sqlStr & type_login & ",'"
			sqlStr=sqlStr & title & action1 & "')"
			on error resume next
			cn.execute(sqlStr)
		end if
	end sub
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
			SystemVer="Windows Server 2012"
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
		ElseIf InStr(agent, "MSIE 9.0") > 0 Then
			browserVer = "Internet Explorer 9.0"
		ElseIf InStr(agent, "MSIE 10.0") > 0 Then
			browserVer = "Internet Explorer 10.0"
		ElseIf InStr(agent, "MSIE 11.0") > 0 Then
			browserVer = "Internet Explorer 11.0"
		ElseIf InStr(agent, "MSIE 12.0") > 0 Then
			browserVer = "Internet Explorer 12.0"
		else
			browserVer=""
		end if
		browser=browserVer
	end function
	Dim Code128A, Code128B, Code128C, EAN128
	Code128A = 0
	Code128B = 1
	Code128C = 2
	EAN128 = 3
	Function Val(ByVal s)
		if s&"" = "" Or Not Isnumeric(s) Then
			val = 0
		else
			val = clng(s)
		end if
	end function
	Function GetCode128(ByVal Char, ByRef ID, ByRef CodingBin, ByVal CodingType)
		Dim FindText,MyArray
		ID = -1
'Dim FindText,MyArray
		Select Case CodingType
		Case 0
		Select Case UCase(Char)
		Case "FNC3": ID = 96: Case "FNC2": ID = 97: Case "SHIFT": ID = 98: Case "CODEC": ID = 99
		Case "CODEB": ID = 100: Case "FNC4": ID = 101: Case "FNC1": ID = 102: Case "STARTA": ID = 103
		Case "STARTB": ID = 104: Case "STARTC": ID = 105: Case "STOP": ID = 106
		Case Else
		FindText = " !""#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_"
'Case Else
		For i = 0 To 31
			FindText = FindText & Chr(i)
		next
		ID = InStr(FindText, UCase(Char)) - 1
		FindText = FindText & Chr(i)
		End Select
		Case 1
		Select Case UCase(Char)
		Case "FNC3": ID = 96: Case "FNC2": ID = 97: Case "SHIFT": ID = 98: Case "CODEC": ID = 99
		Case "FNC4": ID = 100: Case "CODEA": ID = 101: Case "FNC1": ID = 102: Case "STARTA": ID = 103
		Case "STARTB": ID = 104: Case "STARTC": ID = 105: Case "STOP": ID = 106
		Case Else
		FindText = " !""#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~" & Chr(127)
'Case Else
		ID = InStr(FindText, Char) - 1
'Case Else
		End Select
'Case Else
		Select Case UCase(Char)
		Case "CODEB": ID = 100: Case "CODEA": ID = 101: Case "FNC1": ID = 102: Case "STARTA": ID = 103
		Case "STARTB": ID = 104: Case "STARTC": ID = 105: Case "STOP": ID = 106
		Case Else
		ID = Val(Char)
		End Select
		End Select
		MyArray = Array("11011001100","11001101100","11001100110","10010011000","10010001100","10001001100","10011001000","10011000100","10001100100","11001001000","11001000100","11000100100","10110011100","10011011100","10011001110","10111001100","10011101100","10011100110","11001110010","11001011100","11001001110","11011100100","11001110100","11101101110","11101001100","11100101100","11100100110","11101100100","11100110100","11100110010","11011011000","11011000110","11000110110","10100011000","10001011000","10001000110","10110001000","10001101000","10001100010","11010001000","11000101000","11000100010","10110111000","10110001110","10001101110","10111011000","10111000110","10001110110","11101110110","11010001110","11000101110","11011101000","11011100010","11011101110","11101011000","11101000110","11100010110","11101101000","11101100010","11100011010","11101111010","11001000010","11110001010","10100110000","10100001100","10010110000","10010000110","10000101100","10000100110","10110010000","10110000100","10011010000","10011000010","10000110100","10000110010","11000010010","11001010000","11110111010","11000010100","10001111010","10100111100","10010111100","10010011110","10111100100","10011110100","10011110010","11110100100","11110010100","11110010010","11011011110","11011110110","11110110110","10101111000","10100011110","10001011110","10111101000","10111100010","11110101000","11110100010","10111011110","10111101110","11101011110","11110101110","11010000100","11010010000","11010011100","1100011101011")
		If id>=0 then
			CodingBin = MyArray(ID)
		else
			CodingBin = ""
		end if
	end function
	Function GetCode128_ID(ByVal ID)
		Dim MyArray
		MyArray = Array("11011001100","11001101100","11001100110","10010011000","10010001100","10001001100","10011001000","10011000100","10001100100","11001001000","11001000100","11000100100","10110011100","10011011100","10011001110","10111001100","10011101100","10011100110","11001110010","11001011100","11001001110","11011100100","11001110100","11101101110","11101001100","11100101100","11100100110","11101100100","11100110100","11100110010","11011011000","11011000110","11000110110","10100011000","10001011000","10001000110","10110001000","10001101000","10001100010","11010001000","11000101000","11000100010","10110111000","10110001110","10001101110","10111011000","10111000110","10001110110","11101110110","11010001110","11000101110","11011101000","11011100010","11011101110","11101011000","11101000110","11100010110","11101101000","11101100010","11100011010","11101111010","11001000010","11110001010","10100110000","10100001100","10010110000","10010000110","10000101100","10000100110","10110010000","10110000100","10011010000","10011000010","10000110100","10000110010","11000010010","11001010000","11110111010","11000010100","10001111010","10100111100","10010111100","10010011110","10111100100","10011110100","10011110010","11110100100","11110010100","11110010010","11011011110","11011110110","11110110110","10101111000","10100011110","10001011110","10111101000","10111100010","11110101000","11110100010","10111011110","10111101110","11101011110","11110101110","11010000100","11010010000","11010011100","1100011101011")
		If id >=0 then
			GetCode128_ID = MyArray(ID)
		else
			GetCode128_ID = ""
		end if
	end function
	Function Get_EAN_128_Binary(ByVal Data, ByVal CodingType)
		Dim i, Ci
		Dim ID, CodinBin
		Dim CheckSum, CheckCodeID
		Dim CodeStop
		CodeStop = "1100011101011"
		Select Case CodingType
		Case 0
		Get_EAN_128_Binary = "11010000100"
		For i = 1 To Len(Data)
			Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128A)
			CheckSum = CheckSum + i * ID
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128A)
			Get_EAN_128_Binary = Get_EAN_128_Binary + CodinBin
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128A)
		next
		CheckCodeID = (103 + CheckSum) Mod 103
		Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128A)
		Get_EAN_128_Binary = Get_EAN_128_Binary + GetCode128_ID(CheckCodeID) + CodeStop
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128A)
		Case 1
		Get_EAN_128_Binary = "11010010000"
		For i = 1 To Len(Data)
			Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128B)
			CheckSum = CheckSum + i * ID
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128B)
			Get_EAN_128_Binary = Get_EAN_128_Binary + CodinBin
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128B)
		next
		CheckCodeID = (104 + CheckSum) Mod 103
		Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128B)
		Get_EAN_128_Binary = Get_EAN_128_Binary + GetCode128_ID(CheckCodeID) + CodeStop
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128B)
		Case 2
		Get_EAN_128_Binary = "11010011100"
		For i = 1 To Len(Data) Step 2
			Ci = Ci + 1
'For i = 1 To Len(Data) Step 2
			Call GetCode128(Mid(Data, i, 2), ID, CodinBin, Code128C)
			CheckSum = CheckSum + Ci * ID
'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, Code128C)
			Get_EAN_128_Binary = Get_EAN_128_Binary + CodinBin
'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, Code128C)
		next
		CheckCodeID = (105 + CheckSum) Mod 103
		Call GetCode128(Mid(Data, i, 2), ID, CodinBin, Code128C)
		Get_EAN_128_Binary = Get_EAN_128_Binary + GetCode128_ID(CheckCodeID) + CodeStop
		Call GetCode128(Mid(Data, i, 2), ID, CodinBin, Code128C)
		Case Else
		Ci = 1
		CheckSum = 102
		Get_EAN_128_Binary = "11010011100" & "11110101110"
		For i = 1 To Len(Data) Step 2
			Ci = Ci + 1
'For i = 1 To Len(Data) Step 2
			Call GetCode128(Mid(Data, i, 2), ID, CodinBin, EAN128)
			CheckSum = CheckSum + Ci * ID
'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, EAN128)
			Get_EAN_128_Binary = Get_EAN_128_Binary + CodinBin
'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, EAN128)
		next
		CheckCodeID = (105 + CheckSum) Mod 103
		Call GetCode128(Mid(Data, i, 2), ID, CodinBin, EAN128)
		Get_EAN_128_Binary = Get_EAN_128_Binary + GetCode128_ID(CheckCodeID) + CodeStop
'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, EAN128)
		End Select
	end function
	Function Draw_Code128(ByVal Data, ByVal DrawWidth, ByVal ShowData, ByVal CodingType)
		Dim Binary128
		Dim Binary,CodeLineStr
		Dim i, J
		CodeLineStr=""
		If DrawWidth < 1 Then DrawWidth = 1
		Binary128 = Get_EAN_128_Binary(Data, CodingType)
		For i = 1 To Len(Binary128)
			Binary = Val(Mid(Binary128, i, 1))
			If Binary = 1 Then
				CodeLineStr = CodeLineStr & "1"
			else
				CodeLineStr = CodeLineStr & "0"
			end if
		next
		Draw_Code128 = "{w:'" & DrawWidth & "',d:'" & Data & "',code:'" & CodeLineStr & "'}"
	end function
	
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
	
	Function GetSettingHelper(conn)
		Set GetSettingHelper = New SettingHelperClass
		GetSettingHelper.init conn
	end function
	Class SettingHelperClass
		Private cn
		Private m_Shop
		Public Property Get Shop
		If isEmpty(m_Shop) Then
			Set m_Shop = New MMsgShopSetting
			m_Shop.init cn
		end if
		Set Shop = m_Shop
		End Property
		Public Sub init(conn)
			Set cn = conn
		end sub
	End Class
	Class MMsgShopSetting
		Private cn
		Private m_preOrderValidTime
		Private m_completedOrderValidTime
		Private m_completedOrderValidTimeUnit
		Private m_isShowRealStorage
		Private m_isSalePriceIncludeTax
		Private m_autoCreateTelCreator
		Private m_autoCreateTelCreatorName
		Private m_autoCreateTelCateid
		Private m_autoCreateTelCateName
		Private m_autoCreateTelSort1
		Private m_autoCreateTelSort2
		Private m_canUseInvoiceTypes
		Private m_freightSettings
		Private m_noInvoiceId
		Private m_wxContractSort
		Private m_freightProductOrd
		Private m_domain
		Private m_wxPayKindId
		Public Property Get domain
		If isEmpty(m_domain) Then
			Dim rs : Set rs = cn.execute("select hostname from MMsg_Config where id=1")
			If rs.eof = False Then
				m_domain = rs(0)
			else
				m_domain = ""
			end if
		end if
		domain = m_domain
			End Property
			Public Property Get preOrderValidTime
			If isEmpty(m_preOrderValidTime) Then
				Dim rs,sql,mi
				sql =        "SELECT ISNULL(nvalue,0) nvalue, " &_
				"( " &_
				"CASE tvalue " &_
				"   WHEN 'hour' THEN CAST(nvalue AS INT) * 60 " &_
				"   WHEN 'day' THEN CAST(nvalue AS INT) * 24 * 60 " &_
				"   ELSE nvalue " &_
				"END " &_
				") AS mi  " &_
				"FROM home_usConfig WHERE name = 'wx_OrderTerm_Incomplete' "
				Set rs = cn.Execute(sql)
				If Not rs.Eof Then
					mi = rs("mi")
				else
					mi = 0
				end if
				rs.Close : Set rs = Nothing
				m_preOrderValidTime = mi
			end if
			preOrderValidTime = m_preOrderValidTime
			End Property
			Public Property Get completedOrderValidTime
			If isEmpty(m_completedOrderValidTime) Then
				Dim rs,sql,n,t
				sql =        "SELECT ISNULL(nvalue,0) nvalue " &_
				"FROM home_usConfig WHERE name = 'wx_OrderTerm_Complete' "
				Set rs = cn.Execute(sql)
				If Not rs.Eof Then
					t = rs("nvalue")
				else
					t = 0
				end if
				rs.Close : Set rs = Nothing
				m_completedOrderValidTime = t
			end if
			completedOrderValidTime = m_completedOrderValidTime
			End Property
			Public Property Get completedOrderValidTimeUnit
			If isEmpty(m_completedOrderValidTimeUnit) Then
				Dim rs,sql,n,t
				sql =        "SELECT tvalue " &_
				"FROM home_usConfig WHERE name = 'wx_OrderTerm_Complete' "
				Set rs = cn.Execute(sql)
				If Not rs.Eof Then
					t = rs("tvalue")
				end if
				If t&"" = "" Then t = "day"
				rs.Close : Set rs = Nothing
				m_completedOrderValidTimeUnit = t
			end if
			completedOrderValidTimeUnit = m_completedOrderValidTimeUnit
			End Property
			Public Property Get isShowRealStorage
			If isEmpty(m_isShowRealStorage) Then
				Dim rs,sql,n,t
				sql =       "SELECT ISNULL(nvalue,0) nvalue " &_
				"FROM home_usConfig WHERE name = 'wx_SaleRule_Number' "
				Set rs = cn.Execute(sql)
				If Not rs.Eof Then
					n = CLng(rs("nvalue"))
				else
					n = 0
				end if
				rs.Close : Set rs = Nothing
				Dim result
				If n&"" = "1" Then
					result = True
				else
					result = False
				end if
				m_isShowRealStorage = result
			end if
			isShowRealStorage = m_isShowRealStorage
			End Property
			Public Property Get isSalePriceIncludeTax
			If isEmpty(m_isSalePriceIncludeTax) Then
				Dim rs,sql,n,t
				sql =       "SELECT ISNULL(nvalue,0) nvalue " &_
				"FROM home_usConfig WHERE name = 'wx_SaleRule_Price' "
				Set rs = cn.Execute(sql)
				If Not rs.Eof Then
					n = CLng(rs("nvalue"))
				else
					n = 0
				end if
				rs.Close : Set rs = Nothing
				Dim result
				If n&"" = "1" Then
					result = True
				else
					result = False
				end if
				m_isSalePriceIncludeTax = result
			end if
			isSalePriceIncludeTax = m_isSalePriceIncludeTax
			End Property
			Public Property Get completedTelSetting
			If autoCreateTelCreator = 0 Or autoCreateTelCateid = 0 Or autoCreateTelSort1 = 0 Or autoCreateTelSort2 = 0 Then
				completedTelSetting = False
			else
				completedTelSetting = True
			end if
			End Property
			Public Property Get completedBankSetting
			completedBankSetting = cn.execute("select top 1 1 from Shop_Payments where bank is null").eof
			End Property
			Public Property Get autoCreateTelCreator
			If isEmpty(m_autoCreateTelCreator) Then
				Dim rs : Set rs = cn.execute("select b.ord,b.name from home_usconfig a,gate b where a.name='wx_MMsgOrderAutoCreateTelCreator' and a.tvalue=b.ord")
				If rs.eof Then
					m_autoCreateTelCreator = 0 : m_autoCreateTelCreatorName = ""
				else
					m_autoCreateTelCreator = CLng(rs(0)) : m_autoCreateTelCreatorName = rs(1)
				end if
				rs.close
				Set rs=Nothing
			end if
			autoCreateTelCreator = m_autoCreateTelCreator
			End Property
			Public Property Get autoCreateTelCreatorName
			If isEmpty(m_autoCreateTelCreatorName) Then
				Me.autoCreateTelCreator
			end if
			autoCreateTelCreatorName = m_autoCreateTelCreatorName
			End Property
			Public Property Get autoCreateTelCateid
			If isEmpty(m_autoCreateTelCateid) Then
				Dim rs : Set rs = cn.execute("select b.ord,b.name from home_usconfig a,gate b where a.name='wx_MMsgOrderAutoCreateTelCate' and a.tvalue=b.ord")
				If rs.eof Then
					m_autoCreateTelCateid = 0 : m_autoCreateTelCateName = ""
				else
					m_autoCreateTelCateid = CLng(rs(0)) : m_autoCreateTelCateName = rs(1)
				end if
				rs.close
				Set rs=Nothing
			end if
			autoCreateTelCateid = m_autoCreateTelCateid
			End Property
			Public Property Get autoCreateTelCateName
			If isEmpty(m_autoCreateTelCateName) Then
				Me.autoCreateTelCateid
			end if
			autoCreateTelCateName = m_autoCreateTelCateName
			End Property
			Public Property Get autoCreateTelSort1
			If isEmpty(m_autoCreateTelSort1) Then
				Dim rs : Set rs = cn.execute("select tvalue from home_usconfig where name='wx_MMsgOrderAutoCreateTelSort1'")
				If rs.eof Then
					m_autoCreateTelSort1 = 0
				else
					m_autoCreateTelSort1 = CLng(rs(0))
				end if
				rs.close
				Set rs=Nothing
			end if
			autoCreateTelSort1 = m_autoCreateTelSort1
			End Property
			Public Property Get autoCreateTelSort2
			If isEmpty(m_autoCreateTelSort2) Then
				Dim rs : Set rs = cn.execute("select tvalue from home_usconfig where name='wx_MMsgOrderAutoCreateTelSort2'")
				If rs.eof Then
					m_autoCreateTelSort2 = 0
				else
					m_autoCreateTelSort2 = CLng(rs(0))
				end if
				rs.close
				Set rs=Nothing
			end if
			autoCreateTelSort2 = m_autoCreateTelSort2
			End Property
			Public Property Get canUseInvoiceTypes
			If isEmpty(m_canUseInvoiceTypes) Then
				Dim rs,sql,n,t
				Set rs = cn.Execute("SELECT tvalue FROM home_usConfig WHERE name = 'wx_Invoice' and len(ISNULL(tvalue,''))>0")
				If Not rs.Eof Then
					t = rs("tvalue")
				else
					t = Me.noInvoiceId
				end if
				rs.Close : Set rs = Nothing
				Set rs = cn.execute("select typeid from invoiceConfig where  typeid in (" & t & ")")
				t = ""
				While rs.eof = False
					If Len(t)>0 Then t = t & ","
					t = t & rs(0).value
					rs.movenext
				wend
				rs.close
				m_canUseInvoiceTypes = t
				If m_canUseInvoiceTypes & "" = "" Then m_canUseInvoiceTypes = Me.noInvoiceId & ""
			end if
			canUseInvoiceTypes = m_canUseInvoiceTypes
			End Property
			Public Property Get noInvoiceId
			If isEmpty(m_noInvoiceId) Then
				Dim rs : Set rs = cn.execute("select id from sortonehy where gate2=34 and id1=-65535 and id in (select typeid from invoiceConfig )")
'If isEmpty(m_noInvoiceId) Then
				If rs.eof Then
					m_noInvoiceId = 0
				else
					m_noInvoiceId = CLng(rs(0))
				end if
				rs.close
				Set rs=Nothing
			end if
			noInvoiceId = m_noInvoiceId
			End Property
			Public Property Get wxContractSort
			If isEmpty(m_wxContractSort) Then
				Dim rs : Set rs = cn.execute("select id from sortonehy where gate2=31 and id1=-65535")
'If isEmpty(m_wxContractSort) Then
				If rs.eof Then
					m_wxContractSort = 0
				else
					m_wxContractSort = CLng(rs(0))
				end if
				rs.close
				Set rs=Nothing
			end if
			wxContractSort = m_wxContractSort
			End Property
			Public Property Get wxPayKindId
			If isEmpty(m_wxPayKindId) Then
				Dim rs : Set rs = cn.execute("SELECT id FROM sortonehy where gate2=33 and id1=-23160")
'If isEmpty(m_wxPayKindId) Then
				If rs.eof = False Then
					m_wxPayKindId = rs("id")
				else
					m_wxPayKindId = -1
					m_wxPayKindId = rs("id")
				end if
				rs.close
				Set rs=Nothing
			end if
			wxPayKindId = m_wxPayKindId
			End Property
			Public Function payBankAccount(tag)
				Dim rs : Set rs = cn.execute("select bank from Shop_Payments where tag = '" & tag & "'")
				If rs.eof Then
					Err.raise "999", "zbintel", "支付方式（tag为'" & tag & "'）不存在，请核对数据！"
				else
					payBankAccount = rs(0)
				end if
				rs.close
				set rs = nothing
			end function
		Public Property Get freightSettings
		If isEmpty(m_freightSettings) Then
			Set m_freightSettings = New Shop_FreightSetting
			Dim rs,sql,n,t
			Set rs = cn.Execute("SELECT ISNULL(nvalue,0) nvalue,tvalue FROM home_usConfig WHERE name = 'wx_freight'")
			If Not rs.Eof Then
				n = CLng(rs("nvalue"))
				t = rs("tvalue")
			else
				n = 0
				t = 0
			end if
			rs.Close : Set rs = Nothing
			t = Split(t,"|")
			m_freightSettings.init n,t(1),t(0)
		end if
		Set freightSettings = m_freightSettings
		End Property
		Public Property Get freightProductOrd
		If isEmpty(m_freightProductOrd) Then
			Dim rs,sql,proID
			Set rs = cn.Execute("SELECT TOP 1 ord FROM product WHERE company = 1000000")
			If Not rs.Eof Then
				proID = rs("ord")
			else
				proID = 0
			end if
			rs.Close : Set rs = Nothing
			m_freightProductOrd = proID
		end if
		freightProductOrd = m_freightProductOrd
		End Property
		Public Sub init(conn)
			Set cn = conn
		end sub
	End Class
	Class Shop_FreightSetting
		Private m_freightType
		Private m_perPrice
		Private m_freight
		Public Property Get freightType
		freightType = m_freightType
		End Property
		Public Property Get perPrice
		perPrice = m_perPrice
		End Property
		Public Property Get freight
		freight = m_freight
		End Property
		Public Sub init(tp,p,f)
			If Not isEmpty(m_freightType) Then Exit Sub
			m_freightType = CLng(tp)
			m_perPrice = CDbl(p)
			m_freight = CDbl(f)
		end sub
	End Class
	
	Response.write "<style type=""text/css"">" & vbcrlf & ".accordion-bar-bg {" & vbcrlf & "       background: url(../images/m_table_top.jpg) no-repeat;" & vbcrlf & "   height: 30px;" & vbcrlf & "   cursor: pointer;" & vbcrlf & "}" & vbcrlf & ".accordion-bar-tit {" & vbcrlf & "   float: left;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".accordion-bar-tit span {" & vbcrlf & "  margin-left: 10px;" & vbcrlf & "      margin-top: 3px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".accordion-arrow-up,.accordion-arrow-down {" & vbcrlf & "    display: inline-block;" & vbcrlf & "  width: 14px;" & vbcrlf & "    height: 14px;" & vbcrlf & "   background: url(../images/r_down_14_14.png) no-repeat;" & vbcrlf & "}" & vbcrlf & ".accordion-arrow-up {" & vbcrlf & "  background: url(../images/r_up_14_14.png) no-repeat;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "" & vbcrlf & ".accordion-bar-btns {" & vbcrlf & "      float: right;" & vbcrlf & "   text-align: right;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".table_border {" & vbcrlf & "    padding:0;" & vbcrlf & "      margin:0;" & vbcrlf & "       background:none;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".table_border td {" & vbcrlf & "     margin:0;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "#content3 {" & vbcrlf & "   border-collapse: collapse;" & vbcrlf & "}" & vbcrlf & "#content3 td{" & vbcrlf & "    border:none;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "#MRPListShow table,#MRPSetup table{" & vbcrlf & "        border: none;" & vbcrlf & "   border-collapse: collapse;" & vbcrlf & "      padding:0;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf& "#MRPListShow table td,#MRPSetup table td {" & vbcrlf & "       border:none;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "td.no-border {border: none;}" & vbcrlf & "" & vbcrlf & ".zero-height,.zero-height td {" & vbcrlf & " *font-size: 0px;" & vbcrlf & "        *height: 0px;" & vbcrlf & "   *line-height: 0px;" & vbcrlf & "     *border-width: 0px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "/* 图片信息样式 begin */" & vbcrlf & "ul,li,img{margin:0; padding:0; list-style: none;}" & vbcrlf & ".multimage-gallery {" & vbcrlf & "       padding: 5px;" & vbcrlf & "}" & vbcrlf & ".multimage-gallery li {" & vbcrlf & "     float: left;" & vbcrlf & "    font-size: 0;" & vbcrlf & "    display: inline-block;" & vbcrlf & "    border: 1px dashed #CDCDCD;" & vbcrlf & "    margin-right: 10px;" & vbcrlf & "    position: relative;" & vbcrlf & "    vertical-align: top;" & vbcrlf & "    width: 96px;" & vbcrlf & "    height: 96px;" & vbcrlf & "    overflow: hidden" & vbcrlf & "    clear: left;" & vbcrlf & "    margin-bottom: 8px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .primary {" & vbcrlf & "    margin-left: 0;" & vbcrlf & "    border: 1px solid #ffc097;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & " .multimage-gallery .info {" & vbcrlf & "       position: absolute;" & vbcrlf & "    top: 25px;" & vbcrlf & "       left: 25px;" & vbcrlf & "    z-index: 3;" & vbcrlf & "    text-align: center;" & vbcrlf & "    font-size: 12px;" & vbcrlf & "   line-height: 20px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .preview {" & vbcrlf & "      padding:2px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .preview img {" & vbcrlf & "    width: 90px;" & vbcrlf & "    height: 90px;" & vbcrlf & "    vertical-align: middle;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .operate {"& vbcrlf &     "background: rgba(33,33,33,.7);" & vbcrlf &     "filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=#b2404040, endColorstr=#b2404040);" & vbcrlf &     "opacity: .8;" & vbcrlf &     "z-index: 5;" & vbcrlf &     "position: absolute;" & vbcrlf &     "bottom: 0;" & vbcrlf & "left: 0;" & vbcrlf & "    width: 100%;" & vbcrlf & "    height: 20px;" & vbcrlf & "    display: none;" & vbcrlf & "    padding: 5px 0 5px 0px;" & vbcrlf & "   margin-right:10px;" & vbcrlf & "      box-sizing:border-box;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "" & vbcrlf & ".multimage-gallery .operatei {" & vbcrlf & "    background: url(../images/goods_img_icon_bg.png) no-repeat;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .operate i {" & vbcrlf & "    display: inline-block;" & vbcrlf & "    cursor: pointer;" & vbcrlf & "    height: 12px;" & vbcrlf & "    width: 12px;" & vbcrlf& "        margin: 0 5px;" & vbcrlf & "    font-size: 0;" & vbcrlf & "    line-height: 0;" & vbcrlf & "    overflow: hidden;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .operate .toleft {" & vbcrlf & "    background-position: 0 -13px;" & vbcrlf & "  display: none;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .operate .toright {" & vbcrlf & "    background-position: -13px -13px;" & vbcrlf & "      display: none;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .operate .del {" & vbcrlf & "    background-position: -13px 0;" & vbcrlf & "      float: right;" & vbcrlf & "}" & vbcrlf & vbcrlf & ".img-hover .operate {" & vbcrlf &     "display: block;" & vbcrlf & "}" & vbcrlf & "/* 图片信息样式 end */" & vbcrlf & vbcrlf & "</style>" & vbcrlf & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "// 控制价格策略表格粗边框" & vbcrlf & "function controlBorder(){" & vbcrlf & "     jQuery(""table[id^=tpx]"").css({""margin-top"":""-1px""});" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "jQuery(function(){" & vbcrlf & "      var $ = jQuery;" & vbcrlf & " $("".accordion"").parents(""#content"").addClass(""table_border"").attr(""cellSpacing"",0);" & vbcrlf & "     $(""#M_Tactics,#rbtn1"").parent().css({""border"":""none""});" & vbcrlf &    "$(""#MRPSetup,#tb1 td"").addClass(""no-border"");" & vbcrlf &        "$(""table[id^=tpx]"").css({""margin-bottom"":""-1px""});" & vbcrlf &     "$(""#unit1"").on(""change"",function(){" & vbcrlf &          "$(""table[id^=tpx]"").css({""margin-top"":""-1px""});"& vbcrlf & "        });" & vbcrlf & "     " & vbcrlf & "" & vbcrlf & "        var accordionFlag = false;" & vbcrlf & "      // 栏目手风琴效果" & vbcrlf & "    $("".accordion"").click(function () {" & vbcrlf & "        accordionFlag = $(this).find("".accordion-arrow-down.accordion-arrow-up"")[0] ? true : false;" & vbcrlf & "     if (accordionFlag) {" & vbcrlf & "            $(this).nextUntil(""tr.accordion"").not("".btns-bar"").removeClass(""zero-height"").show();" & vbcrlf & "               $(this).nextUntil(""tr.accordion"").not("".btns-bar"").find("".multimage-gallery"").show();" & vbcrlf & "                 $(this).find("".accordion-arrow-down"").toggleClass(""accordion-arrow-up"");" & vbcrlf & "        } else {" & vbcrlf & "            $(this).nextUntil(""tr.accordion"").not("".btns-bar"").addClass(""zero-height"").hide();" & vbcrlf & "                    $(this).nextUntil(""tr.accordion"").not("".btns-bar"").find("".multimage-gallery"").hide();" & vbcrlf & "               $(this).find("".accordion-arrow-down"").toggleClass(""accordion-arrow-up"");" & vbcrlf & "                    $("".accordion"").parents(""#content"").css({ ""border-bottom"": ""0px"" });" & vbcrlf & "        }               " & vbcrlf & "        }).find(':reset,:button,:submit').click(function(e){" & vbcrlf & "e.stopPropagation();" & vbcrlf & "    });" & vbcrlf & "" & vbcrlf & "// 图片信信息控制 begin ****************************************************************/" & vbcrlf & "    // 商品图片排序删除" & vbcrlf & "     $(""#productPic li"").hover(function(){" & vbcrlf & "             var img = $(this).find("".preview img"");" & vbcrlf & "if(img.size() > 0){" & vbcrlf &                      "$(this).addClass(""img-hover"");" & vbcrlf &             "};" & vbcrlf &       "},function(){" & vbcrlf &            "$(this).removeClass(""img-hover"");" & vbcrlf &  "});" & vbcrlf & vbcrlf & vbcrlf &      "// 删除商品图片" & vbcrlf &  "$("".operate .del"").on(""click"",function(){"& vbcrlf & "                var img = $(this).parent().parent().find("".preview img"");" & vbcrlf & "         if(img.size() > 0){" & vbcrlf & "                     var fileID = img.attr(""fileID"")," & vbcrlf & "                          fileName = img.attr(""src"");" & vbcrlf & "                       var start = fileName.indexOf(""product"") + 8;" & vbcrlf & "                      var end = fileName.length;" & vbcrlf & "                 var fName = fileName.substring(start, end);" & vbcrlf & "                     var input = $(this).parent().parent().find("".preview input"");" & vbcrlf & "                     $.post(""../productUpload/ProcDelFile.asp"",{action:""fileDel"",fileID:fileID,fileName:fName},function(data){" & vbcrlf & "                           $(""#primaryImg"").val("""");" & vbcrlf & "                              img.remove();" & vbcrlf & "                           if (input.size() > 0) { input.remove(); }" & vbcrlf & "                       });" & vbcrlf & "             };" & vbcrlf & "" & vbcrlf & "      });" & vbcrlf & "" & vbcrlf & "     // 表单验证" & vbcrlf & "     $(""#productForm"").submit(function(){" & vbcrlf & "              if(!Validator.Validate(this,2)){" & vbcrlf & "                       return false;   " & vbcrlf & "                };      " & vbcrlf & "        " & vbcrlf & "                // 验证主图" & vbcrlf & "             var pImg = $(""#primaryImg"");" & vbcrlf & "              var p = $(""#productPic li[data-index=1]"").find("".preview img"");" & vbcrlf & "" & vbcrlf & "             if(p.size() > 0 && pImg.val().length == 0) {                        " & vbcrlf & "                        pImg.val(p.attr(""fileID""));" & vbcrlf & "               };" & vbcrlf & "              " & vbcrlf & "                var total = $(""#productPic .preview img"").size();" & vbcrlf & "         if(total > 0 && pImg.val().length == 0){                        " & vbcrlf & "                        alert('请添加产品主图！');" & vbcrlf & "                      return false;" & vbcrlf & "};" & vbcrlf &    ""    & vbcrlf &         "});" & vbcrlf & vbcrlf & "// 图片信信息控制 end ****************************************************************/" & vbcrlf & vbcrlf & vbcrlf & "});" & vbcrlf & "</script>" & vbcrlf & vbcrlf
	If tempProID = 0 Then
		dim currid : currid = session("personzbintel2007")
		if currid&""="" then currid = 0
		tempProID = 2000000000 + clng(currid)
'if currid&""="" then currid = 0
	end if
	
	Dim sc4Json
	Sub InitScriptControl
		If Not isEmpty(sc4Json) Then Exit Sub
		Set sc4Json = Server.CreateObject("MSScriptControl.ScriptControl")
		sc4Json.Language = "JavaScript"
		sc4Json.AddCode "var itemTemp=null;function getJSArray(arr, index){itemTemp=arr[index];}"
		sc4Json.AddCode "var AttrValue='';function getJSAttrValue(o, index){AttrValue='';var i=0;for (var k in o) {if(i==index){AttrValue= k + ':'+o[k];break;}; i++;}}"
'sc4Json.AddCode "var itemTemp=null;function getJSArray(arr, index){itemTemp=arr[index];}"
	end sub
	Function getJSONObject(strJSON)
		sc4Json.AddCode "var jsonObject = " & strJSON
		Set getJSONObject = sc4Json.CodeObject.jsonObject
	end function
	function getJSAttrItem(obj,index)
		on error resume next
		sc4Json.Run "getJSAttrValue",obj, index
		getJSAttrItem = sc4Json.CodeObject.AttrValue
		If Err.number=0 Then Exit Function
		getJSAttrItem = ""
	end function
	Function isOpenMoreUnitAttr
		isOpenMoreUnitAttr =(conn.execute("select nvalue from home_usConfig where name='UnitAttributeTactics' and nvalue=1 ").eof=false)
	end function
	function GetFormulaAttrValue(mvttn, tmpformula, NumberValue , numberlimit)
		Dim r : r =eval(replace(tmpformula ,mvttn, "1"))
		If CDbl(r)=0 Then GetFormulaAttrValue = 0 : Exit Function
		Dim mv: mv = cdbl(NumberValue) / cdbl(r)
		GetFormulaAttrValue = FormatNumber(mv ,numberlimit , -1,0 , 0)
'Dim mv: mv = cdbl(NumberValue) / cdbl(r)
	end function
	Function LoadMoreUnit(showType ,commUnitAttr , rowindex, NumberValue , numberlimit)
		If commUnitAttr&""="" Then LoadMoreUnit = "" : Exit Function
		Call InitScriptControl()
		Dim obj : Set obj = getJSONObject(commUnitAttr)
		dim formula : formula = obj.formula
		dim o : Set o = obj.v
		Dim r : r = ""
		Dim s : s = ""
		Dim i ,ss
		Dim v
		Dim k
		Dim varry
		Dim attrName
		Dim canEdit
		Dim defv : defv = 0
		Dim editDefV : editDefV = 0
		If Len(NumberValue)=0 Then NumberValue=0
		Dim canEditAttr : canEditAttr = ""
		If showType = 1 Or showType = 2 Or showType = 0 Then
			Dim mV : mV = 0
			For i=0 To 2
				s = getJSAttrItem(o,i)
				If len(s)=0 Then Exit For
				varry = split(s,":")
				v = varry(ubound(varry))
				canEdit = InStr(v,"G")<1
				If canEdit Then
					varry(ubound(varry)) = "???"
					canEditAttr =Replace(join(varry ,":") , ":???" ,"")
					mV = replace(v ,"G", "")*1
				end if
			next
			If CDbl(NumberValue) > 0 Or mV = 0 Then
				Dim tmpformula: tmpformula = replace(formula ,"π", "3.140000")
				tmpformula = split(tmpformula ,"=")(1)
				Dim mAttrName : mAttrName = ""
				For i=0 To 2
					s = getJSAttrItem(o,i)
					If len(s)=0 Then Exit For
					varry = split(s,":")
					v = varry(ubound(varry))
					varry(ubound(varry)) = "???"
					k = Replace(join(varry ,":") , ":???" ,"")
					ss = split(k ,"_")
					attrName = ss(ubound(ss))
					defv = replace(v ,"G", "")*1
					if k <> canEditAttr Then
						If defv=0 Then defv = 1
						tmpformula = replace(tmpformula , attrName, defv)
					else
						mAttrName = attrName
					end if
				next
				editDefV = GetFormulaAttrValue(mAttrName, tmpformula, NumberValue , numberlimit)
			end if
		end if
		For i=0 To 2
			s = getJSAttrItem(o,i)
			If len(s)=0 Then Exit For
			varry = split(s,":")
			v = varry(ubound(varry))
			varry(ubound(varry)) = "???"
			k = Replace(join(varry ,":") , ":???" ,"")
			ss = split(k ,"_")
			attrName = ss(ubound(ss))
			ss(ubound(ss)) = "???"
			Dim formulaAttr :  formulaAttr = Replace(join(ss ,"_") , "_???" ,"")
			canEdit = InStr(v,"G")<1
			defv = replace(v ,"G", "")*1
			If len(canEditAttr)>0 And canEditAttr =k Then
				If editDefV<>0 Then defv = editDefV
			ElseIf CDbl(NumberValue)>0 And CDbl(defv)=0 Then
				defv = 1
			end if
			defv = FormatNumber(defv , numberlimit , -1,0 , 0)
			defv = 1
			Select Case showType
			Case 0 :
			r = r & "<div style='padding-bottom:1px;padding-top:1px'>"
'Case 0 :
			r = r & formulaAttr & "：" & defv
			r = r & "</div>"
			Case 1 :
			r = r & "<div style='padding-bottom:1px;padding-top:1px'>"
'Case 1 :
			r = r & formulaAttr & "：<input uitype='numberbox' class='cell_" & rowindex & "' "
			r = r & " formula='" + formula + "' vttk='" + k + "'  vttn='" + attrName + "'  "
'r = r & formulaAttr & "：<input uitype='numberbox' class='cell_" & rowindex & "' "
			If canEdit =False Then
				r = r & "readonly vttr='G' "
			else
				r = r & " vttr='' "
			end if
			r = r & " style='width:55%;"
			If canEdit =False Then r = r &"color:#aaa;"
			r = r & " ' name='UnitFormula_"& attrName & "_" & rowindex &"' id='UnitFormula_" & attrName & "_" & rowindex &"' "
			If canEdit Then r = r & " onfocus=if(value==defaultValue){value='';this.style.color='#000'} "
			r = r & " onkeyup=formatData(this,'number');checkDot('UnitFormula_" & attrName & "_" & rowindex &"','"& numberlimit &"') "
			r = r & " onblur=if(!value){value=defaultValue;this.style.color='#000'};try{GetCurrFormulaInfoValue(this," & rowindex & ")}catch(e){}; "
			r = r & " onpropertychange=try{formatData(this,'number');GetCurrFormulaInfoValue(this," & rowindex & ")}catch(e){};  "
			r = r & " dataType='Limit' min='1' max='100'  msg='不能为空' value='" & defv & "' type='text'>"
			r = r & "</div>"
			Case 2 :
			If canEdit=false Then defv = "G" & defv
			If len(r)>1 Then r = r &","
			r = r & "'" & formulaAttr &"_" & attrName & "':'" & defv & "'"
			Case 3 :
			r = r & formulaAttr & "：" & defv & " "
			case 4 :
			if len(r)>0 then r = r &"<br>"
			r = r & formulaAttr & "：" & defv & " "
			Case 5 :
			r = r & "<div class='zb-input-row'>"
'Case 5 :
			r = r & formulaAttr & "：<input fielduitype='text' type='number' placeholder='点击输入' value='"& defv &"' dot='number' "
			r = r & " name='UnitFormula_"& attrName & "_" & rowindex &"' id='UnitFormula_" & attrName & "_" & rowindex &"' "
			r = r & " cap='"& formulaAttr &"' min='0.000001' max='100000000' dbname='UnitFormula_"& attrName & "_" & rowindex &"' post='1' dbtype='number' required='required' "
			r = r & " formula='" + formula + "' vttk='" + k + "'  vttn='" + attrName + "' "
			If canEdit =False Then
				r = r & " readonly='true' disabled vttr='G' "
			else
				r = r & " vttr='' "
			end if
			r = r & " style='width:60%;background-position:98% center; background-size: 18px 18px; background-repeat: no-repeat;"
			r = r & " vttr='' "
			If canEdit =False Then r = r &"color:#aaa;"
			r = r & "' uitype='bill.action.contract.UnitAttrChange' maxlength='50' > <span class='notnull'>&nbsp;*</span>"
			r = r & "</div>"
			End Select
		next
		If showType=2 and Len(r)> 0 Then
			r = "{'formula':'"& formula & "','v':{" + r + "}}"
'If showType=2 and Len(r)> 0 Then
		elseif showType=4 then
			r = "<div class='sub-field'>"& r &"</div>"
'elseif showType=4 then
		elseif showType=5 then
			r = r &"<input fielduitype='hidden' type='hidden' post='1' dbtype='hidden' required='required' dbname='commUnitAttr' name='commUnitAttr_"& rowindex &"' id='commUnitAttr' value="& LoadMoreUnit(2 ,commUnitAttr , rowindex, NumberValue , numberlimit) &">"
		end if
		LoadMoreUnit = r
	end function
	Function GetDefUnitGroup(GroupID , NotExistsSql)
		Dim cmdtext , mSql , unitgp
		if GroupID&""="" then GroupID = 0
		If Len(NotExistsSql)>0 Then mSql = " and u.ord not in ("& NotExistsSql &")"
		cmdtext = "select id from ( " &_
		" select distinct s.id , s.sort1 "&_
		" from erp_comm_UnitGroup s "&_
		" inner join ErpUnits u on u.unitgp=s.id and isnull(s.stoped,0)=0 and isnull(u.stoped,0)=0 "&_
		" where 1=1 "& mSql &_
		" ) a order by sort1 desc "
		unitgp =sdk.getSqlValue(cmdtext)
		If unitgp&""="" Then unitgp = 0
		If unitgp = 0 Then unitgp = sdk.getSqlValue("select id from erp_comm_UnitGroup where isnull(stoped,0)=0 order by sort1 desc")
'If unitgp&""="" Then unitgp = 0
		GetDefUnitGroup = unitgp
	end function
	Function GetDefUnit(GroupID , NotExistsSql)
		Dim cmdtext , mSql , unit
		unit = 0
		if GroupID&""="" then GroupID = 0
		If Len(NotExistsSql)>0 Then mSql = " and ord not in ("& NotExistsSql &")"
		cmdtext = " select top 1 ord from ErpUnits where isnull(stoped,0)=0 and unitgp="& GroupID & mSql & "  order by main desc, gate1 desc "
		unit = sdk.getSqlValue(cmdtext)
		If unit&""="" Then unit = 0
		If unit = 0 Then unit = sdk.getSqlValue("select top 1 ord from ErpUnits where unitgp="& GroupID &" and isnull(stoped,0)=0 order by main desc, gate1 desc ")
'If unit&""="" Then unit = 0
		GetDefUnit = unit
	end function
	Function LoadGroupHtml(ShowType , RowIndex , ProductID, defUnitGroupID)
		Dim rs1 ,sql1 , s ,sHtml : sHtml= ""
		Select case ShowType
		Case "select" :
		sHtml = "<select name='unitgp_0_"& RowIndex &"' onchange='ChangeGroup(this,"& RowIndex &" , "& ProductID &")'>"
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select id,name from erp_comm_UnitGroup where  isnull(stoped,0)=0 and exists(select 1 from erp_comm_unitInfo a inner join sortonehy s on s.ord=a.unitid and isnull(s.isstop,0)=0 where a.unitgp=erp_comm_UnitGroup.id) order by sort1 desc "
		rs1.open sql1,conn,1,1
		while rs1.eof=False
			s = ""
			If defUnitGroupID = rs1("id") Then s = " selected "
			sHtml = sHtml &"<option value="& rs1("id") &" "& s &">"& rs1("name") &"</option>"
			rs1.movenext
		wend
		rs1.close
		sHtml = sHtml &"</select>"
		End Select
		LoadGroupHtml = sHtml
	end function
	Function LoadUnitHtml(ShowType , RowIndex ,GroupID, defUnit,disabled)
		Dim sHtml, rs1 ,sql1 , s
		if GroupID&""="" then GroupID = 0
		Select Case ShowType
		Case "select" :
		sHtml = "<select "&disabled&" class='UnitCelue' name='unit_0_"& RowIndex &"' onchange='ChangeUnit(this,"& RowIndex &"); jQuery("".baseUnitFont"").text(jQuery(""#unitDiv_0_"" + jQuery(""#baseUnitInput"").val()).find(""option:selected"").text());'>"
'Case "select" :
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select ord,sort1 from ErpUnits where unitgp="& GroupID &" and isnull(stoped,0) =0  order by main desc, gate1 desc "
		rs1.open sql1,conn,1,1
		while rs1.eof=False
			s = ""
			If defUnit = rs1("ord") Then s = " selected "
			sHtml = sHtml &"<option value="& rs1("ord") &" "& s &">"& sdk.base64.Utf8CharHtmlConvert(rs1("sort1")) &"</option>"
			rs1.movenext
		wend
		rs1.close
		sHtml = sHtml &"</select>"
		End Select
		LoadUnitHtml = sHtml
	end function
	Function LoadUnitAttrHtml(ShowType , RowIndex , ProductID , GroupID, ByRef UnitAttr)
		Dim sHtml, rs2 ,sql2 , s ,i
		if GroupID&""="" then GroupID = 0
		Select case ShowType
		Case "select" :
		set rs2=server.CreateObject("adodb.recordset")
		sql2="select id,name from erp_comm_UnitGroupAttr where isNull(Stoped,0)=0 and unitgp="& GroupID &" order by gate1 desc"
		rs2.open sql2,conn,3,1
		If rs2.eof=False Then
			sHtml = "<select name='unitAttr_"& RowIndex &"' id='unitAttr_"& RowIndex &"' onChange='ChangeUnitAttr(this,"& RowIndex &" ,"& ProductID &")'  dataType='Limit' min='1' max='100' msg='请选择单位属性'>"
			sHtml = sHtml &"<option value=0></option>"
			i = 0
			do until rs2.eof
				s = ""
				If UnitAttr = rs2("id") Or (UnitAttr=0 And i=0) Then s = " selected "
				sHtml = sHtml &"<option value="& rs2("id") &" "& s &">"& rs2("name") &"</option>"
				If UnitAttr = 0 Then UnitAttr = rs2("id")
				i = i+1
'If UnitAttr = 0 Then UnitAttr = rs2("id")
				rs2.movenext
			Loop
			sHtml = sHtml &"</select>"
		end if
		rs2.close
		set rs2=Nothing
		Case "readonly" :
		Set rs2 = conn.execute("select b.name from erp_comm_unitAttrValue a inner join erp_comm_UnitGroupAttr b on b.id=a.groupattr where a.ord= "& ProductID &" and a.unitid =" & UnitAttr)
		If rs2.eof=False Then
			sHtml=rs2(0).value
		end if
		rs2.close
		End Select
		LoadUnitAttrHtml = sHtml
	end function
	Function LoadFormulaParameter(ShowType , RowIndex ,ProductID, UnitAttr ,numberlimit )
		Dim sHtml , commUnitAttr
		If UnitAttr>0 Then
			Select case ShowType
			Case "input" :
			commUnitAttr = GetUnitGroupFormulaAttr(ProductID, UnitAttr ,false)
			sHtml= LoadMoreUnit(1 ,commUnitAttr , RowIndex , 0, numberlimit)
			Case "readonly" :
			commUnitAttr =GetUnitGroupFormulaAttr(ProductID, UnitAttr ,false)
			sHtml= LoadMoreUnit(0 ,commUnitAttr , ProductID , 0, numberlimit)
			End Select
		end if
		LoadFormulaParameter  = sHtml
	end function
	Function GetProductGroupAttrID(ProductID , unit)
		Dim GroupAttr
		if len(ProductID)>0 and  len(unit)>0 then
			GroupAttr = sdk.getSqlValue("select GroupAttr from erp_comm_unitAttrValue where ord=" & ProductID & " and unitid="& Unit,0)
		end if
		If GroupAttr &""="" Then GroupAttr = 0
		GetProductGroupAttrID = GroupAttr
	end function
	Function GetCommUnitAttr(ProductID , unit)
		GetCommUnitAttr = GetUnitGroupFormulaAttr(ProductID, unit , true)
	end function
	Function loadMoreUnitInit(ProductID ,Unit , rowindex ,NumberValue ,numberlimit)
		loadMoreUnitInit = loadMoreUnitByNum(1, ProductID ,Unit , rowindex ,NumberValue ,numberlimit)
	end function
	Function loadMoreUnitByNum(showType, ProductID ,Unit , rowindex ,NumberValue ,numberlimit)
		Dim commUnitAttr : commUnitAttr =GetCommUnitAttr(ProductID , unit)
		Dim r : r= LoadMoreUnit(showType ,commUnitAttr , rowindex , NumberValue, numberlimit)
		loadMoreUnitByNum = r
	end function
	Function ApplyMoreUnit(ReturnType , ProductID, OldUnit, NewUnit, Num ,rowindex, ByRef NumberValue)
		Dim UnitAttrHtml : UnitAttrHtml = ""
		NumberValue = 0
		Dim dt , GroupAttr
		Set dt = ConvertUnit(ProductID, OldUnit, NewUnit, Num)
		if dt.eof=False Then
			NumberValue =dt("num").value
			GroupAttr = dt("GroupAttr").value
			If ReturnType<2 Then
				UnitAttrHtml = GetUnitGroupFormulaAttr(ProductID, NewUnit ,True)
			end if
		end if
		ApplyMoreUnit = UnitAttrHtml
	end function
	Function ConvertUnit(ProductID, OldUnit, NewUnit, Num)
		dim cmdText : cmdText = "select cast(a.bl as float) /cast(b.bl as float)  as nbl , "&_
		" (cast(" & Num & " as float) * cast(a.bl as float) /cast(b.bl as float)  ) as num ,  "&_
		"  isnull(c.formula,'') as formula , isnull(c.id,0) as GroupAttr "&_
		" from erp_comm_unitRelation a  "&_
		" inner join erp_comm_unitRelation b on a.ord=b.ord and b.unit = " & NewUnit &_
		" inner join ErpUnits u on u.ord = b.unit "&_
		" left join erp_comm_UnitGroupAttr c on c.unitgp = u.unitgp  "&_
		" where a.ord =" & ProductID & " and a.unit = " & OldUnit
		Set ConvertUnit = conn.execute(cmdText)
	end function
	Function GetUnitGroupFormulaAttr(ProductID, GroupAttr , isApply)
		Dim currunit, r , dr ,num1_dot: r = ""
		dim mGroupAttr : mGroupAttr = GroupAttr
		currunit=0
		num1_dot = conn.execute("select num1 from setjm3 where ord=88")(0)
		if mGroupAttr = 0 Then  GetUnitGroupFormulaAttr = r : Exit Function
		Dim cmdText : cmdText = "select a.name, a.formulaAttr , isnull(b.v,0) as v , c.formula "&_
		"  from erp_comm_UnitGroupFormulaAttr a "&_
		"  left join erp_comm_unitAttrValue b on b.ord=" & ProductID & " and b.GroupAttr = a.GroupAttrID and b.parameter = a.name and ("& currunit &"=0 or "& currunit &"=b.unitid) "&_
		"  left join erp_comm_UnitGroupAttr c on c.id = a.GroupAttrID "&_
		"  where a.GroupAttrID=" & mGroupAttr & " and a.hided=0 "
		set dr = conn.execute(cmdText)
		if dr.eof=False Then
			Dim  formula: formula = ""
			While dr.eof=False
				formulaAttr = dr("formulaAttr")
				attrName = dr("name")
				v = CDbl(dr("v"))
				If CDbl(v) > 0 Then
					defv = FormatNumber(v , num1_dot ,-1,0,0)
'If CDbl(v) > 0 Then
				else
					defv = "0"
				end if
				Dim canEdit : canEdit = (v=0)
				if len(formula)= 0 Then formula = dr("formula")
				If Len(r)>0 Then r = r & ","
				Dim vttr : vttr = ""
				If canEdit = False And isApply Then vttr = "G"
				r = r &  "'" & formulaAttr & "_" & attrName & "':'" & vttr & defv & "'"
				dr.movenext
			wend
			if Len(r)> 0 Then r = "{'formula':'"+ formula + "','v':{" + r + "}}"
			dr.movenext
		end if
		dr.close
		GetUnitGroupFormulaAttr = r
	end function
	Function saveFormulaAttr(ProductID ,NewUnit, rowindex)
		Dim GroupAttr : GroupAttr =  GetProductGroupAttrID(ProductID , NewUnit)
		if GroupAttr = 0 Then  saveFormulaAttr = "" : Exit Function
		Dim jsonstr : jsonstr = ""
		Dim cmdText : cmdText = "select a.name, a.formulaAttr , isnull(b.v,0) as v , c.formula "&_
		"  from erp_comm_UnitGroupFormulaAttr a "&_
		"  left join erp_comm_unitAttrValue b on b.ord=" & ProductID & " AND b.unitid = "& NewUnit &" and b.parameter = a.name "&_
		"  left join erp_comm_UnitGroupAttr c on c.id = a.GroupAttrID "&_
		"  where a.GroupAttrID=" & GroupAttr & " and a.hided=0 "
		set dr = conn.execute(cmdText)
		if dr.eof=False Then
			Dim formula : formula = ""
			While dr.eof=False
				If len(formula)=0 Then formula = dr("formula").value
				Dim attrName : attrName = dr("name")
				Dim formulaAttr : formulaAttr = dr("formulaAttr")
				Dim defv  : defv = request("UnitFormula_"& attrName & "_" & rowindex &"")
				If defv&""="" Then defv = "0"
				If CDbl(dr("v").value)<>0 Then  defv = "G"& defv
				If len(jsonstr)>1 Then jsonstr = jsonstr &","
				jsonstr = jsonstr & "'" & formulaAttr &"_" & attrName & "':'" & defv & "'"
				dr.movenext
			wend
			if Len(jsonstr)> 0 Then jsonstr = "{'formula':'"& formula & "','v':{" + jsonstr + "}}"
			dr.movenext
		end if
		dr.close
		saveFormulaAttr = jsonstr
	end function
	Function OpenCGMainUnit()
		OpenCGMainUnit = sdk.getSqlValue("select isnull(nvalue,0) nvalue from home_usConfig where name='CGMainUnitTactics' and isnull(uid,0)=0" , 0)&""="1"
	end function
	Function ShowCGMainUnit(fromtype)
		ShowCGMainUnit = OpenCGMainUnit() and (fromtype&""="1" or fromtype&""="2" or fromtype&""="3" or fromtype&""="5")
	end function
	Function GetProductPhXlhManage(ord,unit)
		dim rs, rs2, phManage, cpyxqNum, cpyxqUnit, cpyxqHours, xlhManage, cpyxqUintFlag
		dim arrRet(2)
		If ord&"" = "" Then ord = 0
		If unit&"" = "" Then unit = 0
		Set rs = conn.execute("select phManage,cpyxqNum,cpyxqUnit from product WITH(NOLOCK) where ord="& ord)
		If rs.eof = False Then
			phManage = rs("phManage") : cpyxqNum = rs("cpyxqNum") : cpyxqUnit = rs("cpyxqUnit")
			Set rs2 = conn.execute("select top 1 isnull(xlhManage,0) xlhManage from jiage WITH(NOLOCK) where product="& ord &" and unit="& unit &" order by isnull(xlhManage,0) desc")
			If rs2.eof = False Then
				xlhManage = rs2("xlhManage")
			end if
			rs2.close
			Set rs2 = Nothing
		end if
		rs.close
		set rs = nothing
		If phManage&"" = "" Then phManage = 0
		If xlhManage&"" = "" Then xlhManage = 0
		If cpyxqUnit&"" = "" Then cpyxqUnit = 2
		arrRet(0) = phManage
		arrRet(1) = xlhManage
		if cpyxqNum&""<>"" then
			Select Case cpyxqUnit&""
			Case "2" : cpyxqUintFlag = "d"
			Case "3" : cpyxqUintFlag = "w"
			Case "4" : cpyxqUintFlag = "m"
			Case "5" : cpyxqUintFlag = "y"
			End Select
			arrRet(2) = cpyxqNum &"|"& cpyxqUintFlag
		else
			arrRet(2) = ""
		end if
		GetProductPhXlhManage = arrRet
	end function
	Function dateYxqSet(currType, dateSc, dateYx, cpyxqHours)
		dim arr_cpyxq, cpyxqNum, cpyxqUintFlag, ret
		ret = ""
		if currType&"" = "datesc" then
			If dateSc&""<>"" and dateYx&""="" and cpyxqHours&""<>"" Then
				arr_cpyxq = split(cpyxqHours&"","|")
				cpyxqNum = arr_cpyxq(0) : cpyxqUintFlag = arr_cpyxq(1)
				Select Case cpyxqUintFlag
				Case "w" : cpyxqUintFlag = "ww"
				Case "y" : cpyxqUintFlag = "yyyy"
				End Select
				If cpyxqNum&""<>"" Then
					ret = dateadd("d",-1,dateadd(cpyxqUintFlag,cpyxqNum,dateSc))
'If cpyxqNum&""<>"" Then
				end if
			end if
		end if
		dateYxqSet = ret
	end function
	Function CheckKuXlhExists(xlh, flag)
		dim rs, ret, sql
		ret = False
		if trim(xlh&"")<>"" then
			xlh = trim(xlh&"")
			sql = "select count(1) num1 from ( "&_
			"  select 1 as num1 from ku WITH(NOLOCK) where (isnull(num2,0)+isnull(locknum,0))>0 and xlh='"& replace(xlh&"","'","''") &"'  "&_
			"sql = ""select count(1) num1 from ( ""&_"
			union all  &_
			"  select 1 as num1 from kuinlist a WITH(NOLOCK) inner join kuin b WITH(NOLOCK) on a.kuin=b.ord and b.del in(1,7) and a.del in(1,7)  "&_
			"          and b.complete1=3 AND b.sort1 NOT IN(2,3,6,7) and cast(a.xlh as nvarchar(max))='"& replace(xlh&"","'","''") &"' "&_
			"          AND NOT EXISTS(SELECT TOP 1 1 FROM kuhclist WITH(NOLOCK) WHERE del=1 AND kuinlist=a.id) "&_
			") t "
			set rs = conn.execute(sql)
			If rs.eof = False Then
				if rs("num1")>flag then ret = True
			end if
			rs.close
			set rs = nothing
		end if
		CheckKuXlhExists = ret
	end function
	Function CheckKuinXlhExists(kuin)
		dim ret, sql
		ret = False
		if kuin&""<>"" and kuin&""<>"0" then
			sql = "SELECT TOP 1 1  FROM kuinlist kl WITH(NOLOCK)  "&_
			"   inner join S2_SerialNumberRelation s2 on s2.ListID=kl.id "&_
			"   inner join M2_SerialNumberList ml2 on ml2.id = s2.SerialID  "&_
			"    inner join kuin k WITH(NOLOCK) on kl.kuin=k.ord   "&_
			"   where  k.complete1=3 AND kl.kuin in("& kuin &")  "&_
			"        AND CAST(kl.xlh AS VARCHAR(MAX))<>''   "&_
			"       AND EXISTS( "&_
			"           SELECT TOP 1 1 FROM ku WITH(NOLOCK)  "&_
			"           inner join S2_SerialNumberRelation s2 on s2.ListID=ISNULL(kuinlist,0) and ISNULL(kuinlist,0)<>kl.id  "&_
			"           inner join M2_SerialNumberList ml on ml.id = s2.SerialID and ml.SeriNum=ml2.SeriNum "&_
			"                   WHERE ord=kl.ord and (isnull(num2,0)+isnull(locknum,0))>0  "&_
			"           inner join M2_SerialNumberList ml on ml.id = s2.SerialID and ml.SeriNum=ml2.SeriNum "&_
			"                   union all  "&_
			"                   select top 1 1 as num1 from kuinlist a WITH(NOLOCK)  "&_
			"           inner join kuin b WITH(NOLOCK) on a.kuin=b.ord and b.del=1 and a.del=1  "&_
			"                           and b.complete1=3 AND b.sort1 NOT IN(2,3,6,7)  "&_
			"                           and CAST(a.xlh AS VARCHAR(MAX))=CAST(kl.xlh AS VARCHAR(MAX)) AND ISNULL(a.id,0)<>kl.id "&_
			"                           AND NOT EXISTS(SELECT TOP 1 1 FROM kuhclist WITH(NOLOCK) WHERE del=1 AND kuinlist=a.id) "&_
			"                   LEFT JOIN ( "&_
			"                           SELECT TOP 1 ctl.id FROM kuoutlist2 kl WITH(NOLOCK)   "&_
			"                           inner join contractthlist ctl WITH(NOLOCK) on ctl.kuoutlist2=kl.id  "&_
			"                           INNER JOIN kuinlist rl WITH(NOLOCK) ON rl.id=kl.kuinlist  "&_
			"                           INNER JOIN kuin r WITH(NOLOCK) ON rl.kuin=r.ord AND r.del=1 AND r.complete1=3 "&_
			"                   ) thrkmx ON thrkmx.id = a.id AND ISNULL(k.sort1,1)=2 "&_
			"                   WHERE a.ord=kl.ord  and  (ISNULL(k.sort1,1)<>2 OR (ISNULL(k.sort1,1)=2 AND thrkmx.id>0))"&_
			"           )"
			ret = (conn.execute(sql).eof = false)
		end if
		CheckKuinXlhExists = ret
	end function
	function CheckParentBillXlhStatus(billType , ids)
		dim canReset : canReset = true
		dim sqltext : sqltext= ""
		select case BillType
		case 61001
		sqltext ="select 1 "&_
		"   from kuinlist kl "&_
		"   inner join kuoutlist2 k2 on k2.id = kl.kuoutlist2 "&_
		"   inner join S2_SerialNumberRelation s2 on s2.billtype = 61001 and abs(s2.listid) = kl.id " &_
		"   inner join S2_SerialNumberRelation s3 on s3.billtype = 62001 and s3.listid = k2.id and s3.SerialID = s2.SerialID " &_
		"   where kl.kuin in ("& ids &") and s3.del=2 "
		canReset = conn.execute(sqltext).eof
		case 62001
		sqltext ="select 1 "&_
		"   from kuoutlist2 k2 "&_
		"   inner join S2_SerialNumberRelation s2 on s2.billtype = 62001 and abs(s2.listid) = k2.id " &_
		"   inner join ku k on k.id = k2.ku " &_
		"   inner join S2_SerialNumberRelation s3 on s3.billtype = 61001 and s3.listid = k.Kuinlist and s3.SerialID = s2.SerialID " &_
		"   where k2.kuout in ("& ids &") and s3.del=2 "
		canReset = conn.execute(sqltext).eof
		end select
		CheckParentBillXlhStatus = canReset
	end function
	function UpdateBillXlhStatus(billType , ids)
		dim sqltext
		sqltext = "update S2_SerialNumberRelation set BillID= abs(BillID) , ListID= abs(ListID) where BillType ="& billType &" and abs(BillID) in (" & ids &")"
		conn.execute(sqltext)
		conn.Execute("update  s3 set s3.status=1 from S2_SerialNumberRelation s2 inner join M2_SerialNumberList s3 on s3.ID=s2.SerialID where s2.billtype="& billType &" and BillID in ("&ids&")")
		select case BillType
		case 61001
		sqltext ="update s3 set s3.del=2  "&_
		"   from kuinlist kl "&_
		"   inner join kuoutlist2 k2 on k2.id = kl.kuoutlist2 "&_
		"   inner join S2_SerialNumberRelation s2 on s2.billtype = 61001 and s2.listid = kl.id " &_
		"   inner join S2_SerialNumberRelation s3 on s3.billtype = 62001 and s3.listid = k2.id and s3.SerialID = s2.SerialID " &_
		"   where kl.kuin in ("& ids &") and s3.del=1 "
		conn.execute(sqltext)
		case 62001
		sqltext ="update s3 set s3.del=2 "&_
		"   from kuoutlist2 k2 "&_
		"   inner join S2_SerialNumberRelation s2 on s2.billtype = 62001 and s2.listid = k2.id " &_
		"   inner join ku k on k.id = k2.ku " &_
		"   inner join S2_SerialNumberRelation s3 on s3.billtype = 61001 and s3.listid = k.Kuinlist and s3.SerialID = s2.SerialID " &_
		"   where k2.kuout in ("& ids &") and s3.del=1 "
		conn.execute(sqltext)
		end select
	end function
	Function CheckCkmxXlhExists(xlh, ckmxid)
		dim rs, ret, sql
		ret = false
		if trim(xlh&"")<>"" then
			xlh = trim(xlh&"")
			If ckmxid&"" = "" Then ckmxid = 0
			if ckmxid&"" = "0" then
				ret = CheckKuXlhExists(xlh, 0)
			else
				sql = "select top 1 kuinlist from ( "&_
				"   select kuinlist from ku WITH(NOLOCK) where (isnull(num2,0)+isnull(locknum,0))>0 and xlh='"& xlh &"'  "&_
				"sql = ""select top 1 kuinlist from ( ""&_"
				union all  &_
				"   select a.id from kuinlist a WITH(NOLOCK) inner join kuin b WITH(NOLOCK) on a.kuin=b.ord and b.del=1 and a.del=1  "&_
				"           and b.complete1=3 AND b.sort1 NOT IN(2,3,6,7) and cast(a.xlh as nvarchar(max))='"& xlh &"' "&_
				"           AND NOT EXISTS(SELECT TOP 1 1 FROM kuhclist WITH(NOLOCK) WHERE del=1 AND kuinlist=a.id) "&_
				") t where NOT EXISTS(SELECT TOP 1 1 FROM kuoutlist2 WITH(NOLOCK) WHERE del=1 AND xlh='"& xlh &"' and id="& ckmxid &" AND kuinlist=t.kuinlist)"
				set rs = conn.execute(sql)
				If rs.eof = False Then
					ret = True
				end if
				rs.close
				set rs = nothing
			end if
		end if
		CheckCkmxXlhExists = ret
	end function
	Function CheckThmxXlhExists(xlh, thmxid, flag)
		dim rs, ret, sql, kuoutlist2
		ret = false
		if trim(xlh&"")<>"" then
			If flag&"" = "" Then flag = 0
			If thmxid&"" = "" Then thmxid = 0
			xlh = trim(xlh&"")
			if thmxid&"" = "0" then
				ret = CheckKuXlhExists(xlh, flag)
			else
				sql = "select isnull(kuoutlist2,0) kuoutlist2 from contractthlist where id="& thmxid &" AND xlh='"& xlh &"' "
				set rs = conn.execute(sql)
				If rs.eof = False Then
					if rs("kuoutlist2")>0 then
						ret = False
					else
						ret = CheckKuXlhExists(xlh, flag)
					end if
				end if
				rs.close
				set rs = nothing
			end if
		end if
		CheckThmxXlhExists = ret
	end function
	Function isOpenProductAttr
		isOpenProductAttr = (ZBRuntime.MC(213104) and conn.execute("select nvalue from home_usConfig where name='ProductAttributeTactics' and nvalue=1 ").eof=false)
	end function
	function ProductAttrWidth(cft)
		ProductAttrWidth = sdk.getSqlValue("select isnull(max(cnt),0) from (select count(1) cnt from Shop_GoodsAttr where pid>0 group by pid) a " , 0 ) * cft
	end function
	function ExistsProductAttribute(ProductID , showType)
		dim sqltext
		sqltext= "select top 2 st.id ,st.title , st.isTiled , (select count(1) from Shop_GoodsAttr where pid = 0 and proCategory = m.RootId) as fcnt "&_
		"  from product p  "&_
		"  inner join menu m on m.id = p.sort1 "&_
		"  inner join Shop_GoodsAttr st on st.proCategory = m.RootId and st.pid = 0 and ("& showType &"<>2 or st.isStop=0) "&_
		"  where p.ord = "& ProductID &" and exists(select 1 from Shop_GoodsAttr where pid=st.id and ("& showType &"<>2 or isStop=0) ) "
		ExistsProductAttribute = (conn.execute(sqltext).eof=false)
	end function
	function LoadProductAttribute(BillType , BillListType , BillID, listID , ProductID , NumInputName , numberlimit , rowindex , showType)
		dim rs , rs2, rsv, sqltext, fcnt , AttrIDs , firstID , hasOld
		sqltext = "select distinct v.AttrID, v.Inx "&_
		"      from [sys_sale_ProductAttrGroup] g  "&_
		"      inner join [sys_sale_ProductAttrValue] v on v.GroupID = g.id "&_
		"      where g.BillType = " & BillType &" and g.BillListType = " & BillListType &"  and g.BillId =  " & BillID &"  and g.listid =  " & listID &" order by v.Inx "
		fcnt= 0
		AttrIDs = "0"
		firstID = 0
		hasOld = false
		set rs = conn.execute(sqltext)
		if rs.eof=false then
			while rs.eof = false
				AttrIDs = AttrIDs &"," & rs("AttrID").value
				if firstID = 0 then firstID = rs("AttrID").value
				fcnt = fcnt + 1
'if firstID = 0 then firstID = rs("AttrID").value
				hasOld = true
				rs.movenext
			wend
		end if
		rs.close
		if fcnt = 0 or showType<>3 then
			sqltext = "select top 2 st.id ,st.title , st.isTiled , (select count(1) from Shop_GoodsAttr where pid = 0 and proCategory = m.RootId) as fcnt "&_
			"  from product p  "&_
			"  inner join menu m on m.id = p.sort1 "&_
			"  inner join Shop_GoodsAttr st on st.proCategory = m.RootId and st.pid = 0 and st.isStop=0 "&_
			"  where p.ord = "& ProductID &" and exists(select 1 from Shop_GoodsAttr where pid=st.id and ("& showType &"<>2 or isStop=0) ) "&_
			"  order by isTiled,st.sort desc , st.id desc"
		else
			sqltext = "select id , title , isTiled, "& fcnt &" as fcnt from Shop_GoodsAttr where id in ("& AttrIDs &") order by (case when id=" & firstID &" then 1 else 2 end) asc  "
		end if
		dim headerhtm, htm , attrhtm , i ,attrv , attrvID
		dim tbTDCss : tbTDCss = "padding-top:5px;padding-bottom:5px;text-align:center;"
'dim headerhtm, htm , attrhtm , i ,attrv , attrvID
		if showType = 3 then tbTDCss = tbTDCss & "border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"
'dim headerhtm, htm , attrhtm , i ,attrv , attrvID
		set rs = conn.execute(sqltext)
		if rs.eof=false then
			i = 0
			htm = ""
			headerhtm = ""
			while rs.eof=false
				fcnt = rs("fcnt").value
				if i = 0 and fcnt>=2 then
					attrvID = 0
					attrv = ""
					set rsv = conn.execute("select top 1 stv.id ,stv.title from [sys_sale_ProductAttrGroup] g "&_
					" inner join  Shop_GoodsAttr stv on stv.pid="& rs("id").value &" and charindex(','+cast(stv.id as varchar(10)) + ',',','+ g.attrs +',')>0 "&_
					"where g.BillType =   & BillType &  and g.BillListType =   & BillListType &  and g.BillId =   & BillID & and g.listid =   & listID &")
					if rsv.eof=false then
						attrv = rsv("title").value
						attrvID = rsv("id").value
					end if
					rsv.close
					if showType = 3 then
						if attrv<>"" then
							headerhtm = headerhtm & "<td style='"& tbTDCss &"border-top:#C0CCDD 1px solid;background-image:url(../images/tb_top_td_bg.gif);' class='dataCell'>"& rs("title").value &"</td>"
'if attrv<>"" then
							htm = "<td class='dataCell' style='"& tbTDCss &"background-color: white;'>"& attrv &"</td>"
'if attrv<>"" then
						end if
					else
						headerhtm = headerhtm & "<td style='"& tbTDCss &"border-top:#C0CCDD 1px solid;background-image:url(../images/tb_top_td_bg.gif);' class='dataCell'>"& rs("title").value &"</td>"
'if attrv<>"" then
						htm = htm & "<td class='dataCell' style='"& tbTDCss &"background-color: white;'><select id='ProductAttrV_v_"& rowindex &"' name='ProductAttrV_v_"& rowindex &"'>"
'if attrv<>"" then
						set rs2 = conn.execute("select id,title from Shop_GoodsAttr where pid = "&  rs("id").value &" and ("& showType &"<>2 or isStop=0) order by sort desc , id desc")
						if rs2.eof=false then
							htm = htm & "<option value='0'></option>"
							while rs2.eof=false
								dim selected : selected = ""
								if attrvID = rs2("id").value THEN selected = " selected "
								htm = htm & "<option value='"& rs2("id").value &"' " & selected &" >"& rs2("title").value &"</option>"
								rs2.MoveNext
							wend
						end if
						rs2.close
						htm = htm & "</select></td>"
					end if
					attrhtm = "<input type='hidden' name='ProductAttrV_" & rowindex &"' value="& rs("id").value &">"
				end if
				if fcnt=1 or i=1 then
					set rsv = conn.execute("select stv.id ,stv.title, g.Num1 , g.attrs from [sys_sale_ProductAttrGroup] g "&_
					" inner join  Shop_GoodsAttr stv on stv.pid="& rs("id").value &" and charindex(','+cast(stv.id as varchar(10)) + ',',','+ g.attrs +',')>0 "&_
					"where g.BillType =   & BillType &  and g.BillListType =   & BillListType &  and g.BillId =   & BillID & and g.listid =   & listID &")
					set rs2 = conn.execute("select id,title , isstop from Shop_GoodsAttr where pid = "&  rs("id").value &" and ("& showType &"<>2 or isStop=0) order by sort desc , id desc")
					if rs2.eof=false then
						attrhtm = attrhtm & "<input type='hidden' name='ProductAttrH_" & rowindex &"' value="& rs("id").value &">"
						dim n : n=0
						while rs2.eof=false
							rsv.Filter = "id=" & rs2("id").value
							attrv = ""
							if rsv.eof=false then
								attrv =formatnumber( rsv("Num1").value , numberlimit ,-1,0,0)
'if rsv.eof=false then
							end if
							if showType = 3 then
								if attrv&""<>"" then
									headerhtm = headerhtm & "<td style='"& tbTDCss &"border-top:#C0CCDD 1px solid;background-image:url(../images/tb_top_td_bg.gif);' class='dataCell' >"& rs2("title").value &"</td>"
'if attrv&""<>"" then
									htm = htm & "<td class='dataCell' style='"& tbTDCss &"background-color: white;width:45;'>"& attrv &"</td>"
'if attrv&""<>"" then
								end if
							else
								headerhtm = headerhtm & "<td style='"& tbTDCss &"border-top:#C0CCDD 1px solid;background-image:url(../images/tb_top_td_bg.gif);' class='dataCell' >"& rs2("title").value &"</td>"
'if attrv&""<>"" then
								htm = htm & "<td class='dataCell' style='"& tbTDCss &"background-color: white;'>"
'if attrv&""<>"" then
								
								htm = htm & "<input type='text' class='productattr_"& id &"' style='width:40;font-size:9pt' id='ProductAttrH_"& rs2("id").value  &"_" & rowindex &"' name='ProductAttrH_"& rs2("id").value &"_" & rowindex &"' value='"& attrv &"' "&_
								"onfocus=if(this.value==this.defaultValue){this.value='';this.style.color='#000"&_
								" onBlur=if(!this.value){this.value=this.defaultValue;this.style.color='#000';};SetCurrProductAttrValue("& id &",'"& NumInputName &"');formatData(this,'number'); "&_
								" onkeyup=formatData(this,'number');checkDot('ProductAttrH_"& rs2("id").value  &"_" & rowindex &"','"& numberlimit &"');SetCurrProductAttrValue("& id &",'"& NumInputName &"'); "&_
								" onpropertychange=formatData(this,'number');SetCurrProductAttrValue("& id &",'"& NumInputName &"');></td>"
							end if
							n = n +1
'onpropertychange=formatData(this,'number');SetCurrProductAttrValue(& id &,'& NumInputName &
							rs2.MoveNext
						wend
					end if
					rs2.close
					rsv.close
				end if
				i = i + 1
				rsv.close
				rs.movenext
			wend
		end if
		rs.close
		if len(headerhtm)>0 then
			dim tbcss : tbcss = "margin:8px;"
			if showType = 3 then tbcss = "margin-left:8px;"
'dim tbcss : tbcss = "margin:8px;"
			htm = "<table bgcolor='#C0CCDD' style='word-break:break-all;word-wrap:break-word;border-collapse:collapse;table-layout: fixed;"& tbcss &"'><tr>"& headerhtm &"</tr><tr>"&htm&"</tr></table>" & attrhtm
'dim tbcss : tbcss = "margin:8px;"
		end if
		LoadProductAttribute = htm
	end function
	function SaveProductAttr(BillType , BillListType , BillID, listID , ProductID , rowindex , num , numberlimit)
		if isOpenProductAttr =false then
			SaveProductAttr = true
			exit function
		end if
		dim rs ,sqltext, ProductAttrV , ProductAttrH
		ProductAttrV = request("ProductAttrV_" & rowindex)
		ProductAttrH = request("ProductAttrH_" & rowindex)
		if ProductAttrV&""="" then ProductAttrV = 0
		if ProductAttrH&""="" then ProductAttrH = 0
		if ProductAttrV = 0 and ProductAttrH = 0 then
			SaveProductAttr = true
			exit function
		end if
		conn.execute("delete from [sys_sale_ProductAttrValue] where GroupID in (select id from [sys_sale_ProductAttrGroup] g where g.BillType ="& BillType &" and g.BillListType ="& BillListType &"  and g.BillId ="& BillID &" and g.listid ="& listID &" )")
		conn.execute("delete from [sys_sale_ProductAttrGroup] where BillType ="& BillType &" and BillListType ="& BillListType &"  and BillId ="& BillID &" and listid ="& listID &" ")
		dim ProductAttrVV ,AttrID, ProductAttrValue , attrs , numAll
		ProductAttrVV = 0
		if ProductAttrV>0 then ProductAttrVV = request("ProductAttrV_v_"& rowindex)
		if len(ProductAttrVV&"")=0 then ProductAttrVV = 0
		if ProductAttrVV>0 then attrs = ProductAttrVV &","
		sqltext = ""
		numAll = 0
		set rs = conn.execute("select id from Shop_GoodsAttr where pid = "&  ProductAttrH &" order by sort desc , id desc")
		if rs.eof=false then
			while rs.eof=false
				AttrID = rs("id").value
				ProductAttrValue = request("ProductAttrH_"& AttrID &"_" & rowindex)
				if ProductAttrValue&""="" then ProductAttrValue = 0
				if ProductAttrValue>0 then
					if len(sqltext)>0 then sqltext = sqltext & " union all "
					sqltext = sqltext & " select " & ProductAttrValue & " as Num1 ,'" & attrs & AttrID &"' as Attrs "
					numAll = cdbl(numAll) + cdbl(ProductAttrValue)
'sqltext = sqltext & " select " & ProductAttrValue & " as Num1 ,'" & attrs & AttrID &"' as Attrs "
				end if
				rs.movenext
			wend
		end if
		rs.close
		if len(sqltext)>0 then
			sqltext = "select "& BillType &" ,"& BillListType &", "& BillID &" , "& listID &"  , a.Num1 , a.Attrs , "& ProductID &" ProductID , 1 del from (" & sqltext &") a "
			conn.execute("INSERT INTO [dbo].[sys_sale_ProductAttrGroup]([BillType],[BillListType] ,[BillId],[ListID],[Num1] ,[Attrs],[ProductID],[Del]) " & sqltext)
			sqltext = "INSERT INTO [dbo].[sys_sale_ProductAttrValue] ([GroupID] ,[AttrID]  ,[AttrValue]  ,[inx] ,[del]) " &_
			" select a.id GroupID, stv.Pid AttrID , stv.id as AttrValue , case when stv.id="& ProductAttrVV &" then 1 else 2 end inx , 1 del "&_
			" from sys_sale_ProductAttrGroup a "&_
			" inner join Shop_GoodsAttr stv on charindex(','+cast(stv.id as varchar(10)) + ',',','+ a.attrs +',')>0 "&_
			" from sys_sale_ProductAttrGroup a "&_
			" where a.BillType ="& BillType &" and a.BillListType ="& BillListType &"  and a.BillId ="& BillID &" and a.listid ="& listID &""
			conn.execute(sqltext)
		end if
		if cdbl(numAll)>0 and cdbl(formatnumber(numAll , numberlimit ,-1,0,0))<> cdbl(formatnumber(num , numberlimit ,-1,0,0)) then
			conn.execute(sqltext)
			SaveProductAttr = false
			exit function
		end if
		SaveProductAttr = true
	end function
	function UpdateListCommUnitAttr(conn, billtype , billid)
		dim MoreUnitCmdText,rs,currNum,ProductAttrBatchId  ,mnTable, mxTable,num1_dot
		num1_dot = conn.execute("select num1 from setjm3 where ord=88")(0)
		select case billtype
		case 11001 :
		mnTable = "contract"
		mxTable = "contractlist"
		case 73001 :
		mnTable = "caigou"
		mxTable = "caigoulist"
		end select
		MoreUnitCmdText = ""
		set rs = conn.execute("select cl.id, cl.ord , cl.unit,cl.num1 , isnull(cl.ProductAttrBatchId,0) ProductAttrBatchId "&_
		" from "& mxTable &" cl "&_
		" where cl."& mnTable &"=" & billid &" and exists(select 1 from erp_comm_unitAttrValue where ord = cl.ord and unitid = cl.unit)  ")
		if rs.eof=false then
			while rs.eof=false
				currNum = rs("num1").Value
				ProductAttrBatchId = rs("ProductAttrBatchId").value
				if ProductAttrBatchId>0 then
					currNum = sdk.GetSqlValue("select sum(num1) num1 from "& mxTable &" where "& mnTable &"="& billid&" and ProductAttrBatchId=" & ProductAttrBatchId,0)
				end if
				dim commUnitAttr : commUnitAttr = GetCommUnitAttr(rs("ord").Value , rs("unit").Value)
				commUnitAttr = LoadMoreUnit(2 ,commUnitAttr , 0, currNum  , num1_dot)
				if len(MoreUnitCmdText)>0 then MoreUnitCmdText = MoreUnitCmdText & " union all "
				MoreUnitCmdText = MoreUnitCmdText &" select " & rs("id").value &" id,'"& replace(commUnitAttr,"'","''") &"' commUnitAttr "
				rs.movenext
			wend
		end if
		rs.close
		if len(MoreUnitCmdText)>0 then
			conn.execute("update "& mxTable &" set "& mxTable &".commUnitAttr =a.commUnitAttr from ("& MoreUnitCmdText &") a where a.id = "& mxTable &".id ")
		end if
	end function
	
	Function GetFullProSort(sortID)
		If sortID = "" Then sortID = 0
		proSort=""
		Set rsa=server.CreateObject("adodb.recordset")
		rsa.Open "select id1,menuname from menu where id=" & sortID,conn,3,1
		If Not  rsa.Eof Then
			proSort=TRIM(rsa(1))
			sortID=rsa(0)
			Dim proSort_i
			For proSort_i = 1 To 20
				Set rst=conn.execute("select id1,menuname from menu where id=" & sortID)
				If rst.eof Then Exit For
				proSort=TRIM(rst(1))&"->"&proSort
'If rst.eof Then Exit For
				sortID=rst(0)
				rst.Close
				Set rst = Nothing
			next
		end if
		rsa.Close
		Set rsa = Nothing
		GetFullProSort = proSort
	end function
	dim MODULES
	MODULES=session("zbintel2010ms")
	sql="select num1 from setjm3 where ord=5430"
	set rs=conn.execute(sql)
	if not rs.eof then
		proStore=rs(0).value
	else
		conn.execute "insert into setjm3(ord,num1) values(5430,0)"
		proStore=0
	end if
	rs.close
	set rs=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=4 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_4_1=0
		intro_4_1=0
	else
		open_4_1=rs1("qx_open")
		intro_4_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=4 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_4_14=0
		intro_4_14=0
	else
		open_4_14=rs1("qx_open")
		intro_4_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=4 and sort2=21"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_4_21=0
	else
		open_4_21=rs1("qx_open")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=24 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_24_1=0
		intro_24_1=0
	else
		open_24_1=rs1("qx_open")
		intro_24_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=24 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_24_14=0
		intro_24_14=0
	else
		open_24_14=rs1("qx_open")
		intro_24_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=24 and sort2=21"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_24_21=0
		intro_24_21=0
	else
		open_24_21=rs1("qx_open")
		intro_24_21=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_1=0
		intro_22_1=0
	else
		open_22_1=rs1("qx_open")
		intro_22_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_14=0
		intro_22_14=0
	else
		open_22_14=rs1("qx_open")
		intro_22_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_1=0
		intro_5_1=0
	else
		open_5_1=rs1("qx_open")
		intro_5_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_14=0
		intro_5_14=0
	else
		open_5_14=rs1("qx_open")
		intro_5_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=5 and sort2=21"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_21=0
	else
		open_5_21=rs1("qx_open")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=41 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_41_1=0
		intro_41_1=0
	else
		open_41_1=rs1("qx_open")
		intro_41_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=41 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_41_14=0
		intro_41_14=0
	else
		open_41_14=rs1("qx_open")
		intro_41_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=42 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_42_1=0
		intro_42_1=0
	else
		open_42_1=rs1("qx_open")
		intro_42_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=42 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_42_14=0
		intro_42_14=0
	else
		open_42_14=rs1("qx_open")
		intro_42_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=23 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_23_3=0
	else
		open_23_3=rs1("qx_open")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=21 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_13=0
	else
		open_21_13=rs1("qx_open")
	end if
	rs1.close
	set rs1=nothing
	dim  CurrBookID,ord,title,complete1,complete2,member1,sorce,may,money1,pay1,intro,date1,date2,cateid,company,person,option1,event1,contract,kuoutlist2_value,QC_sort
	dim invoiceTypes,includeTax
	If isnumeric(request("ord") & "") = false Then
		CurrBookID=deurl(request("ord"))
	else
		CurrBookID=request("ord")
	end if
	If isnumeric(CurrBookID) Then
		CurrBookID = CLng(CurrBookID)
	else
		Response.write"<script language=javascript>alert('此产品已被删除！');history.back()</script>"
		Response.write"<script language=javascript>window.open('','_self');window.close();</script>"
		call db_close : Response.end
	end if
	set rs=server.CreateObject("adodb.recordset")
	sql="select a.*,isnull(b.sort1,'') as QC_sort from product a left join sortonehy b on isnull(a.qc_id,0) = b.ord and  b.del=1 and b.gate2=3001 and isNull(b.isStop,0)=0 Where a.ord="&CurrBookID&" "
	rs.open sql,conn,1,1
	if rs.eof then
		Response.write"<script language=javascript>alert('此产品已被删除！');history.back()</script>"
		Response.write"<script language=javascript>window.open('','_self');window.close();</script>"
		call db_close : Response.end
	end if
	ord=rs("ord")
	title=Replace(htmlspecialchars(rs("title")), " ", "&nbsp;")
	order1=Replace(rs("order1")&"", " ", "&nbsp;")
	sort1=rs("sort1")
	num_sc=zbcdbl(rs("num_sc"))
	unit=rs("unit")
	date7=rs("date7")
	pym = Replace(htmlspecialchars(rs("pym")), " ", "&nbsp;")
	type1=Replace(rs("type1")&"", " ", "&nbsp;")
	roles = rs("roles")
	aleat1=rs("aleat1")
	aleat2=rs("aleat2")
	price1=zbcdbl(rs("price1"))
	price2=zbcdbl(rs("price2"))
	intro1=rs("intro1")
	invoiceTypes = Replace(rs("invoiceTypes")&"", " ", "")
	includeTax = rs("includeTax")
	priceMode = rs("priceMode")
	canOutStore = rs("canOutStore")
	SafeNum =zbcdbl( rs("SafeNum"))
	productzdysort=rs("zdygroupid")
	If SafeNum&""="" Then SafeNum = 0
	PurchaleadDays = rs("PurchaleadDays")
	If PurchaleadDays&""="" Then PurchaleadDays = 0
	WastAge = rs("WastAge")
	If WastAge&""="" Then WastAge = 0
	LimitExcess = RS("LimitExcess")
	if LimitExcess&""="" then LimitExcess = 0
	KuoutLimitExcess = rs("KuoutLimitExcess")
	if KuoutLimitExcess&""="" then KuoutLimitExcess = 0
	ProduceleadDays = rs("ProduceleadDays")
	If ProduceleadDays&""="" Then ProduceleadDays = 0
	extleadDays =rs("extleadDays")
	If extleadDays&""="" Then extleadDays = 0
	extleadNum =zbcdbl( rs("extleadNum"))
	If extleadNum&""="" Then extleadNum = 0
	QC_sort = rs("QC_sort")
	if invoiceTypes = "" Or isnull(invoicetypes) then invoiceTypes = "0"
	If ZBRuntime.MC(23004) Then
		InvoiceTitle = rs("InvoiceTitle")
		TaxPreference = rs("TaxPreference")
		if TaxPreference&""="" then TaxPreference = 0
		TaxPreferenceType = rs("TaxPreferenceType")
		if TaxPreferenceType&"" = "" then TaxPreferenceType = 0
		TaxClassifyMergeCoding = rs("TaxClassify")
		if TaxClassifyMergeCoding&"" = "" then TaxClassifyMergeCoding = 0
	end if
	If Len(intro1&"")=0 Then
		intro1=""
	else
		intro1=replace(intro1,chr(13),"<br/>")
		intro1=replace(intro1,chr(10),"")
		intro1=replace(intro1,chr(32),"&nbsp;")
	end if
	intro2=rs("intro2")
	If Len(intro2&"")=0 Then
		intro2=""
	else
		intro2=replace(intro2,chr(13),"<br/>")
		intro2=replace(intro2,chr(10),"")
		intro2=replace(intro2,chr(32),"&nbsp;")
	end if
	intro3=rs("intro3")
	cateid=rs("addcate")
	num_tc=zbcdbl(rs("num_tc")) : tcsort1 = rs("tcsort1") : tcsort2 = rs("tcsort2")
	If num_tc&"" = "" Then num_tc = 0 Else num_tc = CDbl(num_tc)
	If tcsort1&"" = "" Then tcsort1 = 0
	If tcsort2&"" = "" Then tcsort2 = 0
	If cateid&"" = "" Then cateid = 0
	period=rs("period")
	if len(period&"")=0 then period=3.5
	LimitBuyNum=rs("LimitBuyNum")
	if len(LimitBuyNum&"")=0 then LimitBuyNum = 0
	LimitProduceNum=rs("LimitProduceNum")
	if len(LimitProduceNum&"") = 0 then LimitProduceNum = 0
	If rs("RemindNum")&""<>"" Then
		RemindNum=CDbl(rs("RemindNum"))
		RemindUnit=rs("RemindUnit")
	end if
	If rs("MaintainNum")&""<>"" Then
		MaintainNum=CDbl(rs("MaintainNum"))
		MaintainUnit=rs("MaintainUnit")
	end if
	company=rs("company")
	unitall=rs("unit")
	unitjb=rs("unitjb") : phManage = rs("phManage") : cpyxqNum =rs("cpyxqNum") : cpyxqUnit = rs("cpyxqUnit")
	user_list=rs("user_list")
	if isnull(user_list) or user_list&""="" then
		user_list=""
	else
		user_list=replace(user_list," ","")
	end if
	if Len(unitjb&"")=0 then unitjb=0
	If Len(unitall&"")=0 Then unitall=0
	if Len(company&"")=0 then company=0
	If phManage&"" = "" Then phManage = 0
	If cpyxqUnit&"" = "" Then cpyxqUnit = 2
	if aleat1<>"" then
	else
		aleat1=0
	end if
	if aleat2<>"" then
	else
		aleat2=0
	end if
	set rs7=server.CreateObject("adodb.recordset")
	sql7="select top 1 bz from setbz "
	rs7.open sql7,conn,1,1
	if not rs7.eof then
		setbz=rs7("bz")
	end if
	rs7.close
	set rs7=nothing
	If Len(sort1&"")=0 Then sort1=0
	dim complete3
	set rs7=server.CreateObject("adodb.recordset")
	sql7="select menuname from menu where id="&sort1&""
	rs7.open sql7,conn,1,1
	if not rs7.eof then
		complete3=rs7("menuname")
	end if
	rs7.close
	set rs7=nothing
	dim companyname
	if company<>"" and not isnull(company) then
		set rs7=server.CreateObject("adodb.recordset")
		sql7="select name,cateid from tel where ord="&company&" and sort3=2 and del=1"
		rs7.open sql7,conn,1,1
		if rs7.eof then
			companyname=""
			addcate=0
		else
			companyname=rs7("name")
			cateid_gys=rs7("cateid")
		end if
		rs7.close
		set rs7=nothing
	else
		companyname=""
	end if
	phXlhManageShow = ZBRuntime.MC(34000) and ZBRuntime.MC(17002)
	if canOutStore=1 then
		types="实体"
	end if
	if canOutStore=0 then
		types="非实体"
		feishiti="border-bottom:1px solid #c0ccdc !important;"
		types="非实体"
	end if
	Str_Result1=Str_Result1+"and  sort3=2"
	types="非实体"
	Response.CharSet = "UTF-8"
	types="非实体"
	Response.write "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
	types="非实体"
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "" & vbcrlf & "<script language=""javascript"" src='../inc/dateid.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write "'></script>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body {" & vbcrlf & "    margin-top: 0px;" & vbcrlf & "        background-color: #EFEFEF;" & vbcrlf & "      margin-left: 0px;" & vbcrlf & "       margin-right: 0px;" & vbcrlf & "      margin-bottom: 0px;" & vbcrlf & "}-->" & vbcrlf & ".formulaTab{width:auto; color:#585858} " & vbcrlf & ".formulaTab td.td1{width:75%;text-align:left;vertical-align:top; padding-top:1px; height:18px;} " & vbcrlf & ".formulaTab td.td2{width:25%; text-align:right;}" & vbcrlf & "" & vbcrlf & ".accordion-bar-tit {" & vbcrlf & "    padding-left: 0;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "/*#content tr.top td{border-top:1px solid #CCC !important ;}*/  /*产品详情-价格部分策略粗线条暂时注释*/" & vbcrlf & "#content>tbody>tr.top.accordion>td{border-top:0px!important} /*产品详情-价格部分策略粗线条修正cskt.css的border-top*/" & vbcrlf & "#content3 TR.top TD { *border-bottom: 1px !important;}" & vbcrlf & ".IE5 #content td{border-right:0}" & vbcrlf & ".IE5 #content td td{border-right:1px solid #CCC}" & vbcrlf & "/*#content tr.top td{border:1px solid #c0ccd!important];*/" & vbcrlf & ".IE5 #content3 TR.top TD{border-bottom: 1px solid !important;}" & vbcrlf & ".IE5 #content tr.top td {border-right: 0 !important;}" & vbcrlf & "#content3{border-top:1px solid #CCC}" & vbcrlf & ".autocompleteico{height:15px;width:18px;border:0;cursor:pointer;margin-left:-19px;margin-top:1px;float:left;background:#FFFFFF url(../../SYSN/skin/default/img/auto_search.png) no-repeat center center;}" & vbcrlf & ".help_explan_ico{float:left;display:block;width: 20px;height:20px;cursor: pointer;margin-left: 3px;background: url(../../SYSN/skin/default/img/explan_blue.png) no-repeat center center;}" & vbcrlf & ".help_explan_ico1{display:block;width: 20px;height:20px;cursor: pointer;margin-left: 70px;background: url(../../SYSN/skin/default/img/explan_blue.png) no-repeat center center;}" & vbcrlf & ".bill_help_expaln_text{background-color:#b2dbfd;width:200px;position:absolute;margin-left:20px;z-index:9999}" & vbcrlf & ".bill_help_expaln_top{height:17px;padding:4px 3px 0 0;float:right;}" & vbcrlf & ".bill_help_expaln_close{display: block;float: right;margin-right: 3px;width: 16px;height:16px;cursor: pointer;font-size: 14px;background-position: -48px 32px;text-decoration: none;}" & vbcrlf & ".bill_help_expaln_text1{background-color:#b2dbfd;width:200px;position:absolute;margin-left:100px;z-index:99999}" & vbcrlf & "    #TBSr_tb1_1 td, #TBSr_tb1_2 td,      #TBSr_tb1_1 tr.tabtr, #TBSr_tb1_2 tr.tabtr  {" & vbcrlf & "        background-color:transparent;" & vbcrlf & "        background-image:none;" & vbcrlf & "    border-width:0px}" & vbcrlf & "</style>" & vbcrlf & "<scriptlanguage=""javascript"" src=""../inc/system.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script src= ""../Script/pt_content.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """  language=""javascript""></script>" & vbcrlf & "</head>" & vbcrlf & "<body "
	if open_21_8=0 or (open_21_8=1 and CheckPurview(intro_21_8,trim(cateid))=False) then
		Response.write " oncontextmenu=""return false"" onselectstart=""return false"" ondragstart=""return false"" onbeforecopy=""return false"" oncopy=document.selection.empty()"
	end if
	Response.write " onMouseOver=""window.status='none';return true;"">" & vbcrlf & "" & vbcrlf & "      <table width=""100%"" border=""0"" cellspacing=""0""  cellpadding=""0"" height=""27"">" & vbcrlf & "              <tr>" & vbcrlf & "                    <td width=""5%"" height=""27""  background=""../images/contentbg.gif""><div align=""center""><img src=""../images/contenttop.gif""height=""27""> </div></td>" & vbcrlf &                   "<td class=""resetUniqueTabtleTitle"" width=""18%""  background=""../images/contentbg.gif"">" & vbcrlf &                    "<strong><font color=""#1445A6"">产品详情</font></strong> </td>" & vbcrlf &                     "<td class=""resetTableBg"" width=""1%""  background=""../images/contentbg.gif""></td>" & vbcrlf &                         "<td class=""resetTableBg TopTitleAreaBtn"" width=""69%""  background=""../images/contentbg.gif"">" & vbcrlf &                            "<div align=""right"">" & vbcrlf &                                        "<span id=""kh"">" & vbcrlf
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=106 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_106_13=0
		intro_106_13=0
	else
		open_106_13=rs1("qx_open")
		intro_106_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	if open_106_13<>0 And ZBRuntime.MC(63000) then
		Response.write "" & vbcrlf & "              <input type=""button"" name=""Submitdel2"" value=""添加二维码"" onClick=""window.location.href='../code2/inc/getCode2.asp?c2type=1&selectid="
		Response.write CurrBookID
		Response.write "&fromType=product'"" class=""anybutton""/>" & vbcrlf & "                       "
	end if
	Dim disabled
	If rs("company")&"" = "1000000" Then
		disabled = "disabled"
	else
		disabled = ""
	end if
	if open_21_13<>0 And disabled = "" then
		Response.write "" & vbcrlf & "                                             <input type=""button"" name=""Submit73"" value=""复制""  onClick=""javascript:window.location.href='addcy.asp?ord="
		Response.write pwurl(CurrBookID)
		Response.write "'""  class=""anybutton""/>" & vbcrlf & ""
	end if
	if open_21_2=3 or CheckPurview(intro_21_2,trim(cateid))=True Then
		Response.write "" & vbcrlf & "" & vbcrlf & "                                               <input type=""button"" name=""Submit73"" value=""修改""  onClick=""javascript:window.open('correct.asp?ord="
		Response.write pwurl(CurrBookID)
		Response.write "','newwin77','width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150')""  class=""anybutton"" "
		'Response.write pwurl(CurrBookID)
		Response.write disabled
		Response.write " />" & vbcrlf & ""
	end if
	if open_21_7=3 or CheckPurview(intro_21_7,trim(cateid))=True then
		Response.write "" & vbcrlf & "                                               <input type=""button"" name=""Submit43"" value=""打印""  onClick=""javascript:kh.style.display='none';window.print();return  false;""   class=""anybutton""/>" & vbcrlf & "                    "
		print_sort=2003
		print_ord=ord
		Response.write "<span id=""printButton"" style=""position:relative;display:inline-block;font-size:0;margin:1px 3px;line-height:normal;vertical-align:middle"">" & vbcrlf & "    <input class=""anybutton"" type=""button"" value=""模板打印"" style=""width:85px;height:28px;margin:0;""/>" & vbcrlf & "    <select name=""PrintType"" id=""PrintType"" onchange=""javascript:doPrint(this);"" style=""position:absolute;left:0;top:0;width:85px;height:20px;opacity:0;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=00);""> "& vbcrlf &    " <option value="""">模板打印</option> "& vbcrlf &   "      "
		If (print_sort=4 Or print_sort=2003 Or print_sort=62001) Then
			Response.write "" & vbcrlf & "       <option value=""2020|PrintVersionSplit|../../SYSN/View/comm/TemplatePreviewClient.ashx?sort="
			Response.write print_sort
			Response.write "&ord="
			Response.write print_ord
			Response.write """>打印 2020</option>" & vbcrlf & "        "
		end if
		Response.write "" & vbcrlf & "       <option value=""2017|PrintVersionSplit|../../SYSN/view/comm/TemplatePreview.ashx?sort="
		Response.write print_sort
		Response.write "&ord="
		Response.write print_ord
		Response.write """>打印 2017</option>" & vbcrlf & "       "
		If print_sort<>2003 Then
			If print_sort=18001 Then
				Response.write "" & vbcrlf & "      <option value=""2010|PrintVersionSplit|../contract/correct_out.asp?ord="
				Response.write pwurl(print_ord)
				Response.write "&sort="
				Response.write print_sort
				Response.write "&main=1"">打印 2010</option>" & vbcrlf & "                "
			ElseIf print_sort=102 Then
				Response.write "" & vbcrlf & "      <option value=""2010|PrintVersionSplit|../contract/moban_dy.asp?ord="
				Response.write pwurl(print_ord)
				Response.write "&sort="
				Response.write print_sort
				Response.write "&price="
				Response.write print_price
				Response.write "&main=1"">打印 2010</option>" & vbcrlf & "                "
			ElseIf print_sort=6 Then
				Response.write "" & vbcrlf & "      <option value=""2010d|PrintVersionSplit|../contract/moban_dy.asp?ord="
				Response.write pwurl(print_ord)
				Response.write "&sort="
				Response.write print_sort
				Response.write "&main=1&com="
				Response.write print_com
				Response.write """>打印 2010(明细)</option>" & vbcrlf & " <option value=""2010t|PrintVersionSplit|../contract/moban_dy.asp?ord="
				Response.write pwurl(print_ord)
				Response.write "&sort="
				Response.write print_sort
				Response.write "&main=1&com="
				Response.write print_com
				Response.write "&isSum=1"">打印 2010(汇总)</option>" & vbcrlf & "         "
			ElseIf print_sort=62001 Then
				Response.write "" & vbcrlf & "      <option value=""2010d|PrintVersionSplit|../contract/moban_dy.asp?ord="
				Response.write pwurl(print_ord)
				Response.write "&sort="
				Response.write print_sort
				Response.write "&main=1"">打印 2010(明细)</option>" & vbcrlf & "  <option value=""2010t|PrintVersionSplit|../contract/moban_dy.asp?ord="
				Response.write pwurl(print_ord)
				Response.write "&sort="
				Response.write print_sort
				Response.write "&main=1&isSum=1"">打印 2010(汇总)</option>" & vbcrlf & "          "
			ElseIf print_sort=4 Then
				Response.write "" & vbcrlf & "      <option value=""2010d|PrintVersionSplit|../contract/moban_dy.asp?ord="
				Response.write pwurl(print_ord)
				Response.write "&sort="
				Response.write print_sort
				Response.write "&main=1&isSum=0"">打印 2010(明细)</option>" & vbcrlf & "  <option value=""2010t|PrintVersionSplit|../contract/moban_dy.asp?ord="
				Response.write pwurl(print_ord)
				Response.write "&sort="
				Response.write print_sort
				Response.write "&main=1&isSum=1"">打印 2010(汇总)</option>" & vbcrlf & "          "
			ElseIf print_sort=43002 Then
			else
				Response.write "" & vbcrlf & "      <option value=""2010|PrintVersionSplit|../contract/moban_dy.asp?ord="
				Response.write pwurl(print_ord)
				Response.write "&sort="
				Response.write print_sort
				Response.write "&main=1"">打印 2010</option>" & vbcrlf & "                "
			end if
		end if
		Response.write "" & vbcrlf & " </select>" & vbcrlf & "</span>" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "function doPrint(obj)" & vbcrlf & "{" & vbcrlf & "   if (obj.value!="""")" & vbcrlf & "        {" & vbcrlf & "           var v = obj.value;" & vbcrlf & "      $(obj).val("""");" & vbcrlf & "           window.open(v.split(""|PrintVersionSplit|"")[1], 'newwin77_' + v.split(""|PrintVersionSplit|"")[0], 'width=' + 1400 + ',height=' + 768 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=' + (screen.availWidth - 1400) / 2 + ',top=' + 0);" & vbcrlf & "   }" & vbcrlf & "}" & vbcrlf & "</script>"
		'Response.write "&main=1"">打印 2010</option>" & vbcrlf & "                "
		
		Response.write GetPrintInfo(conn, print_sort , print_ord , 2)
	end if
	Response.write "" & vbcrlf & "                                      </span>                         </div>                  </td>" & vbcrlf & "           </tr>" & vbcrlf & "   </table>" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "    function $ID(id) { return document.getElementById(id); }" & vbcrlf & "    if (!window.app) { window.app = {}; }" & vbcrlf & "    app.swpCss = function (obj) { obj.className = obj.className.indexOf(""_over"") > 0 ? obj.className.replace(""_over"", """") : obj.className + ""_over""; }" & vbcrlf & "    app.stopDomEvent = function (e) { e = e || window.event; e.stopPropagation ? e.stopPropagation() : window.event.cancelBubble = true; return false; }" & vbcrlf & "window.cpord = """
	Response.write ord
	Response.write """;" & vbcrlf & "function showuserlist()" & vbcrlf & "{" & vbcrlf & "         var robj=window.open(""ShowUserList.asp?ord="
	Response.write pwurl(CurrBookID)
	Response.write "&ut=1""+""&r=""+Math.round(Math.random()),""51js"",'width=' + 500 + ',height=' + 400 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & ""
	'Response.write pwurl(CurrBookID)
	if ZBRuntime.MC(18000) then
		Response.write "" & vbcrlf & "<script src= ""../Script/pt_content_1.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """  language=""javascript""></script>" & vbcrlf & ""
	end if
	Response.write "" & vbcrlf & "" & vbcrlf & "      <table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content""  style=""table-layout: fixed;"">" & vbcrlf & "          <tr class=""top accordion"">" & vbcrlf & "                        <td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "                           <div  class=""accordion-bar-tit"">" & vbcrlf & "                                  基本信息<span class=""accordion-arrow-down""></span>" & vbcrlf & "                                </div>" & vbcrlf & "                  </td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td width=""11%"" height=""27""><div align=""right"">产品名称：</div></td>" & vbcrlf & "                  <td width=""22%"" class=""red""><div align=""left""><font class=""gray"">&nbsp;"
	Response.write title
	Response.write "</font></div></td>" & vbcrlf & "                    <td width=""12%""><div align=""right"">编号：</div></td>" & vbcrlf & "                        <td width=""22%"" class=""red""><div align=""left""><font class=""gray"">&nbsp;"
	Response.write order1
	Response.write "</font></div></td>" & vbcrlf & "                    <td width=""13%""><div align=""right"">添加人员：</div></td>" & vbcrlf & "                    <td class=""red""><div align=""left""><font class=""gray"">&nbsp;"
	Response.write sdk.getSqlValue("select name from gate where ord="& cateid)
	Response.write "</font></div></td>" & vbcrlf & "            </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td width=""13%""><div align=""right"">产品型号：</div></td>" & vbcrlf & "                    <td class=""red""><div align=""left""><font class=""gray"">&nbsp;"
	Response.write type1
	Response.write "</font></div></td>" & vbcrlf & "                    <td width=""13%""><div align=""right"">拼音码：</div></td>" & vbcrlf & "                      <td class=""red""><div align=""left""><font class=""gray"">&nbsp;"
	Response.write pym
	Response.write "</font></div></td>                    " & vbcrlf & "                        <td ><div align=""right"">添加时间：</div></td>" & vbcrlf & "                     <td class=""gray"">&nbsp;"
	Response.write date7
	Response.write "</td>" & vbcrlf & "         </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td height=""27""><div align=""right"">产品分类：</div></td>" & vbcrlf & "                    <td width=""17%"" class=""gray"">&nbsp;"
	Response.write sdk.base64.Utf8CharHtmlConvert(GetFullProSort(sort1))
	Response.write "</td>" & vbcrlf & "                 <td height=""27""><div align=""right"">适用平台：</div></td>" & vbcrlf & "                    <td class=""gray"" colspan=""3"">" & vbcrlf & "                       "
	Set rsx = conn.Execute("SELECT * FROM Shop_Goods WHERE del = 1 AND product = "& CurrBookID &" ")
	If Not rsx.Eof Then
		Response.write "【微信】"
	end if
	rsx.Close
	Set rsx = Nothing
	Response.write "                      " & vbcrlf & "                        </td>" & vbcrlf & "" & vbcrlf & "           </tr>" & vbcrlf & "" & vbcrlf & ""
	C2id = 0
	Set rs1=server.CreateObject("adodb.recordset")
	sql1 = "select a.id,a.addcate,a.addtime,a.edittime,g1.name aname,g2.name ename from C2_CodeItems a left join C2_CodeTypes b on a.ctype = b.id and a.del = 1 left join gate g1 on g1.ord=a.addcate left join gate g2 on g2.ord = a.editcate where b.title = '产品自定义' and a.sourceID ="&CurrBookID
	rs1.open sql1,conn,1,1
	If rs1.bof =False And rs1.eof = False Then
		C2id = rs1("id")
		addcate = rs1("addcate")
		aname= rs1("aname")
		ename= rs1("ename")
		addtime=rs1("addtime")
		edittime = rs1("edittime")
	end if
	rs1.close
	Set rs1 =Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=106 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_106_14=0
		intro_106_14=0
	else
		open_106_14=rs1("qx_open")
		intro_106_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If C2id <> 0 And ( open_106_14=3 or CheckPurview(intro_106_14,trim(addcate))=True ) And ZBRuntime.MC(63000) then
		Response.write "" & vbcrlf & "              <tr>" & vbcrlf & "                    <td rowspan=""2""><div align=""right"">二维码：</div></td>" & vbcrlf & "                      <td rowspan=""2"">&nbsp;<img src='"
		Dim app, C2_Src
		Set app = server.createobject(ZBRLibDLLNameSN & ".PageClass")
		C2_Src = GetQrCodeImageUrl(C2id)
		Response.write C2_Src
		Response.write "' width='56' title='点击查看二维码' style='cursor:pointer' onclick='var w=app.PageOpen(""?__cmd=qrcode&imgurl="
		Response.write server.urlencode(C2_Src)
		Response.write """,320,320);' /></td>" & vbcrlf & "                       <td><div align=""right"">二维码添加人：</div></td>" & vbcrlf & "                  <td class=""gray"">&nbsp;"
		Response.write aname
		Response.write "</td>" & vbcrlf & "                 <td><div align=""right"">二维码添加时间：</div></td>" & vbcrlf & "                        <td class=""gray"">&nbsp;"
		Response.write addtime
		Response.write "</td>" & vbcrlf & "         </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td><div align=""right"">二维码最后修改人：</div></td>" & vbcrlf & "                      <td class=""gray"">&nbsp;"
		Response.write ename
		Response.write "</td>" & vbcrlf & "                 <td><div align=""right"">二维码最后修改时间：</div></td>" & vbcrlf & "                    <td class=""gray"">&nbsp;"
		Response.write edittime
		Response.write "</td>" & vbcrlf & "         </tr>" & vbcrlf & ""
	end if
	Response.write "" & vbcrlf & "" & vbcrlf & "              <tr>" & vbcrlf & "                    <td height=""27"" align=""right"">可调用范围：</td>" & vbcrlf & "                     <td  colspan=""5"">" & vbcrlf & "                         <div align=""left"">&nbsp;"
	canseelist=""
	if user_list="" or replace(replace(user_list,",",""),"0","")="" then
		canseelist="全部"
	else
		sql="select name from gate where ord in (" & user_list & ")"
		set rsgate=conn.execute(sql)
		while not rsgate.eof
			if canseelist="" then
				canseelist=rsgate("name")
			else
				canseelist=canseelist&","&rsgate("name")
			end if
			rsgate.movenext
		wend
	end if
	Response.write canseelist
	if (open_21_2=3 or CheckPurview(intro_21_2,trim(cateid))=True) And (company <> 1000000) then
		Response.write "" & vbcrlf & "                                             <a href=""javascript:void(0)"" onClick=""showuserlist();"" style=""color:red"">修改范围</a>" & vbcrlf & "                                         "
	end if
	Response.write "" & vbcrlf & "                             </div>" & vbcrlf & "                  </td>           " & vbcrlf & "                </tr>" & vbcrlf & "        "
	If isUsingExtend(21) Then
		Response.write ShowExtendedByKZZDY(16001, ord ,3,1,1, false , "" , "" , 21 , true,0)
		Response.write ShowExtendedByProductGroup(16001, ord ,3,1,1, false , "" , "" , 21 , true, productzdysort)
	end if
	If ZBRuntime.MC(34000) or  ZBRuntime.MC(18000) or ZBRuntime.MC(35000) Then
		Response.write "" & vbcrlf & "             <tr class=""top accordion"" style=""border-bottom:0px  !important"">" & vbcrlf & "                    <td colspan=""6"" class=""accordion-bar-bg"" style=""border-bottom:0px"">" & vbcrlf & "                                              <style> " & vbcrlf & "                                #tabtool { width:100%;table-layout:fixed;border-collapse:collapse;margin-top:8px}" & vbcrlf & "                                                      #tabtool tr.tabtool {" & vbcrlf & "                                                   background:none !important;" & vbcrlf & "                                }" & vbcrlf & "                                                    #tabtool tr.tabtool td {" & vbcrlf & "                                                        border-top:0px;" & vbcrlf & "  border-left:0px;" & vbcrlf & "                                border-right:0px;" & vbcrlf & "                                border-bottom:0px solid #ccc !important;" & vbcrlf & "                                height:30px;" & vbcrlf & "                                                 }" & vbcrlf & "    #tabtool tr.tabtool td.tabitem {                                       " & vbcrlf & "                                border-top:0px solid #ccc !important;" & vbcrlf & "                                border-right:0px solid #ccc !important;" & vbcrlf & "                   border-left:0px solid #ccc !important;" & vbcrlf & "                                text-align:center;" & vbcrlf & "                                                       }" & vbcrlf & "                                #tabtool tr.tabtool td.tabsel {" & vbcrlf & "                                background-color:white;" & vbcrlf& "                                border-bottom:0px solid #ccc !important;" & vbcrlf & "                                                       }" & vbcrlf & "                                                  </style>" & vbcrlf & "                                         <table id=""tabtool"">" & vbcrlf & "                                <colgroup>" & vbcrlf & "                                    <col width=""120""/>" & vbcrlf & "                                    <col width=""8""/>" & vbcrlf & "                                    <col width=""70""/>" & vbcrlf & "                                    <col width=""8""/>             " & vbcrlf & "                                    <col width=""20""/>" & vbcrlf & "                                    <col width=""8""/>" & vbcrlf & "                                </colgroup>" & vbcrlf & "                                <tr class=""tabtool"">" & vbcrlf & "                                     <td style=""border-top:0px  !important;""><div  class=""accordion-bar-tit"">角色信息<span class=""accordion-arrow-down""></span></div></td>" & vbcrlf &                                      "<td style=""border-top:0px  !important;""></td>" & vbcrlf &        ""         & vbcrlf &                                      "<td class=""tabitem  tabsel stclass"" id=""tabitem0"" style="""
		Response.write feishiti
		Response.write """ onclick=""app.stopDomEvent(event)"">"
		Response.write types
		Response.write "" & vbcrlf & "" & vbcrlf & "                                     </td>" & vbcrlf & "                                       <td style=""border-top:0px  !important;""></td>" & vbcrlf & "                                    "
		Response.write types
		if canOutStore=0 then
			Response.write "" & vbcrlf & "                                     <td style=""position:static"">" & vbcrlf & "                                          <span style=""float:left;display:block;width: 20px;height:20px;cursor: pointer;margin-left: 3px;background: url(../../SYSN/skin/default/img/explan_blue.png) no-repeat center center;"" onclick=""showHelpExplan(1)"" ></span>" & vbcrlf & "                                          <div id=""bill_help_expaln_text"" style=""width:200px;position:absolute;margin-left:20px;display:none;font-weight:10;margin-top:3px;padding:4;margin-top:-4px;font-weight:normal !important;z-index:9999"">" & vbcrlf & "                                          注：非实体产品不允许出入库" & vbcrlf & "                                          <a title=""关闭"" href=""javascript:;""  onclick=""closediv(1)"" style=""display: block;float: right;margin-right: 3px;width: 16px;height:16px;cursor: pointer;font-size: 14px;background-position: -48px 32px;text-decoration: none;position:absolute;top:6px;right:2px;color:#FFF"">×</a>" & vbcrlf & "                                          </div>" & vbcrlf & "                                          <input type=""hidden""  name=""canOutStore"" id=""canOutStore"" value="""" />" & vbcrlf & "                                     </td>" & vbcrlf & "                                    "
		else
			Response.write "" & vbcrlf & "                                    <td style=""border-top:0px  !important;"" ></td>" & vbcrlf & "                                    "
		end if
		Response.write "" & vbcrlf & "                                  " & vbcrlf & "                                     <td style=""border-top:0px  !important;"" ></td>" & vbcrlf & "                                    " & vbcrlf & "                                      "
		if canOutStore=1 then
			Response.write "" & vbcrlf & "                                     <td style=""border-top:0px  !important;"">" & vbcrlf & "                                         "
'if canOutStore=1 then
			If ZBRuntime.MC(18000) or ZBRuntime.MC(35000) Then
				If InStr(roles,"1")>0 and ZBRuntime.MC(18600) Then
					Response.write "自制件&nbsp;"
				end if
				If InStr(roles,"2")>0 and ZBRuntime.MC(18700) Then
					Response.write "委外件&nbsp;"
				end if
				If InStr(roles,"3")>0 Then
					Response.write "外购件&nbsp;"
				end if
			end if
			Response.write "" & vbcrlf & "                                    </td>" & vbcrlf & "                                    <td style=""border-top:0px  !important;"" >&nbsp;</td>" & vbcrlf & "                                     "
			Response.write "外购件&nbsp;"
		else
			Response.write "" & vbcrlf & "                                    <td style=""border-top:0px  !important;"" ></td>" & vbcrlf & "                                     <td style=""border-top:0px  !important;"" ></td>" & vbcrlf & "                                     "
			Response.write "外购件&nbsp;"
		end if
		Response.write "" & vbcrlf & "                                </tr>" & vbcrlf & "                            </table>" & vbcrlf & "                    </td>" & vbcrlf & "           </tr>" & vbcrlf & "        "
	end if
	Response.write "" & vbcrlf & "        <tr id=""trcontent"">" & vbcrlf & "            <td colspan=""6"" style=""border-top:0px"">" & vbcrlf & "                <table style=""width:100%; table-layout:fixed; border:0px;color: #5B7CAE;margin-top:1px;border-collapse:collapse""  cellspacing=""0"" border=""0"">" & vbcrlf & "                    <colgroup>" & vbcrlf & "                        <col width=""5%""/>" & vbcrlf & "                        <col width=""11%""/>" & vbcrlf & "                        <col width=""22%""/>" & vbcrlf & "                        <col width=""11%""/>" & vbcrlf & "                <col width=""22%""/>" & vbcrlf & "                        <col width=""11%""/>" & vbcrlf & "                        <col width=""22%""/>" & vbcrlf & "                     </colgroup>" & vbcrlf & "             "
	If ZBRuntime.MC(7000) and ZBRuntime.MC(17003) Then
		Response.write "" & vbcrlf & "                <tr>" & vbcrlf & "                    <td style=""width:5%""><div align=""center"">销售</div></td>" & vbcrlf & "                    <td><div align=""right"">销售出库超量上限：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "                    <td colspan =""5"" class=""gray""><div align=""left"">&nbsp;"
		Response.write Formatnumber(KuoutLimitExcess,2,-1)
		Response.write "%</div> </td>" & vbcrlf & "                </tr>" & vbcrlf & "            "
	end if
	If ZBRuntime.MC(34000) Then
		If ZBRuntime.MC(1002) or  ZBRuntime.MC(15000) or  ZBRuntime.MC(215102)  or  (ZBRuntime.MC(17002) and ZBRuntime.MC(15000)) Then
			Response.write "" & vbcrlf & "        <tr>" & vbcrlf & "            <td rowspan=""2"" style=""width:5%""><div align=""center"">采购</div></td>" & vbcrlf & "              "
			If ZBRuntime.MC(1002) Then
				Response.write "" & vbcrlf & "            <td><div align=""right"">主供应商：</div></td>" & vbcrlf & "                   <td class=""gray""><font class=""gray"">&nbsp;"
				if open_26_1=3 or (open_26_1=1 and CheckPurview(intro_26_1,trim(cateid_gys))=True) then
					if open_26_14=3 or (open_26_14=1 and CheckPurview(intro_26_14,trim(cateid_gys))=True) then
						Response.write "<a href=""javascript:;"" onClick=""javascript:window.open('../work2/content.asp?ord="
						Response.write pwurl(company)
						Response.write "','newwin535','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看此供应商详情"">"
						'Response.write pwurl(company)
						Response.write companyname
						Response.write "</a>" & vbcrlf & "                    "
					else
						Response.write companyname
					end if
				end if
				Response.write "" & vbcrlf & "                  </font>" & vbcrlf & "                </td>       " & vbcrlf & "              "
			else
				Response.write "" & vbcrlf & "             <td></td><td></td>      " & vbcrlf & "            "
			end if
			If ZBRuntime.MC(15000) Then
				Response.write "             " & vbcrlf & "            <td><div align=""right"">采购提前期：</div></td>" & vbcrlf & "                    <td class=""gray"" ><div align=""left"">&nbsp;"
				Response.write PurchaleadDays
				Response.write "天</div> </td>" & vbcrlf & "             "
			else
				Response.write "" & vbcrlf & "            <td></td><td></td>       " & vbcrlf & "            "
			end if
			If ZBRuntime.MC(215102) Then
				Response.write "" & vbcrlf & "                 <td height=""35"" align=""center""><div align=""right"">质检方案：</div></td>" & vbcrlf & "               <td colspan="""
				Response.write spanNum
				Response.write """><div align=""left""><font class=""gray"">&nbsp;"
				Response.write qc_sort
				Response.write "</font></div></td>" & vbcrlf & "            "
			else
				Response.write "" & vbcrlf & "            <td></td><td></td>       " & vbcrlf & "            "
			end if
			Response.write "           " & vbcrlf & "        </tr>" & vbcrlf & "        <tr>" & vbcrlf & "            "
			If ZBRuntime.MC(15000) Then
				Response.write "" & vbcrlf & "             <td height=""27""><div align=""right"">预计销售周期：</div></td>" & vbcrlf & "                <td class=""gray"" >&nbsp;"
				Response.write Formatnumber(period,2,-1)
				Response.write "月</td>" & vbcrlf & "        "
			else
				Response.write "" & vbcrlf & "        <td></td><td></td>   " & vbcrlf & "        "
			end if
			If ZBRuntime.MC(15000) Then
				Response.write "" & vbcrlf & "        <td><div align=""right"">最小采购量：</div>" & vbcrlf & "          </td>" & vbcrlf & "        <td class=""gray""><div align=""left"">&nbsp;"
				Response.write Formatnumber(LimitBuyNum,num1_dot,-1)
				Response.write "</div>" & vbcrlf & "           </td>" & vbcrlf & "        "
			else
				Response.write "" & vbcrlf & "        <td></td><td></td>" & vbcrlf & "        "
			end if
			If ZBRuntime.MC(15000) and  ZBRuntime.MC(17002) Then
				Response.write "" & vbcrlf & "        <td><div align=""right"">采购入库超量上限：</div></td>" & vbcrlf & "           <td class=""gray""  colspan="""
				Response.write spanNum
				Response.write """><div align=""left"">&nbsp;"
				Response.write Formatnumber(LimitExcess,2,-1)
				Response.write """><div align=""left"">&nbsp;"
				Response.write "%</div> </td>" & vbcrlf & "         "
			else
				Response.write "" & vbcrlf & "        <td></td><td></td>   " & vbcrlf & "        "
			end if
			Response.write "     " & vbcrlf & "" & vbcrlf & "        <td></td>" & vbcrlf & "        <td></td>" & vbcrlf & "              </tr>" & vbcrlf & "    "
		end if
		If ZBRuntime.MC(17000) or ZBRuntime.MC(17009) or ZBRuntime.MC(17001) or ZBRuntime.MC(17002) or  (ZBRuntime.MC(17002) and ZBRuntime.MC(15000)) Then
			If ZBRuntime.MC(17000) Then
				Response.write "" & vbcrlf & "             <tr>" & vbcrlf & "            <td rowspan=""3""><div align=""center"">库存</div></td>" & vbcrlf & "         <td height=""27""><div align=""right"">库存下限：</div></td>" & vbcrlf & "                <td class=""gray""><div align=""left"">&nbsp;"
				Response.write Formatnumber(aleat1,num1_dot,-1)
				Response.write "</div></td>" & vbcrlf & "              <td ><div align=""right"">安全库存：</div></td>" & vbcrlf & "             <td class=""gray""><div align=""left"">&nbsp;"
				Response.write Formatnumber(SafeNum,num1_dot,-1)
				Response.write "</div></td>  " & vbcrlf & "            <td ><div align=""right"">库存上限：</div></td>" & vbcrlf & "             <td class=""gray""><div align=""left"">&nbsp;"
				Response.write Formatnumber(aleat2,num1_dot,-1)
				Response.write "</div></td>                  " & vbcrlf & "                </tr>" & vbcrlf & "" & vbcrlf & "    "
			else
				Response.write "" & vbcrlf & "        <tr>" & vbcrlf & "            <td rowspan=""3""></td>" & vbcrlf & "            <td height=""27""></td>" & vbcrlf & "            <td></td>                  " & vbcrlf & "            <td class=""gray"">         " & vbcrlf & "            <td></td>" & vbcrlf & "            <td class=""gray"">" & vbcrlf & "        </tr>" & vbcrlf & "    "
			end if
			Response.write "     " & vbcrlf & "" & vbcrlf & "                <tr>" & vbcrlf & "               "
			If ZBRuntime.MC(17000) Then
				Response.write "" & vbcrlf & "                        <td align=""center""><div align=""right"">产品有效期：</div></td>" & vbcrlf & "                                <td><font class=""gray"">&nbsp;"
				if cpyxqNum&""<>"" then
					Response.write Formatnumber(cpyxqNum&"",0,-1)
'if cpyxqNum&""<>"" then
					Select Case cpyxqUnit&""
					Case "2" : Response.write "天"
					Case "3" : Response.write "周"
					Case "4" : Response.write "月"
					Case "5" : Response.write "年"
					End Select
				end if
				Response.write "</font>" & vbcrlf & "                                  </td>" & vbcrlf & "                                                <td height=""27""><div align=""right"">失效提前期：</div></td>" & vbcrlf & "                             <td class=""gray"">&nbsp;"
				If RemindNum&""<>"" And RemindNum&""<>"0" Then
					Response.write Formatnumber(RemindNum,2,-1)
'If RemindNum&""<>"" And RemindNum&""<>"0" Then
					Select Case RemindUnit
					Case 1 : Response.write "小时"
					Case 2 : Response.write "天"
					Case 3 : Response.write "周"
					Case 4 : Response.write "月"
					Case 5 : Response.write "年"
					End Select
				end if
				Response.write "</td>" & vbcrlf & "                        "
			else
				Response.write "" & vbcrlf & "                        <td align=""center""></td>" & vbcrlf & "                        <td></td>" & vbcrlf & "                        <td height=""27""></td>" & vbcrlf & "                        <td class=""gray""></td>" & vbcrlf & "                        "
			end if
			If ZBRuntime.MC(17009) Then
				Response.write "" & vbcrlf & "                        <td height=""27""><div align=""right"">养护周期：</div></td>" & vbcrlf & "                         <td class=""gray"">&nbsp;" & vbcrlf & "                        "
				If MaintainNum&""<>"" And MaintainNum&""<>"0" Then
					Response.write Formatnumber(MaintainNum,2,-1)
'If MaintainNum&""<>"" And MaintainNum&""<>"0" Then
					Select Case MaintainUnit
					Case 1 : Response.write "小时"
					Case 2 : Response.write "天"
					Case 3 : Response.write "周"
					Case 4 : Response.write "月"
					Case 5 : Response.write "年"
					End Select
				end if
				Response.write "</td>" & vbcrlf & "                             "
			else
				Response.write "     " & vbcrlf & "                        <td height=""27"" align=""center""></td>" & vbcrlf & "                        <td class=""gray""></td>" & vbcrlf & "                     "
			end if
			Response.write "     " & vbcrlf & "                            </tr>" & vbcrlf & "        <tr>" & vbcrlf & "                        "
			If ZBRuntime.MC(17001) AND  ZBRuntime.MC(17003) Then
				Response.write "" & vbcrlf & "                                    <td><div align=""right"">计价方式：</div></td>" & vbcrlf & "                                           <td class=""gray"" style=""padding-right:5px;"">&nbsp;"
'If ZBRuntime.MC(17001) AND  ZBRuntime.MC(17003) Then
				If priceMode="1" Then
					Response.write "个别计价法"
				elseIf priceMode="2" Then
					Response.write "全月平均法"
				elseIf priceMode="3" Then
					Response.write "移动加权平均法"
				else
					Response.write "先进先出法"
				end if
				Response.write "" & vbcrlf & "                                &nbsp;" & vbcrlf & "                                <a href=""javascript:void(0);"" onclick=""javascript:window.open('updateLog.asp?ord="
				Response.write pwurl(ord)
				Response.write "&PriceModeChangeLog=1','PWin','width=' + 600 + ',height=' + 300 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=200');return false;"">历史记录</a>" & vbcrlf & "                                          </td>" & vbcrlf & "" & vbcrlf & "                         "
				'Response.write pwurl(ord)
			else
				Response.write "     " & vbcrlf & "                        <td></td>" & vbcrlf & "                        <td class=""gray"" ></td>" & vbcrlf & "                        "
			end if
			if phXlhManageShow then
				If ZBRuntime.MC(34000) AND  ZBRuntime.MC(17002) Then
					Response.write "   " & vbcrlf & "                                <td height=""35"" align=""center""><div align=""right"">批号必填：</div></td>" & vbcrlf & "                                <td ><font class=""gray"">&nbsp;"
					Response.write iif(phManage&""="1","是","否")
					Response.write "</td>" & vbcrlf & "                                <td></td>" & vbcrlf & "                                <td></td>" & vbcrlf & "                    "
				else
					Response.write "" & vbcrlf & "                              <td height=""35"" align=""center""></td>" & vbcrlf & "                                <td ><font class=""gray""></td>" & vbcrlf & "                                <td></td>" & vbcrlf & "                                <td></td>" & vbcrlf & "" & vbcrlf & "                    "
				end if
			else
				Response.write "" & vbcrlf & "               <td height=""35"" align=""center""></td>" & vbcrlf & "                                <td ><font class=""gray""></td>" & vbcrlf & "                                <td></td>" & vbcrlf & "                                <td></td>" & vbcrlf & "                        " & vbcrlf & "            " & vbcrlf & "            "
			end if
			Response.write "" & vbcrlf & "                             </tr> " & vbcrlf & "    "
		end if
	end if
	If ZBRuntime.MC(18400) and  (ZBRuntime.MC(18000) or ZBRuntime.MC(35000))  Then
		if CheckPurview(roles,"1") or CheckPurview(roles,"2") then
			Response.write "                                        " & vbcrlf & "                    <tr id=""sc"">" & vbcrlf & "                         <td style=""width:50%"" "
			if ZBRuntime.MC(18000) then
				Response.write " rowspan=""2"""
			end if
			Response.write "><div align=""center"">生产</div></td>" & vbcrlf & "                      "
			If ZBRuntime.MC(18400)  Then
				Response.write "" & vbcrlf & "                         <td><div align=""right"">固定制造提前：</div></td>" & vbcrlf & "                              <td class=""gray"" title=""固定提前期指的是不论批量大小,都以一定时间为提前期；会根据自制件或者委外件的完工日期推算其直接子级产品的完工日期。"">&nbsp;"
				Response.write ProduceleadDays
				Response.write "天</td>                              " & vbcrlf & "                                                 <td><div align=""right"">变动制造：</div></td>" & vbcrlf & "                              <td>提前期 "
				Response.write extleadDays
				Response.write " 天 批量 " & vbcrlf & "" & vbcrlf & "                        "
				Response.write FormatNumber( extleadNum , num1_dot , -1 , 0 ,-1) & sdk.base64.Utf8CharHtmlConvert(sdk.getSQLValue("select sort1 from sortonehy where gate2=61 and isNull(isStop,0)=0 and ord="&unitjb&""))
				Response.write " 天 批量 " & vbcrlf & "" & vbcrlf & "                        "
				Response.write "" & vbcrlf & "" & vbcrlf & "                              </td>" & vbcrlf & "                                          <td><div align=""right"">损耗率：</div></td>" & vbcrlf & "                                    <td class=""gray""><div align=""left"">&nbsp;"
				Response.write Formatnumber(WastAge,percentWithDot,-1)
				Response.write "%</div> </td>" & vbcrlf & "" & vbcrlf & "                     "
			else
				Response.write "" & vbcrlf & "                        <td style=""width:50%""></td>" & vbcrlf & "                        <td></td>" & vbcrlf & "                        <td></td>" & vbcrlf & "                        <td></td>" & vbcrlf & "                        <td></td>" & vbcrlf & "                        <td></td>" & vbcrlf & "                    "
			end if
			Response.write "" & vbcrlf & "" & vbcrlf & "                                 </tr>" & vbcrlf & "                    "
			If ZBRuntime.MC(18000) Then
				Response.write "" & vbcrlf & "                                     <tr id=""sc2"">" & vbcrlf & "                        <td align=""center""><div align=""right"">最小生产量：</div></td>" & vbcrlf & "                        <td class=""gray""><div align=""left"">&nbsp;"
				Response.write Formatnumber(LimitProduceNum,num1_dot,-1)
				Response.write "</div> </td>" & vbcrlf & "                                         <td></td>" & vbcrlf & "                                               <td></td>" & vbcrlf & "                                               <td></td>" & vbcrlf & "                                               <td></td>" & vbcrlf & "                                       </tr>        " & vbcrlf & "                    "
			end if
		end if
	end if
	Response.write "" & vbcrlf & "                          </table>" & vbcrlf & "                    </td>" & vbcrlf & "                    </tr>      " & vbcrlf & "         "
'end if
	If ZBRuntime.MC(23004) Then
		Response.write "" & vbcrlf & "    <tr class=""top accordion"">" & vbcrlf & "         <td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "                   <div  class=""accordion-bar-tit"">" & vbcrlf & "                          开票信息<span class=""accordion-arrow-down""></span>" & vbcrlf & "                        </div>" & vbcrlf & "          </td>" & vbcrlf & "   </tr>" & vbcrlf & "                                   " & vbcrlf & "                <tr>" & vbcrlf & "                    <td>" & vbcrlf & "                            <div align=""right"">产品开票名称：</div>" & vbcrlf & "                   </td>" & vbcrlf & "            <td>&nbsp;"
		Response.write InvoiceTitle
		Response.write "</td>" & vbcrlf & "            <td><div align=""right"">享受税收优惠政策：</div></td>" & vbcrlf & "                  <td>&nbsp;"
		if TaxPreference = 1 then
			Response.write "是"
		end if
		if TaxPreference = 0 then
			Response.write "否"
		end if
		Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   <td><div align=""right"" id=""TaxPreferenceType0"" "
		if TaxPreference = 0 then
			Response.write " style=""display:none"" "
		end if
		Response.write ">税收优惠政策类型：</div></td>" & vbcrlf & "                       <td><div id=""TaxPreferenceType1"" "
		if TaxPreference = 0 then
			Response.write " style=""display:none"" "
		end if
		Response.write ">&nbsp;"
		if TaxPreferenceType = 2 then Response.write "免税"
		if TaxPreferenceType = 3 then Response.write "不征税"
		if TaxPreferenceType = 4 then Response.write "普通零税率"
		Response.write "</div></td>" & vbcrlf & "          </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td>" & vbcrlf & "                            <div align=""right"">税收分类编码：</div>" & vbcrlf & "                   </td>" & vbcrlf & ""
		Set rstax = conn.execute("select id,MergeCoding,GoodsName,ClassifyShorterForm from TaxClassifyCodes where id="&TaxClassifyMergeCoding)
		if not rstax.eof then
			MergeCodid = rstax("id")
			MergeCoding = rstax("MergeCoding")
			GoodsName = rstax("GoodsName")
			ClassifyShorterForm = rstax("ClassifyShorterForm")
		end if
		rstax.close
		set rstax = nothing
		Response.write "" & vbcrlf & "            <td>&nbsp;"
		Response.write MergeCoding
		Response.write "</td>" & vbcrlf & "            <td><div align=""right"">税收分类名称：</div></td>" & vbcrlf & "                      <td><div id=""TaxPreferenceTypeName"">&nbsp;"
		Response.write GoodsName
		Response.write "</div></td>" & vbcrlf & "                  <td><div align=""right"">简称：</div></td>" & vbcrlf & "                  <td><div id=""TaxPreferenceTypeJName"">&nbsp;"
		Response.write ClassifyShorterForm
		Response.write "</div>" & vbcrlf & "                       </td>" & vbcrlf & "           </tr>" & vbcrlf & "    "
	end if
	Response.write "" & vbcrlf & "        <tr class=""top accordion"">" & vbcrlf & "                     <td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "                           <div  class=""accordion-bar-tit"">" & vbcrlf & "                                  价格策略<span class=""accordion-arrow-down""></span>" & vbcrlf & "                                </div>" & vbcrlf & "                  </td>" & vbcrlf & "           </tr>" & vbcrlf & "        "
	If ZBRuntime.MC(19000) Then
		Response.write "" & vbcrlf & "             <tr>" & vbcrlf & "                    <td><div align=""right"">是否含税：</div></td>" & vbcrlf & "                      <td class=""gray"">&nbsp;"
		If includeTax = 1 Then
			Response.write "含税"
		else
			Response.write "不含税"
		end if
		Response.write "</td>" & vbcrlf & "                        <td><div align=""right"">可开具票据类型：</div></td>" & vbcrlf & "                        <td  class=""gray""  >" & vbcrlf & "                              "
		Set rsConfig = conn.execute("select id,sort1 from sortonehy where id in ("&invoiceTypes &") AND isStop = 0 order by gate1 desc")
		While rsConfig.eof = False
			Response.write "&nbsp;"
			Response.write rsConfig("sort1")
			rsConfig.movenext
		wend
		rsConfig.close
		Set rsConfig=nothing
		tc_sort1 = 0 : tc_sort2 = 0 : tc_cpord = CurrBookID
		If tcsort1>0 Then
			tc_sort1 = tcsort1
		else
			Set rs = conn.execute("select isnull(intro,1) intro from setopen  where sort1=11 ")
			If rs.eof = False Then
				tc_sort1=rs("intro")
			end if
			rs.close
			set rs = nothing
		end if
		If tcsort2>0 Then
			tc_sort2 = tcsort2
		else
			tc_cpord = 0
			Set rs = conn.execute("select isnull(intro,1) intro from setopen  where sort1=12 ")
			If rs.eof = False Then
				tc_sort2=rs("intro")
			end if
			rs.close
			set rs = nothing
		end if
		Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   <td height=""27""><div align=""right"">"
		if tc_sort2&""="3" then
			Response.write "提成比例："
		end if
		Response.write "</div></td>" & vbcrlf & "                  <td height=""27"" class=""gray"" style=""padding-left:5px;"">&nbsp;"
		Response.write "提成比例："
		if tc_sort2&""="3" then
			Response.write getTCFormula(tc_sort1, tc_sort2, tc_cpord, num_tc)
		end if
		Response.write "</td>" & vbcrlf & "                </tr>" & vbcrlf & "   "
	end if
	Response.write "" & vbcrlf & "     <tr>" & vbcrlf & "                    <td><div height=""27"" align=""right"">基本单位组：</div></td>" & vbcrlf & "                  <td height=""27"" class=""gray""  colspan=5><span id=""trpx_unit1"" style=""float:left;"">&nbsp;"
	Response.write sdk.getsqlvalue("select top 1 name from erp_comm_UnitGroup where id in (select unitgp from ErpUnits where ord="&unitjb&" )")
	Response.write "</span>" & vbcrlf & "                " & vbcrlf & "                <div id=""bill_help_expaln_text1"" style=""display:none;width:300px;padding:15;line-height:29px;position:absolute;left:250px;padding:10px;z-index:9999"">温馨提示：产品所选单位分组为体积组或面积组时，支持选择分组属性，并且可自定义设置属性项，如果属性项值大于0，则此项为固定项，不允许编辑；如果属性项值为0，则此项为变动项，支持手动编辑。<a title=""关闭"" href=""javascript:;""  onclick=""closediv(2)"" class=""bill_help_expaln_close1"" style=""position:absolute;top:-2px;right:5px;font-size:14px;color:#FFF"">×</a></div>" & vbcrlf & "                <span style=""display:block;width: 20px;cursor: pointer;float:left;background: url(../../SYSN/skin/default/img/explan_blue.png) no-repeat center center;"" onclick=""showHelpExplan(2)"" ></span>" & vbcrlf & "                    </td>" & vbcrlf & "" & vbcrlf & "                   </tr>" & vbcrlf & "           <tr>" & vbcrlf & "            <td height=""27"" colspan=""6"">" & vbcrlf & "                        " & vbcrlf & ""
	if open_21_18=3 or (open_21_18=1 and CheckPurview(intro_21_18,trim(cateid))=True) then
		set rs7=server.CreateObject("adodb.recordset")
		sql7="select id,sort2 from sort5 where time1=1 order by sort1 asc,gate2 desc"
		rs7.open sql7,conn,1,1
		num1=rs7.recordCount
		dim bm_list
		bm_list=0
		if proStore=1 then num1=num1+3
		bm_list=0
		CGMainUnitTactics = sdk.getSqlValue("select isnull(nvalue,0) nvalue from home_usConfig where name='CGMainUnitTactics' and isnull(uid,0)=0" , 0)
		if CGMainUnitTactics&"" = "1" and ZBRuntime.MC(15000)  then num1 = num1 + 1
		maxwidth = 100+100+100+140+140
		if CGMainUnitTactics&"" = "1"  and ZBRuntime.MC(15000) Then maxwidth = maxwidth + 90
		if phXlhManageShow Then maxwidth = maxwidth + 90
		if isOpenMoreUnitAttr Then maxwidth = maxwidth + 80+120
		if proStore=1 then maxwidth = maxwidth + 70+70+50
		if open_21_21<>0 then maxwidth = maxwidth + 140+140
		if open_21_22<>0 then
			maxwidth = maxwidth + 140+140 + 140 * num1
'if open_21_22<>0 then
		end if
		Response.write "" & vbcrlf & "    <div style=""width:100%;overflow-x:auto"">" & vbcrlf & "   <table class=""resetBorderColor"" width="""
'if open_21_22<>0 then
		Response.write maxwidth
		Response.write """  border=""0"" cellpadding=""3"" id=""content3"" style=""border-collapse: collapse; word-wrap: break-word; word-break: break-all;border-top:1px solid #CCC"">" & vbcrlf & "            <tr class=""top"">" & vbcrlf & "                  <td width=""100"" height=""27""><div align=""center"">单位分组</div></td>" & vbcrlf & "   <td width=""100"" height=""27""><div align=""center"">单位</div></td>" & vbcrlf & "                       <td width=""100"" height=""27""><div align=""center"">换算比例</div></td>" & vbcrlf & "                   "
		If CGMainUnitTactics&"" = "1" and ZBRuntime.MC(15000) Then
			Response.write "" & vbcrlf & "                             <td width=""90""><div align=""center"">采购主单位</div></td>" & vbcrlf & "                    "
		end if
		Response.write "" & vbcrlf & "                     <td width=""90""><div align=""center"">停用</div></td>" & vbcrlf & "                  "
		If phXlhManageShow Then
			Response.write "" & vbcrlf & "                             <td width=""90""><div align=""center"">序列号管理</div></td>" & vbcrlf & "                    "
		end if
		If isOpenMoreUnitAttr Then
			Response.write "" & vbcrlf & "                             <td width=""80""><div align=""center"">分组属性</div></td>" & vbcrlf & "                              <td width=""120""><div align=""center"">属性项</div></td>" & vbcrlf & "                       "
		end if
		Response.write "" & vbcrlf & "                     <td width=""140""><div align=""center"">部门</div></td>" & vbcrlf & "                 "
		if proStore=1 then
			Response.write "" & vbcrlf & "                                     <td width=""70"" style='border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;'><div align=""center"">主仓库</div></td>" & vbcrlf & "                                  <td width=""70"" style='border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;'><div align=""center"">仓库容量</div></td>" & vbcrlf & "                                     <td width=""50"" style='border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;'><div align=""center"">辅仓库</div></td>" & vbcrlf & "                  "
'if proStore=1 then
		end if
		Response.write "" & vbcrlf & "                     <td width=""140""><div align=""center"">条形码</div></td>" & vbcrlf & "                       "
		if ZBRuntime.MC(15000) and open_21_21<>0 then
			Response.write "" & vbcrlf & "                             <td width=""140""><div align=""center"">建议进价</div></td>" & vbcrlf & "                             <td width=""140""><div align=""center"">最高进价</div></td>" & vbcrlf & "                             "
		end if
		if ZBRuntime.MC(7000) and open_21_22<>0 then
			Response.write "" & vbcrlf & "                             <td width=""140""><div align=""center"">建议售价</div></td>" & vbcrlf & "                             <td width=""140""><div align=""center"">最低售价</div></td>" & vbcrlf & "                             "
			do until rs7.eof
				bm_list=bm_list&","&rs7("id")
				Response.write("<td width='140'><div align='center'>"&rs7("sort2")&"价格</div></td>")
				rs7.movenext
			loop
			rs7.close
			set rs7=nothing
		end if
		Response.write "" & vbcrlf & "               </tr>" & vbcrlf & "   "
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select a.ord,a.sort1 , b.name from ErpUnits a inner join erp_comm_UnitGroup b on b.id = a.unitgp where a.ord="&unitjb&" order by a.gate1 desc "
		rs1.open sql1,conn,1,1
		i=0
		if not rs1.eof then
			do until rs1.eof
				cgMainUnit = 0 : xlhManage = 0
				sql7="select a.bl,a.txm,a.price1jy,a.price1,a.price2jy,a.price2,a.MainStore,b.sort1,a.StoreCapacity,isnull(a.cgMainUnit,0) cgMainUnit,isnull(a.xlhManage,0) xlhManage,a.product from jiage a left join sortck b on a.MainStore=b.id where bm=0 and unit="&rs1("ord")&" and abs(product)="&CurrBookID&""
				set rs7=conn.execute(sql7)
				if rs7.eof then
					bl=1
					txm=""
					price1jy=0
					price1=0
					price2jy=0
					price2=0
					MainStore=""
					StoreName=""
					StoreCapacity=""
					isUnitStop=0
				else
					bl=rs7("bl")
					txm=rs7("txm")
					price1jy=zbcdbl(rs7("price1jy"))
					price1=zbcdbl(rs7("price1"))
					price2jy=zbcdbl(rs7("price2jy"))
					price2=zbcdbl(rs7("price2"))
					MainStore=rs7("MainStore")
					StoreName=rs7("sort1")
					StoreCapacity=rs7("StoreCapacity")
					cgMainUnit=rs7("cgMainUnit") : xlhManage=rs7("xlhManage")
					if rs7("product")>0 then
						isUnitStop=0
					else
						isUnitStop=1
					end if
				end if
				rs7.close
				set rs7=nothing
				if price1jy="" then price1jy=0
				if price2jy="" then price2jy=0
				if cgMainUnit&""="" then cgMainUnit=0
				if xlhManage&""="" then xlhManage=0
				baseUnitName=sdk.base64.Utf8CharHtmlConvert(rs1("sort1"))
				Response.write "" & vbcrlf & "              <tr  onmouseout=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                  <td><div align=""center"">"
				Response.write rs1("name")
				Response.write "</div></td>" & vbcrlf & "                   <td class=""red""><div align=""center"">"
				Response.write baseUnitName
				Response.write "</div></td>" & vbcrlf & "                   <td><div align=""center"">"
				Response.write FormatNumber(bl,num1_dot,-1,0,-1)
				Response.write "</div></td>" & vbcrlf & "                   <td><div align=""center"">"
				Response.write "</div></td>" & vbcrlf & "                   "
				If CGMainUnitTactics&"" = "1" and ZBRuntime.MC(15000) Then Response.write "<td><div align='center'>"& iif(cgMainUnit=1,"是","") &"</div></td>"
				Response.write "<td><div align='center'>"& iif(isUnitStop=1,"是","") &"</div></td>"
				If phXlhManageShow Then Response.write "<td><div align='center'>"& iif(xlhManage=1,"是","") &"</div></td>"
				If isOpenMoreUnitAttr Then
					UnitAttr = GetProductGroupAttrID(ord , rs1("ord"))
					Response.write "" & vbcrlf & "                              <td style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center""><div align=""center"">"
					UnitAttr = GetProductGroupAttrID(ord , rs1("ord"))
					Response.write LoadUnitAttrHtml("readonly" , 0,CurrBookID ,0, rs1("ord"))
					Response.write "</div></td>" & vbcrlf & "                           <td style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center""><div align=""center"">"
					Response.write LoadUnitAttrHtml("readonly" , 0,CurrBookID ,0, rs1("ord"))
					Response.write LoadFormulaParameter("readonly" , 0 , CurrBookID , UnitAttr ,num1_dot )
					Response.write "</div></td>" & vbcrlf & "                           "
				end if
				Response.write "" & vbcrlf & "                      <td  height=""27""><div align=""center"">基础价格</div></td>" & vbcrlf & "                    "
				if proStore=1 then
					Response.write "" & vbcrlf & "                              <td style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center""><div align=""center"">"
'if proStore=1 then
					Response.write StoreName
					Response.write "</div></td>" & vbcrlf & "                           <td style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center""><div align=""center"">"
					Response.write StoreName
					Response.write StoreCapacity
					Response.write "</div></td>" & vbcrlf & "                           <td style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center"">" & vbcrlf & "                                   <div align=""center"">" & vbcrlf & "                                              <span style=""cursor:pointer"" onMouseOver=""this.style.textDecoration='underline';"" onMouseOut=""this.style.textDecoration='none';"" onClick=""ShowSlaveStore(this,"
					Response.write CurrBookID
					Response.write ","
					Response.write rs1("ord")
					Response.write ");"">查看</span>" & vbcrlf & "                                    </div>" & vbcrlf & "                          </td>" & vbcrlf & "                           "
				end if
				Response.write "" & vbcrlf & "                      <td><div align=""center"">"
				Response.write txm
				Response.write "</div></td>" & vbcrlf & ""
				if ZBRuntime.MC(15000) and open_21_21<>0 then
					Response.write "" & vbcrlf & "                      <td><div align=""right"">"
					Response.write Formatnumber(price1jy,StorePrice_dot_num,-1)
					Response.write "" & vbcrlf & "                      <td><div align=""right"">"
					Response.write "</div></td>" & vbcrlf & "                   <td><div align=""right"">"
					Response.write Formatnumber(price1,StorePrice_dot_num,-1)
					Response.write "</div></td>" & vbcrlf & "                   <td><div align=""right"">"
					Response.write "</div></td>" & vbcrlf & ""
				end if
				if ZBRuntime.MC(7000) and open_21_22<>0 then
					Response.write "" & vbcrlf & "                              <td><div align=""right"">"
					Response.write Formatnumber(price2jy,SalesPrice_dot_num,-1)
					Response.write "" & vbcrlf & "                              <td><div align=""right"">"
					Response.write "</div></td>" & vbcrlf & "                           <td ><div align=""right"">"
					Response.write Formatnumber(price2,SalesPrice_dot_num,-1)
					Response.write "</div></td>" & vbcrlf & "                           <td ><div align=""right"">"
					Response.write "</div></td>" & vbcrlf & ""
					set rs2=server.CreateObject("adodb.recordset")
					sql2="select id from sort5 where time1=1 order by sort1 asc,gate2 desc"
					rs2.open sql2,conn,1,1
					if not rs2.eof then
						do until rs2.eof
							set rs7=server.CreateObject("adodb.recordset")
							sql7="select  isnull(price3,0) as price3 from jiage where bm=0 and unit="&abs(rs1("ord"))&" and sort="&rs2("id")&" and abs(product)="&abs(CurrBookID)&""
							rs7.open sql7,conn,1,1
							if rs7.eof then
								price3=0
							else
								price3=zbcdbl(rs7("price3"))
							end if
							rs7.close
							set rs7=nothing
							Response.write("<td><div align='right'>"&Formatnumber(price3,SalesPrice_dot_num,-1)&"</div></td>")
							set rs7=nothing
							rs2.movenext
						loop
					end if
					rs2.close
					set rs2=nothing
				end if
				Response.write("</tr>")
				set rs=server.CreateObject("adodb.recordset")
				sql="select ord,sort1 from pricegate1 where num1=1 order by gate1 desc,id asc"
				rs.open sql,conn,1,1
				if not rs.eof then
					do until rs.eof
						set rs7=server.CreateObject("adodb.recordset")
						sql7="select txm,price1jy,price1,price2jy,price2 from jiage where bm="&rs("ord")&" and unit="&abs(rs1("ord"))&" and abs(product)="&CurrBookID&""
						rs7.open sql7,conn,1,1
						if rs7.eof then
							txm=""
							price1jy=0
							price1=0
							price2jy=0
							price2=0
						else
							txm=rs7("txm")
							price1jy=zbcdbl(rs7("price1jy"))
							price1=zbcdbl(rs7("price1"))
							price2jy=zbcdbl(rs7("price2jy"))
							price2=zbcdbl(rs7("price2"))
						end if
						rs7.close
						set rs7=nothing
						if price1jy="" then price1jy=0
						if price2jy="" then price2jy=0
						Response.write "" & vbcrlf & "             <tr  onmouseout=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                  <td><div align=""center""></div></td>" & vbcrlf & "                       <td><div align=""center""></div></td>" & vbcrlf & "                       <td>&nbsp;</td>" & vbcrlf & "                 "
						If CGMainUnitTactics&"" = "1" and ZBRuntime.MC(15000) Then
							Response.write "" & vbcrlf & "                     <td>&nbsp;</td>" & vbcrlf & "                 "
						end if
						Response.write "" & vbcrlf & "                     <td>&nbsp;</td>" & vbcrlf & "                 "
						If phXlhManageShow Then
							Response.write "" & vbcrlf & "                     <td>&nbsp;</td>" & vbcrlf & "                 "
						end if
						If isOpenMoreUnitAttr Then
							Response.write "" & vbcrlf & "                     <td>&nbsp;</td>" & vbcrlf & "                 <td>&nbsp;</td>" & vbcrlf & "                 "
						end if
						Response.write "" & vbcrlf & "                     <td  height=""27""><div align=""center"">"
						Response.write rs("sort1")
						Response.write "</div></td>" & vbcrlf & ""
						if proStore=1 then
							Response.write "" & vbcrlf & "                     <td style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center""><div align=""center""></div></td>" & vbcrlf & "                      <td style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center""><div align=""center""></div></td>" & vbcrlf & "                  <td style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center""><div align=""center""></div></td>" & vbcrlf & ""
'if proStore=1 then
						end if
						Response.write "" & vbcrlf & "                     <td><div align=""center"">"
						Response.write txm
						Response.write "</div></td>" & vbcrlf & ""
						if ZBRuntime.MC(15000) and open_21_21<>0 then
							Response.write "" & vbcrlf & "                     <td><div align=""right"">"
							Response.write Formatnumber(price1jy,StorePrice_dot_num,-1)
							Response.write "" & vbcrlf & "                     <td><div align=""right"">"
							Response.write "</div></td>" & vbcrlf & "                  <td><div align=""right"">"
							Response.write Formatnumber(price1,StorePrice_dot_num,-1)
							Response.write "</div></td>" & vbcrlf & "                  <td><div align=""right"">"
							Response.write "</div></td>" & vbcrlf & ""
						end if
						if ZBRuntime.MC(7000) and open_21_22<>0 then
							Response.write "" & vbcrlf & "                                             <td><div align=""right"">"
							Response.write Formatnumber(price2jy,SalesPrice_dot_num,-1)
							Response.write "" & vbcrlf & "                                             <td><div align=""right"">"
							Response.write "</div></td>" & vbcrlf & "                                          <td ><div align=""right"">"
							Response.write Formatnumber(price2,SalesPrice_dot_num,-1)
							Response.write "</div></td>" & vbcrlf & "                                          <td ><div align=""right"">"
							Response.write "</div></td>" & vbcrlf & ""
							set rs2=server.CreateObject("adodb.recordset")
							sql2="select id from sort5 where time1=1 order by sort1 asc,gate2 desc"
							rs2.open sql2,conn,1,1
							do until rs2.eof
								set rs7=server.CreateObject("adodb.recordset")
								sql7="select  isnull(price3,0) price3 from jiage where bm="&rs("ord")&" and unit="&abs(rs1("ord"))&" and sort="&rs2("id")&" and abs(product)="&abs(CurrBookID)&""
								rs7.open sql7,conn,1,1
								if rs7.eof then
									price3=0
								else
									price3=zbcdbl(rs7("price3"))
								end if
								rs7.close
								set rs7=nothing
								Response.write("<td><div align='right'>"&Formatnumber(price3,SalesPrice_dot_num,-1)&"</div></td>")
								set rs7=nothing
								rs2.movenext
							loop
							rs2.close
							set rs2=nothing
						end if
						Response.write("</tr>")
						rs.movenext
					loop
				end if
				rs.close
				set rs=nothing
				rs1.movenext
			loop
		end if
		rs1.close
		set rs1=nothing
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select a.ord,a.sort1 , b.name from ErpUnits a inner join erp_comm_UnitGroup b on b.id = a.unitgp where a.ord in (select unit from jiage where abs(product)="&CurrBookID&") and ord<>"&unitjb&" order by  a.gate1 desc "
		rs1.open sql1,conn,1,1
		i=0
		if Not rs1.eof then
			do until rs1.eof
				cgMainUnit = 0 : xlhManage = 0
				sql7="select a.bl,a.txm,a.price1jy,a.price1,a.price2jy,a.price2,a.MainStore,b.sort1,a.StoreCapacity,isnull(a.cgMainUnit,0) cgMainUnit,isnull(a.xlhManage,0) xlhManage,a.product from jiage a left join sortck b on a.MainStore=b.id where bm=0 and unit="&rs1("ord")&" and abs(product)="&CurrBookID&""
				set rs7=conn.execute(sql7)
				if rs7.eof then
					bl=1
					txm=""
					price1jy=0
					price1=0
					price2jy=0
					price2=0
					MainStore=""
					StoreName=""
					StoreCapacity=""
					isUnitStop=0
				else
					bl=rs7("bl")
					txm=rs7("txm")
					price1jy=zbcdbl(rs7("price1jy"))
					price1=zbcdbl(rs7("price1"))
					price2jy=zbcdbl(rs7("price2jy"))
					price2=zbcdbl(rs7("price2"))
					MainStore=rs7("MainStore")
					StoreName=rs7("sort1")
					StoreCapacity=rs7("StoreCapacity")
					cgMainUnit=rs7("cgMainUnit") : xlhManage=rs7("xlhManage")
					if rs7("product")>0 then
						isUnitStop=0
					else
						isUnitStop=1
					end if
				end if
				rs7.close
				set rs7=nothing
				if price1jy="" then price1jy=0
				if price2jy="" then price2jy=0
				if cgMainUnit&""="" then cgMainUnit=0
				if xlhManage&""="" then xlhManage=0
				Response.write "" & vbcrlf & "             <tr  onmouseout=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                  <td><div align=""center"">"
				Response.write rs1("name")
				Response.write "</div></td>" & vbcrlf & "                  <td><div align=""center"">"
				Response.write rs1("sort1")
				Response.write "</div></td>" & vbcrlf & "                  <td><div align=""center"">"
				Response.write FormatNumber(bl,num1_dot,-1,0,-1)
				Response.write "</div></td>" & vbcrlf & "                  <td><div align=""center"">"
				Response.write "<font class=""red""> "
				Response.write baseUnitName
				Response.write "</font></div></td>" & vbcrlf & "                   "
				If CGMainUnitTactics&"" = "1" and ZBRuntime.MC(15000) Then Response.write "<td><div align='center'>"& iif(cgMainUnit=1,"是","") &"</div></td>"
				Response.write "<td><div align='center'>"& iif(isUnitStop=1,"是","") &"</div></td>"
				If phXlhManageShow Then Response.write "<td><div align='center'>"& iif(xlhManage=1,"是","") &"</div></td>"
				If isOpenMoreUnitAttr Then
					UnitAttr = GetProductGroupAttrID(ord , rs1("ord"))
					Response.write "" & vbcrlf & "                             <td style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center""><div align=""center"">"
					UnitAttr = GetProductGroupAttrID(ord , rs1("ord"))
					Response.write LoadUnitAttrHtml("readonly" , 0,CurrBookID ,0, rs1("ord"))
					Response.write "</div></td>" & vbcrlf & "                          <td style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center""><div align=""center"">"
					Response.write LoadUnitAttrHtml("readonly" , 0,CurrBookID ,0, rs1("ord"))
					Response.write LoadFormulaParameter("readonly" , 0,CurrBookID , UnitAttr ,num1_dot )
					Response.write "</div></td>" & vbcrlf & "                          "
				end if
				Response.write "" & vbcrlf & "                     <td  height=""27""><div align=""center"">基础价格</div></td>" & vbcrlf & ""
				if proStore=1 then
					Response.write "" & vbcrlf & "                     <td style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center""><div align=""center"">"
'if proStore=1 then
					Response.write StoreName
					Response.write "</div></td>" & vbcrlf & "                  <td style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center""><div align=""center"">"
					Response.write StoreName
					Response.write StoreCapacity
					Response.write "</div></td>" & vbcrlf & "                  <td style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center"">" & vbcrlf & "                           <div align=""center"">" & vbcrlf & "                                      <span style=""cursor:pointer"" onMouseOver=""this.style.textDecoration='underline';"" onMouseOut=""this.style.textDecoration='none';"" onClick=""ShowSlaveStore(this,"
					Response.write CurrBookID
					Response.write ","
					Response.write rs1("ord")
					Response.write ");"">查看</span>" & vbcrlf & "                           </div>" & vbcrlf & "                  </td>" & vbcrlf & ""
				end if
				Response.write "" & vbcrlf & "                     <td><div align=""center"">"
				Response.write txm
				Response.write "</div></td>" & vbcrlf & ""
				if ZBRuntime.MC(15000) and open_21_21<>0 then
					Response.write "" & vbcrlf & "                     <td><div align=""right"">"
					Response.write Formatnumber(price1jy,StorePrice_dot_num,-1)
					Response.write "" & vbcrlf & "                     <td><div align=""right"">"
					Response.write "</div></td>" & vbcrlf & "                  <td><div align=""right"">"
					Response.write Formatnumber(price1,StorePrice_dot_num,-1)
					Response.write "</div></td>" & vbcrlf & "                  <td><div align=""right"">"
					Response.write "</div></td>" & vbcrlf & ""
				end if
				if ZBRuntime.MC(7000) and open_21_22<>0 then
					Response.write "" & vbcrlf & "                             <td><div align=""right"">"
					Response.write Formatnumber(price2jy,SalesPrice_dot_num,-1)
					Response.write "" & vbcrlf & "                             <td><div align=""right"">"
					Response.write "</div></td>" & vbcrlf & "                          <td ><div align=""right"">"
					Response.write Formatnumber(price2,SalesPrice_dot_num,-1)
					Response.write "</div></td>" & vbcrlf & "                          <td ><div align=""right"">"
					Response.write "</div></td>" & vbcrlf & ""
				end if
				set rs2=server.CreateObject("adodb.recordset")
				sql2="select id from sort5 where time1=1 and id in ("&bm_list&") order by sort1 asc,gate2 desc"
				rs2.open sql2,conn,1,1
				do until rs2.eof
					set rs7=server.CreateObject("adodb.recordset")
					sql7="select  isnull(price3,0) price3 from jiage where bm=0 and unit="&abs(rs1("ord"))&" and sort="&rs2("id")&" and abs(product)="&abs(CurrBookID)&""
					rs7.open sql7,conn,1,1
					if rs7.eof then
						price3=0
					else
						price3=zbcdbl(rs7("price3"))
					end if
					rs7.close
					set rs7=nothing
					Response.write("<td><div align='right'>"&Formatnumber(price3,SalesPrice_dot_num,-1)&"</div></td>")
					set rs7=nothing
					rs2.movenext
				loop
				rs2.close
				set rs2=nothing
				Response.write("</tr>")
				set rs=server.CreateObject("adodb.recordset")
				sql="select ord,sort1 from pricegate1 where num1=1 and ord in (select bm from jiage where product="&CurrBookID&") order by gate1 desc,id asc"
				rs.open sql,conn,1,1
				if not rs.eof then
					do until rs.eof
						set rs7=server.CreateObject("adodb.recordset")
						sql7="select txm,price1jy,price1,price2jy,price2 from jiage where bm="&rs("ord")&" and unit="&abs(rs1("ord"))&" and abs(product)="&CurrBookID&""
						rs7.open sql7,conn,1,1
						if rs7.eof then
							txm=""
							price1jy=0
							price1=0
							price2jy=0
							price2=0
						else
							txm=rs7("txm")
							price1jy=zbcdbl(rs7("price1jy"))
							price1=zbcdbl(rs7("price1"))
							price2jy=zbcdbl(rs7("price2jy"))
							price2=zbcdbl(rs7("price2"))
						end if
						rs7.close
						set rs7=nothing
						if price1jy="" then price1jy=0
						if price2jy="" then price2jy=0
						Response.write "" & vbcrlf & "             <tr  onmouseout=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                  <td><div align=""center""></div></td>" & vbcrlf & "                       <td><div align=""center""></div></td>" & vbcrlf & "                       <td>&nbsp;</td>" & vbcrlf & "                 "
						If CGMainUnitTactics&"" = "1" and ZBRuntime.MC(15000) Then
							Response.write "" & vbcrlf & "                     <td>&nbsp;</td>" & vbcrlf & "                 "
						end if
						Response.write "" & vbcrlf & "                     <td>&nbsp;</td>" & vbcrlf & "                 "
						If phXlhManageShow Then
							Response.write "" & vbcrlf & "                     <td>&nbsp;</td>" & vbcrlf & "                 "
						end if
						If isOpenMoreUnitAttr Then
							Response.write "" & vbcrlf & "                     <td>&nbsp;</td>" & vbcrlf & "                 <td>&nbsp;</td>" & vbcrlf & "                 "
						end if
						Response.write "" & vbcrlf & "                     <td  height=""27""><div align=""center"">"
						Response.write rs("sort1")
						Response.write "</div></td>" & vbcrlf & ""
						if proStore=1 then
							Response.write "" & vbcrlf & "                     <td width=""70"" style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center""><div align=""center""></div></td>" & vbcrlf & "                     <td width=""70"" style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center""><div align=""center""></div></td>" & vbcrlf & "                        <td width=""50"" style=""border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"" align=""center""><div align=""center""></div></td>" & vbcrlf & ""
'if proStore=1 then
						end if
						Response.write "" & vbcrlf & "                     <td><div align=""center"">"
						Response.write txm
						Response.write "</div></td>" & vbcrlf & ""
						if ZBRuntime.MC(15000) and open_21_21<>0 then
							Response.write "" & vbcrlf & "                     <td><div align=""right"">"
							Response.write Formatnumber(price1jy,StorePrice_dot_num,-1)
							Response.write "" & vbcrlf & "                     <td><div align=""right"">"
							Response.write "</div></td>" & vbcrlf & "                  <td><div align=""right"">"
							Response.write Formatnumber(price1,StorePrice_dot_num,-1)
							Response.write "</div></td>" & vbcrlf & "                  <td><div align=""right"">"
							Response.write "</div></td>" & vbcrlf & ""
						end if
						if ZBRuntime.MC(7000) and open_21_22<>0 then
							Response.write "" & vbcrlf & "                     <td><div align=""right"">"
							Response.write Formatnumber(price2jy,SalesPrice_dot_num,-1)
							Response.write "" & vbcrlf & "                     <td><div align=""right"">"
							Response.write "</div></td>" & vbcrlf & "                  <td ><div align=""right"">"
							Response.write Formatnumber(price2,SalesPrice_dot_num,-1)
							Response.write "</div></td>" & vbcrlf & "                  <td ><div align=""right"">"
							Response.write "</div></td>" & vbcrlf & ""
							set rs2=server.CreateObject("adodb.recordset")
							sql2="select id from sort5 where time1=1 and id in ("&bm_list&") order by sort1 asc,gate2 desc"
							rs2.open sql2,conn,1,1
							do until rs2.eof
								set rs7=server.CreateObject("adodb.recordset")
								sql7="select isnull(price3,0) price3 from jiage where bm="&rs("ord")&" and unit="&abs(rs1("ord"))&" and sort="&rs2("id")&" and abs(product)="&abs(CurrBookID)&""
								rs7.open sql7,conn,1,1
								if rs7.eof then
									price3=0
								else
									price3=zbcdbl(rs7("price3"))
								end if
								rs7.close
								set rs7=nothing
								Response.write("<td><div align='right'>"&Formatnumber(price3,SalesPrice_dot_num,-1)&"</div></td>")
								set rs7=nothing
								rs2.movenext
							loop
							rs2.close
							set rs2=nothing
						end if
						Response.write("</tr>")
						rs.movenext
					loop
				end if
				rs.close
				set rs=nothing
				rs1.movenext
			loop
		end if
		rs1.close
		set rs1=nothing
		Response.write "" & vbcrlf & "     </table>" & vbcrlf & "    </div>" & vbcrlf & "" & vbcrlf & ""
	end if
	Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "           </tr>" & vbcrlf & "" & vbcrlf & "   <tr class=""top accordion"">" & vbcrlf & "                <td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "                   <div  class=""accordion-bar-tit"">图片信息<span class=""accordion-arrow-down""></span>" & vbcrlf & "                  </div>" & vbcrlf & "                </td>" & vbcrlf & "   </tr>" & vbcrlf & "   <tr>" & vbcrlf & "            <td width=""10%"" height=""27""><div align=""right"">产品图片：</div></td>" & vbcrlf & "          <td height=""27"" colspan=""5"">" & vbcrlf & "                <ul class=""multimage-gallery"">" & vbcrlf & "            "
	Response.write "" & vbcrlf & "     </table>" & vbcrlf & "    </div>" & vbcrlf & "" & vbcrlf & ""
	Set rs = server.CreateObject("adodb.recordset")
	sql = "SELECT TOP 6 * FROM sys_upload_res WHERE source = 'productPic' AND id1 = "& ord &" ORDER BY id3 ASC"
	rs.open sql,conn,1,1
	If Not rs.Eof Then
		Dim x
		x = 1
		Do While Not rs.Eof
			Response.write "" & vbcrlf & "                     <li data-index="""
'Do While Not rs.Eof
			Response.write x
			Response.write """ "
			If x = 1 Then
				Response.write " class=""primary"""
			end if
			Response.write ">" & vbcrlf & "                            "
			If x = 1 Then
				Response.write "" & vbcrlf & "                             <div class=""info"" style=""display:none;"">主图 <span class=""red"">*</span><br>800*800</div>" & vbcrlf & "                              "
			end if
			Response.write "" & vbcrlf & "                             <div class=""preview""><a href=""../edit/upimages/product/"
			Response.write rs("fpath")
			Response.write """ target=""_blank""><img src=""../edit/upimages/product/"
			Response.write rs("fpath")
			Response.write """ fileID="""
			Response.write rs("id")
			Response.write """ border=""0""></a></div>" & vbcrlf & "                             <div class=""operate"">" & vbcrlf & "                                     <i class=""toleft"">左移</i>" & vbcrlf & "                                        <i class=""toright"">右移</i>" & vbcrlf & "                                       <i class=""del"">删除</i>" & vbcrlf & "                           </div>" & vbcrlf & "                  </li>" & vbcrlf & "           "
			x = x + 1
			rs.movenext
		Loop
	end if
	rs.close
	set rs = nothing
	Response.write "" & vbcrlf & "             </ul>" & vbcrlf & "           </td>" & vbcrlf & "   </tr>" & vbcrlf & "" & vbcrlf & "           <tr class=""top accordion"">" & vbcrlf & "                        <td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "                           <div  class=""accordion-bar-tit"">" & vbcrlf & "                                  概要信息<span class=""accordion-arrow-down""></span>" & vbcrlf & "                             </div>" & vbcrlf & "                  </td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td height=""27"" width=""11%""><div align=""right"">产品说明：</div></td>" & vbcrlf & "                  <td colspan=""5"" class=""gray""><font class=""gray"">"
	Response.write intro1
	Response.write "</font></td>" & vbcrlf & "         </tr>" & vbcrlf & ""
	if open_21_20=3 or CheckPurview(intro_21_20,trim(cateid))=True then
		Response.write "" & vbcrlf & "             <tr>" & vbcrlf & "                    <td height=""27""><div align=""right"">产品参数：</div></td>" & vbcrlf & "                    <td colspan=""5"" class=""gray""><font class=""gray"">"
		Response.write intro2
		Response.write "</font></td>" & vbcrlf & "         </tr>" & vbcrlf & ""
	end if
	Response.write "" & vbcrlf & "             <tr>" & vbcrlf & "                    <td height=""27""><div align=""right"">图片与附件：</div></td>" & vbcrlf & "                  <td colspan=""5"" class=""gray ewebeditorImg""><font class=""gray"">"
	Response.write intro3
	Response.write "</font></td>" & vbcrlf & "         </tr>" & vbcrlf & ""
	Response.write ShowExtendedByKZZDY(16001, ord ,1,1,5, true , "" , "" , 21 , true,0)
	If ZBRuntime.MC(76010) Then
		Dim s,validTime
		Set s = GetSettingHelper(conn)
		validTime = s.shop.preOrderValidTime
		Dim strWhere,qxOpen, qxIntro
		sdk.setup.getpowerattr 109,1,qxOpen, qxIntro
		If qxOpen = 3 Or qxOpen = 1 Then
			Response.write "" & vbcrlf & "<tr class=""top accordion"">" & vbcrlf & "     <td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "           <div  class=""accordion-bar-tit"">" & vbcrlf & "                  微信商品<span class=""accordion-arrow-down""></span>" & vbcrlf & "                </div>" & vbcrlf & "  </td>" & vbcrlf & "</tr>" & vbcrlf & "<tr><td colspan=""6""><div style=""width:100%;overflow-x:auto"">" & vbcrlf & "<table width=""100%""  border=""0"" cellpadding=""3"" id=""content"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;"">" & vbcrlf & "       <tr class=""top"" onMouseOut=""this.style.backgroundColor=''""onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "           <td width=""20%"" height=""27""><div align=""center"">商品名称</div></td>" & vbcrlf & "           <td width=""5%""><div align=""center"">单位</div></td>" & vbcrlf & "          <td width=""30%"" class=""name""><div align=""center"">商品属性</div></td>" & vbcrlf & "             <td width=""10%"" class=""name""><div align=""center"">市场价</div></td>" & vbcrlf & "            <td width=""10%"" class=""name""><div align=""center"">可售数量</div></td>" & vbcrlf & "          <td width=""15%"" height=""20"" class=""name""><div align=""center"">所属分类</div></td>" & vbcrlf & "                <td width=""10%"" class=""name""><div align=""center"">状态</div></td>" & vbcrlf & "   </tr>" & vbcrlf & "   "
			If qxOpen = 3 Then
				strWhere = " AND 1 = 1"
			else
				strWhere = " AND  (LEN( cast('"& qxIntro &"' as varchar(max))) = 0 OR CHARINDEX(','+ CAST(a.creator AS VARCHAR) +',' ,  cast(',"& qxIntro &",' as varchar(max))  ) > 0) "
				strWhere = " AND 1 = 1"
			end if
			sql =       "SELECT TOP 4 a.id, a.bh AS 商品编号, a.name AS goodsName, b.sort1 AS goodsUnit," &_
			"(CASE WHEN LEN([dbo].[GetGoodsAttrVal](a.id)) > 0 THEN SUBSTRING([dbo].[GetGoodsAttrVal](a.id),2,LEN([dbo].[GetGoodsAttrVal](a.id)) - 1) END) AS " &_
			"goodsAttr, isnull(a.price1,0) AS goodsPrice,   "&_
			"ISNULL((SELECT SUM(num) num " &_
			"FROM    " &_
			"( " &_
			"  SELECT SUM(num1) num " &_
			"  FROM   Shop_StorageAppendLog " &_
			"  WHERE  goodsId = a.id " &_
			"  UNION ALL " &_
			"  SELECT ISNULL(SUM(num1), 0) *- 1 num " &_
			"  UNION ALL " &_
			"  FROM   contractlist aaa " &_
			"  INNER JOIN contract bbb ON aaa.contract = bbb.ord " &_
			"  WHERE  1 = 1 " &_
			"  AND aaa.goodsId = a.id " &_
			"  AND ( bbb.payStatus = 1   " &_
			"            OR bbb.payStatus = 2 " &_
			"            OR (bbb.payKind = 2 AND bbb.del = 1 ) " &_
			"OR (bbb.payKind = 1 and bbb.del = 1 AND DATEDIFF(mi,bbb.date7,GETDATE()) <=" & validTime &")"  &_
			"            ) " &_
			") aa),0) AS goodsNum, c.sort1 AS goodsCategory,  " &_
			"(CASE a.onSale WHEN 1 THEN '上架' WHEN 0 THEN '下架' ELSE '定时上架' END) AS goodsStatus,  " &_
			"d.name AS 添加人,a.createtime AS 添加时间,a.creator " &_
			"FROM Shop_Goods a " &_
			"LEFT JOIN sortonehy b ON b.ord = a.unit " &_
			"LEFT JOIN sortonehy c ON c.ord = a.sortonehy " &_
			"LEFT JOIN gate d ON d.ord = a.creator " &_
			"WHERE a.del = 1 AND a.product = "& CurrBookID &" "& strWhere &" " &_
			"ORDER BY a.createtime DESC "
			set rs = conn.execute(sql)
			If Not rs.Eof Then
				Dim rowNum
				rowNum = 0
				Do While Not rs.Eof
					goodsID = rs("id")
					goodsName = rs("goodsName")
					goodsUnit = rs("goodsUnit")
					goodsAttr = rs("goodsAttr")
					goodsPrice = rs("goodsPrice")
					goodsNum = rs("goodsNum")
					goodsCategory = rs("goodsCategory")
					goodsStatus = rs("goodsStatus")
					goodsCreator = rs("creator")
					Response.write "" & vbcrlf & "      <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "           <td height=""27""><div align=""center"">" & vbcrlf & "                "
					sdk.setup.getpowerattr 109,14,qxOpen14, qxIntro14
					If qxOpen14 = 3 Or (qxOpen14 = 1 And CheckPurview(qxIntro14,Trim(goodsCreator)) = True) Then
						Response.write "" & vbcrlf & "<a href=""javascript:;"" onClick=""javascript:window.open('../MicroMsg/Goods/content.asp?id="
						Response.write pwurl(goodsID)
						Response.write "','goodsWin','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看商品详情"">            " & vbcrlf & "                "
						'Response.write pwurl(goodsID)
					end if
					Response.write goodsName
					Response.write "</a></div></td>" & vbcrlf & "               <td><div align=""center"">"
					Response.write goodsUnit
					Response.write "</div></td>" & vbcrlf & "           <td><div align=""center"">"
					Response.write goodsAttr
					Response.write "</div></td>" & vbcrlf & "           <td><div align=""center"">"
					Response.write FormatNumber(goodsPrice,SalesPrice_dot_num,-1)
					Response.write "</div></td>" & vbcrlf & "           <td><div align=""center"">"
					Response.write "</div></td>" & vbcrlf & "           <td><div align=""center"">"
					Response.write Formatnumber(goodsNum,num1_dot,-1)
					Response.write "</div></td>" & vbcrlf & "           <td><div align=""center"">"
					Response.write "</div></td>" & vbcrlf & "           <td><div align=""center"">"
					Response.write goodsCategory
					Response.write "</div></td>" & vbcrlf & "           <td><div align=""center"">"
					Response.write goodsStatus
					Response.write "</div></td>" & vbcrlf & "   </tr>" & vbcrlf & "   "
					rowNum = rowNum + 1
					Response.write "</div></td>" & vbcrlf & "   </tr>" & vbcrlf & "   "
					If rowNum >= 3 Then Exit Do
					rs.movenext
				Loop
			else
				Response.write "" & vbcrlf & "      <tr><td colspan='7' height='27'><div align='center'>没有信息!</div></td></tr>" & vbcrlf & "   "
			End If
			rs.close
			set rs = nothing
			If rowNum >= 3 Then
				Response.write "" & vbcrlf & "      <tr >" & vbcrlf & "           <td height=""25"" colspan=""7""><div align=""right""><a href=""javascript:;"" onClick=""javascript:window.open('../MicroMsg/goods/list.asp?productid="
				Response.write CurrBookID
				Response.write "','newwins3d3','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');return false;""><font class=""red"">查看更多微信商品...&gt;&gt;&gt;</font></a></div></td>" & vbcrlf & "     </tr>" & vbcrlf & "   "
				Response.write CurrBookID
			End If
			Response.write "" & vbcrlf & "</table>" & vbcrlf & "</div></td></tr>" & vbcrlf & ""
		end if
	End If
	cateid=session("personzbintel2007")
	if ZBRuntime.MC(4000) then
		if open_4_1=3 or open_4_1=1 then
			if open_4_1=1 then
				str_bj=" and a.price in (select ord from price where cateid in ("&intro_4_1&")) "
			end if
			Response.write "" & vbcrlf & "<tr class=""top accordion"">" & vbcrlf & "<td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "<div  class=""accordion-bar-tit"">" & vbcrlf & "   报价明细<span class=""accordion-arrow-down""></span>" & vbcrlf & "</div>" & vbcrlf & "</td>" & vbcrlf & "</tr>" & vbcrlf & "<tr><td colspan=""6""><div style=""width:100%;overflow-x:auto"">" & vbcrlf & "       <table width=""100%""  border=""0"" cellpadding=""3"" id=""content"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;"">" & vbcrlf & ""
			str_bj=" and a.price in (select ord from price where cateid in ("&intro_4_1&")) "
			set rs2=server.CreateObject("adodb.recordset")
			sql2="select a.price1,a.num1,a.money1,a.date7,a.bz,a.price,a.unit,a.discount,a.priceAfterDiscount,a.priceIncludeTax,a.priceAfterTax,isnull(a.invoiceType,0) as invoiceType,a.taxRate,a.taxValue,a.moneyBeforeTax from pricelist a inner join price b on a.price=b.ord and b.del=1 where a.ord="&ord&" "&str_bj&" and a.del=1 order by a.date7 desc"
			rs2.open sql2,conn,1,1
			if rs2.eof then
				Response.write "<tr><td colspan='8' height='27'><div align='center'>没有信息!</div></td></tr>"
			else
				Response.write "" & vbcrlf & "              <tr class=""top"" onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                 <td width=""5%"" height=""27""><div align=""center"">报价日期</div></td>" & vbcrlf & "                    <td width=""8%""><div align=""center"">客户名称</div></td>" & vbcrlf & "                     <td width=""3%"" class=""name""><div align=""center"">单位</div></td>" & vbcrlf & "                       <td width=""5%"" class=""name""><div align=""center"">数量</div></td>" & vbcrlf & ""
				if open_4_21<>0 then
					priceColNum=10
					Response.write "" & vbcrlf & "                      <td width=""5%"" height=""20"" class=""name""><div align=""center"">未税单价</div></td>" & vbcrlf & "                 <td width=""5%"" class=""name""><div align=""center"">折扣</div></td>" & vbcrlf & "                       <td width=""5%"" class=""name""><div align=""center"">折后单价</div></td>" & vbcrlf & "                   <td width=""5%"" class=""name""><div align=""center"">含税单价</div></td>" & vbcrlf & "                       <td width=""5%"" class=""name""><div align=""center"">含税折后单价</div></td>" & vbcrlf & "                       <td width=""5%"" class=""name""><div align=""center"">票据类型</div></td>" & vbcrlf & "                   <td width=""5%"" class=""name""><div align=""center"">税率</div></td>" & vbcrlf & "                     <td width=""5%"" class=""name""><div align=""center"">税前总价</div></td>" & vbcrlf & "                   <td width=""5%"" class=""name""><div align=""center"">税额</div></td>" & vbcrlf & "                       <td width=""5%"" class=""name""><div align=""center"">税后总价</div></td>" & vbcrlf & ""
				else
					priceColNum=2
					Response.write "" & vbcrlf & "            <td width=""5%"" class=""name""><div align=""center"">票据类型</div></td>" & vbcrlf & "                     <td width=""5%"" class=""name""><div align=""center"">税率</div></td>" & vbcrlf & ""
				end if
				Response.write "" & vbcrlf & "                      <td width=""8%"" class=""name""><div align=""center"">关联报价</div></td>" & vbcrlf & "           </tr>" & vbcrlf & ""
				k_sell=1
				do until rs2.eof
					price1_sell=zbcdbl(rs2("price1"))
					num1_sell=zbcdbl(rs2("num1"))
					bz_sell=rs2("bz")
					date1_sell=rs2("date7")
					discount_sell=zbcdbl(rs2("discount"))
					priceAfterDiscount_sell=zbcdbl(rs2("priceAfterDiscount"))
					priceIncludeTax_sell=zbcdbl(rs2("priceIncludeTax"))
					priceAfterTax_sell=zbcdbl(rs2("priceAfterTax"))
					taxRate_sell=zbcdbl(rs2("taxRate"))
					taxValue_sell=zbcdbl(rs2("taxValue"))
					moneyBeforeTax_sell=zbcdbl(rs2("moneyBeforeTax"))
					unit_sell=rs2("unit")
					invoiceType_sell=rs2("invoiceType")
					price_id=zbcdbl(rs2("price"))
					money1=zbcdbl(rs2("money1"))
					if price1_sell="" then price1_sell=0
					if Len(num1_sell&"")=0 then num1_sell=0
					if Len(unit_sell&"")=0 then unit_sell=0
					If Len(discount_sell&"") = 0 Then discount_sell = 0
					If Len(priceAfterDiscount_sell&"") = 0 Then priceAfterDiscount_sell = 0
					If Len(priceIncludeTax_sell&"") = 0 Then priceIncludeTax_sell = 0
					If Len(priceAfterTax_sell&"") = 0 Then priceAfterTax_sell = 0
					If Len(taxRate_sell&"") = 0 Then taxRate_sell = 0
					If Len(taxValue_sell&"") = 0 Then taxValue_sell = 0
					If Len(moneyBeforeTax_sell&"") = 0 Then moneyBeforeTax_sell = 0
					If Len(money1&"") = 0 Then money1 = 0
					if bz_sell<>"" and  bz_sell<>"0" then
						set rs=server.CreateObject("adodb.recordset")
						sql="select sort1 from sortbz where id="&bz_sell&" "
						rs.open sql,conn,1,1
						if rs.eof then
							bzname_sell=""
						else
							bzname_sell=rs("sort1")
						end if
						rs.close
						set rs=nothing
					else
						bzname_sell=""
					end if
					set rs8=conn.execute("select ord,name,cateid, sort3,ISNULL(share,'-222') share from tel where del=1 and ord in (select isnull(company,0) from price where ord="&price_id&") ")
					bzname_sell=""
					if not rs8.eof then
						company_sell=rs8(0).value
						companyname_sell=rs8(1).value
						cateid_kh=rs8(2).value
						company_sort3 = rs8(3).value
						company_share = rs8(4).value
					else
						company_sell=0
						companyname_sell=""
						cateid_kh=-1
						companyname_sell=""
						company_sort3 = "1"
						company_share = ""
					end if
					set rs8=nothing
					if price_id<>"" and not isnull(price_id) then
						set rs7=server.CreateObject("adodb.recordset")
						sql7="select title,cateid from price where ord="&price_id&""
						rs7.open sql7,conn,1,1
						if rs7.eof then
							pricename_sell="关联报价已被删除"
							cateid_bj=0
						else
							pricename_sell=rs7("title")
							cateid_bj=rs7("cateid")
						end if
						rs7.close
						set rs7=nothing
					else
						pricename_sell=""
						cateid_bj=0
					end if
					set rs7=server.CreateObject("adodb.recordset")
					sql7="select sort1 from sortonehy where id="&unit_sell&""
					rs7.open sql7,conn,1,1
					if rs7.eof then
						unitname_sell=""
					else
						unitname_sell=rs7("sort1")
					end if
					rs7.close
					set rs7=nothing
					set rs8= server.CreateObject("adodb.recordset")
					sql8="select sort1 from sortonehy where id="&invoiceType_sell&""
					rs8.open sql8,conn,1,1
					if rs8.eof then
						invoiceTypeName_sell=""
					else
						invoiceTypeName_sell=rs8("sort1")
					end if
					Response.write "" & vbcrlf & "             <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td height=""27"">" & vbcrlf & "                  <div align=""center"">"
					Response.write date1_sell
					Response.write "</div></td>" & vbcrlf & "                  <td>"
					If company_sort3 ="2" Then
						If open_26_1 = 3 Or (open_26_1 = 1 And CheckPurview(intro_26_1,trim(cateid_kh))=True) Then
							if open_26_14=3 or CheckPurview(intro_26_14,trim(cateid_kh))=True then
								Response.write "" & vbcrlf & "                                             <a href=""javascript:;"" onclick=""javascript:window.open('../work2/content.asp?ord="
								Response.write pwurl(company_sell)
								Response.write "','new53win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看供应商详情"">"
								Response.write pwurl(company_sell)
								Response.write companyname_sell
								Response.write "</a>" & vbcrlf & "                            "
							else
								Response.write""&companyname_sell&""
							end if
						end if
					else
						If open_1_1 = 3 Or (open_1_1 = 1 And CheckPurview(intro_1_1,trim(cateid_kh))=True) Or InStr(1,","&company_share&",", ","&sdk.info.user&",",1) > 0 Or company_share = "1" Then
							if open_1_14=3 or CheckPurview(intro_1_14,trim(cateid_kh))=True then
								Response.write "" & vbcrlf & "                                             <a href=""javascript:;"" onclick=""javascript:window.open('../work/content.asp?ord="
								Response.write pwurl(company_sell)
								Response.write "','new53win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看客户详情"">"
								'Response.write pwurl(company_sell)
								Response.write companyname_sell
								Response.write "</a>" & vbcrlf & "                            "
							else
								Response.write""&companyname_sell&""
							end if
						end if
					end if
					Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   <td><div align=""center"">"
					Response.write unitname_sell
					Response.write "</div></td>" & vbcrlf & "                  <td><div align=""center"">"
					Response.write Formatnumber(num1_sell,num1_dot,-1)
					Response.write "</div></td>" & vbcrlf & "                  <td><div align=""center"">"
					Response.write "</div></td>" & vbcrlf & ""
					if open_4_21<>0 then
						Response.write "" & vbcrlf & "                     <td height=""20""><div align=""right"">"
						Response.write Formatnumber(price1_sell,SalesPrice_dot_num,-1)
						Response.write "" & vbcrlf & "                     <td height=""20""><div align=""right"">"
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write Formatnumber(discount_sell,DISCOUNT_DOT_NUM,-1)
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write Formatnumber(priceAfterDiscount_sell,SalesPrice_dot_num,-1)
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write Formatnumber(priceIncludeTax_sell,SalesPrice_dot_num,-1)
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write Formatnumber(priceAfterTax_sell,SalesPrice_dot_num,-1)
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write "</div></td>" & vbcrlf & "                  <td><div align=""center"">"
						Response.write invoiceTypeName_sell
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write Formatnumber(taxRate_sell,num_dot_xs,-1)
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write "%</div></td>" & vbcrlf & "                 <td height=""20""><div align=""right"">"
						Response.write Formatnumber(moneyBeforeTax_sell,num_dot_xs,-1)
						Response.write "%</div></td>" & vbcrlf & "                 <td height=""20""><div align=""right"">"
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write Formatnumber(taxValue_sell,num_dot_xs,-1)
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write Formatnumber(money1,num_dot_xs,-1)
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write "</div></td>" & vbcrlf & ""
					else
						Response.write "" & vbcrlf & "                     <td><div align=""center"">"
						Response.write invoiceTypeName_sell
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write Formatnumber(taxRate_sell,num_dot_xs,-1)
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write "%</div></td>" & vbcrlf & ""
					end if
					Response.write "" & vbcrlf & "                     <td height=""20""><div align=""center"">"
					if open_4_14=3 or (open_4_14=1 and CheckPurview(intro_4_14,trim(cateid_bj))=True) then
						Response.write "<a href=""javascript:;"" onClick=""javascript:window.open('../../SYSN/view/sales/price/price.ashx?ord="
						Response.write pwurl(price_id)
						Response.write "&view=details','new532win2','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看报价详情"">"
						'Response.write pwurl(price_id)
					end if
					Response.write pricename_sell
					Response.write "</a></div></td>" & vbcrlf & "              </tr>" & vbcrlf & ""
					k_sell=k_sell+1
					Response.write "</a></div></td>" & vbcrlf & "              </tr>" & vbcrlf & ""
					rs2.movenext
					if k_sell>3 then exit do
				loop
				if k_sell>3 then
					Response.write "" & vbcrlf & "             <tr >" & vbcrlf & "                   <td height="""
					Response.write 15+priceColNum
					Response.write "" & vbcrlf & "             <tr >" & vbcrlf & "                   <td height="""
					Response.write """><div align=""center""></div></td>" & vbcrlf & "                   <td colspan=""14""><div align=""right""><a href=""javascript:;"" onClick=""javascript:window.open('all_price.asp?ord="
					Response.write CurrBookID
					Response.write "','newwins3d3','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');return false;""><font class=""red"">查看更多报价明细..&gt;&gt;&gt;</font></a></div></td>" & vbcrlf & "             </tr>" & vbcrlf & ""
					Response.write CurrBookID
				end if
			end if
			rs2.close
			set rs2 = nothing
			Response.write "" & vbcrlf & "     </table>" & vbcrlf & "</div></td></tr>" & vbcrlf & ""
		end if
	end if
	cateid=session("personzbintel2007")
	if ZBRuntime.MC(5000) then
		if open_24_1=3 or open_24_1=1 then
			if open_24_1=1 then
				str_xj=" and a.cateid in ("&intro_24_1&") "
			end if
			Response.write "" & vbcrlf & "     <tr class=""top accordion"">" & vbcrlf & "<td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "<div  class=""accordion-bar-tit"">" & vbcrlf & "     询价明细<span class=""accordion-arrow-down""></span>" & vbcrlf & "</div>" & vbcrlf & "</td>" & vbcrlf & "</tr>" & vbcrlf & "<tr><td colspan=""6""><div style=""width:100%;overflow-x:auto"">" & vbcrlf & "     <table width=""100%""  border=""0"" cellpadding=""3"" id=""content"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;"">" & vbcrlf & ""
			str_xj=" and a.cateid in ("&intro_24_1&") "
			set rs2=server.CreateObject("adodb.recordset")
			sql2="select a.price1,a.num1,a.money1,a.date7,a.xunjia,a.unit,isnull(b.id,0) as pricelist,isnull(a.gys,0) as gys,isnull(j.company,0) as company from xunjialist as a inner join xunjia x on a.xunjia=x.id and a.del=1 left join pricelist b on a.ord = b.ord and b.del=1 and b.price=x.price left join price j on b.price=j.ord where a.ord="&ord&" "&str_xj&" and a.del=1 and a.gys>0 order by a.date7 desc"
			rs2.open sql2,conn,1,1
			if rs2.eof then
				Response.write "<tr><td colspan='9' height='27'><div align='center'>没有信息!</div></td></tr>"
			else
				Response.write "" & vbcrlf & "<tr class=""top"" onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "<td width=""12%"" height=""27""><div align=""center"">询价日期</div></td>" & vbcrlf & "                   <td width=""15%""><div align=""center"">供应商名称</div></td>" & vbcrlf & "                 <td width=""15%""><div align=""center"">关联询价</div></td>" & vbcrlf & "                     <td width=""7%"" class=""name""><div align=""center"">单位</div></td>" & vbcrlf & "                       <td width=""7%"" class=""name""><div align=""center"">数量</div></td>" & vbcrlf & "                       <td width=""7%"" class=""name""><div align=""center"">单价</div></td>" & vbcrlf & "                    <td width=""7%"" class=""name""><div align=""center"">总金额</div></td>" & vbcrlf & "                     <td width=""15%"" class=""name""><div align=""center"">关联报价</div></td>" & vbcrlf & "                  <td width=""15%""><div align=""center"">客户名称</div></td>" & vbcrlf & "             </tr>" & vbcrlf & ""
				k_sell=0
				do until rs2.eof
					k_sell=k_sell+1
'do until rs2.eof
					if k_sell>3 then exit do
					price1_sell=zbcdbl(rs2("price1"))
					num1_sell=zbcdbl(rs2("num1"))
					company_xj=rs2("company")
					gys_sell=rs2("gys")
					date1_sell=rs2("date7")
					moneyall_sell=zbcdbl(rs2("money1"))
					unit_sell=rs2("unit")
					xunjia_id=rs2("xunjia")
					pricelist_id=rs2("pricelist")
					if xunjia_id="" then xunjia_id=0
					if num1_sell="" then num1_sell=0
					if Len(unit_sell&"")=0 then unit_sell=0
					If Len(company_xj&"")=0 Then company_xj=0
					set rs8=conn.execute("select ord,name,cateid, sort3,ISNULL(share,'-222') share from tel where del=1 and ord="&company_xj&"")
'If Len(company_xj&"")=0 Then company_xj=0
					if not rs8.eof then
						company_sell=rs8(0).value
						companyname_sell=rs8(1).value
						cateid_kh=rs8(2).value
						company_sort3 = rs8(3).value
						company_share = rs8(4).value
					else
						company_sell=0
						companyname_sell=""
						cateid_kh=-1
						companyname_sell=""
						company_sort3 = "1"
						company_share = ""
					end if
					set rs8=nothing
					If Len(gys_sell&"")=0 Then gys_sell=0
					set rs8=conn.execute("select name,cateid from tel where del=1 and ord="&gys_sell&" ")
					if not rs8.eof then
						gysname_sell=rs8(0).value
						cateid_gys=rs8("cateid")
					else
						gysname_sell=""
						cateid_gys=0
					end if
					set rs8=nothing
					if xunjia_id<>"" and not isnull(xunjia_id) then
						set rs7=server.CreateObject("adodb.recordset")
						sql7="select title,cateid from xunjia where id="&xunjia_id&" "
						rs7.open sql7,conn,1,1
						if rs7.eof then
							xunjianame_sell=""
							cateid_xj=0
						else
							xunjianame_sell=rs7("title")
							cateid_xj=rs7("cateid")
						end if
						rs7.close
						set rs7=nothing
					else
						xunjianame_sell=""
						cateid_xj=0
					end if
					if pricelist_id<>"" and not isnull(pricelist_id) then
						set rs7=server.CreateObject("adodb.recordset")
						sql7="select ord,title from price where ord in (select price from pricelist where ord ="&ord&" and id="&pricelist_id&") "
						rs7.open sql7,conn,1,1
						if rs7.eof then
							price_id=0
							pricename_sell=""
							url_xj="../xunjia/content2.asp"
						else
							price_id=rs7("ord")
							pricename_sell=rs7("title")
							url_xj="../xunjia/content.asp"
						end if
						rs7.close
						set rs7=nothing
					else
						pricename_sell=""
						url_xj="../xunjia/content2.asp"
					end if
					set rs7=server.CreateObject("adodb.recordset")
					sql7="select sort1 from sortonehy where id="&unit_sell&""
					rs7.open sql7,conn,1,1
					if rs7.eof then
						unitname_sell=""
					else
						unitname_sell=rs7("sort1")
					end if
					rs7.close
					set rs7=nothing
					Response.write "" & vbcrlf & "             <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td height=""27"">" & vbcrlf & "                  <div align=""center"">"
					Response.write date1_sell
					Response.write "</div></td>" & vbcrlf & "                  <td>"
					If open_26_1=3 Or (open_26_1=1 and CheckPurview(intro_26_1,trim(cateid_gys))=True) then
						if open_26_14=3 or (open_26_14=1 and CheckPurview(intro_26_14,trim(cateid_gys))=True) then
							Response.write "<a href=""javascript:;"" onClick=""javascript:window.open('../work2/content.asp?ord="
							Response.write pwurl(gys_sell)
							Response.write "','new53win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看供应商详情"">"
							Response.write pwurl(gys_sell)
						end if
						Response.write gysname_sell
						Response.write "</a>"
					end if
					Response.write "</td>" & vbcrlf & "                        <td>"
					if open_24_14=3 or (open_24_14=1 and CheckPurview(intro_24_14,trim(cateid_xj))=True) then
						Response.write "<a href=""javascript:;"" onClick=""javascript:window.open('"
						Response.write url_xj
						Response.write "?ord="
						Response.write pwurl(xunjia_id)
						Response.write "','new53win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看询价详情"">"
						Response.write pwurl(xunjia_id)
					end if
					Response.write xunjianame_sell
					Response.write "</a></td>" & vbcrlf & "                    <td><div align=""center"">"
					Response.write unitname_sell
					Response.write "</div></td>" & vbcrlf & "                  <td><div align=""center"">"
					Response.write Formatnumber(num1_sell,num1_dot,-1)
					Response.write "</div></td>" & vbcrlf & "                  <td><div align=""center"">"
					Response.write "</div></td>" & vbcrlf & ""
					if open_24_21<>0 then
						Response.write "" & vbcrlf & "                     <td height=""20""><div align=""right"">"
						Response.write Formatnumber(price1_sell,StorePrice_dot_num,-1)
						Response.write "" & vbcrlf & "                     <td height=""20""><div align=""right"">"
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write Formatnumber(moneyall_sell,num_dot_xs,-1)
						Response.write "</div></td>" & vbcrlf & "                  <td height=""20""><div align=""right"">"
						Response.write "</div></td>" & vbcrlf & ""
					else
						Response.write "" & vbcrlf & "                     <td height=""20""><div align=""right"">&nbsp;</div></td>" & vbcrlf & "                        <td height=""20""><div align=""right"">&nbsp;</div></td>" & vbcrlf & ""
					end if
					Response.write "" & vbcrlf & "                     <td height=""20""><div align=""center"">"
					if open_4_14=3 or (open_4_14=1 and CheckPurview(intro_4_14,trim(cateid_bj))=True) then
						Response.write "<a href=""javascript:;"" onClick=""javascript:window.open('../../SYSN/view/sales/price/price.ashx?ord="
						Response.write pwurl(price_id)
						Response.write "&view=details','new532win2','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看报价详情"">"
						'Response.write pwurl(price_id)
					end if
					Response.write pricename_sell
					Response.write "</a></div></td>" & vbcrlf & "                      <td>" & vbcrlf & "                    "
					If company_sort3 ="2" Then
						If open_26_1 = 3 Or (open_26_1 = 1 And CheckPurview(intro_26_1,trim(cateid_kh))=True) Then
							if open_26_14=3 or CheckPurview(intro_26_14,trim(cateid_kh))=True then
								Response.write "" & vbcrlf & "                                             <a href=""javascript:;"" onclick=""javascript:window.open('../work2/content.asp?ord="
								Response.write pwurl(company_sell)
								Response.write "','new53win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看供应商详情"">"
								'Response.write pwurl(company_sell)
								Response.write companyname_sell
								Response.write "</a>" & vbcrlf & "                            "
							else
								Response.write""&companyname_sell&""
							end if
						end if
					else
						If open_1_1 = 3 Or (open_1_1 = 1 And CheckPurview(intro_1_1,trim(cateid_kh))=True) Or InStr(1,","&company_share&",", ","&sdk.info.user&",",1) > 0 Or company_share = "1" Then
							if open_1_14=3 or CheckPurview(intro_1_14,trim(cateid_kh))=True then
								Response.write "" & vbcrlf & "                                             <a href=""javascript:;"" onclick=""javascript:window.open('../work/content.asp?ord="
								Response.write pwurl(company_sell)
								Response.write "','new53win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;"" title=""点击可查看客户详情"">"
								'Response.write pwurl(company_sell)
								Response.write companyname_sell
								Response.write "</a>" & vbcrlf & "                            "
							else
								Response.write""&companyname_sell&""
							end if
						end if
					end if
					Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "           </tr>" & vbcrlf & ""
					rs2.movenext
				loop
				if k_sell>3 then
					Response.write "" & vbcrlf & "             <tr >" & vbcrlf & "                   <td height=""25""><div align=""center""></div></td>" & vbcrlf & "                     <td colspan=""8""><div align=""right""><a href=""javascript:;"" onClick=""javascript:window.open('../xunjia/planlist.asp?product="
					Response.write pwurl(CurrBookID)
					Response.write "','newwins3d3','width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');return false;""><font class=""red"">查看更多询价明细..&gt;&gt;&gt;</font></a></div></td>" & vbcrlf & "            </tr>" & vbcrlf & ""
					'Response.write pwurl(CurrBookID)
				end if
			end if
			rs2.close
			set rs2 = nothing
			Response.write "" & vbcrlf & "     </table>" & vbcrlf & "        </div></td></tr>" & vbcrlf & ""
		end if
	end if
	cateid=session("personzbintel2007")
	if ZBRuntime.MC(7000) Then
		Response.write "" & vbcrlf & "<tr class=""top accordion"">" & vbcrlf & "<td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "<div  class=""accordion-bar-tit"">" & vbcrlf & "  销售明细<span class=""accordion-arrow-down""></span>" & vbcrlf & "</div>" & vbcrlf & "</td>" & vbcrlf & "</tr>" & vbcrlf & "<tr><td colspan=""6""><div style=""width:100%;overflow-x:auto"">" & vbcrlf & "      <table width=""100%""  border=""0"" cellpadding=""3"" id=""content"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;"">" & vbcrlf & ""
'if ZBRuntime.MC(7000) Then
		If open_21_11&"" = "" Then open_21_11 = 0
		If intro_21_11&"" = "" Then intro_21_11 = "-222"
'If open_21_11&"" = "" Then open_21_11 = 0
		set rs2=server.CreateObject("adodb.recordset")
		sql2="select isnull(l.priceAfterTax,0) as price1,isnull(l.concessions,0) as concessions,l.num1,isnull(l.money1,0) as money1,l.date1,l.company,l.unit,l.contract ,b.sort1 as bzname,s.sort1 as unitname, "&_
		"  t.name,ISNULL(t.cateid,-222) cateid,ISNULL(t.share,-222) share,ISNULL(t.sort3,1) sort3,t.ord as tord,c.title,c.cateid as htcateid,c.ord as cord "&_
		" from contractlist l "&_
		"  left join sortbz b on b.id = l.bz "&_
		"  left join sortonehy s on s.id = l.unit "&_
		"  left join tel t on t.ord=l.company "&_
		"  left join contract c on c.ord = l.contract "&_
		"  where l.ord="&ord&" and l.del=1 and  isnull(c.status,-1) in (-1,1) and ("& open_5_1 &"=3 "&_
		"  left join contract c on c.ord = l.contract "&_
		"   OR (CHARINDEX(',' + CAST("&session("personzbintel2007")&" as varchar(12)) + ',', ',' +cast(c.share as varchar(max))+',' )>0) "&_
		"  left join contract c on c.ord = l.contract "&_
		"   or ("& open_5_1 &"=1 and charindex(','+cast(isnull(c.cateid,0) as varchar(10))+',',',"& intro_5_1 &",')>0)) "&_
		"  left join contract c on c.ord = l.contract "&_
		"  order by l.date1 desc"
		rs2.open sql2,conn,1,1
		if rs2.eof then
			Response.write "<tr><td "
			if setbz="1" then
				Response.write "colspan='9' "
			else
				Response.write "colspan='8' "
			end if
			Response.write " height='27'><div align='center'>没有信息!</div></td></tr>"
		else
			Response.write "" & vbcrlf & "             <tr class=""top"" onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                 <td width=""12%"" height=""27""><div align=""center"">销售日期</div></td>" & vbcrlf & "                   <td><div align=""center"">客户名称</div></td>" & vbcrlf & "                       <td width=""8%"" class=""name""><div align=""center"">单位</div></td>" & vbcrlf & "                     "
			if setbz="1" then
				Response.write "<td width=""8%"" class=""name""><div align=""center"">币种</div></td>"
			end if
			Response.write "" & vbcrlf & "                     <td width=""8%"" class=""name""><div align=""center"">数量</div></td>" & vbcrlf & "                       <td width=""10%"" height=""20"" class=""name""><div align=""center"">含税折后单价</div></td>" & vbcrlf & "                    <td width=""10%"" height=""20"" class=""name""><div align=""center"">优惠金额</div></td>" & vbcrlf & "                   <td width=""10%"" height=""20"" class=""name""><div align=""center"">产品总价</div></td>" & vbcrlf & "                        <td width=""15%"" height=""20"" class=""name""><div align=""center"">关联合同</div></td>" & vbcrlf & "                </tr>" & vbcrlf & ""
			price1_sell=0
			num1_sell=0
			date1_sell=""
			company_sell=0
			companyname_sell=0
			k_sell=1
			concessions = 0
			do until rs2.eof
				price1_sell=zbcdbl(rs2("price1"))
				concessions = rs2("concessions")
				num1_sell=zbcdbl(rs2("num1"))
				date1_sell=rs2("date1")
				company_sell=rs2("company")
				moneyall_sell=zbcdbl(rs2("money1"))
				contract_id=rs2("contract")
				if price1_sell="" then price1_sell=0
				if Len(num1_sell&"")=0 then num1_sell=0
				If Len(concessions&"") = 0 Then concessions = 0
				If Len(moneyall_sell&"") = 0 Then moneyall_sell = 0
				unitname_sell=rs2("unitname")
				bzname_sell=rs2("bzname")
				companyname_sell=""
				if Len(company_sell&"")=0 then company_sell=0
				if rs2("tord")&""="" then
					companyname_sell="已被删除"
					telCateid = ""
					telShare = ""
					telsort3 = 1
				else
					companyname_sell=rs2("name")&""
					telCateid = rs2("cateid")&""
					telShare = rs2("share")&""
					telsort3 = rs2("sort3")&""
				end if
				if contract_id<>"" and not isnull(contract_id) then
					if rs2("cord")&""="" then
						contractname_sell="关联合同已被删除"
						cateid_ht=0
					else
						contractname_sell=rs2("title")
						cateid_ht=rs2("htcateid")
					end if
				else
					contractname_sell=""
					cateid_ht=0
				end if
				Response.write "" & vbcrlf & "              <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td height=""27"">" & vbcrlf & "                  <div align=""center"">"
				Response.write date1_sell
				Response.write "</div></td>" & vbcrlf & "                   <td>" & vbcrlf & "            "
				If telsort3 ="2" Then
					If open_26_1 = 3 Or (open_26_1 = 1 And CheckPurview(intro_26_1,trim(telCateID))=True) Then
						if open_26_14=3 or CheckPurview(intro_26_14,trim(telCateID))=True then
							Response.write "" & vbcrlf & "                                              <a href=""javascript:;"" onclick=""javascript:window.open('../work2/content.asp?ord="
							Response.write pwurl(company_sell)
							Response.write "','new53win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看供应商详情"">"
							'Response.write pwurl(company_sell)
							Response.write companyname_sell
							Response.write "</a>" & vbcrlf & "                             "
						else
							Response.write""&companyname_sell&""
						end if
					end if
				else
					If open_1_1 = 3 Or (open_1_1 = 1 And CheckPurview(intro_1_1,trim(telCateID))=True) Or InStr(1,","&telShare&",", ","&sdk.info.user&",",1) > 0 Or telShare = "1" Then
						if open_1_14=3 or CheckPurview(intro_1_14,trim(telCateID))=True then
							Response.write "" & vbcrlf & "                                              <a href=""javascript:;"" onclick=""javascript:window.open('../work/content.asp?ord="
							Response.write pwurl(company_sell)
							Response.write "','new53win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看客户详情"">"
							'Response.write pwurl(company_sell)
							Response.write companyname_sell
							Response.write "</a>" & vbcrlf & "                             "
						else
							Response.write""&companyname_sell&""
						end if
					end if
				end if
				Response.write "" & vbcrlf & "            </td>" & vbcrlf & "                     <td><div align=""center"">"
				Response.write unitname_sell
				Response.write "</div></td>" & vbcrlf & "                   "
				if setbz="1" then
					Response.write "<td><div align=""center"">"
					Response.write bzname_sell
					Response.write "</div></td>"
				end if
				Response.write "" & vbcrlf & "                      <td><div align=""center"">"
				Response.write Formatnumber(num1_sell,num1_dot,-1)
				Response.write "" & vbcrlf & "                      <td><div align=""center"">"
				Response.write "</div></td>" & vbcrlf & "                   "
				if open_5_21<>0 then
					Response.write "" & vbcrlf & "                                              <td height=""20""><div align=""right"">"
					Response.write Formatnumber(price1_sell,SalesPrice_dot_num,-1)
					Response.write "</div></td>" & vbcrlf & "                                           <td height=""20""><div align=""right"">"
					Response.write Formatnumber(concessions,num_dot_xs,-1)
					Response.write "</div></td>" & vbcrlf & "                                           <td height=""20""><div align=""right"">"
					Response.write Formatnumber(moneyall_sell,num_dot_xs,-1)
					Response.write "</div></td>" & vbcrlf & "                   "
				else
					Response.write "" & vbcrlf & "                                              <td height=""20""><div align=""right"">&nbsp;</div></td>" & vbcrlf & "                                                <td height=""20""><div align=""right"">&nbsp;</div></td>" & vbcrlf & "                                                <td height=""20""><div align=""right"">&nbsp;</div></td>" & vbcrlf & "                        "
				end if
				Response.write "" & vbcrlf & "                      <td height=""20""><div align=""center"">" & vbcrlf & "                        " & vbcrlf & "                        "
				if open_5_1=3 or (open_5_1=1 And CheckPurview(intro_5_1,trim(cateid_ht))=True) Then
					if open_5_14=3 or (open_5_14=1 and CheckPurview(intro_5_14,trim(cateid_ht))=True) then
						Response.write "<a href=""javascript:;"" onClick=""javascript:window.open('../../SYSN/view/sales/contract/ContractDetails.ashx?ord="
						Response.write pwurl(contract_id)
						Response.write "&view=details','new532win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看详情"">"
						'Response.write pwurl(contract_id)
					end if
					Response.write contractname_sell
					Response.write "</a>" & vbcrlf & "                  "
				end if
				Response.write "" & vbcrlf & "                      </div></td>" & vbcrlf & "             </tr>" & vbcrlf & ""
				k_sell=k_sell+1
				Response.write "" & vbcrlf & "                      </div></td>" & vbcrlf & "             </tr>" & vbcrlf & ""
				rs2.movenext
				if k_sell>3 then exit do
			loop
			if k_sell>3 then
				Response.write "" & vbcrlf & "             <tr >" & vbcrlf & "                   <td height=""25""><div align=""center""></div></td>" & vbcrlf & "                     <td colspan=""9""><div align=""right""><a href=""javascript:;"" onClick=""javascript:window.open('../../SYSN/view/statistics/sale/product/ProductSaleDetail.ashx?pord="
				Response.write pwurl(CurrBookID)
				Response.write "','newwins3d3','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');return false;""><font class=""red"">查看更多销售明细..&gt;&gt;&gt;</font></a></div></td>" & vbcrlf & "             </tr>" & vbcrlf & ""
				'Response.write pwurl(CurrBookID)
			end if
			rs2.close
			set rs2 = nothing
			Response.write "" & vbcrlf & "     </table>" & vbcrlf & "        </div></td></tr>" & vbcrlf & ""
		end if
	end if
	if ZBRuntime.MC(8000) then
		if open_41_1=3 or open_41_1=1 then
			if open_41_1=1 then
				str_th=" and a.cateid in ("&intro_41_1&") "
			end if
			Response.write "" & vbcrlf & "<tr class=""top accordion"">" & vbcrlf & "<td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "<div  class=""accordion-bar-tit"">" & vbcrlf & "  退货明细<span class=""accordion-arrow-down""></span>" & vbcrlf & "</div>" & vbcrlf & "</td>" & vbcrlf & "</tr>" & vbcrlf & "<tr><td colspan=""6""><div style=""width:100%;overflow-x:auto"">" & vbcrlf & "      <table width=""100%""  border=""0"" cellpadding=""3"" id=""content"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;"">" & vbcrlf & ""
			str_th=" and a.cateid in ("&intro_41_1&") "
			if company_sell="" then company_sell=0
			Dim intContactId,conPrice,conMoney
			intContactId=0
			set rsthPro=server.CreateObject("adodb.recordset")
			sqlthPro="select Top 3 a.price1,a.num1,a.money1,a.caigou,a.unit,a.bz,isnull(kuoutlist2,0) as kuoutlist2 from contractthlist a inner join contractth b on a.caigou=b.ord where a.ord="&ord&" "&str_th&" and a.del=1 order by (select date3 from contractth where ord=a.caigou) desc,a.id desc"
			set objRs=conn.execute("select  caigou from contractthlist A WHERE ord="&ord&" "&str_th&" and del=1 order by ord desc")
			If Not objRs.eof Then intContactId=objRs.getString(,,"",",","")
			objRs.close
			Set objRs=Nothing
			intContactId=intContactId&"0"
			rsthPro.open sqlthPro,conn,1,1
			if rsthPro.eof then
				Response.write "<tr><td "
				Response.write " height='27'><div align='center'>没有信息!</div></td></tr>"
			else
				Response.write "" & vbcrlf & "             <tr class=""top"">" & vbcrlf & "<td height=""27"" ><div align=""center"">退货日期</div></td>" & vbcrlf & "<td width=""23%""  ><div align=""center"">关联客户</div></td>" & vbcrlf & "<td class=""name""  ><div align=""center"">单位</div></td>" & vbcrlf & "                                      <td width=""8%""class=""name""><div align=""center"">币种</div></td>" & vbcrlf &                                    "<td width=""6%""   class=""name""><div align=""center"">退货数量</div></td>" & vbcrlf &                                  "<td width=""7%""   class=""name""><div align=""center"">退货单价</div></td>" & vbcrlf &                                  "<td width=""7%""   class=""name""><div align=""center"">退货总价</div></td>" & vbcrlf & "                                      <td width=""7%""   class=""name""><div align=""center"">成本单价</div></td>" & vbcrlf & "                                 <td width=""7%"" class=""name""><div align=""center"">成本总价</div></td>" & vbcrlf & "                                   <td width=""17%""   height=""27"" class=""name""><div align=""center"">关联销售退货</div></td>" & vbcrlf & "                     </tr>" & vbcrlf & "         "
				do until rsthPro.eof
					price1_th=rsthPro(0)
					num1_th=rsthPro(1)
					money1_th=rsthPro(2)
					if rsthPro("caigou")<>"" then
						set rsth=server.CreateObject("adodb.recordset")
						sqlth="select date3,title,sort,complete1,company,ord,cateid from contractth where ord="&rsthPro("caigou")&" and del=1 order by ord desc"
						rsth.open sqlth,conn,1,1
						dim date1_th,title_th,sort_th,complete1_th,money1_th,company_th,companyname_th
						if rsth.eof = false then
							date1_th=rsth(0)
							title_th=rsth(1)
							sort_th=rsth(2)
							complete1_th=rsth(3)
							company_th=rsth(4)
							ord_th=rsth(5)
							cateid_th=rsth("cateid")
						else
							date1_th=0
							title_th=""
							sort_th=0
							complete1_th=0
							company_th=0
							ord_th=0
							cateid_th=0
						end if
						rsth.close
						set rs8=conn.execute("select ord,name,cateid, sort3,ISNULL(share,'-222') share from tel where del=1 and ord="&company_th&"")
						rsth.close
						if not rs8.eof then
							company_sell=rs8(0).value
							companyname_sell=rs8(1).value
							cateid_kh=rs8(2).value
							company_sort3 = rs8(3).value
							company_share = rs8(4).value
						else
							company_sell=0
							companyname_sell=""
							cateid_kh=-1
							companyname_sell=""
							company_sort3 = "1"
							company_share = ""
						end if
						set rs8=nothing
						If Len(sort_th&"")=0 Then sort_th=0
						set rs7=server.CreateObject("adodb.recordset")
						sql7="select sort1 from sortonehy where id="&sort_th&""
						rs7.open sql7,conn,1,1
						if rs7.eof then
							unitname_th=""
						else
							unitname_th=rs7("sort1")
						end if
						rs7.close
						set rs7=nothing
						If Len(complete1_th&"")=0 Then complete1_th=0
						set rs7=server.CreateObject("adodb.recordset")
						sql7="select sort1 from sortonehy where ord="&complete1_th&""
						rs7.open sql7,conn,1,1
						if rs7.eof then
							completeName1_th=""
						else
							completeName1_th=rs7("sort1")
						end if
						rs7.close
						set rs7=nothing
					end if
					conPrice=0
					conMoney=0
					kuoutlist2_value=rsthPro("kuoutlist2")
					If Len(kuoutlist2_value&"")=0 Then kuoutlist2_value=0
					set Rs7=conn.execute("select isNull(ku.num3,0) num3,isNull(ku.money1,0) money1  FROM ku,kuoutlist2 where ku.id=kuoutlist2.ku and kuoutlist2.id="&kuoutlist2_value)
					If Not Rs7.Eof Then
						If Rs7("num3")<>"0" Then
							conPrice=(zbcdbl(Rs7("money1"))&"")/(zbcdbl(Rs7("num3"))&"")
						else
							conPrice=(zbcdbl(Rs7("money1"))&"")/1
						end if
					end if
					conMoney=conPrice*(zbcdbl(rsthPro("num1"))&"")
					Response.write "" & vbcrlf & "             <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td width=""9%"" height=""27"">" & vbcrlf & "                 <div align=""center"">"
					Response.write date1_th
					Response.write "</div></td>" & vbcrlf & "                  <td><div align=""center"">" & vbcrlf & "            "
					If company_sort3 ="2" Then
						If open_26_1 = 3 Or (open_26_1 = 1 And CheckPurview(intro_26_1,trim(cateid_kh))=True) Then
							if open_26_14=3 or CheckPurview(intro_26_14,trim(cateid_kh))=True then
								Response.write "" & vbcrlf & "                                             <a href=""javascript:;"" onclick=""javascript:window.open('../work2/content.asp?ord="
								Response.write pwurl(company_sell)
								Response.write "','new53win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看供应商详情"">"
								'Response.write pwurl(company_sell)
								Response.write companyname_sell
								Response.write "</a>" & vbcrlf & "                            "
							else
								Response.write""&companyname_sell&""
							end if
						end if
					else
						If open_1_1 = 3 Or (open_1_1 = 1 And CheckPurview(intro_1_1,trim(cateid_kh))=True) Or InStr(1,","&company_share&",", ","&sdk.info.user&",",1) > 0 Or company_share = "1" Then
							if open_1_14=3 or CheckPurview(intro_1_14,trim(cateid_kh))=True then
								Response.write "" & vbcrlf & "                                             <a href=""javascript:;"" onclick=""javascript:window.open('../work/content.asp?ord="
								Response.write pwurl(company_sell)
								Response.write "','new53win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看客户详情"">"
								'Response.write pwurl(company_sell)
								Response.write companyname_sell
								Response.write "</a>" & vbcrlf & "                            "
							else
								Response.write""&companyname_sell&""
							end if
						end if
					end if
					Response.write "" & vbcrlf & "            </div></td>" & vbcrlf & "                      <td width=""9%""><div align=""center"">"
					If Len(rsthPro("unit")&"")>0 then
						Set Rso=Conn.execute("select sort1 from sortonehy where id="&rsthPro("unit")&"")
						If Not Rso.eof Then Response.write Rso(0)
						Rso.close
						Set Rso=Nothing
					end if
					Response.write "</div></td>" & vbcrlf & "           <td><div align=""center"">"
					If Len(rsthPro("bz")&"")>0 then
						Set Rso=Conn.execute("select sort1 from sortbz where id="&rsthPro("bz")&" ")
						If Not Rso.eof Then Response.write Rso(0)
						Rso.close
						Set Rso=Nothing
					end if
					Response.write "</div></td>" & vbcrlf & "            <td><div align=""center"">"
					Response.write Formatnumber(num1_th,num1_dot,-1)
					Response.write "</div></td>" & vbcrlf & "            <td><div align=""center"">"
					Response.write "</div></td>" & vbcrlf & "                  <td align=""right""><div align=""right"">" & vbcrlf & "                       "
					If open_5_21=1 Then
						Response.write Formatnumber(price1_th,SalesPrice_dot_num,-1)
'If open_5_21=1 Then
					else
						Response.write Formatnumber(0,SalesPrice_dot_num,-1)
'If open_5_21=1 Then
					end if
					Response.write "</div></td>" & vbcrlf & "                  <td><div align=""right"">"
					If open_5_21=1 Then
						Response.write Formatnumber(money1_th,num_dot_xs,-1)
'If open_5_21=1 Then
					else
						Response.write Formatnumber(0,num_dot_xs,-1)
'If open_5_21=1 Then
					end if
					Response.write "</div></td>" & vbcrlf & "                  <td align=""right"">" & vbcrlf & "                <div align=""right"">"
					If open_23_3=1 and len(conPrice&"")>0 Then
						Response.write formatNumber(conPrice,StorePrice_dot_num,-1)
'If open_23_3=1 and len(conPrice&"")>0 Then
					else
						Response.write formatNumber(0,StorePrice_dot_num,-1)
'If open_23_3=1 and len(conPrice&"")>0 Then
					end if
					Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "                      <td align=""right""><div align=""right"">" & vbcrlf & "                         "
					If open_23_3=1 and len(conMoney&"")>0 Then
						Response.write formatNumber(conMoney,num_dot_xs,-1)
'If open_23_3=1 and len(conMoney&"")>0 Then
					else
						Response.write formatNumber(0,num_dot_xs,-1)
'If open_23_3=1 and len(conMoney&"")>0 Then
					end if
					Response.write "" & vbcrlf & "                 </div></td>" & vbcrlf & "           <td align=""right"">" & vbcrlf & "          <div align=""center"">"
					if open_41_14=3 or (open_41_14=1 and CheckPurview(intro_41_14,trim(cateid_th))=True) then
						Response.write "<a href=""javascript:;"" onClick=""javascript:window.open('../contractth/content.asp?ord="
						Response.write pwurl(ord_th)
						Response.write "','new53win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看详情"">"
						'Response.write pwurl(ord_th)
					end if
					Response.write title_th
					Response.write "</a></div>" & vbcrlf & "          </td>" & vbcrlf & "            </tr>" & vbcrlf & "           "
					k_th=k_th+1
					Response.write "</a></div>" & vbcrlf & "          </td>" & vbcrlf & "            </tr>" & vbcrlf & "           "
					rsthPro.movenext
					if k_th>2 then exit do
				loop
				if k_th>2 then
					Response.write "" & vbcrlf & "                                     <form action=""../contractth/ReturnDetail.asp?page_count=20&page=1"" method=""Post"" id=""postForm"" target=""ReturnDetailNewWin"">" & vbcrlf & "                                             <input name=""ord"" id=""ord"" type=""hidden"" value="""
					Response.write intContactId
					Response.write """>" & vbcrlf & "                                                <input name=""pord"" id=""pord"" type=""hidden"" value="""
					Response.write CurrBookID
					Response.write """>" & vbcrlf & "                                        </form>" & vbcrlf & "                                 <tr >" & vbcrlf & "                                           <td height=""25""><div align=""center""></div></td>" & vbcrlf & "                                             <td colspan=""10""><div align=""right""><a href=""javascript:void(0)"" onClick=""javascript:window.open('../contractth/ReturnDetail.asp?page_count=20&page=1&pord=' + document.getElementById('pord').value + '&ord=' + document.getElementById('ord').value,'ReturnDetailNewWin','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');""><font class=""red"">查看更多退货明细..&gt;&gt;&gt;</font></a></div></td>" & vbcrlf & "                                       </tr>" & vbcrlf & "                   "
				end if
			end if
			rsthPro.close
			set rsthPro = nothing
			Response.write "" & vbcrlf & "     </table>" & vbcrlf & "        </div></td></tr>" & vbcrlf & ""
		end if
	end if
	if ZBRuntime.MC(9000) then
		if open_42_1=3 or open_42_1=1 then
			if open_42_1=1 then
				str_sh=" and cateid in ("&intro_42_1&") "
			end if
			Response.write "" & vbcrlf & "<tr class=""top accordion"">" & vbcrlf & "<td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "<div  class=""accordion-bar-tit"">" & vbcrlf & "  关联售后<span class=""accordion-arrow-down""></span>" & vbcrlf & "</div>" & vbcrlf & "</td>" & vbcrlf & "</tr>" & vbcrlf & "<tr><td colspan=""6""><div style=""width:100%;overflow-x:auto"">" & vbcrlf & "              <table width=""100%"" border=""0"" cellpadding=""3"" id=""content"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;"">" & vbcrlf & "          "
			str_sh=" and cateid in ("&intro_42_1&") "
			set rs2=server.CreateObject("adodb.recordset")
			sql2="select ord,title,company,cateid,date1,result1,great1,date7 from tousu where del=1 and product="&ord&" "&str_sh&" order by date7 desc,ord desc"
			rs2.open sql2,conn,1,1
			if rs2.eof then
				Response.write "<tr><td colspan='5' height='27'><div align='center'>没有信息!</div></td></tr>"
			else
				Response.write "" & vbcrlf & "                     <tr class=""top"">" & vbcrlf & "                          <td width=""13%"" height=""27""><div align=""center"">售后日期</div></td>" & vbcrlf & "                           <td><div align=""center"">售后主题</div></td>" & vbcrlf & "                               <td width=""13%"" class=""name""><div align=""center"">紧急程度</div></td>" & vbcrlf & "                          <td width=""13%"" class=""name""><div align=""center"">处理结果</div></td>" & vbcrlf & "                             <td width=""18%"" class=""name""><div align=""center"">关联客户</div></td>" & vbcrlf & "                  </tr>" & vbcrlf & "                   "
				k_sh=1
				do while not rs2.eof
					if rs2("great1")<>"" and not isnull(rs2("great1")) then
						set rs7=conn.execute("select sort1 from sortonehy where ord="&rs2("great1")&" ")
						if not rs7.eof then
							great1=rs7(0).value
						else
							great1=""
						end if
						set rs7=nothing
					else
						great1=""
					end if
					if Len(rs2("company")&"")>0 Then
						set rs8=conn.execute("select ord,name,cateid, sort3,ISNULL(share,'-222') share from tel where del=1 and ord="&rs2("company")&"")
'if Len(rs2("company")&"")>0 Then
						if not rs8.eof then
							company_sell=rs8(0).value
							companyname_sell=rs8(1).value
							cateid_kh=rs8(2).value
							company_sort3 = rs8(3).value
							company_share = rs8(4).value
						else
							company_sell=0
							companyname_sell=""
							cateid_kh=-1
							companyname_sell=""
							company_sort3 = "1"
							company_share = ""
						end if
						set rs8=Nothing
					end if
					Response.write "" & vbcrlf & "             <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td height=""27""><div align=""center"">"
					Response.write rs2("date1")
					Response.write "</div></td>" & vbcrlf & "                  <td><div align=""left"">"
					if open_42_14=3 or (open_42_14=1 and CheckPurview(intro_42_14,trim(rs2("cateid")))=True) then
						Response.write "<a href=""###"" onClick=""javascript:window.open('../service/content.asp?ord="
						Response.write pwurl(rs2("ord"))
						Response.write "','newwinssh','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');return false;"">"
						'Response.write pwurl(rs2("ord"))
					end if
					Response.write rs2("title")
					Response.write "</a>&nbsp;</div></td>" & vbcrlf & "                        <td class=""name""><div align=""center"">"
					Response.write great1
					Response.write "</div></td>" & vbcrlf & "                  <td class=""name""><div align=""center"">"
					if rs2("result1")=0 then
						Response.write "处理中"
					elseif rs2("result1")=1 then
						Response.write "处理完毕"
					end if
					Response.write "</div></td>" & vbcrlf & "                  <td class=""name""><div align=""left"">"
					if Len(rs2("company")&"")>0 Then
						If company_sort3 ="2" Then
							If open_26_1 = 3 Or (open_26_1 = 1 And CheckPurview(intro_26_1,trim(cateid_kh))=True) Then
								if open_26_14=3 or CheckPurview(intro_26_14,trim(cateid_kh))=True then
									Response.write "" & vbcrlf & "                                                     <a href=""javascript:;"" onclick=""javascript:window.open('../work2/content.asp?ord="
									Response.write pwurl(company_sell)
									Response.write "','new53win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看供应商详情"">"
									'Response.write pwurl(company_sell)
									Response.write companyname_sell
									Response.write "</a>" & vbcrlf & "                                    "
								else
									Response.write""&companyname_sell&""
								end if
							end if
						else
							If open_1_1 = 3 Or (open_1_1 = 1 And CheckPurview(intro_1_1,trim(cateid_kh))=True) Or InStr(1,","&company_share&",", ","&sdk.info.user&",",1) > 0 Or company_share = "1" Then
								if open_1_14=3 or CheckPurview(intro_1_14,trim(cateid_kh))=True then
									Response.write "" & vbcrlf & "                                                     <a href=""javascript:;"" onclick=""javascript:window.open('../work/content.asp?ord="
									Response.write pwurl(company_sell)
									Response.write "','new53win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看客户详情"">"
									'Response.write pwurl(company_sell)
									Response.write companyname_sell
									Response.write "</a>" & vbcrlf & "                                    "
								else
									Response.write""&companyname_sell&""
								end if
							end if
						end if
					end if
					Response.write "&nbsp;</div></td>" & vbcrlf & "            </tr>" & vbcrlf & ""
					k_sh=k_sh+1
					Response.write "&nbsp;</div></td>" & vbcrlf & "            </tr>" & vbcrlf & ""
					rs2.movenext
					if k_sh>3 then exit do
				loop
				if k_sh>3 then
					Response.write "" & vbcrlf & "                             <tr>" & vbcrlf & "                                    <td><div align=""center"">&nbsp;</div></td>" & vbcrlf & "                                 <td colspan=""4"" class=""name""><div align=""right""><a href=""###"" onClick=""javascript:window.open('../service/event.asp?product_sh="
					Response.write ord
					Response.write "','newwins3d3','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');return false;""><font class=""red"">查看更多售后信息..&gt;&gt;&gt;</font></a></div></td>" & vbcrlf & "                             </tr>" & vbcrlf & "                           "
					Response.write ord
				end if
			end if
			rs2.close
			set rs2=nothing
			Response.write "" & vbcrlf & "             </table>" & vbcrlf & "                </div></td></tr>" & vbcrlf & "                "
		end if
	end if
	if ZBRuntime.MC(15000) then
		if open_22_1=3 or open_22_1=1 then
			if open_22_1=1 then
				str_cg=" and b.cateid in ("&intro_22_1&") "
			end if
			Response.write "" & vbcrlf & "<tr class=""top accordion"">" & vbcrlf & "<td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "<div  class=""accordion-bar-tit"">" & vbcrlf & "  采购明细<span class=""accordion-arrow-down""></span>" & vbcrlf & "</div>" & vbcrlf & "</td>" & vbcrlf & "</tr>" & vbcrlf & "<tr><td colspan=""6""><div style=""width:100%;overflow-x:auto"">" & vbcrlf & "              <table width=""100%""  border=""0"" cellpadding=""3"" id=""content"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;"">" & vbcrlf & " "
			str_cg=" and b.cateid in ("&intro_22_1&") "
			set rs2=server.CreateObject("adodb.recordset")
			sql2="select a.priceAfterTax price1,a.money1,a.num1,a.dateadd,a.bz,b.company,a.unit,b.cateid,a.caigou,b.date3 from caigoulist a with(nolock) inner join caigou b with(nolock) on a.caigou=b.ord and a.ord="&ord&" "&str_cg&" and a.del=1 and b.del=1 order by a.dateadd desc"
			rs2.open sql2,conn,1,1
			if rs2.eof then
				Response.write "<tr><td "
				if setbz="1" then
					Response.write "colspan='8' "
				else
					Response.write "colspan='7' "
				end if
				Response.write " height='27'><div align='center'>没有信息!</div></td></tr>"
			else
				Response.write "" & vbcrlf & "                     <tr class=""top"" onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                         <td width=""10%"" height=""27""><div align=""center"">采购日期</div></td>" & vbcrlf & "                           <td><div align=""center"">供应商名称</div></td>" & vbcrlf & "     <td width=""8%"" class=""name""><div align=""center"">单位</div></td>" & vbcrlf & "                               "
				if setbz="1" then
					Response.write "<td width=""8%"" class=""name""><div align=""center"">币种</div></td>"
				end if
				Response.write "" & vbcrlf & "                             <td width=""8%"" class=""name""><div align=""center"">采购数量</div></td>" & vbcrlf & "                           <td width=""12%"" class=""name""><div align=""center"">采购含税单价</div></td>" & vbcrlf & "                              <td width=""15%"" class=""name""><div align=""center"">总金额</div></td>" & vbcrlf & "                            <td width=""15%"" class=""name""><div align=""center"">关联采购</div></td>" & vbcrlf & "                    </tr>" & vbcrlf & "                   "
				dim price1_cg,num1_cg,bz_cg,date1_cg,company_cg,moneyall_cg,unit_cg,k_cg
				price1_cg=0
				num1_cg=0
				bz_cg=""
				date1_cg=""
				company_cg=0
				companyname_cg=0
				unit_cg=0
				k_cg=0
				do until rs2.eof
					k_cg=k_cg+1
'do until rs2.eof
					if k_cg>3 then exit do
					if rs2("price1")<>"" then
						price1_cg=zbcdbl(rs2("price1"))
					else
						price1_cg=0.00
					end if
					if rs2("num1")<>"" then
						num1_cg=zbcdbl(rs2("num1"))
					else
						num1_cg=0
					end if
					bz_cg=rs2("bz")
					date1_cg=rs2("date3")
					company_cg=rs2("company")
					unit_cg=rs2("unit")
					caigou_cg=rs2("caigou")
					if price1_cg="" then price1_cg=0
					if num1_cg="" then num1_cg=0
					if unit_cg="" then unit_cg=0
					if bz_cg="" then bz_cg=0
					moneyall_cg=cdbl(rs2("money1"))
					if setbz="1" then
						if bz_cg<>"" and  bz_cg<>"0" then
							set rs=server.CreateObject("adodb.recordset")
							sql="select intro from sortbz where id="&bz_cg&" "
							rs.open sql,conn,1,1
							if rs.eof then
								bzname_cg=""
							else
								bzname_cg=rs("intro")
							end if
							rs.close
							set rs=nothing
						end if
					end if
					if Len(caigou_cg&"")>0 then
						set rs7=server.CreateObject("adodb.recordset")
						sql7="select title from caigou where ord="&caigou_cg&""
						rs7.open sql7,conn,1,1
						if rs7.eof then
							caigouname_cg="关联采购单已被删除"
						else
							caigouname_cg=rs7("title")
						end if
						rs7.close
						set rs7=nothing
					else
						caigouname_cg=""
					end if
					If Len(unit_cg&"")>0 then
						set rs7=server.CreateObject("adodb.recordset")
						sql7="select sort1 from sortonehy where id="&unit_cg&""
						rs7.open sql7,conn,1,1
						if rs7.eof then
							unitname_cg=""
						else
							unitname_cg=rs7("sort1")
						end if
						rs7.close
						set rs7=Nothing
					else
						unitname_cg=""
					end if
					If Len(company_cg&"")>0 then
						set rs8=conn.execute("select ord,name,cateid, sort3,ISNULL(share,'-222') share from tel where del=1 and ord="& company_cg &"")
'If Len(company_cg&"")>0 then
						if not rs8.eof then
							company_sell=rs8(0).value
							gysname1=rs8(1).value
							cateid_kh=rs8(2).value
							company_sort3 = rs8(3).value
							company_share = rs8(4).value
						else
							company_sell=0
							gysname1="已被删除"
							cateid_kh=-1
							gysname1="已被删除"
							company_sort3 = "1"
							company_share = ""
						end if
						set rs8=Nothing
					else
						gysname1=""
					end if
					if Len(bz_cg&"")>0 then
						set rs7=server.CreateObject("adodb.recordset")
						sql7="select sort1 from sortbz where id="&bz_cg&""
						rs7.open sql7,conn,1,1
						if rs7.eof then
							bzname_cg=""
						else
							bzname_cg=rs7("sort1")
						end if
						rs7.close
						set rs7=nothing
					end if
					Response.write "" & vbcrlf & "                      <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td height=""27"">" & vbcrlf & "                  <div align=""center"">"
					Response.write date1_cg
					Response.write "</div></td>" & vbcrlf & "                   <td>"
					if Len(company_cg&"")>0 Then
						If company_sort3 ="2" Then
							If open_26_1 = 3 Or (open_26_1 = 1 And CheckPurview(intro_26_1,trim(cateid_kh))=True) Then
								if open_26_14=3 or CheckPurview(intro_26_14,trim(cateid_kh))=True then
									Response.write "" & vbcrlf & "                                                      <a href=""javascript:;"" onclick=""javascript:window.open('../work2/content.asp?ord="
									Response.write pwurl(company_sell)
									Response.write "','new53win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看供应商详情"">"
									'Response.write pwurl(company_sell)
									Response.write gysname1
									Response.write "</a>" & vbcrlf & "                                     "
								else
									Response.write""&gysname1&""
								end if
							end if
						else
							If open_1_1 = 3 Or (open_1_1 = 1 And CheckPurview(intro_1_1,trim(cateid_kh))=True) Or InStr(1,","&company_share&",", ","&sdk.info.user&",",1) > 0 Or company_share = "1" Then
								if open_1_14=3 or CheckPurview(intro_1_14,trim(cateid_kh))=True then
									Response.write "" & vbcrlf & "                                                      <a href=""javascript:;"" onclick=""javascript:window.open('../work/content.asp?ord="
									Response.write pwurl(company_sell)
									Response.write "','new53win','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看客户详情"">"
									'Response.write pwurl(company_sell)
									Response.write gysname1
									Response.write "</a>" & vbcrlf & "                                     "
								else
									Response.write""&gysname1&""
								end if
							end if
						end if
					end if
					if num1_cg&""="" then num1_cg = 0
					Response.write "" & vbcrlf & "                      </td>" & vbcrlf & "                   <td><div align=""center"">"
					Response.write unitname_cg
					Response.write "</div></td>" & vbcrlf & "                   "
					if setbz="1" then
						Response.write "<td><div align=""center"">"
						Response.write bzname_cg
						Response.write "</div></td>"
					end if
					Response.write "" & vbcrlf & "                      <td><div align=""center"">"
					Response.write Formatnumber(num1_cg,num1_dot,-1)
					Response.write "" & vbcrlf & "                      <td><div align=""center"">"
					Response.write "</div></td>" & vbcrlf & "                   "
					if open_22_21<>0 then
						if price1_cg&""="" then price1_cg = 0
						if moneyall_cg&""="" then moneyall_cg = 0
						Response.write "" & vbcrlf & "                              <td height=""20""><div align=""right"">"
						Response.write Formatnumber(price1_cg,StorePrice_dot_num,-1)
						Response.write "" & vbcrlf & "                              <td height=""20""><div align=""right"">"
						Response.write "</div></td>" & vbcrlf & "                          <td height=""20""><div align=""right"">"
						Response.write Formatnumber(moneyall_cg,num_dot_xs,-1)
						Response.write "</div></td>" & vbcrlf & "                          <td height=""20""><div align=""right"">"
						Response.write "</div></td>" & vbcrlf & "                  "
					else
						Response.write "" & vbcrlf & "                             <td height=""20""><div align=""right"">&nbsp;</div></td>" & vbcrlf & "                                <td height=""20""><div align=""right"">&nbsp;</div></td>" & vbcrlf & "                        "
					end if
					Response.write "" & vbcrlf & "                     <td><div align=""center"">"
					if open_22_14=3 or (open_22_14=1 and CheckPurview(intro_22_14,trim(rs2("cateid")))=True) then
						Response.write "<a href=""javascript:;"" onClick=""javascript:window.open('../../SYSN/view/store/caigou/caigoudetails.ashx?view=details&ord="
						Response.write pwurl(caigou_cg)
						Response.write "','caigouconn','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">"
						'Response.write pwurl(caigou_cg)
					end if
					Response.write caigouname_cg
					Response.write "</a></div></td>" & vbcrlf & "                      </tr>" & vbcrlf & "                   "
					rs2.movenext
				loop
				if k_cg>3 then
					Response.write "" & vbcrlf & "                             <tr >" & vbcrlf & "                                   <td height=""25""><div align=""center""></div></td>" & vbcrlf & "                                     <td colspan=""9""><div align=""right""><a href=""javascript:;"" onClick=""javascript:window.open('../../SYSN/view/sales/product/productPurchase.ashx?sort=0&product="
					Response.write pwurl(CurrBookID)
					Response.write "','newwins3d3','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');return false;""><font class=""red"">查看更多采购明细..&gt;&gt;&gt;</font></a></div></td>" & vbcrlf & "                             </tr>" & vbcrlf & "                           "
					'Response.write pwurl(CurrBookID)
				end if
			end if
			rs2.close
			set rs2 = nothing
			Response.write "" & vbcrlf & "             </table>" & vbcrlf & "                </div></td></tr>" & vbcrlf & "                "
		end if
	end if
	if ZBRuntime.MC(17000) then
		Response.write "" & vbcrlf & "<tr class=""top accordion"">" & vbcrlf & "<td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "<div  class=""accordion-bar-tit"">" & vbcrlf & "  库存情况<span class=""accordion-arrow-down""></span>" & vbcrlf & "</div>" & vbcrlf & "</td>" & vbcrlf & "</tr>" & vbcrlf & "<tr><td colspan=""6""><div style=""width:100%;overflow-x:auto"">" & vbcrlf & "      <table width=""100%""  border=""0"" cellpadding=""3"" id=""content"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;"">" & vbcrlf & "         <tr class=""top"">" & vbcrlf & "                  <td width=""8%"" ><div align=""center"">仓库名称</div></td>" & vbcrlf & "                        <td ><div align=""center"">单位</div></td>" & vbcrlf & "                  <td ><div align=""center"">数量</div></td>" & vbcrlf & "                  <td ><div align=""center"">成本</div></td>" & vbcrlf & "                  <td width=""7%"" ><div align=""center"">批号<a></div></td>" & vbcrlf & "                      <td width=""7%"" ><div align=""center"">序列号</div></td>" & vbcrlf & "                        <td width=""8%"" ><div align=""center"">生产日期</div></td>" & vbcrlf & "                     <td width=""8%"" ><div align=""center"">有效日期</div></td>" & vbcrlf & "                     <td width=""6%"" ><div align=""center"">包装</div></td>" & vbcrlf & "                 <td width=""9%"" ><div align=""center"">供应商</div></td>" & vbcrlf & "         </tr>" & vbcrlf & ""
		dim n,k,type1,id,unit,ck,ck1name,ckname,num1
		n=0
		set rs=server.CreateObject("adodb.recordset")
		sql="select top 3 a.ord,a.unit,a.ck,isnull(a.num1,0) as num1,(isnull(a.num2,0)+isnull(a.locknum,0)) as num2,isnull(a.FinaMoney,0) as money1,a.ph,a.datesc,a.dateyx,a.bz,isnull(a.gys,0) as gys, "& vbCrLf &_
		"case when not exists(select 1 from S2_SerialNumberRelation with(nolock) where Billtype = 61001 and listid = b.id) then a.xlh" & vbCrLf &_
		"  else stuff((SELECT ','+cast(nl.serinum  as varchar(20)) FROM  S2_SerialNumberRelation s2 with(nolock) inner join M2_SerialNumberList nl with(nolock) on nl.id = s2.serialID where s2.Billtype = 61001 and s2.listid = b.id FOR XML PATH('')) , 1,1 , '' ) end xlh "& vbCrLf &_
		" from ku a "& vbCrLf &_
		" left join kuinlist b on a.kuinlist = b.id and a.ord = b.ord and a.unit = b.unit "& vbCrLf &_
		" left join kuin c on c.ord = b.kuin "& vbCrLf &_
		"    "" where a.ord="&ord&" and a.ck in (select ord from sortck where intro like '"&session("personzbintel2007")&",%' or intro like '%,"&session("personzbintel2007")&",%' or intro like '%, "&session("personzbintel2007")&",%' or intro like '%, "&session("personzbintel2007")&"'  or intro like '%,"&session("personzbintel2007")&"' or intro like '"&session("personzbintel2007")&"' or intro like '0"&_
		" and isnull(a.num2,0)<>0 order by a.ord desc ,a.unit desc ,a.ck desc "
		rs.open sql,conn,1,1
		if rs.RecordCount<=0 then
			Response.write "<tr><td height='27' colspan='10'><div align='center'>没有信息!</div></td></tr>"
		else
			n_kc=0
			cateid=0
			do until rs.eof
				unit=rs("unit")
				ck=rs("ck")
				num1=cdbl(rs("num1"))
				num2=cdbl(rs("num2"))
				money1=zbcdbl(rs("money1"))
				if money1&""="" then money1=0 Else money1=CDbl(money1)
				if num1<>0 then
					money1=Formatnumber(money1,num_dot_xs,-1)
'if num1<>0 then
				else
					money1=0
				end if
				ph=rs("ph")
				xlh=rs("xlh")
				datesc=rs("datesc")
				dateyx=rs("dateyx")
				bz=rs("bz")
				gys=rs("gys")
				if Len(unit&"")=0 then unit=0
				if Len(ck&"")=0 then ck=0
				if bz="" then bz=0
				if isnull(bz) then bz=0
				if Len(gys&"")=0 then gys=0
				set rs7=server.CreateObject("adodb.recordset")
				sql7="select sort1 from sortonehy where id="&unit&""
				rs7.open sql7,conn,1,1
				if rs7.eof then
					unitname=""
				else
					unitname=rs7("sort1")
				end if
				rs7.close
				set rs7=nothing
				set rs7=server.CreateObject("adodb.recordset")
				sql7="select sort1 from sortonehy where id="&bz&""
				rs7.open sql7,conn,1,1
				if rs7.eof then
					bzname=""
				else
					bzname=rs7("sort1")
				end if
				rs7.close
				set rs7=nothing
				gysname1=""
				if gys<>"" then
					set rs7=server.CreateObject("adodb.recordset")
					sql7="select name,cateid from tel "&Str_Result1&"and ord="&gys&" "
					rs7.open sql7,conn,1,1
					if rs7.eof then
						gysname1=""
						cateid = 0
					else
						cateid=rs7("cateid")
						gysname1=rs7("name")
					end if
					rs7.close
					set rs7=nothing
				end if
				set rs7=server.CreateObject("adodb.recordset")
				sql7="select sort1,sort from sortck where ord="&ck&""
				rs7.open sql7,conn,1,1
				if rs7.eof then
					ckname=""
					ck1name=""
				else
					ckname=rs7("sort1")
					storeSort=""
					sql="select id,ParentID,sort1 from sortck1 where id="&rs7("sort")
					set rssort=conn.execute(sql)
					if not rssort.eof then
						storeSort=rssort("sort1")
						set rstmp=conn.execute("select id,ParentID,sort1 from sortck1 where id="&rssort("ParentID"))
						do while not rstmp.eof
							tmpid=rstmp("id").value
							tmpParent=rstmp("ParentID").value
							storeSort=rstmp("sort1")&"-"&storeSort
							tmpParent=rstmp("ParentID").value
							rstmp.close
							set rstmp=conn.execute("select id,ParentID,sort1 from sortck1 where id="&tmpParent)
						loop
						rstmp.close
						set rstmp=nothing
					end if
					ck1name=storeSort&"-"&ckname
					set rstmp=nothing
					rssort.close
					set rssort=nothing
				end if
				rs7.close
				set rs7=Nothing
				Response.write "" & vbcrlf & "             <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td><div align=""center"">"
				Response.write ck1name
				Response.write "</div></td>" & vbcrlf & "                  <td width=""5%"" height=""27""><div align=""center"">"
				Response.write unitname
				Response.write "</div></td>" & vbcrlf & "                  <td width=""7%"" height=""27""><div align=""center"">"
				Response.write Formatnumber(num2,num1_dot,-1)
				Response.write "</div></td>" & vbcrlf & "                  <td width=""8%"" height=""27""><div align=""right"">"
				if open_23_2=1 then
					Response.write Formatnumber(money1,num_dot_xs,-1)
'if open_23_2=1 then
				end if
				Response.write "</div></td>" & vbcrlf & "                  <td><div align=""center"">"
				Response.write ph
				Response.write "</div></td>" & vbcrlf & "                  <td><div align=""center"">"
				Response.write xlh
				Response.write "</div></td>" & vbcrlf & "                  <td><div align=""center"">"
				Response.write datesc
				Response.write "</div></td>" & vbcrlf & "                  <td><div align=""center"">"
				Response.write dateyx
				Response.write "</div></td>" & vbcrlf & "                  <td><div align=""center"">"
				Response.write bzname
				Response.write "</div></td>" & vbcrlf & "                  <td>" & vbcrlf & "                            <div align=""center"">" & vbcrlf & "              "
				if open_26_14=3 or (open_26_14=1 and CheckPurview(intro_26_14,trim(cateid))=True) then
					Response.write "" & vbcrlf & "                             <a href=""javascript:;"" onClick=""javascript:window.open('../work2/content.asp?ord="
					Response.write pwurl(gys)
					Response.write "&unit="
					Response.write unit
					Response.write "&ck="
					Response.write ck
					Response.write "','contrractcon','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">"
					Response.write ck
					Response.write gysname1
					Response.write "</a>" & vbcrlf & "         "
				else
					Response.write gysname1
				end if
				Response.write "" & vbcrlf & "                             </div>" & vbcrlf & "                  </td>" & vbcrlf & "           </tr>" & vbcrlf & "           "
				n_kc=n_kc+1
				If n_kc>2 Then Exit Do
				rs.movenext
			Loop
			if n_kc>2 then
				Response.write "" & vbcrlf & "             <tr >" & vbcrlf & "                   <td height=""25""><div align=""center""></div></td>" & vbcrlf & "                     <td colspan=""9""><div align=""right""><a href=""javascript:;"" onClick=""javascript:window.open('../../SYSN/view/store/inventory/InventoryDetails.ashx?link=yes&ord="
				Response.write pwurl(ord)
				Response.write "','newwins3d3','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');return false;""><font class=""red"">查看更多库存明细..&gt;&gt;&gt;</font></a></div></td>" & vbcrlf & "             </tr>" & vbcrlf & "   "
				'Response.write pwurl(ord)
			end if
		end if
		rs.close
		set rs = nothing
		Response.write "" & vbcrlf & "     </table>" & vbcrlf & "        </div></td></tr>" & vbcrlf & ""
	end if
	if ZBRuntime.MC(18002) then
		Response.write "" & vbcrlf & "<tr class=""top accordion"">" & vbcrlf & "<td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "<div  class=""accordion-bar-tit"">" & vbcrlf & "  物料清单<span class=""accordion-arrow-down""></span>" & vbcrlf & "</div>" & vbcrlf & "</td>" & vbcrlf & "</tr>" & vbcrlf & "<tr><td colspan=""6""><div style=""width:100%;overflow-x:auto"">" & vbcrlf & "      <table width=""100%""  border=""0"" cellpadding=""3"" id=""content"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;"">" & vbcrlf & "         <tr class=""top"">" & vbcrlf & "                  <td ><div align=""center"">清单主题</div></td>" & vbcrlf & "                   <td ><div align=""center"">清单编号</div></td>" & vbcrlf & "                      <td ><div align=""center"">审批状态</div></td>" & vbcrlf & "                      <td ><div align=""center"">操作</div></td>" & vbcrlf & "          </tr>" & vbcrlf & ""
		n=0
		set rs=server.CreateObject("adodb.recordset")
		sql = "select a.id,a.title,a.bombh,"&_
		"          (case status when -1 then '无需审批' when 1 then '审批通过' when 2 then '审批退回' "&_
		"when 4 then '待审批' when 5 then '审批中' else '"&_
		"          (case when p2.qx_open=3 or (p2.qx_open=1 and charindex(','+cast(a.Creator as varchar(10))+',',','+cast(p2.qx_intro as varchar(8000))+',' )>0)                   then 1 else 0 end) as canDetail " &_
		"          when 4 then '待审批' when 5 then '审批中' else '' end ) as spstatus,"&_
		"  from M2_BOM a " &_
		"  inner join ("&_
		"          select distinct b.id from M2_BOMList l "&_
		"          inner join M2_BOM b on b.id = l.BOM and b.del=1 and b.status<>0 where l.ProductID=" & ord &_
		"  ) c on c.id = a.id " &_
		"  inner join power p on p.ord="&session("personzbintel2007")&" and p.sort1=56 and p.sort2=1 " &_
		"  left join power p2 on p2.ord="&session("personzbintel2007")&" and p2.sort1=56 and p2.sort2=14 " &_
		"  where p.qx_open=3 or (p.qx_open=1 and charindex(','+cast(a.Creator as varchar(10))+',',','+cast(p.qx_intro as varchar(8000))+',' )>0)"&_
		"  left join power p2 on p2.ord="&session("personzbintel2007")&" and p2.sort1=56 and p2.sort2=14 " &_
		"  order by a.indate desc "
		rs.open sql,conn,1,1
		if rs.RecordCount<=0 then
			Response.write "<tr><td height='27' colspan='4'><div align='center'>没有信息!</div></td></tr>"
		else
			n_kc=0
			do until rs.eof
				Response.write "" & vbcrlf & "             <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td><div align=""left"">"
				Response.write rs("title")
				Response.write "</div></td>" & vbcrlf & "                  <td height=""27""><div align=""center"">"
				Response.write rs("bombh")
				Response.write "</div></td>" & vbcrlf & "                  <td height=""27""><div align=""center"">"
				Response.write rs("spstatus")
				Response.write "</div></td>" & vbcrlf & "                  <td>" & vbcrlf & "                            <div align=""center"">" & vbcrlf & "                              "
				if rs("canDetail")&""="1" then
					Response.write "" & vbcrlf & "                                     <a href=""javascript:;"" onClick=""javascript:window.open('../../sysn/view/produceV2/BOM/BOMAdd.ashx?ord="
					Response.write rs("id")
					Response.write "&view=details','bomdetail','width=' + 1000 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">详情</a>" & vbcrlf & "                                    "
					Response.write rs("id")
				end if
				Response.write "" & vbcrlf & "                             </div>" & vbcrlf & "                  </td>" & vbcrlf & "           </tr>" & vbcrlf & "           "
				n_kc=n_kc+1
				If n_kc>2 Then Exit Do
				rs.movenext
			Loop
			if n_kc>2 then
				Response.write "" & vbcrlf & "             <tr >" & vbcrlf & "                   <td height=""25""><div align=""center""></div></td>" & vbcrlf & "                     <td colspan=""9""><div align=""right""><a href=""javascript:;"" onClick=""javascript:window.open('../../SYSN/view/produceV2/BOM/BOMList.ashx?fromType=productdetail&productid="
				Response.write pwurl(ord)
				Response.write "','bomdetail3d3','width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');return false;""><font class=""red"">查看更多物料清单..&gt;&gt;&gt;</font></a></div></td>" & vbcrlf & "          </tr>" & vbcrlf & "   "
				'Response.write pwurl(ord)
			end if
		end if
		rs.close
		set rs = nothing
		Response.write "" & vbcrlf & "     </table>" & vbcrlf & "        </div></td></tr>" & vbcrlf & ""
	end if
	Response.write "" & vbcrlf & "     </table>" & vbcrlf & "        <table width=""100%"" border=""0"" align=""left"">" & vbcrlf & "          <tr>" & vbcrlf & "                    <td height=""30"" class=""page""> <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "               <tr>" & vbcrlf & "                    <td height=""30"" ><div align=""center""></div></td>" & vbcrlf & "               </tr>" & vbcrlf & "   </table>" & vbcrlf & ""
	if ZBRuntime.MC(18000) then
		Response.write "" & vbcrlf & "<div id=""hcdiv"" style=""position:absolute;display:none;"">" & vbcrlf & "<form name=""formMRP"" id=""formMRP"" onSubmit=""return false;"">" & vbcrlf & "    <span style=""background:#efeded"" id=""showhc""></span>" & vbcrlf & "</form>" & vbcrlf & "</div>" & vbcrlf & ""
	end if
	Function getTCFormula(sort1, sort2, cpord, num_tc)
		Dim rs, num1, money1, money2, formula1, formula2, tempStr, sort1Str
		tempStr = "" : sort1Str = ""
		Select Case sort1
		Case 1 : sort1Str = "按照销售额计算提成："
		Case 3 : sort1Str = "按照毛利计算提成："
		Case 5 : sort1Str = "按照产品实际销售价提成："
		End Select
		Select Case sort2
		Case 1
		Set rs = conn.execute("select isnull(num1,0) num1 from tcbl where sort1 = "& sort2 &" and isnull(ord,0)="& cpord &"")
		If rs.eof = False Then
			tempStr = "<span class='reseetTextColor' style='color:#2f496e'>"& sort1Str & "</span>" & FormatNumber(CDbl(rs("num1")),num_dot_xs,True) &"%"
		end if
		rs.close
		set rs = nothing
		Case 2, 4
		Set rs = conn.execute("select isnull(num1,0) num1, isnull(money1,0) money1, isnull(money2,0) money2, isnull(tc_formula1,'') formula1, isnull(tc_formula2,'') formula2 from tcbl where sort1 = "& sort2 &" and isnull(ord,0)="& cpord &" order by gate1")
		If rs.eof = False Then
			tempStr = tempStr & "<table class='formulaTab' border=0 cellpadding=3 cellspacing=0>"
			tempStr = tempStr & "<tr><td colspan=2 height=20 class='name'>"& sort1Str &"</td></tr>"
			While rs.eof = False
				num1 = FormatNumber(CDbl(rs("num1")),num_dot_xs,True) &"%"
				money1 = FormatNumber(CDbl(rs("money1")),num_dot_xs,True)
				money2 = FormatNumber(CDbl(rs("money2")),num_dot_xs,True)
				formula1 = rs("formula1") : formula2 = rs("formula2")
				tempStr = tempStr & "<tr>"
				If sort2 = 2 Then
					tempStr = tempStr & "<td class='td1'>自 " & money1 &" 至 "& money2 &"</td><td class='td2'>"& num1 &"</td>"
				ElseIf sort2 = 4 Then
					tempStr = tempStr & "<td class='td1'>自 " & formula1 &" 至 "& formula2 &"</td><td class='td2'>"& num1 &"</td>"
				end if
				tempStr = tempStr & "</tr>"
				rs.movenext
			wend
			tempStr = tempStr & "</table>"
		end if
		rs.close
		set rs = nothing
		Case 3 : tempStr = "<span class='reseetTextColor' style='color:#2f496e'>"& sort1Str & "</span>" & FormatNumber("0"&num_tc,num_dot_xs,True) &"%"
		End Select
		getTCFormula = tempStr
	end function
	action1="产品详情"
	call close_list(1)
	Response.write "" & vbcrlf & "<div id=""ssdiv"" style=""position:absolute;width:500px;height:280px;display:none;background:#FFF"">" & vbcrlf & "<div width=""100%"">" & vbcrlf & " <table width=""100%"" border=""0"" cellpadding=""3"" id=""content"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;"">" & vbcrlf & "<tr class="""">" & vbcrlf & "<td height=""27"" background=""../images/m_table_b.jpg"" style=""padding-left:5px"">" & vbcrlf & "<div style=""float:left""><strong>存放仓库查看</strong></div>" & vbcrlf & "                               <div align=""right"" style=""padding-right:5px""><input type=""button"" value=""关闭"" class=""page"" onClick=""document.getElementById('ssdiv').style.display='none';""></div>" & vbcrlf &                     "</td>" & vbcrlf &            "</tr>" & vbcrlf &    "</table>" & vbcrlf & "</div>" & vbcrlf & "<div id=""sscontentdiv"" style=""width:100%;height:300px;overflow:auto;scrollbar-3dlight-color:#d0d0e8;scrollbar-highlight-color:#fff;scrollbar-face-color:#f0f0ff;scrollbar-arrow-color:#c0c0e8;scrollbar-shadow-color:#d0d0e8;scrollbar-darkshadow-color:#fff;scrollbar-base-color:#ffffff;scrollbar-track-color:#fff;""></div>" & vbcrlf & "</div>" & vbcrlf & "<style>" & vbcrlf & "./*IE5 #content tr.top td{border-right:0!important}*/" & vbcrlf & ".IE5 #content  td tr.top td{border-right:1px solid #CCC!important}" & vbcrlf & "" & vbcrlf & "</style>" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	call close_list(1)
	if request.querystring("showBtn")="1" then
		Response.write  "<script>javascript:kh.style.display='none';</script>"
		Response.end
	end if
	
%>
