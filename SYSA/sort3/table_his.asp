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
	
	Response.Charset="UTF-8"
	Response.ExpiresAbsolute = Now() - 1
	Response.Expires = 0
	Response.CacheControl = "no-cache"
'Response.Expires = 0
	Response.AddHeader "Pragma", "No-Cache"
'Response.Expires = 0
	Function HiddenNumber(ByVal phoneNum)
		Dim numLength,i
		numLength = Len(phoneNum)
		If numLength > 0 Then
			For i = 1 To numLength
				HiddenNumber = HiddenNumber & "*"
			next
		else
			HiddenNumber = ""
		end if
	end function
	Function IsPhonePower(ByVal UserID)
		If UserID & "" = "" Then
			UserID = "0"
		end if
		If ZBRuntime.MC(2000) then
			Dim rs_qx,sql_qx,qx_open,qx_intro,qx_type,sort1,sort2
			sort1 = 2
			sort2 = 6
			sql_qx = "SELECT ISNULL(sort,0) sort FROM qxlblist WHERE sort1 = "&sort1&" AND sort2 = "&sort2&" "
			Set rs_qx = conn.Execute(sql_qx)
			If Not rs_qx.Eof Then
				qx_type = rs_qx("sort")
			else
				qx_type = 0
			end if
			rs_qx.Close : Set rs_qx = Nothing
			If qx_type <> 0 Then
				sql_qx = "SELECT ISNULL(qx_open,0),ISNULL(qx_intro,'-222') FROM [POWER] WHERE sort1 = "&sort1&" AND sort2 = "&sort2&" AND ord = "&session("personzbintel2007")&" "
'If qx_type <> 0 Then
				Set rs_qx = conn.Execute(sql_qx)
				If Not rs_qx.Eof Then
					qx_open              = rs_qx(0)
					qx_intro     = rs_qx(1)
				else
					qx_open = 0
					qx_intro = ""
				end if
				rs_qx.Close : Set rs_qx = Nothing
				If qx_open = qx_type Or (qx_open = 1 And InStr(","&Replace(qx_intro & ""," ","")&",",","&Replace(UserID & ""," ","")&",") > 0 ) Then
					IsPhonePower = True
				else
					IsPhonePower = False
				end if
			else
				IsPhonePower = False
			end if
		else
			IsPhonePower = True
		end if
	end function
	Function GetPhoneNumber(ByVal phoneNum, ByVal UserID)
		If IsPhonePower(UserID) Then
			GetPhoneNumber = phoneNum
		Else
			GetPhoneNumber = HiddenNumber(phoneNum)
		end if
	end function
	Function HexEncode(ByVal data)
		Dim s, c, i ,rnds, item
		c = Len(data) - 1
'Dim s, c, i ,rnds, item
		rnds = Split("g,h,i,j,k,l,m,n,o",",")
		If c = - 1 Then Exit function
		rnds = Split("g,h,i,j,k,l,m,n,o",",")
		For i = 0 To c
			If i > 0 Then
				s = s & rnds(int(rnd*9))
			end if
			item = LCase(Hex(Ascw(Mid(data, i+1, 1))))
			s = s & rnds(int(rnd*9))
			item = Replace(item,"0","q")
			item = Replace(item,"1","p")
			item = Replace(item,"2","t")
			item = Replace(item,"3","s")
			item = Replace(item,"4","x")
			item = Replace(item,"5","u")
			item = Replace(item,"6","v")
			item = Replace(item,"7","y")
			item = Replace(item,"8","z")
			item = Replace(item,"9","w")
			s = s & item
		next
		HexEncode = s
	end function
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
	
	
	dim showHtMoney, showCB, showFyMoney, showThMoney, showSkMoney
	showHtMoney = 0
	showCB = 0
	showFyMoney = 0
	showThMoney = 0
	showSkMoney = 0
	If instr(Lcase(request.ServerVariables("URL")),"sysa/mobilephone/")=0 Then
		If ZBRuntime.MC(6000) Or ZBRuntime.MC(7000) Then showHtMoney = 1
		If ZBRuntime.MC(17003) Then showCB = 1
		If ZBRuntime.MC(27000) Then showFyMoney = 1
		If ZBRuntime.MC(8000) Then showThMoney = 1
		If ZBRuntime.MC(23000) Or ZBRuntime.MC(23001) Then showSkMoney = 1
	end if
	function getHtYhhMoney(htord)
		dim rs, yhhMoney
		yhhMoney = 0
		If ZBRuntime.MC(6000) Or ZBRuntime.MC(7000) Then
			set rs = conn.execute("select isnull(money2,money1) money2 from contract WITH(NOLOCK) where ord="& htord)
			if rs.eof = false then
				yhhMoney = cdbl(rs("money2"))
			end if
			rs.close
			set rs = nothing
		end if
		if yhhMoney&"" = "" then yhhMoney = 0 else yhhMoney = cdbl(yhhMoney)
		getHtYhhMoney = yhhMoney
	end function
	function getHtTaxValue(htord)
		dim rs, taxValue
		taxValue = 0
		If ZBRuntime.MC(6000) Or ZBRuntime.MC(7000) Then
			set rs = conn.execute("select case when b.invoiceMode=1 and isnull(b.dataversion,3100)<3179 then cast(b.money2/(1+isnull(b.taxRate,1)/100) as decimal(25,12))*cast(isnull(b.taxRate,1)/100 as decimal(25,12))  else sum(a.taxValue*isnull(c.hl,1)) end taxValue from contractlist a WITH(NOLOCK) inner join contract b on a.contract = b.ord left join hl c on c.bz = b.bz and b.date3 = c.date1 where a.del=1 and a.contract="&htord&" group by b.invoiceMode,b.money2,b.taxRate,b.dataversion")
			if rs.eof = false then
				taxValue = rs("taxValue")
			end if
			rs.close
			set rs = nothing
		end if
		if taxValue&"" = "" then taxValue = 0 else taxValue = cdbl(taxValue)
		getHtTaxValue = taxValue
	end function
	function getHtJinjiaMoney(htord)
		dim rs, money1
		money1 = 0
		set rs = conn.execute("select sum(tpricejy) tpricejy from contractlist WITH(NOLOCK) where del=1 and contract="& htord)
		if rs.eof = false then
			money1 =zbcdbl( rs("tpricejy"))
		end if
		rs.close
		set rs = nothing
		if money1&"" = "" then money1 = 0 else money1 = cdbl(money1)
		getHtJinjiaMoney = money1
	end function
	function getHtThTaxValue(htord)
		dim rs, sql, taxValue
		taxValue = 0
		If ZBRuntime.MC(8000) Then
			sql = "select isnull(SUM(thl.taxValue),0) * isnull(h.hl,1) taxValue "&_
			"   FROM contractth th WITH(NOLOCK)  "&_
			"   INNER JOIN contractthlist thl WITH(NOLOCK) ON thl.caigou=th.ord AND th.del=1 and thl.del=1 and thl.contract="& htord &" "&_
			"   INNER JOIN contractlist ctl WITH(NOLOCK) ON thl.contractlist=ctl.id AND thl.contract=ctl.contract "&_
			"   INNER JOIN contract ct WITH(NOLOCK) ON ctl.contract=ct.ord "&_
			"   left JOIN hl h WITH(NOLOCK) ON ct.bz = h.bz and ct.date3 = h.date1 "&_
			"   GROUP by thl.contract,isnull(h.hl,1)"
			set rs = conn.execute(sql)
			if rs.eof = false then
				taxValue = rs("taxValue")
			end if
			rs.close
			set rs = nothing
		end if
		if taxValue&"" = "" then taxValue = 0 else taxValue = cdbl(taxValue)
		getHtThTaxValue = taxValue
	end function
	Function OutStore_Cost(contract_ord)
		dim rs1, sql1, money_cpall : money_cpall=0
		if trim(contract_ord)<>"" and isnumeric(trim(contract_ord)) then
			sql1 = "select "&_
			"   isnull(sum( isnull(k.finamoney,0) ),0) money1 " &_
			"   from kuoutlist2 k WITH(NOLOCK) "&_
			"   where (k.sort1=1 or k.sort1=4) and k.contract="&contract_ord&" and k.del=1 "
			set rs1 = server.CreateObject("adodb.recordset")
			rs1.open sql1,conn,1,1
			if not rs1.eof then
				money_cpall = cdbl(rs1("money1"))
			end if
			rs1.close
			set rs1=nothing
		end if
		if money_cpall&"" = "" then money_cpall = 0 else money_cpall = cdbl(money_cpall)
		OutStore_Cost= money_cpall
	end function
	Function OutStore_Th_Cost(contract_ord)
		dim rs1, rs7, sql1, sql7
		if trim(contract_ord)<>"" and isnumeric(trim(contract_ord)) then
			dim money_cpall : money_cpall=0
			sql1="select c.price1,d.num1,c.kuinlist from kuoutlist2 c WITH(NOLOCK),contractthlist d WITH(NOLOCK),contractth e WITH(NOLOCK) where e.del=1 and d.del=1 and e.ord=d.caigou and c.id=d.kuoutlist2 and d.contract="&contract_ord &" and c.del=1"
			set rs1 = server.CreateObject("adodb.recordset")
			rs1.open sql1,conn,1,1
			if not rs1.eof then
				do until rs1.eof
					if rs1("kuinlist")<>"" and rs1("kuinlist")<>"0"  then
						sql7 = "select ROUND(REPLACE(price1,',',''),8) from kuinlist WITH(NOLOCK) where id="&rs1("kuinlist")&" and del=1"
						set rs7 = server.CreateObject("adodb.recordset")
						rs7.open sql7,conn,1,1
						if rs7.eof then
							money_cpall=money_cpall+cdbl(rs1("price1")) * cdbl(rs1("num1"))
'if rs7.eof then
						else
							money_cpall=money_cpall+cdbl(rs7("price1")) * cdbl(rs1("num1"))
'if rs7.eof then
						end if
						rs7.close
						set rs7=nothing
					else
						money_cpall=money_cpall+cdbl(rs1("price1")) * cdbl(rs1("num1"))
						set rs7=nothing
					end if
					rs1.movenext
				loop
			end if
			rs1.close
			set rs1=nothing
			if money_cpall&"" = "" then money_cpall = 0 else money_cpall = cdbl(money_cpall)
			OutStore_Th_Cost= money_cpall
		end if
	end function
	function getHtPaybacktype(htord)
		dim rs, paybacktype
		paybacktype = 0
		set rs = conn.execute("select paybacktype from contract WITH(NOLOCK) where ord="& htord)
		if rs.eof = false then
			paybacktype = rs("paybacktype")
		end if
		rs.close
		set rs = nothing
		getHtPaybacktype = paybacktype
	end function
	function getHtProCb(htord)
		dim rs, rs1, sql1, money_cpall, paybacktype
		money_cpall = 0
		If ZBRuntime.MC(17003) Then
			sql1 = "select isnull(sum(d.finamoney) ,0) as money1 "&_
			"from kuoutlist2 d WITH(NOLOCK) "&_
			"INNER JOIN kuout k WITH(NOLOCK) ON k.ord=d.kuout "&_
			"where k.sort1 in (1,4) and k.order1="& htord &" and d.del=1 "
			set rs1 = server.CreateObject("adodb.recordset")
			rs1.open sql1,conn,1,1
			if rs1.eof = false then
				money_cpall=money_cpall+CDbl(rs1("money1"))
'if rs1.eof = false then
			end if
			rs1.close
			set rs1=nothing
			paybacktype = getHtPaybacktype(htord)
			if paybacktype&"" = "1" then
				money_cpall = OutStore_Cost(htord)
			end if
		end if
		if money_cpall&"" = "" then money_cpall = 0 else money_cpall = cdbl(money_cpall)
		getHtProCb = money_cpall
	end function
	function getHtProCbX(htord, ftype)
		dim rs, rs1, sql1, money_cpall
		money_cpall = 0
		Select Case ftype
		Case ""
		money_cpall = getHtProCb(htord)
		case "jinjia"
		money_cpall=getHtJinjiaMoney(htord)
		End Select
		if money_cpall&"" = "" then money_cpall = 0 else money_cpall = cdbl(money_cpall)
		getHtProCbX = money_cpall
	end function
	function getHtFyMoney(htord)
		dim rs1, sql1, money_fyall
		money_fyall = 0
		If ZBRuntime.MC(27000) Then
			sql1 = "select isnull(sum(a.money1*isnull(b.hl,1)),0) as money1 from pay a WITH(NOLOCK) inner join f_pay c with(nolock) on c.id = a.fid and c.del=1 left join hl b WITH(NOLOCK) on a.bz = b.bz and convert(varchar(10),a.date1,120)=convert(varchar(10),b.date1,120) where a.contract="&htord&" and a.del=1 and a.complete=3 "
			set rs1 = server.CreateObject("adodb.recordset")
			rs1.open sql1,conn,1,1
			if rs1.eof = false then
				money_fyall=cdbl(rs1("money1"))
			end if
			rs1.close
			set rs1=nothing
		end if
		if money_fyall&"" = "" then money_fyall = 0 else money_fyall = cdbl(money_fyall)
		getHtFyMoney = money_fyall
	end function
	function getHtThMoney(htord)
		dim rs1, sql1, total_th
		total_th = 0
		If ZBRuntime.MC(8000) Then
			sql1 = "select SUM(isnull(cld.money1,thl.money1)*dbo.gethl(thl.bz,thl.date1,getdate())) from contractth th WITH(NOLOCK) INNER JOIN contractthlist thl WITH(NOLOCK) ON thl.caigou=th.ord AND th.del=1 and thl.del=1 and thl.contract="&htord&" left join contractthListDetail cld on cld.contractthlist=thl.id and cld.thtype='GOODS' group by thl.contract"
