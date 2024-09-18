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
	
	Response.write vbcrlf
	Response.write "<style>" & vbcrlf & ".select{width:120px;}" & vbcrlf & "</style>" & vbcrlf & ""
	LoginUser = Session("personzbintel2007")
	Set rs = server.CreateObject("adodb.recordset")
	sql = "SELECT num1 FROM setjm3 WHERE ord = 1"
	rs.open sql,conn,1,1
	If Not rs.Eof Then
		moneyScale = rs(0)
	else
		moneyScale = 2
	end if
	rs.close
	set rs = nothing
	Set rs = server.CreateObject("adodb.recordset")
	sql = "SELECT num1 FROM setjm3 WHERE ord = 88"
	rs.open sql,conn,1,1
	If Not rs.Eof Then
		numScale = rs(0)
	else
		numScale = 2
	end if
	rs.close
	set rs = nothing
	Function IsCloseModule(ByVal sort1, ByVal sort2)
		Dim rs_qx,sql_qx,qx_open
		IsCloseModule = True
		sql_qx = "SELECT ISNULL(qx_open,0) FROM [POWER] WHERE sort1 = "&sort1&" AND sort2 = "&sort2&" AND ord = "&LoginUser&" "
		Set rs_qx = conn.Execute(sql_qx)
		If Not rs_qx.Eof Then
			qx_open              = rs_qx(0)
		else
			qx_open = 0
		end if
		rs_qx.Close : Set rs_qx = Nothing
		If qx_open = 1 Then
			IsCloseModule = False
		end if
	end function
	Function IsPower(ByVal sort1, ByVal sort2, ByVal UserID)
		Dim rs_qx,sql_qx,qx_open,qx_intro,qx_type
		If Share = "" Then Share = 0
		sql_qx = "SELECT ISNULL(sort,0) sort FROM qxlblist WHERE sort1 = "&sort1&" AND sort2 = "&sort2&" "
		Set rs_qx = conn.Execute(sql_qx)
		If Not rs_qx.Eof Then
			qx_type = rs_qx("sort")
		else
			qx_type = 0
		end if
		rs_qx.Close : Set rs_qx = Nothing
		If qx_type <> 0 Then
			sql_qx = "SELECT ISNULL(qx_open,0),ISNULL(qx_intro,'-222') FROM [POWER] WHERE sort1 = "&sort1&" AND sort2 = "&sort2&" AND ord = "&LoginUser&" "
'If qx_type <> 0 Then
			Set rs_qx = conn.Execute(sql_qx)
			If Not rs_qx.Eof Then
				qx_open              = rs_qx(0)
				qx_intro     = rs_qx(1)
			else
				qx_open = 0
				qx_intro = ""
			end if
			rs_qx.Close : Set rs_qx = Nothing
			If qx_open = qx_type Or (qx_open = 1 And InStr(","&Replace(qx_intro & ""," ","")&",",","&Replace(UserID & ""," ","")&",") > 0 ) Then
				IsPower = True
			else
				IsPower = False
			end if
		else
			IsPower = False
		end if
	end function
	Function IsPower2(ByVal sort1, ByVal sort2)
		Dim rs_qx,sql_qx,qx_open,qx_intro,qx_type
		If Share = "" Then Share = 0
		sql_qx = "SELECT ISNULL(sort,0) sort FROM qxlblist WHERE sort1 = "&sort1&" AND sort2 = "&sort2&" "
		Set rs_qx = conn.Execute(sql_qx)
		If Not rs_qx.Eof Then
			qx_type = rs_qx("sort")
		else
			qx_type = 0
		end if
		rs_qx.Close : Set rs_qx = Nothing
		If qx_type <> 0 Then
			sql_qx = "SELECT ISNULL(qx_open,0),ISNULL(qx_intro,'-222') FROM [POWER] WHERE sort1 = "&sort1&" AND sort2 = "&sort2&" AND ord = "&LoginUser&" "
'If qx_type <> 0 Then
			Set rs_qx = conn.Execute(sql_qx)
			If Not rs_qx.Eof Then
				qx_open              = rs_qx(0)
				qx_intro     = rs_qx(1)
			else
				qx_open = 0
				qx_intro = ""
			end if
			rs_qx.Close : Set rs_qx = Nothing
			If qx_open = qx_type Or qx_open = 1 Then
				IsPower2 = True
			else
				IsPower2 = False
			end if
		else
			IsPower2 = False
		end if
	end function
	Sub GetProcessBox(PID)
		Dim rs,sql,strHTML,ID,Title
		strHTML = "<select id='ProcessID' name='ProcessID' class='select' dataType='Limit' min='1' max='50' msg='必填' "
		If Status > 0 Then
			strHTML = strHTML& "disabled"
		end if
		strHTML = strHTML& ">"
		strHTML = strHTML&"<option value=''>请选择维修流程</option>"
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT ID,Title FROM Comm_ProcessSet WHERE Type = 1 AND IsUse = 1 ORDER BY Ranking DESC,AddTime DESC"
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While rs.Eof = False
				ID = rs("ID")
				Title = rs("Title")
				strHTML = strHTML&"<option value='"&ID&"' "
				If ID = PID Then
					strHTML = strHTML&"selected"
				end if
				strHTML = strHTML&">"&Title&"</option>"
				rs.movenext
			Loop
		end if
		rs.close
		set rs = nothing
		strHTML = strHTML&"</select>"
		Response.write(strHTML)
	end sub
	Sub GetDealPersonBox(PID,DealPerson)
		Dim rs,sql,strHTML,pListStr
		If PID = "" Then PID = 0
		strHTML = "<select id='DealPerson' name='DealPerson' class='select' dataType='Limit' min='1' max='50' msg='必填' "
		If Status > 0 Then
			strHTML = strHTML& "disabled"
		end if
		strHTML = strHTML& ">"
		strHTML = strHTML&"<option value=''>请选择处理人员</option>"
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT TOP 1 a.DealPerson FROM Comm_ProcessNodeSet a " &_
		"LEFT JOIN Comm_NodesMap b ON b.NodeID = a.Id " &_
		"WHERE a.Type = 1 AND a.ProcessSet = "&PID&" " &_
		"AND a.Id NOT IN (SELECT NextNodeID FROM Comm_NodesMap) "
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			pListStr = rs(0)
		end if
		rs.close
		set rs = nothing
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT ord,name FROM gate WHERE del = 1 AND CHARINDEX(','+ CAST(ord AS VARCHAR(8000)) +',' , ','+ '"&pListStr&"' +',') > 0 AND ord IN (SELECT ord FROM power WHERE sort1 = 46 AND sort2 = 13 AND qx_open = 1) ORDER BY cateid ASC,ord ASC"
		Set rs = server.CreateObject("adodb.recordset")
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While rs.Eof = False
				ord = rs("ord")
				name = rs("name")
				strHTML = strHTML&"<option value='"&ord&"' "
				If DealPerson = ord Then
					strHTML = strHTML&"selected"
				end if
				strHTML = strHTML&">"&name&"</option>"
				rs.movenext
			Loop
		end if
		rs.close
		set rs = nothing
		strHTML = strHTML&"</select>"
		Response.write(strHTML)
	end sub
	Function GetUserName(ord)
		If IsNull(ord) Then ord = -1
