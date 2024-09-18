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
	
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=1 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_1_11=0
		intro_1_11=0
	else
		open_1_11=rs1("qx_open")
		intro_1_11=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	if open_1_11=3 then
		list_tj=""
	elseif open_1_11=1 then
		list_tj="and x.cateid in ("&intro_1_11&")"
	else
		list_tj="and x.cateid=0"
	end if
	dim rs,sql,Str_Result,Str_Result2,catesafe,sorce_user,sorce_user2
	Str_Result="where x.del=1 "&list_tj&""
	Str_Result2="and x.del=1 "&list_tj&""
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
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=1 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_1_10=0
		intro_1_10=0
	else
		open_1_10=rs1("qx_open")
		intro_1_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=1 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_1_7=0
		intro_1_7=0
	else
		open_1_7=rs1("qx_open")
		intro_1_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=17"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_17=0
		intro_5_17=0
	else
		open_5_17=rs1("qx_open")
		intro_5_17=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	
	Class ExcelApp
		Public SheetsInNewWorkbook
		Public WorkBooks
		Public Visible
		Public ActiveSheet
		Public lastRowIndex
		Public CurrFileIndex
		Private m_RecordCount
		Public  currMainRecCount
		Public exportPercent
		Public headerCells
		Private sheets
		Private m_FileName
		Private m_FileBaseName
		Private m_FileExtName
		Private m_numberDot
		Private m_moneyDot
		Public regEx
		Public isMainDetailMode
		Private m_xlsApp
		Public xsheet
		Public sheetPerFile
		Public recordPerSheet
		Public sheetNumInFile
		Public recordNumInSheet
		Public Property Get RecordCount
		RecordCount = m_RecordCount
		End Property
		Public Sub Init(fname,recCnt)
			m_RecordCount = recCnt
			If isMainDetailMode = False Then
				currMainRecCount = recCnt
			else
				currMainRecCount = 0
			end if
			m_FileName = fname
			m_FileName = Replace(m_FileName,"/","")
			m_FileName = Replace(m_FileName,":","")
			m_FileName = Replace(m_FileName,"*","")
			m_FileName = Replace(m_FileName,"?","")
			m_FileName = Replace(m_FileName,"""","")
			m_FileName = Replace(m_FileName,"<","")
			m_FileName = Replace(m_FileName,">","")
			m_FileName = Replace(m_FileName,"|","")
			If Len(m_FileName) = 0 Then
				m_FileName = "未命名.xls"
			ElseIf InStr(m_FileName,".")=0 Then
				m_FileName = m_FileName & ".xls"
			end if
			Dim m_Names
			m_Names=Split(m_FileName,".")
			m_FileExtName = m_Names(ubound(m_Names))
			m_FileBaseName =left(m_FileName,len(m_FileName)-len(m_FileExtName)-1)
'm_FileExtName = m_Names(ubound(m_Names))
		end sub
		Public Property Get FileName
		FileName = m_fileBaseName & "-" & CurrFileIndex & "." & m_fileExtName
'Public Property Get FileName
		End Property
		Public Property Get FileRealPath
		FileRealPath = Server.mappath("../out/") & "\" & Me.FileName
		End Property
		Public Property Get numberDot
		numberDot = m_numberDot
		End Property
		Public Property Get moneyDot
		moneyDot = m_moneyDot
		End Property
		Public Property Get xlsApp
		Set xlsApp = m_xlsApp
		End Property
		Public Function WorkSheets(i)
			Set ActiveSheet = sheets(i)
			Set WorkSheets = ActiveSheet
		end function
		Public Sub NewFile
			Set m_xlsApp = server.createobject(ZBRLibDLLNameSN & ".HtmlExcelApplication")
			m_xlsApp.init zblog.PageScript , conn
			Set xsheet = m_xlsApp.sheets.add(ActiveSheet.name)
			CurrFileIndex = CurrFileIndex + 1
'Set xsheet = m_xlsApp.sheets.add(ActiveSheet.name)
		end sub
		Private Sub class_initialize
			Set m_xlsApp = server.createobject(ZBRLibDLLNameSN & ".HtmlExcelApplication")
			m_xlsApp.init zblog.PageScript , conn
			SheetsInNewWorkbook = 1
			Set WorkBooks = New ExcelWorkBooks
			Set WorkBooks.parent = Me
			Set sheets = New ExcelCommonCollections
			sheets.ClassName = "ExcelWorkSheet"
			Set sheets.parent = Me
			CurrFileIndex = 1
			Dim sheet : Set sheet = New ExcelWorkSheet
			Set sheet.parent = sheets
			Set headerCells = New ExcelCommonCollections
			headerCells.ClassName = "ExcelCell"
			Set headerCells.parent = Me
			lastRowIndex = 0
			sheetPerFile = 1
			recordPerSheet = 10000
			sheetNumInFile = 1
			recordNumInSheet = 0
			Set regEx = New RegExp
			regEx.Pattern = "<[^>]+>"
'Set regEx = New RegExp
			regEx.IgnoreCase = True
			regEx.Global = True
			m_numberDot = conn.execute("select num1 from setjm3 where ord=88")(0)
			m_moneyDot = conn.execute("select num1 from setjm3  where ord=1")(0)
			isMainDetailMode = False
			m_RecordCount = 0
		end sub
		Public Sub Quit
			Call m_xlsApp.Dispose()
		end sub
	End Class
	Class ExcelWorkBooks
		Public parent
		Public Sub Add
		end sub
	End Class
	Class ExcelWorkSheet
		Public parent
		Private m_name
		Public Property Let name(v)
		m_name = v
		Set parent.parent.xsheet = parent.parent.xlsApp.sheets.add(v)
		End Property
		Public Property Get name
		name = m_name
		End Property
		Public Columns
		Public Cells
		Public Function Range(strRange)
			Set Range = New ExcelRange
		end function
		Private Sub class_initialize
			Set Columns = New ExcelCommonCollections
			Columns.ClassName = "ExcelColumn"
			Set Columns.parent = Me
			Set Cells = New ExcelCellCollections
			Set Cells.parent = Me
		end sub
		Public Sub SaveAs(fPath)
			Dim root : Set root = parent.parent
			Call AutoSplitSheetAndFile
			Call WriteContentHtml
			Call root.xlsApp.Save(root.FileRealPath)
			Response.write "<script>exportProcBar.showExcelProgress(100," & root.RecordCount & "," & root.RecordCount & ")</script>"
			Response.write "<script>exportProcBar.addFileLink({fileUrl:'" & root.xlsApp.HexEncode(root.FileRealPath) & "',fileName:'" & root.FileName & "',fileCnt:" & root.CurrFileIndex & "})</script>"
		end sub
		Public Sub AutoSplitSheetAndFile
			Dim root : Set root = parent.parent
			If root.recordNumInSheet >= root.recordPerSheet Then
				If root.sheetNumInFile >= root.sheetPerFile Then
					Call parent.parent.xlsApp.Save(parent.parent.FileRealPath)
					Response.write "<script>exportProcBar.addFileLink({fileUrl:'" & root.xlsApp.HexEncode(root.FileRealPath) & "',fileName:'" & root.FileName & "',fileCnt:" & root.CurrFileIndex & "})</script>"
					Call root.NewFile
					root.sheetNumInFile = 1
				else
					Set root.xsheet = root.xlsApp.sheets.Add(name & (CLng(root.sheetNumInFile) + 1))
'root.sheetNumInFile = 1
					root.sheetNumInFile = root.sheetNumInFile + 1
'root.sheetNumInFile = 1
				end if
				Call WriteHeaderHtml
				root.recordNumInSheet = 1
			else
				root.recordNumInSheet = root.recordNumInSheet + 1
				root.recordNumInSheet = 1
			end if
			If root.isMainDetailMode Then
				If Not isDetailRow() Then
					root.currMainRecCount = root.currMainRecCount + 1
'If Not isDetailRow() Then
				end if
			else
				root.currMainRecCount = root.currMainRecCount + 1
'If Not isDetailRow() Then
			end if
		end sub
		Private Function isDetailRow()
			Dim pos : pos = getIdxOfDetailField()
			If pos < 0 Then
				isDetailRow = isAllEmptyCellBefore(3)
			Else
				isDetailRow = isAllEmptyCellBefore(pos)
			end if
		end function
		Private Function isAllEmptyCellBefore(idx)
			Dim rowIdx : rowIdx = parent.parent.lastRowIndex
			Dim i
			isAllEmptyCellBefore = True
			For i=1 To idx - 1
'isAllEmptyCellBefore = True
				If i > Cells.count Then Exit For
				If Cells(rowIdx,i).value & "" <> "" Then
					isAllEmptyCellBefore = False
					Exit Function
				end if
			next
			isAllEmptyCellBefore = True
		end function
		Private Function getIdxOfDetailField()
			Dim rowIdx : rowIdx = parent.parent.lastRowIndex
			Dim i
			For i=1 To Cells.count
				If InStr(Cells(rowIdx,i).value,"明细") > 0 Then
					getIdxOfDetailField = i
					Exit Function
				end if
			next
			getIdxOfDetailField = -1
			Exit Function
		end function
		Public Sub WriteHeaderHtml
			Call WriteCellHtml(True)
		end sub
		Public Sub WriteContentHtml
			Call WriteCellHtml(False)
		end sub
		Private Sub WriteCellHtml(isHeader)
			Dim i,root,outputCells
			Set root = parent.parent
			If isHeader Then
				Set outputCells = root.headerCells
			else
				Set outputCells = Cells
			end if
			For i = 1 To outputCells.count
				If isHeader Then
					Call outputCells(i).WriteCellHtml(isHeader,Columns(i))
				else
					Call outputCells.cell(i).WriteCellHtml(isHeader,Columns(i))
				end if
			next
			root.xsheet.movenext
		end sub
	End Class
	Class ExcelCommonCollections
		Dim datas()
		Public ClassName
		Public parent
		Private m_count
		Private m_maxIdx
		Public Property Get count
		count = m_count
		End Property
		Public Sub class_initialize
			m_count = 0
			m_maxIdx = 0
			Call allocationSpace
		end sub
		Public Default Function item(ByVal index)
			Dim i
			If isnumeric(index) Then
				If index > 0 Then
					If index > m_count Then
						Dim obj : Set obj = eval("New " & ClassName)
						Set obj.parent = Me
						Call addWithIdx(obj,index)
					end if
					Set item = datas(index)
				else
					Set item = Nothing
				end if
			else
				Set item = Nothing
			end if
		end function
		Private Sub addWithIdx(o,idx)
			While idx > m_maxIdx
				Call AllocationSpace
			wend
			Dim i,obj
			If idx > m_count Then
				For i = m_count + 1 To idx
'If idx > m_count Then
					Set obj = eval("New " & ClassName)
					Set obj.parent = Me
					Set datas(i) = obj
				next
				m_count = idx
			end if
			Set datas(idx) = o
		end sub
		Public Function Add(o)
			m_count = m_count + 1
'Public Function Add(o)
			Add = m_count
			If m_count > m_maxIdx Then
				Call allocationSpace
			end if
			Set datas(m_count) = o
			Call parent.onAfterAdd
		end function
		Private Sub allocationSpace
			m_maxIdx = m_maxIdx + 500
'Private Sub allocationSpace
			ReDim Preserve datas(m_maxIdx)
		end sub
	End Class
	Class ExcelCellCollections
		Dim cells()
		Public parent
		Private m_count
		Private m_maxIdx
		Public Property Get count
		count = m_count
		End Property
		Public Function cell(idx)
			Set cell = cells(idx)
		end function
		Public Sub class_initialize
			m_count = 0
			m_maxIdx = 0
			ReDim cells(m_maxIdx)
		end sub
		Public Default Function item(ByVal rowIndex,ByVal cellIndex)
			If cellIndex <= 0 Then
				Set item = Nothing
				Exit Function
			end if
			Dim i
			Dim sheet : Set sheet = parent
			Dim root : Set root = sheet.parent.parent
			Dim obj : Set obj = New ExcelCell
			Set obj.parent = Me
			If rowIndex > root.lastRowIndex Then
				If root.lastRowIndex = 1 Then
					For i=1 To m_count
						root.headerCells(i).copyFromObj cells(i)
						Set root.headerCells(i).parent = root.headerCells
					next
				end if
				If root.lastRowIndex > 1 Then
					Call sheet.AutoSplitSheetAndFile
				else
					root.recordNumInSheet = 0
					root.currMainRecCount = 0
				end if
				If root.lastRowIndex = 1 Then
					Call sheet.WriteHeaderHtml
				ElseIf root.lastRowIndex > 1 Then
					Call sheet.WriteContentHtml
				end if
				m_count = 0
				m_maxIdx = 0
				Erase cells
				If cellIndex >= m_count Then
					Call addWithIdx(obj,cellIndex)
				end if
				root.lastRowIndex = rowIndex
				Set item = cells(cellIndex)
				Dim percent
				If root.isMainDetailMode Then
					If root.RecordCount = 0 Then
						percent = 0
					else
						percent = CLng((root.currMainRecCount) * 100 / root.RecordCount)
					end if
					If percent - root.exportPercent >= 1 Then
						percent = CLng((root.currMainRecCount) * 100 / root.RecordCount)
						Response.write "<script>exportProcBar.showExcelProgress(" & percent & "," & root.RecordCount & "," & root.currMainRecCount & ")</script>"
					end if
					root.exportPercent = percent
				Else
					If root.RecordCount = 0 Then
						percent = 0
					else
						percent = CLng((root.lastRowIndex - 1) * 100 / root.RecordCount)
'percent = 0
					end if
					If percent - root.exportPercent >= 1 Then
'percent = 0
						Response.write "<script>exportProcBar.showExcelProgress(" & percent & "," & root.RecordCount & "," & root.lastRowIndex & ")</script>"
					end if
					root.exportPercent = percent
				end if
			ElseIf rowIndex = root.lastRowIndex Then
				If cellIndex > m_count Then
					Call addWithIdx(obj,cellIndex)
				end if
				Set item = cells(cellIndex)
			Else
				Set item = New ExcelCell
			end if
		end function
		Private Sub addWithIdx(o,idx)
			While idx > m_maxIdx
				Call AllocationSpace
			wend
			Dim i,obj
			If idx > m_count Then
				For i = m_count + 1 To idx
'If idx > m_count Then
					Set obj = New ExcelCell
					Set obj.parent = Me
					set cells(i) = obj
				next
				m_count = idx
			end if
			Set cells(idx) = o
		end sub
		Public Function Add(o)
			m_count = m_count + 1
'Public Function Add(o)
			Add = m_count
			If m_count > m_maxIdx Then
				Call AllocationSpace
			end if
			Set cells(m_count) = o
			Call parent.onAfterAdd
		end function
		Private Sub AllocationSpace
			m_maxIdx = m_maxIdx + 500
'Private Sub AllocationSpace
			ReDim Preserve cells(m_maxIdx)
		end sub
	End Class
	Class ExcelRange
		Public Borders
		Public Sub Merge
		end sub
		Private Sub class_initialize
			Set Borders = New ExcelBorders
		end sub
	End Class
	Class ExcelBorders
		Public LineStyle
		Private Sub class_initialize
		end sub
	End Class
	Class ExcelColumn
		Public parent
		Public ColumnWidth
		Public HorizontalAlignment
		Private m_dtType
		Private m_NumberFormatLocal
		Public Property Get NumberFormatLocal
		NumberFormatLocal = m_NumberFormatLocal
		End Property
		Public Property Let NumberFormatLocal(v)
		m_NumberFormatLocal = v
		Dim root : Set root = parent.parent.parent.parent
		Dim dotNum : dotNum = getDotNumFromMask()
		If dotNum = root.moneyDot Then
			m_dtType = "money"
		ElseIf dotNum = root.numberDot Then
			m_dtType = "number"
		ElseIf dotNum = 0 Then
			m_dtType = "int"
		else
			m_dtType = "str"
		end if
		End Property
		Public Property Get dtType
		dtType = m_dtType
		End Property
		Private Function getDotNumFromMask()
			If Len(m_NumberFormatLocal) = 0 Then
				getDotNumFromMask = -1
'If Len(m_NumberFormatLocal) = 0 Then
			else
				If InStr(m_NumberFormatLocal,".") = 0 Then
					getDotNumFromMask = 0
					Exit Function
				end if
				Dim tmp : tmp = Split(m_NumberFormatLocal,".")
				getDotNumFromMask = Len(Replace(Replace(tmp(1),"_","")," ",""))
			end if
		end function
		Public Function toString()
			toString =  "&nbsp;&nbsp;ColumnWidth:" & ColumnWidth & "<br>" &_
			"&nbsp;&nbsp;HorizontalAlignment:" & HorizontalAlignment & "<br>" &_
			"&nbsp;&nbsp;NumberFormatLocal:" & NumberFormatLocal & "<br>"
		end function
	End Class
	Class ExcelCell
		Public parent
		Public Value
		Public font
		Public colspan
		Public HorizontalAlignment
		Public NumberFormatLocal
		Public dtType
		Dim sheet,root
		Public Sub copyFromObj(obj)
			Value = obj.Value
			Set font = obj.font
			HorizontalAlignment = obj.HorizontalAlignment
			NumberFormatLocal = obj.NumberFormatLocal
			colspan = obj.colspan
		end sub
		Private Sub class_initialize
			Set font = New ExcelFont
		end sub
		Public Sub WriteCellHtml(isHeader,columnSetting)
			Dim root,v
			If isHeader Then
				Set root = parent.parent
				v = Replace(root.regEx.replace(value&"",""),"=","&#61;")
				v = "<b>" & v & "</b>"
			else
				Set root = parent.parent.parent.parent
				v = Replace(root.regEx.replace(value&"",""),"=","&#61;")
			end if
			Set xsheet = root.xsheet
			If Len(v) > 32767 Then v = Left(v,32767)
			Call xsheet.WriteHtmlCell(v,getCssText(isHeader,columnSetting))
		end sub
		Private Function getCssText(isHeader,columnSetting)
			Dim cssText,cssName,align,alignment
			alignment = Split("l,l,r,c",",")
			cssText = "font-size:12px;"
'alignment = Split("l,l,r,c",",")
			If isHeader Or font.bold = True Then cssText = cssText & "font-weight:bold;"
'alignment = Split("l,l,r,c",",")
			If font.color & "" <> "" Then cssText = cssText & "color:" & font.color & ";"
			If font.bgcolor & "" <> "" Then cssText = cssText & "background-color:" & font.bgcolor & ";"
'If font.color & "" <> "" Then cssText = cssText & "color:" & font.color & ";"
			align = ""
			dtType = "str"
			With columnSetting
			If .ColumnWidth & "" <> "" Then cssText = cssText & "width:" & .ColumnWidth * 10 & ";"
			If Len(.HorizontalAlignment) > 0 And isnumeric(.HorizontalAlignment) Then
				If .HorizontalAlignment > 0 And .HorizontalAlignment < 4 Then
					align = alignment(.HorizontalAlignment)
				end if
			end if
			If Len(.dtType) > 0 Then
				dtType = .dtType
			end if
			End With
			If isHeader Then
				align = "c"
			ElseIf Len(HorizontalAlignment)>0 And isnumeric(HorizontalAlignment) Then
				If HorizontalAlignment > 0 And HorizontalAlignment < 4 Then
					align = alignment(HorizontalAlignment)
				end if
			end if
			If align = "" Then align = "l"
			cssName = dtType & "A" & align
			getCssText = "class='" & cssName & "' style='" & cssText & "'"
			If colspan & "" <> "" And isnumeric(colspan) Then
				getCssText = getCssText & " colspan='" & colspan & "'"
			end if
		end function
		Public Function toString()
			toString =  "&nbsp;&nbsp;parent:" & typename(parent) & "<br>" &_
			"&nbsp;&nbsp;Value:" & value & "<br>" &_
			"&nbsp;&nbsp;font:{<br>" &_
			"Replace(font.toString(),""&nbsp;&nbsp;"",""&nbsp;&nbsp;&nbsp;&nbsp;"") "&_
			"&nbsp;&nbsp;}<br> "&_
			"&nbsp;&nbsp;HorizontalAlignment:" & HorizontalAlignment & "<br>" &_
			"&nbsp;&nbsp;NumberFormatLocal:" & NumberFormatLocal & "<br>"
		end function
	End Class
	Class ExcelFont
		Public bold
		Public Size
		Public color
		Public bgcolor
		Private Sub class_initialize
			bold = False
			Size = 10
		end sub
		Public Function toString()
			toString =  "&nbsp;&nbsp;bold:" & bold & "<br>" &_
			"&nbsp;&nbsp;Size:" & Size & "<br>"
		end function
	End Class
	Server.ScriptTimeOut=100000000
	Response.write " " & vbcrlf & "<HTML>" & vbcrlf & "<HEAD>" & vbcrlf & "<TITLE>客户资料导出</TITLE>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8""><style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body {" & vbcrlf & "       background-color: #FFFFFF;" & vbcrlf & "      margin-left: 0px;" & vbcrlf & "       margin-top: 0px;" & vbcrlf & " margin-right: 0px;" & vbcrlf & "      margin-bottom: 0px;" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & "</style></HEAD>" & vbcrlf & "<body>" & vbcrlf & " <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "  <tr>" & vbcrlf &"    <td class=""place"">客户利润率排行导出</td>" & vbcrlf & "    <td>&nbsp;</td>" & vbcrlf & "    <td align=""right"">&nbsp;</td>" & vbcrlf & "    <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>  " & vbcrlf & " <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "<tr class=""top"">" & vbcrlf & "  <td colspan=2 class=tablebody1>&nbsp;</td>" & vbcrlf & "</tr>" & vbcrlf & "<tr>" & vbcrlf & "  <td colspan=2 class=tablebody1>" & vbcrlf & "<span id=""CountTXTok"" name=""CountTXTok"" style=""font-size:10pt; color:#008040"">" & vbcrlf & "<B>正在导出客户利润率排行,请稍后...</B></span>" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""1"">" & vbcrlf & "<tr> " & vbcrlf & "<td bgcolor=000000>" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"">" & vbcrlf & "<tr> " & vbcrlf & "<td bgcolor=ffffff height=9><img src=""../images/tiao.jpg"" width=""0"" height=""16"" id=""CountImage"" name=""CountImage"" align=""absmiddle""></td></tr></table>" & vbcrlf & "</td></tr></table> <span id=""CountTXT"" name=""CountTXT"" style=""font-size:9pt; color:#008040"">0</span><span style=""font-size:9pt; color:#008040"">%</span></td></tr>" & vbcrlf & "<tr class=""top"">" & vbcrlf & "  <td colspan=2 class=tablebody1 height=""40"">" & vbcrlf & "  </td>" & vbcrlf & "</tr>" & vbcrlf & "</table>" & vbcrlf & ""
	Response.write Application("sys.info.jsver")
	dotstr=""
		for i=1 to num_dot_xs
			dotstr=dotstr&"0"
			next
			Set xlApplication = New ExcelApp
			xlApplication.Visible = False
			xlApplication.SheetsInNewWorkbook=1
			xlApplication.Workbooks.Add
			Set xlWorksheet = xlApplication.Worksheets(1)
			xlWorksheet.name="sheet1"
			xlApplication.ActiveSheet.Columns(1).ColumnWidth=20
			xlApplication.ActiveSheet.Columns(1).HorizontalAlignment=3
			xlApplication.ActiveSheet.Columns(2).ColumnWidth=10
			xlApplication.ActiveSheet.Columns(2).HorizontalAlignment=3
			xlApplication.ActiveSheet.Columns(3).ColumnWidth=10
			xlApplication.ActiveSheet.Columns(3).HorizontalAlignment=3
			xlApplication.ActiveSheet.Columns(3).NumberFormatLocal = "0."&dotstr&"% "
			xlApplication.ActiveSheet.Columns(4).ColumnWidth=10
			xlApplication.ActiveSheet.Columns(4).HorizontalAlignment=3
			xlApplication.ActiveSheet.Columns(4).NumberFormatLocal = "#,##0."&dotstr&"_ "
			xlApplication.ActiveSheet.Columns(5).ColumnWidth=10
			xlApplication.ActiveSheet.Columns(5).HorizontalAlignment=3
			xlApplication.ActiveSheet.Columns(5).NumberFormatLocal = "#,##0."&dotstr&"_ "
			xlApplication.ActiveSheet.Columns(6).ColumnWidth=10
			xlApplication.ActiveSheet.Columns(6).HorizontalAlignment=3
			xlApplication.ActiveSheet.Columns(6).NumberFormatLocal = "#,##0."&dotstr&"_ "
			xlApplication.ActiveSheet.Columns(7).ColumnWidth=10
			xlApplication.ActiveSheet.Columns(7).HorizontalAlignment=3
			xlApplication.ActiveSheet.Columns(7).NumberFormatLocal = "#,##0."&dotstr&"_ "
			xlApplication.ActiveSheet.Columns(8).ColumnWidth=10
			xlApplication.ActiveSheet.Columns(8).HorizontalAlignment=3
			xlApplication.ActiveSheet.Columns(9).ColumnWidth=10
			xlApplication.ActiveSheet.Columns(9).HorizontalAlignment=3
			khname=conn.execute("select (case when isnull(name,'')='' then oldname else name end ) as name from setfields where gate1=1")(0)
			khbianh=conn.execute("select (case when isnull(name,'')='' then oldname else name end ) as name from setfields where gate1=3")(0)
			xlWorksheet.Cells(1,1).Value = khname
			xlWorksheet.Cells(1,1).font.Size=10
			xlWorksheet.Cells(1,1).font.bold=true
			xlWorksheet.Cells(1,2).Value = khbianh
			xlWorksheet.Cells(1,2).font.Size=10
			xlWorksheet.Cells(1,2).font.bold=true
			xlWorksheet.Cells(1,3).Value = "利润率"
			xlWorksheet.Cells(1,3).font.Size=10
			xlWorksheet.Cells(1,3).font.bold=true
			xlWorksheet.Cells(1,4).Value = "利润总额"
			xlWorksheet.Cells(1,4).font.Size=10
			xlWorksheet.Cells(1,4).font.bold=true
			xlWorksheet.Cells(1,5).Value = "产品成本"
			xlWorksheet.Cells(1,5).font.Size=10
			xlWorksheet.Cells(1,5).font.bold=true
			xlWorksheet.Cells(1,6).Value = "费用总额"
			xlWorksheet.Cells(1,6).font.Size=10
			xlWorksheet.Cells(1,6).font.bold=true
			xlWorksheet.Cells(1,7).Value = "购买总额"
			xlWorksheet.Cells(1,7).font.Size=10
			xlWorksheet.Cells(1,7).font.bold=true
			xlWorksheet.Cells(1,8).Value = "购买次数"
			xlWorksheet.Cells(1,8).font.Size=10
			xlWorksheet.Cells(1,8).font.bold=true
			xlWorksheet.Cells(1,9).Value = "销售人员"
			xlWorksheet.Cells(1,9).font.Size=10
			xlWorksheet.Cells(1,9).font.bold=true
			xlWorksheet.Range("A2:I2").Borders.LineStyle=1
			Response.Flush
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
			sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=6 and sort2=1"
			rs1.open sql1,conn,1,1
			if rs1.eof then
				open_6_1=0
				intro_6_1=0
			else
				open_6_1=rs1("qx_open")
				intro_6_1=rs1("qx_intro")
			end if
			rs1.close
			set rs1=nothing
			currpage=Request("currpage")
			if currpage<="0" or currpage="" then
				currpage=1
			end if
			currpage=clng(currpage)
			bh=request.QueryString("bh")
			lie_1=request.QueryString("lie_1")
			if lie_1="" then
				lie_1=1
			end if
			lie_2=request.QueryString("lie_2")
			if lie_2="" then
				lie_2=1
			end if
			lie_3=request.QueryString("lie_3")
			if lie_3="" then
				lie_3=1
			end if
			lie_4=request.QueryString("lie_4")
			if lie_4="" then
				lie_4=1
			end if
			page_count=request.QueryString("page_count")
			if page_count="" then
				page_count=10
			end if
			Str_Result2= " where t.del=1 and t.sort3=1"
			ksjs=request("B")
			ksjs2=request("C")
			m1=request("ret")
			m2=request("ret2")
			js=request("js")
			if ksjs<>"" then
				if ksjs="mc" then
					F1=1
					F2=ksjs2
				elseif ksjs="pym" then
					S1=1
					S2=ksjs2
				elseif ksjs="bh" then
					Y1=1
					Y2=ksjs2
				elseif ksjs="dh" then
					G1=1
					G2=ksjs2
				elseif ksjs="cz" then
					P1=1
					P2=ksjs2
				elseif ksjs="wz" then
					I1=1
					I2=ksjs2
				elseif ksjs="dz" then
					J1=1
					J2=ksjs2
				elseif ksjs="yb" then
					K1=1
					K2=ksjs2
				elseif ksjs="bz" then
					T1=1
					T2=ksjs2
				end if
			end if
			if F2<>"" then
				str_Result2=str_Result2+"and t.name like '%"& F2 &"%'"
'if F2<>"" then
			end if
			if S2<>"" then
				str_Result2=str_Result2+"and t.pym like '%"& S2 &"%'"
'if S2<>"" then
			end if
			if Y2<>"" then
				str_Result2=str_Result2+"and t.khid like '%"& Y2 &"%'"
'if Y2<>"" then
			end if
			if G2<>"" then
				str_Result2=str_Result2+"and t.phone like '%"& G2 &"%'"
'if G2<>"" then
			end if
			if P2<>"" then
				str_Result2=str_Result2+"and t.fax like '%"& P2 &"%'"
'if P2<>"" then
			end if
			if I2<>"" then
				str_Result2=str_Result2+"and t.url like '%"& I2 &"%'"
'if I2<>"" then
			end if
			if J2<>"" then
				str_Result2=str_Result2+"and t.address like '%"& J2 &"%'"
'if J2<>"" then
			end if
			if K2<>"" then
				str_Result2=str_Result2+"and t.zip like '%"& K2 &"%'"
'if K2<>"" then
			end if
			if T2<>"" then
				str_Result2=str_Result2+"and t.intro like '%"& T2 &"%'"
'if T2<>"" then
			end if
			if m1<>"" then
				Str_Result2=Str_Result2+"and t.date1>='"&m1&"'"
'if m1<>"" then
				Str_Result_ht=Str_Result_ht+" and c.date1>='"&m1&"' "
'if m1<>"" then
				Str_Result_fy=Str_Result_fy+"and p.date1>='"&m1&"'"
'if m1<>"" then
				Str_Result_cp=Str_Result_cp+"and ko.contract in (select ord from contract where date3>='"&m1&"' and del=1 and isnull(status,-1) in (-1,1))"
'if m1<>"" then
			end if
			if m2<>"" then
				Str_Result2=Str_Result2+"and t.date1<='"&m2&" 23:59:59'"
'if m2<>"" then
				Str_Result_ht=Str_Result_ht+" and c.date1<='"&m2&" 23:59:59' "
'if m2<>"" then
				Str_Result_fy=Str_Result_fy+"and p.date1<='"&m2&" 23:59:59'"
'if m2<>"" then
				Str_Result_cp=Str_Result_cp+"and ko.contract in (select ord from contract where date3<='"&m2&" 23:59:59' and del=1 and isnull(status,-1) in (-1,1))"
'if m2<>"" then
			end if
			if open_1_10=3 then
			elseif open_1_10=1 then
				Str_Result2=Str_Result2+" and t.cateid<>0 and t.cateid in ("&intro_1_10&") "
'elseif open_1_10=1 then
			else
				Str_Result2=Str_Result2+" and 1=2 "
'elseif open_1_10=1 then
			end if
			if open_5_1=3 then
'elseif open_5_1=1 then
				Str_Result_ht=Str_Result_ht+" and c.cateid<>0 and c.cateid in ("&intro_5_1&") "
'elseif open_5_1=1 then
			else
				Str_Result_ht=Str_Result_ht+" and 1=2 "
'elseif open_5_1=1 then
			end if
			if open_6_1=3 then
			elseif open_6_1=1 then
				Str_Result_fy=Str_Result_fy+" and p.cateid<>0 and p.cateid in ("&intro_6_1&") "
'elseif open_6_1=1 then
			else
				Str_Result_fy=Str_Result_fy+" and 1=2 "
'elseif open_6_1=1 then
			end if
			set rs=server.CreateObject("adodb.recordset")
			sql="" &_
			"select b.ord,t.khid,t.name,t.cateid,g.name cateidname,(case when gz=0 then 0 else (lz/gz)*100 end) as num1,(lz) as money1," & vbcrlf &_
			"cb as money2,fz as money3,gz as money4," & vbcrlf &_
			"tz as 退货总额,numht as num2 from(" & vbcrlf &_
			"select ord,sum(gz-cb-fz) as lz,sum(cb) as cb,sum(fz) as fz,sum(gz) as gz,sum(tz) as tz,sum(numht) as numht from (" & vbcrlf &_
			"tz as 退货总额,numht as num2 from(" & vbcrlf &_
			"select t.ord,0 as cb,0 as fz,isnull(sum(c.money2),0) as gz,0 as tz,count(c.ord) as numht " & vbcrlf &_
			"from tel t WITH(NOLOCK) " & vbcrlf &_
			"inner join contract c WITH(NOLOCK) on t.ord=c.company and c.del=1 and isnull(c.status,-1) in (-1,1) "&Str_Result_ht&" "&Str_Result2 & " " & vbcrlf &_
			"from tel t WITH(NOLOCK) " & vbcrlf &_
			"group by t.ord " & vbcrlf &_
			"union all " & vbcrlf &_
			"select t.ord,sum(isnull(isnull(ku.price1,0)*isnull(ko.num1,0),0)) as cb,0 as fz,0 as gz,0 as tz,0 as numht " & vbcrlf &_
			"from tel t WITH(NOLOCK) " & vbcrlf &_
			"inner join contract c WITH(NOLOCK) on t.ord=c.company and c.del=1 and isnull(c.status,-1) in (-1,1) " & Str_Result_ht & " " & vbcrlf &_
			"from tel t WITH(NOLOCK) " & vbcrlf &_
			"left join kuoutlist2 ko WITH(NOLOCK) on t.ord=ko.company and ko.contract=c.ord and ko.del=1 " & vbcrlf &_
			"and (ko.sort1=1 or ko.sort1=4) " & Str_Result_cp&" " & vbcrlf &_
			"left join ku WITH(NOLOCK) on ko.ku=ku.id " & vbcrlf &_
			""&Str_Result2 & "" & vbcrlf &_
			"group by t.ord"  & vbcrlf &_
			"union all " & vbcrlf &_
			"select t.ord,0 as cb,0 as fz,0 as gz,sum(isnull(ki.money1,0)) as tz,0 as numht " & vbcrlf &_
			"from tel t WITH(NOLOCK) " & vbcrlf &_
			"inner join contract c WITH(NOLOCK) on t.ord=c.company and c.del=1 and isnull(c.status,-1) in (-1,1) "&Str_Result_ht&" " & vbcrlf &_
			"from tel t WITH(NOLOCK) " & vbcrlf &_
			"left join kuinlist ki WITH(NOLOCK) on t.ord=ki.company and ki.sort1=2 "&Str_Result2&" " & vbcrlf &_
			"group by t.ord " & vbcrlf &_
			"union all " & vbcrlf &_
			"select t.ord,0 as cb,sum(isnull(p.money1,0)) as fz,0 as gz,0 as tz,0 as numht " & vbcrlf &_
			"from tel t WITH(NOLOCK) " & vbcrlf &_
			"left join pay p WITH(NOLOCK) on t.ord=p.company and  p.del=1 and p.complete=3 " & Str_Result_fy & " " & Str_Result2 & " " & vbcrlf &_
			"group by t.ord " & vbcrlf &_
			") a " & vbcrlf &_
			"group by a.ord " & vbcrlf &_
			") b " & vbcrlf &_
			"inner join tel t on t.ord=b.ord " & vbcrlf &_
			"left join gate g on g.ord=t.cateid " & vbcrlf &_
			"order by (case when gz=0 then 0 else (lz/gz)*100 end) desc,gz desc,t.ord desc"
			rs.open sql,conn,1,1
			C1=rs.recordcount
			xlApplication.Init "客户利润率排行_"&session("name2006chen")&".xls",C1
			dim i
			i=1
			do until rs.eof
				ord=rs("ord")
				money_mlall=zbcdbl(rs("money1"))
				money_ll=zbcdbl(rs("num1"))
				money_cpall=zbcdbl(rs("money2"))
				pay=zbcdbl(rs("money3"))
				money1=zbcdbl(rs("money4"))
				numht=zbcdbl(rs("num2"))
				k = rs("name")
				khid=rs("khid")
				cateid=rs("cateid")
				cateidname=rs("cateidname")
				xlWorksheet.Cells(1+i,1).Value = k
				cateidname=rs("cateidname")
				xlWorksheet.Cells(1+i,1).font.Size=10
				cateidname=rs("cateidname")
				xlWorksheet.Cells(1+i,2).Value = khid
				cateidname=rs("cateidname")
				xlWorksheet.Cells(1+i,2).font.Size=10
				cateidname=rs("cateidname")
				if open_5_17=1 or open_5_17=3 then
					xlWorksheet.Cells(1+i,3).Value =Formatnumber(money_ll,num_dot_xs,-1)&"%"
'if open_5_17=1 or open_5_17=3 then
					xlWorksheet.Cells(1+i,3).font.Size=10
'if open_5_17=1 or open_5_17=3 then
					xlWorksheet.Cells(1+i,4).Value =Formatnumber(money_mlall,num_dot_xs,-1)
'if open_5_17=1 or open_5_17=3 then
					xlWorksheet.Cells(1+i,4).font.Size=10
'if open_5_17=1 or open_5_17=3 then
					xlWorksheet.Cells(1+i,5).Value =Formatnumber(money_cpall,num_dot_xs,-1)
'if open_5_17=1 or open_5_17=3 then
					xlWorksheet.Cells(1+i,5).font.Size=10
'if open_5_17=1 or open_5_17=3 then
				end if
				xlWorksheet.Cells(1+i,6).Value =Formatnumber(pay,num_dot_xs,-1)
'if open_5_17=1 or open_5_17=3 then
				xlWorksheet.Cells(1+i,6).font.Size=10
'if open_5_17=1 or open_5_17=3 then
				xlWorksheet.Cells(1+i,7).Value =Formatnumber(money1,num_dot_xs,-1)
'if open_5_17=1 or open_5_17=3 then
				xlWorksheet.Cells(1+i,7).font.Size=10
'if open_5_17=1 or open_5_17=3 then
				xlWorksheet.Cells(1+i,8).Value =numht
'if open_5_17=1 or open_5_17=3 then
				xlWorksheet.Cells(1+i,8).font.Size=10
'if open_5_17=1 or open_5_17=3 then
				xlWorksheet.Cells(1+i,9).Value = cateidname
'if open_5_17=1 or open_5_17=3 then
				xlWorksheet.Cells(1+i,9).font.Size=10
'if open_5_17=1 or open_5_17=3 then
				Call ClientClosedExit
				Response.Flush
				i=i+1
				Response.Flush
				rs.movenext
			loop
			rs.close
			set rs=Nothing
			Response.write "<script>CountImage.width=710;CountTXT.innerHTML=""<font color=red><b>客户利润率排行导出全部完成!</b></font>  100"";CountTXTok.innerHTML=""<B>恭喜!客户利润率排行导出成功,共有"&(i-1)&"条记录!</B>"";</script>"
			set rs=Nothing
			Response.write "" & vbcrlf & "</BODY>" & vbcrlf & "</HTML>" & vbcrlf & ""
			Set fs = CreateObject("Scripting.FileSystemObject")
			tfile=Server.MapPath("客户利润率排行_"&session("name2006chen")&".xls")
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
			action1="客户资料导出"
			call close_list(1)
			Response.write "" & vbcrlf & "<p align=""center""><a href=""downfile.asp?fileSpec="
			Response.write tfile
			Response.write """><font class=""red""><strong><u>下载导出的客户利润率排行</u></strong></font></a></p>"
			
%>
