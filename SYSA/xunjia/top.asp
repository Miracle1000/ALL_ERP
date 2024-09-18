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
	
	Dim mxDelAble, needXJ, toBJAble, changeUnitAble, mxEditAble
	Dim cpord, mxid, xjmxid, curCate, cpTitle, order1,type1,unit,unitjb,unitall,pUnit,name, sorce_user, tpx, mxcpDel, mxgysDel
	Dim cpzdy1, cpzdy2, cpzdy3, cpzdy4, cpzdy5, cpzdy6, rs_zdy5, rs_zdy6,company1, company_ord, company_name, company_cateid
	Dim len_rszdy5, len_rszdy6, rs_unit, len_rsunit, rs_invoice, len_rsinvoice
	Dim price1, unitname, money1, jf, invoiceTypes, arr_invoiceTypes, invoiceType,invoiceType2, prices, num1, pricelist, date2, mxIntro
	Dim taxRate, priceAfterDiscount, discount, priceAfterTax, priceIncludeTax, moneyBeforeTax, moneyAfterTax, taxValue, concessions
	Dim sort_jgcl, jgcl_open, price1_top, lim1, price1_limit, num1_kd, mxSet_open, includeTax
	Dim open_21_14, open_24_21, open_26_1, intro_26_1, open_26_14, intro_26_14
	Dim rs_xjmx, len_rsxjmx, caigoulist, caigoulist_yg, Xunjiastatus
	mxDelAble = True
	changeUnitAble = True
	needXJ = False
	toBJAble = False
	Xunjiastatus = 0
	mxEditAble = True
	Function baseParamInit()
		unit=0 : curCate = session("personzbintel2007")&""  : jf = 0
	end function
	Function getCateInfo()
		Dim rs
		set rs=server.CreateObject("adodb.recordset")
		sql="select pricesorce as sorce from gate where ord="& curCate &" "
		rs.open sql,conn,1,1
		if not rs.eof then
			sorce_user=rs("sorce")
		end if
		rs.close
		if sorce_user&""="" Then sorce_user=0
		sql="select  top 1 ord from pricegate1 where ord="&sorce_user&" and num1=1"
		rs.open sql,conn
		if rs.eof then
			sorce_user=0
		end if
		rs.close
		set rs=Nothing
	end function
	Function getPower1()
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select qx_open,qx_intro from power where ord="& curCate &" and sort1=21 and sort2=14"
		rs1.open sql1,conn,1,1
		if rs1.eof then
			open_21_14=0
		else
			open_21_14=rs1("qx_open")
		end if
		rs1.close
		sql1="select qx_open,qx_intro from power where ord="& curCate &" and sort1=24 and sort2=21"
		rs1.open sql1,conn,1,1
		if rs1.eof then
			open_24_21=0
		else
			open_24_21=rs1("qx_open")
		end if
		rs1.close
		set rs1=nothing
	end function
	Function getPower2()
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
	end function
	Function getProductInfo()
		Dim rs
		set rs7=server.CreateObject("adodb.recordset")
		sql7="select title,order1,type1,price1,company,unit,unitjb,includeTax,invoiceTypes,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6,del from product where ord="&cpord&""
		rs7.open sql7,conn,1,1
		if rs7.eof then
			cpTitle="" : order1="" : type1="" : company1=0 : unitall=0 : unitjb=0
			cpzdy5=0 : cpzdy6=0 : mxcpDel = 0
			includeTax=0 : invoiceTypes="0"
		else
			cpTitle=rs7("title") : order1=rs7("order1") : type1=rs7("type1") : mxcpDel=rs7("del")
			company1=rs7("company")
			unitall=rs7("unit") : unitjb=rs7("unitjb")
			cpzdy1=rs7("zdy1") : cpzdy2=rs7("zdy2") : cpzdy3=rs7("zdy3") : cpzdy4=rs7("zdy4") : cpzdy5=rs7("zdy5") : cpzdy6=rs7("zdy6")
			includeTax=rs7("includeTax") : invoiceTypes=rs7("invoiceTypes")
		end if
		rs7.close
		set rs7=nothing
		if unitall="" or isnull(unitall) Then unitall=0
		if unitjb="" or isnull(unitjb) Then unitjb=0
		If pUnit & "" <> "" Then unitjb = pUnit
		If company1&""="" Or company1&""="1000000" Then company1 = 0
		Set rs = conn.execute("select ord,sort1 from sortonehy where gate2=61 and id in ("&unitall&") order by gate1 desc")
		If rs.eof = False Then
			rs_unit = rs.GetRows()
		end if
		rs.close
		set rs = nothing
		if isArray(rs_unit) then
			len_rsunit = ubound(rs_unit,2)
		else
			len_rsunit = -1
			len_rsunit = ubound(rs_unit,2)
		end if
	end function
	Function getBaseJgcl()
		Dim rs
		set rs=server.CreateObject("adodb.recordset")
		sql="select intro from setopen  where sort1=1202"
		rs.open sql,conn,1,1
		if rs.eof then
			sort_jgcl=1
		else
			sort_jgcl=rs("intro")
			if sort_jgcl&""="" Then sort_jgcl=1
		end if
		rs.close
		set rs=nothing
	end function
	Function getPriceInfo()
		Dim rs, i, showInvoiceTypes ,ProdincludeTax
		ProdincludeTax = 0
		invoiceType=0
		set rs2=server.CreateObject("adodb.recordset")
		rs2.open "select includeTax from product where ord="&cpord&"",conn,1,1
		if rs2.eof=false then ProdincludeTax=rs2("includeTax")
		rs2.close
		set rs2=nothing
		jgcl_open=0
		if sort_jgcl="1" then
			set rs7=server.CreateObject("adodb.recordset")
			sql7="select top 1 company,unit,price1,priceAfterDiscountTax from caigoulist where ord="&cpord&" and unit="&unitjb
			if company_ord>0 then
				sql7=sql7&" and company="&company_ord
			end if
			sql7=sql7&" and del=1 and addcate="& curCate &" order by date7 desc"
			rs7.open sql7,conn,1,1
			if rs7.eof then
				set rs8=server.CreateObject("adodb.recordset")
				sql8="select top 1 company,unit,price1,priceAfterDiscountTax from caigoulist where ord="&cpord&" and unit="&unitjb
				sql8=sql8&" and del=1 and addcate="& curCate &" order by date7 desc"
				rs8.open sql8,conn,1,1
				if rs8.eof then
					price1=0 : jgcl_open=1
				else
					price1=rs8("price1")
					if ProdincludeTax&""="1" then price1 = rs8("priceAfterDiscountTax")
				end if
				rs8.close
				set rs8=nothing
			else
				price1=rs7("price1")
				if ProdincludeTax&""="1" then price1 = rs7("priceAfterDiscountTax")
			end if
			rs7.close
			set rs7=nothing
		end if
		if sort_jgcl="2" or jgcl_open=1 then
			set rs1=server.CreateObject("adodb.recordset")
			sql1="select price1jy from jiage where product="&cpord&" and bm="&sorce_user&" and unit="&unitjb&""
			rs1.open sql1,conn,1,1
			if rs1.eof then
				price1=0
			else
				price1=rs1("price1jy")
			end if
			rs1.close
			set rs1=nothing
		end if
		unit=unitjb
		unitname=""
		set rs2=server.CreateObject("adodb.recordset")
		rs2.open "select sort1 from sortonehy where id="&unit&"",conn,1,1
		if rs2.eof=false then unitname=rs2("sort1")
		rs2.close
		set rs2=nothing
		set rs8=conn.execute("select isnull(price1,0) as price1 from jiage where product="&cpord&" and bm="&sorce_user&" and unit="&unit&"")
		if not rs8.eof then
			price1_top=rs8(0).value
		else
			price1_top=9999999999999
		end if
		set rs8=nothing
		set rs8=conn.execute("select isnull(intro,0) from setopen where sort1=44")
		if not rs8.eof then
			lim1=rs8(0).value
		else
			lim1=0
		end if
		set rs8=nothing
		if lim1=1 then
			price1_limit=price1_top
		else
			price1_limit=9999999999999
		end if
		if price1&""="" Then price1=0
		If invoiceTypes = "" Or isnull(invoiceTypes) Then invoiceTypes = "0"
		iType = invoiceType
		If isnull(invoiceType) Or invoiceType="" Then iType = 0
		sql="select * from ("&_
		"                    ""select a.id,a.sort1,b.taxRate,b.priceFormula,b.priceBeforeTaxFormula,(case when a.id=""&iType&"" then 0 else 1 end) as topRow,a.gate1 from sortonehy a inner join invoiceConfig b on a.id=b.typeid where gate2 = 34 and isStop=0 and isnull(id1,0)<>-65535 and a.id in (""&iif(invoiceTypes="""",""0"",invoiceTypes)"&","&iType&")"&_
		"union all ("&_
		"select 0,'不开票',taxRate,priceFormula,priceBeforeTaxFormula,(case when "&iType&"=0 then 0 else 1 end) as topRow,-9999999 from sortonehy a,invoiceConfig b where a.id=b.typeid and isnull(a.id1,0)=-65535"&_
		")"&_
		") bb  order by topRow,gate1 desc"
		Set rs=conn.execute(sql)
		If rs.eof = False Then
			rs_invoice = rs.GetRows()
		end if
		rs.close
		set rs = nothing
		if isArray(rs_invoice) then
			len_rsinvoice = ubound(rs_invoice,2)
		else
			len_rsinvoice = -1
			len_rsinvoice = ubound(rs_invoice,2)
		end if
		showInvoiceTypes = ""
		For i = 0 To len_rsinvoice
			showInvoiceTypes = showInvoiceTypes & iif(showInvoiceTypes&""="", "",",") & rs_invoice(0,i)
		next
		If invoiceTypes&""<>"" Then
			arr_invoiceTypes = Split(invoiceTypes&"",",")
			For i = 0 To ubound(arr_invoiceTypes)
				If InStr(","& showInvoiceTypes &",",","& arr_invoiceTypes(i)&",")>0 And arr_invoiceTypes(i)&""<>"" And arr_invoiceTypes(i)&""<>"0" Then
					invoiceType = arr_invoiceTypes(i)
					Exit For
				end if
			next
		else
			invoiceType = 0
		end if
		invoiceType2 = invoiceType
		prices = getKindsOfPrices(ProdincludeTax, price1, invoiceType)
		If Len(Trim(invoiceType)&"")=0 then invoiceType = 0
		Set rs = conn.execute("select taxRate from sortonehy a inner join invoiceConfig b on a.id=b.typeid and isnull(a.isStop,0)=0 where (case when id1=-65535 then 0 else a.id end)=" & invoiceType)
'If Len(Trim(invoiceType)&"")=0 then invoiceType = 0
		If rs.eof = False then
			taxRate = rs(0).value
		end if
		rs.close
		price1 = CDbl(prices(0))
		priceAfterDiscount = price1
		discount = 1
		priceAfterTax = CDbl(prices(1))
		priceIncludeTax = priceAfterTax / discount
		moneyBeforeTax = prices(0)
		moneyAfterTax = prices(1)
		taxValue = moneyAfterTax - moneyBeforeTax
'moneyAfterTax = prices(1)
		concessions = 0
		money1=Formatnumber(moneyBeforeTax - concessions,num_dot_xs,true,0,0)
'concessions = 0
	end function
	Function getXjZdy56(act)
		Dim rs
		Set rs = conn.execute("select ord,sort1 from sortonehy where gate2=2101 "& iif(mxEditAble=False And InStr(act&"","_edit_add")>0 And cpzdy5&""<>"" ," and ord="& cpzdy5,"")&" order by gate1 desc ")
		If rs.eof = False Then
			rs_zdy5 = rs.GetRows()
		end if
		rs.close
		set rs = nothing
		if isArray(rs_zdy5) then
			len_rszdy5 = ubound(rs_zdy5,2)
		else
			len_rszdy5 = -1
			len_rszdy5 = ubound(rs_zdy5,2)
		end if
		Set rs = conn.execute("select ord,sort1 from sortonehy where gate2=2102 "& iif(mxEditAble=False And InStr(act&"","_edit_add")>0 And cpzdy6&""<>"" ," and ord="& cpzdy6,"")&" order by gate1 desc ")
		If rs.eof = False Then
			rs_zdy6 = rs.GetRows()
		end if
		rs.close
		set rs = nothing
		if isArray(rs_zdy6) then
			len_rszdy6 = ubound(rs_zdy6,2)
		else
			len_rszdy6 = -1
			len_rszdy6 = ubound(rs_zdy6,2)
		end if
	end function
	Function getCompanyInfo()
		If company1&""="" then company1="0"
		set rs1 = conn.execute("select ord,name,cateid,del from tel where ord="&company1&" ")
		if rs1.eof then
			company_name="无" : company_ord=company1 : company_cateid=0 : mxgysDel = 0
		else
			company_name=rs1("name") : company_ord=rs1("ord")   : company_cateid=rs1("cateid") : mxgysDel = rs1("del")
		end if
		rs1.close
		set rs1=nothing
		If company1&""="" Or company1&""="0" or cdbl(company1)<0 Then mxgysDel=-1
'set rs1=nothing
	end function
	Function xjmx_init(act)
		Dim rs1, rs7, rs8, sql7, sql8, sql
		cpord = request.querystring("ord") : pUnit = request.querystring("unit")
		Select Case act
		Case "add"
		top=request.querystring("top")
		tpx= session("num_click2009")-1
'top=request.querystring("top")
		Case "changeUnit"
		mxid=request.querystring("id")
		num1=request.querystring("num1")
		tpx=request.querystring("i")
		If tpx&""="" Then tpx = 0 Else tpx = CLng(tpx)
		Case "tjXunjia", "price_tjXunjia"
		pricelist=request.querystring("id")
		End Select
		Call baseParamInit()
		Call getPower1()
		Call getProductInfo()
		Call getCateInfo()
		If act&""="tjXunjia" Or act&""="price_tjXunjia" Then
			Call getCompanyInfo()
			Call getPower2()
		end if
		Call getBaseJgcl()
		Call getPriceInfo()
		Call getXjZdy56("")
	end function
	Function getXjMxZdy()
		Dim rs
		set rs = conn.execute("select id,title,name,sorce,kd,set_open from zdymx where sort1=24 order by gate1 asc")
		if not rs.eof then
			rs_xjmx = rs.GetRows()
		end if
		rs.close
		set rs = nothing
		if isArray(rs_xjmx) then
			len_rsxjmx = ubound(rs_xjmx,2)
		else
			len_rsxjmx = -1
'len_rsxjmx = ubound(rs_xjmx,2)
		end if
		num1_kd = 0
		for i=0 to len_rsxjmx
			mxSet_open = rs_xjmx(5,i)
			If mxSet_open = 1 Then num1_kd = num1_kd + rs_xjmx(4,i)
'mxSet_open = rs_xjmx(5,i)
		next
	end function
	Function xjmx_show(act)
		Dim u, v, y5, y6, sqlStr
		Select Case act
		Case "add"
		Call xjmx_init(act)
		num1=1
		sqlStr="Insert Into mxpx(ord,cateid,topid,sort1,datepx) values('"
		sqlStr=sqlStr & cpord & "','"
		sqlStr=sqlStr & curCate & "','"
		sqlStr=sqlStr & 0 & "','"
		sqlStr=sqlStr & 1 & "','"
		sqlStr=sqlStr & now & "')"
		Conn.execute(sqlStr)
		mxid = GetIdentity("mxpx","id","cateid","")
		Call getXjMxZdy()
		Case "tjXunjia", "price_tjXunjia"
		Call xjmx_init(act)
		num1=1
		sqlStr="Insert Into mxpx(ord,cateid,topid,sort1,datepx) values('"
		sqlStr=sqlStr & cpord & "','"
		sqlStr=sqlStr & curCate& "','"
		sqlStr=sqlStr & pricelist & "','"
		sqlStr=sqlStr & iif(act="price_tjXunjia",1,3) & "','"
		sqlStr=sqlStr & now & "')"
		Conn.execute(sqlStr)
		mxid = GetIdentity("mxpx","id","cateid","")
		tpx = conn.execute("select count(1) from mxpx where cateid="& curCate &" and topid="&pricelist&" ")(0)
		If tpx&""="" Then tpx = 0
		Call getXjMxZdy()
		Case "edit_add", "yugou_edit_add"
		sqlStr="Insert Into mxpx(ord,cateid,topid,sort1,pricelistid,datepx) values('"
		sqlStr=sqlStr & cpord & "','"
		sqlStr=sqlStr & curCate & "','"
		sqlStr=sqlStr & 0 & "','"
		sqlStr=sqlStr & 1 & "','"
		sqlStr=sqlStr & iif(act="yugou_edit_add", xjmxid, 0) & "','"
		sqlStr=sqlStr & now & "')"
		Conn.execute(sqlStr)
		mxid = GetIdentity("mxpx","id","cateid","")
		Case "edit_tjXunjia", "price_edit_tjXunjia"
		sqlStr="Insert Into mxpx(ord,cateid,topid,sort1,datepx) values('"
		sqlStr=sqlStr & cpord & "','"
		sqlStr=sqlStr & curCate& "','"
		sqlStr=sqlStr & pricelist & "','"
		sqlStr=sqlStr & iif(act="price_edit_tjXunjia",1,3) & "','"
		sqlStr=sqlStr & now & "')"
		Conn.execute(sqlStr)
		mxid = GetIdentity("mxpx","id","cateid","")
		tpx2 = conn.execute("select count(1) from mxpx where cateid="& curCate &" and topid="&pricelist&" ")(0)
		If tpx2&""="" Then tpx2 = 0
		Call getCompanyInfo()
		Case "changeUnit"
		Call xjmx_init(act)
		End Select
		If act = "price_edit_add" Then
			dis="disabled"
		else
			dis=""
		end if
		Response.write "" & vbcrlf & "<table border=""0"" id=""tpx"
		Response.write tpx
		Response.write """ cellpadding=""3"" cellspacing=""0"" style=""width:"
		Response.write num1_kd
		Response.write "px;word-break:break-all;word-wrap:break-word;border-collapse:collapse;table-layout:fixed"" class=""xunjia_pro_list"">" & vbcrlf & "  <tr onmouseout=this.style.backgroundColor="""" onmouseover=this.style.backgroundColor=""ecf5ff""> " & vbcrlf & ""
'Response.write num1_kd
		for i=0 to len_rsxjmx
			sorce = rs_xjmx(3,i) : kd = rs_xjmx(4,i) : mxSet_open = rs_xjmx(5,i)
			strDisplay="" : leftTdBorder = iif(i=0, "border-left:#C0CCDD 1px solid;","")
'sorce = rs_xjmx(3,i) : kd = rs_xjmx(4,i) : mxSet_open = rs_xjmx(5,i)
			if (sorce=7 Or (sorce>=10 And sorce<=16)) and open_24_21=0 then
				If mxSet_open=0 Then strDisplay=" display:none;"
			else
'If mxSet_open=0 Then strDisplay=" display:none;"
			end if
			if sorce=1 then
				Select Case act
				Case "tjXunjia","edit_tjXunjia","price_tjXunjia","price_edit_tjXunjia"
				Response.write "" & vbcrlf & "        <td style="""
				Response.write leftTdBorder
				Response.write "width:"
				Response.write kd
				Response.write "px"" class=""dataCell inputCell"" align=""center""> 询价"
				Response.write iif(tpx2&""="",tpx,tpx2)
				Response.write "<a href=""javascript:void(0)"" onclick='del(""trpx"
				Response.write tpx
				Response.write ""","""
				Response.write mxid
				Response.write """,event);'><img src=""../images/del2.gif""  border='0' alt=""删除此条数据""></a></td>" & vbcrlf & ""
				Case Else
				Response.write "" & vbcrlf & "    <td style="""
				Response.write leftTdBorder
				Response.write "width:"
				Response.write kd
				Response.write "px"" class=""dataCell inputCell"">"
				if open_21_14=1 then
					Response.write "<a href=""javascript:void(0)""  onclick='javascript:window.open(""../product/content.asp?ord="
					Response.write pwurl(cpord)
					Response.write """,""newwin21"",""width=""+800+"",height=""+500+"",toolbar=0,scrollbars=1,resizable=1,left=100,top=100"");return false;' alt=""查看产品详情"">"
'Response.write pwurl(cpord)
				end if
				Response.write "&nbsp;"
				Response.write cpTitle
				Response.write "</a>"
				If mxcpDel&"" = "0" Then
					Response.write "<span class='red'>已彻底删除</span>"
				ElseIf mxcpDel&"" = "2" Then
					Response.write "<span class='red'>(已删除)</span>"
				end if
				Response.write "&nbsp;"
				If mxDelAble Then
					Response.write "<a href=""javascript:void(0)"" onclick=del(""tr_px"
					Response.write tpx
					Response.write ""","""
					Response.write mxid
					Response.write """,event);><img src=""../images/del2.gif""  border=0 alt=""删除此条数据""></a>&nbsp;"
				end if
				If act = "price_edit_add" Then
					Response.write "<a href=""javascript:void(0)"" id=""xj_pro_1_"
					Response.write mxid
					Response.write """ "
					if Xunjiastatus&""="1" then
						Response.write " style=""display:none"""
					end if
					Response.write " onclick='xj_callServer4("""
					Response.write cpord
					Response.write ""","""
					Response.write mxid
					Response.write ""","""
					Response.write tpx+1
					Response.write ""","""
					Response.write ""","""
					Response.write unit
					Response.write """);'><img src=""../images/add.gif"" alt=""添加此产品询价""  border=0/></a>" & vbcrlf & "        "
				else
					Response.write tpx+1
					Response.write """);'><img src=""../images/add.gif"" alt=""添加此产品询价""  border=0/></a>" & vbcrlf & "        "
					Response.write " <a href=""javascript:void(0)"" id=""xj_pro_1_"
					Response.write mxid
					Response.write """ "
					if Xunjiastatus&""="1" then
						Response.write " style=""display:none"""
					end if
					Response.write " onclick='callServer4_2("""
					Response.write cpord
					Response.write ""","""
					Response.write mxid
					Response.write ""","""
					Response.write tpx+1
					Response.write ""","""
					Response.write unit
					Response.write """);'><img src=""../images/add.gif"" alt=""添加此产品询价""  border=0/></a>"
					Response.write "<input type='hidden' name='caigoulist_"& mxid &"' value='"& caigoulist &"'>"
					Response.write "<input type='hidden' name='caigoulist_yg_"& mxid &"' value='"& caigoulist_yg &"'>"
				end if
				Response.write "</td>" & vbcrlf & ""
				End Select
			elseif sorce=2 then
				Response.write "" & vbcrlf & "              <td  style="""
				Response.write leftTdBorder
				Response.write "width:"
				Response.write kd
				Response.write "px;"
				Response.write strDisplay
				Response.write """ class=""dataCell inputCell"">"
				If act="tjXunjia" Or act="edit_tjXunjia" Then Response.write "" Else Response.write order1
				Response.write "</td>" & vbcrlf & ""
			elseif sorce=3 then
				Response.write "" & vbcrlf & "              <td  style="""
				Response.write leftTdBorder
				Response.write "width:"
				Response.write kd
				Response.write "px;"
				Response.write strDisplay
				Response.write """ class=""dataCell inputCell"">"
				If act="tjXunjia" Or act="edit_tjXunjia" Then Response.write "" Else Response.write type1
				Response.write "</td>" & vbcrlf & ""
			elseif sorce=4 then
				Response.write "" & vbcrlf & "              <td  align=""center"" style="""
				Response.write leftTdBorder
				Response.write "width:"
				Response.write kd
				Response.write "px"" class=""dataCell inputCell"">" & vbcrlf & "              "
				If changeUnitAble Then
					If act&""="tjXunjia" Or act="edit_tjXunjia" Or act="price_tjXunjia" Or act="price_edit_tjXunjia" Or act="yugou_edit_add" Then
						Set rs7 = conn.execute("select sort1 from sortonehy where gate2=61 and id="& unit &" order by gate1 desc")
						If rs7.eof = False Then
							Response.write rs7("sort1")
							Response.write "<input name=""unit_"
							Response.write mxid
							Response.write """ id=""u_namecaigou"
							Response.write mxid
							Response.write """ type=""hidden"" size=""1"" value="""
							Response.write unit
							Response.write """/>"
						end if
						rs7.close
						Set rs7 = Nothing
					else
						Response.write "" & vbcrlf & "              <select name=""unit_"
						Response.write mxid
						Response.write """ id=""u_nametest"
						Response.write mxid
						Response.write """ dataType=""Range"" msg=""不能为空"" min=""1"" max=""9999999999999"" onChange='callServer(""test"
						Response.write mxid
						Response.write ""","""
						Response.write cpord
						Response.write ""","""
						Response.write tpx
						Response.write ""","""
						Response.write mxid
						Response.write """);'>" & vbcrlf & ""
						for u=0 to len_rsunit
							Response.write "" & vbcrlf & "               <option value="""
							Response.write rs_unit(0,u)
							Response.write """ "
							if unit&""=rs_unit(0,u)&"" then
								Response.write " selected "
							end if
							Response.write " >"
							Response.write rs_unit(1,u)
							Response.write "</option>" & vbcrlf & ""
						next
						Response.write "" & vbcrlf & "      </select>" & vbcrlf & ""
					end if
				else
					Set rs7 = conn.execute("select sort1 from sortonehy where gate2=61 and id="& unit &" order by gate1 desc")
					If rs7.eof = False Then
						Response.write rs7("sort1")
						Response.write "<input name=""unit_"
						Response.write mxid
						Response.write """ id=""u_namecaigou"
						Response.write mxid
						Response.write """ type=""hidden"" size=""1"" value="""
						Response.write unit
						Response.write """/>"
					end if
					rs7.close
					Set rs7 = Nothing
				end if
				Response.write "" & vbcrlf & "        </td>" & vbcrlf & ""
			elseif sorce=5 then
				If act&""="tjXunjia" Or act="edit_tjXunjia" Or act="price_tjXunjia" Or act="price_edit_tjXunjia" Then
					Response.write "" & vbcrlf & "              <td  style="""
					Response.write leftTdBorder
					Response.write "width:"
					Response.write kd
					Response.write "px"" class=""dataCell inputCell"">" & vbcrlf & "              <span id=""tcaigou"
					Response.write mxid
					Response.write """>" & vbcrlf & "                "
					if open_26_1=3 or CheckPurview(intro_26_1,trim(company_cateid))=True then
						if open_26_14=3 or CheckPurview(intro_26_14,trim(company_cateid))=True then
							Response.write "" & vbcrlf & "             <a href=""javascript:void(0)"" onclick='javascript:window.open(""../work2/content.asp?ord="
							Response.write pwurl(company_ord)
							Response.write """,""newwin23"",""width=""+900+"",height=""+500+"",toolbar=0,scrollbars=1,resizable=1,left=100,top=100"");return false;'  title=""点击可查看供应商详情"">" & vbcrlf & "              "
