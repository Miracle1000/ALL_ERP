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
			'frs.close
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
	
	Server.ScriptTimeOut=100000000
	Response.write " " & vbcrlf & "<HTML>" & vbcrlf & "<HEAD>" & vbcrlf & "<TITLE>产品销售明细导出</TITLE>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8""><style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body {" & vbcrlf & "       background-color: #FFFFFF;" & vbcrlf & "      margin-left: 0px;" & vbcrlf & "       margin-top: 0px;" & vbcrlf & " margin-right: 0px;" & vbcrlf & "      margin-bottom: 0px;" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & "</style></HEAD>" & vbcrlf & "<body>" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "  <tr>" & vbcrlf & "<td class=""place"">产品销售明细导出</td>" & vbcrlf & "    <td>&nbsp;</td>" & vbcrlf & "    <td align=""right"">&nbsp;</td>" & vbcrlf & "    <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf &  " </tr>" & vbcrlf & "</table> "  & vbcrlf & "<table width=""100%""border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "<tr class=""top"">" & vbcrlf & "  <td colspan=2 class=tablebody1>&nbsp;</td>" & vbcrlf & "</tr>" & vbcrlf & "<tr>" & vbcrlf & "  <td colspan=2 class=tablebody1>" & vbcrlf & "<span id=""CountTXTok"" name=""CountTXTok"" style=""font-size:10pt; color:#008040"">" & vbcrlf & "<B>正在导出产品销售明细,请稍后...</B></span>" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""1"">" & vbcrlf & "<tr> " & vbcrlf & "<td bgcolor=000000>" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"">" & vbcrlf & "<tr> " & vbcrlf & "<td bgcolor=ffffff height=9><img src=""../images/tiao.jpg"" width=""0"" height=""16"" id=""CountImage"" name=""CountImage"" align=""absmiddle""></td></tr></table>" & vbcrlf & "</td></tr></table> <span id=""CountTXT"" name=""CountTXT"" style=""font-size:9pt; color:#008040"">0</span><span style=""font-size:9pt; color:#008040"">%</span></td></tr>" & vbcrlf & "<tr class=""top"">" & vbcrlf & "  <td colspan=2 class=tablebody1 height=""40"">" & vbcrlf & "  </td>" & vbcrlf & "</tr>" & vbcrlf & "</table>" & vbcrlf & ""
	Response.write Application("sys.info.jsver")
	dim MODULES
	MODULES=session("zbintel2010ms")
	set rs=server.CreateObject("adodb.recordset")
	strSql="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=1 and sort2=1"
	rs.open strSql,conn
	if rs.eof then
		open_1_1=0
		intro_1_1=0
	else
		open_1_1=rs("qx_open")
		intro_1_1=rs("qx_intro")
		If intro_1_1&""<>"" Then intro_1_1 = Replace(intro_1_1," ","")
	end if
	rs.close
	strSql="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=1"
	rs.open strSql,conn
	if rs.eof then
		open_5_1=0
		intro_5_1=0
	else
		open_5_1=rs("qx_open")
		intro_5_1=rs("qx_intro")
		If intro_5_1&""<>"" Then intro_5_1 = Replace(intro_5_1," ","")
	end if
	rs.close
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=10"
	rs.open sql1,conn,1,1
	if rs.eof then
		open_21_10=0
		intro_21_10=0
	else
		open_21_10=rs("qx_open")
		intro_21_10=rs("qx_intro")
		If intro_21_10 &""<>"" Then intro_21_10 = Replace(intro_21_10," ","") Else intro_21_10 = 0
	end if
	rs.close
	set rs=Nothing
	if open_21_10=3 then
		Str_Result=" where a.del = 1 "
		Str_Result2=" and a.del = 1"
	elseif open_21_10=1 then
		Str_Result=" where a.del = 1 and a.cateid<>0  and a.cateid in ("&intro_21_10&")"
		Str_Result2=" and a.del = 1  and a.cateid<>0 and a.cateid in ("&intro_21_10&")"
	else
		Str_Result=" where a.del = 1 and a.cateid= -1"
		Str_Result2=" and a.del = 1  and a.cateid<>0 and a.cateid in ("&intro_21_10&")"
		Str_Result2=" and a.del = 1 and a.cateid= -1"
		Str_Result2=" and a.del = 1  and a.cateid<>0 and a.cateid in ("&intro_21_10&")"
	end if
	dotstr_num=""
		for i=1 to num1_dot
			dotstr_num=dotstr_num&"0"
			next
			dotstr=""
				for i=1 to num_dot_xs
					dotstr=dotstr&"0"
					next
					discount_dotstr=""
					for i=1 to discount_dot_num
						discount_dotstr=discount_dotstr&"0"
					next
					Set xlApplication = GetExcelApplication()
					xlApplication.Visible = False
					xlApplication.SheetsInNewWorkbook=1
					xlApplication.Workbooks.Add
					Set xlWorksheet = xlApplication.Worksheets(1)
					xlWorksheet.name="sheet1"
					xlApplication.ActiveSheet.Columns(1).ColumnWidth=15
					xlApplication.ActiveSheet.Columns(1).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(1).NumberFormatLocal = "yyyy-m-d"
					xlApplication.ActiveSheet.Columns(1).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(2).ColumnWidth=12
					xlApplication.ActiveSheet.Columns(2).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(3).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(3).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(4).ColumnWidth=12
					xlApplication.ActiveSheet.Columns(4).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(5).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(5).HorizontalAlignment=3
					xlWorksheet.Cells(1,1).Value = "日期"
					xlWorksheet.Cells(1,1).font.Size=10
					xlWorksheet.Cells(1,1).font.bold=true
					xlWorksheet.Cells(1,2).Value = "产品名称"
					xlWorksheet.Cells(1,2).font.Size=10
					xlWorksheet.Cells(1,2).font.bold=true
					xlWorksheet.Cells(1,3).Value = "产品编号"
					xlWorksheet.Cells(1,3).font.Size=10
					xlWorksheet.Cells(1,3).font.bold=true
					xlWorksheet.Cells(1,4).Value = "产品型号"
					xlWorksheet.Cells(1,4).font.Size=10
					xlWorksheet.Cells(1,4).font.bold=true
					xlWorksheet.Cells(1,5).Value = "产品单位"
					xlWorksheet.Cells(1,5).font.Size=10
					xlWorksheet.Cells(1,5).font.bold=true
					j=6
					set rs=server.CreateObject("adodb.recordset")
					strSql="SELECT b.title FROM zdy a inner join zdymx b on a.name=b.name WHERE b.sort1=5 and a.sort1=21 AND b.set_open=1 order by a.gate1"
					rs.open strSql,conn,1,1
					colsCount=rs.recordcount
					do while not rs.eof
						xlApplication.ActiveSheet.Columns(j).ColumnWidth=15
						xlApplication.ActiveSheet.Columns(j).HorizontalAlignment=3
						xlWorksheet.Cells(1,j).Value = rs("title")
						xlWorksheet.Cells(1,j).font.Size=10
						xlWorksheet.Cells(1,j).font.bold=true
						j=j+1
						xlWorksheet.Cells(1,j).font.bold=true
						rs.movenext
					loop
					rs.close
					set rs=nothing
					xlApplication.ActiveSheet.Columns(j).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j).HorizontalAlignment=3
					xlWorksheet.Cells(1,j).Value = "币种"
					xlWorksheet.Cells(1,j).font.Size=10
					xlWorksheet.Cells(1,j).font.bold=true
					j=j+1
					xlWorksheet.Cells(1,j).font.bold=true
					xlApplication.ActiveSheet.Columns(j).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j).NumberFormatLocal = "#,##0."&dotstr_num&"_ "
					xlWorksheet.Cells(1,j).Value = "数量"
					xlWorksheet.Cells(1,j).font.Size=10
					xlWorksheet.Cells(1,j).font.bold=true
					j=j+1
					xlWorksheet.Cells(1,j).font.bold=true
					xlApplication.ActiveSheet.Columns(j).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j).NumberFormatLocal = "#,##0."&dotstr&"_ "
					xlWorksheet.Cells(1,j).Value = "折扣前单价"
					xlWorksheet.Cells(1,j).font.Size=10
					xlWorksheet.Cells(1,j).font.bold=true
					j=j+1
					xlWorksheet.Cells(1,j).font.bold=true
					xlApplication.ActiveSheet.Columns(j).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j).NumberFormatLocal = "#,##0."&dotstr&"_ "
					xlWorksheet.Cells(1,j).Value = "折扣后单价"
					xlWorksheet.Cells(1,j).font.Size=10
					xlWorksheet.Cells(1,j).font.bold=true
					j=j+1
					xlWorksheet.Cells(1,j).font.bold=true
					xlApplication.ActiveSheet.Columns(j).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j).NumberFormatLocal = "#,##0."&discount_dotstr&"_ "
					xlWorksheet.Cells(1,j).Value = "折扣"
					xlWorksheet.Cells(1,j).font.Size=10
					xlWorksheet.Cells(1,j).font.bold=true
					j=j+1
					xlWorksheet.Cells(1,j).font.bold=true
					xlApplication.ActiveSheet.Columns(j).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j).NumberFormatLocal = "#,##0."&dotstr&"_ "
					xlWorksheet.Cells(1,j).Value = "总价"
					xlWorksheet.Cells(1,j).font.Size=10
					xlWorksheet.Cells(1,j).font.bold=true
					j=j+1
					xlWorksheet.Cells(1,j).font.bold=true
					xlApplication.ActiveSheet.Columns(j).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j).HorizontalAlignment=3
					xlWorksheet.Cells(1,j).Value = "关联合同"
					xlWorksheet.Cells(1,j).font.Size=10
					xlWorksheet.Cells(1,j).font.bold=true
					j=j+1
					xlWorksheet.Cells(1,j).font.bold=true
					xlApplication.ActiveSheet.Columns(j).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j).HorizontalAlignment=3
					xlWorksheet.Cells(1,j).Value = "合同数量"
					xlWorksheet.Cells(1,j).font.Size=10
					xlWorksheet.Cells(1,j).font.bold=true
					j=j+1
					xlWorksheet.Cells(1,j).font.bold=true
					xlApplication.ActiveSheet.Columns(j).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j).NumberFormatLocal="@"
					xlWorksheet.Cells(1,j).Value = "客户"
					xlWorksheet.Cells(1,j).font.Size=10
					xlWorksheet.Cells(1,j).font.bold=true
					Response.Flush
					W1=request("W1")
					W2=request("W2")
					W3=request("W3")
					D=request("D")
					if not isNumeric(D) then
						D=0
					else
						D=cint(D)
					end if
					Z=request("Z")
					if not isNumeric(Z) then
						Z=0
					else
						Z=cint(Z)
					end if
					W1_1=replace(W1," ","")
					W2_1=replace(W2," ","")
					W3_1=replace(W3," ","")
					W3_list=replace(getW3(W1_1,W2_1,W3_1)," ","")
					W3_list=getLimitedW3(W3_list,2,2,0,session("personzbintel2007"))
					if W3_list<>"" and W3_list<>"0" then
						Str_Result=Str_Result+" and a.cateid in ("&W3_list&") and a.cateid<>'' and a.cateid is not NULL"