'Function GetUserName(ord)
		Set rs0 = Conn.Execute("SELECT name FROM gate WHERE del = 1 AND ord = "&ord&"")
		If Not Rs0.Eof Then
			GetUserName = rs0("name")
		end if
		rs0.Close
		Set rs0 = Nothing
	end function
	Function vbsUnEscape(str)
		dim i,s,c
		s=""
		For i=1 to Len(str)
			c=Mid(str,i,1)
			If Mid(str,i,2)="%u" and i<=Len(str)-5 Then
				c=Mid(str,i,1)
				If IsNumeric("&H" & Mid(str,i+2,4)) Then
'c=Mid(str,i,1)
					s = s & CHRW(CInt("&H" & Mid(str,i+2,4)))
'c=Mid(str,i,1)
					i = i+5
'c=Mid(str,i,1)
				else
					s = s & c
				end if
			ElseIf c="%" and i<=Len(str)-2 Then
				s = s & c
				If IsNumeric("&H" & Mid(str,i+1,2)) Then
's = s & c
					s = s & CHRW(CInt("&H" & Mid(str,i+1,2)))
's = s & c
					i = i+2
's = s & c
				else
					s = s & c
				end if
			else
				s = s & c
			end if
		next
		vbsUnEscape = s
	end function
	Function GetRelatedWhere(rType,User)
		Dim Department,Group,UserLevel,rs,sql,str
		sql = "SELECT sorce,sorce2,cateid FROM gate WHERE ord = "&User&" "
		Set rs = server.CreateObject("adodb.recordset")
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Department  = rs("sorce")
			Group               = rs("sorce2")
			UserLevel   = rs("cateid")
		end if
		rs.close
		set rs = nothing
		If rType = 1 Then
			Select Case UserLevel
			Case 1
			str = " AND ord = "&LoginUser&" "
			Case 2
			str = " AND cateid = 1 "
			Case 3
			str = " AND sorce = "&Department&" "
			Case 4
			str = " AND sorce = "&Department&" AND sorce2 = "&Group&" "
			End Select
		ElseIf rType = 2 Then
			Select Case UserLevel
			Case 1
			str = " AND ord = "&LoginUser&" "
			Case 2
			str = " AND cateid = 1 "
			Case 3
			str = " AND (sorce = "&Department&" OR cateid = 1)  "
			Case 4
			str = " AND (sorce = "&Department&" OR cateid = 1)  "
			End Select
		Else
			str = ""
		end if
		GetRelatedWhere = str
	end function
	Function JiejianToHtml(mxid)
		Dim rs, jiejianStr, JFtype, JFTitle, jianID
		jiejianStr = "" : JFtype = "" : JFTitle = ""
		If mxid&""<>"" Then
			Set rs = conn.execute("select a.id,a.title1,a.title2,b.Ftype,(case when b.FType = 7 then c.CValue else a.intro end) as intro from repair_sl_jian a inner join ERP_CustomFields b on a.sortid2=b.ID and b.del=1 left join ERP_CustomOptions c on c.CFID = b.ID and b.FType = 7 and cast(a.intro as varchar(10)) = cast(c.ID as varchar(10)) where a.repair_sl_list="& mxid &" order by a.date7 desc")
			If rs.eof = False Then
				While rs.eof = False
					JFtype = rs("Ftype") : JFTitle = rs("title1") : jianID = rs("id")
					jiejianStr = jiejianStr & rs("title2") &"："& rs("intro")
					rs.movenext
					If rs.eof = False Then
						jiejianStr = jiejianStr & "<br>"
					end if
				wend
			end if
			rs.close
			set rs = nothing
		end if
		JiejianToHtml = jiejianStr
	end function
	Function IsBeforeWhere(repID,PID,NID)
		IsBeforeWhere       = False
		Dim rs,sql
		sql = "SELECT BeforeNodeType FROM Copy_ProcessNodeSet WHERE RepairOrder = "&repID&" AND ProcessSet = "&PID&" AND Id = "&NID&" "
		set rs = conn.execute(sql)
		If Not rs.Eof Then
			BeforeNodeType = rs("BeforeNodeType")
		end if
		rs.close
		set rs = nothing
		sql =       "SELECT COUNT(1) NodeNum,ISNULL(SUM(b.CurrentStatus),0) DealNum  " &_
		"FROM Copy_NodesMap a " &_
		"LEFT JOIN RepairDeal b ON a.NodeID = b.NodeID AND b.RepairOrder = "&repID&" AND b.ProcessID = "&PID&" " &_
		"WHERE a.del = 1 AND a.RepairOrder = "&repID&" AND ProcessSet = "&PID&" AND a.NextNodeID = "&NID&" "
		set rs = conn.execute(sql)
		If Not rs.Eof Then
			NodeNum     = rs("NodeNum")
			DealNum = rs("DealNum")
		else
			NodeNum = 0
			DealNum = 0
		end if
		rs.close
		set rs = nothing
		If BeforeNodeType = 1 Then
			If (NodeNum > 0 And DealNum > 0 And NodeNum = DealNum) Or (NodeNum = 0 And DealNum = 0) Then
				IsBeforeWhere = True
			else
				IsBeforeWhere = False
			end if
		ElseIf BeforeNodeType = 2 Then
			If NodeNum > 0 And DealNum > 0 And NodeNum >= DealNum Then
				IsBeforeWhere = True
			else
				IsBeforeWhere = False
			end if
		end if
	end function
	Function IsFinish(repID,PID,NID,BeforeWhere)
		Dim rs,sql,IsDeal,DealStatus,IsMust,rs1,result
		sql = "SELECT a.NodeID,b.CurrentNodeType,b.BeforeNodeType FROM Copy_NodesMap a " &_
		"LEFT JOIN Copy_ProcessNodeSet b ON a.NodeID = b.ID AND b.del = 1 AND b.RepairOrder = "&repID&" AND b.ProcessSet = "&PID&" " &_
		"WHERE a.del = 1 AND a.RepairOrder = "&repID&" AND a.ProcessSet = "&PID&" AND a.NextNodeID = "&NID&" "
		set rs = conn.execute(sql)
		If Not rs.Eof Then
			While rs.Eof = False
				curID = rs("NodeID")
				curBeforeWhere      = rs("BeforeNodeType")
				IsMust = rs("CurrentNodeType")
				Set rs1 = conn.Execute("SELECT CurrentStatus FROM RepairDeal WHERE del = 1 AND RepairOrder = "&repID&" AND ProcessID = "&PID&" AND NodeID = "&curID&" ")
				If Not rs1.Eof Then
					IsDeal      = True
					DealStatus  = rs1("CurrentStatus")
				else
					IsDeal      = False
				end if
				rs1.Close
				Set rs1 = Nothing
				If DealStatus = 1 And BeforeWhere = 2 Then
					IsFinish = True
					Exit Function
				end if
				If IsDeal And DealStatus = 0 And BeforeWhere = 1 Then
					IsFinish = False
					Exit Function
				end if
				If Not IsDeal Then
					IsFinish = False
					If IsMust = 1 Then
						IsFinish = False
						Exit Function
					else
						result = IsFinish(repID,PID,curID,curBeforeWhere)
						If Not result Then
							IsFinish = False
							Exit Function
						else
							If curBeforeWhere = 2 Then
								IsFinish = True
								Exit Function
							end if
						end if
					end if
				end if
				rs.movenext
			wend
			IsFinish = true
		else
			IsFinish = True
		end if
		rs.close
		set rs = nothing
	end function
	Function GetRelatedStatus(rBillType,repID)
		Dim arr,rs,sql,i,zt1,zt2,has,str
		If rBillType = "" Then
			GetRelatedStatus = "无"
			Exit Function
		end if
		arr = Replace(rBillType," ","")
		sql = "SELECT MAX(a.zt1) ZT1,MAX(a.zt2) ZT2,MAX(b.complete) C1,MAX(c.isInvoiced) C2,ISNULL(MAX(a.ord),0) has FROM contract a " &_
		"LEFT JOIN payback b ON b.contract = a.ord AND b.del = 1 " &_
		"LEFT JOIN paybackInvoice c ON c.fromType = 'CONTRACT' AND c.fromId = a.ord AND c.del = 1 " &_
		"WHERE a.del = 1 and isnull(a.status,-1) in (-1,1) AND a.RepairOrderID = "&repID&" "
		set rs = conn.execute(sql)
		If Not rs.Eof Then
			zt1 = rs("zt1")
			zt2 = rs("zt2")
			c1  = rs("c1")
			c2  = rs("c2")
			has = rs("has")
		else
			zt1 = -1
			has = rs("has")
			zt2 = -1
			has = rs("has")
			c1  = -1
			has = rs("has")
			c2  = -1
			has = rs("has")
			has = 0
		end if
		rs.close
		set rs = nothing
		If InStr(1,arr,1,1) > 0 Then
			If has > 0 Then
				str = str &" <label><input type='checkbox' value='1' checked disabled id='r1'> 已建合同</label>"
			else
				str = str &" <label><input type='checkbox' value='0' disabled id='r1'> 已建合同</label>"
			end if
		end if
		If InStr(1,arr,2,1) > 0 Then
			If zt1 >= 2 Then
				str = str &" <label><input type='checkbox' value='2' checked disabled id='r2'> 已出库</label>"
			else
				str = str &" <label><input type='checkbox' value='0' disabled id='r2'> 已出库</label>"
			end if
		end if
		If InStr(1,arr,3,1) > 0 Then
			If zt2 >= 1 Then
				str = str &" <label><input type='checkbox' value='3' checked disabled id='r3'> 已发货</label>"
			else
				str = str &" <label><input type='checkbox' value='0' disabled id='r3'> 已发货</label>"
			end if
		end if
		If InStr(1,arr,4,1) > 0 Then
			If c1 >= 3 Then
				str = str &" <label><input type='checkbox' value='4' checked disabled id='r4'> 已回款</label>"
			else
				str = str &" <label><input type='checkbox' value='0' disabled id='r4'> 已回款</label>"
			end if
		end if
		If InStr(1,arr,5,1) > 0 Then
			If c2 = 1 Or c2 = 2 Then
				str = str &" <label><input type='checkbox' value='5' checked disabled id='r5'> 已开票</label>"
			else
				str = str &" <label><input type='checkbox' value='0' disabled id='r5'> 已开票</label>"
			end if
		end if
		GetRelatedStatus = str
	end function
	Public Function FormatDate(DateAndTime, para)
		on error resume next
		Dim y, m, d, h, mi, s, strDateTime
		FormatDate = DateAndTime
		If Not IsNumeric(para) Then Exit Function
		If Not IsDate(DateAndTime) Then Exit Function
		y = CStr(Year(DateAndTime))
		m = CStr(Month(DateAndTime))
		If Len(m) = 1 Then m = "0" & m
		d = CStr(Day(DateAndTime))
		If Len(d) = 1 Then d = "0" & d
		h = CStr(Hour(DateAndTime))
		If Len(h) = 1 Then h = "0" & h
		mi = CStr(Minute(DateAndTime))
		If Len(mi) = 1 Then mi = "0" & mi
		s = CStr(Second(DateAndTime))
		If Len(s) = 1 Then s = "0" & s
		Select Case para
		Case "1"
		strDateTime = y & "-" & m & "-" & d & " " & h & ":" & mi & ":" & s
