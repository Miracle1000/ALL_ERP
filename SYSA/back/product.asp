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
	Function IsBillRecovery(BillType,BillID)
		Dim rs ,sql, r
		r = False
		If Len(BillID&"") = 0 Then BillID = 0
		Select Case BillType:
		Case 1:
		sql ="select top 1 1 from payout a inner join caigou b on a.contract = b.ord and b.del=1 where a.ord in ("& BillID &") and isnull(a.cls,0)=0 and isnull(a.company,0)>0 and isnull(a.company,0)<>isnull(b.company,0) "
		Case 2:
		sql ="select top 1 1 from payoutInvoice a inner join caigou b on a.fromId = b.ord and b.del=1 where a.fromType='CAIGOU' and a.id in ("& BillID &") and ISNULL(a.company,0)<>ISNULL(b.company,0) "
		Case 3:
		sql ="select top 1 1 from kuin a inner join caigou b on a.caigou = b.ord and b.del = 1 and ISNULL(b.company,0)>0 where ISNULL(a.company,0)<>b.company and a.sort1 = 1 and a.ord in ("& BillID &") "
		Case 4 :
		sql ="select top 1 1 from caigouth a inner join caigou b on a.caigou = b.ord and b.del = 1 and ISNULL(b.company,0)>0 where ISNULL(a.company,0)<>b.company and a.ord in ("& BillID &") "
		Case 5 :
		sql ="select top 1 1 from caigouQC a inner join caigou b on a.caigou = b.ord and b.del = 1 and ISNULL(a.company,0)>0 and ISNULL(b.company,0)>0 where a.company<>b.company and a.id in ("& BillID &") "
		Case 6 :
		sql ="select top 1 1 from caigouth a inner join caigou b on a.caigou = b.ord and b.del = 1 and ISNULL(b.bz,14)>0 where ISNULL(a.bz,14)<>b.bz and a.ord in ("& BillID &") "
		End Select
		if sql&""<>"" then
			set rs = conn.execute(sql)
			If rs.eof=False Then
				r = true
			end if
			rs.close
			set rs = nothing
		end if
		IsBillRecovery  = r
	end function
	Function ProductCanRecover(rs)
		dim jz_kh ,arrjz_kh,canRecover
		set rsc=server.CreateObject("adodb.recordset")
		sql="select ts,jz,bt from celue  where  sort1=21 "
		rsc.open sql,conn,1,1
		if rsc.eof then
			jz_kh=""
		else
			jz_kh=rsc("jz")
		end if
		rsc.close
		set rsc=nothing
		canRecover=true
		arrjz_kh=split(replace(jz_kh," ",""),",")
		for i=0 to ubound(arrjz_kh)
			sql="":msg="":tmp=""
			select case arrjz_kh(i)
			case "1"
			tmp="title"
			case "2"
			tmp="order1"
			case "3"
			tmp="type1"
			case else
			if eval(arrjz_kh(i))<>"" then
				sql="select title,name from zdy where sort1=21 and set_open = 1 and name='" & arrjz_kh(i) & "'"
				set rsname=conn.execute(sql)
				if not rsname.eof then
					tmp=arrjz_kh(i)
				else
					tmp=""
				end if
			end if
			end select
			if tmp<>"" then
				set rsn=server.CreateObject("adodb.recordset")
				sql="select count(*) from product where "&tmp&"='"&Replace(rs(tmp)&"","'","''")&"' and del=1 "
				set rsnum=conn.execute(sql)
				if not rsnum.eof then
					if rsnum(0)>0 then
						canRecover=false
					end if
				end if
			end if
		next
		ProductCanRecover=canRecover
	end function
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style>" & vbcrlf & "div#kh{height:auto!important;line-height:40px}" & vbcrlf & "</style>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"">" & vbcrlf & "var xmlHttp = GetIE10SafeXmlHttp();" & vbcrlf & "function callServer2() {" & vbcrlf & "  var url = ""pro_liebiao_tj.asp?timestamp="" + new Date().getTime() + ""&date1=""+ Math.round(Math.random()*100);" & vbcrlf & "  xmlHttp.open(""GET"", url, false);" & vbcrlf & "  xmlHttp.onreadystatechange = function(){" & vbcrlf & "  updatePage2();" & vbcrlf & "  };" & vbcrlf & "  xmlHttp.send(null);" & vbcrlf & "}" & vbcrlf & "function updatePage2() {" & vbcrlf & "var test7=""ht1""" & vbcrlf & "  if (xmlHttp.readyState < 4) {" & vbcrlf & "        ht1.innerHTML=""loading..."";" & vbcrlf & "  }" & vbcrlf & "  if (xmlHttp.readyState == 4) {" & vbcrlf & "    var response = xmlHttp.responseText;" & vbcrlf & "        ht1.innerHTML=response.replace('&quot;','\'');" & vbcrlf & "  xmlHttp.abort();" & vbcrlf & "  }" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "</head>" & vbcrlf & "<body oncontextmenu=self.event.returnValue=false >" & vbcrlf & ""
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
	searchtype = request("searchtype")
	Str_Result = ""
	if searchtype&""="" then
		sType=request("sType")
		keywords=request("keywords")
		m1=request("ret")
		m2=request("ret2")
		If sType <> "" Then
			If sType = "1" Then
				Str_Result = Str_Result & " and title like '%" & keywords & "%'"
			ElseIf sType = "2" Then
				Str_Result = Str_Result & " and order1 like '%" & keywords & "%'"
			ElseIf sType = "3" Then
				Str_Result = Str_Result & " and type1 like '%" & keywords & "%'"
			ElseIf sType = "4" Then
				Str_Result = Str_Result & " and delcate in (select ord from gate where name like '%" & keywords & "%')"
			end if
		end if
		if m1<>"" then Str_Result = Str_Result & " and deldate>='"&m1&"' "
		if m2<>"" then Str_Result = Str_Result & " and deldate<='"&m2&"' "
	else
		A2=request("A2")
		F1=request("F1")
		F2=request("F2")
		P1=request("P1")
		P2=request("P2")
		G1=request("G1")
		G2=request("G2")
		D2=request("D2")
		m1=request("ret3")
		m2=request("ret4")
		if m1<>"" then Str_Result = Str_Result & " and deldate>='"&m1&"' "
		if m2<>"" then Str_Result = Str_Result & " and deldate<='"&m2&"' "
		if D2<>"" then Str_Result = Str_Result & " and delcate in (select ord from gate where name like '%" & D2 & "%')"
		area_list =  - 1
		If A2 <> "" Then
			Function menuarea(id1)
				Set rsarea = server.CreateObject("adodb.recordset")
				sqlarea    = "select id,id1 from menu where id1=" & id1 & " "
				rsarea.open sqlarea,conn,1,1
				If rsarea.eof Then
					gateord22  = id1
					If Len(area_list) = 0 Then
						area_list = "" & gateord22 & ""
					ElseIf InStr( area_list, gateord22 ) <= 0 Then
						area_list = area_list & ", " & gateord22 & ""
					end if
				else
					Do until rsarea.eof
						gateord22  = rsarea("id")
						If Len(area_list) = 0 Then
							area_list = "" & gateord22 & ""
						ElseIf InStr( area_list, gateord22 ) <= 0 Then
							area_list = area_list & ", " & gateord22 & ""
						end if
						menuarea(rsarea("id"))
						rsarea.movenext
					Loop
				end if
				rsarea.Close
				Set rsarea = Nothing
			end function
	aryReturn2 = Split(A2,",")
	For i = 0 To UBound(aryReturn2)
		n         = 0
		Set rs    = server.CreateObject("adodb.recordset")
		sql       = "select id from menu where id1=" & aryReturn2(i) & " "
		rs.open sql,conn,1,1
		If rs.eof Then
			n = 0
		else
			do until rs.eof
				If  CheckPurview(A2,Trim(rs("id"))) = True  Then
					n = 1
				end if
				If n = 1 Then Exit Do
				rs.movenext
			Loop
		end if
		rs.close
		set rs = nothing
		If n = 0 Then
			menuarea(aryReturn2(i))
		end if
	next
	end if
	If  A2 <> "" Then
		Str_Result = Str_Result + "and  sort1 in (" & area_list & ") and sort1<>''"
