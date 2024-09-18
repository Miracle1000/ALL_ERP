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
	
	Dim IsDisReportBar, RptHasVisible, PreRptProcIndex
	Sub DisReportBar()
		IsDisReportBar = True
		Response.write "" & vbcrlf & "<script language='javascript'>" & vbcrlf & " var obj_box = document.getElementById(""rpt_proc_bar"");" & vbcrlf & "    if(obj_box) {obj_box.style.display = ""none"";}" & vbcrlf & "</script>" & vbcrlf & "    "
	end sub
	Sub InitReportBar(ByVal labeltxt)
		IsDisReportBar = False
		RptHasVisible = False
		Response.write "" & vbcrlf & "       <div id='rpt_proc_bar' style='display:none;width:400px;position:absolute;left:30%;top:26%;z-index:10000'>" & vbcrlf & "       <TABLE class=sys_dbgtab8 cellSpacing=0 cellPadding=0  style='width:400px;' align='center'><TBODY>" & vbcrlf & "       <TR>" & vbcrlf & "    <TD style=""HEIGHT: 20px"" class=sys_dbtl></TD>" & vbcrlf & "   <TD class=sys_dbtc></TD>" & vbcrlf & "        <TD class=sys_dbtr></TD></TR>" & vbcrlf & "   <TR>" & vbcrlf & "    <TD class=sys_dbcl></TD>" & vbcrlf & "        <TD style='border:1px solid #bbb;background-color:white;padding:22px;color:#000;background-color:#fff' valign='top'>" & vbcrlf & "               正在加载“"
		Response.write labeltxt
		Response.write "”,<span id='rpt_proc_bar_st'>请稍后<input type='button' id='r_p_nv' style='display:inline;background-color:white;border:0px;font-size:12px;height:13px;padding:0px'></span>...</span>" & vbcrlf & "                <div style='margin-top:5px;margin-bottom:5px;border:1px solid #c0ccdd;height:12px;background-color:white'>" & vbcrlf & "                       <div id='rpt_proc_v' style='height:10px;background-color:#4475e6;width:0%;background-image:url(../images/bj_tiao2.gif);margin:1px'></div>" & vbcrlf & "               </div>" & vbcrlf & "  </TD>" & vbcrlf & "   <TD class=sys_dbcr></TD></TR>" & vbcrlf & "   <TR>" & vbcrlf & "    <TD class=sys_dbbl></TD>" & vbcrlf & " <TD class=sys_dbbc></TD>" & vbcrlf & "        <TD class=sys_dbbr></TD></TR></TBODY></TABLE></div>" & vbcrlf & "     "
		PreRptProcIndex = -1
	end sub
	Sub doProc(ByVal count , ByVal procv)
		Dim jd
		If IsDisReportBar = true Then  Exit Sub
		If count > 0 Then
			procv = CInt((procv*1.00 / count)*100)
			If procv > 100 Then procv = 100
		else
			procv = 0
		end if
		If procv <= PreRptProcIndex Then
			Exit sub
		end if
		PreRptProcIndex = procv
		Response.write "<script language='javascript'>document.getElementById('rpt_proc_v').style.width='" & procv & "%';document.getElementById('r_p_nv').value='(" & procv & "%)';"
		If RptHasVisible = False Then
			Response.write "document.getElementById('rpt_proc_bar').style.display = 'block';"
			RptHasVisible = true
		end if
		Response.write "</script>"
		Response.flush
	end sub
	Sub closeReportBar()
		If IsDisReportBar = true Then  Exit sub
		Response.write "" & vbcrlf & "      <script language='javascript'>" & vbcrlf & "  document.getElementById('rpt_proc_v').style.width='100%'" & vbcrlf & "        document.getElementById(""rpt_proc_bar_st"").innerText = ""加载完毕。""" & vbcrlf & " setTimeout( function () {" & vbcrlf & "               document.getElementById(""rpt_proc_bar"").style.display = ""none""" & vbcrlf & "        },50);" & vbcrlf & "  </script>" & vbcrlf & ""
		Response.flush
	end sub
	Function IsInList(StrList, StrFind, CharSplit)
		IsInList = InStr(1, CharSplit&StrList&CharSplit, CharSplit&StrFind&CharSplit, 1)>0
	end function
	Function CanFormatNumber(strFieldName)
		CanFormatNumber = (InStr(1, strFieldName, "_DONUM", 1)>0 Or InStr(1, strFieldName, "_MONEY", 1)>0)
	end function
	Function CanSum(strFieldName)
		CanSum = (InStr(1, strFieldName, "_DOSUM", 1)>0)
	end function
	Function replaceDefineName(strFieldName)
		replaceDefineName = Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(strFieldName, "_DONUM", ""), "_DOSUM", ""),"_MONEY",""), "_ID", ""), "brl", "("), "brr", ")"),"_StorePrice_dot_num",""),"_SalesPrice_dot_num","")
	end function
	Function strCombine(strOri, strComb, strSplit)
		If strOri = "" Then
			strCombine = strSplit&strComb
		else
			strCombine = strCombine&strSplit&strComb
		end if
	end function
	Function myformatnumber(v, n1, n2, n3, n4)
		If IsNumeric(v & "") = True Then
			myformatnumber = FormatNumber(v, n1, n2, n3, n4)
		else
			myformatnumber = 0
		end if
	end function
	Function strSubtraction(strOri, strComb, strSplit)
		Dim f_str
		f_str = Replace(strSplit&strOri&strSplit, strSplit&strComb&strSplit, strSplit)
		If Left(f_str, Len(strSplit)) = strSplit Then f_str = Right(f_str, Len(f_str) - Len(strSplit))
'f_str = Replace(strSplit&strOri&strSplit, strSplit&strComb&strSplit, strSplit)
		If Right(f_str, Len(strSplit)) = strSplit Then f_str = Left(f_str, Len(f_str) - Len(strSplit))
'f_str = Replace(strSplit&strOri&strSplit, strSplit&strComb&strSplit, strSplit)
		strSubtraction = f_str
	end function
	Class GatherList
		Public digits
		Public digits_m
		Public StorePrice_dot_num
		Public SalesPrice_dot_num
		Public FieldsSettingIndex
		Public PageSize
		Public CurrPage
		Public PageCount
		Public CanProcPage
		Public CanPX
		Public CantPXFields
		Public CanPXFields
		Public HideFields
		Public CantExportFields
		Public ExportChangeStyleFields
		Public CanTotalSum
		Public CanPageSum
		Public UseProgressBar
		Public DisableProgressBar
		Public DisableBG
		Public AutoProgressBar
		Public px
		Public baseSQL
		Public exportsql
		Public PKName
		Public fieldsList
		Public strCondition
		Public title
		Public title2
		Public ExportFileName
		Public zdylist
		Public ShowDebug
		Public DelBatch
		Public DelID
		Public FiledAdd
		Public QxSort1
		Public OnlyOneField
		Public IfShowPx
		Public RecordCount
		Public isGroup
		Public strOrder
		Public cookieWidth
		Public cWidth
		Public firstSumColumn
		Public lastSumLable
		Public intro
		Public FieldsOrder
		Public arrFields
		Public TotalProgress
		Public ProgressNow
		Public set_MinWidth
		Private RealFieldsList
		Private RealFieldsCount
		Private isExportMode
		Public rsSum
		Public rsHeader
		Public showPage1
		Public showPage2
		Public showPage3
		Public showxs
		Public showcz
		Public showTS
		Private CustomShowFields_Exists
		Public Function getFieldIndexByName(strFieldName)
			For i = 0 To Me.rsHeader.fields.count - 1
'Public Function getFieldIndexByName(strFieldName)
				If Me.rsHeader.fields(i).name = strFieldName Then
					getFieldIndexByName = i
					Exit Function
				end if
			next
			getFieldIndexByName = -1
			Exit Function
		end function
		Function getFieldShowIdx(idx)
			For i = 0 To ubound(Me.arrFields) - 1
'Function getFieldShowIdx(idx)
				If Me.arrFields(i) = idx Then
					getFieldShowIdx = i
					Exit Function
				end if
			next
			getFieldShowIdx = -1
			Exit Function
		end function
		Sub classInit()
			server.scripttimeout = 9999
			CustomShowFields_Exists = SubExists("CustomShowFields")
			If Me.CanPX = "" Then Me.CanPX = True
			If Me.CanProcPage = "" Then Me.CanProcPage = False
			If Me.CanTotalSum = "" Then Me.CanTotalSum = True
			If Me.CanPageSum = "" Then Me.CanPageSum = True
			If Me.UseProgressBar = "" Then Me.UseProgressBar = True
			If Me.DisableProgressBar = "" Then Me.DisableProgressBar = False
			If Me.DisableBG = "" Then Me.DisableBG = True
			If Me.ShowDebug = "" Then Me.ShowDebug = False
			If Me.AutoProgressBar = "" Then Me.AutoProgressBar = True
			If Me.DelBatch = "" Then Me.DelBatch = False
			Call GetPageCount()
			If Me.PageCount<= 2 And Me.AutoProgressBar = True Then
				Me.UseProgressBar = False
				Me.DisableProgressBar = True
			end if
			If Me.IfShowPx="" then Me.IfShowPx=True
			If Me.showPage1="" then Me.showPage1=True
			If Me.showPage2="" then Me.showPage2=True
			If Me.showPage3="" then Me.showPage3=True
			If Me.showxs="" then Me.showxs=True
			If Me.showcz="" then Me.showcz=True
			If Me.showTS="" then Me.showTS=True
		end sub
		Sub run()
			isExportMode = False
			on error resume next
			Dim rsDefine
			If FieldsSettingIndex = "" Then
				Response.write "<script>alert('序号没有设置，请检查！');</script>"
				conn.close
				call db_close : Response.end
			end if
			Set rsDefine = conn.Execute("select top 1 * from GatherRegistration where SettingIndex="&FieldsSettingIndex)
			If rsDefine.EOF=true Then
				Response.write "<script>alert('序号没有注册，请检查！');</script>"
				conn.close
				call db_close : Response.end
			end if
			rsDefine.Close
			Set rsDefine = Nothing
			On Error GoTo 0
			classInit
			getShowFieldsWidth
			getOrderBySQL
			ShowGatherListHTMLHead
			ShowGatherListContent
			ShowSearchDiv
			ShowGatherListHTMLFoot
			ShowGatherListHTMLFootExtend
			Set rs =conn.execute("select * from dbo.sysobjects where id = object_id(N'[dbo].[kqresultlist"&session("personzbintel2007")&"]')")
			If Not rs.eof Then
				conn.execute("drop table kqresultlist"& session("personzbintel2007") )
			end if
			rs.close
			Set rs=Nothing
		end sub
		Sub export()
			isExportMode = True
			classInit
			response.Clear
			Response.Charset = "UTF-8"
'response.Clear
			Call Response.AddHeader("content-type", "application/msexcel")
'response.Clear
			Call Response.AddHeader("Content-Disposition", "attachment;filename="&Me.ExportFileName&".xls")
'response.Clear
			Call Response.AddHeader("Pragma", "No-Cache")
'response.Clear
			server.scripttimeout = 9999999
			getShowFieldsWidth
			getOrderBySQL
			Response.write "" & vbcrlf & "     <html xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns=""http://www.w3.org/TR/REC-html40"">" & vbcrlf & "             <head>" & vbcrlf & "                  <meta http-equiv=Content-Type content=""text/html; charset=UTF-8"">" & vbcrlf & "                 <metaname=ProgId content=""Excel.Sheet"">" & vbcrlf & "                   <meta name=Generator content=""Microsoft Excel 11"">" & vbcrlf & "                        <title>"
			Response.write me.title
			Response.write "</title>" & vbcrlf & "                     <style>" & vbcrlf & "                         table{" & vbcrlf & "                                  border-collapse:collapse;" & vbcrlf & "                               }" & vbcrlf & "                               td.title {" & vbcrlf & "                                      font-weight:bold;" & vbcrlf & "                                       height:50px;" & vbcrlf & "                            }" & vbcrlf & "                               td.head{" & vbcrlf & "                                        padding-top:1px;"& vbcrlf &                                     "padding-right:3px;" & vbcrlf &                                       "padding-left:3px;" & vbcrlf &                                        "mso-ignore:padding;" & vbcrlf &                                      "color:windowtext;" & vbcrlf &                                       " font-size:12px;" & vbcrlf &                                  "font-weight:bold;" & vbcrlf &                                        "font-style:normal;" & vbcrlf &                                       "text-decoration:none;" & vbcrlf & "                                   font-family:宋体;" & vbcrlf & "                                       mso-generic-font-family:auto;" & vbcrlf & "                                   mso-font-charset:134;" & vbcrlf & "                                   mso-number-format:General;" & vbcrlf & "                                      text-align:general;" & vbcrlf & "                                     vertical-align:bottom;" & vbcrlf & "                                  border-left:.5pt solid windowtext;" & vbcrlf & "                                    mso-background-source:auto;" & vbcrlf & "                                     mso-pattern:auto;" & vbcrlf & "                                       white-space:nowrap;" & vbcrlf & "                                     height:22px;" & vbcrlf & "                                    width:80px;" & vbcrlf & "                             }" & vbcrlf & "                               td.cell{" & vbcrlf & "                                        padding-top:1px;" & vbcrlf & "                                        padding-right:3px;" & vbcrlf & "                                      padding-left:3px;" & vbcrlf & "                                       mso-ignore:padding;" & vbcrlf & "                                     color:windowtext;" & vbcrlf & "                                       font-size:12px;" & vbcrlf & "                                 font-style:normal;" & vbcrlf & "                                      text-decoration:none;" & vbcrlf & "                                   font-family:宋体;" & vbcrlf & "                                       mso-generic-font-family:auto;" & vbcrlf & "                                   mso-font-charset:134;" & vbcrlf & "                                   text-align:general;" & vbcrlf & "                                     vertical-align:bottom;" & vbcrlf & "                                  border:.5pt solid windowtext;" & vbcrlf & "                                   mso-background-source:auto;" & vbcrlf & "                                     mso-pattern:auto;" & vbcrlf & "                                       white-space:nowrap;" & vbcrlf & "                                     height:22px;" & vbcrlf & "                                }" & vbcrlf & "" & vbcrlf & "                               td.foot{" & vbcrlf & "                                        border-top:1px solid #000;" & vbcrlf & "                                      text-align:right;" & vbcrlf & "                                       height:30px;" & vbcrlf & "                                    font-size:12px;" & vbcrlf & "                         }" & vbcrlf & "                       </style>" & vbcrlf & "                        <!--[if gte mso 9]><xml>" & vbcrlf & "                   <x:ExcelWorkbook>" & vbcrlf & "                        <x:ExcelWorksheets>" & vbcrlf & "                      <x:ExcelWorksheet>" & vbcrlf & "                           <x:Name>数据清单</x:Name>" & vbcrlf & "                               <x:WorksheetOptions>" & vbcrlf & "                             <x:DefaultRowHeight>285</x:DefaultRowHeight>" & vbcrlf & "                            <x:CodeName>Sheet1</x:CodeName>" & vbcrlf & "                          <x:Selected/>" & vbcrlf & "                          </x:WorksheetOptions>" & vbcrlf & "                      </x:ExcelWorksheet>" & vbcrlf & "                    </x:ExcelWorksheets>" & vbcrlf & "                   </x:ExcelWorkbook>" & vbcrlf & "                     </xml><![endif]-->" & vbcrlf & "              </head>" & vbcrlf & "         <body>" & vbcrlf & "                  <table cellPadding=0 cellSpacing=0 class='frame'>" & vbcrlf & "                  <tr>" & vbcrlf & "                            <td>&nbsp;</td>" & vbcrlf & "                 </tr>" & vbcrlf & ""
			Dim rs, i
			Set rs = server.CreateObject("adodb.recordset")
			Dim orderstr_temp : orderstr_temp = Me.strOrder
			If InStr(orderstr_temp, Me.PKName )=0 And Len(Me.PKName)>0 And Me.canProcPage = true Then
				If Len(Trim(orderstr_temp&""))>0 Then orderstr_temp = orderstr_temp & ","
				orderstr_temp = orderstr_temp & Me.PKName
			end if
			if Me.FieldsSettingIndex=80015 then
				if Me.exportsql<>"" then
					tmpsql = Replace(Replace(Replace(replace(Me.baseSQL,"from mlist333","from mlist333 "&Me.exportsql&" "), "PAGE_TOP_NUM", ""), "PAGE_ORDER_STR", ""), "PAGE_COUNT_NUM", "*")&Me.strCondition & " order by " &  orderstr_temp
				else
					tmpsql = Replace(Replace(Replace(Me.baseSQL, "PAGE_TOP_NUM", ""), "PAGE_ORDER_STR", ""), "PAGE_COUNT_NUM", "*")&Me.strCondition & " order by " & orderstr_temp
				end if
			else
				tmpsql = Replace(Replace(Replace(Me.baseSQL, "PAGE_TOP_NUM", ""), "PAGE_ORDER_STR", ""), "PAGE_COUNT_NUM", "*")&Me.strCondition & " order by " &  orderstr_temp
			end if
			groupbyCountSql=Replace(Replace(Replace(Me.baseSQL, "PAGE_TOP_NUM", ""), "PAGE_ORDER_STR", ""), "PAGE_COUNT_NUM", "*")&Me.strCondition
			rs.Open tmpsql, conn, 1, 1
			Dim FieldIsID, FieldVisible, FieldCanSum, FieldCanFormat, FieldCount
			FieldCount = 0
			ReDim FieldIsID(rs.fields.Count -1)
'FieldCount = 0
			ReDim FieldVisible(rs.fields.Count -1)
'FieldCount = 0
			ReDim FieldCanSum(rs.fields.Count -1)
'FieldCount = 0
			ReDim FieldCanFormat(rs.fields.Count -1)
'FieldCount = 0
			For i = 0 To UBound(Me.arrFields)
				If InStr(1, rs.fields(CInt(Me.arrFields(i))).Name, "_ID", 1)>0  or (Me.FieldsSettingIndex=80015 and instr(rs.fields(CInt(Me.arrFields(i))).Name,"客户编号")>0) Then
					FieldIsID(i) = True
				else
					FieldIsID(i) = False
					NoIDCount = NoIDCount + 1
'FieldIsID(i) = False
				end if
				If IsInList(Me.intro, Me.arrFields(i), ",") Then
					FieldVisible(i) = True
				else
					FieldVisible(i) = False
				end if
				If CanSum(rs.fields(CInt(Me.arrFields(i))).Name) Then
					FieldCanSum(i) = True
				else
					FieldCanSum(i) = False
				end if
				If CanFormatNumber(rs.fields(CInt(Me.arrFields(i))).Name) Then
					FieldCanFormat(i) = True
				else
					FieldCanFormat(i) = False
				end if
				If Not FieldIsID(i) And FieldVisible(i) And Not IsInList(Me.CantExportFields, rs.fields(CInt(Me.arrFields(i))).Name, ",") Then
					FieldCount = FieldCount + 1
				end if
				If Me.firstSumColumn = 0 And IsInList(Me.intro, Me.arrFields(i), ",") And CanSum(rs.fields(CInt(Me.arrFields(i))).Name) Then
					Me.firstSumColumn = i
				end if
			next
			Response.write "" & vbcrlf & "                     <tr>" & vbcrlf & "                            <td>&nbsp;</td><td colspan='"
			Response.write FieldCount
			Response.write "' align=center class='title' style='border-bottom:1px solid #000'>"
			Response.write FieldCount
			Response.write me.title
			Response.write "</td>" & vbcrlf & "                        </tr>" & vbcrlf & ""
			If me.title2<>"" Then
				Response.write "" & vbcrlf & "                             <tr>" & vbcrlf & "                                    <td>&nbsp;</td><td colspan='"
				Response.write FieldCount
				Response.write "' align=center class='cell' style='border-bottom:1px solid #000'>"
				Response.write FieldCount
				Response.write me.title2
				Response.write "</td>" & vbcrlf & "                                </tr>" & vbcrlf & ""
			end if
			Response.write "<tr><td style='border-right:1px solid #000'>&nbsp;</td>"
			Response.write "</td>" & vbcrlf & "                                </tr>" & vbcrlf & ""
			Dim sumSql, sumFlg, zdyarr, zdyidx
			zdyidx=""
			sumSql = ""
			sumFlg = False
			If Me.zdylist<>"" Then
				zdyarr = Split(Me.zdylist, ",")
				zdyidx = 0
			end if
			dim FieldsTmpStr,CanCospan,ifCospan,level2Tr
			redim CanCospan(UBound(Me.arrfields))
			ifCospan=0
			k=0
			for i=0 to Ubound(Me.arrFields)
				If FieldIsID(i) Or Not FieldVisible(i) Then
					strDisplay = ";display:none"
				else
					strDisplay = ""
				end if
				FieldsTmpStr=rs.fields(CInt(Me.arrFields(i))).Name
				If Not FieldIsID(i) And FieldVisible(i) And Not IsInList(Me.CantExportFields, rs.fields(CInt(Me.arrFields(i))).Name, ",") Then
					if instr(FieldsTmpStr,"_数量")>0 or instr(FieldsTmpStr,"_金额")>0 then
						ifCospan=1
						CanCospan(i)=true
						if instr(FieldsTmpStr,"_数量")>0 then
							level2Tr=level2Tr&"<td class='cell'>数量</td>"
						else
							level2Tr=level2Tr&"<td class='cell'>金额</td>"
						end if
					else
						CanCospan(i)=false
					end if
				else
					if instr(FieldsTmpStr,"_数量")>0 or instr(FieldsTmpStr,"_金额")>0 then
						ifCospan=1
						CanCospan(i)=true
					else
						CanCospan(i)=false
					end if
				end if
				k=k+1
				CanCospan(i)=false
			next
			FieldsTmpStr=""
			colspans=0
			For i = 0 To rs.fields.Count - 1
'colspans=0
				If i<Me.firstSumColumn And Not FieldIsID(i) And FieldVisible(i) Then Me.lastSumLable = i
				If InStr(1, rs.fields(CInt(Me.arrFields(i))).Name, "_自定义字段")>0 Then
					if zdyidx="" then
						FieldTitle =""
					else
						FieldTitle =zdyarr(zdyidx)
						zdyidx = zdyidx + 1
'FieldTitle =zdyarr(zdyidx)
					end if
				else
					FieldTitle = replaceDefineName(rs.fields(CInt(Me.arrFields(i))).Name)
				end if
				If Not FieldIsID(i) And FieldVisible(i) And Not IsInList(Me.CantExportFields, rs.fields(CInt(Me.arrFields(i))).Name, ",") Then
					if ifCospan=1 then
						if CanCospan(i) then
							if Ubound(split(FieldTitle,"_"))=2 then
								FieldsTmpStr2=split(FieldTitle,"_")(0)&split(FieldTitle,"_")(2)
							else
								FieldsTmpStr2=split(FieldTitle,"_")(0)
							end if
							if FieldsTmpStr<>FieldsTmpStr2 then
								If (FieldIsID(i) Or Not FieldVisible(i)) and colspans=0 Then
									if (i+1)<UBound(Me.arrFields) then
'If (FieldIsID(i) Or Not FieldVisible(i)) and colspans=0 Then
										If (FieldIsID(i+1) Or Not FieldVisible(i+1)) and CanCospan(i+1) Then
'If (FieldIsID(i) Or Not FieldVisible(i)) and colspans=0 Then
											colspans=0
										else
											colspans=1
											strDisplay=""
										end if
									else
										colspans=1
									end if
								else
									FieldsTmpStr3=replaceDefineName(rs.fields(CInt(Me.arrFields(i+1))).Name)
									colspans=1
									FieldsTmpStr4=replaceDefineName(rs.fields(CInt(Me.arrFields(i-1))).Name)
