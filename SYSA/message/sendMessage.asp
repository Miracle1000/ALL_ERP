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
	
	Private Const BITS_TO_A_BYTE = 8
	Private Const BYTES_TO_A_WORD = 4
	Private Const BITS_TO_A_WORD = 32
	Private m_lOnBits(30)
	Private m_l2Power(30)
	Private Function LShift(lValue, iShiftBits)
		If iShiftBits = 0 Then
			LShift = lValue
			Exit Function
		ElseIf iShiftBits = 31 Then
			If lValue And 1 Then
				LShift = &H80000000
			else
				LShift = 0
			end if
			Exit Function
		ElseIf iShiftBits < 0 Or iShiftBits > 31 Then
			Err.Raise 6
		end if
		If (lValue And m_l2Power(31 - iShiftBits)) Then
			'Err.Raise 6
			LShift = ((lValue And m_lOnBits(31 - (iShiftBits + 1))) * m_l2Power(iShiftBits)) Or &H80000000
			'Err.Raise 6
		else
			LShift = ((lValue And m_lOnBits(31 - iShiftBits)) * m_l2Power(iShiftBits))
			'Err.Raise 6
		end if
	end function
	Private Function str2bin(varstr)
		Dim varasc
		Dim i
		Dim varchar
		Dim varlow
		Dim varhigh
		str2bin=""
		For i=1 To Len(varstr)
			varchar=mid(varstr,i,1)
			varasc = Asc(varchar)
			If varasc<0 Then
				varasc = varasc + 65535
'If varasc<0 Then
			end if
			If varasc>255 Then
				varlow = Left(Hex(Asc(varchar)),2)
				varhigh = right(Hex(Asc(varchar)),2)
				str2bin = str2bin & chrB("&H" & varlow) & chrB("&H" & varhigh)
			else
				str2bin = str2bin & chrB(AscB(varchar))
			end if
		next
	end function
	Private Function RShift(lValue, iShiftBits)
		If iShiftBits = 0 Then
			RShift = lValue
			Exit Function
		ElseIf iShiftBits = 31 Then
			If lValue And &H80000000 Then
				RShift = 1
			else
				RShift = 0
			end if
			Exit Function
		ElseIf iShiftBits < 0 Or iShiftBits > 31 Then
			Err.Raise 6
		end if
		RShift = (lValue And &H7FFFFFFE) \ m_l2Power(iShiftBits)
		If (lValue And &H80000000) Then
			RShift = (RShift Or (&H40000000 \ m_l2Power(iShiftBits - 1)))
'If (lValue And &H80000000) Then
		end if
	end function
	Private Function RotateLeft(lValue, iShiftBits)
		RotateLeft = LShift(lValue, iShiftBits) Or RShift(lValue, (32 - iShiftBits))
'Private Function RotateLeft(lValue, iShiftBits)
	end function
	Private Function AddUnsigned(lX, lY)
		Dim lX4
		Dim lY4
		Dim lX8
		Dim lY8
		Dim lResult
		lX8 = lX And &H80000000
		lY8 = lY And &H80000000
		lX4 = lX And &H40000000
		lY4 = lY And &H40000000
		lResult = (lX And &H3FFFFFFF) + (lY And &H3FFFFFFF)
		lY4 = lY And &H40000000
		If lX4 And lY4 Then
			lResult = lResult Xor &H80000000 Xor lX8 Xor lY8
		ElseIf lX4 Or lY4 Then
			If lResult And &H40000000 Then
				lResult = lResult Xor &HC0000000 Xor lX8 Xor lY8
			else
				lResult = lResult Xor &H40000000 Xor lX8 Xor lY8
			end if
		else
			lResult = lResult Xor lX8 Xor lY8
		end if
		AddUnsigned = lResult
	end function
	Private Function md5_F(x, y, z)
		md5_F = (x And y) Or ((Not x) And z)
	end function
	Private Function md5_G(x, y, z)
		md5_G = (x And z) Or (y And (Not z))
	end function
	Private Function md5_H(x, y, z)
		md5_H = (x Xor y Xor z)
	end function
	Private Function md5_I(x, y, z)
		md5_I = (y Xor (x Or (Not z)))
	end function
	Private Sub md5_FF(a, b, c, d, x, s, ac)
		a = AddUnsigned(a, AddUnsigned(AddUnsigned(md5_F(b, c, d), x), ac))
		a = RotateLeft(a, s)
		a = AddUnsigned(a, b)
	end sub
	Private Sub md5_GG(a, b, c, d, x, s, ac)
		a = AddUnsigned(a, AddUnsigned(AddUnsigned(md5_G(b, c, d), x), ac))
		a = RotateLeft(a, s)
		a = AddUnsigned(a, b)
	end sub
	Private Sub md5_HH(a, b, c, d, x, s, ac)
		a = AddUnsigned(a, AddUnsigned(AddUnsigned(md5_H(b, c, d), x), ac))
		a = RotateLeft(a, s)
		a = AddUnsigned(a, b)
	end sub
	Private Sub md5_II(a, b, c, d, x, s, ac)
		a = AddUnsigned(a, AddUnsigned(AddUnsigned(md5_I(b, c, d), x), ac))
		a = RotateLeft(a, s)
		a = AddUnsigned(a, b)
	end sub
	Private Function ConvertToWordArray(sMessage)
		Dim lMessageLength
		Dim lNumberOfWords
		Dim lWordArray()
		Dim lBytePosition
		Dim lByteCount
		Dim lWordCount
		Const MODULUS_BITS = 512
		Const CONGRUENT_BITS = 448
		lMessageLength = LenB(sMessage)
		lNumberOfWords = (((lMessageLength + ((MODULUS_BITS - CONGRUENT_BITS) \ BITS_TO_A_BYTE)) \ (MODULUS_BITS \ BITS_TO_A_BYTE)) + 1) * (MODULUS_BITS \ BITS_TO_A_WORD)
		'lMessageLength = LenB(sMessage)
		ReDim lWordArray(lNumberOfWords - 1)
		'lMessageLength = LenB(sMessage)
		lBytePosition = 0
		lByteCount = 0
		Do Until lByteCount >= lMessageLength
			lWordCount = lByteCount \ BYTES_TO_A_WORD
			lBytePosition = (lByteCount Mod BYTES_TO_A_WORD) * BITS_TO_A_BYTE
			lWordArray(lWordCount) = lWordArray(lWordCount) Or LShift(AscB(MidB(sMessage, lByteCount + 1, 1)), lBytePosition)
			'lBytePosition = (lByteCount Mod BYTES_TO_A_WORD) * BITS_TO_A_BYTE
			lByteCount = lByteCount + 1
			'lBytePosition = (lByteCount Mod BYTES_TO_A_WORD) * BITS_TO_A_BYTE
		Loop
		'lWordCount = lByteCount \ BYTES_TO_A_WORD
		'lBytePosition = (lByteCount Mod BYTES_TO_A_WORD) * BITS_TO_A_BYTE
		lWordArray(lWordCount) = lWordArray(lWordCount) Or LShift(&H80, lBytePosition)
		lWordArray(lNumberOfWords - 2) = LShift(lMessageLength, 3)
		'lWordArray(lWordCount) = lWordArray(lWordCount) Or LShift(&H80, lBytePosition)
		lWordArray(lNumberOfWords - 1) = RShift(lMessageLength, 29)
		'lWordArray(lWordCount) = lWordArray(lWordCount) Or LShift(&H80, lBytePosition)
		ConvertToWordArray = lWordArray
	end function
	Private Function WordToHex(lValue)
		Dim lByte
		Dim lCount
		For lCount = 0 To 3
			lByte = RShift(lValue, lCount * BITS_TO_A_BYTE) And m_lOnBits(BITS_TO_A_BYTE - 1)
'For lCount = 0 To 3
			WordToHex = WordToHex & Right("0" & Hex(lByte), 2)
		next
	end function
	Public Function MD5(sMessage)
		m_lOnBits(0) = CLng(1)
		m_lOnBits(1) = CLng(3)
		m_lOnBits(2) = CLng(7)
		m_lOnBits(3) = CLng(15)
		m_lOnBits(4) = CLng(31)
		m_lOnBits(5) = CLng(63)
		m_lOnBits(6) = CLng(127)
		m_lOnBits(7) = CLng(255)
		m_lOnBits(8) = CLng(511)
		m_lOnBits(9) = CLng(1023)
		m_lOnBits(10) = CLng(2047)
		m_lOnBits(11) = CLng(4095)
		m_lOnBits(12) = CLng(8191)
		m_lOnBits(13) = CLng(16383)
		m_lOnBits(14) = CLng(32767)
		m_lOnBits(15) = CLng(65535)
		m_lOnBits(16) = CLng(131071)
		m_lOnBits(17) = CLng(262143)
		m_lOnBits(18) = CLng(524287)
		m_lOnBits(19) = CLng(1048575)
		m_lOnBits(20) = CLng(2097151)
		m_lOnBits(21) = CLng(4194303)
		m_lOnBits(22) = CLng(8388607)
		m_lOnBits(23) = CLng(16777215)
		m_lOnBits(24) = CLng(33554431)
		m_lOnBits(25) = CLng(67108863)
		m_lOnBits(26) = CLng(134217727)
		m_lOnBits(27) = CLng(268435455)
		m_lOnBits(28) = CLng(536870911)
		m_lOnBits(29) = CLng(1073741823)
		m_lOnBits(30) = CLng(2147483647)
		m_l2Power(0) = CLng(1)
		m_l2Power(1) = CLng(2)
		m_l2Power(2) = CLng(4)
		m_l2Power(3) = CLng(8)
		m_l2Power(4) = CLng(16)
		m_l2Power(5) = CLng(32)
		m_l2Power(6) = CLng(64)
		m_l2Power(7) = CLng(128)
		m_l2Power(8) = CLng(256)
		m_l2Power(9) = CLng(512)
		m_l2Power(10) = CLng(1024)
		m_l2Power(11) = CLng(2048)
		m_l2Power(12) = CLng(4096)
		m_l2Power(13) = CLng(8192)
		m_l2Power(14) = CLng(16384)
		m_l2Power(15) = CLng(32768)
		m_l2Power(16) = CLng(65536)
		m_l2Power(17) = CLng(131072)
		m_l2Power(18) = CLng(262144)
		m_l2Power(19) = CLng(524288)
		m_l2Power(20) = CLng(1048576)
		m_l2Power(21) = CLng(2097152)
		m_l2Power(22) = CLng(4194304)
		m_l2Power(23) = CLng(8388608)
		m_l2Power(24) = CLng(16777216)
		m_l2Power(25) = CLng(33554432)
		m_l2Power(26) = CLng(67108864)
		m_l2Power(27) = CLng(134217728)
		m_l2Power(28) = CLng(268435456)
		m_l2Power(29) = CLng(536870912)
		m_l2Power(30) = CLng(1073741824)
		Dim x
		Dim k
		Dim AA
		Dim BB
		Dim CC
		Dim DD
		Dim a
		Dim b
		Dim c
		Dim d
		Const S11 = 7
		Const S12 = 12
		Const S13 = 17
		Const S14 = 22
		Const S21 = 5
		Const S22 = 9
		Const S23 = 14
		Const S24 = 20
		Const S31 = 4
		Const S32 = 11
		Const S33 = 16
		Const S34 = 23
		Const S41 = 6
		Const S42 = 10
		Const S43 = 15
		Const S44 = 21
		x = ConvertToWordArray(str2bin(sMessage))
		a = &H67452301
		b = &HEFCDAB89
		c = &H98BADCFE
		d = &H10325476
		For k = 0 To UBound(x) Step 16
			AA = a
			BB = b
			CC = c
			DD = d
			md5_FF a, b, c, d, x(k + 0), S11, &HD76AA478