'if W3_list<>"" and W3_list<>"0" then
					end if
					if Z>0 then
						if D>0 then
							Str_Result=Str_Result+" and a.zdy"&Z&"="&D
'if D>0 then
						end if
					else
						if D>0 then
							Str_Result=Str_Result+" and a.trade="&D
'if D>0 then
						end if
					end if
					m1=request("ret")
					m2=request("ret2")
					reta1=request("reta1")
					reta2=request("reta2")
					if reeta1<>"" then
						m1=reta1
					end if
					if reta2<>"" then
						m2=reta2
					end if
					page_count=request("page_count")
					if not isNumeric(page_count) or page_count="" then
						page_count=10
					else
						page_count=cint(page_count)
					end if
					pageOrder=request("pageOrder")
					if not isNumeric(pageOrder) or pageOrder="" then
						pageOrder=1
					else
						pageOrder=cint(pageOrder)
					end if
					select case pageOrder
					case 1
					Str_Order = " order by date1 desc"
					case 2
					Str_Order = " order by date1 asc"
					case 3
					Str_Order = " order by title desc,date1 desc"
					case 4
					Str_Order = " order by title asc,date1 asc"
					case 5
					Str_Order = " order by order1 desc,date1 desc"
					case 6
					Str_Order = " order by order1 asc,date1 asc"
					case 7
					Str_Order = " order by type1 desc,date1 desc"
					case 8
					Str_Order = " order by type1 asc,date1 asc"
					case 9
					Str_Order = " order by num1 desc"
					case 10
					Str_Order = " order by num1 asc"
					case 11
					Str_Order = " order by contractTitle desc,date1 desc"
					case 12
					Str_Order = " order by contractTitle asc,date1 asc"
					case 13
					Str_Order = " order by name desc,date1 desc"
					case 14
					Str_Order = " order by name asc,date1 asc"
					case 15
					Str_Order = " order by contractNum desc"
					case 16
					Str_Order = " order by contractNum asc"
					end select
					CurrPage=request("CurrPage")
					if not isNumeric(CurrPage) or CurrPage="" then
						CurrPage=1
					else
						CurrPage=cint(CurrPage)
					end if
					productNo=request("productNo")
					companyName=request("companyName")
					productName=request("productName")
					productType=request("productType")
					contractName=request("contractName")
					intro=request("intro")
					num1=request("num1")
					num2=request("num2")
					contractNum1=request("contractNum1")
					contractNum2=request("contractNum2")
					product_zdy1=request("product_zdy1")
					product_zdy2=request("product_zdy2")
					product_zdy3=request("product_zdy3")
					product_zdy4=request("product_zdy4")
					product_zdy5=request("product_zdy5")
					product_zdy6=request("product_zdy6")
					m3=Trim(request("m3"))
					m4=Trim(request("m4"))
					pdBegin=trim(request("pdBegin"))
					pdEnd=trim(request("pdEnd"))
					pdUnit=trim(request("pdUnit"))
					contractPerson=Trim(Request("contractPerson"))
					If contractPerson <> "" Then
						Str_Result=Str_Result+" AND c.person IN (SELECT ord FROM person WHERE name LIKE '%"&contractPerson&"%') "
