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
		Response.write "<!Doctype html><html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""X-UA-Compatible"" content =""IE=edge,chrome=1"">" & vbcrlf & "<meta name=""vs_targetSchema"" content=""http://schemas.microsoft.com/intellisense/ie5""/>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<meta name=""format-detection"" content=""telephone=no"">" & vbcrlf & ""
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
	
	Class CommSPConfig
		Public con
		Public bill
		Public moneyLimit
		Public useHL
		Public useBT
		Public clsID
		Public tabName
		Public keyField
		Public addField
		Public addField2
		Public sprField
		Public stateField
		Public stateOK
		Public stateDai
		Public stateShen
		Public stateFou
		Public moneyField
		Public swicthField
		Public name
		Public remind_sp
		Public remind_sp_sort
		Public sp
		Public saveBillMoneyField
		Public saveBillMoneySub
		Public titleField
		Public isExtract
		Public Enable
		Public Sub Class_Initialize()
			Me.moneyLimit = True
			Me.useHL = False
			Me.useBT = False
			Me.clsID = 0
			Me.keyField = "ord"
			Me.addField="addcate"
			Me.addField2 = ""
			Me.sprField = "cateid_sp"
			Me.sp="sp"
			Me.stateField = "status"
			Me.stateOK = 0
			Me.stateDai = 1
			Me.stateShen = 2
			Me.stateFou = 4
			Me.saveBillMoneyField = ""
			Me.saveBillMoneySub = ""
			Me.isExtract = False
			Me.Enable = true
			Me.remind_sp = False
			me.remind_sp_sort = 0
		end sub
		Public Sub Init(bill)
			dim s
			Me.bill = bill
			on error resume next
			s = conn.connectionstring
			if err.number = 0 then
				set Me.con = conn
			else
				set Me.con = cn
			end if
			On Error GoTo 0
			Me.titleField = "title"
			Select Case Me.bill
			Case "tel"
			Me.tabName = "tel"
			Me.addField="cateadd"
			Me.clsId = 92
			Me.name = "客户"
			Me.sp = "sp_qualifications"
			Me.sprField="cateid_sp_qualifications"
			Me.stateField="status_sp_qualifications"
			Me.titleField = "name"
			Case "gys"
			Me.tabName = "tel"
			Me.addField="cateid"
			Me.clsId = 93
			Me.name = "供应商"
			Me.sp = "sp_qualifications"
			Me.sprField="cateid_sp_qualifications"
			Me.stateField="status_sp_qualifications"
			Me.titleField = "name"
			Case "chance"
			Me.tabName = "chance"
			Me.moneyField = "money1"
			Me.swicthField = "trade"
			Me.addField="cateid"
			Me.clsId = 25
			Me.name = "项目"
			Me.stateField = "del"
			Me.stateOK = 1
			Me.stateDai = 3
			Me.stateShen = 3
			Me.stateFou = 3
			Me.isExtract = True
			Case "contract"
			Me.tabName = "contract"
			Me.moneyField = "money1"
			Me.swicthField = "sort"
			Me.addField="addcate"
			Me.addField2="cateid"
			Me.clsId = 2
			Me.name = "合同"
			Me.stateField = "del"
			Me.stateOK = 1
			Me.stateDai = 3
			Me.stateShen = 3
			Me.stateFou = 3
			Me.isExtract = True
			Case "yugou"
			Me.tabName = "caigou_yg"
			Me.keyField = "id"
			Me.moneyField = "money1"
			Me.swicthField = "sort1"
			Me.addField="cateid"
			Me.clsId = 26
			Me.name = "预购"
			Me.stateField = "status"
			Me.stateOK = 0
			Me.stateDai = 1
			Me.stateShen = 2
			Me.stateFou = -1
			Me.stateShen = 2
			Me.isExtract = False
			Case "caigou"
			Me.tabName = "caigou"
			Me.moneyField = "money1"
			Me.swicthField = "sort"
			Me.addField="cateid"
			Me.clsId = 3
			Me.name = "采购"
			Me.stateField = "del"
			Me.stateOK = 1
			Me.stateDai = 3
			Me.stateShen = 3
			Me.stateFou = 3
			Me.isExtract = True
			Me.remind_sp = True
			Me.remind_sp_sort = 16
			Case "contractth"
			Me.tabName = "contractth"
			Me.moneyField = "money1"
			Me.addField="addcate"
			Me.clsId = 41
			Me.name = "销售退货"
			Me.stateField = "del"
			Me.stateOK = 1
			Me.stateDai = 3
			Me.stateShen = 3
			Me.stateFou = 3
			Me.isExtract = True
			Case "wages"
			Me.moneyLimit = False
			Me.tabName = "wages"
			Me.keyField = "id"
			Me.addField="cateid"
			Me.clsId = 10
			Me.name = "工资"
			Me.stateField = "complete2"
			Me.stateOK = 1
			Me.stateDai = 2
			Me.stateShen = 3
			Me.stateFou = -1
			Me.stateShen = 3
			Me.Enable = ZBRuntime.MC(226100)
			Case "paybx"
			Me.tabName = "paybx"
			Me.moneyField = "dkmoney"
			Me.addField="addcate"
			Me.addField2="cateid"
			Me.keyField = "id"
			Me.clsId = 4
			Me.name = "报销"
			Me.stateField = "complete"
			Me.stateOK = 3
			Me.stateDai = 0
			Me.stateShen = 1
			Me.stateFou = 2
			Me.sp="sp_id"
			Me.swicthField = "bxtype"
			Case "payout" :
			Me.tabName = "payout"
			Me.moneyField = "money1"
			Me.addField="cateid"
			Me.clsId = 50
			Me.name = "付款"
			Me.stateField = "status_sp"
			Me.stateOK = 0
			Me.stateDai = 2
			Me.stateShen = 3
			Me.stateFou = 4
			Me.swicthField = "pay"
			Me.isExtract = True
			Me.remind_sp = True
			Me.remind_sp_sort = 50
			Case "bankout" :
			Me.tabName = "bankout2"
			Me.moneyField = "money1"
			Me.addField="cateid"
			Me.keyField = "id"
			Me.clsId = 51
			Me.name = "预付款"
			Me.stateField = "status_sp"
			Me.stateOK = 0
			Me.stateDai = 2
			Me.stateShen = 3
			Me.stateFou = 4
			Me.isExtract = True
			Me.remind_sp = True
			Me.remind_sp_sort = 206
			Case "budget"
			Me.tabName = "budget"
			Me.moneyField = "money1"
			Me.addField="creator"
			Me.clsId = 62
			Me.name = "预算"
			Me.stateFou = 3
			Case "document"
			Me.tabName = "document"
			Me.keyField = "id"
			Me.clsId = 78
			Me.name = "文档"
			Me.stateField = "spFlag"
			Me.stateOK = 1
			Me.stateDai = 2
			Me.stateShen = 3
			Me.stateFou = -1
			Me.stateShen = 3
			Me.swicthField = "sort"
			Case "paysq"
			Me.tabName = "paysq"
			Me.moneyField = "sqmoney"
			Me.keyField = "id"
			Me.addField="addcateid"
			Me.addField2="cateid"
			Me.sprField = "cateid_sp"
			Me.clsId = 7
			Me.name = "费用申请"
			Me.stateField = "complete"
			Me.stateOK = 1
			Me.stateDai = 0
			Me.stateShen = 2
			Me.stateFou = 3
			Me.sp="sp"
			Me.saveBillMoneyField = "spmoney"
			Me.isExtract = True
			Me.remind_sp = True
			Me.remind_sp_sort = 40
			Case "payjk"
			Me.tabName = "payjk"
			Me.moneyField = "allmoney"
			Me.addField="addcate"
			Me.addField2="sorce2"
			Me.keyField = "id"
			Me.sprField = "gate_sp"
			Me.clsId = 6
			Me.name = "借款"
			Me.stateField = "spstate"
			Me.stateOK = 4
			Me.stateDai = 5
			Me.stateShen = 2
			Me.stateFou = 3
			Me.sp="sp_id"
			Me.saveBillMoneyField = "spmoney"
			Me.isExtract = True
			Case "payfh"
			Me.tabName = "pay"
			Me.moneyField = "money1"
			Me.keyField = "ord"
			Me.addField="addcate"
			Me.addField2="cateid"
			Me.sprField = "cateid_sp"
			Me.clsId = 5
			Me.name = "返还"
			Me.stateField = "complete"
			Me.stateOK = 8
			Me.stateDai = 11
			Me.stateShen = 7
			Me.stateFou = 12
			Me.sp="sp"
			Me.saveBillMoneyField = "money2"
			Me.isExtract = True
			Me.remind_sp = True
			Me.remind_sp_sort = 43
			Case "maintain"
			Me.tabName = "maintain"
			Me.clsId = 91
			Me.name = "养护"
			Me.isExtract = True
			Case "BOM_Structure_Info"
			Me.tabName = "BOM_Structure_Info"
			Me.sp = "sp"
			Me.sprField="cateid_sp"
			Me.stateField="status_sp"
			Me.titleField = "title"
			Me.clsId = 8040
			Me.stateFou = -1
'Me.clsId = 8040
			Me.name = "组装清单"
			Me.isExtract = True
			Case "Design"
			Me.tabName ="Design"
			Me.keyField = "id"
			Me.addField="creator"
			Me.addField2 = "designer"
			Me.sp = "id_sp"
			Me.sprField="cateid_sp"
			Me.stateField="designstatus"
			Me.stateOK = 8
			Me.stateDai = 7
			Me.stateShen = 7
			Me.stateFou = 9
			Me.titleField = "title"
			Me.clsId = 5029
			Me.name = "设计任务"
			Me.name = "设计任务"
			Me.isExtract = True
			Me.swicthField = "sort1"
			Me.remind_sp = True
			Me.remind_sp_sort = 217
			End Select
		end sub
		Public Sub init_sp(sort1)
			Select Case sort1&""
			Case "2" : Call Init("contract")
			Case "3" : Call Init("caigou")
			Case "4" : Call init("paybx")
			Case "5" : Call init("payfh")
			Case "6" : Call Init("payjk")
			Case "7" : Call Init("paysq")
			Case "25" : Call init("chance")
			Case "26" : Call init("yugou")
			Case "41" : Call Init("contractth")
			Case "50" : Call init("payout")
			Case "51" : Call init("bankout")
			Case "91" : Call Init("maintain")
			Case "92" : Call Init("tel")
			Case "93" : Call Init("gys")
			Case "94" : Call Init("teljf")
			Case "78" : Call Init("document")
			Case "8040" : Call Init("BOM_Structure_Info")
			Case "5029" : Call Init("Design")
			End Select
		end sub
		Public Function billExtract(billID, jg, sp)
			Dim helper
			If jg&"" = "1" and sp&"" = "0" Then
				Select Case Me.bill
				Case "paysq"
				Call savepaysqToJk(billID)
				Case "payjk"
				Me.con.execute("update "& Me.tabName &" set payid=1 where del=1 and id = "& billID)
				Case "chance"
				Me.con.execute("update chancelist set del=1 where chance = "& billID)
				Case "contract"
				Call onAfterContractSPAccess(billID)
				Call callExternalJk("htApprove",billID)
				Case "contractth"
				Call handlePassSp(billID)
				Case "caigou" , "payout" , "bankout"
				Call onAfterSPAccess(Me.con, Me.bill, billID)
				Case "maintain"
				Set helper = CreateReminderHelper(Me.con,68,0)
				Call helper.reloadRemind(True)
				Set helper = Nothing
				End Select
			Elseif jg&"" = "2" Then
				Select Case Me.bill
				Case "chance", "payout"
				Me.con.execute("update "& Me.tabName &" set sp=-1 where ord = "& billID)
