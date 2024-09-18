<%@ language=VBScript %>
<%
	Response.Charset="UTF-8"
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
		Response.write "<!Doctype html><html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""X-UA-Compatible"" content =""IE=edge,chrome=1"">" & vbcrlf & "<meta name=""vs_targetSchema"" content=""http://schemas.microsoft.com/intellisense/ie5""/>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<meta name=""format-detection"" content=""telephone=no"">" & vbcrlf & ""
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
	
	Class VmlGraphics
		Dim Labels
		Dim Values
		Dim Ords
		Dim Pies
		Dim SumValue
		Dim Count
		Public Title
		Public Unit
		public ID
		public Url
		Public Urls
		Dim colors
		Public width
		Public height
		Public PieOffsetR
		Private PieXys
		Dim repos
		Dim nodata
		Dim maxCount
		Public backgroundColor
		Public backgroundBorder
		Public Sub class_Initialize
			ReDim Labels(0)
			ReDim Values(0)
			ReDim Ords(0)
			ReDim Urls(0)
			Colors = Split("#ff8c19;#ff1919;#ffff00;#1919ff;#00ee19;#fc0000;#3cc000;#ff19ff;#993300;#f60000",";")
			Count = 0
			width = 550
			height = 340
			PieOffsetR = 36
			maxCount = 10
			backgroundColor = "#fbfbfb"
			backgroundBorder = "1px solid #e0e0e0"
		end sub
		Public Sub Draw(ByVal mType)
			mType = LCase(mtype)
			Select Case mType
			Case "饼图" : mType = "pie"
			Case "圆锥" : mType = "cone"
			End select
			Select Case mType
			Case "pie"
			CreatePieImage 0, 0, width, height
			Case "cone"
			CreateConeImage 0, 0, width, height
			End Select
		end sub
		Public sub loadDataByRecord(ByVal rs)
			Dim c : c = rs.fields.count
			on error resume next
			If ubound(urls)<>rs.recordcount Then
				If c = 2 Then
					rs.sort =  rs(1).name  & " desc"
				else
					rs.sort =  rs(c-1).name  & " desc"
					rs.sort =  rs(1).name  & " desc"
				end if
			end if
			On Error GoTo 0
			While rs.eof = False And count < maxCount
				ReDim preserve       Labels(count)
				ReDim preserve       Values(count)
				ReDim preserve       Ords(count)
				Ords(count)=0
				If c = 2 then
					Labels(count) = rs(0).value
					Values(count) = rs(1).value
				else
					Labels(count) = rs(0).value
					Values(count) = rs(c-1).value
'Labels(count) = rs(0).value
					If c>2 Then Ords(count)=rs(c-2).value
					Labels(count) = rs(0).value
				end if
				count = count + 1
				rs.movenext
			wend
			Call InitData
		end sub
		Private Sub InitData
			Dim i, sump
			Count = ubound(Values) + 1
'Dim i, sump
			SumValue = 0
			for i = 0 To Count - 1
'SumValue = 0
				If Len(Trim(Values(i) & "")) = 0 Then Values(i) = 0
				SumValue = cdbl(SumValue) + cdbl(Values(i))*1
'If Len(Trim(Values(i) & "")) = 0 Then Values(i) = 0
			next
			ReDim Pies(count - 1)
	        'If Len(Trim(Values(i) & "")) = 0 Then Values(i) = 0
			If Count > 0 Then
				sump = 0
				for i = 0 To Count - 1
'sump = 0
					If len(Trim(Values(i) & "")) = 0 Then Values(i) = 0
					If SumValue > 0 then
						Pies(i) =  FormatNumber(cdbl(Values(i))*1.00/cdbl(SumValue), 4,-1,0,-1)
'If SumValue > 0 then
					else
						Pies(i) = 0
					end if
					sump = cdbl(sump) + cdbl(Pies(i))
					'Pies(i) = 0
				next
				nodata = CDbl(sump) = 0
				If Pies(count-1)  < 0 Then Pies(count-1) =0
