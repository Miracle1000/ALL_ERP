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
	
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open from power  where ord="&session("personzbintel2007")&" and sort1=23 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_23_3=0
	else
		open_23_3=rs1("qx_open")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=31 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_31_11=0
		intro_31_11=0
	else
		open_31_11=rs1("qx_open")
		intro_31_11=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=31 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_31_7=0
		intro_31_7=0
	else
		open_31_7=rs1("qx_open")
		intro_31_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=31 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_31_10=0
		intro_31_10=0
	else
		open_31_10=rs1("qx_open")
		intro_31_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=31 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_31_1=0
		intro_31_1=0
	else
		open_31_1=rs1("qx_open")
		intro_31_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
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
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_1=0
	else
		open_21_1=rs1("qx_open")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_14=0
	else
		open_21_14=rs1("qx_open")
	end if
	rs1.close
	set rs1=nothing
	
	Function KuinSortTypeSource
		Dim source : source = ""
		if ZBRuntime.MC(15000) Then source = "采购入库=1;"
		if ZBRuntime.MC(8000) Then source = source & "退货入库=2;"
		if ZBRuntime.MC(18620) Then source = source & "退料入库=3;废料入库=16;"
		source = source & "直接入库=4;"
		source = source & "拆分入库=10;"
		if ZBRuntime.MC(18000) Then source = source & "成品入库=5;"
		if ZBRuntime.MC(17006) Then source = source & "还货入库=6;"
		if ZBRuntime.MC(17004) Then source = source & "调拨入库=7;"
		if ZBRuntime.MC(17005) Then source = source & "盘点入库=8;"
		if ZBRuntime.MC(17007) Then source = source & "组装入库=9;"
		source = source & "导入入库=11;"
		if ZBRuntime.MC(18000) Then source = source & "半成品入库=13;成品报废入库=14;半成品报废入库=15;"
		source = source &"||"
		KuinSortTypeSource = Replace(source,";||","")
	end function
	function ConvertToSerialNumber(cn , KuinID)
		dim rs:set rs = cn.execute("select 1 from kuinlist kl inner join ku k on k.kuinlist = kl.id where kl.kuin=" & KuinID &" and len(k.xlh)>0 ")
		if rs.eof=false then
			cn.execute("exec [erp_store_KuXlhConvertToRelation] " & KuinID)
		end if
		rs.close
	end function
	function ShowSerialNumberKuinlist(cn ,kuinID, isKu)
		dim msql
		if isKu then msql = " and  exists(select 1 from S2_SerialNumberRelation where del=1 and serialid=s.serialid group by billType having sum(case billType when 61001 then 1 else 0 end) -  sum(case billType when 62001 then 1 else 0 end)>0 ) "
'dim msql
		msql ="select kl.id,kl.kuin,kl.num1 ,replace(cast(kl.xlh as nvarchar(max)),'~@@@@@@@@@@~','''') xlh, ml.seriNum , (select count(1) from S2_SerialNumberRelation where BillType=61001 and listID= kl.id) as cnt "&_
		" from kuinlist kl "&_
		" left join S2_SerialNumberRelation s on s.BillType=61001 and s.listID=kl.id " & msql &_
		" left join M2_SerialNumberList ml on ml.id = s.SerialID "&_
		" where kl.kuin=" & kuinID
		set ShowSerialNumberKuinlist = cn.execute(msql)
	end function
	function CurrShowSerialNumber(rs, kuinlistID , mpath , oxlh)
		dim kuinID , s : s =""
		if rs.eof=false then
			kuinID = rs("kuin").value&""
			s = rs("seriNum").value&""
			if rs("num1").value<>"1" and len(oxlh)>0 then
				s = oxlh
			elseif s="" then
				s = replace(rs("xlh").value&"" , chr(1),",")
			elseif rs("cnt").value >1 then
				s = s & "<img style='cursor:pointer;width:10px;height:20px' src='"& mpath &"SYSN/skin/default/img/percent100.png' onclick='ShowSerialNumber(this,61001 , "& kuinID &","& kuinlistID &" )'><div id='w"&kuinlistID&"'></div>"
			end if
		end if
		CurrShowSerialNumber = s
	end function
	function ShowSerialNumber(cn ,kuinID, kuinlistID , mpath , isKu , oxlh)
		dim rs,s , msql : s =""
		if isKu then msql = " and  exists(select 1 from S2_SerialNumberRelation where del=1 and serialid=s.serialid group by billType having sum(case billType when 61001 then 1 else 0 end) -  sum(case billType when 62001 then 1 else 0 end)>0 ) "
'dim rs,s , msql : s =""
		msql ="select kl.id,kl.kuin,kl.num1 ,replace(cast(kl.xlh as nvarchar(max)),'~@@@@@@@@@@~','''') xlh, ml.seriNum "&_
		" from kuinlist kl "&_
		" left join S2_SerialNumberRelation s on s.BillType=61001 and s.listID=kl.id " & msql &_
		" left join M2_SerialNumberList ml on ml.id = s.SerialID "&_
		" where kl.kuin=" & kuinID &" and kl.id = " & kuinlistID
		set rs = cn.execute(msql)
		if rs.eof=false then
			kuinID = rs("kuin").value&""
			s = rs("seriNum").value&""
			if rs("num1").value<>"1" and len(oxlh)>0 then
				s = oxlh
			elseif s="" then
				s = replace(rs("xlh").value&"" , chr(1),",")
			elseif cn.execute("select count(1) from S2_SerialNumberRelation where BillType=61001 and listID= " & kuinlistID)(0)>1 then
				s = s & "<img style='cursor:pointer;width:10px;height:20px' src='"& mpath &"SYSN/skin/default/img/percent100.png' onclick='ShowSerialNumber(this,61001 , "& kuinID &","& kuinlistID &" )'><div id='w"&kuinlistID&"'></div>"
			end if
		end if
		rs.close
		ShowSerialNumber = s
	end function
	function DataSerialNumber(cn ,kuinID, kuinlistID)
		dim rs,s , msql : s =""
		msql ="select kl.id,kl.kuin ,replace(cast(kl.xlh as nvarchar(max)),'~@@@@@@@@@@~','''') xlh, ml.seriNum "&_
		" from kuinlist kl "&_
		" left join S2_SerialNumberRelation s on s.BillType=61001 and s.listID=kl.id " &_
		" left join M2_SerialNumberList ml on ml.id = s.SerialID "&_
		" where kl.kuin=" & kuinID &" and kl.id = " & kuinlistID
		set rs = cn.execute(msql)
		if rs.eof=false then
			kuinID = rs("kuin").value&""
			s = rs("seriNum").value&""
			if s="" then
				s = rs("xlh").value&""
			elseif cn.execute("select count(1) from S2_SerialNumberRelation where BillType=61001 and listID= " & kuinlistID)(0)>1 then
				s = ""
				while rs.eof=false
					if len(s)>0 then s =  s &","
					s =  s & rs("seriNum").value&""
					rs.movenext
				wend
			end if
		end if
		rs.close
		DataSerialNumber = s
	end function
	function KuoutDataSerialNumber(cn ,kuoutID, kuoutlist2ID)
		dim rs,s , msql : s =""
		msql ="select kl.id,kl.kuout ,replace(cast(kl.xlh as nvarchar(max)),'~@@@@@@@@@@~','''') xlh, ml.seriNum "&_
		" from kuoutlist2 kl "&_
		" left join S2_SerialNumberRelation s on s.BillType=62001 and s.listID=kl.id " &_
		" left join M2_SerialNumberList ml on ml.id = s.SerialID "&_
		" where kl.kuout=" & kuoutID &" and kl.id = " & kuoutlist2ID
		set rs = cn.execute(msql)
		if rs.eof=false then
			s = rs("seriNum").value&""
			if s="" then
				s = rs("xlh").value&""
			elseif cn.execute("select count(1) from S2_SerialNumberRelation where BillType=62001 and listID= " & kuoutlist2ID)(0)>1 then
				s = ""
				while rs.eof=false
					if len(s)>0 then s =  s &","
					s =  s & rs("seriNum").value&""
					rs.movenext
				wend
			end if
		end if
		rs.close
		KuoutDataSerialNumber = s
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
	
	dim CurrProductAttrsHandler
	Function isOpenProductAttr
		isOpenProductAttr = (ZBRuntime.MC(213104) and conn.execute("select nvalue from home_usConfig where name='ProductAttributeTactics' and nvalue=1 ").eof=false)
	end function
	function IsApplyProductAttr(ord, AttrID)
		dim SearchText: SearchText = "(ProductAttr1>0 or ProductAttr2>0)"
		if AttrID > 0 then SearchText = "(ProductAttr1="& AttrID & " or ProductAttr2="& AttrID & ")"
		dim cmdtext
		cmdtext = "select top 1 1 x from contractlist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from kuoutlist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from kuoutlist2 where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from kuinlist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from contractthlist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from kumovelist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from caigoulist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from ku where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from bomlist where " & SearchText & " and (Product=" & ord & " or "& ord &" = 0) " &_
		"     union all   "&_
		"     select top 1 1 from bom where " & SearchText & " and (Product=" & ord & " or "& ord &" = 0) " &_
		"     union all   "&_
		"     select top 1 1 from BOM_Structure_List where " & SearchText & " and (ProOrd=" & ord & " or "& ord &" = 0) "
		IsApplyProductAttr =  (conn.execute(cmdtext).eof=false)
	end function
	function ProductAttrsCmdText(ord , loadmodel)
		dim CmdText, cmdwhere
		if loadmodel = "by_fields" then cmdwhere = " and st.pid = 0 "
		if loadmodel = "by_config" then cmdwhere = " and st.isstop = 0 "
		CmdText = "select 1 from product p  with(nolock) inner join menu m  with(nolock) on m.id = p.sort1 inner join Shop_GoodsAttr st  with(nolock) on st.proCategory = m.RootId and st.pid = 0 where p.ord = " & ord
		if conn.execute(CmdText).eof=false then
			CmdText = "select st.id ,st.pid ,st.title , st.sort ,st.isstop,  isnull(st.isTiled,0)isTiled "&_
			"   from product p  with(nolock)  "&_
			"   inner join menu m  with(nolock) on m.id = p.sort1 "&_
			"   inner join Shop_GoodsAttr st  with(nolock) on st.proCategory = m.RootId " & cmdwhere &"   "&_
			"   where p.ord = " & ord &" "&_
			"   order by st.isTiled desc,st.pid ,st.sort desc , st.id desc"
		else
			CmdText ="select st.id ,st.pid , st.title , st.sort ,st.isstop, isnull(st.isTiled,0)isTiled "&_
			"   from Shop_GoodsAttr st  with(nolock) "&_
			"   where st.proCategory = -1 "& cmdwhere &" "&_
			"   from Shop_GoodsAttr st  with(nolock) "&_
			"   order by st.isTiled desc,st.pid ,st.sort desc , st.id desc"
		end if
		ProductAttrsCmdText = CmdText
	end function
	function ProductAttrsByOrd(ord)
		dim attrs , CmdText
		CmdText = ProductAttrsCmdText(ord , "by_fields")
		set ProductAttrsByOrd = conn.execute(CmdText)
	end function
	Function GetProductAttr1Title(ord)
		Dim attrs ,s : s= "产品属性1"
		set attrs =ProductAttrsByOrd(ord)
		while attrs.eof=false
			if attrs("isTiled").value=1 then s = attrs("title").value
			attrs.movenext
		wend
		attrs.close
		GetProductAttr1Title = s
	end function
	Function GetProductAttr2Title(ord)
		Dim attrs ,s : s= "产品属性2"
		set attrs =ProductAttrsByOrd(ord)
		while attrs.eof=false
			if attrs("isTiled").value&""<>"1" then s = attrs("title").value
			attrs.movenext
		wend
		attrs.close
		GetProductAttr2Title = s
	end function
	function GetProductAttrNameById(productAttrId)
		if productAttrId<>"" and productAttrId<>"0" then
			dim rs7
			set rs7=server.CreateObject("adodb.recordset")
			sql7="select title from Shop_GoodsAttr where id="&productAttrId&""
			rs7.open sql7,conn,1,1
			if rs7.eof then
				GetProductAttrNameById=""
			else
				GetProductAttrNameById=rs7("title")
			end if
			rs7.close
			set rs7=nothing
		else
			GetProductAttrNameById=""
		end if
	end function
	function GetProductAttrOption(ord,isTiled)
		dim rs7 , hasAttr
		hasAttr = false
		set rs7 = ProductAttrsByOrd(ord)
		while rs7.eof=false
			if rs7("isTiled").value &""= isTiled&"" then
				set GetProductAttrOption = conn.execute(" select title,id from (select '' as title, 0 as id,999999 sort union all select title, id ,sort from Shop_GoodsAttr where isstop = 0 and pid = "&rs7("id").value  &") a order by  sort desc , id desc ")
				hasAttr = true
			end if
			rs7.movenext
		wend
		rs7.close
		if hasAttr=false then set GetProductAttrOption = conn.execute("select top  0 '' title , 0 id ")
	end function
	class ProductAttrCellClass
		public Attr1
		public Num
		public BillListId
		Public ParentListId
		public  function  GetJSON
			GetJSON = "{num:" &  Num & ",billistid:" & BillListId & ",attr1:" &  clng("0" & Attr1) & ",parentbilllistid:" & ParentListId & "}"
		end function
		public  sub  SetJson(byval  json)
			dim i, ks
			dim s : s = mid(json,2, len(json)-2)
