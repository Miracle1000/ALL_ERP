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
	
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_1=0
		intro_67_1=0
	else
		open_67_1=rs1("qx_open")
		intro_67_1=rs1("qx_intro")
		If Len(intro_67_1&"") = 0 Then intro_67_1 = 0
		If Left(intro_67_1,1) = "," Then intro_67_1 = Right(intro_67_1,Len(intro_67_1)-1)
'If Len(intro_67_1&"") = 0 Then intro_67_1 = 0
		If right(intro_67_1,1) = "," Then intro_67_1 = left(intro_67_1,Len(intro_67_1)-1)
'If Len(intro_67_1&"") = 0 Then intro_67_1 = 0
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_7=0
		intro_67_7=0
	else
		open_67_7=rs1("qx_open")
		intro_67_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_8=0
		intro_67_8=0
	else
		open_67_8=rs1("qx_open")
		intro_67_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_10=0
		intro_67_10=0
	else
		open_67_10=rs1("qx_open")
		intro_67_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_11=0
		intro_67_11=0
	else
		open_67_11=rs1("qx_open")
		intro_67_11=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_3=0
		intro_67_3=0
	else
		open_67_3=rs1("qx_open")
		intro_67_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=12"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_12=0
		intro_67_12=0
	else
		open_67_12=rs1("qx_open")
		intro_67_12=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_13=0
		intro_67_13=0
	else
		open_67_13=rs1("qx_open")
		intro_67_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=17"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_17=0
		intro_67_17=0
	else
		open_67_17=rs1("qx_open")
		intro_67_17=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=15"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_15=0
		intro_67_15=0
	else
		open_67_15=rs1("qx_open")
		intro_67_15=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=19"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_19=0
		intro_67_19=0
	else
		open_67_19=rs1("qx_open")
		intro_67_19=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power with(nolock) where ord="&session("personzbintel2007")&" and sort1=67 and sort2=20"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_67_20=0
		intro_67_20=0
	else
		open_67_20=rs1("qx_open")
		intro_67_20=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_1=0
		intro_77_1=0
	else
		open_77_1=rs1("qx_open")
		intro_77_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_77_1 & "" = "" Then intro_77_1 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_14=0
		intro_77_14=0
	else
		open_77_14=rs1("qx_open")
		intro_77_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_77_14 & "" = "" Then intro_77_14 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_7=0
		intro_77_7=0
	else
		open_77_7=rs1("qx_open")
		intro_77_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_77_7 & "" = "" Then intro_77_7 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_8=0
		intro_77_8=0
	else
		open_77_8=rs1("qx_open")
		intro_77_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_77_8 & "" = "" Then intro_77_8 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_10=0
		intro_77_10=0
	else
		open_77_10=rs1("qx_open")
		intro_77_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_77_10 & "" = "" Then intro_77_10 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_11=0
		intro_77_11=0
	else
		open_77_11=rs1("qx_open")
		intro_77_11=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_77_11 & "" = "" Then intro_77_11 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_3=0
		intro_77_3=0
	else
		open_77_3=rs1("qx_open")
		intro_77_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_77_3 & "" = "" Then intro_77_3 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=12"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_12=0
		intro_77_12=0
	else
		open_77_12=rs1("qx_open")
		intro_77_12=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_77_12 & "" = "" Then intro_77_12 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_13=0
		intro_77_13=0
	else
		open_77_13=rs1("qx_open")
		intro_77_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_77_13 & "" = "" Then intro_77_13 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=17"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_17=0
		intro_77_17=0
	else
		open_77_17=rs1("qx_open")
		intro_77_17=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_77_17 & "" = "" Then intro_77_17 = "0"
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=77 and sort2=19"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_77_19=0
		intro_77_19=0
	else
		open_77_19=rs1("qx_open")
		intro_77_19=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	If intro_77_19 & "" = "" Then intro_77_19 = "0"
	
	ZBRLibDLLNameSN = "ZBRLib3205"
	Class customFieldClass
		Public dbname
		Public Key
		Public show
		Public name
		Public point
		Public enter
		Public sort2
		Public required
		Public extra
		Public isformat
		Public sorttype
		Public search
		Public import
		Public export
		Public census
	End Class
	Function GetFields(sort)
		If sort&""="" Then sort = 1
		Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim rs ,sql, field
		sql = "select (case when isnull(name,'')='' then oldname else name end ) as name,(case when show>0 then 1 else 0 end) as show,(case when Required>0 then 1 else 0 end ) as Required ,"&_
		"   gate1 ,point ,enter, sort2,extra , format ,type , fieldName "&_
		"   from setfields where sort="& sort &" order by sort2, order1 asc "
		set rs = conn.execute(sql)
		While rs.eof = False
			Set field = New customFieldClass
			With field
			.dbname = rs("fieldName").value
			.Key    = rs("gate1").value
			.show   = (rs("show").value = "1")
			.name   = rs("name").value
			.point  = (rs("point").value = "1" And rs("show").value = "1")
			.enter  = (rs("enter").value = "1" And rs("show").value = "1")
			.sort2  = CInt(rs("sort2").value)
			.required=(rs("required").value = "1" And rs("show").value = "1")
			.extra  = rs("extra").value&""
			.isformat=(rs("format").value = "1" And rs("show").value = "1")
			.sorttype   = CInt(rs("type").value)
			End With
			fields.add field
			rs.movenext
		wend
		rs.close
		Set GetFields = fields
	end function
	Function hasOpenZdy(sort)
		If sort&""="" Then sort = 1
		hasOpenZdy = (conn.execute("select 1 from zdy where sort1="& sort &" and set_open = 1 ").eof = false)
	end function
	Function GetZdyFields(sort)
		If sort&""="" Then sort = 1
		Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim rs ,sql, field
		sql = "select * from zdy where sort1="& sort &" order by gate1 asc "
		set rs = conn.execute(sql)
		While rs.eof = False
			Set field = New customFieldClass
			With field
			.dbname = rs("name").value
			.Key    = rs("id").value
			.show   = (rs("set_open").value = "1")
			.name   = rs("title").value
			.point  = (rs("ts").value = "1" And rs("set_open").value = "1")
			.enter  = (rs("jz").value = "1" And rs("set_open").value = "1")
			.required=(rs("bt").value = "1" And rs("set_open").value = "1")
			.extra  = rs("gl").value
			.sorttype   = CInt(rs("sort").value)
			.search = (rs("js").value = "1" And rs("set_open").value = "1")
			.import = (rs("dr").value = "1" And rs("set_open").value = "1")
			.export = (rs("dc").value = "1" And rs("set_open").value = "1")
			.census = (rs("tj").value = "1" And rs("set_open").value = "1")
			End With
			fields.add field
			rs.movenext
		wend
		rs.close
		Set GetZdyFields = fields
	end function
	Function hasOpenExtra(sort)
		If sort&""="" Then sort = 1
		hasOpenExtra = (conn.execute("select 1 from ERP_CustomFields where TName="& sort &" and IsUsing=1 and del=1 ").eof = False)
	end function
	Function GetExtraFields(sort)
		If sort&""="" Then sort = 1
		Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim rs ,sql, field
		sql = "select f.id,f.IsUsing ,f.FType,f.FName,f.MustFillin, ((case f.FType when 1 then 'danh_' when 2 then 'duoh_' when 3 then 'date_' when 4 then 'Numr_' when 5 then 'beiz_' when 6 then 'IsNot_' else 'meju_' end ) + cast(f.id as varchar(20)) ) as dbname,f.CanSearch,f.CanInport ,f.CanExport, f.CanStat  from ERP_CustomFields f where f.TName="& sort &" and f.del=1 order by f.FOrder asc "
		set rs = conn.execute(sql)
		While rs.eof = False
			Set field = New customFieldClass
			With field
			.dbname = rs("dbname").value
			.Key    = rs("id").value
			.show   = rs("IsUsing").value
			.name   = rs("FName").value
			.required=(rs("MustFillin").value And rs("IsUsing").value)
			.extra  = rs("id").value
			.sorttype   = CInt(rs("FType").value)
			.search = (rs("CanSearch").value  And rs("IsUsing").value )
			.import = (rs("CanInport").value  And rs("IsUsing").value )
			.export = (rs("CanExport").value  And rs("IsUsing").value )
			.census = (rs("CanStat").value  And rs("IsUsing").value )
			End With
			fields.add field
			rs.movenext
		wend
		rs.close
		Set GetExtraFields = fields
	end function
	Dim checkmustcontentPersons
	Function getbacktel(ord,v2,needtype)
		getbacktel =  getbackteldata(ord,v2,needtype, 1)
	end function
	Function getbacktelForTmp(ord,v2,needtype)
		getbacktelForTmp =  getbackteldata(ord,v2,needtype, 2)
	end function
	Function getbackteldata(ord,v2,needtype, dtype)
		Dim f_rs,f_sql,remind,reminddays,tord,n,backday,cansum,sql_result
		Dim basesql
		n=0
		If needtype>0 Then
			If needtype=3 Then sql_result=" and backdays<=3 "
			If needtype=7 Then sql_result=" and backdays<=7  and backdays>3 "
			If needtype=10 Then sql_result=" and backdays<=10 and backdays>7 "
			If needtype=15 Then sql_result=" and backdays<=15 and backdays>10 "
			If needtype=999999 Then sql_result=" and backdays>15 "
		else
			sql_result=" and canremind=1 and  backdays<=reminddays "
		end if
		basesql = "select ord into #tmpbacktel from dbo.erp_sale_getBackList('" & v2 & "',0) a where a.cateid in (" & ord & ")  " & sql_result
		If dtype = 1 Then
			getbackteldata = Replace(basesql,"into #tmpbacktel"," ")
			Exit Function
		else
			conn.execute basesql
		end if
	end function
	Function getTelList(ord,v2)
		Dim f_sql,f_rs,v,v1, m
		If len(ord) = 0 Then
			f_sql = "select x.ord from dbo.erp_sale_getWillReplyList('" & v2 & "',0) x"
		else
			f_sql = "select x.ord from dbo.erp_sale_getWillReplyList('" & v2 & "',0) x where x.cateid in (" & ord & ")"
		end if
		Set f_rs=conn.execute(f_sql)
		Do While Not f_rs.eof
			If v1="" Then
				v1=f_rs(0).value
			else
				v1=v1 & "," & f_rs(0).value
			end if
			f_rs.movenext
		Loop
		f_rs.close : Set f_rs=Nothing
		getTelList=v1
	end function
	sub error(message)
		Response.write "" & vbcrlf & "     <script>alert('"
		Response.write message
		Response.write "');if(!parent.window.iswork){history.back()}</script>" & vbcrlf & "        "
		call db_close : Response.end
	end sub
	Function GetSortBtFields(byval sort, byval sort1)
		Dim list : Set list = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim MustContentType : MustContentType = 0
		Dim currgate2 : currgate2 = 0
		Dim rs ,sql
		Set rs =  conn.execute("select isnull(MustContentType,0) as MustContentType, gate2 from sort5 where sort1=" & sort & " and ord=" & sort1)
		if rs.eof= False Then
			MustContentType = rs("MustContentType").value
			currgate2 = rs("gate2").value
		end if
		rs.close
		sql = "select musthas, MustContentType, isnull(mustContent,'') as mustContent,isnull(mustRole,'') as mustRole, isnull(mustzdy,'') as mustzdy, isnull(mustkz_zdy,'') as mustkz_zdy  from sort5  where sort1=" & sort
		if MustContentType = 2 Then
			sql = sql & " and (gate2 >" & currgate2 & " or ord=" & sort1 & ") and MustContentType > 0 "
		elseif MustContentType = 1 then
			sql = sql & " and ord =" & sort1
		else
			sql = sql & " and 1=0 "
		end if
		Dim amustcontent :amustcontent = ""
		Dim amustrole : amustrole = ""
		Dim amustzdy : amustzdy = ""
		Dim amustkz_zdy : amustkz_zdy = ""
		Dim C : C = ""
		Dim R : R = ""
		Dim Z : Z = ""
		Dim K : K = ""
		set rs = conn.execute(sql)
		While rs.eof= False
			C = rs("mustContent").value
			R = rs("mustRole").value
			Z = rs("mustzdy").value
			K = rs("mustkz_zdy").value
			if Len(C)> 0 Then
				if Len(amustcontent)> 0 Then  amustcontent = amustcontent & ","
				amustcontent = amustcontent & Replace(C ," ", "")
			end if
			if Len(R) > 0 Then
				if len(amustrole) > 0 Then amustrole = amustrole & ","
				amustrole = amustrole & Replace(R ," ", "")
			end if
			if len(Z)> 0 Then
				if len(amustzdy)> 0 then amustzdy = amustzdy & ","
				amustzdy = amustzdy & Replace(Z ," ", "")
			end if
			if Len(K)>0 Then
				if len(amustkz_zdy) > 0 Then amustkz_zdy = amustkz_zdy & ","
				amustkz_zdy = amustkz_zdy & Replace(K ," ", "")
			end if
			rs.movenext
		wend
		rs.close
		list.Add amustcontent
		list.Add amustrole
		list.Add amustzdy
		list.Add amustkz_zdy
		Set GetSortBtFields = list
	end function
	Function CustomStageWatchs(byval ID , isCurrentNext, sort, sort1, type_ChangeSort, id_ChangeSort, intro_ChangeSort)
		Dim rs
		Dim v1 : v1 = ""
		Dim v2 : v2 = ""
		Dim v3 : v3 = ""
		Dim v4 : v4 = ""
		Dim list
		Set list = GetSortBtFields(sort, sort1)
		v1 = checkmustcontent(list.item(0), list.item(1),ID)
		v2 = checkrole(list.item(1),list.item(0),ID)
		v3 = checkzdy(list.item(2),ID)
		v4 = checkkz_zdy(list.item(3), ID)
		if Len(v1 & v2 & v3 & v4)> 0 Then
			Dim s : s = IntToStr(1 ,v1, v2 , v3 , v4)
			CustomStageWatchs ="本阶段有必填项未填写，请填写后再保存！" & s & ""
			Exit Function
		end if
		If isCurrentNext = False Then CustomStageWatchs = "" : Exit Function
		Call saveSort5change(ID, sort, sort1, type_ChangeSort, id_ChangeSort , intro_ChangeSort)
		Set rs = conn.execute("select s.ord, s.sort1, s.sort2, isnull(s.mustHas,0) as  mustHas, s.gate2,s.AutoNext from sort5 s inner join tel t on t.sort=s.sort1 and t.ord=" & id & " and gate2<(select gate2 from sort5 where ord=t.sort1) order by gate2 desc")
		Do While rs.eof = False
			if rs("AutoNext") = "1" Then
				sort = rs("sort1")
				sort1 = rs("ord")
				Set list = GetSortBtFields(sort, sort1)
				v1 = checkmustcontent(list.item(0), list.item(1),ID)
				v2 = checkrole(list.item(1),list.item(0),ID)
				v3 = checkzdy(list.item(2),ID)
				v4 = checkkz_zdy(list.item(3), ID)
				if Len(v1 & v2 & v3 & v4)=0 Then
					Call saveSort5change(ID, sort, sort1, 0, 0, "系统自动跳转")
				else
					Exit Do
				end if
			else
				Exit Do
			end if
			if rs("mustHas").value = "1" Then  Exit Do
			rs.movenext
		Loop
		rs.close
		CustomStageWatchs = ""
	end function
	Function  Sort1FieldsTest(ord, sort, sort1)
		Sort1FieldsTest = False
		Dim returnStr : returnStr= CustomStageWatchs(ord, False , sort, sort1, 1, ord ,"")
		If Len(returnStr)>0 Then
			Error returnStr
		end if
		Sort1FieldsTest = true
	end function
	Function autoSkipSort(ord,sort,sort1,reason,reasonid,nosortmode,slient,intro)
		autoSkipSort=True
		Dim presort,presort1,gate2,tgate2
		Dim f_rs,n
		n=0
		Dim mustcontent,mustrole,mustzdy,mustkz_zdy,Aend,autonext,autonext1
		Dim amustcontent,amustrole,amustzdy,amustkz_zdy,mustContentType
		Dim mustcon_tip,mustrole_tip,mustzdy_tip,mustkz_tip,isbt,namelist
		Aend=0
		If Len(ord&"")=0 Then ord=0
		If Len(sort&"")=0 Then sort=0
		If Len(sort1&"")=0 Then sort1=0
		Set f_rs=conn.execute("select isnull(sort,0) as sort,isnull(sort1,0) as sort1 from tel where ord="&ord)
		If f_rs.eof=False Then
			presort=f_rs(0).value
			presort1=f_rs(1).value
		else
			presort=0 : presort1=0 : autoSkipSort=False : Exit function
		end if
		f_rs.close
		If Len(presort&"")=0 Then presort=0
		If Len(presort1&"")=0 Then presort1=0
		If nosortmode Then sort=presort : sort1=presort1
		Dim returnStr : returnStr= CustomStageWatchs(ord ,True , sort, sort1, reason , reasonid ,intro)
		if Len(returnStr) > 0 And slient = True Then
			If ismobileApp = False Then Error returnStr
			autoSkipSort = False
			Exit function
		end if
		autoSkipSort = True
	end function
	Function getnextsort(sort,sort1)
		Dim Frs,Fsql
		Set Frs=conn.execute("select * from sort5 where sort1="&sort&" and ord<>" & sort1 & " and gate2<=(select gate2 from sort5 where sort1="&sort&" and ord="&sort1&") order by gate2 desc")
		If Frs.eof=False Then
			getnextsort=Frs("ord")
		else
			getnextsort=0
		end if
		Frs.close : Set Frs=nothing
	end function
	Function saveSort5change(ord,sort,sort1,reason,reasonid,Fintro)
		Dim state : state = "0"
		Dim rs , sql
		Dim oldsort : oldsort = 0
		Dim oldsort1 : oldsort1 = 0
		Set rs =conn.execute("select top 1 isnull(sort,0) as sort,isnull(sort1,0) as sort1 from tel where ord=" & ord)
		If rs.eof = False Then
			oldsort = rs("sort")
			oldsort1 =rs("sort1")
		end if
		rs.close
		if oldsort1<>sort1 or sort<0 Then
			if sort < 0 Then
				sort = oldsort
				sort1 = oldsort1
				state = "0"
			else
				state = getstate(oldsort,oldsort1,sort,sort1,ord)
			end if
		end if
		sql = "insert into tel_sort_change_log(tord,sort3,preSort,preSort1,newSort,newSort1,cateid,cateid2,cateid3,reason,reasonid,intro,state,date2,date7,cateadd) " &_
		"select ord ,sort3,sort,sort1,'"  & sort &  "','"  & sort1 &"',cateid , cateid2 ,cateid3,'" & reason &"','" & reasonid & "','" & Fintro & "','" & state & "',date2,getdate()," & session("personzbintel2007") &  " from tel where ord = " & ord
		conn.execute(sql)
		If state<>"0" Then conn.execute("update tel set sort=" & sort &",sort1="  & sort1 & " where ord=" & ord)
	end function
	Function getstate(psort,psort1,nsort,nsort1,ord)
		Dim f_rs ,sortSql
		If psort1=0 And nsort1<>0 Then
			getstate=1
			Exit Function
		end if
		If psort&""<>nsort&"" Then
			sortSql="set nocount on;"&_
			"select identity(int,1,1) as id1,cast(ord as int) as ord into #sort4 from (select top 100000000 ord from sort4 order by gate1 desc) a ;"&_
			"select * from #sort4 where ord=" & nsort & " and id1>(select id1 from #sort4 where ord=" & psort & ");"&_
			"drop table #sort4;set nocount off;"
			Set f_rs=conn.execute(sortSql)
			If f_rs.eof=false Then
				getstate=1
			else
				getstate=-1
				getstate=1
			end if
			Exit Function
		end if
		if psort1&""=nsort1&"" then getstate=0 : exit function
		If Len(psort&"")=0 Then psort=0
		If Len(psort1&"")=0 Then psort1=0
		If Len(nsort1&"")=0 Then nsort1=0
		sortSql="set nocount on;"&_
		"select identity(int,1,1) as id1,cast(ord as int) as ord,sort1 into #sort5 from (select top 100000000 ord,sort1 from sort5 where sort1=" & psort & " order by gate2 desc) a;"&_
		"select * from #sort5 where ord=" & nsort1 & " and id1>(select id1 from #sort5 where ord=" & psort1 & ");"&_
		"drop table #sort5;set nocount off;"
		Set f_rs=conn.execute(sortSql)
		If f_rs.eof=false Then
			getstate=1
		else
			getstate=-1
			getstate=1
		end if
		f_rs.close : Set f_rs=Nothing
	end function
	Function getContentName(value,isid)
		Dim v,s,i
		v=Split("6,7,8,9,10,11,12,13,14,15,25,27,28,18,19,20,21,23,24,22,92,93,94,95,96,97,98,99,100",",")
		s=Split("来源,区域,行业,价值,网址,到款,地址,邮编,法人,注册资本,籍贯,部门,职务,家庭电话,办公电话,手机,传真,QQ,MSN,电子邮件,联系人,客户电话,客户传真,客户邮件,已联系,建立项目,已报价,已成交,关联售后",",")
		If isid=True And value&""<>"" Then
			For i=0 To ubound(v)
				If value&""=v(i)&"" Then getContentName=s(i) : Exit For : Exit Function
			next
		else
			For i=0 To ubound(s)
				If value&""=s(i)&"" Then getContentName=v(i) : Exit For : Exit Function
			next
		end if
	end function
	Function patchrep(strs,str1)
		Dim allstr,tstr,f_i
		If Len(str1&"")=0 Then patchrep=strs : Exit Function
		If Len(strs&"")=0 Then patchrep=str1 : Exit Function
		allstr = strs & "," & str1
		allstr = Replace(allstr," ","")
		tstr = Split(allstr,",")
		allstr=""
		For f_i=0 To ubound(tstr)
			If InStr(1,"," & allstr & ",","," & tstr(f_i) & ",",1)=0 Then
				If allstr="" then
					allstr=tstr(f_i)
				else
					allstr=allstr & "," &tstr(f_i)
				end if
			end if
		next
		patchrep=allstr
	end function
	Function patchrep2(strs,str1)
		Dim allstr,tstr,f_i
		If Len(str1&"")=0 Then patchrep2="" : Exit Function
		If Len(strs&"")=0 Then patchrep2="" : Exit Function
		allstr = Replace(str1," ","")
		tstr = Split(allstr,",")
		allstr=""
		For f_i=0 To ubound(tstr)
			If InStr(1,"," & strs & ",","," & tstr(f_i) & ",",1)>0 Then
				If allstr="" then
					allstr=tstr(f_i)
				else
					allstr=allstr & "," &tstr(f_i)
				end if
			end if
		next
		patchrep2=allstr
	end function
	Function ifarray(obj)
		If Not isArray(obj) Then ifarray=False
		Dim v,n
		v=Err.number
		on error resume next
		n=ubound(obj)
		If Abs(Err.number)<>Abs(v) Then
			ifarray=False
		else
			ifarray=True
		end if
		Err.number=v
		On Error GoTo 0
	end function
	Sub showlyEndMsg(ByVal msg)
		Response.write"<script language=javascript>window.alert(""" & Replace( msg, """", "\""" ) & """);if(parent.window.iswork){}else{history.back();}</script>"
		call db_close
		Response.end
	end sub
	Function WatchCustomNumber(ByVal gord, byval addnum, ByVal IsAdd)
		Dim rs, uid
		uid = gord  & ""
		If uid = "" Or uid = "0" Then
			Exit Function
		end if
		Dim hasly_all, hasly_day, hasly_day_add,  hasly_all_add
		Dim openA1, openA2, openB1, openB2, NumA, NumB
		openA1 = 0 : openA2 = 0 : openB1 = 0 : openB2 = 0 : NumA = 0 : NumB = 0
		Set rs = conn.execute("select isnull(sum(case datediff(d,date2,getdate()) when 0 then 1 else 0 end),0) as v1 , count(1) as v2, isnull(sum(case cateid when cateadd then (case datediff(d,date2,getdate()) when 0 then 1 else 0 end) else 0 end),0) as v3, isnull(sum(case cateid when cateadd then 1 else 0end),0) as v4 from tel where cateid = "  & uid & " and sort3=1 and isnull(sp,0)=0 and del=1")
		If rs.eof = False then
			hasly_day = rs(0).value
			hasly_all = rs(1).value
			hasly_day_add = rs(2).value
			hasly_all_add = rs(3).value
		end if
		rs.close
		Set rs = conn.execute("select isnull(intro,'0'), isnull(extra,'0') from setopen  where sort1=25")
		If rs.eof = False then
			openA1 = rs(0).value
			openA2 = rs(1).value
		end if
		rs.close
		Set rs = conn.execute("select isnull(intro,'0'), isnull(extra,'0') from setopen  where sort1=37")
		If rs.eof = False then
			openB1 = rs(0).value
			openB2 = rs(1).value
		end if
		rs.close
		Set rs = conn.execute("select isnull(num_4,0) as maxnum,isnull(num_ly,0) as maxly from gate where ord=" & uid)
		If rs.eof = False Then
			NumA = rs(0).value
			numB = rs(1).value
		end if
		rs.close
		If openA1 >= 1 Then
			If openA2 = 1 Then
				If hasly_all + addnum > NumA Then
'If openA2 = 1 Then
					WatchCustomNumber = "账号最多可以领用" & NumA & "个客户，已领用了" & hasly_all & "个，最多还可领用" & (NumA-hasly_all) & "个客户！"
'If openA2 = 1 Then
					Exit Function
				end if
			else
				If IsAdd = 1 Then addnum = 0
				If (hasly_all - hasly_all_add) + addnum > NumA Then
'If IsAdd = 1 Then addnum = 0
					WatchCustomNumber = "账号最多可以领用" & NumA & "个客户，已领用了" & (hasly_all-hasly_all_add) & "个，最多还可领用" & (NumA-hasly_all + hasly_all_add) & "个客户！"
'If IsAdd = 1 Then addnum = 0
					Exit Function
				end if
			end if
		end if
		If openB1 >= 1 Then
			If openB2 = 1 Then
				If hasly_day + addnum > numB Then
'If openB2 = 1 Then
					WatchCustomNumber = "账号今日最多可以领用" & numB & "个客户，已领用了" & hasly_day & "个，最多还可领用" & (numB-hasly_day) & "个客户！"
'If openB2 = 1 Then
					Exit Function
				end if
			else
				If IsAdd = 1 Then addnum = 0
				If (hasly_day - hasly_day_add) + addnum > numB Then
'If IsAdd = 1 Then addnum = 0
					WatchCustomNumber = "账号今日最多可以领用" & numB & "个客户，已领用了" & (hasly_day-hasly_day_add) & "个，最多还可领用" & (numB-hasly_day + hasly_day_add) & "个客户！"
'If IsAdd = 1 Then addnum = 0
					Exit Function
				end if
			end if
		end if
		WatchCustomNumber = ""
	end function
	sub check_tel_applynum(ByVal gord, byval addnum, ByVal IsAdd)
		message = WatchCustomNumber(gord ,addnum,IsAdd)
		If Len(message)> 0 Then
			showlyEndMsg message
			Exit sub
		end if
	end sub
	Sub salesChangeLog(tord,gord,reason,reasonchildren,f_intro)
		If Len(gord & "") = 0 Then gord = "-1"
'Sub salesChangeLog(tord,gord,reason,reasonchildren,f_intro)
		Dim sql
		sql = " insert into [tel_sales_change_log](tord,sort3,sort,sort1,precateid,newcateid,cateid,date2,date7,reason,reasonchildren,replynum,intro) " &_
		"select ord,sort3,sort,sort1,(case when  '"& reason &"'='1' then 0 else cateid end) as precateid,(case when '"& reason &"'='5' then cateid4 else "& gord &" end) as  newcateid ,'" & session("personzbintel2007") & "' as cateid ,isnull(date2,getdate()) as date2 ,getdate() as date7, '"& reason &"' as reason,'" & reasonchildren &"' as reasonchildren ,(select count(1) from reply where ord2=tel.ord) as replynum,'" & f_intro &"' as intro from tel where ord in (" & tord & ") and (('"& reason &"'<>'1' and isnull(cateid,0)<>"& gord &") or '"& reason &"'='1' ) "
		conn.execute(sql)
	end sub
	Function getOption(HourOrMinute)
		Dim v,vi
		If HourOrMinute="Hour" Then
			For vi=0 To 23
				If vi<10 Then
					v=v & "<option value='0" & vi & "'>0" & vi & "</option>"
				else
					v=v & "<option value='" & vi & "'>" & vi & "</option>"
				end if
			next
		ElseIf HourOrMinute="Minute" Then
			For vi=0 To 55
				If (vi Mod 5)=0 then
					If vi<10 Then
						v=v & "<option value='0" & vi & "'>0" & vi & "</option>"
					else
						v=v & "<option value='" & vi & "'>" & vi & "</option>"
					end if
				end if
			next
		end if
		getOption = v
	end function
	Function isbool(mustcon, strc)
		If InStr(1, "," & mustcon & ",", "," & strc & ",", 1) > 0 Then
			isbool = True
		else
			isbool = False
		end if
	end function
	Function isnuul(boolc, isint, strc)
		Dim ReturnB
		ReturnB = False
		If boolc Then
			If isint > 0 Then
				If strc&"" = "0" Then ReturnB = True
			else
				If Len(strc&"") = 0 Then ReturnB = True
			end if
		end if
		isnuul = ReturnB
	end function
	Function GetFieldID(ByVal name)
		Select Case UCase(Trim(name))
		Case "来源"               : GetFieldID = 6
		Case "区域"               : GetFieldID = 7
		Case "行业"               : GetFieldID = 8
		Case "价值"               : GetFieldID = 9
		Case "网址"               : GetFieldID = 10
		Case "到款"               : GetFieldID = 11
		Case "地址"               : GetFieldID = 12
		Case "邮编"               : GetFieldID = 13
		Case "法人"               : GetFieldID = 14
		Case "注册资本" : GetFieldID = 15
		Case "家庭电话" : GetFieldID = 18
		Case "办公电话" : GetFieldID = 19
		Case "手机"               : GetFieldID = 20
		Case "传真"               : GetFieldID = 21
		Case "电子邮件" : GetFieldID = 22
		Case "QQ"         : GetFieldID = 23
		Case "MSN"                : GetFieldID = 24
		Case "籍贯"               : GetFieldID = 25
		Case "部门"               : GetFieldID = 27
		Case "职务"               : GetFieldID = 28
		Case "联系人"     : GetFieldID = 92
		Case "客户电话" : GetFieldID = 93
		Case "客户传真" : GetFieldID = 94
		Case "客户邮件" : GetFieldID = 95
		Case "已联系"     : GetFieldID = 96
		Case "已项目"     : GetFieldID = 97
		Case "已报价"     : GetFieldID = 98
		Case "已合同"     : GetFieldID = 99
		Case "已收回"     : GetFieldID = 100
		End select
	end function
	Function checkmustcontent(ByVal mustcon,  ByVal mustrole, byval tord)
		checkmustcontent = checkmustcontentBase(mustcon, mustrole, tord, mustcon)
	end function
	Function checkmustcontentBase(ByVal mustcon,  ByVal mustrole, byval tord, ByVal allmustcon)
		Dim Rs, StrR,i,fields,fields1, fid, sql,person_ord
		StrR=""
		Set rs=conn.execute("select top 1 isnull(ly,0),isnull(area,0),isnull(trade,0),isnull(jz,0),len(isnull(url,'')),len(isnull(hk_xz,0)),len(isnull(address,'')),len(isnull(zip,'')),(case when len(isnull(faren,''))>0 or sort2=2 then 1 else 0 end),(case when isnull(zijin,0)>0 or sort2=2 then 1 else 0 end),len(isnull(phone,'')),len(isnull(fax,'')),len(isnull(email,'')) from tel where ord="&tord&"")
		If Not rs.eof Then
			fields=Split("来源,区域,行业,价值,网址,到款,地址,邮编,法人,注册资本,客户电话,客户传真,客户邮件",",")
			For i=0 To ubound(fields)
				fid = GetFieldID(fields(i))
				If isnuul(isbool(mustcon, fid),1,rs(i)) Then
					StrR = StrR & "," & fid
				end if
			next
		end if
		rs.close
		person_ord = ""
		If Len(session("tel_person")&"")>0 And isnumeric(session("tel_person")&"") Then
			person_ord = " and ord ="&session("tel_person")
		end if
		Set rs=conn.execute("select len(isnull(jg,'')),len(isnull(part1,'')),len(isnull(job,'')),len(isnull(phone,'')),len(isnull(phone2,'')),len(isnull(mobile,'')),len(isnull(fax,'')),len(isnull(email,'')),len(isnull(qq,'')),len(isnull(MSN,'')), name,role from person where del<>2 and company="&tord&" "&person_ord)
		checkmustcontentPersons = ""
		Dim itemstr, itemv
		While rs.eof = False
			itemstr = ""
			If isbool(mustcon,GetFieldID("联系人")) Or isbool(mustrole, rs("role").value) then
				fields1=Split("籍贯,部门,职务,办公电话,家庭电话,手机,传真,电子邮件,QQ,MSN",",")
				For i=0 To ubound(fields1)
					itemv = GetFieldID(fields1(i))
					If isnuul(isbool(mustcon,itemv),1, rs(i)) Then
						itemstr = itemstr & "," & itemv
						If InStr(1, "," & strR & "," , "," & itemv & ",", 1) = 0 Then
							strR = strR & "," & itemv
						end if
						If Len(itemstr) > 0 Then
							itemstr = itemstr & ","
						end if
						itemstr = itemstr & itemv
					end if
				next
				If Len(checkmustcontentPersons) > 0 Then
					checkmustcontentPersons = checkmustcontentPersons & "|"
				end if
				checkmustcontentPersons = checkmustcontentPersons & itemstr
			end if
			rs.movenext
		wend
		rs.close
		If isbool(mustcon, GetFieldID("联系人")) Then
			If conn.execute("select 1 from person a where del<>2 and company=" & tord&" "&person_ord).eof Then
				strR = strR & "," & GetFieldID("联系人")
			end if
		end if
		If isbool(mustcon, GetFieldID("已联系")) Then
			Dim resultok
			resultok = True
			If conn.execute("select top 1 1 from reply a inner join tel b on a.ord=b.ord and a.cateid=b.cateid and a.date7 > b.date2 and a.del=1 and a.ord =" & tord).eof=True Then
				resultok =  false
				strR = strR & "," & GetFieldID("已联系")
			end if
			If resultok And Len(mustrole)>0 Then
				arrRole=Split(mustrole,",")
				For i=0 To ubound(arrRole)
					sql = "select 1 from reply a inner join person b on a.del=1 and a.sort1=8 and a.ord2=b.ord " &_
					" and b.del<>2 and b.role='"&arrrole(i)&"' and b.company="& tord &" "&Replace(person_ord,"ord","b.ord") &_
					" and b.company=a.ord inner join tel c on a.ord=c.ord and a.date7 > c.date2"
					If conn.execute(sql).eof=True Then
						strR = strR & "," & GetFieldID("已联系")
						resultok = false
						Exit For
					end if
				next
			end if
			If resultok then
				If isbool(allmustcon, GetFieldID("联系人")) Then
					sql = "select 1 from person a inner join tel c on a.company=c.ord and a.del<>2 and c.ord=" & tord &" "&Replace(person_ord,"ord","a.ord") &_
					" left join reply b on a.ord=b.ord2 and b.sort1=8 and b.del<>2 and b.date7>c.date2 " &_
					" where b.ord is null"
					If conn.execute(sql).eof = false Then
						strR = strR & "," & GetFieldID("已联系")
						resultok = false
					end if
				end if
			end if
		end if
		If isbool(mustcon, GetFieldID("已项目")) Then
			sql = "select top 1 1 from chance where isnull(sp,0)=0 and cateid=(select top 1 cateid from tel where ord="&tord&") and del=1 and charindex('," & tord & ",',','+company+',')>0"
