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
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=4"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_4=0
		intro_5_4=0
	else
		open_5_4=rs1("qx_open")
		intro_5_4=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_11=0
		intro_5_11=0
	else
		open_5_11=rs1("qx_open")
		intro_5_11=iif(len(rs1("qx_intro")&"")=0,0,rs1("qx_intro"))
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
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=2"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_2=0
		intro_5_2=0
	else
		open_5_2=rs1("qx_open")
		intro_5_2=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_3=0
		intro_5_3=0
	else
		open_5_3=rs1("qx_open")
		intro_5_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=5"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_5=0
		intro_5_5=0
	else
		open_5_5=rs1("qx_open")
		intro_5_5=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=6"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_6=0
		intro_5_6=0
	else
		open_5_6=rs1("qx_open")
		intro_5_6=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_7=0
		intro_5_7=0
	else
		open_5_7=rs1("qx_open")
		intro_5_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_8=0
		intro_5_8=0
	else
		open_5_8=rs1("qx_open")
		intro_5_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_10=0
		intro_5_10=0
	else
		open_5_10=rs1("qx_open")
		intro_5_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_13=0
		open_5_13=0
	else
		open_5_13=rs1("qx_open")
		intro_5_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=25"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_25=0
		intro_5_25=0
	else
		open_5_25=rs1("qx_open")
		intro_5_25=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=16"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_16=0
		intro_5_16=0
	else
		open_5_16=rs1("qx_open")
		intro_5_16=rs1("qx_intro")
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
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=27"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_27=0
	else
		open_5_27=rs1("qx_open")
	end if
	rs1.close
	set rs1=nothing
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
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=22 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_22_13=0
		intro_22_13=0
	else
		open_22_13=rs1("qx_open")
		intro_22_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=32 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_32_13=0
		intro_32_13=0
	else
		open_32_13=rs1("qx_open")
		intro_32_13=rs1("qx_intro")
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
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=32 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_32_14=0
		intro_32_14=0
	else
		open_32_14=rs1("qx_open")
		intro_32_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=41 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_41_1=0
		intro_41_1=0
	else
		open_41_1=rs1("qx_open")
		intro_41_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=25 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_25_1=0
		intro_25_1=0
	else
		open_25_1=rs1("qx_open")
		intro_25_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
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
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=3 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_3_1=0
		intro_3_1=0
	else
		open_3_1=rs1("qx_open")
		intro_3_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=4 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_4_1=0
		intro_4_1=0
	else
		open_4_1=rs1("qx_open")
		intro_4_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=42 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_42_1=0
		intro_42_1=0
	else
		open_42_1=rs1("qx_open")
		intro_42_1=rs1("qx_intro")
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
	set rs1=nothing
	Dim list_1
	if open_5_1=3 then
		list=""
		list_1="/*p-5-cateid-s*/" & vbcrlf & "1=1" & vbcrlf & "/*pe*/" & vbcrlf
		list=""
	elseif open_5_1=1 then
		list="and cateid<>0 and cateid in ("&intro_5_1&")"
		list_1="/*p-5-cateid-s*/" & vbcrlf & " cateid<>0 and cateid in ("&intro_5_1&")" & vbcrlf  & "/*pe*/" & vbcrlf
		list="and cateid<>0 and cateid in ("&intro_5_1&")"
	else
		list="and 1=0"
		list_1 = "/*p-5-cateid-s*/" & vbcrlf & "1=0" & vbcrlf & "/*pe*/" & vbcrlf
		list="and 1=0"
	end if
	Str_Result=" where del=1 and ((del=1 and " & list_1 & ") or (charindex(',"&session("personzbintel2007")&",',','+replace(cast(share as varchar(8000)),' ','')+',')>0 or share='1')) "
	list="and 1=0"
	Str_Result2=" and del=1 and ((del=1 "&list&" ) or (charindex(',"&session("personzbintel2007")&",',','+replace(cast(share as varchar(8000)),' ','')+',')>0 or share='1')) "
	list="and 1=0"
	
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
	
	Server.ScriptTimeOut=100000000
	Response.write " " & vbcrlf & "<HTML>" & vbcrlf & "<HEAD>" & vbcrlf & "<TITLE>合同资料导出</TITLE>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8""><style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body {" & vbcrlf & "       background-color: #FFFFFF;" & vbcrlf & "      margin-left: 0px;" & vbcrlf & "       margin-top: 0px;" & vbcrlf & " margin-right: 0px;" & vbcrlf & "      margin-bottom: 0px;" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & "</style></HEAD>" & vbcrlf & "<body>" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "  <tr>" & vbcrlf & "<td class=""place"">合同资料导出</td>" & vbcrlf & "    <td>&nbsp;</td>" & vbcrlf & "    <td align=""right"">&nbsp;</td>" & vbcrlf & "    <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "  </tr>" & vbcrlf & "</table> "  & vbcrlf & " <table width=""100%""border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "<tr class=""top"">" & vbcrlf & "  <td colspan=2 class=tablebody1>&nbsp;</td>" & vbcrlf & "</tr>" & vbcrlf & "<tr>" & vbcrlf & "  <td colspan=2 class=tablebody1>" & vbcrlf & "<span id=""CountTXTok"" name=""CountTXTok"" style=""font-size:10pt; color:#008040"">" & vbcrlf & "<B>正在导出合同资料,请稍后...</B></span>" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""1"">" & vbcrlf & "<tr> " & vbcrlf & "<td bgcolor=000000>" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"">" & vbcrlf & "<tr> " & vbcrlf & "<td bgcolor=ffffff height=9><img src=""../images/tiao.jpg"" width=""0"" height=""16"" id=""CountImage"" name=""CountImage"" align=""absmiddle""></td></tr></table>" & vbcrlf & "</td></tr></table> <span id=""CountTXT"" name=""CountTXT"" style=""font-size:9pt; color:#008040"">0</span><span style=""font-size:9pt; color:#008040"">%</span></td></tr>" & vbcrlf & "<tr class=""top"">" & vbcrlf & "  <td colspan=2 class=tablebody1 height=""40"">" & vbcrlf & "  </td>" & vbcrlf & "</tr>" & vbcrlf & "</table>" & vbcrlf & ""
	Response.write Application("sys.info.jsver")
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=5 and sort2=21"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_21=0
	else
		open_5_21=rs1("qx_open")
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
					saledotstr_num=""
					for i=1 to SalesPrice_dot_num
						saledotstr_num=saledotstr_num&"0"
					next
					Set xlApplication = GetExcelApplication()
					xlApplication.Visible = False
					xlApplication.SheetsInNewWorkbook=1
					xlApplication.Workbooks.Add
					Set xlWorksheet = xlApplication.Worksheets(1)
					xlWorksheet.name="sheet1"
					xlApplication.ActiveSheet.Columns(1).ColumnWidth=20
					xlApplication.ActiveSheet.Columns(1).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(2).ColumnWidth=15
					xlApplication.ActiveSheet.Columns(2).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(3).ColumnWidth=20
					xlApplication.ActiveSheet.Columns(3).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(4).ColumnWidth=12
					xlApplication.ActiveSheet.Columns(4).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(4).NumberFormatLocal = "#,##0."&dotstr&"_ "
					xlApplication.ActiveSheet.Columns(5).ColumnWidth=12
					xlApplication.ActiveSheet.Columns(5).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(5).NumberFormatLocal = "#,##0."&dotstr&"_ "
					xlApplication.ActiveSheet.Columns(6).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(6).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(7).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(7).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(8).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(8).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(9).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(9).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(10).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(10).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(11).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(11).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(12).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(12).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(13).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(13).HorizontalAlignment=3
					j0=14
					set rs88=server.CreateObject("adodb.recordset")
					rs88.open "select id,title,name,sort,gl from zdy where sort1=5 and set_open=1 and dc=1 order by gate1 asc ",conn,1,1
					if not rs88.eof then
						do while not rs88.eof
							xlApplication.ActiveSheet.Columns(j0).ColumnWidth=10
							xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
							rs88.movenext
							j0=j0+1
							rs88.movenext
						loop
					end if
					rs88.close
					set rs88=nothing
					xlApplication.ActiveSheet.Columns(j0).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+1).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+1).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+2).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+2).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+3).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+3).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+4).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+4).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+5).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+5).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+6).ColumnWidth=20
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+6).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+7).ColumnWidth=20
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+7).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+8).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+8).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+9).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+9).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+9).NumberFormatLocal = "#,##0."&saledotstr_num&"_ "
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+10).ColumnWidth=10
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+10).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlApplication.ActiveSheet.Columns(j0+10).NumberFormatLocal = "#,##0."&dotstr&"_ "
					xlApplication.ActiveSheet.Columns(j0).HorizontalAlignment=3
					xlWorksheet.Cells(1,1).Value = "合同主题"
					xlWorksheet.Cells(1,1).font.Size=10
					xlWorksheet.Cells(1,1).font.bold=true
					xlWorksheet.Cells(1,2).Value = "合同编号"
					xlWorksheet.Cells(1,2).font.Size=10
					xlWorksheet.Cells(1,2).font.bold=true
					xlWorksheet.Cells(1,3).Value = "客户名称"
					xlWorksheet.Cells(1,3).font.Size=10
					xlWorksheet.Cells(1,3).font.bold=true
					xlWorksheet.Cells(1,4).Value = "合同金额"
					xlWorksheet.Cells(1,4).font.Size=10
					xlWorksheet.Cells(1,4).font.bold=true
					xlWorksheet.Cells(1,5).Value = "到账金额"
					xlWorksheet.Cells(1,5).font.Size=10
					xlWorksheet.Cells(1,5).font.bold=true
					xlWorksheet.Cells(1,6).Value = "币种"
					xlWorksheet.Cells(1,6).font.Size=10
					xlWorksheet.Cells(1,6).font.bold=true
					xlWorksheet.Cells(1,7).Value = "签订日期"
					xlWorksheet.Cells(1,7).font.Size=10
					xlWorksheet.Cells(1,7).font.bold=true
					xlWorksheet.Cells(1,8).Value = "开始日期"
					xlWorksheet.Cells(1,8).font.Size=10
					xlWorksheet.Cells(1,8).font.bold=true
					xlWorksheet.Cells(1,9).Value = "截止日期"
					xlWorksheet.Cells(1,9).font.Size=10
					xlWorksheet.Cells(1,9).font.bold=true
					xlWorksheet.Cells(1,10).Value = "我方代表"
					xlWorksheet.Cells(1,10).font.Size=10
					xlWorksheet.Cells(1,10).font.bold=true
					xlWorksheet.Cells(1,11).Value = "对方代表"
					xlWorksheet.Cells(1,11).font.Size=10
					xlWorksheet.Cells(1,11).font.bold=true
					xlWorksheet.Cells(1,12).Value = "合同分类"
					xlWorksheet.Cells(1,12).font.Size=10
					xlWorksheet.Cells(1,12).font.bold=true
					xlWorksheet.Cells(1,13).Value = "合同状态"
					xlWorksheet.Cells(1,13).font.Size=10
					xlWorksheet.Cells(1,13).font.bold=true
					j1=14
					set rs88=server.CreateObject("adodb.recordset")
					rs88.open "select id,title,name,sort,gl from zdy where sort1=5 and set_open=1 and dc=1 order by gate1 asc ",conn,1,1
					if not rs88.eof then
						do while not rs88.eof
							xlWorksheet.Cells(1,j1).Value = rs88("title")
							xlWorksheet.Cells(1,j1).font.Size=10
							xlWorksheet.Cells(1,j1).font.bold=true
							rs88.movenext
							j1=j1+1
							rs88.movenext
						loop
					end if
					rs88.close
					set rs88=nothing
					xlWorksheet.Cells(1,j1).Value = "合同概要"
					xlWorksheet.Cells(1,j1).font.Size=10
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+1).Value = "洽谈进展"
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+1).font.Size=10
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+1).font.bold=true
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+2).Value = "销售人员"
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+2).font.Size=10
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+2).font.bold=true
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+3).Value = "创建人"
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+3).font.Size=10
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+3).font.bold=true
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+4).Value = "创建时间"
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+4).font.Size=10
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+4).font.bold=true
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+5).Value = "产品名称"
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+5).font.Size=10
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+5).font.bold=true
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+6).Value = "产品编号"
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+6).font.Size=10
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+6).font.bold=true
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+7).Value = "产品型号"
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+7).font.Size=10
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+7).font.bold=true
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+8).Value = "购买数量"
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+8).font.Size=10
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+8).font.bold=true
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+9).Value = "单价"
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+9).font.Size=10
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+9).font.bold=true
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+10).Value = "合计"
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+10).font.Size=10
					xlWorksheet.Cells(1,j1).font.bold=true
					xlWorksheet.Cells(1,j1+10).font.bold=true
					xlWorksheet.Cells(1,j1).font.bold=true
					Response.Flush
					dim W1,W2,W3,A1,A2,B,C,E,F,H
					A1=request("A1")
					A2=request("A2")
					A3=request("A3")
					B=request("B")
					C=Request.QueryString("C")
					D=request("D")
					E=request("E")
					F=request("F")
					H=request("H")
					m1=request("ret")
					m2=request("ret2")
					SH=request("SH")
					sp1=request("sp")
					F1=request("F1")
					F2=request("F2")
					G1=request("G1")
					G2=request("G2")
					P1=request("P1")
					P2=request("P2")
					I1=request("I1")
					I2=request("I2")
					S1=request("S1")
					S2=request("S2")
					ZT=request("ZT")
					ksjs=request("ksjs")
					ksjs2=request("ksjs2")
					if ksjs<>"" and ksjs2<>"" then
						if ksjs="khmc" then
							F1=1
							F2=ksjs2
						elseif ksjs="htzt" then
							G1=1
							G2=ksjs2
						elseif ksjs="htid" then
							P1=1
							P2=ksjs2
						elseif ksjs="htgy" then
							I1=1
							I2=ksjs2
						end if
					end if
					zdy1_1=request("zdy1_1")
					zdy1_2=request("zdy1_2")
					zdy2_1=request("zdy2_1")
					zdy2_2=request("zdy2_2")
					zdy3_1=request("zdy3_1")
					zdy3_2=request("zdy3_2")
					zdy4_1=request("zdy4_1")
					zdy4_2=request("zdy4_2")
					zdy5=request("zdy5")
					zdy6=request("zdy6")
					if sp1<>"" then
						if sp1="1" then
							Str_Result="where del=3 and sp>0 "&list&""
						elseif sp1="2" then
							Str_Result="where del=3 and sp=-1 "&list&""
