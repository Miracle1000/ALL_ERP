<%@ language=VBScript %>
<%
	response.Buffer=true
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
	
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=41 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_41_7=0
		intro_41_7=0
	else
		open_41_7=rs1("qx_open")
		intro_41_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=41 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_41_10=0
		intro_41_10=0
	else
		open_41_10=rs1("qx_open")
		intro_41_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=1 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_1_11=0
		intro_1_11=0
	else
		open_1_11=rs1("qx_open")
		intro_1_11=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=1 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_1_7=0
		intro_1_7=0
	else
		open_1_7=rs1("qx_open")
		intro_1_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=1 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_1_10=0
		intro_1_10=0
	else
		open_1_10=rs1("qx_open")
		intro_1_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=6 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_6_7=0
		intro_6_7=0
	else
		open_6_7=rs1("qx_open")
		intro_6_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=6 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_6_10=0
		intro_6_10=0
	else
		open_6_10=rs1("qx_open")
		intro_6_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=9 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_9_7=0
		intro_9_7=0
	else
		open_9_7=rs1("qx_open")
		intro_9_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=9 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_9_10=0
		intro_9_10=0
	else
		open_9_10=rs1("qx_open")
		intro_9_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	if open_1_11=3 then
		list_tj=""
	elseif open_1_11=1 then
		list_tj="and cateid in ("&intro_1_11&") and cateid>0"
	else
		list_tj="and 1=0"
	end if
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=1 and sort2=5"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_1_5=0
		intro_1_5=0
	else
		open_1_5=rs1("qx_open")
		intro_1_5=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	dim rs,sql,Str_Result,Str_Result2,catesafe,sorce_user,sorce_user2
	Str_Result="where del=1 "&list_tj&""
	Str_Result2="and del=1 "&list_tj&""
	Str_power=""
	Str_power22=""
	Str_power33=""
	sorce=0
	sorce2=0
	sorce3=0
	if open_1_11="1"  then
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select ord,name,sorce,sorce2 from gate  where ord in ("&intro_1_11&") and del=1 order by sorce asc,sorce2 asc ,cateid asc ,ord asc"
		rs1.open sql1,conn,1,1
		if rs1.eof then
		else
			do until rs1.eof
				sorce=sorce&","&rs1("sorce")
				sorce2=sorce2&","&rs1("sorce2")
				sorce3=sorce3&","&rs1("ord")
				rs1.movenext
			loop
		end if
		rs1.close
		set rs1=nothing
		Str_power="where ord in ("&sorce&")"
		Str_power11="and ord in ("&sorce&")"
		Str_power2="and ord in ("&sorce2&")"
		Str_power22="where ord in ("&sorce2&")"
		Str_power3="and ord in ("&sorce3&")  and del=1"
		Str_power33="where ord in ("&sorce3&") and del=1"
	elseif open_1_11="3" then
		Str_power="where ord>0"
		Str_power11="and ord>0"
		Str_power2="and ord>0"
		Str_power22="where ord>0"
		Str_power3="and ord>0  and del=1"
		Str_power33="where ord>0 and del=1"
	else
		Str_power="where ord<0"
		Str_power2="and ord<0 "
		Str_power22="where ord<0"
		Str_power3="and ord<0"
		Str_power33="where ord<0"
	end if
	
	Response.write "" & vbcrlf & "<HTML>" & vbcrlf & "<HEAD>" & vbcrlf & "<TITLE>客户购买价格分析导出</TITLE>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8""><style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body {" & vbcrlf & "       background-color: #FFFFFF;" & vbcrlf & "      margin-left: 0px;" & vbcrlf & "       margin-top: 0px;" & vbcrlf & " margin-right: 0px;" & vbcrlf & "      margin-bottom: 0px;" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & "</style></HEAD>" & vbcrlf & "<body>" & vbcrlf & " <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "          <tr>" & vbcrlf & "            <td class=""place"">客户购买价格分析导出</td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "            <td align=""right"">&nbsp;</td>" & vbcrlf & "            <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "          </tr>" & vbcrlf & "</table>" & vbcrlf & " <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "<tr class=""top"">" & vbcrlf & "  <td colspan=2 class=tablebody1>&nbsp;</td>" & vbcrlf & "</tr>" & vbcrlf & "<tr>" & vbcrlf & "  <td colspan=2 class=tablebody1>" & vbcrlf & "<span id=""CountTXTok"" name=""CountTXTok"" style=""font-size:10pt; color:#008040"">" & vbcrlf & "<B>正在导出客户购买价格分析,请稍后...</B></span>" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""1"">" & vbcrlf & "<tr>" & vbcrlf & "<td bgcolor=000000>" & vbcrlf& "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"">" & vbcrlf & "<tr>" & vbcrlf & "<td bgcolor=ffffff height=9><img src=""../images/tiao.jpg"" width=""0"" height=""16"" id=""CountImage"" name=""CountImage"" align=""absmiddle""></td></tr></table>" & vbcrlf & "</td></tr></table> <span id=""CountTXT"" name=""CountTXT"" style=""font-size:9pt; color:#008040"">0</span><span style=""font-size:9pt; color:#008040"">%</span></td></tr>" & vbcrlf & "<tr class=""top"">" & vbcrlf & "  <td colspan=2 class=tablebody1 height=""40"">" & vbcrlf & "  </td>" & vbcrlf & "</tr>" & vbcrlf & "</table>" & vbcrlf & ""
	Response.Charset = "UTF-8"