'Case "chance", "payout"
				Case "caigou"
				Me.con.execute("update caigou set sp=-1,cateid_sp='',del=3 where ord = "& billID)
'Case "caigou"
				Me.con.execute("update caigoulist set del=3 where caigou = "& billID)
				Me.con.execute("update caigoubz set del=3 where caigou = "& billID)
				Case "contract"
				Call callExternalJk("htApprove",billID)
				case else
				Call onApproveNoPass(Me.con, Me.bill, billID)
				End Select
			elseif jg&""="3" then
				Select Case Me.bill
				Case "contract"
				Me.con.execute("update contract set sp=999999,cateid_sp=0,del=3 where ord = "& billID)
				case "contractth"
				end select
			end if
			If Me.remind_sp = True and (Me.con.execute("select 1 from sp_intro where ord="&billID&" and sort1="&Me.clsId&" ").eof=False or sp>0) Then
				CreateReminderHelper(Me.con,Me.remind_sp_sort,0).appendRemind billID
			end if
		end function
	End Class
	function ApproveIntroLog(conn, BillType, BillID ,ApproveSort, ApproveID, ApproveName , ApproveCateID , result , intro)
		dim Rs , lastID , lastlevel , ApproveSortType , currLevel
		ApproveSortType = 0
		currLevel = 0
		set rs= conn.execute("select isnull(Sptype,-1) as Sptype , gate1 from sp where id="& ApproveID)
'currLevel = 0
		if rs.eof=false then
			ApproveSortType = rs("Sptype").value
			currLevel = rs("gate1").value
		end if
		rs.close
		lastID = 0
		set rs = conn.execute("select top 1 s.sp_id as SpID from sp_intro s where sort1=" & ApproveSort &" and ord=" & BillID &" order by id desc")
		if rs.eof=false then
			lastID = rs("SpID").value
		end if
		rs.close
		lastlevel = 0
		if lastID>0 then
			set rs = conn.execute("select Gate1 as lastlevel from sp where id="& lastID )
			if rs.eof=false then
				lastlevel = rs("lastlevel").value
			end if
			rs.close
			if cdbl(lastlevel)>= cdbl(currLevel) then lastlevel = 0
		end if
		if cdbl(lastlevel)< cdbl(currLevel) then
			dim BillCateID , Creator , inx , Sp_Intro , BillCateName
			BillCateID = 0
			Creator = session("personzbintel2007")
			BillCateName = "业务人员"
			select case BillType
			case 11001:
			BillCateName = "销售人员"
			set rs = conn.execute("select cateid , addcate, cateid_sp from contract where ord="& BillID)
			if rs.eof=false then
				BillCateID = rs("cateid").value
				Creator = rs("addcate").value
				cateid_sp = rs("cateid_sp").value
			end if
			rs.close
			end select
			inx = 0
			set rs = conn.execute("select id, intro , sort1 from sp where Gate2="& ApproveSort &" and isnull(Sptype,-1)="& ApproveSortType &" and gate1>"& lastlevel &" and gate1<="& currLevel &"  order by gate1")
'inx = 0
			while rs.eof=false
				ApproveID = rs("id").value
				ApproveName = rs("sort1").value
				Sp_Intro = Replace(rs("intro").value&"" , " ","")
				if inx<>0 or len(intro)=0 then
					If BillCateID<>"0" and instr(","& Sp_Intro &"," , ","& BillCateID &",")>0 Then
						ApproveCateID=BillCateID
						intro= BillCateName & "默认审批通过"
					ElseIf instr(","& Sp_Intro &"," , ","& Creator &",")>0 Then
						ApproveCateID=Creator
						intro="添加人员默认审批通过"
					ElseIf  instr(","& Sp_Intro &"," , ","& session("personzbintel2007") &",")>0 and inx<>0 Then
						ApproveCateID=session("personzbintel2007")
						intro="当前审批人默认审批通过"
					end if
				end if
				call ApproveLog(conn, BillType, BillID ,ApproveSort, ApproveID, ApproveName , ApproveCateID , result , intro)
				inx = inx + 1
'call ApproveLog(conn, BillType, BillID ,ApproveSort, ApproveID, ApproveName , ApproveCateID , result , intro)
				rs.movenext
			wend
			rs.close
		end if
	end function
	function ApproveLog(conn, BillType, BillID ,ApproveSort, ApproveID, ApproveName , ApproveCateID , result , intro)
		set Rs = server.CreateObject("adodb.recordset")
		Rs.open "select top 0 * from sp_intro",conn,3,2
		Rs.addnew
		Rs("jg")=result
		Rs("intro")=intro
		Rs("date1")=now
		Rs("ord")=BillID
		Rs("sp")=ApproveName
		Rs("cateid")=ApproveCateID
		Rs("sort1")=ApproveSort
		Rs("sp_id")=ApproveID
		rs.update
		rs.close
		set rs = nothing
	end function
	Sub handlePassSp(ord)
		Dim rs
		Dim money_tk
		money_tk = CDbl(cn.execute("select isnull(sum(money1),0) from contractthList where caigou="&ord &" ")(0))
		If money_tk >0 And cn.execute("select count(1) from payout2 where contractth="&ord&" and del=1 ")(0)=0 Then
			Dim date1,area,trade,cateid,cateid2,cateid3,sorce_user3,sorce_user4 , BKPayModel
			BKPayModel = 0
			Set rs = cn.execute("select * from contractth where ord="& ord)
			If rs.eof = False Then
				date1 = rs("date3")
				sorce_user3=rs("addcate2")
				sorce_user4=rs("addcate3")
				area=rs("area")
				trade=rs("trade")
				cateid=rs("cateid")
				cateid2=rs("cateid2")
				cateid3=rs("cateid3")
				BKPayModel = rs("BKPayModel").value
				BZ=rs("BZ")
			end if
			rs.close
			if BKPayModel=1 then
				dim TkNo
				Set rs = cn.execute("exec [erp_getdjbh] 43010,"&session("personzbintel2007")&" ")
				If rs.eof= False Then
					TkNo=rs("cw_code")
				end if
				rs.close
				sql = "select top 0 * from payout2"
				Set Rs = server.CreateObject("adodb.recordset")
				Rs.open sql,cn,3,3
				Rs.addnew
				Rs("BH")=TkNo
				Rs("date1")=date1
				Rs("money1")=money_tk
				Rs("area")=area
				Rs("trade")=trade
				Rs("complete")=1
				Rs("cateid")=cateid
				Rs("cateid2")=cateid2
				Rs("cateid3")=cateid3
				Rs("addcate")=session("personzbintel2007")
				Rs("addcate2")=sorce_user3
				Rs("addcate3")=sorce_user4
				Rs("contractth")=ord
				Rs("date7")=now
				Rs("FromType") = 0
				Rs("del")=1
				Rs("PayBz")=BZ
				rs.update
				payout2ord = GetIdentity("payout2","ord","addcate","")
				if TkNo&""="" or TkNo="编号已满" then
					cn.execute("update payout2 set BH="&payout2ord&" where ord="&payout2ord)
					rs.close
					set rs = nothing
				end if
			end if
		end if
		dim checktax : checktax=0
		if ZBRuntime.MC(23004) then checktax=1 end if
		cn.execute("exec erp_contractTH_AutoInvoice "& session("personzbintel2007") &","& ord &",'"& date1 &"'," & checktax )
		cn.execute("update contractthlist set del=1 where caigou="&ord)
		cn.execute("Update contractthbz set del=1 where contractth="&ord&"")
		cn.execute("exec [dbo].[erp_contract_UpdateTHStatus] 'select distinct contract from contractthlist where caigou="& ord &" and isnull(contract,0)>0 '")
	end sub
	sub onApproveNoPass(con, bill, billID)
		Dim rs ,sql , company , curCate ,money1, ismobile
		curCate = session("personzbintel2007")
		If curCate&"" = "" Then curCate = 0
		Select Case bill
		Case "contractth"
		con.execute("update s2 set s2.HandleStatus =0 from S2_SerialNumberRelation s2 inner join contractthlist tl on s2.Billtype= 62001 and tl.kuoutlist2 = s2.ListID and s2.serialID = tl.serialID where tl.caigou =  " & billID)
		con.execute("update k2 set k2.thnum = case when isnull(k2.thnum,0) - tl.num1<0 then 0 else isnull(k2.thnum,0) - tl.num1 end from kuoutlist2 k2 inner join  (select kuoutlist2 ,sum(num1) num1 from  contractthlist where caigou =  " & billID &" group by kuoutlist2) tl on tl.kuoutlist2 = k2.ID ")
		con.execute("exec [dbo].[erp_contract_UpdateTHStatus] 'select distinct contract from contractthlist where caigou="& billID &" and isnull(contract,0)>0 '")
		end select
	end sub
	Sub savePaybxMoney(ord, money1)
		conn.execute("update paybxlist set money1=pay.money1 from pay where pay.ord=paybxlist.payid and bxid="& ord)
	end sub
	Sub savepaysqToJk(ord)
		Dim rs ,jktitle_length ,spstate, payid, spCount, spIntro, needSpLog
		jktitle_length=conn.execute("select length/2 from syscolumns where id=(select id from sysobjects where name='payjk') and name='title'")(0)
		Dim rsbh ,sqltext ,jkid, jkord, jkSpmoney, jkspid, jkSptitle
		set rsbh = conn.execute("EXEC erp_getdjbh 81,"&session("personzbintel2007"))
		jkid=rsbh(0).value
		rsbh.close
		set rsbh=Nothing
		spstate = 5
		payid = 4
		spCount = 0
		needSpLog = False
		Set rs = conn.execute("select TOP 1 id,sort1,intro from sp WHERE gate2=6 ORDER BY gate1 desc")
		If rs.eof = False Then
			spIntro = replace(rs("intro")&""," ","")
			Dim sq_cateid
			sq_cateid = CDbl(conn.execute("select cateid from paysq where id=" & ord &"")(0))
			If instr(","& spIntro &",", ","& session("personzbintel2007") &",")>0 or instr(","& spIntro &",", ","& sq_cateid &",")>0 Then
				spCount = 0 : needSpLog = True : jkspid = rs("id") : jkSptitle = rs("sort1")
			else
				spCount = 1
			end if
		end if
		rs.close
		set rs = nothing
		If jkspid&"" = "" Then jkspid = 0
		If spCount = 0 Then
			spstate = 1 : payid = 1
		end if
		sqltext="insert into payjk(title,datejk,sorce2,allmoney,spstate,spmoney,payid,bz,date7,sqid,del,addcate,sorce,sorce1,jktype,bh) "&_
		"select left('转费用申请:'+p.title,"& jktitle_length &"),'"&date&"',p.cateid,p.spmoney,"& spstate &",(case "& spCount &" when 0 then p.spmoney when 1 then 0 else p.spmoney end),"& payid &",p.bz,'"&now&"',p.id,1,p.addcateid,g.sorce,g.sorce2,1,'"& jkid &"' "&_
		" from paysq p inner join gate g on g.ord = p.cateid  where p.id = " & ord &" and p.jk=1 and p.complete=1 "
		conn.execute(sqltext)
		If needSpLog Then
			Set rs = conn.execute("select top 1 id, spmoney from payjk where del=1 and addcate='"&session("personzbintel2007")&"' and spstate="& spstate &" and payid="& payid &" and bh='"& jkid &"' and title like '转费用申请:%' order by date7 desc")
			If rs.eof = False Then
				jkord = rs("id") : jkSpmoney = rs("spmoney")
			end if
			rs.close
			set rs = nothing
			If jkord&"" = "" Then jkord = 0
			If jkSpmoney&"" = "" Then jkSpmoney = 0 Else jkSpmoney = CDbl(jkSpmoney)
			conn.execute("insert into sp_intro(jg, intro, date1, ord, sp, cateid, sort1, money1, sp_id) values (1,'添加人员默认审批通过', getdate()," & jkord & ",'" & jkSptitle & "', '" & session("personzbintel2007") & "',6,"& jkSpmoney &"," & jkspid &") ")
		end if
	end sub
	Sub onAfterContractSPAccess(ord)
		Dim money1,moneyRmb,company,date3,baojia,cateid1,cateid2,cateid3,paybackMode,yhmoney,invoiceMode,invoicePlan,invoiceType,plan
		Dim sql,sort2,jfsort,sum_jf,sql7,jf_single,jf,sum_tel,rs,sqltext,sqlStr
		Dim canInvoice
		set rs=server.CreateObject("adodb.recordset")
		sql="select sp,money1,money2,company,date3,cateid_sp,event1,cateid,cateid2,cateid3,sort,paybackMode,invoiceMode,yhmoney,fqhk,invoicePlan,invoicePlanType from contract where ord="& ord &" "
		rs.open sql,conn,1,1
		if Not rs.eof then
			money1=rs("money1")
			moneyRmb=rs("money2")
			company=rs("company")
			date3=rs("date3")
			baojia=rs("event1")
			cateid1=rs("cateid")
			cateid2=rs("cateid2")
			cateid3=rs("cateid3")
			paybackMode=CLng("0" & rs("paybackMode"))
			yhmoney=rs("yhmoney")
			invoiceMode=CLng("0" & rs("invoiceMode"))
			invoicePlan=CLng("0" & rs("invoicePlan"))
			invoiceType=CLng("0" & rs("invoicePlanType"))
			plan = CLng("0" & rs("fqhk"))
			if cateid1 & "" = "" Then cateid1=0
			if cateid2 & "" = "" Then cateid2=0
			if cateid3 & "" = "" Then cateid3=0
			If app.power.existsPowerIntro(7,13,cateid1) Then
				canInvoice = True
			else
				canInvoice = False
			end if
			CreateReminderHelper(conn,151,0).appendRemind ord
			Call getcontent(1,company, ord)
			sql="update contract set sp=0,cateid_sp='',del=1,alt=1 where ord=" & ord & " "
			conn.execute(sql)
			if baojia & "" <> "" then
				sql="Update price set complete=4 where ord=" & baojia & ""
				conn.execute(sql)
			end if
			conn.execute "Update contractlist set del=1 where contract=" & ord &""
			conn.execute "Update contractbz set del=1 where contract=" & ord &""
			if ZBRuntime.MC(18000) and ZBRuntime.MC(18100) then
				conn.execute("exec dbo.erp_auto_produce_CreateManuPlansPre @ContractId="&ord)
			end if
			Call CreateNewPayback(ord,cn)
			if plan="2" Then
				sqltext="update p set complete=1,complete2=2," &_
				"area=c.area,trade=c.trade," & vbcrlf &_
				"cateid=c.cateid,cateid2=c.cateid2,cateid3=c.cateid3," & vbcrlf &_
				"addcate=" & Info.User & ",addcate2=isnull(g.sorce,0),addcate3=isnull(g.sorce2,0)," & vbcrlf &_
				"company=c.company,date4=getdate(),del=1,paybackMode=c.paybackMode " & vbcrlf &_
				"from payback p " & vbcrlf &_
				"inner join contract c on p.contract=c.ord " & vbcrlf &_
				"left join gate g on g.ord=" & Info.User & " " & vbcrlf &_
				"where p.contract = " & ord & " "
				conn.execute sqltext
				sqltext="update plan_hk set del=1 where contract="& ord &" "
