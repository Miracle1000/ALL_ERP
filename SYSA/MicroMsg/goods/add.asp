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
	Dim allowExt
	allowExt="|jpeg|jpg|png|gif|"
	Dim MaxUploadSize
	MaxUploadSize=1048576
	sub getUploadFileList(cn,OrderID,sort,edit)
		sql="select * from reply_file_Access where sort=" & sort & " and del=1 and charindex(','+rtrim(ord)+',', ','+(select top 1 uploadfile from reply where id="&OrderID&" )+',')>0"
'sub getUploadFileList(cn,OrderID,sort,edit)
		set rsAtt=cn.execute(sql)
		if not rsAtt.eof then
			Response.write "" & vbcrlf & "               <TR class=top>" & vbcrlf & "                  <TD><CENTER><SPAN class=""tableTitleLinks"" style=""FONT-WEIGHT: bolder; COLOR: #5b7cae"">文件名*</SPAN></CENTER></TD>" & vbcrlf & "                  <TD><CENTER><SPAN class=""tableTitleLinks"" style=""FONT-WEIGHT: bolder; COLOR: #5b7cae"">文件大小</SPAN></CENTER></TD>"& vbcrlf &                "       <TD><CENTER><SPAN class=""tableTitleLinks"" style=""FONT-WEIGHT: bolder; COLOR: #5b7cae"">文件描述</SPAN></CENTER></TD> "& vbcrlf &              "    <TD><CENTER><SPAN class=""tableTitleLinks"" style=""FONT-WEIGHT: bolder; COLOR: #5b7cae"">删除</SPAN></CENTER></TD> "& vbcrlf &   "           </TR> "& vbcrlf &    ""
'if not rsAtt.eof then
			while not rsAtt.eof
				FileName=rsAtt("Access_url")
				FileNameArr=split(FileName,"/")
				if ubound(FileNameArr)=4 then
					FileNameNew=FileNameArr(4)
					FolderName=FileNameArr(3)
				end if
				FileNameOld=rsAtt("oldname")
				FileSize=rsAtt("Access_size")
				FileDesc=rsAtt("fileDes")
				FileAccessID=rsAtt("ord")
				if CheckLocalFileExist(FileName) Or 1=1 then
					Response.write "" & vbcrlf & "                      <TR class=top style=""HEIGHT: 22px"">" & vbcrlf & "                               <TD style=""PADDING-RIGHT: 20px; PADDING-LEFT: 20px"">" & vbcrlf & "                                      <CENTER>" & vbcrlf & "                                        <SPAN style=""FONT-WEIGHT: lighter; COLOR: #5b7cae"">" & vbcrlf & "                                               <A href="""
