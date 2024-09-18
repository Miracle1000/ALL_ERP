<%@ language=VBScript %>
<%
	Response.write vbcrlf
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
		'Response.write sysCurrPath
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

	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_1=0
		intro_10_1=0
	else
		open_10_1=rs1("qx_open")
		intro_10_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_14=0
		intro_10_14=0
	else
		open_10_14=rs1("qx_open")
		intro_10_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_3=0
		intro_10_3=0
	else
		open_10_3=rs1("qx_open")
		intro_10_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_7=0
		intro_10_7=0
	else
		open_10_7=rs1("qx_open")
		intro_10_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_8=0
		intro_10_8=0
	else
		open_10_8=rs1("qx_open")
		intro_10_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_10=0
		intro_10_10=0
	else
		open_10_10=rs1("qx_open")
		intro_10_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_13=0
		intro_10_13 = 0
	else
		open_10_13=rs1("qx_open")
		intro_10_13 = rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=16"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_16=0
		intro_10_16=0
	else
		open_10_16=rs1("qx_open")
		intro_10_16=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	if open_10_1=3 then
		list=""
	elseif open_10_1=1 then
		list="and ord in ("&intro_10_1&")"
		listgz="and id in ("&intro_10_1&")"
	else
		list="and ord=0"
		listgz="and id=0"
	end if
	Str_Result="where del=1 "&list&""
	Str_Result2="and del=1 "&listgz&""
	Str_Result3="and del=1 "&listgz&""
	
	dim open_bz
	set rs=server.CreateObject("adodb.recordset")
	sql="select top 1 bz from setbz "
	rs.open sql,conn,1,1
	if not rs.eof then
		open_bz=rs("bz")
	end if
	rs.close
	set rs=nothing
	Function ChW_sortbz(id,num)
		Dim rs1 ,sql1 ,sort1
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select sort1,intro from sortbz where id="&cint(id)&""
		rs1.open sql1,conn,1,1
		if rs1.eof then
			Response.write "此币种已被删除"
		else
			if num=0 then
				sort1=rs1("sort1")
				sort1=sort1&"("&rs1("intro")&")"
			else
				sort1=rs1("intro")
			end if
			Response.write sort1
		end if
		rs1.close
		set rs1=nothing
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
			GetPowerIntro = r
		end if
		rs.close
		set rs = nothing
	end function
	
	If request("remind") <> "" Then
		Response.write "" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "try{" & vbcrlf & "       jQuery(function(){" & vbcrlf & "              jQuery('form').each(function(){" & vbcrlf & "                 jQuery('<input type=""hidden"" name=""remind"" value="""
		Response.write Request("remind")
		Response.write """/>').appendTo(this);" & vbcrlf & "               });" & vbcrlf & "     });" & vbcrlf & "}catch(e){}" & vbcrlf & "</script>" & vbcrlf & ""
	end if
	ZBRLibDLLNameSN = "ZBRLib3205"
	Function CreateReminderHelper(ByRef cn,cfgId,subCfgId)
		Dim remind
		Set remind = New Reminder
		Set remind.cn = cn
		Call remind.init(cfgId,subCfgId)
		Set CreateReminderHelper = remind
	end function
	Function CreateReminderHelperByRs(ByRef cn,ByRef rs)
		Dim remind
		Set remind = New Reminder
		Set remind.cn = cn
		Call remind.initByRs(rs)
		Set CreateReminderHelperByRs = remind
	end function
	Dim Global_Power
	Sub InitGlobalPower(ByRef cn)
		Dim sql,rs
		sql = "select a.sort1,a.sort2,isnull(b.qx_open,0) qx_open," &_
		"(case when b.qx_intro is null or datalength(b.qx_intro)=0 then '-255' else b.qx_intro end) qx_intro," &_
		"isnull(a.sort,1) qx_type, " &_
		"from qxlblist a  with(nolock) " &_
		"left join power b  with(nolock) on b.sort1=a.sort1 and b.sort2=a.sort2 and b.ord=" & session("personzbintel2007")
		Set rs = cn.execute(sql)
		If rs.eof = False Then
			Global_Power = rs.getRows()
		end if
		rs.close
		Set rs=Nothing
	end sub
	Class Reminder
		Public cn
		Private configId
		Private base64
		Private power
		Private regEx
		Private uid
		Private actDate
		Private m_subCfgId
		Private m_name
		Private m_setjmId
		Private m_mCondition
		Private m_remindMode
		Private m_qxlb
		Private m_listqx
		Private m_detailqx
		Private m_detailOpen
		Private m_detailIntro
		Private m_moreLinkUrl
		Private m_detailLinkUrl
		Private m_moreLinkUrl_mobile
		Private m_detailLinkUrl_mobile
		Private m_hasModule
		Private m_canCancel
		Private m_jointly
		Private m_num1
		Private m_opened
		Private m_gate1
		Private m_tq1
		Private m_fw1
		Private m_canShow
		Private m_remindCount
		Private m_titleMaxLength
		Private m_subSql
		Private m_lastReloadDate
		Private m_MOrderSetting
		Private m_MBusinessType
		Private m_canTQ
		Private m_fwSetting
		Private m_isMobileMode
		Private m_colCount
		Public displaySqlOnCount
		Public displaySqlOnShow
		Public isCleanMode
		Public dateBegin
		Public pageSize
		Public pageIndex
		Public showStatusField
		Private recCount
		Private pageCount
		Private m_existsPowerIntro
		Private m_expiCount
		Private m_UsingPowerCache
		Private m_cacheHelper
		Private m_cacheExpiredCondition
		Private m_usingLv2Cache
		Private m_hasAltField
		Private Function hasAltField(rs)
			If isEmpty(m_hasAltField) Then
				m_hasAltField = hasFieldInRs(rs,"canCancelAlt")
			end if
			hasAltField = m_hasAltField
		end function
		Public Sub setMobileMode
			m_isMobileMode = True
		end sub
		Public Property Get canCancel
		canCancel = m_canCancel
		End Property
		Public Property Get colCount
		colCount = iif(m_isMobileMode,m_colCount,-1)
'Public Property Get colCount
		End Property
		Public Property Get mobileDetailLinkUrl
		mobileDetailLinkUrl = m_detailLinkUrl_mobile
		End Property
		Private m_hasStatField
		Private Function hasStatField(rs)
			If isEmpty(m_hasStatField) Then
				m_hasStatField = hasFieldInRs(rs,"orderStat")
			end if
			hasStatField = m_hasStatField
		end function
		Private m_hasInfoField
		Private Function hasInfoField(rs)
			If isEmpty(m_hasInfoField) Then
				m_hasInfoField = hasInfoField = hasFieldInRs(rs,"otherInfo")
			end if
			hasInfoField = m_hasInfoField
		end function
		Public Property Get numDigit
		numDigit = cn.execute("select num1 from setjm3  with(nolock) where ord=88")(0)
		End Property
		Public Property Get moneyDigit
		moneyDigit = cn.execute("select num1 from setjm3  with(nolock) where ord=1")(0)
		End Property
		Public Property Get hlDigit
		hlDigit = cn.execute("select num1 from setjm3 with(nolock)  where ord=87")(0)
		End Property
		Public Property Get zkDigit
		zkDigit = cn.execute("select num1 from setjm3  with(nolock) where ord=2014053101")(0)
		End Property
		Public Property Get usingLv2Cache
		usingLv2Cache = m_usingLv2Cache
		End Property
		Public Property Let usingLv2Cache(v)
		m_usingLv2Cache = v
		End Property
		Public Property Get subSql
		subSql = m_subSql
		End Property
		Public Property Get lastReloadDate
		lastReloadDate = m_lastReloadDate
		End Property
		Public Property Get subConfigId
		subConfigId = m_subCfgId
		End Property
		Public Property Get moreLink
		moreLink = moreLinkURL()
		End Property
		Public Property Get num1
		num1 = m_num1
		End Property
		Public Property Let num1(v)
		m_num1 = v
		End Property
		Public Property Get gate1
		gate1 = m_gate1
		End Property
		Public Property Get name
		name = m_name
		End Property
		Public Property Get fw1
		fw1 = m_fw1
		End Property
		Public Property Get tq1
		tq1 = m_tq1
		End Property
		Public Property Get canTQ
		canTQ = m_canTQ
		End Property
		Public Property Get fwSetting
		fwSetting = m_fwSetting
		End Property
		Public Property Get setjmId
		setjmId = m_setjmId
		End Property
		Public Property Get canShow
		If isEmpty(m_canShow) Then
			If m_opened = False And isCleanMode <> True Then
				m_canShow = False
			else
				m_canShow = m_hasModule
			end if
		end if
		canShow = m_canShow
		End Property
		Public Property Get isOpened
		isOpened = m_opened
		End Property
		Public Property Get hasModule
		hasModule = m_hasModule
		End Property
		Private Sub class_initialize
			Set base64 = server.createobject(ZBRLibDLLNameSN &".Base64Class")
			Set power = server.createobject(ZBRLibDLLNameSN &".PowerClass")
			power.PowerCache = True
			uid = session("personzbintel2007")
			If uid = "" Then uid = 0
			actDate = session("timezbintel2007")
			If actDate = "" Then actDate = now
			session("timezbintel2007") = actDate
			Set regEx =New RegExp
			regEx.Pattern = "<[^>]+>"
			Set regEx =New RegExp
			regEx.IgnoreCase = True
			regEx.Global = True
			m_subCfgId = 0
			m_subSql = ""
			isCleanMode = False
			dateBegin = IIf(request.querystring("__dt")="",dateadd("m",-3,date),request.querystring("__dt"))
			isCleanMode = False
			pageSize = IIf(request.querystring("__pageSize")="",10,request.querystring("__pageSize"))
			pageIndex = IIf(request.querystring("__pageIndex")="",1,request.querystring("__pageIndex"))
			pageSize = CLng(pageSize)
			pageIndex = CLng(pageIndex)
			recCount = 0
			pageCount = 0
			displaySqlOnCount = False
			displaySqlOnShow = False
			redim m_existsPowerIntro(0)
			If isEmpty(Global_Power) Then
				m_UsingPowerCache = False
			else
				m_UsingPowerCache = True
			end if
			m_usingLv2Cache = False
			showStatusField = True
			m_isMobileMode = False
		end sub
		Public Function listSQL(mode)
			dim ismobile: ismobile= instr(1,mode & "","mobileplus:",1) = 1
			Dim sql,cateCondition,tmpCondition,qOpen,qIntro,fields,orderBy
			Dim withoutCateCondition,cancelCondition,withoutCancelCondition,i,withoutOrderBy,cancelJoinTable
			mode = replace(mode & "", "mobileplus:", "")
			withoutCateCondition = instr(1,mode,"withoutCateCondition",1) > 0
			withoutCancelCondition = instr(1,mode,"withoutCancelCondition",1) > 0
			withoutOrderBy = InStr(1,mode,"withoutOrderBy",1) > 0
			dim icsql : icsql = ""
			if ismobile then
				icsql = "union select cateid, reminderId from reminderPersonsForMobPush  with(nolock) where cateid=" & uid
			end if
			mode = LCase(Split(mode,"_")(0))
			cancelJoinTable = "left join (" & vbcrlf &_
			"select cateid as isCanceled,reminderId from reminderPersons  with(nolock)  where cateid=" & uid & " " & vbcrlf & icsql & vbcrlf &_
			") __rp on __rp.reminderId=a.id " & vbcrlf
			cancelCondition = " and __rp.isCanceled is null "
			Select Case m_setjmId
			Case 1:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"p.cateid")
			sql = "select COUNT(*) REMIND_CNT from plan1 p with(nolock) "&_
			"where complete='1' and option1<>'1' and "&_
			"(startdate1<'" & dateadd("d",m_tq1,date) & "' or "&_
			"(startdate1='" & dateadd("d",m_tq1,date) & "' and "&_
			"(starttime1<'"&hour(time)&"' or starttime1='"&hour(time)&"'and starttime2<'"&minute(time)&"')"&_
			")"&_
			") [CATECONDITION] [ORDERBY]"
			fields = "ord [id],intro title,case when startdate1 is null then convert(varchar(10),date1,21) + ' ' + time1 + ':' + time2 "&_
			"else convert(varchar(10),startdate1,21) + ' ' + starttime1 + ':" &_
			"datediff(s,'&actDate&"
			orderBy = "order by startdate1 desc,date8 desc "
			Case 2:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " and charindex(',"&uid&",',','+alt+',')<=0 "
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) "&_
			" [CANCELJOINTABLE] " & _
			"inner join learntz b on a.orderId=b.ord and b.del=1 " &_
			" where a.reminderConfig=" & configId & " [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "isnull(b.ord,0) [id],isnull(b.title,'【已删除数据】') title,isnull(convert(varchar(19),b.date7,21),'----') dt,"&_
			"datediff(s,' & actDate & ',isnull(b.date7,'2000-01-01"
'where a.reminderConfig= & configId &  [CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by a.id desc"
			Case 4:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.ecateid")
			cateCondition = cateCondition & " and datediff(d,getdate(),b.stime) <= " & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) "&_
			" [CANCELJOINTABLE] " & _
			"inner join importantMsg b on a.orderId=b.id and b.del=1 AND b.metype = "& m_subCfgId &" " &_
			"left join tel c on b.t_ord=c.ord " & vbcrlf &_
			" where c.del=1 and b.state<>2 and a.reminderConfig=" & configId & " [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],isnull(c.name,'【已删除数据】') title,isnull(convert(varchar(19),b.stime,21),'----') dt,"&_
			" where c.del=1 and b.state<>2 and a.reminderConfig=" & configId & " [CATECONDITION] [CANCELCONDITION] [ORDERBY]" &_
			"case when year(b.stime)<year(getdate()) then -1 else datediff(s,'&actDate&"
'where c.del=1 and b.state<>2 and a.reminderConfig= & configId &  [CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by b.stime desc"
			Case 7:
			Dim nowDays : nowDays = datediff("d",CDate(year(date)&"-01-01"),date)
'Case 7:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			if m_fw1&""="0" then
				if qOpen=3 then
					cateCondition=""
				elseif qOpen=1 then
					cateCondition=cateCondition & " and (tl.cateid in ("&qIntro&") "&_
					"or tl.share='1' "&_
					"or charindex(',"&uid&",',','+tl.share+',')>0) "
'or tl.share='1
				else
					cateCondition=cateCondition & " and (tl.share='1' or charindex(',"&uid&",',','+tl.share+',')>0) "
'or tl.share='1
				end if
			else
				cateCondition=cateCondition & " and tl.cateid="&uid&" or (tl.share='1' or charindex(',"&uid&",',','+tl.share+',')>0) "
'or tl.share='1
			end if
			cateCondition=cateCondition & " and bDays - "&nowDays&" >=0 and bDays - "&nowDays&" <= " & m_tq1 & " " & vbcrlf
'or tl.share='1
			sql = """" & vbcrlf &_
			"select COUNT(*) REMIND_CNT " & vbcrlf &_
			"from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join person p  with(nolock) on a.reminderConfig = 7 and a.orderId=p.ord and p.del=1 and p.sort3=1 and p.bDays >= 0 " & vbcrlf &_
			"left join tel tl on tl.ord = p.company " & vbcrlf &_
			"where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "p.ord [id]," & _
			"case when bDays - "&nowDays&" = 0 then p.name+CHAR(11)+CHAR(12)+'今日生日'" & _
			"else p.name+CHAR(11)+CHAR(12)+'还差'+cast(bDays - &nowDays& as varchar)+'天" &_
			"end as title," & _
			"convert(varchar(10),dateadd(d,p.bDays,'"&year(date)&"-01-01'),121)+'@'+cast(p.birthdayType as varchar) dt," & _
			"-1 as newTag,a.id [rid],tl.cateid "
			orderBy = "order by p.bDays asc"""
			Case 9:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"d.cateid")
			cateCondition = cateCondition & " and datediff(d,getdate(),c.date2)<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join caigoulist c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.id and c.del=1 " & vbcrlf &_
			"inner join caigou d  with(nolock) on d.ord=c.caigou " & vbcrlf &_
			"inner join product b  with(nolock) on b.ord=c.ord " & vbcrlf &_
			"where d.del=1 and isnull(d.status,-1) IN (-1,1) and c.alt=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
'inner join product b  with(nolock) on b.ord=c.ord  & vbcrlf &_
			fields = "c.id [id],d.title+'['+b.title+']' title,convert(varchar(10),c.date2,23) dt,datediff(s,'""&actDate&""',a.inDate) newTag,a.id [rid],c.cateid"""
'inner join product b  with(nolock) on b.ord=c.ord  & vbcrlf &_
			orderBy = "order by c.date2 desc,c.date7 desc"""
			Case 11:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"c.cateid")
			cateCondition = cateCondition & " and datediff(d,getdate(),c.date1)<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join payback c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.ord and c.del=1 and c.complete='1' " & vbcrlf &_
			"left join contract ct  with(nolock) on ct.ord=c.contract " & vbcrlf &_
			"left join sortbz bz  with(nolock) on bz.id=ct.bz " & vbcrlf &_
			"where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "c.ord [id],'@code:""'+isnull(bz.intro,'RMB')+' "" & FormatNumber('+CAST(c.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(10),c.date1,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],c.cateid"
'where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by c.date1 desc,c.date7 desc"
			Case 12:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"c.cateid")
			cateCondition = cateCondition & " and datediff(d,getdate(),c.date1)<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join payout c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.ord and c.del=1 and c.complete='1' " & vbcrlf &_
			"left join (select ord,bz,0 cls from caigou union all select ID as ord,14 bz, 2 cls from M_OutOrder union all select ID as ord,bz, (case isnull(wwType,0) when 0 then 5 when 1 then 4 else 2 end) cls from M2_OutOrder  with(nolock) ) ct on ct.ord=c.contract and ct.cls=isnull(c.cls,0) " & vbcrlf &_
			"left join sortbz bz on bz.id=ct.bz " & vbcrlf &_
			"where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "c.ord [id],'@code:""'+isnull(bz.intro,'RMB')+' "" & FormatNumber('+CAST(c.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(10),c.date1,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],c.cateid"
'where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by c.date1 desc,c.date7 desc"
			Case 21:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1&""="0" Then
				If qOpen = 3 Then
					cateCondition = ""
				ElseIf qOpen=1 Then
					cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
					tmpCondition = " and (cateid is not null and cateid<>0)"
				else
					cateCondition = " and 1=2"
				end if
			else
				cateCondition = " and cateid=" & uid
			end if
			cateCondition = " and ("&_
			"(1=1"&cateCondition&") or charindex(',"&uid&",',','+replace(cast(share as varchar(8000)),' ','')+',')>0 or share='1'"&_
			"cateCondition = "" and ("""&_
			") " & tmpCondition & vbcrlf
			cateCondition = cateCondition & " and datediff(d,getdate(),b.date2)<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join contract b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 and isnull(b.status,-1) in (-1,1)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title,convert(varchar(10),b.date2,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date2 desc,b.date7 desc"
			Case 22:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				tmpCondition = ""
			ElseIf qOpen=1 Then
				tmpCondition = " and addcate in ("&qIntro&") "
			else
				tmpCondition = " and 1=2"
			end if
			If m_fw1&""="0" Then
				cateCondition = tmpCondition & " and isnull(catelead,0) > 0 "
			else
				cateCondition = tmpCondition & " and catelead=" & uid
			end if
			sql="select COUNT(*) REMIND_CNT from tousu  with(nolock) where del=1 [CATECONDITION] and result1=0 [ORDERBY]"
			fields = "ord [id],title,date1 dt,datediff(s,'" & actDate & "',isnull(date7,'2000-01-01')) newTag,0 [rid],addcate cateid"
			sql="select COUNT(*) REMIND_CNT from tousu  with(nolock) where del=1 [CATECONDITION] and result1=0 [ORDERBY]"
			orderBy = "order by date1 desc,date7 desc"
			Case 23:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " and datediff(d,getdate(),c.date2)<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join contractlist c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.id and c.del=1 " & vbcrlf &_
			"inner join contract b  with(nolock) on b.ord=c.contract and b.del=1 and isnull(b.status,-1) in (-1,1)  " & vbcrlf &_
			"left join product p  with(nolock) on p.ord=c.ord and p.del=1 " & vbcrlf &_
			"where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "c.id [id],b.title+'['+isnull(p.title,'产品被删除')+']' title,convert(varchar(10),c.date2,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
'where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by c.date2 desc,c.date7 desc"
			Case 39:
			cateCondition = "and learnhd.cateid="&uid
			sql="SELECT COUNT(*) REMIND_CNT FROM replyhd  with(nolock) "&_
			"LEFT JOIN learnhd  with(nolock) ON replyhd.ord = learnhd.ord "&_
			"where learnhd.del=1 and replyhd.alt=1 [CATECONDITION] [ORDERBY]"
			fields = "replyhd.id as [id],learnhd.title as title,replyhd.date7 as dt,-1 newTag,0 [rid],learnhd.cateid as cateid,learnhd.ord as ord"
'where learnhd.del=1 and replyhd.alt=1 [CATECONDITION] [ORDERBY]
			orderBy = "order by replyhd.date7 desc"
			Case 68:
			cateCondition = "and CHARINDEX(',"&uid&",',','+c.RemindPerson+',')>0 " & vbcrlf &_
			"AND daysFromNow <=  & (m_tq1 * 24)"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join ku b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"inner join product c  with(nolock) on c.ord=b.ord " & vbcrlf &_
			"inner join sortck ck  with(nolock) on b.ck=ck.ord and ck.del=1 " &_
			"IIf(withoutCateCondition,"""",""and (cast(ck.intro as varchar(10))='0' "&_
			"or CHARINDEX(',&uid&,',','+cast(ck.intro as varchar(4000))+'," &_
			"IIf(withoutCateCondition,"""",""and (cast(ck.intro as varchar(10))='0' "&_
			"where isnull(b.locked,0)=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],c.title,"&_
			"CONVERT(varchar(10),dateadd(hh,a.daysFromNow,'"&date&"'),23) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],0 cateid"
			orderBy = "ORDER BY dt DESC,id DESC"
			Case 74:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and creator in ("&qIntro&") "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & " AND cateid=" & uid
			sql="SELECT COUNT(*) REMIND_CNT FROM sale_proposal  with(nolock) WHERE ISNULL(alt,0) = 0 AND del = 0 [CATECONDITION] [ORDERBY]"
			fields = "[id],title,ServerTime dt,datediff(s,'" & actDate & "',isnull(ServerTime,'2000-01-01')) newTag,0 [rid],ISNULL(creator,0) cateid"
			orderBy = "ORDER BY ServerTime DESC,id DESC"
			Case 73:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and cateid in ("&qIntro&") "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition &  "AND NextOperator=" & uid &" "& cateCondition
			sql="SELECT COUNT(*) REMIND_CNT FROM sale_Complaints  with(nolock) WHERE del=0 and ISNULL(alt,0) = 0 [CATECONDITION] [ORDERBY]"
			fields = "[id],title,ServerTime dt,datediff(s,'" & actDate & "',isnull(ServerTime,'2000-01-01')) newTag,0 [rid],ISNULL(cateid,0) cateid"
			orderBy = "ORDER BY ServerTime DESC,id DESC"
			Case 72:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and cateid in ("&qIntro&") "
			else
				cateCondition = " and 1=2"
			end if
			sql="SELECT COUNT(*) REMIND_CNT FROM Sale_CallBack  with(nolock) where Del=1 and cateid=" & uid &_
			" and dbo.dateDiffByDay(ybackTime,2,0,"& m_tq1 &",GETDATE())>=0 and isback=0 and isnull(setalt,0)=0 "& cateCondition & " [ORDERBY]"
			fields = "[id],title,CONVERT(varchar, ybackTime,20) dt,-1 newTag,0 [rid],cateid"
			orderBy = "ORDER BY ServerTime DESC,id DESC"
			Case 100:
			sql = "select COUNT(*) REMIND_CNT from notebook with(nolock)  "&_
			"where (del=1 or del is null) and alt=0 and complete<>2 and cateid =" & uid &_
			"and datediff(d,getdate(),date7) <= " & m_tq1 & " [ORDERBY]"
			fields = "ord [id],'@code:htmldecode(rs(""real_title""))' title,convert(varchar,date7,120) dt,-1 newTag,0 [rid],cateid,cast(intro as varchar(8000)) real_title" &_
			"and datediff(d,getdate(),date7) <= " & m_tq1 & " [ORDERBY]"
			orderBy = "order by date7 desc"
			Case 101:
			sql = "    select COUNT(*) REMIND_CNT "&_
			"from learn  with(nolock) where (cateid=" & uid & " or CHARINDEX('," & uid & ",' , ','+share+',') > 0 or share = '1') " &_
			"and CHARINDEX(',&uid&,',','+alt+',"
			fields = "[id],title,convert(varchar,date7,120) dt,-1 newTag,0 [rid],cateid"
'sql = "    select COUNT(*) REMIND_CNT "&_
			orderBy = "order by date7 desc"
			Case 102:
			cateCondition = getCondition(m_qxlb,m_listqx,"a.AddUser")
			sql= "SELECT COUNT(*) REMIND_CNT " & vbcrlf &_
			"FROM RepairOrder a  with(nolock) left join ( " &_
			"select id,title from Comm_ProcessSet  with(nolock) where type=1 " &_
			") b on b.id = a.ProcessID  where a.id in( "& vbcrlf &_
			"select a.id FROM RepairOrder a  with(nolock) " & vbcrlf &_
			"left join ( " & vbcrlf &_
			"select id,title from Comm_ProcessSet  with(nolock) where type=1 " & vbcrlf &_
			") b on b.id = a.ProcessID " & vbcrlf &_
			"left join ( " & vbcrlf &_
			"SELECT distinct a.RepairOrder,a.ProcessID,a.DealPerson,ActualBeginTime,NodeID FROM RepairDeal a  with(nolock) " & vbcrlf &_
			"LEFT JOIN Copy_ProcessNodeSet b with(nolock)  ON b.ID = a.NodeID AND b.del = 1 " & vbcrlf &_
			"WHERE a.del = 1 AND a.CurrentStatus = 0 " & vbcrlf &_
			") c on c.RepairOrder=a.id and c.ProcessID=a.ProcessID " & vbcrlf &_
			"WHERE a.del = 1 " & vbcrlf &_
			"and (a.Status = 0 or a.Status = 1) " & vbcrlf &_
			"and isnull(c.DealPerson,a.DealPerson) = " & uid &" "&_
			"and datediff(d,getdate(),isnull(c.ActualBeginTime,'1900-01-01'))<= " & m_tq1 & " " &_
			"and isnull(c.DealPerson,a.DealPerson) = " & uid &" "&_
			"cateCondition & "") [ORDERBY]"""
			fields = "a.[id],b.title+'['+a.Title+']' title,convert(varchar,a.addTime,120) dt,-1 newTag,0 [rid],a.AddUser cateid"
'cateCondition & ") [ORDERBY]"
			orderBy = "order by a.addTime desc"
			Case 103:
			cateCondition = getCondition(m_qxlb,m_listqx,"MainExecutor")
			sql = "select COUNT(*) REMIND_CNT from (" & vbcrlf &_
			"select a.id,c.title+'['+b.name+']' title,convert(varchar,BeginTimePlan,120) dt,"& vbcrlf &_
			"a.BeginTimePlan,MainExecutor from ChanceProcRunLogs a  with(nolock) " & vbcrlf &_
			"inner join chanceProcNodesBak b  with(nolock) on a.ProcNodesBak = b.id " & vbcrlf &_
			"inner join chance c  with(nolock) on c.ord=a.chance AND c.del = 1 " & vbcrlf &_
			"where " & vbcrlf & _
			"(" & vbcrlf &_
			"(a.Status=0 and MainExecutor="&uid&")" & vbcrlf &_
			" or " & vbcrlf & _
			"(" & vbcrlf & _
			"(a.Status=1 or a.Status=9) " & vbcrlf &_
			" and " & vbcrlf &_
			"(MainExecutor="&uid&" or charindex(',"&uid&",',','+a.Executors+',')>0) " & vbcrlf &_
			" and " & vbcrlf &_
			")" & vbcrlf & _
			")" & vbcrlf &_
			" and datediff(d,getdate(),BeginTimePlan)<="& m_tq1&" " & cateCondition & vbcrlf &_
			") a [ORDERBY]"
			fields = "[id],title,dt,-1 newTag,0 [rid],MainExecutor cateid"
') a [ORDERBY]
			orderBy = "order by BeginTimePlan desc"
			Case 216:
			Dim sort46Open,sort47Open,rs_setting
			Set rs_setting = cn.execute("select intro from setopen  with(nolock) where sort1=46 union all select 0")
			sort46Open = rs_setting("intro")
			rs_setting.close
			Set rs_setting = cn.execute("select intro from setopen  with(nolock) where sort1=47 union all select 0")
			sort47Open = rs_setting("intro")
			rs_setting.close
			Set rs_setting = Nothing
			Call fillinPower(1,18,qOpen,qIntro)
			qIntro = IIF(qIntro&""="","0",qIntro)
			if sort46Open<>0 and sort46Open<>"" then
				if qOpen = 1 then
					if sort46Open = 1 then
						if sort47Open = 1 then
							cateCondition = cateCondition & " and (order1<>2 and (cateadd in("& qIntro &"))) "
						elseif sort47Open = 2 then
							cateCondition = cateCondition & " and (order1<>2 and (cateidgq in("& qIntro &"))) "
						else
							cateCondition = cateCondition & " and (order1<>2 and (cateidgq in("& qIntro &") or cateadd in("& qIntro &"))) "
						end if
					elseif sort46Open=2 then
						if sort47Open=1 then
							cateCondition = cateCondition & " and (cateadd in("& qIntro &")) "
						elseif sort47Open = 2 then
							cateCondition = cateCondition & " and (cateidgq in("& qIntro &")) "
						elseif sort47Open = 3 then
							cateCondition = cateCondition & " and (cateid in("& qIntro &")) "
						else
							cateCondition = cateCondition & " and (cateidgq in("& qIntro &") or cateadd in(" & qIntro & ")) "
						end if
					end if
				ElseIf qOpen <> 3 And qOpen & "" <> "" Then
					cateCondition = cateCondition & " and 1=2 "
				end if
			end if
			Call fillinPower(1,6,qOpen,qIntro)
			tmpCondition = "" & _
			" AND (" & vbcrlf &_
			"(" & vbcrlf &_
			"order1 = 3 and (" & vbcrlf &_
			"qOpen & ""=3 or ("" & qOpen & ""=1 and charindex(','+cast(b.cateid4 as varchar)+',',',"" & qIntro & "",')>0)" & vbcrlf &_
			")" & vbcrlf &_
			") " & vbcrlf &_
			"OR (isnull(order1,0) = 0  AND cateid4 = "& uid &" )" & vbcrlf &_
			") "
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & tmpCondition & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN order1 <> 3 THEN 1 ELSE 0 END) canCancelAlt," & vbcrlf &_
			"(case WHEN order1 = 3 then 10 else 12 end) orderStat"
			orderBy = "order by a.inDate desc,b.ord desc"
			Case 104:
			cateCondition = " AND (charindex(',"&uid&",',','+b.share+',')>0 or share='1') "