'conn.execute sqltext
				conn.execute "update payback set complete=3 where money1=0 and contract ="& ord
			end if
			If plan=2 then
				conn.execute "update payback set complete=3 where money1=0 and contract =" & ord
			end if
			If invoiceMode <> 0 and canInvoice = true Then
				Call AutoCompletePayBackInvoice(cn,invoiceMode,company,invoiceType,ord,yhmoney)
			end if
			call ContractJFHandle(conn , company ,ord, company)
			Call autoSkipSort(company,0,0,8,0,true,false,"合同审批")
			cn.execute("exec autoChangeSort1 " & Info.User & "," & company )
		else
			rs.close
			set rs=nothing
			Exit Sub
		end if
		cn.execute("update contract set del=1,sp=0,cateid_sp=0 where ord=" & ord)
	end sub
	Sub setPayoutMx(ord,caigouord , money1, ismobile,NeedDel)
		dim rs, num_mx, money_mx, money2, yhmoney, sql, cls,sum
		money2=0
		If ismobile = False Then
			Set rs = conn.execute("select isnull(cls,0) cls from payout where ord="& ord)
			If rs.eof = False Then
				cls = rs("cls")
			end if
			rs.close
			set rs = nothing
			If cls&"" = "" Then cls = 0
			Select Case cls
			Case 0 : sql = "select id,ord from caigoulist where caigou="&caigouord
			Case 2 : sql = "select id,productid ord from M_OutOrderlists where outID="&caigouord
			Case 4,5 : sql = "select id,productid ord from M2_OutOrderlists where outID="&caigouord
			End Select
			Set rs=conn.execute(sql)
			While rs.eof = False
				If ismobile Then
					money_mx=app.mobile("mx_"&rs("id"))
					num_mx=app.mobile("num_"&rs("id"))
				else
					money_mx=request("mx_"&rs("id"))
					num_mx=request("num_"&rs("id"))
					sum=cdbl(sum)+cdbl(num_mx)
					num_mx=request("num_"&rs("id"))
				end if
				If num_mx&""<>"" and money_mx&""<>"" Then
					If conn.execute("select top 1 1 from payoutlist where caigoulist="&rs("id")&" and payout="&ord).eof =False Then
						conn.execute ("update payoutlist set money1="& money_mx &",num1="& num_mx &" where caigoulist="&rs("id")&" and payout="&ord)
					else
						conn.execute ("insert into payoutlist (product,caigoulist,payout,money1,num1,del) values ("&rs("ord")&","&rs("id")&","&ord&","& money_mx &","&num_mx&",1)")
					end if
					money2 = cdbl(money2) + cdbl(money_mx)
				else
					if NeedDel then
						If conn.execute("select top 1 1 from payoutlist where caigoulist="&rs("id")&" and payout="&ord).eof =False Then
							conn.execute ("update payoutlist set money1=0,num1=0,del=2 where caigoulist="&rs("id")&" and caigoulist>0 and payout="&ord)
						end if
					end if
				end if
				rs.movenext
			wend
			rs.close
			If (num_mx&""<>"" and money_mx&""<>"") or sum&""<>"" Then
				If ismobile Then
					yhmoney = app.mobile("yhmoney")
				else
					yhmoney = request("yhmoney")
				end if
				If yhmoney&""<>"" Then
					If conn.execute("select top 1 1 from payoutlist where caigoulist=0 and payout="&ord).eof =False Then
						conn.execute ("update payoutlist set money1="& yhmoney &" where caigoulist=0 and payout="&ord)
					else
						conn.execute ("insert into payoutlist (product,caigoulist,payout,money1,del) values (0,0,"&ord&","& yhmoney &",1)")
					end if
					money2 = cdbl(money2) - cdbl(yhmoney)
				end if
				If cdbl(FormatNumber(money2,3,-1,0,0))<>cdbl(FormatNumber(money1,3,-1,0,0)) Then
					canCommit = False
					errStr = "付款明细总额和单据总额不一致"
					Exit Sub
				end if
			end if
		end if
		conn.execute("update payout set money1 = "& money1 &" where ord="&ord)
	end sub
	Sub onAfterSPAccess(con, bill, billID)
		Dim rs ,sql , company , curCate ,money1, ismobile
		curCate = session("personzbintel2007")
		If curCate&"" = "" Then curCate = 0
		Select Case bill
		Case "caigou"
		con.execute("update caigou set alt=1 where ord="&billID&" ")
		con.execute("Update caigoulist set del=1 where caigou="&billID&" ")
		con.execute("Update caigoubz set  del=1 where caigou="&billID&" ")
		con.execute("exec erp_UpdateStatus_Caigou_QC '" &billID& "','' " )
		Dim invoicePlan ,payplan
		company = 0 :  payplan = 0: invoicePlan= 0
		money1 = 0
		Set rs = con.execute("select company ,isnull(fyhk,0) fyhk,isnull(invoicePlan,0) as invoicePlan, isnull(money1,0) as money1 from caigou where ord="& billID)
		If rs.eof = False Then
			company = rs("company")
			payplan = rs("fyhk")
			invoicePlan = rs("invoicePlan")
			money1 = rs("money1").value
		end if
		rs.close
		set rs = nothing
		dim status_sp:status_sp=1
		dim noSP:noSP = con.execute("select 1 from sp where gate2=50 and (isnull(sptype,0)=0 or isnull(sptype,0)=(select sort from caigou where ord="&billID&"))").eof
		if noSP then status_sp=0
		dim autotype : autotype=0
		if payplan = 0 or payplan= 2  then autotype=payplan*1+1
'dim autotype : autotype=0
		if invoiceplan = 0 or invoiceplan = 2  then autotype = (invoiceplan+1)*10+ autotype
'dim autotype : autotype=0
		if autotype>0 and cdbl(money1)>0 then
			creatorurl = sdk.getvirpath() & "../SYSN/view/finan/payout/AutoCreator.ashx?autotype=" &  autotype & "&fromtype=caigou&fromid=" & billID & "&t=" & cdbl(now)
			Response.write  "<script>var xhttp=new XMLHttpRequest(); xhttp.open('GET','" &creatorurl & "&disGotoPayoutList=1',false);xhttp.send();</script>"
		end if
		if payplan = 5 then
			con.execute("update plan_fk set del=1 where del=3 and caigou="& billID)
			con.execute("update payout set del=1,status_sp=" & status_sp & " where del=3 and contract="& billID)
			con.execute("update payoutList set del=1 where payout in(select ord from payout where del=3 and contract="& billID &")")
			con.execute("update payoutList set del=1 where payout in(select ord from payout where del=1 and contract="& billID &") and del=3")
			con.execute("update plan_fk set del2=1 where del=2 and del2=3 and caigou="& billID)
			con.execute("update payout set del2=1,status_sp=" & status_sp & " where del=2 and del2=3 and contract="& billID)
			con.execute("update payoutList set del2=1 where payout in(select ord from payout where del=2 and del2=3 and contract="& billID &")")
		end if
		Case "payout"
		Dim caigouid, cls, fkTitle
		caigouid = 0 : cls = 0 : fkTitle = ""
		money1=  0
		Set rs = con.execute("select contract, isnull(cls,0) cls , money1, title from payout where ord="& billID &" and isnull(cls,0) not in(2) ")
		If rs.eof = False Then
			caigouid = rs("contract") : cls = rs("cls") : money1 = rs("money1") : fkTitle = rs("title")
		end if
		rs.close
		set rs = nothing
		If caigouid&""="0" Then caigouid = 0
		If cls&""="0" Then cls = 0
		If caigouid>0 Then
			on error resume next
			ismobile = app.ismobile
			if err.number > 0 then
				ismobile = False
			end if
			On Error GoTo 0
			if not (cls = 0 and fkTitle&"" = "期初应付") then
				call setPayoutMx(billID, caigouid , money1, ismobile,false)
			end if
		end if
		Case "bankout"
		If conn.execute("select top 1 1 from bank where sort=11 and gl="&billID&" and gl2="&billID).eof =False Then
			Response.write "<script>alert('此数据已提交！');</script>"
			Exit Sub
		end if
		Dim bz ,money_last ,money_list ,money_new ,invoiceMode , invoiceType , planDate
		sql = "insert into bank (bank , money2 , sort , intro , gl ,gl2 ,cateid ,date1, date7 ) "&_
		"  select bank, money1 , 11 , '供应商预付款', id,id, "& curCate &",date3,'"& now &"' from bankout2 where id="& billID
		con.execute(sql)
		bz = 14
		company = 0
		money1 = 0
		invoiceMode = 0
		invoiceType = 0
		planDate = Date
		Set rs = con.execute("select company , isnull(bank,0) bank, isnull(money1,0) money1 ,isnull(invoiceMode,0) as invoiceMode,isnull(invoiceType,0) as invoiceType ,planDate from bankout2 where id="& billID)
		If rs.eof = False Then
			bz = sdk.GetSqlValue("select top 1  bz from sortbank where id="& rs("bank"),14)
			company = rs("company")
			money1 = rs("money1")
			invoiceMode = rs("invoiceMode")
			invoiceType = rs("invoiceType")
			planDate = rs("planDate")
		end if
		rs.close
		If money1&"" = "" Then money1 = 0 Else money1 = CDBL(money1)
		money_last = getMoneyLeft(con,company,bz,2)
		con.execute("update bankout2 set money_left = money1 where id="& billID)
		If invoiceMode ="2" Then
			Dim isInvoiced , hasInvoice, taxValue
			isInvoiced = 0
			Set rs = con.execute("select isInvoiced from payoutInvoice where fromType='PREOUT' and fromid="& billID &"")
			If rs.eof=False Then
				hasInvoice = True
				isInvoiced = rs("isInvoiced")
			else
				hasInvoice = False
			end if
			rs.close
			Set rs = con.execute("select taxRate from invoiceConfig where typeid="& invoiceType &"")
			If rs.eof=False Then
				taxRate = rs("taxRate")
			end if
			rs.close
			If taxRate&"" = "" Then taxRate = 0 Else taxRate = CDbl(taxRate)
			taxValue = cdbl(money1) / (1+cdbl(taxRate)/100) * (cdbl(taxRate)/100)