'if CheckLocalFileExist(FileName) Or 1=1 then
					Response.write FileName
					Response.write """ target=_blank>"
					Response.write FileNameOld
					Response.write "</A>" & vbcrlf & "                                          <INPUT type=hidden value="""
					Response.write FileNameNew
					Response.write """ name=""FileNameNew"">" & vbcrlf & "                                                <INPUT type=hidden value="""
					Response.write FolderName
					Response.write """ name=""FolderName"">" & vbcrlf & "                                         <INPUT type=hidden value="""
					Response.write FileNameOld
					Response.write """ name=""FileNameOld"">" & vbcrlf & "                                                <INPUT type=hidden value="""
					Response.write FileDesc
					Response.write """ name=""FileDesc"">" & vbcrlf & "                                           <INPUT type=hidden value="""
					Response.write FileSize
					Response.write """ name=""FileSize"">" & vbcrlf & "                                           <INPUT type=hidden value="""
					Response.write now()
					Response.write """ name=""FileInDate"">" & vbcrlf & "                                         <INPUT type=hidden value="""
					Response.write FileAccessID
					Response.write """ name=""FileAccessID"">" & vbcrlf & "                                       </SPAN>" & vbcrlf & "                                 </CENTER>" & vbcrlf & "                               </TD>" & vbcrlf & "                           <TD style=""PADDING-RIGHT: 20px; PADDING-LEFT: 20px"">" & vbcrlf & "                                      <CENTER><SPAN style=""FONT-WEIGHT: lighter; COLOR: #5b7cae"">"
					'Response.write FileAccessID
					Response.write FileSize
					Response.write "</SPAN></CENTER>" & vbcrlf & "                              </TD>" & vbcrlf & "                           <TD style=""PADDING-RIGHT: 20px; PADDING-LEFT: 20px"">" & vbcrlf & "                                      <CENTER><SPAN style=""FONT-WEIGHT: lighter; COLOR: #5b7cae"">"
					'Response.write FileSize
					Response.write FileDesc
					Response.write "</SPAN></CENTER>" & vbcrlf & "                              </TD>" & vbcrlf & "                           <TD style=""PADDING-RIGHT: 20px; PADDING-LEFT: 20px"">" & vbcrlf & "                                      "
					'Response.write FileDesc
					if edit="edit" then
						Response.write "" & vbcrlf & "                                                              <CENTER><SPAN style=""FONT-WEIGHT: lighter; COLOR: #5b7cae""><A onclick=delRow(this,"
'if edit="edit" then
						Response.write FileAccessID
						Response.write "); href=""###"">删除</A></SPAN></CENTER>" & vbcrlf & "                                  "
					else
						Response.write "" & vbcrlf & "                                                              <CENTER><SPAN style=""FONT-WEIGHT: lighter; COLOR: #5b7cae"">只读</SPAN></CENTER>" & vbcrlf & "                                   "
						Response.write "); href=""###"">删除</A></SPAN></CENTER>" & vbcrlf & "                                  "
					end if
					Response.write "" & vbcrlf & "                              </TD>" & vbcrlf & "                   </TR>" & vbcrlf & "                   "
				end if
				rsAtt.movenext
			wend
		end if
		rsAtt.close
		set rsAtt=nothing
	end sub
	Function CheckLocalFileExist(file_dir)
		If file_dir="" Then
			CheckLocalFileExist =False
			Exit Function
		end if
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		if fs.FileExists(server.mappath(file_dir))=true Then
			CheckLocalFileExist = True
		else
			CheckLocalFileExist = False
		end if
		Set fs=Nothing
	end function
	Response.write "<style type=""text/css"">" & vbcrlf & ".accordion {" & vbcrlf & "" & vbcrlf & "}" & vbcrlf & ".accordion-bar-bg {" & vbcrlf & "  height: 30px;" & vbcrlf & "   cursor: pointer;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".accordion-bar-tit {" & vbcrlf & "   float: left;" & vbcrlf & "    padding-left: 10px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".accordion-bar-tit span {" & vbcrlf & "  margin-left: 10px;" & vbcrlf & "      margin-top: 3px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".accordion-arrow-up,.accordion-arrow-down {" & vbcrlf & "    display: inline-block;" & vbcrlf & "  width: 14px;" & vbcrlf & "    height: 14px;" & vbcrlf & "  background: url(../../images/r_down_14_14.png) no-repeat;" & vbcrlf & "}" & vbcrlf & ".accordion-arrow-up {" & vbcrlf & " background: url(../../images/r_up_14_14.png) no-repeat;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "" & vbcrlf & ".accordion-bar-btns {" & vbcrlf & "   float: right;" & vbcrlf & "    text-align: right;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".table_border {" & vbcrlf & "      padding:0;" & vbcrlf & "      margin:0;" & vbcrlf & "       background:none;" & vbcrlf & "        border-collapse: collapse;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".table_border td {" & vbcrlf & "   padding: 3px;" & vbcrlf & "   margin:0;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "</style>" & vbcrlf & "" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "jQuery(function(){" & vbcrlf & "       var $ = jQuery;" & vbcrlf & " $("".accordion"").parents(""#content"").addClass(""table_border"").attr(""cellSpacing"",0);" & vbcrlf & "" & vbcrlf & "     var accordionFlag = false;" & vbcrlf & "    $("".accordion"").click(function () {" & vbcrlf & "        accordionFlag = $(this).find("".accordion-arrow-down.accordion-arrow-up"")[0] ? true : false;" & vbcrlf & "        if (accordionFlag) {" & vbcrlf & "    $(this).nextUntil(""tr.accordion"").show();" & vbcrlf & "            $(this).find("".accordion-arrow-down"").toggleClass(""accordion-arrow-up"");" & vbcrlf & "        } else {" & vbcrlf & "            $(this).nextUntil(""tr.accordion"").not("".btns-bar"").hide();" & vbcrlf & "            $(this).find("".accordion-arrow-down"").toggleClass(""accordion-arrow-up"");" & vbcrlf & "        }" & vbcrlf & "    }).find(':reset,:button,:submit').click(function(e){" & vbcrlf & "            e.stopPropagation();" & vbcrlf & "    });" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "});" & vbcrlf & "</script>" & vbcrlf &"" & vbcrlf & "" & vbcrlf & ""
	Function FixTextInputView(v)
		If v&"" <> "" Then
			FixTextInputView = Server.HtmlEncode(v)
		end if
	end function
	Function GetCategory(id)
		Dim str,rs,sql,cid,cname
		str = "<select name='goodsCategory' id='goodsCategory' dataType='Limit' min='1' max='25' msg='必填'>"
		If id = 0 Then
			str = str & "<option value='' selected></option>"
		end if
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT ord,sort1 FROM sortonehy WHERE gate2 = 80 AND isStop = 0 ORDER BY gate1 DESC"
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While Not rs.Eof
				cid = rs("ord")
				cname = rs("sort1")
				str = str & "<option"
				If cid = id Then
					str = str & " selected"
				end if
				str = str &" value='"& cid &"'>"& cname &"</option>"
				rs.movenext
			Loop
		end if
		rs.close
		set rs = nothing
		str = str & "</select>"
		GetCategory = str
	end function
	Function GetUnit(unit,proID)
		Dim str,rs,sql,uid,uname,curUnitName
		str = "<select name='goodsUnit' id='goodsUnit' dataType='Limit' min='1' max='25' msg='必填'>"
		If unit = 0 Then
			str = str & "<option value='' selected></option>"
		end if
		Set rs = server.CreateObject("adodb.recordset")
		sql =        "SELECT MAX(a.id) AS xID,a.unit,MAX(b.sort1) AS uname " &_
		"FROM jiage a " &_
		"LEFT JOIN sortonehy b ON a.unit = b.ord " &_
		"WHERE a.product = "& proID &" GROUP BY a.unit  " &_
		"ORDER BY xID ASC"
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While Not rs.Eof
				uid = rs("unit")
				uname = rs("uname")
				str = str & "<option"
				If uid = unit Then
					curUnitName = uname & "<input type='hidden' id='goodsUnit' name='goodsUnit' value='"& uid &"'>"
					str = str & " selected"
				end if
				str = str &" value='"& uid &"'>"& uname &"</option>"
				rs.movenext
			Loop
		end if
		rs.close
		set rs = nothing
		str = str & "</select>"
		If curUnitName <> "" Then str = curUnitName
		GetUnit = str
	end function
	Function GetProCategory(proID)
		Dim rs,sql,temp
		Set rs = conn.Execute("SELECT dbo.getTopOrd(sort1,0) AS CID FROM product WHERE ord = "& proID &" ")
		If Not rs.Eof Then
			temp = rs("CID")
		else
			temp = 0
		end if
		rs.close
		set rs = nothing
		GetProCategory = temp
	end function
	Function GetUsingDegreeList(goodsID)
		Dim rs,sql,temp
		temp = 0
		sql =        "SELECT degreeID FROM Shop_GoodsAttrValue WHERE goodsID = "& goodsID &" "
		set rs = conn.execute(sql)
		If Not rs.Eof Then
			Do While Not rs.Eof
				temp = temp &","&rs("degreeID")
				rs.movenext
			Loop
		end if
		rs.close
		set rs = nothing
		GetUsingDegreeList = temp
	end function
	Function IsUsedDegree(proID,unit,degreeID,goodsID)
		Dim rs,sql,temp,attrNum
		attrNum = Ubound(Split(degreeID,",")) + 1
'Dim rs,sql,temp,attrNum
		temp = False
		sql =       "SELECT goodsID FROM Shop_GoodsAttrValue WHERE goodsID IN ( " &_
		"  SELECT goodsID FROM Shop_GoodsAttrValue " &_
		"  WHERE LEN(attrVal) > 0 AND goodsID IN (SELECT id FROM Shop_Goods WHERE product = "& proID &" AND unit = "& unit &") " &_
		"  AND goodsID <> "& goodsID &" " &_
		"  GROUP BY goodsID " &_
		"  HAVING COUNT(*) = "& attrNum &" " &_
		") AND degreeID IN ("& degreeID &") " &_
		"GROUP BY goodsID " &_
		"HAVING COUNT(*) = "& attrNum &" "
		set rs = conn.execute(sql)
		If Not rs.Eof Then
			temp = True
		end if
		rs.close
		set rs = nothing
		IsUsedDegree = temp
	end function
	Sub ValidField(field,msg)
		If field&"" = "" Then
			Response.write "<script>alert('"& msg &"不能为空！');window.history.back();</script>"
			Response.end
		end if
	end sub
	Dim curUser,virPath
	curUser = session("personzbintel2007")
	virPath = sdk.getVirPath
	Referrer = Request("Referrer")
	proName = Request("proName")
	proID = Request("proID")
	goodsID = deurl(Request("goodsID"))
	If goodsSort = "" Then goodsSort = 1
	If proID = "" Then proID = 0
	If goodsID = "" Then goodsID = 0
	If goodsID = 0 And proID <> 0 Then
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT TOP 1 intro1,intro2,intro3 FROM product WHERE ord = "& proID &" "
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			goodsDescription = rs("intro3")
			goodsParameter = rs("intro2")
			goodsBZSH = rs("intro1")
		end if
		rs.close
		set rs = nothing
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT TOP 1 * FROM Shop_Goods WHERE product = "& proID &" ORDER BY id DESC "
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			goodsDescription = rs("intro3")
			goodsParameter = rs("intro2")
			goodsBZSH = rs("intro1")
		end if
		rs.close
		set rs = nothing
	end if
	Dim pageTitle
	If goodsID > 0 Then
		pageTitle = "商品修改"
		Set rs = server.CreateObject("adodb.recordset")
		sql =        "SELECT b.title AS proName,a.product AS proID,a.name AS goodsName,a.bh AS goodsBH,a.adWord AS goodsAD, " &_
		"a.sort AS goodsSort,a.sortonehy goodsCategory,a.unit AS goodsUnit,a.price1 AS goodsPrice, " &_
		"a.intro3 AS goodsDescription,a.intro2 AS goodsParameter,a.intro1 AS goodsBZSH,c.id AS primaryImg,a.onSaleAfter AS putTime," &_
		"[dbo].[GetGoodsStatus](a.id,GETDATE()) AS onSale " &_
		"FROM Shop_Goods a " &_
		"LEFT JOIN product b ON b.ord = a.product " &_
		"LEFT JOIN sys_upload_res c ON c.id2 = 1 AND c.id1 = a.id " &_
		"WHERE a.del = 1 AND a.id = "& goodsID &" "
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			proName = rs("proName")
			proID = rs("proID")
			goodsName = rs("goodsName")
			goodsBH = rs("goodsBH")
			goodsAD = rs("goodsAD")
			goodsSort = rs("goodsSort")
			goodsCategory = rs("goodsCategory")
			goodsUnit = rs("goodsUnit")
			goodsPrice = rs("goodsPrice")
			goodsDescription = rs("goodsDescription")
			goodsParameter = rs("goodsParameter")
			goodsBZSH = rs("goodsBZSH")
			primaryImg = rs("primaryImg")
			onSale = rs("onSale")
			putTime = rs("putTime")
		else
			Response.write "<script>alert('该商品已被删除！');window.close();</script>"
			Response.end
		end if
		rs.close
		set rs = nothing
		UsedAttr = GetUsingDegreeList(goodsID)
	Else
		pageTitle = "商品添加"
		Set rs88 = conn.execute("EXEC erp_getdjbh 109,"& curUser &"")
		goodsBH = rs88(0).value
		rs88.Close
		Set rs88 = Nothing
		If goodsBH = "error" Then
			Response.write "<script language='javascript'>alert('商品编号顺序递增位数已占满，请联系系统管理员，重新调整编号顺序递增位数！');return false;</script>"
			Call db_close : Response.end
		end if
		sql = "DELETE Shop_Goods WHERE del=7 AND creator = "& curUser &" "
		conn.Execute(sql)
		sqlStr = "INSERT INTO Shop_Goods (product,sortonehy,sort,unit,price1,creator,createtime,bh,del) VALUES ('"
		sqlStr = sqlStr & 0 & "','"
		sqlStr = sqlStr & 0 & "','"
		sqlStr = sqlStr & 0 & "','"
		sqlStr = sqlStr & 0 & "','"
		sqlStr = sqlStr & 0 & "','"
		sqlStr = sqlStr & curUser & "','"
		sqlStr = sqlStr & now & "','"
		sqlStr = sqlStr & goodsBH & "','"
		sqlStr = sqlStr & 7 & "')"
		Conn.execute(sqlStr)
		curGoodsID = GetIdentity("Shop_Goods","id","creator","")
		goodsCategory = 0
		goodsUnit = 0
	End If
	If Replace(Trim(goodsDescription&""),"<br>","")="" Then goodsDescription = ""
	If Replace(Trim(goodsParameter&""),"<br>","")="" Then goodsParameter = ""
	If proName = "" Then proName = "<span class='red'>请先选择产品！</span>"
	Response.write "" & vbcrlf & "" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Language"" content=""zh-cn"">" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
'If proName = "" Then proName = "<span class='red'>请先选择产品！</span>"
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link href=""../../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style>" & vbcrlf & "html{" & vbcrlf & "scrollbar-3dlight-color:#d0d0e8;" & vbcrlf & "scrollbar-highlight-color:#fff;" & vbcrlf & "scrollbar-face-color:#f0f0ff;" & vbcrlf & "scrollbar-arrow-color:#c0c0e8;" & vbcrlf & "scrollbar-shadow-color:#d0d0e8;" & vbcrlf & "scrollbar-darkshadow-color:#fff;" & vbcrlf & "scrollbar-base-color:#ffffff;" & vbcrlf & "scrollbar-track-color:#fff;" & vbcrlf & "}" & vbcrlf & "html,body{ height:100%; }" & vbcrlf & "" & vbcrlf & ".g-field {" & vbcrlf & "       width: 80%;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".g-textarea {" & vbcrlf & "       width: 95%;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".g-error {" & vbcrlf & "  border: 1px solid red;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "ul,li,img{margin:0; padding:0; list-style: none;}" & vbcrlf & ".multimage-gallery {" & vbcrlf & "    padding: 5px;" & vbcrlf & "}" & vbcrlf & ".multimage-gallery li {" & vbcrlf & "        float: left;" & vbcrlf & "    font-size: 0;" & vbcrlf & "    display: inline-block;" & vbcrlf & "    border: 1px dashed #CDCDCD;" & vbcrlf & "    margin-right: 10px;" & vbcrlf & "    position: relative;" & vbcrlf & "    vertical-align: top;" & vbcrlf& "    width: 96px;" & vbcrlf & "    height: 96px;" & vbcrlf & "    overflow: hidden" & vbcrlf & "    clear: left;" & vbcrlf & "    margin-bottom: 8px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .primary {" & vbcrlf & "    margin-left: 0;" & vbcrlf & "    border: 1px solid #ffc097;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & " .multimage-gallery .info {" & vbcrlf & "       position: absolute;" & vbcrlf & "    top: 25px;" & vbcrlf & "       left: 25px;" & vbcrlf & "    z-index: 3;" & vbcrlf & "    text-align: center;" & vbcrlf & "    font-size: 12px;" & vbcrlf & "   line-height: 20px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .preview {" & vbcrlf & "       padding:2px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .preview img {" & vbcrlf & "    width: 90px;" & vbcrlf & "    height: 90px;" & vbcrlf & "    vertical-align: middle;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .operate {" & vbcrlf & "    background: rgba(33,33,33,.7);" & vbcrlf & "    filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=#b2404040, endColorstr=#b2404040);" & vbcrlf & " opacity: .8;" & vbcrlf & "    z-index: 5;" & vbcrlf & "    position: absolute;"& vbcrlf & "    bottom: 0;" & vbcrlf & "    left: 0;" & vbcrlf & "    width: 100%;" & vbcrlf & "    height: 20px;" & vbcrlf & "    display: none;" & vbcrlf & "    padding: 5px 0 5px 12px;" & vbcrlf & "    box-sizing:border-box;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "" & vbcrlf & ".multimage-gallery .operate i {" & vbcrlf & "    background: url(../../images/goods_img_icon_bg.png) no-repeat;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .operate i {" & vbcrlf & "    display: inline-block;" & vbcrlf & "    cursor: pointer;" & vbcrlf & "    height: 12px;" & vbcrlf & "    width: 12px;" & vbcrlf & "       margin: 0 5px;" & vbcrlf & "    font-size: 0;" & vbcrlf & "    line-height: 0;" & vbcrlf & "    overflow: hidden;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .operate .toleft {" & vbcrlf & "    background-position: 0 -13px;" & vbcrlf & "  display: none;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .operate .toright {" & vbcrlf & "    background-position: -13px -13px;" & vbcrlf & "    display: none;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".multimage-gallery .operate .del {" & vbcrlf & "    background-position: -13px 0;" & vbcrlf & "      float: right;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".img-hover .operate {" & vbcrlf & "    display: block;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "</style>" & vbcrlf & "<script language=""javascript"" src=""../../inc/DelUnusedFiles.js?ver="
	'Response.write Application("sys.info.jsver")
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script>" & vbcrlf & "$(function(){" & vbcrlf & "  // 表单验证" & vbcrlf & "     $(""#goodsForm"").submit(function(){" & vbcrlf & "                " & vbcrlf & "                if(!checkPro()){" & vbcrlf & "                        return false;   " & vbcrlf & "                };" & vbcrlf & "              " & vbcrlf & "                if(!Validator.Validate(this,2)){" & vbcrlf & "                   return false;   " & vbcrlf & "                };" & vbcrlf & "" & vbcrlf & "              //if(!checkAttr()){" & vbcrlf & "             //      alert('请将属性信息填写完整！');" & vbcrlf & "                //      return false;" & vbcrlf & "           //};    " & vbcrlf & "" & vbcrlf & "                // 验证商品主图" & vbcrlf & "         var pImg = $(""#primaryImg"");" & vbcrlf & "              var p =$(""#goodsPic li[data-index=1]"").find("".preview img"");" & vbcrlf & "" & vbcrlf & "          if(p.size() > 0 && pImg.val().length == 0) {                    " & vbcrlf & "                        pImg.val(p.attr(""fileID""));" & vbcrlf & "               };" & vbcrlf & "              " & vbcrlf & "                if(pImg.val().length == 0){                     " & vbcrlf & "                        alert('请添加商品主图！');" & vbcrlf & "                 return false;" & vbcrlf & "           };" & vbcrlf & "" & vbcrlf & "              // 验证定时上架时间" & vbcrlf & "             var onSale = $(""input[name=onSale]:checked"").val();" & vbcrlf & "               if(onSale == 2){" & vbcrlf & "                        var putTime = $(""#putTime"").val();" & vbcrlf & "                        if(putTime.length == 0){" & vbcrlf & "                                alert(""请填写定时上架时间!"");" & vbcrlf & "                           return false;" & vbcrlf & "                   };" & vbcrlf & "              };" & vbcrlf & "" & vbcrlf & "              // 验证是否自动生成二维码" & vbcrlf & "               var autoCode2 = $(""#autoCode2"").val();" & vbcrlf & "            if(autoCode2 != 1){" & vbcrlf & "                     if(confirm(""是否同步更新二维码？"")){" & vbcrlf & "                              $(""#autoCode2"").val(1); "& vbcrlf &              "          }else{ "& vbcrlf &                  "        $(""#autoCode2"").val(0);" & vbcrlf &      "              };                      " & vbcrlf &      "           }; "& vbcrlf & vbcrlf & vbcrlf &  "     }); "& vbcrlf & vbcrlf &" }); "& vbcrlf & vbcrlf & "// 验证是否选择了产品 "& vbcrlf & "function checkPro(){ "& vbcrlf &"  var p = $(""#proID"");" & vbcrlf & "     if(p.val().length == 0 || p.val() == ""0""){" & vbcrlf & "                alert('温馨提示：请先选择产品！');" & vbcrlf & "              return false;" & vbcrlf & "   }else{" & vbcrlf & "          return true;    " & vbcrlf & "        };              " & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "// 验证是否选择了属性" & vbcrlf & "function checkAttr(){" & vbcrlf & "       var result = true;" & vbcrlf & "      $("".attrList"").each(function(index,ele){" & vbcrlf & "          var  $p = $(this).parent();" & vbcrlf & "             $p.removeClass(""g-error"");" & vbcrlf & "                var aID = $(this).attr(""attrID"");" & vbcrlf & "         var degree = $(this).find(""input[name=degree_""+ aID +""]"");" & vbcrlf & "             if(degree.size() > 0){" & vbcrlf & "                  var isChk = degree.is("":checked"");" & vbcrlf & "                        // " & vbcrlf & "                     if(!isChk){" & vbcrlf & "                             $p.addClass(""g-error"");" & vbcrlf & "                           result = false;" & vbcrlf & "                         return false;" & vbcrlf & "                   };" & vbcrlf & "              };" & vbcrlf & "   });" & vbcrlf & "     " & vbcrlf & "        return result;" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "$(function(){" & vbcrlf & "   // 处理点击属性 " & vbcrlf & "        $("".degreeVal"").click(function(){" & vbcrlf & "         var d = $(this).siblings("".degreeID"");" & vbcrlf & "            var curID = $(this).attr(""degreeID"");" & vbcrlf & "             var status = $(this).find(""input[type=radio]"").attr(""disabled"");" & vbcrlf & "            if(!status){" & vbcrlf & "                    d.val(curID);" & vbcrlf & "           };" & vbcrlf & "" & vbcrlf & "      });" & vbcrlf & "" & vbcrlf & "     // 选择单位清空属性选择" & vbcrlf & " $(""#goodsUnit"").on(""change"",function(){" & vbcrlf & "               $(""input[name^=degree_]"").removeAttr(""checked"").removeAttr(""disabled"");" & vbcrlf & "       });" & vbcrlf & "" & vbcrlf & "     // 选择属性处理" & vbcrlf & " $(""input[name^=degree_]"").on(""click"",function(){" & vbcrlf & "            $(""input[name^=degree_]"").removeAttr(""disabled""); "& vbcrlf &           "    var attr = [];" & vbcrlf & vbcrlf &   "        $(""input[name^=degree_]:checked"").each(function(){ "& vbcrlf &      "                   var v =  $(this).attr(""id"").substring(7,100); "& vbcrlf &       "               attr.push(v); "& vbcrlf &      "      }); "& vbcrlf & vbcrlf &          "    var degreeID = attr.join(); "& vbcrlf & "var unit = $(""#goodsUnit"").val() || 0;" & vbcrlf & "            if(unit.length == 0 || unit == 0){" & vbcrlf & "                      alert('请先选择商品单位！');" & vbcrlf & "                    return false;" & vbcrlf & "           };              " & vbcrlf & "                " & vbcrlf & "                // 获取已使用的属性组合" & vbcrlf & "         $.post(""ajax.asp"",{act:""attrSelect"",proID:"""
	Response.write proID
	Response.write """,unit:unit,degreeID:degreeID,goodsID:"
	Response.write goodsID
	Response.write "},function(data){" & vbcrlf & "                    if(data !== ""error""){" & vbcrlf & "                             if(data == ""True""){" & vbcrlf & "                                       alert('您选择的商品属性或属性组合已被其他商品使用，请重新选择！');" & vbcrlf & "                                      // 初始化" & vbcrlf & "                                       $(""input[name^=degree_]"").removeAttr(""checked"").removeAttr(""disabled"");" & vbcrlf & "                                       $("".degreeID"").val(0);" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "                                 // 处理属性程度不可选" & vbcrlf & "                                   degreeID = degreeID.split("","");" & vbcrlf & "                                   $.each(degreeID, function(index, value) {" & vbcrlf & "                                               $(""#degree_""+value).attr(""disabled"",""true"");" & vbcrlf & "                                  });                             " & vbcrlf& "                               };" & vbcrlf & "                              " & vbcrlf & "" & vbcrlf & "                                " & vbcrlf & "                        }" & vbcrlf & "               });" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "     });" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "     // 商品图片排序删除" & vbcrlf & "     $(""#goodsPic li"").hover(function(){" & vbcrlf & "               var img = $(this).find("".preview img"");" & vbcrlf & "            if(img.size() > 0){" & vbcrlf & "                     $(this).addClass(""img-hover"");" & vbcrlf & "            };" & vbcrlf & "      },function(){" & vbcrlf & "           $(this).removeClass(""img-hover"");" & vbcrlf & " });" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "     // 删除商品图片" & vbcrlf & " $("".operate .del"").on(""click"",function(){" & vbcrlf & "               var img = $(this).parent().parent().find("".preview img"");" & vbcrlf & "         if(img.size() > 0){" & vbcrlf & "                     var fileID = img.attr(""fileID"")," & vbcrlf & "                          fileName = img.attr(""src"");" & vbcrlf & "                       var start = fileName.indexOf(""shop"") + 5;"& vbcrlf & "                      var end = fileName.length;" & vbcrlf & "                      var fName = fileName.substring(start,end);" & vbcrlf & "                      $.post(""../goodsUpload/ProcDelFile.asp"",{action:""fileDel"",fileID:fileID,fileName:fName},function(data){" & vbcrlf & "                             $(""#primaryImg"").val("""");" & vbcrlf & "                           img.remove();" & vbcrlf & "                 });" & vbcrlf & "             };" & vbcrlf & "" & vbcrlf & "      });" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "});" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "</script>" & vbcrlf & "" & vbcrlf & "<script language=""JavaScript"" type=""text/JavaScript"">" & vbcrlf & "function setparentheight(){" & vbcrlf & "   parent.document.getElementById(self.name).height=document.body.scrollHeight;" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "</head>" & vbcrlf & "<body onload=""try{setparentheight();}catch(e){}"">" & vbcrlf & "" & vbcrlf & "<table border=""0"" width=""100%"" cellspacing=""0"" cellpadding=""0"" bgcolor=""#FFFFFF"" > "& vbcrlf & "  <tr> "& vbcrlf &        "     <td valign=""top"">" & vbcrlf &             "     <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../../images/m_mpbg.gif""> "& vbcrlf &                         "      <tr> "& vbcrlf &                       "              <td class=""place>"
	Response.write pageTitle
	Response.write "</td>" & vbcrlf & "                                        <td>&nbsp;</td>" & vbcrlf & "                                 <td align=""right"">&nbsp;</td>" & vbcrlf & "                                     <td width=""3""><img src=""../../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "                           </tr>" & vbcrlf & "                   </table>" & vbcrlf & "                        <form method=""post"" action=""save.asp"" name=""goodsForm"" id=""goodsForm"">" & vbcrlf & "" & vbcrlf & "                        <table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "                                      <tr class=""top accordion"">" & vbcrlf & "                                                <td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "                                                      <div  class=""accordion-bar-tit"">基本信息<span class=""accordion-arrow-down""></span></div>" & vbcrlf & "                                                    <div class=""accordion-bar-btns"">                                                          " & vbcrlf & "                                                                <input type=""submit"" name=""pageType"" value=""保存""  class=""page""/>" & vbcrlf & "                                                               "
	'Response.write pageTitle
	If goodsID = 0 Then
		Response.write "" & vbcrlf & "                                                             <input type=""submit"" name=""pageType"" value=""增加""  class=""page""/>" & vbcrlf & "                                                               "
	end if
	Response.write "" & vbcrlf & "                                                             <input type=""reset"" value=""重填""  class=""page"" name=""B2222"">" & vbcrlf & "                                                            "
	Dim isAutoCode2
	If sdk.power.existsPowerIntro(106,13,curUser) Then
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select isauto from C2_CodeTypes where title = '商品自定义'"
		rs1.open sql1,conn,1,1
		if rs1.eof then
			isAutoCode2 = 0
		else
			isAutoCode2 = rs1("isauto")
		end if
		rs1.close
		set rs1=nothing
	else
		isAutoCode2 = 0
	end if
	Response.write "" & vbcrlf & "                                                             <input type=""hidden"" value="""
	Response.write isAutoCode2
	Response.write """ name=""autoCode2"" id=""autoCode2""/>" & vbcrlf & "                                                   </div>" & vbcrlf & "                                          </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   <tr>" & vbcrlf & "                                            <td width=""10%"" align=""right"" height=""27"">关联产品：</td>" & vbcrlf & "                                             <td colspan=""6""><div id=""product"">"
	Response.write proName
	Response.write "<input id=""proID"" name=""proID"" type=""hidden"" value="""
	Response.write proID
	Response.write """ > </div></td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   <tr>" & vbcrlf & "                                            <td width=""10%"" align=""right"" height=""27"">商品名称：</div></td>" & vbcrlf & "                                               <td width=""50%"">" & vbcrlf & "                                                  <input class=""g-field"" type=""text"" size=""25"" id=""goodsName"" name=""goodsName"" dataType=""Limit"" min=""1"" max=""100"" msg=""长度必须在1个至100个字之间"" value="""
	Response.write FixTextInputView(goodsName)
	Response.write """ onkeyup=""checkPro()"">" & vbcrlf & "                                                     <span class=""red"">*</span>" & vbcrlf & "                                                </td>" & vbcrlf & "                                           <td width=""10%""><div align=""right"" height=""27"">商品编号：</div></td>" & vbcrlf & "                                          <td width=""30%"">" & vbcrlf & "                                                  <input class=""g-field"" type=""text"" size=""20"" id=""goodsBH"" name=""goodsBH"" dataType=""Limit"" min=""1"" max=""100"" msg=""长度必须在1个至100个字之间"" value="""
	Response.write FixTextInputView(goodsBH)
	Response.write """>" & vbcrlf & "                                                        <span class=""red"">*</span>" & vbcrlf & "                                                </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   <tr>" & vbcrlf & "                                            <td width=""10%"" align=""right"" height=""27"">广告语：</div></td>" & vbcrlf & "                                         <td width=""60%"">" & vbcrlf & "                                                  <input class=""g-field"" type=""text"" size=""20"" id=""goodsAD"" name=""goodsAD"" value="""
	Response.write FixTextInputView(goodsAD)
	Response.write """ dataType=""Limit"" min=""0"" max=""100"" msg=""长度必须在0个至100个字之间"">" & vbcrlf & "                                            </td>" & vbcrlf & "                                           <td width=""10%""><div align=""right"" height=""27"">重要指数：</div></td>" & vbcrlf & "                                          <td width=""20%"">" & vbcrlf & "                                                  <input class=""g-field"" type=""text"" size=""20"" id=""goodsSort"" name=""goodsSort"" onkeyup=""value=value.replace(/^[^1-9]/g,'').replace(/[^0-9]$/g,'').replace(/\./g,'');this.value=this.value.substr(0,8);"" dataType=""Number"" cannull=""1"" value="""
	'Response.write FixTextInputView(goodsAD)
	Response.write goodsSort
	Response.write """>" & vbcrlf & "                                                </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   <tr>" & vbcrlf & "                                            <td width=""10%"" align=""right"" height=""27"">所属分类：</div></td>" & vbcrlf & "                                               <td width=""60%"">" & vbcrlf & "                                                  "
	Response.write GetCategory(goodsCategory)
	Response.write "" & vbcrlf & "                                                     <span class=""red"">*</span>" & vbcrlf & "                                                </td>" & vbcrlf & "                                           <td width=""10%""><div align=""right"" height=""27"">商品单位：</div></td>" & vbcrlf & "                                          <td width=""20%"">" & vbcrlf & "                                                  "
	Response.write GetUnit(goodsUnit,proID)
	If goodsID = 0 Then
		Response.write "" & vbcrlf & "                                                     <span class=""red"">*</span>" & vbcrlf & "                                                        "
	end if
	Response.write "" & vbcrlf & "                                             </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   "
	If goodsID = 0 Then
		Response.write "" & vbcrlf & "                                     <tr>" & vbcrlf & "                                            <td width=""10%"" align=""right"" height=""27"">商品数量：</div></td>" & vbcrlf & "                                               <td width=""60%"">" & vbcrlf & "                                                  <input type=""text"" size=""12"" id=""goodsNum"" name=""goodsNum"" onkeyup=""value=value.replace(/[^\d\.]/g,'');checkDot('goodsNum','"
		Response.write num1_dot
		Response.write "');"" onfocus=""if(value==defaultValue){value='';this.style.color='#000'};"" onblur=""if(!value){value=defaultValue;this.style.color='#000'};checkDot('goodsNum','"
		Response.write num1_dot
		Response.write "')"" dataType=""number"" min=""1"" max=""99999999"" msg=""必填"" value="""
		Response.write goodsNum
		Response.write """>" & vbcrlf & "                                                        <span class=""red"">*</span>" & vbcrlf & "                                                </td>" & vbcrlf & "                                           <td width=""10%""><div align=""right"" height=""27"">商品价格：</div></td>" & vbcrlf & "                                          <td width=""20%"">" & vbcrlf & "                                                  <input type=""text"" size=""15"" id=""goodsPrice"" name=""goodsPrice""onkeyup=""value=value.replace(/[^\d\.]/g,'');checkDot('goodsPrice','"
		Response.write SalesPrice_dot_num
		Response.write "');"" dataType=""Number"" min=""0"" max=""9999999999.99999999"" msg=""必填"" value="""
		Response.write FormatNumber(goodsPrice,sdk.info.SalesPriceDotNum,-1,0,0)
		Response.write """>" & vbcrlf & "                                                        ￥" & vbcrlf & "                                                      <span class=""red"">*</span>" & vbcrlf & "                                                </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   "
	else
		Response.write "" & vbcrlf & "                                     <tr>" & vbcrlf & "                                            <td width=""10%""><div align=""right"" height=""27"">商品价格：</div></td>" & vbcrlf & "                                          <td width=""90%"" colspan=""5"">" & vbcrlf & "                                                        <input type=""text"" size=""15"" id=""goodsPrice"" name=""goodsPrice"" onkeyup=""value=value.replace(/[^\d\.]/g,'');checkDot('goodsPrice','"
		Response.write SalesPrice_dot_num
		Response.write "');"" dataType=""Number"" min=""0"" max=""9999999999.99999999"" msg=""必填"" value="""
		Response.write FormatNumber(goodsPrice,sdk.info.SalesPriceDotNum,-1,-1,0)
		Response.write """>" & vbcrlf & "                                                        ￥" & vbcrlf & "                                                      <span class=""red"">*</span>" & vbcrlf & "                                                </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   "
	end if
	Response.write "" & vbcrlf & "" & vbcrlf & "                                     <tr class=""top accordion"">" & vbcrlf & "                                                <td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "                                                   <div  class=""accordion-bar-tit"">属性信息<span class=""accordion-arrow-down""></span></div>" & vbcrlf & "                                            </td>" & vbcrlf & "                                   </tr>" & vbcrlf& "                                       "
	If goodsID = 0 Then
		Set rs = server.CreateObject("adodb.recordset")
		sql =       "SELECT a.id,MAX(a.title) attrName,MAX(a.sort) AS attrSort " &_
		"FROM Shop_GoodsAttr a " &_
		"INNER JOIN Shop_GoodsAttr b ON b.pid = a.id " &_
		"WHERE a.pid = 0 AND a.isStop = 0 AND a.proCategory = "& GetProCategory(proID) &" " &_
		"GROUP BY a.id " &_
		"ORDER BY attrSort DESC "
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While Not rs.Eof
				attrID = rs("id")
				attrName = rs("attrName")
				Response.write "" & vbcrlf & "                                                     <tr>" & vbcrlf & "                                                            <td width=""10%"" align=""right"" height=""27"">"
				Response.write attrName
				Response.write "：<input type=""hidden"" name=""attrID"" value="""
				Response.write attrID
				Response.write """ ></td>" & vbcrlf & "                                                          <td colspan=""6"">" & vbcrlf & "                                                          <div class=""attrList"" attrID="""
				Response.write attrID
				Response.write """>" & vbcrlf & "                                                                        "
				Set rs1 = server.CreateObject("adodb.recordset")
				sql1 = "SELECT * FROM Shop_GoodsAttr WHERE pid = "& attrID &" AND isStop = 0 ORDER BY sort DESC "
				rs1.Open sql1,conn,1,1
				If Not rs1.Eof Then
					Do While Not rs1.Eof
						degreeID = rs1("id")
						Response.write "<label for='degree_"& degreeID &"' degreeID='"& degreeID &"' class='degreeVal'><input id='degree_"& degreeID &"' name='degree_"& attrID &"' type='radio' "
						Response.write "value='"& rs1("title") &"' >"& rs1("title") &"</label>"
						rs1.MoveNext
					Loop
				end if
				rs1.Close
				Set rs1 = Nothing
				Response.write "" & vbcrlf & "                                                                     <input type=""hidden"" name=""degreeID_"
				Response.write attrID
				Response.write """ value=""0"" class=""degreeID"">" & vbcrlf & "                                                         </div>" & vbcrlf & "                                                          </td>" & vbcrlf & "                                                   </tr>" & vbcrlf & "                                                   "
				rs.movenext
			Loop
		else
			Response.write "<tr><td colspan='6' height='27' align='center'>请设置商品属性！</td></tr>"
		end if
		rs.close
		set rs = nothing
	ElseIf goodsID > 0 Then
		Set rs = server.CreateObject("adodb.recordset")
		sql =       "SELECT a.id,MAX(a.title) attrName,MAX(a.sort) AS attrSort " &_
		"FROM Shop_GoodsAttr a " &_
		"INNER JOIN Shop_GoodsAttr b ON b.pid = a.id " &_
		"WHERE a.pid = 0 AND a.isStop = 0 AND a.proCategory = "& GetProCategory(proID) &" " &_
		"GROUP BY a.id " &_
		"ORDER BY attrSort DESC "
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While Not rs.Eof
				attrID = rs("id")
				attrName = rs("attrName")
				Response.write "" & vbcrlf & "                                             <tr>" & vbcrlf & "                                                    <td width=""10%"" align=""right"" height=""27"">"
				Response.write attrName
				Response.write "：<input type=""hidden"" name=""attrID"" value="""
				Response.write attrID
				Response.write """ ></td>" & vbcrlf & "                                                  <td colspan=""6"">" & vbcrlf & "                                                  <div class=""attrList"" attrID="""
				Response.write attrID
				Response.write """>" & vbcrlf & "                                                                "
				Set rs1 = server.CreateObject("adodb.recordset")
				sql1 = "SELECT * FROM Shop_GoodsAttr WHERE pid = "& attrID &" AND (isStop = 0 or charindex(','+cast(id as varchar(10))+',',',"& UsedAttr &",')>0)  ORDER BY sort DESC "
				'Set rs1 = server.CreateObject("adodb.recordset")
				rs1.Open sql1,conn,1,1
				If Not rs1.Eof Then
					Do While Not rs1.Eof
						degreeID = rs1("id")
						Response.write "<label for='degree_"& degreeID &"' degreeID='"& degreeID &"' class='degreeVal'><input id='degree_"& degreeID &"' name='degree_"& attrID &"' type='radio' "
						If InStr(1,","& UsedAttr &",",","& degreeID &",",1) > 0 Then
							Response.write "checked='checked'"
						end if
						Response.write "value='"& rs1("title") &"' >"& rs1("title") &"</label>"
						rs1.MoveNext
					Loop
				end if
				rs1.Close
				Set rs1 = Nothing
				Response.write "" & vbcrlf & "                                                             <input type=""hidden"" name=""degreeID_"
				Response.write attrID
				Response.write """ value=""0"" class=""degreeID"">" & vbcrlf & "                                                 </div>" & vbcrlf & "                                                  </td>" & vbcrlf & "                                           </tr>" & vbcrlf & "                                   "
				rs.movenext
			Loop
		else
			Response.write "<tr><td colspan='6' height='27' align='center'>请设置商品属性！</td></tr>"
		end if
		rs.close
		set rs = nothing
	end if
	Response.write "" & vbcrlf & "" & vbcrlf & "                                     <tr class=""top accordion"">" & vbcrlf & "                                                <td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "                                                   <div  class=""accordion-bar-tit"">商品图片<span class=""accordion-arrow-down""></span></div>" & vbcrlf & "                                            </td>" & vbcrlf & "                                   </tr>" & vbcrlf& "                                       <tr>" & vbcrlf & "                                            <td width=""10%"" align=""right"" height=""27"">商品图片：</td>" & vbcrlf & "                                             <td colspan=""6"">" & vbcrlf & "                                                  <div class=""multimage-gallery"">" & vbcrlf & "                                                           <input type=""hidden"" id=""primaryImg"" name=""primaryImg"" value="""
	Response.write "<tr><td colspan='6' height='27' align='center'>请设置商品属性！</td></tr>"
	Response.write primaryImg
	Response.write """ >" & vbcrlf & "                                                               <ul id=""goodsPic"">" & vbcrlf & "" & vbcrlf & "                                                                        "
	If goodsID = 0 Then
		For i = 1 To 6
			Response.write "" & vbcrlf & "                                                                                     <li data-index="""
