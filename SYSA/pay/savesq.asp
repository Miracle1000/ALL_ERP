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
	
	If request("remind") <> "" Then
		Response.write "" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "try{" & vbcrlf & "       jQuery(function(){" & vbcrlf & "              jQuery('form').each(function(){" & vbcrlf & "                 jQuery('<input type=""hidden"" name=""remind"" value="""
		Response.write Request("remind")
		Response.write """/>').appendTo(this);" & vbcrlf & "               });" & vbcrlf & "     });" & vbcrlf & "}catch(e){}" & vbcrlf & "</script>" & vbcrlf & ""
	end if
	ZBRLibDLLNameSN = "ZBRLib3205"
	Function CreateReminderHelper(ByRef cn,cfgId,subCfgId)
		Dim remind
		Set remind = New Reminder
		Set remind.cn = cn
		Call remind.init(cfgId,subCfgId)
		Set CreateReminderHelper = remind
	end function
	Function CreateReminderHelperByRs(ByRef cn,ByRef rs)
		Dim remind
		Set remind = New Reminder
		Set remind.cn = cn
		Call remind.initByRs(rs)
		Set CreateReminderHelperByRs = remind
	end function
	Dim Global_Power
	Sub InitGlobalPower(ByRef cn)
		Dim sql,rs
		sql = "select a.sort1,a.sort2,isnull(b.qx_open,0) qx_open," &_
		"(case when b.qx_intro is null or datalength(b.qx_intro)=0 then '-255' else b.qx_intro end) qx_intro," &_
		"isnull(a.sort,1) qx_type, " &_
		"from qxlblist a  with(nolock) " &_
		"left join power b  with(nolock) on b.sort1=a.sort1 and b.sort2=a.sort2 and b.ord=" & session("personzbintel2007")
		Set rs = cn.execute(sql)
		If rs.eof = False Then
			Global_Power = rs.getRows()
		end if
		rs.close
		Set rs=Nothing
	end sub
	Class Reminder
		Public cn
		Private configId
		Private base64
		Private power
		Private regEx
		Private uid
		Private actDate
		Private m_subCfgId
		Private m_name
		Private m_setjmId
		Private m_mCondition
		Private m_remindMode
		Private m_qxlb
		Private m_listqx
		Private m_detailqx
		Private m_detailOpen
		Private m_detailIntro
		Private m_moreLinkUrl
		Private m_detailLinkUrl
		Private m_moreLinkUrl_mobile
		Private m_detailLinkUrl_mobile
		Private m_hasModule
		Private m_canCancel
		Private m_jointly
		Private m_num1
		Private m_opened
		Private m_gate1
		Private m_tq1
		Private m_fw1
		Private m_canShow
		Private m_remindCount
		Private m_titleMaxLength
		Private m_subSql
		Private m_lastReloadDate
		Private m_MOrderSetting
		Private m_MBusinessType
		Private m_canTQ
		Private m_fwSetting
		Private m_isMobileMode
		Private m_colCount
		Public displaySqlOnCount
		Public displaySqlOnShow
		Public isCleanMode
		Public dateBegin
		Public pageSize
		Public pageIndex
		Public showStatusField
		Private recCount
		Private pageCount
		Private m_existsPowerIntro
		Private m_expiCount
		Private m_UsingPowerCache
		Private m_cacheHelper
		Private m_cacheExpiredCondition
		Private m_usingLv2Cache
		Private m_hasAltField
		Private Function hasAltField(rs)
			If isEmpty(m_hasAltField) Then
				m_hasAltField = hasFieldInRs(rs,"canCancelAlt")
			end if
			hasAltField = m_hasAltField
		end function
		Public Sub setMobileMode
			m_isMobileMode = True
		end sub
		Public Property Get canCancel
		canCancel = m_canCancel
		End Property
		Public Property Get colCount
		colCount = iif(m_isMobileMode,m_colCount,-1)
'Public Property Get colCount
		End Property
		Public Property Get mobileDetailLinkUrl
		mobileDetailLinkUrl = m_detailLinkUrl_mobile
		End Property
		Private m_hasStatField
		Private Function hasStatField(rs)
			If isEmpty(m_hasStatField) Then
				m_hasStatField = hasFieldInRs(rs,"orderStat")
			end if
			hasStatField = m_hasStatField
		end function
		Private m_hasInfoField
		Private Function hasInfoField(rs)
			If isEmpty(m_hasInfoField) Then
				m_hasInfoField = hasInfoField = hasFieldInRs(rs,"otherInfo")
			end if
			hasInfoField = m_hasInfoField
		end function
		Public Property Get numDigit
		numDigit = cn.execute("select num1 from setjm3  with(nolock) where ord=88")(0)
		End Property
		Public Property Get moneyDigit
		moneyDigit = cn.execute("select num1 from setjm3  with(nolock) where ord=1")(0)
		End Property
		Public Property Get hlDigit
		hlDigit = cn.execute("select num1 from setjm3 with(nolock)  where ord=87")(0)
		End Property
		Public Property Get zkDigit
		zkDigit = cn.execute("select num1 from setjm3  with(nolock) where ord=2014053101")(0)
		End Property
		Public Property Get usingLv2Cache
		usingLv2Cache = m_usingLv2Cache
		End Property
		Public Property Let usingLv2Cache(v)
		m_usingLv2Cache = v
		End Property
		Public Property Get subSql
		subSql = m_subSql
		End Property
		Public Property Get lastReloadDate
		lastReloadDate = m_lastReloadDate
		End Property
		Public Property Get subConfigId
		subConfigId = m_subCfgId
		End Property
		Public Property Get moreLink
		moreLink = moreLinkURL()
		End Property
		Public Property Get num1
		num1 = m_num1
		End Property
		Public Property Let num1(v)
		m_num1 = v
		End Property
		Public Property Get gate1
		gate1 = m_gate1
		End Property
		Public Property Get name
		name = m_name
		End Property
		Public Property Get fw1
		fw1 = m_fw1
		End Property
		Public Property Get tq1
		tq1 = m_tq1
		End Property
		Public Property Get canTQ
		canTQ = m_canTQ
		End Property
		Public Property Get fwSetting
		fwSetting = m_fwSetting
		End Property
		Public Property Get setjmId
		setjmId = m_setjmId
		End Property
		Public Property Get canShow
		If isEmpty(m_canShow) Then
			If m_opened = False And isCleanMode <> True Then
				m_canShow = False
			else
				m_canShow = m_hasModule
			end if
		end if
		canShow = m_canShow
		End Property
		Public Property Get isOpened
		isOpened = m_opened
		End Property
		Public Property Get hasModule
		hasModule = m_hasModule
		End Property
		Private Sub class_initialize
			Set base64 = server.createobject(ZBRLibDLLNameSN &".Base64Class")
			Set power = server.createobject(ZBRLibDLLNameSN &".PowerClass")
			power.PowerCache = True
			uid = session("personzbintel2007")
			If uid = "" Then uid = 0
			actDate = session("timezbintel2007")
			If actDate = "" Then actDate = now
			session("timezbintel2007") = actDate
			Set regEx =New RegExp
			regEx.Pattern = "<[^>]+>"
			Set regEx =New RegExp
			regEx.IgnoreCase = True
			regEx.Global = True
			m_subCfgId = 0
			m_subSql = ""
			isCleanMode = False
			dateBegin = IIf(request.querystring("__dt")="",dateadd("m",-3,date),request.querystring("__dt"))
			isCleanMode = False
			pageSize = IIf(request.querystring("__pageSize")="",10,request.querystring("__pageSize"))
			pageIndex = IIf(request.querystring("__pageIndex")="",1,request.querystring("__pageIndex"))
			pageSize = CLng(pageSize)
			pageIndex = CLng(pageIndex)
			recCount = 0
			pageCount = 0
			displaySqlOnCount = False
			displaySqlOnShow = False
			redim m_existsPowerIntro(0)
			If isEmpty(Global_Power) Then
				m_UsingPowerCache = False
			else
				m_UsingPowerCache = True
			end if
			m_usingLv2Cache = False
			showStatusField = True
			m_isMobileMode = False
		end sub
		Public Function listSQL(mode)
			dim ismobile: ismobile= instr(1,mode & "","mobileplus:",1) = 1
			Dim sql,cateCondition,tmpCondition,qOpen,qIntro,fields,orderBy
			Dim withoutCateCondition,cancelCondition,withoutCancelCondition,i,withoutOrderBy,cancelJoinTable
			mode = replace(mode & "", "mobileplus:", "")
			withoutCateCondition = instr(1,mode,"withoutCateCondition",1) > 0
			withoutCancelCondition = instr(1,mode,"withoutCancelCondition",1) > 0
			withoutOrderBy = InStr(1,mode,"withoutOrderBy",1) > 0
			dim icsql : icsql = ""
			if ismobile then
				icsql = "union select cateid, reminderId from reminderPersonsForMobPush  with(nolock) where cateid=" & uid
			end if
			mode = LCase(Split(mode,"_")(0))
			cancelJoinTable = "left join (" & vbcrlf &_
			"select cateid as isCanceled,reminderId from reminderPersons  with(nolock)  where cateid=" & uid & " " & vbcrlf & icsql & vbcrlf &_
			") __rp on __rp.reminderId=a.id " & vbcrlf
			cancelCondition = " and __rp.isCanceled is null "
			Select Case m_setjmId
			Case 1:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"p.cateid")
			sql = "select COUNT(*) REMIND_CNT from plan1 p with(nolock) "&_
			"where complete='1' and option1<>'1' and "&_
			"(startdate1<'" & dateadd("d",m_tq1,date) & "' or "&_
			"(startdate1='" & dateadd("d",m_tq1,date) & "' and "&_
			"(starttime1<'"&hour(time)&"' or starttime1='"&hour(time)&"'and starttime2<'"&minute(time)&"')"&_
			")"&_
			") [CATECONDITION] [ORDERBY]"
			fields = "ord [id],intro title,case when startdate1 is null then convert(varchar(10),date1,21) + ' ' + time1 + ':' + time2 "&_
			"else convert(varchar(10),startdate1,21) + ' ' + starttime1 + ':" &_
			"datediff(s,'&actDate&"
			orderBy = "order by startdate1 desc,date8 desc "
			Case 2:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " and charindex(',"&uid&",',','+alt+',')<=0 "
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) "&_
			" [CANCELJOINTABLE] " & _
			"inner join learntz b on a.orderId=b.ord and b.del=1 " &_
			" where a.reminderConfig=" & configId & " [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "isnull(b.ord,0) [id],isnull(b.title,'【已删除数据】') title,isnull(convert(varchar(19),b.date7,21),'----') dt,"&_
			"datediff(s,' & actDate & ',isnull(b.date7,'2000-01-01"
'where a.reminderConfig= & configId &  [CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by a.id desc"
			Case 4:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.ecateid")
			cateCondition = cateCondition & " and datediff(d,getdate(),b.stime) <= " & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) "&_
			" [CANCELJOINTABLE] " & _
			"inner join importantMsg b on a.orderId=b.id and b.del=1 AND b.metype = "& m_subCfgId &" " &_
			"left join tel c on b.t_ord=c.ord " & vbcrlf &_
			" where c.del=1 and b.state<>2 and a.reminderConfig=" & configId & " [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],isnull(c.name,'【已删除数据】') title,isnull(convert(varchar(19),b.stime,21),'----') dt,"&_
			" where c.del=1 and b.state<>2 and a.reminderConfig=" & configId & " [CATECONDITION] [CANCELCONDITION] [ORDERBY]" &_
			"case when year(b.stime)<year(getdate()) then -1 else datediff(s,'&actDate&"
'where c.del=1 and b.state<>2 and a.reminderConfig= & configId &  [CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by b.stime desc"
			Case 7:
			Dim nowDays : nowDays = datediff("d",CDate(year(date)&"-01-01"),date)
'Case 7:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			if m_fw1&""="0" then
				if qOpen=3 then
					cateCondition=""
				elseif qOpen=1 then
					cateCondition=cateCondition & " and (tl.cateid in ("&qIntro&") "&_
					"or tl.share='1' "&_
					"or charindex(',"&uid&",',','+tl.share+',')>0) "
'or tl.share='1
				else
					cateCondition=cateCondition & " and (tl.share='1' or charindex(',"&uid&",',','+tl.share+',')>0) "
'or tl.share='1
				end if
			else
				cateCondition=cateCondition & " and tl.cateid="&uid&" or (tl.share='1' or charindex(',"&uid&",',','+tl.share+',')>0) "
'or tl.share='1
			end if
			cateCondition=cateCondition & " and bDays - "&nowDays&" >=0 and bDays - "&nowDays&" <= " & m_tq1 & " " & vbcrlf
'or tl.share='1
			sql = """" & vbcrlf &_
			"select COUNT(*) REMIND_CNT " & vbcrlf &_
			"from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join person p  with(nolock) on a.reminderConfig = 7 and a.orderId=p.ord and p.del=1 and p.sort3=1 and p.bDays >= 0 " & vbcrlf &_
			"left join tel tl on tl.ord = p.company " & vbcrlf &_
			"where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "p.ord [id]," & _
			"case when bDays - "&nowDays&" = 0 then p.name+CHAR(11)+CHAR(12)+'今日生日'" & _
			"else p.name+CHAR(11)+CHAR(12)+'还差'+cast(bDays - &nowDays& as varchar)+'天" &_
			"end as title," & _
			"convert(varchar(10),dateadd(d,p.bDays,'"&year(date)&"-01-01'),121)+'@'+cast(p.birthdayType as varchar) dt," & _
			"-1 as newTag,a.id [rid],tl.cateid "
			orderBy = "order by p.bDays asc"""
			Case 9:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"d.cateid")
			cateCondition = cateCondition & " and datediff(d,getdate(),c.date2)<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join caigoulist c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.id and c.del=1 " & vbcrlf &_
			"inner join caigou d  with(nolock) on d.ord=c.caigou " & vbcrlf &_
			"inner join product b  with(nolock) on b.ord=c.ord " & vbcrlf &_
			"where d.del=1 and isnull(d.status,-1) IN (-1,1) and c.alt=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
'inner join product b  with(nolock) on b.ord=c.ord  & vbcrlf &_
			fields = "c.id [id],d.title+'['+b.title+']' title,convert(varchar(10),c.date2,23) dt,datediff(s,'""&actDate&""',a.inDate) newTag,a.id [rid],c.cateid"""
'inner join product b  with(nolock) on b.ord=c.ord  & vbcrlf &_
			orderBy = "order by c.date2 desc,c.date7 desc"""
			Case 11:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"c.cateid")
			cateCondition = cateCondition & " and datediff(d,getdate(),c.date1)<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join payback c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.ord and c.del=1 and c.complete='1' " & vbcrlf &_
			"left join contract ct  with(nolock) on ct.ord=c.contract " & vbcrlf &_
			"left join sortbz bz  with(nolock) on bz.id=ct.bz " & vbcrlf &_
			"where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "c.ord [id],'@code:""'+isnull(bz.intro,'RMB')+' "" & FormatNumber('+CAST(c.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(10),c.date1,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],c.cateid"
'where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by c.date1 desc,c.date7 desc"
			Case 12:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"c.cateid")
			cateCondition = cateCondition & " and datediff(d,getdate(),c.date1)<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join payout c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.ord and c.del=1 and c.complete='1' " & vbcrlf &_
			"left join (select ord,bz,0 cls from caigou union all select ID as ord,14 bz, 2 cls from M_OutOrder union all select ID as ord,bz, (case isnull(wwType,0) when 0 then 5 when 1 then 4 else 2 end) cls from M2_OutOrder  with(nolock) ) ct on ct.ord=c.contract and ct.cls=isnull(c.cls,0) " & vbcrlf &_
			"left join sortbz bz on bz.id=ct.bz " & vbcrlf &_
			"where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "c.ord [id],'@code:""'+isnull(bz.intro,'RMB')+' "" & FormatNumber('+CAST(c.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(10),c.date1,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],c.cateid"
'where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by c.date1 desc,c.date7 desc"
			Case 21:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1&""="0" Then
				If qOpen = 3 Then
					cateCondition = ""
				ElseIf qOpen=1 Then
					cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
					tmpCondition = " and (cateid is not null and cateid<>0)"
				else
					cateCondition = " and 1=2"
				end if
			else
				cateCondition = " and cateid=" & uid
			end if
			cateCondition = " and ("&_
			"(1=1"&cateCondition&") or charindex(',"&uid&",',','+replace(cast(share as varchar(8000)),' ','')+',')>0 or share='1'"&_
			"cateCondition = "" and ("""&_
			") " & tmpCondition & vbcrlf
			cateCondition = cateCondition & " and datediff(d,getdate(),b.date2)<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join contract b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 and isnull(b.status,-1) in (-1,1)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title,convert(varchar(10),b.date2,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date2 desc,b.date7 desc"
			Case 22:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				tmpCondition = ""
			ElseIf qOpen=1 Then
				tmpCondition = " and addcate in ("&qIntro&") "
			else
				tmpCondition = " and 1=2"
			end if
			If m_fw1&""="0" Then
				cateCondition = tmpCondition & " and isnull(catelead,0) > 0 "
			else
				cateCondition = tmpCondition & " and catelead=" & uid
			end if
			sql="select COUNT(*) REMIND_CNT from tousu  with(nolock) where del=1 [CATECONDITION] and result1=0 [ORDERBY]"
			fields = "ord [id],title,date1 dt,datediff(s,'" & actDate & "',isnull(date7,'2000-01-01')) newTag,0 [rid],addcate cateid"
			sql="select COUNT(*) REMIND_CNT from tousu  with(nolock) where del=1 [CATECONDITION] and result1=0 [ORDERBY]"
			orderBy = "order by date1 desc,date7 desc"
			Case 23:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " and datediff(d,getdate(),c.date2)<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join contractlist c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.id and c.del=1 " & vbcrlf &_
			"inner join contract b  with(nolock) on b.ord=c.contract and b.del=1 and isnull(b.status,-1) in (-1,1)  " & vbcrlf &_
			"left join product p  with(nolock) on p.ord=c.ord and p.del=1 " & vbcrlf &_
			"where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "c.id [id],b.title+'['+isnull(p.title,'产品被删除')+']' title,convert(varchar(10),c.date2,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
'where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by c.date2 desc,c.date7 desc"
			Case 39:
			cateCondition = "and learnhd.cateid="&uid
			sql="SELECT COUNT(*) REMIND_CNT FROM replyhd  with(nolock) "&_
			"LEFT JOIN learnhd  with(nolock) ON replyhd.ord = learnhd.ord "&_
			"where learnhd.del=1 and replyhd.alt=1 [CATECONDITION] [ORDERBY]"
			fields = "replyhd.id as [id],learnhd.title as title,replyhd.date7 as dt,-1 newTag,0 [rid],learnhd.cateid as cateid,learnhd.ord as ord"
'where learnhd.del=1 and replyhd.alt=1 [CATECONDITION] [ORDERBY]
			orderBy = "order by replyhd.date7 desc"
			Case 68:
			cateCondition = "and CHARINDEX(',"&uid&",',','+c.RemindPerson+',')>0 " & vbcrlf &_
			"AND daysFromNow <=  & (m_tq1 * 24)"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join ku b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"inner join product c  with(nolock) on c.ord=b.ord " & vbcrlf &_
			"inner join sortck ck  with(nolock) on b.ck=ck.ord and ck.del=1 " &_
			"IIf(withoutCateCondition,"""",""and (cast(ck.intro as varchar(10))='0' "&_
			"or CHARINDEX(',&uid&,',','+cast(ck.intro as varchar(4000))+'," &_
			"IIf(withoutCateCondition,"""",""and (cast(ck.intro as varchar(10))='0' "&_
			"where isnull(b.locked,0)=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],c.title,"&_
			"CONVERT(varchar(10),dateadd(hh,a.daysFromNow,'"&date&"'),23) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],0 cateid"
			orderBy = "ORDER BY dt DESC,id DESC"
			Case 74:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and creator in ("&qIntro&") "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & " AND cateid=" & uid
			sql="SELECT COUNT(*) REMIND_CNT FROM sale_proposal  with(nolock) WHERE ISNULL(alt,0) = 0 AND del = 0 [CATECONDITION] [ORDERBY]"
			fields = "[id],title,ServerTime dt,datediff(s,'" & actDate & "',isnull(ServerTime,'2000-01-01')) newTag,0 [rid],ISNULL(creator,0) cateid"
			orderBy = "ORDER BY ServerTime DESC,id DESC"
			Case 73:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and cateid in ("&qIntro&") "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition &  "AND NextOperator=" & uid &" "& cateCondition
			sql="SELECT COUNT(*) REMIND_CNT FROM sale_Complaints  with(nolock) WHERE del=0 and ISNULL(alt,0) = 0 [CATECONDITION] [ORDERBY]"
			fields = "[id],title,ServerTime dt,datediff(s,'" & actDate & "',isnull(ServerTime,'2000-01-01')) newTag,0 [rid],ISNULL(cateid,0) cateid"
			orderBy = "ORDER BY ServerTime DESC,id DESC"
			Case 72:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and cateid in ("&qIntro&") "
			else
				cateCondition = " and 1=2"
			end if
			sql="SELECT COUNT(*) REMIND_CNT FROM Sale_CallBack  with(nolock) where Del=1 and cateid=" & uid &_
			" and dbo.dateDiffByDay(ybackTime,2,0,"& m_tq1 &",GETDATE())>=0 and isback=0 and isnull(setalt,0)=0 "& cateCondition & " [ORDERBY]"
			fields = "[id],title,CONVERT(varchar, ybackTime,20) dt,-1 newTag,0 [rid],cateid"
			orderBy = "ORDER BY ServerTime DESC,id DESC"
			Case 100:
			sql = "select COUNT(*) REMIND_CNT from notebook with(nolock)  "&_
			"where (del=1 or del is null) and alt=0 and complete<>2 and cateid =" & uid &_
			"and datediff(d,getdate(),date7) <= " & m_tq1 & " [ORDERBY]"
			fields = "ord [id],'@code:htmldecode(rs(""real_title""))' title,convert(varchar,date7,120) dt,-1 newTag,0 [rid],cateid,cast(intro as varchar(8000)) real_title" &_
			"and datediff(d,getdate(),date7) <= " & m_tq1 & " [ORDERBY]"
			orderBy = "order by date7 desc"
			Case 101:
			sql = "    select COUNT(*) REMIND_CNT "&_
			"from learn  with(nolock) where (cateid=" & uid & " or CHARINDEX('," & uid & ",' , ','+share+',') > 0 or share = '1') " &_
			"and CHARINDEX(',&uid&,',','+alt+',"
			fields = "[id],title,convert(varchar,date7,120) dt,-1 newTag,0 [rid],cateid"
'sql = "    select COUNT(*) REMIND_CNT "&_
			orderBy = "order by date7 desc"
			Case 102:
			cateCondition = getCondition(m_qxlb,m_listqx,"a.AddUser")
			sql= "SELECT COUNT(*) REMIND_CNT " & vbcrlf &_
			"FROM RepairOrder a  with(nolock) left join ( " &_
			"select id,title from Comm_ProcessSet  with(nolock) where type=1 " &_
			") b on b.id = a.ProcessID  where a.id in( "& vbcrlf &_
			"select a.id FROM RepairOrder a  with(nolock) " & vbcrlf &_
			"left join ( " & vbcrlf &_
			"select id,title from Comm_ProcessSet  with(nolock) where type=1 " & vbcrlf &_
			") b on b.id = a.ProcessID " & vbcrlf &_
			"left join ( " & vbcrlf &_
			"SELECT distinct a.RepairOrder,a.ProcessID,a.DealPerson,ActualBeginTime,NodeID FROM RepairDeal a  with(nolock) " & vbcrlf &_
			"LEFT JOIN Copy_ProcessNodeSet b with(nolock)  ON b.ID = a.NodeID AND b.del = 1 " & vbcrlf &_
			"WHERE a.del = 1 AND a.CurrentStatus = 0 " & vbcrlf &_
			") c on c.RepairOrder=a.id and c.ProcessID=a.ProcessID " & vbcrlf &_
			"WHERE a.del = 1 " & vbcrlf &_
			"and (a.Status = 0 or a.Status = 1) " & vbcrlf &_
			"and isnull(c.DealPerson,a.DealPerson) = " & uid &" "&_
			"and datediff(d,getdate(),isnull(c.ActualBeginTime,'1900-01-01'))<= " & m_tq1 & " " &_
			"and isnull(c.DealPerson,a.DealPerson) = " & uid &" "&_
			"cateCondition & "") [ORDERBY]"""
			fields = "a.[id],b.title+'['+a.Title+']' title,convert(varchar,a.addTime,120) dt,-1 newTag,0 [rid],a.AddUser cateid"
'cateCondition & ") [ORDERBY]"
			orderBy = "order by a.addTime desc"
			Case 103:
			cateCondition = getCondition(m_qxlb,m_listqx,"MainExecutor")
			sql = "select COUNT(*) REMIND_CNT from (" & vbcrlf &_
			"select a.id,c.title+'['+b.name+']' title,convert(varchar,BeginTimePlan,120) dt,"& vbcrlf &_
			"a.BeginTimePlan,MainExecutor from ChanceProcRunLogs a  with(nolock) " & vbcrlf &_
			"inner join chanceProcNodesBak b  with(nolock) on a.ProcNodesBak = b.id " & vbcrlf &_
			"inner join chance c  with(nolock) on c.ord=a.chance AND c.del = 1 " & vbcrlf &_
			"where " & vbcrlf & _
			"(" & vbcrlf &_
			"(a.Status=0 and MainExecutor="&uid&")" & vbcrlf &_
			" or " & vbcrlf & _
			"(" & vbcrlf & _
			"(a.Status=1 or a.Status=9) " & vbcrlf &_
			" and " & vbcrlf &_
			"(MainExecutor="&uid&" or charindex(',"&uid&",',','+a.Executors+',')>0) " & vbcrlf &_
			" and " & vbcrlf &_
			")" & vbcrlf & _
			")" & vbcrlf &_
			" and datediff(d,getdate(),BeginTimePlan)<="& m_tq1&" " & cateCondition & vbcrlf &_
			") a [ORDERBY]"
			fields = "[id],title,dt,-1 newTag,0 [rid],MainExecutor cateid"
') a [ORDERBY]
			orderBy = "order by BeginTimePlan desc"
			Case 216:
			Dim sort46Open,sort47Open,rs_setting
			Set rs_setting = cn.execute("select intro from setopen  with(nolock) where sort1=46 union all select 0")
			sort46Open = rs_setting("intro")
			rs_setting.close
			Set rs_setting = cn.execute("select intro from setopen  with(nolock) where sort1=47 union all select 0")
			sort47Open = rs_setting("intro")
			rs_setting.close
			Set rs_setting = Nothing
			Call fillinPower(1,18,qOpen,qIntro)
			qIntro = IIF(qIntro&""="","0",qIntro)
			if sort46Open<>0 and sort46Open<>"" then
				if qOpen = 1 then
					if sort46Open = 1 then
						if sort47Open = 1 then
							cateCondition = cateCondition & " and (order1<>2 and (cateadd in("& qIntro &"))) "
						elseif sort47Open = 2 then
							cateCondition = cateCondition & " and (order1<>2 and (cateidgq in("& qIntro &"))) "
						else
							cateCondition = cateCondition & " and (order1<>2 and (cateidgq in("& qIntro &") or cateadd in("& qIntro &"))) "
						end if
					elseif sort46Open=2 then
						if sort47Open=1 then
							cateCondition = cateCondition & " and (cateadd in("& qIntro &")) "
						elseif sort47Open = 2 then
							cateCondition = cateCondition & " and (cateidgq in("& qIntro &")) "
						elseif sort47Open = 3 then
							cateCondition = cateCondition & " and (cateid in("& qIntro &")) "
						else
							cateCondition = cateCondition & " and (cateidgq in("& qIntro &") or cateadd in(" & qIntro & ")) "
						end if
					end if
				ElseIf qOpen <> 3 And qOpen & "" <> "" Then
					cateCondition = cateCondition & " and 1=2 "
				end if
			end if
			Call fillinPower(1,6,qOpen,qIntro)
			tmpCondition = "" & _
			" AND (" & vbcrlf &_
			"(" & vbcrlf &_
			"order1 = 3 and (" & vbcrlf &_
			"qOpen & ""=3 or ("" & qOpen & ""=1 and charindex(','+cast(b.cateid4 as varchar)+',',',"" & qIntro & "",')>0)" & vbcrlf &_
			")" & vbcrlf &_
			") " & vbcrlf &_
			"OR (isnull(order1,0) = 0  AND cateid4 = "& uid &" )" & vbcrlf &_
			") "
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & tmpCondition & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN order1 <> 3 THEN 1 ELSE 0 END) canCancelAlt," & vbcrlf &_
			"(case WHEN order1 = 3 then 10 else 12 end) orderStat"
			orderBy = "order by a.inDate desc,b.ord desc"
			Case 104:
			cateCondition = " AND (charindex(',"&uid&",',','+b.share+',')>0 or share='1') "