'dim i, ks
			dim items :  items =  split(s, ",")
			for i = 0 to  ubound(items)
				ks = split(items(i), ":")
				select case ks(0)
				case "attr1" :   Attr1 = clng("0" & ks(1))
				case "num" :   Num = cdbl(ks(1))
				case "billistid" :   me.BillListId = clng(ks(1))
				case "parentbilllistid" :
				If ks(1)&"" = "" Then me.ParentListId = 0 Else me.ParentListId = CDBL(ks(1))
				end select
			next
			if err.number<>0 then
				Response.write "【" & json & "|" &  ubound(items) & "|"  & BillListId& "】"
			end if
		end sub
	end class
	class ProductAttrConfigCollection
		public id
		public title
		public options
		public sub Class_Initialize
			options = split("",",")
		end sub
		public sub Addtem(byval title,  byval id,  byval istop)
			dim c: c =ubound(options) + 1
'public sub Addtem(byval title,  byval id,  byval istop)
			redim preserve  options(c)
			options(c) = split( id & chr(1) & title & chr(1) & istop,   chr(1))
			options(c)(0) = clng( options(c)(0) )
			options(c)(2) = clng( "0" & options(c)(2) )
		end sub
		public sub RemoveAt(index)
			dim         j , i, c
			j = -1
'dim         j , i, c
			c = UBound(options)
			For i = 0 To c
				If i <> index Then
					j = j + 1
'If i <> index Then
					options(j) =options(i)
				end if
			next
			if j >=0 then
				redim preserve options(j)
			else
				options = split("",",")
			end if
		end sub
	end class
	class ProductAttrCellCollection
		public Cells
		public Attr2
		public SumNum
		public BatchId
		public Attr1Configs
		public Attr2Configs
		private currrs
		public  LoadModel
		public MxpxId
		public OldListData
		private isOpened
		private currlistrs
		public  StrongInherit
		public sub Class_Initialize
			set Attr1Configs =  nothing
			set Attr2Configs =  nothing
			LoadModel = "by_config"
			Cells = split("",",")
			isOpened = true
			StrongInherit = false
			set currlistrs = nothing
		end sub
		public function InitByNoOpened (byref rs)
			isOpened = false
			set currlistrs= rs
		end function
		public function Items(byval itemname)
			dim i, ns
			if isOpened = false then
				on error resume next
				if  not currlistrs is nothing then
					Items = currlistrs(itemname).value
				end if
				exit function
			end if
			if isarray(OldListData) then
				for i = 0 to ubound(OldListData)
					ns = split(OldListData(i), chr(1))
					if lcase(ns(0)) = lcase(itemname) then
						Items = ns(1)
						exit function
					end if
				next
			end if
			Items = ""
		end function
		public sub Bind(byval rs)
			SumNum =   0
			BatchId = rs("ProductAttrBatchId").value
			Attr2 = clng("0" & rs("ProductAttr2").value)
			Cells = split("",",")
			set currrs =  rs
		end sub
		public sub AddCell(ByRef listid,ByRef attr1Id, ByRef numv, ByRef parentlistid)
			dim obj
			set obj = new ProductAttrCellClass
			numv = cdbl(numv & "")
			obj.BillListId =  listid
			obj.ParentListId =  parentlistid
			obj.Num =  numv
			obj.Attr1 =  attr1Id
			SumNum = SumNum + numv
'obj.Attr1 =  attr1Id
			dim c : c =ubound(cells) + 1
'obj.Attr1 =  attr1Id
			redim preserve cells(c)
			set  cells(c) =  obj
			call  Update
		end sub
		public  function  GetJSON
			dim json, c,  i
			json = "{batchid:" & BatchId & "," &_
			"attr2:" & Attr2 & "," &_
			"sumnum:" & sumnum & "," &_
			"cells:["
			c = ubound(cells)
			for i = 0 to c
				if i>0 then json = json & ","
				json = json  & cells(i).GetJson
			next
			json = json & "]"
			GetJSON = json
		end function
		public  function  LoadJSON (byval jsondata)
			dim s : s = split(jsondata,  ",cells:")
			dim baseinfo:  baseinfo = mid(s(0), 2,  len(s(0))-1)
'dim s : s = split(jsondata,  ",cells:")
			dim cellsinfo :  cellsinfo = mid(s(1), 2,  len(s(1))-2)
'dim s : s = split(jsondata,  ",cells:")
			dim i, bi,  bs :  bs = split(baseinfo, ",")
			for i = 0 to ubound(bs)
				bi = split(bs(i), ":")
				select case bi(0)
				case "attr2" :  attr2 =  clng("0" & bi(1))
				case "batchid" :  batchid =  clng("0" & bi(1))
				case "sumnum" :  sumnum =  cdbl(bi(1))
				end select
			next
			dim cellsinfos :  cellsinfos = split(cellsinfo, "},{")
			dim  c : c = ubound(cellsinfos)
			if c = -1 then
'dim  c : c = ubound(cellsinfos)
				cells =  split("",",")
			else
				dim cjson
				redim cells(c)
				for i = 0 to c
					cjson = cellsinfos(i)
					if i <> 0 then  cjson = "{" & cjson
					if i <> c  then cjson =  cjson & "}"
					set cells(i) = new ProductAttrCellClass
					cells(i).SetJson cjson
				next
			end if
		end function
		private  sub Update
			currrs("ProductAttrsJson").value  = GetJSON()
			currrs.update
		end sub
		public sub  DelNullDataConfig
			dim i, ii,  exists
			if Attr2 =0 then set Attr2Configs =  nothing
			if not Attr1Configs is nothing then
				for i = ubound(Attr1Configs.options) to 0 step -1
'if not Attr1Configs is nothing then
					exists = false
					for ii = 0 to ubound(Cells)
						if Cells(ii).Attr1  =  Attr1Configs.options(i)(0) then
							exists  = true :  exit for
						end if
					next
					if exists = false then
						Attr1Configs.RemoveAt(i)
					end if
				next
				if ubound(Attr1Configs.options) = - 1 then  set Attr1Configs =  nothing
				Attr1Configs.RemoveAt(i)
			end if
			if not Attr2Configs is nothing then
				for i = ubound(Attr2Configs.options) to 0 step -1
'if not Attr2Configs is nothing then
					exists = false
					for ii = 0 to ubound(Cells)
						if attr2  =  Attr2Configs.options(i)(0) then
							exists  = true :  exit for
						end if
					next
					if exists = false and Attr2Configs.options(i)(2)=1 then
						Attr2Configs.RemoveAt(i)
					end if
				next
				if ubound(Attr2Configs.options) = - 1 then  set Attr2Configs =  nothing
				Attr2Configs.RemoveAt(i)
			end if
		end sub
		public sub  DelNullDataStopConfig
			dim i, ii,  exists
			if not Attr1Configs is nothing then
				for i = ubound(Attr1Configs.options) to 0 step -1
'if not Attr1Configs is nothing then
					exists = false
					for ii = 0 to ubound(Cells)
						if Cells(ii).Attr1  =  Attr1Configs.options(i)(0) then
							exists  = true :  exit for
						end if
					next
					if exists = false and Attr1Configs.options(i)(2)=1 then
						Attr1Configs.RemoveAt(i)
					end if
				next
				if ubound(Attr1Configs.options) = - 1 then
					Attr1Configs.RemoveAt(i)
					set Attr1Configs =  nothing
				end if
			end if
			if not Attr2Configs is nothing then
				for i = ubound(Attr2Configs.options) to 0 step -1
'if not Attr2Configs is nothing then
					exists = false
					for ii = 0 to ubound(Cells)
						if attr2  =  Attr2Configs.options(i)(0) then
							exists  = true :  exit for
						end if
					next
					if exists = false and Attr2Configs.options(i)(2)=1 then
						Attr2Configs.RemoveAt(i)
					end if
				next
				if ubound(Attr2Configs.options) = - 1 then
					Attr2Configs.RemoveAt(i)
					set Attr2Configs =  nothing
				end if
			end if
		end sub
		public sub AddConfig(byval id, byval pid, byval title, byval istop,  byval isNumAttr)
			if pid = 0 then
				if isNumAttr then
					set Attr1Configs = new  ProductAttrConfigCollection
					Attr1Configs.id = id
					Attr1Configs.title = title
				else
					set Attr2Configs = new  ProductAttrConfigCollection
					Attr2Configs.id = id
					Attr2Configs.title = title
				end if
			else
				if not Attr1Configs is nothing then
					if pid = Attr1Configs.id then
						Attr1Configs.Addtem title,  id,  istop
					else
						Attr2Configs.Addtem title,  id,  istop
					end if
				else
					Attr2Configs.Addtem title,  id,  istop
				end if
			end if
		end sub
		public function GetEachCount()
			if Attr1Configs is nothing then GetEachCount = 0 : exit function
			select case LoadModel
			case "by_data" :  GetEachCount =  ubound(Attr1Configs.options)+1
'select case LoadModel
			case "by_config" :  GetEachCount =  ubound(Attr1Configs.options)+1
'select case LoadModel
			case "by_config_or_data" : GetEachCount =  ubound(Attr1Configs.options)+1
'select case LoadModel
			case else
			err.Raise 1000, 1, "GetEachCount 暂不支持【" & loadmodel & "】模式"
			end select
		end function
		private eachdataindex
		public sub  GetEachData(byval eindex,  byref attr1,  byref numv,  byref  billlistid,  byref mxpx)
			dim i
			eachdataindex = -1
'dim i
			if LoadModel  = "by_config" or  LoadModel  = "by_data" or LoadModel  = "by_config_or_data" then
				attr1 = 0:  numv = "":  billlistid = 0
				if not Attr1Configs is nothing then
					if eindex <= ubound(Attr1Configs.options) then
						attr1 = clng(Attr1Configs.options(eindex)(0))
					end if
				end if
				if attr1>0 then
					for i = 0 to ubound(cells)
						if cells(i).Attr1 = attr1 then
							numv = cells(i).num
							billlistid = cells(i).BillListId
							mxpx = "AttrsBatch_Attr1_" & mxpxid & "_" &  attr1 & "_" &  cells(i).BillListId & "_" &  cells(i).ParentListId
							eachdataindex =  i
							exit sub
						end if
					next
					billlistid = 0
					if ubound(cells) = 0 then
						mxpx = "AttrsBatch_Attr1_" & mxpxid & "_" &  attr1 & "_0_" &  cells(0).ParentListId
					else
						mxpx = "AttrsBatch_Attr1_" & mxpxid & "_" &  attr1 & "_0_0"
					end if
				else
					billlistid =  BatchId
					numv = SumNum
					mxpx = mxpxid
					eachdataindex = -1