'If contractPerson <> "" Then
					end if
					if not isNumeric(num1) then
						num1=0
					else
						num1=clng(num1)
					end if
					if not isNumeric(num2) then
						num2=0
					else
						num2=clng(num2)
					end if
					total1=request("total1")
					total2=request("total2")
					if not isNumeric(total1) then
						total1=0
					else
						total1=cdbl(total1)
					end if
					if not isNumeric(total2) then
						total2=0
					else
						total2=cdbl(total2)
					end if
					if not isNumeric(contractNum1) then
						contractNum1=0
					else
						contractNum1=clng(contractNum1)
					end if
					if not isNumeric(contractNum2) then
						contractNum2=0
					else
						contractNum2=clng(contractNum2)
					end if
					bz=request("bz")
					if not isNumeric(bz) then
						bz=0
					else
						bz=cint(bz)
					end if
					if bz>0 then
						Str_Result=Str_Result+" and a.bz="&bz
'if bz>0 then
					end if
					if num1>0 then
						Str_Result=Str_Result+" and a.num1>="&num1
'if num1>0 then
					end if
					if num2>0 then
						Str_Result=Str_Result+" and a.num1<="&num2
'if num2>0 then
					end if
					if total1>0 then
						Str_Result=Str_Result+" and a.money1>="&total1