'If isbool(mustcon, GetFieldID("已项目")) Then
			If conn.execute(sql).eof= True Then
				strR = strR & "," & GetFieldID("已项目")
			end if
		end if
		If isbool(mustcon, GetFieldID("已报价")) Then
			sql = "select top 1 1 from price where del=1 and isnull(status,-1) in (-1,1) and cateid=(select top 1 cateid from tel where ord="&tord&") and company=" & tord
'If isbool(mustcon, GetFieldID("已报价")) Then
			If conn.execute(sql).eof=True Then
				strR = strR & "," & GetFieldID("已报价")
			end if
		end if
		If isbool(mustcon, GetFieldID("已合同")) Then
			sql = "select top 1 1 from contract where isnull(sp,0)=0 and cateid=(select top 1 cateid from tel where ord="&tord&") and del=1 and company=" & tord
			If conn.execute(sql).eof=True Then
				strR = strR & "," & GetFieldID("已合同")
			end if
		end if
		If isbool(mustcon, GetFieldID("已收回")) Then
			sql = "select top 1 1 from tousu where del=1 and cateid=(select top 1 cateid from tel where ord="&tord&") and company=" & tord
			If conn.execute(sql).eof=True then
				strR = strR & "," & GetFieldID("已收回")
			end if
		end if
		checkmustcontentBase=StrR
	end function
	Function checkkz_zdy(kzmustcon,tord)
		Dim v ,i, strR
		strR = ""
		v=kzmustcon
		v=Replace(v," ","")
		If v<>"" Then
			v=Split(v,",")
			For i=0 To ubound(v)
				If isnumeric(v(i)) Then
					If conn.execute("select top 1 1 from ERP_CustomValues where FieldsId=" & v(i) & " and OrderId=" & tord & " and isnull(Fvalue,'')<>''").eof=True Then strR = strR & "," & v(i)
				end if
			next
		end if
		checkkz_zdy=strR
	end function
	Function checkzdy(zdymustcon,tord)
		Dim v, i, strR
		strR = ""
		v=zdymustcon
		v=Replace(v," ","")
		If v<>"" Then
			v=Split(v,",")
			For i=0 To ubound(v)
				If isnumeric(v(i)) Then
					If conn.execute("select top 1 1 from tel where isnull(zdy" & v(i) & ",'')<>'' and ord=" & tord ).eof=True Then strR = strR & "," & v(i)
				end if
			next
		end if
		checkzdy=strR
	end function
	Function checkrole(mustrole,mustcon,tord)
		Dim strR,v,i,n
		v=mustrole
		If Len(v&"")>0 Then
			v=Split(v,",")
			For i=0 To ubound(v)
				n=Trim(v(i))
				If Len(n&"")=0 Or isnumeric(n)=False Then n=0
				If isbool(mustcon,96) Then
					If conn.execute("select top 1 1 from person where isnull(role,0)>0 and role=" & n & " and del<>2 and company=" & tord &" and ord in(select ord2 from reply where sort1=8 and del=1)").eof=True Then strR = strR & "," & n
				else
					If conn.execute("select top 1 1 from person where isnull(role,0)>0 and role=" & n & " and del<>2 and company=" & tord ).eof=True Then strR = strR & "," & n
				end if
			next
		end if
		checkrole=strR
	end function
	Function IntToStr(intType,mustConStr,mustRoleStr,mustZdyStr,mustKzStr)
		Dim intlist,nameList,nameList1,nameList2,rss
		intlist=""
		nameList=""
		If intType=1 Then
			If Len(Trim(mustConStr))>0 Then
				intlist=mustConStr
				If Left(intlist,1)="," Then intlist=Right(mustConStr,Len(mustConStr)-1)
'intlist=mustConStr
				Set rss=conn.execute("select gate1,(case when isnull(name,'')='' then oldname else name end ) as name,isnull(show,0) as show,point,enter,format from setfields where gate1 in ( 6,7,8,9,10,11,12,13,14,15,25,27,28,18,19,20,21,23,24,22) order by gate1")
				Do While Not rss.eof
					If isbool(mustConStr,rss(0)) Then nameList2=nameList2 & "【"&rss(1)&"】"
					If (isbool(mustConStr,93) And rss(0)=19) Or (isbool(mustConStr,94) And rss(0)=21) Or (isbool(mustConStr,95) And rss(0)=22) Then nameList1=nameList1 & "【"&rss(1)&"（客户）】"
					rss.movenext
				Loop
				rss.close : Set rss=Nothing
				nameList=nameList & nameList1
				If isbool(mustConStr,92) Then nameList=nameList & "【联系人】"
				nameList=nameList & nameList2
			end if
			If Len(Trim(mustRoleStr))>0 Then nameList=nameList & getmustContent("select ord,sort1 from sort9 where 1=1",1,"ord","sort1",mustRoleStr)
			If Len(Trim(mustZdyStr))>0 Then nameList=nameList & getmustContent("select id,title,name,sort,gl from zdy where sort1=1 and set_open=1 order by gate1 asc",2,"id","title",mustZdyStr)
			If Len(Trim(mustKzStr))>0 Then nameList=nameList & getmustContent("select id,fname from ERP_CustomFields where TName=1 and IsUsing=1 and del=1 order by FOrder asc",3,"id","fname",mustKzStr)
			If Len(Trim(mustConStr))>0 Then
				If isbool(mustConStr,96) Then nameList=nameList & "【已联系】"
				If isbool(mustConStr,97) Then nameList=nameList & "【建立项目】"
				If isbool(mustConStr,98) Then nameList=nameList & "【已报价】"
				If isbool(mustConStr,99) Then nameList=nameList & "【已成交】"
				If isbool(mustConStr,100) Then nameList=nameList & "【关联售后】"
			end if
		end if
		If nameList<>"" Then nameList="\n必填项有：" & nameList
		IntToStr=nameList
	end function
	Public Function getmustContent(sql,keyid,ids,names,model_id)
		Dim f_rs,s
		Set f_rs=conn.execute(sql)
		Do While Not f_rs.eof
			If isbool(model_id,f_rs(ids)) then
				s = s & "【" & f_rs(names) & "】"
			end if
			f_rs.movenext
		Loop
		f_rs.close : Set f_rs=nothing
		getmustContent=s
	end function
	Function canGetCompany(tel_ord,neednum, canly, needsort, intro , needGetApply ,condition,limitsort1,limitsort2,limitsort3,limitsort4,limitsort5,limitsort6,limitsort7,limitsort8,limitsort9, needGetTel, cateid4,sort,sort1,ly,jz,trade,area,zdy5,zdy6, needzdy, ishaszdy5, ishaszdy6)
		Dim islingy,telrs,rs1 , rss ,rss1
		islingy=True
		If Len(tel_ord&"") = 0 Then
			canGetCompany = islingy
			Exit Function
		end if
		If needGetTel = True Then
			set telrs=conn.execute("select * from tel where ord="& tel_ord &" ")
			If telrs.eof = False Then
				cateid4 = telrs("cateid4")
				sort=telrs("sort")
				sort1=telrs("sort1")
				ly=telrs("ly")
				jz=telrs("jz")
				trade=telrs("trade")
				area=telrs("area")
				zdy5=telrs("zdy5")
				zdy6=telrs("zdy6")
			end if
			telrs.close
		end if
		If cateid4&"" = "" Then cateid4 = 0
		If neednum = True Then
			If Len(WatchCustomNumber(member2, 1, 0))>0 Then islingy=False
		else
			islingy = canly
		end if
		If islingy = False Then
			canGetCompany = islingy
			Exit Function
		end if
		If needsort = True Then
			intro = 0
			set rs1=conn.execute("select isnull(intro,0) as intro from setopen where sort1=39 and isnull(intro,0)>0")
			If rs1.eof = False Then
				intro=rs1("intro")
			end if
			rs1.close
		end if
		Dim lysql, qysql
		If intro>0 Then
			If intro=2 Then
				lysql=" and cateid=0"
				qysql=" and ord =0 "
			else
				lysql=" and cateid="& cateid4 &" "
				qysql=" and ord = " & cateid4 &" "
			end if
			If needGetApply Then
				Set rss=conn.execute("select * from tel_apply where 1=1 " & lysql )
				If Not rss.eof Then
					condition=rss("condition")
					limitsort1=rss("limitsort1")
					limitsort2=rss("limitsort2")
					limitsort3=rss("limitsort3")
					limitsort4=rss("limitsort4")
					limitsort5=rss("limitsort5")
					limitsort6=rss("limitsort6")
					If limitsort6&""="" Then limitsort6 = 0
					limitsort7=rss("limitsort7")
					limitsort8=rss("limitsort8")
					limitsort9=rss("limitsort9")
				else
					canGetCompany = islingy
					Exit Function
				end if
				rss.close
			end if
			Dim isfl : isfl=False
			If limitsort1&""<>"" And Len(sort&"")>0 And sort&""<>"0" Then
				If InStr(","&Replace(limitsort1," ","")&",",","&sort&",")>0 Then isfl=True
			ElseIf condition=1 Then
				isfl=True
			ElseIf Len(limitsort1&"")>0 and (Len(sort&"")=0 Or sort&""="0") Then
				isfl=True
			end if
			Dim isgj : isgj=False
			If limitsort2&""<>"" And Len(sort1&"")>0 And sort1&""<>"0" Then
				If InStr(","&Replace(limitsort2," ","")&",",","&sort1&",")>0 Then isgj=True
			ElseIf condition=1 Then
				isgj=True
			ElseIf Len(limitsort2&"")>0 and (Len(sort1&"")=0 Or sort1&""="0") Then
				isgj=True
			end if
			Dim isly : isly=False
			If limitsort3&""<>"" And Len(ly&"")>0 And ly&""<>"0" Then
				If InStr(","&Replace(limitsort3," ","")&",",","&ly&",")>0 Then isly=True
			ElseIf condition=1 Then
				isly=True
			ElseIf Len(limitsort3&"")>0 and (Len(ly&"")=0 Or ly&""="0") Then
				isly=True
			end if
			Dim isjz : isjz=False
			If limitsort4&""<>"" And jz&""<>"0" And Len(jz&"")>0 Then
				If InStr(","&Replace(limitsort4," ","")&",",","&jz&",")>0 Then isjz=True
			ElseIf condition=1 Then
				isjz=True
			ElseIf Len(limitsort4&"")>0 and (Len(jz&"")=0 Or jz&""="0") Then
				isjz=True
			end if
			Dim ishy : ishy=False
			If limitsort5&""<>"" And Len(trade&"")>0 And trade&""<>"0"  Then
				If InStr(","&Replace(limitsort5," ","")&",",","&trade&",")>0 Then ishy=True
			ElseIf condition=1 Then
				ishy=True
			ElseIf Len(limitsort5&"")>0 and (Len(trade&"")>0 Or trade&""="0") Then
				ishy=True
			end if
			Dim isqy : isqy=False
			If limitsort6=1 And Len(area&"")>0 And area&""<>"0" Then
				If conn.execute("select count(id) from tel_area where sort=2 and area="& area &" " & qysql)(0)>0 Then isqy=True
			ElseIf condition=1 Then
				isqy=True
			ElseIf limitsort6=1 and (Len(area&"")=0 Or area&""="0") Then
				isqy=True
			end if
			If needzdy = True Then
				ishaszdy5 = (conn.execute("select 1 from zdy where sort1=1 and set_open=1 and name='zdy5' ").eof = false)
				ishaszdy6 = (conn.execute("select 1 from zdy where sort1=1 and set_open=1 and name='zdy6' ").eof = false)
			end if
			Dim iszdy5 : iszdy5=False
			If ishaszdy5 Then
				If limitsort7&""<>"" And Len(zdy5&"")>0 And zdy5&""<>"0" Then
					If InStr(","&Replace(limitsort7," ","")&",",","&zdy5&",")>0 Then iszdy5=True
				ElseIf condition=1 Then
					iszdy5=True
				ElseIf Len(limitsort7&"")>0 and (Len(zdy5&"")=0 Or zdy5&""="0") Then
					iszdy5=True
				end if
			ElseIf condition=1 Then
				iszdy5=True
			end if
			Dim iszdy6 : iszdy6=False
			If ishaszdy6 Then
				If limitsort8&""<>"" And Len(zdy6&"")>0 And zdy6&""<>"0" Then
					If InStr(","&Replace(limitsort8," ","")&",",","&zdy6&",")>0 Then iszdy6=True
				ElseIf condition=1 Then
					iszdy6=True
				ElseIf Len(limitsort8&"")>0 And (Len(zdy6&"")=0 Or zdy6&""="0") Then
					iszdy6=True
				end if
			ElseIf condition=1 Then
				iszdy6=True
			end if
			Dim iskz : iskz=False
			If limitsort9&""<>"" Then
				Dim kz_zdyfields()
				Dim kz_zdyValue()
				reDim kz_zdyfields(0)
				reDim kz_zdyValue(0)
				Dim j : j=0
				Dim iskz_zdy : iskz_zdy=False
				Set rss1=conn.execute("select id,FValue from ERP_CustomFields f left join (select FieldsID,o.id as FValue from ERP_CustomValues v inner join ERP_CustomOptions o on v.FValue=o.cvalue and o.del=1 where v.OrderID='"& tel_ord &"') a on a.FieldsID = f.id where TName=1 and FType=7 and IsUsing=1 and del=1 order by FOrder asc ")
				While Not rss1.eof
					iskz_zdy=True
					redim Preserve kz_zdyfields(j)
					redim Preserve kz_zdyValue(j)
					kz_zdyfields(j)=rss1("id")
					kz_zdyValue(j)=Trim(rss1("FValue"))
					j=j+1
'kz_zdyValue(j)=Trim(rss1("FValue"))
					rss1.movenext
				wend
				rss1.close
				If iskz_zdy Then
					Dim r , strlm,strlm2 ,strlm_one ,kz_zdy ,kz_id ,kz_str
					strlm=Split(limitsort9,"||")
					strlm2=Split(limitsort9,"||")
					For r=0 To ubound(strlm)
						strlm_one=strlm(r)
						If strlm_one<>"" Then
							kz_zdy=Split(strlm_one,":")
							strlm2(r)=kz_zdy(0)
							strlm(r)=kz_zdy(1)
						end if
					next
					kz_id=Join(strlm2,",")
					kz_str=Join(strlm,",")
					For r=0 To ubound(kz_zdyfields)
						If InStr(","&Replace(kz_id," ",""),","&kz_zdyfields(r)&",")>0 Then
							If InStr(","&Replace(kz_str," ",""),","&kz_zdyValue(r)&",")>0 Or (Len(kz_zdyValue(r))=0 Or kz_zdyValue(r)&""="0") Then
								iskz=True
								If condition=0 Then Exit For
							else
								iskz=False
								If condition=1 Then Exit For
							end if
						end if
					next
				ElseIf condition=1 Then
					iskz=True
				end if
			ElseIf condition=1 Then
				iskz=True
			end if
			If len(limitsort1&"")=0 and len(limitsort2&"")=0 and len(limitsort3&"")=0 and len(limitsort4&"")=0 and len(limitsort5&"")=0 and (len(limitsort6&"")=0 or limitsort6="0") and len(limitsort7&"")=0 and len(limitsort8&"")=0 and len(limitsort9&"")=0 Then
			else
				If condition=1 Then
					If isfl And isgj And isly And isjz And ishy And isqy And iszdy5 And iszdy6 And iskz Then
					else
						islingy=False
					end if
				else
					If (isfl and isgj) Or isly Or isjz Or ishy Or isqy Or iszdy5 Or iszdy6 Or iskz Then
					else
						islingy=False
					end if
				end if
			end if
		end if
		canGetCompany = islingy
	end function
	Function ismobileApp()
		ismobileApp = InStr(Trim(Request.ServerVariables("CONTENT_TYPE")), "application/zsml")>0 Or InStr(Trim(Request.ServerVariables("CONTENT_TYPE")) , "application/json")>0 Or Request.QueryString("__mobile2_debug") = "1"
	end function
	Function WatchCustomExtent(byval uid ,ByVal ID)
		Dim r : r = true
		Dim order1 : order1 = 0
		Dim rs
		Dim resort : resort = ""
		Dim resort1: resort1= ""
		Dim rely : rely =""
		Dim rejz: rejz = ""
		Dim retrade: retrade =""
		Dim rearea: rearea =""
		Dim rezdy5: rezdy5 = ""
		Dim rezdy6: rezdy6 = ""
		Dim rekz : rekz = ""
		Dim telarea : telarea = ""
		if ID> 0 Then
			Set rs = conn.execute("select a.*, b.sex,b.name as person,b.part1,b.job,b.mobile,b.QQ,b.email,b.phone2,b.msn from tel a left join person b on a.person=b.ord where a.ord=" & id )
			If rs.eof = False Then
				order1=rs("order1").value
				resort=rs("sort")
				resort1=rs("sort1")
				rely=rs("ly")
				rejz=rs("jz")
				retrade=rs("trade")
				rearea=rs("area")
				rezdy5=rs("zdy5")
				rezdy6=rs("zdy6")
				telarea = rs("area")
			end if
			rs.close
			Set rs = conn.execute("select id,CValue from ERP_CustomOptions where CFID in (select id from ERP_CustomFields where TName=1 and IsUsing=1 and del=1 and FType=7) and  CValue=(select top 1 FValue from ERP_CustomValues where  FieldsID=ERP_CustomOptions.CFID and OrderID="& id & " )")
			While rs.eof=False
				If Len(rekz)>0 Then rekz = rekz & ","
				rekz = rekz & rs("id")
				rs.movenext
			wend
			rs.close
		end if
		If order1<>1 Then
			Dim intro : intro = 0
			Set rs = conn.execute("select isnull(intro,0) as intro from setopen where sort1=39 and isnull(intro,0)>0")
			If rs.eof = False Then
				intro = rs("intro").value
			else
				WatchCustomExtent = True
				Exit Function
			end if
			rs.close
			Dim lysql: lySql = " and cateid=" & uid &  " and isnull(del,1)=1 "
			Dim qysql: qysql = " and ord=" & uid
			if intro = 2 Then
				lySql = " and cateid=0"
				qysql = " and ord=0 "
			end if
			Dim condition :condition = 0
			Set rs = conn.execute("select * from tel_apply where 1=1 " & lySql)
			If rs.eof = True Then
				WatchCustomExtent = True
				Exit Function
			else
				condition = rs("condition").value
				Dim sort , sort1 ,ly,jz,trade ,area ,zdy5 , zdy6
				If ismobileApp = True Then
					sort = Split(app.mobile("sort1"),",")(0)
					sort1 = Split(app.mobile("sort1"),",")(1)
					ly = app.mobile("ly")
					jz = app.mobile("jz")
					trade = app.mobile("trade")
					area = app.mobile("area")
					zdy5 = app.mobile("zdy5")
					zdy6 = app.mobile("zdy6")
				else
					sort = request("sort")
					sort1 = request("sort1")
					ly = request("ly")
					jz = request("jz")
					trade = request("trade")
					area =  request("area")
					zdy5 = request("zdy5")
					zdy6 = request("zdy6")
				end if
				Dim fields : Set fields = GetFields(1)
				Dim isfl : isfl = tel_canLy(condition, rs("limitsort1").value & "", sort, resort , fields.GetItemByDBname("sort").show)
				Dim isgj : isgj = tel_canLy(condition, rs("limitsort2").value & "", sort1, resort1, fields.GetItemByDBname("sort1").show)
				Dim isly : isly = tel_canLy(condition, rs("limitsort3").value & "", ly, rely, fields.GetItemByDBname("ly").show)
				Dim isjz : isjz = tel_canLy(condition, rs("limitsort4").value & "", jz, rejz, fields.GetItemByDBname("jz").show)
				Dim ishy : ishy = tel_canLy(condition, rs("limitsort5").value & "", trade, retrade, fields.GetItemByDBname("trade").show)
				Dim isqy : isqy = false
				if Len(area&"") = 0 then area = telarea
				if rs("limitsort6")= 1 and Len(area)>0 Then
					isqy = (conn.execute("select top 1 id from tel_area where sort=2 and area=" & area & qysql &"").eof =False )
					if area= rearea Then isqy = true
				elseif rs("limitsort6") = 0 and Len(area)= 0 And fields.GetItemByDBname("area").show=True Then
					isqy = true
				ElseIf condition=1 Then
					isqy = true
				end if
				Dim zdyfields : Set zdyfields = GetZdyFields(1)
				Dim iszdy5 : iszdy5 = tel_canLy(condition, rs("limitsort7").value & "", zdy5, rezdy5, zdyfields.GetItemByDBname("zdy5").show )
				Dim iszdy6 : iszdy6 = tel_canLy(condition, rs("limitsort8").value & "", zdy6, rezdy6, zdyfields.GetItemByDBname("zdy6").show )
				Dim limitsort9 : limitsort9 = rs("limitsort9").value & ""
				Dim iskz : iskz = ExtendedLy(condition, limitsort9, rekz)
				if Len(rs("limitsort1")&"")>0 Or Len(rs("limitsort2")&"")>0 Or Len(rs("limitsort3")&"")>0 Or Len(rs("limitsort4")&"")>0 Or Len(rs("limitsort5")&"")>0 Or rs("limitsort6")=1 Or Len(rs("limitsort7")&"")>0 Or Len(rs("limitsort8")&"")>0 Or Len(limitsort9&"")>0 Then
					if condition = 1 Then
						if isfl = false Or isgj = false or isly = false or isjz = false or ishy = false or isqy = false or iszdy5 = false or iszdy6 = false or iskz = False Then r = false
					else
						if (isfl and isgj) = false and isly = false and isjz = false and ishy = false and isqy = false and iszdy5 = false and iszdy6 = False and iskz = False Then r = false
					end if
				end if
			end if
			rs.close
		end if
		WatchCustomExtent = r
	end function
	Function tel_canLy(ByVal typeCondition ,byval limit ,byval  newValue , byval oldValue , byval show)
		Dim r : r = false
		limit = Replace(limit , " ", "")
		if Len(limit) > 0 And Len(newValue) > 0 Then
			if Len(oldValue)> 0 Then  limit = limit & "," & oldValue
			if instr("," & limit & "," , "," & newValue & ",") > 0 Then  r = true
		elseif  Len(limit) > 0 and Len(newValue)= 0 and show Then
			r = true
		elseif typeCondition = 1 Then
			r = true
		end if
		tel_canLy = r
	end function
	Function ExtendedLy(ByVal typeCondition, Byref limit ,ByVal oldValue)
		Dim i
		Dim r : r = False
		If Len(limit)>0 Then
			Dim kz_id : kz_id = ""
			Dim kz_str : kz_str = ""
			Dim strlm : strlm = Split(limit ,"or")
			For i = 0 To ubound(strlm)
				if Len(strlm(i))> 0 Then
					if len(kz_id)> 0 Then kz_id = kz_id & ","
					if len(kz_str)> 0 Then kz_str = kz_str & ","
					kz_id = kz_id & Split(strlm(i) ,":")(0)
					kz_str = kz_str & Split(strlm(i) ,":")(1)
				end if
				if Len(oldValue)> 0 Then kz_str = kz_str & "," & oldValue
			next
			Dim extrafields : Set extrafields = GetExtraFields(1)
			Dim OID , hasKz , field
			hasKz = False
			For i = 0 To extrafields.count-1
'hasKz = False
				Set field = extrafields.item(i)
				If field.show = True And field.sorttype = 7 Then
					If ismobileApp = True Then
						OID = app.mobile("meju_" & field.Key )
					else
						OID = request("meju_" & field.Key )
					end if
					if instr("," & kz_id & ",","," & field.Key & ",") > 0 Then
						hasKz = True
						if instr("," & kz_str & ",","," & OID & ",") > 0 Or Len(OID)=0 Then
							r = true
							if typeCondition = 0 Then Exit For
						else
							r = false
							if typeCondition = 1 Then Exit For
						end if
					end if
				end if
			next
			If hasKz = False Then
				limit = ""
				If typeCondition = 1 Then r = True
			end if
		elseif typeCondition = 1 Then
			r = true
		end if
		ExtendedLy= r
	end function
	Function CustomReviewWatchs(id)
		Dim r : r = False
		Dim rs , rss
		Dim fields : Set fields = GetFields(1)
		if id = 0 or ( id > 0 And conn.execute("select ord from tel where ord='" & id & "' and (datediff(d,getdate(),date1)>=0 or isnull(sp,0)<>0) ").eof= False ) Then
			Dim condition :condition = 0
			Set rs= conn.execute("select * from tel_review ")
			If rs.eof = False Then
				condition = rs("condition").value
				Dim sort , sort1 ,ly,jz,trade ,area ,zdy5 , zdy6
				If ismobileApp = True Then
					sort = Split(app.mobile("sort1"),",")(0)
					sort1 = Split(app.mobile("sort1"),",")(1)
					ly = app.mobile("ly")
					jz = app.mobile("jz")
					trade = app.mobile("trade")
					area = app.mobile("area")
					zdy5 = app.mobile("zdy5")
					zdy6 = app.mobile("zdy6")
				else
					sort = request("sort")
					sort1 = request("sort1")
					ly = request("ly")
					jz = request("jz")
					trade = request("trade")
					area =  request("area")
					zdy5 = request("zdy5")
					zdy6 = request("zdy6")
				end if
				Dim isfl : isfl = hasReview(condition, rs("limitsort1")&"", sort, fields.GetItemByDBname("sort").show)
				Dim isgj : isgj = hasReview(condition, rs("limitsort2")&"", sort1, fields.GetItemByDBname("sort1").show)
				Dim isly : isly = hasReview(condition, rs("limitsort3")&"", ly, fields.GetItemByDBname("ly").show)
				Dim isjz : isjz = hasReview(condition, rs("limitsort4")&"", jz, fields.GetItemByDBname("jz").show)
				Dim ishy : ishy = hasReview(condition, rs("limitsort5")&"", trade, fields.GetItemByDBname("trade").show)
				Dim isqy : isqy = false
				if rs("limitsort6")= 1 Then
					if Len(area)>0 Then
						isqy = (conn.execute("select top 1 id from tel_area where sort=1 and area=" & area &"").eof =False )
					elseif condition= 1 And fields.GetItemByDBname("area").show=False Then
						isqy = True
					end if
				Elseif condition= 1 Then
					isqy = True
				end if
				Dim zdyfields : Set zdyfields = GetZdyFields(1)
				Dim iszdy5 : iszdy5 = hasReview(condition, rs("limitsort7")&"", zdy5,  zdyfields.GetItemByDBname("zdy5").show )
				Dim iszdy6 : iszdy6 = hasReview(condition, rs("limitsort8")&"", zdy6, zdyfields.GetItemByDBname("zdy6").show )
				Dim limitsort9 : limitsort9 = rs("limitsort9")&""
				Dim iskz : iskz = ExtendedReview(condition, limitsort9)
				if Len(rs("limitsort1")&"")>0 Or Len(rs("limitsort2")&"")>0 Or Len(rs("limitsort3")&"")>0 Or Len(rs("limitsort4")&"")>0 Or Len(rs("limitsort5")&"")>0 Or rs("limitsort6")=1 Or Len(rs("limitsort7")&"")>0 Or Len(rs("limitsort8")&"")>0 Or Len(limitsort9&"")>0 Then
					if condition = 1 Then
						if isfl and isgj and isly and isjz and ishy and isqy and iszdy5 and iszdy6 and iskz Then  r = true
					else
						if (isfl and isgj) or isly or isjz or ishy or isqy or iszdy5 or iszdy6 or iskz Then  r = true
					end if
				end if
			end if
		end if
		CustomReviewWatchs = r
	end function
	Function hasReview(ByVal condition , ByVal limit , ByVal newValue ,ByVal show)
		Dim r : r = false
		limit = Replace(limit, " ", "")
		if Len(limit) > 0 Then
			if Len(newValue) > 0 Then
				If instr("," & limit & "," , "," & newValue & ",") > 0  Then  r = true
			elseif show=False and condition = 1 Then
				r = true
			end if
		elseif condition=1 Then
			r = True
		end if
		hasReview = r
	end function
	Function ExtendedReview(ByVal typeCondition, Byref limit)
		Dim r ,i ,field
		r = False
		If Len(limit)>0 Then
			Dim kz_id : kz_id = ""
			Dim kz_str : kz_str = ""
			Dim strlm : strlm = Split(limit ,"or")
			For i = 0 To ubound(strlm)
				if Len(strlm(i))> 0 Then
					if len(kz_id)> 0 Then kz_id = kz_id & ","
					if len(kz_str)> 0 Then kz_str = kz_str & ","
					kz_id = kz_id & Split(strlm(i) ,":")(0)
					kz_str = kz_str & Split(strlm(i) ,":")(1)
				end if
			next
			Dim extrafields : Set extrafields = GetExtraFields(1)
			Dim OID , hasKz
			hasKz = False
			For i = 0 To extrafields.count-1
'hasKz = False
				Set field = extrafields.item(i)
				If field.show = True And field.sorttype = 7 Then
					If ismobileApp = True Then
						OID = app.mobile("meju_" & field.Key )
					else
						OID = request("meju_" & field.Key )
					end if
					if instr("," & kz_id & ",","," & field.Key & ",") > 0 Then
						hasKz = True
						if instr("," & kz_str & ",","," & OID & ",") > 0 and Len(OID)>0 Then
							r = true
							if typeCondition = 0 Then Exit For
						else
							r = false
							if typeCondition = 1 Then Exit For
						end if
					end if
				end if
			next
			If hasKz = False Then
				limit = ""
				If typeCondition = 1 Then r = True
			end if
		elseif typeCondition = 1 Then
			r = true
		end if
		ExtendedReview = r
	end function
	Public pub_cf,KZ_LIMITID
	Function getExtended(TName,ord)
		Call showExtended(TName,ord,3,1,1)
	end function
	function ShowExtendedByProductGroup(byval TName,byval ord,byval columns, byval col1, byval col2 ,byval isIntro ,byval bzstr ,byval tsstr ,byval oldZdySort ,byval readonly,byval zdygroupid)
		if zdygroupid = 0 then zdygroupid = -1
		dim rss
		Response.write "" & vbcrlf & "       <tr class=""top accordion"" id=""cpBasezdygroup"">" & vbcrlf & "      <td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "           <div  class=""accordion-bar-tit"" style=""padding-top:6px;"">" & vbcrlf & "                   自定义字段 <span class=""accordion-arrow-down""></span>" & vbcrlf & "             </div>" &vbcrlf & "          <div onclick=""app.stopDomEvent();return false"" style=""float:left;padding:5px"">" & vbcrlf & "              &nbsp;" & vbcrlf & "          "
		if readonly then
			dim wsql : wsql = " and  ord="  & clng(zdygroupid)
			if zdygroupid = -1 then wsql=" and tagdata='1' "
'dim wsql : wsql = " and  ord="  & clng(zdygroupid)
			set rss = conn.execute("select ord, sort1, tagdata from sortonehy where gate2=63 and ord=" & zdygroupid)
			if rss.eof = false then
				Response.write rss("sort1").value
			end if
			rss.close
		else
			Response.write "" & vbcrlf & "              <select name=""zdygroupid"" style=""min-width:100px"" onchange=""refreshProductGroupArea("
			rss.close
			Response.write ord
			Response.write ", this)"">" & vbcrlf & "                  "
			set rss = conn.execute("select ord, (case tagdata when '1' then '' else sort1 end) as sort1, tagdata from sortonehy where gate2=63 order by gate1 desc")
			while rss.eof = false
				tagdata = rss("tagdata").value
				sortord =rss("ord").value
				if tagdata = "1" then sortord = 0
				if zdygroupid = sortord then
					Response.write "<option value='" & sortord & "' selected>" & rss("sort1").value & "</option>"
				else
					Response.write "<option value='" & sortord & "'>" & rss("sort1").value & "</option>"
				end if
				rss.movenext
			wend
			rss.close
			Response.write "" & vbcrlf & "              </select>" & vbcrlf & "               <script>" & vbcrlf & "                        function refreshProductGroupArea(billord,  sbox ){" & vbcrlf & "                              var  x = new XMLHttpRequest();" & vbcrlf & "                          x.open(""Get"", window.sysCurrPath + ""inc/GetExtended.ProductGroup.asp?t="" + (new Date()).getTime() + ""&billord="" + billord + ""&groupid="" + sbox.value,  false)" & vbcrlf & "                          x.send();" & vbcrlf & "                               var html = x.responseText;" & vbcrlf & "                              x = null;" & vbcrlf & "                               var myrow = $(""#cpBasezdygroup"");" & vbcrlf & "                         var currgprow = $(""tr.zdyrowgroup1"");" & vbcrlf & "                             currgprow.remove(); "& vbcrlf & "                               if(html.length>0 && html.indexOf(""<tr"")>=0) " & vbcrlf & "                              {" & vbcrlf & "                                               myrow.after(html)" & vbcrlf & "                               }" & vbcrlf & "                               if(window.BillExtSN){" & vbcrlf & "                                   window.BillExtSN.BindKeys = undefined;" & vbcrlf & "                                  jQuery(""input[type=text]"").unbind(""blur"", window.BillExtSN.Refresh).bind(""blur"", window.BillExtSN.Refresh);" & vbcrlf & "                                       jQuery(""input[type=checkbox]"").unbind(""click"", window.BillExtSN.Refresh).bind(""click"", window.BillExtSN.Refresh);" & vbcrlf & "                                     jQuery(""input[type=radio]"").unbind(""click"", window.BillExtSN.Refresh).bind(""click"", window.BillExtSN.Refresh)" & vbcrlf & "                                   jQuery(""select"").unbind(""change"", window.BillExtSN.Refresh).bind(""change"", window.BillExtSN.Refresh);" & vbcrlf & "                                 jQuery(""textarea"").unbind(""blur"", window.BillExtSN.Refresh).bind(""blur"", window.BillExtSN.Refresh);" & vbcrlf &"                                  var data = [];" & vbcrlf & "                                  var CatchFields = [];" & vbcrlf & "                                   var frm = document.getElementsByTagName(""form"")[0];" & vbcrlf & "                                       if (!frm) { return; }" & vbcrlf & "                                   var boxs = jQuery(frm).serializeArray();" & vbcrlf & "                                        for (var i = boxs.length - 1; i >= 0; i--) {" & vbcrlf & "                                           if (i > 0 && boxs[i].name == boxs[i - 1].name) {" & vbcrlf & "                                                        boxs[i - 1].value = boxs[i - 1].value + "","" + boxs[i].value;" & vbcrlf & "                                                      boxs[i].name = """";" & vbcrlf & "                                                } else {" & vbcrlf & "                                                        var n = boxs[i].name;" & vbcrlf & "                                                   var box = document.getElementsByName(n)[0];" & vbcrlf & "                                                        if (box.tagName == ""SELECT"") {" & vbcrlf & "                                                            boxs.push({ name: boxs[i].name + ""_selectvalue"", value: (boxs[i].value + """") });" & vbcrlf & "                                                            boxs[i].value = box.options[box.options.selectedIndex].text;" & vbcrlf & "                                                    }" & vbcrlf & "               }" & vbcrlf & "                                       }" & vbcrlf & "                                       for (var i = 0; i < boxs.length; i++) {" & vbcrlf & "                                         var ibox = boxs[i];" & vbcrlf & "                                             var n = ibox.name;" & vbcrlf & "                                              if (n) {" & vbcrlf & "                                                        CatchFields.push(n);" & vbcrlf & "                                                    if (ibox.value.length < 200) { //200字限制" & vbcrlf & "                                                         data.push(n + ""="" + encodeURIComponent(encodeURIComponent(ibox.value)));" & vbcrlf & "                                                  } else {" & vbcrlf & "                                                                data.push(n + ""="");" & vbcrlf & "                                                       }" & vbcrlf & "                                               }" & vbcrlf & "                                       }" & vbcrlf & "                                       data.push(""__CatchFields="" + encodeURIComponent(CatchFields.join(""|"")));" & vbcrlf & "                                  data.push(""__BillTypeId="" + window.BillExtSN.CodeType);" & vbcrlf & "                                   var xhttp = window.XMLHttpRequest ? (new XMLHttpRequest()):(new ActiveXObject(""Microsoft.XMLHTTP""));" & vbcrlf & "                                      xhttp.open(""POST"", ((window.sysCurrPath ? (window.sysCurrPath + ""../"") : window.SysConfig.VirPath) + ""SYSN/view/comm/GetBHValue.ashx?GB2312=1""), false);" & vbcrlf & "                                      xhttp.setRequestHeader(""content-type"", ""application/x-www-form-urlencoded"");" & vbcrlf & "                                        xhttp.send(data.join(""&""));" & vbcrlf & "                                       var obj = eval(""("" + xhttp.responseText + "")"");" & vbcrlf &                                   "  window.BillExtSN.BindKeys = obj.keys; "& vbcrlf &                                   " //window.BillExtSN.ReBindEvt();" & vbcrlf &                         " }" & vbcrlf &                       " } "& vbcrlf &               " </script> "& vbcrlf & ""
		end if
		Response.write "" & vbcrlf & "              </div>" & vbcrlf & "  </tr>" & vbcrlf & "   "
		call ShowExtendedByKZZDY( TName, ord, columns,  col1,  col2 , false , bzstr , tsstr , oldZdySort , readonly, zdygroupid)
		call ShowExtendedByKZZDY( TName, ord, 1,  col1,  columns*2-1 , true , bzstr , tsstr , oldZdySort , readonly, zdygroupid)
	end function
	function ShowExtendedByKZZDY(byval TName,byval ord,byval columns, byval col1, byval col2 ,byval isIntro ,byval bzstr ,byval tsstr ,byval oldZdySort ,byval readonly,byval zdygroupid)
		dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7 , introsql
		dim  num1, i_jm, j_jm, c_Value,colstr1,colstr2,rssort,moneyDigits,numDigits,priceDigits
		set rssort=conn.execute("select num1 from setjm3 where ord=1")
		if not rssort.eof then
			moneyDigits=rssort(0)
		else
			moneyDigits=2
		end if
		set rssort=conn.execute("select num1 from setjm3 where ord=2019042802")
		if not rssort.eof then
			priceDigits=rssort(0)
		else
			priceDigits=2
		end if
		set rssort=conn.execute("select num1 from setjm3 where ord=88")
		if not rssort.eof then
			numDigits=rssort(0)
		else
			numDigits=2
		end if
		If col1>1 Then colstr1= " colspan='"&col1&"'"
		If col2>1 Then colstr2= " colspan='"&col2&"'"
		if TName=1001 or ord=-1 Then columns=2