'/table>" & vbcrlf & ""
	server.scripttimeout = 9999999
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=1 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_1_10=0
		intro_1_10=0
	else
		open_1_10=rs1("qx_open")
		intro_1_10=rs1("qx_intro")
	end if
	Str_Result=Replace(Str_Result,"cateid","t.cateid")
	if open_1_10=3 then
		Str_Result=Str_Result
	elseif open_1_10=1 then
		Str_Result=Str_Result+" and t.cateid in("&intro_1_10&") and t.cateid<>0 "
'elseif open_1_10=1 then
	else
		Str_Result=Str_Result+" and 1=0 "
'elseif open_1_10=1 then
	end if
	function selects(khqy,cn,tb)
		if khqy&""<>"" then
			dim kharea
			kharea = ""
			khqy = replace(khqy," ","")
			set rsf = cn.execute("select khqy=dbo.GetMenuArea('"& khqy &"','"& tb &"')")
			if not rsf.eof then
				kharea = rsf(0)
			end if
			rsf.close
			set rsf = nothing
			selects = kharea
		end if
	end function
	if request.Form("hiddendate")="" then
		tdate=date()
		if request("jtdate")<>"" then
			tdate=request("jtdate")
		end if
	else
		if request.Form("hiddenflag")="1" then
			tdate=DateAdd("m",-1,cdate(request.Form("hiddendate")))
