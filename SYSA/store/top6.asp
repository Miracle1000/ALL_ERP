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
	
	Dim sc4Json
	Sub InitScriptControl
		If Not isEmpty(sc4Json) Then Exit Sub
		Set sc4Json = Server.CreateObject("MSScriptControl.ScriptControl")
		sc4Json.Language = "JavaScript"
		sc4Json.AddCode "var itemTemp=null;function getJSArray(arr, index){itemTemp=arr[index];}"
		sc4Json.AddCode "var AttrValue='';function getJSAttrValue(o, index){AttrValue='';var i=0;for (var k in o) {if(i==index){AttrValue= k + ':'+o[k];break;}; i++;}}"
'sc4Json.AddCode "var itemTemp=null;function getJSArray(arr, index){itemTemp=arr[index];}"
	end sub
	Function getJSONObject(strJSON)
		sc4Json.AddCode "var jsonObject = " & strJSON
		Set getJSONObject = sc4Json.CodeObject.jsonObject
	end function
	function getJSAttrItem(obj,index)
		on error resume next
		sc4Json.Run "getJSAttrValue",obj, index
		getJSAttrItem = sc4Json.CodeObject.AttrValue
		If Err.number=0 Then Exit Function
		getJSAttrItem = ""
	end function
	Function isOpenMoreUnitAttr
		isOpenMoreUnitAttr =(conn.execute("select nvalue from home_usConfig where name='UnitAttributeTactics' and nvalue=1 ").eof=false)
	end function
	function GetFormulaAttrValue(mvttn, tmpformula, NumberValue , numberlimit)
		Dim r : r =eval(replace(tmpformula ,mvttn, "1"))
		If CDbl(r)=0 Then GetFormulaAttrValue = 0 : Exit Function
		Dim mv: mv = cdbl(NumberValue) / cdbl(r)
		GetFormulaAttrValue = FormatNumber(mv ,numberlimit , -1,0 , 0)
'Dim mv: mv = cdbl(NumberValue) / cdbl(r)
	end function
	Function LoadMoreUnit(showType ,commUnitAttr , rowindex, NumberValue , numberlimit)
		If commUnitAttr&""="" Then LoadMoreUnit = "" : Exit Function
		Call InitScriptControl()
		Dim obj : Set obj = getJSONObject(commUnitAttr)
		dim formula : formula = obj.formula
		dim o : Set o = obj.v
		Dim r : r = ""
		Dim s : s = ""
		Dim i ,ss
		Dim v
		Dim k
		Dim varry
		Dim attrName
		Dim canEdit
		Dim defv : defv = 0
		Dim editDefV : editDefV = 0
		If Len(NumberValue)=0 Then NumberValue=0
		Dim canEditAttr : canEditAttr = ""
		If showType = 1 Or showType = 2 Or showType = 0 Then
			Dim mV : mV = 0
			For i=0 To 2
				s = getJSAttrItem(o,i)
				If len(s)=0 Then Exit For
				varry = split(s,":")
				v = varry(ubound(varry))
				canEdit = InStr(v,"G")<1
				If canEdit Then
					varry(ubound(varry)) = "???"
					canEditAttr =Replace(join(varry ,":") , ":???" ,"")
					mV = replace(v ,"G", "")*1
				end if
			next
			If CDbl(NumberValue) > 0 Or mV = 0 Then
				Dim tmpformula: tmpformula = replace(formula ,"π", "3.140000")
				tmpformula = split(tmpformula ,"=")(1)
				Dim mAttrName : mAttrName = ""
				For i=0 To 2
					s = getJSAttrItem(o,i)
					If len(s)=0 Then Exit For
					varry = split(s,":")
					v = varry(ubound(varry))
					varry(ubound(varry)) = "???"
					k = Replace(join(varry ,":") , ":???" ,"")
					ss = split(k ,"_")
					attrName = ss(ubound(ss))
					defv = replace(v ,"G", "")*1
					if k <> canEditAttr Then
						If defv=0 Then defv = 1
						tmpformula = replace(tmpformula , attrName, defv)
					else
						mAttrName = attrName
					end if
				next
				editDefV = GetFormulaAttrValue(mAttrName, tmpformula, NumberValue , numberlimit)
			end if
		end if
		For i=0 To 2
			s = getJSAttrItem(o,i)
			If len(s)=0 Then Exit For
			varry = split(s,":")
			v = varry(ubound(varry))
			varry(ubound(varry)) = "???"
			k = Replace(join(varry ,":") , ":???" ,"")
			ss = split(k ,"_")
			attrName = ss(ubound(ss))
			ss(ubound(ss)) = "???"
			Dim formulaAttr :  formulaAttr = Replace(join(ss ,"_") , "_???" ,"")
			canEdit = InStr(v,"G")<1
			defv = replace(v ,"G", "")*1
			If len(canEditAttr)>0 And canEditAttr =k Then
				If editDefV<>0 Then defv = editDefV
			ElseIf CDbl(NumberValue)>0 And CDbl(defv)=0 Then
				defv = 1
			end if
			defv = FormatNumber(defv , numberlimit , -1,0 , 0)
			defv = 1
			Select Case showType
			Case 0 :
			r = r & "<div style='padding-bottom:1px;padding-top:1px'>"
'Case 0 :
			r = r & formulaAttr & "：" & defv
			r = r & "</div>"
			Case 1 :
			r = r & "<div style='padding-bottom:1px;padding-top:1px'>"
'Case 1 :
			r = r & formulaAttr & "：<input uitype='numberbox' class='cell_" & rowindex & "' "
			r = r & " formula='" + formula + "' vttk='" + k + "'  vttn='" + attrName + "'  "
'r = r & formulaAttr & "：<input uitype='numberbox' class='cell_" & rowindex & "' "
			If canEdit =False Then
				r = r & "readonly vttr='G' "
			else
				r = r & " vttr='' "
			end if
			r = r & " style='width:55%;"
			If canEdit =False Then r = r &"color:#aaa;"
			r = r & " ' name='UnitFormula_"& attrName & "_" & rowindex &"' id='UnitFormula_" & attrName & "_" & rowindex &"' "
			If canEdit Then r = r & " onfocus=if(value==defaultValue){value='';this.style.color='#000'} "
			r = r & " onkeyup=formatData(this,'number');checkDot('UnitFormula_" & attrName & "_" & rowindex &"','"& numberlimit &"') "
			r = r & " onblur=if(!value){value=defaultValue;this.style.color='#000'};try{GetCurrFormulaInfoValue(this," & rowindex & ")}catch(e){}; "
			r = r & " onpropertychange=try{formatData(this,'number');GetCurrFormulaInfoValue(this," & rowindex & ")}catch(e){};  "
			r = r & " dataType='Limit' min='1' max='100'  msg='不能为空' value='" & defv & "' type='text'>"
			r = r & "</div>"
			Case 2 :
			If canEdit=false Then defv = "G" & defv
			If len(r)>1 Then r = r &","
			r = r & "'" & formulaAttr &"_" & attrName & "':'" & defv & "'"
			Case 3 :
			r = r & formulaAttr & "：" & defv & " "
			case 4 :
			if len(r)>0 then r = r &"<br>"
			r = r & formulaAttr & "：" & defv & " "
			Case 5 :
			r = r & "<div class='zb-input-row'>"
'Case 5 :
			r = r & formulaAttr & "：<input fielduitype='text' type='number' placeholder='点击输入' value='"& defv &"' dot='number' "
			r = r & " name='UnitFormula_"& attrName & "_" & rowindex &"' id='UnitFormula_" & attrName & "_" & rowindex &"' "
			r = r & " cap='"& formulaAttr &"' min='0.000001' max='100000000' dbname='UnitFormula_"& attrName & "_" & rowindex &"' post='1' dbtype='number' required='required' "
			r = r & " formula='" + formula + "' vttk='" + k + "'  vttn='" + attrName + "' "
			If canEdit =False Then
				r = r & " readonly='true' disabled vttr='G' "
			else
				r = r & " vttr='' "
			end if
			r = r & " style='width:60%;background-position:98% center; background-size: 18px 18px; background-repeat: no-repeat;"
			r = r & " vttr='' "
			If canEdit =False Then r = r &"color:#aaa;"
			r = r & "' uitype='bill.action.contract.UnitAttrChange' maxlength='50' > <span class='notnull'>&nbsp;*</span>"
			r = r & "</div>"
			End Select
		next
		If showType=2 and Len(r)> 0 Then
			r = "{'formula':'"& formula & "','v':{" + r + "}}"
'If showType=2 and Len(r)> 0 Then
		elseif showType=4 then
			r = "<div class='sub-field'>"& r &"</div>"
'elseif showType=4 then
		elseif showType=5 then
			r = r &"<input fielduitype='hidden' type='hidden' post='1' dbtype='hidden' required='required' dbname='commUnitAttr' name='commUnitAttr_"& rowindex &"' id='commUnitAttr' value="& LoadMoreUnit(2 ,commUnitAttr , rowindex, NumberValue , numberlimit) &">"
		end if
		LoadMoreUnit = r
	end function
	Function GetDefUnitGroup(GroupID , NotExistsSql)
		Dim cmdtext , mSql , unitgp
		if GroupID&""="" then GroupID = 0
		If Len(NotExistsSql)>0 Then mSql = " and u.ord not in ("& NotExistsSql &")"
		cmdtext = "select id from ( " &_
		" select distinct s.id , s.sort1 "&_
		" from erp_comm_UnitGroup s "&_
		" inner join ErpUnits u on u.unitgp=s.id and isnull(s.stoped,0)=0 and isnull(u.stoped,0)=0 "&_
		" where 1=1 "& mSql &_
		" ) a order by sort1 desc "
		unitgp =sdk.getSqlValue(cmdtext)
		If unitgp&""="" Then unitgp = 0
		If unitgp = 0 Then unitgp = sdk.getSqlValue("select id from erp_comm_UnitGroup where isnull(stoped,0)=0 order by sort1 desc")
'If unitgp&""="" Then unitgp = 0
		GetDefUnitGroup = unitgp
	end function
	Function GetDefUnit(GroupID , NotExistsSql)
		Dim cmdtext , mSql , unit
		unit = 0
		if GroupID&""="" then GroupID = 0
		If Len(NotExistsSql)>0 Then mSql = " and ord not in ("& NotExistsSql &")"
		cmdtext = " select top 1 ord from ErpUnits where isnull(stoped,0)=0 and unitgp="& GroupID & mSql & "  order by main desc, gate1 desc "
		unit = sdk.getSqlValue(cmdtext)
		If unit&""="" Then unit = 0
		If unit = 0 Then unit = sdk.getSqlValue("select top 1 ord from ErpUnits where unitgp="& GroupID &" and isnull(stoped,0)=0 order by main desc, gate1 desc ")
'If unit&""="" Then unit = 0
		GetDefUnit = unit
	end function
	Function LoadGroupHtml(ShowType , RowIndex , ProductID, defUnitGroupID)
		Dim rs1 ,sql1 , s ,sHtml : sHtml= ""
		Select case ShowType
		Case "select" :
		sHtml = "<select name='unitgp_0_"& RowIndex &"' onchange='ChangeGroup(this,"& RowIndex &" , "& ProductID &")'>"
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select id,name from erp_comm_UnitGroup where  isnull(stoped,0)=0 and exists(select 1 from erp_comm_unitInfo a inner join sortonehy s on s.ord=a.unitid and isnull(s.isstop,0)=0 where a.unitgp=erp_comm_UnitGroup.id) order by sort1 desc "
		rs1.open sql1,conn,1,1
		while rs1.eof=False
			s = ""
			If defUnitGroupID = rs1("id") Then s = " selected "
			sHtml = sHtml &"<option value="& rs1("id") &" "& s &">"& rs1("name") &"</option>"
			rs1.movenext
		wend
		rs1.close
		sHtml = sHtml &"</select>"
		End Select
		LoadGroupHtml = sHtml
	end function
	Function LoadUnitHtml(ShowType , RowIndex ,GroupID, defUnit,disabled)
		Dim sHtml, rs1 ,sql1 , s
		if GroupID&""="" then GroupID = 0
		Select Case ShowType
		Case "select" :
		sHtml = "<select "&disabled&" class='UnitCelue' name='unit_0_"& RowIndex &"' onchange='ChangeUnit(this,"& RowIndex &"); jQuery("".baseUnitFont"").text(jQuery(""#unitDiv_0_"" + jQuery(""#baseUnitInput"").val()).find(""option:selected"").text());'>"
'Case "select" :
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select ord,sort1 from ErpUnits where unitgp="& GroupID &" and isnull(stoped,0) =0  order by main desc, gate1 desc "
		rs1.open sql1,conn,1,1
		while rs1.eof=False
			s = ""
			If defUnit = rs1("ord") Then s = " selected "
			sHtml = sHtml &"<option value="& rs1("ord") &" "& s &">"& sdk.base64.Utf8CharHtmlConvert(rs1("sort1")) &"</option>"
			rs1.movenext
		wend
		rs1.close
		sHtml = sHtml &"</select>"
		End Select
		LoadUnitHtml = sHtml
	end function
	Function LoadUnitAttrHtml(ShowType , RowIndex , ProductID , GroupID, ByRef UnitAttr)
		Dim sHtml, rs2 ,sql2 , s ,i
		if GroupID&""="" then GroupID = 0
		Select case ShowType
		Case "select" :
		set rs2=server.CreateObject("adodb.recordset")
		sql2="select id,name from erp_comm_UnitGroupAttr where isNull(Stoped,0)=0 and unitgp="& GroupID &" order by gate1 desc"
		rs2.open sql2,conn,3,1
		If rs2.eof=False Then
			sHtml = "<select name='unitAttr_"& RowIndex &"' id='unitAttr_"& RowIndex &"' onChange='ChangeUnitAttr(this,"& RowIndex &" ,"& ProductID &")'  dataType='Limit' min='1' max='100' msg='请选择单位属性'>"
			sHtml = sHtml &"<option value=0></option>"
			i = 0
			do until rs2.eof
				s = ""
				If UnitAttr = rs2("id") Or (UnitAttr=0 And i=0) Then s = " selected "
				sHtml = sHtml &"<option value="& rs2("id") &" "& s &">"& rs2("name") &"</option>"
				If UnitAttr = 0 Then UnitAttr = rs2("id")
				i = i+1
'If UnitAttr = 0 Then UnitAttr = rs2("id")
				rs2.movenext
			Loop
			sHtml = sHtml &"</select>"
		end if
		rs2.close
		set rs2=Nothing
		Case "readonly" :
		Set rs2 = conn.execute("select b.name from erp_comm_unitAttrValue a inner join erp_comm_UnitGroupAttr b on b.id=a.groupattr where a.ord= "& ProductID &" and a.unitid =" & UnitAttr)
		If rs2.eof=False Then
			sHtml=rs2(0).value
		end if
		rs2.close
		End Select
		LoadUnitAttrHtml = sHtml
	end function
	Function LoadFormulaParameter(ShowType , RowIndex ,ProductID, UnitAttr ,numberlimit )
		Dim sHtml , commUnitAttr
		If UnitAttr>0 Then
			Select case ShowType
			Case "input" :
			commUnitAttr = GetUnitGroupFormulaAttr(ProductID, UnitAttr ,false)
			sHtml= LoadMoreUnit(1 ,commUnitAttr , RowIndex , 0, numberlimit)
			Case "readonly" :
			commUnitAttr =GetUnitGroupFormulaAttr(ProductID, UnitAttr ,false)
			sHtml= LoadMoreUnit(0 ,commUnitAttr , ProductID , 0, numberlimit)
			End Select
		end if
		LoadFormulaParameter  = sHtml
	end function
	Function GetProductGroupAttrID(ProductID , unit)
		Dim GroupAttr
		if len(ProductID)>0 and  len(unit)>0 then
			GroupAttr = sdk.getSqlValue("select GroupAttr from erp_comm_unitAttrValue where ord=" & ProductID & " and unitid="& Unit,0)
		end if
		If GroupAttr &""="" Then GroupAttr = 0
		GetProductGroupAttrID = GroupAttr
	end function
	Function GetCommUnitAttr(ProductID , unit)
		GetCommUnitAttr = GetUnitGroupFormulaAttr(ProductID, unit , true)
	end function
	Function loadMoreUnitInit(ProductID ,Unit , rowindex ,NumberValue ,numberlimit)
		loadMoreUnitInit = loadMoreUnitByNum(1, ProductID ,Unit , rowindex ,NumberValue ,numberlimit)
	end function
	Function loadMoreUnitByNum(showType, ProductID ,Unit , rowindex ,NumberValue ,numberlimit)
		Dim commUnitAttr : commUnitAttr =GetCommUnitAttr(ProductID , unit)
		Dim r : r= LoadMoreUnit(showType ,commUnitAttr , rowindex , NumberValue, numberlimit)
		loadMoreUnitByNum = r
	end function
	Function ApplyMoreUnit(ReturnType , ProductID, OldUnit, NewUnit, Num ,rowindex, ByRef NumberValue)
		Dim UnitAttrHtml : UnitAttrHtml = ""
		NumberValue = 0
		Dim dt , GroupAttr
		Set dt = ConvertUnit(ProductID, OldUnit, NewUnit, Num)
		if dt.eof=False Then
			NumberValue =dt("num").value
			GroupAttr = dt("GroupAttr").value
			If ReturnType<2 Then
				UnitAttrHtml = GetUnitGroupFormulaAttr(ProductID, NewUnit ,True)
			end if
		end if
		ApplyMoreUnit = UnitAttrHtml
	end function
	Function ConvertUnit(ProductID, OldUnit, NewUnit, Num)
		dim cmdText : cmdText = "select cast(a.bl as float) /cast(b.bl as float)  as nbl , "&_
		" (cast(" & Num & " as float) * cast(a.bl as float) /cast(b.bl as float)  ) as num ,  "&_
		"  isnull(c.formula,'') as formula , isnull(c.id,0) as GroupAttr "&_
		" from erp_comm_unitRelation a  "&_
		" inner join erp_comm_unitRelation b on a.ord=b.ord and b.unit = " & NewUnit &_
		" inner join ErpUnits u on u.ord = b.unit "&_
		" left join erp_comm_UnitGroupAttr c on c.unitgp = u.unitgp  "&_
		" where a.ord =" & ProductID & " and a.unit = " & OldUnit
		Set ConvertUnit = conn.execute(cmdText)
	end function
	Function GetUnitGroupFormulaAttr(ProductID, GroupAttr , isApply)
		Dim currunit, r , dr ,num1_dot: r = ""
		dim mGroupAttr : mGroupAttr = GroupAttr
		currunit=0
		num1_dot = conn.execute("select num1 from setjm3 where ord=88")(0)
		if mGroupAttr = 0 Then  GetUnitGroupFormulaAttr = r : Exit Function
		Dim cmdText : cmdText = "select a.name, a.formulaAttr , isnull(b.v,0) as v , c.formula "&_
		"  from erp_comm_UnitGroupFormulaAttr a "&_
		"  left join erp_comm_unitAttrValue b on b.ord=" & ProductID & " and b.GroupAttr = a.GroupAttrID and b.parameter = a.name and ("& currunit &"=0 or "& currunit &"=b.unitid) "&_
		"  left join erp_comm_UnitGroupAttr c on c.id = a.GroupAttrID "&_
		"  where a.GroupAttrID=" & mGroupAttr & " and a.hided=0 "
		set dr = conn.execute(cmdText)
		if dr.eof=False Then
			Dim  formula: formula = ""
			While dr.eof=False
				formulaAttr = dr("formulaAttr")
				attrName = dr("name")
				v = CDbl(dr("v"))
				If CDbl(v) > 0 Then
					defv = FormatNumber(v , num1_dot ,-1,0,0)
'If CDbl(v) > 0 Then
				else
					defv = "0"
				end if
				Dim canEdit : canEdit = (v=0)
				if len(formula)= 0 Then formula = dr("formula")
				If Len(r)>0 Then r = r & ","
				Dim vttr : vttr = ""
				If canEdit = False And isApply Then vttr = "G"
				r = r &  "'" & formulaAttr & "_" & attrName & "':'" & vttr & defv & "'"
				dr.movenext
			wend
			if Len(r)> 0 Then r = "{'formula':'"+ formula + "','v':{" + r + "}}"
			dr.movenext
		end if
		dr.close
		GetUnitGroupFormulaAttr = r
	end function
	Function saveFormulaAttr(ProductID ,NewUnit, rowindex)
		Dim GroupAttr : GroupAttr =  GetProductGroupAttrID(ProductID , NewUnit)
		if GroupAttr = 0 Then  saveFormulaAttr = "" : Exit Function
		Dim jsonstr : jsonstr = ""
		Dim cmdText : cmdText = "select a.name, a.formulaAttr , isnull(b.v,0) as v , c.formula "&_
		"  from erp_comm_UnitGroupFormulaAttr a "&_
		"  left join erp_comm_unitAttrValue b on b.ord=" & ProductID & " AND b.unitid = "& NewUnit &" and b.parameter = a.name "&_
		"  left join erp_comm_UnitGroupAttr c on c.id = a.GroupAttrID "&_
		"  where a.GroupAttrID=" & GroupAttr & " and a.hided=0 "
		set dr = conn.execute(cmdText)
		if dr.eof=False Then
			Dim formula : formula = ""
			While dr.eof=False
				If len(formula)=0 Then formula = dr("formula").value
				Dim attrName : attrName = dr("name")
				Dim formulaAttr : formulaAttr = dr("formulaAttr")
				Dim defv  : defv = request("UnitFormula_"& attrName & "_" & rowindex &"")
				If defv&""="" Then defv = "0"
				If CDbl(dr("v").value)<>0 Then  defv = "G"& defv
				If len(jsonstr)>1 Then jsonstr = jsonstr &","
				jsonstr = jsonstr & "'" & formulaAttr &"_" & attrName & "':'" & defv & "'"
				dr.movenext
			wend
			if Len(jsonstr)> 0 Then jsonstr = "{'formula':'"& formula & "','v':{" + jsonstr + "}}"
			dr.movenext
		end if
		dr.close
		saveFormulaAttr = jsonstr
	end function
	Function OpenCGMainUnit()
		OpenCGMainUnit = sdk.getSqlValue("select isnull(nvalue,0) nvalue from home_usConfig where name='CGMainUnitTactics' and isnull(uid,0)=0" , 0)&""="1"
	end function
	Function ShowCGMainUnit(fromtype)
		ShowCGMainUnit = OpenCGMainUnit() and (fromtype&""="1" or fromtype&""="2" or fromtype&""="3" or fromtype&""="5")
	end function
	Function GetProductPhXlhManage(ord,unit)
		dim rs, rs2, phManage, cpyxqNum, cpyxqUnit, cpyxqHours, xlhManage, cpyxqUintFlag
		dim arrRet(2)
		If ord&"" = "" Then ord = 0
		If unit&"" = "" Then unit = 0
		Set rs = conn.execute("select phManage,cpyxqNum,cpyxqUnit from product WITH(NOLOCK) where ord="& ord)
		If rs.eof = False Then
			phManage = rs("phManage") : cpyxqNum = rs("cpyxqNum") : cpyxqUnit = rs("cpyxqUnit")
			Set rs2 = conn.execute("select top 1 isnull(xlhManage,0) xlhManage from jiage WITH(NOLOCK) where product="& ord &" and unit="& unit &" order by isnull(xlhManage,0) desc")
			If rs2.eof = False Then
				xlhManage = rs2("xlhManage")
			end if
			rs2.close
			Set rs2 = Nothing
		end if
		rs.close
		set rs = nothing
		If phManage&"" = "" Then phManage = 0
		If xlhManage&"" = "" Then xlhManage = 0
		If cpyxqUnit&"" = "" Then cpyxqUnit = 2
		arrRet(0) = phManage
		arrRet(1) = xlhManage
		if cpyxqNum&""<>"" then
			Select Case cpyxqUnit&""
			Case "2" : cpyxqUintFlag = "d"
			Case "3" : cpyxqUintFlag = "w"
			Case "4" : cpyxqUintFlag = "m"
			Case "5" : cpyxqUintFlag = "y"
			End Select
			arrRet(2) = cpyxqNum &"|"& cpyxqUintFlag
		else
			arrRet(2) = ""
		end if
		GetProductPhXlhManage = arrRet
	end function
	Function dateYxqSet(currType, dateSc, dateYx, cpyxqHours)
		dim arr_cpyxq, cpyxqNum, cpyxqUintFlag, ret
		ret = ""
		if currType&"" = "datesc" then
			If dateSc&""<>"" and dateYx&""="" and cpyxqHours&""<>"" Then
				arr_cpyxq = split(cpyxqHours&"","|")
				cpyxqNum = arr_cpyxq(0) : cpyxqUintFlag = arr_cpyxq(1)
				Select Case cpyxqUintFlag
				Case "w" : cpyxqUintFlag = "ww"
				Case "y" : cpyxqUintFlag = "yyyy"
				End Select
				If cpyxqNum&""<>"" Then
					ret = dateadd("d",-1,dateadd(cpyxqUintFlag,cpyxqNum,dateSc))