'nodata = CDbl(sump) = 0
			end if
		end sub
		Private Sub AddHtml(ByRef data, ByVal html)
			Dim C : C = ubound(data) + 1
'Private Sub AddHtml(ByRef data, ByVal html)
			ReDim Preserve data(C)
			data(c) = html
		end sub
		Function showlabel(ByVal n)
			Dim nn
			If InStr(n,"_") Then
				Dim s
				s = Split(n, "_")
				nn = s(ubound(s))
			else
				nn = n
			end if
			If App.ByteLen(nn) > 12 And InStr(1, nn, "<i>",1)=0 then
				nn = "<span title='" & n & "'>…" & App.ByteRight(nn,9) & "</span>"
			else
				If Len(Trim(nn&"")) = 0 Then nn = "<i>空</i> "
			end if
			showlabel = nn
		end function
		Sub WriteHTML(ByRef html)
			Response.write Join(html, "")
			Erase html
		end sub
		function  IsOldIE()
			dim IEversion,EXP,IEver
			EXP=Request.ServerVariables("HTTP_USER_AGENT")
			if InStr(EXP, "MSIE") > 0 Then
				IEver=Split(EXP,";")(1)
				IEversion=Split(IEver,"MSIE")(1)
				if IEversion*1<9 Then
					IsOldIE=true
				end if
			elseif InStr(EXP, "Trident") > 0 Then
				IEver=Split(EXP,":")(1)
				IEversion=Split(IEver,".")(0)
				if IEversion*1<9 Then
					IsOldIE=true
				end if
			else
				IsOldIE=false
			end if
		end function
		Private Sub CreateConeImage(ByVal mLeft ,ByVal mTop,ByVal mWidth,ByVal mHeight)
			Dim html, i, ii, iii, clen, spc
			Dim imgW, imgH, imgT, imgL, dtw
			Dim w, t, c, h, x1, y1, x2, y2, x3, y3, x4, y4, y0
			Dim xlist, ylist, ct ,surl, isIE, msvdata , murl
			clen = ubound(colors)
			ReDim html(0)
			addHTML html, "<div style='position:relative;width:" & mWidth & "px;height:" & mHeight & "px'>"
			isIE=isOldIE()
			imgT = 0
			imgL = 0
			mHeight = mHeight
			mWidth =  mWidth
			imgW = mWidth - 250
'mWidth =  mWidth
			imgH = mHeight + 20
'mWidth =  mWidth
			dtw = (imgW/imgH)*0.7
			spc = 8
			t = 0.00
			ct = ubound(values)
			msvdata = imgW & "|" & imgH
			For i = 0 To ct
				c = colors(i Mod clen)
				h =  CLng(pies(i)*imgH)
				y0 = CLng(t*imgH)
				w = CLng(imgW - y0*dtw)
'y0 = CLng(t*imgH)
				x1 = CLng(y0*dtw/2)
				x2 = w + x1
'x1 = CLng(y0*dtw/2)
				y1 = y0 : y2 = y0
				y3 = CLng((t+pies(i))*imgH) : y4 = y3
'y1 = y0 : y2 = y0
				x4 = CLng((y0+h)*dtw/2)
'y1 = y0 : y2 = y0
				x3 =  CLng(imgW - x4)
'y1 = y0 : y2 = y0
				xlist = x3 - 10
'y1 = y0 : y2 = y0
				ylist = CLng((y2+y3)/2)
'y1 = y0 : y2 = y0
				If isIE then
					Call addHTML(html, "<v:shape  CoordOrig='0,0' CoordSize='" & (imgw+10) & "," & imgH & "'  path='m " & x1 & ",0 l " & x2 & ",0  l " & x3 & "," & (y3-y2) & " l " & x4 & "," & (y4-y2) & " l " & x1 & ",0 xe' style='position:absolute;top:" &  (y1+40+i*spc) & "px;left:20px;width:" & (imgw+10) & "px;height:" & imgH & "px;z-index:" & (count-i+12) & "' fillcolor='" & c & "'><o:extrusion v:ext='view' on='t'/></v:shape>")