'Case 104:
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name title,convert(varchar(19),b.date1,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by a.inDate desc,b.ord desc"
			Case 54:
			cateCondition = " AND (CHARINDEX(',"&uid&",',','+b.share+',')>0 OR share='1') "
'Case 54:
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN chance b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),b.date1,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 201:
			cateCondition = " AND (CHARINDEX(',"&uid&",',','+b.share+',')>0 OR share='1') "
'Case 201:
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN contract b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(10),b.date3,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 202:
			cateCondition = " AND (CHARINDEX(',"&uid&",',','+b.share+',')>0 OR share='1') "
'Case 202:
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN tousu b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),b.date7,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate [cateid]"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 203:
			Dim workPosition : workPosition = cn.execute("SELECT workPosition FROM gate WHERE ord = "& uid)(0).value
			cateCondition = " AND (CHARINDEX(',"&uid&",',','+cast(b.share1 as varchar(8000))+',')>0 OR CHARINDEX(',"&uid&",',','+cast(b.share2 as varchar(8000))+',')>0 OR CHARINDEX(',"&workPosition&",',','+cast(b.postView as varchar(8000))+',')>0 OR CHARINDEX(',"&workPosition&",',','+cast(b.postDown as varchar(8000))+',')>0) "
'Dim workPosition : workPosition = cn.execute("SELECT workPosition FROM gate WHERE ord = "& uid)(0).value
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN document b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del=1 AND (b.sp = 0 AND b.cateid_sp = 0)" & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(19),b.date7,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate [cateid]"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 64:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND sp > 0) OR (cateid_sp = 0  AND ((ISNULL(cateid,0) = 0 AND addcate = " & uid & ") or (ISNULL(cateid,0) > 0 AND cateid = " & uid & ")))) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN chance b ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3)  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid, " &_
			"(CASE WHEN (cateid_sp = 0 OR sp < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case sp when -1 then 12 when 0 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 53:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateadd")
			cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND sp > 0) OR (cateid_sp = "& uid &" AND sp=-1) OR (cateid_sp = 0  AND cateadd = "& uid &" )) "
'cateCondition = getCondition(m_qxlb,m_listqx,"b.cateadd")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN (cateid_sp = 0 OR sp < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case when sp<0 then 15 when cateid_sp = 0 then 14 else 13 end) orderStat"
			orderBy = "order by a.inDate desc,b.ord desc"
			Case 13:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND b.ord in ( SELECT mr.ord FROM dbo.price mr  with(nolock)   "&_
			"   inner join sp_ApprovalInstance c  with(nolock) on c.gate2=13001 and c.PrimaryKeyID = mr.ord and c.BillPattern in (0,1)  "&_
			"   WHERE mr.del<>2 and ((mr.status in (-1,0,1) and isnull(mr.Cateid,mr.Addcate) =" & uid &") "&_
			"   or (mr.status in (2,4,5) and charindex('," & uid &",',','+ c.SurplusApprover +',')>0))) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN price b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) " & vbcrlf &_
			"inner join sp_ApprovalInstance c on c.gate2=13001 and c.PrimaryKeyID = b.ord and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(case when c.ApprovalFlowStatus in (-1,0,1,3) then 1 else 0 end) canCancelAlt," &_
			"(case status when 0 then 16 when 4 then 10 when 5 then 8 when 2 then 12 else 11 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 14:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND b.ord in ( SELECT mr.ord FROM dbo.contract mr  with(nolock)   "&_
			"   inner join sp_ApprovalInstance c  with(nolock) on c.gate2=11001 and c.PrimaryKeyID = mr.ord and c.BillPattern in (0,1)  "&_
			"   WHERE mr.del<>2 and ((mr.status in (-1,0,1) and case when isnull(mr.Cateid,0)>0 then mr.Cateid else mr.Addcate end =" & uid &") "&_
			"   or (mr.status in (2,4,5) and charindex('," & uid &",',','+ c.SurplusApprover +',')>0))) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN contract b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) "&vbcrlf &_
			"inner join sp_ApprovalInstance c on c.gate2=11001 and c.PrimaryKeyID = b.ord and c.BillPattern in (0,1) " &_
			"WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(case when c.ApprovalFlowStatus in (-1,0,1,3) then 1 else 0 end) canCancelAlt," &_
			"(case status when 0 then 16 when 4 then 10 when 5 then 8 when 2 then 12 else 11 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 69:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND sp > 0) OR (cateid_sp = 0  AND addcate = " & uid & "))  "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN contractth b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN (cateid_sp = 0 OR sp < 0) THEN 1 ELSE 0 END) canCancelAlt, " &_
			"(case sp when -1 then 12 when 0 then 11 else 10 end) orderStat" &_
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 16:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN caigou b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) "&_
			"inner join sp_ApprovalInstance c on c.gate2=73001 and c.PrimaryKeyID = b.ord and c.BillPattern in (0,1) " &_
			"WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			" 0 canCancelAlt,(case b.status when -1 then 17 when 0 then 16 when 1 then 11 when 2 then 12 when 3 then 9 when 4 then 10 when 5 then 8 else 10 end)  orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 60:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND ( (kg = "& uid &" AND complete1 = 1 and isnull(b.status,-1) in (-1,1)) OR (complete1 > 1  AND cateid = "& uid &" ) ) "
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN kuin b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del = 1 WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN (kg = 0 OR complete1 IN (2,3)) THEN 1 ELSE 0 END) canCancelAlt, " &_
			"(case isnull(status,-1) when 1 then 11 else 17 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 61001:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join kuin b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c on c.gate2=61001 and c.PrimaryKeyID = b.ord and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title,b.date7 dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.date7 desc"
			Case 62001:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join kuout b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=62001 and c.PrimaryKeyID = b.ord and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title,b.date7 dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.date7 desc"
			Case 23701:
			DIM MCYG,MCBJ
			MCYG=FALSE
			MCBJ=FALSE
			if ZBRuntime.MC(14000) then
				MCYG=TRUE
			end if
			if ZBRuntime.MC(4000) then
				MCBJ=TRUE
			end if
			sql ="select COUNT(*) REMIND_CNT from"& _
			"("& _
			"select A.id,A.cateid,1 ismode,title,date1,date7  from"& _
			"("& _
			"select "& _
			"cai.id,count(c.id) cid,count(x.id)xid,cai.date7,cai.date1,cai.title,cai.cateid "& _
			"from caigou_yg cai  with(nolock)  "& _
			"inner join caigoulist_yg c  with(nolock) on  cai.id=c.caigou "& _
			"left join xunjialist x  with(nolock) on c.id=x.caigoulist_yg and x.caigoulist_yg>0 and x.del=1 "& _
			"left join xunjia xu  with(nolock) on xu.id=x.xunjia and xu.fromtype<>0 "&_
			"left join gate g  with(nolock) on g.ord=cai.cateid  "& _
			"left join power p  with(nolock) on p.ord="&uid&" and p.sort1=25 and p.sort2=1"&_
			"                                 ""where  cai.del=1 and cai.status=0  AND '""&MCYG&""'='TRUE'   and ISNULL(cai.xunjia,0)=0 and needxj=1 and (p.qx_open=3 or  CHARINDEX(','+CAST(cai.cateid AS VARCHAR(20))+',',','+CAST(p.qx_intro AS VARCHAR(8000))+',') > 0) GROUP BY cai.id,cai.date7,cai.date1,cai.title,g.name,cai.cateid,cai.ygid " & _
			")A WHERE (A.cid>0 AND xid=0) or(A.cid>0 And xid>0 And xid<A.cid)  "& _
			"union all  "& _
			"select p.ord,p.cateid cateid,0 ismode,p.title,p.date1,p.date7 from price p  with(nolock) "& _
			"left join gate gg  with(nolock) on gg.ord=p.addcate "& _
			" left join power po  with(nolock) on po.ord="&uid&" and po.sort1=4 and po.sort2=1"&_
			"where (p.complete=1 or p.complete=8) and p.del=1 AND '"&MCBJ&"'='TRUE' and p.xj=1 and  exists(select 1 from pricelist  with(nolock) where price =p.ord AND xunjiastatus!=1)"&_
			"AND NOT exists(select 1 from xunjialist a  with(nolock)  "&_
			"inner join xunjia b  with(nolock) on a.xunjia=b.id and b.del=1 "&_
			"INNER join tel c on a.gys=c.ord and c.sort3=2 "&_
			"where b.price=p.ord)"&_
			" and (po.qx_open=3 or CHARINDEX(','+CAST(p.cateid AS VARCHAR(20))+',',','+CAST(po.qx_intro AS VARCHAR(8000))+',') > 0)"& _
			"where b.price=p.ord)"&_
			")C left join power pow on pow.ord= "&uid&"  and pow.sort1=24 and pow.sort2=13    WHERE (pow.qx_open=3 or CHARINDEX(','+CAST(C.cateid AS VARCHAR(20))+',',','+CAST(pow.qx_intro AS VARCHAR(8000))+',') > 0) AND 1=1"& _
			"where b.price=p.ord)"&_
			"[ORDERBY]"
			fields = "C.id [id],(case when C.ismode=1 THEN '来自预购:'+ C.title else '来自报价:'+ C.title end) title,0 [rid],C.cateid,-1 newTag, CAST(CONVERT(varchar(10), C.date1 , 120)as datetime)  dt"
'[ORDERBY]
			orderBy = "ORDER BY C.date7 DESC"
			Case 61:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND ( (kg = "& uid &" AND complete1 = 1 and isnull(b.status,-1) in (-1,1)) ) "
'cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN kuout b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del = 1 WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN (kg = 0 OR complete1 IN (2,3)) THEN 1 ELSE 0 END) canCancelAlt, " &_
			"(case isnull(status,-1) when 1 then 11 else 17 end) orderStat"
'(CASE WHEN (kg = 0 OR complete1 IN (2,3)) THEN 1 ELSE 0 END) canCancelAlt,  &_
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 62:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND ( ("& iif(openPower(33,16) > 0,"1=1","1=2") &" AND complete1 = 0) OR (complete1 = 1  AND cateid = "& uid &" ) ) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN send b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN (addcate = 0 OR complete1 = 1) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case complete1 when 0 then 10 when 1 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 50:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.Creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN payoutsure b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ID AND b.del = 1  " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=44011 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ID DESC"
			Case 43012:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.Creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.Creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.Creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN PaybackInvoiceSure b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ID AND b.del = 1  " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=43012 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ID DESC"
			Case 44012:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.Creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.Creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.Creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN PayoutInvoiceSure b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ID AND b.del = 1  " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=44012 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ID DESC"
			Case 65:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN bankin2 b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) " & vbcrlf &_
			" inner join sp_ApprovalInstance c on c.gate2=43001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			" WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],cast(b.title as varchar(8000)) title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN (cateid_sp = 0 OR sp < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case status_sp when 2 then 12 when 1 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 206:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN bankout2 b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) " & vbcrlf &_
			" inner join sp_ApprovalInstance c  with(nolock) on c.gate2=44001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			" WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],cast(b.title as varchar(8000)) title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator as cateid,"&_
			"(CASE WHEN (ISNULL(cateid_sp,0) = 0 OR ISNULL(sp,0) < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case status_sp when 2 then 12 when 1 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 205:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.addcate")
			cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND complete = 2) OR (complete = 3  AND addcate = "& uid &" )) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN caigouQC b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del = 1 WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate [cateid],"&_
			"(CASE WHEN (cateid_sp = 0 OR complete < 0 OR complete = 3) THEN 1 ELSE 0 END) canCancelAlt, " &_
			"(case complete when -1 then 12 when 3 then 11 else 10 end) orderStat"
'(CASE WHEN (cateid_sp = 0 OR complete < 0 OR complete = 3) THEN 1 ELSE 0 END) canCancelAlt,  &_
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 40:
			cateCondition = getCondition(m_qxlb,m_listqx,"addcateid")
			cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND complete not in (1,3)) OR (complete in (1,3) AND addcateid = "& uid &" )) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN paysq b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcateid [cateid],"&_
			"(CASE WHEN complete in (1,3) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case complete when 3 then 12 when 1 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 41:
			cateCondition = getCondition(m_qxlb,m_listqx,"cateid")
			cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND complete not in (2,3)) OR (complete in (2,3) AND cateid = "& uid &" )) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN paybx b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid [cateid],"&_
			"(CASE WHEN (cateid_sp = 0 OR sp_id < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case complete when 2 then 12 when 3 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 42:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.sorce2")
			cateCondition = cateCondition & " AND ((isnull(gate_sp,0) = "& uid &" AND sp_id > 0) OR (isnull(sp_id,0) = 0  AND sorce2 = "& uid &" )) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN payjk b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.sorce2 [cateid],"&_
			"(CASE WHEN (isnull(gate_sp,0) = 0 OR sp_id < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case sp_id when -1 then 12 when 0 then 11 else 10 end) orderStat"