'mxpx = mxpxid
				end if
			else
				err.Raise 1000, 1, "GetEachData 暂不支持【" & loadmodel & "】模式"
			end if
		end sub
		public sub SetOldListData(datas)
			if EachDataIndex <0 then
				OldListData = split("",",")
			else
				OldListData = split( split(datas, chr(3))(EachDataIndex), chr(2))
			end if
		end sub
		public function GetEachNumValue(byval eindex)
			select case LoadModel
			case "by_config" :
			dim i,  attrid :  attrid =  Attr1Configs.options(eindex)(0)
			for i = 0 to ubound(cells)
				if cells(i).Attr1 = attrid then
					exit function
				end if
			next
			case else
			err.Raise 1000, 1, "GetEachNumValue 暂不支持【" & loadmodel & "】模式"
			end select
		end function
	end Class
	class ProductAttrsHelperClass
		private CurrNumField
		private CurrPrimaryKeyField
		Private CurrParentPrimaryKeyField
		private CurrJoinnumFields
		private ListRecordset
		private ProductField
		public ForEachIndex
		public EachObject
		private ForEachListId
		private CurrLoadModel
		private CurrEditDispaly
		private IsAddModel
		public StrongInheritModel
		private IsOpened
		private mbit
		public sub Class_Initialize
			ForEachListId = "**"
			CurrLoadModel = "by_config"
			CurrEditDispaly = "editable"
			IsAddModel = false
			BufferModel= false
			StrongInheritModel = false
			IsOpened =  isOpenProductAttr
			set CurrProductAttrsHandler =  me
			mbit= sdk.GetSqlValue("select num1 from setjm3 where ord in (1)",6)
		end sub
		public sub InitAsAddNew(byval  productid,  byval initnum1)
			dim proxyrs  :  set proxyrs = nothing
			if IsOpened then
				set proxyrs = server.CreateObject("adodb.recordset")
				proxyrs.fields.Append  "Attrf_Productid",  3,  4,  120
				proxyrs.fields.Append  "Attrf_Num1",  5,  19,  120
				proxyrs.fields.Append  "Attrf_billlist",  3,  4,  120
				proxyrs.fields.Append  "Attrf_money1",  5,  19,  120
				proxyrs.fields.Append  "ProductAttr1",  3,  4,  120
				proxyrs.fields.Append  "ProductAttr2",  3,  4,  120
				proxyrs.fields.Append  "ProductAttrBatchId",  3,  4,  120
				proxyrs.Open
				proxyrs.AddNew
				proxyrs("Attrf_Productid").Value =  productid
				proxyrs("Attrf_Num1").Value =  cdbl(initnum1)
				proxyrs("Attrf_billlist").Value =  0
				proxyrs("Attrf_money1").Value =  0
				proxyrs.Update
				IsAddModel = true
			end if
			HandleRecordSet proxyrs,  "Attrf_billlist" , "",  "Attrf_Productid",  "Attrf_Num1",  "Attrf_money1"
		end sub
		public sub InitAsAddNewByAttrs(byval  productid,  byval initnum1Str, ByVal ProductAttr1Str, ByVal ProductAttr2, ByVal AttrBatchId, ByVal billListIdStr, ByVal parentListIdStr)
			dim proxyrs  :  set proxyrs = nothing
			dim initnum1, i, arr_cpord, arr_num1, arr_attr1, arr_billListId, arr_parentListId
			if IsOpened then
				set proxyrs = server.CreateObject("adodb.recordset")
				proxyrs.fields.Append  "Attrf_Productid",  3,  4,  120
				proxyrs.fields.Append  "Attrf_Num1",  5,  19,  120
				proxyrs.fields.Append  "Attrf_billlist",  3,  4,  120
				proxyrs.fields.Append  "Attrf_money1",  5,  19,  120
				proxyrs.fields.Append  "ProductAttr1",  3,  4,  120
				proxyrs.fields.Append  "ProductAttr2",  3,  4,  120
				proxyrs.fields.Append  "ProductAttrBatchId",  3,  4,  120
				proxyrs.fields.Append  "parentListId",  3,  4,  120
				proxyrs.Open
				if ProductAttr1Str&"" = "" then
					If parentListIdStr&""="" Then
						parentListIdStr = "0"
					else
						parentListIdStr = split(parentListIdStr&"",",")(0)
					end if
					proxyrs.AddNew
					proxyrs("Attrf_Productid").Value =  productid
					proxyrs("Attrf_Num1").Value =  zbcdbl(initnum1Str)
					proxyrs("ProductAttr2").Value =  ProductAttr2
					proxyrs("ProductAttrBatchId").Value =  AttrBatchId
					proxyrs("Attrf_billlist").Value =  billListIdStr
					proxyrs("Attrf_money1").Value =  0
					proxyrs("parentListId").Value =  parentListIdStr
					proxyrs.Update
				else
					arr_num1 = split(initnum1Str&"",",")
					arr_attr1 = split(ProductAttr1Str&"",",")
					arr_billListId = split(billListIdStr&"",",")
					arr_parentListId = split(parentListIdStr&"",",")
					for i=0 to ubound(arr_num1)
						if arr_num1(i)&""<>"" then
							proxyrs.AddNew
							proxyrs("Attrf_Productid").Value =  productid
							proxyrs("ProductAttr1").Value =  arr_attr1(i)
							proxyrs("Attrf_Num1").Value =  cdbl(arr_num1(i))
							proxyrs("ProductAttr2").Value =  ProductAttr2
							proxyrs("ProductAttrBatchId").Value =  AttrBatchId
							proxyrs("Attrf_billlist").Value =  arr_billListId(i)
							proxyrs("Attrf_money1").Value =  0
							proxyrs("parentListId").Value =  arr_parentListId(i)
							proxyrs.Update
						end if
					next
				end if
				IsAddModel = true
			end if
			HandleRecordSet proxyrs,  "Attrf_billlist" , "parentListId",  "Attrf_Productid",  "Attrf_Num1",  "Attrf_money1"
		end sub
		private function existsRsField(byref rs, byref fieldname)
			dim i, c
			for i = 0 to rs.fields.count - 1
'dim i, c
				set c = rs.fields(i)
				if lcase(c.name) = lcase(fieldname) then
					existsRsField = true
					exit function
				end if
			next
			existsRsField = false
		end function
		public sub HandleRecordSet(byref rs,  byval billlistf,   ByVal parentbilllistf,   byval pfield,   byval numfield,  byval joinnumFields)
			dim i,  ii,  newrs ,  c,  newc,  colhas,  parentlistid, rowindexkey
			dim attrbatchid,  signkeys,  soruce,  ctype
			if IsOpened = false then
				set ListRecordset = rs
				exit sub
			end if
			CurrNumField = numfield
			dim JoinnumField : JoinnumField = numfield
			if len(joinnumFields)>0 then JoinnumField = joinnumFields & "," & numfield
			CurrJoinnumFields  =  split(JoinnumField ,",")
			CurrPrimaryKeyField = billlistf
			CurrParentPrimaryKeyField = parentbilllistf
			ProductField = pfield
			signkeys = split("ProductAttr1,ProductAttr2,ProductAttrBatchId," & numfield & "," & joinnumFields,",")
			soruce = rs.Source
			set  rs.ActiveConnection = nothing
			rs.Sort = "ProductAttrBatchId, " & billlistf
			for ii=0 to ubound(signkeys)
				if len(signkeys(ii))>0 and existsRsField(rs, signkeys(ii)) = false then
					err.Raise 1000,1000, "<div style='color:red;padding:20px;margin:5px 0px;background-color:#ffffaa;font-size:14px;font-family:微软雅黑;line-height:18px'>ProductAttrsClass.HandleRecordSet 转换失败! " &_
					"<br>请确认要处理的明细数据源中是否提供了【 & join(signkeys, 】、【) & 】 列.  <br> 数据源命令：   & soruce & </div>"
				end if
			next
			dim fieldmap : fieldmap = "|"
			set newrs = server.CreateObject("adodb.recordset")
			for i = 0 to rs.fields.count - 1
'set newrs = server.CreateObject("adodb.recordset")
				set c = rs.fields(i)
				if instr(fieldmap, "|" & lcase(c.name) & "|") = 0 then
					newrs.fields.Append c.Name,  c.type,  c.DefinedSize, c.Attributes
					set newc = newrs.Fields(c.Name)
					newc.DataFormat = c.DataFormat
					newc.NumericScale = c.NumericScale
					newc.Precision = c.Precision
					fieldmap=  fieldmap & lcase(c.name) & "|"
				end if
			next
			newrs.fields.Append  "ProductAttrsJson",  202, 4000
			newrs.fields.Append  "ProductAttrsOldDatas",  202, 8000
			newrs.open
			dim  attrs,  PreAttrbatchid :  PreAttrbatchid  = -1
'newrs.open
			while rs.eof = False
				parentlistid = 0
				attrbatchid = clng("0" & rs("ProductAttrBatchId").value)
				If Len(CurrParentPrimaryKeyField) > 0 Then  parentlistid = rs(CurrParentPrimaryKeyField).value
				if PreAttrbatchid = attrbatchid  and  attrbatchid <>0  then
					call attrs.AddCell ( rs(CurrPrimaryKeyField).value ,  rs("ProductAttr1").value ,  rs(numfield).value,  parentlistid)
					call AddNeedSumFields(newrs,  rs)
					call AddOldListFieldDatas(newrs, rs)
				else
					newrs.AddNew
					for i = 0 to rs.fields.count - 1
'newrs.AddNew
						set c = rs.fields(i)
						on error resume next
						newrs.Fields(c.name).Value = c.value
						on error goto 0
					next
					set attrs= new ProductAttrCellCollection
					call attrs.Bind( newrs )
					call attrs.AddCell (rs(CurrPrimaryKeyField).value ,  rs("ProductAttr1").value ,  rs(numfield).value,  parentlistid)
					call AddOldListFieldDatas(newrs, rs)
					PreAttrbatchid = attrbatchid
				end if
				rs.movenext
			wend
			rs.close
			set rs = newrs
			if  existsRsField(rs, "rowindex") then
				rs.sort = "rowindex," &  billlistf
			else
				rs.sort =  billlistf
			end if
			if rs.eof = false then rs.movefirst
			set ListRecordset = rs
		end sub
		private sub AddNeedSumFields(byval newrs,  byval oldrs)
			dim i,  f,  newv, oldv
			for i = 0 to ubound(CurrJoinnumFields)
				f = CurrJoinnumFields(i)
				oldv =  oldrs(f).Value :  if len(oldv & "") = 0 then oldv = 0
				newv =  newrs(f).Value :  if len(newv & "") = 0 then newv = 0
				newrs(f).Value = cdbl(oldv) + cdbl(newv)
'newv =  newrs(f).Value :  if len(newv & "") = 0 then newv = 0
				newrs.Update
			next
		end sub
		public sub  AddOldListFieldDatas(byval newrs, byval oldrs)
			dim i,  n, v,  attrs,  itemc
			attrs =newrs("ProductAttrsOldDatas").Value & ""
			itemc = ""
			for i = 0 to oldrs.fields.count - 1