'Response.write pwurl(company_ord)
						end if
						Response.write company_name
						Response.write "" & vbcrlf & "             </a>"
						If mxgysDel = 2 Then
							Response.write "<span class='red'>(已删除)</span>"
						ElseIf mxgysDel = 0 Then
							Response.write "<span class='red'>已彻底删除</span>"
						end if
					end if
					Response.write "" & vbcrlf & "             <input name=""gys_"
					Response.write mxid
					Response.write """ type=""hidden"" value="""
					Response.write company_ord
					Response.write """><img class='resetElementHidden' src='../images/jiantou.gif' /><img class='resetElementShow' style='display:none;' src='../skin/default/images/MoZihometop/content/lvw_addrow_btn.png' /><a class=""blue2"" href=""javascript:void(0)"" onclick=callServer2(""caigou"
					Response.write mxid
					Response.write ""","""
					Response.write cpord
					Response.write ""","""
					Response.write company1
					Response.write ""","""
					Response.write mxid
					Response.write """,event);>重选</a></span>" & vbcrlf & "         <div id=""caigou"
					Response.write mxid
					Response.write """></div></td>" & vbcrlf & ""
				else
					Response.write "" & vbcrlf & "             <td  style="""
					Response.write leftTdBorder
					Response.write "width:"
					Response.write kd
					Response.write "px"" class=""dataCell inputCell""><div align=""center""><a id=""xj_1_"
					Response.write mxid
					Response.write """ href=""javascript:void(0)"" onclick='"
					If act&""="price_edit_add" Then Response.write "xj_callServer4" Else Response.write "callServer4_2"
					Response.write "("""
					Response.write cpord
					Response.write ""","""
					Response.write mxid
					Response.write ""","""
					Response.write tpx+1
					Response.write ""","""
					Response.write ""","""
					Response.write unit
					Response.write """);' "
					if Xunjiastatus&""="1" then
						Response.write " style=""display:none"""
					end if
					Response.write ">添加询价<img src=""../images/add.gif"" alt=""添加此产品询价""  border=0/></a>" & vbcrlf & "               "
					If needXJ Then
						Response.write "<input type=""hidden"" name=""Xunjiastatus_"
						Response.write mxid
						Response.write """ id=""Xunjiastatus_"
						Response.write mxid
						Response.write """ value="""
						Response.write iif(Xunjiastatus&""="",0, Xunjiastatus)
						Response.write """>" & vbcrlf & "                <a href=""javascript:void(0);"" id=""xj_2_"
						Response.write mxid
						Response.write """ onClick=""callServer8('1','"
						Response.write mxid
						Response.write "');return false;"""
						if Xunjiastatus&""="1" then
							Response.write " style=""display:none"""
						end if
						Response.write ">无需询价</a>" & vbcrlf & "                 <a href=""javascript:void(0);"" id=""xj_3_"
						Response.write mxid
						Response.write """ onClick=""callServer8('0','"
						Response.write mxid
						Response.write "');return false;"" "
						if Xunjiastatus&""="0" or Xunjiastatus&""="" then
							Response.write " style=""display:none"""
						end if
						Response.write ">需要询价</a>" & vbcrlf & "                 "
					end if
					If toBJAble Then
						Response.write "" & vbcrlf & "              <a href=""javascript:void(0);"" onClick=""saveXunjia2('2','"
						Response.write mxid
						Response.write "');return false;"">生成报价</a>" & vbcrlf & "            "
					end if
					Response.write "</div></td>" & vbcrlf & ""
				end if
			elseif sorce=6 then
				Response.write "             " & vbcrlf & "                <td  style="""
				Response.write leftTdBorder
				Response.write "width:"
				Response.write kd
				Response.write "px"" class=""dataCell inputCell""><div align=""center""><input Name=""num1_"
				Response.write mxid
				Response.write """ id=""num"
				Response.write mxid
				Response.write """ value="""
				Response.write num1
				Response.write """ "
				If mxEditAble=False And InStr(act&"","_edit_add")>0 Then
					Response.write " readonly "
				else
					Response.write " onfocus=""if(value==defaultValue){value='';this.style.color='#000'}""  onBlur=""if(!value){value=defaultValue;this.style.color='#000'}"" onkeyup=""checkDot('num"
					Response.write mxid
					Response.write "','"
					Response.write num1_dot
					Response.write "')""  onpropertychange=""formatData(this,'number');chtotal("
					Response.write mxid
					Response.write ","
					Response.write num_dot_xs
