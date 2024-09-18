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
	
	sBASE_64_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	sBASE_64_CHARACTERS = strUnicode2Ansi(sBASE_64_CHARACTERS)
	Function strUnicode2Ansi(asContents)
		on error resume next
		strUnicode2Ansi=""
		len1=len(asContents)
		for i=1 to len1
			varchar=mid(asContents,i,1)
			varasc=asc(varchar)
			if varasc<0 then varasc=varasc+65536
			varasc=asc(varchar)
			if varasc>255 then
				varHex=Hex(varasc)
				varlow=left(varHex,2)
				varhigh=right(varHex,2)
				strUnicode2Ansi=strUnicode2Ansi & chrb("&H" & varlow ) & chrb("&H" & varhigh )
			else
				strUnicode2Ansi=strUnicode2Ansi & chrb(varasc)
			end if
		next
	end function
	Function strAnsi2Unicode(asContents)
		on error resume next
		strAnsi2Unicode = ""
		len1=lenb(asContents)
		if len1=0 then exit function
		for i=1 to len1
			varchar=midb(asContents,i,1)
			varasc=ascb(varchar)
			if varasc > 127 then
				strAnsi2Unicode = strAnsi2Unicode & chr(ascw(midb(asContents,i+1,1) & varchar))
'if varasc > 127 then
				i=i+1
'if varasc > 127 then
			else
				strAnsi2Unicode = strAnsi2Unicode & chr(varasc)
			end if
		next
	end function
	Function Base64encode(asContents)
		Dim lnPosition
		Dim lsResult
		Dim Char1
		Dim Char2
		Dim Char3
		Dim Char4
		Dim Byte1
		Dim Byte2
		Dim Byte3
		Dim SaveBits1
		Dim SaveBits2
		Dim lsGroupBinary
		Dim lsGroup64
		Dim m4,len1,len2
		len1=Lenb(asContents)
		if len1<1 then
			Base64encode=""
			exit Function
		end if
		m3=Len1 Mod 3
		If M3 > 0 Then asContents = asContents & String(3-M3, chrb(0))
		m3=Len1 Mod 3
		IF m3 > 0 THEN
			len1=len1+(3-m3)
'IF m3 > 0 THEN
			len2=len1-3
'IF m3 > 0 THEN
		else
			len2=len1
		end if
		lsResult = ""
		For lnPosition = 1 To len2 Step 3
			lsGroup64 = ""
			lsGroupBinary = Midb(asContents, lnPosition, 3)
			Byte1 = Ascb(Midb(lsGroupBinary, 1, 1)): SaveBits1 = Byte1 And 3
			Byte2 = Ascb(Midb(lsGroupBinary, 2, 1)): SaveBits2 = Byte2 And 15
			Byte3 = Ascb(Midb(lsGroupBinary, 3, 1))
			Char1 = Midb(sBASE_64_CHARACTERS, ((Byte1 And 252) \ 4) + 1, 1)
			Byte3 = Ascb(Midb(lsGroupBinary, 3, 1))
			Char2 = Midb(sBASE_64_CHARACTERS, (((Byte2 And 240) \ 16) Or (SaveBits1 * 16) And &HFF) + 1, 1)
			Byte3 = Ascb(Midb(lsGroupBinary, 3, 1))
			Char3 = Midb(sBASE_64_CHARACTERS, (((Byte3 And 192) \ 64) Or (SaveBits2 * 4) And &HFF) + 1, 1)
			Byte3 = Ascb(Midb(lsGroupBinary, 3, 1))
			Char4 = Midb(sBASE_64_CHARACTERS, (Byte3 And 63) + 1, 1)
			Byte3 = Ascb(Midb(lsGroupBinary, 3, 1))
			lsGroup64 = Char1 & Char2 & Char3 & Char4
			lsResult = lsResult & lsGroup64
		next
		if M3 > 0 then
			lsGroup64 = ""
			lsGroupBinary = Midb(asContents, len2+1, 3)
			lsGroup64 = ""
			Byte1 = Ascb(Midb(lsGroupBinary, 1, 1)): SaveBits1 = Byte1 And 3
			Byte2 = Ascb(Midb(lsGroupBinary, 2, 1)): SaveBits2 = Byte2 And 15
			Byte3 = Ascb(Midb(lsGroupBinary, 3, 1))
			Char1 = Midb(sBASE_64_CHARACTERS, ((Byte1 And 252) \ 4) + 1, 1)
			Byte3 = Ascb(Midb(lsGroupBinary, 3, 1))
			Char2 = Midb(sBASE_64_CHARACTERS, (((Byte2 And 240) \ 16) Or (SaveBits1 * 16) And &HFF) + 1, 1)
			Byte3 = Ascb(Midb(lsGroupBinary, 3, 1))
			Char3 = Midb(sBASE_64_CHARACTERS, (((Byte3 And 192) \ 64) Or (SaveBits2 * 4) And &HFF) + 1, 1)
			Byte3 = Ascb(Midb(lsGroupBinary, 3, 1))
			if M3=1 then
				lsGroup64 = Char1 & Char2 & ChrB(61) & ChrB(61)
			else
				lsGroup64 = Char1 & Char2 & Char3 & ChrB(61)
			end if
			lsResult = lsResult & lsGroup64
		end if
		Base64encode = lsResult
	end function
	Function Base64decode(asContents)
		Dim lsResult
		Dim lnPosition
		Dim lsGroup64, lsGroupBinary
		Dim Char1, Char2, Char3, Char4
		Dim Byte1, Byte2, Byte3
		Dim M4,len1,len2
		len1= Lenb(asContents)
		M4 = len1 Mod 4
		if len1 < 1 or M4 > 0 then
			Base64decode = ""
			exit Function
		end if
		if midb(asContents, len1, 1) = chrb(61) then m4=3
		if midb(asContents, len1-1, 1) = chrb(61) then m4=2
'if midb(asContents, len1, 1) = chrb(61) then m4=3
		if m4 = 0 then
			len2=len1
		else
			len2=len1-4
			len2=len1
		end if
		For lnPosition = 1 To Len2 Step 4
			lsGroupBinary = ""
			lsGroup64 = Midb(asContents, lnPosition, 4)
			Char1 = InStrb(sBASE_64_CHARACTERS, Midb(lsGroup64, 1, 1)) - 1
			lsGroup64 = Midb(asContents, lnPosition, 4)
			Char2 = InStrb(sBASE_64_CHARACTERS, Midb(lsGroup64, 2, 1)) - 1
			lsGroup64 = Midb(asContents, lnPosition, 4)
			Char3 = InStrb(sBASE_64_CHARACTERS, Midb(lsGroup64, 3, 1)) - 1
			lsGroup64 = Midb(asContents, lnPosition, 4)
			Char4 = InStrb(sBASE_64_CHARACTERS, Midb(lsGroup64, 4, 1)) - 1
			lsGroup64 = Midb(asContents, lnPosition, 4)
			Byte1 = Chrb(((Char2 And 48) \ 16) Or (Char1 * 4) And &HFF)
			Byte2 = lsGroupBinary & Chrb(((Char3 And 60) \ 4) Or (Char2 * 16) And &HFF)
			Byte3 = Chrb((((Char3 And 3) * 64) And &HFF) Or (Char4 And 63))
			lsGroupBinary = Byte1 & Byte2 & Byte3
			lsResult = lsResult & lsGroupBinary
		next
		if M4 > 0 then
			lsGroupBinary = ""
			lsGroup64 = Midb(asContents, len2+1, m4) & chrB(65)
'lsGroupBinary = ""
			if M4=2 then
				lsGroup64 = lsGroup64 & chrB(65)
			end if
			Char1 = InStrb(sBASE_64_CHARACTERS, Midb(lsGroup64, 1, 1)) - 1