'elseif sp1="2" then
						elseif sp1="3" then
							Str_Result="where del=3 or del=1 "&list&""
						end if
					else
					end if
					if SH<>"" then
						if SH="1" then
							Str_Result=" where share<>'0' and share<>'-1' and (share='1' or addshare="&session("personzbintel2007")&") "
'if SH="1" then
						elseif SH="2" then
							Str_Result=" where (share='1' or share like '%"&session("personzbintel2007")&"%') "
						end if
					end if
					W1=replace(request("W1")," ","")
					W2=replace(request("W2")," ","")
					W3=replace(request("W3")," ","")
					if W1="" then W1=0
					if W2="" then W2=0
					if W3="" then W3=0
					W3=getW3(W1,W2,W3)
					W4=replace(W3,"0","")
					W4=replace(W4,",","")
					if W4<>"" Then
						tmp=split(getW1W2(W3),";")
						W1=tmp(0)
						W2=tmp(1)
						Str_Result=Str_Result+" and cateid in("& W3 &") and cateid>0 "
						W2=tmp(1)
					end if
					dim HtType,titlename
					dim rebackurl
					HtType=request("HtType")
					if HtType<>"" then
						select case HtType
						case 0
						Str_Result=Str_Result+" and (paybacktype=0 or paybacktype is null)"