'Response.write ","
					Response.write jf
					Response.write ",this);"""
				end if
				Response.write " type=""text""  style=""height: 19px; solid;font-size: 9pt;"" size=""5"" dataType=""Limit"" min=""1"" max=""100""  msg=""不能为空"">" & vbcrlf & ""
				Response.write ",this);"""
				if ZBRuntime.MC(17000) then
					Response.write "" & vbcrlf & "             <img src='../images/116.png' onmouseover=callServer5('tttttest"
					Response.write mxid
					Response.write "','"
					Response.write iif(act&""="tjXunjia"  Or act="edit_tjXunjia"  Or act="price_edit_add" Or act="price_edit_tjXunjia" Or act="price_tjXunjia" Or act="yugou_edit_add","caigou","test") & mxid
					Response.write "','"
					Response.write cpord
					Response.write "','"
					Response.write mxid
					Response.write "'); onmouseout=callServer6('tttttest"
					Response.write mxid
					Response.write "','"
					Response.write iif(act&""="tjXunjia" Or act="edit_tjXunjia"  Or act="price_edit_add" Or act="price_edit_tjXunjia" Or act="price_tjXunjia" ,"caigou","test") &mxid
					Response.write "','"
					Response.write cpord
					Response.write "','"
					Response.write mxid
					Response.write "'); border=0 style='cursor:hand'>" & vbcrlf & ""
				end if
				Response.write "" & vbcrlf & "             <span id='tttttest"
				Response.write mxid
				Response.write "' style='position:absolute;margin-left:0;'></span></div></td>" & vbcrlf & ""
				Response.write mxid
			elseif sorce=7 then
				Response.write "" & vbcrlf & "             <td class=""name dataCell"" style=""width:"
				Response.write kd
				Response.write "px;"
				Response.write leftTdBorder
				Response.write strDisplay
				Response.write """>" & vbcrlf & "                        <div align=""center"">" & vbcrlf & "                              <input name=""price1_"
				Response.write mxid
				Response.write """  id=""pricetest"
				Response.write mxid
				Response.write """ maxlength=""20"" type=""text""  value="""
				Response.write FormatNumber(price1,StorePrice_dot_num,-1,0,0)
'Response.write """ maxlength=""20"" type=""text""  value="""
				Response.write """ " & vbcrlf & "                                        style=""height: 19px; solid;font-size: 9pt;text-align:right;width:50px;white-space: nowrap"" " & vbcrlf & "                                       "
'Response.write """ maxlength=""20"" type=""text""  value="""
				If mxEditAble=False And InStr(act&"","_edit_add")>0 Then
					Response.write " readonly "
				else
					Response.write "onfocus=""if(value==defaultValue){value='';this.style.color='#000'}""" & vbcrlf & "                                    onBlur=""if(!value){value=defaultValue;this.style.color='#000';chtotal("
					Response.write mxid
					Response.write ","
					Response.write num_dot_xs
'Response.write ","
					Response.write jf
					Response.write ",this);};checkDot('pricetest"
					Response.write mxid
					Response.write "','"
					Response.write StorePrice_dot_num
					Response.write "')""" & vbcrlf & "                                       onkeyup=""checkDot('pricetest"
					Response.write mxid
					Response.write "','"
					Response.write StorePrice_dot_num
					Response.write "') """ & vbcrlf & "                                      onpropertychange=""formatData(this,'StorePrice');chtotal("
					Response.write mxid
					Response.write ","
					Response.write num_dot_xs
'Response.write ","
					Response.write jf
					Response.write ",this);"" " & vbcrlf & "                                 "
				end if
				Response.write "" & vbcrlf & "                                     dataType=""Range"" msg=""金额必须在0-999999999999"" min=0 max=""999999999999""  />" & vbcrlf & "                  </div>" & vbcrlf & "          </td>" & vbcrlf & ""
				Response.write ",this);"" " & vbcrlf & "                                 "
			elseif sorce=8 then
				Response.write "" & vbcrlf & "             <td class=""dataCell inputCell"" align=""center"" style=""width:"
				Response.write kd
				Response.write "px;"
				Response.write leftTdBorder
				Response.write strDisplay
				Response.write """>" & vbcrlf & "                        <input type=""text"" name=""taxRate_"
				Response.write mxid
				Response.write """ id=""taxRate_"
				Response.write mxid
				Response.write """ value="""
				Response.write FormatNumber(taxRate,num_dot_xs,-1,0,0)
				Response.write """ value="""
				Response.write """ " & vbcrlf & "                                readonly onfocus=""blur()"" onpropertychange=""chtotal("
				Response.write mxid
				Response.write ","
				Response.write num_dot_xs
'Response.write ","
				Response.write jf
				Response.write ",this);"" style=""color: #666666;border: #CCCCCC 1px solid;text-align:right;width:70%""/>%" & vbcrlf & "             </td>" & vbcrlf & ""
'Response.write jf
			elseif sorce=9 then
				Response.write "" & vbcrlf & "             <td style="""
				Response.write leftTdBorder
				Response.write "width:"
				Response.write kd
				Response.write "px;"
				Response.write strDisplay
				Response.write """ class=""dataCell inputCell"">" & vbcrlf & "               <div align=""center"">" & vbcrlf & "              <select name=""invoiceType_"
				Response.write mxid
				Response.write """ "
				Response.write dis
				Response.write " id=""invoiceType_"
				Response.write mxid
				Response.write """ includeTax="""
				Response.write includeTax
				Response.write """ onchange=""changeInvoice("
				Response.write mxid
				Response.write ");""  "
				Response.write iif(mxEditAble=False And InStr(act&"","_edit_add")>0 , "disabled","")
				Response.write " mxEditAble="""
				Response.write iif(mxEditAble=False And InStr(act&"","_edit_add")>0 , 0,1)
				Response.write """>" & vbcrlf & "                        "
				for v=0 to len_rsinvoice
					Response.write "" & vbcrlf & "                             <option value="""
					Response.write rs_invoice(0,v)
					Response.write """ "
					If invoiceType2&""=rs_invoice(0,v)&"" Then Response.write "selected"
					Response.write "" & vbcrlf & "                                     taxRate="""
					Response.write FormatNumber(rs_invoice(2,v),num_dot_xs,-1,0,0)