'"select isnull(sum(a.money2*isnull(c.hl,1)),0),isnull(sum(a.money2),0) from contractthListDetail a inner join contractthlist b on a.contractthlist = b.id and b.del=1 left join hl c on c.bz = b.bz and convert(varchar(10),c.date1,120) = convert(varchar(10),b.date1,120) where a.contract="&htord&" and a.del=1"
			set rs1 = server.CreateObject("adodb.recordset")
			rs1.open sql1,conn,1,1
			if rs1.eof = false then
				total_th=cdbl(rs1(0))
			end if
			rs1.close
			set rs1=nothing
		end if
		if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
		getHtThMoney = total_th
	end function
	function getHtSTMoney(htord)
		dim rs, stmoney, sql
		stmoney = 0
		if htord&""="" then htord = 0 else htord = cdbl(htord)
		if htord>0 then
			sql = "select isnull((select SUM(thl.money1*dbo.gethl(thl.bz,thl.date1,getdate())) from contractth th WITH(NOLOCK) INNER JOIN contractthlist thl WITH(NOLOCK) ON thl.caigou=th.ord AND th.del=1 and thl.del=1 and thl.contract="&htord&" group by thl.contract),0) - "&_
			"isnull((select isnull(sum(a.money2*dbo.gethl(b.bz,b.date3,getdate())),0) from contractthListDetail a WITH(NOLOCK)" &_
			"inner join contractth b WITH(NOLOCK) on a.contractth = b.ord and b.del=1 and isnull(b.sp,0)=0 "&_
			"and a.thtype='GOODS' and a.contract=" & htord &"),0)"
			set rs = conn.execute(sql)
			if rs.eof = false then
				stmoney = rs(0)
			end if
		end if
		if stmoney&""="" then stmoney = 0 else stmoney = cdbl(stmoney)
		getHtSTMoney = stmoney
	end function
	function getHtThYbzMoney(htord)
		dim rs1, sql1, total_th_ybz
		total_th_ybz = 0
		If ZBRuntime.MC(8000) Then
			sql1 = "select SUM(thl.money1) from contractth th WITH(NOLOCK) INNER JOIN contractthlist thl WITH(NOLOCK) ON thl.caigou=th.ord AND th.del=1 and thl.del=1 and thl.contract="&htord&" group by thl.contract"
'"select isnull(sum(a.money2*isnull(c.hl,1)),0),isnull(sum(a.money2),0) from contractthListDetail a inner join contractthlist b on a.contractthlist = b.id and b.del=1 left join hl c on c.bz = b.bz and convert(varchar(10),c.date1,120) = convert(varchar(10),b.date1,120) where a.contract="&htord&" and a.del=1"
			set rs1 = server.CreateObject("adodb.recordset")
			rs1.open sql1,conn,1,1
			if rs1.eof = false then
				total_th_ybz=rs1(0)
			end if
			rs1.close
			set rs1=nothing
		end if
		if total_th_ybz&"" = "" then total_th_ybz = 0 else total_th_ybz = cdbl(total_th_ybz)
		getHtThYbzMoney = total_th_ybz
	end function
	function getHtThCost(htord)
		dim rs1, sql1, total_th_cost, paybacktype
		total_th_cost = 0
		If ZBRuntime.MC(8000) Then
			sql1 = "select (case a.paybacktype when 1 then  " & vbcrlf &_
			"  (select isnull(sum(c.price1*d.num1),0) from kuoutlist2 c WITH(NOLOCK),contractthlist d WITH(NOLOCK),contractth e WITH(NOLOCK) where e.del=1 and d.caigou=e.ord and c.del=1 and d.del=1 and c.id=d.kuoutlist2 and d.contract=a.ord) " & vbcrlf &_
			"else   " & vbcrlf &_
			"  (select SUM(ISNULL((CASE ISNULL(c.kuinlist,0) WHEN 0 THEN c.price1*d.num1 ELSE ROUND(REPLACE(r.price1,',',''),8)*d.num1 END),c.price1*d.num1)) " & vbcrlf &_
			"  FROM kuoutlist2 c WITH(NOLOCK) INNER JOIN contractthlist d WITH(NOLOCK) ON c.id=d.kuoutlist2 and c.del=1 and d.del=1 " & vbcrlf &_
			"  INNER JOIN contractth e WITH(NOLOCK) ON e.del=1 and e.ord=d.caigou and d.contract=a.ord " & vbcrlf &_
			"  LEFT JOIN kuinlist r WITH(NOLOCK) ON r.id=c.kuinlist AND r.del=1) " & vbcrlf &_
			"end)  from contract a WITH(NOLOCK) where a.ord="& htord
			set rs1 = conn.execute(sql1)
			if rs1.eof = false then
				total_th_cost=rs1(0)
			end if
			rs1.close
			set rs1=nothing
		end if
		if total_th_cost&"" = "" then total_th_cost = 0 else total_th_cost = cdbl(total_th_cost)
		getHtThCost = total_th_cost
	end function
	function getHtThJinJiaCost(htord)
		dim rs1, sql1, total_th_cost, paybacktype
		total_th_cost = 0
		If ZBRuntime.MC(8000) Then
			sql1 = "select isnull(sum(c.pricejy*d.num1),0) "&_
			"from contract a WITH(NOLOCK) "&_
			"inner join contractthlist d WITH(NOLOCK) on d.contract=a.ord "&_
			"inner join contractth e WITH(NOLOCK) on d.caigou=e.ord "&_
			"inner join contractlist c WITH(NOLOCK) on c.id=d.contractlist "&_
			"where e.del=1 and c.del=1 and d.del=1 and a.ord="& htord
			set rs1 = conn.execute(sql1)
			if rs1.eof = false then
				total_th_cost=rs1(0)
			end if
			rs1.close
			set rs1=nothing
		end if
		if total_th_cost&"" = "" then total_th_cost = 0 else total_th_cost = cdbl(total_th_cost)
		getHtThJinJiaCost = total_th_cost
	end function
	function getHtDzMoney(htord)
		dim rs, money_hkall,sql
		money_hkall = 0
		If ZBRuntime.MC(23000) Or ZBRuntime.MC(23001) Then
			sql = "select (case isnull(a.importPayback,0) when 1 then isnull(a.money1,0) else isnull(k.money1,0) end) money1 "&_
			"   from contract a WITH(NOLOCK) "&_
			"   left join (select p.contract, isnull(sum(p.money1*dbo.gethl(c.bz,isnull(p.date5,c.date3),getdate())),0) as money1 "&_
			"from payback p WITH(NOLOCK) inner join contract c WITH(NOLOCK) on p.contract=c.ord and p.del=1 and p.complete='3' and p.completeType<>7 and p.contract="& htord &" group by p.contract"&_
			"   ) k on k.contract=a.ord where a.ord="& htord &""
			set rs = conn.execute(sql)
			if rs.eof = false then
				money_hkall =zbcdbl( rs("money1"))
			end if
			rs.close
			set rs = nothing
		end if
		if money_hkall&"" = "" then money_hkall = 0 else money_hkall = cdbl(money_hkall)
		getHtDzMoney = money_hkall
	end function
	function getHtDzYMoney(htord)
		dim rs, money_hkall
		money_hkall = 0
		If ZBRuntime.MC(23000) Or ZBRuntime.MC(23001) Then
			set rs = conn.execute("select isnull(sum(p.money1),0) as money1 from payback p WITH(NOLOCK) inner join contract c WITH(NOLOCK) on p.contract=c.ord and p.contract="& htord &" and p.del=1 and p.complete='3' and p.CompleteType<>7")
			if rs.eof = false then
				money_hkall =zbcdbl( rs("money1"))
			end if
			rs.close
			set rs = nothing
		end if
		if money_hkall&"" = "" then money_hkall = 0 else money_hkall = cdbl(money_hkall)
		getHtDzYMoney = money_hkall
	end function
	function getHtBackMLMoney(htord)
		dim rs, mlmoney
		mlmoney = 0
		If ZBRuntime.MC(23000) Or ZBRuntime.MC(23001) Then
			set rs = conn.execute("select isnull(sum(p.money1),0) as money1 from payback p WITH(NOLOCK) inner join contract c WITH(NOLOCK) on p.contract=c.ord and p.contract="& htord &" and p.del=1 and p.complete='3' and p.CompleteType=7")
			if rs.eof = false then
				mlmoney =zbcdbl( rs("money1"))
			end if
			rs.close
			set rs = nothing
		end if
		if mlmoney&"" = "" then mlmoney = 0 else mlmoney = cdbl(mlmoney)
		getHtBackMLMoney = mlmoney
	end function
	Function GetSetopenValue(keysign,  nullvalue)
		dim rs, ret
		ret = ""
		if keysign&""<>"" then
			set rs = conn.execute("select intro from setopen WITH(NOLOCK) where sort1="& keysign)
			If rs.eof = false then
				ret = rs("intro")
			end if
		end if
		if ret&"" = "" then ret = nullvalue
		GetSetopenValue = ret
	end function
	function getHtMlMoney(htord)
		dim mlMoney, num2018030701
		mlMoney = 0
		if htord &"" = "" then htord = 0
		if htord>0 then
			num2018030701 = GetSetopenValue(2018030701, 2)
			select case num2018030701&""
			case "1"
			mlMoney = getHtYhhMoney(htord) - getHtTaxValue(htord) + getHtThTaxValue(htord) - getHtProCb(htord) -getHtFyMoney(htord) -getHtThMoney(htord) + getHtThCost(htord)
'case "1"
			case "2"
			mlMoney = getHtYhhMoney(htord) - getHtProCb(htord) -getHtFyMoney(htord) -getHtThMoney(htord) + getHtThCost(htord)
'case "2"
			case "3"
			mlMoney = getHtDzMoney(htord) - getHtTaxValue(htord) + getHtThTaxValue(htord) - getHtProCb(htord) -getHtFyMoney(htord) -getHtSTMoney(htord) + getHtThCost(htord)
'case "3"
			case "4"
			mlMoney = getHtDzMoney(htord) - getHtProCb(htord) -getHtFyMoney(htord) -getHtSTMoney(htord) + getHtThCost(htord)
'case "4"
			end select
		end if
		getHtMlMoney = mlMoney
	end function
	function getHtMlMoneyX(htord,ftype)
		dim mlMoney, num2018030701
		mlMoney = 0
		if htord &"" = "" then htord = 0
		if htord>0 then
			num2018030701 = GetSetopenValue(2018030701, 2)
			Select Case ftype
			Case "" : mlMoney = getHtMlMoney(htord)
			Case Else:
			select case num2018030701&""
			case "1"
			mlMoney = getHtYhhMoney(htord) - getHtTaxValue(htord) + getHtThTaxValue(htord) - getHtProCbX(htord,ftype) -getHtFyMoney(htord) -getHtThMoney(htord) + getHtThJinJiaCost(htord)
'case "1"
			case "2"
			mlMoney = getHtYhhMoney(htord) - getHtProCbX(htord,ftype) -getHtFyMoney(htord) -getHtThMoney(htord) + getHtThJinJiaCost(htord)
'case "2"
			case "3"
			mlMoney = getHtDzMoney(htord) - getHtTaxValue(htord) + getHtThTaxValue(htord) - getHtProCbX(htord,ftype) -getHtFyMoney(htord) -getHtSTMoney(htord) + getHtThJinJiaCost(htord)
'case "3"
			case "4"
			mlMoney = getHtDzMoney(htord) - getHtProCbX(htord,ftype) -getHtFyMoney(htord) -getHtSTMoney(htord) + getHtThJinJiaCost(htord)
'case "4"
			end select
			End Select
		end if
		getHtMlMoneyX = mlMoney
	end function
	function getHtMlMoney2(ByVal formulaIdx, ByVal htMoney, ByVal dzMoney, ByVal taxValue, ByVal thTaxValue, ByVal proCb, ByVal fyMoney, ByVal thMoney, ByVal sthMoney, ByVal thCost)
		dim mlMoney
		mlMoney = 0
		if formulaIdx &"" = "" then formulaIdx = 0 else formulaIdx = cdbl(formulaIdx)
		if htMoney &"" = "" then htMoney = 0 else htMoney = cdbl(htMoney)
		if dzMoney &"" = "" then dzMoney = 0 else dzMoney = cdbl(dzMoney)
		if taxValue &"" = "" then taxValue = 0 else taxValue = cdbl(taxValue)
		if thTaxValue &"" = "" then thTaxValue = 0 else thTaxValue = cdbl(thTaxValue)
		if proCb &"" = "" then proCb = 0 else proCb = cdbl(proCb)
		if fyMoney &"" = "" then fyMoney = 0 else fyMoney = cdbl(fyMoney)
		if thMoney &"" = "" then thMoney = 0 else thMoney = cdbl(thMoney)
		if sthMoney &"" = "" then sthMoney = 0 else sthMoney = cdbl(sthMoney)
		if thCost &"" = "" then thCost = 0 else thCost = cdbl(thCost)
		if formulaIdx>0 then
			select case formulaIdx&""
			case "1"
			mlMoney = htMoney - taxValue + thTaxValue - proCb -fyMoney -thMoney + thCost