'If  A2 <> "" Then
	end if
	If F2 <> "" Then
		If F1 = 1 Then
			str_Result = str_Result + "and title like '%" & F2 & "%'"
'If F1 = 1 Then
		ElseIf F1 = 2 Then
			str_Result = str_Result + "and title not like '%" & F2 & "%'"
'ElseIf F1 = 2 Then
		ElseIf F1 = 3 Then
			str_Result = str_Result + "and title='" & F2 & "'"
'ElseIf F1 = 3 Then
		ElseIf F1 = 4 Then
			str_Result = str_Result + "and title<>'" & F2 & "'"
'ElseIf F1 = 4 Then
		ElseIf F1 = 5 Then
			str_Result = str_Result + "and title like '" & F2 & "%'"
'ElseIf F1 = 5 Then
		ElseIf F1 = 6 Then
			str_Result = str_Result + "and title like '%" & F2 & "'"
'ElseIf F1 = 6 Then
		end if
	end if
	F2 = Escape(F2)
	If G2 <> "" Then
		If G1 = 1 Then
			str_Result = str_Result + "and order1 like '%" & G2 & "%'"
'If G1 = 1 Then
		ElseIf G1 = 2 Then
			str_Result = str_Result + "and order1 not like '%" & G2 & "%'"
'ElseIf G1 = 2 Then
		ElseIf G1 = 3 Then
			str_Result = str_Result + "and order1='" & G2 & "'"