'Response.write "" & vbcrlf & "                                     taxRate="""
					Response.write """ " & vbcrlf & "                                        formula="""
					Response.write rs_invoice(3,v)
					Response.write """ formula2="""
					Response.write rs_invoice(4,v)
					Response.write """>"
					Response.write rs_invoice(1,v)
					Response.write "</option>" & vbcrlf & "                    "
				next
				Response.write "" & vbcrlf & "                     </select>" & vbcrlf & "                       </div></td>" & vbcrlf & ""
			elseif sorce=10 then
				If Not isnumeric(DISCOUNT_DOT_NUM) Then DISCOUNT_DOT_NUM = 1
				Response.write "" & vbcrlf & "             <td class=""dataCell inputCell"" align=""center"" style=""width:"
				Response.write kd
				Response.write "px;"
				Response.write leftTdBorder
				Response.write strDisplay
				Response.write """>" & vbcrlf & "                        <input type=""text"" name=""discount_"
				Response.write mxid
				Response.write """ id=""discount_"
				Response.write mxid
				Response.write """ value="""
				Response.write FormatNumber(discount,DISCOUNT_DOT_NUM,-1,0,0)
				Response.write """ value="""
				Response.write """ style=""width:90%;text-align:right;white-space: nowrap"" " & vbcrlf & "                   "
				Response.write """ value="""
				If mxEditAble=False And InStr(act&"","_edit_add")>0 Then
					Response.write " readonly "
				else
					Response.write "onfocus=""if(value==defaultValue){value='';this.style.color='#000'}"" " & vbcrlf & "                   onBlur=if(!value){value=defaultValue;this.style.color='#000';chtotal("
					Response.write mxid
					Response.write ","
					Response.write num_dot_xs
'Response.write ","
					Response.write jf
					Response.write ",this)} " & vbcrlf & "                     onkeyup=""checkDot('discount_"
					Response.write mxid
					Response.write "','"
					Response.write DISCOUNT_DOT_NUM
					Response.write "');""" & vbcrlf & "                      msg=""折扣必须控制在0-"
'Response.write DISCOUNT_DOT_NUM
					Response.write FormatNumber(DISCOUNT_MAX_VALUE,DISCOUNT_DOT_NUM,-1,0,0)
'Response.write DISCOUNT_DOT_NUM
					Response.write "之间"" dataType=""Range"" min=""0"" max="""
					Response.write DISCOUNT_MAX_VALUE
					Response.write """" & vbcrlf & "                 onpropertychange=""formatData(this,'discount');chtotal("
					Response.write mxid
					Response.write ","
					Response.write num_dot_xs
					Response.write ","
					Response.write jf
					Response.write ",this)""" & vbcrlf & "                   "
				end if
				Response.write "" & vbcrlf & "                     msgWhenHide=""折扣必须控制在0-"
				Response.write ",this)""" & vbcrlf & "                   "
				Response.write FormatNumber(DISCOUNT_MAX_VALUE,DISCOUNT_DOT_NUM,-1,0,0)
				Response.write ",this)""" & vbcrlf & "                   "
				Response.write "之间（请联系管理员在明细自定义中开启该字段）"" " & vbcrlf & "                    />" & vbcrlf & "                      <input type=""hidden"" name=""discountValue_"
				Response.write mxid
				Response.write """ id=""discountValue_"
				Response.write mxid
				Response.write """ value="""
				Response.write discount
				Response.write """/>" & vbcrlf & "               </td>" & vbcrlf & ""
			elseif sorce=11 then
				Response.write "" & vbcrlf & "             <td class=""dataCell inputCell"" align=""center"" style=""width:"
				Response.write kd
				Response.write "px;"
				Response.write leftTdBorder
				Response.write strDisplay
				Response.write """>" & vbcrlf & "                        <input type=""text"" name=""priceAfterDiscount_"
				Response.write mxid
				Response.write """ style=""white-space: nowrap"" id=""priceAfterDiscount_"
				Response.write mxid
				Response.write mxid
				Response.write """ value="""
				Response.write FormatNumber(priceAfterDiscount,StorePrice_dot_num,-1,0,0)
				Response.write """ value="""
				Response.write """ " & vbcrlf & "                        "
				If mxEditAble=False And InStr(act&"","_edit_add")>0 Then
					Response.write " readonly "
				else
					Response.write "onfocus=""if(value==defaultValue){value='';this.style.color='#000'}"" " & vbcrlf & "                   onBlur=if(!value){value=defaultValue;this.style.color='#000';chtotal("
					Response.write mxid
					Response.write ","
					Response.write num_dot_xs
'Response.write ","
					Response.write jf
					Response.write ",this);} " & vbcrlf & "                    onkeyup=""checkDot('priceAfterDiscount_"
					Response.write mxid
					Response.write "','"
					Response.write StorePrice_dot_num
					Response.write "');""" & vbcrlf & "                      style=""width:90%;text-align:right"" dataType=""Range"" msg=""金额必须在0-999999999999"" min=0 max=""999999999999"" " & vbcrlf & "                    "
'Response.write StorePrice_dot_num
				end if
				Response.write "" & vbcrlf & "                     onpropertychange=""formatData(this,'StorePrice');chtotal("
				Response.write mxid
				Response.write ","
				Response.write num_dot_xs
'Response.write ","
				Response.write jf
				Response.write ",this);""/>" & vbcrlf & "                </td>" & vbcrlf & ""
			elseif sorce=12 then
				Response.write "" & vbcrlf & "             <td class=""dataCell inputCell"" align=""center"" style=""width:"
				Response.write kd
				Response.write "px;"
				Response.write leftTdBorder
				Response.write strDisplay
				Response.write """>" & vbcrlf & "                        <input type=""text"" name=""priceIncludeTax_"
				Response.write mxid
				Response.write """ style=""white-space: nowrap"" id=""priceIncludeTax_"
				Response.write mxid
				Response.write mxid
				Response.write """ value="""
				Response.write FormatNumber(priceIncludeTax,StorePrice_dot_num,-1,0,0)
				Response.write """ value="""
				Response.write """  " & vbcrlf & "                       "
				If mxEditAble=False And InStr(act&"","_edit_add")>0 Then
					Response.write " readonly "
				else
					Response.write "onfocus=""if(value==defaultValue){value='';this.style.color='#000'}"" " & vbcrlf & "                   onBlur=""if(!value){value=defaultValue;this.style.color='#000';chtotal("
					Response.write mxid
					Response.write ","
					Response.write num_dot_xs
'Response.write ","
					Response.write jf
					Response.write ",this);}""" & vbcrlf & "                 onkeyup=""checkDot('priceIncludeTax_"
					Response.write mxid
					Response.write "','"
					Response.write StorePrice_dot_num
					Response.write "');"" " & vbcrlf & "                     onpropertychange=""formatData(this,'StorePrice');chtotal("
					Response.write mxid
					Response.write ","
					Response.write num_dot_xs
'Response.write ","
					Response.write jf
					Response.write ",this);""" & vbcrlf & "                  "
				end if
				Response.write "" & vbcrlf & "                     dataType=""Range"" msg=""金额必须在0-999999999999"" min=""0"" max=""999999999999"" " & vbcrlf & "                     style=""width:95%;text-align:right""/>" & vbcrlf & "              </td>" & vbcrlf & ""
				Response.write ",this);""" & vbcrlf & "                  "
			elseif sorce=13 then
				Response.write "" & vbcrlf & "             <td class=""dataCell inputCell"" align=""center"" style=""width:"
				Response.write kd
				Response.write "px;"
				Response.write leftTdBorder
				Response.write strDisplay
				Response.write """>" & vbcrlf & "                        <input type=""text"" name=""priceAfterTax_"
				Response.write mxid
				Response.write """ style=""white-space: nowrap"" id=""priceAfterTax_"
				Response.write mxid
				Response.write mxid
				Response.write """ value="""
				Response.write FormatNumber(priceAfterTax,StorePrice_dot_num,-1,0,0)
				Response.write """ value="""
				Response.write """                 " & vbcrlf & "                        "
				If mxEditAble=False And InStr(act&"","_edit_add")>0 Then
					Response.write " readonly "
				else
					Response.write "onfocus=""if(value==defaultValue){value='';this.style.color='#000'}"" " & vbcrlf & "                   onBlur=""if(!value){value=defaultValue;this.style.color='#000';chtotal("
					Response.write mxid
					Response.write ","
					Response.write num_dot_xs
'Response.write ","
					Response.write jf
					Response.write ",this);}""" & vbcrlf & "                 onkeyup=""checkDot('priceAfterTax_"
					Response.write mxid
					Response.write "','"
					Response.write StorePrice_dot_num
					Response.write "');"" " & vbcrlf & "                     onpropertychange=""formatData(this,'StorePrice');chtotal("
					Response.write mxid
					Response.write ","
					Response.write num_dot_xs
'Response.write ","
					Response.write jf
					Response.write ",this);""" & vbcrlf & "                  "
				end if
				If InStr(act&"","tjXunjia")>0 Then
					Response.write "" & vbcrlf & "                      dataType=""Range"" msg=""高于限价"" max="""
					Response.write price1_limit
					Response.write """ min=0 " & vbcrlf & "                  msgWhenHide = ""含税折后单价高于限价（请联系管理员在明细自定义中开启该字段）""" & vbcrlf & "                      "
				else
					Response.write "dataType='Range' msg='金额必须在0-999999999999' min='0' max='999999999999' "
				end if
				Response.write "" & vbcrlf & "                     style=""text-align:right;width:95%""/>" & vbcrlf & "              </td>" & vbcrlf & ""
			elseif sorce=14 then
				Response.write "" & vbcrlf & "             <td style=""width:"
				Response.write kd
				Response.write "px;"
				Response.write leftTdBorder
				Response.write strDisplay
				Response.write """ class=""dataCell inputCell""><input name=""moneyall_"
				Response.write mxid
				Response.write """ id=""moneyall"
				Response.write mxid
				Response.write """ type=""text"" value="""
				Response.write FormatNumber(money1,num_dot_xs,-1,0,0)
'Response.write """ type=""text"" value="""
				Response.write """ readonly dataType=""Range"" min=""0"" max=""999999999999.9999"" msg=""金额必须在0-999999999999.9999"" size=""10"" style=""color: #666666;border: #CCCCCC 1px solid;text-align:right;width:95%"" ></td>" & vbcrlf & ""
'Response.write """ type=""text"" value="""
			elseif sorce=15 then
				Response.write "" & vbcrlf & "               <td class=""dataCell inputCell"" align=""center"" style=""width:"
				Response.write kd
				Response.write "px;"
				Response.write leftTdBorder
				Response.write strDisplay
				Response.write """>" & vbcrlf & "                  <input type=""text"" name=""taxValue_"
				Response.write mxid
				Response.write """ id=""taxValue_"
				Response.write mxid
				Response.write """ readonly value="""
				Response.write FormatNumber(taxValue,num_dot_xs,-1,0,0)
'Response.write """ readonly value="""
				Response.write """ style=""width:95%;color:#666666;border: #CCCCCC 1px solid;text-align:right""/>" & vbcrlf & "               </td>" & vbcrlf & ""
'Response.write """ readonly value="""
			elseif sorce=16 then
				Response.write "" & vbcrlf & "              <td class=""dataCell inputCell"" align=""center"" style=""width:"
				Response.write kd
				Response.write "px;"
				Response.write leftTdBorder
				Response.write strDisplay
				Response.write """>" & vbcrlf & "                 <input type=""text"" name=""moneyAfterTax_"
				Response.write mxid
				Response.write """ id=""moneyAfterTax_"
				Response.write mxid
				Response.write """ readonly value="""
				Response.write FormatNumber(moneyAfterTax,num_dot_xs,-1,0,0)