'If taxRate&"" = "" Then taxRate = 0 Else taxRate = CDbl(taxRate)
			If hasInvoice = False Then
				sql = "insert into payoutInvoice(company,fromType,fromId,invoiceType,invoiceMode,taxRate,taxValue,date1,date7,money1,bz,money_left,cateid,addcate,isInvoiced,del) " &_
				" select company,'PREOUT',id,invoiceType,1,"& taxRate &","& taxValue &",planDate,'"&now()&"',money1,bz,0,cateid,"& curCate &",0,1 from bankout2 where id="& billID
				con.execute(sql)
			ElseIf isInvoiced<>1 Then
				conn.execute("update payoutInvoice set invoiceType="& invoiceType &",date1='"& planDate &"',date7='"& now() &"' where fromType='PREOUT' and fromid="& billID &"")
			end if
		end if
		money_list=money1
		money_new=cdbl(money_last)+cdbl(money_list)
'money_list=money1
		Call ChangeLog_Yfk(1,"添加预付款",money_last,money_list,money_new,bz,company, billID , curCate ,session("name2006chen"))
		End Select
	end sub
	
	Class CommSPHandle
		Private rs, sql, rs2
		Public currgate
		public currSpr
		Public nextSpId
		Public nextGates
		Public cateid_sp
		Public actCate
		Public addCate
		Public useCate
		Public BillID
		Public backSPInfo
		Public swicthFieldValue
		Public moneyFieldValue
		Public MoneySpFieldValue
		Public stateFieldValue
		Public reBack
		Public nextSPOK
		Public jg
		Public yspGate
		public config
		Public newmoney
		Public MoneyNumber
		Public ReturnIntro
		Public isSdkSave
		Private logOn
		Private ArrLog       ()
		Private logIdx
		Private logFile
		Public Sub initById(billid , approve)
			Me.BillID = BillID
			Set config = New CommSPConfig
			config.init_sp(approve)
			Call init2
			Call setSwicthFieldValue(billid , approve)
			Me.isSdkSave = True
		end sub
		Function setSwicthFieldValue(billid , approve)
			Select Case approve
			Case 4
			Call checkBudget(billid)
			Case 50
			Call getPayoutSwicthValue(billid)
			Case 78
			call getCommBillSwitchValue(approve, billid)
			End Select
		end function
		Function getCommBillSwitchValue(approve, billid)
			dim sql
			Select Case approve
			Case 78
			sql = "select isnull(dbo.Fn_XQgenfenlei(sort),0) wdRoot from document Where id="& BillID
			End Select
			if sql&""<>"" then
				Set rs = config.con.execute(sql)
				If rs.eof = False Then
					Me.swicthFieldValue = rs(0).value
				end if
				rs.close
				set rs = nothing
			end if
			If Me.swicthFieldValue&"" = "" Then Me.swicthFieldValue = 0
		end function
		Function getPayoutSwicthValue(billid)
			Dim rs,sp_id : sp_id = 0
			Set rs = config.con.execute("select isnull("& config.sp &",0) as sp from "& config.tabName &" where "& config.keyField &"="& BillID)
			If rs.eof= False Then
				sp_id = rs(0).value
			end if
			rs.close
			If sp_id>0 Then
				Set rs = config.con.execute("select sptype from sp where id= "& sp_id)
				If rs.eof= False Then
					Me.swicthFieldValue = rs(0).value
				end if
				rs.close
				If Me.swicthFieldValue&"" = "" Then Me.swicthFieldValue = 0
				Exit Function
			else
				Set rs = config.con.execute("select sort from caigou where ord=(select isnull(contract,0) contract from "& config.tabName &" where "& config.keyField &"="& BillID &" and isnull(cls,0)=0)")
				If rs.eof = False Then
					Me.swicthFieldValue = rs(0).value
				end if
				rs.close
				set rs = nothing
				If Me.swicthFieldValue&"" = "" Then Me.swicthFieldValue = 0
			end if
		end function
		Function checkBudget(billid)
			Dim rs,sp_id : sp_id = 0
			Set rs = config.con.execute("select isnull("& config.sp &",0) as sp from "& config.tabName &" where "& config.keyField &"="& BillID)
			If rs.eof= False Then
				sp_id = rs(0).value
			end if
			rs.close
			If sp_id>0 Then
				Set rs = config.con.execute("select sptype from sp where id= "& sp_id)
				If rs.eof= False Then
					Me.swicthFieldValue = rs(0).value
				end if
				rs.close
				Exit Function
			end if
			dim strateget
			strateget = 0
			set rs = config.con.execute("select sort from strategy where gate2=1")
			if rs.eof = False And ZBRuntime.MC(80000) then
				strateget = rs.fields(0).value
			end if
			rs.close
			set rs = nothing
			If strateget = 2 Or strateget = 1 Then
				Dim sorce : sorce= ""
				Dim uid : uid = 0
				Dim bz : bz = 14
				Dim ret : ret = Date
				Dim money : money = 0
				Set rs = config.con.execute("select cateid,bz,bxdate,(select sum(isnull(money1,0)) as spmoney from paybxlist where bxid =p.id ) as spmoney from paybx p where id = "& billid &"")
				If rs.eof =False Then
					uid = rs(0).value
					bz = rs(1).value
					ret = rs(2).value
					money = rs(3).value
				end if
				rs.close
				Set rs=config.con.execute("select isnull(sorce,0) as sorce from gate where del=1 and ord="& uid &"")
				If rs.eof = False Then
					sorce=rs("sorce").value
				else
					Exit Function
				end if
				rs.close
				Dim rss ,rss1 ,sortsql, bxsql ,mode , startdate,enddate , money1 ,money2 , atStr
				If sorce<>"" Then
					If sorce>0 Then
						sortsql=" and sort=1 and obj_ord="&sorce&" "
						bxsql=" and cateid2=" & sorce & " "
					else
						sortsql=" and sort=2 and obj_ord="& uid &" "
						bxsql=" and cateid="& uid &" and isnull(cateid2,0)=0 "
					end if
					Set rs=config.con.execute("select ord,mode,money1,startdate,enddate from budget where del=1 and isnull(status,0)=0  "& sortsql &" and bz= "& bz &" and startDate<='"& ret &"' and endDate>='" & ret & "'")
					If rs.eof = False Then
						mode=rs("mode").value
						startdate=rs("startdate").value
						enddate=rs("enddate").value
						If mode=0 then
							money1=cdbl(rs("money1").value)
							money2=0
							Set rss=config.con.execute("select isnull(sum(isnull(money1,0)),0) as money2 from paybxlist where bxid in (select id from paybx where complete<>2 and complete<>0 and bxdate between '"&startdate&"' and '"& enddate &"' and isnull(bz,14)="& bz &" "& bxsql &") and bxid <> " & billid)
							If rss.eof= False Then
								money2=cdbl(rss("money2").value)
							end if
							rss.close
							Set rss=config.con.execute("select isnull(sum(isnull(money1,0)),0) as money2 from pay where ord in (select payid from paybxlist s1 inner join paybx s2 on s1.bxid=s2.id and s2.complete=0 and s2.bxdate between '"&startdate&"' and '"&enddate&"' and isnull(s2.bz,14)="& bz &" "& bxsql &" and s1.bxid <> " & billid & ")")
							If rss.eof= False Then
								money2=cdbl(money2) + cdbl(rss("money2").value)
'If rss.eof= False Then
							end if
							rss.close
							If CDbl(money)>cdbl(money1)-cdbl(money2) Then
'rss.close
								atStr = "预算总额："& formatnumber(money1,Me.MoneyNumber,-1)&"  使用总额："&formatnumber(money2,Me.MoneyNumber,-1)&"  剩余总额："&FormatNumber((money1-money2),Me.MoneyNumber,-1)&"，本次报销金额"&formatnumber(money,Me.MoneyNumber,-1)&"，大于剩余总额"&FormatNumber((money1-money2),Me.MoneyNumber,-1)
'rss.close
							end if
						else
							Set rss=config.con.execute("select sort,money1,sortName from budgetlist where pid="& rs("ord").value &"")
							If rss.eof =False Then
								While rss.eof = False
									money1=cdbl(rss("money1"))
									money2=0
									Set rss1=config.con.execute("select isnull(sum(isnull(money1,0)),0)as money2 from paybxlist where sort="&rss("sort").value &" and bxid in (select id from paybx where complete<>2 and complete<>0 and bxdate between '"&startdate&"' and '"&enddate&"' and isnull(bz,14)="& bz &" "& bxsql &") and bxid <> " & billid)
									If rss1.eof= False Then
										money2=cdbl(rss1("money2").value)
									end if
									rss1.close
									Set rss1=config.con.execute("select isnull(sum(isnull(money1,0)),0) as money2 from pay where  sort="&rss("sort").value &" and ord in (select payid from paybxlist s1 inner join paybx s2 on s1.bxid=s2.id and s2.complete=0 and s2.bxdate between '"&startdate&"' and '"&enddate&"' and isnull(s2.bz,14)="& bz &" "& bxsql &" and s1.bxid <> " & billid & ")")
									If rss1.eof= False Then
										money2=money2 + cdbl(rss1("money2").value)
'If rss1.eof= False Then
									end if
									rss1.close
									Set rss1=config.con.execute("select isnull(sum(isnull(money1,0)),0) as money from pay where sort="&rss("sort").value &" and ord in (select payid from paybxlist where bxid="& billid &" )")
									If rss1.eof= False Then
										money=cdbl(rss1("money").value)
									else
										money=0
									end if
									rss1.close
									If money>0 And money1>0 And money>money1-money2 Then
										rss1.close
										If Len(atStr)>0 Then atStr=atStr & vbcrlf
										atStr= atStr &  ""& rss("sortName").value &"预算总额："& formatnumber(money1,Me.MoneyNumber,-1)&"  使用总额："&formatnumber(money2,Me.MoneyNumber,-1)&"  剩余总额："&FormatNumber((money1-money2),Me.MoneyNumber,-1)&"，本次报销金额"&formatnumber(money,Me.MoneyNumber,-1)&"大于剩余总额"&FormatNumber((money1-money2),Me.MoneyNumber,-1)
