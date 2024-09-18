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
	
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_1=0
		intro_77_1=0
	else
		open_77_1=rs1("qx_open")
		intro_77_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_14=0
		intro_77_14=0
	else
		open_77_14=rs1("qx_open")
		intro_77_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_7=0
		intro_77_7=0
	else
		open_77_7=rs1("qx_open")
		intro_77_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_8=0
		intro_77_8=0
	else
		open_77_8=rs1("qx_open")
		intro_77_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_10=0
		intro_77_10=0
	else
		open_77_10=rs1("qx_open")
		intro_77_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_11=0
		intro_77_11=0
	else
		open_77_11=rs1("qx_open")
		intro_77_11=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_3=0
		intro_77_3=0
	else
		open_77_3=rs1("qx_open")
		intro_77_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=12"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_12=0
		intro_77_12=0
	else
		open_77_12=rs1("qx_open")
		intro_77_12=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_13=0
		intro_77_13=0
	else
		open_77_13=rs1("qx_open")
		intro_77_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=19"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_19=0
		intro_77_19=0
	else
		open_77_19=rs1("qx_open")
		intro_77_19=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	if open_77_1=3 then
		list_tj=""
	elseif open_77_1=1 then
		list_tj="and addcate in ("&intro_77_1&")"
	else
		list_tj="and addcate=0"
	end if
	dim rs,sql,Str_Result,Str_Result2,catesafe,sorce_user,sorce_user2
	Str_Result="where 1=1 "&list_tj&""
	Str_Result2="and 1=1 "&list_tj&""
	Str_power=""
	Str_power22=""
	Str_power33=""
	sorce=0
	sorce2=0
	sorce3=0
	if open_77_1="1"  then
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select ord,name,sorce,sorce2 from gate  where ord in ("&intro_77_1&") and del=1 order by sorce asc,sorce2 asc ,cateid asc ,ord asc"
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
	elseif open_77_1="3" then
		Str_power="where ord>0"
		Str_power11="and ord>0"
		Str_power2="and ord>0"
		Str_power22="where ord>0"
		Str_power3="and ord>0  and del=1"
		Str_power33="where ord>0 and del=1"
	else
		Str_power="where ord<0"
		Str_power2="ord<0 and "
		Str_power22="where ord<0"
		Str_power3="and ord<0"
		Str_power33="where ord<0"
	end if
	
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
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=85 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_85_1=0
		intro_85_1=0
	else
		open_85_1=rs1("qx_open")
		intro_85_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=85 and sort2=2"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_85_2=0
		intro_85_2=0
	else
		open_85_2=rs1("qx_open")
		intro_85_2=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=85 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_85_14=0
		intro_85_14=0
	else
		open_85_14=rs1("qx_open")
		intro_85_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=85 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_85_7=0
		intro_85_7=0
	else
		open_85_7=rs1("qx_open")
		intro_85_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=85 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_85_8=0
		intro_85_8=0
	else
		open_85_8=rs1("qx_open")
		intro_85_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=85 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_85_10=0
		intro_85_10=0
	else
		open_85_10=rs1("qx_open")
		intro_85_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=85 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_85_11=0
		intro_85_11=0
	else
		open_85_11=rs1("qx_open")
		intro_85_11=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=85 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_85_3=0
		intro_85_3=0
	else
		open_85_3=rs1("qx_open")
		intro_85_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=85 and sort2=12"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_85_12=0
		intro_85_12=0
	else
		open_85_12=rs1("qx_open")
		intro_85_12=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=85 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_85_13=0
		intro_85_13=0
	else
		open_85_13=rs1("qx_open")
		intro_85_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=85 and sort2=16"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_85_16=0
		intro_85_16=0
	else
		open_85_16=rs1("qx_open")
		intro_85_16=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=85 and sort2=19"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_85_19=0
		intro_85_19=0
	else
		open_85_19=rs1("qx_open")
		intro_85_19=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
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
	Dim curUserID
	curUserID = Session("personzbintel2007")
	Sub InitTempTable(tableName,sql,billIDFiledName,UserFieldName,sort1)
		Dim rs,contentPower,qx_open,qx_intro,tName,tempSql
		Set rs1 = server.CreateObject("adodb.recordset")
		sql1 = "SELECT qx_open,qx_intro FROM power  WHERE ord = "& curUserID &" AND sort1 = "&sort1&" AND sort2 = 14 "
		rs1.Open sql1,conn,1,1
		If rs1.eof then
			qx_open = 0
			qx_intro = 0
		else
			qx_open = rs1("qx_open")
			qx_intro = rs1("qx_intro")
		end if
		rs1.Close
		Set rs1 = Nothing
		If qx_open = 3 Or sort1 = 77 Then
			contentPower = ""
		ElseIf qx_open = 1 Then
			contentPower = " AND xxxxx."&UserFieldName&" IN ("& qx_intro &") "
		else
			contentPower = " AND 1 = 2"
		end if
		sql = "###temp"&Trim(sql)
		sql = Replace(sql,Left(sql,14),"SELECT TOP 1000000 ")
		sql = "SELECT * FROM ("& sql &") xxxxx WHERE 1 = 1 "&contentPower&" "
		CALL setAttr(tableName&"_"&curUserID&"_temp",sql)
	end sub
	Sub ShowPrevOrNext(tableName,FiledName,ID,IsEncryption)
		Dim httptype
		if Request.ServerVariables("HTTPS") = "on" then
			httptype = "https"
		else
			httptype = "http"
		end if
		Dim rs,sql,tempSql,URL,Domain_Name,Domain_port,Page_Name,tName,globalStr,arr,billIDFiledName,UserFieldName,sort1
		tempSql = getAttr(tableName&"_"&curUserID&"_temp")
		If tempSql&"" = "" Then
			Exit Sub
		end if
		Domain_Name = LCase(Request.ServerVariables("Server_Name"))
			Domain_port = LCase(Request.ServerVariables("Server_port"))
				Page_Name = LCase(Request.ServerVariables("Script_Name"))
				URL = httptype & "://"&Domain_Name&":"&Domain_port&Page_Name
				Dim prevID,nextID
				Set rs = server.CreateObject("adodb.recordset")
				sql = " set nocount on;declare @currID int; "&_
				" declare @a table(id int identity(1,1),ord int); "&_
				" insert into @a select " & FiledName & " from ("& tempSql &") a; "&_
				" select @currID = id from @a where ord = " & id & "; "&_
				" select top 1 ord,'Prev' KeyName from @a where id = currID - 1 "&_
				" select @currID = id from @a where ord = " & id & "; "&_
				" union all "&_
				" select top 1 ord,'Next' KeyName from @a where id = currID + 1; "&_
				" union all "&_
				"delete @a;set nocount off"
				prevID = 0
				nextID = 0
				rs.open sql,conn,1,1
				while rs.Eof =  False
					If rs(1) = "Prev" Then
						prevID = rs(0)
					end if
					If rs(1) = "Next" Then
						nextID = rs(0)
					end if
					rs.movenext
				wend
				rs.close
				set rs = nothing
				If prevID > 0 Then
					If IsEncryption = "1" Then
						prevURL = URL&"?"&FiledName&"="&pwurl(prevID)
					else
						prevURL = URL&"?"&FiledName&"="&prevID
					end if
					If tableName = "email_log" Then
						prevURL = prevURL&"&action=send"
					ElseIf tableName = "email_recv_list" Then
						prevURL = prevURL&"&action=recv&isRead=1"
					end if
					Response.write("<input type='button' name='prev' value='上一个' onClick=""javascript:window.location.href='"&prevURL&"'"" class='anybutton' />")
				end if
				If nextID > 0 Then
					If IsEncryption = "1" Then
						nextURL = URL&"?"&FiledName&"="&pwurl(nextID)
					else
						nextURL = URL&"?"&FiledName&"="&nextID
					end if
					If tableName = "email_log" Then
						nextURL = nextURL&"&action=send"
					ElseIf tableName = "email_recv_list" Then
						nextURL = nextURL&"&action=recv&isRead=1"
					end if
					Response.write("<input type='button' name='prev' value='下一个' onClick=""javascript:window.location.href='"&nextURL&"'"" class='anybutton' />")
				end if
			end sub
			Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN"" ""http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
			Response.write session("name2006chen")
			Response.write "智能销售平台</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
			Response.write Application("sys.info.jsver")
			Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<link href=""css/style.css?ver="
			Response.write Application("sys.info.jsver")
			Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style>" & vbcrlf & "#ht1 #content{margin-bottom:-1px;}" & vbcrlf & "</style>" & vbcrlf & "<script src=""../inc/system.js?ver="
			'Response.write Application("sys.info.jsver")
			Response.write Application("sys.info.jsver")
			Response.write """ type=""text/javascript"" language=""javascript""></script>" & vbcrlf & "<script src=""../inc/jquery-1.4.2.min.js?ver="
			'Response.write Application("sys.info.jsver")
			Response.write Application("sys.info.jsver")
			Response.write """ type=""text/javascript"" language=""javascript""></script>" & vbcrlf & "<script src=""js/saveAccess.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write """ type=""text/javascript"" language=""javascript""></script>" & vbcrlf & "</head>" & vbcrlf & "<body bgcolor=""#ebebeb"" "
			if open_77_8=0 then
				Response.write " oncontextmenu=""return false"" onselectstart=""return false"" ondragstart=""return false"" onbeforecopy=""return false"" oncopy=document.selection.empty()"
			end if
			Response.write " onMouseOver=""window.status='none';return true;"">" & vbcrlf & ""
			Server.ScriptTimeOut=1000
			function IsPermission(sqlQx_intro,seller)
				set rsQx_intro=server.CreateObject("adodb.recordset")
				rsQx_intro.Open sqlQx_intro,conn,1,1
				IsPermission=false
				if not rsQx_intro.EOF then
					qx_open=rsQx_intro("qx_open")
					if qx_open=3 then
						IsPermission=true
					elseif qx_open=0 then
						IsPermission=false
					else
						if rsQx_intro("qx_intro")=seller then
							IsPermission=true
						else
							m=instr(rsQx_intro("qx_intro"),seller&",")
							n=instr(rsQx_intro("qx_intro"),","&seller)
							q=instr(rsQx_intro("qx_intro"),","&seller&",")
							if m>0 or n>0 or q>0 then
								IsPermission=true
							end if
						end if
					end if
				end if
				rsQx_intro.close
				set rsQx_intro=nothing
			end function
	del=trim(request("del"))
	G1=trim(request("G1"))
	G2=trim(request("G2"))
	S1=trim(request("S1"))
	S2=trim(request("S2"))
	m1=trim(request("ret"))
	m2=trim(request("ret2"))
	A1=trim(request("A1"))
	T1=trim(request("T1"))
	T2=trim(request("T2"))
	C1=trim(request("C1"))
	C2=trim(request("C2"))
	W1=replace(request("W1")," ","")
	W2=replace(request("W2")," ","")
	W3=replace(request("W3")," ","")
	if W1="" then W1=0
	if W2="" then W2=0
	if W3="" then W3=0
	W3=getW3(W1,W2,W3)
	W3=getLimitedW3(W3,2,1,0,session("personzbintel2007"))
	W4=replace(W3,"0","")
	W4=replace(W4,",","")
	CurrPage=Request("CurrPage")
	If Not isnumeric(CurrPage) Or CurrPage="" Then
		CurrPage=1
	else
		CurrPage=clng(CurrPage)
	end if
	page_count=request.QueryString("page_count")
	if page_count="" then
		page_count=10
	end if
	if W4<>"" then
		Str_Result=Str_Result+"and addcate in  ("&W3&")"
'if W4<>"" then
		Str_Result2=Str_Result2+"and addcate in  ("&W3&")"
'if W4<>"" then
	end if
	if m1<>"" then
		Str_Result=Str_Result+"and sendtime>='"&m1&"' "
'if m1<>"" then
		Str_Result2=Str_Result2+"and sendtime>='"&m1&"' "
'if m1<>"" then
		m1name="  起始："&m1
	end if
	if m2<>"" then
		Str_Result=Str_Result+"and sendtime<='"&cdate(m2)+1&"' "
'if m2<>"" then
		Str_Result2=Str_Result2+"and sendtime<='"&cdate(m2)+1&"' "
'if m2<>"" then
		m2name="  截止："&m2
	end if
	if A1<>"" then
		Str_Result=Str_Result+" and stact is not null  and  stact in("&A1&")"
'if A1<>"" then
		Str_Result2=Str_Result2+" and stact is not null and  stact in("&A1&")"
'if A1<>"" then
	end if
	if C2<>"" then
		if C1=1 then
			str_Result=str_Result+" and content like '%"& C2 &"%'"
'if C1=1 then
			str_Result2=str_Result2+" and content like '%"& C2 &"%'"
'if C1=1 then
		elseif C1=2 then
			str_Result=str_Result+" and content not like '%"& C2 &"%'"
'elseif C1=2 then
			str_Result2=str_Result2+" and content not like '%"& C2 &"%'"
'elseif C1=2 then
		elseif C1=3 then
			str_Result=str_Result+" and content like '"&C2&"'"
'elseif C1=3 then
			str_Result2=str_Result2+" and content like '"&C2&"'"
'elseif C1=3 then
		elseif C1=4 then
			str_Result=str_Result+" and content not like '"&C2&"'"
'elseif C1=4 then
			str_Result2=str_Result2+" and content not like '"&C2&"'"
'elseif C1=4 then
		elseif C1=5 then
			str_Result=str_Result+" and content like '"& C2 &"%'"
'elseif C1=5 then
			str_Result2=str_Result2+" and content like '"& C2 &"%'"
'elseif C1=5 then
		elseif C1=6 then
			str_Result=str_Result+" and content like '%"& C2 &"'"
'elseif C1=6 then
			str_Result2=str_Result2+" and content like '%"& C2 &"'"
'elseif C1=6 then
		end if
	end if
	if S2<>"" and S1<>"" then
		if S1=1 then
			str_Result=str_Result+" and sendMail like '%"& S2 &"%'"
'if S1=1 then
			str_Result2=str_Result2+" and sendMail like '%"& S2 &"%'"
'if S1=1 then
		elseif S1=2 then
			str_Result=str_Result+" and sendMail not like '%"& S2 &"%'"
'elseif S1=2 then
			str_Result2=str_Result2+" and sendMail not like '%"& S2 &"%'"
'elseif S1=2 then
		elseif S1=3 then
			str_Result=str_Result+" and sendMail='"&S2&"'"
'elseif S1=3 then
			str_Result2=str_Result2+" and sendMail='"&S2&"'"
'elseif S1=3 then
		elseif S1=4 then
			str_Result=str_Result+" and sendMail<>'"&S2&"'"
'elseif S1=4 then
			str_Result2=str_Result2+" and sendMail<>'"&S2&"'"
'elseif S1=4 then
		elseif S1=5 then
			str_Result=str_Result+" and sendMail like '"& S2 &"%'"
'elseif S1=5 then
			str_Result2=str_Result2+" and sendMail like '"& S2 &"%'"
'elseif S1=5 then
		elseif S1=6 then
			str_Result=str_Result+" and sendMail like '%"& S2 &"'"
'elseif S1=6 then
			str_Result2=str_Result2+" and sendMail like '%"& S2 &"'"
'elseif S1=6 then
		end if
	end if
	If G1&""="" Then
		G1=trim(request("G3"))
		G2=trim(request("G4"))
	end if
	if G2<>"" then
		if G1=1 then
			str_Result2=str_Result2+"and title  like '%"& G2 &"%'"
'if G1=1 then
		elseif G1=2 then
			str_Result2=str_Result2+"and title not like '%"& G2 &"%'"
'elseif G1=2 then
		elseif G1=3 then
			str_Result2=str_Result2+"and title='"&G2&"'"
'elseif G1=3 then
		elseif G1=4 then
			str_Result2=str_Result2+"and title<>'"&G2&"'"
'elseif G1=4 then
		elseif G1=5 then
			str_Result2=str_Result2+"and title like '"& G2 &"%'"
'elseif G1=5 then
		elseif G1=6 then
			str_Result2=str_Result2+"and title like '%"& G2 &"'"
'elseif G1=6 then
		end if
	end if
	if open_77_1= 3 then
		Str_Result2=Str_Result2&""
	elseif open_77_1= 1 then
		Str_Result2=Str_Result2&" and (addcate in("&intro_77_1&")) "
	else
		Str_Result2=Str_Result2&" and 1=2"
	end if
	if del="2" then
		Str_Result2=Str_Result2&" and del=2"
	else
		Str_Result2=Str_Result2&" and del=1"
	end if
	Response.write "" & vbcrlf & "<form name=""date"" method=""post"" action=""recvList.asp?page_count="
	Response.write page_count
	Response.write """ style=""margin:0"">" & vbcrlf & "<table width=""100%""  border=""0"" align=""left"" cellpadding=""0"" cellspacing=""0"" bordercolor=""#E2E2E1"" bgcolor=""#FFFFFF"" >" & vbcrlf & "    <tr>" & vbcrlf & "         <td width=""100%"" valign=""top"">" & vbcrlf & "              <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "                   <tr><td width=""608"" height=""33"" class=""place"">邮件接收记录</td><td >&nbsp;</td></tr>" & vbcrlf & "                  <tr>" & vbcrlf & "                            <td  background=""../images/112.gif""  height=""30"" align=""right"" colspan=""4""><div align=""right""  id=""kh"">邮件标题：" & vbcrlf & "                          <input name=""G3""  value=""1"" id=""Kjs1"" type=""hidden"" size=""15"" />" & vbcrlf & "                          <input  name=""G4"" id=""Kjs1"" type=""text"" size=""15"" />" & vbcrlf & "                            <input type=""submit"" name=""Submit45"" value=""检索"" onClick=""submit4();""  class=""page""/>" & vbcrlf & "                             <input type=""button"" name=""getEmail"" value=""获取邮件"" onClick=""if(confirm('获取最新邮件？')){window.location.href='getEmail.asp'}""  class=""anybutton2""/>" & vbcrlf & "                          "
	if open_77_10=1 or open_77_10=3 then
		Response.write "" & vbcrlf & "                             <input type=""button"" name=""Submitdel2"" value=""记录导出"" onClick=""if(confirm('确认导出为EXCEL文档？')){exportExcel({from:'form_with_page_action',page:'../out/xls_emailRecv.asp?page_count="
		Response.write page_count
		Response.write "&currPage="
		Response.write  currpage
		Response.write "&A2="
		Response.write A2
		Response.write "&A1="
		Response.write A1
		Response.write "&person="
		Response.write personid
		Response.write "&company="
		Response.write companyid
		Response.write "&S1="
		Response.write S1
		Response.write "&del=1&S2="
		Response.write S2
		Response.write "&G1="
		Response.write G1
		Response.write "&G2="
		Response.write G2
		Response.write "&D="
		Response.write D
		Response.write "&q="
		Response.write q
		Response.write "&F1="
		Response.write F1
		Response.write "&F2="
		Response.write F2
		Response.write "&E="
		Response.write E
		Response.write "&F="
		Response.write F
		Response.write "&C1="
		Response.write C1
		Response.write "&C2="
		Response.write C2
		Response.write "&W1="
		Response.write W1
		Response.write "&W2="
		Response.write W2
		Response.write "&W3="
		Response.write W3
		Response.write "&P1="
		Response.write P1
		Response.write "&P2="
		Response.write P2
		Response.write "&J1="
		Response.write J1
		Response.write "&J2="
		Response.write J2
		Response.write "&ret="
		Response.write m1
		Response.write "&ret2="
		Response.write m2
		Response.write "'});}"" class=""anybutton2""/>" & vbcrlf & "                         "
	end if
	if open_77_3=3 or open_77_3=1  then
		Response.write "<input  name=submit22332 type=""button"" onClick=""if(confirm('确认清除全部？')){window.location.href='delallRecv.asp?complete=1&page_count="
		Response.write page_count
		Response.write "&currPage="
		Response.write  currpage
		Response.write "&A2="
		Response.write A2
		Response.write "&A1="
		Response.write A1
		Response.write "&person="
		Response.write personid
		Response.write "&company="
		Response.write companyid
		Response.write "&S1="
		Response.write S1
		Response.write "&S2="
		Response.write S2
		Response.write "&G1="
		Response.write G1
		Response.write "&G2="
		Response.write G2
		Response.write "&D="
		Response.write D
		Response.write "&q="
		Response.write q
		Response.write "&F1="
		Response.write F1
		Response.write "&F2="
		Response.write F2
		Response.write "&E="
		Response.write E
		Response.write "&F="
		Response.write F
		Response.write "&C1="
		Response.write C1
		Response.write "&C2="
		Response.write C2
		Response.write "&W1="
		Response.write W1
		Response.write "&W2="
		Response.write W2
		Response.write "&W3="
		Response.write W3
		Response.write "&P1="
		Response.write P1
		Response.write "&P2="
		Response.write P2
		Response.write "&J1="
		Response.write J1
		Response.write "&J2="
		Response.write J2
		Response.write "&ret="
		Response.write m1
		Response.write "&ret2="
		Response.write m2
		Response.write "'}"" style=""cursor:hand"" class=""anybutton2""  value=""清除全部"">"
	end if
	if open_77_7=1 or open_77_7=3 then
		Response.write "<input type=""button"" name=""Submit43"" value=""打印""  onClick=""window.print();return  false;""   class=""anybutton""/>" & vbcrlf & "                               "
	end if
	Response.write "" & vbcrlf & "                             <a href=""###"" class=""AfterQuickSearch"" onclick=""callServer2();document.getElementById('kh').disabled='disabled';document.getElementById('kh').style.display='none';document.getElementById('kh').style.display='none';document.getElementById('ht1').style.display='';document.getElementById('ht1').disabled='';""><img src=""../images/icon_title.gif"" width=""18"" height=""7"" border=""0""><u><font class=""advanSearch"">高级检索</font></u></a> </div></td>" & vbcrlf & "                  </tr>" & vbcrlf & "           </table>" & vbcrlf & "        <span id=""ht1""></span>" & vbcrlf & "        <table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "          <tr class=""top"">" & vbcrlf & "            <td align=""center"" width=""5%""><div align=""center"">选择</div></td>" & vbcrlf & "            <td width=""8%""><div align=""center"">姓名</div></td>" & vbcrlf & "            <td width=""8%""><div align=""center"">职位</div></td>" & vbcrlf & "            <td width=""16%""><div align=""center"">来源</div></td>" & vbcrlf & "            <td width=""16%"" height=""27"" ><div align=""center"">发送人邮箱</div></td>" & vbcrlf & "            <td width=""25%"" ><div align=""center"">邮件标题</div></td>" & vbcrlf & "            <td ><div align=""center"">发送时间</div></td>" & vbcrlf & "            <td ><div align=""center"">收件人</div></td>" & vbcrlf & "            <td ><div align=""center"">" & vbcrlf & "                <select name=""select5"" onChange=""if(this.selectedIndex && this.selectedIndex!=0){window.open(this.value,'_self');}this.selectedIndex=0;"" style=""BACKGROUND: #FFFFFF; HEIGHT: 20px;font-size:12px;font-weight: bold;color:#2F496E;border:0px   solid   #FFFFFF; overflow:hidden"">" & vbcrlf &     "              <option>-请选择-</option>" &vbcrlf & "                  <option value=""recvList.asp?page_count=10&currPage="
	Response.write  currPage
	Response.write "&A2="
	Response.write A2
	Response.write "&A1="
	Response.write A1
	Response.write "&person="
	Response.write personid
	Response.write "&company="
	Response.write companyid
	Response.write "&S1="
	Response.write S1
	Response.write "&del="
	Response.write del
	Response.write "&S2="
	Response.write S2
	Response.write "&G1="
	Response.write G1
	Response.write "&G2="
	Response.write G2
	Response.write "&D="
	Response.write D
	Response.write "&q="
	Response.write q
	Response.write "&F1="
	Response.write F1
	Response.write "&F2="
	Response.write F2
	Response.write "&E="
	Response.write E
	Response.write "&F="
	Response.write F
	Response.write "&C1="
	Response.write C1
	Response.write "&C2="
	Response.write C2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&P1="
	Response.write P1
	Response.write "&P2="
	Response.write P2
	Response.write "&J1="
	Response.write J1
	Response.write "&J2="
	Response.write J2
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write """ "
	if page_count=10 then
		Response.write "selected"
	end if
	Response.write ">每页显示10条</option>" & vbcrlf & "                  <option value=""recvList.asp?page_count=20&currPage="
	Response.write  currPage
	Response.write "&A2="
	Response.write A2
	Response.write "&A1="
	Response.write A1
	Response.write "&person="
	Response.write personid
	Response.write "&company="
	Response.write companyid
	Response.write "&S1="
	Response.write S1
	Response.write "&del="
	Response.write del
	Response.write "&S2="
	Response.write S2
	Response.write "&G1="
	Response.write G1
	Response.write "&G2="
	Response.write G2
	Response.write "&D="
	Response.write D
	Response.write "&q="
	Response.write q
	Response.write "&F1="
	Response.write F1
	Response.write "&F2="
	Response.write F2
	Response.write "&E="
	Response.write E
	Response.write "&F="
	Response.write F
	Response.write "&C1="
	Response.write C1
	Response.write "&C2="
	Response.write C2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&P1="
	Response.write P1
	Response.write "&P2="
	Response.write P2
	Response.write "&J1="
	Response.write J1
	Response.write "&J2="
	Response.write J2
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write """ "
	if page_count=20 then
		Response.write "selected"
	end if
	Response.write ">每页显示20条</option>" & vbcrlf & "                  <option value=""recvList.asp?page_count=30&currPage="
	Response.write  currPage
	Response.write "&A2="
	Response.write A2
	Response.write "&A1="
	Response.write A1
	Response.write "&person="
	Response.write personid
	Response.write "&company="
	Response.write companyid
	Response.write "&S1="
	Response.write S1
	Response.write "&del="
	Response.write del
	Response.write "&S2="
	Response.write S2
	Response.write "&G1="
	Response.write G1
	Response.write "&G2="
	Response.write G2
	Response.write "&D="
	Response.write D
	Response.write "&q="
	Response.write q
	Response.write "&F1="
	Response.write F1
	Response.write "&F2="
	Response.write F2
	Response.write "&E="
	Response.write E
	Response.write "&F="
	Response.write F
	Response.write "&C1="
	Response.write C1
	Response.write "&C2="
	Response.write C2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&P1="
	Response.write P1
	Response.write "&P2="
	Response.write P2
	Response.write "&J1="
	Response.write J1
	Response.write "&J2="
	Response.write J2
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write """ "
	if page_count=30 then
		Response.write "selected"
	end if
	Response.write ">每页显示30条</option>" & vbcrlf & "                  <option value=""recvList.asp?page_count=50&currPage="
	Response.write  currPage
	Response.write "&A2="
	Response.write A2
	Response.write "&A1="
	Response.write A1
	Response.write "&person="
	Response.write personid
	Response.write "&company="
	Response.write companyid
	Response.write "&S1="
	Response.write S1
	Response.write "&del="
	Response.write del
	Response.write "&S2="
	Response.write S2
	Response.write "&G1="
	Response.write G1
	Response.write "&G2="
	Response.write G2
	Response.write "&D="
	Response.write D
	Response.write "&q="
	Response.write q
	Response.write "&F1="
	Response.write F1
	Response.write "&F2="
	Response.write F2
	Response.write "&E="
	Response.write E
	Response.write "&F="
	Response.write F
	Response.write "&C1="
	Response.write C1
	Response.write "&C2="
	Response.write C2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&P1="
	Response.write P1
	Response.write "&P2="
	Response.write P2
	Response.write "&J1="
	Response.write J1
	Response.write "&J2="
	Response.write J2
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write """ "
	if page_count=50 then
		Response.write "selected"
	end if
	Response.write ">每页显示50条</option>" & vbcrlf & "                  <option value=""recvList.asp?page_count=100&currPage="
	Response.write  currPage
	Response.write "&A2="
	Response.write A2
	Response.write "&A1="
	Response.write A1
	Response.write "&person="
	Response.write personid
	Response.write "&company="
	Response.write companyid
	Response.write "&S1="
	Response.write S1
	Response.write "&del="
	Response.write del
	Response.write "&S2="
	Response.write S2
	Response.write "&G1="
	Response.write G1
	Response.write "&G2="
	Response.write G2
	Response.write "&D="
	Response.write D
	Response.write "&q="
	Response.write q
	Response.write "&F1="
	Response.write F1
	Response.write "&F2="
	Response.write F2
	Response.write "&E="
	Response.write E
	Response.write "&F="
	Response.write F
	Response.write "&C1="
	Response.write C1
	Response.write "&C2="
	Response.write C2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&P1="
	Response.write P1
	Response.write "&P2="
	Response.write P2
	Response.write "&J1="
	Response.write J1
	Response.write "&J2="
	Response.write J2
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write """ "
	if page_count=100 then
		Response.write "selected"
	end if
	Response.write ">每页显示100条</option>" & vbcrlf & "                  <option value=""recvList.asp?page_count=200&currPage="
	Response.write  currPage
	Response.write "&A2="
	Response.write A2
	Response.write "&A1="
	Response.write A1
	Response.write "&person="
	Response.write personid
	Response.write "&company="
	Response.write companyid
	Response.write "&S1="
	Response.write S1
	Response.write "&del="
	Response.write del
	Response.write "&S2="
	Response.write S2
	Response.write "&G1="
	Response.write G1
	Response.write "&G2="
	Response.write G2
	Response.write "&D="
	Response.write D
	Response.write "&q="
	Response.write q
	Response.write "&F1="
	Response.write F1
	Response.write "&F2="
	Response.write F2
	Response.write "&E="
	Response.write E
	Response.write "&F="
	Response.write F
	Response.write "&C1="
	Response.write C1
	Response.write "&C2="
	Response.write C2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&P1="
	Response.write P1
	Response.write "&P2="
	Response.write P2
	Response.write "&J1="
	Response.write J1
	Response.write "&J2="
	Response.write J2
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write """ "
	if page_count=200 then
		Response.write "selected"
	end if
	Response.write ">每页显示200条</option>" & vbcrlf & "                </select>" & vbcrlf & "              </div></td>" & vbcrlf & "          </tr>" & vbcrlf & "        "
	Dim sqlcount
	sqlcount="select count(*) from email_recv_list where 1=1 "&Str_Result2
	set rscount=conn.execute(sqlcount)
	recCount=rscount(0)
	rscount.close
	PageCount=recCount \ page_count
	if recCount mod page_count then PageCount=PageCount+1
	PageCount=recCount \ page_count
	if CurrPage>PageCount then CurrPage=PageCount
	if CurrPage<1 then CurrPage=1
	if currpage=pagecount then
		intcount=recCount-(pagecount-1)*page_count