'If isIE then
				else
					msvdata = msvdata & "|" & pies(i)
				end if
				t = t + pies(i)
				msvdata = msvdata & "|" & pies(i)
				y0 = clng(y1 + 40 + i*spc + (y3-y2)/2 - 6)
'msvdata = msvdata & "|" & pies(i)
				x1 = CLng((x2 + x3)/2 + 28)
'msvdata = msvdata & "|" & pies(i)
				w = imgW - x1 + 60
'msvdata = msvdata & "|" & pies(i)
				Call addHTML(html, "<div style='position:absolute;top:" & y0 & "px;left:" & x1 & "px;width:" & w & "px;;height:1px;overflow:hidden;background-color:#e3e4ea;z-index:" &  (count-i+100) & "'></div>")
'msvdata = msvdata & "|" & pies(i)
				Call addHTML(html, "<div style='width:200px;position:absolute;top:" & (y0-8) & "px;left:" & (x1+w+3) & "px;z-index:" &  (count-i+100) & "'>" )
'msvdata = msvdata & "|" & pies(i)
				If Len(Url)>0 Then
					murl = Url
				ElseIf ubound(Urls)>=ct Then
					murl = Urls(i)
				end if
				If murl<>"" Then
					sUrl=Replace(murl,"@ord",Ords(i))
					If instr(sUrl,"@") = 1 Then
						Call addHTML(html, "<a href='javascript:void(0);' onClick=""javascript:window.OpenNoUrl('" & Replace(sUrl,"@","") & "','newwin22','width=' + 1200 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150')"">")
'If instr(sUrl,"@") = 1 Then
					else
						Call addHTML(html, "<a href='"&sUrl&"' target=_blank>")
					end if
				end if
				Call addHTML(html, labels(i) & "：&nbsp;" & values(i) & " (百分比：" & FormatNumber(pies(i)*100,2,-1,0,-1) & "%)")
				Call addHTML(html, "<a href='"&sUrl&"' target=_blank>")
				If murl<>"" Then Call addHTML(html, "</a>")
				Call addHTML(html, "</div>")
			next
			If isIE = False Then
				randomize
				Dim cansvId : cansvId = "ID" & Replace(CDbl(now) & "", ".","") & CLng(rnd*1000)
				addHTML html , "<canvas style='position:absolute;left:20px;top:14px;' id='vml_con_" & cansvId & "' width='" & (imgW+10) & "' height='" & (imgH+20) & "'></canvas>"
'Dim cansvId : cansvId = "ID" & Replace(CDbl(now) & "", ".","") & CLng(rnd*1000)
				addHTML html , "<ajaxscript>setTimeout(""app.drawVMLCone('" & cansvId & "','" & msvdata & "')"",500);</ajaxscript>"
			end if
			t = 0.00
			AddHtml html, "</div>"
			Call WriteHTML(html)
		end sub
		Private Sub CreatePieImage(ByVal mLeft ,ByVal mTop,ByVal mWidth,ByVal mHeight)
			Dim i, ci, A1, A2, tit, zp, pc
			Dim R, zIndex, clen, c, html, items,surl
			ReDim html(0)
			ReDim PieXys(0)
			clen = ubound(colors)
			R = mWidth
			zIndex = 10000
			If R > mHeight Then R = mHeight
			R = CLng(R/2)
			R = R - PieOffsetR
