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
	
	TdYear=year(date())
	Tdmonth=month(date())
	TdDay=day(date())
	TdStartDay=year(date())&"-"&month(date())&"-1"
'TdDay=day(date())
	TdNextMonthday=dateadd("m",1,TdStartDay)
	TdTol=datediff("d",TdStartDay,TdNextMonthday)
	TdEndDay=year(date())&"-"&month(date())&"-"&TdTol&""
'TdTol=datediff("d",TdStartDay,TdNextMonthday)
	set rslog=server.CreateObject("adodb.recordset")
	sqllog="select * from hr_KQ_config where del=0 and datediff(d,startTime,'"&date()&"')>=0 and datediff(d,endTime,'"&date()&"')<=0"
	rslog.open sqllog,conn,1,1
	if not rslog.eof then
		HR_login_M=rslog("login_M")*60
		HR_leave_M=rslog("leave_M")*60
		HR_overtime_M=rslog("overtime_M")*60
		HR_work_H=rslog("work_H")
		HR_login_Pat=rslog("login_Pat")
		HR_overtime_to_int=rslog("overtime_to_int")
		HR_hoDay_Ref=rslog("hoDay_Ref")*60
		HR_comType=rslog("companyType")
		HR_Test=rslog("publicTest")
	else
		HR_login_M=0
		HR_leave_M=0
		HR_overtime_M=8
		HR_login_Pat=4
		HR_overtime_to_int=30
		HR_work_H=1
		HR_hoDay_Ref=2*60
		HR_comType=1
		HR_Test=1
	end if
	rslog.close
	set rslog=nothing
	if isnumeric(HR_hoDay_Ref)=false then HR_hoDay_Ref=2*60
	function getCliIP()
		CliIP = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
		If CliIP = "" Or IsNull(CliIP) Then CliIP = Request.ServerVariables("REMOTE_ADDR")
		If InStr(CliIP, ",") Then CliIP = Split(CliIP, ",")(0)
		CliIP = CStr(CliIP)
		getCliIP=CliIP
	end function
	sub dayLog(rusult)
		dim thisIPStr
		thisIPStr=getCliIP()
		conn.execute "insert into  hr_Log (creator,inDate,result,ip,del) values("&session("personzbintel2007")&",'"&now()&"',"&rusult&",'"&thisIPStr&"',0)"
	end sub
	sub hr_login_C()
		set rslog1=server.CreateObject("adodb.recordset")
		sqllog1="select * from hr_LoginList where del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
		rslog1.open sqllog1,conn,1,1
		if rslog1.eof then
			Com_login_Time=getWorkClassListC(date,session("personzbintel2007"),1)
			Com_out_Time=getWorkClassListC(date,session("personzbintel2007"),2)
			if isdate(Com_login_Time)=true then
				if abs(datediff("n",Com_login_Time,now()))<=HR_hoDay_Ref then
					if datediff("s",now(),Com_login_Time)<=HR_login_M then
						conn.execute "insert into  hr_LoginList (creator,today,loginTime,del,week,kt,c_loginTime,c_outTime,result) values("&session("personzbintel2007")&",'"&date&"','"&now()&"',0,'"&WeekdayName(Weekday(Date))&"',0,'"&Com_login_Time&"','"&Com_out_Time&"','|6')"
					else
						conn.execute "insert into  hr_LoginList (creator,today,loginTime,del,week,kt,c_loginTime,c_outTime,result) values("&session("personzbintel2007")&",'"&date&"','"&now()&"',0,'"&WeekdayName(Weekday(Date))&"',0,'"&Com_login_Time&"','"&Com_out_Time&"','')"
					end if
				end if
			else
			end if
		else
		end if
		rslog1.close
		set rslog1=nothing
	end sub
	sub hr_out_C()
		dim oldresult
		set rslog1=server.CreateObject("adodb.recordset")
		sqllog1="select * from hr_LoginList where del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
		rslog1.open sqllog1,conn,1,1
		if not rslog1.eof then
			oldresult=rslog1("result")
			Com_out_Time=getWorkClassListC(date,session("personzbintel2007"),2)
			if isdate(Com_out_Time)=false then
			else
				if abs(datediff("n",Com_out_Time,now()))<=HR_hoDay_Ref then
					if datediff("s",now(),Com_out_Time)<=0 then
						if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
							if gethrResultCount(now(),now(),session("personzbintel2007"),15)>0 then
								conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','') where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
							elseif gethrResultCount(now(),now(),session("personzbintel2007"),15)=0 and oldresult="" then
								conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','')+'|15' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
							elseif gethrResultCount(now(),now(),session("personzbintel2007"),15)=0 and oldresult="" then
							else
								conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','') where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
							end if
						else
							resultStr=conn.execute("select result from  hr_LoginList  where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'")(0)
							if isnull(resultStr) or resultStr="" then
								conn.execute "update  hr_LoginList set outTime='"&now()&"',result=result+'|15' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
'if isnull(resultStr) or resultStr="" then
							else
								conn.execute "update  hr_LoginList set outTime='"&now()&"' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
							end if
						end if
					else
						if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
							conn.execute "update  hr_LoginList set outTime='"&now()&"' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
						else
							conn.execute "update  hr_LoginList set outTime='"&now()&"',result=result+'|7' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
						end if
					end if
				end if
			end if
		else
		end if
		rslog1.close
		set rslog1=nothing
	end sub
	sub hr_login_F()
		set rslog9=server.CreateObject("adodb.recordset")
		sqllog9="select top 1 * from hr_LoginList where del=0 and creator="&session("personzbintel2007")&" order by id desc"
		rslog9.open sqllog9,conn,1,1
		if rslog9.eof then
			call hr_f_LoginAdd()
		else
			hr_f_loginTime=rslog9("c_loginTime")
			hr_f_outTime=rslog9("c_outTime")
			hr_f_kt=rslog9("kt")
			hr_f_id=rslog9("id")
			if hr_f_kt="" or isnumeric(hr_f_kt)=false then hr_f_kt=0
			if isdate(hr_c_loginTime) and isdate(hr_c_outTime) then
				if datediff("d",now(),hr_f_loginTime)<=0 and datediff("d",now(),hr_f_outTime)>=0 and hr_f_kt>0 then
				else
					set rslog10=server.CreateObject("adodb.recordset")
					sqllog10="select * from hr_LoginList where del=0 and creator="&session("personzbintel2007")&" today='"&date&"'"
					rslog10.open sqllog10,conn,1,1
					if rslog10.eof then
						call hr_f_LoginAdd()
					else
					end if
					rslog10.close
					set rslog10=nothing
				end if
			else
			end if
		end if
		rslog9.close
		set rslog9=nothing
	end sub
	sub hr_f_LoginAdd()
		f_login_Time=getFcClassListC(date,session("personzbintel2007"),1)
		f_out_Time=getFcClassListC(date,session("personzbintel2007"),2)
		f_kt=getWorkKT(date,session("personzbintel2007"))
		if isnumeric(f_kt)=false then f_kt=0
		result_add=""
		if isdate(f_login_Time)=true and abs(datediff("n",f_login_Time,now()))<=HR_hoDay_Ref then
			if datediff("s",now(),f_login_Time)<=HR_login_M then
				result_add="|6"
			else
				result_add=""
			end if
			conn.execute "insert into  hr_LoginList (creator,today,loginTime,del,week,kt,c_loginTime,c_outTime,result) values("&session("personzbintel2007")&",'"&date&"','"&now()&"',0,'"&WeekdayName(Weekday(Date))&"',"&f_kt&",'"&f_login_Time&"','"&f_out_Time&"','"&result_add&"')"
		else
		end if
	end sub
	sub hr_f_LoginEdit(id)
		conn.execute "update  hr_LoginList set outTime='"&now()&"' where  del=0 and creator="&session("personzbintel2007")&" and id="&id&""
	end sub
	sub hr_out_F()
		set rslog8=server.CreateObject("adodb.recordset")
		sqllog8="select top 1 * from hr_LoginList where del=0 and creator="&session("personzbintel2007")&" order by id desc"
		rslog8.open sqllog8,conn,1,1
		if rslog8.eof then
		else
			outOld=rslog8("c_outTime")
			loginOld=rslog8("c_loginTime")
			ktOld=rslog8("kt")
			oldresult=rslog8("result")
			if ktOld="" or isnumeric(ktOld)=false then ktOld=0
			if  isdate(outOld) and isdate(loginOld)   then
				if datediff("s",loginOld,now())>=0 and datediff("s",outOld,now())<=0 and ktOld>0 then
					if abs(datediff("n",outOld,now()))<=HR_hoDay_Ref then
						if datediff("s",now(),outOld)<=0 then
							if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
								if gethrResultCount(now(),now(),session("personzbintel2007"),15)>0 then
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','') where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'"
'if gethrResultCount(now(),now(),session("personzbintel2007"),15)>0 then
								elseif gethrResultCount(now(),now(),session("personzbintel2007"),15)=0 and oldresult="" then
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','')+'|15' where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'"
'elseif gethrResultCount(now(),now(),session("personzbintel2007"),15)=0 and oldresult="" then
								else
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','') where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'"
'else
								end if
							else
								resultStr=conn.execute("select result from  hr_LoginList  where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'")(0)
'else
								if isnull(resultStr) or resultStr="" then
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=result+'|15' where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'"
'if isnull(resultStr) or resultStr="" then
								else
									conn.execute "update  hr_LoginList set outTime='"&now()&"' where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'"
'else
								end if
							end if
						else
							if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
								conn.execute "update  hr_LoginList set outTime='"&now()&"' where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'"
'if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
							else
								conn.execute "update  hr_LoginList set outTime='"&now()&"',result=result+'|7' where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'"