'Case "1"
		Case "2"
		strDateTime = y & "-" & m & "-" & d
'Case "2"
		Case "3"
		strDateTime = y & "/" & m & "/" & d
		Case "4"
		strDateTime = y & "年" & m & "月" & d & "日"
		Case "5"
		strDateTime = m & "-" & d & " " & h & ":" & mi
'Case "5"
		Case "6"
		strDateTime = m & "/" & d
		Case "7"
		strDateTime = m & "月" & d & "日"
		Case "8"
		strDateTime = y & "年" & m & "月"
		Case "9"
		strDateTime = y & "-" & m
'Case "9"
		Case "10"
		strDateTime = y & "/" & m
		Case "11"
		strDateTime = right(y,2) & "-" &m & "-" & d & " " & h & ":" & mi
'Case "11"
		Case "12"
		strDateTime = right(y,2) & "-" &m & "-" & d
'Case "12"
		Case "13"
		strDateTime = m & "-" & d
'Case "13"
		Case Else
		strDateTime = DateAndTime
		End Select
		FormatDate = strDateTime
	end function
	Function strSubtraction(strOri, strComb, strSplit)
		Dim f_str,combArr
		combArr = Split(strComb,",")
		For i = 0 To UBound(combArr)
			If f_str <> "" Then
				strOri = f_str
			end if
			f_str = Replace(strSplit&strOri&strSplit, strSplit&combArr(i)&strSplit, strSplit)
			If Left(f_str, Len(strSplit)) = strSplit Then f_str = Right(f_str, Len(f_str) - Len(strSplit))