'DD = d
			md5_FF d, a, b, c, x(k + 1), S12, &HE8C7B756
'DD = d
			md5_FF c, d, a, b, x(k + 2), S13, &H242070DB
'DD = d
			md5_FF b, c, d, a, x(k + 3), S14, &HC1BDCEEE
'DD = d
			md5_FF a, b, c, d, x(k + 4), S11, &HF57C0FAF
'DD = d
			md5_FF d, a, b, c, x(k + 5), S12, &H4787C62A
'DD = d
			md5_FF c, d, a, b, x(k + 6), S13, &HA8304613
'DD = d
			md5_FF b, c, d, a, x(k + 7), S14, &HFD469501
'DD = d
			md5_FF a, b, c, d, x(k + 8), S11, &H698098D8
'DD = d
			md5_FF d, a, b, c, x(k + 9), S12, &H8B44F7AF
'DD = d
			md5_FF c, d, a, b, x(k + 10), S13, &HFFFF5BB1
'DD = d
			md5_FF b, c, d, a, x(k + 11), S14, &H895CD7BE
'DD = d
			md5_FF a, b, c, d, x(k + 12), S11, &H6B901122
'DD = d
			md5_FF d, a, b, c, x(k + 13), S12, &HFD987193
'DD = d
			md5_FF c, d, a, b, x(k + 14), S13, &HA679438E
'DD = d
			md5_FF b, c, d, a, x(k + 15), S14, &H49B40821
'DD = d
			md5_GG a, b, c, d, x(k + 1), S21, &HF61E2562
'DD = d
			md5_GG d, a, b, c, x(k + 6), S22, &HC040B340
'DD = d
			md5_GG c, d, a, b, x(k + 11), S23, &H265E5A51
'DD = d
			md5_GG b, c, d, a, x(k + 0), S24, &HE9B6C7AA
'DD = d
			md5_GG a, b, c, d, x(k + 5), S21, &HD62F105D
'DD = d
			md5_GG d, a, b, c, x(k + 10), S22, &H2441453
'DD = d
			md5_GG c, d, a, b, x(k + 15), S23, &HD8A1E681
'DD = d
			md5_GG b, c, d, a, x(k + 4), S24, &HE7D3FBC8
'DD = d
			md5_GG a, b, c, d, x(k + 9), S21, &H21E1CDE6
'DD = d
			md5_GG d, a, b, c, x(k + 14), S22, &HC33707D6
'DD = d
			md5_GG c, d, a, b, x(k + 3), S23, &HF4D50D87
'DD = d
			md5_GG b, c, d, a, x(k + 8), S24, &H455A14ED
'DD = d
			md5_GG a, b, c, d, x(k + 13), S21, &HA9E3E905
'DD = d
			md5_GG d, a, b, c, x(k + 2), S22, &HFCEFA3F8
'DD = d
			md5_GG c, d, a, b, x(k + 7), S23, &H676F02D9
'DD = d
			md5_GG b, c, d, a, x(k + 12), S24, &H8D2A4C8A
'DD = d
			md5_HH a, b, c, d, x(k + 5), S31, &HFFFA3942
'DD = d
			md5_HH d, a, b, c, x(k + 8), S32, &H8771F681
'DD = d
			md5_HH c, d, a, b, x(k + 11), S33, &H6D9D6122
'DD = d
			md5_HH b, c, d, a, x(k + 14), S34, &HFDE5380C
'DD = d
			md5_HH a, b, c, d, x(k + 1), S31, &HA4BEEA44
'DD = d
			md5_HH d, a, b, c, x(k + 4), S32, &H4BDECFA9
'DD = d
			md5_HH c, d, a, b, x(k + 7), S33, &HF6BB4B60
'DD = d
			md5_HH b, c, d, a, x(k + 10), S34, &HBEBFBC70
'DD = d
			md5_HH a, b, c, d, x(k + 13), S31, &H289B7EC6
'DD = d
			md5_HH d, a, b, c, x(k + 0), S32, &HEAA127FA
'DD = d
			md5_HH c, d, a, b, x(k + 3), S33, &HD4EF3085
'DD = d
			md5_HH b, c, d, a, x(k + 6), S34, &H4881D05
'DD = d
			md5_HH a, b, c, d, x(k + 9), S31, &HD9D4D039
'DD = d
			md5_HH d, a, b, c, x(k + 12), S32, &HE6DB99E5
'DD = d
			md5_HH c, d, a, b, x(k + 15), S33, &H1FA27CF8
'DD = d
			md5_HH b, c, d, a, x(k + 2), S34, &HC4AC5665
'DD = d
			md5_II a, b, c, d, x(k + 0), S41, &HF4292244
'DD = d
			md5_II d, a, b, c, x(k + 7), S42, &H432AFF97
'DD = d
			md5_II c, d, a, b, x(k + 14), S43, &HAB9423A7
'DD = d
			md5_II b, c, d, a, x(k + 5), S44, &HFC93A039
'DD = d
			md5_II a, b, c, d, x(k + 12), S41, &H655B59C3
'DD = d
			md5_II d, a, b, c, x(k + 3), S42, &H8F0CCC92
'DD = d
			md5_II c, d, a, b, x(k + 10), S43, &HFFEFF47D
'DD = d
			md5_II b, c, d, a, x(k + 1), S44, &H85845DD1
'DD = d
			md5_II a, b, c, d, x(k + 8), S41, &H6FA87E4F
'DD = d
			md5_II d, a, b, c, x(k + 15), S42, &HFE2CE6E0
'DD = d
			md5_II c, d, a, b, x(k + 6), S43, &HA3014314
'DD = d
			md5_II b, c, d, a, x(k + 13), S44, &H4E0811A1
'DD = d
			md5_II a, b, c, d, x(k + 4), S41, &HF7537E82
'DD = d
			md5_II d, a, b, c, x(k + 11), S42, &HBD3AF235
'DD = d
			md5_II c, d, a, b, x(k + 2), S43, &H2AD7D2BB
'DD = d
			md5_II b, c, d, a, x(k + 9), S44, &HEB86D391
'DD = d
			a = AddUnsigned(a, AA)
			b = AddUnsigned(b, BB)
			c = AddUnsigned(c, CC)
			d = AddUnsigned(d, DD)
		next
		MD5 = LCase(WordToHex(a) & WordToHex(b) & WordToHex(c) & WordToHex(d))
	end function
	Public Function MD5_16Bit(sMessage)
		m_lOnBits(0) = CLng(1)
		m_lOnBits(1) = CLng(3)
		m_lOnBits(2) = CLng(7)
		m_lOnBits(3) = CLng(15)
		m_lOnBits(4) = CLng(31)
		m_lOnBits(5) = CLng(63)
		m_lOnBits(6) = CLng(127)
		m_lOnBits(7) = CLng(255)
		m_lOnBits(8) = CLng(511)
		m_lOnBits(9) = CLng(1023)
		m_lOnBits(10) = CLng(2047)
		m_lOnBits(11) = CLng(4095)
		m_lOnBits(12) = CLng(8191)
		m_lOnBits(13) = CLng(16383)
		m_lOnBits(14) = CLng(32767)
		m_lOnBits(15) = CLng(65535)
		m_lOnBits(16) = CLng(131071)
		m_lOnBits(17) = CLng(262143)
		m_lOnBits(18) = CLng(524287)
		m_lOnBits(19) = CLng(1048575)
		m_lOnBits(20) = CLng(2097151)
		m_lOnBits(21) = CLng(4194303)
		m_lOnBits(22) = CLng(8388607)
		m_lOnBits(23) = CLng(16777215)
		m_lOnBits(24) = CLng(33554431)
		m_lOnBits(25) = CLng(67108863)
		m_lOnBits(26) = CLng(134217727)
		m_lOnBits(27) = CLng(268435455)
		m_lOnBits(28) = CLng(536870911)
		m_lOnBits(29) = CLng(1073741823)
		m_lOnBits(30) = CLng(2147483647)
		m_l2Power(0) = CLng(1)
		m_l2Power(1) = CLng(2)
		m_l2Power(2) = CLng(4)
		m_l2Power(3) = CLng(8)
		m_l2Power(4) = CLng(16)
		m_l2Power(5) = CLng(32)
		m_l2Power(6) = CLng(64)
		m_l2Power(7) = CLng(128)
		m_l2Power(8) = CLng(256)
		m_l2Power(9) = CLng(512)
		m_l2Power(10) = CLng(1024)
		m_l2Power(11) = CLng(2048)
		m_l2Power(12) = CLng(4096)
		m_l2Power(13) = CLng(8192)
		m_l2Power(14) = CLng(16384)
		m_l2Power(15) = CLng(32768)
		m_l2Power(16) = CLng(65536)
		m_l2Power(17) = CLng(131072)
		m_l2Power(18) = CLng(262144)
		m_l2Power(19) = CLng(524288)
		m_l2Power(20) = CLng(1048576)
		m_l2Power(21) = CLng(2097152)
		m_l2Power(22) = CLng(4194304)
		m_l2Power(23) = CLng(8388608)
		m_l2Power(24) = CLng(16777216)
		m_l2Power(25) = CLng(33554432)
		m_l2Power(26) = CLng(67108864)
		m_l2Power(27) = CLng(134217728)
		m_l2Power(28) = CLng(268435456)
		m_l2Power(29) = CLng(536870912)
		m_l2Power(30) = CLng(1073741824)
		Dim x
		Dim k
		Dim AA
		Dim BB
		Dim CC
		Dim DD
		Dim a
		Dim b
		Dim c
		Dim d
		Const S11 = 7
		Const S12 = 12
		Const S13 = 17
		Const S14 = 22
		Const S21 = 5
		Const S22 = 9
		Const S23 = 14
		Const S24 = 20
		Const S31 = 4
		Const S32 = 11
		Const S33 = 16
		Const S34 = 23
		Const S41 = 6
		Const S42 = 10
		Const S43 = 15
		Const S44 = 21
		x = ConvertToWordArray(sMessage)
		a = &H67452301
		b = &HEFCDAB89
		c = &H98BADCFE
		d = &H10325476
		For k = 0 To UBound(x) Step 16
			AA = a
			BB = b
			CC = c
			DD = d
			md5_FF a, b, c, d, x(k + 0), S11, &HD76AA478