'case "1"
			case "2"
			mlMoney = htMoney - proCb -fyMoney -thMoney + thCost
'case "2"
			case "3"
			mlMoney = dzMoney - taxValue + thTaxValue - proCb -fyMoney - sthMoney + thCost
'case "3"
			case "4"
			mlMoney = dzMoney - proCb -fyMoney - sthMoney + thCost
'case "4"
			end select
		end if
		getHtMlMoney2 = mlMoney
	end function
	function getHtMlRate(htord)
		dim money2, mlRate, total_th,  num2018030701
		mlRate = 0 : total_th = 0
		num2018030701 = GetSetopenValue(2018030701, 2)
		if htord &"" = "" then htord = 0
		select case num2018030701&""
		case "1", "2":
		money2 = getHtYhhMoney(htord)
		total_th = getHtThMoney(htord)
		case "3", "4":
		money2 = getHtDzMoney(htord)
		total_th = getHtSTMoney(htord)
		end select
		if money2&"" = "" then money2 = 0 else money2 = cdbl(money2)
		if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
		if money2<>0 and (money2-total_th)<>0 then
'if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
			mlRate=getHtMlMoney(htord)*100/(CDbl(money2)-CDbl(total_th))
'if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
		end if
		if mlRate&"" = "" then mlRate = 0
		getHtMlRate = mlRate
	end function
	function getHtMlRateX(htord, ftype)
		dim money2, mlRate, total_th,  num2018030701
		mlRate = 0 : total_th = 0
		num2018030701 = GetSetopenValue(2018030701, 2)
		if htord &"" = "" then htord = 0
		select case num2018030701&""
		case "1", "2":
		money2 = getHtYhhMoney(htord)
		total_th = getHtThMoney(htord)
		case "3", "4":
		money2 = getHtDzMoney(htord)
		total_th = getHtSTMoney(htord)
		end select
		if money2&"" = "" then money2 = 0 else money2 = cdbl(money2)
		if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
		if money2<>0 and (money2-total_th)<>0 then
'if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
			mlRate=getHtMlMoneyX(htord, ftype)*100/(CDbl(money2)-CDbl(total_th))
'if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
		end if
		if mlRate&"" = "" then mlRate = 0
		getHtMlRateX = mlRate
	end function
	function getHtMlRate2(ByVal htord, ByVal mlMoney)
		dim money2, mlRate, total_th,  num2018030701
		mlRate = 0 : total_th = 0
		if htord &"" = "" then htord = 0
		if mlMoney &"" = "" then mlMoney = 0 else mlMoney = cdbl(mlMoney)
		num2018030701 = GetSetopenValue(2018030701, 2)
'if htord &"" = "" then htord = 0
		select case num2018030701&""
		case "1", "2":
		money2 = getHtYhhMoney(htord)
		total_th = getHtThMoney(htord)
		case "3", "4":
		money2 = getHtDzMoney(htord)
		total_th = getHtSTMoney(htord)
		end select
		if money2&"" = "" then money2 = 0 else money2 = cdbl(money2)
		if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
		if money2<>0 and (money2-total_th)<>0 then
'if total_th&"" = "" then total_th = 0 else total_th = cdbl(total_th)
			mlRate=mlMoney*100/(CDbl(money2)-CDbl(total_th))
		end if
		if mlRate&"" = "" then mlRate = 0
		getHtMlRate2 = mlRate
	end function
	function getHtMlRate3(ByVal formulaIdx, ByVal mlMoney, ByVal htMoney, ByVal dzMoney, ByVal thMoney, ByVal sthMoney)
		dim money2, mlRate, moneyTotal
		mlRate = 0 : moneyTotal = 0
		if formulaIdx &"" = "" then formulaIdx = 0 else formulaIdx = cdbl(formulaIdx)
		if formulaIdx>0 then
			if mlMoney &"" = "" then mlMoney = 0 else mlMoney = cdbl(mlMoney)
			if htMoney &"" = "" then htMoney = 0 else htMoney = cdbl(htMoney)
			if dzMoney &"" = "" then dzMoney = 0 else dzMoney = cdbl(dzMoney)
			if thMoney &"" = "" then thMoney = 0 else thMoney = cdbl(thMoney)
			if sthMoney &"" = "" then sthMoney = 0 else sthMoney = cdbl(sthMoney)
			select case formulaIdx
			case 1, 2 : moneyTotal = htMoney
			case 3, 4 :
			moneyTotal = dzMoney : thMoney = sthMoney
			end select
			if moneyTotal<>0 And (moneyTotal-thMoney)<>0 then
'end select
				mlRate=mlMoney*100/(moneyTotal-thMoney)
'end select
			else
				mlRate=0
			end if
		end if
		getHtMlRate3 = mlRate
	end function
	function getHtMlMoneySql(ByVal formulaIdx, ByVal htMoneyField, ByVal dzMoneyField, ByVal taxValueField, ByVal thTaxValueField, ByVal proCbField, ByVal fyMoneyField, ByVal thMoneyField, ByVal sthMoneyField, ByVal thCostField)
		dim headerSql
		headerSql = ""
		if formulaIdx>0 then
			select case formulaIdx&""
			case "1"
			headerSql = htMoneyField &" - "& taxValueField &" + "& thTaxValueField &" - "& proCbField &" - "& fyMoneyField &" - "& thMoneyField &" + "& thCostField
'case "1"
			case "2"
			headerSql = htMoneyField &" - "& proCbField &" - "& fyMoneyField &" - "& thMoneyField &" + "& thCostField
'case "2"
			case "3"
			headerSql = dzMoneyField &" - "& taxValueField &" + "& thTaxValueField &" - "& proCbField &" - "& fyMoneyField &" - "& sthMoneyField &" + "& thCostField
'case "3"
			case "4"
			headerSql = dzMoneyField &" - "& proCbField &" - "& fyMoneyField &" - "& sthMoneyField &" + "& thCostField
'case "4"
			end select
		else
			headerSql = "0"
		end if
		getHtMlMoneySql = "("& headerSql &")"
	end function
	function getHtMlRateSql(ByVal formulaIdx, ByVal mlMoneyField, ByVal htMoneyField, ByVal dzMoneyField, ByVal thMoneyField, ByVal sthMoneyField)
		dim headerSql, moneyTotalField
		headerSql = "" : moneyTotalField = ""
		if formulaIdx &"" = "" then formulaIdx = 0 else formulaIdx = cdbl(formulaIdx)
		if formulaIdx>0 then
			select case formulaIdx
			case 1, 2 : moneyTotalField = htMoneyField
			case 3, 4 :
			moneyTotalField = dzMoneyField : thMoneyField = sthMoneyField
			end select
			headerSql = "(CASE WHEN ( ("& moneyTotalField &"-"& thMoneyField &")<>0) THEN (cast("& mlMoneyField &" *100 as decimal(25,12))/("& moneyTotalField &"-"& thMoneyField &")) ELSE 0 END)"