'case 0   '
						titlename="销售"
						case 2
						Str_Result=Str_Result+" and paybacktype=1"
'case 2   '
						titlename="直接出库"
						case else
						Str_Result=Str_Result
						end select
					else
						titlename="所有"
						Str_Result=Str_Result
					end if
					area_list=-1
					Str_Result=Str_Result
					if A2<>"" then
						function menuarea(id1)
							set rsarea=server.CreateObject("adodb.recordset")
							sqlarea="select id from menuarea where id1="&id1&" "
							rsarea.open sqlarea,conn,1,1
							if rsarea.eof then
								gateord22=id1
								If Len(area_list) = 0 Then
									area_list = "" & gateord22 & ""
								ElseIf InStr( area_list, gateord22 ) <= 0 Then
									area_list = area_list & ", " & gateord22 & ""
								end if
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
	aryReturn2 = Split(A2,",")
	For i = 0 To UBound(aryReturn2)
		n=0
		set rs=server.CreateObject("adodb.recordset")
		sql="select id from menuarea where id1="&aryReturn2(i)&" "
		rs.open sql,conn,1,1
		if rs.eof then
			n=0
		else
			do until rs.eof
				if  CheckPurview(A2,trim(rs("id")))=True  then
					n=1
				end if
				if n=1 then exit do
				rs.movenext
			loop
		end if
		rs.close
		set rs=nothing
		if n=0 then
			menuarea(aryReturn2(i))
		end if
	next
	end if
	if  A2<>"" then
		Str_Result=Str_Result+"and  area in ("&area_list&")"