'if total1>0 then
					end if
					if total2>0 then
						Str_Result=Str_Result+" and a.money1<="&total2
'if total2>0 then
					end if
					Str_Result3=""
					if contractNum1>0 then
						Str_Result3=Str_Result3&" and contractNum>="&contractNum1
					end if
					if contractNum2>0 then
						Str_Result3=Str_Result3&" and contractNum<="&contractNum2
					end if
					if productName<>"" then
						Str_Result=Str_Result+" and b.title like'%" & productName &"%'"
'if productName<>"" then
					end if
					if productNo<>"" then
						Str_Result=Str_Result+" and b.order1 like'%" & productNo &"%'"
'if productNo<>"" then
					end if
					if productType<>"" then
						Str_Result=Str_Result+" and b.type1 like'%" & productType &"%'"
'if productType<>"" then
					end if
					if companyName<>"" then
						Str_Result=Str_Result+" and d.name like'%" & companyName &"%'"
'if companyName<>"" then
					end if
					if contractName<>"" then
						Str_Result=Str_Result+" and c.title like'%" & contractName &"%'"
'if contractName<>"" then
					end if
					if intro<>"" then
						Str_Result=Str_Result+" and b.intro3 like'%" & intro &"%'"
'if intro<>"" then
					end if
					if product_zdy1<>"" then
						Str_Result=Str_Result + " and a.zdy1 like '%" & product_zdy1 & "%'"
'if product_zdy1<>"" then
					end if
					if product_zdy2<>"" then
						Str_Result=Str_Result + " and a.zdy2 like '%" & product_zdy2 & "%'"
'if product_zdy2<>"" then
					end if
					if product_zdy3<>"" then
						Str_Result=Str_Result + " and a.zdy3 like '%" & product_zdy3 & "%'"
'if product_zdy3<>"" then
					end if
					if product_zdy4<>"" then
						Str_Result=Str_Result + " and a.zdy4 like '%" & product_zdy4 & "%'"
'if product_zdy4<>"" then
					end if
					if product_zdy5<>"" then
						Str_Result=Str_Result + " and a.zdy5 = " & product_zdy5
'if product_zdy5<>"" then
					end if
					if product_zdy6<>"" then
						Str_Result=Str_Result + " and a.zdy6 = " & product_zdy6
'if product_zdy6<>"" then
					end if
					if pdBegin<>"" then
						Str_Result=Str_Result & " and z.date5>=cast('" & pdBegin & "' as datetime)"
					end if
					if pdEnd<>"" then
						Str_Result=Str_Result & " and z.date5<dateadd(s,-1,dateadd(d,1,cast('" & pdEnd & "' as datetime)))"
'if pdEnd<>"" then
					end if
					If m3<>"" Then
						Str_Result=Str_Result & " and c.date3>=cast('" & m3 & "' as datetime)"
					end if
					If m4<>"" Then
						Str_Result=Str_Result & " and c.date3<dateadd(s,-1,dateadd(d,1,cast('" & m4 & "' as datetime)))"
'If m4<>"" Then
					end if
					if pdUnit<>"" then
						Str_Result=Str_Result & " and a.unit=" & pdUnit
					end if
					product1=session("areazbinteltj2007")
					if product1<>"" then
						Str_Result=Str_Result+" and b.ord="&product1&" "
'if product1<>"" then
					end if
					pdid=request("pdid")
					if pdid<>"" then
						Str_Result=Str_Result+" and b.ord="&pdid&" "