'ElseIf G1 = 3 Then
		ElseIf G1 = 4 Then
			str_Result = str_Result + "and order1<>'" & G2 & "'"
'ElseIf G1 = 4 Then
		ElseIf G1 = 5 Then
			str_Result = str_Result + "and order1 like '" & G2 & "%'"
'ElseIf G1 = 5 Then
		ElseIf G1 = 6 Then
			str_Result = str_Result + "and order1 like '%" & G2 & "'"
'ElseIf G1 = 6 Then
		end if
	end if
	If P2 <> "" Then
		If P1 = 1 Then
			str_Result = str_Result + "and type1 like '%" & P2 & "%'"
'If P1 = 1 Then
		ElseIf P1 = 2 Then
			str_Result = str_Result + "and type1 not like '%" & P2 & "%'"
'ElseIf P1 = 2 Then
		ElseIf P1 = 3 Then
			str_Result = str_Result + "and type1='" & P2 & "'"
'ElseIf P1 = 3 Then
		ElseIf P1 = 4 Then
			str_Result = str_Result + "and type1<>'" & P2 & "'"
'ElseIf P1 = 4 Then
		ElseIf P1 = 5 Then
			str_Result = str_Result + "and type1 like '" & P2 & "%'"
'ElseIf P1 = 5 Then
		ElseIf P1 = 6 Then
			str_Result = str_Result + "and type1 like '%" & P2 & "'"