'if  A2<>"" then
	end if
	if A1<>"" then
		Str_Result=Str_Result+"and  zt1="&A1&""
'if A1<>"" then
	end if
	if A3<>"" then
		Str_Result=Str_Result+"and  zt2="&A3&""
'if A3<>"" then
	end if
	if D<>"" then
		Str_Result=Str_Result+"and  trade in  ("&D&")"
'if D<>"" then
	end if
	if E<>"" then
		Str_Result=Str_Result+"and  complete1 in  ("&E&")"
'if E<>"" then
	end if
	if F<>"" then
		Str_Result=Str_Result+"and  sort in  ("&F&")"
'if F<>"" then
	end if
	if zdy5<>"" then
		Str_Result=Str_Result+"and  zdy5 in  ("&zdy5&")"
'if zdy5<>"" then
	end if
	if zdy6<>"" then
		Str_Result=Str_Result+"and  zdy6 in  ("&zdy6&")"
'if zdy6<>"" then
	end if
	if F2<>"" then
		if F1=1 then
			str_Result=str_Result+"and company in (select ord from tel where name like '%"& F2 &"%')"
'if F1=1 then
		elseif F1=2 then
			str_Result=str_Result+"and company in (select ord from tel where name not like '%"& F2 &"%')"
'elseif F1=2 then
		elseif F1=3 then
			str_Result=str_Result+"and company in (select ord from tel where name='"&F2&"')"
'elseif F1=3 then
		elseif F1=4 then
			str_Result=str_Result+"and company in (select ord from tel where name<>'"&F2&"')"
'elseif F1=4 then
		elseif F1=5 then
			str_Result=str_Result+"and company in (select ord from tel where name like '"& F2 &"%')"
'elseif F1=5 then
		elseif F1=6 then
			str_Result=str_Result+"and company in (select ord from tel where name like '%"& F2 &"')"
'elseif F1=6 then
		end if
	end if
	if G2<>"" then
		if G1=1 then
			str_Result=str_Result+"and title like '%"& G2 &"%'"
'if G1=1 then
		elseif G1=2 then
			str_Result=str_Result+"and title not like '%"& G2 &"%'"
'elseif G1=2 then
		elseif G1=3 then
			str_Result=str_Result+"and title='"& G2 &"'"
'elseif G1=3 then
		elseif G1=4 then
			str_Result=str_Result+"and title<>'"& G2 &"'"
'elseif G1=4 then
		elseif G1=5 then
			str_Result=str_Result+"and title like '"& G2 &"%'"
'elseif G1=5 then
		elseif G1=6 then
			str_Result=str_Result+"and title like '%"& G2 &"'"
'elseif G1=6 then
		end if
	end if
	if S2<>"" then
		if S1=1 then
			str_Result=str_Result+"and person1 like '%"& S2 &"%'"
'if S1=1 then
		elseif S1=2 then
			str_Result=str_Result+"and person1 not like '%"& S2 &"%'"
'elseif S1=2 then
		elseif S1=3 then
			str_Result=str_Result+"and person1='"& S2 &"'"
'elseif S1=3 then
		elseif S1=4 then
			str_Result=str_Result+"and person1<>'"& S2 &"'"
'elseif S1=4 then
		elseif S1=5 then
			str_Result=str_Result+"and person1 like '"& S2 &"%'"
'elseif S1=5 then
		elseif S1=6 then
			str_Result=str_Result+"and person1 like '%"& S2 &"'"
'elseif S1=6 then
		end if
	end if
	if P2<>"" then
		if P1=1 then
			str_Result=str_Result+"and htid like '%"& P2 &"%'"
'if P1=1 then
		elseif P1=2 then
			str_Result=str_Result+"and htid not like '%"& P2 &"%'"
'elseif P1=2 then
		elseif P1=3 then
			str_Result=str_Result+"and htid='"& P2 &"'"
'elseif P1=3 then
		elseif P1=4 then
			str_Result=str_Result+"and htid<>'"& P2 &"'"
'elseif P1=4 then
		elseif P1=5 then
			str_Result=str_Result+"and htid like '"& P2 &"%'"
'elseif P1=5 then
		elseif P1=6 then
			str_Result=str_Result+"and htid like '%"& P2 &"'"
'elseif P1=6 then
		end if
	end if
	if I2<>"" then
		if I1=1 then
			str_Result=str_Result+"and intro like '%"& I2 &"%'"
'if I1=1 then
		elseif I1=2 then
			str_Result=str_Result+"and intro not like '%"& I2 &"%'"
'elseif I1=2 then
		elseif I1=3 then
			str_Result=str_Result+"and intro like '%"& I2 &"%'"
'elseif I1=3 then
		elseif I1=4 then
			str_Result=str_Result+"and intro not like '%"& I2 &"%'"
'elseif I1=4 then
		elseif I1=5 then
			str_Result=str_Result+"and intro like '"& I2 &"%'"
'elseif I1=5 then
		elseif I1=6 then
			str_Result=str_Result+"and intro like '%"& I2 &"'"
'elseif I1=6 then
		end if
	end if
	if zdy1_2<>"" then
		if zdy1_1=1 then
			str_Result=str_Result+"and zdy1 like '%"& zdy1_2 &"%'"
'if zdy1_1=1 then
		elseif zdy1_1=2 then
			str_Result=str_Result+"and zdy1 not like '%"& zdy1_2 &"%'"