'if pdid<>"" then
					end if
					clid = request("clid")
					If clid&""<>"" Then
						Str_Result=Str_Result & " and a.id="& clid
					end if
					A3=request("A3")
					function menuarea(id1)
						set rsarea=server.CreateObject("adodb.recordset")
						sqlarea="select id from menuarea where id1="&id1&" "
						rsarea.open sqlarea,conn,1,1
						if rsarea.eof then
						else
							do until rsarea.eof
								gateord22=rsarea("id")
								If Len(area_list) = 0 Then
									area_list = "" & gateord22 & ""
								ElseIf InStr( area_list, gateord22 ) <= 0 Then
									area_list = area_list & ", " & gateord22 & ""
								end if
								menuarea(rsarea("id"))
								rsarea.movenext
							loop
						end if
						rsarea.close
						set rsarea=nothing
					end function
	area_list="0"
	if A3<>"" then
		menuarea(A3)
		Str_Result=Str_Result+" and  a.area in ("&area_list&") and a.area<>0"
		menuarea(A3)
	end if
	function menu(id1)
		set rsarea=server.CreateObject("adodb.recordset")
		sqlarea="select id,id1 from menu where id1="&id1&" "
		rsarea.open sqlarea,conn,1,1
		if rsarea.eof then
			gateord22=id1
			If Len(area_list) = 0 Then
				product_list = "" & gateord22 & ""
			ElseIf InStr( product_list, gateord22 ) <= 0 Then
				product_list = product_list & ", " & gateord22 & ""
			end if
		else
			do until rsarea.eof
				gateord22=rsarea("id")
				If Len(product_list) = 0 Then
					product_list = "" & gateord22 & ""
				ElseIf InStr( product_list, gateord22 ) <= 0 Then
					product_list = product_list & ", " & gateord22 & ""
				end if
				menu(rsarea("id"))
				rsarea.movenext
			loop
		end if
		rsarea.close
		set rsarea=nothing
	end function
	A2=request("A2")
	product_list="0"
	if A2<>"" then
		aryReturn2 = Split(A2,",")
		For i = 0 To UBound(aryReturn2)
			n=0
			set rs2=server.CreateObject("adodb.recordset")
			sql="select id from menu where id1="&aryReturn2(i)&" "
			rs2.open sql,conn,1,1
			if rs2.eof then
				n=0
			else
				do until rs2.eof
					if  CheckPurview(A2,trim(rs2("id")))=True  then
						n=1
					end if
					if n=1 then exit do
					rs2.movenext
				loop
			end if
			rs2.close
			set rs2=nothing
			if n=0 then
				menu(aryReturn2(i))
			end if
		next
		Str_Result=Str_Result+" and  b.sort1 in ("&product_list&") and b.sort1<>''"
		menu(aryReturn2(i))
	end if
	Str_Result2=""
	if m1<>"" then
		Str_Result=Str_Result+" and a.date1>='"&m1&"' "
'if m1<>"" then
		Str_Result2=Str_Result2+" and date1>='"&m1&"' "
'if m1<>"" then
	end if
	if m2<>"" then
		Str_Result=Str_Result+" and a.date1<='"&cdate(m2)&"' "
'if m2<>"" then
		Str_Result2=Str_Result2+" and date1<='"&cdate(m2)&"' "
'if m2<>"" then
	end if
	B=request("B")
	C=request("C")
	if C<>"" then
		if B = "cpmc" then
			Str_Result=Str_Result+" and b.title like '%"& C &"%'"
'if B = "cpmc" then
		elseif B = "cpxh" then
			Str_Result=Str_Result+" and b.type1 like '%"& C &"%'"
'elseif B = "cpxh" then
		elseif B = "cpbh" then
			Str_Result=Str_Result+" and b.order1 like '%"& C &"%'"
'elseif B = "cpbh" then
		elseif B = "cpsm" then
			Str_Result=Str_Result+" and b.intro1 like '%"& C &"%'"
'elseif B = "cpsm" then
		elseif B = "cpcs" then
			Str_Result=Str_Result+" and b.intro2 like '%"& C &"%'"
'elseif B = "cpcs" then
		elseif B = "cpbz" then
			Str_Result=Str_Result+" and b.intro3 like '%"& C &"%'"
'elseif B = "cpbz" then
		elseif B="htzt"  then
			Str_Result=Str_Result+" and c.title like '%"& C &"%'"
'elseif B="htzt"  then
		elseif B="khmc"  then
			Str_Result=Str_Result+" and d.name like '%"& C &"%'"