'lsGroup64 = lsGroup64 & chrB(65)
			Char2 = InStrb(sBASE_64_CHARACTERS, Midb(lsGroup64, 2, 1)) - 1
'lsGroup64 = lsGroup64 & chrB(65)
			Char3 = InStrb(sBASE_64_CHARACTERS, Midb(lsGroup64, 3, 1)) - 1
'lsGroup64 = lsGroup64 & chrB(65)
			Char4 = InStrb(sBASE_64_CHARACTERS, Midb(lsGroup64, 4, 1)) - 1
'lsGroup64 = lsGroup64 & chrB(65)
			Byte1 = Chrb(((Char2 And 48) \ 16) Or (Char1 * 4) And &HFF)
			Byte2 = lsGroupBinary & Chrb(((Char3 And 60) \ 4) Or (Char2 * 16) And &HFF)
			Byte3 = Chrb((((Char3 And 3) * 64) And &HFF) Or (Char4 And 63))
			if M4=2 then
				lsGroupBinary = Byte1
			elseif M4=3 then
				lsGroupBinary = Byte1 & Byte2
			end if
			lsResult = lsResult & lsGroupBinary
		end if
		Base64decode = lsResult
	end function
	Function AspUrlDecode(strValue)
		Dim varAry, varElement, objStream, lngLoop, Flag
		strValue = Replace(strValue, "+", " ")
'Dim varAry, varElement, objStream, lngLoop, Flag
		varAry = Split(strValue, "%")
		Flag = varAry(0) = ""
		Set objStream = frk3_
		With objStream
		.Type = 2
		.Mode = 3
		.Open
		For Each varElement In varAry
			If varElement <> Empty Then
				If Len(varElement) >= 2 And Flag Then
					.WriteText ChrB(CInt("&H" & Left(varElement, 2)))
					For lngLoop = 3 To Len(varElement)
						.WriteText ChrB(Asc(Mid(varElement, lngLoop, 1)))
					next
				else
					For lngLoop = 1 To Len(varElement)
						.WriteText ChrB(Asc(Mid(varElement, lngLoop, 1)))
					next
					Flag = True
				end if
			end if
		next
		.WriteText Chr(0)
		.Position = 0
		AspUrlDecode = Replace(ConvUnicode(.ReadText), Chr(0), "", 1, -1, 0)
		.Position = 0
		on error resume next
		.Close
		Set objStream = Nothing
		End With
	end function
	Function ConvUnicode(ByVal strData)
		Dim rs, stm, bytAry, intLen
		If Len(strData & "") > 0 Then
			strData = MidB(strData, 1)
			intLen = LenB(strData)
			Set rs = server.CreateObject("adodb.recordset")
			Set stm = frk3_
			With rs
			.Fields.Append "X", 205, intLen
			.Open
			.AddNew
			rs(0).AppendChunk strData & ChrB(0)
			.Update
			bytAry = rs(0).GetChunk(intLen)
			End With
			With stm
			.Type = 1
			.Open
			.Write bytAry
			.Position = 0
			.Type = 2
			.Charset = "utf-8"
'.Type = 2
			ConvUnicode = .ReadText
			End With
		end if
		on error resume next
		stm.Close
		Set stm = Nothing
		rs.close
		set rs = nothing
	end function
	Function UTF8URLDecode(ByVal strIn)
		on error resume next
		UTF8URLDecode = ""
		Dim sl: sl = 1
		Dim tl: tl = 1
		Dim key: key = "%"
		Dim kl: kl = Len(key)
		Dim hh, hi, hl
		Dim a
		sl = InStr(sl, strIn, key, 1)
		Do While sl>0
			If (tl=1 And sl<>1) or tl<sl Then UTF8URLDecode = UTF8URLDecode & Mid(strIn, tl, sl-tl)
'Do While sl>0
			Select Case UCase(Mid(strIn, sl+kl, 1))
'Do While sl>0
			Case "U":
			a = Mid(strIn, sl+kl+1, 4)
'Case "U":'
			UTF8URLDecode = UTF8URLDecode & ChrW("&H" & a)
			sl = sl + 6
			UTF8URLDecode = UTF8URLDecode & ChrW("&H" & a)
			Case "E":
			hh = Mid(strIn, sl+kl, 2)
'Case "E":'
			a = Int("&H" & hh)
			If Abs(a)<128 Then
				sl = sl + 3
'If Abs(a)<128 Then
				UTF8URLDecode = UTF8URLDecode & Chr(a)
			else
				hi = Mid(strIn, sl+3+kl, 2)
				UTF8URLDecode = UTF8URLDecode & Chr(a)
				hl = Mid(strIn, sl+6+kl, 2)
				UTF8URLDecode = UTF8URLDecode & Chr(a)
				a = ("&H" & hh And &H0F) * 2 ^12 or ("&H" & hi And &H3F) * 2 ^ 6 or ("&H" & hl And &H3F)
				If a<0 Then a = a + 65536
				a = ("&H" & hh And &H0F) * 2 ^12 or ("&H" & hi And &H3F) * 2 ^ 6 or ("&H" & hl And &H3F)
				UTF8URLDecode = UTF8URLDecode & ChrW(a)
				sl = sl + 9
				UTF8URLDecode = UTF8URLDecode & ChrW(a)
			end if
			Case Else:
			hh = Mid(strIn, sl+kl, 2)
'Case Else:'
			a = Int("&H" & hh)
			If Abs(a)<128 Then
				sl = sl + 3
'If Abs(a)<128 Then
			else
				hi = Mid(strIn, sl+3+kl, 2)
'If Abs(a)<128 Then
				a = Int("&H" & hh & hi)
				sl = sl + 6
'a = Int("&H" & hh & hi)'
			end if
			UTF8URLDecode = UTF8URLDecode & Chr(a)
			End Select
			tl = sl
			sl = InStr(sl, strIn, key, 1)
		Loop
		UTF8URLDecode = UTF8URLDecode & Mid(strIn, tl)
	end function
	
	Class MimeFileItemClass
		Public fileName
		Public fileBody
		Public ContentID
		Public ExtName
		Public savePath
		Public savevirPath
		Public saveName
		Public Size
	End class
	Class EmailMessageClass
		Dim mText, mhtml,  minnerFiles, mAttachments, msize, b64, mfromEmail, mSubject, mfromName, mSendTime, fso
		Dim minnerFilesCount, mAttachmentsCount
		Public Property Get fromEmail
		fromEmail = mfromEmail
		End Property
		Public Property Get fromName
		fromName = mfromName
		End Property
		Public Property Get SendTime
		SendTime = mSendTime
		End Property
		Public Property Get Subject
		Subject = mSubject
		End Property
		Public Property Get Text
		Text = mText
		End Property
		Public Property Get html
		If Len(mHtml)>0 Then
			Html = mHtml
		else
			Html = mText
		end if
		End Property
		Public Property Get InnerFilesCount
		InnerFilesCount = mInnerFilesCount
		End Property
		Public Property Get AttachmentsCount
		AttachmentsCount = mAttachmentsCount
		End Property
		Public Property Get innerFiles(ByVal index)
		Set innerFiles = minnerFiles(index)
		End Property
		Public Property Get Attachments(ByVal index)
		Set Attachments = mAttachments(index)
		End Property
		Public Property Get Size
		Size = mSize
		End Property
		Function GetSpliterChar(ByRef Emailbody)
			Dim i1, i, result
			result = vbcrlf & "--"