'if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
							end if
						end if
					end if
				elseif ktold=0 then
					TdOutTime=conn.execute("select outTime from  hr_LoginList  where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'")(0)
					Tdresult=conn.execute("select result from  hr_LoginList  where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'")(0)
					if isdate(TdoutTime)=false then exit sub
					if abs(datediff("n",TdOutTime,now()))<=HR_hoDay_Ref then
						if datediff("s",now(),TdOutTime)<=0 then
							if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
								if gethrResultCount(now(),now(),session("personzbintel2007"),15)>0 then
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','') where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
								elseif gethrResultCount(now(),now(),session("personzbintel2007"),15)=0 and Tdresult="" then
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','')+'|15' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
'elseif gethrResultCount(now(),now(),session("personzbintel2007"),15)=0 and Tdresult="" then
								else
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','') where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
								end if
							else
								Tdresult=conn.execute("select result from  hr_LoginList  where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'")(0)
								if isnull(Tdresult) or Tdresult="" then
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=result+'|15' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
'if isnull(Tdresult) or Tdresult="" then
								else
									conn.execute "update  hr_LoginList set outTime='"&now()&"' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
								end if
							end if
						else
							if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
								conn.execute "update  hr_LoginList set outTime='"&now()&"' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
							else
								conn.execute "update  hr_LoginList set outTime='"&now()&"',result=result+'|7' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
							end if
						end if
					end if
				end if
			else
			end if
		end if
		rslog8.close
		Set rslog8=Nothing
		set rslog=server.CreateObject("adodb.recordset")
		sqllog="select * from hr_LoginList where del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
		rslog.open sqllog,conn,1,1
		if rslog.eof then
		else
			outRS=rslog("c_outTime")
			if isdate(outRS) then
			end if
			conn.execute "insert into  hr_LoginList (creator,today,loginTime,del,week) values("&session("personzbintel2007")&",'"&date&"','"&now()&"',0,'"&WeekdayName(Weekday(Date))&"')"
		end if
		rslog.close
		set rslog=nothing
	end sub
	function haveLogData(num)
		dim hr_newDate
		hr_newDate=dateadd("d",-num,date)
'dim hr_newDate
		set rslog2=server.CreateObject("adodb.recordset")
		sqllog2="select * from hr_LoginList where del=0 and creator="&session("personzbintel2007")&" and today='"&hr_newDate&"'"
		rslog2.open sqllog2,conn,1,1
		if not rslog2.eof then
			haveLogData=true
		else
			haveLogData=false
		end if
		rslog2.close
		set rslog2=nothing
	end function
	function getPersonID(pid)
		set rslog3=server.CreateObject("adodb.recordset")
		sqllog3="select * from hr_PersonClass where del=0 and ','+user_list+',' like '%,"&pid&",%'"
'set rslog3=server.CreateObject("adodb.recordset")
		rslog3.open sqllog3,conn,1,1
		if not rslog3.eof then
			getPersonID=rslog3("id")
		else
			getPersonID=""
		end if
		rslog3.close
		set rslog3=nothing
	end function
	function getcomType()
		set rslog4=server.CreateObject("adodb.recordset")
		sqllog4="select * from hr_KQ_config "
		rslog4.open sqllog4,conn,1,1
		if not rslog4.eof then
			getcomType=rslog4("companyType")
		else
			getcomType=1
		end if
		rslog4.close
		set rslog4=nothing
	end function
	function getWorkClassListC(timestr,ord,result)
		dim Lg_startTimeList(6),Lg_endTimeList(6),Lg_openList(6)
		if isdate(timestr) then
			weekNum=weekday(timestr)-2
'if isdate(timestr) then
			W_today=FormatDateTime(year(timestr)&"-"&month(timestr)&"-"&day(timestr))
'if isdate(timestr) then
			set rslog=server.CreateObject("adodb.recordset")
			sqllog="select * from hr_com_time where del=0 and (isall=1 or (isall=0 and ','+cast(user_list as nvarchar)+',' like '%,"&ord&",%')) and DateDiff(d,startTime,'"&timestr&"') >=0 and DateDiff(d,endTime,'"&timestr&"')<=0"
'set rslog=server.CreateObject("adodb.recordset")
			rslog.open sqllog,conn,1,1
			if not rslog.eof then
				Lg_startTimeList(0)=W_today&" "&rslog("stime1")
				Lg_startTimeList(1)=W_today&" "&rslog("stime2")
				Lg_startTimeList(2)=W_today&" "&rslog("stime3")
				Lg_startTimeList(3)=W_today&" "&rslog("stime4")
				Lg_startTimeList(4)=(W_today&" "&rslog("stime5"))
				Lg_startTimeList(5)=(W_today&" "&rslog("stime6"))
				Lg_startTimeList(6)=(W_today&" "&rslog("stime7"))
				Lg_endTimeList(0)=(W_today&" "&rslog("etime1"))
				Lg_endTimeList(1)=(W_today&" "&rslog("etime2"))
				Lg_endTimeList(2)=(W_today&" "&rslog("etime3"))
				Lg_endTimeList(3)=(W_today&" "&rslog("etime4"))
				Lg_endTimeList(4)=(W_today&" "&rslog("etime5"))
				Lg_endTimeList(5)=(W_today&" "&rslog("etime6"))
				Lg_endTimeList(6)=(W_today&" "&rslog("etime7"))
				Lg_openList(0)=rslog("open1")
				Lg_openList(1)=rslog("open2")
				Lg_openList(2)=rslog("open3")
				Lg_openList(3)=rslog("open4")
				Lg_openList(4)=rslog("open5")
				Lg_openList(5)=rslog("open6")
				Lg_openList(6)=rslog("open7")
				for i=0 to 6
					if weekNum<>"" and weekNum=i then
						Lg_open=Lg_openList(i)
						if Lg_open=1 then
							Lg_startTime=Lg_startTimeList(i)
							Lg_endTime=Lg_endTimeList(i)
						elseif Lg_open=2 then
							Lg_startTime="0"
							Lg_endTime="0"
						end if
					end if
				next
			else
				Lg_startTime=""
				Lg_endTime=""
			end if
			rslog.close
			set rslog=nothing
		else
			Lg_startTime=""
			Lg_endTime=""
		end if
		if isnumeric(result) and result=1 then
			getWorkClassListC=Lg_startTime
		elseif isnumeric(result) and result=2 then
			getWorkClassListC=Lg_endTime
		else
			getWorkClassListC=""
		end if
	end function
	function getFcClassListC(timestr,ord,result)
		if isdate(timestr) then
			personid=getPersonID(ord)
			set rslog=server.CreateObject("adodb.recordset")
			sqllog="select * from hr_Fc_time where del=0 and personClass="&personid&" and DateDiff(d,d1,'"&timestr&"') >=0 and DateDiff(d,d2,'"&timestr&"')>=0"
			rslog.open sqllog,conn,1,1
			if not rslog.eof then
				workID=rslog("workClass")
				if workID<>"" and isnumeric(workID) then
					if workID=0 then
						getFcClassListC="0"
					else
						set rs_wi=server.CreateObject("adodb.recordset")
						sql_wi="select * from hr_dayWorkTime where del=0 and id="&workID&""
						rs_wi.open sql_wi,conn,1,1
						if not rs_wi.eof then
							W_today=FormatDateTime(year(timestr)&"-"&month(timestr)&"-"&day(timestr))
'if not rs_wi.eof then
							Lg_startTime=FormatDateTime(W_today&" "&rs_wi("dateStart"))
							Lg_endTime=rs_wi("dateEnd")
							kt=rs_wi("kt")
							if kt<>"0" then
								Lg_endTime=FormatDateTime(dateadd("d",kt,W_today)&" "&Lg_endTime)
							else
								Lg_endTime=FormatDateTime(W_today&" "&Lg_endTime)
							end if
						else
							Lg_startTime=""
							Lg_endTime=""
						end if
						rs_wi.close
						set rs_wi=nothing
					end if
				else
					Lg_startTime=""
					Lg_endTime=""
				end if
			else
				Lg_startTime=""
				Lg_endTime=""
			end if
			rslog.close
			set rslog=nothing
		else
			Lg_startTime=""
			Lg_endTime=""
		end if
		if isnumeric(result) and result=1 then
			getFcClassListC=Lg_startTime
		elseif isnumeric(result) and result=2 then
			getFcClassListC=Lg_endTime
		else
			getFcClassListC=""
		end if
	end function
	function getWorkKT(timestr,ord)
		if isdate(timestr) then
			personid=getPersonID(ord)
			set rslog=server.CreateObject("adodb.recordset")
			sqllog="select * from hr_Fc_time where del=0 and personClass="&personid&" and DateDiff(d,d1,'"&timestr&"') <=0 and DateDiff(d,d2,'"&timestr&"')<=0"
			rslog.open sqllog,conn,1,1
			if not rslog.eof then
				workID=rslog("workClass")
				if workID<>"" and isnumeric(workID) then
					set rs_wi=server.CreateObject("adodb.recordset")
					sql_wi="select * from hr_dayWorkTime where del=0 and id="&workID&""
					rs_wi.open sql_wi,conn,1,1
					if not rs_wi.eof then
						getWorkKT=rs_wi("kt")
					else
						getWorkKT=0
					end if
					rs_wi.close
					set rs_wi=nothing
				else
					getWorkKT=0
				end if
			else
				getWorkKT=0
			end if
			rslog.close
			set rslog=nothing
		else
			getWorkKT=0
		end if
	end function
	function getSalaryClassName(id)
		if id<>"" and isnumeric(id) then
			set rs_scn=server.CreateObject("adodb.recordset")
			sql_scn="select * from hr_SalaryClass where del=0 and id="&id&""
			rs_scn.open sql_scn,conn,1,1
			if not rs_scn.eof then
				getSalaryClassName=rs_scn("title")
			else
				getSalaryClassName=""
			end if
			rs_scn.close
			set rs_scn=nothing
		else
			getSalaryClassName=""
		end if
	end function
	function getSalary(flag,gateid,tsdate)
		dim pubBasicWage,pubReguldate,pubProbSalary,pubEntrydate
		tsyear=year(tsdate)
		tsmonth=month(tsdate)
		tsDay=year(tsdate)&"-"&month(tsdate)&"-1"
'tsmonth=month(tsdate)
		nextmonthday=dateadd("m",1,tsDay)
		tsTol=datediff("d",tsDay,nextmonthday)
		tsDayEnd=year(tsdate)&"-"&month(tsdate)&"-"&tsTol&""
