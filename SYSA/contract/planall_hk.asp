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
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_1=0
		intro_7_1=0
	else
		open_7_1=rs1("qx_open")
		intro_7_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=2"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_2=0
		intro_7_2=0
	else
		open_7_2=rs1("qx_open")
		intro_7_2=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_14=0
		intro_7_14=0
	else
		open_7_14=rs1("qx_open")
		intro_7_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_3=0
		intro_7_3=0
	else
		open_7_3=rs1("qx_open")
		intro_7_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=6"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_6=0
		intro_7_6=0
	else
		open_7_6=rs1("qx_open")
		intro_7_6=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_7=0
		intro_7_7=0
	else
		open_7_7=rs1("qx_open")
		intro_7_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_8=0
		intro_7_8=0
	else
		open_7_8=rs1("qx_open")
		intro_7_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_10=0
		intro_7_10=0
	else
		open_7_10=rs1("qx_open")
		intro_7_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_11=0
		intro_7_11=0
	else
		open_7_11=rs1("qx_open")
		intro_7_11=rs1("qx_intro")
		If intro_7_11&""<>"" Then intro_7_11 = Replace(intro_7_11," ","") Else intro_7_11 = "-222"
		intro_7_11=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_13=0
		intro_7_13=0
	else
		open_7_13=rs1("qx_open")
		intro_7_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=16"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_16=0
		intro_7_16=0
	else
		open_7_16=rs1("qx_open")
		intro_7_16=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=20"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_20=0
		intro_7_20=0
	else
		open_7_20=rs1("qx_open")
		intro_7_20=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=21"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_21=0
		intro_7_21=0
	else
		open_7_21=rs1("qx_open")
		intro_7_21=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
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
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_1=0
		intro_5_1=0
	else
		open_5_1=rs1("qx_open")
		intro_5_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_14=0
		intro_5_14=0
	else
		open_5_14=rs1("qx_open")
		intro_5_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_1=0
		intro_21_1=0
	else
		open_21_1=rs1("qx_open")
		intro_21_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_14=0
		intro_21_14=0
	else
		open_21_14=rs1("qx_open")
		intro_21_14=rs1("qx_intro")
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
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=9 and sort2=1"
	rs1.open sql1,conn,3,1
	if rs1.eof then
		open_9_1=0
		intro_9_1=0
	else
		open_9_1=rs1("qx_open")
		intro_9_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=9 and sort2=10"
	rs1.open sql1,conn,3,1
	if rs1.eof then
		open_9_10=0
		intro_9_10=0
	else
		open_9_10=rs1("qx_open")
		intro_9_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	if open_9_1=3 then
		list3= ""
	elseif open_9_1=1 then
		list3=" and p.cateid in ("&intro_9_1&") and p.cateid<>0 "
	else
		list3=" and 1=0 "
	end if
	if open_7_1=3 then
		list=""
		list1=""
		list2= ""
	elseif open_7_1=1 then
		list=" and cateid in ("&intro_7_1&") and cateid<>0 "
		list1=" and c.cateid in ("&intro_7_1&") and c.cateid<>0 "
		list2=" and p.cateid in ("&intro_7_1&") and p.cateid<>0 "
	else
		list=" and 1=0 "
		list1=" and 1=0 "
		list2=" and 1=0 "
	end if
	Str_Result3 = list1
	Str_Result=" where del=1 "&list&" "
	Str_Result2=" and del=1 "&list&" "
	Str_Result4 = list2
	Str_Result5 = list3
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
			imgurl = "../code2/view.asp?sn=view&ct=46&data=CLDJ:"& v &"&width=120&errorh=3"
		else
			imgurl = "../code2/viewCode.asp?codeType=128&data=HTID:"& v &"&height=60"
			s = "<div style='width:auto; display:inline-block !important; *zoom:1; display:inline; '><div style='text-align:center'><a href='javascript:void(0)' onclick=""javascript:window.open('../code2/viewImage.asp?codeType=128&title="& server.urlencode(code) &"&imgurl=" & server.urlencode(imgurl) & "&t="&now()&"','imgurl_1','width=' + 320 + ',height=' + 320 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')""><img  height='30' title='"&title&"' src='"& imgurl &"' style='cursor:pointer;'></a></div><div style='text-align:center'>"&v&"</div></div>"
			imgurl = "../code2/viewCode.asp?codeType=128&data=HTID:"& v &"&height=60"
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
	dim open_bz
	set rs=server.CreateObject("adodb.recordset")
	sql="select top 1 bz from setbz "
	rs.open sql,conn,1,1
	if not rs.eof then
		open_bz=rs("bz")
	end if
	rs.close
	set rs=nothing
	Function ChW_sortbz(id,num)
		Dim rs1 ,sql1 ,sort1
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select sort1,intro from sortbz where id="&cint(id)&""
		rs1.open sql1,conn,1,1
		if rs1.eof then
			Response.write "此币种已被删除"
		else
			if num=0 then
				sort1=rs1("sort1")
				sort1=sort1&"("&rs1("intro")&")"
			else
				sort1=rs1("intro")
			end if
			Response.write sort1
		end if
		rs1.close
		set rs1=nothing
	end function
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
	Dim MODULES
	MODULES=session("zbintel2010ms")
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_1=0
		intro_7_1=0
	else
		open_7_1=rs1("qx_open")
		intro_7_1=rs1("qx_intro")
	end if
	rs1.close
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_11=0
		intro_7_11=0
	else
		open_7_11=rs1("qx_open")
		intro_7_11=rs1("qx_intro")
		If intro_7_11&""<>"" Then
			intro_7_11 = Replace(intro_7_11," ","")
		else
			intro_7_11 = "-222"
			intro_7_11 = Replace(intro_7_11," ","")
		end if
	end if
	rs1.close
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7001 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7001_11=0
		intro_7001_11=0
	else
		open_7001_11=rs1("qx_open")
		intro_7001_11=rs1("qx_intro")
		If intro_7001_11&""<>"" Then
			intro_7001_11 = Replace(intro_7001_11," ","")
		else
			intro_7001_11 = "-222"
			intro_7001_11 = Replace(intro_7001_11," ","")
		end if
	end if
	rs1.close
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_1=0
		intro_7_1=0
	else
		open_7_1=rs1("qx_open")
		intro_7_1=rs1("qx_intro")
		If intro_7_1&""<>"" Then
			intro_7_1 = Replace(intro_7_1," ","")
		else
			intro_7_1 = "-222"
			intro_7_1 = Replace(intro_7_1," ","")
		end if
	end if
	rs1.close
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7001 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7001_1=0
		intro_7001_1=0
	else
		open_7001_1=rs1("qx_open")
		intro_7001_1=rs1("qx_intro")
		If intro_7001_1&""<>"" Then
			intro_7001_1 = Replace(intro_7001_1," ","")
		else
			intro_7001_1 = "-222"
			intro_7001_1 = Replace(intro_7001_1," ","")
		end if
	end if
	rs1.close
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_26_1=0
		intro_26_1=0
	else
		open_26_1=rs1("qx_open")
		intro_26_1=rs1("qx_intro")
		If intro_26_1&""<>"" Then intro_26_1 = Replace(intro_26_1," ","")
	end if
	rs1.close
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=9 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_9_11=0
		intro_9_11=0
	else
		open_9_11=rs1("qx_open")
		intro_9_11=rs1("qx_intro")
		If intro_9_11&""<>"" Then
			intro_9_11 = Replace(intro_9_11," ","")
		else
			intro_9_11 = "-222"
			intro_9_11 = Replace(intro_9_11," ","")
		end if
	end if
	rs1.close
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_26_14=0
		intro_26_14=0
	else
		open_26_14=rs1("qx_open")
		intro_26_14=rs1("qx_intro")
		If intro_26_14&""<>"" Then intro_26_14 = Replace(intro_26_14," ","")
	end if
	rs1.close
	set rs1=nothing
	MSellReturn = iif(ZBRuntime.MC(8000),1,0)
	str_Result11 = ""
	If Right(intro_7_11,1) = "," Then
		intro_7_11 = intro_7_11 & "0"
	end if
	If Right(intro_9_11,1) = "," Then
		intro_9_11 = intro_9_11 & "0"
	end if
	if open_7_11=1 then
		sql_result=" and charindex(','+cast(a.cateid as varchar(15))+',', ',"&intro_7_11&",')>0 and a.cateid<>0 "
'if open_7_11=1 then
		sql_qcpayback=" and charindex(','+cast(a.cateid as varchar(15))+',', ',"&intro_7_11&",')>0 and a.cateid<>0 "
'if open_7_11=1 then
		sql_qcpayback2=" and charindex(','+cast(a.cateid as varchar(15))+',', ',"&intro_7_11&",')>0 and a.cateid<>0 "
'if open_7_11=1 then
		sql_bankin_condition =" and charindex(','+cast(t.cateid as varchar(15))+',', ',"&intro_7_11&",')>0 and t.cateid<>0 "
'if open_7_11=1 then
	elseif open_7_11=3 then
		sql_result=" and 1=1 "
		sql_qcpayback=" and 1=1 "
		sql_qcpayback2=" and 1=1 "
		sql_bankin_condition =" and 1=1 "
	else
		sql_result=" and 1=2 "
		sql_qcpayback=" and 1=2 "
		sql_qcpayback2=" and 1=2 "
		sql_bankin_condition =" and 1=2 "
	end if
	if open_7001_11=1 then
		sql_qcpbi =" and charindex(','+cast(bi.cateid as varchar(15))+',', ',"&intro_7001_11&",')>0 and bi.cateid<>0 "
'if open_7001_11=1 then
		sql_pbi =" and charindex(','+cast(bi.cateid as varchar(15))+',', ',"&intro_7001_11&",')>0 and bi.cateid<>0 "
'if open_7001_11=1 then
		sql_pbsi =" and charindex(','+cast(bi.cateid as varchar(15))+',', ',"&intro_7001_11&",')>0 and bi.cateid<>0 "
'if open_7001_11=1 then
	elseif open_7001_11=3 then
		sql_qcpbi =" and 1=1 "
		sql_pbi =" and 1=1 "
		sql_pbsi =" and 1=1 "
	else
		sql_qcpbi =" and 1=2 "
		sql_pbi =" and 1=2 "
		sql_pbsi =" and 1=2 "
	end if
	if open_9_11=1 then
		sql_pout=" and charindex(','+cast(y.cateid as varchar(15))+',', ',"&intro_9_11&",')>0 and y.cateid<>0 "
'if open_9_11=1 then
		sql_qcout=" and charindex(','+cast(y.cateid as varchar(15))+',', ',"&intro_9_11&",')>0 and y.cateid<>0 "