'itemc = ""
				v =  oldrs(i).value & ""
				if len(v)>0 and isnumeric(v) then
					if len(itemc) > 0 then  itemc =  itemc & chr(2)
					itemc =  itemc & oldrs(i).name & chr(1) & v
				end if
			next
			if len(attrs) > 0 then attrs = attrs & chr(3)
			attrs = attrs & itemc
			newrs("ProductAttrsOldDatas").Value  =  attrs
		end sub
		public function GetForEachAttrObject (byval json ,  byval  productid,  byval loadmodel)
			dim i,  existsids,  attrobj, rs,  onlynostop
			set attrobj = new  ProductAttrCellCollection
			attrobj.loadmodel = loadmodel
			attrobj.LoadJSON  json
			dim  sql : sql = ProductAttrsCmdText(productid , loadmodel)
			set rs = conn.execute(sql)
			dim existspid : existspid =  false
			while rs.eof = false
				if existspid = false then existspid =  clng("0" &  rs("pid").value)
				attrobj.AddConfig  rs("id").value ,   rs("pid").value,  rs("title").value,  rs("isstop").value,  (rs("isTiled").value & "")="1"
				rs.movenext
			wend
			rs.close
			set rs =  nothing
			attrobj.StrongInherit =   (StrongInheritModel=true and  existspid )
			if loadmodel = "by_data"  or  attrobj.StrongInherit  then
				attrobj.DelNullDataConfig
			elseif loadmodel = "by_config_or_data" then
				attrobj.DelNullDataStopConfig
			end if
			set GetForEachAttrObject = attrobj
		end function
		private function GetExistsDataIdsSql(attrobj)
			dim i
			dim attr2id : attr2id = attrobj.Attr2
			dim attr2parentids :   attr2parentids =  "0"
			if attr2id>0 then attr2parentids = attr2id & "," & conn.execute("select pid  from Shop_GoodsAttr where id=" & attr2id).value
			dim attrs1ids :  attrs1ids = "0"
			for i = 0 to ubound(attrobj.Cells)
				attrs1ids = attrs1ids
			next
		end function
		public sub SetLoadModel(byval loadmodel, byval display)
			loadmodel = lcase(loadmodel)
			if loadmodel <> "by_config" and  loadmodel <> "by_data" and loadmodel<>"by_config_or_data" then
				err.Raise 1000,1000, "产品属性 loadmodel参数只支持：  by_config（仅按配置加区域）  by_data (仅按数据加载区域) 和  by_config_or_data（按配置和数据加载区域，取并集）"
			end if
			if display <> "editable" and  display <> "readonly"  then
				err.Raise 1000,1000, "产品属性display 参数只支持：  editable（编辑模式）  readonly (只读模式) "
			end if
			CurrLoadModel = loadmodel
			CurrEditDispaly= display
		end sub
		public BufferModel
		public BuffterModelHtml
		public function WriteHtml(byval html)
			response_Write html
		end function
		public function getBufferHtml()
			getBufferHtml = BuffterModelHtml
			BuffterModelHtml = ""
		end function
		private currnumtext
		public function ForEach(byref mxid, byref billistid ,  byref  attr1id, byref  attr2id,  byref num1, byref  inputattrs)
			if ForEachIndex = -100 then
				inputattrs = ""
				attr1id = 0  :  attr2id = 0
				ForEachIndex=0 :  ForEach = false
				exit function
			end if
			if IsOpened = false then
				set EachObject = new ProductAttrCellCollection
				EachObject.InitByNoOpened ListRecordset
				attr1id = 0  :  attr2id = 0
				ForEachIndex=-100  :  ForEach = true
'attr1id = 0  :  attr2id = 0
				exit function
			end if
			dim rs : set rs = ListRecordset
			if ForEachListId <>  rs(CurrPrimaryKeyField).value then
				ForEachIndex = 0
				ForEachListId = rs(CurrPrimaryKeyField).value
				set EachObject = GetForEachAttrObject( rs("ProductAttrsJson").value,  rs(ProductField).value ,  CurrLoadModel)
				EachObject.MxpxId = mxid
				if  EachObject.Attr1Configs is nothing  and   EachObject.Attr2Configs is nothing  then
					ForEachIndex = - 100
'if  EachObject.Attr1Configs is nothing  and   EachObject.Attr2Configs is nothing  then
					set EachObject = nothing
					ForEach = true
					exit function
				else
					if (EachObject.batchid & "") = ""  or  (EachObject.batchid & "")  = "0" then
						EachObject.batchid =  ForEachListId
					end if
				end if
			else
				ForEachIndex = ForEachIndex + 1
				EachObject.batchid =  ForEachListId
			end if
			if ForEachIndex = 0 then
				currnumtext = ""
				CStartAttrTableHtml  loadmodel
			end if
			if  ForEachIndex > EachObject.GetEachCount() then
				CEndAttrTableHtml
				ForEach = false
			else
				call EachObject.GetEachData( ForEachIndex,   attr1id,   num1,    billistid,  mxid)
				call EachObject.SetOldListData (rs("ProductAttrsOldDatas").value)
				attr2id = EachObject.attr2
				inputattrs = GetNewInputHtmlAttrs(mxid)
				CItemAttrTableHtml mxid
				currnumtext = currnumtext & num1
				ForEach = true
			end if
		end function
		public RowIndexTick
		public sub UpdateFieldValue(byval  rs,   byval mxid)
			dim v1, v2, v3
			v1= request.Form("AttrsBatch_Attr1_" & mxid)
			v2 = request.Form("AttrsBatch_Attr2_" & mxid)
			v3 = request.Form("AttrsBatch_BatchId_" & mxid)
			if len(v1 & "")=0 then v1 = 0
			rs("ProductAttr1").value = v1
			if len(v2 & "")=0 then v2 = 0
			rs("ProductAttr2").value =  v2
			if len(v3 & "")>0 then rs("ProductAttrBatchId").value = v3
			RowIndexTick = RowIndexTick + 1
'if len(v3 & "")>0 then rs("ProductAttrBatchId").value = v3
			on error resume next
			rs("rowindex").value = RowIndexTick
			on error goto 0
		end sub
		public function  InitScript()
			Response.write "<script src='" & sdk.GetVirPath  & "inc/ProductAttrhelper.js'></script>"
			Response.write "<style>.attrreadsum input, .attrreadNumInput{background-color:#e0e0e0; color:#666;}</style>"
			Response.write "<script src='" & sdk.GetVirPath  & "inc/ProductAttrhelper.js'></script>"
		end function
		private  function  GetNewInputHtmlAttrs(mxid)
			dim itemhtml
			if instr(mxid & "","AttrsBatch_Attr1")>0 then
				if IsAddModel then
					itemhtml = " min='' "
				end if
				GetNewInputHtmlAttrs = " IsAttrCellBox=1 onblur='void(0)'  onkeyup='void(0)'  onpropertychange=""formatData(this,'number');""  "  & itemhtml
			else
				GetNewInputHtmlAttrs = " IsAttrSumBox=1 "
				if IsReadSumCell(mxid) then GetNewInputHtmlAttrs =  GetNewInputHtmlAttrs & " readonly "
			end if
		end function
		private function IsReadSumCell(byval mxid)
			IsReadSumCell = len(currnumtext & "")>0 and instr(mxid & "","AttrsBatch_Attr1")=0  and  ForEachIndex>0
		end function
		private sub CItemAttrTableHtml(byval mxid)
			if ForEachIndex>0 then Response.write "</td>"
			if IsReadSumCell(mxid) then
				response_Write "<td align=center isattrcell=1 class='attrreadsum' >"
			else
				response_Write "<td align=center isattrcell=1 >"
			end if
		end sub
		private sub response_Write(byval html)
			if BufferModel = false then
				Response.write html
			else
				BuffterModelHtml = BuffterModelHtml & html
			end if
		end sub
		private sub  CStartAttrTableHtml(byval loadmodel)
			dim oitems, i
			dim attr1 :  set attr1 =  EachObject.Attr1Configs
			dim attr2 :  set attr2 =  EachObject.Attr2Configs
			response_Write "<input type='hidden'  name='__sys_productattrs_batchid' value='" & EachObject.mxpxid & "'>"
			response_Write "<input type='hidden'  id='__sy_pa_fs_" &   EachObject.mxpxid & "' name='__sys_productattrs_fields_" &   EachObject.mxpxid & "' value=''>"
			response_Write "<table class='productattrstable'><tr class='header'>"
			if not attr2 is nothing then
				response_Write "<td>" & attr2.title & "</td>"
			end if
			if not attr1 is nothing then
				for i = 0 to ubound(attr1.options)
					oitems = attr1.options(i)
					response_Write "<td>" & oitems(1)  & "</td>"
				next
			end if
			response_Write "<td>小计</td></tr>"
			response_Write "<tr class=data>"
			dim IsEdit :  IsEdit =CurrEditDispaly = "editable"
			if not attr2 is nothing then
				response_Write "<td align=center>"
				if IsEdit then
					response_Write "<select name='AttrsBatch_Attr2_" & EachObject.mxpxid & "'>"
					if EachObject.StrongInherit = false then  response_Write "<option value=0 selected ></option>"
				end if
				for i = 0 to ubound(attr2.options)
					dim oid : oid= attr2.options(i)(0)
					dim otit : otit = attr2.options(i)(1)
					if (oid & "")=  (EachObject.Attr2 & "") then
						if IsEdit then
							response_Write "<option value=" & oid &" selected >" & otit & "</option>"
						else
							response_Write otit & "<input type='hidden' name='AttrsBatch_Attr2_" & EachObject.mxpxid & "' value='" & oid & "'>"
						end if
					else
						if IsEdit and EachObject.StrongInherit= false then  response_Write "<option value=" & oid &" >" & otit & "</option>"
					end if
				next
				if IsEdit then response_Write "</select>"
				response_Write "</td>"
			end if
		end sub
		private sub CEndAttrTableHtml
			response_Write "</td></tr></table>"
		end sub
		private CurrMaxMXPXID
		Public Function  CreateProxyRequest(ByVal  mxidname,  ByVal  billlistidname,  ByVal  parentbilllistidname,  ByVal numname,  ByVal joinfilednames)
			if isOpened = false then exit Function
			Dim mxid, n, i
			ExecuteGlobal "public Request"
			Set Request =  new ProductAttrProxyRequst
			For Each n In SystemRequestObject.form
				Request.AddFormValue n, CStr( SystemRequestObject.form(n))
			next
			CurrMaxMXPXID = 0
			dim rs : set rs = conn.execute("select max(id) from mxpx")
			if rs.eof = false then CurrMaxMXPXID = rs(0).value
			rs.close
			dim  mxids :  mxids =  split(SystemRequestObject.Form("__sys_productattrs_batchid"), ",")
			for i = 0 to ubound(mxids)
				mxid = clng(mxids(i))
				HanleFormBatchItemData mxid,  mxidname,  billlistidname,  parentbilllistidname,  numname,  joinfilednames
			next
		end function
		private sub HanleFormBatchItemData(byval  batchid,  ByVal  mxidname,  ByVal  billlistidname,  ByVal  parentbilllistidname,  ByVal numname,  ByVal joinfilednames)
			dim n, v, c, joinfs, i, ii,  attsns
			dim  isallmodel : isallmodel = false
			dim attr1s :  attr1s= split("", ",")
			for each n in SystemRequestObject.Form
				if  instr(n,  numname  & "AttrsBatch_Attr1_" & batchid & "_" ) = 1 then
					v  = SystemRequestObject.Form(n)
					if len(v & "")>0 then
						ArrayAppend attr1s,  array(n, v)
					end if
				end if
			next
			if ubound(attr1s)  <0  then exit sub
			joinfs = split(joinfilednames, ",")
			ArrayAppend joinfs,  numname
			dim  sumvalues, usedvalues, sumsize
			sumsize = ubound(joinfs)
			redim usedvalues(sumsize)
			dim item_batchid,  item_attr1_id,  item_billlistid ,   item_parentbilllistid
			dim currbilllistid :  currbilllistid = CStr(SystemRequestObject.Form( billlistidname & batchid ))
			currbilllistid = clng("0" & currbilllistid)
			dim isdeleted : isdeleted = cellcount>=0
			dim sumnum : sumnum =  cdbl(replace(CStr(SystemRequestObject.Form( numname & batchid )) ,",",""))
			dim cellcount :  cellcount = ubound(attr1s)
			for i = 0 to cellcount
				n  = attr1s(i)(0)
				v =  cdbl(replace(attr1s(i)(1), ",",""))
				attsns = split( split(n, "AttrsBatch_Attr1_")(1) , "_")
				item_batchid = clng(attsns(0))
				item_attr1_id = clng(attsns(1))
				item_billlistid = clng(attsns(2))
				item_parentbilllistid = clng(attsns(3))
				if isdeleted then
					if  item_billlistid = currbilllistid  and currbilllistid> 0 then  isdeleted = false
				end if
				if item_billlistid = 0  or item_billlistid<>currbilllistid  then
					CurrMaxMXPXID = CurrMaxMXPXID+1
