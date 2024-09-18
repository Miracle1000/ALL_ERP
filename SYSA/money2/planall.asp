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
		Response.write "" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "        var getIEVer = function () {" & vbcrlf & "            var browser = navigator.appName;" & vbcrlf & "                if(window.ActiveXObject && top.document.compatMode==""BackCompat"") {return 5;}" & vbcrlf & "             var b_version = navigator.appVersion;" & vbcrlf & "             var version = b_version.split("";"");" & vbcrlf & "               if(document.documentMode && isNaN(document.documentMode)==false) { return document.documentMode; }" & vbcrlf & "              if (window.ActiveXObject) {" & vbcrlf & "                     var v = version[1].replace(/[ ]/g, """");" & vbcrlf & "                   if (v == ""MSIE10.0""){return 10;}" & vbcrlf & "                        if (v == ""MSIE9.0"") {return 9;}" & vbcrlf & "                   if (v == ""MSIE8.0"") {return 8;}" & vbcrlf & "                   if (v == ""MSIE7.0"") {return 7;}" & vbcrlf & "                   if (v == ""MSIE6.0"") {return 6;}" & vbcrlf & "                   if (v == ""MSIE5.0"") {return 5;" & vbcrlf & "                    } else {return 11}" &vbcrlf & "         }" & vbcrlf & "               else {" & vbcrlf & "                  return 100;" & vbcrlf & "             }" & vbcrlf & "       };" & vbcrlf & "      try{ document.getElementsByTagName(""html"")[0].className = ""IE"" + getIEVer() ; } catch(exa){}" & vbcrlf & "        window.uizoom = "
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
	
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_1=0
		intro_22_1=0
	else
		open_22_1=rs1("qx_open")
		intro_22_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	If intro_22_1 & "" = "" Then intro_22_1 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_14=0
		intro_22_14=0
	else
		open_22_14=rs1("qx_open")
		intro_22_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_22_14 & "" = "" Then intro_22_14 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=2"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_2=0
		intro_22_2=0
	else
		open_22_2=rs1("qx_open")
		intro_22_2=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_22_2 & "" = "" Then intro_22_2 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_3=0
		intro_22_3=0
	else
		open_22_3=rs1("qx_open")
		intro_22_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_22_3 & "" = "" Then intro_22_3 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=5"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_5=0
		intro_22_5=0
	else
		open_22_5=rs1("qx_open")
		intro_22_5=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	If intro_22_5 & "" = "" Then intro_22_5 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=6"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_6=0
		intro_22_6=0
	else
		open_22_6=rs1("qx_open")
		intro_22_6=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_22_6 & "" = "" Then intro_22_6 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_7=0
		intro_22_7=0
	else
		open_22_7=rs1("qx_open")
		intro_22_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_22_7 & "" = "" Then intro_22_7 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_8=0
		intro_22_8=0
	else
		open_22_8=rs1("qx_open")
		intro_22_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_22_8 & "" = "" Then intro_22_8 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_10=0
		intro_22_10=0
	else
		open_22_10=rs1("qx_open")
		intro_22_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_22_10 & "" = "" Then intro_22_10 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_13=0
	else
		open_22_13=rs1("qx_open")
	end if
	rs1.close
	set rs1=nothing
	If open_22_13 & "" = "" Then open_22_13 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=16"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_16=0
		intro_22_16=0
	else
		open_22_16=rs1("qx_open")
		intro_22_16=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_22_16 & "" = "" Then intro_22_16 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=40"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_40=0
		intro_22_40=0
	else
		open_22_40=rs1("qx_open")
		intro_22_40=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_22_40 & "" = "" Then intro_22_40 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=6 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_6_13=0
		intro_6_13=0
	else
		open_6_13=rs1("qx_open")
		intro_6_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_6_13 & "" = "" Then intro_6_13 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=8 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_8_13=0
		intro_8_13=0
	else
		open_8_13=rs1("qx_open")
		intro_8_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_8_13 & "" = "" Then intro_8_13 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=31 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_31_13=0
		intro_31_13=0
	else
		open_31_13=rs1("qx_open")
		intro_31_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_31_13 & "" = "" Then intro_31_13 = "0"
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
	If intro_1_14 & "" = "" Then intro_1_14 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=8 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_8_14=0
		intro_8_14=0
	else
		open_8_14=rs1("qx_open")
		intro_8_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_8_14 & "" = "" Then intro_8_14 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=8 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_8_3=0
		intro_8_3=0
	else
		open_8_3=rs1("qx_open")
		intro_8_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_8_3 & "" = "" Then intro_8_3 = "0"
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
	set rs1=Nothing
	If intro_21_14 & "" = "" Then intro_21_14 = "0"
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
	If intro_26_1 & "" = "" Then intro_26_1 = "0"
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
	If intro_26_14 & "" = "" Then intro_26_14 = "0"
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
	If intro_1_1 & "" = "" Then intro_1_1 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=31 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_31_14=0
		intro_31_14=0
	else
		open_31_14=rs1("qx_open")
		intro_31_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_31_14 & "" = "" Then intro_31_14 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=31 and sort2=2"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_31_2=0
		intro_31_2=0
	else
		open_31_2=rs1("qx_open")
		intro_31_2=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_31_2 & "" = "" Then intro_31_2 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=31 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_31_3=0
		intro_31_3=0
	else
		open_31_3=rs1("qx_open")
		intro_31_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_31_3 & "" = "" Then intro_31_3 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=31 and sort2=19"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_31_19=0
		intro_31_19=0
	else
		open_31_19=rs1("qx_open")
		intro_31_19=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_31_19 & "" = "" Then intro_31_19 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=8 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_8_1=0
		intro_8_1=0
	else
		open_8_1=rs1("qx_open")
		intro_8_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_8_1 & "" = "" Then intro_8_1 = "0"
	if open_22_1=3 then
		list=""
	elseif open_22_1=1 then
		list="and cateid in ("&intro_22_1&") and cateid<>0 "
	else
		list="and cateid=0"
	end if
	Str_Result="where del=1 "&list&""
	Str_Result2="and del=1 "&list&""
	
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=8 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_8_1=0
		intro_8_1=0
	else
		open_8_1=rs1("qx_open")
		intro_8_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=8 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_8_14=0
		intro_8_14=0
	else
		open_8_14=rs1("qx_open")
		intro_8_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=8 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_8_3=0
		intro_8_3=0
	else
		open_8_3=rs1("qx_open")
		intro_8_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=8 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_8_7=0
		intro_8_7=0
	else
		open_8_7=rs1("qx_open")
		intro_8_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=8 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_8_8=0
		intro_8_8=0
	else
		open_8_8=rs1("qx_open")
		intro_8_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=8 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_8_10=0
		intro_8_10=0
	else
		open_8_10=rs1("qx_open")
		intro_8_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=8 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_8_13=0
		intro_8_13=0
	else
		open_8_13=rs1("qx_open")
		intro_8_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=8 and sort2=16"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_8_16=0
		intro_8_16=0
	else
		open_8_16=rs1("qx_open")
		intro_8_16=rs1("qx_intro")
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
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=76 and sort2=1"
	set rs1=server.CreateObject("adodb.recordset")
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_76_1=0
		intro_76_1=0
	else
		open_76_1=rs1("qx_open")
		intro_76_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_14=0
		intro_22_14=0
	else
		open_22_14=rs1("qx_open")
		intro_22_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_1=0
		intro_22_1=0
	else
		open_22_1=rs1("qx_open")
		intro_22_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1= conn.execute("select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=8 and sort2=20")
	If rs1.eof = False Then
		open_8_20 =  rs1("qx_open") : intro_8_20=rs1("qx_intro")
	end if
	rs1.close
	Set rs1 = Nothing
	If open_8_20&"" = "" Then open_8_20 = 0
	If intro_8_20&"" = "" Then intro_8_20 = "-222"
'If open_8_20&"" = "" Then open_8_20 = 0
	set rs1= conn.execute("select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5025 and sort2=1")
	If rs1.eof = False Then
		open_5025_1 =  rs1("qx_open") : intro_5025_1=rs1("qx_intro")
	end if
	rs1.close
	Set rs1 = Nothing
	If open_5025_1&"" = "" Then open_5025_1 = 0
	If intro_5025_1&"" = "" Then intro_5025_1 = "-222"
'If open_5025_1&"" = "" Then open_5025_1 = 0
	set rs1= conn.execute("select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5025 and sort2=14")
	If rs1.eof = False Then
		open_5025_14 =  rs1("qx_open") : intro_5025_14=rs1("qx_intro")
	end if
	rs1.close
	Set rs1 = Nothing
	If open_5025_14&"" = "" Then open_5025_14 = 0
	If intro_5025_14&"" = "" Then intro_5025_14 = "-222"
'If open_5025_14&"" = "" Then open_5025_14 = 0
	set rs1= conn.execute("select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5026 and sort2=1")
	If rs1.eof = False Then
		open_5026_1 =  rs1("qx_open") : intro_5026_1=rs1("qx_intro")
	end if
	rs1.close
	Set rs1 = Nothing
	If open_5026_1&"" = "" Then open_5026_1 = 0
	If intro_5026_1&"" = "" Then intro_5026_1 = "-222"
'If open_5026_1&"" = "" Then open_5026_1 = 0
	set rs1= conn.execute("select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5026 and sort2=14")
	If rs1.eof = False Then
		open_5026_14 =  rs1("qx_open") : intro_5026_14=rs1("qx_intro")
	end if
	rs1.close
	Set rs1 = Nothing
	If open_5026_14&"" = "" Then open_5026_14 = 0
	If intro_5026_14&"" = "" Then intro_5026_14 = "-222"
'If open_5026_14&"" = "" Then open_5026_14 = 0
	if open_8_1=3 then
		list=""
	elseif open_8_1=1 then
		list="and cateid in ("&intro_8_1&")"
	else
		list="and cateid=0"
	end if
	Str_Result="where del=1 "&list&""
	Str_Result2="and del=1 "&list&""
	
	s1=request("firstload")
	firstload=s1
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
	set rs1=Nothing
	A = request("A")
	B=request("B")
	C=Request("C")
	D=request("D")
	E=request("E")
	F=request("F")
	H=request("H")
	m1=request("ret")
	m2=request("ret2")
	telord=deurl(request("companyid"))
	Cls = clng("0" & request("Cls"))
	dType = clng("0" &  request("dType"))
	if len(m1 & "")=0 and  len(m2 & "")=0  and s1& ""="" then
		m1 = year(now) & "-01-01"
'if len(m1 & "")=0 and  len(m2 & "")=0  and s1& ""="" then
		m2 = year(now) & "-12-31"
'if len(m1 & "")=0 and  len(m2 & "")=0  and s1& ""="" then
	end if
	if request("type")=2 then
		m1=""
		m2=""
	end if
	if dType = 0 then
		if m1<>"" then Str_Result=Str_Result+"and date3>='"&m1&" 00:00:00' "
'if dType = 0 then
		if m2<>"" then Str_Result=Str_Result+"and date3<='"&m2&" 23:59:59' "
'if dType = 0 then
	else
		if m1<>"" then Str_Result=Str_Result+"and date7>='"&m1&" 00:00:00' "
'if dType = 0 then
		if m2<>"" then Str_Result=Str_Result+"and date7<='"&m2&" 23:59:59' "
'if dType = 0 then
	end if
	if Cls > 0 then
		Str_Result=Str_Result & "and cls=" & (Cls-1) & " "
'if Cls > 0 then
	end if
	if telord>0 then
		Str_Result = Str_Result + " and company in("&telord&") "
'if telord>0 then
	end if
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
	if W4<>"" Then
		tmp=split(getW1W2(W3),";")
		W1=tmp(0)
		W2=tmp(1)
		Str_Result=Str_Result+" and cateid in("& W3 &") and cateid<>0 "
		W2=tmp(1)
	end if
	if C<>"" then
		if B="khmc" then
			Str_Result=Str_Result+" and companyName like '%"& replace(C,"'","''") &"%' "
'if B="khmc" then
		elseif B="khid" then
			Str_Result=Str_Result+" and company in (select ord from tel where del=1 and khid like '%"& replace(C,"","") &"%') "
'elseif B="khid" then
		elseif B="htzt" then
			Str_Result=Str_Result+" and title like '%"&replace(C,"'","")&"%' "
'elseif B="htzt" then
		elseif B="cgid" then
			Str_Result=Str_Result+" and cgid like '%"&replace(C,"'","")&"%' "
'elseif B="cgid" then
		elseif B="cguser" then
			Str_Result=Str_Result+" and BillUserName like '%"&replace(C,"'","")&"%' "
'elseif B="cguser" then
		end if
	end if
	If A="1" Then
		Str_Result=Str_Result+" and PlanStatus='未生成' "
'If A="1" Then
	ElseIf A="2" Then
		Str_Result=Str_Result+" and PlanStatus='部分生成' "
'ElseIf A="2" Then
	end if
	dim pxdats : redim pxdats(15)
	pxdats(0) = "按单据日期排序（降）"
	pxdats(1) = "按单据日期排序（升）"
	pxdats(2) = "按供应商名称排序（降）"
	pxdats(3) = "按供应商名称排序（升）"
	pxdats(4) = "按优惠后总额排序（降）"
	pxdats(5) = "按优惠后总额排序（升）"
	pxdats(6) = "按付款计划总额排序（降）"
	pxdats(7) = "按付款计划总额排序（升）"
	pxdats(8) = "按付款总额排序（降）"
	pxdats(9) = "按付款总额排序（升）"
	pxdats(10) = "按付款计划余额排序（降）"
	pxdats(11) = "按付款计划余额排序（升）"
	pxdats(12) = "按付款计划进展排序（降）"
	pxdats(13) = "按付款计划进展排序（升）"
	pxdats(14) = "按单据人员排序（降）"
	pxdats(15) = "按单据人员排序（升）"
	dim px_Result
	px= clng("0" &  request.QueryString("px"))
	if px = 0 then px = 1
	select case px
	case 1:  px_Result="order by convert(varchar(10),a.date3,120) desc,a.date7 desc"
	case 2:  px_Result="order by convert(varchar(10),a.date3,120) asc,a.date7 desc"
	case 3:  px_Result="order by a.companyName desc,a.date7 desc"
	case 4:  px_Result="order by a.companyName asc,a.date7 desc"
	case 5:  px_Result="order by a.money1 desc,a.date7 desc"
	case 6:  px_Result="order by a.money1 asc,a.date7 desc"
	case 7:  px_Result="order by a.PayPlanMoney desc,a.date7 desc"
	case 8:  px_Result="order by a.PayPlanMoney asc,a.date7 desc"
	case 9:  px_Result="order by a.PaySureMoney desc,a.date7 desc"
	case 10:  px_Result="order by a.PaySureMoney asc,a.date7 desc"
	case 11:  px_Result="order by a.PayAlsoMoney desc,a.date7 desc"
	case 12:  px_Result="order by a.PayAlsoMoney asc,a.date7 desc"
	case 13:  px_Result="order by a.PlanStatus desc,a.date7 desc"
	case 14:  px_Result="order by a.PlanStatus asc,a.date7 desc"
	case 15:  px_Result="order by a.billUserName desc,a.date7 desc"
	case 16:  px_Result="order by a.billUserName asc,a.date7 desc"
	end select
	page_count=request.QueryString("page_count")
	if page_count="" then
		page_count=10
	end if
	currpage=Request("currpage")
	if currpage<="0" or currpage="" then
		currpage=1
	end if
	currpage=cdbl(currpage)
	UUrl=ReturnUrl()
	hasCG = ZBRuntime.MC(15000)
	hasWWJG = ZBRuntime.MC(35000)
	hasZDWW = ZBRuntime.MC(18700)
	hasGXWW= ZBRuntime.MC(18610)
	hasLBWW= ZBRuntime.MC(18000)
	IF hasCG=FALSE THEN
		Str_Result=Str_Result+" and cls!=0"
'IF hasCG=FALSE THEN
	end if
	IF hasZDWW=FALSE THEN
		Str_Result=Str_Result+" and cls!=4 and cls!=5"
'IF hasZDWW=FALSE THEN
	end if
	IF hasLBWW=FALSE THEN
		Str_Result=Str_Result+" and cls!=2"
'IF hasLBWW=FALSE THEN
	end if
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "    <meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "    <title>"
'IF hasLBWW=FALSE THEN
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "    <link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/default/easyui.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """>" & vbcrlf & "    <link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/icon.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """>" & vbcrlf & "    <script type=""text/javascript"" src=""../inc/jquery-1.4.2.min.js?ver="
	'Response.write Application("sys.info.jsver")
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "    <script type=""text/javascript"" src=""../inc/jquery.easyui.min.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "    <script type=""text/javascript"" src=""cp_ajax.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "    <link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "    <style>" & vbcrlf & "        .IE5 .bot_btns input.anybutton2 {" & vbcrlf & "            height: 18px;" & vbcrlf & "            line-height: 16px;" & vbcrlf & "            margin-bottom: -0.5px;" & vbcrlf & "        }" & vbcrlf & "    </style>" & vbcrlf & "</head>" & vbcrlf & "<body "
	if open_8_8=0 then
		Response.write " oncontextmenu=""return false"" onselectstart=""return false"" ondragstart=""return false"" onbeforecopy=""return false"" oncopy=""document.selection.empty()"
	end if
	Response.write """ onmouseover=""window.status='none';return true;"">" & vbcrlf & "    <form method=""get"" action=""planall.asp"" id=""demo"" onsubmit=""return Validator.Validate(this,2)"" name=""date"">" & vbcrlf & "        <table width=""100%"" border=""0"" align=""left"" cellpadding=""0"" cellspacing=""0""bordercolor=""#E2E2E1"" bgcolor=""#FFFFFF"">" & vbcrlf &         "    <tr> "& vbcrlf &          "       <td width=""100%"" valign=""top""> "& vbcrlf &               "      <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif""> "& vbcrlf &"<input type=""hidden"" name=""px"" value="""
	Response.write px
	Response.write """>" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td class=""place"">待建立付款计划</td>" & vbcrlf & "                            <td>&nbsp;<a class='px_btn' href=""javascript:void(0)"" onclick=""Myopen_px(User);return false;"" class=""sortRule"">排序规则<img src=""../images/i10.gif"" width=""9"" height=""5"" border=""0""></a>" & vbcrlf & "                                <script language=""javascript"">" & vbcrlf & "                     function Myopen_px(divID){" & vbcrlf & "                              if(divID.style.display==""""){" & vbcrlf & "                                      divID.style.display=""none""" & vbcrlf & "                                }else{" & vbcrlf & "                                   divID.style.display=""""" & vbcrlf & "                            }" & vbcrlf & "                               divID.style.left=300;" & vbcrlf & "                           divID.style.top=0;" & vbcrlf & "                      }" & vbcrlf & "                                </script>" & vbcrlf & "                                <div id=""User"" style=""position: absolute; width: 170px; height: 350; display: none;"">" & vbcrlf & "                                    <table width=""190"" height=""250"" border=""0"" cellpadding=""-2"" cellspacing=""-2"">" & vbcrlf & "                                        <tr>" & vbcrlf & "                                            <td height=""139"">" & vbcrlf & "                                                <table width=""190"" height=""115"" bgcolor=""#ecf5ff"" border=""0"">" & vbcrlf & "                                                    "
	for  pxi = 0  to 15
		Response.write "" & vbcrlf & "                                                    <tr valign=""middle"">" & vbcrlf & "                                                        <td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""javascript:void(0);"" onclick=""gotourl('px="
		Response.write cstr(pxi+1)
		Response.write "');""><font color=""#2F496E"">"
		Response.write pxdats(pxi)
		Response.write "</font></a></td>" & vbcrlf & "                                                    </tr>" & vbcrlf & "                                                    "
	next
	Response.write "" & vbcrlf & "                                                </table>" & vbcrlf & "                                            </td>" & vbcrlf & "                                        </tr>" & vbcrlf & "                                    </table>" & vbcrlf & "                              </div>" & vbcrlf & "                            </td>" & vbcrlf & "                            <td align=""right"">" & vbcrlf & "                                <select name=""select2"" onchange=""if(this.selectedIndex && this.selectedIndex!=0){gotourl(this.value);}"">" & vbcrlf & "              <option>-请选择-</option>" & vbcrlf & "                                    <option value=""page_count=10"" "
	if page_count=10 then
		Response.write "selected"
	end if
	Response.write ">每页显示10条</option>" & vbcrlf & "                                    <option value=""page_count=20"" "
	if page_count=20 then
		Response.write "selected"
	end if
	Response.write ">每页显示20条</option>" & vbcrlf & "                                    <option value=""page_count=30"" "
	if page_count=30 then
		Response.write "selected"
	end if
	Response.write ">每页显示30条</option>" & vbcrlf & "                                    <option value=""page_count=50"" "
	if page_count=50 then
		Response.write "selected"
	end if
	Response.write ">每页显示50条</option>" & vbcrlf & "                                    <option value=""page_count=100"" "
	if page_count=100 then
		Response.write "selected"
	end if
	Response.write ">每页显示100条</option>" & vbcrlf & "                                    <option value=""page_count=200"" "
	if page_count=200 then
		Response.write "selected"
	end if
	Response.write ">每页显示200条</option>" & vbcrlf & "                                </select>&nbsp;</td>" & vbcrlf & "                            <td width=""3"">" & vbcrlf & "                                <img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        <tr>" & vbcrlf & "                            <input name=""firstload"" type=""hidden"" size=""10"" value=""1"" />" & vbcrlf & "                            <td class='ser_btn2 resetHeadBg' height=""50"" valign='middle' colspan=""3"" align=""right"">" & vbcrlf& "                                <select name=""dType"">" & vbcrlf & "                                    <option value=""0"" "
	if dType=0 then
		Response.write "selected"
	end if
	Response.write ">单据日期</option>" & vbcrlf & "                                    <option value=""1"" "
	if dType=1 then
		Response.write "selected"
	end if
	Response.write ">添加日期</option>" & vbcrlf & "                                </select><span style=""position: relative; top: -1px"">" & vbcrlf & "                                    "
	'Response.write "selected"
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
	
	Response.write "" & vbcrlf & "                                </span>" & vbcrlf & "                                <select name=""Cls"">" & vbcrlf & "                                    <option value=""0"" "
	if Cls=0 then
		Response.write "selected"
	end if
	Response.write ">单据来源</option>" & vbcrlf & "                                    "
	if hasCG then
		Response.write "" & vbcrlf & "                                    <option value=""1"" "
		if Cls=1 then
			Response.write "selected"
		end if
		Response.write ">采购</option>" & vbcrlf & "                                    "
	end if
	if hasZDWW then
		Response.write "" & vbcrlf & "                                    <option value=""6"" "
		if Cls=6 then
			Response.write "selected"
		end if
		Response.write ">整单委外</option>" & vbcrlf & "                                    <option value=""5"" "
		if Cls=5 then
			Response.write "selected"
		end if
		Response.write ">工序委外</option>" & vbcrlf & "                                    "
	end if
	if hasLBWW then
		Response.write "" & vbcrlf & "                                    <option value=""3"" "
		if Cls=3 then
			Response.write "selected"
		end if
		Response.write ">老版委外</option>" & vbcrlf & "                                    "
	end if
	Response.write "" & vbcrlf & "                                </select>" & vbcrlf & "                                <select name=""A"">" & vbcrlf & "                                    <option value=""0"" "
	if A="0" then
		Response.write "selected"
	end if
	Response.write ">付款计划进展</option>" & vbcrlf & "                                    <option value=""1"" "
	if A="1" then
		Response.write "selected"
	end if
	Response.write ">未生成</option>" & vbcrlf & "                                    <option value=""2"" "
	if A="2" then
		Response.write "selected"
	end if
	Response.write ">部分生成</option>" & vbcrlf & "                                </select>" & vbcrlf & "                                <select name=""B"">" & vbcrlf & "                                    <option value=""khmc"" "
	if B="khmc" then
		Response.write "selected"
	end if
	Response.write ">供应商名称</option>" & vbcrlf & "                                    <option value=""khid"" "
	if B="khid" then
		Response.write "selected"
	end if
	Response.write ">供应商编号</option>" & vbcrlf & "                                    <option value=""htzt"" "
	if B="htzt" then
		Response.write "selected"
	end if
	Response.write ">单据主题</option>" & vbcrlf & "                                    <option value=""cgid"" "
	if B="cgid" then
		Response.write "selected"
	end if
	Response.write ">单据编号</option>" & vbcrlf & "                                    <option value=""cguser"" "
	if B="cguser" then
		Response.write "selected"
	end if
	Response.write ">单据人员</option>" & vbcrlf & "                                </select>" & vbcrlf & "                                <input name=""C"" type=""text"" size=""10"" value="""
	Response.write C
	Response.write """ />" & vbcrlf & "                                <input type=""submit"" name=""Submit422"" value=""检索"" class=""anybutton"" />" & vbcrlf & "                                "
	if open_8_10=1 or open_8_10=3 then
		Response.write "" & vbcrlf & "                                <input type=""button"" name=""Submitdel2"" value=""导出"" onclick=""if(confirm('确认导出为EXCEL文档？')){exportExcel({debug:false,page:'../out/xls_dfk.asp'})}"" class=""anybutton"" />" & vbcrlf & "                                "
	end if
	if open_8_7=1 or open_8_7=3 then
		Response.write "" & vbcrlf & "                                <input type=""button"" name=""print"" onclick=""window.print();"" value=""打印"" class=""anybutton"" />" & vbcrlf & "                                "
	end if
	Response.write "</td>" & vbcrlf & "                        </tr>" & vbcrlf & "                    </table>" & vbcrlf & "    </form>" & vbcrlf & "    "
	Response.Flush : Response.Clear
	Response.write "" & vbcrlf & "    <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "        <tr height=""27"" class=""top resetGroupTableBg"">" & vbcrlf & "            <td width=""4%"" align=""center"">" & vbcrlf & "                <div align=""center""><strong>选择</strong></div>" & vbcrlf & "            </td>" & vbcrlf & "            <td width=""7%"">" & vbcrlf & "                <div align=""center"">单据日期</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td width=""12%"">" & vbcrlf & "                <div align=""center"">供应商</div>" & vbcrlf &      "       </td>" & vbcrlf &        "     <td width=""17%"">" & vbcrlf &         "        <div align=""center"">单据主题</div> "& vbcrlf &            " </td> "& vbcrlf &      "       <td width=""7%"">" & vbcrlf &            "     <div align=""center"">单据来源</div> "& vbcrlf &" </td>" & vbcrlf & "            <td width=""8%"">" & vbcrlf & "                <div align=""center"">优惠后总额</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td width=""8%"">" & vbcrlf & "                <div align=""center"">付款计划总额</div>" & vbcrlf & "            </td>" & vbcrlf& "            <td width=""8%"">" & vbcrlf & "                <div align=""center"">付款总额 </div>" & vbcrlf & "            </td>" & vbcrlf & "            <td width=""8%"">" & vbcrlf & "                <div align=""center"">付款计划余额</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td width=""15%"">" & vbcrlf & "                <div align=""center"">付款计划进展</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td width=""10%"">" & vbcrlf & "                <div align=""center"">单据人员</div>" & vbcrlf & "            </td>" & vbcrlf & "        </tr>" & vbcrlf & "        "
	dim n,k, rmbSort
	dim cgmoney1, moneyjh, moneyyh, cnCgmoney1, cnMoneyjh, cnMoneyyh
	dim sumCgMoney1, sumMoneyjh, sumMoneyyh
	dim cnSumCgMoney1, cnSumMoneyjh, cnSumMoneyyh
	n=0
	k=""
	cgmoney1 = 0 : moneyjh=0 : moneyyh = 0
	cnCgmoney1 = 0 : cnMoneyjh=0 : cnMoneyyh = 0
	sumCgMoney1 = 0 : sumMoneyjh = 0 : sumMoneyyh = 0
	cnSumCgMoney1 = 0 : cnSumMoneyjh = 0 : cnSumMoneyyh = 0
	allSumCgMoney1 = 0 : allSumMoneyjh = 0 : allSumMoneyyh = 0
	allCnSumCgMoney1 = 0 : allCnSumMoneyjh = 0 : allCnSumMoneyyh = 0
	rmbSort = sdk.getSqlValue("select intro from sortbz WITH(NOLOCK) where id=14","RMB")
	ovqt = sdk.getSqlValue("select nvalue from home_usConfig  where name='ZDWWPayPlayQT'","1")
	conn.cursorlocation = 3
	dim recordcount
	sql7="select " & vbCrLf &_
	"  count(1) as recordcount,  " & vbCrLf &_
	"  sum(round(money1," & num_dot_xs & ")) as money1," & vbCrLf &_
	"  sum(round(money1*hl," & num_dot_xs & ")) as rmb_Money1," & vbCrLf &_
	"  sum(round(PayPlanMoney," & num_dot_xs & ")) as PlanMoney," & vbCrLf &_
	"  sum(round(PayPlanMoney*hl," & num_dot_xs & ")) as rmb_PayPlanMoney," & vbCrLf &_
	"  sum(round(PaySureMoney," & num_dot_xs & ")) as PaySureMoney," & vbCrLf &_
	"  sum(round(PaySureMoney*hl," & num_dot_xs & ")) as rmb_PaySureMoney," & vbCrLf &_
	"  sum(round(PayAlsoMoney," & num_dot_xs & ")) as PayAlsoMoney," & vbCrLf &_
	"  sum(round(PayAlsoMoney*hl," & num_dot_xs & ")) as rmb_PayAlsoMoney" & vbCrLf &_
	"from  dbo.erp_finace_willpayoutList(" & ovqt & ") a " & Str_Result
	set rs7 = conn.execute(sql7)
	if rs7.eof = false then
		recordcount = rs7("recordcount").value
		allSumCgMoney1 = rs7("money1") : allCnSumCgMoney1 = rs7("rmb_Money1")
		allSumMoneyjh = rs7("PlanMoney") : allCnSumMoneyjh = rs7("rmb_PayPlanMoney")
		allSumMoneyyh = rs7("PaySureMoney") : allCnSumMoneyyh = rs7("rmb_PaySureMoney")
		allSumMoneyAlso = rs7("PayAlsoMoney") : allCnSumMoneyAlso = rs7("rmb_PayAlsoMoney")
	end if
	rs7.close
	set rs7 = Nothing
	page_count = clng("0" & page_count)
	CurrPage = clng("0" & CurrPage)
	PageCount = int(recordcount / page_count ) +  abs((recordcount mod page_count) > 0)
	CurrPage = clng("0" & CurrPage)
	if PageCount = 0 then PageCount = 1
	if CurrPage<=0 then CurrPage=1
	if CurrPage>=PageCount then  CurrPage=PageCount
	set rs=server.CreateObject("adodb.recordset")
	sql = "select  * from ("   & vbcrlf &_
	"          select cls,ord,cateid,title,cgid,company,bz,del,date7, date3," &_
	"          companyname, companydel,  companycateid, PlanStatus, " &_
	"          money1, PayPlanMoney,PaySureMoney, PayAlsoMoney, hl, "  & vbcrlf &_
	"          billUserName, ROW_NUMBER() OVER (" & px_Result & ") as rowIndex " & vbcrlf &_
	"          from dbo.erp_finace_willpayoutList(" & ovqt & ")  a "  & vbcrlf & Str_Result  & vbcrlf &_
	")  t1 where  rowindex>" & clng(page_count*(CurrPage-1)) & " and rowindex<=" & clng( page_count * CurrPage )
	rs.open sql,conn,1,1
	if rs.RecordCount<=0 then
		Response.write "<table><tr><td>没有信息!</td></tr></table>"
	else
		Response.write "" & vbcrlf & "        <form name=""form1"" method=""post"" action=""delete4.asp?"
		Response.write UUrl
		Response.write """>" & vbcrlf & "            "
		do until rs.eof
			cateid=rs("cateid")
			cls=rs("cls")
			ord=rs("ord")
			gys = rs("company")
			title = rs("title")
			date3 = rs("date3")
			bz = rs("bz")
			hl = zbcdbl(rs("hl").Value)
			cateidname = rs("billUserName")
			cgmoney1 =zbcdbl( rs("money1"))
			PayPlanMoney =zbcdbl( rs("PayPlanMoney"))
			PaySureMoney =zbcdbl( rs("PaySureMoney"))
			PayAlsoMoney =zbcdbl( rs("PayAlsoMoney"))
			cncgmoney1 =zbcdbl(cgmoney1)*hl
			cnPayPlanMoney =zbcdbl(PayPlanMoney)*hl
			cnPaySureMoney =zbcdbl(PaySureMoney)*hl
			cnPayAlsoMoney =zbcdbl(PayAlsoMoney)*hl
			sumCgMoney1 = sumCgMoney1 + cdbl(Formatnumber(cgmoney1,num_dot_xs,true,0,0))
			cnPayAlsoMoney =zbcdbl(PayAlsoMoney)*hl
			sumMoneyjh = sumMoneyjh + cdbl(Formatnumber(PayPlanMoney,num_dot_xs,true,0,0))
			cnPayAlsoMoney =zbcdbl(PayAlsoMoney)*hl
			sumMoneyyh = sumMoneyyh + cdbl(Formatnumber(PaySureMoney,num_dot_xs,true,0,0))
			cnPayAlsoMoney =zbcdbl(PayAlsoMoney)*hl
			sumMoneyAlso = sumMoneyAlso + cdbl(Formatnumber(PayAlsoMoney,num_dot_xs,true,0,0))
			cnPayAlsoMoney =zbcdbl(PayAlsoMoney)*hl
			cnSumCgMoney1 = cnSumCgMoney1 + cdbl(Formatnumber(cncgmoney1,num_dot_xs,true,0,0))
			cnPayAlsoMoney =zbcdbl(PayAlsoMoney)*hl
			cnSumMoneyjh = cnSumMoneyjh + cdbl(Formatnumber(cnPayPlanMoney,num_dot_xs,true,0,0))
			cnPayAlsoMoney =zbcdbl(PayAlsoMoney)*hl
			cnSumMoneyyh = cnSumMoneyyh + cdbl(Formatnumber(cnPaySureMoney,num_dot_xs,true,0,0))
			cnPayAlsoMoney =zbcdbl(PayAlsoMoney)*hl
			cnsumMoneyAlso = cnsumMoneyAlso + cdbl(Formatnumber(cnPayAlsoMoney,num_dot_xs,true,0,0))
			cnPayAlsoMoney =zbcdbl(PayAlsoMoney)*hl
			If bz&"" = "" Then bz = 14
			Response.write "" & vbcrlf & "        <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "            <td align=""center""><span class=""red"">" & vbcrlf & "                "
			if ((rs("companyDel").Value=1 or rs("companyDel").Value=2) and  (open_8_13=3 or (CheckPurview(intro_8_13,trim(cateid))=True) or rs("cls").Value=2 )) then
				Response.write "" & vbcrlf & "                <input name=""selectid1"" type=""checkbox"" title="""
				Response.write rs("cls")
				Response.write """ id=""selectid1"" value="""
				Response.write rs("ord")
				Response.write """>" & vbcrlf & "                "
			end if
			Response.write "</span></td>" & vbcrlf & "            <td align=""center"" height=""24"">" & vbcrlf & "                "
			Response.write  sdk.vbl.format(cdate(date3), "yyyy-MM-dd")
			Response.write "" & vbcrlf & "            </td>" & vbcrlf & "            <td align=""center"" style=""display: none;""><span class=""red"">"
			if open_8_3=3 or (CheckPurview(intro_8_3,trim(cateid))=True  And cateid<>0  ) then
				Response.write "<input name=""selectid"" type=""checkbox"" id=""selectid"" value="""
				Response.write ord
				Response.write """>"
			end if
			Response.write "</span></td>" & vbcrlf & "            "
			if gys&""<>"" then
				companyname = rs("companyname").Value
				companyDel = rs("companyDel").Value
				cateid_kh = rs("CompanyCateid").Value
				if companyDel = -100 then
					cateid_kh = rs("CompanyCateid").Value
					cateid_kh=-1
					cateid_kh = rs("CompanyCateid").Value
					companyname="<font color=red>关联供应商已被删除</font>"
				else
					cateid_kh=rs("CompanyCateid")
					if cateid_kh&""="" then cateid_kh = 0
					if companyDel = 1 then
						companyname = rs("companyname").Value
					else
						companyname = rs("companyname").Value&"<font style='color:red'>(已删除)</font>"
					end if
				end if
			else
				companyname=""
			end if
			Response.write "" & vbcrlf & "            <td align=""center"" height=""24"">" & vbcrlf & "                <div align=""left"">" & vbcrlf & "                    &nbsp;"
			if (open_26_1=3 or (open_26_1=1 and CheckPurview(intro_26_1,trim(cateid_kh))=True)) and cateid_kh<>-1 then
				if open_26_14=3 or (open_26_14=1 and CheckPurview(intro_26_14,trim(cateid_kh))=True) then
					Response.write "<a href=""javascript:;"" onclick=""javascript:window.open('../work2/content.asp?ord="
					Response.write pwurl(gys)
					Response.write "','newwin','width=' + 800 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title=""点击查看供应商详情"">"
					Response.write pwurl(gys)
					Response.write companyname
					Response.write "</a>"
				end if
			else
				Response.write companyname
			end if
			Response.write "" & vbcrlf & "                </div>" & vbcrlf & "            </td>" & vbcrlf & "            "
			set rs7=server.CreateObject("adodb.recordset")
			rs7.open "select intro from sortbz WITH(NOLOCK) where id="& bz &" ",conn,3,1
			if not rs7.eof then
				sortbz=rs7("intro")
			end if
			rs7.close
			Response.write "" & vbcrlf & "            <td class=""name"">" & vbcrlf & "                <div align=""left"">" & vbcrlf & "                    &nbsp;"
			open_lb = open_22_1 : intro_lb = intro_22_1
			open_xq = open_22_14 : intro_xq = intro_22_14
			glurl = "../../SYSN/view/store/caigou/caigoudetails.ashx?view=details&ord="& pwurl(ord) &""
			glaTitle = "点击查看采购详情" : hasModel = hasCG
			Select Case cls&""
			Case "2"
			open_lb = open_5025_1 : intro_lb = intro_5025_1
			open_xq = open_5025_14 : intro_xq = intro_5025_14 : hasModel = hasZDWW
			glurl="../manufacture/inc/Readbill.asp?orderid=25&ID="&ord&"&SplogId=0"
			glaTitle = "点击查看委外单详情"
			Case "4"
			open_lb = open_5026_1 : intro_lb = intro_5026_1
			open_xq = open_5026_14 : intro_xq = intro_5026_14 : hasModel = hasGXWW
			glurl = "../../SYSN/view/produceV2/OutProcedure/AddOutProcedure.ashx?ord="&pwurl(ord)&"&view=details"
			glaTitle = "点击查看工序委外详情"
			Case "5"
			open_lb = open_5025_1 : intro_lb = intro_5025_1
			open_xq = open_5025_14 : intro_xq = intro_5025_14 : hasModel = hasZDWW
			glurl = "../../SYSN/view/produceV2/ProductionOutsource/ProOutsourceAdd.ashx?ord="&pwurl(ord)&"&view=details"
			glaTitle = "点击查看整单委外详情"
			End Select
			if hasModel And (open_lb=3 or (open_lb=1 and CheckPurview(intro_lb,trim(cateid))=True)) Then
				if open_xq=3 or (open_xq=1 and CheckPurview(intro_xq,trim(cateid))=True  And cateid<>0) Then
					Response.write "<a href='javascript:;' onclick=""javascript:window.open('"& glurl &"','newwin','width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title='"& glaTitle &"'>"& title &"</a>"
'if open_xq=3 or (open_xq=1 and CheckPurview(intro_xq,trim(cateid))=True  And cateid<>0) Then
				else
					Response.write title
				end if
			end if
			Response.write "" & vbcrlf & "                </div>" & vbcrlf & "            </td>" & vbcrlf & "            <td align=""center"">"
			Select Case cls&""
			Case "2":
			clstype="5"
			Response.write  "委外"
			Case "4":
			clstype="3"
			Response.write  "工序委外"
			Case "5":
			clstype="2"
			Response.write  "整单委外"
			Case else:
			clstype="1"
			Response.write  "采购"
			End Select
			Response.write "</td>" & vbcrlf & "            <td height=""27"">" & vbcrlf & "                <div align=""right""><span>"
			Response.write sortbz&" "
			Response.write Formatnumber(cgmoney1,num_dot_xs,-1)
			Response.write sortbz&" "
			Response.write "</span></div>" & vbcrlf & "            </td>" & vbcrlf & "            <td height=""27"">" & vbcrlf & "                <div align=""right"">" & vbcrlf & "                    "
			if PayPlanMoney>0 then
				Response.write "" & vbcrlf & "                    <a href=""javascript:;"" onclick=""javascript:window.open('../../SYSN/view/finan/payout/payoutlist.ashx?clstype="
				Response.write clstype
				Response.write "&frombillid="
				Response.write pwurl(ord)
				Response.write "','plancor6','width=' + 1500 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & vbcrlf & "                        "
				Response.write pwurl(ord)
			end if
			Response.write sortbz&" "
			Response.write Formatnumber(PayPlanMoney,num_dot_xs,-1)
			Response.write sortbz&" "
			Response.write "" & vbcrlf & "                    </a>" & vbcrlf & "                </div>" & vbcrlf & "            </td>" & vbcrlf & "            <td height=""27"">" & vbcrlf & "                <div align=""right"">" & vbcrlf & "                    "
			if PaySureMoney>0 then
				Response.write "" & vbcrlf & "                    <a href=""javascript:;"" onclick=""javascript:window.open('../../SYSN/view/finan/payout/payoutlist.ashx?clstype="
				Response.write clstype
				Response.write "&frombillid="
				Response.write pwurl(ord)
				Response.write "&plans=777','plancor6','width=' + 1500 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & vbcrlf & "                        "
				Response.write pwurl(ord)
			end if
			Response.write sortbz&" "
			Response.write Formatnumber(PaySureMoney,num_dot_xs,-1)
			Response.write sortbz&" "
			Response.write "" & vbcrlf & "                    </a>" & vbcrlf & "                </div>" & vbcrlf & "            </td>" & vbcrlf & "            <td height=""27"">" & vbcrlf & "                <div align=""right"">"
			Response.write sortbz&" "
			Response.write Formatnumber(PayAlsoMoney,num_dot_xs,-1)
			Response.write sortbz&" "
			Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""center"">" & vbcrlf & "                    <font class=""gray"">"
			Response.write rs("PlanStatus").Value
			Response.write "</font>" & vbcrlf & "                    "
			if (open_8_13=3 or (open_8_13=1 and CheckPurview(intro_8_13,trim(cateid))=True And cateid<>0)) and companyDel <> "-100" and companyDel<>"2" then
				Response.write "</font>" & vbcrlf & "                    "
				Response.write "" & vbcrlf & "                    <img src=""../images/jiantou.gif"" style='margin-bottom: -2px' width=""16"" height=""11"">" & vbcrlf & "                    <a href=""javascript:;"" onclick=""javascript:window.open('../money2/addht.asp?ord="
				Response.write "</font>" & vbcrlf & "                    "
				Response.write pwurl(ord)
				Response.write "&cls="
				Response.write cls
				Response.write "','plancor6','width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & vbcrlf & "                        <font class=""blue2"">生成付款计划</font>" & vbcrlf & "                    </a>" & vbcrlf & "                    "
				Response.write cls
			end if
			Response.write "" & vbcrlf & "                </div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""center"">" & vbcrlf & "                    "
			if cls = 0 then
				Response.write "采购人员："
			else
				Response.write "我方代表："
			end if
			Response.write cateidname
			Response.write "" & vbcrlf & "                </div>" & vbcrlf & "            </td>" & vbcrlf & "        </tr>" & vbcrlf & "        "
			rs.movenext
		loop
		dim hzColspan : hzColspan = 5
		Response.write "" & vbcrlf & "        <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "            <td height=""27"" colspan="""
		Response.write hzColspan
		Response.write """>" & vbcrlf & "                <div align=""right"">本页合计：</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write Formatnumber(sumCgMoney1,num_dot_xs,-1)
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write Formatnumber(sumMoneyjh,num_dot_xs,-1)
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write Formatnumber(sumMoneyyh,num_dot_xs,-1)
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write Formatnumber(sumMoneyAlso,num_dot_xs,-1)
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "        </tr>" & vbcrlf & "        <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "            <td height=""27"" colspan="""
		Response.write hzColspan
		Response.write """>" & vbcrlf & "                <div align=""right""></div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write rmbSort&" "
		Response.write Formatnumber(cnSumCgMoney1,num_dot_xs,-1)
		Response.write rmbSort&" "
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write rmbSort&" "
		Response.write Formatnumber(cnSumMoneyjh,num_dot_xs,-1)
		Response.write rmbSort&" "
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write rmbSort&" "
		Response.write Formatnumber(cnSumMoneyyh,num_dot_xs,-1)
		Response.write rmbSort&" "
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write rmbSort&" "
		Response.write Formatnumber(cnSumMoneyAlso,num_dot_xs,-1)
		Response.write rmbSort&" "
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "        </tr>" & vbcrlf & "        <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "            <td height=""27"" colspan="""
		Response.write hzColspan
		Response.write """>" & vbcrlf & "                <div align=""right"">所有合计：</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write Formatnumber(allSumCgMoney1,num_dot_xs,-1)
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write Formatnumber(allSumMoneyjh,num_dot_xs,-1)
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write Formatnumber(allSumMoneyyh,num_dot_xs,-1)
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write Formatnumber(allSumMoneyAlso,num_dot_xs,-1)
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "        </tr>" & vbcrlf & "        <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "            <td height=""27"" colspan="""
		Response.write hzColspan
		Response.write """>" & vbcrlf & "                <div align=""right""></div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write rmbSort&" "
		Response.write Formatnumber(allCnSumCgMoney1,num_dot_xs,-1)
		Response.write rmbSort&" "
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write rmbSort&" "
		Response.write Formatnumber(allCnSumMoneyjh,num_dot_xs,-1)
		Response.write rmbSort&" "
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write rmbSort&" "
		Response.write Formatnumber(allCnSumMoneyyh,num_dot_xs,-1)
		Response.write rmbSort&" "
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>" & vbcrlf & "                <div align=""right"">"
		Response.write rmbSort&" "
		Response.write Formatnumber(allCnSumMoneyAlso,num_dot_xs,-1)
		Response.write rmbSort&" "
		Response.write "</div>" & vbcrlf & "            </td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "        </tr>" & vbcrlf & "    </table>" & vbcrlf & "    </td>" & vbcrlf & "      </tr>" & vbcrlf & "   <tr>" & vbcrlf & " <td class=""page"">" & vbcrlf & "              <table width=""100%"" border=""0"" align=""left"">" & vbcrlf & "                  <tr>" & vbcrlf & "                      <td width=""30%"" height=""25"">" & vbcrlf & "                          <div style=""margin-left: 15px"">" & vbcrlf & "   <input name=""chkall"" title=""全选"" type=""checkbox"" id=""chkall"" value=""all"" style=""vertical-align: middle"" onclick=""mm(this.form)"" />" & vbcrlf & "                              全选&nbsp;<input name=""backchkall"" type=""checkbox"" id=""backchkall"" value=""backall"" style=""vertical-align: middle"" onclick=""mm1(this.form)"" />" & vbcrlf &               "                反选&nbsp; "
		Response.write rmbSort&" "
		if open_8_13=1 or open_8_13=3 then
			Response.write "<input type=""button"" value=""批量生成付款计划"" class=""page"" onclick=""GeneraterPlan(this.form)"" />"
		end if
		Response.write "" & vbcrlf & "                          </div>" & vbcrlf & "                      </td>" & vbcrlf & "                      </form>" & vbcrlf & "                      <td width=""70%"" class='bot_btns'>" & vbcrlf & "                          <div align=""right"">" & vbcrlf & "                  <span class=""black"">"
		Response.write recordcount
		Response.write "个 | "
		Response.write currpage
		Response.write "/"
		Response.write pagecount
		Response.write "页 | &nbsp;"
		Response.write page_count
		Response.write "条信息/页</span>&nbsp;&nbsp;" & vbcrlf & "   <input name=""currpage"" type=""text"" onkeyup=""value=value.replace(/[^\d]/g,'')"" size=""3"">" & vbcrlf & "                              <input type=""submit"" name=""Submit422"" value=""跳转"" onclick=""gotourl('currPage='+document.getElementById('currpage').value);"" class=""anybutton2"" />" & vbcrlf & "                              "
		if currpage=1 then
			Response.write "" & vbcrlf & "                              <input type=""button"" name=""Submit4"" value=""首页"" class=""page"" />" & vbcrlf & "                              <input type=""button"" name=""Submit42"" value=""上一页"" class=""page"" />" & vbcrlf & "                              "
		else
			Response.write "" & vbcrlf & "                              <input type=""button"" name=""Submit4"" value=""首页"" class=""page"" onclick=""gotourl('currPage=1');"" />" & vbcrlf & "                              <input type=""button"" name=""Submit42"" value=""上一页"" onclick=""gotourl('currPage="
			Response.write  currpage -1
			Response.write "');"" class=""page"" />" & vbcrlf & "                              "
		end if
		if currpage=pagecount then
			Response.write "" & vbcrlf & "                              <input type=""button"" name=""Submit43"" value=""下一页"" class=""page"" />" & vbcrlf & "                              <input type=""button"" name=""Submit44"" value=""尾页"" class=""page"" />" & vbcrlf & "                              "
		else
			Response.write "" & vbcrlf & "                              <input type=""button"" name=""Submit43"" value=""下一页"" onclick=""gotourl('currPage="
			Response.write  currpage + 1
			Response.write "');"" class=""page"" />" & vbcrlf & "                              <input type=""button"" name=""Submit43"" value=""尾页"" onclick=""    gotourl('currPage="
			Response.write pagecount
			Response.write "');"" class=""page"" />" & vbcrlf & "                              "
		end if
		Response.write "" & vbcrlf & "                          </div>" & vbcrlf & "                      </td>" & vbcrlf & "                  </tr>" & vbcrlf & "                  <script language=""javascript"">" & vbcrlf & "function test()" & vbcrlf & "{" & vbcrlf & "  if(!confirm('确认删除吗？')) return false;" & vbcrlf& "}" & vbcrlf & "function GeneraterPlan(form){" & vbcrlf & "var ord_type="""";" & vbcrlf & "   for (var i=0;i<form.elements.length;i++)" & vbcrlf & "    {" & vbcrlf & "        var e = form.elements[i];" & vbcrlf & "        if (e.name == 'selectid1'&&e.checked)" & vbcrlf & "        {" & vbcrlf & " if(ord_type.length>0){ord_type+="","";}" & vbcrlf & "           ord_type+=e.value+""_""+e.title;" & vbcrlf & "        }" & vbcrlf & "    }" & vbcrlf & "    if(ord_type.length>1){" & vbcrlf & "    window.open('../../SYSN/view/finan/payout/GeneratePayPlan.ashx?ord_Type='+ord_type,'newwin77','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150')" & vbcrlf & " " & vbcrlf & "}else " & vbcrlf & "{" & vbcrlf & "" & vbcrlf & "}" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function mm(form)" & vbcrlf & "{" & vbcrlf & "" & vbcrlf & "      for (var i=0;i<form.elements.length;i++)" & vbcrlf & "      {" & vbcrlf & "               var e = form.elements[i];" & vbcrlf & "               if (e.name != 'chkall'){ if(e.name!='backchkall') {e.checked =true;}else {e.checked=false;} }" & vbcrlf & "        " & vbcrlf & "   }" & vbcrlf & "}" & vbcrlf & "function mm1(form){" & vbcrlf & "" & vbcrlf & "         for (var i=0;i<form.elements.length;i++)" & vbcrlf & "        {" & vbcrlf & "               var e = form.elements[i];" & vbcrlf & "               if (e.name != 'backchkall'){ if(e.name!='chkall') { e.checked=!e.checked;}else {e.checked=false;} }" & vbcrlf & "             " & vbcrlf & "        }" & vbcrlf & "}" & vbcrlf & " " &vbcrlf & "                  </script>" & vbcrlf & "                  <tr>" & vbcrlf & "                      <td height=""38"" colspan=""3"">" & vbcrlf & "                          <div align=""right"">" & vbcrlf & "                              <p>&nbsp;</p>" & vbcrlf & "                          </div>" & vbcrlf & "                      </td>" & vbcrlf & "                  </tr>" & vbcrlf & "              </table>" & vbcrlf & "              "
	end if
	rs.close
	set rs=nothing
	conn.execute("if exists(select top 1 1 from tempdb..sysobjects where name='tempdb..#payout') drop table #payout")
	Response.write "" & vbcrlf & "              <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "                  <tr>" & vbcrlf & "                      <td width=""100%"" height=""10"">" & vbcrlf & "                          <img src=""../image/pixel.gif"" width=""1"" height=""1""></td>" & vbcrlf & "                  </tr>" & vbcrlf & "                  <tr>" & vbcrlf & "                      <td height=""10"">&nbsp;</td>" & vbcrlf & "                  </tr>" & vbcrlf & "              </table>" & vbcrlf & "          </td>" & vbcrlf & "      </tr>" & vbcrlf & "    </table>" & vbcrlf & "</form>" & vbcrlf & "    <script language=""javascript"">" & vbcrlf & "function Myopen_px(divID){" & vbcrlf & "        if(divID.style.display==""""){" & vbcrlf & "              divID.style.display=""none""" & vbcrlf & "        }else{" & vbcrlf & "          divID.style.display=""""" & vbcrlf & "    }" & vbcrlf & "       divID.style.left=300;" & vbcrlf & "    divID.style.top=0;" & vbcrlf & "}" & vbcrlf & "    </script>" & vbcrlf & "    "
	action1="待建立付款计划"
	call close_list(1)
	Response.write "" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	
%>