'R = CLng(R/2)
			A1 = 0
			addhtml html, "<div style='position:relative;width:" & mWidth & "px;height:" & mHeight & "px;background-color:" & backgroundColor &_
			";border: & backgroundBorder & ;' name='vm_pie_sn' onmouseover='vmp_focus(this)' onmouseover='vmp_focus(this)"
			addhtml html, "<div style='height:30px;overflow:hidden;'><div style='height:8px;overflow:hidden'>&nbsp;</div><div style='color:#2f496e;font-weight:bold;text-align:center'>" & title & "</div></div>"
			Dim BrowserString,isIE
			isIE=IsOldIE()
			If Not isIE And Not nodata Then
				addhtml html, "<div id='echarts_"& Id &"' style='width:510px; height: 270px;'></div>"
				Dim valueJson ,murl
				valueJson = "["
				For i = 0 To ubound(pies)
					items = Labels(i)
					items = Replace(Replace(items&"","\","\\"),"""","\\""")
					If Len(Url)>0 Then
						murl = Url
					ElseIf ubound(Urls)>=ubound(pies) Then
						murl = Urls(i)
					end if
					sUrl = ""
					If murl<>"" Then sUrl=Replace(Replace(murl,"@ord",Ords(i)),"@","")
					valueJson = valueJson &"{value:"& values(i) &",name:"""& items &""",url:"""& sUrl &"""}"
					If i < Ubound(values) Then  valueJson = valueJson &","
				next
				valueJson = valueJson &"]"
				addhtml html, "<ajaxscript>setTimeout(function(){showECharts('pie','','"& valueJson &"','echarts_"& Id &"') },1000);</ajaxscript>"
			end if
			addhtml html, "<div style='position:absolute;left:" & CLng((mWidth-2*R)/2) & "px;'>"
			zp = 0
			pc =  ubound(pies)
			If nodata = True Then
				For i = 0 To pc
					pies(i)  = CDbl(1.00/(pc+1))
'For i = 0 To pc
				next
			end if
			For i = 0 To ubound(pies)
				If pies(i)*100 < 1 Then
					zp = zp + 1
'If pies(i)*100 < 1 Then
				end if
			next
			If nodata Then
				addhtml html, "<div class='lvw_nulldata' style='width:" & R*2 & "px;height:" & R*2 & "px;'>&nbsp;</div>"
			else
				If isIE Then
					For i = 0 To ubound(pies)
						c = colors(i Mod clen)
						A2 = CLng(A1 + pies(i)*360)
'c = colors(i Mod clen)
						items = Split(Labels(i)&" ","_")
						tit = Trim(items(ubound(items)))
						If Len(tit) = 0 Then
							tit = "<i>空</i>"
						end if
						If nodata Then
							tit = tit & "(<B>0.00%</B>)"
							c = "white"
						else
							Dim txtv
							If isnumeric(Values(i)) Then
								If InStr(title,"额")>0 then
									txtv = Replace(FormatNumber(Values(i),sdk.Info.moneynumber,-1,0,-1),",","")
'If InStr(title,"额")>0 then
								else
									txtv = Replace(FormatNumber(Values(i),sdk.Info.floatnumber,-1,0,-1),",","")
'If InStr(title,"额")>0 then
								end if
							else
								txtv = Values(i)
							end if
							tit = tit & "(<B><b>" & txtv & "，" &  FormatNumber(pies(i)*100,2,-1,0,-1) & "%</b></B>)"
							txtv = Values(i)
						end if
						If Len(Url)>0 Then
							murl = Url
						ElseIf ubound(Urls)>=ubound(pies) Then
							murl = Urls(i)
						end if
						If murl<>"" Then
							sUrl=Replace(murl,"@ord",Ords(i))
							If instr(sUrl,"@") = 1 Then
								tit="<a href='javascript:void(0);' onClick=""javascript:window.OpenNoUrl('" & Replace(sUrl,"@","") & "','newwin22','width=' + 1200 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150')"">"&tit&"</a>"
'If instr(sUrl,"@") = 1 Then
							else
								tit="<a href='"&sUrl&"' target=_blank>"&tit&"</a>"
							end if
						end if
						addhtml html, CreatePieImageItem(A1, A2, R, c,  tit, zIndex, 55, "vml_piegrs_" & Id & "_" & i, 30-zp*6, Id)
						tit="<a href='"&sUrl&"' target=_blank>"&tit&"</a>"
						A1 = A2
					next
				end if
			end if
			addhtml html, "</div>"
			AddHtml html, "</div>"
			Call WriteHTML(html)
		end sub
		Private Function CreatePieImageItem(ByVal A1, ByVal A2, ByVal R, ByVal Color, ByVal title, ByRef zIndex, ByRef rJ, ByVal htmlId, ByVal offsetY0, ByVal imgid)
			Dim html, zoom,  i
			Dim PI : PI = 3.14159265
			Dim R2 : R2 = R*2
			Dim YR : YR = CLng(Cos((rJ/180)*PI)*R - offsetY0)
'Dim R2 : R2 = R*2
			If A2 > 360 Then A2 = 360
			If A2 = 0 Then A2 = 1
			If A1 >= 360 Then A1 = 359
			if A1 < 180 then
				zIndex = zIndex + 1
'if A1 < 180 then
			else
				zIndex = zIndex - 1
'if A1 < 180 then
			end if
			If A1 = A2 And A1<=359 Then
				A2 = A1+1
'If A1 = A2 And A1<=359 Then
			end if
			zoom = 2400
			Dim fs : fs = PI*A1/180
			Dim fe : fe = PI*A2/180
			Dim sx : sx = CLng(R*sin(fs))
			Dim sy : sy = CLng(-R*cos(fs))
'Dim sx : sx = CLng(R*sin(fs))
			Dim ex : ex = CLng(R*sin(fe))
			Dim ey : ey = CLng(-R*cos(fe))
'Dim ex : ex = CLng(R*sin(fe))
			html = "<v:shape onmouseout='vml_pieout(this)' onmouseover='vml_pieover(this)' id='" & htmlId & "' style='position:absolute;z-index:" & zIndex & ";width:" & R2 & ";height:" & R2 & ";left:" & R & "px;top:" & (YR+PieOffsetR) & "px'  CoordSize='" & R2*zoom &"," & R2*zoom & "' strokeweight='0pt' StrokeColor='" & color & "' fillcolor='" & color & "'"
			html = html & " path='m " & sx*zoom & "," & sy*zoom & " l " & sx*zoom & "," & sy*zoom & " ar -" & r*zoom & ",-" & r*zoom & "," & r*zoom & "," & r*zoom & "," & ex*zoom & "," & ey*zoom & "," & sx*zoom & "," & sy*zoom & " l0,0 x e' deep='" & CLng(R/8) & "' oTop='" &  (YR+PieOffsetR) & "'>"
'eColor='" & color & "' fillcolor='" & color & "'"
			html = html & "<v:fill opacity='60293f' color2='fill lighten(200)' o:opacity2='60293f' rotate='t' angle='-135' method='linear sigma' focus='100%' type='gradient'/>"
'eColor='" & color & "' fillcolor='" & color & "'"
			html = html &  "<o:extrusion v:ext='view' on='t'  rotationangle='" & rJ & "' skewamt='0' backdepth='" & CLng(R/8) & "' viewpoint='0,0' viewpointorigin='0,0' lightposition='-50000,-50000' lightposition2='50000'/>"
'eColor='" & color & "' fillcolor='" & color & "'"
			html = html &  "</v:shape>"
			Dim Ao : Ao = CLng((A1 + A2) / 2)
'html = html &  "</v:shape>"
			Dim x1, y1, x2, y2
			x1 = CLng((R-10) * Sin(Ao*PI/180))
'Dim x1, y1, x2, y2
			y1 = CLng(-(R-10)* cos(Ao*PI/180))
'Dim x1, y1, x2, y2
			y1 = CLng(y1 * Cos(rJ*PI/180))
			x1 = x1 + R
'y1 = CLng(y1 * Cos(rJ*PI/180))
			y1 = y1 + R + PieOffsetR - offsetY0
'y1 = CLng(y1 * Cos(rJ*PI/180))
			x2 = CLng((R+10) * Sin((Ao)*PI/180))
'y1 = CLng(y1 * Cos(rJ*PI/180))
			y2 = CLng(-(R+10)* cos(Ao*PI/180))
'y1 = CLng(y1 * Cos(rJ*PI/180))
			y2 = CLng(y2 * Cos(rJ*PI/180))
			x2 = x2 + R
'y2 = CLng(y2 * Cos(rJ*PI/180))
			y2 = y2 + R  + PieOffsetR - offsetY0
'y2 = CLng(y2 * Cos(rJ*PI/180))
			Dim x3, xl, align
			align = abs(x2 > R)
			If x2 = x1 Then
				xl = 2.2
			else
				xl = (y2 - y1)/(x2-x1)
				xl = 2.2
			end if
			If ubound(PieXys) = 1 Then
				Dim oxl, oy2
				oxl = PieXys(0)
				oy2 = PieXys(1)
				If oxl*xl > 0 Then
					If align=1 Then
						If y2 - oy2 < 13 Then
'If align=1 Then
							y2 = oy2 + 13
'If align=1 Then
						end if
					else
						If oy2 - y2 < 13 Then
'If align=1 Then
							y2 = oy2 - 13
'If align=1 Then
						end if
					end if
				end if
			end if
			If align = 0 Then
				x3 = CLng(x2 - (R-abs(x2-R))*0.6 - 10)
'If align = 0 Then
			else
				x3 = CLng(x2 + (R-abs(x2-R))*0.6 + 10)
'If align = 0 Then
			end if
			html = html & "<v:line id='" & htmlId & "_l1' strokecolor='#cccccc' style='position:absolute;z-index:100000' from='" & x1 & "," & y1 & "' to='" & x2 & "," & y2 & "'/>"
			If align = 0 Then
				html = html & "<v:line id='" & htmlId & "_l2' strokecolor='#cccccc' style='position:absolute;z-index:100000' from='" & x2 & "," & y2 & "' to='" & x3 & "," & y2 & "'/>"
'If align = 0 Then
'If align = 0 Then
				html = html & "<div id='" & htmlId & "_txt' name='vmtxt_" & imgid & "' oTop='" & (y2-8) & "' style='padding-left:2px;padding-right:2px;position:absolute;z-index:100001;text-align:right;width:200px;left:" & (x3-205) & "px;top:" & (y2-8) & "px' onmouseover='__vmtxtv(this,1)' onmouseout='__vmtxtv(this,0)'>" & title & "</div>"
			else
				html = html & "<div id='" & htmlId & "_txt' name='vmtxt_" & imgid & "' oTop='" & (y2-8) & "' style='padding-left:2px;padding-right:2px;position:absolute;z-index:100001;text-align:left;width:200px;left:" & (x3+5) & "px;top:" & (y2-8) & "px' onmouseover='__vmtxtv(this,1)' onmouseout='__vmtxtv(this,0)'>" & title & "</div>"
			end if
			PieXys = Split(xl & "|" & y2 , "|")
			CreatePieImageItem = html
		end function
	End Class
	Class ImageVmlClass
		Public title
		Public sql
		Public gType
		Public dMode
		Public vname
		Public index
		Public Itype
		Public urls
		Public filterText
		Public Sub Class_Initialize()
			Itype = "pie"
			dMode = "col"
			ReDim urls(0)
		end sub
		Public Function ShowImageDivItem(ByVal cn)
			Dim img : Set img = New VmlGraphics
			on error resume next
			Dim rs : Set rs = cn.execute(sql)
			If Err.number<> 0 Then
				Response.write "<textarea style='display:none' id='GroupErrSql" & index & "'>"
				If InStr(Request.ServerVariables("LOCAL_ADDR"), "127.0.0.1")  > 0 Then Response.write sql
				Response.write "</textarea>"
				Set rs = cn.execute("select '<a href=""javascript:showgrouperrSql(" & index & ")""><b style=""color:red"">统计出错</b></a>' as n , 0 as v")
			end if
			On Error GoTo 0
			Dim msql : msql = "set nocount on;create table #nm(id int identity(1,1), n nvarchar(500), v float);"
			Dim i
			If dMode = "col" Then
				For i = 0 To rs.fields.count - 1
'If dMode = "col" Then
					msql = msql & "insert into #nm(n, v) values ('" & Replace(rs.fields(i).name,"'","''") & "','" & rs.fields(i).value & "');"
				next
				rs.close
				msql = msql & "select n, v from #nm order by id asc ;set nocount off;"
				on error resume next
				Set rs = cn.execute(msql)
				If Err.number <> 0 Then Response.write msql
			end if
			If len(filterText)>0 Then rs.Filter = filterText
			img.height = 310
			img.width = 520
			img.Urls = urls
			img.loadDataByRecord rs
			img.title = "按" & title & "统计"
			img.id = "RMG" & index
			Response.write "<div class='gmitem' style='_display:inline;' align='center'>"
			Call img.Draw(Itype)
			Response.write "</div>"
			Set img = nothing
			rs.close
		end function
	End Class
	
	response.Clear()
	dim cid,sel2,sid,fromname,DefaultID
	btime=trim(unescape(request.QueryString("btime")))
	etime=trim(unescape(request.QueryString("etime")))
	cs=trim(unescape(request.QueryString("cs")))
	IF  btime&"" = "" Then
		btime = "1999-1-1"
'IF  btime&"" = "" Then
	end if
	IF  etime&"" = "" Then
		etime = "2050-12-31"
'IF  etime&"" = "" Then
	end if
	sub close_conn
		conn.close
		set conn = nothing
	end sub
	Response.write "" & vbcrlf & "<script src='../skin/default/js/VmlGraphics.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write "'></script>" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse; border-top-width: 0px;"" bordercolor=""#C0CCDD"" class=""childTable"">" & vbcrlf & "    <tr height=""24"">" & vbcrlf & "    <td colspan=""4""><div align=""center"">审批状态</div></td>" & vbcrlf & "    <td colspan=""2""><div align=""center"">回收分析</div></td></tr>" & vbcrlf & "" & vbcrlf & "    <tr height=""24"">" & vbcrlf & "    <td width=""16%""><div align=""center"">待审批</div></td>" & vbcrlf & "    <td width=""16%""><div align=""center"">审批中</div></td>" & vbcrlf &"    <td width=""16%""><div align=""center"">审批通过</div></td>" & vbcrlf & "    <td width=""16%""><div align=""center"">审批未通过</div></td>" & vbcrlf & "    <td width=""16%""><div align=""center"">即将回收</div></td>" & vbcrlf & "    <td width=""16%""><div align=""center"">已回收</div></td>" & vbcrlf & "    </tr>" & vbcrlf & "        <tr height=""24"">" & vbcrlf & ""
	Set rs=conn.execute("exec GetFnItemzygl '"&session("personzbintel2007")&"','"&btime&"','"&etime&"','"&cs&"'")
	do while rs.eof = False
		i=i+1
'do while rs.eof = False
		IF cs&"" = "c" Then
			ordl=session("personzbintel2007")
		else
			ordl=GateGroupOrd_QX(3,1,3)
		end if
		IF i=1 Then
			titles = "result.asp?spState=1&W3="&ordl&"&ret3="&btime&"&ret4="&etime
		end if
		IF  i=2 Then
			titles = "result.asp?spState=1&spinfo=2&W3="&ordl&"&ret3="&btime&"&ret4="&etime
		end if
		IF i=3 Then
			titles = "result.asp?spinfo=3&W3="&ordl&"&ret3="&btime&"&ret4="&etime
		end if
		IF  i=5 Then
			titles = "result.asp?spinfo=5&W3="&ordl
		end if
		IF i=4 Then
			titles = "result.asp?spState=2&W3="&ordl&"&ret3="&btime&"&ret4="&etime
		end if
		IF i=6 Then
			titles = "chancetop.asp?B=2&W3="&ordl&"&spinfo=6"
		end if
		IF cs&"" = "c" Then
			Response.write "" & vbcrlf & "      <td><div align=""center""><font color=""#585858"">"
			Response.write openbutton(rs(1),titles,1200,600,150,150)
			Response.write "</font></div></td>" & vbcrlf & "    "
		ElseIF cs&"" = "s" Then
			Response.write "" & vbcrlf & "      <td><div align=""center""><font color=""#585858"">"
			Response.write openbutton(rs(1),titles,1200,600,150,150)
			Response.write "</font><IMG style=""CURSOR: hand"" onMouseOver=""javascript:ajax.regEvent('showperson"
			Response.write i
			Response.write "');ajax.addParam('partid', '0');ajax.addParam('v05', '"
			Response.write btime
			Response.write "');ajax.addParam('v06', '"
			Response.write etime
			Response.write "');showDlgDiv(ajax.send());"" border=0 src=""../images/116.png""></div></td>    " & vbcrlf & "        "
		end if
		rs.movenext
	loop
	set rs=nothing
	Response.write "</tr>        " & vbcrlf & "    </table>" & vbcrlf & "     <table  style=""BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; WORD-BREAK: break-all;width:1200px"" border=0 cellPadding=3 align=center>" & vbcrlf & "     <tr height=""24"">" & vbcrlf & "      <td align=""center"">" & vbcrlf & "       <div style='position:relative;height:300px'>" & vbcrlf & "  "
	Dim v : Set v = New VmlGraphics
	Set rs = conn.execute("exec GetFnItemzygl '"&session("personzbintel2007")&"','"&btime&"','"&etime&"','"&cs&"'")
	v.width = 580
	v.id = "aa"
	v.height = 300
	v.title = "项目资源管理TOP10"
	v.loadDataByRecord rs
	v.draw "pie"
	rs.close
	Response.write "</div>"
	Response.write "" & vbcrlf & "      </div></td></tr></table>" & vbcrlf & ""
	call close_conn
	Function openbutton(v,url,w,h,l,t)
		openbutton="<a href=""javascript:void(0);"" onClick=""javascript:window.OpenNoUrl('" & url & "','newwin22','width=' + " & w & " + ',height=' + " & h & " + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=" & l & ",top=" & t & "')"">"&v&"</a>"
'Function openbutton(v,url,w,h,l,t)
	end function
	Private Function GateGroupOrd_QX(sort1,sort2,ByVal sType)
		Dim rs,v,open1_1,intro1_1
		Set rs=conn.execute("select qx_open,qx_intro from power  where ord=" & session("personzbintel2007") & " and sort1="&sort1&" and sort2="&sort2&"")
		If Not rs.eof Then
			open1_1=rs(0).value
			intro1_1=rs(1).value&","&session("personzbintel2007")
		else
			open1_1=0
			intro1_1=0
		end if
		rs.close
		If open1_1=3  Then
			Set rs=conn.execute("select ord from gate  where del=1")
			Do While Not rs.eof
				If v="" Then
					v=rs(0).value
				else
					v=v & "," & rs(0).value
				end if
				rs.movenext
			Loop
			rs.close
		ElseIf open1_1=1 Then
			v=intro1_1
		else
			v=-1
			v=intro1_1
		end if
		If Len(v&"")=0 Then v=0
		GateGroupOrd_QX=v
	end function
	
%>