'If cpyxqNum&""<>"" Then
				end if
			end if
		end if
		dateYxqSet = ret
	end function
	Function CheckKuXlhExists(xlh, flag)
		dim rs, ret, sql
		ret = False
		if trim(xlh&"")<>"" then
			xlh = trim(xlh&"")
			sql = "select count(1) num1 from ( "&_
			"  select 1 as num1 from ku WITH(NOLOCK) where (isnull(num2,0)+isnull(locknum,0))>0 and xlh='"& replace(xlh&"","'","''") &"'  "&_
			"sql = ""select count(1) num1 from ( ""&_"
			union all  &_
			"  select 1 as num1 from kuinlist a WITH(NOLOCK) inner join kuin b WITH(NOLOCK) on a.kuin=b.ord and b.del in(1,7) and a.del in(1,7)  "&_
			"          and b.complete1=3 AND b.sort1 NOT IN(2,3,6,7) and cast(a.xlh as nvarchar(max))='"& replace(xlh&"","'","''") &"' "&_
			"          AND NOT EXISTS(SELECT TOP 1 1 FROM kuhclist WITH(NOLOCK) WHERE del=1 AND kuinlist=a.id) "&_
			") t "
			set rs = conn.execute(sql)
			If rs.eof = False Then
				if rs("num1")>flag then ret = True
			end if
			rs.close
			set rs = nothing
		end if
		CheckKuXlhExists = ret
	end function
	Function CheckKuinXlhExists(kuin)
		dim ret, sql
		ret = False
		if kuin&""<>"" and kuin&""<>"0" then
			sql = "SELECT TOP 1 1  FROM kuinlist kl WITH(NOLOCK)  "&_
			"   inner join S2_SerialNumberRelation s2 on s2.ListID=kl.id "&_
			"   inner join M2_SerialNumberList ml2 on ml2.id = s2.SerialID  "&_
			"    inner join kuin k WITH(NOLOCK) on kl.kuin=k.ord   "&_
			"   where  k.complete1=3 AND kl.kuin in("& kuin &")  "&_
			"        AND CAST(kl.xlh AS VARCHAR(MAX))<>''   "&_
			"       AND EXISTS( "&_
			"           SELECT TOP 1 1 FROM ku WITH(NOLOCK)  "&_
			"           inner join S2_SerialNumberRelation s2 on s2.ListID=ISNULL(kuinlist,0) and ISNULL(kuinlist,0)<>kl.id  "&_
			"           inner join M2_SerialNumberList ml on ml.id = s2.SerialID and ml.SeriNum=ml2.SeriNum "&_
			"                   WHERE ord=kl.ord and (isnull(num2,0)+isnull(locknum,0))>0  "&_
			"           inner join M2_SerialNumberList ml on ml.id = s2.SerialID and ml.SeriNum=ml2.SeriNum "&_
			"                   union all  "&_
			"                   select top 1 1 as num1 from kuinlist a WITH(NOLOCK)  "&_
			"           inner join kuin b WITH(NOLOCK) on a.kuin=b.ord and b.del=1 and a.del=1  "&_
			"                           and b.complete1=3 AND b.sort1 NOT IN(2,3,6,7)  "&_
			"                           and CAST(a.xlh AS VARCHAR(MAX))=CAST(kl.xlh AS VARCHAR(MAX)) AND ISNULL(a.id,0)<>kl.id "&_
			"                           AND NOT EXISTS(SELECT TOP 1 1 FROM kuhclist WITH(NOLOCK) WHERE del=1 AND kuinlist=a.id) "&_
			"                   LEFT JOIN ( "&_
			"                           SELECT TOP 1 ctl.id FROM kuoutlist2 kl WITH(NOLOCK)   "&_
			"                           inner join contractthlist ctl WITH(NOLOCK) on ctl.kuoutlist2=kl.id  "&_
			"                           INNER JOIN kuinlist rl WITH(NOLOCK) ON rl.id=kl.kuinlist  "&_
			"                           INNER JOIN kuin r WITH(NOLOCK) ON rl.kuin=r.ord AND r.del=1 AND r.complete1=3 "&_
			"                   ) thrkmx ON thrkmx.id = a.id AND ISNULL(k.sort1,1)=2 "&_
			"                   WHERE a.ord=kl.ord  and  (ISNULL(k.sort1,1)<>2 OR (ISNULL(k.sort1,1)=2 AND thrkmx.id>0))"&_
			"           )"
			ret = (conn.execute(sql).eof = false)
		end if
		CheckKuinXlhExists = ret
	end function
	function CheckParentBillXlhStatus(billType , ids)
		dim canReset : canReset = true
		dim sqltext : sqltext= ""
		select case BillType
		case 61001
		sqltext ="select 1 "&_
		"   from kuinlist kl "&_
		"   inner join kuoutlist2 k2 on k2.id = kl.kuoutlist2 "&_
		"   inner join S2_SerialNumberRelation s2 on s2.billtype = 61001 and abs(s2.listid) = kl.id " &_
		"   inner join S2_SerialNumberRelation s3 on s3.billtype = 62001 and s3.listid = k2.id and s3.SerialID = s2.SerialID " &_
		"   where kl.kuin in ("& ids &") and s3.del=2 "
		canReset = conn.execute(sqltext).eof
		case 62001
		sqltext ="select 1 "&_
		"   from kuoutlist2 k2 "&_
		"   inner join S2_SerialNumberRelation s2 on s2.billtype = 62001 and abs(s2.listid) = k2.id " &_
		"   inner join ku k on k.id = k2.ku " &_
		"   inner join S2_SerialNumberRelation s3 on s3.billtype = 61001 and s3.listid = k.Kuinlist and s3.SerialID = s2.SerialID " &_
		"   where k2.kuout in ("& ids &") and s3.del=2 "
		canReset = conn.execute(sqltext).eof
		end select
		CheckParentBillXlhStatus = canReset
	end function
	function UpdateBillXlhStatus(billType , ids)
		dim sqltext
		sqltext = "update S2_SerialNumberRelation set BillID= abs(BillID) , ListID= abs(ListID) where BillType ="& billType &" and abs(BillID) in (" & ids &")"
		conn.execute(sqltext)
		conn.Execute("update  s3 set s3.status=1 from S2_SerialNumberRelation s2 inner join M2_SerialNumberList s3 on s3.ID=s2.SerialID where s2.billtype="& billType &" and BillID in ("&ids&")")
		select case BillType
		case 61001
		sqltext ="update s3 set s3.del=2  "&_
		"   from kuinlist kl "&_
		"   inner join kuoutlist2 k2 on k2.id = kl.kuoutlist2 "&_
		"   inner join S2_SerialNumberRelation s2 on s2.billtype = 61001 and s2.listid = kl.id " &_
		"   inner join S2_SerialNumberRelation s3 on s3.billtype = 62001 and s3.listid = k2.id and s3.SerialID = s2.SerialID " &_
		"   where kl.kuin in ("& ids &") and s3.del=1 "
		conn.execute(sqltext)
		case 62001
		sqltext ="update s3 set s3.del=2 "&_
		"   from kuoutlist2 k2 "&_
		"   inner join S2_SerialNumberRelation s2 on s2.billtype = 62001 and s2.listid = k2.id " &_
		"   inner join ku k on k.id = k2.ku " &_
		"   inner join S2_SerialNumberRelation s3 on s3.billtype = 61001 and s3.listid = k.Kuinlist and s3.SerialID = s2.SerialID " &_
		"   where k2.kuout in ("& ids &") and s3.del=1 "
		conn.execute(sqltext)
		end select
	end function
	Function CheckCkmxXlhExists(xlh, ckmxid)
		dim rs, ret, sql
		ret = false
		if trim(xlh&"")<>"" then
			xlh = trim(xlh&"")
			If ckmxid&"" = "" Then ckmxid = 0
			if ckmxid&"" = "0" then
				ret = CheckKuXlhExists(xlh, 0)
			else
				sql = "select top 1 kuinlist from ( "&_
				"   select kuinlist from ku WITH(NOLOCK) where (isnull(num2,0)+isnull(locknum,0))>0 and xlh='"& xlh &"'  "&_
				"sql = ""select top 1 kuinlist from ( ""&_"
				union all  &_
				"   select a.id from kuinlist a WITH(NOLOCK) inner join kuin b WITH(NOLOCK) on a.kuin=b.ord and b.del=1 and a.del=1  "&_
				"           and b.complete1=3 AND b.sort1 NOT IN(2,3,6,7) and cast(a.xlh as nvarchar(max))='"& xlh &"' "&_
				"           AND NOT EXISTS(SELECT TOP 1 1 FROM kuhclist WITH(NOLOCK) WHERE del=1 AND kuinlist=a.id) "&_
				") t where NOT EXISTS(SELECT TOP 1 1 FROM kuoutlist2 WITH(NOLOCK) WHERE del=1 AND xlh='"& xlh &"' and id="& ckmxid &" AND kuinlist=t.kuinlist)"
				set rs = conn.execute(sql)
				If rs.eof = False Then
					ret = True
				end if
				rs.close
				set rs = nothing
			end if
		end if
		CheckCkmxXlhExists = ret
	end function
	Function CheckThmxXlhExists(xlh, thmxid, flag)
		dim rs, ret, sql, kuoutlist2
		ret = false
		if trim(xlh&"")<>"" then
			If flag&"" = "" Then flag = 0
			If thmxid&"" = "" Then thmxid = 0
			xlh = trim(xlh&"")
			if thmxid&"" = "0" then
				ret = CheckKuXlhExists(xlh, flag)
			else
				sql = "select isnull(kuoutlist2,0) kuoutlist2 from contractthlist where id="& thmxid &" AND xlh='"& xlh &"' "
				set rs = conn.execute(sql)
				If rs.eof = False Then
					if rs("kuoutlist2")>0 then
						ret = False
					else
						ret = CheckKuXlhExists(xlh, flag)
					end if
				end if
				rs.close
				set rs = nothing
			end if
		end if
		CheckThmxXlhExists = ret
	end function
	Function isOpenProductAttr
		isOpenProductAttr = (ZBRuntime.MC(213104) and conn.execute("select nvalue from home_usConfig where name='ProductAttributeTactics' and nvalue=1 ").eof=false)
	end function
	function ProductAttrWidth(cft)
		ProductAttrWidth = sdk.getSqlValue("select isnull(max(cnt),0) from (select count(1) cnt from Shop_GoodsAttr where pid>0 group by pid) a " , 0 ) * cft
	end function
	function ExistsProductAttribute(ProductID , showType)
		dim sqltext
		sqltext= "select top 2 st.id ,st.title , st.isTiled , (select count(1) from Shop_GoodsAttr where pid = 0 and proCategory = m.RootId) as fcnt "&_
		"  from product p  "&_
		"  inner join menu m on m.id = p.sort1 "&_
		"  inner join Shop_GoodsAttr st on st.proCategory = m.RootId and st.pid = 0 and ("& showType &"<>2 or st.isStop=0) "&_
		"  where p.ord = "& ProductID &" and exists(select 1 from Shop_GoodsAttr where pid=st.id and ("& showType &"<>2 or isStop=0) ) "
		ExistsProductAttribute = (conn.execute(sqltext).eof=false)
	end function
	function LoadProductAttribute(BillType , BillListType , BillID, listID , ProductID , NumInputName , numberlimit , rowindex , showType)
		dim rs , rs2, rsv, sqltext, fcnt , AttrIDs , firstID , hasOld
		sqltext = "select distinct v.AttrID, v.Inx "&_
		"      from [sys_sale_ProductAttrGroup] g  "&_
		"      inner join [sys_sale_ProductAttrValue] v on v.GroupID = g.id "&_
		"      where g.BillType = " & BillType &" and g.BillListType = " & BillListType &"  and g.BillId =  " & BillID &"  and g.listid =  " & listID &" order by v.Inx "
		fcnt= 0
		AttrIDs = "0"
		firstID = 0
		hasOld = false
		set rs = conn.execute(sqltext)
		if rs.eof=false then
			while rs.eof = false
				AttrIDs = AttrIDs &"," & rs("AttrID").value
				if firstID = 0 then firstID = rs("AttrID").value
				fcnt = fcnt + 1
'if firstID = 0 then firstID = rs("AttrID").value
				hasOld = true
				rs.movenext
			wend
		end if
		rs.close
		if fcnt = 0 or showType<>3 then
			sqltext = "select top 2 st.id ,st.title , st.isTiled , (select count(1) from Shop_GoodsAttr where pid = 0 and proCategory = m.RootId) as fcnt "&_
			"  from product p  "&_
			"  inner join menu m on m.id = p.sort1 "&_
			"  inner join Shop_GoodsAttr st on st.proCategory = m.RootId and st.pid = 0 and st.isStop=0 "&_
			"  where p.ord = "& ProductID &" and exists(select 1 from Shop_GoodsAttr where pid=st.id and ("& showType &"<>2 or isStop=0) ) "&_
			"  order by isTiled,st.sort desc , st.id desc"
		else
			sqltext = "select id , title , isTiled, "& fcnt &" as fcnt from Shop_GoodsAttr where id in ("& AttrIDs &") order by (case when id=" & firstID &" then 1 else 2 end) asc  "
		end if
		dim headerhtm, htm , attrhtm , i ,attrv , attrvID
		dim tbTDCss : tbTDCss = "padding-top:5px;padding-bottom:5px;text-align:center;"
'dim headerhtm, htm , attrhtm , i ,attrv , attrvID
		if showType = 3 then tbTDCss = tbTDCss & "border-bottom:#C0CCDD 1px solid;border-left:#C0CCDD 1px solid;border-right:#C0CCDD 1px solid;"
'dim headerhtm, htm , attrhtm , i ,attrv , attrvID
		set rs = conn.execute(sqltext)
		if rs.eof=false then
			i = 0
			htm = ""
			headerhtm = ""
			while rs.eof=false
				fcnt = rs("fcnt").value
				if i = 0 and fcnt>=2 then
					attrvID = 0
					attrv = ""
					set rsv = conn.execute("select top 1 stv.id ,stv.title from [sys_sale_ProductAttrGroup] g "&_
					" inner join  Shop_GoodsAttr stv on stv.pid="& rs("id").value &" and charindex(','+cast(stv.id as varchar(10)) + ',',','+ g.attrs +',')>0 "&_
					"where g.BillType =   & BillType &  and g.BillListType =   & BillListType &  and g.BillId =   & BillID & and g.listid =   & listID &")
					if rsv.eof=false then
						attrv = rsv("title").value
						attrvID = rsv("id").value
					end if
					rsv.close
					if showType = 3 then
						if attrv<>"" then
							headerhtm = headerhtm & "<td style='"& tbTDCss &"border-top:#C0CCDD 1px solid;background-image:url(../images/tb_top_td_bg.gif);' class='dataCell'>"& rs("title").value &"</td>"
'if attrv<>"" then
							htm = "<td class='dataCell' style='"& tbTDCss &"background-color: white;'>"& attrv &"</td>"
'if attrv<>"" then
						end if
					else
						headerhtm = headerhtm & "<td style='"& tbTDCss &"border-top:#C0CCDD 1px solid;background-image:url(../images/tb_top_td_bg.gif);' class='dataCell'>"& rs("title").value &"</td>"
'if attrv<>"" then
						htm = htm & "<td class='dataCell' style='"& tbTDCss &"background-color: white;'><select id='ProductAttrV_v_"& rowindex &"' name='ProductAttrV_v_"& rowindex &"'>"
'if attrv<>"" then
						set rs2 = conn.execute("select id,title from Shop_GoodsAttr where pid = "&  rs("id").value &" and ("& showType &"<>2 or isStop=0) order by sort desc , id desc")
						if rs2.eof=false then
							htm = htm & "<option value='0'></option>"
							while rs2.eof=false
								dim selected : selected = ""
								if attrvID = rs2("id").value THEN selected = " selected "
								htm = htm & "<option value='"& rs2("id").value &"' " & selected &" >"& rs2("title").value &"</option>"
								rs2.MoveNext
							wend
						end if
						rs2.close
						htm = htm & "</select></td>"
					end if
					attrhtm = "<input type='hidden' name='ProductAttrV_" & rowindex &"' value="& rs("id").value &">"
				end if
				if fcnt=1 or i=1 then
					set rsv = conn.execute("select stv.id ,stv.title, g.Num1 , g.attrs from [sys_sale_ProductAttrGroup] g "&_
					" inner join  Shop_GoodsAttr stv on stv.pid="& rs("id").value &" and charindex(','+cast(stv.id as varchar(10)) + ',',','+ g.attrs +',')>0 "&_
					"where g.BillType =   & BillType &  and g.BillListType =   & BillListType &  and g.BillId =   & BillID & and g.listid =   & listID &")
					set rs2 = conn.execute("select id,title , isstop from Shop_GoodsAttr where pid = "&  rs("id").value &" and ("& showType &"<>2 or isStop=0) order by sort desc , id desc")
					if rs2.eof=false then
						attrhtm = attrhtm & "<input type='hidden' name='ProductAttrH_" & rowindex &"' value="& rs("id").value &">"
						dim n : n=0
						while rs2.eof=false
							rsv.Filter = "id=" & rs2("id").value
							attrv = ""
							if rsv.eof=false then
								attrv =formatnumber( rsv("Num1").value , numberlimit ,-1,0,0)
'if rsv.eof=false then
							end if
							if showType = 3 then
								if attrv&""<>"" then
									headerhtm = headerhtm & "<td style='"& tbTDCss &"border-top:#C0CCDD 1px solid;background-image:url(../images/tb_top_td_bg.gif);' class='dataCell' >"& rs2("title").value &"</td>"
'if attrv&""<>"" then
									htm = htm & "<td class='dataCell' style='"& tbTDCss &"background-color: white;width:45;'>"& attrv &"</td>"
'if attrv&""<>"" then
								end if
							else
								headerhtm = headerhtm & "<td style='"& tbTDCss &"border-top:#C0CCDD 1px solid;background-image:url(../images/tb_top_td_bg.gif);' class='dataCell' >"& rs2("title").value &"</td>"
'if attrv&""<>"" then
								htm = htm & "<td class='dataCell' style='"& tbTDCss &"background-color: white;'>"
'if attrv&""<>"" then
								
								htm = htm & "<input type='text' class='productattr_"& id &"' style='width:40;font-size:9pt' id='ProductAttrH_"& rs2("id").value  &"_" & rowindex &"' name='ProductAttrH_"& rs2("id").value &"_" & rowindex &"' value='"& attrv &"' "&_
								"onfocus=if(this.value==this.defaultValue){this.value='';this.style.color='#000"&_
								" onBlur=if(!this.value){this.value=this.defaultValue;this.style.color='#000';};SetCurrProductAttrValue("& id &",'"& NumInputName &"');formatData(this,'number'); "&_
								" onkeyup=formatData(this,'number');checkDot('ProductAttrH_"& rs2("id").value  &"_" & rowindex &"','"& numberlimit &"');SetCurrProductAttrValue("& id &",'"& NumInputName &"'); "&_
								" onpropertychange=formatData(this,'number');SetCurrProductAttrValue("& id &",'"& NumInputName &"');></td>"
							end if
							n = n +1
'onpropertychange=formatData(this,'number');SetCurrProductAttrValue(& id &,'& NumInputName &
							rs2.MoveNext
						wend
					end if
					rs2.close
					rsv.close
				end if
				i = i + 1
				rsv.close
				rs.movenext
			wend
		end if
		rs.close
		if len(headerhtm)>0 then
			dim tbcss : tbcss = "margin:8px;"
			if showType = 3 then tbcss = "margin-left:8px;"
'dim tbcss : tbcss = "margin:8px;"
			htm = "<table bgcolor='#C0CCDD' style='word-break:break-all;word-wrap:break-word;border-collapse:collapse;table-layout: fixed;"& tbcss &"'><tr>"& headerhtm &"</tr><tr>"&htm&"</tr></table>" & attrhtm
'dim tbcss : tbcss = "margin:8px;"
		end if
		LoadProductAttribute = htm
	end function
	function SaveProductAttr(BillType , BillListType , BillID, listID , ProductID , rowindex , num , numberlimit)
		if isOpenProductAttr =false then
			SaveProductAttr = true
			exit function
		end if
		dim rs ,sqltext, ProductAttrV , ProductAttrH
		ProductAttrV = request("ProductAttrV_" & rowindex)
		ProductAttrH = request("ProductAttrH_" & rowindex)
		if ProductAttrV&""="" then ProductAttrV = 0
		if ProductAttrH&""="" then ProductAttrH = 0
		if ProductAttrV = 0 and ProductAttrH = 0 then
			SaveProductAttr = true
			exit function
		end if
		conn.execute("delete from [sys_sale_ProductAttrValue] where GroupID in (select id from [sys_sale_ProductAttrGroup] g where g.BillType ="& BillType &" and g.BillListType ="& BillListType &"  and g.BillId ="& BillID &" and g.listid ="& listID &" )")
		conn.execute("delete from [sys_sale_ProductAttrGroup] where BillType ="& BillType &" and BillListType ="& BillListType &"  and BillId ="& BillID &" and listid ="& listID &" ")
		dim ProductAttrVV ,AttrID, ProductAttrValue , attrs , numAll
		ProductAttrVV = 0
		if ProductAttrV>0 then ProductAttrVV = request("ProductAttrV_v_"& rowindex)
		if len(ProductAttrVV&"")=0 then ProductAttrVV = 0
		if ProductAttrVV>0 then attrs = ProductAttrVV &","
		sqltext = ""
		numAll = 0
		set rs = conn.execute("select id from Shop_GoodsAttr where pid = "&  ProductAttrH &" order by sort desc , id desc")
		if rs.eof=false then
			while rs.eof=false
				AttrID = rs("id").value
				ProductAttrValue = request("ProductAttrH_"& AttrID &"_" & rowindex)
				if ProductAttrValue&""="" then ProductAttrValue = 0
				if ProductAttrValue>0 then
					if len(sqltext)>0 then sqltext = sqltext & " union all "
					sqltext = sqltext & " select " & ProductAttrValue & " as Num1 ,'" & attrs & AttrID &"' as Attrs "
					numAll = cdbl(numAll) + cdbl(ProductAttrValue)