'if currpage=pagecount then
	else
		intcount=page_count
	end if
	set rs=server.CreateObject("adodb.recordset")
	sql="select ord,addcate,sendMail,title,sendtime,isRead,isAccess from ("&_
	"  select top "&page_count&" ord,addcate,sendMail,title,sendtime,isRead,isAccess from email_recv_list where ord in ("&_
	"          select top "&intcount&" ord from email_recv_list where ord in ("&_
	"                  select top "&page_count*CurrPage&" ord from email_recv_list where 1=1 "&Str_Result2&" order by sendtime desc,ord desc ) "&_
	"           order by sendtime asc,ord asc ) "&_
	"   order by sendtime desc,ord desc "&_
	") a "
	rs.open sql,conn,3,1
	CALL InitTempTable("email_recv_list",sql,"ord","cateid",77)
	if rs.RecordCount<=0 then
		Response.write "<tr><td  align='center' colspan='10'  class='gray' height='800'>没有日志记录！</td></tr>"
		Response.write "<table width='100%' border='0' cellpadding='0' cellspacing='0' ><tr><td ><br><br>&nbsp;&nbsp;<b>温馨提示：</b> 列表中“发送时间”显示的是邮件发送服务器所在时区时间， 邮箱中显示的时间是邮件接收服务器所在时区时间。</td></tr></table>"
	else
		do until rs.eof
			ord=rs("ord")
			addcate=rs("addcate")
			sendMail=rs("sendMail")
			title=rs("title")
			sendtime=rs("sendtime")
			isRead=rs("isRead")
			if isRead="" then isRead=0
			Response.write "" & vbcrlf & "          <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "            <td align=""center""><input name=""selectid"" type=""checkbox"" id=""selectid"" value="""
			Response.write rs("ord")
			Response.write """></td>" & vbcrlf & "            "
			Customer="-"
			Response.write """></td>" & vbcrlf & "            "
			CustomerJob="-"
			Response.write """></td>" & vbcrlf & "            "
			CustomerSource="-"
			Response.write """></td>" & vbcrlf & "            "
			CustomerType="-"
			Response.write """></td>" & vbcrlf & "            "
			company=""
			cateid=0
			share=0
			set rsCustomer=server.CreateObject("adodb.recordset")
			sqlCustomer="select p.ord ,p.name as clictname,p.job as clictjob,t.name,t.sort3,t.ord as company,t.cateid,t.share from person p left join tel t on t.ord=p.company and t.del=1 where p.del=1 and p.email='"&sendMail&"' union all select e.ord,e.clictname,e.clictjob,t.name,t.sort3,t.ord,t.cateid,t.share from email_Person e left join tel t on t.ord=e.company and t.del=1 where e.del=1 and e.clictEmail='"&sendMail&"' union all select 0,'','',name,sort3,ord,cateid,share from tel where del=1 and email='"&sendMail&"'"
			rsCustomer.Open sqlCustomer,conn,3,1
			if not rsCustomer.EOF then
				Customer=rsCustomer("clictname")
				CustomerJob=rsCustomer("clictjob")
				CustomerSource=rsCustomer("name")
				CustomerType=rsCustomer("sort3")
				company=rsCustomer("company")
				cateid=rsCustomer("cateid")
				share=rsCustomer("share")
			end if
			rsCustomer.Close()
			set rsCustomer=nothing
			If isnull(share) Or share="" Then share=0
			Response.write "" & vbcrlf & "            <td>"
			Response.write Customer
			Response.write "</td>" & vbcrlf & "            <td>"
			Response.write CustomerJob
			Response.write "</td>" & vbcrlf & "            <td>" & vbcrlf & "            "
			if CustomerType="1" then
				sqlQx_list_intro="select qx_open,qx_intro FROM power where sort1=1 and sort2=1 and ord="&session("personzbintel2007") &""
				sqlQx_intro="select qx_open,qx_intro FROM power where sort1=1 and sort2=14 and ord="&session("personzbintel2007") &""
				strfolder="work"
			Else
				sqlQx_list_intro="select qx_open,qx_intro FROM power where sort1=26 and sort2=1 and ord="&session("personzbintel2007") &""
				sqlQx_intro="select qx_open,qx_intro FROM power where sort1=26 and sort2=14 and ord="&session("personzbintel2007") &""
				strfolder="work2"
			end if
			Listflag=IsPermission(sqlQx_list_intro,cateid)
			flag=IsPermission(sqlQx_intro,cateid)
			If Listflag Or share=1 Or InStr(","&Replace(share," ","")&",",","&session("personzbintel2007")&",") Then
				if flag And CustomerSource<>"-" then
					Response.write "" & vbcrlf & "                                     <a href=""###"" onclick=""javascript:window.open('../"
					Response.write strfolder
					Response.write "/content.asp?ord="
					Response.write pwurl(company)
					Response.write "','emailres','width=' + 1000 + ',height=' + 700 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=102,top=102')"" title=""点击可查看详情"">"
					Response.write pwurl(company)
					Response.write CustomerSource
					Response.write "</a>" & vbcrlf & "                                 "
				else
					Response.write CustomerSource
				end if
			end if
			Response.write "" & vbcrlf & "            </td>" & vbcrlf & "            <td height=""28"" ><div align=""center"">"
			Response.write sendMail
			Response.write "</div></td>" & vbcrlf & "            <td height=""28""><div align=""left"" id=""Access"
			Response.write ord
			Response.write """><a href=""javascript:void(0)"" onClick=""javascript:window.open('email_content.asp?action=recv&ord="
			Response.write pwurl(ord)
			Response.write "&isRead="
			Response.write isRead
			Response.write "','newmail','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=110,top=110');return false;"" onMouseOver=""window.status='none';return true;""  title=""点击可查看此邮件详情"">" & vbcrlf & "                "
			Response.write isRead
			if isRead=0 then Response.write("<strong>")
			Response.write (title)
			if isRead=0 then Response.write("</strong>")
			Response.write "" & vbcrlf & "                </a>" & vbcrlf & "                "
			if rs("isAccess")="1" then
				set rs1=server.CreateObject("adodb.recordset")
				sql1="select Access_url from email_recv_Access where del=1 and mailType=2 and email_ord="&ord&""
				rs1.open sql1,conn,3,1
				if not rs1.eof then
					do while not rs1.eof
						Response.write("<a href='"&rs1("Access_url")&"' title='下载附件'><img src='img/attachment.gif' style='border: none;' alt='此邮件存在附件'/></a>")
						rs1.movenext
					loop
				else
					Response.write("<img src='img/attachment.gif' style='border: none;' alt='此邮件存在附件'/>附件未下载")
				end if
				rs1.close
			end if
			Response.write "" & vbcrlf & "              </div></td>" & vbcrlf & "            <td width=""15%""><div align=""center"">"
			Response.write sendtime
			Response.write "</div></td>" & vbcrlf & "            "
			if addcate<>"" then
				set rs7=server.CreateObject("adodb.recordset")
				sql7="select name from gate where ord="&addcate&""
				rs7.open sql7,conn,3,1
				dim cateid
				If rs7.eof =  False then
					cateid=rs7("name")
				end if
				rs7.close
				set rs7=nothing
			end if
			Response.write "" & vbcrlf & "            <td width=""15%""><div align=""center"">"
			Response.write cateid
			Response.write "</div></td>" & vbcrlf & "            <td width=""17%"" class=""func""><div align=""center"">" & vbcrlf & "                "
			if open_77_13=1 and open_77_19<>1  then
				Response.write "<input  name=submit2 type=""button"" class=""anybutton"" onClick=""javascript:window.open('../email/index.asp?email="
				Response.write trim(sendMail)
				Response.write "','newsSendemail','width=' + 900 + ',height=' + 800 + ',fullscreen =no,scrollbars=0,toolbar=0, status=no,resizable=1,location=no,menubar=no,menubar=no,left=200,top=100')""   value=""单发"">"
				Response.write trim(sendMail)
			end if
			if open_77_3=3 or CheckPurview(intro_77_3,trim(addcate))=True then
				Response.write "<input  name=submit2 type=""button"" class=""anybutton""   onClick=""if(!confirm('确认删除吗？')){return false;}else{window.location.href='delRecv.asp?ord="
				Response.write pwurl(ord)
				Response.write "&CurrPage="
				Response.write CurrPage
				Response.write "&page_count="
				Response.write page_count
				Response.write "&A2="
				Response.write A2
				Response.write "&A1="
				Response.write A1
				Response.write "&person="
				Response.write personid
				Response.write "&company="
				Response.write companyid
				Response.write "&S1="
				Response.write S1
				Response.write "&del="
				Response.write del
				Response.write "&S2="
				Response.write S2
				Response.write "&G1="
				Response.write G1
				Response.write "&G2="
				Response.write G2
				Response.write "&D="
				Response.write D
				Response.write "&q="
				Response.write q
				Response.write "&F1="
				Response.write F1
				Response.write "&F2="
				Response.write F2
				Response.write "&E="
				Response.write E
				Response.write "&F="
				Response.write F
				Response.write "&C1="
				Response.write C1
				Response.write "&C2="
				Response.write C2
				Response.write "&W1="
				Response.write W1
				Response.write "&W2="
				Response.write W2
				Response.write "&W3="
				Response.write W3
				Response.write "&P1="
				Response.write P1
				Response.write "&P2="
				Response.write P2
				Response.write "&J1="
				Response.write J1
				Response.write "&J2="
				Response.write J2
				Response.write "&ret="
				Response.write m1
				Response.write "&ret2="
				Response.write m2
				Response.write "';}""  value=""删除"">"
			end if
			Response.write "" & vbcrlf & "              </div></td>" & vbcrlf & "          </tr>" & vbcrlf & "          "
			rs.movenext
		loop
		Response.write "" & vbcrlf & "        </table></td>" & vbcrlf & "    </tr>" & vbcrlf & "    <tr>" & vbcrlf & "      <td  class=""page""><table width=""100%"" border=""0"" align=""center"">" & vbcrlf & "          <tr>" & vbcrlf & "            <td width=""12%"" height=""30"" valign=""center"" align=""center"">全选" & vbcrlf & "              <input name=""chkall"" type=""checkbox"" id=""chkall"" value=""all"" onclick=""mm(this.form)"" /></td>" & vbcrlf & "            <td width=""38%"" valign=""top"">"
		if open_77_13=1 and open_77_19<>1  then
			Response.write "" & vbcrlf & "              <input  name=""submit22"" type=""submit"" class=""anybutton"" style=""cursor:hand""   onClick=""submit3();"" value=""批量发送"">" & vbcrlf & "              "
		end if
		if open_77_3=3 or open_77_3=1  Then
			Response.write "" & vbcrlf & "              <input  name=submit2233 type=""submit"" onClick=""if(confirm('确认批量删除？')){submit1();}"" style=""cursor:hand"" class=""anybutton""  value=""批量删除"">" & vbcrlf & "              "
		end if
		if open_85_13<>0 then
			Response.write "<input  name=""submit22"" type=""submit"" class=""anybutton"" style=""cursor:hand""   onClick=""if(confirm('确认批量转为简历？')){submit6();}"" value=""邮件转简历"">"
		end if
		Response.write "</td>" & vbcrlf & "            <td width=""50%"" valign=""top""><div align=""right""> <span class=""black"">"
		Response.write recCount
		Response.write "个 | "
		Response.write currpage
		Response.write "/"
		Response.write PageCount
		Response.write "页 | &nbsp;"
		Response.write page_count
		Response.write "条信息/页</span>&nbsp;" & vbcrlf & "                <input   name=""currpage""  type=text onpropertychange=""formatData(this,'int');"" maxlength=8 onkeyup=""checkDot('currpage',0,8)"" size=3  >" & vbcrlf & "                &nbsp;" & vbcrlf & "                <input type=""submit"" name=""Submit422"" onClick=""submit5()"" value=""跳转""  class=""anybutton2""/> "& vbcrlf &           "      &nbsp; "& vbcrlf &      "           "
		if currpage=1 then
			Response.write "" & vbcrlf & "                <input type=""button"" name=""Submit4"" value=""首页""  class=""page""/>" & vbcrlf & "                <input type=""button"" name=""Submit42"" value=""上一页""  class=""page""/>" & vbcrlf & "                "
		else
			Response.write "" & vbcrlf & "                <input type=""button"" name=""Submit4"" value=""首页""   class=""page"" onClick=""window.location.href='recvList.asp?page_count="
			Response.write page_count
			Response.write "&currPage=1&A2="
			Response.write A2
			Response.write "&A1="
			Response.write A1
			Response.write "&person="
			Response.write personid
			Response.write "&company="
			Response.write companyid
			Response.write "&S1="
			Response.write S1
			Response.write "&del="
			Response.write del
			Response.write "&S2="
			Response.write S2
			Response.write "&G1="
			Response.write G1
			Response.write "&G2="
			Response.write G2
			Response.write "&D="
			Response.write D
			Response.write "&q="
			Response.write q
			Response.write "&F1="
			Response.write F1
			Response.write "&F2="
			Response.write F2
			Response.write "&E="
			Response.write E
			Response.write "&F="
			Response.write F
			Response.write "&C1="
			Response.write C1
			Response.write "&C2="
			Response.write C2
			Response.write "&W1="
			Response.write W1
			Response.write "&W2="
			Response.write W2
			Response.write "&W3="
			Response.write W3
			Response.write "&P1="
			Response.write P1
			Response.write "&P2="
			Response.write P2
			Response.write "&J1="
			Response.write J1
			Response.write "&J2="
			Response.write J2
			Response.write "&ret="
			Response.write m1
			Response.write "&ret2="
			Response.write m2
			Response.write "'""/>" & vbcrlf & "                <input type=""button"" name=""Submit42"" value=""上一页""  onClick=""window.location.href='recvList.asp?page_count="
			Response.write page_count
			Response.write "&currPage="
			Response.write  currpage -1
			Response.write "&currPage="
			Response.write "&A2="
			Response.write A2
			Response.write "&A1="
			Response.write A1
			Response.write "&person="
			Response.write personid
			Response.write "&company="
			Response.write companyid
			Response.write "&S1="
			Response.write S1
			Response.write "&del="
			Response.write del
			Response.write "&S2="
			Response.write S2
			Response.write "&G1="
			Response.write G1
			Response.write "&G2="
			Response.write G2
			Response.write "&D="
			Response.write D
			Response.write "&q="
			Response.write q
			Response.write "&F1="
			Response.write F1
			Response.write "&F2="
			Response.write F2
			Response.write "&E="
			Response.write E
			Response.write "&F="
			Response.write F
			Response.write "&C1="
			Response.write C1
			Response.write "&C2="
			Response.write C2
			Response.write "&W1="
			Response.write W1
			Response.write "&W2="
			Response.write W2
			Response.write "&W3="
			Response.write W3
			Response.write "&P1="
			Response.write P1
			Response.write "&P2="
			Response.write P2
			Response.write "&J1="
			Response.write J1
			Response.write "&J2="
			Response.write J2
			Response.write "&ret="
			Response.write m1
			Response.write "&ret2="
			Response.write m2
			Response.write "'"" class=""page""/>" & vbcrlf & "                "
		end if
		if currpage=PageCount then
			Response.write "" & vbcrlf & "                <input type=""button"" name=""Submit"" value=""下一页""  class=""page""/>" & vbcrlf & "                <input type=""button"" name=""Submit44"" value=""尾页""  class=""page""/>" & vbcrlf & "                "
		else
			Response.write "" & vbcrlf & "                <input type=""button"" name=""Submit43"" value=""下一页""  onClick=""window.location.href='recvList.asp?page_count="
			Response.write page_count
			Response.write "&currPage="
			Response.write  currpage + 1
			Response.write "&currPage="
			Response.write "&A2="
			Response.write A2
			Response.write "&A1="
			Response.write A1
			Response.write "&person="
			Response.write personid
			Response.write "&company="
			Response.write companyid
			Response.write "&S1="
			Response.write S1
			Response.write "&del="
			Response.write del
			Response.write "&S2="
			Response.write S2
			Response.write "&G1="
			Response.write G1
			Response.write "&G2="
			Response.write G2
			Response.write "&D="
			Response.write D
			Response.write "&q="
			Response.write q
			Response.write "&F1="
			Response.write F1
			Response.write "&F2="
			Response.write F2
			Response.write "&E="
			Response.write E
			Response.write "&F="
			Response.write F
			Response.write "&C1="
			Response.write C1
			Response.write "&C2="
			Response.write C2
			Response.write "&W1="
			Response.write W1
			Response.write "&W2="
			Response.write W2
			Response.write "&W3="
			Response.write W3
			Response.write "&P1="
			Response.write P1
			Response.write "&P2="
			Response.write P2
			Response.write "&J1="
			Response.write J1
			Response.write "&J2="
			Response.write J2
			Response.write "&ret="
			Response.write m1
			Response.write "&ret2="
			Response.write m2
			Response.write "'"" class=""page""/>" & vbcrlf & "                <input type=""button"" name=""Submit43"" value=""尾页""  onClick=""window.location.href='recvList.asp?currPage="
			Response.write  PageCount
			Response.write "&A2="
			Response.write A2
			Response.write "&A1="
			Response.write A1
			Response.write "&person="
			Response.write personid
			Response.write "&company="
			Response.write companyid
			Response.write "&S1="
			Response.write S1
			Response.write "&del="
			Response.write del
			Response.write "&S2="
			Response.write S2
			Response.write "&G1="
			Response.write G1
			Response.write "&G2="
			Response.write G2
			Response.write "&D="
			Response.write D
			Response.write "&q="
			Response.write q
			Response.write "&F1="
			Response.write F1
			Response.write "&F2="
			Response.write F2
			Response.write "&E="
			Response.write E
			Response.write "&F="
			Response.write F
			Response.write "&C1="
			Response.write C1
			Response.write "&C2="
			Response.write C2
			Response.write "&W1="
			Response.write W1
			Response.write "&W2="
			Response.write W2
			Response.write "&W3="
			Response.write W3
			Response.write "&P1="
			Response.write P1
			Response.write "&P2="
			Response.write P2
			Response.write "&J1="
			Response.write J1
			Response.write "&J2="
			Response.write J2
			Response.write "&ret="
			Response.write m1
			Response.write "&ret2="
			Response.write m2
			Response.write "'"" class=""page""/>" & vbcrlf & "                "
		end if
		Response.write "" & vbcrlf & "              </div></td>" & vbcrlf & "          </tr>" & vbcrlf & "               <tr><td colspan=""3"" height=""50"">&nbsp;&nbsp;<b>温馨提示：</b> 列表中“发送时间”显示的是邮件发送服务器所在时区时间， 邮箱中显示的时间是邮件接收服务器所在时区时间。</td></tr>" & vbcrlf & "        </table>" & vbcrlf & "               "
	end if
	rs.close
	set rs=nothing
	Response.write "" & vbcrlf & "" & vbcrlf & "<script language=javascript>" & vbcrlf & "function test()" & vbcrlf & "{" & vbcrlf & "  if(!confirm('确认删除吗？')) return false;" & vbcrlf & "}" & vbcrlf & "function reloadOpener()" & vbcrlf & "{" & vbcrlf & "    "
	if qf="" then
		Response.write "" & vbcrlf & "     try" & vbcrlf & "     {" & vbcrlf & "       window.parent.window.location.reload();" & vbcrlf & " }" & vbcrlf & "       catch(e1)" & vbcrlf & "       {}" & vbcrlf & "      "
	end if
	Response.write "" & vbcrlf & "}" & vbcrlf & "function mm(form) " & vbcrlf & "{ " & vbcrlf & "        ///定义函数checkall,参数为form " & vbcrlf & " ///循环,form.elements.length得到表单里的控件个数" & vbcrlf & "        for (var i=0;i<form.elements.length;i++)" & vbcrlf & "        {" & vbcrlf & "               ///把表单里的内容依依付给e这个变量 " & vbcrlf & "             var e = form.elements[i]; " & vbcrlf & "            if (e.name != 'chkall') " & vbcrlf & "                e.checked = form.chkall.checked; " & vbcrlf & "       } " & vbcrlf & "} " & vbcrlf & "</script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"">" & vbcrlf & "<!--" & vbcrlf & "" & vbcrlf & "function submit1()" & vbcrlf &"{" & vbcrlf & "document.all.date.action = ""delallRecv.asp?complete=1&type=1&page_count="
	Response.write page_count
	Response.write "&currPage="
	Response.write currpage
	Response.write "&A2="
	Response.write A2
	Response.write "&A1="
	Response.write A1
	Response.write "&person="
	Response.write personid
	Response.write "&company="
	Response.write companyid
	Response.write "&S1="
	Response.write S1
	Response.write "&del="
	Response.write del
	Response.write "&S2="
	Response.write S2
	Response.write "&G1="
	Response.write G1
	Response.write "&G2="
	Response.write G2
	Response.write "&D="
	Response.write D
	Response.write "&q="
	Response.write q
	Response.write "&F1="
	Response.write F1
	Response.write "&F2="
	Response.write F2
	Response.write "&E="
	Response.write E
	Response.write "&F="
	Response.write F
	Response.write "&C1="
	Response.write C1
	Response.write "&C2="
	Response.write C2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&P1="
	Response.write P1
	Response.write "&P2="
	Response.write P2
	Response.write "&J1="
	Response.write J1
	Response.write "&J2="
	Response.write J2
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write """;" & vbcrlf & "//reloadOpener();" & vbcrlf & "}" & vbcrlf & "function submit3()" & vbcrlf & "{" & vbcrlf & "document.all.date.action = ""sendAllRecv.asp?type=1&currPage="
	Response.write currPage
	Response.write "&page_count="
	Response.write page_count
	Response.write """;" & vbcrlf & "}" & vbcrlf & "function submit4()" & vbcrlf & "{" & vbcrlf & "document.all.date.action = ""recvList.asp?page_count="
	Response.write page_count
	Response.write """;" & vbcrlf & "}" & vbcrlf & "function submit5()" & vbcrlf & "{" & vbcrlf & "document.all.date.action = ""recvList.asp?page_count="
	Response.write page_count
	Response.write "&A2="
	Response.write A2
	Response.write "&A1="
	Response.write A1
	Response.write "&person="
	Response.write personid
	Response.write "&company="
	Response.write companyid
	Response.write "&S1="
	Response.write S1
	Response.write "&del="
	Response.write del
	Response.write "&S2="
	Response.write S2
	Response.write "&G1="
	Response.write G1
	Response.write "&G2="
	Response.write G2
	Response.write "&D="
	Response.write D
	Response.write "&q="
	Response.write q
	Response.write "&F1="
	Response.write F1
	Response.write "&F2="
	Response.write F2
	Response.write "&E="
	Response.write E
	Response.write "&F="
	Response.write F
	Response.write "&C1="
	Response.write C1
	Response.write "&C2="
	Response.write C2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&P1="
	Response.write P1
	Response.write "&P2="
	Response.write P2
	Response.write "&J1="
	Response.write J1
	Response.write "&J2="
	Response.write J2
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write """;" & vbcrlf & "}" & vbcrlf & "function submit6()" & vbcrlf & "{" & vbcrlf & "document.all.date.action = ""emailToResume.asp?page_count="
	Response.write page_count
	Response.write """;" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & "</script>" & vbcrlf & "      </td>" & vbcrlf & "    </tr>" & vbcrlf & "</table>" & vbcrlf & "</form>" & vbcrlf & ""
	'Response.write page_count
	action1="邮件接收记录"
	call close_list(1)
	Response.write "" & vbcrlf & "</body>" & vbcrlf & "</html>"
	
%>