'end select
		else
			headerSql = "0"
		end if
		getHtMlRateSql = headerSql
	end function
	function mlMoneySql(tjtabName, formulaIdx)
		dim sql
		sql = ""
		select case tjtabName
		case "product_gather"
		sql = getHtMlMoneySql(formulaIdx, "出库总额_DONUM_DOSUM", "到账金额_DONUM_DOSUM", "税额_DONUM_DOSUM", "退货税额_DONUM_ID", "出库成本_DONUM_DOSUM","0","退货总额_DONUM_DOSUM", "实退货金额_DONUM_ID", "退货成本_DONUM_DOSUM")
		case "product_ProfitsList"
		sql = getHtMlMoneySql(formulaIdx, "销售总额_DONUM_DOSUM", "到账金额_DONUM_DOSUM", "税额_DONUM_DOSUM", "退货税额_DONUM_ID", "成本总价_DONUM_DOSUM","0","退货总额_DONUM_DOSUM", "实退货金额_DONUM_ID", "退货成本_DONUM_DOSUM")
		case "kh_jx7"
		sql = getHtMlMoneySql(formulaIdx, "contractTotal", "htDzMoney", "taxTotal", "thTaxTotal", "productCost","payTotal","thTotal", "sthTotal", "thCost")
		end select
		mlMoneySql = sql
	end function
	function mlRateMoneySql(tjtabName, formulaIdx)
		dim sql
		sql = ""
		select case tjtabName
		case "product_gather"
		sql = getHtMlRateSql(formulaIdx, mlMoneySql(tjtabName, formulaIdx),"出库总额_DONUM_DOSUM", "到账金额_DONUM_DOSUM", "退货总额_DONUM_DOSUM", "实退货金额_DONUM_ID")
		case "product_ProfitsList"
		sql = getHtMlRateSql(formulaIdx, mlMoneySql(tjtabName, formulaIdx),"销售总额_DONUM_DOSUM", "到账金额_DONUM_DOSUM", "退货总额_DONUM_DOSUM", "实退货金额_DONUM_ID")
		end select
		mlRateMoneySql = sql
	end function
	function htdzMoneySql(tjtabName, str_Result)
		dim sql
		sql = ""
		select case tjtabName
		case "product_gather", "product_ProfitsList"
		sql = ",ISNULL((case "& showSkMoney &" when 1  then ( " & vbcrlf &_
		"""      select isnull(sum( (case when c.paybackMode=2 then pl.money1*dbo.gethl(c.bz,isnull(p.date5,c.date3),getdate())   when c.paybackMode=0 or (c.paybackMode=1 and htl.id<>maxdetial.id) then 0  else p.money1*dbo.gethl(c.bz,isnull(p.date5,c.date3),getdate()) end )),0) as money1 from payback p inner join contract c on p.contract=c.ord and p.del=1 and p.complete='3' inner join contractlist htl on  htl.contract=c.ord and htl.del=1 and htl.ord=a.ord and htl.unit=b.ord  INNER JOIN kuoutlist2 ki WITH(NOLOCK) ON ki.contractlist=htl.id and ki.sort1=1 and ki.del=1 and ki.ord=htl.ord "& iif(tjtabName = "product_ProfitsList","and ki.id = d.id","" )&" inner join kuout on ki.kuout=kuout.ord "& replace(replace(str_Result,"d.","ki."),"ki.sort1","kuout.sort1") &" inner join (select max(id) id,contract from contractlist where del=1 group by contract) maxdetial on maxdetial.contract = c.ord  left join paybacklist pl on pl.payback=p.ord and  pl.contractlist=htl.id  and pl.product=htl.ord  and pl.product=a.ord " & vbcrlf &_
		") else 0 end),0) AS 到账金额_DONUM_DOSUM"
		case "salesProfit_1"
		sql = ",htDzMoney=ISNULL((case "& showSkMoney &" when 1  then ( " & vbcrlf &_
		"  select isnull(sum(p.money1*dbo.gethl(e.bz,isnull(p.date5,e.date3),getdate())),0) as money1 from payback p inner join contract e on p.contract=e.ord and e.cateid=a.ord and p.del=1 and p.complete='3' "& str_Result &" " & vbcrlf &_
		") else 0 end),0) "
		case "kh_jx7"
		sql = "    left join ("&_
		"          select p.contract,isnull((case "& showSkMoney &" when 1  then (sum(p.money1*dbo.gethl(c.bz,isnull(p.date5,c.date3),getdate()))) else 0 end),0) as payMoney from payback p inner join contract c on p.contract=c.ord and p.del=1 and p.complete='3' group by p.contract " & vbcrlf &_
		"  ) c on c.contract=y.ord "
		end select
		htdzMoneySql = sql
	end function
	function taxValueSql(tjtabName, str_Result)
		dim sql
		sql = ""
		select case tjtabName
		case "product_gather", "product_ProfitsList"
		sql = ",ISNULL((case "& showHtMoney &" when 1  then ( " & vbcrlf &_
		"                            ""      select ISNULL(SUM(htl.price1*ki.num1*(htl.taxRate*0.01) * isnull(h.hl,1)),0) from contractlist htl INNER JOIN contract ht ON ht.del=1 AND htl.del=1 AND htl.contract=ht.ord AND htl.ord=a.ord and htl.unit=b.ord INNER JOIN kuoutlist2 ki on ki.contractlist=htl.id and ki.sort1=1 and ki.del=1 and ki.ord=htl.ord "& iif(tjtabName = "product_ProfitsList","and ki.id = d.id","" )&" inner join kuout on ki.kuout=kuout.ord "& str_Result &"  left JOIN hl h WITH(NOLOCK) ON ht.bz = h.bz and ht.date3 = h.date1 " & vbcrlf &_
		") else 0 end),0) AS 税额_DONUM_DOSUM "
		case "salesProfit_1"
		sql = ",taxTotal=isnull((case "& showHtMoney &" when 1  then ( " & vbcrlf &_
		"  select ISNULL(SUM(htl.taxValue * isnull(h.hl,1)),0) from contractlist htl INNER JOIN contract e ON e.del=1 and htl.contract=e.ord AND htl.del=1 AND e.cateid=a.ord left JOIN hl h WITH(NOLOCK) ON e.bz = h.bz and e.date3 = h.date1 where 1=1 "& str_Result &" group by e.cateid" & vbcrlf &_
		") else 0 end),0) "
		case "salesProfit_2"
		sql = ",taxTotal=isnull((case "& showHtMoney &" when 1  then (" & vbcrlf &_
		"select sum(htl.taxValue * isnull(h.hl,1)) taxValue from contractlist htl INNER JOIN contract e ON e.del=1 and htl.contract=e.ord left JOIN hl h WITH(NOLOCK) ON e.bz = h.bz and e.date3 = h.date1 where htl.del=1 and htl.contract=a.ord " & vbcrlf &_
		") else 0 end),0) "
		case "kh_jx7"
		sql = "select htl.contract,sum(htl.taxValue * isnull(h.hl,1)) taxValue from contractlist htl inner join contract y on y.del=1 and htl.del=1 and htl.contract=y.ord left JOIN hl h WITH(NOLOCK) ON y.bz = h.bz and y.date3 = h.date1 " & str_Result &" group by htl.contract "
		end select
		taxValueSql = sql
	end function
	function thTaxValueSql(tjtabName, str_Result)
		dim sql
		sql = ""
		select case tjtabName
		case "product_gather", "product_ProfitsList"
		sql = ",ISNULL((case "& showThMoney &" when 1  then ( " & vbcrlf &_
		"  select ISNULL(SUM(thl.num1 * (CASE ISNULL(ctl.num1,0) WHEN 0 THEN 0 ELSE ctl.taxValue/ctl.num1 END)) ,0)  " & vbcrlf &_
		"  FROM contractth th   " & vbcrlf &_
		"  INNER JOIN contractthlist thl ON thl.caigou=th.ord AND th.del=1 and thl.del=1  " & vbcrlf &_
		"   INNER JOIN CONTRACT ht ON ht.ord = thl.contract " & vbcrlf &_
		"  INNER JOIN contractlist ctl ON thl.contractlist=ctl.id AND thl.contract=ctl.contract "  & vbcrlf &_
		"  INNER JOIN kuoutlist2 ki on ki.contractlist=ctl.id and ki.sort1=1 and ki.del=1 and ki.ord=ctl.ord "& iif(tjtabName = "product_ProfitsList","and ki.id = d.id","" )&" inner join kuout on ki.kuout=kuout.ord "& str_Result &"  " & vbcrlf &_
		"  WHERE thl.ord=a.ord and thl.unit=b.ord " & vbcrlf &_
		") else 0 end),0) AS 退货税额_DONUM_ID "
		case "salesProfit_1"
		sql = ",thTaxTotal=isnull((case "& showThMoney &" when 1  then ( " & vbcrlf &_
		"  select ISNULL(SUM(thl.num1 * (CASE ISNULL(ctl.num1,0) WHEN 0 THEN 0 ELSE ctl.taxValue/ctl.num1 END)) ,0)  " & vbcrlf &_
		"  FROM contractth th   " & vbcrlf &_
		"  INNER JOIN contractthlist thl ON thl.caigou=th.ord AND th.del=1 and thl.del=1  " & vbcrlf &_
		"  INNER JOIN contractlist ctl ON thl.contractlist=ctl.id AND thl.contract=ctl.contract " & vbcrlf &_
		"  INNER JOIN contract e ON ctl.contract=e.ord "& str_Result &" " & vbcrlf &_
		"  WHERE e.cateid=a.ord " & vbcrlf &_
		") else 0 end),0)"
		case "salesProfit_2"
		sql = ",thTaxTotal=isnull((case "& showThMoney &" when 1  then (" & vbcrlf &_
		"select SUM(thl.num1 * (CASE ISNULL(ctl.num1,0) WHEN 0 THEN 0 ELSE ctl.taxValue/ctl.num1 END)) taxValue "& vbcrlf &_
		"FROM contractth th  "& vbcrlf &_
		"INNER JOIN contractthlist thl ON thl.caigou=th.ord AND th.del=1 and thl.del=1 and thl.contract=a.ord "& vbcrlf &_
		"INNER JOIN contractlist ctl ON thl.contractlist=ctl.id AND thl.contract=ctl.contract "& vbcrlf &_
		"GROUP by thl.contract " & vbcrlf &_
		") else 0 end),0) "
		end select
		thTaxValueSql = sql
	end function
	function thMoneySql(tjtabName, str_Result)
		dim sql
		sql = ""
		if str_Result&"" = "" then str_Result = ""
		select case tjtabName
		case "salesProfit_1"
		sql = ",thTotal=ISNULL((case "& showThMoney &" when 1  then (select SUM(thl.money1*dbo.gethl(thl.bz,thl.date1,getdate())) from contractth th INNER JOIN contractthlist thl ON thl.caigou=th.ord AND th.del=1 and thl.del=1 inner join contract e on thl.contract=e.ord and e.del=1 and e.cateid=a.ord "& str_Result &") else 0 end),0) "
		case "kh_jx7"
		sql = "ISNULL((case "& showThMoney &" when 1  then (select isnull(sum(money2),0) as money2 from contractth where company=x.ord and del=1 "&str_Result&") else 0 end),0)"
		end select
		thMoneySql = sql
	end function
	function sthMoneySql(tjtabName, str_Result)
		dim sql
		sql = ""
		select case tjtabName
		case "product_gather", "product_ProfitsList"
		sql = ",ISNULL((case "& showThMoney &" when 1  then ( " & vbcrlf &_
		"  ISNULL((select SUM(thl.money1*dbo.gethl(thl.bz,thl.date1,getdate())) from contractth th INNER JOIN contractthlist thl ON thl.caigou=th.ord AND th.del=1 and thl.del=1 and thl.ord=a.ord and thl.unit=b.ord " & vbcrlf &_
		"  INNER JOIN kuoutlist2 ki on ki.contractlist=thl.contractlist and ki.sort1=1 and ki.del=1 and ki.ord=thl.ord inner join kuout on ki.kuout=kuout.ord "& str_Result &" ),0) -  " & vbcrlf &_
		"  ISNULL((select isnull(sum(thd.money2*dbo.gethl(th.bz,th.date3,getdate())),0) from contractthListDetail thd  " & vbcrlf &_
		"  inner join contractth th on thd.contractth = th.ord and th.del=1 and th.sp=0  " & vbcrlf &_
		"  and thd.thtype='GOODS' and thd.ord=a.ord and thd.unit=b.ord " & vbcrlf &_
		"  INNER JOIN kuoutlist2 ki on ki.contractlist=thd.contractlist and ki.sort1=1 and ki.del=1 and ki.ord=thd.ord inner join kuout on ki.kuout=kuout.ord "& str_Result &"  " & vbcrlf &_
		"),0) ) else 0 end),0) AS 实退货金额_DONUM_ID  "
		case "salesProfit_1"
		sql = ",sthTotal=ISNULL((case "& showThMoney &" when 1  then ( " & vbcrlf &_
		"  ISNULL((select SUM(thl.money1*dbo.gethl(thl.bz,thl.date1,getdate())) from contractth th INNER JOIN contractthlist thl ON thl.caigou=th.ord AND th.del=1 and thl.del=1 inner join contract e on thl.contract=e.ord and e.del=1 and e.cateid=a.ord "& str_Result &"),0) -  " & vbcrlf &_
		"sql = "",sthTotal=ISNULL((case ""& showThMoney &"" when 1  then ( """ & vbcrlf &_
		"ISNULL((select isnull(sum(thd.money2*dbo.gethl(th.bz,th.date3,getdate())),0) from contractthListDetail thd "  & vbcrlf &_
		"  inner join contractth th on thd.contractth = th.ord and th.del=1 and isnull(th.sp,0)=0 " & vbcrlf &_
		"  inner join contract e on thd.contract=e.ord and e.del=1 and e.cateid=a.ord "& str_Result &" " & vbcrlf &_
		"  and thd.thtype='GOODS'),0) ) else 0 end),0)  "
		case "kh_jx7"
		sql = "ISNULL((case "& showThMoney &" when 1  then (sum(isnull(thmoney1,0)-isnull(thmoney2,0))) else 0 end),0)"
'case "kh_jx7"
		end select
		sthMoneySql = sql
	end function
	function tdTaxValueHtml(tjtabName, outExcel, formulaIdx, taxValue, thTaxValue)
		dim ret
		ret = ""
		if formulaIdx&"" = "" then formulaIdx = 2
		if taxValue&"" = "" then taxValue = 0 else taxValue = cdbl(taxValue)
		if thTaxValue&"" = "" then thTaxValue = 0 else thTaxValue = cdbl(thTaxValue)
		select case formulaIdx
		case 1, 3
		if outExcel = 0 then
			ret = "<div title=""合同税额："& Formatnumber(taxValue,num_dot_xs,-1) &"&#13;退货税额："& Formatnumber(thTaxValue,num_dot_xs,-1) &""">"& Formatnumber((taxValue - thTaxValue),num_dot_xs,-1) &"</div>"
'if outExcel = 0 then
		else
			ret = Formatnumber((taxValue - thTaxValue),num_dot_xs,-1)
'if outExcel = 0 then
		end if
		case 2, 4
		if outExcel = 0 then
			ret = "<div >"& Formatnumber(taxValue,num_dot_xs,-1) &"</div>"
'if outExcel = 0 then
		else
			ret = Formatnumber(taxValue,num_dot_xs,-1)
'if outExcel = 0 then
		end if
		end select
		tdTaxValueHtml = ret
	end function
	function tdThMoneyHtml(tjtabName, outExcel, formulaIdx, thMoney, sthMoney)
		dim ret
		ret = ""
		if formulaIdx&"" = "" then formulaIdx = 2
		if thMoney&"" = "" then thMoney = 0 else thMoney = cdbl(thMoney)
		if sthMoney&"" = "" then sthMoney = 0 else sthMoney = cdbl(sthMoney)
		select case formulaIdx
		case 1, 2
		if outExcel = 0 then
			ret = "<div>"& Formatnumber(thMoney,num_dot_xs,-1) &"</div>"
'if outExcel = 0 then
		else
			ret = Formatnumber(thMoney,num_dot_xs,-1)
'if outExcel = 0 then
		end if
		case 3, 4
		if outExcel = 0 then
			ret = "<div title=""退货总额："& Formatnumber(thMoney,num_dot_xs,-1) &"&#13;未退款退货总额："& Formatnumber((thMoney-sthMoney),num_dot_xs,-1) &""">"& Formatnumber(sthMoney,num_dot_xs,-1) &"</div>"
'if outExcel = 0 then
		else
			ret = Formatnumber(sthMoney,num_dot_xs,-1)