'If Len(atStr)>0 Then atStr=atStr & vbcrlf
									end if
									rss.movenext
								wend
							end if
							rss.close
						end if
					end if
					rs.close
				end if
				If Len(atStr)>0 Then
					If strateget = 2 Then
						If config.con.execute("select COUNT(1) from sp where gate2=4 and sptype = 1")(0)>0 Then Me.swicthFieldValue = 1
					else
						Me.ReturnIntro = atStr
					end if
				end if
			end if
		end function
		Public Function loadNextBySdk(NeedMoney , spmoney)
			Dim rs
			If NeedMoney=True Then
				spmoney = Me.moneyFieldValue
			else
				Me.moneyFieldValue = spmoney
			end if
			Call loadNextSp2(swicthFieldValue, spmoney)
		end function
		Public Sub init(Bill, BillID)
			Set config = New CommSPConfig
			config.init Bill
			If Len(config.tabName)=0 Then
				Me.ReturnIntro = "请初始定义审批类型"
				Exit Sub
			end if
			Me.BillID = BillID
			Call init2
			Call setSwicthFieldValue(BillID , config.clsId)
		end sub
		Private Sub init2()
			Me.isSdkSave = False
			Me.swicthFieldValue = 0
			Me.moneyFieldValue = 0
			Me.MoneyNumber = 2
			Me.ReturnIntro = ""
			Me.currgate = 0
			Me.nextSPOK = False
			Me.actCate = session("personzbintel2007")
			Me.addCate = session("personzbintel2007")
			Me.useCate = 0
			Me.reBack = False
			Me.yspGate = 0
			ReDim ArrLog(5000)
			logIdx = 0
			logOn = false
			logFile = "../../inc/commSPLog.txt"
			Dim rs ,sql
			Set rs = config.con.execute("select num1 from setjm3  where ord=1 ")
			If rs.eof = False Then
				Me.MoneyNumber = rs("num1").value
			end if
			rs.close
			If Len(config.swicthField)>0 Then
				sql = "isnull("&config.swicthField&",0) as " & config.swicthField
			else
				sql = "0"
			end if
			If Len(config.moneyField)>0 Then
				sql = sql &"," & "isnull("&config.moneyField&",0) as " & config.moneyField
			else
				sql = sql &",0"
			end if
			If Len(config.saveBillMoneyField)>0 Then
				sql = sql &"," & "isnull("&config.saveBillMoneyField&",0) as " & config.saveBillMoneyField
			else
				sql = sql &",0"
			end if
			sql = sql & "," & config.stateField &"," & config.sprField
			Set rs = config.con.execute("select "& sql &" from "& config.tabName &" where "& config.keyField &"="& Me.BillID)
			If rs.eof= False Then
				Me.swicthFieldValue = rs(0).value
				Me.moneyFieldValue = rs(1).value
				Me.MoneySpFieldValue = rs(2).value
				Me.stateFieldValue = rs(3).value
				Me.currSpr = rs(4).value
			end if
			rs.close
			If config.clsId = 4 Then
				Me.moneyFieldValue = config.con.execute("select isnull(sum(isnull(money1,0)),0) as spmoney from paybxlist where bxid ="& Me.BillID)(0).value
			end if
		end sub
		public property let UseCateid(v)
		if isnumeric(v) then
			Me.useCate = CLng(v)
		end if
		end Property
		public property let LogFilePath(v)
		if v&"" <> "" Then logFile = v
		end Property
		Public Function loadNextSp2(swicthFieldValue, moneyFieldValue)
			if Me.moneyFieldValue&""="" then Me.moneyFieldValue = 0
			If swicthFieldValue&""="" Then swicthFieldValue=0
			Me.swicthFieldValue = swicthFieldValue
			If moneyFieldValue&""="" Then moneyFieldValue=0 Else moneyFieldValue = CDbl(moneyFieldValue)
			If CDbl(Me.moneyFieldValue)< CDbl(moneyFieldValue) Then  Me.moneyFieldValue = CDbl(moneyFieldValue)
			Call loadNextSp()
		end function
		Public  Function loadNextSp()
			Dim sp      ,currMaxMoney, nextbt ,isCont,maxMoney,currbt,stateField
			cateid_sp = 0
			Me.currgate = 0
			Me.nextSpId = 0
			Me.nextGates = ""
			If Me.moneyFieldValue&""="" Then Me.moneyFieldValue = 0
			Me.moneyFieldValue = CDbl(Me.moneyFieldValue)
			currbt = 0
			If config.Enable = False Then Exit Function
			If Me.BillID>0 Then
				Set rs = config.con.execute("select "& config.sprField &", "& config.sp &", "& config.addField & iif(Len(config.addField2)>0,"," & config.addField2 &"","") &","& config.stateField &" from "& config.tabName &" where "& config.keyField &"="& Me.BillID)
				If rs.eof=False  Then
					cateid_sp = rs(""& config.sprField &"")
					If cateid_sp&"" = "" Then cateid_sp = 0
					sp = rs(""&config.sp&"")
					stateField=rs(""&config.stateField&"")
					If stateField&""="" Then stateField=0 Else stateField = CLng(stateField)
					If Me.reBack = True Then
						sp = 0
					else
						If Clng(cateid_sp)<>Clng(Me.actCate) And Clng(cateid_sp)>0 Then
							Me.nextSpId = -3
'If Clng(cateid_sp)<>Clng(Me.actCate) And Clng(cateid_sp)>0 Then
							Exit Function
						elseif stateField=Clng(config.stateOK) or (Clng(config.stateFou)<>Clng(config.stateShen) and stateField=Clng(config.stateFou) ) or (Clng(config.stateFou)=Clng(config.stateShen) and stateField=Clng(config.stateFou) and sp = -1 ) then
'Exit Function
							Me.nextSpId = -3
'Exit Function
							Exit Function
						end if
					end if
					Me.addCate = rs(""& config.addField & "")
					If Len(config.addField2)>0 Then
						Me.useCate = rs(""& config.addField2 &"")
					end if
					If Me.addCate & "" = "" Then Me.addCate = 0
					If Me.useCate & "" = "" Then Me.useCate = 0
					If sp&""="" Then sp=0 Else sp = CLng(sp)
					currMaxMoney = 0 : nextbt = 0 : maxMoney = 0 : currbt = 0
					Set rs2 = config.con.execute("select gate1, isnull(money2,0) as currMaxMoney, isnull(bt,0) bt from sp where id="& sp)
					If rs2.eof=False Then
						Me.currgate = rs2("gate1")
						currMaxMoney = zbcdbl(rs2("currMaxMoney")) : currbt = rs2("bt")
					end if
					rs2.close
					Set rs2 = Nothing
					If sp>0 Then
						If Clng(cateid_sp)<>Clng(Me.actCate) And Clng(cateid_sp)>0 Then
							Me.nextSpId = -3
'If Clng(cateid_sp)<>Clng(Me.actCate) And Clng(cateid_sp)>0 Then
							Exit Function
						end if
					end if
				else
					cateid_sp = 0
					Me.nextSpId = -2
					cateid_sp = 0
					Exit Function
				end if
				rs.close
				set rs = nothing
			end if
			If sp&""="" Then sp=0 Else sp = CLng(sp)
			Dim spord,sptitle,gates,m1,m2,bt, gate1
			if cdbl(Me.swicthFieldValue)>0 then
				set rs = config.con.execute("select count(ord) from sp where gate2="& config.clsId &" and ("& sp &"=0 or "& sp &"=-1 or "& sp &"=999999 or id="& sp &") and isnull(sptype,0)="& Me.swicthFieldValue &"")
'if cdbl(Me.swicthFieldValue)>0 then
				if rs(0)=0 then
					Me.swicthFieldValue = 0
				end if
				rs.close
				set rs = nothing
			end if
			isCont = False
			If currbt > 0 And config.moneyLimit = True And config.moneyField &"" <> "" Then
				If checkLastMoney(Me.currgate,Me.moneyFieldValue) > 0 Then
					isCont = True
					Call Log("[BillID="& Me.BillID &"][currgate="& Me.currgate &"][currbt > 0 And checkLastMoney = True][当前级是必经且上面流程已结束]")
				end if
			end if
			If isCont = False And config.moneyLimit = True And config.moneyField &"" <> "" Then
				If Me.moneyFieldValue< currMaxMoney And currbt=0 Then
					nextbt = checkNextBT(Me.currgate)
					If nextbt>0 Then
						isCont = True
						Call Log("[BillID="& Me.BillID &"][currgate="& Me.currgate &"][nextbt > 0 And moneyFieldValue:"& Me.moneyFieldValue &" < currMaxMoney:"& currMaxMoney &"][到当前级结束，后面只走必经流程]")
					end if
				end if
			end if
			Set rs = config.con.execute("select ord, sort1, dbo.erp_bill_GetSpLinkMan("& iif(Me.useCate>0, Me.useCate, Me.addCate) &", replace(intro,' ',''), gate3) as intro, money1, money2,gate1, isnull(bt,0) as bt from sp where gate1 > "& Me.currgate &" and gate2="& config.clsId &" and isnull(sptype,0)="& Me.swicthFieldValue &"   order by gate1")
			If rs.eof=False Then
				Do While rs.eof=False
					spord = rs("ord")
					sptitle = rs("sort1")
					If rs("intro")&""<>"" Then gates = Replace(rs("intro")," ","") Else gates = ""
					m1 = CDbl(rs("money1")) : bt = rs("bt") : m2 = CDbl(rs("money2")) : gate1 = rs("gate1")
					If (InStr(gates,"|"& Me.actCate &"=")=0 and InStr(gates,"|"& Me.addCate &"=")=0) _
					And (Me.useCate=0 Or (Me.useCate>0 And InStr(gates,"|"& Me.useCate &"=")=0)) Then
						If bt=1 Then
							Me.nextSpId = spord
							Me.nextGates = gates
							Call Log("[gate1="& gate1 &"][bt = 1][nextSpId="& spord &"][nextGates="& gates &"][此级必经]")
							Exit Do
						ElseIf isCont = False Then
							If config.moneyLimit = True And config.moneyField &"" <> "" then
								If Me.moneyFieldValue >= m1 And Me.moneyFieldValue >=currMaxMoney Then
									Me.nextSpId = spord
									Me.nextGates = gates
									Call Log("[BillID="& Me.BillID &"][gate1="& gate1 &"][nextSpId="& spord &"][nextGates="& gates &"][moneyFieldValue:"& Me.moneyFieldValue &" >= m1:"& m1 &"][进入此级流程]")
									Exit Do
								else
									isCont= true
									Call Log("[gate1="& gate1 &"][moneyFieldValue:"& moneyFieldValue &" < m1:"& m1 &" And nextbt > 0][审批流程到此结束，后面只走必经流程]")
								end if
							else
								Me.nextSpId = spord
								Me.nextGates = gates
								Call Log("[BillID="& Me.BillID &"][gate1="& gate1 &"][nextSpId="& spord &"][nextGates="& gates &"][进入此级流程]")
								Exit Do
							end if
						end if
					Else
						If isCont = False And config.moneyLimit = True And config.moneyField &"" <> "" Then
							nextbt = checkNextBT(gate1)
							If Me.moneyFieldValue< m2 Then
								If nextbt>0 Then
									isCont = True
									Call Log("[gate1="& gate1 &"][moneyFieldValue:"& moneyFieldValue &" < m2:"& m2 &" And nextbt > 0][审批流程到此结束，后面只走必经流程]")
								Else
									Me.nextSpId = 0
									Me.nextGates = ""
									Call Log("[gate1="& gate1 &"][nextSpId = "& nextSpId &"][nextGates = "& nextGates &"][审批流程结束]")
									Exit Function
								end if
							end if
						end if
					end if
					rs.movenext
				Loop
			else
				Me.nextSpId = 0
				Me.nextGates = ""
				Call Log("[BillID="& Me.BillID &"][nextSpId = "& nextSpId &"][nextGates = "& nextGates &"][后面没有审批流程，审批流程结束]")
			end if
			rs.close
			set rs = nothing
		end function
		Private Function checkNextBT(gate1)
			checkNextBT = config.con.execute("select count(1) from sp where gate1 > "& gate1 &" and gate2="& config.clsId &" and isnull(sptype,0)="& Me.swicthFieldValue &" and bt=1 ")(0)
		end function
		Private Function checkLastMoney(gate1,spMoney)
			checkLastMoney = config.con.execute("select COUNT(1) from sp_intro a inner join sp b on a.sp_id=b.id and b.gate2="& config.clsId &" where a.sort1="& config.clsId &" and a.ord="& Me.BillID &" and a.jg=1 and b.money2>"& spMoney &" and isnull(b.bt,0)=0 and isnull(b.sptype,0)="& Me.swicthFieldValue &"")(0)
		end function
		Public Function saveBillBySdk(nextSpId, cateid_sp)
			Call saveBill2(nextSpId, cateid_sp, Me.swicthFieldValue, Me.moneyFieldValue)
		end function
		Public Function saveBill2(nextSpId, cateid_sp, nowSpID, reMoney)
			Dim spIdStr, arr_allSp, i, spId, spCates, spCate, remark2, sptitle
			if nextSpId&""="" or isnull(nextSpId) then nextSpId=0
			if cateid_sp&""="" or isnull(cateid_sp) then cateid_sp=0
			if nextSpId>0 and cateid_sp=0 then
				Me.nextSpId = -2