'elseif zdy1_1=2 then
		elseif zdy1_1=3 then
			str_Result=str_Result+"and zdy1='"& zdy1_2 &"'"
'elseif zdy1_1=3 then
		elseif zdy1_1=4 then
			str_Result=str_Result+"and zdy1<>'"& zdy1_2 &"'"
'elseif zdy1_1=4 then
		elseif zdy1_1=5 then
			str_Result=str_Result+"and zdy1 like '"& zdy1_2 &"%'"
'elseif zdy1_1=5 then
		elseif zdy1_1=6 then
			str_Result=str_Result+"and zdy1 like '%"& zdy1_2 &"'"
'elseif zdy1_1=6 then
		end if
	end if
	if zdy2_2<>"" then
		if zdy2_1=1 then
			str_Result=str_Result+"and zdy2 like '%"& zdy2_2 &"%'"
'if zdy2_1=1 then
		elseif zdy2_1=2 then
			str_Result=str_Result+"and zdy2 not like '%"& zdy2_2 &"%'"
'elseif zdy2_1=2 then
		elseif zdy2_1=3 then
			str_Result=str_Result+"and zdy2='"& zdy2_2 &"'"
'elseif zdy2_1=3 then
		elseif zdy2_1=4 then
			str_Result=str_Result+"and zdy2<>'"& zdy2_2 &"'"
'elseif zdy2_1=4 then
		elseif zdy2_1=5 then
			str_Result=str_Result+"and zdy2 like '"& zdy2_2 &"%'"
'elseif zdy2_1=5 then
		elseif zdy2_1=6 then
			str_Result=str_Result+"and zdy2 like '%"& zdy2_2 &"'"
'elseif zdy2_1=6 then
		end if
	end if
	if zdy3_2<>"" then
		if zdy3_1=1 then
			str_Result=str_Result+"and zdy3 like '%"& zdy3_2 &"%'"
'if zdy3_1=1 then
		elseif zdy3_1=2 then
			str_Result=str_Result+"and zdy3 not like '%"& zdy3_2 &"%'"
'elseif zdy3_1=2 then
		elseif zdy3_1=3 then
			str_Result=str_Result+"and zdy3='"& zdy3_2 &"'"
'elseif zdy3_1=3 then
		elseif zdy3_1=4 then
			str_Result=str_Result+"and zdy3<>'"& zdy3_2 &"'"
'elseif zdy3_1=4 then
		elseif zdy3_1=5 then
			str_Result=str_Result+"and zdy3 like '"& zdy3_2 &"%'"
'elseif zdy3_1=5 then
		elseif zdy3_1=6 then
			str_Result=str_Result+"and zdy3 like '%"& zdy3_2 &"'"
'elseif zdy3_1=6 then
		end if
	end if
	if zdy4_2<>"" then
		if zdy4_1=1 then
			str_Result=str_Result+"and zdy4 like '%"& zdy4_2 &"%'"
'if zdy4_1=1 then
		elseif zdy4_1=2 then
			str_Result=str_Result+"and zdy4 not like '%"& zdy4_2 &"%'"
'elseif zdy4_1=2 then
		elseif zdy4_1=3 then
			str_Result=str_Result+"and zdy4='"& zdy4_2 &"'"
'elseif zdy4_1=3 then
		elseif zdy4_1=4 then
			str_Result=str_Result+"and zdy4<>'"& zdy4_2 &"'"
'elseif zdy4_1=4 then
		elseif zdy4_1=5 then
			str_Result=str_Result+"and zdy4 like '"& zdy4_2 &"%'"
'elseif zdy4_1=5 then
		elseif zdy4_1=6 then
			str_Result=str_Result+"and zdy4 like '%"& zdy4_2 &"'"
'elseif zdy4_1=6 then
		end if
	end if
	if m1<>"" then
		Str_Result=Str_Result+"and date3>='"&m1&"' "
'if m1<>"" then
	end if
	if m2<>"" then
		Str_Result=Str_Result+"and date3<='"&m2&"' "
'if m2<>"" then
	end if
	if ZT<>"" then
		if zt="1" then
			Str_Result=Str_Result+" and zt1=1 and zt2=0 and not(num1=num2 and num2>0) "
'if zt="1" then
		elseif zt="2" then
			Str_Result=Str_Result+" and zt1=1 and zt2=0 and (num1=num2 and num2>0) "
'elseif zt="2" then
		elseif zt="8"      then
			Str_Result=Str_Result+" and zt1=2 and zt2=0 and (num1=num2 and num2>0) "
'elseif zt="8"      then
		elseif zt="9"      then
			Str_Result=Str_Result+" and zt1=2 and zt2=1 and (num1=num2 and num2>0) "
'elseif zt="9"      then
		elseif zt="3" then
			Str_Result=Str_Result+" and zt1=2 and zt2=0 and num1>num2 "
'elseif zt="3" then
		elseif zt="4" then
			Str_Result=Str_Result+" and zt1=3 and zt2=0 "
'elseif zt="4" then
		elseif zt="5" then
			Str_Result=Str_Result+" and zt1=2 and zt2=1 and not(num1=num2 and num2>0) "
'elseif zt="5" then
		elseif zt="6" then
			Str_Result=Str_Result+" and zt1=3 and zt2=1 "
'elseif zt="6" then
		elseif zt="7" then
			Str_Result=Str_Result+" and zt1=3 and zt2=2 "