'tsTol=datediff("d",tsDay,nextmonthday)
		set rs_s=server.CreateObject("adodb.recordset")
		sql_s="select * from hr_SalaryClass where del=0 "
		rs_s.open sql_s,conn,1,1
		if not rs_s.eof then
			redim SalaryClass(1,rs_s.recordCount)
			i=0
			do while not rs_s.eof
				SalaryClass(0,i)=rs_s("title")
				SalaryClass(1,i)=rs_s("flag")
				i=i+1
'SalaryClass(1,i)=rs_s("flag")
				rs_s.movenext
			loop
		else
			SalaryClass(0,0)=""
			SalaryClass(1,0)=""
		end if
		rs_s.close
		set rs_s=nothing
		if flag<>"" and gateid<>"" and isnumeric(gateid) then
			set rs_s=server.CreateObject("adodb.recordset")
			sql_s="select * from hr_person where del=0 and userID="&gateid&" and datediff(d,Entrydate,'"&tsDayEnd&"')>=0"
			rs_s.open sql_s,conn,1,1
			if not rs_s.eof then
				pubBasicWage=Formatnumber(cdbl(rs_s("BasicSalary")),1,-1,0,0)
'if not rs_s.eof then
				pubReguldate=rs_s("Reguldate")
				pubProbSalary=Formatnumber(cdbl(rs_s("ProbSalary")),1-1,0,0)
'pubReguldate=rs_s("Reguldate")
				pubEntrydate=rs_s("Entrydate")
				nowStatus=rs_s("nowStatus")
			else
				pubBasicWage=0
				pubProbSalary=0
				nowStatus=0
				pubReguldate=""
				pubEntrydate=""
			end if
			rs_s.close
			set rs_s=nothing
			pubWordDays=Formatnumber(getRealWordDay(tsdate,tsDayEnd,gateid),4,-1,0,0)
'set rs_s=nothing
			pubNeedWorkDays=Formatnumber(getMonthWrokDay(tsdate,tsDayEnd,gateid),4,-1,0,0)
'set rs_s=nothing
			pubBaseSalary=0
			pubLateTimes=gethrResultCount(tsdate,tsDayEnd,gate,resultid)
			if isdate(pubReguldate) and isdate(tsdate) then
				if datediff("d",pubReguldate,tsdate)>=0 and nowStatus=1 then
					pubBaseSalary=pubBasicWage
				elseif datediff("d",pubReguldate,tsdate)<0 and datediff("d",pubReguldate,tsDayEnd)<0 and nowStatus=2 then
					pubBaseSalary=pubProbSalary
				elseif  datediff("d",pubReguldate,tsdate)<0 and datediff("d",pubReguldate,tsDayEnd)>=0  and nowStatus=2 then
					if pubNeedWorkDays>0 then
						pubBaseSalary=(pubProbSalary*(datediff("d",tsdate,pubReguldate)/pubNeedWorkDays))+pubBasicWage*(pubNeedWorkDays-datediff("d",tsdate,pubReguldate)/pubNeedWorkDays)
'if pubNeedWorkDays>0 then
					else
					end if
				else
					pubBaseSalary=0
				end if
			else
				pubBaseSalary=0
			end if
			pubLateTimes=Formatnumber(gethrResultCount(tsdate,tsDayEnd,gateid,6),4,-1,0,0)
'pubBaseSalary=0
			pubLeaveTimes=Formatnumber(gethrResultCount(tsdate,tsDayEnd,gateid,7),4,-1,0,0)
'pubBaseSalary=0
			pubPersion=Formatnumber(makeWelfare(1,gateid,tsdate,tsDayEnd),4,-1,0,0)
'pubBaseSalary=0
			pubHealth=Formatnumber(makeWelfare(2,gateid,tsdate,tsDayEnd),4,-1,0,0)
'pubBaseSalary=0
			pubUnplo=Formatnumber(makeWelfare(3,gateid,tsdate,tsDayEnd),4,-1,0,0)
'pubBaseSalary=0
			pubInjury=Formatnumber(makeWelfare(4,gateid,tsdate,tsDayEnd),4,-1,0,0)
'pubBaseSalary=0
			pubMater=Formatnumber(makeWelfare(5,gateid,tsdate,tsDayEnd),4,-1,0,0)
'pubBaseSalary=0
			pubHouse=Formatnumber(makeWelfare(6,gateid,tsdate,tsDayEnd),4,-1,0,0)
'pubBaseSalary=0
			if flag<>"" then
				if instr(flag,"{基本工资}")>0 then
					flag=replace(flag,"{基本工资}",pubBaseSalary)
				end if
				if instr(flag,"{实际出勤天数}")>0 then
					flag=replace(flag,"{实际出勤天数}",pubWordDays)
				end if
				if instr(flag,"{应出勤天数}")>0 then
					flag=replace(flag,"{应出勤天数}",pubNeedWorkDays)
				end if
				if instr(flag,"{迟到次数}")>0 then
					flag=replace(flag,"{迟到次数}",pubLateTimes)
				end if
				if instr(flag,"{早退次数}")>0 then
					flag=replace(flag,"{早退次数}",pubLeaveTimes)
				end if
				if instr(flag,"{养老保险}")>0 then
					flag=replace(flag,"{养老保险}",pubPersion)
				end if
				if instr(flag,"{医疗保险}")>0 then
					flag=replace(flag,"{医疗保险}",pubHealth)
				end if
				if instr(flag,"{失业保险}")>0 then
					flag=replace(flag,"{失业保险}",pubUnplo)
				end if
				if instr(flag,"{工伤保险}")>0 then
					flag=replace(flag,"{工伤保险}",pubInjury)
				end if
				if instr(flag,"{生育保险}")>0 then
					flag=replace(flag,"{生育保险}",pubMater)
				end if
				if instr(flag,"{住房公积金}")>0 then
					flag=replace(flag,"{住房公积金}",pubHouse)
				end if
				set rs9=server.CreateObject("adodb.recordset")
				sql9="select *  from hr_KQClass where del=0 and isprice=1 and sortid in(1,2,3) and UnitType is not null and sortID<>0"
				rs9.open sql9,conn,1,1
				if not rs9.eof then
					do while not rs9.eof
						kcTitle=rs9("title")
						kcUnitType=UnitTypeName(rs9("UnitType"))
						kcOrd=rs9("id")
						kcUnit=rs9("UnitType")
						if instr(flag,"{"&kcTitle&""&kcUnitType&"}")>0 then
							flag=replace(flag,"{"&kcTitle&""&kcUnitType&"}",Formatnumber(PriceAppDay(tsdate,tsDayEnd,gateid,kcOrd,kcUnit),4,-1,0,0))
'if instr(flag,"{"&kcTitle&""&kcUnitType&"}")>0 then
						end if
						rs9.movenext
					loop
				end if
				rs9.close
				set rs9=nothing
			else
				flag=0.0
			end if
			getSalaryClassNum=strtoint(flag)
		else
			getSalaryClassNum=0
		end if
		getSalary=getSalaryClassNum
	end function
	function getRealWordDay(SDate,EDate,gateid)
		set rs_s=server.CreateObject("adodb.recordset")
		sql_s="select count(*) as co from hr_LoginList where del=0 and creator="&gateid&" and datediff(HH,loginTime,outTime)>="&HR_login_Pat&" and datediff(d,'"&SDate&"',today)>=0 and datediff(d,'"&EDate&"',today)<=0"
		rs_s.open sql_s,conn,1,1
		if not rs_s.eof then
			getRealWordDay=rs_s(0)
		else
			getRealWordDay=0
		end if
		rs_s.close
		set rs_s=nothing
	end function
	function getMonthWrokDay(cwDate,cwDayEnd,gateid)
		dim cw_open(6)
		dim tolWorkMonth
		tolWorkMonth=0
		if isdate(cwDate) and isnumeric(gateid) then
			cwDay=day(cwDate)
			cwTol=datediff("d",cwDate,cwDayEnd)
			cwDayEnd=year(cwdate)&"-"&month(cwdate)&"-"&cwTol&""
'cwTol=datediff("d",cwDate,cwDayEnd)
			if HR_comType=1 then
				for c=0 to cwTol
					thisCWDay=dateadd("d",c,cwDate)
					set rs_scn=server.CreateObject("adodb.recordset")
					sql_scn="select * from hr_com_time where del=0 and datediff(d,startTime,'"&thisCWDay&"')>=0 and datediff(d,endTime,'"&thisCWDay&"')<=0 and charindex(','+cast("&gateid&" as varchar)+',',cast(user_list as varchar))>0"
'set rs_scn=server.CreateObject("adodb.recordset")
					rs_scn.open sql_scn,conn,1,1
					if not rs_scn.eof then
						cw_open(0)=rs_scn("open7")
						cw_open(1)=rs_scn("open1")
						cw_open(2)=rs_scn("open2")
						cw_open(3)=rs_scn("open3")
						cw_open(4)=rs_scn("open4")
						cw_open(5)=rs_scn("open5")
						cw_open(6)=rs_scn("open6")
					else
					end if
					rs_scn.close
					set rs_scn=nothing
					for o=0 to ubound(cw_open)
						if cw_open(o)=1 and weekday(thisCWDay)=(o+1) then
'for o=0 to ubound(cw_open)
							tolWorkMonth=tolWorkMonth+1
'for o=0 to ubound(cw_open)
						end if
					next
					if HR_Test=1 then
						tolWorkMonth=tolWorkMonth-getHolidayTNum(cwDate,cwDayEnd,1)
'if HR_Test=1 then
						tolWorkMonth=tolWorkMonth+getHolidayTNum(cwDate,cwDayEnd,2)
'if HR_Test=1 then
					end if
				next
			elseif HR_comType=2 then
				set rs_scn=server.CreateObject("adodb.recordset")
				sql_scn="select * from hr_Fc_time where personClass=(select id from hr_PersonClass where workClass<>0 and del=0 and( (isall=0 and (','+user_list+',' like '%,"&gateid&",%') ) or isall=1)) and del=0 and datediff(d,d1,'"&cwDate&"')<=0 and datediff(d,d2,'"&cwDayEnd&"')>=0 "
				set rs_scn=server.CreateObject("adodb.recordset")
				rs_scn.open sql_scn,conn,1,1
				if not rs_scn.eof then
					do while not rs_scn.eof
						tolWorkMonth=tolWorkMonth+1
