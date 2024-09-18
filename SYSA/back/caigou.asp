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
	
	Function cg_initByParent(uid , cgID , fromtype , fromid)
		Dim rs, ids , ord , sumNum1 , ProductAttrBatchId : ids = ""
		ord = fromid
		If InStr(fromid,",")>0 Then ids = fromid : ord = 0
		conn.execute("exec [erp_cg_initByParent] "& uid & ","& cgID &","& fromtype &" , "& ord &" , '"& ids &"' ")
		set rs = conn.execute("select cl.id, cl.ord , cl.unit , cl.num1, isnull(cl.ProductAttrBatchId,0) ProductAttrBatchId,commUnitAttr "&_
		"  from caigoulist cl  "&_
		"  inner join erp_comm_unitInfo a on a.unitid=cl.unit  "&_
		"  inner join erp_comm_UnitGroup b on b.id = a.unitgp and b.stype=1  "&_
		"  where cl.caigou=" & cgID)
		if rs.eof=false then
			while rs.eof=false
				ProductAttrBatchId = rs("ProductAttrBatchId").value
				if ProductAttrBatchId>0 then
					sumNum1 = sdk.getsqlvalue("select isnull((select sum(num1) from caigoulist where caigou=" & cgID & " and ProductAttrBatchId="& ProductAttrBatchId &"),0)", 0)
				else
					sumNum1 = rs("num1").value
				end if
				if rs("commUnitAttr").value &""="" then
					r = loadMoreUnitByNum(2 , rs("ord").value ,rs("Unit").value  , 0 ,sumNum1 ,num1_dot)
				else
					r = LoadMoreUnit(2 ,rs("commUnitAttr").value , 0 , sumNum1, num1_dot)
				end if
				conn.execute("update caigoulist set commUnitAttr='" & replace(r,"'","''") &"' where id = " & rs("id").value)
				rs.movenext
			wend
		end if
		rs.close
	end function
	Function checkBillCanAddCaigou(cn, fromType , ord)
		Dim r : r = False
		Dim sort48 ,sort2016102101 , sort2016102102,sort2021070521
		sort2021070521 = sdk.getSqlValue("select intro from setopen where sort1=2021070521",1)
		If Len(ord&"") = 0 Then ord = 0
		Select Case fromType
		Case "chance" :
		sort2016102101 = sdk.getSqlValue("select intro from setopen where sort1=2016102101",0)
		If sort2016102101 = 1 Then
			sql = " SELECT top 1 1  FROM chancelist a INNER JOIN product p ON p.ord=a.ord and ("&sort2021070521&"=1 or ("& sort2021070521 &"=2 and charindex(',3,',','+p.Roles+',')>0))"&_
			"LEFT JOIN ("&_
			"           select b.chancelist ,isnull(b.fromUnit,b.unit) unit , sum(isnull(b.fromNum,b.num1)) as num1 "&_
			"           from ( "&_
			"                   SELECT mx.caigou,mx.fromid chancelist,mx.fromUnit,mx.fromNum,mx.unit,mx.num1 FROM caigoulist cl WITH(NOLOCK)  "&_
			"                   INNER JOIN caigoulist_mx mx WITH(NOLOCK) ON mx.fromType=1 AND cl.id=mx.caigoulist "&_
			"           ) b  "&_
			"           inner JOIN caigou c ON c.del not in (2,7) AND ISNULL(c.status,-1)<>0 AND c.ord=b.caigou "&_
			"           ) b  "&_
			"           where c.chance ="& ord &" and c.del not in (2,7) "&_
			"           group by b.chancelist ,isnull(b.fromUnit,b.unit) "&_
			"   ) d  ON d.chancelist = a.id AND d.unit = a.unit" &_
			"   WHERE a.chance = "& ord &" and a.num1-ISNULL(d.num1,0)>0 "
') d  ON d.chancelist = a.id AND d.unit = a.unit &_
			r =( cn.execute(sql).eof=False )
		else
			sql = " SELECT top 1 1  FROM chancelist a INNER JOIN product p ON p.ord=a.ord and ("&sort2021070521&"=1 or ("& sort2021070521 &"=2 and charindex(',3,',','+p.Roles+',')>0)) WHERE a.chance = "& ord
			r =( cn.execute(sql).eof=False )
			r =( cn.execute(sql).eof=False )
		end if
		Case "contract" :
		sort48 = sdk.getSqlValue("select intro from setopen where sort1=48",0)
		If sort48 = 1 Then
			sql = " SELECT top 1 1  FROM contractlist a INNER JOIN product p ON p.ord=a.ord and ("&sort2021070521&"=1 or ("& sort2021070521 &"=2 and charindex(',3,',','+p.Roles+',')>0))"&_
			""&_
			"           select b.contractlist ,isnull(b.fromUnit,b.unit) unit , sum(isnull(b.fromNum,b.num1)) as num1 "&_
			"           from ( "&_
			"                   SELECT mx.caigou,mx.fromid contractlist,mx.fromUnit,mx.fromNum,mx.unit,mx.num1 FROM caigoulist cl WITH(NOLOCK)  "&_
			"                   INNER JOIN caigoulist_mx mx WITH(NOLOCK) ON mx.fromType=2 AND cl.id=mx.caigoulist "&_
			"           ) b  "&_
			"           inner JOIN caigou c ON c.del not in (2,7) AND ISNULL(c.status,-1)<>0 AND c.ord=b.caigou "&_
			"           ) b  "&_
			"           where c.contract ="& ord &" and c.del not in (2,7) "&_
			"           group by b.contractlist ,isnull(b.fromUnit,b.unit) "&_
			"   ) d  ON d.contractlist = a.id AND d.unit = a.unit" &_
			"   WHERE a.contract = "& ord &" and a.num1-ISNULL(d.num1,0)>0 "
') d  ON d.contractlist = a.id AND d.unit = a.unit &_
			r =( cn.execute(sql).eof=False )
		else
			sql = " SELECT top 1 1  FROM contractlist a INNER JOIN product p ON p.ord=a.ord and ("&sort2021070521&"=1 or ("& sort2021070521 &"=2 and charindex(',3,',','+p.Roles+',')>0)) WHERE a.contract = "& ord
			r =( cn.execute(sql).eof=False )
			r =( cn.execute(sql).eof=False )
		end if
		Case "yugou" :
		sort2016102102 = sdk.getSqlValue("select intro from setopen where sort1=2016102102",0)
		If sort2016102102 = 1 Then
			sql = " SELECT top 1 1  FROM caigoulist_yg a INNER JOIN product p ON p.ord=a.ord and ("&sort2021070521&"=1 or ("& sort2021070521 &"=2 and charindex(',3,',','+p.Roles+',')>0))"&_
			"LEFT JOIN ("&_
			"       select caigoulist_yg,unit,sum(num1) as num1 from ("&_
			"               select b.caigoulist_yg ,(case when b.fromUnit>0 then b.fromUnit else b.unit end) unit , sum((case when b.fromUnit>0 then b.fromNum else b.num1 end)) as num1 "&_
			"               from ( "&_
			"                       SELECT mx.caigou,mx.fromid caigoulist_yg,mx.fromUnit,CAST(dbo.formatNumber(mx.fromNum,"& num1_dot &",1) AS DECIMAL(25,12)) fromNum,mx.unit,CAST(dbo.formatNumber(mx.num1,"& num1_dot &",1) AS DECIMAL(25,12)) num1 "&_
			"               FROM caigoulist cl WITH(NOLOCK)  "&_
			"                       INNER JOIN caigoulist_mx mx WITH(NOLOCK) ON mx.fromType=5 AND cl.id=mx.caigoulist "&_
			"               ) b  "&_
			"           left join caigou on caigou.ord=b.caigou " &_
			"               where isnull(b.caigoulist_yg,0)>0 and caigou.del not in (2,7) and ISNULL(cg.status,-1)<>0 "&_
			"           left join caigou on caigou.ord=b.caigou " &_
			"               group by b.caigoulist_yg,b.fromUnit,b.unit "&_
			"           ) t group by caigoulist_yg,unit "&_
			"   ) d  ON d.caigoulist_yg = a.id AND d.unit = a.unit" &_
			"   WHERE a.caigou = "& ord &" and cast(dbo.formatNumber(cast(dbo.formatNumber(a.num1, "& num1_dot &" ,0) as decimal(25,12))-ISNULL(d.num1,0) , "& num1_dot &" ,0) as decimal(25,12))>0 "