'For i = 1 To 6
			Response.write i
			Response.write """ "
			If i = 1 Then
				Response.write " class=""primary"""
			end if
			Response.write ">" & vbcrlf & "                                                                                            "
			If i = 1 Then
				Response.write "" & vbcrlf & "                                                                                             <div class=""info"">主图 <span class=""red"">*</span><br>800*800</div>" & vbcrlf & "                                                                                          "
			end if
			Response.write "" & vbcrlf & "                                                                                             <div class=""preview""></div>" & vbcrlf & "                                                                                               <div class=""operate"">" & vbcrlf & "                                                                                                     <i class=""toleft"">左移</i>" & vbcrlf & "                                                                                                        <i class=""toright"">右移</i>" & vbcrlf & "                                                                                                       <i class=""del"">删除</i>" & vbcrlf & "                                                                                           </div>"& vbcrlf & "                                                                                      </li>" & vbcrlf & "                                                                           "
		next
	Else
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT TOP 6 * FROM sys_upload_res WHERE source = 'goodsPic' AND id1 = "& goodsID &" ORDER BY id3 ASC"
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Dim x,fpath
			x = 1
			Do While Not rs.Eof
				fpath = rs("fpath")
				If x = 1 And rs("ID2") <> 1 Then
					Response.write "" & vbcrlf & "                                                                                     <li data-index="""