'Dim i1, i, result
			i1 = InStr(Emailbody, result)
			If i1=0 Then
				GetSpliterChar =  result
			else
				For i = i1+4 To Len(Emailbody)
					GetSpliterChar =  result
					If Mid(Emailbody, i, 1) = "-" Then
						GetSpliterChar =  result
						result = result & "-"
						GetSpliterChar =  result
					else
						Exit for
					end if
				next
				GetSpliterChar = result
			end if
		end function
		Function boolReg(s,p)
			s = Replace(Replace(s,Chr(10),""),Chr(13),"")
			If isEmpty(regExObj) Then
				Set regExObj = New RegExp
			end if
			regExObj.Pattern = p
			regExObj.IgnoreCase = false
			regExObj.Global = True
			boolReg=regExObj.Test(s)
		end function
		Function Load(ByRef EmailBody)
			Dim i, ii, datas, iText, signItem, count, isUtf8, splitkey
			mAttachmentsCount = 0
			mInnerFilesCount = 0
			mText = ""
			mHtml = ""
			ReDim minnerFiles(0)
			ReDim mAttachments(0)
			Dim res : ReDim res(0)
			count = 0
			msize = Len(EmailBody)
			splitkey = GetSpliterChar(EmailBody)
			datas = Split(EmailBody, splitkey)
			If ubound(datas) = 0 And InStr(EmailBody,"Content-Transfer-Encoding")=0 Then
				datas = Split(EmailBody, splitkey)
				If InStr(1, EmailBody, "=3D") > 0 Then
					mHtml = Qu_DeCodeByHtml(EmailBody,1)
				Elseif boolReg(EmailBody,"([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$") then
					mHtml = Qu_DeCodeByHtml(EmailBody,1)
					mHtml = b64.DeCodeByUtf8(EmailBody)
				else
					mHtml = b64.DataStrConv(b64.XmlDecodeBase64(EmailBody), 64)
				end if
			else
				For i = 0 To ubound(datas)
					iText =  datas(i)
					signItem = InStr(1, iText, "Content-Type: multipart", 1) > 0  or InStr(1, iText, "Content-Type:", 1) = 0
					iText =  datas(i)
					If signItem = False Then
						ii = instr(iText, vbcrlf & vbcrlf)
						If ii>0 Then
							Dim k1 : k1 = "Content-Transfer-Encoding: base64"
'If ii>0 Then
							Dim k2 : k2 = "Content-Transfer-Encoding: quoted-printable"
'If ii>0 Then
							Dim k3 : k3 = "Content-Disposition: attachment"
'If ii>0 Then
							Dim headTxt :  headTxt = Left(iText, ii)
							Dim bodyTxt :  bodyTxt = mid(iText, ii)
							Dim iii : iii = InStr(1, headTxt, "Content-Type:", 1)
'Dim bodyTxt :  bodyTxt = mid(iText, ii)
							Dim isBase64 : isBase64 = InStr(1, headTxt, k1, 1) > 0 Or InStr(1, headTxt, Replace(k1," ",""), 1) > 0
							Dim isQucode : isQucode = InStr(1, headTxt, k2, 1) > 0 Or InStr(1, headTxt, Replace(k2," ",""), 1) > 0
							Dim isAttachment : isAttachment = InStr(1, headTxt, k3, 1) > 0 Or InStr(1, headTxt, Replace(k3," ",""), 1) > 0
							Dim isInnerFiles : isInnerFiles = Not isAttachment And InStr(iii, headTxt, "Content-ID:", 1) > 0
							If isAttachment =  False And isInnerFiles = False Then
								If isBase64 And InStr(1, headTxt, "Content-Type: text/plain", 1) = 0 And InStr(1, headTxt, "Content-Type: text/html", 1) = 0 Then
'If isAttachment =  False And isInnerFiles = False Then
									isAttachment = InStr(iText, "name=""") > 0
								end if
							end if
							on error resume next
							If Not isAttachment  And Not isInnerFiles Then
								isUtf8 = InStr(iii, headtxt, "charset=utf-8", 1) > 0 Or InStr(iii, headtxt, "charset=""utf-8""", 1) > 0
'If Not isAttachment  And Not isInnerFiles Then
								If isbase64 Then bodyTxt = Replace(bodyTxt, vbcrlf, "",1,4,1)
								If  InStr(1, headTxt, "Content-Type: text/plain", 1) > 0 Then
'If isbase64 Then bodyTxt = Replace(bodyTxt, vbcrlf, "",1,4,1)
									If isUtf8 Then
										If isBase64 Then
											If Len(bodyTxt)>3 Then mText =  b64.DeCodeByUtf8(bodyTxt)
										elseif isQucode Then
											mText = Qu_DeCodeByHtml(bodyTxt,1)
										else
											mText = bodyTxt
										end if
									else
										If isBase64 Then
											If Len(bodyTxt)>3 Then mText =  b64.DataStrConv(b64.XmlDecodeBase64(bodyTxt), 64)
										elseif isQucode Then
											mText =  Qu_DeCodeByHtml(bodyTxt,0)
										else
											mText = bodyTxt
										end if
									end if
								Else
									If isUtf8 Then
										If isBase64 Then
											If Len(bodyTxt)>3 Then mHtml = b64.DeCodeByUtf8(bodyTxt)
										elseif isQucode Then
											mHtml =  Qu_DeCodeByHtml(bodyTxt,1)
										else
											mHtml = bodyTxt
										end if
									else
										If isBase64 Then
											If Len(bodyTxt)>3 Then  mHtml = b64.DataStrConv(b64.XmlDecodeBase64(bodyTxt), 64)
										elseif isQucode Then
											mHtml =  Qu_DeCodeByHtml(bodyTxt,0)
										else
											mHtml = bodyTxt
										end if
									end if
								end if
							else
								Dim fnms
								Set ifile = New MimeFileItemClass
								ifile.fileBody = bodyTxt
								ifile.fileName = GetFileNameFromHeader(headTxt)
								fnms = Split(ifile.fileName,".")
								If ubound(fnms) > 0 Then ifile.ExtName =  fnms(ubound(fnms))
								If isInnerFiles Then
									ifile.contentId = GetContentIDFromHeader(headTxt)
									ReDim Preserve minnerFiles(minnerFilesCount)
									Set minnerFiles(minnerFilesCount) = ifile
									minnerFilesCount = minnerFilesCount + 1
'Set minnerFiles(minnerFilesCount) = ifile
								Else
									ReDim Preserve mAttachments(mAttachmentsCount)
									Set mAttachments(mAttachmentsCount) = ifile
									mAttachmentsCount = mAttachmentsCount + 1
'Set mAttachments(mAttachmentsCount) = ifile
								end if
							end if
							On Error GoTo 0
							count = count + 1
'On Error GoTo 0
						else
							headTxt = iText
						end if
					else
						headTxt = iText
					end if
					Call checkEmailMsg(headTxt)
				next
			end if
			ParseMimeText = res
		end function
		Private Sub checkEmailMsg(ByRef  headtxt)
			Dim i, ii, itxt, iss
			If Len(mfromEmail) = 0 and Len(mSubject) = 0 Then
				If InStr(headtxt, vbcrlf & "Subject:") > 0 Then
					Dim items : items = Split(headtxt, vbcrlf)
					For i = 0 To ubound(items)
						itxt = items(i)
						Dim txtv
						txtv = GetEmailHeaderItem(items, "Subject", i)
						If Len(txtv) > 0 Then mSubject = txtv
						If Len(txtv) = 0 Then
							txtv = GetEmailHeaderItem(items, "from", i)
							If Len(txtv) > 0 Then
								If InStr(txtv,"<") > 0 Then
									iss = Split(txtv, "<")
									mfromEmail = Replace(iss(1), ">", "")
									mfromName = iss(0)
								else
									If InStr(txtv, "@") > 0 then
										mfromEmail = txtv
									else
										mfromName = txtv
									end if
								end if
							end if
						end if
						If Len(txtv) = 0 Then
							txtv = GetEmailHeaderItem(items, "Date", i)
							If Len(txtv) > 0 Then
								If InStr(txtv,",") > 0 Then txtv = Split(txtv,",")(1)
								iss = Split(Trim(txtv), " ")
								mSendTime = iss(2) & "-" & cDateMonth(iss(1)) & "-" & iss(0) & " " & iss(3)