'elseif B="khmc"  then
		end if
	end if
	sumMoney=0
	sumMoney1=0
	sumNum1=0
	sumNum=0
	if pdBegin<>"" or pdEnd<>"" Or m3<>"" Or m4<>"" then
		strTable=" from kuout z inner join kuoutlist2 x on z.ord=x.kuout inner join contractlist a on x.contractlist=a.id inner join contract c on a.contract=c.ord and c.del=1 left join product b" & _
		" on a.ord=b.ord left join tel d on isnull(c.company,0)=d.ord " & _
		" left join sortonehy u on u.ord=a.unit left join sortbz s on s.id=a.bz left join hl h on h.bz=a.bz and h.date1=c.date3 "
		strSqls="select sum(num_out) as sumNum_out,sum(cast(num_out*money1 as decimal(25,12))/(case num1 when 0 then 1 else num1 end)) as sumMoney,sum(cast(cast(num_out*money1 as decimal(25,12))*hl as decimal(25,12))/(case num1 when 0 then 1 else num1 end)) as sumMoney_rmb from (" & _
		"select x.num1 as num_out,a.ord,isnull(a.price1,0) as price1,a.num1,isnull(a.money1,0) as money1,a.num3,a.contract,a.date1,a.zdy1,a.zdy2,a.zdy3,a.zdy4,a.zdy5,a.zdy6" & _
		",b.title,b.order1,b.type1,c.title as contractTitle,c.company,d.name" & _
		",s.sort1 as bz,u.sort1 as unit,isnull(h.hl,1) as hl" & _
		",(select count(distinct contract) from contractlist where contract=c.ord and ord=b.ord" & Str_Result2&") as contractNum" & _
		"strTable & Str_Result &"") as t where 1=1 "" & Str_Result2 & Str_Result3"
		strSql="select * from (select x.num1 as num_out,a.ord,isnull(a.price1,0) as price1,isnull(a.num1,0) as num1,isnull(a.money1,0) as money1,a.num3" & _
		",a.contract,a.date1,a.zdy1,a.zdy2,a.zdy3,a.zdy4,a.zdy5,a.zdy6" & _
		",b.title,b.order1,b.type1,c.title as contractTitle,c.company,isnull(c.cateid,0) htcateid,isnull(d.cateid,0) khcateid,d.name" & _
		",s.sort1 as bz,u.sort1 as unit" & _
		",(select count(distinct contract) from contractlist where contract=c.ord and ord=b.ord" & Str_Result2&") as contractNum" & _
		"strTable & Str_Result &"") as t where 1=1 "" & Str_Result2 & Str_Result3 & Str_Order"
	else
		strTable=" from contractlist a inner join contract c on a.contract=c.ord and c.del=1 left join product b" & _
		" on a.ord=b.ord left join tel d on isnull(c.company,0)=d.ord " & _
		" left join sortonehy u on u.ord=a.unit left join sortbz z on z.id=a.bz left join hl h on h.bz=a.bz and h.date1=c.date3 "
		strSqls="select sum(num1) as sumNum,sum(money1) as sumMoney,SUM(money1*hl) as sumMoney_rmb from (" & _
		"select a.ord,a.price1,a.num1,a.money1,a.num3,a.contract,a.date1,a.zdy1,a.zdy2,a.zdy3,a.zdy4,a.zdy5,a.zdy6" & _
		",b.title,b.order1,b.type1,c.title as contractTitle,c.company,d.name" & _
		",z.sort1 as bz,u.sort1 as unit,isnull(h.hl,1) as hl" & _
		",contractNum=(select count(distinct contract) from contractlist where ord=b.ord" & Str_Result2&")" & _
		"strTable & Str_Result &"") as t where 1=1"" & Str_Result2 & Str_Result3"
		strSql="select * from (select a.ord,a.price1,isnull(a.num1,0) as num1,a.money1,a.num3" & _
		",a.contract,a.date1,a.zdy1,a.zdy2,a.zdy3,a.zdy4,a.zdy5,a.zdy6" & _
		",b.title,b.order1,b.type1,c.title as contractTitle,c.company,isnull(c.cateid,0) htcateid,isnull(d.cateid,0) khcateid,d.name" & _
		",z.sort1 as bz,u.sort1 as unit" & _
		",contractNum=(select count(distinct contract) from contractlist where ord=b.ord" & Str_Result2&")" & _
		"strTable & Str_Result &"") as t where 1=1"" & Str_Result2 & Str_Result3 & Str_Order"
	end if
	set rs=server.CreateObject("adodb.recordset")
	rs.open strSqls,conn
	if rs.eof=false then
		sumNum=rs(0)
		sumMoney=rs(1)
		sumMoney_rmb = rs(2)
	end if
	rs.close
	i=0
	rs.open strSql,conn,1,1
	intCount=rs.recordcount
	do while rs.eof=false
		i=i+1