'If x = 1 And rs("ID2") <> 1 Then
					Response.write x
					Response.write """ "
					If x = 1 Then
						Response.write " class=""primary"""
					end if
					Response.write ">" & vbcrlf & "                                                                                            "
					If x = 1 Then
						Response.write "" & vbcrlf & "                                                                                             <div class=""info"" style=""display:none;"">主图 <span class=""red"">*</span><br>800*800</div>" & vbcrlf & "                                                                                              "
					end if
					Response.write "" & vbcrlf & "                                                                                             <div class=""preview""></div>" & vbcrlf & "                                                                                               <div class=""operate"">" & vbcrlf & "                                                                                                     <i class=""toleft"">左移</i>" & vbcrlf & "                                                                                                        <i class=""toright"">右移</i>" & vbcrlf & "                                                                                                       <i class=""del"">删除</i>" & vbcrlf & "                                                                                           </div>"& vbcrlf & "                                                                                      </li>" & vbcrlf & "                                                                                   "
					x = 2
					Response.write "" & vbcrlf & "                                                                                     <li data-index="""
					'x = 2
					Response.write x
					Response.write """ "
					If x = 1 Then
						Response.write " class=""primary"""
					end if
					Response.write ">" & vbcrlf & "                                                                                            "
					If x = 1 Then
						Response.write "" & vbcrlf & "                                                                                             <div class=""info"" style=""display:none;"">主图 <span class=""red"">*</span><br>800*800</div>" & vbcrlf & "                                                                                              "
					end if
					Response.write "" & vbcrlf & "                                                                                             <div class=""preview""><img src=""../../edit/upimages/shop/"
					Response.write fpath
					Response.write """ fileID="""
					Response.write rs("id")
					Response.write """>" & vbcrlf & "                                                                                                <input type=""hidden"" name=""fileID"" value="""
					Response.write rs("id")
					Response.write """ >" & vbcrlf & "                                                                                               </div>" & vbcrlf & "                                                                                          <div class=""operate"">" & vbcrlf & "                                                                                                     <i class=""toleft"">左移</i>" & vbcrlf & "                                                                                                        <i class=""toright"">右移</i>" & vbcrlf & "                                                                                                       <i class=""del"">删除</i>" & vbcrlf & "                                                                                           </div>" & vbcrlf & "                                          </li>                                                                                   " & vbcrlf & "                                                                                        "
				else
					Response.write "" & vbcrlf & "                                                                                     <li data-index="""
					Response.write x
					Response.write """ "
					If x = 1 Then
						Response.write " class=""primary"""
					end if
					Response.write ">" & vbcrlf & "                                                                                            "
					If x = 1 Then
						Response.write "" & vbcrlf & "                                                                                             <div class=""info"" style=""display:none;"">主图 <span class=""red"">*</span><br>800*800</div>" & vbcrlf & "                                                                                              "
					end if
					Response.write "" & vbcrlf & "                                                                                             <div class=""preview""><img src=""../../edit/upimages/shop/"
					Response.write fpath
					Response.write """ fileID="""
					Response.write rs("id")
					Response.write """>" & vbcrlf & "                                                                                                <input type=""hidden"" name=""fileID"" value="""
					Response.write rs("id")
					Response.write """ >" & vbcrlf & "                                                                                               </div>" & vbcrlf & "                                                                                          <div class=""operate"">" & vbcrlf & "                                                                                                     <i class=""toleft"">左移</i>" & vbcrlf & "                                                                                                        <i class=""toright"">右移</i>" & vbcrlf & "                                                                                                       <i class=""del"">删除</i>" & vbcrlf & "                                                                                           </div>" & vbcrlf & "                                          </li>" & vbcrlf & "                                                                                   "
				end if
				x = x + 1
				rs.movenext
			Loop
			For i = x To 6
				Response.write "" & vbcrlf & "                                                                                     <li data-index="""
