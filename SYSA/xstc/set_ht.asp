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
'Response.write sysCurrPath
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
'c = Lcase(Mid(name, i, 1))
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
	
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body {" & vbcrlf & "      margin-top: 0px;" & vbcrlf & "        background-color: #FFFFFF;" & vbcrlf & "      margin-left: 0px;" & vbcrlf & "       margin-right: 0px;" & vbcrlf & "      margin-bottom: 0px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".tcblgram{margin-top:8px; margin-bottom:8px;}" & vbcrlf & ".tcblgram li{" & vbcrlf & "  border: 1px solid #C0CCDD;" & vbcrlf & "      line-height: 26px;" & vbcrlf & "      margin: 2px;" & vbcrlf & "    float: left;" & vbcrlf & "    height: 26px;" & vbcrlf & "    list-style:none;"& vbcrlf & "        width: 100px;" & vbcrlf & "   text-align: center;" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & "</style>" & vbcrlf & "<script language=""javascript"" src=""../sortcp/function.js?ver="
	Response.write Application("sys.info.jsver")
'Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"" src=""cp_ajax.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""JavaScript"" type=""text/JavaScript"">" & vbcrlf & "<!--" & vbcrlf & "function MM_jumpMenu(targ,selObj,restore){ //v3.0" & vbcrlf & "eval(targ+"".location=\'""+selObj.options[selObj.selectedIndex].value+""\'"");" & vbcrlf & "if (restore) selObj.selectedIndex=0;" & vbcrlf & "}" & vbcrlf & "//-->" & vbcrlf & "</script>" & vbcrlf & "<script language=javascript>" & vbcrlf & "function inselect4()" & vbcrlf & "{" & vbcrlf & "document.date.sort1.length=0;" & vbcrlf & "if(document.date.sort.value==""0""||document.date.sort.value==null)" & vbcrlf & "document.date.sort1.options[0]=new Option('客户分类','0');" & vbcrlf & "else" & vbcrlf & "{" & vbcrlf & "for(i=0;i<ListUserId4[document.date.sort.value].length;i++)" & vbcrlf & "{" & vbcrlf & "document.date.sort1.options[i]=new Option(ListUserName4[document.date.sort.value][i],ListUserId4[document.date.sort.value][i]);" & vbcrlf & "}" & vbcrlf & "}" & vbcrlf & "var index=document.date.sort.selectedIndex;" & vbcrlf & "//sname.innerHTML=document.date.sort.options[index].text" & vbcrlf & "} " & vbcrlf & "" & vbcrlf & "//-->" & vbcrlf & "</script>" & vbcrlf & ""
'Response.write Application("sys.info.jsver")
	dim MODULES
	MODULES=session("zbintel2010ms")
	Response.write "<script language=""javascript"">"&chr(13)
	Response.write "<!--"&chr(13)
'Response.write "<script language=""javascript"">"&chr(13)
	Response.write "var ListUserName4=new Array();"&chr(13)
	Response.write "var ListUserId4=new Array();"&chr(13)
	set rss=conn.execute("select * from sort4")
	while not rss.eof
		sid4=rss("id")
		Response.write "ListUserName4["&sid4&"]=new Array();"&chr(13)
		Response.write "ListUserId4["&sid4&"]=new Array();"&chr(13)
		Response.write "ListUserName4["&sid4&"][0]='"& rss("sort1") & "';"&chr(13)
		Response.write "ListUserId4["&sid4&"][0]='';"&chr(13)
		set rsi=conn.execute("select * from sort5 where sort1="&rss("id"))
		index4=1
		while not rsi.eof
			Response.write "ListUserName4["&sid4&"]["&Index4&"]='"&rsi("sort2")&"';"&chr(13)
			Response.write "ListUserId4["&sid4&"]["&Index4&"]='"&rsi("Id")&"';"&chr(13)
			Index4=Index4+1
'Response.write "ListUserId4["&sid4&"]["&Index4&"]='"&rsi("Id")&"';"&chr(13)
			rsi.movenext
		wend
		rsi.close
		set rsi=nothing
		rss.movenext
	wend
	rss.close
	set rss=nothing
	Response.write "//-->"&chr(13)
'set rss=nothing
	Response.write "</SCRIPT>"&chr(13)
	Response.write "" & vbcrlf & "</head>" & vbcrlf & ""
	cpord = ""
	If request("ord")<>"" Then
		cpord = deurl(request("ord"))
	end if
	num2 = 0
	Dim cp_tcsort1, cp_tcsort2, num_tc, cptitle, intro11, intro12
	If cpord&""<>"" Then
		Set rs = conn.execute("select p.title,isnull(p.tcsort1,0) tcsort1,isnull(p.tcsort2,0) tcsort2, isnull(p.num_tc,0) num_tc, ISNULL(s1.intro,0) intro11, ISNULL(s2.intro,0) intro12, isnull(p.num_tc,0) num3 from product p left join setopen s1 on s1.sort1 = 11 left join setopen s2 on s2.sort1 = 12 where p.ord = "& cpord)
		If rs.eof = False Then
			tcsort1 = rs("tcsort1") : cp_tcsort2 = rs("tcsort2") : num_tc = CDbl(rs("num_tc")) : cptitle = rs("title") : intro11 = rs("intro11") : intro12 = rs("intro12")
			If tcsort1 > 0 Then
				sort1 = tcsort1
			else
				sort1 = intro11
			end if
			If cp_tcsort2 > 0 Then
				sort2 = cp_tcsort2
			else
				sort2 = intro12
			end if
			Select Case sort2
			Case 1
			If cp_tcsort2 = 1 Then
				sql = "select isnull(num1,0) num1 from tcbl where sort1=1 and ord = "& cpord
			ElseIf intro12 = 1 Then
				sql = "select isnull(num1,0) num1 from tcbl where sort1=1 and ord is null "
			end if
			Set rs2 = conn.execute(sql)
			If rs2.eof = False Then
				num2 = FormatNumber(CDbl(rs2("num1")),num_dot_xs,True,0,0)
			end if
			rs2.close
			Set rs2 = Nothing
			End Select
		end if
		rs.close
		set rs = nothing
	end if
	Response.write "" & vbcrlf & "<body>" & vbcrlf & "<table width=""100%""  border=""0"" align=""left"" cellpadding=""0"" cellspacing=""0"" bordercolor=""#E2E2E1"" bgcolor=""#FFFFFF"" >" & vbcrlf & "  <tr>" & vbcrlf & "    <td width=""100%"" valign=""top""> " & vbcrlf & "    <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" height=""27"">" & vbcrlf & "             <tr>" & vbcrlf & "                  <td width=""5%"" height=""27""  background=""../images/contentbg.gif""><div align=""center""><img src=""../images/contenttop.gif""height=""27""> </div></td> " & vbcrlf & "                   <td width=""95%""  background=""../images/contentbg.gif"">" & vbcrlf & "                    <strong><font color=""#1445A6"">提成规则设置</font></strong> </td>" & vbcrlf & "          </tr>" & vbcrlf & "           <tr class=""groupTitle""><td class=""resetTableBg tableTitleLinks resetBorderColor"" colspan=""2"" height=""27"" style=""border-bottom:1px solid #CCC;background:#FFF;font-weight:bold; padding:10px 10px  10px 20px;"">"
'End Select
	If cpord&""<>"" And cpord&""<>"0" Then Response.write "更新" Else Response.write "添加"
	Response.write "提成规则</td></tr>" & vbcrlf & "      </table>" & vbcrlf & "        <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""5"">" & vbcrlf & "         <tr>" & vbcrlf & "          <td width=""215"" valign=""top"">" & vbcrlf & ""
	treeType = "TC"
	
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
					"<span class='tree-pagebar-last-btn"&iif(CInt(pageIndex)>=pageCount,"-disabled'","' onclick=""__treePage(this,'last');""")&"></span>"&_
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
'childrenCnt = dataCate(2,j)
						menutype="class='tree-folder tree-lastfolder-" & iif(cascade,"open","closed") & "'"
'childrenCnt = dataCate(2,j)
						listtype="class='tree-lastleaf-nodes'"
'childrenCnt = dataCate(2,j)
					else
						menutype="class='tree-folder tree-folder-" & iif(cascade,"open","closed") & "'"
'childrenCnt = dataCate(2,j)
						listtype="class='tree-leaf-nodes'"
'childrenCnt = dataCate(2,j)
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
					"<span class='tree-pagebar-last-btn"&iif(CInt(pageIndex)>=pageCount,"-disabled'","' onclick=""__treePage(this,'last');""")&"></span>"&_
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
'Response.write GetVirPath()
		Response.write GetVirPath()
		Response.write "images/smico/jt1.gif' style='margin-top:3px;'>" & vbcrlf & "                    <img class=""resetElementShowNoAlign"" src='"
'Response.write GetVirPath()
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
			"                          where del=1 and (cast(intro as varchar(10))='0' or  "&_
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
		'Response.write abs(ShowOnlyHasBomProduct)
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
		'Response.write abs(ShowOnlyHasBomProduct)
		Response.write hasCheckBox
		Response.write "&outProductStr="
		Response.write outProductStr
		Response.write "&timestamp="" + new Date().getTime() + ""&date1=""+ Math.round(Math.random()*100);" & vbcrlf & "                     }       " & vbcrlf & "                }catch (e){}" & vbcrlf & "            xmlHttp.open(""GET"", url, false);" & vbcrlf & "          xmlHttp.onreadystatechange = function(){" & vbcrlf & "                        if (xmlHttp.readyState < 4) return;" & vbcrlf & "                    updatePage_cp(callBack);" & vbcrlf & "                };" & vbcrlf & "              xmlHttp.send(null);  " & vbcrlf & "   }" & vbcrlf & "" & vbcrlf & "       var xmlHttpNode = GetIE10SafeXmlHttp();" & vbcrlf & " function TxmAjaxSubmit(returnUnit){" & vbcrlf & "             //获取用户输入" & vbcrlf & "          var TxmID=document.txmfrom.txm.value;"& vbcrlf &             "if (TxmID.length ==0){return;}" & vbcrlf &           "var top=document.txmfrom.top.value;" & vbcrlf &              "if (TxmID.indexOf(""："")>=0)" & vbcrlf &                "{" & vbcrlf &                        "//多行文本内容，二维码文本编码.task.2355.binary.2014.12" & vbcrlf &                  "if( TxmID.indexOf(""流水号："")==0) { sendTxmRequest(top, TxmID); }" & vbcrlf & "                 return;" & vbcrlf & "         }" & vbcrlf & "               if (TxmID.toLowerCase().indexOf(""view.asp?v"")>0)" & vbcrlf & "          {" & vbcrlf & "                       //网址信息，可能是二维码URL编码" & vbcrlf & "                 TxmID = ""QrUrl="" + TxmID.split(""view.asp?"")[1];" & vbcrlf & "             }" & vbcrlf & "               sendTxmRequest(top,TxmID,returnUnit); // 常规单行条码" & vbcrlf & "      }" & vbcrlf & "" & vbcrlf & "       function sendTxmRequest(top,TxmID,returnUnit) {" & vbcrlf & "         returnUnit = returnUnit || '';" & vbcrlf & "          var url = """
		Response.write GetVirPath()
		Response.write "product/txmRK.asp?txm=""+escape(TxmID)+""&top=""+escape(top) +""&cstore="
		'Response.write GetVirPath()
		Response.write abs(ShowOnlyCanStoreProduct)
		Response.write "&returnUnit="" + returnUnit + ""&timestamp="" + new Date().getTime() + ""&date1=""+ Math.round(Math.random()*100);" & vbcrlf & "         xmlHttp.open(""GET"", url, false);" & vbcrlf & "          xmlHttp.onreadystatechange = function(){" & vbcrlf & "                        updateTxm(top,returnUnit);" & vbcrlf & "              };" & vbcrlf & "xmlHttp.send(null);"  & vbcrlf &     "}" & vbcrlf & vbcrlf &        "function updateTxm(x1,returnUnit) {" & vbcrlf &              "returnUnit = returnUnit || '';" & vbcrlf &           "if (xmlHttp.readyState < 4) {" & vbcrlf &            "//      cp_search.innerHTML=""loading..."";" & vbcrlf &          "}" & vbcrlf &                "if (xmlHttp.readyState == 4) {" & vbcrlf & "                 var response = xmlHttp.responseText;" & vbcrlf & "                    // alert(response);" & vbcrlf & "                     response=response.split(""</noscript>"");" & vbcrlf & "                   //alert(response[1]);" & vbcrlf & "                   response[1] = (response[1])?response[1]:0;" & vbcrlf & "                      if (response[1] != ''){" & vbcrlf & "                          if (returnUnit != ''){" & vbcrlf & "                                  callServer4(response[1].split(',')[0],x1,response[1].split(',')[1]);" & vbcrlf & "                            }else{" & vbcrlf & "                                  callServer4(response[1],x1);" & vbcrlf & "                            }" & vbcrlf & "                       }else{" & vbcrlf & "                          alert(""产品不存在"");" & vbcrlf & "                      }" & vbcrlf &"         }" & vbcrlf & "       }" & vbcrlf & "       " & vbcrlf & "        function selectAllProduct(obj){" & vbcrlf & "         $("".productclsid"").attr(""checked"",obj.checked);" & vbcrlf & "     }" & vbcrlf & "" & vbcrlf & "       function addProductClick(){" & vbcrlf & "             $(""input[class=productclsid]:checked"").each(function(){" & vbcrlf & "                   callServer4(this.value,'');" & vbcrlf & "             });" & vbcrlf & "     }" & vbcrlf & "" & vbcrlf & "       function Left_adSearch(obj){" & vbcrlf & "            var sdivobj=document.getElementById(""adsDiv"");" & vbcrlf & "            if(sdivobj.style.display!=""none""){" & vbcrlf & "                        Left_adClose();" & vbcrlf & "         }else{"& vbcrlf &                     "var x=obj.offsetLeft,y=obj.offsetTop;" & vbcrlf &                    "var obj2=obj;" & vbcrlf &                    "var offsetx=0;" & vbcrlf &                   "while(obj2=obj2.offsetParent){" & vbcrlf &                           "x+=obj2.offsetLeft;" & vbcrlf &                              "y+=obj2.offsetTop;" & vbcrlf &                       "}" & vbcrlf &                        "sdivobj.style.left=x+50+""px"";" & vbcrlf & "                   sdivobj.style.top=y+""px"";" & vbcrlf & "                 sdivobj.style.display=""inline"";" & vbcrlf & "           }" & vbcrlf & "               document.getElementById('adsIF').style.height=document.getElementById('adsIF').contentWindow.document.getElementsByTagName('table')[1].offsetHeight+160+'px';" & vbcrlf & "   }" & vbcrlf & "" & vbcrlf & "   function Left_adClose(){" & vbcrlf & "                document.getElementById('adsDiv').style.display=""none"";" & vbcrlf & "   }" & vbcrlf & "       window.ShowOnlyCanStoreProduct = "
		Response.write abs(ShowOnlyCanStoreProduct)
		Response.write ";" & vbcrlf & "    window.ShowOnlyHasBomProduct = "
		Response.write abs(ShowOnlyHasBomProduct)
		Response.write ";" & vbcrlf & "</script>" & vbcrlf & ""
	end sub
	Call ShowLeftTree
	Response.write "" & vbcrlf & "              </td>" & vbcrlf & "           <td valign=""top"">" & vbcrlf & "                 <form method=""post"" action=""Update_htlc.asp"" id=""demo"" onsubmit=""return Validator.Validate(this,2) && checkForm()"" name=""date"">" & vbcrlf & "                    <div style=""margin-bottom:1px;""><textarea  id=""cpNames"" readonly rows=""4"" style=""overflow:auto; width:89%"">"
	Response.write cptitle
	Response.write "</textarea><input type=""hidden"" name=""cpords"" id=""cpords"" value="""
	Response.write cpord
	Response.write """><input type=""hidden"" name=""clsIds"" id=""clsIds"" value="""
	Response.write clsIds
	Response.write """>" & vbcrlf & "                         <span id=""qkongcp"" style=""display:"
	If cpord&""<>"" And cpord&""<>"0" Then Response.write "" Else Response.write "none"
	Response.write ";""><a href=""javascript:;"" onclick=""qkongcp()"">[全部清空]</a></span></div>" & vbcrlf & "                      <table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "                       <tr class=""top"">" & vbcrlf & "                                <td height=""30"" colspan=""6"" >提成基数</td>" & vbcrlf & "                           </tr>" & vbcrlf & "                     <tr>" & vbcrlf & "                          <td  height=""26"" colspan=""6"" class=""name""><input type=""hidden"" name=""add"" id=""add"">" & vbcrlf & "                         "
	If Len(sort1 & "") = 0 then        sort1 = "1"
	if ZBRuntime.MC(7000) then
		Response.write "" & vbcrlf & "                             <input type=""radio"" name=""sort1"" id=""sort11"" value=""1"" "
		If sort1&""="1" Then Response.write "checked"
		Response.write " onclick=""checkSort1()"">按照销售额计算提成" & vbcrlf & "                             "
	end if
	if ZBRuntime.MC(7000) and ZBRuntime.MC(17000) and ZBRuntime.MC(23000) then
		Response.write "" & vbcrlf & "                                     <input type=""radio"" name=""sort1"" id=""sort13"" value=""3"" "
		If sort1&""="3" Then Response.write "checked"
		Response.write " onclick=""checkSort1()"">按照毛利计算提成" & vbcrlf & "                               "
	end if
	if ZBRuntime.MC(7000) then
		Response.write "" & vbcrlf & "                             <input type=""radio"" name=""sort1"" id=""sort15"" value=""5"" "
		If sort1&""="5" Then Response.write "checked"
		Response.write " onclick=""checkSort1()"">按照产品实际销售价提成" & vbcrlf & "                         "
	end if
	if ZBRuntime.MC(7000) then
		Response.write "" & vbcrlf & "                                     <input type=""radio"" name=""sort1"" id=""sort17"" value=""7"" "
		If sort1&""="7" Then Response.write "checked"
		Response.write " onclick=""checkSort1()"">按照建议进价成本毛利计算提成" & vbcrlf & "                           "
	end if
	Response.write "" & vbcrlf & "                             </td>" & vbcrlf & "                     </tr>" & vbcrlf & "                   <tr class=""top"">" & vbcrlf & "                                <td  height=""26"" colspan=""6"" class=""name"">提成比例</td>" & vbcrlf & "                         </tr>" & vbcrlf & "                   <tr>" & vbcrlf & "                          <td  height=""26"" colspan=""6"" id=""blType"" class=""name""><input type=""radio"" name=""sort2"" id=""sort21"" value=""1"" "
	If sort2&""="1" Then Response.write "checked"
	Response.write " onclick=""checkSort2(this.id)"">" & vbcrlf & "                                  同一比例" & vbcrlf & "                                <span id=""tcType23"" style=""display: "
	If sort1&""="5" Or sort2&""="4" Then Response.write "none" Else Response.write ""
	Response.write ";"">" & vbcrlf & "                                       <input type=""radio"" name=""sort2"" id=""sort22"" value=""2"" "
	If sort2&""="2" Then Response.write "checked"
	Response.write " onclick=""checkSort2(this.id)"">" & vbcrlf & "                                        累加比例" & vbcrlf & "                                        <input type=""radio"" name=""sort2"" id=""sort23"" value=""3"" "
	If sort2&""="3" Then Response.write "checked"
	Response.write " onclick=""checkSort2(this.id)"">" & vbcrlf & "                                        产品比例" & vbcrlf & "                                  </span>" & vbcrlf & "                                 <span id=""tcType4"" style=""display: "
	If sort1&""="5" Or sort2&""="4" Then Response.write "" Else Response.write "none"
	Response.write ";"">" & vbcrlf & "                                       <input type=""radio"" name=""sort2"" id=""sort24"" value=""4"" "
	If sort2&""="4" Then Response.write "checked"
	Response.write "  onclick=""checkSort2(this.id)"">" & vbcrlf & "                                       累加比例" & vbcrlf & "                                  </span>" & vbcrlf & "                                       <br>" & vbcrlf & "            <font id=""kh"" style=""display:"
	If sort2&""="1" Then Response.write "" Else Response.write "none"
	Response.write """>" & vbcrlf & "                提成比例：" & vbcrlf & "              <input name=""num2"" id=""num2"" type=""text"" size=""10"" onblur='if(this.value==""""){this.value=0}' onkeyup=""checkDot('num2',"
	Response.write num_dot_xs
	Response.write ")"" onkeypress=""return checkOnlyNum(1)"" value="""
	Response.write FormatNumber(num2,num_dot_xs,true,0,0)
	Response.write """ oncontextmenu=""self.event.returnValue=false""  dataType=""Limit"" min=""1"" max=""15""  msg=""长度必须在1到15位之间"">" & vbcrlf & "             %</font>" & vbcrlf & "                <font id=""xm"" style=""display:"
	If sort2&""="2" Then Response.write "" Else Response.write "none"
	Response.write """>" & vbcrlf & "                <br>" & vbcrlf & "            "
	i=0
	If cpord&""<>"" And cpord&""<>"0" Then
		set rs1=server.CreateObject("adodb.recordset")
		If cp_tcsort2 > 0 Then
			sql1="select isnull(money1,0) money1, isnull(money2,0) money2, isnull(num1,0) num1 from tcbl where sort1=2 and ord="& cpord &" order by gate1 asc"
		else
			sql1="select isnull(money1,0) money1, isnull(money2,0) money2, isnull(num1,0) num1 from tcbl where sort1=2 and ord is null order by gate1 asc"
		end if
		rs1.open sql1,conn,1,1
		i=0
		do until rs1.eof
			Response.write "" & vbcrlf & "             自：<input name=""money1"" id=""money1"
			Response.write i
			Response.write """ type=""text"" size=""10"" onkeyup=""checkDot('money1"
			Response.write i
			Response.write "',"
			Response.write num_dot_xs
			Response.write ")"" onkeypress=""return checkOnlyNum(1)"" dataType=""Limit"" min=""0"" max=""15""  msg=""长度不能超过15位"" value="""
			Response.write FormatNumber(rs1("money1"),num_dot_xs,true,0,0)
			Response.write """ oncontextmenu=""self.event.returnValue=false"">&nbsp;至：<input name=""money2"" id=""money2"
			Response.write i
			Response.write """ type=""text"" size=""10"" onkeyup=""checkDot('money2"
			Response.write i
			Response.write "',"
			Response.write num_dot_xs
			Response.write ")"" onkeypress=""return checkOnlyNum(1)""  dataType=""Limit"" min=""0"" max=""15""  msg=""长度不能超过15位"" value="""
			Response.write FormatNumber(rs1("money2"),num_dot_xs,true,0,0)
			Response.write """ oncontextmenu=""self.event.returnValue=false""> &nbsp;提成比例：<input name=""num6"" id=""num6"
			Response.write i
			Response.write """ type=""text"" size=""10"" onkeyup=""checkDot('num6"
			Response.write i
			Response.write "',"
			Response.write num_dot_xs
			Response.write ")"" onkeypress=""return checkOnlyNum(1)"" dataType=""Limit"" min=""0"" max=""15""  msg=""长度不能超过15位"" value="""
			Response.write FormatNumber(rs1("num1"),num_dot_xs,true,0,0)
			Response.write """ oncontextmenu=""self.event.returnValue=false"">" & vbcrlf & "             %<br>" & vbcrlf & "           "
			i=i+1
			rs1.movenext
		loop
		rs1.close
		set rs1=nothing
	end if
	for i=i to 5
		Response.write "" & vbcrlf & "             自：<input name=""money1"" id=""money1"
		Response.write i
		Response.write """ type=""text"" size=""10"" onkeyup=""checkDot('money1"
		Response.write i
		Response.write "',"
		Response.write num_dot_xs
		Response.write ")"" onkeypress=""return checkOnlyNum(1)"" dataType=""Limit"" min=""0"" max=""15""  msg=""长度不能超过15位"" oncontextmenu=""self.event.returnValue=false"">&nbsp;至：<input name=""money2"" id=""money2"
		Response.write i
		Response.write """ type=""text"" size=""10"" onkeyup=""checkDot('money2"
		Response.write i
		Response.write "',"
		Response.write num_dot_xs
		Response.write ")"" onkeypress=""return checkOnlyNum(1)"" dataType=""Limit"" min=""0"" max=""15""  msg=""长度不能超过15位"" oncontextmenu=""self.event.returnValue=false""> &nbsp;提成比例：<input name=""num6"" id=""num6"
		Response.write i
		Response.write """ type=""text"" size=""10"" onkeyup=""checkDot('num6"
		Response.write i
		Response.write "',"
		Response.write num_dot_xs
		Response.write ")"" onkeypress=""return checkOnlyNum(1)"" dataType=""Limit"" min=""0"" max=""15""  msg=""长度不能超过15位"" oncontextmenu=""self.event.returnValue=false"">" & vbcrlf & "                %" & vbcrlf & "               <br>" & vbcrlf & "            "
	next
	Response.write "" & vbcrlf & "             <br><br></font>" & vbcrlf & "         <font id=""cp"" style=""display:"
	If sort2&""="3" Then Response.write "" Else Response.write "none"
	Response.write ";"">" & vbcrlf & "               提成比例：" & vbcrlf & "              <input name=""num3"" id=""num3"" type=""text"" size=""10"" onblur='if(this.value==""""){this.value=0}' onkeyup=""checkDot('num3',"
	Response.write num_dot_xs
	Response.write ")"" onkeypress=""return checkOnlyNum(1)"" oncontextmenu=""self.event.returnValue=false"" value="""
	Response.write FormatNumber(num_tc,num_dot_xs,true,0,0)
	Response.write """  dataType=""Limit"" min=""1"" max=""15""  msg=""长度必须在1到15位之间"">" & vbcrlf & "                %</font>" & vbcrlf & "                <font id=""ht"" style=""display:"
	If sort2&""="4" Then Response.write "" Else Response.write "none"
	Response.write """>" & vbcrlf & "                <br>" & vbcrlf & "            "
	i=0
	If cpord&""<>"" And cpord&""<>"0" Then
		set rs1=server.CreateObject("adodb.recordset")
		If cp_tcsort2 > 0 Then
			sql1="select tc_formula1, tc_formula2, isnull(num1,0) num1 from tcbl where sort1=4 and ord="& cpord &" order by gate1 asc"
		else
			sql1="select tc_formula1, tc_formula2, isnull(num1,0) num1 from tcbl where sort1=4 and ord is null order by gate1 asc"
		end if
		rs1.open sql1,conn,1,1
		do until rs1.eof
			Response.write "" & vbcrlf & "             自：<input name=""formula1"" id=""formula1"
			Response.write i
			Response.write """ type=""text"" size=""20"" dataType=""Limit"" min=""0"" max=""200""  msg=""长度不能超过200"" value="""
			Response.write rs1("tc_formula1")
			Response.write """>&nbsp;至：<input name=""formula2"" id=""formula2"
			Response.write i
			Response.write """ type=""text"" size=""20"" dataType=""Limit"" min=""0"" max=""200""  msg=""长度不能超过200"" value="""
			Response.write rs1("tc_formula2")
			Response.write """> &nbsp;提成比例：<input name=""num8"" id=""num8"
			Response.write i
			Response.write """ type=""text"" size=""10"" dataType=""Limit"" min=""0"" max=""15""  msg=""长度不能超过15位"" value="""
			Response.write FormatNumber(rs1("num1"),num_dot_xs,true,0,0)
			Response.write """ onkeyup=""checkDot('num8"
			Response.write i
			Response.write "',"
			Response.write num_dot_xs
			Response.write ")"" onkeypress=""return checkOnlyNum(1)"" oncontextmenu=""self.event.returnValue=false"">" & vbcrlf & "          %<br>" & vbcrlf & "           "
			i=i+1
			rs1.movenext
		loop
		rs1.close
		set rs1=nothing
	end if
	for i=i to 5
		Response.write "" & vbcrlf & "             自：<input name=""formula1"" id=""formula1"
		Response.write i
		Response.write """ type=""text"" size=""20"" dataType=""Limit"" min=""0"" max=""200""  msg=""长度不能超过200"">&nbsp;至：<input name=""formula2"" id=""formula2"
		Response.write i
		Response.write """ type=""text"" size=""20"" dataType=""Limit"" min=""0"" max=""200""  msg=""长度不能超过200""> &nbsp;提成比例：<input name=""num8"" id=""num8"
		Response.write i
		Response.write """ type=""text"" size=""10"" onkeyup=""checkDot('num8"
		Response.write i
		Response.write "',"
		Response.write num_dot_xs
		Response.write ")"" onkeypress=""return checkOnlyNum(1)"" oncontextmenu=""self.event.returnValue=false"" dataType=""Limit"" min=""0"" max=""15""  msg=""长度不能超过15位"">" & vbcrlf & "                %" & vbcrlf & "               <br>" & vbcrlf & "            "
	next
	Response.write "" & vbcrlf & "             <div class=""tcblgram"" id=""strlist"">" & vbcrlf & "                 "
	if ZBRuntime.MC(7000) then
		Response.write "" & vbcrlf & "                     <li title=""点击复制{建议售价}"" id=""tcgram1"" onclick=""copyClick(this.id)"">{建议售价}</li>" & vbcrlf & "                      <li title=""点击复制{最低售价}"" id=""tcgram2"" onclick=""copyClick(this.id)"">{最低售价}</li>" & vbcrlf & "                      "
	end if
	if ZBRuntime.MC(15000) then
		Response.write "" & vbcrlf & "                     <li title=""点击复制{建议进价}"" id=""tcgram3"" onclick=""copyClick(this.id)"">{建议进价}</li>" & vbcrlf & "                      <li title=""点击复制{最高进价}"" id=""tcgram4"" onclick=""copyClick(this.id)"">{最高进价}</li>" & vbcrlf & "                      "
	end if
	if ZBRuntime.MC(7000) then
		Response.write "" & vbcrlf & "                     <li title=""点击复制{客户跟进程度价格}"" id=""tcgram5"" onclick=""copyClick(this.id)"" style=""width:130px;"">{客户跟进程度价格}</li>" & vbcrlf & "                   "
	end if
	Response.write "" & vbcrlf & "             </div>" & vbcrlf & "          <div style=""float:left; margin-top:10px; width:500px; padding-left:5px; padding-bottom:5px;"">注：只能包含参数及 + _ *  / 和数字</div>" & vbcrlf & "             <br></font></td>" & vbcrlf & "                          </tr>                   " & vbcrlf & "                      <tr>" & vbcrlf & "                            <td height=""40"" colspan=""6""><div align=""center"">" & vbcrlf & "                             <input type=""submit"" name=""Submit42"" value=""保存""  class=""page""/>　" & vbcrlf & "                             "
	If cpord&""="" or cpord&""="0" Then
		Response.write "<input type=""button"" name=""Submit43"" value=""增加""  class=""page"" onclick=""addNew()"" />"
	end if
	Response.write "　" & vbcrlf & "                             <input type=""button"" value=""关闭"" class=""page"" name=""B2"" onclick=""window.close();"">         " & vbcrlf & "                              </div></td>" & vbcrlf & "             </tr>           " & vbcrlf & "              </table>" & vbcrlf & "                </form> " & vbcrlf & "                </td>" & vbcrlf & "   </tr>" & vbcrlf & "   </table>" &vbcrlf & " </td>" & vbcrlf & "  </tr>" & vbcrlf & "  <tr>" & vbcrlf & "  <td  class=""page"">" & vbcrlf & "   <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "  <tr>" & vbcrlf & "    <td height=""30"" ><div align=""center""></div></td>" & vbcrlf & "    </tr>" & vbcrlf & "</table>" &vbcrlf & "           </td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & ""
	action1="提成规则设置"
	call close_list(1)
	Response.write "" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
%>