'if request.Form("hiddenflag")="1" then
		elseif request.Form("hiddenflag")="2" then
			tdate=DateAdd("m",1,cdate(request.Form("hiddendate")))
		elseif request.Form("hiddenflag")="3" then
			tdate=date()
			if request("jtdate")<>"" then
				tdate=request("jtdate")
			end if
		end if
	end if
	tdmonth=month(tdate)
	tdyear=year(tdate)
	tdyear2=year(tdate)-1
	tdyear=year(tdate)
	B=request("B")
	C=request("C")
	Str_Result=Str_Result+" and t.sort3=1  "&list&""
	C=request("C")
	if B = "mc" then
		if Str_Result="" then
			str_Result="where  t.name t.like '%"& C &"%'"
		else
			Str_Result=Str_Result+"and  t.name like '%"& C &"%'"
			str_Result="where  t.name t.like '%"& C &"%'"
		end if
	elseif B = "dh" then
		if Str_Result="" then
			str_Result="where  t.phone like '%"& C &"%'"
		else
			Str_Result=Str_Result+"and  t.phone like '%"& C &"%'"
			str_Result="where  t.phone like '%"& C &"%'"
		end if
	elseif B = "cz" then
		if Str_Result="" then
			str_Result="where  t.fax like '%"& C &"%'"
		else
			Str_Result=Str_Result+"and  t.fax like '%"& C &"%'"
			str_Result="where  t.fax like '%"& C &"%'"
		end if
	elseif B = "yj" then
		if Str_Result="" then
			str_Result="where  t.email like '%"& C &"%'"
		else
			Str_Result=Str_Result+"and  t.email like '%"& C &"%'"
			str_Result="where  t.email like '%"& C &"%'"
		end if
	elseif B = "dz" then
		if Str_Result="" then
			str_Result="where  t.address like '%"& C &"%'"
		else
			Str_Result=Str_Result+"and  t.address like '%"& C &"%'"
			str_Result="where  t.address like '%"& C &"%'"
		end if
	elseif B = "yb" then
		if Str_Result="" then
			str_Result="where  t.zip like '%"& C &"%'"
		else
			Str_Result=Str_Result+"and  t.zip like '%"& C &"%'"
			str_Result="where  t.zip like '%"& C &"%'"
		end if
	elseif B = "yw" then
		if Str_Result="" then
			str_Result="where  t.product like '%"& C &"%'"
		else
			Str_Result=Str_Result+"and  t.product like '%"& C &"%'"
			str_Result="where  t.product like '%"& C &"%'"
		end if
	end if
	khmc=request("khmc")
	If khmc<>"" Then
		Str_Result=Str_Result+" and  t.name like '%"& khmc &"%'"
'If khmc<>"" Then
	end if
	khid=request("khid")
	If khid<>"" Then
		Str_Result=Str_Result+" and  t.khid like '%"& khid &"%'"
'If khid<>"" Then
	end if
	A2=request("A2")
	If A2<>"" Then
		area = selects(A2,conn,"menuarea")
		Str_Result=Str_Result+" and  t.area in ("& area &")"
		area = selects(A2,conn,"menuarea")
	end if
	D=request("D")
	If D<>"" Then
		Str_Result=Str_Result+" and  t.trade in ("& D &")"
'If D<>"" Then
	end if
	E=request("E")
	F=request("F")
	if E<>"" then Str_Result=Str_Result+" and  t.sort in  ("&E&") "
	F=request("F")
	if F<>"" then Str_Result=Str_Result+" and  t.sort1 in  ("&F&") "
	F=request("F")
	khly=request("khly")
	If khly<>"" Then
		Str_Result=Str_Result+" and t.ly in ("& khly &")"
'If khly<>"" Then
	end if
	A1=request("A1")
	If A1<>"" Then
		Str_Result=Str_Result+" and t.jz in ("& A1 &")"