'do while not rs_scn.eof
						rs_scn.movenext
					loop
				end if
				rs_scn.close
				set rs_scn=nothing
			end if
		end if
		getMonthWrokDay=tolWorkMonth
	end function
	function getHolidayTNum(dateStart,dateEnd,typeID)
		if isdate(dateStart) then
			startYear=year(dateStart)
			endYear=year(dateEnd)
		else
			startYear=year(now())
			endYear=year(now())
		end if
		if typeID="" or isnumeric(typeID)=false then typeID=0
		noNeedWork=""
		NeedWork=""
		set rs_ghd=server.CreateObject("adodb.recordset")
		sql_ghd="select * from hr_holiday where del=0 and datediff(y,HdYear,'"&startYear&"')<=0 and datediff(y,HdYear,'"&endYear&"')>=0"
		rs_ghd.open sql_ghd,conn,1,1
		if not rs_ghd.eof then
			do while not rs_ghd.eof
				noNeedWork=noNeedWork&rs_ghd("noNeedWork")
				NeedWork=NeedWork&rs_ghd("NeedWork")
				rs_ghd.movenext
			loop
		else
			noNeedWork=""
			NeedWork=""
		end if
		rs_ghd.close
		set rs_ghd=nothing
		if typeID=1 then
			if noNeedWork<>"" and isnull(noNeedWork)=false then
				if instr(noNeedWork,"|")=1 then
					noNeedWork=right(noNeedWork,len(noNeedWork)-1)
'if instr(noNeedWork,"|")=1 then
				end if
				oldGetHolidayTArr=split(noNeedWork,"|")
				dim newHolidayTArr,newHolidayTStr
				if oldGetHolidayTArr<>"" and isnull(oldGetHolidayTArr)=false then
					for wk=0 to ubound(oldGetHolidayTArr)
						if datediff("d",dateStart,oldGetHolidayTArr(wk))>=0 and datediff("d",dateEnd,oldGetHolidayTArr(wk))<=0 then
							newHolidayTStr=newHolidayTStr&"|"&oldGetHolidayTArr(wk)
						end if
					next
				else
					newHolidayTStr=""
				end if
				if newHolidayTStr<>"" then
					if instr(newHolidayTStr,"|")=1 then
						newHolidayTStr=right(newHolidayTStr,len(newHolidayTStr)-1)
'if instr(newHolidayTStr,"|")=1 then
						getHolidayTNum=ubound(split(newHolidayTStr,"|"))+1
'if instr(newHolidayTStr,"|")=1 then
					else
						getHolidayTNum=0
					end if
				else
					getHolidayTNum=0
				end if
			else
				getHolidayTNum=0
			end if
		elseif typeID=2 then
			if NeedWork<>"" and isnull(NeedWork)=false then
				if instr(NeedWork,"|")=1 then
					NeedWork=right(NeedWork,len(NeedWork)-1)
'if instr(NeedWork,"|")=1 then
				end if
				oldGetHolidayWArr=split(NeedWork,"|")
			else
				oldGetHolidayWArr=""
			end if
			dim newHolidayWArr,newHolidayWStr
			if oldGetHolidayWArr<>"" and isnull(oldGetHolidayWArr)=false then
				for wk=0 to ubound(oldGetHolidayWArr)
					if datediff("d",dateStart,oldGetHolidayWArr(wk))>=0 and datediff("d",dateEnd,oldGetHolidayWArr(wk))<=0 then
						newHolidayWStr=newHolidayWStr&"|"&oldGetHolidayWArr(wk)
					end if
				next
			else
				newHolidayWStr=""
			end if
			if newHolidayWStr<>"" then
				if instr(newHolidayWStr,"|")=1 then
					newHolidayWStr=right(newHolidayWStr,len(newHolidayWStr)-1)
'if instr(newHolidayWStr,"|")=1 then
					getHolidayTArr=ubound(split(newHolidayWStr,"|"))+1
'if instr(newHolidayWStr,"|")=1 then
				else
					getHolidayTNum=0
				end if
			else
				getHolidayTNum=0
			end if
		else
			getHolidayTNum=0
		end if
	end function
	function getresult(str)
		resultList=""
		if str<>""  then
			reArr=split(str,"|")
			for gt=0 to ubound(reArr)
				if reArr(gt)<>"" and isnumeric(reArr(gt)) then
					resultList=resultList&" "&gethrResult(reArr(gt))
				end if
			next
		else
			resultList=""
		end if
		getresult=resultList
	end function
	function gethrResult(id)
		if id<>"" and isnumeric(id) then
			set rs_g=server.CreateObject("adodb.recordset")
			sql_g="select * from hr_KQClass where del=0 and id="&id&" and sortid=5"
			rs_g.open sql_g,conn,1,1
			if not rs_g.eof then
				kqTitle=rs_g("title")
				if id<>15 then
					gethrResult="<span style='color:#ff0000'>"&kqTitle&"</span>"
				else
					gethrResult=rs_g("title")
				end if
			else
				gethrResult=""
				kqTitle=""
			end if
			rs_g.close
			set rs_g=nothing
		else
			gethrResult=""
		end if
	end function
	function gethrResultCount(sdate,edate,gate,resultid)
		if isdate(sdate)=false then sdate=TdStartDay
		if isdate(edate)=false then edate=TdEndDay
		if gate<>"" and isnumeric(gate) and isdate(sdate) and isdate(edate) and isnumeric(resultid) then
			dim ResultList
			ResultNum=0
			set rs_g=server.CreateObject("adodb.recordset")
			sql_g="select * from hr_LoginList where del=0 and datediff(d,'"&sdate&"',today)>=0 and datediff(d,'"&edate&"',today)<=0 and creator="&gate&""
			rs_g.open sql_g,conn,1,1
			if not rs_g.eof then
				do while not rs_g.eof
					C_result="|"&rs_g("result")&"|"
					if instr(C_result,"|"&resultid&"|")>0 then
						ResultNum=ResultNum+1
'if instr(C_result,"|"&resultid&"|")>0 then
					end if
					rs_g.movenext
				loop
			else
				ResultNum=0
			end if
			rs_g.close
			set rs_g=nothing
			gethrResultCount=ResultNum
		else
			gethrResultCount=""
		end if
	end function
	function strtoint(str)
		str=trim(str)
		if str="" or isnull(str) then
			strtoint=0
			exit function
		else
			if RegTest(str,"^[\d\+\-\*\/\(\)\.]+$") then
				exit function
				set rs9=server.CreateObject("adodb.recordset")
				Errdivi=true
				if instr(str,"/")>0 then
					dividentArr=split(str,"/")
					for s=0 to ubound(dividentArr)
						if s <>0 then
							if instr(dividentArr(s),")")>0 then
								divident=split(dividentArr(s),")")(0)
							else
								divident=dividentArr(s)
							end if
							if instr(divident,"+")>0 then
								divident=split(divident,"+")(0)
							end if
							if instr(divident,"+")>0 then
								divident=split(divident,"+")(0)
							end if
							if instr(divident,"+")>0 then
								divident=split(divident,"+")(0)
							end if
							if divident="" or isnumeric(divident)=false then divident=1
							if divident=0 then Errdivi=false
						end if
					next
				end if
				if Errdivi=false then
					strtoint=0
					exit function
				end if
				sql9="select "&str&""
				rs9.open sql9,conn,1,1
				if not rs9.eof then
					strtoint=rs9(0)
				else
					strtoint=0
				end if
				rs9.close
				set rs9=nothing
			else
				strtoint=0
			end if
		end if
	end function
	Function RegExpStr(patrn, strng)
		Dim regEx, Match, Matches
		Set regEx = New RegExp
		regEx.Pattern = patrn          ' 设置模式。'"\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