'if open_9_11=1 then
		sql_qcout2=" and charindex(','+cast(y.cateid as varchar(15))+',', ',"&intro_9_11&",')>0 and y.cateid<>0 "
'if open_9_11=1 then
	elseif open_9_11=3 then
		sql_pout=" and 1=1 "
		sql_qcout=" and 1=1 "
		sql_qcout2=" and 1=1 "
	else
		sql_pout=" and 1=2 "
		sql_qcout = " and 1=2 "
		sql_qcout2 = " and 1=2 "
	end if
	sql_pout = sql_pout &" and "& MSellReturn &"=1 "
	dim A,A2,B,D,C,m1,m2, fst
	fst = request("fst")
	m1=request("ret")
	m2=request("ret2")
	A=request("A")
	A2=request("A2")
	D=request("D")
	B=request("B")
	C=request("C")
	FK=request("FK")
	Dim IsType
	IsType = 0
	If Trim(request("IsType"))<>"" then
		If Len(Trim(request("IsType")))>0 then
			IsType = 1
		else
			IsType = 0
		end if
	end if
	If istype=1 Then
		if  Trim(Request("ret"))<>"" then
			m1=Trim(Request("ret"))
		else
			m1=""
		end if
		if  Trim(Request("ret2"))<>"" then
			m2=Trim(Request("ret2"))
		else
			m2=""
		end if
	end if
	If istype=0 then
		If fst&"" = "" Then
			if m1="" then
				m1= year(date)&"-"&Right("0" & month(date), 2)&"-01"
'if m1="" then
			end if
			if m2="" then
				newDate=dateadd("m",1,m1)-1
'if m2="" then
				m2 = year(newDate)&"-"&Right("0" & month(newDate), 2)&"-"&Right("0" & day(newDate), 2)
'if m2="" then
			end if
		end if
	end if
	if m1&""<>"" then
		sql_result = sql_result &" and a.date1 >= '"&m1&"' "
		sql_qcpayback = sql_qcpayback &" and a.date1 < '"&m1&"' "
		sql_qcpayback2 = sql_qcpayback2 &" and (isnull(a.date5,'2100-01-01') < '"&m1&"' and a.date5 is not null) "
		sql_qcpayback = sql_qcpayback &" and a.date1 < '"&m1&"' "
		sql_pout = sql_pout &" and y.date1>= '"&m1&"' "
		sql_qcout = sql_qcout &" and y.date1< '"&m1&"' "
		sql_qcout2 = sql_qcout2 &" and (isnull(y.date2,'2100-01-01')< '"&m1&"' and y.date2 is not null)  "
		sql_qcout = sql_qcout &" and y.date1< '"&m1&"' "
		sql_qcpbi = sql_qcpbi &" and bi.date1 < '"&m1&"' and (bi.InvoiceDate>='"&m1&"' or bi.InvoiceDate is null)"
		sql_pbi = sql_pbi &" and bi.date1 >= '"&m1&"' "
		sql_pbsi = sql_pbsi &" and bi.InvoiceDate >= '"&m1&"' "
	else
		sql_qcpayback = sql_qcpayback &" and 1=0 "
		sql_qcpayback2 = sql_qcpayback2 &" and 1=0 "
		sql_qcout = sql_qcout &" and 1=0 "
		sql_qcout2 = sql_qcout2 &" and 1=0 "
		sql_qcpbi = sql_qcpbi &" and 1=0  "
		sql_pbi = sql_pbi &" and 1=0  "
		sql_pbsi = sql_pbsi &" and 1=0  "
	end if
	if m2&""<>"" then
		sql_result = sql_result &" and a.date1 <= '"&m2&" 23:59:59' "
		sql_pout = sql_pout &" and y.date1<= '"&m2&" 23:59:59' "
		sql_qcpbi = sql_qcpbi &" and bi.date1<= '"&m2&" 23:59:59' "
		sql_pbi = sql_pbi &" and bi.date1<= '"&m2&" 23:59:59' "
		sql_pbsi = sql_pbsi &" and bi.InvoiceDate<= '"&m2&" 23:59:59' "
	end if
	zmr=request("zmr")
	if zmr="" or Isnull(zmr) then
		zmr=10
	end if
	if zmr<>"10" then
		if zmr&""="1" then
			sql_qcout = sql_qcout&" and 1=2 "
			sql_qcout2 = sql_qcout2&" and 1=2 "
			sql_pout = sql_pout&" and 1=2 "
			nsql_qcpbi_zmr = " and bi.fromType !='ContractTH'  "
			nsql_pbi_zmr = " and  bi.fromType !='ContractTH' "
			nsql_pbsi_zmr = " and  bi.fromType !='ContractTH' "
		end if
		if zmr &""="0" then
			sql_result=sql_result&" and 1=2 "
			sql_qcpayback=" and 1=2 "
			sql_qcpayback2=" and 1=2 "
			sql_pbi_zmr = " and 1=2 "
		end if
	end if
	if ZBRuntime.MC(25000) or ZBRuntime.MC(25001) then
	else
		sql_qcout = sql_qcout&" and 1=2 "
		sql_qcout2 = sql_qcout2&" and 1=2 "
		sql_pout = sql_pout&" and 1=2 "
		nsql_qcpbi_zmr = " and bi.fromType !='ContractTH'  "
		nsql_pbi_zmr = " and  bi.fromType !='ContractTH' "
		nsql_pbsi_zmr = " and  bi.fromType !='ContractTH' "
	end if
	dim zmrstr1,zmrstr2,zmrstr3,zmrstr4,zmrstr
	zmr_zj=request("zmr_zj")
	zmr_zc=request("zmr_zc")
	zmr_xy=request("zmr_xy")
	zmr_tk=request("zmr_tk")
	zmr_qc=request("zmr_qc")
	if zmr_zj<>"" then zmrstr1=zmrstr1 & " a.paybacktype="&zmr_zj&""
	if zmr_zc<>"" then zmrstr2=zmrstr2 & " a.paybacktype="&zmr_zc&" or a.paybacktype is null"
	if zmr_xy<>"" then zmrstr3=zmrstr3 & " a.paybacktype="&zmr_xy&""
	if zmr_tk<>"" then zmrstr4=zmrstr4 & " a.paybacktype="&zmr_tk&""
	if zmr_qc<>"" then zmrstr5=zmrstr5 & " a.paybacktype="&zmr_qc&""
	if zmrstr1<>"" then zmrstr=zmrstr & " or " & zmrstr1
	if zmrstr2<>"" then zmrstr=zmrstr & " or " & zmrstr2
	if zmrstr3<>"" then zmrstr=zmrstr &" or " & zmrstr3
	if zmrstr4<>"" then zmrstr=zmrstr & " or " & zmrstr4
	if zmrstr5<>"" then zmrstr=zmrstr & " or " & zmrstr5
	if zmrstr<>"" then
		zmrstr=right(zmrstr,len(zmrstr)-len(" or "))
'if zmrstr<>"" then
		zmrstr_2 = replace(zmrstr,"a.","")
		sql_result=sql_result& " and (" & zmrstr & ")"
		sql_qcpayback=sql_qcpayback& " and (" & zmrstr & ")"
		sql_qcpayback2=sql_qcpayback2& " and (" & zmrstr & ")"
		str_Result11=str_Result11& " and t.ord in (select company from payback where "&zmrstr_2&")"
	end if
	if A2="" or IsNull(A2) then
		A2=0
	end if
	if A2&""<>"0" then
		str_Result11=str_Result11+" and p.bz="&A2&" "
'if A2&""<>"0" then
	end if
	if FK="" or IsNull("FK") then
		FK=10
	end if
	if FK<>"10" then
		str_Result11=str_Result11& " and t.ord in (select company from contract where fqhk="&FK&" )"
	end if
	B="khmc"
	if C<>"" then
		if B="khmc" then
			str_Result11=str_Result11+" and t.name like '%"& C &"%' "
'if B="khmc" then
			Set rs2 = conn.execute("select ord from tel where name like '%"& C &"%' " )
			If rs2.eof = False Then
				telOrd = rs2("ord")
			else
				telOrd = -1
				telOrd = rs2("ord")
			end if
			rs2.close
			set rs2=nothing
		elseif B="khid" then
			str_Result11=str_Result11+" and t.khid like '%"& C &"%' "
'elseif B="khid" then
		elseif B="htzt" then
			str_Result11=str_Result11+" and t.ord in (select company from contract where title like '%"& C &"%')"
'elseif B="htzt" then
		elseif B="htid" then
			str_Result11=str_Result11+" and t.ord in (select company from contract where htid like '%"& C &"%')"
'elseif B="htid" then
		elseif B="xsry" then
			str_Result11=str_Result11+" and t.cateid in (select ord from gate where name like '%"& C &"%') "
