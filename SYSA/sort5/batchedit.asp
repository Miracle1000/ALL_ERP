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
	
	Response.write vbcrlf
	
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
	
	Dim progessName
	progessName="跟进程度"
	Set rs=conn.execute("select (case when isnull(name,'')='' then oldname else name end ) as name from setfields where gate1=5 ")
	If Not rs.eof Then progessName=rs(0)
	rs.close
	dim MODULES
	MODULES=session("zbintel2010ms")
	ord=request("ord")
	If Len(ord&"")=0 Then ord=0
	if Request("menu1") = "addto" then
		call addto()
	else call index()
	end if
	Public Function getmustContent(sql,keyid,ids,names)
		Dim f_rs,s
		Set f_rs=conn.execute(sql)
		Do While Not f_rs.eof
			s = s & "<input name='Content" & keyid & "' type='checkbox' value='" & f_rs(ids) & "'>" & f_rs(names) & "&nbsp;"
			f_rs.movenext
		Loop
		f_rs.close : Set f_rs=nothing
		getmustContent=s
	end function
	sub index()
		Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title></title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body {" & vbcrlf & "     margin-top: 0px;" & vbcrlf & "        font-size: 9pt;" & vbcrlf & " background-color: #FFFFFF;" & vbcrlf & "      margin-left: 0px;" & vbcrlf & "       margin-right: 0px;" & vbcrlf& "        margin-bottom: 0px;" & vbcrlf & "}" & vbcrlf & ".cllist,.home {" & vbcrlf & "     color: #5B7CAE; " & vbcrlf & "}" & vbcrlf & ".cllist tr,.home tr {" & vbcrlf & "  background-color:#FFFFFF;" & vbcrlf & "}" & vbcrlf & ".cllist td.func input {" & vbcrlf & "       color: #5B7CAE;" & vbcrlf & " background-image: url(../images/m_an1.gif);" & vbcrlf & "        background-repeat: no-repeat;" & vbcrlf & "   height: 18px;" & vbcrlf & "   width: 35px;" & vbcrlf & "    font-size: 12px;" & vbcrlf & "        border:0;" & vbcrlf & "       background-color:transparent;" & vbcrlf & "   padding:0px;" & vbcrlf & "    padding-top:2px;" & vbcrlf & "}& vbcrlf & .cllist tr.top td { & vbcrlf &   background-image: url(../images/m_table_top.jpg); & vbcrlf &        background-repeat: repeat-x; & vbcrlf &     text-align:left; & vbcrlf &         line-height:20px; & vbcrlf &        font-weight: bold; & vbcrlf &       color: #2F496E; & vbcrlf & } & vbcrlf & .cllist td.name,.home td.name {" & vbcrlf & "   color: #2F496E;" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & "</style>" & vbcrlf & "<script language=""JavaScript"" type=""text/JavaScript"">" & vbcrlf & "<!--" & vbcrlf & "function MM_jumpMenu(targ,selObj,restore){ //v3.0" & vbcrlf & "eval(targ+"".location=\'""+selObj.options[selObj.selectedIndex].value+"
		Response.write Application("sys.info.jsver")
		Response.write ord
		Response.write """; " & vbcrlf & "}" & vbcrlf & "var vi=2;  //初始行" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "function checklimit(){" & vbcrlf & "      if(confirm('批量修改操作不可恢复，您是否要继续修改？')){" & vbcrlf & "                return confirm('批量修改跟进程度可能会导致客户被系统收回，您确定要继续修改吗？');" & vbcrlf & "       }else{" & vbcrlf & "          return false;" & vbcrlf & "}" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function checkshday(){" & vbcrlf & "        var isProtect=0;" & vbcrlf & "        var reply1=0;" & vbcrlf & "   var unreplyback1day=0;" & vbcrlf & "  var unreplyback1_1=0;" & vbcrlf & "   var unreplyback1type2=0;" & vbcrlf & "        var unreplyback1day=0;" & vbcrlf & "  if(document.getElementById(""isProtect1"").checked==true){" & vbcrlf & "         isProtect=1;" & vbcrlf & "    }" & vbcrlf & "       if(isProtect==1){" & vbcrlf & "               if(document.getElementById(""reply1"").value!=""""){" & vbcrlf & "                    reply1 = Number(document.getElementById(""reply1"").value);" & vbcrlf & "                 if(document.getElementById(""isProtect1"").checked==true){" & vbcrlf & "                              unreplyback1_1=1" & vbcrlf & "                        }" & vbcrlf & "                       if(document.getElementById(""unreplyback1type2"").checked==true){" & vbcrlf & "                           unreplyback1type2=1" & vbcrlf & "                     }" & vbcrlf & "                       if(unreplyback1_1==1 && unreplyback1type2==1){" & vbcrlf & "                           unreplyback1day = Number(document.getElementById(""unreplyback1day"").value);" & vbcrlf & "                               if(unreplyback1day<=reply1){" & vbcrlf & "                                    alert(""领用未联系收回天数须大于首次联系天数"");" & vbcrlf & "                                    if(document.getElementById(""unreplyback1TypeTip1"").style.display==""none""){" & vbcrlf & "                          document.getElementById(""unreplyback1TypeTip1"").style.display=""block"";" & vbcrlf & "                                      }" & vbcrlf & "                                       document.getElementById(""unreplyback1day"").focus();" & vbcrlf & "                                       return false;" & vbcrlf & "                           }else{" & vbcrlf & "                                  return true;" & vbcrlf & "                            }" & vbcrlf & "                       }else{" & vbcrlf & "                         return true;" & vbcrlf & "                    }" & vbcrlf & "               }" & vbcrlf & "       }else{" & vbcrlf & "          return true;" & vbcrlf & "    }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "//-->" & vbcrlf & "</script>" & vbcrlf & "</head>" & vbcrlf & "<body >" & vbcrlf & ""
		'Response.write ord
		Dim sort4name
		Set rs=conn.execute("select sort1 from sort4 where ord="& ord)
		If rs.eof=False Then sort4name=rs(0).value
		rs.close : Set rs=Nothing
		dim clo
		clo=request("clo")
		if clo<>"" Then
			Response.write "" & vbcrlf & "<script language='javascript'>window.close();</script>" & vbcrlf & ""
		end if
		Response.write "" & vbcrlf & "<table width=""100%""  border=""0"" align=""left"" cellpadding=""0"" cellspacing=""0"" bordercolor=""#E2E2E1"" bgcolor=""#FFFFFF"" >" & vbcrlf & "  <tr>" & vbcrlf & "    <td width=""100%"" valign=""top"">" & vbcrlf & "  <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" height=""27"">" & vbcrlf & "              <tr>" & vbcrlf & "                <td width=""5%"" class=""resetElementHidden"" height=""27""  background=""../images/contentbg.gif""><div align=""center""><img src=""../images/contenttop.gif""height=""27""> </div></td> " & vbcrlf & "              <td width=""95%"" class=""resetUniqueTabtleTitle resetUniqueText""  background=""../images/contentbg.gif"">" & vbcrlf & "                  <strong><font class=""tableTitleLinks"" color=""#1445A6"">"
		Response.write progessName
		Response.write "批量修改</font></strong> </td>" & vbcrlf & "        </tr>" & vbcrlf & "      </table>" & vbcrlf & "     <form method=""post"" action=""batchedit.asp?ord="
		Response.write ord
		Response.write """ id=""demo"" onsubmit=""return Validator.Validate(this,2) && checkshday() && checklimit()"" name=""date"">" & vbcrlf & "    <table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "              <input type=hidden name=menu1 value=addto>" & vbcrlf & "             <input type=hidden name=ip value="
		Response.write Request.ServerVariables("REMOTE_ADDR")
		Response.write ">" & vbcrlf & "    <tr class=""top"">" & vbcrlf & "      <td colspan=""4"">修改"
		Response.write progessName
		Response.write "("
		Response.write sort4name
		Response.write ") </td>" & vbcrlf & "    </tr>" & vbcrlf & "      <tr class=""top"">" & vbcrlf & "      <td colspan=""4"">" & vbcrlf & "                <span style=""float:left;"">基础设置 </span>" & vbcrlf & "                <span style=""float:right; margin-right:8px;"">" & vbcrlf & "            <input type=""submit"" name=""Submit422"" value=""修改"" class=""page""/>" & vbcrlf & "            <input type=""reset"" value=""重填"" class=""page"" name=""B2"">" & vbcrlf & "              </span>" & vbcrlf & "                 <div style=""clear:both;""> </div>" & vbcrlf & "          </td>" & vbcrlf & "    </tr>" & vbcrlf & " " & vbcrlf & "    <tr height=""30"">" & vbcrlf &"      <td ><div align=""right"">是否开启积分：</div></td>" & vbcrlf & "      <td><input name=""jf"" type=""radio"" value=""1"">" & vbcrlf & "        开启" & vbcrlf & "          <input type=""radio"" name=""jf"" value=""0"" checked>" & vbcrlf & "          关闭</td>" & vbcrlf & "" & vbcrlf & "      "
		Dim open_automodel, displaycss
		open_automodel = ZBRuntime.MC(201103)
		If open_automodel = False Then
			displaycss =  " style='display:none' "
		end if
		Dim cols
		cols=1
		if ZBRuntime.MC(13000) then
			Response.write "" & vbcrlf & "      <td><div align=""right"">是否开启价格策略：</div></td>" & vbcrlf & "      <td colspan="""
			Response.write cols
			Response.write """>" & vbcrlf & "                 <input name=""time1"" type=""radio"" value=""1"" checked>" & vbcrlf & "                   开启" & vbcrlf & "                    <input type=""radio"" name=""time1"" value=""0"">" & vbcrlf & "               关闭" & vbcrlf & "          </td>" & vbcrlf & " "
		else
			Response.write "" & vbcrlf & "        <td colspan="""
			Response.write cols+1
			Response.write "" & vbcrlf & "        <td colspan="""
			Response.write """></td>" & vbcrlf & "    "
		end if
		Response.write "" & vbcrlf & "      </tr>" & vbcrlf & "" & vbcrlf & "   <script src= ""../Script/s5_batchedit.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """  language=""javascript""></script>" & vbcrlf & "   <tr class=""top"" "
		Response.write displaycss
		Response.write " >" & vbcrlf & "      <td colspan=""4""><a class=""tableTitleLinks"" href=""javascript:;"" onclick=""this.blur();showGjcl();"">跟进策略<span id='t1' style="""">(点击即可收回)</span><input type='hidden' value=2 id=""v1""></a>" & vbcrlf & "      </td>" & vbcrlf & "    </tr>" & vbcrlf & "        </tbody>" & vbcrlf &"  " & vbcrlf & "        "
		gjmaxday = 1
		Set rs2 = conn.execute("select isnull(MAX(a.gate2),0) from sort5list a left join sort5 b on a.sort5=b.ord where b.sort1=3 and a.gate2 not in(9998,9999) ")
		If Not rs2.eof Then
			If rs2(0)>0 Then gjmaxday = rs2(0)
		end if
		rs2.close
		Set rs2 = Nothing
		isProtect = 0
		Set rs2 = conn.execute("select ISNULL(max(ISNULL(isProtect,0)),0) from sort5 where sort1="& ord)
		If Not rs2.eof Then
			isProtect = rs2(0)
		end if
		rs2.close
		Set rs2 = Nothing
		ztday = 0
		ztday = ztday + 1
		ztday = 0
		Response.write "" & vbcrlf & "     <tbody id=""cllist1"" "
		Response.write displaycss
		Response.write " >" & vbcrlf & "    <tr>" & vbcrlf & "     <td><div align=""right"">是否开启跟进策略：</div></td>" & vbcrlf & "      <td colspan=""3""><div align=""left"">" & vbcrlf & "            <input name=""isProtect"" id=""isProtect1"" type=""radio"" value=""1"""
		if isProtect="1" then Response.write(" checked")
		Response.write " onClick=""this.blur();showGjday();"">开启&nbsp;&nbsp;" & vbcrlf & "            <input name=""isProtect"" id=""isProtect0"" type=""radio"" value=""0"""
		if isProtect="0" then Response.write(" checked")
		Response.write " onClick=""this.blur();showGjday();"">关闭" & vbcrlf & "                 </div>" & vbcrlf & "          </td>" & vbcrlf & "    </tr>" & vbcrlf & "        </tbody>" & vbcrlf & "        <tbody id=""cllist5"" "
		If isProtect="0" then
			Response.write "style=""display:none"""
		end if
		Response.write ">" & vbcrlf & "    <tr>" & vbcrlf & "      <td width=""20%""><div align=""right"">首次联系：</div></td>" & vbcrlf & "      <td colspan=""3"" width=""80%"">" & vbcrlf & "          <div align=""left"">" & vbcrlf & "            <input name=""reply1"" type=""text"" id=""reply1"" size=""15"" dataType=""Number"" min=""0"" max=""10000"" msg=""数字在0-10000之间"" value=""1"" onKeyUp=""autoztday()"" onpropertychange=""totalday()""> 天" & vbcrlf & "             </div>" & vbcrlf & "          </td>" & vbcrlf & "    </tr>" & vbcrlf & "        </tbody>" & vbcrlf & "        <tbody id=""replysobj"" "
		Response.write "style=""display:none"""
		If isProtect="0" Or gjmaxday<=1 then
			Response.write "style=""display:none"""
		end if
		Response.write ">" & vbcrlf & "    "
		If gjmaxday>1 Then
			For i=2 To gjmaxday
				ztday = ztday + 1
'For i=2 To gjmaxday
				Response.write "" & vbcrlf & "                     <tr id=""reply_"
				Response.write i
				Response.write """>" & vbcrlf & "                          <td ><div align=""right"">第"
				Response.write i
				Response.write "次联系：</div></td>" & vbcrlf & "                    <td colspan=""2"">" & vbcrlf & "                                  <div align=""left"">" & vbcrlf & "                                      <input name=""reply"
				Response.write i
				Response.write """ type=""text"" id=""reply"
				Response.write i
				Response.write """ size=""15"" dataType=""Number"" min=""0"" max=""10000"" msg=""数字在0-10000之间"" value=""1"" onKeyUp=""autoztday()"" onpropertychange=""totalday()""> 天（与上一次联系天数间隔）" & vbcrlf & "                                 </div>" & vbcrlf & "                          </td>" & vbcrlf & "                   <td><div align='left' style='cursor:pointer;' onclick=""deleterow('reply_"
				Response.write i
				Response.write "')"">删除</div></td>" & vbcrlf & "                       </tr>" & vbcrlf & "                   <script>vi=vi+1;</script>" & vbcrlf & "                       "
				Response.write i
			next
		end if
		Response.write "" & vbcrlf & "     </tbody>" & vbcrlf & "" & vbcrlf & "        <tbody id=""cllist4"" "
		If isProtect="0" then
			Response.write "style=""display:none"""
		end if
		Response.write ">" & vbcrlf & "    <tr height=""30"">" & vbcrlf & "    <td ><div align=""right"" style=""text-decoration: underline; cursor: pointer;"" onclick=""addreply()"" >添加新行</div></td>" & vbcrlf & "      <td colspan=""3""> " & vbcrlf & "   </td>" & vbcrlf & "    </tr>" & vbcrlf & "    <script src= ""../Script/s5_batchedit_1.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """  lanaguage=""javascript""></script>" & vbcrlf & " <tr>" & vbcrlf & "      <td ><div align=""right"">以后每次联系</div></td>" & vbcrlf & "      <td colspan=""3"">" & vbcrlf & "          <div align=""left"">"
		ztday = ztday + 1
		Response.write "" & vbcrlf & "            <input name=""replycommon"" type=""text"" id=""replycommon"" size=""15"" dataType=""Number"" min=""0"" max=""100"" msg=""数字在0-10000之间"" value=""1"" onKeyUp=""autoztday()""> 天（循环间隔天数）" & vbcrlf & "               </div>" & vbcrlf & "          </td>" & vbcrlf & "    </tr>" & vbcrlf & "" &vbcrlf & "        <tr>" & vbcrlf & "      <td ><div align=""right"">自动暂停跟踪</div></td>" & vbcrlf & "      <td colspan=""3"">" & vbcrlf & "          <div align=""left"">" & vbcrlf & "            <input name=""replypause"" type=""text"" id=""replypause"" size=""15"" dataType=""Number"" min=""0"" max=""10000""  msg=""数字在0-10000之间"" value="""
		Response.write ztday
		Response.write """> 天" & vbcrlf & "               </div>" & vbcrlf & "          </td>" & vbcrlf & "    </tr>" & vbcrlf & "        </tbody>" & vbcrlf & "" & vbcrlf & "        <tbody>" & vbcrlf & " <tr class=""top"">" & vbcrlf & "      <td colspan=""4""><a class=""tableTitleLinks"" href=""javascript:void(0);"" onclick=""show_cllist('cllist2');"">回收策略<span id='t2' style="""">(点击即可收回)</span><input type='hidden' value=2 id=""v2""></a>" & vbcrlf & "       </td>" & vbcrlf & "    </tr>" & vbcrlf & "        </tbody>" & vbcrlf & "" & vbcrlf & "        <tbody id=""cllist2"">" & vbcrlf & "      <tr>" & vbcrlf & "      <td width=""20%""><div align=""right"">回收例外策略：</div></td>" & vbcrlf & "      <td colspan=""3"" width=""75%"">" & vbcrlf & "                   <div align=""left"" style=""margin:5px 0 3px 0;"" >" & vbcrlf & "                                     该"
		Response.write progessName
		Response.write "下的客户不受回收策略控制" & vbcrlf & "                     </div>" & vbcrlf & "                  <div align=""left"">" & vbcrlf & "                                                <input name=""unautoback"" type=""radio"" value=""1"">" & vbcrlf & "                                              是" & vbcrlf & "                                              <input type=""radio"" name=""unautoback"" value=""0"" checked>" & vbcrlf & "                                              否" & vbcrlf & "                      </div>"& vbcrlf & "                      <div align=""left"" style=""margin:5px 0 3px 0;"" >" & vbcrlf & "                                     保护状态下客户不受回收策略控制" & vbcrlf & "                  </div>" & vbcrlf & "                  <div align=""left"">" & vbcrlf & "                                                <input name=""unback"" type=""radio"" value=""1"">" & vbcrlf & "                                          是" & vbcrlf & "                                              <input type=""radio"" name=""unback"" value=""0"" checked>" & vbcrlf &"                                                否" & vbcrlf & "                      </div>" & vbcrlf & vbcrlf & "    </td>" & vbcrlf & " </tr>" & vbcrlf & vbcrlf & "   <tr>" & vbcrlf & "      <td ><div align=""right"">领用未联系收回：</div></td>" & vbcrlf & "      <td colspan=""3"">" & vbcrlf & "                 <script src=""../Script/s5_batchedit_2.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """  language=""javascript""></script>" & vbcrlf & "          <div align=""left"" style=""margin:5px;"">" & vbcrlf & "                                              <input type=""radio"" name=""unreplyback1"" id=""unreplyback1_1"" value=""1"" onclick=""document.getElementById('sz1_1').style.display='';"" >" & vbcrlf & "                                              启用" & vbcrlf & "                                            <input type=""radio"" name=""unreplyback1"" value=""0"" checked onclick=""document.getElementById('sz1_1').style.display='none';document.getElementById('unreplyback1TypeTip1').style.display='none';document.getElementById('unreplyback1TypeTip2').style.display='none';document.getElementById('tips1').style.display='none';"" >" & vbcrlf & "                                             不启用" & vbcrlf & "                  </div>" & vbcrlf & "                  <div id=""sz1_1"" align=""left"" style=""margin:5px;display:none;"">" & vbcrlf & "                                                <span style=""float:left"">" & vbcrlf & "                                         <input type=""radio"" name=""unreplyback1type"" id=""unreplyback1type2"" value=""2""  onclick=""lywlxdyqx()"">" & vbcrlf & "                                             单一期限" & vbcrlf & "                                                <input type=""radio"" name=""unreplyback1type"" value=""3"" onclick=""document.getElementById('unreplyback1TypeTip1').style.display='none';document.getElementById('unreplyback1TypeTip2').style.display='block';document.getElementById('tips1').style.display='block';"">" & vbcrlf & "                                          不同人员设置不同期限" & vbcrlf & "                                            </span>" & vbcrlf & "                                         <span id=""tips1"" style=""display:none"">" & vbcrlf & "                                              <input type=""button"" name=""Submit32"" value=""批量设置""  class=""anniu"" onClick=""javascript:window.open('../manager/batchsetgate.asp','newwin','width=' + 1100 + ',height=' + 800 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=100,top=10')"" style=""margin-left:10px;"" />" & vbcrlf & "                                           </span>" & vbcrlf & "                 </div>" & vbcrlf & "                  <div align=""left"" style=""clear:both;margin:5px;display:none;"" id=""unreplyback1TypeTip1""  >" & vbcrlf & "                             <input name=""unreplyback1day"" type=""text"" id=""unreplyback1day"" size=""15"" dataType=""Number"" min=""0"" max=""100""  msg=""数字在0-10000之间"" value=""2"" onKeyup=""if(this.value==''){this.value='1'}"">  天 <br />" & vbcrlf & "                   </div>" & vbcrlf & "                       <div align=""left"" style=""margin:5px;display:none;"" id=""unreplyback1TypeTip2"">" & vbcrlf & "                          不同销售人员收回的期限可以不一样，具体期限您可以在用户账号管理界面设置。" & vbcrlf & "                       </div>" & vbcrlf & "    </td>" & vbcrlf & " </tr>" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "   <tr>" & vbcrlf & "      <td ><div align=""right"">间隔未联系收回：</div></td>" & vbcrlf & "      <td colspan=""3"">" & vbcrlf & "           <div align=""left"" style=""margin:5px;"">" & vbcrlf & "                                              <input type=""radio"" name=""unreplyback2"" value=""1"" onclick=""document.getElementById('sz2_1').style.display='';"">" & vbcrlf & "                                         启用" & vbcrlf & "                                             <input type=""radio"" name=""unreplyback2"" value=""0""  checked onclick=""document.getElementById('sz2_1').style.display='none';document.getElementById('unreplyback2TypeTip1').style.display='none';document.getElementById('unreplyback2TypeTip2').style.display='none';document.getElementById('tips2').style.display='none';"" >" & vbcrlf & "                                             不启用" & vbcrlf & "                  </div>" & vbcrlf & "                  <div id=""sz2_1"" align=""left"" style=""margin:5px;display:none;"" >" & vbcrlf & "                                               <span style=""float:left"">" & vbcrlf & "                                         <input type=""radio"" name=""unreplyback2type"" value=""2""  onclick=""document.getElementById('unreplyback2TypeTip2').style.display='none';document.getElementById('unreplyback2TypeTip1').style.display='block';document.getElementById('tips2').style.display='none';"">" & vbcrlf & "                                             单一期限" & vbcrlf & "                                                <input type=""radio"" name=""unreplyback2type"" value=""3"" onclick=""document.getElementById('unreplyback2TypeTip1').style.display='none';document.getElementById('unreplyback2TypeTip2').style.display='block';document.getElementById('tips2').style.display='block';"">" & vbcrlf & "                                              不同人员设置不同期限" & vbcrlf & "                                            </span>" & vbcrlf & "                                         <span id=""tips2""  style=""display:none"">" & vbcrlf & "                                          <input type=""button"" name=""Submit32"" value=""批量设置""  class=""anniu"" onClick=""javascript:window.open=10')"" style=""margin-left:10px;"" />" & vbcrlf & "                                                </span>" & vbcrlf & "                 </div>" & vbcrlf & "                  <div align=""left"" style=""clear:both;margin:5px;display:none;""  id=""unreplyback2TypeTip1"" >" & vbcrlf & "                             <input name=""unreplyback2day"" type=""text"" id=""unreplyback2day"" size=""15""dataType=""Number"" min=""0"" max=""100""  msg=""数字在0-10000之间"" value=""0"" onKeyup=""if(this.value==''){this.value='0'}"">  天 <br />" & vbcrlf & "                        </div>" & vbcrlf & "                  <div align=""left"" style=""margin:5px;display:none;"" id=""unreplyback2TypeTip2"">" & vbcrlf & "                          不同销售人员收回的期限可以不一样，具体期限您可以在用户账号管理界面设置。" & vbcrlf & "                    </div>" & vbcrlf & "    </td>" & vbcrlf & " </tr>" & vbcrlf & "" & vbcrlf & "  "
		if ZBRuntime.MC(7000) then
			Response.write "" & vbcrlf & "     <tr>" & vbcrlf & "      <td ><div align=""right"">领用未成功收回：</div></td>" & vbcrlf & "      <td colspan=""3"">" & vbcrlf & "                 <div align=""left"" style=""margin:5px;"">" & vbcrlf & "                                              <input name=""unsalesback"" type=""radio"" value=""1"" onclick=""document.getElementById('sz3_1').style.display='';"">" & vbcrlf & "                                             启用" & vbcrlf & "                                            <input type=""radio"" name=""unsalesback"" value=""0""  checked onclick=""document.getElementById('sz3_1').style.display='none';document.getElementById('unsalesbacktypeTip1').style.display='none';document.getElementById('unsalesbacktypeTip2').style.display='none';document.getElementById('tips3').style.display='none';"" >" & vbcrlf & "                                             不启用" & vbcrlf & "                  </div>" & vbcrlf & "                  <div align=""left"" style=""margin:5px;display:none;"" id=""sz3_1"" >" & vbcrlf & "                                               <span style=""float:left"">" & vbcrlf & "                                         <input name=""unsalesbacktype"" type=""radio"" value=""2""  onclick=""document.getElementById('unsalesbacktypeTip2').style.display='none';document.getElementById('unsalesbacktypeTip1').style.display='block';document.getElementById('tips3').style.display='none';"">" & vbcrlf & "                                            单一期限" & vbcrlf & "                                                <input type=""radio"" name=""unsalesbacktype"" value=""3"" onclick=""document.getElementById('unsalesbacktypeTip1').style.display='none';document.getElementById('unsalesbacktypeTip2').style.display='block';document.getElementById('tips3').style.display='block';"">" & vbcrlf & "                                            不同人员设置不同期限" & vbcrlf & "                                           </span>" & vbcrlf & "                                         <span id=""tips3"" style=""display:none"">" & vbcrlf & "                                              <input type=""button"" name=""Submit32"" value=""批量设置""  class=""anniu"" onClick=""javascript:window.open('../manager/batchsetgate.asp','newwin','width=' + 1100 + ',height=' + 800 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=100,top=10')"" style=""margin-left:10px;"" />" & vbcrlf & "                                               </span>" & vbcrlf & "                 </div>" & vbcrlf & "                  <div align=""left"" style=""clear:both;margin:5px;display:none;""  id=""unsalesbacktypeTip1"" >" & vbcrlf & "                              <input name=""TipsPerDaylist"" type=""text"" id=""TipsPerDaylist1"" size=""15"" dataType=""Number"" min=""0"" max=""100""  msg=""数字在0-10000之间"" value=""0"" onKeyup=""if(this.value==''){this.value='0'}"">  天 <br />" & vbcrlf & "                     </div>" & vbcrlf & "                  <div align=""left"" style=""margin:5px;display:none;"" id=""unsalesbacktypeTip2"" >" & vbcrlf & "                               不同销售人员收回的期限可以不一样，具体期限您可以在用户账号管理界面设置。" & vbcrlf & "                       </div>" & vbcrlf & "    </td>" & vbcrlf &  "</tr>" & vbcrlf & ""
		end if
		Response.write "" & vbcrlf & "     <tr  "
		Response.write displaycss
		Response.write ">" & vbcrlf & "      <td><div align=""right"">跟进超期收回：</div></td>" & vbcrlf & "      <td colspan=""3"">" & vbcrlf & "                    在此设置本阶段停留最大天数收回期限" & vbcrlf & "              <div align=""left"" style=""margin:5px;"">" & vbcrlf & "                                              <input name=""stayback"" type=""radio"" value=""1"" onclick=""document.getElementById('staybacktip').style.display='block';"">" & vbcrlf & "                                               启用" & vbcrlf & "                                            <input type=""radio"" name=""stayback"" value=""0"" checked onclick=""document.getElementById('staybacktip').style.display='none';document.getElementById('staybacktiptypeTip1').style.display='none';document.getElementById('staybacktiptypeTip2').style.display='none';document.getElementById('tips4').style.display='none';"">" & vbcrlf & "                                              不启用" & vbcrlf & "                  </div>" & vbcrlf & "                  <div align=""left"" style=""margin:5px;display='none'"" id=""staybacktip""  >" & vbcrlf & "                                               <span style=""float:left"">" & vbcrlf & "                                               <input name=""staybacktiptype"" type=""radio"" value=""2""   onclick=""document.getElementById""                                         单一期限" & vbcrlf & "                                                <input type=""radio"" name=""staybacktiptype"" value=""3"" onclick=""document.getElementById('staybacktiptypeTip1').style.display='none';document.getElementById('staybacktiptypeTip2').style.display='block';document.getElementById('tips4').style.display='block';"">" & vbcrlf & "                                         不同人员设置不同期限" & vbcrlf & "                                            </span>" & vbcrlf & "                                         <span id=""tips4"" style=""display:none"">" & vbcrlf & "                                              <input type=""button"" name=""Submit32"" value=""批量设置""  class=""anniu"" onClick=""javascript:window.open('../manager/batchsetgate.asp','newwin','width=' + 1100 + ',height=' + 800 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=100,top=10')"" style=""margin-left:10px;"" />" & vbcrlf & "                                               </span>" & vbcrlf & "                 </div>" & vbcrlf & "                  <div align=""left"" style=""clear:both;margin:5px;display='none'""  id=""staybacktiptypeTip1"" >" & vbcrlf & "                            <input name=""staybackday"" type=""text"" id=""staybackday"" size=""15"" dataType=""Number"" min=""0"" max=""100""  msg=""数字在0-10000之间"" value=""0"" onKeyup=""if(this.value==''){this.value='0'}"">  天 <br />" & vbcrlf & "                       </div>" & vbcrlf & "                  <div align=""left"" style=""margin:5px;display:none;""id=""staybacktiptypeTip2"">" & vbcrlf & "                           不同销售人员收回的期限可以不一样，具体期限您可以在用户账号管理界面设置。" & vbcrlf & "                       </div>" & vbcrlf & "    </td>" & vbcrlf & " </tr>" & vbcrlf & vbcrlf & vbcrlf & vbcrlf & "   <tr "
		Response.write displaycss
		Response.write ">" & vbcrlf & "      <td ><div align=""right"">领用超期收回：</div></td>" & vbcrlf & "      <td colspan=""3"">" & vbcrlf & "                   在此设置领用至本阶段最大跟进天数收回期限" & vbcrlf & "                <div align=""left"" style=""margin:5px;"">" & vbcrlf & "                                              <input name=""maxback"" type=""radio"" value=""1"" onclick=""document.getElementById('maxbacktip').style.display='block';"">" & vbcrlf & "                                             启用" & vbcrlf & "                                            <input type=""radio"" name=""maxback"" value=""0"" checked onclick=""document.getElementById('maxbacktip').style.display='none';document.getElementById('maxbacktiptypeTip1').style.display='none';document.getElementById('maxbacktiptypeTip2').style.display='none';document.getElementById('tips5').style.display='none';"">" & vbcrlf & "                                                不启用" & vbcrlf & "                  </div>" & vbcrlf & "                  <div align=""left"" style=""margin:5px;display='none'"" id=""maxbacktip""  >" & vbcrlf & "                                                <span style=""float:left"">"& vbcrlf & "                                            <input name=""maxbacktiptype"" type=""radio"" value=""2""  onclick=""document.getElementById单一期限" & vbcrlf & "                                                <input type=""radio"" name=""maxbacktiptype"" value=""3"" onclick=""document.getElementById('maxbacktiptypeTip1').style.display='none';document.getElementById('maxbacktiptypeTip2').style.display='block';document.getElementById('tips5').style.display='block';"">" & vbcrlf & "不同人员设置不同期限" & vbcrlf & "                                            </span>" & vbcrlf & "                                         <span id=""tips5"" style=""display:none"">" & vbcrlf & "                                              <input type=""button"" name=""Submit32"" value=""批量设置""  class=""anniu"" onClick=""javascript:window.open('../manager/batchsetgate.asp','newwin','width=' + 1100 + ',height=' +800 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=100,top=10')"" style=""margin-left:10px;"" />" & vbcrlf & "                                         </span>" & vbcrlf & "                 </div>" & vbcrlf & "                  <div align=""left"" style=""clear:both;margin:5px;display='none'""  id=""maxbacktiptypeTip1"">" & vbcrlf & "                               <input name=""maxbackday"" type=""text"" id=""maxbackday"" size=""15"" dataType=""Number"" min=""0"" max=""100""  msg=""数字在0-10000之间"" value=""0"" onKeyup=""if(this.value==''){this.value='0'}"">  天 <br />" & vbcrlf & "                     </div>" & vbcrlf & "                  <div align=""left"" style=""margin:5px;display:none;"" id=""maxbacktiptypeTip2"">" & vbcrlf & "                             不同销售人员收回的期限可以不一样，具体期限您可以在用户账号管理界面设置。" & vbcrlf & "                       </div>" & vbcrlf & "    </td>" & vbcrlf & " </tr>" & vbcrlf & "   </tbody>" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "        <tbody>" & vbcrlf & " <tr class=""top""  "
		Response.write displaycss
		Response.write ">" & vbcrlf & "      <td colspan=""4""><a class=""tableTitleLinks"" href=""javascript:void(0);""  onclick=""show_cllist('cllist3');"">回收提醒<span id='t3' style="""">(点击即可收回)</span><input type='hidden' value=2 id=""v3""></a>" & vbcrlf & "      </td>" & vbcrlf & "    </tr>" & vbcrlf & "        </tbody>" & vbcrlf & "" & vbcrlf & "  <tbody id=""cllist3"">" & vbcrlf & "      <tr style=""height:30px;""  "
		Response.write displaycss
		Response.write ">" & vbcrlf & "      <td width=""20%""><div align=""right"">是否启用提醒：</div></td>" & vbcrlf & "      <td width=""25%"">" & vbcrlf & "          <div align=""left"">" & vbcrlf & "                                                <input name=""canremind"" type=""radio"" value=""1"" onclick=""document.getElementById('tips6').style.display='block';document.getElementById('tips7').style.display='block';"">" & vbcrlf & "                                               是" & vbcrlf & "                                              <input type=""radio"" name=""canremind"" value=""0"" checked onclick=""document.getElementById('tips6').style.display='none';document.getElementById('tips7').style.display='none';"">" & vbcrlf & "                          否" & vbcrlf & "                      </div>" & vbcrlf & "    </td>" & vbcrlf & "           <td width=""20%""><div align=""right"" id=""tips6"" style=""display:none"">提前提醒天数：</div></td>" & vbcrlf & "      <td width=""30%"">" & vbcrlf & "              <div align=""left"" id=""tips7"" style=""display:none"">" & vbcrlf & "                                            <input name=""reminddays"" type=""text"" id=""reminddays"" size=""15"" dataType=""Number"" min=""0"" max=""100""  msg=""数字在0-10000之间"" value=""0"" onKeyup=""if(this.value==''){this.value='0'}"">  天" & vbcrlf & "                    </div>" & vbcrlf & "    </td>" & vbcrlf & " </tr>" & vbcrlf & "   </tbody>" & vbcrlf & "" & vbcrlf & " <tbody class=""cllist"">" & vbcrlf & "    <tr>" & vbcrlf & "        <td colspan=""4""><div align=""center"" style='padding:5px'>" & vbcrlf & "            <input type=""submit"" name=""Submit422"" value=""修改"" class=""page""/>" & vbcrlf & "            <input type=""reset"" value=""重填"" class=""page"" name=""B2"">" & vbcrlf & "        </div></td>" & vbcrlf & "    </tr>" & vbcrlf & "        </tbody>  " & vbcrlf & "    </td>" & vbcrlf & "  </tr>" & vbcrlf & "  </table>" & vbcrlf & "  </form>  " & vbcrlf & "   <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "  <tr>" & vbcrlf & "<td height=""80"" class=""page""><div align=""center""></div></td>" & vbcrlf & "    </tr>" & vbcrlf & "</table>" & vbcrlf & " </body>" & vbcrlf & "</html>" & vbcrlf & "" & vbcrlf & "  "
	end sub
	sub addto()
		dim sort1,sort2,gate2,ord
		ord=request("ord")
		If Len(ord&"")=0 Then ord=0
		time1=request("time1")
		if time1="" then
			time1=0
		end if
		time2=request("time2")
		if time2="" then
			time2=0
		end if
		jf=request("jf")
		if jf="" then
			jf=0
		end if
		mustHas=request("mustHas")
		If Len(mustHas&"")=0 Then mustHas=0
		AutoNext=request("AutoNext")
		If Len(AutoNext&"")=0 Then AutoNext=0
		ContentType=request("ContentType")
		If Len(ContentType&"")=0 Then ContentType=0
		ContentType=request("ContentType")
		Content=request("Content")
		mustRole=request("Content1")
		mustzdy=request("Content2")
		mustkz_zdy=request("Content3")
		If Len(Content)>0 Then Content=Replace(Content," ","")
		If Len(mustRole)>0 Then mustRole=Replace(mustRole," ","")
		If Len(mustzdy)>0 Then mustzdy=Replace(mustzdy," ","")
		If Len(mustkz_zdy)>0 Then mustkz_zdy=Replace(mustkz_zdy," ","")
		perSuccess=request("perSuccess")
		If Len(perSuccess&"")=0 Then perSuccess=0
		unautoback=request("unautoback")
		If Len(unautoback&"")=0 Then unautoback=0
		unback=request("unback")
		If Len(unback&"")=0 Then unback=0
		protect=request("protect")
		If Len(protect&"")=0 Then protect=0
		isProtect=request("isProtect")
		If Len(isProtect&"")=0 Then isProtect=0
		unreplyback1=request("unreplyback1")
		If Len(unreplyback1&"")=0 Then unreplyback1=0
		unreplyback1day=request("unreplyback1day")
		If Len(unreplyback1day&"")=0 Then unreplyback1day=0
		unreplyback1Type=request("unreplyback1Type")
		If Len(unreplyback1Type&"")=0 Then unreplyback1Type=0
		If unreplyback1Type<>"0" And unreplyback1="1" Then
			unreplyback1=unreplyback1Type
		end if
		unreplyback2=request("unreplyback2")
		If Len(unreplyback2&"")=0 Then unreplyback2=0
		unreplyback2day=request("unreplyback2day")
		If Len(unreplyback2day&"")=0 Then unreplyback2day=0
		unreplyback2Type=request("unreplyback2Type")
		If Len(unreplyback2Type&"")=0 Then unreplyback2Type=0
		If unreplyback2Type<>"0" And unreplyback2="1" Then
			unreplyback2=unreplyback2Type
		end if
		unsalesback=request("unsalesback")
		If Len(unsalesback&"")=0 Then unsalesback=0
		unsalesbacktype=request("unsalesbacktype")
		If Len(unsalesbacktype&"")=0 Then unsalesbacktype=0
		TipsPerDaylist=request("TipsPerDaylist")
		If Len(TipsPerDaylist&"")=0 Then TipsPerDaylist=0
		If unsalesbacktype<>"0" And unsalesback="1" Then
			unsalesback=unsalesbacktype
		end if
		stayback=request("stayback")
		If Len(stayback&"")=0 Then stayback=0
		staybacktiptype=request("staybacktiptype")
		If Len(staybacktiptype&"")=0 Then staybacktiptype=0
		If staybacktiptype<>"0" And stayback="1" Then
			stayback=staybacktiptype
		end if
		staybackday=request("staybackday")
		If Len(staybackday&"")=0 Then staybackday=0
		maxback=request("maxback")
		If Len(maxback&"")=0 Then maxback=0
		maxbacktiptype=request("maxbacktiptype")
		If Len(maxbacktiptype&"")=0 Then maxbacktiptype=0
		If maxbacktiptype<>"0" And maxback="1" Then
			maxback=maxbacktiptype
		end if
		maxbackday=request("maxbackday")
		If Len(maxbackday&"")=0 Then maxbackday=0
		canremind=request("canremind")
		If Len(canremind&"")=0 Then canremind=0
		reminddays=request("reminddays")
		If Len(reminddays&"")=0 Then reminddays=0
		If Len(gate2&"")=0 Then gate2=0
		If Len(ord&"")=0 Then ord=0
		If Len(jf&"")=0 Then jf=0
		conn.CursorLocation=3
		conn.BeginTrans
		sql = "select * from sort5 where sort1="&ord&" "
		Set Rs = server.CreateObject("adodb.recordset")
		Rs.open sql,conn,3,2
		Do While Not rs.eof
			ord=rs("ord")
			Call savesort_his(ord)
			Rs("time1")=time1
			Rs("time2")=time2
			Rs("jf")=jf
			Rs("unautoback")=unautoback
			Rs("unback")=unback
			Rs("protect")=protect
			Rs("isProtect")=isProtect
			Rs("unreplyback1")=unreplyback1
			Rs("unreplyback2")=unreplyback2
			Rs("unsalesback")=unsalesback
			Rs("stayback")=stayback
			Rs("staydays")=staybackday
			Rs("maxback")=maxback
			Rs("maxbackdays")=maxbackday
			Rs("canremind")=canremind
			Rs("reminddays")=reminddays
			Rs("cateid")=session("personzbintel2007")
			Rs("date7")=now()
			Rs("del")=1
			rs.update
			conn.execute("if exists(select top 1 1 from gate a left join sort5_gate b on a.ord=b.gateord and b.sort5=" & ord & " where b.id is null) insert into sort5_gate(gateord,sort5) select a.ord," & ord & " from gate a left join sort5_gate b on a.ord=b.gateord and b.sort5=" & ord & " where b.id is null")
			if isProtect&""="0" then
				conn.execute("delete from sort5list where sort5=" & ord )
				conn.execute("delete from sort5list where sort5=" & ord & " and gate2=9998")
				conn.execute("delete from sort5list where sort5=" & ord & " and gate2=9999")
			else
				Call savegjset(ord)
			end if
			If unreplyback1="2" Then
				sqltext="Update sort5_gate set unback1day="&unreplyback1day&" where sort5=" & ord
				conn.execute(sqltext)
			end if
			If unreplyback2="2" Then
				sqltext="Update sort5_gate set unback2day="&unreplyback2day&" where sort5=" & ord
				conn.execute(sqltext)
			end if
			If unsalesback="2" Then
				sqltext="Update sort5_gate set salesbackday="&TipsPerDaylist&" where sort5=" & ord
				conn.execute(sqltext)
			end if
			rs.movenext
		Loop
		rs.close
		set rs = nothing
		If Err.number<>0 Then
			conn.rollbacktrans
			Response.write "<script>alert('保存失败！');history.back(-1);</script>"
			conn.rollbacktrans
			Call db_close() : Response.end
		else
			conn.CommitTrans
			Response.write "<script>alert('批量修改成功！');try{window.opener.location.reload();}catch(e){};window.close();</script>"
		end if
		call db_close : Response.end
	end sub
	sub savegjset(ords)
		Dim f_i,fvalue
		For f_i=1 To 100
			execute("fvalue=request(""reply"&f_i&""")")
			If Len(fvalue&"")=0 Then fvalue=-1
			execute("fvalue=request(""reply"&f_i&""")")
			If fvalue="-1" Then
				execute("fvalue=request(""reply"&f_i&""")")
				If conn.execute("select top 1 * from sort5list where sort5=" & ords & " and gate2=" & f_i ).eof=False Then
					conn.execute("update sort5list set del=2 where sort5=" & ords & "and gate2=" & f_i)
				end if
			ElseIf isnumeric(fvalue) then
				If conn.execute("select top 1 * from sort5list where sort5=" & ords & " and gate2=" & f_i ).eof=False Then
					conn.execute("update sort5list set del=1,days=" & fvalue & " where sort5=" & ords & "and gate2=" & f_i)
				else
					conn.execute("insert into sort5list(sort5,gate2,days,del) values(" & ords & "," & f_i & "," & fvalue & ",1)")
				end if
			end if
		next
		Dim replycommon,replypause
		replycommon=request("replycommon")
		replypause=request("replypause")
		If Len(replycommon&"")=0 Then replycommon=0
		If Len(replypause&"")=0 Then replypause=0
		If conn.execute("select top 1 * from sort5list where sort5=" & ords & " and gate2=9998" ).eof=False Then
			conn.execute("update sort5list set del=1,days=" & replycommon & " where sort5=" & ords & "and gate2=9998")
		else
			conn.execute("insert into sort5list(sort5,gate2,days,del) values(" & ords & ",9998," & replycommon & ",1)")
		end if
		If conn.execute("select top 1 * from sort5list where sort5=" & ords & " and gate2=9999" ).eof=False Then
			conn.execute("update sort5list set del=1,days=" & replypause & " where sort5=" & ords & "and gate2=9999")
		else
			conn.execute("insert into sort5list(sort5,gate2,days,del) values(" & ords & ",9999," & replypause & ",1)")
		end if
	end sub
	Sub savesort_his(ord)
		Dim v
		v=getIP()
		sqltext="insert into sort5_his(id,ord,sort1,sort2,gate2,time1,time2,num1,jf,mustHas,AutoNext,mustContentType,mustContent,mustRole,mustzdy,mustkz_zdy,perSuccess,unautoback,unback," & _
		"protect,unreplyback1,unreplyback2,unsalesback,stayback,staydays,maxback,maxbackdays,canRemind,Reminddays,cateid,del,op,ip,opdate)" & _
		"select top 1 id,ord,sort1,sort2,gate2,time1,time2,num1,jf,mustHas,AutoNext,mustContentType,mustContent,mustRole,mustzdy,mustkz_zdy,perSuccess,unautoback,unback," & _
		"protect,unreplyback1,unreplyback2,unsalesback,stayback,staydays,maxback,maxbackdays,canRemind,Reminddays,cateid,del,"&session("personzbintel2007")&",'"&v&"',getdate() from sort5 where ord="&ord&""
		conn.execute(sqltext)
	end sub
	Response.write "     </td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	
%>