'f_str = Replace(strSplit&strOri&strSplit, strSplit&combArr(i)&strSplit, strSplit)
			If Right(f_str, Len(strSplit)) = strSplit Then f_str = Left(f_str, Len(f_str) - Len(strSplit))
'f_str = Replace(strSplit&strOri&strSplit, strSplit&combArr(i)&strSplit, strSplit)
		next
		If f_str = "" Then f_str = 0
		strSubtraction = f_str
	end function
	Response.write vbcrlf
	sub GetBeforeNodeList(ByVal repID,ByVal PID,ByVal NID, ByRef arr)
		Dim rs, sql,  ni , c, nm, nt
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT * FROM Copy_ProcessNodeSet " &_
		"WHERE del = 1 AND RepairOrder = "&repID&" AND ProcessSet = "&PID&" AND "&_
		"Id IN (SELECT NodeID FROM Copy_NodesMap WHERE del = 1 AND RepairOrder = "&repID&" AND ProcessSet = "&PID&" AND NextNodeID = "&NID&") " &_
		"AND Id IN (SELECT NodeID FROM RepairDeal WHERE del = 1 AND CurrentStatus = 1 AND RepairOrder = "&repID&" AND ProcessSet = "&PID&" ) "
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While rs.Eof = False
				ni = rs("ID")
				nm = rs("Title")
				nt = rs("CurrentNodeType")
				If isarray(arr) Then
					c = ubound(arr) + 1
'If isarray(arr) Then
					ReDim Preserve arr(c)
				else
					c = 0
					ReDim arr(c)
				end if
				arr(c) = array(ni , nm)
				If nt = 1 Then
					rs.close
					set rs = nothing
					Exit Sub
				end if
				rs.movenext
			Loop
			rs.close
			set rs = nothing
			Call GetBeforeNodeList(repID,PID,ni, arr)
		else
			rs.close
			set rs = nothing
		end if
	end sub
	Sub ReturnNodeHandle(repID,ID,DealNID,ReturnNID)
		Dim sql
		sql = "UPDATE RepairDeal SET approveRemark=isnull(approveRemark+'|','') + convert(varchar(23),getdate(),120)+',B:"& ReturnNID &",E:"& DealNID &","& sdk.Info.user &"'  WHERE  ID = "& ID