'elseif zt="7" then
		end if
	end if
	currpage=Request("currpage")
	if currpage<="0" or currpage="" then
		currpage=1
	end if
	currpage=clng(currpage)
	lie_1=request.QueryString("lie_1")
	if lie_1="" then
		lie_1=1
	end if
	lie_2=request.QueryString("lie_2")
	if lie_2="" then
		lie_2=1
	end if
	lie_3=request.QueryString("lie_3")
	if ZBRuntime.MC(17000) then
		if lie_3="" then
			lie_3=1
		end if
	else
		if lie_3="" then
			lie_3=2
		end if
	end if
	lie_4=request.QueryString("lie_4")
	if lie_4="" then
		lie_4=1
	end if
	lie_7=request.QueryString("lie_7")
	if lie_7="" then
		lie_7=1
	end if
	page_count=request.QueryString("page_count")
	if page_count="" then
		page_count=10
	end if
	px=request("px")
	if px="" or isnull(px) then
		px="1"
	end if
	if px="1" then
		px_Result="order by date7 desc,ord desc"
	elseif px="2" then
		px_Result="order by date7 asc,ord asc"
	elseif px="3" then
		px_Result="order by title desc"
	elseif px="4" then
		px_Result="order by title asc"
	elseif px="5" then
		px_Result="order by htid desc"
	elseif px="6" then
		px_Result="order by htid asc"
	elseif px="7" then
		px_Result="order by date3 desc,ord desc"
	elseif px="8" then
		px_Result="order by date3 asc,ord asc"
	elseif px="9" then
		px_Result="order by date2 desc,ord desc"
	elseif px="10" then
		px_Result="order by date2 asc,ord asc"
	end if
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=5 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_5_10=0
		intro_5_10=0
	else
		open_5_10=rs1("qx_open")
		intro_5_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	if open_5_10=3 then
		list=""
	elseif open_5_10=1 then
		list=" and cateid in ("&intro_5_10&") and cateid>0 "
	else
		list=" and 1=2 "
	end if
	Str_Result=Str_Result+""&list&""
	list=" and 1=2 "
	set rs=server.CreateObject("adodb.recordset")
	sql="select * from(select *" & _
	",num1=(select isnull(sum(num1),0)  from  contractlist  where contract=contract.ord and del=1)" & _
	",num2=(select isnull(sum(num2),0)  from  contractlist  where contract=contract.ord and del=1)" & _
	" from contract) as t  "&Str_Result&" "&querystr&" "&px_Result&""
	rs.open sql,conn,1,1
	C1=rs.recordcount
	dim i
	i=1
	j=0
	dim title,name,khid,sort1,complete1,jz,ly,area,trade,preson,sex,part1,job,phone,fax,mobile,email,url,address,zip,product,c2,c3,c4,intro,intro2,cateid,date7
	do until rs.eof
		title=rs("title")
		htid=rs("htid")
		bz=rs("bz")
		if bz="" then
			bz=0
		end if
		set rs7=server.CreateObject("adodb.recordset")
		sql7="select intro from sortbz where id="&bz&" "
		rs7.open sql7,conn,1,1
		if rs7.eof then
			sortbz=""
		else
			sortbz=rs7("intro")
			sortbz=sortbz&" "
		end if
		rs7.close
		set rs7=nothing
		set rs7=server.CreateObject("adodb.recordset")
		sql7="select name from tel where ord="&rs("company")&""
		rs7.open sql7,conn,1,1
		if rs7.eof then
			name1=""
		else
			name1=rs7("name")
		end if
		rs7.close
		set rs7=nothing
		money1=zbcdbl(rs("money1"))
		set rs7=server.CreateObject("adodb.recordset")
		sql7="select isnull(sum(money1),0) as money2  from payback where  contract="&rs("ord")&" and complete=3 and del=1 "
		rs7.open sql7,conn,1,1
		if rs7.eof then
			money2=0
		else
			money2=zbcdbl(rs7("money2"))
		end if
		rs7.close
		set rs7=nothing
		money1=Formatnumber(money1,num_dot_xs,-1)
		set rs7=nothing
		money2=Formatnumber(money2,num_dot_xs,-1)
		set rs7=nothing
		date1=rs("date1")
		date2=rs("date2")
		date3=rs("date3")
		person1=rs("person1")
		person2=rs("person2")
		if isnull(person2) then person2 = ""
		if rs("person")<>"" and person2="" then
			set rsobj=server.CreateObject("adodb.recordset")
			sql="select * from person where ord="&rs("person")&" "
			rsobj.open sql,conn,1,1
			if not rsobj.eof then
				person2 = rsobj("name")
			end if
			rsobj.close
			set rsobj = nothing
		end if
		if rs("sort")<>"" then
			set rs7=server.CreateObject("adodb.recordset")
			sql7="select sort1 from sortonehy where ord="&rs("sort")&""
			rs7.open sql7,conn,1,1
			if rs7.eof then
				sort1=""
			else
				sort1=rs7("sort1")
			end if
			rs7.close
			set rs7=nothing
		else
			sort1=""
		end if
		if rs("complete1")<>"" then
			set rs7=server.CreateObject("adodb.recordset")
			sql7="select sort1 from sortonehy where ord="&rs("complete1")&""
			rs7.open sql7,conn,1,1
			if rs7.eof then
				complete1=""
			else
				complete1=rs7("sort1")
			end if
			rs7.close
			set rs7=nothing
		else
			complete1=""
		end if
		if rs("zt1")="0" then
			zt1="未编辑合同明细"
		elseif rs("zt1")="1" then
			zt1="未出库"
		elseif rs("zt1")="2" then
			zt1="部分出库"
		elseif rs("zt1")="3" then
			zt1="出库完毕"
		end if
		if rs("zt2")="0" then
			zt2="未发货"
		elseif rs("zt2")="1" then
			zt2="部分发货"
		elseif rs("zt2")="2" then
			zt2="发货完毕"
		end if
		intro=HTMLDecode(rs("intro"))
		intro2=""
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select intro,date7 from reply  where ord2="&rs("ord")&" and sort1=4 and del=1 order by date7 asc"
		rs1.open sql1,conn,1,1
		if rs1.RecordCount<=0 then
		else
			do until rs1.eof
				intro2=intro2&rs1("date7")&"："&HTMLDecode(rs1("intro"))&"\\\"
				rs1.movenext
				if rs1.eof then exit do
			loop
		end if
		rs1.close
		set rs1=nothing
		if rs("cateid")<>"" then
			set rs7=server.CreateObject("adodb.recordset")
			sql7="select name from gate where ord="&rs("cateid")&""
			rs7.open sql7,conn,1,1
			if rs7.eof then
				cateid=""
			else
				cateid=rs7("name")
			end if
			rs7.close
			set rs7=nothing
		else
			cateid=""
		end if
		if rs("addcate")<>"" then
			set rs7=server.CreateObject("adodb.recordset")
			sql7="select name from gate where ord="&rs("addcate")&""
			rs7.open sql7,conn,1,1
			if rs7.eof then
				addcate=""
			else
				addcate=rs7("name")
			end if
			rs7.close
			set rs7=nothing
		else
			addcate=""
		end if
		date7=rs("date7")
		xlWorksheet.Cells(1+i,1).Value = title
		date7=rs("date7")
		xlWorksheet.Cells(1+i,1).font.Size=10
		date7=rs("date7")
		xlWorksheet.Cells(1+i,1).HorizontalAlignment=1
		date7=rs("date7")
		xlWorksheet.Cells(1+i,2).Value = htid
		date7=rs("date7")
		xlWorksheet.Cells(1+i,2).font.Size=10
		date7=rs("date7")
		xlWorksheet.Cells(1+i,3).Value = name1
		date7=rs("date7")
		xlWorksheet.Cells(1+i,3).font.Size=10
		date7=rs("date7")
		xlWorksheet.Cells(1+i,3).HorizontalAlignment=1
		date7=rs("date7")
		if open_5_21<>0 then
			xlWorksheet.Cells(1+i,4).Value = money1