'if item_billlistid = 0  or item_billlistid<>currbilllistid  then
					dim currformv : currformv = Request.Form(mxidname)
					if len(currformv & "") > 0 then  currformv = currformv & ","
					Request.SetFormValue mxidname,  InsertMxIdAfter(currformv ,  CurrMaxMXPXID, batchid)
					AddNewFormItem  batchid,  CurrMaxMXPXID,  item_billlistid, item_attr1_id,  billlistidname,  parentbilllistidname,  item_parentbilllistid,  numname,  joinfs ,   usedvalues,  sumnum,  v ,  i=cellcount
				else
					UpdateFormItem  batchid,   item_attr1_id,  billlistidname,  parentbilllistidname,  numname,  joinfs ,   usedvalues,  sumnum,  v ,   i=cellcount
				end if
			next
			if isdeleted then
				currformv = replace(Request.Form(mxidname), " ", "")
				currformv  = replace("," & currformv & ",", "," &  batchid & ",", ",")
				currformv =  replace(currformv, ",,", ",")
				currformv =  replace(currformv, ",,", ",")
				currformv =  replace(currformv, ",,", ",")
				currformv =  replace(currformv, ",,", ",")
				if left(currformv, 1) = "," then currformv = mid(currformv, 2)
				if right(currformv, 1) = "," then currformv = mid(currformv, 1, len(currformv)-1)
'if left(currformv, 1) = "," then currformv = mid(currformv, 2)
				Request.setFormValue mxidname,  currformv
				dim  fms :  fms = split(request.Form("__sys_productattrs_fields_" &  batchid), "|")
				for i = 0 to ubound(fms)
					Request.SetFormValue fms(i) & batchid ,  ""
				next
			end if
		end sub
		private function InsertMxIdAfter(byval  mxliststr,  byval newmxid,  byval beforemxid)
			mxliststr = "," & replace(mxliststr, " ", "") & ","
			mxliststr = replace(mxliststr, ("," & beforemxid & ",") ,  ("," & beforemxid & "," & newmxid & ","))
			mxliststr = ClearArrayStr(mxliststr, ",")
			InsertMxIdAfter =mxliststr
		end function
		private function ClearArrayStr(byval arrtxt, byval splitkey)
			dim arr1 :  arr1 = split(arrtxt, splitkey)
			dim i,  j,  arr2 : j = 0
			arr2 = split("", ",")
			for i=0 to ubound(arr1)
				if len(arr1(i))>0 then
					redim preserve arr2(j)
					arr2(j) = arr1(i)
					j=j+1
'arr2(j) = arr1(i)
				end if
			next
			ClearArrayStr = join(arr2,  splitkey)
		end function
		private sub  AddNewFormItem(byval copybatchid, byval newmxid,  byval itembilllistid, byval attr1id, byval billlistidname,  byval parentbilllistidname, byval item_parentbilllistid, byval numf,  byval joinfs ,  byref useds,  byval  allnum,  byval  itemnum ,  byval iseof)
			Request.AddFormValue billlistidname & newmxid,  itembilllistid
			if len(parentbilllistidname) >0 then  Request.AddFormValue parentbilllistidname & newmxid,  item_parentbilllistid
			Request.AddFormValue "AttrsBatch_Attr2_" & newmxid,  Request.Form("AttrsBatch_Attr2_" & copybatchid)
			Request.AddFormValue "AttrsBatch_Attr1_" & newmxid,  attr1id
			Request.AddFormValue "AttrsBatch_BatchId_" & newmxid,  copybatchid
			dim allfs : allfs = split(request.Form("__sys_productattrs_fields_" & copybatchid), "|")
			dim joinftxt : joinftxt = "|" & lcase( join(joinfs, "|") ) & "|"
			dim i, ii, iii
			for ii = 0 to ubound(allfs)
				dim itemn : itemn =  allfs(ii)
				dim litemn:  litemn = lcase(itemn)
				if litemn = lcase(billlistidname) or litemn = lcase(parentbilllistidname)  then
				else
					if  instr( joinftxt,  "|" &  litemn & "|") >0  then
						dim newjoinitemv
						newjoinitemv = 0
						if litemn =  lcase(numf) then
							newjoinitemv =  itemnum
						else
							dim oldsumv :  oldsumv = CStr(SystemRequestObject.Form(itemn & copybatchid))
							if len(oldsumv & "")=0 then  oldsumv = 0
							if isnumeric(oldsumv) = false then oldsumv = 0
							oldsumv = cdbl(replace(oldsumv & "",",",""))
							if  oldsumv <> 0 and  allnum<>0 then
								dim ji : ji = ArrayIndexOf(joinfs,  itemn)
								if ji>=0 then
									if iseof then
										newjoinitemv =  cdbl(oldsumv)*1  -  cdbl(useds(ji))
'if iseof then
									else
										newjoinitemv = cdbl(oldsumv)*cdbl(itemnum/allnum)
										newjoinitemv = sdk.getsqlvalue("select round("& newjoinitemv &","& mbit &")",0)
										useds(ji) = cdbl(useds(ji)) + cdbl(newjoinitemv)
'newjoinitemv = sdk.getsqlvalue("select round("& newjoinitemv &","& mbit &")",0)
									end if
								end if
							end if
						end if
						Request.AddFormValue itemn & newmxid,  newjoinitemv
					else
						Request.AddFormValue itemn & newmxid,  CStr(SystemRequestObject.Form(itemn & copybatchid))
					end if
				end if
			next
		end sub
		private sub  UpdateFormItem(byval currmxid,  byval attr1id,  byval billlistidname,  byval parentbilllistidname, byval numf,   byval joinfs ,   byref useds,  byval  allnum,  byval  itemnum ,  byval iseof)
			Request.AddFormValue "AttrsBatch_Attr1_" & currmxid,  attr1id
			Request.AddFormValue "AttrsBatch_BatchId_" & currmxid,  currmxid
			dim allfs : allfs = split(request.Form("__sys_productattrs_fields_" & currmxid), "|")
			dim joinftxt : joinftxt = "|" & lcase( join(joinfs, "|") ) & "|"
			dim i, ii, iii
			for ii = 0 to ubound(allfs)
				dim itemn : itemn =  allfs(ii)
				dim litemn:  litemn = lcase(itemn)
				if litemn = lcase(billlistidname) or litemn = lcase(parentbilllistidname)  then
				else
					if  instr( joinftxt,  "|" &  litemn & "|") >0  then
						dim newjoinitemv
						newjoinitemv = 0
						if litemn =  lcase(numf) then
							newjoinitemv =  itemnum
						else
							dim oldsumv :  oldsumv = CStr(SystemRequestObject.Form(itemn & currmxid))
							if len(oldsumv & "")=0 then  oldsumv = 0
							oldsumv = cdbl(replace(oldsumv & "",",",""))
							if  oldsumv <> 0 and  allnum<>0 then
								dim ji : ji = ArrayIndexOf(joinfs,  itemn)
								if ji>=0 then
									if iseof then
										newjoinitemv = oldsumv*1  -  cdbl(useds(ji))
'if iseof then
									else
										newjoinitemv = oldsumv *  cdbl(itemnum/allnum)
										newjoinitemv = sdk.getsqlvalue("select round("& newjoinitemv &","& mbit &")",0)
										useds(ji) = cdbl(useds(ji)) + newjoinitemv
'newjoinitemv = sdk.getsqlvalue("select round("& newjoinitemv &","& mbit &")",0)
									end if
								end if
							end if
						end if
						Request.SetFormValue litemn & currmxid,  newjoinitemv
					end if
				end if
			next
		end sub
		public sub ShowFormValues
			dim i
			for i = 0 to ubound(request.FormValues)
				Response.write  request.FormValues(i)(0) & "===" & request.FormValues(i)(1) & "<br>"
			next
			Response.end
		end sub
		public sub ArrayAppend(byref arr,  byref v)
			dim c :  c = ubound(arr)+1
'public sub ArrayAppend(byref arr,  byref v)
			redim preserve arr(c)
			arr(c) =  v
		end sub
		private function ArrayIndexOf(byref arr,  byref v)
			dim i
			for i = 0 to  ubound(arr)
				if lcase(arr(i)) = lcase(v) then ArrayIndexOf = i : exit function
			next
			ArrayIndexOf =  -1
			if lcase(arr(i)) = lcase(v) then ArrayIndexOf = i : exit function
		end function
	end Class
	Public  SystemRequestObject :  Set SystemRequestObject = Request
	Class  ProductAttrProxyRequst
		Public QueryString
		Public ServerVariables
		Public Cookies
		Public  TotalBytes
		Public  FormValues
		Public Function BinaryRead(ByVal count)
			BinaryRead = SystemRequestObject.BinaryRead(count)
		end function
		Public Function AddFormValue(name,  value)
			Dim c: c = ubound(FormValues) + 1
'Public Function AddFormValue(name,  value)
			ReDim Preserve FormValues(c)
			FormValues(c) =  Array(name, value)
		end function
		Public Function SetFormValue(name,  value)
			name = LCase(name)
			For i = 0 To  ubound(FormValues)
				If LCase(FormValues(i)(0)) = name  Then
					FormValues(i)(1) =  value
					Exit Function
				end if
			next
			AddFormValue name, value
		end function
		Public Function Form(byval name)
			dim i
			name = LCase(name)
			For i = 0 To  ubound(FormValues)
				If LCase(FormValues(i)(0)) = name  Then
					Form = FormValues(i)(1)
					Exit Function
				end if
			next
		end function
		Public  Default Function  items(ByVal name)
			Dim r : r = QueryString(name)
			If Len(r & "") = 0 Then r = Form(name)
			items = r
		end function
		public sub Class_Initialize
			FormValues = Split("",",")
			TotalBytes = SystemRequestObject.TotalBytes
			Set QueryString = SystemRequestObject.QueryString
			Set ServerVariables = SystemRequestObject.ServerVariables
			Set Cookies = SystemRequestObject.Cookies
		end sub
	End Class
	
	Server.ScriptTimeOut=100000000
	Response.write " " & vbcrlf & "<HTML>" & vbcrlf & "<HEAD>" & vbcrlf & "<TITLE>入库明细导出</TITLE>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8""></HEAD>" & vbcrlf & "<body>" & vbcrlf & " <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "  <tr>"& vbcrlf & "     <td class=""place"">入库明细导出</td>" & vbcrlf & "       <td>&nbsp;</td>" & vbcrlf & " <td align=""right"">&nbsp;</td>" & vbcrlf & "     <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>  " & vbcrlf & " <table width=""100%""border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "<tr class=""top"">" & vbcrlf & "  <td colspan=2 class=tablebody1>&nbsp;</td>" & vbcrlf & "</tr>" & vbcrlf & "<tr>" & vbcrlf & "  <td colspan=2 class=tablebody1>" & vbcrlf & "<span id=""CountTXTok"" name=""CountTXTok"" style=""font-size:10pt; color:#008040"">" & vbcrlf & "<B>正在导出入库明细,请稍后...</B></span>" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""1"">" & vbcrlf & "<tr> " & vbcrlf & "<td bgcolor=000000>" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"">" & vbcrlf & "<tr> " & vbcrlf & "<td bgcolor=ffffff height=9><img src=""../images/tiao.jpg"" width=""0"" height=""16"" id=""CountImage"" name=""CountImage"" align=""absmiddle""></td></tr></table>" & vbcrlf & "</td></tr></table> <span id=""CountTXT"" name=""CountTXT"" style=""font-size:9pt; color:#008040"">0</span><span style=""font-size:9pt; color:#008040"">%</span></td></tr>" & vbcrlf & "<tr class=""top"">" & vbcrlf & "  <td colspan=2 class=tablebody1 height=""40"">" & vbcrlf & "  </td>" & vbcrlf & "</tr>" & vbcrlf & "</table>" & vbcrlf & ""
	Response.write Application("sys.info.jsver")
	isOpenAssisUnit = (GetAssistUnitTactics()&""="1")
	dim MODULES
	MODULES=session("zbintel2010ms")
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open from power  where ord="&session("personzbintel2007")&" and sort1=23 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_23_3=0
	else
		open_23_3=rs1("qx_open")
	end if
	rs1.close
	set rs1=nothing
	dotstr=""
		for i=1 to num_dot_xs
			dotstr=dotstr&"0"
			next
			dotstr_num=""
				for i=1 to num1_dot
					dotstr_num=dotstr_num&"0"
					next
					Dim headerStr
					Set xApp = server.createobject(ZBRLibDLLNameSN & ".HtmlExcelApplication")
					xApp.init Me, conn
					Set xsheet = xApp.sheets.add("入库明细表")
					if isOpenAssisUnit then assHeader=",辅助单位,辅助数量"
					if isOpenProductAttr then proHeader=",产品属性1,产品属性2"
					headerStr =  "入库日期,产品名称,产品编号,产品型号,单位"&proHeader&",入库数量"&assHeader&",仓库,入库类别,批号,序列号,生产日期,有效日期,包装,件数," & _
					"入库编号,入库主题,备注,申请人员"
					if (ZBRuntime.MC(1002) or ZBRuntime.MC(1000)) then
						headerStr = headerStr & ",关联供应商"
						sql="select id,title,name,sort from zdymx where sort1=31 and set_open=1 AND LEFT(name,3) = 'zdy' order by gate1 asc"
						set rszdy=conn.execute(sql)
						dim arrzdy()
						zdyfields=""
						m=22
						n=1
						while not rszdy.eof
							headerStr = headerStr & "," & rszdy("title")
							zdyfields=zdyfields&",a."&rszdy("name")& " as " & rszdy("name")
							redim Preserve arrzdy(3,n)
							arrzdy(0,n)=rszdy("name")
							arrzdy(1,n)=rszdy("title")
							arrzdy(3,n)=rszdy("sort")
							rszdy.movenext
							n=n+1
							rszdy.movenext
						wend
						zdycount=n-1
						rszdy.movenext
						rszdy.close
						set rszdy=nothing
					end if
					Response.Flush
					xsheet.showHeader headerStr
					xsheet.movenext
					set rs1=server.CreateObject("adodb.recordset")
					sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=31 and sort2=1"
					rs1.open sql1,conn,1,1
					if rs1.eof then
						open_31_1=0
						intro_31_1=0
					else
						open_31_1=rs1("qx_open")
						intro_31_1=rs1("qx_intro")
					end if
					rs1.close
					set rs1=nothing
					set rs7=server.CreateObject("adodb.recordset")
					sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=1"
					rs7.open sql1,conn,1,1
					if rs7.eof then
						open_26_1=0
						intro_26_1=0
					else
						open_26_1=rs7("qx_open")
						intro_26_1=rs7("qx_intro")
					end if
					rs7.close
					set rs7=nothing
					set rs1=server.CreateObject("adodb.recordset")
					sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=31 and sort2=11"
					rs1.open sql1,conn,1,1
					if rs1.eof then
						open_31_11=0
						intro_31_11=0
					else
						open_31_11=rs1("qx_open")
						intro_31_11=rs1("qx_intro")
					end if
					rs1.close
					set rs1=nothing
					if open_31_11=3 then
						list1=""
					elseif open_31_11=1 then
						if len(intro_31_11&"") = 0 then intro_31_11 = -222