'if outExcel = 0 then
		end if
		end select
		tdThMoneyHtml = ret
	end function
	Function SubBillCount(htord)
		dim rs, sql, ret
		ret = 0
		sql = "SELECT ISNULL(SUM(t.num1),0) num1 FROM ( "&_
		"  SELECT TOP 1 1 num1 FROM kuout WITH(NOLOCK) WHERE del=1 AND sort1 IN(1,4) AND order1="& htord &" "&_
		"  UNION ALL  "&_
		"  SELECT TOP 1 1 num1 FROM kuoutlist kl WITH(NOLOCK) inner join kuout k WITH(NOLOCK) on k.ord = kl.kuout WHERE k.del=1 AND k.sort1 IN(1,4) AND kl.Fromid="& htord &" "&_
		"  UNION ALL  "&_
		"  SELECT TOP 1 1 num1 FROM send a WITH(NOLOCK) LEFT JOIN kuout b WITH(NOLOCK) ON b.ord=a.kuout WHERE a.del=1 AND ISNULL(b.sort1,0) IN(0,1,4) AND a.order1="& htord &" "&_
		"  UNION ALL  "&_
		"  SELECT TOP 1 1 num1 FROM payback WITH(NOLOCK) WHERE del=1 AND contract="& htord &" "&_
		"  UNION ALL  "&_
		"  SELECT TOP 1 1 num1 FROM paybackInvoice WITH(NOLOCK) WHERE del=1 AND fromType='CONTRACT' AND fromid="& htord &" "&_
		") t"
		ret = conn.execute(sql)(0)
		SubBillCount = ret
	end function
	Function SubBillCount2(htord, con)
		dim rs, sql, ret
		ret = 0
		sql = "SELECT ISNULL(SUM(t.num1),0) num1 FROM ( "&_
		"  SELECT TOP 1 1 num1 FROM kuout WITH(NOLOCK) WHERE del=1 AND sort1 IN(1,4) AND order1="& htord &" "&_
		"  UNION ALL  "&_
		"  SELECT TOP 1 1 num1 FROM payback WITH(NOLOCK) WHERE del=1 AND contract="& htord &" "&_
		"  UNION ALL  "&_
		"  SELECT TOP 1 1 num1 FROM paybackInvoice WITH(NOLOCK) WHERE del=1 AND fromType='CONTRACT' AND fromid="& htord &" "&_
		"  UNION ALL "&_
		"  SELECT TOP 1 1 num1 FROM contractth a WITH(NOLOCK) "&_
		"  INNER JOIN contractthlist b WITH(NOLOCK) ON b.caigou=a.ord AND a.del IN(1,3) AND ISNULL(a.sp,0)<>-1 AND b.del=1 AND b.contract="& htord &" "&_
		"  UNION ALL "&_
		"  SELECT TOP 1 1 num1 FROM payout2 a WITH(NOLOCK)  "&_
		"  INNER join contractth b WITH(NOLOCK) on a.contractth=b.ord  "&_
		"  inner join ( "&_
		"          SELECT contractth,contract  "&_
		"          FROM contractthlistDetail WITH(NOLOCK) where contract>0 and (thtype='MONEY' or thtype='GOODS_MONEY')  "&_
		"          GROUP by contractth,contract "&_
		"  ) k ON K.contractth = b.ord  "&_
		"  where a.del=1 and k.contract="& htord &" "&_
		"  UNION ALL "&_
		"  SELECT TOP 1 1 num1 FROM pay WITH(NOLOCK) WHERE del=1 AND complete in(3,0) AND contract="& htord &" "&_
		") t"
		ret = con.execute(sql)(0)
		SubBillCount2 = ret
	end function
	Function GetContractBz(htord)
		dim rs, ret
		ret = 0
		Set rs = conn.execute("select bz from contract WITH(NOLOCK) where ord="& htord)
		If rs.eof = False Then
			bz = rs("bz")
		end if
		rs.close
		set rs = nothing
		If bz&"" = "" Then bz = 0
		ret = bz
		GetContractBz = ret
	end function
	Function GetHzKpHtInvoiceType(htord)
		dim rs, ret
		ret = 0
		Set rs = conn.execute("select isnull(invoicePlanType,0) invoicePlanType from contract WITH(NOLOCK) where invoiceMode=1 and ord="& htord)
		If rs.eof = False Then
			ret = rs("invoicePlanType")
		end if
		rs.close
		set rs = nothing
		GetHzKpHtInvoiceType = ret
	end function
	function IsOpenContractModifyTactics
		set Modifyrs=server.CreateObject("adodb.recordset")
		sql="select intro from setopen where sort1=2020021801"
		Modifyrs.open sql,conn,1,1
		if Modifyrs.eof then
			num2020021801=0
		else
			num2020021801=Modifyrs("intro")
		end if
		Modifyrs.close
		set Modifyrs=Nothing
		IsOpenContractModifyTactics = (num2020021801="1")
	end function
	Function CheckBillCanDelete(chkType, htords, htcateids)
		dim rs, rs2, sql, ret, nowCate, open_7_3, intro_7_3, open_32_3, intro_32_3, open_33_3, intro_33_3, isGoOn, cateids, canDelOrds
		ret = "ALL" : canDelOrds = ""
		nowCate = session("personzbintel2007")
		If nowCate&"" = "" Then nowCate = 0
		If htords&"" = "" Then htords = 0
		if htcateids&"" = "" then
			Set rs = conn.execute("select distinct cateid from contract where ord in("& htords &")")
			While rs.eof = False
				if htcateids&""<>"" then htcateids = htcateids &","
				htcateids = htcateids & rs("cateid")
				rs.movenext
			wend
			rs.close
			set rs = nothing
		end if
		If htcateids&"" = "" Then htcateids = 0
		cateids = ""
		Select Case chkType
		Case "payback"
		sql = "select top 1 1 from payback where del=1 and complete<3 and contract in("& htords &") "
		isGoOn = (conn.execute(sql).eof=false)
		if isGoOn then
			set rs = conn.execute("select qx_open,qx_intro from power WITH(NOLOCK) where ord="&nowCate&" and sort1=7 and sort2=3")
			if rs.eof = false then
				open_7_3=rs("qx_open") : intro_7_3=rs("qx_intro")
			end if
			rs.close
			set rs=nothing
			If open_7_3&"" = "" Then open_7_3 = 0
			If intro_7_3&"" = "" Then intro_7_3 = "-222" Else intro_7_3 = replace(intro_7_3&""," ","")
			If open_7_3&"" = "" Then open_7_3 = 0
			if open_7_3=3 then
				isGoOn = True
			elseif open_7_3=1 then
				isGoOn = False
				Set rs = conn.execute("SELECT ISNULL(STUFF((SELECT ','+CAST(a.cateid AS VARCHAR(10)) FROM (SELECT id,CAST(short_str AS INT) cateid FROM dbo.split('"& intro_7_3 &"',',')) a INNER JOIN (SELECT id,CAST(short_str AS INT) cateid FROM dbo.split('"& htcateids &"',',')) b ON a.cateid=b.cateid AND a.cateid>0 for xml path('')),1,1,''),'') ")
				If rs.eof = False Then
					if rs(0)&""<>"" then
						cateids = rs(0)&""
						isGoOn = True
					end if
				end if
				rs.close
				set rs = nothing
			else
				isGoOn = False
			end if
			if isGoOn and conn.execute("select 1 from home_usConfig where name='Payback_Invoice_Voucher_Constraint' and nvalue=1").eof=false then
				if  conn.execute("select 1 from payback pb inner join dbo.collocation c on c.del=1 and c.sort1 = 6 AND c.clstype = 6009 AND pb.ord = c.erpOrd  where pb.contract in ("& htords &") and pb.del=1 and pb.complete <3 ").eof=false then
					isGoOn = False
				end if
			end if
			if isGoOn then
				isGoOn = False
				If cateids&"" = "" Then cateids = "0"
				sql = "SELECT ISNULL(STUFF((select ','+cast(ord as varchar(15)) from payback where del=1 and complete<3 and contract in("& htords &") and ('"& cateids &"'='0' or cateid in("& cateids &")) for xml path('')),1,1,''),'') "
'If cateids&"" = "" Then cateids = "0"
				set rs = conn.execute(sql)
				If rs.eof = False Then
					if rs(0)&""<>"" then
						canDelOrds = rs(0)&""
						isGoOn = True
					end if
				end if
				rs.close
				set rs = nothing
			end if
		end if
		if isGoOn then
			ret = canDelOrds
		else
			ret = "False"
		end if
		case "paybackInvoice"
		sql = "select top 1 1 from paybackinvoice where del=1 and isinvoiced=0 and fromType='CONTRACT' and fromid in ("& htords &") "
		isGoOn = (conn.execute(sql).eof=false)
		if isGoOn then
			set rs = conn.execute("select qx_open,qx_intro from power WITH(NOLOCK) where ord="&nowCate&" and sort1=7001 and sort2=3")
			if rs.eof = false then
				open_7001_3=rs("qx_open") : intro_7001_3=rs("qx_intro")
			end if
			rs.close
			set rs=nothing
			If open_7001_3&"" = "" Then open_7001_3 = 0
			If intro_7001_3&"" = "" Then intro_7001_3 = "-222" Else intro_7001_3 = replace(intro_7001_3&""," ","")
'If open_7001_3&"" = "" Then open_7001_3 = 0
			if open_7001_3=3 then
				isGoOn = True
			elseif open_7001_3=1 then
				isGoOn = False
				Set rs = conn.execute("SELECT ISNULL(STUFF((SELECT ','+CAST(a.cateid AS VARCHAR(10)) FROM (SELECT id,CAST(short_str AS INT) cateid FROM dbo.split('"& intro_7001_3 &"',',')) a INNER JOIN (SELECT id,CAST(short_str AS INT) cateid FROM dbo.split('"& htcateids &"',',')) b ON a.cateid=b.cateid AND a.cateid>0 for xml path('')),1,1,''),'') ")
				If rs.eof = False Then
					if rs(0)&""<>"" then
						cateids = rs(0)&""
						isGoOn = True
					end if
				end if
				rs.close
				set rs = nothing
			else
				isGoOn = False
			end if
			if isGoOn then
				isGoOn = False
				If cateids&"" = "" Then cateids = "0"
				sql = "SELECT ISNULL(STUFF((select ','+cast(id as varchar(15)) from paybackinvoice where del=1 and isinvoiced=0 and fromType='CONTRACT' and fromid in("& htords &") and ('"& cateids &"'='0' or cateid in("& cateids &")) for xml path('')),1,1,''),'') "
'If cateids&"" = "" Then cateids = "0"
				set rs = conn.execute(sql)
				If rs.eof = False Then
					if rs(0)&""<>"" then
						canDelOrds = rs(0)&""
						isGoOn = True
					end if
				end if
				rs.close
				set rs = nothing
			end if
		end if
		if isGoOn then
			ret = canDelOrds
		else
			ret = "False"
		end if
		Case "kuout"
		isGoOn = True
		If sdk.getSqlValue("select count(1) from kuout where del=1 and complete1<3 and sort1 in(1,4) and order1 in("& htords &")" , 0)&"" = "0" Then
			isGoOn = False
		end if
		if isGoOn then
			set rs = conn.execute("select qx_open,qx_intro from power WITH(NOLOCK) where ord="&nowCate&" and sort1=32 and sort2=3")
			if rs.eof = false then
				open_32_3=rs("qx_open") : intro_32_3=rs("qx_intro")
			end if
			rs.close
			set rs=nothing
			If open_32_3&"" = "" Then open_32_3 = 0
			If intro_32_3&"" = "" Then intro_32_3 = "-222" Else intro_32_3 = replace(intro_32_3&""," ","")
'If open_32_3&"" = "" Then open_32_3 = 0
			If open_32_3 = 3 Then
				isGoOn = True
			ElseIf open_32_3 = 1 Then
				isGoOn = True
			else
				isGoOn = False
			end if
			if isGoOn then
				isGoOn = False
				Set rs = conn.execute("SELECT ISNULL(STUFF((SELECT ','+cast(ord as varchar(15)) from kuout where del=1 and complete1<3 and sort1 in(1,4) and order1 in("& htords &") and ("& open_32_3 &"=3 or ("& open_32_3 &"=1 and charindex(','+cast(cateid as varchar(10))+',',',"& intro_32_3 &",')>0)) for xml path('')),1,1,''),'')")
				If rs.eof = False Then
					if rs(0)&""<>"" then
						canDelOrds = rs(0)&""
						isGoOn = True
					end if
				end if
				rs.close
				set rs = nothing
				Set rs = conn.execute("select top 1 1 from kuout where del=1 and sort1 in(1,4) and order1 in("& htords &") and ord not in(SELECT distinct a.kuout FROM kuoutlist2 a WITH(NOLOCK) INNER JOIN contractthlist b WITH(NOLOCK) ON b.kuoutlist2=a.id AND b.del=1 INNER JOIN contractth c WITH(NOLOCK) ON c.ord=b.caigou AND c.del IN(1,3) AND ISNULL(c.sp,0)<>-1INNER JOIN kuout d WITH(NOLOCK) on a.kuout=d.ord AND d.del=1 AND d.sort1 in(1,4) and d.order1 in("& htords &"))")
				isGoOn = True
			end if
		end if
		if isGoOn then
			ret = canDelOrds
		else
			ret = "False"
		end if
		Case "send"
		isGoOn = True
		If sdk.getSqlValue("select count(1) from sendlist s inner join kuout k on k.ord=s.kuout and s.del=1 and s.complete1=0 and k.sort1 in(1,4) and k.order1 in("& htords &")" , 0)&"" = "0" Then
			isGoOn = False
		end if
		if isGoOn then
			set rs = conn.execute("select qx_open,qx_intro from power WITH(NOLOCK) where ord="&nowCate&" and sort1=33 and sort2=3")
			if rs.eof = false then
				open_33_3=rs("qx_open") : intro_33_3=rs("qx_intro")
			end if
			rs.close
			set rs=nothing
			If open_33_3&"" = "" Then open_33_3 = 0
			If intro_33_3&"" = "" Then intro_33_3 = "-222" Else intro_33_3 = replace(intro_33_3&""," ","")
'If open_33_3&"" = "" Then open_33_3 = 0
			If open_33_3 = 3 Then
				isGoOn = True
			ElseIf open_33_3 = 1 Then
				isGoOn = True
