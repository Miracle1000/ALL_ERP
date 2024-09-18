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
	Function getConnection()
		Dim connText
		if request.querystring("updateconnection")="1" then
			Application("_sys_connection") = ""
		end if
		connText = Application("_sys_connection") & ""
		If Len(connText) = 0 Then
			connText =  getConnectionText()
		end if
		Set conn = server.CreateObject("adodb.connection")
		on error resume next
		conn.open (connText)
		conn.cursorlocation = 3
		conn.CommandTimeout = 600
		if abs(err.number) > 0 then
			Response.write "数据库链接失败 - [" & err.Description & "]"
'if abs(err.number) > 0 then
			call AppEnd
		end if
		Set getConnection = conn
	end function
	Function GetPrintNum(sort,ord)
		Dim cn : Set cn = getConnection()
		If sort&"" = "" Then sort = 0
		If ord&"" = "" Then ord = 0
		Dim rs_Print : Set rs_Print = cn.execute ("select count(1) as PrintNum from PrinterInfo where sort = " & sort & " and formID = " & ord)
		GetPrintNum = rs_Print("PrintNum")
		rs_Print.close
		Set rs_Print = nothing
	end function
	Function GetPrintInfo(cn, datatype , ord , rType)
		Dim rs , times ,csStr , statusStr
		Set rs = cn.execute("select times from printtimes where datatype ="& datatype &" and ord=" & ord)
		If rs.eof = False Then
			statusStr = "<font color=green>[已打印]</font>"
			times =  rs("times").value
		else
			statusStr = "<font color=red>[未打印]</font>"
			times = 0
		end if
		rs.close
		Set rs=Nothing
		Dim withs : withs = 84+8*Len(times)
		Set rs=Nothing
		If rType=2 Then
			csStr = "<input type='button' name='btnPrint1' value='打印记录("& times &"次)'   onClick='javascript:window.open(""../Manufacture/inc/PrinterRrcorderList.asp?formid="& sdk.base64.pwurl(ord)&"&sort="& datatype &""",""newwin88"",""width="" + 900 + "",height="" + 500 + "",fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150"")'  class='anybutton' />"
		else
			csStr = times
		end if
		If rType = 1 Then
			GetPrintInfo = statusStr
		else
			GetPrintInfo = csStr
		end if
	end function
	Function SavePrintInfo(cn)
		dim id, formid, html, rs, [sort], ord, ord1  ,isSum,count
		id = request("id")
		formid = request("ord")
		[sort] = request("sort")
		isSum = request("isSum")
		If isSum&""="" Then isSum = 0
		count = request("count")
		If count&""="" Then count = 0
		html= ""
		if len(formid) = 0 then exit Function
		if len(id) = 0 or isnumeric(id)=0 then exit Function
		if len(sort) = 0 or isnumeric(sort)=0 then exit Function
		Dim oldcount : oldcount = GetPrintInfo(cn,[sort],formid,3)
		If cdbl(oldcount)-CDbl(count)<>0 And count>=0 Then
'Dim oldcount : oldcount = GetPrintInfo(cn,[sort],formid,3)
			SavePrintInfo = "count"
			exit Function
		end if
		on error resume next
		cn.begintrans
		formid = split(formid,",")
		for i = 0 to ubound(formid)
			if isnumeric(formid(i)) Then
				If cn.execute("select 1 from printtimes where datatype ="& [sort] &" and ord=" & formid(i)).eof=true Then
					cn.execute("insert into printtimes (datatype , ord ,times)values ("& [sort] &","& formid(i) &",1) ")
				else
					cn.execute("update printtimes set times = times + 1 where datatype ="& [sort] &" and ord=" & formid(i))
					cn.execute("insert into printtimes (datatype , ord ,times)values ("& [sort] &","& formid(i) &",1) ")
				end if
				cn.execute("insert into PrinterInfo (templateID, formID, sort, html, addCate, addDate,isSum,isOld) values (" & id & ", " & formid(i) & ", " & [sort] & ", '" & html & "', " & session("personzbintel2007") & ", '" & now() & "','"& isSum &"',1)")
				ord = GetIdentity("PrinterInfo","id","addcate","")
				cn.execute ("update PrinterInfo set ord = id where id = " & ord)
				cn.execute ("insert into PrinterHistory (PrinterInfoID, PrintCate, PrintDate) values (" & ord & ", " & session("personzbintel2007") & ", '" & now() & "')")
				ord1 = GetIdentity("PrinterHistory","id","PrintCate","")
				cn.execute ("update PrinterHistory set ord = id where id = " & ord1)
			end if
		next
		if err.number <> 0 Then
			cn.RollBackTrans
			SavePrintInfo = "false"
		else
			cn.CommitTrans
			SavePrintInfo = "true"
		end if
	end function
	sub Prt_add_logs(args,action1,sort)
		Dim rs3
		open_rz_system = Application("_open_rz_system")
		if len(open_rz_system) = 0 then
			set rs3=server.CreateObject("adodb.recordset")
			sql3="select intro from setjm where ord=802"
			rs3.open sql3,cn,1,1
			if rs3.eof then
				open_rz_system=0
			else
				open_rz_system=rs3("intro")
			end if
			Application("_open_rz_system")=open_rz_system
			rs3.close
			set rs3=nothing
		end if
		if open_rz_system="1" Then
			dim action_url,type_sys,type_brower,title
			If isnumeric(sort) Then
				set rs3=server.CreateObject("adodb.recordset")
				sql3="select title from PrintTemplate_Type where ord = " & sort
				rs3.open sql3,cn,1,1
				if rs3.eof then
					title=""
				else
					title=rs3("title")
				end if
				rs3.close
				set rs3=nothing
			end if
			action_url=GetUrl()
			action_url=replace(action_url,"'","''")
			type_sys=operationsystem()
			type_brower=browser()
			type_login=args
			sqlStr="Insert Into action_list(username,name,page1,time_login,type_sys,type_brower,type_login,action1) values("
			sqlStr=sqlStr & session("personzbintel2007") & ",'"
			sqlStr=sqlStr & session("name2006chen") & "','"
			sqlStr=sqlStr & action_url & "','"
			sqlStr=sqlStr & now & "','"
			sqlStr=sqlStr & type_sys & "','"
			sqlStr=sqlStr & type_brower & "',"
			sqlStr=sqlStr & type_login & ",'"
			sqlStr=sqlStr & title & action1 & "')"
			on error resume next
			cn.execute(sqlStr)
		end if
	end sub
	Function GetUrl()
		Dim ScriptAddress,Servername,qs
		ScriptAddress = CStr(Request.ServerVariables("SCRIPT_NAME"))
		Servername = CStr(Request.ServerVariables("Server_Name"))
		qs=Request.QueryString
		if qs<>"" then
			GetUrl = ScriptAddress &"?"&qs
		else
			GetUrl = ScriptAddress
		end if
	end function
	function operationsystem()
		dim agent
		agent = Request.ServerVariables("HTTP_USER_AGENT")
		if Instr(agent,"NT 5.2")>0 then
			SystemVer="Windows Server 2003"
		elseif Instr(agent,"NT 5.1")>0 then
			SystemVer="Windows XP"
		elseif Instr(agent,"NT 5.0")>0 then
			SystemVer="Windows 2000"
		elseif Instr(agent,"NT 4.0")>0 or Instr(agent,"NT 3.1")>0 or Instr(agent,"NT 3.5")>0 or Instr(agent,"NT 3.51 ")>0 then
			SystemVer="老版本Windows NT4"
		elseif Instr(agent,"4.9")>0 then
			SystemVer="Windows ME"
		elseif Instr(agent,"98")>0 then
			SystemVer="Windows 98"
		elseif Instr(agent,"95")>0 then
			SystemVer="Windows 95"
		elseif Instr(agent,"Vista")>0 then
			SystemVer="Windows Vista"
		elseif Instr(agent,"Windows 7")>0 then
			SystemVer="Windows 7"
		elseif Instr(agent,"Windows 8")>0 then
			SystemVer="Windows 8"
		elseif Instr(agent,"Server 2008 R2")>0 then
			SystemVer="Windows Server 2008 R2"
		elseif Instr(agent,"Server 2008")>0 then
			SystemVer="Windows Server 2008"
		elseif Instr(agent,"Server 2010")>0 then
			SystemVer="Windows Server 2010"
		elseif Instr(agent,"NT 6.2")>0 then
			SystemVer="Windows Server 2012"
		elseif Instr(agent,"CE")>0 then
			SystemVer="Windows CE"
		elseif Instr(agent,"PE")>0 then
			SystemVer="Windows PE"
		else
			SystemVer=""
		end if
		operationsystem=SystemVer
	end function
	function browser()
		dim agent
		agent = Request.ServerVariables("HTTP_USER_AGENT")
		if Instr(agent,"MSIE 6.0")>0 then
			browserVer="Internet Explorer 6.0"
		elseif Instr(agent,"MSIE 5.5")>0 then
			browserVer="Internet Explorer 5.5"
		elseif Instr(agent,"MSIE 5.01")>0 then
			browserVer="Internet Explorer 5.01"
		elseif Instr(agent,"MSIE 5.0")>0 then
			browserVer="Internet Explorer 5.00"
		elseif Instr(agent,"MSIE 4.0")>0 then
			browserVer="Internet Explorer 4.0"
		elseif Instr(agent,"TencentTraveler")>0 then
			browserVer="腾讯 TT"
		elseif Instr(agent,"Firefox")>0 then
			browserVer="Firefox"
		elseif Instr(agent,"Opera")>0 then
			browserVer="Opera"
		elseif Instr(agent,"Wap")>0 then
			browserVer="Wap浏览器"
		elseif Instr(agent,"Maxthon")>0 then
			browserVer="Maxthon"
		elseif Instr(agent,"MSIE 7.0")>0 then
			browserVer="Internet Explorer 7.0"
		elseif Instr(agent,"MSIE 8.0")>0 then
			browserVer="Internet Explorer 8.0"
		ElseIf InStr(agent, "MSIE 9.0") > 0 Then
			browserVer = "Internet Explorer 9.0"
		ElseIf InStr(agent, "MSIE 10.0") > 0 Then
			browserVer = "Internet Explorer 10.0"
		ElseIf InStr(agent, "MSIE 11.0") > 0 Then
			browserVer = "Internet Explorer 11.0"
		ElseIf InStr(agent, "MSIE 12.0") > 0 Then
			browserVer = "Internet Explorer 12.0"
		else
			browserVer=""
		end if
		browser=browserVer
	end function
	Dim Code128A, Code128B, Code128C, EAN128
	Code128A = 0
	Code128B = 1
	Code128C = 2
	EAN128 = 3
	Function Val(ByVal s)
		if s&"" = "" Or Not Isnumeric(s) Then
			val = 0
		else
			val = clng(s)
		end if
	end function
	Function GetCode128(ByVal Char, ByRef ID, ByRef CodingBin, ByVal CodingType)
		Dim FindText,MyArray
		ID = -1
'Dim FindText,MyArray
		Select Case CodingType
		Case 0
		Select Case UCase(Char)
		Case "FNC3": ID = 96: Case "FNC2": ID = 97: Case "SHIFT": ID = 98: Case "CODEC": ID = 99
		Case "CODEB": ID = 100: Case "FNC4": ID = 101: Case "FNC1": ID = 102: Case "STARTA": ID = 103
		Case "STARTB": ID = 104: Case "STARTC": ID = 105: Case "STOP": ID = 106
		Case Else
		FindText = " !""#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_"
'Case Else
		For i = 0 To 31
			FindText = FindText & Chr(i)
		next
		ID = InStr(FindText, UCase(Char)) - 1
		FindText = FindText & Chr(i)
		End Select
		Case 1
		Select Case UCase(Char)
		Case "FNC3": ID = 96: Case "FNC2": ID = 97: Case "SHIFT": ID = 98: Case "CODEC": ID = 99
		Case "FNC4": ID = 100: Case "CODEA": ID = 101: Case "FNC1": ID = 102: Case "STARTA": ID = 103
		Case "STARTB": ID = 104: Case "STARTC": ID = 105: Case "STOP": ID = 106
		Case Else
		FindText = " !""#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~" & Chr(127)
'Case Else
		ID = InStr(FindText, Char) - 1
'Case Else
		End Select
'Case Else
		Select Case UCase(Char)
		Case "CODEB": ID = 100: Case "CODEA": ID = 101: Case "FNC1": ID = 102: Case "STARTA": ID = 103
		Case "STARTB": ID = 104: Case "STARTC": ID = 105: Case "STOP": ID = 106
		Case Else
		ID = Val(Char)
		End Select
		End Select
		MyArray = Array("11011001100","11001101100","11001100110","10010011000","10010001100","10001001100","10011001000","10011000100","10001100100","11001001000","11001000100","11000100100","10110011100","10011011100","10011001110","10111001100","10011101100","10011100110","11001110010","11001011100","11001001110","11011100100","11001110100","11101101110","11101001100","11100101100","11100100110","11101100100","11100110100","11100110010","11011011000","11011000110","11000110110","10100011000","10001011000","10001000110","10110001000","10001101000","10001100010","11010001000","11000101000","11000100010","10110111000","10110001110","10001101110","10111011000","10111000110","10001110110","11101110110","11010001110","11000101110","11011101000","11011100010","11011101110","11101011000","11101000110","11100010110","11101101000","11101100010","11100011010","11101111010","11001000010","11110001010","10100110000","10100001100","10010110000","10010000110","10000101100","10000100110","10110010000","10110000100","10011010000","10011000010","10000110100","10000110010","11000010010","11001010000","11110111010","11000010100","10001111010","10100111100","10010111100","10010011110","10111100100","10011110100","10011110010","11110100100","11110010100","11110010010","11011011110","11011110110","11110110110","10101111000","10100011110","10001011110","10111101000","10111100010","11110101000","11110100010","10111011110","10111101110","11101011110","11110101110","11010000100","11010010000","11010011100","1100011101011")
		If id>=0 then
			CodingBin = MyArray(ID)
		else
			CodingBin = ""
		end if
	end function
	Function GetCode128_ID(ByVal ID)
		Dim MyArray
		MyArray = Array("11011001100","11001101100","11001100110","10010011000","10010001100","10001001100","10011001000","10011000100","10001100100","11001001000","11001000100","11000100100","10110011100","10011011100","10011001110","10111001100","10011101100","10011100110","11001110010","11001011100","11001001110","11011100100","11001110100","11101101110","11101001100","11100101100","11100100110","11101100100","11100110100","11100110010","11011011000","11011000110","11000110110","10100011000","10001011000","10001000110","10110001000","10001101000","10001100010","11010001000","11000101000","11000100010","10110111000","10110001110","10001101110","10111011000","10111000110","10001110110","11101110110","11010001110","11000101110","11011101000","11011100010","11011101110","11101011000","11101000110","11100010110","11101101000","11101100010","11100011010","11101111010","11001000010","11110001010","10100110000","10100001100","10010110000","10010000110","10000101100","10000100110","10110010000","10110000100","10011010000","10011000010","10000110100","10000110010","11000010010","11001010000","11110111010","11000010100","10001111010","10100111100","10010111100","10010011110","10111100100","10011110100","10011110010","11110100100","11110010100","11110010010","11011011110","11011110110","11110110110","10101111000","10100011110","10001011110","10111101000","10111100010","11110101000","11110100010","10111011110","10111101110","11101011110","11110101110","11010000100","11010010000","11010011100","1100011101011")
		If id >=0 then
			GetCode128_ID = MyArray(ID)
		else
			GetCode128_ID = ""
		end if
	end function
	Function Get_EAN_128_Binary(ByVal Data, ByVal CodingType)
		Dim i, Ci
		Dim ID, CodinBin
		Dim CheckSum, CheckCodeID
		Dim CodeStop
		CodeStop = "1100011101011"
		Select Case CodingType
		Case 0
		Get_EAN_128_Binary = "11010000100"
		For i = 1 To Len(Data)
			Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128A)
			CheckSum = CheckSum + i * ID
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128A)
			Get_EAN_128_Binary = Get_EAN_128_Binary + CodinBin
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128A)
		next
		CheckCodeID = (103 + CheckSum) Mod 103
		Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128A)
		Get_EAN_128_Binary = Get_EAN_128_Binary + GetCode128_ID(CheckCodeID) + CodeStop
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128A)
		Case 1
		Get_EAN_128_Binary = "11010010000"
		For i = 1 To Len(Data)
			Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128B)
			CheckSum = CheckSum + i * ID
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128B)
			Get_EAN_128_Binary = Get_EAN_128_Binary + CodinBin
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128B)
		next
		CheckCodeID = (104 + CheckSum) Mod 103
		Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128B)
		Get_EAN_128_Binary = Get_EAN_128_Binary + GetCode128_ID(CheckCodeID) + CodeStop
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128B)
		Case 2
		Get_EAN_128_Binary = "11010011100"
		For i = 1 To Len(Data) Step 2
			Ci = Ci + 1
'For i = 1 To Len(Data) Step 2
			Call GetCode128(Mid(Data, i, 2), ID, CodinBin, Code128C)
			CheckSum = CheckSum + Ci * ID
'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, Code128C)
			Get_EAN_128_Binary = Get_EAN_128_Binary + CodinBin
'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, Code128C)
		next
		CheckCodeID = (105 + CheckSum) Mod 103
		Call GetCode128(Mid(Data, i, 2), ID, CodinBin, Code128C)
		Get_EAN_128_Binary = Get_EAN_128_Binary + GetCode128_ID(CheckCodeID) + CodeStop
		Call GetCode128(Mid(Data, i, 2), ID, CodinBin, Code128C)
		Case Else
		Ci = 1
		CheckSum = 102
		Get_EAN_128_Binary = "11010011100" & "11110101110"
		For i = 1 To Len(Data) Step 2
			Ci = Ci + 1
'For i = 1 To Len(Data) Step 2
			Call GetCode128(Mid(Data, i, 2), ID, CodinBin, EAN128)
			CheckSum = CheckSum + Ci * ID
'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, EAN128)
			Get_EAN_128_Binary = Get_EAN_128_Binary + CodinBin
'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, EAN128)
		next
		CheckCodeID = (105 + CheckSum) Mod 103
		Call GetCode128(Mid(Data, i, 2), ID, CodinBin, EAN128)
		Get_EAN_128_Binary = Get_EAN_128_Binary + GetCode128_ID(CheckCodeID) + CodeStop
'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, EAN128)
		End Select
	end function
	Function Draw_Code128(ByVal Data, ByVal DrawWidth, ByVal ShowData, ByVal CodingType)
		Dim Binary128
		Dim Binary,CodeLineStr
		Dim i, J
		CodeLineStr=""
		If DrawWidth < 1 Then DrawWidth = 1
		Binary128 = Get_EAN_128_Binary(Data, CodingType)
		For i = 1 To Len(Binary128)
			Binary = Val(Mid(Binary128, i, 1))
			If Binary = 1 Then
				CodeLineStr = CodeLineStr & "1"
			else
				CodeLineStr = CodeLineStr & "0"
			end if
		next
		Draw_Code128 = "{w:'" & DrawWidth & "',d:'" & Data & "',code:'" & CodeLineStr & "'}"
	end function
	msgid = request("msgid")
	If msgid&""<>"" Then
		Response.clear
		Response.charset="UTF-8"
		Response.clear
		Select Case msgid&""
		Case "showContent" : Call showContent()
		End Select
		conn.close
		Set conn = Nothing
		Response.end
	end if
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
	'Response.end
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<script language=""javascript"" src=""../Inc/jquery-1.4.2.min.js?ver="
	'Response.write Application("sys.info.jsver")
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "    function toPrint(id ,ord , sort , isSum,count){" & vbcrlf & "         jQuery.ajax({" & vbcrlf & "                   url:'SavePrintInfo.asp?id='+id+'&ord='+ord+'&sort='+sort + '&isSum='+isSum + ""&count=""+count," & vbcrlf & "                     success:function(r){" & vbcrlf & "                         //alert(r);" & vbcrlf & "                             if (r==""count"")" & vbcrlf & "                           {       " & vbcrlf & "                                        if(confirm(""该单据已存在最新打印记录，是否继续？"")){" & vbcrlf & "                                              var xhttp = new (XMLHttpRequest?XMLHttpRequest:ActiveXObject)(""Msxml2.XMLHTTP"");" & vbcrlf & "                                          xhttp.open(""get"",""SavePrintInfo.asp?id=""+id+""&ord=""+ord+""&sort=""+sort + ""&isSum=""+isSum + ""&count=-1"",false);" & vbcrlf & "                                             xhttp.send();" & vbcrlf & "                                           $(window.frames[""mbPage2""]).focus();" & vbcrlf & "                                              document.getElementById(""mbPage2"").contentWindow.document.getElementById(""printBtn"").click();                                       "& vbcrlf & "                                       }" & vbcrlf & "                               }else{" & vbcrlf & "                                  $(window.frames[""mbPage2""]).focus();" & vbcrlf & "                                      document.getElementById(""mbPage2"").contentWindow.document.getElementById(""printBtn"").click();" & vbcrlf & "                               }" & vbcrlf & "                       }" & vbcrlf & "               });" & vbcrlf & "             return false;" & vbcrlf & "    }" & vbcrlf & "</script>" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body,td,th {" & vbcrlf & " color: #000000;" & vbcrlf & "}" & vbcrlf & ".page{position:absolute; color: red}" & vbcrlf & "@media print" & vbcrlf & "{" & vbcrlf & ".page,.noprint {display:none}" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & "</style>" & vbcrlf & "</head>" & vbcrlf & "<body>" & vbcrlf & "<table width=""100%""   border=""0"" align=""left"" cellpadding=""0"" cellspacing=""0"" bordercolor=""#E2E2E1"" bgcolor=""#FFFFFF"">" & vbcrlf & "<tr>" & vbcrlf & "    <td width=""100%"" valign=""top"">" & vbcrlf & "    "
	intro=Replace(trim(Request.form("content")),"<tr,","<tr",1,-1,1)
'lign=""top"">" & vbcrlf & "    "
	intro=Replace(intro,"<td,","<td",1,-1,1)
'lign=""top"">" & vbcrlf & "    "
	id = Request("id")
	ord = deurl(request("ord")):If ord&"" = "" Or isnumeric(ord&"") = False Then ord = 0
	sort = request("sort")
	If sort&"" = "" Then sort = 0
	isSum = request("isSum")
	pageType = request("pageType")
	pageWidth = request("pageWidth")
	pageHeight = request("pageHeight")
	topMargin = request("topMargin")
	bottomMargin = request("bottomMargin")
	leftMargin = request("leftMargin")
	rightMargin = request("rightMargin")
	count = GetPrintInfo(conn,sort,ord,3)
	session("zbintelPrintIntro2017") = intro
	if pageType&"" = "" then pageType = "A4"
	if pageWidth&"" = "" then pageWidth = 21
	if pageHeight&"" = "" then pageHeight = 29.7
	if topMargin&"" = "" then topMargin = 1.5
	if bottomMargin&"" = "" then bottomMargin = 1.5
	if leftMargin&"" = "" then leftMargin = 1.5
	if rightMargin&"" = "" then rightMargin = 1.5
	Response.write "" & vbcrlf & "<table width=""100%"" class=""noprint"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content2"">" & vbcrlf & "<tr>" & vbcrlf & "  <td height=""27"" style=""color:#5b7cae; text-align:right"">" & vbcrlf & "            纸张类型："
	'if rightMargin&"" = "" then rightMargin = 1.5
	Select Case pageType&""
	Case "16k" : Response.write "16开"
	Case "32k" : Response.write "32开"
	Case "B32k" : Response.write "大32开"
	Case "zdy" : Response.write "自定义"
	Case Else : Response.write pageType
	End Select
	Response.write "" & vbcrlf & "              <span style=""margin-left:20px;"">纸张大小： " & vbcrlf & "               宽："
'End Select
	Response.write pageWidth
	Response.write " 厘米</span>" & vbcrlf & "          <span style=""margin-left:8px;"">高："
	'Response.write pageWidth
	Response.write pageHeight
	Response.write " 厘米</span>" & vbcrlf & "          <span style=""margin-left:15px;"">页边距：&nbsp;&nbsp;上："
	'Response.write pageHeight
	Response.write topMargin
	Response.write " 厘米</span>" & vbcrlf & "          <span style=""margin-left:8px;"">下："
	'Response.write topMargin
	Response.write bottomMargin
	Response.write " 厘米</span>" & vbcrlf & "          <span style=""margin-left:8px;"">左："
	'Response.write bottomMargin
	Response.write leftMargin
	Response.write " 厘米</span>" & vbcrlf & "          <span style=""margin-left:8px;"">右："
	'Response.write leftMargin
	Response.write rightMargin
	Response.write " 厘米</span>" & vbcrlf & "  </td>" & vbcrlf & "</tr>" & vbcrlf & "<tr>" & vbcrlf & "          <td height=""27"">" & vbcrlf & "                  "
	If sort&"" <> "7" And sort&"" <> "126" Then
		Response.write "" & vbcrlf & "                      <div class=""noprint"" style=""float:left;color:red;width:300px;text-align:left;margin-left:8px;line-height:27px;"">该单据已打印"
'If sort&"" <> "7" And sort&"" <> "126" Then
		Response.write count
		Response.write "次</div>" & vbcrlf & "                      "
	end if
	Response.write "              " & vbcrlf & "                <div class=""noprint"" style=""float:right;width:300px;line-height:27px; text-align:right; margin-right:20px;""><input type=""button"" class=""""  name=""print"" onclick=""toPrint('"
	'Response.write "次</div>" & vbcrlf & "                      "
	Response.write id
	Response.write "','"
	Response.write ord
	Response.write "','"
	Response.write sort
	Response.write "','"
	Response.write isSum
	Response.write "',"
	Response.write count
	Response.write ")"" value=""打印""  class=""anybutton""></div>" & vbcrlf & "              </td>" & vbcrlf & "      </tr>" & vbcrlf & "</table>" & vbcrlf & "<table align=""center"" width=""100%"">" & vbcrlf & "  <tr>" & vbcrlf & "   <td align=""center"">" & vbcrlf & "               <iframe id=""mbPage2"" frameborder=""0"" class=""Composition"" style=""width:"
	Response.write (pageWidth-leftMargin-rightMargin)*10