'if nextSpId>0 and cateid_sp=0 then
				Exit Function
			end if
			if nowSpID&""="" then nowSpID=0
			if reMoney&""="" then reMoney=0 else reMoney=cdbl(reMoney)
			Me.swicthFieldValue = nowSpID
			Me.newmoney = reMoney
			If CDbl(Me.moneyFieldValue)< CDbl(reMoney) Then  Me.moneyFieldValue = CDbl(reMoney)
			If Me.BillID>0 and not me.reBack Then
				dim lastState ,nowSpGate
				nowSpGate = 0
				Set rs = config.con.execute("select isnull(a."&config.sp&",0) sp,isnull(b.gate1,0) gate1,isnull("& config.stateField &",0) state, "& config.addField & iif(Len(config.addField2)>0,"," & config.addField2 &"","") &",isnull("& config.sprField &",0) as "& config.sprField &" from "& config.tabName &" a left join sp b on a."&config.sp&"=b.id where a."& config.keyField &"="& Me.BillID)
				If rs.eof=False Then
					nowSpGate = rs("gate1").value
					lastState = rs("state")
					Me.addCate = rs(""& config.addField & "")
					If Len(config.addField2)>0 Then
						Me.useCate = rs(""& config.addField2 &"")
					end if
					If Me.addCate & "" = "" Then Me.addCate = 0
					If Me.useCate & "" = "" Then Me.useCate = 0
				end if
				rs.close
				set rs = nothing
				If cdbl(nowSpGate)>0 And Me.currgate<>nowSpGate Then
					Me.nextSpId = -1
'If cdbl(nowSpGate)>0 And Me.currgate<>nowSpGate Then
					Exit Function
				end if
			end if
			spIdStr = ""
			spIdStr = nextSpList()
			if spIdStr&""<>"" then
				arr_allSp = Split(spIdStr,",")
				for i=0 to ubound(arr_allSp)
					if arr_allSp(i)&""<>"" then
						spId = clng(arr_allSp(i))
						if spId = nextSpId then
							exit for
						end if
						spCates = ""
						set rs = config.con.execute("select sort1,intro from sp where gate2="& config.clsId &" and ord="& spId)
						if rs.eof=false then
							sptitle = rs("sort1")
							spCates = rs("intro")
							If spCates&""<>"" Then spCates=Replace(spCates," ","")
						end if
						rs.close
						set rs = nothing
						if instr(","& spCates &",",","& Me.actCate &",")>0 Or instr(","& spCates &",",","& Me.addCate &",")>0 Or (Me.useCate>0 And instr(","& spCates &",",","& Me.useCate &",")>0) then
							If instr(","& spCates &",",","& Me.addCate &",")>0 then
								remark2 = "添加人员默认审批通过"
								spCate = Me.addCate
							ElseIf instr(","& spCates &",",","& Me.actCate &",")>0 Then
								remark2 = "当前审批人默认审批通过"
								spCate = Me.actCate
							ElseIf Me.useCate>0 And instr(","& spCates &",",","& Me.useCate &",")>0 Then
								remark2 = getGateName(Me.useCate) & " 默认审批通过"        '"使用人员默认通过"
								spCate = Me.useCate
							end if
							Call Log("审批记录：[BillID = "& Me.BillID &"][spId = "& spId &"][result = 1][sptitle = "& sptitle &"][spCate = "& spCate &"][remark2 = "& remark2 &"][clsId = "& config.clsId &"][reMoney="& reMoney &"]")
							config.con.execute("insert into sp_intro(jg, intro, date1, ord, sp, cateid, sort1, money1, sp_id) values (1,'" & remark2 & "', getdate()," & Me.BillID & ",'" & sptitle & "', " & spCate & "," & config.clsId & ","& reMoney &"," & spId &") ")
						else
							exit for
						end if
					end if
				next
			end if
			call saveBill(nextSpId, cateid_sp)
		end function
		Public  Sub saveBill(nextSpId, cateid_sp)
			Dim spNum , lastJG, lastState
			spNum = 0
			lastJG = 1
			if nextSpId&""="" or isnull(nextSpId) then nextSpId=0
			if cateid_sp&""="" or isnull(cateid_sp) then cateid_sp=0
			sql = "select top 1 jg from sp_intro where sort1="& config.clsId &" and ord= "& Me.BillID &" order by date1 desc,id desc"
			Set rs = server.CreateObject("adodb.recordset")
			rs.open sql,config.con,1,1
			spNum = rs.RecordCount
			If spNum<0 Then spNum=0
			If rs.eof=False Then
				lastJG = rs("jg")
			end if
			rs.close
			set rs = nothing
			If lastJG&""="2" Or Me.reback Then spNum=0 ': lastJG = 1     ' Or lastJG&""="3" 临后是APP退回直接审批通过
			Set rs = config.con.execute("select isnull("& config.stateField &",0) from "& config.tabName &" where  "& config.keyField &"="& Me.BillID)
			If rs.eof = False Then
				lastState = rs(0)
			end if
			rs.close
			set rs = nothing
			sql = "update "& config.tabName &" set "&config.sp&"="& nextSpID &",  "& config.sprField &"="& cateid_sp
			If nextSpID=0 Then
				If Me.jg&""="3" Then
					sql = sql &", "& config.stateField &"="& nextSpID
				else
					if config.stateField = "del" then
						sql = sql &", "& config.stateField &"=(case "& config.stateField &" when "& config.stateShen &" then "& config.stateOK &" else "& config.stateField &" end)"
					else
						sql = sql &", "& config.stateField &"="& config.stateOK &""
					end if
				end if
			ElseIf nextSpID>0 And spNum=0 Then
				sql = sql &", "& config.stateField &"="& config.stateDai
			ElseIf nextSpID>0 And spNum>0 Then
				If lastState&""<>"" Then
					If lastState&"" = config.stateOK&"" Or lastState&"" = config.stateFou&"" Then
						sql = sql &", "& config.stateField &"="& config.stateDai
					else
						sql = sql &", "& config.stateField &"="& config.stateShen
					end if
				else
					sql = sql &", "& config.stateField &"="& config.stateShen
				end if
			ElseIf nextSpId=-1 Then
				sql = sql &", "& config.stateField &"="& config.stateShen
				sql = sql &", "& config.stateField &"="& config.stateFou
			end if
			sql = sql &" where "& config.keyField &"="& Me.BillID
			config.con.execute(sql)
			If (nextSpID=0 Or spNum>0) And Me.newmoney>0 And lastJG&""="1" And (config.saveBillMoneyField <> "" Or config.saveBillMoneySub <>"") Then
				If config.saveBillMoneySub <> "" Then
					If Not ExistsProc(config.saveBillMoneySub) Then
						config.con.rollbacktrans
						Response.write "<script>alert('请定义函数【"& config.saveBillMoneySub &"】');history.back();</script>"
						Exit Sub
					else
						TryExecuteProc "call "& config.saveBillMoneySub &"("& Me.BillID &","& Me.newmoney &")"
					end if
				ElseIf config.saveBillMoneyField <> "" Then
					config.con.execute("update "& config.tabName &" set "& config.saveBillMoneyField &" = "& Me.newmoney &" where "& config.keyField &"="& Me.BillID)
				end if
			end if
			If config.isExtract = True Then
				Call config.billExtract(Me.BillID, lastJG, nextSpID)
			end if
		end sub
		Public  Function saveBillBySdkSP2(result, remark, nextSpID, nextSpCateid, reMoney)
			If reMoney&""<>"" Then reMoney = Replace(reMoney&"",",","")
			saveBillBySdkSP2 = saveSP2(result, remark, nextSpID, nextSpCateid, Me.swicthFieldValue, reMoney)
		end function
		Public  Function saveSP2(result, remark, nextSpID, nextSpCateid, swicthValue, reMoney)
			If swicthValue&""="" Then swicthValue=0
			Me.swicthFieldValue=swicthValue
			if nextSpID&""="" or isnull(nextSpID) then nextSpID=0
			if nextSpCateid&""="" or isnull(nextSpID) then nextSpCateid=0
			If reMoney&""<>"" Then reMoney = Replace(reMoney&"",",","")
			saveSP2 = saveSP(result, remark, nextSpID, nextSpCateid, reMoney)
		end function
		Public  Function saveSP(result, remark, nextSpID, nextSpCateid, reMoney)
			Dim i, nowSpID, nowSpGate, sptitle, nextSpGate, sp_title, remark2
			Dim spIdStr, allSpStr, arr_allSp, spId, spGate, spIntro, spCate, nowSpCate, lastSpId
			Dim preSpCate
			nowSpID = 0
			nowSpGate = 0
			nowSpCate = 0
			sptitle = ""
			nextSpGate = 0
			spIdStr = ""
			remark2 = ""
			If reMoney&""<>"" Then reMoney = Replace(reMoney&"",",","")
			If reMoney&""="" Then reMoney=0 else reMoney=cdbl(reMoney)
			Me.jg = result
			Me.newmoney = reMoney
			If CDbl(Me.moneyFieldValue)< reMoney Then  Me.moneyFieldValue = reMoney
			if nextSpID&""="" or isnull(nextSpID) then
				nextSpID=0
			else
				nextSpID = CLng(nextSpID)
			end if
			if nextSpCateid&""="" or isnull(nextSpCateid) then
				nextSpCateid=0
			else
				nextSpCateid = CLng(nextSpCateid)
			end if
			If Me.reBack = True Then
				config.con.execute("update "& config.tabName &" set "&config.sp&"=0 where "& config.keyField &"="& Me.BillID)
			end if
			Set rs = config.con.execute("select isnull(a."&config.sp&",0) sp,isnull(b.gate1,0) gate1,"& config.addField & iif(Len(config.addField2)>0,"," & config.addField2 &"","") &",isnull("& config.sprField &",0) as "& config.sprField &" from "& config.tabName &" a left join sp b on a."&config.sp&"=b.id where a."& config.keyField &"="& Me.BillID)
			If rs.eof=False Then
				nowSpID = rs("sp")
				nowSpGate = rs("gate1")
				Me.addCate = rs(""& config.addField & "")
				If Len(config.addField2)>0 Then
					Me.useCate = rs(""& config.addField2 &"")
				end if
				If Me.addCate & "" = "" Then Me.addCate = 0
				If Me.useCate & "" = "" Then Me.useCate = 0
				nowSpCate = rs(""& config.sprField &"")
			end if
			rs.close
			set rs = nothing
			If Me.yspGate>0 And Me.yspGate<>nowSpGate Then
				saveSP = "-1"
