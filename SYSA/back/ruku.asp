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
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body {" & vbcrlf & "      margin-top: 0px;" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & "</style>" & vbcrlf & "<script language='javascript' src='AutoHiddeFunBtn.js?ver="
	'Response.write Application("sys.info.jsver")
	Response.write Application("sys.info.jsver")
	Response.write "' defer='defer'></script>" & vbcrlf & "</head>" & vbcrlf & "<body class=""ReportUI"">" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "  <tr>" & vbcrlf & "    <td width=""100%"" valign=""top"">" & vbcrlf & "                      <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "       <tr>" & vbcrlf & "              <td class=""place"">入库回收站</td>" & vbcrlf & "         <td>&nbsp;</td>" & vbcrlf & "         <td align=""right""><input type=""button"" name=""Submitdel"" class=""anybutton"" value=""全部清空"" onClick=""if(confirm('确认清空本回收站里的所有内容？')){window.location.href='delall.asp?ord=kuin&url=ruku.asp&list1=kuinlist'}""/></td>" & vbcrlf &          " <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td> "& vbcrlf &         "    </tr> "& vbcrlf &        "      </table> " & vbcrlf &"<table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content""> "& vbcrlf &                      "         <tr class=""top""> "& vbcrlf &                "             <td align=""center"" width=""5%""><div align=""center""><strong>选择</strong></div></td> "& vbcrlf &         "                    <td align=""center"" width=""5%"" height=""24""><div align=""center""><strong>序号</strong></div></td> "& vbcrlf &      "                           <td height=""27"" width=""25%""><div align=""center""><strong>入库主题</strong></div></td>" & vbcrlf &                   "                <td width=""15%""><div align=""center""><strong>负责人</strong></div></td> "& vbcrlf &                   "            <td width=""15%""><div align=""center""><strong>删除人</strong></div></td> "& vbcrlf &              "                  <td width=""15%""><div align=""center""><strong>删除日期</strong></div></td> "& vbcrlf &                             "<td width=""20%""><div align=""center""><strong>操作</strong></div></td> "& vbcrlf &          "             </tr>" & vbcrlf
	dim n,canDelete
	n=0
	set rs=server.CreateObject("adodb.recordset")
	sql="select k.ord,k.title,k.sort1,k.date5,k.complete1,(select stuff((select ','+cast(isnull(caigou,0) as varchar(10)) from kuinlist where kuin=k.ord for xml path('')),1,1,''))caigou,k.deldate,k.cateid,k.delcate,isnull(c.id,0) cid, "&_
	"g.name delname,isnull(a.cnt,0) cnt,isnull(t.id,0)cnt1,g1.name cateidname "&_
	"from kuin k with(nolock) "&_
	"left join collocation c with(nolock) on c.sort1=11  and c.del=1 and c.erpord=k.ord and isnull(c.voucher,0)>0 " &_
	"left join gate g with(nolock) on g.ord=k.delcate "&_
	"left join ( "&_
	"select count(1) cnt,c.kuin id from ku a with(nolock) "&_
	"inner join kuhclist b with(nolock) on a.id=b.kuid and b.del=1 and b.num1>0 "&_
	"inner join kuinlist c with(nolock) on c.id=a.kuinlist  "&_
	"group by c.kuin "&_
	") a on a.id=k.ord "&_
	"left join inventoryCost t with(nolock) on datediff(mm,t.date1,k.date5)=0 and t.complete1 >= 1 " &_
	"left join gate g1 with(nolock) on g1.ord=k.cateid  " &_
	"where k.del=2 order by deldate desc "
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
		Response.write "" & vbcrlf & "    <form name=""form1"" method=""post"" action=""deleterkall.asp?ord="
		Response.write rs("ord")
		Response.write "&CurrPage="
		Response.write CurrPage
		Response.write "&a="
		Response.write a
		Response.write "&b="
		Response.write b
		Response.write "&c="
		Response.write c
		Response.write """>" & vbcrlf & "    "
		do until rs.eof
			dim k,ord,id
			id=rs("ord")
			k=rs("title")
			sort1=rs("sort1")
			date5 = rs("date5")
			hcfix = ""
			isCompleted = rs("complete1") = 3
			if rs("cnt")>0 then
				hcfix1="(有对冲)"
				bCanRestore1=false
			else
				hcfix1=""
				bCanRestore1=true
			end if
			hcfix2=""
			m=0
			bCanRestore2=True
			if rs("cnt")>0 then
				hcfix2=" (单据所在成本核算月已核算)"
				bCanRestore2=false
				m=1
			end if
			If Len(date5&"")>0 Then
				If IsCostAnalysis(conn , 61001, id , sort1 ,date5)  Then
					hcfix2=" (单据所在生产成本已核算)"
					bCanRestore2=false
					m=1
				end if
			end if
			If bCanRestore2 = True Then
				sql88="select top 1 caigoulist from kuinlist with(nolock) where kuin="&id&" and "&sort1&" in (1,2)"
				set rs88=server.CreateObject("adodb.recordset")
				rs88.open sql88,conn,1,1
				if not rs88.eof then
					do while not rs88.eof and m=0
						set rs99=conn.execute("select  top 1 1  from kuinlist with(nolock) where kuin<>"&id&" and kuin in (select ord from kuin with(nolock) where sort1="&sort1&") and caigoulist="&rs88("caigoulist")&" and del=1")
						if not rs99.eof then
							hcfix2=" (有明细已经入库)"
							bCanRestore2=false
							m=1
						else
							hcfix2=""
							bCanRestore2=true
							m=0
						end if
						set rs99=nothing
						rs88.movenext
					loop
				end if
				rs88.close
				set rs88=nothing
			end if
			if bCanRestore1=false or bCanRestore2=false then
				hcfix=hcfix1+hcfix2
'if bCanRestore1=false or bCanRestore2=false then
				bCanRestore=false
			else
				hcfix=""
				bCanRestore=true
			end if
			existsKuout = True
			If sort1="1" Then
				if bCanRestore then
					if conn.execute("select top 1 1 from caigou_his with(nolock) where ord in (" & "0"&rs("caigou").value  & ") and opdate>'" & rs("deldate").Value & "' ").eof = false then
						hcfix = "(对应采购单已修改)"
						bCanRestore = False
					end if
				end if
			ElseIf sort1="7" Then
				If conn.execute("select  top 1 1  from kuinlist a with(nolock) inner join kuinlist b with(nolock) on a.kuin=" & id & " and a.joindblistID = b.joinDBlistID and a.id<>b.id and b.del<>2 and b.del<>7").eof = False Then
					hcfix = "(已有调拨入库)"
					bCanRestore = False
				end if
				If conn.execute("select  top 1 1  from kuoutlist2 a with(nolock) inner join kuinlist b with(nolock) on b.kuin=" & id & " and a.JoinDBlistId=b.JoinDBlistId and a.del=1").eof Then
					existsKuout = False
					hcfix = "(关联调拨出库单已被删除)"
				end if
			ElseIf sort1 = "5" Or sort1 = "13" Then
				iswagx =(conn.execute("select  top 1 1  from kuinlist with(nolock) where kuin="&id &" and isnull(M2_WAID,0)>0 and exists(select top 1 1 from dbo.M2_WFP_Assigns wfpa with(nolock) where wfpa.del=1 and wfpa.WAID=isnull(M2_WAID,0))").eof = false)
				iswapp=(conn.execute("select top 1 1 from dbo.M2_ProcessExecution_Result per with(nolock) inner join (select pep.WAID,MAX(pep.ProcIndex) MaxProcIndex from dbo.M2_ProcessExecution_Plan pep with(nolock) inner join dbo.kuinlist kl with(nolock) on kl.M2_WAID=pep.WAID where kl.kuin="&id &" group by pep.WAID) tt on tt.WAID=per.WAID and tt.MaxProcIndex=per.ProcIndex where (isnull(per.HgNumByCheck,0)+isnull(per.HgNumByRework,0))>0").eof = True)
				If iswagx and iswapp then
					existsKuout = False
					hcfix = "不允许恢复"
				end if
				isOldwaRK =(conn.execute("select  top 1 1  from kuinlist with(nolock) where kuin="&id &" and isnull(M2_WAID,0)>0 and not exists(select top 1 1 from dbo.M2_WFP_Assigns wfpa with(nolock) where wfpa.del=1 and wfpa.WAID=isnull(M2_WAID,0))").eof = false)
				If isOldwaRK and existsKuout and conn.execute("select  top 1 1  from kuinlist a with(nolock) inner join M2_WorkAssigns b with(nolock) on b.id=a.M2_WAID and b.del=1 where a.kuin=" & id & " and not exists(select top 1 1 from dbo.M2_WFP_Assigns wfpa with(nolock) where wfpa.del=1 and wfpa.WAID=b.Id)").eof=true Then
					existsKuout = False
					hcfix = "(关联派工单/返工单已被删除)"
				end if
				isNoQCRK=(conn.execute("select  top 1 1  from kuinlist a with(nolock) inner join M2_WorkAssigns b with(nolock) on b.id=a.M2_WAID and b.del=1  where a.kuin="&id &" and isnull(a.M2_WAID,0)>0 and isnull(b.ExecQcCheck,1)=0 and isnull(b.ReturnProcess,0)=0").eof = false)
				If isNoQCRK and existsKuout then
					If conn.execute("select  top 1 1  from kuinlist x with(nolock) inner join kuinlist y with(nolock) on x.kuin=" & id & " and x.M2_WAID=y.M2_WAID and x.del<>y.del and x.id <>y.id ").eof = false Then
						existsKuout = False
						hcfix = "(其派工单/返工单下已有其它入库单)"
					end if
				end if
				isOldQTRK = (conn.execute("select  top 1 1  from kuinlist with(nolock) where kuin="&id &" and isnull(m2_QTLID,0)>0 ").eof = false)
				If isOldQTRK and existsKuout and conn.execute("select  top 1 1  from kuinlist a with(nolock) inner join M_QualityTestingLists b with(nolock) on a.kuin=" & id & " and b.id=a.QTLID inner join M_QualityTestings c with(nolock) on c.del=0 and c.id = b.QTID ").eof=true And conn.execute("select 1 from kuinlist a with(nolock) inner join M_wwQCList b with(nolock) on a.kuin=" & id & " and b.id=-a.QTLID inner join M_QualityTestings c on c.del=0 and c.id = b.QCID ").eof = True And conn.execute("select 1 from kuinlist a inner join M2_QualityTestingLists b on a.kuin=" & id & " and b.id=isnull(nullif(a.QTLID,0),a.M2_QTLID) inner join M2_QualityTestings c with(nolock) on c.del=1 and c.id = b.QTID ").eof = True Then
					existsKuout = False
					hcfix = "(关联质检单已被删除)"
				end if
				If isOldQTRK and existsKuout then
					If conn.execute("select  top 1 1  from kuinlist x with(nolock) inner join kuinlist y with(nolock) on x.kuin=" & id & " and (x.QTLID=y.QTLID or x.M2_QTLID=y.M2_QTLID) and x.del<>y.del and x.id <>y.id ").eof = false Then
						existsKuout = False
						hcfix = "(其质检单下已有其它入库单)"
					end if
				end if
				if conn.execute("SELECT  top 1 1  FROM kuin with(nolock) WHERE fromid=(SELECT fromid FROM kuin with(nolock) WHERE ord=" & id & " and isnull(fromid,0)>0) and del=1 and (sort1=5 or sort1=13)").eof =false then
					existsKuout = False
				end if
			end if
			If sort1 = 3 Then
				If conn.execute("select  top 1 1  from kuin x with(nolock) inner join kuin y with(nolock) on x.ord=" & id & " and x.sort1=y.sort1 and isnull(x.source,0)=isnull(y.source,0) and isnull(x.fromid,0)=isnull(y.fromid,0) and isnull(x.caigou,0)=isnull(y.caigou,0) and x.ord<>y.ord and x.del<>y.del").eof =False Then
					existsKuout = False
					hcfix = "(其退料单下已有其它入库单)"
				end if
			end if
			if bCanRestore then
				if CheckKuinXlhExists(id) then
					hcfix = "(有重复序列号)"
					bCanRestore = False
				end if
			end if
			if bCanRestore then
				if conn.execute("select top 1 1 from kuin k with(nolock) inner join kuinlist kt with(nolock) on k.ord=kt.kuin "&_
				" inner join S2_SerialNumberRelation s2 with(nolock) on s2.BillType=61001 and abs(s2.BillID)="&id&" and abs(s2.ListID)=kt.id "&_
				" where k.ord="&id&" and  exists(select top 1 1 from S2_SerialNumberRelation s with(nolock) where s.BillType=61001 and s.SerialID=s2.SerialID and s.billid<>s2.BillID and s.id> s2.id) ").eof = False Then
					hcfix = "(序列号已被其他单据入库)"
					bCanRestore = False
				end if
			end if
			Response.write "" & vbcrlf & "             <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td width=""6%"" align=""center""><span class=""red"">" & vbcrlf & "                      <input name=""selectid"" type=""checkbox"" id=""selectid"" value="""
			Response.write rs("ord")
			Response.write """>" & vbcrlf & "                        </span></td> " & vbcrlf & "                   <td width=""8%"" align=""center"" height=""24"">"
			Response.write Rs.recordcount-Rs.pagesize*(currpage-1)-n
			Response.write "</td>" & vbcrlf & "                        <td width=""24%"" height=""27"" class=""name"" >&nbsp;<a href=""#"" onclick=""javascript:window.open('../store/contentrk.asp?ord="
			Response.write pwurl(rs("ord"))
			Response.write "','contractcon','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;"" title="""
			Response.write pwurl(rs("ord"))
			Response.write rs("title")
			Response.write """>"
			Response.write""&k&""
			Response.write "</a><span class=""red"">"
			Response.write hcfix
			Response.write "</span></td>" & vbcrlf & ""
			cateid=rs("cateidname")
			Response.write "" & vbcrlf & "      <td width=""15%"" class=""name"" ><div align=""center""><font class=""name"">"
			Response.write cateid
			Response.write "</font></div></td>" & vbcrlf & ""
			delcate=rs("delname")
			if  rs("cid")>0 then
				canDelete=false
			else
				canDelete=true
			end if
			Response.write "" & vbcrlf & "             <td class=""name""><div align=""center"">"
			Response.write delcate
			Response.write "</div></td> " & vbcrlf & "         <td width=""13%"" class=""name""><div align=""center"">"
			Response.write rs("deldate")
			Response.write "</div></td>" & vbcrlf & "          <td><div align=""center""><input type=""button"""
			if not bCanRestore Or Not existsKuout or IsBillRecovery(3,rs("ord")) then Response.write " disabled"
			Response.write " name=""Submit3c""  class=""anybutton"" value=""恢复"" onClick=""if(confirm('确认恢复？')){window.location.href='../../SYSN/view/recycle/store/KuinRecoveyHandle.ashx?ord="
			Response.write rs("ord")
			Response.write "&CurrPage="
			Response.write CurrPage
			Response.write "'}""/>&nbsp;&nbsp;"
			if canDelete then
				Response.write "<input type=""button"" name=""Submitdel"" class=""anybutton"" value=""彻底删除"" onClick=""if(confirm('您选择的是彻底删除，删除后不能再恢复，确认删除？')){window.location.href='deleterk.asp?ord="
				Response.write rs("ord")
				Response.write "&CurrPage="
				Response.write CurrPage
				Response.write "'}""/>"
			end if
			Response.write " </div></td>" & vbcrlf & "         </tr>" & vbcrlf & "           "
			n=n+1
			Response.write " </div></td>" & vbcrlf & "         </tr>" & vbcrlf & "           "
			rs.movenext
			if rs.eof or n>=rs.PageSize then exit do
		loop
		m=n
		Response.write "       " & vbcrlf & "  </table>" & vbcrlf & "    </td>" & vbcrlf & "</tr>" & vbcrlf & "<tr>" & vbcrlf & "   <td class=""page"">" & vbcrlf & "         <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "   <tr>" & vbcrlf & "    <td width=""10%"" height=""30""><div align=""center"">全选" & vbcrlf &" <input type=""checkbox"" name=""checkbox2"" value=""Check All"" onClick=""mm(this.form)""> "& vbcrlf & "    </div></td>" & vbcrlf &   "  <td> "& vbcrlf &           "   <input type=""submit"" name=""Submit426"" value=""批量删除""  onClick=""return test();""  class=""anybutton2"">" & vbcrlf &         "     <input type=""button"" name=""Submit426"" value=""批量恢复"" onclick=""ask2();"" class=""anybutton2""/>" & vbcrlf & "          </td>" & vbcrlf & "    <td width=""69%""><div align=""right"">" & vbcrlf & "    "
		Response.write rs.RecordCount
		Response.write "个 | "
		Response.write currpage
		Response.write "/"
		Response.write rs.pagecount
		Response.write "页 | &nbsp;"
		Response.write rs.pagesize
		Response.write "条信息/页&nbsp;&nbsp;" & vbcrlf & "    "
		if currpage=1 then
			Response.write "" & vbcrlf & "     <input type=""button"" name=""Submit4"" value=""首页""  class=""page""/> <input type=""button"" name=""Submit42"" value=""上一页""  class=""page""/>" & vbcrlf & "    "
		else
			Response.write "" & vbcrlf & "     <input type=""button"" name=""Submit4"" value=""首页""   class=""page"" onClick=""window.location.href='ruku.asp?currPage="
			Response.write  1
			Response.write "&a="
			Response.write a
			Response.write "&b="
			Response.write b
			Response.write "&c="
			Response.write c
			Response.write "'""/> <input type=""button"" name=""Submit42"" value=""上一页""  onClick=""window.location.href='ruku.asp?currPage="
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
			Response.write "" & vbcrlf & "     <input type=""button"" name=""Submit43"" value=""下一页""  class=""page""/> <input type=""button"" name=""Submit44"" value=""尾页""  class=""page""/>" & vbcrlf & "    "
		else
			Response.write "" & vbcrlf & "             <input type=""button"" name=""Submit43"" value=""下一页""  onClick=""window.location.href='ruku.asp?currPage="
			Response.write  currpage + 1
			Response.write "&a="
			Response.write a
			Response.write "&b="
			Response.write b
			Response.write "&c="
			Response.write c
			Response.write "'"" class=""page""/> <input type=""button"" name=""Submit43"" value=""尾页""  onClick=""window.location.href='ruku.asp?currPage="
			Response.write  rs.PageCount
			Response.write "&a="
			Response.write a
			Response.write "&b="
			Response.write b
			Response.write "&c="
			Response.write c
			Response.write "'"" class=""page""/>" & vbcrlf & "    "
		end if
		Response.write "" & vbcrlf & "    </div></td>" & vbcrlf & "  </tr>" & vbcrlf & "<script type=""text/Javascript"">window.currask2Url =""../../SYSN/view/recycle/store/KuinRecoveyHandle.ashx?currPage="
		Response.write currPage
		Response.write """; </script>" & vbcrlf & "<script src='../script/bk_comm01.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write "'></script>" & vbcrlf & "  <tr>" & vbcrlf & "    <td height=""38"" colspan=""3""><div align=""right""><p>&nbsp;" & vbcrlf & "      </p>" & vbcrlf & "    </div></td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "</form>                    " & vbcrlf & ""
	end if
	rs.close
	set rs=nothing
	dim actinon1
	action1="入库回收站"
	call close_list(1)
	Response.write "   " & vbcrlf & "    <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "      <tr> " & vbcrlf & "        <td height=""10"" colspan=""2""><img src=""../images/pixel.gif"" width=""1"" height=""1""></td>" & vbcrlf & "      </tr> " & vbcrlf & "               <tr>" & vbcrlf &"             <td width=""16%"" height=""10""><div align=""right""></div></td>" & vbcrlf & "        <td width=""84%"">&nbsp;</td>" & vbcrlf & "       </tr>" & vbcrlf & "             <tr>" & vbcrlf & "              <td height=""10"" colspan=""2"">&nbsp;</td>" & vbcrlf & "         </tr>" & vbcrlf & "             <tr>" & vbcrlf & "              <td height=""10"" colspan=""2"">&nbsp;</td>" & vbcrlf & "           </tr>" & vbcrlf & "    </table>" & vbcrlf & "       </td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "</body>" & vbcrlf & "</html>"
	
%>