'DD = d
			md5_FF d, a, b, c, x(k + 1), S12, &HE8C7B756
'DD = d
			md5_FF c, d, a, b, x(k + 2), S13, &H242070DB
'DD = d
			md5_FF b, c, d, a, x(k + 3), S14, &HC1BDCEEE
'DD = d
			md5_FF a, b, c, d, x(k + 4), S11, &HF57C0FAF
'DD = d
			md5_FF d, a, b, c, x(k + 5), S12, &H4787C62A
'DD = d
			md5_FF c, d, a, b, x(k + 6), S13, &HA8304613
'DD = d
			md5_FF b, c, d, a, x(k + 7), S14, &HFD469501
'DD = d
			md5_FF a, b, c, d, x(k + 8), S11, &H698098D8
'DD = d
			md5_FF d, a, b, c, x(k + 9), S12, &H8B44F7AF
'DD = d
			md5_FF c, d, a, b, x(k + 10), S13, &HFFFF5BB1
'DD = d
			md5_FF b, c, d, a, x(k + 11), S14, &H895CD7BE
'DD = d
			md5_FF a, b, c, d, x(k + 12), S11, &H6B901122
'DD = d
			md5_FF d, a, b, c, x(k + 13), S12, &HFD987193
'DD = d
			md5_FF c, d, a, b, x(k + 14), S13, &HA679438E
'DD = d
			md5_FF b, c, d, a, x(k + 15), S14, &H49B40821
'DD = d
			md5_GG a, b, c, d, x(k + 1), S21, &HF61E2562
'DD = d
			md5_GG d, a, b, c, x(k + 6), S22, &HC040B340
'DD = d
			md5_GG c, d, a, b, x(k + 11), S23, &H265E5A51
'DD = d
			md5_GG b, c, d, a, x(k + 0), S24, &HE9B6C7AA
'DD = d
			md5_GG a, b, c, d, x(k + 5), S21, &HD62F105D
'DD = d
			md5_GG d, a, b, c, x(k + 10), S22, &H2441453
'DD = d
			md5_GG c, d, a, b, x(k + 15), S23, &HD8A1E681
'DD = d
			md5_GG b, c, d, a, x(k + 4), S24, &HE7D3FBC8
'DD = d
			md5_GG a, b, c, d, x(k + 9), S21, &H21E1CDE6
'DD = d
			md5_GG d, a, b, c, x(k + 14), S22, &HC33707D6
'DD = d
			md5_GG c, d, a, b, x(k + 3), S23, &HF4D50D87
'DD = d
			md5_GG b, c, d, a, x(k + 8), S24, &H455A14ED
'DD = d
			md5_GG a, b, c, d, x(k + 13), S21, &HA9E3E905
'DD = d
			md5_GG d, a, b, c, x(k + 2), S22, &HFCEFA3F8
'DD = d
			md5_GG c, d, a, b, x(k + 7), S23, &H676F02D9
'DD = d
			md5_GG b, c, d, a, x(k + 12), S24, &H8D2A4C8A
'DD = d
			md5_HH a, b, c, d, x(k + 5), S31, &HFFFA3942
'DD = d
			md5_HH d, a, b, c, x(k + 8), S32, &H8771F681
'DD = d
			md5_HH c, d, a, b, x(k + 11), S33, &H6D9D6122
'DD = d
			md5_HH b, c, d, a, x(k + 14), S34, &HFDE5380C
'DD = d
			md5_HH a, b, c, d, x(k + 1), S31, &HA4BEEA44
'DD = d
			md5_HH d, a, b, c, x(k + 4), S32, &H4BDECFA9
'DD = d
			md5_HH c, d, a, b, x(k + 7), S33, &HF6BB4B60
'DD = d
			md5_HH b, c, d, a, x(k + 10), S34, &HBEBFBC70
'DD = d
			md5_HH a, b, c, d, x(k + 13), S31, &H289B7EC6
'DD = d
			md5_HH d, a, b, c, x(k + 0), S32, &HEAA127FA
'DD = d
			md5_HH c, d, a, b, x(k + 3), S33, &HD4EF3085
'DD = d
			md5_HH b, c, d, a, x(k + 6), S34, &H4881D05
'DD = d
			md5_HH a, b, c, d, x(k + 9), S31, &HD9D4D039
'DD = d
			md5_HH d, a, b, c, x(k + 12), S32, &HE6DB99E5
'DD = d
			md5_HH c, d, a, b, x(k + 15), S33, &H1FA27CF8
'DD = d
			md5_HH b, c, d, a, x(k + 2), S34, &HC4AC5665
'DD = d
			md5_II a, b, c, d, x(k + 0), S41, &HF4292244
'DD = d
			md5_II d, a, b, c, x(k + 7), S42, &H432AFF97
'DD = d
			md5_II c, d, a, b, x(k + 14), S43, &HAB9423A7
'DD = d
			md5_II b, c, d, a, x(k + 5), S44, &HFC93A039
'DD = d
			md5_II a, b, c, d, x(k + 12), S41, &H655B59C3
'DD = d
			md5_II d, a, b, c, x(k + 3), S42, &H8F0CCC92
'DD = d
			md5_II c, d, a, b, x(k + 10), S43, &HFFEFF47D
'DD = d
			md5_II b, c, d, a, x(k + 1), S44, &H85845DD1
'DD = d
			md5_II a, b, c, d, x(k + 8), S41, &H6FA87E4F
'DD = d
			md5_II d, a, b, c, x(k + 15), S42, &HFE2CE6E0
'DD = d
			md5_II c, d, a, b, x(k + 6), S43, &HA3014314
'DD = d
			md5_II b, c, d, a, x(k + 13), S44, &H4E0811A1
'DD = d
			md5_II a, b, c, d, x(k + 4), S41, &HF7537E82
'DD = d
			md5_II d, a, b, c, x(k + 11), S42, &HBD3AF235
'DD = d
			md5_II c, d, a, b, x(k + 2), S43, &H2AD7D2BB
'DD = d
			md5_II b, c, d, a, x(k + 9), S44, &HEB86D391
'DD = d
			a = AddUnsigned(a, AA)
			b = AddUnsigned(b, BB)
			c = AddUnsigned(c, CC)
			d = AddUnsigned(d, DD)
		next
		MD5_16Bit=LCase(WordToHex(b) & WordToHex(c))
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
	
	Server.ScriptTimeOut=100000000
	Set base64 = server.createobject(ZBRLibDLLNameSN & ".Base64Class")
	urlWhenError = request("urlWhenError")
	If Len(urlWhenError) > 0 Then
		urlWhenError = base64.decode(urlWhenError)
	end if
	set rs=server.CreateObject("adodb.recordset")
	sql="select * from setMessage order by ord desc"
	rs.open sql,conn,1,1
	if not rs.eof then
		accName=session("UniqueName")
		accPwd=md5(left(accName,8)&"zbintel807")
		lastCon=rs("lastCon")
		openLastCon=trim(rs("openLastCon"))
		urlBalance=rs("urlBalance")
		urlSend=rs("urlSend")
		urlUser=rs("urlUser")
		urlPwd=rs("urlPwd")
		urlMobil=rs("urlMobil")
		urlStrBalance=rs("urlStrBalance")
		urlStrSend=rs("urlStrSend")
		urlContent=rs("urlContent")
	else
		If Len(urlWhenError) = 0 Then
			Response.write "<script language='javascript'> alert('友情提示：您还没有短信账户！'); window.opener=null;window.open('','_self');window.close();</script> "
		else
			Response.write "<script language='javascript'> alert('友情提示：您还没有短信账户！');window.location='" & urlWhenError & "';</script> "
		end if
		call db_close : Response.end
	end if
	rs.close
	set rs=nothing
	if openLastCon=1 then
	else
		openLastCon=0
	end if
	if lastCon<>"" and  openLastCon=1 then
		lenlastCon=len(lastCon)
	end if
	if lenlastCon="" then lenlastCon=0
	Response.write "" & vbcrlf & "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">" & vbcrlf & "<html xmlns=""http://www.w3.org/1999/xhtml"">" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"" />" & vbcrlf & "<title>发送短信</title>" & vbcrlf & "<link href=""../Manufacture/inc/comm.css?ver="