'If Me.yspGate>0 And Me.yspGate<>nowSpGate Then
				Me.nextSpId = -1
'If Me.yspGate>0 And Me.yspGate<>nowSpGate Then
				Exit Function
			end if
			If result&""="1" Then
				spIdStr = nextSpList()
			ElseIf result&""="2" Then
				If nowSpCate&""<>Me.actCate&"" Then
					Me.nextSpId = -1
'If nowSpCate&""<>Me.actCate&"" Then
					saveSP = "-1"
'If nowSpCate&""<>Me.actCate&"" Then
					Exit Function
				end if
				spIdStr = nowSpID &","
				nowSpGate = -1
'spIdStr = nowSpID &","
				nextSpGate = -1
'spIdStr = nowSpID &","
				nextSpID = -1
'spIdStr = nowSpID &","
			ElseIf result&""="3" Then
				nowSpGate = nextSpGate
				spIdStr = nowSpID &","
			end if
			If Me.isSdkSave = False Then
				config.con.CursorLocation = 3
				config.con.begintrans
			end if
			If spIdStr&""<>"" Then
				lastSpId = 0
				If spIdStr&""="0" Then spIdStr = nowSpID &","
				arr_allSp = Split(spIdStr,",")
				if nextSpID>0 then
					lastSpId = nextSpID
				else
					lastSpId = arr_allSp(ubound(arr_allSp)-1)
					lastSpId = nextSpID
				end if
				For i=0 To ubound(arr_allSp)
					remark2 = ""
					If arr_allSp(i)&""<>"" Then
						spId = CLng(arr_allSp(i))
						Set rs = config.con.execute("select sort1, gate1, intro from sp where id="& spId)
						If rs.eof=False Then
							sptitle = rs("sort1")
							spGate = rs("gate1")
							spCate = 0
							if nowSpID&""=spId&"" then
								if remark&""="" then remark=""
								remark2 = replace(remark,"'","''")
								spCate = session("personzbintel2007")
							Else
								spIntro = rs("intro")
								if spIntro&""="" then
									spIntro="0"
								else
									spIntro = replace(spIntro," ","")
								end if
								if instr(","& spIntro &",","," & Me.addCate &",")>0 then
									remark2 = "添加人员默认审批通过"
									spCate = Me.addCate
								elseif instr(","& spIntro &",","," & Me.actCate &",")>0 then
									remark2 = "当前审批人默认审批通过"
									spCate = Me.actCate
									if spCate = preSpCate then
										remark2 = "上一级审批人员默认审批通过"
									end if
								ElseIf Me.useCate>0 And instr(","& spIntro &",",","& Me.useCate &",")>0 Then
									remark2 = getGateName(Me.useCate) & " 默认审批通过"       '"使用人员默认通过"
									spCate = Me.useCate
								else
									if nextSpID=spId and nextSpCateid&""<>"" then
										spCate = nextSpCateid
									else
										spCate = session("personzbintel2007")
									end if
									if spCate = preSpCate then
										remark2 = "上一级审批人员默认审批通过"
									end if
								end if
							end if
							If remark2&""<>"" Then
								If Len(remark2)>500 Then
									remark2 = Left(remark2,500)
								end if
							end if
							spCate = CLng(spCate)
							nowSpCate = CLng(nowSpCate)
							if spCate>0 And nowSpCate=spCate or spCate = Me.addCate or spCate = Me.useCate Then
								Call Log("审批记录：[BillID = "& Me.BillID &"][spId = "& spId &"][result = "& result &"][sptitle = "& sptitle &"][spCate = "& spCate &"][remark2 = "& remark2 &"][clsId = "& config.clsId &"][reMoney="& reMoney &"]")
								config.con.execute("insert into sp_intro(jg, intro, date1, ord, sp, cateid, sort1, money1, sp_id) values (" & result & ",'" & remark2 & "', getdate()," & Me.BillID & ",'" & sptitle & "', " & spCate & "," & config.clsId & ","& reMoney &"," & spId &") ")
							end if
							preSpCate = spCate
						end if
						rs.close
						set rs = nothing
						if lastSpId>0 and lastSpId=spID then
							exit for
						end if
					end if
				next
			end if
			Call saveBill(nextSpID, nextSpCateid)
			if err.number<>0 then
				If Me.isSdkSave = False Then config.con.rollbacktrans
				saveSP = False
				Exit Function
			else
				If Me.isSdkSave = False Then config.con.CommitTrans
				saveSP = True
			end if
		end function
		Public  Function nextSpList()
			Dim sp      ,currMaxMoney, nextbt, isCont
			Dim spords, gate1
			cateid_sp = 0 :spords = "" : isCont = False
			If Me.moneyFieldValue&""="" Then Me.moneyFieldValue = 0
			Me.moneyFieldValue = CDbl(Me.moneyFieldValue)
			If Me.BillID>0 Then
				Set rs = config.con.execute("select "& config.sprField &", "& config.sp &", "& config.addField & iif(Len(config.addField2)>0,"," & config.addField2 &"","") & " from "& config.tabName &" where "& config.keyField &"="& Me.BillID)
				If rs.eof=False Then
					cateid_sp = rs(""& config.sprField &"")
					sp = rs(""& config.sp &"")
					Me.addCate = rs(""& config.addField & "")
					If Len(config.addField2)>0 Then
						Me.useCate = rs(""& config.addField2 &"")
					end if
					If Me.addCate & "" = "" Then Me.addCate = 0
					If Me.useCate & "" = "" Then Me.useCate = 0
					If sp&""="" Then sp=0
					Set rs2 = config.con.execute("select gate1 from sp where id="& sp)
					If rs2.eof=False Then
						Me.currgate = rs2("gate1")
					end if
					rs2.close
					Set rs2 = Nothing
				end if
				rs.close
				set rs = nothing
			end if
			If sp&"" = "" Then sp = 0
			Dim spord,sptitle,gates,m1,bt
			if cdbl(Me.swicthFieldValue)>0 then
				set rs = config.con.execute("select count(ord) from sp where gate2="& config.clsId &" and ("& sp &"=0 or "& sp &"=-1 or "& sp &"=999999 or id="& sp &") and isnull(sptype,0)="& Me.swicthFieldValue &"")