'Case 104:
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name title,convert(varchar(19),b.date1,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by a.inDate desc,b.ord desc"
			Case 54:
			cateCondition = " AND (CHARINDEX(',"&uid&",',','+b.share+',')>0 OR share='1') "
'Case 54:
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN chance b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),b.date1,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 201:
			cateCondition = " AND (CHARINDEX(',"&uid&",',','+b.share+',')>0 OR share='1') "
'Case 201:
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN contract b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(10),b.date3,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 202:
			cateCondition = " AND (CHARINDEX(',"&uid&",',','+b.share+',')>0 OR share='1') "
'Case 202:
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN tousu b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),b.date7,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate [cateid]"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 203:
			Dim workPosition : workPosition = cn.execute("SELECT workPosition FROM gate WHERE ord = "& uid)(0).value
			cateCondition = " AND (CHARINDEX(',"&uid&",',','+cast(b.share1 as varchar(8000))+',')>0 OR CHARINDEX(',"&uid&",',','+cast(b.share2 as varchar(8000))+',')>0 OR CHARINDEX(',"&workPosition&",',','+cast(b.postView as varchar(8000))+',')>0 OR CHARINDEX(',"&workPosition&",',','+cast(b.postDown as varchar(8000))+',')>0) "
'Dim workPosition : workPosition = cn.execute("SELECT workPosition FROM gate WHERE ord = "& uid)(0).value
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN document b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del=1 AND (b.sp = 0 AND b.cateid_sp = 0)" & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(19),b.date7,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate [cateid]"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 64:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND sp > 0) OR (cateid_sp = 0  AND ((ISNULL(cateid,0) = 0 AND addcate = " & uid & ") or (ISNULL(cateid,0) > 0 AND cateid = " & uid & ")))) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN chance b ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3)  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid, " &_
			"(CASE WHEN (cateid_sp = 0 OR sp < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case sp when -1 then 12 when 0 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 53:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateadd")
			cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND sp > 0) OR (cateid_sp = "& uid &" AND sp=-1) OR (cateid_sp = 0  AND cateadd = "& uid &" )) "
'cateCondition = getCondition(m_qxlb,m_listqx,"b.cateadd")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN (cateid_sp = 0 OR sp < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case when sp<0 then 15 when cateid_sp = 0 then 14 else 13 end) orderStat"
			orderBy = "order by a.inDate desc,b.ord desc"
			Case 13:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND b.ord in ( SELECT mr.ord FROM dbo.price mr  with(nolock)   "&_
			"   inner join sp_ApprovalInstance c  with(nolock) on c.gate2=13001 and c.PrimaryKeyID = mr.ord and c.BillPattern in (0,1)  "&_
			"   WHERE mr.del<>2 and ((mr.status in (-1,0,1) and isnull(mr.Cateid,mr.Addcate) =" & uid &") "&_
			"   or (mr.status in (2,4,5) and charindex('," & uid &",',','+ c.SurplusApprover +',')>0))) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN price b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) " & vbcrlf &_
			"inner join sp_ApprovalInstance c on c.gate2=13001 and c.PrimaryKeyID = b.ord and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(case when c.ApprovalFlowStatus in (-1,0,1,3) then 1 else 0 end) canCancelAlt," &_
			"(case status when 0 then 16 when 4 then 10 when 5 then 8 when 2 then 12 else 11 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 14:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND b.ord in ( SELECT mr.ord FROM dbo.contract mr  with(nolock)   "&_
			"   inner join sp_ApprovalInstance c  with(nolock) on c.gate2=11001 and c.PrimaryKeyID = mr.ord and c.BillPattern in (0,1)  "&_
			"   WHERE mr.del<>2 and ((mr.status in (-1,0,1) and case when isnull(mr.Cateid,0)>0 then mr.Cateid else mr.Addcate end =" & uid &") "&_
			"   or (mr.status in (2,4,5) and charindex('," & uid &",',','+ c.SurplusApprover +',')>0))) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN contract b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) "&vbcrlf &_
			"inner join sp_ApprovalInstance c on c.gate2=11001 and c.PrimaryKeyID = b.ord and c.BillPattern in (0,1) " &_
			"WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(case when c.ApprovalFlowStatus in (-1,0,1,3) then 1 else 0 end) canCancelAlt," &_
			"(case status when 0 then 16 when 4 then 10 when 5 then 8 when 2 then 12 else 11 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 69:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND sp > 0) OR (cateid_sp = 0  AND addcate = " & uid & "))  "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN contractth b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN (cateid_sp = 0 OR sp < 0) THEN 1 ELSE 0 END) canCancelAlt, " &_
			"(case sp when -1 then 12 when 0 then 11 else 10 end) orderStat" &_
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 16:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN caigou b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) "&_
			"inner join sp_ApprovalInstance c on c.gate2=73001 and c.PrimaryKeyID = b.ord and c.BillPattern in (0,1) " &_
			"WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			" 0 canCancelAlt,(case b.status when -1 then 17 when 0 then 16 when 1 then 11 when 2 then 12 when 3 then 9 when 4 then 10 when 5 then 8 else 10 end)  orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 60:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND ( (kg = "& uid &" AND complete1 = 1 and isnull(b.status,-1) in (-1,1)) OR (complete1 > 1  AND cateid = "& uid &" ) ) "
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN kuin b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del = 1 WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN (kg = 0 OR complete1 IN (2,3)) THEN 1 ELSE 0 END) canCancelAlt, " &_
			"(case isnull(status,-1) when 1 then 11 else 17 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 61001:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join kuin b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c on c.gate2=61001 and c.PrimaryKeyID = b.ord and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title,b.date7 dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.date7 desc"
			Case 62001:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join kuout b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=62001 and c.PrimaryKeyID = b.ord and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title,b.date7 dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.date7 desc"
			Case 23701:
			DIM MCYG,MCBJ
			MCYG=FALSE
			MCBJ=FALSE
			if ZBRuntime.MC(14000) then
				MCYG=TRUE
			end if
			if ZBRuntime.MC(4000) then
				MCBJ=TRUE
			end if
			sql ="select COUNT(*) REMIND_CNT from"& _
			"("& _
			"select A.id,A.cateid,1 ismode,title,date1,date7  from"& _
			"("& _
			"select "& _
			"cai.id,count(c.id) cid,count(x.id)xid,cai.date7,cai.date1,cai.title,cai.cateid "& _
			"from caigou_yg cai  with(nolock)  "& _
			"inner join caigoulist_yg c  with(nolock) on  cai.id=c.caigou "& _
			"left join xunjialist x  with(nolock) on c.id=x.caigoulist_yg and x.caigoulist_yg>0 and x.del=1 "& _
			"left join xunjia xu  with(nolock) on xu.id=x.xunjia and xu.fromtype<>0 "&_
			"left join gate g  with(nolock) on g.ord=cai.cateid  "& _
			"left join power p  with(nolock) on p.ord="&uid&" and p.sort1=25 and p.sort2=1"&_
			"                                 ""where  cai.del=1 and cai.status=0  AND '""&MCYG&""'='TRUE'   and ISNULL(cai.xunjia,0)=0 and needxj=1 and (p.qx_open=3 or  CHARINDEX(','+CAST(cai.cateid AS VARCHAR(20))+',',','+CAST(p.qx_intro AS VARCHAR(8000))+',') > 0) GROUP BY cai.id,cai.date7,cai.date1,cai.title,g.name,cai.cateid,cai.ygid " & _
			")A WHERE (A.cid>0 AND xid=0) or(A.cid>0 And xid>0 And xid<A.cid)  "& _
			"union all  "& _
			"select p.ord,p.cateid cateid,0 ismode,p.title,p.date1,p.date7 from price p  with(nolock) "& _
			"left join gate gg  with(nolock) on gg.ord=p.addcate "& _
			" left join power po  with(nolock) on po.ord="&uid&" and po.sort1=4 and po.sort2=1"&_
			"where (p.complete=1 or p.complete=8) and p.del=1 AND '"&MCBJ&"'='TRUE' and p.xj=1 and  exists(select 1 from pricelist  with(nolock) where price =p.ord AND xunjiastatus!=1)"&_
			"AND NOT exists(select 1 from xunjialist a  with(nolock)  "&_
			"inner join xunjia b  with(nolock) on a.xunjia=b.id and b.del=1 "&_
			"INNER join tel c on a.gys=c.ord and c.sort3=2 "&_
			"where b.price=p.ord)"&_
			" and (po.qx_open=3 or CHARINDEX(','+CAST(p.cateid AS VARCHAR(20))+',',','+CAST(po.qx_intro AS VARCHAR(8000))+',') > 0)"& _
			"where b.price=p.ord)"&_
			")C left join power pow on pow.ord= "&uid&"  and pow.sort1=24 and pow.sort2=13    WHERE (pow.qx_open=3 or CHARINDEX(','+CAST(C.cateid AS VARCHAR(20))+',',','+CAST(pow.qx_intro AS VARCHAR(8000))+',') > 0) AND 1=1"& _
			"where b.price=p.ord)"&_
			"[ORDERBY]"
			fields = "C.id [id],(case when C.ismode=1 THEN '来自预购:'+ C.title else '来自报价:'+ C.title end) title,0 [rid],C.cateid,-1 newTag, CAST(CONVERT(varchar(10), C.date1 , 120)as datetime)  dt"
'[ORDERBY]
			orderBy = "ORDER BY C.date7 DESC"
			Case 61:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND ( (kg = "& uid &" AND complete1 = 1 and isnull(b.status,-1) in (-1,1)) ) "
'cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN kuout b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del = 1 WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN (kg = 0 OR complete1 IN (2,3)) THEN 1 ELSE 0 END) canCancelAlt, " &_
			"(case isnull(status,-1) when 1 then 11 else 17 end) orderStat"
'(CASE WHEN (kg = 0 OR complete1 IN (2,3)) THEN 1 ELSE 0 END) canCancelAlt,  &_
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 62:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND ( ("& iif(openPower(33,16) > 0,"1=1","1=2") &" AND complete1 = 0) OR (complete1 = 1  AND cateid = "& uid &" ) ) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN send b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN (addcate = 0 OR complete1 = 1) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case complete1 when 0 then 10 when 1 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 50:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.Creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN payoutsure b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ID AND b.del = 1  " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=44011 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ID DESC"
			Case 43012:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.Creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.Creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.Creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN PaybackInvoiceSure b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ID AND b.del = 1  " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=43012 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ID DESC"
			Case 44012:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.Creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.Creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.Creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN PayoutInvoiceSure b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ID AND b.del = 1  " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=44012 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ID DESC"
			Case 65:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN bankin2 b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) " & vbcrlf &_
			" inner join sp_ApprovalInstance c on c.gate2=43001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			" WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],cast(b.title as varchar(8000)) title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN (cateid_sp = 0 OR sp < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case status_sp when 2 then 12 when 1 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 206:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN bankout2 b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) " & vbcrlf &_
			" inner join sp_ApprovalInstance c  with(nolock) on c.gate2=44001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			" WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],cast(b.title as varchar(8000)) title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator as cateid,"&_
			"(CASE WHEN (ISNULL(cateid_sp,0) = 0 OR ISNULL(sp,0) < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case status_sp when 2 then 12 when 1 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 205:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.addcate")
			cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND complete = 2) OR (complete = 3  AND addcate = "& uid &" )) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN caigouQC b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del = 1 WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate [cateid],"&_
			"(CASE WHEN (cateid_sp = 0 OR complete < 0 OR complete = 3) THEN 1 ELSE 0 END) canCancelAlt, " &_
			"(case complete when -1 then 12 when 3 then 11 else 10 end) orderStat"
'(CASE WHEN (cateid_sp = 0 OR complete < 0 OR complete = 3) THEN 1 ELSE 0 END) canCancelAlt,  &_
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 40:
			cateCondition = getCondition(m_qxlb,m_listqx,"addcateid")
			cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND complete not in (1,3)) OR (complete in (1,3) AND addcateid = "& uid &" )) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN paysq b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcateid [cateid],"&_
			"(CASE WHEN complete in (1,3) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case complete when 3 then 12 when 1 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 41:
			cateCondition = getCondition(m_qxlb,m_listqx,"cateid")
			cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND complete not in (2,3)) OR (complete in (2,3) AND cateid = "& uid &" )) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN paybx b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid [cateid],"&_
			"(CASE WHEN (cateid_sp = 0 OR sp_id < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case complete when 2 then 12 when 3 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 42:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.sorce2")
			cateCondition = cateCondition & " AND ((isnull(gate_sp,0) = "& uid &" AND sp_id > 0) OR (isnull(sp_id,0) = 0  AND sorce2 = "& uid &" )) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN payjk b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.sorce2 [cateid],"&_
			"(CASE WHEN (isnull(gate_sp,0) = 0 OR sp_id < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case sp_id when -1 then 12 when 0 then 11 else 10 end) orderStat"