'sqltext = sqltext & " select " & ProductAttrValue & " as Num1 ,'" & attrs & AttrID &"' as Attrs "
				end if
				rs.movenext
			wend
		end if
		rs.close
		if len(sqltext)>0 then
			sqltext = "select "& BillType &" ,"& BillListType &", "& BillID &" , "& listID &"  , a.Num1 , a.Attrs , "& ProductID &" ProductID , 1 del from (" & sqltext &") a "
			conn.execute("INSERT INTO [dbo].[sys_sale_ProductAttrGroup]([BillType],[BillListType] ,[BillId],[ListID],[Num1] ,[Attrs],[ProductID],[Del]) " & sqltext)
			sqltext = "INSERT INTO [dbo].[sys_sale_ProductAttrValue] ([GroupID] ,[AttrID]  ,[AttrValue]  ,[inx] ,[del]) " &_
			" select a.id GroupID, stv.Pid AttrID , stv.id as AttrValue , case when stv.id="& ProductAttrVV &" then 1 else 2 end inx , 1 del "&_
			" from sys_sale_ProductAttrGroup a "&_
			" inner join Shop_GoodsAttr stv on charindex(','+cast(stv.id as varchar(10)) + ',',','+ a.attrs +',')>0 "&_
			" from sys_sale_ProductAttrGroup a "&_
			" where a.BillType ="& BillType &" and a.BillListType ="& BillListType &"  and a.BillId ="& BillID &" and a.listid ="& listID &""
			conn.execute(sqltext)
		end if
		if cdbl(numAll)>0 and cdbl(formatnumber(numAll , numberlimit ,-1,0,0))<> cdbl(formatnumber(num , numberlimit ,-1,0,0)) then
			conn.execute(sqltext)
			SaveProductAttr = false
			exit function
		end if
		SaveProductAttr = true
	end function
	function UpdateListCommUnitAttr(conn, billtype , billid)
		dim MoreUnitCmdText,rs,currNum,ProductAttrBatchId  ,mnTable, mxTable,num1_dot
		num1_dot = conn.execute("select num1 from setjm3 where ord=88")(0)
		select case billtype
		case 11001 :
		mnTable = "contract"
		mxTable = "contractlist"
		case 73001 :
		mnTable = "caigou"
		mxTable = "caigoulist"
		end select
		MoreUnitCmdText = ""
		set rs = conn.execute("select cl.id, cl.ord , cl.unit,cl.num1 , isnull(cl.ProductAttrBatchId,0) ProductAttrBatchId "&_
		" from "& mxTable &" cl "&_
		" where cl."& mnTable &"=" & billid &" and exists(select 1 from erp_comm_unitAttrValue where ord = cl.ord and unitid = cl.unit)  ")
		if rs.eof=false then
			while rs.eof=false
				currNum = rs("num1").Value
				ProductAttrBatchId = rs("ProductAttrBatchId").value
				if ProductAttrBatchId>0 then
					currNum = sdk.GetSqlValue("select sum(num1) num1 from "& mxTable &" where "& mnTable &"="& billid&" and ProductAttrBatchId=" & ProductAttrBatchId,0)
				end if
				dim commUnitAttr : commUnitAttr = GetCommUnitAttr(rs("ord").Value , rs("unit").Value)
				commUnitAttr = LoadMoreUnit(2 ,commUnitAttr , 0, currNum  , num1_dot)
				if len(MoreUnitCmdText)>0 then MoreUnitCmdText = MoreUnitCmdText & " union all "
				MoreUnitCmdText = MoreUnitCmdText &" select " & rs("id").value &" id,'"& replace(commUnitAttr,"'","''") &"' commUnitAttr "
				rs.movenext
			wend
		end if
		rs.close
		if len(MoreUnitCmdText)>0 then
			conn.execute("update "& mxTable &" set "& mxTable &".commUnitAttr =a.commUnitAttr from ("& MoreUnitCmdText &") a where a.id = "& mxTable &".id ")
		end if
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
	
	Response.write "" & vbcrlf & "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">" & vbcrlf & "<html xmlns=""http://www.w3.org/1999/xhtml"">" & vbcrlf & ""
	isOpenAssUnit = (GetAssistUnitTactics() & ""= "1")
	isFixAssRat = (GetConversionUnitTactics() & ""= "1")
	isOpenProductAttrV=isOpenProductAttr
	sql="select num1 from setjm3 where ord=5430"
	set rs=conn.execute(sql)
	if not rs.eof then
		proStore=rs(0).value
	else
		proStore=0
	end if
	rs.close
	set rs=nothing
	Response.write "" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"" />" & vbcrlf & "<title>"
	set rs=nothing
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"" />" & vbcrlf & "<style>" & vbcrlf & " #cp_search{width:221px!important;}" & vbcrlf & " .top td{height:40px;}" & vbcrlf & " .nopadding32{" & vbcrlf & "     background-color:#FFF;" & vbcrlf & " }" & vbcrlf & "</style>" & vbcrlf & "<script language=""javascript"" src=""../sortcp/function.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"" src=""../inc/ptdmanger.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""javascript"" src= ""../inc/function.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""javascript"" src= ""../Script/store_function.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"" src=""../contract/formatnumber.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"" src='sczz.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write "'></script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"" src='storeselbox.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write "'></script>" & vbcrlf & "<script>" & vbcrlf & "function UnitCustomFun(sobj,ord,type,id,inx){" & vbcrlf & "    if(type==""assistUnit""){" & vbcrlf & "        var inx=sobj.id.split(""_"")[1] ;" & vbcrlf & "        var id=sobj.name.split(""_"")[1] ;" & vbcrlf & "        //var tdobj =obj.parentElement" & vbcrlf & "     var pid=ord;" & vbcrlf & "            var unit= $(""#unit2_""+inx).val();" & vbcrlf & "         var num=$(""#num2_""+id).val();" & vbcrlf & "        var assistUnit=sobj.value;" & vbcrlf & "    }" & vbcrlf & "    if(type==""num""){" & vbcrlf & "            var pid=ord;" & vbcrlf & "            var unit= $(""#unit2_""+inx).val();" & vbcrlf & "          var num=$(""#num2_""+id).val();" & vbcrlf & "        var assistUnit=$(""#AssistUnit_""+inx).val();" & vbcrlf & "    }" & vbcrlf & "    if(pid&&unit&&assistUnit&&assistUnit!=""0""){" & vbcrlf & "        var url = ""../store/CommonReturn.asp?act=assistnum&pid="" + pid + ""&unit="" + unit + ""&assistUnit="" + assistUnit + ""&num=1&stamp="" + Math.round(Math.random() * 100);" & vbcrlf & "            xmlHttp.open(""GET"", url, false);" & vbcrlf & "          xmlHttp.send(null);" & vbcrlf & "     var result = xmlHttp.responseText;" & vbcrlf & "      xmlHttp.abort();" & vbcrlf & "            window.assignBl = result;" & vbcrlf & "       $(""#AssistNum_""+id).val(FormatNumber(num * result,"
	'Response.write Application("sys.info.jsver")
	Response.write num1_dot
	Response.write "));" & vbcrlf & "       $(""#AssistNum_""+id).text(FormatNumber(num * result,"
	Response.write num1_dot
	Response.write num1_dot
	Response.write "));" & vbcrlf & "        if("""
	Response.write isFixAssRat
	Response.write """==""False""){$(""#AssistNum_""+id).removeAttr(""readonly"");} " & vbcrlf & "    }else{" & vbcrlf & "      $(""#AssistNum_""+id).attr(""readonly"",""readonly"");" & vbcrlf & "      $(""#AssistNum_""+id).val("""");" & vbcrlf & "            $(""#AssistNum_""+id).text("""");" & vbcrlf & "    }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "</script>" & vbcrlf & "<SCRIPT language=JavaScript1.2>" & vbcrlf & "// 一个简单的测试是否IE浏览器的表达式" & vbcrlf & "// 得到IE中各元素真正的位移量，即使这个元素在一个表格中" & vbcrlf & "function getIEPosX(elt) { return getIEPos(elt,""Left""); }" & vbcrlf & "function getIEPosY(elt) { return getIEPos(elt,""Top""); }" & vbcrlf & "function getIEPos(elt,which) {" & vbcrlf & " iPos = 0" & vbcrlf & " while (elt!=null) {" & vbcrlf & "  iPos += elt[""offset"" + which]" & vbcrlf & "  elt = elt.offsetParent" & vbcrlf & " }" & vbcrlf & " return iPos" & vbcrlf & "}" & vbcrlf & "// -->" & vbcrlf & "</SCRIPT>" & vbcrlf & "</head>" & vbcrlf & ""
	Function ShowXlh(rowIndex ,stype ,xlh)
		Dim html :html =""
		Select Case stype
		Case "content" :
		If Len(xlh)>0 And InStr(xlh,Chr(1))>0 Then
			html = "<a href='javascript:void(0)' onclick='ShowAllXlh("&rowIndex&")'>查看</a><div id='xlh"&rowIndex&"' style='display:none'>"&xlh&"</div>"
		else
			html = xlh
		end if
		Case Else
		html = "这里"
		End Select
		ShowXlh = html
	end function
	Response.write "" & vbcrlf & "<style>" & vbcrlf & "       .div_li li{" & vbcrlf & "             border: 1px solid #C0CCDD;" & vbcrlf & "              line-height: 26px;" & vbcrlf & "              margin: 2px;" & vbcrlf & "            float: left;" & vbcrlf & "            height: 26px;" & vbcrlf & "           text-align: center;" & vbcrlf & "             list-style-type:none;" & vbcrlf & "overflow: hidden;" & vbcrlf & "               text-overflow: ellipsis;" & vbcrlf & "                white-space: nowrap;" & vbcrlf & "            padding: 0 2px;" & vbcrlf & " }" & vbcrlf & "</style>" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href="""
	'ShowXlh = html
	Response.write sdk.GetVirPath()
	Response.write "inc/themes/default/easyui.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """/>" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href="""
	Response.write sdk.GetVirPath()
	Response.write "inc/themes/icon.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """/>" & vbcrlf & "<script type=""text/javascript"" src="""
	Response.write sdk.GetVirPath()
	Response.write "inc/jquery.easyui.min.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write " ""></script>" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "//入库详情" & vbcrlf & "function ShowAllXlh(rowIndex){" & vbcrlf & "    var xlh = $("").html();" & vbcrlf & "      var title = $(""#title""+rowIndex).html();" & vbcrlf & "  var order1 = $(""#order""+rowIndex).html();" & vbcrlf & "  var type1 = $(""#type""+rowIndex).html();" & vbcrlf & "   var wtitle = ""  【产品名称：""+ title + (order1 && order1.length>0?""   产品编号：""+order1 :"""") + (type1 && type1.length>0 ?""   产品型号：""+type1:"""") +""】"";" & vbcrlf & "  var xlhs = xlh.split(""\1"");//序列号个数" & vbcrlf & "   var html = ""<div id='target' class='div_li' style='border:1px solid #ccc;width:98%;height:98%;float:left;margin:5px;overflow:auto;cursor:default;padding-bottom:3px;'>""" & vbcrlf & "    var xlh_lis = new Array();" & vbcrlf & "      for (var i=0;i< xlhs.length ;i++ )" & vbcrlf & "      {       " & vbcrlf & "                xlh_lis[i] = ""<li style='width:100px'>""+xlhs[i]+""</li>"";" & vbcrlf & "     }" & vbcrlf & "       html = html + xlh_lis.join("""") + ""</div>"";" & vbcrlf & "  $('#w').html(html).window({" & vbcrlf & "             title:'序列号管理'+wtitle ," & vbcrlf & "             width:670," & vbcrlf & "              height:420," & vbcrlf & "             top:150+document.body.scrollTop + document.documentElement.scrollTop," & vbcrlf & "                closeable:true," & vbcrlf & "         collapsible:false," & vbcrlf & "              minimizable:false," & vbcrlf & "              maximizable:false," & vbcrlf & "              resizable:true" & vbcrlf & "  }).window('open');" & vbcrlf & "}" & vbcrlf & "//入库申请" & vbcrlf & "function checkXLH(){" & vbcrlf & "    var w = document.getElementById(""i"").value;" & vbcrlf & "       var canSubmit = true ;" & vbcrlf & "  for(var i=1; i<w; i++)" & vbcrlf & "  {" & vbcrlf & "               var xlh = document.getElementById(""xlh""+i);" & vbcrlf & "               if(xlh==null) { continue; }  //xlh为null，说明此行可能被删除了。" & vbcrlf & "                var xlhs = xlh.value;" & vbcrlf & "            if(xlhs.length>0){      " & vbcrlf & "                        var int_num = 0" & vbcrlf & "                 var num = document.getElementById(""num"" + xlh.name.replace(""xlh_"","""")).value;" & vbcrlf & "                 if (num.length==0){" & vbcrlf & "                             num = 0;" & vbcrlf & "                        }else{" & vbcrlf & "                          int_num=parseInt(num);" & vbcrlf & "                            if(int_num<parseFloat(num)){int_num = int_num + 1;}" & vbcrlf & "                     }" & vbcrlf & "                       var xlhs_num = xlhs.split(""\1"").length;//序列号个数" & vbcrlf & "                       //上级要求 序列号可以小于申请入库数量" & vbcrlf & "                   if (int_num<xlhs_num){" & vbcrlf & "                          document.getElementById(""xlhts""+i).innerHTML=""序列号个数[""+ xlhs_num +""]不能大于申请入库数量"";" & vbcrlf & "                            canSubmit = false;" & vbcrlf & "                      }else{" & vbcrlf & "                          document.getElementById(""xlhts""+i).innerHTML="""";" & vbcrlf & "                    }" & vbcrlf & "               }" & vbcrlf & "       }" & vbcrlf & "       resizeDiv();" & vbcrlf & "    return canSubmit;" & vbcrlf & "}" & vbcrlf & ""& vbcrlf &" function setContent(rowIndex){" & vbcrlf &    "    if (window.event.keyCode==13){ "& vbcrlf &        "   addxlhSQ(rowIndex , true);" & vbcrlf &     "  } "& vbcrlf & "}" & vbcrlf & vbcrlf & "function addxlhSQ(rowIndex ,isKeyDown){ "& vbcrlf &      "  var obj = document.getElementById(""xlh""+rowIndex);" & vbcrlf & "  var curr = document.getElementById(""scanxlh""+rowIndex);" & vbcrlf & "   var v = curr.value.replace(/(^\s*)|(\s*$)/g,'');" & vbcrlf & "        var oldxlh = obj.value.replace(/(^\s*)|(\s*$)/g,'');" & vbcrlf & "    var xlhs = oldxlh.split(""\1"");//序列号个数" & vbcrlf & "        if (isKeyDown ==false && v.length>0)" & vbcrlf & "  {" & vbcrlf & "               for(var i=0;i<xlhs.length;i++){" & vbcrlf & "                 if (v==xlhs[i]){return;}" & vbcrlf & "                }" & vbcrlf & "       }" & vbcrlf & "       var int_num = 0" & vbcrlf & " var num = document.getElementById(""num"" + obj.name.replace(""xlh_"","""")).value;" & vbcrlf & " if (num.length==0){num = 0;}else{int_num=parseInt(num);}" & vbcrlf & "      if (xlhs.length>=int_num && oldxlh.length>0){" & vbcrlf & "           curr.setAttribute(""canevent"" ,""1"");" & vbcrlf & "         curr.value=xlhs[xlhs.length-1];" & vbcrlf & "         document.getElementById(""xlhimg""+rowIndex).src = ""../images/percent100.png"";" &vbcrlf & " }else{" & vbcrlf & "          curr.setAttribute(""canevent"",""0"");" & vbcrlf & "          if (v.length>0)" & vbcrlf & "         {" & vbcrlf & "                       var imgid = ""00"";" & vbcrlf & "                 if (xlhs.length>=int_num){imgid = ""100"";}" & vbcrlf & "                 else if(int_num!=0){" & vbcrlf & "                            if (oldxlh.length==0)" & vbcrlf & "                              {" & vbcrlf & "                                       imgid = (parseInt(1/num * 10) >0 ? parseInt(1/num * 10) + ""0"":""10"");" & vbcrlf & "                                }else{" & vbcrlf & "                                  imgid = (parseInt((xlhs.length+1)/num * 10) >0 ? parseInt((xlhs.length+1)/num * 10) + ""0"":""10"");" & vbcrlf & "                            }" & vbcrlf & "                       }" & vbcrlf & "                       document.getElementById(""xlhimg""+rowIndex).src = ""../images/percent""+ imgid +"".png"";" & vbcrlf & "                        obj.value = oldxlh.length>0? oldxlh + ""\1"" + v : v;" & vbcrlf & "                       if (imgid==""100""){curr.setAttribute(""canevent"",""1"");}" & vbcrlf & "         }" & vbcrlf & "       }" & vbcrlf & "       if(isKeyDown){curr.select();}" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function setBlurContent(rowIndex){" & vbcrlf & "      addxlhSQ(rowIndex , false);" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "var setObjSQ = null;" & vbcrlf & "function SetAllXlhSQ(rowIndex){" & vbcrlf & " setObjSQ = document.getElementById(""xlh""+rowIndex);" & vbcrlf & "      var xlh = setObjSQ.value;" & vbcrlf & "       var title =document.getElementById(""rkmx_title_td""+rowIndex).innerText.replace(/(^\s*)|(\s*$)/g,'');" & vbcrlf & "      var order1 =document.getElementById(""rkmx_order1_td""+rowIndex)? document.getElementById(""rkmx_title_td""+rowIndex).innerText.replace(/(^\s*)|(\s*$)/g,'') : """";" & vbcrlf & "      var type1 = document.getElementById(""rkmx_type1_td""+rowIndex)? document.getElementById(""rkmx_type1_td""+rowIndex).innerText.replace(/(^\s*)|(\s*$)/g,'') : """";" & vbcrlf & " var wtitle = ""  【产品名称：""+ title + (order1.length>0?""      产品编号：""+order1 :"""") + (type1.length>0 ?""   产品型号：""+type1:"""") +""】"";" & vbcrlf & "       var xlhs = xlh.split(""\1"");//序列号个数" & vbcrlf & "   var html = ""<table style='width:100%;height:100%;'><tr><td style='width:23%;'>""" & vbcrlf & "   html += ""<div style='height:90%;margin:2px;'><textarea id='lrxlh' style='height:100%;border:1px solid #ccc;overflow:auto;cursor:default'></textarea></div>"";" & vbcrlf & "       html += ""<div style='width:100%;text-align:right;margin-right:2px;margin-top:3px;'>"";" & vbcrlf & "     html += "" <input type='button' onclick='addxlh()' class='page' value='加入'>"";" & vbcrlf & "    html += "" <input type='button' onclick='deleteaddxlh()' class='page' value='重置'>"";" & vbcrlf & " html += ""</div>""  " & vbcrlf & "        html += ""</td><td style='width:77%;'>"";" & vbcrlf & "   html += ""<div id='target' class='div_li' style='height:89%;margin:3px;margin-left:0px;border:1px solid #ccc;overflow:auto;cursor:default;padding-bottom:3px;' >""" & vbcrlf & "      var xlh_lis = new Array();" & vbcrlf & "      var num = document.getElementById(""num"" + setObjSQ.name.replace(""xlh_"","""")).value ;" & vbcrlf & "   var xlhnum = 0" & vbcrlf & "  if (xlh.length>0)" & vbcrlf & "       {" & vbcrlf & "               for (var i=0;i< xlhs.length ;i++ )" & vbcrlf & "            {       " & vbcrlf & "                        xlh_lis[i] = ""<li style='width:100px;position:relative' onmouseover='showdel(this)' onmouseout='hiddendel(this)'><img title='删除' style='width:10px;display:none;right:1px;top:1px;color:red;position:absolute' onclick='deleteli(this)' src='../images/delete.jpg'/>""+xlhs[i]+""</li>"";" & vbcrlf & "             }" & vbcrlf & "               xlhnum = xlhs.length;" & vbcrlf & "   }" & vbcrlf & "       html += xlh_lis.join("""");" & vbcrlf & " html += ""</div>"";" & vbcrlf & " html += ""<div style='width:100%;text-align:right;margin-right:10px;margin-top:5px;'>"";" & vbcrlf & "    html += "" 入库申请数量：<span class='gray'>"" + num + ""</span> "";" & vbcrlf & "   html += "" 当前序列号数量：<span id='xlhnum' class='gray'>""+ xlhnum +""</span>&nbsp;&nbsp;<input type='button' onclick='deleteallxlh()' class='page' value='清空'>"";" & vbcrlf & "  html += ""</div>"";" & vbcrlf & " html += ""</td></tr></table>"";" & vbcrlf & "" & vbcrlf & " $('#w').html(html).window({" & vbcrlf & "             title:'序列号管理'+wtitle ," & vbcrlf & "             width:730," & vbcrlf & "              height:420," & vbcrlf & "             top:150+document.body.scrollTop + document.documentElement.scrollTop," & vbcrlf & "           closeable:true," & vbcrlf & "         collapsible:false," & vbcrlf & "              minimizable:false," & vbcrlf & "              maximizable:false," & vbcrlf & "              modal:true," & vbcrlf & "             resizable:true," & vbcrlf & "         onClose:function(){" & vbcrlf & "                             var x1 = new Array();" & vbcrlf & "                           var i = 0;" & vbcrlf & "                              $(""#target"").find(""li"").each(function(){" &vbcrlf & "                                 x1[i] = $(this).text();" & vbcrlf & "                                 i++;" & vbcrlf & "                            });" & vbcrlf & "                             if (i>0)" & vbcrlf & "                                {" & vbcrlf & "                                       setObjSQ.value = x1.join(""\1"");" & vbcrlf & "                                   var imgid = ""00"";" & vbcrlf & "                                 var num = document.getElementById(""num"" + setObjSQ.name.replace(""xlh_"","""")).value;" & vbcrlf & "                                    if (num.length==0){num = 0;}" & vbcrlf & "                                    if (i>=parseInt(num)){imgid = ""100"";}" & vbcrlf & "                                     else if(parseInt(num)!=0){" & vbcrlf&_
	"imgid = (parseInt(i/num * 10)>0 ? parseInt(i/num * 10) + ""0"":""10"");" & vbcrlf & "                                 }" & vbcrlf & "document.getElementById(""xlhimg""+setObjSQ.id.replace(""xlh"","""")).src = ""../images/percent""+ imgid +"".png"";" & vbcrlf & "                                 document.getElementById(""scanxlh""+setObjSQ.id.replace(""xlh"","""")).value = x1[x1.length-1];" & vbcrlf & "                             }else{" & vbcrlf & "                                  setObjSQ.value = """";"& vbcrlf & "                                       document.getElementById(""scanxlh""+setObjSQ.id.replace(""xlh"","""")).value = """";" & vbcrlf & "                                    document.getElementById(""xlhimg""+setObjSQ.id.replace(""xlh"","""")).src = ""../images/percent100.png"";" & vbcrlf & "                               }" & vbcrlf & "               }" & vbcrlf & "       }).window('open');" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "//入库审批" & vbcrlf & "function checkAllXLH(extIndex){" & vbcrlf & " var canSubmit = true ;" & vbcrlf & "  for (var i = 0 ; i<lv.Rows.length ;  i++)" & vbcrlf & "       {" & vbcrlf & "               var v = lv.Rows[i].Cells[12+extIndex].value;" & vbcrlf & "            if (v.length>0)" & vbcrlf & "         {       " & vbcrlf & "                        var num = lv.Rows[i].Cells[8+extIndex].value;" & vbcrlf & "                   var int_num = 0;" & vbcrlf & "                        if (num.length==0){" & vbcrlf & "                             num = 0;" & vbcrlf & "                        }else{" & vbcrlf & "                          int_num=parseInt(num);" & vbcrlf & "                          if(int_num<parseFloat(num)){int_num = int_num + 1;}" & vbcrlf & "                  }" & vbcrlf & "                       var xlhs_num = v.split(""\1"").length;" & vbcrlf & "                      //序列号个数" & vbcrlf & "                    //上级要求 序列号可以小于申请入库数量" & vbcrlf & "                   if (int_num<xlhs_num)" & vbcrlf & "                   {" & vbcrlf & "                               lv.Rows[i].Cells[12+extIndex].isError = true;" & vbcrlf & "                           if (canSubmit==true)" & vbcrlf & "{   "                     & vbcrlf &                                       "  alert(""第""+(i+1)+""行[""+lv.Headers[12].innerHTML+""]列数据不合法：序列号个数[""+ xlhs_num +""]不能大于入库数量"");" & vbcrlf &                               "     lv.startIdx=(i>(lv.Rows.length-lv.RowsPerPage))?(lv.Rows.length>lv.RowsPerPage?lv.Rows.length-lv.RowsPerPage:0):i; "& vbcrlf &                                  "     if(lv.Rows[i].Cells[12+extIndex].obj)" & vbcrlf & "                                 {" & vbcrlf & "                                               var tr=lv.Rows[i].Cells[12+extIndex].obj.parentElement;" & vbcrlf & "                                         //tr.fireEvent(""onclick"");" & vbcrlf & "                                                $(tr).trigger(""click"");" & vbcrlf & "                                           lv.EditRow=tr.rowIndex;" & vbcrlf & "                                         lv.RefreshRow(lv.EditRow);" & vbcrlf & "                                 }" & vbcrlf & "                               }" & vbcrlf & "                               canSubmit = false;" & vbcrlf & "                      }" & vbcrlf & "               }" & vbcrlf & "       }" & vbcrlf & "       lv.RefreshContent();" & vbcrlf & "    return canSubmit;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "var setObjZZ = null;" & vbcrlf & "function SetAllXlhZZ(rowIndex, xlhExt, xlhNameExt,cpTitleExt,order1Ext,type1Ext,numExt){" & vbcrlf & "      setObjZZ = document.getElementById(xlhExt+rowIndex);" & vbcrlf & "    var xlh = setObjZZ.value;" & vbcrlf & "       var title = """";" & vbcrlf & "   if(document.getElementById(cpTitleExt+rowIndex)){" & vbcrlf & "               title = document.getElementById(cpTitleExt+rowIndex).innerText.replace(/(^\s*)|(\s*$)/g,'');" & vbcrlf & "   }else{" & vbcrlf & "          document.getElementById(cpTitleExt).innerText.replace(/(^\s*)|(\s*$)/g,'');" & vbcrlf & "     }" & vbcrlf & "       var order1 =document.getElementById(order1Ext+rowIndex)? document.getElementById(order1Ext+rowIndex).innerText.replace(/(^\s*)|(\s*$)/g,'') : """";" & vbcrlf & " var type1 = document.getElementById(type1Ext+rowIndex)? document.getElementById(type1Ext+rowIndex).innerText.replace(/(^\s*)|(\s*$)/g,'') : """";" & vbcrlf&_
	"   var wtitle = ""  【产品名称：""+ title + (order1.length>0?""      产品编号：""+order1 :"""") + (type1.length>0 ?""   产品型号：""+type1:"""") +""】"";" & vbcrlf & "        var xlhs = xlh.split(""\1"");//序列号个数" & vbcrlf & "   var html = ""<table style='width:100%;height:100%;'><tr><td style='width:23%;height:100%'>""" & vbcrlf & "        html += ""<div style='height:89%;margin:2px;'><textarea id='lrxlh' style='height:100%;*height:342px;border:1px solid #ccc;overflow:auto;cursor:default;box-sizing:border-box'></textarea></div>"";" & vbcrlf & "     html += ""<div style='width:100%;text-align:right;margin-right:2px;margin-top:5px;'>"";" & vbcrlf & "     html += "" <input type='button' onclick='addxlh()' class='page' value='加入'>"";" & vbcrlf & "    html += "" <input type='button' onclick='deleteaddxlh()' class='page' value='重置'>"";" & vbcrlf & "      html += ""</div>""  " & vbcrlf & "        html += ""</td><td style='width:77%;height:100%;'>"";" & vbcrlf & "       html += ""<div id='target' class='div_li' style='height:89%;margin:3px;margin-left:0px;border:1px solid #ccc;overflow:auto;cursor:default;padding-bottom:3px;' >""" & vbcrlf & "        var xlh_lis = new Array();" & vbcrlf & "      var num = 0 ;" & vbcrlf & "   if (document.getElementById(numExt + setObjZZ.name.replace(xlhNameExt,""""))){" & vbcrlf & "              num = document.getElementById(numExt + setObjZZ.name.replace(xlhNameExt,"""")).value;" & vbcrlf & "   }else if(document.getElementById(numExt + setObjZZ.id.replace(xlhExt,""""))){" & vbcrlf & "               num = document.getElementById(numExt + setObjZZ.id.replace(xlhExt,"""")).value;" & vbcrlf & "     }" & vbcrlf & "       var xlhnum = 0" & vbcrlf & "if (xlh.length>0)" & vbcrlf & "       {" & vbcrlf & "               for (var i=0;i< xlhs.length ;i++ )" & vbcrlf & "              {       " & vbcrlf & "                        xlh_lis[i] = ""<li style='width:100px;position:relative' onmouseover='showdel(this)' onmouseout='hiddendel(this)'><img title='删除' style='width:10px;display:none;right:1px;top:1px;color:red;position:absolute' onclick='deleteli(this)' src='../images/delete.jpg'/>""+xlhs[i]+""</li>"";" & vbcrlf & "          }" & vbcrlf & "               xlhnum = xlhs.length;" & vbcrlf & "   }" & vbcrlf & "       html += xlh_lis.join("""");" & vbcrlf & " html += ""</div>"";" & vbcrlf & " html += ""<div style='width:100%;text-align:right;margin-right:10px;margin-top:5px;'>"";" & vbcrlf & " html += "" 入库申请数量：<span class='gray'>"" + num + ""</span> "";" & vbcrlf & "    html += "" 当前序列号数量：<span id='xlhnum' class='gray'>""+ xlhnum +""</span>&nbsp;&nbsp;<input type='button' onclick='deleteallxlh()' class='page' value='清空'>"";" &vbcrlf & " html += ""</div>"";" & vbcrlf & " html += ""</td></tr></table>"";" & vbcrlf & "" & vbcrlf & "     $('#w').html(html).window({" & vbcrlf & "             title:'序列号管理'+wtitle ," & vbcrlf & "             width:730," & vbcrlf & "              height:420," & vbcrlf & "             top:150+document.body.scrollTop + document.documentElement.scrollTop," & vbcrlf & "            closeable:true," & vbcrlf & "         collapsible:false," & vbcrlf & "              minimizable:false," & vbcrlf & "              maximizable:false," & vbcrlf & "              modal:true," & vbcrlf & "             resizable:true," & vbcrlf & "         onClose:function(){" & vbcrlf & "                             var x1 = new Array();" & vbcrlf & "                           var i = 0;" & vbcrlf & "                           $(""#target"").find(""li"").each(function(){" & vbcrlf & "                                    x1[i] = $(this).text();" & vbcrlf & "                                 i++;" & vbcrlf & "                            });" & vbcrlf & "                             if (i>0)" & vbcrlf & "                                {" & vbcrlf & "                                       setObjZZ.value = x1.join(""\1"");" & vbcrlf & "                                   var imgid = ""00"";" & vbcrlf & " var num = 0;" & vbcrlf & "                                    if (document.getElementById(numExt + setObjZZ.name.replace(xlhNameExt,""""))){" & vbcrlf & "                                              num = document.getElementById(numExt + setObjZZ.name.replace(xlhNameExt,"""")).value;" & vbcrlf & "                                       }else if(document.getElementById(numExt + setObjZZ.id.replace(xlhExt,""""))){" & vbcrlf & "                                           num = document.getElementById(numExt + setObjZZ.id.replace(xlhExt,"""")).value;" & vbcrlf & "                                     }" & vbcrlf & "                                       if (num.length==0){num = 0;}" & vbcrlf & "                                    if (i>=parseInt(num)){imgid = ""100"";}" & vbcrlf & "                                     else if(parseInt(num)!=0){" & vbcrlf & "                      imgid = (parseInt(i/num * 10)>0 ? parseInt(i/num * 10) + ""0"":""10"");" & vbcrlf & "                                 }" & vbcrlf & "                                       document.getElementById(""xlhimg""+setObjZZ.id.replace(xlhExt,"""")).src = ""../images/percent""+ imgid +"".png"";" & vbcrlf & "                                      document.getElementById(""scanxlh""+setObjZZ.id.replace(xlhExt,"""")).value = x1[x1.length-1];" & vbcrlf & "                         }else{" & vbcrlf & "                                  setObjZZ.value = """";" & vbcrlf & "                                      document.getElementById(""scanxlh""+setObjZZ.id.replace(xlhExt,"""")).value = """";" & vbcrlf & "                                 document.getElementById(""xlhimg""+setObjZZ.id.replace(xlhExt,"""")).src =""../images/percent100.png"";" & vbcrlf & "                           }" & vbcrlf & "               }" & vbcrlf & "       }).window('open');" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function setContentZZ(rowIndex, xlhExt, xlhNameExt,cpTitleExt,order1Ext,type1Ext,numExt){" & vbcrlf & "    if (window.event.keyCode==13){" & vbcrlf & "          addxlhSQZZ(rowIndex , true, xlhExt, xlhNameExt,cpTitleExt,order1Ext,type1Ext,numExt);" & vbcrlf & "                return false;" & vbcrlf & "   }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function setBlurContentZZ(rowIndex, xlhExt, xlhNameExt,numExt){" & vbcrlf & "       addxlhSQZZ(rowIndex , false, xlhExt, xlhNameExt,numExt);"& vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function addxlhSQZZ(rowIndex ,isKeyDown, xlhExt, xlhNameExt,numExt){" & vbcrlf & "  setObjZZ = document.getElementById(xlhExt+rowIndex);" & vbcrlf & "    var obj = document.getElementById(xlhExt+rowIndex);" & vbcrlf & "     var curr = document.getElementById(""scanxlh""+rowIndex);" & vbcrlf & "    var v = curr.value.replace(/(^\s*)|(\s*$)/g,'');" & vbcrlf & "        var oldxlh = obj.value.replace(/(^\s*)|(\s*$)/g,'');" & vbcrlf & "    var xlhs = oldxlh.split(""\1"");//序列号个数" & vbcrlf & "        if (isKeyDown ==false && v.length>0)" & vbcrlf & "    {" & vbcrlf & "               for(var i=0;i<xlhs.length;i++){" & vbcrlf & "                        if (v==xlhs[i]){return;}" & vbcrlf & "                }" & vbcrlf & "       }" & vbcrlf & "       var int_num = 0" & vbcrlf & " var num = 0;" & vbcrlf & "    if (document.getElementById(numExt + setObjZZ.name.replace(xlhNameExt,""""))){" & vbcrlf & "              num = document.getElementById(numExt + setObjZZ.name.replace(xlhNameExt,"""")).value;" & vbcrlf & "   }else if(document.getElementById(numExt + setObjZZ.id.replace(xlhExt,""""))){" & vbcrlf & "               num = document.getElementById(numExt + setObjZZ.id.replace(xlhExt,"""")).value;" & vbcrlf & "     }" & vbcrlf & "       if (num.length==0){num = 0;}else{int_num=parseInt(num);}" & vbcrlf & " if (xlhs.length>=int_num && oldxlh.length>0){" & vbcrlf & "           curr.setAttribute(""canevent"" ,""1"");" & vbcrlf & "         curr.value=xlhs[xlhs.length-1];" & vbcrlf & "         document.getElementById(""xlhimg""+rowIndex).src = ""../images/percent100.png"";" & vbcrlf & "        }else{" & vbcrlf & "               curr.setAttribute(""canevent"",""0"");" & vbcrlf & "          if (v.length>0)" & vbcrlf & "         {" & vbcrlf & "                       var imgid = ""00"";" & vbcrlf & "                 if (xlhs.length>=int_num){imgid = ""100"";}" & vbcrlf & "                 else if(int_num!=0){" & vbcrlf & "                            if (oldxlh.length==0)" & vbcrlf & "                           {" & vbcrlf & "               imgid = (parseInt(1/num * 10) >0 ? parseInt(1/num * 10) + ""0"":""10"");" & vbcrlf & "                                }else{" & vbcrlf & "                                  imgid = (parseInt((xlhs.length+1)/num * 10) >0 ? parseInt((xlhs.length+1)/num * 10) + ""0"":""10"");" & vbcrlf & "                            }" & vbcrlf & "                       }" & vbcrlf&_
	"                       document.getElementById(""xlhimg""+rowIndex).src = ""../images/percent""+ imgid +"".png"";" & vbcrlf & "                     obj.value = oldxlh.length>0? oldxlh + ""\1"" + v : v;" & vbcrlf & "                       if (imgid==""100""){curr.setAttribute(""canevent"",""1"");}" & vbcrlf & "         }" & vbcrlf & "       }" & vbcrlf & "       if(isKeyDown){curr.select();}" & vbcrlf & "}"& vbcrlf & vbcrlf & vbcrlf & "var setObj = null,scanObjTD= null "& vbcrlf &" function SetAllXlh(obj,extIndex){ "& vbcrlf &   " scanObjTD = obj.parentElement;" & vbcrlf &  " setObj = obj.parentElement.obj;" & vbcrlf & " var rowidx=obj.parentElement.parentElement.rowIndex; "& vbcrlf &    " var xlh = setObj.value;" & vbcrlf & "   var title = setObj.getParent().Cells[2].obj.innerText.replace(/(^\s*)|(\s*$)/g,'');" & vbcrlf & "     var order1 =setObj.getParent().Cells[4].text;" & vbcrlf & "   var type1 = setObj.getParent().Cells[5].text;" & vbcrlf & "   var wtitle = ""  【产品名称：""+ title + (order1.length>0?""      产品编号：""+order1 :"""") + (type1.length>0 ?""   产品型号：""+type1:"""") +""】"";" & vbcrlf & "  var xlhs = xlh.split(""\1"");//序列号个数" & vbcrlf & "   var html = ""<table style='width:100%;height:100%;'><tr><td style='width:23%;'>""" & vbcrlf & "   html += ""<div style='height:82%;margin:3px;*margin-top:2px'><textarea id='lrxlh' style='height:100%;border:1px solid #ccc;overflow:auto;cursor:default'></textarea></div>"";" & vbcrlf & " html += ""<div style='width:100%;text-align:right;margin-right:2px;margin-right:3px;'>"";" & vbcrlf & "   html += "" <input type='button' onclick='addxlh()' class='page' value='加入'>"";" & vbcrlf & "      html += "" <input type='button' onclick='deleteaddxlh()' class='page' value='重置'>"";" & vbcrlf & "      html += ""</div>""  " & vbcrlf & "        html += ""</td><td style='width:77%;'>"";" & vbcrlf & "   html += ""<div id='target' class='div_li' style='height:82%;margin:3px;margin-left:0px;border:1px solid #ccc;overflow:auto;cursor:default;padding-bottom:3px;*padding-bottom:0' >""" & vbcrlf & "     var num = setObj.getParent().Cells[8+extIndex].value;" & vbcrlf & "   var xlhnum = 0" & vbcrlf & "  var xlh_lis = new Array();" & vbcrlf & "      if (xlh.length>0)" & vbcrlf & "       {" & vbcrlf & "               for (var i=0;i< xlhs.length ;i++ )" & vbcrlf & "               {       " & vbcrlf & "                        xlh_lis[i] = ""<li style='width:100px;position:relative' onmouseover='showdel(this)' onmouseout='hiddendel(this)'><img title='删除' style='width:10px;right:1px;top:1px;color:red;display:none;position:absolute' onclick='deleteli(this)' src='../images/delete.jpg'/>""+xlhs[i]+""</li>"";" & vbcrlf & "               }" & vbcrlf & "               xlhnum = xlhs.length;" & vbcrlf & "   }" & vbcrlf & "       html += xlh_lis.join("""");" & vbcrlf & " html += ""</div>"";" & vbcrlf & " html += ""<div style='width:100%;text-align:right;margin-right:10px;margin-top:5px;'>"";" & vbcrlf & " html += "" 入库申请数量：<span class='gray'>"" + num + ""</span> "";" & vbcrlf & "    html += "" 当前序列号数量：<span id='xlhnum' class='gray'>""+ xlhnum +""</span>&nbsp;&nbsp;<input type='button' onclick='deleteallxlh()' class='page' value='清空'>"";" & vbcrlf & "  html += ""</div>"";" & vbcrlf & " html += ""</td></tr></table>"";" & vbcrlf & vbcrlf &  "var top = $(obj).offset().top;" & vbcrlf &  " $ible:false," & vbcrlf & "         minimizable:false," & vbcrlf & "              maximizable:false," & vbcrlf & "              modal:true," & vbcrlf & "             resizable:true," & vbcrlf & "         onClose: function () {" & vbcrlf & "                          var x1 = new Array();" & vbcrlf & "                           var i = 0;" & vbcrlf & "                              $(""#target"").find(""li"").each(function(){" & vbcrlf & "                                        x1[i] = $(this).text();" & vbcrlf & "                                 i++;" & vbcrlf & "                            });" & vbcrlf & "                             if (i>0)" & vbcrlf & "                                {" & vbcrlf & "                                       setObj.value = x1.join(""\1"");" & vbcrlf & "                                     var imgid = ""00"";" & vbcrlf & "                                 var num = setObj.getParent().Cells[8+extIndex].value;" & vbcrlf & "                                  if (num.length==0){num = 0;}" & vbcrlf & "                                    if (i>=parseInt(num)){imgid = ""100"";}" & vbcrlf & "                                     else if(parseInt(num)!=0){" & vbcrlf & "                                              imgid = (parseInt(i/num * 10)>0 ? parseInt(i/num * 10) + ""0"":""10"");" & vbcrlf & "                                 }" & vbcrlf & "                                       $(scanObjTD).find(""img"")[0].src = ""../images/percent""+ imgid +"".png"";" & vbcrlf & "                                  $(scanObjTD).find(""input"")[0].value = x1[x1.length-1];" & vbcrlf & "                            }else{" & vbcrlf & "                                  setObj.value = """";" & vbcrlf & "                                        $(scanObjTD).find(""input"")[0].value = """";" & vbcrlf & "                                   $(scanObjTD).find(""img"")[0].src = ""../images/percent100.png"";" & vbcrlf & "                            }" & vbcrlf & "               }" & vbcrlf & "       }).window('open');" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function setXlh(curr,extIndex){" & vbcrlf & "      if (window.event.keyCode==13){" & vbcrlf & "          setxlhSP(curr ,true,extIndex);" & vbcrlf & "  }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function setxlhSP(curr ,isKeyDown,extIndex){" & vbcrlf & "       var obj = curr.parentElement.obj;" & vbcrlf & "       var v = curr.value.replace(/(^\s*)|(\s*$)/g,'');" & vbcrlf & "        var oldxlh = obj.value.replace(/(^\s*)|(\s*$)/g,'');" & vbcrlf & "    var xlhs = oldxlh.split(""\1"");//序列号个数" & vbcrlf & "  if (isKeyDown ==false && v.length>0)" & vbcrlf & "    {" & vbcrlf & "               for(var i=0;i<xlhs.length;i++){" & vbcrlf & "                 if (v==xlhs[i]){return;}" & vbcrlf & "                }" & vbcrlf & "       }" & vbcrlf & "       var cfxlh = checkXlhExists(v);" & vbcrlf & "  if(cfxlh != """"){" & vbcrlf & "          alert(""序列号【""+ v +""】存在重复！"");" & vbcrlf &                "return;" & vbcrlf &"  } "& vbcrlf &      "  var int_num = 0" & vbcrlf &  "var num = obj.getParent().Cells[8+extIndex].value;//数量 "& vbcrlf &        " if (num.length==0){num = 0;}else{int_num=parseInt(num);} "& vbcrlf &      "   if (xlhs.length>=int_num && oldxlh.length>0){" & vbcrlf &"curr.setAttribute(""canevent"" ,""1"");" & vbcrlf &          "curr.value=xlhs[xlhs.length-1];" & vbcrlf &        "  $(curr.parentElement).find(""img"")[0].src = ""../images/percent100.png""; "& vbcrlf &       "}else{" & vbcrlf &          " curr.setAttribute(""canevent"",""0"");" & vbcrlf &       "    if (v.length>0)" & vbcrlf & "{" & vbcrlf & "                       var imgid = ""00"";" & vbcrlf & "                 if (xlhs.length>=int_num){imgid = ""100"";}" & vbcrlf & "                 else if(int_num!=0){" & vbcrlf & "                            if (oldxlh.length==0)" & vbcrlf & "                           {" & vbcrlf & "                                       imgid = (parseInt(1/num * 10) >0 ? parseInt(1/num * 10) + ""0"":""10"");" & vbcrlf & "                }else{" & vbcrlf & "                                  imgid = (parseInt((xlhs.length+1)/num * 10) >0 ? parseInt((xlhs.length+1)/num * 10) + ""0"":""10"");" & vbcrlf & "                            }" & vbcrlf & "                       }" & vbcrlf & "                       $(curr.parentElement).find(""img"")[0].src = ""../images/percent""+ imgid +"".png"";" & vbcrlf & "                        obj.value = oldxlh.length>0? oldxlh + ""\1"" + v : v;" & vbcrlf & "                     if (imgid==""100""){curr.setAttribute(""canevent"",""1"");}" & vbcrlf & "         }" & vbcrlf & "       }" & vbcrlf & "       if(isKeyDown){curr.select();}" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function setBlurXlh(curr,extIndex){" & vbcrlf & "       setxlhSP(curr ,false , extIndex);" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function scanEvent(){" & vbcrlf & "        if (window.event.keyCode==13){addxlh();}" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function trim(str){return str.replace(/(^\s*)|(\s*$)/g, """");}" & vbcrlf & "" & vbcrlf & "function addxlh(){" & vbcrlf & "  var v = $(""#lrxlh"").val();" & vbcrlf & "    if (v.length>0)" & vbcrlf & " {       " & vbcrlf & "                var xlhStr1 = """";" & vbcrlf & "         var xlhExists = 0;" & vbcrlf & "              var cfxlh = """";" & vbcrlf & "           var arrli = v.split(/\n/g);" & vbcrlf & "             var i=0;" & vbcrlf & "                for(i=0;i<arrli.length ;i++){" & vbcrlf & "                        var v1 = trim(arrli[i].replace(/(^\s*)|(\s*$)/g,''));" & vbcrlf & "                   if(v1!=""""){" & vbcrlf & "                               if((""\2""+xlhStr1+""\2"").indexOf(""\2""+v1+""\2"")==-1){" & vbcrlf & "                                      xlhStr1 += (xlhStr1==""""?"""":""\2"") + v1;" & vbcrlf & "                                }else{                          " & vbcrlf & "                                        xlhExists = 1;" & vbcrlf & "                                        break;" & vbcrlf & "                          }" & vbcrlf & "                       }" & vbcrlf & "               }" & vbcrlf & "               if(xlhExists == 1){" & vbcrlf & "                     alert(""序列号【""+ v1 +""】存在重复！"");" & vbcrlf & "                      return;" & vbcrlf & "         }" & vbcrlf & "               var targetXlh = """";" & vbcrlf & "               $(""#target"").children().each(function(){" & vbcrlf &"                 targetXlh += (targetXlh==""""?"""":""\2"") + $(this).text();" & vbcrlf & "                });" & vbcrlf & "             for(i=0;i<arrli.length ;i++){" & vbcrlf & "                   var v1 = arrli[i].replace(/(^\s*)|(\s*$)/g,'');" & vbcrlf & "                 if(v1!=""""){" & vbcrlf & "                               if((""\2""+targetXlh+""\2"").indexOf(""\2""+v1+""\2"")>-1){"& vbcrlf &  "                                   xlhExists = 1;" & vbcrlf &                              "     break;" & vbcrlf &                 "          } "& vbcrlf &             "           } "& vbcrlf &         "       } "& vbcrlf &              "  if(xlhExists == 1){ "& vbcrlf &                      "alert(""序列号【""+ v1 +""】存在重复！""); "& vbcrlf &                  "     return;" & vbcrlf &       "   } "& vbcrlf &            "    cfxlh = checkXlhExists(xlhStr1);" & vbcrlf & "if(cfxlh != """"){" & vbcrlf & "                  alert(""序列号【""+ cfxlh +""】存在重复！"");" & vbcrlf & "                   return;" & vbcrlf & "         }" & vbcrlf & "" & vbcrlf & "               for (i=0;i<arrli.length ;i++ )" & vbcrlf & "          {" & vbcrlf & "                       var v1 = arrli[i].replace(/(^\s*)|(\s*$)/g,'');" & vbcrlf & "                 if (v1.length>0)" & vbcrlf & "{" & vbcrlf & "                               $(""<li style='width:100px;position:relative' onmouseover='showdel(this)' onmouseout='hiddendel(this)'><img style='width:10px;right:1px;top:1px;color:red;display:none;position:absolute' onclick='deleteli(this)' title='删除' src='../images/delete.jpg'/>""+v1+""</li>"").appendTo($(""#target""));" & vbcrlf &                "   } "& vbcrlf &            "    } "& vbcrlf &               " $(""#lrxlh"").val("""");" & vbcrlf &               "  $("""").text($(""#target"").children().size()); "& vbcrlf & " } "& vbcrlf &      "  $(""#lrxlh"")[0].focus();" & vbcrlf & "} "& vbcrlf & vbcrlf & "function checkXlhExists(xlhStr){"&_
	"       var ret = """";" & vbcrlf & "     var xlhExists = 0;" & vbcrlf & "      $.ajax({" & vbcrlf & "                url:'../store/CommonReturn.asp'," & vbcrlf & "                data:{act:'CheckXlhExists',xlhStr:xlhStr}," & vbcrlf & "              async:false," & vbcrlf & "            type:'post'," & vbcrlf & "            success:function(r){" & vbcrlf & "                    var arr_ret = r.split(""\2"");" & vbcrlf & "                   if(arr_ret[0]==""1""){" & vbcrlf & "                              ret = arr_ret[1];" & vbcrlf & "                               xlhExists = 1;" & vbcrlf & "                          return false;" & vbcrlf & "                   }" & vbcrlf & "               }" & vbcrlf & "       });     " & vbcrlf & "        return ret;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function deleteaddxlh(){" & vbcrlf & "       $(""#lrxlh"").val("""");" & vbcrlf & "        $(""#lrxlh"")[0].focus();" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function deleteallxlh(){" & vbcrlf & "  if(confirm(""确认清空？"")){" & vbcrlf & "                $(""#target li"").remove();" & vbcrlf & "         $("").text($(""#target"").children().size());  " & vbcrlf & "        }" & vbcrlf & "       $(""#lrxlh"")[0].focus();" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function showdel(obj){" & vbcrlf & "    var $close =$(obj).find(""img"");" & vbcrlf & "   $close.css({display:""block""});" & vbcrlf & "}" & vbcrlf & "function hiddendel(obj){" & vbcrlf & "   var $close =$(obj).find(""img"");" & vbcrlf & "    $close.css({display:""none""});" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function deleteli(obj){" & vbcrlf & "     $(obj).parent().remove();" & vbcrlf & "       $("").text($(""#target"").children().size());" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "</script>" & vbcrlf & "<div id=""w""></div>"
	
	Response.write "" & vbcrlf & "<body class=""BillUI"" onLoad=""txmFocus();BuildEvent();UpdatePrice();"" onclick=""TexTxmFocus(event);"">" & vbcrlf & ""
	session("num_click2009")=0
	session("num_click2010")=0
	dim ids,top,f
	top=deurl(request("top"))
	Response.write "" & vbcrlf & "<script>" & vbcrlf & "      window.billorderid = """
	Response.write top
	Response.write """;" & vbcrlf & "</script>" & vbcrlf & ""
	conn.cursorlocation = 3
	Set colrs =conn.execute("select id,title,name,sort,kd,set_open,sorce,gate1 from zdymx where sort1=1004 and set_open=1 order by gate1 asc ")
	Set colrs.activeconnection = Nothing
	Set colrs1005 =conn.execute("select id,title,name,sort,kd,set_open,sorce,gate1 from zdymx where sort1=1005 and set_open=1 order by gate1 asc ")
	Set colrs1005.activeconnection = Nothing
	Set unitrs = conn.execute("select ord,sort1,id from sortonehy where gate2=61")
	Set unitrs.activeconnection = Nothing
	sql="Delete  mxpx Where cateid="&session("personzbintel2007")&" "
	conn.Execute(sql)
	set rs7=server.CreateObject("adodb.recordset")
	sql7="select sum(kd) as num1 from zdymx where sort1=5 and set_open=1"
	rs7.open sql7,conn,1,1
	if rs7.eof then
	else
		num1_kd=rs7("num1")
	end if
	rs7.close
	set rs7=Nothing
	ShowOnlyCanStoreProduct = True
	dim IsOpenRKPrice : IsOpenRKPrice = sdk.power.existsPower(23,3)
	displayStr = ""
	if IsOpenRKPrice=false then displayStr = "display:none;"
	Dim returnUnit : returnUnit = True
	Dim kdtall
	kdtall=0
	set rs = colrs : colrs.movefirst
	while Not rs.eof
		if (rs("sorce").Value=6 or rs("sorce").Value=7) then
			if IsOpenRKPrice then kdtall=kdtall+rs("kd")
'if (rs("sorce").Value=6 or rs("sorce").Value=7) then
		else
			kdtall=kdtall+rs("kd")
'if (rs("sorce").Value=6 or rs("sorce").Value=7) then
		end if
		rs.movenext
	wend
	Set rs=Nothing
	Response.write "" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""5"">" & vbcrlf & "<tr>" & vbcrlf & "<td width=""215"" valign=""top"">" & vbcrlf & ""
	JyBomProduct=True
	
	Const CACHE_SIZE = 5000
	Const PAGE_LIMIT_COUNT = 2000
	Class TreeClass
		Public treeid
		Public width
		Public height
		Public url
		Public params
		Public parentField
		Public idField
		Public textField
		Public nodePageSize
		Public nodeLimit
		Public leafPageSize
		Public leafLimit
		Public cascade
		Public ShowOnlyCanStoreProduct
		Public ShowOnlyHasBomProduct
		Public ShowOnlyHaszzInfo
		Public cn
		Public leafSql
		Public cateSql
		Public treeHeaderHtml
		Public treeType
		Public ClsBatchSelect
		Public onClick
		Private virPath
		Private pageIndex
		Private cache
		Private cacheIdx
		Public isFirstLoop
		Private Sub Class_Initialize
			treeid = "jquery_tree_component"
			parentfield = "pid"
			params = ""
			pageIndex = request("__pageIndex")
			If pageIndex = "" Then pageIndex = 1
			ShowOnlyCanStoreProduct = False
			ShowOnlyHasBomProduct = False
			ShowOnlyHaszzInfo=false
			width = 210
			idField = "id"
			textField = "text"
			Dim pobj
			set pobj = server.createobject( ZBRLibDLLNameSN & ".PageClass")
			virPath = pobj.GetVirPath()
			set pobj = Nothing
			ReDim cache(CACHE_SIZE)
			cacheIdx = 0
			cascade = False
			isFirstLoop = True
		end sub
		Public Sub html(v)
			cache(cacheIdx) = v
			cacheIdx = cacheIdx + 1
			'cache(cacheIdx) = v
			If cacheIdx >= CACHE_SIZE Then Call htmlFlush
		end sub
		Public Sub htmlFlush()
			Response.write Join(cache,"")
			Response.flush
			ReDim cache(CACHE_SIZE)
			cacheIdx = 0
		end sub
		Public Sub tree
			If isEmpty(cn) Then
				Response.write "树控件调用缺少必要的参数"
				Response.end
			end if
			Response.write "<link rel='stylesheet' type='text/css' href='"&virPath&"inc/jquery.tree.css'></link>" & vbcrlf
			Response.write "<script>var __tree</script>" & vbcrlf
			Response.write "<script src='"&virPath&"inc/jquery.tree.js'></script>" & vbcrlf
			Response.write "<script>$(function(){__tree=$('#"&treeid&"')});</script>" & vbcrlf
			Response.write "<div class='pro-menu-wrap' id='" & treeid & "' cstore='"&iif(ShowOnlyCanStoreProduct,1,0)&"' jybom='"&iif(ShowOnlyHaszzInfo,1,0)&"' cbom='"&iif(ShowOnlyHasBomProduct,1,0)&"' params='"&params&"'>"
			'Response.write "<script>$(function(){__tree=$('#"&treeid&"')});</script>" & vbcrlf
			Call showCate(0,cascade)
			Call htmlFlush
			Response.write "</div>"
		end sub
		Sub showCP(nodeId)
			Dim sql,rsCp,dataCp,leafTitle,leafId,cpCnt,i
			set rsCp = server.CreateObject("adodb.recordset")
			sql = Replace(leafSql,"@pid",nodeId)
			rsCp.open sql,cn,1,1
			If rsCp.eof = False Then
				Call html("<table border='0' width='100%' cellspacing='0' cellpadding='0' class='tree'>")
				cpCnt = rsCp.recordCount
				dataCp = rsCp.getRows
				rsCp.close
				Dim pageCount,startIdx,endIdx
				If isEmpty(leafPageSize) Or leafPageSize&""="0" Then leafPageSize = 20
				pageCount = iif(cpCnt Mod leafPageSize = 0,cpCnt \ leafPageSize,cpCnt \ leafPageSize + 1)
'If isEmpty(leafPageSize) Or leafPageSize&""="0" Then leafPageSize = 20
				If pageIndex = "" Or Not isnumeric(pageIndex) Then pageIndex = 1
				If CInt(pageIndex) < 1 Then pageIndex = 1
				If CInt(pageIndex) > pageCount Then pageIndex = pageCount
				startIdx = (pageIndex - 1) * leafPageSize
'If CInt(pageIndex) > pageCount Then pageIndex = pageCount
				If cpCnt>leafLimit Then
					endIdx = startIdx + leafPageSize - 1
'If cpCnt>leafLimit Then
				else
					endIdx = cpCnt - 1
'If cpCnt>leafLimit Then
				end if
				Dim fieldCount : fieldCount = ubound(dataCp,1)
				Dim kk,strAttr,tmpstr
				For j=startIdx To endIdx
					If j>=cpCnt Then Exit For
					leafId = dataCp(0,j)
					leafTitle = dataCp(1,j)
					strAttr=" nid='"&dataCp(0,j)&"'"
					For kk=2 To fieldCount
						strAttr=strAttr&" attr_"& kk &"='"& dataCp(kk,j) &"'"
					next
					Call html(  "<tr><td " & iif(onClick<>"","onclick='" & onClick & "'","") & " "&strAttr&" style='padding-left:5px'>" )
					'strAttr=strAttr&" attr_"& kk &"='"& dataCp(kk,j) &"'"
					tmpstr = "<img src='../images/icon_sanjiao.gif' style='border:0px'>" &_
					"<a class='tree-linkOfLeafNodes' href='javascript:void(0);' lid='" & leafId & "' "
					If treeType="TC" Then
						tmpstr = tmpstr&"id='cp" & leafId & "' funType='0' " & vbcrlf &_
						"onclick='selectCP("&leafId&")' " & vbcrlf &_
						"name='" & Replace(Replace(dataCp(2,j)&"","""","&quot;"),"'","&#039;") & "'"
						If dataCp(4,j)>0 Then
							tmpstr = tmpstr & " style='color:red'"
						end if
					end if
					tmpstr = tmpstr & ">" & leafTitle & "</a>"
					Call html(tmpstr)
					Call html(  "</td></tr>" )
				next
				If cpCnt>leafLimit And pageCount>1 Then
					Call html("<tr><td><span class='tree-pagebar' nid='"&id&"' iscp='0' pageCount='"&pageCount&"' pageIndex='"&pageIndex&"'>" &_
					"<span class='tree-pagebar-first-btn"&iif(CInt(pageIndex)<=1,"-disabled'","' onclick=""__treePage(this,'first');""")&"></span>"&_
					"<input type='text' class='tree-pagebar-page-box' onkeydown='return __pageBoxKeyDown(event,this);"&_
					"onfocus='this.select();' maxlength='4' value='"&pageIndex&_
					"<span class='tree-pagebar-next-btn"&iif(CInt(pageIndex)>=pageCount,"-disabled'","' onclick=""__treePage(this,'next');""")&"></span>"&_
					" onfocus='this.select();' maxlength='4' value='"&pageIndex&"'>/"&pageCount&_
					"<span class='tree-pagebar-last-btn"&iif(CInt(pageIndex)>=pageCount,"-disabled'","' onclick=""__treePage(this,'last');""")&"></span>"&_
					" onfocus='this.select();' maxlength='4' value='"&pageIndex&"'>/"&pageCount&_
					"</span></td></tr>")
				end if
				Call html("</table>")
			end if
		end sub
		Sub showCate(id,cascade)
			Dim storeAtrrwhere : storeAtrrwhere = ""
			If ShowOnlyCanStoreProduct = True  Then
				storeAtrrwhere = " and canOutStore=1 "
			end if
			Dim sql,rsCate,dataCate,nodeCnt
			Set rsCate = server.CreateObject("adodb.recordset")
			sql=Replace(Replace(cateSql,"@pid",id),"@isFirstLoop",Abs(isFirstLoop))
			rsCate.open sql,cn,1,1
			If rsCate.eof = False Then
				nodeCnt = rsCate.recordCount
				dataCate = rsCate.getRows()
				rsCate.close
				Dim j,menuType,listType,childrenCnt,nodeId,nodeTitle
				Dim pageCount,startIdx,endIdx
				If isEmpty(nodePageSize) Then nodePageSize = 20
				If nodePageSize = 0 Then nodePageSize = 20
				pageCount = iif(nodeCnt Mod nodePageSize = 0,nodeCnt \ nodePageSize,nodeCnt \ nodePageSize + 1)
'If nodePageSize = 0 Then nodePageSize = 20
				If pageIndex = "" Or Not isnumeric(pageIndex) Then pageIndex = 1
				If CInt(pageIndex) < 1 Then pageIndex = 1
				If CInt(pageIndex) > pageCount Then pageIndex = pageCount
				startIdx = (pageIndex - 1) * nodePageSize
'If CInt(pageIndex) > pageCount Then pageIndex = pageCount
				If nodeCnt>nodeLimit Then
					endIdx = startIdx + nodePageSize - 1
'If nodeCnt>nodeLimit Then
				else
					endIdx = nodeCnt - 1
'If nodeCnt>nodeLimit Then
				end if
				Call html("<table border='0' width='100%' cellspacing='0' cellpadding='0' class='tree'>")
				If isFirstLoop Then Call html(Me.treeHeaderHtml)
				For j=startIdx To endIdx
					If j>=nodeCnt Then Exit For
					nodeId = dataCate(0,j)
					If Me.treeType = "TC" And isFirstLoop = False Then
						nodeTitle = "<a href='javascript:void(0);' onclick='categoryTC("&nodeId&");event.cancelBubble=true;' " &_
						">" & dataCate(1,j) & "</a>"
					else
						nodeTitle = dataCate(1,j)
					end if
					childrenCnt = dataCate(2,j)
					If j=nodeCnt Or (nodeCnt>nodeLimit And j+1=nodePageSize-1) Then
						childrenCnt = dataCate(2,j)
						menutype="class='tree-folder tree-lastfolder-" & iif(cascade,"open","closed") & "'"
						childrenCnt = dataCate(2,j)
						listtype="class='tree-lastleaf-nodes'"
						childrenCnt = dataCate(2,j)
					else
						menutype="class='tree-folder tree-folder-" & iif(cascade,"open","closed") & "'"
						childrenCnt = dataCate(2,j)
						listtype="class='tree-leaf-nodes'"
						childrenCnt = dataCate(2,j)
					end if
					Dim ihtml:  ihtml = ""
					If CLng("0" & ClsBatchSelect)=1 Then
						ihtml = "<a href='javascript:void(0)' onclick='return __TreeClsClick(event, " & nodeId & ")'><img style='border:none' src='../images/jiantou.gif'>加入</a>"
					end if
					If childrenCnt = 0 Then
						Call html(  "<tr>"&_
						"<td " & iif(Me.treeType = "TC"," id='b" & nodeId & "' funType='0'" ,"") & menutype & " onclick='__toggleNode(this);' nid='"&nodeId&"' leafCate='1'>" & nodeTitle & " " & ihtml & "</td>" &_
						"</tr>"&_
						"<tr " & iif(cascade,"","style='display:none'") &" class='tree-panel'>"&_
						"</tr>"&_
						"<td " & listtype & ">")
						If cascade Then
							Call showCP(nodeId)
						end if
						Call html(          "</td>" &_
						"</tr>")
					Else
						Call html(  "<tr>"&_
						"<td " & iif(Me.treeType = "TC"," id='b" & nodeId & "' funType='0'" ,"") & menutype & " onclick='__toggleNode(this)' nid='"&nodeId&"' leafCate='0'>" & nodeTitle &  " " & ihtml & "</td>" &_
						"</tr>"&_
						"<tr "& iif(cascade,"","style='display:none'") &" class='tree-panel'>"&_
						"</tr>"&_
						"<td " & listtype & ">")
						If cascade Then
							isFirstLoop = False
							Call showCate(nodeId,cascade)
						end if
						Call html(          "</td>" &_
						"</tr>")
					end if
				next
				If nodeCnt>nodeLimit And pageCount>1 Then
					Call html("<tr><td><span class='tree-pagebar' nid='"&id&"' iscp='0' pageCount='"&pageCount&"' pageIndex='"&pageIndex&"'>" &_
					"<span class='tree-pagebar-first-btn"&iif(CInt(pageIndex)<=1,"-disabled'","' onclick=""__treePage(this,'first');""")&"></span>"&_
					"<input type='text' class='tree-pagebar-page-box' onkeydown='return __pageBoxKeyDown(event,this);"&_
					"onfocus='this.select();' maxlength='4' value='"&pageIndex&_
					"<span class='tree-pagebar-next-btn"&iif(CInt(pageIndex)>=pageCount,"-disabled'","' onclick=""__treePage(this,'next');""")&"></span>"&_
					" onfocus='this.select();' maxlength='4' value='"&pageIndex&"'>/"&pageCount&_
					"<span class='tree-pagebar-last-btn"&iif(CInt(pageIndex)>=pageCount,"-disabled'","' onclick=""__treePage(this,'last');""")&"></span>"&_
					" onfocus='this.select();' maxlength='4' value='"&pageIndex&"'>/"&pageCount&_
					"</span></td></tr>")
				end if
				Call html("</table>")
			end if
		end sub
	End Class
	Response.write "" & vbcrlf & "<style>" & vbcrlf & "#cpjsdiv #cpB {" & vbcrlf & " vertical-align: top;" & vbcrlf & "    height: 20px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "#cpjsdiv #txtKeywords {" & vbcrlf & "   height: 20px;" & vbcrlf & "   width:75px!important" & vbcrlf & "}" & vbcrlf & ".IE8 #txtKeywords{height:14px!important;line-height:14px!important;}" & vbcrlf & ".IE5 #txtKeywords{height:21px!important;line-height:15px!important;margin-top:-1px;}" & vbcrlf & "#cp_search{" & vbcrlf & "  display:none;padding-top:6px; border: 1px solid #ccc; border-top: none;overflow:hidden;" & vbcrlf & " width:223px;padding:0;padding-top:5px;" & vbcrlf & "}" & vbcrlf & " .ie5 #cp_search{width:215px!important;}" & vbcrlf & " .ie8 #cp_search{width:213px!important;}" & vbcrlf & "@-moz-document url-prefix() { " & vbcrlf & "        #cp_search{ width: 99%; }" & vbcrlf & "}" & vbcrlf & "  .ie8 .productTree {width:213px;}" & vbcrlf & "" & vbcrlf & ".pro-menu-search {margin-top:2px;height:25px;}" & vbcrlf & "" & vbcrlf & ".IE5 .pro-menu-wrap{width:215px;}" & vbcrlf & "</style>" & vbcrlf & "<script language=""javascript"" src="""
	Response.write GetVirPath()
	Response.write "inc/system.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & ""
	function IIF(cv,ov1,ov2)
		if cv then
			IIF=ov1
		else
			IIF=ov2
		end if
	end function
	Sub ShowLeftTree
		Dim hasCheckBox : hasCheckBox = 0
		If ShowCheckBoxWhenSearch = True Then hasCheckBox = 1
		Dim rsLeftlist,leftlist,rs, actCate
		actCate = session("personzbintel2007")
		Set rs=conn.execute("select sort1 from leftlist where cateid="& actCate )
		if rs.eof then
			leftlist=1
			conn.execute "insert into leftlist(cateid,sort1) values("& actCate &",1)"
		else
			leftlist=rs("sort1")
		end if
		rs.close
		set rs=Nothing
		Dim sort3
		sort3 = CLng(conn.execute("select intro from setopen where sort1=17")(0))
		Dim storeAtrrwhere
		storeAtrrwhere = ""
		If ShowOnlyCanStoreProduct = True  Then
			storeAtrrwhere = " and canOutStore=1 "
		else
			ShowOnlyCanStoreProduct = false
		end if
		If ShowOnlyHasBomProduct = True Then
			storeAtrrwhere = storeAtrrwhere & " and c.ord in (select distinct(ProOrd) from BOM_Structure_Info where pType = 1 and del = 1 and status_sp=0) "
		else
			ShowOnlyHasBomProduct = False
			if JyBomProduct then
				ShowOnlyHaszzInfo=true
				storeAtrrwhere = storeAtrrwhere & " and c.ord in (select distinct(product) from bom where complete = 1 and del = 1 ) "
			end if
		end if
		If Len(outProductStr)>0 Then storeAtrrwhere = storeAtrrwhere & " and c.ord not in ("& outProductStr &")"
		If hideTreeTitle <> True Then
			Response.write "" & vbcrlf & "              <div class=""resetBorderColor"" style=""position:relative;height:64px;line-height:64px;overflow:hidden;border-right:1px solid #ccc;border-left:1px solid #efefef"" id='cpjsdiv'>" & vbcrlf & "                        <img class=""resetElementHidden"" src='"
'If hideTreeTitle <> True Then
			Response.write GetVirPath()
			Response.write "images/m_placebg.jpg' width='100%' height='40px'>" & vbcrlf & "                     <div class=""leftPageBg tableTitleLinks"" style='position:absolute;top:0px;left:0px;width:100%;padding-left:17px;height:40px;line-height:40px;padding-top:3px;font-size:14px;font-weight:bold;background:#EFEFEF"
		end if
		Response.write "" & vbcrlf & "      <div class=""resetBorderColor resetTransparent"" style=""background:#fff;overflow:hidden;white-space:nowrap;height:48px;border-right:1px solid #ccc;border-left:1px solid #efefef""  id='cpjsdivsearch'>" & vbcrlf & "                <div class=""pro-menu-search"" style='border-right:0;border-left:0'>" & vbcrlf & "                        <form name=""form"" method=""post"" style=""margin:0px"">" & vbcrlf & "                           <table style='width:100%' style='border-collapse:collapse;' cellpadding=0 cellspacing=0>" & vbcrlf & "                                        <tr>" & vbcrlf & "                                            <td valign=""middle"" style='padding-top:0px;height:48px;line-height:48px;'>" & vbcrlf & "                                                 <input type=""hidden"" name=""cstore"" value="""
		Response.write abs(ShowOnlyCanStoreProduct)
		Response.write """>" & vbcrlf & "                                                 <select name=""B"" id=""cpB"" style=""width:80px;padding:0px;white-space:nowrap;margin-left:3px;margin-right:3px"">" & vbcrlf & "                                                         <option "
		'Response.write abs(ShowOnlyCanStoreProduct)
		Response.write iif(sort3=1," selected","")
		Response.write " value=""cpmc"">产品名称</option>" & vbcrlf & "                                                         <option "
		Response.write iif(sort3=5," selected","")
		Response.write " value=""txm"">条形码</option>" & vbcrlf & "                                                            <option "
		Response.write iif(sort3=4," selected","")
		Response.write " value=""pym"">拼音码</option>" & vbcrlf & "                                                            <option "
		Response.write iif(sort3=2," selected","")
		Response.write " value=""cpbh"">产品编号</option>" & vbcrlf & "                                                         <option "
		Response.write iif(sort3=3," selected","")
		Response.write " value=""cpxh"">产品型号</option>" & vbcrlf & "                                                 </select>"
		Dim rsJm, fullTreeFlag
		set rsjm=conn.execute("select num1 from setjm3 where ord=7")
		if not rsjm.eof then
			fullTreeFlag=rsjm(0)
		else
			fullTreeFlag=1
		end if
		rsjm.close
		set rsjm=Nothing
		Dim proCount
		If fullTreeFlag = 1 Then
			If leftlist = 1 Then
				fullTreeFlag = 0
			end if
			proCount = conn.execute("select count(1) from product where del=1" & Replace(storeAtrrwhere,"c.","")).fields(0).value
			If proCount > PAGE_LIMIT_COUNT Then
				fullTreeFlag = 0
			end if
		end if
		if fullTreeFlag<>1 then
			Response.write "<input name=""C"" id=""txtKeywords"" type=""text"" value=""按回车搜索"" style=""width:69px;height:20px;solid;font-size: 9pt;color: #999999;text-align:center;"" onfocus=""if(value==defaultValue){value='';this.style.color='#000'}"" onblur=""if(value=='')value=defaultValue;"" onpropertychange=""if(this.value.indexOf('\'')>=0){this.value=this.value.replace('\'','');}"" onkeypress=""if(event.keyCode==13) {quickSearch();return false;}""/><input name=""top"" type=""hidden"" value="""
			Response.write top
			Response.write """>"
		else
			Response.write "<input name=""C"" id=""txtKeywords"" type=""text"" value=""按回车搜索"" style=""width:67px;height:20px;solid;font-size: 9pt;color: #999999;text-align:center;*vertical-align:top;line-height:20px;*height:14px;*line-height:14px;"" onfocus=""if(this.value=='按回车搜索'){this.value='';this.style.color='#000'}"" onblur=""if(this.value=='')this.value='按回车搜索';"" onpropertychange=""if(this.value.indexOf('\'')>=0){this.value=this.value.replace('\'','');} else{if(this.value!='按回车搜索') quickSearch();}"" onkeypress=""if(event.keyCode==13) {quickSearch();return false;}""/><input name=""top"" type=""hidden"" value="""
			Response.write top
			Response.write """>"
		end if
		Response.write "<input type=""button"" id=""__adv_search_btn"" value=""高级"" style=""width:34px;*height:20px;*line-height:16px;margin-left:3px"" class=""anybutton2"" onclick=""Left_adSearch(this);"">" & vbcrlf & "                                             </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                           </table>" & vbcrlf & "                        </form>" & vbcrlf & "</div>" & vbcrlf &   "</div>" & vbcrlf &""
		Dim num24,num25,num2014062801,num2014062802
		set rs=conn.execute("select num1 from setjm3 where ord=24")
		if not rs.eof then
			num24=rs(0)
		else
			conn.execute "insert into setjm3(ord,num1) values(24,500)"
			num24=500
		end if
		set rs=conn.execute("select num1 from setjm3 where ord=25")
		if not rs.eof then
			num25=rs(0)
		else
			conn.execute "insert into setjm3(ord,num1) values(25,20)"
			num25=20
		end if
		rs.close
		set rs=Nothing
		set rs=conn.execute("select num1 from setjm3 where ord=2014062801")
		if not rs.eof then
			num2014062801=rs(0)
		else
			conn.execute "insert into setjm3(ord,num1) values(2014062801,500)"
			num2014062801=500
		end if
		set rs=conn.execute("select num1 from setjm3 where ord=2014062802")
		if not rs.eof then
			num2014062802=rs(0)
		else
			conn.execute "insert into setjm3(ord,num1) values(2014062802,20)"
			num2014062802=20
		end if
		rs.close
		set rs=Nothing
		Response.write "" & vbcrlf & "     <div id=""productdh"" class=""resetGroupTableBg"" style='margin-top:2px;border:1px solid #ccc;border-top:0px;border-right:1px solid #a7bbd6;" & vbcrlf & "                    background-image:url("
		'set rs=Nothing
		Response.write GetVirPath()
		Response.write "images/smico/lmeuntab_bg_c.gif);height:23px;overflow:hidden;z-index:100'>" & vbcrlf & "            <table width=""100%"">" & vbcrlf & "                      <tr>" & vbcrlf & "                            <td width=""80px"" valign=""center"">" & vbcrlf & "                                   <img class=""resetElementHidden"" src='"
		Response.write GetVirPath()
		Response.write GetVirPath()
		Response.write "images/smico/jt1.gif' style='margin-top:3px;'>" & vbcrlf & "                    <img class=""resetElementShowNoAlign"" src='"
		Response.write GetVirPath()
		Response.write GetVirPath()
		Response.write "skin/default/images/MoZihometop/leftNav/expand.png' style='margin-top:3px;display:none'>" & vbcrlf & "<a  href=""javascript:void(0);"" onclick=""colspanAll();"" class=""m_l tableTitleLinks"">产品分类</a>" & vbcrlf & "                               </td>" & vbcrlf & "                           <td align=""right"">" & vbcrlf & "                                        <a  href=""javascript:void(0)"" onClick=""colspanAll();"" class=""red""><u>显示分类</u></a>&nbsp;" & vbcrlf &                                   "<a  href=""javascript:void(0)"" id=""__tree_toggle_btn"" state="""
		Response.write fullTreeFlag
		Response.write """ " & vbcrlf & "                                                        onClick=""toggleAll(this);"" class=""red""><u>全部"
		Response.write iif(fullTreeFlag=1,"收缩","展开")
		Response.write "</u></a>" & vbcrlf & "                             </td>" & vbcrlf & "                   </tr>" & vbcrlf & "           </table>" & vbcrlf & "        </div>" & vbcrlf & "  "
		Dim rs5
		set rs5=conn.execute("select intro from setopen  where sort1=15")
		if rs5.eof then
			px_1=1
		else
			px_1=rs5("intro")
		end if
		rs5.close
		set rs5=conn.execute("select intro from setopen  where sort1=16 ")
		if rs5.eof then
			px=1
		else
			px=rs5("intro")
		end if
		rs5.close
		set rs5=conn.execute("select intro from setopen where sort1=17 ")
		if rs5.eof then
			B_2=1
		else
			B_2=rs5("intro")
		end if
		rs5.close
		if px=1 then
			px_Result=" order by c.date7 desc"
		elseif px=2 then
			px_Result=" order by c.date7 asc"
		elseif px=3 then
			px_Result=" order by c.title desc"
		elseif px=4 then
			px_Result=" order by c.title asc"
		elseif px=5 then
			px_Result=" order by c.order1 desc"
		elseif px=6 then
			px_Result=" order by c.order1 asc"
		elseif px=7 then
			px_Result=" order by c.type1 desc"
		elseif px=8 then
			px_Result=" order by c.type1 asc"
		end if
		str_Result="where del=1"
		if B="cpmc" then
			str_Result=str_Result+" and title like '%"& C &"%'"
'if B="cpmc" then
		elseif B="pym" then
			str_Result=str_Result+" and pym like '%"& C &"%'"
'elseif B="pym" then
		elseif B="cpbh" then
			str_Result=str_Result+" and order1 like '%"& C &"%'"
'elseif B="cpbh" then
		elseif B="cpxh" then
			str_Result=str_Result+" and type1 like '%"& C &"%'"
'elseif B="cpxh" then
		elseif B="txm" then
			str_Result=str_Result+" and ord in(select product from jiage where txm like '%"& C &"%')"
'elseif B="txm" then
		end if
		if px_1=1 then
			title_1="isnull(c.title,'')"
		elseif px_1=2 then
			title_1="isnull(c.order1,'')"
		elseif px_1=3 then
			title_1="isnull(c.type1,'')"
		elseif px_1=4 then
			title_1="isnull(c.title,'')+'('+isnull(c.order1,'')+')'"
'elseif px_1=4 then
		elseif px_1=5 then
			title_1="isnull(c.title,'')+'('+isnull(c.type1,'')+')'"
'elseif px_1=5 then
		elseif px_1=6 then
			title_1="isnull(c.order1,'')+'('+isnull(c.type1,'')+')'"
'elseif px_1=6 then
		ElseIf px_1 > 10 Then
			zdyid = px_1 Mod 10
			zdyfname = "isnull(c.zdy"&zdyid&",'')"
			If zdyid > 4 Then
				zdyfname = "isnull(st"&(zdyid-4)&".sort1,'')"
'If zdyid > 4 Then
			end if
			Select Case Int(px_1\10)
			Case 1
			title_1 = "isnull(c.title,'')+'('+"&zdyfname&"+')'"
'Case 1
			Case 3
			title_1 = "isnull(c.order1,'')+'('+"&zdyfname&"+')'"
'Case 3
			Case 5
			title_1 = "isnull(c.title,'')+'('+isnull(c.order1,'')+'，'+"&zdyfname&"+')'"
'Case 5
			Case 7
			title_1 = "isnull(c.title,'')+'('+isnull(c.type1,'')+'，'+"&zdyfname&"+')'"
'Case 7
			Case Else
			title_1="isnull(c.title,'')"
			End select
		else
			title_1="isnull(c.title,'')"
		end if
		Dim tree
		Set tree = New TreeClass
		tree.treeid="productTree"
		Set tree.cn = conn
		tree.onClick = "nodeClick(event,this);"
		Dim uuuurl : uuuurl = LCase(Request.ServerVariables("Url") & "")
		If (InStr(1,uuuurl, "/price/top",1) > 0 Or inStr(1,uuuurl, "/chance/top",1) > 0 Or  inStr(1,uuuurl, "/contract/top",1) > 0 ) And  inStr(1,uuuurl, "/contract/topkd.asp",1) = 0  then
			set rsjm=conn.execute("select num1 from setjm3 where ord=2018031301")
			if not rsjm.eof Then
				tree.ClsBatchSelect  =rsjm(0).value
			end if
			rsjm.close
			set rsjm=Nothing
		end if
		If treeType = "maintain" Then
			tree.params = "treeType=maintain"
			tree.treeType = "maintain"
			conn.cursorLocation = 3
			conn.execute "select ku.ck,ku.ord,SUM(ku.num2) num2 into #ku from ku "&_
			"                  inner join sortck ck on ku.ck=ck.ord and ck.del=1 and (cast(ck.intro as varchar(10))='0' "&_
			"                          or CHARINDEX(',"& actCate &",',','+cast(ck.intro as varchar(4000))+',')>0) "&_
			"                  where ku.num2>0 and ISNULL(ku.locked,0)=0 "&_
			"                  group by ku.ck,ku.ord having SUM(ku.num2)>0 "
			conn.execute "create table #cksort (id int,menuname nvarchar(50),sort2 int,gate1 int,id1 int,isnew int,i [int] IDENTITY(1,1) NOT NULL) "&_
			"                  declare @i int, @id1 int "&_
			"                  insert into #cksort (id,menuname,sort2,gate1,id1,isnew) "&_
			"                  select a.id,a.sort1 menuname,1 sort2, a.gate1, a.ParentID id1, 0 isnew from sortck1 a  "&_
			"                          inner join sortck b  on b.sort=a.id and b.del=1 and (cast(b.intro as varchar(10))='0'  "&_
			"                                  or CHARINDEX(',"& actCate &",',','+cast(b.intro as varchar(4000))+',')>0)  "&_
			"                          inner join (select distinct ck from #ku) kk on kk.ck=b.id   "&_
			"                  update #cksort set isnew=1 where id1>0 and id1 not in(select id from #cksort) "&_
			"                  set @i = 0 "&_
			"                  while exists(select top 1 1 from #cksort where id1>0 and isnew=1) "&_
			"                  begin "&_
			"                          set @i = i + 1 "&_
			"                          set @id1 = null "&_
			"                          select @id1 = id1 from #cksort where i=@i and id1>0 and isnew=1 "&_
			"                          if @id1 is not null "&_
			"                          begin            "&_
			"                                  insert into #cksort (id,menuname,sort2,gate1,id1,isnew) "&_
			"                                  select id,sort1 menuname,1 sort2,gate1,ParentID id1,(case ParentID when 0 then 0 else 1 end) isnew "&_
			"                                          from sortck1 where id=@id1 "&_
			"                                  update #cksort set isnew=0 where i=@i "&_
			"                          end "&_
			"                  end  "&_
			"                  select * into #ck from (  "&_
			"                  select id,menuname,sort2, gate1, id1 from #cksort "&_
			"                  union  "&_
			"                  select -id,sort1 menuname,2 sort2,gate1,sort id1 from sortck b  "&_
			"                          inner join (select distinct ck from #ku) kk on kk.ck=b.id  "&_
			"                          where del=1 and (cast(intro as varchar(10))='0' or  "&_
			"                          CHARINDEX(',"& actCate &",',','+cast(intro as varchar(4000))+',')>0)  "&_
			"                  ) m "
			conn.execute "select c.ord,c.title,c.order1,c.type1,c.date7,c.sort1,c.zdy1,c.zdy2,c.zdy3,c.zdy4,c.zdy5,c.zdy6 into #cp from product c "&_
			"                  inner join (select distinct ord from #ku) k on k.ord = c.ord "&_
			"                  where c.del=1 " & storeAtrrwhere & " and (c.user_list is null or replace(replace(replace(c.user_list,' ',''),',',''),'0','')='' " &_
			"                  or charindex(',"& actCate &",',','+replace(c.user_list,' ','')+',')>0) "
			tree.leafSql = "select c.ord," & title_1 & "title, isnull(k.ck,0) ck "&_
			"from #cp c "&_
			"inner join #ku k on k.ord=c.ord "&_
			"inner join #ck m on k.ck=abs(m.id) and m.sort2=2 " &_
			"left join sortonehy st1 on st1.ord=c.zdy5 " &_
			"left join sortonehy st2 on st2.ord=c.zdy6 " &_
			"where m.id=@pid and m.sort2=2 " & px_Result
			tree.cateSql =      "if @pid >= 0 /*仓库分类*/" &_
			"select m.id,m.menuname,isnull(mm.nCount,0) nCount,isnull(n.pCount,0) pCount from #ck m " &_
			"left join ( " &_
			"select count(k.ord) pCount,k.ck pid from #cp c "&_
			"inner join #ku k on k.ord=c.ord "&_
			"group by k.ck " &_
			") n on m.id=n.pid " &_
			"left join ( select count(*) nCount,id1 from #ck group by id1 ) mm on mm.id1=m.id  " &_
			"where m.id1=@pid order by m.gate1 desc, abs(m.id) " &_
			"else /*仓库*/" &_
			"select -m.id,m.menuname,0 nCount,isnull(n.pCount,0) pCount from #ck m " &_
			"left join ( " &_
			"select count(k.ord) pCount,k.ck pid from #cp c "&_
			"inner join #ku k on k.ord=c.ord "&_
			"group by k.ck " &_
			") n on m.id=n.pid " &_
			"left join ( select count(*) nCount,id1 from #ck group by id1 ) mm on mm.id1=m.id  " &_
			"where m.id1=abs(@pid) order by m.gate1 desc, abs(m.id)   "
		ElseIf treeType = "TC" Then
			tree.treeHeaderHtml = "<tr><td class='menu_gx2'><img src='../images/icon_sanjiao.gif' style='margin-left:4px;' /> <a id='cp0' href='javascript:;' funType='0'  name='统一规则' onclick='selectCP(0)'>统一规则</a></td></tr>"
'ElseIf treeType = "TC" Then
			tree.treeType = "TC"
			tree.onClick = ""
			tree.params = "treeType=TC"
			tree.leafSql =  "select c.ord id," & title_1 & "title,c.title pname,"&_
			"isnull(tcsort1,0) tcsort1,isnull(tcsort2,0) tcsort2 " &_
			"from product c " &_
			"left join sortonehy st1 on st1.ord=c.zdy5 " &_
			"left join sortonehy st2 on st2.ord=c.zdy6 " &_
			"inner join menu m on m.id=c.sort1 " &_
			"where c.del=1 " & storeAtrrwhere & " and "&_
			"(c.user_list is null or replace(replace(replace(c.user_list,' ',''),',',''),'0','')='' or "&_
			"charindex(',"& actCate &",',','+replace(c.user_list,' ','')+',')>0) and c.sort1=@pid" &_
			"and (m.user_list1 is null or isnull(m.user_list1,'0')='0' or m.user_list1=''  " &_
			"  or charindex(',"& actCate &",',','+replace(m.user_list1,' ','')+',')>0 " &_
			") " & px_Result
			tree.cateSql =      "select m.id,m.menuname,isnull(mm.nCount,0) nCount,isnull(n.pCount,0) pCount from (" & vbcrlf &_
			" select id,id1,menuname,gate1 from menu where @isFirstLoop = 0 " &_
			" union all " &_
			" select 0,0,'例外规则',99999999 where @isFirstLoop = 1 " &_
			") m " &_
			"left join ( " &_
			"select count(*) pCount,sort1 pid from product c where c.del=1 " & storeAtrrwhere & " and " &_
			"(c.user_list is null or replace(replace(replace(c.user_list,' ',''),',',''),'0','')='' or " &_
			"charindex(',"& actCate &",',','+replace(c.user_list,' ','')+',')>0) " &_
			"group by sort1 " &_
			") n on m.id=n.pid " &_
			"left join ( " &_
			"select count(*) nCount,id1 from menu group by id1 " &_
			") mm on mm.id1=m.id " &_
			"where m.id1=@pid order by m.gate1 desc,m.id asc"
		else
			tree.params = ""
			tree.treeType = ""
			tree.leafSql =  "select c.ord id," & title_1 & "title "&_
			"from product c " &_
			"left join sortonehy st1 on st1.ord=c.zdy5 " &_
			"left join sortonehy st2 on st2.ord=c.zdy6 " &_
			"inner join menu m on m.id=c.sort1 " &_
			"where c.del=1 " & storeAtrrwhere & " and "&_
			"(c.user_list is null or replace(replace(replace(c.user_list,' ',''),',',''),'0','')='' or "&_
			"charindex(',"& actCate &",',','+replace(c.user_list,' ','')+',')>0) and c.sort1=@pid" &_
			"and (m.user_list1 is null or isnull(m.user_list1,'0')='0' or m.user_list1=''  " &_
			"  or charindex(',"& actCate &",',','+isnull(m.user_list1,'0')+',')>0 " &_
			") " & px_Result
			tree.cateSql =      "select m.id,m.menuname,isnull(mm.nCount,0) nCount,isnull(n.pCount,0) pCount from menu m " &_
			"left join ( " &_
			"select count(*) pCount,sort1 pid from product c where c.del=1 " & storeAtrrwhere & " and " &_
			"(c.user_list is null or replace(replace(replace(c.user_list,' ',''),',',''),'0','')='' or " &_
			"charindex(',"& actCate &",',','+replace(c.user_list,' ','')+',')>0) " &_
			"group by sort1 " &_
			") n on m.id=n.pid " &_
			"left join ( " &_
			"select count(*) nCount,id1 from menu group by id1 " &_
			") mm on mm.id1=m.id " &_
			"where m.id1=@pid "&_
			"and (m.user_list1 is null or isnull(m.user_list1,'0')='0' or m.user_list1=''  " &_
			"  or charindex(',"& actCate &",',','+replace(m.user_list1,' ','')+',')>0 " &_
			") " &_
			"order by m.gate1 desc,m.id asc"
		end if
		tree.leafPageSize=num25
		tree.nodePageSize=num2014062802
		tree.nodeLimit=num2014062801
		tree.leafLimit=num24
		tree.ShowOnlyCanStoreProduct = ShowOnlyCanStoreProduct
		tree.ShowOnlyHaszzInfo=ShowOnlyHaszzInfo
		tree.ShowOnlyHasBomProduct = ShowOnlyHasBomProduct
		tree.cascade = (fullTreeFlag = 1)
		tree.tree
		Response.write "" & vbcrlf & "     <div id='cp_search'>    " & vbcrlf & "        </div>" & vbcrlf & "  <form method=""post""  id=""txmfrom""  name=""txmfrom"" style=""width:0; height:0;border:0 0 0 0;margin: 0px;padding: 0px;position:fixed;_position:absolute;top:1px;_top:90%;left:1px"">" & vbcrlf & "                <input name=""txm"" autocomplete=""off"" type=""text"" style="" width:1px; height:1px; border:0 0 0 0;margin: 0px;padding: 0px;"" onkeypress=""if(event.keyCode==13) {TxmAjaxSubmit("
		Response.write iif(returnUnit&""<>"","'returnUnit'","")
		Response.write ");this.value='';unEnterDown();return PreventBrowserDefaultBehavior()}"" onFocus=""this.value=''"" size=""10"">" & vbcrlf & "             <input name=""top"" type=""hidden"" size=""2""  value="""
		Response.write top
		Response.write """>" & vbcrlf & "        </form>" & vbcrlf & " <div id=""adsDiv"" style=""position:absolute;z-index:2000;left:-10000px;"">" & vbcrlf & "     "
		'Response.write top
		ly = ""
		If treeType = "maintain" Then
			ly = "?ly=yanghu"
		end if
		Response.write "" & vbcrlf & "     <iframe src="""
		Response.write GetVirPath()
		Response.write "inc/productADSearch.asp"
		Response.write ly
		Response.write """ id=""adsIF"" " & vbcrlf & "               onload=""$(this.contentWindow.document.body).trigger('click');"" " & vbcrlf & "           width=""400px"" frameborder=""0"" border=""0"" scrolling=""yes""></iframe>" & vbcrlf & "      </div>" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "      var __esc = escape;" & vbcrlf & "   escape = function (data){" & vbcrlf & "               //return escape(sStr).replace(/\+/g, '%2B').replace(/\""/g,'%22').replace(/\'/g, '%27').replace(/\//g,'%2F');" & vbcrlf & "         var ascCodev = ""& ﹙ ﹚ ﹛ ﹜ ＋ － × ÷ ﹢ ﹣ ≠ ≤ ≥ ≈ ≡ ≒ ∥ ／ ± ＜ ＞ ﹤ ﹥ ≦ ＝ ≧ ≌ ∽ ≮ ≯ ∶ ∴ ∵ ∷ ⊙ ∑ ∏ ∪ ∩ ∈ ⌒ ⊥ ∠ ㏑ ￠ ㏒ ∟ √ ∨ ∧ ∞ ∝ ∮ ∫ ％ ‰ ℅ ° ℃ ℉ ′ ″ 〒 ¤ ○ ￡ ￥ ㏕ ♂ ♀ △ ▽ ● ○ ◇ □ · — ˉ ¨ 々 ～ ‖ 」 「 『 』 ． 〖 〗 【 】 € ‰ ◆ ◎ ★ ☆ § ā á ǎ à ō ó ǒ ò ê ē é ě è ī í ǐ ì ū ú ǔ ù ǖ ǘ ǚ ǜ ü μ μ ˊ ﹫ ＿ ﹌ ﹋ ′ ˋ ― ︴ ˉ ￣ θ ε ‥ ☉ ⊕ Θ ◎ の ⊿ … ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ ▉ ▊ ▋ ▌ ▍ ▎ ▏ ⌒ ￠ ℡ ㈱ ㊣ ▏ ▕ ▁ ▔ ↖ ↑ ↗ → ← ↙ ↓ ↘ 卍 ◤ ◥ ◢ ◣ 卐 ∷ № § Ψ ￥ ￡ ≡ ￢ ＊ Ю"".split("" "");" & vbcrlf & "           var ascCodec = ""%26+%A9v+%A9w+%A9x+%A9y+%A3%AB+%A3%AD+%A1%C1+%A1%C2+%A9%80+%A9%81+%A1%D9+%A1%DC+%A1%DD+%A1%D6+%A1%D4+%A8P+%A1%CE+%A3%AF+%A1%C0+%A3%BC+%A3%BE+%A9%82+%A9%83+%A8Q+%A3%BD+%A8R+%A1%D5+%A1%D7+%A1%DA+%A1%DB+%A1%C3+%A1%E0+%A1%DF+%A1%CB+%A1%D1+%A1%C6+%A1%C7+%A1%C8+%A1%C9+%A1%CA+%A1%D0+%A1%CD+%A1%CF+%A9R+%A1%E9+%A9S+%A8N+%A1%CC+%A1%C5+%A1%C4+%A1%DE+%A1%D8+%A1%D3+%A1%D2+%A3%A5+%A1%EB+%A8G+%A1%E3+%A1%E6+%A8H+%A1%E4+%A1%E5+%A8%93+%A1%E8+%A1%F0+%A1%EA+%A3%A4+%A9T+%A1%E1+%A1%E2+%A1%F7+%A8%8C+%A1%F1+%A1%F0+%A1%F3+%A1%F5+%a1%a4+%a1%aa+%a1%a5+%a1%a7+%a1%a9+%a1%ab+%a1%ac+%a1%b9+%a1%b8+%a1%ba+%a1%bb+%a3%ae+%a1%bc+%a1%bd+%a1%be+%a1%bf+%80+%a1%eb+%a1%f4+%a1%f2+%a1%ef+%a1%ee+%a1%ec+%a8%a1+%a8%a2+%a8%a3+%a8%a4+%a8%ad+%a8%ae+%a8%af+%a8%b0+%a8%ba+%a8%a5+%a8%a6+%a8%a7+%a8%a8+%a8%a9+%a8%aa+%a8%ab+%a8%ac+%a8%b1+%a8%b2+%a8%b3+%a8%b4+%a8%b5+%a8%b6+%a8%b7+%a8%b8+%a8%b9+%a6%cc+%a6%cc+%a8%40+%a9%88+%a3%df+%a9k+%a9j+%a1%e4+%a8A+%a8D+%a6%f5+%a1%a5+%a3%fe+%a6%c8+%a6%c5+%a8E+%a8%91+%a8%92+%a6%a8+%a1%f2+%a4%ce+%a8S+%a1%ad+%a8x+%a8y+%a8z+%a8%7b+%a8%7c+%a8%7d+%a8%7e+%a8%80+%a8%81+%a8%82+%a8%83+%a8%84+%a8%85+%a8%86+%a8%87+%a1%d0+%a1%e9+%a9Y+%a9Z+%a9I+%a8%87+%a8%8a+%a8x+%a8%89+%a8I+%a1%fc+%a8J+%a1%fa+%a1%fb+%a8L+%a1%fd+%a8K+%85d+%a8%8f+%a8%90+%a8%8d+%a8%8e+%85e+%a1%cb+%a1%ed+%a1%ec+%a6%b7+%a3%a4+%a1%ea+%a1%d4+%a9V+%a3%aa+%a7%c0"".split(""+"");" & vbcrlf & "          data = data + '';" & vbcrlf & "               data = data.replace(/\s/g, ""kglllskjdfsfdsdwerr"");" & vbcrlf & "                data = data.replace(/\+/g, ""abekdalfdajlkfdajfda"");" & vbcrlf &               "data = __esc(data);" & vbcrlf &              "if(data.indexOf(""%B5"")>-1){" & vbcrlf &                        "data = data.replace(""%B5"",""%u03BC"")" & vbcrlf &          "}" & vbcrlf &                "data = unescape(data);" & vbcrlf &           "if (!isNaN(data) || !data) { return data; }" & vbcrlf &              "for (vari = 0; i < ascCodev.length; i++) {" & vbcrlf & "                 var re = new RegExp(ascCodev[i], ""g"")" & vbcrlf & "                     data = data.replace(re, ""ajaxsrpchari"" + i + ""endbyjohnny"");" & vbcrlf & "                        re = null;" & vbcrlf & "              }" & vbcrlf & "               data = __esc(data);" & vbcrlf & "             " & vbcrlf & "                for (var i = ascCodev.length - 1; i > -1; i--) {" & vbcrlf & "                     var re = new RegExp(""ajaxsrpchari"" + i + ""endbyjohnny"", ""g"")" & vbcrlf & "                  data = data.replace(re, ascCodec[i]);" & vbcrlf & "           }" & vbcrlf & "               data = data.replace(/\*/g, ""%2A"");        //置换*         " & vbcrlf & "                data = data.replace(/\-/g, ""%2D"");        //置换-" & vbcrlf & "             data = data.replace(/\./g, ""%2E"");        //置换." & vbcrlf & "         data = data.replace(/\@/g, ""%40"");        //置换@" & vbcrlf & "         data = data.replace(/\_/g, ""%5F"");        //置换_" & vbcrlf & "         data = data.replace(/\//g, ""%2F"");        //置换/" & vbcrlf & "         data = data.replace(/kglllskjdfsfdsdwerr/g,""%20"")" & vbcrlf & "               data = data.replace(/abekdalfdajlkfdajfda/g,""%2B"");" & vbcrlf & "               return data;" & vbcrlf & "    }" & vbcrlf & "" & vbcrlf & "       var top = '"
		Response.write top
		Response.write "';" & vbcrlf & "   function colspanAll(){" & vbcrlf & "          if($('#__tree_toggle_btn').attr('state')=='2') return;" & vbcrlf & "" & vbcrlf & "          $.ajax({" & vbcrlf & "                        url:'"
		Response.write GetVirPath()
		Response.write "store/CommonReturn.asp'," & vbcrlf & "                     data:{act:'leftlist',leftlist:1}," & vbcrlf & "                       async:false," & vbcrlf & "                    cache:false," & vbcrlf & "                    success:function(r){" & vbcrlf & "                            $('#__tree_toggle_btn').attr('state','2').html('<u>全部展开</u>');" & vbcrlf & "                              $('#cp_search').hide();" & vbcrlf & "                         $('#productTree').show();" & vbcrlf & "                               $('.tree-lastfolder-open,.tree-folder-open').trigger('click');" & vbcrlf & "                  }" & vbcrlf & "               });" & vbcrlf & "     }" & vbcrlf & "" & vbcrlf & "       function expandAll(){" & vbcrlf & "           $.ajax({" & vbcrlf & "                        url:'"
		'Response.write GetVirPath()
		Response.write GetVirPath()
		Response.write "store/CommonReturn.asp'," & vbcrlf & "                     data:{act:'leftlist',leftlist:2}," & vbcrlf & "                       async:false," & vbcrlf & "                    cache:false," & vbcrlf & "                    success:function(r){" & vbcrlf & "                            $('#__tree_toggle_btn').attr('state','1').html('<u>全部收缩</u>');" & vbcrlf & "                              $('#cp_search').hide();" & vbcrlf & "                         $('#productTree').show();" & vbcrlf & "                               $('.tree-lastfolder-closed,.tree-folder-closed').each(function(){" & vbcrlf & "                                       __toggleNode(this,true);" & vbcrlf & "                                });" & vbcrlf & "                     }" & vbcrlf & "               });" & vbcrlf & "     }" & vbcrlf & "" & vbcrlf & "       function toggleAll(obj){" & vbcrlf & "             $(obj).attr(""state"")!='1'?expandAll():colspanAll();" & vbcrlf & "       }" & vbcrlf & "       " & vbcrlf & "        function __TreeClsClick(oEvent, nodeId){" & vbcrlf & "                oEvent.cancelBubble = true;" & vbcrlf & "        try{oEvent.stopPropagation();}catch(ex){}" & vbcrlf & "            xmlHttp.open(""GET"", '"
		Response.write GetVirPath()
		Response.write "inc/LeftAddChildItems.asp?nodeID=' + nodeId , false);" & vbcrlf & "                xmlHttp.send(null); " & vbcrlf & "            var ids =  xmlHttp.responseText;" & vbcrlf & "                if(ids.length>0) {" & vbcrlf & "                      var td = document.createElement(""td"");" & vbcrlf & "                    td.setAttribute(""nid"", ids);" & vbcrlf & "                      nodeClick(oEvent,  td);" & vbcrlf & "               }" & vbcrlf & "               return false;" & vbcrlf & "   }" & vbcrlf & "" & vbcrlf & "       window.searchModel = 0;" & vbcrlf & " function quickSearch(){" & vbcrlf & "         $('#productTree').hide();" & vbcrlf & "               $('#cp_search').show();" & vbcrlf & "         ajaxSubmit(0, """
		Response.write hasCheckBox
		Response.write """, """
		Response.write outProductStr
		Response.write """);" & vbcrlf & "               try {" & vbcrlf & "                   callServer4(0, '');" & vbcrlf & "             } catch (e) { }" & vbcrlf & "         window.searchModel = 0;" & vbcrlf & "         parent.searchModel = 0;" & vbcrlf & " }" & vbcrlf & "" & vbcrlf & "       function nodeClick(e,node){" & vbcrlf & "             callServer4($(node).attr('nid'),'"
		Response.write top
		Response.write "');" & vbcrlf & "  }" & vbcrlf & "" & vbcrlf & "       function ajaxSubmit_page(sort1,pagenum,callBack){" & vbcrlf & "               $('#productTree').hide();" & vbcrlf & "               $('#cp_search').show();" & vbcrlf & "         //获取用户输入" & vbcrlf & "          var B=document.forms[0].B.value;" & vbcrlf & "                var C=(document.forms[0].C.value==$(""#txtKeywords"").get(0).defaultValue?"""":document.forms[0].C.value);" & vbcrlf & "               var top=document.forms[0].top.value;" & vbcrlf & "            var url = """
		Response.write GetVirPath()
		Response.write iif(treeType="TC","xstc","contract")
		Response.write "/search_cp.asp?P=""+pagenum+""&B=""+ B +""&C=""+ encodeURIComponent(C) +""&top=""+escape(top) +""&cstore="
		'Response.write iif(treeType="TC","xstc","contract")
		Response.write abs(ShowOnlyCanStoreProduct)
		Response.write "&cbom="
		Response.write abs(ShowOnlyHasBomProduct)
		Response.write "&sort1=""+escape(sort1) + ""&hasCheckBox="
		Response.write abs(ShowOnlyHasBomProduct)
		Response.write hasCheckBox
		Response.write "&outProductStr="
		Response.write outProductStr
		Response.write "&timestamp="" + new Date().getTime() + ""&date1=""+ Math.round(Math.random()*100);" & vbcrlf & "             try{" & vbcrlf & "                    if(window.searchModel==1){" & vbcrlf & "                              //处理高级搜索" & vbcrlf & "                          var ifcobj=document.getElementById(""adsIF"").contentWindow.document;" & vbcrlf & "                               var sobj=ifcobj.getElementsByTagName(""input"");" & vbcrlf & "                          var txValue="""";" & vbcrlf & "                           for(var i=0;i<sobj.length;i++){" & vbcrlf & "                                 var sk = $(sobj[i]).attr(""sk"");" & vbcrlf & "                                   if(sk && $(sobj[i]).attr(""type"")=='text'&& sobj[i].value!=''){" & vbcrlf & "                                        txValue+=(txValue==""""?"""":""&"")+sk+""=""+encodeURIComponent(sobj[i].value);" & vbcrlf & "                                 }" & vbcrlf & "                               }" & vbcrlf & "                               sobj=ifcobj.getElementsByTagName(""select"");" & vbcrlf & "                               for(var i=0;i<sobj.length;i++){" & vbcrlf & "                                 var sk = $(sobj[i]).attr(""sk"");" & vbcrlf & "                                   if(sk&&sobj[i].value!=''){"& vbcrlf & "                                              txValue+=(txValue==""""?"""":""&"")+sk+""=""+escape(sobj[i].value);" & vbcrlf & "                                     }" & vbcrlf & "                               }" & vbcrlf & "                               sobj=ifcobj.getElementsByName(""A2"");" & vbcrlf & "                              var tmp="""";" & vbcrlf & "                               for(var i=0;i<sobj.length;i++){" & vbcrlf & "                                 if(sobj[i].checked){" & vbcrlf & "                                            tmp+=(tmp==""""?"""":"","")+escape(sobj[i].value);" & vbcrlf & "                                  }" & vbcrlf & "                               }" & vbcrlf & "                               txValue+=(tmp==""""?"""":(txValue==""""?"""":""&"")+""A2=""+tmp)" & vbcrlf & "                                url="""
		Response.write GetVirPath()
		Response.write iif(treeType="TC","xstc","contract")
		Response.write "/search_cp.asp?ads=1""+(txValue==""""?"""":""&"")+txValue+""&P=""+pagenum+""&top=""+escape(top) +""&cstore="
		'Response.write iif(treeType="TC","xstc","contract")
		Response.write abs(ShowOnlyCanStoreProduct)
		Response.write "&cbom="
		Response.write abs(ShowOnlyHasBomProduct)
		Response.write "&sort1=""+escape(sort1) + ""&hasCheckBox="
		Response.write abs(ShowOnlyHasBomProduct)
		Response.write hasCheckBox
		Response.write "&outProductStr="
		Response.write outProductStr
		Response.write "&timestamp="" + new Date().getTime() + ""&date1=""+ Math.round(Math.random()*100);" & vbcrlf & "                     }       " & vbcrlf & "                }catch (e){}" & vbcrlf & "            xmlHttp.open(""GET"", url, false);" & vbcrlf & "          xmlHttp.onreadystatechange = function(){" & vbcrlf & "                        if (xmlHttp.readyState < 4) return;" & vbcrlf & "                    updatePage_cp(callBack);" & vbcrlf & "                };" & vbcrlf & "              xmlHttp.send(null);  " & vbcrlf & "   }" & vbcrlf & "" & vbcrlf & "       var xmlHttpNode = GetIE10SafeXmlHttp();" & vbcrlf & " function TxmAjaxSubmit(returnUnit){" & vbcrlf & "             //获取用户输入" & vbcrlf & "          var TxmID=document.txmfrom.txm.value;"& vbcrlf &             "if (TxmID.length ==0){return;}" & vbcrlf &           "var top=document.txmfrom.top.value;" & vbcrlf &              "if (TxmID.indexOf(""："")>=0)" & vbcrlf &                "{" & vbcrlf &                        "//多行文本内容，二维码文本编码.task.2355.binary.2014.12" & vbcrlf &                  "if( TxmID.indexOf(""流水号："")==0) { sendTxmRequest(top, TxmID); }" & vbcrlf & "                 return;" & vbcrlf & "         }" & vbcrlf & "               if (TxmID.toLowerCase().indexOf(""view.asp?v"")>0)" & vbcrlf & "          {" & vbcrlf & "                       //网址信息，可能是二维码URL编码" & vbcrlf & "                 TxmID = ""QrUrl="" + TxmID.split(""view.asp?"")[1];" & vbcrlf & "             }" & vbcrlf & "               sendTxmRequest(top,TxmID,returnUnit); // 常规单行条码" & vbcrlf & "      }" & vbcrlf & "" & vbcrlf & "       function sendTxmRequest(top,TxmID,returnUnit) {" & vbcrlf & "         returnUnit = returnUnit || '';" & vbcrlf & "          var url = """
		Response.write GetVirPath()
		Response.write "product/txmRK.asp?txm=""+escape(TxmID)+""&top=""+escape(top) +""&cstore="
		Response.write GetVirPath()
		Response.write abs(ShowOnlyCanStoreProduct)
		Response.write "&returnUnit="" + returnUnit + ""&timestamp="" + new Date().getTime() + ""&date1=""+ Math.round(Math.random()*100);" & vbcrlf & "         xmlHttp.open(""GET"", url, false);" & vbcrlf & "          xmlHttp.onreadystatechange = function(){" & vbcrlf & "                        updateTxm(top,returnUnit);" & vbcrlf & "              };" & vbcrlf & "xmlHttp.send(null);"  & vbcrlf &     "}" & vbcrlf & vbcrlf &        "function updateTxm(x1,returnUnit) {" & vbcrlf &              "returnUnit = returnUnit || '';" & vbcrlf &           "if (xmlHttp.readyState < 4) {" & vbcrlf &            "//      cp_search.innerHTML=""loading..."";" & vbcrlf &          "}" & vbcrlf &                "if (xmlHttp.readyState == 4) {" & vbcrlf & "                 var response = xmlHttp.responseText;" & vbcrlf & "                    // alert(response);" & vbcrlf & "                     response=response.split(""</noscript>"");" & vbcrlf & "                   //alert(response[1]);" & vbcrlf & "                   response[1] = (response[1])?response[1]:0;" & vbcrlf & "                      if (response[1] != ''){" & vbcrlf & "                          if (returnUnit != ''){" & vbcrlf & "                                  callServer4(response[1].split(',')[0],x1,response[1].split(',')[1]);" & vbcrlf & "                            }else{" & vbcrlf & "                                  callServer4(response[1],x1);" & vbcrlf & "                            }" & vbcrlf & "                       }else{" & vbcrlf & "                          alert(""产品不存在"");" & vbcrlf & "                      }" & vbcrlf &"         }" & vbcrlf & "       }" & vbcrlf & "       " & vbcrlf & "        function selectAllProduct(obj){" & vbcrlf & "         $("".productclsid"").attr(""checked"",obj.checked);" & vbcrlf & "     }" & vbcrlf & "" & vbcrlf & "       function addProductClick(){" & vbcrlf & "             $(""input[class=productclsid]:checked"").each(function(){" & vbcrlf & "                   callServer4(this.value,'');" & vbcrlf & "             });" & vbcrlf & "     }" & vbcrlf & "" & vbcrlf & "       function Left_adSearch(obj){" & vbcrlf & "            var sdivobj=document.getElementById(""adsDiv"");" & vbcrlf & "            if(sdivobj.style.display!=""none""){" & vbcrlf & "                        Left_adClose();" & vbcrlf & "         }else{"& vbcrlf &                     "var x=obj.offsetLeft,y=obj.offsetTop;" & vbcrlf &                    "var obj2=obj;" & vbcrlf &                    "var offsetx=0;" & vbcrlf &                   "while(obj2=obj2.offsetParent){" & vbcrlf &                           "x+=obj2.offsetLeft;" & vbcrlf &                              "y+=obj2.offsetTop;" & vbcrlf &                       "}" & vbcrlf &                        "sdivobj.style.left=x+50+""px"";" & vbcrlf & "                   sdivobj.style.top=y+""px"";" & vbcrlf & "                 sdivobj.style.display=""inline"";" & vbcrlf & "           }" & vbcrlf & "               document.getElementById('adsIF').style.height=document.getElementById('adsIF').contentWindow.document.getElementsByTagName('table')[1].offsetHeight+160+'px';" & vbcrlf & "   }" & vbcrlf & "" & vbcrlf & "   function Left_adClose(){" & vbcrlf & "                document.getElementById('adsDiv').style.display=""none"";" & vbcrlf & "   }" & vbcrlf & "       window.ShowOnlyCanStoreProduct = "
		Response.write abs(ShowOnlyCanStoreProduct)
		Response.write ";" & vbcrlf & "    window.ShowOnlyHasBomProduct = "
		Response.write abs(ShowOnlyHasBomProduct)
		Response.write ";" & vbcrlf & "</script>" & vbcrlf & ""
	end sub
	Call ShowLeftTree
	Response.write "" & vbcrlf & "</td>" & vbcrlf & "<td valign=""top"" style=""padding-left:20px"">" & vbcrlf & "<form method=""post"" action=""savelistzz.asp?top="
	Response.write top
	Response.write """ target=""sumitFrame"" id=""demo"" onSubmit=""return Validator.Validate(this,2) && checkFormSubmit()"" name=""date"">" & vbcrlf & "<table width=""1200"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "<tr>" & vbcrlf & "<td width=""100%"" valign=""center"" class=""nopadding32"">" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "    <tr>" & vbcrlf & "    <td class=""place"">父件清单</td>" & vbcrlf & "    <td><div>&nbsp;<input type=""submit"" name=""Submit4222"" value=""保存清单""  class=""anybutton2""/>" & vbcrlf & "         &nbsp;&nbsp;&nbsp;&nbsp;<input type=""reset"" name=submit2  value=""重新填写"" class=""anybutton2""/></div></td>" & vbcrlf & "    <td align=""right"">"
	if session("pro1zbintel2007")="1" then
		Response.write "<input type=""button"" name=""Submit3"" value=""添加产品""  onClick=""javascript:window.open('../product/add_list.asp?ord="
		Response.write pwurl(89)
		Response.write "','newwproductin','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150')"" class=""anybutton""/>"
		'Response.write pwurl(89)
	end if
	Response.write "</td>" & vbcrlf & "    <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "    </tr>" & vbcrlf & "</table>" & vbcrlf & "<table width=""100%"" class=""resetTransparent bgfff detailTable""  border=""0"" cellpadding=""3""  background=""../images/112.gif"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;table-layout:fixed;""> "& vbcrlf &  " <tr>                "           & vbcrlf &""
	'Response.write pwurl(89)
	set rs = colrs : colrs.movefirst
	j=0
	while Not rs.eof
		sorce=rs("sorce")
		kd=rs("kd")
		If j=0 Then
			pl=""
		else
			pl=""
		end if
		Select Case sorce
		case 4:
		Response.write "" & vbcrlf & "                    <td width="""
		Response.write kd
		Response.write """ height='26' style=''>"
		Response.write pl
		Response.write "</td>" & vbcrlf & "                    "
		if isOpenProductAttrV then
			Response.write "" & vbcrlf & "                        <td width=""90"" height='26' style=''>"
			Response.write pl
			Response.write "</td>" & vbcrlf & "                        <td width=""90"" height='26' style=''>"
			Response.write pl
			Response.write "</td>" & vbcrlf & "                    "
		end if
		case 5:
		if isOpenAssUnit then
			if isFixAssRat then readonly="readonly"
			Response.write "<td width='"
			Response.write kd
			Response.write "' height='26' style=''>"
			Response.write pl
			Response.write "</td>" & vbcrlf & "                                    <td  width='70' align='center' style=''><div align='center'>批量录入：</div></td>" & vbcrlf & "                                    <td  width='70' align='center' style=''> " & vbcrlf & "                                        <div align=""center"">" & vbcrlf & "                                            <strong>" & vbcrlf & "                                                <input name="""" type=""text"" id=""assistNumAll"" size=""9"" "
			Response.write readonly
			Response.write " onpropertychange=""assistNumBatchInput()"" style=""height: 19px; solid;font-size: 9pt;""  onkeyup=value=value.replace(/[^\d\.]/g,'');checkDot(""assistNumAll"","""
			'Response.write readonly
			Response.write num1_dot
			Response.write """);>" & vbcrlf & "" & vbcrlf & "                                            </strong>" & vbcrlf & "                                        </div>" & vbcrlf & "                                    </td>" & vbcrlf & "                                "
		else
			Response.write "<td width='"&kd&"' height='26' style=''>"&pl&"</td>"
		end if
		case 6 :
		Response.write "<td width='"&kd&"' height='26' style='"& displayStr &"'>"&pl&"</td>"
		Case 7 :
		if not isOpenAssUnit then
			batchInput="<div align='center'>批量录入：</div>"
		end if
		Response.write "<td width='"&kd&"' height='26' style='"& displayStr &"'>"&batchInput&"</td>"
		Case 8 :
		Response.write "" & vbcrlf & "                                <td width='195px' height='26' style=''><div align='center'>" & vbcrlf & "                                                  "
		if proStore<>1 then
			Response.write "" & vbcrlf & "                                                             <table style='width:100%' cellspacing=0 cellpadding=0><tr><td width=""179px;"">" & vbcrlf & "                                                             <input type='hidden' name=""dfggck"" id=""ckall_2"" text='' onChange=""ckk()"">" & vbcrlf & "                                                             <div style='float:left;'><input style='float:left;' id='for_ckall_2' type='button' class='storeButton'></div>" & vbcrlf & "                                                             </td><td style='width:16px;'><img  style='cursor:pointer;' src='../images/11645.png' onClick=""showStoreDlg('ckall_2')""></td>" & vbcrlf & "                                                              </tr></table>" & vbcrlf & "                                                   "
		end if
		Response.write "" & vbcrlf & "                                                     </div></td>" & vbcrlf & "                                                     "
		Case 9 :
		Response.write "" & vbcrlf & "                                                             <td width='"
		Response.write kd
		Response.write "' height='26' style=''>" & vbcrlf & "                                                              <div align=""center""><strong><input name=""num3353all"" type=""text"" id=""phall"" size=""9""   onpropertychange=""ph()"" style='height: 19px; solid;font-size: 9pt;'  dataType='Limit' max='50' msg='不要超过50个字'></strong></div></td>" & vbcrlf & "                                             "
		Case 11 :
		Response.write "" & vbcrlf & "                                                             <td  width="""
		Response.write kd
		Response.write """ style=""""><div align=""center""><strong><INPUT name=ret7 size=9  onpropertychange=""datesc()"" onchange=""datesc()"" id=""daysOfMonth7Pos"" readonly=true onMouseUp=""toggleDatePicker('daysOfMonth7','date.ret7')""  style='height: 19px; solid;font-size: 9pt;'><DIV id=daysOfMonth7 style=""POSITION: absolute""></DIV></strong></div></td>" & vbcrlf & "                                                      "
		Case 12 :
		Response.write "" & vbcrlf & "                                                             <td  width="""
		Response.write kd
		Response.write """ style=""""><div align=""center""><strong><INPUT name=ret8 size=9  onpropertychange=""dateyx()"" onchange=""dateyx()""id=""daysOfMonth8Pos"" readonly=true onMouseUp=""toggleDatePicker('daysOfMonth8','date.ret8')""  style='height: 19px; solid;font-size: 9pt;'><DIV id=daysOfMonth8 style=""POSITION: absolute""></DIV></strong></div></td>" & vbcrlf & "                                                               "
		Case 13 :
		Response.write "" & vbcrlf & "                                                                     <td  width="""
		Response.write kd
		Response.write """ style=""""><div align=""center"">" & vbcrlf & "                                                                       <select name=""bzall""  id=""bzall""  onpropertychange=""bz()"" onchange=""bz()"" >" & vbcrlf & "                                                                             <option value=""""></option>" & vbcrlf & "                                                                                "
		set rs2=server.CreateObject("adodb.recordset")
		sql2="select ord,sort1 from sortonehy where gate2=82 order by gate1 desc"
		rs2.open sql2,conn,1,1
		do until rs2.eof
			Response.write "" & vbcrlf & "                                                                             <option value="""
			Response.write rs2("ord")
			Response.write """>"
			Response.write rs2("sort1")
			Response.write "</option>" & vbcrlf & "                                                                            "
			rs2.movenext
		loop
		rs2.close
		set rs2=nothing
		Response.write "" & vbcrlf & "                                                                     </select>" & vbcrlf & "                                                                       </div></td>" & vbcrlf & "                                                             "
		Case else :
		Response.write "<td width='"&kd&"' height='26' style=''>"&pl&"</td>"
		End Select
		j=j+1
'End Select
		rs.movenext
	wend
	Set rs=Nothing
	Response.write "" & vbcrlf & "     </tr>" & vbcrlf & "   </table>" & vbcrlf & "        <table width=""100%"" class=""resetTransparent"" border=""0"" cellpadding=""3""  background=""../images/112.gif"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;table-layout:fixed;"">" & vbcrlf & "     <tr class=""top""> "& vbcrlf & vbcrlf
	num1_ls=0
	adressNum1=0
	set rs = colrs : colrs.movefirst
	If Not rs.eof Then
		do until rs.eof
			sorce=rs("sorce")
			kd=rs("kd")
			Select Case sorce
			Case 1 :
			Response.write "<td width='"&kd&"' height='26' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 1 :
			Case 2 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 2 :
			Case 3 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 3 :
			Case 4 :
			if isOpenProductAttrV then
				Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"&_
				"<td  width='90' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>产品属性1</strong></div></td>"&_
				"<td  width='90' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>产品属性2</strong></div></td>"
'if isOpenProductAttrV then
			else
				Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'if isOpenProductAttrV then
			end if
			Case 5 :
			if isOpenAssUnit then
				Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"&_
				"<td  width='70' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>辅助单位</strong></div></td>"&_
				"<td  width='70' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>辅助数量</strong></div></td>"
'if isOpenAssUnit then
			else
				Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'if isOpenAssUnit then
			end if
			Case 6 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;"& displayStr &"'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 6 :
			Case 7 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;"& displayStr &"'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 7 :
			Case 8 :
			Response.write "<td  width='195px' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 8 :
			Case 9 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 9 :
			Case 10 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 10 :
			Case 11 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 11 :
			Case 12 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 12 :
			Case 13 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 13 :
			Case 14 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 14 :
			Case 15 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 15 :
			Case 16 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 16 :
			Case 17 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 17 :
			Case 18 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 18 :
			Case 19 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 19 :
			Case 20 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 20 :
			Case 21 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 21 :
			End Select
			If rs("sorce")=5 Then
				adressNum1=num1_ls
			end if
			num1_ls=num1_ls+1
			adressNum1=num1_ls
			rs.movenext
		Loop
	end if
	set rs = nothing
	Response.write "" & vbcrlf & "     </tr>" & vbcrlf & "</table>" & vbcrlf & ""
	Dim qxOpen,qxIntro
	sdk.setup.getpowerattr 21,14,qxOpen, qxIntro
	sqls = "select * from kuinlist where caigou="&top&" and sort1=9  and addcate="&session("personzbintel2007")&" and del=7 order by date7 asc,id asc"
	set rss = server.CreateObject("adodb.recordset")
	rss.open sqls,conn,1,1
	m=1
	if rss.eof then
		Response.write "" & vbcrlf & "<span id=""trpx0"">" & vbcrlf & "<table width=""100%"" border=""0""  cellpadding=""3"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;"" class=""bgfff"">" & vbcrlf & "<tr >" & vbcrlf & "   <td height=""30"" style=""border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;"" id=""nomc"">无产品明细！</td>" & vbcrlf & "       </tr>" & vbcrlf & "</table>" & vbcrlf & "</span>" & vbcrlf & ""
'if rss.eof then
	else
		m=0
		us_i=1
		do until rss.eof
			caigoulist=rss("id")
			ord=rss("ord")
			company_ord=rss("company")
			unit=rss("unit")
			AssistUnit=rss("AssistUnit")
			AssistNum=rss("AssistNum").Value
			price1=rss("price1")
			If price1&"" = "" Then price1 = 0 Else price1 = CDBL(price1)
			num1=cdbl(rss("num1"))-cdbl(rss("num2"))
'If price1&"" = "" Then price1 = 0 Else price1 = CDBL(price1)
			If num1&"" = "" Then num1 = 0 Else num1 = CDBL(num1)
			money1=price1*num1
			ck=rss("ku")
			ph=rss("ph")
			xlh=rss("xlh")
			datesc=rss("datesc")
			dateyx=rss("dateyx")
			js=rss("js")
			bz=rss("bz")
			intro=rss("intro")
			parentProductAttr1=rss("ProductAttr1")
			parentProductAttr2=rss("ProductAttr2")
			if parentProductAttr1&""="" then parentProductAttr1=0
			if parentProductAttr2&""="" then parentProductAttr2=0
			if unit<>"" And Not isnull(unit) then
			else
				unit=0
			end if
			if AssistUnit<>"" And Not isnull(AssistUnit) then
			else
				AssistUnit=0
			end if
			sqlStr="Insert Into mxpx(ord,cateid,topid,sort1,datepx,del) values('"
			sqlStr=sqlStr & ord & "','"
			sqlStr=sqlStr & session("personzbintel2007") & "','"
			sqlStr=sqlStr & 0 & "','"
			sqlStr=sqlStr & 1 & "','"
			sqlStr=sqlStr & now & "','"
			sqlStr=sqlStr & us_i & "')"
			Conn.execute(sqlStr)
			dim id
			id = GetIdentity("mxpx","id","cateid","")
			sqltext="Update kuoutlist2 set  area="&id&"  where area="&rss("caigoulist")&"  and addcate="&session("personzbintel2007")&" and del=7"
			conn.execute(sqltext)
			sqltext="Update kuinlist set  caigoulist="&id&"  where id="&rss("id")&""
			conn.execute(sqltext)
			set rs2=server.CreateObject("adodb.recordset")
			sql2="select sort1 from sortonehy where id="&unit&""
			rs2.open sql2,conn,1,1
			if rs2.eof then
				unitname=""
			else
				unitname=rs2("sort1")
			end if
			rs2.close
			set rs2=nothing
			set rs7=server.CreateObject("adodb.recordset")
			sql7="select id from mxpx where cateid="&session("personzbintel2007")&" and sort1=1 "
			rs7.open sql7,conn,1,1
			i=rs7.RecordCount
			rs7.close
			set rs7=nothing
			set rs7=server.CreateObject("adodb.recordset")
			sql7="select title,order1,type1,price1,company,unit from product where ord="&ord&""
			rs7.open sql7,conn,1,1
			if rs7.eof then
				k=""
				order1=""
				type1=""
				unitall=""
			else
				k=rs7("title")
				order1=rs7("order1")
				type1=rs7("type1")
				unitall=rs7("unit")
			end if
			rs7.close
			set rs7=nothing
			PhXlhManage = GetProductPhXlhManage(ord, unit)
			phManage = PhXlhManage(0)
			xlhManage = PhXlhManage(1)
			cpyxqHours = PhXlhManage(2)
			Response.write("<span id='trpx"&m&"'><span id='trpx_"&id&"'>")
			list="<table width='100%' border='0' id='tpx"&id&"' cellpadding='3' style='word-break:break-all;word-wrap:break-word;border-collapse:collapse;table-layout:fixed;'><tr   onmouseout=this.style.backgroundColor='' onmouseover=this.style.backgroundColor='efefef'>"
			'Response.write("<span id='trpx"&m&"'><span id='trpx_"&id&"'>")
			set rs=colrs : rs.movefirst
			do until rs.eof
				sorce=rs("sorce")
				kd=rs("kd")
				Select Case sorce
				Case 1:
				list=list&"<td width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;' id='cpmx_title_td"&i&"'>"
'Case 1:
				If qxOpen > 0 Then
					list=list&"<a href='javascript:void(0)'  onclick=javascript:window.open('../product/content.asp?ord="&pwurl(ord)&"','newwin21','width='+800+',height='+500+',toolbar=0,scrollbars=1,resizable=1,left=100,top=100');return false; alt='查看产品详情'>"
'If qxOpen > 0 Then
				end if
				list=list&"&nbsp;"&k&"</a>  <a href='javascript:void(0)' onclick=del2('tpx"&id&"','"&id&"');><img src='../images/del2.gif'  border=0 alt='删除此产品'></a><label id=""inx_"&id&""">"&i&"</label> <input name='gys_"&id&"' type='hidden'   value='"&company_ord&"' size='7'><input name='caigoulist_"&id&"' type='hidden'   value='"&caigoulist&"' size='7'></td>"
				Case 2:
				list=list+"<td width='"&kd&"' id='cpmx_order1_td"&i&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'>"&order1&"</td>"
'Case 2:
				Case 3:
				list=list&"<td  width='"&kd&"' id='cpmx_type1_td"&i&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'>"&type1&"</td>"
'Case 3:
				Case 4:
				list=list&"<td align='center' width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><select name='unit_"&id&"' id='unit2_"&i&"' width='"&kd&"' onchange=newbom(this.value,'"&ord&"','"&top&"','trpx"&i-1&"_"&id&"','"&id&"')  dataType='Range' msg='不能为空' min='1' max='9999999999999'>"
				set rs7=server.CreateObject("adodb.recordset")
				sql7="select ord,sort1 from sortonehy where gate2=61 and id in ("&unitall&") order by gate1 desc"
				rs7.open sql7,conn,1,1
				do until rs7.eof
					list=list&"<option value='"&rs7("ord")&"'"
					if clng(unit)=rs7("ord") then
						list=list&" selected"
					end if
					list=list&">"&rs7("sort1")&"</option>"
					rs7.movenext
				loop
				rs7.close
				set rs7=nothing
				list=list&"</select></td>"
				if isOpenProductAttr then
					list=list+" <td align='center' width='90' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><select name='ProductAttr1_"&id&"' id='ProductAttr1_"&i&"' width='50' onChange=newbom($('#unit2_"&i&"').val(),'"&ord&"','"&top&"','trpx"&i-1&"_"&id&"','"&id&"',this.value,$('#ProductAttr2_"&i&"').val())  dataType='Range'> "
					set rs7=GetProductAttrOption(ord,1)
					do until rs7.eof
						list=list+"<option value='"&rs7("id")&"'"
'do until rs7.eof
						if clng(parentProductAttr1)=rs7("id") then list=list+" selected"
'do until rs7.eof
						list=list+">"&rs7("title")&"</option>"
'do until rs7.eof
						rs7.movenext
					loop
					rs7.close
					set rs7=nothing
					list=list+"</select></td>"
'set rs7=nothing
					list=list+" <td align='center' width='90' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><select name='ProductAttr2_"&id&"' id='ProductAttr2_"&i&"' width='50' onChange=newbom($('#unit2_"&i&"').val(),'"&ord&"','"&top&"','trpx"&i-1&"_"&id&"','"&id&"',$('#ProductAttr1_&i&').val(),this.value)  dataType='Range"
					set rs7=GetProductAttrOption(ord,0)
					do until rs7.eof
						list=list+"<option value='"&rs7("id")&"'"
'do until rs7.eof
						if clng(parentProductAttr2)=rs7("id") then list=list+" selected"
'do until rs7.eof
						list=list+">"&rs7("title")&"</option>"
'do until rs7.eof
						rs7.movenext
					loop
					rs7.close
					set rs7=nothing
					list=list+"</select></td>"
					set rs7=nothing
				end if
				Case 5:
				list=list&"<td  class='name' width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><input Name='num1_"&id&"' id='num2_"&id&"'  value='"&Formatnumber(num1,num1_dot,true,0,0)&"' onkeyup=value=value.replace(/[^\d\.]/g,'');checkDot('num2_"&id&"','"&num1_dot&"'); onblur=chtotal3("&ord&","&top&","&id&","&i&","&num_dot_xs&") type='text' style='height: 19px; solid;font-size: 9pt;' size='5' dataType='Range' msg='数量必须大于0' min='0.00000000000001' max='9999999999999'></div></td>"
'Case 5:
				if isOpenAssUnit then
					list=list&"<td align='center' width='70' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><select name='AssistUnit_"&id&"' id='AssistUnit_"&i&"' width='70' onchange=UnitCustomFun(this,'"&ord&"','assistUnit')  dataType='Range'>"
'if isOpenAssUnit then
					set rs7=server.CreateObject("adodb.recordset")
					sql7="select ord,sort1 from  (select 0 ord,'' sort1, 99999999 gate1 union all select ord,sort1,gate1 from sortonehy where gate2=61  and id in ("&unitall&"))t order by gate1 desc"
					rs7.open sql7,conn,1,1
					if assistUnit&""<>"0" then
						assistUnitValue=assistUnit
					else
						assistNum=""
						assistUnitValue=GetHistoryAssistUnit(ord)
					end if
					do until rs7.eof
						list=list&"<option value='"&rs7("ord")&"'"
						if clng(assistUnitValue)=rs7("ord") then
							list=list&" selected"
						end if
						list=list&">"&rs7("sort1")&"</option>"
						rs7.movenext
					loop
					list=list&"</select></td>"
					rs7.close
					set rs7=nothing
					readonly=""
					if assistUnit&""<>"0" and cdbl(iif(AssistNum&""="",0,AssistNum)) <>0 then
						assistNum=Formatnumber(AssistNum,num1_dot,-1,-1,0)
'if assistUnit&""<>"0" and cdbl(iif(AssistNum&""="",0,AssistNum)) <>0 then '
					else
						if clng(assistUnitValue)<>0 then
							assistBl = ConvertUnitData(ord,unit,clng(assistUnitValue),1)
							if cdbl(assistBl)<>0 then  assistNum=Formatnumber(assistBl,num1_dot,-1,-1,0)
							assistBl = ConvertUnitData(ord,unit,clng(assistUnitValue),1)
						else
							readonly="readonly"
						end if
					end if
					if isFixAssRat then readonly="readonly"
					list=list&"<td "&readonly&" class='name' width='70' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><input "&readonly&" Name='AssistNum_"&id&"' id='AssistNum_"&id&"' value='"&assistNum&"' class= 'AssistNum_"&i&"' onkeyup=value=value.replace(/[^\d\.]/g,'');checkDot('AssistNum_"&id&"','"&num1_dot&"');  type='text' style='height: 19px; solid;font-size: 9pt;' size='5' dataType='Range'></div></td>"
'if isFixAssRat then readonly="readonly"
				end if
				Case 6:
				list=list&"<td class='name' width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;"& displayStr &"'><div align='center'><input name='price1_"&id&"' readonly=true old_val='" & Formatnumber(price1,StorePrice_dot_num,true,0,0) & "' id='pricetest2_"&id&"' type='text'  value='"&Formatnumber(price1,StorePrice_dot_num,true,0,0)&"' onkeyup=value.replace(/[^\d\.]/g,'');checkDot('pricetest2_"&id&"','"&StorePrice_dot_num&"') onpropertychange=""chtotal2("&id&","&num_dot_xs&");"" style='color: #666666;border: #CCCCCC 1px solid;height: 19px; solid;font-size: 9pt;text-align:right'  size='7'></div></td>"
'Case 6:
				Case 7:
				list=list&"<td width='"&kd&"'style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;"& displayStr &"'><div align='right'><input name='moneyall_"&id&"' id='moneyall2_"&id&"' readonly=true type='text' onkeyup=value=value.replace(/[^\d\.]/g,'');checkDot('moneyall2_"&id&"','"&num_dot_xs&"') value='"&Formatnumber(money1,num_dot_xs,true,0,0)&"' size='10' style='color: #666666;border: #CCCCCC 1px solid;text-align:right' ></div></td>"
'Case 7:
				Case 8:
				list = list&"<td class='name' width='195px' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'>"
'Case 8:
				Set ckrs = conn.execute("select sort1 from sortck where ord=" & ck)
				If ckrs.eof = False Then
					ckname = ckrs.fields(0).value
				else
					ckname = ""
				end if
				ckrs.close
				list = list & "<table style='width:100%' cellspacing=0 cellpadding=0><tr><td>" & _
				"<input type='hidden' name='ck_"& id &"' id='ck2_"&i&"' text='" & ckname & "' value='" & ck & "' dataType='Limit' min='1' max='100' msg='请选择仓库'>" & _
				"<div style='float:left;'><input title='" & ckname & "' style='float:left;' id='for_ck2_"&i&"' type='button' class='storeButton' value='" & ckname & "'></div>" & _
				"</td><td style='width:16px;'><img  style='cursor:pointer;' src='../images/11645.png' onclick=""showStoreDlg('ck2_"&i&"'," & ord & "," & unit & ")""></td>" & _
				"</tr></table>"
				list=list&"</td>"
				Case 9:
				list=list&"<td class='name' width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><input name='ph_"&id&"' id='ph2_"&i&"'  value='"&ph&"' type='text'  style='height: 19px; solid;font-size: 9pt;'  size='10' dataType='Limit' max='50' "& iif(phManage=1," min='1'","") &"  msg='"& iif(phManage=1,"长度必须在1到50个字之间","不要超过50个字") &"'>"& iif(phManage=1," <span class='red'>*</span>","") &" <span id='ph_tip_"&id&"' class='red'></span></div></td>"
				Case 10:
				xlhid = "100"
				If Len(trim(xlh&""))>0 And cdbl(num1)>1 Then
					arr_xlh = split(trim(xlh&""),chr(1))
					xlhid = cint(((ubound(arr_xlh)+1)/cdbl(num1))*10)*10
					arr_xlh = split(trim(xlh&""),chr(1))
					If xlhid = 0 Then xlhid = "10"
				end if
				list=list&"<td class='name' width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><input name='xlh_"&id&"' id='xlh2_"&i&"'  value='"&xlh&"' type='hidden'  style='height: 19px; solid;font-size: 9pt;' size='10' dataType='Limit' "& iif(xlhManage=1," dataType='Limit' min='1' msg='"& iif(xlhManage=1,"必填","") &"'","") &"><input type='text' style='height: 19px; solid;font-size: 9pt;' size='9' canevent='0' id='scanxlh"&i&"' onkeydown=""setContentZZ("& i &",'xlh2_','xlh_','num2_')"" value='"
				If xlhid = 0 Then xlhid = "10"
				if trim(xlh&"")<>"" then
					arr_xlh = split(trim(xlh&""),chr(1))
					list=list&arr_xlh(ubound(arr_xlh))
				end if
				list=list&"' onblur=""setBlurContentZZ("& i &",'xlh2_','xlh_','num2_')"" onfocus='this.select()'><img id='xlhimg"& i&"' src='../images/percent"& xlhid &".png' title='序列号管理' style='width:12px;height:18px;cursor:hand;vertical-align:bottom;' onclick=""SetAllXlhZZ("&i&",'xlh2_','xlh_','cpmx_title_td','cpmx_order1_td','cpmx_type1_td','num2_')""><span id='xlhts"& i &"' style='color:red'></span>"& iif(xlhManage=1," <span class='red'>*</span>","") &" <span id='xlh_tip_"&id&"' class='red'></span></div></td>"
				Case 11:
				list=list&"<td align='center' width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><INPUT name='datesc_"&id&"' cpyxqHours='"& cpyxqHours &"' onchange=""dateYxqSet('datesc','daysdatesc"&i&"Pos','daysdateyx"&i&"Pos')""  id='daysdatesc"&i&"Pos'value='"&datesc&"' size=9  style='height: 19px; solid;font-size: 9pt;' readonly=true onmouseup=toggleDatePicker('daysdatesc"&i&"','date.datesc_"&id&"') ><DIV id='daysdatesc"&i&"' style='POSITION: absolute'></DIV></td>"
'Case 11:
				Case 12:
				list=list&"<td align='center' width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><INPUT name='dateyx_"&id&"'  id='daysdateyx"&i&"Pos' cpyxqHours='"& cpyxqHours &"' onchange=""dateYxqSet('dateyx','daysdatesc"&i&"Pos','daysdateyx"&i&"Pos')""value='"&dateyx&"' size=9  style='height: 19px; solid;font-size: 9pt;' readonly=true onmouseup=toggleDatePicker('daysdateyx"&i&"','date.dateyx_"&id&"') ><DIV id='daysdateyx"&i&"' style='POSITION: absolute'></DIV></td>"
'Case 12:
				Case 13:
				list=list&"<td class='name' width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><select name='bz_"&id&"' id='bz2_"&i&"'>"
'Case 13:
				If Len(bz&"")=0 Then bz=0
				set rs2=server.CreateObject("adodb.recordset")
				sql2="select ord,sort1 from sortonehy where gate2=82 order by gate1 desc"
				rs2.open sql2,conn,1,1
				do until rs2.eof
					If rs2("ord")=CInt(bz) Then
						list=list&"<option value='"&rs2("ord")&"' selected>"&rs2("sort1")&"</option>"
					else
						list=list&"<option value='"&rs2("ord")&"'>"&rs2("sort1")&"</option>"
					end if
					rs2.movenext
				loop
				rs2.close
				set rs2=nothing
				list=list&"</select></div></td>"
				Case 14:
				list=list&"<td class='name' width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><input name='js_"&id&"' id='js2_"&i&"'  value='"&js&"' type='text' onkeyup=value=value.replace(/[^\d\.]/g,'')  style='height: 19px; solid;font-size: 9pt;'  size='5'></div></td>"
'Case 14:
				Case 15:
				list=list&"<td width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><textarea name='intro_"&id&"' id='intro2_"&i&"' type='text' style='overflow-y:hidden;word-break:break-all;width:80px' onfocus='this.style.posHeight=this.scrollHeight' onpropertychange='this.style.posHeight=this.scrollHeight' dataType='Limit' min='0' max='200' msg='不要超过200个字' rows='1'>"&intro&"</textarea></div></td>"
				Case 16:
				list=list+"<td class='name' align='center' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'><textarea name='zdy1_"&id&"' cols='10' id='zdy12_"&i&"' style='overflow-y:hidden;word-break:break-all;width:50px' onFocus='this.style.posHeight=this.scrollHeight' onpropertychange='this.style.posHeight=this.scrollHeight'  datatype='Limit' min='0' max='200' msg='不要超过200个字'>"&replace(rss(""&rs("name")&"")&"","<br>",chr(10))&"</textarea></td>"
				Case 17:
				list=list+"<td align='center' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'><textarea name='zdy2_"&id&"' id='zdy22_"&i&"' cols='10' style='overflow-y:hidden;word-break:break-all;width:50px' onFocus='this.style.posHeight=this.scrollHeight' onpropertychange='this.style.posHeight=this.scrollHeight'  datatype='Limit' min='0' max='200' msg='不要超过200个字'>"&replace(rss(""&rs("name")&"")&"","<br>",chr(10))&"</textarea></td>"
				Case 18:
				list=list+"<td align='center' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'><textarea name='zdy3_"&id&"' id='zdy32_"&i&"' cols='10' style='overflow-y:hidden;word-break:break-all;width:50px' onFocus='this.style.posHeight=this.scrollHeight' onpropertychange='this.style.posHeight=this.scrollHeight'  datatype='Limit' min='0' max='200' msg='不要超过200个字'>"&replace(rss(""&rs("name")&"")&"","<br>",chr(10))&"</textarea></td>"
				Case 19:
				list=list+"<td align='center' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'><textarea name='zdy4_"&id&"' id='zdy42_"&i&"' cols='10' style='overflow-y:hidden;word-break:break-all;width:50px' onFocus='this.style.posHeight=this.scrollHeight' onpropertychange='this.style.posHeight=this.scrollHeight'  datatype='Limit' min='0' max='200' msg='不要超过200个字'>"&replace(rss(""&rs("name")&"")&"","<br>",chr(10))&"</textarea></td>"
				Case 20:
				list=list+"<td align='center' class='name' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'><select name='zdy5_"&id&"' id='zdy52_"&i&"'>"
'Case 20:
				set rs7=conn.execute("select ord,sort1 from sortonehy where gate2=2101 order by gate1 desc ")
				do until rs7.eof
					list=list+"<option value='"&rs7("ord")&"'"
'do until rs7.eof
					if rs7("ord")=rss(""&rs("name")&"") Then
						list=list+"selected"
'if rs7("ord")=rss(""&rs("name")&"") Then
					end if
					list=list+">"&rs7("sort1")&"</option>"
'if rs7("ord")=rss(""&rs("name")&"") Then
					rs7.movenext
				loop
				rs7.close
				list=list+"</select></td>"
'rs7.close
				Case 21:
				list=list+"<td align='center' class='name' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'><select name='zdy6_"&id&"' id='zdy62_"&i&"'>"
'Case 21:
				set rs7=conn.execute("select ord,sort1 from sortonehy where gate2=2102 order by gate1 desc ")
				do until rs7.eof
					list=list+"<option value='"&rs7("ord")&"'"
'do until rs7.eof
					if rs7("ord")=rss(""&rs("name")&"") Then
						list=list+"selected"
'if rs7("ord")=rss(""&rs("name")&"") Then
					end if
					list=list+">"&rs7("sort1")&"</option>"
'if rs7("ord")=rss(""&rs("name")&"") Then
					rs7.movenext
				loop
				rs7.close
				list=list+"</select></td>"
				rs7.close
				End Select
				rs.movenext
			Loop
			set rs = nothing
			list=list&"</tr></table>"
			Response.write(""&list&"</span></span>")
			session("num_click2009")=i
			us_i=us_i+1
			'session("num_click2009")=i
			m=m+1
			'session("num_click2009")=i
			rss.movenext
		loop
	end if
	rss.close
	set rss=nothing
	for j=m to num_cpmx_yl
		list_ys=list_ys+"<span id='trpx"&j&"'></span>"
'for j=m to num_cpmx_yl
	next
	Response.write "<div id='beforelastRow'></div>"
	Response.write(""&list_ys&"")
	Response.write "" & vbcrlf & "" & vbcrlf & "<p></p>" & vbcrlf & "" & vbcrlf & ""
	Dim kdtall2
	kdtall2=0
	Set rs=colrs1005: colrs1005.movefirst
	while Not rs.eof
		kdtall2=kdtall2+rs("kd")
'while Not rs.eof
		rs.movenext
	wend
	Set rs=Nothing
	Response.write "" & vbcrlf & "<div id='zbmxlist' class=""nopadding32"">" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"" class=""bgfff"">" & vbcrlf & "          <tr>" & vbcrlf & "            <td class=""place"">子件清单</td>" & vbcrlf & "     <td>&nbsp;</td>" & vbcrlf & "            <td align=""right"">"
	if session("pro1zbintel2007")="1" then
		Response.write "<input type=""button"" name=""Submit3"" value=""添加产品""  onClick=""javascript:window.open('../product/add_list.asp?ord="
		Response.write pwurl(89)
		Response.write "','newwproductin','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150')"" class=""anybutton""/>"
		'Response.write pwurl(89)
	end if
	Response.write "</td>" & vbcrlf & "            <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "          </tr>" & vbcrlf & "      </table>" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "<table width=""100%"" class=""resetHeadBg bgfff"" border=""0"" cellpadding=""3""  background=""../images/112.gif"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;table-layout:fixed;"">" & vbcrlf & "        <tr>" & vbcrlf & "    "
	'Response.write pwurl(89)
	Set rs=colrs1005: colrs1005.movefirst
	while Not rs.eof
		Select Case rs("sorce")
		Case 4 :
		Response.write "" & vbcrlf & "                            <td width="""
		Response.write rs("kd")
		Response.write """ height='26'>"
		Response.write pl
		Response.write "</td>" & vbcrlf & "                        "
		if isOpenProductAttrV then
			Response.write "" & vbcrlf & "                            <td width=""90"" height='26'>"
			Response.write pl
			Response.write "</td>" & vbcrlf & "                            <td width=""90"" height='26'>"
			Response.write pl
			Response.write "</td>" & vbcrlf & "                        "
		end if
		case 6:
		Response.write "<td width='"&rs("kd")&"'  style='"& displayStr &"'>&nbsp;</td>"
		Case 7 :
		Response.write "" & vbcrlf & "                                       <td  width="""
		Response.write rs("kd")
		Response.write """  height=""26"" style="""
		Response.write displayStr
		Response.write """><div align=""center"">批量录入：</div></td>" & vbcrlf & "                                   "
		Case 8 :
		Response.write "" & vbcrlf & "                                        <td  width=""195px"">" & vbcrlf & "                                      "
		if proStore<>1 then
			Response.write "" & vbcrlf & "                                             <table style='width:100%' cellspacing=0 cellpadding=0><tr><td width=""100%"">" & vbcrlf & "                                               <input type='hidden' name=""dfggck"" id=""ckall"" text=''  onchange=""ck('"
			Response.write num_dot_xs
			Response.write "',true);"">" & vbcrlf & "                                                <div style='float:left;'><input style='float:left;' id='for_ckall' type='button' class='storeButton'></div>" & vbcrlf & "                                             </td><td style='width:16px;'><img  style='cursor:pointer;' src='../images/11645.png' onClick=""showStoreDlg('ckall')""></td>" & vbcrlf &"                                         </tr></table>" & vbcrlf & "                                     "
		end if
		Response.write "" & vbcrlf & "                                </td>" & vbcrlf & "                                          "
		Case 11 :
		Response.write "" & vbcrlf & "                                       <td  width="""
		Response.write rs("kd")
		Response.write """><div align=""center"">" & vbcrlf & "                                              <select name=""bzall_2""  id=""bzall_2""  onpropertychange=""bzz()"" >" & vbcrlf & "                                                <option value=""""></option>" & vbcrlf & "                                                "
		set rs2=server.CreateObject("adodb.recordset")
		sql2="select ord,sort1 from sortonehy where gate2=82 order by gate1 desc"
		rs2.open sql2,conn,1,1
		do until rs2.eof
			Response.write "" & vbcrlf & "                                               <option value="""
			Response.write rs2("ord")
			Response.write """>"
			Response.write rs2("sort1")
			Response.write "</option>" & vbcrlf & "                                              "
			rs2.movenext
		loop
		rs2.close
		set rs2=nothing
		Response.write "" & vbcrlf & "                                               </select>" & vbcrlf & "                                             </div></td>" & vbcrlf & "                                       "
		Case Else
		Response.write "<td width='"&rs("kd")&"'>&nbsp;</td>"
		End select
		rs.movenext
	wend
	Set rs=Nothing
	Response.write "" & vbcrlf & "     </tr>" & vbcrlf & "" & vbcrlf & "   <tr class=""top"">" & vbcrlf & "  "
	num1_ls=0
	adressNum1=0
	Set rs=colrs1005: colrs1005.movefirst
	If Not rs.eof Then
		do until rs.eof
			sorce=rs("sorce")
			kd=rs("kd")
			Select Case sorce
			Case 1 :
			Response.write "<td width='"&kd&"' height='26' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 1 :
			Case 2 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 2 :
			Case 3 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 3 :
			Case 4 :
			if isOpenProductAttrV then
				Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"&_
				"<td  width='90' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>产品属性1</strong></div></td>"&_
				"<td  width='90' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>产品属性2</strong></div></td>"
'if isOpenProductAttrV then
			else
				Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'if isOpenProductAttrV then
			end if
			Case 5 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 5 :
			Case 6 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;"& displayStr &"'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 6 :
			Case 7 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;"& displayStr &"'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 7 :
			Case 8 :
			Response.write "<td  width='195px' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 8 :
			Case 9 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 9 :
			Case 10 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 10 :
			Case 11 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 11 :
			Case 12 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 12 :
			Case 13 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 13 :
			Case 14 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 14 :
			Case 15 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 15 :
			Case 16 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 16 :
			Case 17 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 17 :
			Case 18 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 18 :
			Case 19 :
			Response.write "<td  width='"&kd&"' align='center' background='../images/m_table_top.jpg' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><strong>"&rs("title")&"</strong></div></td>"
'Case 19 :
			End Select
			If rs("sorce")=5 Then
				adressNum1=num1_ls
			end if
			num1_ls=num1_ls+1
			adressNum1=num1_ls
			rs.movenext
		Loop
	end if
	set rs = nothing
	Response.write "" & vbcrlf & "     </tr>" & vbcrlf & "</table>" & vbcrlf & ""
	id1_old=0
	sqls = "select a.*,  y.title ,  y.order1,  y.type1,  y.company , y.unitall ,(select top 1 sort1 from sortck x where x.ord=a.ck) as ckname "&_
	" from kuoutlist2 a "  &  vbcrlf &_
	" inner join ( select  ord, title,order1,type1,company,unit as unitall  from product  ) y on   a.contract="&top&" and a.sort1=9 and a.del=7 and a.ord=y.ord order by area asc,date7 asc,id asc"
	set rss = server.CreateObject("adodb.recordset")
	rss.open sqls,conn,1,1
	i=1
	n=1
	if rss.eof then
		Response.write "" & vbcrlf & "    <span id=""zjtrpx0"">" & vbcrlf & "    <table width=""100%"" border=""0""  cellpadding=""3"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;""  class=""bgfff"">" & vbcrlf & "        <tr >" & vbcrlf & "            <td height=""30"" style=""border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;"">无产品明细！</td>" & vbcrlf & "            </tr>" & vbcrlf & "    </table>" & vbcrlf & "    </span>" & vbcrlf & "    "
'if rss.eof then
	else
		us_i=1
		Ismode=0
		do until rss.eof
			ord=rss("ord")
			unit=rss("unit")
			price1=rss("price1")
			num1=rss("num1")
			money1=rss("money1")
			ck=rss("ck")
			bz=rss("bz")
			js=rss("js")
			intro=rss("intro")
			id1=rss("area")
			if Ismode>0 and Ismode<>id1 then
				sumtrclos="<span id='sumspan"&Ismode&"'>"
				sumtrclos=sumtrclos+"<table width='100%' border='0' id='tpx9'  cellpadding='3' style='word-break:break-all;word-wrap:break-word;border-collapse:collapse;table-layout:fixed;'><tr   onmouseout=this.style.backgroundColor='' onmouseover=this.style.backgroundColor='efefef'>"
'sumtrclos="<span id='sumspan"&Ismode&"'>"
				sumtrclos=sumtrclos+sumtdclos
'sumtrclos="<span id='sumspan"&Ismode&"'>"
				sumtrclos=sumtrclos+"</table>"
'sumtrclos="<span id='sumspan"&Ismode&"'>"
				sumtrclos=sumtrclos+"</span>"
'sumtrclos="<span id='sumspan"&Ismode&"'>"
				Response.write(""&sumtrclos&"</span>")
				sumnum1=0
				summoney1=0
			end if
			Ismode=rss("area")
			ku=rss("ku")
			zzdata = rss("zzyckData")
			ProductAttr1 = rss("ProductAttr1")
			ProductAttr2 = rss("ProductAttr2")
			if ProductAttr1&""="" then ProductAttr1=0
			if ProductAttr2&""="" then ProductAttr2=0
			if unit&""="" then unit=0
			session("num_click2010")=session("num_click2010")+1
'if unit&""="" then unit=0
			sqlStr="set nocount on;Insert Into mxpx(ord,cateid,topid,sort1,datepx,del) values('"
			sqlStr=sqlStr & ord & "','"
			sqlStr=sqlStr & session("personzbintel2007") & "','"
			sqlStr=sqlStr & id1 & "','"
			sqlStr=sqlStr & 3 & "','"
			sqlStr=sqlStr & now & "','"
			sqlStr=sqlStr & us_i & "'); select max(id) as maxid, count(1) as recordcount from mxpx where  cateid="&session("personzbintel2007")&" and sort1=3; set nocount off "
			set rsid = Conn.execute(sqlStr)
			id = rsid("maxid").value
			i = rsid("recordcount").value
			rsid.close
			if IsNumeric(ku)and ku>0 Then
				checked_zd1=""
				checked_zd2="checked"
				sqltext="Update kuoutlist2 set  mxid="&id&" where id="&rss("id")&""
				conn.execute(sqltext)
			else
				checked_zd1="checked"
				checked_zd2=""
			end if
			k=rss("title")
			order1=rss("order1")
			type1=rss("type1")
			unitall=rss("unitall")
			kcxz=""
			sumnum1=cdbl(sumnum1)+cdbl(num1)
			'kcxz=""
			summoney1=cdbl(summoney1)+cdbl(money1)
			'kcxz=""
			set rs=server.CreateObject("adodb.recordset")
			sql="select sum(num2) as num1,ck,unit, bb.sort1 as ckname, bb.fullpath from ku aa inner join sortck bb on  aa.ord="&ord&" and aa.ck="&ck&" and aa.ck=bb.ord and aa.ck in (select id from sortck where del=1 and (intro like '"&session("personzbintel2007")&",%' or intro like '%,"&session("personzbintel2007")&",%' or intro like '%, "&session("personzbintel2007")&",%' or intro like '%, "&session("personzbintel2007")&"'  or intro like '%,"&session("personzbintel2007")&"' or intro like '"&session("personzbintel2007")&"' or intro like '0')) group by ck,unit, sort1, fullpath having sum(num2)>0 order byck asc"
			rs.open sql,conn,1,1
			if rs.RecordCount<=0 then
			else
				do until rs.eof
					num_kc2=rs("num1")
					unit2=rs("unit")
					ck2=rs("ck")
					if unit2<>"" then
					else
						unit2=0
					end if
					unitrs.filter = " id=" & unit2
					unit2name=unitrs("sort1").value
					ckname=rs("ckname").value
					ck1name = Replace(rs("fullpath").value & "", Chr(1),"-")
					ckname=rs("ckname").value
					if clng(unit)=unit2 then
						num_kclimit=num_kc2
						kcxz=kcxz+"<font class='red'>"
						'num_kclimit=num_kc2
						kcxz=kcxz+""&ck1name&" "&ckname&" "&unit2name&" "&num_kc2&"<br>"
						'num_kclimit=num_kc2
						kcxz=kcxz+"</font>"
						'num_kclimit=num_kc2
					end if
					if num_kclimit="" then
						num_kclimit=0
					end if
					if clng(unit)<>unit2 then
						kcxz=kcxz+"<font color='#546C95'>"&ck1name&" "&ckname&" </font>"&unit2name&" "&num_kc2&""
'if clng(unit)<>unit2 then
						kcxz=kcxz+"<a href='javascript:void(0)' onclick=javascript:window.open('../store/ku_unit.asp?ord="&ord&"&unit="&unit&"&id="&id&"&ck="&ck&"&ck2="&ck2&"','newwin23','width='+800+',height='+400+',toolbar=0,scrollbars=1,resizable=1,left=100,top=100');><img src='../images/jiantou.gif' border='0' alt='选择'>拆分</a><br>"
					end if
					rs.movenext
				loop
			end if
			rs.close
			set rs=nothing
			if  kcxz="" then
				kcxz="没有库存！"
			end if
			if clng(id1_old)<>clng(id1) then
				if n=1 then
				else
					Response.write("</span>")
				end if
				Response.write("<span id='cktrpx"&id1&"'>")
				id1_old=clng(id1)
			end if
			Response.write("<input name='ord_"&id&"' id='ord_"&i&"' type='hidden'  value='"&ord&"'><input name='id_"&id&"' id='id"&i&"' type='hidden'  value='"&id&"'><input name='id1_"&id&"' id='id1_"&i&"' type='hidden'  value='"&id1&"'>")
			Response.write("<span id='trpx"&(i-1)&"_"&id&"'>")
			list=""
			list="<table width='100%' border='0' id='tpx"&(i-1)&"' cellpadding='3' style='word-break:break-all;word-wrap:break-word;border-collapse:collapse;table-layout:fixed;'><tr onmouseout=this.style.backgroundColor='' onmouseover=this.style.backgroundColor='efefef'>"
			'list=""
			sumtdclos=""
			Set rs=colrs1005: colrs1005.movefirst
			do until rs.eof
				sorce=rs("sorce")
				kd=rs("kd")
				Select Case sorce
				Case 1:
				list=list&"<td width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'>"
'Case 1:
				If qxOpen > 0 Then
					list=list&"<a href='javascript:void(0)'  onclick=javascript:window.open('../product/content.asp?ord="&pwurl(ord)&"','newwin21','width='+800+',height='+500+',toolbar=0,scrollbars=1,resizable=1,left=100,top=100');return false; alt='查看产品详情'>"
'If qxOpen > 0 Then
				end if
				list=list&"&nbsp;"&k&"</a>  <a href='javascript:void(0)' onclick=del('trpx"&(i-1)&"_"&id&"','"&id&"','"&id1&"');><img src='../images/del2.gif'  border=0/ alt='删除此产品'>"&i&"</a><input name='numdata1_"  & id & "' value='" & zzdata & "' type='hidden'><input name='w_"&id&"' id='w"&i&"' type='hidden'value='trpx"&(i-1)&"_"&id&"' size='7'></td>"
'If qxOpen > 0 Then
				sumtdclos=sumtdclos&"<td width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'>"
'If qxOpen > 0 Then
				sumtdclos=sumtdclos&"</td>"
				Case 2:
				list=list&"<td width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'>"&order1&"</td>"
'Case 2:
				sumtdclos=sumtdclos&"<td width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'></td>"
'Case 2:
				Case 3:
				list=list&"<td width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'>"&type1&"</td>"
'Case 3:
				sumtdclos=sumtdclos&"<td width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'></td>"
'Case 3:
				Case 4:
				list=list&"<td align='center' width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><select name='unit_"&id&"' id='unit"&i&"' width='"&kd&"' onChange=ckxz('"&ord&"','"&i&"','"&id&"','"&id1&"','trpx"&(i-1)&"_"&id&"','2','"&num_dot_xs&"');  dataType='Range' msg='不能为空' min='1' max='9999999999999'>"
				sumtdclos=sumtdclos&"<td align='center' width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'>合计：</td>"
'taType='Range' msg='不能为空' min='1' max='9999999999999'>"
				unitrs.filter = " id<>0"
				Set rs7 = unitrs :
				unitrs.movefirst
				do until rs7.eof
					If InStr("," & unitall & ",", "," & rs7("id").value  & ",")>0 then
						list=list&"<option value='"&rs7("ord")&"'"
						if clng(unit)=rs7("ord") then
							list=list&" selected"
						end if
						list=list&">"&rs7("sort1")&"</option>"
					end if
					rs7.movenext
				loop
				set rs7=nothing
				list=list&"</select></td>"
				if isOpenProductAttr then
					list=list+" <td align='center' width='90' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><input name='ProductAttr1_"&id&"' id='ProductAttr1_"&i&"' type='hidden'   value='"&ProductAttr1&"'>"&GetProductAttrNameById(ProductAttr1)&"</td>"
'if isOpenProductAttr then
					list=list+" <td align='center' width='90' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><input name='ProductAttr2_"&id&"' id='ProductAttr2_"&i&"' type='hidden'   value='"&ProductAttr2&"'>"&GetProductAttrNameById(ProductAttr2)&"</td>"
'if isOpenProductAttr then
					sumtdclos=sumtdclos+" <td align='center' width='90' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'></td>"
'if isOpenProductAttr then
					sumtdclos=sumtdclos+" <td align='center' width='90' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'></td>"
'if isOpenProductAttr then
				end if
				Case 5:
				list=list&"<td width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><input Name='num1_"&id&"' id='num"&id&"'  if num1=0 then onfocus=if(value==defaultValue){value='';this.style.color='#000'}  onBlur=if(!value){value=defaultValue;this.style.color='#000'}  value='"&Formatnumber(num1,num1_dot,true,0,0)&"'  onkeyup=value=value.replace(/[^\d\.]/g,'');checkDot('num"&id&"','"&num1_dot&"')  onpropertychange=chtotal("&id&","&id1&","&num1_dot&"); type='text' style='height: 19px; solid;font-size: 9pt;' size='5' dataType='Range' msg='数量必须大于0且小于等于库存' min='0.00000000000001' max='"&num_kclimit&"'></div></td>"
				sumtdclos=sumtdclos&"<td width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div id='sumnums"&id1&"'>"&Formatnumber(sumnum1,num1_dot,-1,0,0)&"</div></td>"
'e' msg='数量必须大于0且小于等于库存' min='0.00000000000001' max='"&num_kclimit&"'></div></td>"
				Case 6:
				list=list&"<td class='name' width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;"& displayStr &"'><div align='center'><input name='price1_"&id&"' old_val='" & Formatnumber(price1,StorePrice_dot_num,true,0,0) & "' id='pricetest"&id&"' type='text' if price1=0 then onfocus=if(value==defaultValue){value='';this.style.color='#000'}  onBlur=if(!value){value=defaultValue;this.style.color='#000'} value='"&Formatnumber(price1,StorePrice_dot_num,true,0,0)&"' onkeyup=value.replace(/[^\d\.]/g,'');checkDot('pricetest"&id&"','"&StorePrice_dot_num&"') onpropertychange=""chtotal("&id&","&id1&","&num_dot_xs&");"" style='height: 19px; solid;font-size: 9pt;text-align:right'  size='7' ></div></td>"
'Case 6:
				sumtdclos=sumtdclos&"<td class='name' width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;"& displayStr &"'></td>"
'Case 6:
				Case 7:
				list=list&"<td width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;"& displayStr &"'><div align='right'><input name='moneyall_"&id&"' id='moneyall"&id&"' type='text' readonly=true if price1=0 then onfocus=if(value==defaultValue){value='';this.style.color='#000'} value='"&Formatnumber(money1,num_dot_xs,true,0,0)&"' onBlur=if(!value){value=defaultValue;this.style.color='#666'}  onkeyup=value=value.replace(/[^\d\.]/g,'');checkDot('moneyall"&id&"','"&num_dot_xs&"')  size='10' style='color: #666666;border: #CCCCCC 1px solid;text-align:right' ></div></td>"
				sumtdclos=sumtdclos&"<td width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;"& displayStr &"'><div id='summoney"&id1&"' align='center'>"&Formatnumber(summoney1,num_dot_xs,-1,-1,0)&"</div></td>"
' ></div></td>"
				Case 8:
				list=list&"<td width='195px' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'>"
'Case 8:
				sumtdclos=sumtdclos&"<td width='195px' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'>"
'Case 8:
				ckname = rss("ckname").value
				list = list & "<table style='width:100%' cellspacing=0 cellpadding=0><tr><td>" & _
				"<input type='hidden' name='ck_"& id &"' id='ck"& i &"' text='" & ckname & "' value='" & ck & "' onchange=""ckxz('"&ord&"','"&i&"','"&id&"',"&id1&",'trpx"&(i-1)&"_"&id&"','1','"&num_dot_xs&"');"" dataType='Limit' min='1' max='100' msg='请选择仓库'>" & _
				"<div style='float:left;'><input title=' & ckname & ' style='float:left;' id='for_ck&i&' type='button' class='storeButton' value=' & ckname & '></div>" & _
				"</td><td style='width:16px;'><img  style='cursor:pointer;' src='../images/11645.png' onclick=""showStoreDlg('ck"&i&"'," & ord & "," & unit & ")""></td>" & _
				"</tr></table>"
				list=list&"</td>"
				sumtdclos = sumtdclos & "<table style='width:100%' cellspacing=0 cellpadding=0><tr><td>" & _
				"<div style='float:left;'></div>" & _
				"</td><td style='width:16px;'></td>" & _
				"</tr></table>"
				sumtdclos=sumtdclos&"</td>"
				Case 9:
				list=list&"<td  width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><span id='ck2xz_"&id&"'>"&kcxz&"</span></td>"
'Case 9:
				sumtdclos=sumtdclos&"<td  width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'></td>"
'Case 9:
				Case 10:
				yzdhtml = ""
				if IsNumeric(ku)and ku>0 Then
					yzdhtml= "<font class='red' size='2'><b><br>已指定："& formatnumber(Formatnumber(num1,num1_dot,-1,-1,0)) &"</b></font>"
'if IsNumeric(ku)and ku>0 Then
				end if
				list=list&"<td  width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><input type='radio' name='way1_"&id&"' onclick=del_zd('"&id&"'); value='1' "&_
				"  "&checked_zd1&"/>随机&nbsp;<input type='radio' name='way1_"&id&"' value='2'  onclick=""if(check_ckxz('"&i&"'))javascript:window.open('../store/ku_select_ck.asp?ord="&ord&"&unit=' + getcurrunit(" & id & ") + '&id="&id&"&ck=' + getcurrck(" & id & ") +'&num1=' + getcurrnum1(" &id & ") + '&contractlist="&contractlist&"&kuout="&kuout&"&kuoutlist="&kuoutlist&"&sort_ck=9&ProductAttr1="&ProductAttr1&"&ProductAttr2="&ProductAttr2&"','newwin23','width='+800+',height='+400+',toolbar=0,scrollbars=1,resizable=1,left=100,top=100');""  "&checked_zd2&">指定<span id='zdkc"&id&"'>"& yzdhtml &"</span></td>"
				sumtdclos=sumtdclos&"<td  width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'></td>"
'tml &"</span></td>"
				Case 11:
				list=list&"<td width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><select name='bz_"&id&"' id='bz"&i&"'>"
'Case 11:
				set rs2=server.CreateObject("adodb.recordset")
				sql2="select ord, sort1 from sortonehy where gate2=82 order by gate1 desc"
				rs2.open sql2,conn,1,1
				do until rs2.eof
					list=list&"<option value='"&rs2("ord")&"'"
					if clng(bz)=rs2("ord") then
						list=list&" selected"
					end if
					list=list&">"&rs2("sort1")&"</option>"
					rs2.movenext
				loop
				rs2.close
				set rs2=nothing
				list=list&"</select></div></td>"
				sumtdclos=sumtdclos&"<td width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'>"
				list=list&"</select></div></td>"
				sumtdclos=sumtdclos&"</div></td>"
				Case 12:
				list=list&"<td width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><input name='js_"&id&"'  id='js"&i&"' type='text'  value='"&js&"' onkeyup=value=value.replace(/[^\d\.]/g,'')  style='height: 19px; solid;font-size: 9pt;'  size='5'></div></td>"
				sumtdclos=sumtdclos&"<td width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'></div></td>"
'  size='5'></div></td>"
				Case 13:
				list=list&"<td width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'><textarea name='intro_"&id&"' id='intro"&i&"' type='text' style='overflow-y:hidden;word-break:break-all;width:80px;' onfocus='this.style.posHeight=this.scrollHeight' onpropertychange='this.style.posHeight=this.scrollHeight' dataType='Limit' min='0' max='200' msg='不要超过200个字' rows='1'>"&intro&"</textarea></div></td>"
				sumtdclos=sumtdclos&"<td width='"&kd&"' style='border-bottom:#CCC 1px solid;border-left:#CCC 1px solid;border-right:#CCC 1px solid;'><div align='center'></div></td>"
				Case 14:
				list=list+"<td align='center' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'><textarea name='zdy1_"&id&"' id='zdy1"&i&"'  style='overflow-y:hidden;word-break:break-all;width:50px' onFocus='this.style.posHeight=this.scrollHeight' onpropertychange='this.style.posHeight=this.scrollHeight'  datatype='Limit' min='0' max='200' msg='不要超过200个字'>"&replace(rss(""&rs("name")&"")&"","<br>",chr(10))&"</textarea></td>"
				sumtdclos=sumtdclos+"<td align='center' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'></td>"
				Case 15:
				list=list+"<td align='center' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'><textarea name='zdy2_"&id&"' id='zdy2"&i&"' cols='10' style='overflow-y:hidden;word-break:break-all;width:50px' onFocus='this.style.posHeight=this.scrollHeight' onpropertychange='this.style.posHeight=this.scrollHeight'  datatype='Limit' min='0' max='200' msg='不要超过200个字'>"&replace(rss(""&rs("name")&"")&"","<br>",chr(10))&"</textarea></td>"
				sumtdclos=sumtdclos+"<td align='center' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'></td>"
				Case 16:
				list=list+"<td align='center' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'><textarea name='zdy3_"&id&"' id='zdy3"&i&"' cols='10' style='overflow-y:hidden;word-break:break-all;width:50px' onFocus='this.style.posHeight=this.scrollHeight' onpropertychange='this.style.posHeight=this.scrollHeight'  datatype='Limit' min='0' max='200' msg='不要超过200个字'>"&replace(rss(""&rs("name")&"")&"","<br>",chr(10))&"</textarea></td>"
				sumtdclos=sumtdclos+"<td align='center' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'></td>"
				Case 17:
				list=list+"<td align='center' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'><textarea name='zdy4_"&id&"' id='zdy4"&i&"' cols='10' style='overflow-y:hidden;word-break:break-all;width:50px' onFocus='this.style.posHeight=this.scrollHeight' onpropertychange='this.style.posHeight=this.scrollHeight'  datatype='Limit' min='0' max='200' msg='不要超过200个字'>"&replace(rss(""&rs("name")&"")&"","<br>",chr(10))&"</textarea></td>"
				sumtdclos=sumtdclos+"<td align='center' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'></td>"
				Case 18:
				list=list+"<td align='center' class='name' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'><select name='zdy5_"&id&"' id='zdy5"&i&"'>"
'Case 18:
				set rs7=conn.execute("select ord,sort1 from sortonehy where gate2=2101 order by gate1 desc ")
				do until rs7.eof
					list=list+"<option value='"&rs7("ord")&"'"
'do until rs7.eof
					if rs7("ord")=rss(""&rs("name")&"") Then
						list=list+"selected"
'if rs7("ord")=rss(""&rs("name")&"") Then
					end if
					list=list+">"&rs7("sort1")&"</option>"
'if rs7("ord")=rss(""&rs("name")&"") Then
					rs7.movenext
				loop
				rs7.close
				list=list+"</select></td>"
'rs7.close
				sumtdclos=sumtdclos+"<td align='center' class='name' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'><select name='zdy5_"&id&"' id='zdy5"&i&"'>"
'rs7.close
				sumtdclos=sumtdclos+"</td>"
'rs7.close
				Case 19:
				list=list+"<td align='center' class='name' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'><select name='zdy6_"&id&"' id='zdy6"&i&"'>"
'Case 19:
				set rs7=conn.execute("select ord,sort1 from sortonehy where gate2=2102 order by gate1 desc ")
				do until rs7.eof
					list=list+"<option value='"&rs7("ord")&"'"
'do until rs7.eof
					if rs7("ord")=rss(""&rs("name")&"") Then
						list=list+"selected"
'if rs7("ord")=rss(""&rs("name")&"") Then
					end if
					list=list+">"&rs7("sort1")&"</option>"
'if rs7("ord")=rss(""&rs("name")&"") Then
					rs7.movenext
				loop
				rs7.close
				list=list+"</select></td>"
'rs7.close
				sumtdclos=sumtdclos+"<td align='center' class='name' width='"&kd&"' style='BORDER-BOTTOM:#CCC  1px  solid; BORDER-LEFT:#CCC 1px solid;BORDER-RIGHT:#CCC 1px solid;'>"
'rs7.close
				list=list+"</td>"
'rs7.close
				End Select
				rs.movenext
			Loop
			set rs = nothing
			list=list&"</tr></table>"
			Response.write(""&list&"</span>")
			n=n+1
			'Response.write(""&list&"</span>")
			us_i=us_i+1
			'Response.write(""&list&"</span>")
			rss.movenext
		loop
	end if
	rss.close
	set rss=nothing
	sumtrclos="<span id='sumspan"&id1&"'>"
	sumtrclos=sumtrclos+"<table width='100%' border='0' id='tpx9'  cellpadding='3' style='word-break:break-all;word-wrap:break-word;border-collapse:collapse;table-layout:fixed;'><tr   onmouseout=this.style.backgroundColor='' onmouseover=this.style.backgroundColor='efefef'>"
'sumtrclos="<span id='sumspan"&id1&"'>"
	sumtrclos=sumtrclos+sumtdclos
'sumtrclos="<span id='sumspan"&id1&"'>"
	sumtrclos=sumtrclos+"</table>"
'sumtrclos="<span id='sumspan"&id1&"'>"
	sumtrclos=sumtrclos+"</span>"
'sumtrclos="<span id='sumspan"&id1&"'>"
	Response.write(""&sumtrclos&"</span>")
	list_ys=""
	for j=1 to num_cpmx_yl
		list_ys=list_ys+"<span id='zjtrpx"&j&"'></span>"
'for j=1 to num_cpmx_yl
	next
	Response.write(""&list_ys&"")
	Response.write "" & vbcrlf & " </td>" & vbcrlf & "  </tr>" & vbcrlf & "  <tr>" & vbcrlf & "  <td  class=""page"">" & vbcrlf & " <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "  <tr>" & vbcrlf & "  <td height=""40"" style=""padding-top:0"" colspan=""2"">&nbsp;&nbsp;<span id=""all_num""><inputname=""636r"" type=""hidden"" size=""6"" value="""
	Response.write session("num_click2009")+1
'name=""636r"" type=""hidden"" size=""6"" value="""
	Response.write """ id=""alli""><input name=""636t"" type=""hidden""  value="""
	Response.write session("num_click2010")+1
	'Response.write """ id=""alli""><input name=""636t"" type=""hidden""  value="""
	Response.write """ id=""alli_2""></span>" & vbcrlf & "  <input type=""submit"" name=""Submit4222"" value=""保存清单""  class=""anybutton2""/>&nbsp;&nbsp;&nbsp;&nbsp;<input type=""reset"" name=submit2  value=""重新填写"" class=""anybutton2""/>" & vbcrlf & "  <p style=""margin-top:15px;color:red"">全月平均法同先进先出法，子件默认按照出库批次成本价显示</p>" & vbcrlf & "  </td>" & vbcrlf & "  <td width=""65%"">&nbsp;<input name=""top""   type='hidden' value="""
	Response.write top
	Response.write """></td></tr>" & vbcrlf & ""
	action1="组装明细"
	call close_list(1)
	Response.write "" & vbcrlf & "</table>" & vbcrlf & "  </form>" & vbcrlf & "  <iframe width=""100%"" height=""500"" style=""display:none"" id=""sumitFrame"" frameborder=""0"" scrolling=""auto"" name=""sumitFrame"" src=""about:blank""></iframe>" & vbcrlf & "</td>" & vbcrlf & " </tr>" & vbcrlf & "</table>" & vbcrlf & "</div>" & vbcrlf & "</body>" & vbcrlf & "</html>"
	
%>