') d  ON d.caigoulist_yg = a.id AND d.unit = a.unit &_
			r =( cn.execute(sql).eof=False)
		else
			sql = " SELECT top 1 1  FROM caigoulist_yg a INNER JOIN product p ON p.ord=a.ord and ("&sort2021070521&"=1 or ("& sort2021070521 &"=2 and charindex(',3,',','+p.Roles+',')>0)) WHERE a.caigou = "& ord
			r =( cn.execute(sql).eof=False)
			r =( cn.execute(sql).eof=False)
		end if
		End Select
		checkBillCanAddCaigou = r
	end function
	Function CanAddCaigou(cn, fromType , ord , bill_cateid)
		Dim r : r = False
		if ZBRuntime.MC(15000) And sdk.power.existsPowerIntro(22,13, bill_cateid) Then
			r = checkBillCanAddCaigou(cn, fromType , ord)
		end if
		CanAddCaigou = r
	end function
	Function checkCaigouCanReback(cn, ord)
		Dim r ,fromType: r = True
		Dim sort48 ,sort2016102101 , sort2016102102
		If Len(ord&"") = 0 Then ord = 0
		If cn.execute("select top 1 1 from caigoulist where caigou="& ord & " and chancelist>0 UNION ALL select top 1 1 from caigoulist cgl inner join caigoulist_mx mx on mx.fromtype=1 and mx.fromid>0 and mx.caigoulist=cgl.id and mx.caigou="& ord & "").eof = False Then
			fromType = "chance"
		ElseIf cn.execute("select top 1 1 from caigoulist where caigou="& ord & " and contractlist>0 UNION ALL select top 1 1 from caigoulist cgl inner join caigoulist_mx mx on mx.fromtype=2 and mx.fromid>0 and mx.caigoulist=cgl.id and mx.caigou="& ord & "").eof = False Then
			fromType = "contract"
		ElseIf cn.execute("select top 1 1 from caigoulist cgl inner join caigoulist_mx mx on mx.fromtype=5 and mx.fromid>0 and mx.caigoulist=cgl.id and mx.caigou="& ord & "").eof = False Then
			fromType = "yugou"
		end if
		Dim rs , numberBit : numberBit = 2
		Set rs = cn.execute("select num1 from setjm3 where ord = 88")
		If rs.eof=False Then
			numberBit = rs("num1").value
		end if
		rs.close
		Select Case fromType
		Case "chance" :
		sort2016102101 = sdk.getSqlValue("select intro from setopen where sort1=2016102101",0)
		If sort2016102101 = 1 Then
			sql = " SELECT 1 FROM chancelist a INNER JOIN product p ON p.ord=a.ord "&_
			"  inner JOIN ("&_
			"          select b.chancelist ,isnull(b.fromUnit,b.unit) unit , sum(isnull(b.fromNum,b.num1)) as num1  "&_
			"          from ( "&_
			"                  SELECT mx.caigou,mx.fromid chancelist,mx.fromUnit,mx.fromNum,mx.unit,mx.num1 FROM caigoulist cl WITH(NOLOCK)  "&_
			"                  INNER JOIN caigoulist_mx mx WITH(NOLOCK) ON mx.fromType=1 AND cl.id=mx.caigoulist and mx.caigou<>"& ord &" "&_
			"          ) b "&_
			"          inner JOIN caigou c ON c.ord=b.caigou AND ISNULL(c.sp,0)>=0 AND c.del not in (2,7) and c.ord<>"& ord &" "&_
			"          where b.chancelist>0 and b.chancelist in (select chancelist from caigoulist where caigou="& ord &") "&_
			"          group by b.chancelist ,isnull(b.fromUnit,b.unit)  "&_
			"  ) d  ON d.chancelist = a.id AND d.unit = a.unit" &_
			"  WHERE exists (select chancelist from ( "&_
			"                  SELECT mx.fromid chancelist FROM caigoulist cl WITH(NOLOCK)  "&_
			"                  INNER JOIN caigoulist_mx mx WITH(NOLOCK) ON mx.fromType=1 AND cl.id=mx.caigoulist and mx.caigou="& ord &" "&_
			"          ) t where chancelist=a.id ) and cast(dbo.formatNumber(ISNULL(d.num1,0)-a.num1,"& numberBit &",0)as decimal(25,12)) >=0 "
			r = cn.execute(sql).eof
		end if
		Case "contract" :
		sort48 = sdk.getSqlValue("select intro from setopen where sort1=48",0)
		If sort48 = 1 Then
			sql = " SELECT 1 FROM contractlist a INNER JOIN product p ON p.ord=a.ord "&_
			"  inner JOIN ("&_
			"          select b.contractlist ,isnull(b.fromUnit,b.unit) unit , sum(isnull(b.fromNum,b.num1)) as num1 "&_
			"          from ( "&_
			"                  SELECT mx.caigou,mx.fromid contractlist,mx.fromUnit,mx.fromNum,mx.unit,mx.num1 FROM caigoulist cl WITH(NOLOCK)  "&_
			"                  INNER JOIN caigoulist_mx mx WITH(NOLOCK) ON mx.fromType=2 AND cl.id=mx.caigoulist and mx.caigou<>"& ord &" "&_
			"          ) b "&_
			"          inner JOIN caigou c ON c.ord=b.caigou AND ISNULL(c.sp,0)>=0 AND c.del not in (2,7) and c.ord<>"& ord &" "&_
			"          where b.contractlist>0 and b.contractlist in (select contractlist from caigoulist where caigou="& ord &") "&_
			"          group by b.contractlist ,isnull(b.fromUnit,b.unit) "&_
			"  ) d  ON d.contractlist = a.id AND d.unit = a.unit" &_
			"  WHERE exists (select contractlist from ( "&_
			"                  SELECT mx.fromid contractlist FROM caigoulist cl WITH(NOLOCK)  "&_
			"                  INNER JOIN caigoulist_mx mx WITH(NOLOCK) ON mx.fromType=2 AND cl.id=mx.caigoulist and mx.caigou="& ord &" "&_
			"          ) t where contractlist=a.id ) and  cast(dbo.formatNumber(ISNULL(d.num1,0)-a.num1,"& numberBit &",0)as decimal(25,12)) >=0 "
			r = cn.execute(sql).eof
		end if
		Case "yugou" :
		sort2016102102 = sdk.getSqlValue("select intro from setopen where sort1=2016102102",0)
		If sort2016102102 = 1 Then
			sql = " SELECT 1  FROM caigoulist_yg a "&_
			"   INNER JOIN product p ON p.ord=a.ord "&_
			"  LEFT JOIN ("&_
			"          select b.caigoulist_yg ,isnull(b.fromUnit,b.unit) unit , sum(isnull(b.fromNum,b.num1)) as num1 "&_
			"          from ( "&_
			"                  SELECT mx.caigou,mx.fromid caigoulist_yg,mx.fromUnit,mx.fromNum,mx.unit,mx.num1 FROM caigoulist cl WITH(NOLOCK)  "&_
			"                  INNER JOIN caigoulist_mx mx WITH(NOLOCK) ON mx.fromType=5 AND cl.id=mx.caigoulist and mx.caigou<>"& ord &" "&_
			"          ) b "&_
			"          inner JOIN caigou c ON c.ord=b.caigou AND ISNULL(c.sp,0)>=0 AND c.del not in (2,7) and c.ord<>"& ord &" "&_
			"          where b.caigoulist_yg>0 "&_
			"          group by b.caigoulist_yg ,isnull(b.fromUnit,b.unit) " &_
			"  ) d  ON d.caigoulist_yg = a.id AND d.unit = a.unit" &_
			"  WHERE exists (select caigoulist_yg from ( "&_
			"                  SELECT mx.fromid caigoulist_yg FROM caigoulist cl WITH(NOLOCK)  "&_
			"                  INNER JOIN caigoulist_mx mx WITH(NOLOCK) ON mx.fromType=5 AND cl.id=mx.caigoulist and mx.caigou="& ord &" "&_
			"          ) t where caigoulist_yg=a.id ) and cast(dbo.formatNumber(ISNULL(d.num1,0)-a.num1,"& numberBit &",0) as decimal(25,12)) >=0 "
			r = cn.execute(sql).eof
		end if
		if r = true then
			r = (cn.execute("select 1 from caigoulist_mx a inner join caigou_yg b on b.id = a.frombillID and b.del=1 where a.fromType=5 and a.caigou="& ord &" ").eof=false)
		end if
		End Select
		if r = true then
			r =  cn.execute("select 1 from caigou where ord=" & ord & " and isnull(yhmoney,0)>0").eof
		end if
		checkCaigouCanReback = r
	end function
	Function Update_CaiGou_Status(cn , ord)
		cn.execute("exec [erp_UpdateStatus_Caigou_QC] '"& ord &"',''")
	end function
	Function getInvoiceInfo(cn,ByVal invoiceType,ByVal company,invoiceTitle,invoiceTaxno,invoiceAddr,invoicePhone,invoiceBank,invoiceAccount)
		Dim rs :Set rs = cn.execute("select name from tel where ord ="&company)
		If rs.eof=False Then
			invoiceTitle = Replace(rs(0).value&"","'","''")
		end if
		rs.close
		Set rs = cn.execute("select top 1 title,taxno,addr,phone,bank,account from payoutinvoice where company="& company &" and InvoiceType="&invoiceType &" and isnull(title,'')='"& invoiceTitle &"' order by id desc")
		If rs.eof=False Then
			invoiceTitle = Replace(rs(0).value&"","'","''")
			invoiceTaxno =Replace( rs(1).value&"","'","''")
			invoiceAddr = Replace(rs(2).value&"","'","''")
			invoicePhone = Replace(rs(3).value&"","'","''")
			invoiceBank = Replace(rs(4).value&"","'","''")
			invoiceAccount = Replace(rs(5).value&"","'","''")
		end if
		rs.close
	end function
	Function showFyFt()
		showFyFt = (ZBRuntime.MC(27000) And ZBRuntime.MC(15000) And ZBRuntime.MC(17002))
	end function
	Function getFtKcHsed(ftord)
		dim ret, rs
		ret = False
		set rs = conn.execute("select top 1 x.id from caigou_CostSharing_RKList x "&_
		"    inner join kuinlist y on x.kuinlist = y.id "&_
		"    left join kuin k on y.kuin = k.ord "&_
		"where x.csid = "& ftord &" and exists(select 1 from inventoryCost WHERE  datediff(mm, k.date5, date1) = 0) and complete1 >= 1")
		if rs.eof = False then
			ret = True
		end if
		rs.close
		set rs = nothing
		getFtKcHsed = ret
	end function
	Function delteCgPayCostFt(ftord)
		dim ret, rs, kuinlist, basePrice, price2, UserID, uip
		ret = 0
		if ftord&"" = "" or isnumeric(ftord&"")=False then ftord = 0
		conn.execute("update caigou_CostSharing set del = 2 where id = "& ftord)
		conn.execute("update caigou_CostSharing_FYList set del = 2 where csid = "& ftord)
		conn.execute("update caigou_CostSharing_RKList set del = 2 where csid = "& ftord)
		Set rs = conn.execute("select DISTINCT y.kuinlist,basePrice,'127.0.0.1' as uip, "&_
		"            isnull(l.priceAfterDiscountTax,0) price2 "&_
		"        from caigou_CostSharing x "&_
		"        inner join caigou_CostSharing_RKList y on x.id = y.csid "&_
		"        inner join kuinlist k on k.id = y.kuinlist "&_
		"        inner join caigoulist l on l.id=k.caigoulist "&_
		"        left join invoiceConfig c on c.typeid=l.invoiceType "&_
		"        where y.csid ="& ftord)
		While rs.eof = false
			kuinlist = rs("kuinlist") : basePrice = rs("basePrice") : price2 = rs("price2")
			UserID = session("personzbintel2007") : uip = rs("uip")
			If kuinlist&"" = "" Then kuinlist = 0
			If basePrice&"" = "" Then basePrice = 0 Else basePrice = cdbl(basePrice)
			If price2&"" = "" Then price2 = 0 Else price2 = cdbl(price2)
			If UserID&"" = "" Then UserID = 0
			conn.execute("exec erp_changeStoreCostByKuinlist "& kuinlist &","& basePrice &","& price2 &","& UserID &",'"& uip &"'")
			rs.movenext
		wend
		rs.close
		set rs = nothing
		ret = 1
		delteCgPayCostFt = ret
	end function
	Function glFyFtNum(fromtype, fromid)
		dim ret, sql, rs
		ret = 0 : sql = ""
		if fromid&"" = "" then fromid = 0
		select case fromtype&""
		case "pay"
		sql = "select count(id) from caigou_CostSharing where id in (select csid from caigou_CostSharing_FYList a inner join pay p on a.payid=p.ord and p.complete=3 and p.fid in("& fromid &")) and del=1"
		case "kuin"
		sql = "select count(id) from caigou_CostSharing where id in (select csid from caigou_CostSharing_RKList a inner join kuinlist kl on a.kuinlist=kl.id and kl.kuin in("& fromid &")) and del=1"
		end select
		set rs = conn.execute(sql)
		if rs.eof = false then
			ret = rs(0)
		end if
		rs.close
		set rs = nothing
		glFyFtNum = ret
	end function
	Function glFyFtOrds(fromtype, fromid)
		dim ret, sql, rs
		ret = "" : sql = ""
		if fromid&"" = "" then fromid = 0
		select case fromtype&""
		case "pay"
		sql = "select p.fid from caigou_CostSharing a inner join caigou_CostSharing_FYList b on b.csid=a.id and a.del=1 and b.del=1 inner join pay p on b.payid=p.ord and p.complete=3 and p.fid in("& fromid &")"
		case "kuin"
		sql = "select k.kuin from caigou_CostSharing a inner join caigou_CostSharing_RKList b on b.csid=a.id and a.del=1 and b.del=1 inner join kuinlist k on b.kuinlist=k.id and k.kuin in("& fromid &")"
		end select
		set rs = conn.execute(sql)
		if rs.eof = false then
			if ret&"" <> "" then ret = ret &","
			ret = ret & rs(0)
		end if
		rs.close
		set rs = nothing
		glFyFtOrds = ret
	end function
	Function glFyFtIds(fromtype, fromid)
		dim ret, sql, rs
		ret = "" : sql = ""
		if fromid&"" = "" then fromid = 0
		select case fromtype&""
		case "pay"
		sql = "select p.ord from caigou_CostSharing a inner join caigou_CostSharing_FYList b on b.csid=a.id and a.del=1 and b.del=1 inner join pay p on b.payid=p.ord and p.complete=3 and p.fid in("& fromid &")"
		case "kuin"
		sql = "select k.id from caigou_CostSharing a inner join caigou_CostSharing_RKList b on b.csid=a.id and a.del=1 and b.del=1 inner join kuinlist k on b.kuinlist=k.id and k.kuin in("& fromid &")"
		end select
		set rs = conn.execute(sql)
		if rs.eof = false then
			if ret&"" <> "" then ret = ret &","
			ret = ret & rs(0)
		end if
		rs.close
		set rs = nothing
		glFyFtIds = ret
	end function
	Function CgSubBillCount(cgord, con)
		dim rs, sql, ret
		ret = 0
		sql = "SELECT ISNULL(SUM(t.num1),0) num1 FROM ( "&_
		"          select top 1 1 num1 from payout with(nolock) where contract="& cgord &" and isnull(cls,0)=0 and del=1 "&_
		"          UNION ALL "&_
		"          select top 1 1 num1 from payoutinvoice with(nolock) where fromType='CAIGOU' and fromid="& cgord &" and del=1 "&_
		"          UNION ALL "&_
		"          select top 1 1 num1 from kuin with(nolock) where caigou="& cgord &" and sort1=1 and del=1 "&_
		"          UNION ALL "&_
		"          select top 1 1 num1 from caigouth with(nolock) where caigou="& cgord &" and del=1 "&_
		"          UNION ALL "&_
		"          SELECT TOP 1 1 num1 FROM pay WITH(NOLOCK) WHERE del=1 AND complete in(3,0) AND caigou = "& cgord &" "&_
		"          UNION ALL "&_
		"          select top 1 1 num1 from caigouqc where caigou = "& cgord &" and del=1 "&_
		"  ) t"
		ret = con.execute(sql)(0)
		CgSubBillCount = ret
	end function
	Function GetCaigouRKStatus(ord)
		Dim num1 , num2 ,sql ,rs, zt2
		sql="select isnull(sum(a.num1),0) as num1 ,isnull(sum(a.num2),0) as num2 from caigoulist a inner join product b on a.ord=b.ord and b.canoutstore=1 where a.caigou="& ord &" and (a.del=1 or a.del=3)"
		Set rs = cn.execute(sql)
		If rs.eof= False Then
			num1 = FormatNumber(rs("num1").value, Info.FloatNumber ,-1)