'(CASE WHEN (isnull(gate_sp,0) = 0 OR sp_id < 0) THEN 1 ELSE 0 END) canCancelAlt, &_
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"""
			Case 43:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND complete IN (7,11)) OR ((complete = 8 OR complete = 12)  AND addcate = "& uid &" )) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN pay b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"(CASE WHEN (cateid_sp = 0 OR complete = 8 OR complete = 12) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case complete when 12 then 12 when 8 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 71:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_NeedPerson b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(19),b.indate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 44:
			cateCondition = getCondition(m_qxlb,m_listqx,"c.use_cateid")
			cateCondition = cateCondition &" AND d.send_cateid = "& uid &" "
			sql = "SELECT COUNT(*) REMIND_CNT FROM (" & vbcrlf &_
			"select distinct b.id [id],c.use_title title,convert(varchar(19),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,b.id [rid],c.use_cateid [cateid],a.inDate,c.id cid " & vbcrlf &_
			"from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN O_MeetingSummary b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id " & vbcrlf &_
			"INNER JOIN O_MeetingUse c  with(nolock) ON c.id = b.sum_metId " & vbcrlf &_
			"INNER JOIN O_SummarySend d  with(nolock) ON d.send_meetingid = b.id " & vbcrlf &_
			"WHERE 1 = 1 AND d.send_type = 1 AND d.send_issucceed = 1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] "&vbcrlf &_
			") bbb [ORDERBY]"
			fields = "[id],title,dt,newTag,[rid],[cateid],inDate,cid"
			orderBy = "ORDER BY inDate DESC,cid DESC"
			Case 56:
			tmpCondition = ""
			If m_fw1&""="0" Then
				tmpCondition = ""
			else
				tmpCondition = " and c.cateid=" & uid & " "
			end if
			cateCondition = "and (" & vbcrlf
			Call fillinPower(1,5,qOpen,qIntro)
			cateCondition = cateCondition & " ( c.sort1=1 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(2,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=8 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(3,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=2 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(4,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=3 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(5,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=4 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(22,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=5 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(41,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=6 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(42,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=7 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(75,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=75 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(95,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=102001 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(96,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( c.sort1=102002 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			cateCondition = cateCondition & " ) "
			cateCondition = " and (( 1=1 " & tmpCondition & " " & cateCondition & ") or c.share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(c.share as varchar(8000)),' ','')+',')>0)" & vbcrlf
			cateCondition = cateCondition & " ) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN dianping b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id " &_
			"INNER JOIN reply c  with(nolock) ON c.id = b.ord " &_
			"LEFT JOIN tel d  with(nolock) ON d.ord = c.ord " &_
			"WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.intro title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],0 [cateid]"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 57:
			cateCondition = " AND isnull(order1,0) = "& uid &" "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN plan1 b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord WHERE b.complete='2' " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.intro title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],0 [cateid]"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 58:
			cateCondition = " AND isnull(cateid,0) = "& uid &" "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN plan2 b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.type IN (17,12,13,14,15,16) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],cast(b.intro as varchar(8000)) title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],0 [cateid]"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 18:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN payback b  with(nolock) ON a.reminderConfig=" & configId & " AND (a.orderId = -b.ord or a.orderId = b.ord) AND b.del = 1 AND complete = '3' WHERE 1 = 1 " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],'@code:FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 207:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.ret_addcateid")
			cateCondition = cateCondition & " AND ((ret_bcateid = "& uid &" AND ret_state = 1 ) OR (ret_state > 1 AND Exit Sub_addcateid = "& uid &" )) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN O_proReturn b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.ret_del = 1 WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.ret_title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.ret_addcateid [cateid],"&_
			"(CASE WHEN (ret_bcateid = 0 OR ret_state > 1) THEN 1 ELSE 0 END) canCancelAlt, " &_
			"(case ret_state when 3 then 12 when 2 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 208:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.get_addcateid")
			cateCondition = cateCondition & " AND ((get_storecateid = "& uid &" AND get_store = 2 ) OR (get_store <> 2 AND get_addcateid = "& uid &" )) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN O_productOut b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.get_del = 1 WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.get_title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.get_addcateid [cateid],"&_
			"(CASE WHEN (get_storecateid = 0 OR get_store <> 2) THEN 1 ELSE 0 END) canCancelAlt, " &_
			"(case get_store when 3 then 12 when 1 then 11 else 10 end) orderStat"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 8:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			cateCondition = " and ((1=1" & cateCondition & ") or CHARINDEX(',"&uid&",',','+b.share+',')>0 OR share='0') "
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) "&_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN learnhd b  with(nolock) on a.orderId = b.ord AND b.del = 1 " &_
			" WHERE a.reminderConfig=" & configId & " [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "ISNULL(b.ord,0) [id],isnull(b.title,'【已删除数据】') title,isnull(convert(varchar(19),b.date7,21),'----') dt,"&_
			"DATEDIFF(s,' & actDate & "
			orderBy = "ORDER BY a.id DESC"
			Case 209:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN payoutsure b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ID AND b.del = 1  " & vbcrlf &_
			"left join sortbz d  with(nolock) on d.id=b.bz " & vbcrlf &_
			"WHERE 1 = 1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ID [id],  '@code:""'+b.title+'('+isnull(d.intro,'RMB')+' "" & FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)&""'+')'+'""' title,"&_
			"convert(varchar(19),a.inDate,21) dt,datediff(s,'&actDate&"
			orderBy = "ORDER BY a.inDate DESC,b.ID DESC"
			Case 210:
			cateCondition = " AND ((b.khzt <> 1 AND EXISTS (SELECT 1 FROM hr_perform_sp_list  with(nolock) WHERE sortID = b.sortid AND sp_id = "& uid &")) OR (b.khzt = 1 AND (CAST(b.user_list AS VARCHAR) = '0' OR CHARINDEX(',"& uid &",' , ','+ CAST(b.user_list AS VARCHAR) +',') > 0)) )"
'Case 210:
			cateCondition = cateCondition & " AND DATEDIFF(d,sp_Time1,GETDATE()) >= 0 AND DATEDIFF(d,sp_Time2,GETDATE()) <= 0 "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN hr_perform_sort b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del = 0 WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator [cateid]"
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 211:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN paybackInvoice b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del = 1 " & vbcrlf &_
			"left join sortbz c  with(nolock) on c.id=b.bz " & vbcrlf &_
			"WHERE 1 = 1 AND b.isInvoiced <> 3  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],'@code:""'+isnull(c.intro,'RMB')+' "" & FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(10),b.invoiceDate,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 212:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN payoutInvoice b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del = 1 " & vbcrlf &_
			"WHERE 1 = 1 AND b.del = 1 AND b.isInvoiced in (1,2) " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.[id],'@code:FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(19),b.invoiceDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid "
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 10:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"c.cateid")
			cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN kujhlist b  with(nolock) on a.reminderConfig="&configId&" and a.orderId=b.id and b.del=1 " & vbcrlf &_
			"inner Join kujh c  with(nolock) on b.kujh=c.ord and c.del=1 " & vbcrlf &_
			"inner join product d on d.ord=b.ord " & vbcrlf &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],c.title+'('+d.title+')' title,CONVERT(VARCHAR(10),b.date2,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],c.cateid [cateid]"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by b.date2 DESC,b.date7 DESC"
			Case 20:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			storelist_sort5 = "0"
			Set rsUsConfig= conn.execute("select isnull(tvalue,'0') tvalue from home_usConfig where name='storelist_sort5' and isnull(uid, 0) =" &  session("personzbintel2007") )
			If rsUsConfig.eof= False Then
				storelist_sort5=rsUsConfig("tvalue")
			end if
			rsUsConfig.close
			showKuLimitZeroSQL = ""
			if storelist_sort5 = "0" then
				showKuLimitZeroSQL = " and (isnull(b.alert1,0)>0 or isnull(b.alert2,0)>0)"
			end if
			showzore =0
			Set rsUsConfig= conn.execute("select (case cast(tvalue as varchar(10)) when '1' then 1 else 0 end) v from home_usConfig  with(nolock) where uid="& session("personzbintel2007") &" and name='storelist_sort1' ")
			if rsUsConfig.eof=false  then
				showzore = rsUsConfig("v").value
			end if
			rsUsConfig.close
			unkuinwarning = 0
			if showzore="1" then
				Set rsUsConfig= conn.execute("select (case cast(tvalue as varchar(10)) when '1' then 1 else 0 end) v from home_usConfig  with(nolock) where uid="& session("personzbintel2007") &" and name='storelist_warning' ")
				if rsUsConfig.eof=false  then
					unkuinwarning = rsUsConfig("v").value
				end if
				rsUsConfig.close
			end if
			showZeroSQL = ""
			if showzore = "0" then
				showZeroSQL = " and isnull(b.ku_num,0)>0 "
			else
				if unkuinwarning="0" then
					showZeroSQL = " and exists(select 1 from ku where ord =a.ord) "
				end if
			end if
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen = 1 Then
				cateCondition = " and charindex(','+cast(b.addcate as varchar)+',',',"&qIntro&",')>0 "
'ElseIf qOpen = 1 Then
			else
				cateCondition = " and 1=2 "
			end if
			If withoutCateCondition Then
				tmpCondition = ""
			else
				tmpCondition = "inner join sortck subc on subc.id = suba.ck "& vbcrlf &_
				"and subc.del=1 "& vbcrlf &_
				"and ("& vbcrlf &_
				"charindex('," & uid & ",',','+replace(cast(subc.intro as varchar(4000)),' ','')+',')>0 "& vbcrlf &_
				"and ("& vbcrlf &_
				"or replace(cast(subc.intro as varchar(4000)),' ','') = '0'"& vbcrlf &_
				")"
			end if
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN ("&vbcrlf & _
			"SELECT a.ord,addcate,title," & vbcrlf & _
			"(CASE WHEN Isnull(aleat1, 0) = 0 THEN 0 ELSE Isnull(aleat1,0) END) AS alert1, " & vbcrlf & _
			"(CASE WHEN Isnull(aleat2, 0) = 0 THEN 0 ELSE Isnull(aleat2,0) END) AS alert2, " & vbcrlf & _
			"date7,Isnull(ku_num, 0) ku_num " & vbcrlf & _
			"FROM product a " & vbcrlf & _
			"LEFT JOIN ("&vbcrlf & _
			"SELECT ord,Sum(numjb) AS ku_num FROM ("&vbcrlf & _
			"SELECT suba.ord," & vbcrlf & _
			"(CASE WHEN suba.unit = subb.unitjb THEN num2 " & vbcrlf & _
			"ELSE num2 * Isnull((SELECT TOP 1 bl FROM jiage  with(nolock) WHERE product = suba.ord AND unit = suba.unit),0) " & vbcrlf & _
			"END) numjb " & vbcrlf & _
			"FROM ku suba  with(nolock) " & vbcrlf & _
			"INNER JOIN product subb  with(nolock) ON suba.ord = subb.ord " & vbcrlf & _
			"tmpCondition" & vbcrlf &_
			") subaa " & vbcrlf & _
			"GROUP BY ord " & vbcrlf & _
			") AS b ON a.ord = b.ord " & vbcrlf & _
			"WHERE a.del = 1 "& showZeroSQL&" AND (isnull(ku_num,0)<=aleat1 or isnull(ku_num,0)>aleat2) " & vbcrlf & _
			") AS b ON a.orderid = b.ord "& showKuLimitZeroSQL &" AND a.reminderConfig=" & configId & " " & vbcrlf & _
			"WHERE 1 = 1 " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title," &_
			"CASE WHEN [Ku_num]<[alert1] then '↓'+cast(dbo.formatnumber([Ku_num]," & numDigit & ",0) as nvarchar(50)) " & _
			"WHEN [Ku_num]>[alert2] then '↑" &_
			"END dt," &_
			"DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate [cateid]"
			orderBy = "order by title desc,date7 desc"
			Case 49:
			cateCondition = getCondition(m_qxlb,m_listqx,"c.personID")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_person_health c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.id " & vbcrlf &_
			"INNER JOIN hr_person b  with(nolock) ON b.userID = c.personID " & vbcrlf & _
			"where 1=1 AND Isnull(c.alt, 1) < 2 and b.del = 0 AND c.lastdate IS NOT NULL "&_
			"AND c.zhouqi IS NOT NULL AND b.nowstatus NOT IN (2,3,4) " & vbcrlf &_
			"and DATEDIFF(m,GETDATE(),b.contractEnd)>0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]" & vbcrlf
			fields = "c.id [id],b.username title,CONVERT(VARCHAR(10)," & _
			"(CASE c.unit " & vbcrlf & _
			"WHEN 1 THEN Dateadd(yyyy, c.zhouqi, c.lastdate) " & vbcrlf & _
			"WHEN 2 THEN Dateadd(qq, c.zhouqi, c.lastdate) " & vbcrlf & _
			"WHEN 3 THEN Dateadd(m, c.zhouqi, c.lastdate) " & vbcrlf & _
			"WHEN 4 THEN Dateadd(ww, c.zhouqi, c.lastdate) " & vbcrlf & _
			"WHEN 5 THEN Dateadd(d, c.zhouqi, c.lastdate) " & vbcrlf & _
			"ELSE NULL " & vbcrlf & _
			"END )" & vbcrlf &_
			",23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],c.personID [cateid]"
			orderBy = "order by dt DESC"
			Case 66:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1 & " "
			cateCondition = cateCondition & " and charindex('," & uid &",',','+cast(isnull(b.alt,'') as varchar(4000))+',')=0"
			cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1 & " "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"(" & vbcrlf &_
			"SELECT z.id,t.name,t.cateid,s.title,z.date2,cast(isnull(z.alt,'') as varchar(4000)) alt,t.share " & vbcrlf & _
			"FROM tel t  with(nolock) " & vbcrlf & _
			"INNER JOIN sortFieldsContent z  with(nolock) " & vbcrlf & _
			"ON z.ord = t.ord " & vbcrlf & _
			"AND z.del = 1 " & vbcrlf & _
			"AND t.del = 1 " & vbcrlf & _
			"AND z.sort = 1 " & vbcrlf & _
			"AND t.sort3 = 2 " & vbcrlf & _
			"AND t.isNeedQuali = 1 " & vbcrlf & _
			"AND ISNULL(t.status_sp_qualifications, 0) = 0 " & vbcrlf & _
			"AND LEN(z.date2) > 0 " & vbcrlf & _
			"AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"AND CHARINDEX(',"& uid &",', ',' + CAST(z.share AS VARCHAR(4000)) + ',') > 0 " & vbcrlf & _
			"AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"INNER JOIN sortClass s with(nolock)  " & vbcrlf & _
			"ON z.sortid = s.id " & vbcrlf & _
			"AND ISNULL(s.isStop, 0) = 0 " & vbcrlf & _
			"AND s.sort1 = 2 " & vbcrlf & _
			") b ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbcrlf & _
			"WHERE 1 = 1 " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.name title,CONVERT(VARCHAR(10),b.date2,23) dt,DATEDIFF(s,'"&actDate&"',b.date2) newTag,a.id [rid],b.cateid [cateid]"
			orderBy = "order by b.date2 DESC"
			Case 67:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1 & " "
			cateCondition = cateCondition & " and charindex('," & uid &",',','+cast(isnull(b.alt,'') as varchar(4000))+',')=0"
			cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1 & " "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"("&_
			"SELECT z.id,t.name,t.cateid,s.title,z.date2,cast(isnull(z.alt,'') as varchar(4000)) alt,t.share " & vbcrlf & _
			"FROM tel t  with(nolock) " & vbcrlf & _
			"INNER JOIN sortFieldsContent z  with(nolock) " & vbcrlf & _
			"ON z.ord = t.ord " & vbcrlf & _
			"AND z.del = 1 " & vbcrlf & _
			"AND t.del = 1 " & vbcrlf & _
			"AND z.sort = 1 " & vbcrlf & _
			"AND t.sort3 = 1 " & vbcrlf & _
			"AND t.isNeedQuali = 1 " & vbcrlf & _
			"AND ISNULL(t.status_sp_qualifications, 0) = 0 " & vbcrlf & _
			"AND LEN(z.date2) > 0 " & vbcrlf & _
			"AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"AND CHARINDEX(',"& uid &",', ',' + CAST(z.share AS VARCHAR(4000)) + ',') > 0 " & vbcrlf & _
			"AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"INNER JOIN sortClass s  with(nolock) " & vbcrlf & _
			"ON z.sortid = s.id " & vbcrlf & _
			"AND ISNULL(s.isStop, 0) = 0 " & vbcrlf & _
			"AND s.sort1 = 2 " & vbcrlf & _
			") b ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbcrlf & _
			"WHERE 1 = 1 " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.name title,CONVERT(VARCHAR(10),b.date2,23) dt,DATEDIFF(s,'"&actDate&"',b.date2) newTag,a.id [rid],b.cateid [cateid]"
			orderBy = "ORDER BY b.date2 DESC"
			Case 213:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"( " & vbCrLf &_
			"  SELECT a.id,a.date1,a.date7,a.cateid,ISNULL(a.money1,0) money1,b.intro bz FROM paybackinvoice a  with(nolock)  " & vbCrLf &_
			"  INNER JOIN sortbz b  with(nolock) ON b.id = a.bz " & vbCrLf &_
			"  WHERE a.del = 1 AND isInvoiced = 0  AND ISNULL(a.cateid,0) <> 0 " & vbCrLf &_
			") b ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
			"WHERE 1 = 1 " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],'@code:""'+isnull(b.bz,'RMG')+' "" & FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,CONVERT(VARCHAR(10),b.date1,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "ORDER BY b.date1 DESC,b.date7 DESC"
			Case 214:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN payoutInvoice b  with(nolock) ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
			"left JOIN sortbz d  with(nolock) ON d.id = b.bz " & vbCrLf &_
			"WHERE 1 = 1 AND b.del = 1 AND b.isInvoiced in (0,11) " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.[id],'@code:""'+isnull(d.intro,'RMB')+' "" & FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,CONVERT(VARCHAR(10),b.date1,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "ORDER BY b.date1 DESC,b.date7 DESC"
			Case 52:
			cateCondition = cateCondition & " AND daysFromNow <= " & m_tq1 * 24
			sql = "" &_
			"SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join ku k  with(nolock) on a.orderId=k.id and a.reminderConfig=" & configId &" " & vbcrlf &_
			"INNER JOIN product p  with(nolock) ON p.ord = k.ord " & vbcrlf &_
			"INNER JOIN sortck ck  with(nolock) ON k.ck = ck.ord AND ck.del = 1 " & vbcrlf &_
			"where (" & vbcrlf & _
			"CAST(ISNULL(ck.intro,'') AS VARCHAR(4000)) = '0' " & vbcrlf &_
			"OR CHARINDEX(',"&uid&",', ',' + CAST(ck.intro AS VARCHAR(4000)) + ',') > 0 " & vbcrlf &_
			"CAST(ISNULL(ck.intro,'') AS VARCHAR(4000)) = '0' " & vbcrlf &_
			") " & vbcrlf &_
			"AND p.del = 1 " & vbcrlf &_
			"AND k.num2 > 0 " & vbcrlf &_
			"AND p.RemindNum > 0 " & vbcrlf &_
			"AND CHARINDEX(',"&uid&",', ',' + ISNULL(p.RemindPerson, '') + ',') > 0 " & vbcrlf &_
			"AND p.RemindNum > 0 " & vbcrlf &_
			"AND k.dateyx IS NOT NULL " & vbcrlf &_
			"AND ISNULL(k.locked, 0) = 0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "k.id [id],p.title,CONVERT(VARCHAR(10),k.dateyx,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],p.addcate [cateid]"
			orderBy = "ORDER BY k.dateyx DESC,p.date7 DESC"
			Case 51:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.addcateid")
			cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1 & " AND b.addcateid = "& uid &" "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"( " & vbCrLf &_
			"  SELECT a.id,d.id lid, c.bk_name, a.ld_rettime, d.addcateid " & vbcrlf &_
			"  FROM O_Lendbookmx a  with(nolock) " & vbcrlf &_
			"  LEFT JOIN O_Lendbook d  with(nolock) ON a.Ld_fid=d.id " & vbcrlf &_
			"  LEFT JOIN O_regbook c  with(nolock) ON a.Ld_bkid=c.id " & vbcrlf &_
			"  WHERE a.ld_num > (SELECT isnull(sum(Ret_num),0) AS Ret_num FROM O_RetBookmx  with(nolock) WHERE Ret_bkid=a.id) " & vbcrlf &_
			") b ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
			"WHERE 1 = 1 " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.lid [id],b.bk_name title,CONVERT(VARCHAR(10),b.ld_rettime,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcateid [cateid]"
			orderBy = "ORDER BY b.ld_rettime DESC"
			Case 59:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.userId")
			cateCondition = cateCondition & " AND DATEDIFF(d,getdate(),b.Reguldate)<=" & m_tq1 & " "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"( " & vbCrLf &_
			"  SELECT a.ID,a.Reguldate,a.UserId,a.userName name " & vbcrlf &_
			"  FROM hr_person a  with(nolock) " & vbcrlf &_
			"  WHERE  a.nowStatus = 5 AND a.del = 0 " & vbcrlf &_
			") b ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
			"WHERE 1 = 1 " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.name title,CONVERT(VARCHAR(10),b.Reguldate,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.UserId [cateid]"
			orderBy = "ORDER BY b.Reguldate DESC"
			Case 215:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1 & " "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"Chance b  with(nolock) ON a.orderID = b.ord AND a.reminderConfig=" & configId & " " & vbCrLf &_
			"WHERE 1 = 1 AND b.del = 1 AND b.cateid > 0 " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,'距离回收' + CAST(daysFromNow AS VARCHAR) + '天' dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid [cateid]"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "ORDER BY b.date7 DESC"
			Case 300:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.addcate")
			cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1 & " "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"document b  with(nolock) ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
			"WHERE 1 = 1 AND b.del = 1  AND validity = 2 AND (b.sp = 0 AND b.cateid_sp = 0) AND b.addcate = "& uid &" " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,CONVERT(VARCHAR(10),b.date4,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate [cateid]"
			orderBy = "ORDER BY b.date7 DESC"
			Case 301:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.addcate")
			cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1 & " "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN " & vbcrlf & _
			"documentlist b  with(nolock) ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
			"inner join document d on d.id = b.document "  & vbCrLf &_
			"WHERE 1 = 1 AND d.del = 1 and b.del=1  AND b.l_validity = 2 AND (d.sp = 0 AND d.cateid_sp = 0) AND d.addcate = "& uid &" " & vbcrlf & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.oldname title,CONVERT(VARCHAR(10),b.l_date4,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],d.addcate [cateid]"
			orderBy = "ORDER BY b.date7 DESC"
			Case 105:
			tmpCondition = getConditionByFW(m_qxlb,m_listqx,"b.reg_addcateid")
			If withoutCateCondition Then tmpCondition = ""
			cateCondition = getConditionByFW(m_qxlb,15,"b.prod_addcateid")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join o_product b on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"inner join ( " & vbcrlf &_
			"select replace(prod_id,' ','') as ProductID,replace(prod_unit,' ','') as UnitId,sum(prod_num) as ku_num " & vbcrlf &_
			"from o_kuinlist a  with(nolock) " & vbcrlf &_
			"left join o_kuin b  with(nolock) on a.reg_fid=b.id " & vbcrlf &_
			"where 1=1 " & tmpCondition & " " & vbcrlf &_
			"group by prod_id,prod_unit " & vbcrlf &_
			") c on b.id=c.ProductID and a.daysFromNow=c.UnitId " & vbcrlf &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.prod_name title,(" & _
			"CASE when [Ku_num]<[prod_less] then '↓'+cast(dbo.formatnumber([Ku_num]," & numDigit & ",0) as nvarchar(50)) " & _
			"fields = ""b.id [id],b.prod_name title,(""" &_
			"when [Ku_num]>[prod_more] then '↑"
			fields = "b.id [id],b.prod_name title,(" & _
			"end " & _
			") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.prod_addcateid cateid"
			orderBy = "order by b.prod_name desc"
			Case 106:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name title,'距离回收' + cast(daysFromNow as varchar) + '天' dt,"&_
			"datediff(s,'&actDate&" &_
			orderBy = "order by daysFromNow asc"
			Case 107:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_AppHoliday b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where (" & vbcrlf &_
			"KQClass in (" & vbcrlf &_
			"select id from hr_KQClass  with(nolock) where sortID=1 and del=0 " & vbcrlf &_
			") or KQClass=1 " & vbcrlf &_
			") and del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(19),startTime,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 108:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_AppHoliday b with(nolock)  on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where (" & vbcrlf &_
			"KQClass in (" & vbcrlf &_
			"select id from hr_KQClass  with(nolock) where sortID=2 and del=0 " & vbcrlf &_
			") or KQClass=2 " & vbcrlf &_
			") and del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(19),startTime,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 109:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_AppHoliday b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where (" & vbcrlf &_
			"KQClass in (" & vbcrlf &_
			"select id from hr_KQClass  with(nolock) where sortID=3 and del=0 " & vbcrlf &_
			") or KQClass=3 " & vbcrlf &_
			") and del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(19),startTime,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 110:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((sp=-1 or sp=0) and cateid="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"cateCondition = cateCondition & ""and (""" & vbcrlf &_
			"or (sp>0 and cateid_sp=&uid&) /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join wages b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"where del=1 and isnull(salaryClass,0)>0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],title,cast(year(date2) as varchar)+'年'+cast(month(date2) as varchar)+'月' dt,"&_
			"datediff(s,'&actDate&" &_
			"(case when sp=-1 or sp=0 then 1 else 0 end) canCancelAlt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],cateid,"&_
			"(case sp when -1 then 12 when 0 then 11 else 10 end) orderStat"
			orderBy = "order by b.date7 desc,b.date3 desc"
			Case 111:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((sp=-1 or sp=0) and cateid="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"cateCondition = cateCondition & ""and (""" & vbcrlf &_
			"or (sp>0 and cateid_sp=&uid&) /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join wages b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"where del=1 and isnull(salaryClass,0)=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],title,cast(year(date2) as varchar)+'年'+cast(month(date2) as varchar)+'月' dt,"&_
			"datediff(s,'&actDate&" &_
			"(case when sp=-1 or sp=0 then 1 else 0 end) canCancelAlt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],cateid,"&_
			"(case sp when -1 then 12 when 0 then 11 else 10 end) orderStat"
			orderBy = "order by b.date7 desc,b.date3 desc"
			Case 217:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.designer")
			cateCondition = cateCondition & " AND ( (cateid_sp = "& uid &" AND id_sp > 0) OR (cateid_sp = 0  AND designer = "& uid &" ) ) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			" INNER JOIN design b  with(nolock) ON a.reminderConfig="& configId &" AND a.orderId = b.id and b.del=1 AND b.designstatus in (7,8,9) WHERE 1 = 1"& vbcrlf &_
			" [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id], b.title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.designer as cateid,"&_
			"(CASE WHEN (cateid_sp = 0 OR id_sp < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
			"(case id_sp when -1 then 12 when 0 then 11 else 10 end) orderStat"
'(CASE WHEN (cateid_sp = 0 OR id_sp < 0) THEN 1 ELSE 0 END) canCancelAlt, &_
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 218:
			cateCondition = getCondition(m_qxlb,15,"c.designer")
			cateCondition = cateCondition & " AND  charindex(',"& uid &",',','+replace(reminders,' ','')+',')>0 "
			cateCondition = getCondition(m_qxlb,15,"c.designer")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			" INNER JOIN reply b  with(nolock) ON a.reminderConfig="& configId &" AND a.orderId = b.id AND b.del=1 and b.sort1 = 5029 "& vbcrlf &_
			" inner join design c  with(nolock) on c.id = b.ord2       "&_
			" where b.del =1 " & vbcrlf &_
			" [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id], b.title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid], b.cateid "
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 112:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and cateid_moi in ("&qIntro&") "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & " and Cateid_MOI=" & uid
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M_ManuOrderIssueds b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.inDate desc"
			Case 113:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and b.id in (select distinct b.id from reminderQueue a  with(nolock) " & vbcrlf &_
				"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
				"left join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+b.Cateid_WA+',')>0" & vbcrlf &_
				"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" AND plist.sort1 = 54 AND plist.sort2 = 1" & vbcrlf &_
				"where b.del=1 and b.ptype=0 and tempSave=0 and b.[status]<>2 AND ISNULL(b.SPStatus,-1) IN(-1,1)" & vbcrlf &_
				"and (plist.qx_open = 3 OR CHARINDEX(','+CAST(g1.ord AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0))"
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & " and charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(Cateid_WA,' ','')+',')>0"
			cateCondition = " and 1=2"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join product p  with(nolock) on p.ord = b.productid "&_
			"where b.del=1 and ptype=0 and tempSave=0 and b.[status]<>2 AND ISNULL(b.SPStatus,-1) IN(-1,1) and CONVERT(varchar(10),b.inDate,120) <= CONVERT(varchar(10),GETDATE(),120)"&_
			"inner join product p  with(nolock) on p.ord = b.productid "&_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title +' ('+ p.title +')' as title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by b.inDate desc"
			Case 224:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and b.id in (select distinct b.id from reminderQueue a  with(nolock) " & vbcrlf &_
				"inner join erp_M2_WorkAssigns_status b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
				"left join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+b.Cateid_WA+',')>0" & vbcrlf &_
				"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" AND plist.sort1 = 54 AND plist.sort2 = 1" & vbcrlf &_
				"where b.del=1 and b.ptype=0 and tempSave=0 and b.[status]<>2 and b.wastatus!='生产完毕' AND ISNULL(b.SPStatus,-1) IN(-1,1)" & vbcrlf &_
				"and (plist.qx_open = 3 OR CHARINDEX(','+CAST(g1.ord AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0))"
			else
				cateCondition = " and 1=2"
			end if
			If m_fw1&""="1" Then
				tmpCondition = " and charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(Cateid_WA,' ','')+',')>0"
'If m_fw1&""="1" Then
			end if
			cateCondition =  " " & tmpCondition & " " & cateCondition & " and datediff(d,getdate(),b.dateEnd)<=" & m_tq1 & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join erp_M2_WorkAssigns_status b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join product p  with(nolock) on p.ord = b.productid "&_
			"where b.del=1 and b.ptype=0 and tempSave=0 and b.[status]<>2 and b.wastatus!='生产完毕' AND ISNULL(b.SPStatus,-1) IN(-1,1)" &_
			"inner join product p  with(nolock) on p.ord = b.productid "&_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title +' ('+ p.title +')' as title ,b.dateEnd dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by b.DateEnd, b.inDate desc"
			Case 225:
			tmpCondition = ""
			cateCondition = ""
			sql = "select COUNT(*) REMIND_CNT from dbo.v_attendance_GetRemind a   with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"where exists(select top 1 g.ord from dbo.gate g  with(nolock) where g.ord="& uid &" and g.orgsid=a.orgsid and g.Partadmin=1)" &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "a.Id [id],a.userName as title,a.WorkLong,a.RemindUnit,GETDATE() as dt,a.LogDate as newTag,a.Id [rid],a.Id cateid"
			orderBy = "order by a.LogDate desc"
			Case 5013:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & " and charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(Cateid_WA,' ','')+',')>0"
			cateCondition = " and 1=2"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join product p  with(nolock) on p.ord = b.productid "&_
			"where b.del=1 and b.ptype=1 and tempSave=0 and b.[status]<>2 and CONVERT(varchar(10),b.inDate,120) = CONVERT(varchar(10),GETDATE(),120)" & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title +' ('+ p.title +')' as title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by b.inDate desc"
			Case 54015:
			tmpCondition = ""
			cateCondition = ""
			sql = "select COUNT(*) REMIND_CNT from erp_fn_GetForSJWorkAssigns(''," & uid & ") a " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WorkAssigns b  with(nolock) on a.ID=b.ID "&_
			"where " &_
			" exists(" &_
			"SELECT 1 from dbo.gate gt  with(nolock) " &_
			"inner join power sjpow  with(nolock) ON sjpow.ord =" & uid & " AND sjpow.sort1 =(case isnull(b.ptype,0) when 0 then 54 else 62 end) and sjpow.sort2=1 " &_
			"WHERE  (sjpow.qx_open = 3 OR CHARINDEX(','+CAST(gt.ord AS VARCHAR(20))+',',','+CAST(sjpow.qx_intro AS VARCHAR(8000))+',') > 0) " &_
			"and CHARINDEX(','+CAST(gt.ord AS VARCHAR(20))+',',','+ISNULL(b.Cateid_WA,-1)+',') > 0)" &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "a.Id [id],a.title as title,a.inDate as dt,datediff(s,'"&actDate&"',a.inDate) as newTag,a.Id [rid],a.Creator cateid"
			orderBy = "order by a.inDate desc"
			Case 54106:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			cateCondition = ""
			cateCondition = cateCondition & " and (charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(QcCateid as varchar(12)),' ','')+',')>0 or exists(" &_
			"select top 1 1 from dbo.M2_OneSelfQualityTestingTaskList ttl  with(nolock) " &_
			" where ttl.TaskID=b.ID and charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(ttl.QcCateid as varchar(12)),' ','')+',')>0))"
			sql = "select COUNT(*) REMIND_CNT from (select MAX(b.id) as ID,b.orderId,reminderConfig,max(inDate) inDate from reminderQueue b  with(nolock) group by b.orderId,reminderConfig) a """ & vbcrlf &_
			"[CANCELJOINTABLE] " & _
			"inner join M2_OneSelfQualityTestingTask b with(nolock)  on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"where b.[QCStatus]<>2 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title +' ('+ b.TaskBh +')' as title,convert(varchar(10),b.TaskDate,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by b.inDate desc"
			Case 5014:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1&""="2" Then
				If qOpen = 3 Then
					tmpCondition = ""
				ElseIf qOpen=1 Then
					tmpCondition = " and b.id in (select distinct b.id from M2_WorkAssigns b  with(nolock)  " & vbcrlf &_
					"inner join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+b.Cateid_WA+',')>0" & vbcrlf &_
					"tmpCondition = "" and b.id in (select distinct b.id from M2_WorkAssigns b  with(nolock)  """ & vbcrlf &_
					"where g1.ord in (& qIntro &) )"
				else
					tmpCondition = " and 1=2"
				end if
			else
				tmpCondition = " and charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(Cateid_WA,' ','')+',')>0 "
				tmpCondition = " and 1=2"
			end if
			cateCondition =  " " & tmpCondition & " " & cateCondition & " and datediff(d,getdate(),b.dateEnd)<=" & m_tq1 & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join product p  with(nolock) on p.ord = b.productid "&_
			"where b.del=1 and ptype=1 and tempSave=0 and b.[status]<>2 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title +' ('+ p.title +')' as title ,b.dateEnd dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by b.inDate desc "
			Case 114:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M_ManuPlans b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 and b.status=3 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.inDate desc"
			Case 115:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M_ManuOrders b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 and b.status=3 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.inDate desc"
			Case 116:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M_OutOrder b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 and b.status=3 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.inDate desc"
			Case 117:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M_MaterialProgres b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.inDate desc"
			Case 118:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M_QualityTestings b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where b.qtype<>1 and del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.inDate desc"
			Case 119:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M_QualityTestings b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where b.qtype=1 and del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.inDate desc"
			Case 120:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name title,'距离保护到期' + cast(daysFromNow as varchar) + '天' dt,"&_
			"datediff(s,'&actDate&"
			orderBy = "order by daysFromNow asc"
			Case 121:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name title,'下次联系：' + convert(varchar(10),dateadd(d,daysFromNow,'2014-01-01'),23) dt,"&_
			"datediff(s,'&actDate&"
			orderBy = "order by daysFromNow asc"
			Case 122:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_ret_plan b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 123:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_Resume b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.keyword title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 124:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_interview b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],dbo.HrGetResumeName(b.resumeID) title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 125:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_train_plan b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 126:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_expaper b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 127:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_person_salary b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],ISNULL((SELECT TOP 1 name FROM gate  with(nolock) WHERE ord = b.cateid), '用户' + CAST(b.cateid AS varchar(10)) + '【已删】') title,"&_
			"convert(varchar(10),a.inDate,21) dt," &_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 128:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_person_contract b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 129:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_regime b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 130:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_positive b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 131:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_leave b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 132:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_Transfer b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 133:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_off_staff b with(nolock)  on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.gateName title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 134:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_reinstate b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.gateName title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 135:
			Set rs_setting = cn.execute("select workPosition FROM gate  with(nolock) WHERE ord ="& uid &"")
			workPosition = rs_setting("workPosition")
			If Len(workPosition&"") = 0 Then workPosition = 0
			rs_setting.close
			cateCondition = "and (" & vbcrlf &_
			"((spFlag=1 or spFlag=-1) and addcate="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"cateCondition = ""and (""" & vbcrlf &_
			"or ((spFlag=2 or spFlag=3) and cateid_sp=&uid&) /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join document b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"left join power p  with(nolock) on p.ord="& uid &" and sort1=78 and sort2=1 " & vbcrlf &_
			"left join power p1  with(nolock) on p1.ord="& uid &" and p1.sort1=78 and p1.sort2=16 "&_
			"where  del=1 " & vbcrlf &_
			"and (p1.qx_open = 3  OR (CHARINDEX(','+CAST(b.addcate AS VARCHAR(20))+',',','+CAST(p1.qx_intro AS VARCHAR(max))+',') > 0)"& vbcrlf &_
			"where  del=1 " & vbcrlf &_
			"or (b.addcate="& uid &" and  (b.spFlag = 1 or b.spFlag=-1)) "&_
			"where  del=1 " & vbcrlf &_
			" ) "& vbcrlf &_
			"and (p.qx_open = 3 OR (CHARINDEX(','+CAST(b.addcate AS VARCHAR(20))+',',','+CAST(p.qx_intro AS VARCHAR(max))+',') > 0"& vbcrlf &_
			" ) "& vbcrlf &_
			"or  CHARINDEX(','+ CONVERT(varchar(20),"& uid &") +',', ','+isnull(cast(b.share1 as varchar(8000)),0)+',')>0  " & vbcrlf &_
			" ) "& vbcrlf &_
			"or CHARINDEX(','+ CONVERT(varchar(20),"& workPosition &") +',', ','+isnull(cast(b.postDown as varchar(8000)),0)+',')>0  "&_
			" ) "& vbcrlf &_
			"or CHARINDEX(','+ CONVERT(varchar(20),"& workPosition &") +',', ','+isnull(cast(b.postView as varchar(8000)),0)+',')>0  "&_
			" ) "& vbcrlf &_
			"or (b.addcate="& uid &" and  (b.spFlag = 1 or b.spFlag=-1)) "&_
			" ) "& vbcrlf &_
			"or  CHARINDEX(','+ CONVERT(varchar(20),"& uid &") +',', ','+isnull(cast(b.share2 as varchar(8000)),0)+',')>0  ))" & vbcrlf &_
			" ) "& vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate cateid," &_
			"(case when spFlag=1 or spFlag=-1 then 1 else 0 end) canCancelAlt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate cateid," &_
			"datediff(s,'&actDate&"
			orderBy = "order by b.id desc"
			Case 136:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1&""="0" Then
				If qOpen = 3 Then
					cateCondition = ""
				ElseIf qOpen=1 Then
					cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
					tmpCondition = " and (cateid is not null and cateid<>0)"
				else
					cateCondition = " and 1=2"
				end if
			else
				cateCondition = " and cateid=" & uid
			end if
			cateCondition = " " & cateCondition & " " & tmpCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join xunjia b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),b.date7,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date7 desc"
			Case 137:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If m_fw1&""="0" Then
				If qOpen = 3 Then
					cateCondition = ""
				ElseIf qOpen=1 Then
					cateCondition = " and ("_
					&" (addcate is not null and addcate<>0 and addcate in ("&qIntro&")) "_
					&" or (catelead is not null and catelead<>0 and catelead in ("&qIntro&")) "_
					&" or (cate1 is not null and cate1<>0 and cate1 in ("&qIntro&")) "_
					&" or (cate2 is not null and cate2<>0 and cate2 in ("&qIntro&")) "_
					&" or (cate3 is not null and cate3<>0 and cate3 in ("&qIntro&")) "_
					&" or (cate4 is not null and cate4<>0 and cate4 in ("&qIntro&")) "_
					&" or (cate5 is not null and cate5<>0 and cate5 in ("&qIntro&")) "_
					&" or (cate6 is not null and cate6<>0 and cate6 in ("&qIntro&")) "_
					&" or (cate7 is not null and cate7<>0 and cate7 in ("&qIntro&")) "_
					&" or (cate8 is not null and cate8<>0 and cate8 in ("&qIntro&")) "_
					&" or (member1 is not null and member1<>0 and member1 in ("&qIntro&")) "_
					&" or share='0' or charindex(',"&uid&",',','+replace(share,' ','')+',')>0 "_
					&" or (member1 is not null and member1<>0 and member1 in ("&qIntro&")) "_
					&" )"
				else
					cateCondition = " and 1=2"
				end if
			else
				cateCondition = " and ("_
				&" (addcate is not null and addcate<>0 and addcate ="&uid&") "_
				&" or (catelead is not null and catelead<>0 and catelead in ("&uid&")) "_
				&" or (cate1 is not null and cate1<>0 and cate1 in ("&uid&")) "_
				&" or (cate2 is not null and cate2<>0 and cate2 in ("&uid&")) "_
				&" or (cate3 is not null and cate3<>0 and cate3 in ("&uid&")) "_
				&" or (cate4 is not null and cate4<>0 and cate4 in ("&uid&")) "_
				&" or (cate5 is not null and cate5<>0 and cate5 in ("&uid&")) "_
				&" or (cate6 is not null and cate6<>0 and cate6 in ("&uid&")) "_
				&" or (cate7 is not null and cate7<>0 and cate7 in ("&uid&")) "_
				&" or (cate8 is not null and cate8<>0 and cate8 in ("&uid&")) "_
				&" or (member1 is not null and member1<>0 and member1 in ("&uid&")) "_
				&" or share='0' or charindex(',"&uid&",',','+replace(share,' ','')+',')>0 "_
				&" or (member1 is not null and member1<>0 and member1 in ("&uid&")) "_
				&" )"
			end if
			cateCondition = " " & cateCondition & " " & tmpCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tousu b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title,convert(varchar(19),b.date7,"& iif(m_isMobileMode,"21","23") &") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate cateid"
			orderBy = "order by b.date7 desc"
			Case 138:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
				tmpCondition = " and (catein = " & uid & ") "
			ElseIf qOpen=1 Then
				cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
				tmpCondition = " and (catein = " & uid & ") "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & tmpCondition
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join kumove b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid"
			orderBy = "order by b.ord desc"
			Case 139:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.addcate")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=0 or status=4) and addcate="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=1 or status=2) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join maintain b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate cateid," &_
			"(case when status=0 or status=4 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 0 then 11 when 4 then 12 else 10 end) orderStat"
			orderBy = "order by b.ord desc"
			Case 140:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
			else
				cateCondition = " and 1=2"
			end if
			tmpCondition = ""
			If m_fw1&""="0" Then
				tmpCondition = " "
			else
				tmpCondition = " and cateid=" & uid
			end if
			cateCondition = " " & cateCondition & " " & tmpCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join caigou b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title,convert(varchar(10),b.date7,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date7 desc"
			Case 141:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1&""="0" Then
				If qOpen = 3 Then
					cateCondition = ""
				ElseIf qOpen=1 Then
					cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
					tmpCondition = " and (cateid is not null and cateid<>0)"
				else
					cateCondition = " and 1=2"
				end if
			else
				cateCondition = " and cateid=" & uid
			end if
			cateCondition = " " & cateCondition & " " & tmpCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join caigou_yg b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),b.date7,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date7 desc"
			Case 142:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
				tmpCondition = " and (cateout = " & uid & ") "
			ElseIf qOpen=1 Then
				cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
				tmpCondition = " and (cateout = " & uid & ") "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & tmpCondition
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join kumove b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid"
			orderBy = "order by b.ord desc"
			Case 143:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
			else
				cateCondition = " and 1=2"
			end if
			Call fillinPower(24,13,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition &  " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			Call fillinPower(4,14,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition &  " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & tmpCondition
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join price b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del in (3,1) and complete in (1,8)  " & vbcrlf &_
			"where del in (3,1) " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(10),b.date1,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid"
			orderBy = "order by b.ord desc"
			Case 144:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
				tmpCondition = " and (Inspector = " & uid & ") "
			ElseIf qOpen=1 Then
				cateCondition = " and addcate is not null and addcate<>0 and addcate in ("&qIntro&") "
				tmpCondition = " and (Inspector = " & uid & ") "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & tmpCondition
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join caigouqc b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del = 1 and b.complete in (0,1)  " & vbcrlf &_
			"where del =1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate cateid"
			orderBy = "order by b.id desc"
			Case 145:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status=0 or status=3) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=1 or status=2) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join budget b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=0 or status=3 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 0 then 11 when 3 then 12 else 10 end) orderStat"
			orderBy = "order by b.ord desc"
			Case 146:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1="0" Then
				tmpCondition = ""
			else
				tmpCondition = " and (cateid=" & uid & ") "
			end if
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and ((cateid is not null and cateid<>0 and cateid in ("&qIntro&")) or share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0) "
'ElseIf qOpen=1 Then
			else
				cateCondition = " and (share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0)"