'Response.write """ readonly value="""
				Response.write """ style=""width:95%;color:#666666;border: #CCCCCC 1px solid;text-align:right""/>" & vbcrlf & "               </td>" & vbcrlf & ""
'Response.write """ readonly value="""
			elseif sorce=17 then
				Response.write "" & vbcrlf & "    <td align=""center"" style="""
				Response.write leftTdBorder
				Response.write "width:"
				Response.write kd
				Response.write "px;"
				Response.write strDisplay
				Response.write """ class=""dataCell inputCell""><INPUT name=""date1_"
				Response.write mxid
				Response.write """  id=""daysdate1_"
				Response.write mxid
				Response.write "Pos"" value="""
				Response.write date2
				Response.write """ size=9   style=""height: 19px; solid;font-size: 9pt;"" "
'Response.write date2
				If mxEditAble=False And InStr(act&"","_edit_add")>0 Then
					Response.write " readonly "
				else
					Response.write " onmouseup=toggleDatePicker('daysdate1_"
					Response.write mxid
					Response.write "','date.date1_"
					Response.write mxid
					Response.write "') "
				end if
				Response.write "  dataType=""Date"" format=""ymd""  msg=""日期格式不正确""><DIV id='daysdate1_"
				Response.write mxid
				Response.write "' style='POSITION: absolute'></DIV></td>" & vbcrlf & ""
			elseif sorce=18 then
				Response.write "" & vbcrlf & "              <td align=""center"" style="""
				Response.write leftTdBorder
				Response.write "width:"
				Response.write kd
				Response.write "px;"
				Response.write strDisplay
				Response.write """ class=""dataCell inputCell""><textarea rows=""1"" id=""intro_"
				Response.write mxid
				Response.write """ name=""intro_"
				Response.write mxid
				Response.write """   style=""overflow-y:hidden;word-break:break-all;width:"
				Response.write mxid
				Response.write kd
				Response.write "px;"" " & vbcrlf & "               "
				If mxEditAble=False And InStr(act&"","_edit_add")>0 Then Response.write " readonly "
				Response.write " " & vbcrlf & "             onFocus=""this.style.posHeight=this.scrollHeight;productListResize();"" onpropertychange=""this.style.posHeight=this.scrollHeight;productListResize();"" dataType=""Limit"" min=""0"" max=""200"" msg=""不要超过200个字"">"
				Response.write mxIntro
				Response.write "</textarea></td>" & vbcrlf & ""
			elseif sorce=19 then
				Response.write "" & vbcrlf & "    <td align=""center"" style="""
				Response.write leftTdBorder
				Response.write "width:"
				Response.write kd
				Response.write "px;"
				Response.write strDisplay
				Response.write """ class=""dataCell inputCell""><input name=""zdy1_"
				Response.write mxid
				Response.write """ id=""zdy1_"
				Response.write mxid
				Response.write """ value="""
				Response.write cpzdy1
				Response.write """ "
				If mxEditAble=False And InStr(act&"","_edit_add")>0 Then Response.write " readonly "
				Response.write " type=""text"" style=""height: 19px;width:95%; solid;font-size: 9pt;"" size=""10"" dataType=""Limit"" min=""0"" max=""200"" msg=""不要超过200个字""></td>" & vbcrlf & ""
'If mxEditAble=False And InStr(act&"","_edit_add")>0 Then Response.write " readonly "
			elseif sorce=20 then
				Response.write "" & vbcrlf & "    <td align=""center"" style="""
				Response.write leftTdBorder
				Response.write "width:"
				Response.write kd
				Response.write "px;"
				Response.write strDisplay
				Response.write """ class=""dataCell inputCell""><input name=""zdy2_"
				Response.write mxid
				Response.write """ id=""zdy2_"
				Response.write mxid
				Response.write """ value="""
				Response.write cpzdy2
				Response.write """ "
				If mxEditAble=False And InStr(act&"","_edit_add")>0 Then Response.write " readonly "
				Response.write " type=""text"" style=""height: 19px;width:95%; solid;font-size: 9pt;"" size=""10"" dataType=""Limit"" min=""0"" max=""200"" msg=""不要超过200个字""></td>" & vbcrlf & ""
'If mxEditAble=False And InStr(act&"","_edit_add")>0 Then Response.write " readonly "
			elseif sorce=21 then
				Response.write "" & vbcrlf & "    <td align=""center"" style="""
				Response.write leftTdBorder
				Response.write "width:"
				Response.write kd
				Response.write "px;"
				Response.write strDisplay
				Response.write """ class=""dataCell inputCell""><input name=""zdy3_"
				Response.write mxid
				Response.write """ id=""zdy3_"
				Response.write mxid
				Response.write """ value="""
				Response.write cpzdy3
				Response.write """ "
				If mxEditAble=False And InStr(act&"","_edit_add")>0 Then Response.write " readonly "
				Response.write " type=""text"" style=""height: 19px;width:95%; solid;font-size: 9pt;"" size=""10"" dataType=""Limit"" min=""0"" max=""200"" msg=""不要超过200个字""></td>" & vbcrlf & ""
'If mxEditAble=False And InStr(act&"","_edit_add")>0 Then Response.write " readonly "
			elseif sorce=22 then
				Response.write "" & vbcrlf & "    <td align=""center"" style="""
				Response.write leftTdBorder
				Response.write "width:"
				Response.write kd
				Response.write "px;"
				Response.write strDisplay
				Response.write """ class=""dataCell inputCell""><input name=""zdy4_"
				Response.write mxid
				Response.write """ id=""zdy4_"
				Response.write mxid
				Response.write """ value="""
				Response.write cpzdy4
				Response.write """ "
				If mxEditAble=False And InStr(act&"","_edit_add")>0 Then Response.write " readonly "
				Response.write " type=""text"" style=""height: 19px;width:95%; solid;font-size: 9pt;"" size=""10"" dataType=""Limit"" min=""0"" max=""200"" msg=""不要超过200个字""></td>" & vbcrlf & ""
'If mxEditAble=False And InStr(act&"","_edit_add")>0 Then Response.write " readonly "
			elseif sorce=23 then
				Response.write "" & vbcrlf & "    <td align=""center""  style="""
				Response.write leftTdBorder
				Response.write "width:"
				Response.write kd
				Response.write "px;"
				Response.write strDisplay
				Response.write """ class=""dataCell inputCell"">" & vbcrlf & "       <select name=""zdy5_"
				Response.write mxid
				Response.write """ id=""zdy5_"
				Response.write mxid
				Response.write """>" & vbcrlf & ""
				for y5=0 to len_rszdy5
					Response.write "" & vbcrlf & "      <option value="""
					Response.write rs_zdy5(0,y5)
					Response.write """ "
					if rs_zdy5(0,y5)&""=cpzdy5&"" then
						Response.write "selected"
					end if
					Response.write ">"
					Response.write rs_zdy5(1,y5)
					Response.write "</option>" & vbcrlf & ""
				next
				Response.write "" & vbcrlf & "     </select></td>" & vbcrlf & ""
			elseif sorce=24 then
				Response.write "" & vbcrlf & "    <td align=""center""  style="""
				Response.write leftTdBorder
				Response.write "width:"
				Response.write kd
				Response.write "px;"
				Response.write strDisplay
				Response.write """ class=""dataCell inputCell"">" & vbcrlf & "       <select name=""zdy6_"
				Response.write mxid
				Response.write """ id=""zdy6_"
				Response.write mxid
				Response.write """>" & vbcrlf & ""
				for y6=0 to len_rszdy6
					Response.write "" & vbcrlf & "        <option value="""
					Response.write rs_zdy6(0,y6)
					Response.write """ "
					if rs_zdy6(0,y6)&""=cpzdy6&"" then
						Response.write "selected"
					end if
					Response.write ">"
					Response.write rs_zdy6(1,y6)
					Response.write "</option>" & vbcrlf & ""
				next
				Response.write "" & vbcrlf & "       </select></td>" & vbcrlf & ""
			end if
		next
		Response.write "" & vbcrlf & "             </tr></table>           " & vbcrlf & ""
		If act&""="add" Or act&""="changeUnit" Then
			num_xj=0
			for i=num_xj+1 to XUNJIA_SIZE
'num_xj=0
				Response.write"<span id='trpx" & (tpx+1) * XUNJIA_SIZE + i & "'></span>"
'num_xj=0
			next
		end if
	end function
	Function xjmx_edit(xjord, del)
		Dim rs, rs2, j, k, m, tpx2
		j = 0
		If del&"" = "" Then del = 1
		Set rs = conn.execute("select * from xunjialist where del="& del &" and xunjia="& xjord &" and pricelist=0 order by date7,id asc")
		If rs.eof Then
			Response.write "" & vbcrlf & "     <span id=""tr_px0"">" & vbcrlf & "        <table style=""width:"
			Response.write num1_kd
			Response.write "px"" border=""0""  cellpadding=""3"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;table-layout:fixed;"">" & vbcrlf & " <tr >" & vbcrlf & "             <td height=""30"" class=""dataCell inputCell"" style=""border-left:#C0CCDD 1px solid;"">无产品明细！</td>" & vbcrlf & "         </tr>" & vbcrlf & "       </table>" & vbcrlf & "        </span>" & vbcrlf & " "
		else
			Call baseParamInit()
			Call getPower1()
			Call getCateInfo()
			Call getBaseJgcl()
			Call getPower2()
			tpx = 0
			While rs.eof = False
				xjmxid = rs("id") : cpord = rs("ord") : pUnit = rs("unit")
				Call getProductInfo()
				Call getPriceInfo()
				num1 = rs("num1") : price1 = rs("price1") : taxRate = rs("taxRate") : invoiceType2 = rs("invoiceType") : discount = rs("discount")
				priceAfterDiscount = rs("priceAfterDiscount") : priceIncludeTax = rs("priceIncludeTax") : priceAfterTax = rs("priceAfterTax")
				money1 = rs("money1") : taxValue = rs("taxValue") : moneyAfterTax = rs("moneyAfterTax")
				date2 = rs("date2") : mxIntro = rs("intro") : cpzdy1 = rs("zdy1") : cpzdy2 = rs("zdy2") : cpzdy3 = rs("zdy3")
				cpzdy4 = rs("zdy4") : cpzdy5 = rs("zdy5") : cpzdy6 = rs("zdy6") : company1 = rs("gys")
				caigoulist = rs("caigoulist") : caigoulist_yg = rs("caigoulist_yg")
				Call getXjZdy56("edit_add")
				Response.write "<span id=""tr_px"& j &""">"
				Call xjmx_show("edit_add")
				j = j + 1 : pricelist = mxid : num_xj=0 : k=0 : tpx = j : tpx2 = tpx
'Call xjmx_show("edit_add")
				Set rs2 = conn.execute("select * from xunjialist where del=1 and xunjia="& xjord &" and pricelist="& xjmxid &" order by date7")
				If rs2.eof = False Then
					While rs2.eof = False
						num1 = rs2("num1") : price1 = rs2("price1") : taxRate = rs2("taxRate") : invoiceType2 = rs2("invoiceType") : discount = rs2("discount")
						priceAfterDiscount = rs2("priceAfterDiscount") : priceIncludeTax = rs2("priceIncludeTax") : priceAfterTax = rs2("priceAfterTax")
						money1 = rs2("money1") : taxValue = rs2("taxValue") : moneyAfterTax = rs2("moneyAfterTax")
						date2 = rs2("date2") : mxIntro = rs2("intro") : cpzdy1 = rs2("zdy1") : cpzdy2 = rs2("zdy2") : cpzdy3 = rs2("zdy3")
						cpzdy4 = rs2("zdy4") : cpzdy5 = rs2("zdy5") : cpzdy6 = rs2("zdy6") : company1 = rs2("gys")
						k = k + 1
'cpzdy4 = rs2("zdy4") : cpzdy5 = rs2("zdy5") : cpzdy6 = rs2("zdy6") : company1 = rs2("gys")
						Call getXjZdy56("edit_tjXunjia")
						Response.write"<span id='trpx" & (tpx2) * XUNJIA_SIZE + k & "'>"
'Call getXjZdy56("edit_tjXunjia")
						Call xjmx_show("edit_tjXunjia")
						Response.write "</span>"
						rs2.movenext
					wend
				end if
				rs2.close
				Set rs2 = Nothing
				For m = k+1 To XUNJIA_SIZE
'Set rs2 = Nothing
					Response.write"<span id='trpx" & (tpx2) * XUNJIA_SIZE + m & "'></span>"
'Set rs2 = Nothing
				next
				Response.write "</span>"
				rs.movenext
			wend
		end if
		rs.close
		set rs = nothing
		session("num_click2009")=j
		xjmx_edit = iif(j=0,j , j - 1)