'If rs.eof= False Then
			num2 = FormatNumber(rs("num2").value, Info.FloatNumber ,-1)
'If rs.eof= False Then
			If CDbl(num1)>CDbl(num2) Then
				zt2 = 1
			ElseIf  CDbl(num1)=CDbl(num2) And CDbl(num2)>0 Then
				zt2 = 2
			else
				zt2 = 0
			end if
		end if
		rs.close
		GetCaigouRKStatus = zt2
	end function
	Function statushtml(zt1 , ord)
		Dim s : s = ""
		Dim rs ,zt2 ,sql
		zt2 = GetCaigouRKStatus(ord)
		Select Case zt1
		Case "0" : s = "未编辑明细"
		Case "1" :
		if zt2=2 then s = "申请完毕"
		s = s & "未入库"
		Case "2" :
		if zt2=2 then s = "申请完毕"
		s = s & "部分入库"
		Case "3" : s = "入库完毕"
		Case "4" : s = "超量入库"
		End Select
		statushtml = s
	end function
	Function CgSubBillCount2(cgord, con)
		dim rs, sql, ret
		ret = 0
		sql = "SELECT ISNULL(SUM(t.num1),0) num1 FROM ( "&_
		"          select top 1 1 num1 from payout with(nolock) where contract="& cgord &" and isnull(cls,0)=0 and del=1 "&_
		"          UNION ALL "&_
		"          select top 1 1 num1 from payoutinvoice with(nolock) where fromType='CAIGOU' and fromid="& cgord &" and del=1 "&_
		"          UNION ALL "&_
		"          select top 1 1 num1 from kuin with(nolock) where caigou="& cgord &" and sort1=1 and del=1 "&_
		"          UNION ALL "&_
		"          select top 1 1 num1 from caigouth with(nolock) where caigou="& cgord &" and del=1 "&_
		"          UNION ALL "&_
		"          SELECT TOP 1 1 num1 FROM pay WITH(NOLOCK) WHERE del=1 AND complete in(3,0) AND caigou = "& cgord &" "&_
		"          UNION ALL "&_
		"          select top 1 1 num1 from caigouqc where caigou = "& cgord &" and del=1 "&_
		"  ) t"
		ret = con.execute(sql)(0)
		CgSubBillCount2 = ret
	end function
	Function CGMergeMxIsOpen()
		CGMergeMxIsOpen = (sdk.getSqlValue("select isnull((select intro from setopen  where sort1=2019030101),0)" , 0)&""="1")
	end function
	Function PayOutAutoApprove()
		PayOutAutoApprove = (sdk.getSqlValue("select intro from setopen where sort1=74" , 0)&""="1")
	end function
	Function CgmxUpdateMergeNum(fromtype, caigoulistid, num1, unit, updateMX)
		dim rs, rs2, sql, cpord, num2, num3, mxnum, sumNum, newNum, mxid, mxUnit, fromUnit, fromNum, fromBl, unitBl, tempBl, leftNum, leftFromNum
		dim fromid, rs_mx, len_rsmx, i, preMxNum, mxdel, currCate, sort1, sort3, sort4, sort6
		sumNum = 0 : newNum = 0
		currCate = session("personzbintel2007")
		If currCate&"" = "" Then currCate = 0
		Set rs = conn.execute("select top 1 unit,del from caigoulist_mx where caigoulist="& caigoulistid &" and (del=1 or (del=7 and addcate="& currCate &"))")
		If rs.eof = False Then
			mxUnit = rs("unit") : mxdel = rs("del")
		end if
		rs.close
		set rs = nothing
		If unit&"" = "" Then unit = 0 Else unit = clng(unit)
		If mxUnit&"" = "" Then mxUnit = 0
		If mxdel&"" = "" Then mxdel = 7
		if num1_dot&""="" then
			num1_dot = conn.execute("select isnull((select num1 from setjm3  where ord=88),0)")(0)
		end if
		Set rs = conn.execute("select sum(num1) num2 from caigoulist_mx where caigoulist="& caigoulistid &" and (del=1 or (del=7 and addcate="& currCate &"))")
		If rs.eof = False Then
			num2 = rs("num2")
		end if
		rs.close
		set rs = nothing
		If num2&"" = "" Then num2 = 0 Else num2 = CDBL(FormatNumber(num2,num1_dot,true,0,0))
		If num1&"" = "" Then num1 = 0 Else num1 = CDBL(FormatNumber(num1,num1_dot,true,0,0))
		sort1 = sdk.getSqlValue("select isnull((select intro from setopen where sort1=48),0) ",0)
		sort3 = sdk.getSqlValue("select isnull((select intro from setopen where sort1=2016102101),0) ",0)
		sort4 = sdk.getSqlValue("select isnull((select intro from setopen where sort1=2016102102),0) ",0)
		sort6 = sdk.getSqlValue("select isnull((select intro from setopen where sort1=2016102801),0) ",0)
		If num1 <> num2 or unit <> mxUnit or updateMX Then
			if mxdel = 1 then
				conn.execute("delete from caigoulist_mx where del=10 and addcate="& currCate &" and fromType="& fromType &" and caigoulist="& caigoulistid)
				conn.execute("insert into caigoulist_mx(ord,fromType,fromBillId,fromid,caigou,caigoulist,unit,num1,fromUnit,fromNum,addcate,date7,del ,bl) "&_
				"select ord,fromType,fromBillId,fromid,caigou,caigoulist,unit,num1,fromUnit,fromNum,"& currCate &"addcate,date7,10 del, case when fromNum= 0 then 0 else num1/fromNum end"&_
				" from caigoulist_mx where del=1 and fromType="& fromType &" and caigoulist="& caigoulistid)
			end if
			if unit <> mxUnit then
				call CgmxMergeChangeUnit(caigoulistid, unit)
			end if
			conn.execute("delete from caigoulist_mx where (del=1 or (del=7 and addcate="& currCate &")) and fromType="& fromType &" and caigoulist="& caigoulistid)
			sql = "select a.id, a.ord,a.fromType,a.fromBillId,a.fromid,a.caigou,a.caigoulist,a.unit,a.num1,a.fromUnit,a.fromNum, "&_
			"           round(b.num1,"& num1_dot &")-round(isnull(ymx.fromNum,0),"& num1_dot &") leftNum "&_
			"  from caigoulist_mx a "&_
			"  INNER JOIN ( "&_
			"          select "& fromtype &" fromType, yg.id fromBillId, ygl.id fromid, yg.date7,ygl.num1 from caigou_yg yg "&_
			"          inner join caigoulist_yg ygl on ygl.caigou=yg.id and "& fromtype &"=5 and yg.del=1 "&_
			"          UNION ALL "&_
			"          select "& fromtype &" fromType, xm.ord fromBillId, xl.id fromid, xm.date7,xl.num1 from chance xm "&_
			"          inner join chancelist xl on xl.chance=xm.ord and "& fromtype &"=1 and xm.del=1 "&_
			"          UNION ALL "&_
			"          select "& fromtype &" fromType, ht.ord fromBillId, htl.id fromid, ht.date7,htl.num1 from contract ht "&_
			"          inner join contractlist htl on htl.contract=ht.ord and "& fromtype &"=2 and ht.del=1 "&_
			"          UNION ALL "&_
			"          select "& fromtype &" fromType, xj.id fromBillId, xjl.id fromid, xj.date7,xjl.num1 from xunjia xj "&_
			"          inner join xunjialist xjl on xjl.xunjia=xj.id and "& fromtype &"=3 and xj.del=1 "&_
			"  ) b on a.fromType=b.fromType and a.fromid=b.fromid and a.caigoulist="& caigoulistid &" and (a.del=1 or (a.del=10 and a.addcate="& currCate &"))"&_
			"  left join ( "&_
			"          select a.fromType,a.fromBillId,a.fromid,sum(a.fromNum) fromNum,sum(a.num1) num1 "&_
			"       from caigoulist_mx a "&_
			"          inner join caigou b on a.fromType="& fromType &" and a.del=1 and a.caigou=b.ord and b.del in(1,3) and isnull(b.sp,0)>=0 "&_
			"                  and (("& fromType &"=5 and "& sort4 &"=1) or ("& fromType &"=1 and "& sort3 &"=1) "&_
			"                          or ("& fromType &"=2 and "& sort1 &"=1) or ("& fromType &"=3 and "& sort6 &"=1)) "&_
			"          group by a.fromType,a.fromBillId,a.fromid "&_
			"  ) ymx on ymx.fromtype=a.fromtype and a.fromBillId=ymx.fromBillId and ymx.fromid=a.fromid and ymx.fromid=b.fromid "&_
			"  where round(b.num1,"& num1_dot &")>round(isnull(ymx.fromNum,0),"& num1_dot &") "&_
			"  order by a.id, b.fromid , b.date7  "
			set rs = conn.execute(sql)
			If rs.eof = false Then
				rs_mx = rs.GetRows()
			end if
			rs.close
			set rs = nothing
			if isArray(rs_mx) then
				len_rsmx = ubound(rs_mx,2)
			else
				len_rsmx = -1
				len_rsmx = ubound(rs_mx,2)
			end if
			for i=0 to len_rsmx
				mxid = rs_mx(0,i) : fromid = rs_mx(4,i) : cpord = rs_mx(1,i) : mxnum = rs_mx(8,i) : fromUnit = rs_mx(9,i) : FromNum = rs_mx(10,i) : leftFromNum = rs_mx(11,i)
				If cpord&"" = "" Then cpord = 0
				If fromUnit&"" = "" Then fromUnit = 0
				If mxnum&"" = "" Then mxnum = 0 Else mxnum = CDBL(mxnum)
				If FromNum&"" = "" Then FromNum = 0 Else FromNum = CDBL(FromNum)
				Set rs2 = conn.execute("select (select top 1 bl from jiage where bm=0 and product="& cpord &" and unit="& unit &" order by bl desc) unitBl,(select top 1 bl from jiage where bm=0 and product="& cpord &" and unit="& fromUnit &" order by bl desc) fromBl")
				If rs2.eof = False Then
					unitBl = rs2("unitBl") : fromBl = rs2("fromBl")
				end if
				rs2.close
				Set rs2 = Nothing
				If unitBl&"" = "" Then unitBl = 1 Else unitBl = CDBL(unitBl)
				If fromBl&"" = "" Then fromBl = 1 Else fromBl = CDBL(fromBl)
				if fromBl = 0 then fromBl = 1
				if unitBl = 0 then unitBl = 1
				newNum = CDBL(FormatNumber(mxnum ,num1_dot,true,0,0))
				if newNum> num1 - sumNum then
					newNum = CDBL(FormatNumber(mxnum ,num1_dot,true,0,0))
					newNum = CDBL(FormatNumber(num1 - sumNum,num1_dot,true,0,0))
					newNum = CDBL(FormatNumber(mxnum ,num1_dot,true,0,0))
					fromNum = FormatNumber(newNum * unitBl / fromBl,num1_dot,true,0,0)
					if CDBL(fromNum)> CDBL(leftFromNum) then
						fromNum = leftFromNum
						newNum = CDBL(FormatNumber(cdbl(fromNum) * fromBl / unitBl,num1_dot,true,0,0))
					end if
				else
					fromNum = leftFromNum
					newNum = CDBL(FormatNumber(cdbl(fromNum) * fromBl / unitBl,num1_dot,true,0,0))
				end if
				conn.execute("insert into caigoulist_mx(ord,fromType,fromBillId,fromid,caigou,caigoulist,unit,num1,fromUnit,fromNum,addcate,date7,del,bl) "&_
				"                        "" select ord,fromType,fromBillId,fromid,caigou,caigoulist,unit,""& newNum &"" num1,fromUnit,""& fromNum &"" fromNum,""& currCate &"" addcate,getdate() date7,7 del ,case when ""& fromNum &"" = 0 then 0 else cast(""& newNum &"" as decimal(25,12))/cast(""& fromNum &"" as decimal(25,12)) end"&_
				" from caigoulist_mx where id="& mxid)
				sumNum = sumNum + mxnum