'ition"" style=""width:"
	Response.write "mm;height:"
	Response.write (pageHeight-topMargin-bottomMargin)*10
	'Response.write "mm;height:"
	Response.write "mm; margin-top:8px;"" marginwidth=""1"" marginheight=""1"" SCROLLING=""no"" src=""moban_dy2.asp?msgid=showContent""></iframe>" & vbcrlf & "       </td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & ""
	'Response.write "mm;height:"
	sub showContent()
		dim intro
		intro = session("zbintelPrintIntro2017")
		Response.clear
		Response.write "<html style='margin:0; padding:0'>"
		Response.write "<head>"
		Response.write "<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'/>"
		'Response.write "<head>"
		Response.write "<link href=""../Edit/CSS/CoolBlue/EditorArea.css"" rel=""stylesheet"" type=""text/css"">"
		Response.write "<meta name='GENERATOR' content='MSHTML 9.00.8112.16636'/>"
		Response.write "</head>"
		Response.write "<body style='zoom: 100%;margin:0; padding:0;' onload=""parent.document.all('mbPage2').style.height=document.body.scrollHeight; "">"
		Response.write "<input type='button' id='printBtn' onclick='window.print()' style='display:none'>"
		Response.write "<div id='printTable'>"
		Response.write intro
		Response.write "</div>"
		Response.write "</body>"
		Response.write "</html>"
	end sub
	conn.close
	set conn=nothing
	Response.write "" & vbcrlf & " </td>" & vbcrlf & "  </tr>" & vbcrlf & "  </table>" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
%>