'Dim sql
		conn.Execute(sql)
		sql = "INSERT INTO RepairDeal(CurrentStatus,DealPerson,NodeID,ProcessID,RepairOrder,AddUser) " &_
		"select top 1 0,DealPerson,"& ReturnNID &", ProcessID ,RepairOrder,"& sdk.Info.user &" from RepairDeal where RepairOrder = "& repID &" AND NodeID = "& ReturnNID &" order by id desc "
		conn.Execute(sql)
	end sub
	Sub ReturnNodeStatusUpdate(repID,PID,DealNID,ReturnNID)
		Dim sql1, sql2, sql
		sql1 = "(SELECT TOP 1 ID FROM RepairDeal WHERE del = 1 AND RepairOrder = "&repID&" AND ProcessID = "&PID&" AND NodeID = "&ReturnNID&") "
		sql2 = "(SELECT TOP 1 ID FROM RepairDeal WHERE del = 1 AND RepairOrder = "&repID&" AND ProcessID = "&PID&" AND NodeID = "&DealNID&" AND CurrentStatus = -1) "
		sql = "UPDATE RepairDeal SET CurrentStatus = 0 ,approveRemark=isnull(approveRemark+'|','') + convert(varchar(23),getdate(),120)+',B:"& ReturnNID &",E:"& DealNID &","& sdk.Info.user &"'  WHERE  ID >= "& sql1 &" AND ID < "& sql2 &" "
		conn.Execute(sql)
	end sub
	Sub UpdateBeforeNodeList(ByVal RepairOrder,ByVal ProcessID,ByVal NodeID,ByVal  beginTime, ByVal endTime)
		Dim rs, CurrentNodeType, AutoDealPerson, pList, sql, sql0
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT ID,CurrentNodeType,DealPerson FROM Copy_ProcessNodeSet " &_
		"WHERE del = 1 AND RepairOrder = "&RepairOrder&" AND ProcessSet = "&ProcessID&" "&_
		"AND Id IN (SELECT NodeID FROM Copy_NodesMap WHERE del = 1 AND RepairOrder = "&RepairOrder&" AND ProcessSet = "&ProcessID&" AND NextNodeID = "&NodeID&") "
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While rs.Eof = False
				NodeID = rs("ID")
				CurrentNodeType = rs("CurrentNodeType")
				AutoDealPerson = rs("DealPerson")
				pList = Split(AutoDealPerson,",")
				sql0 = "UPDATE RepairDeal SET DealPerson = "& pList(0) &"," &_
				"Remark = '自动处理 ',AddTime = GETDATE(), " &_
				"ActualBeginTime = '"&beginTime&"',ActualEndTime = '"&endTime&"' "&_
				"WHERE del = 1 AND RepairOrder = "&RepairOrder&" AND ProcessID = "&ProcessID&" AND NodeID = "&NodeID&" AND CurrentStatus = 0 and len(isnull(cast(Remark as nvarchar(max)),''))=0 "
				conn.Execute(sql0)
				sql0 = "UPDATE RepairDeal SET CurrentStatus = 1 WHERE del = 1 AND RepairOrder = "&RepairOrder&" AND ProcessID = "&ProcessID&" AND NodeID = "&NodeID&" AND CurrentStatus = 0"
				conn.Execute(sql0)
				If CurrentNodeType = 1 Then
					Exit Sub
				end if
				rs.movenext
			Loop
			CAll UpdateBeforeNodeList(RepairOrder,ProcessID,NodeID, beginTime, endTime)
		end if
		rs.close
		set rs = nothing
	end sub
	Sub UpdateRepairDealStatus(RepairOrder, ProcessID)
		Dim rs, sql
		set rs = server.CreateObject("adodb.recordset")
		sql = "select top 1 id from repairdeal where del = 1 and repairorder = "&repairorder&" and processid = "&processid&" "
		rs.open sql,conn,1,1
		if not rs.eof then
			conn.execute("update repairorder set status = 1 where id = "&repairorder&" ")
		end if
		rs.close
		set rs = nothing
		set rs = server.CreateObject("adodb.recordset")
		sql = "select top 1 id from repairdeal where repairorder = "&repairorder&" and processid = "&processid&" and currentstatus = 1 " &_
		"and nodeid in ( " &_
		"   select id from copy_processnodeset where repairorder = "&repairorder&" and processset = "&processid&" "&_
		"   and id not in (select nodeid from copy_nodesmap where repairorder = "&repairorder&" and processset = "&processid&") " &_
		") "
		rs.open sql,conn,1,1
		if not rs.eof then
			conn.execute("update repairorder set status = 2,disposedtime = getdate() where id = "&repairorder&" ")
			sql = "update a set a.num3 = b.num from repair_sl_list a " &_
			"inner join repairorder b on b.repair_sl_list = a.id " &_
			"where b.del = 1 and b.id = "&repairorder&" "
			conn.execute(sql)
			sql = "insert into repair_kulist " &_
			"select a.proid,a.repair_sl,a.repair_sl_list,a.id,2,a.num,getdate(),"& sdk.Info.user &",getdate(),1 " &_
			"from repairorder a " &_
			"inner join repair_sl_list b on b.id = a.repair_sl_list and b.ruku = 1 " &_
			"where a.del = 1 and a.id = "&repairorder&" "
			conn.execute(sql)
			Dim rs0, customid
			set rs0 = conn.execute("select isnull(company,0) company from repairorder a inner join repair_sl b on b.id = a.repair_sl where a.id = "&repairorder&" ")
			if not rs0.eof then
				customid = rs0("company")
			else
				customid = 0
			end if
			rs0.close
			set rs0 = nothing
			call getcontent(7,customid,repairorder)
		end if
		rs.close
		set rs = nothing
	end sub
	Sub UpdateSlStatus(ByVal repID)
		Dim rs,sql,slNum,repNum,slStatus,pgStatus , slID
		sql = "SELECT repair_sl FROM RepairOrder WHERE ID = "&repID&" "
		set rs = conn.execute(sql)
		If Not rs.Eof Then
			slID = rs("repair_sl")
		else
			Exit Sub
		end if
		rs.close
		Dim mxnum , wxnum , slStatus2 ,wx0, wx1, wx2
		Set rs = conn.execute("select isnull(sum(l.num1),0) as mxnum from repair_sl_list l inner join repair_sl r on l.repair_sl=r.id and r.del=1 and l.del=1 and l.repair_sl="& slID)
		If rs.eof = False Then
			mxnum = rs("mxnum")
		end if
		rs.close
		Set rs = conn.execute("select isnull(sum(w.NUM),0) as wxnum from RepairOrder w left join repair_sl_list l on w.repair_sl_list = l.id where w.del=1 and l.repair_sl="& slID)
		If rs.eof = False Then
			wxnum =zbcdbl( rs("wxnum"))
		end if
		rs.close
		sql = " select isnull(sum((case when isnull(w.status,0)=0 then w.num else 0 end) ),0) as wx0, isnull(sum((case when isnull(w.status,0)=1 then w.num else 0 end) ),0) as wx1,isnull(sum((case when isnull(w.status,0)=2 then w.num else 0 end) ),0) as wx2  from repair_sl_list l left join RepairOrder w onw.repair_sl = l.repair_sl  and w.repair_sl_list = l.id  and w.del=1 where l.del = 1 and l.repair_sl = " & slID
		set rs = conn.execute(sql)
		If Not rs.Eof Then
			wx0 = rs("wx0")
			wx1 = rs("wx1")
			wx2 = rs("wx2")
		else
			Exit Sub
		end if
		rs.close
		If  CDbl(wxnum)  = 0 Then
			slStatus2 = 0
		ElseIf CDbl(mxnum) = CDbl(wxnum) Then
			slStatus2 = 2
		else
			slStatus2 = 1
		end if
		If CDbl(mxnum) = CDbl(wx2) Then
			slStatus = 2
		ElseIf CDbl(wx1) = 0 And CDbl(wx2) = 0 Then
			slStatus = 0
		else
			slStatus = 1
		end if
		conn.Execute("UPDATE repair_sl SET complete1 = "&slStatus2&",complete2 = "&slStatus&" WHERE id = "&slID&" ")
	end sub
	Function  GetNextNodeList(ByVal repID,ByVal PID,ByVal NID)
		Dim rs,  sql, result : result = ""
		Dim NodeID,  NodeName, CurrentNodeType, NodeType, rs1
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT ID, Title, CurrentNodeType, NodeType FROM Copy_ProcessNodeSet " &_
		"WHERE del = 1 AND RepairOrder = "&repID&" AND ProcessSet = "&PID&" "&_
		"AND Id IN " &_
		"(SELECT NextNodeID FROM Copy_NodesMap WHERE del = 1 AND RepairOrder = "&repID&" AND ProcessSet = "&PID&" AND NodeID = "&NID&") "
		rs.open sql,conn,1,1
		Dim mustnodes
		If Not rs.Eof Then
			Do While rs.Eof = False
				NodeID = rs("ID")
				NodeName = rs("Title")
				CurrentNodeType = rs("CurrentNodeType")
				NodeType = rs("NodeType")
				If Len(result) > 0 Then result = result & Chr(2)
				result = result & NodeName & Chr(1) & NodeID & Chr(1) & Abs(CurrentNodeType=1) & Chr(1) & Abs(CurrentNodeType = 1)
				If CurrentNodeType = 0 Then
					Dim cresult
					cresult = GetNextNodeList(repID,PID,NodeID)
					If Len(cresult)>0 Then
						If Len(result) > 0 Then result = result & Chr(2)
						result = result & cresult
					end if
				end if
				rs.movenext
			Loop
		end if
		rs.close
		set rs = nothing
		GetNextNodeList = result
	end function
	action                = Request("action")
	CurrPage      = cint(Request("CurrPage"))
	Id                    = Request("ID")
	If action = "del" Then
		conn.CursorLocation = 3
		conn.BeginTrans
		on error resume next
		sql = "DELETE RepairNewParts WHERE RepairOrder IN ("&ID&") "
		conn.Execute(sql)
		sql = "DELETE RepairDealApprove WHERE RepairOrder IN ("&ID&") "
		conn.Execute(sql)
		sql = "DELETE RepairTriggerNode WHERE RepairOrder IN ("&ID&") "
		conn.Execute(sql)
		sql = "DELETE RepairDeal WHERE RepairOrder IN ("&ID&") "
		conn.Execute(sql)
		sql = "DELETE Copy_NodesMap WHERE RepairOrder IN ("&ID&") "
		conn.Execute(sql)
		sql = "DELETE Copy_ProcessNodeSet WHERE RepairOrder IN ("&ID&") "
		conn.Execute(sql)
		sql = "DELETE Copy_ProcessSet WHERE RepairOrder IN ("&ID&") "
		conn.Execute(sql)
		sql = "DELETE Copy_CustomFields WHERE RepairOrder IN ("&ID&") "
		conn.Execute(sql)
		sql = "DELETE repair_kulist WHERE RepairOrder IN ("&ID&") "
		conn.Execute(sql)
		sql = "DELETE RepairOrder WHERE ID IN ("&ID&") "
		conn.Execute(sql)
		If Err.Number <> 0 Then
			conn.RollbackTrans
			Response.write "<script>alert('删除失败！');window.history.back();</script>"
			conn.Close
			Set conn = Nothing
			Call db_close : Response.end
		end if
		conn.CommitTrans
		conn.Close
		Response.write("<script>window.location.href='?CurrPage="&CurrPage&"'</script>")
		Response.end()
	ElseIf action = "recover" Then
		conn.CursorLocation = 3
		conn.BeginTrans
		rList = Split(ID,",")
		For j = 0 To UBound(rList)
			If IsRecover(rList(j))       Then
				sql = "UPDATE RepairNewParts SET del = 1 WHERE RepairOrder IN ("&rList(j)&") "
				conn.Execute(sql)
				sql = "UPDATE RepairDealApprove SET del = 1 WHERE RepairOrder IN ("&rList(j)&") "
				conn.Execute(sql)
				sql = "UPDATE RepairTriggerNode SET del = 1 WHERE RepairOrder IN ("&rList(j)&") "
				conn.Execute(sql)
				sql = "UPDATE RepairDeal SET del = 1 WHERE RepairOrder IN ("&rList(j)&") "
				conn.Execute(sql)
				sql = "UPDATE Copy_NodesMap SET del = 1 WHERE RepairOrder IN ("&rList(j)&") "
				conn.Execute(sql)
				sql = "UPDATE Copy_ProcessNodeSet SET del = 1 WHERE RepairOrder IN ("&rList(j)&") "
				conn.Execute(sql)
				sql = "UPDATE Copy_ProcessSet SET del = 1 WHERE RepairOrder IN ("&rList(j)&") "
				conn.Execute(sql)
				sql = "UPDATE Copy_CustomFields SET del = 1 WHERE RepairOrder IN ("&rList(j)&") "
				conn.Execute(sql)
				sql = "UPDATE b SET num2 = num2 + a.NUM FROM RepairOrder a " &_
				"INNER JOIN repair_sl_list b ON b.id = a.repair_sl_list  "&_
				"WHERE a.id IN ("&rList(j)&") "
				conn.Execute(sql)
				sql = "UPDATE a SET a.num3 = b.NUM FROM repair_sl_list a " &_
				"INNER JOIN RepairOrder b ON b.repair_sl_list = a.id " &_
				"WHERE b.id IN ("&rList(j)&") "
				conn.Execute(sql)
				sql = "UPDATE repair_kulist SET del = 1 WHERE RepairOrder IN ("&rList(j)&") "
				conn.Execute(sql)
				sql = "UPDATE RepairOrder SET DelUser = "&LoginUser&", DelTime = '"&Now()&"' WHERE ID IN ("&rList(j)&") "
				conn.Execute(sql)
				sql = "UPDATE RepairOrder SET del = 1 WHERE ID IN ("&rList(j)&") "
				conn.Execute(sql)
				CALL UpdateSlStatus(rList(i))
			end if
		next
		If Err.Number <> 0 Then
			conn.RollbackTrans
			Response.write "<script>alert('恢复失败！');window.history.back();</script>"
			conn.Close
			Set conn = Nothing
			Call db_close : Response.end
		end if
		conn.CommitTrans
		conn.Close
		Response.write("<script>window.location.href='?CurrPage="&CurrPage&"'</script>")
		Response.end()
	ElseIf action = "empty" Then
		conn.CursorLocation = 3
		conn.BeginTrans
		sql = "DELETE RepairNewParts WHERE del = 0 "
		conn.Execute(sql)
		sql = "DELETE RepairDealApprove WHERE del = 0 "
		conn.Execute(sql)
		sql = "DELETE RepairTriggerNode WHERE del = 0 "
		conn.Execute(sql)
		sql = "DELETE RepairDeal WHERE del = 0 "
		conn.Execute(sql)
		sql = "DELETE Copy_NodesMap WHERE del = 0 "
		conn.Execute(sql)
		sql = "DELETE Copy_ProcessNodeSet WHERE del = 0 "
		conn.Execute(sql)
		sql = "DELETE Copy_ProcessSet WHERE del = 0 "
		conn.Execute(sql)
		rList = Split(ID,",")
		For i = 0 To UBound(rList)
			CALL UpdateSlStatus(rList(i))
		next
		sql = "DELETE RepairOrder WHERE del = 0 "
		conn.Execute(sql)
		If Err.Number <> 0 Then
			conn.RollbackTrans
			Response.write "<script>alert('全部清空失败！');window.history.back();</script>"
			conn.Close
			Set conn = Nothing
			Call db_close : Response.end
		end if
		conn.CommitTrans
		conn.Close
		Response.write("<script>window.location.href='?CurrPage="&CurrPage&"'</script>")
		Response.end()
	end if
	Function IsRecover(repID)
		Dim rs,sql
		IsRecover = True
		sql = "SELECT TOP 1 ID FROM RepairOrder WHERE del = 0 AND ID = "&repID&" " &_
		"AND repair_sl_list IN (SELECT repair_sl_list FROM RepairOrder WHERE del = 1) "
		set rs = conn.execute(sql)
		If Not rs.Eof Then
			IsRecover = False
		end if
		rs.close
		set rs = nothing
	end function
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
	'IsRecover = False
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<script language='javascript' src='AutoHiddeFunBtn.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write "' defer='defer'></script>" & vbcrlf & "</head>" & vbcrlf & "<body bgcolor=""#ebebeb"" oncontextmenu=self.event.returnValue=true>" & vbcrlf & "<form name=""form1"" method=""post"" id=""frm"" action=""?"">" & vbcrlf & "  <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "    <tr>" & vbcrlf & "      <td width=""100%"" valign=""top""><table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"">" & vbcrlf & "          <tr>" & vbcrlf & "            <td class=""place"">维修单回收站</td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "            <td align=""right""><input type=""button"" name=""Submitdel"" class=""anybutton"" style=""background:#FFF"" value=""全部清空"" onClick=""if(confirm('确认清空本回收站里的所有内容？')){window.location.href='?action=empty'}""/></td>" & vbcrlf & "            <td width=""3""><img src=""../images/m_mpr.gIf"" width=""3"" height=""32"" /></td>" & vbcrlf &       "    </tr>" & vbcrlf &     "    </table> "& vbcrlf &     "    <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf &    "       <tr class=""top resetGroupTableBg"">" & vbcrlf &     "        <td align=""center"" width=""35""><div align=""center""><strong>选择</strong></div></td>" & vbcrlf & "            <td align=""center"" width=""45""><div align=""center""><strong>序号</strong></div></td>" & vbcrlf & "            <td height=""27""><div align=""center""><strong>维修单主题</strong></div></td>" & vbcrlf & "   <td width=""148""><div align=""center""><strong>状态</strong></div></td>" & vbcrlf & "            <td width=""138"" ><div align=""center""><strong>删除人</strong></div></td>" & vbcrlf & "            <td width=""136"" ><div align=""center""><strong>删除时间</strong></div></td>" & vbcrlf & "          <td width=""178"" ><div align=""center""><strong>操作</strong></div></td>" & vbcrlf & "          </tr>" & vbcrlf & "    "
	Set rs = server.CreateObject("adodb.recordset")
	sql =       "SELECT a.Id,a.Title,(CASE a.Status WHEN 0 THEN '未维修' WHEN 1 THEN '维修中' WHEN 2 THEN '维修完毕' END) Status, " &_
	"b.Name DelUser,a.DelTime " &_
	"FROM RepairOrder a " &_
	"LEFT JOIN gate b ON b.ord = a.DelUser " &_
	"WHERE a.del = 0 ORDER BY a.DelTime DESC"
	rs.open sql,conn,1,1
	If rs.RecordCount <= 0 Then
		Response.write "<table><tr><td height='27'>没有信息!</td></tr></table>"
	else
		i=0
		rs.PageSize=15
		PageCount=clng(rs.PageCount)
		If CurrPage<=0 or CurrPage="" Then
			CurrPage=1
		end if
		If CurrPage>=PageCount Then
			CurrPage=PageCount
		end if
		BookNum=rs.RecordCount
		rs.AbsolutePage = CurrPage
		Do While rs.Eof = False
			Id          = rs("Id")
			Title       = rs("Title")
			Status      = rs("Status")
			DelUser     = rs("DelUser")
			DelTime     = rs("DelTime")
			Response.write "" & vbcrlf & "          <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "            <td align=""center"" height=""27""><input name=""ID"" type=""checkbox"" id=""selectid"" value="""
			Response.write Id
			Response.write """ /></td>" & vbcrlf & "            <td align=""center"">"
			Response.write Rs.recordcount-Rs.pagesize*(currpage-1)-i
			Response.write """ /></td>" & vbcrlf & "            <td align=""center"">"
			Response.write "</td>" & vbcrlf & "            <td class=""name"">" & vbcrlf & "            <div align=""left"">&nbsp;" & vbcrlf & "            <a href=""#"" onclick=""javascript:window.open('../Repair/RepairOrderContent.asp?Referer=recycle&ID="
			Response.write Id
			Response.write "','newWXwin','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;"" title=""点击可查看此维修单详情"">" & vbcrlf & "                "
			Response.write Id
			Response.write Title
			Response.write "" & vbcrlf & "            </a>" & vbcrlf & "            </div>" & vbcrlf & "            </td>" & vbcrlf & "            <td class=""name""><div align=""center"">"
			Response.write Status
			Response.write "</div></td>" & vbcrlf & "            <td class=""name""><div align=""center"">"
			Response.write DelUser
			Response.write "</div></td>" & vbcrlf & "            <td class=""name""><div align=""center"">"
			Response.write DelTime
			Response.write "</div></td>" & vbcrlf & "            <td ><div align=""center"">            " & vbcrlf & "                <input type=""button"" name=""Submit3c"" class=""anybutton"" value=""恢复"" onClick=""if(confirm('确认恢复？')){window.location.href='?action=recover&ID="
			Response.write Id
			Response.write "&CurrPage="
			Response.write CurrPage
			Response.write "'}"" "
			If Not IsRecover(Id) Then Response.write("disabled")
			Response.write " />" & vbcrlf & "                <input type=""button"" name=""Submitdel"" class=""anybutton"" value=""彻底删除"" onClick=""if(confirm('您选择的是彻底删除，删除后不可恢复，确定删除？')){window.location.href='?action=del&ID="
			Response.write Id
			Response.write "&CurrPage="
			Response.write CurrPage
			Response.write "'}""/>" & vbcrlf & "              </div></td>" & vbcrlf & "          </tr>" & vbcrlf & "     "
			i = i + 1
			Response.write "'}""/>" & vbcrlf & "              </div></td>" & vbcrlf & "          </tr>" & vbcrlf & "     "
			If i>= rs.PageSize Then Exit Do
			rs.movenext
		Loop
		Response.write "" & vbcrlf & "        </table></td>" & vbcrlf & "    </tr>" & vbcrlf & "    <tr>" & vbcrlf & "      <td  class=""page""><table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "          <tr>" & vbcrlf & "            <td width=""10%"" height=""30""><div align=""center"">全选" & vbcrlf & "<input type=""checkbox"" name=""checkbox2"" value=""CheckAll"" onClick=""mm()"">" & vbcrlf &       "        </div></td>" & vbcrlf &       "      <td ><input type=""button"" name=""Submit426"" id=""batchDel"" value=""批量删除""   onClick=""return test();""  class=""anybutton2"">" & vbcrlf & "              <input type=""button"" name=""Submit426"" id=""batchRecover"" value=""批量恢复""  onclick=""ask2();"" class=""anybutton2""/></td>" & vbcrlf & "            <td width=""69%""><div align=""right""> "
		Response.write rs.RecordCount
		Response.write "个 | "
		Response.write currpage
		Response.write "/"
		Response.write rs.pagecount
		Response.write "页 | &nbsp;"
		Response.write rs.pagesize
		Response.write "条信息/页&nbsp;&nbsp;" & vbcrlf & "                "
		If currpage=1 Then
			Response.write "" & vbcrlf & "                <input type=""button"" name=""Submit4"" value=""首页""  class=""page""/>" & vbcrlf & "                <input type=""button"" name=""Submit42"" value=""上一页""  class=""page""/>" & vbcrlf & "                "
		else
			Response.write "" & vbcrlf & "                <input type=""button"" name=""Submit4"" value=""首页""   class=""page"" onClick=""gotourl('currPage=1');""/>" & vbcrlf & "                <input type=""button"" name=""Submit42"" value=""上一页""  onClick=""gotourl('currPage="
			Response.write  currpage -1
			Response.write "')"" class=""page""/>" & vbcrlf & "                "
		end if
		If currpage=rs.pagecount Then
			Response.write "" & vbcrlf & "                <input type=""button"" name=""Submit43"" value=""下一页""  class=""page""/>" & vbcrlf & "                <input type=""button"" name=""Submit44"" value=""尾页""  class=""page""/>" & vbcrlf & "                "
		else
			Response.write "" & vbcrlf & "                <input type=""button"" name=""Submit43"" value=""下一页""  onClick=""gotourl('currPage="
			Response.write  currpage +1
			Response.write "')"" class=""page""/>" & vbcrlf & "                <input type=""button"" name=""Submit43"" value=""尾页""  onClick=""gotourl('currPage="
			Response.write rs.PageCount
			Response.write "')"" class=""page""/>" & vbcrlf & "                "
		end if
		Response.write "" & vbcrlf & "              </div></td>" & vbcrlf & "          </tr>" & vbcrlf & "          <tr>" & vbcrlf & "            <td height=""38"" colspan=""3""><div align=""right"">" & vbcrlf & "                <p>&nbsp; </p>" & vbcrlf & "              </div></td>" & vbcrlf & "          </tr>" & vbcrlf & "        </table>" & vbcrlf & "        "
	end if
	rs.close
	set rs=nothing
	dim actinon1
	action1="维修单收站"
	call close_list(1)
	Response.write "</td>" & vbcrlf & "    </tr>" & vbcrlf & "  </table>" & vbcrlf & "</form>" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "function test()" & vbcrlf & "{" & vbcrlf & " var num = $(""input[name=ID]:checked"").size();" & vbcrlf & "     if(num == 0){" & vbcrlf & "           alert('您没有选择任何维修单，请选择后再删除！');" & vbcrlf & "             return false;   " & vbcrlf & "        }" & vbcrlf & "       " & vbcrlf & "        " & vbcrlf & "  if(confirm('您选择的是彻底删除，删除后不能再恢复，确认删除？')) {window.document.getElementById(""frm"").action='?CurrPage="
	Response.write CurrPage
	Response.write "&action=del';" & vbcrlf & "  document.getElementById(""frm"").submit();" & vbcrlf & "  }" & vbcrlf & "}" & vbcrlf & " " & vbcrlf & "function mm()" & vbcrlf & "{" & vbcrlf & "   var a = document.all(""checkbox2"");" & vbcrlf & "   var c = document.getElementsByName(""ID"")" & vbcrlf & " if(a.checked==true)" & vbcrlf & "        {" & vbcrlf & "               for(var i=0;i<c.length;i++)" & vbcrlf & "             c[i].checked=true;" & vbcrlf & "      }" & vbcrlf & "       else" & vbcrlf & "    {" & vbcrlf & "               for(var i=0;i<c.length;i++)" & vbcrlf & "             c[i].checked=false" & vbcrlf & "      }" & vbcrlf & "}" & vbcrlf & "function ask2() { " & vbcrlf & "" & vbcrlf & "  var num = $(""input[name=ID]:checked"").size();" & vbcrlf & "     if(num == 0){" & vbcrlf & "           alert('您没有选择任何维修单，请选择后再恢复！');" & vbcrlf & "                return false;   " & vbcrlf & "        }" & vbcrlf & "       if (confirm(""确认要批量恢复选中的信息？""))" & vbcrlf & "        {" & vbcrlf & "               document.getElementById(""frm"").action = ""?currPage="
	Response.write currPage
	Response.write "&action=recover""; " & vbcrlf & "                document.getElementById(""frm"").submit(); " & vbcrlf & " }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "</script>" & vbcrlf & "" & vbcrlf & "</body>" & vbcrlf & "</html>"
	
%>