'(CASE WHEN (isnull(gate_sp,0) = 0 OR sp_id < 0) THEN 1 ELSE 0 END) canCancelAlt, &_
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"""
			Case 43:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND complete IN (7,11)) OR ((complete = 8 OR complete = 12)  AND addcate = "& uid &" )) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN pay b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN (cateid_sp = 0 OR complete = 8 OR complete = 12) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case complete when 12 then 12 when 8 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 71:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_NeedPerson b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(19),b.indate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 44:
			cateCondition = getCondition(m_qxlb,m_listqx,"c.use_cateid")
			cateCondition = cateCondition &" AND d.send_cateid = "& uid &" "
			sql = "SELECT COUNT(*) REMIND_CNT FROM (" & vbcrlf &_
			"select distinct b.id [id],c.use_title title,convert(varchar(19),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,b.id [rid],c.use_cateid [cateid],a.inDate,c.id cid " & vbcrlf &_
			"from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN O_MeetingSummary b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id " & vbcrlf &_
			"INNER JOIN O_MeetingUse c  with(nolock) ON c.id = b.sum_metId " & vbcrlf &_
			"INNER JOIN O_SummarySend d  with(nolock) ON d.send_meetingid = b.id " & vbcrlf &_
			"WHERE 1 = 1 AND d.send_type = 1 AND d.send_issucceed = 1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] "&vbcrlf &_
			") bbb [ORDERBY]"
			fields = "[id],title,dt,newTag,[rid],[cateid],inDate,cid"
			orderBy = "ORDER BY inDate DESC,cid DESC"
			Case 56:
			tmpCondition = ""
			If m_fw1&""="0" Then
				tmpCondition = ""
			else
				tmpCondition = " and c.cateid=" & uid & " "
			end if
			cateCondition = "and (" & vbcrlf
			Call fillinPower(1,5,qOpen,qIntro)
			cateCondition = cateCondition & " ( c.sort1=1 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(2,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=8 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(3,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=2 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(4,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=3 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(5,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=4 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(22,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=5 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(41,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=6 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(42,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=7 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(75,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=75 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(95,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=102001 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(96,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=102002 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			cateCondition = cateCondition & " ) "
			cateCondition = " and (( 1=1 " & tmpCondition & " " & cateCondition & ") or c.share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(c.share as varchar(8000)),' ','')+',')>0)" & vbcrlf
			cateCondition = cateCondition & " ) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN dianping b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id " &_
			"INNER JOIN reply c  with(nolock) ON c.id = b.ord " &_
			"LEFT JOIN tel d  with(nolock) ON d.ord = c.ord " &_
			"WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.intro title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],0 [cateid]"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 57:
			cateCondition = " AND isnull(order1,0) = "& uid &" "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN plan1 b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord WHERE b.complete='2' " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.intro title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],0 [cateid]"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 58:
			cateCondition = " AND isnull(cateid,0) = "& uid &" "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN plan2 b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.type IN (17,12,13,14,15,16) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],cast(b.intro as varchar(8000)) title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],0 [cateid]"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 18:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN payback b  with(nolock) ON a.reminderConfig=" & configId & " AND (a.orderId = -b.ord or a.orderId = b.ord) AND b.del = 1 AND complete = '3' WHERE 1 = 1 " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],'@code:FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 207:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.ret_addcateid")
			cateCondition = cateCondition & " AND ((ret_bcateid = "& uid &" AND ret_state = 1 ) OR (ret_state > 1 AND Exit Sub_addcateid = "& uid &" )) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN O_proReturn b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.ret_del = 1 WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.ret_title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.ret_addcateid [cateid],"&_
			"(CASE WHEN (ret_bcateid = 0 OR ret_state > 1) THEN 1 ELSE 0 END) canCancelAlt, " &_
			"(case ret_state when 3 then 12 when 2 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 208:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.get_addcateid")
			cateCondition = cateCondition & " AND ((get_storecateid = "& uid &" AND get_store = 2 ) OR (get_store <> 2 AND get_addcateid = "& uid &" )) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN O_productOut b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.get_del = 1 WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.get_title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.get_addcateid [cateid],"&_
			"(CASE WHEN (get_storecateid = 0 OR get_store <> 2) THEN 1 ELSE 0 END) canCancelAlt, " &_
			"(case get_store when 3 then 12 when 1 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 8:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			cateCondition = " and ((1=1" & cateCondition & ") or CHARINDEX(',"&uid&",',','+b.share+',')>0 OR share='0') "
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) "&_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN learnhd b  with(nolock) on a.orderId = b.ord AND b.del = 1 " &_
			" WHERE a.reminderConfig=" & configId & " [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "ISNULL(b.ord,0) [id],isnull(b.title,'【已删除数据】') title,isnull(convert(varchar(19),b.date7,21),'----') dt,"&_
			"DATEDIFF(s,' & actDate & "
			orderBy = "ORDER BY a.id DESC"
			Case 209:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN payoutsure b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ID AND b.del = 1  " & vbcrlf &_
			"left join sortbz d  with(nolock) on d.id=b.bz " & vbcrlf &_
			"WHERE 1 = 1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ID [id],  '@code:""'+b.title+'('+isnull(d.intro,'RMB')+' "" & FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)&""'+')'+'""' title,"&_
			"convert(varchar(19),a.inDate,21) dt,datediff(s,'&actDate&"
			orderBy = "ORDER BY a.inDate DESC,b.ID DESC"
			Case 210:
			cateCondition = " AND ((b.khzt <> 1 AND EXISTS (SELECT 1 FROM hr_perform_sp_list  with(nolock) WHERE sortID = b.sortid AND sp_id = "& uid &")) OR (b.khzt = 1 AND (CAST(b.user_list AS VARCHAR) = '0' OR CHARINDEX(',"& uid &",' , ','+ CAST(b.user_list AS VARCHAR) +',') > 0)) )"
'Case 210:
			cateCondition = cateCondition & " AND DATEDIFF(d,sp_Time1,GETDATE()) >= 0 AND DATEDIFF(d,sp_Time2,GETDATE()) <= 0 "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN hr_perform_sort b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del = 0 WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator [cateid]"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 211:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN paybackInvoice b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del = 1 " & vbcrlf &_
			"left join sortbz c  with(nolock) on c.id=b.bz " & vbcrlf &_
			"WHERE 1 = 1 AND b.isInvoiced <> 3  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],'@code:""'+isnull(c.intro,'RMB')+' "" & FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(10),b.invoiceDate,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 212:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN payoutInvoice b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del = 1 " & vbcrlf &_
			"WHERE 1 = 1 AND b.del = 1 AND b.isInvoiced in (1,2) " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.[id],'@code:FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(19),b.invoiceDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid "
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 10:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"c.cateid")
			cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN kujhlist b  with(nolock) on a.reminderConfig="&configId&" and a.orderId=b.id and b.del=1 " & vbcrlf &_
			"inner Join kujh c  with(nolock) on b.kujh=c.ord and c.del=1 " & vbcrlf &_
			"inner join product d on d.ord=b.ord " & vbcrlf &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],c.title+'('+d.title+')' title,CONVERT(VARCHAR(10),b.date2,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],c.cateid [cateid]"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by b.date2 DESC,b.date7 DESC"
			Case 20:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			storelist_sort5 = "0"
			Set rsUsConfig= conn.execute("select isnull(tvalue,'0') tvalue from home_usConfig where name='storelist_sort5' and isnull(uid, 0) =" &  session("personzbintel2007") )
			If rsUsConfig.eof= False Then
				storelist_sort5=rsUsConfig("tvalue")
			end if
			rsUsConfig.close
			showKuLimitZeroSQL = ""
			if storelist_sort5 = "0" then
				showKuLimitZeroSQL = " and (isnull(b.alert1,0)>0 or isnull(b.alert2,0)>0)"
			end if
			showzore =0
			Set rsUsConfig= conn.execute("select (case cast(tvalue as varchar(10)) when '1' then 1 else 0 end) v from home_usConfig  with(nolock) where uid="& session("personzbintel2007") &" and name='storelist_sort1' ")
			if rsUsConfig.eof=false  then
				showzore = rsUsConfig("v").value
			end if
			rsUsConfig.close
			unkuinwarning = 0
			if showzore="1" then
				Set rsUsConfig= conn.execute("select (case cast(tvalue as varchar(10)) when '1' then 1 else 0 end) v from home_usConfig  with(nolock) where uid="& session("personzbintel2007") &" and name='storelist_warning' ")
				if rsUsConfig.eof=false  then
					unkuinwarning = rsUsConfig("v").value
				end if
				rsUsConfig.close
			end if
			showZeroSQL = ""
			if showzore = "0" then
				showZeroSQL = " and isnull(b.ku_num,0)>0 "
			else
				if unkuinwarning="0" then
					showZeroSQL = " and exists(select 1 from ku where ord =a.ord) "
				end if
			end if
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen = 1 Then
				cateCondition = " and charindex(','+cast(b.addcate as varchar)+',',',"&qIntro&",')>0 "
'ElseIf qOpen = 1 Then
			else
				cateCondition = " and 1=2 "
			end if
			If withoutCateCondition Then
				tmpCondition = ""
			else
				tmpCondition = "inner join sortck subc on subc.id = suba.ck "& vbcrlf &_
				"and subc.del=1 "& vbcrlf &_
				"and ("& vbcrlf &_
				"charindex('," & uid & ",',','+replace(cast(subc.intro as varchar(4000)),' ','')+',')>0 "& vbcrlf &_
				"and ("& vbcrlf &_
				"or replace(cast(subc.intro as varchar(4000)),' ','') = '0'"& vbcrlf &_
				")"
			end if
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN ("&vbcrlf & _
			"SELECT a.ord,addcate,title," & vbcrlf & _
			"(CASE WHEN Isnull(aleat1, 0) = 0 THEN 0 ELSE Isnull(aleat1,0) END) AS alert1, " & vbcrlf & _
			"(CASE WHEN Isnull(aleat2, 0) = 0 THEN 0 ELSE Isnull(aleat2,0) END) AS alert2, " & vbcrlf & _
			"date7,Isnull(ku_num, 0) ku_num " & vbcrlf & _
			"FROM product a " & vbcrlf & _
			"LEFT JOIN ("&vbcrlf & _
			"SELECT ord,Sum(numjb) AS ku_num FROM ("&vbcrlf & _
			"SELECT suba.ord," & vbcrlf & _
			"(CASE WHEN suba.unit = subb.unitjb THEN num2 " & vbcrlf & _
			"ELSE num2 * Isnull((SELECT TOP 1 bl FROM jiage  with(nolock) WHERE product = suba.ord AND unit = suba.unit),0) " & vbcrlf & _
			"END) numjb " & vbcrlf & _
			"FROM ku suba  with(nolock) " & vbcrlf & _
			"INNER JOIN product subb  with(nolock) ON suba.ord = subb.ord " & vbcrlf & _
			"tmpCondition" & vbcrlf &_
			") subaa " & vbcrlf & _
			"GROUP BY ord " & vbcrlf & _
			") AS b ON a.ord = b.ord " & vbcrlf & _
			"WHERE a.del = 1 "& showZeroSQL&" AND (isnull(ku_num,0)<=aleat1 or isnull(ku_num,0)>aleat2) " & vbcrlf & _
			") AS b ON a.orderid = b.ord "& showKuLimitZeroSQL &" AND a.reminderConfig=" & configId & " " & vbcrlf & _
			"WHERE 1 = 1 " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title," &_
			"CASE WHEN [Ku_num]<[alert1] then '↓'+cast(dbo.formatnumber([Ku_num]," & numDigit & ",0) as nvarchar(50)) " & _
			"WHEN [Ku_num]>[alert2] then '↑" &_
			"END dt," &_
			"DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate [cateid]"
			orderBy = "order by title desc,date7 desc"
			Case 49:
			cateCondition = getCondition(m_qxlb,m_listqx,"c.personID")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_person_health c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.id " & vbcrlf &_
			"INNER JOIN hr_person b  with(nolock) ON b.userID = c.personID " & vbcrlf & _
			"where 1=1 AND Isnull(c.alt, 1) < 2 and b.del = 0 AND c.lastdate IS NOT NULL "&_
			"AND c.zhouqi IS NOT NULL AND b.nowstatus NOT IN (2,3,4) " & vbcrlf &_
			"and DATEDIFF(m,GETDATE(),b.contractEnd)>0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]" & vbcrlf
			fields = "c.id [id],b.username title,CONVERT(VARCHAR(10)," & _
			"(CASE c.unit " & vbcrlf & _
			"WHEN 1 THEN Dateadd(yyyy, c.zhouqi, c.lastdate) " & vbcrlf & _
			"WHEN 2 THEN Dateadd(qq, c.zhouqi, c.lastdate) " & vbcrlf & _
			"WHEN 3 THEN Dateadd(m, c.zhouqi, c.lastdate) " & vbcrlf & _
			"WHEN 4 THEN Dateadd(ww, c.zhouqi, c.lastdate) " & vbcrlf & _
			"WHEN 5 THEN Dateadd(d, c.zhouqi, c.lastdate) " & vbcrlf & _
			"ELSE NULL " & vbcrlf & _
			"END )" & vbcrlf &_
			",23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],c.personID [cateid]"
			orderBy = "order by dt DESC"
			Case 66:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1 & " "
			cateCondition = cateCondition & " and charindex('," & uid &",',','+cast(isnull(b.alt,'') as varchar(4000))+',')=0"
			cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1 & " "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"(" & vbcrlf &_
			"SELECT z.id,t.name,t.cateid,s.title,z.date2,cast(isnull(z.alt,'') as varchar(4000)) alt,t.share " & vbcrlf & _
			"FROM tel t  with(nolock) " & vbcrlf & _
			"INNER JOIN sortFieldsContent z  with(nolock) " & vbcrlf & _
			"ON z.ord = t.ord " & vbcrlf & _
			"AND z.del = 1 " & vbcrlf & _
			"AND t.del = 1 " & vbcrlf & _
			"AND z.sort = 1 " & vbcrlf & _
			"AND t.sort3 = 2 " & vbcrlf & _
			"AND t.isNeedQuali = 1 " & vbcrlf & _
			"AND ISNULL(t.status_sp_qualifications, 0) = 0 " & vbcrlf & _
			"AND LEN(z.date2) > 0 " & vbcrlf & _
			"AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"AND CHARINDEX(',"& uid &",', ',' + CAST(z.share AS VARCHAR(4000)) + ',') > 0 " & vbcrlf & _
			"AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"INNER JOIN sortClass s with(nolock)  " & vbcrlf & _
			"ON z.sortid = s.id " & vbcrlf & _
			"AND ISNULL(s.isStop, 0) = 0 " & vbcrlf & _
			"AND s.sort1 = 2 " & vbcrlf & _
			") b ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbcrlf & _
			"WHERE 1 = 1 " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.name title,CONVERT(VARCHAR(10),b.date2,23) dt,DATEDIFF(s,'"&actDate&"',b.date2) newTag,a.id [rid],b.cateid [cateid]"
			orderBy = "order by b.date2 DESC"
			Case 67:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1 & " "
			cateCondition = cateCondition & " and charindex('," & uid &",',','+cast(isnull(b.alt,'') as varchar(4000))+',')=0"
			cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1 & " "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"("&_
			"SELECT z.id,t.name,t.cateid,s.title,z.date2,cast(isnull(z.alt,'') as varchar(4000)) alt,t.share " & vbcrlf & _
			"FROM tel t  with(nolock) " & vbcrlf & _
			"INNER JOIN sortFieldsContent z  with(nolock) " & vbcrlf & _
			"ON z.ord = t.ord " & vbcrlf & _
			"AND z.del = 1 " & vbcrlf & _
			"AND t.del = 1 " & vbcrlf & _
			"AND z.sort = 1 " & vbcrlf & _
			"AND t.sort3 = 1 " & vbcrlf & _
			"AND t.isNeedQuali = 1 " & vbcrlf & _
			"AND ISNULL(t.status_sp_qualifications, 0) = 0 " & vbcrlf & _
			"AND LEN(z.date2) > 0 " & vbcrlf & _
			"AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"AND CHARINDEX(',"& uid &",', ',' + CAST(z.share AS VARCHAR(4000)) + ',') > 0 " & vbcrlf & _
			"AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"INNER JOIN sortClass s  with(nolock) " & vbcrlf & _
			"ON z.sortid = s.id " & vbcrlf & _
			"AND ISNULL(s.isStop, 0) = 0 " & vbcrlf & _
			"AND s.sort1 = 2 " & vbcrlf & _
			") b ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbcrlf & _
			"WHERE 1 = 1 " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.name title,CONVERT(VARCHAR(10),b.date2,23) dt,DATEDIFF(s,'"&actDate&"',b.date2) newTag,a.id [rid],b.cateid [cateid]"
			orderBy = "ORDER BY b.date2 DESC"
			Case 213:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"( " & vbCrLf &_
			"  SELECT a.id,a.date1,a.date7,a.cateid,ISNULL(a.money1,0) money1,b.intro bz FROM paybackinvoice a  with(nolock)  " & vbCrLf &_
			"  INNER JOIN sortbz b  with(nolock) ON b.id = a.bz " & vbCrLf &_
			"  WHERE a.del = 1 AND isInvoiced = 0  AND ISNULL(a.cateid,0) <> 0 " & vbCrLf &_
			") b ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
			"WHERE 1 = 1 " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],'@code:""'+isnull(b.bz,'RMG')+' "" & FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,CONVERT(VARCHAR(10),b.date1,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "ORDER BY b.date1 DESC,b.date7 DESC"
			Case 214:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN payoutInvoice b  with(nolock) ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
			"left JOIN sortbz d  with(nolock) ON d.id = b.bz " & vbCrLf &_
			"WHERE 1 = 1 AND b.del = 1 AND b.isInvoiced in (0,11) " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.[id],'@code:""'+isnull(d.intro,'RMB')+' "" & FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,CONVERT(VARCHAR(10),b.date1,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "ORDER BY b.date1 DESC,b.date7 DESC"
			Case 52:
			cateCondition = cateCondition & " AND daysFromNow <= " & m_tq1 * 24
			sql = "" &_
			"SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join ku k  with(nolock) on a.orderId=k.id and a.reminderConfig=" & configId &" " & vbcrlf &_
			"INNER JOIN product p  with(nolock) ON p.ord = k.ord " & vbcrlf &_
			"INNER JOIN sortck ck  with(nolock) ON k.ck = ck.ord AND ck.del = 1 " & vbcrlf &_
			"where (" & vbcrlf & _
			"CAST(ISNULL(ck.intro,'') AS VARCHAR(4000)) = '0' " & vbcrlf &_
			"OR CHARINDEX(',"&uid&",', ',' + CAST(ck.intro AS VARCHAR(4000)) + ',') > 0 " & vbcrlf &_
			"CAST(ISNULL(ck.intro,'') AS VARCHAR(4000)) = '0' " & vbcrlf &_
			") " & vbcrlf &_
			"AND p.del = 1 " & vbcrlf &_
			"AND k.num2 > 0 " & vbcrlf &_
			"AND p.RemindNum > 0 " & vbcrlf &_
			"AND CHARINDEX(',"&uid&",', ',' + ISNULL(p.RemindPerson, '') + ',') > 0 " & vbcrlf &_
			"AND p.RemindNum > 0 " & vbcrlf &_
			"AND k.dateyx IS NOT NULL " & vbcrlf &_
			"AND ISNULL(k.locked, 0) = 0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "k.id [id],p.title,CONVERT(VARCHAR(10),k.dateyx,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],p.addcate [cateid]"
			orderBy = "ORDER BY k.dateyx DESC,p.date7 DESC"
			Case 51:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.addcateid")
			cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1 & " AND b.addcateid = "& uid &" "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"( " & vbCrLf &_
			"  SELECT a.id,d.id lid, c.bk_name, a.ld_rettime, d.addcateid " & vbcrlf &_
			"  FROM O_Lendbookmx a  with(nolock) " & vbcrlf &_
			"  LEFT JOIN O_Lendbook d  with(nolock) ON a.Ld_fid=d.id " & vbcrlf &_
			"  LEFT JOIN O_regbook c  with(nolock) ON a.Ld_bkid=c.id " & vbcrlf &_
			"  WHERE a.ld_num > (SELECT isnull(sum(Ret_num),0) AS Ret_num FROM O_RetBookmx  with(nolock) WHERE Ret_bkid=a.id) " & vbcrlf &_
			") b ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
			"WHERE 1 = 1 " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.lid [id],b.bk_name title,CONVERT(VARCHAR(10),b.ld_rettime,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcateid [cateid]"
			orderBy = "ORDER BY b.ld_rettime DESC"
			Case 59:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.userId")
			cateCondition = cateCondition & " AND DATEDIFF(d,getdate(),b.Reguldate)<=" & m_tq1 & " "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"( " & vbCrLf &_
			"  SELECT a.ID,a.Reguldate,a.UserId,a.userName name " & vbcrlf &_
			"  FROM hr_person a  with(nolock) " & vbcrlf &_
			"  WHERE  a.nowStatus = 5 AND a.del = 0 " & vbcrlf &_
			") b ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
			"WHERE 1 = 1 " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.name title,CONVERT(VARCHAR(10),b.Reguldate,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.UserId [cateid]"
			orderBy = "ORDER BY b.Reguldate DESC"
			Case 215:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1 & " "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"Chance b  with(nolock) ON a.orderID = b.ord AND a.reminderConfig=" & configId & " " & vbCrLf &_
			"WHERE 1 = 1 AND b.del = 1 AND b.cateid > 0 " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,'距离回收' + CAST(daysFromNow AS VARCHAR) + '天' dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid [cateid]"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "ORDER BY b.date7 DESC"
			Case 300:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.addcate")
			cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1 & " "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"document b  with(nolock) ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
			"WHERE 1 = 1 AND b.del = 1  AND validity = 2 AND (b.sp = 0 AND b.cateid_sp = 0) AND b.addcate = "& uid &" " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,CONVERT(VARCHAR(10),b.date4,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate [cateid]"
			orderBy = "ORDER BY b.date7 DESC"
			Case 301:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.addcate")
			cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1 & " "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"documentlist b  with(nolock) ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
			"inner join document d on d.id = b.document "  & vbCrLf &_
			"WHERE 1 = 1 AND d.del = 1 and b.del=1  AND b.l_validity = 2 AND (d.sp = 0 AND d.cateid_sp = 0) AND d.addcate = "& uid &" " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.oldname title,CONVERT(VARCHAR(10),b.l_date4,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],d.addcate [cateid]"
			orderBy = "ORDER BY b.date7 DESC"
			Case 105:
			tmpCondition = getConditionByFW(m_qxlb,m_listqx,"b.reg_addcateid")
			If withoutCateCondition Then tmpCondition = ""
			cateCondition = getConditionByFW(m_qxlb,15,"b.prod_addcateid")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join o_product b on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"inner join ( " & vbcrlf &_
			"select replace(prod_id,' ','') as ProductID,replace(prod_unit,' ','') as UnitId,sum(prod_num) as ku_num " & vbcrlf &_
			"from o_kuinlist a  with(nolock) " & vbcrlf &_
			"left join o_kuin b  with(nolock) on a.reg_fid=b.id " & vbcrlf &_
			"where 1=1 " & tmpCondition & " " & vbcrlf &_
			"group by prod_id,prod_unit " & vbcrlf &_
			") c on b.id=c.ProductID and a.daysFromNow=c.UnitId " & vbcrlf &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.prod_name title,(" & _
			"CASE when [Ku_num]<[prod_less] then '↓'+cast(dbo.formatnumber([Ku_num]," & numDigit & ",0) as nvarchar(50)) " & _
			"fields = ""b.id [id],b.prod_name title,(""" &_
			"when [Ku_num]>[prod_more] then '↑"
			fields = "b.id [id],b.prod_name title,(" & _
			"end " & _
			") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.prod_addcateid cateid"
			orderBy = "order by b.prod_name desc"
			Case 106:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name title,'距离回收' + cast(daysFromNow as varchar) + '天' dt,"&_
			"datediff(s,'&actDate&" &_
			orderBy = "order by daysFromNow asc"
			Case 107:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_AppHoliday b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where (" & vbcrlf &_
			"KQClass in (" & vbcrlf &_
			"select id from hr_KQClass  with(nolock) where sortID=1 and del=0 " & vbcrlf &_
			") or KQClass=1 " & vbcrlf &_
			") and del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(19),startTime,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 108:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_AppHoliday b with(nolock)  on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where (" & vbcrlf &_
			"KQClass in (" & vbcrlf &_
			"select id from hr_KQClass  with(nolock) where sortID=2 and del=0 " & vbcrlf &_
			") or KQClass=2 " & vbcrlf &_
			") and del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(19),startTime,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 109:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_AppHoliday b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where (" & vbcrlf &_
			"KQClass in (" & vbcrlf &_
			"select id from hr_KQClass  with(nolock) where sortID=3 and del=0 " & vbcrlf &_
			") or KQClass=3 " & vbcrlf &_
			") and del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(19),startTime,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 110:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((sp=-1 or sp=0) and cateid="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"cateCondition = cateCondition & ""and (""" & vbcrlf &_
			"or (sp>0 and cateid_sp=&uid&) /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join wages b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"where del=1 and isnull(salaryClass,0)>0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],title,cast(year(date2) as varchar)+'年'+cast(month(date2) as varchar)+'月' dt,"&_
			"datediff(s,'&actDate&" &_
			"(case when sp=-1 or sp=0 then 1 else 0 end) canCancelAlt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],cateid,"&_
			"(case sp when -1 then 12 when 0 then 11 else 10 end) orderStat"
			orderBy = "order by b.date7 desc,b.date3 desc"
			Case 111:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((sp=-1 or sp=0) and cateid="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"cateCondition = cateCondition & ""and (""" & vbcrlf &_
			"or (sp>0 and cateid_sp=&uid&) /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join wages b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"where del=1 and isnull(salaryClass,0)=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],title,cast(year(date2) as varchar)+'年'+cast(month(date2) as varchar)+'月' dt,"&_
			"datediff(s,'&actDate&" &_
			"(case when sp=-1 or sp=0 then 1 else 0 end) canCancelAlt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],cateid,"&_
			"(case sp when -1 then 12 when 0 then 11 else 10 end) orderStat"
			orderBy = "order by b.date7 desc,b.date3 desc"
			Case 217:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.designer")
			cateCondition = cateCondition & " AND ( (cateid_sp = "& uid &" AND id_sp > 0) OR (cateid_sp = 0  AND designer = "& uid &" ) ) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			" INNER JOIN design b  with(nolock) ON a.reminderConfig="& configId &" AND a.orderId = b.id and b.del=1 AND b.designstatus in (7,8,9) WHERE 1 = 1"& vbcrlf &_
			" [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id], b.title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.designer as cateid,"&_
			"(CASE WHEN (cateid_sp = 0 OR id_sp < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case id_sp when -1 then 12 when 0 then 11 else 10 end) orderStat"
'(CASE WHEN (cateid_sp = 0 OR id_sp < 0) THEN 1 ELSE 0 END) canCancelAlt, &_
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 218:
			cateCondition = getCondition(m_qxlb,15,"c.designer")
			cateCondition = cateCondition & " AND  charindex(',"& uid &",',','+replace(reminders,' ','')+',')>0 "
			cateCondition = getCondition(m_qxlb,15,"c.designer")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			" INNER JOIN reply b  with(nolock) ON a.reminderConfig="& configId &" AND a.orderId = b.id AND b.del=1 and b.sort1 = 5029 "& vbcrlf &_
			" inner join design c  with(nolock) on c.id = b.ord2       "&_
			" where b.del =1 " & vbcrlf &_
			" [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id], b.title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid], b.cateid "
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 112:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and cateid_moi in ("&qIntro&") "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & " and Cateid_MOI=" & uid
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M_ManuOrderIssueds b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.inDate desc"
			Case 113:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and b.id in (select distinct b.id from reminderQueue a  with(nolock) " & vbcrlf &_
				"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
				"left join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+b.Cateid_WA+',')>0" & vbcrlf &_
				"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" AND plist.sort1 = 54 AND plist.sort2 = 1" & vbcrlf &_
				"where b.del=1 and b.ptype=0 and tempSave=0 and b.[status]<>2 AND ISNULL(b.SPStatus,-1) IN(-1,1)" & vbcrlf &_
				"and (plist.qx_open = 3 OR CHARINDEX(','+CAST(g1.ord AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0))"
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & " and charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(Cateid_WA,' ','')+',')>0"
			cateCondition = " and 1=2"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join product p  with(nolock) on p.ord = b.productid "&_
			"where b.del=1 and ptype=0 and tempSave=0 and b.[status]<>2 AND ISNULL(b.SPStatus,-1) IN(-1,1) and CONVERT(varchar(10),b.inDate,120) <= CONVERT(varchar(10),GETDATE(),120)"&_
			"inner join product p  with(nolock) on p.ord = b.productid "&_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title +' ('+ p.title +')' as title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by b.inDate desc"
			Case 224:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and b.id in (select distinct b.id from reminderQueue a  with(nolock) " & vbcrlf &_
				"inner join erp_M2_WorkAssigns_status b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
				"left join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+b.Cateid_WA+',')>0" & vbcrlf &_
				"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" AND plist.sort1 = 54 AND plist.sort2 = 1" & vbcrlf &_
				"where b.del=1 and b.ptype=0 and tempSave=0 and b.[status]<>2 and b.wastatus!='生产完毕' AND ISNULL(b.SPStatus,-1) IN(-1,1)" & vbcrlf &_
				"and (plist.qx_open = 3 OR CHARINDEX(','+CAST(g1.ord AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0))"
			else
				cateCondition = " and 1=2"
			end if
			If m_fw1&""="1" Then
				tmpCondition = " and charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(Cateid_WA,' ','')+',')>0"
'If m_fw1&""="1" Then
			end if
			cateCondition =  " " & tmpCondition & " " & cateCondition & " and datediff(d,getdate(),b.dateEnd)<=" & m_tq1 & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join erp_M2_WorkAssigns_status b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join product p  with(nolock) on p.ord = b.productid "&_
			"where b.del=1 and b.ptype=0 and tempSave=0 and b.[status]<>2 and b.wastatus!='生产完毕' AND ISNULL(b.SPStatus,-1) IN(-1,1)" &_
			"inner join product p  with(nolock) on p.ord = b.productid "&_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title +' ('+ p.title +')' as title ,b.dateEnd dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by b.DateEnd, b.inDate desc"
			Case 225:
			tmpCondition = ""
			cateCondition = ""
			sql = "select COUNT(*) REMIND_CNT from dbo.v_attendance_GetRemind a   with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"where exists(select top 1 g.ord from dbo.gate g  with(nolock) where g.ord="& uid &" and g.orgsid=a.orgsid and g.Partadmin=1)" &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "a.Id [id],a.userName as title,a.WorkLong,a.RemindUnit,GETDATE() as dt,a.LogDate as newTag,a.Id [rid],a.Id cateid"
			orderBy = "order by a.LogDate desc"
			Case 5013:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & " and charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(Cateid_WA,' ','')+',')>0"
			cateCondition = " and 1=2"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join product p  with(nolock) on p.ord = b.productid "&_
			"where b.del=1 and b.ptype=1 and tempSave=0 and b.[status]<>2 and CONVERT(varchar(10),b.inDate,120) = CONVERT(varchar(10),GETDATE(),120)" & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title +' ('+ p.title +')' as title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by b.inDate desc"
			Case 54015:
			tmpCondition = ""
			cateCondition = ""
			sql = "select COUNT(*) REMIND_CNT from erp_fn_GetForSJWorkAssigns(''," & uid & ") a " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WorkAssigns b  with(nolock) on a.ID=b.ID "&_
			"where " &_
			" exists(" &_
			"SELECT 1 from dbo.gate gt  with(nolock) " &_
			"inner join power sjpow  with(nolock) ON sjpow.ord =" & uid & " AND sjpow.sort1 =(case isnull(b.ptype,0) when 0 then 54 else 62 end) and sjpow.sort2=1 " &_
			"WHERE  (sjpow.qx_open = 3 OR CHARINDEX(','+CAST(gt.ord AS VARCHAR(20))+',',','+CAST(sjpow.qx_intro AS VARCHAR(8000))+',') > 0) " &_
			"and CHARINDEX(','+CAST(gt.ord AS VARCHAR(20))+',',','+ISNULL(b.Cateid_WA,-1)+',') > 0)" &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "a.Id [id],a.title as title,a.inDate as dt,datediff(s,'"&actDate&"',a.inDate) as newTag,a.Id [rid],a.Creator cateid"
			orderBy = "order by a.inDate desc"
			Case 54106:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			cateCondition = ""
			cateCondition = cateCondition & " and (charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(QcCateid as varchar(12)),' ','')+',')>0 or exists(" &_
			"select top 1 1 from dbo.M2_OneSelfQualityTestingTaskList ttl  with(nolock) " &_
			" where ttl.TaskID=b.ID and charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(ttl.QcCateid as varchar(12)),' ','')+',')>0))"
			sql = "select COUNT(*) REMIND_CNT from (select MAX(b.id) as ID,b.orderId,reminderConfig,max(inDate) inDate from reminderQueue b  with(nolock) group by b.orderId,reminderConfig) a """ & vbcrlf &_
			"[CANCELJOINTABLE] " & _
			"inner join M2_OneSelfQualityTestingTask b with(nolock)  on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"where b.[QCStatus]<>2 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title +' ('+ b.TaskBh +')' as title,convert(varchar(10),b.TaskDate,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by b.inDate desc"
			Case 5014:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1&""="2" Then
				If qOpen = 3 Then
					tmpCondition = ""
				ElseIf qOpen=1 Then
					tmpCondition = " and b.id in (select distinct b.id from M2_WorkAssigns b  with(nolock)  " & vbcrlf &_
					"inner join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+b.Cateid_WA+',')>0" & vbcrlf &_
					"tmpCondition = "" and b.id in (select distinct b.id from M2_WorkAssigns b  with(nolock)  """ & vbcrlf &_
					"where g1.ord in (& qIntro &) )"
				else
					tmpCondition = " and 1=2"
				end if
			else
				tmpCondition = " and charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(Cateid_WA,' ','')+',')>0 "
				tmpCondition = " and 1=2"
			end if
			cateCondition =  " " & tmpCondition & " " & cateCondition & " and datediff(d,getdate(),b.dateEnd)<=" & m_tq1 & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join product p  with(nolock) on p.ord = b.productid "&_
			"where b.del=1 and ptype=1 and tempSave=0 and b.[status]<>2 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title +' ('+ p.title +')' as title ,b.dateEnd dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by b.inDate desc "
			Case 114:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M_ManuPlans b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 and b.status=3 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.inDate desc"
			Case 115:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M_ManuOrders b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 and b.status=3 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.inDate desc"
			Case 116:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M_OutOrder b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 and b.status=3 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.inDate desc"
			Case 117:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M_MaterialProgres b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.inDate desc"
			Case 118:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M_QualityTestings b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where b.qtype<>1 and del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.inDate desc"
			Case 119:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M_QualityTestings b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where b.qtype=1 and del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.inDate desc"
			Case 120:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name title,'距离保护到期' + cast(daysFromNow as varchar) + '天' dt,"&_
			"datediff(s,'&actDate&"
			orderBy = "order by daysFromNow asc"
			Case 121:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name title,'下次联系：' + convert(varchar(10),dateadd(d,daysFromNow,'2014-01-01'),23) dt,"&_
			"datediff(s,'&actDate&"
			orderBy = "order by daysFromNow asc"
			Case 122:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_ret_plan b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 123:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_Resume b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.keyword title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 124:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_interview b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],dbo.HrGetResumeName(b.resumeID) title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 125:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_train_plan b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 126:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_expaper b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 127:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_person_salary b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],ISNULL((SELECT TOP 1 name FROM gate  with(nolock) WHERE ord = b.cateid), '用户' + CAST(b.cateid AS varchar(10)) + '【已删】') title,"&_
			"convert(varchar(10),a.inDate,21) dt," &_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 128:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_person_contract b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 129:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_regime b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 130:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_positive b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 131:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_leave b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 132:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_Transfer b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 133:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_off_staff b with(nolock)  on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.gateName title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 134:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_reinstate b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.gateName title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 135:
			Set rs_setting = cn.execute("select workPosition FROM gate  with(nolock) WHERE ord ="& uid &"")
			workPosition = rs_setting("workPosition")
			If Len(workPosition&"") = 0 Then workPosition = 0
			rs_setting.close
			cateCondition = "and (" & vbcrlf &_
			"((spFlag=1 or spFlag=-1) and addcate="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"cateCondition = ""and (""" & vbcrlf &_
			"or ((spFlag=2 or spFlag=3) and cateid_sp=&uid&) /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join document b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"left join power p  with(nolock) on p.ord="& uid &" and sort1=78 and sort2=1 " & vbcrlf &_
			"left join power p1  with(nolock) on p1.ord="& uid &" and p1.sort1=78 and p1.sort2=16 "&_
			"where  del=1 " & vbcrlf &_
			"and (p1.qx_open = 3  OR (CHARINDEX(','+CAST(b.addcate AS VARCHAR(20))+',',','+CAST(p1.qx_intro AS VARCHAR(max))+',') > 0)"& vbcrlf &_
			"where  del=1 " & vbcrlf &_
			"or (b.addcate="& uid &" and  (b.spFlag = 1 or b.spFlag=-1)) "&_
			"where  del=1 " & vbcrlf &_
			" ) "& vbcrlf &_
			"and (p.qx_open = 3 OR (CHARINDEX(','+CAST(b.addcate AS VARCHAR(20))+',',','+CAST(p.qx_intro AS VARCHAR(max))+',') > 0"& vbcrlf &_
			" ) "& vbcrlf &_
			"or  CHARINDEX(','+ CONVERT(varchar(20),"& uid &") +',', ','+isnull(cast(b.share1 as varchar(8000)),0)+',')>0  " & vbcrlf &_
			" ) "& vbcrlf &_
			"or CHARINDEX(','+ CONVERT(varchar(20),"& workPosition &") +',', ','+isnull(cast(b.postDown as varchar(8000)),0)+',')>0  "&_
			" ) "& vbcrlf &_
			"or CHARINDEX(','+ CONVERT(varchar(20),"& workPosition &") +',', ','+isnull(cast(b.postView as varchar(8000)),0)+',')>0  "&_
			" ) "& vbcrlf &_
			"or (b.addcate="& uid &" and  (b.spFlag = 1 or b.spFlag=-1)) "&_
			" ) "& vbcrlf &_
			"or  CHARINDEX(','+ CONVERT(varchar(20),"& uid &") +',', ','+isnull(cast(b.share2 as varchar(8000)),0)+',')>0  ))" & vbcrlf &_
			" ) "& vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate cateid," &_
			"(case when spFlag=1 or spFlag=-1 then 1 else 0 end) canCancelAlt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate cateid," &_
			"datediff(s,'&actDate&"
			orderBy = "order by b.id desc"
			Case 136:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1&""="0" Then
				If qOpen = 3 Then
					cateCondition = ""
				ElseIf qOpen=1 Then
					cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
					tmpCondition = " and (cateid is not null and cateid<>0)"
				else
					cateCondition = " and 1=2"
				end if
			else
				cateCondition = " and cateid=" & uid
			end if
			cateCondition = " " & cateCondition & " " & tmpCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join xunjia b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),b.date7,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date7 desc"
			Case 137:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If m_fw1&""="0" Then
				If qOpen = 3 Then
					cateCondition = ""
				ElseIf qOpen=1 Then
					cateCondition = " and ("_
					&" (addcate is not null and addcate<>0 and addcate in ("&qIntro&")) "_
					&" or (catelead is not null and catelead<>0 and catelead in ("&qIntro&")) "_
					&" or (cate1 is not null and cate1<>0 and cate1 in ("&qIntro&")) "_
					&" or (cate2 is not null and cate2<>0 and cate2 in ("&qIntro&")) "_
					&" or (cate3 is not null and cate3<>0 and cate3 in ("&qIntro&")) "_
					&" or (cate4 is not null and cate4<>0 and cate4 in ("&qIntro&")) "_
					&" or (cate5 is not null and cate5<>0 and cate5 in ("&qIntro&")) "_
					&" or (cate6 is not null and cate6<>0 and cate6 in ("&qIntro&")) "_
					&" or (cate7 is not null and cate7<>0 and cate7 in ("&qIntro&")) "_
					&" or (cate8 is not null and cate8<>0 and cate8 in ("&qIntro&")) "_
					&" or (member1 is not null and member1<>0 and member1 in ("&qIntro&")) "_
					&" or share='0' or charindex(',"&uid&",',','+replace(share,' ','')+',')>0 "_
					&" or (member1 is not null and member1<>0 and member1 in ("&qIntro&")) "_
					&" )"
				else
					cateCondition = " and 1=2"
				end if
			else
				cateCondition = " and ("_
				&" (addcate is not null and addcate<>0 and addcate ="&uid&") "_
				&" or (catelead is not null and catelead<>0 and catelead in ("&uid&")) "_
				&" or (cate1 is not null and cate1<>0 and cate1 in ("&uid&")) "_
				&" or (cate2 is not null and cate2<>0 and cate2 in ("&uid&")) "_
				&" or (cate3 is not null and cate3<>0 and cate3 in ("&uid&")) "_
				&" or (cate4 is not null and cate4<>0 and cate4 in ("&uid&")) "_
				&" or (cate5 is not null and cate5<>0 and cate5 in ("&uid&")) "_
				&" or (cate6 is not null and cate6<>0 and cate6 in ("&uid&")) "_
				&" or (cate7 is not null and cate7<>0 and cate7 in ("&uid&")) "_
				&" or (cate8 is not null and cate8<>0 and cate8 in ("&uid&")) "_
				&" or (member1 is not null and member1<>0 and member1 in ("&uid&")) "_
				&" or share='0' or charindex(',"&uid&",',','+replace(share,' ','')+',')>0 "_
				&" or (member1 is not null and member1<>0 and member1 in ("&uid&")) "_
				&" )"
			end if
			cateCondition = " " & cateCondition & " " & tmpCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tousu b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title,convert(varchar(19),b.date7,"& iif(m_isMobileMode,"21","23") &") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate cateid"
			orderBy = "order by b.date7 desc"
			Case 138:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
				tmpCondition = " and (catein = " & uid & ") "
			ElseIf qOpen=1 Then
				cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
				tmpCondition = " and (catein = " & uid & ") "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & tmpCondition
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join kumove b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid"
			orderBy = "order by b.ord desc"
			Case 139:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.addcate")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=0 or status=4) and addcate="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=1 or status=2) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join maintain b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate cateid," &_
			"(case when status=0 or status=4 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 0 then 11 when 4 then 12 else 10 end) orderStat"
			orderBy = "order by b.ord desc"
			Case 140:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
			else
				cateCondition = " and 1=2"
			end if
			tmpCondition = ""
			If m_fw1&""="0" Then
				tmpCondition = " "
			else
				tmpCondition = " and cateid=" & uid
			end if
			cateCondition = " " & cateCondition & " " & tmpCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join caigou b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title,convert(varchar(10),b.date7,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date7 desc"
			Case 141:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1&""="0" Then
				If qOpen = 3 Then
					cateCondition = ""
				ElseIf qOpen=1 Then
					cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
					tmpCondition = " and (cateid is not null and cateid<>0)"
				else
					cateCondition = " and 1=2"
				end if
			else
				cateCondition = " and cateid=" & uid
			end if
			cateCondition = " " & cateCondition & " " & tmpCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join caigou_yg b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),b.date7,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date7 desc"
			Case 142:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
				tmpCondition = " and (cateout = " & uid & ") "
			ElseIf qOpen=1 Then
				cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
				tmpCondition = " and (cateout = " & uid & ") "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & tmpCondition
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join kumove b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid"
			orderBy = "order by b.ord desc"
			Case 143:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
			else
				cateCondition = " and 1=2"
			end if
			Call fillinPower(24,13,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition &  " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			Call fillinPower(4,14,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition &  " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & tmpCondition
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join price b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del in (3,1) and complete in (1,8)  " & vbcrlf &_
			"where del in (3,1) " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(10),b.date1,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid"
			orderBy = "order by b.ord desc"
			Case 144:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
				tmpCondition = " and (Inspector = " & uid & ") "
			ElseIf qOpen=1 Then
				cateCondition = " and addcate is not null and addcate<>0 and addcate in ("&qIntro&") "
				tmpCondition = " and (Inspector = " & uid & ") "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & tmpCondition
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join caigouqc b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del = 1 and b.complete in (0,1)  " & vbcrlf &_
			"where del =1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate cateid"
			orderBy = "order by b.id desc"
			Case 145:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=0 or status=3) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=1 or status=2) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join budget b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=0 or status=3 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 0 then 11 when 3 then 12 else 10 end) orderStat"
			orderBy = "order by b.ord desc"
			Case 146:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1="0" Then
				tmpCondition = ""
			else
				tmpCondition = " and (cateid=" & uid & ") "
			end if
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and ((cateid is not null and cateid<>0 and cateid in ("&qIntro&")) or share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0) "
'ElseIf qOpen=1 Then
			else
				cateCondition = " and (share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0)"
'ElseIf qOpen=1 Then
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join chance b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title,convert(varchar(19),b.date7,"& iif(m_isMobileMode,"21","23") &") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date7 desc"
			Case 147:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1="0" Then
				tmpCondition = ""
			else
				tmpCondition = " and ((order1=1 or order1=2) and cateid=" & uid & ") "
			end if
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and ((cateid is not null and cateid<>0 and cateid in ("&qIntro&")) or share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0) "
'ElseIf qOpen=1 Then
			else
				cateCondition = " and (share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0)"
