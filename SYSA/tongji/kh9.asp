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
	
	sort3=request("sort3")
	if sort3<>"" then
	else
		sort3=1
	end if
	if sort3=1 then
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=41 and sort2=7"
		rs1.open sql1,conn,1,1
		if rs1.eof then
			open_41_7=0
			intro_41_7=0
		else
			open_41_7=rs1("qx_open")
			intro_41_7=rs1("qx_intro")
		end if
		rs1.close
		set rs1=nothing
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=41 and sort2=10"
		rs1.open sql1,conn,1,1
		if rs1.eof then
			open_41_10=0
			intro_41_10=0
		else
			open_41_10=rs1("qx_open")
			intro_41_10=rs1("qx_intro")
		end if
		rs1.close
		set rs1=nothing
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
		sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=6 and sort2=7"
		rs1.open sql1,conn,1,1
		if rs1.eof then
			open_6_7=0
			intro_6_7=0
		else
			open_6_7=rs1("qx_open")
			intro_6_7=rs1("qx_intro")
		end if
		rs1.close
		set rs1=nothing
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=6 and sort2=10"
		rs1.open sql1,conn,1,1
		if rs1.eof then
			open_6_10=0
			intro_6_10=0
		else
			open_6_10=rs1("qx_open")
			intro_6_10=rs1("qx_intro")
		end if
		rs1.close
		set rs1=nothing
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=9 and sort2=7"
		rs1.open sql1,conn,1,1
		if rs1.eof then
			open_9_7=0
			intro_9_7=0
		else
			open_9_7=rs1("qx_open")
			intro_9_7=rs1("qx_intro")
		end if
		rs1.close
		set rs1=nothing
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=9 and sort2=10"
		rs1.open sql1,conn,1,1
		if rs1.eof then
			open_9_10=0
			intro_9_10=0
		else
			open_9_10=rs1("qx_open")
			intro_9_10=rs1("qx_intro")
		end if
		rs1.close
		set rs1=nothing
		if open_1_11=3 then
			list_tj=""
		elseif open_1_11=1 then
			list_tj="and cateid in ("&intro_1_11&") and cateid>0"
		else
			list_tj="and 1=0"
		end if
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=1 and sort2=5"
		rs1.open sql1,conn,1,1
		if rs1.eof then
			open_1_5=0
			intro_1_5=0
		else
			open_1_5=rs1("qx_open")
			intro_1_5=rs1("qx_intro")
		end if
		rs1.close
		set rs1=nothing
		dim rs,sql,Str_Result,Str_Result2,catesafe,sorce_user,sorce_user2
		Str_Result="where del=1 "&list_tj&""
		Str_Result2="and del=1 "&list_tj&""
		Str_power=""
		Str_power22=""
		Str_power33=""
		sorce=0
		sorce2=0
		sorce3=0
		if open_1_11="1"  then
			set rs1=server.CreateObject("adodb.recordset")
			sql1="select ord,name,sorce,sorce2 from gate  where ord in ("&intro_1_11&") and del=1 order by sorce asc,sorce2 asc ,cateid asc ,ord asc"
			rs1.open sql1,conn,1,1
			if rs1.eof then
			else
				do until rs1.eof
					sorce=sorce&","&rs1("sorce")
					sorce2=sorce2&","&rs1("sorce2")
					sorce3=sorce3&","&rs1("ord")
					rs1.movenext
				loop
			end if
			rs1.close
			set rs1=nothing
			Str_power="where ord in ("&sorce&")"
			Str_power11="and ord in ("&sorce&")"
			Str_power2="and ord in ("&sorce2&")"
			Str_power22="where ord in ("&sorce2&")"
			Str_power3="and ord in ("&sorce3&")  and del=1"
			Str_power33="where ord in ("&sorce3&") and del=1"
		elseif open_1_11="3" then
			Str_power="where ord>0"
			Str_power11="and ord>0"
			Str_power2="and ord>0"
			Str_power22="where ord>0"
			Str_power3="and ord>0  and del=1"
			Str_power33="where ord>0 and del=1"
		else
			Str_power="where ord<0"
			Str_power2="and ord<0 "
			Str_power22="where ord<0"
			Str_power3="and ord<0"
			Str_power33="where ord<0"
		end if
		
	else
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
		sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=10"
		rs1.open sql1,conn,1,1
		if rs1.eof then
			open_26_10=0
			intro_26_10=0
		else
			open_26_10=rs1("qx_open")
			intro_26_10=rs1("qx_intro")
		end if
		rs1.close
		set rs1=nothing
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=7"
		rs1.open sql1,conn,1,1
		if rs1.eof then
			open_26_7=0
			intro_26_7=0
		else
			open_26_7=rs1("qx_open")
			intro_26_7=rs1("qx_intro")
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
		sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=26 and sort2=11"
		rs1.open sql1,conn,1,1
		if rs1.eof then
			open_26_11=0
			intro_26_11=0
		else
			open_26_11=rs1("qx_open")
			intro_26_11=rs1("qx_intro")
		end if
		rs1.close
		set rs1=nothing
		if open_26_11=3 then
			list_tj=""
		elseif open_26_11=1 then
			list_tj=" and cateid in ("&intro_26_11&") and cateid>0 "
		else
			list_tj=" and cateid=0 "
		end if
		Str_Result=" where del=1 "&list_tj&" "
		Str_Result2=" and del=1 "&list_tj&" "
		Str_power=""
		Str_power22=""
		Str_power33=""
		sorce=0
		sorce2=0
		sorce3=0
		if open_26_11="1"  then
			set rs1=server.CreateObject("adodb.recordset")
			sql1="select ord,name,sorce,sorce2 from gate  where ord in ("&intro_26_11&") and del=1 order by sorce asc,sorce2 asc ,cateid asc ,ord asc"
			rs1.open sql1,conn,1,1
			if rs1.eof then
			else
				do until rs1.eof
					sorce=sorce&","&rs1("sorce")
					sorce2=sorce2&","&rs1("sorce2")
					sorce3=sorce3&","&rs1("ord")
					rs1.movenext
				loop
			end if
			rs1.close
			set rs1=nothing
			Str_power="where ord in ("&sorce&")"
			Str_power11="and ord in ("&sorce&")"
			Str_power2="and ord in ("&sorce2&")"
			Str_power22="where ord in ("&sorce2&")"
			Str_power3="and ord in ("&sorce3&")  and del=1"
			Str_power33="where ord in ("&sorce3&") and del=1"
		elseif open_26_11="3" then
			Str_power="where ord>0"
			Str_power11="and ord>0"
			Str_power2="and ord>0"
			Str_power22="where ord>0"
			Str_power3="and ord>0  and del=1"
			Str_power33="where ord>0 and del=1"
		else
			Str_power="where ord<0"
			Str_power2="ord<0 and "
			Str_power22="where ord<0"
			Str_power3="and ord<0"
			Str_power33="where ord<0"
		end if
		
	end if
	Response.write "" & vbcrlf & "<html xmlns:v=""urn:schemas-microsoft-com:vml"" xmlns:o=""urn:schemas-microsoft-com:office:office"">" & vbcrlf & "<!--[if !mso]>" & vbcrlf & "<style>" & vbcrlf & "v\:*         { behavior: url(#default#VML) }" & vbcrlf & "o\:*         { behavior: url(#default#VML) }" & vbcrlf & ".shape       { behavior: url(#default#VML) }" & vbcrlf & "</style>" & vbcrlf & "<![endif]-->" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body {" & vbcrlf & "     margin-top: 0px;" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & ".IE5 .top_btns input.anybutton2 {height:18px;line-height:16px;margin-bottom:-0.5px;}" & vbcrlf & ".top_btns  select{height:20px!important;line-height:20px;}" & vbcrlf & ".IE5 .top_btns  select{height:22px!important;line-height:22px;}" & vbcrlf & "</style>" & vbcrlf & "<script language=""JavaScript"" type=""text/JavaScript"">" & vbcrlf & "<!--" & vbcrlf & "function MM_jumpMenu(targ,selObj,restore){//v3.0" & vbcrlf & "eval(targ+"".location=\'""+selObj.options[selObj.selectedIndex].value+""\'"");" & vbcrlf & "if (restore) selObj.selectedIndex=0;" & vbcrlf & "}" & vbcrlf & "//-->" & vbcrlf & "</script>" & vbcrlf & "</head>" & vbcrlf & "" & vbcrlf & "<body  oncontextmenu=self.event.returnValue=false  onMouseOver=""window.status='none';return true;""  scroll=AUTO>" & vbcrlf & ""
	Dim arrShow1()
	Dim arrName1()
	Dim arrFelds1()
	Dim rss,intgate1
	Set rss=conn.execute("select (case when isnull(name,'')='' then oldname else name end ) as name, (case when show>0 then 1 else 0 end) as show,fieldName,gate1 from setfields order by gate1 asc ")
	While Not rss.eof
		intgate1=rss("gate1")
		redim Preserve arrShow1(intgate1)
		redim Preserve arrName1(intgate1)
		redim Preserve arrFelds1(intgate1)
		arrShow1(intgate1)=rss("show")
		arrName1(intgate1)=rss("name")
		arrFelds1(intgate1)=rss("fieldName")
		rss.movenext
	wend
	rss.close
	dim st,m1,m1name,m2,m2name,E,F,gate2
	W1=request("W1")
	W2=request("W2")
	W3=request("W3")
	if W3<>"" then
		W1=""
		W2=""
	end if
	E=request("sort")
	F=request("sort1")
	m1=request("ret")
	m2=request("ret2")
	gate2=request("gate2")
	if gate2="" then
		gate2=1
	end if
	Str_Result2=Str_Result2+"and sort3="&sort3&""&" and isnull(order1,0)<>4 "
	gate2=1
	gate_result=""
	if m1<>"" then
		Str_Result=Str_Result+"and date2>='"&m1&" 00:00:00' "
'if m1<>"" then
		Str_Result2=Str_Result2+"and date2>='"&m1&" 00:00:00' "
'if m1<>"" then
		m1name="  起始："&m1
	end if
	if m2<>"" then
		Str_Result=Str_Result+"and date2<='"&cdate(m2)&" 23:59:59' "
'if m2<>"" then
		Str_Result2=Str_Result2+"and date2<='"&cdate(m2)&" 23:59:59' "
'if m2<>"" then
		m2name="  截止："&m2
	end if
	if E<>"" then
		Str_Result=Str_Result+"and  sort='"&E&"'"
'if E<>"" then
		Str_Result2=Str_Result2+"and  sort='"&E&"'"
'if E<>"" then
	end if
	if F<>"" then
		Str_Result=Str_Result+"and  sort1='"&F&"'"
'if F<>"" then
		Str_Result2=Str_Result2+"and  sort1='"&F&"'"
'if F<>"" then
	end if
	if W1<>"" then
		Str_Result=Str_Result+"and   cateid in ("& GetUserIdsByOrgsID(W1) &")"
'if W1<>"" then
		Str_Result2=Str_Result2+"and   cateid in ("& GetUserIdsByOrgsID(W1) &")"
'if W1<>"" then
	end if
	if W2<>"" then
		Str_Result=Str_Result+"and  cateid3='"&W2&"'"
'if W2<>"" then
		Str_Result2=Str_Result2+"and  cateid3='"&W2&"'"
'if W2<>"" then
	end if
	if W3&""<>"" and W3&""<>"0" then
		Str_Result=Str_Result+"and  cateid='"&W3&"'"
'if W3&""<>"" and W3&""<>"0" then
		Str_Result2=Str_Result2+"and  cateid='"&W3&"'"
'if W3&""<>"" and W3&""<>"0" then
	end if
	dim sort,sort1
	if E<>"" then
		set rs=server.CreateObject("adodb.recordset")
		sql="select sort1 from  sort4 where ord="&E&""
		rs.open sql,conn,1,1
		sort=rs("sort1")
		sort=sort&">>"
		rs.close
		set rs=nothing
	end if
	if F<>"" then
		set rs=server.CreateObject("adodb.recordset")
		sql="select sort1,sort2 from  sort5 where ord="&F&""
		rs.open sql,conn,1,1
		sort1=rs("sort2")
		sort1=sort1&">>"
		rs.close
		set rs=nothing
	end if
	if W1<>"" then
		set rs=server.CreateObject("adodb.recordset")
		sql="select sort1 from  gate1_full where ord="&W1&""
		rs.open sql,conn,1,1
		if rs.eof = false then
			W1name=rs("sort1")
			W1name=W1name&">>"
		end if
		rs.close
		set rs=nothing
	end if
	if W2<>"" then
		set rs=server.CreateObject("adodb.recordset")
		sql="select sort2 from  gate2 where ord="&W2&""
		rs.open sql,conn,1,1
		if rs.eof = false then
			W2name=rs("sort2")
			W2name=W2name&">>"
		end if
		rs.close
		set rs=nothing
	end if
	if W3&""<>"" and W3&""<>"0" then
		set rs=server.CreateObject("adodb.recordset")
		sql="select name from  gate where ord="&W3&""
		rs.open sql,conn,1,1
		if rs.eof = false then
			W3name=rs("name")
			W3name=W3name&">>"
		end if
		rs.close
		set rs=nothing
	end if
	khjz=request("khjz")
	khhy=request("khhy")
	khly=request("khly")
	If khjz<>"" Then Str_Result2=Str_Result2 & " and jz=" & khjz & ""
	If khhy<>"" Then Str_Result2=Str_Result2 & " and trade=" & khhy & ""
	If khly<>"" Then Str_Result2=Str_Result2 & " and ly=" & khly & ""
	dim type_tj,width_tj
	type_tj=request("type_tj")
	if type_tj="" then
		type_tj=1
	end if
	width_tj=request("width_tj")
	if width_tj="" then
		width_tj=550
	end if
	If sort3=2 Then arrName1(7)="区域"
	Response.write "" & vbcrlf & "<div id=""user"" name=""user"" style=""position:absolute;left:0; top:0;width:100%; height:10;"">" & vbcrlf & "<table class=""resetTableBg"" width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "  <tr>" & vbcrlf & "    <td class=""place"">"
	if sort3=1 then
		Response.write "客户"
	elseif sort3=2 then
		Response.write "供应商"
	end if
	Response.write "数量统计</td>" & vbcrlf & "    <td align=""left""><strong>"
	Response.write W1name
	Response.write W2name
	Response.write W3name
	Response.write sort
	Response.write sort1
	Response.write arrName1(7)
	Response.write "对比"
	Response.write m1name
	Response.write m2name
	Response.write "</strong></td>" & vbcrlf & "    <td width=""3""><img class=""resetElementHidden"" src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "<tr class=""top"">" & vbcrlf &" <form method=""POST"" action=""kh9.asp?width_tj="
	Response.write width_tj
	Response.write "&sort3="
	Response.write sort3
	Response.write """ id=""demo"" onSubmit=""return Validator.Validate(this,2)"" name=""date"">" & vbcrlf & "<td class=""top_btns"">选择统计条件：" & vbcrlf & ""
	set rs=server.CreateObject("adodb.recordset")
	sql="select top 1 gate2  from  menuarea order by gate2 desc"
	rs.open sql,conn,1,1
	if rs.eof then
		topjb=1
	else
		topjb=rs("gate2")
	end if
	rs.close
	set rs=nothing
	Response.write "" & vbcrlf & "<select name=""gate2"">" & vbcrlf & ""
	dim jb
	for jb=1 to topjb
		Response.write "" & vbcrlf & "  <option value="""
		Response.write jb
		Response.write """ "
		if jb=clng(gate2) then
			Response.write "selected"
		end if
		Response.write ">第"
		Response.write jb
		Response.write "级"
		Response.write arrName1(7)
		Response.write "</option>" & vbcrlf & ""
	next
	Response.write "" & vbcrlf & "</select>" & vbcrlf & ""
	ww111 = request("w1")
	ww222= request("w2")
	ww333 = request("w3")
	on error resume next
	if len(ww111 & "")=0 then ww111 = w1
	if len(ww222 & "")=0 then ww222 = w2
	if len(ww333 & "")=0 then ww333 = w3
	Response.write replace(sdk.setup.Select_Tj_Html(gate_person, CHG_OPEN, sysCurrPath , Str_power, Str_power2 , Str_power3, ww111, ww222, ww333),"""gatetreeselbox""","""gatetreeselbox""  ismulti=0 SID=4 ")
	
	if sort3=1 then
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
		Response.write "" & vbcrlf & "<script language=javascript>" & vbcrlf & "function inselect4()" & vbcrlf & "{" & vbcrlf & "     document.date.sort1.length=0;" & vbcrlf & "   if(document.date.sort.value==""0"" || document.date.sort.value==null || document.date.sort.value=="""")" & vbcrlf & "         document.date.sort1.options[0]=new Option('"
		Response.write arrName(5)
		Response.write "','');" & vbcrlf & "        else" & vbcrlf & "    {" & vbcrlf & "               for(i=0;i<ListUserId4[document.date.sort.value].length;i++)" & vbcrlf & "             {" & vbcrlf & "                       document.date.sort1.options[i]=new Option(ListUserName4[document.date.sort.value][i],ListUserId4[document.date.sort.value][i]);" & vbcrlf & "         }"& vbcrlf &  "    } "& vbcrlf &  "      var index=document.date.sort.selectedIndex; "& vbcrlf &  "    //sname.innerHTML=document.date.sort.options[index].text "& vbcrlf & "}"  & vbcrlf & vbcrlf & "//-->" & vbcrlf & "</script> "& vbcrlf
		Response.write arrName(5)
		Response.write "<script language=""javascript"">"&chr(13)
		Response.write "<!--"&chr(13)
		Response.write "<script language=""javascript"">"&chr(13)
		Response.write "var ListUserName4=new Array();"&chr(13)
		Response.write "var ListUserId4=new Array();"&chr(13)
		set rss=conn.execute("select * from sort4 ")
		while not rss.eof
			sid4=rss("id")
			Response.write "ListUserName4["&sid4&"]=new Array();"&chr(13)
			Response.write "ListUserId4["&sid4&"]=new Array();"&chr(13)
			Response.write "ListUserName4["&sid4&"][0]='"& rss("sort1") & "';"&chr(13)
			Response.write "ListUserId4["&sid4&"][0]='';"&chr(13)
			set rsi=conn.execute("select * from sort5 where sort1="&rss("id")&" order by gate2 desc")
			index4=1
			while not rsi.eof
				Response.write "ListUserName4["&sid4&"]["&Index4&"]='"&rsi("sort2")&"';"&chr(13)
				Response.write "ListUserId4["&sid4&"]["&Index4&"]='"&rsi("Id")&"';"&chr(13)
				Index4=Index4+1
				Response.write "ListUserId4["&sid4&"]["&Index4&"]='"&rsi("Id")&"';"&chr(13)
				rsi.movenext
			wend
			rsi.close
			set rsi=nothing
			rss.movenext
		wend
		rss.close
		set rss=nothing
		Response.write "//-->"&chr(13)
		set rss=nothing
		Response.write "</SCRIPT>"&chr(13)
		sortx=request("sort")
		if sortx="" then sortx=0
		sortx=cint(sortx)
		Response.write "<select name='sort' onChange='javascript:inselect4();' style='width:120px;'>"
		if E<>"" then
			set rs7=conn.execute("select id,sort1 from sort4 where  ord="&E&"")
			If Not rs7.eof Then
				Response.write "<option value='"&rs7("id")&"' >"&rs7("sort1")&"</option>"
				set rss=conn.execute("select * from sort4  where ord<>"&rs7("id")&" order by gate1 desc")
				while not rss.eof
					sele=""
					if int(sortx)=rss("id") Then sele="selected"
					Response.write "<option value="""&rss("id")&""" "&sele&">"&rss("sort1")&"</option>"
					rss.movenext
				wend
				rss.close
			end if
			rs7.close
			Response.write "<option value='' >"&arrName(4)&"</option>"
		else
			Response.write "<option value='' >"&arrName(4)&"</option>"
			set rss=conn.execute("select * from sort4 order by gate1 desc")
			while not rss.eof
				sele=""
				if int(sortx)=rss("id") Then sele="selected"
				Response.write "<option value="""&rss("id")&""" "&sele&">"&rss("sort1")&"</option>"
				rss.movenext
			wend
			rss.close
		end if
		Response.write "</select> "
		Response.write "<select name='sort1'  datatype='Limit' style='width:120px;'>"
		if F<>"" then
			set rs7=conn.execute("select id,sort2 from sort5 where  ord="&F&"")
			If Not rs7.eof Then
				Response.write "<option value='"&rs7("id")&"' >"&rs7("sort2")&"</option> "
				set rss=conn.execute("select id ,sort2 from sort5  where ord<>"&rs7("id")&" and sort1="&E&" order by gate2 desc")
				while not rss.eof
					sele=""
					if int(sorce)=rss("id") Then sele="selected"
					Response.write "<option value="""&rss("id")&""" "&sele&">"&rss("sort2")&"</option>"
					rss.movenext
				wend
				rss.close
			end if
			rs7.close
			Response.write "<option value='' >"&arrName(5)&"</option>"
		else
			Response.write "<option value='' >"&arrName(5)&"</option>"
			if E<>"" then
				set rss=conn.execute("select id ,sort2 from sort5 where sort1="&E&" order by gate2 desc")
				while not rss.eof
					Response.write "<option value="""&rss("id")&""">"&rss("sort2")&"</option>"
					rss.movenext
				wend
				rss.close
			end if
		end if
		Response.write "</select> "
		Response.write("<select name='khjz' dataType='Limit'>")
		Response.write("<option value=''>"&arrName(9)&"</optoin>")
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT id,sort1 FROM sortonehy WHERE gate2 = 14 ORDER BY gate1 DESC"
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While rs.Eof = False
				Response.write("<option value='"& rs("id") &"' ")
				If rs("id")&"" = khjz Then
					Response.write("selected")
				end if
				Response.write(" >"& rs("sort1") &"</option>")
				rs.movenext
			Loop
		end if
		rs.close
		set rs = nothing
		Response.write("</select> ")
		Response.write("<select name='khhy' dataType='Limit'>")
		Response.write("<option value=''>"&arrName(8)&"</optoin>")
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT id,sort1 FROM sortonehy WHERE gate2 = 11 ORDER BY gate1 DESC"
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While rs.Eof = False
				Response.write("<option value='"& rs("id") &"' ")
				If rs("id")&"" = khhy Then
					Response.write("selected")
				end if
				Response.write(" >"& rs("sort1") &"</option>")
				rs.movenext
			Loop
		end if
		rs.close
		set rs = nothing
		Response.write("</select> ")
		Response.write("<select name='khly' dataType='Limit'>")
		Response.write("<option value=''>"&arrName(6)&"</optoin>")
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT id,sort1 FROM sortonehy WHERE gate2 = 13 ORDER BY gate1 DESC"
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While rs.Eof = False
				Response.write("<option value='"& rs("id") &"' ")
				If rs("id")&"" = khly Then
					Response.write("selected")
				end if
				Response.write(" >"& rs("sort1") &"</option>")
				rs.movenext
			Loop
		end if
		rs.close
		set rs = nothing
		Response.write("</select> ")
		
	end if
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
	
	Response.write "" & vbcrlf & "<input type=""submit"" name=""Submit422"" value=""统计""  class=""anybutton2""/></td></form>" & vbcrlf & "  </tr></table>" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" >" & vbcrlf & "  <tr>" & vbcrlf & "    <td height=""30""  align=""right"" class=""top_btns"">" & vbcrlf & "           <input type=""button"" name=""pillar"" value=""柱状图分析"" onClick=""window.location.href='kh9.asp?type_tj=1&gate2="
	Response.write gate2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&sort="
	Response.write E
	Response.write "&sort1="
	Response.write F
	Response.write "&sort3="
	Response.write sort3
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write "&width_tj="
	Response.write width_tj
	Response.write "&khjz="
	Response.write khjz
	Response.write "&khly="
	Response.write khly
	Response.write "&khhy="
	Response.write khhy
	Response.write "'"" class=""anybutton2"">" & vbcrlf & "          <input type=""button"" name=""zxt"" value=""折线图分析"" onClick=""window.location.href='kh9.asp?type_tj=2&gate2="
	Response.write gate2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&sort="
	Response.write E
	Response.write "&sort1="
	Response.write F
	Response.write "&sort3="
	Response.write sort3
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write "&width_tj="
	Response.write width_tj
	Response.write "&khjz="
	Response.write khjz
	Response.write "&khly="
	Response.write khly
	Response.write "&khhy="
	Response.write khhy
	Response.write "'"" class=""anybutton2"">" & vbcrlf & "      <input type=""button"" name=""line"" value=""饼图分析"" onClick=""window.location.href='kh9.asp?type_tj=3&gate2="
	Response.write gate2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&sort="
	Response.write E
	Response.write "&sort1="
	Response.write F
	Response.write "&sort3="
	Response.write sort3
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write "&width_tj="
	Response.write width_tj
	Response.write "&khjz="
	Response.write khjz
	Response.write "&khly="
	Response.write khly
	Response.write "&khhy="
	Response.write khhy
	Response.write "'"" class=""anybutton2"">" & vbcrlf & "      <select name=""select"" onChange=""if(this.selectedIndex && this.selectedIndex!=0){window.open(this.value,'_self');}this.selectedIndex=0;"" style=""BACKGROUND: #FFFFFF; HEIGHT: 20px;font-size:12px;font-weight: bold;color:#2F496E;border:0px solid #FFFFFF; overflow:hidden"">" & vbcrlf & "        <option>-请选择-</option>" & vbcrlf & "        <option value=""kh9.asp?type_tj="
	Response.write khhy
	Response.write type_tj
	Response.write "&gate2="
	Response.write gate2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&sort="
	Response.write E
	Response.write "&sort1="
	Response.write F
	Response.write "&sort3="
	Response.write sort3
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write "&width_tj=550&khjz="
	Response.write khjz
	Response.write "&khly="
	Response.write khly
	Response.write "&khhy="
	Response.write khhy
	Response.write """ "
	if width_tj=550 then
		Response.write "selected"
	end if
	Response.write ">图宽=550</option>" & vbcrlf & "        <option value=""kh9.asp?type_tj="
	Response.write type_tj
	Response.write "&gate2="
	Response.write gate2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&sort="
	Response.write E
	Response.write "&sort1="
	Response.write F
	Response.write "&sort3="
	Response.write sort3
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write "&width_tj=700&khjz="
	Response.write khjz
	Response.write "&khly="
	Response.write khly
	Response.write "&khhy="
	Response.write khhy
	Response.write """ "
	if width_tj=700 then
		Response.write "selected"
	end if
	Response.write ">图宽=700</option>" & vbcrlf & "        <option value=""kh9.asp?type_tj="
	Response.write type_tj
	Response.write "&gate2="
	Response.write gate2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&sort="
	Response.write E
	Response.write "&sort1="
	Response.write F
	Response.write "&sort3="
	Response.write sort3
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write "&width_tj=1000&khjz="
	Response.write khjz
	Response.write "&khly="
	Response.write khly
	Response.write "&khhy="
	Response.write khhy
	Response.write """ "
	if width_tj=1000 then
		Response.write "selected"
	end if
	Response.write ">图宽=1000</option>" & vbcrlf & "        <option value=""kh9.asp?type_tj="
	Response.write type_tj
	Response.write "&gate2="
	Response.write gate2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&sort="
	Response.write E
	Response.write "&sort1="
	Response.write F
	Response.write "&sort3="
	Response.write sort3
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write "&width_tj=1500&khjz="
	Response.write khjz
	Response.write "&khly="
	Response.write khly
	Response.write "&khhy="
	Response.write khhy
	Response.write """ "
	if width_tj=1500 then
		Response.write "selected"
	end if
	Response.write ">图宽=1500</option>" & vbcrlf & "        <option value=""kh9.asp?type_tj="
	Response.write type_tj
	Response.write "&gate2="
	Response.write gate2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&sort="
	Response.write E
	Response.write "&sort1="
	Response.write F
	Response.write "&sort3="
	Response.write sort3
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write "&width_tj=2000&khjz="
	Response.write khjz
	Response.write "&khly="
	Response.write khly
	Response.write "&khhy="
	Response.write khhy
	Response.write """ "
	if width_tj=2000 then
		Response.write "selected"
	end if
	Response.write ">图宽=2000</option>" & vbcrlf & "        <option value=""kh9.asp?type_tj="
	Response.write type_tj
	Response.write "&gate2="
	Response.write gate2
	Response.write "&W1="
	Response.write W1
	Response.write "&W2="
	Response.write W2
	Response.write "&W3="
	Response.write W3
	Response.write "&sort="
	Response.write E
	Response.write "&sort1="
	Response.write F
	Response.write "&sort3="
	Response.write sort3
	Response.write "&ret="
	Response.write m1
	Response.write "&ret2="
	Response.write m2
	Response.write "&width_tj=3000&khjz="
	Response.write khjz
	Response.write "&khly="
	Response.write khly
	Response.write "&khhy="
	Response.write khhy
	Response.write """ "
	if width_tj=3000 then
		Response.write "selected"
	end if
	Response.write ">图宽=3000</option>" & vbcrlf & "      </select>" & vbcrlf & "    "
	if open_1_7=1 or open_1_7=3  then
		Response.write "<input type=""button"" name=""Submit43"" value=""打印""  onClick=""window.print()"" class=""anybutton2"">"
	end if
	Response.write "&nbsp;"
	if open_1_10=1 or open_1_10=3  then
		Response.write "<input type=""button"" name=""Submitdel2"" value=""导出"" onClick=""if(confirm('确认将统计结果导出为EXCEL文档？')){window.location.href='kh9.asp?type_tj=4&gate2="
		Response.write gate2
		Response.write "&W1="
		Response.write W1
		Response.write "&W2="
		Response.write W2
		Response.write "&W3="
		Response.write W3
		Response.write "&sort="
		Response.write E
		Response.write "&sort1="
		Response.write F
		Response.write "&sort3="
		Response.write sort3
		Response.write "&ret="
		Response.write m1
		Response.write "&ret2="
		Response.write m2
		Response.write "&width_tj="
		Response.write width_tj
		Response.write "&khjz="
		Response.write khjz
		Response.write "&khly="
		Response.write khly
		Response.write "&khhy="
		Response.write khhy
		Response.write "'}"" class=""anybutton2""/>"
	end if
	Response.write "</td>" & vbcrlf & "    </tr>" & vbcrlf & "</table>" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" id=""user2"">" & vbcrlf & "<tr bgcolor=""#FFFFFF""><td align=""left""><div align=""left""><span id=""CountTXTok"" name=""CountTXTok"" style=""font-size:10pt;"">" & vbcrlf & "  <B>正在处理数据...</B></span></div></td></tr>" & vbcrlf & "<tr>" & vbcrlf & "  <td colspan=2 class=tablebody1>" & vbcrlf & " <table width=""600"" border=""0"" cellpadding=""1"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "<tr bgcolor=""#FFFFFF"">  " & vbcrlf & "<td bgcolor=ffffff height=9><img src=""../images/bj_tiao2.gif"" style="""" width=""0"" height=""16"" id=""CountImage"" name=""CountImage"" align=""absmiddle""><img src=""../images/bj_tiao2.gif"" style="""" width=""0"" height=""16"" id=""CountImage2"" name=""CountImage2"" align=""absmiddle"">" & vbcrlf & "</table>" & vbcrlf & "  </td>" & vbcrlf & "</tr>" & vbcrlf & "<tr bgcolor=""#FFFFFF""><td><span id=""CountTXT"" name=""CountTXT"" style=""font-size:9pt; color:#008040"">0</span><span style=""font-size:9pt; color:#008040"">%</span></td></tr>" & vbcrlf & "</table>" & vbcrlf & "</div>" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" >" & vbcrlf & "  <tr>" & vbcrlf & "    <td align=""center"">" & vbcrlf & ""
	dim numcg1,zs1
	Function selects(id)
		Dim rs,strid
		strid=""
		Set rs=conn.execute("exec erp_menuarea_search '"&id&"'")
		If Not rs.eof then
			While Not rs.eof
				If Len(strid)=0 then
					strid = rs(0)
				else
					strid = strid&","&rs(0)
				end if
				rs.movenext
			wend
		end if
		rs.close
		selects=strid
	end function
	if W3=0 then W3 = ""
	conn.cursorLocation = 3
	conn.execute "select id,cast(id as varchar(8000)) ids,id1 into #area from menuarea"
	Set rsArea = conn.execute("select count(*) from #area where id1>0")
	Dim iLoop:iLoop=0
	While rsArea(0)>0 And iLoop<100
		conn.execute "update #area set ids=ids+','+cast(m.id as varchar),id1=m.id1 from menuarea m where m.id = #area.id1"
'While rsArea(0)>0 And iLoop<100
		iLoop=iLoop+1
'While rsArea(0)>0 And iLoop<100
		Set rsArea = conn.execute("select count(*) from #area where id1>0")
	wend
	rsArea.close
	Set rsArea = Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select a.id,a.id1,a.menuname,b.ids from menuarea a inner join #area b on a.id=b.id where a.gate2="&gate2&" order by a.id1 asc,a.gate1 desc"
	rs1.open sql1,conn,1,1
	counts=rs1.recordCount+1
	rs1.open sql1,conn,1,1
	redim total1(counts,2)
	redim total2(counts,3)
	redim total3(counts,2)
	dim hzb,zzb
	hzb=arrName1(7)
	zzb="数量"
	lburl=""
	if counts<=0 then
		Response.write "没有信息!"
	else
		j=1
		zs1=0
		do until rs1.eof
			arealist = rs1("ids")
			if Len(selects(rs1("id")))=0 then
				area_list=rs1("id")
			else
				area_list=selects(rs1("id"))
			end if
			numcg1=0
			sql="select count(ord) from  tel  where  isnull(sp,0)=0 and  area in ("&area_list&") "&Str_Result2&" "
			Set rs=conn.execute(sql)
			numcg1=rs(0)
			rs.close
			set rs=nothing
			title=rs1("menuname")
			if sort3=1 then
				lburl="../work/telhy.asp?fromTJ=1&A2="&arealist&"&W1="&W1&"&W2="&W2&"&W3="&W3&"&E="&E&"&F="&F&"&ret3="&m1&"&ret4="&m2&"&D="&khhy&"&A3="&khly&"&A1="&khjz
			else
				lburl="../work2/telhy.asp?A2="&rs1("id")&"&W1="&W1&"&W2="&W2&"&W3="&W3&"&E="&E&"&F="&F&"&ret3="&m1&"&ret4="&m2&""
			end if
			total1(j,1)=numcg1
			total1(j,2)=title
			total1(j,0)=lburl
			total2(j,0)=title
			total2(j,1)=numcg1
			total2(0,1)="#FF0000,1.5,1,2,客户分布"
			total2(j,2)=lburl
			total3(j,0)=title
			total3(j,1)=numcg1
			total3(j,2)=lburl
			zs1=zs1+numcg1
			total3(j,2)=lburl
			j=j+1
			total3(j,2)=lburl
			Response.write "<script>CountImage.width=" & Fix((j/counts) * 300) & ";" & VbCrLf
			Response.write "CountTXT.innerHTML=""处理进度:<font color=red><b>" & Clng(FormatNumber(j/counts*50,4,-1)) & "</b></font>"";" & VbCrLf
			Response.write "<script>CountImage.width=" & Fix((j/counts) * 300) & ";" & VbCrLf
			Response.write "CountImage.title=""正在处理数据..."";</script>" & VbCrLf
			Response.Flush
			rs1.movenext
		Loop
		sql="select count(ord) from tel where isnull(sp,0)=0 and (isnull(area,0)=0 or isnull(area,0) not in (select id from menuarea))"&Str_Result2&" "
		numcg1=conn.execute(sql)(0).value
		if sort3=1 then
			lburl="../work/telhy.asp?fromTJ=1&H=30&area=0&W1="&W1&"&W2="&W2&"&W3="&W3&"&E="&E&"&F="&F&"&ret3="&m1&"&ret4="&m2&"&D="&khhy&"&A3="&khly&"&A1="&khjz
		else
			lburl="../work2/telhy.asp?A2=-1&W1="&W1&"&W2="&W2&"&W3="&W3&"&E="&E&"&F="&F&"&ret3="&m1&"&ret4="&m2&""
		end if
		total1(j,1)=numcg1
		total1(j,2)="无"&arrName1(7)
		total1(j,0)=lburl
		total2(j,0)="无"&arrName1(7)
		total2(j,1)=numcg1
		total2(0,1)="#FF0000,1.5,1,2,客户分布"
		total2(j,2)=lburl
		total3(j,0)="无"&arrName1(7)
		total3(j,1)=numcg1
		total3(j,2)=lburl
		zs1=zs1+numcg1
		total3(j,2)=lburl
	end if
	rs1.close
	set rs1=nothing
	action1="客户数量统计"
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
	Const  HasSysTongJiJoinPage = 1
	Dim joinfileList, joinfileListText
	Sub DoSysTongJiJoinPageProc(proctype)
		Dim i, u1s, u1, u2 , existsv ,url
		u1s = Split(LCase(Request.ServerVariables("url")),"/")
		u1 = u1s(ubound(u1s))
		Dim joinfileListv, item, cnt
		existsv = false
		If joinfileListText & "" = "" Then
			joinfileListText = sdk.file.readalltext("joinpageinfos.txt")
			If Len(joinfileListText) =  0 Then joinfileListText = "-" : ReDim joinfileList(0) :  Exit sub
'joinfileListText = sdk.file.readalltext("joinpageinfos.txt")
			If Len(joinfileListText) >1 Then
				ReDim joinfileList(0)
				cnt = 0
				joinfileListv = Split(joinfileListText,vbcrlf)
				For i=0 To ubound(joinfileListv)
					item = Trim(joinfileListv(i))
					item = Replace(item,"：",":")
					If  InStr(item,":")=0  Then
						If existsv Then Exit for
						ReDim joinfileList(0)
						cnt = 0
					else
						ReDim Preserve joinfileList(cnt)
						joinfileList(cnt) = Split(item, ":")
						u2 = LCase(joinfileList(cnt)(1))
						If InStr(u1,u2)=1 Then existsv = true
						cnt = cnt + 1
'If InStr(u1,u2)=1 Then existsv = true
					end if
				next
				If existsv = False Then  ReDim joinfileList(0) : joinfileListText = "-" : Exit sub
				If InStr(u1,u2)=1 Then existsv = true
			end if
		else
			If joinfileListText = "-" Then Exit sub
			If InStr(u1,u2)=1 Then existsv = true
		end if
		Dim currk
		Dim k
		k = sdk.base64.md5(joinfileList(0)(1))
		k = sdk.Attributes(k)
		currk = -1
'k = sdk.Attributes(k)
		For i = 0 To ubound(joinfileList)
			If joinfileList(i)(0) = u1 Then
				currk = i
			end if
		next
		If Len(Request.QueryString())>0 Then
			dim kurl : kurl = replace(replace(replace(Request.QueryString(),"&frmn=1",""),"frmn=1&",""),"frmn=1","")
			if len(kurl)>0 then
				url= "?" & kurl
			else
				url = ""
			end if
		else
			url = ""
		end if
		If proctype = 0 Then
			If request.querystring("__msgid")="setdefjoinPage" Then
				sdk.Attributes(request.querystring("key")) =  request.querystring("value")
				Response.write "<script></script>"
				conn.close
				Response.end
			end if
			If Request.querystring("frmn") = "1"  And  (request.querystring("width_tj") & "")="" Then
				If isnumeric(k) Then
					If k*1 <> currk Then
						u1 = joinfileList(k)(1)
						conn.close
						Response.redirect  u1 & url
						Response.end
					end if
				end if
			end if
		else
			Response.write "" & vbcrlf & "              <style>" & vbcrlf & "         #tongjitopjoinbar {position:absolute;right:15px;top:7px;;} " & vbcrlf & "             #tongjitopjoinbar label {cursor:pointer;}" & vbcrlf & "               #setDeftjPageBoxfrm {position:absolute;left:-3000px}" & vbcrlf & "            </style>" & vbcrlf & "                <script>" & vbcrlf & "                        function jlkboxclick(box){" & vbcrlf & "                         setTimeout(function(){" & vbcrlf & "                                  window.location.href = box.value;" & vbcrlf & "                               },100);" & vbcrlf & "                 }" & vbcrlf & "" & vbcrlf & "                       function setDefTongjPage(box) {" & vbcrlf & "                                 var  frm = document.getElementById(""setDeftjPageBoxfrm"");" & vbcrlf & "                                   var  s = box.value.split(""|"")" & vbcrlf & "                                     frm.innerHTML = ""<iframe  style='width:2px;height:2px' frameborder=0 src='?__msgid=setdefjoinPage&key="" +  s[0] + ""&value="" + (box.checked?s[1]:"""") + ""&t="" + (new Date()).getTime() + ""'></iframe>""" & vbcrlf & "                      }" & vbcrlf &"          </script>" & vbcrlf & "               "
			Dim selhtm
			Response.write("<div id='tongjitopjoinbar'>")
			Dim seli:   seli= 0
			For i = 0 To ubound(joinfileList)
				item = joinfileList(i)
				If InStr(1,u1,item(1),1)=1 Then
					selhtm = " checked "
					seli = i
				else
					selhtm = ""
				end if
				Response.write "<input value='" & item(1) & ""&url&"'  onclick='jlkboxclick(this)' type=radio name='jlkboxs' id='jlkboxs" & i & "' " & selhtm & "><label for='jlkboxs" & i & "'>" & item(0) & "</label>&nbsp;"
			next
			Response.write " <input onclick='setDefTongjPage(this)' type='checkbox' id='jlkdefbox'  "
			If isnumeric(k) = False Then k = -1
'Response.write " <input onclick='setDefTongjPage(this)' type='checkbox' id='jlkdefbox'  "
			If seli*1 =  k*1 Then
				Response.write " checked "
			end if
			Response.write " value='" & sdk.base64.md5(joinfileList(0)(1)) & "|" & seli & "'><label for='jlkdefbox'>默认页</label>"
			Response.write("<div id='setDeftjPageBoxfrm'></div></div>")
		end if
	end sub
	Dim isIE
	isIE = True
	If InStr(1,sdk.vbl.GetBrowser(request),"Internet Explorer",1) <= 0 Then
		isIE = False
	end if
	Dim oldWidth,tempType, itemcountxx
	itemcountxx = ubound(total3,1)
	oldWidth = width_tj
	tempWidth = Request("width_tj")
	If tempWidth = "" Then tempWidth = 0
	If cellcountOne&""="" Then cellcountOne = 1
	If InStr(zzb & "","金额")>0 Then
		on error resume next
		for ix = 0 to cellcountOne-1
			If InStr(zzb & "","金额")>0 Then
				For i = 1 To ubound(total1)
					If Len(total1(i,ix*3+1)&"")>0 then
'For i = 1 To ubound(total1)
						total1(i,ix*3+1) = Formatnumber(total1(i,ix*3+1), sdk.Info.moneyNumber,-1)
'For i = 1 To ubound(total1)
					end if
				next
			end if
		next
		On Error GoTo 0
	end if
	If InStr(zzb & "","数量")>0 Then
		on error resume next
		for ix = 0 to cellcountOne-1
			If InStr(zzb & "","数量")>0 Then
				For i = 1 To ubound(total1)
					If Len(total1(i,ix*3+1)&"")>0 then
'For i = 1 To ubound(total1)
						total1(i,ix*3+1) = Formatnumber(total1(i,ix*3+1), sdk.Info.floatNumber,-1)
'For i = 1 To ubound(total1)
					end if
				next
			end if
		next
		On Error GoTo 0
	end if
	If type_tj = 3 Then width_tj = "100%"
	selectW = width_tj
	If oldWidth = 550 Then oldWidth = 700
	If width_tj =  "100%" Then  selectW = oldWidth
	Response.write "" & vbcrlf & "<script type=""text/javascript"" src=""../inc/echarts.min.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "" & vbcrlf & ""
	If SysTongJiJoinPageToTop ="" Then Call DoSysTongJiJoinPageProc(1)
	Response.write "" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "$(function(){" & vbcrlf & "    var ie = $.browser.msie;" & vbcrlf & "    if($.browser.version){ie=null};//echarts支持 ie7/8 统一绘图路径；" & vbcrlf & "   if(!ie){" & vbcrlf & "                var chartsType = "
	Response.write type_tj
	Response.write "" & vbcrlf & "             var chartsW = """
	Response.write width_tj
	Response.write """" & vbcrlf & "         var selectW = """
	Response.write selectW
	Response.write """" & vbcrlf & "         var width_tj = $(""select[name=width_tj]"");" & vbcrlf & "                if(width_tj.size() > 0){" & vbcrlf & "                        width_tj.css({""border"":""1px solid #9FA3BC"",""height"":""22px""});" & vbcrlf & "           }else{" & vbcrlf & "                  var wSelect = $(""select[name=select]"");" & vbcrlf & "                           wSelect.css({""border"":""1px solid #9FA3BC"",""height"":""22px""});" & vbcrlf & "                }" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "               // 隐藏页面进度条" & vbcrlf & "               $(""#user"").css(""height"",""auto"");" & vbcrlf & "              $(""#user2"").hide();" & vbcrlf & "" & vbcrlf & "               var userH = $(""#user"").height() - 20;" & vbcrlf & "" & vbcrlf & "              var chartsH = 1000;" & vbcrlf & "             // 控制饼图的高度" & vbcrlf & "               if (chartsType == ""3"")" & vbcrlf & "            {" & vbcrlf & "                       chartsH = 550;" & vbcrlf & "          }" & vbcrlf & "               $('<div id=""echarts-box"" style=""width:100%;overflow-x:auto;height:' + chartsH + 'px;""></div>').appendTo(document.body)" & vbcrlf & "           $('<div id=""echarts"" style=""width: ' + (chartsW * 1 + 260) + 'px; height:' + chartsH + 'px;overflow:hidden; ""></div>').appendTo(document.getElementById('echarts-box'));" & vbcrlf & "            var xName = ["
'Response.write selectW
	Response.write (cellcountOne-1)
'Response.write selectW
	Response.write "];           // 分类数据" & vbcrlf & "             var xValue = ["
	Response.write (cellcountOne-1)
'Response.write "];           // 分类数据" & vbcrlf & "             var xValue = ["
	Response.write "];           // 分类结果" & vbcrlf & "             "
	for ix = 0 to cellcountOne-1
'Response.write "];           // 分类结果" & vbcrlf & "             "
		Response.write "xName[" & ix & "]=[];xValue[" & ix & "]=[];"
		Dim xCategoryName,xCategoryValue,xCategoryUrl
		for i=1 to ubound(total1,1)
			xCategoryName = total1(i,ix*3+2)
'for i=1 to ubound(total1,1)
			xCategoryValue = total1(i,ix*3+1)
'for i=1 to ubound(total1,1)
			If xCategoryName <> "" Then xCategoryName = Replace(xCategoryName,"<br>"," ")
			If xCategoryValue <> "" Then xCategoryValue = Replace(xCategoryValue,",","")
			xCategoryName=sdk.htmlconvert(xCategoryName)
			xCategoryValue=sdk.htmlconvert(xCategoryValue)
			xCategoryUrl = total1(i,ix*3)
			Response.write "" & vbcrlf & "                     xName["
			Response.write ix
			Response.write "].push('"
			Response.write xCategoryName
			Response.write "');" & vbcrlf & "                  xValue["
			Response.write ix
			Response.write "].push({value: '"
			Response.write xCategoryValue
			Response.write "', name: '"
			Response.write xCategoryName
			Response.write "', url: '"
			Response.write xCategoryUrl
			Response.write "'});" & vbcrlf & "         "
		next
	next
	Response.write "" & vbcrlf & "" & vbcrlf & "             switch (chartsType)" & vbcrlf & "             {" & vbcrlf & "                       case 1:" & vbcrlf & "                         chartsType = ""bar""" & vbcrlf & "                                break;" & vbcrlf & "                  case 2:" & vbcrlf & "                         chartsType = ""line""" & vbcrlf & "                               break;" & vbcrlf & "                  case 3:" & vbcrlf & "                         chartsType = ""pie"" "& vbcrlf &"                          break; "& vbcrlf &"                   default: "& vbcrlf & "                                chartsType = ""bar"" "& vbcrlf &"                                 break; "& vbcrlf &"           } "& vbcrlf & vbcrlf & "               showECharts(chartsType,xName,xValue); "& vbcrlf &"            return false; "& vbcrlf &"    }; "& vbcrlf &" }); "& vbcrlf & vbcrlf & "window.EChartsShowX = 0;" & vbcrlf & "window.EChartsColors = ['#00aa00','#ff0000','#ff9900','#33cccc','#666699','#993300','#99cc00'];" & vbcrlf & ""
	If ubound(total2,2)>=0 and counts>0 Then
		If total2(0,0)&"" = "" Then
			tb_color = getTbColor(counts)
			len_tbColor = ubound(tb_color,2)
			For i = 0 To cellcountOne-1
'len_tbColor = ubound(tb_color,2)
				total2(0,i) = tb_color(1,(i*2+2) Mod len_tbColor) &",1.5,1,3,"
'len_tbColor = ubound(tb_color,2)
			next
		end if
	end if
	dim colscv
	if cellcountOne>=1 and multiCol&""="1" then
		for ix = 1 to cellcountOne
			if ix > 1 then colscv = colscv & ","
			if ubound(split(total2(0,ix-1), ","))>=0 then
'if ix > 1 then colscv = colscv & ","
				colscv = colscv & """" & split(total2(0,ix-1), ",")(0) & """"
'if ix > 1 then colscv = colscv & ","
			end if
		next
		Response.write "" & vbcrlf & "     window.EChartsColors = ["
		Response.write colscv
		Response.write "];" & vbcrlf & ""
	end if
	Response.write "" & vbcrlf & "// 调用统计图插件" & vbcrlf & "// sType : 统计图类型 1.柱形图；2.折线图；3.饼图" & vbcrlf & "// xName : 类目名称" & vbcrlf & "// xValue : 值" & vbcrlf & "function showECharts(sType,xName,xValue){" & vbcrlf & "        // 基于准备好的dom，初始化echarts实例" & vbcrlf & "        var myChart = echarts.init(document.getElementById('echarts'));" & vbcrlf & "                document.getElementById('echarts').style.height  = ""480px""" & vbcrlf & "                document.getElementById('echarts').style.top  = $(""#user"").height() +  ""px"";" & vbcrlf & "                //document.getElementById('echarts').style.border  = ""1px solid #eee""" & vbcrlf & "       // 指定图表的配置项和数据" & vbcrlf & "        var option = {" & vbcrlf & "            title: {" & vbcrlf & "                text: ''" & vbcrlf & "            }," & vbcrlf & "            tooltip: {" & vbcrlf & "                            formatter: '{b}：{c}'" & vbcrlf & "                   }," & vbcrlf & "                      color: window.EChartsColors," & vbcrlf & "                        calculable : true," & vbcrlf & "                      textStyle: {" & vbcrlf & "                            color: '#2f496e'" & vbcrlf & "                        }," & vbcrlf & "" & vbcrlf & "            xAxis: {" & vbcrlf & "                          name : """
	Response.write hzb
	Response.write """," & vbcrlf & "                                type : ''," & vbcrlf & "                              color: ""#00000""," & vbcrlf & "                          axisTick: {" & vbcrlf & "                                     interval : 0" & vbcrlf & "                            }," & vbcrlf & "                              axisLabel: {" & vbcrlf & "                                    interval:0," & vbcrlf & "                                     rotate: "
	dim sscww : sscww = clng("0" & request.querystring("width_tj")) - 550
	if sscww < 0 then sscww = 0
	if itemcountxx < (7 + clng(sscww/100)) then
'if sscww < 0 then sscww = 0
		Response.write "0"
	else
		Response.write "45"
	end if
	Response.write ",    // 类目名称倾斜度" & vbcrlf & "                                       textStyle: {" & vbcrlf & "                                            color: '#2f496e'" & vbcrlf & "                                        }" & vbcrlf & "                               }," & vbcrlf & "                data: xName[0]," & vbcrlf & "                               splitLine : {" & vbcrlf & "                                   show:false" & vbcrlf & "                              }," & vbcrlf & "                              axisLine : {" & vbcrlf & "                                    lineStyle:{" & vbcrlf & "                                          width: 2," & vbcrlf & "                                               type : ""solid""," & vbcrlf & "                                           color: ""#000""," & vbcrlf & "                                            shadowOffsetX:10," & vbcrlf & "                                               shadowColor:""#000""" & vbcrlf & "                                        }  " & vbcrlf & "                             }" & vbcrlf & "            }," & vbcrlf & "            yAxis: {" & vbcrlf & "                             name : """
	Response.write zzb&iif(colTipHxt&""<>"","（"& colTipHxt &"）","")
	Response.write iif(zs1&""<>"", "(总数："& zs1&")","")
	Response.write """," & vbcrlf & "                                nameGap: ""30""," & vbcrlf & "                            nameTextStyle : {" & vbcrlf & "                                       color: 'red'" & vbcrlf & "                            }," & vbcrlf & "                              axisLabel: {" & vbcrlf & "                                    textStyle: {" & vbcrlf & "                                            color: '#2f496e'        " & vbcrlf & "                                        }" & vbcrlf & "                               }," & vbcrlf & "                              splitLine : {" & vbcrlf & "                                       lineStyle : {" & vbcrlf & "                                           color: ""#aaaaff""" & vbcrlf & "                                  }" & vbcrlf & "                               }," & vbcrlf & "                              axisLine : {" & vbcrlf & "                                    lineStyle:{" & vbcrlf & "                                             width: 2," & vbcrlf & "                                               type : ""solid""," & vbcrlf & "                                           color: ""#000""," & vbcrlf & "                                            shadowOffsetY:-10," & vbcrlf & "                                            shadowColor:""#000""" & vbcrlf & "                                        }  " & vbcrlf & "                             }" & vbcrlf & "                       }," & vbcrlf & "                      grid: {" & vbcrlf & "                         left: '90'," & vbcrlf & "                             right: '20%'," & vbcrlf & "                           bottom: '600px'," & vbcrlf & "                                containLabel: true" & vbcrlf & "                      }," & vbcrlf & "     series: [" & vbcrlf & "                    "
	for i = 1 to cellcountOne
		if i > 1 then
			Response.write ","
		end if
		Response.write "" & vbcrlf & "                             {" & vbcrlf & "                                       name: '销量'," & vbcrlf & "                                   type: sType," & vbcrlf & "                                    barMinHeight: 2," & vbcrlf & "                                        barWidth : '"
		Response.write clng((40)/cellcountOne)
		Response.write "'," & vbcrlf & "                                   radius : '45%'," & vbcrlf & "                                 center: ['50%', '50%']," & vbcrlf & "                                 label:{" & vbcrlf & "                                         normal: {" & vbcrlf & "                                                       show: true," & vbcrlf & "                                                     position: ""top""," & vbcrlf & "                                                  formatter: ""{c}""," & vbcrlf & "                                                 textStyle: {" & vbcrlf & "                    color: ""#2f496e""" & vbcrlf & "                                                  }" & vbcrlf & "                                               }" & vbcrlf & "                                       }," & vbcrlf & "                                      itemStyle : {" & vbcrlf & "                                           normal : {" & vbcrlf & "                                                      color : function(item){" & vbcrlf & "                                                         if("
		Response.write cellcountOne
		Response.write "==1){" & vbcrlf & "                                                                        var result =  window.EChartsColors[window.EChartsShowX%window.EChartsColors.length];" & vbcrlf & "                                                                    window.EChartsShowX++;" & vbcrlf & "                                                                  window.itemColor = result;" & vbcrlf & "                                                                      return result;" & vbcrlf & "                                                          }else{" & vbcrlf & "                                                                  window.itemColor = window.EChartsColors["
		Response.write i
		Response.write "-1];" & vbcrlf & "                                                                 return window.EChartsColors["
'Response.write i
		Response.write i
		Response.write "-1];" & vbcrlf & "                                                         }                                                               " & vbcrlf & "                                                        }," & vbcrlf & "                                                      lineStyle : {" & vbcrlf & "                                                           "
'Response.write i
		if cellcountOne=1 and (multiCol&""="" or multiCol&""="0") then
			Response.write "" & vbcrlf & "                                                             color: ""#cc0000""" & vbcrlf & "                                                          "
		else
			Response.write "" & vbcrlf & "                                                             color: window.EChartsColors["
			Response.write i
			Response.write "-1]" & vbcrlf & "                                                          "
'Response.write i
		end if
		Response.write "" & vbcrlf & "                                                     }" & vbcrlf & "                                               }," & vbcrlf & "                                              emphasis: {" & vbcrlf & "                                                     shadowBlur: 0," & vbcrlf & "                                                  shadowOffsetX: 0," & vbcrlf & "                                                       shadowColor: 'rgba(0, 0, 0, 0)'" & vbcrlf & "                                         }" & vbcrlf & "                                       }," & vbcrlf & "                                      data:xValue["
		Response.write i-1
		Response.write "]" & vbcrlf & "                            }" & vbcrlf & "                               "
	next
	Response.write "" & vbcrlf & "                     ]" & vbcrlf & "        };" & vbcrlf & "             " & vbcrlf & "                // 饼图特殊设置" & vbcrlf & "         if(sType == ""pie""){" & vbcrlf & "                       option.xAxis = null;" & vbcrlf & "                    option.yAxis = null;" & vbcrlf & "                    option.series[0].itemStyle.normal = null;" & vbcrlf & "                       option.series[0].label.normal.formatter = ""{b}：{c}"";" & vbcrlf & "                  option.tooltip.formatter = ""{b}：{c}({d}%)"";" & vbcrlf & "              };" & vbcrlf & "" & vbcrlf & "              // 使用刚指定的配置项和数据显示图表。" & vbcrlf & "        myChart.setOption(option);" & vbcrlf & "" & vbcrlf & "        function eConsolePieClick(e) {" & vbcrlf & "                   //console.log(e); // 3.0 e有嵌套结构，不可以JSON.stringify" & vbcrlf & "                    if(e.data.url){" & vbcrlf & "                         window.location.href = e.data.url" & vbcrlf & "                       };" & vbcrlf & "        }" & vbcrlf & "        myChart.on('click',  eConsolePieClick); // 点击事件绑定 与2.0不同" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "function new_sf() {" & vbcrlf & " var d1 = document.getElementById(""daysOfMonthPos"");" & vbcrlf & "       var d2 = document.getElementById(""daysOfMonth2Pos"");" & vbcrlf & "      if(!d1 || !d2) { return true; }" & vbcrlf & " d1 = d1.value; d2 = d2.value;" & vbcrlf & "   if(d1=="""" || d2=="""") {return true;}"& vbcrlf &"     d1 = new Date(d1.replace(""-"",""/""))" & vbcrlf &  " d2 = new Date(d2.replace(""-"",""/"")) "& vbcrlf & "  if(d1>d2) { alert(""温馨提示：起始日期不能大于截止日期""); return false;} "& vbcrlf &"    var dt = (d2-d1)/1000/3600/24; "& vbcrlf &"   var strongs = document.getElementsByTagName(""strong"")[0]; "&vbcrlf & " if(strongs) {" & vbcrlf & "           if(strongs.innerHTML.indexOf(""每日走势"")>=0) {" & vbcrlf & "                    if(dt > 365*2) { alert(""温馨提示：每日走势统计时间跨度不支持超过两年。"");  return false; }" & vbcrlf & "                }" & vbcrlf & "               if(strongs.innerHTML.indexOf(""每周走势"")>=0) {" & vbcrlf & "                    if(dt > 365*10) { alert(""温馨提示：每周走势统计时间跨度不支持超过十年。"");  return false; }" & vbcrlf & "           }" & vbcrlf & "               if(strongs.innerHTML.indexOf(""每月走势"")>=0) {" & vbcrlf & "                    if(dt > 365*20) { alert(""温馨提示：每月走势统计时间跨度不支持超过二十年。"");  return false; }" & vbcrlf & "             }" & vbcrlf & "       }" & vbcrlf & "       return true;" & vbcrlf & "}" & vbcrlf & "jQuery(function(){" & vbcrlf & "      var dcbtn = jQuery(':input[value=""导出""]')[0];" & vbcrlf & "    if (dcbtn){" & vbcrlf & "             dcbtn.onclick = function(){" & vbcrlf & "                     if(confirm('确认导出为EXCEL文档？')){exportExcel({debug:false,from:'form_with_page_action',page:'"
	Response.write request("script_name")
	Response.write "?exportMode=1&'+(window.currForm.length>0?window.currForm:window.currQueryString)})}" & vbcrlf & "         }" & vbcrlf & "       }" & vbcrlf & "       $(""#Ismode"").val(1);" & vbcrlf & "      var frm = document.forms[0];" & vbcrlf & "    if(!frm)return;" & vbcrlf & " var old_sf = frm.onsubmit;" & vbcrlf & "      if(frm.getAttribute(""redimsubmit"")==null) {" & vbcrlf & "              frm.setAttribute(""redimsubmit"",1);" & vbcrlf & "                frm.onsubmit = function() {" & vbcrlf & "                     return old_sf() && new_sf();    " & vbcrlf & "                }" & vbcrlf & "       }" & vbcrlf & "});" & vbcrlf & "</script>" & vbcrlf & ""
	Dim BrowserString
	BrowserString = Request.ServerVariables("HTTP_USER_AGENT")
	BrowserString = Lcase(BrowserString)
	Dim broFirefox
	broFirefox = "firefox"
	if Instr(BrowserString, broFirefox) <> 0 then
	end if
	if counts=0 Then
		Response.write "<script>CountImage.width=0;user2.style.display='none';CountTXT.innerHTML=""<font color=red><b></b></font>  100"";CountTXTok.innerHTML="""";</script>"
	end if
	isIE = false
	exportMode = request("exportMode")
	If exportMode<>"" Then type_tj=4
	if counts>0 then
		if type_tj=1 And isIE then
			call table1(total1,20,150,width_tj/counts/3,width_tj/counts/1.5,width_tj,300,"A")
		elseif type_tj=2 And isIE then
			call table2(total2,20,150,width_tj,300,cellcountOne)
		elseif type_tj=3 And isIE then
			call table3(total3,200,180,250,250,"B")
		elseif type_tj=4 then
			call table_out(total2,total3,200,180,250,250,"B")
		end if
	end if
	function ask()
		call table3(total3,200,180,250,250,"B")
	end function
	Function getTbColor(counts)
		Dim tb_color()
		redim tb_color(counts,20)
		for z=1 to counts
			z_lenth=right(z, 1)
			If cellcountOne&""<>"1" Or multiCol&""="1" Then
				tb_color(z,1)="#d1ffd1"
				tb_color(z,2)="#00ff00"
				tb_color(z,3)="#ffbbbb"
				tb_color(z,4)="#ff0000"
				tb_color(z,5)="#ffe3bb"
				tb_color(z,6)="#ff9900"
				tb_color(z,7)="#cff4f3"
				tb_color(z,8)="#33cccc"
				tb_color(z,9)="#d9d9e5"
				tb_color(z,10)="#666699"
				tb_color(z,11)="#ffc7ab"
				tb_color(z,12)="#993300"
				tb_color(z,13)="#ecffb7"
				tb_color(z,14)="#99cc00"
				tb_color(z,15)="#d1ffd1"
				tb_color(z,16)="#00ff00"
				tb_color(z,17)="#ffbbbb"
				tb_color(z,18)="#ff0000"
				tb_color(z,19)="#ffe3bb"
				tb_color(z,20)="#ff9900"
			else
				if z_lenth=1 then
					tb_color(z,1)="#d1ffd1"
					tb_color(z,2)="#00ff00"
				elseif z_lenth=2 then
					tb_color(z,1)="#ffbbbb"
					tb_color(z,2)="#ff0000"
				elseif z_lenth=3 then
					tb_color(z,1)="#ffe3bb"
					tb_color(z,2)="#ff9900"
				elseif z_lenth=4 then
					tb_color(z,1)="#cff4f3"
					tb_color(z,2)="#33cccc"
				elseif z_lenth=5 then
					tb_color(z,1)="#d9d9e5"
					tb_color(z,2)="#666699"
				elseif z_lenth=6 then
					tb_color(z,1)="#ffc7ab"
					tb_color(z,2)="#993300"
				elseif z_lenth=7 then
					tb_color(z,1)="#ecffb7"
					tb_color(z,2)="#99cc00"
				elseif z_lenth=8 then
					tb_color(z,1)="#d1ffd1"
					tb_color(z,2)="#00ff00"
				elseif z_lenth=9 then
					tb_color(z,1)="#ffbbbb"
					tb_color(z,2)="#ff0000"
				elseif z_lenth=0 then
					tb_color(z,1)="#ffe3bb"
					tb_color(z,2)="#ff9900"
				end if
			end if
		next
		getTbColor = tb_color
	end function
	function table1(total1,table_x,table_y,thickness,table_width,all_width,all_height,table_type)
		tb_color = getTbColor(counts)
		len_tbColor = ubound(tb_color,2)
		line_color="#69f"
		left_width=70
		length=thickness/2
		total_no=ubound(total1,1)
		temp1=0
		temp6=0
		for i=1 to total_no
			For k  = 0 To cellcountOne-1
'for i=1 to total_no
				if temp1<cdbl(total1(i,k * 3 + 1)) then temp1=cdbl(total1(i,k * 3 + 1))
'for i=1 to total_no
				if temp6>cdbl(total1(i,k * 3 + 1)) then temp6=cdbl(total1(i,k * 3 + 1))
'for i=1 to total_no
			next
		next
		temp1=int(temp1)
		if temp6>=0 then
			temp6=int(temp6)
			if temp6>10 then
				temp2=mid(cstr(temp6),2,1)
				if temp2>4 then
					temp3=(int(temp6/(10^(len(cstr(temp6))-1)))-1)*10^(len(cstr(temp6))-1)
'if temp2>4 then
				else
					temp3=(int(temp6/(10^(len(cstr(temp6))-1)))-0.5)*10^(len(cstr(temp6))-1)
'if temp2>4 then
				end if
				temp6=temp3
			else
				temp6=0
			end if
		else
			temp6=int(0-temp6)
'temp6=0
			if temp6>10 then
				temp2=mid(cstr(temp6),2,1)
				if temp2>4 then
					temp3=(int(temp6/(10^(len(cstr(temp6))-1)))+1)*10^(len(cstr(temp6))-1)
'if temp2>4 then
				else
					temp3=(int(temp6/(10^(len(cstr(temp6))-1)))+0.5)*10^(len(cstr(temp6))-1)
'if temp2>4 then
				end if
				temp6=0-temp3
'if temp2>4 then
			else
				temp6=-10
'if temp2>4 then
			end if
		end if
		if temp1>9 then
			temp2=mid(cstr(temp1),2,1)
			if temp2>4 then
				temp3=(int(temp1/(10^(len(cstr(temp1))-1)))+1)*10^(len(cstr(temp1))-1)
'if temp2>4 then
			else
				temp3=(int(temp1/(10^(len(cstr(temp1))-1)))+0.5)*10^(len(cstr(temp1))-1)
'if temp2>4 then
			end if
		else
			if temp1>4 then temp3=10 else temp3=5
		end if
		temp4=temp3
		Response.write "<v:rect id='_x0000_s1027' alt='智邦国际' style='position:absolute;left:"&table_x+left_width&"px;top:"&table_y&"px;width:"&all_width&"px;height:"&all_height&"px;z-index:-1' fillcolor='#9cf' stroked='f'><v:fill rotate='t' angle='-45' focus='100%' type='gradient'/></v:rect>"
'temp4=temp3
		select case table_type
		case "A"
		for i=0 to all_height step all_height/5
			if i<>all_height then Response.write "<v:line id='_x0000_s1027' alt='' style='position:absolute;left:0;text-align:left;top:0;flip:y;z-index:-1' from='"&table_x+left_width+length&"px,"&table_y+all_height-length-i&"px' to='"&table_x+all_width+left_width&"px,"&table_y+all_height-length-i&"px' strokecolor='"&line_color&"' strokeweight='-3'/>"
'for i=0 to all_height step all_height/5
			if i<>all_height then Response.write "<v:line id='_x0000_s1027' alt='' style='position:absolute;left:0;text-align:left;top:0;flip:y;z-index:-1' from='"&table_x+left_width&"px,"&table_y+all_height-length-i&"px' to='"&table_x+left_width+length&"px,"&table_y+all_height-i&"px' strokecolor='"&line_color&"'/>"
'for i=0 to all_height step all_height/5
			Response.write "<v:line id='_x0000_s1027' alt='' style='position:absolute;left:0;text-align:left;top:0;flip:y;z-index:-1' from='"&table_x+(left_width-15)&"px,"&table_y+i&"px' to='"&table_x+left_width&"px,"&table_y+i&"px'/>"
'for i=0 to all_height step all_height/5
			Response.write ""
			Response.write "<v:shape id='_x0000_s1025' type='#_x0000_t202' alt='' style='position:absolute;left:"&table_x&"px;top:"&table_y+i&"px;width:"&left_width&"px;height:18px;z-index:-1'>"
'Response.write ""
			Response.write "<v:textbox inset='0px,0px,0px,0px'><table cellspacing='0' cellpadding='0' width='100%' height='100%'><tr><td align='right'>"&temp4&"</td></tr></table></v:textbox></v:shape>"
			temp4=temp4-(temp3-temp6)/5
		next
		Response.write "<v:line id='_x0000_s1027' alt='' style='position:absolute;left:0;text-align:left;top:0;flip:y;z-index:-1' from='"&table_x+left_width+length&"px,"&table_y&"px' to='"&table_x+left_width+length&"px,"&table_y+all_height-length&"px' strokecolor='"&line_color&"'/>"
		Response.write "<v:shape id='_x0000_s1025' type='#_x0000_t202' alt='' style='position:absolute;left:"&table_x+left_width-30&"px;top:"&table_y-20&"px;width:750px;height:18px;z-index:-1'>"
		Response.write "<v:textbox inset='0px,0px,0px,0px'><table cellspacing='0' cellpadding='0' width='150%' height='100%'><tr><td align='left'><b>"&zzb&"</b>"
		If zs1&""<>"" Then Response.write "<font color='red'>(总数："&zs1&")</font>"
		Response.write "</td></tr></table></v:textbox></v:shape>"
		Response.write "<v:shape id='_x0000_s1025' type='#_x0000_t202' alt='' style='position:absolute;left:"&table_x+left_width+all_width&"px;top:"&table_y+all_height-9&"px;width:100px;height:18px;z-index:-1'>"
'Response.write "</td></tr></table></v:textbox></v:shape>"
		Response.write "<v:textbox inset='0px,0px,0px,0px'><table cellspacing='0' cellpadding='0' width='100%' height='100%'><tr><td align='left'><b>"&hzb&"</b></td></tr></table></v:textbox></v:shape>"
		line0=(temp3/(temp3-temp6))*all_height
		Response.write "<v:line id='_x0000_s1027' alt='' style='position:absolute;left:0;text-align:left;top:0;flip:y;z-index:-1' from='"&table_x+left_width&"px,"&table_y+line0&"px' to='"&table_x+all_width+left_width&"px,"&table_y+line0&"px'></v:line>"
		Response.write "<v:line id='_x0000_s1027' alt='' style='position:absolute;left:0;text-align:left;top:0;flip:y;z-index:-1' from='"&table_x+left_width&"px,"&table_y+line0-length&"px' to='"&table_x+left_width+length&"px,"&table_y+line0&"px' strokecolor='"&line_color&"'/>"
		Response.write "<v:line id='_x0000_s1027' alt='' style='position:absolute;left:0;text-align:left;top:0;flip:y;z-index:-1' from='"&table_x+left_width+length&"px,"&table_y+line0-length&"px' to='"&table_x+all_width+left_width&"px,"&table_y+line0-length&"px' strokecolor='"&line_color&"'/>"
		table_space=(all_width-table_width*total_no)/total_no
		for i=1 to total_no
			temp_space=table_x+left_width+table_space/2 +table_space*(i-1)+table_width*(i-1)
'for i=1 to total_no
			If tj_show0&""="" Or (tj_show0&""="0" And total1(i,1)>0) then
				If total1(i,0)&"" <>"" Then
					Response.write "<a href='"&total1(i,0)&"'><v:rect title='"&total3(i,0)&"："&total1(i,1) & colTipHxt&" "&VbCrLf&"点击可查看详细列表' style='cursor:hand' "
				else
					Response.write "<v:rect title='"&total3(i,0)&"："&total1(i,1) & colTipHxt&"' "
				end if
				Response.write "id='_x0000_s1025' alt='' style='position:absolute;"
				Response.write "left:"&temp_space&"px;top:"
				if total1(i,1)>0 then
					Response.write table_y+line0-(total1(i,1)/(temp3-temp6))*all_height
'if total1(i,1)>0 then
				else
					Response.write table_y+line0
'if total1(i,1)>0 then
				end if
				Response.write "px;width:"&table_width/cellcountOne&"px;height:"&all_height*(abs(total1(i,1))/(temp3-temp6))
'if total1(i,1)>0 then
				Response.write "px;z-index:-1' fillcolor='"&tb_color(i,2)&"'>"
'if total1(i,1)>0 then
				Response.write "<v:fill color2='"&tb_color(i,1)&"' rotate='t' type='gradient'/>"
				Response.write "<o:extrusion v:ext='view' backdepth='"&thickness&"pt' color='"&tb_color(i,2)&"' on='t'/>"
				Response.write "</v:rect>"
				If total1(i,0)&"" <>"" Then Response.write "</a>"
				Response.write "<v:shape id='_x0000_s1025' type='#_x0000_t202' alt='' style='position:absolute;left:"
				If tj_show0&"" = "0" Then
					Response.write temp_space-table_width/2+table_width/(cellcountOne*10)
'If tj_show0&"" = "0" Then
				else
					Response.write temp_space-table_space/2
'If tj_show0&"" = "0" Then
				end if
				Response.write "px;top:"
				if total1(i,1)>0 then
					Response.write table_y+line0-(total1(i,1)/(temp3-temp6))*all_height-thickness/2-15
'if total1(i,1)>0 then
				else
					Response.write table_y+line0-table_width
'if total1(i,1)>0 then
				end if
				Response.write "px;width:"&table_space+table_width&"px;height:18px;z-index:-1'>"
'if total1(i,1)>0 then
				If total1(i,0)&"" <>"" Then
					Response.write "<v: title='"&total3(i,0)&"："&total1(i,1) & colTipHxt&" "&VbCrLf&"点击可查看详细列表' style='cursor:hand' ><table cellspacing='0' cellpadding='0' width='100%' height='100%'><tr><td align='center'><a href='"&total1(i,0)&"'>"&total1(i,1) & colTipHxt&"</a></td></tr></table></v:textbox></v:shape>"
				else
					Response.write "<v: title='"&total3(i,0)&"："&total1(i,1) & colTipHxt&"'><table cellspacing='0' cellpadding='0' width='100%' height='100%'><tr><td align='center'>"&total1(i,1) & colTipHxt &"</td></tr></table></v:textbox></v:shape>"
				end if
			end if
			m = 0
			For k = 1 To cellcountOne-1
'm = 0
				if tj_show0&""="" Or (tj_show0&""="0" And total1(i,k*3+1)>0) then
'm = 0
					m = m + 1
'm = 0
					If total1(i,k*3)&""<>"" then
						Response.write "<a href='"&total1(i,k*3)&"'><v:rect title='"&total3(i,k*3)&"："&total1(i,k*3+1) & colTipHxt&" "&VbCrLf&"点击可查看详细列表' style='cursor:hand' "
'If total1(i,k*3)&""<>"" then
					else
						Response.write "<v:rect title='"&total3(i,k*3)&"："&total1(i,k*3+1) & colTipHxt&"' "
					end if
					Response.write "id='_x0000_s1025' alt='' style='position:absolute;"
					Response.write "left:"&temp_space+(table_width/cellcountOne)*m &"px;top:"
'Response.write "id='_x0000_s1025' alt='' style='position:absolute;"
					if total1(i,k*3+1)>0 then
'Response.write "id='_x0000_s1025' alt='' style='position:absolute;"
						Response.write table_y+line0-(total1(i,k*3+1)/(temp3-temp6))*all_height
'Response.write "id='_x0000_s1025' alt='' style='position:absolute;"
					else
						Response.write table_y+line0
'Response.write "id='_x0000_s1025' alt='' style='position:absolute;"
					end if
					Response.write "px;width:"&table_width/cellcountOne&"px;height:"&all_height*(abs(total1(i,k*3+1))/(temp3-temp6))
'Response.write "id='_x0000_s1025' alt='' style='position:absolute;"
					Response.write "px;z-index:-1' fillcolor='"&tb_color(i,(k*2+2) Mod (len_tbColor-1))&"'>"
'Response.write "id='_x0000_s1025' alt='' style='position:absolute;"
					Response.write "<v:fill color2='"&tb_color(i,(k*2+1) Mod (len_tbColor-1))&"' rotate='t' type='gradient'/>"
'Response.write "id='_x0000_s1025' alt='' style='position:absolute;"
					Response.write "<o:extrusion v:ext='view' backdepth='"&thickness&"pt' color='"&tb_color(i,(k*2+2) Mod (len_tbColor-1))&"' on='t'/>"
'Response.write "id='_x0000_s1025' alt='' style='position:absolute;"
					Response.write "</v:rect>"
					If total1(i,k*3)&""<>"" then Response.write "</a>"
					Response.write "<v:shape id='_x0000_s1025' type='#_x0000_t202' alt='' style='position:absolute;left:"
					If tj_show0&"" = "0" Then
						Response.write temp_space-table_width/2  + (table_width/cellcountOne)*m+table_width/(cellcountOne*5)
'If tj_show0&"" = "0" Then
					else
						Response.write temp_space-table_space/2 + (table_width/cellcountOne)*m
'If tj_show0&"" = "0" Then
					end if
					Response.write "px;top:"
					if total1(i,k*3+1)>0 then
'Response.write "px;top:"
						Response.write table_y+line0-(total1(i,k*3+1)/(temp3-temp6))*all_height-thickness/2-15
'Response.write "px;top:"
					else
						Response.write table_y+line0-table_width
'Response.write "px;top:"
					end if
					Response.write "px;width:"&table_space+table_width&"px;height:18px;z-index:-1'>"
'Response.write "px;top:"
					If total1(i,k*3)&""<>"" Then
						Response.write "<v: title='"&total3(i,0)&"："&total1(i,k*3+1) & colTipHxt&" "&VbCrLf&"点击可查看详细列表' style='cursor:hand' ><table cellspacing='0' cellpadding='0' width='100%' height='100%'><tr><td align='center'><a href='"&total1(i,k*3)&"'>"&total1(i,k*3+1) & colTipHxt &"</a></td></tr></table></v:textbox></v:shape>"
					else
						Response.write "<v: title='"&total3(i,0)&"："&total1(i,k*3+1) & colTipHxt&"'><table cellspacing='0' cellpadding='0' width='100%' height='100%'><tr><td align='center'>"&total1(i,k*3+1) & colTipHxt &"</td></tr></table></v:textbox></v:shape>"
					end if
				end if
			next
			Response.write "<v:shape id='_x0000_s1025' type='#_x0000_t202' style='position:absolute;left:"&temp_space-table_space/2-(table_width/cellcountOne)*m/2&"px;top:"&table_y+all_height+1&"px;width:"&table_space+table_width&"px;height:18px;z-index:-1'>"
			If total1(i,0)&""<>"" Then
				Response.write "<v: title='"&total3(i,0)&"："&total1(i,1)&" "&VbCrLf&"点击可查看详细列表' style='cursor:hand' inset='0px,0px,0px,0px'><table cellspacing='0' cellpadding='0' width='100%' ><tr><td align='center'><a href='"&total1(i,0)&"'>"&total1(i,2)&"</a></td></tr></table></v:textbox></v:shape>"
			else
				Response.write "<v: inset='0px,0px,0px,0px' title='"&total3(i,0)&"："&total1(i,1)&"'><table cellspacing='0' cellpadding='0' width='100%' ><tr><td align='center'>"&total1(i,2)&"</td></tr></table></v:textbox></v:shape>"
			end if
			Response.write "<script>CountImage2.width=" & Fix((i/total_no) * 300) & ";" & VbCrLf
			Response.write "CountTXT.innerHTML=""处理进度:<font color=red><b>" & Clng(FormatNumber(i/total_no*50,4,-1)+50) & "</b></font>"";" & VbCrLf
'Response.write "<script>CountImage2.width=" & Fix((i/total_no) * 300) & ";" & VbCrLf
			Response.write "CountImage2.title=""正在处理数据..."";</script>" & VbCrLf
			Response.Flush
		next
		Response.write "<script>CountImage.width=0;user2.style.display='none';CountTXT.innerHTML=""<font color=red><b></b></font>  100"";CountTXTok.innerHTML="""";</script>"
		case else
		end select
		Response.write "<v:line id='_x0000_s1027' alt='' style='position:absolute;left:0;text-align:left;top:0;flip:y;z-index:-1' from='"&table_x+left_width&"px,"&table_y+all_height&"px' to='"&table_x+all_width+left_width&"px,"&table_y+all_height&"px'><v:stroke endarrow='block'/></v:line>"
'end select
		Response.write "<v:line id='_x0000_s1027' alt='' style='position:absolute;left:0;text-align:left;top:0;flip:y;z-index:-1' from='"&table_x+left_width&"px,"&table_y&"px' to='"&table_x+left_width&"px,"&table_y+all_height&"px'><v:stroke endarrow='block'/></v:line>"
'end select
	end function
	function table2(total2,table_x,table_y,all_width,all_height,line_no)
		line_color="#69f"
		left_width=70
		total_no=ubound(total2,1)
		temp1=0
		if total_no>0 then temp6=cdbl(total2(1,1))
		for i=1 to total_no
			for k=0 to line_no-1
'for i=1 to total_no
				if temp1<cdbl(total2(i,k * 3 + 1)) then temp1=cdbl(total2(i,k * 3 + 1))
'for i=1 to total_no
				if temp6>cdbl(total2(i,k * 3 + 1)) then temp6=cdbl(total2(i,k * 3 + 1))
'for i=1 to total_no
			next
		next
		temp1=int(temp1)
		if temp6>=0 then
			temp6=int(temp6)
			if temp6>10 then
				temp2=mid(cstr(temp6),2,1)
				if temp2>4 then
					temp3=(int(temp6/(10^(len(cstr(temp6))-1)))-1)*10^(len(cstr(temp6))-1)
'if temp2>4 then
				else
					temp3=(int(temp6/(10^(len(cstr(temp6))-1)))-0.5)*10^(len(cstr(temp6))-1)
'if temp2>4 then
				end if
				temp6=temp3
			else
				temp6=0
			end if
		else
			temp6=int(0-temp6)
'temp6=0
			if temp6>10 then
				temp2=mid(cstr(temp6),2,1)
				if temp2>4 then
					temp3=(int(temp6/(10^(len(cstr(temp6))-1)))+1)*10^(len(cstr(temp6))-1)
'if temp2>4 then
				else
					temp3=(int(temp6/(10^(len(cstr(temp6))-1)))+0.5)*10^(len(cstr(temp6))-1)
'if temp2>4 then
				end if
				temp6=0-temp3
'if temp2>4 then
			else
				temp6=-10
'if temp2>4 then
			end if
		end if
		if temp1>9 then
			temp2=mid(cstr(temp1),2,1)
			if temp2>4 then
				temp3=(int(temp1/(10^(len(cstr(temp1))-1)))+1)*10^(len(cstr(temp1))-1)
'if temp2>4 then
			else
				temp3=(int(temp1/(10^(len(cstr(temp1))-1)))+0.5)*10^(len(cstr(temp1))-1)
'if temp2>4 then
			end if
		else
			if temp1>4 then temp3=10 else temp3=5
		end if
		temp4=temp3
		Response.write "<v:rect id='_x0000_s1027' alt='' style='position:absolute;left:"&table_x+left_width&"px;top:"&table_y&"px;width:"&all_width&"px;height:"&all_height&"px;z-index:-1' fillcolor='#9cf' stroked='f'><v:fill rotate='t' angle='-45' focus='100%' type='gradient'/></v:rect>"
'temp4=temp3
		for i=0 to all_height step all_height/5
			Response.write "<v:line id='_x0000_s1027' alt='' style='position:absolute;left:0;text-align:left;top:0;flip:y;z-index:-1' from='"&table_x+left_width+length&"px,"&table_y+all_height-length-i&"px' to='"&table_x+all_width+left_width&"px,"&table_y+all_height-length-i&"px' strokecolor='"&line_color&"'/>"
'for i=0 to all_height step all_height/5
			Response.write "<v:line id='_x0000_s1027' alt='' style='position:absolute;left:0;text-align:left;top:0;flip:y;z-index:-1' from='"&table_x+(left_width-15)&"px,"&table_y+i&"px' to='"&table_x+left_width&"px,"&table_y+i&"px'/>"
'for i=0 to all_height step all_height/5
			Response.write ""
			Response.write "<v:shape id='_x0000_s1025' type='#_x0000_t202' alt='' style='position:absolute;left:"&table_x&"px;top:"&table_y+i&"px;width:"&left_width&"px;height:18px;z-index:-1'>"
'Response.write ""
			Response.write "<v:textbox inset='0px,0px,0px,0px'><table cellspacing='0' cellpadding='0' width='100%' height='100%'><tr><td align='right'>"&temp4&"</td></tr></table></v:textbox></v:shape>"
			temp4=temp4-(temp3-temp6)/5
		next
		Response.write "<v:line id='_x0000_s1027' alt='' style='position:absolute;left:0;text-align:left;top:0;flip:y;z-index:-1' from='"&table_x+left_width&"px,"&table_y+all_height&"px' to='"&table_x+all_width+left_width&"px,"&table_y+all_height&"px'><v:stroke endarrow='block'/></v:line>"
		Response.write "<v:line id='_x0000_s1027' alt='' style='position:absolute;left:0;text-align:left;top:0;flip:y;z-index:-1' from='"&table_x+left_width&"px,"&table_y&"px' to='"&table_x+left_width&"px,"&table_y+all_height&"px'><v:stroke endarrow='block'/></v:line>"
		Response.write "<v:shape id='_x0000_s1025' type='#_x0000_t202' alt='' style='position:absolute;left:"&table_x+left_width-30&"px;top:"&table_y-20&"px;width:750px;height:18px;z-index:-1'>"
		Response.write "<v:textbox inset='0px,0px,0px,0px'><table cellspacing='0' cellpadding='0' width='100%' height='100%'><tr><td align='left'><b>"&zzb&"</b>"
		If zs1&""<>"" Then Response.write "<font color='red'>(总数："&zs1&")</font>"
		Response.write "</td></tr></table></v:textbox></v:shape>"
		Response.write "<v:shape id='_x0000_s1025' type='#_x0000_t202' alt='' style='position:absolute;left:"&table_x+left_width+all_width&"px;top:"&table_y+all_height-9&"px;width:100px;height:18px;z-index:-1'>"
'Response.write "</td></tr></table></v:textbox></v:shape>"
		Response.write "<v:textbox inset='0px,0px,0px,0px'><table cellspacing='0' cellpadding='0' width='100%' height='100%'><tr><td align='left'><b>"&hzb&"</b></td></tr></table></v:textbox></v:shape>"
		If ubound(total2,2)>=0 and counts>0 Then
			If total2(0,0)&"" = "" Then
				tb_color = getTbColor(counts)
				len_tbColor = ubound(tb_color,2)
				For i = 0 To line_no-1
'len_tbColor = ubound(tb_color,2)
					total2(0,i) = tb_color(1,(i*2+2) Mod len_tbColor) &",1.5,1,3,"
'len_tbColor = ubound(tb_color,2)
				next
			end if
		end if
		dim line_code
		redim line_code(line_no,5)
		for i=1 to line_no
			line_temp=split(total2(0,i-1)&"",",")
'for i=1 to line_no
			If ubound(line_temp)>0 Then
				line_code(i,1)=line_temp(0)
				line_code(i,2)=line_temp(1)
				line_code(i,3)=line_temp(2)
				line_code(i,4)=line_temp(3)
				If ubound(line_temp)>=4 Then
					line_code(i,5)=line_temp(4)
				end if
			end if
		next
		for j=1 to line_no
			for i=1 to total_no
				If i<=total_no Then
					x1=table_x+left_width+all_width*(i-1)/total_no
'If i<=total_no Then
					y1=table_y+(temp3-total2(i,j * 3 - 2))*(all_height/(temp3-temp6))
'If i<=total_no Then
					If i=total_no And i+1>total_no Then
'If i<=total_no Then
						x2=table_x+left_width+all_width*(i-1)/total_no
'If i<=total_no Then
						y2=table_y+(temp3-total2(i,j * 3 - 2))*(all_height/(temp3-temp6))
'If i<=total_no Then
					else
						x2=table_x+left_width+all_width*i/total_no
'If i<=total_no Then
						y2=table_y+(temp3-total2(i+1,j * 3 - 2))*(all_height/(temp3-temp6))
'If i<=total_no Then
					end if
					Response.write "<v:line id=""_x0000_s1025"" alt="""" style='position:absolute;left:0;text-align:left;top:0;z-index:-1' from="""&x1&"px,"&y1&"px"" to="""&x2&"px,"&y2&"px"" coordsize=""21600,21600"" strokecolor="""&line_code(j,1)&""" strokeweight="""&line_code(j,2)&""">"
'If i<=total_no Then
					select case line_code(j,3)
					case 1
					case 2
					Response.write "<v:stroke dashstyle='1 1'/>"
					case 3
					Response.write "<v:stroke dashstyle='dash'/>"
					case 4
					Response.write "<v:stroke dashstyle='dashDot'/>"
					case 5
					Response.write "<v:stroke dashstyle='longDash'/>"
					case 6
					Response.write "<v:stroke dashstyle='longDashDot'/>"
					case 7
					Response.write "<v:stroke dashstyle='longDashDotDot'/>"
					case else
					end select
					Response.write "</v:line>"&CHR(13)
					select case line_code(j,4)
					case 1
					case 2
					Response.write "<v:rect id=""_x0000_s1027"" style='position:absolute;left:"&x1-2&"px;top:"&y1-2&"px;width:4px;height:4px; z-index:-1' fillcolor="""&line_code(j,1)&""" strokecolor="""&line_code(j,1)&"""/>"&CHR(13)
'case 2
					case 3
					Response.write "<v:oval id=""_x0000_s1026"" style='position:absolute;left:"&x1-2&"px;top:"&y1-2&"px;width:4px;height:4px;z-index:-1' fillcolor="""&line_code(j,1)&""" strokecolor="""&line_code(j,1)&"""/>"&CHR(13)
'case 3
					end Select
					tempCategoryName = total3(i,j * 3-3)
'end Select
					If tempCategoryName <> "" Then tempCategoryName = Replace(tempCategoryName,"<br>","")
					If total2(i,j * 3 -1)&"" <>"" Then
'If tempCategoryName <> "" Then tempCategoryName = Replace(tempCategoryName,"<br>","")
						Response.write "<v:shape id='_x0000_s1025' type='#_x0000_t202' title='"& tempCategoryName &"："&total2(i,j * 3 -2) & colTipHxt&" "&VbCrLf&"点击可查看详细列表' style='position:absolute;left:"&x1&"px;top:"&y1-15&"px;width:100px;height:18px;z-index:-1'><v:textbox inset='0px,0px,0px,0px'><table cellspacing='0' cellpadding='0' width='100%' height='100%'><tr><td align='left'><a href='"&total2(i,j * 3 -1)&"'>"&total2(i,j * 3 -2) & colTipHxt&"</a></td></tr></table></v:textbox></v:shape>"
'If tempCategoryName <> "" Then tempCategoryName = Replace(tempCategoryName,"<br>","")
					else
						Response.write "<v:shape id='_x0000_s1025' type='#_x0000_t202' title='"& tempCategoryName &"："&total2(i,j * 3 -2) & colTipHxt&"' style='position:absolute;left:"&x1&"px;top:"&y1-15&"px;width:100px;height:18px;z-index:-1'><v:textbox inset='0px,0px,0px,0px'><table cellspacing='0' cellpadding='0' width='100%' height='100%'><tr><td align='left'>"&total2(i,j * 3 -2) & colTipHxt&"</td></tr></table></v:textbox></v:shape>"
'If tempCategoryName <> "" Then tempCategoryName = Replace(tempCategoryName,"<br>","")
					end if
				end if
				Response.write "<v:line id='_x0000_s1027' alt='' style='position:absolute;left:0;text-align:left;top:0;flip:y;z-index:-1' from='"&table_x+left_width+all_width*(i-1)/total_no&"px,"&table_y+all_height&"px' to='"&table_x+left_width+all_width*(i-1)/total_no&"px,"&table_y+all_height+15&"px'/>"
				If tempCategoryName <> "" Then tempCategoryName = Replace(tempCategoryName,"<br>","")
				Response.write ""
				Response.write "<v:shape id='_x0000_s1025' type='#_x0000_t202' alt='' style='position:absolute;left:"&table_x+left_width+all_width*(i-1)/total_no&"px;top:"&table_y+all_height&"px;width:"&all_width/total_no&"px;height:18px;z-index:-1'>"
'Response.write ""
				If total2(i,j * 3 -1)&"" <>"" Then
'Response.write ""
					Response.write "<v: inset='0px,0px,0px,0px'><table cellspacing='0' cellpadding='0' width='100%' height='100%'><tr><td align='left'><a href='"&total2(i,j * 3 -1)&"'>"&total2(i,j * 3 -3)&"</a></td></tr></table></v:textbox></v:shape>"
'Response.write ""
				else
					Response.write "<v: inset='0px,0px,0px,0px'><table cellspacing='0' cellpadding='0' width='100%' height='100%'><tr><td align='left'>"&total2(i,j * 3 -3)&"</td></tr></table></v:textbox></v:shape>"
'Response.write ""
				end if
			next
			select case line_code(j,4)
			case 1
			case 2
			Response.write "<v:rect id=""_x0000_s1027"" style='position:absolute;left:"&x2-2&"px;top:"&y2-2&"px;width:4px;height:4px; z-index:-1' fillcolor="""&line_code(j,1)&""" strokecolor="""&line_code(j,1)&"""/>"&CHR(13)
'case 2
			case 3
			Response.write "<v:oval id=""_x0000_s1026"" style='position:absolute;left:"&x2-2&"px;top:"&y2-2&"px;width:4px;height:4px;z-index:-1' fillcolor="""&line_code(j,1)&""" strokecolor="""&line_code(j,1)&"""/>"&CHR(13)
'case 3
			end select
			Response.write "<v:shape id='_x0000_s1025' type='#_x0000_t202' alt='' style='position:absolute;left:"&x2&"px;top:"&y2-15&"px;width:100px;height:18px;z-index:-1'><v:textbox inset='0px,0px,0px,0px' title='"& tempCategoryName &"："&total2(i-1,j * 3 -2) & colTipHxt&"'><table cellspacing='0' cellpadding='0' width='100%' height='100%'><tr><td align='left'>"
			If total2(i-1,j * 3 -1)&""<>"" Then
'='100%' height='100%'><tr><td align='left'>"
				Response.write "<a href='"&total2(i-1,j * 3 -1)&"'>"&total2(i-1,j * 3 -2) & colTipHxt&"</a>"
'='100%' height='100%'><tr><td align='left'>"
			else
				Response.write total2(i-1,j * 3 -2) & colTipHxt
'='100%' height='100%'><tr><td align='left'>"
			end if
			Response.write "</td></tr></table></v:textbox></v:shape>"
		next
		for i=1 to total_no
			Response.write "<script>CountImage2.width=" & Fix((i/total_no) * 300) & ";" & VbCrLf
			Response.write "CountTXT.innerHTML=""处理进度:<font color=red><b>" & Clng(FormatNumber(i/total_no*50,4,-1)+50) & "</b></font>"";" & VbCrLf
'Response.write "<script>CountImage2.width=" & Fix((i/total_no) * 300) & ";" & VbCrLf
			Response.write "CountImage2.title=""正在处理数据..."";</script>" & VbCrLf
			Response.Flush
		next
		Response.write "<script>CountImage.width=0;user2.style.display='none';CountTXT.innerHTML=""<font color=red><b></b></font>  100"";CountTXTok.innerHTML="""";</script>"
		tb_height=50
	end function
	function table3(total3,table_x,table_y,all_width,all_height,table_type)
		tb_height=30
		redim tb_color(counts,2)
		for z=1 to counts
			z_lenth=right(z, 1)
			if z_lenth=1 then
				tb_color(z,1)="#d1ffd1"
				tb_color(z,2)="#00ff00"
			elseif z_lenth=2 then
				tb_color(z,1)="#ffbbbb"
				tb_color(z,2)="#ff0000"
			elseif z_lenth=3 then
				tb_color(z,1)="#ffe3bb"
				tb_color(z,2)="#ff9900"
			elseif z_lenth=4 then
				tb_color(z,1)="#cff4f3"
				tb_color(z,2)="#33cccc"
			elseif z_lenth=5 then
				tb_color(z,1)="#d9d9e5"
				tb_color(z,2)="#666699"
			elseif z_lenth=6 then
				tb_color(z,1)="#ffc7ab"
				tb_color(z,2)="#993300"
			elseif z_lenth=7 then
				tb_color(z,1)="#ecffb7"
				tb_color(z,2)="#99cc00"
			elseif z_lenth=8 then
				tb_color(z,1)="#d1ffd1"
				tb_color(z,2)="#00ff00"
			elseif z_lenth=9 then
				tb_color(z,1)="#ffbbbb"
				tb_color(z,2)="#ff0000"
			elseif z_lenth=0 then
				tb_color(z,1)="#ffe3bb"
				tb_color(z,2)="#ff9900"
			end if
		next
		total_no=ubound(total3,1)
		totalpie=0
		for i=1 to total_no
			totalpie=totalpie+total3(i,1)
'for i=1 to total_no
		next
		if totalpie=0 then
			totalpie=1
		end if
		PreAngle=0
		dim zero_tj
		zero_tj=0
		iszero = true
		For i=1 To total_no
			if total3(i,1)<>0 Then
				iszero = False
			else
				zero_tj=zero_tj+1
				iszero = False
			end if
		next
		for i=1 to total_no
			piev = total3(i,1)
			If iszero Then
				piev = 1/total_no
			end if
			Response.write "<a href='"&total3(i,2)&"'><v:shape id='_x0000_s1025'  title='点击可查看详细列表' alt='' style='position:absolute;left:"&table_x&"px;top:"&table_y&"px;width:"&all_width&"px;height:"&all_height&"px;z-index:-1' coordsize='1500,1400' o:spt='100' adj='0,,0' path='m750,700ae750,700,750,700,"&int(23592960*PreAngle)&","&int(23592960*piev/totalpie)&"xe' fillcolor='"&tb_color(i,1)&"' strokecolor='#FFFFFF'><v:fill color2='"&tb_color(i,2)&"' rotate='t' focus='100%' type='gradient'/><v:stroke joinstyle='round'/><v:formulas/><v:path o:connecttype='segments'/></v:shape></a>"&CHr(13)
			PreAngle=PreAngle+piev/totalpie
		next
		if table_type="B" then
			pie=3.14159265358979
			TempPie=0
			for i=1 to total_no
				Response.write "<script>CountImage2.width=" & Fix((i/total_no) * 300) & ";" & VbCrLf
				Response.write "CountTXT.innerHTML=""处理进度:<font color=red><b>" & Clng(FormatNumber(i/total_no*50,4,-1)+50) & "</b></font>"";" & VbCrLf
'Response.write "<script>CountImage2.width=" & Fix((i/total_no) * 300) & ";" & VbCrLf
				Response.write "CountImage2.title=""正在处理数据..."";</script>" & VbCrLf
				Response.Flush
				piev = total3(i,1)
				If iszero Then
					piev = 1/total_no
				end if
				TempAngle=pie*2*(piev/(TotalPie*2)+TempPie)
'piev = 1/total_no
				x1=table_x+all_width/2+cos(TempAngle)*all_width*3/8
'piev = 1/total_no
				y1=table_y+all_height/2-sin(TempAngle)*all_height*3/8
'piev = 1/total_no
				x2=table_x+all_width/2+cos(TempAngle)*all_width*3/4
'piev = 1/total_no
				y2=table_y+all_height/2-sin(TempAngle)*all_height*3/4
'piev = 1/total_no
				if x2>table_x+all_width/2 then
'piev = 1/total_no
					x3=x2+20
'piev = 1/total_no
					x4=x3
				else
					x3=x2-20
'x4=x3
					x4=x3-100
'x4=x3
				end if
				Response.write "<a href='"&total3(i,2)&"'><v:oval id='_x0000_s1027' title='点击可查看详细列表'  style='position:absolute;left:"&x1-2&"px;top:"&y1-2&"px;width:4px;height:4px; z-index:-1' fillcolor='#111111' strokecolor='#111111'/></a>"&CHR(13)
'x4=x3
				Response.write "<a href='"&total3(i,2)&"'><v:line id='_x0000_s1025'  title='点击可查看详细列表' alt='' style='position:absolute;left:0;text-align:left;top:0;z-index:-1' from='"&x1&"px,"&y1&"px' to='"&x2&"px,"&y2&"px' coordsize='21600,21600' strokecolor='#111111' strokeweight='1px'></v:line></a>"
'x4=x3
'Response.write "<a href='"&total3(i,2)&"'><v:line id='_x0000_s1025'  title='点击可查看详细列表' alt='' style='position:absolute;left:0;text-align:left;top:0;z-index:-1' from='"&x2&"px,"&y2&"px' to='"&x3&"px,"&y2&"px' coordsize='21600,21600' strokecolor='#111111' strokeweight='1px'></v:line></a>"
'x4=x3
				Response.write "<a href='"&total3(i,2)&"'><v:shape id='_x0000_s1025' type='#_x0000_t202' alt='' style='position:absolute;left:"&x4&"px;top:"&y2-10&"px;width:330px;height:40px;z-index:-1;'></a>"
'x4=x3
				Response.write "<v:textbox  title='点击可查看详细列表' inset='0px,0px,0px,0px'><table cellspacing='0' cellpadding='0' width='100%' style='position:relative' height='100%'><tr><td align='left'><a href='"&total3(i,2)&"'>"&total3(i,0)&" "&total3(i,1)&" 占"&formatnumber(total3(i,1)*100/totalpie,2,-1)&"%</a></td></tr></table></v:textbox></v:shape>"
				TempPie=TempPie+piev/TotalPie
			next
			Response.write "<script>CountImage.width=0;user2.style.display='none';CountTXT.innerHTML=""<font color=red><b></b></font>  100"";CountTXTok.innerHTML="""";</script>"
		end if
	end function
	function table_out(total2,total3,table_x,table_y,all_width,all_height,table_type)
		Server.ScriptTimeOut=100000000
		tb_height=30
		redim tb_color(counts,2)
		Dim font_color,j
		redim font_color(20)
		font_color(1)="#d1ffd1"
		font_color(2)="#00ff00"
		font_color(3)="#ffbbbb"
		font_color(4)="#ff0000"
		font_color(5)="#ffe3bb"
		font_color(6)="#ff9900"
		font_color(7)="#cff4f3"
		font_color(8)="#33cccc"
		font_color(9)="#d9d9e5"
		font_color(10)="#666699"
		font_color(11)="#ffc7ab"
		font_color(12)="#993300"
		font_color(13)="#ecffb7"
		font_color(14)="#99cc00"
		font_color(15)="#d1ffd1"
		font_color(16)="#00ff00"
		font_color(17)="#ffbbbb"
		font_color(18)="#ff0000"
		font_color(19)="#ffe3bb"
		font_color(20)="#ff9900"
		total_no=ubound(total3,1)
		dim zero_tj
		zero_tj=0
		Dim gpcnt : gpcnt = CInt(ubound(total3,2) / 3)
		dotstr=""
			If total_no>0 Then
				If ubound(total3,2)>0 Then
					arr_tmpdot = Split(total3(1,1)&"",".")
					If ubound(arr_tmpdot)<=0 Then
						dotNum = 0
						else
							dotNum = Len(arr_tmpdot(1)&"")
							end if
						end if
						If dotNum&"" = "" Then dotNum = num_dot_xs
						for i=1 to dotNum
							dotstr=dotstr&"0"
							next
							Set xlApplication = New ExcelApp
							xlApplication.Visible = False
							xlApplication.SheetsInNewWorkbook=1
							xlApplication.Workbooks.Add
							Set xlWorksheet = xlApplication.Worksheets(1)
							xlWorksheet.name=zzb&"统计"
							xlApplication.ActiveSheet.Columns(1).ColumnWidth=20
							xlApplication.ActiveSheet.Columns(1).HorizontalAlignment=3
							If gpcnt > 1 Then
								For j = 0 To gpcnt - 1
'If gpcnt > 1 Then
									xlApplication.ActiveSheet.Columns(j+2).ColumnWidth=20
'If gpcnt > 1 Then
									xlApplication.ActiveSheet.Columns(j+2).HorizontalAlignment=3
'If gpcnt > 1 Then
									If colTipHxt&""="" Then xlApplication.ActiveSheet.Columns(j+2).NumberFormatLocal = "#,##0."&dotstr&"_ "
'If gpcnt > 1 Then
								next
								xlApplication.ActiveSheet.Columns(j+2).ColumnWidth=20
'If gpcnt > 1 Then
								xlApplication.ActiveSheet.Columns(j+2).HorizontalAlignment=1
'If gpcnt > 1 Then
							else
								xlApplication.ActiveSheet.Columns(2).ColumnWidth=20
								xlApplication.ActiveSheet.Columns(2).HorizontalAlignment=3
								If colTipHxt&""="" Then xlApplication.ActiveSheet.Columns(2).NumberFormatLocal = "#,##0."&dotstr&"_ "
								xlApplication.ActiveSheet.Columns(3).ColumnWidth=20
								xlApplication.ActiveSheet.Columns(3).HorizontalAlignment=1
							end if
							xlWorksheet.Cells(1,1).Value = hzb
							If gpcnt > 1 Then
								For j = 0 To gpcnt - 1
'If gpcnt > 1 Then
									k = j+1
'If gpcnt > 1 Then
									If k>ubound(total3) Then k= ubound(total3)
									xlWorksheet.Cells(1,2+j).Value = iif(outItemShow&""="1",total3(k,j*3)& "-","") & zzb
'If k>ubound(total3) Then k= ubound(total3)
									xlWorksheet.Cells(1,2+j).font.bgcolor = font_color((j*2 + 2) Mod (len_tbColor-1))
'If k>ubound(total3) Then k= ubound(total3)
								next
							else
								xlWorksheet.Cells(1,2).Value =  iif(outItemShow&""="1",total3(1,0)& "-","") & zzb
								If k>ubound(total3) Then k= ubound(total3)
							end if
							xlWorksheet.Range("A2:F2").Borders.LineStyle=1
							Response.Flush
							Call xlApplication.Init(zzb&"_"&hzb&"统计_"&session("name2006chen")&".xls",total_no)
							for i=1 to total_no
								total3111=replace(total2(i,0),"<br>","-")
'for i=1 to total_no
								total3222=replace(total2(i,1),"<br>","-")
'for i=1 to total_no
								xlWorksheet.Cells(1+i,1).Value = total3111
'for i=1 to total_no
								If gpcnt > 1 Then
									For j = 0 To gpcnt - 1
'If gpcnt > 1 Then
										If colTipHxt&""<>"" Then
											xlWorksheet.Cells(1+i,2+j).Value = total2(i,j * 3 + 1) & colTipHxt
'If colTipHxt&""<>"" Then
										else
											xlWorksheet.Cells(1+i,2+j).Value = total2(i,j * 3 + 1)
'If colTipHxt&""<>"" Then
										end if
									next
								else
									xlWorksheet.Cells(1+i,2).Value = total3222
'If colTipHxt&""<>"" Then
								end if
								Response.Flush
							next
							Set fs = CreateObject("Scripting.FileSystemObject")
							tfile=Server.MapPath("../out/"&zzb&"_"&hzb&"统计_"&session("name2006chen")&".xls")
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
						end if
					end function
	call close_list(1)
	Response.write "" & vbcrlf & "</td></tr>" & vbcrlf & "</table>" & vbcrlf & "</body>" & vbcrlf & "</html>"
	
%>