'ElseIf qOpen=1 Then
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join chance b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title,convert(varchar(19),b.date7,"& iif(m_isMobileMode,"21","23") &") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date7 desc"
			Case 147:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1="0" Then
				tmpCondition = ""
			else
				tmpCondition = " and ((order1=1 or order1=2) and cateid=" & uid & ") "
			end if
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and ((cateid is not null and cateid<>0 and cateid in ("&qIntro&")) or share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0) "
'ElseIf qOpen=1 Then
			else
				cateCondition = " and (share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0)"
'ElseIf qOpen=1 Then
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where del =1 and isnull(sp,0)=0 and sort3=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name [title],convert(varchar(19),b.date2,"& iif(m_isMobileMode,"21","23") &") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = " order by b.date2 desc "
			Case 148:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateadd")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((isnull(status_sp_qualifications,0)=0 or status_sp_qualifications=4) and isnull(cateid,cateadd)="&uid&") " & vbcrlf &_
			"/*审批通过或终止的提醒给采购人员或添加人*/" & vbcrlf &_
			"or " & vbcrlf &_
			"((status_sp_qualifications=1 or status_sp_qualifications=2) and cateid_sp_qualifications="&uid&") " & vbcrlf &_
			"/*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join sortFieldsContent c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.id and c.del = 1 " & vbcrlf &_
			"inner join tel b  with(nolock) on c.ord = b.ord and b.del=1 " & vbcrlf &_
			"where b.del=1 and sort3=2 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "c.id [id],b.name title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateadd cateid," &_
			"(case when isnull(status_sp_qualifications,0)=0 or status_sp_qualifications=4 then 1 else 0 end) canCancelAlt,"&_
			"(case isnull(status_sp_qualifications,0) when 0 then 11 when 4 then 12 else 10 end) orderStat"
			orderBy = "order by b.ord desc"
			Case 149:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateadd")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"((status_sp_qualifications=0 or status_sp_qualifications=4) and isnull(cateid,cateadd)=" & uid & ") " & vbcrlf &_
			"/*审批通过或终止的提醒给销售人员或添加人*/" & vbcrlf &_
			"or "&_
			"((status_sp_qualifications=1 or status_sp_qualifications=2) and cateid_sp_qualifications=" & uid & ") " & vbcrlf &_
			"/*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join sortFieldsContent c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.id and c.del = 1 " & vbcrlf &_
			"inner join tel b  with(nolock) on c.ord = b.ord and b.del=1 " & vbcrlf &_
			"where b.sort3=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "c.id [id],b.name title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateadd cateid," &_
			"(case when isnull(status_sp_qualifications,0)=0 or status_sp_qualifications=4 then 1 else 0 end) canCancelAlt,"&_
			"(case isnull(status_sp_qualifications,0) when 0 then 11 when 4 then 12 else 10 end) orderStat"
			orderBy = "order by b.ord desc"
			Case 70:
			cateCondition = " @MyPower_1_102 and (" & vbcrlf &_
			"((use_complete=4 or use_complete=3) and use_addcateid="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((use_complete=1 or use_complete=2) and use_cateid_sp="&uid&" @MyPower_16_102) /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				tmpCondition = ""
			ElseIf qOpen=1 Then
				tmpCondition = " and use_addcateid is not null and use_addcateid<>0 and use_addcateid in ("&qIntro&") "
			else
				tmpCondition = " and 1=2"
			end if
			cateCondition = Replace(cateCondition,"@MyPower_1_102",tmpCondition)
			tmpCondition = ""
			cateCondition = Replace(cateCondition,"@MyPower_16_102",tmpCondition)
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join O_carUse b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.use_id and b.use_del=1 " & vbcrlf &_
			"inner join gate g  with(nolock) on b.use_cateid = g.ord " & vbcrlf &_
			"where use_del=1 and use_type=1 and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.use_id [id],g.name title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.use_addcateid cateid," &_
			"(case when use_complete=3 or use_complete=4 then 1 else 0 end) canCancelAlt,"&_
			"(case use_complete when 3 then 11 when 4 then 12 else 10 end) orderStat"
			orderBy = "order by b.use_id desc"
			Case 150:
			cateCondition = " @MyPower_1_102 and (" & vbcrlf &_
			"((status=2 or status=3) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or ((status=0 or status=1) and cateid_sp="&uid&" @MyPower_16_102) /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				tmpCondition = ""
			ElseIf qOpen=1 Then
				tmpCondition = " and creator is not null and creator<>0 and creator in ("&qIntro&") "
			else
				tmpCondition = " and 1=2"
			end if
			cateCondition = Replace(cateCondition,"@MyPower_1_102",tmpCondition)
			tmpCondition = ""
'cateCondition = Replace(cateCondition,"@MyPower_16_102",tmpCondition)
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join hr_perform_ss b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
			"where del=0 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when status=2 or status=3 then 1 else 0 end) canCancelAlt,"&_
			"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
			orderBy = "order by b.id desc"
			Case 151:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1&""="0" Then
				tmpCondition = ""
			else
				tmpCondition = " and cateid=" & uid & " "
			end if
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and ((addcate is not null and addcate<>0 and addcate in ("&qIntro&")) or share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0) "
'ElseIf qOpen=1 Then
			else
				cateCondition = " and (1=2 or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0)"