'from caigoulist_mx where id=& mxid)
				if sumNum>=num1 then exit for
			next
		end if
	end function
	Function CgmxMergeChangeUnit(caigoulistid, unit)
		dim rs, rs2, fromBl, unitBl, newBl, fromUnit, fromNum, ynum1, yunit, newNum, num1, cgmxid
		dim cpord
		If unit&"" = "" Then unit = 0 Else unit = clng(unit)
		Set rs = conn.execute("select ord from caigoulist where id="& caigoulistid)
		If rs.eof = False Then
			cpord = rs("ord")
		end if
		rs.close
		set rs = nothing
		Set rs2 = conn.execute("select (select top 1 bl from jiage where bm=0 and product="& cpord &" and unit="& unit &" order by bl desc) newBl")
		If rs2.eof = False Then
			newBl = rs2("newBl")
		end if
		rs2.close
		Set rs2 = Nothing
		If newBl&"" = "" Then newBl = 1 Else newBl = CDBL(newBl)
		if num1_dot&""<>"" then
			num1_dot = conn.execute("select isnull((select num1 from setjm3  where ord=88),0)")(0)
		end if
		Set rs = conn.execute("select id, fromUnit, fromNum, num1, unit from caigoulist_mx where caigoulist="& caigoulistid &" and (del=1 or (del=10 and addcate="& session("personzbintel2007") &"))")
		While rs.eof = False
			cgmxid = rs("id") : fromUnit = rs("fromUnit") : fromNum = rs("fromNum") : num1 = rs("num1")
			If fromNum&"" = "" Then fromNum = 0 Else fromNum = CDBL(fromNum)
			If num1&"" = "" Then num1 = 0 Else num1 = CDBL(num1)
			If fromUnit&"" = "" Then fromUnit = 0 Else fromUnit = clng(fromUnit)
			Set rs2 = conn.execute("select (select top 1 bl from jiage where bm=0 and product="& cpord &" and unit="& fromUnit &" order by bl desc) fromBl")
			If rs2.eof = False Then
				fromBl = rs2("fromBl")
			end if
			rs2.close
			Set rs2 = Nothing
			If fromBl&"" = "" Then fromBl = 1 Else fromBl = CDBL(fromBl)
			newNum = CDBL(FormatNumber(fromNum * fromBl / newBl,num1_dot,true,0,0))
			conn.execute("update caigoulist_mx set num1="& newNum &", unit="& unit &" , bl="& (fromBl/newBl) &" where del=10 and addcate="& session("personzbintel2007") &" and id="& cgmxid)
			rs.movenext
		wend
		rs.close
		set rs = nothing
	end function
	Function GetCgmxMergeNum(cgord, caigoulistid)
		GetCgmxMergeNum = cdbl(sdk.getSqlValue("select isnull((select sum(num1) num1 from caigoulist_mx where caigou="& cgord &" and caigoulist="& caigoulistid &" and (del=1 or del=2 or (del=10 and addcate="& session("personzbintel2007") &"))),0)" , 0))
	end function
	dim RE2016102102: RE2016102102 =-1
	dim RE2016102101: RE2016102101 =-1
	dim RE48: RE48 =-1
	dim RE2016102801: RE2016102801 =-1
	Function GetCgmxRelateNum(fromtype, cgord, caigoulistid, cgmxUnit)
		dim rs, sql, currCate, noReCaigou, CGMergeMxOpen, fromUnit, cpord, fromUnitBl, unitBl, fromNum, num1, mxdel, isMerged
		if RE2016102102=-1 then
			RE2016102102 = sdk.getSqlValue("select isnull((select intro from setopen WITH(NOLOCK) where sort1=2016102102),0) ",0)
			RE2016102101 = sdk.getSqlValue("select isnull((select intro from setopen WITH(NOLOCK) where sort1=2016102101),0) ",0)
			RE48 = sdk.getSqlValue("select isnull((select intro from setopen WITH(NOLOCK) where sort1=48),0) ",0)
			RE2016102801 = sdk.getSqlValue("select isnull((select intro from setopen WITH(NOLOCK) where sort1=2016102801),0) ",0)
		end if
		Select Case fromtype&""
		Case "5" : noReCaigou = RE2016102102
		Case "1" : noReCaigou = RE2016102101
		Case "2" : noReCaigou = RE48
		Case "3" : noReCaigou = RE2016102801
		End Select
		if noReCaigou&"" = "1" then
			currCate = session("personzbintel2007")
			If currCate&"" = "" Then currCate = 0
			If cgmxUnit&"" = "" Then cgmxUnit = 0
			sql=   " SELECT cl.ord, c.fromUnit,(isnull(e.num1,c.currnum1)-ISNULL(c.lsnum1,0)) num1 ,isnull(c.fromNum,0) fromNum                            "&_
			"FROM caigoulist cl                                                                                                               "&_
			" left JOIN (                                                                                                                      "&_
			"        /* 本次数量 ，来源数量    */                                                                                               "&_
			"     SELECT mx.caigoulist,mx.fromUnit, sum(mx.num1) as currnum1 ,sum(a.num1) as lynum1    ,sum(ls.num1) as lsnum1 ,sum(mx.fromNum) as fromNum   "&_
			"     FROM caigoulist_mx mx WITH(NOLOCK)                                                                                           "&_
			"     inner join (                                                                                                                           "&_
			"          select id, ord, num1, unit from chancelist WITH(NOLOCK) where del=1 and "&fromtype&"=1                                                      "&_
			"          union all                                                                                                                     "&_
			"          select id, ord, num1, unit from contractlist WITH(NOLOCK) where del=1 and "&fromtype&"=2                                                "&_
			"          union all                                                                                                                     "&_
			"          select id, ord, num1, unit from xunjialist WITH(NOLOCK) where del=1 and "&fromtype&"=3                                                      "&_
			"          union all                                                                                                                     "&_
			"          select id, ord, num1, unit                                                                                              "&_
			"          from caigoulist_yg WITH(NOLOCK) where del=1 and "& fromtype &"=5                                                                     "&_
			"      ) a on a.id = mx.fromid                                                                                                     "&_
			"     left join (                                                                                                                  "&_
			"         SELECT mx.fromid , sum(mx.num1) as num1                                                                                            "&_
			"         FROM caigoulist_mx mx WITH(NOLOCK)                                                                                       "&_
			"         where mx.fromType="&fromtype&"  and mx.del=1 and mx.caigou<>"&cgord&"                                                                     "&_
			"         group by mx.fromid                                                                                                       "&_
			"     ) ls on ls.fromid = a.id                                                                                                     "&_
			"     where mx.fromType="&fromtype&" and (mx.del=1 or (mx.del=7 and mx.addcate="& currCate &"))                                                                      "&_
			"         and mx.caigou="&cgord&" and mx.caigoulist="&caigoulistid&"                                                                                 "&_
			"     group by mx.caigoulist ,mx.fromUnit                                                                                                      "&_
			" ) c on c.caigoulist=cl.id                                                                                                              "&_
			" left join (                                                                                                                      "&_
			"       /* --初始化数量      */                                                                                          "&_
			"     SELECT mx.caigoulist , sum(mx.num1) as num1                                                                                            "&_
			"     FROM caigoulist_mx mx WITH(NOLOCK)                                                                                           "&_
			"     where mx.fromType="&fromtype&" and mx.del=10 and mx.addcate="& currCate &"                                                                                     "&_
			"         and mx.caigou="&cgord&" and mx.caigoulist="&caigoulistid&"                                                                                 "&_
			"     group by mx.caigoulist                                                                                                       "&_
			" ) e on e.caigoulist=cl.id                                                                                                              "&_
			" where cl.caigou="&cgord&" and cl.id="&caigoulistid&" "
			set rs = conn.execute(sql)
			If rs.eof = False Then
				fromUnit = rs("fromUnit") : cpord = rs("ord") : fromNum = rs("fromNum") : num1 = rs("num1")
				If fromUnit&"" = "" Then fromUnit = 0
				If cpord&"" = "" Then cpord = 0
				If fromNum&"" = "" Then fromNum = 0 Else fromNum = CDBL(fromNum)
				If num1&"" = "" Then num1 = 0 Else num1 = CDBL(num1)
				if fromUnit&"" = cgmxUnit&"" then
					GetCgmxRelateNum = fromNum
				else
					fromUnitBl = sdk.getSqlValue("select isnull(bl,1) from jiage WITH(NOLOCK) where bm=0 and product="& cpord &" and unit="&fromUnit&"",1)
					unitBl = sdk.getSqlValue("select isnull(bl,1) from jiage WITH(NOLOCK) where bm=0 and product="& cpord &" and unit="&cgmxUnit&"",1)
					If fromUnitBl&"" = "" Then fromUnitBl = 1 Else fromUnitBl = cdbl(fromUnitBl)
					If unitBl&"" = "" Then unitBl = 1 Else unitBl = cdbl(unitBl)
					if unitBl = 0 then unitBl = fromUnitBl
					GetCgmxRelateNum = fromNum*fromUnitBl/unitBl
				end if
			else
				GetCgmxRelateNum = 0
			end if
			rs.close
			set rs = nothing
		else
			GetCgmxRelateNum = 0
		end if
	end function
	Function CgmxMergeUpdateOnSave(fromType, cgord)
		dim rs, rs2, sql, num1, num2, num3, fromid, mxid
		sql = "select top 1 a.fromType,a.id,a.num1,b.num1 as num2, c.num1 as num3 from ( "&_
		"          SELECT 5 fromType, id, num1 FROM caigoulist_yg WHERE "& fromType &"=5 and del=1 and exists(SELECT intro from setopen where sort1=2016102102 and intro=1) "&_
		"          union all  "&_
		"          SELECT 1 fromType, id, num1 FROM chancelist WHERE "& fromType &"=1 and del=1 and exists(SELECT intro from setopen where sort1=2016102101 and intro=1) "&_
		"          union all  "&_
		"          SELECT 2 fromType, id, num1 FROM contractlist WHERE "& fromType &"=2 and del=1 and exists(SELECT intro from setopen where sort1=48 and intro=1) "&_
		"          union all  "&_
		"          SELECT 3 fromType, id, num1 FROM xunjialist WHERE "& fromType &"=3 and del=1 and exists(SELECT intro from setopen where sort1=2016102801 and intro=1)"&_
		"  ) a INNER JOIN ( "&_
		"          select mx.fromType, mx.fromid, sum(mx.num1) num1 from caigoulist cgl  "&_
		"          INNER JOIN caigoulist_mx mx ON mx.fromType="& fromType &" and mx.caigoulist=cgl.id  "&_
		"                  AND mx.del=7 and cgl.caigou="& cgord &" "&_
		"          GROUP BY mx.fromType, mx.fromid "&_
		"  ) b on a.fromType=b.fromType and a.id=b.fromid "&_
		"  INNER JOIN ( "&_
		"          select mx.fromType, mx.fromid, sum(mx.num1) num1 from caigoulist cgl  "&_
		"          INNER JOIN caigoulist_mx mx ON mx.fromType="& fromType &" and mx.caigoulist=cgl.id AND mx.del=1 and cgl.caigou<>"& cgord &" "&_
		"          GROUP BY mx.fromType, mx.fromid "&_
		"  ) c on a.fromType=c.fromType and a.id=c.fromid "&_
		"  WHERE a.num1<(isnull(b.num1,0)+isnull(c.num1,0))"