'Set regEx = New RegExp
		regEx.IgnoreCase = True
		regEx.Global = True
		Set Matches = regEx.Execute(strng)
		For Each Match In Matches
			RetStr = RetStr & Match.Value & "|"
		next
		RegExpTest = RetStr
	end function
	function getWelfare(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			select case id
			case 1:getWelfare="养老保险"
			case 2:getWelfare="医疗保险"
			case 3:getWelfare="失业保险"
			case 4:getWelfare="工伤保险"
			case 5:getWelfare="生育保险"
			case 6:getWelfare="住房公积金"
			case else :getWelfare=""
			end select
		else
			getWelfare=""
		end if
	end function
	function getPersonStatus(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			select case id
			case 1:getPersonStatus="正常"
			case 2:getPersonStatus="退休"
			case 3:getPersonStatus="离职未发工资"
			case 4:getPersonStatus="离职"
			case 5:getPersonStatus="试用期"
			case 6:getPersonStatus="休职"
			case 7:getPersonStatus="离职申请"
			case else :getPersonStatus=""
			end select
		else
			getPersonStatus=""
		end if
	end function
	function makeWelfare(id,gateid,sdate,edate)
		if id<>"" and isnumeric(id) and gateid<>"" and isnumeric(gateid) then
			set rsW=server.CreateObject("adodb.recordset")
			sqlW="select * from hr_Welfare where del=0 and classid="&id&" and ((isall=0 and ','+cast(user_list as nvarchar)+',' like '%,"&gateid&",%') or isall=1) order by id desc"
'set rsW=server.CreateObject("adodb.recordset")
			rsW.open sqlW,conn,1,1
			if not rsW.eof then
				w_base=noNum(rsW("base"),0)
				w_limit=noNum(rsW("limit"),0)
				w_lower=noNum(rsW("lower"),0)
				w_Propm_person=noNum(rsW("Propm_person"),0)
				w_Propm_personJia=noNum(rsW("Propm_personJia"),0)
				if w_base=0 then
					makeWelfare=0
				else
					if w_limit>0 then
						if w_base>w_limit then
							w_base=w_limit
						end if
					end if
					if w_lower>0 then
						if w_base<w_lower then
							w_base=w_lower
						end if
					end if
					makeWelfare=w_base*(w_Propm_person*0.01)+w_Propm_personJia
					w_base=w_lower
				end if
			else
				makeWelfare=0
			end if
			rsW.close
			set rsW=nothing
		else
			makeWelfare=0
		end if
	end function
	function noNum(str,zero)
		if str="" or isnull(str) or isnumeric(str)=false then
			noNum=zero
		else
			noNum=str
		end if
	end function
	function WelfareActin(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			select case id
			case 1:WelfareActin="一月计算"
			case 2:WelfareActin="实际天数"
			case 3:WelfareActin="忽略不计"
			case else :WelfareActin=""
			end select
		else
			WelfareActin=""
		end if
	end function
	function getSorceName(id)
		if id<>"" and isnumeric(id) and isnull(id)=false then
			set rs9=server.CreateObject("adodb.recordset")
			sql9="select sort1 from gate1 where ord="&id&""
			rs9.open sql9,conn,1,1
			if rs9.eof then
				getSorceName=""
			else
				getSorceName=rs9("sort1")
			end if
			rs9.close
			set rs9=nothing
		else
			getSorceName=""
		end if
	end function
	function getAppHolidayNum(startDate,endDate,cateid,sortid,unit)
		if startDate<>"" and isdate(startDate) and endDate<>"" and isdate(endDate) and cateid<>"" and isnull(cateid)=false  and isnumeric(cateid) and sortid<>"" and isnull(sortid)=false and isnumeric(sortid) and unit<>"" then
			getAppHolidayNum=conn.execute("select dbo.HrPriceAppDay('"&startDate&"','"&endDate&"',"&cateid&","&sortid&","&unit&")")(0)
		else
			getAppHolidayNum=0
		end if
	end function
	function getAppHolidayDay(startDate,endDate,cateid,sortid)
		if startDate<>"" and isdate(startDate) and endDate<>"" and isdate(endDate) and cateid<>"" and isnull(cateid)=false  and isnumeric(cateid) and sortid<>"" and isnull(sortid)=false and isnumeric(sortid) then
			set rs9=server.CreateObject("adodb.recordset")
			sql9="select *  from hr_AppHoliday where KQClass ="&sortid&" and creator="&cateid&" and ((datediff(d,'"&startDate&"',endTime)>=0 and datediff(d,'"&endDate&"',endTime)<=0)  or (datediff(d,'"&startDate&"',startTime)>=0 and datediff(d,'"&endDate&"',startTime)<=0))"
			rs9.open sql9,conn,1,1
			if rs9.eof then
				getAppHolidayDay=0
			else
				appDayNum=0
				do while not rs9.eof
					ad_endTime=rs9("endTime")
					ad_startTime=rs9("startTime")
					if ad_endTime<>"" and isnull(ad_endTime)=false and isnull(ad_startTime)=false and ad_startTime<>"" and  isdate(ad_endTime) and isdate(ad_startTime) then appDayNum=appDayNum+(datediff("h",ad_startTime,ad_endTime))
'ad_startTime=rs9("startTime")
					rs9.movenext
				loop
				getAppHolidayDay=appDayNum
			end if
			rs9.close
			set rs9=nothing
		else
			getAppHolidayDay=0
		end if
	end function
	function PriceAppDay(startDate,endDate,cateid,sortid,unit)
		if startDate<>"" and isdate(startDate) and endDate<>"" and isdate(endDate) and cateid<>"" and isnull(cateid)=false  and isnumeric(cateid) and sortid<>"" and isnull(sortid)=false and isnumeric(sortid) then
			set rs9=server.CreateObject("adodb.recordset")
			if unit=1 then
				sql9="select count(*) as co from hr_AppHoliday where KQClass ="&sortid&"  and creator="&cateid&" and ((datediff(d,'"&startDate&"',endTime)>=0 and datediff(d,'"&endDate&"',endTime)<=0)  or (datediff(d,'"&startDate&"',startTime)>=0 and datediff(d,'"&endDate&"',startTime)<=0))"
			else
				sql9="select *  from hr_AppHoliday where KQClass ="&sortid&" and creator="&cateid&" and ((datediff(d,'"&startDate&"',endTime)>=0 and datediff(d,'"&endDate&"',endTime)<=0)  or (datediff(d,'"&startDate&"',startTime)>=0 and datediff(d,'"&endDate&"',startTime)<=0))"
			end if
			rs9.open sql9,conn,1,1
			if rs9.eof then
				PriceAppDay=0
			else
				if unit=1 then
					PriceAppDay=rs9("co")
				else
					appDayNum=0
					do while not rs9.eof
						ad_endTime=rs9("endTime")
						ad_startTime=rs9("startTime")
						if unit=2 then
							if ad_endTime<>"" and isnull(ad_endTime)=false and isnull(ad_startTime)=false and ad_startTime<>"" and  isdate(ad_endTime) and isdate(ad_startTime) then appDayNum=appDayNum+(datediff("h",ad_startTime,ad_endTime))
'if unit=2 then
						elseif unit=3 then
							if ad_endTime<>"" and isnull(ad_endTime)=false and isnull(ad_startTime)=false and ad_startTime<>"" and  isdate(ad_endTime) and isdate(ad_startTime) then appDayNum=appDayNum+(getMonthWrokDay(ad_startTime,ad_endTime,cateid))
'elseif unit=3 then
						else
							appDayNum=0
						end if
						rs9.movenext
					loop
					PriceAppDay=appDayNum
				end if
			end if
			rs9.close
			set rs9=nothing
		else
			PriceAppDay=0
		end if
	end function
	function GetKQClassName(id)
		if id<>"" and isnumeric(id) and isnull(id)=false then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select * from hr_kqclass where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				GetKQClassName=rs9("title")
				if instr(GetKQClassName,"正常")=0 and instr(GetKQClassName,"休息")=0  and instr(GetKQClassName,"放假")=0 then
					GetKQClassName="<span style=""color:#ff0000"">"&GetKQClassName&"</span>"
				end if
			else
				GetKQClassName=""
			end if
			rs9.close
			set rs9=nothing
		else
			GetKQClassName=""
		end if
	end function
	function GetKQClassName1(id)
		if id<>"" and isnumeric(id) and isnull(id)=false then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select * from hr_kqclass where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				GetKQClassName1=rs9("title")
			else
				GetKQClassName1=""
			end if
			rs9.close
			set rs9=nothing
		else
			GetKQClassName1=""
		end if
	end function
	function WorKClassLi(personSort,tday)
		if personSort<>"" and isnumeric(personSort) and isnull(personSort)=false and isdate(tday) and tday<>"" then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select workclass from hr_fc_time where personclass="&personSort&" and datediff(d,d1,'"&tday&"')>=0 and datediff(d,d2,'"&tday&"')<=0"
			rs9.open sql,conn,1,1
			if not rs9.eof then
				workclass=rs9("workclass")
			else
				workclass=0
				WorKClassLi=""
				exit function
			end if
			rs9.close
			set rs9=nothing
			if workclass=0 then
				WorKClassLi="休息"
			else
				set rs9=server.CreateObject("adodb.recordset")
				sql="select * from hr_dayWorkTime where del=0 and id="&workclass&""
				rs9.open sql,conn,1,1
				if not rs9.eof then
					WorKClassLi=rs9("title")
				else
					WorKClassLi=""
				end if
				rs9.close
				set rs9=nothing
			end if
		else
			WorKClassLi=""
		end if
	end function
	function WorKClassLiID(personSort,tday)
		if personSort<>"" and isnumeric(personSort) and isnull(personSort)=false and isdate(tday) and tday<>"" then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select workclass from hr_fc_time where personclass="&personSort&" and datediff(d,d1,'"&tday&"')>=0 and datediff(d,d2,'"&tday&"')<=0"
			rs9.open sql,conn,1,1
			if not rs9.eof then
				workclass=rs9("workclass")
			else
				workclass=0
				WorKClassLiID=0
				exit function
			end if
			rs9.close
			set rs9=nothing
			if workclass=0 then
				WorKClassLiID=0
			else
				set rs9=server.CreateObject("adodb.recordset")
				sql="select * from hr_dayWorkTime where del=0 and id="&workclass&""
				rs9.open sql,conn,1,1
				if not rs9.eof then
					WorKClassLiID=rs9("id")
				else
					WorKClassLiID=0
				end if
				rs9.close
				set rs9=nothing
			end if
		else
			WorKClassLiID=0
		end if
	end function
	function WorKClassLiColor(personSort,tday)
		if personSort<>"" and isnumeric(personSort) and isnull(personSort)=false and isdate(tday) and tday<>"" then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select workclass from hr_fc_time where personclass="&personSort&" and datediff(d,d1,'"&tday&"')>=0 and datediff(d,d2,'"&tday&"')<=0"
			rs9.open sql,conn,1,1
			if not rs9.eof then
				workclass=rs9("workclass")
			else
				workclass=0
				WorKClassLiColor=""
				exit function
			end if
			rs9.close
			set rs9=nothing
			if workclass=0 then
				WorKClassLiColor="#ffffff"
			else
				set rs9=server.CreateObject("adodb.recordset")
				sql="select * from hr_dayWorkTime where del=0 and id="&workclass&""
				rs9.open sql,conn,1,1
				if not rs9.eof then
					WorKClassLiColor=rs9("color")
					if instr(WorKClassLiColor,"#")=0 then WorKClassLiColor="#ffffff"
				else
					WorKClassLiColor="#ffffff"
				end if
				rs9.close
				set rs9=nothing
			end if
		else
			WorKClassLiColor="#ffffff"
		end if
	end function
	function GetWorKClassName(id,num)
		if num="" then num=1
		if id<>"" and isnumeric(id) and isnull(id)=false  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select * from hr_dayWorkTime where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				title=rs9("title")
				PrefixCode=rs9("PrefixCode")
			else
				title=""
				color=""
				PrefixCode=""
			end if
			rs9.close
			set rs9=nothing
			if color<>"" then
				title="<font style=color:"&color&">"&title&"</font>"
			end if
			if num=1 then
				GetWorKClassName=title
			elseif num=2 then
				GetWorKClassName=color
			elseif num=3 then
				GetWorKClassName=PrefixCode
			end if
		else
			GetWorKClassName=""
		end if
	end function
	function UnitTypeName(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			select case id
			case 1:UnitTypeName="次数"
			case 2:UnitTypeName="小时"
			case 3:UnitTypeName="天数"
			case else :
			UnitTypeName=""
			end select
		else
			UnitTypeName=""
		end if
	end function
	function UnitName(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			select case id
			case 1:UnitName="次数"
			case 2:UnitName="小时"
			case 0:UnitName="天数"
			Case 3:UnitName ="分钟"
			case else :
			UnitName=""
			end select
		else
			UnitName=""
		end if
	end function
	function TaxLvName(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			select case id
			case 1:TaxLvName="一级"
			case 2:TaxLvName="二级"
			case 3:TaxLvName="三级"
			case 4:TaxLvName="四级"
			case 5:TaxLvName="五级"
			case 6:TaxLvName="六级"
			case 7:TaxLvName="七级"
			case 8:TaxLvName="八级"
			case 9:TaxLvName="九级"
			case 10:TaxLvName="十级"
			case else :TaxLvName="无"
			end select
		else
			TaxLvName="无"
		end if
	end function
	function belongGzClass(gateid,id)
		belongGzClass=false
		if id<>"" and isnull(id)=false and isnumeric(id) and isnumeric(gateid) then
			set rs9=server.CreateObject("adodb.recordset")
			sql="declare @str varchar(500) select @str=gongzi from hr_gongziclass where isall=1 or (isall=0 and charindex(','+cast("&gateid&" as varchar)+',',','+cast(user_list as varchar)+',')>0)  select count(id) as co from sortwages where id="&id&" and  id in (select short_str from dbo.split(@str,','))"
'set rs9=server.CreateObject("adodb.recordset")
			rs9.open sql,conn,1,1
			if not rs9.eof then
				if rs9("co")>0 then
					belongGzClass=true
				else
					belongGzClass=false
				end if
			else
				belongGzClass=false
			end if
			rs9.close
			set rs9=nothing
		else
			belongGzClass=false
		end if
	end function
	function GzClassName(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select title from hr_gongziclass where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				GzClassName=rs9("title")
			else
				GzClassName=""
			end if
			rs9.close
			set rs9=nothing
		else
			GzClassName=""
		end if
	end function
	sub checkDbPerson(table,allcansee,W3,id)
		ThisHad=false
		if allcansee=1 then
			hasNum=conn.execute("select count(*) from "&table&" where del=0 and id<>"&id&"")(0)
			if hasNum>0 then
				ThisHad=true
			end if
		else
			if W3<>"" then
				hasNumStr=split(W3,",")
				for j=0 to ubound(hasNumStr)
					if hasNumStr(j)<>"" and hasNumStr(j)<>"0" then
						hasNum=conn.execute("select count(*) from "&table&" where del=0 and id<>"&id&" and (isall=1 or (isall=0 and charindex(','+cast("& hasNumStr(j) &" as varchar)+',',','+user_list+',')>0))")(0)
'if hasNumStr(j)<>"" and hasNumStr(j)<>"0" then
						if hasNum>0 then
							ThisHad=true
						end if
					end if
				next
			end if
		end if
		if thisHad then
			call jsBack("每个分组中的人员不能与别的分组重复")
		end if
	end sub
	sub DateDiffFun(typeStr,sDAte,eDate)
		if isdate(sDAte) and isdate(eDate) then
			if datediff(typeStr,sDAte,eDate)<0 then
				call jsBack("开始时间必须小于截止时间")
			end if
		else
			call jsBack("时间格式不正确")
		end if
	end sub
	sub DateDiffDoub(typeStr,sDate,eDate,sdata,edata,table,id)
		if isdate(sDAte) and isdate(eDate) then
			call DateDiffFun(typeStr,sDate,eDate)
			sql="select count("&id&") from "&table&" where del=0  and"&_
			"("&_
			"(datediff("&typeStr&","&sdata&",'"&sDate&"')>=0 and datediff("&typeStr&","&edata&",'"&sDate&"')<=0) or"&_
			"(datediff("&typeStr&","&sdata&",'"&eDate&"')>=0 and datediff("&typeStr&","&edata&",'"&eDate&"')<=0)  or"&_
			"(datediff("&typeStr&","&sdata&",'"&sDate&"')<0 and datediff("&typeStr&","&edata&",'"&eDate&"')>0)"&_
			")"
			county=conn.execute(sql)(0)
			if county>0 then
				call jsBack("时间段存在交叉！")
				call db_close : Response.end
			end if
		else
			call jsBack("时间格式不正确")
			call db_close : Response.end
		end if
	end sub
	function GetUserList(P_user_list)
		if P_user_list<>"" and isnull(P_user_list)=false and replace(replace(P_user_list,",","")," ","")<>"" then
			set rs9=server.CreateObject("adodb.recordset")
			sql_pl="select * from gate  where ord in("&P_user_list&") and dbo.HrIsShowGate('"&date()&"',ord)=1"
			rs9.open sql_pl,conn,1,1
			if not rs9.eof then
				GetUserList=""
				do while not rs9.eof
					GetUserList=GetUserList&"<span style='padding:4px'>"&rs9("name")&"</span>"
					rs9.movenext
				loop
			else
				GetUserList="无"
			end if
			rs9.close
			set rs9=nothing
		else
			GetUserList="无"
		end if
	end function
	function performClassName(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select title from hr_perform_sp where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				performClassName=rs9("title")
			else
				performClassName=""
			end if
			rs9.close
			set rs9=nothing
		else
			performClassName=""
		end if
	end function
	function performSortName(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select title from hr_perform_sort where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				performSortName=rs9("title")
			else
				performSortName=""
			end if
			rs9.close
			set rs9=nothing
		else
			performSortName=""
		end if
	end function
	function GetPerformScore(id,project,spid)
		if id<>"" and isnull(id)=false and isnumeric(id) and isnumeric(project) and isnumeric(spid)  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select score from hr_perform_score where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				GetPerformScore=rs9("score")
			else
				GetPerformScore=0
			end if
			rs9.close
			set rs9=nothing
		else
			GetPerformScore=0
		end if
	end function
	function taxSortName(id)
		if id<>"" and isnull(id)=false  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select title from hr_PersonTaxSort where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				taxSortName=rs9("title")
			else
				taxSortName=""
			end if
			rs9.close
			set rs9=nothing
		else
			taxSortName=""
		end if
	end function
	function KQClassUnitName(id)
		if id<>"" and isnull(id)=false  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select UnitType from hr_KQClass where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				KQClassUnitName=UnitTypeName(rs9("UnitType"))
			else
				KQClassUnitName=""
			end if
			rs9.close
			set rs9=nothing
		else
			KQClassUnitName=""
		end if
	end function
	function KQClassTitle(id)
		if id<>"" and isnull(id)=false  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select title from hr_KQClass where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				KQClassTitle=(rs9("title"))
			else
				KQClassTitle=""
			end if
			rs9.close
			set rs9=nothing
		else
			KQClassTitle=""
		end if
	end function
	function KQClassSort(id)
		if id<>"" and isnull(id)=false  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select  title  from hr_KQClass where del=0 and id=(select top 1 sortid from hr_KQClass where del=0 and id="&id&")"
			rs9.open sql,conn,1,1
			if not rs9.eof then
				KQClassSort=(rs9("title"))
			else
				KQClassSort=""
			end if
			rs9.close
			set rs9=nothing
		else
			KQClassSort=""
		end if
	end function
	function todayWorkColor(today,uid)
		if today<>"" and isdate(today)=true and uid<>""  then
			todayID=conn.execute("select dbo.HrTodayNeedWork('"&today&"',"&uid&")")(0)
			select case todayID
			case 1 todayWorkColor="hrNomer"
			case 2 todayWorkColor="hrTest"
			case 3 todayWorkColor="hrHoliday"
			case 4 todayWorkColor="hrNWork"
			case else todayWorkColor="Dday"
			end select
		else
			todayWorkColor="hrNoWrite"
		end if
	end function
	function todayKQResult(today,uid)
		if today<>"" and isdate(today)=true and uid<>"" then
			if  datediff("d",now(),today)>0  then
				todayKQResult=""
			else
				if conn.execute("select dbo.HrIsShowGate('"&today&"','"&uid&"')")(0)=1 then
					todayKQResult=conn.execute("select dbo.HrKQClassName(dbo.HrGetKQResult('"&today&"',"&uid&"))")(0)
				else
					todayKQResult=""
				end if
			end if
		else
			todayKQResult=""
		end if
	end function
	sub hrDelPower(id,table,openStr,intro)
		if openStr=3 then
			sql="select count(*) as co from "&table&" where del=0 and id="&id&" "
		elseif openStr=1 then
			sql="select count(*) as co from "&table&" where del=0 and id="&id&"  and  creator in("&intro&")"
		else
			call jsBack("您目前没有该单据的删除权限！")
			call db_close : Response.end
		end if
		set rs9=server.CreateObject("adodb.recordset")
		rs9.open sql,conn,1,1
		if not rs9.eof then
			if rs9("co")>0 then
				exit sub
			else
				call jsBack("您目前没有该单据的删除权限！")
				call db_close : Response.end
			end if
		else
			call jsBack("您目前没有该单据的删除权限！")
			call db_close : Response.end
		end if
		rs9.close
		set rs9=nothing
	end sub
	sub chkdoub(table,data1,val1,id)
		set rs9=server.CreateObject("adodb.recordset")
		sql9="select "&data1&" from "&table&" where "&data1&"='"&val1&"' and id<>"&id&""
		rs9.open sql9,conn,1,1
		if not  rs9.eof then
			call jsAlert("编号不能重复！")
			call db_close : Response.end
		end if
		rs9.close
		set rs9=nothing
	end sub
	sub chkgate(table,data1,val1,id)
		set rs9=server.CreateObject("adodb.recordset")
		sql9="select "&data1&" from "&table&" where "&data1&"='"&val1&"' and ord<>"&id&""
		rs9.open sql9,conn,1,1
		if not  rs9.eof then
			call jsAlert("编号不能重复！")
			call db_close : Response.end
		end if
		rs9.close
		set rs9=nothing
	end sub
	function getW3(strW1,strW2,strW3,nowstatus)
		dim i,status, sW4
		status=""
		If nowstatus<>"" Then status = " and nowstatus in ("& nowstatus &")"
		sW3 = Replace(strW3 & ""," ","")
		For i = 0 To 5
			sW3 = Replace(sW3,  ",,", ",")
		next
		If Len(sW3 & "") = 0 Then sW3 = "0"
		If status<>"" Then
			Set rs=conn.execute("select userid from hr_person where userid in ("&sW3&")" & status )
			If Not rs.eof Then
				While Not rs.eof
					sW4=rs("userid")&","&sW4
					rs.movenext
				wend
				sW3=Left(Trim(sW4),Len(Trim(sW4))-1)
				sW4=rs("userid")&","&sW4
			end if
			rs.close
			Set rs=Nothing
		end if
		getW3=sW3
	end function
	function getLimitedW3(strw3,stype,sort1,sort2,cid)
		dim i
		if (stype<>1 and stype<>2) or not isnumeric(sort1) or not isnumeric(sort2) or not isnumeric(cid) then
			Response.write "参数错误"
			call db_close : Response.end
		end if
		if strw3="-1" or strw3="0" then
			call db_close : Response.end
			getLimitedW3=strW3
		else
			if stype=1 then
				sql="select qx_open,qx_intro from power where sort1="&sort1&" and sort2="&sort2&" and ord="& cid
			elseif stype=2 then
				sql="select qx_open,w3 from power2 where sort1="&sort1&" and cateid="& cid
			end if
			set rs=conn.execute(sql)
			if not rs.eof then
				qx_open=rs(0)
				pw3=replace(rs(1)," ","")
			else
				qx_open=0
				pw3=""
			end if
			rs.close
			if qx_open="1" then
				tmp=split(strw3,",")
				tmpW3=""
				for i=0 to ubound(tmp)
					if instr(1,","&pw3&",",","&tmp(i)&",")>0 then
						if tmpW3="" then
							tmpW3=tmp(i)
						else
							tmpW3=tmpW3&","&tmp(i)
						end if
					end if
				next
				getLimitedW3=tmpW3
			elseif qx_open="0" then
				getLimitedW3="0"
			elseif qx_open="3" then
				getLimitedW3=strw3
			end if
		end if
	end function
	function getW1W2(strW3)
		dim rtnW1,rtnW2,frs,fsql
		rtnW1=""
		rtnW2=""
		if strW3<>"" then
			fsql="select sorce,sorce2 from gate where ord in ("&strW3&")"
			set frs=conn.execute(fsql)
			while not frs.eof
				if rtnW1="" then
					rtnW1=frs(0)
				else
					rtnW1=rtnW1&","&frs(0)
				end if
				if rtnW2="" then
					rtnW2=frs(1)
				else
					rtnW2=rtnW2&","&frs(1)
				end if
				frs.movenext
			wend
			frs.close
		end if
		if rtnW1="" then rtnW1="0"
		if rtnW2="" then rtnW2="0"
		getW1W2=rtnW1&";"&rtnW2
	end function
	function getW3WithLock(strW1,strW2,strW3)
		sW1=strW1:sW2=strW2:sW3=strW3
		W2list=0:W2list2=0:W3list=0:W3list2=0
		if sW1="" then sW1=0
		if sW2="" then sW2=0
		if sW3="" then sW3=0
		if sW1<>"" then
			set rsfunc=server.CreateObject("adodb.recordset")
			sql1="select ord from gate1  where ord in  ("&sW1&") order by gate1 asc"
			rsfunc.open sql1,conn,1,1
			if not rsfunc.eof then
				gate2="true"
				do until rsfunc.eof
					W2list=0
					set rs2=server.CreateObject("adodb.recordset")
					sql2="select ord from gate2  where sort1="&rsfunc("ord")&" order by gate2 asc"
					rs2.open sql2,conn,1,1
					if rs2.eof then
						gate2="false"
					else
						do until rs2.eof
							Products=rs2("ord")
							If CheckPurview(sW2,trim(Products))=True Then
								W2list="0"
								exit do
							else
								W2list=W2list&","&Products
							end if
							rs2.movenext
						loop
					end if
					rs2.close
					set rs2=nothing
					set rs2=server.CreateObject("adodb.recordset")
					sql2="select ord from gate where sorce="&rsfunc("ord")&" order by ord asc"
					rs2.open sql2,conn,1,1
					if not rs2.eof then
						do until rs2.eof
							Products=rs2("ord")
							If CheckPurview(sW3,trim(Products))=True Then
								W2list="0"
								exit do
							end if
							rs2.movenext
						loop
					end if
					rs2.close
					set rs2=nothing
					if W2list<>"0" or gate2="false" then
						set rs2=server.CreateObject("adodb.recordset")
						sql2="select ord from gate  where sorce="&rsfunc("ord")&" and cateid=2 order by ord asc"
						rs2.open sql2,conn,1,1
						if not rs2.eof then
							do until rs2.eof
								Products=rs2("ord")
								If CheckPurview(sW3,trim(Products))<>True Then
									sW3=sW3&","&Products
								end if
								rs2.movenext
							loop
						end if
						rs2.close
						set rs2=nothing
					end if
					W2list2=W2list2&","&W2list
					rsfunc.movenext
				loop
			end if
			rsfunc.close
			set rsfunc=nothing
		end if
		sW2 =sW2&","&W2list2
		if sW2<>"" and sW2<>"0" then
			set rsfunc=server.CreateObject("adodb.recordset")
			sql1="select ord from gate2  where ord in  ("&sW2&") order by gate2 desc"
			rsfunc.open sql1,conn,1,1
			if not rsfunc.eof then
				do until rsfunc.eof
					W3list="0"
					set rs2=server.CreateObject("adodb.recordset")
					sql2="select ord from gate  where sorce2="&rsfunc("ord")&" order by ord asc"
					rs2.open sql2,conn,1,1
					if not rs2.eof then
						do until rs2.eof
							Products =rs2("ord")
							If CheckPurview(sW3,trim(Products))=True Then
								W3list="0"
								exit do
							else
								W3list =W3list&","&Products
							end if
							rs2.movenext
						loop
					end if
					rs2.close
					set rs2=nothing
					if W3list<>"" then
						W3list2 = W3list2&","&W3list
					end if
					rsfunc.movenext
				loop
			end if
			rsfunc.close
			set rsfunc=nothing
		end if
		sW3=sW3&","&W3list2 & ""
		if sW3<>"0" and sW3<>"" then
			set rsfunc=server.CreateObject("adodb.recordset")
			sql1="select ord,name,sorce,sorce2 from gate  where ord in ("&sW3&") order by sorce asc,sorce2 asc ,cateid asc ,ord asc"
			rsfunc.open sql1,conn,1,1
			if rsfunc.eof then
				member2=""
			else
				do until rsfunc.eof
					if sW1<>"" then
						if ((not CheckPurview(sW1,trim(rsfunc("sorce")))) or (not CheckPurview(sW2,trim(rsfunc("sorce2"))))) and ((rsfunc("sorce2")<>0 and rsfunc("sorce")<>0) or (rsfunc("sorce2")=0 and rsfunc("sorce")<>0)) Then
							sW3=replace(sW3,rsfunc("ord")&",","")
						end if
					end if
					sW3=replace(sW3,",0,",",")
					rsfunc.movenext
				loop
			end if
			rsfunc.close
			set rsfunc=nothing
		end if
		dim zmrlist : zmrlist="0"
		if open_5_11=1 then
			dim zmrarriy : zmrarriy=split(intro_5_11,",")
			dim ryarriy : ryarriy=split(sW3,",")
			for i=lbound(zmrarriy) to ubound(zmrarriy)
				for j=lbound(ryarriy) to ubound(ryarriy)
					if CheckPurview(zmrarriy(i),ryarriy(j))=True Then
						zmrlist =zmrlist&","&ryarriy(j)
					end if
				next
			next
			getW3WithLock=zmrlist
		else
			getW3WithLock=sW3
		end if
	end function
	function GetSoreName(id)
		if id<>"" and isnull(id)=false and isnumeric(id)  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select sort1 from gate1 where ord=isnull((select sorce from gate where ord="&id&"),0)"
			rs9.open sql,conn,1,1
			if not rs9.eof then
				GetSoreName=rs9("sort1")
			else
				GetSoreName=""
			end if
			rs9.close
			set rs9=nothing
		else
			GetSoreName=""
		end if
	end function
	function GetSore2Name(id)
		if id<>"" and isnull(id)=false and isnumeric(id)  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select sort2 from gate2 where ord=isnull((select sorce2 from gate where ord="&id&"),0)"
			rs9.open sql,conn,1,1
			if not rs9.eof then
				GetSore2Name=rs9("sort2")
			else
				GetSore2Name=""
			end if
			rs9.close
			set rs9=nothing
		else
			GetSore2Name=""
		end if
	end function
	function personFile(id)
		personFile=true
		if id<>"" and isnull(id)=false   then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select id from wageslist where cateid in("&id&") and del=1"
			rs9.open sql,conn,1,1
			if not rs9.eof then
				personFile=false
			end if
			rs9.close
			set rs9=nothing
		end if
	end function
	Function checkWFWages(gateid, ynowStatus, nowStatus, contractEnd, act)
		If ((ynowStatus&""<>"2"  Or ynowStatus&""<>"4") And (nowStatus&""="2"  Or nowStatus&""="4")) Or datediff("d",contractEnd,Date)>0 Then
			Dim SCrs, altStr , intro
			If gateid&"" = "" Then gateid = 0
			Set SCrs = conn.execute("select isnull(sum((case when b.del=1 then 1 else 0 end)),0) as zcnum,isnull(sum((case when b.del<>1 then 1 else 0 end)),0) as delnum from wageslist a inner join wages b on a.wages=b.id and isnull(b.complete1,0)=0 where a.cateid="& gateid)
			If SCrs.eof = False Then
				intro = ""
				If SCrs(0).value>0 Then intro = "工资单列表"
				If SCrs(1).value>0 Then
					If Len(intro)>0 Then intro = intro & "和"
					intro = intro & "工资单回收站列表"
				end if
				If intro&""<>"" Then
					Select Case act
					Case "update" : altStr = "更新为离职或退休"
					Case "freeze" : altStr = "冻结"
					Case "delete" : altStr = "删除"
					End Select
					Call jsBack("该人员"& intro & "有未发放的工资，不可以"& altStr)
				end if
			end if
			SCrs.close
			Set SCrs = Nothing
		end if
	end function
	
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
	Response.write session("name2006chen")
	Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body {" & vbcrlf & "      margin-top: 0px;" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & "</style>" & vbcrlf & "<script language=""JavaScript"" type=""text/JavaScript"">" & vbcrlf & "<!--" &vbcrlf & "    function MM_jumpMenu(targ, selObj, restore) { //v3.0" & vbcrlf & "        eval(targ + "".location=\'"" + selObj.options[selObj.selectedIndex].value + ""\'"");" & vbcrlf & "        if (restore) selObj.selectedIndex = 0;" & vbcrlf & "    }" & vbcrlf & "//-->" & vbcrlf & "</script>" & vbcrlf & "</head>" & vbcrlf & "<body bgcolor=""#ebebeb"">" & vbcrlf & "<table width=""100%""  border=""0"" align=""left"" cellpadding=""0"" cellspacing=""0"" bordercolor=""#E2E2E1"" bgcolor=""#FFFFFF"" >" & vbcrlf & "  <tr>" & vbcrlf & "    <td width=""100%"" valign=""top"">" & vbcrlf & "   <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "          <tr>" & vbcrlf & "            <td class=""place"">工资项目设置</td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "            <td align=""right""><input type=""button"" name=""Submit32"" value=""添加项目""  class=""anniu"" onClick=""javascript:window.open('add.asp','newwin','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=10,left=200,top=150')""/></td>" & vbcrlf & "            <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "          </tr>" & vbcrlf & "      </table>" & vbcrlf & ""
	CurrPage=cint(Request("CurrPage"))
	set rs=server.CreateObject("adodb.recordset")
	sql="select * from sortwages order by gate1 desc,sort1 asc"
	rs.open sql,conn,1,1
	if  rs.eof then
		Response.write "<table align='center'><tr><td  align='center' class='gray'>没有信息!</td></tr></table>"
	else
		i=0
		rs.PageSize=15
		PageCount=clng(rs.PageCount)
		if CurrPage<=0 or CurrPage="" then
			CurrPage=1
		end if
		if CurrPage>=PageCount then
			CurrPage=PageCount
		end if
		BookNum=rs.RecordCount
		rs.absolutePage = CurrPage
		Response.write "" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & " <tr border=1 valign=""center"" class=""top"">" & vbcrlf & "    <td width=""270"" height=""27"" align=""center"" valign=""middle"" bgcolor=""#F8F8F8"">      <div align=""center""><font style=""font-size: 9pt"">工资项目</font></div></td>" & vbcrlf & "    <td width=""193"" align=""center"" valign=""middle"" bgcolor=""#F8F8F8""><div align=""center"">类型</div></td>" & vbcrlf & "    <td width=""177"" align=""center"" valign=""middle"" bgcolor=""#F8F8F8""><div align=""center"">计算公式</div></td>" & vbcrlf & "    <td width=""125"" align=""center"" valign=""middle"" bgcolor=""#F8F8F8""><div align=""center""><font style=""font-size: 9pt"">重要指数</font></div></td>" & vbcrlf &"     <td width=""206"" height=""32"" align=""center"" valign=""middle"" bgcolor=""#F8F8F8""><div align=""center""><font style=""font-size: 9pt"">操作</font>　</div></td>" & vbcrlf & "    </tr>" & vbcrlf & "  "
		rs.absolutePage = CurrPage
		do until rs.eof
			sql="select distinct l.sort1 from wages w inner join wageslist l on l.wages=w.id where w.complete1=0 and w.del=1 and l.sort1="&rs("id")&" "
			set Crs=conn.execute(sql)
			if not Crs.eof Then
				disabled="disabled"
			else
				set Crs1=conn.execute("select id from wages where salaryClass in (select id from hr_gongziClass where del=0 and charindex(',"&rs("id")&",',','+cast(gongzi as nvarchar)+',')>0) and complete1=0")
				disabled="disabled"
				if not Crs1.eof Then
					disabled="disabled"
				else
					disabled=""
				end if
				Crs1.close
			end if
			Crs.close
			Set Crs=Nothing
			Response.write "" & vbcrlf & "  <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "    <td width=""270"" height=""25"" align=""left"" valign=""middle""  class=""name""><div align=""center"">"
			Response.write rs("sort1")
			Response.write "</div></td>" & vbcrlf & "    <td width=""193"" align=""center"" valign=""middle""  class=""name"">"
			if rs("intro")=1 then
				Response.write "增项"
			elseif rs("intro")=-1 then
				Response.write "增项"
				Response.write "减项"
			elseif rs("intro")=0 then
				Response.write "不操作"
			end if
			Response.write "</td>" & vbcrlf & "    <td width=""177"" align=""center"" valign=""middle""  class=""name"">"
			Response.write (rs("salaryClass"))
			Response.write "</td>" & vbcrlf & "    <td width=""125"" height=""25"" align=""center"" valign=""middle""  class=""name"">"
			Response.write rs("gate1")
			Response.write "</td>" & vbcrlf & "    <td height=""25"" align=""center"" valign=""middle""  class=""func"">" & vbcrlf & "    <input type=""button"" name=""Submit3c"" value=""修改"" "
			Response.write disabled
			Response.write " onClick=""javascript:window.open('correct.asp?ord="
			Response.write rs("id")
			Response.write "','newwincor','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')""/> <input type=""button"" name=""Submitdel"" value=""删除"" "
			Response.write rs("id")
			Response.write disabled
			Response.write " onClick=""if(confirm('确认删除？')){window.location.href='Delete.asp?ord="
			Response.write rs("id")
			Response.write "&CurrPage="
			Response.write CurrPage
			Response.write "'}""/></td>" & vbcrlf & "    </tr>" & vbcrlf & "  "
			i=i+1
			'Response.write "'}""/></td>" & vbcrlf & "    </tr>" & vbcrlf & "  "
			if i>=rs.PageSize then exit do
			rs.movenext
		loop
		Response.write "" & vbcrlf & "</table>" & vbcrlf & "  </td>" & vbcrlf & "  </tr>" & vbcrlf & "          <tr>" & vbcrlf & "    <td  class=""page"">" & vbcrlf & "       <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "  <tr>" & vbcrlf & "    <td width=""10%"" height=""30""><div align=""center""></div></td>" & vbcrlf & "    <td >&nbsp;    </td>" & vbcrlf & "    <td width=""79%""><div align=""right"">" & vbcrlf & "    "
		Response.write rs.RecordCount
		Response.write "个 | "
		Response.write currpage
		Response.write "/"
		Response.write rs.pagecount
		Response.write "页 | &nbsp;"
		Response.write rs.pagesize
		Response.write "条信息/页&nbsp;&nbsp;" & vbcrlf & "          "
		if currpage=1 then
			Response.write "" & vbcrlf & "          <input type=""button"" name=""Submit4"" value=""首页""  class=""page""/> <input type=""button"" name=""Submit42"" value=""上一页""  class=""page""/>" & vbcrlf & "          "
		else
			Response.write "" & vbcrlf & "          <input type=""button"" name=""Submit4"" value=""首页""   class=""page"" onClick=""window.location.href='edit.asp?currPage="
			Response.write  1
			Response.write "'""/> <input type=""button"" name=""Submit42"" value=""上一页""  onClick=""window.location.href='edit.asp?currPage="
			Response.write  currpage -1
			Response.write "'"" class=""page""/>" & vbcrlf & "          "
		end if
		if currpage=rs.pagecount then
			Response.write "" & vbcrlf & "          <input type=""button"" name=""Submit43"" value=""下一页""  class=""page""/> <input type=""button"" name=""Submit44"" value=""尾页""  class=""page""/>" & vbcrlf & "          "
		else
			Response.write "" & vbcrlf & "         <input type=""button"" name=""Submit43"" value=""下一页""  onClick=""window.location.href='edit.asp?currPage="
			Response.write  currpage + 1
			Response.write "'"" class=""page""/> <input type=""button"" name=""Submit43"" value=""尾页""  onClick=""window.location.href='edit.asp?currPage="
			Response.write  rs.PageCount
			'Response.write "'"" class=""page""/>" & vbcrlf & "          "
		end if
		Response.write "" & vbcrlf & "    </div></td>" & vbcrlf & "  </tr>" & vbcrlf & "  <script language=javascript>" & vbcrlf & "      function test() {" & vbcrlf & "          if (!confirm('确认删除吗？')) return false;" & vbcrlf & "      }" & vbcrlf & "" & vbcrlf & "      function mm() {" & vbcrlf & "          var a = document.getElementsByTagName(""input"");" & vbcrlf & "          if (a[0].checked == true) {" & vbcrlf & "              for (var i = 0; i < a.length; i++)" & vbcrlf & "                  if (a[i].type == ""checkbox"") a[i].checked = false;" & vbcrlf & "          }" & vbcrlf & "          else {" & vbcrlf & "              for (var i = 0; i < a.length; i++)" & vbcrlf & "                  if (a[i].type == ""checkbox"") a[i].checked = true;" & vbcrlf & "          }" & vbcrlf & "      }" & vbcrlf & "</script>" & vbcrlf & "</table>" & vbcrlf & ""
		'Response.write "'"" class=""page""/>" & vbcrlf & "          "
	end if
	rs.close
	set rs=nothing
	action1="工资项目设置"
	call close_list(1)
	Response.write "" & vbcrlf & "  </center>" & vbcrlf & "</div>    </td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "</body>" & vbcrlf & "</html>"
%>