'ElseIf qOpen=1 Then
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join contract b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 and isnull(b.status,-1) in (-1,1) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"where del =1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title [title],convert(varchar(19),b.date7,"& iif(m_isMobileMode,"21","23") &") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date1 desc,b.date7 desc"
			Case 152:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1&""="0" Then
				tmpCondition = ""
			else
				tmpCondition = " and cateid=" & uid & " "
			end if
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and ((addcate is not null and addcate<>0 and addcate in ("&qIntro&"))) "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join price b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del in (1,3) and complete not in (1,8) " & vbcrlf &_
			"where del in (1,3) " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title [title],convert(varchar(10),b.date7,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date1 desc,b.date7 desc"
			Case 153:
			cateCondition = " @MyPower_1_102 and (" & vbcrlf &_
			"((complete1<>1) and cateid="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (complete1=1 and kg="&uid&" @MyPower_16_102) /*待审批的提醒给审批人*/" & vbcrlf &_
			")"
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				tmpCondition = ""
			ElseIf qOpen=1 Then
				tmpCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
			else
				tmpCondition = " and 1=2"
			end if
			cateCondition = Replace(cateCondition,"@MyPower_1_102",tmpCondition)
			tmpCondition = ""
'cateCondition = Replace(cateCondition,"@MyPower_16_102",tmpCondition)
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join kumove b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid," &_
			"(case when complete1<>1 then 1 else 0 end) canCancelAlt,"&_
			"(case when complete1=4 or complete1=3 or complete1=5 then 11 when complete1=2 then 12 else 10 end) orderStat"
			orderBy = "order by b.ord desc"
			Case 154:
			tmpCondition = ""
			If m_fw1&""="0" Then
				tmpCondition = ""
			else
				tmpCondition = " and b.cateid=" & uid & " "
			end if
			cateCondition = "and (" & vbcrlf
			Call fillinPower(1,5,qOpen,qIntro)
			cateCondition = cateCondition & " ( b.sort1=1 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(2,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=8 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(3,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=2 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(4,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=3 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(5,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=4 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(22,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=5 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(41,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=6 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(42,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=7 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(75,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=75 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(95,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=102001 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			Call fillinPower(96,5,qOpen,qIntro)
			cateCondition = cateCondition & " or ( b.sort1=102002 "
			If qOpen = 3 Then
				cateCondition = cateCondition & ""
			ElseIf qOpen=1 Then
				cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
			else
				cateCondition = cateCondition & " and 1=2"
			end if
			cateCondition = cateCondition & " ) "
			cateCondition = cateCondition & " ) "
			cateCondition = " and (( 1=1 " & tmpCondition & " " & cateCondition & ") or b.share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(b.share as varchar(8000)),' ','')+',')>0)" & vbcrlf
			cateCondition = cateCondition & " ) "
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join reply b with(nolock)  on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and ISNULL(b.alt,0) = 0 and b.id1 is null " & vbcrlf &_
			"inner join tel t  with(nolock) on t.ord = b.ord and t.del=1 and t.sort3=1 " & vbcrlf &_
			"where b.del =1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],cast(b.intro as varchar(8000)) [title],convert(varchar(19),b.date7,"& iif(m_isMobileMode,"21","23") &") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by b.date7 desc"
			Case 155:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = " and iss_cateid=" & uid & " "
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and ((iss_addcateid is not null and iss_addcateid<>0 and iss_addcateid in ("&qIntro&") and car_addcateid in ("&qIntro&"))) "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join O_insure b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.iss_id and b.iss_del=1 and b.iss_warn = 1 and DATEDIFF(D,GETDATE(),b.iss_endtime)<= "& m_tq1 &" " & vbcrlf &_
			" inner join O_carData c  with(nolock) on c.car_id = b.iss_carid "& vbcrlf &_
			" inner join O_carSet s  with(nolock) on s.setType=3 and s.id=b.iss_type "&_
			"where iss_del =1 and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.iss_id [id],c.car_code+' ('+s.setname+')' title,iss_endtime dt,"&_
			"datediff(s,'&actDate&"
			orderBy = "order by iss_endtime desc"
			Case 157:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and (isnull(t.cateid,u.cateid) is not null and isnull(t.cateid,u.cateid)<>0 and u.cateid in ("&qIntro&")) "
			else
				cateCondition = " and 1=2 "
			end if
			tmpCondition = ""
			If m_fw1&""="2" Then
				tmpCondition = " and (isnull(t.cateid,0)=" & uid & " or isnull(u.cateid,0)=" & uid & ") "
			else
				tmpCondition = " and isnull(u.cateid,0)=" & uid & " "
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from MMsg_User u  with(nolock) " & vbcrlf &_
			"inner join ( " & vbcrlf &_
			"select userid,1 cnt,createtime lastTime from MMsg_Message  with(nolock) " & vbcrlf &_
			"where sendOrReceive = 1 and readed = 0 " & vbcrlf &_
			"and datediff(hh,dateadd(s,createTime,'1970-1-1 0:0:0'),getdate()) < 56 " & vbcrlf &_
			"where sendOrReceive = 1 and readed = 0 " & vbcrlf &_
			") m on u.id=m.userid " & vbcrlf &_
			"left join (" & vbcrlf &_
			"    select p.ord,tl.cateid from person p  with(nolock) " & vbcrlf &_
			"    left join tel tl on tl.ord = p.company " & vbcrlf &_
			") t on u.person=t.ord " & vbcrlf &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [ORDERBY]"
			fields = "u.id [id],u.nickname + '(' + cast(cnt as varchar) + ')' title,dateadd(hh,8,dateadd(s,lastTime,'1970-1-1 0:0:0')) dt,"&_
			"datediff(s,'&actDate&',dateadd(hh,8,dateadd(s,lastTime,'1970-1-1 0:0:0"
'[CATECONDITION] [ORDERBY]
			orderBy = "order by m.lastTime desc"
			Case 219:
			cateCondition =  " AND (charindex(',"& uid &",',','+replace(share,' ','')+',')>0 or b.share='1' or exists(select 1 from noticelist  with(nolock) where notice = b.id and cateid = "& uid &") ) "
'Case 219:
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			" INNER JOIN notice b  with(nolock) ON a.reminderConfig="& configId &" AND a.orderId = b.id AND b.del=1 "& vbcrlf &_
			" where b.del =1 " & vbcrlf &_
			" [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id], b.title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid], b.creator as cateid "
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 220:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & " AND b.Id in ( SELECT mr.Id FROM dbo.caigou_yg mr  with(nolock)   "&_
			"   inner join sp_ApprovalInstance c  with(nolock) on c.gate2=72001 and c.PrimaryKeyID = mr.Id and c.BillPattern in (0,1)  "&_
			"   WHERE mr.del<>2 and ((mr.status in (-1,0,1) and isnull(mr.Cateid,mr.Addcate) =" & uid &") "&_
			"   or (mr.status in (2,4,5) and charindex('," & uid &",',','+ c.SurplusApprover +',')>0))) "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN caigou_yg b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
			"0 canCancelAlt, " &_
			"(case status when -1 then 17 when 0 then 16 when 1 then 11 when 2 then 12 when 3 then 9 when 4 then 10 when 5 then 8 else 10 end) orderStat"
'0 canCancelAlt,  &_
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 17:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If m_fw1&""="0" Then
				tmpCondition = ""
			else
				tmpCondition = " and ord=" & uid & " "
			end if
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and ((ord is not null and ord<>0 and ord in ("&qIntro&"))) "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join "& vbcrlf &_
			" (select *,(select TOP 1 id from hr_person  with(nolock) where del = 0 AND userid=ord) as id from gate_person where del=1) "& vbcrlf &_
			" b on a.reminderConfig=" & configId & " and a.orderId = b.id and nowStatus not in (2,4) " & vbcrlf &_
			"where b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.name title,date3 dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.ord cateid"
			orderBy = "order by date3 desc"
			Case 156:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If Me.isSupperAdmin Then
				tmpCondition = ""
			else
				tmpCondition = " and 1 = 2 "
			end if
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and ((ord is not null and ord<>0 and ord in ("&qIntro&"))) "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join gate b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"where del =1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name title,date3 dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.ord cateid"
			orderBy = "order by date3 desc"
			Case 222:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If sdk.power.existsPower(80,17) Then
				cateCondition = "  "
			else
				cateCondition = " and 1=2"
			end if
			cateCondition =  cateCondition &" AND ((b.DisposeUser=" & uid & " and b.TreatmentStatus = -1) ) "
			cateCondition = " and 1=2"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join HrKQ_AttendanceAppeal b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ID " & vbcrlf &_
			"left join HrKQ_AttendanceType c with(nolock)  on c.onlyid = b.reason " &_
			"where 1 =1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ID [id],c.title title,b.CreateDate dt, datediff(s,'"& actDate &"',a.inDate) newTag,a.id [rid],b.userid cateid"
			orderBy = "order by b.CreateDate desc"
			Case 223 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.createID")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.CreateID="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (4,5) and charindex(',"& uid &",',','+ c.Approver +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.CreateID="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join HrKQ_AttendanceApply b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.isdel=0 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=8 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.CreateDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.createid cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.CreateDate desc"
			Case 52001 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_ManuPlansPre b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=52001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 51005 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_BOM b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=51005 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 54001 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_ManuOrders b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=54001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 54002 :
			Dim qxOpen,qxIntro
			Call fillInPower(m_qxlb,m_listqx,qxOpen,qxIntro)
			If qxOpen = 3 Then
				cateCondition = ""
			ElseIf qxOpen = 1 Then
				cateCondition = " and b.id in (select distinct b.id from reminderQueue a  with(nolock) " & vbcrlf &_
				"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
				"left join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+b.Cateid_WA+',')>0" & vbcrlf &_
				"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" AND plist.sort1 = 54 AND plist.sort2 = 1" & vbcrlf &_
				"where b.del=1 and b.ptype=0 and tempSave=0 and b.[status]<>2" & vbcrlf &_
				"and (plist.qx_open = 3 OR CHARINDEX(','+CAST(g1.ord AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0))"
'where b.del=1 and b.ptype=0 and tempSave=0 and b.[status]<>2 & vbcrlf &_
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c with(nolock) on c.gate2=54002 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 54003 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_OutOrder b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=54003 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 52002 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_ManuPlans b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=52002 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 55001 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_MaterialOrders b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and b.MaterialType in (1,2) " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=55001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 55006 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_MaterialOrders b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and b.MaterialType = 3 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=55006 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 56001 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.Approver +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_PriceRate b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=56001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 55002 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_MaterialRegisters b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and b.OrderType = 2 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=55002 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 55003 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_MaterialRegisters b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and b.OrderType = 3 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=55003 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 56007 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.Approver +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_TimeWages b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=56007 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 56008 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.Approver +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_Wage_JS b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c with(nolock)  on c.gate2=56008 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 160 :
			cateCondition =  " AND "& uid &"=b.cateid "
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			" INNER JOIN M2_RewardPunish b  with(nolock) ON a.reminderConfig="& configId &" AND a.orderId = b.id AND b.del=1 "& vbcrlf &_
			" where b.del =1 " & vbcrlf &_
			" [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id], b.title,convert(varchar(10),b.RPdate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid], b.creator as cateid "
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 54007:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and M2WFPA.id in (select  M2WFPA.id from reminderQueue a  with(nolock) " & vbcrlf &_
				"inner join (SELECT M2WFPA.ID FROM M2_WFP_Assigns M2WFPA  with(nolock) " & vbcrlf &_
				"left join erp_Gxdqtx_status M2WA  with(nolock) on M2WFPA.WAID = M2WA.ID and M2WA.del = 1 and M2WA.tempSave = 0 " & vbcrlf &_
				"left join M2_WorkingProcedures M2WP  with(nolock) on M2WP.ID = M2WFPA.WPID  " & vbcrlf &_
				"left join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+isnull(M2WFPA.cateid,'')+','+isnull(M2WA.Cateid_WA,'')+','+isnull(M2WP.Wheelman,'')+',')>0  " & vbcrlf &_
				"left join M2_WorkingProcedures M2WP  with(nolock) on M2WP.ID = M2WFPA.WPID  " & vbcrlf &_
				"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" and plist.sort1=5031 AND plist.sort2=1" & vbcrlf &_
				" where M2WFPA.del=1 and isnull(M2WFPA.isOut,0)=0  and tempSave=0 " & vbcrlf &_
				" AND (plist.qx_open = 3 or dbo.existsPower2(plist.qx_intro, isnull(M2WFPA.cateid, '') + ',' + isnull(M2WA.Cateid_WA, ''), ',') = 1) "& vbcrlf &_
				" where M2WFPA.del=1 and isnull(M2WFPA.isOut,0)=0  and tempSave=0 " & vbcrlf &_
				" AND M2WA.[Status]<>2  AND M2WA.wastatus!='生产完毕' AND ISNULL(M2WA.SPStatus,-1) IN(-1,1)"& vbcrlf &_
				" where M2WFPA.del=1 and isnull(M2WFPA.isOut,0)=0  and tempSave=0 " & vbcrlf &_
				" AND ISNULL(M2WFPA.Finished, 0) = 0"& vbcrlf &_
				" AND NOT EXISTS(SELECT 1 FROM M2_CostComputation  with(nolock) WHERE complete1=1 and datediff(mm,date1,M2WA.DateStart)=0)  GROUP BY M2WFPA.ID)  M2WFPA  ON  a.reminderConfig= " & configId & "  and a.orderId = M2WFPA.id) "
			else
				cateCondition = " and 1=2"
			end if
			If m_fw1&""="1" Then
				tmpCondition = " and charindex(','+cast(" & uid & " as varchar(12))+',',','+isnull(M2WFPA.cateid,'')+','+isnull(M2WA.Cateid_WA,'')+','+isnull(M2WP.Wheelman,'')+',')>0"
'If m_fw1&""="1" Then
			else
				tmpCondition = " and (plist.qx_open = 3  OR CHARINDEX(','+CAST(g1.ord AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0)"
'If m_fw1&""="1" Then
			end if
			cateCondition =  " " & tmpCondition & " " & cateCondition & " and datediff(d,getdate(),M2WFPA.dateEnd)<=" & m_tq1 & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join (SELECT  M2WFPA.id,M2WA.title,M2WP.WPName,M2WFPA.DateEnd,M2WFPA.cateid,M2WA.indate  from M2_WFP_Assigns M2WFPA   with(nolock)    " & vbcrlf &_
			"left join erp_Gxdqtx_status M2WA  with(nolock) on M2WFPA.WAID = M2WA.ID and M2WA.del = 1 and M2WA.tempSave = 0  " & vbcrlf &_
			"left join M2_WorkingProcedures M2WP  with(nolock) on M2WP.ID = M2WFPA.WPID   " & vbcrlf &_
			"left join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+isnull(M2WFPA.cateid,'')+','+isnull(M2WA.Cateid_WA,'')+','+isnull(M2WP.Wheelman,'')+',')>0 " & vbcrlf &_
			"left join M2_WorkingProcedures M2WP  with(nolock) on M2WP.ID = M2WFPA.WPID   " & vbcrlf &_
			"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" and plist.sort1=5031 AND plist.sort2=1 " & vbcrlf &_
			"WHERE  M2WFPA.del=1 and isnull(M2WFPA.isOut,0)=0  and charindex(','+cast(" & uid & " as varchar(12))+',',','+isnull(M2WFPA.cateid,'')+','+isnull(M2WA.Cateid_WA,'')+','+isnull(M2WP.Wheelman,'')+',')>0 and tempSave=0 " & vbcrlf &_
			" AND M2WA.[Status]<>2  AND M2WA.wastatus!='生产完毕' AND ISNULL(M2WA.SPStatus,-1) IN(-1,1) "& vbcrlf &_
			" AND ISNULL(M2WFPA.Finished, 0) = 0"& vbcrlf &_
			" AND NOT EXISTS(SELECT 1 FROM M2_CostComputation  with(nolock) WHERE complete1=1 and datediff(mm,date1,M2WA.DateStart)=0) "& vbcrlf &_
			"[CATECONDITION]  "& vbcrlf &_
			" GROUP BY  M2WFPA.id,M2WA.title,M2WP.WPName,M2WFPA.DateEnd,M2WFPA.cateid,M2WA.indate) M2WFPA ON  a.reminderConfig=" & configId & " and a.orderId = M2WFPA.id  "& vbcrlf &_
			"[CANCELCONDITION] [ORDERBY]"
			fields = "M2WFPA.id,isnull(M2WFPA.title,'')+'['+ISNULL(M2WFPA.WPName,'')+']' as title ,convert(varchar(10),M2WFPA.DateEnd,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],M2WFPA.cateid"
'[CANCELCONDITION] [ORDERBY]
			orderBy = "order by M2WFPA.indate desc"
			Case 540071:
			tmpCondition = ""
			cateCondition = ""
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WFP_Assigns wfpa  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = wfpa.id and wfpa.del=1 and isnull(wfpa.ExecTask,0) = 1 " & vbcrlf &_
			"inner join M2_WorkAssigns wa  with(nolock) on wfpa.waid = wa.id and wa.del=1 " & vbcrlf &_
			"inner join M2_WorkingProcedures wp  with(nolock) on wfpa.wpid = wp.id and wp.del=1 " & vbcrlf &_
			"where 1=1 and (dbo.existsPower2(wp.wheelman,'" & uid & "',',') = 1 or dbo.existsPower2(wfpa.cateid,'" & uid & "',',') = 1)" & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "wfpa.id [id],wa.title+'('+wp.WPName+')' as title,wa.inDate dt,datediff(s,'"&actDate&"',wa.inDate) newTag,a.id [rid],(wa.Cateid_WA+','+wp.wheelman+','+wfpa.cateid) cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by wa.inDate desc"
			Case 540072:
			tmpCondition = ""
			cateCondition = ""
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WFPTask_Assigns task  with(nolock) on a.reminderConfig=""" & configId & " and a.orderId = task.id and task.beginStatus = 0 and not exists(select top 1 1 from M2_ProcedureProgres  with(nolock) where del = 1 and TaskID = task.ID) and dbo.existsPower2(task.cateid,'" & uid & "',',') = 1" & vbcrlf &_
			"inner join M2_WFP_Assigns wfpa  with(nolock) on task.wfpaid = wfpa.id and wfpa.del=1 " & vbcrlf &_
			"inner join M2_WorkAssigns wa  with(nolock) on wfpa.waid = wa.id and wa.del=1 " & vbcrlf &_
			"inner join M2_WorkingProcedures wp  with(nolock) on wfpa.wpid = wp.id and wp.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "task.id [id],wa.title+'('+wp.WPName+')' as title,task.inDate dt,datediff(s,'"&actDate&"',task.inDate) newTag,a.id [rid],(wa.Cateid_WA+','+wp.wheelman+','+wfpa.cateid) cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by task.inDate desc"
			Case 540073:
			tmpCondition = ""
			cateCondition = ""
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join (" & vbcrlf &_
			"   select isnull(batchid,id) id,indate,creator,wfpaid from M2_ProcedureProgres with(nolock) " & vbcrlf &_
			"   where del = 1 and checkresult = 2 and CheckPerson = "& uid &_
			"   group by isnull(batchid,id),indate,creator,wfpaid" & vbcrlf &_
			") aa on a.reminderConfig =  " & configId & " and a.orderId = aa.id" & vbcrlf &_
			"inner join M2_WFP_Assigns wfpa  with(nolock) on aa.wfpaid = wfpa.id and wfpa.del=1 " & vbcrlf &_
			"inner join M2_WorkAssigns wa  with(nolock) on wa.id = wfpa.waid " & vbcrlf &_
			"inner join M2_WorkingProcedures wp  with(nolock) on wfpa.wpid = wp.id and wp.del=1" & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "aa.[id],wa.title+'('+wp.WPName+')' as title,aa.inDate dt,datediff(s,'"&actDate&"',aa.inDate) newTag,a.[id] [rid],(wa.Cateid_WA+','+wp.wheelman+','+wfpa.cateid+','+cast(aa.Creator as varchar(20))) cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by aa.inDate desc"
			Case 51001:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			cateCondition = " and charindex(','+CAST(" & uid & " as varchar(10))+',',','+replace(CONVERT(VARCHAR(8000),remindPerson),' ','')+',')>0 " &_
			"AND DATEDIFF(d, GETDATE() ,(CASE remindunit WHEN 1 THEN DATEADD(HOUR,remindcyc,begindate)  " &_
			"  WHEN 2 THEN DATEADD(DAY,remindcyc,begindate) END))<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_MachineComponent b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id,b.title,convert(varchar(10),(CASE remindunit WHEN 1 THEN DATEADD(HOUR,remindcyc,begindate) "  &_
			"  WHEN 2 THEN DATEADD(DAY,remindcyc,begindate) END),23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.remindPerson as cateid"
			orderBy = "order by (CASE remindunit WHEN 1 THEN DATEADD(HOUR,remindcyc,begindate) "  &_
			"  WHEN 2 THEN DATEADD(DAY,remindcyc,begindate) END) desc,b.indate desc"
			Case 55004 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_MaterialRegisters b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and b.OrderType = 1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=55004 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.date1 dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.date1 desc"
			Case 51011:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			cateCondition = " and charindex(','+CAST(" & uid & " as varchar(10))+',',','+replace(CONVERT(VARCHAR(8000),cateid),' ','')+',')>0 " &_
			"AND DATEDIFF(d, GETDATE() ,(CASE Unit2 WHEN 0 THEN DATEADD(MINUTE,num2,date1) " &_
			"  WHEN 1 THEN DATEADD(HOUR,num2,date1) WHEN 2 THEN DATEADD(DAY,num2,date1) WHEN 3 THEN DATEADD(MONTH,num2,date1) " &_
			"  WHEN 4 THEN DATEADD(YEAR,num2,date1) end))<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_maintain b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id,b.title,convert(varchar(10),(CASE Unit2 WHEN 0 THEN DATEADD(MINUTE,num2,date1) " & vbcrlf &_
			"  WHEN 1 THEN DATEADD(HOUR,num2,date1) WHEN 2 THEN DATEADD(DAY,num2,date1) WHEN 3 THEN DATEADD(MONTH,num2,date1) " & vbcrlf &_
			"  WHEN 4 THEN DATEADD(YEAR,num2,date1) end),23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by (CASE Unit2 WHEN 0 THEN DATEADD(MINUTE,num2,date1) " & vbcrlf &_
			"  WHEN 1 THEN DATEADD(HOUR,num2,date1) WHEN 2 THEN DATEADD(DAY,num2,date1) WHEN 3 THEN DATEADD(MONTH,num2,date1) " & vbcrlf &_
			"  WHEN 4 THEN DATEADD(YEAR,num2,date1) end) desc,b.indate desc"
			Case 54013:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If m_fw1&""="1" Then
				tmpCondition = " AND b.ourperson="& uid &""
			end if
			cateCondition = " where isnull(ool.Mergeinx,0)>=0 " & tmpCondition & " AND (plist.qx_open = 3  OR CHARINDEX(','+CAST(b.ourperson AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0) AND DATEDIFF(d, GETDATE() ,DateDelivery)<=" & m_tq1
			tmpCondition = " AND b.ourperson="& uid &""
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			"inner join M2_OutOrder b  with(nolock) on b.wwType=0 and  a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"inner join M2_OutOrderlists ool  with(nolock) on ool.outID = b.ID " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"left join dbo.power plist  with(nolock) ON plist.ord = & uid & AND plist.sort1 = 5025 AND plist.sort2 = 1" & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id,b.title,convert(varchar(10),ool.DateDelivery,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by ool.DateDelivery desc,b.indate desc"
			Case 54016:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			If m_fw1&""="1" Then
				tmpCondition = " AND b.ourperson="& uid &""
			end if
			cateCondition = " where isnull(ool.Mergeinx,0)>=0 " & tmpCondition & " AND (plist.qx_open = 3  OR CHARINDEX(','+CAST(b.ourperson AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0) AND DATEDIFF(d, GETDATE() ,DateDelivery)<=" & m_tq1
'tmpCondition = " AND b.ourperson="& uid &""
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			"inner join M2_OutOrder b  with(nolock) on b.wwType=1 and a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"inner join M2_OutOrderlists ool  with(nolock) on ool.outID = b.ID " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" AND plist.sort1 = 5026 AND plist.sort2 = 1" & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id,b.title,convert(varchar(10),ool.DateDelivery,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by ool.DateDelivery desc,b.indate desc"
			Case 54006:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a   with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_OutOrder b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=54006 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 51003 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_WorkingFlows b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=51003 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.WFName,b.indate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.indate desc"
			Case 51005 :
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_BOM b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=51005 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.inDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 54009:
			Call fillinPower(m_qxlb,m_listqx,qOpen,"b.creator")
			cateCondition = cateCondition &" and CKUser ="& uid &_
			"   and ool.QTResult>0 and isnull(b.CkStatus,0)=0  AND DATEDIFF(d, GETDATE() ,QTDate)<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_QualityTestings b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"inner join (select QTID,sum(QTResult) QTResult from M2_QualityTestingLists  with(nolock) where del=1 group by QTID) ool on ool.QTID = b.ID " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id,b.title,convert(varchar(10),b.QTDate,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.QTDate desc"
			Case 54004:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition =cateCondition & " and CKUser ="& uid &_
			" and ool.QTResult>0 and isnull(b.CkStatus,0)=0 AND DATEDIFF(d, GETDATE() ,QTDate)<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_QualityTestings b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
			"inner join (select QTID,sum(QTResult) QTResult from M2_QualityTestingLists  with(nolock) where del=1 group by QTID) ool on ool.QTID = b.ID " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id,b.title,convert(varchar(10),b.QTDate,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.QTDate desc"
			Case 57004:
			tmpCondition = ""
			cateCondition = ""
			sql = "select COUNT(*) REMIND_CNT from (" & vbcrlf &_
			" SELECT t.ID,t.Title,t.TaskDate,t.Creator,tl.QcCateid FROM dbo.M2_GXQualityTestingTask t  with(nolock) " & vbcrlf &_
			" INNER JOIN dbo.M2_GXQualityTestingTaskList tl  with(nolock) ON t.ID = tl.TaskID " & vbcrlf &_
			" WHERE tl.QCStatus != 2 GROUP BY t.ID,t.Title,t.TaskDate,t.Creator,tl.QcCateid " & vbcrlf &_
			" ) a " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"where a.QcCateid ="& uid &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "a.ID [id],a.Title as title,a.TaskDate as dt,a.TaskDate as newTag,a.ID [rid],a.Creator cateid"
			orderBy = "order by a.TaskDate desc"
			Case 56004 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_Wage_JJ b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=56004 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.CountDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 56008 :
			cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join M2_Wage_JS b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=56008 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,b.CountDate dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.inDate desc"
			Case 45001:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(b.[status] in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (b.[status] in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(b.[status] in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join bankin b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=45001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),b.date3 ,120) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.date7 desc"
			Case 45002:
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(b.[status] in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (b.[status] in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(b.[status] in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			")"
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join bankout b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=45002 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title,convert(varchar(10),b.date3 ,120) dt,"&_
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid," &_
			"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
			" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
			orderBy = "order by b.date7 desc"
			Case 47003:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			tmpCondition = ""
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and b.id in (select distinct b.id from reminderQueue a  with(nolock) " & vbcrlf &_
				"inner join AcceptanceDraft b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
				"left join gate g1  with(nolock) on g1.ord = b.creator" & vbcrlf &_
				"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" AND plist.sort1 = 1101 AND plist.sort2 = 1" & vbcrlf &_
				"where b.del=1" & vbcrlf &_
				"and (plist.qx_open = 3 OR CHARINDEX(','+CAST(g1.ord AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0))"
			else
				cateCondition = " and 1=2"
			end if
			If m_fw1&""="1" Then
				tmpCondition = " and "& uid &" = creator"
			end if
			cateCondition =  " " & tmpCondition & " " & cateCondition & " and datediff(d,getdate(),b.LimitEndDate)<=" & m_tq1 & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join AcceptanceDraft b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"where b.del=1" &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id,b.sn title ,b.LimitEndDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
			orderBy = "order by b.LimitEndDate"
			Case Else :
			sql = ""
			fields = ""
			End Select
			If withoutOrderBy Then
				sql = Replace(sql,"[ORDERBY]","")
			end if
			If mode = "cnt" Then
				sql = Replace(sql,"[ORDERBY]","")
			ElseIf mode = "top" Then
				sql = Replace(Replace(sql,"COUNT(*) REMIND_CNT","top " & (m_num1) & " " & fields),"[ORDERBY]", orderBy)
			ElseIf mode = "all" Then
				sql = Replace(Replace(sql,"COUNT(*) REMIND_CNT",fields),"[ORDERBY]", orderBy)
			ElseIf mode = "ids" Then
				fields = Split(fields,"[id],")(0)
				sql = Replace(Replace(sql,"COUNT(*) REMIND_CNT","top 100 percent " & fields & "id"),"[ORDERBY]", orderBy)
			ElseIf mode = "rids" Then
				fields = Split(fields,",")
				Dim findFlag
				findFlag = False
				For i = 0 To ubound(fields)
					If InStr(1,fields(i),"[rid]",1)>0 Then
						sql = Replace(Replace(sql,"COUNT(*) REMIND_CNT","top 100 percent " & fields(i)),"[ORDERBY]", orderBy)
						findFlag = True
						Exit For
					end if
				next
				If findFlag = False Then
					Response.write "sql语句里面缺少rid字段，无法提取该字段的语句"
					Response.end
				end if
			else
				Response.write "不支持的模式参数"
				Response.end
			end if
			If withoutCateCondition Then
				sql = Replace(sql,"[CATECONDITION]","")
			else
				sql = Replace(sql,"[CATECONDITION]",cateCondition)
			end if
			If withoutCancelCondition Then
				sql = Replace(Replace(sql,"[CANCELCONDITION]",""),"[CANCELJOINTABLE]","")
			else
				sql = Replace(Replace(sql,"[CANCELCONDITION]",cancelCondition),"[CANCELJOINTABLE]",cancelJoinTable)
			end if
			listSQL = sql
		end function
		Public Property Get remindCount
		Dim sql,rs
		If isEmpty(m_remindCount) Then
			If m_hasModule = False Then
				m_remindCount = 0
			else
				If isCleanMode Then
					sql = "select count(*) from reminderQueue a  with(nolock) "&_
					"inner join (" & listSQL("all_withoutCateCondition_withoutOrderBy_withoutCancelCondition") & ") b on a.id=b.rid " &_
					"where datediff(s,a.inDate,'"&dateBegin&"')>=0"
				else
					sql = listSQL("cnt")
				end if
				If displaySqlOnCount = true Then
					Response.write "<div style='border:1px solid red'>"&_
					"m_name&""(""&configId&"")---remindCount:<br>""&Replace(server.HTMLEncode(sql),vbcrlf,""<br>"")&""""&_"
					Response.write "<div style='border:1px solid red'>"&_
					"</div>"
				end if
				on error resume next
				Err.clear
				If m_usingLv2Cache And isCleanMode <> True Then
					m_remindCount = CLng(m_cacheHelper.GetCacheRecord(sql,m_cacheExpiredCondition,True,True,uid&"-"&configId&"-"&m_subCfgId&"-count")(0))
'If m_usingLv2Cache And isCleanMode <> True Then
				else
					m_remindCount = CLng(Me.cn.execute(sql)(0))
				end if
				If Err.number <> 0 Then
					Response.Clear()
					Response.write "提醒【"&m_name&"("&configId&")】读取过程中，以下语句执行错误：<br><hr>"
					Response.write Replace(server.HTMLEncode(sql),vbcrlf,"<br>") & "<hr>" & _
					"cacheExpiredCondition:<br>" & Replace(m_cacheExpiredCondition,vbcrlf,"<br>")
					Response.end
				end if
				On Error GoTo 0
			end if
		end if
		remindCount = m_remindCount
		End Property
		Public Sub remindShow
			If m_hasModule = False Then Exit Sub
			on error resume next
			Dim rs,sql,i,j
			Set rs = server.CreateObject("adodb.recordset")
			If isCleanMode Then
				If pageIndex < 1 Then pageIndex = 1
				sql = "select b.*,convert(varchar(19),a.inDate,21) inDate from reminderQueue a  with(nolock) "&_
				"inner join (" & listSQL("all_withoutCateCondition_withoutCancelCondition_withoutOrderBy") & ") b on a.id=b.rid "&_
				"where datediff(s,a.inDate,'"&dateBegin&"')>=0"
				rs.open sql,cn,1,1
				recCount = rs.RecordCount
				rs.PageSize = pageSize
				pageCount = rs.pageCount
				If CLng(pageIndex) > CLng(pageCount) Then pageIndex = pageCount
				If rs.eof = False Then
					rs.AbsolutePage = pageIndex
				end if
				If Err.number <> 0 Then
					Response.Clear()
					Response.write "提醒【"&m_name&"("&configId&")】读取过程中，以下语句执行错误：<br><hr>"
					Response.write Replace(server.HTMLEncode(sql),vbcrlf,"<br>") & "<hr>" & _
					"cacheExpiredCondition:<br>" & Replace(m_cacheExpiredCondition,vbcrlf,"<br>")
					Response.end
				end if
			else
				sql = listSQL("top")
				If m_usingLv2Cache Then
					Set rs = m_cacheHelper.GetCacheRecord(sql,m_cacheExpiredCondition,True,True,uid&"-"&configId&"-"&m_subCfgId&"list")
'If m_usingLv2Cache Then
				else
					rs.open sql,cn,1,1
				end if
				If Err.number <> 0 Then
					Response.Clear()
					Response.write "提醒【"&m_name&"("&configId&")】读取过程中，以下语句执行错误：<br><hr>"
					Response.write Replace(server.HTMLEncode(sql),vbcrlf,"<br>") & "<hr>" & _
					"cacheExpiredCondition:<br>" & Replace(m_cacheExpiredCondition,vbcrlf,"<br>")
					Response.end
				end if
			end if
			If displaySqlOnShow = true Then
				Response.write "<div style='border:1px solid red'>"&_
				"m_name&""(""&configId&"")---remindShow:<br>""&Replace(server.HTMLEncode(sql),vbcrlf,""<br>"")&""""&_"
				Response.write "<div style='border:1px solid red'>"&_
				"</div>"
			end if
			Response.write "" & vbcrlf & "             <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" " & vbcrlf & "                 "
			Response.write IIf(isCleanMode,"style='table-layout:fixed;'","")
			Response.write " bgcolor=""#C0CCDD"" class=""reminder home detailTable"" " & vbcrlf & "                    cfgId="""
			Response.write configId
			Response.write """ subId="""
			Response.write m_subCfgId
			Response.write """>" & vbcrlf & "                "
			If isCleanMode <> True Then
				Response.write "" & vbcrlf & "                     <tr class=""top tbheader OnlyHeader"">" & vbcrlf & "                              <td colspan=""2"" valign=""center"" height=""30"" onMouseOut=""RemObj.toggleBar(this,false);"" onmouseover=""RemObj.toggleBar(this,true);"">" & vbcrlf & "                                        <span style=""float:left"">"
				Response.write m_name
				Response.write "(<a href="""
				Response.write moreLinkURL()
				Response.write """ style='color:red'>"
				Response.write remindCount
				Response.write "</a>)</span>" & vbcrlf & "                                 <span class=""alt_title"" style=""float:left;display:none;"">" & vbcrlf & "                                           <a href=""javascript:void(0)"" onclick=""altChgOrder("
				Response.write m_setjmId
				Response.write ","
				Response.write m_subCfgId
				Response.write ",1,this)"" title=""左移"">←</a>" & vbcrlf & "                                               <a href=""javascript:void(0)"" onclick=""altChgOrder("
				Response.write m_setjmId
				Response.write ","
				Response.write m_subCfgId
				Response.write ",2,this)"" title=""上移"">↑</a>" & vbcrlf & "                                               <a href=""javascript:void(0)"" onclick=""altChgOrder("
				Response.write m_setjmId
				Response.write ","
				Response.write m_subCfgId
				Response.write ",3,this)"" title=""下移"">↓</a>" & vbcrlf & "                                               <a href=""javascript:void(0)"" onclick=""altChgOrder("
				Response.write m_setjmId
				Response.write ","
				Response.write m_subCfgId
				Response.write ",4,this)"" title=""右移"">→</a>" & vbcrlf & "                                               <a href=""javascript:void(0)"" onclick=""altChgOrder("
				Response.write m_setjmId
				Response.write ","
				Response.write m_subCfgId
				Response.write ",5,this)"" title=""关闭"">×</a>" & vbcrlf & "                                       </span>" & vbcrlf & "                                 <span style=""float:right;"">"
				Response.write getMoreLink()
				Response.write "</span>" & vbcrlf & "                      "
				If m_remindMode = "CYCLE" Then
					Response.write "" & vbcrlf & "                                     <span class=""alt_refreshBtn"" style=""float:right;padding-right:10px;"">" & vbcrlf & "                                               <img src=""../images/refresh.png"" class=""alt_refreshImg"" border=""0"" width=""12px"" alt=""手动更新""" & vbcrlf & "                                                    style=""cursor:pointer;"" onclick=""RemObj.refresh("
'If m_remindMode = "CYCLE" Then
					Response.write m_setjmId
					Response.write ","
					Response.write m_subCfgId
					Response.write ",this);""/>" & vbcrlf & "                                        </span>" & vbcrlf & "                                 <span class=""alt_refreshTime"" style=""float:right;font-weight:normal;padding-right:10px;"">上次更新："
					Response.write m_subCfgId
					Response.write m_lastReloadDate
					Response.write "</span>" & vbcrlf & "                                      "
				end if
				Response.write "" & vbcrlf & "                             </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
			Else
				Response.write "" & vbcrlf & "                     <tr class=""top"">" & vbcrlf & "                          <td width=""36"">&nbsp;</td>" & vbcrlf & "                                <td>主题</td>" & vbcrlf & "                           <td width=""150"">添加时间</td>" & vbcrlf & "                             <td width=""150"" style=""text-align:center"">" & vbcrlf & "                                  <select onchange=""loadList("
'Else
				Response.write pageIndex
				Response.write ",this.value);"">" & vbcrlf & "                                           <option value=""10"" "
				Response.write IIf(pageSize=10," selected","")
				Response.write ">每页显示10条</option>" & vbcrlf & "                                               <option value=""20"" "
				Response.write IIf(pageSize=20," selected","")
				Response.write ">每页显示20条</option>" & vbcrlf & "                                               <option value=""30"" "
				Response.write IIf(pageSize=30," selected","")
				Response.write ">每页显示30条</option>" & vbcrlf & "                                               <option value=""50"" "
				Response.write IIf(pageSize=50," selected","")
				Response.write ">每页显示50条</option>" & vbcrlf & "                                               <option value=""100"" "
				Response.write IIf(pageSize=100," selected","")
				Response.write ">每页显示100条</option>" & vbcrlf & "                                              <option value=""200"" "
				Response.write IIf(pageSize=200," selected","")
				Response.write ">每页显示200条</option>" & vbcrlf & "                                      </select>" & vbcrlf & "                               </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
			end if
			i = 0
			If rs.eof Then
				If remindCount > 0 Then
					Response.write "" & vbcrlf & "                     <tr><td colspan=""4"" align=""center"">您设置的显示行数为0，无信息可显示</td></tr>" & vbcrlf & "                      "
				else
					Response.write "" & vbcrlf & "                     <tr><td colspan=""4"" style=""height:107px"" align=""center"">没有信息！</td></tr>" & vbcrlf & "                  "
				end if
			else
				While rs.eof = False And ((isCleanMode = True And i < pageSize) Or isCleanMode = False)
					Response.write "" & vbcrlf & "                     <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                           "
					If isCleanMode = True Then
						Response.write "<td><input type='checkbox' class='delRids' value='" & rs("rid") & "'/></td>" & vbcrlf
					end if
					Response.write "" & vbcrlf & "                             <td class=""name"" width=""57%"">"
					Response.write getTitleHTML(rs)
					Response.write "</td>" & vbcrlf & "                                <td align=""center"">"
					Response.write getDtHTML(rs)
					Response.write "</td>" & vbcrlf & "                                "
					If isCleanMode = True Then
						Response.write "" & vbcrlf & "                             <td align=""center""><input type=""button"" onclick=""dropRemind("
						Response.write rs("rid")
						Response.write ");"" value=""清理此提醒"" class=""anybutton2""/></td>" & vbcrlf & "                              "
					end if
					Response.write "" & vbcrlf & "                     </tr>" & vbcrlf & "                           "
					i=i+1
					Response.write "" & vbcrlf & "                     </tr>" & vbcrlf & "                           "
					rs.movenext
				wend
			end if
			If  isCleanMode <> True Then
				If remindCount > 0 Then
					For j=i To m_num1 - 1
'If remindCount > 0 Then
						Response.write "<tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">"&_
						"<td class=""name"" colspan=""4"">&nbsp;</td>"&_
						"</tr>"
					next
				end if
			else
				Response.write "" & vbcrlf & "                     <tr>" & vbcrlf & "                            <td><input type='checkbox' onclick=""checkAll(this);""/></td>" & vbcrlf & "                               <td colspan=""3"" align=""right"">" & vbcrlf & "                                      <table style=""width:100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "                                           <tr>" & vbcrlf & "                                                    <td width=""100px"">" & vbcrlf & "                                                             <input type=""button"" value=""批量清理"" class=""anybutton2"" onclick=""dropRemind();""/>" & vbcrlf & "                                                      </td>" & vbcrlf & "                                                   <td align=""right"">" & vbcrlf & "                                                                共"
				Response.write recCount
				Response.write "条&nbsp;"
				Response.write pageSize
				Response.write "/页&nbsp;"
				Response.write pageIndex
				Response.write "/"
				Response.write pageCount
				Response.write "页" & vbcrlf & "                                                             <input type=""text"" id=""jppgidx"" style=""width:40px"" maxlength=""8"" value="""
				Response.write pageIndex
				Response.write """ " & vbcrlf & "                                                                  onfocus=""this.select();""" & vbcrlf & "                                                                  onkeydown=""pageKeyup(this);""" & vbcrlf & "                                                                      title=""按回车可翻页""" & vbcrlf & "                                                              />" & vbcrlf & "                                                              <input type=""button"" value=""跳转"" class=""page"" onclick=""if(!isNaN($('#jppgidx').val())) loadList($('#jppgidx').val(),"
				Response.write pageSize
				Response.write ")""/>" & vbcrlf & "                                                               <input type=""button"" value=""首页"" class=""page"" onclick=""loadList("
				Response.write 1&","&pageSize
				Response.write ");""/>" & vbcrlf & "                                                              <input type=""button"" value=""上页"" class=""page"" onclick=""loadList("
				Response.write (pageIndex-1)&","&pageSize
				Response.write ");""/>" & vbcrlf & "                                                              <input type=""button"" value=""下页"" class=""page"" onclick=""loadList("
				Response.write (pageIndex+1)&","&pageSize
				Response.write ");""/>" & vbcrlf & "                                                              <input type=""button"" value=""尾页"" class=""page"" onclick=""loadList("
				Response.write pageCount&","&pageSize
				Response.write ");""/>" & vbcrlf & "                                                      </td>" & vbcrlf & "                                           </tr>" & vbcrlf & "                                   </table>" & vbcrlf & "                                </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
			end if
			Response.write "" & vbcrlf & "              </table>" & vbcrlf & "                "
			If Err.number<>0 Then
				dim errtxt
				errtxt = err.Description
				if instr(errtxt,"未找到项目")>0 then
					errtxt = errtxt & " <br>sql查询需要提供【rid】,【cateid】,【title】,【newTag】列，请检查SQL是否正确支持。"
				end if
				Response.write Replace("以下语句执行错误：<br>" & server.HTMLEncode(sql) & "<div style='padding:10px;background-color:#ffff00'>错误提示语：" & errtxt & "</div>", vbcrlf , "<br>")
				errtxt = errtxt & " <br>sql查询需要提供【rid】,【cateid】,【title】,【newTag】列，请检查SQL是否正确支持。"
				cn.close
				Response.end
			end if
		end sub
		Public Function getTitleHTML(ByRef rs)
			Dim ttArr,ttStr
			Select Case m_setjmId
			Case 7:
			ttArr = Split(rs("title"),Chr(11)&Chr(12))
			If m_isMobileMode Then
				getTitleHTML = getTitleHTML & ttArr(0)'rs("title")
			else
				getTitleHTML = getTitleHTML & "<span style='float:left;color:#5b7cae'>"&getTitleLink(ttArr(0),rs("id"),rs("cateid")) & "</span>"
				getTitleHTML = getTitleHTML & "<span style='float:right;'>("&ttArr(1)&")</span>"
			end if
			Case 225:
			Dim showTitle2
			showTitle2 = rs("title")
			If InStr(rs("title"),"@code:") > 0 Then
				showTitle2 = eval(REPLACE(rs("title"),"@code:",""))
			end if
			If m_isMobileMode Then
				getTitleHTML = getTitleHTML & showTitle2
			else
				getTitleHTML = getTitleHTML & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
				getTitleHTML = getTitleHTML & "     <tr>"&_
				"<td style=""background-Color:transparent;"">" &_
				"getTitleLink(showTitle2,rs(""id""),rs(""cateid""))" &_
				"<span style='float:right;'>"&rs("WorkLong")&"小时</span>" &_
				"IIf(rs(""newTag"")>=0,""<span class='alt_tx'></span>"","""")" &_
				"</td>" &_
				"</table>"
			end if
			Case Else:
			Dim showTitle
			showTitle = rs("title")
			If InStr(rs("title"),"@code:") > 0 Then
				showTitle = eval(REPLACE(rs("title"),"@code:",""))
			end if
			If m_isMobileMode Then
				getTitleHTML = getTitleHTML & showTitle
			else
				getTitleHTML = getTitleHTML & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
				getTitleHTML = getTitleHTML & "     <tr>"&_
				"<td style=""background-Color:transparent;color:#5b7cae"">" &_
				"getTitleLink(showTitle,rs(""id""),rs(""cateid""))" &_
				"IIf(rs(""newTag"")>=0,""<span class='alt_tx'></span>"","""")" &_
				"</td>"
			end if
			If hasStatField(rs) And showStatusField Then
				If rs("orderStat")>0 Then
					If m_isMobileMode Then
						getTitleHTML = getTitleHTML & Chr(11) & Chr(12) & "(" & getOrderStat(rs("orderStat")) & ")"
					else
						getTitleHTML = getTitleHTML & "<td width='80px' style=""background-Color:transparent;"">("&getOrderStat(rs("orderStat"))&")</td>"
'getTitleHTML = getTitleHTML & Chr(11) & Chr(12) & "(" & getOrderStat(rs("orderStat")) & ")"
					end if
				end if
			end if
			If Not m_isMobileMode Then
				getTitleHTML = getTitleHTML & "     </tr>" &_
				"</table>"
			end if
			End Select
		end function
		Public Function getDtHTML(ByRef rs)
			Dim dtArr,dtStr,dtType
			If isCleanMode Then
				getDtHTML = getDtHTML & rs("inDate")
			else
				If configId = 7 Then
					If m_isMobileMode Then
						dtArr = Split(rs("dt"),"@")
						dtStr = dtArr(0)
						dtType = dtArr(1)
						getDtHTML = getDtHTML & dtStr
					else
						Dim nlObj
						Set nlObj = New hlxNongLiGongLi
						dtArr = Split(rs("dt"),"@")
						dtStr = dtArr(0)
						dtType = dtArr(1)
						If dtType="2" Then
							getDtHTML = getDtHTML & "农历"&nlObj.getYearStr(dtStr)&"年"&_
							"nlObj.NongliMonth(nlObj.getMonthStr(dtStr))&""月""&_"
							nlObj.NongliDay(nlObj.getDayStr(dtStr))
						ElseIf dtType="3" Then
							getDtHTML = getDtHTML & "农历"&nlObj.getYearStr(dtStr)&"年闰"&_
							"nlObj.NongliMonth(nlObj.getMonthStr(dtStr))&""月""&_"
							nlObj.NongliDay(nlObj.getDayStr(dtStr))
						else
							getDtHTML = getDtHTML & "公历"&nlObj.getYearStr(dtStr)&"年"&_
							"nlObj.getMonthStr(dtStr)&""月""&_"
							nlObj.getDayStr(dtStr)&"日"
						end if
					end if
				else
					getDtHTML = getDtHTML & rs("dt")
				end if
			end if
			Dim canCancelAlt : canCancelAlt = False
			If m_canCancel = True And isCleanMode <> True And Not m_isMobileMode Then
				If hasAltField(rs) Then
					If CLng(rs("canCancelAlt")) = 1 Then
						canCancelAlt = True
					else
						canCancelAlt = False
					end if
				else
					canCancelAlt = True
				end if
				If canCancelAlt = True Then
					getDtHTML = getDtHTML & _
					"<img src='../images/alt3.gif' " &_
					"style='cursor:pointer;' " &_
					"onClick=""RemObj.cancel('" & rs("id") & "','" & rs("rid") & "'," & m_setjmId & "," & m_subCfgId & ")"" " &_
					"alt='取消提醒'"  &_
					"border='0'" &_
					"/>"
				end if
			end if
		end function
		Public Sub appendRemind(oid)
			Call appendRemindWithStat(oid,0)
		end sub
		Public Sub appendRemindWithStat(oid,stat)
			Call appendRemindWithInfo(oid,stat,"")
		end sub
		Public Sub appendRemindWithInfo(oid,stat,inf)
			Dim sql
			oid = Replace(oid," ","")
			If oid = "" Then
				Response.write "方法调用缺少必要的参数"
				Response.end
			end if
			sql = "select [id] from reminderQueue a  with(nolock) where reminderConfig=" & configId & " and subCfgId=" & m_subCfgId &_
			" And orderId in (" & oid & ") and orderStat=" & stat
			Me.cn.execute "delete reminderPersons where reminderId in ("&sql&")"
			Me.cn.execute "update reminderQueue set inDate =getdate() where id in ("&oid&")"
			Me.cn.execute "insert into reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,orderStat,otherInfo,inDate) " & _
			"select "&configId&","&m_subCfgId&_
			",cast(short_str as int),0,"&stat&",'"&inf&"',getdate() from dbo.split('"&oid&"',',') where cast(short_str as int) not in ("&Replace(sql,"[id]","[orderID]")&")"
		end sub
		Public Sub dropRemindByOID(oid)
			Call dropRemindByOidAndStat(oid,0)
		end sub
		Public Sub dropRemindByOidAndStat(oid,stat)
			If m_remindMode <> "PASSIVE" And m_remindMode <> "CYCLE" Then
				Response.write m_remindMode & "模式下不支持此过程调用！"
				Response.end
			end if
			oid = Replace(oid," ","")
			If oid = "" Then
				Response.write "方法调用缺少必要的参数"
				Response.end
			end if
			Me.cn.execute "delete reminderPersons where reminderId in " & _
			"(select id from reminderQueue  with(nolock) where orderId in (" & oid & ") and subCfgId="&m_subCfgId&_
			" and orderStat="&stat&" and reminderConfig=" & configId &")"
			Me.cn.execute "delete reminderQueue where orderId in (" & oid & ") and subCfgId="&m_subCfgId&_
			" and orderStat="&stat&" and reminderConfig=" & configId
		end sub
		Public Sub dropRemindByRID(rid)
			If m_remindMode <> "PASSIVE" And m_remindMode <> "CYCLE" Then
				Response.write m_remindMode & "模式下不支持此过程调用！"
				Response.end
			end if
			If rid = "" Then
				Response.write "方法调用缺少必要的参数"
				Response.end
			end if
			Me.cn.execute "delete reminderPersons where reminderId in (" & rid & ")"
			Me.cn.execute "delete reminderQueue where id in (" & rid & ")"
		end sub
		Public Sub cancelRemind(rid)
			Dim sql,rs,id
			If rid&""<>"0" And rid&""<>"" Then
				sql = iif(instr(rid,",")>0 , " id in (" & rid & ")", "id=" & rid)
				sql = "select id from reminderQueue  with(nolock) where " & sql
				Set rs=Me.cn.execute(sql)
				If rs.eof=True Then rs.close : Exit Sub
				While rs.eof = False
					id = CLng(rs(0))
					If canCancelOrder(id) Then
						If m_remindMode = "PASSIVE" Or m_remindMode = "CYCLE" Then
							If m_jointly = True Then
								If m_remindMode = "CYCLE" Then
									Me.cn.execute "insert into reminderPersons(reminderId,cateid) " & vbcrlf &_
									"select distinct "&id&",isnull(cateid," & uid & ") from setjm a  with(nolock) where ord="&m_setjmId&" " & vbcrlf &_
									"and not exists (select top 1 1 from reminderPersons  with(nolock) where reminderId="&id&" and cateid=isnull(a.cateid," & uid & "))"
								Else
									Call Me.dropRemindByRID(rid)
								end if
							else
								Me.cn.execute "if not exists (select 1 from reminderPersons  with(nolock) where reminderId=" & id & " and cateid=" & uid & ") " & vbcrlf &_
								"insert into reminderPersons(reminderId,cateid) values("&id&","&uid&")"
							end if
						end if
					end if
					rs.movenext
				wend
				rs.close
				set rs = nothing
			end if
		end sub
		Public Sub cancelRemindByOid(oid)
			Dim sql,rs,id,result,success
			If oid&""<>"0" And oid&""<>"" Then
				sql = "select distinct rid,cast(title as nvarchar(200)) as title from (" & listSql("all_withoutOrderBy") & ") a where [id] in (" & oid & ")"
				Set rs=Me.cn.execute(sql)
				If rs.eof=True Then Exit Sub
				result = ""
				While rs.eof = False
					id = CLng(rs("rid"))
					If canCancelOrder(id) Then
						If m_remindMode = "PASSIVE" Or m_remindMode = "CYCLE" Then
							If m_jointly = True Then
								If m_remindMode = "CYCLE" Then
									Me.cn.execute "insert into reminderPersons(reminderId,cateid) " & vbcrlf &_
									"select distinct "&id&",isnull(cateid," & uid & ") from setjm a  with(nolock) where ord="&m_setjmId&" " & vbcrlf &_
									"and not exists (select top 1 1 from reminderPersons  with(nolock) where reminderId="&id&" and cateid=isnull(a.cateid," & uid & ") )"
								Else
									Call Me.dropRemindByRID(rid)
								end if
							else
								Me.cn.execute "if not exists (select 1 from reminderPersons  with(nolock) where reminderId=" & id & " and cateid=" & uid & ") " & vbcrlf &_
								"insert into reminderPersons(reminderId,cateid) values("&id&","&uid&")"
							end if
						end if
						success = "true"
					else
						success = "false"
					end if
					result = result & "{""id"":"&id&",""name"":"""&IIF(Len(rs("title"))>0,rs("title"),"无标题")&""",""success"":"&success&"}"
					rs.movenext
					If rs.eof=False Then result = result & ","
				wend
				If Len(result)>0 Then
					Response.write "[" & result & "]"
				end if
			end if
		end sub
		Public Sub reloadRemind(withoutLimit)
			Dim sql,condition,qOpen,qIntro,fields,orderBy,rs,cfgId,cateid,rType,rAdvance,topNum,tmpCondition,lastReloadDate
			Me.cn.cursorLocation = 3
			If withoutLimit <> True Then
				sql = "select lastReloadDate from reminderConfigs  with(nolock) where setjmId=" & m_setjmId
				Set rs=Me.cn.execute(sql)
				If rs.eof Then
					Response.write "读取配置失败，请联系管理员"
					Response.end
				else
					lastReloadDate = now
					If datediff("s",rs(0),lastReloadDate) < RELOAD_INTERVAL_LIMIT And datediff("s",rs(0),lastReloadDate) > 0 Then
						Response.write "请不要频繁进行更新操作"
						Response.end
					end if
				end if
			else
				lastReloadDate = now
			end if
			sql = "select top 0 id,reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate into #reminderQueue from reminderQueue"
			Me.cn.execute sql
			Set rs = Me.cn.execute("select isnull(max(tq1),0) tq1 from setjm  with(nolock) where intro='1' and ord=" & m_setjmId)
			If rs.eof Then
				rAdvance = 0
			else
				rAdvance = rs(0)
			end if
			Select Case m_setjmId
			Case 7:
			Dim nowDays : nowDays = datediff("d",CDate(year(date)&"-01-01"),date)
'Case 7:
			sql = "exec erp_PersonBirthdayUpdate "&year(date)&",0"
			Me.cn.execute sql
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select "&m_setjmId&",0,a.ord,year(getdate())+(case when isnull(a.bDays - "&nowDays&",0)=0 then 0 else 1 end)*100000,"&_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"a.bDays - "&nowDays&",getdate() " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"From person a  with(nolock) " & vbcrlf &_
			"where bDays - "&nowDays&" >=0 and bDays - "&nowDays&" <= " & rAdvance & " " & vbcrlf &_
			"From person a  with(nolock) " & vbcrlf &_
			"and a.ord not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by a.bDays,a.ord"
			Me.cn.execute sql
			Case 9:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select " & m_setjmId & ",0,id,datediff(d,'2000-01-01',date2),datediff(d,getdate(),date2),getdate() from caigoulist a with(nolock)  " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where del=1 and alt=1 " & vbcrlf & _
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"and datediff(d,getdate(),date2)<=" & rAdvance & " and datediff(m,getdate(),date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by date2 desc,date7 desc"
			Me.cn.execute sql
			Case 11:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select "&m_setjmId&",0,ord,datediff(d,'2000-01-01',date1),datediff(d,getdate(),date1),getdate() from payback a with(nolock)  " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where del=1 and complete='1' " & vbcrlf &_
			"and datediff(d,getdate(),date1)<=" & rAdvance & " " & vbcrlf &_
			"and a.ord not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by date1 desc,date7 desc"
			Me.cn.execute sql
			Case 209:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select "&m_setjmId&",0,id,datediff(d,'2000-01-01',applydate),datediff(d,getdate(),applydate),getdate() from payoutsure a  with(nolock) " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where del=1 and (complete='0' and status in (-1,1) or complete='3')" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"and datediff(d,getdate(),applydate)<=" & rAdvance & " " & vbcrlf &_
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by applydate desc,InDate desc"
			Me.cn.execute sql
			Case 12:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select "&m_setjmId&",0,ord,datediff(d,'2000-01-01',date1),datediff(d,getdate(),date1),getdate() from payout a  with(nolock) " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where del=1 and complete='1' " & vbcrlf &_
			"and datediff(d,getdate(),date1)<=" & rAdvance & " " & vbcrlf &_
			"and a.ord not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by date1 desc,date7 desc"
			Me.cn.execute sql
			Case 21:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select " & m_setjmId & ",0,ord,datediff(d,'2000-01-01',date2),datediff(d,getdate(),date2),getdate() from contract a with(nolock)  " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where del=1 " & vbcrlf & _
			"and a.ord not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"and datediff(d,getdate(),date2)<=" & rAdvance & " and datediff(m,getdate(),date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"and a.ord not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by date2 desc,date7 desc"
			Me.cn.execute sql
			Case 23:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select " & m_setjmId & ",0,id,datediff(d,'2000-01-01',date2),datediff(d,getdate(),date2),getdate() from contractlist a with(nolock)  " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where a.del=1 and a.num2<a.num1 " & vbcrlf & _
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"and datediff(d,getdate(),date2)<=" & rAdvance & " and datediff(m,getdate(),date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by date2 desc,date7 desc"
			Me.cn.execute sql
			Case 68:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select " & m_setjmId & ",0,ku.id," & vbcrlf &_
			"MaintainUnit*10000 + MaintainNum * 10 + cast(ISNULL(m.date1,ISNULL(ku.datesc,'1970-1-1')) as int)," & vbcrlf &_
			"select " & m_setjmId & ",0,ku.id," & vbcrlf &_
			"datediff(hh,'"&date&"',ISNULL(m.date1,ISNULL(ku.datesc,'1970-1-1'))) + " & vbcrlf &_
			"select " & m_setjmId & ",0,ku.id," & vbcrlf &_
			"case " & vbcrlf &_
			"when MaintainUnit = 1 then MaintainNum " & vbcrlf &_
			"when MaintainUnit = 2 then MaintainNum * 24 " & vbcrlf &_
			"when MaintainUnit = 3 then MaintainNum * 24 * 7 " & vbcrlf &_
			"when MaintainUnit = 4 then MaintainNum * 24 * 30 " & vbcrlf &_
			"when MaintainUnit = 5 then MaintainNum * 24 * 365 " & vbcrlf &_
			"end " & vbcrlf &_
			",getdate() " & vbcrlf &_
			"from product p  with(nolock) " & vbcrlf &_
			"inner join ku  with(nolock) on p.ord=ku.ord and ku.num2<>0 and LEN(ku.datesc)>0 and p.del=1 " & vbcrlf &_
			"and ISNULL(p.MaintainNum,0)>0 and datalength(p.RemindPerson)>0 " & vbcrlf &_
			"left join ( " & vbcrlf &_
			"select m1.ord yhord,m2.ord,m2.ku,m3.date1 from maintain m1  with(nolock) " & vbcrlf &_
			"inner join ( " & vbcrlf &_
			"select maintain,ord,ku from maintainlist  with(nolock) " & vbcrlf &_
			"where del=1 " & vbcrlf &_
			"group by maintain,ord,ku " & vbcrlf &_
			") m2 on m2.maintain=m1.ord " & vbcrlf &_
			"inner join ( " & vbcrlf &_
			"select m2.ord, m2.ku, max(m1.date1) date1 " & vbcrlf &_
			"from maintain m1  with(nolock) " & vbcrlf &_
			"inner join maintainlist m2  with(nolock) on m2.maintain=m1.ord and m2.del=1 " & vbcrlf &_
			"inner join product p  with(nolock) on p.ord=m2.ord and p.del=1 " & vbcrlf &_
			"and ISNULL(p.MaintainNum,0)>0 and datalength(p.RemindPerson)>0 " & vbcrlf &_
			"where m1.del=1 and isnull(m1.status,0)=0 " & vbcrlf &_
			"group by m2.ord,m2.ku " & vbcrlf &_
			")m3 on m2.ord=m3.ord and m2.ku=m3.ku " & vbcrlf &_
			"where m1.del=1 and isnull(m1.status,0)=0 and m1.date1=m3.date1 " & vbcrlf &_
			") m on m.ku=ku.id and p.ord=m.ord " & vbcrlf &_
			"where isnull(ku.locked,0)=0 and len(ISNULL(m.date1,ku.datesc))>0 " & vbcrlf &_
			"and datediff(hh,'"&date&"',ISNULL(m.date1,ISNULL(ku.datesc,'1970-1-1'))) + " & vbcrlf &_
			"where isnull(ku.locked,0)=0 and len(ISNULL(m.date1,ku.datesc))>0 " & vbcrlf &_
			"case " & vbcrlf &_
			"when MaintainUnit = 1 then MaintainNum " & vbcrlf &_
			"when MaintainUnit = 2 then MaintainNum * 24 " & vbcrlf &_
			"when MaintainUnit = 3 then MaintainNum * 24 * 7 " & vbcrlf &_
			"when MaintainUnit = 4 then MaintainNum * 24 * 30 " & vbcrlf &_
			"when MaintainUnit = 5 then MaintainNum * 24 * 365 " & vbcrlf &_
			"end <= " & (rAdvance * 24)
			Me.cn.execute sql
			Case 105:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select "&m_setjmId&",0,ProductID,datediff(mi,'2014-01-01',getdate()),b.UnitId,getdate() " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"from o_product a  with(nolock) " & vbcrlf &_
			"inner join ( " & vbcrlf &_
			"select replace(prod_id,' ','') as ProductID,replace(prod_unit,' ','') as UnitId,sum(prod_num) as ku_num " & vbcrlf &_
			"from o_kuinlist a  with(nolock) " & vbcrlf &_
			"inner join o_kuin b  with(nolock) on a.reg_fid=b.id " & vbcrlf &_
			"group by prod_id,prod_unit " & vbcrlf &_
			") b on a.id=b.ProductID " & vbcrlf &_
			"where " & vbcrlf &_
			"(case when Ku_num>prod_more and prod_more<>0 then "&_
			"(convert(decimal,(Ku_num-prod_more))/convert(decimal,prod_more))*100 else 0 end) > 0 " & vbcrlf &_
			"(case when Ku_num>prod_more and prod_more<>0 then "&_
			" or " & vbcrlf &_
			"(case when Ku_num<prod_less and prod_less<>0 then "&_
			"(convert(decimal,(prod_less-Ku_num))/convert(decimal,prod_less))*100 else 0 end) > 0 "
'(case when Ku_num<prod_less and prod_less<>0 then &_
			Me.cn.execute sql
			Case 106:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select distinct "&m_setjmId&",0,ord,isnull(min(type1),0) * 100000 + min(backdays),min(backdays),getdate() " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"from dbo.erp_sale_getBackList('"&date&"',0) where canremind=1 and backdays<=reminddays " & vbcrlf &_
			"group by ord"
			Me.cn.execute sql
			Case 120:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select distinct "&m_setjmId&",0,a.ord,datediff(d,'2014-01-01',getdate()),datediff(d,'" & date & "',datepro+isnull(b.num2,0)),getdate() "&_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"from tel as a WITH(NOLOCK) "& vbcrlf &_
			"inner join num_bh b on a.sort1=b.kh and a.cateid=b.cateid "& vbcrlf &_
			"where a.profect1=1 "& vbcrlf &_
			"and datediff(d,'" & date & "',datepro+isnull(b.num2,0)) <= isnull(b.num3,0) "& vbcrlf &_
			"where a.profect1=1 "& vbcrlf &_
			"and a.del=1 and isnull(a.sp,0)=0 and a.sort3=1"
			Me.cn.execute sql
			Case 121:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select distinct "&m_setjmId&",0,ord,datediff(d,'2014-01-01',getdate()),datediff(d,'2014-01-01',isnull(nextReply,EndReplyDate)),getdate() "&_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"from dbo.erp_sale_getWillReplyList('"&date&"',0) "
			Me.cn.execute sql
			Case 10:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT " & m_setjmId & ",0,a.id,DATEDIFF(d,'2000-01-01',a.date2),DATEDIFF(d,GETDATE(),a.date2),GETDATE() FROM kujhlist a  with(nolock) " & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"WHERE a.del = 1 AND a.num1 > a.num2 " & vbcrlf & _
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.date2)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY a.date2 DESC,a.date7 DESC"
			Me.cn.execute sql
			Case 20:
			storelist_sort5 = "0"
			Set rsUsConfig= conn.execute("select isnull(tvalue,'0') tvalue from home_usConfig where name='storelist_sort5' and isnull(uid, 0) =" &  session("personzbintel2007") )
			If rsUsConfig.eof= False Then
				storelist_sort5=rsUsConfig("tvalue")
			end if
			rsUsConfig.close
			showKuLimitZeroSQL = ""
			if storelist_sort5 = "0" then
				showKuLimitZeroSQL = " and (isnull(a.alert1,0)>0 or isnull(a.alert2,0)>0)"
			end if
			showzore =0
			Set rsUsConfig= conn.execute("select (case cast(tvalue as varchar(10)) when '1' then 1 else 0 end) v from home_usConfig  with(nolock) where uid="& session("personzbintel2007") &" and name='storelist_sort1' ")
			if rsUsConfig.eof=false  then
				showzore = rsUsConfig("v").value
			end if
			rsUsConfig.close
			unkuinwarning = 0
			if showzore="1" then
				Set rsUsConfig= conn.execute("select (case cast(tvalue as varchar(10)) when '1' then 1 else 0 end) v from home_usConfig  with(nolock) where uid="& session("personzbintel2007") &" and name='storelist_warning' ")
				if rsUsConfig.eof=false  then
					unkuinwarning = rsUsConfig("v").value
				end if
				rsUsConfig.close
			end if
			showZeroSQL = ""
			if showzore = "0" then
				showZeroSQL = " and isnull(b.ku_num,0)>0 "
			else
				if unkuinwarning="0" then
					showZeroSQL = " and exists(select 1 from ku where ord =a.ord) "
				end if
			end if
			sql = "" & vbcrlf &_
			"select cateid from setjm a " & vbcrlf &_
			"inner join (" & vbcrlf &_
			"select ord from (" & vbcrlf &_
			"select ord from power  with(nolock) where (sort1=31 and sort2=13 and qx_open>0) " & vbcrlf &_
			"union all " & vbcrlf &_
			"select ord from power  with(nolock) where (sort1=31 and sort2=16 and qx_open>0) " & vbcrlf &_
			") a group by ord having count(*)=2 " & vbcrlf &_
			"union " & vbcrlf &_
			"select ord from (" & vbcrlf &_
			"select ord from power  with(nolock) where (sort1=32 and sort2=13 and qx_open>0) " & vbcrlf &_
			"union all " & vbcrlf &_
			"select ord from power  with(nolock) where (sort1=32 and sort2=16 and qx_open>0) " & vbcrlf &_
			") a group by ord having count(*)=2" & vbcrlf &_
			") b on a.cateid=b.ord " & vbcrlf &_
			"where a.intro=1 and a.ord=" & m_setjmId
			Set rs = Me.cn.execute(sql)
			While rs.eof = False
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT " & m_setjmId & ",0,a.ord,DATEDIFF(mi,'2000-01-01',a.date7),DATEDIFF(d,GETDATE(),a.date7),GETDATE() " & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"FROM (" & vbcrlf &_
				"SELECT a.ord,addcate,title," & vbcrlf & _
				"(CASE WHEN Isnull(aleat1, 0) = 0 THEN 0 ELSE Isnull(aleat1, 0) END )  AS alert1, " & vbcrlf & _
				"(CASE WHEN Isnull(aleat2, 0) = 0 THEN 0 ELSE Isnull(aleat2, 0) END )  AS alert2, " & vbcrlf & _
				"date7,Isnull(ku_num, 0) ku_num " & vbcrlf & _
				"FROM product a  with(nolock) " & vbcrlf & _
				"LEFT JOIN (" & vbcrlf &_
				"SELECT ord,Sum(numjb) AS ku_num FROM ("&vbcrlf &_
				"SELECT suba.ord," & vbcrlf & _
				"(CASE " & vbcrlf & _
				"WHEN suba.unit = subb.unitjb THEN num2 " & vbcrlf & _
				"ELSE num2 * Isnull((SELECT TOP 1 bl FROM jiage WHERE  product = suba.ord AND unit = suba.unit), 0) " & vbcrlf & _
				"END) numjb " & vbcrlf & _
				"FROM ku suba  with(nolock) " & vbcrlf & _
				"INNER JOIN product subb  with(nolock) ON suba.ord = subb.ord " & vbcrlf & _
				"inner join sortck subc  with(nolock) on subc.id = suba.ck "& vbcrlf &_
				"and subc.del=1 "& vbcrlf &_
				"and ("& vbcrlf &_
				"charindex('," & rs(0) & ",',','+replace(cast(subc.intro as varchar(4000)),' ','')+',')>0 "& vbcrlf &_
				"and ("& vbcrlf &_
				"or replace(cast(subc.intro as varchar(4000)),' ','') = '0'"& vbcrlf &_
				")" & vbcrlf &_
				") subaa " & vbcrlf & _
				"GROUP BY ord " & vbcrlf & _
				") AS b ON a.ord = b.ord " & vbcrlf & _
				"WHERE a.del = 1 "& showZeroSQL&" AND (isnull(ku_num,0)<=aleat1 or isnull(ku_num,0)>aleat2)" & vbcrlf & _
				") AS a " & vbcrlf & _
				"WHERE not a.date7 is NULL "& showKuLimitZeroSQL &" " & vbcrlf & _
				"AND a.ord NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"ORDER BY a.date7 DESC"
				Me.cn.execute sql
				rs.movenext
			wend
			rs.close
			Case 49:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT " & m_setjmId & ",0,a.id,DATEDIFF(mi,'2000-01-01',a.lastdate)+100000*isnull(a.zhouqi,0),DATEDIFF(d,GETDATE(),a.lastdate),GETDATE() " & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"FROM " & vbcrlf & _
			"(SELECT a.id,a.personID, b.username,a.lastdate,a.zhouqi, " & vbcrlf & _
			"  (CASE a.unit " & vbcrlf & _
			"     WHEN 1 THEN Dateadd(yyyy, a.zhouqi, a.lastdate) " & vbcrlf & _
			"     WHEN 2 THEN Dateadd(qq, a.zhouqi, a.lastdate) " & vbcrlf & _
			"     WHEN 3 THEN Dateadd(m, a.zhouqi, a.lastdate) " & vbcrlf & _
			"     WHEN 4 THEN Dateadd(ww, a.zhouqi, a.lastdate) " & vbcrlf & _
			"     WHEN 5 THEN Dateadd(d, a.zhouqi, a.lastdate) " & vbcrlf & _
			"     ELSE NULL " & vbcrlf & _
			"  END ) AS nextdate, " & vbcrlf & _
			"  Isnull(a.alt, 1) AS alt " & vbcrlf & _
			"FROM   hr_person_health a  with(nolock) " & vbcrlf & _
			"       INNER JOIN hr_person b  with(nolock) ON b.userID = a.personID " & vbcrlf & _
			"WHERE  b.del = 0 AND a.lastdate IS NOT NULL AND a.zhouqi IS NOT NULL AND b.nowstatus NOT IN (2,3,4) " & vbcrlf & _
			") a " & vbcrlf & _
			"WHERE 1 = 1 AND a.alt < 2 " & vbcrlf & _
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.nextdate)<=" & rAdvance &_
			"AND DATEDIFF(m,GETDATE(),a.nextdate)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.nextdate)<=" & rAdvance &_
			"ORDER BY a.lastdate DESC"
			Me.cn.execute sql
			Case 66:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT " & m_setjmId & ",0,a.id,DATEDIFF(mi,'2000-01-01',a.date2),DATEDIFF(d,GETDATE(),a.date2),GETDATE() " & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"FROM " & vbcrlf & _
			"(SELECT z.id,t.name,t.cateid,s.title,z.date2,ISNULL(z.alt, '') alt " & vbcrlf & _
			"FROM   tel t  with(nolock) " & vbcrlf & _
			"INNER JOIN sortFieldsContent z " & vbcrlf & _
			"       ON z.ord = t.ord " & vbcrlf & _
			"          AND z.del = 1 " & vbcrlf & _
			"          AND t.del = 1 " & vbcrlf & _
			"          AND z.sort = 1 " & vbcrlf & _
			"          AND t.sort3 = 2 " & vbcrlf & _
			"          AND t.isNeedQuali = 1 " & vbcrlf & _
			"          AND ISNULL(t.status_sp_qualifications, 0) = 0 " & vbcrlf & _
			"          AND LEN(z.date2) > 0 " & vbcrlf & _
			"          AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"          AND CHARINDEX(',"& uid &",', ',' + CAST(z.share AS VARCHAR(4000)) + ',') > 0 " & vbcrlf & _
			"          AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"INNER JOIN sortClass s " & vbcrlf & _
			"       ON z.sortid = s.id " & vbcrlf & _
			"          AND ISNULL(s.isStop, 0) = 0 " & vbcrlf & _
			"          AND s.sort1 = 2 " & vbcrlf & _
			") a " & vbcrlf & _
			"WHERE 1 = 1 " & vbcrlf & _
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.date2)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY a.date2 DESC"
			Me.cn.execute sql
			Case 67:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT " & m_setjmId & ",0,a.id,DATEDIFF(mi,'2000-01-01',a.date2),DATEDIFF(d,GETDATE(),a.date2),GETDATE() " & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"FROM " & vbcrlf & _
			"(SELECT z.id,t.name,t.cateid,s.title,z.date2,ISNULL(z.alt, '') alt " & vbcrlf & _
			"FROM   tel t  with(nolock) " & vbcrlf & _
			"INNER JOIN sortFieldsContent z " & vbcrlf & _
			"       ON z.ord = t.ord " & vbcrlf & _
			"          AND z.del = 1 " & vbcrlf & _
			"          AND t.del = 1 " & vbcrlf & _
			"          AND z.sort = 1 " & vbcrlf & _
			"          AND t.sort3 = 1 " & vbcrlf & _
			"          AND t.isNeedQuali = 1 " & vbcrlf & _
			"          AND ISNULL(t.status_sp_qualifications, 0) = 0 " & vbcrlf & _
			"          AND LEN(z.date2) > 0 " & vbcrlf & _
			"          AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"          AND CHARINDEX(',"& uid &",', ',' + CAST(z.share AS VARCHAR(4000)) + ',') > 0 " & vbcrlf & _
			"          AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
			"INNER JOIN sortClass s " & vbcrlf & _
			"       ON z.sortid = s.id " & vbcrlf & _
			"          AND ISNULL(s.isStop, 0) = 0 " & vbcrlf & _
			"          AND s.sort1 = 2 " & vbcrlf & _
			") a " & vbcrlf & _
			"WHERE 1 = 1 " & vbcrlf & _
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.date2)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY a.date2 DESC"
			Me.cn.execute sql
			Case 213:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,a.id,DATEDIFF(d,'2000-01-01',a.date1),DATEDIFF(d,GETDATE(),a.date1),GETDATE() " & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"FROM ( " & vbCrLf &_
			"  SELECT a.id,a.date1,a.date7 FROM paybackinvoice a   with(nolock) " & vbCrLf &_
			"  INNER JOIN sortbz b ON b.id = a.bz " & vbCrLf &_
			"  WHERE a.del = 1 AND isInvoiced = 0  AND ISNULL(a.cateid,0) <> 0 " & vbCrLf &_
			") a " & vbCrLf &_
			"WHERE 1 =1 " & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.date1)<=" & rAdvance & " " & vbcrlf &_
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY a.date1 DESC,a.date7 DESC"
			Me.cn.execute sql
			Case 214:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,id,DATEDIFF(d,'2000-01-01',date1),DATEDIFF(d,GETDATE(),date1),GETDATE() " & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"FROM payoutInvoice  with(nolock) WHERE del = 1 AND isInvoiced=0 " & vbCrLf &_
			"AND DATEDIFF(d,GETDATE(),date1)<=" & rAdvance & "  " & vbcrlf &_
			"AND id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY date1 DESC,date7 DESC"
			Me.cn.execute sql
			Case 52:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,id,RemindNum*100+RemindUnit*10+cast(getdate() as int)," & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"isnull(daysFromNow,0) - " & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"isnull(case " & vbcrlf &_
			"when RemindUnit = 1 then RemindNum " & vbcrlf &_
			"when RemindUnit = 2 then RemindNum * 24 " & vbcrlf &_
			"when RemindUnit = 3 then RemindNum * 24 * 7 " & vbcrlf &_
			"when RemindUnit = 4 then RemindNum * 24 * 30 " & vbcrlf &_
			"when RemindUnit = 5 then RemindNum * 24 * 365 " & vbcrlf &_
			"end,0)" & vbcrlf &_
			",GETDATE() " & vbcrlf &_
			"FROM ( " & vbCrLf &_
			"SELECT p.ord, p.title, p.addcate, k.dateyx, k.id,ISNULL(p.RemindUnit,0) RemindUnit,ISNULL(p.RemindNum,0) RemindNum," & vbcrlf &_
			"datediff(hh,getdate(),k.dateyx) daysFromNow " & vbcrlf &_
			"FROM ku k  with(nolock) " & vbcrlf &_
			"INNER JOIN product p  with(nolock) ON p.ord = k.ord " & vbcrlf &_
			"INNER JOIN sortck ck  with(nolock) ON k.ck = ck.ord AND ck.del = 1 " & vbcrlf &_
			"WHERE (CAST(ISNULL(ck.intro,'') AS VARCHAR(4000))='0' OR CHARINDEX(',"&uid&",',','+CAST(ck.intro AS VARCHAR(4000))+',')>0) " & vbcrlf &_
			"INNER JOIN sortck ck  with(nolock) ON k.ck = ck.ord AND ck.del = 1 " & vbcrlf &_
			"AND p.del = 1 " & vbcrlf &_
			"AND k.num2 > 0 " & vbcrlf &_
			"AND p.RemindNum > 0 " & vbcrlf &_
			"AND k.dateyx IS NOT NULL " & vbcrlf &_
			"AND ISNULL(k.locked, 0) = 0 " & vbcrlf &_
			") a " & vbCrLf &_
			"WHERE 1 =1 " & vbcrlf &_
			"AND daysFromNow <= " & (rAdvance*24) & " " & vbcrlf &_
			"AND ord NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY dateyx DESC"
			Me.cn.execute sql
			Case 51:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,id,DATEDIFF(d,'2000-01-01',ld_rettime),DATEDIFF(d,GETDATE(),ld_rettime),GETDATE() " & vbcrlf &_
			"FROM ( " & vbCrLf &_
			"  SELECT a.id, c.bk_name, a.ld_rettime, d.addcateid " & vbcrlf &_
			"  FROM O_Lendbookmx a with(nolock)  " & vbcrlf &_
			"  LEFT JOIN O_Lendbook d  with(nolock) ON a.Ld_fid=d.id " & vbcrlf &_
			"  LEFT JOIN O_regbook c  with(nolock) ON a.Ld_bkid=c.id " & vbcrlf &_
			"  WHERE a.ld_num > (SELECT isnull(sum(Ret_num),0) AS Ret_num FROM O_RetBookmx WHERE Ret_bkid=a.id) " & vbcrlf &_
			") a " & vbCrLf &_
			"WHERE 1 =1 " & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),ld_rettime)<=" & rAdvance & " " & vbcrlf &_
			"AND id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY ld_rettime DESC"
			Me.cn.execute sql
			Case 59:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,id,DATEDIFF(d,'2000-01-01',Reguldate),DATEDIFF(d,GETDATE(),Reguldate),GETDATE() " & vbcrlf &_
			"FROM ( " & vbCrLf &_
			"  SELECT a.ID,a.Reguldate " & vbcrlf &_
			"  FROM hr_person a  with(nolock) " & vbcrlf &_
			"  WHERE  a.nowStatus = 5 AND a.del = 0 " & vbcrlf &_
			") a " & vbCrLf &_
			"WHERE 1 =1 " & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),Reguldate)<=" & rAdvance & " " & vbcrlf &_
			"AND id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY Reguldate DESC"
			Me.cn.execute sql
			Case 215:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,chanceID,DATEDIFF(d,'2000-01-01',GETDATE()) * 1000 + backdays,backDays,GETDATE() " & vbcrlf &_
			"FROM dbo.erp_chance_callbackList('"& Now() &"') a" & vbCrLf &_
			"WHERE 1 =1 AND a.backdays <= ISNULL((SELECT ISNULL(tq1,5) FROM setjm WHERE cateid = "& uid &" AND ord = "&m_setjmId&" AND intro = '1'),5)  " & vbcrlf &_
			"AND chanceID NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY chanceID DESC"
			Me.cn.execute sql
			Case 300:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,id,ISNULL(DATEDIFF(d,'2000-01-01',date4),0),ISNULL(DATEDIFF(d,GETDATE(),date4),0),GETDATE() " & vbcrlf &_
			"FROM document with(nolock)  " & vbCrLf &_
			"WHERE del = 1 AND validity = 2 AND (sp = 0 AND cateid_sp = 0) AND addcate = "& uid &" AND date4 is not null  " & vbcrlf &_
			"AND id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY id DESC"
			Me.cn.execute sql
			Case 301:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT "&m_setjmId&",0,l.id,ISNULL(DATEDIFF(d,'2000-01-01',l.l_date4),0),ISNULL(DATEDIFF(d,GETDATE(),l.l_date4),0),GETDATE() " & vbcrlf &_
			"FROM documentlist l  with(nolock) " & vbCrLf &_
			"inner join document d on d.id = l.document "&  vbCrLf &_
			"WHERE d.del = 1 and l.del=1 AND l.l_validity = 2 AND (d.sp = 0 AND d.cateid_sp = 0) AND l.l_date4 is not null  " & vbcrlf &_
			"AND l.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"ORDER BY l.id DESC"
			Me.cn.execute sql
			Case 155:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT " & m_setjmId & ",0,a.iss_id,DATEDIFF(mi,'2000-01-01',a.iss_endtime),DATEDIFF(d,GETDATE(),a.iss_endtime),GETDATE() " & vbcrlf &_
			"FROM " & vbcrlf & _
			"O_insure a  with(nolock) " & vbcrlf & _
			"WHERE a.del=1 " & vbcrlf & _
			"AND a.iss_id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.iss_endtime)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.iss_endtime)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"ORDER BY a.iss_endtime DESC"
			Me.cn.execute sql
			Case 17:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT " & m_setjmId & ",0,a.id,DATEDIFF(mi,'2000-01-01',a.date3),DATEDIFF(d,GETDATE(),a.date3),GETDATE() " & vbcrlf &_
			"FROM " & vbcrlf & _
			"(select *,(select TOP 1 id from hr_person  with(nolock) where del = 0 AND userid=ord) as id from gate_person) a " & vbcrlf & _
			"WHERE 1 = 1 " & vbcrlf & _
			"and a.id IS NOT NULL " & vbcrlf & _
			"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.date3)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.date3)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"ORDER BY a.date3 DESC"
			Me.cn.execute sql
			Case 156:
			sql = "" & vbcrlf &_
			"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"SELECT " & m_setjmId & ",0,a.ord,DATEDIFF(mi,'2000-01-01',a.date3),DATEDIFF(d,GETDATE(),a.date3),GETDATE() " & vbcrlf &_
			"FROM " & vbcrlf & _
			"gate a " & vbcrlf & _
			"WHERE 1 = 1 " & vbcrlf & _
			"and a.ord IS NOT NULL " & vbcrlf & _
			"AND a.ord NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d,GETDATE(),a.date3)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.date3)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"ORDER BY a.date3 DESC"
			Me.cn.execute sql
			Case 224:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select " & m_setjmId & ",0,id,datediff(d,'2000-01-01',dateEnd),datediff(d,getdate(),dateEnd),getdate() from M_WorkAssigns a " & vbcrlf &_
			"left join (" & vbcrlf & _
			"  --需要质检的工序中-质检通过数量最少的数量值" & vbcrlf & _
			"  select M_WorkAssigns , min(pnum) as pnum " & vbcrlf & _
			"  from " & vbcrlf & _
			"(" & vbcrlf & _
			"            select n.id as M_WorkAssigns, w.id ,sum(isnull(r.num1,0)) as pnum " & vbcrlf & _
			"            from M_WorkAssigns n with(nolock) " & vbcrlf & _
			"            inner join M_WFP_Assigns w on w.WFid = n.WProID and w.result=1 --工艺流程中需要质检的工序" & vbcrlf & _
			"            from M_WorkAssigns n with(nolock) " & vbcrlf & _
			"            left join M_ProcedureProgres r on r.[Procedure]=w.id and r.del=0 and r.result = 1 --质检通过" & vbcrlf & _
			"            from M_WorkAssigns n with(nolock) " & vbcrlf & _
			"            group by n.id , w.id" & vbcrlf & _
			"    ) s group by M_WorkAssigns" & vbcrlf & _
			") d on d.M_WorkAssigns = a.id" & vbcrlf & _
			"left join (" & vbcrlf & _
			"    select m.WAID , sum(NumQualified) as qnum ,max(m.MPDate) as newInDate" & vbcrlf & _
			"   from M_MaterialProgres m " & vbcrlf & _
			"   inner join M_MaterialProgresDetail t on t.MPID = m.id and m.del=0 and t.del=0" & vbcrlf & _
			"   group by m.WAID" & vbcrlf & _
			") c on c.WAID = a.id" & vbcrlf & _
			"where a.del=0 " & vbcrlf &_
			"and (case when (isnull(d.pnum,-1)=-1 or isnull(d.pnum,-1)>=a.NumMake ) and isnull(c.qnum,0)>=a.NumMake then 1 else 0 end) = 0 " & vbcrlf &_
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"and datediff(d,getdate(),dateEnd)<=" & rAdvance & " and datediff(m,getdate(),dateEnd)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"order by dateEnd desc,indate desc"
			Me.cn.execute sql
			Case 47003:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select " & m_setjmId & ",0,id,datediff(d,'2000-01-01',LimitEndDate),datediff(d,getdate(),LimitEndDate),getdate() from AcceptanceDraft a  with(nolock) " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where a.del=1 " & vbcrlf &_
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"and datediff(d,getdate(),LimitEndDate)<=" & rAdvance & " and datediff(m,getdate(),LimitEndDate)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"order by LimitEndDate"
			Me.cn.execute sql
			Case 51011:
			sql = "" & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"select " & m_setjmId & ",0,id,datediff(d,'2000-01-01',date1),datediff(d,getdate(),date1),getdate() from dbo.M2_maintain a  with(nolock) " & vbcrlf &_
			"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
			"where 1=1 " & vbcrlf & _
			"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
			"AND DATEDIFF(d, GETDATE() ,(CASE Unit2 WHEN 0 THEN DATEADD(MINUTE,num2,date1) " & vbcrlf &_
			"WHEN 1 THEN DATEADD(HOUR,num2,date1) WHEN 2 THEN DATEADD(DAY,num2,date1) WHEN 3 THEN DATEADD(MONTH,num2,date1) " & vbcrlf &_
			"WHEN 4 THEN DATEADD(YEAR,num2,date1) end))<=" & rAdvance & " " & vbcrlf &_
			"order by date1 desc"
			Me.cn.execute sql
			End Select
			sql = "select * from setjm  with(nolock) where intro='1' and ord=" & m_setjmId
			Set rs = Me.cn.execute(sql)
			While rs.eof = False
				cfgId = rs("ord")
				cateid = rs("cateid")
				rType = rs("fw1")
				rAdvance = rs("tq1")
				topNum = rs("num1")
				Select Case cfgId
				Case Else :
				End Select
				rs.movenext
			wend
			cn.execute "exec erp_UpdateReminderQueue " & configId & "," & m_subCfgId & ",'" & lastReloadDate & "'"
		end sub
		Public Function getRemindIdByOID(oid)
			getRemindIdByOID = getRemindIdByOIDAndStat(oid,0)
		end function
		Public Function getRemindIdByOIDAndStat(oid,stat)
			Dim sql,rs
			sql = "select top 1 id from reminderQueue  with(nolock) where reminderConfig=" & configId & " and subCfgId="&m_subCfgId&_
			" and orderId=" & oid & " and orderStat=" & stat & " and id in " &_
			"("&listSql("rids")&")"
			Set rs = Me.cn.execute(sql)
			If rs.eof Then
				getRemindIdByOIDAndStat = -1
'If rs.eof Then
			else
				getRemindIdByOIDAndStat = CLng(rs(0))
			end if
		end function
		Public Function canCancelOrder(rid)
			If rid <= 0 Then
				canCancelOrder = False
			else
				Dim rs,sql
				sql = Me.listSql("all_withoutOrderBy")
				If InStr(sql,"canCancelAlt")>0 Then
					sql = "select top 1 * from (" & sql & ") a where rid=" & rid & " and canCancelAlt = 1"
				else
					sql = "select top 1 * from (" & sql & ") a where rid=" & rid
				end if
				Set rs = cn.execute(sql)
				If rs.eof Then
					canCancelOrder = False
				else
					canCancelOrder = Me.cn.execute("select top 1 reminderId from reminderPersons  with(nolock) where reminderId = " & rid & " and cateid=" & uid).eof
				end if
			end if
		end function
		Private Function getConditionByFW(s1,s2,cateField)
			Dim qOpen,qIntro
			Call fillInPower(s1,s2,qOpen,qIntro)
			if m_fw1&""="0" Then
				if qOpen = 3 then
					getConditionByFW = ""
				elseif qOpen = 1 then
					getConditionByFW=" and "&cateField&" in ("&qIntro&") "
				else
					getConditionByFW=" and 1=2 "
				end if
			else
				getConditionByFW=" and "&cateField&"="&uid&" and ("&qOpen&"=3 or ("&qOpen&"=1 and CHARINDEX(','+cast("&cateField&" as varchar)+',', ',"&qIntro&",') > 0))"
'getConditionByFW=" and 1=2 "
			end if
		end function
		Private Function getConditionWithShare(s1,s2,cateField,shareField)
			Dim qOpen,qIntro
			Call fillInPower(s1,s2,qOpen,qIntro)
			if qOpen = 3 then
				getConditionWithShare = ""
			elseif qOpen = 1 then
				getConditionWithShare = " AND ("&cateField&" IN ("&qIntro&") OR ("&shareField&" = '1' OR CHARINDEX(',"& uid &",', ',' + "& shareField &" + ',') > 0  ))"
'elseif qOpen = 1 then
			else
				getConditionWithShare = " AND ("&shareField&" = '1' OR CHARINDEX(',"& uid &",', ',' + "& shareField &" + ',') > 0  )"
'elseif qOpen = 1 then
			end if
		end function
		Private Function getCondition(s1,s2,cateField)
			Dim qOpen,qIntro
			Call fillInPower(s1,s2,qOpen,qIntro)
			if qOpen = 3 then
				getCondition = ""
			elseif qOpen = 1 then
				getCondition=" and "&cateField&" in ("&qIntro&") "
			else
				getCondition=" and "&cateField&"=0 and ("&qOpen&"=3 or ("&qOpen&"=1 and CHARINDEX(','+cast("&cateField&" as varchar)+',', ',"&qIntro&",') > 0))"
'getCondition=" and "&cateField&" in ("&qIntro&") "
			end if
		end function
		Private Sub findPower(arrPower,ByVal find_s1,ByVal find_s2,ByRef qx_open,ByRef qx_intro,ByRef qx_type)
			Dim i
			For i = 0 To ubound(arrPower,2)
				If find_s1 = arrPower(0,i) And find_s2 = arrPower(1,i) Then
					qx_open = arrPower(2,i)
					qx_intro = arrPower(3,i)
					qx_type = arrPower(4,i)
					Exit Sub
				end if
			next
			qx_open = 0
			qx_intro = "-255"
			qx_open = 0
			qx_type = 1
		end sub
		Private Sub fillInPower(s1,s2,ByRef qx_open,ByRef qx_intro)
			Dim rsPower
			If m_UsingPowerCache Then
				Call findPower(Global_Power,s1,s2,qx_open,qx_intro,"")
			else
				Set rsPower = Me.cn.execute("select qx_open,qx_intro from power  with(nolock) where ord="&uid&" and sort1="&s1&" and sort2="&s2)
				if rsPower.eof then
					qx_open = 0
					qx_intro = "-222"
					qx_open = 0
				else
					qx_open=rsPower("qx_open")
					If rsPower("qx_intro") & "" = "" Or Len(rsPower("qx_intro"))=0 Then
						qx_intro = "-222"
'If rsPower("qx_intro") & "" = "" Or Len(rsPower("qx_intro"))=0 Then
					else
						qx_intro = rsPower("qx_intro")
					end if
				end if
				rsPower.close
				set rsPower=Nothing
			end if
		end sub
		Public Sub initByRs(ByRef rs)
			Dim subRs
			configId = rs("id")
			m_subSql = rs("subSql")
			m_subCfgId = rs("subCfgId")
			If m_subCfgId > 0 Then
				Set subRs = Me.cn.execute(m_subSql&" and id="&m_subCfgId)
				If subRs.eof Then
					m_hasModule = False
					Exit Sub
				else
					m_name = Me.cn.execute(m_subSql&" and id="&m_subCfgId)(1)
				end if
			else
				m_name = rs("name")
			end if
			m_setjmId = rs("setjmId")
			m_mCondition = rs("mCondition")
			m_remindMode = rs("remindMode")
			m_qxlb = rs("qxlb")
			m_listqx = rs("listqx")
			m_detailqx = rs("detailqx")
			m_num1 = rs("num1")
			m_opened = (rs("opened") = "1")
			m_gate1 = rs("gate1")
			m_tq1 = rs("tq1")
			If m_tq1 & "" = "" Then  m_tq1 = 0
			m_fw1 = rs("fw1")
			m_moreLinkUrl = rs("moreLinkUrl")
			m_detailLinkUrl = rs("detailLinkUrl")
			m_moreLinkUrl_mobile = rs("moreLinkUrl_mobile")
			m_detailLinkUrl_mobile = rs("detailLinkUrl_mobile")
			m_canCancel = rs("canCancel")
			m_jointly = rs("jointly")
			m_titleMaxLength = rs("titleMaxLength")
			m_lastReloadDate = rs("lastReloadDate")
			m_MOrderSetting = rs("MOrderSetting")
			m_MBusinessType = rs("MBusinessType")
			m_cacheExpiredCondition = rs("cacheExpiredCondition") & ""
			m_canTQ = rs("canTQ")
			m_fwSetting = rs("fwSetting")
			If m_usingLv2Cache = True And Len(m_cacheExpiredCondition) > 0 Then
				m_cacheExpiredCondition = base64.URLDecode(base64.Base64Decode(m_cacheExpiredCondition))
				m_cacheExpiredCondition = m_cacheExpiredCondition & ";" & vbcrlf &_
				"select reminderId from ReminderPersons a  with(nolock) "&_
				"inner join reminderQueue b  with(nolock) on a.reminderId=b.id and a.cateid=" & uid &" "&_
				"and b.reminderConfig="&configId&";" & vbcrlf &_
				"select '" & Date &"' from qxlb  with(nolock) where sort1=1 "
			end if
			If Len(m_mCondition) = 0 Then
				m_hasModule = True
			else
				on error resume next
				m_hasModule = eval(base64.URLDecode(base64.Base64Decode(m_mCondition)))
				If Abs(Err.number)>0 Then
					m_hasModule = False
				end if
				On Error GoTo 0
			end if
			If m_usingLv2Cache = True Then
				Set m_cacheHelper = server.createobject(ZBRLibDLLNameSN & ".PageClass")
				Call m_cacheHelper.init(Me)
			end if
		end sub
		Public Sub init(cfgId,subCfgId)
			If InStr(cfgId,",") > 0 Then
				cfgId = Split(cfgId,",")(0)
			end if
			If Not isnumeric(cfgId) Or cfgId&""="" Then
				Response.write "参数cfgId不正确，类初始化失败！"
				Response.end
			end if
			configId = cfgId
			Dim sql,rs
			If subCfgId > 0 Then
				m_subCfgId = subCfgId
				sql = "select a.*,isnull(b.num1,4) num1,isnull(b.intro,'0') opened,isnull(b.gate1,1) gate1,b.tq1,b.fw1,"&subCfgId&" subCfgId from reminderConfigs a  with(nolock) " &_
				"left join setjm b  with(nolock) on a.setjmId=b.ord and b.cateid="&uid&" and b.subCfgId="&subCfgId&" where a.id=" & configId
			else
				sql = "select a.*,isnull(b.num1,4) num1,isnull(b.intro,'0') opened,isnull(b.gate1,1) gate1,b.tq1,b.fw1,0 subCfgId from reminderConfigs a  with(nolock) " &_
				"left join setjm b  with(nolock) on a.setjmId=b.ord and b.cateid="&uid&" where a.id=" & configId
			end if
			Set rs = Me.cn.execute(sql)
			If rs.eof Then
				Response.write "错误：未能读取到提醒配置信息！"
				Response.end
			end if
			Call initByRs(rs)
			rs.close
			Set rs=Nothing
		end sub
		Private Function getMoreLink()
			getMoreLink = "<a href=""" & moreLinkURL() & """><font style='font-weight:normal;'>更多&gt;&gt;&gt;</font></a>"
'Private Function getMoreLink()
		end function
		Public Function moreLinkURL()
			moreLinkURL = replaceTemplete(iif(m_isMobileMode,m_moreLinkURL_mobile,m_moreLinkURL))
		end function
		Private Function replaceTemplete(v)
			Dim r
			r = Replace(v,"@subId",m_subCfgId)
			r = Replace(r,"@date",date)
			r = Replace(r,"@MOrderId",m_MOrderSetting)
			r = Replace(r,"@cfgId",m_setjmId)
			replaceTemplete = r
		end function
		Private Function getTitleLink(title,orderId,cateid)
			If orderId&"" = "" Or orderId&"" = "0" Then
				getTitleLink = "【已删除数据】"
				Exit Function
			end if
			title = regEx.replace(title&"","")
			Dim url : url = m_detailLinkUrl
			If m_titleMaxLength > 0 Then
				If Len(title) > m_titleMaxLength Then title = Left(title,m_titleMaxLength-1) & "..."
'If m_titleMaxLength > 0 Then
			end if
			If title = "" Then title = "【无标题】"
			If Len(url&"") = 0 Then
				getTitleLink = title
				Exit Function
			end if
			If InStr(url,"@encodeId") > 0 Then
				url = Replace(url,"@encodeId",base64.pwurl(orderId))
			else
				url = Replace(url,"@id",orderId)
			end if
			url = replaceTemplete(url)
			If hasDetailPower(cateid) Then
				getTitleLink = "<a href='javascript:void(0)' class='remind_detail_link' onclick=""RemObj.openWin('" & url & "','remindWin"&configId&"');"">" & title & "</a>"
			else
				getTitleLink = title
			end if
		end function
		Public Function hasDetailPower(cateid)
			If m_detailqx = 0 Then
				hasDetailPower = True
			ElseIf existsPowerIntro(m_qxlb,m_detailqx,cateid) Then
				hasDetailPower = True
			else
				hasDetailPower = False
			end if
		end function
		Private Function getOrderStat(st)
			Select Case st
			Case 1:
			getOrderStat = "共享"
			Case 2:
			getOrderStat = "取消共享"
			Case 8 :
			getOrderStat = "审批中"
			Case 9 :
			getOrderStat = "待提交"
			Case 10:
			getOrderStat = "待审批"
			Case 11:
			getOrderStat = "审批通过"
			Case 12:
			getOrderStat = "审批退回"
			Case 16:
			getOrderStat = "未通过"
			Case 13:
			getOrderStat = "待审核"
			Case 14:
			getOrderStat = "审核通过"
			Case 15:
			getOrderStat = "审核退回"
			case 17:
			getOrderStat = "无需审批"
			Case Else
			End Select
		end function
		Private Function hasFieldInRs(ByRef r,ByVal fd)
			Dim kk
			For kk=0 To r.fields.count - 1
'Dim kk
				If r.fields(kk).name = fd Then
					hasFieldInRs = True
					Exit Function
				end if
			next
			hasFieldInRs = False
		end function
		Private Function openPower(x1,x2)
			Dim sql1,rs1,isOpen
			if x1<>"" and x2<>"" Then
				If m_UsingPowerCache Then
					Call findPower(Global_Power,x1,x2,isOpen,"","")
					openPower = isOpen
				else
					set rs1=server.CreateObject("adodb.recordset")
					sql1="select qx_open from power  with(nolock)  where ord="&uid&" and sort1="&x1&" and sort2="&x2&""
					rs1.open sql1,cn,1,1
					if rs1.eof Then
						openPower=0
						If x2=19 Then
							If cn.execute("select 1 from power with(nolock)  where ord="&uid&" and sort1="&x1&"").eof Then openPower = 1
						end if
					else
						openPower=rs1("qx_open")
					end if
					rs1.close
					set rs1=nothing
				end if
			else
				openPower=0
			end if
		end function
		Private Function IIf(e,v1,v2)
			If e = True Then
				iif = v1
			else
				iif = v2
			end if
		end function
		Public Function existsPowerIntro(byval sort1,byval sort2, byval CreatorID)
			Dim sql_qx,qx_type,qx_open,qx_intro
			dim i , item, hs, rs_qx
			hs = false
			for i = 0 to ubound(m_existsPowerIntro)
				if isarray(m_existsPowerIntro(i)) then
					item = m_existsPowerIntro(i)
					if item(0) = sort1 and item(1) = sort2 then
						qx_type = item(2)
						qx_open = item(3)
						qx_intro = item(4)
						hs = true
						exit for
					end if
				end if
			next
			if hs = false then
				sql_qx="select isnull(sort,0) as sort from qxlblist  with(nolock) where sort1=" & sort1 & " and sort2="& sort2
				set rs_qx=cn.execute(sql_qx)
				if not rs_qx.eof then
					qx_type=rs_qx(0)
				else
					qx_type=0
				end if
				rs_qx.close
				sql_qx="select isnull(qx_open,0) as qx_open,isnull(qx_intro,'') as qx_intro from [power]  with(nolock) where sort1=" & sort1 & " and sort2="&sort2&" and ord=" & uid
				set rs_qx=cn.execute(sql_qx)
				if not rs_qx.eof then
					qx_open=rs_qx(0)
					qx_intro=rs_qx(1)
				else
					qx_open=0
					qx_intro=""
				end if
				rs_qx.close
				set rs_qx=nothing
				redim preserve m_existsPowerIntro(m_expiCount)
				m_existsPowerIntro(m_expiCount) = split(sort1 & chr(1) & sort2 & chr(1) & qx_type & chr(1) & qx_open & chr(1) & qx_intro, chr(1))
				m_expiCount = m_expiCount+ 1
			end if
			if len(qx_open & "") = 0 then qx_open = 0
			qx_open = clng(qx_open)
			if qx_type = 1 then
				existsPowerIntro = (qx_open = 1)
			else
				if qx_open = 3 then
					existsPowerIntro = true
				elseif qx_open = 1 then
					existsPowerIntro =  CheckIntro(qx_intro,CreatorID&"")>0 And CreatorID > 0
				else
					existsPowerIntro = false
				end if
			end if
		end function
		private function CheckIntro(str1,str2)
			dim ids: ids = split(replace(str2 & ""," ",""),",")
			dim inx : inx = 0
			for n=0 to ubound(ids)
				if ids(n)&""<>"" and ids(n)&""<>"0" then
					inx = instr(","&replace(str1 & ""," ","")&",",","& ids(n) &",")
					if inx>0 then exit for
				end if
			next
			CheckIntro = inx
		end function
		Public Property Get user
		user = session("personzbintel2007") & ""
		If Len(user) = 0 Then
			user = request.querystring("__sys_uid_sign")
			if isnumeric(user)= false then
				user = 0
			else
				user = clng(user)
			end if
		end if
		End Property
		Public Property Get isAdmin
		dim rs
		if len(is_admin) = 0 then
			Set rs = cn.execute("select top1 from gate  with(nolock) where ord=" & me.user)
			if rs.eof then
				is_admin = false
			else
				is_admin = (rs.fields(0).value & "" = "1")
			end if
			rs.close
		end if
		isAdmin = is_admin
		End Property
		Public Property Get isSupperAdmin
		Dim rs
		If Len(is_supperadmin) = 0 Then
			If Me.isAdmin  Then
				Set rs = cn.execute("select qx_open from power  with(nolock) where sort1=66 and sort2=12 and ord=" & Me.User & " and qx_open=1")
				is_supperadmin = Not rs.eof
				rs.close
			else
				is_supperadmin = false
			end if
		end if
		isSupperAdmin = is_supperadmin
		End Property
		Private Function HTMLDecode(fString)
			if not isnull(fString) Then
				fString = replace(fString, "&gt;", ">")
				fString = replace(fString, "&lt;", "<")
				fString = Replace(fString, "&nbsp;",CHR(32) )
				fString = Replace(fString, "&quot;",CHR(34) )
				fString = Replace(fString, "&#39;",CHR(39) )
				fString = Replace(fString, "",CHR(13))
				fString = Replace(fString, "</P><P>",CHR(10) & CHR(10))
				fString = Replace(fString, "<br>",CHR(10))
				HTMLDecode = fString
			end if
		end function
	End Class
	Class StringBuffer
		Private m_idx
		Private m_contents
		Private m_maxIdx
		Public Sub push(v)
			m_contents(m_idx) = v : m_idx = m_idx + 1
'Public Sub push(v)
			If m_idx > m_maxIdx Then
				m_maxIdx = m_maxIdx + 500
'If m_idx > m_maxIdx Then
				ReDim Preserve m_maxIdx(m_maxIdx)
			end if
		end sub
		Public Property Get toString
		toString = Join(m_contents,"")
		End Property
		Private Sub Class_Initialize
			m_idx = 0
			m_maxIdx = 500
			ReDim m_contents(m_maxIdx)
		end sub
		Private Sub Class_Teriminate
			Erase m_contents
		end sub
	End Class
	Class ReminderList
		Private m_reminders()
		Public m_rIdx
		Public m_popIdx
		Public Sub push(remindObj)
			m_rIdx = m_rIdx + 1
'Public Sub push(remindObj)
			ReDim Preserve m_reminders(m_rIdx)
			Set m_reminders(m_rIdx) = remindObj
		end sub
		Public Function pop
			If Me.hasRemind = False Then Exit Function
			Set pop = m_reminders(m_popIdx)
			m_popIdx = m_popIdx + 1
			Set pop = m_reminders(m_popIdx)
		end function
		Public Property Get reminders
		reminders = m_reminders
		End Property
		Public Property Get hasRemind
		hasRemind = m_rIdx >=0 And m_popIdx <= m_rIdx
		End Property
		Private Sub Class_Initialize
			m_rIdx = -1
'Private Sub Class_Initialize
			m_popIdx = 0
		end sub
		Private Sub Class_Teriminate
			Dim i
			For i = 0 To ubound(m_reminders)
				Set m_reminders(i) = Nothing
			next
		end sub
	end class
	
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
	ord=getInt(request.QueryString("ord"))
	num=request.QueryString("num")
	title=Conver(request.Form("title"))
	title_length=conn.execute("select length/2 from syscolumns where id=(select id from sysobjects where name='paysq') and name='title'")(0)
	title=left(title,title_length)
	bz=getInt(request("bz"))
	if bz=0 then bz=14
	allmoney=getInt(request("allpay"))
	allnum=getInt(request("allnum"))
	ret=request.Form("ret")
	member2=request.Form("member2")
	if member2="" then
		Response.write("<script>alert('请选择费用申请人');</script>")
		call db_close : Response.end
	end if
	if allmoney&""<>"" And Not IsNumeric(allmoney&"") then
		Response.write("<script>alert('请输入正确的申请费用');</script>")
		call db_close : Response.end
	end if
	sql="select 1 from sortonehy where gate2=41"
	if conn.execute(sql).eof then
		Response.write("<script>alert('没有分类请填写分类');</script>")
		call db_close : Response.end
	end if
	rejk=getInt(request.Form("rejk"))
	intro=Conver(request.Form("intro"))
	remark=request.Form("remark")
	days=getInt(request.Form("days"))
	conn.begintrans
	conn.Execute "delete paysqlist where fid="&ord&" AND del2 = 1 "
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select p.* from paytype p inner join sortonehy s on s.gate2=41 and s.ord=p.sort2 order by s.gate1 desc, p.gate2 desc"
	rs1.open sql1,conn,1,1
	if not rs1.eof then
		do until rs1.eof
			a=rs1("id")
			numarr=split(num,",")
			for i=0 to Ubound(numarr)
				if numarr(i)<>"" and (not isnull(numarr(i))) then
					pay1=Trim(request("money_"&a&"_"&numarr(i)))
					note1=trim(request("note_"&a&"_"&numarr(i)))
					hdj1=trim(request("hdj_"&a&"_"&numarr(i)))
					payid=trim(request("bh_"&a&"_"&numarr(i)))
					num1=trim(request("num_"&a&"_"&numarr(i)))
					if num1="" or isnull(num1) then num1=0
					startime=request("startime_"&a&"_"&numarr(i))
					endtime=request("endtime_"&a&"_"&numarr(i))
					If Len(startime&"")=0 Then startime=Date()
					If Len(endtime&"")=0 Then endtime=Date()
					If isdate(startime)=False Or isdate(endtime)=False Then
						conn.RollbackTrans
						Response.write "<script>alert('开始时间或结束时间格式不正确');</script>"
						conn.close
						call db_close : Response.end()
					elseif cdate(startime)>cdate(endtime) then
						conn.RollbackTrans
						Response.write "<script>alert('开始时间不能早于结束时间');</script>"
						conn.close
						call db_close : Response.end()
					end if
					mdd=request("mdd_"&a&"_"&numarr(i))
					smdd=request("smdd_"&a&"_"&numarr(i))
					lic=request("lic_"&a&"_"&numarr(i))
					jtgj=request("jtgj_"&a&"_"&numarr(i))
					retime=request("retime_"&a&"_"&numarr(i))
					startime1=request("startime1_"&a&"_"&numarr(i))
					endtime1=request("endtime1_"&a&"_"&numarr(i))
					If Len(startime1&"")=0 Then startime1=Date()
					If Len(endtime1&"")=0 Then endtime1=Date()
					If isdate(endtime1)=False Or isdate(startime1)=False Then
						conn.RollbackTrans
						Response.write "<script>alert('开始时间或结束时间格式不正确，请修改相应的日期字段内容');</script>"
						conn.close
						call db_close : Response.end()
					elseif cdate(startime1)>cdate(endtime1) then
						conn.RollbackTrans
						Response.write "<script>alert('开始时间不能早于结束时间');</script>"
						conn.close
						call db_close : Response.end()
					end if
					city=request("city_"&a&"_"&numarr(i))
					hatol=request("hatol_"&a&"_"&numarr(i))
					ggdate=request("ggdate_"&a&"_"&numarr(i))
					ggdx=request("ggdx_"&a&"_"&numarr(i))
					ggsy=request("ggsy_"&a&"_"&numarr(i))
					lw=request("lw_"&a&"_"&numarr(i))
					xytime=request("xytime_"&a&"_"&numarr(i))
					yt=request("yt_"&a&"_"&numarr(i))
					if num1<>"" and (not isnull(num1)) then
						if Not IsNumeric(num1&"") then
							conn.RollbackTrans
							Response.write("<script>alert('请输入正确的张数');</script>")
							call db_close : Response.end
						end if
					end if
					if pay1<>"" and (not isnull(pay1)) then
						if Not IsNumeric(pay1&"") then
							conn.RollbackTrans
							Response.write("<script>alert('请输入正确的金额');</script>")
							call db_close : Response.end
						end if
						if hdj1<>"" and (not isnull(hdj1)) then
							sql7="select * from paysqlist where id = "& hdj1
						else
							sql7="select * from paysqlist where 1=2"
						end if
						set rs7=server.CreateObject("adodb.recordset")
						rs7.open sql7,conn,1,3
						if hdj1="" or isnull(hdj1)  then
							rs7.addnew
						end if
						If Len(smdd & "") > 200 Then smdd = Left(smdd, 200)
						If Len(mdd & "") > 200 Then mdd = Left(mdd, 200)
						If Len(lic & "") > 20 Then lic = Left(lic, 20)
						If Len(jtgj & "") > 20 Then jtgj = Left(jtgj, 20)
						If Len(city & "") > 200 Then city = Left(city, 200)
						If Len(hatol & "") > 100 Then hatol = Left(hatol, 100)
						If Len(ggsy & "") > 300 Then ggsy = Left(ggsy, 300)
						If Len(note1 & "") > 200 Then note1 = Left(note1, 200)
						If Len(yt & "") > 200 Then yt = Left(yt, 200)
						If Len(lw & "") > 200 Then lw = Left(lw, 200)
						If startime&"" <> "" Then rs7("startime")=startime
						rs7("staraddr")=smdd
						If endtime&"" <> "" Then rs7("endtime")=endtime
						rs7("endaddr")=mdd
						rs7("lc")=lic
						rs7("bus")=jtgj
						If retime&"" <> "" Then rs7("retime")=retime
						If startime1&"" <> "" Then rs7("startime1")=startime1
						If endtime1&"" <> "" Then rs7("endtime1")=endtime1
						rs7("city")=city
						rs7("hotel")=hatol
						If ggdate&"" <> "" Then rs7("ggtime")=ggdate
						rs7("ggcate")=ggdx
						rs7("ggintro")=ggsy
						rs7("gglw")=lw
						If xytime&"" <> "" Then rs7("xytime")=xytime
						rs7("yt")=yt
						rs7("bh")=payid
						rs7("num")=num1
						rs7("note")=note1
						rs7("money1")=pay1
						if hdj1&""="" or isnull(hdj1) then
							rs7("fid")=ord
							rs7("sort1")=rs1("id")
						end if
						rs7("adddate")=now
						rs7("addcateid")=session("personzbintel2007")
						rs7("del")=1
						rs7.update
						set rs7=nothing
					end if
				end if
			next
			rs1.movenext
		loop
	end if
	set rs1=nothing
	sqltext="update paysqlist set del=1 where fid="&ord
	conn.execute(sqltext)
	ModifyStamp=replace(replace(replace(now,"-",""),":","")," ","")&timer
	conn.execute(sqltext)
	sqltext="update paysq set ModifyStamp='"&ModifyStamp&"',days="&days&",del=1,sqmoney="& allmoney &",intro='"&replace(intro,"'","''")&"',remark='"&replace(remark,"'","''")&"',sp_date='"&ret&"',cateid="&member2&",jk="&rejk&",bz="&bz&",title='"&replace(title,"'","''")&"' where id="&ord
	conn.execute(sqltext)
	set rs88=server.CreateObject("adodb.recordset")
	rs88.open "select top 1 money1,id from sp where gate2=7 order by gate1 asc",conn,1,1
	if rs88.eof then
		money1_sp=9999999999
		id_sp=0
	else
		money1_sp=zbcdbl(rs88("money1"))
		id_sp=rs88("id")
	end if
	rs88.close
	set rs88=nothing
	Set commSP = New CommSPHandle
	Call commSP.init("paysq",ord)
	sp_id = request("sp")
	If sp_id &"" = "" Then sp_id = 0 Else sp_id = CLng(sp_id)
	cateid_sp = request("cateid_sp")
	If cateid_sp &"" = "" Then cateid_sp = 0 Else cateid_sp = CLng(cateid_sp)
	commSP.reBack = true
	Call commSP.saveBill2(sp_id, cateid_sp, 0, allmoney)
	rUrl = "paysq.asp"
	if conn.execute("select 1 from paysq where id="&ord &" and complete=1 and jk=1 ").eof=false then
		rd=0
		spstate = 0
		Set rs = conn.execute("select top 1 id,isnull(spstate,0) spstate from payjk where sqid="&ord &" order by id desc")
		If rs.eof = False Then
			rd = rs("id")
			spstate =  rs("spstate")
			if cdbl(spstate)<>1 then
				rUrl = "paysqjk.asp?ord="&rd
			end if
		end if
		rs.close
	end if
	conn.CommitTrans
	conn.close
	set conn = nothing
	Response.write "" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "    parent.window.location = """
	Response.write rUrl
	Response.write """;" & vbcrlf & "</script>"
	
%>