'elseif open_31_11=1 then
						list1="and a.addcate in ("&intro_31_11&")"
					else
						list1="and a.addcate=0"
					end if
					Str_Result="where a.num1<>0 and (a.del=1 or a.del=99) "&list1&""
					Function IsInList(StrList, StrFind, CharSplit)
						IsInList = InStr(1, CharSplit&StrList&CharSplit, CharSplit&StrFind&CharSplit, 1)>0
					end function
	Function searchCID(IDs,tb)
		If IDs&""<>"" Then
			dim CIDs , rs
			CIDs = ""
			IDs = replace(IDs," ","")
			Set rs = conn.Execute("select dbo.GetMenuArea('"& IDs &"','"& tb &"')")
			If Not rs.Eof Then
				CIDs = rs(0)
			end if
			rs.close
			set rs = nothing
			searchCID = CIDs
		end if
	end function
	fromsc=Request("fromsc")
	strW1=replace(request("W1")," ","")
	strW2=replace(request("W2")," ","")
	strW3=replace(request("W3")," ","")
	if strW1="" then strW1="0"
	if strW2="" then strW2="0"
	if strW3="" then strW3="0"
	strW3=getW3(strW1,strW2,strW3)
	strW3=getLimitedW3(strW3,2,1,0,session("personzbintel2007"))
	strW4=replace(replace(strW3,"0",""),",","")
	if strW4<>"" then
		tmp=split(getW1W2(strW3),";")
		strW1=tmp(0)
		strW2=tmp(1)
	else
		strW1=""
		strW2=""
		strW3=""
	end if
	W1=strW1
	W2=strW2
	W3=strW3
	W4=strW4
	searchType          = Request("searchType")
	A2                          = searchCID(Request("A2"),"menu")
	product_title       = Request("product_title")
	product_order       = Request("product_order")
	product_type        = Request("product_type")
	product_PH          = Request("product_PH")
	product_XLH         = Request("product_XLH")
	product_BZ          = Request("product_BZ")
	product_Unit        = Request("product_Unit")
	product_zdy1        = Request("product_zdy1")
	product_zdy2        = Request("product_zdy2")
	product_zdy3        = Request("product_zdy3")
	product_zdy4        = Request("product_zdy4")
	product_zdy5        = Request("product_zdy5")
	product_zdy6        = Request("product_zdy6")
	custom_name         = Request("custom_name")
	kuin_title          = Request("kuin_title")
	kuin_SN                     = Request("kuin_SN")
	kuin_intro          = Request("kuin_intro")
	kuin_type           = Request("kuin_type")
	product_CK          = Request("product_CK")
	product_NumKu1      = Request("product_NumKu1")
	product_NumKu2      = Request("product_NumKu2")
	appDate1            = Request("appDate1")
	appDate2            = Request("appDate2")
	If searchType = "1" Then
		If A2 <> "" Then
			Str_Result = Str_Result & " AND a.ord IN (SELECT ord FROM product WHERE sort1 IN ("&A2&")) "
		ElseIf Len(session("hzkc2_"& session("personzbintel2007")))<>0 Then
			Str_Result = Str_Result & " AND a.ord IN (SELECT ord FROM product WHERE sort1 IN ("& session("hzkc2_"& session("personzbintel2007")) &")) "
		end if
		If product_title <> "" Then
			Str_Result = Str_Result & " AND a.ord IN (SELECT ord FROM product WHERE title LIKE '%"&product_title&"%') "
		end if
		If product_order <> "" Then
			Str_Result = Str_Result & " AND a.ord IN (SELECT ord FROM product WHERE order1 LIKE '%"&product_order&"%') "
		end if
		If product_type <> "" Then
			Str_Result = Str_Result & " AND a.ord IN (SELECT ord FROM product WHERE type1 LIKE '%"&product_type&"%') "
		end if
		If product_PH <> "" Then
			Str_Result = Str_Result & " AND a.ph LIKE '%"&product_PH&"%' "
		end if
		If product_XLH <> "" Then
			Str_Result = Str_Result & " AND (a.xlh LIKE '%"&product_XLH&"%' or a.id in (select s.listid from S2_SerialNumberRelation s inner join M2_SerialNumberList ml on ml.id = s.SerialID and s.BillType=61001 where  ml.seriNum like '%"& product_XLH &"%' ) ) "
		end if
		If product_BZ <> "" Then
			Str_Result = Str_Result & " AND a.bz IN ("&product_BZ&") "
		end if
		If product_Unit <> "" Then
			Str_Result = Str_Result & " AND a.unit IN ("&product_Unit&") "
		end if
		If product_zdy1     <> "" Then
			Str_Result = Str_Result & " AND a.zdy1 LIKE '%"&product_zdy1&"%' "
		end if
		If product_zdy2     <> "" Then
			Str_Result = Str_Result & " AND a.zdy2 LIKE '%"&product_zdy2&"%' "
		end if
		If product_zdy3     <> "" Then
			Str_Result = Str_Result & " AND a.zdy3 LIKE '%"&product_zdy3&"%' "
		end if
		If product_zdy4     <> "" Then
			Str_Result = Str_Result & " AND a.zdy4 LIKE '%"&product_zdy4&"%' "
		end if
		If product_zdy5 <> "" Then
			Str_Result = Str_Result & " AND a.zdy5 = "&product_zdy5&" "
		end if
		If product_zdy6 <> "" Then
			Str_Result = Str_Result & " AND a.zdy6 = "&product_zdy6&" "
		end if
		If custom_name <> "" Then
			Str_Result = Str_Result & " AND (((case when "&open_26_1&"=3 or("&open_26_1&"=1 and  CHARINDEX(',' + CAST(t.cateid as varchar(12)) + ',', ',' +cast('"&intro_26_1&"' as varchar(max))+',' )>0) then isnull(a.company,0) else 0 end) IN (SELECT ord FROM tel WHERE sort3 = 2 AND name LIKE '%"&custom_name&"%')) or ((case when "&open_1_1&"=3 or("&open_1_1&"=1 and  CHARINDEX(',' + CAST(t.cateid as varchar(12)) + ',', ',' +cast('"&intro_1_1&"' as varchar(max))+',' )>0) then isnull(a.company,0) else 0 end) IN (SELECT ord FROM tel WHERE sort3 = 1 AND name LIKE '%"&custom_name&"%') and a.sort1=2))"
'If custom_name <> "" Then
		end if
		If kuin_title <> "" Then
			Str_Result = Str_Result & " AND a.kuin IN (SELECT ord FROM kuin WHERE title LIKE '%"&kuin_title&"%') "
		end if
		If kuin_SN <> "" Then
			Str_Result = Str_Result & " AND a.kuin IN (SELECT ord FROM kuin WHERE rkbh LIKE '%"&kuin_SN&"%') "
		end if
		If kuin_intro <> "" Then
			Str_Result = Str_Result & " and a.intro LIKE '%"&kuin_intro&"%' "
		end if
		If kuin_type <> "" Then
			Str_Result = Str_Result & " AND a.sort1 IN ("&kuin_type&") "
		end if
		If W3 <> "" Then
			Str_Result = Str_Result & " AND a.kuin IN (SELECT ord FROM kuin WHERE cateid IN ("&W3&")) "
		end if
		If product_CK <> "" Then
			Str_Result = Str_Result & " AND a.ku IN ("&product_CK&") "
		end if
		If product_NumKu1 <> "" AND product_NumKu2 <> "" Then
			Str_Result = Str_Result & " AND a.num2 BETWEEN "&product_NumKu1&" AND "&product_NumKu2&" "
		ElseIf product_NumKu1 <> "" AND product_NumKu2 = "" Then
			Str_Result = Str_Result & " AND a.num2 >= "&product_NumKu1&"  "
		ElseIf product_NumKu1 = "" AND product_NumKu2 <> "" Then
			Str_Result = Str_Result & " AND a.num2 <= "&product_NumKu2&"  "
		end if
		If appDate1 <> "" And appDate2 <> "" Then
			Str_Result = Str_Result & " AND a.kuin IN (SELECT ord FROM kuin WHERE CONVERT(VARCHAR(10),date5,120) BETWEEN '"&appDate1&"' AND '"&appDate2&"' ) "
		ElseIf appDate1 <> "" And appDate2 = "" Then
			Str_Result = Str_Result & " AND a.kuin IN (SELECT ord FROM kuin WHERE CONVERT(VARCHAR(10),date5,120) >= '"&appDate1&"' ) "
		ElseIf appDate1 = "" And appDate2 <> "" Then
			Str_Result = Str_Result & " AND a.kuin IN (SELECT ord FROM kuin WHERE CONVERT(VARCHAR(10),date5,120) <= '"&appDate1&"' ) "
		end if
	end if
	companyid=Request("companyid")
	s1=request.form("s1")
	a=request.querystring("a")
	B=request.querystring("B")
	C=request.querystring("C")
	D=request.querystring("D")
	E=request.querystring("E")
	F=request.querystring("F")
	m1=request.querystring("ret")
	m2=request.querystring("ret2")
	telid=request.querystring("telid")
	cgbzid=request.querystring("cgbzid")
	cgret=request.querystring("cgret")
	cgret2=request.querystring("cgret2")
	TransType=request.querystring("TransType")
	if TransType&"" ="rkhz" then
		AssistUnit=request.querystring("AssistUnit")
		if AssistUnit&""="" then AssistUnit="0"
		If AssistUnit&""<>"" Then  Str_Result=Str_Result&" and isnull(c.AssistUnit,0)= "&AssistUnit
	end if
	kuid = ""
	if Request("kuid")<>"" then kuid=Request("kuid")
	If kuid<>"" Then
		Str_Result = Str_Result & " AND c.id = "&kuid&" "
		datemonth = Request("datemonth")
		If Len(datemonth)>0 And Len(datemonth)<10 Then
			datemonth = Replace(Replace(datemonth,".","-"),"/","-")