'ElseIf qOpen=1 Then
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where del =1 and isnull(sp,0)=0 and sort3=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name [title],convert(varchar(19),b.date2,"& iif(m_isMobileMode,"21","23") &") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = " order by b.date2 desc "
			Case 148:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateadd")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((isnull(status_sp_qualifications,0)=0 or status_sp_qualifications=4) and isnull(cateid,cateadd)="&uid&") " & vbcrlf &_
			"/*审批通过或终止的提醒给采购人员或添加人*/" & vbcrlf &_
			"or " & vbcrlf &_
			"((status_sp_qualifications=1 or status_sp_qualifications=2) and cateid_sp_qualifications="&uid&") " & vbcrlf &_
			"/*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join sortFieldsContent c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.id and c.del = 1 " & vbcrlf &_
			"inner join tel b  with(nolock) on c.ord = b.ord and b.del=1 " & vbcrlf &_
			"where b.del=1 and sort3=2 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "c.id [id],b.name title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateadd cateid," &_
			"(case when isnull(status_sp_qualifications,0)=0 or status_sp_qualifications=4 then 1 else 0 end) canCancelAlt,"&_
			"(case isnull(status_sp_qualifications,0) when 0 then 11 when 4 then 12 else 10 end) orderStat"
			orderBy = "order by b.ord desc"
			Case 149:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateadd")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status_sp_qualifications=0 or status_sp_qualifications=4) and isnull(cateid,cateadd)=" & uid & ") " & vbcrlf &_
			"/*审批通过或终止的提醒给销售人员或添加人*/" & vbcrlf &_
			"or "&_
			"((status_sp_qualifications=1 or status_sp_qualifications=2) and cateid_sp_qualifications=" & uid & ") " & vbcrlf &_
			"/*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join sortFieldsContent c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.id and c.del = 1 " & vbcrlf &_
			"inner join tel b  with(nolock) on c.ord = b.ord and b.del=1 " & vbcrlf &_
			"where b.sort3=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "c.id [id],b.name title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateadd cateid," &_
			"(case when isnull(status_sp_qualifications,0)=0 or status_sp_qualifications=4 then 1 else 0 end) canCancelAlt,"&_
			"(case isnull(status_sp_qualifications,0) when 0 then 11 when 4 then 12 else 10 end) orderStat"
			orderBy = "order by b.ord desc"
			Case 70:
			cateCondition = " @MyPower_1_102 and (" & vbcrlf &_
			"((use_complete=4 or use_complete=3) and use_addcateid="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((use_complete=1 or use_complete=2) and use_cateid_sp="&uid&" @MyPower_16_102) /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				tmpCondition = ""
			ElseIf qOpen=1 Then
				tmpCondition = " and use_addcateid is not null and use_addcateid<>0 and use_addcateid in ("&qIntro&") "
			else
				tmpCondition = " and 1=2"
			end if
			cateCondition = Replace(cateCondition,"@MyPower_1_102",tmpCondition)
			tmpCondition = ""
			cateCondition = Replace(cateCondition,"@MyPower_16_102",tmpCondition)
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join O_carUse b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.use_id and b.use_del=1 " & vbcrlf &_
			"inner join gate g  with(nolock) on b.use_cateid = g.ord " & vbcrlf &_
			"where use_del=1 and use_type=1 and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.use_id [id],g.name title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.use_addcateid cateid," &_
			"(case when use_complete=3 or use_complete=4 then 1 else 0 end) canCancelAlt,"&_
			"(case use_complete when 3 then 11 when 4 then 12 else 10 end) orderStat"
			orderBy = "order by b.use_id desc"
			Case 150:
			cateCondition = " @MyPower_1_102 and (" & vbcrlf &_
			"((status=2 or status=3) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&" @MyPower_16_102) /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				tmpCondition = ""
			ElseIf qOpen=1 Then
				tmpCondition = " and creator is not null and creator<>0 and creator in ("&qIntro&") "
			else
				tmpCondition = " and 1=2"
			end if
			cateCondition = Replace(cateCondition,"@MyPower_1_102",tmpCondition)
			tmpCondition = ""
'cateCondition = Replace(cateCondition,"@MyPower_16_102",tmpCondition)
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_perform_ss b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=2 or status=3 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 151:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1&""="0" Then
				tmpCondition = ""
			else
				tmpCondition = " and cateid=" & uid & " "
			end if
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and ((addcate is not null and addcate<>0 and addcate in ("&qIntro&")) or share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0) "
'ElseIf qOpen=1 Then
			else
				cateCondition = " and (1=2 or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0)"
'ElseIf qOpen=1 Then
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join contract b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 and isnull(b.status,-1) in (-1,1) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"where del =1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title [title],convert(varchar(19),b.date7,"& iif(m_isMobileMode,"21","23") &") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date1 desc,b.date7 desc"
			Case 152:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1&""="0" Then
				tmpCondition = ""
			else
				tmpCondition = " and cateid=" & uid & " "
			end if
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and ((addcate is not null and addcate<>0 and addcate in ("&qIntro&"))) "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join price b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del in (1,3) and complete not in (1,8) " & vbcrlf &_
			"where del in (1,3) " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title [title],convert(varchar(10),b.date7,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date1 desc,b.date7 desc"
			Case 153:
			cateCondition = " @MyPower_1_102 and (" & vbcrlf &_
			"((complete1<>1) and cateid="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (complete1=1 and kg="&uid&" @MyPower_16_102) /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				tmpCondition = ""
			ElseIf qOpen=1 Then
				tmpCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
			else
				tmpCondition = " and 1=2"
			end if
			cateCondition = Replace(cateCondition,"@MyPower_1_102",tmpCondition)
			tmpCondition = ""
'cateCondition = Replace(cateCondition,"@MyPower_16_102",tmpCondition)
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join kumove b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid," &_
			"(case when complete1<>1 then 1 else 0 end) canCancelAlt,"&_
			"(case when complete1=4 or complete1=3 or complete1=5 then 11 when complete1=2 then 12 else 10 end) orderStat"
			orderBy = "order by b.ord desc"
			Case 154:
			tmpCondition = ""
			If m_fw1&""="0" Then
				tmpCondition = ""
			else
				tmpCondition = " and b.cateid=" & uid & " "
			end if
			cateCondition = "and (" & vbcrlf
			Call fillinPower(1,5,qOpen,qIntro)
			cateCondition = cateCondition & " ( b.sort1=1 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(2,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=8 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(3,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=2 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(4,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=3 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(5,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=4 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(22,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=5 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(41,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=6 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(42,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=7 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(75,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=75 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(95,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=102001 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(96,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=102002 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			cateCondition = cateCondition & " ) "
			cateCondition = " and (( 1=1 " & tmpCondition & " " & cateCondition & ") or b.share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(b.share as varchar(8000)),' ','')+',')>0)" & vbcrlf
			cateCondition = cateCondition & " ) "
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join reply b with(nolock)  on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and ISNULL(b.alt,0) = 0 and b.id1 is null " & vbcrlf &_
			"inner join tel t  with(nolock) on t.ord = b.ord and t.del=1 and t.sort3=1 " & vbcrlf &_
			"where b.del =1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],cast(b.intro as varchar(8000)) [title],convert(varchar(19),b.date7,"& iif(m_isMobileMode,"21","23") &") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date7 desc"
			Case 155:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = " and iss_cateid=" & uid & " "
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and ((iss_addcateid is not null and iss_addcateid<>0 and iss_addcateid in ("&qIntro&") and car_addcateid in ("&qIntro&"))) "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join O_insure b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.iss_id and b.iss_del=1 and b.iss_warn = 1 and DATEDIFF(D,GETDATE(),b.iss_endtime)<= "& m_tq1 &" " & vbcrlf &_
			" inner join O_carData c  with(nolock) on c.car_id = b.iss_carid "& vbcrlf &_
			" inner join O_carSet s  with(nolock) on s.setType=3 and s.id=b.iss_type "&_
			"where iss_del =1 and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.iss_id [id],c.car_code+' ('+s.setname+')' title,iss_endtime dt,"&_
			"datediff(s,'&actDate&"
			orderBy = "order by iss_endtime desc"
			Case 157:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and (isnull(t.cateid,u.cateid) is not null and isnull(t.cateid,u.cateid)<>0 and u.cateid in ("&qIntro&")) "
			else
				cateCondition = " and 1=2 "
			end if
			tmpCondition = ""
			If m_fw1&""="2" Then
				tmpCondition = " and (isnull(t.cateid,0)=" & uid & " or isnull(u.cateid,0)=" & uid & ") "
			else
				tmpCondition = " and isnull(u.cateid,0)=" & uid & " "
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from MMsg_User u  with(nolock) " & vbcrlf &_
			"inner join ( " & vbcrlf &_
			"select userid,1 cnt,createtime lastTime from MMsg_Message  with(nolock) " & vbcrlf &_
			"where sendOrReceive = 1 and readed = 0 " & vbcrlf &_
			"and datediff(hh,dateadd(s,createTime,'1970-1-1 0:0:0'),getdate()) < 56 " & vbcrlf &_
			"where sendOrReceive = 1 and readed = 0 " & vbcrlf &_
			") m on u.id=m.userid " & vbcrlf &_
			"left join (" & vbcrlf &_
			"    select p.ord,tl.cateid from person p  with(nolock) " & vbcrlf &_
			"    left join tel tl on tl.ord = p.company " & vbcrlf &_
			") t on u.person=t.ord " & vbcrlf &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [ORDERBY]"
			fields = "u.id [id],u.nickname + '(' + cast(cnt as varchar) + ')' title,dateadd(hh,8,dateadd(s,lastTime,'1970-1-1 0:0:0')) dt,"&_
			"datediff(s,'&actDate&',dateadd(hh,8,dateadd(s,lastTime,'1970-1-1 0:0:0"
'[CATECONDITION] [ORDERBY]
			orderBy = "order by m.lastTime desc"
			Case 219:
			cateCondition =  " AND (charindex(',"& uid &",',','+replace(share,' ','')+',')>0 or b.share='1' or exists(select 1 from noticelist  with(nolock) where notice = b.id and cateid = "& uid &") ) "