'colspans=1
									if Ubound(split(FieldsTmpStr3,"_"))=2 then
										FieldsTmpStr3=split(FieldsTmpStr3,"_")(0)&split(FieldsTmpStr3,"_")(2)
									else
										FieldsTmpStr3=split(FieldsTmpStr3,"_")(0)
									end if
									if Ubound(split(FieldsTmpStr4,"_"))=2 then
										FieldsTmpStr4=split(FieldsTmpStr4,"_")(0)&split(FieldsTmpStr4,"_")(2)
									else
										FieldsTmpStr4=split(FieldsTmpStr4,"_")(0)
									end if
									if FieldsTmpStr3=FieldsTmpStr2 and ((FieldIsID(i+1) Or Not FieldVisible(i+1)) and CanCospan(i+1)) then
										FieldsTmpStr4=split(FieldsTmpStr4,"_")(0)
										colspans=1
										strDisplay=""
									elseif FieldsTmpStr4=FieldsTmpStr2 and ((FieldIsID(i-1) Or Not FieldVisible(i-1)) and CanCospan(i-1)) then
'strDisplay=""
										colspans=1
'strDisplay=""
									else
										if OnlyShowMoneyOrNum=1 or OnlyShowMoneyOrNum=2 then
											colspans=1
										else
											colspans=2
										end if
									end if
									FieldsTmpStr=FieldsTmpStr2
									Response.write "<td class='head' colSpan='"&colspans&"'>" & FieldsTmpStr & "</td>"
								end if
							end if
						else
							Response.write "<td class='head' rowSpan='2'>" & FieldTitle & "</td>"
						end if
					else
						Response.write "<td class='head'>" & FieldTitle & "</td>"
					end if
				end if
				If FieldCanSum(i) Then
					If sumFlg = False Then
						sumSql = sumSql&" sum(["&rs.fields(CInt(Me.arrFields(i))).Name&"]) as sum"&i
						sumFlg = True
					else
						sumSql = sumSql&",sum(["&rs.fields(CInt(Me.arrFields(i))).Name&"]) as sum"&i
					end if
				else
					If sumFlg = False Then
						sumSql = sumSql&" '' as sum"&i
						sumFlg = True
					else
						sumSql = sumSql&",'' as sum"&i
					end if
				end if
			next
			Response.write "<td style='border-left:1px solid #000'>&nbsp;</td></tr>"
			sumSql = sumSql&",'' as sum"&i
			if ifCospan=1 then Response.write "<tr><td style='border-left:1px solid #000'>"&level2Tr&"</td></tr>"
'sumSql = sumSql&",'' as sum"&i
			Dim tmpi
			tmpi = 1
			Dim hasCellHandle : hasCellhandle =  SubExists("handleExcelCell")
			While rs.EOF=false
				Response.write "<tr><td style='border-right:1px solid #000'>&nbsp;</td>"
'While rs.EOF=false
				For i = 0 To rs.fields.Count - 1
'While rs.EOF=false
					If Not FieldIsID(i) And FieldVisible(i) And Not IsInList(Me.CantExportFields, rs.fields(CInt(Me.arrFields(i))).Name, ",") Then
						If ExportChangeStyleFields<>"" And IsInList(ExportChangeStyleFields, rs.fields(CInt(Me.arrFields(i))).Name, ",") Then
							Response.write "<td class='cell'>"
							Call CustomShowFields(CInt(Me.arrFields(i)), rs.fields)
							Response.write "</td>"
						else
							If FieldCanFormat(i) Then
								cellv = rs.fields(CInt(Me.arrFields(i))).Value
								If hasCellhandle Then
									Call handleExcelCell(cellv, rs, rs.fields(CInt(Me.arrFields(i))).Name)
								end if
								if instr(rs.fields(CInt(Me.arrFields(i))).Name,"_MONEY")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"额")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"总价")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"毛利")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"出库成本")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"退货成本")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"库存成本")>0 then
									Response.write "<td class='cell' style='vnd.ms-excel.numberformat:#,##0."&String(digits_m,"0")&"'>" & myFormatNumber(cellv, Me.digits_m, -1, 0, 0) & "</td>"
'ields(CInt(Me.arrFields(i))).Name,"退货成本")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"库存成本")>0 then
								elseif instr(rs.fields(CInt(Me.arrFields(i))).Name,"_StorePrice_dot_num")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"成本单价")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"进价")>0 then
									Response.write "<td class='cell' style='vnd.ms-excel.numberformat:#,##0."&String(StorePrice_dot_num,"0")&"'>" & myFormatNumber(cellv, Me.StorePrice_dot_num, -1, 0, 0) & "</td>"
								elseif instr(rs.fields(CInt(Me.arrFields(i))).Name,"_SalesPrice_dot_num")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"单价")>0 then
									Response.write "<td class='cell' style='vnd.ms-excel.numberformat:#,##0."&String(SalesPrice_dot_num,"0")&"'>" & myFormatNumber(cellv, Me.SalesPrice_dot_num, -1, 0, 0) & "</td>"
								else
									Response.write "<td class='cell' style='vnd.ms-excel.numberformat:#,##0."&String(digits,"0")&"'>" & myFormatNumber(cellv, Me.digits, -1, 0, 0) & "</td>"
								end if
							else
								If CustomShowFields_Exists Then
									Response.write "<td class='cell' style='vnd.ms-excel.numberformat:@'>"
'If CustomShowFields_Exists Then
									Call CustomShowFields(CInt(Me.arrFields(i)), rs.fields)
									Response.write "</td>"
								else
									Response.write "<td class='cell'>" & rs.fields(CInt(Me.arrFields(i))).Value & "</td>"
								end if
							end if
						end if
					end if
				next
				Response.write "<td style='border-left:1px solid #000'>&nbsp;</td></tr>"
				Response.write "<td class='cell'>" & rs.fields(CInt(Me.arrFields(i))).Value & "</td>"
				tmpi = tmpi + 1
				Response.write "<td class='cell'>" & rs.fields(CInt(Me.arrFields(i))).Value & "</td>"
				If tmpi Mod 100 = 0 Then response.flush
				rs.movenext
			wend
			rs.close
			If Me.CanTotalSum Then
				Response.write "<tr><td style='border-right:1px solid #000'>&nbsp;</td>"
'If Me.CanTotalSum Then
				if Me.FieldsSettingIndex=80015 then
					if Me.exportsql<>"" then
						sqlSum = Replace(Replace(Replace(replace(Me.baseSQL,"from mlist333","from mlist333 "&Me.exportsql&" "), "PAGE_COUNT_NUM", sumSql), "PAGE_TOP_NUM", ""), "PAGE_ORDER_STR", "") & strCondition
					else
						sqlSum = Replace(Replace(Replace(Me.baseSQL, "PAGE_COUNT_NUM", sumSql), "PAGE_TOP_NUM", ""), "PAGE_ORDER_STR", "") & strCondition
					end if
				else
					sqlSum = Replace(Replace(Replace(Me.baseSQL, "PAGE_COUNT_NUM", sumSql), "PAGE_TOP_NUM", ""), "PAGE_ORDER_STR", "") & strCondition
				end if
				Set Me.rsSum = conn.Execute(sqlsum)
				For i = 0 To rs.fields.Count -1
'Set Me.rsSum = conn.Execute(sqlsum)
					If i = Me.lastSumLable Then
						Response.write "" & vbcrlf & "                                                                     <td class='cell'>总计：</td>" & vbcrlf & "                            "
					else
						If Not FieldIsID(i) And FieldVisible(i) And Not IsInList(Me.CantExportFields, rs.fields(CInt(Me.arrFields(i))).Name, ",") Then
							If SubExists("CustomShowTotalSumFields") Then
								Response.write "<td class='cell' "
								If SubExists("SumCount") Then Response.write " style='vnd.ms-excel.numberformat:#,##0.00' "
								Response.write "<td class='cell' "
								Response.write ">"
								Call CustomShowTotalSumFields(rs.fields(CInt(Me.arrFields(i))).Name, Me.rsSum(i).Value&"")
								If SubExists("SumCount") Then Call SumCount(groupbyCountSql,rs.fields(CInt(Me.arrFields(i))).Name)
								Response.write "</td>"
							ElseIf SubExists("CustomShowTotalSumFieldsEX") Then
								Response.write "<td class='cell' "
								If SubExists("SumCount") Then Response.write " style='vnd.ms-excel.numberformat:#,##0.00' "
								Response.write "<td class='cell' "
								Response.write ">"
								Call CustomShowTotalSumFieldsEX(rs.fields(CInt(Me.arrFields(i))).Name,rsSum(i).Value& "",rs.fields,i)
								If SubExists("SumCount") Then Call SumCount(groupbyCountSql,rs.fields(CInt(Me.arrFields(i))).Name)
								Response.write "</td>"
							else
								If FieldCanFormat(i) Then
									if instr(rs.fields(CInt(Me.arrFields(i))).Name,"_MONEY")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"额")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"总价")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"毛利")>0 then
										Response.write "<td class='cell' style='vnd.ms-excel.numberformat:#,##0."&String(digits_m,"0")&"'>"&myFormatNumber(Me.rsSum(i).Value, Me.digits_m, -1, 0, 0)&"</td>"
									elseif instr(rs.fields(CInt(Me.arrFields(i))).Name,"_StorePrice_dot_num")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"成本单价")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"进价")>0 then
										Response.write "<td class='cell' style='vnd.ms-excel.numberformat:#,##0."&String(StorePrice_dot_num,"0")&"'>" & myFormatNumber(cellv, Me.StorePrice_dot_num, -1, 0, 0) & "</td>"
									elseif instr(rs.fields(CInt(Me.arrFields(i))).Name,"_SalesPrice_dot_num")>0 then
										Response.write "<td class='cell' style='vnd.ms-excel.numberformat:#,##0."&String(SalesPrice_dot_num,"0")&"'>" & myFormatNumber(cellv, Me.SalesPrice_dot_num, -1, 0, 0) & "</td>"
'elseif instr(rs.fields(CInt(Me.arrFields(i))).Name,"_SalesPrice_dot_num")>0 then
									else
										Response.write "<td class='cell' style='vnd.ms-excel.numberformat:#,##0."&String(digits,"0")&"'>"&myFormatNumber(Me.rsSum(i).Value, Me.digits, -1, 0, 0)&"</td>"
'elseif instr(rs.fields(CInt(Me.arrFields(i))).Name,"_SalesPrice_dot_num")>0 then
									end if
								else
									Response.write "<td class='cell'>"&Me.rsSum(i).Value&"</td>"
								end if
							end if
						end if
					end if
				next
				Me.rsSum.Close
				Response.write "<td style='border-left:1px solid #000'>&nbsp;</td></tr>"
'Me.rsSum.Close
				If SubExists("CreateMoreSumRow") Then
					Call CreateMoreSumRow(Me,FieldIsID,FieldVisible,rs,2)
				end if
			end if
			Response.write "" & vbcrlf & "                      <tr>" & vbcrlf & "                            <td>&nbsp;</td><td colspan='"
			Response.write FieldCount
			Response.write "' class='foot'>导出时间:"
			Response.write now
			Response.write "&nbsp;&nbsp;导出人:"
			Response.write session("name2006chen")
			Response.write "</td>" & vbcrlf & "                 </tr>" & vbcrlf & "                   </table>" & vbcrlf & ""
			set rs = nothing
			Response.write "" & vbcrlf & "              </body>" & vbcrlf & " </html>" & vbcrlf & ""
		end sub
		Sub ShowGatherListHTMLHead
			server.scripttimeout = 9999999
			Me.TotalProgress = 0
			Me.ProgressNow = 0
			Response.write "" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<meta http-equiv=""X-UA-Compatible"" content=""IE=7"">" & vbcrlf & "<title>"