'If col2>1 Then colstr2= " colspan='"&col2&"'"
		If ord = "" Then ord=0
		if isIntro=false then
			introsql = " and uitype<>13  "
		else
			introsql = " and uitype=13  "
		end if
		dim id, FName , dname , UiType,MustFillin,TextLen
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select *,case Id when 1 then 7 when 2 then 8 when 3 then 9 when 4 then 10 when 5 then 11 when 6 then 12 else Id end zdyid, 0 as mustshow, ' ' as arename  "
		sql = sql + " from sys_sdk_BillFieldInfo where billtype="& TName &" and ListType='0' and isused = 1 "& introsql & " and ProductZdyGroupId=" & clng(zdygroupid)
		sql = sql + " order by RootDataType desc, Showindex "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if rs_kz_zdy.eof = False then
			Response.write("<tr class='zdyrowgroup" + cstr(abs(zdygroupid*1>0)) + "'>")
'if rs_kz_zdy.eof = False then
			do until rs_kz_zdy.eof
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr class='zdyrowgroup" + cstr(abs(zdygroupid*1>0)) + "'>")
'if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					j_jm=j_jm+1
'if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
				end if
				c_Value=""
				id = rs_kz_zdy("zdyid")
				FName = rs_kz_zdy("title")
				dname = rs_kz_zdy("dbname")
				UiType = rs_kz_zdy("UiType")
				MustFillin = rs_kz_zdy("MustFillin")
				netid = rs_kz_zdy("id")
				TextLen = rs_kz_zdy("TextLen")
				Response.write "" & vbcrlf & "                     <td width=""11%"" align=""right"" "
				Response.write colstr1
				Response.write ">"
				Response.write FName
				Response.write "：</td>" & vbcrlf & "                      <td width=""22%"" "
				if i_jm=num1-1  then
					Response.write "：</td>" & vbcrlf & "                      <td width=""22%"" "
					Response.write "colspan="""
					Response.write col2+(col1+col2)*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """ "
				else
					Response.write colstr2
				end if
				Response.write ">" & vbcrlf & "                    "
				if instr(dname,"ext")>0 then
					zid = replace(dname&"","ext","")
					Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="& zid &" and OrderID="&ord&" and OrderID>0 ")
					If rs_kz_zdy_88.eof = False  Then c_Value=rs_kz_zdy_88("FValue")
					rs_kz_zdy_88.close
					if readonly then
						select case UiType
						case 31 :
						Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
						Response.write replace(c_Value,",","->")
						Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
						Response.write "</span>"
						case 2 :
						Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
						Response.write getExtendedValue(c_Value,numDigits)
						Response.write "</span>"
						case 3 :
						Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
						Response.write getExtendedValue(c_Value,moneyDigits)
						Response.write "</span>"
						case 3000 :
						Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
						Response.write getExtendedValue(c_Value,priceDigits)
						Response.write "</span>"
						Case Else:
						Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
						Response.write c_Value
						Response.write "</span>"
						end select
					else
						c_Value=replace(replace(c_Value&"","""","&#34;"),"'","&#39;")
						select case UiType
						case 0 :
						Response.write "" & vbcrlf & "                                     <input name=""danh_"
						Response.write zid
						Response.write """ type=""text"" size=""15"" id=""danh_"
						Response.write zid
						Response.write """ value="""
						Response.write c_Value
						Response.write """ dataType=""Limit"" "
						if MustFillin=1  then
							Response.write " min=""1""  msg=""必须在1到"
							Response.write TextLen
							Response.write "个字符之间""  "
						else
							Response.write " msg=""长度不能超过"
							Response.write TextLen
							Response.write "个字"" "
						end if
						Response.write "  max="
						Response.write TextLen
						Response.write " maxlength=""4000"">" & vbcrlf & "                                     "
						case 1:
						Response.write "" & vbcrlf & "                                     <input class=""resetDataPickerBg"" readonly name=""date_"
						Response.write zid
						Response.write """ value="""
						Response.write c_Value
						Response.write """ size=""15"" id=""daysOfMonthPos"" onmouseup=""toggleDatePicker('daysOfMonth_"
						Response.write zid
						Response.write "','date_"
						Response.write zid
						Response.write "')"" dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:93px;width:111px;;background-repeat:no-repeat;""> <div id=""daysOfMonth_"
						Response.write " min=""1"" "
						Response.write zid
						Response.write """ style=""POSITION:absolute""></div>" & vbcrlf & "                                  "
						case 2:
						Response.write "" & vbcrlf & "                                     <input name=""Numr_"
						Response.write zid
						Response.write """ type=""text"" value="""
						Response.write c_Value
						Response.write """ size=""15"" id=""Numr_"
						Response.write zid
						Response.write """ onpropertychange=""formatData(this,'number')"" dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                                  "
						case 3:
						Response.write "" & vbcrlf & "                                     <input name=""danh_"
						Response.write zid
						Response.write """ type=""text"" value="""
						Response.write c_Value
						Response.write """ size=""15"" id=""Numr_"
						Response.write zid
						Response.write """ onpropertychange=""formatData(this,'money')""  dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                                  "
						case 36:
						Response.write "" & vbcrlf & "                                     <input name=""danh_"
						Response.write zid
						Response.write """ type=""text"" value="""
						Response.write c_Value
						Response.write """ size=""15"" id=""Numr_"
						Response.write zid
						Response.write """  onpropertychange=""formatData(this,'int')""   dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                                  "
						case 3000:
						Response.write "" & vbcrlf & "                                     <input name=""danh_"
						Response.write zid
						Response.write """ type=""text"" value="""
						Response.write c_Value
						Response.write """ size=""15"" id=""Numr_"
						Response.write zid
						Response.write """ onpropertychange=""formatData(this,'CommPrice')"" dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                                  "
						case 4:
						Response.write "" & vbcrlf & "                                     <select name=""IsNot_"
						Response.write zid
						Response.write """ id=""IsNot_"
						Response.write zid
						Response.write """  dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                                   <option value=""是"" "
						If c_Value="是" then
							Response.write "selected"
						end if
						Response.write ">是</option>" & vbcrlf & "                                 <option value=""否"" "
						If c_Value="否" then
							Response.write "selected"
						end if
						Response.write ">否</option>" & vbcrlf & "                                 </select>" & vbcrlf & "                                       "
						case 5:
						Response.write "" & vbcrlf & "                                     <select name=""meju_"
						Response.write zid
						Response.write """ id=""meju_"
						Response.write zid
						Response.write """  dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                                   "
						xxsql = "select t1.id, t1.CValue from (select id,CValue from ERP_CustomOptions x  where CFID="& zid &") t1 "
						xxsql = xxsql & " inner join  (select [text], ShowIndex  from  sys_sdk_BillFieldOptionsSource where  Stoped=0 and FieldId=" & netid & "  ) t2  " &_
						" on t1.CValue = t2.[text]  order by t2.showindex "
						set rs7=conn.execute(xxsql)
						do until rs7.eof
							Response.write "" & vbcrlf & "                                             <option value="""
							Response.write rs7("id")
							Response.write """ "
							If rs7("CValue")&""=c_Value&"" then
								Response.write "selected"
							end if
							Response.write ">"
							Response.write rs7("CValue")
							Response.write "</option>" & vbcrlf & "                                            "
							rs7.movenext
						loop
						rs7.close
						Response.write "" & vbcrlf & "                                 </select>" & vbcrlf & "                                   "
						case 54:
						cixx = 0
						xxsql = "select t1.id, t1.CValue from (select id,CValue from ERP_CustomOptions x  where CFID="& zid &") t1 "
						xxsql = xxsql & " inner join  (select [text], ShowIndex  from  sys_sdk_BillFieldOptionsSource where  Stoped=0 and FieldId=" & netid & "  ) t2  " &_
						" on t1.CValue = t2.[text]  order by t2.showindex "
						set rs7=conn.execute(xxsql)
						do until rs7.eof
							Response.write "" & vbcrlf & "                                                      <input name=""danh_"
							Response.write zid
							Response.write """ id=""danh_"
							Response.write zid
							Response.write "_"
							Response.write cixx
							Response.write """ "
							if  instr("," & c_value   & ",", "," & rs7("CValue").value & ",")>0 then Response.write "checked"
							Response.write "  type=""checkbox"" value="""
							Response.write replace(rs7("CValue").value & "", """","&#34")
							Response.write """ >" & vbcrlf & "                                                       <label for=""danh_"
							Response.write zid
							Response.write "_"
							Response.write cixx
							Response.write """>"
							Response.write replace(rs7("CValue").value & "", """","&#34")
							Response.write "</label>" & vbcrlf & "                                             "
							cixx = cixx +1
							Response.write "</label>" & vbcrlf & "                                             "
							rs7.movenext
						loop
						rs7.close
						case 31:
						Response.write "" & vbcrlf & "                                     <select name=""danh_"
						Response.write zid
						Response.write """ id=""danh_"
						Response.write zid
						Response.write """  dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                                   "
						exitsgp = false
						ptxt = ""
						xxsql =  "select  [Text] as cvalue, deep  from sys_sdk_BillFieldOptionsSource a "
						xxsql = xxsql & " where  Stoped=0 and FieldId=" & netid & " "
						xxsql = xxsql & " and ( ParentId=0 or exists(select 1 from  sys_sdk_BillFieldOptionsSource b where a.ParentId=b.id and b.Stoped=0) )"
						xxsql = xxsql & " order by ShowIndex "
						set rs7=conn.execute(xxsql)
						do until rs7.eof
							if rs7("deep").value=0 then
								if exitsgp then Response.write "</optgroup>"
								Response.write " <optgroup label=""" &  rs7("cvalue")  & """>"
								ptxt  = rs7("cvalue").value
								exitsgp = true
							else
								myvalue = ptxt & "," & rs7("CValue")
								Response.write "" & vbcrlf & "                                             <option value="""
								Response.write myvalue
								Response.write """ "
								If myvalue&""=c_Value&"" then
									Response.write "selected"
								end if
								Response.write ">"
								Response.write rs7("CValue")
								Response.write "</option>" & vbcrlf & "                                            "
							end if
							rs7.movenext
						loop
						rs7.close
						if exitsgp then Response.write "</optgroup>"
						Response.write "" & vbcrlf & "                                 </select>" & vbcrlf & "                                   "
						case 10:
						Response.write "" & vbcrlf & "                        <textarea name=""duoh_"
						Response.write zid
						Response.write """ id=""duoh_"
						Response.write zid
						Response.write """ style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px;padding-left:4px;"" onfocus=""this.style.height=this.scrollHeight"" onpropertychange=""this.style.height=this.scrollHeight"" dataType=""Limit"" "
						Response.write zid
						if MustFillin=1 then
							Response.write " min=""1""   msg=""必须在1到"
							Response.write TextLen
							Response.write "个字符之间"" "
						else
							Response.write " msg=""长度不能超过"
							Response.write TextLen
							Response.write "个字"" "
						end if
						Response.write " max="
						Response.write TextLen
						Response.write ">"
						Response.write c_Value
						Response.write "</textarea>" & vbcrlf & "                        "
						case 13:
						Response.write "" & vbcrlf & "                        <textarea name=""beiz_"
						Response.write zid
						Response.write """ id=""beiz_"
						Response.write zid
						Response.write """ dataType=""Limit"" "
						If MustFillin=1 Then
							Response.write "min=""1"""
						end if
						Response.write "" & vbcrlf & "                            max=""4000""  msg=""备注长度不能超过4000个字"" style=""display:none;"" cols=""1"" rows=""1"">"
						if c_Value<>"" then Response.write c_Value End if
						Response.write "</textarea>" & vbcrlf & "                                  <IFRAME ID=""eWebEditor_"
						Response.write zid
						Response.write """ SRC=""../edit/ewebeditor.asp?id=beiz_"
						Response.write zid
						Response.write "&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""300"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME>" & vbcrlf & "                        "
						end select
					end if
				else
					dim tbname : tbname = ""
					select case TName
					case 16001 : tbname = "product"
					end select
					if ord<>0 then
						c_Value = sdk.getSqlValue("select "& dname &" from "& tbname & " where ord="& ord,"")
						if UiType<>0 and len(c_Value)>0 and readonly then
							c_Value = sdk.getSqlValue("select sort1 from sortonehy where ord= "& c_Value,"")
						end if
					end if
					if readonly then
						Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
						Response.write c_Value
						Response.write "</span>"
					else
						if UiType=0 then
							c_Value=replace(replace(c_Value&"","""","&#34;"),"'","&#39;")
							Response.write "" & vbcrlf & "                        <input name="""
							Response.write dname
							Response.write """ type=""text"" size=""20"" id="""
							Response.write dname
							Response.write """ value="""
							Response.write c_Value
							Response.write """ "
							if CheckPurview(tsstr,dname)=True then
								Response.write "onChange=""callServer_ts('"
								Response.write id
								Response.write "','"
								Response.write dname
								Response.write "');"""
							end if
							Response.write " dataType=""Limit"" "
							if  CheckPurview(bzstr,dname)=True or MustFillin=1  then
								Response.write " min=""1"" "
							end if
							Response.write "  max=""200""  msg=""必须在1到200个字符之间"">" & vbcrlf & "                        "
						else
							Response.write "" & vbcrlf & "                        <select name="""
							Response.write dname
							Response.write """ "
							if CheckPurview(tsstr,dname)=True then
								Response.write "onChange=""callServer_ts('"
								Response.write id
								Response.write "','"
								Response.write dname
								Response.write "');"""
							end if
							Response.write " id="""
							Response.write dname
							Response.write """   dataType=""Limit"" "
							if  CheckPurview(btstr,dname)=True  then
								Response.write " min=""1"" "
							end if
							Response.write "  max=""50""  msg=""长度不能超过50个字"">" & vbcrlf & "                        "
							dim gl : gl = sdk.getSqlValue("select gl from zdy where sort1= "& oldZdySort & " and name='"& dname &"' ",0)
							set rs7=server.CreateObject("adodb.recordset")
							sql7="select ord,sort1 from sortonehy where gate2="& gl &" order by gate1 desc "
							rs7.open sql7,conn,1,1
							do until rs7.eof
								Response.write "" & vbcrlf & "                            <option value="""
								Response.write rs7("ord")
								Response.write """ "
								if rs7("ord").value &""=c_Value&"" then
									Response.write "selected"
								end if
								Response.write " >"
								Response.write rs7("sort1")
								Response.write "</option>" & vbcrlf & "                            "
								rs7.movenext
							loop
							rs7.close
							set rs7=nothing
							Response.write "" & vbcrlf & "                        </select>" & vbcrlf & "                        "
						end if
					end if
				end if
				Response.write " <span id=""test"
				Response.write id
				Response.write """ class=""red"">"
				if  (MustFillin=1 or CheckPurview(bzstr,dname)=true) and readonly=false Then
					Response.write "*"
				end if
				Response.write "</span>" & vbcrlf & "                      </td>" & vbcrlf & "                   "
				i_jm=i_jm+1
				Response.write "</span>" & vbcrlf & "                      </td>" & vbcrlf & "                   "
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function showExtended(TName,ord,columns,col1,col2)
		dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7
		dim  num1, i_jm, j_jm, c_Value,colstr1,colstr2
		If col1>1 Then colstr1= " colspan='"&col1&"'"
		If col2>1 Then colstr2= " colspan='"&col2&"'"
		if TName=1001 or ord=-1 Then columns=2
'If col2>1 Then colstr2= " colspan='"&col2&"'"
		If ord = "" Then ord=0
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 and FType<>'5' order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if rs_kz_zdy.eof = False then
			Response.write("<tr>")
			do until rs_kz_zdy.eof
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr>")
					j_jm=j_jm+1
					Response.write("</tr><tr>")
				end if
				c_Value=""
				Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy("id")&" and OrderID="&ord&" and OrderID>0 ")
				If rs_kz_zdy_88.eof = False  Then c_Value=rs_kz_zdy_88("FValue")
				rs_kz_zdy_88.close
				Response.write "" & vbcrlf & "                      <td width=""11%"" align=""right"" "
				Response.write colstr1
				Response.write ">"
				Response.write rs_kz_zdy("FName")
				Response.write "：</td>" & vbcrlf & "                       <td width=""22%"" "
				if i_jm=num1-1  then
					Response.write "：</td>" & vbcrlf & "                       <td width=""22%"" "
					Response.write "colspan="""
					Response.write col2+(col1+col2)*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """ "
				else
					Response.write colstr2
				end if
				Response.write ">" & vbcrlf & "                     "
				if rs_kz_zdy("FType")="1" Then
					Response.write "" & vbcrlf & "                              <input name=""danh_"
					Response.write rs_kz_zdy("id")
					Response.write """ type=""text"" size=""15"" id=""danh_"
					Response.write rs_kz_zdy("id")
					Response.write """ value="""
					Response.write c_Value
					Response.write """ dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1""  msg=""必须在1到200个字符之间""  "
					else
						Response.write " msg=""长度不能超过200个字"" "
					end if
					Response.write "  max=""200"" maxlength=""4000"">" & vbcrlf & "                             "
				Elseif rs_kz_zdy("FType")="2" then
					Response.write "" & vbcrlf & "                              <textarea name=""duoh_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""duoh_"
					Response.write rs_kz_zdy("id")
					Response.write """ style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px;padding-left:4px;"" onfocus=""this.style.height=this.scrollHeight"" onpropertychange=""this.style.height=this.scrollHeight"" dataType=""Limit"" "
					Response.write rs_kz_zdy("id")
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1""   msg=""必须在1到500个字符之间"" "
					else
						Response.write " msg=""长度不能超过500个字"" "
					end if
					Response.write " max=""500"">"
					Response.write c_Value
					Response.write "</textarea>" & vbcrlf & "                           "
				elseif rs_kz_zdy("FType")="3" Then
					Response.write "" & vbcrlf & "                              <input class=""resetDataPickerBg"" readonly name=""date_"
					Response.write rs_kz_zdy("id")
					Response.write """ value="""
					Response.write c_Value
					Response.write """ size=""15"" id=""daysOfMonthPos"" onmouseup=""toggleDatePicker('daysOfMonth_"
					Response.write rs_kz_zdy("id")
					Response.write "','date_"
					Response.write rs_kz_zdy("id")
					Response.write "')"" dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:93px;width:111px;;background-repeat:no-repeat;""> <div id=""daysOfMonth_"
					Response.write " min=""1"" "
					Response.write rs_kz_zdy("id")
					Response.write """ style=""POSITION:absolute""></div>" & vbcrlf & "                           "
				ElseIf rs_kz_zdy("FType")="4" then
					Response.write "" & vbcrlf & "                              <input name=""Numr_"
					Response.write rs_kz_zdy("id")
					Response.write """ type=""text"" value="""
					Response.write c_Value
					Response.write """ size=""15"" id=""Numr_"
					Response.write rs_kz_zdy("id")
					Response.write """ onkeyup=value=value.replace(/[^\d\.]/g,'') dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                           "
				ElseIf rs_kz_zdy("FType")="6" then
					Response.write "" & vbcrlf & "                              <select name=""IsNot_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""IsNot_"
					Response.write rs_kz_zdy("id")
					Response.write """  dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                            <option value=""是"" "
					If c_Value="是" then
						Response.write "selected"
					end if
					Response.write ">是</option>" & vbcrlf & "                          <option value=""否"" "
					If c_Value="否" then
						Response.write "selected"
					end if
					Response.write ">否</option>" & vbcrlf & "                          </select>" & vbcrlf & "                               "
				else
					Response.write "" & vbcrlf & "                              <select name=""meju_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""meju_"
					Response.write rs_kz_zdy("id")
					Response.write """  dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                           "
					set rs7=conn.execute("select id,CValue from ERP_CustomOptions where CFID="&rs_kz_zdy("id")&" order by id asc ")
					do until rs7.eof
						Response.write "" & vbcrlf & "                                     <option value="""
						Response.write rs7("id")
						Response.write """ "
						If rs7("CValue")&""=c_Value&"" then
							Response.write "selected"
						end if
						Response.write ">"
						Response.write rs7("CValue")
						Response.write "</option>" & vbcrlf & "                                    "
						rs7.movenext
					loop
					rs7.close
					Response.write "" & vbcrlf & "                        </select>" & vbcrlf & "                            "
				end if
				if  rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then
					Response.write " <span class=""red"">*</span>"
				end if
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
				i_jm=i_jm+1
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function showExtended2(TName,ord,columns,col1,col2)
		dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7
		dim  num1, i_jm, j_jm, c_Value,colstr1,colstr2
		If col1>1 Then colstr1= " colspan='"&col1&"'"
		If col2>1 Then colstr2= " colspan='"&col2&"'"
		if TName=1001 or ord=-1 Then columns=2
'If col2>1 Then colstr2= " colspan='"&col2&"'"
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 and FType<>'5' order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if rs_kz_zdy.eof = False then
			Response.write("<tr>")
			do until rs_kz_zdy.eof
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr>")
					j_jm=j_jm+1
					Response.write("</tr><tr>")
				end if
				c_Value=""
				Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy("id")&" and OrderID="&ord&" and OrderID>0 ")
				If rs_kz_zdy_88.eof = False  Then c_Value=rs_kz_zdy_88("FValue")
				rs_kz_zdy_88.close
				Response.write "" & vbcrlf & "                     <td align=""right"" "
				Response.write colstr1
				Response.write ">"
				Response.write rs_kz_zdy("FName")
				Response.write "：</td>" & vbcrlf & "                      <td "
				if i_jm=num1-1  then
					Response.write "：</td>" & vbcrlf & "                      <td "
					Response.write "colspan="""
					Response.write col2+(col1+col2)*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """ "
				else
					Response.write colstr2
				end if
				Response.write ">" & vbcrlf & "                    "
				if rs_kz_zdy("FType")="1" Then
					Response.write "" & vbcrlf & "                             <input name=""danh_"
					Response.write rs_kz_zdy("id")
					Response.write """ type=""text"" size=""15"" id=""danh_"
					Response.write rs_kz_zdy("id")
					Response.write """ value="""
					Response.write c_Value
					Response.write """ dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"" maxlength=""4000"">" & vbcrlf & "                            "
				Elseif rs_kz_zdy("FType")="2" then
					Response.write "" & vbcrlf & "                             <textarea name=""duoh_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""duoh_"
					Response.write rs_kz_zdy("id")
					Response.write """ style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px"" onfocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" dataType=""Limit"" "
					Response.write rs_kz_zdy("id")
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write " max=""500""  msg=""必须在1到500个字符"">"
					Response.write c_Value
					Response.write "</textarea>" & vbcrlf & "                          "
				elseif rs_kz_zdy("FType")="3" Then
					Response.write "" & vbcrlf & "                             <input readonly name=""date_"
					Response.write rs_kz_zdy("id")
					Response.write """ value="""
					Response.write c_Value
					Response.write """ size=""15"" id=""daysOfMonthPos"" onmouseup=""toggleDatePicker('daysOfMonth_"
					Response.write rs_kz_zdy("id")
					Response.write "','date_"
					Response.write rs_kz_zdy("id")
					Response.write "')"" dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:right;background-repeat:no-repeat;""> <div id=""daysOfMonth_"
					Response.write " min=""1"" "
					Response.write rs_kz_zdy("id")
					Response.write """ style=""POSITION:absolute""></div>" & vbcrlf & "                          "
				ElseIf rs_kz_zdy("FType")="4" then
					Response.write "" & vbcrlf & "                             <input name=""Numr_"
					Response.write rs_kz_zdy("id")
					Response.write """ type=""text"" value="""
					Response.write c_Value
					Response.write """ size=""15"" id=""Numr_"
					Response.write rs_kz_zdy("id")
					Response.write """ onkeyup=value=value.replace(/[^\d\.]/g,'') dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                          "
				ElseIf rs_kz_zdy("FType")="6" then
					Response.write "" & vbcrlf & "                             <select name=""IsNot_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""IsNot_"
					Response.write rs_kz_zdy("id")
					Response.write """  dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                           <option value=""是"" "
					If c_Value="是" then
						Response.write "selected"
					end if
					Response.write ">是</option>" & vbcrlf & "                         <option value=""否"" "
					If c_Value="否" then
						Response.write "selected"
					end if
					Response.write ">否</option>" & vbcrlf & "                         </select>" & vbcrlf & "                               "
				else
					Response.write "" & vbcrlf & "                             <select name=""meju_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""meju_"
					Response.write rs_kz_zdy("id")
					Response.write """  dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                           "
					set rs7=conn.execute("select id,CValue from ERP_CustomOptions where CFID="&rs_kz_zdy("id")&" order by id asc ")
					do until rs7.eof
						Response.write "" & vbcrlf & "                                     <option value="""
						Response.write rs7("id")
						Response.write """ "
						If rs7("CValue")&""=c_Value&"" then
							Response.write "selected"
						end if
						Response.write ">"
						Response.write rs7("CValue")
						Response.write "</option>" & vbcrlf & "                                    "
						rs7.movenext
					loop
					rs7.close
					Response.write "" & vbcrlf & "                        </select>" & vbcrlf & "                            "
				end if
				if  rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then
					Response.write " <span class=""red"">*</span>"
				end if
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
				i_jm=i_jm+1
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function getExtendedDeal(TName,ord,repID)
		Call showExtendedDeal(TName,ord,3,1,1,repID)
	end function
	Function showExtendedDeal(TName,ord,columns,col1,col2,repID)
		dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7
		dim  num1, i_jm, j_jm, c_Value,colstr1,colstr2
		If col1>1 Then colstr1= " colspan='"&col1&"'"
		If col2>1 Then colstr2= " colspan='"&col2&"'"
		columns = 2
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from Copy_CustomFields where TName="&TName&" AND RepairOrder = "&repID&" "& KZ_LIMITID &" and FType<>5 and IsUsing=1 and del=1 order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if rs_kz_zdy.eof = False then
			Response.write("<tr>")
			do until rs_kz_zdy.eof
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr>")
					j_jm=j_jm+1
					Response.write("</tr><tr>")
				end if
				c_Value=""
				Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy("id")&" and OrderID="&ord&" ")
				If rs_kz_zdy_88.eof = False  Then c_Value=rs_kz_zdy_88("FValue")
				rs_kz_zdy_88.close
				Response.write "" & vbcrlf & "                     <td width=""11%"" align=""right"" "
				Response.write colstr1
				Response.write ">"
				Response.write rs_kz_zdy("FName")
				Response.write "：</td>" & vbcrlf & "                      <td width=""22%"" "
				if i_jm=num1-1  then
					Response.write "：</td>" & vbcrlf & "                      <td width=""22%"" "
					Response.write "colspan="""
					Response.write col2+(col1+col2)*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """ "
				else
					Response.write colstr2
				end if
				Response.write ">" & vbcrlf & "                    "
				if rs_kz_zdy("FType")="1" Then
					Response.write "" & vbcrlf & "                             <input name=""danh_"
					Response.write rs_kz_zdy("id")
					Response.write """ type=""text"" size=""15"" id=""danh_"
					Response.write rs_kz_zdy("id")
					Response.write """ value="""
					Response.write c_Value
					Response.write """ dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"" maxlength=""4000"">" & vbcrlf & "                            "
				Elseif rs_kz_zdy("FType")="2" then
					Response.write "" & vbcrlf & "                             <textarea name=""duoh_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""duoh_"
					Response.write rs_kz_zdy("id")
					Response.write """ style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px;padding-left:4px;"" onfocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" dataType=""Limit"" "
					Response.write rs_kz_zdy("id")
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write " max=""500""  msg=""必须在1到500个字符"">"
					Response.write c_Value
					Response.write "</textarea>" & vbcrlf & "                          "
				Elseif rs_kz_zdy("FType")="5" then
					Response.write "" & vbcrlf & "                             <textarea name=""beiz_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""beiz_"
					Response.write rs_kz_zdy("id")
					Response.write """ style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px;padding-left:4px;"" onfocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" dataType=""Limit"" "
					Response.write rs_kz_zdy("id")
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write " max=""4000""  msg=""必须在1到4000个字符"">"
					Response.write c_Value
					Response.write "</textarea>" & vbcrlf & "                          "
				elseif rs_kz_zdy("FType")="3" Then
					Response.write "" & vbcrlf & "                             <input readonly name=""date_"
					Response.write rs_kz_zdy("id")
					Response.write """ value="""
					Response.write c_Value
					Response.write """ size=""15"" id=""daysOfMonthPos"" onmouseup=""toggleDatePicker('daysOfMonth_"
					Response.write rs_kz_zdy("id")
					Response.write "','date_"
					Response.write rs_kz_zdy("id")
					Response.write "')"" dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:right;background-repeat:no-repeat;""> <div id=""daysOfMonth_"
					Response.write " min=""1"" "
					Response.write rs_kz_zdy("id")
					Response.write """ style=""POSITION:absolute""></div>" & vbcrlf & "                          "
				ElseIf rs_kz_zdy("FType")="4" then
					Response.write "" & vbcrlf & "                             <input name=""Numr_"
					Response.write rs_kz_zdy("id")
					Response.write """ type=""text"" value="""
					Response.write c_Value
					Response.write """ size=""15"" id=""Numr_"
					Response.write rs_kz_zdy("id")
					Response.write """ onkeyup=value=value.replace(/[^\d\.]/g,'') dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                  "
				ElseIf rs_kz_zdy("FType")="6" then
					Response.write "" & vbcrlf & "                             <select name=""IsNot_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""IsNot_"
					Response.write rs_kz_zdy("id")
					Response.write """  dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                           <option value=""是"" "
					If c_Value="是" then
						Response.write "selected"
					end if
					Response.write ">是</option>" & vbcrlf & "                         <option value=""否"" "
					If c_Value="否" then
						Response.write "selected"
					end if
					Response.write ">否</option>" & vbcrlf & "                         </select>" & vbcrlf & "                               "
				else
					Response.write "" & vbcrlf & "                             <select name=""meju_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""meju_"
					Response.write rs_kz_zdy("id")
					Response.write """  dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                           "
					set rs7=conn.execute("select id,CValue from ERP_CustomOptions where CFID="&rs_kz_zdy("id")&" order by id asc ")
					do until rs7.eof
						Response.write "" & vbcrlf & "                                     <option value="""
						Response.write rs7("id")
						Response.write """ "
						If rs7("CValue")&""=c_Value&"" then
							Response.write "selected"
						end if
						Response.write ">"
						Response.write rs7("CValue")
						Response.write "</option>" & vbcrlf & "                                    "
						rs7.movenext
					loop
					rs7.close
					Response.write "" & vbcrlf & "                        </select>" & vbcrlf & "                            "
				end if
				if  rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then
					Response.write " <span class=""red"">*</span>"
				end if
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
				i_jm=i_jm+1
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function showExtendedBzDeal(TName,ord, repID,col1,col2)
		Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
		if TName=1001 or ord=-1 Then col2=3
'Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
		If col1>1 Then colstr1= " colspan='"&col1&"'"
		If col2>1 Then colstr2= " colspan='"&col2&"'"
		Set rs_kz_zdy_8=server.CreateObject("adodb.recordset")
		rs_kz_zdy_8.open "select * from Copy_CustomFields where IsUsing=1 and TName="&TName&" AND RepairOrder = "&repID&" "& KZ_LIMITID &" and FType='5' order by FOrder asc",conn,1,1
		If Not rs_kz_zdy_8.eof Then
			Do While Not rs_kz_zdy_8.eof
				If Len(rs_kz_zdy_8("FName")&"") > 0 then
					c_Value=""
					Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy_8("id")&" and OrderID="&ord&" ")
					If Not rs_kz_zdy_88.eof Then c_Value=rs_kz_zdy_88("FValue")
					rs_kz_zdy_88.close
					Response.write "" & vbcrlf & "                         <tr>" & vbcrlf & "                                    <td "
					Response.write colstr1
					Response.write "><div align=""right"">"
					If (rs_kz_zdy_8("MustFillin") Or Len(KZ_LIMITID&"")>0 ) And (rs_kz_zdy_8("FType")=1 Or rs_kz_zdy_8("FType")=2 Or rs_kz_zdy_8("FType")=4) then
						Response.write " &nbsp;<span class=""red"">*&nbsp;</span>"
					end if
					Response.write rs_kz_zdy_8("FName")
					Response.write "：</div></td>" & vbcrlf & "                                    <td "
					Response.write colstr2
					Response.write "><textarea name=""beiz_"
					Response.write rs_kz_zdy_8("id")
					Response.write """ id=""beiz_"
					Response.write rs_kz_zdy_8("id")
					Response.write """ dataType=""Limit""  " & vbcrlf & "                    "
					If Len(KZ_LIMITID&"")>0 Then
						Response.write "min=""1"""
					end if
					Response.write "" & vbcrlf & "                    max=""4000""  msg=""备注长度不能超过4000个字"" style=""display:none;"" cols=""1"" rows=""1"">"
					if c_Value<>"" then Response.write c_Value End if
					Response.write "</textarea>" & vbcrlf & "                              <IFRAME ID=""eWebEditor_"
					Response.write rs_kz_zdy_8("id")
					Response.write """ SRC=""../edit/ewebeditor.asp?id=beiz_"
					Response.write rs_kz_zdy_8("id")
					Response.write "&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""300"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME></td>" & vbcrlf & "                         </tr>" & vbcrlf & "                       "
				end if
				rs_kz_zdy_8.movenext
			loop
		end if
		rs_kz_zdy_8.close
		Set rs_kz_zdy_8=Nothing
	end function
	Function getExtended2(TName,ord,ly_str)
		columns=3
		if TName=1001 or ord=-1 Then columns=2
'columns=3
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 and FType<>'5' order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if Not rs_kz_zdy.eof then
			Response.write("<tr>")
			do until rs_kz_zdy.eof
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr>")
					j_jm=j_jm+1
				end if
				c_Value=""
				Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy("id")&" and OrderID="&ord&" ")
				If Not rs_kz_zdy_88.eof Then c_Value=rs_kz_zdy_88("FValue")
				rs_kz_zdy_88.close
				Response.write "<td width='11%' align='right'>"&rs_kz_zdy("FName")&"：</td><td width='22%' "
				if i_jm=num1-1  Then Response.write "colspan="&(1+2*(j_jm*columns-num1))&" "
				Response.write "<td width='11%' align='right'>"&rs_kz_zdy("FName")&"：</td><td width='22%' "
				Response.write ">"
				if rs_kz_zdy("FType")="1" Then
					Response.write "<input name='danh_"&rs_kz_zdy("id")&"' type='text' size='15' id='danh_"&rs_kz_zdy("id")&"' value='"&c_Value&"' dataType='Limit' "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
					Response.write " max='500'  msg='必须在1到500个字符' maxlength='4000'>"
				Elseif rs_kz_zdy("FType")="2" Then
					Response.write "<textarea name='duoh_"&rs_kz_zdy("id")&"' id='duoh_"&rs_kz_zdy("id")&"' style='overflow-y:hidden;word-break:break-all;width:160px;height:22px;padding-left:4px;' onfocus='this.style.posHeight=this.scrollHeight' onpropertychange='this.style.posHeight=this.scrollHeight' dataType='Limit' "
'Elseif rs_kz_zdy("FType")="2" Then
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
					Response.write " max='500'  msg='必须在1到500个字符'>"&c_Value&"</textarea>"
				elseif rs_kz_zdy("FType")="3" Then
					Response.write "<input readonly name='date_"&rs_kz_zdy("id")&"' value='"&c_Value&"' size='15' id='daysOfMonthPos' onmouseup=""toggleDatePicker('daysOfMonth_"&rs_kz_zdy("id")&"','date_"&rs_kz_zdy("id")&"')"" dataType='Limit' "
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
					Response.write " max='500' msg='请选择日期' style='background-image:url(../images/datePicker.gif);background-position:right;background-repeat:no-repeat;'> <div id='daysOfMonth_"&rs_kz_zdy("id")&"' style='POSITION:absolute'></div>"
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
				ElseIf rs_kz_zdy("FType")="4" then
					Response.write "<input name='Numr_"&rs_kz_zdy("id")&"' type='text' value='"&c_Value&"' size='15' id='Numr_"&rs_kz_zdy("id")&"' onkeyup=value=value.replace(/[^\d\.]/g,'') dataType='Limit' "
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1'  "
					Response.write " max='500'  msg='必须在1到500个字符' >"
				ElseIf rs_kz_zdy("FType")="6" then
					Response.write "<select name='IsNot_"&rs_kz_zdy("id")&"' id='IsNot_"&rs_kz_zdy("id")&"'  dataType='Limit' "
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
					Response.write " max='500'  msg='必须在1到500个字符'>"
					Response.write "<option value='是' "
					If c_Value="是" Then Response.write " selected "
					Response.write ">是</option>"
					Response.write "<option value='否' "
					If c_Value="否" Then Response.write " selected "
					Response.write ">否</option>"
					Response.write "</select>"
				else
					Response.write "<select name='meju_"&rs_kz_zdy("id")&"' id='meju_"&rs_kz_zdy("id")&"'  dataType='Limit' "
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
					Response.write " max='500'  msg='必须在1到500个字符'>"
					Response.write "<option value=''></option>"
					ly_sql=""
					If c_Value<>"" And ly_str&""<>"" Then ly_str=ly_str&","&c_Value
					If ly_str&""<>"" Then ly_sql=" and id in ("&ly_str&")"
					set rs7=conn.execute("select id,CValue from ERP_CustomOptions where CFID="&rs_kz_zdy("id")&" "&ly_sql&" order by id asc ")
					do until rs7.eof
						Response.write "<option value='"&rs7("id")&"' "
						If rs7("CValue")&""=c_Value&"" Then Response.write " selected "
						Response.write ">"&rs7("CValue")&"</option>"
						rs7.movenext
					loop
					rs7.close
					Response.write "</select>"
				end if
				if  (rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0) And (rs_kz_zdy("FType")=1 Or rs_kz_zdy("FType")=2 Or rs_kz_zdy("FType")=4)  Then Response.write " &nbsp;<span class='red'>*</span>"
				Response.write "</td>"
				i_jm=i_jm+1
				Response.write "</td>"
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function getExtended1(TName,ord)
		Call showExtended1(TName,ord,1,1,5)
	end function
	Function showExtended1(TName,ord,columns ,col1,col2)
		Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
		if TName=1001 or ord=-1 Then col2=3
'Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
		If col1>1 Then colstr1= " colspan='"&col1&"'"
		If col2>1 Then colstr2= " colspan='"&col2&"'"
		Set rs_kz_zdy_8=server.CreateObject("adodb.recordset")
		rs_kz_zdy_8.open "select * from ERP_CustomFields where IsUsing=1 and TName="&TName&" "& KZ_LIMITID &" and FType='5' order by FOrder asc",conn,1,1
		If Not rs_kz_zdy_8.eof Then
			Do While Not rs_kz_zdy_8.eof
				c_Value=""
				Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy_8("id")&" and OrderID="&ord&" ")
				If Not rs_kz_zdy_88.eof Then c_Value=rs_kz_zdy_88("FValue")
				rs_kz_zdy_88.close
				Response.write "" & vbcrlf & "                      <tr>" & vbcrlf & "                            <td width=""11%"" "
				Response.write colstr1
				Response.write "><div align=""right"">"
				If (rs_kz_zdy_8("MustFillin") Or Len(KZ_LIMITID&"")>0 ) And (rs_kz_zdy_8("FType")=1 Or rs_kz_zdy_8("FType")=2 Or rs_kz_zdy_8("FType")=4) then
					Response.write " &nbsp;<span class=""red"">*&nbsp;</span>"
				end if
				Response.write rs_kz_zdy_8("FName")
				Response.write "：</div></td>" & vbcrlf & "                         <td "
				Response.write colstr2
				Response.write "><textarea name=""beiz_"
				Response.write rs_kz_zdy_8("id")
				Response.write """ id=""beiz_"
				Response.write rs_kz_zdy_8("id")
				Response.write """ dataType=""Limit""  " & vbcrlf & "                "
				If Len(KZ_LIMITID&"")>0 Then
					Response.write "min=""1"""
				end if
				Response.write "" & vbcrlf & "                max=""4000""  msg=""备注长度不能超过4000个字"" style=""display:none;"" cols=""1"" rows=""1"">"
				if c_Value<>"" then Response.write c_Value End if
				Response.write "</textarea>" & vbcrlf & "                           <IFRAME ID=""eWebEditor_"
				Response.write rs_kz_zdy_8("id")
				Response.write """ SRC=""../edit/ewebeditor.asp?id=beiz_"
				Response.write rs_kz_zdy_8("id")
				Response.write "&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""300"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME></td>" & vbcrlf & "                     </tr>" & vbcrlf & "                   "
				rs_kz_zdy_8.movenext
			loop
		end if
		rs_kz_zdy_8.close
		Set rs_kz_zdy_8=Nothing
	end function
	Function showExtended3(TName,ord,columns ,col1,col2)
		Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
		if TName=1001 or ord=-1 Then col2=3
'Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
		If col1>1 Then colstr1= " colspan='"&col1&"'"
		If col2>1 Then colstr2= " colspan='"&col2&"'"
		Set rs_kz_zdy_8=server.CreateObject("adodb.recordset")
		rs_kz_zdy_8.open "select * from ERP_CustomFields where IsUsing=1 and TName="&TName&" "& KZ_LIMITID &" and FType='5' order by FOrder asc",conn,1,1
		If Not rs_kz_zdy_8.eof Then
			Do While Not rs_kz_zdy_8.eof
				c_Value=""
				Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy_8("id")&" and OrderID="&ord&" ")
				If Not rs_kz_zdy_88.eof Then c_Value=rs_kz_zdy_88("FValue")
				rs_kz_zdy_88.close
				Response.write "" & vbcrlf & "                     <tr>" & vbcrlf & "                            <td "
				Response.write colstr1
				Response.write "><div align=""right"">"
				If (rs_kz_zdy_8("MustFillin") Or Len(KZ_LIMITID&"")>0 ) And (rs_kz_zdy_8("FType")=1 Or rs_kz_zdy_8("FType")=2 Or rs_kz_zdy_8("FType")=4) then
					Response.write " &nbsp;<span class=""red"">*&nbsp;</span>"
				end if
				Response.write rs_kz_zdy_8("FName")
				Response.write "：</div></td>" & vbcrlf & "                                <td "
				Response.write colstr2
				Response.write "><textarea name=""beiz_"
				Response.write rs_kz_zdy_8("id")
				Response.write """ id=""beiz_"
				Response.write rs_kz_zdy_8("id")
				Response.write """ dataType=""Limit""  " & vbcrlf & "                "
				If Len(KZ_LIMITID&"")>0 Then
					Response.write "min=""1"""
				end if
				Response.write "" & vbcrlf & "                max=""4000""  msg=""备注长度不能超过4000个字"" style=""display:none;"" cols=""1"" rows=""1"">"
				if c_Value<>"" then Response.write c_Value End if
				Response.write "</textarea>" & vbcrlf & "                          <IFRAME ID=""eWebEditor_"
				Response.write rs_kz_zdy_8("id")
				Response.write """ SRC=""../edit/ewebeditor.asp?id=beiz_"
				Response.write rs_kz_zdy_8("id")
				Response.write "&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""300"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME></td>" & vbcrlf & "                     </tr>" & vbcrlf & "                   "
				rs_kz_zdy_8.movenext
			loop
		end if
		rs_kz_zdy_8.close
		Set rs_kz_zdy_8=Nothing
	end function
	Function saveExtended(TName,ord)
		Dim rs_kz_zdy, FValue, OID, sql, id, rs0, rs1
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select *,(select uitype from sys_sdk_BillFieldInfo m where m.billtype=16001 and m.dbname='ext' +cast(t.id as varchar(12)) ) as utype from ERP_CustomFields t where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 order by FOrder asc "
'set rs_kz_zdy=server.CreateObject("adodb.recordset")
		rs_kz_zdy.open sql,conn,1,1
		If not rs_kz_zdy.eof Then
			Do While Not rs_kz_zdy.eof
				id=rs_kz_zdy("id")
				if rs_kz_zdy("FType")="1" Then
					if rs_kz_zdy("utype")="54" then
						FValue=replace(Trim(request.Form("danh_"&id)),", ",",")
					else
						FValue=Trim(request.Form("danh_"&id))
					end if
				ElseIf rs_kz_zdy("FType")="2" then
					FValue=Trim(request.Form("duoh_"&id))
				ElseIf rs_kz_zdy("FType")="3" then
					FValue=Trim(request.Form("date_"&id))
				ElseIf rs_kz_zdy("FType")="4"  then
					FValue=Trim(request.Form("Numr_"&id))
				ElseIf rs_kz_zdy("FType")="5" then
					FValue=Trim(request.Form("beiz_"&id))
				ElseIf rs_kz_zdy("FType")="6" then
					FValue=Trim(request.Form("IsNot_"&id))
				else
					OID=Trim(request.Form("meju_"&id))
					If OID="" Then OID=0
					Set rs1=server.CreateObject("adodb.recordset")
					rs1.open "select CValue from ERP_CustomOptions where id="&OID,conn,1,1
					If rs1.eof Then
						FValue=""
					else
						FValue=rs1("CValue")
					end if
					rs1.close
					Set rs1=nothing
				end if
				Set rs0=server.CreateObject("adodb.recordset")
				rs0.open "select top 1 * from ERP_CustomValues where FieldsID="&id&" and OrderID="&ord&" ",conn,1,1
				If rs0.eof Then
					If FValue<>"" And not IsNull(FValue) Then
						conn.execute "insert into ERP_CustomValues(FieldsID,OrderID,FValue) values("&id&","&ord&",N'"&FValue&"')"
					end if
				else
					conn.execute "update ERP_CustomValues set FValue=N'"&FValue&"' where FieldsID="&id&" and OrderID="&ord&" "
				end if
				rs0.close
				Set rs0=nothing
				rs_kz_zdy.movenext
			loop
		end if
		rs_kz_zdy.close
		Set rs_kz_zdy=Nothing
	end function
	Function searchExtended(TName,col)
		Dim sqldate
		Dim rs_kz_zdy_2 : set rs_kz_zdy_2=server.CreateObject("adodb.recordset")
		Dim sql2 : sql2="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 and CanSearch=1 order by FOrder asc "
		Dim str33,id,danh_1,danh_2,Numr_1,Numr_2,beiz_1,beiz_2,IsNot_1,meju_1,duoh_1,duoh_2,date_1,date_2
		rs_kz_zdy_2.open sql2,conn,1,1
		if rs_kz_zdy_2.eof then
		else
			str33=""
			do until rs_kz_zdy_2.eof
				id=rs_kz_zdy_2("id")
				If rs_kz_zdy_2("FType")="1" Then
					danh_1=request("danh_"&id&"_1")
					danh_2=request("danh_"&id&"_2")
					str33=str33+"&danh_"&id&"_1="+danh_1
'danh_2=request("danh_"&id&"_2")
					str33=str33+"&danh_"&id&"_2="+danh_2
'danh_2=request("danh_"&id&"_2")
					If danh_2<>"" Then
						If danh_1=1 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& danh_2 &"%')"
'If danh_1=1 Then
						Elseif danh_1=2 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue not like '%"& danh_2 &"%')"
'Elseif danh_1=2 Then
						Elseif danh_1=3 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& danh_2 &"')"
'Elseif danh_1=3 Then
						Elseif danh_1=4 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue<>'"& danh_2 &"')"
'Elseif danh_1=4 Then
						Elseif danh_1=5 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '"& danh_2 &"%')"
'Elseif danh_1=5 Then
						Elseif danh_1=6 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& danh_2 &"')"
'Elseif danh_1=6 Then
						end if
					end if
				ElseIf rs_kz_zdy_2("FType")="2" Then
					duoh_1=request("duoh_"&id&"_1")
					duoh_2=request("duoh_"&id&"_2")
					str33=str33+"&duoh_"&id&"_1="+duoh_1
'duoh_2=request("duoh_"&id&"_2")
					str33=str33+"&duoh_"&id&"_2="+duoh_2
'duoh_2=request("duoh_"&id&"_2")
					If duoh_2<>"" Then
						If duoh_1=1 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& duoh_2 &"%')"
'If duoh_1=1 Then
						Elseif duoh_1=2 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue not like '%"& duoh_2 &"%')"
'Elseif duoh_1=2 Then
						Elseif duoh_1=3 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& duoh_2 &"')"
'Elseif duoh_1=3 Then
						Elseif duoh_1=4 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue<>'"& duoh_2 &"')"
'Elseif duoh_1=4 Then
						Elseif duoh_1=5 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '"& duoh_2 &"%')"
'Elseif duoh_1=5 Then
						Elseif duoh_1=6 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& duoh_2 &"')"
'Elseif duoh_1=6 Then
						end if
					end if
				ElseIf rs_kz_zdy_2("FType")="3" Then
					date_1=request("date_"&id&"_1")
					date_2=request("date_"&id&"_2")
					str33=str33+"&date_"&id&"_1="+date_1
'date_2=request("date_"&id&"_2")
					str33=str33+"&date_"&id&"_2="+date_2
'date_2=request("date_"&id&"_2")
					If date_1<>"" or date_2<>"" Then
						If date_1<>"" Then
							sqldate=" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime) end)>=cast('"& date_1 &"'as datetime)"
'If date_1<>"" Then
						end if
						If date_2<>"" Then
							sqldate=sqldate&" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime) end)<=cast('"& date_2 &"' as datetime)"
'If date_2<>"" Then
						end if
						str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&""&sqldate&")"
'If date_2<>"" Then
					end if
				ElseIf rs_kz_zdy_2("FType")="4" Then
					Numr_1=request("Numr_"&id&"_1")
					Numr_2=request("Numr_"&id&"_2")
					str33=str33+"&Numr_"&id&"_1="+Numr_1
'Numr_2=request("Numr_"&id&"_2")
					str33=str33+"&Numr_"&id&"_2="+Numr_2
'Numr_2=request("Numr_"&id&"_2")
					If Numr_2<>"" Then
						If Numr_1=1 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& Numr_2 &"%')"
'If Numr_1=1 Then
						Elseif Numr_1=2 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue not like '%"& Numr_2 &"%')"
'Elseif Numr_1=2 Then
						Elseif Numr_1=3 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& Numr_2 &"')"
'Elseif Numr_1=3 Then
						Elseif Numr_1=4 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue<>'"& Numr_2 &"')"
'Elseif Numr_1=4 Then
						Elseif Numr_1=5 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '"& Numr_2 &"%')"
'Elseif Numr_1=5 Then
						Elseif Numr_1=6 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& Numr_2 &"')"
'Elseif Numr_1=6 Then
						end if
					end if
				ElseIf rs_kz_zdy_2("FType")="5" Then
					beiz_1=request("beiz_"&id&"_1")
					beiz_2=request("beiz_"&id&"_2")
					str33=str33+"&beiz_"&id&"_1="+beiz_1
'beiz_2=request("beiz_"&id&"_2")
					str33=str33+"&beiz_"&id&"_2="+beiz_2
					beiz_2=request("beiz_"&id&"_2")
					If beiz_2<>"" Then
						If beiz_1=1 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& beiz_2 &"%')"
'If beiz_1=1 Then
						Elseif beiz_1=2 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue not like '%"& beiz_2 &"%')"
'Elseif beiz_1=2 Then
						Elseif beiz_1=3 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& beiz_2 &"')"
'Elseif beiz_1=3 Then
						Elseif beiz_1=4 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue<>'"& beiz_2 &"')"
'Elseif beiz_1=4 Then
						Elseif beiz_1=5 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '"& beiz_2 &"%')"
'Elseif beiz_1=5 Then
						Elseif beiz_1=6 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& beiz_2 &"')"
'Elseif beiz_1=6 Then
						end if
					end if
				ElseIf rs_kz_zdy_2("FType")="6" Then
					IsNot_1=request("IsNot_"&id&"_1")
					str33=str33+"&IsNot_"&id&"_1="+IsNot_1
'IsNot_1=request("IsNot_"&id&"_1")
					If IsNot_1<>"" Then
						str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& IsNot_1 &"')"
'If IsNot_1<>"" Then
					end if
				else
					meju_1=request("meju_"&id&"_1")
					str33=str33+"&meju_"&id&"_1="+Server.Urlencode(meju_1)
'meju_1=request("meju_"&id&"_1")
					If meju_1<>"" Then
						str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& meju_1 &"')"
'If meju_1<>"" Then
					end if
				end if
				rs_kz_zdy_2.movenext
			Loop
		end if
		rs_kz_zdy_2.close
		Set rs_kz_zdy_2=Nothing
		pub_cf=str33
	end function
	Function Show_Extended_By_Type(TName,typ,ord,columns)
		Dim rs_kz_zdy, rs_kz_zdy_88, num1, i_jm, j_jm, classNamezdy, c_Value,sql,showWhere
		if columns="" or columns=0 then
			columns=3
		else
			columns=cint(columns)
		end if
		if typ="" then
			typ=0
		end if
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from ERP_CustomFields where TName='"&TName&"' and IsUsing=1 and del = 1 and FType in("&typ&") order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if Not rs_kz_zdy.eof then
			do until rs_kz_zdy.eof
				classNamezdy=""
				If rs_kz_zdy("FType")=5 Then classNamezdy="ywcss2"
				If i_jm=0 Then Response.write("<tr class='"&classNamezdy&"'>")
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr class='"&classNamezdy&"'>")
					j_jm=j_jm+1
					Response.write("</tr><tr class='"&classNamezdy&"'>")
				end if
				Set rs_kz_zdy_88=server.CreateObject("adodb.recordset")
				rs_kz_zdy_88.open "select case when b.ftype=3 and isnull(FValue,'')<>'' then convert(varchar(10),isnull(FValue,''),120) else isnull(FValue,'') end FValue from ERP_CustomValues a inner join ERP_CustomFields b on a.fieldsid = b.id where a.FieldsID='"&rs_kz_zdy("id")&"' and a.OrderID='"&ord&"' ",conn,1,1
				If Not rs_kz_zdy_88.eof Then
					c_Value=rs_kz_zdy_88("FValue")
					if rs_kz_zdy("FType")=2 then
						c_Value=replace(c_Value&"",Chr(13)&Chr(10),"<br>")
					end if
				else
					c_Value=""
				end if
				rs_kz_zdy_88.close
				Set rs_kz_zdy_88=nothing
				Response.write "" & vbcrlf & "                     <td align=""right"" height=""25"">"
				Response.write rs_kz_zdy("FName")
				Response.write "：</td>" & vbcrlf & "                      <td "
				if i_jm=num1-1  then
					Response.write "：</td>" & vbcrlf & "                      <td "
					Response.write "colspan="""
					Response.write 1+2*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """"
				end if
				Response.write " class=""gray ewebeditorImg"">&nbsp;"
				Response.write c_Value
				Response.write "</td>" & vbcrlf & "                        "
				i_jm=i_jm+1
				Response.write "</td>" & vbcrlf & "                        "
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function Show_Extended_By_TypeDeal(TName,typ,ord,columns,repID)
		Dim rs_kz_zdy, rs_kz_zdy_88, num1, i_jm, j_jm, classNamezdy, c_Value,sql,showWhere
		if columns="" or columns=0 then
			columns=3
		else
			columns=cint(columns)
		end if
		if typ="" then
			typ=0
		end if
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from Copy_CustomFields where TName='"&TName&"' AND RepairOrder = "&repID&" and IsUsing=1 and del = 1 and FType in("&typ&") order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if Not rs_kz_zdy.eof then
			do until rs_kz_zdy.eof
				classNamezdy=""
				If rs_kz_zdy("FType")=5 Then classNamezdy="ywcss2"
				If i_jm=0 Then Response.write("<tr class='"&classNamezdy&"'>")
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr class='"&classNamezdy&"'>")
					j_jm=j_jm+1
					Response.write("</tr><tr class='"&classNamezdy&"'>")
				end if
				Set rs_kz_zdy_88=server.CreateObject("adodb.recordset")
				rs_kz_zdy_88.open "select isnull(FValue,'') FValue from ERP_CustomValues where FieldsID='"&rs_kz_zdy("id")&"' and OrderID='"&ord&"' ",conn,1,1
				If Not rs_kz_zdy_88.eof Then
					c_Value=rs_kz_zdy_88("FValue")
					if rs_kz_zdy("FType")=2 then
						c_Value=replace(c_Value&"",Chr(13)&Chr(10),"<br>")
					end if
				else
					c_Value=""
				end if
				rs_kz_zdy_88.close
				Set rs_kz_zdy_88=nothing
				Response.write "" & vbcrlf & "                     <td align=""right"" height=""25"">"
				Response.write rs_kz_zdy("FName")
				Response.write "：</td>" & vbcrlf & "                      <td "
				if i_jm=num1-1  then
					Response.write "：</td>" & vbcrlf & "                      <td "
					Response.write "colspan="""
					Response.write 1+2*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """"
				end if
				Response.write " class=""gray ewebeditorImg"">"
				Response.write c_Value
				Response.write "&nbsp;</td>" & vbcrlf & "                  "
				i_jm=i_jm+1
				Response.write "&nbsp;</td>" & vbcrlf & "                  "
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function Show_Extended_By_TypeDealBZ(TName,typ,ord,columns,repID)
		Dim rs_kz_zdy, rs_kz_zdy_88, num1, i_jm, j_jm, classNamezdy, c_Value,sql,showWhere
		if columns="" or columns=0 then
			columns=3
		else
			columns=cint(columns)
		end if
		if typ="" then
			typ=0
		end if
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from Copy_CustomFields where TName='"&TName&"' AND RepairOrder = "&repID&" and IsUsing=1 and del = 1 and FType in("&typ&") order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if Not rs_kz_zdy.eof then
			do until rs_kz_zdy.eof
				classNamezdy=""
				If rs_kz_zdy("FType")=5 Then classNamezdy="ywcss2"
				Response.write("<tr class='"&classNamezdy&"'>")
				Set rs_kz_zdy_88=server.CreateObject("adodb.recordset")
				rs_kz_zdy_88.open "select isnull(FValue,'') FValue from ERP_CustomValues where FieldsID='"&rs_kz_zdy("id")&"' and OrderID='"&ord&"' ",conn,1,1
				If Not rs_kz_zdy_88.eof Then
					c_Value=rs_kz_zdy_88("FValue")
					if rs_kz_zdy("FType")=2 then
						c_Value=replace(c_Value&"",Chr(13)&Chr(10),"<br>")
					end if
				else
					c_Value=""
				end if
				rs_kz_zdy_88.close
				Set rs_kz_zdy_88=nothing
				Response.write "" & vbcrlf & "                     <td align=""right"" height=""25"">"
				Response.write rs_kz_zdy("FName")
				Response.write "：</td>" & vbcrlf & "                        <td colspan="""
				Response.write columns
				Response.write """ class=""gray ewebeditorImg"">"
				Response.write c_Value
				Response.write "&nbsp;</td>" & vbcrlf & "                    "
				i_jm=i_jm+1
				Response.write "&nbsp;</td>" & vbcrlf & "                    "
				Response.write("</tr>")
				rs_kz_zdy.movenext
			loop
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function Show_Extended_By_Type2(TName,typ,ord,columns,sort1,filed1)
		Dim rs_kz_zdy, rs_kz_zdy_88, num1, i_jm, j_jm, classNamezdy, c_Value, FVID
		if columns="" or columns=0 then
			columns=3
		else
			columns=cint(columns)
		end if
		if typ="" then
			typ=0
		end if
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from ERP_CustomFields where TName='"&TName&"' and IsUsing=1 and del=1 and FType in("&typ&") order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if Not rs_kz_zdy.eof then
			do until rs_kz_zdy.eof
				classNamezdy=""
				If rs_kz_zdy("FType")=5 Then classNamezdy="ywcss2"
				If i_jm=0 Then Response.write("<tr class='"&classNamezdy&"'>")
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr class='"&classNamezdy&"'>")
					j_jm=j_jm+1
					Response.write("</tr><tr class='"&classNamezdy&"'>")
				end if
				Set rs_kz_zdy_88=server.CreateObject("adodb.recordset")
				rs_kz_zdy_88.open "select isnull(FValue,'') FValue,id from ERP_CustomValues where FieldsID='"&rs_kz_zdy("id")&"' and OrderID='"&ord&"' ",conn,1,1
				If Not rs_kz_zdy_88.eof Then
					c_Value=rs_kz_zdy_88("FValue")
					FVID = rs_kz_zdy_88("id")
					if rs_kz_zdy("FType")=2 then
						c_Value=replace(c_Value&"",Chr(13)&Chr(10),"<br>")
					end if
				else
					c_Value=""
				end if
				rs_kz_zdy_88.close
				Set rs_kz_zdy_88=Nothing
				If FVID&"" = "" Then FVID=0
				Response.write "" & vbcrlf & "                      <td align=""right"" height=""25"">"
				Response.write rs_kz_zdy("FName")
				Response.write "：</td>" & vbcrlf & "                       <td "
				if i_jm=num1-1  then
					Response.write "：</td>" & vbcrlf & "                       <td "
					Response.write "colspan="""
					Response.write 1+2*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """"
				end if
				Response.write " class=""gray ewebeditorImg"">"
				If rs_kz_zdy("FType")=5 Then
					If c_Value&""<>"" Then
						Dim arr_img
						arr_img = split(c_Value,"<img",-1,1)
'Dim arr_img
						if ubound(arr_img)>0 then
							Response.write "" & vbcrlf & "                                              <a href=""javascript:;"" onClick=""window.open('info.asp?ord="
							Response.write app.base64.pwurl(FVID)
							Response.write "&sort1="
							Response.write sort1
							Response.write "&sort2="
							Response.write filed1
							Response.write "','neww6768999in','width=' + 1600 + ',height=' + 800 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=0,top=150');return false;"" onMouseOver=""window.status='none';return true;"" title=""放大查看"">"
							Response.write filed1
							Response.write c_Value
							Response.write "</a>" & vbcrlf & "                           "
						else
							Response.write(c_Value)
						end if
					end if
				else
					Response.write c_Value
				end if
				Response.write "&nbsp;</td>" & vbcrlf & "                   "
				i_jm=i_jm+1
				Response.write "&nbsp;</td>" & vbcrlf & "                   "
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function Del_Extended_Value(TName,ord)
		if ord="" Then ord=0
		sql="delete from ERP_CustomValues where id in(select b.id from ERP_CustomFields  a " _
		& " left join ERP_CustomValues b on a.id=b.fieldsid " _
		& " where a.tname='"&TName&"' and b.orderid in("&ord&")) "
		conn.execute(sql)
	end function
	Function Show_Search_Extended(TName)
		set rs_kz_zdy_2=server.CreateObject("adodb.recordset")
		sql2="select * from ERP_CustomFields where TName='"&TName&"' and IsUsing=1 and del=1 and CanSearch=1 order by FOrder asc "
		rs_kz_zdy_2.open sql2,conn,1,1
		if rs_kz_zdy_2.eof then
		else
			do until rs_kz_zdy_2.eof
				Response.write "" & vbcrlf & "                     <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td align=""right"">"
				Response.write rs_kz_zdy_2("FName")
				Response.write "：</td>" & vbcrlf & "                      <td align=""left"">" & vbcrlf & "                 "
				If rs_kz_zdy_2("FType")="1" then
					Response.write "" & vbcrlf & "                             <select name=""danh_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"">" & vbcrlf & "                              <option value=""1"">包含</option>" & vbcrlf & "                           <option value=""2"">不包含</option>" & vbcrlf & "                         <option value=""3"">等于</option>" & vbcrlf & "                           <option value=""4"">不等于</option>" & vbcrlf & "                         <option value=""5"">以..开始</option>" & vbcrlf & "                               <option value=""6"">以..结束</option>" & vbcrlf & "                             </select>" & vbcrlf & "                               <input name=""danh_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_2"" type=""text"" size=""15"">" & vbcrlf & "                            "
				ElseIf rs_kz_zdy_2("FType")="2" Then
					Response.write "" & vbcrlf & "                             <select name=""duoh_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"">" & vbcrlf & "                              <option value=""1"">包含</option>" & vbcrlf & "                           <option value=""2"">不包含</option>" & vbcrlf & "                         <option value=""3"">等于</option>" & vbcrlf & "                           <option value=""4"">不等于</option>" & vbcrlf & "                         <option value=""5"">以..开始</option>" & vbcrlf & "                               <option value=""6"">以..结束</option>" & vbcrlf & "                             </select>" & vbcrlf & "                               <input name=""duoh_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_2"" type=""text"" size=""15"">" & vbcrlf & "                            "
				ElseIf rs_kz_zdy_2("FType")="3" then
					Response.write "" & vbcrlf & "                             <INPUT name=""date_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"" size=""11""  id=""date_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"" onmouseup=toggleDatePicker(""paydate1div_"
					Response.write rs_kz_zdy_2("id")
					Response.write """,""date.date_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"")><DIV id=""paydate1div_"
					Response.write rs_kz_zdy_2("id")
					Response.write """ style=""POSITION: absolute"" name =""paydate1div_"
					Response.write rs_kz_zdy_2("id")
					Response.write """></DIV>&nbsp;-&nbsp;<INPUT name=""date_"
					Response.write rs_kz_zdy_2("id")
					Response.write rs_kz_zdy_2("id")
					Response.write "_2"" size=""11"" id=""date_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_2"" onmouseup=toggleDatePicker(""paydate2div_"
					Response.write rs_kz_zdy_2("id")
					Response.write """,""date.date_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_2"")><DIV id=""paydate2div_"
					Response.write rs_kz_zdy_2("id")
					Response.write """ style=""POSITION: absolute"" name =""paydate2div_"
					Response.write rs_kz_zdy_2("id")
					Response.write """></DIV>" & vbcrlf & "                          "
				ElseIf rs_kz_zdy_2("FType")="4" then
					Response.write "" & vbcrlf & "                             <select name=""Numr_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"">" & vbcrlf & "                              <option value=""1"">包含</option>" & vbcrlf & "                           <option value=""2"">不包含</option>" & vbcrlf & "                         <option value=""3"">等于</option>" & vbcrlf & "                           <option value=""4"">不等于</option>" & vbcrlf & "                         <option value=""5"">以..开始</option>" & vbcrlf & "                               <option value=""6"">以..结束</option>" & vbcrlf & "                             </select>" & vbcrlf & "                               <input name=""Numr_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_2"" type=""text"" size=""15"">" & vbcrlf & "                            "
				ElseIf rs_kz_zdy_2("FType")="5" then
					Response.write "" & vbcrlf & "                             <select name=""beiz_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"">" & vbcrlf & "                              <option value=""1"">包含</option>" & vbcrlf & "                           <option value=""2"">不包含</option>" & vbcrlf & "                         <option value=""3"">等于</option>" & vbcrlf & "                           <option value=""4"">不等于</option>" & vbcrlf & "                         <option value=""5"">以..开始</option>" & vbcrlf & "                               <option value=""6"">以..结束</option>" & vbcrlf & "                             </select>" & vbcrlf & "                               <input name=""beiz_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_2"" type=""text"" size=""15"">" & vbcrlf & "                            "
				ElseIf rs_kz_zdy_2("FType")="6" then
					Response.write "" & vbcrlf & "                             <select name=""IsNot_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"">" & vbcrlf & "                              <option value="""">选择</option>" & vbcrlf & "                            <option value=""是"">是</option>" & vbcrlf & "                            <option value=""否"">否</option>" & vbcrlf & "                            </select>" & vbcrlf & "                               "
				else
					Response.write "" & vbcrlf & "                             <select name=""meju_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"">" & vbcrlf & "                              <option value="""">选择</option>" & vbcrlf & "                            "
					Set rs_kz_zdy_8=server.CreateObject("adodb.recordset")
					rs_kz_zdy_8.open "select * from ERP_CustomOptions where CFID="&rs_kz_zdy_2("id")&" ",conn,1,1
					If Not rs_kz_zdy_8.eof Then
						Do While Not rs_kz_zdy_8.eof
							Response.write "" & vbcrlf & "                                             <option value="""
							Response.write rs_kz_zdy_8("CValue")
							Response.write """>"
							Response.write rs_kz_zdy_8("CValue")
							Response.write "</option>" & vbcrlf & "                                            "
							rs_kz_zdy_8.movenext
						Loop
					end if
					rs_kz_zdy_8.close
					Set rs_kz_zdy_8=nothing
					Response.write "" & vbcrlf & "                             </select>" & vbcrlf & "                               "
				end if
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
				rs_kz_zdy_2.movenext
			loop
		end if
		rs_kz_zdy_2.close
		set rs_kz_zdy_2=Nothing
	end function
	Function Show_Search_Extended_Simple(TName)
		set rs_kz_zdy_2=server.CreateObject("adodb.recordset")
		sql2="select * from ERP_CustomFields where TName='"&TName&"' and IsUsing=1 and del=1 and CanSearch=1 order by FOrder asc "
		rs_kz_zdy_2.open sql2,conn,1,1
		if rs_kz_zdy_2.eof =False then
			do until rs_kz_zdy_2.eof
				Response.write "" & vbcrlf & "                     <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td align=""right"">"
				Response.write rs_kz_zdy_2("FName")
				Response.write "：</td>" & vbcrlf & "                      <td align=""left"">" & vbcrlf & "                 "
				Select Case rs_kz_zdy_2("FType")
				Case "1" :
				Response.write "" & vbcrlf & "                             <input name=""danh_"
				Response.write rs_kz_zdy_2("id")
				Response.write """ type=""text"" size=""15"">" & vbcrlf & "                              "
				Case "2" :
				Response.write "" & vbcrlf & "                             <input name=""duoh_"
				Response.write rs_kz_zdy_2("id")
				Response.write """ type=""text"" size=""15"">" & vbcrlf & "                              "
				Case "3" :
				Response.write "" & vbcrlf & "                             <INPUT name=""date_"
				Response.write rs_kz_zdy_2("id")
				Response.write "_1"" size=""11""  id=""date_"
				Response.write rs_kz_zdy_2("id")
				Response.write "_1"" onmouseup=toggleDatePicker(""paydate1div_"
				Response.write rs_kz_zdy_2("id")
				Response.write """,""date.date_"
				Response.write rs_kz_zdy_2("id")
				Response.write "_1"")><DIV id=""paydate1div_"
				Response.write rs_kz_zdy_2("id")
				Response.write """ style=""POSITION: absolute"" name =""paydate1div_"
				Response.write rs_kz_zdy_2("id")
				Response.write """></DIV>&nbsp;-&nbsp;<INPUT name=""date_"
				Response.write rs_kz_zdy_2("id")
				Response.write rs_kz_zdy_2("id")
				Response.write "_2"" size=""11"" id=""date_"
				Response.write rs_kz_zdy_2("id")
				Response.write "_2"" onmouseup=toggleDatePicker(""paydate2div_"
				Response.write rs_kz_zdy_2("id")
				Response.write """,""date.date_"
				Response.write rs_kz_zdy_2("id")
				Response.write "_2"")><DIV id=""paydate2div_"
				Response.write rs_kz_zdy_2("id")
				Response.write """ style=""POSITION: absolute"" name =""paydate2div_"
				Response.write rs_kz_zdy_2("id")
				Response.write """></DIV>" & vbcrlf & "                          "
				Case "4" :
				Response.write "" & vbcrlf & "                             <input name=""Numr_"
				Response.write rs_kz_zdy_2("id")
				Response.write """ type=""text"" size=""15"">" & vbcrlf & "                              "
				Case "5" :
				Response.write "" & vbcrlf & "                             <input name=""beiz_"
				Response.write rs_kz_zdy_2("id")
				Response.write """ type=""text"" size=""15"">" & vbcrlf & "                              "
				Case "6" :
				Response.write "" & vbcrlf & "                             <select name=""IsNot_"
				Response.write rs_kz_zdy_2("id")
				Response.write """>" & vbcrlf & "                                <option value="""">选择</option>" & vbcrlf & "                            <option value=""是"">是</option>" & vbcrlf & "                            <option value=""否"">否</option>" & vbcrlf & "                            </select>" & vbcrlf & "                               "
				Case Else
				Response.write "" & vbcrlf & "                             <select name=""meju_"
				Response.write rs_kz_zdy_2("id")
				Response.write """>" & vbcrlf & "                                <option value="""">选择</option>" & vbcrlf & "                            "
				Set rs_kz_zdy_8=server.CreateObject("adodb.recordset")
				rs_kz_zdy_8.open "select * from ERP_CustomOptions where CFID="&rs_kz_zdy_2("id")&" ",conn,1,1
				If Not rs_kz_zdy_8.eof Then
					Do While Not rs_kz_zdy_8.eof
						Response.write "" & vbcrlf & "                                             <option value="""
						Response.write rs_kz_zdy_8("CValue")
						Response.write """>"
						Response.write rs_kz_zdy_8("CValue")
						Response.write "</option>" & vbcrlf & "                                            "
						rs_kz_zdy_8.movenext
					Loop
				end if
				rs_kz_zdy_8.close
				Set rs_kz_zdy_8=nothing
				Response.write "" & vbcrlf & "                             </select>" & vbcrlf & "                               "
				End Select
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
				rs_kz_zdy_2.movenext
			loop
		end if
		rs_kz_zdy_2.close
		set rs_kz_zdy_2=Nothing
	end function
	Function searchExtended_Simple(TName,keycode)
		Dim rs_kz_zdy_2 ,searchsql
		set rs_kz_zdy_2=server.CreateObject("adodb.recordset")
		Dim sql2 : sql2="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 and CanSearch=1 order by FOrder asc "
		Dim str33,id,danh,Numr,beiz,IsNot_1,meju,duoh,date_1,date_2
		rs_kz_zdy_2.open sql2,conn,1,1
		if rs_kz_zdy_2.eof=False then
			str33=""
			do until rs_kz_zdy_2.eof
				id=rs_kz_zdy_2("id")
				Select Case rs_kz_zdy_2("FType")
				Case "1" :
				danh=request("danh_"&id&"")
				str33=str33+"&danh_"&id&"="+danh
'danh=request("danh_"&id&"")
				If danh<>"" Then
					searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& danh &"%')"
'If danh<>"" Then
				end if
				Case "2" :
				duoh=request("duoh_"&id&"")
				str33=str33+"&duoh_"&id&"="+duoh
'duoh=request("duoh_"&id&"")
				If duoh<>"" Then
					searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& duoh &"%')"
'If duoh<>"" Then
				end if
				Case "3" :
				date_1=request("date_"&id&"_1")
				date_2=request("date_"&id&"_2")
				str33=str33+"&date_"&id&"_1="+date_1
'date_2=request("date_"&id&"_2")
				str33=str33+"&date_"&id&"_2="+date_2
'date_2=request("date_"&id&"_2")
				If date_1<>"" or date_2<>"" Then
					Dim sqldate
					If date_1<>"" Then
						sqldate=" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime) end)>=cast('"& date_1 &"'as datetime)"
'If date_1<>"" Then
					end if
					If date_2<>"" Then
						sqldate=sqldate&" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime) end)<=cast('"& date_2 &"' as datetime)"
'If date_2<>"" Then
					end if
					searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" "&sqldate&")"
'If date_2<>"" Then
				end if
				Case "4" :
				Numr=request("Numr_"&id&"")
				str33=str33+"&Numr_"&id&"="+Numr
'Numr=request("Numr_"&id&"")
				If Numr<>"" Then
					searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& Numr &"%')"
'If Numr<>"" Then
				end if
				Case "5" :
				beiz=request("beiz_"&id&"")
				str33=str33+"&beiz_"&id&"="+beiz
'beiz=request("beiz_"&id&"")
				If beiz<>"" Then
					searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& beiz &"%')"
'If beiz<>"" Then
				end if
				Case "6" :
				IsNot_1=request("IsNot_"&id&"")
				str33=str33+"&IsNot_"&id&"_1="+IsNot_1
'IsNot_1=request("IsNot_"&id&"")
				If IsNot_1<>"" Then
					searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& IsNot_1 &"')"
'If IsNot_1<>"" Then
				end if
				Case Else
				meju=request("meju_"&id&"")
				str33=str33+"&meju_"&id&"="+Server.Urlencode(meju)
'meju=request("meju_"&id&"")
				If meju<>"" Then
					searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& meju &"')"
'If meju<>"" Then
				end if
				End Select
				rs_kz_zdy_2.movenext
			Loop
		end if
		rs_kz_zdy_2.close
		Set rs_kz_zdy_2=Nothing
		pub_cf=str33
		searchExtended_Simple=searchsql
	end function
	Sub Export_xls_Extended(TName,typ,cols,columns,ord)
		IF typ=1 then
			set rs_kz_zdy=server.CreateObject("adodb.recordset")
			kz_sql="select 1 from erp_customFields  where TName='"&TName&"'  and IsUsing=1 and del=1 and canExport=1 order by FOrder asc"
			rs_kz_zdy.open kz_sql,conn,1,1
			do while not rs_kz_zdy.eof
				xlApplication.ActiveSheet.columns(columns).columnWidth=15
				xlApplication.ActiveSheet.columns(columns).HorizontalAlignment=3
				rs_kz_zdy.movenext
				columns=columns+1
'rs_kz_zdy.movenext
			loop
			rs_kz_zdy.close
			set rs_kz_zdy=nothing
		ElseIf typ=2 then
			set rs_kz_zdy=server.CreateObject("adodb.recordset")
			kz_sql="select FName from erp_customFields  where TName='"&TName&"' and IsUsing=1 and del=1 and canExport=1 order by FOrder asc"
			rs_kz_zdy.open kz_sql,conn,1,1
			do while not rs_kz_zdy.eof
				xlWorksheet.Cells(1,columns).Value = rs_kz_zdy("FName")
				xlWorksheet.Cells(1,columns).font.Size=10
				xlWorksheet.Cells(1,columns).font.bold=true
				rs_kz_zdy.movenext
				columns=columns+1
				rs_kz_zdy.movenext
			loop
			rs_kz_zdy.close
			set rs_kz_zdy =nothing
		ElseIf typ=3 then
			set rs_kz_zdy=server.CreateObject("adodb.recordset")
			kz_sql="select b.FValue from erp_customFields a left join (select fieldsid,fvalue,orderid from erp_customValues where orderid='"&ord&"') b " _
			& " on b.fieldsid=a.id where a.TName='"&TName&"' and a.IsUsing=1 and a.canExport=1 order by a.FOrder asc"
			rs_kz_zdy.open kz_sql,conn,1,1
			do while not rs_kz_zdy.eof
				xlWorksheet.Cells(1+cols,columns).Value = rs_kz_zdy("FValue")
'do while not rs_kz_zdy.eof
				xlWorksheet.Cells(1+cols,columns).font.Size=10
'do while not rs_kz_zdy.eof
				rs_kz_zdy.movenext
				columns=columns+1
				rs_kz_zdy.movenext
			loop
			rs_kz_zdy.close
			set rs_kz_zdy=nothing
		end if
	end sub
	Function dyExtended(TName,columns)
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		kz_sql="select * from ERP_CustomFields where TName="&TName&" and IsUsing=1 and del=1 order by FOrder asc "
		rs_kz_zdy.open kz_sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if rs_kz_zdy.eof then
		else
			Response.write("<table width='100%' border='0' cellpadding='0' cellspacing='0' id='content2' bgcolor='#000000'>")
			Response.write("<tr>")
			do until rs_kz_zdy.eof
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr>")
					j_jm=j_jm+1
					Response.write("</tr><tr>")
				end if
				Response.write "" & vbcrlf & "                     <td width=""42%"" height=""27"" "
				if i_jm=num1-1  then
					Response.write "" & vbcrlf & "                     <td width=""42%"" height=""27"" "
					Response.write "colspan="""
					Response.write 1+2*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """"
				end if
				Response.write ">" & vbcrlf & "                            {"
				Response.write rs_kz_zdy("fname")
				Response.write ":<span title=""点击复制"
				Response.write rs_kz_zdy("fname")
				Response.write """ id=""zdy"
				Response.write rs_kz_zdy("id")
				Response.write """ onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_"
				Response.write rs_kz_zdy("id")
				Response.write "_E</span>}" & vbcrlf & "                   " & vbcrlf & "                        </td>" & vbcrlf & "                   "
				i_jm=i_jm+1
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
			Response.write("</table>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function dyMxExtended(TName,columns)
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		If TName = 28 Then
			kz_sql="select a.id,a.fname,b.sort1 from ERP_CustomFields a inner join sortonehy b on b.ord+200000 = a.tname and b.gate2=3001 and b.del=1 and b.isStop = 0 and a.FType<>'5' and a.id>0 ORDER BY FOrder asc,a.id "
'If TName = 28 Then
		else
			kz_sql="select * from ERP_CustomFields where TName="&TName&" and IsUsing=1 and del=1 order by FOrder asc "
		end if
		rs_kz_zdy.open kz_sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if rs_kz_zdy.eof then
		else
			Response.write("<table width='100%' border='0' cellpadding='0' cellspacing='0' id='content2' bgcolor='#000000'>")
			Response.write("<tr>")
			do until rs_kz_zdy.eof
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr>")
					j_jm=j_jm+1
					Response.write("</tr><tr>")
				end if
				Response.write "" & vbcrlf & "                     <td width=""42%"" height=""27"" "
				if i_jm=num1-1  then
					Response.write "" & vbcrlf & "                     <td width=""42%"" height=""27"" "
					Response.write "colspan="""
					Response.write 1+2*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """"
				end if
				Response.write ">" & vbcrlf & "                            {"
				Response.write rs_kz_zdy("fname")
				Response.write "["
				Response.write rs_kz_zdy("sort1")
				Response.write "]：<span title=""点击复制"
				Response.write rs_kz_zdy("fname")
				Response.write """ id=""zdy"
				Response.write rs_kz_zdy("id")
				Response.write """ onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">Extended_"
				Response.write rs_kz_zdy("id")
				Response.write "_E</span>}" & vbcrlf & "                   " & vbcrlf & "                        </td>" & vbcrlf & "                   "
				i_jm=i_jm+1
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
			Response.write("</table>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function dyExtended_kz(TName,columns)
		Response.write "" & vbcrlf & "     <table width='100%' border='0' cellpadding='4' cellspacing='1' id='content2' bgcolor='#C0CCDD'>" & vbcrlf & "         <tr class=top><td colspan="""
		Response.write columns
		Response.write """><strong>【公共字段】</strong></td></tr>" & vbcrlf & "         <td width=""33%"" height=""27"">{税号:<span title=""点击复制税号"" id=""zdy_taxno"" onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_taxno_E</span>}</td>" & vbcrlf & "           "
		If columns = 1 Then Response.write "</tr><tr>"
		Response.write "" & vbcrlf & "             <td width=""33%"" height=""27"">{公司地址:<span title=""点击复制公司地址"" id=""zdy_addr"" onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_addr_E</span>}</td>" & vbcrlf & "             "
		If 2 mod columns = 0 Then Response.write "</tr><tr>"
		Response.write "" & vbcrlf & "             <td width=""33%"" height=""27"">{公司电话:<span title=""点击复制公司电话"" id=""zdy_phone"" onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_phone_E</span>}</td>" & vbcrlf & "           "
		If 3 mod columns = 0 Then Response.write "</tr><tr>"
		Response.write "" & vbcrlf & "             <td width=""33%"" height=""27"">{开户行:<span title=""点击复制开户行"" id=""zdy_bank"" onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_bank_E</span>}</td>" & vbcrlf & "         "
		If 4 mod columns = 0 Then Response.write "</tr><tr>"
		Response.write "" & vbcrlf & "             <td width=""33%"" height=""27"">{开户行账号:<span title=""点击复制开户行账号"" id=""zdy_account"" onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_account_E</span>}</td>" & vbcrlf & "           "
		If 5 mod columns = 0 Then
			Response.write "</tr>"
		else
			Response.write "<td colspan="&(columns-(5 mod columns))&"></td></tr>"
			Response.write "</tr>"
		end if
		Set rs =conn.execute("select ord,sort1 from sortonehy where gate2="&TName&" and isnull(id1,0)=0")
		If rs.eof= False Then
			While rs.eof = False
				set rs_kz_zdy=server.CreateObject("adodb.recordset")
				kz_sql="select * from ERP_CustomFields where TName="&(rs("ord")*1+100000)&" and IsUsing=1 and del=1 order by FOrder asc "
'set rs_kz_zdy=server.CreateObject("adodb.recordset")
				rs_kz_zdy.open kz_sql,conn,1,1
				if rs_kz_zdy.eof= False Then
					Response.write "<tr class=top><td colspan="""
					Response.write columns
					Response.write """><strong>【"
					Response.write rs("sort1")
					Response.write "】</strong></td></tr>"
					num1 = 0
					do until rs_kz_zdy.eof
						If num1 Mod columns = 0 Then Response.write "<tr>"
						Response.write "" & vbcrlf & "                                              <td width=""33%"" height=""27"">" & vbcrlf & "                                                        {"
						Response.write rs_kz_zdy("fname")
						Response.write ":<span title=""点击复制"
						Response.write rs_kz_zdy("fname")
						Response.write """ id=""zdy"
						Response.write rs_kz_zdy("id")
						Response.write """ onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_"
						Response.write rs_kz_zdy("id")
						Response.write "_E</span>}                                    " & vbcrlf & "                                                </td>" & vbcrlf & "                                           "
						num1=num1+1
						If num1 Mod columns = 0 Then Response.write "</tr>"
						rs_kz_zdy.movenext
					Loop
					If num1 Mod columns > 0  Then Response.write "<td colspan="&columns-(num1 Mod columns)&"></td></tr>"
'Loop
				end if
				rs_kz_zdy.close
				set rs_kz_zdy=Nothing
				rs.movenext
			wend
		end if
		rs.close
		Response.write "" & vbcrlf & "      </table>" & vbcrlf & "        "
	end function
	Function isUsingExtend(TName)
		Dim rs,sql
		Set rs = server.CreateObject("adodb.recordset")
		sql =        "SELECT TOP 1 ID FROM ERP_CustomFields WHERE TName = "& TName &" AND IsUsing=1 AND del=1 AND FType <> '5' " &_
		"UNION " &_
		"SELECT TOP 1 ID FROM zdy WHERE sort1 = "& TName &" AND set_open = 1"
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			isUsingExtend = True
		else
			isUsingExtend = False
		end if
		rs.close
		set rs = nothing
	end function
	Function getExtendedCount(TName)
		getExtendedCount = sdk.getSqlValue("select count(1) from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1", 0)
	end function
	Function showExtended_byListHeader(TName, ord, classStr)
		dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7
		sql="select FName from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 order by FOrder asc "
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		rs_kz_zdy.open sql,conn,1,1
		While rs_kz_zdy.eof = False
			Response.write "" & vbcrlf & "              <td width=""11%"" align=""center"" "
			Response.write classStr
			Response.write ">"
			Response.write rs_kz_zdy("FName")
			Response.write "</td>" & vbcrlf & " "
			rs_kz_zdy.movenext
		wend
		rs_kz_zdy.close
		Set rs_kz_zdy = Nothing
	end function
	Function showExtended_byLIsttdStr(TName, ord, classStr)
		dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7, retStr
		retStr = ""
		sql="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 order by FOrder asc "
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		rs_kz_zdy.open sql,conn,1,1
		While rs_kz_zdy.eof = False
			retStr = retStr & "<td height=""30"" width=""10%"" class="""& classStr &""">"
			if rs_kz_zdy("FType")="1" Then
				retStr = retStr & "<input name=""danh_"& rs_kz_zdy("id") &""" type=""text"" size=""15"" id=""danh_"& rs_kz_zdy("id") &""" value="""& c_Value &""" dataType=""Limit"""
				if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then retStr = retStr & " min=""1"""
				retStr = retStr & " max=""500""  msg=""必须在1到500个字符"" maxlength=""4000"">"
			Elseif rs_kz_zdy("FType")="2" then
				retStr = retStr & "<textarea name=""duoh_"& rs_kz_zdy("id") &""" id=""duoh_"& rs_kz_zdy("id") &""" style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px"" onfocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" dataType=""Limit"""
				if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then retStr = retStr & " min=""1"" "
				retStr = retStr & "max=""500""  msg=""必须在1到500个字符"">"& c_Value &"</textarea>"
			elseif rs_kz_zdy("FType")="3" Then
				retStr = retStr & "<input readonly name=""date_"& rs_kz_zdy("id") &""" value="""& c_Value &""" size=""15"" id=""daysOfMonthPos"" onmouseup=""toggleDatePicker('daysOfMonth_"& rs_kz_zdy("id") &"','date_"& rs_kz_zdy("id") &"')"" dataType=""Limit"""
				if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then retStr = retStr & " min=""1"""
				retStr = retStr & " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:right;background-repeat:no-repeat;""> <div id=""daysOfMonth_"& rs_kz_zdy("id") &""" style=""POSITION:absolute""></div>"
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then retStr = retStr & " min=""1"""
			ElseIf rs_kz_zdy("FType")="4" then
				retStr = retStr & "<input name=""Numr_"& rs_kz_zdy("id") &""" type=""text"" value="""& c_Value &""" size=""8"" id=""Numr_"& rs_kz_zdy("id") &""" onkeyup=""value=value.replace(/[^\d\.]/g,'')"" dataType=""Limit"""
				if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then retStr = retStr & " min=""1"" "
				retStr = retStr & "max=""500""  msg=""必须在1到500个字符"" >"
			Elseif rs_kz_zdy("FType")="5" then
				retStr = retStr & "<textarea name=""beiz_"& rs_kz_zdy("id") &""" id=""beiz_"& rs_kz_zdy("id") &""" style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px"" onfocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" dataType=""Limit"""
				if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then retStr = retStr & " min=""1"""
				retStr = retStr & "max=""500""  msg=""必须在1到500个字符"">"& c_Value &"</textarea>"
			ElseIf rs_kz_zdy("FType")="6" then
				retStr = retStr & "<select name=""IsNot_"& rs_kz_zdy("id") &""" id=""IsNot_"& rs_kz_zdy("id") &"""  dataType=""Limit"""
				if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then retStr = retStr & " min=""1"""
				retStr = retStr & " max=""500""  msg=""必须在1到500个字符"">"
				retStr = retStr & "<option value=""是"""
				If c_Value="是" Then retStr = retStr & " selected"
				retStr = retStr & ">是</option>"
				retStr = retStr & "<option value=""否"""
				If c_Value="否" Then retStr = retStr & "selected"
				retStr = retStr & ">否</option>"
				retStr = retStr & "</select>"
			ElseIf rs_kz_zdy("FType")="7" then
				retStr = retStr & "<select name=""meju_" & rs_kz_zdy("id") &""" id=""meju_"& rs_kz_zdy("id") &"""  dataType=""Limit"""
				if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then retStr = retStr & " min=""1"""
				retStr = retStr & " max=""500""  msg=""必须在1到500个字符"">"
				set rs7=conn.execute("select id,CValue from ERP_CustomOptions where CFID="&rs_kz_zdy("id")&" order by id asc ")
				do until rs7.eof
					retStr = retStr & "<option value="""& rs7("id") &""""
					If rs7("CValue")=c_Value Then retStr = retStr & " selected"
					retStr = retStr & ">"& rs7("CValue") &"</option>"
					rs7.movenext
				loop
				rs7.close
				retStr = retStr & "</select>"
			end if
			if  rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then
				retStr = retStr & "&nbsp;<span class=""red"">*</span>"
			end if
			retStr = retStr & "</td>"
			rs_kz_zdy.movenext
		wend
		rs_kz_zdy.close
		Set rs_kz_zdy = Nothing
		showExtended_byLIsttdStr = retStr
	end function
	Function getExtendedValue(c_Value,priceDigits)
		if c_Value ="" then
			getExtendedValue=""
		else
			getExtendedValue=FormatNumber(zbcdbl(c_Value),priceDigits,-1,0,0)
			getExtendedValue=""
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
			Me.clsId = 8040
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
				Case "chance", "payout"
				Case "caigou"
				Me.con.execute("update caigou set sp=-1,cateid_sp='',del=3 where ord = "& billID)
				Case "caigou"
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
		currLevel = 0
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
			inx = 0
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
				call ApproveLog(conn, BillType, BillID ,ApproveSort, ApproveID, ApproveName , ApproveCateID , result , intro)
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
				conn.execute sqltext
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
			If taxRate&"" = "" Then taxRate = 0 Else taxRate = CDbl(taxRate)
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
		money_list=money1
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
								rss.close
								atStr = "预算总额："& formatnumber(money1,Me.MoneyNumber,-1)&"  使用总额："&formatnumber(money2,Me.MoneyNumber,-1)&"  剩余总额："&FormatNumber((money1-money2),Me.MoneyNumber,-1)&"，本次报销金额"&formatnumber(money,Me.MoneyNumber,-1)&"，大于剩余总额"&FormatNumber((money1-money2),Me.MoneyNumber,-1)
								rss.close
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
			Dim sp,currMaxMoney, nextbt ,isCont,maxMoney,currbt,stateField
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
							Exit Function
							Me.nextSpId = -3
							Exit Function
							Exit Function
						end if
					end if
					Me.addCate = rs(""& config.addField & "")
					If Len(config.addField2)>0 Then
						Me.useCate = rs(""& config.addField2 &"")
					end if
					If Me.addCate & "" = "" Then Me.addCate = 0
'If Me.useCate & "" = "" Then Me.useCate = 0
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
'If Me.useCate & "" = "" Then Me.useCate = 0
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
'ElseIf nextSpID>0 And spNum>0 Then
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
'If Me.useCate & "" = "" Then Me.useCate = 0
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
				spIdStr = nowSpID &","
				nextSpGate = -1
				spIdStr = nowSpID &","
				nextSpID = -1
				spIdStr = nowSpID &","
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
				set f=fso.getfile(filepath)
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
	Function getQualifications(sort)
		Dim Qualitype : Qualitype=0
		Set rss_Quali = conn.execute("select intro from setopen where sort1="&sort&" and isnull(intro,0)>0 ")
		If rss_Quali.eof= False  Then Qualitype=rss_Quali("intro")
		rss_Quali.close
		getQualifications = Qualitype
	end function
	Function isOpenSet(sort)
		If sort = 102 Or sort = 103 Or sort=104 Then
			sort_qyQuali = 101
		ElseIf sort = 106 Or sort = 107 Or sort=108 Then
			sort_qyQuali = 105
		end if
		Dim Qualitype : Qualitype = getQualifications(sort_qyQuali)
		Dim isopen : isopen=0
		If Qualitype>0 Then
			isopen = setname("setopen","sort1",sort,"intro")
			If isopen="" Then isopen = 0
		end if
		isOpenSet = isopen
	end function
	Sub add_Quali_set(sort,Quali)
		Dim Qualitype : Qualitype = getQualifications(sort)
		If Qualitype>0 Then
			Response.write "" & vbcrlf & "              <tr>" & vbcrlf & "                    <td align=""right"">是否需要资质：</td>" & vbcrlf & "                     <td class=""gray""><input type=""radio"" name=""isNeedQuali"" onclick=""setQuali(1)"" value=""1"" "
			If Qualitype = 2 Or isNeedQuali=1 Then
				Response.write "checked"
			end if
			Response.write ">是" & vbcrlf & "                           "
			If Qualitype = 1 Then
				Response.write "<input type=""radio"" name=""isNeedQuali"" onclick=""setQuali(0)"" value=""0"" "
				If isNeedQuali=0 Then
					Response.write " checked "
				end if
				Response.write ">否"
			end if
			Response.write "" & vbcrlf & "                      </td>" & vbcrlf & "                   <td align=""right""><div id=""zzName"" "
			If (Qualitype = 0 Or isNeedQuali=0) And Qualitype<>2 Then
				Response.write " style=""display:none"" "
			end if
			Response.write ">资质分类：</div></td>" & vbcrlf & "                        <td colspan=""3""><div id=""zzSelect"" "
			If (Qualitype = 0 Or isNeedQuali=0) And Qualitype<>2 Then
				Response.write " style=""display:none"" "
			end if
			Response.write ">"
			Response.write zzSelectHtml(ord,Qualitype,isNeedQuali,Quali,1)
			Response.write "</div></td>   " & vbcrlf & "                </tr>" & vbcrlf & "           "
		end if
	end sub
	Function showFields_list(tel_ord,Quali, Quali_lx ,strType ,qx_canSet, colNum2)
		If Quali>0 Then
			Dim zzlx_id : zzlx_id=0
			Dim td_num : td_num=0
			Dim tdnum : tdnum = colNum2 / 2
			Dim width1,width2
			width1 = "10%"
			width2 = "20%"
			If colNum2 = 8 Then width2 = "15%"
			quali_sql="select s2.id as zzid,s2.title,s3.id,s3.fieldname,(case when len(name)=0 then oldname else name end ) as name ,type, extra ,required "&_
			" from sortclass s1 "&_
			" inner join sortclass s2 on charindex(','+cast(s2.id as varchar(20))+',',','+replace(cast(s1.intro as varchar(4000)),' ','')+',')>0 "&_
			" from sortclass s1 "&_
			"                                                   and s2.del=1 and s2.isstop=0 and s2.sort1=2 "&_
			" inner join sortfields s3 on s3.sort=s2.id and s3.show>0 "&_
			" where s1.sort1=1 and s1.id="&Quali&" and s1.del=1 "
			If Quali_lx>0 Then quali_sql = quali_sql & " and s2.id = " & Quali_lx
			quali_sql = quali_sql & " order by s2.gate1 desc , s2.id desc, s3.gate1 asc , s3.id asc "
			Set Quali_rs = conn.execute(quali_sql)
			If Quali_rs.eof = False Then
				Response.write "<table style='width:100%' border='0' cellpadding='4' cellspacing='1' bgcolor='#C0CCDD' id='content' class='detailTable'>"
				While Quali_rs.eof = False
					If zzlx_id<> Quali_rs("zzid") Then
						zzlx_id = Quali_rs("zzid")
						zztitle = Quali_rs("title")
						If td_num Mod tdnum > 0 Then Response.write "<td colspan='"&(tdnum-(td_num Mod tdnum))*2&"'></td></tr>"
						zztitle = Quali_rs("title")
						Response.write "" & vbcrlf & "                                      <tr class=""top""><td  align=""left"" colspan="""
						Response.write colNum2
						Response.write """><div style=""float:right;padding-right:10px"">"
						Response.write colNum2
						If qx_canSet And strType="show" Then
							Response.write "<input type=""button"" value=""修改"" class=""anybutton2"" onclick=""javascript:window.open('../qualifications/edit_qualifications.asp?ord="
							Response.write pwurl(tel_ord)
							Response.write "&Quali="
							Response.write Quali
							Response.write "&sort1="
							Response.write zzlx_id
							Response.write "','newwin22','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')"">"
							Response.write zzlx_id
						end if
						Response.write "</div><div align=""left"">"
						Response.write zztitle
						Response.write "</div></td></tr>" & vbcrlf & "                                      "
						td_num = 0
					end if
					If td_num Mod tdnum = 0 Then Response.write "<tr class='notop'>"
					Response.write "<td align='right' width='"&width1&"' height='30px'>"&Quali_rs("name")&"：</td>"
					Response.write "<td width='"&width2&"' class='gray' align='left' style='padding-left:6px'>"
					Response.write "<td align='right' width='"&width1&"' height='30px'>"&Quali_rs("name")&"：</td>"
					zzrequired = Quali_rs("required")
					zzFieldValue= getFieldsValue(tel_ord,zzlx_id,Quali_rs("fieldname"),strType)
					objName=Quali_rs("fieldname")&"_"&zzlx_id
					If strType = "edit" Then
						Select Case Quali_rs("type")
						Case 1 :
						Response.write "<select name='"&objName&"'>"
						extra = Quali_rs("extra")
						Set extra_rs= conn.execute("select id,title from sortclass where sort1="&extra&" and id1="&zzlx_id)
						While extra_rs.eof= False
							Response.write "<option value='"&extra_rs("id")&"' "
							If zzFieldValue = extra_rs("id") Then Response.write " selected "
							Response.write ">"&extra_rs("title")&"</option>"
							extra_rs.movenext
						wend
						extra_rs.close
						Response.write "</select>"
						Case 2 :
						Response.write "<input type='text' name='"&objName&"' value='"&zzFieldValue&"' "
						if zzrequired=1  Then Response.write  " min='1' "
						max=100
						if InStr(Quali_rs("fieldname")&"","zdy") then max=500
						Response.write " dataType='Limit' max="&max&" msg='必须在1到"&max&"个字符'>"
						Case 4 :
						zzFieldValueName = getPersonName(""&zzFieldValue&"")
						Response.write "<input type='text' readonly id='"&objName&"' value='"&zzFieldValueName&"' size='20' onmouseup=""setPerson_zz(this)"" "
						if zzrequired=1  Then Response.write  " min='1' "
						Response.write " dataType='Limit' max='4000' msg='请选择人员'> <input type='hidden' name='"&objName&"' id='"&objName&"_id' value='"&zzFieldValue&"'>"
						Case 9 :
						Response.write "<input type='text' readonly name='"&objName&"' value='"&zzFieldValue&"' size='15' id='daysOfMonthPos' onmouseup=""toggleDatePicker('daysOfMonth_"&objName&"','"&objName&"')"" "
'if zzrequired=1  Then Response.write  " min='1' "
						Response.write " dataType='Limit' max='20' msg='请选择日期' style='background-image:url(../images/datePicker.gif);background-position:right;background-repeat:no-repeat;'> <div id='daysOfMonth_"&objName&"' style='POSITION:absolute'></div>"
'if zzrequired=1  Then Response.write  " min='1' "
						End Select
					ElseIf strType = "show" Then
						If Quali_rs("type") = 4 Then
							Response.write getPersonName(""&zzFieldValue&"")
						ElseIf Quali_rs("type") = 1 Then
							Set extra_rs= conn.execute("select id,title from sortclass where id='"&zzFieldValue&"' and del=1 ")
							If extra_rs.eof= False Then
								Response.write extra_rs("title")
							end if
							extra_rs.close
						else
							Response.write zzFieldValue
						end if
					end if
					Response.write "</td>"
					td_num = td_num + 1
					Response.write "</td>"
					If td_num Mod tdnum = 0 Then Response.write "</tr>"
					Quali_rs.movenext
					If Quali_rs.eof Then
						If td_num Mod tdnum>0 Then Response.write "<td colspan='"&(tdnum-(td_num Mod tdnum))*2&"'></td></tr>"
'If Quali_rs.eof Then
					end if
				wend
				Response.write "</table>"
			else
				Response.write "暂无记录！"
			end if
			Quali_rs.close
		else
			Response.write "请选择资质分类！"
		end if
	end function
	Sub show_Quali_sort(sort,Quali)
		Dim Qualitype : Qualitype = getQualifications(sort)
		If Qualitype>0 Then
			Response.write "" & vbcrlf & "             <tr>" & vbcrlf & "                    <td align=""right"">是否需要资质：</td>" & vbcrlf & "                     <td class=""gray"" "
			If isNeedQuali<>1 Then
				Response.write " colspan=""7"""
			end if
			Response.write ">&nbsp;"
			If isNeedQuali=1 Then
				Response.write "是"
			else
				Response.write "否"
			end if
			Response.write "</td>" & vbcrlf & "                        "
			If isNeedQuali=1 Then
				Response.write "<td align=""right"">资质分类：</td><td colspan=""5"" class=""gray"">&nbsp;"
				Response.write zzSelectHtml(ord,Qualitype,isNeedQuali,Quali,2)
				Response.write "</td>"
			end if
			Response.write "" & vbcrlf & "             </tr>" & vbcrlf & "           "
		end if
	end sub
	sub show_Quali_list(tel_ord,sort, Quali,strType, colNum1 , colNum2)
		Dim Qualitype : Qualitype = getQualifications(sort)
		If Qualitype>0 Then
			Response.write "" & vbcrlf & "             <tr class=""top"" id=""zzTr1"" "
			If Quali=0 Or (strType="show" And isNeedQuali=0) Then
				Response.write "style=""display:none"" "
			end if
			Response.write "><td  align=""left"" colspan="""
			Response.write colNum1
			Response.write """><div align=""left"" class=""blue2"">资质信息</div></td></tr>" & vbcrlf & "            <tr id=""zzTr2"" "
			If Quali=0 Or (strType="show" And isNeedQuali=0) Then
				Response.write "style=""display:none"" "
			end if
			Response.write "><td colspan="""
			Response.write colNum1
			Response.write """ height=""25""><div align=""center"" id=""Qualis"" style=""width:100%;padding-left:30px"" >" & vbcrlf & "              "
			Response.write colNum1
			Call showFields_list(tel_ord, Quali, 0 ,strType ,isZupdate, colNum2)
			Response.write "             " & vbcrlf & "                </div></td></tr>" & vbcrlf & "                "
		end if
	end sub
	Sub show_Quali_sp(tel_ord,sort,sp_sort)
		Dim Qualitype : Qualitype = getQualifications(sort)
		If Qualitype>0 And isZsp Then
			Response.write "<input type=""button"" name=""Submit32"" value=""审批"" class=""anybutton"" onClick=""window.open('../inc/CommSPSet.asp?ord="
			Response.write pwurl(tel_ord)
			Response.write "&sort1="
			Response.write sp_sort
			Response.write "','newwin5','width=' + 800 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')""/>"
			Response.write sp_sort
		end if
	end sub
	Function show_Quali_sp_intro(tel_ord,sort,sp_sort,Quali)
		Dim Qualitype : Qualitype = getQualifications(sort)
		If Qualitype>0 And Quali>0 Then
			Response.write "" & vbcrlf & "             <tr class=""top""><td height=""30"" colspan=""8""><div align=""left"" class=""blue2"">资质审批记录</div></td></tr>" & vbcrlf & "          <tr><td height=""30"" colspan=""8"">" & vbcrlf & "            <table style='width:100%' border='0' cellpadding='4' cellspacing='1' bgcolor='#C0CCDD' id='content'>" & vbcrlf & "               <tr height=""27"" class=""top"">" & vbcrlf & "                        <td width=""20%""><div align=""center"">审批阶段</div></td>" & vbcrlf & "                     <td width=""15%"" colspan=""2""><div align=""center"">审批时间</div></td>" & vbcrlf & "                   <td width=""15%""><div align=""center"">审批结果</div></td>" & vbcrlf & "                     <td width=""20%"" colspan=""2""><div align=""center"">审批人员</div></td>" & vbcrlf & "                      <td width=""30%"" colspan=""2""><div align=""center"">审批意见</div></td>" & vbcrlf & "           </tr>" & vbcrlf & "           "
			sql0= "select a.*,b.sort1 spname from sp_intro a left join sp b on a.sp_id=b.id where a.ord="&tel_ord&" and a.sort1="&sp_sort&" order by a.id asc "
			Set Rs0 = server.CreateObject("adodb.recordset")
			Rs0.open sql0,conn,1,1
			if rs0.eof = False then
				do until rs0.eof=True
					spname=rs0("sp")
					if isnumeric(spname) then
						set rssp=conn.execute("select sort1 from sp where gate2=4 and id=" & spname)
						if not rssp.eof then spname=rssp(0)
					end if
					if not isnull(rs0("spname")) then spname=rs0("spname")
					If Rs0("jg")=1 Then
						resultStr="同意"
					else
						resultStr="否决"
					end if
					Response.write "" & vbcrlf & "                             <tr>" & vbcrlf & "                            <td height=""27"" class=""gray""><div align=""center"">"
					Response.write spname
					Response.write "</div></td>" & vbcrlf & "                          <td height=""27"" colspan=""2"" class=""gray""><div align=""center"">"
					Response.write rs0("date1")
					Response.write "</div></td>" & vbcrlf & "                          <td height=""27""  class=""gray""><div align=""center"">"
					Response.write resultStr
					Response.write "</div></td>" & vbcrlf & "                          <td width=""11%"" height=""27"" colspan=""2"" class=""gray""><div align=""center"">"
					Response.write ShowSignImage(setname("gate","ord",rs0("cateid"),"name"),rs0("cateid"),rs0("date1"))
					Response.write "</div></td>  " & vbcrlf & "                                <td width=""15%"" height=""27"" colspan=""2"" class=""gray""><div align=""center"">"
					Response.write rs0("intro")
					Response.write "</div></td>" & vbcrlf & "                          </tr>" & vbcrlf & "                           "
					rs0.movenext
				loop
			else
				Response.write "<tr><td colspan=8 align=center height=27>暂无记录！</td></tr>"
			end if
			Response.write "</table>" & vbcrlf & "             </td></tr>" & vbcrlf & "              "
		end if
	end function
	function setname(tname,zname,values,rname)
		names=""
		if values<>"" then
			sql7="select * from "&tname&" where "&zname&"="&values&" "
			set rs7=server.CreateObject("adodb.recordset")
			rs7.open sql7,conn,1,3
			if not rs7.eof then
				names=rs7(""&rname&"")
			end if
			set rs7=nothing
		end if
		setname=names
	end function
	sub save_Quali_list(tel_ord,sort,bill)
		Dim Qualitype : Qualitype = getQualifications(sort)
		If Qualitype>0 Then
			isNeedQuali = request("isNeedQuali")
			If isNeedQuali=1 Then
				Quali = request("qualifications")
				If Quali&""="" Then Quali=0
				If Quali>0  Then
					oldQuali = conn.execute("select isnull(qualifications,0) from tel where ord="&tel_ord)(0)
					zzintro = ""
					If CInt(oldQuali)<>CInt(Quali) Or Order1=4 Or sort4=4 Then
						Set zzintro_rs = conn.execute("select intro from sortclass where id="&oldQuali)
						If zzintro_rs.eof= False Then
							zzintro=zzintro_rs("intro")
						end if
						zzintro_rs.close
						sp_qualifications = request("sp")
						If sp_qualifications &"" = "" Then sp_qualifications = 0 Else sp_qualifications = CLng(sp_qualifications)
						cateid_sp_qualifications = request("cateid_sp")
						status_sp_qualifications = 0
						If sp_qualifications>0 Then
							status_sp_qualifications=2
						ElseIf sp_qualifications=0 Then
							status_sp_qualifications=3
						else
							status_sp_qualifications=4
						end if
						conn.execute("update tel set isNeedQuali=1 ,qualifications="&Quali&" where ord="&tel_ord)
						Dim isOpen :
						isOpen = isOpenSet(106)
						If sort = 101 Then isOpen = isOpenSet(102)
						If sort4<>4 And isOpen = 1 Then
							conn.execute("update tel set sp_qualifications=0 where ord="&tel_ord)
							Set commSP = New CommSPHandle
							Call commSP.init(bill,tel_ord)
							Call commSP.saveBill2(sp_qualifications, cateid_sp_qualifications, 0, 0)
						end if
						quali_sql="select s2.id as zzid,s2.title,s3.id,s3.fieldname,(case when len(name)=0 then oldname else name end ) as name ,type, extra ,required "&_
						" from sortclass s1 "&_
						" inner join sortclass s2 on charindex(','+cast(s2.id as varchar(20))+',',','+replace(cast(s1.intro as varchar(4000)),' ','')+',')>0 "&_
						" from sortclass s1 "&_
						"                                                  and s2.del=1 and s2.isstop=0 and s2.sort1=2 "&_
						" inner join sortfields s3 on s3.sort=s2.id and s3.show>0 "&_
						" where s1.sort1=1 and s1.id="&Quali&" and s1.del=1 "&_
						" order by s2.gate1 desc , s2.id desc, s3.gate1 asc , s3.id asc "
						Set Quali_rs = conn.execute(quali_sql)
						While Quali_rs.eof = False
							fieldValue = request(""&Quali_rs("fieldname")&"_"&Quali_rs("zzid")&"")
							If InStr(","&Replace(zzintro," ","")&",",","&Quali_rs("zzid")&",")=0 And zzintro<>"" Then
								conn.execute("update sortFieldsContent set del=2 where ord="&tel_ord &" and sortid in ("&zzintro&") and del=1 ")
							end if
							Call saveFieldsValue(tel_ord,Quali_rs("zzid"),Quali_rs("fieldname"),fieldValue)
							Quali_rs.movenext
						wend
						Quali_rs.close
					end if
				end if
			else
				conn.execute("update tel set isNeedQuali=0,qualifications=0 where ord="&tel_ord)
			end if
		end if
	end sub
	sub saveFieldsValue(tel_ord,sort_id,field,fieldValue)
		If conn.execute("select count(1) from sortFieldsContent where sort=1 and ord="&tel_ord &" and sortid="&sort_id&" ")(0)>0 Then
			conn.execute("update sortFieldsContent set "&field&"='"&fieldValue&"',del=1 where sort=1 and ord="&tel_ord &" and sortid="&sort_id&" ")
		else
			conn.execute("insert into sortFieldsContent ("&field&" ,ord,sortid,sort,del) values ('"&fieldValue&"',"&tel_ord&","&sort_id&",1,1)")
		end if
		Dim sql
		sql = "select a.[id] from reminderQueue a " & vbcrlf &_
		"inner join sortFieldsContent b on a.orderId=b.id and b.sort=1 and b.sortid=" & sort_id & " " & vbcrlf &_
		"inner join tel c on c.ord=b.ord and b.ord=" & tel_ord & " " & vbcrlf &_
		"where a.reminderConfig=150 - c.sort3 " &_
		"inner join tel c on c.ord=b.ord and b.ord=" & tel_ord & " " & vbcrlf &_
		"And a.subCfgId=0 "
		sql = "" &_
		"delete reminderPersons where reminderId in ("&sql&") " & vbcrlf &_
		"insert into reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,orderStat,otherInfo,inDate) " & vbcrlf &_
		"select 150 - b.sort3,0,a.id,0,0,'',getdate() " & vbcrlf &_
		"insert into reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,orderStat,otherInfo,inDate) " & vbcrlf &_
		"from sortFieldsContent a " & vbcrlf &_
		"inner join tel b on a.ord=b.ord and a.sort=1 and a.ord=" & tel_ord & " and a.sortid=" & sort_id & " " & vbcrlf &_
		"where a.id not in ("&Replace(sql,"a.[id]","a.[orderID]")&")"
		conn.execute sql
	end sub
	Function getFieldsValue(tel_ord,sort_id,field,strType)
		Dim mValue,Field_Content_rs,del_sql
		del_sql = " and del=1 "
		Set Field_Content_rs = conn.execute("select * from sortFieldsContent where ord="&tel_ord &" and sortid="&sort_id&" "& del_sql)
		If Field_Content_rs.eof= False Then
			mValue =Field_Content_rs(""&field&"")
		end if
		Field_Content_rs.close
		getFieldsValue = mValue
	end function
	Function getPersonName(personstr)
		Dim personName,person_rs
		personName=""
		If Len(personstr)>0 Then
			Set person_rs=conn.execute("select name from gate where del=1 and ord in ("&personstr&")")
			While person_rs.eof= False
				If Len(personName)>0 Then personName = personName &","
				personName = personName & person_rs("name")
				person_rs.movenext
			wend
			person_rs.close
		end if
		getPersonName=personName
	end function
	Function zzSelectHtml(tel_ord,Qualitype,isNeedQuali,qualifications,ntype)
		Dim zstr
		If ntype =1 Then
			zstr = "<select name='qualifications' id='qualifications' oldvalue='"&qualifications&"' onchange='selectZzSort("&tel_ord&",this)' datatype='Limit' "
			If isNeedQuali=1 Or Qualitype=2 Then zstr = zstr & " min='1' "
			zstr = zstr & " max='100' msg='必填'><option value=''></option>"
			Set Quali_rs=conn.execute("select id,title from sortClass where sort1=1 order by gate1 desc ")
			While Quali_rs.eof = False
				zstr = zstr & "<option value='"&Quali_rs("id")&"' "
				If qualifications = Quali_rs("id") Then zstr = zstr & " selected "
				zstr = zstr & ">"&Quali_rs("title")&"</option>"
				Quali_rs.movenext
			wend
			Quali_rs.close
			zstr = zstr &"</select> <span class='red'>*</span>"
		else
			Set Quali_rs=conn.execute("select id,title from sortClass where sort1=1 and id = "& qualifications)
			if Quali_rs.eof = False Then
				zstr = Quali_rs("title")
			end if
			Quali_rs.close
		end if
		zzSelectHtml = zstr
	end function
	Function returnZzSql(sort)
		Dim zsql : zsql=""
		Dim Qualitype : Qualitype = getQualifications(sort)
		Dim unsp , unyx
		If Qualitype>0 Then
			If sort = 101 Then
				unsp = isOpenSet(103)
				unyx = isOpenSet(104)
			ElseIf sort = 105 Then
				unsp = isOpenSet(107)
				unyx = isOpenSet(108)
			end if
			If unsp = 1 Then zsql = zsql & " and isnull(status_sp_qualifications,0)=0 "
			If unyx = 1 Then zsql = zsql & " and not exists(select top 1 1 from sortFieldsContent where sort=1 and ord = tel.ord and del=1 and  DATEDIFF(d,date2,getdate())>0)"
		end if
		returnZzSql = zsql
	end function
	Response.write "" & vbcrlf & "<script type=""text/JavaScript"" src=""../inc/CommSPAjax.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script type=""text/JavaScript"">" & vbcrlf & "window.qualiEditNum= """
	Response.write request("editNum")
	Response.write """ ;" & vbcrlf & "</script>" & vbcrlf & "<script src= ""../Script/qs_function_Quali.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """  language=""javascript""></script>"
	
	Dim MODULES,Module_Result
	MODULES=session("zbintel2010ms")
	dim q,rd,s,hy,trade1
	rd=request("rd")
	hy=request("hy")
	trade1=request("trade1")
	dr=request("dr")
	q=request("q")
	if q="" then  q=1
	s=request("s")
	if s="" then  s=2
	intsort=request("intsort")
	If intsort&""="" Then intsort=1
	drgr=request("drgr")
	muid=request("muid")
	If Not isnumeric(muid) Or muid & "" = "" Then
		muid = 0
	else
		muid = CLng("0" & muid)
	end if
	delstr=""
	Dim userid :  userid = session("personzbintel2007")
	If Len(userid) = 0 Then userid = "0"
	userid = CLng(userid)
	Dim t : t = now
	conn.cursorlocation = 3
	conn.execute "delete ERP_CustomValues " & _
	"where exists (select 1 from tel a where a.cateadd = " & userid & " and a.del=7 and a.ord = ERP_CustomValues.OrderID) " &_
	"and   exists (select 1 from ERP_CustomFields a where  a.TName=1 and a.IsUsing=1 and a.del=1 and a.ID=ERP_CustomValues.FieldsID)" & vbcrlf &_
	" " &_
	"delete from person where exists (select 1 from tel a where a.cateadd=" & userid & " and a.del=7 and a.person=person.ord) and del=7" & vbcrlf &_
	"delete sortFieldsContent where sort=1 and ord in (select ord from tel where del=7 and cateadd="& userid &")" & vbcrlf &_
	"Delete tel where del=7 and cateadd=" & userid
	ord=deurl(request("ord"))
	isupdate=False
	intupdate=0
	isNeedQuali = 0
	qualifications = 0
	editNum=1
	strType="edit"
	If ord>0 Then
		isupdate=True
		intupdate=ord
		editNum=request("editNum")
		If editNum&""="" Then editNum = 1
		If editNum = 1 Then strType = "show"
		strtitle="修改"
		Set rs=conn.execute("select *,(select menuname from menuarea where id=tel.area) as areaname from tel where ord="&ord&"")
		If Not rs.eof Then
			intsort=rs("sort2")
			tel_name=rs("name")
			tel_pym=rs("pym")
			tel_sort=rs("sort")
			tel_sort1=rs("sort1")
			isNeedQuali = rs("isNeedQuali")
			If isNeedQuali&""="" Then isNeedQuali = 0
			qualifications = rs("qualifications")
			If qualifications &"" = "" Then qualifications = 0
			tel_ly=rs("ly")
			tel_jf2=rs("jf2")
			tel_areaname=rs("areaname")
			tel_area=rs("area")
			session("areamenu_list")=rs("area")
			tel_trade=rs("trade")
			tel_jz=rs("jz")
			tel_credit=rs("credit")
			tel_address=rs("address")
			tel_zip=rs("zip")
			tel_faren=rs("faren")
			tel_zijin=rs("zijin")
			If tel_zijin&""<>"" Then
				tel_zijin = CDbl(tel_zijin)
				tel_zijin = tel_zijin / 10000
				tel_zijin = formatNumB(tel_zijin,2)
			end if
			tel_pernum1=rs("pernum1")
			tel_pernum2=rs("pernum2")
			tel_fax=rs("fax")
			tel_email=rs("email")
			tel_hk_xz=rs("hk_xz")
			tel_url=rs("url")
			If tel_url&""="" Then tel_url="http://"
			tel_phone=rs("phone")
			tel_zdy1=rs("zdy1")
			tel_zdy2=rs("zdy2")
			tel_zdy3=rs("zdy3")
			tel_zdy4=rs("zdy4")
			tel_zdy5=rs("zdy5")
			tel_zdy6=rs("zdy6")
			tel_product=Replace(Replace(rs("product")&"","<br>",vbcrlf),"<br />",vbcrlf)
			tel_c2=Replace(Replace(rs("c2")&"","<br>",vbcrlf),"<br />",vbcrlf)
			tel_c3=Replace(Replace(rs("c3")&"","<br>",vbcrlf),"<br />",vbcrlf)
			tel_c4=Replace(Replace(rs("c4")&"","<br>",vbcrlf),"<br />",vbcrlf)
			tel_intro=rs("intro")
			khid=rs("khid")
			tel_bank_1=rs("bank_1")
			tel_bank_2=rs("bank_2")
			tel_bank_3=rs("bank_3")
			tel_bank_4=rs("bank_4")
			tel_bank_5=rs("bank_5")
			tel_bank_6=rs("bank_6")
			tel_bank_7=rs("bank_7")
			tel_bank2_1=rs("bank2_1")
			tel_bank2_2=rs("bank2_2")
			tel_bank2_3=rs("bank2_3")
			tel_bank2_4=rs("bank2_4")
			tel_bank2_5=rs("bank2_5")
			tel_bank2_6=rs("bank2_6")
			tel_bank2_7=rs("bank2_7")
			tel_cateid = rs("cateid")
			tel_fkdays = rs("fkdays")
			tel_fkdate = rs("fkdate")
		end if
		rs.close
		Call lyong_fields
	else
		strtitle="添加"
		set rs88 = conn.execute("EXEC erp_getdjbh 1,"&session("personzbintel2007"))
		khid=rs88(0).value
		rs88.close
		set rs88=nothing
		if khid="error" then
			Response.write "<script language='javascript'>alert('客户编号顺序递增位数已占满，请联系系统管理员，重新调整客户编号顺序递增位数！');location.href='telhy.asp';</script>"
			call db_close : Response.end
		end if
		sqlStr="Insert Into tel(cateadd,date1,khid,del) values('" & session("personzbintel2007") & "','" & date & "','"  & khid & "','"& 7 & "')"
		Conn.execute(sqlStr)
		If muid>0 Then
			Set rs5=conn.execute("select nickname from MMsg_User where id=" & muid)
			If rs5.eof = False Then
				weixinAcc = rs5(0)
			end if
			rs5.close
		end if
		ord=CDbl(GetIdentity("tel","ord","cateadd",""))
		set rs5=conn.execute("select area,(select menuname from menuarea where id=arealist.area) as areaname  from arealist where cateid="&session("personzbintel2007")&"")
		if Not rs5.eof Then
			tel_areaname=rs5("areaname")
			tel_area=rs5("area")
			session("areamenu_list")=rs5("area")
		end if
		rs5.close
		tel_url="http://"
	end if
	Sub lyong_fields
		set rs=conn.execute("select isnull(intro,0) as intro from setopen where sort1=39 and isnull(intro,0)>0")
		if not rs.eof Then
			intro=rs("intro")
			member=session("personzbintel2007")
			If intro=2 Then member=0
			lysql=" and cateid='"& member &"'"
			Set rss=conn.execute("select * from tel_apply where 1=1 " & lysql )
			If Not rss.eof Then
				limitsort1=rss("limitsort1")
				limitsort2=rss("limitsort2")
				limitsort3=rss("limitsort3")
				limitsort4=rss("limitsort4")
				limitsort5=rss("limitsort5")
				limitsort6=getint(rss("limitsort6"))
				If limitsort6=1 Then
					L=0
					limitsort6=""
					Set rs_srea=conn.execute("select area from tel_area where sort=2 and ord='"&member&"'")
					While Not rs_srea.eof
						If L>0 Then limitsort6=limitsort6&","
						limitsort6=limitsort6 & rs_srea("area")&""
						L=L+1
						limitsort6=limitsort6 & rs_srea("area")&""
						rs_srea.movenext
					wend
					rs_srea.close
				else
					limitsort6=""
				end if
				limitsort7=rss("limitsort7")
				limitsort8=rss("limitsort8")
				limitsort9=rss("limitsort9")&""
				If limitsort9&""<>"" Then
					strlm=Split(limitsort9,"||")
					For r=0 To ubound(strlm)
						strlm_one=strlm(r)
						If strlm_one<>"" Then
							kz_zdy=Split(strlm_one,":")
							strlm(r)=kz_zdy(1)
						end if
					next
					limitsort9=Join(strlm,",")
				end if
			end if
			rss.close
		end if
		rs.close
	end sub
	Sub zdyfield_show
		If ZBRuntime.MC(201106) Then Call add_Quali_set(105,qualifications)
		set rss=server.CreateObject("adodb.recordset")
		sql="select id,title,name,sort,gl,bt,ts,jz from zdy where sort1=1 and set_open=1 order by gate1 asc "
		rss.open sql,conn,1,1
		num1=rss.RecordCount
		i_jm=0
		j_jm=1
		s="0"
		If Not rss.eof then
			Response.write("<tr>")
			do until rss.eof
				if clng(i_jm/3)=i_jm/3 and i_jm<>0 then
					Response.write("</tr><tr>")
					j_jm=j_jm+1
					'Response.write("</tr><tr>")
				end if
				zdytitle=rss("title")
				zdyname=rss("name")
				Select Case zdyname
				Case "zdy1" : s="61" : strvalue=tel_zdy1
				Case "zdy2" : s="62" : strvalue=tel_zdy2
				Case "zdy3" : s="63" : strvalue=tel_zdy3
				Case "zdy4" : s="64" : strvalue=tel_zdy4
				End Select
				bt=rss("bt")
				ts=rss("ts")
				jz=rss("jz")
				zdysort=rss("sort")
				Response.write "" & vbcrlf & "<td align=""right"">"
				Response.write zdytitle
				Response.write "：</td>" & vbcrlf & "<td "
				if i_jm=num1-1  then
					'Response.write "：</td>" & vbcrlf & "<td "
					Response.write "colspan="""
					Response.write 1+2*(j_jm*3-num1)
					'Response.write "colspan="""
					Response.write """ "
				end if
				Response.write ">" & vbcrlf & "    "
				if zdysort=2 then
					Response.write "" & vbcrlf & "    <input name="""
					Response.write zdyname
					Response.write """ type=""text"" id="""
					Response.write zdyname
					Response.write """ value="""
					Response.write strvalue
					Response.write """ "
					if ts=1 Or jz=1 then
						Response.write " onkeyup=""callServer("
						Response.write s
						Response.write ",this.value);"" "
					end if
					Response.write " size=""15"" "
					if bt=1 then
						Response.write " min=""1"" "
					end if
					Response.write " datatype=""Limit"" max=""400"" msg=""必须为1到400个字符"">"
					if bt=1 then
						Response.write " &nbsp;<span class=""red"">*</span>"
					end if
					if ts=1 then
						Response.write "<span id=""ts_"
						Response.write s
						Response.write """ class=""red""></span>"
					end if
					If jz=1 Then
						Response.write "<input type=""hidden"" name=""jzlr"" value="""
						Response.write s
						Response.write """>"
					end if
				elseif zdysort=1 then
					Response.write "" & vbcrlf & "    <select name="""
					Response.write zdyname
					Response.write """ "
					if bt=1 then
						Response.write " datatype=""Limit"" min=""1"" msg=""必填"" "
					end if
					Response.write ">" & vbcrlf & "        <option value=""""></option>" & vbcrlf & "        "
					ly_sql=""
					If zdyname="zdy5" Then
						strvalue=tel_zdy5
						If limitsort7&""<>"" Then ly_sql=" and ord in ("&limitsort7&")"
					end if
					If zdyname="zdy6" Then
						strvalue=tel_zdy6
						If limitsort8&""<>"" Then ly_sql=" and ord in ("&limitsort8&")"
					end if
					set rs7=conn.execute("select ord,sort1 from sortonehy where gate2="&rss("gl")&" "& ly_sql &" order by gate1 desc ")
					do until rs7.eof
						Response.write "<option value='"&rs7("ord")&"' "
						If strvalue=rs7("ord") Then Response.write " selected "
						Response.write ">"&rs7("sort1")&"</option>"
						rs7.movenext
					loop
					rs7.close
					Response.write "" & vbcrlf & "    </select>" & vbcrlf & "    "
					if bt=1 then
						Response.write "<span class=""red"">*</span>"
					end if
				end if
				Response.write "             " & vbcrlf & "</td>" & vbcrlf & ""
				i_jm=i_jm+1
				'Response.write "             " & vbcrlf & "</td>" & vbcrlf & ""
				rss.movenext
			loop
			Response.write("</tr>")
		end if
		rss.close
		set rss=nothing
	end sub
	Dim openSp
	If ZBRuntime.MC(201106) then
		openSp = isOpenSet(106)
	else
		openSp = 0
	end if
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "    <meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "    <title>"
	'openSp = 0
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "    <link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "    <script type=""text/javascript"" src=""../inc/comm.pym.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "    <link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/default/easyui.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """>" & vbcrlf & "    <link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/icon.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """>" & vbcrlf & "    <script src=""../inc/popup_layer.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ type=""text/javascript"" language=""javascript""></script>" & vbcrlf & "    <script type=""text/javascript"" src=""../inc/jquery.decorateIframe.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "    <script type=""text/javascript"" src=""../inc/jquery.easyui.min.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "    <script language=""javascript"" src=""../sortcp/function.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "    <script src=""../Script/wk_add.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ type=""text/javascript""></script>" & vbcrlf & "    <script type=""text/javascript"" src=""../inc/jquery.bgiframe.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "    <script type=""text/javascript"" src=""../work/correctarea.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "    <script type=""text/javascript"">" & vbcrlf & "      $(function() {" & vbcrlf & "          $('.panel').bgiframe();" & vbcrlf & " });" & vbcrlf & "    </script>" & vbcrlf & "    <style type=""text/css"">" & vbcrlf & "        .autocplclear{" & vbcrlf & "            background:url(../../sysn/skin/default/img/autocplclearbtn.png) center center no-repeat;" & vbcrlf & "            width:18px;" & vbcrlf & "            height:18px;  " & vbcrlf & "            cursor:pointer;" & vbcrlf & "            margin-left:5px;" & vbcrlf & "            display: inline-block;" & vbcrlf & "   margin-top:-4px;" & vbcrlf & "            vertical-align: middle;" & vbcrlf & "        } " & vbcrlf & "        .iframe-x {" & vbcrlf & "            width: 100%;" & vbcrlf & "            height: 100%;" & vbcrlf & "            margin: 5px;" & vbcrlf & "            background: #fff;" & vbcrlf & "            position: absolute;" & vbcrlf & "            left: 20px;" & vbcrlf & "            top: 20px;" & vbcrlf & "            z-index: 200;" & vbcrlf & "        }" & vbcrlf & "        <!--" & vbcrlf & "        body {" & vbcrlf & "            margin-top: 0px;" & vbcrlf & "        }" & vbcrlf &"" & vbcrlf & "        .style1 {" & vbcrlf & "            color: #0066FF;" & vbcrlf & "        }" & vbcrlf & "        -->" & vbcrlf & "        #w1 {" & vbcrlf & "            height: 460px !important;" & vbcrlf & "        }" & vbcrlf & "" & vbcrlf & "        #daysOfMonthPos {" & vbcrlf & "          background-position-x: 99% !important;" & vbcrlf & "        }" & vbcrlf & "    </style>" & vbcrlf & "    <script language=""javascript"">" & vbcrlf & "function ask(sort2,sort3,sort4) { " & vbcrlf & "     //sort2 1.单位客户 2.个人客户" & vbcrlf & "   //sort3 1.返回列表 2.继续添加" & vbcrlf & "   //sort4 1.公用 2.领用 3.修改 4.暂存" & vbcrlf & "  var openSp = """
	Response.write openSp
	Response.write """;" & vbcrlf & "        if (sort4==4)" & vbcrlf & "   {" & vbcrlf & "               setbt(0);" & vbcrlf & "       }" & vbcrlf & "       else" & vbcrlf & "    {" & vbcrlf & "               if (openSp == ""1"")" & vbcrlf & "                {" & vbcrlf & "                       if (document.getElementsByName(""isNeedQuali"")[0].checked){setbt(1);}" & vbcrlf & "              }" & vbcrlf & "}" & vbcrlf & "       var obj=document.getElementById(""demo"");" & vbcrlf & "  clearSpace($('#name')[0])" & vbcrlf & "       if (Validator.Validate(obj,2))" & vbcrlf & "  {" & vbcrlf & "               //BUG 7165 Sword 2015-2-28 客户字段策略开启重名禁止录入后添加客户的保存提示问题 " & vbcrlf & "                /*var result=check_jzlr();" & vbcrlf & "              if (result>0)" & vbcrlf & "           {" & vbcrlf & "                       alert(document.getElementById(""ts_""+result).innerHTML);" & vbcrlf & "           }*/" & vbcrlf & "             " & vbcrlf & "                document.all.date.action = ""save3.asp?sort2=""+sort2+""&sort3=""+sort3+""&sort4=""+sort4+""&drgr="
	'Response.write openSp
	Response.write drgr
	Response.write "&ord="
	Response.write pwurl(ord)
	Response.write """; " & vbcrlf & "               if (sort4!=4 && openSp == ""1"")" & vbcrlf & "            {" & vbcrlf & "                       if (document.getElementsByName(""isNeedQuali"")[0].checked)" & vbcrlf & "                 {" & vbcrlf & "                               if ($(""#qualifications"").attr(""oldvalue"")!=$(""#qualifications"").val()||"
	Response.write editNum
	Response.write "==3)" & vbcrlf & "                         {" & vbcrlf & "                                       spclient.GetNextSP('tel',"""
	Response.write ord
	Response.write """,0,0,0,1);" & vbcrlf & "                                       return false;" & vbcrlf & "                           }" & vbcrlf & "                       }" & vbcrlf & "               }" & vbcrlf & "               obj.submit();" & vbcrlf & "   }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function check_jzlr(){" & vbcrlf & "        var arrjz=document.getElementsByName(""jzlr"");" & vbcrlf & "     for (var k=0 ;k<arrjz.length; k++)" & vbcrlf & "   {       if (document.getElementById(""ts_""+arrjz[k].value))" & vbcrlf & "                {       " & vbcrlf & "                        if(document.getElementById(""ts_""+arrjz[k].value).innerHTML!=""""){" & vbcrlf & "                            return arrjz[k].value;" & vbcrlf & "                  }" & vbcrlf & "               }       " & vbcrlf & "        }" & vbcrlf & "        return 0 ;" & vbcrlf & "}" & vbcrlf & "function inselect4(){" & vbcrlf & "        var sort = document.getElementsByName(""sort"")[0].value;" & vbcrlf & "   var objsort1= document.getElementsByName(""sort1"")[0];" & vbcrlf & "     if(sort==""0""||sort==null || sort==""""){" & vbcrlf & "          for(var i =objsort1.options.length-1; i>=0; i--){" & vbcrlf & "             objsort1.options.remove(i);" & vbcrlf & "         }" & vbcrlf & "   }else{" & vbcrlf & "          for(var i =objsort1.options.length-1; i>=0; i--){" & vbcrlf & "                       objsort1.options.remove(i);" & vbcrlf & "             }" & vbcrlf & "               for(i=0;i<ListUserId4[sort].length;i++){        " & vbcrlf & "                        var oOption = document.createElement(""OPTION"");" & vbcrlf & "                   objsort1.options.add(oOption);" & vbcrlf & "                  oOption.innerHTML = ListUserName4[sort][i];" & vbcrlf & "                     oOption.value = ListUserId4[sort][i];" & vbcrlf & "           }" & vbcrlf & "       }" & vbcrlf & "       var index=objsort1.selectedIndex;" & vbcrlf & "}" & vbcrlf & "function getBirthYear() {" & vbcrlf & "    var val = $(""#birthdayType"").val();" & vbcrlf & "    var s = """";" & vbcrlf & "    xmlHttp.open(""GET"", ""../person/getBirthJson.asp?v=getYear&birthType="" + val + ""&r="" + Math.random(), false);" & vbcrlf & " xmlHttp.send();" & vbcrlf & "    if (xmlHttp.readyState == 4) {" & vbcrlf & "        var json = eval(xmlHttp.responseText);" & vbcrlf & "        var objBirthYear = document.getElementById(""birthYear"");" & vbcrlf & "        objBirthYear.options.length = 0;" & vbcrlf & "        for (var i = 0; i < json.length; i++) {" & vbcrlf & "            objBirthYear.options.add(new Option(json[i].yName, json[i].yValue));" & vbcrlf & "            if ("""
	'Response.write ord
	Response.write year(date)
	Response.write """ == json[i].yValue) { objBirthYear.options[i].selected = ""selected""; }" & vbcrlf & "        };" & vbcrlf & "        getBirthMonth();" & vbcrlf & "    }" & vbcrlf & "}" & vbcrlf & "function getBirthMonth() {" & vbcrlf & "    var val = $(""#birthdayType"").val();" & vbcrlf & "    var birthYear = $(""#birthYear"").val();" & vbcrlf & "    xmlHttp.open(""GET"", ""../person/getBirthJson.asp?v=getMonth&birthType="" + val + ""&birthYear="" + birthYear + ""&r="" + Math.random(), false);" & vbcrlf & "    xmlHttp.send();" & vbcrlf & "    if (xmlHttp.readyState == 4) {" & vbcrlf & "        var json = eval(xmlHttp.responseText);" & vbcrlf & "        var objBirthMonth = document.getElementById(""birthMonth"");" & vbcrlf & "        objBirthMonth.options.length = 0;" & vbcrlf & "" & vbcrlf & "        for (var i = 0; i < json.length; i++) {" & vbcrlf & "            objBirthMonth.options.add(new Option(json[i].mName, json[i].mValue));" & vbcrlf & "            if ("""
	Response.write month(date)
	Response.write "-0"" == json[i].mValue) { objBirthMonth.options[i].selected = ""selected""; }" & vbcrlf & "        };" & vbcrlf & "        getBirthDay();" & vbcrlf & "    }" & vbcrlf & "     if (birthYear!=""""){getAge(birthYear);}" & vbcrlf & "}" & vbcrlf & "function getBirthDay() {" & vbcrlf & "    var val = $(""#birthdayType"").val();" & vbcrlf &     "var birthYear = $(""#birthYear"").val();" & vbcrlf &     "var birthMonth = $(""#birthMonth"").val();" & vbcrlf & vbcrlf &     "xmlHttp.open(""GET"", ""../person/getBirthJson.asp?v=getDay&birthType="" + val + ""&birthYear="" + birthYear + "&birthMonth=" + birthMonth + "&r=" + Math.random(), false);" & vbcrlf &     "xmlHttp.send();" & vbcrlf &     "if (xmlHttp.readyState == 4) {" & vbcrlf &         "var json = eval(xmlHttp.responseText);" & vbcrlf &         "var objBirthDay = document.getElementById(""birthDay"");" & vbcrlf &         "objBirthDay.options.length = 0;" & vbcrlf & "        for (var i = 0; i < json.length; i++) {" & vbcrlf & "            objBirthDay.options.add(new Option(json[i].dName, json[i].dValue));" & vbcrlf & "            if ("""
	'Response.write month(date)
	Response.write day(date)
	Response.write """ == json[i].dValue) { objBirthDay.options[i].selected = ""selected""; }" & vbcrlf & "        };" & vbcrlf & "    }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function getAge(birthYear)" & vbcrlf & "{" & vbcrlf & "   if (document.getElementById(""age""))" & vbcrlf & "       {" & vbcrlf & "               var myDate=new Date();" & vbcrlf & "                document.getElementById(""age"").value=myDate.getFullYear()-birthYear;" & vbcrlf & "      }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function setjf5() {" & vbcrlf & "   var sort1 = document.getElementsByName(""sort1"")[0].value;" & vbcrlf & " var url = ""../sort5/getsort5.asp?ord="" + sort1 +""&timestamp="" + new Date().getTime() + ""&date1=""+ Math.round(Math.random()*100);" & vbcrlf & "       xmlHttp.open(""GET"", url, false);" & vbcrlf & "  xmlHttp.onreadystatechange = function(){" & vbcrlf & "                updatejf();" & vbcrlf & "     };" & vbcrlf & "      xmlHttp.send(null);  " & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function updatejf(){" & vbcrlf & "   if (xmlHttp.readyState == 4) {" & vbcrlf & "          var controls = document.getElementsByTagName('select');" & vbcrlf & "         var response = xmlHttp.responseText;" & vbcrlf & "            for(var i=0; i<controls.length; i++){" & vbcrlf & "                   if(controls[i].name.indexOf(""jf2"")>=0){" & vbcrlf & "                               for(var j=0;j<controls[i].options.length;j++) " & vbcrlf & "                          {" & vbcrlf & "                                       if(controls[i].options[j].value==parseInt(response)) " & vbcrlf & "                                   {       controls[i].options[j].selected=true; " & vbcrlf & "                                          break;" & vbcrlf & "                                  }" & vbcrlf & "       }       " & vbcrlf & "                        }" & vbcrlf & "               }" & vbcrlf & "       }" & vbcrlf & "}" & vbcrlf & "//-->" & vbcrlf & "    </script>" & vbcrlf & "    "
	'Response.write day(date)
	Response.write "<script language=""javascript"">"&chr(13)
	Response.write "<!--"&chr(13)
	'Response.write "<script language=""javascript"">"&chr(13)
	Response.write "var ListUserName4=new Array();"&chr(13)
	Response.write "var ListUserId4=new Array();"&chr(13)
	Response.write "var ListMust4=new Array();"&chr(13)
	set rss=conn.execute("select * from sort4")
	while not rss.eof
		sid4=rss("id")
		Response.write "ListUserName4["&sid4&"]=new Array();"&chr(13)
		Response.write "ListUserId4["&sid4&"]=new Array();"&chr(13)
		Response.write "ListMust4["&sid4&"]=new Array();"&Chr(13)
		Response.write "ListUserName4["&sid4&"][0]='';"&chr(13)
		Response.write "ListUserId4["&sid4&"][0]='';"&chr(13)
		Response.write "ListMust4["&sid4&"][0]='';"&Chr(13)
		set rsi=conn.execute("select *,isnull(MustHas,0) as MustHas1 from sort5 where sort1="&rss("id")&" order by sort1,gate2 desc")
		index4=1
		Do while not rsi.eof
			Response.write "ListUserName4["&sid4&"]["&Index4&"]='"&rsi("sort2")&"';"&chr(13)
			Response.write "ListUserId4["&sid4&"]["&Index4&"]='"&rsi("Id")&"';"&chr(13)
			Response.write "ListMust4["&sid4&"]["&Index4&"]='"&rsi("MustHas1")&"';"&Chr(13)
			If rsi("sort1")&""=tel_sort&"" Then
				If rsi("ord")&""=tel_sort1&"" Then
					gate2=rsi("gate2")
				else
					If gate2>rsi("gate2") And rsi("MustHas1")="1" Then
						Exit Do
					end if
				end if
			end if
			Index4=Index4+1
			Exit Do
			rsi.movenext
		loop
		rsi.close
		set rsi=nothing
		rss.movenext
	wend
	rss.close
	set rss=nothing
	Response.write "//-->"&chr(13)
	'set rss=nothing
	Response.write "</SCRIPT>"&chr(13)
	Response.write "" & vbcrlf & "<script language=""javascript"" type=""text/javascript"">" & vbcrlf & "" & vbcrlf & "function callServer(m,strname) {" & vbcrlf & "if(window.Ajaxhwnd) {" & vbcrlf & "window.clearTimeout(window.Ajaxhwnd);" & vbcrlf & "     window.Ajaxhwnd = 0;" & vbcrlf & "   }" & vbcrlf& "   window.Ajaxhwnd =  window.setTimeout(function(){" & vbcrlf & "            var w2  = ""ts_""+m;" & vbcrlf & "                w2=document.all[w2];" & vbcrlf & "            if ((strname == null) || (strname == """")) return;" & vbcrlf & "         jQuery.ajax({" & vbcrlf & "                   url:'cu.asp'," & vbcrlf & "                   cache:false," & vbcrlf & "                    async:false," & vbcrlf & "                 type:'post'," & vbcrlf & "                    data:{" & vbcrlf & "                          name:escape(strname)," & vbcrlf & "                           ord:m," & vbcrlf & "                          intupdate:'"
	Response.write intupdate
	Response.write "'," & vbcrlf & "                           timestamp:new Date().getTime()" & vbcrlf & "                  }," & vbcrlf & "                      success:function(r){" & vbcrlf & "                            w2.innerHTML=r;" & vbcrlf & "                 }" & vbcrlf & "               });" & vbcrlf & "     },200)" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "window.callServer2Repeat = false;" & vbcrlf & "function callServer2(ord,intype) {" & vbcrlf & " if(window.callServer2Repeat==true) {return;}" & vbcrlf & "    window.callServer2Repeat = true;" & vbcrlf & "                setTimeout(function(){window.callServer2Repeat=false},8000);  //至少延时5秒才能访问" & vbcrlf & "     var w=""w1"";" & vbcrlf & "       var url = ""correctall_area.asp?intype="" + intype +""&ord=""+ord+""&timestamp="" + new Date().getTime() + ""&date1=""+ Math.round(Math.random()*100);" & vbcrlf & "  xmlHttp.open(""GET"", url, false);" & vbcrlf & "  xmlHttp.onreadystatechange = function(){" & vbcrlf & "                updatePage2(w,ord);" & vbcrlf & "     };" & vbcrlf & "      xmlHttp.send(null);  " & vbcrlf & "}" & vbcrlf & "//任务：升级到31.70后 添加客户选择不了区域 xieyanhui20150415" & vbcrlf & "function updatePage2(w,ord) {" & vbcrlf & "  if (xmlHttp.readyState == 4) {" & vbcrlf & "var response = xmlHttp.responseText;" & vbcrlf & "document.getElementById(""""+w+"""").innerHTML=response;" & vbcrlf & "ord = Number(ord);" & vbcrlf & "var $td = """";" & vbcrlf & "var arealist = $(""#arealist"").val(); " & vbcrlf & "             if(arealist!="""" && arealist!=""0"" && arealist !=""-1""){" & vbcrlf & "                 arealist = "",""+arealist+"","";" & vbcrlf & "                        $(""#treeArea"").find(""td[id^='b']"").each(function(){" & vbcrlf & "                            var trid = $(this).attr(""id"").replace(""b"","""");" & vbcrlf & "                                if(arealist.indexOf("",""+trid+"","")<0){" & vbcrlf & "                                       $(this).parent().hide();" & vbcrlf & "                                        $(""#a""+trid).hide();" & vbcrlf & "                              }else{" & vbcrlf & "                                  if($(""#a""+trid).size()>0){" & vbcrlf & "$(""#a""+trid).find(""td[id^='b']"").each(function(){           " & vbcrlf & "                                                        $td =$(this);" & vbcrlf & "                                                   $td.find(""a:first"").attr(""href"",""javascript:;"").unbind().click(function(){" & vbcrlf & "select_area(ord,$(this).parent().attr(""id"").replace(""b"",""""),$(this).text());" & vbcrlf & "});" & vbcrlf & "});" & vbcrlf & "                                     }else{" & vbcrlf & "                                                  $td =$(this);" & vbcrlf & "                                                   $td.find(""a:first"").attr(""href"",""javascript:;"").unbind().click(function(){                            " & vbcrlf & "                                                                select_area(ord,$(this).parent().attr(""id"").replace(""b"",""""),$(this).text());" & vbcrlf &                                                     "});" & vbcrlf & "}" & vbcrlf &                                "}"        & vbcrlf &                         "});" & vbcrlf &              "}else{" & vbcrlf &                   "$(""#treeArea"").find(""td[id^='b']"").each(function(){"          & vbcrlf &                                 "$td =$(this);" & vbcrlf &                            "$td.find(""a:first"").attr(""href"",""javascript:;"").unbind().click(function(){" & vbcrlf &                                     "select_area(ord,$(this).parent().attr(""id"").replace(""b"",""""),$(this).text());" & vbcrlf &                           "});" & vbcrlf &                      "});" & vbcrlf &              "}" & vbcrlf &        "}" & vbcrlf & "}" & vbcrlf & vbcrlf & "function select_area(khord,ord,strvalue)" & vbcrlf &"{        //alert(khord+""   ""+ ord+""   ""+strvalue);" & vbcrlf & "   if (document.getElementById(""area""))" & vbcrlf & "      {" & vbcrlf & "               document.getElementById(""area"").value=ord;" & vbcrlf & "                document.getElementById(""areaname"").value=strvalue;" & vbcrlf & "       }" & vbcrlf & "       $('#w1').window('close');" & vbcrlf & "}" & vbcrlf & "function cleararea(){" & vbcrlf & "    document.getElementById(""area"").value=""0"";" & vbcrlf & "    document.getElementById(""areaname"").value="""";" & vbcrlf & "    document.getElementById(""areaname"").innerText="""";" & vbcrlf & "}" & vbcrlf & "    </script>" & vbcrlf & "" & vbcrlf & "    <script src=""../inc/popup_layer.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ type=""text/javascript"" language=""javascript""></script>" & vbcrlf & "    <script language=""javascript""> " & vbcrlf & "function phoneCall(phoneNum) " & vbcrlf & "{ " & vbcrlf & "      if (phoneNum!="""")" & vbcrlf & " {" & vbcrlf & "               getCall('../china/bh.asp?"
	Response.write iif(strtitle="添加","","ord=" & ord & "&")
	Response.write "ordtype=0&phone='+ phoneNum +'');" & vbcrlf & "            return false;" & vbcrlf & "   }" & vbcrlf & "       else" & vbcrlf & "    {" & vbcrlf & "               alert(""号码不能为空！"");" & vbcrlf & "  }" & vbcrlf & "} " & vbcrlf & "" & vbcrlf & "function phoneNum2V(Num2V)" & vbcrlf & "{" & vbcrlf & "  reMobil=Validator.Mobile;//匹配IP地址的正则表达式" & vbcrlf & "   rePhone=Validator.Phone; //匹配IP地址的正则表达式" & vbcrlf & "       if(reMobil.test(Num2V))" & vbcrlf & " {" & vbcrlf & "               document.getElementById('mobile').value=Num2V;" & vbcrlf & "          return false;" & vbcrlf & "   }" & vbcrlf & "       else" & vbcrlf & "    {" & vbcrlf & "               if(rePhone.test(Num2V))" & vbcrlf & "               {" & vbcrlf & "                       document.getElementById('phone').value=Num2V;" & vbcrlf & "                   return false;" & vbcrlf & "           }" & vbcrlf & "               else" & vbcrlf & "            {" & vbcrlf & "                       return false;" & vbcrlf & "           }" & vbcrlf & "       }" & vbcrlf & "}" & vbcrlf & "    </script>" & vbcrlf & "</head>" & vbcrlf & "<body bgcolor=""#ebebeb"">" & vbcrlf &     "<table width=""100%"" border=""0"" align=""left"" cellpadding=""0"" cellspacing=""0"" bordercolor=""#E2E2E1"">" & vbcrlf &         "<tr>" & vbcrlf &             "<td width=""100%"" valign=""top"">" & vbcrlf &                   "<table class=""resetTableBg"" width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"">" & vbcrlf &                     "<tr>" & vbcrlf &                         "<td class=""place place42"">客户"
	Response.write strtitle
	If intsort=1 Then
		Response.write "（单位）"
	else
		Response.write "（个人）"
	end if
	Response.write "</td>" & vbcrlf & "                        <td>&nbsp;</td>" & vbcrlf & "                        <td align=""right"">" & vbcrlf & "                            "
	If drgr="1" Then
		If intsort=1 Then
			Response.write "" & vbcrlf & "                            <input type=""button"" style=""background:#FFF!important"" name=""Submit422"" value=""添加个人客户"" class=""anybutton2"" onclick=""javascript:window.location.href='../work/add.asp?intsort=2'"" />" & vbcrlf & "                            "
		end if
	end if
	Response.write "" & vbcrlf & "                        </td>" & vbcrlf & "                        <td width=""3"">" & vbcrlf & "                            <img class=""resetElementHidden"" src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "                    </tr>" & vbcrlf & "       </table>" & vbcrlf & "                <form method=""POST"" action=""save3.asp?ord="
	Response.write pwurl(ord)
	Response.write """ id=""demo"" onsubmit=""return false;"" name=""date"" target=""sdate"" style=""margin: 0"">" & vbcrlf & "                    <table class=""contentTable"" width=""100%"" border=""0"" cellpadding=""4"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "                        <input type=""hidden"" name=""oldsort"" id=""oldsort"" value="""
	Response.write tel_sort
	Response.write """>" & vbcrlf & "                        <input type=""hidden"" name=""oldsort1"" id=""oldsort1"" value="""
	Response.write tel_sort1
	Response.write """>" & vbcrlf & "                        <input type=""hidden"" name=""MicroMsgUserId"" value="""
	Response.write muid
	Response.write """ />" & vbcrlf & "                        "
	Cists=0
	If intsort=1 Then
		sort_sql=" and gate1 not in (26) "
	else
		sort_sql=" and gate1 not in (14,15,16,17) and sort2<>4 "
	end if
	If isupdate=True Then sort_sql = sort_sql & "  and gate1 not in (17,18,20,23,24,25,27,28,29,30,31,32,100) "
	name_length=conn.execute("select length/2 from syscolumns where id=(select id from sysobjects where name='tel') and name='name'")(0)
	Set rs=conn.execute("select x.*,(case when Required>0 then 1 else 0 end ) as RequiredID from setfields x inner join (select MIN(id) as xmid from setfields where sort=1 and  show>0 "& sort_sql &" group by fieldName) y on y.xmid=x.id order by order1 asc")
	If Not rs.eof Then
		n=0
		While Not rs.eof
			gate1=rs("gate1")
			point=rs("point")
			enter=rs("enter")
			Sort2=rs("sort2")
			If oSort2<>Sort2 Then
				If n Mod 3>0 Then Response.write "<td colspan='"&(3-(n Mod 3))*2&"'></td>"
'If oSort2<>Sort2 Then
				If Sort2=1 Then
					Response.write "<tr class='top top_no-border'><td align='left' colspan=6>&nbsp;基本信息 <div style='float:right;height:10px!important;overflow:visible;margin-top:-5px'>"
'If Sort2=1 Then
					If isupdate=False Or editNum=3 Then
						If ZBRuntime.MC(201106) Then Response.write "<input type='button' name='Submit426' value='暂存'  onClick='ask("&intsort&","&editNum&",4);' class='anybutton2'/>&nbsp;"
						Response.write "<input type='button' name='Submit422' value='领用'  onClick='ask("&intsort&",1,2);' class='anybutton2'/>"
						Response.write "<input type='button' name='Submit424' value='领用增加' onClick='ask("&intsort&",2,2);' class='anybutton2'/>&nbsp;"
						Response.write "<input type='button' name='Submit42' value='公用' onclick='ask("&intsort&",1,1);' class='anybutton2'/>"
						Response.write "<input type='button' name='Submit425' value='公用增加' onClick='ask("&intsort&",2,1);' class='anybutton2'/>&nbsp;"
					else
						Response.write "<input type='button' name='Submit43' value='保存' onclick='ask("&intsort&",3,3);' class='anybutton2'/>"
					end if
					Response.write "<input type='reset' value='重填' class='anybutton2' name='B22'></div></td></tr>"
				ElseIf Sort2=2 Then
					Call zdyfield_show()
					Response.write getExtended2(1,ord,limitsort9)
					Response.write "" & vbcrlf & "                        <tr class=""top"">" & vbcrlf & "                            <td align=""left"" colspan=""6"">" & vbcrlf & "                                <div align=""left"">&nbsp;联系信息</div>" & vbcrlf & "                            </td>" & vbcrlf & "                    </tr>" & vbcrlf & "                        "
				ElseIf Sort2=3 Then
					If oSort2=1 Then
						Call zdyfield_show()
						Response.write getExtended2(1,ord,limitsort9)
					end if
					If ZBRuntime.MC(201106) Then call show_Quali_list(ord,105,qualifications,strType,6,6)
					Response.write "" & vbcrlf & "                        <tr class=""top"">" & vbcrlf & "                            <td align=""left"" colspan=""6"">" & vbcrlf & "                                <div align=""left"">&nbsp;<a class=""tableTitleLinks"" target=""_self"" href=""javascript:;"" onclick=""showLay('ywxx')"">业务信息</a></div>" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        "
				ElseIf Sort2=4 Then
					If oSort2=1 Then
						Call zdyfield_show()
						Response.write getExtended2(1,ord,limitsort9)
					ElseIf oSort2=2 Then
						If ZBRuntime.MC(201106) Then call show_Quali_list(ord,105,qualifications,strType,6,6)
					end if
					Response.write getExtended1(1,ord)
					Response.write "" & vbcrlf & "                        <tr class=""top"">" & vbcrlf & "                            <td align=""left"" colspan=""6"">" & vbcrlf & "                                <div align=""left"">&nbsp;<a class=""tableTitleLinks"" target=""_self"" href=""javascript:;"" onclick=""showLay('cwxx')"">财务信息（点击即可弹开收回）</a></div>" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        "
				end if
				oSort2=Sort2
				n=0
			end if
			name=rs("name")
			If name="" Then name=rs("oldname")
			fieldName=rs("fieldName")
			if fieldName="address" then
				If n Mod 3=2 Then
					Response.write "<td colspan='"&(3-(n Mod 3))*2&"'></td></tr>"
'If n Mod 3=2 Then
					n=0
				end if
			end if
			If n Mod 3 =0 Then 'Or fieldName="address"
			Response.write "" & vbcrlf & "                        <tr "
			If Sort2=3 Then
				Response.write " id=""ywxx"
				Response.write gate1
				Response.write """ "
			ElseIf Sort2=4 Then
				Response.write " id=""cwxx"
				Response.write gate1
				Response.write """ style=""display: none"" "
			end if
			Response.write ">" & vbcrlf & "                            "
			n=0
		end if
		Required=rs("RequiredID")
		extra=rs("extra")
		ists=0
		If extra&""<>"" Then
			strsort=Split(extra,":")
			For m=0 To ubound(strsort)
				onesort=Split(strsort(m),"=")
				Select Case  onesort(0)
				Case "zlts" :
				ists=onesort(1)
				Cists=onesort(1)
				End Select
			next
		end if
		strformat=rs("format")
		size=15
		dataType="Limit"
		min=1
		max=50
		msg=name&"必填"
		formatHtml=""
		Select Case fieldName
		Case "part1":
		If Required=1 Then
			msg=name&"必须在1至"&max&"个字之间"
		else
			msg=name&"长度必须在1至"&max&"个字符之间"
		end if
		Case "job":
		If Required=1 Then
			msg=name&"必须在1至"&max&"个字之间"
		else
			msg=name&"长度必须在1至"&max&"个字符之间"
		end if
		Case "qq":
		If Required=1 Then
			msg=name&"必须在1至"&max&"个字之间"
		else
			msg=name&"长度必须在1至"&max&"个字符之间"
		end if
		Case "weixinAcc":
		If Required=1 Then
			msg=name&"必须在1至"&max&"个字之间"
		else
			msg=name&"长度必须在1至"&max&"个字符之间"
		end if
		Case "msn":
		If Required=1 Then
			msg=name&"必须在1至"&max&"个字之间"
		else
			msg=name&"长度必须在1至"&max&"个字符之间"
		end if
		Case "email":
		If Required=1 Then
			msg=name&"必须在1至"&max&"个字之间"
		else
			msg=name&"长度必须在1至"&max&"个字符之间"
		end if
		Case "jg":
		If Required=1 Then
			msg=name&"必须在1至"&max&"个字之间"
		else
			msg=name&"长度必须在1至"&max&"个字符之间"
		end if
		Case "faren":
		If Required=1 Then
			msg=name&"必须在1至"&max&"个字之间"
		else
			msg=name&"长度必须在1至"&max&"个字符之间"
		end if
		Case "name":
		size=25
		max=name_length
		If Required=1 Then
			msg=name&"必须在1至"&max&"个字之间"
		else
			msg=name&"长度必须在1至"&max&"个字符之间"
		end if
		Case "person_name":
		If Required=1 Then
			msg="必须在1至50个字之间"
		else
			msg="长度必须在1至50个字符之间"
		end if
		Case "pym":
		size=15
		max=100
		If Required=1 Then
			msg=name&"必须在1至"&max&"个字之间"
		else
			msg=name&"长度必须在1至"&max&"个字符之间"
		end if
		Case "url"
		size=46
		min=8
		max=100
		If Required=1 Then msg=name&"必须在8至"&max&"个字之间"
		Case "hk_xz"
		dataType="number"
		min=0
		max=100
		msg="大于等于0小于等于100的数字"
		Case "address"
		size=46
		max=200
		If Required=1 Then
			min = 1
			msg=name&"长度必须在"& min &"至"&max&"个字符之间"
		else
			min = 0
			msg=name&"长度不能超过"&max&"个字符"
		end if
		Case "zip"
		If strformat="1" Then
			dataType="Zip"
			msg="格式不正确"
			formatHtml="&nbsp;例：100085"
			max=6
		end if
		Case "zijin" :
		dataType="number"
		msg = "必须是数字"
		max=9999999999
		Case "phone2" :
		If Required<>1 Then msg="长度不超过50个字"
		If strformat="1" Then
			If Required=1 Then
				dataType="Phone"
			else
				dataType="PhoneNull"
			end if
			msg="格式不正确"
			formatHtml="&nbsp;例：01012345678或01012345678"
		end if
		If tp=1 Then
			If ZBRuntime.MC(32000) Then
				formatHtml= formatHtml & "&nbsp;<img src='../images/15.gif' border='0' align='absbottom' style=' cursor:hand' onClick='phoneCall("&fieldName&".value)'>"
			end if
		end if
		Case "phone" :
		If Required<>1 Then msg="长度不超过50个字"
		If strformat="1" Then
			If Required=1 Then
				dataType="Phone"
			else
				dataType="PhoneNull"
			end if
			msg="格式不正确"
			formatHtml="&nbsp;例：01012345678或01012345678-6008"
			msg="格式不正确"
		end if
		If tp=1 Then
			If ZBRuntime.MC(32000) Then
				formatHtml= formatHtml & "&nbsp;<img src='../images/15.gif' border='0' align='absbottom' style=' cursor:hand' onClick='phoneCall("&fieldName&".value)'>"
			end if
		end if
		Case "mobile" :
		If Required<>1 Then msg="长度不超过50个字"
		If strformat="1" Then
			If Required=1 Then
				dataType="Mobile"
			else
				dataType="MobileNull"
			end if
			msg="格式不正确"
			formatHtml="&nbsp;例：13123456789"
		end if
		If tp=1 Then
			If ZBRuntime.MC(32000) Then
				formatHtml= formatHtml & "&nbsp;<img src='../images/sj.gif' border='0' align='absbottom' style=' cursor:hand' onClick='phoneCall("&fieldName&".value)'>"
			end if
		end if
		if open_67_13=1  and open_67_19<>1  Then
			formatHtml= formatHtml & "&nbsp;<img src='../images/message.gif' onClick=""sendSms("&fieldName&".value);function sendSms(phone){if (phone.length==11){window.open('../message/topadd.asp?phone='+phone+'','newsSendSMS','width=900,height=800,fullscreen=no,scrollbars=0,toolbar=0,status=no,resizable=1,location=no,menubar=no,menubar=no,left=20,top=100');} else{ alert('请填写正确的号码！');}}""  style='cursor:hand' border='0' alt='发送短信' align='absbottom'>"
		end if
		Case "fax" :
		If Required<>1 Then msg="长度不超过50个字"
		If strformat="1" Then
			If Required=1 Then
				dataType="Phone"
			else
				dataType="PhoneNull"
			end if
			msg="格式不正确"
			formatHtml="&nbsp;例：01012345678或01012345678-6008"
			msg="格式不正确"
		end if
		If tp=1 Then
			If ZBRuntime.MC(32000) Then
				formatHtml= formatHtml & "&nbsp;<img src='../images/15.gif' border='0' align='absbottom' style=' cursor:hand' onClick='phoneCall("&fieldName&".value)'>"
			end if
		end if
		Case "email" :
		If strformat="1" Then
			dataType="Email"
			msg="格式不正确"
			formatHtml="&nbsp;例：abc@hotmail.com"
		end if
		if open_77_13=1  and open_77_19<>1  Then
			formatHtml=formatHtml& "<img src='../images/email.gif' onClick=""sendEmail(email.value);function sendEmail(email){if (email.indexOf('@')>0){window.open('../email/index.asp?email='+email+'','newsSendEmail','width=900,height=800,fullscreen=no,scrollbars=0,toolbar=0,status=no,resizable=1,location=no,menubar=no,menubar=no,left=20,top=100');} else{ alert('请输入正确的邮箱！');}}""  style='cursor:hand' border='0' alt='发送邮件' align='absbottom'>"
		end if
		Case "qq" :
		If strformat="1" Then
			dataType="QQ"
			msg="格式不正确"
			formatHtml="&nbsp;例：34567"
		end if
		max=20
		Case "msn" :
		If strformat="1" Then
			dataType="Email"
			msg="格式不正确"
			formatHtml="&nbsp;例：abc@hotmail.com"
		end if
		max=50
		Case "bank_1" , "bank_2" ,"bank_3" , "bank_4" ,"bank_5" , "bank_6" ,"bank2_1" , "bank2_2" ,"bank2_3" , "bank2_4" ,"bank2_5" , "bank2_6" :
		max=100
		msg="太长了"
		End Select
		intType=rs("type")
		strHTML=""
		Change_strHTML=""
		If fieldName="pym" Then
			strHTML="&nbsp;&nbsp;"& name &"："
		else
			strHTML="<td width='10%'><div align='right'>"&name&"：</div></td>"
			strHTML=strHTML&"<td class='gray' width='20%' "
			If fieldName="name" Or fieldName="address" Or fieldName="url"  Then  strHTML=strHTML&  " colspan=3 "
			If intType=7 Or intType=8 Then  strHTML=strHTML&  " colspan=5 "
			strHTML=strHTML&">"
		end if
		Select Case intType
		Case 1:
		strHTML=strHTML&" <select name='"&fieldName&"'  STYLE='width: 120px' "
		If fieldName="sort" Then
			strHTML = strHTML& " onChange='inselect4();' "
		end if
		If fieldName="sort1" Then
			strHTML = strHTML& " onChange='setjf5();' "
		end if
		strHTML = strHTML& " dataType='"&dataType&"' "
		If Required=1 Then strHTML = strHTML& " min='"&min&"' "
		strHTML = strHTML& " max='"&max&"' msg='"&msg&"' "
		strHTML = strHTML& ">  "
		If fieldName="sort" Then
			ly_sql=""
			If tel_sort&""<>"" And limitsort1&""<>"" Then limitsort1=limitsort1&","&tel_sort
			If limitsort1&""<>"" Then ly_sql=" and ord in ("&limitsort1&")"
			set rss=conn.execute("select id,sort1 from sort4 where 1=1 "&ly_sql&" order by gate1 desc")
			i=0
			sort4=0
			strHTML = strHTML& "<option value=''></option>"
			while not rss.eof
				If tel_sort&""<>"" Then sort4=tel_sort
				strHTML = strHTML& "<option value='"&rss("id")&"' "
				if tel_sort&""=rss("id").value&"" Then strHTML = strHTML& " selected "
				strHTML = strHTML& ">"&rss("sort1")&"</option>"
				i=i+1
				'strHTML = strHTML& ">"&rss("sort1")&"</option>"
				rss.movenext
			wend
			rss.close
		ElseIf fieldName="sort1" Then
			ly_sql=""
			If tel_sort1<>"" And limitsort2&""<>"" Then limitsort2=limitsort2&","&tel_sort1
			If limitsort2&""<>"" Then ly_sql=" and ord in ("&limitsort2&")"
			strHTML = strHTML& "<option value=''></option>"
			set rss=conn.execute("select id,sort2,ord,gate2,MustHas from sort5 where sort1="&sort4&" "& ly_sql &" order by sort1,gate2 desc")
			Do while not rss.eof
				strHTML = strHTML& "<option value='"&rss("id")&"'"
				If tel_sort1=rss("id") Then strHTML = strHTML& " selected "
				strHTML = strHTML& ">"&rss("sort2")&"</option>"
				If rss("ord")&""=tel_sort1&"" Then
					gate2=rss("gate2")
				else
					If gate2>=rss("gate2") And rss("ord")<>sort1&"" And rss("MustHas")="1" Then
						Exit Do
					end if
				end if
				rss.movenext
			Loop
			rss.close
			set rss=Nothing
		ElseIf fieldName="ly" Then
			strHTML = strHTML& "<option value=''></option>"
			ly_sql=""
			If tel_ly<>"" And limitsort3&""<>"" Then limitsort3=limitsort3&","&tel_ly
			If limitsort3&""<>"" Then ly_sql=" and ord in ("&limitsort3&")"
			set rss=conn.execute("select ord,sort1 from sortonehy where gate2=13 "&ly_sql&" order by gate1 desc")
			while not rss.eof
				strHTML = strHTML& "<option value='"&rss("ord")&"'"
				If tel_ly=rss("ord") Then strHTML = strHTML& " selected "
				strHTML = strHTML& ">"&rss("sort1")&"</option>"
				rss.movenext
			wend
			rss.close
			set rss=Nothing
		ElseIf fieldName="trade" Then
			strHTML = strHTML& "<option value=''></option>"
			ly_sql=""
			If tel_trade<>"" And limitsort5&""<>"" Then limitsort5=limitsort5&","&tel_trade
			If limitsort5&""<>"" Then ly_sql=" and ord in ("&limitsort5&")"
			set rss=conn.execute("select ord,sort1 from sortonehy where gate2=11 "&ly_sql&" order by gate1 desc")
			while not rss.eof
				strHTML = strHTML& "<option value='"&rss("ord")&"'"
				If tel_trade=rss("ord") Then strHTML = strHTML& " selected "
				strHTML = strHTML& ">"&rss("sort1")&"</option>"
				rss.movenext
			wend
			rss.close
			set rss=Nothing
		ElseIf fieldName="jz" Then
			strHTML = strHTML& "<option value=''></option>"
			ly_sql=""
			If tel_jz<>"" And limitsort4&""<>"" Then limitsort4=limitsort4&","&tel_jz
			If limitsort4&""<>"" Then ly_sql=" and ord in ("&limitsort4&")"
			set rss=conn.execute("select ord,sort1 from sortonehy where gate2=14 "&ly_sql&" order by gate1 desc")
			while not rss.eof
				strHTML = strHTML& "<option value='"&rss("ord")&"'"
				If tel_jz=rss("ord") Then strHTML = strHTML& " selected "
				strHTML = strHTML& ">"&rss("sort1")&"</option>"
				rss.movenext
			wend
			rss.close
			set rss=Nothing
		ElseIf fieldName="credit" Then
			strHTML = strHTML& "<option value=''></option>"
			set rss=conn.execute("select ord,sort1,NowMoney from sortonehy where gate2=19 order by gate1 desc")
			while not rss.eof
				strHTML = strHTML& "<option value='"&rss("ord")&"'"
				If tel_credit=rss("ord") Then strHTML = strHTML& " selected "
				strHTML = strHTML& ">"&rss("sort1")&"("& Formatnumber(zbcdbl(rss("NowMoney")),num_dot_xs,-1) &")</option>"
'If tel_credit=rss("ord") Then strHTML = strHTML& " selected "
				rss.movenext
			wend
			rss.close
			set rss=Nothing
		ElseIf fieldName="role" Then
			strHTML = strHTML& "<option value=''></option>"
			set rss=conn.execute("select * from sort9 order by gate2 desc")
			while not rss.eof
				strHTML = strHTML& "<option value='"&rss("ord")&"'>"&rss("sort1")&"</option>"
				rss.movenext
			wend
			rss.close
			set rss=Nothing
		end if
		strHTML=strHTML&" </select>"
		If  fieldName="sort1" Then
			If ZBRuntime.mc("201103") then
				strHTML=strHTML&"&nbsp;<a href='javascript:void(0);' onclick=""javascript:window.open('../sort5/sort5map.asp?sort='+document.getElementsByName('sort')[0].value+'&sort1='+document.getElementsByName('sort1')[0].value,'gjFlowChart','width=' + 945 + ',height=' + 500 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=0,left=250,top=150');return false;"" target='_blank'>流程图</a>"
			end if
		end if
		Case 2 :
		If fieldName="year1" Then
			strHTML=strHTML&"<select name='birthdayType' id='birthdayType' onChange='getBirthYear()'><option value='0'>类型</option><option value='1'>公历</option><option value='2'>农历</option></select><select name='birthYear' id='birthYear' onChange='getBirthMonth()'>"
			for i=1901 to year(date)
				strHTML=strHTML&"<option value='"&i&"'"
				if i=year(date) then strHTML=strHTML&" selected"
				strHTML=strHTML&">"&i&"年</option>"
			next
			strHTML=strHTML&"</select><select name='birthMonth' id='birthMonth' onChange='getBirthDay()'><option value=''>选择月</option></select><select name='birthDay' id='birthDay'><option value=''>选择日</option></select>"
		else
			strHTML=strHTML& " <input type='text' name='"&fieldName&"' id='"&fieldName&"' "
			If fieldName="name" Then
				strHTML = strHTML& " onKeyUp=""ff4(this.value,document.getElementById('pym'));"
				If ists="1" Then strHTML = strHTML& "if(event.keyCode==13){showLikeCompany('"&fieldName&"',1);}"
				If point=1 Or enter=1 Then strHTML = strHTML& "callServer("&gate1&",this.value);"
				strHTML = strHTML& """ value='"&tel_name&"'  "
				strHTML = strHTML&  " maxlength="& name_length & " "
				If ists="1" Then strHTML = strHTML& " onmouseover='event.cancelBubble=true;' onfocus=""showLikeCompany('"&fieldName&"',1);"" "
			ElseIf fieldName="bank_1" Then
				strHTML = strHTML& " value='"&tel_bank_1&"' "
			ElseIf fieldName="bank_2" Then
				strHTML = strHTML& " value='"&tel_bank_2&"' "
			ElseIf fieldName="bank_3" Then
				strHTML = strHTML& " value='"&tel_bank_3&"' "
			ElseIf fieldName="bank_4" Then
				strHTML = strHTML& " value='"&tel_bank_4&"' "
			ElseIf fieldName="bank_5" Then
				strHTML = strHTML& " value='"&tel_bank_5&"' "
			ElseIf fieldName="bank_6" Then
				strHTML = strHTML& " value='"&tel_bank_6&"' "
			ElseIf fieldName="bank_7" Then
				strHTML = strHTML& " value='"&tel_bank_7&"' "
			ElseIf fieldName="bank2_1" Then
				strHTML = strHTML& " value='"&tel_bank2_1&"' "
			ElseIf fieldName="bank2_2" Then
				strHTML = strHTML& " value='"&tel_bank2_2&"' "
			ElseIf fieldName="bank2_3" Then
				strHTML = strHTML& " value='"&tel_bank2_3&"' "
			ElseIf fieldName="bank2_4" Then
				strHTML = strHTML& " value='"&tel_bank2_4&"' "
			ElseIf fieldName="bank2_5" Then
				strHTML = strHTML& " value='"&tel_bank2_5&"' "
			ElseIf fieldName="bank2_6" Then
				strHTML = strHTML& " value='"&tel_bank2_6&"' "
			ElseIf fieldName="bank2_7" Then
				strHTML = strHTML& " value='"&tel_bank2_7&"' "
			ElseIf fieldName="pym" Then
				strHTML = strHTML& " value='"&tel_pym&"' "
			ElseIf fieldName="khid" Then
				strHTML = strHTML& " value='"&khid&_
				"' class='jquery-auto-bh' autobh-options='cfgId:1,autoCheck:false,autoCreate:false'"
				'strHTML = strHTML& " value='"&khid&_
			ElseIf fieldName="address" Then
				strHTML = strHTML& " value='"& Replace(tel_address & "", Chr(0),"") &"' "
			ElseIf fieldName="faren" Then
				strHTML = strHTML& " value='"&tel_faren&"' "
			ElseIf fieldName="fax" Then
				strHTML = strHTML& " value='"&tel_fax&"' "
				If Not IsPhonePower(tel_cateid) And tel_fax <> "" Then
					strHTML = Replace(strHTML,"type='text'","type='password'")
				end if
			ElseIf fieldName="email" Then
				strHTML = strHTML& " value='"&tel_email&"' "
			ElseIf fieldName="url" Then
				strHTML = strHTML& " value='"&tel_url&"'"
			ElseIf fieldName="phone" Then
				strHTML = strHTML& " value='"&tel_phone&"'"
				If Not IsPhonePower(tel_cateid) And tel_phone <> "" Then
					strHTML = Replace(strHTML,"type='text'","type='password'")
				end if
			ElseIf fieldName="zip" Then
				strHTML = strHTML& " maxlength='10' onKeyUp=""value=value.replace(/[^\d]/g,'');"
				If point=1 Or enter=1 Then strHTML = strHTML& "callServer("&gate1&",this.value);"
				strHTML = strHTML& """ value='"&tel_zip&"'"
			ElseIf fieldName="person_name" Then
				strHTML = strHTML& " max='50' onKeyUp=""ff4(this.value,document.getElementById('pym2'));"
				If point=1 Or enter=1 Then strHTML = strHTML& "callServer("&gate1&",this.value);"
				strHTML = strHTML& """ "
			ElseIf fieldName="qq" Then
				strHTML = strHTML& " onKeyUp=""value=value.replace(/[^\d]/g,'');"
				If point=1 Or enter=1 Then strHTML = strHTML& "callServer("&gate1&",this.value);"
				strHTML = strHTML& """ "
			ElseIf fieldName="weixinAcc" Then
				If point=1 Or enter=1 Then strHTML = strHTML& " onKeyUp=""callServer("&gate1&",this.value);"""
				strHTML = strHTML& " value=""" & weixinAcc & """ maxlength=""100"""
			end if
			If point=1 Or enter=1 Then
				If fieldName<>"name" And fieldName<>"zip" And fieldName<>"person_name" And fieldName<>"qq" Then strHTML = strHTML& " onKeyUp=""callServer("&gate1&",this.value);"" "
				If fieldName<>"name"  Then strHTML = strHTML& " onfocus=""callServer("&gate1&",this.value);"" "
			end if
			strHTML = strHTML& " size='"&size&"' "
			If Required=1 Then strHTML = strHTML& " min='"&min&"'  "
			strHTML = strHTML& "dataType='"&dataType&"' max='"&max&"' msg='"&msg&"' "
			strHTML = strHTML& ">"
			If fieldName="person_name" Then  strHTML = strHTML& "<input name='pym2'  type='hidden' id='pym2' size='15'>"
			If fieldName="address" Then  strHTML = strHTML & showImageByArea(conn, ord, 0, "address")
		end if
		Case 3 :
		strHTML = strHTML& "<input type='radio' name='"&fieldName&"' value='男'>男&nbsp;<input type='radio' name='"&fieldName&"' value='女'>女&nbsp;"
		Case 4 :
		strHTML = strHTML&"<input name='area' type='hidden' id='area' size='10' value='"&tel_area&"'>"
		strHTML = strHTML&"<input name='areaname' type='text' id='areaname' size='15' maxlength='30' readonly='true' value='"&tel_areaname&"' onclick=""callServer2("&ord&",1);$('#w1').window('open');"" "
		If Required=1 Then strHTML = strHTML& " min='"&min&"'  "
		strHTML = strHTML& "dataType='"&dataType&"' max='"&max&"' msg='"&msg&"' "
		strHTML = strHTML& ">"
		strHTML = strHTML& "<div class='autocplclear' title='点击清空内容' onclick='cleararea()'></div>"
		Case 5 :
		strHTML=strHTML& " <input type='text' name='"&fieldName&"' id='"&fieldName&"' "
		If fieldName="age" Then
			strHTML = strHTML& " onkeyup=""this.value=this.value.replace(/\D/g,'')"" maxlength='3' "
		ElseIf fieldName="zijin" Then
			strHTML = strHTML& " onkeyup=""checkDot2('"&fieldName&"','2')"" oncontextmenu='self.event.returnValue=false' "
		else
			strHTML = strHTML& " onkeyup=""value=value.replace(/[^\d\.]/g,'');checkDot('"&fieldName&"','"&num_dot_xs&"')"" "
		end if
		strHTML = strHTML& " size='"&size&"' "
		If Required=1 Then strHTML = strHTML& " min='"&min&"' "
		If fieldName="zijin" Then
			strHTML = strHTML& " value='"&tel_zijin&"' "
			If Required = 0 then
				strHTML = strHTML& " cannull='1' "
			end if
		end if
		If fieldName="hk_xz" Then
			If tel_hk_xz="" Then
				tel_hk_xz=0
			end if
			strHTML = strHTML& " value='"&tel_hk_xz&"' max='"&max&"' "
		else
			strHTML = strHTML& " max='"&max&"' "
		end if
		strHTML = strHTML& " dataType='"&dataType&"' msg='"&msg&"' "
		strHTML = strHTML& ">"
		If fieldName="zijin" Then strHTML = strHTML& "&nbsp;万元&nbsp;"
		If fieldName="hk_xz" Then strHTML = strHTML& "&nbsp;%"
		If fieldName="age" Then strHTML = strHTML& "&nbsp;岁"
		Case 6 :
		strHTML=strHTML& " 销售 <input name='pernum1' type='text' size='5' value='"&tel_pernum1&"'  onKeyUp=""this.value=this.value.replace(/\D/g,'')""  dataType='LimitB' min='0' max='6'  msg='长度必须在6位之内'> 技术 <input name='pernum2' type='text' size='5'  value='"&tel_pernum2&"'onKeyUp=""this.value=this.value.replace(/\D/g,'')""   dataType='LimitB' min='0' max='6'  msg='长度必须在6位之内'>"
		Case 7 :
		strHTML=strHTML& "<textarea name='"&fieldName&"' style='display:none' cols='1' rows='1'>"& Replace(Replace(tel_intro & "","<","&lt;"),"&gt;","") &"</textarea><IFRAME ID='eWebEditor1' SRC='../edit/ewebeditor.asp?id="&fieldName&"&style=news' FRAMEBORDER='0' SCROLLING='no' WIDTH='100%' HEIGHT='300' marginwidth='1' marginheight='1' name='wfasdg'></IFRAME>"
		Case 8 :
		If fieldName="product" Then strvalue=tel_product
		If fieldName="c2" Then strvalue=tel_c2
		If fieldName="c3" Then strvalue=tel_c3
		If fieldName="c4" Then strvalue=tel_c4
		strHTML=strHTML& "<textarea name='"&fieldName&"' style='width:80%' cols='80' rows='4' dataType='Limit' max='4000'  msg='最多4000个字'>"&strvalue&"</textarea>"
		End Select
		If Required=1 Then strHTML = strHTML&" <span class='red'>*</span>"
		strHTML = strHTML&formatHtml
		Response.write strHTML
		If fieldName="pym" Then
			If isupdate=False Then
				If intsort=2 Then
					sel2=" selected "
				else
					sel1=" selected "
				end if
				Response.write "&nbsp;&nbsp;<select onchange=""window.location.href='add.asp?intsort='+this.value""><option value=1 "&sel1&">单位客户</option><option value=2 "&sel2&">个人客户</option>"
				'sel1=" selected "
			end if
			Response.write "<table style=""vertical-align: middle;display:inline-block;zoom:1;*display:inline ""><tr><th>&nbsp;<img src=""../images/baidu.png"" border=""0"" alt=""百度搜索"" onclick=""openSearch('baidu')"" style=""cursor=pointer""/>&nbsp;<img src=""../images/sky-eye.jpg"" border=""0"" alt=""天眼查"" onclick=""openSearch('skyeye')"" style=""cursor=pointer;""/>&nbsp;<img src=""../images/Q-search.png"" border=""0"" alt=""企查查"" onclick=""openSearch('Qsearch')"" style=""cursor=pointer;""/></th></tr></table>" & vbcrlf & "" & vbcrlf & "<script language=""javascript"" type=""text/javascript"">" & vbcrlf & "    function openSearch(lname) {" & vbcrlf & "             if (document.getElementById(""u_name""))" & vbcrlf & "            { " & vbcrlf & "                      if (typeof (document.getElementById(""u_name"")) != ""undefined"") {" & vbcrlf & "                            var keys = encodeURIComponent(document.getElementById(""u_name"").value);" & vbcrlf & "                   }" & vbcrlf & "                      else {" & vbcrlf & "                          var keys = """";" & vbcrlf & "                    }" & vbcrlf & "               }" & vbcrlf & "               else " & vbcrlf & "           {" & vbcrlf & "                       if (typeof (document.getElementById(""name"")) != ""undefined"") {" & vbcrlf & "                              var keys = encodeURIComponent(document.getElementById(""name"").value);" & vbcrlf & "                    }" & vbcrlf & "                       else {" & vbcrlf & "                          var keys = """";" & vbcrlf & "                    }" & vbcrlf & "               }" & vbcrlf & "               switch (lname) {" & vbcrlf & "                    case ""skyeye"":" & vbcrlf & "                        window.open(""https://www.tianyancha.com""+ (keys.length>0?""/search?key="" + keys : """"));" & vbcrlf & "                  break;" & vbcrlf & "              case ""Qsearch"":" & vbcrlf & "                       window.open(""http://www.qichacha.com""+ (keys.length>0?""/search?key="" + keys : """"));" & vbcrlf & "                   break;" & vbcrlf & "            case ""baidu"":" & vbcrlf & "                window.open(""http://www.baidu.com/s?wd="" + keys); " & vbcrlf & "                break;" & vbcrlf & "            case ""google"":" & vbcrlf & "                window.open(""http://www.google.com.hk/search?q="" + keys);" & vbcrlf & "                break;" & vbcrlf & "        }" & vbcrlf & "    }" & vbcrlf & "</script>"
			
		ElseIf fieldName="ly" Then
			set rss=conn.execute("select intro from setopen where sort1=1")
			if Not rss.eof then
				jf=rss("intro")
			end if
			rss.close
			set rss=nothing
			if jf="1" And ZBRuntime.MC(7000) Then
				strjf1=""
				strjf2=""
				If tel_jf2="1" Then
					strjf1=" selected "
				else
					strjf2=" selected "
				end if
				Response.write "&nbsp;<select name='jf2'><option value='1' "&strjf1&">积分</option><option value='0' "&strjf2&">不积分</option></select>"
			end if
		end if
		If point=1 Or enter=1 Then Response.write "<span class='red' name='ts' id='ts_"&gate1&"'></span>"
		If enter=1 Then Response.write "<input type='hidden' name='jzlr' value='"&gate1&"'>"
		If fieldName<>"name" Then Response.write "</td>"
		If fieldName="year1" Then Response.write "<script language='javascript' defer='defer'>getBirthYear();</script>"
		n=n+1
'If fieldName="year1" Then Response.write "<script language='javascript' defer='defer'>getBirthYear();</script>"
		If fieldName="address" Or fieldName="url" Then
			n=n+1
'If fieldName="address" Or fieldName="url" Then
		ElseIf intType=8 Or intType=7 Then
			n=n+2
'ElseIf intType=8 Or intType=7 Then
		end if
		rs.movenext
		If rs.eof Then
			If n Mod 3>0 Then Response.write "<td colspan='"&(3-(n Mod 3))*2&"'></td>"
'If rs.eof Then
		end if
		If n Mod 3=0  Or rs.eof Then Response.write "</tr>"
		If rs.eof And Sort2<>4 Then
			If Sort2=1 Then
				Call zdyfield_show()
				Response.write getExtended2(1,ord,limitsort9)
			ElseIf Sort2=2 Then
				If ZBRuntime.MC(201106) Then call show_Quali_list(ord,105,qualifications,strType,6,6)
			end if
			Response.write getExtended1(1,ord)
		end if
		If rs.eof And Sort2=4 Then
			Response.write "" & vbcrlf & "                             <tr  id=""cwxx54"" style=""display: none"">" & vbcrlf & "                                     <td ><div align=""right"">账期：</div></td>" & vbcrlf & "                                 <td class=""gray""><input name=""fkdays"" id=""fkdays"" value="""
			Response.write tel_fkdays
			Response.write """ type=""text"" size=""15"" maxlength=""3"" onpropertychange=""formatData(this,'int');"" onKeyUp=""checkDot('fkdays','0')""  dataType=""Range"" min=0 max=""365""  msg=""账期必须是0到365之间的数字""> 天</td>" & vbcrlf & "                                    <td><div align=""right"">结算日期：</div></td>" & vbcrlf & "                                      <td class=""gray"">每月 <select name=""fkdate"" >" & vbcrlf & "                                            <option value=""0""></option>" & vbcrlf & "                                               "
			For i=1 To 31
				Response.write "" & vbcrlf & "                                                     <option value="""
				Response.write i
				Response.write """ "
				Response.write iif(tel_fkdate=i,"selected","")
				Response.write ">"
				Response.write i
				Response.write "</option>" & vbcrlf & "                                                    "
			next
			Response.write "" & vbcrlf & "                                             </select>号</td>" & vbcrlf & "                                        <td colspan=""2""></td>" & vbcrlf & "                             </tr>" & vbcrlf & "                           <tr  id=""cwxx53"" style=""display: none;"">" & vbcrlf & "                                    <td colspan=""6""><span class='red' style="" margin-top:12px; margin-left:30px;"">温馨提示：如果当前月没有31号，则结算日期为30或31号时，按照当前月最后一天生成收款计划；</span></td>" & vbcrlf & "                          </tr>" & vbcrlf & "                           "
		end if
	wend
	end if
	rs.close
	action1="客户" & strtitle
	If intsort = 1 Then
		action1="客户" & strtitle  & "(单位)"
	else
		action1="客户" & strtitle  & "(个人)"
	end if
	Response.write "" & vbcrlf & "                    </table>" & vbcrlf & "                    <script src=""../Script/wk_add_1.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ language=""JavaScript""></script>" & vbcrlf & "                    <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""0"" bgcolor=""#C0CCDD"" id=""content"" height=""30"" style=""margin-top:-1px"">" & vbcrlf & "                        <tr>" & vbcrlf & "                      <td colspan=""6"" valign=""center"" class=""gray"">" & vbcrlf & "                                <div align=""center"">" & vbcrlf & "                                    "
	If isupdate=False Or editNum=3 Then
		If ZBRuntime.MC(201106) Then
			Response.write "<input type='button' name='Submit426' value='暂存' onclick='ask("
			Response.write intsort
			Response.write ","
			Response.write ",4);' class='anybutton2' />&nbsp;"
		end if
		Response.write "" & vbcrlf & "                                    <input type=""button"" name=""Submit422"" value=""领用"" class=""anybutton2"" onclick=""ask("
		Response.write intsort
		Response.write ",1,2)"" />" & vbcrlf & "                                    <input type=""button"" name=""Submit424"" value=""领用增加"" onclick=""ask("
		Response.write intsort
		Response.write ",2,2);"" class=""anybutton2"" />" & vbcrlf & "                                    <input type=""button"" name=""Submit42"" value=""公用"" onclick=""ask("
		Response.write intsort
		Response.write ",1,1);"" class=""anybutton2"" />" & vbcrlf & "                                    <input type=""button"" name=""Submit425"" value=""公用增加"" onclick=""ask("
		Response.write intsort
		Response.write ",2,1);"" class=""anybutton2"" />" & vbcrlf & "                                    "
	else
		Response.write "" & vbcrlf & "                                    <input type='button' name='Submit43' value='保存' onclick='ask("
		Response.write intsort
		Response.write ",3,3);' class='anybutton2' />" & vbcrlf & "                                    "
	end if
	Response.write "" & vbcrlf & "                                    <input type=""reset"" value=""重填"" name=""B2"" class='anybutton2'>" & vbcrlf & "                                    <input type=""hidden"" value=""0"" name=""sp_qualifications"">" & vbcrlf & "                                    <input type=""hidden"" value=""0"" name=""cateid_sp_qualifications"">" & vbcrlf & "                                    <br>" & vbcrlf & "                                    <br>" & vbcrlf & "                                </div>" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                    </table>" & vbcrlf & "                </form>" & vbcrlf & "            </td>" & vbcrlf & "        </tr>" & vbcrlf & "    </table>" & vbcrlf & "    "
	if Cists="1" then
		Response.write "" & vbcrlf & "    <div id=""tel_namediv"" style=""position: absolute; width: 150px; background-color: #E3EAFA; padding: 2px,2px,2px,2px; display: none"" onmouseover=""event.cancelBubble=true;"">" & vbcrlf & "    </div>" & vbcrlf & "    <script src=""../Script/wk_add_2.js?ver="
'if Cists="1" then
		Response.write Application("sys.info.jsver")
		Response.write """ language=""javascript""></script>" & vbcrlf & "    "
	end if
	phoneNumber=request.QueryString("phone")
	if Len(phoneNumber)>5 Then
		If InStr(phoneNumber,"-") = 2 Then
'if Len(phoneNumber)>5 Then
			phoneNumber = Right(phoneNumber, Len(phoneNumber)-2)
'if Len(phoneNumber)>5 Then
		end if
		If InStr(phoneNumber,"0") = 1 And InStr(phoneNumber,"1") = 2 And mid(phoneNumber,3,1) <> "0" Then
			phoneNumber = Right(phoneNumber,Len(phoneNumber)-1)
'If InStr(phoneNumber,"0") = 1 And InStr(phoneNumber,"1") = 2 And mid(phoneNumber,3,1) <> "0" Then
		end if
		Response.write "" & vbcrlf & "    <script language=""javascript"">" & vbcrlf & "     phoneNum2V("""
		Response.write phoneNumber
		Response.write """);" & vbcrlf & "    </script>" & vbcrlf & "    "
	end if
	call close_list(1)
	Response.write "" & vbcrlf & "    <div id=""w1"" class=""easyui-window"" title=""区域选择"" style=""width: 320px; height: 490px; padding: 5px; background: #fafafa; top: 130px; left: 290px;"" closed=""true""></div>" & vbcrlf & "    <div id=""w2"" class=""easyui-window"" title=""人员选择"" style=""width: 560px; height:380px; padding: 5px; background: #fafafa; top: 130px; left: 290px;"" closed=""true""></div>" & vbcrlf & "    "
	Function showImageByArea(cn ,ord , stype , objid )
		Dim html ,rs ,hascoord, lat ,lng  : lat = 0  : lng = 0
		hascoord = 0
		Dim address : address= ""
		Set rs = cn.execute("select address,  isnull(lng,0) as lng ,isnull(lat,0) as lat , isnull(hascoord,0) as hascoord  from tel where ord="& ord)
		If rs.eof = False Then
			lng = rs("lng").value
			lat=  rs("lat").value
			hascoord =rs("hascoord").value
			address = rs("address").value
		end if
		rs.close
		html = ""
		If Len(address)>0 Or stype=0 Then html =  "&nbsp;"
		html= html& "<img  src='../images/coordinate.png' onclick=""OpenMap(this,'"& objid &"',"& stype &","& ord &");"" style='cursor:pointer;width:20px;height:20px:'><input id='lng' name='lng' type='hidden' value='"& lng &"'><input id='lat' name='lat' type='hidden' value='"& lat &"'>"
		showImageByArea = html
	end function
	Response.write "" & vbcrlf & "<style>" & vbcrlf & "div li {list-style-type:none;cursor:pointer}" & vbcrlf & "</style>" & vbcrlf & "<div id=""map_div"" style=""border:1px solid #ccc;padding:5px;background: #fff;display:none;position:absolute;width:720px;height:430px;"">" & vbcrlf & " <table style=""width:100%;height:100%;background: #fafafa;"">" & vbcrlf & "        <tr>" & vbcrlf & "            <td width=""250px"" height=""35px"" id=""coordtd1""><input type=text size=25 name=""searchtext"" style=""width:180px;height:22px;"" id = ""searchtext"" onkeyup=""onkeySearch()"">" & vbcrlf & "          <input type=""button"" class=""oldbutton anybutton2"" value=""检索"" onclick=""searchCoordinate()"" >" & vbcrlf & "          <!-- <img style='width:240px;height:180px:' src='../images/coord12.png'> --></td>" & vbcrlf & "               <td height=""35px""><div style=""display:inline"" id=""setdiv""><img id=""imghander"" style='border:1px solid #fff;width:70px;height:70px:' src='../images/coord24.png' onclick=""setPoint(this)""></div></td>" & vbcrlf & "               <td>经度 <input type=text size=10 name=""newlng"" id=""newlng"" style=""width:80px;height:22px"" readonly onkeydown=""return false""> 纬度 <input type=text size=10 name=""newlat"" style=""width:80px;height:22px"" id=""newlat"" readonly onkeydown=""return false"">" & vbcrlf & "          </td>" & vbcrlf & "           <td align=""right"">" & vbcrlf & "                        <div style=""display:inline"" id=""savediv""><input type=""button"" class=""oldbutton anybutton2"" value=""确定"" onclick=""saveCoordinate()"">&nbsp;</div>" & vbcrlf & "             <input type=""button"" class=""oldbutton anybutton2"" value=""关闭"" onclick=""closeMap()"">" & vbcrlf & "                    <input type=""hidden"" value=""0"" id=""coordstype"">" & vbcrlf & "                       <input type=""hidden"" value=""0"" id=""coordaddtrss"">" & vbcrlf & "             </td>" & vbcrlf & "   </tr>" & vbcrlf & "   <tr>" & vbcrlf & "             <td id=""coordtd2""><div id=""coordlist"" style=""width:240px;height:390px;overflow-y:auto;overflow-x:hidden;"">            " & vbcrlf & "                <DIV style=""BORDER-BOTTOM: #ccc 1px solid; BORDER-LEFT: #ccc 1px solid; FONT: 12px arial,sans-serif; BORDER-TOP: #ccc 1px solid; BORDER-RIGHT: #ccc 1px solid;height:99%"">" & vbcrlf & "                        <DIV style=""BACKGROUND: #fff;margin-top:50%;text-align:center;"">暂无检索结果!</DIV>" & vbcrlf & "               </DIV>" & vbcrlf & "          </div></td>" & vbcrlf & "             <td colspan=3> " & vbcrlf & "                 <div style=""width:100%; height:390px;"" >" & vbcrlf & "                  <div id=""container"" style=""width:100%; height:100%;""></div>" & vbcrlf & "                 </div>" & vbcrlf & "          </td>" & vbcrlf & "   </tr>" & vbcrlf & "   </table>" & vbcrlf & "</div>" & vbcrlf & "<script>" & vbcrlf & "document.write(""<script type='text/javascript' src='http://api.map.baidu.com/api?v=2.0&ak=LfGdXDPYrseQPmslbBpxdSPh'/>"") "& vbcrlf &" </script> "& vbcrlf &"<script language='javascript'>" & vbcrlf & "    var map = null ,local=null ,oldaddress = """" , Points = [] , P_address=[] , coordord, coordstype ,coordaddtrss , isSetPoint , clickMarker=null ;" & vbcrlf & "   function OpenMap(img, objid , stype,ord ){" & vbcrlf &           "var div = document.getElementById(""map_div"");" & vbcrlf & "             var tdleft = img.parentNode.offsetLeft; //img所在td 左距离" & vbcrlf & "              var bodyw = document.body.offsetWidth;//浏览器可见宽度" & vbcrlf & "          div.style.top = img.parentNode.offsetTop+60+""px"";" & vbcrlf & "         div.style.left = ((bodyw-tdleft>720) ? tdleft : (bodyw-745)) +""px""; //" & vbcrlf & "           div.style.display="""";" & vbcrlf & "             isSetPoint = false;" & vbcrlf & "             //初始赋值" & vbcrlf & "              var lat = document.getElementById(""lat"").value;   " & vbcrlf & "                var lng = document.getElementById(""lng"").value;" & vbcrlf & "           lat = lat==""0"" ? "" : lat;" & vbcrlf & "          lng = lng ==""0"" ? "" : lng;" & vbcrlf & "         if (stype==""1"" && lat!="")" & vbcrlf &  "         {      "  & vbcrlf & "                        $(""#coordtd1"").hide(); "& vbcrlf &  "                   $(""#coordtd2"").hide();" & vbcrlf &  "                   $(""#setdiv"").hide();" & vbcrlf & "                      $(""#savediv"").hide(); " & vbcrlf & "               }" & vbcrlf & "               document.getElementById(""newlat"").value = lat;" & vbcrlf & "            document.getElementById(""newlng"").value = lng;" & vbcrlf & "            coordstype =stype;" & vbcrlf & "              coordord = ord;" & vbcrlf & "         coordaddtrss = objid;" & vbcrlf & "           if(!map) { map = new BMap.Map(""container""); map.addEventListener(""click"",hideBtn);}// 创建地图实例" & vbcrlf & "         local = new BMap.LocalSearch(map, {" & vbcrlf & "                     pageCapacity:5," & vbcrlf & "                 renderOptions: {map: map, panel: ""coordlist"" , selectFirstResult: true,autoViewport:true}," & vbcrlf & "                        onMarkersSet: function(pois){" & vbcrlf &"                          Points = [];" & vbcrlf & "                            P_address=[];" & vbcrlf & "                           for (var i = 0; i < pois.length; i ++){" & vbcrlf & "                             Points.push(pois[i].point);" & vbcrlf & "                    P_address.push(pois[i].address);" & vbcrlf & "                             }" & vbcrlf & "                               //地图标记点击事件" & vbcrlf & "                              $(""span.BMap_noprint"").click(function(){" & vbcrlf & "                                       var indexId =  $(this).index();" & vbcrlf & "                                 setPointInfo(indexId);" & vbcrlf & "                          })" & vbcrlf & "                      }," & vbcrlf & "                      onResultsHtmlSet:function(e){" & vbcrlf & "                           //检索结果列表点击事件" & vbcrlf & "                          var lis =e.getElementsByTagName(""li"");" & vbcrlf & "                              for (var i = 0; i < lis.length; i ++){" & vbcrlf & "                                  $(lis[i]).click(function(){" & vbcrlf & "                                             var indexId =  $(this).index();" & vbcrlf & "                                         setPointInfo(indexId);" & vbcrlf & "                                  });" & vbcrlf & "                             }" & vbcrlf & "                               //隐藏详情 更多链接" & vbcrlf & "                             $(""#coordlist"").find(""a[href*='http']"").hide();" & vbcrlf & "                 }" & vbcrlf & "               });" & vbcrlf & "             document.getElementById(""imghander"").style.border=""1px solid #fff"";" & vbcrlf & "         isSetPoint=false;" & vbcrlf & "               map.removeEventListener(""click"",mapclick);" & vbcrlf & "" & vbcrlf & "                var searchtext ="""";" & vbcrlf & "            //默认地图中心 " & vbcrlf & "         var initlat = 39.915;" & vbcrlf & "           var initlng = 116.404;" & vbcrlf & "          var zoom = 15;" & vbcrlf & "          if (lat=="""" && lng == """")" & vbcrlf & "           {" & vbcrlf & "                       if (stype==""1""){" & vbcrlf & "                          searchtext = document.getElementById(objid).innerHTML.replace(/(^\s*)|(\s*$)/g, """");//去掉左右空格" & vbcrlf & "                  }else{" & vbcrlf & "                          searchtext = document.getElementById(objid).value.replace(/(^\s*)|(\s*$)/g, """");//去掉左右空格" & vbcrlf & "                    }" & vbcrlf & "                       oldaddress = searchtext;" & vbcrlf & "                        document.getElementById(""searchtext"").value = searchtext;" & vbcrlf &"                      if (searchtext.length>0){$(""#coordlist"").html("");local.search(searchtext);}else{ "& vbcrlf &"                            //定位当前位置   "& vbcrlf &"                                 var geolocation = new BMap.Geolocation(); "& vbcrlf &"                                geolocation.getCurrentPosition(function(r){ "& vbcrlf &"                                      if(this.getStatus() == BMAP_STATUS_SUCCESS){" & vbcrlf & "                                         //var mk = new BMap.Marker(r.point);" & vbcrlf & "                                            //map.addOverlay(mk);" & vbcrlf & "                                           map.panTo(r.point);" & vbcrlf & "                                     }      " & vbcrlf & "                         },{enableHighAccuracy: true})" & vbcrlf & "                   }" & vbcrlf & "               }else{" & vbcrlf & "                  initlng =lng;" & vbcrlf & "                       initlat = lat;" & vbcrlf & "                  var mk = new BMap.Marker(new BMap.Point(lng, lat));" & vbcrlf & "                     map.addOverlay(mk);" & vbcrlf & "                     zoom = 17" & vbcrlf & "                       //map.panTo(point);" & vbcrlf & "             }" & vbcrlf & "               var point =new BMap.Point(initlng, initlat);" & vbcrlf & "            map.centerAndZoom(point, zoom);                                 // 初始化地图，设置中心点坐标和地图级别" & vbcrlf & "         map.enableScrollWheelZoom();                                    // 开启滚轮缩放地图" & vbcrlf & "             map.enableKeyboard();                                                   // 开启键盘操作（方向键和小键盘区移动地图）" & vbcrlf & "             map.addControl(new BMap.NavigationControl());   // 开启地图级别操作" & vbcrlf & "             " & vbcrlf & "        }" & vbcrlf & "       " & vbcrlf &" function setPointInfo(indexid){ "& vbcrlf &"          if (Points.length>=indexid) "& vbcrlf &"              { "& vbcrlf &"                        document.getElementById(""newlat"").value = Points[indexid].lat; "& vbcrlf &"                     document.getElementById(""newlng"").value = Points[indexid].lng;" & vbcrlf &"                     document.getElementById(""searchtext"").value = P_address[indexid];" & vbcrlf & "            }" & vbcrlf & "       }" & vbcrlf & "" & vbcrlf & "       function closeMap(){" & vbcrlf & "            document.getElementById(""map_div"").style.display=""none"";" & vbcrlf & "    }" & vbcrlf & "       " & vbcrlf & "        function searchCoordinate(){" & vbcrlf & "            var searchtext = document.getElementById(""searchtext"").value" & vbcrlf & "                searchtext = searchtext.replace(/(^\s*)|(\s*$)/g, """");//去掉左右空格" & vbcrlf & "              if (searchtext.length>0){local.search(searchtext);}" & vbcrlf & "     }" & vbcrlf & "" & vbcrlf & "       function onkeySearch(){" & vbcrlf & "         var e = event || window.event || arguments.callee.caller.arguments[0];         " & vbcrlf & "          if(e && e.keyCode==13){ // enter 键" & vbcrlf & "                      searchCoordinate();" & vbcrlf & "            }" & vbcrlf & "       }" & vbcrlf & "       function setPoint(obj){" & vbcrlf & "         try{" & vbcrlf & "                    if (isSetPoint)" & vbcrlf & "                 {" & vbcrlf &" obj.style.border=""1px solid #fff"";" & vbcrlf &"                                 isSetPoint=false; "& vbcrlf &"                                map.removeEventListener(""click"",mapclick); "& vbcrlf &"                         }else{ "& vbcrlf &"                           obj.style.border=""1px solid #000""; "& vbcrlf &"                                 isSetPoint=true; "& vbcrlf &"                                 map.addEventListener(""click"",mapclick);" & vbcrlf & "                     }" & vbcrlf & "               }catch(e){}" & vbcrlf & "     }" & vbcrlf & "" & vbcrlf & "function hideBtn(){" & vbcrlf & "    setTimeout(function(){" & vbcrlf & "   $(""input[value=导航]"").hide();" & vbcrlf & "   },1000)" & vbcrlf & " " & vbcrlf & "}" & vbcrlf & "       function mapclick(e){" & vbcrlf &" var pt = e.point; "& vbcrlf &"                if (clickMarker){ map.clearOverlays();} "& vbcrlf &"          clickMarker = new BMap.Marker(pt); "& vbcrlf &"               map.addOverlay(clickMarker); "& vbcrlf &"         "& vbcrlf &"              document.getElementById(""newlat"").value = pt.lat; "& vbcrlf &"          document.getElementById(""newlng"").value = pt.lng;" & vbcrlf & "           var geoc = new BMap.Geocoder();" & vbcrlf & "         geoc.getLocation(pt, function(rs){" & vbcrlf & "                      var addComp = rs.addressComponents;" & vbcrlf & "                     var address = (addComp.province==addComp.city? addComp.city : addComp.province+addComp.city) +addComp.district+ addComp.street + addComp.streetNumber;" & vbcrlf & "                     document.getElementById(""searchtext"").value = address;" & vbcrlf & "            });" & vbcrlf & "     }" & vbcrlf & "" & vbcrlf & "       function saveCoordinate(){" & vbcrlf & "              var canclose = true;" & vbcrlf & "            var lat = document.getElementById(""newlat"").value;      " & vbcrlf & "                var lng = document.getElementById(""newlng"").value;" & vbcrlf & "                if (lat==""0"" || lat == """" || lng == """" || lng ==""0"")" & vbcrlf & "            {" & vbcrlf & "                       alert(""请设置客户地址经纬度"");" & vbcrlf & "                    return;" & vbcrlf & "         }" & vbcrlf & "               var address = document.getElementById(""searchtext"").value;" & vbcrlf & "                if (coordstype==""1"")" & vbcrlf & "              {//需要提交坐标 并保存" & vbcrlf & "                  if (oldaddress.length==0 && address.length==0)" & vbcrlf & "                  {" & vbcrlf & "                               alert(""请输入客户地址!"");" & vbcrlf & "                         return;" & vbcrlf & "                 }" & vbcrlf & "                       $.ajax({" & vbcrlf & "                                url:""../work/saveCoordinate.asp?__msgid=__sys_dosave&ord=""+ coordord + ""&lat=""+ lat + ""&lng="" + lng + ""&address=""+escape(address)," & vbcrlf & "                              type:""POST""," & vbcrlf & "                              success: function(data){ " & vbcrlf & "                                       if (data!=""ok""){" & vbcrlf & "                                          canclose = false;" & vbcrlf & "               alert(data);    " & vbcrlf & "                                        }else{" & vbcrlf & "                                          alert(""保存成功!"");" & vbcrlf & "                                       }" & vbcrlf & "                               }," & vbcrlf & "                              async:false     " & vbcrlf & "                        });" & vbcrlf & "             }" & vbcrlf & "               if (canclose==true)" & vbcrlf & "             {       " & vbcrlf & "                        document.getElementById(""lat"").value = lat;" & vbcrlf & "                    document.getElementById(""lng"").value = lng;" & vbcrlf & "                       if (coordstype==""1""){" & vbcrlf & "                             if (oldaddress.length==0){document.getElementById(coordaddtrss).innerHTML = address + ""&nbsp;"";}" & vbcrlf & "                  }else{" & vbcrlf & "                          //if (document.getElementById(coordaddtrss).value=="""")" & vbcrlf & "                         //{" & vbcrlf & "                                     document.getElementById(coordaddtrss).value = address;" & vbcrlf & "                          //}" & vbcrlf & "                     }" & vbcrlf & "                       closeMap();" & vbcrlf & "             }" & vbcrlf & "       }" & vbcrlf & "</script>"
	Response.write "" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & "<iframe id=""sdate"" name=""sdate"" style=""display: none; height: 0px; width: 0px"">" & vbcrlf & "</frame>" & vbcrlf & ""
	
%>