'session("num_click2009")=j
	end function
	Function price_xjmx_edit(bjord, xjord, del)
		Dim rs, rs2, j, k, m, tpx2
		j = 0
		If del&"" = "" Then del = 1
		Set rs = conn.execute("select id,ord,unit,num1,isnull(price1,0)price1,isnull(TaxRate,0)TaxRate,InvoiceType,isnull(PriceAfterDiscount,0)PriceAfterDiscount,isnull(priceIncludeTax,0)priceIncludeTax, isnull(discount,0)discount,isnull(priceAfterTax,0)priceAfterTax,isnull(money1,0)money1,isnull(taxValue,0)taxValue,date2,intro,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6,Xunjiastatus from pricelist where del=3 and id not in(select isnull(pid,0) from pricelist where price="&bjord&" and del=1) and price="& bjord &" order by listorder asc, date7 asc,id asc")
		If rs.eof Then
			Response.write "" & vbcrlf & "     <span id=""tr_px0"">" & vbcrlf & "        <table style=""width:"
			Response.write num1_kd
			Response.write "px"" border=""0""  cellpadding=""3"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;table-layout:fixed;"">" & vbcrlf & " <tr >" & vbcrlf & "             <td height=""30"" class=""dataCell inputCell"" style=""border-left:#C0CCDD 1px solid;"">无产品明细！</td>" & vbcrlf & "         </tr>" & vbcrlf & "       </table>" & vbcrlf & "        </span>" & vbcrlf & " "
		else
			Call baseParamInit()
			Call getPower1()
			Call getCateInfo()
			Call getBaseJgcl()
			Call getPower2()
			tpx = 0 : xjmxid = 0
			While rs.eof = False
				mxid = rs("id") : cpord = rs("ord") : pUnit = rs("unit")
				Call getProductInfo()
				Call getPriceInfo()
				num1 = rs("num1") : price1 = rs("price1") : taxRate = rs("TaxRate") : invoiceType2 = rs("InvoiceType") : discount =rs("discount")
				priceAfterDiscount = rs("PriceAfterDiscount") : priceIncludeTax =rs("priceIncludeTax") : priceAfterTax = rs("priceAfterTax")
				money1 = rs("money1") : taxValue =rs("taxValue") : moneyAfterTax = money1
				date2 = rs("date2") : mxIntro = rs("intro") : cpzdy1 = rs("zdy1") : cpzdy2 = rs("zdy2") : cpzdy3 = rs("zdy3")
				cpzdy4 = rs("zdy4") : cpzdy5 = rs("zdy5") : cpzdy6 = rs("zdy6") : company1 = 0 : Xunjiastatus = rs("Xunjiastatus")
				Call getXjZdy56("price_edit_add")
				Response.write "<span id=""tr_px"& j &""">"
				Call xjmx_show("price_edit_add")
				j = j + 1 : pricelist = mxid : num_xj=0 : k=0 : tpx = j : tpx2 = tpx
'Call xjmx_show("price_edit_add")
				Response.write "<div id='price_xj_"&pricelist&"'>"
				Set rs2 = conn.execute("select * from xunjialist where pricelist="& mxid &" and xunjia in ("&xjord&") and del=1 order by date7 asc,id asc")
				If rs2.eof = False Then
					While rs2.eof = False
						xjmxid = rs2("id") : num1 = rs2("num1") : price1 = rs2("price1") : taxRate = rs2("taxRate")
						invoiceType2 = rs2("invoiceType") : discount = rs2("discount")
						priceAfterDiscount = rs2("priceAfterDiscount") : priceIncludeTax = rs2("priceIncludeTax") : priceAfterTax = rs2("priceAfterTax")
						money1 = rs2("money1") : taxValue = rs2("taxValue") : moneyAfterTax = rs2("moneyAfterTax")
						date2 = rs2("date2") : mxIntro = rs2("intro") : cpzdy1 = rs2("zdy1") : cpzdy2 = rs2("zdy2") : cpzdy3 = rs2("zdy3")
						cpzdy4 = rs2("zdy4") : cpzdy5 = rs2("zdy5") : cpzdy6 = rs2("zdy6") : company1 = rs2("gys")
						k = k + 1
'cpzdy4 = rs2("zdy4") : cpzdy5 = rs2("zdy5") : cpzdy6 = rs2("zdy6") : company1 = rs2("gys")
						Call getXjZdy56("price_edit_tjXunjia")
						Response.write"<span id='trpx" & (tpx2) * XUNJIA_SIZE + k & "'>"
'Call getXjZdy56("price_edit_tjXunjia")
						Call xjmx_show("price_edit_tjXunjia")
						Response.write "</span>"
						rs2.movenext
					wend
				end if
				rs2.close
				Set rs2 = Nothing
				For m = k+1 To XUNJIA_SIZE
'Set rs2 = Nothing
					Response.write"<span id='trpx" & (tpx2) * XUNJIA_SIZE + m & "'></span>"
'Set rs2 = Nothing
				next
				Response.write "</div>"
				Response.write "</span>"
				rs.movenext
			wend
		end if
		rs.close
		set rs = nothing
		session("num_click2009")=j
		price_xjmx_edit = iif(j=0,j , j - 1)
'session("num_click2009")=j
	end function
	Function yugou_xjmx_edit(ygord, xjord, del)
		Dim rs, rs2, j, k, m, tpx2
		j = 0
		If del&"" = "" Then del = 1
		sql = "select b.* from caigoulist_yg a inner join xunjialist b on a.id=b.caigoulist_yg and b.del in(1,7) and b.pricelist=0 and b.xunjia="& xjord &" where a.caigou="& ygord &" and a.del=1 order by a.date7 asc,a.id asc"
		set rs = conn.execute(sql)
		If rs.eof Then
			Response.write "" & vbcrlf & "     <span id=""tr_px0"">" & vbcrlf & "        <table style=""width:"
			Response.write num1_kd
			Response.write "px"" border=""0""  cellpadding=""3"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;table-layout:fixed;"">" & vbcrlf & " <tr >" & vbcrlf & "             <td height=""30"" class=""dataCell inputCell"" style=""border-left:#C0CCDD 1px solid;"">无产品明细！</td>" & vbcrlf & "         </tr>"& vbcrlf & "       </table>" & vbcrlf & "        </span>" & vbcrlf & " "
		else
			Call baseParamInit()
			Call getPower1()
			Call getCateInfo()
			Call getBaseJgcl()
			Call getPower2()
			tpx = 0 : xjmxid = 0
			While rs.eof = False
				cpord = rs("ord") : pUnit = rs("unit") : xjmxid = rs("id") : caigoulist_yg = rs("caigoulist_yg")
				Call getProductInfo()
				Call getPriceInfo()
				num1 = FormatNumber(rs("num1"),num1_dot,-1,0,0) : price1 = rs("price1") : taxRate = rs("taxRate") : invoiceType2 = rs("invoiceType") : discount = rs("discount")
'Call getPriceInfo()
				priceAfterDiscount = rs("priceAfterDiscount") : priceIncludeTax = rs("priceIncludeTax") : priceAfterTax = rs("priceAfterTax")
				money1 = rs("money1") : taxValue = rs("taxValue") : moneyAfterTax = rs("moneyAfterTax")
				date2 = rs("date2") : mxIntro = rs("intro") : cpzdy1 = rs("zdy1") : cpzdy2 = rs("zdy2") : cpzdy3 = rs("zdy3")
				cpzdy4 = rs("zdy4") : cpzdy5 = rs("zdy5") : cpzdy6 = rs("zdy6") : company1 = 0 : Xunjiastatus = rs("Xunjiastatus")
				If Xunjiastatus&"" = "" Then Xunjiastatus = 0
				Call getXjZdy56("yugou_edit_add")
				Response.write "<span id=""tr_px"& j &""">"
				Call xjmx_show("yugou_edit_add")
				j = j + 1 : pricelist = mxid : num_xj=0 : k=0 : tpx = j : tpx2 = tpx
'Call xjmx_show("yugou_edit_add")
				Response.write "<div id='price_xj_"&pricelist&"'>"
				Set rs2 = conn.execute("select * from xunjialist where del=1 and xunjia="& xjord &" and pricelist="& xjmxid &" order by date7")
				If rs2.eof = False Then
					While rs2.eof = False
						num1 = FormatNumber(rs2("num1"),num1_dot,-1,0,0)  : price1 = rs2("price1") : taxRate = rs2("taxRate") : invoiceType2 = rs2("invoiceType") : discount = rs2("discount")
'While rs2.eof = False
						priceAfterDiscount = rs2("priceAfterDiscount") : priceIncludeTax = rs2("priceIncludeTax") : priceAfterTax = rs2("priceAfterTax")
						money1 = rs2("money1") : taxValue = rs2("taxValue") : moneyAfterTax = rs2("moneyAfterTax")
						date2 = rs2("date2") : mxIntro = rs2("intro") : cpzdy1 = rs2("zdy1") : cpzdy2 = rs2("zdy2") : cpzdy3 = rs2("zdy3")
						cpzdy4 = rs2("zdy4") : cpzdy5 = rs2("zdy5") : cpzdy6 = rs2("zdy6") : company1 = rs2("gys")
						k = k + 1
'cpzdy4 = rs2("zdy4") : cpzdy5 = rs2("zdy5") : cpzdy6 = rs2("zdy6") : company1 = rs2("gys")
						Call getXjZdy56("edit_tjXunjia")
						Response.write"<span id='trpx" & (tpx2) * XUNJIA_SIZE + k & "'>"
'Call getXjZdy56("edit_tjXunjia")
						Call xjmx_show("edit_tjXunjia")
						Response.write "</span>"
						rs2.movenext
					wend
				end if
				rs2.close
				Set rs2 = Nothing
				For m = k+1 To XUNJIA_SIZE
'Set rs2 = Nothing
					Response.write"<span id='trpx" & (tpx2) * XUNJIA_SIZE + m & "'></span>"
'Set rs2 = Nothing
				next
				Response.write "</div>"
				Response.write "</span>"
				rs.movenext
			wend
		end if
		rs.close
		set rs = nothing
		session("num_click2009")=j
		yugou_xjmx_edit = iif(j=0,j , j - 1)