'iss = Split(Trim(txtv), " ")
							end if
						end if
					next
				end if
			end if
		end sub
		Private Function cDateMonth(ByVal v)
			Dim ss , i
			ss = Split("jan,feb,mar,apr,may,jun,ju1,aug,sep,oct,nov,dec",",")
			v = LCase(v)
			For i = 0 To ubound(ss)
				If v = ss(i) Then
					cDateMonth = i+1
'If v = ss(i) Then
					Exit function
				end if
			next
			If v = "sept" Then
				cDateMonth = 8
			else
				cDateMonth = 1
			end if
		end function
		Function GetEmailHeaderItem(items, headerName, i)
			Dim ii
			itxt = items(i)
			If InStr(1, itxt, headerName & ":", 1) = 1 Then
				itxt = Replace(itxt, headerName & ":", "", 1,1,1)
				If InStr(itxt, "=?") > 0 Then
					GetEmailHeaderItem =  GetEncodeItem(itxt)
				else
					GetEmailHeaderItem = itxt
				end if
				For ii = i + 1 To ubound(items)
					GetEmailHeaderItem = itxt
					itxt = items(ii)
					If InStr(itxt,":")>0 Then Exit for
					If InStr(itxt, "=?") > 0 Then
						GetEmailHeaderItem = GetEmailHeaderItem & GetEncodeItem(itxt)
					else
						GetEmailHeaderItem = GetEmailHeaderItem & itxt
					end if
				next
			end if
		end function
		Private Function Qu_DeCodeByHtml(ByVal html, ByVal isUtf8)
			html = Replace(html, "=" & vbcrlf, "")
			html = Replace(html, "=3D""", Chr(1) & Chr(3))
			html = Replace(html, "=3D'", Chr(1) & Chr(2))
			Dim i1, i2
			i1 = InStr(1, html, "=")
			i2 = getQuCodeI2(html, i1)
			while i2 > i1 And i1>0
				qutext =  Mid(html, i1, i2-i1+1)
'while i2 > i1 And i1>0
				If qutext <> "=3D" then
					If isUtf8 Then
						on error resume next
						qutext = b64.UrlDecodeByUtf8(Replace(qutext,"=","%"))
						If Err.number <> 0 Then qutext = " "
						On Error GoTo 0
					else
						qutext = b64.URLDecode(Replace(qutext,"=","%"))
					end if
					html = Left(html, i1-1) & qutext & Mid(html, i2+1)
					qutext = b64.URLDecode(Replace(qutext,"=","%"))
				else
					i1=i1+3
					qutext = b64.URLDecode(Replace(qutext,"=","%"))
				end if
				i1 = InStr(i1, html, "=")
				i2 = getQuCodeI2(html, i1)
				While i1>i2 And i1>0
					i1 = InStr(i1+1, html, "=")
'While i1>i2 And i1>0
					i2 = getQuCodeI2(html, i1)
				wend
			wend
			html = Replace(html,  Chr(1) & Chr(3), "=""")
			html = Replace(html,  Chr(1) & Chr(2), "='")
			Qu_DeCodeByHtml = html
		end function
		Function getQuCodeI2(ByRef html, ByVal i1)
			Dim i , ac, l
			l = Len(html)
			For i = i1 To l Step 3
				If i > l or i<1 Then getQuCodeI2 = i-1 : Exit Function
'For i = i1 To l Step 3
				If Mid(html, i, 1) <> "=" Then getQuCodeI2 = i-1 : Exit Function
'For i = i1 To l Step 3
				If i+1>= l Then getQuCodeI2 = i-1 : Exit Function
'For i = i1 To l Step 3
'If i+1>= l Then getQuCodeI2 = i-1 : Exit Function
'For i = i1 To l Step 3
				If i+2>= l Then getQuCodeI2 = i-1 : Exit Function
'For i = i1 To l Step 3
				ac = Asc((Mid(html, i+1, 1)))
'For i = i1 To l Step 3
				If  ((ac >=48 And ac<=57) Or (ac >=65 And ac<=70)) = False Then  getQuCodeI2 = i-1 : Exit Function
'For i = i1 To l Step 3
				ac = Asc((Mid(html, i+2, 1)))
'For i = i1 To l Step 3
				If  ((ac >=48 And ac<=57) Or (ac >=65 And ac<=70)) = False Then  getQuCodeI2 = i-1 :Exit Function
'For i = i1 To l Step 3
			next
			getQuCodeI2 = l
		end function
		Private Function GetEncodeItem(ByVal txt)
			Dim nms, nmt
			nms = Split(txt, "?")
			If ubound(nms)>3 Then
				nmt = nms(4)
				If Left(nmt,1) = "=" Then nmt = mid(nmt,2)
				If Left(nmt,1) = """" Then nmt = mid(nmt,2)
			end if
			If ubound(nms)>7 Then
				If boolReg(nms(7),"^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$") Then nmt = b64.DataStrConv(b64.XmlDecodeBase64(nms(7)), 64)
'If ubound(nms)>7 Then
			end if
			If InStr(1,nms(1),"utf",1)>0 Then
				If UCase(nms(2)) = "Q" Then
					GetEncodeItem = b64.UrlDecodeByUtf8(Replace(nms(3),"=","%")) & nmt
				else
					GetEncodeItem = b64.DeCodeByUtf8(nms(3)) & nmt
				end if
			else
				If UCase(nms(2)) = "Q" Then
					GetEncodeItem = b64.UrlDecode(Replace(nms(3),"=","%")) & nmt
				else
					GetEncodeItem = b64.DataStrConv(b64.XmlDecodeBase64(nms(3)), 64) & nmt
				end if
			end if
		end function
		Public Function GetFileNameFromHeader(byref headTxt)
			Dim i, i1, i2, fname, nms
			i = InStr(1, headTxt, "Content-Type:", 1)
'Dim i, i1, i2, fname, nms
			i1 =  InStr(i, headTxt, "name=""", 1)
			If i1 = 0 Then Exit Function
			i1 = i1 + 6