'elseif B="xsry" then
		end if
	end if
	px=request.QueryString("px")
	if px="" then
		px=9
	end if
	if px=1 then
		px_Result="order by isnull(t.name,'') desc,p.company desc"
	elseif px=2 then
		px_Result="order by isnull(t.name,'') asc,p.company asc"
	elseif px=3 then
		px_Result="order by ISNULL(期初应收,0) desc,p.company desc"
	elseif px=4 then
		px_Result="order by ISNULL(期初应收,0) asc,p.company asc"
	elseif px=5 then
		px_Result="order by ISNULL(本期应收,0) desc,p.company desc"
	elseif px=6 then
		px_Result="order by ISNULL(本期应收,0) asc,p.company asc"
	elseif px=7 then
		px_Result="order by ISNULL(本期实收,0) desc,p.company desc"
	elseif px=8 then
		px_Result="order by ISNULL(本期实收,0) asc,p.company asc"
	elseif px=9 then
		px_Result="order by ISNULL(期末应收,0) desc,p.company desc"
	elseif px=10 then
		px_Result="order by ISNULL(期末应收,0) asc,p.company asc"
	elseif px=11 then
		px_Result="order by ISNULL(期初应开票,0) desc,p.company desc"
	elseif px=12 then
		px_Result="order by ISNULL(期初应开票,0) asc,p.company asc"
	elseif px=13 then
		px_Result="order by ISNULL(本期应开票,0) desc,p.company desc"
	elseif px=14 then
		px_Result="order by ISNULL(本期应开票,0) asc,p.company asc"
	elseif px=15 then
		px_Result="order by ISNULL(本期实开票,0) desc,p.company desc"
	elseif px=16 then
		px_Result="order by ISNULL(本期实开票,0) asc,p.company asc"
	elseif px=17 then
		px_Result="order by ISNULL(期末应开票,0) desc,p.company desc"
	elseif px=18 then
		px_Result="order by ISNULL(期末应开票,0) asc,p.company asc"
	elseif px=19 then
		px_Result="order by ISNULL(g.name,0) desc,p.company desc"
	elseif px=20 then
		px_Result="order by ISNULL(g.name,0) asc,p.company asc"
	end if
	page_count=request.QueryString("page_count")
	if page_count="" then
		page_count=10
	end if
	currpage=Request("currpage")
	if currpage<="0" or currpage="" then
		currpage=1
	end if
	currpage=clng(currpage)
	khname=conn.execute("select (case when isnull(name,'')='' then oldname else name end ) as name from setfields where gate1=1 ")(0)
	If khname="" Then khname="客户名称"
	khbianh=conn.execute("select (case when isnull(name,'')='' then oldname else name end ) as name from setfields where gate1=3 ")(0)
	If khbianh="" Then khbianh="客户编号"
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
'If khbianh="" Then khbianh="客户编号"
	Response.write session("name2006chen")
	Response.write "企业管理软件</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body {" & vbcrlf & "    margin-top: 0px;" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & "</style>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"">" & vbcrlf & "" & vbcrlf & "function callServer2() {" & vbcrlf & "  var url = ""liebiao_tj.asp?timestamp="" + new Date().getTime() + ""&date1=""+ Math.round(Math.random()*100);" & vbcrlf & "  xmlHttp.open(""GET"", url, false);" & vbcrlf & "  xmlHttp.onreadystatechange = function(){" & vbcrlf & "  updatePage2();" & vbcrlf & "  };" & vbcrlf & "  xmlHttp.send(null);  " & vbcrlf & "}" & vbcrlf & "function updatePage2() {" & vbcrlf & "var test7=""ht1""" & vbcrlf & "  if (xmlHttp.readyState < 4) {" & vbcrlf & "      ht1.innerHTML=""loading..."";" & vbcrlf & "  }" & vbcrlf & "  if (xmlHttp.readyState == 4) {" & vbcrlf & "    var response = xmlHttp.responseText;" & vbcrlf & "        ht1.innerHTML=response;" & vbcrlf & " xmlHttp.abort();" & vbcrlf & "  }" & vbcrlf & "}" & vbcrlf & "function go(loc) {" & vbcrlf & "window.location.href = loc;" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "</head>" & vbcrlf & "<body>" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "<tr>" & vbcrlf & "    <td width=""100%"" valign=""top"">" & vbcrlf & "        <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "     <form action=""planall_hk.asp?px="
	Response.write px
	Response.write "&page_count="
	Response.write page_count
	Response.write """ method=""get""　id=""demo"" onsubmit=""return Validator.Validate(this,2)"" name=""date"">" & vbcrlf & "               <tr>" & vbcrlf & "        <td class=""place"">" & vbcrlf & "        收款开票汇总表</td>" & vbcrlf & "        <td>&nbsp;<a class='px_btn' href=""javascript:;"" onClick=""Myopen_px(User);return false;"" class=""sortRule"">排序规则<img src=""../images/i10.gif"" width=""9"" height=""5"" border=""0""></a></td>" & vbcrlf & "        <td align=""right"">" & vbcrlf & "               <label style=""margin-right:50px;""><input type=""radio"" onclick=""this.checked = false; window.open('../../SYSN/view/finan/payback/CustomStateMent1.ashx?company="
	if B="khmc" then Response.write pwurl(telOrd) end if
	Response.write "&date1="
	Response.write m1
	Response.write "&date2="
	Response.write m2
	Response.write "','khdzreport','width=' + 1000 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');"">客户对账单</label>" & vbcrlf & "           <select name=""select2""  onChange=""if(this.selectedIndex && this.selectedIndex!=0){gotourl(this.value);}"">" & vbcrlf & "        <option>-请选择-</option>" & vbcrlf & "        <option value=""page_count=10"" "
	Response.write m2
	if page_count=10 then
		Response.write "selected"
	end if
	Response.write ">每页显示10条</option>" & vbcrlf & "        <option value=""page_count=20"" "
	if page_count=20 then
		Response.write "selected"
	end if
	Response.write ">每页显示20条</option>" & vbcrlf & "        <option value=""page_count=30"" "
	if page_count=30 then
		Response.write "selected"
	end if
	Response.write ">每页显示30条</option>" & vbcrlf & "        <option value=""page_count=50"" "
	if page_count=50 then
		Response.write "selected"
	end if
	Response.write ">每页显示50条</option>" & vbcrlf & "        <option value=""page_count=100"" "
	if page_count=100 then
		Response.write "selected"
	end if
	Response.write ">每页显示100条</option>" & vbcrlf & "        <option value=""page_count=200"" "
	if page_count=200 then
		Response.write "selected"
	end if
	Response.write ">每页显示200条</option>" & vbcrlf & "      </select></td>" & vbcrlf & "    <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "      </tr>" & vbcrlf & "  </table> " & vbcrlf & "      <table width=""100%"" border=""0"" cellpadding=""3"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;"">" & vbcrlf & "    <tr>" & vbcrlf & "      <td  class='ser_btn' align=""right"" style=""border-top:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"">"
	Response.write "selected"
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
	Response.write "" & vbcrlf & "<span> "
	Response.write khname
	Response.write "：</span>" & vbcrlf & "<input name=""C"" type=""text"" size=""10""  value="""
	Response.write sdk.htmlconvert(C)
	Response.write """/>" & vbcrlf & "<select name=""zmr"">" & vbcrlf & "  <option value=""10"" "
	if zmr=10 then
		Response.write "selected"
	end if
	Response.write ">单据类型</option>" & vbcrlf & "  <option value=""1"" "
	if zmr=1 then
		Response.write "selected"
	end if
	Response.write ">合同</option>" & vbcrlf & "  <option value=""0"" "
	if zmr=0 then
		Response.write "selected"
	end if
	Response.write ">销售退款</option>" & vbcrlf & "</select>" & vbcrlf & "<select name=""A2"">" & vbcrlf & "  <option value=""0"" >币种</option>" & vbcrlf & ""
	set rs88=server.CreateObject("adodb.recordset")
	if open_bz=1 then
		sql88="select id,sort1 from sortbz order by gate1 desc"
	else
		sql88="select id,sort1 from sortbz where id=14 "
	end if
	rs88.open sql88,conn,1,1
	if not rs88.eof then
		do while not rs88.eof
			Response.write "" & vbcrlf & "     <option value="""
			Response.write rs88("id")
			Response.write """ "
			if rs88("id")=cint(A2) then
				Response.write "selected"
			end if
			Response.write ">"
			Response.write rs88("sort1")
			Response.write "</option>" & vbcrlf & ""
			rs88.movenext
		loop
	end if
	rs88.close
	set rs88=nothing
	hasTelMc = false
	if ZBRuntime.MC(1000) or ZBRuntime.MC(1002) then
		hasTelMc = true
	end if
	Response.write "" & vbcrlf & "</select>" & vbcrlf & "      <input type=""submit"" name=""Submit422"" value=""检索""  class=""anybutton""/><span id=s1>"
	if open_7_10=1 or open_7_10=3 then
		Response.write "" & vbcrlf & "      <input type=""button"" name=""Submitdel2"" value=""导出"" onClick=""if(confirm('确认导出为EXCEL文档？')){exportExcel({from:'form_with_page_action',page:'../out/xls_hkhz.asp?zmr="
		Response.write zmr
		Response.write "&zmr_zj="
		Response.write zmr_zj
		Response.write "&fst="
		Response.write fst
		Response.write "&zmr_zc="
		Response.write zmr_zc
		Response.write "&zmr_qc="
		Response.write zmr_qc
		Response.write "&zmr_xy="
		Response.write zmr_xy
		Response.write "&zmr_tk="
		Response.write zmr_tk
		Response.write "&A="
		Response.write A
		Response.write "&A2="
		Response.write A2
		Response.write "&B="
		Response.write B
		Response.write "&FK="
		Response.write FK
		Response.write "&C="
		Response.write server.urlencode(C)
		Response.write "&D="
		Response.write D
		Response.write "&ret="
		Response.write m1
		Response.write "&ret2="
		Response.write m2
		Response.write "&page_count="
		Response.write page_count
		Response.write "&px="
		Response.write px
		Response.write "&IsType="
		Response.write IsType
		Response.write "'})}"" class=""anybutton""/>" & vbcrlf & "    "
	end if
	if open_7_7=1 or open_7_7=3 then
		Response.write "<input type=""button""  name=""print"" onclick=""javascript:s1.style.display='none';window.print();return  false;"" value=""打印"" class=""anybutton""/>"
	end if
	Response.write "</span></td>" & vbcrlf & "        </tr>" & vbcrlf & "      </table>" & vbcrlf & "        <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "</form>" & vbcrlf & "      <tr class=""top"">" & vbcrlf & "    "
	if hasTelMc then
		Response.write "<td height=""27"" width=""20%"" ><div align=""center"">"
		Response.write khname
		Response.write "</div></td>"
	end if
	Response.write "" & vbcrlf & "        <td width=""10%"" colspan=""4""><div align=""center"" style=""font:bold"">收款</div></td>" & vbcrlf & "       <td width=""10%"" colspan=""4""><div align=""center""style=""font:bold"" >开票</div></td>" & vbcrlf & "       <td width=""10%"" colspan=""4""><div align=""center"">销售人员</div></td>"& vbcrlf &"      </tr> "& vbcrlf &"     <tr class=""> "& vbcrlf &""
	if hasTelMc then
		Response.write "<td height=""27"" width=""14%"" style=""background-image:none"" ></td>"
'if hasTelMc then
	end if
	Response.write "" & vbcrlf & "        <td width=""9%""  style=""background-image:none""><div align=""center"">期初应收</div></td>" & vbcrlf & "         <td width=""9%""  style=""background-image:none""><div align=""center"">本期应收</div></td>" & vbcrlf & "         <td width=""9%""  style=""background-image:none""><div align=""center"">本期实收</div></td> "& vbcrlf &"        <td width=""9%""  style=""background-image:none""><div align=""center"">期末应收</div></td>" & vbcrlf &"          <td width=""9%""  style=""background-image:none""><div align=""center"">期初应开票</div></td> "& vbcrlf &"        <td width=""9%""  style=""background-image:none""><div align=""center"">本期应开票</div></td>" & vbcrlf & "      <td width=""9%""  style=""background-image:none""><div align=""center"">本期实开票</div></td>" & vbcrlf & "       <td width=""9%""  style=""background-image:none""><div align=""center"">期末应开票</div></td>" & vbcrlf & "       <td width=""5%""  style=""background-image:none""></td>" & vbcrlf & "     </tr>" & vbcrlf & ""
	dim summoney1,summoney2,summoney3,summoney4,summoney5,money1_all,money2_all,money3_all,money4_all,money5_all
	Dim Rmb_SumMoney1,Rmb_SumMoney2,Rmb_SumMoney4,Rmb_SumMoney5
	Dim Rmb_Money_All1,Rmb_Money_All2,Rmb_Money_All4,Rmb_Money_All5
	summoney1=0
	summoney2=0
	summoney3=0
	summoney4=0
	summoney5=0
	summoney7=0
	summoney8=0
	summoney9=0
	money1_all=0
	money2_all=0
	money3_all=0
	money4_all=0
	money5_all=0
	money7_all=0
	money8_all=0
	money9_all=0
	Rmb_SumMoney1=0
	Rmb_SumMoney2=0
	Rmb_SumMoney3=0
	Rmb_SumMoney4=0
	Rmb_SumMoney5=0
	Rmb_SumMoney7=0
	Rmb_SumMoney8=0
	Rmb_SumMoney9=0
	Rmb_Money_All1=0
	Rmb_Money_All2=0
	Rmb_Money_All3=0
	Rmb_Money_All4=0
	Rmb_Money_All5=0
	Rmb_Money_All7=0
	Rmb_Money_All8=0
	Rmb_Money_All9=0
	n=0
	sqlStr ="select company, bz,                                                                                                                                                                                                   "&_
	"    (ISNULL(期初应收回款,0)-ISNULL(期初实收回款,0)-ISNULL(期初应退金额,0)+ISNULL(期初已退金额,0)) 期初应收, (ISNULL(期初应收回款_RMB,0)-ISNULL(期初实收回款_rmb,0)-ISNULL(期初应退金额_rmb,0)+ISNULL(期初已退金额_rmb,0)) 期初应收_rmb,    "&_
	"    ISNULL(应收总额,0)-ISNULL(应退总额,0) 本期应收,ISNULL(应收总额_rmb,0)-ISNULL(应退总额_RMB,0) 本期应收_rmb,                                                                                                        "&_
	"    ISNULL(已收总额,0)-ISNULL(已退总额,0) 本期实收, ISNULL(已收总额_rmb,0)-ISNULL(已退总额_RMB,0) 本期实收_rmb,                                                                                                       "&_
	"    (ISNULL(期初应收回款,0)-ISNULL(期初实收回款,0)-ISNULL(期初应退金额,0)+ISNULL(期初已退金额,0))+(ISNULL(应收总额,0)-ISNULL(应退总额,0))-(ISNULL(已收总额,0)-ISNULL(已退总额,0)) 期末应收,                                                                                 "&_
	"    (ISNULL(期初应收回款_RMB,0)-ISNULL(期初实收回款_rmb,0)-ISNULL(期初应退金额_rmb,0)+ISNULL(期初已退金额_rmb,0))+(ISNULL(应收总额_rmb,0)-ISNULL(应退总额_RMB,0))-(ISNULL(已收总额_rmb,0)-ISNULL(已退总额_RMB,0)) 期末应收_rmb,                                                     "&_
	"    (ISNULL(期初应开票金额,0)-ISNULL(期初负数应开票金额,0)) 期初应开票, (ISNULL(期初应开票金额_rmb,0)-ISNULL(期初负数应开票金额_rmb,0)) 期初应开票_rmb,                                                               "&_
	"    ISNULL(本期应开票金额,0)-ISNULL(本期负数应开票金额,0) 本期应开票,ISNULL(本期应开票金额_rmb,0)-ISNULL(本期负数应开票金额_rmb,0) 本期应开票_rmb,                                                                    "&_
	"    ISNULL(本期实开票金额,0)-ISNULL(红冲发票金额,0) 本期实开票, ISNULL(本期实开票金额_rmb,0)-ISNULL(红冲发票金额金额_rmb,0) 本期实开票_rmb,                                                                           "&_
	"    (ISNULL(期初应开票金额,0)-ISNULL(期初负数应开票金额,0)) +(ISNULL(本期应开票金额,0)-ISNULL(本期负数应开票金额,0))-(ISNULL(本期实开票金额,0)-ISNULL(红冲发票金额,0)) 期末应开票,                                    "&_
	"    (ISNULL(期初应开票金额_rmb,0)-ISNULL(期初负数应开票金额_rmb,0))+(ISNULL(本期应开票金额_rmb,0)-ISNULL(本期负数应开票金额_rmb,0))-(ISNULL(本期实开票金额_rmb,0)-ISNULL(红冲发票金额金额_rmb,0)) 期末应开票_rmb      "&_
	"    into #tempall from(                                                                "&_
	"select company, bz, SUM(期初应收回款) AS 期初应收回款, SUM(期初应收回款_RMB) AS 期初应收回款_RMB   "&_
	"   ,SUM(期初实收回款) as 期初实收回款,SUM(期初实收回款_rmb) as 期初实收回款_rmb            "&_
	"   ,SUM(期初应退金额) as 期初应退金额,SUM(期初应退金额_rmb) as 期初应退金额_rmb,SUM(期初已退金额) as 期初已退金额,SUM(期初已退金额_rmb) as 期初已退金额_rmb            "&_
	"   ,SUM(应收总额) as 应收总额,SUM(应收总额_rmb) as 应收总额_rmb            "&_
	"   ,SUM(已收总额) as 已收总额,SUM(已收总额_RMB) as 已收总额_RMB            "&_
	"   ,SUM(应退总额) as 应退总额,SUM(应退总额_RMB) as 应退总额_RMB            "&_
	"   ,SUM(已退总额) as 已退总额,SUM(已退总额_rmb) as 已退总额_rmb            "&_
	"   , sum(期初应开票金额) as 期初应开票金额, SUM(期初应开票金额_rmb) AS 期初应开票金额_rmb                      "&_
	"   , sum(期初负数应开票金额) as 期初负数应开票金额, SUM(期初负数应开票金额_rmb) AS 期初负数应开票金额_rmb      "&_
	"   , sum(本期应开票金额) as 本期应开票金额, SUM(本期应开票金额_rmb) AS 本期应开票金额_rmb                      "&_
	"   , sum(本期负数应开票金额) as 本期负数应开票金额, SUM(本期负数应开票金额_rmb) AS 本期负数应开票金额_rmb      "&_
	"   , sum(本期实开票金额) as 本期实开票金额, SUM(本期实开票金额_rmb) AS 本期实开票金额_rmb                      "&_
	"   , sum(红冲发票金额) as 红冲发票金额, SUM(红冲发票金额金额_rmb) AS 红冲发票金额金额_rmb                      "&_
	"    from ( "&_
	"      SELECT a.company, isnull(a.bz,14) bz, "&_
	"          SUM(a.money1) AS 期初应收回款,SUM(a.money1 * isnull(c.hl, 1)) AS 期初应收回款_RMB  "&_
	"          , 0 AS 期初实收回款, 0 AS 期初实收回款_RMB  "&_
	"          , 0 AS 期初应退金额, 0 AS 期初应退金额_rmb, 0 AS 期初已退金额, 0 AS 期初已退金额_rmb, 0 AS 应收总额, 0 AS 应收总额_rmb  "&_
	"          , 0 AS 已收总额, 0 AS 已收总额_RMB, 0 AS 应退总额, 0 AS 应退总额_RMB "&_
	"          , 0 as 已退总额, 0 as 已退总额_rmb                                                                      "&_
	"          , 0 as 期初应开票金额, 0 as 期初应开票金额_rmb, 0 as 期初负数应开票金额, 0 as 期初负数应开票金额_rmb    "&_
	"          , 0 as 本期应开票金额, 0 as 本期应开票金额_rmb, 0 as 本期负数应开票金额, 0 as 本期负数应开票金额_rmb    "&_
	"          , 0 as 本期实开票金额, 0 as 本期实开票金额_rmb, 0 as 红冲发票金额, 0 as 红冲发票金额金额_rmb            "&_
	"      from payback a WITH (NOLOCK) "&_
	"              LEFT JOIN (SELECT bz, hl, date1 FROM hl WITH (NOLOCK)GROUP BY bz, hl, date1) c ON c.date1 = a.Date1 AND c.bz = a.bz "&_
	"              WHERE a.del = 1 "& sql_qcpayback &""&_
	"      group by a.company, a.bz"&_
	"          union all "&_
	"      SELECT a.company, isnull(a.bz,14) bz,0,0 "&_
	"          ,SUM(a.money1) AS 期初实收回款,SUM(a.money1 * isnull(c.hl, 1)) AS 期初实收回款_RMB  "&_
	"          , 0 AS 期初应退金额, 0 AS 期初应退金额_rmb, 0 AS 期初已退金额, 0 AS 期初已退金额_rmb, 0 AS 应收总额, 0 AS 应收总额_rmb  "&_
	"          , 0 AS 已收总额, 0 AS 已收总额_RMB, 0 AS 应退总额, 0 AS 应退总额_RMB "&_
	"           , 0 as 已退总额, 0 as 已退总额_rmb                                                                      "&_
	"                  , 0 as 期初应开票金额, 0 as 期初应开票金额_rmb, 0 as 期初负数应开票金额, 0 as 期初负数应开票金额_rmb    "&_
	"           , 0 as 本期应开票金额, 0 as 本期应开票金额_rmb, 0 as 本期负数应开票金额, 0 as 本期负数应开票金额_rmb    "&_
	"           , 0 as 本期实开票金额, 0 as 本期实开票金额_rmb, 0 as 红冲发票金额, 0 as 红冲发票金额金额_rmb            "&_
	"      from payback a WITH (NOLOCK) "&_
	"              LEFT JOIN (SELECT bz, hl, date1 FROM hl WITH (NOLOCK)GROUP BY bz, hl, date1) c ON c.date1 = a.Date1 AND c.bz = a.bz "&_
	"              WHERE a.del = 1 "& sql_qcpayback2 &""&_
	"      group by a.company, a.bz"&_
	"          union all "&_
	"          SELECT h.company, h.bz , 0, 0,0,0 "&_
	"          ,SUM(y.money1) AS 期初应退金额, SUM(y.money1* isnull(l.hl, 1)) AS 期初应退金额_rmb "&_
	"          , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "&_
	"          , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "&_
	"      FROM  payout2 y WITH (NOLOCK) "&_
	"          LEFT JOIN contractth h WITH (NOLOCK) ON h.ord = y.contractth "&_
	"          LEFT JOIN ( SELECT bz, hl, date1 FROM hl WITH (NOLOCK) GROUP BY bz, hl, date1 ) l ON l.date1 = h.date3 AND l.bz = h.bz "&_
	"              where y.del=1 "& sql_qcout &""&_
	"      GROUP BY h.company, h.bz "&_
	"          union all "&_
	"          SELECT h.company, h.bz , 0, 0,0,0,0,0 "&_
	"          ,SUM(y.money1) AS 期初已退金额, SUM(y.money1* isnull(l.hl, 1)) AS 期初已退金额_rmb "&_
	"          , 0, 0, 0, 0, 0, 0, 0, 0 "&_
	"          , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "&_
	"      FROM  payout2 y WITH (NOLOCK) "&_
	"          LEFT JOIN contractth h WITH (NOLOCK) ON h.ord = y.contractth "&_
	"          LEFT JOIN ( SELECT bz, hl, date1 FROM hl WITH (NOLOCK) GROUP BY bz, hl, date1 ) l ON l.date1 = h.date3 AND l.bz = h.bz "&_
	"              where y.del=1 "& sql_qcout2 &""&_
	"      GROUP BY h.company, h.bz "&_
	"          union all "&_
	"          select a.company, a.bz, 0 , 0 , 0, 0, 0 , 0 , 0, 0, "&_
	"          a.money1 as 应收总额,a.money1*isnull(c.hl,1) as 应收总额_rmb  "&_
	"          , 0, 0, 0, 0, 0, 0 "&_
	"      , 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0"    &_
	"          from payback a WITH(NOLOCK)  "&_
	"          left join (SELECT bz, hl, date1 FROM hl WITH (NOLOCK) GROUP BY bz, hl, date1) c on c.date1 = a.date1 and c.bz = a.bz "&_
	"          where a.del=1 "& sql_result &""&_
	"          union all "&_
	"          select a.company,a.bz, "&_
	"          0,0,0,0,0,0, 0 , 0 , 0, 0, "&_
	"          a.money1 as 已收总额, a.money1 *isnull(c.hl,1) as 已收总额_RMB, "&_
	"          0,0,0,0 "&_
	"      , 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0"    &_
	"          from payback a WITH(NOLOCK)  "&_
	"          left join ( "&_
	"                  SELECT bz, hl, date1 FROM hl WITH (NOLOCK) GROUP BY bz, hl, date1 "&_
	"          ) c on c.date1 = a.date1 AND c.bz = a.bz "&_
	"          where a.del=1 and a.complete = 3 "& replace(sql_result,"a.date1","a.date5") &""&_
	"          union all "&_
	"          select h.company,h.bz,0,0,0,0,0,0,0,0, 0 , 0 , 0, 0, "&_
	"          y.money1 as 应退总额, y.money1*isnull(l.hl,1) as 应退总额_RMB, "&_
	"          0 , 0  "&_
	"      , 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0" &_
	"          from payout2 y WITH(NOLOCK)  "&_
	"          left join contractth h WITH(NOLOCK) on h.ord=y.contractth  "&_
	"          left join (select bz,hl,date1 from hl WITH(NOLOCK) group by bz,hl,date1) l on l.date1 = h.date3 and l.bz = h.bz "&_
	"          where y.del=1 "& sql_pout &""&_
	"          union all "&_
	"          select h.company,h.bz,0,0,0,0,0,0,0,0,0,0, 0 , 0 , 0, 0, "&_
	"          y.money1 as 已退总额,y.money1 *isnull(l.hl,1) as 已退总额_rmb "&_
	"      , 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0" &_
	"          from payout2 y WITH(NOLOCK)  "&_
	"          left join contractth h WITH(NOLOCK) on h.ord=y.contractth  "&_
	"          left join ( "&_
	"                  select bz,hl,date1 from hl WITH(NOLOCK) group by bz,hl,date1 "&_
	"          ) l on l.date1 = h.date3 and l.bz = h.bz  "&_
	"          where y.del=1 and y.complete = 2 "& replace(sql_pout,"y.date1","y.date2") &""&_
	"          union all                                                                                                                                                         "&_
	"      SELECT bi.Company,bi.bz, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0, 0 , 0 , 0, 0,                                                                                                        "&_
	"      bi.money1 as 期初应开票金额,                                                                                                                                       "&_
	"      bi.money1 * isnull(l.hl, 1) as 期初应开票金额_rmb                                                                                                                  "&_
	"      , 0, 0, 0, 0, 0, 0, 0, 0,0,0                                                                                                                                       "&_
	"      from PaybackInvoice bi WITH (NOLOCK) LEFT JOIN ( SELECT bz, hl, date1 FROM hl WITH (NOLOCK) GROUP BY bz, hl, date1 ) l on l.date1 = bi.Date7 and l.bz=bi.bz        "&_
	"      WHERE bi.del = 1  and FromType!='ContractTH' and isnull(RedJoinId,0) = 0 "& sql_qcpbi & sql_pbi_zmr &"                                    "&_
	"      UNION ALL                                                                         "&_
	"      SELECT bi.Company,bi.bz, 0 , 0 , 0, 0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0                         "&_
	"          ,0,0,                                                                         "&_
	"          bi.money1 as 期初负数应开票金额,                                              "&_
	"          bi.money1 * isnull(l.hl, 1) as 期初负数应开票金额_rmb                         "&_
	"          , 0, 0, 0, 0, 0, 0, 0, 0                                                      "&_
	"      from PaybackInvoice bi WITH (NOLOCK)                                              "&_
	"                  LEFT JOIN (                                                              "&_
	"                  SELECT bz, hl, date1 FROM hl WITH (NOLOCK) GROUP BY bz, hl, date1        "&_
	"          ) l on l.date1 = bi.Date7 and l.bz=bi.bz                                      "&_
	"      WHERE bi.del = 1 and (bi.fromType='ContractTH' or isnull(RedJoinId,0) > 0) "& sql_qcpbi & nsql_qcpbi_zmr &_
	"      UNION ALL                                                                         "&_
	"      SELECT bi.Company,bi.bz, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0, 0 , 0 , 0, 0,                        "&_
	"          0,0,0,0,                                                                      "&_
	"          bi.money1 as 本期应开票金额,                                                  "&_
	"          bi.money1 * isnull(l.hl, 1) as 本期应开票金额_rmb                             "&_
	"          , 0, 0, 0, 0, 0, 0                                                            "&_
	"      from PaybackInvoice bi WITH (NOLOCK)                                              "&_
	"              LEFT JOIN ( SELECT bz, hl, date1 FROM hl WITH (NOLOCK) GROUP BY bz, hl, date1 "&_
	"          ) l on l.date1 = bi.Date7 and l.bz=bi.bz                                      "&_
	"      WHERE bi.del = 1 and FromType!='ContractTH' and isnull(bi.RedJoinId,0) = 0 and isnull(bi.isInvoiced,0)<>3 "&sql_pbi& sql_pbi_zmr &_
	"      UNION ALL                                                                         "&_
	"      SELECT bi.Company,bi.bz, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0, 0 , 0 , 0, 0                         "&_
	"          ,0,0,0,0,0,0,                                                                 "&_
	"          bi.money1 as 本期负数应开票金额,                                              "& _
	"          bi.money1 * isnull(l.hl, 1) as 本期负数应开票金额_rmb                         "& _
	"          , 0, 0, 0, 0                                                                  "&_
	"      from PaybackInvoice bi WITH (NOLOCK)                                              "&_
	"              LEFT JOIN( SELECT bz, hl, date1 FROM hl WITH (NOLOCK) GROUP BY bz, hl, date1  "&_
	"          ) l on l.date1 = bi.Date7 and l.bz=bi.bz                                      "&_
	"      WHERE bi.del = 1 and (bi.fromType='ContractTH' or isnull(bi.RedJoinId,0) > 0) "&sql_pbi& nsql_pbi_zmr &_
	"      UNION ALL                                                                         "&_
	"      select bi.company,bi.bz,0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0 , 0 , 0 , 0, 0                         "&_
	"          ,0,0,0,0,0,0,0,0,                                                             "&_
	"          bi.money1 as 本期实开票金额,                                                  "&_
	"          bi.money1 * isnull(l.hl, 1) as 本期实开票金额_rmb                             "&_
	"          , 0, 0                                                                        "&_
	"      from PaybackInvoice bi with (nolock)                                              "&_
	"                  LEFT JOIN ( SELECT bz, hl, date1 FROM hl WITH (NOLOCK) GROUP BY bz, hl, date1 "&_
	"          ) l on l.date1 = bi.Date7 and l.bz=bi.bz                                      "&_
	"      WHERE bi.del = 1 and (bi.IsInvoiced=1 or bi.IsInvoiced=2) and FromType!='ContractTH' and isnull(bi.RedJoinId,0) = 0 "&sql_pbsi& sql_pbi_zmr &_
	"          UNION ALL                                                                         "&_
	"      select bi.company,bi.bz,0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0, 0 , 0 , 0, 0                            "&_
	"          ,0,0,0,0,0,0,0,0,0,0,                                                         "&_
	"          bi.money1 as 红冲发票金额,                                                     "&_
	"          bi.money1 * isnull(l.hl, 1) as 红冲发票金额金额_rmb                            "&_
	"      from PaybackInvoice bi with (nolock)                                               "&_
	"                  LEFT JOIN (SELECT bz, hl, date1  FROM hl WITH (NOLOCK) GROUP BY bz, hl, date1 "&_
	"          ) l on l.date1 = bi.Date7 and l.bz=bi.bz                                        "&_
	"      WHERE bi.del = 1  and (bi.fromType='ContractTH' or isnull(bi.RedJoinId,0) > 0) and (bi.IsInvoiced=1 or bi.IsInvoiced=2) "&sql_pbsi& nsql_pbsi_zmr &_
	"      ) p group by company,bz"     &_
	"   )t"
	conn.execute (sqlStr)
	mainSql = "from (select * from #tempall) p " & vbcrlf &_
	"inner join tel t WITH(NOLOCK) on t.ord = p.company and t.del=1 " & vbcrlf &_
	"left join gate  g on g.ord = t.cateid " & vbcrlf &_
	"left join sortbz s WITH(NOLOCK) on s.id=p.bz where 1=1 "& str_Result11 &" " & vbcrlf &_
	"  and ( isnull(期初应收,0)<>0 or isnull(本期应收,0)<>0 or isnull(本期实收,0)<>0 or isnull(期末应收,0)<>0 or isnull(期初应开票,0)<>0 or isnull(本期应开票,0)<>0 or isnull(本期实开票,0)<>0 or ISNULL(期末应开票,0)<>0 or isnull(期初应收_rmb,0)<>0 or isnull(本期应收_rmb,0)<>0 or isnull(本期实收_rmb,0)<>0 or isnull(期末应收_rmb,0)<>0 or isnull(期初应开票_rmb,0)<>0 or isnull(本期应开票_rmb,0)<>0 or isnull(本期实开票_rmb,0)<>0 or ISNULL(期末应开票_rmb,0)<>0) "
	countsql = "select count(1) recordcount," & vbcrlf &_
	"sum(ISNULL(期初应收,0)) 期初应收, sum(ISNULL(期初应收_rmb,0)) 期初应收_rmb," & vbcrlf &_
	"sum(ISNULL(本期应收,0)) 本期应收, sum(ISNULL(本期应收_rmb,0)) 本期应收_rmb," & vbcrlf &_
	"sum(ISNULL(本期实收,0)) 本期实收, sum(ISNULL(本期实收_rmb,0)) 本期实收_rmb," & vbcrlf &_
	"sum(ISNULL(期末应收,0)) 期末应收, sum(ISNULL(期末应收_rmb,0)) 期末应收_rmb," & vbcrlf &_
	"sum(ISNULL(期初应开票,0)) 期初应开票, sum(ISNULL(期初应开票_rmb,0)) 期初应开票_rmb," & vbcrlf &_
	"sum(ISNULL(本期应开票,0)) 本期应开票, sum(ISNULL(本期应开票_rmb,0)) 本期应开票_rmb," & vbcrlf &_
	"sum(ISNULL(本期实开票,0)) 本期实开票, sum(ISNULL(本期实开票_rmb,0)) 本期实开票_rmb," & vbcrlf &_
	"sum(ISNULL(期末应开票,0)) 期末应开票, sum(ISNULL(期末应开票_rmb,0)) 期末应开票_rmb " & vbcrlf &_
	" " & mainSql
	Set rs = conn.execute(countsql)
	If rs.eof = False Then
		recordcount=rs("recordcount")
		money1_all=rs("期初应收") : Rmb_Money_All1 = rs("期初应收_rmb")
		money2_all=rs("本期应收") : Rmb_Money_All2 = rs("本期应收_rmb")
		money3_all=rs("本期实收") : Rmb_Money_All3 = rs("本期实收_rmb")
		money4_all=rs("期末应收") : Rmb_Money_All4 = rs("期末应收_rmb")
		money5_all=rs("期初应开票") : Rmb_Money_All5 = rs("期初应开票_rmb")
		money7_all=rs("本期应开票") : Rmb_Money_All7 = rs("本期应开票_rmb")
		money8_all=rs("本期实开票") : Rmb_Money_All8 = rs("本期实开票_rmb")
		money9_all=rs("期末应开票") : Rmb_Money_All9 = rs("期末应开票_rmb")
	end if
	rs.close
	set rs = nothing
	If recordcount&"" = "" Then recordcount = 0 Else recordcount = CDBL(recordcount)
	If money1_all&"" = "" Then money1_all = 0 Else money1_all = CDBL(money1_all)
	If money2_all&"" = "" Then money2_all = 0 Else money2_all = CDBL(money2_all)
	If money3_all&"" = "" Then money3_all = 0 Else money3_all = CDBL(money3_all)
	If money4_all&"" = "" Then money4_all = 0 Else money4_all = CDBL(money4_all)
	If money5_all&"" = "" Then money5_all = 0 Else money5_all = CDBL(money5_all)
	If money7_all&"" = "" Then money7_all = 0 Else money7_all = CDBL(money7_all)
	If money8_all&"" = "" Then money8_all = 0 Else money8_all = CDBL(money8_all)
	If money9_all&"" = "" Then money9_all = 0 Else money9_all = CDBL(money9_all)
	If Rmb_Money_All1&"" = "" Then Rmb_Money_All1 = 0 Else Rmb_Money_All1 = CDBL(Rmb_Money_All1)
	If Rmb_Money_All2&"" = "" Then Rmb_Money_All2 = 0 Else Rmb_Money_All2 = CDBL(Rmb_Money_All2)
	If Rmb_Money_All3&"" = "" Then Rmb_Money_All3 = 0 Else Rmb_Money_All3 = CDBL(Rmb_Money_All3)
	If Rmb_Money_All4&"" = "" Then Rmb_Money_All4 = 0 Else Rmb_Money_All4 = CDBL(Rmb_Money_All4)
	If Rmb_Money_All5&"" = "" Then Rmb_Money_All5 = 0 Else Rmb_Money_All5 = CDBL(Rmb_Money_All5)
	If Rmb_Money_All7&"" = "" Then Rmb_Money_All7 = 0 Else Rmb_Money_All7 = CDBL(Rmb_Money_All7)
	If Rmb_Money_All8&"" = "" Then Rmb_Money_All8 = 0 Else Rmb_Money_All8 = CDBL(Rmb_Money_All8)
	If Rmb_Money_All9&"" = "" Then Rmb_Money_All9 = 0 Else Rmb_Money_All9 = CDBL(Rmb_Money_All9)
	pagecount = int(recordcount/ page_count) + Abs(recordcount Mod page_count>0)
	'If Rmb_Money_All9&"" = "" Then Rmb_Money_All9 = 0 Else Rmb_Money_All9 = CDBL(Rmb_Money_All9)
	if currpage>=PageCount then
		currpage=PageCount
	end if
	sql = "select * from (select isnull(t.name,'') as 客户名称,  " & vbcrlf &_
	"isnull(t.ord,0) company,t.cateid, ISNULL(t.share,'-222') share,t.ord khord2, t.cateid cateid2, t.sort3, " & vbcrlf &_
	"ISNULL(p.bz, 0) as 币种,s.intro as sortbz,g.name as 销售人员 , "& vbcrlf &_
	"ISNULL(期初应收,0) 期初应收,ISNULL(期初应收_rmb,0) 期初应收_rmb," & vbcrlf &_
	"ISNULL(本期应收,0) 本期应收,ISNULL(本期应收_rmb,0) 本期应收_rmb," & vbcrlf &_
	"ISNULL(本期实收,0) 本期实收,ISNULL(本期实收_rmb,0) 本期实收_rmb," & vbcrlf &_
	"ISNULL(期末应收,0) 期末应收,ISNULL(期末应收_rmb,0) 期末应收_rmb," & vbcrlf &_
	"ISNULL(期初应开票,0) 期初应开票,ISNULL(期初应开票_rmb,0) 期初应开票_rmb," & vbcrlf &_
	"ISNULL(本期应开票,0) 本期应开票,ISNULL(本期应开票_rmb,0) 本期应开票_rmb," & vbcrlf &_
	"ISNULL(本期实开票,0) 本期实开票,ISNULL(本期实开票_rmb,0) 本期实开票_rmb," & vbcrlf &_
	"ISNULL(期末应开票,0) 期末应开票,ISNULL(期末应开票_rmb,0) 期末应开票_rmb," & vbcrlf &_
	" (row_number() OVER("& px_Result &"))  as rownum " & mainSql  &_
	") skTab where (rownum between " & (page_count*(currpage-1)+1) & " and " & (page_count*currpage) & " )  order by rownum"
	money1=0 : money2=0 : money5=0 : money3=0
    money4=0 : money7=0 : money8=0
	set rs=server.CreateObject("adodb.recordset")
	rs.open sql,conn,1,1
	if recordcount<=0 then
		Response.write "<table><tr><td>没有信息!</td></tr></table>"
	else
		do until rs.eof
			bz1 = rs("币种")
			sortbz = rs("sortbz")
			company=rs("company")
			companyname = rs("客户名称")
			share = rs("share")
			cateid_kh = rs("cateid2")
			cateid = rs("cateid")
			Set rs2 = conn.execute("select name from gate where ord = '"&cateid&"'")
			If rs2.eof = False Then
				cateName = rs2("name")
			else
				cateName = ""
			end if
			rs2.close
			set rs2=nothing
			if cateid_kh=0 or cateid_kh="" then
				cateid_kh=-1
'if cateid_kh=0 or cateid_kh="" then
			end if
			money1=rs("期初应收") : money1_rmb=rs("期初应收_rmb")
			money2=rs("本期应收") : money2_rmb=rs("本期应收_rmb")
			money3=rs("本期实收") : money3_rmb=rs("本期实收_rmb")
			money4=rs("期末应收") : money4_rmb=rs("期末应收_rmb")
			money5=rs("期初应开票") : money5_rmb=rs("期初应开票_rmb")
			money7=rs("本期应开票") : money7_rmb=rs("本期应开票_rmb")
			money8=rs("本期实开票") : money8_rmb=rs("本期实开票_rmb")
			money9=rs("期末应开票") : money9_rmb=rs("期末应开票_rmb")
			If money1&"" = "" Then money1 = 0 Else money1 = CDBL(money1)
			If money1_rmb&"" = "" Then money1_rmb = 0 Else money1_rmb = CDBL(money1_rmb)
			If money2&"" = "" Then money2 = 0 Else money2 = CDBL(money2)
			If money2_rmb&"" = "" Then money2_rmb = 0 Else money2_rmb = CDBL(money2_rmb)
			If money3&"" = "" Then money3 = 0 Else money3 = CDBL(money3)
			If money3_rmb&"" = "" Then money3_rmb = 0 Else money3_rmb = CDBL(money3_rmb)
			If money4&"" = "" Then money4 = 0 Else money4 = CDBL(money4)
			If money4_rmb&"" = "" Then money4_rmb = 0 Else money4_rmb = CDBL(money4_rmb)
			If money5&"" = "" Then money5 = 0 Else money5 = CDBL(money5)
			If money5_rmb&"" = "" Then money5_rmb = 0 Else money5_rmb = CDBL(money5_rmb)
			If money7&"" = "" Then money7 = 0 Else money7 = CDBL(money7)
			If money7_rmb&"" = "" Then money7_rmb = 0 Else money7_rmb = CDBL(money7_rmb)
			If money8&"" = "" Then money8 = 0 Else money8 = CDBL(money8)
			If money8_rmb&"" = "" Then money8_rmb = 0 Else money8_rmb = CDBL(money8_rmb)
			If money9&"" = "" Then money9 = 0 Else money9 = CDBL(money9)
			If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			summoney1=summoney1+money1
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			summoney2=summoney2+money2
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			summoney3=summoney3+money3
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			summoney4=summoney4+money4
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			summoney5=summoney5+money5
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			summoney7=summoney7+money7
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			summoney8=summoney8+money8
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			summoney9=summoney9+money9
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			Rmb_SumMoney1 = Rmb_SumMoney1 + money1_rmb
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			Rmb_SumMoney2 = Rmb_SumMoney2 + money2_rmb
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			Rmb_SumMoney3 = Rmb_SumMoney3 + money3_rmb
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			Rmb_SumMoney4 = Rmb_SumMoney4 + money4_rmb
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			Rmb_SumMoney5 = Rmb_SumMoney5 + money5_rmb
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			Rmb_SumMoney7 = Rmb_SumMoney7 + money7_rmb
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			Rmb_SumMoney8 = Rmb_SumMoney8 + money8_rmb
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			Rmb_SumMoney9 = Rmb_SumMoney9 + money9_rmb
'If money9_rmb&"" = "" Then money9_rmb = 0 Else money9_rmb = CDBL(money9_rmb)
			Response.write "" & vbcrlf & "     <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & ""
			if hasTelMc then
				Response.write " " & vbcrlf & "    <td height=""27"">" & vbcrlf & "  "
				If company = 0 Then
					If rs("sort3") = 2 Then
						Response.write "<div style='color:red'>供应商已删除</div>"
					else
						Response.write "<div style='color:red'>客户已删除</div>"
					end if
				else
					If InStr(1,","&share&",", ","&session("personzbintel2007")&",",1) > 0 Or share = "1" Then
						IsShare = True
					else
						IsShare = False
					end if
					If rs("sort3") = 1 Then
						if open_1_1=3 or CheckPurview(intro_1_1,trim(cateid_kh))=True Or IsShare then
							if open_1_14=3 or CheckPurview(intro_1_14,trim(cateid_kh))=True then
								Response.write "" & vbcrlf & "                                     <a href=""javascript:;"" onclick=""javascript:window.open('../work/content.asp?ord="
								Response.write pwurl(company)
								Response.write "','workcon','width=' + 800 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">"
								'Response.write pwurl(company)
								Response.write companyname
								Response.write "</a>" & vbcrlf & "                         "
							else
								Response.write companyname
							end if
						end if
					ElseIf rs("sort3") = 2 Then
						if open_26_1=3 or CheckPurview(intro_26_1,trim(cateid_kh))=True then
							if open_26_14=3 or CheckPurview(intro_26_14,trim(cateid_kh))=True then
								Response.write "" & vbcrlf & "                                     <a href=""javascript:;"" onclick=""javascript:window.open('../work2/content.asp?ord="
								Response.write pwurl(company)
								Response.write "','work2con','width=' + 800 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">"
								'Response.write pwurl(company)
								Response.write companyname
								Response.write "</a>" & vbcrlf & "                         "
							else
								Response.write companyname
							end if
						end if
					end if
				end if
				Response.write "" & vbcrlf & "     </td> " & vbcrlf & ""
			end if
			Response.write "" & vbcrlf & "      <td align=""right"">" & vbcrlf & "          "
			if open_7_1=3 or CheckPurview(intro_7_1,trim(cateid_kh))=True then
				newRet2 =  DateAdd("d",-1,m1)
'if open_7_1=3 or CheckPurview(intro_7_1,trim(cateid_kh))=True then
				Response.write "" & vbcrlf & "            <a href=""javascript:;"" onclick=""javascript:window.open('../../SYSA/money/planall2.asp?company="
				Response.write pwurl(company)
				Response.write "&ret2="
				Response.write  year(newRet2)&"-"&Right("0" & month(newRet2), 2)&"-"&Right("0" & day(newRet2), 2)
				Response.write "&ret2="
				Response.write "&bz="
				Response.write bz1
				Response.write "&hastk=1&A=9'," & vbcrlf & "                'new20win','width=' + 1000 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=100');return false;"">" & vbcrlf & "                "
				'Response.write bz1
				Response.write sortbz & Formatnumber(money1,num_dot_xs,-1)
				'Response.write bz1
				Response.write "" & vbcrlf & "            </a>" & vbcrlf & "           "
			else
				Response.write sortbz & Formatnumber(money1,num_dot_xs,-1)
				'Response.write "" & vbcrlf & "            </a>" & vbcrlf & "           "
			end if
			Response.write "" & vbcrlf & "      </td>" & vbcrlf & "      <td align=""right"">" & vbcrlf & "          "
			if open_7_1=3 or CheckPurview(intro_7_1,trim(cateid_kh))=True then
				Response.write "" & vbcrlf & "          <a href=""javascript:;"" onclick=""javascript:window.open('../../SYSA/money/planall2.asp?company="
				Response.write pwurl(company)
				Response.write "&ret="
				Response.write m1
				Response.write "&ret2="
				Response.write m2
				Response.write "&bz="
				Response.write bz1
				Response.write "&hastk=1'," & vbcrlf & "                'new20win','width=' + 1000 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=100');return false;"">" & vbcrlf & "                "
				'Response.write bz1
				Response.write sortbz & Formatnumber(money2,num_dot_xs,-1)
				'Response.write bz1
				Response.write "" & vbcrlf & "           </a>" & vbcrlf & "          "
			else
				Response.write sortbz & Formatnumber(money2,num_dot_xs,-1)
				Response.write "" & vbcrlf & "           </a>" & vbcrlf & "          "
			end if
			Response.write "" & vbcrlf & "      </td>" & vbcrlf & "    <td align=""right"">" & vbcrlf & "          "
			if open_7_1=3 or CheckPurview(intro_7_1,trim(cateid_kh))=True then
				Response.write "" & vbcrlf & "          <a href=""javascript:;"" onclick=""javascript:window.open('../../SYSA/money/planall2.asp?company="
				Response.write pwurl(company)
				Response.write "&paydate1="
				Response.write m1
				Response.write "&paydate2="
				Response.write m2
				Response.write "&bz="
				Response.write bz1
				Response.write "&hastk=1&A=11'," & vbcrlf & "                'new20win','width=' + 1000 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=100');return false;"">" & vbcrlf & "                "
				'Response.write bz1
				Response.write sortbz & Formatnumber(money3,num_dot_xs,-1)
				'Response.write bz1
				Response.write "" & vbcrlf & "           </a>" & vbcrlf & "          "
			else
				Response.write sortbz & Formatnumber(money3,num_dot_xs,-1)
				Response.write "" & vbcrlf & "           </a>" & vbcrlf & "          "
			end if
			Response.write "" & vbcrlf & "       </td>" & vbcrlf & "   <td align=""right"">" & vbcrlf & "          "
			if open_7_1=3 or CheckPurview(intro_7_1,trim(cateid_kh))=True then
				Response.write "" & vbcrlf & "          <a href=""javascript:;"" onclick=""javascript:window.open('../../SYSA/money/planall2.asp?company="
				Response.write pwurl(company)
				Response.write "&ret2="
				Response.write m2
				Response.write "&bz="
				Response.write bz1
				Response.write "&hastk=1&A=9'," & vbcrlf & "                'new20win','width=' + 1000 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=100');return false;"">" & vbcrlf & "                "
				'Response.write bz1
				Response.write sortbz & Formatnumber(money4,num_dot_xs,-1)
				'Response.write bz1
				Response.write "" & vbcrlf & "           </a>" & vbcrlf & "          "
			else
				Response.write sortbz & Formatnumber(money4,num_dot_xs,-1)
				'Response.write "" & vbcrlf & "           </a>" & vbcrlf & "          "
			end if
			Response.write "" & vbcrlf & "       </td>" & vbcrlf & "   <td align=""right"">" & vbcrlf & "          "
			if open_7001_1=3 or CheckPurview(intro_7001_1,trim(cateid_kh))=True then
				iret2 = DateAdd("d",-1,m1)
'if open_7001_1=3 or CheckPurview(intro_7001_1,trim(cateid_kh))=True then
				Response.write "" & vbcrlf & "          <a href=""javascript:;"" onclick=""javascript:window.open('../../SYSA/money/paybackinvoice_list.asp?company="
				Response.write pwurl(company)
				Response.write "&ret2="
				Response.write  year(iret2)&"-"&Right("0" & month(iret2), 2)&"-"&Right("0" & day(iret2), 2)
				Response.write "&ret2="
				Response.write "&bz="
				Response.write bz1
				Response.write "&A=4&B=1'," & vbcrlf & "                'new20win','width=' + 1000 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=100');return false;"">" & vbcrlf & "                "
				'Response.write bz1
				Response.write sortbz & Formatnumber(money5,num_dot_xs,-1)
				'Response.write bz1
				Response.write "" & vbcrlf & "           </a>" & vbcrlf & "          "
			else
				Response.write sortbz & Formatnumber(money5,num_dot_xs,-1)
				'Response.write "" & vbcrlf & "           </a>" & vbcrlf & "          "
			end if
			Response.write "" & vbcrlf & "         </td>" & vbcrlf & "   <td align=""right"">" & vbcrlf & "          "
			if open_7001_1=3 or CheckPurview(intro_7001_1,trim(cateid_kh))=True then
				Response.write "" & vbcrlf & "          <a href=""javascript:;"" onclick=""javascript:window.open('../../SYSA/money/paybackinvoice_list.asp?company="
				Response.write pwurl(company)
				Response.write "&ret="
				Response.write m1
				Response.write "&ret2="
				Response.write m2
				Response.write "&bz="
				Response.write bz1
				Response.write "&A=6'," & vbcrlf & "                'new20win','width=' + 1000 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=100');return false;"">" & vbcrlf & "                "
				'Response.write bz1
				Response.write sortbz & Formatnumber(money7,num_dot_xs,-1)
				'Response.write bz1
				Response.write "" & vbcrlf & "           </a>" & vbcrlf & "          "
			else
				Response.write sortbz & Formatnumber(money7,num_dot_xs,-1)
				'Response.write "" & vbcrlf & "           </a>" & vbcrlf & "          "
			end if
			Response.write "" & vbcrlf & "        </td>" & vbcrlf & "      <td align=""right"">" & vbcrlf & "          "
			if open_7001_1=3 or CheckPurview(intro_7001_1,trim(cateid_kh))=True then
				Response.write "" & vbcrlf & "            <a href=""javascript:;"" onclick=""javascript:window.open('../../SYSA/money/paybackinvoice_list.asp?company="
				Response.write pwurl(company)
				Response.write "&invdate1="
				Response.write m1
				Response.write "&invdate2="
				Response.write m2
				Response.write "&bz="
				Response.write bz1
				Response.write "&A=5'," & vbcrlf & "                'new20win','width=' + 1000 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=100');return false;"">" & vbcrlf & "                "
				'Response.write bz1
				Response.write sortbz & Formatnumber(money8,num_dot_xs,-1)
				'Response.write bz1
				Response.write "" & vbcrlf & "            </a>" & vbcrlf & "          "
			else
				Response.write sortbz & Formatnumber(money8,num_dot_xs,-1)
				'Response.write "" & vbcrlf & "            </a>" & vbcrlf & "          "
			end if
			Response.write "" & vbcrlf & "      </td>" & vbcrlf & "      <td align=""right"">" & vbcrlf & "           "
			if open_7001_1=3 or CheckPurview(intro_7001_1,trim(cateid_kh))=True then
				Response.write "" & vbcrlf & "            <a href=""javascript:;"" onclick=""javascript:window.open('../../SYSA/money/paybackinvoice_list.asp?company="
				Response.write pwurl(company)
				Response.write "&ret2="
				Response.write m2
				Response.write "&bz="
				Response.write bz1
				Response.write "&A=4'," & vbcrlf & "                'new20win','width=' + 1000 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=100');return false;"">" & vbcrlf & "                "
				'Response.write bz1
				Response.write sortbz & Formatnumber(money9,num_dot_xs,-1)
				'Response.write bz1
				Response.write "" & vbcrlf & "            </a>" & vbcrlf & "          "
			else
				Response.write sortbz & Formatnumber(money9,num_dot_xs,-1)
				Response.write "" & vbcrlf & "            </a>" & vbcrlf & "          "
			end if
			Response.write "" & vbcrlf & "      </td>" & vbcrlf & "      <td align=""right"">" & vbcrlf & "          <div  align=""center"">"
			Response.write cateName
			Response.write "</div>" & vbcrlf & "      </td>" & vbcrlf & "     </tr>" & vbcrlf & ""
			n=n+1
			'Response.write "</div>" & vbcrlf & "      </td>" & vbcrlf & "     </tr>" & vbcrlf & ""
			rs.movenext
		loop
		Response.write "      " & vbcrlf & "    <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "         <td class=""name"" height=""27""><div align=""right"">本页合计：</div></td>" & vbcrlf & "         <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(summoney1,num_dot_xs,-1)
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(summoney2,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(summoney3,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(summoney4,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(summoney5,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(summoney7,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(summoney8,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(summoney9,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write "</div></td>" & vbcrlf & "     <td rowspan=""4""></td>" & vbcrlf & "     </tr>" & vbcrlf & "    <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "          <td class=""name"" height=""27""><div align=""right"">&nbsp;</div></td>" & vbcrlf & "<td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_SumMoney1,num_dot_xs,-1)
'<td ><d'iv align=""right"" style=""color:red"">￥"
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_SumMoney2,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">￥"
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_SumMoney3,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">￥"
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_SumMoney4,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">￥"
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_SumMoney5,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">￥"
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_SumMoney7,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">￥"
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_SumMoney8,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">￥"
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_SumMoney9,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">￥"
		Response.write "</div></td>" & vbcrlf & "     </tr>" & vbcrlf & " <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "     <td class=""name"" height=""27""><div align=""right"">所有合计：</div></td>" & vbcrlf & "         <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(money1_all,num_dot_xs,-1)
'ed"">"
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(money2_all,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(money3_all,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">"
		Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(money4_all,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">"
		Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(money5_all,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">"
		Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(money7_all,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">"
		Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(money8_all,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">"
		Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">"
		Response.write Formatnumber(money9_all,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">"
		Response.write "</div></td>" & vbcrlf & "    </tr> " & vbcrlf & "        <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "     <td class=""name"" height=""27""><div align=""right"">&nbsp;</div></td>" & vbcrlf & "     <td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_Money_All1,num_dot_xs,-1)
':red"">￥"
		Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_Money_All2,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">￥"
		Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_Money_All3,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">￥"
		Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_Money_All4,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">￥"
		Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_Money_All5,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">￥"
		Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_Money_All7,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">￥"
		Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_Money_All8,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">￥"
		Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">￥"
		Response.write Formatnumber(Rmb_Money_All9,num_dot_xs,-1)
		'Response.write "</div></td>" & vbcrlf & "    <td ><div align=""right"" style=""color:red"">￥"
		Response.write "</div></td>" & vbcrlf & "    </tr> " & vbcrlf & "      </table>" & vbcrlf & "   </td>" & vbcrlf & "    </tr>" & vbcrlf & "   <tr>" & vbcrlf & "    <td  class=""page"">" & vbcrlf & "       <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "  <tr>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "        <td>&nbsp;</td>" & vbcrlf & "       </form>" & vbcrlf & "   <td width=""79%""><div align=""right"">" & vbcrlf & "     <span class=""black"">"
		Response.write recordcount
		Response.write "个 | "
		Response.write currpage
		Response.write "/"
		Response.write pagecount
		Response.write "页 | &nbsp;"
		Response.write page_count
		Response.write "条信息/页</span>&nbsp;&nbsp;" & vbcrlf & "  <input name=""currpage"" id=""currpage"" type=""text"" onkeyup=""value=value.replace(/[^\d]/g,'')"" size=""3"" maxlength=""8"">" & vbcrlf & "          <input type=""button"" name=""Submit422"" value=""跳转"" onClick=""gotourl('currPage='+document.getElementById('currpage').value);"" class=""anybutton2""/>" & vbcrlf & "    "
		if currpage=1 then
			Response.write "" & vbcrlf & "    <input type=""button"" name=""Submit4"" value=""首页"" class=""page""/> <input type=""button"" name=""Submit42"" value=""上一页""  class=""page""/>" & vbcrlf & "    "
		else
			Response.write "" & vbcrlf & "    <input type=""button"" name=""Submit4"" value=""首页"" class=""page"" onClick=""gotourl('currPage=1')""/> <input type=""button"" name=""Submit42"" value=""上一页""  onClick=""gotourl('currPage="
			Response.write  currpage -1
			Response.write "')"" class=""page""/>" & vbcrlf & "    "
		end if
		if currpage=pagecount then
			Response.write "" & vbcrlf & "    <input type=""button"" name=""Submit43"" value=""下一页""  class=""page""/> <input type=""button"" name=""Submit44"" value=""尾页""  class=""page""/>" & vbcrlf & "    "
		else
			Response.write "" & vbcrlf & "   <input type=""button"" name=""Submit43"" value=""下一页""  onClick=""gotourl('currPage="
			Response.write  currpage + 1
			Response.write "')"" class=""page""/> <input type=""button"" name=""Submit43"" value=""尾页""  onClick=""gotourl('currPage="
			Response.write  pagecount
			Response.write "')"" class=""page""/>" & vbcrlf & "    "
		end if
		Response.write "" & vbcrlf & "    </div></td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "        <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "  <tr>" & vbcrlf & "    <td width=""8%"" height=""30"">&nbsp;</td>" & vbcrlf & "    <td width=""19%"" >&nbsp;</td>" & vbcrlf & "      <td width=""6%"">" & vbcrlf & "  </tr>" & vbcrlf & "</table>                  " & vbcrlf & ""
	end if
	rs.close
	set rs=nothing
	action1="收款开票汇总表"
	call close_list(1)
	Response.write "   " & vbcrlf & "    </td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "</div>" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "function Myopen_px(divID){" & vbcrlf & ""
	if A2<>"0" then
		Response.write "" & vbcrlf & "     if(divID.style.display==""""){" & vbcrlf & "              divID.style.display=""none""" & vbcrlf & "        }else{" & vbcrlf & "          divID.style.display=""""" & vbcrlf & "    }" & vbcrlf & "       divID.style.left=300;" & vbcrlf & "   divID.style.top=20;" & vbcrlf & ""
	else
		Response.write "" & vbcrlf & "     if(divID.style.display==""""){" & vbcrlf & "              divID.style.display=""none""" & vbcrlf & "        }else{" & vbcrlf & "          divID.style.display=""""" & vbcrlf & "    }" & vbcrlf & "       divID.style.left=310;" & vbcrlf & "   divID.style.top=-65;" & vbcrlf & ""
	end if
	Response.write "" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "<div id=""User"" style=""position:absolute;width:150; height:400;display:none;"">" & vbcrlf & "<table width=""150"" height="""
	if A2&""<>"0" then Response.write("150") else Response.write("200")
	Response.write """  border=""0"" cellpadding=""2"" cellspacing=""2"">" & vbcrlf & "  <tr>" & vbcrlf & "    <td height=""50"">" & vbcrlf & "        <table width=""150"" height=""50"" bgcolor=""#ecf5ff"" border=""0"" >" & vbcrlf & "          <tr valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=1')""><font color=""#2F496E"">按"
	Response.write khname
	Response.write "排序(降)</font></a></td>" & vbcrlf & "          </tr>" & vbcrlf & "                 <tr  valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=2')""><font color=""#2F496E"">按"
	Response.write khname
	Response.write "排序(升)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "                <tr  valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=3')""><font color=""#2F496E"">按期初应收排序(降)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf &" <tr  valign=""middle""> "& vbcrlf &"             <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=4')""><font color=""#2F496E"">按期初应收排序(升)</font></a> </td> "& vbcrlf &"           </tr> "& vbcrlf &"            <tr  valign=""middle""> "& vbcrlf &"             <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=5')""><font color=""#2F496E"">按本期应收排序(降)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "                <tr  valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=6')""><font color=""#2F496E"">按本期应收排序(升)</font></a> </td> "& vbcrlf &"           </tr> "& vbcrlf &"             <tr  valign=""middle""> "& vbcrlf &"             <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl</tr>""" & vbcrlf & "                  <tr  valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=8')""><font color=""#2F496E"">按本期实收排序(升)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "                <tr  valign=""middle"">" & vbcrlf & "  <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=9')""><font color=""#2F496E"">按期末应收排序(降)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "             <tr  valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=10')""><font color=""#2F496E"">按期末应收排序(升)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "           <tr  valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=11')""><font color=""#2F496E"">按期初应开票排序(降)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "            <tr  valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=12')""><font color=""#2F496E"">按期初应开票排序(升)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "              <tr valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=13')""><font color=""#2F496E"">按本期应开票排序(降)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "              <tr valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourlr=""""#2F496E"">按本期实开票排序(降)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "                 <tr valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=16')""><font color=""#2F496E"">按本期实开票排序(升)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "          <tr valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=17')""><font color=""#2F496E"">按期末应开票排序(降)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "                  <tr valign=""middle"">" & vbcrlf & "       <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=18')""><font color=""#2F496E"">按期末应开票排序(升)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "          <tr valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=19')""><font color=""#2F496E"">销售人员排序(降)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "               <tr valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;<a href=""###"" onclick=""gotourl('px=20')""><font color=""#2F496E"">销售人员排序(升)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "        </table>" & vbcrlf & "    </td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "</div>" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	
%>