') c on a.fromType=c.fromType and a.id=c.fromid &_
		set rs = conn.execute(sql)
		If rs.eof = False Then
			conn.execute("delete from caigoulist_mx where del=7 and addcate="& session("personzbintel2007") &" and fromType="& fromType &" and caigou="& cgord)
			sql = "insert into caigoulist_mx(ord,fromType,fromBillId,fromid,caigou,caigoulist,unit,num1,fromUnit,fromNum,addcate,date7,del,bl) "&_
			"  select mx.ord,mx.fromType,mx.fromBillId,mx.fromid,mx.caigou,mx.caigoulist,mx.unit,mx.num1, "&_
			"          mx.fromUnit,mx.fromNum,"& session("personzbintel2007") &" addcate, getdate() date7,7 del,case when mx.fromNum= 0 then 0 else mx.num1/mx.fromNum end  "&_
			"  from caigoulist_mx mx  "&_
			"  where mx.del=10 and mx.addcate="& session("personzbintel2007") &" and mx.fromType="& fromType &"  and caigou="&cgord&" "
			conn.execute(sql)
			Set rs2 = conn.execute("select id,num1,unit from caigoulist cgl where caigou="& cgord &" and exists(select ord from caigoulist_mx where del=7 and addcate="& session("personzbintel2007") &" and fromType="& fromType &" and caigou="& cgord &" and caigoulist=cgl.id)")
			While rs2.eof = False
				call CgmxUpdateMergeNum(fromType, rs2("id"),rs2("num1"),rs2("unit"), true)
				rs2.movenext
			wend
			rs2.close
			Set rs2 = Nothing
		end if
		rs.close
		set rs = nothing
	end function
	Function CheckCgmxMerged(cgord, caigoulistid)
		dim ret
		ret = False
		If cgord&"" = "" Then cgord = 0
		If caigoulistid&"" = "" Then caigoulistid = 0
		ret = sdk.getSqlValue("select isnull((select top 1 1 from caigoulist_mx where caigou="& cgord &" and caigoulist="& caigoulistid &" and (del=1 or (del=10 and addcate="& session("personzbintel2007") &"))),0) ",0)
		if ret > 0 then
			CheckCgmxMerged = True
		else
			CheckCgmxMerged = False
		end if
	end function
	
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<script language='javascript' src='AutoHiddeFunBtn.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write "' defer='defer'></script>" & vbcrlf & "</head>" & vbcrlf & "<body oncontextmenu=self.event.returnValue=false>" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "       <tr>" & vbcrlf & "    <td width=""100%"" valign=""top"">" & vbcrlf & "              <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "      <tr>" & vbcrlf & "        <td class=""place"">采购回收站</td>" & vbcrlf & "        <td>&nbsp;</td>" & vbcrlf & "        <td align=""right""><input type=""button"" name=""Submitdel"" class=""anybutton"" value=""全部清空"" onClick=""if(confirm('确认清空本回收站里的所有内容？')){window.location.href='delall.asp?ord=caigou&url=caigou.asp&list1=caigoulist'}""/></td>" & vbcrlf & "        <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "      </tr>" & vbcrlf & "   </table>" & vbcrlf & "            <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "                      <tr class=""top"">" & vbcrlf & "                    <td width=""5%"" align=""center""><div align=""center""><strong>选择</strong></div></td>" & vbcrlf & "                    <td width=""5%"" align=""center"" height=""24""><div align=""center""><strong>序号</strong></div></td>" & vbcrlf & "                          <td width=""25%"" height=""27""><div align=""center""><strong>采购</strong>主题</div></td>" & vbcrlf & "                          <td width=""15%""><div align=""center""><strong>负责人</strong></div></td>" & vbcrlf & "<td width=""15%""><div align=""center""><strong>删除人</strong></div> </td>" & vbcrlf & "                     <td width=""15%""><div align=""center"">删除日期</div></td>" & vbcrlf & "                     <td width=""20%""><div align=""center""><strong>操作</strong></div></td>" & vbcrlf & "              </tr>" & vbcrlf & ""
	dim n
	n=0
	set rs=server.CreateObject("adodb.recordset")
	sql="select * from caigou where del=2 order by deldate desc"
	rs.open sql,conn,1,1
	if rs.RecordCount<=0 then
		Response.write "<table><tr><td>没有信息!</td></tr></table>"
	else
		n=0
		rs.PageSize=15
		PageCount=clng(rs.PageCount)
		CurrPage=cdbl(Request("CurrPage"))
		if CurrPage<=0 or CurrPage="" then
			CurrPage=1
		end if
		if CurrPage>=PageCount then
			CurrPage=PageCount
		end if
		BookNum=rs.RecordCount
		rs.absolutePage = CurrPage
		Response.write "" & vbcrlf & "<form name=""form1"" method=""post"" action=""deletecgall.asp?ord="
		Response.write rs("ord")
		Response.write "&CurrPage="
		Response.write CurrPage
		Response.write "&a="
		Response.write a
		Response.write "&b="
		Response.write b
		Response.write "&c="
		Response.write c
		Response.write """>" & vbcrlf & ""
		do until rs.eof
			dim k,ord,id
			id=rs("ord")
			ord=rs("company")
			k=rs("title")
			Response.write "" & vbcrlf & "      <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "     <td align=""center""><span class=""red""><input name=""selectid"" type=""checkbox"" id=""selectid"" value="""
			Response.write rs("ord")
			Response.write """></span></td>" & vbcrlf & "    <td align=""center"" height=""24"">"
			Response.write Rs.recordcount-Rs.pagesize*(currpage-1)-n
			Response.write """></span></td>" & vbcrlf & "    <td align=""center"" height=""24"">"
			Response.write "</td>" & vbcrlf & "    <td height=""27"" class=""name"" >&nbsp;<a href=""#"" onclick=""javascript:window.open('../../SYSN/view/store/caigou/caigoudetails.ashx?view=details&ord="
			Response.write pwurl(rs("ord"))
			Response.write "','contractcon','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;"" title="""
			Response.write pwurl(rs("ord"))
			Response.write rs("title")
			Response.write """>"
			Response.write""&k&" "
			If request("bufh")<>"" And  InStr(","&request("bufh")&",",","&id&",")>0 Then
				Response.write "<font color='red'> 不允许恢复</font>"
			end if
			Response.write "" & vbcrlf & "      </a></td>" & vbcrlf & ""
			if rs("cateid")<>"" then
				set rs7=server.CreateObject("adodb.recordset")
				sql7="select name from gate where ord="&rs("cateid")&""
				rs7.open sql7,conn,1,1
				dim cateid
				if rs7.eof then
					cateid=""
				else
					cateid=rs7("name")
				end if
				rs7.close
				set rs7=nothing
			end if
			Response.write "" & vbcrlf & "    <td class=""name""><div align=""center""><font class=""name"">"
			Response.write cateid
			Response.write "</font></div></td>" & vbcrlf & ""
			set rs7=server.CreateObject("adodb.recordset")
			sql7="select name from gate where ord="&rs("delcate")&""
			rs7.open sql7,conn,1,1
			dim delcate
			if not rs7.eof then
				delcate=rs7("name")
			else
				delcate=""
			end if
			rs7.close
			set rs7=nothing
			Response.write "" & vbcrlf & "    <td class=""name""><div align=""center"">"
			Response.write delcate
			Response.write "</div></td>" & vbcrlf & "           <td><div align=""center"">"
			Response.write rs("deldate")
			Response.write "</div></td>" & vbcrlf & "    <td><div align=""center"">" & vbcrlf & " "
			Set rssort=conn.execute("select intro from setopen  where sort1=48")
			If rssort.eof Then
				sort48=1
			else
				sort48=rssort("intro")
			end if
			rssort.close
			If sort48=1 Then
				ishuifu=True
			else
				contract=rs("contract")
				If contract&""="" Then contract=0
				Set rsnumdiff=conn.execute("select h.ord,htnum,cgnum from (select ord,sum(isnull(num1,0)) as htnum from contractlist where contract="&contract &" group by ord) h left join (select ord,sum(isnull(num1,0)) as cgnum from caigoulist where caigou in (select ord from caigou where contract="&contract &"and del<>2 and sp>=0 union all select "& id &")  group by ord) c on h.ord=c.ord  where  isnull(cgnum,0)>htnum")
				If rsnumdiff.eof Then
					ishuifu=True
				else
					ishuifu=False
				end if
				rsnumdiff.close
			end if
			If ishuifu=false Then
				isfh= " disabled"
			else
				isfh=""
			end if
			If checkCaigouCanReback(conn, rs("ord")) =false Then
				isfh= " disabled "
			else
				sql1="select TOP 1 1    "&_
				"  from caigou  "&_
				"  inner join caigoulist_mx cl on caigou.ord="& rs("ord") &" and cl.caigou = caigou.ord "&_
				"  left join (           "&_
				"      SELECT cgl.caigou, mx.fromtype , mx.fromid,mx.fromUnit,mx.fromNum,mx.unit,mx.num1 FROM caigoulist cgl WITH(NOLOCK)   "&_
				"      INNER JOIN caigou cg WITH(NOLOCK) ON cgl.caigou=cg.ord  AND  ISNULL(cg.sp,0)>=0                   "&_
				"      INNER JOIN caigoulist_mx mx WITH(NOLOCK) ON  mx.del=1 AND mx.caigoulist=cgl.id         "&_
				"  ) b  on cl.fromType = b.fromType and cl.fromid =b.fromid                    "&_
				"  where isnull(b.fromid,0)>0 "
				Set rsSql1=conn.execute(sql1)
				if rsSql1.eof=false then  isfh= " disabled "
				rsSql1.close
			end if
			Response.write "" & vbcrlf & "     <input type=""button"" name=""Submit3c""  class=""anybutton""  value=""恢复""  "
			Response.write isfh
			Response.write " onClick=""if(confirm('确认恢复？')){window.location.href='setcg.asp?ord="
			Response.write rs("ord")
			Response.write "&CurrPage="
			Response.write CurrPage
			Response.write "'}""/>&nbsp;&nbsp;" & vbcrlf & " <input type=""button"" name=""Submitdel"" class=""anybutton"" value=""彻底删除"" onClick=""if(confirm('您选择的是彻底删除，删除后不能再恢复，确认删除？')){window.location.href='deletecg.asp?ord="
			Response.write rs("ord")
			Response.write "&CurrPage="
			Response.write CurrPage
			Response.write "'}""/></div></td>" & vbcrlf & "  </tr>" & vbcrlf & ""
			n=n+1
			Response.write "'}""/></div></td>" & vbcrlf & "  </tr>" & vbcrlf & ""
			rs.movenext
			if rs.eof or n>=rs.PageSize then exit do
		loop
		m=n
		Response.write "" & vbcrlf & "</table>" & vbcrlf & "</td>" & vbcrlf & "</tr>" & vbcrlf & "<tr>" & vbcrlf & "<td class=""page"">" & vbcrlf & "         <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "  <tr>" & vbcrlf & "    <td width=""10%"" height=""30""><div align=""center"">全选" & vbcrlf & "        <input type=""checkbox"" name=""checkbox2"" value=""Check All"" onClick=""mm()"">" & vbcrlf & "    </div></td>" & vbcrlf & "    <td >" & vbcrlf & " <input type=""submit"" name=""Submit426"" value=""批量删除""   onClick=""return test();""  class=""anybutton2"">" & vbcrlf & "    <input type=""button"" name=""Submit426"" value=""批量恢复""  onclick=""ask2();"" class=""anybutton2""/>" & vbcrlf & "               </td>" & vbcrlf & "    <td width=""69%""><div align=""right"">" & vbcrlf & "    "
		Response.write rs.RecordCount
		Response.write "个 | "
		Response.write currpage
		Response.write "/"
		Response.write rs.pagecount
		Response.write "页 | &nbsp;"
		Response.write rs.pagesize
		Response.write "条信息/页&nbsp;&nbsp;" & vbcrlf & "    "
		if currpage=1 then
			Response.write "" & vbcrlf & "    <input type=""button"" name=""Submit4"" value=""首页""  class=""page""/> <input type=""button"" name=""Submit42"" value=""上一页""  class=""page""/>" & vbcrlf & "    "
		else
			Response.write "" & vbcrlf & "    <input type=""button"" name=""Submit4"" value=""首页""   class=""page"" onClick=""window.location.href='caigou.asp?currPage="
			Response.write  1
			Response.write "&a="
			Response.write a
			Response.write "&b="
			Response.write b
			Response.write "&c="
			Response.write c
			Response.write "'""/> <input type=""button"" name=""Submit42"" value=""上一页""  onClick=""window.location.href='caigou.asp?currPage="
			Response.write  currpage -1
			Response.write "&a="
			Response.write a
			Response.write "&b="
			Response.write b
			Response.write "&c="
			Response.write c
			Response.write "'"" class=""page""/>" & vbcrlf & "    "
		end if
		if currpage=rs.pagecount then
			Response.write "" & vbcrlf & "    <input type=""button"" name=""Submit43"" value=""下一页""  class=""page""/> <input type=""button"" name=""Submit44"" value=""尾页""  class=""page""/>" & vbcrlf & "    "
		else
			Response.write "" & vbcrlf & "   <input type=""button"" name=""Submit43"" value=""下一页""  onClick=""window.location.href='caigou.asp?currPage="
			Response.write  currpage + 1
			Response.write "&a="
			Response.write a
			Response.write "&b="
			Response.write b
			Response.write "&c="
			Response.write c
			Response.write "'"" class=""page""/> <input type=""button"" name=""Submit43"" value=""尾页""  onClick=""window.location.href='caigou.asp?currPage="
			Response.write  rs.PageCount
			Response.write "&a="
			Response.write a
			Response.write "&b="
			Response.write b
			Response.write "&c="
			Response.write c
			Response.write "'"" class=""page""/>" & vbcrlf & "    "
		end if
		Response.write "" & vbcrlf & "    </div></td>" & vbcrlf & "  </tr>" & vbcrlf & "<script type=""text/Javascript"">window.currask2Url=""setcgall.asp?currPage="
		Response.write currPage
		Response.write """;</script>" & vbcrlf & "<script src='../script/bk_comm01.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write "'></script>" & vbcrlf & "  <tr>" & vbcrlf & "    <td height=""38"" colspan=""3""><div align=""right""><p>&nbsp;" & vbcrlf & "      </p>" & vbcrlf & "    </div></td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "</form>" & vbcrlf & ""
	end if
	rs.close
	set rs=nothing
	dim actinon1
	action1="采购回收站"
	call close_list(1)
	Response.write "" & vbcrlf & "     <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "    <tr>" & vbcrlf & "      <td height=""10"" colspan=""2""><img src=""../image/pixel.gif"" width=""1"" height=""1""></td>" & vbcrlf & "    </tr>" & vbcrlf & "          <tr>" & vbcrlf & "      <td width=""16%"" height=""10""><div align=""right""></div></td>" & vbcrlf & "      <td width=""84%"">&nbsp;</td>" & vbcrlf & "          </tr>" & vbcrlf & "     <tr>" & vbcrlf & "      <td height=""10"" colspan=""2"">&nbsp;</td>" & vbcrlf & "         </tr>" & vbcrlf & "     <tr>" & vbcrlf & "      <td height=""10"" colspan=""2"">&nbsp;</td> "& vbcrlf &  "   </tr>" & vbcrlf & "  </table>" & vbcrlf & " </td> "& vbcrlf & "  </tr>" & vbcrlf &" </table> "& vbcrlf &" </body> "& vbcrlf & "</html>"
	
%>