'if open_5_21<>0 then
		else
			xlWorksheet.Cells(1+i,4).Value = ""
'if open_5_21<>0 then
		end if
		xlWorksheet.Cells(1+i,4).font.Size=10
		if open_5_21<>0 then
'if open_5_21<>0 then
			xlWorksheet.Cells(1+i,5).Value = money2
'if open_5_21<>0 then
		else
			xlWorksheet.Cells(1+i,5).Value = ""
'if open_5_21<>0 then
		end if
		xlWorksheet.Cells(1+i,5).font.Size=10
		if open_5_21<>0 then
'if open_5_21<>0 then
			xlWorksheet.Cells(1+i,6).Value = sortbz
'if open_5_21<>0 then
		else
			xlWorksheet.Cells(1+i,6).Value = ""
'if open_5_21<>0 then
		end if
		xlWorksheet.Cells(1+i,6).font.Size=10
'if open_5_21<>0 then
		xlWorksheet.Cells(1+i,7).Value = date3
'if open_5_21<>0 then
		xlWorksheet.Cells(1+i,7).font.Size=10
'if open_5_21<>0 then
		xlWorksheet.Cells(1+i,8).Value = date1
'if open_5_21<>0 then
		xlWorksheet.Cells(1+i,8).font.Size=10
'if open_5_21<>0 then
		xlWorksheet.Cells(1+i,9).Value = date2
'if open_5_21<>0 then
		xlWorksheet.Cells(1+i,9).font.Size=10
'if open_5_21<>0 then
		xlWorksheet.Cells(1+i,10).Value = person1
'if open_5_21<>0 then
		xlWorksheet.Cells(1+i,10).font.Size=10
'if open_5_21<>0 then
		xlWorksheet.Cells(1+i,11).Value = person2
'if open_5_21<>0 then
		xlWorksheet.Cells(1+i,11).font.Size=10
'if open_5_21<>0 then
		xlWorksheet.Cells(1+i,12).Value = sort1
'if open_5_21<>0 then
		xlWorksheet.Cells(1+i,12).font.Size=10
'if open_5_21<>0 then
		xlWorksheet.Cells(1+i,13).Value = complete1
'if open_5_21<>0 then
		xlWorksheet.Cells(1+i,13).font.Size=10
'if open_5_21<>0 then
		j2=14
		set rs88=server.CreateObject("adodb.recordset")
		rs88.open "select id,title,name,sort,gl from zdy where sort1=5 and set_open=1 and dc=1 order by gate1 asc ",conn,1,1
		if not rs88.eof then
			do while not rs88.eof
				if rs88("sort")=2 then
					xlWorksheet.Cells(1+i,j2).Value = rs(""&rs88("name")&"")
'if rs88("sort")=2 then
				elseif rs88("sort")=1 then
					zdy=rs(""&rs88("name")&"")
					if zdy="" or isnull(zdy) then
						zdy=0
					end if
					set rs77=server.CreateObject("adodb.recordset")
					rs77.open "select sort1 from sortonehy where ord="&zdy&" ",conn,1,1
					if not rs77.eof then
						xlWorksheet.Cells(1+i,j2).Value = rs77("sort1")
'if not rs77.eof then
					else
						xlWorksheet.Cells(1+i,j2).Value = ""