'if cdbl(Me.swicthFieldValue)>0 then
				if rs(0)=0 then
					Me.swicthFieldValue = 0
				end if
				rs.close
				set rs = nothing
			end if
			Set rs = config.con.execute("select ord, sort1, dbo.erp_bill_GetSpLinkMan("& iif(Me.useCate>0, Me.useCate, Me.addCate) &", replace(intro,' ',''), gate3) as intro, money1, isnull(bt,0) as bt, isnull(money2,0) as currMaxMoney, gate1 from sp where gate1 >= "& Me.currgate &" and gate2="& config.clsId &" and isnull(sptype,0)="& Me.swicthFieldValue &" order by gate1")
			If rs.eof=False Then
				Do While rs.eof=False
					spord = rs("ord")
					sptitle = rs("sort1")
					gate1 = rs("gate1")
					If rs("intro")&""<>"" Then gates = Replace(rs("intro")," ","") Else gates = ""
					m1 = CDbl(rs("money1"))
					bt = rs("bt")
					If bt=1 Then
						spords = spords & spord &","
						Call Log("审批流程：[gate1 = "& gate1 &"][bt = "& bt &"][spord = "& spord &"][此级必经]")
					ElseIf isCont = False Then
						If config.moneyLimit = True And config.moneyField &"" <> "" then
							currMaxMoney = rs("currMaxMoney").value
							If Me.moneyFieldValue< cdbl(currMaxMoney) Then
								nextbt = checkNextBT(gate1)
								If nextbt>0 Then
									isCont = True
									If Me.moneyFieldValue >= m1 Then
										spords = spords & spord &","
										Call Log("审批流程：[gate1 = "& gate1 &"][moneyFieldValue:"& moneyFieldValue &" < currMaxMoney:"& currMaxMoney &" And nextbt > 0 And moneyFieldValue:"& moneyFieldValue &" > m1:"& m1 &"][spord = "& spord &"][后面走必经流程]")
									else
										Call Log("审批流程：[gate1 = "& gate1 &"][moneyFieldValue:"& moneyFieldValue &" < currMaxMoney:"& currMaxMoney &" And nextbt > 0 And moneyFieldValue:"& moneyFieldValue &" > m1:"& m1 &"][后面走必经流程]")
									end if
								else
									If checkLastMoney(gate1,Me.moneyFieldValue) > 0 Then
										isCont = True
										Call Log("审批流程：[gate1 = "& gate1 &"][moneyFieldValue:"& moneyFieldValue &" < currMaxMoney:"& currMaxMoney &" And nextbt = 0 And checkLastMoney > 0][前面流程已结束，后面走必经流程]")
									else
										If Me.moneyFieldValue >= m1 Then
											spords = spords & spord &","
											Call Log("审批流程：[gate1 = "& gate1 &"][spord = "& spord &"][moneyFieldValue:"& moneyFieldValue &" < currMaxMoney:"& currMaxMoney &" And moneyFieldValue >= m1:"& m1 &"][后面没有必经流程，到此结束]")
											Exit Do
										end if
									end if
								end if
							else
								If Me.moneyFieldValue >= m1 Then
									spords = spords & spord &","
									Call Log("审批流程：[gate1 = "& gate1 &"][spord = "& spord &"][moneyFieldValue:"& moneyFieldValue &" > currMaxMoney:"& currMaxMoney &" And moneyFieldValue >= m1:"& m1 &"]")
								end if
							end if
						else
							spords = spords & spord &","
							Call Log("审批流程：[gate1 = "& gate1 &"][spord = "& spord &"]")
						end if
					end if
					rs.movenext
				Loop
			else
				spords = 0
			end if
			rs.close
			set rs = nothing
			nextSpList = spords
		end function
		Public  Function spRollback()
			Dim backSPStr, nowSpGate
			backSPStr = ""
			nowSpGate = 0
			Set rs = config.con.execute("select  b.gate1 from "& config.tabName &" a left join sp b on a.sp=b.id where a."& config.keyField &"="& Me.BillID)
			If rs.eof=False Then
				nowSpGate = rs("gate1")
			end if
			rs.close
			set rs = nothing
			sql ="select t1.sp_id, t1.sp, t1.cateid, e.name from sp_intro t1 inner join( "&_
			"  select MAX(a.id) maxOrd,c.gate1 "&_
			"  from sp_intro a left join sp c on ISNULL(a.sp_id,0)=c.id "&_
			"  where a.sort1="& config.clsId &" and a.ord="& Me.BillID &" and ISNULL(c.gate1,0)>0 and a.jg=1 "&_
			"  group by c.gate1 "&_
			") t2 on t1.id=t2.maxOrd "&_
			"left join sp d on ISNULL(t1.sp_id,0)=d.id "&_
			"left join gate e on t1.cateid=e.ord and e.del=1 "&_
			"where d.gate1<"& nowSpGate &" order by t1.date1 desc"
			Set rs = config.con.execute(sql)
			While rs.eof=False
				backSPStr = backSPStr & rs("sp_id") &"[|]"& rs("sp") &"[|]"& rs("cateid") &"="& rs("name") &"{|}"
				rs.movenext
			wend
			rs.close
			set rs = nothing
			Me.backSPInfo = backSPStr
		end function
		Function nextSPSelect(showType, swicthFieldValue, moneyFieldValue)
			Dim nextSpId, nextGates, tempStr, i, arr_gates1, arr_gates2
			If showType&"" = "" Then showType = "Select"
			Call loadNextSp2(swicthFieldValue, moneyFieldValue)
			nextSpId = Me.nextSpId
			nextGates = Me.nextGates
			tempStr = ""
			If showType = "Select" Then
				tempStr = tempStr &"<select name='cateid_sp' id='cateid_sp' datatype='Limit'  min='1' max='50' msg='请选择审批人'>"
				tempStr = tempStr &"<option value=''>请选择</option>"
				if nextGates&""<>"" then
					arr_gates1 = split(nextGates,"|")
					for i=0 to ubound(arr_gates1)
						if arr_gates1(i)&""<>"" then
							arr_gates2 = split(arr_gates1(i),"=")
							tempStr = tempStr &"<option value='"& arr_gates2(0) &"'>"& arr_gates2(1) &"</option>"
						end if
					next
				end if
				tempStr = tempStr &"</select><input type='hidden' name='sp' value='"& nextSpId &"'>"
				tempStr = tempStr &" <span class='red'>*</span>"
			ElseIf showType = "sql"   Then
				if nextGates&""<>"" then
					arr_gates1 = split(nextGates,"|")
					for i=0 to ubound(arr_gates1)
						if arr_gates1(i)&""<>"" then
							arr_gates2 = split(arr_gates1(i),"=")
							If tempStr <>"" Then  tempStr = tempStr & " union all  "
							tempStr = tempStr & " select '"& arr_gates2(1) &"' as name, "&arr_gates2(0)&" as ord "
						end if
					next
				end if
			end if
			nextSPSelect = tempStr
		end function
		Function showSpRecords(cn,sort1,ord,cols)
			Dim Rs0, sql0, spname, resultStr, col2, rssp, sp_id
			If cols&"" = "" Then cols = 6
			If cols = 6 Or cols = 4 Then
				col2 = 1
			ElseIf cols = 8 Then
				col2 = 2
			end if
			Response.write "" & vbcrlf & "             <tr class=""top resetTableBg""><td height=""30"" class='fcell' colspan="""
			Response.write cols
			Response.write """><div class='group-title'>审批记录</div></td></tr>" & vbcrlf & "         <tr><td height=""30"" colspan="""
			Response.write cols
			Response.write """>" & vbcrlf & "          <table style='width:100%' border='0' cellpadding='4' cellspacing='1' bgcolor='#C0CCDD' id='content'>" & vbcrlf & "            <tr height=""27"" class=""top resetGroupTableBg"">" & vbcrlf & "                      <td width=""20%""><div align=""center"">审批阶段</div></td>" & vbcrlf & "                     <td width=""15%"" colspan="""
			Response.write col2
			Response.write """><div align=""center"">审批时间</div></td>" & vbcrlf & "                     <td width=""15%""><div align=""center"">审批结果</div></td>" & vbcrlf & "                     <td width=""20%"" colspan="""
			Response.write col2
			Response.write """><div align=""center"">审批人员</div></td>" & vbcrlf & "                     <td width=""30%"" colspan="""
			Response.write col2
			Response.write """><div align=""center"">审批意见</div></td>" & vbcrlf & "             </tr>" & vbcrlf & "           "
			sql0= "select a.sp, a.date1, a.cateid, a.jg, a.intro, a.sp_id, b.sort1 spname from sp_intro a left join sp b on isnull(a.sp_id,0)=b.id where a.ord="&ord&" and a.sort1="& sort1 &" order by a.id asc "
			Set Rs0 = server.CreateObject("adodb.recordset")
			Rs0.open sql0,cn,1,1
			if rs0.eof = False then
				do until rs0.eof=True
					spname=rs0("sp") : sp_id = rs0("sp_id")
					if sp_id&""="" And isnumeric(spname) then
						set rssp=cn.execute("select sort1 from sp where gate2="& sort1 &" and id=" & spname)
						if not rssp.eof then spname=rssp(0)
						rssp.close
						Set rssp = Nothing
					end if
					if not isnull(rs0("spname")) then spname=rs0("spname")
					If Rs0("jg")=1 Then
						resultStr="同意"
					else
						resultStr="否决"
					end if
					Response.write "" & vbcrlf & "                              <tr>" & vbcrlf & "                            <td height=""27"" class=""gray""><div align=""center"">"
					Response.write spname
					Response.write "</div></td>" & vbcrlf & "                           <td height=""27"" colspan="""
					Response.write col2
					Response.write """ class=""gray""><div align=""center"">"
					Response.write rs0("date1")
					Response.write "</div></td>" & vbcrlf & "                           <td height=""27""  class=""gray""><div align=""center"">"
					Response.write resultStr
					Response.write "</div></td>" & vbcrlf & "                           <td width=""11%"" height=""27"" colspan="""
					Response.write col2
					Response.write """ class=""gray""><div align=""center"">"
					Response.write ShowSignImage(setname("gate","ord",rs0("cateid"),"name"),rs0("cateid"),rs0("date1"))
					Response.write "</div></td>   " & vbcrlf & "                                <td width=""15%"" height=""27"" colspan="""
					Response.write col2
					Response.write """ class=""gray""><div align=""center"">"
					Response.write rs0("intro")
					Response.write "</div></td>" & vbcrlf & "                           </tr>" & vbcrlf & "                           "
					rs0.movenext
				loop
			else
				Response.write "<tr><td colspan="& cols &" align=center height=27>暂无记录</td></tr>"
			end if
			Response.write "</table>" & vbcrlf & "              </td></tr>" & vbcrlf & "              "
			rs0.close
			Set rs0 = Nothing
		end function
		Sub setBillSwith()
			dim sql2
			sql2 = ""
			if config.swicthField &""<>"" then
				sql2 = sql2 & "isnull("& config.swicthField & ",0) "
			else
				sql2 = sql2 & "0 "
			end if
			if config.moneyField &""<>"" then
				sql2 = sql2 &", isnull("& config.moneyField &",0) "
			else
				sql2 = sql2 & ", 0 "
			end if
			set rs = config.con.execute("select "& sql2 &" from "& config.tabName &" where "& config.keyField &"="& Me.BillID)
			if rs.eof = false then
				Me.swicthFieldValue = rs(0)
				Me.moneyFieldValue = rs(1)
			end if
			rs.close
			set rs = nothing
			Call setSwicthFieldValue(Me.BillID , config.clsId)
		end sub
		Private function iif(byval cv,byval ov1,byval ov2)
			if cv then iif=ov1 : exit function
			iif=ov2
		end function
		Private Function getGateName(ord)
			If ord&"" = "" Or isnumeric(ord&"") = False Then
				Exit Function
			end if
			Dim rs, cateName
			cateName = ""
			Set rs = config.con.Execute("select name from gate where ord="& ord)
			If rs.eof = False Then
				cateName = rs("name")
			end if
			rs.close
			set rs = nothing
			getGateName = cateName
		end function
		Private function ShowSignImage(catename, cateid, billdate)
			dim rs , sql
			sql =  "if exists(select 1 from setjm3 where ord=201207051 and num1=1)" & vbcrlf & _
			"begin" & vbcrlf & _
			"    select top 1 id from erp_filedatas where title='" & cateid & "' and datediff(d,date,'" & billdate & "')>=0 and folder='私人章' order by date desc, id " & vbcrlf & _
			"end" & vbcrlf & _
			"else" & vbcrlf & "begin" & vbcrlf & " select top 0 0 as id" & vbcrlf & "end"
			set rs = config.con.Execute(sql)
			if rs.eof = false then
				ShowSignImage = "<img src='../sdk/getdata.asp?id=" & rs.fields("id").value & "'>"
			else
				ShowSignImage = catename
			end if
			rs.close
		end function
		Private Function setname(tname,zname,values,rname)
			Dim names, rs
			names=""
			if values<>"" Then
				Set rs = config.con.execute("select * from "&tname&" where "&zname&"="&values&" ")
				if not rs.eof then
					names=rs(""&rname&"")
				end if
				rs.close
				set rs=nothing
			end if
			setname=names
		end function
		Private Function ExistsProc(subName)
			on error resume next
			Call TypeName(getref(subName))
			ExistsProc = (Len(Err.description)=0)
		end function
		Private Sub TryExecuteProc(subName)
			Execute subName
		end sub
		Private Sub  Log(v)
			If logOn <> True Then Exit Sub
			ArrLog(logIdx) = (logIdx+1) &". "& v & vbcrlf
'If logOn <> True Then Exit Sub
			logIdx = logIdx + 1
'If logOn <> True Then Exit Sub
		end sub
		Private Sub saveLog()
			If logOn <> True Then Exit Sub
			Dim strHTML, fso, fw, filepath, f
			set fso=server.CreateObject("Scripting.FileSystemObject")
			filepath=server.mappath(logFile)
			if fso.FileExists(filepath) then
				set f=fso.getfile(filepath)
				if f.attributes and 1 then f.attributes=f.attributes-1
'set f=fso.getfile(filepath)
				set f=nothing
			end if
			set fw = fso.opentextfile(filepath,8,TRUE,TristateTrue)
			strHTML = Join(ArrLog,"")
			fw.Write strHTML & vbcrlf
			fw.close
			set fw=nothing
			set fso=nothing
		end sub
		Private Sub Class_Terminate()
			Call saveLog()
		end sub
	End Class
	response.Clear()
	response.Charset = "UTF-8"
	response.Clear()
	Dim ty, bill, top, money1, sptype, sp, cateid_sp, jg, intro, isSaveSp
	ty = request("ty")
	bill = request("bill")
	top = request("top")
	money1 = Replace(Replace(request("money1"),",",""),"，","")
	sptype = request("sptype")
	sp = request("sp")
	cateid_sp = request("cateid_sp")
	jg = request("jg")
	intro = request("intro")
	useCateid = request("useCateid")
	If top&"" = "" Then top = 0
	If sptype&"" = "" Then sptype = 0
	If money1&"" = "" Then money1 = 0
	If Not isnumeric(money1) Then Response.write "您提交的数据【"&money1 & "】不是有效的金额值" : conn.close :  Response.end
	If sp&"" = "" Then sp = 0
	If cateid_sp&"" = "" Then cateid_sp = 0
	If useCateid&"" = "" Then useCateid = 0 Else useCateid = CLng(useCateid)
	Set commSP = New CommSPHandle
	Call commSP.init(bill,top)
	If commSP.ReturnIntro<>"" Then Response.write commSP.ReturnIntro : conn.close :  Response.end
	Dim reback : reback = request("reback")
	If reback="1" Then commSP.reback=True
	If useCateid > 0 Then
		commSP.UseCateid = useCateid
	end if
	Select Case ty
	Case "1"
	Call commSP.loadNextSp()
	Response.write commSP.nextSpId &"$#"& commSP.nextGates
	Case "2"
	Call commSP.loadNextSp2(sptype,money1)
	Response.write commSP.nextSpId &"$#"& commSP.nextGates
	Case "3"
	Call commSP.saveBill2(sp, cateid_sp, sptype, money1)
	Case "4"
	isSaveSp = False
	isSaveSp = commSP.saveSP(jg, intro,sp, cateid_sp, money1)
	If isSaveSp=True Then
		Response.write "1"
	else
		Response.write "0"
	end if
	Case "5"
	Call commSP.spRollback()
	Response.write commSP.backSPInfo
	Case "6"
	isSaveSp = False
	isSaveSp = commSP.saveSP2(jg, intro,sp, cateid_sp, swicthValue, money1)
	If isSaveSp=True Then
		Response.write "1"
	else
		Response.write "0"
	end if
	End Select
	
%>