'Case 219:
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			" INNER JOIN notice b  with(nolock) ON a.reminderConfig="& configId &" AND a.orderId = b.id AND b.del=1 "& vbcrlf &_
			" where b.del =1 " & vbcrlf &_
			" [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id], b.title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid], b.creator as cateid "
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 220:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND b.Id in ( SELECT mr.Id FROM dbo.caigou_yg mr  with(nolock)   "&_
			"   inner join sp_ApprovalInstance c  with(nolock) on c.gate2=72001 and c.PrimaryKeyID = mr.Id and c.BillPattern in (0,1)  "&_
			"   WHERE mr.del<>2 and ((mr.status in (-1,0,1) and isnull(mr.Cateid,mr.Addcate) =" & uid &") "&_
			"   or (mr.status in (2,4,5) and charindex('," & uid &",',','+ c.SurplusApprover +',')>0))) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN caigou_yg b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"0 canCancelAlt, " &_
			"(case status when -1 then 17 when 0 then 16 when 1 then 11 when 2 then 12 when 3 then 9 when 4 then 10 when 5 then 8 else 10 end) orderStat"
'0 canCancelAlt,  &_
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 17:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1&""="0" Then
				tmpCondition = ""
			else
				tmpCondition = " and ord=" & uid & " "
			end if
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and ((ord is not null and ord<>0 and ord in ("&qIntro&"))) "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join "& vbcrlf &_
			" (select *,(select TOP 1 id from hr_person  with(nolock) where del = 0 AND userid=ord) as id from gate_person where del=1) "& vbcrlf &_
			" b on a.reminderConfig=" & configId & " and a.orderId = b.id and nowStatus not in (2,4) " & vbcrlf &_
			"where b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.name title,date3 dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.ord cateid"
			orderBy = "order by date3 desc"
			Case 156:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If Me.isSupperAdmin Then
				tmpCondition = ""
			else
				tmpCondition = " and 1 = 2 "
			end if
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and ((ord is not null and ord<>0 and ord in ("&qIntro&"))) "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join gate b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where del =1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name title,date3 dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.ord cateid"
			orderBy = "order by date3 desc"
			Case 222:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If sdk.power.existsPower(80,17) Then
				cateCondition = "  "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition =  cateCondition &" AND ((b.DisposeUser=" & uid & " and b.TreatmentStatus = -1) ) "
			cateCondition = " and 1=2"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join HrKQ_AttendanceAppeal b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ID " & vbcrlf &_
			"left join HrKQ_AttendanceType c with(nolock)  on c.onlyid = b.reason " &_
			"where 1 =1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ID [id],c.title title,b.CreateDate dt, datediff(s,'"& actDate &"',a.inDate) newTag,a.id [rid],b.userid cateid"
			orderBy = "order by b.CreateDate desc"
			Case 223 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.createID")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.CreateID="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (4,5) and charindex(',"& uid &",',','+ c.Approver +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.CreateID="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join HrKQ_AttendanceApply b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.isdel=0 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=8 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.CreateDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.createid cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.CreateDate desc"
			Case 52001 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_ManuPlansPre b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=52001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 51005 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_BOM b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=51005 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 54001 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_ManuOrders b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=54001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 54002 :
			Dim qxOpen,qxIntro
			Call fillInPower(m_qxlb,m_listqx,qxOpen,qxIntro)
			If qxOpen = 3 Then
				cateCondition = ""
			ElseIf qxOpen = 1 Then
				cateCondition = " and b.id in (select distinct b.id from reminderQueue a  with(nolock) " & vbcrlf &_
				"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
				"left join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+b.Cateid_WA+',')>0" & vbcrlf &_
				"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" AND plist.sort1 = 54 AND plist.sort2 = 1" & vbcrlf &_
				"where b.del=1 and b.ptype=0 and tempSave=0 and b.[status]<>2" & vbcrlf &_
				"and (plist.qx_open = 3 OR CHARINDEX(','+CAST(g1.ord AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0))"
'where b.del=1 and b.ptype=0 and tempSave=0 and b.[status]<>2 & vbcrlf &_
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c with(nolock) on c.gate2=54002 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 54003 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_OutOrder b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=54003 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 52002 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_ManuPlans b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=52002 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 55001 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_MaterialOrders b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and b.MaterialType in (1,2) " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=55001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 55006 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_MaterialOrders b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and b.MaterialType = 3 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=55006 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 56001 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.Approver +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_PriceRate b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=56001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 55002 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_MaterialRegisters b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and b.OrderType = 2 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=55002 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 55003 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_MaterialRegisters b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and b.OrderType = 3 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=55003 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 56007 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.Approver +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_TimeWages b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=56007 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 56008 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.Approver +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_Wage_JS b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c with(nolock)  on c.gate2=56008 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 160 :
			cateCondition =  " AND "& uid &"=b.cateid "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			" INNER JOIN M2_RewardPunish b  with(nolock) ON a.reminderConfig="& configId &" AND a.orderId = b.id AND b.del=1 "& vbcrlf &_
			" where b.del =1 " & vbcrlf &_
			" [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id], b.title,convert(varchar(10),b.RPdate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid], b.creator as cateid "
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 54007:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and M2WFPA.id in (select  M2WFPA.id from reminderQueue a  with(nolock) " & vbcrlf &_
				"inner join (SELECT M2WFPA.ID FROM M2_WFP_Assigns M2WFPA  with(nolock) " & vbcrlf &_
				"left join erp_Gxdqtx_status M2WA  with(nolock) on M2WFPA.WAID = M2WA.ID and M2WA.del = 1 and M2WA.tempSave = 0 " & vbcrlf &_
				"left join M2_WorkingProcedures M2WP  with(nolock) on M2WP.ID = M2WFPA.WPID  " & vbcrlf &_
				"left join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+isnull(M2WFPA.cateid,'')+','+isnull(M2WA.Cateid_WA,'')+','+isnull(M2WP.Wheelman,'')+',')>0  " & vbcrlf &_
				"left join M2_WorkingProcedures M2WP  with(nolock) on M2WP.ID = M2WFPA.WPID  " & vbcrlf &_
				"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" and plist.sort1=5031 AND plist.sort2=1" & vbcrlf &_
				" where M2WFPA.del=1 and isnull(M2WFPA.isOut,0)=0  and tempSave=0 " & vbcrlf &_
				" AND (plist.qx_open = 3 or dbo.existsPower2(plist.qx_intro, isnull(M2WFPA.cateid, '') + ',' + isnull(M2WA.Cateid_WA, ''), ',') = 1) "& vbcrlf &_
				" where M2WFPA.del=1 and isnull(M2WFPA.isOut,0)=0  and tempSave=0 " & vbcrlf &_
				" AND M2WA.[Status]<>2  AND M2WA.wastatus!='生产完毕' AND ISNULL(M2WA.SPStatus,-1) IN(-1,1)"& vbcrlf &_
				" where M2WFPA.del=1 and isnull(M2WFPA.isOut,0)=0  and tempSave=0 " & vbcrlf &_
				" AND ISNULL(M2WFPA.Finished, 0) = 0"& vbcrlf &_
				" AND NOT EXISTS(SELECT 1 FROM M2_CostComputation  with(nolock) WHERE complete1=1 and datediff(mm,date1,M2WA.DateStart)=0)  GROUP BY M2WFPA.ID)  M2WFPA  ON  a.reminderConfig= " & configId & "  and a.orderId = M2WFPA.id) "
			else
				cateCondition = " and 1=2"
			end if
			If m_fw1&""="1" Then
				tmpCondition = " and charindex(','+cast(" & uid & " as varchar(12))+',',','+isnull(M2WFPA.cateid,'')+','+isnull(M2WA.Cateid_WA,'')+','+isnull(M2WP.Wheelman,'')+',')>0"
'If m_fw1&""="1" Then
			else
				tmpCondition = " and (plist.qx_open = 3  OR CHARINDEX(','+CAST(g1.ord AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0)"
'If m_fw1&""="1" Then
			end if
			cateCondition =  " " & tmpCondition & " " & cateCondition & " and datediff(d,getdate(),M2WFPA.dateEnd)<=" & m_tq1 & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join (SELECT  M2WFPA.id,M2WA.title,M2WP.WPName,M2WFPA.DateEnd,M2WFPA.cateid,M2WA.indate  from M2_WFP_Assigns M2WFPA   with(nolock)    " & vbcrlf &_
			"left join erp_Gxdqtx_status M2WA  with(nolock) on M2WFPA.WAID = M2WA.ID and M2WA.del = 1 and M2WA.tempSave = 0  " & vbcrlf &_
			"left join M2_WorkingProcedures M2WP  with(nolock) on M2WP.ID = M2WFPA.WPID   " & vbcrlf &_
			"left join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+isnull(M2WFPA.cateid,'')+','+isnull(M2WA.Cateid_WA,'')+','+isnull(M2WP.Wheelman,'')+',')>0 " & vbcrlf &_
			"left join M2_WorkingProcedures M2WP  with(nolock) on M2WP.ID = M2WFPA.WPID   " & vbcrlf &_
			"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" and plist.sort1=5031 AND plist.sort2=1 " & vbcrlf &_
			"WHERE  M2WFPA.del=1 and isnull(M2WFPA.isOut,0)=0  and charindex(','+cast(" & uid & " as varchar(12))+',',','+isnull(M2WFPA.cateid,'')+','+isnull(M2WA.Cateid_WA,'')+','+isnull(M2WP.Wheelman,'')+',')>0 and tempSave=0 " & vbcrlf &_
			" AND M2WA.[Status]<>2  AND M2WA.wastatus!='生产完毕' AND ISNULL(M2WA.SPStatus,-1) IN(-1,1) "& vbcrlf &_
			" AND ISNULL(M2WFPA.Finished, 0) = 0"& vbcrlf &_
			" AND NOT EXISTS(SELECT 1 FROM M2_CostComputation  with(nolock) WHERE complete1=1 and datediff(mm,date1,M2WA.DateStart)=0) "& vbcrlf &_
			"[CATECONDITION]  "& vbcrlf &_
			" GROUP BY  M2WFPA.id,M2WA.title,M2WP.WPName,M2WFPA.DateEnd,M2WFPA.cateid,M2WA.indate) M2WFPA ON  a.reminderConfig=" & configId & " and a.orderId = M2WFPA.id  "& vbcrlf &_
			"[CANCELCONDITION] [ORDERBY]"
			fields = "M2WFPA.id,isnull(M2WFPA.title,'')+'['+ISNULL(M2WFPA.WPName,'')+']' as title ,convert(varchar(10),M2WFPA.DateEnd,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],M2WFPA.cateid"
'[CANCELCONDITION] [ORDERBY]
			orderBy = "order by M2WFPA.indate desc"
			Case 540071:
			tmpCondition = ""
			cateCondition = ""
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WFP_Assigns wfpa  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = wfpa.id and wfpa.del=1 and isnull(wfpa.ExecTask,0) = 1 " & vbcrlf &_
			"inner join M2_WorkAssigns wa  with(nolock) on wfpa.waid = wa.id and wa.del=1 " & vbcrlf &_
			"inner join M2_WorkingProcedures wp  with(nolock) on wfpa.wpid = wp.id and wp.del=1 " & vbcrlf &_
			"where 1=1 and (dbo.existsPower2(wp.wheelman,'" & uid & "',',') = 1 or dbo.existsPower2(wfpa.cateid,'" & uid & "',',') = 1)" & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "wfpa.id [id],wa.title+'('+wp.WPName+')' as title,wa.inDate dt,datediff(s,'"&actDate&"',wa.inDate) newTag,a.id [rid],(wa.Cateid_WA+','+wp.wheelman+','+wfpa.cateid) cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by wa.inDate desc"
			Case 540072:
			tmpCondition = ""
			cateCondition = ""
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WFPTask_Assigns task  with(nolock) on a.reminderConfig=""" & configId & " and a.orderId = task.id and task.beginStatus = 0 and not exists(select top 1 1 from M2_ProcedureProgres  with(nolock) where del = 1 and TaskID = task.ID) and dbo.existsPower2(task.cateid,'" & uid & "',',') = 1" & vbcrlf &_
			"inner join M2_WFP_Assigns wfpa  with(nolock) on task.wfpaid = wfpa.id and wfpa.del=1 " & vbcrlf &_
			"inner join M2_WorkAssigns wa  with(nolock) on wfpa.waid = wa.id and wa.del=1 " & vbcrlf &_
			"inner join M2_WorkingProcedures wp  with(nolock) on wfpa.wpid = wp.id and wp.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "task.id [id],wa.title+'('+wp.WPName+')' as title,task.inDate dt,datediff(s,'"&actDate&"',task.inDate) newTag,a.id [rid],(wa.Cateid_WA+','+wp.wheelman+','+wfpa.cateid) cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by task.inDate desc"
			Case 540073:
			tmpCondition = ""
			cateCondition = ""
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join (" & vbcrlf &_
			"   select isnull(batchid,id) id,indate,creator,wfpaid from M2_ProcedureProgres with(nolock) " & vbcrlf &_
			"   where del = 1 and checkresult = 2 and CheckPerson = "& uid &_
			"   group by isnull(batchid,id),indate,creator,wfpaid" & vbcrlf &_
			") aa on a.reminderConfig =  " & configId & " and a.orderId = aa.id" & vbcrlf &_
			"inner join M2_WFP_Assigns wfpa  with(nolock) on aa.wfpaid = wfpa.id and wfpa.del=1 " & vbcrlf &_
			"inner join M2_WorkAssigns wa  with(nolock) on wa.id = wfpa.waid " & vbcrlf &_
			"inner join M2_WorkingProcedures wp  with(nolock) on wfpa.wpid = wp.id and wp.del=1" & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "aa.[id],wa.title+'('+wp.WPName+')' as title,aa.inDate dt,datediff(s,'"&actDate&"',aa.inDate) newTag,a.[id] [rid],(wa.Cateid_WA+','+wp.wheelman+','+wfpa.cateid+','+cast(aa.Creator as varchar(20))) cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by aa.inDate desc"
			Case 51001:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			cateCondition = " and charindex(','+CAST(" & uid & " as varchar(10))+',',','+replace(CONVERT(VARCHAR(8000),remindPerson),' ','')+',')>0 " &_
			"AND DATEDIFF(d, GETDATE() ,(CASE remindunit WHEN 1 THEN DATEADD(HOUR,remindcyc,begindate)  " &_
			"  WHEN 2 THEN DATEADD(DAY,remindcyc,begindate) END))<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_MachineComponent b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id,b.title,convert(varchar(10),(CASE remindunit WHEN 1 THEN DATEADD(HOUR,remindcyc,begindate) "  &_
			"  WHEN 2 THEN DATEADD(DAY,remindcyc,begindate) END),23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.remindPerson as cateid"
			orderBy = "order by (CASE remindunit WHEN 1 THEN DATEADD(HOUR,remindcyc,begindate) "  &_
			"  WHEN 2 THEN DATEADD(DAY,remindcyc,begindate) END) desc,b.indate desc"
			Case 55004 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_MaterialRegisters b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and b.OrderType = 1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=55004 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.date1 dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.date1 desc"
			Case 51011:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			cateCondition = " and charindex(','+CAST(" & uid & " as varchar(10))+',',','+replace(CONVERT(VARCHAR(8000),cateid),' ','')+',')>0 " &_
			"AND DATEDIFF(d, GETDATE() ,(CASE Unit2 WHEN 0 THEN DATEADD(MINUTE,num2,date1) " &_
			"  WHEN 1 THEN DATEADD(HOUR,num2,date1) WHEN 2 THEN DATEADD(DAY,num2,date1) WHEN 3 THEN DATEADD(MONTH,num2,date1) " &_
			"  WHEN 4 THEN DATEADD(YEAR,num2,date1) end))<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_maintain b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id,b.title,convert(varchar(10),(CASE Unit2 WHEN 0 THEN DATEADD(MINUTE,num2,date1) " & vbcrlf &_
			"  WHEN 1 THEN DATEADD(HOUR,num2,date1) WHEN 2 THEN DATEADD(DAY,num2,date1) WHEN 3 THEN DATEADD(MONTH,num2,date1) " & vbcrlf &_
			"  WHEN 4 THEN DATEADD(YEAR,num2,date1) end),23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by (CASE Unit2 WHEN 0 THEN DATEADD(MINUTE,num2,date1) " & vbcrlf &_
			"  WHEN 1 THEN DATEADD(HOUR,num2,date1) WHEN 2 THEN DATEADD(DAY,num2,date1) WHEN 3 THEN DATEADD(MONTH,num2,date1) " & vbcrlf &_
			"  WHEN 4 THEN DATEADD(YEAR,num2,date1) end) desc,b.indate desc"
			Case 54013:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If m_fw1&""="1" Then
				tmpCondition = " AND b.ourperson="& uid &""
			end if
			cateCondition = " where isnull(ool.Mergeinx,0)>=0 " & tmpCondition & " AND (plist.qx_open = 3  OR CHARINDEX(','+CAST(b.ourperson AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0) AND DATEDIFF(d, GETDATE() ,DateDelivery)<=" & m_tq1
			tmpCondition = " AND b.ourperson="& uid &""
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			"inner join M2_OutOrder b  with(nolock) on b.wwType=0 and  a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"inner join M2_OutOrderlists ool  with(nolock) on ool.outID = b.ID " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"left join dbo.power plist  with(nolock) ON plist.ord = & uid & AND plist.sort1 = 5025 AND plist.sort2 = 1" & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id,b.title,convert(varchar(10),ool.DateDelivery,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by ool.DateDelivery desc,b.indate desc"
			Case 54016:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If m_fw1&""="1" Then
				tmpCondition = " AND b.ourperson="& uid &""
			end if
			cateCondition = " where isnull(ool.Mergeinx,0)>=0 " & tmpCondition & " AND (plist.qx_open = 3  OR CHARINDEX(','+CAST(b.ourperson AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0) AND DATEDIFF(d, GETDATE() ,DateDelivery)<=" & m_tq1
'tmpCondition = " AND b.ourperson="& uid &""
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			"inner join M2_OutOrder b  with(nolock) on b.wwType=1 and a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"inner join M2_OutOrderlists ool  with(nolock) on ool.outID = b.ID " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" AND plist.sort1 = 5026 AND plist.sort2 = 1" & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id,b.title,convert(varchar(10),ool.DateDelivery,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by ool.DateDelivery desc,b.indate desc"
			Case 54006:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a   with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_OutOrder b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=54006 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 51003 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WorkingFlows b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=51003 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.WFName,b.indate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.indate desc"
			Case 51005 :
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_BOM b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=51005 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 54009:
			Call fillinPower(m_qxlb,m_listqx,qOpen,"b.creator")
			cateCondition = cateCondition &" and CKUser ="& uid &_
			"   and ool.QTResult>0 and isnull(b.CkStatus,0)=0  AND DATEDIFF(d, GETDATE() ,QTDate)<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_QualityTestings b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"inner join (select QTID,sum(QTResult) QTResult from M2_QualityTestingLists  with(nolock) where del=1 group by QTID) ool on ool.QTID = b.ID " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id,b.title,convert(varchar(10),b.QTDate,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.QTDate desc"
			Case 54004:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition =cateCondition & " and CKUser ="& uid &_
			" and ool.QTResult>0 and isnull(b.CkStatus,0)=0 AND DATEDIFF(d, GETDATE() ,QTDate)<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_QualityTestings b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"inner join (select QTID,sum(QTResult) QTResult from M2_QualityTestingLists  with(nolock) where del=1 group by QTID) ool on ool.QTID = b.ID " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id,b.title,convert(varchar(10),b.QTDate,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.QTDate desc"
			Case 57004:
			tmpCondition = ""
			cateCondition = ""
			sql = "select COUNT(*) REMIND_CNT from (" & vbcrlf &_
			" SELECT t.ID,t.Title,t.TaskDate,t.Creator,tl.QcCateid FROM dbo.M2_GXQualityTestingTask t  with(nolock) " & vbcrlf &_
			" INNER JOIN dbo.M2_GXQualityTestingTaskList tl  with(nolock) ON t.ID = tl.TaskID " & vbcrlf &_
			" WHERE tl.QCStatus != 2 GROUP BY t.ID,t.Title,t.TaskDate,t.Creator,tl.QcCateid " & vbcrlf &_
			" ) a " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"where a.QcCateid ="& uid &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "a.ID [id],a.Title as title,a.TaskDate as dt,a.TaskDate as newTag,a.ID [rid],a.Creator cateid"
			orderBy = "order by a.TaskDate desc"
			Case 56004 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_Wage_JJ b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=56004 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.CountDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 56008 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_Wage_JS b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=56008 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.CountDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 45001:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(b.[status] in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (b.[status] in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(b.[status] in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join bankin b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=45001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),b.date3 ,120) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.date7 desc"
			Case 45002:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(b.[status] in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (b.[status] in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(b.[status] in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join bankout b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=45002 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),b.date3 ,120) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.date7 desc"
			Case 47003:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and b.id in (select distinct b.id from reminderQueue a  with(nolock) " & vbcrlf &_
				"inner join AcceptanceDraft b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
				"left join gate g1  with(nolock) on g1.ord = b.creator" & vbcrlf &_
				"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" AND plist.sort1 = 1101 AND plist.sort2 = 1" & vbcrlf &_
				"where b.del=1" & vbcrlf &_
				"and (plist.qx_open = 3 OR CHARINDEX(','+CAST(g1.ord AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0))"
			else
				cateCondition = " and 1=2"
			end if
			If m_fw1&""="1" Then
				tmpCondition = " and "& uid &" = creator"
			end if
			cateCondition =  " " & tmpCondition & " " & cateCondition & " and datediff(d,getdate(),b.LimitEndDate)<=" & m_tq1 & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join AcceptanceDraft b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"where b.del=1" &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id,b.sn title ,b.LimitEndDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.LimitEndDate"
			Case Else :
			sql = ""
			fields = ""
			End Select
			If withoutOrderBy Then
				sql = Replace(sql,"[ORDERBY]","")
			end if
			If mode = "cnt" Then
				sql = Replace(sql,"[ORDERBY]","")
			ElseIf mode = "top" Then
				sql = Replace(Replace(sql,"COUNT(*) REMIND_CNT","top " & (m_num1) & " " & fields),"[ORDERBY]", orderBy)
			ElseIf mode = "all" Then
				sql = Replace(Replace(sql,"COUNT(*) REMIND_CNT",fields),"[ORDERBY]", orderBy)
			ElseIf mode = "ids" Then
				fields = Split(fields,"[id],")(0)
				sql = Replace(Replace(sql,"COUNT(*) REMIND_CNT","top 100 percent " & fields & "id"),"[ORDERBY]", orderBy)
			ElseIf mode = "rids" Then
				fields = Split(fields,",")
				Dim findFlag
				findFlag = False
				For i = 0 To ubound(fields)
					If InStr(1,fields(i),"[rid]",1)>0 Then
						sql = Replace(Replace(sql,"COUNT(*) REMIND_CNT","top 100 percent " & fields(i)),"[ORDERBY]", orderBy)
						findFlag = True
						Exit For
					end if
				next
				If findFlag = False Then
					Response.write "sql语句里面缺少rid字段，无法提取该字段的语句"
					Response.end
				end if
			else
				Response.write "不支持的模式参数"
				Response.end
			end if
			If withoutCateCondition Then
				sql = Replace(sql,"[CATECONDITION]","")
			else
				sql = Replace(sql,"[CATECONDITION]",cateCondition)
			end if
			If withoutCancelCondition Then
				sql = Replace(Replace(sql,"[CANCELCONDITION]",""),"[CANCELJOINTABLE]","")
			else
				sql = Replace(Replace(sql,"[CANCELCONDITION]",cancelCondition),"[CANCELJOINTABLE]",cancelJoinTable)
			end if
			listSQL = sql
		end function
		Public Property Get remindCount
		Dim sql,rs
		If isEmpty(m_remindCount) Then
			If m_hasModule = False Then
				m_remindCount = 0
			else
				If isCleanMode Then
					sql = "select count(*) from reminderQueue a  with(nolock) "&_
					"inner join (" & listSQL("all_withoutCateCondition_withoutOrderBy_withoutCancelCondition") & ") b on a.id=b.rid " &_
					"where datediff(s,a.inDate,'"&dateBegin&"')>=0"
				else
					sql = listSQL("cnt")
				end if
				If displaySqlOnCount = true Then
					Response.write "<div style='border:1px solid red'>"&_
					"m_name&""(""&configId&"")---remindCount:<br>""&Replace(server.HTMLEncode(sql),vbcrlf,""<br>"")&""""&_"
					Response.write "<div style='border:1px solid red'>"&_
					"</div>"
				end if
				on error resume next
				Err.clear
				If m_usingLv2Cache And isCleanMode <> True Then
					m_remindCount = CLng(m_cacheHelper.GetCacheRecord(sql,m_cacheExpiredCondition,True,True,uid&"-"&configId&"-"&m_subCfgId&"-count")(0))
'If m_usingLv2Cache And isCleanMode <> True Then
				else
					m_remindCount = CLng(Me.cn.execute(sql)(0))
				end if
				If Err.number <> 0 Then
					Response.Clear()
					Response.write "提醒【"&m_name&"("&configId&")】读取过程中，以下语句执行错误：<br><hr>"
					Response.write Replace(server.HTMLEncode(sql),vbcrlf,"<br>") & "<hr>" & _
					"cacheExpiredCondition:<br>" & Replace(m_cacheExpiredCondition,vbcrlf,"<br>")
					Response.end
				end if
				On Error GoTo 0
			end if
		end if
		remindCount = m_remindCount
		End Property
		Public Sub remindShow
			If m_hasModule = False Then Exit Sub
			on error resume next
			Dim rs,sql,i,j
			Set rs = server.CreateObject("adodb.recordset")
			If isCleanMode Then
				If pageIndex < 1 Then pageIndex = 1
				sql = "select b.*,convert(varchar(19),a.inDate,21) inDate from reminderQueue a  with(nolock) "&_
				"inner join (" & listSQL("all_withoutCateCondition_withoutCancelCondition_withoutOrderBy") & ") b on a.id=b.rid "&_
				"where datediff(s,a.inDate,'"&dateBegin&"')>=0"
				rs.open sql,cn,1,1
				recCount = rs.RecordCount
				rs.PageSize = pageSize
				pageCount = rs.pageCount
				If CLng(pageIndex) > CLng(pageCount) Then pageIndex = pageCount
				If rs.eof = False Then
					rs.AbsolutePage = pageIndex
				end if
				If Err.number <> 0 Then
					Response.Clear()
					Response.write "提醒【"&m_name&"("&configId&")】读取过程中，以下语句执行错误：<br><hr>"
					Response.write Replace(server.HTMLEncode(sql),vbcrlf,"<br>") & "<hr>" & _
					"cacheExpiredCondition:<br>" & Replace(m_cacheExpiredCondition,vbcrlf,"<br>")
					Response.end
				end if
			else
				sql = listSQL("top")
				If m_usingLv2Cache Then
					Set rs = m_cacheHelper.GetCacheRecord(sql,m_cacheExpiredCondition,True,True,uid&"-"&configId&"-"&m_subCfgId&"list")
'If m_usingLv2Cache Then
				else
					rs.open sql,cn,1,1
				end if
				If Err.number <> 0 Then
					Response.Clear()
					Response.write "提醒【"&m_name&"("&configId&")】读取过程中，以下语句执行错误：<br><hr>"
					Response.write Replace(server.HTMLEncode(sql),vbcrlf,"<br>") & "<hr>" & _
					"cacheExpiredCondition:<br>" & Replace(m_cacheExpiredCondition,vbcrlf,"<br>")
					Response.end
				end if
			end if
			If displaySqlOnShow = true Then
				Response.write "<div style='border:1px solid red'>"&_
				"m_name&""(""&configId&"")---remindShow:<br>""&Replace(server.HTMLEncode(sql),vbcrlf,""<br>"")&""""&_"
				Response.write "<div style='border:1px solid red'>"&_
				"</div>"
			end if
			Response.write "" & vbcrlf & "             <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" " & vbcrlf & "                 "
			Response.write IIf(isCleanMode,"style='table-layout:fixed;'","")
			Response.write " bgcolor=""#C0CCDD"" class=""reminder home detailTable"" " & vbcrlf & "                    cfgId="""
			Response.write configId
			Response.write """ subId="""
			Response.write m_subCfgId
			Response.write """>" & vbcrlf & "                "
			If isCleanMode <> True Then
				Response.write "" & vbcrlf & "                     <tr class=""top tbheader OnlyHeader"">" & vbcrlf & "                              <td colspan=""2"" valign=""center"" height=""30"" onMouseOut=""RemObj.toggleBar(this,false);"" onmouseover=""RemObj.toggleBar(this,true);"">" & vbcrlf & "                                        <span style=""float:left"">"
				Response.write m_name
				Response.write "(<a href="""
				Response.write moreLinkURL()
				Response.write """ style='color:red'>"
				Response.write remindCount
				Response.write "</a>)</span>" & vbcrlf & "                                 <span class=""alt_title"" style=""float:left;display:none;"">" & vbcrlf & "                                           <a href=""javascript:void(0)"" onclick=""altChgOrder("
				Response.write m_setjmId
				Response.write ","
				Response.write m_subCfgId
				Response.write ",1,this)"" title=""左移"">←</a>" & vbcrlf & "                                               <a href=""javascript:void(0)"" onclick=""altChgOrder("
				Response.write m_setjmId
				Response.write ","
				Response.write m_subCfgId
				Response.write ",2,this)"" title=""上移"">↑</a>" & vbcrlf & "                                               <a href=""javascript:void(0)"" onclick=""altChgOrder("
				Response.write m_setjmId
				Response.write ","
				Response.write m_subCfgId
				Response.write ",3,this)"" title=""下移"">↓</a>" & vbcrlf & "                                               <a href=""javascript:void(0)"" onclick=""altChgOrder("
				Response.write m_setjmId
				Response.write ","
				Response.write m_subCfgId
				Response.write ",4,this)"" title=""右移"">→</a>" & vbcrlf & "                                               <a href=""javascript:void(0)"" onclick=""altChgOrder("
				Response.write m_setjmId
				Response.write ","
				Response.write m_subCfgId
				Response.write ",5,this)"" title=""关闭"">×</a>" & vbcrlf & "                                       </span>" & vbcrlf & "                                 <span style=""float:right;"">"
				Response.write getMoreLink()
				Response.write "</span>" & vbcrlf & "                      "
				If m_remindMode = "CYCLE" Then
					Response.write "" & vbcrlf & "                                     <span class=""alt_refreshBtn"" style=""float:right;padding-right:10px;"">" & vbcrlf & "                                               <img src=""../images/refresh.png"" class=""alt_refreshImg"" border=""0"" width=""12px"" alt=""手动更新""" & vbcrlf & "                                                    style=""cursor:pointer;"" onclick=""RemObj.refresh("
'If m_remindMode = "CYCLE" Then
					Response.write m_setjmId
					Response.write ","
					Response.write m_subCfgId
					Response.write ",this);""/>" & vbcrlf & "                                        </span>" & vbcrlf & "                                 <span class=""alt_refreshTime"" style=""float:right;font-weight:normal;padding-right:10px;"">上次更新："
					Response.write m_subCfgId
					Response.write m_lastReloadDate
					Response.write "</span>" & vbcrlf & "                                      "
				end if
				Response.write "" & vbcrlf & "                             </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
			Else
				Response.write "" & vbcrlf & "                     <tr class=""top"">" & vbcrlf & "                          <td width=""36"">&nbsp;</td>" & vbcrlf & "                                <td>主题</td>" & vbcrlf & "                           <td width=""150"">添加时间</td>" & vbcrlf & "                             <td width=""150"" style=""text-align:center"">" & vbcrlf & "                                  <select onchange=""loadList("
'Else
				Response.write pageIndex
				Response.write ",this.value);"">" & vbcrlf & "                                           <option value=""10"" "
				Response.write IIf(pageSize=10," selected","")
				Response.write ">每页显示10条</option>" & vbcrlf & "                                               <option value=""20"" "
				Response.write IIf(pageSize=20," selected","")
				Response.write ">每页显示20条</option>" & vbcrlf & "                                               <option value=""30"" "
				Response.write IIf(pageSize=30," selected","")
				Response.write ">每页显示30条</option>" & vbcrlf & "                                               <option value=""50"" "
				Response.write IIf(pageSize=50," selected","")
				Response.write ">每页显示50条</option>" & vbcrlf & "                                               <option value=""100"" "
				Response.write IIf(pageSize=100," selected","")
				Response.write ">每页显示100条</option>" & vbcrlf & "                                              <option value=""200"" "
				Response.write IIf(pageSize=200," selected","")
				Response.write ">每页显示200条</option>" & vbcrlf & "                                      </select>" & vbcrlf & "                               </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
			end if
			i = 0
			If rs.eof Then
				If remindCount > 0 Then
					Response.write "" & vbcrlf & "                     <tr><td colspan=""4"" align=""center"">您设置的显示行数为0，无信息可显示</td></tr>" & vbcrlf & "                      "
				else
					Response.write "" & vbcrlf & "                     <tr><td colspan=""4"" style=""height:107px"" align=""center"">没有信息！</td></tr>" & vbcrlf & "                  "
				end if
			else
				While rs.eof = False And ((isCleanMode = True And i < pageSize) Or isCleanMode = False)
					Response.write "" & vbcrlf & "                     <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                           "
					If isCleanMode = True Then
						Response.write "<td><input type='checkbox' class='delRids' value='" & rs("rid") & "'/></td>" & vbcrlf
					end if
					Response.write "" & vbcrlf & "                             <td class=""name"" width=""57%"">"
					Response.write getTitleHTML(rs)
					Response.write "</td>" & vbcrlf & "                                <td align=""center"">"
					Response.write getDtHTML(rs)
					Response.write "</td>" & vbcrlf & "                                "
					If isCleanMode = True Then
						Response.write "" & vbcrlf & "                             <td align=""center""><input type=""button"" onclick=""dropRemind("
						Response.write rs("rid")
						Response.write ");"" value=""清理此提醒"" class=""anybutton2""/></td>" & vbcrlf & "                              "
					end if
					Response.write "" & vbcrlf & "                     </tr>" & vbcrlf & "                           "
					i=i+1
					Response.write "" & vbcrlf & "                     </tr>" & vbcrlf & "                           "
					rs.movenext
				wend
			end if
			If  isCleanMode <> True Then
				If remindCount > 0 Then
					For j=i To m_num1 - 1
'If remindCount > 0 Then
						Response.write "<tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">"&_
						"<td class=""name"" colspan=""4"">&nbsp;</td>"&_
						"</tr>"
					next
				end if
			else
				Response.write "" & vbcrlf & "                     <tr>" & vbcrlf & "                            <td><input type='checkbox' onclick=""checkAll(this);""/></td>" & vbcrlf & "                               <td colspan=""3"" align=""right"">" & vbcrlf & "                                      <table style=""width:100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "                                           <tr>" & vbcrlf & "                                                    <td width=""100px"">" & vbcrlf & "                                                             <input type=""button"" value=""批量清理"" class=""anybutton2"" onclick=""dropRemind();""/>" & vbcrlf & "                                                      </td>" & vbcrlf & "                                                   <td align=""right"">" & vbcrlf & "                                                                共"
				Response.write recCount
				Response.write "条&nbsp;"
				Response.write pageSize
				Response.write "/页&nbsp;"
				Response.write pageIndex
				Response.write "/"
				Response.write pageCount
				Response.write "页" & vbcrlf & "                                                             <input type=""text"" id=""jppgidx"" style=""width:40px"" maxlength=""8"" value="""
				Response.write pageIndex
				Response.write """ " & vbcrlf & "                                                                  onfocus=""this.select();""" & vbcrlf & "                                                                  onkeydown=""pageKeyup(this);""" & vbcrlf & "                                                                      title=""按回车可翻页""" & vbcrlf & "                                                              />" & vbcrlf & "                                                              <input type=""button"" value=""跳转"" class=""page"" onclick=""if(!isNaN($('#jppgidx').val())) loadList($('#jppgidx').val(),"
				Response.write pageSize
				Response.write ")""/>" & vbcrlf & "                                                               <input type=""button"" value=""首页"" class=""page"" onclick=""loadList("
				Response.write 1&","&pageSize
				Response.write ");""/>" & vbcrlf & "                                                              <input type=""button"" value=""上页"" class=""page"" onclick=""loadList("
				Response.write (pageIndex-1)&","&pageSize
				Response.write ");""/>" & vbcrlf & "                                                              <input type=""button"" value=""下页"" class=""page"" onclick=""loadList("
				Response.write (pageIndex+1)&","&pageSize
				Response.write ");""/>" & vbcrlf & "                                                              <input type=""button"" value=""尾页"" class=""page"" onclick=""loadList("
				Response.write pageCount&","&pageSize
				Response.write ");""/>" & vbcrlf & "                                                      </td>" & vbcrlf & "                                           </tr>" & vbcrlf & "                                   </table>" & vbcrlf & "                                </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
			end if
			Response.write "" & vbcrlf & "              </table>" & vbcrlf & "                "
			If Err.number<>0 Then
				dim errtxt
				errtxt = err.Description
				if instr(errtxt,"未找到项目")>0 then
					errtxt = errtxt & " <br>sql查询需要提供【rid】,【cateid】,【title】,【newTag】列，请检查SQL是否正确支持。"
				end if
				Response.write Replace("以下语句执行错误：<br>" & server.HTMLEncode(sql) & "<div style='padding:10px;background-color:#ffff00'>错误提示语：" & errtxt & "</div>", vbcrlf , "<br>")
				errtxt = errtxt & " <br>sql查询需要提供【rid】,【cateid】,【title】,【newTag】列，请检查SQL是否正确支持。"
				cn.close
				Response.end
			end if
		end sub
		Public Function getTitleHTML(ByRef rs)
			Dim ttArr,ttStr
			Select Case m_setjmId
			Case 7:
			ttArr = Split(rs("title"),Chr(11)&Chr(12))
			If m_isMobileMode Then
				getTitleHTML = getTitleHTML & ttArr(0)'rs("title")
			else
				getTitleHTML = getTitleHTML & "<span style='float:left;color:#5b7cae'>"&getTitleLink(ttArr(0),rs("id"),rs("cateid")) & "</span>"
				getTitleHTML = getTitleHTML & "<span style='float:right;'>("&ttArr(1)&")</span>"
			end if
			Case 225:
			Dim showTitle2
			showTitle2 = rs("title")
			If InStr(rs("title"),"@code:") > 0 Then
				showTitle2 = eval(REPLACE(rs("title"),"@code:",""))
			end if
			If m_isMobileMode Then
				getTitleHTML = getTitleHTML & showTitle2
			else
				getTitleHTML = getTitleHTML & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
				getTitleHTML = getTitleHTML & "     <tr>"&_
				"<td style=""background-Color:transparent;"">" &_
				"getTitleLink(showTitle2,rs(""id""),rs(""cateid""))" &_
				"<span style='float:right;'>"&rs("WorkLong")&"小时</span>" &_
				"IIf(rs(""newTag"")>=0,""<span class='alt_tx'></span>"","""")" &_
				"</td>" &_
				"</table>"
			end if
			Case Else:
			Dim showTitle
			showTitle = rs("title")
			If InStr(rs("title"),"@code:") > 0 Then
				showTitle = eval(REPLACE(rs("title"),"@code:",""))
			end if
			If m_isMobileMode Then
				getTitleHTML = getTitleHTML & showTitle
			else
				getTitleHTML = getTitleHTML & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
				getTitleHTML = getTitleHTML & "     <tr>"&_
				"<td style=""background-Color:transparent;color:#5b7cae"">" &_
				"getTitleLink(showTitle,rs(""id""),rs(""cateid""))" &_
				"IIf(rs(""newTag"")>=0,""<span class='alt_tx'></span>"","""")" &_
				"</td>"
			end if
			If hasStatField(rs) And showStatusField Then
				If rs("orderStat")>0 Then
					If m_isMobileMode Then
						getTitleHTML = getTitleHTML & Chr(11) & Chr(12) & "(" & getOrderStat(rs("orderStat")) & ")"
					else
						getTitleHTML = getTitleHTML & "<td width='80px' style=""background-Color:transparent;"">("&getOrderStat(rs("orderStat"))&")</td>"
'getTitleHTML = getTitleHTML & Chr(11) & Chr(12) & "(" & getOrderStat(rs("orderStat")) & ")"
					end if
				end if
			end if
			If Not m_isMobileMode Then
				getTitleHTML = getTitleHTML & "     </tr>" &_
				"</table>"
			end if
			End Select
		end function
		Public Function getDtHTML(ByRef rs)
			Dim dtArr,dtStr,dtType
			If isCleanMode Then
				getDtHTML = getDtHTML & rs("inDate")
			else
				If configId = 7 Then
					If m_isMobileMode Then
						dtArr = Split(rs("dt"),"@")
						dtStr = dtArr(0)
						dtType = dtArr(1)
						getDtHTML = getDtHTML & dtStr
					else
						Dim nlObj
						Set nlObj = New hlxNongLiGongLi
						dtArr = Split(rs("dt"),"@")
						dtStr = dtArr(0)
						dtType = dtArr(1)
						If dtType="2" Then
							getDtHTML = getDtHTML & "农历"&nlObj.getYearStr(dtStr)&"年"&_
							"nlObj.NongliMonth(nlObj.getMonthStr(dtStr))&""月""&_"
							nlObj.NongliDay(nlObj.getDayStr(dtStr))
						ElseIf dtType="3" Then
							getDtHTML = getDtHTML & "农历"&nlObj.getYearStr(dtStr)&"年闰"&_
							"nlObj.NongliMonth(nlObj.getMonthStr(dtStr))&""月""&_"
							nlObj.NongliDay(nlObj.getDayStr(dtStr))
						else
							getDtHTML = getDtHTML & "公历"&nlObj.getYearStr(dtStr)&"年"&_
							"nlObj.getMonthStr(dtStr)&""月""&_"
							nlObj.getDayStr(dtStr)&"日"
						end if
					end if
				else
					getDtHTML = getDtHTML & rs("dt")
				end if
			end if
			Dim canCancelAlt : canCancelAlt = False
			If m_canCancel = True And isCleanMode <> True And Not m_isMobileMode Then
				If hasAltField(rs) Then
					If CLng(rs("canCancelAlt")) = 1 Then
						canCancelAlt = True
					else
						canCancelAlt = False
					end if
				else
					canCancelAlt = True
				end if
				If canCancelAlt = True Then
					getDtHTML = getDtHTML & _
					"<img src='../images/alt3.gif' " &_
					"style='cursor:pointer;' " &_
					"onClick=""RemObj.cancel('" & rs("id") & "','" & rs("rid") & "'," & m_setjmId & "," & m_subCfgId & ")"" " &_
					"alt='取消提醒'"  &_
					"border='0'" &_
					"/>"
				end if
			end if
		end function
		Public Sub appendRemind(oid)
			Call appendRemindWithStat(oid,0)
		end sub
		Public Sub appendRemindWithStat(oid,stat)
			Call appendRemindWithInfo(oid,stat,"")
		end sub
		Public Sub appendRemindWithInfo(oid,stat,inf)
			Dim sql
			oid = Replace(oid," ","")
			If oid = "" Then
				Response.write "方法调用缺少必要的参数"
				Response.end
			end if
			sql = "select [id] from reminderQueue a  with(nolock) where reminderConfig=" & configId & " and subCfgId=" & m_subCfgId &_
			" And orderId in (" & oid & ") and orderStat=" & stat
			Me.cn.execute "delete reminderPersons where reminderId in ("&sql&")"
			Me.cn.execute "update reminderQueue set inDate =getdate() where id in ("&oid&")"
			Me.cn.execute "insert into reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,orderStat,otherInfo,inDate) " & _
			"select "&configId&","&m_subCfgId&_
			",cast(short_str as int),0,"&stat&",'"&inf&"',getdate() from dbo.split('"&oid&"',',') where cast(short_str as int) not in ("&Replace(sql,"[id]","[orderID]")&")"
		end sub
		Public Sub dropRemindByOID(oid)
			Call dropRemindByOidAndStat(oid,0)
		end sub
		Public Sub dropRemindByOidAndStat(oid,stat)
			If m_remindMode <> "PASSIVE" And m_remindMode <> "CYCLE" Then
				Response.write m_remindMode & "模式下不支持此过程调用！"
				Response.end
			end if
			oid = Replace(oid," ","")
			If oid = "" Then
				Response.write "方法调用缺少必要的参数"
				Response.end
			end if
			Me.cn.execute "delete reminderPersons where reminderId in " & _
			"(select id from reminderQueue  with(nolock) where orderId in (" & oid & ") and subCfgId="&m_subCfgId&_
			" and orderStat="&stat&" and reminderConfig=" & configId &")"
			Me.cn.execute "delete reminderQueue where orderId in (" & oid & ") and subCfgId="&m_subCfgId&_
			" and orderStat="&stat&" and reminderConfig=" & configId
		end sub
		Public Sub dropRemindByRID(rid)
			If m_remindMode <> "PASSIVE" And m_remindMode <> "CYCLE" Then
				Response.write m_remindMode & "模式下不支持此过程调用！"
				Response.end
			end if
			If rid = "" Then
				Response.write "方法调用缺少必要的参数"
				Response.end
			end if
			Me.cn.execute "delete reminderPersons where reminderId in (" & rid & ")"
			Me.cn.execute "delete reminderQueue where id in (" & rid & ")"
		end sub
		Public Sub cancelRemind(rid)
			Dim sql,rs,id
			If rid&""<>"0" And rid&""<>"" Then
				sql = iif(instr(rid,",")>0 , " id in (" & rid & ")", "id=" & rid)
				sql = "select id from reminderQueue  with(nolock) where " & sql
				Set rs=Me.cn.execute(sql)
				If rs.eof=True Then rs.close : Exit Sub
				While rs.eof = False
					id = CLng(rs(0))
					If canCancelOrder(id) Then
						If m_remindMode = "PASSIVE" Or m_remindMode = "CYCLE" Then
							If m_jointly = True Then
								If m_remindMode = "CYCLE" Then
									Me.cn.execute "insert into reminderPersons(reminderId,cateid) " & vbcrlf &_
									"select distinct "&id&",isnull(cateid," & uid & ") from setjm a  with(nolock) where ord="&m_setjmId&" " & vbcrlf &_
									"and not exists (select top 1 1 from reminderPersons  with(nolock) where reminderId="&id&" and cateid=isnull(a.cateid," & uid & "))"
								Else
									Call Me.dropRemindByRID(rid)
								end if
							else
								Me.cn.execute "if not exists (select 1 from reminderPersons  with(nolock) where reminderId=" & id & " and cateid=" & uid & ") " & vbcrlf &_
								"insert into reminderPersons(reminderId,cateid) values("&id&","&uid&")"
							end if
						end if
					end if
					rs.movenext
				wend
				rs.close
				set rs = nothing
			end if
		end sub
		Public Sub cancelRemindByOid(oid)
			Dim sql,rs,id,result,success
			If oid&""<>"0" And oid&""<>"" Then
				sql = "select distinct rid,cast(title as nvarchar(200)) as title from (" & listSql("all_withoutOrderBy") & ") a where [id] in (" & oid & ")"
				Set rs=Me.cn.execute(sql)
				If rs.eof=True Then Exit Sub
				result = ""
				While rs.eof = False
					id = CLng(rs("rid"))
					If canCancelOrder(id) Then
						If m_remindMode = "PASSIVE" Or m_remindMode = "CYCLE" Then
							If m_jointly = True Then
								If m_remindMode = "CYCLE" Then
									Me.cn.execute "insert into reminderPersons(reminderId,cateid) " & vbcrlf &_
									"select distinct "&id&",isnull(cateid," & uid & ") from setjm a  with(nolock) where ord="&m_setjmId&" " & vbcrlf &_
									"and not exists (select top 1 1 from reminderPersons  with(nolock) where reminderId="&id&" and cateid=isnull(a.cateid," & uid & ") )"
								Else
									Call Me.dropRemindByRID(rid)
								end if
							else
								Me.cn.execute "if not exists (select 1 from reminderPersons  with(nolock) where reminderId=" & id & " and cateid=" & uid & ") " & vbcrlf &_
								"insert into reminderPersons(reminderId,cateid) values("&id&","&uid&")"
							end if
						end if
						success = "true"
					else
						success = "false"
					end if
					result = result & "{""id"":"&id&",""name"":"""&IIF(Len(rs("title"))>0,rs("title"),"无标题")&""",""success"":"&success&"}"
					rs.movenext
					If rs.eof=False Then result = result & ","
				wend
				If Len(result)>0 Then
					Response.write "[" & result & "]"
				end if
			end if
		end sub
		Public Sub reloadRemind(withoutLimit)
			Dim sql,condition,qOpen,qIntro,fields,orderBy,rs,cfgId,cateid,rType,rAdvance,topNum,tmpCondition,lastReloadDate
			Me.cn.cursorLocation = 3
			If withoutLimit <> True Then
				sql = "select lastReloadDate from reminderConfigs  with(nolock) where setjmId=" & m_setjmId
				Set rs=Me.cn.execute(sql)
				If rs.eof Then
					Response.write "读取配置失败，请联系管理员"
					Response.end
				else
					lastReloadDate = now
					If datediff("s",rs(0),lastReloadDate) < RELOAD_INTERVAL_LIMIT And datediff("s",rs(0),lastReloadDate) > 0 Then
						Response.write "请不要频繁进行更新操作"
						Response.end
					end if
				end if
			else
				lastReloadDate = now
			end if
			sql = "select top 0 id,reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate into #reminderQueue from reminderQueue"
			Me.cn.execute sql
			Set rs = Me.cn.execute("select isnull(max(tq1),0) tq1 from setjm  with(nolock) where intro='1' and ord=" & m_setjmId)
			If rs.eof Then
				rAdvance = 0
			else
				rAdvance = rs(0)
			end if
			Select Case m_setjmId
			Case 7:
			Dim nowDays : nowDays = datediff("d",CDate(year(date)&"-01-01"),date)
'Case 7:
			sql = "exec erp_PersonBirthdayUpdate "&year(date)&",0"
			Me.cn.execute sql
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select "&m_setjmId&",0,a.ord,year(getdate())+(case when isnull(a.bDays - "&nowDays&",0)=0 then 0 else 1 end)*100000,"&_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"a.bDays - "&nowDays&",getdate() " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"From person a  with(nolock) " & vbcrlf &_
			"where bDays - "&nowDays&" >=0 and bDays - "&nowDays&" <= " & rAdvance & " " & vbcrlf &_
			"From person a  with(nolock) " & vbcrlf &_
			"and a.ord not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by a.bDays,a.ord"
			Me.cn.execute sql
			Case 9:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select " & m_setjmId & ",0,id,datediff(d,'2000-01-01',date2),datediff(d,getdate(),date2),getdate() from caigoulist a with(nolock)  " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where del=1 and alt=1 " & vbcrlf & _
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"and datediff(d,getdate(),date2)<=" & rAdvance & " and datediff(m,getdate(),date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by date2 desc,date7 desc"
			Me.cn.execute sql
			Case 11:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select "&m_setjmId&",0,ord,datediff(d,'2000-01-01',date1),datediff(d,getdate(),date1),getdate() from payback a with(nolock)  " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where del=1 and complete='1' " & vbcrlf &_
			"and datediff(d,getdate(),date1)<=" & rAdvance & " " & vbcrlf &_
			"and a.ord not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by date1 desc,date7 desc"
			Me.cn.execute sql
			Case 209:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select "&m_setjmId&",0,id,datediff(d,'2000-01-01',applydate),datediff(d,getdate(),applydate),getdate() from payoutsure a  with(nolock) " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where del=1 and (complete='0' and status in (-1,1) or complete='3')" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"and datediff(d,getdate(),applydate)<=" & rAdvance & " " & vbcrlf &_
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by applydate desc,InDate desc"
			Me.cn.execute sql
			Case 12:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select "&m_setjmId&",0,ord,datediff(d,'2000-01-01',date1),datediff(d,getdate(),date1),getdate() from payout a  with(nolock) " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where del=1 and complete='1' " & vbcrlf &_
			"and datediff(d,getdate(),date1)<=" & rAdvance & " " & vbcrlf &_
			"and a.ord not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by date1 desc,date7 desc"
			Me.cn.execute sql
			Case 21:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select " & m_setjmId & ",0,ord,datediff(d,'2000-01-01',date2),datediff(d,getdate(),date2),getdate() from contract a with(nolock)  " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where del=1 " & vbcrlf & _
			"and a.ord not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"and datediff(d,getdate(),date2)<=" & rAdvance & " and datediff(m,getdate(),date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"and a.ord not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by date2 desc,date7 desc"
			Me.cn.execute sql
			Case 23:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select " & m_setjmId & ",0,id,datediff(d,'2000-01-01',date2),datediff(d,getdate(),date2),getdate() from contractlist a with(nolock)  " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where a.del=1 and a.num2<a.num1 " & vbcrlf & _
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"and datediff(d,getdate(),date2)<=" & rAdvance & " and datediff(m,getdate(),date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by date2 desc,date7 desc"
			Me.cn.execute sql
			Case 68:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select " & m_setjmId & ",0,ku.id," & vbcrlf &_
			"MaintainUnit*10000 + MaintainNum * 10 + cast(ISNULL(m.date1,ISNULL(ku.datesc,'1970-1-1')) as int)," & vbcrlf &_
			"select " & m_setjmId & ",0,ku.id," & vbcrlf &_
			"datediff(hh,'"&date&"',ISNULL(m.date1,ISNULL(ku.datesc,'1970-1-1'))) + " & vbcrlf &_
			"select " & m_setjmId & ",0,ku.id," & vbcrlf &_
			"case " & vbcrlf &_
			"when MaintainUnit = 1 then MaintainNum " & vbcrlf &_
			"when MaintainUnit = 2 then MaintainNum * 24 " & vbcrlf &_
			"when MaintainUnit = 3 then MaintainNum * 24 * 7 " & vbcrlf &_
			"when MaintainUnit = 4 then MaintainNum * 24 * 30 " & vbcrlf &_
			"when MaintainUnit = 5 then MaintainNum * 24 * 365 " & vbcrlf &_
			"end " & vbcrlf &_
			",getdate() " & vbcrlf &_
			"from product p  with(nolock) " & vbcrlf &_
			"inner join ku  with(nolock) on p.ord=ku.ord and ku.num2<>0 and LEN(ku.datesc)>0 and p.del=1 " & vbcrlf &_
			"and ISNULL(p.MaintainNum,0)>0 and datalength(p.RemindPerson)>0 " & vbcrlf &_
			"left join ( " & vbcrlf &_
			"select m1.ord yhord,m2.ord,m2.ku,m3.date1 from maintain m1  with(nolock) " & vbcrlf &_
			"inner join ( " & vbcrlf &_
			"select maintain,ord,ku from maintainlist  with(nolock) " & vbcrlf &_
			"where del=1 " & vbcrlf &_
			"group by maintain,ord,ku " & vbcrlf &_
			") m2 on m2.maintain=m1.ord " & vbcrlf &_
			"inner join ( " & vbcrlf &_
			"select m2.ord, m2.ku, max(m1.date1) date1 " & vbcrlf &_
			"from maintain m1  with(nolock) " & vbcrlf &_
			"inner join maintainlist m2  with(nolock) on m2.maintain=m1.ord and m2.del=1 " & vbcrlf &_
			"inner join product p  with(nolock) on p.ord=m2.ord and p.del=1 " & vbcrlf &_
			"and ISNULL(p.MaintainNum,0)>0 and datalength(p.RemindPerson)>0 " & vbcrlf &_
			"where m1.del=1 and isnull(m1.status,0)=0 " & vbcrlf &_
			"group by m2.ord,m2.ku " & vbcrlf &_
			")m3 on m2.ord=m3.ord and m2.ku=m3.ku " & vbcrlf &_
			"where m1.del=1 and isnull(m1.status,0)=0 and m1.date1=m3.date1 " & vbcrlf &_
			") m on m.ku=ku.id and p.ord=m.ord " & vbcrlf &_
			"where isnull(ku.locked,0)=0 and len(ISNULL(m.date1,ku.datesc))>0 " & vbcrlf &_
			"and datediff(hh,'"&date&"',ISNULL(m.date1,ISNULL(ku.datesc,'1970-1-1'))) + " & vbcrlf &_
			"where isnull(ku.locked,0)=0 and len(ISNULL(m.date1,ku.datesc))>0 " & vbcrlf &_
			"case " & vbcrlf &_
			"when MaintainUnit = 1 then MaintainNum " & vbcrlf &_
			"when MaintainUnit = 2 then MaintainNum * 24 " & vbcrlf &_
			"when MaintainUnit = 3 then MaintainNum * 24 * 7 " & vbcrlf &_
			"when MaintainUnit = 4 then MaintainNum * 24 * 30 " & vbcrlf &_
			"when MaintainUnit = 5 then MaintainNum * 24 * 365 " & vbcrlf &_
			"end <= " & (rAdvance * 24)
			Me.cn.execute sql
			Case 105:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select "&m_setjmId&",0,ProductID,datediff(mi,'2014-01-01',getdate()),b.UnitId,getdate() " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"from o_product a  with(nolock) " & vbcrlf &_
			"inner join ( " & vbcrlf &_
			"select replace(prod_id,' ','') as ProductID,replace(prod_unit,' ','') as UnitId,sum(prod_num) as ku_num " & vbcrlf &_
			"from o_kuinlist a  with(nolock) " & vbcrlf &_
			"inner join o_kuin b  with(nolock) on a.reg_fid=b.id " & vbcrlf &_
			"group by prod_id,prod_unit " & vbcrlf &_
			") b on a.id=b.ProductID " & vbcrlf &_
			"where " & vbcrlf &_
			"(case when Ku_num>prod_more and prod_more<>0 then "&_
			"(convert(decimal,(Ku_num-prod_more))/convert(decimal,prod_more))*100 else 0 end) > 0 " & vbcrlf &_
			"(case when Ku_num>prod_more and prod_more<>0 then "&_
			" or " & vbcrlf &_
			"(case when Ku_num<prod_less and prod_less<>0 then "&_
			"(convert(decimal,(prod_less-Ku_num))/convert(decimal,prod_less))*100 else 0 end) > 0 "
'(case when Ku_num<prod_less and prod_less<>0 then &_
			Me.cn.execute sql
			Case 106:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select distinct "&m_setjmId&",0,ord,isnull(min(type1),0) * 100000 + min(backdays),min(backdays),getdate() " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"from dbo.erp_sale_getBackList('"&date&"',0) where canremind=1 and backdays<=reminddays " & vbcrlf &_
			"group by ord"
			Me.cn.execute sql
			Case 120:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select distinct "&m_setjmId&",0,a.ord,datediff(d,'2014-01-01',getdate()),datediff(d,'" & date & "',datepro+isnull(b.num2,0)),getdate() "&_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"from tel as a WITH(NOLOCK) "& vbcrlf &_
			"inner join num_bh b on a.sort1=b.kh and a.cateid=b.cateid "& vbcrlf &_
			"where a.profect1=1 "& vbcrlf &_
			"and datediff(d,'" & date & "',datepro+isnull(b.num2,0)) <= isnull(b.num3,0) "& vbcrlf &_
			"where a.profect1=1 "& vbcrlf &_
			"and a.del=1 and isnull(a.sp,0)=0 and a.sort3=1"
			Me.cn.execute sql
			Case 121:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select distinct "&m_setjmId&",0,ord,datediff(d,'2014-01-01',getdate()),datediff(d,'2014-01-01',isnull(nextReply,EndReplyDate)),getdate() "&_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"from dbo.erp_sale_getWillReplyList('"&date&"',0) "
			Me.cn.execute sql
			Case 10:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT " & m_setjmId & ",0,a.id,DATEDIFF(d,'2000-01-01',a.date2),DATEDIFF(d,GETDATE(),a.date2),GETDATE() FROM kujhlist a  with(nolock) " & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"WHERE a.del = 1 AND a.num1 > a.num2 " & vbcrlf & _
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.date2)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY a.date2 DESC,a.date7 DESC"
			Me.cn.execute sql
			Case 20:
			storelist_sort5 = "0"
			Set rsUsConfig= conn.execute("select isnull(tvalue,'0') tvalue from home_usConfig where name='storelist_sort5' and isnull(uid, 0) =" &  session("personzbintel2007") )
			If rsUsConfig.eof= False Then
				storelist_sort5=rsUsConfig("tvalue")
			end if
			rsUsConfig.close
			showKuLimitZeroSQL = ""
			if storelist_sort5 = "0" then
				showKuLimitZeroSQL = " and (isnull(a.alert1,0)>0 or isnull(a.alert2,0)>0)"
			end if
			showzore =0
			Set rsUsConfig= conn.execute("select (case cast(tvalue as varchar(10)) when '1' then 1 else 0 end) v from home_usConfig  with(nolock) where uid="& session("personzbintel2007") &" and name='storelist_sort1' ")
			if rsUsConfig.eof=false  then
				showzore = rsUsConfig("v").value
			end if
			rsUsConfig.close
			unkuinwarning = 0
			if showzore="1" then
				Set rsUsConfig= conn.execute("select (case cast(tvalue as varchar(10)) when '1' then 1 else 0 end) v from home_usConfig  with(nolock) where uid="& session("personzbintel2007") &" and name='storelist_warning' ")
				if rsUsConfig.eof=false  then
					unkuinwarning = rsUsConfig("v").value
				end if
				rsUsConfig.close
			end if
			showZeroSQL = ""
			if showzore = "0" then
				showZeroSQL = " and isnull(b.ku_num,0)>0 "
			else
				if unkuinwarning="0" then
					showZeroSQL = " and exists(select 1 from ku where ord =a.ord) "
				end if
			end if
			sql = "" & vbcrlf &_
			"select cateid from setjm a " & vbcrlf &_
			"inner join (" & vbcrlf &_
			"select ord from (" & vbcrlf &_
			"select ord from power  with(nolock) where (sort1=31 and sort2=13 and qx_open>0) " & vbcrlf &_
			"union all " & vbcrlf &_
			"select ord from power  with(nolock) where (sort1=31 and sort2=16 and qx_open>0) " & vbcrlf &_
			") a group by ord having count(*)=2 " & vbcrlf &_
			"union " & vbcrlf &_
			"select ord from (" & vbcrlf &_
			"select ord from power  with(nolock) where (sort1=32 and sort2=13 and qx_open>0) " & vbcrlf &_
			"union all " & vbcrlf &_
			"select ord from power  with(nolock) where (sort1=32 and sort2=16 and qx_open>0) " & vbcrlf &_
			") a group by ord having count(*)=2" & vbcrlf &_
			") b on a.cateid=b.ord " & vbcrlf &_
			"where a.intro=1 and a.ord=" & m_setjmId
			Set rs = Me.cn.execute(sql)
			While rs.eof = False
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT " & m_setjmId & ",0,a.ord,DATEDIFF(mi,'2000-01-01',a.date7),DATEDIFF(d,GETDATE(),a.date7),GETDATE() " & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"FROM (" & vbcrlf &_
				"SELECT a.ord,addcate,title," & vbcrlf & _
				"(CASE WHEN Isnull(aleat1, 0) = 0 THEN 0 ELSE Isnull(aleat1, 0) END )  AS alert1, " & vbcrlf & _
				"(CASE WHEN Isnull(aleat2, 0) = 0 THEN 0 ELSE Isnull(aleat2, 0) END )  AS alert2, " & vbcrlf & _
				"date7,Isnull(ku_num, 0) ku_num " & vbcrlf & _
				"FROM product a  with(nolock) " & vbcrlf & _
				"LEFT JOIN (" & vbcrlf &_
				"SELECT ord,Sum(numjb) AS ku_num FROM ("&vbcrlf &_
				"SELECT suba.ord," & vbcrlf & _
				"(CASE " & vbcrlf & _
				"WHEN suba.unit = subb.unitjb THEN num2 " & vbcrlf & _
				"ELSE num2 * Isnull((SELECT TOP 1 bl FROM jiage WHERE  product = suba.ord AND unit = suba.unit), 0) " & vbcrlf & _
				"END) numjb " & vbcrlf & _
				"FROM ku suba  with(nolock) " & vbcrlf & _
				"INNER JOIN product subb  with(nolock) ON suba.ord = subb.ord " & vbcrlf & _
				"inner join sortck subc  with(nolock) on subc.id = suba.ck "& vbcrlf &_
				"and subc.del=1 "& vbcrlf &_
				"and ("& vbcrlf &_
				"charindex('," & rs(0) & ",',','+replace(cast(subc.intro as varchar(4000)),' ','')+',')>0 "& vbcrlf &_
				"and ("& vbcrlf &_
				"or replace(cast(subc.intro as varchar(4000)),' ','') = '0'"& vbcrlf &_
				")" & vbcrlf &_
				") subaa " & vbcrlf & _
				"GROUP BY ord " & vbcrlf & _
				") AS b ON a.ord = b.ord " & vbcrlf & _
				"WHERE a.del = 1 "& showZeroSQL&" AND (isnull(ku_num,0)<=aleat1 or isnull(ku_num,0)>aleat2)" & vbcrlf & _
				") AS a " & vbcrlf & _
				"WHERE not a.date7 is NULL "& showKuLimitZeroSQL &" " & vbcrlf & _
				"AND a.ord NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"ORDER BY a.date7 DESC"
				Me.cn.execute sql
				rs.movenext
			wend
			rs.close
			Case 49:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT " & m_setjmId & ",0,a.id,DATEDIFF(mi,'2000-01-01',a.lastdate)+100000*isnull(a.zhouqi,0),DATEDIFF(d,GETDATE(),a.lastdate),GETDATE() " & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"FROM " & vbcrlf & _
			"(SELECT a.id,a.personID, b.username,a.lastdate,a.zhouqi, " & vbcrlf & _
			"  (CASE a.unit " & vbcrlf & _
			"     WHEN 1 THEN Dateadd(yyyy, a.zhouqi, a.lastdate) " & vbcrlf & _
			"     WHEN 2 THEN Dateadd(qq, a.zhouqi, a.lastdate) " & vbcrlf & _
			"     WHEN 3 THEN Dateadd(m, a.zhouqi, a.lastdate) " & vbcrlf & _
			"     WHEN 4 THEN Dateadd(ww, a.zhouqi, a.lastdate) " & vbcrlf & _
			"     WHEN 5 THEN Dateadd(d, a.zhouqi, a.lastdate) " & vbcrlf & _
			"     ELSE NULL " & vbcrlf & _
			"  END ) AS nextdate, " & vbcrlf & _
			"  Isnull(a.alt, 1) AS alt " & vbcrlf & _
			"FROM   hr_person_health a  with(nolock) " & vbcrlf & _
			"       INNER JOIN hr_person b  with(nolock) ON b.userID = a.personID " & vbcrlf & _
			"WHERE  b.del = 0 AND a.lastdate IS NOT NULL AND a.zhouqi IS NOT NULL AND b.nowstatus NOT IN (2,3,4) " & vbcrlf & _
			") a " & vbcrlf & _
			"WHERE 1 = 1 AND a.alt < 2 " & vbcrlf & _
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.nextdate)<=" & rAdvance &_
			"AND DATEDIFF(m,GETDATE(),a.nextdate)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.nextdate)<=" & rAdvance &_
			"ORDER BY a.lastdate DESC"
			Me.cn.execute sql
			Case 66:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT " & m_setjmId & ",0,a.id,DATEDIFF(mi,'2000-01-01',a.date2),DATEDIFF(d,GETDATE(),a.date2),GETDATE() " & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"FROM " & vbcrlf & _
			"(SELECT z.id,t.name,t.cateid,s.title,z.date2,ISNULL(z.alt, '') alt " & vbcrlf & _
			"FROM   tel t  with(nolock) " & vbcrlf & _
			"INNER JOIN sortFieldsContent z " & vbcrlf & _
			"       ON z.ord = t.ord " & vbcrlf & _
			"          AND z.del = 1 " & vbcrlf & _
			"          AND t.del = 1 " & vbcrlf & _
			"          AND z.sort = 1 " & vbcrlf & _
			"          AND t.sort3 = 2 " & vbcrlf & _
			"          AND t.isNeedQuali = 1 " & vbcrlf & _
			"          AND ISNULL(t.status_sp_qualifications, 0) = 0 " & vbcrlf & _
			"          AND LEN(z.date2) > 0 " & vbcrlf & _
			"          AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"          AND CHARINDEX(',"& uid &",', ',' + CAST(z.share AS VARCHAR(4000)) + ',') > 0 " & vbcrlf & _
			"          AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"INNER JOIN sortClass s " & vbcrlf & _
			"       ON z.sortid = s.id " & vbcrlf & _
			"          AND ISNULL(s.isStop, 0) = 0 " & vbcrlf & _
			"          AND s.sort1 = 2 " & vbcrlf & _
			") a " & vbcrlf & _
			"WHERE 1 = 1 " & vbcrlf & _
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.date2)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY a.date2 DESC"
			Me.cn.execute sql
			Case 67:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT " & m_setjmId & ",0,a.id,DATEDIFF(mi,'2000-01-01',a.date2),DATEDIFF(d,GETDATE(),a.date2),GETDATE() " & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"FROM " & vbcrlf & _
			"(SELECT z.id,t.name,t.cateid,s.title,z.date2,ISNULL(z.alt, '') alt " & vbcrlf & _
			"FROM   tel t  with(nolock) " & vbcrlf & _
			"INNER JOIN sortFieldsContent z " & vbcrlf & _
			"       ON z.ord = t.ord " & vbcrlf & _
			"          AND z.del = 1 " & vbcrlf & _
			"          AND t.del = 1 " & vbcrlf & _
			"          AND z.sort = 1 " & vbcrlf & _
			"          AND t.sort3 = 1 " & vbcrlf & _
			"          AND t.isNeedQuali = 1 " & vbcrlf & _
			"          AND ISNULL(t.status_sp_qualifications, 0) = 0 " & vbcrlf & _
			"          AND LEN(z.date2) > 0 " & vbcrlf & _
			"          AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"          AND CHARINDEX(',"& uid &",', ',' + CAST(z.share AS VARCHAR(4000)) + ',') > 0 " & vbcrlf & _
			"          AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"INNER JOIN sortClass s " & vbcrlf & _
			"       ON z.sortid = s.id " & vbcrlf & _
			"          AND ISNULL(s.isStop, 0) = 0 " & vbcrlf & _
			"          AND s.sort1 = 2 " & vbcrlf & _
			") a " & vbcrlf & _
			"WHERE 1 = 1 " & vbcrlf & _
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.date2)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY a.date2 DESC"
			Me.cn.execute sql
			Case 213:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,a.id,DATEDIFF(d,'2000-01-01',a.date1),DATEDIFF(d,GETDATE(),a.date1),GETDATE() " & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"FROM ( " & vbCrLf &_
			"  SELECT a.id,a.date1,a.date7 FROM paybackinvoice a   with(nolock) " & vbCrLf &_
			"  INNER JOIN sortbz b ON b.id = a.bz " & vbCrLf &_
			"  WHERE a.del = 1 AND isInvoiced = 0  AND ISNULL(a.cateid,0) <> 0 " & vbCrLf &_
			") a " & vbCrLf &_
			"WHERE 1 =1 " & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.date1)<=" & rAdvance & " " & vbcrlf &_
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY a.date1 DESC,a.date7 DESC"
			Me.cn.execute sql
			Case 214:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,id,DATEDIFF(d,'2000-01-01',date1),DATEDIFF(d,GETDATE(),date1),GETDATE() " & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"FROM payoutInvoice  with(nolock) WHERE del = 1 AND isInvoiced=0 " & vbCrLf &_
			"AND DATEDIFF(d,GETDATE(),date1)<=" & rAdvance & "  " & vbcrlf &_
			"AND id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY date1 DESC,date7 DESC"
			Me.cn.execute sql
			Case 52:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,id,RemindNum*100+RemindUnit*10+cast(getdate() as int)," & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"isnull(daysFromNow,0) - " & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"isnull(case " & vbcrlf &_
			"when RemindUnit = 1 then RemindNum " & vbcrlf &_
			"when RemindUnit = 2 then RemindNum * 24 " & vbcrlf &_
			"when RemindUnit = 3 then RemindNum * 24 * 7 " & vbcrlf &_
			"when RemindUnit = 4 then RemindNum * 24 * 30 " & vbcrlf &_
			"when RemindUnit = 5 then RemindNum * 24 * 365 " & vbcrlf &_
			"end,0)" & vbcrlf &_
			",GETDATE() " & vbcrlf &_
			"FROM ( " & vbCrLf &_
			"SELECT p.ord, p.title, p.addcate, k.dateyx, k.id,ISNULL(p.RemindUnit,0) RemindUnit,ISNULL(p.RemindNum,0) RemindNum," & vbcrlf &_
			"datediff(hh,getdate(),k.dateyx) daysFromNow " & vbcrlf &_
			"FROM ku k  with(nolock) " & vbcrlf &_
			"INNER JOIN product p  with(nolock) ON p.ord = k.ord " & vbcrlf &_
			"INNER JOIN sortck ck  with(nolock) ON k.ck = ck.ord AND ck.del = 1 " & vbcrlf &_
			"WHERE (CAST(ISNULL(ck.intro,'') AS VARCHAR(4000))='0' OR CHARINDEX(',"&uid&",',','+CAST(ck.intro AS VARCHAR(4000))+',')>0) " & vbcrlf &_
			"INNER JOIN sortck ck  with(nolock) ON k.ck = ck.ord AND ck.del = 1 " & vbcrlf &_
			"AND p.del = 1 " & vbcrlf &_
			"AND k.num2 > 0 " & vbcrlf &_
			"AND p.RemindNum > 0 " & vbcrlf &_
			"AND k.dateyx IS NOT NULL " & vbcrlf &_
			"AND ISNULL(k.locked, 0) = 0 " & vbcrlf &_
			") a " & vbCrLf &_
			"WHERE 1 =1 " & vbcrlf &_
			"AND daysFromNow <= " & (rAdvance*24) & " " & vbcrlf &_
			"AND ord NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY dateyx DESC"
			Me.cn.execute sql
			Case 51:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,id,DATEDIFF(d,'2000-01-01',ld_rettime),DATEDIFF(d,GETDATE(),ld_rettime),GETDATE() " & vbcrlf &_
			"FROM ( " & vbCrLf &_
			"  SELECT a.id, c.bk_name, a.ld_rettime, d.addcateid " & vbcrlf &_
			"  FROM O_Lendbookmx a with(nolock)  " & vbcrlf &_
			"  LEFT JOIN O_Lendbook d  with(nolock) ON a.Ld_fid=d.id " & vbcrlf &_
			"  LEFT JOIN O_regbook c  with(nolock) ON a.Ld_bkid=c.id " & vbcrlf &_
			"  WHERE a.ld_num > (SELECT isnull(sum(Ret_num),0) AS Ret_num FROM O_RetBookmx WHERE Ret_bkid=a.id) " & vbcrlf &_
			") a " & vbCrLf &_
			"WHERE 1 =1 " & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),ld_rettime)<=" & rAdvance & " " & vbcrlf &_
			"AND id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY ld_rettime DESC"
			Me.cn.execute sql
			Case 59:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,id,DATEDIFF(d,'2000-01-01',Reguldate),DATEDIFF(d,GETDATE(),Reguldate),GETDATE() " & vbcrlf &_
			"FROM ( " & vbCrLf &_
			"  SELECT a.ID,a.Reguldate " & vbcrlf &_
			"  FROM hr_person a  with(nolock) " & vbcrlf &_
			"  WHERE  a.nowStatus = 5 AND a.del = 0 " & vbcrlf &_
			") a " & vbCrLf &_
			"WHERE 1 =1 " & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),Reguldate)<=" & rAdvance & " " & vbcrlf &_
			"AND id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY Reguldate DESC"
			Me.cn.execute sql
			Case 215:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,chanceID,DATEDIFF(d,'2000-01-01',GETDATE()) * 1000 + backdays,backDays,GETDATE() " & vbcrlf &_
			"FROM dbo.erp_chance_callbackList('"& Now() &"') a" & vbCrLf &_
			"WHERE 1 =1 AND a.backdays <= ISNULL((SELECT ISNULL(tq1,5) FROM setjm WHERE cateid = "& uid &" AND ord = "&m_setjmId&" AND intro = '1'),5)  " & vbcrlf &_
			"AND chanceID NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY chanceID DESC"
			Me.cn.execute sql
			Case 300:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,id,ISNULL(DATEDIFF(d,'2000-01-01',date4),0),ISNULL(DATEDIFF(d,GETDATE(),date4),0),GETDATE() " & vbcrlf &_
			"FROM document with(nolock)  " & vbCrLf &_
			"WHERE del = 1 AND validity = 2 AND (sp = 0 AND cateid_sp = 0) AND addcate = "& uid &" AND date4 is not null  " & vbcrlf &_
			"AND id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY id DESC"
			Me.cn.execute sql
			Case 301:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,l.id,ISNULL(DATEDIFF(d,'2000-01-01',l.l_date4),0),ISNULL(DATEDIFF(d,GETDATE(),l.l_date4),0),GETDATE() " & vbcrlf &_
			"FROM documentlist l  with(nolock) " & vbCrLf &_
			"inner join document d on d.id = l.document "&  vbCrLf &_
			"WHERE d.del = 1 and l.del=1 AND l.l_validity = 2 AND (d.sp = 0 AND d.cateid_sp = 0) AND l.l_date4 is not null  " & vbcrlf &_
			"AND l.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY l.id DESC"
			Me.cn.execute sql
			Case 155:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT " & m_setjmId & ",0,a.iss_id,DATEDIFF(mi,'2000-01-01',a.iss_endtime),DATEDIFF(d,GETDATE(),a.iss_endtime),GETDATE() " & vbcrlf &_
			"FROM " & vbcrlf & _
			"O_insure a  with(nolock) " & vbcrlf & _
			"WHERE a.del=1 " & vbcrlf & _
			"AND a.iss_id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.iss_endtime)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.iss_endtime)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"ORDER BY a.iss_endtime DESC"
			Me.cn.execute sql
			Case 17:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT " & m_setjmId & ",0,a.id,DATEDIFF(mi,'2000-01-01',a.date3),DATEDIFF(d,GETDATE(),a.date3),GETDATE() " & vbcrlf &_
			"FROM " & vbcrlf & _
			"(select *,(select TOP 1 id from hr_person  with(nolock) where del = 0 AND userid=ord) as id from gate_person) a " & vbcrlf & _
			"WHERE 1 = 1 " & vbcrlf & _
			"and a.id IS NOT NULL " & vbcrlf & _
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.date3)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.date3)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"ORDER BY a.date3 DESC"
			Me.cn.execute sql
			Case 156:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT " & m_setjmId & ",0,a.ord,DATEDIFF(mi,'2000-01-01',a.date3),DATEDIFF(d,GETDATE(),a.date3),GETDATE() " & vbcrlf &_
			"FROM " & vbcrlf & _
			"gate a " & vbcrlf & _
			"WHERE 1 = 1 " & vbcrlf & _
			"and a.ord IS NOT NULL " & vbcrlf & _
			"AND a.ord NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.date3)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.date3)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"ORDER BY a.date3 DESC"
			Me.cn.execute sql
			Case 224:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select " & m_setjmId & ",0,id,datediff(d,'2000-01-01',dateEnd),datediff(d,getdate(),dateEnd),getdate() from M_WorkAssigns a " & vbcrlf &_
			"left join (" & vbcrlf & _
			"  --需要质检的工序中-质检通过数量最少的数量值" & vbcrlf & _
			"  select M_WorkAssigns , min(pnum) as pnum " & vbcrlf & _
			"  from " & vbcrlf & _
			"(" & vbcrlf & _
			"            select n.id as M_WorkAssigns, w.id ,sum(isnull(r.num1,0)) as pnum " & vbcrlf & _
			"            from M_WorkAssigns n with(nolock) " & vbcrlf & _
			"            inner join M_WFP_Assigns w on w.WFid = n.WProID and w.result=1 --工艺流程中需要质检的工序" & vbcrlf & _
			"            from M_WorkAssigns n with(nolock) " & vbcrlf & _
			"            left join M_ProcedureProgres r on r.[Procedure]=w.id and r.del=0 and r.result = 1 --质检通过" & vbcrlf & _
			"            from M_WorkAssigns n with(nolock) " & vbcrlf & _
			"            group by n.id , w.id" & vbcrlf & _
			"    ) s group by M_WorkAssigns" & vbcrlf & _
			") d on d.M_WorkAssigns = a.id" & vbcrlf & _
			"left join (" & vbcrlf & _
			"    select m.WAID , sum(NumQualified) as qnum ,max(m.MPDate) as newInDate" & vbcrlf & _
			"   from M_MaterialProgres m " & vbcrlf & _
			"   inner join M_MaterialProgresDetail t on t.MPID = m.id and m.del=0 and t.del=0" & vbcrlf & _
			"   group by m.WAID" & vbcrlf & _
			") c on c.WAID = a.id" & vbcrlf & _
			"where a.del=0 " & vbcrlf &_
			"and (case when (isnull(d.pnum,-1)=-1 or isnull(d.pnum,-1)>=a.NumMake ) and isnull(c.qnum,0)>=a.NumMake then 1 else 0 end) = 0 " & vbcrlf &_
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"and datediff(d,getdate(),dateEnd)<=" & rAdvance & " and datediff(m,getdate(),dateEnd)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"order by dateEnd desc,indate desc"
			Me.cn.execute sql
			Case 47003:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select " & m_setjmId & ",0,id,datediff(d,'2000-01-01',LimitEndDate),datediff(d,getdate(),LimitEndDate),getdate() from AcceptanceDraft a  with(nolock) " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where a.del=1 " & vbcrlf &_
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"and datediff(d,getdate(),LimitEndDate)<=" & rAdvance & " and datediff(m,getdate(),LimitEndDate)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by LimitEndDate"
			Me.cn.execute sql
			Case 51011:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select " & m_setjmId & ",0,id,datediff(d,'2000-01-01',date1),datediff(d,getdate(),date1),getdate() from dbo.M2_maintain a  with(nolock) " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where 1=1 " & vbcrlf & _
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d, GETDATE() ,(CASE Unit2 WHEN 0 THEN DATEADD(MINUTE,num2,date1) " & vbcrlf &_
			"WHEN 1 THEN DATEADD(HOUR,num2,date1) WHEN 2 THEN DATEADD(DAY,num2,date1) WHEN 3 THEN DATEADD(MONTH,num2,date1) " & vbcrlf &_
			"WHEN 4 THEN DATEADD(YEAR,num2,date1) end))<=" & rAdvance & " " & vbcrlf &_
			"order by date1 desc"
			Me.cn.execute sql
			End Select
			sql = "select * from setjm  with(nolock) where intro='1' and ord=" & m_setjmId
			Set rs = Me.cn.execute(sql)
			While rs.eof = False
				cfgId = rs("ord")
				cateid = rs("cateid")
				rType = rs("fw1")
				rAdvance = rs("tq1")
				topNum = rs("num1")
				Select Case cfgId
				Case Else :
				End Select
				rs.movenext
			wend
			cn.execute "exec erp_UpdateReminderQueue " & configId & "," & m_subCfgId & ",'" & lastReloadDate & "'"
		end sub
		Public Function getRemindIdByOID(oid)
			getRemindIdByOID = getRemindIdByOIDAndStat(oid,0)
		end function
		Public Function getRemindIdByOIDAndStat(oid,stat)
			Dim sql,rs
			sql = "select top 1 id from reminderQueue  with(nolock) where reminderConfig=" & configId & " and subCfgId="&m_subCfgId&_
			" and orderId=" & oid & " and orderStat=" & stat & " and id in " &_
			"("&listSql("rids")&")"
			Set rs = Me.cn.execute(sql)
			If rs.eof Then
				getRemindIdByOIDAndStat = -1
'If rs.eof Then
			else
				getRemindIdByOIDAndStat = CLng(rs(0))
			end if
		end function
		Public Function canCancelOrder(rid)
			If rid <= 0 Then
				canCancelOrder = False
			else
				Dim rs,sql
				sql = Me.listSql("all_withoutOrderBy")
				If InStr(sql,"canCancelAlt")>0 Then
					sql = "select top 1 * from (" & sql & ") a where rid=" & rid & " and canCancelAlt = 1"
				else
					sql = "select top 1 * from (" & sql & ") a where rid=" & rid
				end if
				Set rs = cn.execute(sql)
				If rs.eof Then
					canCancelOrder = False
				else
					canCancelOrder = Me.cn.execute("select top 1 reminderId from reminderPersons  with(nolock) where reminderId = " & rid & " and cateid=" & uid).eof
				end if
			end if
		end function
		Private Function getConditionByFW(s1,s2,cateField)
			Dim qOpen,qIntro
			Call fillInPower(s1,s2,qOpen,qIntro)
			if m_fw1&""="0" Then
				if qOpen = 3 then
					getConditionByFW = ""
				elseif qOpen = 1 then
					getConditionByFW=" and "&cateField&" in ("&qIntro&") "
				else
					getConditionByFW=" and 1=2 "
				end if
			else
				getConditionByFW=" and "&cateField&"="&uid&" and ("&qOpen&"=3 or ("&qOpen&"=1 and CHARINDEX(','+cast("&cateField&" as varchar)+',', ',"&qIntro&",') > 0))"
'getConditionByFW=" and 1=2 "
			end if
		end function
		Private Function getConditionWithShare(s1,s2,cateField,shareField)
			Dim qOpen,qIntro
			Call fillInPower(s1,s2,qOpen,qIntro)
			if qOpen = 3 then
				getConditionWithShare = ""
			elseif qOpen = 1 then
				getConditionWithShare = " AND ("&cateField&" IN ("&qIntro&") OR ("&shareField&" = '1' OR CHARINDEX(',"& uid &",', ',' + "& shareField &" + ',') > 0  ))"
'elseif qOpen = 1 then
			else
				getConditionWithShare = " AND ("&shareField&" = '1' OR CHARINDEX(',"& uid &",', ',' + "& shareField &" + ',') > 0  )"
'elseif qOpen = 1 then
			end if
		end function
		Private Function getCondition(s1,s2,cateField)
			Dim qOpen,qIntro
			Call fillInPower(s1,s2,qOpen,qIntro)
			if qOpen = 3 then
				getCondition = ""
			elseif qOpen = 1 then
				getCondition=" and "&cateField&" in ("&qIntro&") "
			else
				getCondition=" and "&cateField&"=0 and ("&qOpen&"=3 or ("&qOpen&"=1 and CHARINDEX(','+cast("&cateField&" as varchar)+',', ',"&qIntro&",') > 0))"
'getCondition=" and "&cateField&" in ("&qIntro&") "
			end if
		end function
		Private Sub findPower(arrPower,ByVal find_s1,ByVal find_s2,ByRef qx_open,ByRef qx_intro,ByRef qx_type)
			Dim i
			For i = 0 To ubound(arrPower,2)
				If find_s1 = arrPower(0,i) And find_s2 = arrPower(1,i) Then
					qx_open = arrPower(2,i)
					qx_intro = arrPower(3,i)
					qx_type = arrPower(4,i)
					Exit Sub
				end if
			next
			qx_open = 0
			qx_intro = "-255"
			qx_open = 0
			qx_type = 1
		end sub
		Private Sub fillInPower(s1,s2,ByRef qx_open,ByRef qx_intro)
			Dim rsPower
			If m_UsingPowerCache Then
				Call findPower(Global_Power,s1,s2,qx_open,qx_intro,"")
			else
				Set rsPower = Me.cn.execute("select qx_open,qx_intro from power  with(nolock) where ord="&uid&" and sort1="&s1&" and sort2="&s2)
				if rsPower.eof then
					qx_open = 0
					qx_intro = "-222"
					qx_open = 0
				else
					qx_open=rsPower("qx_open")
					If rsPower("qx_intro") & "" = "" Or Len(rsPower("qx_intro"))=0 Then
						qx_intro = "-222"
'If rsPower("qx_intro") & "" = "" Or Len(rsPower("qx_intro"))=0 Then
					else
						qx_intro = rsPower("qx_intro")
					end if
				end if
				rsPower.close
				set rsPower=Nothing
			end if
		end sub
		Public Sub initByRs(ByRef rs)
			Dim subRs
			configId = rs("id")
			m_subSql = rs("subSql")
			m_subCfgId = rs("subCfgId")
			If m_subCfgId > 0 Then
				Set subRs = Me.cn.execute(m_subSql&" and id="&m_subCfgId)
				If subRs.eof Then
					m_hasModule = False
					Exit Sub
				else
					m_name = Me.cn.execute(m_subSql&" and id="&m_subCfgId)(1)
				end if
			else
				m_name = rs("name")
			end if
			m_setjmId = rs("setjmId")
			m_mCondition = rs("mCondition")
			m_remindMode = rs("remindMode")
			m_qxlb = rs("qxlb")
			m_listqx = rs("listqx")
			m_detailqx = rs("detailqx")
			m_num1 = rs("num1")
			m_opened = (rs("opened") = "1")
			m_gate1 = rs("gate1")
			m_tq1 = rs("tq1")
			If m_tq1 & "" = "" Then  m_tq1 = 0
			m_fw1 = rs("fw1")
			m_moreLinkUrl = rs("moreLinkUrl")
			m_detailLinkUrl = rs("detailLinkUrl")
			m_moreLinkUrl_mobile = rs("moreLinkUrl_mobile")
			m_detailLinkUrl_mobile = rs("detailLinkUrl_mobile")
			m_canCancel = rs("canCancel")
			m_jointly = rs("jointly")
			m_titleMaxLength = rs("titleMaxLength")
			m_lastReloadDate = rs("lastReloadDate")
			m_MOrderSetting = rs("MOrderSetting")
			m_MBusinessType = rs("MBusinessType")
			m_cacheExpiredCondition = rs("cacheExpiredCondition") & ""
			m_canTQ = rs("canTQ")
			m_fwSetting = rs("fwSetting")
			If m_usingLv2Cache = True And Len(m_cacheExpiredCondition) > 0 Then
				m_cacheExpiredCondition = base64.URLDecode(base64.Base64Decode(m_cacheExpiredCondition))
				m_cacheExpiredCondition = m_cacheExpiredCondition & ";" & vbcrlf &_
				"select reminderId from ReminderPersons a  with(nolock) "&_
				"inner join reminderQueue b  with(nolock) on a.reminderId=b.id and a.cateid=" & uid &" "&_
				"and b.reminderConfig="&configId&";" & vbcrlf &_
				"select '" & Date &"' from qxlb  with(nolock) where sort1=1 "
			end if
			If Len(m_mCondition) = 0 Then
				m_hasModule = True
			else
				on error resume next
				m_hasModule = eval(base64.URLDecode(base64.Base64Decode(m_mCondition)))
				If Abs(Err.number)>0 Then
					m_hasModule = False
				end if
				On Error GoTo 0
			end if
			If m_usingLv2Cache = True Then
				Set m_cacheHelper = server.createobject(ZBRLibDLLNameSN & ".PageClass")
				Call m_cacheHelper.init(Me)
			end if
		end sub
		Public Sub init(cfgId,subCfgId)
			If InStr(cfgId,",") > 0 Then
				cfgId = Split(cfgId,",")(0)
			end if
			If Not isnumeric(cfgId) Or cfgId&""="" Then
				Response.write "参数cfgId不正确，类初始化失败！"
				Response.end
			end if
			configId = cfgId
			Dim sql,rs
			If subCfgId > 0 Then
				m_subCfgId = subCfgId
				sql = "select a.*,isnull(b.num1,4) num1,isnull(b.intro,'0') opened,isnull(b.gate1,1) gate1,b.tq1,b.fw1,"&subCfgId&" subCfgId from reminderConfigs a  with(nolock) " &_
				"left join setjm b  with(nolock) on a.setjmId=b.ord and b.cateid="&uid&" and b.subCfgId="&subCfgId&" where a.id=" & configId
			else
				sql = "select a.*,isnull(b.num1,4) num1,isnull(b.intro,'0') opened,isnull(b.gate1,1) gate1,b.tq1,b.fw1,0 subCfgId from reminderConfigs a  with(nolock) " &_
				"left join setjm b  with(nolock) on a.setjmId=b.ord and b.cateid="&uid&" where a.id=" & configId
			end if
			Set rs = Me.cn.execute(sql)
			If rs.eof Then
				Response.write "错误：未能读取到提醒配置信息！"
				Response.end
			end if
			Call initByRs(rs)
			rs.close
			Set rs=Nothing
		end sub
		Private Function getMoreLink()
			getMoreLink = "<a href=""" & moreLinkURL() & """><font style='font-weight:normal;'>更多&gt;&gt;&gt;</font></a>"
'Private Function getMoreLink()
		end function
		Public Function moreLinkURL()
			moreLinkURL = replaceTemplete(iif(m_isMobileMode,m_moreLinkURL_mobile,m_moreLinkURL))
		end function
		Private Function replaceTemplete(v)
			Dim r
			r = Replace(v,"@subId",m_subCfgId)
			r = Replace(r,"@date",date)
			r = Replace(r,"@MOrderId",m_MOrderSetting)
			r = Replace(r,"@cfgId",m_setjmId)
			replaceTemplete = r
		end function
		Private Function getTitleLink(title,orderId,cateid)
			If orderId&"" = "" Or orderId&"" = "0" Then
				getTitleLink = "【已删除数据】"
				Exit Function
			end if
			title = regEx.replace(title&"","")
			Dim url : url = m_detailLinkUrl
			If m_titleMaxLength > 0 Then
				If Len(title) > m_titleMaxLength Then title = Left(title,m_titleMaxLength-1) & "..."
'If m_titleMaxLength > 0 Then
			end if
			If title = "" Then title = "【无标题】"
			If Len(url&"") = 0 Then
				getTitleLink = title
				Exit Function
			end if
			If InStr(url,"@encodeId") > 0 Then
				url = Replace(url,"@encodeId",base64.pwurl(orderId))
			else
				url = Replace(url,"@id",orderId)
			end if
			url = replaceTemplete(url)
			If hasDetailPower(cateid) Then
				getTitleLink = "<a href='javascript:void(0)' class='remind_detail_link' onclick=""RemObj.openWin('" & url & "','remindWin"&configId&"');"">" & title & "</a>"
			else
				getTitleLink = title
			end if
		end function
		Public Function hasDetailPower(cateid)
			If m_detailqx = 0 Then
				hasDetailPower = True
			ElseIf existsPowerIntro(m_qxlb,m_detailqx,cateid) Then
				hasDetailPower = True
			else
				hasDetailPower = False
			end if
		end function
		Private Function getOrderStat(st)
			Select Case st
			Case 1:
			getOrderStat = "共享"
			Case 2:
			getOrderStat = "取消共享"
			Case 8 :
			getOrderStat = "审批中"
			Case 9 :
			getOrderStat = "待提交"
			Case 10:
			getOrderStat = "待审批"
			Case 11:
			getOrderStat = "审批通过"
			Case 12:
			getOrderStat = "审批退回"
			Case 16:
			getOrderStat = "未通过"
			Case 13:
			getOrderStat = "待审核"
			Case 14:
			getOrderStat = "审核通过"
			Case 15:
			getOrderStat = "审核退回"
			case 17:
			getOrderStat = "无需审批"
			Case Else
			End Select
		end function
		Private Function hasFieldInRs(ByRef r,ByVal fd)
			Dim kk
			For kk=0 To r.fields.count - 1
'Dim kk
				If r.fields(kk).name = fd Then
					hasFieldInRs = True
					Exit Function
				end if
			next
			hasFieldInRs = False
		end function
		Private Function openPower(x1,x2)
			Dim sql1,rs1,isOpen
			if x1<>"" and x2<>"" Then
				If m_UsingPowerCache Then
					Call findPower(Global_Power,x1,x2,isOpen,"","")
					openPower = isOpen
				else
					set rs1=server.CreateObject("adodb.recordset")
					sql1="select qx_open from power  with(nolock)  where ord="&uid&" and sort1="&x1&" and sort2="&x2&""
					rs1.open sql1,cn,1,1
					if rs1.eof Then
						openPower=0
						If x2=19 Then
							If cn.execute("select 1 from power with(nolock)  where ord="&uid&" and sort1="&x1&"").eof Then openPower = 1
						end if
					else
						openPower=rs1("qx_open")
					end if
					rs1.close
					set rs1=nothing
				end if
			else
				openPower=0
			end if
		end function
		Private Function IIf(e,v1,v2)
			If e = True Then
				iif = v1
			else
				iif = v2
			end if
		end function
		Public Function existsPowerIntro(byval sort1,byval sort2, byval CreatorID)
			Dim sql_qx,qx_type,qx_open,qx_intro
			dim i , item, hs, rs_qx
			hs = false
			for i = 0 to ubound(m_existsPowerIntro)
				if isarray(m_existsPowerIntro(i)) then
					item = m_existsPowerIntro(i)
					if item(0) = sort1 and item(1) = sort2 then
						qx_type = item(2)
						qx_open = item(3)
						qx_intro = item(4)
						hs = true
						exit for
					end if
				end if
			next
			if hs = false then
				sql_qx="select isnull(sort,0) as sort from qxlblist  with(nolock) where sort1=" & sort1 & " and sort2="& sort2
				set rs_qx=cn.execute(sql_qx)
				if not rs_qx.eof then
					qx_type=rs_qx(0)
				else
					qx_type=0
				end if
				rs_qx.close
				sql_qx="select isnull(qx_open,0) as qx_open,isnull(qx_intro,'') as qx_intro from [power]  with(nolock) where sort1=" & sort1 & " and sort2="&sort2&" and ord=" & uid
				set rs_qx=cn.execute(sql_qx)
				if not rs_qx.eof then
					qx_open=rs_qx(0)
					qx_intro=rs_qx(1)
				else
					qx_open=0
					qx_intro=""
				end if
				rs_qx.close
				set rs_qx=nothing
				redim preserve m_existsPowerIntro(m_expiCount)
				m_existsPowerIntro(m_expiCount) = split(sort1 & chr(1) & sort2 & chr(1) & qx_type & chr(1) & qx_open & chr(1) & qx_intro, chr(1))
				m_expiCount = m_expiCount+ 1
			end if
			if len(qx_open & "") = 0 then qx_open = 0
			qx_open = clng(qx_open)
			if qx_type = 1 then
				existsPowerIntro = (qx_open = 1)
			else
				if qx_open = 3 then
					existsPowerIntro = true
				elseif qx_open = 1 then
					existsPowerIntro =  CheckIntro(qx_intro,CreatorID&"")>0 And CreatorID > 0
				else
					existsPowerIntro = false
				end if
			end if
		end function
		private function CheckIntro(str1,str2)
			dim ids: ids = split(replace(str2 & ""," ",""),",")
			dim inx : inx = 0
			for n=0 to ubound(ids)
				if ids(n)&""<>"" and ids(n)&""<>"0" then
					inx = instr(","&replace(str1 & ""," ","")&",",","& ids(n) &",")
					if inx>0 then exit for
				end if
			next
			CheckIntro = inx
		end function
		Public Property Get user
		user = session("personzbintel2007") & ""
		If Len(user) = 0 Then
			user = request.querystring("__sys_uid_sign")
			if isnumeric(user)= false then
				user = 0
			else
				user = clng(user)
			end if
		end if
		End Property
		Public Property Get isAdmin
		dim rs
		if len(is_admin) = 0 then
			Set rs = cn.execute("select top1 from gate  with(nolock) where ord=" & me.user)
			if rs.eof then
				is_admin = false
			else
				is_admin = (rs.fields(0).value & "" = "1")
			end if
			rs.close
		end if
		isAdmin = is_admin
		End Property
		Public Property Get isSupperAdmin
		Dim rs
		If Len(is_supperadmin) = 0 Then
			If Me.isAdmin  Then
				Set rs = cn.execute("select qx_open from power  with(nolock) where sort1=66 and sort2=12 and ord=" & Me.User & " and qx_open=1")
				is_supperadmin = Not rs.eof
				rs.close
			else
				is_supperadmin = false
			end if
		end if
		isSupperAdmin = is_supperadmin
		End Property
		Private Function HTMLDecode(fString)
			if not isnull(fString) Then
				fString = replace(fString, "&gt;", ">")
				fString = replace(fString, "&lt;", "<")
				fString = Replace(fString, "&nbsp;",CHR(32) )
				fString = Replace(fString, "&quot;",CHR(34) )
				fString = Replace(fString, "&#39;",CHR(39) )
				fString = Replace(fString, "",CHR(13))
				fString = Replace(fString, "</P><P>",CHR(10) & CHR(10))
				fString = Replace(fString, "<br>",CHR(10))
				HTMLDecode = fString
			end if
		end function
	End Class
	Class StringBuffer
		Private m_idx
		Private m_contents
		Private m_maxIdx
		Public Sub push(v)
			m_contents(m_idx) = v : m_idx = m_idx + 1
'Public Sub push(v)
			If m_idx > m_maxIdx Then
				m_maxIdx = m_maxIdx + 500
'If m_idx > m_maxIdx Then
				ReDim Preserve m_maxIdx(m_maxIdx)
			end if
		end sub
		Public Property Get toString
		toString = Join(m_contents,"")
		End Property
		Private Sub Class_Initialize
			m_idx = 0
			m_maxIdx = 500
			ReDim m_contents(m_maxIdx)
		end sub
		Private Sub Class_Teriminate
			Erase m_contents
		end sub
	End Class
	Class ReminderList
		Private m_reminders()
		Public m_rIdx
		Public m_popIdx
		Public Sub push(remindObj)
			m_rIdx = m_rIdx + 1
'Public Sub push(remindObj)
			ReDim Preserve m_reminders(m_rIdx)
			Set m_reminders(m_rIdx) = remindObj
		end sub
		Public Function pop
			If Me.hasRemind = False Then Exit Function
			Set pop = m_reminders(m_popIdx)
			m_popIdx = m_popIdx + 1
			Set pop = m_reminders(m_popIdx)
		end function
		Public Property Get reminders
		reminders = m_reminders
		End Property
		Public Property Get hasRemind
		hasRemind = m_rIdx >=0 And m_popIdx <= m_rIdx
		End Property
		Private Sub Class_Initialize
			m_rIdx = -1
'Private Sub Class_Initialize
			m_popIdx = 0
		end sub
		Private Sub Class_Teriminate
			Dim i
			For i = 0 To ubound(m_reminders)
				Set m_reminders(i) = Nothing
			next
		end sub
	end class
	function GetDateByInventoryCost(conn,date1)
		date1 = sdk.vbl.Format(date1,"yyyy-MM-dd hh:mm:ss")
'function GetDateByInventoryCost(conn,date1)
		If conn.execute("select 1 from inventoryCost WHERE datediff(mm,date1,'"& date1 &"')=0 and complete1 >= 1").eof=False Then
			date1 = conn.execute("select convert(varchar(10),dateadd(mm,1,max(date1)), 120)+' '+convert(varchar,GETDATE(),108) from inventoryCost where complete1 >= 1")(0)
		end if
		GetDateByInventoryCost = date1
	end function
	function IsInventoryCost(conn, date1)
		IsInventoryCost = (conn.execute("select 1 from inventoryCost WHERE datediff(mm,'" + date1 + "',date1)=0 and complete1>=1 ").eof=false)
'function IsInventoryCost(conn, date1)
	end function
	Function IsHasNotionalPooling(cn,BillType ,BillIDs)
		dim ishas : ishas = false
		if len(BillIDs)>0 then
			select case BillType
			case 46001,26001:
			ishas = sdk.getSqlValue("select count(1) cnt from wageslist where wages in ("& BillIDs &") and iscostcollect=1",0)>0
			case 49002:
			ishas = sdk.getSqlValue("select count(1) cnt from O_assDeprect where id in ("& BillIDs &") and iscostcollect=1",0)>0
			end select
		end if
		IsHasNotionalPooling = ishas
	end function
	Function IsHasOrderCostsNotionalPooling(cn , BillID)
		Dim rs, msql
		Dim r : r = False
		If BillID > 0 Then
			msql ="select top 1 1 from paybx a "&_
			"   inner join paybxlist b on a.id=b.bxid and a.complete = 3 and a.del=1 and b.del=1 "&_
			"   inner join M2_OrderCostsNotionalPoolingList ocnp on b.id = ocnp.PaybxlId and ocnp.del = 1 and ocnp.FromType=1 "&_
			"   where a.id = " & BillID & " "
			Set rs = cn.execute(msql)
			r = (rs.eof=false)
			rs.close
		end if
		IsHasOrderCostsNotionalPooling  = r
	end function
	function CurrCostDate(cn)
		dim date1 : date1 = dateadd("d" , 1- day(date) , date)
'function CurrCostDate(cn)
		Dim rs : set rs = cn.execute("select dbo.[GetCurrCostMonth]() date1;")
		if rs.eof=false then
			date1 = rs("date1").value
		end if
		rs.close
		CurrCostDate =       date1
	end function
	function CostTypeID(date1)
		CostTypeID = sdk.getSqlValue("select CostType from M2_CostSet where datediff(mm,date1,'" & date1&"" & "')>=0 order by Date1 desc","2")
	end function
	Function IsCostAnalysis(cn , BillType, BillID , SortType ,date1 )
		Dim rs ,sql , msql,dsql ,costType: sql = ""
		costType = 0
		Select Case BillType:
		Case 61001:
		msql ="select k.date5 as date1 from kuin k where ord="& BillID &" and k.complete1 = 3 and k.del in (1,99) "
		Set rs = cn.execute(msql)
		If (BillID=0 And instr(",3,5,13,14,15,16,",","&SortType&",")>0) or rs.eof=False Then
			costType = 0
			If len(date1&"") = 0 Then date1 = rs("date1")
			If len(date1&"") > 0 Then
				sql = "select 1 from M2_CostComputation where (costType = "& costType &" or 0="& costType &") and complete1 >= 1 and datediff(mm,date1,'"& date1 &"')=0 "
			end if
		end if
		rs.close
		if instr(",3,5,13,14,15,16,",","&SortType&",")>0 then
			dsql = "select 1 from kuin k "&_
			" inner join kuinlist kl on kl.kuin = k.ord and kl.del = 1 and (isnull(kl.M2_QTLID,0)<>0 or isnull(kl.M2_BFID,0)<>0)  "&_
			" inner join M2_QualityTestingLists QTL on QTL.ID = kl.M2_QTLID or QTL.ID = kl.M2_BFID  "&_
			" inner join M2_QualityTestings QT on QT.id = QTL.QTID  "&_
			" inner join [M2_CostComputationList_ManuOrders] ccm on ccm.del =1 and ccm.[BillID] = (case when QT.poType in (3,4) then 1 else -1 end) * QTL.bid  "&_
			" inner join M2_QualityTestings QT on QT.id = QTL.QTID  "&_
			" where k.ord=" & BillID &" and k.complete1 = 3 and k.del = 1 and k.sort1 in (3,5,13,14,15,16) and isnull(k.fromid,0)>0 "
		end if
		Case 62001:
		msql ="select k.date5 as date1 from kuout k where ord="& BillID &" and k.complete1 = 3 and k.del in (1,99)"
		Set rs = cn.execute(msql)
		If (BillID=0 And SortType=3) or rs.eof=False Then
			costType = 0
			If len(date1&"") = 0 Then date1 = rs("date1")
			If len(date1&"") > 0 Then
				sql = "select 1 from M2_CostComputation where (costType = "& costType &" or 0="& costType &") and complete1 >= 1 and datediff(mm,date1,'"& date1 &"')=0 "
			end if
		end if
		Case 41003:
		If SortType = 0 Then
			msql ="select s.id1 from paybx a "&_
			"   inner join paybxlist b on a.id=b.bxid and a.complete = 3 "&_
			"   inner join pay syl on b.payid = syl.ord  "&_
			"   inner join paytype pt on pt.id = syl.sort "&_
			"   inner join sortonehy s on s.ord= pt.sort2  "&_
			"   where a.id = " & BillID & " and s.id1 in (5,6,7,8,9) "
			Set rs = cn.execute(msql)
			If rs.eof=False Then
				SortType = rs("id1").value
			end if
			rs.close
		end if
		dim IsMatch : IsMatch = true
		dim BillCostType : BillCostType = 0
		if len(date1)>0 then
			BillCostType = CostTypeID(date1)
		end if
		dim currCostType : currCostType = 2
		dim CostDate1 : CostDate1 = CurrCostDate(cn)
		if len(CostDate1)>0 then
			currCostType = CostTypeID(CostDate1)
		end if
		Select Case SortType
		Case 8,9 :
		msql = "select 1 from paybx a "&_
		"  inner join paybxlist b on a.id=b.bxid and a.complete = 3 "&_
		"  inner join pay syl on b.payid = syl.ord  "&_
		"  inner join paytype pt on pt.id = syl.sort "&_
		"  inner join sortonehy s on s.ord= pt.sort2 and s.id1 in (8,9)  "&_
		"  inner join M2_CostComputation cc on cc.complete1=1 and datediff(mm,cc.date1,b.datepay)=0 " &_
		"  where a.id = " & BillID &  " "
		If cn.execute(msql).eof=False Then
			costType = 0
			sql = "select 1 "
		end if
		dsql = "select 1 from paybx a "&_
		"  inner join paybxlist b on a.id=b.bxid and a.complete = 3 "&_
		"  inner join pay syl on b.payid = syl.ord  "&_
		"  inner join paytype pt on pt.id = syl.sort "&_
		"  inner join sortonehy s on s.ord= pt.sort2 and s.id1 in (8,9)  "&_
		"   inner join M2_OutOrder oo on oo.id = abs((case s.id1 when 9 then syl.gxww else -syl.zdww end))  "&_
		"  inner join sortonehy s on s.ord= pt.sort2 and s.id1 in (8,9)  "&_
		"   inner join M2_OutOrderlists ool on ool.outID = oo.id  "&_
		"   left join M2_WFP_Assigns WPA on WPA.ID= ool.WFPAID  "&_
		"   left join M2_WorkAssigns WA on WA.ID = WPA.WAID  "&_
		"   inner join [M2_CostComputationList_ManuOrders] ccm on ccm.del =1 and ccm.[BillID] = (case when (case s.id1 when 9 then syl.gxww else -syl.zdww end)>0 then isnull(WA.WAID,WA.ID) else -ool.id end)  "&_
		"   left join M2_WorkAssigns WA on WA.ID = WPA.WAID  "&_
		"   where a.id = " & BillID &  " "
		Case 7 :
		IsMatch = (currCostType=2 and currCostType=BillCostType)
		msql = "select 1 from paybx a "&_
		"  inner join paybxlist b on a.id=b.bxid and a.complete = 3 "&_
		"  inner join pay syl on b.payid = syl.ord  "&_
		"  inner join paytype pt on pt.id = syl.sort "&_
		"  inner join sortonehy s on s.ord= pt.sort2 and s.id1=7 "&_
		"  inner join M2_CostComputation cc on cc.complete1=1 and cc.costType=2 and datediff(mm,cc.date1,b.datepay)<=0 " &_
		"  where a.id = " & BillID
		If cn.execute(msql).eof=False Then
			costType = 2
			sql = "select 1 "
		end if
		dsql = "select 1 from paybx a "&_
		"  inner join paybxlist b on a.id=b.bxid and a.complete = 3 "&_
		"  inner join pay syl on b.payid = syl.ord  "&_
		"  inner join paytype pt on pt.id = syl.sort "&_
		"  inner join sortonehy s on s.ord= pt.sort2 and s.id1=7  "&_
		"   inner join [M2_CostComputationList_ManuOrders] ccm on ccm.del =1 and ccm.[MOID] = syl.scdd  "&_
		"   where a.id = " & BillID &  " "
		Case 6 :
		IsMatch = ((currCostType=1 or currCostType =3) and currCostType=BillCostType)
		msql = "select 1 from paybx a "&_
		"  inner join paybxlist b on a.id=b.bxid and a.complete = 3 "&_
		"  inner join pay syl on b.payid = syl.ord  "&_
		"  inner join paytype pt on pt.id = syl.sort "&_
		"  inner join sortonehy s on s.ord= pt.sort2 and s.id1=6 "&_
		"  inner join M2_CostComputation cc on cc.complete1=1 and cc.costType=1 and datediff(mm,cc.date1,b.datepay)<=0 " &_
		"  where a.id = " & BillID
		If cn.execute(msql).eof=False Then
			costType = 1
			sql = "select 1 "
		end if
		Case 5 :
		IsMatch = ((currCostType=1 or currCostType =3) and currCostType=BillCostType)
		msql = "select 1 from paybx a "&_
		"  inner join paybxlist b on a.id=b.bxid and a.complete = 3 "&_
		"  inner join M2_ChargeNotionalPooling  cnp on cnp.PayID = b.ID "&_
		"  inner join M2_ChargeShare cs on cnp.CSID = cs.ID and cs.complete1 = 1 and cs.del=1 "&_
		"  inner join M2_CostComputation cc on cc.complete1=1 and cc.costType=1 and datediff(mm,cc.date1,cs.date1)=0 " &_
		"  where a.id = " & BillID
		If cn.execute(msql).eof=False Then
			costType = 1
			sql = "select 1 "
		end if
		End Select
		if IsMatch=false and currCostType<>0 then
			IsCostAnalysis  = true
			exit function
		end if
		End Select
		Dim r : r = False
		If len(sql)>0 Then r= (cn.execute(sql).eof=false)
		if r = false and len(dsql)>0 then r = (cn.execute(dsql).eof=false)
		IsCostAnalysis  = r
	end function
	Function ExistsCostAnalysis(cn , BillType, BillIDs)
		Dim sql : sql = ""
		Select Case BillType:
		Case 61001:
		sql = "select 1 from kuin k inner join M2_CostComputation cc on cc.complete1 = 1 and datediff(mm,cc.date1,k.date5)=0 where k.ord in ("& BillIDs &") and k.complete1 = 3 and k.del = 1 and k.sort1 in (3,5,13,14,15,16) and isnull(k.fromid,0)>0 "
		Case 62001:
		sql = "select 1 from kuout k inner join M2_CostComputation cc on cc.complete1 = 1 and datediff(mm,cc.date1,k.date5)=0 where k.ord in ("& BillIDs &") and k.complete1 = 3 and k.del = 1 "
		End Select
		Dim r : r = False
		If len(sql)>0 Then r= (cn.execute(sql).eof=false)
		if r=false and BillType = 61001 then
			sql = "select 1 from kuin k "&_
			" inner join kuinlist kl on kl.kuin = k.ord and kl.del = 1 and (isnull(kl.M2_QTLID,0)<>0 or isnull(kl.M2_BFID,0)<>0)  "&_
			" inner join M2_QualityTestingLists QTL on QTL.ID = kl.M2_QTLID or QTL.ID = kl.M2_BFID  "&_
			" inner join M2_QualityTestings QT on QT.id = QTL.QTID  "&_
			" inner join [M2_CostComputationList_ManuOrders] ccm on ccm.del =1 and ccm.[BillID] = (case when QT.poType in (3,4) then 1 else -1 end) * QTL.bid  "&_
			" inner join M2_QualityTestings QT on QT.id = QTL.QTID  "&_
			" where k.ord in ("& BillIDs &") and k.complete1 = 3 and k.del = 1 and k.sort1 in (3,5,13,14,15,16) and isnull(k.fromid,0)>0 "
			r= (cn.execute(sql).eof=false)
		end if
		ExistsCostAnalysis  = r
	end function
	dim w,a ,b,c,d,e,f,sort1,sort2,order,m1,m2
	m1=request("ret")
	m2=request("ret2")
	MODULES=session("zbintel2010ms")
	str_Result2=""
	w=trim(request("W3"))
	if w<>"" then
		str_Result2=str_Result2+" and cateid="&w
'if w<>"" then
	end if
	if open_10_13=0 then
		str_Result2=str_Result2+" and 1=0"
'if open_10_13=0 then
	elseif open_10_13=1 then
		str_Result2=str_Result2+" and cateid in ("&intro_10_13&")"
'elseif open_10_13=1 then
	end if
	dim origin
	origin = Request("origin")
	If origin="home" Then
		query_scope = ""
	else
		query_scope = " and isnull(salaryClass,0)=0"
	end if
	if m1<>"" then
		if InstrRev(m1,"-")<7 then
'if m1<>"" then
			m1=m1&"-1"
'if m1<>"" then
		end if
	end if
	if m2<>"" then
		if InstrRev(m2,"-")<7 then
'if m2<>"" then
			m2=m2&"-1"
'if m2<>"" then
		end if
	end if
	if m2<m1 then
		m1=m2
	end if
	if m1<>"" and m2<>"" then
		str_Result2=str_Result2+" and date1>='"&m1&"' and date1<='"&m2&"'"
'if m1<>"" and m2<>"" then
	end if
	if m1="" then
		m1=cdate(year(date)&"-"&month(date)&"-1")
'if m1="" then
	end if
	if m2="" then
		m2=date
	end if
	if m2<m1 then
		m1=m2
	end if
	a=request("a")
	b=request("b")
	c=request("c")
	d=request("d")
	e=request("e")
	f=request("f")
	if a="" then
		a=1
	end if
	if a = "1" or a="3" or a="4" or a="5" then
		order="order by date3 desc,date7 desc"
	elseif a = "2" then
		order="order by money1 desc"
	else
		order="order by date7 desc"
	end if
	if a="3" then
		if Str_Result="" then
			str_Result="where year(date3)="&m2&" and month(date3)="&m1&""
		else
			Str_Result=Str_Result+"and  year(date3)="&m2&" and month(date3)="&m1&""
			str_Result="where year(date3)="&m2&" and month(date3)="&m1&""
		end if
	elseif a="4" then
		if Str_Result="" then
			str_Result="where year(date3)="&m2&""
		else
			Str_Result=Str_Result+"and  year(date3)="&m2&""
			str_Result="where year(date3)="&m2&""
		end if
	elseif a="5" then
		if Str_Result="" then
			str_Result="where date3='"&date&"'"
		else
			Str_Result=Str_Result+"and  date3='"&date&"'"
			str_Result="where date3='"&date&"'"
		end if
	end if
	if b<>"" then
		if Str_Result="" then
			str_Result="where  sort='"&b&"'"
		else
			Str_Result=Str_Result+"and  sort='"&b&"'"
			str_Result="where  sort='"&b&"'"
		end if
	end if
	if c<>"" then
		if Str_Result="" then
			str_Result="where  complete1="&c&""
		else
			Str_Result=Str_Result+"and  complete1="&c&""
			str_Result="where  complete1="&c&""
		end if
	end if
	if d<>"" then
		if Str_Result="" then
			str_Result="where  zt1="&d&""
		else
			Str_Result=Str_Result+"and  zt1="&d&""
			str_Result="where  zt1="&d&""
		end if
	end if
	if e<>"" then
		if Str_Result="" then
			str_Result="where  zt2="&e&""
		else
			Str_Result=Str_Result+"and  zt2="&e&""
			str_Result="where  zt2="&e&""
		end if
	end if
	Dim gz_sp_open
	gz_sp_open  = ZBRuntime.MC(226100)
	Dim remindId,helper
	remindId = request("remindId")
	If remindId <> "" And isnumeric(remindId) Then
		Set helper = CreateReminderHelper(conn,remindId,0)
		str_Result2 = str_Result2 & " and id in (" & helper.listSql("ids") & ")"
	end if
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
	'str_Result2 = str_Result2 & " and id in (" & helper.listSql("ids") & ")"
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body {" & vbcrlf & "    margin-top: 0px;" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & "</style>" & vbcrlf & "</head>" & vbcrlf & "<body oncontextmenu=self.event.returnValue=false class=""ReportUI"">" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "<tr>" & vbcrlf & "    <td width=""100%"" valign=""top"">" & vbcrlf & "       <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "          <tr>" & vbcrlf & "            <td class=""place"">"
	if a=0 then
		Response.write "未发放"
	elseif a=1 then
		Response.write "已发放"
	end if
	Response.write "工资表</td>" & vbcrlf & "             <td  align=""left"">&nbsp;</td>" & vbcrlf & "            <td align=""right"">&nbsp;</td>" & vbcrlf & "            <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "          </tr>" & vbcrlf & "      </table> " & vbcrlf & "   <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "     <tr class=""top resetGroupTableBg"">" & vbcrlf & "          <td width=""5%""><div align=""center""><strong>选择</strong></div></td>" & vbcrlf & "         <td width=""6%"" align=""center""><div align=""center""><strong>序号</strong></div></td>" & vbcrlf & "     <td width=""13%""><div align=""center""><strong>工资主题</strong></div></td>" & vbcrlf & "    <td width=""11%"" height=""27""><div align=""center""><strong>工资总额</strong></div></td>" & vbcrlf & "          <td width=""13%"" ><div align=""center""><strong>发放状态</strong></div></td>" & vbcrlf & "         "
	If a=0 And gz_sp_open then
		Response.write "" & vbcrlf & "      <td width=""8%"" ><div align=""center""><strong>审批人员</strong></div></td>" & vbcrlf & "     "
	end if
	If a=1 Then
		Response.write "" & vbcrlf & "       <td width=""13%""><div align=""center""><strong>支付账户</strong></div></td>" & vbcrlf & "    "
	end if
	Response.write "" & vbcrlf & "       <td width=""8%""><div align=""center""><strong>经手人</strong></div></td>" & vbcrlf & "     "
	If a=1 then
		Response.write "" & vbcrlf & "       <td width=""9%""><div align=""center""><strong>发放日期</strong></div></td>" & vbcrlf & "     "
	end if
	Response.write "" & vbcrlf & "       <td width=""23%"" ><div align=""center""><strong>操作</strong></div></td>" & vbcrlf & "       </tr>" & vbcrlf & ""
	If a = 0 Then
		hrmsql=""
		if ZBRuntime.MC(39000) then
			hrmsql=" and y.nowStatus<>4 and y.nowStatus<>2 and y.contractEnd>='"&date&"' and y.contractStart<='"&date&"'"
		end if
		if open_10_13= 3 then
			sql1= hrmsql
		else
			if open_10_13 = 0 then
				sql1=" and 1=0 "
			else
				sql1=" and y.ord in ("&intro_10_13&") "& hrmsql &" "
			end if
		end if
		sql1 = "isnull((select sum(money1) from (select x.money1*x.updown as money1 from wageslist x inner join gate_person y on x.cateid=y.ord and x.wages=wages.id and y.del=1 " & sql1 & " union all select money1 from wageslist_jj x inner join gate_person y on x.cateid=y.ord and x.wages2=wages.id and y.del=1 " & sql1 & ") t ),0) as money1"
	else
		sql1 = "isnull((select sum(money1) from (select x.money1*x.updown as money1 from wageslist x inner join gate_person y on x.cateid=y.ord and x.wages=wages.id union all select money1 from wageslist_jj x inner join gate_person y on x.cateid=y.ord and x.wages2=wages.id) t ),0) as money1"
	end if
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select id,title,isnull(money1,0)," & sql1 & ",bank,complete1,cateid,del,delcate,deldate,date1,date2,date3,date7,bz,salaryClass,ModifyStamp,isnull(complete2,1) complete2,cateid_sp, "&_
	" (select count(1) cnt from wageslist where wages=wages.id and iscostcollect=1) cnt "&_
	" from wages where del=1 "&query_scope&" and complete1="&a& str_result2&" order by date7 desc"
	rs1.open sql1,conn,1,1
	if rs1.RecordCount<=0 then
		Response.write "<tr><td  colspan='10'>没有信息!</td></tr>"
	else
		n=0
		rs1.PageSize=15
		PageCount=clng(rs1.PageCount)
		CurrPage=Request("CurrPage")
		if len(CurrPage&"")=0 Or isnumeric(CurrPage)=false then CurrPage=1
		CurrPage=clng(CurrPage)
		if CurrPage<=0 or CurrPage="" then
			CurrPage=1
		end if
		if CurrPage>=PageCount then
			CurrPage=PageCount
		end if
		BookNum=rs1.RecordCount
		rs1.absolutePage = CurrPage
		Response.write "" & vbcrlf & "        <form name=""form1"" method=""post"" action=""deleteall.asp?ord="
		Response.write rs1("id")
		Response.write "&CurrPage="
		Response.write CurrPage
		Response.write "&a="
		Response.write a
		Response.write "&b="
		Response.write b
		Response.write "&c="
		Response.write c
		Response.write """>" & vbcrlf & ""
		Dim rid,canCancel
		do until rs1.eof
			if not isnull(rs1("bz")) and rs1("bz")<>0  then
				bzflag = getrsval("select top 1 intro from sortbz where id="&rs1("bz"))
			else
				bzflag = ""
			end if
			id=rs1("id")
			If remindId <> "" Then
				rid = helper.getRemindIdByOID(id)
				canCancel = helper.canCancelOrder(rid)
			else
				canCancel = False
			end if
			money1=0
			complete1 = rs1("complete1")
			complete2 = rs1("complete2")
			if isnull(complete2) then complete2=1
			cateid_sp = rs1("cateid_sp")
			Response.write "" & vbcrlf & "     <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "     <td align=""center"" class=""name"">"
			if open_10_3=3 or CheckPurview(intro_10_3,trim(rs1("cateid")))=True then
				Response.write " " & vbcrlf & "        <input name=""selectid"" type=""checkbox"" id=""selectid"" value="""
				Response.write rs1("id")
				Response.write """ rid="""
				Response.write rid
				Response.write """>" & vbcrlf & "          "
			end if
			Response.write "</td> " & vbcrlf & "        <td align=""center"" class=""name"">"
			Response.write Rs1.recordcount-Rs1.pagesize*(currpage-1)-n
			'Response.write "</td> " & vbcrlf & "        <td align=""center"" class=""name"">"
			Response.write "</td>" & vbcrlf & "        <td align=""center"" class=""name"">" & vbcrlf & "                    "
			Response.write rs1("title")
			If canCancel Then
				Response.write "" & vbcrlf & "             <img src=""../images/alt3.gif"" class=""cancelBtn"" style=""cursor:hand"" alt=""取消提醒"" rid="""
				Response.write rid
				Response.write """ border=""0""/>" & vbcrlf & ""
			end if
			Response.write "" & vbcrlf & "             </td>" & vbcrlf & "        <td class=""name""  align=""center""><div align=""right"">"
			Response.write  bzflag&"  "&Formatnumber(zbcdbl(rs1("money1")),num_dot_xs,-1)
			Response.write "</div></td>" & vbcrlf & "        <td  class=""name""><div align=""center"">"
			If complete2 = 6 Then
				Response.write("暂存")
			else
				If gz_sp_open then
					if complete2=2 then
						Response.write("待审批")
					elseif complete2=3 then
						Response.write("审批中")
					elseif complete2=-1 then
						Response.write("审批中")
						Response.write("审批未通过")
					elseif complete2=1 then
						if complete1=0 then
							Response.write("未发放")
						elseif complete1=1 then
							Response.write("已发放")
						end if
					end if
					Response.write "<img src=""../images/jiantou.gif""><a href=""javascript:void(0)"" class=""blue2"" onClick=""loadSPmx(" & rs1("id") & ");"">审批记录</a>"
				else
					if complete1=0 then
						Response.write("未发放")
					elseif complete1=1 then
						Response.write("已发放")
					end if
				end if
			end if
			Response.write "" & vbcrlf & "             </div></td>" & vbcrlf & "    "
			If a=0 And  gz_sp_open then
				Response.write "" & vbcrlf & "     <td  class=""name""><div align=""center"">"
				if cateid_sp&""<>"" then
					set rs2 =conn.execute("select name from gate where ord="&cateid_sp&"")
					if rs2.eof=false then
						Response.write(rs2("name"))
					end if
					rs2.close
					set rs2 = nothing
				end if
				Response.write "</div></td>" & vbcrlf & ""
			end if
			cateid=""
			cateid1=rs1("cateid")
			bank=""
			if rs1("bank")<>"" then
				set rs7=server.CreateObject("adodb.recordset")
				sql7="select sort1 from sortbank where id="&rs1("bank")&""
				rs7.open sql7,conn,1,1
				if rs7.eof then
				else
					bank=rs7("sort1")
				end if
				rs7.close
				set rs7=nothing
			end if
			if rs1("cateid")<>"" then
				set rs7=server.CreateObject("adodb.recordset")
				sql7="select name from gate where ord="&rs1("cateid")&""
				rs7.open sql7,conn,1,1
				if rs7.eof then
				else
					cateid=rs7("name")
				end if
				rs7.close
				set rs7=nothing
			end if
			If a=1 then
				Response.write "" & vbcrlf & "        <td width=""13%"" class=""name"" ><div align=""center"">"
				Response.write bank
				Response.write "</div></td>" & vbcrlf & "          "
			end if
			Response.write "" & vbcrlf & "        <td width=""9%"" class=""name"" ><div align=""center"">"
			Response.write cateid
			Response.write "" & vbcrlf & "          </div></td>  " & vbcrlf & "              "
			If a=1 then
				Response.write "" & vbcrlf & "             <td width=""9%""  class=""name"" ><div align=""center"">"
				Response.write rs1("date1")
				Response.write "</div></td>" & vbcrlf & "          "
			end if
			Response.write "" & vbcrlf & "             <td class=""func""> " & vbcrlf & "                             <div align=""center"">" & vbcrlf & "                          "
			if open_10_14=3 or CheckPurview(intro_10_14,trim(rs1("cateid")))=True then
				Response.write " " & vbcrlf & "                           <input type=""button"" name=""Submit32"" value=""详情""  onClick=""javascript:window.open('content.asp?ord="
				Response.write pwurl(rs1("id"))
				Response.write "&ret="
				Response.write m1
				Response.write "&ret2="
				Response.write m2
				Response.write "','newgzwin1','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')"" >" & vbcrlf & "                                "
				Response.write m2
			end if
			if complete2 = 6 And (open_10_13=3 or CheckPurview(intro_10_13,trim(rs1("cateid")))=True) then
				Response.write " " & vbcrlf & "                           <input type=""button"" name=""Submit32"" value=""编辑""  onClick=""javascript:window.open('edit.asp?ord="
				Response.write pwurl(rs1("id"))
				Response.write "&ret="
				Response.write m1
				Response.write "&ret2="
				Response.write m2
				Response.write "','newgzwin2','width=' + 1150 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')"" >" & vbcrlf & "                               "
				'Response.write m2
			end if
			if complete2<>6 And gz_sp_open And (open_10_16=3 or CheckPurview(intro_10_16,trim(rs1("cateid")))=True) and cateid_sp=session("personzbintel2007") then
				Response.write "" & vbcrlf & "                   <input type=""button"" name=""Submit3"" value=""审批""  onClick=""javascript:window.open('set.asp?ord="
				Response.write pwurl(rs1("id"))
				Response.write "','neww3win','width=' + 600 + ',height=' + 350 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');"" >" & vbcrlf & "                                  "
				'Response.write pwurl(rs1("id"))
			end if
			if complete2=2 or complete2=-1 then
				Response.write pwurl(rs1("id"))
				Response.write "<input type=""button"" name=""Submit3"" value=""修改""  onClick=""javascript:window.open('correct.asp?ord="
				'Response.write pwurl(rs1("id"))
				Response.write "&ret="
				Response.write m1
				Response.write "&ret2="
				Response.write m2
				Response.write "','newgzwin3','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=50')"" >" & vbcrlf & "                   "
				'Response.write m2
			end if
			if (complete2=1 Or (gz_sp_open=False And complete2<>6)  ) And complete1=0 then
				Response.write "" & vbcrlf & "                   <input type=""button"" name=""Submit3"" value=""发放""  onClick=""javascript:window.open('zf.asp?id="
				Response.write pwurl(rs1("id"))
				Response.write "&ret="
				Response.write m1
				Response.write "&ret2="
				Response.write m2
				Response.write "','newgzwin4','width=' + 600 + ',height=' + 400 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')"" >" & vbcrlf & "                                  "
				'Response.write m2
			end if
			if (open_10_3=3 or (open_10_3=1 and CheckPurview(intro_10_3,trim(rs1("cateid")))=True) ) and rs1("cnt").value=0 then
				Response.write " " & vbcrlf & "                   <input type=""button"" name=""Submitdel"" value=""删除"" onClick=""if(confirm('确认删除？')){window.location.href='Delete.asp?ord="
				Response.write rs1("id")
				Response.write "&CurrPage="
				Response.write CurrPage
				Response.write "&a="
				Response.write a
				Response.write "&b="
				Response.write b
				Response.write "&c="
				Response.write c
				Response.write "'}""/>" & vbcrlf & "                                "
			end if
			Response.write "" & vbcrlf & "                    </div>" & vbcrlf & "              </td>" & vbcrlf & "        </tr>" & vbcrlf & "    "
			n=n+1
			rs1.movenext
			if rs1.eof or n>=rs1.PageSize then exit do
		loop
		Response.write "" & vbcrlf & "</table>" & vbcrlf & "   </td>" & vbcrlf & "</tr>" & vbcrlf & "   <tr>" & vbcrlf & "     <td  class=""page"">" & vbcrlf & "      <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "  <tr>" & vbcrlf & "    <td width=""10%"" height=""30""><div align=""center"">全选" & vbcrlf & "          <input type=""checkbox"" name=""checkbox2"" value=""Check All"" onClick=""mm()"">" & vbcrlf & "    </div></td>" & vbcrlf & "    <td>"
		if open_10_3=3 or CheckPurview(intro_10_3,trim(cateid1))=True then
			Response.write "   " & vbcrlf & "    <input class=""resetElementHidden"" type=image src=""../images/m_an_del.gif""   onClick=""return test();""  name=submit>" & vbcrlf & "    <input class=""resetElementShow anybutton"" type=submit value=""批量删除"" style=""display:none;"" onClick=""return test();""  name=submit>"& vbcrlf & ""
		end if
		Response.write "</td>" & vbcrlf & "    <td width=""79%""><div align=""right"">" & vbcrlf & "    "
		Response.write rs1.RecordCount
		Response.write "个 | "
		Response.write currpage
		Response.write "/"
		Response.write rs1.pagecount
		Response.write "页 | &nbsp;"
		Response.write rs1.pagesize
		Response.write "条信息/页&nbsp;&nbsp;" & vbcrlf & "        <input id=""curp1"" name=""currpage""  type=text onkeyup=""value=value.replace(/[^\d]/g,'')""  size=3  maxlength=8/>&nbsp;" & vbcrlf & "  <input type=""button"" name=""Submit422"" value=""跳转"" onClick=""window.location.href='planall.asp?currPage='+document.getElementById('curp1').value+'&a="
		Response.write rs1.pagesize
		Response.write a
		Response.write "&b="
		Response.write b
		Response.write "&c="
		Response.write c
		Response.write "&origin="
		Response.write origin
		Response.write "'""  class=""anybutton2""/>" & vbcrlf & "          "
		if currpage=1 then
			Response.write "" & vbcrlf & "          <input type=""button"" name=""Submit4"" value=""首页""  class=""page""/> <input type=""button"" name=""Submit42"" value=""上一页""  class=""page""/>" & vbcrlf & "          "
		else
			Response.write "" & vbcrlf & "          <input type=""button"" name=""Submit4"" value=""首页""   class=""page"" onClick=""window.location.href='planall.asp?currPage="
			Response.write  1
			Response.write "&a="
			Response.write a
			Response.write "&b="
			Response.write b
			Response.write "&c="
			Response.write c
			Response.write "&origin="
			Response.write origin
			Response.write "'""/> <input type=""button"" name=""Submit42"" value=""上一页""  onClick=""window.location.href='planall.asp?currPage="
			Response.write  currpage -1
			Response.write "&a="
			Response.write a
			Response.write "&b="
			Response.write b
			Response.write "&c="
			Response.write c
			Response.write "&origin="
			Response.write origin
			Response.write "'"" class=""page""/>" & vbcrlf & "          "
		end if
		if currpage=rs1.pagecount then
			Response.write "" & vbcrlf & "          <input type=""button"" name=""Submit43"" value=""下一页""  class=""page""/> <input type=""button"" name=""Submit44"" value=""尾页""  class=""page""/>" & vbcrlf & "          "
		else
			Response.write "" & vbcrlf & "         <input type=""button"" name=""Submit43"" value=""下一页""  onClick=""window.location.href='planall.asp?currPage="
			Response.write  currpage + 1
			Response.write "&a="
			Response.write a
			Response.write "&b="
			Response.write b
			Response.write "&c="
			Response.write c
			Response.write "&origin="
			Response.write origin
			Response.write "'"" class=""page""/> <input type=""button"" name=""Submit43"" value=""尾页""  onClick=""window.location.href='planall.asp?currPage="
			Response.write  rs1.PageCount
			Response.write "&a="
			Response.write a
			Response.write "&b="
			Response.write b
			Response.write "&c="
			Response.write c
			Response.write "&origin="
			Response.write origin
			Response.write "'"" class=""page""/>" & vbcrlf & "          "
		end if
		Response.write "" & vbcrlf & "    </div></td>" & vbcrlf & "  </tr>" & vbcrlf & "  <script src= ""../Script/ws_planall.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """  language=javascript></script>" & vbcrlf & "  <tr>" & vbcrlf & "    <td height=""38"" colspan=""3""><div align=""right""><p>&nbsp;" & vbcrlf & "      </p>" & vbcrlf & "    </div></td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "</form>                    " & vbcrlf & ""
	end if
	rs1.close
	set rs1=nothing
	action1="工资表"
	call close_list(1)
	Response.write "   " & vbcrlf & "" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/default/easyui.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """>" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/icon.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """>" & vbcrlf & "<script type=""text/javascript"" src=""../inc/jquery.easyui.min.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<div id=""w"" class=""easyui-window"" title=""工资表审批记录"" style=""width:700px;height:300px;padding:5px;background: #fafafa;top:200px; display:none""  closed=""true"" collapsible=""false"" minimizable=""false"" maximizable=""false"">" & vbcrlf & "    <div id=""dhtml"" region=""center"" border=""false"" style=""padding:5px;background:#fff;border:1px solid #ccc; width:660px; margin-top:10px;"">" & vbcrlf & "    </div>" & vbcrlf & "</div>   " & vbcrlf & "" & vbcrlf & "      <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "          <tr> " & vbcrlf & "                <td height=""10"" colspan=""2""><img src=""../image/pixel.gif"" width=""1"" height=""1""></td>" & vbcrlf & "              </tr> " & vbcrlf & "                       <tr>" & vbcrlf & "                      <td width=""16%"" height=""10""><div align=""right""></div></td>" & vbcrlf & "                  <td width=""84%"">&nbsp;</td>" & vbcrlf & "     </tr>" & vbcrlf & "                         <tr>" & vbcrlf & "                      <td height=""10"" colspan=""2"">&nbsp;</td>" & vbcrlf & "     </tr>" & vbcrlf & "                         <tr>" & vbcrlf & "                      <td height=""10"" colspan=""2"">&nbsp;</td>" & vbcrlf & "     </tr>" & vbcrlf & "      </table>" & vbcrlf & "       </td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	
%>