'Set rs = conn.execute("SELECT top 1 1 FROM (SELECT id,CAST(short_str AS INT) cateid FROM dbo.split('"& intro_33_3 &"',',')) a INNER JOIN (select distinct s.cateid from send s inner join kuout k on k.ord=s.kuout and s.del=1 and k.sort1 in(1,4) and k.order1 in("& htords &")) b on a.cateid=b.cateid AND a.cateid>0")
			else
				isGoOn = False
			end if
		end if
		If isGoOn Then
			isGoOn = False
			Set rs = conn.execute("SELECT ISNULL(STUFF((SELECT ','+cast(s.ord as varchar(15)) from send s inner join sendlist st on st.send=s.ord inner join kuout k on k.ord=st.kuout and s.del=1 and s.complete1=0 and k.sort1 in(1,4) and k.order1 in("& htords &") and ("& open_33_3 &"=3 or ("& open_33_3 &"=1 and charindex(','+cast(s.cateid as varchar(10))+',',',"& intro_33_3 &",')>0)) group by s.ord for xml path('')),1,1,''),'')")
			isGoOn = False
			If rs.eof = False Then
				if rs(0)&""<>"" then
					canDelOrds = rs(0)&""
					isGoOn = True
				end if
			end if
			rs.close
			set rs = nothing
		end if
		if isGoOn then
			ret = canDelOrds
		else
			ret = "False"
		end if
		End Select
		if ret&"" = "" then ret = "False"
		CheckBillCanDelete = ret
	end function
	function IsCanDeleteCheckPayback(cn , PaybackID)
		if cn.execute("select 1 from home_usConfig where name='Payback_Invoice_Voucher_Constraint' and nvalue=1").eof=false then
			if cn.execute("select 1 from payback pb inner join dbo.collocation c on c.del=1 and c.sort1 = 6 AND c.clstype = 6009 AND pb.ord = c.erpOrd  where pb.ord="& PaybackID &" and pb.del=1 and pb.complete <3 ").eof=false then
				IsCanDeleteCheckPayback = false
				exit function
			end if
		end if
		IsCanDeleteCheckPayback = true
	end function
	function ExistsLeftMoneyForInvoice(cn,contractID)
		ExistsLeftMoneyForInvoice = (cn.execute("select c.ord,c.company "&_
		"  from contract c  "&_
		"  left join ( "&_
		"      select contract, count(1) as invoiceMxCount ,sum(money1) as money1,sum(num1) as num1  "&_
		"      from contractlist  "&_
		"      where del=1 and isnull(invoicetype,0)>0 and contract = "& contractID &" "&_
		"      group by contract  "&_
		"  ) m on m.contract = c.ord "&_
		"  left join ( "&_
		"      select p.fromid as contract, sum((case when isnull(p.RedJoinId,0)>0 then -1 else 1 end) * p.money1 + isnull(pl.money1,0)) as money1 "&_
		"  left join ( "&_
		"      from paybackinvoice p "&_
		"      left join (select paybackinvoice,sum(money1) as money1 from paybackinvoice_list where contractlist<=0 and del=1 group by paybackinvoice) pl on p.id = pl.paybackinvoice "&_
		"      where p.del=1 and p.isinvoiced<>3 and p.fromtype='CONTRACT' and p.fromId = "& contractID &"  "&_
		"      group by p.fromid  "&_
		"  ) i on i.contract = c.ord "&_
		"  left join ( "&_
		"      select p.fromid as contract, sum((case when isnull(p.RedJoinId,0)>0 then -1 else 1 end) * pl.num1) as num1 "&_
		"  left join ( "&_
		"      from paybackinvoice p "&_
		"      inner join paybackinvoice_list  pl on p.id = pl.paybackinvoice and pl.contractlist>0 "&_
		"      where p.del=1 and p.isinvoiced<>3 and p.fromtype='CONTRACT' and p.fromId = "& contractID &"  "&_
		"      group by p.fromid  "&_
		"  ) j on j.contract = c.ord "&_
		"  left join ( "&_
		"      select isnull(sum(d.money2),0) as thmoney,l.contract "&_
		"      from contractthListDetail d  "&_
		"      inner join contractlist l on l.id=d.contractlist  "&_
		"      inner join contractthlist tl on tl.id=d.contractthlist  "&_
		"      inner join contractth ct on ct.ord=tl.caigou and ct.del=1 and ct.sp=0  "&_
		"      where d.del=1 and (isnull(d.thtype,'') = 'GOODS' or isnull(d.thtype,'') = 'GOODS_MONEY' or isnull(d.thtype,'') = 'MONEY')  "&_
		"      group by l.contract "&_
		"  ) th on th.contract = c.ord "&_
		"  where c.ord="& contractID &"  and c.del=1 and c.isTerminated=0 and isnull(c.importInvoice,0)=0 and c.invoicemode<>0 "&_
		"     and m.money1 - isnull(c.yhmoney,0) - isnull(i.money1,0) - ISNULL(th.thmoney,0)>0 and (c.invoicemode=1 or (c.invoicemode=2 and isnull(m.num1,0)-isnull(j.num1,0)>0) )").eof=false)
	end function

	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body {" & vbcrlf & "      margin-top: 0px;" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & ".IE5 .aaa input.anybutton2{height:18px;line-height:16px;;margin-bottom:-0.5px;}" & vbcrlf & "</style>" & vbcrlf & "<script language=""JavaScript"" type=""text/JavaScript"">" & vbcrlf & "<!--" & vbcrlf & "    function MM_jumpMenu(targ, selObj, restore) { //v3.0" & vbcrlf & "        eval(targ + "".location=\'"" + selObj.options[selObj.selectedIndex].value + ""\'"");" & vbcrlf & "        if (restore)selObj.selectedIndex = 0;" & vbcrlf & "    }" & vbcrlf & "//-->" & vbcrlf & "</script>" & vbcrlf & "</head>" & vbcrlf & "" & vbcrlf & "<body bgcolor=""#ebebeb"">" & vbcrlf & ""
	'Response.write Application("sys.info.jsver")
	Dim arrShow()
	Dim arrName()
	Set rs=conn.execute("select (case when isnull(name,'')='' then oldname else name end ) as name, (case when show>0 then 1 else 0 end) as show,gate1 from setfields order by gate1 asc ")
	While Not rs.eof
		intgate1=rs("gate1")
		redim Preserve arrShow(intgate1)
		redim Preserve arrName(intgate1)
		arrShow(intgate1)=rs("show")
		arrName(intgate1)=rs("name")
		rs.movenext
	wend
	rs.close
	result=""
	ord=request("ord")
	fromid = request("fromid")
	If Len(fromid)>0 Then fromid = deurl(fromid)
	If Len(fromid) = 0 Then fromid = 0
	title = ""
	Select Case ord
	Case "1" :
	title = "客户"
	action1="客户修改记录查看"
	tablename="tel_his"
	searchid=request("searchid")
	searchkey=request("searchkey")
	if searchkey<>"" Then
		Select Case searchid
		Case "1" : result=result&" and name like '%"&searchkey&"%'"
		Case "2" : result=result&" and khid like '%"&searchkey&"%'"
		Case "3" : result=result&" and person in (select ord from person where name like '%"&searchkey&"%')"
		Case "6" : result=result&" and cateid in (select ord from gate where name like '%"&searchkey&"%')"
		End Select
	end if
	Case "2" :
	title = "联系人"
	action1="联系人修改记录查看"
	tablename="person_his"
	searchid=request("searchid")
	searchkey=request("searchkey")
	if searchkey<>"" Then
		Select Case searchid
		Case "1" : result=result&" and name like '%"&searchkey&"%'"
		Case "2" : result=result&" and pym like '%"&searchkey&"%'"
		Case "3" : result=result&" and phone like '%"&searchkey&"%'"
		End Select
	end if
	Case "3" :
	title = "合同"
	action1="合同修改记录查看"
	tablename="contract_his"
	If fromid<>0 Then result = result  &" and ord ="& fromid
	searchid=request("searchid")
	searchkey=request("searchkey")
	if searchkey<>"" Then
		Select Case searchid
		Case "1" : result=result&" and title like '%"&searchkey&"%'"
		Case "2" : result=result&" and htid like '%"&searchkey&"%'"
		Case "3" : result=result&" and company in (select ord from tel where name like '%"&searchkey&"%')"
		Case "4" : result=result&" and cateid in (select ord from gate where name like '%"&searchkey&"%')"
		Case "5" : result=result&" and addcate in (select ord from gate where name like '%"&searchkey&"%')"
		End Select
	end if
	Case "-8" :
'End Select
	title = "项目"
	action1="项目修改记录查看"
	tablename="chance_his"
	If fromid<>0 Then  result = result  &" and ord ="& fromid
	searchid=request("searchid")
	searchkey=request("searchkey")
	if searchkey<>"" Then
		Select Case searchid
		Case "1" : result=result&" and title like '%"&searchkey&"%'"
		Case "2" : result=result&" and xmid like '%"&searchkey&"%'"
		Case "3" : result=result&" and company in (select ord from tel where name like '%"&searchkey&"%')"
		Case "4" : result=result&" and cateid in (select ord from gate where name like '%"&searchkey&"%')"
		Case "5" : result=result&" and addcate in (select ord from gate where name like '%"&searchkey&"%')"
		End Select
	end if
	Case "22" :
	title = "采购"
	action1 = "采购修改记录查看"
	tablename = "caigou_his"
	If fromid<>0 Then  result = result  &" and ord ="& fromid
	searchid=request("searchid")
	searchkey=request("searchkey")
	if searchkey<>"" Then
		Select Case searchid
		Case "1" : result=result&" and title like '%"&searchkey&"%'"
		Case "2" : result=result&" and addcate in (select ord from gate where name like '%"&searchkey&"%')"
		Case "3" : result=result&" and op in (select ord from gate where name like '%"&searchkey&"%')"
		Case "4" : result=result&" and company in (select ord from tel where name like '%"&searchkey&"%')"
		End Select
	end if
	End Select
	Function GetSelectSearchType(SearchType , currID)
		Dim sst : sst=""
		If SearchType&""=currID&"" Then
			sst = " selected "
		end if
		GetSelectSearchType = sst
	end function
	px=request("px")
	if px="" then px=1
	Select Case px
	Case 1 :
	pxresult=" order by opdate desc"
	Case 2 :
	pxresult=" order by opdate asc"
	Case 3 :
	if ord="3" Or ord="-8" Or ord="22" then
'Case 3 :
		pxresult=" order by title desc"
	elseif ord="2" then
		pxresult=" order by name desc"
	else
		pxresult=" order by name desc"
	end if
	Case 4 :
	if ord="3" Or ord="-8" Or ord="22" then
'Case 4 :
		pxresult=" order by title asc"
	elseif ord="2" then
		pxresult=" order by name asc"
	else
		pxresult=" order by name asc"
	end if
	Case 5 :
	pxresult=" order by ip desc"
	Case 6 :
	pxresult=" order by ip asc"
	End Select
	ret1=request("ret1")
	ret2=request("ret2")
	page_count=request("page_count")
	currpage=Request("currpage")
	if ret1<>"" Then result=result&" and opdate >='"&ret1&"'"
	if ret2<>"" Then result=result&" and opdate <='"&ret2&"'"
	if page_count="" Then page_count=15
	if currpage<="0" or currpage="" Then currpage=1
	currpage=clng(currpage)
	Function huanYanAble(ord, hisid)
		dim rs, ybz, htord, ret
		ret = true
		Select Case ord&""
		Case "3"
		Set rs = conn.execute("select isnull(bz,0) bz,ord from contract_his where id="& hisid)
		If rs.eof = False Then
			ybz = rs("bz") : htord = rs("ord")
			if ybz&""<> GetContractBz(htord)&"" then
				if SubBillCount2(htord, conn)>0 then
					ret = false
				end if
			end if
		end if
		rs.close
		set rs = nothing
		End Select
		huanYanAble = ret
	end function
	Response.write "" & vbcrlf & "<table width=""100%""  border=""0"" align=""left"" cellpadding=""0"" cellspacing=""0"" >" & vbcrlf & "<tr>" & vbcrlf & "    <td width=""100%"" valign=""top"">       " & vbcrlf & "        <form name=""form1"" id=""frm"" style=""margin:0"" action=""table_his.asp?fromid="
	Response.write pwurl(fromid)
	Response.write "&sar=1&ord="
	Response.write ord
	Response.write "&px="
	Response.write px
	Response.write "&page_count="
	Response.write page_count
	Response.write """ method=""post"">" & vbcrlf & "    <table width=""100%""  border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "        <tr>" & vbcrlf & "            <td class=""place"">"
	Response.write title
	Response.write "修改记录查看</td>" & vbcrlf & "            <td><A onclick=""Myopen(User);return false;"" href=""#"" class=""sortRule"">排序规则<IMG src=""../images/i10.gif"" alt=""排序规则"" width=""9"" height=""5"" border=""0""></A></td>" & vbcrlf & "             <td align=""right"" class='aaa'>" & vbcrlf & "                    自：<input name=""ret1"" id=""ret1"" size=""10"" value="""
	Response.write ret1
	Response.write """ onclick=""toggleDatePicker('daysOfMonth1','date.ret1')"" readonly><DIV id=daysOfMonth1 style=""POSITION: absolute""></DIV>&nbsp;" & vbcrlf & "                        至：<input name=""ret2"" id=""ret2"" size=""10"" value="""
	Response.write ret2
	Response.write """ onclick=""toggleDatePicker('daysOfMonth2','date.ret2')"" readonly><DIV id=daysOfMonth2 style=""POSITION: absolute""></DIV>&nbsp;" & vbcrlf & "                        <select name=""searchid"">" & vbcrlf & "                  "
	Select Case ord
	Case "1" :
	Response.write "" & vbcrlf & "                             <option value=""1"" "
	Response.write GetSelectSearchType(searchid , 1)
	Response.write ">"
	Response.write arrName(1)
	Response.write "</option>" & vbcrlf & "                            <option value=""2"" "
	Response.write GetSelectSearchType(searchid , 2)
	Response.write ">"
	Response.write arrName(3)
	Response.write "</option>" & vbcrlf & "                            <option value=""3"" "
	Response.write GetSelectSearchType(searchid , 3)
	Response.write ">主联系人</option>" & vbcrlf & "                           <option value=""6"" "
	Response.write GetSelectSearchType(searchid , 6)
	Response.write ">销售人员</option>" & vbcrlf & "                           "
	Case "3" :
	Response.write "                     " & vbcrlf & "                                <option value=""1"" "
	Response.write GetSelectSearchType(searchid , 1)
	Response.write ">合同标题</option>" & vbcrlf & "                           <option value=""2"" "
	Response.write GetSelectSearchType(searchid , 2)
	Response.write ">合同编号</option>" & vbcrlf & "                           <option value=""3"" "
	Response.write GetSelectSearchType(searchid , 3)
	Response.write ">"
	Response.write arrName(1)
	Response.write "</option>" & vbcrlf & "                            <option value=""4"" "
	Response.write GetSelectSearchType(searchid , 4)
	Response.write ">销售人员</option>" & vbcrlf & "                           <option value=""5"" "
	Response.write GetSelectSearchType(searchid , 5)
	Response.write ">创建人员</option>" & vbcrlf & "                           "
	Case "2" :
	Response.write "" & vbcrlf & "                             <option value=""1"" "
	Response.write GetSelectSearchType(searchid , 1)
	Response.write ">姓&nbsp;&nbsp;名</option>" & vbcrlf & "                           <option value=""2"" "
	Response.write GetSelectSearchType(searchid , 2)
	Response.write ">拼音码</option>" & vbcrlf & "                             <option value=""3"" "
	Response.write GetSelectSearchType(searchid , 3)
	Response.write ">电&nbsp;&nbsp;话</option>" & vbcrlf & "                           "
	Case "-8" :
	Response.write ">电&nbsp;&nbsp;话</option>" & vbcrlf & "                           "
	Response.write "" & vbcrlf & "                             <option value=""1"" "
	Response.write GetSelectSearchType(searchid , 1)
	Response.write ">项目主题</option>" & vbcrlf & "                           <option value=""2"" "
	Response.write GetSelectSearchType(searchid , 2)
	Response.write ">项目编号</option>" & vbcrlf & "                           <option value=""3"" "
	Response.write GetSelectSearchType(searchid , 3)
	Response.write ">"
	Response.write arrName(1)
	Response.write "</option>" & vbcrlf & "                            <option value=""4"" "
	Response.write GetSelectSearchType(searchid , 4)
	Response.write ">主负责人</option>" & vbcrlf & "                           <option value=""5"" "
	Response.write GetSelectSearchType(searchid , 5)
	Response.write ">创建人员</option>" & vbcrlf & "                           "
	Case "22" :
	Response.write "" & vbcrlf & "                             <option value=""1"" "
	Response.write GetSelectSearchType(searchid , 1)
	Response.write ">采购主题</option>" & vbcrlf & "                           <option value=""2"" "
	Response.write GetSelectSearchType(searchid , 2)
	Response.write ">创建人员</option>" & vbcrlf & "                           <option value=""3"" "
	Response.write GetSelectSearchType(searchid , 3)
	Response.write ">修改人员</option>" & vbcrlf & "                           <option value=""4"" "
	Response.write GetSelectSearchType(searchid , 4)
	Response.write ">供应商</option>" & vbcrlf & "                             "
	Case Else
	Response.write "" & vbcrlf & "                             <option value=""1"" "
	Response.write GetSelectSearchType(searchid , 1)
	Response.write ">"
	Response.write arrName(1)
	Response.write "</option>" & vbcrlf & "                            <option value=""2"" "
	Response.write GetSelectSearchType(searchid , 2)
	Response.write ">"
	Response.write arrName(3)
	Response.write "</option>" & vbcrlf & "                            <option value=""3"" "
	Response.write GetSelectSearchType(searchid , 3)
	Response.write ">主联系人</option>" & vbcrlf & "                           <option value=""6"" "
	Response.write GetSelectSearchType(searchid , 6)
	Response.write ">销售人员</option>" & vbcrlf & "                           "
	end Select
	Response.write "" & vbcrlf & "                     </select>" & vbcrlf & "                       <input type=""text"" value="""
	Response.write searchkey
	Response.write """ name=""searchkey"" size=""15"">" & vbcrlf & "                 <input type=""button"" onClick=""document.getElementById('frm').submit()"" name=""btn3"" value=""检索"" class=""anybutton2"">" & vbcrlf & "               </td>" & vbcrlf & "        <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "    </tr>" & vbcrlf & "      </table>" & vbcrlf & "        </form>" & vbcrlf & "<div align=""center"">" & vbcrlf & "  <center>" & vbcrlf & "<form name=""data"" action=""table_his.asp"" method=""post"">" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content""> " & vbcrlf & "<tr  valign=""center"" class=""top"">" & vbcrlf & "  <td width=""6%"" height=""25"" align=""left"" valign=""middle""  class=""name""><div align=""center"">选择</div></td>" & vbcrlf & "   <td width=""17%"" align=""left"" valign=""middle""  class=""name""><div align=""center"">" & vbcrlf & "  "
	Select case ord
	Case "1" : Response.write arrName(1)
	Case "2" : Response.write "姓名"
	Case "3" : Response.write "合同主题"
	Case "-8" : Response.write "项目主题"
	Case "3" : Response.write "合同主题"
	Case "22" : Response.write "采购主题"
	Case else
	Response.write arrName(1)
	end Select
	Response.write "</div>" & vbcrlf & "       </td>" & vbcrlf & "   <td width=""15%"" align=""left"" valign=""middle""  class=""name""><div align=""center""><strong> "
	Select case ord
	Case "1" : Response.write arrName(3)
	Case "2" : Response.write "电话"
	Case "3" : Response.write "合同编号"
	Case "-8" : Response.write "项目编号"
	Case "3" : Response.write "合同编号"
	Case "22" : Response.write "采购编号"
	Case else
	Response.write arrName(3)
	end Select
	Response.write "</strong></div>" & vbcrlf & "      </td>" & vbcrlf & "   <td width=""10%"" align=""left"" valign=""middle""  class=""name""><div align=""center""><strong>修改人</strong></div></td>" & vbcrlf & " <td width=""20%"" align=""left"" valign=""middle""  class=""name""><strong><div align=""center"">编辑登录IP</div></td>" & vbcrlf & "       <td width=""18%"" align=""left"" valign=""middle""  class=""name""><strong><div align=""center"">编辑时间</div></td>" & vbcrlf & "    <td width=""9%"" height=""25"" align=""left"" valign=""middle""  class=""name"">" & vbcrlf & "                <div align=""center"" >" & vbcrlf & "             <select name=""select5"" onChange=""if(this.selectedIndex && this.selectedIndex!=0){window.open(this.value,'_self');}this.selectedIndex=0;"" style=""font-size:12px;font-weight:bold;overflow:hidden"">" & vbcrlf & "          <option>-请选择-</option>" & vbcrlf & "               <option value=""table_his.asp?fromid="
'end Select
	Response.write pwurl(fromid)
	Response.write "&ord="
	Response.write ord
	Response.write "&px="
	Response.write px
	Response.write "&ret1="
	Response.write ret1
	Response.write "&ret2="
	Response.write ret2
	Response.write "&searchkey="
	Response.write searchkey
	Response.write "&searchid="
	Response.write searchid
	Response.write "&page_count=10&CurrPage="
	Response.write CurrPage
	Response.write """ "
	if page_count=10 then
		Response.write "selected"
	end if
	Response.write ">每页显示10条</option>" & vbcrlf & "               <option value=""table_his.asp?fromid="
	Response.write pwurl(fromid)
	Response.write "&ord="
	Response.write ord
	Response.write "&px="
	Response.write px
	Response.write "&ret1="
	Response.write ret1
	Response.write "&ret2="
	Response.write ret2
	Response.write "&searchkey="
	Response.write searchkey
	Response.write "&searchid="
	Response.write searchid
	Response.write "&page_count=20&CurrPage="
	Response.write CurrPage
	Response.write """ "
	if page_count=20 then
		Response.write "selected"
	end if
	Response.write ">每页显示20条</option>" & vbcrlf & "               <option value=""table_his.asp?fromid="
	Response.write pwurl(fromid)
	Response.write "&ord="
	Response.write ord
	Response.write "&px="
	Response.write px
	Response.write "&ret1="
	Response.write ret1
	Response.write "&ret2="
	Response.write ret2
	Response.write "&searchkey="
	Response.write searchkey
	Response.write "&searchid="
	Response.write searchid
	Response.write "&page_count=30&CurrPage="
	Response.write CurrPage
	Response.write """ "
	if page_count=30 then
		Response.write "selected"
	end if
	Response.write ">每页显示30条</option>" & vbcrlf & "               <option value=""table_his.asp?fromid="
	Response.write pwurl(fromid)
	Response.write "&ord="
	Response.write ord
	Response.write "&px="
	Response.write px
	Response.write "&ret1="
	Response.write ret1
	Response.write "&ret2="
	Response.write ret2
	Response.write "&searchkey="
	Response.write searchkey
	Response.write "&searchid="
	Response.write searchid
	Response.write "&page_count=50&CurrPage="
	Response.write CurrPage
	Response.write """ "
	if page_count=50 then
		Response.write "selected"
	end if
	Response.write ">每页显示50条</option>" & vbcrlf & "               <option value=""table_his.asp?fromid="
	Response.write pwurl(fromid)
	Response.write "&ord="
	Response.write ord
	Response.write "&px="
	Response.write px
	Response.write "&ret1="
	Response.write ret1
	Response.write "&ret2="
	Response.write ret2
	Response.write "&searchkey="
	Response.write searchkey
	Response.write "&searchid="
	Response.write searchid
	Response.write "&page_count=100&CurrPage="
	Response.write CurrPage
	Response.write """ "
	if page_count=100 then
		Response.write "selected"
	end if
	Response.write ">每页显示100条</option>" & vbcrlf & "              <option value=""table_his.asp?fromid="
	Response.write pwurl(fromid)
	Response.write "&ord="
	Response.write ord
	Response.write "&px="
	Response.write px
	Response.write "&ret1="
	Response.write ret1
	Response.write "&ret2="
	Response.write ret2
	Response.write "&searchkey="
	Response.write searchkey
	Response.write "&searchid="
	Response.write searchid
	Response.write "&page_count=200&CurrPage="
	Response.write CurrPage
	Response.write """ "
	if page_count=200 then
		Response.write "selected"
	end if
	Response.write ">每页显示200条</option>" & vbcrlf & "              </select>" & vbcrlf & "               </div>" & vbcrlf & "  </td>" & vbcrlf & "</tr>" & vbcrlf & ""
	If ord = "2" Then
		countsql="select count(*) from "&tablename&" LEFT JOIN (SELECT ord,cateid FROM tel) b ON b.ord = person_his.company  where del=1 "&result
	else
		countsql="select count(*) from "&tablename&" where del=1 "&result
	end if
	Set rs = conn.execute(countsql)
	If rs.eof = False Then
		recordcount=rs(0)
	end if
	rs.close
	set rs = nothing
	If recordcount&"" = "" Then recordcount = 0 Else recordcount = CDBL(recordcount)
	pagecount = int(recordcount/ page_count) + Abs(recordcount Mod page_count>0)
'If recordcount&"" = "" Then recordcount = 0 Else recordcount = CDBL(recordcount)
	if currpage>=PageCount then
		currpage=PageCount
	end if
	set rs=server.CreateObject("adodb.recordset")
	If ord = "2" Then
		sql="select * from (select *,ISNULL(b.cid,0) customCateID,(row_number() OVER("& pxresult &"))  as rownum from "&tablename&" LEFT JOIN (SELECT ord as od,cateid as cid FROM tel) b ON b.od = person_his.company  where del=1 "&result&" ) z where (rownum between " & (page_count*(currpage-1)+1) & " and " & (page_count*currpage) & ") order by rownum"
	else
		sql="select * from (select *,(row_number() OVER("& pxresult &"))  as rownum from "&tablename&" where del=1 "&result&" ) z where (rownum between " & (page_count*(currpage-1)+1) & " and " & (page_count*currpage) & ") order by rownum "' & (page_count*currpage) & ") order by rownum"
	end if
	rs.open sql,conn,1,1
	if recordcount<=0 then
		Response.write "<tr><td colspan='7' style='text-align:center;'>没有信息!</td></tr>"
'if recordcount<=0 then
	else
		j7=0
		do until rs.eof
			i=j7+1
			'j7=0
			Response.write "" & vbcrlf & "             <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "           <td height=""25"" align=""left"" valign=""middle""  class=""name""><div align=""center"">"
			Response.write i
			Response.write "</div></td>" & vbcrlf & "          <td align=""left"" valign=""middle""  class=""name""><div align=""left"">"
			Select Case ord
			Case "3" ,"-8" ,"22" : Response.write rs("title")
'Select Case ord
			Case Else : Response.write rs("name")
			End Select
			Response.write "" & vbcrlf & "                     </div>" & vbcrlf & "          </td>" & vbcrlf & "           <td align=""left"" valign=""middle""  class=""name""><div align=""left"">"
			Select Case ord
			Case "3" : Response.write rs("htid")
			Case "2" : Response.write GetPhoneNumber(rs("phone"), rs("customCateID"))
			Case "-8" : Response.write rs("xmid")
			'Case "2" : Response.write GetPhoneNumber(rs("phone"), rs("customCateID"))
			Case "22" : Response.write rs("cgid")
			Case Else : Response.write rs("khid")
			End Select
			Response.write "</div>" & vbcrlf & "               </td>" & vbcrlf & "           <td align=""left"" valign=""middle""  class=""name""><div align=""center"">"
			Response.write sdk.getSqlValue("select name from gate where ord="&rs("op"),"对应修改的人不存在")
			Response.write "</div></td>" & vbcrlf & "          <td align=""left"" valign=""middle""  class=""name""><div align=""center"">"
			Response.write rs("ip")
			Response.write "</div></td>" & vbcrlf & "          <td align=""left"" valign=""middle""  class=""name""><div align=""center"">"
			Response.write rs("opdate")
			Response.write "</div></td>" & vbcrlf & "          <td width=""4%"" height=""25"" align=""left"" valign=""middle""  class=""func""><div align=""center"">" & vbcrlf & "                  <input type=""button"" name=""btn1"" value=""详情"" onClick="""
			Select Case ord
			Case "2" : Response.write("testa("& rs("id") &","& ord &" , "& rs("sort3") &")")
			Case "-8" ,"22" : Response.write("testa('"& pwurl(rs("id")) &"' ,"& ord &" ,0)")
			'Case "2" : Response.write("testa("& rs("id") &","& ord &" , "& rs("sort3") &")")
			Case Else :response.Write("testa("& rs("id") &" ,"& ord &", 0)")
			End Select
			Response.write ";"">&nbsp;"
			If ord<>"-8" And ord<>"22" Then
				'Response.write ";"">&nbsp;"
				Response.write "<input type=""button"" name=""btn2"" value=""还原"" onClick=""testb("
				Response.write rs("id")
				Response.write ");"" "
				Response.write iif(huanYanAble(ord,rs("id")),"","disabled")
				Response.write ">"
			end if
			Response.write "" & vbcrlf & "                     </div>" & vbcrlf & "          </td>" & vbcrlf & "           </tr>" & vbcrlf & "           "
			j7=j7+1
			rs.movenext
		loop
	end if
	Response.write "" & vbcrlf & "</table>  " & vbcrlf & "</form>" & vbcrlf & "</td>" & vbcrlf & "  </tr>" & vbcrlf & "<tr>" & vbcrlf & "<td  class=""page"">" & vbcrlf & "     <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "  <tr>" & vbcrlf & "    "
	if ord="3" then
		Response.write "" & vbcrlf & "    <td width=""45%"" height=""30""><div align=""left"">温馨提示：此表主要查看V32.02版本前合同修改日志，自V32.02（含）合同修改日志在合同详情中进行查看。</div></td>" & vbcrlf & "        "
	end if
	if ord="22" then
		Response.write "" & vbcrlf & "    <td width=""45%"" height=""30""><div align=""left"">温馨提示：此表主要查看V32.03版本前采购修改日志，自V32.03（含）采购修改日志在采购详情中进行查看。</div></td>" & vbcrlf & "        "
	end if
	Response.write "" & vbcrlf & "    <td >&nbsp;</td>" & vbcrlf & "    <td width=""49%""><div align=""right"">" & vbcrlf & "    "
	Response.write recordcount
	Response.write "个 | "
	Response.write currpage
	Response.write "/"
	Response.write pagecount
	Response.write "页 | &nbsp;"
	Response.write page_count
	Response.write "条信息/页&nbsp;&nbsp;" & vbcrlf & "          "
	if currpage=1 then
		Response.write "" & vbcrlf & "          <input type=""button"" name=""Submit4"" value=""首页""  class=""page""/> <input type=""button"" name=""Submit42"" value=""上一页""  class=""page""/>" & vbcrlf & "          "
	else
		Response.write "" & vbcrlf & "          <input type=""button"" name=""Submit4"" value=""首页""   class=""page"" onClick=""window.location.href='table_his.asp?fromid="
		Response.write pwurl(fromid)
		Response.write "&ord="
		Response.write ord
		Response.write "&currPage="
		Response.write  1
		Response.write "&page_count="
		Response.write page_count
		Response.write "&px="
		Response.write px
		Response.write "&ret1="
		Response.write ret1
		Response.write "&ret2="
		Response.write ret2
		Response.write "&searchkey="
		Response.write searchkey
		Response.write "&searchid="
		Response.write searchid
		Response.write "'""/> <input type=""button"" name=""Submit42"" value=""上一页""  onClick=""window.location.href='table_his.asp?fromid="
		Response.write pwurl(fromid)
		Response.write "&ord="
		Response.write ord
		Response.write "&currPage="
		Response.write  currpage -1
		Response.write "&currPage="
		Response.write "&page_count="
		Response.write page_count
		Response.write "&px="
		Response.write px
		Response.write "&ret1="
		Response.write ret1
		Response.write "&ret2="
		Response.write ret2
		Response.write "&searchkey="
		Response.write searchkey
		Response.write "&searchid="
		Response.write searchid
		Response.write "'"" class=""page""/>" & vbcrlf & "          "
	end if
	if currpage=pagecount then
		Response.write "" & vbcrlf & "          <input type=""button"" name=""Submit43"" value=""下一页""  class=""page""/> <input type=""button"" name=""Submit44"" value=""尾页""  class=""page""/>" & vbcrlf & "          "
	else
		Response.write "" & vbcrlf & "         <input type=""button"" name=""Submit43"" value=""下一页""  onClick=""window.location.href='table_his.asp?fromid="
		Response.write pwurl(fromid)
		Response.write "&ord="
		Response.write ord
		Response.write "&currPage="
		Response.write  currpage + 1
		Response.write "&currPage="
		Response.write "&page_count="
		Response.write page_count
		Response.write "&px="
		Response.write px
		Response.write "&ret1="
		Response.write ret1
		Response.write "&ret2="
		Response.write ret2
		Response.write "&searchkey="
		Response.write searchkey
		Response.write "&searchid="
		Response.write searchid
		Response.write "'"" class=""page""/> <input type=""button"" name=""Submit43"" value=""尾页""  onClick=""window.location.href='table_his.asp?fromid="
		Response.write pwurl(fromid)
		Response.write "&ord="
		Response.write ord
		Response.write "&currPage="
		Response.write  PageCount
		Response.write "&page_count="
		Response.write page_count
		Response.write "&px="
		Response.write px
		Response.write "&ret1="
		Response.write ret1
		Response.write "&ret2="
		Response.write ret2
		Response.write "&searchkey="
		Response.write searchkey
		Response.write "&searchid="
		Response.write searchid
		Response.write "'"" class=""page""/>" & vbcrlf & "          "
	end if
	Response.write "" & vbcrlf & "    </div></td>" & vbcrlf & "  </tr>" & vbcrlf & "<script language=javascript>" & vbcrlf & "function testa(valueid ,ord , tag){" & vbcrlf & " switch (ord){" & vbcrlf & "   case 2: " & vbcrlf & "                if (tag==2){" & vbcrlf & "                window.open('gcontent.asp?sid='+valueid+'','newwin22','width=1000,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');" & vbcrlf & "         }else{" & vbcrlf & "              window.open('pcontent.asp?sid='+valueid+'','newwin22','width=1000,height=500,fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');" & vbcrlf & "           }" & vbcrlf & "          break;" & vbcrlf & "  case 3: " & vbcrlf & "                window.open('ccontent.asp?sid='+valueid+'','newwin22','width=1000,height=500,fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');" & vbcrlf & "               break;" & vbcrlf & "  case -8:" & vbcrlf & "                window.open('../chance/content.asp?sid='+valueid+'','newwin22','width=1000,height=500,fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');" & vbcrlf & "                break;" & vbcrlf & "  case 22 :" & vbcrlf & "           window.open('../caigou/content.asp?view=details&sid='+valueid+'','newwin22','width=1000,height=500,fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');" & vbcrlf & "            break;" & vbcrlf & "  default:" & vbcrlf & "                window.open('wcontent.asp?sid='+valueid+'','newwin22','width=1000,height=500,fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');       " & vbcrlf & "        }" & vbcrlf & "}" & vbcrlf & vbcrlf & "function Myopen(divID){ //根据传递的参数确定显示的层" & vbcrlf & "       if(divID.style.display==""""){" & vbcrlf & "              divID.style.display=""none""" & vbcrlf & "        }else{" & vbcrlf & "          divID.style.display=""""" & vbcrlf & "    }" & vbcrlf & "       divID.style.left=300;" & vbcrlf & "   divID.style.top=10;" & vbcrlf & "}" & vbcrlf & "function testb(valuesid){" & vbcrlf & "      document.data.action =""alerttable.asp?ord1="
	Response.write ord
	Response.write "&px="
	Response.write px
	Response.write "&currPage="
	Response.write currpage
	Response.write "&ret1="
	Response.write ret1
	Response.write "&ret2="
	Response.write ret2
	Response.write "&searchkey="
	Response.write searchkey
	Response.write "&searchid="
	Response.write searchid
	Response.write "&ord=""+valuesid;" & vbcrlf & "   document.data.submit();" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "</table>" & vbcrlf & "</td>" & vbcrlf & "    </tr>" & vbcrlf & "   <tr><td>" & vbcrlf & "  "
	Response.write searchid
	rs.close
	set rs7=nothing
	conn.close
	set conn=nothing
	Response.write " " & vbcrlf & "</td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "<div id=""User"" style=""position:absolute;width:100%; height:180;display:none;"">" & vbcrlf & "<table width=""150"" height=""180""  border=""0"" cellpadding=""-2"" cellspacing=""-2"">" & vbcrlf & "  <tr>" & vbcrlf & "<td height=""192"">" & vbcrlf & "        <table width=""150"" height=""172"" bgcolor=""#ecf5ff"" border=""0"" >" & vbcrlf & "          <tr valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""table_his.asp?fromid="
	Response.write pwurl(fromid)
	Response.write "&px=1&ord="
	Response.write ord
	Response.write "&page_count="
	Response.write page_count
	Response.write "&currPage="
	Response.write currpage
	Response.write "&ret1="
	Response.write ret1
	Response.write "&ret2="
	Response.write ret2
	Response.write "&searchkey="
	Response.write searchkey
	Response.write "&searchid="
	Response.write searchid
	Response.write "&searchid="
	Response.write searchid
	Response.write "&searchid="
	Response.write searchid
	Response.write """><font color=""#2F496E"">按添加时间排序(降)</font></a></td>" & vbcrlf & "          </tr>" & vbcrlf & "              <tr  valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""table_his.asp?fromid="
	Response.write pwurl(fromid)
	Response.write "&px=2&ord="
	Response.write ord
	Response.write "&page_count="
	Response.write page_count
	Response.write "&currPage="
	Response.write currpage
	Response.write "&ret1="
	Response.write ret1
	Response.write "&ret2="
	Response.write ret2
	Response.write "&searchkey="
	Response.write searchkey
	Response.write "&searchid="
	Response.write searchid
	Response.write "&searchid="
	Response.write searchid
	Response.write "&searchid="
	Response.write searchid
	Response.write """><font color=""#2F496E"">按添加时间排序(升)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "            " & vbcrlf & "                 <tr  valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""table_his.asp?fromid="
	Response.write pwurl(fromid)
	Response.write "&px=3&ord="
	Response.write ord
	Response.write "&page_count="
	Response.write page_count
	Response.write "&currPage="
	Response.write currpage
	Response.write "&ret1="
	Response.write ret1
	Response.write "&ret2="
	Response.write ret2
	Response.write "&searchkey="
	Response.write searchkey
	Response.write "&searchid="
	Response.write searchid
	Response.write "&searchid="
	Response.write searchid
	Response.write "&searchid="
	Response.write searchid
	Response.write """><font color=""#2F496E"">按"
	Select case ord
	Case "1" : Response.write arrName(1)
	Case "2" : Response.write "用户姓名"
	Case "3" : Response.write "合同主题"
	Case "-8" : Response.write "项目主题"
	Case "3" : Response.write "合同主题"
	Case "22" : Response.write "采购主题"
	Case else
	Response.write arrName(1)
	end Select
	Response.write "排序(降)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "                <tr  valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""table_his.asp?fromid="
	Response.write pwurl(fromid)
	Response.write "&px=4&ord="
	Response.write ord
	Response.write "&page_count="
	Response.write page_count
	Response.write "&currPage="
	Response.write currpage
	Response.write "&ret1="
	Response.write ret1
	Response.write "&ret2="
	Response.write ret2
	Response.write "&searchkey="
	Response.write searchkey
	Response.write "&searchid="
	Response.write searchid
	Response.write "&searchid="
	Response.write searchid
	Response.write "&searchid="
	Response.write searchid
	Response.write """><font color=""#2F496E"">按"
	Select case ord
	Case "1" : Response.write arrName(1)
	Case "2" : Response.write "用户姓名"
	Case "3" : Response.write "合同主题"
	Case "-8" : Response.write "项目主题"
	Case "3" : Response.write "合同主题"
	Case "22" : Response.write "采购主题"
	Case else
	Response.write arrName(1)
	end Select
	Response.write "排序(升)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "               " & vbcrlf & "                 <tr  valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""table_his.asp?fromid="
	Response.write pwurl(fromid)
	Response.write "&px=5&ord="
	Response.write ord
	Response.write "&page_count="
	Response.write page_count
	Response.write "&currPage="
	Response.write currpage
	Response.write "&ret1="
	Response.write ret1
	Response.write "&ret2="
	Response.write ret2
	Response.write "&searchkey="
	Response.write searchkey
	Response.write "&searchid="
	Response.write searchid
	Response.write "&searchid="
	Response.write searchid
	Response.write "&searchid="
	Response.write searchid
	Response.write """><font color=""#2F496E"">按用户IP排序(降)</font></a> </td>" & vbcrlf & "          </tr>" & vbcrlf & "               <tr  valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""table_his.asp?fromid="
	Response.write pwurl(fromid)
	Response.write "&px=6&ord="
	Response.write ord
	Response.write "&page_count="
	Response.write page_count
	Response.write "&currPage="
	Response.write currpage
	Response.write "&ret1="
	Response.write ret1
	Response.write "&ret2="
	Response.write ret2
	Response.write "&searchkey="
	Response.write searchkey
	Response.write "&searchid="
	Response.write searchid
	Response.write "&searchid="
	Response.write searchid
	Response.write "&searchid="
	Response.write searchid
	Response.write """><font color=""#2F496E"">按用户IP排序(升)</font></a> </td>" & vbcrlf & "          </tr> " & vbcrlf & "             " & vbcrlf & "        </table>" & vbcrlf & "    </td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "" & vbcrlf & "</div>" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	
%>