'If A1<>"" Then
	end if
	productsql=""
	cpmc=request("cpmc")
	If cpmc<>"" Then productsql=productsql & " and p.title like '%"& cpmc &"%'"
	cpbh=request("cpbh")
	If cpbh<>"" Then productsql=productsql & " and p.order1 like '%"& cpbh &"%'"
	cpxh=request("cpxh")
	If cpxh<>"" Then productsql=productsql & " and p.type1 like '%"& cpxh &"%'"
	A3=request("A3")
	if A3<>"" then
		proCls=selects(A3,conn,"menu")
		productsql=productsql & " and  p.sort1 in ("& proCls &") and p.sort1<>''"
	end if
	zdy1=request("zdy1")
	If zdy1<>"" Then productsql=productsql & " and  p.zdy1  like '%"& zdy1 &"%'"
	zdy2=request("zdy2")
	If zdy2<>"" Then productsql=productsql & " and  p.zdy2  like '%"& zdy2 &"%'"
	zdy3=request("zdy3")
	If zdy3<>"" Then productsql=productsql & " and  p.zdy3  like '%"& zdy3 &"%'"
	zdy4=request("zdy4")
	If zdy4<>"" Then productsql=productsql & " and  p.zdy4  like '%"& zdy4 &"%'"
	zdy5=request("zdy5")
	If zdy5<>"" Then productsql=productsql & " and  p.zdy5 in ("& zdy5 &")"
	zdy6=request("zdy6")
	If zdy6<>"" Then productsql=productsql & " and  p.zdy6  in ("& zdy6 &")"
	Dim arrShow()
	Dim arrName()
	Set rs=conn.execute("select (case when isnull(name,'')='' then oldname else name end ) as name, (case when show>0 then 1 else 0 end) as show,gate1 from setfields order by order1 asc ")
	While Not rs.eof
		intgate1=rs("gate1")
		redim Preserve arrShow(intgate1)
		redim Preserve arrName(intgate1)
		arrShow(intgate1)=rs("show")
		arrName(intgate1)=rs("name")
		rs.movenext
	wend
	rs.close
	Chtml="<table width='2000' border='0' cellpadding='6' cellspacing='1' id='content'><tr class='top'><td width='100'><div align='center'>"&arrName(1)&"</div></td><td width='100'><div align='center'>产品名称</div></td><td ><div align='center'>产品编号</div></td><td ><div align='center'>产品型号</div></td><td colspan='15' width='800'><div align='center'>价格分析</div></td><td height='26' ><div align='center'>"&arrName(6)&"</div></td><td height='26' ><div align='center'>"&arrName(7)&"</div></td><td height='26' ><div align='center'>"&arrName(8)&"</div></td><td height='26' ><div align='center'>"&arrName(6)&"</div></td><td height='26' ><div align='center'>"&arrName(9)&"</div></td><td height='26' ><div align='center'>"&arrName(4)&"</div></td><td height='26' ><div align='center'>"&arrName(5)&"</div></td></tr><tr><td height='27'>&nbsp;</td><td height='27'>&nbsp;</td><td height='27'>&nbsp;</td><td height='27'>&nbsp;</td><td colspan='6' width='120' align='center'>今年</td><td colspan='6' width='120' align='center'>去年</td><td colspan='3' width='60' align='center'>历史</td><td  align='center'></td><td  align='center'></td><td  align='center'></td><td  align='center'></td><td  align='center'></td><td  align='center'></td><td  align='center'></td></tr><tr><td height='26'>&nbsp;</td><td height='26'>&nbsp;</td><td height='27'>&nbsp;</td><td height='27'>&nbsp;</td><td colspan='3'  align='center'>本月</td><td colspan='3'  align='center'>累计</td><td colspan='3'  align='center'>本月</td><td colspan='3'  align='center'>累计</td><td colspan='3'  align='center'>总计</td><td  align='center'></td><td  align='center'></td><td  align='center'></td><td  align='center'></td><td  align='center'></td><td  align='center'></td><td  align='center'></td></tr><tr onmouseout='this.style.backgroundColor=''' onmouseover='this.style.backgroundColor='efefef''><td width='26' align='center'>&nbsp;</td><td width='26' align='center'>&nbsp;</td><td height='27'>&nbsp;</td><td height='27'>&nbsp;</td><td  align='center'>最高价</td><td  align='center'>最低价</td><td  align='center'>平均价</td><td  align='center'>最高价</td><td  align='center'>最低价</td><td align='center'>平均价</td><td  align='center'>最高价</td><td  align='center'>最低价</td><td  align='center'>平均价</td><td  align='center'>最高价</td><td  align='center'>最低价</td><td  align='center'>平均价</td><td  align='center'>最高价</td><td  align='center'>最低价</td><td  align='center'>平均价</td><td  align='center'></td><td  align='center'></td><td  align='center'></td><td  align='center'></td><td  align='center'></td><td  align='center'></td><td  align='center'></td></tr>"
	Set xApp = server.createobject(ZBRLibDLLNameSN & ".HtmlExcelApplication")
	xApp.init Me, conn
	Set xsheet = xApp.sheets.add("客户购买价格分析")
	response.Flush()
	xsheet.writeHTML Chtml
	Str_Result=replace(Str_Result,"where"," and ")
	set rs=server.CreateObject("adodb.recordset")
	sql7="select ss.company,p.ord,p.title,p.price2,p.order1,p.type1,p.addcate ,isnull(sum(numcg1),0) as numcg1,isnull(sum(numcg1m),0) as numcg1m,isnull(sum(high1),0) as high1,isnull(sum(low1),0) as low1,isnull(sum(ever1),0) as ever1,isnull(sum(numcg2),0) as numcg2,isnull(sum(numcg2m),0) as numcg2m,isnull(sum(high2),0) as high2,isnull(sum(low2),0) as low2,isnull(sum(ever2),0) as ever2,isnull(sum(numcg3),0) as numcg3,isnull(sum(numcg3m),0) as numcg3m,isnull(sum(high3),0) as high3,isnull(sum(low3),0) as low3,isnull(sum(ever3),0) as ever3,isnull(sum(numcg4),0) as numcg4,isnull(sum(numcg4m),0) as numcg4m,isnull(sum(high4),0) as high4,isnull(sum(low4),0) as low4,isnull(sum(ever4),0) as ever4,isnull(sum(numcg5),0) as numcg5,isnull(sum(numcg5m),0) as numcg5m,isnull(sum(high5),0) as high5,isnull(sum(low5),0) as low5,isnull(sum(ever5),0) as ever5 from product p inner join(select ord,company,0 as numcg1,0 as numcg1m,0 as high1,0 as low1,0 as ever1,0 as numcg2,0 as numcg2m,0 as high2,0 as low2,0 as ever2,0 as numcg3,0 as numcg3m,0 as high3,0 as low3,0 as ever3,0 as numcg4,0 as numcg4m,0 as high4,0 as low4,0 as ever4,sum(isnull(c.num1,0)) as numcg5, sum(isnull(c.num1,0)*isnull(c.price1,0)) as numcg5m,max(isnull(c.price1,0)) as high5,min(isnull(c.price1,0)) as low5,(case isnull(sum(isnull(c.num1,0)),0) when 0 then 0 else isnull(sum(isnull(c.num1,0)*isnull(c.price1,0)),0)/isnull(sum(isnull(c.num1,0)),0) end ) as ever5 from  contractlist c Where c.del=1 group by ord,company union all select ord,company,sum(isnull(c1.num1,0)) as numcg1, sum(isnull(c1.num1,0)*isnull(c1.price1,0)) as numcg1m,max(isnull(c1.price1,0)) as high1,min(isnull(c1.price1,0)) as low1,(case isnull(sum(isnull(c1.num1,0)),0) when 0 then 0 else cast(isnull(sum(isnull(c1.num1,0)*isnull(c1.price1,0)),0) as decimal(25,12))/isnull(sum(isnull(c1.num1,0)),0) end ) as ever1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 from  contractlist c1 where c1.del=1 and year(c1.date1)="&tdyear&" and month(c1.date1)="&tdmonth&" group by ord,company union all select ord,company,0,0,0,0,0,sum(isnull(c2.num1,0)) as numcg2, sum(isnull(c2.num1,0)*isnull(c2.price1,0)) as numcg2m,max(isnull(c2.price1,0)) as high2,min(isnull(c2.price1,0)) as low2,(case isnull(sum(isnull(c2.num1,0)),0) when 0 then 0 else isnull(cast(sum(isnull(c2.num1,0)*isnull(c2.price1,0)) as decimal(25,12)),0)/isnull(sum(isnull(c2.num1,0)),0) end ) as ever2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 from  contractlist c2 Where c2.del=1 and year(c2.date1)="&tdyear&"  group by ord,company union all select ord,company,0,0,0,0,0,0,0,0,0,0,sum(isnull(c3.num1,0)) as numcg3, sum(isnull(c3.num1,0)*isnull(c3.price1,0)) as numcg3m,max(isnull(c3.price1,0)) as high3,min(isnull(c3.price1,0)) as low3,(case isnull(sum(isnull(c3.num1,0)),0) when 0 then 0 else isnull(sum(isnull(c3.num1,0)*isnull(c3.price1,0)),0)/isnull(sum(isnull(c3.num1,0)),0) end ) as ever3,0,0,0,0,0,0,0,0,0,0 from  contractlist c3 Where c3.del=1 and year(c3.date1)="&tdyear2&" and month(c3.date1)="&tdmonth&" group by ord,company union all select ord,company,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sum(isnull(c4.num1,0)) as numcg4, sum(isnull(c4.num1,0)*isnull(c4.price1,0)) as numcg4m,max(isnull(c4.price1,0)) as high4,min(isnull(c4.price1,0)) as low4,(case isnull(sum(isnull(c4.num1,0)),0) when 0 then 0 else isnull(sum(isnull(c4.num1,0)*isnull(c4.price1,0)),0)/isnull(sum(isnull(c4.num1,0)),0) end ) as ever4,0,0,0,0,0 from  contractlist c4 where c4.del=1 and year(c4.date1)="&tdyear2&" group by ord,company) ss on ss.ord=p.ord where p.del=1 " & productsql&" group by ss.company,p.ord,p.title,p.price2,p.order1,p.type1,p.addcate "
	sql1="select yy.ord,aa.ord as cpord,aa.title,aa.order1,aa.type1,name,khid,kharea,khtrade,khlyname,khjz,khsort,khsort1,isnull(sum(numcg1),0) as numcg1,isnull(sum(numcg1m),0) as numcg1m,isnull(sum(high1),0) as high1,isnull(sum(low1),0) as low1,isnull(sum(ever1),0) as ever1,isnull(sum(numcg2),0) as numcg2,isnull(sum(numcg2m),0) as numcg2m,isnull(sum(high2),0) as high2,isnull(sum(low2),0) as low2,isnull(sum(ever2),0) as ever2,isnull(sum(numcg3),0) as numcg3,isnull(sum(numcg3m),0) as numcg3m,isnull(sum(high3),0) as high3,isnull(sum(low3),0) as low3,isnull(sum(ever3),0) as ever3,isnull(sum(numcg4),0) as numcg4,isnull(sum(numcg4m),0) as numcg4m,isnull(sum(high4),0) as high4,isnull(sum(low4),0) as low4,isnull(sum(ever4),0) as ever4,isnull(sum(numcg5),0) as numcg5,isnull(sum(numcg5m),0) as numcg5m,isnull(sum(high5),0) as high5,isnull(sum(low5),0) as low5,isnull(sum(ever5),0) as ever5 from (select t.ord,t.name,t.khid, m.menuname as kharea,s1.sort1 as khtrade,s2.sort1 as khlyname,s3.sort1 as khjz,s4.sort1 as khsort,s5.sort2 as khsort1 from tel t left join menuarea m on m.id = t.area left join sortonehy s1 on s1.ord=t.trade and s1.gate2=11 left join sortonehy s2 on s2.ord=t.ly and s2.gate2=13left join sortonehy s3 on s3.ord=t.jz and s3.gate2=14 left join sort4 s4 on s4.ord=t.sort left join sort5 s5 on s5.ord=t.sort1 where isnull((select sum(money1) from contract where company=t.ord),0)>0 and t.del=1 "&Replace(Str_Result,"del","t.del")&") yy inner join (" & sql7& ") aa on aa.company=yy.ord group by yy.ord,name,khid,kharea,khtrade,khlyname,khjz,khsort,khsort1,aa.ord,aa.title,aa.order1,aa.type1 order by yy.ord "
	rs.open sql1,conn,1,1
	C1=rs.RecordCount
	If C1<=0  then
		xsheet.writeHTML "<table><tr><td>没有信息!</td></tr></table>"
	else
		cord=0
		n=0
		do until rs.eof
			dim k,ord
			ord=rs("ord")
			title=rs("name")
			k=rs("name")
			khid=rs("khid")
			kharea=rs("kharea")
			khtrade=rs("khtrade")
			khlyname=rs("khlyname")
			khjz=rs("khjz")
			khsort=rs("khsort")
			khsort1=rs("khsort1")
			ord2=rs("cpord")
			title2=rs("title")
			order1=rs("order1")
			type1=rs("type1")
			k2=rs("title")
			numcg1=rs("numcg1")
			numcg2=rs("numcg2")
			numcg3=rs("numcg3")
			numcg4=rs("numcg4")
			numcg5=rs("numcg5")
			numcg1m=rs("numcg1m")
			numcg2m=rs("numcg2m")
			numcg3m=rs("numcg3m")
			numcg4m=rs("numcg4m")
			numcg5m=rs("numcg5m")
			high1=rs("high1")
			high2=rs("high2")
			high3=rs("high3")
			high4=rs("high4")
			high5=rs("high5")
			low1=rs("low1")
			low2=rs("low2")
			low3=rs("low3")
			low4=rs("low4")
			low5=rs("low5")
			ever1=rs("ever1")
			ever2=rs("ever2")
			ever3=rs("ever3")
			ever4=rs("ever4")
			ever5=rs("ever5")
			if cord<>ord Then
				cord=ord
				m=1
			else
				m=0
			end if
			xsheet.writeHTML "<tr><td align='center'>"
			if m=1 Then xsheet.writeHTML k
			xsheet.writeHTML "</td>"
			xsheet.writeHTML "<td align='center'><div align='left'>"&k2&"<div id='intro"&ord&"_"&ord2&"' style='position:absolute;margin-top:20;'></div></div></td><td align='center'>"&order1&"</td><td align='center'>"&type1&"</td><td align='center'>"&FormatnumberSub(high1,num_dot_xs,-1)&"</td><td align='center'>"&FormatnumberSub(low1,num_dot_xs,-1)&"</span></td><td align='center'><span class='red'>"&FormatnumberSub(ever1,num_dot_xs,-1)&"</td><td align='center'>"&FormatnumberSub(high2,num_dot_xs,-1)&"</td><td align='center'>"&FormatnumberSub(low2,num_dot_xs,-1)&"</td><td align='center'>"&FormatnumberSub(ever2,num_dot_xs,-1)&"</td><td align='center'>"&FormatnumberSub(high3,num_dot_xs,-1)&"</td><td align='center'>"&FormatnumberSub(low3,num_dot_xs,-1)&"</td><td align='center'>"&FormatnumberSub(ever3,num_dot_xs,-1)&"</td><td align='center'>"&FormatnumberSub(high4,num_dot_xs,-1)&"</td><td align='center'>"&FormatnumberSub(low4,num_dot_xs,-1)&"</td><td align='center'>"&FormatnumberSub(ever4,num_dot_xs,-1)&"</td><td align='center'>"&FormatnumberSub(high5,num_dot_xs,-1)&"</td><td align='center'>"&FormatnumberSub(low5,num_dot_xs,-1)&"</td><td align='center'>"&FormatnumberSub(ever5,num_dot_xs,-1)&"</td>"
			if m=1 then
				xsheet.writeHTML "<td align='center'>"&khid&"</td><td align='center'>"&kharea&"</td><td align='center'>"&khtrade&"</td><td align='center'>"&khlyname&"</td><td align='center'>"&khjz&"</td><td align='center'>"&khsort&"</td><td align='center'>"&khsort1&"</td>"
			else
				xsheet.writeHTML "<td align='center'></td><td align='center'></td><td align='center'></td><td align='center'></td><td align='center'></td><td align='center'></td><td align='center'></td>"
			end if
			xsheet.writeHTML "</tr>"
			currProcV = Clng(n/C1*100)
			If PreProcV < currProcV Then
				Response.write "<script>exportProcBar.showExcelProgress(" & currProcV & "," & C1 & "," & n & ")</script>"
				PreProcV = currProcV
			end if
			Response.Flush
			n=n+1
			Response.Flush
			rowIndex=rowIndex+1
			Response.Flush
			If rowIndex > 40000 Then
				xsheet.writeHTML  "<tr colspan='4'><td ><div align='right'>合计：</div></td><td  align='center' class='red'>"&Formatnumber(sumcg1,num1_dot,-1)&"</td><td  align='center'>"&Formatnumber(sumcg1m,num_dot_xs,-1)&"</td><td  align='center' class='red'>"&Formatnumber(sumcg2,num1_dot,-1)&"</td><td  align='center'>"&Formatnumber(sumcg2m,num_dot_xs,-1)&"</td><td  align='center' class='red'>"&Formatnumber(sumcg3,num1_dot,-1)&"</td><td  align='center'>"&Formatnumber(sumcg3m,num_dot_xs,-1)&"</td><td  align='center' class='red'>"&Formatnumber(sumcg4,num1_dot,-1)&"</td><td  align='center'>"&Formatnumber(sumcg4m,num_dot_xs,-1)&"</td><td  align='center' class='red'>"&Formatnumber(sumcg5,num1_dot,-1)&"</td><td  align='center'>"&Formatnumber(sumcg5m,num_dot_xs,-1)&"</td><td  colspan='7' ></td></tr>"