'if lenlastCon="" then lenlastCon=0
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<script language=""javascript"" src=""../inc/system.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ type=""text/javascript""></script>" & vbcrlf & "<script language=""javascript"" src=""http://sms."
	Response.write sdk.info.companysite
	Response.write "/messageserver/sms/keywordsjs.asp?t="
	Response.write (year(date)&month(date)&(day(date)\7))
	Response.write """ type=""text/javascript""></script>" & vbcrlf & "<script language=""javascript"" src=""../inc/SensitiveWords.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ type=""text/javascript""></script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"" src=""../Manufacture/inc/base.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "#MobanList ul{" & vbcrlf & " padding: 0px;" & vbcrlf & "   list-style-type: disc;" & vbcrlf & "  list-style-position: outside;" & vbcrlf & "   margin: 0px;" & vbcrlf & "}" & vbcrlf & "#MobanList ul li{" & vbcrlf & "  color: #573400;" & vbcrlf & "      line-height: 20px;" & vbcrlf & "      height: 20px;" & vbcrlf & "   text-indent: 8px;" & vbcrlf & "}" & vbcrlf & "#page" & vbcrlf & "{" & vbcrlf & "        width:100%;" & vbcrlf & "     text-align: center;" & vbcrlf & "     line-height: 20px;" & vbcrlf & "      height: 20px;" & vbcrlf & "}" & vbcrlf & "#content td{ height:26px}" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "html {padding: 0;overflow:auto;}" & vbcrlf & "-->" & vbcrlf & "#content td{padding-top:4px!important;padding-bottom:4px!important}" & vbcrlf & "</style>" & vbcrlf & "<script>" & vbcrlf & "    function frameResize() {" & vbcrlf& "        document.getElementById(""mxlist"").style.height = I3.document.body.scrollHeight + 20 + ""px"";" & vbcrlf & "    }" & vbcrlf & "" & vbcrlf & "    function clearSendMessage() {" & vbcrlf & "           document.getElementById('messageContent').value='';" & vbcrlf & "             try{document.getElementById('messageContent').innerHTML='';}catch(e){}" & vbcrlf & "                document.getElementById('qccon').style.display='none';" & vbcrlf & "          getWordsLength();" & vbcrlf & "       }" & vbcrlf & "</script>" & vbcrlf & "</head>" & vbcrlf & ""
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
	from = Request("from")
	phone=trim(request("phone"))
	If from = "encrypt" Then
		hiddenNum = HexDecode(phone)
		hiddenNumShow = "***********"
		phone = ""
	end if
	person=trim(request("person"))
	person1=trim(request.Form("person1"))
	person2=trim(request.Form("person2"))
	person3=trim(request.Form("person3"))
	person4=trim(request.Form("person4"))
	personPre=trim(request("personPre"))
	sendType=trim(request("sendType"))
	smsContent=trim(request("content"))
	smsApproval=trim(request("smsApproval"))
	If smsApproval<>"" Then
		needrec=1
	else
		needrec=0
	end if
	if smsContent<>"" then
		lensmsContent=len(smsContent)
	else
		lensmsContent=0
	end if
	qf=trim(request("qf"))
	if sendType="" then sendType=1
	if personPre<>"" then
		if personPre=1 then
			clictPre=person1
		elseif personPre=2 then
			clictPre=person2
		elseif personPre=3 then
			clictPre=person3
		elseif personPre=4 then
			clictPre=person4
		else
			clictPre=""
		end if
	else
		personPre=0
	end if
	if (personPre=1 or personPre=2 or personPre=3) and clictPre<>"" then
		lenPreCon=7
	end if
	if lenPreCon="" then lenPreCon=0
	if open_67_13<>1 then
		If Len(urlWhenError) = 0 Then
			Response.write"<script language=javascript>alert('友情提示：没有权限 ！'); window.opener=null;window.open('','_self');window.close();</script>"
		else
			Response.write"<script language=javascript>alert('友情提示：没有权限 ！'); window.location='" & urlWhenError & "';</script>"
		end if
		call db_close : Response.end
	end if
	if phone<>"" then
		if len(phone)>11 then
			if RegTest(phone,"^\,((13[0-9]|14[0-9]|15[^4]|16[0-9]|17[0-9]|18[0-9]|19[0-9])\d{8}((\,(13[0-9]|14[0-9]|15[^4]|16[0-9]|17[0-9]|18[0-9]|19[0-9])\d{8})*))$")=true then
'if len(phone)>11 then
				phone=mid(""&phone&"",2)
			end if
			if (personPre=1 or personPre=2 or personPre=3) and clictPre<>"" then
				if RegTest(clictPre,"^\,")=true then
					clictPre=mid(""&clictPre&"",2)
				end if
			end if
			if len(phone)>11 then
				if instr(phone,",")>0 then
					ArrPhone=split(phone,",")
					talNum=UBound(ArrPhone)+1
					ArrPhone=split(phone,",")
					for y=0 to UBound(ArrPhone)
						checkMobile(ArrPhone(y))
					next
				else
					If Len(urlWhenError) = 0 Then
						Response.write "<script language='javascript'> alert('友情提示：号码("&phone&")格式不符！'); window.opener=null;window.open('','_self');window.close();</script> "
					else
						Response.write "<script language='javascript'> alert('友情提示：号码("&phone&")格式不符！');window.location='" & urlWhenError & "';</script> "
					end if
					call db_close : Response.end
				end if
			elseif len(phone)=11 then
				checkMobile(phone)
			else
				If Len(urlWhenError) = 0 Then
					Response.write "<script language='javascript'> alert('友情提示：号码("&phone&")格式不符！'); window.opener=null;window.open('','_self');window.close();</script> "
				else
					Response.write "<script language='javascript'> alert('友情提示：号码("&phone&")格式不符！');window.location='" & urlWhenError & "';</script> "
				end if
				call db_close : Response.end
			end if
		else
			checkMobile(phone)
			talNum=1
		end if
	end if
	if talNum="" then talNum=0
	function checkMobile(num1)
		if RegTest(num1,"^(13[0-9]|14[0-9]|15[^4]|16[0-9]|17[0-9]|18[0-9]|19[0-9])\d{8}$")=false then
'function checkMobile(num1)
			If Len(urlWhenError) = 0 Then
				Response.write "<script language='javascript'> alert('友情提示：号码("&num1&")格式不符！只能发送给手机号码'); window.opener=null;window.open('','_self');window.close();</script> "
			else
				Response.write "<script language='javascript'> alert('友情提示：号码("&num1&")格式不符！只能发送给手机号码'); window.location='" & urlWhenError & "';</script> "
			end if
			call db_close : Response.end
		end if
	end function
	set rs=server.CreateObject("adodb.recordset")
	sql="select intro from setjm3  where ord=6"
	rs.open sql,conn,1,1
	if rs.eof then
		intro5=""
	else
		intro5=rs("intro")
	end if
	rs.close
	set rs=nothing
	Response.write "" & vbcrlf & "<style>" & vbcrlf & "IFRAME#mxlist{height:62px!important;}" & vbcrlf & "</style>" & vbcrlf & "<script language=javascript>" & vbcrlf & "window.openLastCon = "
	Response.write openLastCon
	Response.write ";" & vbcrlf & "window.sendPhone = """
	Response.write phone
	Response.write """;" & vbcrlf & "window.sendQF = """
	Response.write qf
	Response.write """;" & vbcrlf & "</script>" & vbcrlf & "<script src= ""../Script/me_sendMessage.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """  language=javascript></script>" & vbcrlf & "<body scrolling='no'   "
	if open_67_8=0 then
		Response.write " oncontextmenu=""return false"" onselectstart=""return false"" ondragstart=""return false"" onbeforecopy=""return false"" oncopy=document.selection.empty()"
	end if
	Response.write " onMouseOver=""window.status='none';return true;"" style=""overflow:auto;"" onLoad=""testfunc();"">" & vbcrlf & "<table width=""100%""  border=""0"" align=""center"" cellpadding=""0"" cellspacing=""0"" bordercolor=""#E2E2E1"" bgcolor=""#FFFFFF"">" & vbcrlf & "  <form name=""date"" id=""date"">"& vbcrlf &"     <tr> "& vbcrlf &"       <td><table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif""> "& vbcrlf &"           <tr> "& vbcrlf &"             <td class=""place"">发送短信</td> "& vbcrlf &"             <td>"
	Response.write GetServerState()
	Response.write "&nbsp;<span class=""red"" id=""showerrmessage""></span></td>" & vbcrlf & "            <td align=""right"" id=""serverStatus"">&nbsp;</td>" & vbcrlf & "            <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "          </tr>" & vbcrlf & "      </table></td>" & vbcrlf & "    </tr>" & vbcrlf & "    <tr>" & vbcrlf & "      <td><table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"" style=""border-collapse:initial;"">" & vbcrlf & "          <tr>" & vbcrlf & "            <td width=""15%"" height=""30"" align=""right""><div align=""right"">发送给：</div></td>" & vbcrlf & "            <td width=""85%"" align=""left"" style=""font-weight: normal;white-space:nowrap;padding-top:4px!important;padding-bottom:4px!important""><table width=""100%"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "  <tr>" & vbcrlf & "                  <td width=""250px"">" & vbcrlf & "                  <textarea name=""hiddenNumShow"" id=""hiddenNumShow"" cols=""50""  rows=""3"" readonly style=""width:460px;"">"
	Response.write hiddenNumShow
	Response.write "</textarea><br>" & vbcrlf & "                  <input type=""hidden"" name=""hiddenNum"" id=""hiddenNum"" value="""
	Response.write hiddenNum
	Response.write """ />" & vbcrlf & "                  <textarea name=""takeName"" cols=""50""  rows=""3"" id=""takeName"" onFocus=""sortNum(this)""  style=""color:#5B7CAE;border:#CCCCCC 1px solid;width:460px;"" onpropertychange=""if(this.value.length>0 ||this.innerText){document.getElementById('qccon1').style.display='inline';document.getElementById('qccon2').style.display='inline'}else{document.getElementById('qccon1').style.display='none';document.getElementById('qccon2').style.display='none';}changeICON();"" onKeyUp=""if(value.match(/[^ \d\,]/g)){value=value.replace(/[^ \d\,]/g,'');};clearSub('takeName','qccon1');sortNum(this);"" datatype=""Message"">"
	Response.write phone
	Response.write "</textarea>" & vbcrlf & "                  </td>" & vbcrlf & "                  <td align=""left""><a href=""javascript:void(0)"" onClick=""clearNum()"" id=""qccon1"" style=""display:none"" title=""清除号码"">【清除号码】</a><br/>" & vbcrlf & "                    <a href=""javascript:void(0)"" onClick=""removeRepeatNum()"" id=""qccon2"" style=""display:none""  title=""号码排重"">【号码排重】</a> </td>" & vbcrlf & "                </tr>" & vbcrlf & "              </table>" & vbcrlf & "              <div style=""padding:6px"">合计(<span id=""tallNum"" style=""color:#FF0000;"">" & vbcrlf & "                "
	if talNum<>"" then Response.write(talNum) else Response.write(0) end if
	Response.write "" & vbcrlf & "                </span>)条。<span style=""font-weight: normal; color:#FF0000"">注意：用英文逗号"",""隔开每个号码，比如：13888888888,18988888888。 </span></div></td>" & vbcrlf & "          </tr>" & vbcrlf & "          <tr >" & vbcrlf & "            <td height=""30"" align=""right"">导入号码：</td>" & vbcrlf & "            <td align=""left"" style='padding-top:4px!important;padding-bottom:4px!important'><div id=""div"">" & vbcrlf & "                <IFRAME name=""I3"" SRC=""../load/UpLoad_mobil.asp"" id=""mxlist"" width=""100%"" onload=""frameResize();sortNum(document.getElementById('takeName'));"" scrolling=no BORDER=0 marginheight=0 marginwidth=0 frameborder=0 target=""_self"" ></IFRAME>" & vbcrlf & "              </div></td>" & vbcrlf & "          </tr>" & vbcrlf & "          <tr  >" & vbcrlf & "            <td  align=""right""><div align=""right"">内容：</div></td>" & vbcrlf & "            <td align=""left"" style='padding-top:4px!important;padding-bottom:4px!important'><div  style=""color:#FF0000"" id=""mecon"">" & vbcrlf & "                <textarea name=""messageContent"" onpropertychange='if(window.event.propertyName==""value""){getWordsLength();}' style=""color:#5B7CAE;border:#CCCCCC 1px solid;overflow-y:hidden;padding:4px;width:460px;"" cols=""56"" rows=""4""  id=""messageContent"">"
	'if talNum<>"" then Response.write(talNum) else Response.write(0) end if
	Response.write smsContent
	Response.write "</textarea>" & vbcrlf & "                <a href=""javascript:void(0)"" onClick=""clearSendMessage()"" id=""qccon"" style=""display:none"" title=""清除内容"">【清除内容】</a> </div>" & vbcrlf & "              <div style=""padding:6px"">" & vbcrlf & "                <span id=""tip"">(共<em>"
	Response.write (lenlastCon+lenPreCon+lensmsContent)
	Response.write "</em>个字,折合"
	Response.write Cint((lenlastCon+lenPreCon+lensmsContent)/64)
	Response.write "</em>个字,折合"
	Response.write "条短信费用),</span><span id='tip2' style='color:#588905'>64 个字/条.</span>" & vbcrlf & "                <span id=""balance"" style=""color:#588905""><span style=""color:#FF0000"" id=""succss""></span></div></td>" & vbcrlf & "          </tr>" & vbcrlf & "          <tr >" & vbcrlf & "            <td height=""30"" align=""right"">模板：</td>" & vbcrlf & "            <td align=""left""  style='padding-top:4px!important;padding-bottom:4px!important'>" & vbcrlf & "                          <div id=""MesMoban"" style=""width:460px; height:115px;border:#CCCCCC 1px solid; padding:6px;overflow:auto"">" & vbcrlf & "                                   <div id=""MesSort"" style=""line-height:20px; ""></div>" & vbcrlf & "                                       <div id=""MobanList"" style=""width:100%; margin:5px 0""></div>" & vbcrlf & "                         </div>" & vbcrlf & "                   </td>" & vbcrlf & "          </tr>" & vbcrlf & "          <tr id=""openZunChen"">" & vbcrlf & "            <td height=""20px"" align=""right"">启用尊称：</td>" & vbcrlf & "            <td align=""left""><input name=""personPre"" type=""radio"" id=""personPre"" onClick=""IGetOpenPre(0);document.getElementById('personPreErr').innerHTML='';"" value=""0"" checked=""checked"" />" & vbcrlf & "              不启用" & vbcrlf & "              <input name=""personPre"" type=""radio"" id=""personPre"" onClick=""IGetOpenPre(1);document.getElementById('personPreErr').innerHTML='例：尊敬的赵先生/小姐';getWordsLength();""  value=""1"" />" & vbcrlf & "              按性别" & vbcrlf & "              <input name=""personPre"" type=""radio"" id=""personPre"" onClick=""IGetOpenPre(2);document.getElementById('personPreErr').innerHTML='例：尊敬的赵经理/主管';getWordsLength();""  value=""2"" />" & vbcrlf & "              按职位" & vbcrlf & "              <input name=""personPre"" type=""radio"" id=""personPre"" onClick=""IGetOpenPre(3);document.getElementById('personPreErr').innerHTML='例：尊敬的赵XX';getWordsLength();""  value=""3"" />" & vbcrlf & "              按姓名" & vbcrlf & "              <input name=""personPre"" type=""radio"" id=""radio"" onClick=""IGetOpenPre(4);document.getElementById('personPreErr').innerHTML='例：尊敬的赵XX经理/主管';getWordsLength();""  value=""4"" />"& vbcrlf &"               按姓名+职位&nbsp;<span style=""color:#FF0000"" id=""personPreErr""></span></td> "& vbcrlf &"           </tr> "& vbcrlf &"           <tr > "& vbcrlf &"             <td height=""20px"" align=""right"">是否定时发送：</td> "& vbcrlf &"             <td align=""left""><input name=""autoSend""  type=""radio"" onClick=""document.getElementById('openAutoTime').style.display='none';IntOpenAutoSend=0"" checked=""checked"" />" & vbcrlf & "              不开启" & vbcrlf & "              <input type=""radio"" name=""autoSend""  onclick=""document.getElementById('openAutoTime').style.display='';IntOpenAutoSend=1;"" value=""1"" />" & vbcrlf & "              开启</td>" & vbcrlf & "          </tr>" & vbcrlf & "          <tr id=""openAutoTime"" style='display:none'>" & vbcrlf & "            <td height=""20px"" align=""right"">定时发送时间：</td>" & vbcrlf & "            <td align=""left""><INPUT name=ret size=9  id=""daysOfMonthPos"" onmouseup=toggleDatePicker(""daysOfMonth"",""date.ret"") value="""
	Response.write date()
	Response.write """>" & vbcrlf & "              日" & vbcrlf & "              <DIV id=daysOfMonth style=""POSITION: absolute;z-index:10"">&nbsp;</DIV>" & vbcrlf & "              <select name=""time1"" id=""time1"">" & vbcrlf & "                <option value=""0"">00</option>" & vbcrlf & "                <optionvalue=""1"">01</option>" & vbcrlf & "                <option value=""2"">02</option>" & vbcrlf & "                <option value=""3"">03</option>" & vbcrlf & "                <option value=""4"">04</option>" & vbcrlf & "                <option value=""5"">05</option>" & vbcrlf & "                <option value=""6"">06</option>" & vbcrlf & "                <option value=""7"">07</option>" & vbcrlf & "                <option value=""8"">08</option>" & vbcrlf & "                <option value=""9"">09</option>" & vbcrlf & "                <option value=""10"">10</option>" & vbcrlf & "            <option value=""11"">11</option>" & vbcrlf & "                <option value=""12"">12</option>" & vbcrlf & "                <option value=""13"">13</option>" & vbcrlf & "                <option value=""14"">14</option>" & vbcrlf & "                <option value=""15"">15</option>" & vbcrlf & "  <option value=""16"">16</option>" & vbcrlf & "                <option value=""17"">17</option>" & vbcrlf & "                <option value=""18"">18</option>" & vbcrlf & "                <option value=""19"">19</option>" & vbcrlf & "                <option value=""20"">20</option>" & vbcrlf & "                <option value=""21"">21</option>" & vbcrlf & "                <option value=""22"">22</option>" & vbcrlf & "                <option value=""23"">23</option>" & vbcrlf & "              </select>" & vbcrlf & "              时" & vbcrlf & "              <select name=""time2"" id=""time2"">" & vbcrlf & "                <option value=""00"">00</option>" & vbcrlf & "                <option value=""05"">05</option>" & vbcrlf & "                <option value=""10"">10</option>" & vbcrlf & "                <option value=""15"">15</option>" & vbcrlf & "                <option value=""20"">20</option>" & vbcrlf & "                <option value=""25"">25</option>" & vbcrlf & "                <option value=""30"">30</option>" & vbcrlf & "                <option value=""35"">35</option>" & vbcrlf & "                <option value=""40"">40</option>" & vbcrlf & "                <option value=""45"">45</option>" & vbcrlf & "                <option value=""50"">50</option>" & vbcrlf & "                <option value=""55"">55</option>" & vbcrlf & "              </select>" & vbcrlf & "              分 </td>" & vbcrlf & "          </tr>" & vbcrlf & "          <tr>" & vbcrlf & "   <td height=""20px"" align=""right"">是否开启短信签名：</td>" & vbcrlf & "            <td align=""left""><input name=""openSignature""  type=""radio"" onClick=""document.getElementById('openLast').style.display='none';openlaststr=0;document.getElementById('signature').value='';getWordsLength();"" "
	if openLastCon=0 or openLastCon="" then
		Response.write "checked=""checked"""
	end if
	Response.write " value=""0""  />" & vbcrlf & "              不开启" & vbcrlf & "              <input type=""radio"" name=""openSignature""  "
	if openLastCon=1 then
		Response.write "checked=""checked"""
	end if
	Response.write "  onclick=""document.getElementById('openLast').style.display='';openlaststr=1;document.getElementById('signature').value='"
	Response.write lastCon
	Response.write "';getWordsLength();"" value=""1"" />" & vbcrlf & "              开启</td>" & vbcrlf & "          </tr>" & vbcrlf & "          <tr  id=""openLast"" "
	if openLastCon<>1 then
		Response.write " style=""display:none"""
	end if
	Response.write ">" & vbcrlf & "            <td height=""20px"" align=""right"">短信签名内容：</td>" & vbcrlf & "            <td align=""left""><input name=""signature"" onKeyUp=""getWordsLength();"" style="" color:#5B7CAE;border:#CCCCCC 1px solid;overflow-y:hidden;padding:4px;"" dataType=""Limit"" min=""1"" max=""50"" value="
	Response.write lastCon
	Response.write """ type=""text"" id=""signature"" size=""20"" maxlength=""50"" />" & vbcrlf & "              例：<a href=""javascript:void(0)"" onClick=""document.getElementById('signature').value='"
	Response.write("【"&intro5&"】")
	Response.write "';getWordsLength();"" title=""点击复制"">【"
	Response.write intro5
	Response.write "】</a></td>" & vbcrlf & "          </tr>" & vbcrlf & "          <tr class=""buttonTableGray"">" & vbcrlf & "            <td height=""20px"" align=""right""  style=""padding-top:4px!important;padding-bottom:4px!important""></td>" & vbcrlf & "            <td align=""left""><div align=""left"" id=""subBut"" style=""color:#FF0000;padding-top:4px!important;padding-bottom:4px!important;height:30px;"">" & vbcrlf & "                <input type=""button"" style=""cursor:pointer;padding-left:5px;padding-right:5px;""  class=""anybutton"" id=""button""  onclick=""sendOnClick()""  value=""发  送"" name=""B8"" >" & vbcrlf & "                &nbsp;&nbsp;&nbsp;" & vbcrlf & "                <input type=""reset"" style=""cursor:pointer;padding-left:5px;padding-right:5px;""  class=""anybutton"" id=""B8"" value=""取  消"" name=""B82"">" & vbcrlf & "                &nbsp;&nbsp;&nbsp;" & vbcrlf & "<input type=""button"" style=""cursor:pointer;padding-left:5px;padding-right:5px;""  class=""anybutton"" id=""B82"" onClick=""ViewSMS(takeName.value,messageContent.value);""   value=""预  览"" name=""B822"" />" & vbcrlf & "              </div></td>" & vbcrlf & "          </tr>" & vbcrlf & "   </table></td>" & vbcrlf & "    </tr>" & vbcrlf & "    <tr>" & vbcrlf & "      <td  class=""page""><table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "          <tr>" & vbcrlf & "            <td style=""background:#efefef;"" height=""30px"" align=""left"" valign=""center"" ><span style=""color:#FF0000"" id=""sendErr""></span></td>" & vbcrlf & "          </tr>" & vbcrlf & "        </table></td>" & vbcrlf & "    </tr>" & vbcrlf & "  </form>" & vbcrlf & "</table>" & vbcrlf & "" & vbcrlf & "<script language=""javascript"" type=""text/javascript"">" & vbcrlf & "<!--" & vbcrlf & "var xmlHttp = GetIE10SafeXmlHttp();" & vbcrlf & "var xmlHttp2 = null;" & vbcrlf & "if(document.getElementById('takeName').value!=""""){" & vbcrlf & "       document.getElementById('qccon1').style.display='inline';" & vbcrlf & "       document.getElementById('qccon2').style.display='inline';" & vbcrlf & "}" & vbcrlf & "function sortNum(obj){" & vbcrlf & "       if(obj.value.length>0){" & vbcrlf & "         var snum=obj.value.split(',');" & vbcrlf & "          if (obj.value.substring(obj.value.length-2,obj.value.length)=="",,""){" & vbcrlf & "                      obj.value=obj.value.substring(0,obj.value.length-1);" & vbcrlf & "                    return;" & vbcrlf & "              }" & vbcrlf & "               if (snum[snum.length-1].length>0){" & vbcrlf & "                      document.getElementById('tallNum').innerHTML=snum.length;" & vbcrlf & "               }else{" & vbcrlf & "                  document.getElementById('tallNum').innerHTML=snum.length-1;" & vbcrlf & "             }" & vbcrlf & "       }" & vbcrlf & "}" & vbcrlf & "//发送第一步"& vbcrlf & "function sendOnClick(){" & vbcrlf & "       var takeName = document.getElementById('takeName');" & vbcrlf & "     var hiddenNum = document.getElementById('hiddenNum');" & vbcrlf & "   var messageContent = document.getElementById('messageContent');" & vbcrlf & " if(Sensitivewords(messageContent.value)==false){return;}" & vbcrlf & " else if ((takeName.value.length>0 || hiddenNum.value.length>0)&&messageContent.value.length>0){" & vbcrlf & "         var phoneArr =takeName.value;" & vbcrlf & "           if(hiddenNum.value.length > 0){" & vbcrlf & "                 if(takeName.value.length > 0){" & vbcrlf & "                          phoneArr = takeName.value +"",""+ hiddenNum.value;" & vbcrlf & "                    }else{" & vbcrlf & "                          phoneArr = hiddenNum.value;" & vbcrlf & "                     }" & vbcrlf & "               }" & vbcrlf & "               var snum=phoneArr.split(',');" & vbcrlf & "           for (i=0;i<snum.length ;i++ ){" & vbcrlf & "                  if (snum[i].length>0){" & vbcrlf & "                          if (!_Check(snum[i])){" & vbcrlf & "                                   alert( ""输入的手机号码""+snum[i]+""错误 "");" & vbcrlf & "                                   return;" & vbcrlf & "                         }" & vbcrlf & "                       }else{" & vbcrlf & "                          kk=i+1;" & vbcrlf & "                         if (kk!=snum.length){" & vbcrlf & "                                   alert('友情提示：第'+kk+'个号码不能为空！');" & vbcrlf & "                                    document.getElementById('button').disabled='';" & vbcrlf & "                                  document.getElementById('sendErr').innerText='';" & vbcrlf & "                                        return;" & vbcrlf & "                         }" & vbcrlf & "                       }" & vbcrlf & "               }" & vbcrlf & "               document.getElementById('button').disabled='disabled';" & vbcrlf & "          div_send=window.DivOpen(""message_send"" ,""短信发送状态"", 300,160,""right"",160,true,20);" & vbcrlf & "            div_send.innerHTML = ""<img src='../images/loading.gif'/>正在发送中，请稍候..."";" & vbcrlf & "           var strNum=takeName.value;" & vbcrlf & "              if (strNum.length>11){" & vbcrlf & "                  var strNum=strNum.split("","");" & vbcrlf & "                     document.getElementById(""tallNum"").innerText=strNum.length;" & vbcrlf & "                      if(returnStr*10<strNum.length){" & vbcrlf & "                         div_send.innerHTML = ""发送状态: 您的余额不足本次所有短信发送，请及时充值！<br/><br/><br/><br/><p  align='center'>【<a href='javascript:void(0)' title='继续发送' onclick=window.DivClose(this);window.setTimeout(function(){sendSubmit(document.getElementById('takeName').value,document.getElementById('messageContent').value,openlaststr,document.getElementById('signature').value);},1000);>继续发送</a>】&nbsp;&nbsp;&nbsp;【<a href='javascript:void(0)' title='取消发送' onclick=window.DivClose(this)>取消发送</a>】</p>"";" & vbcrlf & "                      }else{" & vbcrlf & "          window.setTimeout(function(){sendSubmit(takeName.value,messageContent.value,openlaststr,document.getElementById('signature').value);},1000);" & vbcrlf & "                    }" & vbcrlf & "               }else{" & vbcrlf & "                  window.setTimeout(function(){sendSubmit(takeName.value,messageContent.value,openlaststr,document.getElementById('signature').value);},1000);" & vbcrlf & "             }" & vbcrlf & "       }else if(takeName.value.length<=0 && hiddenNum.value.length<=0){" & vbcrlf & "                alert('友情提示：号码不能为空！');" & vbcrlf & "              document.getElementById('button').disabled='';" & vbcrlf & "          document.getElementById('sendErr').innerText='';"& vbcrlf & "              return;" & vbcrlf & " }else if(messageContent.value.length<=0){" & vbcrlf & "               alert('友情提示：内容不能为空！');" & vbcrlf & "              document.getElementById('button').disabled='';" & vbcrlf & "          document.getElementById('sendErr').innerText='';" & vbcrlf & "                return;" & vbcrlf & " }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function showErrMessageByType(errMessage,stype , showPosition){" & vbcrlf & "  if (stype){" & vbcrlf & "             if (!showPosition){" & vbcrlf & "                     document.getElementById(""showerrmessage"").innerHTML=""(""+errMessage+"")"";" & vbcrlf & "               }else{" & vbcrlf & "                  document.getElementById(showPosition).innerHTML=errMessage;" & vbcrlf & "            }" & vbcrlf & "       }else{" & vbcrlf & "          alert(errMessage);" & vbcrlf & "      }" & vbcrlf & "}" & vbcrlf & "//获取剩余可发短信数量" & vbcrlf & "function getBalance(isShowTop){" & vbcrlf & " getWebPage('"
	Response.write urlBalance
	Response.write "?"
	Response.write urlUser
	Response.write "="
	Response.write accName
	Response.write "&"
	Response.write urlPwd
	Response.write "="
	Response.write accPwd
	Response.write "&"
	Response.write urlStrBalance
	Response.write "'+""&stamp=""+Math.round(Math.random()*100) , isShowTop);" & vbcrlf & "}" & vbcrlf & "var returnStr=0" & vbcrlf & "function getWebPage(url ,isShowTop){" & vbcrlf & "    showErrMessageByType(""<span style='color:#ff0000'>正在获取账户信息.</span>"", true , ""balance"");" & vbcrlf & "     var my_url=""getSendUrl.asp"";" & vbcrlf & "  xmlHttp2 = new GetIE10SafeXmlHttp();" & vbcrlf & "    xmlHttp2.open('post',my_url,true);" & vbcrlf & "      xmlHttp2.setRequestHeader(""Content-Type"",""application/x-www-form-urlencoded"");" & vbcrlf & "      var postStr = ""url=""+escape(url)+""&date1=""+Math.round(Math.random()*100);" &vbcrlf & "        //document.getElementById(""messageContent"").value=""http://127.0.0.1/message/getSendUrl.asp?""+postStr;" & vbcrlf & "       xmlHttp2.onreadystatechange=function(){" & vbcrlf & "         if(xmlHttp2.readyState==4){" & vbcrlf & "                     if(xmlHttp2.status==200){" & vbcrlf & "                               returnStr=xmlHttp2.responseText;" & vbcrlf & "                              if ((Number(returnStr))<=0 ){" & vbcrlf & "                                   if (returnStr==""-1111""){" & vbcrlf & "                                          showErrMessageByType(""<span style='color:#ff0000'>网络通信异常.</span>"", true , ""balance"");" & vbcrlf & "                                 }else{" & vbcrlf & "                                          showErrMessageByType(""友情提示：您的余额不足，请及时充值！"",isShowTop , ""balance"");" & vbcrlf & "                                           window.opener=null;window.open('','_self');" & vbcrlf & "                                             //window.close();" & vbcrlf & "                                       }" & vbcrlf & "                                       return;" & vbcrlf & "                         }else if((Number(returnStr))<=10&&(Number(returnStr))>0 ){" & vbcrlf & "                                      showErrMessageByType(""友情提示：您的余额不足10元，请及时充值！"",isShowTop);" & vbcrlf & "                                        showErrMessageByType(""<span style='color:#ff0000'>还能发送：""+ Math.floor(Number(returnStr)*10) +""条</span>"",true , ""balance"");" & vbcrlf & "                                       var talNum="
	'Response.write urlStrBalance
	Response.write talNum
	Response.write ";" & vbcrlf & "                                    if(talNum>(Number(returnStr))*10){" & vbcrlf & "                                              showErrMessageByType(""友情提示：您的余额不足此次发送！"",isShowTop);" & vbcrlf & "                                       }" & vbcrlf & "                               }else{" & vbcrlf & "                                  showErrMessageByType(""还能发送：""+ Math.floor(Number(returnStr)*10) +""条"",true , ""balance"");" & vbcrlf &"                                 var talNum="
	Response.write talNum
	Response.write ";" & vbcrlf & "                                    if(talNum>(Number(returnStr))*10){" & vbcrlf & "                                              showErrMessageByType(""友情提示：您的余额不足此次发送！"",isShowTop);" & vbcrlf & "                                       }" & vbcrlf & "                               }" & vbcrlf & "                               xmlHttp2.abort();" & vbcrlf & "                       }else{" & vbcrlf & "                          showErrMessageByType(""连接SP失败,可能短信配置错误或网络不通!"",isShowTop);" & vbcrlf & "                      }" & vbcrlf & "               }" & vbcrlf & "       }" & vbcrlf & "       xmlHttp2.send(postStr);" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function sendSub(phone,msg,zchstr){" & vbcrlf & "     if(msg.length<=1000){" & vbcrlf & "           sendSub1(phone,msg,zchstr);" & vbcrlf & "     }else{" & vbcrlf & "          alert(""友情提示：短信内容太长了"");" & vbcrlf & "            window.DivClose(div_send);" & vbcrlf & "      }" & vbcrlf & "}" & vbcrlf & "function sendSub1(phone,msg,zchstr){" & vbcrlf & "    var msgStr = UrlEncode(msg);" & vbcrlf & "" & vbcrlf & "    if(IntOpenAutoSend==1)" & vbcrlf & "        {" & vbcrlf & "               var strdate=document.getElementById(""daysOfMonthPos"").value;" & vbcrlf & "          if(strdate=="""")" & vbcrlf & "           {" & vbcrlf & "                       alert(""友情提示：您开启定时发送功能，但没有选择发送日期！"");" & vbcrlf & "                      window.DivClose(div_send);" & vbcrlf & "              }" & vbcrlf & "               var strH=document.getElementById(""time1"").value;" & vbcrlf & "          if(strH=="""")" & vbcrlf& "               {" & vbcrlf & "                       alert(""友情提示：您开启定时发送功能，但没有选择发送小时！"");" & vbcrlf & "                      window.DivClose(div_send);" & vbcrlf & "              }" & vbcrlf & "               var strM=document.getElementById(""time2"").value;" & vbcrlf & "          if(strM=="""")" & vbcrlf & "              {" & vbcrlf & "                       alert(""友情提示：您开启定时发送功能，但没有选择发送分钟！"");" & vbcrlf &"                 window.DivClose(div_send);" & vbcrlf & "              }" & vbcrlf & "               if (strdate!=""""&&strH!=""""&&strM!="""")" & vbcrlf & "          {" & vbcrlf & "                       var strSendtime=strdate+"" ""+strH+"":""+strM+"":01"";" & vbcrlf & "                      var now= new Date();" & vbcrlf & "                    var nowtime=now.getYear()+""-""+(now.getMonth()+1)+""-""+now.getDate()+"" ""+now.getHours()+"":""+now.getMinutes()+"":""+now.getSeconds();" & vbcrlf & "                       var regS = new RegExp(""-"",""gi"");" & vbcrlf & "                    var date1=strSendtime;" & vbcrlf & "                  var date2=nowtime;" & vbcrlf & "                      date1=date1.replace(regS,""/"");" & vbcrlf & "                    date2=date2.replace(regS,""/"");" & vbcrlf & "                     var bd =new Date(Date.parse(date1));" & vbcrlf & "                    var ed =new Date(Date.parse(date2));" & vbcrlf & "                    if(bd<=ed)" & vbcrlf & "                      {" & vbcrlf & "                               document.getElementById(""sendErr"").innerText="""";" & vbcrlf & "                            alert(""友情提示：您的定时已过期！"");" & vbcrlf & "                              window.DivClose(div_send);" & vbcrlf & "                 }" & vbcrlf & "                       else" & vbcrlf & "                    {" & vbcrlf & "                           sendMsg("""
	Response.write urlSend
	Response.write "?"
	Response.write urlUser
	Response.write "="
	Response.write accName
	Response.write "&"
	Response.write urlPwd
	Response.write "="
	Response.write accPwd
	Response.write "&"
	Response.write urlMobil
	Response.write "=""+ phone +""&"
	'Response.write urlMobil
	Response.write urlContent
	Response.write "=""+msgStr+""&zchstr=""+ UrlEncode(zchstr) +""&sendtime=""+ escape(strSendtime)+""&openAutoSend=""+IntOpenAutoSend+""&smsApproval="
	'Response.write urlContent
	Response.write smsApproval
	Response.write "&"
	Response.write urlStrSend
	Response.write """,phone,msg,zchstr);" & vbcrlf & "                      }" & vbcrlf & "               }" & vbcrlf & "       }" & vbcrlf & "       else" & vbcrlf & "    {" & vbcrlf & "        sendMsg("""
	Response.write urlSend
	Response.write "?"
	Response.write urlUser
	Response.write "="
	Response.write accName
	Response.write "&"
	Response.write urlPwd
	Response.write "="
	Response.write accPwd
	Response.write "&"
	Response.write urlMobil
	Response.write "=""+ phone +""&"
	'Response.write urlMobil
	Response.write urlContent
	Response.write "=""+msgStr+""&zchstr=""+ UrlEncode(zchstr) +""&smsApproval="
	'Response.write urlContent
	Response.write smsApproval
	Response.write "&"
	Response.write urlStrSend
	Response.write """,phone,msg,zchstr);" & vbcrlf & "      }" & vbcrlf & "}" & vbcrlf & "function sendMsg(url,phone,con,zchstr){" & vbcrlf & "       var my_url=""getSendUrl.asp"";" & vbcrlf & "      var stact=1;" & vbcrlf & "    logid=0;" & vbcrlf & "        logMessage(phone,con,stact,logid,"
	Response.write needrec
	Response.write ",0,0,zchstr);//调用记录日志,初始状态 1 ;" & vbcrlf & "     url=url+""&logid=""+logid;" & vbcrlf & "  //document.getElementById(""messageContent"").value=""http://127.0.0.1/getSendUrl.asp?url=""+escape(url)+""&date1=""+Math.round(Math.random()*100);" & vbcrlf & " //return;" & vbcrlf & "       xmlHttp.open('post',my_url,false);" & vbcrlf & "        xmlHttp.setRequestHeader(""Content-Type"",""application/x-www-form-urlencoded"");" & vbcrlf & "       var postStr = ""url=""+escape(url)+""&date1=""+Math.round(Math.random()*100);" & vbcrlf & "   var wTimeoutHwnd = window.setTimeout(sendMsgTimeoutHandle(xmlHttp,phone,con,logid),10000)" & vbcrlf & "        xmlHttp.onreadystatechange=function()" & vbcrlf & "   {" & vbcrlf & "               if(xmlHttp.readyState==4)" & vbcrlf & "               {" & vbcrlf & "                       if(xmlHttp.status==200)" & vbcrlf & "                 {" & vbcrlf & "                               returnStr=xmlHttp.responseText;" & vbcrlf & "                         returnStr=textRepalce(returnStr);" & vbcrlf &"                         returns=returnStr.split("","");" & vbcrlf & "                             if (returns.length<3)" & vbcrlf & "                           {" & vbcrlf & "                                       getErrStr(returns[0],phone,con,logid,0,0);//调用返回状态" & vbcrlf & "                                        getBalance();" & vbcrlf & "                           }" & vbcrlf & "                               else" & vbcrlf & "                            {" & vbcrlf & "                                       getErrStr(returns[0],phone,con,logid,returns[1],returns[2]);//调用返回状态" & vbcrlf & "                                   getBalance();" & vbcrlf & "                           }" & vbcrlf & "                               xmlHttp.abort();" & vbcrlf & "                                if(wTimeoutHwnd>0)" & vbcrlf & "                              {" & vbcrlf & "                                       window.clearTimeout(wTimeoutHwnd);" & vbcrlf & "                                      wTimeoutHwnd = 0;" & vbcrlf & "                               }" & vbcrlf & "                      }" & vbcrlf & "" & vbcrlf & "               }" & vbcrlf & "       }" & vbcrlf & "       xmlHttp.send(postStr);" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function sendMsgTimeoutHandle(xmlHttp,phone,con,logid){" & vbcrlf & "  return function()" & vbcrlf & "       {" & vbcrlf & "               xmlHttp.abort();" & vbcrlf & "                getErrStr(908,phone,con,logid,0,0);//调用返回状态" & vbcrlf & "                getBalance();" & vbcrlf & "   }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "//发送第二步" & vbcrlf & "function sendSubmit(strNum,strcon,openstr,laststr){" & vbcrlf & "       if (openstr==""""||openstr==null||openstr==""undefined""){openstr=0;}" & vbcrlf & "   if (strcon!=null && strcon!=""""&&strNum!=null&&strNum!="""")" & vbcrlf & "  {" & vbcrlf & "               var openPre=IntOpenPre;" & vbcrlf & "         if (openPre==1||openPre==2||openPre==3||openPre==4)" & vbcrlf & "             {" & vbcrlf & "                       var splitcount=1000;" & vbcrlf & "            }" & vbcrlf & "               else" & vbcrlf & "            {" & vbcrlf & "                       varsplitcount=10000;" & vbcrlf & "          }" & vbcrlf & "               var clictPre="""";" & vbcrlf & "          var strNumLong="""";" & vbcrlf & "                strNumLong=strNum;" & vbcrlf & "              if(openstr==1 && laststr!="""" && laststr!=null && strcon.indexOf(""】"") < 1){strcon=strcon+""""+laststr+"""";}" & vbcrlf & "                var strNum=strNum.split("","")" & vbcrlf & "            document.getElementById(""tallNum"").innerText=strNum.length;//发送条数" & vbcrlf & "             var newsStrNum="""";" & vbcrlf & "                var strcon2=""""" & vbcrlf & "            for(j=0;j<Math.ceil(strNum.length/splitcount);j++)" & vbcrlf & "              {" & vbcrlf & "                       newsStrNum="""";" & vbcrlf & "                    newsStrNum=strNumLong.substr((12*splitcount-1)*j+j,(12*splitcount-1));" & vbcrlf & "                  if (openPre==1||openPre==2||openPre==3||openPre==4)" & vbcrlf & "                     {" & vbcrlf & "                               strcon2=getZunchStr(newsStrNum,openPre);" & vbcrlf & "                                sendSub(newsStrNum,strcon,strcon2);" & vbcrlf & "                     }" & vbcrlf & "                       else" & vbcrlf & "                  {" & vbcrlf & "                               //alert(newsStrNum);" & vbcrlf & "                            sendSub(newsStrNum,strcon,strcon2);" & vbcrlf & "                     }" & vbcrlf & "               }" & vbcrlf & "       }" & vbcrlf & "}" & vbcrlf & "//获取尊称" & vbcrlf & "function getZunchStr(phoneStr,stype) {" & vbcrlf & "      var strzunch;" & vbcrlf & "   var url = ""getZuncheng.asp"";" & vbcrlf & "  var postStr=""phone=""+phoneStr+""&stype=""+stype+""&timestamp="" + new Date().getTime() +  ""&date1=""+ Math.round(Math.random()*100);" & vbcrlf & " xmlHttp.open(""GET"", url, false);" & vbcrlf & "  xmlHttp.open(""POST"", url, false);" & vbcrlf & " xmlHttp.setRequestHeader(""Content-Type"",""application/x-www-form-urlencoded"");" & vbcrlf & " xmlHttp.setRequestHeader(""Content-Length"",postStr.length);" & vbcrlf & "        xmlHttp.onreadystatechange = function()" & vbcrlf & " {" & vbcrlf & "               if (xmlHttp.readyState == 4) {" & vbcrlf & "                  var response = xmlHttp.responseText.split(""</noscript>"")[1];" & vbcrlf & "                   strzunch=response.replace(""\r"","""").replace(""\n"","""");" & vbcrlf & "            }" & vbcrlf & "       };" & vbcrlf & "      xmlHttp.send(postStr);" & vbcrlf & "  //alert(strzunch);" & vbcrlf & "      //alert(strzunch.split("","").length);" & vbcrlf & "      return strzunch;" & vbcrlf & "}" & vbcrlf & "function ViewSMS(phone,content){" & vbcrlf & " if(phone!=""""&&phone!=null&&content!=""""&&content!=null)" & vbcrlf & "      {" & vbcrlf & "               phone=phone.substring(0,11)" & vbcrlf & "             var strPre,strLast,islong;" & vbcrlf & "              if (IntOpenPre==1||IntOpenPre==2||IntOpenPre==3||IntOpenPre==4)" & vbcrlf & "            {" & vbcrlf & "                       strPre=getZunchStr(phone,IntOpenPre);" & vbcrlf & "                   if (strPre.replace("","","""")!="""")" & vbcrlf & "                       {" & vbcrlf & "                               strPre=""尊敬的""+strPre+"": "";" & vbcrlf & "                        }" & vbcrlf & "                       else" & vbcrlf & "                    {" & vbcrlf & "                               strPre="""";" & vbcrlf & "                    }" & vbcrlf & "               }" & vbcrlf & "               else" & vbcrlf & "            {" & vbcrlf & "                       strPre="""";" & vbcrlf & "                }" & vbcrlf & "               if (openlaststr==1)" & vbcrlf & "             {" & vbcrlf & "                       strLast=document.getElementById(""signature"").value;" & vbcrlf & "               }" & vbcrlf & "               else" & vbcrlf & "            {" & vbcrlf & "strLast="""";" & vbcrlf & "               }" & vbcrlf & "               var con=strPre+content+strLast;" & vbcrlf & "         var con2 = con;" & vbcrlf & "         con2 = escape(con2);" & vbcrlf & "            con2 = con2.replace(/%A0%/g,""%20%"");" & vbcrlf & "              con2 = con2.replace(/\+/g,""%2B"");" & vbcrlf & "         var url = ""../message/viewSMS.asp"";            " & vbcrlf & "                var data=""phone=""+phone+""&con=""+con2+""&timestamp="" + new Date().getTime();" & vbcrlf & "            $('#w').window('open');" & vbcrlf & "         document.getElementById(""dhtml"").style.display="""";" & vbcrlf & "          xmlHttp.open(""POST"", url, false);" & vbcrlf & "         xmlHttp.setRequestHeader(""Content-type"", ""application/x-www-form-urlencoded""); " & vbcrlf & "             xmlHttp.onreadystatechange = function(){" & vbcrlf & "                        var dhtml = document.getElementById(""dhtml"");" & vbcrlf & "                     if (xmlHttp.readyState < 4) {" & vbcrlf & "                   dhtml.innerHTML=""loading..."";" & vbcrlf & "                     }" & vbcrlf & "                  if (xmlHttp.readyState == 4) {" & vbcrlf & "                          var response = xmlHttp.responseText;" & vbcrlf & "                            dhtml.innerHTML=response;" & vbcrlf & "                               xmlHttp.abort();" & vbcrlf & "                        }" & vbcrlf & "               };" & vbcrlf & "              xmlHttp.send(data);  " & vbcrlf & "   }" & vbcrlf & "       else if(phone==""""||phone==null)" & vbcrlf & "  {" & vbcrlf & "               alert('友情提示：号码为空！');" & vbcrlf & "  }" & vbcrlf & "       else if (content==""""||content==null)" & vbcrlf & "      {" & vbcrlf & "               alert('友情提示：短信内容为空！');" & vbcrlf & "      }" & vbcrlf & "}" & vbcrlf & "function getWordsLength(){" & vbcrlf & "    if(openlaststr==1)" & vbcrlf & "        {" & vbcrlf & "               var lenlastcontent=document.getElementById(""signature"").value.length;" & vbcrlf & "     }" & vbcrlf & "       else" & vbcrlf & "    {" & vbcrlf & "               var lenlastcontent=0;" & vbcrlf & "   }" & vbcrlf & "       var obj=document.getElementById('messageContent');" & vbcrlf & "      var objTip=document.getElementById('tip');" & vbcrlf & "  var lenTextLimit=64-"
	'Response.write needrec
	Response.write lenPreCon
	Response.write ";" & vbcrlf & "    var num=lenTextLimit;" & vbcrlf & "   var usedlong = document.getElementById('usedlong');" & vbcrlf & "     if(obj.value.length>0)" & vbcrlf & "  {" & vbcrlf & "               document.getElementById(""qccon"").style.display="""";" & vbcrlf & "          document.getElementById(""button"").disabled=""disabled"";" & vbcrlf & "    }" & vbcrlf & "       else" & vbcrlf & "    {" & vbcrlf & "               document.getElementById(""qccon"").style.display=""none"";" & vbcrlf & "      }" & vbcrlf & "       if(obj.value.length>=0)" & vbcrlf & " {" & vbcrlf & "               objTip.innerHTML=""(共<em>"" + Math.abs(obj.value.length +lenlastcontent) + "" </em>个字,折合"" + (obj.value.length == 0?0:(parseInt((obj.value.length + lenlastcontent) / num) + (parseInt(obj.value.length+lenlastcontent) % 64 != 0?1:0))) + ""条短信费用),"";" & vbcrlf & "         document.getElementById(""button"").disabled="""";" & vbcrlf & "      }" & vbcrlf & "       else" & vbcrlf & "    {" & vbcrlf & "               document.getElementById(""button"").disabled=""disabled"";" & vbcrlf & "     }" & vbcrlf & "}" & vbcrlf & "function clearSub(clearTextObj,fontObj){" & vbcrlf & "      if(document.getElementById(clearTextObj).value.length>0)" & vbcrlf & "        {" & vbcrlf & "               document.getElementById(fontObj).style.display="""";" & vbcrlf & "  }" & vbcrlf & "       else" & vbcrlf & "    {" & vbcrlf & "               document.getElementById(fontObj).style.display='none';" & vbcrlf & "  }" & vbcrlf & "}" & vbcrlf & "var ss=true;" & vbcrlf & "function abc(r){" & vbcrlf & "  if(r!=""""&&r!=null&&r!=undefined&&document.getElementById(""takeName"").value!="""")" & vbcrlf & "       {" & vbcrlf & "               document.getElementById(""takeName"").value = document.getElementById(""takeName"").value+r;" & vbcrlf & "          ss=false;" & vbcrlf & "       }" & vbcrlf & "       else if(r!=""""&&r!=null&&r!=undefined&&document.getElementById(""takeName"").value=="""")" & vbcrlf & "  {" & vbcrlf & "          document.getElementById(""takeName"").value =r;" & vbcrlf & "             ss=false;" & vbcrlf & "       }" & vbcrlf & "}" & vbcrlf & "//JS转义字符编码" & vbcrlf & "function getcode(objHTML){" & vbcrlf & "  var t = document.createTextNode(objHTML);" & vbcrlf & "  var d = document.createElement('div');" & vbcrlf & "  d.appendChild(t);" & vbcrlf & "  return d.innerHTML;" & vbcrlf & "}" & vbcrlf & "//******************检查单个号码的正确性" & vbcrlf & "function  _Check(Phone){" & vbcrlf & "    var reg=/^(\b13[0-9]{9}\b)|(\b14[7-7]\d{8}\b)|(\b15[0-9]\d{8}\b)|(\b16[0-9]\d{8}\b)|(\b17[0-9]\d{8}\b)|(\b18[0-9]\d{8}\b)|(\b19[0-9]\d{8}\b)|\b1[1-9]{2,4}\b$/" & vbcrlf & "      return reg.test(Phone);" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & "</script>" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/default/easyui.css?ver="
	'Response.write lenPreCon
	Response.write Application("sys.info.jsver")
	Response.write """>" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/icon.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """>" & vbcrlf & "<script type=""text/javascript"" src=""../inc/jquery-1.4.2.min.js?ver="
	'Response.write Application("sys.info.jsver")
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script type=""text/javascript"" src=""../inc/jquery.easyui.min.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<div id=""w"" class=""easyui-window"" title=""预览短信""  style=""width:450px;height:300px;padding:5px;background: #fafafa;top:200px;""  closed=""true""  modal=""true"">" & vbcrlf & "    <div region=""center"" id=""dhtml"" border=""false"" style=""padding:10px;width:410px; height:210px; "">" & vbcrlf & "    </div>" & vbcrlf & "    <div region=""south"" border=""false"" style=""text-align:right;height:25px;line-height:25px; margin-top:8px;"">" & vbcrlf & "        <a class=""easyui-linkbutton""  href=""javascript:void(0)"" icon=""icon-cancel"" onClick=""$('#w').window('close');"" style=""margin-right:10px;"">关闭</a>" & vbcrlf & "    </div>" & vbcrlf & "</div>" & vbcrlf & "" & vbcrlf & ""
	'Response.write Application("sys.info.jsver")
	if accName<>"" and accPwd<>"" and urlBalance<>"" and urlSend<>"" then
		Response.write "<script language='javascript'>getBalance(true);</script> "
	else
		Response.write "<script language='javascript'> alert('友情提示：短信账户有误！'); window.opener=null;window.open('','_self');window.close();</script> "
	end if
	Response.write "" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	function getServerState
		Dim https, r
		set https=server.createobject("msxml2.serverxmlhttp")
		https.settimeouts 4000,4000,4000,4000
		https.open "GET","http://127.0.0.1:818/settask.asp?cmd=test", false
		on error resume next
		https.send()
		if https.readystate =4 then
			if https.status=200 then
				r = https.responsetext
			end if
		end if
		If Len(r) = 0 And isdate(r) = False Then
			getServerState = "<span style='color:red'>短信服务程序未开启,请联系系统管理员.</span>"
		else
			getServerState = "<span style='color:#009900'>服务程序正常</span>"
		end if
		Set https = nothing
	end function
	
%>