'If i1 = 0 Then Exit Function
			i2 = InStr(i1, headTxt, """")
			If i2 = 0 Then Exit Function
			fname = Mid(headTxt, i1, i2-i1)
'If i2 = 0 Then Exit Function
			If InStr(fname, "=?") =  1 Then
				Dim ws1 :  ws1 = Split(fname,"?")
				If ubound(ws1) > 5 Then
					Dim ws2 :  ws2 = ws1(0) & "?" & ws1(1) & "?" & ws1(2)  & "?"
					For i = 0 To 10
						fname = Replace(fname, "?=" & vbcrlf & Left("          ", i) & ws2, "")
					next
				end if
				GetFileNameFromHeader = GetEncodeItem(fname)
			else
				GetFileNameFromHeader = fname
			end if
		end function
		Public Function GetContentIDFromHeader(byref headTxt)
			Dim i1, i2, fname, nms
			i1 = InStr(1, headTxt, "Content-ID: <", 1)
'Dim i1, i2, fname, nms
			If i1 = 0 Then Exit Function
			i1 = i1 + 13
'If i1 = 0 Then Exit Function
			i2 =  InStr(i1, headTxt, ">", 1)
			GetContentIDFromHeader = Mid(headTxt, i1, i2-i1)
'i2 =  InStr(i1, headTxt, ">", 1)
		end function
		Public Sub Save(ByVal filePath, ByVal BodyVirPath)
			Dim i, f, rnd, NName
			Randomize
			fso.CreateFolder filePath
			For i = 0 To Me.innerFilescount - 1
				fso.CreateFolder filePath
				Set fitem = minnerFiles(i)
				NName = "E" &  GetRndName(fitem.extName)
				fitem.saveName = NName
				fitem.savePath = Replace(filePath & "\" & NName,"\\","\")
				fitem.savevirPath = Replace(BodyVirPath & "/" & NName,"\","/")
				SaveBinraryFile fitem.savePath, b64.XmlDecodeBase64(fitem.fileBody)
				fitem.Size = fso.GetFileLen(fitem.savePath)
				mhtml = Replace(mhtml, "cid:" & fitem.ContentId, fitem.savevirPath)
			next
			For i = 0 To mAttachmentsCount - 1
				mhtml = Replace(mhtml, "cid:" & fitem.ContentId, fitem.savevirPath)
				Set fitem = mAttachments(i)
				NName = "E" &  GetRndName(fitem.extName)
				fitem.saveName = NName
				fitem.savePath = Replace(filePath & "\" & NName,"\\","\")
				fitem.savevirPath = Replace(BodyVirPath & "/" & NName,"\","/")
				SaveBinraryFile fitem.savePath, b64.XmlDecodeBase64(fitem.fileBody)
				fitem.Size = fso.GetFileLen(fitem.savePath)
			next
		end sub
		Private Sub SaveBinraryFile(ByRef fpath, ByRef data)
			Dim stm
			Set stm=frk3_
			stm.Type = 1
			stm.Open
			stm.write data
			stm.SaveToFile fpath
			Set stm = Nothing
		end sub
		Private Function GetRndName(extname)
			Dim s , r
			s = Split( Replace(Replace(Replace(Replace(now & "","/","-"),":","-")," ","-"),"--","-"), "-")
'Dim s , r
			For i = 0 To ubound(s)
				If Len(s(i))=1 Then s(i) = "0" & s(i)
			next
			Randomize
			r = Join(s,"") & right("00000" & CStr(CLng(rnd*100000)), 5)
			If Len(extName) > 0 Then r = r & "." & extname
			GetRndName = r
		end function
		Public Function GetDateText
			Dim s , r
			s = Split( Replace(Replace(Replace(Replace(date & "","/","-"),":","-")," ","-"),"--","-"), "-")
'Dim s , r
			For i = 0 To ubound(s)
				If Len(s(i))=1 Then s(i) = "0" & s(i)
			next
			GetDateText = Join(s,"")
		end function
		Public Sub Class_Initialize()
			Set b64 = server.createobject(ZBRLibDLLNameSN & ".base64Class")
			Set fso = server.createobject(ZBRLibDLLNameSN & ".commfileClass")
		end sub
		Public Sub dispose
			Set b64 = Nothing
			Set fso = nothing
			For i = 0 To mInnerFilesCount - 1
				Set fso = nothing
				Set minnerFiles(i) = Nothing
			next
			For i = 0 To mAttachmentsCount - 1
				Set minnerFiles(i) = Nothing
				Set mAttachments(i) = Nothing
			next
			Erase minnerFiles
			Erase mAttachments
		end sub
		Private Sub Class_Terminate()
			Call dispose
		end sub
	End Class
	on error resume next
	Function ShowTemp(Style)
		Dim Fso, F, F1, Fc, S
		Set Fso = CreateObject("Scripting.FileSystemObject")
		Set F = Fso.GetFolder(Server.mappath("/templates/."))
		Set Fs = F.SubFolders
		Set Fc = F.Files
		Outstr = Outstr & "<select Name=templates Style='font-size: 9pt ;border: 1px Solid #c0c0c0 ; Height:16px ;width:" & Style & "px;'>"
'Set Fc = F.Files
		For Each F1 In Fc
			Dim FileName
			FileName = F1.Name
			Outstr = Outstr & "<option Value='" & FileName & "'>" & FileName & "</option>"
		next
		Outstr = Outstr & "</select>"
		Response.write Outstr
		Set Fso = Nothing
	end function
	Function MailTemp(templates)
		Dim Objfso
		Dim Fdata
		Dim ObjcountFile
		Set Objfso = Server.CreateObject("Scripting.FileSystemObject")
		Set ObjcountFile = Objfso.Opentextfile(Server.MapPath("/templates/" & templates), 1)
		If Not ObjcountFile.AtEndofStream Then Fdata = Objcountfile.ReadAll
		ObjcountFile.Close
		Set ObjcountFile = Nothing
		Set Objfso = Nothing
		MailTemp = Fdata
	end function
	Function SendMailNow(EmailUrl1,EmailName1,EmailPasswd1,UserEmail,userName,csEmail,msEmail, Topic,MailBody,uploadfile,FileNameOldArr,FileSizeArr,Html,Prioty,Emailord_fun,add_cateid2,add_cateid3,ord_action,sort_action)
		If Len(Html) = 0 Then Html = 0
		If IsObjInstalled(SmtpObj) Then
			Select Case LCase(Split(SmtpObj, ".")(0))
			Case "jmail"
			SendMailNow=(JMailSend(EmailUrl1,EmailName1,EmailPasswd1,UserEmail,userName,csEmail,msEmail, Topic, MailBody,uploadfile,FileNameOldArr,FileSizeArr, Html,Prioty,Emailord_fun,add_cateid2,add_cateid3,ord_action,sort_action))
			Case "cdonts"
			SendMailNow=(Cdonts(UserEmail, Topic, MailBody, Html))
			Case "persits"
			SendMailNow=(Persits(UserEmail, Topic, MailBody, Html))
			Case Else
			SendMailNow="N"
			End Select
		end if
	end function
	Dim SendMail
	Function JMailSend(EmailUrl2,EmailName2,EmailPasswd2,Email,userName,csEmail,msEmail, Topic, MailBody,uploadfile,FileNameOldArr,FileSizeArr, Html,Prioty,Emailord_Jmai,add_cateid2,add_cateid3,ord_action,sort_action)
		Set JMail = Server.CreateObject("JMail.Message")
		JMail.ISOEncodeHeaders = True
		JMail.Silent = True
		JMail.From = EmailUrl2
		JMail.FromName = EmailName2
		JMail.MailServerUserName =EmailName2
		JMail.MailServerPassword = EmailPasswd2
		EmailLog=Email
		Email=replace(Email,"]","")
		ArrEamil=split(Email,";")
		eamil_sendNum=Ubound(ArrEamil,1)
		For I = 0 to eamil_sendNum
			if instr(ArrEamil(I),"[")>0 then
				ArrEamil_list=split(ArrEamil(I),"[")
				this_email_url=ArrEamil_list(1)
				this_email_name=ArrEamil_list(0)
			else
				this_email_url=ArrEamil(I)
				this_email_name=""
			end if
			JMail.AddRecipient this_email_url,this_email_name
		next
		if msEmail<>"" then
			if instr(msEmail,";")>0 then
				ArrmsEmail=split(msEmail,";")
				eamil_msSendNum=Ubound(ArrmsEmail,1)
				eamil_sendNum=eamil_sendNum+eamil_msSendNum+1
				eamil_msSendNum=Ubound(ArrmsEmail,1)
				For f = 0 to eamil_msSendNum
					JMail.AddRecipientBCC ArrmsEmail(f)
				next
			else
				eamil_sendNum=eamil_sendNum+1
				JMail.AddRecipientBCC ArrmsEmail(f)
				JMail.AddRecipientBCC msEmail
			end if
		end if
		if csEmail<>"" Then
			if instr(csEmail,";")>0 then
				ArrcsEmail=split(csEmail,";")
				eamil_csSendNum=Ubound(ArrcsEmail,1)
				eamil_sendNum=eamil_sendNum+eamil_csSendNum+1
				eamil_csSendNum=Ubound(ArrcsEmail,1)
				For f = 0 to eamil_csSendNum
					JMail.AddRecipientCC ArrcsEmail(f)
				next
			else
				eamil_sendNum=eamil_sendNum+1
				JMail.AddRecipientCC ArrcsEmail(f)
				JMail.AddRecipientCC csEmail
			end if
		end if
		JMail.Subject = Topic        'JMail.deferreddelivery="2011-03-16 09:30:00"
		JMail.AddRecipientCC csEmail
		JMail.Body = MailBody
		if ubound(uploadfile)>=0 then
			for f=0 to ubound(uploadfile)
				JMail.AddAttachment(Server.MapPath(uploadfile(f)))
			next
		end if
		JMail.HTMLBody = MailBody
		JMail.appendText " "
		if JMail.Send( ""&Emailsmtp&"" ) then
			JMailSend="Y"
			send_errmsg=1
		else
			JMailSend="N"
			send_errmsg=0
		end if
		call sendLog(Topic,Emailord_Jmai,EmailLog,MailBody,send_errmsg,add_cateid2,add_cateid3,uploadfile,FileNameOldArr,FileSizeArr,csEmail,msEmail,eamil_sendNum+1,ord_action,sort_action)
		send_errmsg=0
		JMail.Close()
		Set JMail = Nothing
	end function
	sub RecvJMail(recvord,SmtpUser,SmtpPass,Smtppop3,Isdel,EmailUrl,maxMailSendtime,receiveNum)
		on error resume next
		Set pop3 = Server.CreateObject( "JMail.POP3" )
		pop3.Connect EmailUrl, SmtpPass, Smtppop3
		if err.number<>0 then
			err.Clear
			pop3.Connect SmtpUser, SmtpPass, Smtppop3
		end if
		if err.number<>0 then
			Response.write"<script language=javascript>alert('接收邮箱账号异常！');history.back(); </script>"
			Response.end
		end if
		EmailToall=pop3.count
		if isNull(receiveNum) then receiveNum=30
		if EmailToall > 0 then
			num=0
			K=EmailToall
			do while K>0 And (num<receiveNum Or receiveNum=0)
				Response.write"<script type=""text/javascript"">$(""#loading div"").css(""width"","""&Fix(((EmailToall-K) /(EmailToall))*400)&"px"").text("""&formatnumber((EmailToall-K) /(EmailToall)*100)&"%"")</script>"
'do while K>0 And (num<receiveNum Or receiveNum=0)
				Response.Flush
				emailid = pop3.GetMessageUID(k)
				If conn.execute("select 1 email_Id from email_recv_list where email_Id='"& emailid &"'").eof  Then
					Set msg = pop3.Messages.item(K)
					num=num+1
'Set msg = pop3.Messages.item(K)
					ReTo = ""
					ReCC = ""
					Set Recipients = msg.Recipients
					Err.clear
					needZM = False
					needZM = isUTF8(msg.Headers.GetHeader("Subject"))
					subject = msg.Subject
					strFrom = msg.From
					subject= toUTF8(msg.Headers.GetHeader("Subject"), msg.Subject)
					FromName= toUTF8(msg.Headers.GetHeader("FromName"), msg.FromName)
					Err.clear
					msg.Charset = "utf-8"
					Err.clear
					msg.ContentTransferEncoding="base64"
					msg.Encoding="base64"
					msg.ISOEncodeHeaders=False
					separator = ", "
					For i = 0 To Recipients.Count - 1
						separator = ", "
						If i = Recipients.Count - 1 Then separator = ""
						separator = ", "
						Set re = Recipients.item(i)
						If re.ReType = 0 Then
							ReTo = ReTo & re.EMail & separator
						else
							ReCC = ReCC & re.EMail & separator
						end if
					next
					Set doc = New EmailMessageClass
					doc.load msg.bodytext
						doc.save Server.mappath("../email/upload/" & doc.GetDateText), "../email/upload/" & doc.GetDateText
							recvID = recvLog_sub(strFrom,FromName,ReTo,Subject,doc.html, msg.date, doc.AttachmentsCount,ReCC,recvord,pop3.GetMessageUID(k))
							For i = 0 To doc.AttachmentsCount - 1
								Set fitem = doc.Attachments(i)
								Dim sizestr
								If fitem.Size < 1024 Then
									sizestr = fitem.Size & " 字节"
								Elseif fitem.Size < CLng(1024)*1024 Then
									sizestr = FormatNumber(fitem.Size/1024,2) & " KB"
								Elseif fitem.Size < CLng(1024)*1024*1024 Then
									sizestr = FormatNumber(fitem.Size/1024/1024,2) & " MB"
								end if
								call saveAccess(recvID, fitem.saveVirpath , sizestr, 2, fitem.fileName, "")
							next
							Set doc = nothing
							if msg.Attachments.Count=0 or datediff("d",msg.date,now())>30 then
								if Isdel=1 Then pop3.deletesinglemessage(K)
							end if
							Set msg = nothing
						end if
						K=K-1
						Set msg = nothing
					Loop
					Response.write"<script type=""text/javascript"">$(""#loading div"").animate({width:"""&Fix(1*400)&"px""}).text(""100%"")</script>"
					Response.Flush
				end if
				Set pop3 = Nothing
			end sub
			Sub RecvJMail_ord(sendID,recvID,isdel)
				Dim rs
				set rs=server.CreateObject("adodb.recordset")
				sql="select * from email_sender where ord="&sendID&""
				rs.open sql,conn,1,1
				if not rs.eof Then
					SmtpUser = rs("emailname")
					EmailUrl=rs("EmailUrl")
					SmtpPass=DeCrypt(rs("EmailPasswd"))
					Smtppop3=rs("EmailPop3")
				else
					Response.write"<script language=javascript>alert('接收邮箱账号异常！'); history.back();</script>"
					Response.end
				end if
				rs.close
				set rs=nothing
				set rs=server.CreateObject("adodb.recordset")
				sql="select * from email_recv_list where ord="&recvID&""
				rs.open sql,conn,1,1
				if not rs.eof then
					email_Id=rs("email_Id")
				else
					Response.write"<script language=javascript>alert('该邮件异常！无法下载附件'); history.back();</script>"
					Response.end
				end if
				rs.close
				set rs=Nothing
				on error resume next
				Set pop3 = Server.CreateObject( "JMail.POP3" )
				pop3.Connect EmailUrl, SmtpPass, Smtppop3
				if err.number<>0 then
					err.Clear
					pop3.Connect SmtpUser, SmtpPass, Smtppop3
				end if
				if err.number<>0 then
					Response.write"<script language=javascript>alert('接收邮箱账号异常！');history.back(); </script>"
					Response.end
				end if
				EmailToall=pop3.count
				if EmailToall > 0 then
					For K = 1 To EmailToall
						if pop3.GetMessageUID(k)=email_Id Then
							Set msg = pop3.Messages.item(K)
							ReTo = ""
							ReCC = ""
							Set Recipients = msg.Recipients
							msg.Charset = "utf-8"
							Set Recipients = msg.Recipients
							msg.ContentTransferEncoding="base64"
							msg.Encoding="base64"
							msg.ISOEncodeHeaders=False
							Dim doc : Set doc = New EmailMessageClass
							doc.load msg.bodytext
								doc.save Server.mappath("../email/upload/" & doc.GetDateText), "../email/upload/" & doc.GetDateText
									For i = 0 To doc.AttachmentsCount - 1
										doc.save Server.mappath("../email/upload/" & doc.GetDateText), "../email/upload/" & doc.GetDateText
											Set fitem = doc.Attachments(i)
											call saveAccess(recvID, fitem.saveVirpath ,fitem.Size &"( bytes)",2, fitem.fileName, "")
											str_Access_url=str_Access_url&("<a href='" & fitem.saveVirpath & "' title='下载附件'><img src='img/attachment.gif' style='border: none;' alt='此邮件存在附件'/></a><br/>")
										next
										If doc.InnerFilesCount > 0 And Len(doc.html) > 0 Then
											conn.execute "update email_recv_list set content='" & Replace(doc.html,"'","''") & "' where ord=" & recvID
										end if
										Set doc = Nothing
										conn.execute "update email_recv_list set isDownAccess=1 where ord="&recvID&""
										Response.write str_Access_url
										if isdel=1 Then pop3.deletesinglemessage(K)
										pop3.Disconnect
										Set pop3 = Nothing
										conn.close
										Response.end
									end if
								next
							end if
							pop3.Disconnect
							Set pop3 = Nothing
							Response.write "无法获取要下载的邮件。"
						end sub
						Sub DelJMail_ord(sendID,recvID)
							Dim rs
							set rs=server.CreateObject("adodb.recordset")
							sql="select * from email_sender where ord="&sendID&""
							rs.open sql,conn,1,1
							if not rs.eof Then
								SmtpUser = rs("emailname")
								EmailUrl=rs("EmailUrl")
								SmtpPass=DeCrypt(rs("EmailPasswd"))
								Smtppop3=rs("EmailPop3")
							else
								Response.write"<script language=javascript>alert('接收邮箱账号异常！'); history.back();</script>"
								Response.end
							end if
							rs.close
							set rs=nothing
							set rs=server.CreateObject("adodb.recordset")
							sql="select * from email_recv_list where ord="&recvID&""
							rs.open sql,conn,1,1
							if not rs.eof then
								email_Id=rs("email_Id")
							else
								Response.write"<script language=javascript>alert('该邮件异常！无法下载附件'); history.back();</script>"
								Response.end
							end if
							rs.close
							set rs=Nothing
							Set pop3 = Server.CreateObject( "JMail.POP3" )
							pop3.Connect EmailUrl, SmtpPass, Smtppop3
							if err.number<>0 then
								err.Clear
								pop3.Connect SmtpUser, SmtpPass, Smtppop3
							end if
							if err.number<>0 then
								Response.write"<script language=javascript>alert('接收邮箱账号异常！');history.back(); </script>"
								Response.end
							end if
							EmailToall=pop3.count
							if EmailToall > 0 then
								For K = 1 To EmailToall
									if pop3.GetMessageUID(k)=email_Id then
										pop3.deletesinglemessage(K)
									end if
								next
							end if
							Set pop3 = Nothing
						end sub
						sub DelJMail_All(sendID,recver_sql)
							Dim rs
							set rs=server.CreateObject("adodb.recordset")
							sql="select * from email_sender where ord="&sendID&""
							rs.open sql,conn,1,1
							if not rs.eof Then
								SmtpUser = rs("emailname")
								EmailUrl=rs("EmailUrl")
								SmtpPass=DeCrypt(rs("EmailPasswd"))
								Smtppop3=rs("EmailPop3")
							end if
							rs.close
							set rs=nothing
							if SmtpUser<>"" and SmtpPass<>"" and Smtppop3<>"" then
								set rs=server.CreateObject("adodb.recordset")
								rs.open recver_sql,conn,1,1
								if not rs.eof then
									REDIM email_IdArr(rs.RecordCount)
									i=0
									do while not rs.eof
										email_IdArr(i)=rs("email_Id")
										i=i+1
										email_IdArr(i)=rs("email_Id")
										rs.movenext
									loop
								end if
								rs.close
								set rs=Nothing
								on error resume next
								Set pop3 = Server.CreateObject( "JMail.POP3" )
								pop3.Connect EmailUrl, SmtpPass, Smtppop3
								if err.number<>0 then
									err.Clear
									pop3.Connect SmtpUser, SmtpPass, Smtppop3
								end if
								if err.number<>0 then
									Response.write"<script language=javascript>alert('接收邮箱账号异常！');history.back(); </script>"
									Response.end
								end if
								EmailToall=pop3.count
								if EmailToall > 0 then
									for j=0 to Ubound(email_IdArr,1)-1
'if EmailToall > 0 then
										For K = 1 To EmailToall
											on error resume next
											if pop3.GetMessageUID(k)=email_IdArr(j) then
												pop3.deletesinglemessage(K)
											end if
											On Error GoTo 0
										next
									next
								end if
								Set pop3 = Nothing
							end if
						end sub
						Function Cdonts(Email, Topic, MailBody, Html)
							on error resume next
							Dim objCDOMail
							Set objCDOMail = Server.CreateObject("CDONTS.NewMail")
							objCDOMail.From = WebMail
							objCDOMail.To = Email
							objCDOMail.Subject = Topic
							If CLng(Html) = 1 Then
								objCDOMail.BodyFormat = 0
							else
								objCDOMail.BodyFormat = 1
							end if
							objCDOMail.MailFormat = 0
							objCDOMail.Importance = 2
							objCDOMail.Body = MailBody
							objCDOMail.Send
							Set objCDOMail = Nothing
						end function
	Function Persits(Email, Topic, MailBody, Html)
		on error resume next
		Dim Mailer
		Set Mailer = Server.CreateObject("Persits.MailSender")
		Mailer.Charset = "utf-8"
		Set Mailer = Server.CreateObject("Persits.MailSender")
		If CLng(Html) = 1 Then
			Mailer.IsHTML = True
		else
			Mailer.IsHTML = False
		end if
		Mailer.username = SmtpUser
		Mailer.password = SmtpPass
		Mailer.Priority = 1
		Mailer.Host = SmtpSrv
		Mailer.Port = 25
		Mailer.From = WebMail
		Mailer.FromName = SiteName
		Mailer.AddAddress Email, Email
		Mailer.Subject = Topic
		Mailer.Body = MailBody
		Mailer.Send
		Set Mailer = Nothing
	end function
	function sendLog(title,sender,recver,sendContent,errmsg,add_cateid2,add_cateid3,uploadfile,FileNameOldArr,FileSizeArr,csEmail,msEmail,sendNum,ord_action,sort_action)
		if sender<>"" and recver<>"" and sendContent<>"" and errmsg<>"" then
			if recver<>"" and instr(recver,";")<1 then
				set rs7=server.CreateObject("adodb.recordset")
				sql7="select ord from person where del=1 and email='"&recver&"'"
				rs7.open sql7,conn,1,1
				if not rs7.eof then
					person=rs7(0)
				else
					person=0
				end if
				rs7.close
				set rs7=nothing
			end if
			if person="" then person=0
			if ubound(uploadfile)>=0 then
				isAccess=1
			else
				isAccess=0
			end if
			sql="insert into email_log(recv_email,title,content,stact,addtime,addcate,cateid2,cateid3,send_email,csEmail,msEmail,isAccess,sendNum,person,del,ord_action,sort_action) values('"&recver&"','"&title&"','"&sendContent&"',"&errmsg&",'"&now()&"',"&session("personzbintel2007")&","&add_cateid2&","&add_cateid3&","&sender&",'"&csEmail&"','"&msEmail&"',"&isAccess&","&sendNum&","&person&",1,"&ord_action&","&sort_action&")"
			conn.execute sql
			if ubound(uploadfile)>=0 then
				df_access_ord=conn.execute("SELECT SCOPE_IDENTITY()")(0)
				for f=0 to ubound(uploadfile)
					call saveAccess(df_access_ord,uploadfile(f),FileSizeArr(f),1,FileNameOldArr(f),"")
				next
			end if
		end if
	end function
	function recvLog_sub(ByVal sendMail,ByVal sendName,recvmail,title,content,sendtime,isAccess,csEmail,recvord,email_Id)
		if recvmail<>"" and title<>"" and content<>""  then
			set rs=server.CreateObject("adodb.recordset")
			sql="select * from email_recv_list  where addcate="&session("personzbintel2007")&" and recvord="&recvord&" and email_Id='"&email_Id&"'"
			rs.open sql,conn,1,3
			if rs.eof then
				rs.addnew
				sendMail = sendMail & ""
				title = title & ""
				If Len(sendMail) > 50 Then sendMail = Left(sendMail,50)
				If Len(title) > 200 Then title = Left(title,200)
				rs("sendMail")=sendMail
				rs("sendName")=sendName
				rs("recvmail")=recvmail
				rs("title")=title
				rs("content")=(content)
				rs("sendtime")=sendtime
				rs("addtime")=now()
				rs("addcate")=session("personzbintel2007")
				rs("isAccess")=isAccess
				rs("isDownAccess")=1
				rs("csEmail")=csEmail
				rs("recvord")=recvord
				rs("isRead")=0
				rs("email_Id")=email_Id
				rs("del")=1
				rs.update
				rs.close
				set rs=Nothing
				Dim r
				r = conn.execute("select max(ord) from email_recv_list where addcate="&session("personzbintel2007")&" and recvord="&recvord&" and email_Id='"&email_Id&"'")(0).value
				recvLog_sub = r
			else
				rs.close
				set rs = nothing
			end if
		end if
	end function
	sub saveAccess(ord,url,Fsize,Mtype,oldName,fileDes)
		if ord<>"" and url<>""  then
			conn.execute "insert into email_recv_Access(email_ord,Access_url,Access_size,mailType,oldname,fileDes,del) values("&ord&",'"&url&"','"&Fsize&"',"&Mtype&",'"&oldName&"','"&fileDes&"',1)"
		end if
	end sub
	sub viewAcdess(ord,mailType)
		set rs_view=server.CreateObject("adodb.recordset")
		sql_view="select Access_url,oldname from email_recv_Access  where mailType="&mailType&" and del=1 and email_ord="&ord&""
		rs_view.open sql_view,conn,1,1
		if not rs_view.eof then
			do while not rs_view.eof
				Response.write "<a href='"&rs_view(0)&"' title='下载附件'><img src='img/attachment.gif' style='border: none;' alt='此邮件存在附件 &#10 "&rs_view("oldname")&"'/></a><br/>"
				rs_view.movenext
			loop
		end if
		rs_view.close
		set rs_view=nothing
	end sub
	sub viewAcdessContent(ord,mailType)
		set rs_view=server.CreateObject("adodb.recordset")
		sql_view="select Access_url,oldname from email_recv_Access  where mailType="&mailType&" and del=1 and email_ord="&ord&""
		rs_view.open sql_view,conn,1,1
		if not rs_view.eof then
			do while not rs_view.eof
				Response.write "<a href='"&rs_view(0)&"' title='下载附件'><img src='img/attachment.gif' style='border: none;' alt='此邮件存在附件 &#10 "&rs_view("oldname")&"'/>"&rs_view("oldname")&"</a><br/>"
				rs_view.movenext
			loop
		else
			Response.write "附件已删除"
		end if
		rs_view.close
		set rs_view=nothing
	end sub
	Function isUTF8(str)
		isUTF8 = (InStr(UCase(str),"UTF-8")>0 Or InStr(UCase(str),"UTF8")>0)
'Function isUTF8(str)
	end function
	Function toUTF8(str,str1)
		Dim ArrUtf8_From
		If InStr(UCase(str),"UTF-8")>0 Or InStr(UCase(str),"UTF8")>0 Then
'Dim ArrUtf8_From
			ArrUtf8_From=Split(str,"?")
			Dim b64str
			Dim b64 : Set b64 = server.createobject(ZBRLibDLLNameSN & ".Base64Class")
			If UCase(ArrUtf8_From(2))="Q" Then
				toUTF8= b64.UrlDecodeByUtf8(Replace(ArrUtf8_From(3),"=","%"))
			else
				b64str = ArrUtf8_From(3)
				toUTF8 = b64.DeCodeByUtf8(b64str)
			end if
			Set b64 = nothing
		else
			toUTF8=str1
		end if
	end function
	
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN"" ""http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
	Response.write session("name2006chen")
	Response.write "智能销售平台</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<link href=""css/style.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<script src=""../inc/system.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ type=""text/javascript"" language=""javascript""></script>" & vbcrlf & "<script src=""../inc/jquery-1.4.2.min.js?ver="
	'Response.write Application("sys.info.jsver")
	Response.write Application("sys.info.jsver")
	Response.write """ type=""text/javascript"" language=""javascript""></script>" & vbcrlf & "</head>" & vbcrlf & "<body bgcolor=""#ebebeb"" onMouseOver=""window.status='none';return true;"">" & vbcrlf & ""
	Server.ScriptTimeOut=1000
	set rs=server.CreateObject("adodb.recordset")
	sql="select top 1 * from email_sender  where gate="&session("personzbintel2007")&" order by EmailDefault desc"
	rs.open sql,conn,1,1
	if rs.eof then
		EmailName=""
		EmailPasswd=""
		Emailsmtp=""
		EmailPop3=""
		EmailUrl=""
		SmtpObj=""
		Emailord=0
		delMail=0
		Response.write"<script language=javascript>alert('您还没有设置邮箱接收账号！请到【邮件设置】界面设置'); window.location.href='setEmail.asp'; </script>"
		call db_close : Response.end
	else
		EmailName=rs("EmailName")
		EmailPasswd=DeCrypt(rs("EmailPasswd"))
		Emailsmtp=rs("Emailsmtp")
		EmailPop3=rs("EmailPop3")
		EmailUrl=rs("EmailUrl")
		SmtpObj=rs("SmtpObj")
		Emailord=rs("ord")
		delMail=rs("delMail")
		receiveNum=rs("receiveTotal")
	end if
	rs.close
	set rs=nothing
	Response.write "" & vbcrlf & "<div id=""loading""><div></div></div>" & vbcrlf & ""
	if delMail="" then delMail=0
	if request.QueryString("page_count")="" then
		maxMailSendtimeSQL="select isnull(max(sendtime),0) as maxTime from email_recv_list where del=1 and recvord=" & Emailord & " and addcate="&session("personzbintel2007")&""
		set maxRs=server.CreateObject("adodb.recordset")
		maxRs.Open maxMailSendtimeSQL,conn,1,1
		maxMailSendtime=maxRs("maxTime")
		if maxMailSendtime="1900-1-1" Or maxMailSendtime="1900-01-01"  then
			maxMailSendtime=maxRs("maxTime")
			call RecvJMail(Emailord,EmailName,EmailPasswd,EmailPop3,delMail,EmailUrl,0,receiveNum)
		else
			call RecvJMail(Emailord,EmailName,EmailPasswd,EmailPop3,delMail,EmailUrl,maxMailSendtime,receiveNum)
			maxRs.Close()
		end if
	end if
	action1="接收最新邮件"
	call close_list(1)
	Response.write "" & vbcrlf & "<script type=""text/javascript"">$(""#loading"").fadeOut();window.location.href=""../email/recvlist.asp"";</script></body>" & vbcrlf & "</html>"
	
%>