'If Len(datemonth)>0 And Len(datemonth)<10 Then
			m1=datemonth &"-1"
'If Len(datemonth)>0 And Len(datemonth)<10 Then
			m2=dateadd("d",-1,dateadd("m",1 ,m1))
'If Len(datemonth)>0 And Len(datemonth)<10 Then
		end if
	end if
	Dim partid,BillID ,fromtype ,listid, date1: partid = 0 : BillID = 0 : date1 =date
	Dim afv_existssql : afv_existssql = LongRequest("afv_existssql")
	If Len(afv_existssql)>0 Then
		existssql = sdk.base64.RsaDecode(afv_existssql)
		If Len(existssql)>0 Then
			partid = request("partid")
			Dim extSql : extSql = ""
			If partid &""<>"" Then extSql = " and g.orgsid ="& partid
			Str_Result = Str_Result & " and b.ord in ("& existssql & extSql &" ) "
		end if
	else
		if fromtype<=0 then
			if m1="" and telid="" and request.querystring("s1")<>"1" then m1=cdate(year(date)&"-"&month(date)&"-1")
'if fromtype<=0 then
			if m2="" and telid="" and request.querystring("s1")<>"1" then m2=dateadd("m",1,m1)-1
'if fromtype<=0 then
		end if
	end if
	if a="" then a=0
	if D="" then D=33
	if telid<>"" then Str_Result=Str_Result&" and d.company =" & telid
	if cgbzid<>"" then Str_Result=Str_Result&" and d.bz=" & cgbzid
	If cgret&""<>"" Then  Str_Result=Str_Result&" and datediff(d,'"& cgret &"',e.date3)>=0 "
	If cgret2&""<>"" Then  Str_Result=Str_Result&" and datediff(d,'"& cgret2 &"',e.date3)<=0 "
	if a<>0 then Str_Result=Str_Result+"and a.ku='"&a&"'"
	If cgret2&""<>"" Then  Str_Result=Str_Result&" and datediff(d,'"& cgret2 &"',e.date3)<=0 "
	if C<>"" then
		if B="cpmc" then
			Str_Result=Str_Result+" and  a.ord in (select ord from product where title like '%"&C&"%')"
'if B="cpmc" then
		elseif B="cpbh" then
			Str_Result=Str_Result+" and  a.ord in (select ord from product where order1 like '%"&C&"%')"
'elseif B="cpbh" then
		elseif B="cpxh" then
			Str_Result=Str_Result+" and  a.ord in (select ord from product where type1 like '%"&C&"%')"
'elseif B="cpxh" then
		elseif B="glkh" then
			Str_Result = Str_Result & " AND (((case when "&open_26_1&"=3 or("&open_26_1&"=1 and  CHARINDEX(',' + CAST(t.cateid as varchar(12)) + ',', ',' +cast('"&intro_26_1&"' as varchar(max))+',' )>0) then isnull(t.ord,0) else 0 end) IN (SELECT ord FROM tel WHERE sort3 = 2 AND name LIKE '%"&C&"%')) or ((case when "&open_1_1&"=3 or("&open_1_1&"=1 and  CHARINDEX(',' + CAST(t.cateid as varchar(12)) + ',', ',' +cast('"&intro_1_1&"' as varchar(max))+',' )>0) then isnull(t.ord,0) else 0 end) IN (SELECT ord FROM tel WHERE sort3 = 1 AND name LIKE '%"&C&"%') and a.sort1=2))"
'elseif B="glkh" then
		elseif B="ph" then
			Str_Result=Str_Result+" and  c.ph like '%"&C&"%'"
'elseif B="ph" then
		elseif B="xlh" then
			Str_Result=Str_Result+" and  (c.xlh like '%"&C&"%'  or a.id in (select s.listid from S2_SerialNumberRelation s inner join M2_SerialNumberList ml on ml.id = s.SerialID and s.BillType=61001 where  ml.seriNum like '%"& C &"%' ) )"
'elseif B="xlh" then
		elseif B="bz" then
			Str_Result=Str_Result+" and  a.bz in (select ord from sortonehy where sort1 like '%"&C&"%')"
'elseif B="bz" then
		elseif B="js" then
			Str_Result=Str_Result+" and  a.js like '%"&C&"%'"
'elseif B="js" then
		elseif B="ckbz" then
			Str_Result=Str_Result+" and  a.intro like '%"&C&"%'"
'elseif B="ckbz" then
		elseif B="rkbh" then
			Str_Result=Str_Result+" and  b.rkbh like '%"&C&"%'"
'elseif B="rkbh" then
		elseif B="rkzt" then
			Str_Result=Str_Result+" and  b.title like '%"&C&"%'"
'elseif B="rkzt" then
		elseif B<>"" then
			if isnumeric(B) then
				sql="select id,title,name,sort from zdymx WHERE sort1=31 and set_open=1 AND LEFT(name,3) = 'zdy' and id="&B&" order by gate1 asc"
				set rszdy=conn.execute(sql)
				if not rszdy.eof then
					If rszdy("name") = "zdy5" Then
						Str_Result=Str_Result+" and a."&rszdy("name")&" = (SELECT TOP 1 ID FROM sortonehy WHERE gate2 = 2101 AND sort1 like '%"&C&"%' ) "
'If rszdy("name") = "zdy5" Then
					ElseIf rszdy("name") = "zdy6" Then
						Str_Result=Str_Result+" and a."&rszdy("name")&" = (SELECT TOP 1 ID FROM sortonehy WHERE gate2 = 2102 AND sort1 like '%"&C&"%' ) "
'ElseIf rszdy("name") = "zdy6" Then
					else
						Str_Result=Str_Result+" and a."&rszdy("name")&" like '%"&C&"%'"
'ElseIf rszdy("name") = "zdy6" Then
					end if
				end if
				rszdy.close
			end if
		end if
	end if
	if D<>"" and D<>"33" then Str_Result=Str_Result+"and a.sort1="&D&""
	rszdy.close
	if fromsc&""<>"" then
		Str_Result=Str_Result+"and a.sort1 in(3,5,13,14,15,16) "
'if fromsc&""<>"" then
	end if
	if not ZBRuntime.MC(15000) then
		Str_Result=Str_Result+" and  a.sort1<>1 "
'if not ZBRuntime.MC(15000) then
	end if
	if not ZBRuntime.MC(8000) then
		Str_Result=Str_Result+" and  a.sort1<>2 "
'if not ZBRuntime.MC(8000) then
	end if
	if not ZBRuntime.MC(17006) then
		Str_Result=Str_Result+" and  a.sort1<>6 "
'if not ZBRuntime.MC(17006) then
	end if
	if not ZBRuntime.MC(17004) then
		Str_Result=Str_Result+" and  a.sort1<>7 "
'if not ZBRuntime.MC(17004) then
	end if
	if not ZBRuntime.MC(17005) then
		Str_Result=Str_Result+" and  a.sort1<>8 "
'if not ZBRuntime.MC(17005) then
	end if
	if not ZBRuntime.MC(17007) then
		Str_Result=Str_Result+" and  a.sort1<>9 "
'if not ZBRuntime.MC(17007) then
	end if
	if E<>"" then Str_Result=Str_Result+" and a.ord="&E&""
'if not ZBRuntime.MC(17007) then
	if F<>"" then Str_Result=Str_Result+" and a.unit="&F&""
'if not ZBRuntime.MC(17007) then
	If searchType<>1 then
		if m1<>"" then Str_Result=Str_Result+" and datediff(mi,'"&m1&" 00:00:00',b.date5)>=0 "
'If searchType<>1 then
		if m2<>"" then Str_Result=Str_Result+" and datediff(mi,'"&m2&" 23:59:59',b.date5)<=0 "
'If searchType<>1 then
	end if
	if companyid&""=""then
		companyid=0
	end if
	if companyid<>"" and companyid>0 then
		Str_Result = Str_Result & "and t.ord="&companyid&" "
	end if
	px=request.QueryString("px")
	if px="" then px=1
	if px=1 then
		px_Result="order by date5 desc,aa.date7 desc,aa.id desc"
	elseif px=2 then
		px_Result="order by date5 asc,aa.date7 asc"
	elseif px=3 then
		px_Result="order by aa.num1 desc,aa.date7 desc,id desc"
	elseif px=4 then
		px_Result="order by num1 asc,aa.date7 asc,id asc"
	elseif px=5 then
		px_Result="order by ku_ph desc,aa.date7 desc,id desc"
	elseif px=6 then
		px_Result="order by ku_ph asc,aa.date7 asc,id asc"
	elseif px=7 then
		px_Result="order by ku_xlh desc,aa.date7 desc,id desc"
	elseif px=8 then
		px_Result="order by ku_xlh asc,aa.date7 asc,id asc"
	elseif px=9 then
		px_Result="order by js desc,aa.date7 desc,id desc"
	elseif px=10 then
		px_Result="order by js asc,aa.date7 asc,id asc"
	elseif px=11 then
		px_Result="order by ku desc,aa.date7 desc,id desc"
	elseif px=12 then
		px_Result="order by ku asc,aa.date7 asc,id asc"
	end if
	i=1
	sumMoney2=0
	sumMoney=0
	sumNum=0
	sumAssistNum=0
	Dim rowIndex, pageCount
	PreProcV = -1