'do while rs.eof=false
		numcg1=0
		numcg2=0
		numcg1m=0
		numcg2m=0
		numcg3m=0
		numcg1=cdbl(rs("num1"))
		numcg2=cdbl(rs("num3"))
		numcg1m=zbcdbl(rs("price1"))
		If numcg1=0 Then
			numcg3m=0
		else
			numcg3m=zbcdbl(rs("money1"))/numcg1
		end if
		numcg2m=numcg1*numcg3m
		sumMoney1=sumMoney1+numcg2m
		numcg2m=numcg1*numcg3m
		sumNum1=cdbl(sumNum1)+cdbl(numcg1)
		numcg2m=numcg1*numcg3m
		htcateid = rs("htcateid")
		khcateid = rs("khcateid")
		If numcg1 = 0 Then
			zk = 1
		else
			if numcg1m=0 then
				zk=zbcdbl(rs("money1"))/cdbl(rs("num1"))
			else
				zk=zbcdbl(rs("money1"))/zbcdbl(rs("price1"))/cdbl(rs("num1"))
			end if
		end if
		xlWorksheet.Cells(1+i,1).Value = rs("date1")
		zk=zbcdbl(rs("money1"))/zbcdbl(rs("price1"))/cdbl(rs("num1"))
		xlWorksheet.Cells(1+i,1).font.Size=10
		zk=zbcdbl(rs("money1"))/zbcdbl(rs("price1"))/cdbl(rs("num1"))
		if isnull(rs("title")) then
			productName="产品已删除"
		else
			productName=rs("title")
		end if
		xlWorksheet.Cells(1+i,2).Value = productName
		productName=rs("title")
		xlWorksheet.Cells(1+i,2).font.Size=10
		productName=rs("title")
		xlWorksheet.Cells(1+i,3).Value = rs("order1")
		productName=rs("title")
		xlWorksheet.Cells(1+i,3).font.Size=10
		productName=rs("title")
		xlWorksheet.Cells(1+i,4).Value = rs("type1")
		productName=rs("title")
		xlWorksheet.Cells(1+i,4).font.Size=10
		productName=rs("title")
		xlWorksheet.Cells(1+i,5).Value = rs("unit")
		productName=rs("title")
		xlWorksheet.Cells(1+i,5).font.Size=10
		productName=rs("title")
		j=6
		set rs1=server.CreateObject("adodb.recordset")
		strSql1="SELECT a.name,a.sort,a.gl FROM zdy a inner join zdymx b on a.name=b.name WHERE b.sort1=5 and a.sort1=21 AND b.set_open=1 order by a.gate1"
		rs1.open strSql1,conn
		do while not rs1.eof
			if rs1("sort")=2 then
				zdyname=rs(trim(rs1(0)))
				if zdyname<>"" and isnull(zdyname)=false then
					zdyname=replace(replace(zdyname,"<br>",""),"&nbsp;","")
				end if
			elseif rs1("sort")=1 then
				if IsNumeric(rs(""&rs1("name")&"")) then
					set rs7=server.CreateObject("adodb.recordset")
					sql7="select ord,sort1 from sortonehy where ord="&rs(""&rs1("name")&"")&""
					rs7.open sql7,conn,1,1
					if rs7.eof then
						zdyname=""
					else
						zdyname=rs7("sort1")
					end if
					rs7.close
					set rs7=nothing
				else
					zdyname=""
				end if
			end if
			xlWorksheet.Cells(1+i,j).Value = zdyname
			zdyname=""
			xlWorksheet.Cells(1+i,j).font.Size=10
			zdyname=""
			j=j+1
			zdyname=""
			rs1.movenext
		loop
		rs1.close
		xlWorksheet.Cells(1+i,j).Value = rs("bz")
		rs1.close
		xlWorksheet.Cells(1+i,j).font.Size=10
		rs1.close
		j=j+1
		rs1.close
		xlWorksheet.Cells(1+i,j).Value = Formatnumber(zbcdbl(rs("num1")),num1_dot,-1)
		rs1.close
		xlWorksheet.Cells(1+i,j).font.Size=10
		rs1.close
		xlWorksheet.Cells(1+i,j).HorizontalAlignment=1
		rs1.close
		j=j+1
		rs1.close
		xlWorksheet.Cells(1+i,j).Value = Formatnumber(numcg1m,num_dot_xs,-1)
		rs1.close
		xlWorksheet.Cells(1+i,j).font.Size=10
		rs1.close
		xlWorksheet.Cells(1+i,j).HorizontalAlignment=1
		rs1.close
		j=j+1
		rs1.close
		xlWorksheet.Cells(1+i,j).Value = Formatnumber(numcg3m,num_dot_xs,-1)
		rs1.close
		xlWorksheet.Cells(1+i,j).font.Size=10
		rs1.close
		xlWorksheet.Cells(1+i,j).HorizontalAlignment=1
		rs1.close
		j=j+1
		rs1.close
		xlWorksheet.Cells(1+i,j).Value = Formatnumber(zk,discount_dot_num,-1)
		rs1.close
		xlWorksheet.Cells(1+i,j).font.Size=10
		rs1.close
		xlWorksheet.Cells(1+i,j).HorizontalAlignment=1
		rs1.close
		j=j+1
		rs1.close
		xlWorksheet.Cells(1+i,j).Value = Formatnumber(numcg2m,num_dot_xs,-1)
		rs1.close
		xlWorksheet.Cells(1+i,j).font.Size=10
		rs1.close
		xlWorksheet.Cells(1+i,j).HorizontalAlignment=1
		rs1.close
		j=j+1
		rs1.close
		if ZBRuntime.MC(7000) and (open_5_1=3 or (CheckPurview(intro_5_1,trim(htcateid)) And htcateid&""<>"" And htcateid&""<>"0")) then
			contractTitle = ""
			if isnull(rs("contractTitle")) then
				contractTitle="合同已被删除"
			else
				contractTitle=rs("contractTitle")
			end if
		end if
		xlWorksheet.Cells(1+i,j).Value = contractTitle
		contractTitle=rs("contractTitle")
		xlWorksheet.Cells(1+i,j).font.Size=10
		contractTitle=rs("contractTitle")
		j=j+1
		contractTitle=rs("contractTitle")
		xlWorksheet.Cells(1+i,j).Value = rs("contractNum")
		contractTitle=rs("contractTitle")
		xlWorksheet.Cells(1+i,j).font.Size=10
		contractTitle=rs("contractTitle")
		xlWorksheet.Cells(1+i,j).HorizontalAlignment=1
		contractTitle=rs("contractTitle")
		j=j+1
		contractTitle=rs("contractTitle")
		if ZBRuntime.MC(1000) and (open_1_1=3 or (CheckPurview(intro_1_1,trim(khcateid)) And khcateid&""<>"" And khcateid&""<>"0")) then
			companyName = ""
			if isnull(rs("name")) then
				companyName="客户已被删除"
			else
				companyName=rs("name")
			end if
		end if
		xlWorksheet.Cells(1+i,j).Value = companyName
		companyName=rs("name")
		xlWorksheet.Cells(1+i,j).font.Size=10
		companyName=rs("name")
		Call ClientClosedExit
		Response.write "<script>CountImage.width=" & Fix((i/intCount) * 710) & ";" & VbCrLf
		Response.write "CountTXT.innerHTML=""共有<font color=red><b>"&intCount&"</b></font>条数据!导出进度:<font color=red><b>" & Clng(FormatNumber(i/intCount*100,4,-1)) & "</b></font>"";" & VbCrLf
		Response.write "<script>CountImage.width=" & Fix((i/intCount) * 710) & ";" & VbCrLf
		Response.write "CountImage.title=""正在处理数据,请稍后..."";</script>" & VbCrLf
		Response.Flush
		rs.movenext
	loop
	rs.close
	set rs=nothing
	set rs1=nothing
	if not IsNumeric(trim(sumNum)) Then sumNum=0
	if not IsNumeric(trim(sumMoney)) Then sumMoney=0
	xlWorksheet.Range("A"&(2+i)&":"&chr(70+colsCount)&(2+i)).Merge
	if not IsNumeric(trim(sumMoney)) Then sumMoney=0
	xlWorksheet.Cells(2+i,1).font.bold=true
	if not IsNumeric(trim(sumMoney)) Then sumMoney=0
	xlWorksheet.Cells(2+i,1).Value = "合计"
	if not IsNumeric(trim(sumMoney)) Then sumMoney=0
	xlWorksheet.Cells(2+i,1).font.Size=10
	if not IsNumeric(trim(sumMoney)) Then sumMoney=0
	xlWorksheet.Cells(2+i,7+colsCount).Value = Formatnumber(sumNum1,num1_dot,-1)
	if not IsNumeric(trim(sumMoney)) Then sumMoney=0
	xlWorksheet.Cells(2+i,7+colsCount).font.Size=10
	if not IsNumeric(trim(sumMoney)) Then sumMoney=0
	xlWorksheet.Cells(2+i,7+colsCount).HorizontalAlignment=1
	if not IsNumeric(trim(sumMoney)) Then sumMoney=0
	xlWorksheet.Cells(2+i,11+colsCount).Value = Formatnumber(sumMoney,num_dot_xs,-1)
	if not IsNumeric(trim(sumMoney)) Then sumMoney=0
	xlWorksheet.Cells(2+i,11+colsCount).font.Size=10
	if not IsNumeric(trim(sumMoney)) Then sumMoney=0
	xlWorksheet.Cells(2+i,11+colsCount).HorizontalAlignment=1
	if not IsNumeric(trim(sumMoney)) Then sumMoney=0
	xlWorksheet.Cells(3+i,11+colsCount).Value = "￥"& Formatnumber(sumMoney_rmb,num_dot_xs,-1)
	if not IsNumeric(trim(sumMoney)) Then sumMoney=0
	xlWorksheet.Cells(3+i,11+colsCount).font.Size=10
	if not IsNumeric(trim(sumMoney)) Then sumMoney=0
	xlWorksheet.Cells(3+i,11+colsCount).HorizontalAlignment=1
	if not IsNumeric(trim(sumMoney)) Then sumMoney=0
	Response.write "<script>CountImage.width=710;CountTXT.innerHTML=""<font color=red><b>产品销售明细导出全部完成!</b></font>  100"";CountTXTok.innerHTML=""<B>恭喜!产品销售明细导出成功,共有"&(i)&"条记录!</B>"";</script>"
	Response.write "" & vbcrlf & "</BODY>" & vbcrlf & "</HTML>" & vbcrlf & ""
	Set fs = CreateObject("Scripting.FileSystemObject")
	tfile=Server.MapPath("产品销售明细_"&session("name2006chen")&".xls")
	if fs.FileExists(tfile) then
		Set f = fs.GetFile(tfile)
		f.delete true
		Set f = nothing
	end if
	Set fs = nothing
	xlWorksheet.SaveAs tfile
	xlApplication.Quit
	Set xlWorksheet = Nothing
	Set xlApplication = Nothing
	action1="产品销售明细导出"
	call close_list(1)
	Response.write " " & vbcrlf & "<p align=""center""><a href=""downfile.asp?fileSpec="
	Response.write tfile
	Response.write """><font class=""red""><strong><u>下载导出的产品销售明细</u></strong></font></a></p> " & vbcrlf & ""
	
%>