'if not rs77.eof then
					end if
					rs77.close
					set rs77=nothing
				end if
				xlWorksheet.Cells(1+i,j2).font.Size=10
				set rs77=nothing
				rs88.movenext
				j2=j2+1
				rs88.movenext
			loop
		end if
		rs88.close
		set rs88=nothing
		xlWorksheet.Cells(1+i,j2).Value = intro
		set rs88=nothing
		xlWorksheet.Cells(1+i,j2).font.Size=10
		set rs88=nothing
		xlWorksheet.Cells(1+i,j2+1).Value = intro2
		set rs88=nothing
		xlWorksheet.Cells(1+i,j2+1).font.Size=10
		set rs88=nothing
		xlWorksheet.Cells(1+i,j2+2).Value = cateid
		set rs88=nothing
		xlWorksheet.Cells(1+i,j2+2).font.Size=10
		set rs88=nothing
		xlWorksheet.Cells(1+i,j2+3).Value = addcate
		set rs88=nothing
		xlWorksheet.Cells(1+i,j2+3).font.Size=10
		set rs88=nothing
		xlWorksheet.Cells(1+i,j2+4).Value = date7
		set rs88=nothing
		xlWorksheet.Cells(1+i,j2+4).font.Size=10
		set rs88=nothing
		sql1 = "select * from contractlist where contract="&rs("ord")&"  order by id asc"
		set rs1 = server.CreateObject("adodb.recordset")
		rs1.open sql1,conn,1,1
		if rs1.eof then
		else
			do until rs1.eof
				sql6 = "select title,order1,type1 from product where ord="&rs1("ord")&" and del=1"
				set rs6 = server.CreateObject("adodb.recordset")
				rs6.open sql6,conn,1,1
				if rs6.eof then
					product=""
					order1=""
					type1=""
				else
					product=rs6("title")
					order1=rs6("order1")
					type1=rs6("type1")
				end if
				rs6.close
				set rs6=nothing
				num1=zbcdbl(rs1("num1"))
				num2=zbcdbl(rs1("num2"))
				num3=zbcdbl(rs1("num3"))
				num4=zbcdbl(rs1("num4"))
				price1=zbcdbl(rs1("price1"))
				money1=zbcdbl(rs1("money1"))
				i=i+1
				money1=zbcdbl(rs1("money1"))
				xlWorksheet.Cells(1+i,2).Value = "产品明细"
				money1=zbcdbl(rs1("money1"))
				xlWorksheet.Cells(1+i,2).font.Size=10
				money1=zbcdbl(rs1("money1"))
				xlWorksheet.Cells(1+i,j2+5).Value = product
				money1=zbcdbl(rs1("money1"))
				xlWorksheet.Cells(1+i,j2+5).font.Size=10
				money1=zbcdbl(rs1("money1"))
				xlWorksheet.Cells(1+i,j2+5).HorizontalAlignment=1
				money1=zbcdbl(rs1("money1"))
				xlWorksheet.Cells(1+i,j2+6).Value = order1
				money1=zbcdbl(rs1("money1"))
				xlWorksheet.Cells(1+i,j2+6).font.Size=10
				money1=zbcdbl(rs1("money1"))
				xlWorksheet.Cells(1+i,j2+7).Value = type1
				money1=zbcdbl(rs1("money1"))
				xlWorksheet.Cells(1+i,j2+7).font.Size=10
				money1=zbcdbl(rs1("money1"))
				xlWorksheet.Cells(1+i,j2+8).Value = num1
				money1=zbcdbl(rs1("money1"))
				xlApplication.ActiveSheet.Columns(j2+8).NumberFormatLocal = "#,##0."&dotstr_num&"_ "
				money1=zbcdbl(rs1("money1"))
				xlWorksheet.Cells(1+i,j2+8).font.Size=10
				money1=zbcdbl(rs1("money1"))
				if open_5_21<>0 then
					xlWorksheet.Cells(1+i,j2+9).Value = price1
'if open_5_21<>0 then
				else
					xlWorksheet.Cells(1+i,j2+9).Value = ""
'if open_5_21<>0 then
				end if
				xlWorksheet.Cells(1+i,j2+9).font.Size=10
				if open_5_21<>0 then
'if open_5_21<>0 then
					xlWorksheet.Cells(1+i,j2+10).Value = money1
'if open_5_21<>0 then
				else
					xlWorksheet.Cells(1+i,j2+10).Value = ""
'if open_5_21<>0 then
				end if
				xlWorksheet.Cells(1+i,j2+10).font.Size=10
'if open_5_21<>0 then
				rs1.movenext
			loop
		end if
		rs1.close
		set rs1=nothing
		Call ClientClosedExit
		Response.write "<script>CountImage.width=" & Fix((j/C1) * 710) & ";" & VbCrLf
		Response.write "CountTXT.innerHTML=""共有<font color=red><b>"&C1&"</b></font>条数据!导出进度:<font color=red><b>" & Clng(FormatNumber(j/C1*100,4,-1)) & "</b></font>"";" & VbCrLf
		Response.write "<script>CountImage.width=" & Fix((j/C1) * 710) & ";" & VbCrLf
		Response.write "CountImage.title=""正在处理数据,请稍后..."";</script>" & VbCrLf
		Response.Flush
		i=i+1
		Response.Flush
		j=j+1
		Response.Flush
		rs.movenext
	loop
	rs.close
	set rs=Nothing
	Response.write "<script>CountImage.width=710;CountTXT.innerHTML=""<font color=red><b>合同资料导出全部完成!</b></font>  100"";CountTXTok.innerHTML=""<B>恭喜!合同资料导出成功,共有"&j&"条记录!</B>"";</script>"
	Response.write "" & vbcrlf & "</BODY>" & vbcrlf & "</HTML>" & vbcrlf & ""
	Set fs = CreateObject("Scripting.FileSystemObject")
	tfile=Server.MapPath("合同资料_"&session("name2006chen")&".xls")
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
	action1="合同资料导出"
	call close_list(1)
	Response.write " " & vbcrlf & "" & vbcrlf & "" & vbcrlf & "<p align=""center""><a href=""downfile.asp?fileSpec="
	Response.write tfile
	Response.write """><font class=""red""><strong><u>下载导出的合同资料</u></strong></font></a></p> " & vbcrlf & ""
	
%>