'session("num_click2009")=j
	end function
	fromName = "" : fromTitle = "" : fromTitleLink = "" : fromCate = 0 : fromCateName = ""
	Function getFromBillBase(fromtype, ord)
		If ord&"" = "" Then ord = 0
		Select Case fromtype&""
		Case "1"
		if ZBRuntime.MC(4000) And open_4_19<>1 then
			fromName = "报价"
			Set rs7 = conn.execute("select a.title, a.cateid, g.name from price a left join gate g on a.cateid=g.ord where a.ord="& ord)
			If rs7.eof = False Then
				fromTitle = rs7("title") : fromCateName = rs7("name") : fromCate = rs7("cateid")
			end if
			rs7.close
			Set rs7 = Nothing
			If fromCate&"" = "" Then fromCate = 0
			if ZBRuntime.MC(4000) And (open_4_1=3 or CheckPurview(intro_4_1,trim(fromCate))=True) Then
				if open_4_14=3 or CheckPurview(intro_4_14,trim(fromCate))=True Then
					fromTitleLink = "<a href=""javascript:;"" title=""点击可查看详情""  onclick=""javascript:window.open('../../SYSN/view/sales/price/price.ashx?ord="&pwurl(ord)&"&view=details','newwin2','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');return false;"">" & fromTitle&"</a>"
				else
					fromTitleLink = fromTitle
				end if
			end if
		end if
		Case "2"
		if ZBRuntime.MC(14000) And open_25_19<>1 then
			fromName = "预购"
			Set rs7 = conn.execute("select a.title, a.cateid, g.name from caigou_yg a left join gate g on a.cateid=g.ord where a.id="& ord)
			If rs7.eof = False Then
				fromTitle = rs7("title") : fromCateName = rs7("name") : fromCate = rs7("cateid")
			end if
			rs7.close
			Set rs7 = Nothing
			If fromCate&"" = "" Then fromCate = 0
			if ZBRuntime.MC(14000) And (open_25_1=3 or CheckPurview(intro_25_1,trim(fromCate))=True) Then
				if open_25_14=3 or CheckPurview(intro_25_14,trim(fromCate))=True Then
					fromTitleLink = "<a href=""javascript:;"" title=""点击可查看详情""  onclick=""javascript:window.open('../../SYSN/view/store/yugou/YuGou.ashx?ord="&pwurl(ord)&"&view=details','newygwin','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');return false;"">" & fromTitle&"</a>"
				else
					fromTitleLink = fromTitle
				end if
			end if
		end if
		End Select
	end function
	Response.write "" & vbcrlf & "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">" & vbcrlf & "<html xmlns=""http://www.w3.org/1999/xhtml"">" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"" />" & vbcrlf & "<title>"
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"" />" & vbcrlf & "<script language=""javascript"" src=""../inc/function.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""javascript"" src=""../sortcp/function.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"" src=""../contract/formatnumber.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"" src=""../inc/ptdmanger.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"" src=""cp_ajax2.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script src= ""../Script/xa_top.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """  language=JavaScript1.2></SCRIPT>" & vbcrlf & "<style>" & vbcrlf & "body {" & vbcrlf & "   margin-top: 0px;" & vbcrlf & "        background-color: #FFFFFF;" & vbcrlf & "      margin-left: 0px;" & vbcrlf & "       margin-right: 0px;" & vbcrlf & "      margin-bottom: 0px;" & vbcrlf & "     scrollbar-3dlight-color:#d0d0e8;" & vbcrlf & "    scrollbar-highlight-color:#fff;" & vbcrlf & " scrollbar-face-color:#f0f0ff;" & vbcrlf & "   scrollbar-arrow-color:#c0c0e8;" & vbcrlf & "  scrollbar-shadow-color:#d0d0e8;" & vbcrlf & " scrollbar-darkshadow-color:#fff;" & vbcrlf & "        scrollbar-base-color:#ffffff;" & vbcrlf & "   scrollbar-track-color:#fff;" & vbcrlf & "}" & vbcrlf & ".dataCell{" & vbcrlf & "   border-bottom:#CCC 1px solid;   " & vbcrlf & "        border-right:#CCC 1px solid;" & vbcrlf & "}" & vbcrlf & ".inputCell{overflow-x:hidden}" & vbcrlf & ".xunjia_pro_list td { overflow: hidden;}" & vbcrlf & "#cpB{margin-top:-1px}" & vbcrlf & ".IE5 #cpB{margin-top:0px}" & vbcrlf & " .tip_table{background:#fff;border:1px solid #c0ccdd}" & vbcrlf & " .tip_table td{border:0}" & vbcrlf & " .tip_table td table{border-collapse:collapse;}" & vbcrlf & " .tip_table td td{border:1px solid #c0ccdd}" & vbcrlf & " #content.tip_table tr.top td{border:1px solid #c0ccdd!important}" & vbcrlf & " .tip_table td table{background-color:#fff}" & vbcrlf & " #content.tip_table td tr.top{border-right:1px solid #c0ccdd}" & vbcrlf & " #content.tip_table td tr.top td{border-right:0!important;border-collapse:collapse}" & vbcrlf & "" & vbcrlf & " td.page2 {filter:noen}" & vbcrlf & "</style>" & vbcrlf & "<script>" & vbcrlf & "function chkForm(){" & vbcrlf & "        if($(""#act"").val()==""save""){" & vbcrlf & "                if($(""span[id^='trpx']"").find(""table"").size()==0){" & vbcrlf & "                  alert(""请添加询价记录！"");" & vbcrlf & "                        return false;" & vbcrlf & "           }else{" & vbcrlf & "                     var hasNoGys = 0;" & vbcrlf & "                       $(""span[id^='trpx']"").find(""input[name^='gys_']"").each(function(){" & vbcrlf & "                          if($(this).val()==""0""){" & vbcrlf & "                                   hasNoGys = 1;                                   " & vbcrlf & "                                        return false;" & vbcrlf & "                           }" & vbcrlf & "                               else{" & vbcrlf & "                                   return true;"& vbcrlf & "                               }" & vbcrlf & "                       });" & vbcrlf & "                     if(hasNoGys == 1){" & vbcrlf & "                              alert(""请给所有询价记录选择上供应商后再保存！"");" & vbcrlf & "                          return false;" & vbcrlf & "                   }else{" & vbcrlf & "                          return true;" & vbcrlf & "                    }" & vbcrlf & "               }" & vbcrlf & "       }else" & vbcrlf & "   {" & vbcrlf & "               return true;" & vbcrlf & "        }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function beforSubmit(act){" & vbcrlf & "    if(act == ""zsave""){" & vbcrlf & "               $('#act').val('zsave')" & vbcrlf & "          $(""input[name='xjid']"").attr(""min"",0);" & vbcrlf & "              $(""select[name='cateid_dj']"").attr(""min"",0);" & vbcrlf & "}else if(act == ""save""){" & vbcrlf & "          $('#act').val('save')" & vbcrlf & "           $(""input[name='xjid']"").attr(""min"",1);" & vbcrlf & "              $(""select[name='cateid_dj']"").attr(""min"",1);" & vbcrlf & "        }" & vbcrlf & "       if(Validator.Validate(document.getElementById('demo'),2) && chkForm()){document.getElementById('demo').submit()}" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "</head>" & vbcrlf & "<body onLoad=""txmFocus();"" onclick=""TexTxmFocus(event);""  ><!--oncontextmenu=self.event.returnValue=false-->"
	'Response.write Application("sys.info.jsver")
	curCate = session("personzbintel2007")
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power where ord="& curCate &" and sort1=21 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_13=0
	else
		open_21_13=rs1("qx_open")
	end if
	rs1.close
	sql1="select qx_open,qx_intro from power  where ord="& curCate &" and sort1=24 and sort2=21"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_24_21=0
	else
		open_24_21=rs1("qx_open")
	end if
	rs1.close
	dim ids,top,f
	top=0
	f=request("f")
	If request("ord")&""<>"" Then
		ord = deurl(request("ord"))
	end if
	conn.Execute("Delete  mxpx Where cateid="& curCate &" ")
	If ord&""="" Or ord&""="0" Then
		session("num_click2009")=0 : xj_ls=0
		conn.Execute("Delete xunjia where cateid="& curCate &" and del=7")
		conn.Execute("Delete xunjialist where  cateid="& curCate &" and del=7")
		set rs88 = conn.execute("EXEC erp_getdjbh 24,"& curCate )
		khid=rs88(0).value
		set rs88=nothing
		sqlStr="Insert Into xunjia(cateid,xjid,date7,del) values('"
		sqlStr=sqlStr &  curCate  & "','"
		sqlStr=sqlStr & khid & "','"
		sqlStr=sqlStr & date & "','"
		sqlStr=sqlStr & 7 & "')"
		Conn.execute(sqlStr)
		dim rd
		rd = GetIdentity("xunjia","id","cateid","")
		zdy1="" : zdy2="" : zdy3="" : zdy4="" : zdy5=0 : zdy6=0
		date1=date
		fromtype = request("fromtype")
		If request("fromid")&""<>"" Then
			fromid = deurl(request("fromid"))
		end if
		If fromtype&""="" Then fromtype = 0 Else fromtype = CLng(fromtype)
		If fromid&""="" Then fromid = 0 Else fromid = CLng(fromid)
		If fromtype>0 And fromid>0 Then
			conn.execute("exec [erp_xj_initByParent] "& curCate & ","& rd &","& fromtype &" , "& fromid &" ")
		end if
	else
		rd = ord : top = ord : xj_ls=1
		Set rs7 = conn.execute("select * from xunjia where id="& rd)
		If rs7.eof = False Then
			title = rs7("title") : khid = rs7("xjid") : date1 = rs7("date1") : cateid_dj = rs7("cateid_dj") : bizhong = rs7("bz")
			remark = rs7("remark") : zdy1=rs7("zdy1") : zdy2=rs7("zdy2") : zdy3=rs7("zdy3") : zdy4=rs7("zdy4") : zdy5=rs7("zdy5") : zdy6=rs7("zdy6")
		end if
		rs7.close
		Set rs7 = Nothing
	end if
	fromName = "" : fromTitle = "" : fromCate = 0 : fromCateName = ""
	Select Case fromtype&""
	Case "2"
	fromName = "预购"
	Set rs = conn.execute("select a.title, a.cateid, g.name from caigou_yg a left join gate g on a.cateid=g.ord where a.id="& fromid)
	If rs.eof = False Then
		fromTitle = rs("title") : fromCateName = rs("name") : fromCate = rs("cateid")
	end if
	rs.close
	set rs = nothing
	End Select
	If fromCate&"" = "" Then fromCate = 0
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="& curCate &" and sort1=4 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_4_14=0
		intro_4_14=0
	else
		open_4_14=rs1("qx_open")
		intro_4_14=rs1("qx_intro")
	end if
	Response.write "" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""10"">" & vbcrlf & "  <tr>" & vbcrlf & "  <td width=""215"" valign=""top"">" & vbcrlf & " "
	Dim returnUnit : returnUnit = True
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
			Response.write "<script>$(function(){__tree=$('#"&treeid&"')});</script>" & vbcrlf
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
		set rs=Nothing
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
		Response.write top
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
		Response.write GetVirPath()
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
		Response.write iif(treeType="TC","xstc","contract")
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
		Response.write iif(treeType="TC","xstc","contract")
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
	Response.write "<form name=""form"" method=""post""></form>" & vbcrlf & "  </td>" & vbcrlf & "    <td valign=""top""><form method=""POST"" class='pagefrm' action=""save2.asp?ord="
	Response.write rd
	Response.write "&xj_ls="
	Response.write xj_ls
	Response.write """ id=""demo"" onSubmit=""return Validator.Validate(this,2) && chkForm()"" name=""date"">" & vbcrlf & "      <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "<tr>" & vbcrlf & "    <td width=""100%"" valign=""top"">" & vbcrlf & "       <table width=""100%"" border=""0""cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "        " & vbcrlf & "                 <tr>" & vbcrlf & "            <td class=""place"">询价添加</td>" & vbcrlf & "            <td>"
	if open_21_13=1  then
		Response.write "<input type=""button"" name=""Submit3"" value=""添加产品""  onClick=""javascript:window.open('../product/add_list.asp?top="
		Response.write pwurl(top)
		Response.write "','newwproductin','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150')"" class=""anybutton""/>"
		'Response.write pwurl(top)
	end if
	Response.write "</td>" & vbcrlf & "            <td align=""right"">" & vbcrlf & "              <input type=""hidden"" name=""act"" id=""act""><input type=""hidden"" name=""fromtype"" value="""
	Response.write fromtype
	Response.write """>" & vbcrlf & "                          <input type=""hidden"" name=""fromid"" value="""
	Response.write fromid
	Response.write """>" & vbcrlf & "                          <input type=""button"" name=""Submit4222"" value=""暂存"" onclick=""beforSubmit('zsave');"" class=""page""/>                        " & vbcrlf & "                        <input type=""button"" name=""Submit4222"" value=""保存"" onclick=""beforSubmit('save');"" class=""page""/>" & vbcrlf & "              <input type=""reset"" value=""重填""  class=""page"" name=""B22"" />&nbsp;&nbsp;" & vbcrlf & "            </td>" & vbcrlf & "            <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "          </tr>" & vbcrlf & "      </table>" & vbcrlf & "" & vbcrlf & "     <table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & ""
	If fromtype&""<>"" And fromtype&""<>"0" Then
		Response.write "" & vbcrlf & "      <tr>" & vbcrlf & "        <td width=""80""><div align=""right"">询价来源：</div></td>" & vbcrlf & "        <td width=""200"" class=""gray"">"
		Response.write fromName
		Response.write "</td>" & vbcrlf & "        <td width=""80""><div align=""right"">来源单据：</div></td>" & vbcrlf & "        <td  width=""200"">"
		Response.write fromTitle
		Response.write "</td>" & vbcrlf & "        <td width=""80""><div align=""right"">单据人员：</div></td>" & vbcrlf & "        <td class=""gray"" width=""200"">"
		Response.write fromCateName
		Response.write "</td>" & vbcrlf & "     </tr>" & vbcrlf & ""
	end if
	Response.write "     " & vbcrlf & "         " & vbcrlf & "        <tr>" & vbcrlf & "        <td width=""80""><div align=""right"">询价主题：</div></td>" & vbcrlf & "        <td width=""200"" class=""gray""><input name=""title"" id=""title"" type=""text"" size=""20"" dataType=""Limit"" min=""1"" max=""100""  msg=""询价主题必须在1到100个字之间"" value="""
	Response.write title
	Response.write """>" & vbcrlf & "        <span class=""red""> *</span></td>" & vbcrlf & "        <td width=""80""><div align=""right"">询价编号：</div></td>" & vbcrlf & "        <td  width=""200""><input name=""xjid"" type=""text""  value="""
	Response.write khid
	Response.write """ size=""15"" " & vbcrlf & "                                dataType=""Limit"" min=""1"" max=""50""  msg=""长度必须在1至50个字之间""" & vbcrlf & "                                class='jquery-auto-bh' autobh-options='cfgId:24,recId:"
	Response.write khid
	Response.write rd
	Response.write ",autoCreate:false'" & vbcrlf & "                   >" & vbcrlf & "          <span class=""red"">*</span></td>" & vbcrlf & "        <td width=""80""><div align=""right"">询价日期：</div></td>" & vbcrlf & "        <td class=""gray"" width=""200""><INPUT name=ret size=10  id=""daysOfMonthPos"" value="""
	Response.write date1
	Response.write """ readonly onChange=""getBankAccountByBzId($('#bizhong'),'daysOfMonthPos')"" onMouseUp=""toggleDatePicker('daysOfMonth','date.ret')""   dataType=""Date"" format=""ymd"" required msg=""日期格式不正确"">" & vbcrlf & "          <span class=""red"">*</span>" & vbcrlf & "          <DIV id=daysOfMonth style=""POSITION: absolute""></DIV><input name=""id_show"" id=""id_show"" type=""hidden"" size=""1"" value=""""/><input name=""top"" type=""hidden"" size=""1"" value="""
	Response.write top
	Response.write """/></td>" & vbcrlf & "     </tr>" & vbcrlf & "     <tr>" & vbcrlf & "        <td width=""80""><div align=""right"">定价人员：</div></td>" & vbcrlf & "        <td width=""200"" class=""gray""><select name=""cateid_dj"" dataType=""Limit"" min=""1"" msg=""请选择定价人员"">" & vbcrlf & "                    <option value=''>请选择</option>" & vbcrlf & "                       "
	Set rs = conn.execute("select a.ord,a.name from gate a inner join power p on p.ord=a.ord and a.del=1 and p.sort1=24 and p.sort2=17 and (p.qx_open=3 or (p.qx_open=1 and charindex(',"& curCate &",',','+replace(isnull(cast(p.qx_intro as varchar(8000)),'-222'),' ','')+',')>0))")
	While rs.eof = False
		Response.write "" & vbcrlf & "                     <option value='"
		Response.write rs("ord")
		Response.write "' "
		If cateid_dj&"" = rs("ord")&"" Then Response.write "selected"
		Response.write ">"
		Response.write rs("name")
		Response.write "</option>" & vbcrlf & "                    "
		rs.movenext
	wend
	rs.close
	set rs = nothing
	Response.write "" & vbcrlf & "             </select>" & vbcrlf & "        <span class=""red""> *</span></td>" & vbcrlf & "        <td width=""80""><div align=""right"">币种：</div></td>" & vbcrlf & "        <td colspan=""3"">" & vbcrlf & "                    <select name=""bizhong"" id=""bizhong""  dataType=""Limit"" min=""1"" max=""50""  msg=""请选择币种"" onChange=""getBankAccountByBzId(this,'daysOfMonthPos')"">" & vbcrlf & ""
	Set rs = conn.execute("select top 1 bz from setbz ")
	If rs.eof = False Then
		bzOpen = rs("bz")
	end if
	rs.close
	set rs = nothing
	If bzOpen&"" = "" Then bzOpen = 0
	if bzOpen=0 then
		sql1="select id,sort1 from sortbz where id=14"
	else
		sql1="select id,sort1 from sortbz order by gate1 desc"
	end if
	set rs1=server.CreateObject("adodb.recordset")
	rs1.open sql1,conn,1,1
	if rs1.eof then
		Response.write "" & vbcrlf & "                              <option>还没有设置币种，不能添加询价</option>" & vbcrlf & ""
	else
		do until rs1.eof
			Response.write "" & vbcrlf & "                             <option value="""
			Response.write rs1("id")
			Response.write """ "
			If bizhong&"" = rs1("id")&"" Then Response.write "selected"
			Response.write ">"
			Response.write rs1("sort1")
			Response.write "</option>" & vbcrlf & ""
			rs1.movenext
		loop
		rs1.close
		set rs1=nothing
	end if
	If defbz&"" = "" Then defbz = 0
	Response.write "" & vbcrlf & "                     </select>&nbsp;<span class=""red"">*</span>" & vbcrlf & "           </td>" & vbcrlf & ""
	set rs=server.CreateObject("adodb.recordset")
	sql="select id,title,name,sort,gl from zdy where sort1=24 and set_open=1 order by gate1 asc "
	rs.open sql,conn,1,1
	num1=rs.RecordCount
	i_jm=0
	j_jm=1
	if rs.eof then
	else
		Response.write("<tr>")
		do until rs.eof
			if clng(i_jm/3)=i_jm/3 and i_jm<>0 then
				Response.write("</tr><tr>")
				j_jm=j_jm+1
				Response.write("</tr><tr>")
			end if
			zdy_name=rs("name")
			Response.write "" & vbcrlf & "         <td align=""right"">"
			Response.write rs("title")
			Response.write "：</td>" & vbcrlf & "              <td "
			if i_jm=num1-1  then
				Response.write "：</td>" & vbcrlf & "              <td "
				Response.write "colspan="""
				Response.write 1+2*(j_jm*3-num1)
				Response.write "colspan="""
				Response.write """"
			end if
			Response.write ">" & vbcrlf & "            "
			if rs("sort")=2 then
				Response.write "<input name="""
				Response.write zdy_name
				Response.write """ type=""text"" size=""15""  value="""
				execute "response.write "& zdy_name
				Response.write """>" & vbcrlf & "                "
			elseif rs("sort")=1 then
				Response.write "" & vbcrlf & "             <select name="""
				Response.write zdy_name
				Response.write """>" & vbcrlf & "             "
				set rs7=server.CreateObject("adodb.recordset")
				sql7="select ord,sort1 from sortonehy where gate2="&rs("gl")&" order by gate1 desc "
				rs7.open sql7,conn,1,1
				do until rs7.eof
					Response.write "" & vbcrlf & "             <option value="""
					Response.write rs7("ord")
					Response.write """ "
					execute "if "& zdy_name &"&""""="& rs7("ord") &"&"""" then Response.write ""selected"" "
					Response.write ">"
					Response.write rs7("sort1")
					Response.write "</option>" & vbcrlf & "             "
					rs7.movenext
				loop
				rs7.close
				set rs7=nothing
				Response.write "" & vbcrlf & "           </select>" & vbcrlf & "         "
			end if
			Response.write "             </td>" & vbcrlf & ""
			i_jm=i_jm+1
			Response.write "             </td>" & vbcrlf & ""
			rs.movenext
		loop
		Response.write("</tr>")
	end if
	rs.close
	set rs=nothing
	Response.write "" & vbcrlf & "" & vbcrlf & "    </table>" & vbcrlf & "" & vbcrlf & "<table width=""100%"" border=""0""  cellpadding=""3"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;margin-top:-1px;"" id=""content"">" & vbcrlf & "<tr class=""top""><td height=""27""><strong>询价清单</strong></td></tr>" & vbcrlf & "<tr><td class=""name"">" & vbcrlf & "       <div align=""left"" id='productlist' style=""width:600px;overflow-y:hidden;overflow-x:auto"">" & vbcrlf & "   "
	set rs=nothing
	Call getXjMxZdy()
	Response.write "" & vbcrlf & "     <table border=""0""  cellpadding=""3"" cellspacing=""0""  style=""width:"
	Response.write num1_kd
	Response.write "px;word-break:break-all;word-wrap:break-word;border-collapse:collapse;table-layout:fixed"">" & vbcrlf & "                <tr>" & vbcrlf & "            "
	Response.write num1_kd
	for i=0 to len_rsxjmx
		mxTitle = rs_xjmx(1,i) : sorce = rs_xjmx(3,i) : kd = rs_xjmx(4,i) : mxSet_open = rs_xjmx(5,i)
		strDisplay=""
		if (sorce=7 Or (sorce>=10 And sorce<=16)) and open_24_21=0 then
			If mxSet_open=0 Then strDisplay=" display:none;"
		else
			If mxSet_open=0 Then strDisplay=" display:none;"
		end if
		Response.write "" & vbcrlf & "               <td height=""26"" align=""center"" style="""
		Response.write strDisplay
		Response.write "width:"
		Response.write kd
		Response.write "px;"
		Response.write iif(i=0,"border-left:#CCC 1px solid;","")
		'Response.write "px;"
		Response.write "border-top:#CCC 1px solid;"" class=""dataCell inputCell""><strong>"
		'Response.write "px;"
		Response.write mxTitle
		Response.write "</strong></td>" & vbcrlf & "               "
	next
	Response.write "" & vbcrlf & "             </tr>" & vbcrlf & "           "
	If ord&""="" Then
		Response.write "" & vbcrlf & "             <tr>" & vbcrlf & "              <td height=""30"" colspan="""
		Response.write len_rsxjmx+1
		Response.write "" & vbcrlf & "             <tr>" & vbcrlf & "              <td height=""30"" colspan="""
		Response.write """ class=""dataCell inputCell"" style=""border-left:#CCC 1px solid;"">无产品明细！</td>" & vbcrlf & "            </tr>" & vbcrlf & "           "
		Response.write "" & vbcrlf & "             <tr>" & vbcrlf & "              <td height=""30"" colspan="""
	end if
	Response.write "" & vbcrlf & "     </table>" & vbcrlf & "        "
	j = 0
	If (ord&""="" Or ord&""="0") And (fromtype&""="" Or fromtype&""="0") Then
		Response.write "" & vbcrlf & "     <span id=""tr_px0"">        " & vbcrlf & "        </span>" & vbcrlf & " "
	ElseIf fromtype&""<>"" And fromtype&""<>"0" Then
		j = xjmx_edit(rd, 7)
	else
		j = xjmx_edit(ord, 1)
	end if
	for i=j+1 to num_cpmx_yl-1
		'j = xjmx_edit(ord, 1)
		list_ys=list_ys+"<span id='tr_px"&i&"'></span>"
		'j = xjmx_edit(ord, 1)
	next
	Response.write(""&list_ys&"")
	Response.write "" & vbcrlf & "     </div>" & vbcrlf & "</td></tr>" & vbcrlf & "</table>" & vbcrlf & "<span id='tttttest'  style='position:absolute;width:500px;'></span>" & vbcrlf & "<span id=""lsttcaigou""  style=""position:absolute; width:335px;""></span>" & vbcrlf & "<div id=""ttcaigou""  style=""position:absolute;width:490px;""></div>" & vbcrlf & ""
	action1="询价添加"
	call close_list(1)
	Response.write "" & vbcrlf & " </td>" & vbcrlf & "</tr>" & vbcrlf & "<tr>" & vbcrlf & "<td>" & vbcrlf & "  <table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"" style=""margin-top:-1px;"">" & vbcrlf & "       <tr>" & vbcrlf & "            <td width=""80""><div align=""right"">询价概要：</div></td>" & vbcrlf & "            <td><textarea name=""remark"" style=""display:none"" cols=""1"" rows=""1"">"
	if remark<>"" then Response.write remark
	Response.write "</textarea><IFRAME ID=""eWebEditor1"" SRC=""../edit/ewebeditor.asp?id=remark&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""300"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME></td>" & vbcrlf & "        </tr>" & vbcrlf & "    </table>" & vbcrlf & "</td>"& vbcrlf & "</tr>" & vbcrlf &    ""    & vbcrlf &    "<tr>" & vbcrlf &     "<td  class=""page"">" & vbcrlf &    "<table width=""100%"" border=""0"" align=""left"" >" & vbcrlf &   "<tr>" & vbcrlf &     "<td height=""30"" align=""center"">" & vbcrlf &       "<input type=""button"" name=""Submit4222""value=""暂存"" onclick=""beforSubmit('zsave');"" class=""page""/>" & vbcrlf & "        <input type=""button"" name=""Submit4222"" value=""保存"" onclick=""beforSubmit('save');"" class=""page""/>" & vbcrlf & "         <input type=""reset"" value=""重填""  class=""page"" name=""B222"" />" & vbcrlf & "      &nbsp; </td></tr>" & vbcrlf & "</table></form>" & vbcrlf & "      </td>" & vbcrlf & "  </tr>" & vbcrlf & " " & vbcrlf & "</table>" & vbcrlf & "</body>" & vbcrlf & "</html>"
%>