'Dim rowIndex, pageCount
	pageCount = 1
	hasModels = (ZBRuntime.MC(1002) or ZBRuntime.MC(1000))
	sql1 = "select aa.*,(select top 1 name from tel  where ord=aa.company) as telname,"&_
	"aa.cateid telcateid,isnull(aa.sort3,0)sort3,"&_
	"(select top 1 sort1 from sortck where ord=aa.ku) as ckname,"&_
	"(select top 1 sort1 from sortonehy  where ord=aa.bz) as bzname,"&_
	"(select top 1 sort1 from sortonehy  where ord=aa.unit) as unitname,"&_
	"(select top 1 sort1 from sortonehy  where ord=aa.AssistUnit) as AssistUnitName,"&_
	"convert(decimal(25,12),ROUND(REPLACE(ISNULL(aa.price1,0),',',''),12)) as ku_price1, "&_
	"aa.ku_money1 as ku_jc_money1,isnull(aa.price2,0),aa.money2, "&_
	"(case isnull(bb.del,0) when 1 then bb.title else '产品已被删除' end) as p_title, bb.order1, bb.type1, aa.title as kuintitle,dd.name as cateidname "&_
	"from ("&vbcrlf&_
	"select sga1.title as ProductAttr1,sga2.title as ProductAttr2,a.id kuinlistid,a.kuin,t.sort3,t.cateid,c.id,a.ord,a.ku,a.bz,a.num1,a.unit,c.AssistUnit,c.AssistNum,a.price1,isnull(a.pricemonth,0) as pricemonth,isnull(t.ord,0) as company,a.addcate,a.sort1,a.js,"&_
	"a.intro,a.datesc,a.dateyx,a.date7,c.ph as ku_ph,isnull(c.xlh,'') as ku_xlh,c.num3 as ku_num1,c.money1 as ku_money1,a.price2,isnull(c.num1*a.money2/a.num1,0) as money2," & vbcrlf &_
	"CONVERT(VARCHAR(10),b.date5,120) daterk,b.date5,b.ord as bord,b.title as title,b.rkbh as rkbh,a.caigou  "&vbcrlf&zdyfields&_
	" from kuinlist a "&vbcrlf&_
	"inner join kuin b on a.kuin=b.ord and a.del in (1,99) and b.del in (1,99) "&vbcrlf&_
	"inner join ku c on c.kuinlist=a.id "&vbcrlf&_
	"inner join sortck x4 on x4.del=1 and x4.ord = c.ck and (cast(x4.intro as varchar(10)) = '0' or charindex(',' + cast("&session("personzbintel2007")&" as varchar(20)) + ',',','+replace(cast(x4.intro as varchar(8000)),' ','')+',')>0) " &_
	"inner join ku c on c.kuinlist=a.id "&vbcrlf&_
	"left join caigoulist d on d.id=a.caigoulist left join caigou e on d.caigou=e.ord and b.sort1 in (1,4) "&vbcrlf&_
	"left join contractth  co on co.ord=b.caigou "  &_
	"left join Shop_GoodsAttr sga1 WITH(NOLOCK) on sga1.id=a.ProductAttr1 "&vbcrlf&_
	"left join Shop_GoodsAttr sga2 WITH(NOLOCK) on sga2.id=a.ProductAttr2 "&vbcrlf&_
	"left join tel t  on  (case when b.sort1=2 THEN co.company  when b.sort1=10 THEN 0 when b.sort1=4 THEN b.company when b.sort1 in (5,13,14,15) THEN b.company ELSE e.company END )=t.ord and t.del=1   "& Str_Result &_
	" UNION ALL "&vbcrlf&_
	"SELECT sga1.title as ProductAttr1,sga2.title as ProductAttr2,a.id kuinlistid,a.kuin,t.sort3,t.cateid,c.id,a.ord,c.ck,a.bz,a.num1,a.unit,c.AssistUnit,c.AssistNum,a.price1,isnull(a.pricemonth,0) as pricemonth,isnull(a.company,0) as company,a.addcate,a.sort1,a.js,"&_
	"a.intro,a.datesc,a.dateyx,a.date7,c.ph as ku_ph,isnull(c.xlh,'') as ku_xlh,s_b.num1 as ku_num1,cast(isnull(s_b.num1*a.money1/a.num1,0) as decimal(25,12)) as ku_money1,"&_
	"a.price2,cast(isnull(s_b.num1*a.money2/a.num1,0) as decimal(25,12)) as money2, " & vbcrlf &_
	" CONVERT(VARCHAR(10),b.date5,120) daterk,b.date5,b.ord as bord,b.title as title,b.rkbh as rkbh,a.caigou "&vbcrlf&zdyfields&_
	" from kuinlist a "&vbcrlf&_
	"INNER join kuin b on a.kuin=b.ord  "&vbcrlf&_
	"INNER JOIN kuhclist s_b ON a.id=s_b.kuinlist AND s_b.del=1 "&vbcrlf&_
	"INNER JOIN ku c ON c.id=s_b.kuid "&vbcrlf&_
	"inner join sortck x4 on x4.del=1 and x4.ord = c.ck and (cast(x4.intro as varchar(10)) = '0' or charindex(',' + cast("&session("personzbintel2007")&" as varchar(20)) + ',',','+replace(cast(x4.intro as varchar(8000)),' ','')+',')>0) " &_
	"INNER JOIN ku c ON c.id=s_b.kuid "&vbcrlf&_
	"LEFT JOIN caigoulist d ON d.id=a.caigoulist left join caigou e on d.caigou=e.ord and b.sort1 in (1,4) "&vbcrlf&_
	"left join contractth  co on co.ord=b.caigou " &vbcrlf&_
	"left join Shop_GoodsAttr sga1 WITH(NOLOCK) on sga1.id=a.ProductAttr1 "&vbcrlf&_
	"left join Shop_GoodsAttr sga2 WITH(NOLOCK) on sga2.id=a.ProductAttr2 "&vbcrlf&_
	"left join tel t  on  (case when b.sort1=2 THEN co.company  when b.sort1=10 THEN 0 when b.sort1=4 THEN b.company ELSE e.company END )=t.ord"&Str_Result&_
	") aa "&_
	"inner join product bb on aa.ord=bb.ord "&_
	"left join gate dd on dd.ord=aa.addcate "&px_Result&""
	set rs1 = server.CreateObject("adodb.recordset")
	rs1.open sql1,conn,1,1
	C1=rs1.recordcount
	if not rs1.eof then
		do until rs1.eof
			ProductAttr1=rs1("ProductAttr1")
			ProductAttr2=rs1("ProductAttr2")
			sort3=rs1("sort3")
			telcateid=rs1("telcateid")
			date1=rs1("daterk")
			ord=rs1("ord")
			ck=rs1("ku")
			ph=rs1("ku_ph")
			xlh=DataSerialNumber(conn ,rs1("kuin"), rs1("kuinlistid"))
			datesc=rs1("datesc")
			dateyx=rs1("dateyx")
			bz=rs1("bz")
			intro=rs1("intro")
			num1=zbcdbl(rs1("num1"))
			AssistNum=zbcdbl(rs1("AssistNum"))
			num2=rs1("ku_num1")
			js=rs1("js")
			unit=rs1("unit")
			cateid=rs1("addcate")
			company=rs1("company")
			rkbh=rs1("rkbh")
			price1=rs1("ku_price1")
			if isnull(price1) then price1=0
			money1=Formatnumber(cdbl(rs1("ku_jc_money1")),num_dot_xs,-1,-1,0)
'if isnull(price1) then price1=0
			if isnull(money1) then money1=0
			price2=rs1("price2")
'if isnull(price2) then price2=0
			money2=rs1("money2")
			if isnull(money2) then money2=0
			rkTitle=rs1("title")
			if isnull(rkTitle) then rkTitle=""
			if isnull(num2) then num2=0
			company=rs1("company")
			cateid=rs1("addcate")
			sumMoney2=cdbl(sumMoney2)+cdbl(money2)
			cateid=rs1("addcate")
			sumMoney=cdbl(sumMoney)+cdbl(money1)
			cateid=rs1("addcate")
			sumNum=cdbl(sumNum)+cdbl(num2)
			cateid=rs1("addcate")
			sumAssistNum=cdbl(sumAssistNum)+cdbl(AssistNum)
			cateid=rs1("addcate")
			rklb=""
			Select Case rs1("sort1").value
			Case 1 : rklb="采购入库"
			Case 2 : rklb="退货入库"
			Case 3 : rklb="退料入库"
			Case 4 : rklb="直接入库"
			Case 5 : rklb="成品入库"
			Case 6 : rklb="还货入库"
			Case 7 : rklb="调拨入库"
			Case 8 : rklb="盘点入库"
			Case 9 : rklb="组装入库"
			Case 10 : rklb="拆分入库"
			Case 11 : rklb="导入入库"
			Case 13 : rklb="半成品入库"
			Case 14 : rklb="成品报废入库"
			Case 15 : rklb="半成品报废入库"
			Case 16 : rklb="废料入库"
			Case Else
			rklb= "其它入库"
			End select
			product=rs1("p_title")
			order1=rs1("order1")
			type1=rs1("type1")
			unitname=rs1("unitname")
			AssistUnitName=rs1("AssistUnitName")
			kuinname=rs1("kuintitle")
			if open_31_1=1 or  open_31_1=3 then
				rukudan=kuinname
			else
				rukudan=""
			end if
			sortname=rs1("bzname")
			ckname=rs1("ckname")
			cateidname=rs1("cateidname")
			companyname1=rs1("telname")
			xsheet.writecell date1
			xsheet.writestr product
			xsheet.writestr order1
			xsheet.writestr type1
			xsheet.writestr unitname
			if isOpenProductAttr then
				xsheet.writestr ProductAttr1
				xsheet.writestr ProductAttr2
			end if
			xsheet.writenumber num2
			if isOpenAssisUnit then
				xsheet.writenumber AssistUnitName
				xsheet.writenumber AssistNum
			end if
			xsheet.writestr ckname
			xsheet.writestr rklb
			xsheet.writestr ph
			xsheet.writestr replace(xlh&"","=","&#61")
			xsheet.writecell datesc
			xsheet.writecell dateyx
			xsheet.writestr sortname
			xsheet.writecell js
			xsheet.writestr rkbh
			xsheet.writestr rkTitle
			xsheet.writestr intro
			xsheet.writestr cateidname
			if hasModels Then
				if(sort3=2)then
				if(ZBRuntime.MC(1002))then
				if open_26_1=3 or CheckPurview(intro_26_1,trim(telcateid))=True then
					xsheet.writestr companyname1
				else
					xsheet.writecell ""
				end if
			else
				xsheet.writecell ""
			end if
		else
			if(ZBRuntime.MC(1000))then
			if open_1_1=3 or CheckPurview(intro_1_1,trim(telcateid))=True then
				xsheet.writestr companyname1
			else
				xsheet.writecell ""
			end if
		else
			xsheet.writecell ""
		end if
	end if
	for j=1 to zdycount
		If arrzdy(0,j) = "zdy5" Or arrzdy(0,j) = "zdy6" Then
			Dim rsz,sqlz,zdyV
			If ISNULL(rs1(arrzdy(0,j))) Or rs1(arrzdy(0,j)) = "" Then
				fieldV = -1
'If ISNULL(rs1(arrzdy(0,j))) Or rs1(arrzdy(0,j)) = "" Then
			else
				fieldV = rs1(arrzdy(0,j))
			end if
			sqlz = "SELECT TOP 1 sort1 FROM sortonehy WHERE id = "&fieldV&" "
			Set rsz = conn.Execute(sqlz)
			If Not rsz.Eof Then
				zdyV = rsz("sort1")
			end if
			rsz.Close
			Set rsz = Nothing
			xsheet.writestr zdyV
		else
			xsheet.writestr rs1(arrzdy(0,j))
		end if
	next
	end if
	currProcV = Clng(i/C1*100)
	If PreProcV < currProcV Then
		Response.write "<script>exportProcBar.showExcelProgress(" & currProcV & "," & C1 & "," & i & ")</script>"
		Response.Flush
		PreProcV = currProcV
	end if
	i=i+1
	PreProcV = currProcV
	rs1.movenext
	xsheet.movenext
	rowIndex = rowIndex + 1
	xsheet.movenext
	If rowIndex > 40000 Then
		If pageCount = 1 then
			xsheet.title = "入库明细表(" & pageCount & "页)"
		end if
		pageCount = pageCount + 1
		xsheet.title = "入库明细表(" & pageCount & "页)"
		Set xsheet = xapp.sheets.add("入库明细表(" & pageCount & "页)")
		rowIndex = 0
		xsheet.showHeader headerStr
		xsheet.movenext
	end if
	loop
	end if
	xsheet.writespace iif(isOpenProductAttr,6,4)
	xsheet.writecell "合计:"
	xsheet.writenumber sumNum
	if isOpenAssisUnit then
		xsheet.writecell ""
		xsheet.writenumber sumAssistNum
	end if
	xsheet.writecell ""
	rs1.close
	set rs1=Nothing
	Response.write "<script>CountImage.style.width='100%';CountTXT.innerHTML=""<font color=red><b>入库明细导出全部完成!</b></font>  100"";CountTXTok.innerHTML=""<B>恭喜!入库明细导出成功,共有"&(i-1)&"条记录!</B>"";</script>"
	set rs1=Nothing
	tfile=Server.MapPath(xApp.cFileName("入库明细表") & ".xls")
	xApp.save tfile
	xApp.dispose
	tfile = xApp.HexEncode(tfile)
	Response.write "<script>exportProcBar.showExcelProgress(100," & C1 & "," & C1 & ")</script>"
	Response.write "<script>exportProcBar.addFileLink({fileUrl:'" & tfile & "',fileName:'入库明细表_"&session("name2006chen")&".xls',fileCnt:1})</script>"
	Set xApp = Nothing
	action1="入库明细表_导出"
	call close_list(1)
	Response.write " " & vbcrlf & "<p align=""center""><a href=""downfile.asp?fileSpec="
	Response.write tfile
	Response.write """><font class=""red""><strong><u>下载导出的入库明细</u></strong></font></a></p> " & vbcrlf & "</BODY>" & vbcrlf & "</HTML>" & vbcrlf & ""
	
%>