'If rowIndex > 40000 Then
				sumcg1=0
				sumcg2=0
				sumcg3=0
				sumcg4=0
				sumcg5=0
				sumcg1m=0
				sumcg2m=0
				sumcg3m=0
				sumcg4m=0
				sumcg5m=0
				xsheet.writeHTML "</table>"
				If pageCount = 1 then
					xsheet.title = "客户购买价格分析(" & pageCount & "页)"
				end if
				pageCount = pageCount + 1
				xsheet.title = "客户购买价格分析(" & pageCount & "页)"
				Set xsheet = xApp.sheets.add("客户购买价格分析(" & pageCount & "页)")
				rowIndex = 0
				xsheet.writeHTML Chtml
			end if
			rs.movenext
		loop
	end if
	rs.close
	set rs=Nothing
	xsheet.writeHTML "</table>"
	Response.write "<script>CountImage.width=710;CountTXT.innerHTML=""<font color=red><b>客户购买价格分析导出全部完成!</b></font>  100"";CountTXTok.innerHTML=""<B>恭喜!客户购买价格分析导出成功,共有"&(n)&"条记录!</B>"";</script>"
	tfile=Server.MapPath("客户购买价格分析_"&session("name2006chen")&".xls")
	xApp.save tfile
	xApp.dispose
	tfile = xApp.HexEncode(tfile)
	Response.write "<script>exportProcBar.showExcelProgress(100," & C1 & "," & C1 & ")</script>"
	Response.write "<script>exportProcBar.addFileLink({fileUrl:'" & tfile & "',fileName:'客户购买价格分析_"&session("name2006chen")&".xls',fileCnt:1})</script>"
	Set xApp = Nothing
	action1="客户购买价格分析"
	call close_list(1)
	Response.write "" & vbcrlf & "<p align=""center""><a href=""downfile.asp?fileSpec="
	Response.write tfile
	Response.write """><font class=""red""><strong><u>下载导出的客户购买价格分析</u></strong></font></a></p>" & vbcrlf & "</BODY>" & vbcrlf & "</HTML>" & vbcrlf & ""
	
%>