'For i = x To 6
				Response.write i
				Response.write """>" & vbcrlf & "                                                                                                <div class=""preview""></div>" & vbcrlf & "                                                                                               <div class=""operate"">" & vbcrlf & "                                                                                                     <i class=""toleft"">左移</i>" & vbcrlf & "                                                                                                        <i class=""toright"">右移</i>" & vbcrlf & "                                                                                                       <i class=""del"">删除</i>" & vbcrlf & "                                                                                           </div>" & vbcrlf & "                                                                                  </li>" & vbcrlf & "                                                                           "
			next
		else
			For i = 1 To 6
				Response.write "" & vbcrlf & "                                                                                     <li data-index="""
'For i = 1 To 6
				Response.write i
				Response.write """ "
				If i = 1 Then
					Response.write " class=""primary"""
				end if
				Response.write ">" & vbcrlf & "                                                                                            "
				If i = 1 Then
					Response.write "" & vbcrlf & "                                                                                             <div class=""info"">主图 <span class=""red"">*</span><br>800*800</div>" & vbcrlf & "                                                                                          "
				end if
				Response.write "" & vbcrlf & "                                                                                             <div class=""preview""></div>" & vbcrlf & "                                                                                               <div class=""operate"">" & vbcrlf & "                                                                                                     <i class=""toleft"">左移</i>" & vbcrlf & "                                                                                                        <i class=""toright"">右移</i>" & vbcrlf & "                                                                                                       <i class=""del"">删除</i>" & vbcrlf & "                                                                                           </div>"& vbcrlf & "                                                                                      </li>" & vbcrlf & "                                                                           "
			next
		end if
		rs.close
		set rs = nothing
	end if
	Response.write "" & vbcrlf & "                                                             </ul>" & vbcrlf & "                                                           <div style=""clear:both;""></div>" & vbcrlf & "                                                   <table id=""atttb"" border=""0"" cellspacing=""1"" cellpadding=""0"" bgcolor=""#C0CCDD"" style=""display:none;"">" & vbcrlf & "" & vbcrlf & "                                                       </table>                                                " & vbcrlf & "" & vbcrlf & "        </div>" & vbcrlf & "" & vbcrlf & "                                                  <span style=""cursor:pointer"" onClick=""showUploadForm(this);""><div style=""vertical-align:middle;float:left""><img src='../../images/smico/3.gif'/></div><div id=""addImgBtn"" style=""padding-top:3px;"">添加图片</div>" & vbcrlf & "                                         </td>" & vbcrlf &" </tr>" & vbcrlf & vbcrlf &                "                    <tr class=""top accordion""> "& vbcrlf &                                      "           <td colspan=""6"" class=""accordion-bar-bg""> "& vbcrlf &                                 "                   <div  class=""accordion-bar-tit"">概要信息<span class=""accordion-arrow-down""></span></div> "& vbcrlf &                 "                            </td>" & vbcrlf &                       "            </tr> "& vbcrlf & "                                  <tr>" & vbcrlf & "                                            <td width=""10%"" align=""right"" height=""27"">商品介绍：</td>" & vbcrlf & "                                             <td colspan=""6"">" & vbcrlf & "                                          <span class=""gray"">" & vbcrlf & "                                                       <textarea name=""goodsDescription"" style=""display:none"" cols=""1"" rows=""1"" dataType=""Limit"" min=""1"" msg=""必填"">"
	Response.write goodsDescription
	Response.write "</textarea>" & vbcrlf & "                                                  <iframe id=""eWebEditor1"" src=""../../edit/ewebeditor.asp?id=goodsDescription&style=news"" frameborder=""0"" scrolling=""no"" width=""100%"" height=""300"" marginwidth=""1"" marginheight=""1"" name=""goodsDescription"" class=""g-textarea""></iframe><span class=""red"">*</span> "& vbcrlf &               "                                  </span> "& vbcrlf &              "                            </td>" & vbcrlf &                  "                  </tr> "& vbcrlf &                         "           <tr>" & vbcrlf &                          "                   <td width=""10%"" align=""right"" height=""27"">规格参数：</td> "& vbcrlf &                    "                         <td colspan=""6""> "& vbcrlf &                  "                         <span class=""gray""> "& vbcrlf &                                   "                     <textarea name=""goodsParameter"" style=""display:none"" cols=""1"" rows=""1"" dataType=""Limit"" min=""1"" msg=""必填"">"
	Response.write goodsParameter
	Response.write "</textarea>" & vbcrlf & "                                                  <iframe id=""eWebEditor2"" src=""../../edit/ewebeditor.asp?id=goodsParameter&style=news"" frameborder=""0"" scrolling=""no"" width=""100%"" height=""300"" marginwidth=""1"" marginheight=""1"" name=""goodsParameter"" class=""g-textarea""></iframe><span class=""red"">*</span>" & vbcrlf & "                                              </span>" & vbcrlf & "                                         </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   <tr>" & vbcrlf & "                                            <td width=""10%"" align=""right"" height=""27"">包装售后：</td>" & vbcrlf & "                                             <td colspan=""6"">" & vbcrlf & "                                          <span class=""gray"">" & vbcrlf & "                                                       <textarea name=""goodsBZSH"" cols=""80"" rows=""6"" class=""g-textarea"" dataType=""Require"" msg=""必填"">"
	'Response.write goodsParameter
	Response.write goodsBZSH
	Response.write "</textarea>" & vbcrlf & "                                                  <span class=""red"">*</span>" & vbcrlf & "                                                </span>" & vbcrlf & "                                         </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "" & vbcrlf & "                                   <tr class=""top accordion"">" & vbcrlf & "                                                <td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "                                                   <div  class=""accordion-bar-tit"">上架时间<span class=""accordion-arrow-down""></span></div>" & vbcrlf & "                                           </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   <tr>" & vbcrlf & "                                            <td  height=""40""></td>" & vbcrlf & "                                            <td colspan=""6"">" & vbcrlf & "                                          <span class=""gray"">" & vbcrlf & "                                                       "
	'Response.write goodsBZSH
	If putTime = "" Then putTime = Now()
	If onSale = "" Then onSale = 1
	Response.write "" & vbcrlf & "                                                     <label for=""onSale1""><input type=""radio"" id=""onSale1"" name=""onSale"" value=""1"" "
	If onSale = 1 Then Response.write "checked"
	Response.write " /> 立即上架</label>" & vbcrlf & "                                                 <label for=""onSale2""><input type=""radio"" id=""onSale2"" name=""onSale"" value=""2"" "
	If onSale = 2 Then Response.write "checked"
	Response.write " /> 定时上架 </label>" & vbcrlf & "                                                        <input readonly id=""putTime"" name=""putTime"" size=""20"" value="""
	Response.write putTime
	Response.write """  onMouseUp = ""datedlg.showDateTime();"" minDate="""
	Response.write Date()
	Response.write """>" & vbcrlf & "                                                        <label for=""onSale0""><input type=""radio"" id=""onSale0"" name=""onSale"" value=""0"" "
	If onSale = 0 Then Response.write "checked"
	Response.write " /> 暂缓上架</label>" & vbcrlf & "                                         </span>" & vbcrlf & "                                         </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "" & vbcrlf & "                                   <tr class=""btns-bar"">" & vbcrlf & "                                             <td colspan=""6"" height=""35"">" & vbcrlf & "                                                        <div align=""center"">" & vbcrlf & "                                                              <input type=""submit"" name=""pageType"" value=""保存"" class=""page""/> "& vbcrlf & "                                                              "
	If goodsID = 0 Then
		Response.write "" & vbcrlf & "                                                             <input type=""submit"" name=""pageType"" value=""增加"" class=""page""/>" & vbcrlf & "                                                                "
	end if
	Response.write "" & vbcrlf & "                                                             <input type=""reset"" value=""重填""  class=""page"" name=""B222"">" & vbcrlf & "                                                             "
	If goodsID = "0" Then goodsID = curGoodsID
	Response.write "" & vbcrlf & "                                                             <input type=""hidden"" name=""goodsID"" value="""
	Response.write goodsID
	Response.write """ >" & vbcrlf & "                                                               <input type=""hidden"" name=""Referrer"" value="""
	Response.write Referrer
	Response.write """ >" & vbcrlf & "                                                               " & vbcrlf & "                                                        </div>" & vbcrlf & "                                          </td>" & vbcrlf & "                                   </tr>   " & vbcrlf & "                        </table>" & vbcrlf & "                        </form>" & vbcrlf & "         </td>" & vbcrlf & "   </tr>" & vbcrlf & "   <tr>" & vbcrlf & "            <td  class=""page"">" & vbcrlf & "                        <table width=""100%"" border=""0"" align=""left"" > "& vbcrlf &                   "            <tr> "& vbcrlf &       "                              <td height=""100"" ><div align=""center""></div></td>" & vbcrlf &                  "          </tr> "& vbcrlf &           "         </table> "& vbcrlf &           "      </td>"& vbcrlf &   " </tr> "& vbcrlf &" </table> "& vbcrlf & vbcrlf & vbcrlf
	Response.write "<!--上传文件模块开始-->"
	xmlPath = "../../edit/upimages/shop/" & Timer & ".xml"
	t_v=Split(tfiles,Chr(0) & Chr(1))
	Set objFso = Server.CreateObject("Scripting.FileSystemObject")
	For t_i=0 To ubound(t_v)
		If Len(t_v(t_i)&"")>0 then
			If objFso.FileExists(server.Mappath(t_v(t_i))) Then
				objFso.DeleteFile(server.Mappath(t_v(t_i)))
			end if
		end if
	next
	Set objFso = Nothing
	Response.write "" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "/*#bg{ display:none;position:absolute;top:0%;left:0%;width:100%;height:100%;background-color:#B9C5DD;z-index:1001;-moz-opacity:0.7;opacity:.70;filter:alpha(opacity=50);}" & vbcrlf & "*/" & vbcrlf & ".progress {" & vbcrlf & "    position: absolute;" & vbcrlf & "    filter:alpha(opacity=80);" & vbcrlf & "    padding: 4px;" & vbcrlf & "    top: 50px;" & vbcrlf & "    left: 400px;" & vbcrlf & "    font-family: Verdana, Helvetica, Arial, sans-serif;" & vbcrlf & "    font-size: 9px;" & vbcrlf & "    z-index:1002px;" & vbcrlf & "    width: 250px;" & vbcrlf & "    height:100px;" & vbcrlf & "    background: #DAEAFA;" & vbcrlf & "    color: #3D2C05;" & vbcrlf & "    border: 1px solid #715208;" & vbcrlf & "    /* Mozilla proprietary */" & vbcrlf & "    -moz-border-radius: 5px;" & vbcrlf & "    /*-moz-opacity: 0.95; */" & vbcrlf & "}" & vbcrlf & ".progress table,.progress td{" & vbcrlf & "  font-size:9pt;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".Bar{" & vbcrlf & "  width:100%;" & vbcrlf & "    height:13px;" & vbcrlf & "    background-color:#CCCCCC;" & vbcrlf & "    border: 1px inset #666666;" & vbcrlf & "    margin-bottom:4px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".ProgressPercent{" & vbcrlf & "    font-size: 9pt;" & vbcrlf & "    color: #ffffff;" & vbcrlf & "    height: 13px;" & vbcrlf & "    position: absolute;" & vbcrlf & "    z-index: 20;" & vbcrlf & "    width: 100%;" & vbcrlf & "    text-align: center;" & vbcrlf & "}"& vbcrlf & ".ProgressBar{" & vbcrlf & "  background-color:blue;" & vbcrlf & "    width:1px;" & vbcrlf & "    height:13px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "#sash_left { width:430px; float:left; }" & vbcrlf & "#sash_left ul { text-align:left; vertical-align:middle; padding-left:75px; }" & vbcrlf & "#sash_left ul li { line-height:16px; margin:2px 0; }" & vbcrlf & ".b1, .b2, .b3, .b4 { font-size:1px; overflow:hidden; display:block; }" & vbcrlf & ".b1 { height:1px; background:#AAA; margin:0 5px; }" & vbcrlf & ".b2 { height:1px; background:#DAEAFA; border-right:2px inset #AAA; border-left:2px inset #AAA; margin:0 3px; }" & vbcrlf & ".b3 { height:1px; background:#DAEAFA; border-right:1px inset #AAA; border-left:1px inset #AAA; margin:0 2px; }" & vbcrlf & ".b4 { height:2px; background:#DAEAFA; border-right:1px inset #AAA; border-left:1px inset #AAA; margin:0 1px; }" & vbcrlf & ".contentb { height:99px; background:#DAEAFA; border-right:1px inset #AAA; border-left:1px inset #AAA; }" & vbcrlf & "</style>" & vbcrlf & "<div id=""fupload"" style=""position:absolute;display:none;height:102px;width:300px"">" & vbcrlf & "       <b class=""b1""></b><b class=""b2""></b><b class=""b3""></b><b class=""b4""></b>" & vbcrlf & "    <div class=""contentb"" style=""padding-left:10px;padding-top:7px;padding-right:10px;width:100%;box-sizing:border-box;"">" & vbcrlf & "               <form name=""upform2"" method=""post"" action=""../goodsUpload/ProcUpload.asp?goodsID="
	Set objFso = Nothing
	Response.write goodsID
	Response.write """ onsubmit=""return chkFrm();"" enctype=""multipart/form-data"" target=""if1"" style=""margin:0;padding:0;"">" & vbcrlf & "                      <div class=""reseetTextColor"" style=""float:right;cursor:pointer"" onmouseover=""this.style.color='red'"" onmouseout=""this.style.color='#2F496E';"" onclick=""document.getElementById('fupload').style.display='none';"">关闭</div>" & vbcrlf & "                     <div class=""reseetTextColor"" style=""font-weight:bolder"">文件上传</div>" & vbcrlf & "                      <div class=""reseetTextColor"" style=""height:40px;white-space:nowrap;overflow:hidden;width:100%;margin-top:3px;"">选择文件：<input type=""text"" id=""txt"" disabled style=""width:150px"" name=""txt"" />" & vbcrlf & "                         <input type=""button"" name=""sbtn"" id=""sbtn"" value=""浏览"" class=""page"" onclick=""filefield.click()"">" & vbcrlf & "                           <input type=""file"" name=""filefield"" id=""filefield"" hidefocus=""hidefocus"" onclick=""sbtn.click"" style=""filter:alpha(opacity=0);-moz-opacity:0;opacity:0;overflow:hidden;width:0px;position:relative;left:-60px"" onchange=""txt.value=this.value"">" & vbcrlf & "                      </div>" & vbcrlf & "                  <div class=""reseetTextColor"" style=""color:#5B7CAE"">文件描述：<input type=""text"" style=""width:150px"" name=""filedesc"">" & vbcrlf & "                               <input type=""submit"" value=""上传"" class=""page"">" & vbcrlf & "                       </div>" & vbcrlf & "          </form>" & vbcrlf & " </div>" & vbcrlf & "  <b class=""b4""></b><b class=""b3""></b><b class=""b2""></b><b class=""b1""></b>" & vbcrlf & "</div>" & vbcrlf & "<iframe name=""if1"" style=""width:100px;height:100px;display:none"" src=""""></iframe>" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "var allowExt="""
	Response.write allowExt
	Response.write """;" & vbcrlf & "function addAtt(strName,strSize,strDesc,strDelLink,strPath,fileID)" & vbcrlf & "{" & vbcrlf & "" & vbcrlf & "      $(function(){" & vbcrlf & "           var g = $(""#goodsPic li"");" & vbcrlf & "                var img = $(""<img src='""+ strPath +""' fileID='""+ fileID +""'>"");" & vbcrlf & "               var inp =""<input type='hidden' name='fileID' value='""+ fileID +""' >"";" & vbcrlf & "            " & vbcrlf & "                g.each(function(index,ele){" & vbcrlf & "                     var curImg = $(this).find(""img"");" & vbcrlf & "                 var info = $(this).find("".info"");" & vbcrlf & "                 if(curImg.size() == 0){" & vbcrlf & "                         $.post(""../goodsUpload/ProcDelFile.asp"",{action:""fileSort"",fileID:fileID,sort:index+1},function(){" & vbcrlf & "                                       //alert(index);" & vbcrlf & "                         });" & vbcrlf & "                             $(this).find("".preview"").html(img)" & vbcrlf & "                                $(this).find("".preview"").append(inp);" & vbcrlf & "                             if(index == 0){" & vbcrlf &" info.hide(); "& vbcrlf &                    "                 // 设置主图的文件ID" & vbcrlf &                   "                   var pImg = $(""#primaryImg""); "& vbcrlf &                       "                pImg.val(fileID); "& vbcrlf &         "                       }; "& vbcrlf &                     "          return false; "& vbcrlf &        "            }; "& vbcrlf &              "     "     & vbcrlf &        "         }); "& vbcrlf &      "      "   & vbcrlf & vbcrlf &   "    "   & vbcrlf & "});" & vbcrlf & "  " & vbcrlf & "        var tbobj=document.getElementById(""atttb"");" & vbcrlf & "       if(tbobj.rows.length==0)" & vbcrlf & "        {" & vbcrlf & "               var th=tbobj.insertRow(-1);" & vbcrlf & "             th.className=""top"";" & vbcrlf & "               var th1=th.insertCell(-1);" & vbcrlf & "              var th2=th.insertCell(-1);" &vbcrlf & "         var th3=th.insertCell(-1);" & vbcrlf & "              var th4=th.insertCell(-1);" & vbcrlf & "              th1.innerHTML=""<center><span style='font-weight:bolder'>文件名</span></center>"";" & vbcrlf & "          th2.innerHTML=""<center><span style='font-weight:bolder'>文件大小</span></center>"";" & vbcrlf & "                th3.innerHTML=""<center><span style='font-weight:bolder'>文件描述</span></center>"";" & vbcrlf & "         th4.innerHTML=""<center><span style='font-weight:bolder'>删除</span></center>"";" & vbcrlf & "    }" & vbcrlf & "       var newtr=tbobj.insertRow(-1);" & vbcrlf & "  //newtr.className=""top"";" & vbcrlf & "  var newcell1=newtr.insertCell(-1);" & vbcrlf & "        var newcell2=newtr.insertCell(-1);" & vbcrlf & "      var newcell3=newtr.insertCell(-1);" & vbcrlf & "      var newcell4=newtr.insertCell(-1);" & vbcrlf & "      newtr.style.height=""22px""" & vbcrlf & " newcell1.style.paddingLeft=""20px"";" & vbcrlf & "        newcell1.style.paddingRight=""20px"";" & vbcrlf & "      newcell1.innerHTML=""<center><span style='font-weight:lighter'>""+strName+""</span></center>"";" & vbcrlf & " newcell2.style.paddingLeft=""20px"";" & vbcrlf & "        newcell2.style.paddingRight=""20px"";" & vbcrlf & "       newcell2.innerHTML=""<center><span style='font-weight:lighter'>""+strSize+""</span></center>"";" & vbcrlf & "     newcell3.style.paddingLeft=""20px"";" & vbcrlf & "        newcell3.style.paddingRight=""20px"";" & vbcrlf & "       newcell3.innerHTML=""<center><span style='font-weight:lighter'>""+strDesc+""</span></center>"";" & vbcrlf & " newcell4.style.paddingLeft=""20px"";" & vbcrlf & "      newcell4.style.paddingRight=""20px"";" & vbcrlf & "       newcell4.innerHTML=""<center><span style='font-weight:lighter'>""+strDelLink+""</span></center>"";" & vbcrlf & "      var tmpFrame;" & vbcrlf & "   if(tmpFrame=parent.document.getElementById(""cFF"")){tmpFrame.style.height=document.body.scrollHeight+0+""px"";}" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function delRow(obj,ord)" & vbcrlf & "{" & vbcrlf & "   if(confirm(""确定要删除此文件吗（删除后不可恢复）？""))" & vbcrlf & "     {" & vbcrlf & "               var trobj=obj.parentElement.parentElement.parentElement.parentElement;" & vbcrlf & "          var hidobj=trobj.getElementsByTagName(""input"")" & vbcrlf & "              var fname=hidobj[0].value;" & vbcrlf & "              var foname=hidobj[1].value;" & vbcrlf & "             var ajaxurl=""ProcDelFile.asp?ord=""+ord+""&f=""+escape(foname+""/""+fname)+""&t=""+Math.random();" & vbcrlf & "              xmlHttp.open(""GET"", ajaxurl, false);" & vbcrlf & "              xmlHttp.onreadystatechange = function(){" & vbcrlf & "         if (xmlHttp.readyState < 4) {" & vbcrlf & "           }" & vbcrlf & "               if (xmlHttp.readyState == 4) {" & vbcrlf & "          var response = xmlHttp.responseText.split(""</noscript>"")[1];" & vbcrlf & "              xmlHttp.abort();" & vbcrlf & "                }" & vbcrlf & "               };" & vbcrlf & "              xmlHttp.send(null);" & vbcrlf & "             trobj.parentElement.removeChild(trobj);" & vbcrlf & "         var tbobj=document.getElementById(""atttb"");" & vbcrlf & "               if(tbobj.rows.length==1) tbobj.deleteRow(0);" & vbcrlf & "    }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function showUploadForm(obj)" & vbcrlf & "{" & vbcrlf & ""& vbcrlf &  "    var img = $(""#goodsPic li .preview img"");" & vbcrlf & " if(img.size() >= 6){" & vbcrlf & "            alert('最多可以上传6张图片！');" & vbcrlf & "         return false;" & vbcrlf & "   };" & vbcrlf & "      " & vbcrlf & "" & vbcrlf & "        var x=obj.offsetLeft,y=obj.offsetTop;" & vbcrlf & "   var obj2=obj;" & vbcrlf & "   var offsetx=25;" & vbcrlf & "      while(obj2=obj2.offsetParent)" & vbcrlf & "   {" & vbcrlf & "               x+=obj2.offsetLeft;  " & vbcrlf & "           y+=obj2.offsetTop;" & vbcrlf & "      }" & vbcrlf & "       var showobj=document.getElementById(""fupload"");" & vbcrlf & "   showobj.style.display=""block"";" & vbcrlf & "    showobj.style.left=offsetx+x+""px"";" & vbcrlf & " showobj.style.top=y-5+""px"";" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function chkFrm()" & vbcrlf & "{" & vbcrlf & "  if (document.getElementsByTagName(""html"")[0].className == ""IE8"") {" & vbcrlf & "      if (window.event.srcElement.getAttribute(""IE8XXXX"") != ""1"") { "& vbcrlf &        "   window.event.srcElement.setAttribute(""IE8XXXX"", ""1"");" & vbcrlf &         "  return; "& vbcrlf &   "    } "& vbcrlf &   "    else { "& vbcrlf &      "     window.event.srcElement.setAttribute(""IE8XXXX"", ""0"");" & vbcrlf &  "     } "& vbcrlf & "  }" & vbcrlf & "  var objFrm = document.upform2;" & vbcrlf & "  if(objFrm.filefield.value=="""")" & vbcrlf & "  {" & vbcrlf & "             alert(""请选择一个文件"");" & vbcrlf & "          return false;" & vbcrlf & "  }" & vbcrlf & "  if(objFrm.filedesc.value.length>200)" & vbcrlf & "  {" & vbcrlf & "       alert(""文件描述不能超过200字"");" & vbcrlf & "    return false;" & vbcrlf & "  }" & vbcrlf & "  var arrExt=objFrm.txt.value.split(""."");" & vbcrlf & "  var fExt=arrExt[arrExt.length-1];" & vbcrlf & "  if(allowExt.toLowerCase().indexOf('|'+fExt.toLowerCase()+'|')<0 && arrExt.length!=0)" & vbcrlf & "  {" & vbcrlf & "     alert(""上传的文件不合法,只能上传\n"
	Response.write mid(replace(allowExt,"|",","),2,len(allowExt)-2)
'上传\n"
	Response.write "格式的文件"")" & vbcrlf & "       return false;" & vbcrlf & "  }" & vbcrlf & "  objFrm.action = ""../goodsUpload/ProcUpload.asp?opt=Upload&xmlPath="
	Response.write xmlPath
	Response.write "&goodsID="
	Response.write goodsID
	Response.write """;" & vbcrlf & "  document.getElementById(""fupload"").style.display=""none"";" & vbcrlf & "  document.getElementById(""bg"").style.display=""block"";" & vbcrlf & "" & vbcrlf & " ProgressPercent.innerHTML = ""0%"";" & vbcrlf & " ProgressBar.style.width = ""0%"";" & vbcrlf & "   uploadSize.innerHTML = '0';" & vbcrlf & "  uploadSpeed.innerHTML = '0';" & vbcrlf & "    totalTime.innerHTML = '0';" & vbcrlf & "      leftTime.innerHTML = '0';" & vbcrlf & "  startProgress('"
	Response.write xmlPath
	Response.write "');//启动进度条" & vbcrlf & "  return true;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "//启动进度条" & vbcrlf & "function startProgress(xmlPath)" & vbcrlf & "{" & vbcrlf & "  displayProgress();" & vbcrlf & "  setProgressDivPos();" & vbcrlf & "  setTimeout(""DisplayProgressBar('"" + xmlPath + ""')"",500);"& vbcrlf & "}" & vbcrlf & vbcrlf & "function DisplayProgressBar(xmlPath) "& vbcrlf &" { "& vbcrlf &   "  var xmlDoc; "& vbcrlf &  "   if (window.ActiveXObject) {" & vbcrlf &     "    xmlDoc = new ActiveXObject(""Msxml2.DOMDocument.3.0"");" & vbcrlf & " xmlDoc.async = false;" & vbcrlf & "   xmlDoc.load(xmlPath);" & vbcrlf & "        if (xmlDoc.parseError.errorCode!=0)" & vbcrlf & "        {" & vbcrlf & "            //var error = xmlDoc.parseError;" & vbcrlf & "            //alert(error.reason)" & vbcrlf & "            setTimeout(""DisplayProgressBar('"" + xmlPath + ""')"",1000);" & vbcrlf & "            return;" & vbcrlf & "        }" & vbcrlf & "" & vbcrlf & "   try" & vbcrlf & "     {" & vbcrlf & "               var root = xmlDoc.documentElement;   //根节点" & vbcrlf & "           var totalbytes = root.childNodes(0).text;" & vbcrlf & "               var uploadbytes = root.childNodes(1).text;" & vbcrlf & "              var percent = root.childNodes(2).text;" & vbcrlf & "                ProgressPercent.innerHTML = percent + ""%"";" & vbcrlf & "                ProgressBar.style.width = percent + ""%"";" & vbcrlf & "          uploadSize.innerHTML = uploadbytes;" & vbcrlf & "             uploadSpeed.innerHTML = root.childNodes(3).text;" & vbcrlf & "                totalTime.innerHTML = root.childNodes(4).text;" & vbcrlf & "             leftTime.innerHTML = root.childNodes(5).text;" & vbcrlf & "           if (percent<100)" & vbcrlf & "                {" & vbcrlf & "                       setTimeout(""DisplayProgressBar('"" + xmlPath + ""')"",1000);" & vbcrlf & "           }" & vbcrlf & "       }" & vbcrlf & "       catch(e)" & vbcrlf & "        {" & vbcrlf & "      }" & vbcrlf & "}}" & vbcrlf & "" & vbcrlf & "function displayProgress()" & vbcrlf & "{" & vbcrlf & "  var objProgress = document.getElementById(""Progress"");" & vbcrlf & "  objProgress.style.display = """";" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function closeProgress()" & vbcrlf & "{" & vbcrlf & "  var objProgress = document.getElementById(""Progress"");" & vbcrlf & "  objProgress.style.display = ""none"";" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function setProgressDivPos()" & vbcrlf & "{" & vbcrlf & "   var objProgress = document.getElementById(""Progress"");" & vbcrlf & "    objProgress.style.top = document.body.scrollTop+($(""#addImgBtn"").position().top)/2;" & vbcrlf & "   objProgress.style.left = document.body.scrollLeft+(document.body.clientWidth-document.getElementById(""Progress"").offsetWidth)/2;" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "<div id=""Progress"" style=""display:none;"" class=""progress"">" & vbcrlf & "    <div class=""bar"">" & vbcrlf & "        <div id=""ProgressPercent"" class=""ProgressPercent"">0%</div>" & vbcrlf & "        <div id=""ProgressBar"" class=""ProgressBar""></div>" & vbcrlf & "    </div>" & vbcrlf & "    <table border=""0"" cellspacing=""0"" cellpadding=""1"">" & vbcrlf & "        <tr>" & vbcrlf & "            <td>已经上传</td>" & vbcrlf & "            <td>:</td>" & vbcrlf & "            <td id=""uploadSize""></td>" & vbcrlf & "        </tr>" & vbcrlf & "        <tr>" & vbcrlf & "            <td>上传速度</td>" & vbcrlf & "        <td>:</td>" & vbcrlf & "            <td id=""uploadSpeed"">&nbsp;</td>" & vbcrlf & "        </tr>" & vbcrlf & "        <tr>" & vbcrlf & "            <td>共需时间</td>" & vbcrlf & "            <td>:</td>" & vbcrlf & "            <td id=""totalTime"">&nbsp;</td>" & vbcrlf & "        </tr>" & vbcrlf & "<tr> "& vbcrlf &        "     <td>剩余时间</td> "& vbcrlf &       "      <td>:</td> "& vbcrlf &        "     <td id=""leftTime"">&nbsp;</td> "& vbcrlf &   "      </tr>" & vbcrlf &  "   </table> "& vbcrlf & "</div> "& vbcrlf & "<div id=""bg""></div>" & vbcrlf &" <!--上传模块结束--> "& vbcrlf
	'Response.write xmlPath
	Response.write "" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	action1 = pageTitle
	call close_list(1)
	
%>