'ElseIf P1 = 6 Then
		end if
	end if
	end if
	Response.write "" & vbcrlf & "<script language='javascript' src='AutoHiddeFunBtn.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write "' defer='defer'></script>" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "<tr>" & vbcrlf & "    <td width=""100%"" valign=""top"">" & vbcrlf & "    <form action=""product.asp"" method=""get""　id=""demo"" onsubmit=""return Validator.Validate(this,2)"" name=""date"" style=""margin:0"">" & vbcrlf & "  <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "          <tr>" & vbcrlf & "            <td class=""place"">产品回收站</td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "<td align=""right""> "& vbcrlf &          "   <div id=""kh""> "& vbcrlf &      "        删除日期"
	type_tj_v = request.querystring("type_tj")
	If Len(type_tj_v & "") = 0 Then
		type_tj_v = request.form("type_tj")
		If Len(type_tj_v) > 0 then
			type_tj = type_tj_v
		end if
	end if
	Response.write "&nbsp;自：<INPUT readonly=""true"" name=ret size=9  id=daysOfMonthPos  onmousedown=""datedlg.show()"" value="""
	Response.write m1
	Response.write """>&nbsp;至：<INPUT name=ret2 readonly=""true"" size=9  id=daysOfMonth2Pos onmousedown=""datedlg.show()"" value="""
	Response.write m2
	Response.write """>&nbsp;<input type='hidden' name='type_tj' value='"
	Response.write type_tj_v
	Response.write "'>"
	
	Response.write "" & vbcrlf & "            <select name=""sType"">" & vbcrlf & "              <option value=""1"" "
	if sType="1" then
		Response.write "selected"
	end if
	Response.write ">产品名称</option>" & vbcrlf & "                   <option value=""2"" "
	if sType="2" then
		Response.write "selected"
	end if
	Response.write ">产品编号</option>" & vbcrlf & "                   <option value=""3"" "
	if sType="3" then
		Response.write "selected"
	end if
	Response.write ">产品型号</option>" & vbcrlf & "                <option value=""4"" "
	if sType="4" then
		Response.write "selected"
	end if
	Response.write ">删除人</option>" & vbcrlf & "            </select>" & vbcrlf & "            <input type=""text"" name=""keywords"" value="""
	Response.write keywords
	Response.write """""  size=""15"" >" & vbcrlf & "            <input type=""submit"" name=""btn_search"" value=""检索""  class=""page"" >" & vbcrlf & "            <input type=""button"" name=""Submitdel"" class=""anybutton"" value=""全部清空"" onClick=""if(confirm('确认清空本回收站里的所有内容？')){window.location.href='delcpall.asp?ord=product&url=product.asp'}""/>" & vbcrlf & "            <a href=""javascript:void(0)"" class=""AfterQuickSearch"" onclick=""callServer2();document.getElementById('ht1').style.display='';document.getElementById('kh').style.display='none';return false;""><img src=""../images/icon_title.gif"" width=""18"" height=""7"" border=""0""><u><font class=""advanSearch"">高级检索</font></u></a></div>" & vbcrlf & "            </td>" & vbcrlf & "            <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "          </tr>" & vbcrlf & "      </table>" & vbcrlf &"      <span id=""ht1""></span>" & vbcrlf & "      </form>" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "        <tr class=""top"">" & vbcrlf & "    <td align=""center"" ><div align=""center""><strong>选择</strong></div></td>" & vbcrlf & "   <td height=""26"" align=""center"" ><div align=""center""><strong>编号</strong></div></td>" & vbcrlf & "          <td height=""23""  ><div align=""center""><strong>产品名称</strong></div></td>" & vbcrlf & "          <td width=""17%"" ><div align=""center""><strong>分类</strong></div></td>" & vbcrlf & "<td width=""11%"" ><div align=""center"" ><strong>删除人</strong></div></td>" & vbcrlf &  "  <td > "& vbcrlf &  "    <div align=""center""><strong>删除日期</strong></div></td> "& vbcrlf &     "    <td width=""21%"" ><div align=""center"" ><strong>操作</strong></div></td> "& vbcrlf &    "   </tr>" & vbcrlf & "  "
	dim n,canDelete
	n=0
	set rs=server.CreateObject("adodb.recordset")
	sql="select ord,title,order1,sort1,isnull(delcate,0) as delcateid,* from product where del=2 "&Str_Result&" order by deldate desc"
	rs.open sql,conn,1,1
	if rs.RecordCount<=0 then
		Response.write "<table><tr><td>没有信息!</td></tr></table>"
	else
		rs.PageSize=12
		PageCount=clng(rs.PageCount)
		CurrPage=Request("CurrPage")
		if CurrPage="" or isnull(CurrPage) then CurrPage=0
		CurrPage=cdbl(CurrPage)
		if CurrPage<=0 or CurrPage="" then
			CurrPage=1
		end if
		if CurrPage>=PageCount then
			CurrPage=PageCount
		end if
		BookNum=rs.RecordCount
		rs.absolutePage = CurrPage
		params="ret="& m1 &"&ret2="& m2 &"&sType="&sType&"&keywords="&keywords&"&searchtype="&searchtype&"&A2="&A2&"&F1="&F1&"F2="&F2&"P1="&P1&"P2="&P2&"G1="&G1&"G2="&G2&"&ret3="& m1 &"&ret4="& m2 &"&D2="&D2&"&CurrPage="&CurrPage&" "
		Response.write "" & vbcrlf & "   <form name=""form1"" method=""post"" action=""deletecpall.asp?ord="
		Response.write rs("ord")
		Response.write "&"
		Response.write params
		Response.write "&sort="
		Response.write sort
		Response.write """>" & vbcrlf & "          "
		do until rs.eof
			dim k
			k=rs("title")
			Response.write "" & vbcrlf & "     <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "     <td width=""6%"" align=""center"" class=""red""><input name=""selectid"" type=""checkbox"" id=""selectid"" value="""
			Response.write rs("ord")
			Response.write """></td> " & vbcrlf & "                <td width=""9%"" align=""center"" height=""27"" >"
			Response.write rs("order1")
			Response.write "</td>" & vbcrlf & "      <td width=""22%"" height=""27"" class=""name"">&nbsp;<a href=""javascript:void(0)"" onclick=""javascript:window.open('../product/content.asp?ord="
			Response.write pwurl(rs("ord"))
			Response.write "','newwin','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;"" title=""点击可查看此产品详情"">"
			Response.write pwurl(rs("ord"))
			Response.write""&k&""
			Response.write "</a>           </td>" & vbcrlf & "         <td class=""name""><div align=""center"">"
			Response.write GetFullProSort(rs("sort1"))
			Response.write "</div></td>" & vbcrlf & "          " & vbcrlf & "                "
			set rs7=server.CreateObject("adodb.recordset")
			sql7="select * from gate where ord="&rs("delcateid")&""
			rs7.open sql7,conn,1,1
			dim cateid
			if rs7.eof then
			else
				cateid=rs7("name")
			end if
			rs7.close
			set rs7=Nothing
			canDelete = conn.execute("exec [erp_rela_finance_GetAssistIDs] "& session("personzbintel2007") &", 1,'6', '" & rs("ord") &"','"& Application("__saas__company") &"'").eof
			Response.write "" & vbcrlf & "   " & vbcrlf & "        <td class=""name""><div align=""center"">"
			Response.write cateid
			Response.write "</div></td>" & vbcrlf & "          " & vbcrlf & "        <td width=""14%"" class=""name""><div align=""center"">"
			Response.write rs("deldate")
			Response.write "</div></td> " & vbcrlf & "     <td>                 " & vbcrlf & "                  <div align=""center"">" & vbcrlf & "                    "
			if ProductCanRecover(rs)=true then
				Response.write "<input type=""button"" name=""Submit3c""  class=""anybutton""  value=""恢复""  onClick=""if(confirm('确认恢复？')){window.location.href='setcp.asp?ord="
				Response.write rs("ord")
				Response.write "&"
				Response.write params
				Response.write "'}""/>"
			end if
			if canDelete then
				Response.write "<input   type=""button"" name=""Submitdel"" class=""anybutton"" value=""彻底删除"" onClick=""if(confirm('您选择的是彻底删除，删除后不能再恢复，确认删除？')){window.location.href='deletecp.asp?ord="
				Response.write rs("ord")
				Response.write "&"
				Response.write params
				Response.write "'}""/>"
			end if
			Response.write "" & vbcrlf & "</div>" & vbcrlf & "               </td>" & vbcrlf & "   </tr>" & vbcrlf & "    "
			n=n+1
			Response.write "" & vbcrlf & "</div>" & vbcrlf & "               </td>" & vbcrlf & "   </tr>" & vbcrlf & "    "
			rs.movenext
			if rs.eof or n>=rs.PageSize then exit do
		loop
		Response.write "     " & vbcrlf & "          </table>" & vbcrlf & "  </td>" & vbcrlf & "         </tr>" & vbcrlf & "   <tr>" & vbcrlf & "    <td  class=""page"">" & vbcrlf & "       <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "  <tr>" & vbcrlf & "    <td width=""10%"" height=""30""><div align=""center"">全选" &vbcrlf & "          <input type=""checkbox"" name=""checkbox2"" value=""Check All"" onClick=""mm()"">" & vbcrlf & "    </div></td>" & vbcrlf & "    <td >" & vbcrlf & "     <input type=""submit"" name=""Submit426"" value=""批量删除""   onClick=""return test();""  class=""anybutton2"">" & vbcrlf & "    <input type=""button"" name=""Submit426"" value=""批量恢复""  onclick=""ask2();"" class=""anybutton2""/>" & vbcrlf & "                </td>" & vbcrlf & "    <td width=""69%""><div align=""right"">" & vbcrlf & "    "
		Response.write rs.RecordCount
		Response.write "个 | "
		Response.write currpage
		Response.write "/"
		Response.write rs.pagecount
		Response.write "页 | &nbsp;"
		Response.write rs.pagesize
		Response.write "条信息/页&nbsp;&nbsp;" & vbcrlf & "      "
		if currpage=1 then
			Response.write "" & vbcrlf & "      <input type=""button"" name=""Submit4"" value=""首页""  class=""page""/>" & vbcrlf & "      <input type=""button"" name=""Submit42"" value=""上一页""  class=""page""/>" & vbcrlf & "      "
		else
			Response.write "" & vbcrlf & "      <input type=""button"" name=""Submit4"" value=""首页""   class=""page"" onClick=""gotourl('currPage="
			Response.write  1
			Response.write "')""/>" & vbcrlf & "      <input type=""button"" name=""Submit42"" value=""上一页""  onClick=""gotourl('currPage="
			Response.write  currpage -1
			Response.write "')"" class=""page""/>" & vbcrlf & "      "
		end if
		if currpage=rs.pagecount then
			Response.write "" & vbcrlf & "      <input type=""button"" name=""Submit43"" value=""下一页""  class=""page""/>" & vbcrlf & "      <input type=""button"" name=""Submit44"" value=""尾页""  class=""page""/>" & vbcrlf & "      "
		else
			Response.write "" & vbcrlf & "      <input type=""button"" name=""Submit43"" value=""下一页""  onClick=""gotourl('currPage="
			Response.write  currpage + 1
			Response.write "')"" class=""page""/>" & vbcrlf & "      <input type=""button"" name=""Submit43"" value=""尾页""  onClick=""gotourl('currPage="
			Response.write  rs.PageCount
			Response.write "')"" class=""page""/>" & vbcrlf & "      "
		end if
		Response.write "" & vbcrlf & "          " & vbcrlf & "    </div></td>" & vbcrlf & "  </tr>" & vbcrlf & "  <script language=javascript>" & vbcrlf & "function test()" & vbcrlf & "{" & vbcrlf & "  if(!confirm('确认删除吗？')) return false;" & vbcrlf & "}" & vbcrlf & " " & vbcrlf & "function mm()" & vbcrlf & "{" & vbcrlf & "   var a = document.all(""checkbox2"");" & vbcrlf & "   var c = document.getElementsByName(""selectid"")" & vbcrlf & "   if(a.checked==true)" & vbcrlf & "     {" & vbcrlf & "               for(var i=0;i<c.length;i++)" & vbcrlf & "             c[i].checked=true;" & vbcrlf & "      }" & vbcrlf & "       else" & vbcrlf & "    {" & vbcrlf & "           for(var i=0;i<c.length;i++)" & vbcrlf & "             c[i].checked=false" & vbcrlf & "      }" & vbcrlf & "}" & vbcrlf & "function ask2() { " & vbcrlf & "if (!confirm(""确认要批量恢复选中的信息？"")) {" & vbcrlf & "            window.event.returnValue = false;" & vbcrlf & "        }" & vbcrlf & "else" & vbcrlf & "{" &vbcrlf & "    document.all.form1.action = ""setcpall.asp?"
		Response.write params
		Response.write """;" & vbcrlf & "document.all.form1.submit(); " & vbcrlf & "}" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "  <tr>" & vbcrlf & "    <td height=""38"" colspan=""3""><div align=""right""><p>&nbsp;" & vbcrlf & "      </p>" & vbcrlf & "    </div></td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "</form>            " & vbcrlf & " "
	end if
	rs.close
	set rs=nothing
	dim actinon1
	action1="产品回收站"
	call close_list(1)
	Response.write "  " & vbcrlf & "   </td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	
%>