'Me.ProgressNow = 0
			Response.write title_xtjm
			Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
			Response.write Application("sys.info.jsver")
			Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/default/easyui.css?ver="
			Response.write Application("sys.info.jsver")
			Response.write """>" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/icon.css?ver="
			Response.write Application("sys.info.jsver")
			Response.write """>" & vbcrlf & "<style>" & vbcrlf & ".overflowdiv{overflow:hidden;word-break:break-all;white-space:nowrap;margin:0px 0px 0px 0px;}" & vbcrlf & ".overflowdivSum{overflow:hidden;word-break:break-all;white-space:nowrap;margin:0px 0px 0px 0px;}" & vbcrlf & ".searchInput{height:19px;font-size:9pt;text-align:left;}" & vbcrlf & ".toolitem_hover{" & vbcrlf & "    background-color:#0A246A;" & vbcrlf & "}" & vbcrlf & ".toolitem{" & vbcrlf & "    background-color:transparent;" & vbcrlf & "}" & vbcrlf & "#ScroTop{" & vbcrlf & " position:absolute;" & vbcrlf & "      top:0px;" & vbcrlf & "        left:10px;" & vbcrlf & " right:10px;" & vbcrlf & "     height:100%;" & vbcrlf & ""
			If set_MinWidth<>"" Then
				Response.write "" & vbcrlf & "              min-width:"
'If set_MinWidth<>"" Then
				Response.write set_MinWidth
				Response.write ";" & vbcrlf & "             width:expression(document.body.clientWidth < """
				Response.write Left(set_MinWidth,Len(set_MinWidth)-2)
				Response.write ";" & vbcrlf & "             width:expression(document.body.clientWidth < """
				Response.write """ ? """
				Response.write set_MinWidth
				Response.write """ : ""auto"");" & vbcrlf & ""
			else
				Response.write "" & vbcrlf & "              width:auto;" & vbcrlf & ""
			end if
			Response.write "" & vbcrlf & "}" & vbcrlf & "html{" & vbcrlf & "scrollbar-face-color: #feffff;scrollbar-highlight-color: white;scrollbar-3dlight-color:#8096ad;scrollbar-darkshadow-color: white;scrollbar-shadow-color:#8096ad;scrollbar-arrow-color:#8096ad;scrollbar-track-color:white;" & vbcrlf & "}     " & vbcrlf &"</style>" & vbcrlf & "<script language=""JavaScript"">" & vbcrlf & "      window.isGatherListPage = 1; //标记加载该类 (setup.js 做判断条件)" & vbcrlf & "       var tipsOpen="
			Response.write lcase(request.cookies("showTips_"&me.FieldsSettingIndex)="true")
			Response.write ";//提示开关；" & vbcrlf & " var mFieldsSettingIndex = "
			Response.write me.FieldsSettingIndex
			Response.write ";" & vbcrlf & "     var script_name = """
			Response.write request("script_name")
			Response.write """;" & vbcrlf & " function isint(str) " & vbcrlf & "    { " & vbcrlf & "              var result=str.match(/^(-|\+)?\d+$/); " & vbcrlf & "          if(result==null) return str=1; " & vbcrlf & "         if (str<2147483647)" & vbcrlf & "             {" & vbcrlf & "                 return str;" & vbcrlf & "           }else{" & vbcrlf & "            return 1;" & vbcrlf & "              }" & vbcrlf & "       }" & vbcrlf & "</script>" & vbcrlf & "<script language=""JavaScript"" type=""text/JavaScript"" src='../inc/GatherListClass.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "</head>" & vbcrlf & "<body bgcolor=""#ebebeb"" onmousemove=""MouseMoveToResize(event);"" onmouseup=""MouseUpToResize();"">" & vbcrlf & ""
			If DisableProgressBar = false then
				Call InitReportBar(title)
			else
				Call DisReportBar()
			end if
		end sub
		Sub getShowFieldsWidth()
			Err.Clear
			on error resume next
			Dim intro, FieldsOrder, rs, i, sortsql, rstmp
			Me.firstSumColumn = 0
			Me.lastSumLable = 0
			cookieWidth = request.cookies("cookieWidth_"&Me.FieldsSettingIndex)
			If cookieWidth<>"" Then cWidth = Split(cookieWidth, ",")
			Set rs = server.CreateObject("adodb.recordset")
			If isGroup="" Then isGroup=False
			If isGroup Then
				sortsql =Replace(Replace(Replace(Replace(baseSQL, "PAGE_COUNT_NUM", "top 0 *"), "PAGE_TOP_NUM", ""), "PAGE_ORDER_STR", ""),"1=1","1=2")
			else
				sortsql = Replace(Replace(Replace(baseSQL, "PAGE_COUNT_NUM", "top 0 *"), "PAGE_TOP_NUM", ""), "PAGE_ORDER_STR", "")&" and 1=2"
			end if
			rs.Open sortsql, conn, 1, 1
			Set rsHeader = rs
			If Err.Number<>0 Then Call ThrowException(Err.Description, sortsql)
			ReDim RealFieldsList(rs.Fields.Count -1)
'If Err.Number<>0 Then Call ThrowException(Err.Description, sortsql)
			For i = 0 To rs.Fields.Count -1
'If Err.Number<>0 Then Call ThrowException(Err.Description, sortsql)
				RealFieldsList(i) = rs.Fields(i).Name
			next
			sql = "select * from setjm3 where ord="&Me.FieldsSettingIndex&" and cateid=" & session("personzbintel2007")
			Set rstmp = conn.Execute(sql)
			If rstmp.EOF=True Then
				intro = ""
				For i = 0 To rs.fields.Count -1
'intro = ""
					If InStr(1, rs.fields(i).Name, "_ID", 1)<= 0 Then
						If intro = "" Then
							intro = i
						else
							intro = intro&","&i
						end if
					end if
				next
				conn.Execute "if exists(SELECT * FROM syscolumns WHERE NAME='intro' AND id=OBJECT_ID('setjm3') AND length<500) ALTER TABLE setjm3 ALTER COLUMN intro nvarchar(500)"
				conn.Execute "insert into setjm3(ord,cateid,intro) values("&Me.FieldsSettingIndex&","&session("personzbintel2007")&",'"&intro&"')"
			else
				If validateIntro(rs.fields.count,rstmp("intro"))=True Then
					intro = rstmp("intro")
				else
					FieldsOrder = ""
					For i = 0 To rs.fields.Count -1
'FieldsOrder = ""
						If FieldsOrder = "" Then
							FieldsOrder = i
						else
							FieldsOrder = FieldsOrder&","&i
						end if
					next
					response.cookies("cookieWidth_"&Me.FieldsSettingIndex) = ""
					cWidth = Split("", ",")
					conn.execute "update setjm3 set intro='" & FieldsOrder & "' where ord="&(Me.FieldsSettingIndex)&" and cateid=" & session("personzbintel2007")
				end if
			end if
			Me.intro = intro
			rstmp.Close
			Set rstmp = Nothing
			sql = "select * from setjm3 where ord="&(Me.FieldsSettingIndex + 10000)&" and cateid=" & session("personzbintel2007")
'Set rstmp = Nothing
			Set rstmp = conn.Execute(sql)
			If rstmp.eof = False Then
				If validateIntro(rs.fields.count,rstmp("intro"))=True Then
					FieldsOrder = rstmp("intro")
				else
					FieldsOrder = ""
					For i = 0 To rs.fields.Count -1
'FieldsOrder = ""
						If FieldsOrder = "" Then
							FieldsOrder = i
						else
							FieldsOrder = FieldsOrder&","&i
						end if
					next
					response.cookies("cookieWidth_"&Me.FieldsSettingIndex) = ""
					cWidth = Split("", ",")
					conn.execute "update setjm3 set intro='" & FieldsOrder & "' where ord="&(Me.FieldsSettingIndex + 10000)&" and cateid=" & session("personzbintel2007")
'cWidth = Split("", ",")
				end if
			else
				FieldsOrder = ""
				For i = 0 To rs.fields.Count -1
'FieldsOrder = ""
					If FieldsOrder = "" Then
						FieldsOrder = i
					else
						FieldsOrder = FieldsOrder&","&i
					end if
				next
				response.cookies("cookieWidth_"&Me.FieldsSettingIndex) = ""
				cWidth = Split("", ",")
				conn.Execute "insert into setjm3(ord,cateid,intro) values("&(Me.FieldsSettingIndex + 10000)&","&session("personzbintel2007")&",'"&FieldsOrder&"')"
'cWidth = Split("", ",")
			end if
			dim ford
			ford = split(FieldsOrder & "",",")
			for i = 0 to ubound(ford)
				if len(ford(i)) > 0 and isnumeric(ford(i)) = false then
					FieldsOrder = ""
					exit for
				end if
			next
			Me.FieldsOrder = FieldsOrder
			Dim FCount
			FCount = UBound(Split(FieldsOrder, ",")) + 1
'Dim FCount
			If FCount<>rs.fields.Count Then
				response.cookies("cookieWidth_"&Me.FieldsSettingIndex) = ""
				conn.Execute "delete setjm3 where cateid="&session("personzbintel2007")&" and (ord="&(Me.FieldsSettingIndex + 10000)&" or ord="&Me.FieldsSettingIndex&")"
'response.cookies("cookieWidth_"&Me.FieldsSettingIndex) = ""
				ReDim cWidth(UBound(Me.arrFields))
				FieldsOrder = ""
				For i = 0 To rs.fields.Count -1
'FieldsOrder = ""
					If FieldsOrder = "" Then
						FieldsOrder = i
					else
						FieldsOrder = FieldsOrder&","&i
					end if
				next
				response.cookies("cookieWidth_"&Me.FieldsSettingIndex) = ""
				cWidth = Split("", ",")
				conn.Execute "insert into setjm3(ord,cateid,intro) values("&(Me.FieldsSettingIndex + 10000)&","&session("personzbintel2007")&",'"&FieldsOrder&"')"
'cWidth = Split("", ",")
				Me.FieldsOrder = FieldsOrder
			end if
			Me.arrFields = Split(Me.FieldsOrder, ",")
			For i = 0 To UBound(Me.arrFields)
				Me.arrFields(i) = CInt(Me.arrFields(i))
			next
			rstmp.Close
			Set rstmp = Nothing
			set rs = nothing
			On Error GoTo 0
		end sub
		Function validateIntro(fieldCnt,strIntro)
			Dim arrIntro : arrIntro = Split(strIntro,",")
			Dim i
			For i = 0 To ubound(arrIntro)
				If CInt(arrIntro(i)) > fieldCnt Then
					checkIntro = False
					Exit Function
				end if
			next
			checkIntro = True
		end function
		Sub getOrderBySQL
			on error resume next
			Err.Clear
			On Error GoTo 0
			Dim arrpx, px_1, px_2, sortsql, rs, sqlSum, tmpSort, i, arrsort, stype
			If px = "" Or InStr(1, px, "-", 1)<= 0 Then px = "0-1"
'Dim arrpx, px_1, px_2, sortsql, rs, sqlSum, tmpSort, i, arrsort, stype
			arrpx = Split(px, "_")
			Set rs = server.CreateObject("adodb.recordset")
			If isGroup="" Then isGroup=False
			If isGroup Then
				sqlsum = Replace(Replace(Replace(Replace(baseSQL, "PAGE_COUNT_NUM", "top 0 *"), "PAGE_TOP_NUM", ""), "PAGE_ORDER_STR", ""),"1=1","1=2")
			else
				sqlsum = Replace(Replace(Replace(baseSQL, "PAGE_COUNT_NUM", "top 0 *"), "PAGE_TOP_NUM", ""), "PAGE_ORDER_STR", "")&" and 1=2"
			end if
			rs.Open sqlsum, conn, 1, 1
			If Err.Number<>0 Then Call ThrowException(Err.Description, sqlsum)
			tmpSort = ""
			For i = 0 To UBound(arrpx)
				arrsort = Split(arrpx(i), "-")
'For i = 0 To UBound(arrpx)
				stype = ""
				If arrsort(1) = 1 Then
					stype = " desc"
				else
					stype = " asc"
				end if
				If tmpSort = "" Then
					tmpSort = "["&rs.fields(CInt(arrsort(0))).Name&"]" & stype
				else
					tmpSort = tmpSort&",["&rs.fields(CInt(arrsort(0))).Name &"]"& stype
				end if
			next
			Me.strOrder = tmpSort
			rs.close
			set rs = nothing
			On Error GoTo 0
		end sub
		Sub GetPageCount()
			Dim sortsql, rsCount
			on error resume next
			Err.Clear
			If isGroup="" Then isGroup=False
			If isGroup Then
				sortsql ="Select Count(1) From (" & Replace(Replace(Replace(Me.baseSQL, "PAGE_TOP_NUM ", ""), "PAGE_ORDER_STR", ""), "PAGE_COUNT_NUM", "*") & Me.strCondition &") TableCount"
			else
				sortsql = Replace(Replace(Replace(baseSQL, "PAGE_COUNT_NUM", "isnull(count(*),0)"), "PAGE_TOP_NUM", ""), "PAGE_ORDER_STR", "") & strCondition
			end if
			Set rsCount = conn.Execute(sortsql)
			If Err.Number<>0 Then Call ThrowException(Err.Description, sortsql)
			on error goto 0
			Me.RecordCount = rsCount(0)
			rsCount.Close
			Set rsCount = Nothing
			Me.PageCount = Me.RecordCount \ Me.PageSize
			If Me.RecordCount Mod Me.PageSize Then Me.PageCount = Me.PageCount + 1
'Me.PageCount = Me.RecordCount \ Me.PageSize
			If Me.CurrPage>Me.PageCount Then Me.CurrPage = Me.PageCount
		end sub
		Sub ShowGatherListContent()
			on error resume next
			Err.Clear
			Dim rs, CountHeadFoot, i,groupbyCountSql
			If Me.CurrPage<1 Then Me.CurrPage = 1
			If Me.CanProcPage Then
				Dim orderstr_temp : orderstr_temp = Me.strOrder
				If InStr(orderstr_temp, Me.PKName )=0 And Len(Me.PKName)>0 Then
					If Len(Trim(orderstr_temp&""))>0 Then orderstr_temp = orderstr_temp & ","
					orderstr_temp = orderstr_temp & Me.PKName
				end if
				sortsql = Replace(Replace(Replace(baseSQL, "PAGE_COUNT_NUM", "*"), "PAGE_TOP_NUM", "top "& Me.CurrPage * Me.PageSize ), "PAGE_ORDER_STR", " order by " & orderstr_temp ) & strCondition &_
				" and " & Me.PKName & " not in (" &_
				Replace(Replace(Replace(baseSQL, "PAGE_COUNT_NUM", "top "&(Me.CurrPage -1) * Me.PageSize&" "&Me.PKName), "PAGE_TOP_NUM", "top "& (Me.CurrPage -1) * Me.PageSize), "PAGE_ORDER_STR", " order by " & orderstr_temp ) & strCondition & ")"&_
				" and " & Me.PKName & " not in ( "&_
				"else"
				sortsql = Replace(Replace(Replace(Me.baseSQL, "PAGE_TOP_NUM ", ""), "PAGE_ORDER_STR", ""), "PAGE_COUNT_NUM", "*") & Me.strCondition & " order by " & Me.strOrder
				groupbyCountSql=Replace(Replace(Replace(Me.baseSQL, "PAGE_TOP_NUM ", ""), "PAGE_ORDER_STR", ""), "PAGE_COUNT_NUM", "*") & Me.strCondition
			end if
			If Me.ShowDebug Then Response.write sortsql
			conn.CursorLocation=3
			Set rs = server.CreateObject("adodb.recordset")
			rs.Open sortsql, conn, 1, 1
			If Err.Number<>0 Then Call ThrowException(Err.Description, sortsql)
			on error goto 0
			If Not Me.CanProcPage And Not rs.EOF Then
				rs.PageSize = Me.PageSize
				rs.AbsolutePage = Me.CurrPage
			end if
			CountHeadFoot = 2
			If Me.CanTotalSum Then CountHeadFoot = CountHeadFoot + 1
'CountHeadFoot = 2
			If Me.CanPageSum Then CountHeadFoot = CountHeadFoot + 1
'CountHeadFoot = 2
			If Me.RecordCount Mod Me.PageSize > 0 Then
				If Me.CurrPage<>Me.PageCount Then
					Me.TotalProgress = rs.Fields.Count * Me.PageSize+(rs.Fields.Count * CountHeadFoot)
'If Me.CurrPage<>Me.PageCount Then
				else
					Me.TotalProgress = rs.Fields.Count * (Me.RecordCount Mod Me.PageSize) + (rs.Fields.Count * CountHeadFoot)
'If Me.CurrPage<>Me.PageCount Then
				end if
			else
				If Me.RecordCount = 0 Then
					Me.TotalProgress = rs.Fields.Count * CountHeadFoot
				else
					Me.TotalProgress = rs.Fields.Count * Me.PageSize+(rs.Fields.Count * CountHeadFoot)
					Me.TotalProgress = rs.Fields.Count * CountHeadFoot
				end if
			end if
			Dim FieldIsID, FieldVisible, FieldCanSum, FieldCanFormat, NoIDCount, FieldCount, sumSql, sumFlg
			ReDim FieldIsID(rs.fields.Count -1)
'Dim FieldIsID, FieldVisible, FieldCanSum, FieldCanFormat, NoIDCount, FieldCount, sumSql, sumFlg
			ReDim FieldVisible(rs.fields.Count -1)
'Dim FieldIsID, FieldVisible, FieldCanSum, FieldCanFormat, NoIDCount, FieldCount, sumSql, sumFlg
			ReDim FieldCanSum(rs.fields.Count -1)
'Dim FieldIsID, FieldVisible, FieldCanSum, FieldCanFormat, NoIDCount, FieldCount, sumSql, sumFlg
			ReDim FieldCanFormat(rs.fields.Count -1)
'Dim FieldIsID, FieldVisible, FieldCanSum, FieldCanFormat, NoIDCount, FieldCount, sumSql, sumFlg
			NoIDCount = 0
			For i = 0 To UBound(Me.arrFields)
				If InStr(1, rs.fields(CInt(Me.arrFields(i))).Name, "_ID", 1)>0 or (Me.FieldsSettingIndex=80015 and instr(rs.fields(CInt(Me.arrFields(i))).Name,"客户编号")>0) Then
					FieldIsID(i) = True
				else
					FieldIsID(i) = False
				end if
				If IsInList(Me.intro, Me.arrFields(i), ",") And IsInList(Me.HideFields,rs.fields(CInt(Me.arrFields(i))).Name,",") = False Then
					FieldVisible(i) = True
				else
					FieldVisible(i) = False
				end if
				If CanSum(rs.fields(CInt(Me.arrFields(i))).Name) Then
					FieldCanSum(i) = True
				else
					FieldCanSum(i) = False
				end if
				If CanFormatNumber(rs.fields(CInt(Me.arrFields(i))).Name) Then
					FieldCanFormat(i) = True
				else
					FieldCanFormat(i) = False
				end if
				If Not FieldIsID(i) And FieldVisible(i) Then
					FieldCount = FieldCount + 1
'If Not FieldIsID(i) And FieldVisible(i) Then
					NoIDCount = NoIDCount + 1
'If Not FieldIsID(i) And FieldVisible(i) Then
				end if
				If Me.firstSumColumn = 0 And IsInList(Me.intro, Me.arrFields(i), ",") And CanSum(rs.fields(CInt(Me.arrFields(i))).Name) Then
					Me.firstSumColumn = i
				end if
			next
			Response.write "" & vbcrlf & "<div id=""ScroTop"">" & vbcrlf & "<table width=""100%"" id=""tableid"" border=""0"" align=""left"" cellpadding=""0"" cellspacing=""0"" >" & vbcrlf & "       <tr>" & vbcrlf & "            <td width=""100%"" valign=""top"">" & vbcrlf & "                      <form method=""get"" action="""" id=""demo"" name=""date""style=""margin:0"">" & vbcrlf & "                    <table width=""100%"" style='table-layout:fixed' cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "                               <tr>" & vbcrlf & "                                    <td class=""place"" style='width:320px;'>"
			Me.firstSumColumn = i
			Response.write me.title
			Response.write "</td>" & vbcrlf & "                                        <td style='width:120px;'>&nbsp;" & vbcrlf & ""
			If Me.CanPX = "" Or Me.CanPX = True Then
				Response.write "<a class='sortRule' style='position:relative;top:2px;font-weight:bold' href='javascript:void(0)' onClick=""Myopen('sort_pannel');return false;"">排序规则<img src='../images/i10.gif' width=9 height=5 border=0></a>"
'If Me.CanPX = "" Or Me.CanPX = True Then
			end if
			Response.write "" & vbcrlf & "                                     </td>" & vbcrlf & "                                   <td align=""right"">" & vbcrlf & ""
			if Me.showTS then
				Response.write "" & vbcrlf & "                                             <input type=""checkbox"" name=""tips_open"" value=""1"""
				if request.cookies("showTips_"&me.FieldsSettingIndex)="true" then Response.write " checked"
				Response.write " onClick=""tipsOpen=this.checked;SetCookie('showTips_"
				Response.write me.FieldsSettingIndex
				Response.write "',tipsOpen);"">提示" & vbcrlf & ""
			end if
			if Me.IfShowPx then
				Response.write "<input type=""button"" value=""顺序"" onClick=""OrderDialog();"" class=""anybutton"" style=""margin:0 1;"" />"
			end if
			if Me.showxs then
				Response.write "<input type=""button"" value=""显示"" onClick=""FieldDialog();"" class=""anybutton"" style=""margin:0 1;"" />"
			end if
			if Me.showcz then
				Response.write("<input type=""button"" value=""重置"" onClick=""if(confirm('确定要重置列宽吗？')){DelCookie('cookieWidth_" & Me.FieldsSettingIndex & "');gotourl('');}"" class=""anybutton"" style=""margin:0 1;""/>")
			end if
			If SubExists("CurstomTitleLine") Then CurstomTitleLine
			Response.write "" & vbcrlf & "                                     </td>" & vbcrlf & "                                   <td width=""4""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "                              </tr>" & vbcrlf & "                           <tr   class=""ser_top resetHeadBg"">" & vbcrlf & "                                  <td colspan=""4"" height=""50px"" valign=""middle"" style='border:0px;/*border-top:1px solid #C3CEDF;统计-采购产品追踪表线条粗；*/'>" & vbcrlf & "                    <div style=""float:left;padding-left:4px; "
'If SubExists("CurstomTitleLine") Then CurstomTitleLine
			If Me.DelBatch = False And Me.showPage1= False Then Response.write "display:none;"
			Response.write """>" & vbcrlf & ""
			If Me.DelBatch = True Then
				If HasPower(Me.QxSort1, 3) Then
					Response.write "<input name=""DelList"" class=""anybutton2"" onClick=""if(confirm('确定删除所选？')){DelBatch();}""  value=""批量删除"" type=""button"">"
				end if
			end if
			if Me.showPage1=True then
				if me.currpage=1 then
					Response.write "<img class='resetElementHidden' src='../images/smico/pg5disabled.gif' title='首页' onMouseOver='tm(this);' onMouseOut='tu(this);' style='cursor:pointer;vertical-align:middle'><img class='resetElementShow' src='../skin/default/images/ico16/lvwbar_1_1.png' title='首页' onMouseOver='tm(this);' onMouseOut='tu(this);' style='cursor:pointer;vertical-align:middle;display:none;margin:0 2px;'>"
'if me.currpage=1 then
					Response.write "<img class='resetElementHidden' src='../images/smico/pg3disabled.gif' title='上页' onMouseOver='tm(this);' onMouseOut='tu(this);' style='cursor:pointer;vertical-align:middle'><img class='resetElementShow' src='../skin/default/images/ico16/lvwbar_2_1.png' title='上页' onMouseOver='tm(this);' onMouseOut='tu(this);' style='cursor:pointer;vertical-align:middle;display:none;margin:0 2px;'>"
'if me.currpage=1 then
				else
					Response.write "<img class='resetElementHidden' src='../images/smico/pg5.gif' title='首页' onMouseOver='tm(this);' onMouseOut='tu(this);' style='cursor:pointer;vertical-align:middle' onClick=""gotourl('currPage=1');"">"
'if me.currpage=1 then
					Response.write "<img class='resetElementHidden' src='../images/smico/pg3.gif' title='上页' onMouseOver='tm(this);' onMouseOut='tu(this);' style='cursor:pointer;vertical-align:middle' onClick=""gotourl('currPage=" & (me.currpage-1) & "');"">"
'if me.currpage=1 then
					Response.write "<img class='resetElementShow' src='../skin/default/images/ico16/lvwbar_1_1.png' title='首页' onMouseOver='tm(this);' onMouseOut='tu(this);' style='cursor:pointer;vertical-align:middle;margin:0 2px;' onClick=""gotourl('currPage=1');"">"
'if me.currpage=1 then
					Response.write "<img class='resetElementShow' src='../skin/default/images/ico16/lvwbar_2_1.png' title='上页' onMouseOver='tm(this);' onMouseOut='tu(this);' style='cursor:pointer;vertical-align:middle;margin:0 2px' onClick=""gotourl('currPage=" & (me.currpage-1) & "');"">"
'if me.currpage=1 then
				end if
				if me.currpage=me.pagecount or RecordCount=0 then
					Response.write "<img class='resetElementHidden' src='../images/smico/pg2disabled.gif' style='cursor:pointer;vertical-align:middle'><img class='resetElementShow' src='../skin/default/images/ico16/lvwbar_3_1.png' style='cursor:pointer;vertical-align:middle;display:none;margin:0 2px;'><img class='resetElementHidden' src='../images/smico/pg4disabled.gif' style='cursor:pointer;vertical-align:middle'><img class='resetElementShow' src='../skin/default/images/ico16/lvwbar_4_1.png' style='cursor:pointer;vertical-align:middle;display:none;margin:0 2px;'>"
'if me.currpage=me.pagecount or RecordCount=0 then
				else
					Response.write "<img class='resetElementHidden' src='../images/smico/pg2.gif' title='下页' onMouseOver='tm(this)' onMouseOut='tu(this)' style='cursor:pointer;vertical-align:middle' onClick=""gotourl('currPage=" & (me.currpage+1) & "');"">"
'if me.currpage=me.pagecount or RecordCount=0 then
					Response.write "<img class='resetElementHidden' src='../images/smico/pg4.gif' title='尾页' onMouseOver='tm(this)' onMouseOut='tu(this)' style='cursor:pointer;vertical-align:middle' onClick=""gotourl('currPage="& me.PageCount &"');"">"
'if me.currpage=me.pagecount or RecordCount=0 then
					Response.write "<img class='resetElementShow' src='../skin/default/images/ico16/lvwbar_3_1.png' title='下页' onMouseOver='tm(this)' onMouseOut='tu(this)' style='cursor:pointer;vertical-align:middle;margin:0 2px' onClick=""gotourl('currPage=" & (me.currpage+1) & "');"">"
'if me.currpage=me.pagecount or RecordCount=0 then
					Response.write "<img class='resetElementShow' src='../skin/default/images/ico16/lvwbar_4_1.png' title='尾页' onMouseOver='tm(this)' onMouseOut='tu(this)' style='cursor:pointer;vertical-align:middle;margin:0 2px' onClick=""gotourl('currPage="& me.PageCount &"');"">"
'if me.currpage=me.pagecount or RecordCount=0 then
				end if
				Response.write "" & vbcrlf & "                        <input size=3 type=text id=""jmppage1"" name=""currPage"" onKeyUp=""value=isint(value)"" onBlur=""value=isint(value)"" >&nbsp;<input type=""button"" value=""跳转"" onClick=""gotourl('currPage='+document.getElementById('jmppage1').value)""  class=""anybutton2""/>" & vbcrlf & " "
			end if
			Response.write "" & vbcrlf & "                    </div>" & vbcrlf & "                    <div style=""text-align:right;padding-top:1px;overflow:hidden"">" & vbcrlf & ""
'"/> & vbcrlf
			If SubExists("CurstomButtons") Then CurstomButtons
			Response.write "" & vbcrlf & "                    </div>" & vbcrlf & "                             </td>" & vbcrlf & "                     </tr>" & vbcrlf & "                       </table>" & vbcrlf & "                        </form>" & vbcrlf & "                 <table "
			if me.cookieWidth="" then
				Response.write "width=""100%"""
			end if
			Response.write " jsflg=""1"" border=""0"" style=""table-layout:fixed"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "                           <tr class=""top resetGroupTableBg"" valign=""center"" id=""TH1"">" & vbcrlf & ""
			'Response.write "width=""100%"""
			Dim zdyarr, i_col, col_flg, strDisplay, strwidth, txalign, FieldTitle, iCount, iLoop, zdyidx, className, IsCanSum, sqlSum, arrph, pxlist
			Dim tmparr, strPXDisplay, CanMove, descColor, ascColor, moveStyle, firstflg
			If Me.zdylist<>"" Then
				zdyarr = Split(Me.zdylist, ",")
				zdyidx = 0
			end if
			sumSql = ""
			sumFlg = False
			Dim sumPage
			Dim headArr
			redim headArr(UBound(Me.arrfields))
			ReDim sumPage(UBound(Me.arrFields))
			dim FieldsTmpStr,CanCospan,ifCospan,level2Tr
			redim CanCospan(UBound(Me.arrfields))
			ifCospan=0
			k=0
			for i=0 to Ubound(Me.arrFields)
				If FieldIsID(i) Or Not FieldVisible(i) Then
					strDisplay = ";display:none"
				else
					strDisplay = ""
				end if
				FieldsTmpStr=rs.fields(CInt(Me.arrFields(i))).Name
				if instr(FieldsTmpStr,"_数量")>0 or instr(FieldsTmpStr,"_金额")>0 then
					ifCospan=1
					CanCospan(i)=true
					if instr(FieldsTmpStr,"_数量")>0 then
						level2Tr=level2Tr&"<td align='right' id='headField_child"&k&"_1' style=""text-align:center"&strDisplay&strwidth&""">数量</td>"&vbcrlf & ""
'if instr(FieldsTmpStr,"_数量")>0 then
					else
						level2Tr=level2Tr&"<td align='right' id='headField_child"&k&"_1' style=""text-align:center"&strDisplay&strwidth&""">金额</td>"&vbcrlf & ""
'if instr(FieldsTmpStr,"_数量")>0 then
					end if
				else
					CanCospan(i)=false
				end if
				k=k+1
				CanCospan(i)=false
			next
			FieldsTmpStr=""
			ReDim sumPage(UBound(Me.arrFields))
			dim k,colspans
			k=0
			colspans=0
			For i = 0 To UBound(Me.arrFields)
				Me.ProgressNow = Me.ProgressNow + 1
'For i = 0 To UBound(Me.arrFields)
				If FieldCanSum(i) Then
					If sumFlg = False Then
						sumSql = sumSql&" sum(["&rs.fields(CInt(Me.arrFields(i))).Name&"]) as sum"&i
						sumFlg = True
					else
						sumSql = sumSql&",sum(["&rs.fields(CInt(Me.arrFields(i))).Name&"]) as sum"&i
					end if
					sumPage(i) = "0"
				else
					If sumFlg = False Then
						sumSql = sumSql&" '' as sum"&i
						sumFlg = True
					else
						sumSql = sumSql&",'' as sum"&i
					end if
					sumPage(i) = ""
				end if
				If i<Me.firstSumColumn And Not FieldIsID(i) And FieldVisible(i) Then Me.lastSumLable = i
				If FieldIsID(i) Or Not FieldVisible(i) Then
					strDisplay = ";display:none"
				else
					strDisplay = ""
				end if
				If Me.cookieWidth<>"" Then
					If i>UBound(Me.cWidth) Then
						strwidth = ";width:100px"
					else
						strwidth = ";width:"&Me.cWidth(i)&"px"
					end if
				else
					strwidth = ""
				end if
				If InStr(1, rs.fields(CInt(Me.arrFields(i))).Name, "_自定义字段")>0 Then
					FieldTitle = zdyarr(zdyidx)
					zdyidx = zdyidx + 1
'FieldTitle = zdyarr(zdyidx)
				else
					FieldTitle = replaceDefineName(rs.fields(CInt(Me.arrFields(i))).Name)
				end if
				if FieldTitle = "操作" then
					if strwidth = "" then strwidth = ";width:130px;"
				end if
				If DelBatch = True And FieldTitle = DelID Then
					Response.write("<td valign=""middle"" style=""text-align:left"& strDisplay&strwidth &"""><div >&nbsp;<input type=""checkbox"" style=""cursor: auto;"" name=""Del_Batch"" id=""Del_Batch"" value=""1"" />&nbsp;"& FieldTitle &"</div></td>")
'If DelBatch = True And FieldTitle = DelID Then
				else
					if ifCospan=1 then
						if CanCospan(i) then
							if Ubound(split(FieldTitle,"_"))=2 then
								FieldsTmpStr2=split(FieldTitle,"_")(0)&split(FieldTitle,"_")(2)
							else
								FieldsTmpStr2=split(FieldTitle,"_")(0)
							end if
							if FieldsTmpStr<>FieldsTmpStr2 then
								If (FieldIsID(i) Or Not FieldVisible(i)) and colspans=0 Then
									if (i+1)<UBound(Me.arrFields) then
'If (FieldIsID(i) Or Not FieldVisible(i)) and colspans=0 Then
										If (FieldIsID(i+1) Or Not FieldVisible(i+1)) and CanCospan(i+1) Then
'If (FieldIsID(i) Or Not FieldVisible(i)) and colspans=0 Then
											colspans=0
										else
											colspans=1
											strDisplay=""
										end if
									else
										colspans=1
									end if
								else
									FieldsTmpStr3=replaceDefineName(rs.fields(CInt(Me.arrFields(i+1))).Name)
									colspans=1
									FieldsTmpStr4=replaceDefineName(rs.fields(CInt(Me.arrFields(i-1))).Name)
'colspans=1
									if Ubound(split(FieldsTmpStr3,"_"))=2 then
										FieldsTmpStr3=split(FieldsTmpStr3,"_")(0)&split(FieldsTmpStr3,"_")(2)
									else
										FieldsTmpStr3=split(FieldsTmpStr3,"_")(0)
									end if
									if Ubound(split(FieldsTmpStr4,"_"))=2 then
										FieldsTmpStr4=split(FieldsTmpStr4,"_")(0)&split(FieldsTmpStr4,"_")(2)
									else
										FieldsTmpStr4=split(FieldsTmpStr4,"_")(0)
									end if
									if FieldsTmpStr3=FieldsTmpStr2 and ((FieldIsID(i+1) Or Not FieldVisible(i+1)) and CanCospan(i+1)) then
										FieldsTmpStr4=split(FieldsTmpStr4,"_")(0)
										colspans=1
										strDisplay=""
									elseif FieldsTmpStr4=FieldsTmpStr2 and ((FieldIsID(i-1) Or Not FieldVisible(i-1)) and CanCospan(i-1)) then
										strDisplay=""
										colspans=1
'strDisplay=""
									else
										if OnlyShowMoneyOrNum=1 or OnlyShowMoneyOrNum=2 then
											colspans=1
										else
											colspans=2
										end if
									end if
									FieldsTmpStr=FieldsTmpStr2
									Response.write "" & vbcrlf & "                                                             <td valign=""middle"" style=""text-align:center"
'FieldsTmpStr=FieldsTmpStr2
									Response.write strDisplay&strwidth
									Response.write """ colspan='"
									Response.write colspans
									Response.write "' id=""headField_"
									Response.write i
									Response.write """><div class=""overflowdiv"">"
									Response.write FieldsTmpStr
									Response.write "</div></td>" & vbcrlf & ""
								end if
							else
								Response.write "" & vbcrlf & "                                                      <span id=""headField_"
								Response.write i
								Response.write """></span>" & vbcrlf & ""
								colspans=0
							end if
						else
							Response.write "" & vbcrlf & "                                              <td valign=""middle"" style=""text-align:center"
							colspans=0
							Response.write strDisplay&strwidth
							Response.write """ rowspan='2' id=""headField_"
							Response.write i
							Response.write """><div class=""overflowdiv"">"
							Response.write FieldTitle
							Response.write "</div></td>" & vbcrlf & ""
						end if
					else
						Response.write "" & vbcrlf & "                      <td valign=""middle"" style=""text-align:center"
						Response.write "</div></td>" & vbcrlf & ""
						Response.write strDisplay&strwidth
						Response.write """ id=""headField_"
						Response.write i
						Response.write """><div class=""overflowdiv"">"
						Response.write FieldTitle
						Response.write "</div></td>" & vbcrlf & ""
					end if
				end if
				k=k+1
				Response.write "</div></td>" & vbcrlf & ""
			next
			if Me.FieldsSettingIndex=80015 Then
				Response.write "" & vbcrlf & "                      <td colspan=""2"" rowspan=""2"" style=""display:none""></td>" & vbcrlf & ""
			end if
			Response.write "" & vbcrlf & "              </tr>" & vbcrlf & ""
			Dim cot
			If ifCospan=1 then Response.write "<tr>"&level2Tr&"</tr>"
			cot = Me.RecordCount
			If cot<= 0 Then
				Response.write "<tr><td colspan='"&NoIDCount&"'>没有信息!</td></tr></table>"
			else
				iCount = 1
				iLoop = 1
				CellNum = 1
				procCount =  Me.PageSize
				If procCount > cot then  procCount = cot
				procCount = procCount + 3 + Me.CanTotalSum*3
'If procCount > cot then  procCount = cot
				While Not rs.EOF And CLng(iLoop) <= CLng(Me.PageSize)
					Response.write "<tr valign=""top"" onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">"
					zdyidx = 0
					Call doProc(procCount, iCount)
					For i = 0 To UBound(Me.arrFields)
						If FieldIsID(i) Or Not FieldVisible(i) Then
							strDisplay = ";display:none"
						else
							strDisplay = ""
						end if
						If FieldCanSum(i) Then
							If Len(rs.fields(CInt(Me.arrFields(i))).Value&"")>0 Then
								sumPage(i) = CDbl(sumPage(i)) + CDbl(rs.fields(CInt(Me.arrFields(i))).Value)
'If Len(rs.fields(CInt(Me.arrFields(i))).Value&"")>0 Then
							end if
							className = "overflowdivSum"
							txalign = "right"
							IsCanSum = True
						else
							If FieldCanFormat(i) Then
								className = "overflowdivSum"
								txalign = "right"
							else
								className = "overflowdiv"
								txalign = "left"
							end if
							IsCanSum = False
						end if
						Response.write "<td valign=middle id=td_" & iCount & "_" & i & " class=" & className & " onMouseOver='showTips(this,true)' onMouseOut='showTips(this,false);' style='text-align:" & txalign & strDisplay & "'>"
						IsCanSum = False
						If DelBatch = True And Me.arrFields(i) = 1 And Me.FiledAdd<>"" And QxSort1<>"" Then
							If CanDelete(QxSort1, rs.fields((Me.FiledAdd)).Value) = False Then
								Response.write "<div align=""left""> <input type=""checkbox"" disabled=""disabled"" title=""没有此信息的删除权限"" name=""NoPower_Del_Item_List"" Class=""NoPower_Del_Item_List"" value="""& rs.fields(CInt(Me.arrFields(i))).Value &"""></div>"
							else
								Response.write "<div align=""left""> <input type=""checkbox"" name=""Del_Item_List"" Class=""Del_Item_List"" value="""& rs.fields(CInt(Me.arrFields(i))).Value &"""></div>"
							end if
						else
							If CustomShowFields_Exists Then
								Call CustomShowFields(CInt(Me.arrFields(i)), rs.fields)
							else
								If CanFormatNumber(rs.fields(CInt(Me.arrFields(i))).Name) Then
									Response.write myFormatNumber(rs.fields(CInt(Me.arrFields(i))).Value, gather.digits, -1, 0, 0)
'If CanFormatNumber(rs.fields(CInt(Me.arrFields(i))).Name) Then
								else
									Response.write rs.fields(CInt(Me.arrFields(i))).Value
								end if
							end if
						end if
						Response.write "</td>"
					next
					if Me.FieldsSettingIndex=80015 Then
						Response.write "<td style='display:none'></td><td style='display:none'></td>"
					end if
					Response.write "</tr>"
					If Not Me.CanProcPage Then iLoop = iLoop + 1
					Response.write "</tr>"
					iCount = iCount + 1
					Response.write "</tr>"
					CellNum = CellNum + 1
					Response.write "</tr>"
					rs.movenext
				wend
				iCount = iCount + 1
				Response.write "</tr>"
				Call doProc(procCount, iCount)
				If Me.CanPageSum Then
					Response.write "<tr valign=top onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">"
					For i = 0 To UBound(Me.arrFields)
						If i = Me.lastSumLable Then
							Response.write "<td style='text-align:right'><div class='overflowdivSum'>本页合计：</div></td>"
'If i = Me.lastSumLable Then
						else
							If FieldIsID(i) Or Not FieldVisible(i) Then
								strDisplay = ";display:none"
							else
								strDisplay = ""
							end if
							Response.write "<td valign='middle' class='overflowdivSum' style='text-align:right" & strDisplay & "'><div class='overflowdivSum'>"
							strDisplay = ""
							If SubExists("CustomShowPageSumFields") Then
								Call CustomShowPageSumFields(rs.fields(CInt(Me.arrFields(i))).Name, sumPage(i))
							else
								If sumPage(i)<>"" Then
									haswrite = false
									If SubExists("CustomPageSumHandle") Then
										haswrite = CustomPageSumHandle(rs.fields(CInt(Me.arrFields(i))).Name, i, sumPage,rs)
									end if
									If haswrite = False Then
										If FieldCanFormat(i) And isnumeric(sumPage(i)) Then
											if instr(rs.fields(CInt(Me.arrFields(i))).Name,"_MONEY")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"金额")>0 then
												Response.write myFormatNumber(sumPage(i),digits_m,-1,0,0)
											else
												Response.write myFormatNumber(sumPage(i), digits, -1, 0, 0)
											end if
										else
											Response.write sumPage(i)
										end if
									end if
								end if
							end if
							Response.write "</div>"
							Response.write "</td>"
						end if
					next
					if Me.FieldsSettingIndex=80015 Then
						Response.write "<td style='display:none'></td><td style='display:none'></td>"
					end if
					Response.write "</tr>"
					If SubExists("CreateMoreSumRow") Then
						Call CreateMoreSumRow(Me,FieldIsID,FieldVisible,rs,0)
					end if
				end if
				iCount = iCount + 1
				Call CreateMoreSumRow(Me,FieldIsID,FieldVisible,rs,0)
				Call doProc(procCount, iCount)
				If Me.CanTotalSum Then
					Response.write "<tr valign='top' onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">"
					if len(trim(sumSql)) > 0 then
						sqlSum = Replace(Replace(Replace(Me.baseSQL, "PAGE_COUNT_NUM", sumSql), "PAGE_TOP_NUM", ""), "PAGE_ORDER_STR", "") & strCondition
						Set rsSum = conn.Execute(sqlsum)
						iCount = iCount + 1
'Set rsSum = conn.Execute(sqlsum)
						Call doProc(procCount, iCount)
						If Err.Number<>0 Then Call ThrowException(Err.Description, sqlSum)
						For i = 0 To UBound(Me.arrFields)
							If i = Me.lastSumLable Then
								Response.write "<td style='text-align:right'><div class='overflowdivSum'>总计：</div></td>"
'If i = Me.lastSumLable Then
							else
								If FieldIsID(i) Or Not FieldVisible(i) Then
									strDisplay = ";display:none"
								else
									strDisplay = ""
								end if
								Response.write "<td valign='middle' class='overflowdivSum' style='text-align:right" & strDisplay & "'>"
								strDisplay = ""
								Response.write "<div class='overflowdivSum'>"
								If SubExists("CustomShowTotalSumFields") Then
									Call CustomShowTotalSumFields(rs.fields(CInt(Me.arrFields(i))).Name,rsSum(i).Value& "")
									If SubExists("SumCount") Then Call SumCount(groupbyCountSql,rs.fields(CInt(Me.arrFields(i))).Name)
								ElseIf SubExists("CustomShowTotalSumFieldsEX") Then
									Call CustomShowTotalSumFieldsEX(rs.fields(CInt(Me.arrFields(i))).Name,rsSum(i).Value& "",rs.fields,i)
									If SubExists("SumCount") Then Call SumCount(groupbyCountSql,rs.fields(CInt(Me.arrFields(i))).Name)
								else
									If rsSum(i)<>"" Then
										If FieldCanFormat(i) Then
											if instr(rs.fields(CInt(Me.arrFields(i))).Name,"_MONEY")>0 or instr(rs.fields(CInt(Me.arrFields(i))).Name,"金额")>0 then
												Response.write myFormatNumber(rsSum(i).Value, Me.digits_m, -1, 0, 0)
											else
												Response.write myFormatNumber(rsSum(i).Value, Me.digits, -1, 0, 0)
											end if
										else
											Response.write rsSum(i).Value
										end if
									end if
								end if
								Response.write "</div>"
								Response.write "</td>"
							end if
						next
						rsSum.Close
						Set rsSum = Nothing
					end if
					Response.write "</tr>"
					If SubExists("CreateMoreSumRow") Then
						Call CreateMoreSumRow(Me,FieldIsID,FieldVisible,rs,1)
					end if
					iCount = iCount + 1
					Call CreateMoreSumRow(Me,FieldIsID,FieldVisible,rs,1)
					Call doProc(procCount, iCount)
				end if
				Response.write "</table>"
			End If
			Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td class=""page"">" & vbcrlf & "                         <table width=""100%"" border=""0"" align=""left"" background=""../images/m_mpbg.gif"" >" & vbcrlf & "                         <tr>" & vbcrlf & "                                    <td align=""left"">" & vbcrlf & ""
			if Me.showPage2=True Then
				if me.currpage=1 Then
					Response.write "" & vbcrlf & "                                             <img class='resetElementHidden'  onMouseOver='tm(this);' onMouseOut='tu(this);' title='首页' src='../images/smico/pg5disabled.gif' style='cursor:pointer;vertical-align:middle'><img class='resetElementShow'  onMouseOver='tm(this);' onMouseOut='tu(this);' title='首页' src='../skin/default/images/ico16/lvwbar_1_1.png' style='cursor:pointer;vertical-align:middle;display:none;margin:0 2px;'>" & vbcrlf & "                                             <img class='resetElementHidden'  onMouseOver='tm(this);' onMouseOut='tu(this);' title='上页' src='../images/smico/pg3disabled.gif' style='cursor:pointer;vertical-align:middle'><img class='resetElementShow'  onMouseOver='tm(this);' onMouseOut='tu(this);' title='上页' src='../skin/default/images/ico16/lvwbar_2_1.png' style='cursor:pointer;vertical-align:middle;display:none;margin:0 2px;'>" & vbcrlf & ""
'if me.currpage=1 Then
				else
					Response.write "" & vbcrlf & "                                             <img class='resetElementHidden' src=""../images/smico/pg5.gif"" title=""首页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                      style='cursor:pointer;vertical-align:middle' onClick=""gotourl('currPage="
'if me.currpage=1 Then
					Response.write 1
					Response.write "');"">" & vbcrlf & "                                             <img class='resetElementHidden' src=""../images/smico/pg3.gif"" title=""上页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                      style='cursor:pointer;vertical-align:middle' onClick=""gotourl('currPage="
					Response.write 1
					Response.write me.currpage-1
					Response.write 1
					Response.write "');"">" & vbcrlf & "                        <img class='resetElementShow' src=""../skin/default/images/ico16/lvwbar_1_1.png"" title=""首页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                 style='cursor:pointer;vertical-align:middle;margin:0 2px' onClick=""gotourl('currPage="
					Response.write 1
					Response.write "');"">" & vbcrlf & "                                             <img class='resetElementShow' src=""../skin/default/images/ico16/lvwbar_2_1.png"" title=""上页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                    style='cursor:pointer;vertical-align:middle;margin:0 2px' onClick=""gotourl('currPage="
					Response.write 1
					Response.write me.currpage-1
					Response.write 1
					Response.write "');"">" & vbcrlf & ""
				end if
				if me.currpage=me.pagecount or RecordCount=0 Then
					Response.write "" & vbcrlf & "                                             <img class='resetElementHidden' src='../images/smico/pg2disabled.gif' style='cursor:pointer;vertical-align:middle'><img class='resetElementShow' src='../skin/default/images/ico16/lvwbar_3_1.png' style='cursor:pointer;vertical-align:middle;display:none;margin:0 2px;'>" & vbcrlf & "                                            <img class='resetElementHidden' src='../images/smico/pg4disabled.gif' style='cursor:pointer;vertical-align:middle'><img class='resetElementShow' src='../skin/default/images/ico16/lvwbar_4_1.png' style='cursor:pointer;vertical-align:middle;display:none;margin:0 2px;'>" & vbcrlf & ""
'if me.currpage=me.pagecount or RecordCount=0 Then
				else
					Response.write "" & vbcrlf & "                                             <img class='resetElementHidden' src=""../images/smico/pg2.gif"" title=""下页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                      style='cursor:pointer;vertical-align:middle' onClick=""gotourl('currPage="
'if me.currpage=me.pagecount or RecordCount=0 Then
					Response.write me.currpage+1
'if me.currpage=me.pagecount or RecordCount=0 Then
					Response.write "');"">" & vbcrlf & "                                             <img class='resetElementHidden' src=""../images/smico/pg4.gif"" title=""尾页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                      style='cursor:pointer;vertical-align:middle' onClick=""gotourl('currPage="
'if me.currpage=me.pagecount or RecordCount=0 Then
					Response.write me.PageCount
					Response.write "');"">" & vbcrlf & "                        <img class='resetElementShow' src=""../skin/default/images/ico16/lvwbar_3_1.png"" title=""下页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                 style='cursor:pointer;vertical-align:middle;margin:0 2px' onClick=""gotourl('currPage="
					Response.write me.currpage+1
'ge="
					Response.write "');"">" & vbcrlf & "                                             <img class='resetElementShow' src=""../skin/default/images/ico16/lvwbar_4_1.png"" title=""尾页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                    style='cursor:pointer;vertical-align:middle;margin:0 2px' onClick=""gotourl('currPage="
'ge="
					Response.write me.PageCount
					Response.write "');"">" & vbcrlf & ""
				end if
				Response.write "" & vbcrlf & "                                             <input size=3 type=text id=""jmppage2"" name=""currPage"" onKeyUp=""value=isint(value)"" onBlur=""value=isint(value)"" >&nbsp;" & vbcrlf & "                                          <input type=""button"" value=""跳转"" onClick=""gotourl('currPage='+document.getElementById('jmppage2').value)"" class=""anybutton2""/>" & vbcrlf & ""
			end if
			If SubExists("CurstomBtmButtons") Then CurstomBtmButtons
			Response.write "" & vbcrlf & "                                     </td>" & vbcrlf & "                                   <td width=""50%"" align=""right"">" & vbcrlf & "                                              "
			Response.write me.RecordCount
			Response.write "个 | "
			Response.write me.CurrPage
			Response.write "/"
			Response.write me.PageCount
			Response.write "页 | &nbsp;"
			Response.write me.PageSize
			Response.write "条信息/页&nbsp;&nbsp;" & vbcrlf & ""
			if Me.showPage3=True Then
'if me.currpage=1 Then
				Response.write "" & vbcrlf & "                                             <img class='resetElementHidden'  onMouseOver='tm(this);' onMouseOut='tu(this);' title='首页' src='../images/smico/pg5disabled.gif' style='cursor:pointer;vertical-align:middle'><img class='resetElementShow'  onMouseOver='tm(this);' onMouseOut='tu(this);' title='首页' src='../skin/default/images/ico16/lvwbar_1_1.png' style='cursor:pointer;vertical-align:middle;display:none;margin:0 2px;'>" & vbcrlf & "                                             <img class='resetElementHidden'  onMouseOver='tm(this);' onMouseOut='tu(this);' title='上页' src='../images/smico/pg3disabled.gif' style='cursor:pointer;vertical-align:middle'><img class='resetElementShow'  onMouseOver='tm(this);' onMouseOut='tu(this);' title='上页' src='../skin/default/images/ico16/lvwbar_2_1.png' style='cursor:pointer;vertical-align:middle;display:none;margin:0 2px;'>" & vbcrlf & ""
				if me.currpage=1 Then
				else
					Response.write "" & vbcrlf & "                                             <img class='resetElementHidden' src=""../images/smico/pg5.gif"" title=""首页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                      style='cursor:pointer;vertical-align:middle' onClick=""gotourl('currPage="
'if me.currpage=1 Then
					Response.write 1
					Response.write "');"">" & vbcrlf & "                                             <img class='resetElementHidden' src=""../images/smico/pg3.gif"" title=""上页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                      style='cursor:pointer;vertical-align:middle' onClick=""gotourl('currPage="
					Response.write 1
					Response.write me.currpage-1
					Response.write 1
					Response.write "');"">" & vbcrlf & "                        <img class='resetElementShow' src=""../skin/default/images/ico16/lvwbar_1_1.png"" title=""首页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                 style='cursor:pointer;vertical-align:middle;margin:0 2px' onClick=""gotourl('currPage="
					Response.write 1
					Response.write "');"">" & vbcrlf & "                                             <img class='resetElementShow' src=""../skin/default/images/ico16/lvwbar_2_1.png"" title=""上页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                    style='cursor:pointer;vertical-align:middle;margin:0 2px' onClick=""gotourl('currPage="
					Response.write 1
					Response.write me.currpage-1
					Response.write 1
					Response.write "');"">" & vbcrlf & ""
				end if
				if me.currpage=me.pagecount or RecordCount=0 Then
					Response.write "" & vbcrlf & "                                             <img class='resetElementHidden' src='../images/smico/pg2disabled.gif' style='cursor:pointer;vertical-align:middle'><img class='resetElementShow' src='../skin/default/images/ico16/lvwbar_3_1.png' style='cursor:pointer;vertical-align:middle;display:none;margin:0 2px;'>" & vbcrlf & "                                            <img class='resetElementHidden' src='../images/smico/pg4disabled.gif' style='cursor:pointer;vertical-align:middle'><img class='resetElementShow' src='../skin/default/images/ico16/lvwbar_4_1.png' style='cursor:pointer;vertical-align:middle;display:none;margin:0 2px;'>" & vbcrlf & ""
'if me.currpage=me.pagecount or RecordCount=0 Then
				else
					Response.write "" & vbcrlf & "                                             <img class='resetElementHidden' src=""../images/smico/pg2.gif"" title=""下页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                      style='cursor:pointer;vertical-align:middle' onClick=""gotourl('currPage="
'if me.currpage=me.pagecount or RecordCount=0 Then
					Response.write me.currpage+1
'if me.currpage=me.pagecount or RecordCount=0 Then
					Response.write "');"">" & vbcrlf & "                                             <img class='resetElementHidden' src=""../images/smico/pg4.gif"" title=""尾页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                      style='cursor:pointer;vertical-align:middle' onClick=""gotourl('currPage="
'if me.currpage=me.pagecount or RecordCount=0 Then
					Response.write me.PageCount
					Response.write "');"">" & vbcrlf & "                        <img class='resetElementShow' src=""../skin/default/images/ico16/lvwbar_3_1.png"" title=""下页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                 style='cursor:pointer;vertical-align:middle;margin:0 2px;' onClick=""gotourl('currPage="
					Response.write me.currpage+1
'age="
					Response.write "');"">" & vbcrlf & "                                             <img class='resetElementShow' src=""../skin/default/images/ico16/lvwbar_4_1.png"" title=""尾页"" onMouseOver=""tm(this);"" onMouseOut=""tu(this);"" " & vbcrlf & "                                                    style='cursor:pointer;vertical-align:middle;margin:0 2px;' onClick=""gotourl('currPage="
'age="
					Response.write me.PageCount
					Response.write "');"">" & vbcrlf & ""
				end if
				Response.write "" & vbcrlf & "                                             <input size=3 type=text id=""jmppage3"" name=""currPage"" onKeyUp=""value=isint(value)"" onBlur=""value=isint(value)"" >&nbsp;" & vbcrlf & "                                          <input type=""button"" value=""跳转"" onClick=""gotourl('currPage='+document.getElementById('jmppage3').value)"" class=""anybutton2""/>" & vbcrlf & ""
			end if
			Response.write "" & vbcrlf & "                                     </td>" & vbcrlf & "                           </tr>" & vbcrlf & "                           </table>" & vbcrlf & "                        </td>" & vbcrlf & "           </tr>" & vbcrlf & "   </table>" & vbcrlf & ""
			Call closeReportBar()
			Response.write "" & vbcrlf & "</div>" & vbcrlf & "<div id=""sort_pannel"" style=""position:absolute;display:none;"">" & vbcrlf & "     <table bgcolor=""#fafcff"" border=""0"" style='border:1px solid #C0CCDD;border-right:1px solid #A0ACBD;border-bottom:1px solid #A0ACBD' cellpadding='4'>" & vbcrlf & ""
'Call closeReportBar()
			arrph = Split(px, "_")
			pxlist = ""
			zdyidx = 0
			For i = 0 To UBound(arrph)
				Me.ProgressNow = Me.ProgressNow + 1
'For i = 0 To UBound(arrph)
				tmparr = Split(arrph(i), "-")
'For i = 0 To UBound(arrph)
				If FieldIsID(CInt(tmparr(0))) = 0 Then
					If InStr(1, rs.fields(CInt(tmparr(0))).Name, "_自定义字段")>0 Then
						FieldTitle = zdyarr(CInt(Replace(rs.fields(CInt(tmparr(0))).Name, "_自定义字段", "") -1))
'If InStr(1, rs.fields(CInt(tmparr(0))).Name, "_自定义字段")>0 Then
						zdyidx = zdyidx + 1
'If InStr(1, rs.fields(CInt(tmparr(0))).Name, "_自定义字段")>0 Then
					else
						FieldTitle = replaceDefineName(rs.fields(CInt(tmparr(0))).Name)
					end if
					If tmparr(1) = "1" Then
						descColor = "red"
						ascColor = "#2F496E"
					else
						descColor = "#2F496E"
						ascColor = "red"
					end if
					Response.write "" & vbcrlf & "                     <tr valign=""middle"">" & vbcrlf & "                        <td height=""18"" align=""right""><span style=""color:red"">按"
					Response.write FieldTitle
					Response.write "排序：</span></td>" & vbcrlf & "                     <td>" & vbcrlf & "                          <a href=""###"" style=""color:"
					Response.write descColor
					Response.write """ svalue="""
					Response.write tmparr(0)
					Response.write """ stype=""1"" onClick=""setSort(this);"">【↓】</a>" & vbcrlf & "                               <a href=""###"" style=""color:"
					Response.write ascColor
					Response.write """ svalue="""
					Response.write tmparr(0)
					Response.write """ stype=""2"" onClick=""setSort(this);"">【↑】</a>" & vbcrlf & "                               <span style=""color:lightgreen;cursor:hand"" onClick=""chgOrder(this,1);"">▲</span>" & vbcrlf & "                            <span style=""color:lightgreen;cursor:hand"" onClick=""chgOrder(this,0)"">▼</span>" & vbcrlf & "                       </td>" & vbcrlf & "                 </tr>" & vbcrlf & ""
					If pxlist = "" Then
						pxlist = tmparr(0)
					else
						pxlist = pxlist&","&tmparr(0)
					end if
				end if
			next
			For i = 0 To UBound(Me.arrFields)
				If InStr(1, ","&pxlist&",", ","&i&",")<= 0 Then
					If (FieldIsID(i) = 0 And Not isInList(Me.CantPXFields,rs.fields(i).Name,",")) Or isInList(Me.CanPXFields,rs.fields(i).Name,",") Then
						If InStr(1, rs.fields(i).Name, "_自定义字段")>0 Then
							FieldTitle = zdyarr(zdyidx)
							zdyidx = zdyidx + 1
'FieldTitle = zdyarr(zdyidx)
						else
							FieldTitle = replaceDefineName(rs.fields(i).Name)
						end if
						If IsInList(Me.CantPXFields, rs.fields(i).Name, ",") Then
							strPXDisplay = "style='display:none';"
						else
							strPXDisplay = ""
						end if
						Response.write "" & vbcrlf & "                     <tr valign=""middle"" "
						Response.write strPXDisplay
						Response.write ">" & vbcrlf & "                            <td height=""18"" align=""right""><span class=""reseetTextColor"" style=""color:#2F496E"">按"
						Response.write FieldTitle
						Response.write "排序：</span></td>" & vbcrlf & "                           <td>" & vbcrlf & "                                    <a href=""###"" class=""reseetTextColor"" style=""color:#2F496E"" svalue="""
						Response.write i
						Response.write """ stype=""1"" onClick=""setSort(this);"">【↓】</a>" & vbcrlf & "                                       <a href=""###"" class=""reseetTextColor"" style=""color:#2F496E"" svalue="""
						Response.write i
						Response.write """ stype=""2"" onClick=""setSort(this);"">【↑】</a>" & vbcrlf & "                                       <span style=""color:lightgreen;cursor:hand"" onClick=""chgOrder(this,1);"">▲</span>" & vbcrlf & "                                    <span style=""color:lightgreen;cursor:hand"" onClick=""chgOrder(this,0)"">▼</span>" & vbcrlf & "                             </td>" & vbcrlf & "                   </tr>" & vbcrlf & ""
					end if
				end if
			next
			Response.write "" & vbcrlf & "                     <tr>" & vbcrlf & "                            <td colspan=""2"" align=""right"">" & vbcrlf & "                                      <input type=""button"" class=""page"" value=""排序"" onClick=""DoSort(this.parentElement.parentElement.parentElement.parentElement);"">" & vbcrlf & "                         </td>" & vbcrlf & "                   </tr>" & vbcrlf & "           </table>"& vbcrlf &     "</div>" & vbcrlf & " " & vbcrlf &   "<div id=""FieldOrderSelect"" class=""easyui-window"" icon=""icon-search"" title=""设置列显示顺序"""   & vbcrlf &             "style=""display:none;width:510px;height:450px;padding:2px;background:#fafafa;top:0px"" closed=""true"" >" & vbcrlf &        " <input name=""needhidedlgdiv"" type=""hidden"">" & vbcrlf & "         <div region=""center"" border=""false"" style=""padding:1%;background:#fff;class='needhide';border:1px solid #ccc;width:98%"">" & vbcrlf & "                      <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"" " & vbcrlf & "                           style=""word-break:break-all;word-wrap:break-word;"">" & vbcrlf & " "
'tr>" & vbcrlf & ""
			zdyidx = 0
			For i = 0 To UBound(Me.arrFields)
				CanMove = False
				If InStr(1, rs.fields(CInt(Me.arrFields(i))).Name, "_自定义字段")>0 Then
					FieldTitle = zdyarr(zdyidx)
					zdyidx = zdyidx + 1
'FieldTitle = zdyarr(zdyidx)
				else
					If Not FieldIsID(i) And FieldVisible(i) And i<>0 Then
						CanMove = True
					end if
					FieldTitle = replaceDefineName(rs.fields(CInt(Me.arrFields(i))).Name)
				end if
				If Not CanMove Then
					moveStyle = "style=""display:none"""
				else
					moveStyle = ""
				end if
				Response.write "" & vbcrlf & "                     <tr id=""sortcol_"
				Response.write me.arrFields(i)
				Response.write """ onMouseOut=""this.style.backgroundColor=''"" mvalue="""
				Response.write me.arrFields(i)
				Response.write """ " & vbcrlf & "                                mflg="""
				Response.write abs(CanMove)
				Response.write """ onMouseOver=""this.style.backgroundColor='efefef';"" "
				Response.write moveStyle
				Response.write ">" & vbcrlf & "                            <td>"
				Response.write FieldTitle
				Response.write "</td>" & vbcrlf & "                                <td>" & vbcrlf & "                                    <div>" & vbcrlf & ""
				Response.write "" & vbcrlf & "                                     <a href=""###"" onClick=""UpFieldOrder(this,true);"">【↑】</a>" & vbcrlf & "                                 <a href=""###"" onClick=""UpFieldOrder(this,false)"">【↓】</a>" & vbcrlf & ""
				Response.write "" & vbcrlf & "                                     </div>" & vbcrlf & "                          </td>" & vbcrlf & "                   </tr>" & vbcrlf & ""
			next
			Response.write "" & vbcrlf & "             </table>" & vbcrlf & "        </div>" & vbcrlf & "  <div region=""south"" border=""false"" style=""text-align:right;height:30px;padding-top:10px"">" & vbcrlf & "             <input type=""hidden"" name=""sflg"" value=""1"">" & vbcrlf & "           <input type=""hidden"" name=""page_count"" value="""
			Response.write page_count
			Response.write """>" & vbcrlf & "                <input type=""hidden"" name=""px"" value="""
			Response.write px
			Response.write """>" & vbcrlf & "                <a class=""easyui-linkbutton"" icon=""icon-search"" href=""###"" onClick=""if(confirm('确定要保存设置吗？（此操作将自动重置列宽设置）')) SaveFieldOrder('save');"">保存</a>" & vbcrlf & "             <a class=""easyui-linkbutton"" icon=""icon-cancel"" href=""###"" onClick=""$('#FieldOrderSelect').window('close');"">取消</a>" & vbcrlf & "              <a class=""easyui-linkbutton"" icon=""icon-undo"" href=""###"" onClick=""if(confirm('确定要恢复默认顺序吗？（此操作将自动重置列宽设置）')) SaveFieldOrder('reset');"">默认</a>" & vbcrlf & "  </div>" & vbcrlf & "</div>" & vbcrlf & "" & vbcrlf & "<div id=""FieldSelected"" icon=""icon-search"" title=""查看列选择"" style=""display:none;width:510px;padding:2px;background:#fafafa;top:0px"" closed=""true"" >" & vbcrlf & "        <div region=""center"" border=""false"" style=""padding:1%;background:#fff;border:1px solid #ccc;width:98%"" id='visibleCol'>" & vbcrlf & "               <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content""  style=""word-break:break-all;word-wrap:break-word;"">" & vbcrlf & " "
			Response.write px
			zdyidx = 0
			i_col = 0
			col_flg = False
			firstflg = False
			For i = 0 To UBound(Me.arrFields)
				If Not FieldIsID(CInt(Me.arrFields(i))) Then
					If i=0 Then
						If i_col = 0 Then
							If firstflg Then Response.write "</tr>"
							Response.write "<tr style='display:none'>"
							col_flg = True
						end if
						firstflg = True
						Response.write "" & vbcrlf & "                                     <td colspan='3'>" & vbcrlf & "                                                <input type=""checkbox"" "
						if IsInList(me.intro,me.arrFields(i),",")=true then Response.write " checked"
						Response.write " name=""showFields"" " & vbcrlf & "                                                    value="""
						Response.write i
						Response.write """ value2='"
						Response.write me.arrFields(i)
						Response.write "' id=""chkbx"
						Response.write i
						Response.write """ " & vbcrlf & "                                                        onclick=""hidField(this,event)"">"
						Response.write replaceDefineName(rs.fields(CInt(Me.arrFields(i))).Name)
						Response.write "" & vbcrlf & "                                       </td>" & vbcrlf & ""
					else
						If i_col = 0 Then
							If firstflg Then Response.write "</tr>"
							Response.write "<tr>"
							col_flg = True
						end if
						firstflg = True
						If InStr(1, rs.fields(CInt(Me.arrFields(i))).Name, "_自定义字段")>0 Then
							FieldTitle = zdyarr(zdyidx)
							zdyidx = zdyidx + 1
'FieldTitle = zdyarr(zdyidx)
						else
							FieldTitle = replaceDefineName(rs.fields(CInt(Me.arrFields(i))).Name)
						end if
						Response.write "" & vbcrlf & "                                      <td onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef';"" " & vbcrlf & "                                          onClick=""objid('chkbx"
						Response.write i
						Response.write "').click();"" style=""cursor:pointer"">" & vbcrlf & "                                         <input type=""checkbox"" "
						if IsInList(me.intro,me.arrFields(i),",")=true then Response.write " checked"
						Response.write " name=""showFields"" " & vbcrlf & "                                                     value="""
						Response.write i
						Response.write """ value2='"
						Response.write me.arrFields(i)
						Response.write "' id=""chkbx"
						Response.write i
						Response.write """ onclick=""hidField(this,event);"">"
						Response.write FieldTitle
						Response.write "" & vbcrlf & "                                      </td>" & vbcrlf & ""
						i_col = i_col + 1
						Response.write "" & vbcrlf & "                                      </td>" & vbcrlf & ""
						If i_col = 3 Then i_col = 0
					end if
				end if
			next
			If i_col>0 Then Response.write "<td colspan='"&(3 - i_col)&"'><div></div></td>"
			If i_col = 3 Then i_col = 0
			If col_flg Then
				Response.write "</tr>"
			end if
			Response.write "" & vbcrlf & "              </table>" & vbcrlf & "        </div>" & vbcrlf & "</div>" & vbcrlf & ""
			On Error GoTo 0
			rs.close
			Set rs=Nothing
		end sub
		Sub ShowGatherListHTMLFoot()
			Response.write "" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "var jstarget=document.getElementsByTagName(""table"");" & vbcrlf & "var tbobj=null;" & vbcrlf & "for(var i=0;i<jstarget.length;i++)" & vbcrlf & "{" & vbcrlf & "      var jsflg = jstarget[i].getAttribute(""jsflg"");" & vbcrlf & "    if(jsflg==""1"")" & vbcrlf &    "{ "& vbcrlf &               " tbobj=jstarget[i]; "& vbcrlf &               "break;" & vbcrlf &   "}" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function resetForm()" & vbcrlf &" {" & vbcrlf &  "var wobj=document.getElementById(""dd"").getElementsByTagName(""input"");" & vbcrlf &        "for(var i=0;i<wobj.length;i++)" & vbcrlf & "        {" & vbcrlf & "               if(wobj[i].name)" & vbcrlf & "                {" & vbcrlf & "                       if(wobj[i].type==""checkbox""&&wobj[i].checked)" & vbcrlf & "                     {" & vbcrlf & "                               wobj[i].click();" & vbcrlf & "                        }" & vbcrlf & "                       else if(wobj[i].type!=""hidden""&&wobj[i].type!=""checkbox"")" & vbcrlf & "                   {& vbcrlf &                              wobj[i].value=""; & vbcrlf &                  } & vbcrlf &                } & vbcrlf &        } & vbcrlf &        open1(); & vbcrlf & } & vbcrlf & vbcrlf & //当内容宽度小于表头宽度时自适应调整宽度 & vbcrlf & //var tbpannel=tbobj.parentElement; & vbcrlf & var tbpannel=tbobj.parentElement.parentElement.parentElement.parentElement;" & vbcrlf & "var tbpannelwidth=tbpannel.offsetWidth;" & vbcrlf & "var tbwidth=0;" & vbcrlf & "var tbvisable=0;" & vbcrlf & "" & vbcrlf & "for(var i=0;i<tbobj.rows[0].cells.length;i++)" & vbcrlf & "{" & vbcrlf & "     tbwidth+=tbobj.rows[0].cells[i].offsetWidth;" & vbcrlf & "    if(tbobj.rows[0].cells[i].style.display!=""none"") tbvisable++;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "if(tbwidth<tbpannelwidth-100)" & vbcrlf & "{" & vbcrlf & " for(var i=0;i<tbobj.rows[0].cells.length;i++)" & vbcrlf & "   {" & vbcrlf & "               if(tbobj.rows[0].cells[i].style.display!=""none"") tbobj.rows[0].cells[i].style.width=(tbpannelwidth/tbvisable)+""px"";" & vbcrlf & "  }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "if(top!=window)" & vbcrlf & "{" & vbcrlf & "      if(parent.document.getElementById('cFF'))" & vbcrlf & "       {" & vbcrlf & "               if (parseInt(document.getElementById(""tableid"").offsetHeight)<=600)" & vbcrlf & "             {" & vbcrlf & "                       parent.document.getElementById('cFF').style.height=600+""px"";" & vbcrlf & "              }" & vbcrlf & "               else" & vbcrlf & "            {" & vbcrlf & "                       parent.document.getElementById('cFF').style.height=document.getElementById(""tableid"").offsetHeight+50+""px"";" & vbcrlf & "         }" & vbcrlf &"  }" & vbcrlf & "" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "<script type=""text/javascript"" src=""../inc/jquery-1.4.2.min.js?ver="
'Sub ShowGatherListHTMLFoot()
			Response.write Application("sys.info.jsver")
			Response.write """></script>" & vbcrlf & "<script type=""text/JavaScript"" src=""../inc/jquery.easyui.min.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write """></script>" & vbcrlf & "<script type=""text/javascript"" language=""javascript"">" & vbcrlf & "$(document).ready(function(){" & vbcrlf & "  setTimeout( function() {" & vbcrlf & "                        $(""#Del_Batch"").bind(""click"", function(){" & vbcrlf & "                      if($("".Del_Item_List"").attr(""checked""))" & vbcrlf & "                     {" & vbcrlf & "                                    $("".Del_Item_List"").removeAttr(""checked"");" & vbcrlf & "                           }" & vbcrlf & "                         else" & vbcrlf & "                    {" & vbcrlf & "                             $("".Del_Item_List"").attr(""checked"",'true');" & vbcrlf & "                                 }" & vbcrlf & "                      });" & vbcrlf & "     }, 1000);" & vbcrlf & "});" & vbcrlf & "var showed = false;" & vbcrlf & "document.body.onclick = function(){" & vbcrlf & "      if( showed == false){" & vbcrlf & "           document.getElementById(""FieldSelected"").style.visibility=""visible"";" & vbcrlf & "                var divs = document.getElementsByName(""needhidedlgdiv"");" & vbcrlf & "          for(var i =0 ; i < divs.length;i++){" & vbcrlf & "                   divs[i].parentNode.style.visibility=""visible"";" & vbcrlf & "                    if($("".needhide""))" & vbcrlf & "                        {" & vbcrlf & "                           $("".needhide"").show();" & vbcrlf & "                        }" & vbcrlf & "               }" & vbcrlf & "               showed  = true;" & vbcrlf & " }" & vbcrlf & "}" & vbcrlf & "function DelBatch(){" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "<script language='javascript'>ResizeTable_Init(tbobj,true,true);</script>" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
		end sub
		Public Sub ClearDB
			response.flush
			conn.Close()
			Set conn = Nothing
		end sub
		Public Function SubExists(subName)
			on error resume next
			Execute subName&"=1"
			SubExists = (Err.Number = 501 Or Err.Number = 450)
			On Error GoTo 0
		end function
		Public Sub UpdateProgressBar(pmsg)
			Call doProc(Me.TotalProgress, Me.ProgressNow)
		end sub
		Public Sub ThrowException(errDesc, errCode)
			Response.write "<div style='padding:10px;border:1px solid #cccc88;background-color:#ffffcc;top:20px;width:80%;left:10%;z-index:1200;position:absolute;height:40px;font-size:12px'>"&_
			"<div style='margin-top:-5px;"&_
			"错误信息：<span style='font-size:12px;color:red"&_
			"<div>错误代码：<textarea style='color:blue;width:100%;height:300px' onfocus='this.select();"&_
			"<div style='text-align:right'><a href='###' onclick='window.location.reload();'>刷新页面</a></div>"&_
			"</div>"
			on  error resume next
			conn.close
			call db_close : Response.end
		end sub
		Public Function CanDelete(qx_sort, creator)
			CanDelete = CheckPower(qx_sort, 3, creator)
		end function
		Public Function CheckPower(sort1, sort2, CreatorID)
			Dim sql_qx, qx_type, qx_open, qx_intro
			sql_qx = "select isnull(sort,0) as sort from qxlblist where sort1=" & sort1 & " and sort2="& sort2
			Set rs_qx = conn.Execute(sql_qx)
			If Not rs_qx.EOF Then
				qx_type = rs_qx(0)
			else
				qx_type = 0
			end if
			rs_qx.Close
			Set rs_qx = Nothing
			If qx_type<>0 Then
				sql_qx = "select isnull(qx_open,0) as qx_open,isnull(qx_intro,'') as qx_intro from [power] where sort1=" & sort1 & " and sort2="&sort2&" and ord=" & session("personzbintel2007")
				Set rs_qx = conn.Execute(sql_qx)
				If Not rs_qx.EOF Then
					qx_open = rs_qx(0)
					qx_intro = rs_qx(1)
				else
					qx_open = 0
					qx_intro = ""
				end if
				rs_qx.Close
				Set rs_qx = Nothing
				If Len(CreatorID & "") = 0 Then CreatorID = 0
				If qx_open = qx_type Or (qx_open = 1 And CheckIntro(qx_intro, CStr(CreatorID))>0) Then
					CheckPower = True
				else
					CheckPower = False
				end if
			else
				CheckPower = False
			end if
		end function
		Function CheckIntro(str1, str2)
			CheckIntro = InStr(","&Replace(str1 & "", " ", "")&",", ","&Replace(str2 & "", " ", "")&",")
		end function
		Function HasPower(x1, x2)
			HasPower = False
			If x1<>"" And x2<>"" Then
				Set rs1 = server.CreateObject("adodb.recordset")
				sql1 = "select qx_open from power  where ord="&session("personzbintel2007")&" and sort1="&x1&" and sort2="&x2&""
				rs1.Open sql1, conn, 1, 1
				If Not rs1.EOF Then
					If rs1("qx_open") = 3 Or rs1("qx_open") = 1 Then
						HasPower = True
					end if
				end if
				rs1.Close
				Set rs1 = Nothing
			end if
		end function
	End Class
	
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=74 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_74_1=0
		intro_74_1=0
	else
		open_74_1=rs1("qx_open")
		intro_74_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=74 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_74_3=0
		intro_74_3=0
	else
		open_74_3=rs1("qx_open")
		intro_74_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=74 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_74_13=0
		intro_74_13=0
	else
		open_74_13=rs1("qx_open")
		intro_74_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=74 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_74_7=0
		intro_74_7=0
	else
		open_74_7=rs1("qx_open")
		intro_74_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=74 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_74_8=0
		intro_74_8=0
	else
		open_74_8=rs1("qx_open")
		intro_74_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=74 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_74_10=0
		intro_74_10=0
	else
		open_74_10=rs1("qx_open")
		intro_74_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=74 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_74_11=0
		intro_74_11=0
	else
		open_74_11=rs1("qx_open")
		intro_74_11=rs1("qx_intro")
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
	if open_74_1=3 then
		list=""
	elseif open_74_1=1 then
		list="and addcate in ("&intro_74_1&")"
		list8=" and addcate_ID in("&intro_74_1&")"
	else
		list="and addcate=0"
		list8=" and addcate_ID=0"
	end if
	Str_Result="where del=1 "&list&""
	Str_Result2="and del=1 "&list&""
	Str_Result8="and del_ID=1 "&list8&""
	
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
	
	Response.write vbcrlf
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
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=2 and sort2=2"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_2_2=0
		intro_2_2=0
	else
		open_2_2=rs1("qx_open")
		intro_2_2=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=2 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_2_3=0
		intro_2_3=0
	else
		open_2_3=rs1("qx_open")
		intro_2_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=2 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_2_7=0
		intro_2_7=0
	else
		open_2_7=rs1("qx_open")
		intro_2_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=2 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_2_8=0
		intro_2_8=0
	else
		open_2_8=rs1("qx_open")
		intro_2_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=2 and sort2=9"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_2_9=0
		intro_2_9=0
	else
		open_2_9=rs1("qx_open")
		intro_2_9=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=2 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_2_10=0
		intro_2_10=0
	else
		open_2_10=rs1("qx_open")
		intro_2_10=rs1("qx_intro")
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
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=74 and sort2=12"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_74_12 = 0
		intro_74_12 = 0
	else
		open_74_12 = rs1("qx_open")
		intro_74_12 = rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
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
	if open_2_1=3 then
		list=""
	elseif open_2_1=1 then
		list="b.cateid in  ("&intro_2_1&")"
	else
		list="b.cateid=0"
	end if
	Str_Result=" where a.del=1"
	if list<>"" then
		Str_Result=Str_Result& " and ((" & vbcrlf & "/*p-2-cateid-s*/" & vbcrlf & list & vbcrlf & "/*pe*/) or (b.sharecontact=1 and (b.share like'%"&session("personzbintel2007")&"%' or b.share='1')))"
'if list<>"" then
	end if
	
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
			'imgurl = "../code2/view.asp?sn=view&ct=46&data=CLDJ:"& v &"&width=120&errorh=3"
		else
			imgurl = "../code2/viewCode.asp?codeType=128&data=HTID:"& v &"&height=60"
			s = "<div style='width:auto; display:inline-block !important; *zoom:1; display:inline; '><div style='text-align:center'><a href='javascript:void(0)' onclick=""javascript:window.open('../code2/viewImage.asp?codeType=128&title="& server.urlencode(code) &"&imgurl=" & server.urlencode(imgurl) & "&t="&now()&"','imgurl_1','width=' + 320 + ',height=' + 320 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')""><img  height='30' title='"&title&"' src='"& imgurl &"' style='cursor:pointer;'></a></div><div style='text-align:center'>"&v&"</div></div>"
			'imgurl = "../code2/viewCode.asp?codeType=128&data=HTID:"& v &"&height=60"
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
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_1=0
		intro_67_1=0
	else
		open_67_1=rs1("qx_open")
		intro_67_1=rs1("qx_intro")
		If Len(intro_67_1&"") = 0 Then intro_67_1 = 0
		If Left(intro_67_1,1) = "," Then intro_67_1 = Right(intro_67_1,Len(intro_67_1)-1)
'If Len(intro_67_1&"") = 0 Then intro_67_1 = 0
		If right(intro_67_1,1) = "," Then intro_67_1 = left(intro_67_1,Len(intro_67_1)-1)
'If Len(intro_67_1&"") = 0 Then intro_67_1 = 0
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_7=0
		intro_67_7=0
	else
		open_67_7=rs1("qx_open")
		intro_67_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_8=0
		intro_67_8=0
	else
		open_67_8=rs1("qx_open")
		intro_67_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_10=0
		intro_67_10=0
	else
		open_67_10=rs1("qx_open")
		intro_67_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_11=0
		intro_67_11=0
	else
		open_67_11=rs1("qx_open")
		intro_67_11=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_3=0
		intro_67_3=0
	else
		open_67_3=rs1("qx_open")
		intro_67_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=12"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_12=0
		intro_67_12=0
	else
		open_67_12=rs1("qx_open")
		intro_67_12=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_13=0
		intro_67_13=0
	else
		open_67_13=rs1("qx_open")
		intro_67_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=17"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_17=0
		intro_67_17=0
	else
		open_67_17=rs1("qx_open")
		intro_67_17=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=15"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_15=0
		intro_67_15=0
	else
		open_67_15=rs1("qx_open")
		intro_67_15=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=19"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_19=0
		intro_67_19=0
	else
		open_67_19=rs1("qx_open")
		intro_67_19=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=20"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_20=0
		intro_67_20=0
	else
		open_67_20=rs1("qx_open")
		intro_67_20=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	
	Dim power_uid, kh_list
	Dim open_1_1,open_1_2,open_1_3,open_1_4,open_1_5,open_1_6,open_1_7,open_1_8,open_1_9,open_1_10,open_1_11,open_1_13
	Dim open_1_14,open_1_15,open_1_16,open_1_17,open_1_21,open_1_25
	Dim intro_1_1,intro_1_2,intro_1_3,intro_1_4,intro_1_5,intro_1_6,intro_1_7,intro_1_8,intro_1_9,intro_1_10,intro_1_11
	Dim intro_1_13,intro_1_14,intro_1_15,intro_1_16,intro_1_17,intro_1_21,intro_1_25
	Dim open_2_1,open_2_3,intro_2_3,open_2_13,open_2_14,open_2_19,intro_2_1,  intro_2_13,intro_2_14,intro_2_19
	Dim open_3_1,open_3_13,open_3_14,open_3_19,open_3_21,intro_3_1,intro_3_13,intro_3_14,intro_3_19,intro_3_21
	Dim open_4_1,open_4_13,open_4_14,open_4_19,open_4_21,intro_4_1,intro_4_13,intro_4_14,intro_4_19,intro_4_21,open_4_23,intro_4_23
	Dim open_5_1,open_5_11,open_5_13,open_5_14,open_5_19,open_5_21,intro_5_1,intro_5_11,intro_5_13,intro_5_14,intro_5_19,intro_5_21
	Dim open_6_1,open_6_13,open_6_14,open_6_19,intro_6_1,intro_6_13,intro_6_14,intro_6_19
	Dim open_7_1,open_7_2,open_7_3,open_7_13,open_7_14,open_7_19,open_7_20,open_7_21,open_7_22
	Dim intro_7_1,intro_7_2,intro_7_3,intro_7_13,intro_7_14,intro_7_19,intro_7_20,intro_7_21,intro_7_22
	Dim open_7001_1,open_7001_2,open_7001_3,open_7001_13,open_7001_14,open_7001_19,open_7001_20,open_7001_21,open_7001_22
	Dim intro_7001_1,intro_7001_2,intro_7001_3,intro_7001_13,intro_7001_14,intro_7001_19,intro_7001_20,intro_7001_21,intro_7001_22
	Dim open_26_1 , intro_26_1,open_26_14 , intro_26_14
	Dim open_33_1,open_33_13,open_33_14,open_33_19,intro_33_1,intro_33_13,intro_33_14,intro_33_19
	Dim open_41_1,open_41_14,open_41_19,intro_41_1,intro_41_14,intro_41_19
	Dim open_42_1,open_42_13,open_42_14,open_42_19,intro_42_1,intro_42_13,intro_42_14,intro_42_19
	Dim open_43_13,open_43_19,intro_43_13,intro_43_19
	Dim open_74_1,open_74_19,intro_74_1,intro_74_19
	Dim open_108_5,intro_108_5
	sub g_p_v(byval s1,byval s2,byref p1,byref p2)
		sdk.setup.getpowerattr s1,s2,p1,p2
	end sub
	g_p_v 1,1,open_1_1,intro_1_1
	g_p_v 1,2,open_1_2,intro_1_2
	g_p_v 1,3,open_1_3,intro_1_3
	g_p_v 1,4,open_1_4,intro_1_4
	g_p_v 1,5,open_1_5,intro_1_5
	g_p_v 1,6,open_1_6,intro_1_6
	g_p_v 1,7,open_1_7,intro_1_7
	g_p_v 1,8,open_1_8,intro_1_8
	g_p_v 1,9,open_1_9,intro_1_9
	g_p_v 1,10,open_1_10,intro_1_10
	g_p_v 1,11,open_1_11,intro_1_11
	g_p_v 1,13,open_1_13,intro_1_13
	g_p_v 1,14,open_1_14,intro_1_14
	g_p_v 1,15,open_1_15,intro_1_15
	g_p_v 1,16,open_1_16,intro_1_16
	g_p_v 1,17,open_1_17,intro_1_17
	g_p_v 1,21,open_1_21,intro_1_21
	g_p_v 1,25,open_1_25,intro_1_25
	g_p_v 2,1,open_2_1,intro_2_1
	g_p_v 2,3,open_2_3,intro_2_3
	g_p_v 2,13,open_2_13,intro_2_13
	g_p_v 2,14,open_2_14,intro_2_14
	g_p_v 2,19,open_2_19,intro_2_19
	g_p_v 108,5,open_108_5,intro_108_5
	g_p_v 3,1,open_3_1,intro_3_1
	g_p_v 3,13,open_3_13,intro_3_13
	g_p_v 3,14,open_3_14,intro_3_14
	g_p_v 3,19,open_3_19,intro_3_19
	g_p_v 3,21,open_3_21,intro_3_21
	g_p_v 4,1,open_4_1,intro_4_1
	g_p_v 4,13,open_4_13,intro_4_13
	g_p_v 4,14,open_4_14,intro_4_14
	g_p_v 4,19,open_4_19,intro_4_19
	g_p_v 4,21,open_4_21,intro_4_21
	g_p_v 4,23,open_4_23,intro_4_23
	g_p_v 5,1,open_5_1,intro_5_1
	g_p_v 5,11,open_5_11,intro_5_11
	g_p_v 5,13,open_5_13,intro_5_13
	g_p_v 5,14,open_5_14,intro_5_14
	g_p_v 5,19,open_5_19,intro_5_19
	g_p_v 5,21,open_5_21,intro_5_21
	g_p_v 6,1,open_6_1,intro_6_1
	g_p_v 6,13,open_6_13,intro_6_13
	g_p_v 6,14,open_6_14,intro_6_14
	g_p_v 6,19,open_6_19,intro_6_19
	g_p_v 7,1,open_7_1,intro_7_1
	g_p_v 7,2,open_7_2,intro_7_2
	g_p_v 7,3,open_7_3,intro_7_3
	g_p_v 7,13,open_7_13,intro_7_13
	g_p_v 7,14,open_7_14,intro_7_14
	g_p_v 7,19,open_7_19,intro_7_19
	g_p_v 7,20,open_7_20,intro_7_20
	g_p_v 7,21,open_7_21,intro_7_21
	g_p_v 7,25,open_7_22,intro_7_22
	g_p_v 7001,1,open_7001_1,intro_7001_1
	g_p_v 7001,2,open_7001_2,intro_7001_2
	g_p_v 7001,3,open_7001_3,intro_7001_3
	g_p_v 7001,13,open_7001_13,intro_7001_13
	g_p_v 7001,14,open_7001_14,intro_7001_14
	g_p_v 7001,19,open_7001_19,intro_7001_19
	g_p_v 7001,20,open_7001_20,intro_7001_20
	g_p_v 7001,21,open_7001_21,intro_7001_21
	g_p_v 7001,25,open_7001_22,intro_7001_22
	g_p_v 26,1,open_26_1,intro_26_1
	g_p_v 26,14,open_26_14,intro_26_14
	g_p_v 33,1,open_33_1,intro_33_1
	g_p_v 33,13,open_33_13,intro_33_13
	g_p_v 33,14,open_33_14,intro_33_14
	g_p_v 33,19,open_33_19,intro_33_19
	g_p_v 41,1,open_41_1,intro_41_1
	g_p_v 41,13,open_41_13,intro_41_13
	g_p_v 41,14,open_41_14,intro_41_14
	g_p_v 41,19,open_41_19,intro_41_19
	g_p_v 42,1,open_42_1,intro_42_1
	g_p_v 42,13,open_42_13,intro_42_13
	g_p_v 42,14,open_42_14,intro_42_14
	g_p_v 42,19,open_42_19,intro_42_19
	g_p_v 43,14,open_43_14,intro_43_14
	g_p_v 43,19,open_43_19,intro_43_19
	g_p_v 74,1,open_74_1,intro_74_1
	g_p_v 74,19,open_74_19,intro_74_19
	power_uid = session("personzbintel2007")
	if open_1_1=3 then
		list=" 1=1 "
		list2=" 1=1 "
	elseif open_1_1=1 then
		list=" cateid in ("&iif(intro_1_1&""="","0",intro_1_1)&") and cateid>0 "
		list2=" cateadd in ("&iif(intro_1_1&""="","0",intro_1_1)&") and cateadd>0 "
	else
		list=" 1=2 "
		list2=" 0=1 "
	end if
	dim rs,sql,Str_Result,Str_Result2
	str_temp_where = "and ((" & vbcrlf & "/*p-1-cateid-s*/" & vbcrlf & list & vbcrlf & "/*pe*/" & vbcrlf & ") or (CHARINDEX(',"&power_uid&",' , ','+REPLACE(share,' ','')+',') > 0 or share='1'))"
'dim rs,sql,Str_Result,Str_Result2
'dim rs,sql,Str_Result,Str_Result2
	Str_Result=" where del=1 and sort3=1   "&str_temp_where&""
	Str_Result2=" and (del=1 and sort3=1 and (("&list&") or (CHARINDEX(',"&power_uid&",' , ','+REPLACE(share,' ','')+',') > 0 or share='1')) "
'Str_Result=" where del=1 and sort3=1   "&str_temp_where&""
	Str_Result3=" where del=1 and sort3=1 and (("&list2&") or (CHARINDEX(',"&power_uid&",' , ','+REPLACE(share,' ','')+',') > 0 or share='1'))"
'Str_Result=" where del=1 and sort3=1   "&str_temp_where&""
	
	Function GetW3Core(ByVal strW1,ByVal strW2, ByVal strW3, ByVal deltype)
		dim rs, orgsid, sql
		If Len(strW3) > 0 And strW3<>"0" then
			If InStr(1,strW3,"select",1) > 0 Then
				GetW3Core = strW3
				Exit function
			end if
			strW3 = Replace(strW3 & "", " ", "")
			strW3 = Replace(strW3, ",,", ",")
			strW3 = Replace(Replace("?" & strW3 & "?", "?,", ""),",?","")
			strW3 = Replace(strW3,"?","")
			If strW3 = "" Then strW3 = "0"
			GetW3Core=strW3
			Exit function
		else
			if len(strW2) > 0 And strW2<>"0" Then
				sql = "select ord from gate where orgsid in ("& strW2 &") or ('"& strW1&"'='999999999' and orgsid=0)"
			else
				if len(strW1) > 0 And strW1<>"0" Then
					strW3 = ""
					orgsid =  Replace(("," & Replace(strW1 & "," & strW2, " ", ",")  & ","), ",0,",",")
					dim ids :ids = ""
					sql = "select x.id  from orgs_parts x inner join (" & _
					"   select fullids from orgs_parts  where '," + replace(orgsid, " ","") + ",%'  like '%,' + cast(ID as varchar(12)) + ',%'" & _
					") y on charindex(y.fullids+',',  x.fullids+'," & _
					"set rs = conn.execute(sql)"
					while rs.eof = false
						if len(ids)>0 then ids =  ids & ","
						ids = ids & rs(0).value
						rs.movenext
					wend
					rs.close
					if len(ids) = 0 then ids = "-1"
					ids = ids & rs(0).value
					if strW1&""="" then strW1 = 0
					if instr(strW1,"-")>0 then ids = replace(strW1,"-","")
'if strW1&""="" then strW1 = 0
					sql = "select ord from gate where orgsid in ("& ids &") or ('"& strW1 &"'='999999999' and orgsid=0)"
				else
					GetW3Core = "0"
					Exit function
				end if
			end if
		end if
		set rs = conn.execute(sql)
		While rs.eof= False
			If Len(strW3)>0 Then  strW3 = strW3 & ","
			strW3 = strW3 & rs(0).value
			rs.movenext
		wend
		rs.close
		if strW1&""="999999999" then
			If Len(strW3)>0 Then strW3 = strW3 & ","
			strW3 = strW3 & "0"
		end if
		GetW3Core=strW3
	end function
	function getW3(ByVal strW1,ByVal strW2, ByVal strW3)
		getW3=GetW3Core(strW1, strW2, strW3, "1")
	end function
	function getLimitedW3(strw3,stype,sort1,sort2,cid)
		dim i,sql
		if (stype<>1 and stype<>2) or not isnumeric(sort1) or not isnumeric(sort2) or not isnumeric(cid) then
			Response.write "参数错误"
			call db_close : Response.end
		end if
		Dim fw1,fw2,fw3,pw3,qx_open,tmpW3,tmp,rs
		fw1=replace(request("w1")," ","")
		fw2=replace(request("w2")," ","")
		fw3=replace(request("w3")," ","")
		if fw3<>"" and fw3<>"0" and (fw1="" or fw1="0") and (fw2="" or fw2="0") and isnumeric(fw3) and instr(fw3,",")<=0 then
			getLimitedW3=strw3
		else
			if strw3="-1" or strw3="0" Or strw3&""="" then
				getLimitedW3=strw3
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
					if ((fw1<>"" And fw1<>"0") or (fw2<>"" And fw2<>"0") or (fw3<>"" And fw3<>"0")) and replace(replace(tmpW3," ",""),"0","")="" then tmpW3="-1"
					tmpW3=tmpW3&","&tmp(i)
					getLimitedW3=tmpW3
				elseif qx_open="0" then
					getLimitedW3="-1"
'elseif qx_open="0" then
				elseif qx_open="3" then
					getLimitedW3=strw3
				end if
			end if
		end if
	end function
	function getW1W2(strW3)
		dim rtnW1,rtnW2,frs,fsql, strW3s
		rtnW1=""
		rtnW2=""
		If InStr(strW3,"|") >0 Then strW3s = Split(strW3, "|"):   strW3 = strW3s(ubound(strW3s))
		strW3 = Replace(","&Trim(strW3)&",",",0,",",")
		If Left(strW3,1)="," Then strW3=Right(strW3,Len(strW3)-1)
		strW3 = Replace(","&Trim(strW3)&",",",0,",",")
		If right(strW3,1)="," Then strW3=left(strW3,Len(strW3)-1)
		strW3 = Replace(","&Trim(strW3)&",",",0,",",")
		if strW3<>"" Then
			fsql="select distinct sorce from gate where charindex(','+cast(ord as varchar(10))+',',',"&strW3&",')>0 and sorce>=0"
'if strW3<>"" Then
			set frs=conn.execute(fsql)
			while not frs.eof
				if rtnW1="" then
					rtnW1=frs(0)
				else
					rtnW1=rtnW1&","&frs(0)
				end if
				frs.movenext
			wend
			frs.close
			fsql="select distinct sorce2 from gate where charindex(','+cast(ord as varchar(10))+',',',"&strW3&",')>0 and sorce2>=0"
			frs.close
			set frs=conn.execute(fsql)
			while not frs.eof
				if rtnW2="" then
					rtnW2=frs(0)
				else
					rtnW2=rtnW2&","&frs(0)
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
		getW3WithLock=GetW3Core(strW1, strW2, strW3, "1,2,3")
	end function
	function CheckPurview(AllPurviews,strPurview)
		if isNull(AllPurviews) or AllPurviews="" or strPurview="" then
			CheckPurview=False
			exit function
		end if
		CheckPurview=False
		if instr(AllPurviews,",")>0 then
			dim arrPurviews,i77
			arrPurviews=split(AllPurviews,",")
			for i77=0 to ubound(arrPurviews)
				if trim(arrPurviews(i77))=strPurview then
					CheckPurview=True
					exit for
				end if
			next
		else
			if AllPurviews=strPurview then
				CheckPurview=True
			end if
		end if
	end function
	
	Response.Charset="UTF-8"
	Response.ExpiresAbsolute = Now() - 1
	Response.Expires = 0
	Response.CacheControl = "no-cache"
'Response.Expires = 0
	Response.AddHeader "Pragma", "No-Cache"
'Response.Expires = 0
	Function HiddenNumber(ByVal phoneNum)
		Dim numLength,i
		numLength = Len(phoneNum)
		If numLength > 0 Then
			For i = 1 To numLength
				HiddenNumber = HiddenNumber & "*"
			next
		else
			HiddenNumber = ""
		end if
	end function
	Function IsPhonePower(ByVal UserID)
		If UserID & "" = "" Then
			UserID = "0"
		end if
		If ZBRuntime.MC(2000) then
			Dim rs_qx,sql_qx,qx_open,qx_intro,qx_type,sort1,sort2
			sort1 = 2
			sort2 = 6
			sql_qx = "SELECT ISNULL(sort,0) sort FROM qxlblist WHERE sort1 = "&sort1&" AND sort2 = "&sort2&" "
			Set rs_qx = conn.Execute(sql_qx)
			If Not rs_qx.Eof Then
				qx_type = rs_qx("sort")
			else
				qx_type = 0
			end if
			rs_qx.Close : Set rs_qx = Nothing
			If qx_type <> 0 Then
				sql_qx = "SELECT ISNULL(qx_open,0),ISNULL(qx_intro,'-222') FROM [POWER] WHERE sort1 = "&sort1&" AND sort2 = "&sort2&" AND ord = "&session("personzbintel2007")&" "
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
					IsPhonePower = True
				else
					IsPhonePower = False
				end if
			else
				IsPhonePower = False
			end if
		else
			IsPhonePower = True
		end if
	end function
	Function GetPhoneNumber(ByVal phoneNum, ByVal UserID)
		If IsPhonePower(UserID) Then
			GetPhoneNumber = phoneNum
		Else
			GetPhoneNumber = HiddenNumber(phoneNum)
		end if
	end function
	Function HexEncode(ByVal data)
		Dim s, c, i ,rnds, item
		c = Len(data) - 1
'Dim s, c, i ,rnds, item
		rnds = Split("g,h,i,j,k,l,m,n,o",",")
		If c = - 1 Then Exit function
		rnds = Split("g,h,i,j,k,l,m,n,o",",")
		For i = 0 To c
			If i > 0 Then
				s = s & rnds(int(rnd*9))
			end if
			item = LCase(Hex(Ascw(Mid(data, i+1, 1))))
			s = s & rnds(int(rnd*9))
			item = Replace(item,"0","q")
			item = Replace(item,"1","p")
			item = Replace(item,"2","t")
			item = Replace(item,"3","s")
			item = Replace(item,"4","x")
			item = Replace(item,"5","u")
			item = Replace(item,"6","v")
			item = Replace(item,"7","y")
			item = Replace(item,"8","z")
			item = Replace(item,"9","w")
			s = s & item
		next
		HexEncode = s
	end function
	Function HexDecode(ByVal data)
		Dim s, c, i , rnds, item
		c = Len(data) - 1
'Dim s, c, i , rnds, item
		rnds = Split("g,h,i,j,k,l,m,n,o",",")
		For i = 0 To 8
			data = Replace(data, rnds(i), "|")
		next
		s = Split(data, "|")
		For i = 0 To ubound(s)
			item = s(i)
			item = Replace(item,"q","0")
			item = Replace(item,"p","1")
			item = Replace(item,"t","2")
			item = Replace(item,"s","3")
			item = Replace(item,"x","4")
			item = Replace(item,"u","5")
			item = Replace(item,"v","6")
			item = Replace(item,"y","7")
			item = Replace(item,"z","8")
			item = Replace(item,"w","9")
			s(i) = Chrw(eval("&H" & item))
		next
		HexDecode = Join(s,"")
	end function
	
	
	Response.write "" & vbcrlf & "<style>" & vbcrlf & "       #ScroTop td.page table[background=""../images/m_mpbg.gif""]{background:#FFF}" & vbcrlf & "        #ScroTop td.page table[background=""../images/m_mpbg.gif""] td{padding-left:20px;}" & vbcrlf & "  #ScroTop td.page table[background=""../images/m_mpbg.gif""] input[type='button']{background:#EFEFEF!important;}" & vbcrlf & "</style>" & vbcrlf & "<script language=""javascript"" src=""../inc/popup_layer.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ type=""text/javascript""></script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"">" & vbcrlf & "var xmlHttp = GetIE10SafeXmlHttp();" & vbcrlf & "function callServer2() {" & vbcrlf & "  var url = ""liebiao_tj.asp?timestamp="" + new Date().getTime() + ""&date1=""+ Math.round(Math.random()*100);" & vbcrlf & "  xmlHttp.open(""GET"", url, false);" & vbcrlf & "  xmlHttp.onreadystatechange = function(){" & vbcrlf & "  updatePage2();" & vbcrlf & "  };" & vbcrlf & "  xmlHttp.send(null);" & vbcrlf & "}" & vbcrlf & "function updatePage2() {" & vbcrlf & "var test7=""ht1"";"& vbcrlf & "  if (xmlHttp.readyState < 4) {" & vbcrlf & "        ht1.innerHTML=""loading..."";" & vbcrlf & "  }" & vbcrlf & "  if (xmlHttp.readyState == 4) {" & vbcrlf & "    var response = xmlHttp.responseText;" & vbcrlf & "    ht1.innerHTML=response;" & vbcrlf & " xmlHttp.abort();" & vbcrlf & "  }" & vbcrlf & "}" & vbcrlf & "//--屏蔽运行时间错误" & vbcrlf & "window.onerror=function(){return true}" & vbcrlf & "</script>" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "    function checkAll2(str){" & vbcrlf & "        var a=document.getElementById(""u""+str).getElementsByTagName(""input"");" & vbcrlf & "        var b=document.getElementById(""e""+str);" & vbcrlf & "        for(var i=0;i<a.length;i++){" & vbcrlf & "            a[i].checked=b.checked;" & vbcrlf & "        }" & vbcrlf & "    }" & vbcrlf & "" & vbcrlf & "    function fixChk2(str){" & vbcrlf & "        var a=document.getElementById(""u""+str).getElementsByTagName(""input"");" & vbcrlf & "        var b=document.getElementById(""e""+str);" & vbcrlf & "        for(var i=0;i<a.length;i++){" & vbcrlf & "            if(a[i].checked==true){" & vbcrlf & "                //b.checked=false;" & vbcrlf & "                return ;" & vbcrlf & "            }" & vbcrlf & "        }" & vbcrlf & "        b.checked=false;" & vbcrlf & "    }" & vbcrlf & "  </script>" & vbcrlf & "  <script type=""text/javascript"">" & vbcrlf & "    function checkAll3(str){" & vbcrlf & "        var a=document.getElementById(""h""+str).getElementsByTagName(""input"");" & vbcrlf &   "      var b=document.getElementById(""i""+str);" & vbcrlf & "        for(var i=0;i<a.length;i++){" & vbcrlf & "            a[i].checked=b.checked; "& vbcrlf & "        }" & vbcrlf & "    }" & vbcrlf & "    function fixChk3(str){ "& vbcrlf & "        var a=document.getElementById(""h1"").getElementsByTagName(""input"");" & vbcrlf & "        var b=document.getElementById(""i1"");" & vbcrlf & "        for(var i=0;i<a.length;i++){" & vbcrlf & "            if(a[i].checked==false){" & vbcrlf & "                b.checked=false;" & vbcrlf & "                return ;" & vbcrlf& "            }" & vbcrlf & "        }" & vbcrlf & "        b.checked=true;" & vbcrlf & "    }" & vbcrlf & "  </script>" & vbcrlf & "  <script type=""text/javascript"">" & vbcrlf & "    function checkAll7(str){" & vbcrlf & "        var a=document.getElementById(""Wd""+str).getElementsByTagName(""input"");" & vbcrlf & "        var b=document.getElementById(""Wt""+str);" & vbcrlf & "        for(var i=0;i<a.length;i++){" & vbcrlf & "            a[i].checked=b.checked;" & vbcrlf & "        }" & vbcrlf & "    }" & vbcrlf & "" & vbcrlf & "    function fixChk7(str){" & vbcrlf & "        var a=document.getElementById(""Wd1"").getElementsByTagName(""input"");" & vbcrlf & "        var b=document.getElementById(""Wt1"");" & vbcrlf & "        for(var i=0;i<a.length;i++){" & vbcrlf & "            if(a[i].checked==false){" & vbcrlf & "                b.checked=false;" & vbcrlf & "                return ;" & vbcrlf & "            }" & vbcrlf & "        }" & vbcrlf & "        b.checked=true;" & vbcrlf & "    }" & vbcrlf & "  </script>" & vbcrlf & "  <script type=""text/javascript"">" & vbcrlf & "    function checkAll4(str){" & vbcrlf & "        var a=document.getElementById(""j""+str).getElementsByTagName(""input"");" & vbcrlf & "        var b=document.getElementById(""k""+str);" & vbcrlf & "        for(var i=0;i<a.length;i++){" & vbcrlf & "            a[i].checked=b.checked;" & vbcrlf & "        }" & vbcrlf & "    }" & vbcrlf & "" & vbcrlf & "    function fixChk4(str){" & vbcrlf & "      var a=document.getElementById(""j1"").getElementsByTagName(""input"");" & vbcrlf & "        var b=document.getElementById(""k1"");" & vbcrlf & "        for(var i=0;i<a.length;i++){" & vbcrlf & "            if(a[i].checked==false){" & vbcrlf & "                b.checked=false;" & vbcrlf & "        return ;" & vbcrlf & "            }" & vbcrlf & "        }" & vbcrlf & "        b.checked=true;" & vbcrlf & "    }" & vbcrlf & "  </script>" & vbcrlf & "" & vbcrlf & ""
	xuhao=0
	action1="通话列表"
	CurrPage=Request.querystring("CurrPage")
	page_count=request.querystring("page_count")
	px=request.querystring("px")
	if page_count="" then page_count=10
	if CurrPage="" then CurrPage=1
	if px="" or instr(1,px,"-",1)<=0 then px="1-1"
	if CurrPage="" then CurrPage=1
	set rssort=conn.execute("select num1 from setjm3 where ord=1")
	if not rssort.eof then
		NumDigits=rssort(0)
	else
		NumDigits=2
	end if
	sort3=replace(request("sort3")," ","")
	W1=replace(request("W1")," ","")
	W2=replace(request("W2")," ","")
	W3=replace(request("W3")," ","")
	if sort3="" then sort3=0
	if W1="" then W1=0
	if W2="" then W2=0
	if W3="" then W3=0
	If W1<>0 Then
		strCon="and a.cateid2 in ("&W1&")"
	end if
	If W2<>0 Then
		strCon="and a.cateid3 in ("&W2&")"
	end if
	If W3<>0 Then
		strCon="and a.addcate in ("&W3&")"
	end if
	sflg=request.querystring("sflg")
	for each reqPara in request.querystring
		if instr(1,reqPara,"call_")>0 then
			execute(reqPara&"="""&request.querystring(reqPara))&""""
		end if
	next
	if request("export")=1 Then
		if open_74_10=3 then
			listperson=""
		elseif open_74_10=1 then
			listperson=" and addcate_ID in("&intro_74_10&")"
		else
			listperson=" and addcate_ID=0"
		end if
		strCondition="and del_ID=1 "&listperson&""
	else
		strCondition=Str_Result8
	end if
	person=trim(request("person"))
	company=trim(request("company"))
	W3=getW3(W1,W2,W3)
	W3=getLimitedW3(W3,2,1,0,session("personzbintel2007"))
	W4=replace(W3,"0","")
	W4=replace(W4,",","")
	if W4<>"" Then
		tmp=split(getW1W2(W3),";")
		W1=tmp(0)
		W2=tmp(1)
	end if
	strW1=W1
	strW2=W2
	strW3=W3
	if person<>"" and call_G2="" then strCondition=strCondition&" and 联系人_ID=("&person&")"
	if company<>"" and call_F2="" then  strCondition=strCondition&" and 客户_ID=("&company&")"
	If Len(Trim(request("A1")))<>0 Then call_A1 = Trim(request("A1"))
	If Len(Trim(request("call_A1")))<>0  Then call_A1 = Trim(request("call_A1"))
	if call_A1<>""    then
		strCondition=strCondition+" and status_ID in("& call_A1 &")"
'if call_A1<>""    then
	end if
	Dim company : company = request("company")
	If company <> "" Then strCondition = strCondition & " and 客户_ID=" & company
	call_E=trim(request("E"))
	call_F=trim(request("F"))
	if call_E<>""  then strCondition=strCondition+" and gj1_ID in ("& call_E &")"
	call_F=trim(request("F"))
	if call_F<>""  then strCondition=strCondition+" and gj2_ID in ("& call_F &")"
	call_F=trim(request("F"))
	Dim khjz,khhy,khly
	khjz = request("khjz")
	khhy = request("khhy")
	khly = request("khly")
	If sort3<>0 Then
		strCon=strCon & "and b.sort3=1"
	end if
	If khjz & "" <> "" Then
		strCon = strCon & " and b.jz=" & khjz & " "
	end if
	If khhy & "" <> "" Then
		strCon = strCon & " and b.trade=" & khhy & " "
	end if
	If khly & "" <> "" Then
		strCon = strCon & " and b.ly=" & khly & " "
	end if
	if call_S2<>"" then
		if call_S1=1 then
			strCondition=strCondition+" and 通话号码 like '%"& call_S2 &"%'"
'if call_S1=1 then
		elseif call_S1=2 then
			strCondition=strCondition+" and 通话号码 not like '%"& call_S2 &"%'"
'elseif call_S1=2 then
		elseif call_S1=3 then
			strCondition=strCondition+" and 通话号码='"&call_S2&"'"
'elseif call_S1=3 then
		elseif call_S1=4 then
			strCondition=strCondition+" and 通话号码<>'"&call_S2&"'"
'elseif call_S1=4 then
		elseif call_S1=5 then
			strCondition=strCondition+" and 通话号码 like '"& call_S2 &"%'"
'elseif call_S1=5 then
		elseif call_S1=6 then
			strCondition=strCondition+" and 通话号码 like '%"& call_S2 &"'"
'elseif call_S1=6 then
		end if
	end if
	if call_F2<>"" then
		if call_F1=1 then
			strCondition=strCondition+" and 客户 like '%"& call_F2 &"%'"
'if call_F1=1 then
		elseif call_F1=2 then
			strCondition=strCondition+" and 客户 not like '%"& call_F2 &"%'"
'elseif call_F1=2 then
		elseif call_F1=3 then
			strCondition=strCondition+" and 客户='"&call_F2&"'"
'elseif call_F1=3 then
		elseif call_F1=4 then
			strCondition=strCondition+" and 客户<>'"&call_F2&"'"
'elseif call_F1=4 then
		elseif call_F1=5 then
			strCondition=strCondition+" and 客户 like '"& call_F2 &"%'"
'elseif call_F1=5 then
		elseif call_F1=6 then
			strCondition=strCondition+" and 客户 like '%"& call_F2 &"'"
'elseif call_F1=6 then
		end if
	end if
	if call_G2<>"" then
		if call_G1=1 then
			strCondition=strCondition+" and 联系人 like '%"& call_G2 &"%'"
'if call_G1=1 then
		elseif call_G1=2 then
			strCondition=strCondition+" and 联系人 not like '%"& call_G2 &"%'"
'elseif call_G1=2 then
		elseif call_G1=3 then
			strCondition=strCondition+" and 联系人='"&call_G2&"'"
'elseif call_G1=3 then
		elseif call_G1=4 then
'strCondition=strCondition+" and 联系人<>'"&call_G2&"'"
		elseif call_G1=4 then
		elseif call_G1=5 then
			strCondition=strCondition+" and 联系人 like '"& call_G2 &"%'"
'elseif call_G1=5 then
		elseif call_G1=6 then
			strCondition=strCondition+" and 联系人 like '%"& call_G2 &"'"
'elseif call_G1=6 then
		end if
	end if
	call_ret=trim(request("ret"))
	call_ret2=trim(request("ret2"))
	if len(trim(call_ret))<12 and len(call_ret)>0 then
		call_ret=call_ret&" 00:00:00"
	end if
	if len(trim(call_ret2))<12 and len(call_ret2)>0  then
		call_ret2=call_ret2&" 23:59:59"
	end if
	if call_ret<>"" then
		strCondition=strCondition + " and 通话时间 - '"&call_ret&"' >= 0 "
'if call_ret<>"" then
	end if
	If  call_ret2<>"" Then
		strCondition=strCondition + " and 通话时间 - '"&call_ret2&"' <= 0 "
'If  call_ret2<>"" Then
	end if
	baseSQL="select PAGE_COUNT_NUM from (select PAGE_TOP_NUM * from (select a.ord as ord_ID,"
	if request("export")="" then
		baseSQL=baseSQL&"a.ord as 选择,"
	else
		baseSQL=baseSQL&"a.ord as 序号,"
	end if
	baseSQL=baseSQL&"a.phone as 通话号码,a.ord * 1 as 序号_ID,a.del as del_ID,a.statusData as statusData_ID,a.company as 客户_ID," & vbcrlf &_
	"a.person as 联系人_ID,a.status as status_ID,a.addcate as addcate_ID,b.sort as gj1_ID," & vbcrlf &_
	"b.sort1 as gj2_ID,a.recordUrl as 录音地址_ID," & vbcrlf &_
	"a.talktime as 通话时长_DOSUM, dbo.CallGetStatus(a.status) as 通话状态,a.adddate as 通话时间,isnull(b.name,'') as 客户," & vbcrlf &_
	"isnull(c.name,'') as 联系人,isnull(d.name,'') as 登记者,'' as 录音,'' as 操作,ISNULL(b.cateid,0) cateid_ID,mobilecall as mobilecall_ID  " & vbcrlf &_
	"from call a with(nolock) " & vbcrlf &_
	"left join tel b with(nolock) on a.company=b.ord " & vbcrlf &_
	"left join person c with(nolock) on a.person=c.ord " & vbcrlf &_
	"left join gate d with(nolock) on a.addcate=d.ord " & vbcrlf &_
	"where 1=1 " & strCon & ") bbb  where 1=1 " & strCondition &" PAGE_ORDER_STR ) ccc where 1=1"
	dim gather
	set gather=new GatherList
	If Len(request.cookies("cookieWidth_87401")) = 0 Then
		Response.Cookies("cookieWidth_87401").Expires= (now()+7)
'If Len(request.cookies("cookieWidth_87401")) = 0 Then
		Response.cookies("cookieWidth_87401") = "0,83,119,0,0,0,0,0,0,0,0,0,0,103,100,152,139,136,119,77,72,0"
	end if
	with gather
	.digits=NumDigits
	.title="通话列表"
	.FieldsSettingIndex=87401
	.PageSize=cint(page_count)
	.CurrPage=clng(CurrPage)
	.px=px
	.CanTotalSum=true
	.CanPageSum=true
	.CantPXFields="操作,录音"
	.CantExportFields="操作,录音"
	.CanProcPage=True
	.ShowDebug=False
	.ExportChangeStyleFields="通话时长_DOSUM"
	.baseSQL=baseSQL
	.PKName="序号_ID"
	.fieldsList="*"
	.DelBatch=True
	.DelID="选择"
	.QxSort1=74
	.FiledAdd="addcate_ID"
	.strCondition=strCondition
	if request("export")<>"" then
		.ExportFileName=.title&"_"&session("name2006chen")&"_"&date
		.export
	else
		.run
	end if
	end with
	Set gather = Nothing
	function CustomShowFields(idx,rsobj)
		dim rst
		set rst=server.CreateObject("adodb.recordset")
		select case rsobj(idx).name
		case "选择"
		case "序号"
		xuhao=xuhao+1
		case "序号"
		Response.write xuhao
		case "通话时长_DOSUM"
		if rsobj("通话时长_DOSUM")<>"" then
			Response.write(conn.execute("select dbo.CallGetTimeLenth("&rsobj("通话时长_DOSUM")&")")(0))
		end if
		case "通话号码"
		Response.write "<div style='align:left;mso-number-format:""\@"";'>" & GetPhoneNumber(rsobj("通话号码"), rsobj("cateid_ID")) & "</div>"
		case "通话号码"
		if rsobj("通话号码")<>"" and tp=1 then
			if request("export")="" then
				if rsobj("客户_ID")<>"" then
					Response.write("<img src=""../images/15.gif"" onClick=""getCall('../china/bh.asp?ordtype=0&ord="&(rsobj("客户_ID"))&"&phone="&rsobj("通话号码")&"')"" style=""cursor:hand"" border=""0"" align=""absbottom"">")
				else
					Response.write("<img src=""../images/15.gif"" onClick=""getCall('../china/bh.asp?phone=" & replace(rsobj("通话号码").value & "",vbcrlf ,"") &"')"" style=""cursor:hand"" border=""0"" align=""absbottom"">")
				end if
			end if
		end if
		if request("export")="" then
			if open_67_13=1 and open_67_19<>1 and isMobile(rsobj("通话号码")) then
				If IsPhonePower(rsobj("cateid_ID")) Then
					mobileNum = trim(rsobj("通话号码"))
					from = "normal"
				else
					mobileNum = HexEncode(trim(rsobj("通话号码")))
					from = "encrypt"
				end if
				Response.write("<img src=""../images/message.gif"" onClick=""javascript:window.open('../message/topadd.asp?from="&from&"&phone="&mobileNum&"','newsSendSMS','width=' + 900 + ',height=' + 800 + ',fullscreen =no,scrollbars=1,toolbar=0, status=no,resizable=1,location=no,menubar=no,menubar=no,left=200,top=100')""style=""cursor:hand"" border=""0"" alt=""发送短信"" align=""absbottom"">")
			end if
		end if
		case "客户"
		companyid=rsobj("客户_ID").value
		if companyid<>"" And companyid<>0 Then
			rst.open "select cateid,share,sort3 from tel with(nolock) where  ord="&companyid&"",conn,3,1
			if not rst.eof then
				cateid=rst(0)
				share = Replace(rst(1)&""," ","")
				telsort3=rst(2)
			else
				share = ""
				cateid=0
				telsort3=0
			end if
			rst.close
			if telsort3=1 then
				If open_1_1=3 Or (open_1_1=1 And  CheckPurview(intro_1_1,trim(cateid))=True And trim(cateid)<>"0") Or share = "1" Or CheckPurview(share,trim(cateid))=True Then
					if request("export")="" then
						if open_1_14=3 or (open_1_14=1 And  CheckPurview(intro_1_14,trim(cateid))=True And trim(cateid)<>"0") then
							Response.write("<a href=""javascript:void(0)"" onClick=""javascript:window.open('../work/content.asp?ord="&pwurl(trim(rsobj("客户_ID")))&"','newwinc','width=' + 900 + ',height=' + 800 + ',fullscreen =no,scrollbars=1,toolbar=0, status=no,resizable=1,location=no,menubar=no,menubar=no,left=200,top=100')""style=""cursor:hand"" border=""0"" title=""点击查看客户详情"" align=""absbottom"">"&trim(rsobj("客户"))&"</a>")
						else
							Response.write trim(rsobj("客户"))
						end if
					else
						Response.write trim(rsobj("客户"))
					end if
				end if
			else
				If open_26_1=3 Or (open_26_1=1 And  CheckPurview(intro_26_1,trim(cateid))=True And trim(cateid)<>"0") Or share = "1" Or CheckPurview(share,trim(cateid))=True Then
					if request("export")="" then
						if open_26_14=3 or (open_26_14=1 And  CheckPurview(intro_26_14,trim(cateid))=True And trim(cateid)<>"0") then
							Response.write("<a href=""javascript:void(0)"" onClick=""javascript:window.open('../work/content.asp?ord="&pwurl(trim(rsobj("客户_ID")))&"','newwinc','width=' + 900 + ',height=' + 800 + ',fullscreen =no,scrollbars=1,toolbar=0, status=no,resizable=1,location=no,menubar=no,menubar=no,left=200,top=100')""style=""cursor:hand"" border=""0"" title=""点击查看客户详情"" align=""absbottom"">"&trim(rsobj("客户"))&"</a>")
						else
							Response.write trim(rsobj("客户"))
						end if
					else
						Response.write trim(rsobj("客户"))
					end if
				end if
			end if
		else
			telnum = rsobj("通话号码") & ""
			Select Case Trim(telnum)
			Case "10086" : Response.write "中国移动"
			Case "10000" : Response.write "中国电信"
			Case "10010" : Response.write "中国联通"
			Case else
			Response.write ""
			End Select
		end if
		case "联系人"
		personid=rsobj("联系人_ID")
		if  personid<>"" then
			rst.open "select cateid from person with(nolock) where  ord="&personid&"",conn,3,1
			if not rst.eof then
				cateid=rst(0)
			else
				cateid=0
			end if
			rst.close
			If  open_2_1=3 Or (open_2_1=1 And  CheckPurview(intro_2_1,trim(cateid))=True And trim(cateid)<>"0") Then
				if request("export")="" then
					if open_2_14=3 or (open_2_1=1 And  CheckPurview(intro_2_14,trim(cateid))=True And trim(cateid)<>"0") then
						Response.write("<a href=""javascript:void(0)"" onClick=""javascript:window.open('../person/content.asp?ord="&pwurl(trim(rsobj("联系人_ID")))&"','newwinp','width=' + 900 + ',height=' + 800 + ',fullscreen =no,scrollbars=1,toolbar=0, status=no,resizable=1,location=no,menubar=no,menubar=no,left=200,top=100')"" style=""cursor:hand"" border=""0"" title=""点击查看联系人详情"" align=""absbottom"">"&trim(rsobj("联系人"))&"</a>")
					else
						Response.write trim(rsobj("联系人"))
					end if
				else
					Response.write trim(rsobj("联系人"))
				end if
			end if
		else
			Response.write ""
		end if
		case "录音"
		If rsobj("通话状态") <> "未接" Then
			If rsobj("mobilecall_ID") Then
				Response.write("<div align='center'>手机导入，无录音</div>")
			else
				recordUrl=rsobj("录音地址_ID")
				newRecordUrl=""
				if  (trim(rsobj("statusData_ID"))="") or isnull(rsobj("statusData_ID")) then
					isOldData=true
				else
					isOldData=false
				end if
				if isOldData then
					if recordUrl<>"" and isnull(recordUrl)=false then
						if RegTest(recordUrl,"^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*(\:[0-9]*)?\/*[0-9]*.*$") or RegTest(recordUrl,"^[\w\d]*\.[\w\d]*\.[\w\d]*\/*.*$") then
'if recordUrl<>"" and isnull(recordUrl)=false then
							recordUrlArr=split(recordUrl,"/")
							for j=0 to ubound(recordUrlArr)
								if j<>0 then
									newRecordUrl=newRecordUrl&"/"&recordUrlArr(j)
								end if
							next
						else
							newRecordUrl=recordUrl
						end if
					end if
					if left(trim(newRecordUrl),1)="/" then
						checkurl="../recordWav"&newRecordUrl
					else
						checkurl="../recordWav/"&newRecordUrl
					end if
				else
					checkurl="../ocx/CtlEvent.asp?__msgId=openwavfile%26id="&trim(rsobj("ord_ID"))
				end if
				if isOldData then
					if (recordUrl<>""  and CheckLocalFileExist(checkurl) ) then
						if open_74_13=1 or open_74_13=3 or CheckPurview(intro_74_13,trim(session("personzbintel2007")))=True then
							Response.write "" & vbcrlf & "                                             <div align='center'><input type=""button"" name=""play"" value=""播放"" class=""anybutton""  onClick=""getCall1('player.asp?url="
							Response.write checkurl
							Response.write "')""/></div>" & vbcrlf & "                                               "
						else
							Response.write("<div align='center'>已录音</div>")
						end if
					else
						Response.write("<div align='center'>没有录音</div>")
					end if
				else
					if open_74_13=1 or open_74_13=3 or CheckPurview(intro_74_13,trim(session("personzbintel2007")))=True then
						Response.write "" & vbcrlf & "                                             <div align='center'><input type=""button"" name=""play"" value=""播放"" class=""anybutton""  onClick=""getCall1('player.asp?url="
						Response.write checkurl
						Response.write "')""/></div>" & vbcrlf & "                                               "
					else
						Response.write("<div align='center'>已录音</div>")
					end if
				end if
			end if
		end if
		case "ord"
		Response.write("<div align='center'>"&rsobj("选择").value &"</div>")
		case "操作"
		Response.write "" & vbcrlf & "<div align=""center"">" & vbcrlf & ""
		if  open_74_3=3 or CheckPurview(intro_74_3,trim(rsobj("addcate_ID").value))=True then
			Response.write "" & vbcrlf & "<input type=""button"" name=""Submitdel"" class=""anybutton"" value=""删除"" onClick=""if(confirm('确认删除？')){window.location.href='Delete.asp?ord="
			Response.write rsobj("序号_ID")
			Response.write "&CurrPage="
			Response.write CurrPage
			Response.write "&A1="
			Response.write A1
			Response.write "&page_count="
			Response.write page_count
			Response.write "&px="
			Response.write px
			Response.write "&ret="
			Response.write m1
			Response.write "&ret2="
			Response.write m2
			Response.write "&F1="
			Response.write F1
			Response.write "&F2="
			Response.write F2
			Response.write "&W1="
			Response.write W1
			Response.write "&W2="
			Response.write W2
			Response.write "&W3="
			Response.write W3
			Response.write "&S1="
			Response.write S1
			Response.write "&S2="
			Response.write S2
			Response.write "&E="
			Response.write E
			Response.write "&F="
			Response.write F
			Response.write "&company="
			Response.write company
			Response.write "&person="
			Response.write person
			Response.write "'}""/>" & vbcrlf & ""
		end if
		Response.write "</div>" & vbcrlf & ""
		case else
		Response.write "<div align='center'>"&rsobj(idx).value &"</div>"
		end select
		set rst=nothing
	end function
	sub ShowSearchDiv()
		Response.write "" & vbcrlf & "     <div id=""dd"" class=""easyui-window"" icon=""icon-search"" title=""高级检索""  style=""visibility:hidden;width:610px;height:400px;padding:2px;background: #fafafa;top:0px;""  closed=""true"" >" & vbcrlf & "        <input name=""needhidedlgdiv"" type=""hidden"">" & vbcrlf & "    <div region=""center"" border=""false"" class='needhide' style=""padding:5px;background:#fff;border:1px solid #ccc;width:565px;"">" & vbcrlf & " <form name=""form2"" method=""get"" id=""searchform"">" & vbcrlf & "      <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & " <tr>" & vbcrlf & "    <td rowspan=""2"" width=""60""><div align=""right"">人员选择：</div></td>" & vbcrlf & "   <td onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "               <input type=""checkbox"" name=""call_A1"" value=""2"" />" & vbcrlf & "          呼出" & vbcrlf & "            <input type=""checkbox"" name=""call_A1"" value=""1"" />" & vbcrlf & "            呼入" & vbcrlf & "                       <input type=""checkbox"" name=""call_A1"" value=""3"" />" & vbcrlf & "         黑名单" & vbcrlf & "          <input type=""checkbox"" name=""call_A1"" value=""0"" />" & vbcrlf & "            未接" & vbcrlf &"         </td>" & vbcrlf & "   </tr>" & vbcrlf & "   <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "         <td>"
		if sort_zjjg="" or isnull(sort_zjjg) then
			sort_zjjg=1
		end if
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select sort1,qx_open,w1,w2,w3 from power2  where cateid="&session("personzbintel2007")&" and sort1="&sort_zjjg&" "
		rs1.open sql1,conn,1,1
		if rs1.eof then
			open_1_1=0
		else
			open_1_1=rs1("qx_open")
			w1=rs1("w1")
			w2=rs1("w2")
			w3=rs1("w3")
		end if
		rs1.close
		set rs1=nothing
		if open_1_1=1 then
			str_w1="and ord in ("&w1&")"
			str_w2="and ord in ("&w2&")"
			str_w3="and ord in ("&w3&")"
		elseif open_1_1=3 then
			str_w1=""
			str_w2=""
			str_w3=""
		else
			str_w1="and ord=0"
			str_w2="and ord=0"
			str_w3="and ord=0"
		end if
		Correct_W1=0
		Correct_W2=0
		Correct_W3=user_list
		if Correct_W3<>"" and Correct_W3<>"0" then
			tmp=split(getW1W2(Correct_W3),";")
			Correct_W1=tmp(0)
			Correct_W2=tmp(1)
		end if
		Dim SeaStr
		SeaStr = ""
		If IsType = 1 Then
			If Len(dongjie)>0 And dongjie=1 then
				SeaStr = SeaStr & " or del = 2"
			end if
			If Len(huishouzhan)>0 And huishouzhan=1 then
				SeaStr = SeaStr & " or del = 5"
			end if
		end if
		ReDim d_at(54)
		d_at(0) = "Class UserTreeNodeItem"
		d_at(1) = "  Public Nodes,  NodeText,  NodeId,  orgstype,  wsign,del, parent, checked"
		d_at(4) = "  Public Sub setparent(ByRef p) : Set parent = p : End sub"
		d_at(5) = "  Public Function GetJSON()"
		d_at(6) = "          GetJSON = ""{text:"""""" & NodeText & """""",value:"" & NodeId & "",datas:[0,"" & orgstype & ""],wsign:"" & wsign & "", checked:"" & Abs(checked) & "",nodes:"" & nodes.GetJSON & "",del:"" & del & "" }"""
		d_at(7) = "  End function"
		d_at(8) = "End Class"
		d_at(11) = "Class UserTreeNodeList"
		d_at(12) = "        public items,  count, curr"
		d_at(13) = "        Public Sub setcurr(ByRef c)"
		d_at(14) = "                Set curr = c"
		d_at(15) = "        End sub"
		d_at(17) = "        Public Sub Dispose"
		d_at(18) = "                Dim i : Set curr = nothing"
		d_at(19) = "                For i = 0 To count-1"
'd_at(18) = "                Dim i : Set curr = nothing"
		d_at(20) = "                        items(i).Dispose :  Set items(i) = nothing"
		d_at(21) = "                Next"
		d_at(22) = "                Erase items"
			d_at(23) = "		End Sub"
		d_at(24) = "        Public function Add(ByRef rs, ByRef w3v, ByRef orgsv, byref realw3)"
		d_at(25) = "                Dim item : Set item = New UserTreeNodeItem"
		d_at(26) = "                If isobject(curr) then  item.setparent curr"
		d_at(27) = "                item.nodetext = rs(""NodeText"").value"
		d_at(28) = "                item.nodeid = rs(""NodeId"").value"
		d_at(29) = "                item.del = rs(""del"").value"
		d_at(30) = "                item.orgstype =  rs(""orgstype"").value"
		d_at(31) = "                item.wsign = rs(""wsign"").value"
		d_at(32) = "                If item.wsign = 3 Then "
		d_at(33) = "                         item.checked = InStr("","" & w3v & "","",  "","" & item.nodeid & "","") > 0 " & vbcrlf & _
		"   if item.checked then " & vbcrlf & _
		"           if len(realw3)>0 then realw3 = realw3 & "","" " & vbcrlf & _
		"           realw3 = realw3 & item.nodeid " & vbcrlf &_
		"   end if"
		d_at(34) = "                Else"
		d_at(35) = "                         item.checked = InStr("","" & orgsv & "","",  "","" & item.nodeid & "","") > 0"
		d_at(36) = "                End If"
		d_at(37) = "                ReDim Preserve items(count)"
		d_at(38) = "                Set items(count) = item"
		d_at(39) = "                Set Add = item"
		d_at(40) = "                count = count + 1"
'd_at(39) = "                Set Add = item"
		d_at(41) = "        End Function"
		d_at(42) = "        Public Function GetJSON"
		d_at(43) = "                Dim i, html "
		'd_at(44) = "                If count>0 Then "
		d_at(45) = "                        ReDim html(count-1)"
''d_at(44) = "                If count>0 Then "
		d_at(46) = "                        For i = 0 To count -1 "
		''d_at(44) = "                If count>0 Then "
		d_at(47) = "                                html(i) = items(i).getJSON()"
		d_at(48) = "                        Next"
		d_at(49) = "                        GetJSON = ""["" & Join(html,"","") & ""]"""
		d_at(50) = "                Else"
		d_at(51) = "                        GetJSON = ""[]"""
		d_at(52) = "                End if"
		d_at(53) = "        End function"
		d_at(54) = "End Class"
		execute "On Error Resume Next : ExecuteGlobal Join(d_at, vbcrlf)"
		ReDim d_at(61)
		d_at(0) = "'复选树" & vbCrLf
		d_at(1) = "Function CBaseUserTreeHtml(ByVal sql, ByVal orgsname, ByVal w1name, ByVal w2name, ByVal w3name, ByVal orgsvalue, ByVal w1value,  ByVal w2value,  ByVal w3value)" & vbCrLf
		d_at(2) = " CBaseUserTreeHtml = CBaseUserTreeHtmlCore(sql, orgsname, w1name, w2name, w3name, orgsvalue, w1value, w2value, w3value, ""checkbox"", """")" & vbCrLf
		d_at(3) = "End Function" & vbCrLf
		d_at(4) = "'单选树" & vbCrLf
		d_at(5) = "Function CBaseUserTreeHtmlRadio(ByVal sql, ByVal orgsname, ByVal w1name, ByVal w2name, ByVal w3name, ByVal orgsvalue, ByVal w1value,  ByVal w2value,  ByVal w3value)" & vbCrLf
		d_at(6) = " CBaseUserTreeHtmlRadio = CBaseUserTreeHtmlCore(sql, orgsname, w1name, w2name, w3name, orgsvalue, w1value, w2value, w3value, ""radio"", """")" & vbCrLf
		d_at(7) = "End Function" & vbCrLf
		d_at(8) = "'带事件的单选树" & vbCrLf
		d_at(9) = "Function CBaseUserTreeHtmlRadioCE(ByVal sql, ByVal orgsname, ByVal w1name, ByVal w2name, ByVal w3name, ByVal orgsvalue, ByVal w1value,  ByVal w2value,  ByVal w3value, ByVal changeEvent)" & vbCrLf
		d_at(10) = "        CBaseUserTreeHtmlRadioCE = CBaseUserTreeHtmlCore(sql, orgsname, w1name, w2name, w3name, orgsvalue, w1value, w2value, w3value, ""radio"",  changeEvent)" & vbCrLf
		d_at(11) = "End Function" & vbCrLf
		d_at(12) = "'生成树基本方法" & vbCrLf
		d_at(13) = "Function CBaseUserTreeHtmlCore(byref sql, byref orgsname, byref w1name, byref w2name, byref w3name, byref orgsvalue, byref w1value,  byref w2value,  byref w3value, ByVal checktype, ByVal changeEvent)" & vbCrLf
		d_at(14) = "        Dim htmlid,  htmlsortid, rs, pdeep, currdeep, i, fc, nd, basenodes, nodes, realw3" & vbCrLf
		d_at(15) = "        Randomize :     pdeep =  0 : fc = 0" & vbCrLf
		d_at(16) = "        w3value = Replace(w3value & """","" "","""")" & vbCrLf
		d_at(17) = "        orgsvalue = Replace(orgsvalue & """", "" "" , """")" & vbCrLf
		d_at(18) = "        htmlsortid =CLng(rnd*1000000)" & vbCrLf
		d_at(19) = "        htmlid = ""basetreedata"" & htmlsortid" & vbCrLf  & " on error resume next " & vbcrlf & "if isobject(conn) = false then set conn = cn" & vbcrlf
		d_at(20) = "        on error resume next : Set rs = conn.execute(""exec erp_comm_UsersTreeBase '"" & Replace(sql, ""'"", ""''"") & ""',0"")" & vbCrLf
		d_at(21) = "  if err.number <> 0 then CBaseUserTreeHtmlCore = ""UsersTreeBase错误，SQL:"" & ""exec erp_comm_UsersTreeBase '"" & Replace(sql, ""'"", ""''"") & ""',0"" & "","" & err.description : exit function" & vbcrlf
		d_at(22) = "        Set basenodes = New UserTreeNodeList" & vbCrLf
		d_at(23) = "        Set nodes = basenodes" & vbCrLf
		d_at(24) = "        while rs.eof = False" & vbCrLf
		d_at(25) = "                currdeep =  rs(""NodeDeep"").value" & vbCrLf
		d_at(26) = "                If currdeep > pdeep Then " & vbCrLf
		d_at(27) = "                        Set nodes = nd.nodes" & vbCrLf
		d_at(28) = "                ElseIf currdeep<pdeep then" & vbCrLf
		d_at(29) = "                        For i = currdeep To pdeep" & vbCrLf
		d_at(30) = "                                Set nd = nd.parent" & vbCrLf
		d_at(31) = "                        Next" & vbCrLf
		d_at(32) = "                        If nd Is Nothing Then Err.rasie ""1212"", ""asa"", currdeep & ""=="" & pdeep" & vbCrLf
		d_at(33) = "                        Set nodes = nd.nodes" & vbCrLf
		d_at(34) = "                End If" & vbCrLf
		d_at(35) = "                Set nd = nodes.Add(rs, w3value, orgsvalue, realw3)" & vbCrLf
		d_at(36) = "                pdeep = currdeep" & vbCrLf
		d_at(37) = "                rs.movenext" & vbCrLf
		d_at(38) = "        wend" & vbCrLf
		d_at(39) = "        rs.close" & vbCrLf
		d_at(40) = "       Set rs = Nothing" & vbCrLf
		d_at(41) = "       Dim json : json = ""{nodes:"" & basenodes.getJSON & ""}""" & vbCrLf
		d_at(42) = "       Set nodes = basenodes.Items(0).nodes" & vbCrLf
		d_at(43) = "       For i = 0 To nodes.count-1" & vbCrLf
'd_at(42) = "       Set nodes = basenodes.Items(0).nodes" & vbCrLf
		d_at(44) = "               If nodes.items(i).orgstype = 0 Then" & vbCrLf
		d_at(45) = "                       fc = fc + 1" & vbCrLf
'd_at(44) = "               If nodes.items(i).orgstype = 0 Then" & vbCrLf
		d_at(46) = "               End if" & vbCrLf
		d_at(47) = "       next" & vbCrLf
		d_at(48) = "       basenodes.dispose" & vbCrLf
		d_at(49) = "       Set basenodes = nothing" & vbCrLf
		d_at(50) = "       json = Replace(json,"""""""",""&#34;"")" & vbCrLf
		d_at(51) = "       json = Replace(json,""<"",""&#60;"")" & vbCrLf
		d_at(52) = "       json = Replace(json,"">"",""&#62;"")" & vbCrLf
		d_at(53) = "       json = Replace(json,""&"",""&#38;"")" & vbCrLf
		d_at(54) = "       Dim inputhtml :  inputhtml = """"" & vbCrLf
		d_at(55) = "       If Len(orgsname)>0 Then inputhtml = inputhtml & ""<input checked type='"" & checktype & ""' style='display:none' id='"" & htmlid & ""_orgs' name='"" & orgsname & ""' value='"" &  orgsvalue & ""'>""" & vbCrLf
		d_at(56) = "       If Len(w1name)>0 Then inputhtml = inputhtml & ""<input checked type='"" & checktype & ""' style='display:none'  id='"" & htmlid & ""_w1' name='"" & w1name & ""' value='"" &  w1value & ""'>""" & vbCrLf
		d_at(57) = "       If Len(w2name)>0 Then inputhtml = inputhtml & ""<input checked type='"" & checktype & ""' style='display:none'  id='"" & htmlid & ""_w2' name='"" & w2name & ""' value='"" &  w2value & ""'>""" & vbCrLf
		d_at(58) = "       If Len(w3name)>0 Then inputhtml = inputhtml & ""<input checked type='"" & checktype & ""' style='display:none'  id='"" & htmlid & ""_w3' name='"" & w3name & ""' value='"" &  realw3 & ""'>""" & vbCrLf
		d_at(59) = "       If Len(changeEvent) > 0 Then changeEvent = "" changeEvent="""""" & Replace(changeEvent,"""""""",""&#34;"") & """""" """ & vbCrLf
		d_at(60) = "       CBaseUserTreeHtmlCore = (inputhtml & ""<iframe ""& changeEvent &"" id='"" & htmlid & ""' json="""""") &  json & ("""""" scrolling='no' frameborder='0' src='"" & sdk.getvirpath & ""sdk/baseusertree.htm?checktype="" & checktype &""&signid="" & htmlid & ""' style='background-color:white;display:block;width:96%;height:"" & ((fc+2)*20+12) & ""px'></iframe>"")" & vbCrLf
		d_at(61) = "End function"
		execute "On Error Resume Next : ExecuteGlobal Join(d_at, vbcrlf)"
		If Len(Correct_W3)=0 Then Correct_W3 = request.form("W3") & ""
		If Len(Correct_W3)=0 Then Correct_W3 = request.querystring("W3") & ""
		Response.write  CBaseUserTreeHtml("select ord,orgsid from gate where 1=1 "&str_w3&" and (del=1 "&SeaStr&")","orgsid", "W1","W2","W3",  "", w1, w2, Correct_W3)
		
		Response.write "</td>" & vbcrlf & "        </tr>" & vbcrlf & "           <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "               <td><div align=""right"">客户分类：</div></td>" & vbcrlf & "              <td>" & vbcrlf & "            "
		dim i5
		i5=1
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select * from sort4 order by gate1 desc"
		rs1.open sql1,conn,3,1
		if rs1.eof then
			Response.write "&nbsp;"
		else
			do until rs1.eof
				Response.write "" & vbcrlf & "                             <input name=""E"" type=""checkbox"" value="""
				Response.write rs1("ord")
				Response.write """ "
				if instr(","&Replace(call_E," ","")&",",","&rs1("ord")&",")>0 then
					Response.write " checked=""checked"""
				end if
				Response.write " id=""e"
				Response.write i5
				Response.write """ onClick=document.getElementById('u"
				Response.write i5
				Response.write "').style.display=(this.checked==1?'':'none');checkAll2("""
				Response.write i5
				Response.write """)>"
				Response.write rs1("sort1")
				Response.write "" & vbcrlf & "                               <div id=""u"
				Response.write i5
				Response.write """  style=""border:1px  dotted  #000000;"
				if instr(","&Replace(call_E," ","")&",",","&rs1("ord")&",")=0 or Replace(call_E," ","")="" then
					Response.write "display:none;"
				end if
				Response.write """>" & vbcrlf & "                          "
				set rs2=server.CreateObject("adodb.recordset")
				sql2="select * from sort5  where sort1="&rs1("ord")&" order by gate2 desc"
				rs2.open sql2,conn,3,1
				if rs2.eof then
					Response.write "&nbsp;"
				else
					do until rs2.eof
						Response.write "" & vbcrlf & "                                              <span class='gray'><input name='F' type='checkbox' value='"
						Response.write rs2("ord")
						Response.write "' "
						if instr(","&Replace(call_F," ","")&",",","&rs2("ord")&",")>0 then
							Response.write " checked=""checked"""
						end if
						Response.write " onClick=fixChk2('"
						Response.write i5
						Response.write "')>"
						Response.write rs2("sort2")
						Response.write "</span>" & vbcrlf & "                                               "
						rs2.movenext
					loop
				end if
				rs2.close
				set rs2=Nothing
				Response.write "" & vbcrlf & "                              </div>" & vbcrlf & "                          "
				i5=i5+1
				Response.write "" & vbcrlf & "                              </div>" & vbcrlf & "                          "
				rs1.movenext
			loop
		end if
		rs1.close
		set rs1=nothing
		Response.write "" & vbcrlf & "              </td></tr>" & vbcrlf & "" & vbcrlf & "              <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "           <td><div align=""right"">通话号码：</div></td>" & vbcrlf & "              <td><select name=""call_S1"">" & vbcrlf & "               <option value=""1"">包含</option>" & vbcrlf & "               <option value=""2"">不包含</option>" & vbcrlf & "         <option value=""3"">等于</option>" & vbcrlf & "           <option value=""4"">不等于</option>" & vbcrlf & "         <option value=""5"">以..开始</option>" & vbcrlf & "               <option value=""6"">以..结束</option>" & vbcrlf & "               </select>" & vbcrlf & "               <input name=""call_S2"" type=""text"" size=""15"" /></td>" & vbcrlf & "            </tr>" & vbcrlf & "           <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "           <td><div align=""right"">客户名称：</div></td>" & vbcrlf & "              <td><select name=""call_F1"">" & vbcrlf & "             <option value=""1"">包含</option>" & vbcrlf & "           <option value=""2"">不包含</option>" & vbcrlf & "         <option value=""3"">等于</option>" & vbcrlf & "           <option value=""4"">不等于</option>" & vbcrlf & "         <option value=""5"">以..开始</option>" & vbcrlf & "               <option value=""6"">以..结束</option>" & vbcrlf & "               </select>" & vbcrlf & "             <input name=""call_F2"" type=""text"" size=""15""></td>" & vbcrlf & "             </tr>" & vbcrlf & "           <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "           <td><div align=""right"">联系人：</div></td>" & vbcrlf & "                <td><selectname=""call_G1"">" & vbcrlf & "               <option value=""1"">包含</option>" & vbcrlf & "           <option value=""2"">不包含</option>" & vbcrlf & "         <option value=""3"">等于</option>" & vbcrlf & "           <option value=""4"">不等于</option>" & vbcrlf & "         <option value=""5"">以..开始</option>" & vbcrlf & "               <option value=""6"">以..结束</option>" & vbcrlf & "             </select>" & vbcrlf & "               <input name=""call_G2"" type=""text"" size=""15""></td>" & vbcrlf & "             </tr>" & vbcrlf & "       <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "          <td><div align=""right"">通话时间：</div></td>" & vbcrlf & "          <td>&nbsp;自：" & vbcrlf & "            <INPUT name=""ret"" size=18  id=daysOfMonthPos onClick=""datedlg.showDateTime();"" readonly value="""
		Response.write ret
		Response.write """>&nbsp;至:<INPUT name=""ret2"" size=18  id=daysOfMonth2Pos  onclick=""datedlg.showDateTime();"" readonly value="""
		Response.write ret2
		Response.write """></td>" & vbcrlf & "        </tr>" & vbcrlf & "      </table>" & vbcrlf & "         <input type=""hidden"" name=""sflg"" value=""1"">" & vbcrlf & "           <input name=""person"" type=""hidden"" value="""
		Response.write person
		Response.write """>" & vbcrlf & "         <input name=""company"" type=""hidden"" value="""
		Response.write company
		Response.write """>" & vbcrlf & "         <input type=""hidden"" name=""page_count"" value="""
		Response.write page_count
		Response.write """>" & vbcrlf & "         <input type=""hidden"" name=""px"" value="""
		Response.write px
		Response.write """>" & vbcrlf & "   </form>" & vbcrlf & "    </div>" & vbcrlf & "    <div region=""south"" border=""false"" style=""text-align:right;height:30px;line-height:30px;"">" & vbcrlf & "             <a class=""easyui-linkbutton"" icon=""icon-search"" href=""javascript:void(0)"" onClick=""document.getElementById('searchform').submit();return false;"">检索</a><a class=""easyui-linkbutton"" icon=""icon-cancel"" href=""javascript:void(0)"" onClick=""$('#dd').window('close');"">取消</a><a class=""easyui-linkbutton"" icon=""icon-undo"" href=""javascript:void(0)"" onClick=""resetForm();"">清空</a>" & vbcrlf & "      </div>"& vbcrlf &  " </div>" & vbcrlf
	end sub
	sub ShowGatherListHTMLFootExtend()
		Response.write "" & vbcrlf & "<script language =""javascript"">" & vbcrlf & "var strW1="","
		Response.write strW1
		Response.write ","";" & vbcrlf & "var strW2="","
		Response.write strW2
		Response.write ","";" & vbcrlf & "var strW3="","
		Response.write strW3
		Response.write ","";" & vbcrlf & "var wobj=document.getElementById(""dd"").getElementsByTagName(""input"");" & vbcrlf & "for(var i=0;i<wobj.length;i++)" & vbcrlf & "{" & vbcrlf & "        if(wobj[i].name)" & vbcrlf & "        {" & vbcrlf & "               if(wobj[i].name==""W1""&&strW1.indexOf(','+wobj[i].value+',')>=0)" & vbcrlf & "           {" & vbcrlf & "                    wobj[i].click();" & vbcrlf & "                }" & vbcrlf & "               else if(wobj[i].name==""W2""&&strW2.indexOf(','+wobj[i].value+',')>=0)" & vbcrlf & "              {" & vbcrlf & "                       wobj[i].click();" & vbcrlf & "                }" & vbcrlf & "               else if(wobj[i].name==""W3"")" & vbcrlf & "               {" & vbcrlf & "                       wobj[i].checked=(strW3.indexOf(','+wobj[i].value+',')>=0)" & vbcrlf & "             }" & vbcrlf & "       }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "//批量删除，如开启要重写这个函数" & vbcrlf & "function DelBatch()" & vbcrlf & "{" & vbcrlf & "  var StrResult=""删除失败"";" & vbcrlf & " var list="""";" & vbcrlf & "      var check=$('input[type=""checkbox""][class=""Del_Item_List""]:checked');" & vbcrlf & "" & vbcrlf & " check.each(function()" & vbcrlf & "{" & vbcrlf & "" & vbcrlf & "      if(list=="""")" & vbcrlf & "      {" & vbcrlf & "               list=$(this).val();" & vbcrlf & "             }" & vbcrlf & "       else" & vbcrlf & "    {" & vbcrlf & "               list=list+"",""+$(this).val();" & vbcrlf & "             }" & vbcrlf & " });" & vbcrlf & "" & vbcrlf & "DelList(list);" & vbcrlf & "}" & vbcrlf & "function DelList(list) {" & vbcrlf & "  var url = ""Ajax_Delete.asp?ord=""+list+""&time1="" + new Date().getTime() + ""&date1=""+ Math.round(Math.random()*100);" & vbcrlf & "  xmlHttp.open(""GET"", url, false);" & vbcrlf & "  xmlHttp.onreadystatechange = function(){" & vbcrlf & "  updateDelList();" & vbcrlf & "  };" & vbcrlf & "  xmlHttp.send(null);" & vbcrlf & "}" & vbcrlf & "function updateDelList() {" & vbcrlf & "  if (xmlHttp.readyState < 4) {" & vbcrlf & "  }" & vbcrlf & "  if (xmlHttp.readyState == 4) {" & vbcrlf & "                var StrResult=""您没有选择任何数据，请选择后再删除！""" & vbcrlf & "              var response = xmlHttp.responseText;" & vbcrlf & "                            if(response.indexOf(""</noscript>"")>=0)" & vbcrlf & "                            {" & vbcrlf & "                                       if(response.split(""</noscript>"")[1]==1)" & vbcrlf & "                                   {" & vbcrlf & "                                               StrResult=""删除成功！""" & vbcrlf & "                                               }" & vbcrlf & "                                       }" & vbcrlf & "       alert(""""+StrResult+"""");" & vbcrlf & "     window.location.reload();" & vbcrlf & "       xmlHttp.abort();" & vbcrlf & "  }" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & ""
		Response.write strW3
	end sub
	sub CurstomButtons()
		Response.write "" & vbcrlf & "<input type=""hidden"" name=""px"" value="""
		Response.write px
		Response.write """>" & vbcrlf & "<input type=""hidden"" name=""sflg"" value=""1""/>" & vbcrlf & "<input name=""person"" type=""hidden"" value="""
		Response.write person
		Response.write """>" & vbcrlf & "<input name=""company"" type=""hidden"" value="""
		Response.write company
		Response.write """>" & vbcrlf & "<!--<input type=""submit"" value=""查看"" class=""anybutton""/>-->" & vbcrlf & "<select name=""page_count"" onChange=""if(this.value != ''){gotourl('page_count='+this.value);}"">" & vbcrlf & "  <option value=""10"" "
		Response.write company
		if page_count=10 then
			Response.write "selected"
		end if
		Response.write ">每页显示10条</option>" & vbcrlf & "  <option value=""20"" "
		if page_count=20 then
			Response.write "selected"
		end if
		Response.write ">每页显示20条</option>" & vbcrlf & "  <option value=""50"" "
		if page_count=50 then
			Response.write "selected"
		end if
		Response.write ">每页显示50条</option>" & vbcrlf & "  <option value=""100"" "
		if page_count=100 then
			Response.write "selected"
		end if
		Response.write ">每页显示100条</option>" & vbcrlf & "  <option value=""200"" "
		if page_count=200 then
			Response.write "selected"
		end if
		Response.write ">每页显示200条</option>" & vbcrlf & "</select> 通话时间：<INPUT name=""ret"" size=18 style=""width:132px""  id=daysOfMonthPos onClick=""datedlg.showDateTime();""  value="""
		Response.write request("ret")
		Response.write """ readonly>&nbsp;" & vbcrlf & "至:<INPUT name=""ret2"" size=18 style=""width:132px""  id=daysOfMonth2Pos  onclick=""datedlg.showDateTime();"" value="""
		Response.write request("ret2")
		Response.write """ readonly>" & vbcrlf & "<input type=""button"" class=""anybutton"" value="" 检索 "" onClick=""if(document.getElementById('daysOfMonthPos').value==''&&document.getElementById('daysOfMonth2Pos').value!=''){if(!confirm('没有起始日期，可能检索到大量通话记录,是否确定？')){return false;};};document.getElementById('demo').submit();"" />" & vbcrlf & "<input type=""button"" class=""anybutton"" value=""高级检索"" onClick=""open1();""/>" & vbcrlf & ""
		if open_74_10<>0 then
			Response.write "" & vbcrlf & "<input type=""button"" value=""导出""  onClick=""if(confirm('确定要导出吗？')){window.location.href = ('"
			Response.write request("script_name")
			Response.write "?'+getUrl('export=1'));}"" class=""anybutton""/>" & vbcrlf & ""
			Response.write request("script_name")
		end if
		if open_74_7<>0 then
			Response.write "" & vbcrlf & "<input type=""button"" value=""打印""  onClick=""window.print();"" class=""anybutton""/>" & vbcrlf & ""
		end if
	end sub
	sub CustomShowPageSumFields(vname,v1)
		select case vname
		case "通话时长_DOSUM"
		If Len(v1&"")>0 Then
			Response.write(conn.execute("select dbo.CallGetTimeLenth("&v1&")")(0))
		else
			Response.write 0
		end if
		case else
		Response.write v1
		end select
	end sub
	sub CustomShowTotalSumFields(vname,v1)
		select case vname
		case "通话时长_DOSUM"
		If Len(v1&"")>0 Then
			Response.write(conn.execute("select dbo.CallGetTimeLenth("&v1&")")(0))
		else
			Response.write 0
		end if
		case else
		Response.write v1
		end select
	end sub
	call db_close : Response.end
	
%>
