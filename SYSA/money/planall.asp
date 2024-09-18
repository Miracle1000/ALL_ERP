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
		If ZBRuntime.SplitVersion <3173 Then Response.write "<br><br><br><br><center style='color:red;font-size:12px'>系统提示：运行库组件版本不正确。</center>" : Re.end
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
		'strW3 = Replace(","&Trim(strW3)&",",",0,",",")
		If right(strW3,1)="," Then strW3=left(strW3,Len(strW3)-1)
		'strW3 = Replace(","&Trim(strW3)&",",",0,",",")
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
	'list="and 1=0"
	
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
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=2"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_2=0
		intro_7_2=0
	else
		open_7_2=rs1("qx_open")
		intro_7_2=rs1("qx_intro")
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
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_3=0
		intro_7_3=0
	else
		open_7_3=rs1("qx_open")
		intro_7_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=6"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_6=0
		intro_7_6=0
	else
		open_7_6=rs1("qx_open")
		intro_7_6=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_7=0
		intro_7_7=0
	else
		open_7_7=rs1("qx_open")
		intro_7_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_8=0
		intro_7_8=0
	else
		open_7_8=rs1("qx_open")
		intro_7_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_10=0
		intro_7_10=0
	else
		open_7_10=rs1("qx_open")
		intro_7_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=11"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_11=0
		intro_7_11=0
	else
		open_7_11=rs1("qx_open")
		intro_7_11=rs1("qx_intro")
		If intro_7_11&""<>"" Then intro_7_11 = Replace(intro_7_11," ","") Else intro_7_11 = "-222"
		intro_7_11=rs1("qx_intro")
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
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=16"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_16=0
		intro_7_16=0
	else
		open_7_16=rs1("qx_open")
		intro_7_16=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=20"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_20=0
		intro_7_20=0
	else
		open_7_20=rs1("qx_open")
		intro_7_20=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=7 and sort2=21"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_7_21=0
		intro_7_21=0
	else
		open_7_21=rs1("qx_open")
		intro_7_21=rs1("qx_intro")
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
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_1=0
		intro_21_1=0
	else
		open_21_1=rs1("qx_open")
		intro_21_1=rs1("qx_intro")
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
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=9 and sort2=1"
	rs1.open sql1,conn,3,1
	if rs1.eof then
		open_9_1=0
		intro_9_1=0
	else
		open_9_1=rs1("qx_open")
		intro_9_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=9 and sort2=10"
	rs1.open sql1,conn,3,1
	if rs1.eof then
		open_9_10=0
		intro_9_10=0
	else
		open_9_10=rs1("qx_open")
		intro_9_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=Nothing
	if open_9_1=3 then
		list3= ""
	elseif open_9_1=1 then
		list3=" and p.cateid in ("&intro_9_1&") and p.cateid<>0 "
	else
		list3=" and 1=0 "
	end if
	if open_7_1=3 then
		list=""
		list1=""
		list2= ""
	elseif open_7_1=1 then
		list=" and cateid in ("&intro_7_1&") and cateid<>0 "
		list1=" and c.cateid in ("&intro_7_1&") and c.cateid<>0 "
		list2=" and p.cateid in ("&intro_7_1&") and p.cateid<>0 "
	else
		list=" and 1=0 "
		list1=" and 1=0 "
		list2=" and 1=0 "
	end if
	Str_Result3 = list1
	Str_Result=" where del=1 "&list&" "
	Str_Result2=" and del=1 "&list&" "
	Str_Result4 = list2
	Str_Result5 = list3
	
	type_tj_v = request.querystring("type_tj")
	If Len(type_tj_v & "") = 0 Then
		type_tj_v = request.form("type_tj")
		If Len(type_tj_v) > 0 then
			type_tj = type_tj_v
		end if
	end if
	A1=request("A1")
	A2=request("A2")
	A3=request("A3")
	B=request("B")
	C=Request("C")
	D=request("D")
	E=request("E")
	F=request("F")
	H=request("H")
	dateType = request("dateType")
	if dateType&""="" then dateType =0
	m1=request("ret")
	m2=request("ret2")
	if m1&""="" and m2&""=""   then
		m1 = dateadd("d",1,dateadd("yyyy",-1,date))
'if m1&""="" and m2&""=""   then
		m2 = date
	end if
	m3 = request("ret3")
	m4 = request("ret4")
	Str_Result = Str_Result3
	if request("type")="2" then
		m1=""
		m2=""
	end if
	if dateType="1" then
		if m1<>"" then Str_Result=Str_Result+"and CONVERT(varchar(10), c.date7, 120)>=CONVERT(varchar(10), cast('"&m1&"' as datetime), 120) "
'if dateType="1" then
		if m2<>"" then Str_Result=Str_Result+"and CONVERT(varchar(10), c.date7, 120)<=CONVERT(varchar(10),cast('"&m2&"' as datetime), 120) "
'if dateType="1" then
	else
		if m1<>"" then Str_Result=Str_Result+"and CONVERT(varchar(10), c.date3, 120)>=CONVERT(varchar(10),cast('"&m1&"' as datetime) , 120)"
'if dateType="1" then
		if m2<>"" then Str_Result=Str_Result+"and CONVERT(varchar(10), c.date3, 120)<=CONVERT(varchar(10),cast('"&m2&"' as datetime), 120) "
'if dateType="1" then
	end if
	if m3<>"" then Str_Result=Str_Result+"and CONVERT(varchar(10), c.date7, 120)>=CONVERT(varchar(10),cast('"&m3&"' as datetime), 120) "
'if dateType="1" then
	if m4<>"" then Str_Result=Str_Result+"and CONVERT(varchar(10), c.date7, 120)<=CONVERT(varchar(10),cast('"&m4&"' as datetime), 120) "
'if dateType="1" then
	W1=replace(request("W1")," ","")
	W2=replace(request("W2")," ","")
	W3=replace(request("W3")," ","")
	if W1="" then W1=0
	if W2="" then W2=0
	if W3="" then W3=0
	W3=getW3(W1,W2,W3)
	W3=getLimitedW3(W3,2,1,0,session("personzbintel2007"))
	W4=replace(W3,"0","")
	W4=replace(W4,",","")
	if W4<>"" Then
		tmp=split(getW1W2(W3),";")
		W1=tmp(0)
		W2=tmp(1)
		Str_Result=Str_Result+" and c.cateid in ("& W3 &") and c.cateid<>0 "
		'W2=tmp(1)
	end if
	if C<>"" then
		if B="khmc" then
			Str_Result=Str_Result+" and t.name like '%"&C&"%' "
'if B="khmc" then
		elseif B="khid" then
			Str_Result=Str_Result+" and t.khid like '%"&C&"%' "
'elseif B="khid" then
		elseif B="khord" then
			Str_Result=Str_Result+" and t.ord = '"&deurl(C)&"' "
'elseif B="khord" then
		elseif B="htzt" then
			Str_Result=Str_Result+" and c.title like '%"&C&"%'"
'elseif B="htzt" then
		elseif B="htid" then
			Str_Result=Str_Result+" and c.htid like '%"&C&"%'"
'elseif B="htid" then
		elseif B="xscate" then
			Str_Result=Str_Result+" and g.name like '%"&C&"%'"
'elseif B="xscate" then
		end if
	end if
	if request("khmc")<>"" then str_Result=str_Result+" and t.name like '%"& request("khmc") &"%' "
'elseif B="xscate" then
	if request("khbh")<>"" then str_Result=str_Result+" and t.khid like '%"& request("khbh") &"%' "
'elseif B="xscate" then
	if request("contractname")<>"" then str_Result=str_Result+" and c.title like '%"& request("contractname") &"%' "
'elseif B="xscate" then
	if request("htbh")<>"" then str_Result=str_Result+" and c.htid like '%"& request("htbh") &"%' "
'elseif B="xscate" then
	hkjz = request("hkjz")
	if hkjz<>"" and hkjz<>"10" then
		Str_Result=Str_Result+" and (case when ("& hkjz &"=1 and isnull(p.allmoney,0)=0) or ("& hkjz &"=2 and isnull(p.allmoney,0)<>0 ) then 1 else 0 end) = 1  "
'if hkjz<>"" and hkjz<>"10" then
	end if
	if Request("duemoney1")<>"" then str_Result=str_Result+" and c.money1>="&Request("duemoney1")&" "
'if hkjz<>"" and hkjz<>"10" then
	if Request("duemoney2")<>"" then str_Result=str_Result+" and c.money1<="&Request("duemoney2")&" "
'if hkjz<>"" and hkjz<>"10" then
	if Request("duemoney3")<>"" then str_Result=str_Result+" and isnull(p.allmoney,0)>="&Request("duemoney3")&" "
'if hkjz<>"" and hkjz<>"10" then
	if Request("duemoney4")<>"" then str_Result=str_Result+" and isnull(p.allmoney,0)<="&Request("duemoney4")&" "
'if hkjz<>"" and hkjz<>"10" then
	if Request("duemoney5")<>"" then str_Result=str_Result+" and isnull(p.ysmoney,0)>="&Request("duemoney5")&" "
'if hkjz<>"" and hkjz<>"10" then
	if Request("duemoney6")<>"" then str_Result=str_Result+" and isnull(p.ysmoney,0)<="&Request("duemoney6")&" "
'if hkjz<>"" and hkjz<>"10" then
	if Request("duemoney7")<>"" then str_Result=str_Result+" and c.money1-isnull(p.allmoney,0)>="&Request("duemoney7")&" "
'if hkjz<>"" and hkjz<>"10" then
	if Request("duemoney8")<>"" then str_Result=str_Result+" and c.money1-isnull(p.allmoney,0)<="&Request("duemoney8")&" "
'if hkjz<>"" and hkjz<>"10" then
	bz = replace(request("bz")&""," ","")
	if bz<>"" and bz<>"0" then str_Result=str_Result+" and charindex(','+cast(c.bz as varchar(10))+',',',"& bz &",')>0 "
	'bz = replace(request("bz")&""," ","")
	page_count=request.QueryString("page_count")
	if page_count="" Then page_count=10
	currpage=Request("currpage")
	if currpage<="0" or currpage="" Then currpage=1
	currpage=cdbl(currpage)
	UUrl=ReturnUrl()
	khname=conn.execute("select (case when isnull(name,'')='' then oldname else name end ) as name from setfields where gate1=1 ")(0)
	If khname="" Then khname="客户名称"
	px=request.QueryString("px")
	px_Result = ""
	if px="" then px=3
	select case px
	case 1: px_Result = " order by isnull(t.name,'') desc, c.date7 desc"
	case 2: px_Result = " order by isnull(t.name,'') asc, c.date7 asc"
	case 3: px_Result = " order by c.date3 desc, c.date7 desc"
	case 4: px_Result = " order by c.date3 asc ,c.date7 asc"
	case 5: px_Result = " order by c.title desc, c.date7 desc"
	case 6: px_Result = " order by c.title asc, c.date7 asc"
	case 7: px_Result = " order by c.money1 desc ,c.date7 desc"
	case 8: px_Result = " order by c.money1 asc, c.date7 asc"
	case 9: px_Result = " order by (case when isnull(p.allmoney,0)=0 then 1 else 2 end) desc, c.date7 desc"
	case 10: px_Result = " order by (case when isnull(p.allmoney,0)=0 then 1 else 2 end) asc, c.date7 asc"
	case 11: px_Result = " order by isnull(g.name,'') desc, c.date7 desc"
	case 12: px_Result = " order by isnull(g.name,'') asc ,c.date7 asc"
	end select
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
'end select
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/default/easyui.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """>" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/icon.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """>" & vbcrlf & "<script type=""text/javascript"" src=""../inc/jquery-1.4.2.min.js?ver="
	'Response.write Application("sys.info.jsver")
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script type=""text/javascript"" src=""../inc/jquery.easyui.min.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script type=""text/javascript"" src=""cp_ajax.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style>" & vbcrlf & "    .IE5 .top_btns input.anybutton {" & vbcrlf & "        height: 18px;" & vbcrlf & "        line-height: 16px;" & vbcrlf & "        margin-bottom: -0.5px;" & vbcrlf & "    }" & vbcrlf & "    select{vertical-align:middle;}" & vbcrlf & "    input[name=""C""],input[name=""ret""],input[name=""ret2""]{vertical-align:middle;height:20px;box-sizing:border-box;line-height:20px;}" & vbcrlf & "</style>" & vbcrlf & "</head>" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "    function showpx(divID) { //根据传递的参数确定显示的层" & vbcrlf & "        if (divID.style.display == """") {" & vbcrlf & "            divID.style.display = ""none""" & vbcrlf & "        } else {" & vbcrlf & "            divID.style.display = """"" & vbcrlf & "        }" & vbcrlf & "        divID.style.left = 374 + ""px"";/*原来的300不知道怎么来的，导致列表的排序规则显示的位置不对；*/" & vbcrlf & "        divID.style.top = 100;" & vbcrlf & "    }" & vbcrlf & "    function callServer2() {" & vbcrlf & "        document.getElementById('kh').style.display = 'none';" & vbcrlf & "        document.getElementById('ht1').style.display = '';" & vbcrlf & "        document.getElementById('ht1').style.position = 'relative';" & vbcrlf & "        document.getElementById('ht1').style.zIndex = 1;" & vbcrlf & "        var url = ""liebiao_UnPayback.asp?timestamp="" + new Date().getTime() + ""&date1="" + Math.round(Math.random() * 100) + ""&E="" + window.request_E + ""&F="" + window.request_F + ""&H2="" + window.request_H2;" & vbcrlf & "        xmlHttp.open(""GET"", url, false);" & vbcrlf & "        xmlHttp.onreadystatechange = function () {" & vbcrlf & "            updatePage2();" & vbcrlf & "        };" & vbcrlf & "        xmlHttp.send(null);" & vbcrlf & "    }" & vbcrlf & "" &vbcrlf & "    function updatePage2() {" & vbcrlf & "        var test7 = ""ht1""" & vbcrlf & "        if (xmlHttp.readyState < 4) {" & vbcrlf & "            ht1.innerHTML = ""loading..."";" & vbcrlf & "        }" & vbcrlf & "        if (xmlHttp.readyState == 4) {" & vbcrlf & "            var response = xmlHttp.responseText;" & vbcrlf & "            ht1.innerHTML = response;" & vbcrlf & "            xmlHttp.abort();" & vbcrlf & "        }" & vbcrlf & "    }" & vbcrlf & "" & vbcrlf & "    function mm(form) {" & vbcrlf & "        for (var i = 0; i < form.elements.length; i++) {" & vbcrlf & "     var e = form.elements[i];" & vbcrlf & "            if (e.name != 'chkall')" & vbcrlf & "                e.checked = document.getElementById(""chkall"").checked;" & vbcrlf & "        }" & vbcrlf & "    }" & vbcrlf & "" & vbcrlf & "    function BatchAdd() {" & vbcrlf & "        var ids = """";"& vbcrlf & "        $(""input[name='ids']:checked"").each(function () {" & vbcrlf & "            ids += (ids == """" ? """" : "","") + $(this).val();" & vbcrlf & "        });" & vbcrlf & "        if (ids == """") {" & vbcrlf & "            alert(""您没有选择任何合同，请选择后再批量生成！"");" & vbcrlf & "            return;" & vbcrlf & "        }" & vbcrlf & "        document.getElementById('BatchAddPayback').submit();" & vbcrlf & "    }" & vbcrlf & "</script>" & vbcrlf & "<body "
	if open_7_8=0 then
		Response.write " oncontextmenu=""return false"" onselectstart=""return false"" ondragstart=""return false"" onbeforecopy=""return false"" oncopy=document.selection.empty()"
	end if
	Response.write " onMouseOver=""window.status='none';return true;"">" & vbcrlf & "<table width=""100%"" border=""0"" align=""left"" cellpadding=""0"" cellspacing=""0"" bordercolor=""#E2E2E1"" bgcolor=""#FFFFFF"">" & vbcrlf & "<tr>" & vbcrlf & "<td width=""100%"" valign=""top"">" & vbcrlf & "  <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "        <tr>" & vbcrlf & "        <td class=""place"">待建立应收账款合同</td>" & vbcrlf & "        <td style='width:100px;'>&nbsp;<a class='px_btn' href=""javascript:void(0)"" onClick=""showpx(User);return false;"" class=""sortRule"">排序规则<img src=""../images/i10.gif"" width=""9"" height=""5"" border=""0""></a>" & vbcrlf & "            <div id=""User"" style=""position:absolute;width:100%; height:400;display:none;"">" & vbcrlf & "            <table width=""150"" height=""300""  border=""0"" cellpadding=""-2"" cellspacing=""-2"">" & vbcrlf & "              <tr>" & vbcrlf & "                <td height=""139"">" & vbcrlf & "                            <table width=""165"" height=""115"" bgcolor=""#ecf5ff"" border=""0"" >" & vbcrlf & "                          <tr valign=""middle""><td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""###"" onclick=""gotourl('px=1');"">按客户名称排序(降)</a></td></tr>" & vbcrlf & "                           <tr valign=""middle""><td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""###"" onclick=""gotourl('px=2');"">按客户名称排序(升)</a> </td></tr>" & vbcrlf & "                            <tr valign=""middle""><td height=""24""colspan=""2"">&nbsp;&nbsp;<a href=""###"" onclick=""gotourl('px=3');"">按签订日期排序(降)</a> </td></tr>" & vbcrlf & "                           <tr valign=""middle""><td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""###"" onclick=""gotourl('px=4');"">按签订日期排序(升)</a> </td></tr>" & vbcrlf & "                            <tr valign=""middle""><td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""###"" onclick=""gotourl"& "                            <tr valign=""middle""><td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""###"" onclick=""gotourl('px=7');"">按优惠后总额排序(降)</a> </td></tr>" & vbcrlf & "                          <tr valign=""middle""><td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""###"" onclick=""gotourl('px=8');"">按优惠后总额排序(升)</a> </td></tr>" & vbcrlf & "                           <tr valign=""middle""><td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""###"" onclick=""gotourl('px=9');"">按收款计划进展排序(降)</a> </td></tr>" & vbcrlf & "                        <tr valign=""middle""><td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""###"" onclick=""gotourl('px=10');"">按收款计划进展排序(升)</a> </td></tr>" & vbcrlf & "                          <tr valign=""middle""><td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""###"" onclick=""gotourl('px=11');"">按销售人员排序(降)</a> </td></tr>" & vbcrlf & "                           <tr valign=""middle""><td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""###"" onclick=""gotourl('px=12');"">按销售人员排序(升)</a> </td></tr>" & vbcrlf & "                            </table>" & vbcrlf & "                </td>" & vbcrlf & "              </tr>" & vbcrlf & "            </table>" & vbcrlf & "            </div>" & vbcrlf & "        </td>" & vbcrlf & "        <td>&nbsp;</td>" & vbcrlf & "                  <td align=""right"">" & vbcrlf & "                "
	if open_7_10=1 or open_7_10=3 then
		Response.write "<input type=""button"" name=""Submitdel2"" value=""导出"" onClick=""if (confirm('确认导出为EXCEL文档？')) { exportExcel({ debug: false, page: '../out/xls_dhk.asp' }) }"" class=""anybutton""/> "
	end if
	if open_7_7=1 or open_7_7=3 then
		Response.write "<input type=""button""  name=""print"" onclick=""window.print();"" value=""打印"" class=""anybutton""/>"
	end if
	Response.write " <select name=""select2""  onChange=""if(this.selectedIndex && this.selectedIndex!=0){gotourl(this.value);}"" >" & vbcrlf & "                  <option>-请选择-</option>" & vbcrlf & "               <option value=""page_count=10"" "
	if page_count=10 then
		Response.write "selected"
	end if
	Response.write ">每页显示10条</option>" & vbcrlf & "                   <option value=""page_count=20"" "
	if page_count=20 then
		Response.write "selected"
	end if
	Response.write ">每页显示20条</option>" & vbcrlf & "                   <option value=""page_count=30"" "
	if page_count=30 then
		Response.write "selected"
	end if
	Response.write ">每页显示30条</option>" & vbcrlf & "                   <option value=""page_count=50"" "
	if page_count=50 then
		Response.write "selected"
	end if
	Response.write ">每页显示50条</option>" & vbcrlf & "                   <option value=""page_count=100"" "
	if page_count=100 then
		Response.write "selected"
	end if
	Response.write ">每页显示100条</option>" & vbcrlf & "                  <option value=""page_count=200"" "
	if page_count=200 then
		Response.write "selected"
	end if
	Response.write ">每页显示200条</option>" & vbcrlf & "                  </select>" & vbcrlf & "                   </td>" & vbcrlf & "       <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "        </tr>" & vbcrlf & "         <tr>" & vbcrlf & "            <td class=""resetHeadBg"" colspan=""4"" height=""50"" class='top_btns' valign=""middle"" align=""right"">" & vbcrlf & "        <div id=""kh"" style='height:50px;line-height:50px;'>" & vbcrlf & "            <form action=""planall.asp"" method=""get""　id=""demo"" onsubmit=""return Validator.Validate(this,2)"" name=""date"" style=""margin:0"">" & vbcrlf & "            <input type=""hidden"" name=""px"" value="""
	Response.write px
	Response.write """>" & vbcrlf & "            <INPUT TYPE=""hidden"" NAME=""page_count"" VALUE="""
	Response.write page_count
	Response.write """>" & vbcrlf & "            <select name=""dateType"" id=""dateType""><option value=""0"" "
	if dateType="0" then
		Response.write "selected"
	end if
	Response.write ">签订日期</option><option value=""1"" "
	if dateType="1" then
		Response.write "selected"
	end if
	Response.write ">合同添加日期</option></select>" & vbcrlf & "            <input readonly=""true"" name=ret size=10  id=daysOfMonthPos  onmousedown=""datedlg.show()"" value="""
	Response.write m1
	Response.write """> - <INPUT name=ret2 readonly=""true"" size=10  id=daysOfMonth2Pos onmousedown=""datedlg.show()"" value="""
	'Response.write m1
	Response.write m2
	Response.write """>" & vbcrlf & "            <input type='hidden' name='type_tj' value='"
	Response.write type_tj_v
	Response.write "'>" & vbcrlf & "            <select name=""hkjz"">" & vbcrlf & "                 <option value=""10"" "
	if hkjz="10" then
		Response.write "selected"
	end if
	Response.write ">收款计划进展</option>" & vbcrlf & "                   <option value=""1"" "
	if hkjz="1" then
		Response.write "selected"
	end if
	Response.write ">未生成</option>" & vbcrlf & "                 <option value=""2"" "
	if hkjz="2" then
		Response.write "selected"
	end if
	Response.write ">部分生成</option>" & vbcrlf & "            </select>" & vbcrlf & "            <select name=""bz"">" & vbcrlf & "                <option value=""0"">币种</option>" & vbcrlf & "                    "
	dim selectstr : selectstr = ""
	dim bzset : bzset = sdk.getSqlValue("select top 1 bz from setbz",0)
	if bzset=0 then
		if bz="14" then selectstr = " selected "
		Response.write "<option value=""14"" "& selectstr &">人民币</option>"
	else
		set rs=conn.execute("select id,sort1 from sortbz order by gate1 desc")
		do while not rs.eof
			selectstr = ""
			if bz&""=rs("id").Value&"" then selectstr = " selected "
			Response.write "<option value="""&rs("id")&""" "& selectstr &">"&rs("sort1")&"</option>"
			rs.movenext
		loop
		rs.close
		set rs=nothing
	end if
	Response.write "" & vbcrlf & "            </select>" & vbcrlf & "" & vbcrlf & "            <select name=""B"">" & vbcrlf & "                 <option value=""khmc"" "
	if B="khmc" then
		Response.write "selected"
	end if
	Response.write ">"
	Response.write khname
	Response.write "</option>" & vbcrlf & "                <option value=""khid"" "
	if B="khid" then
		Response.write "selected"
	end if
	Response.write ">客户编号</option>" & vbcrlf & "               <option value=""htzt"" "
	if B="htzt" then
		Response.write "selected"
	end if
	Response.write ">合同主题</option>" & vbcrlf & "               <option value=""htid"" "
	if B="htid" then
		Response.write "selected"
	end if
	Response.write ">合同编号</option>" & vbcrlf & "                <option value=""xscate"" "
	if B="xscate" then
		Response.write "selected"
	end if
	Response.write ">销售人员</option>" & vbcrlf & "            </select>" & vbcrlf & "                      <input name=""C"" type=""text"" size=""10""  value="""
	if B <>"khord" then Response.write C end if
	Response.write """""/>" & vbcrlf & "                   <input type=""submit"" name=""Submit422"" value=""检索""  class=""anybutton""/>" & vbcrlf & "             </form>" & vbcrlf & "            <a href=""javascript:void(0)"" class=""AfterQuickSearch"" onClick=""callServer2()"" style='display:inline-block;*padding-bottom:3px;width:66px;'><img src=""../images/icon_title.gif"" width=""18"" height=""7"" border=""0""><u><font class=""advanSearch"">高级检索</font></u></a>&nbsp;" & vbcrlf & "        </div>" & vbcrlf & "         <form action=""planall.asp"" method=""get""　id=""demo"" onsubmit=""return Validator.Validate(this,2)"" name=""date"" style=""margin:0"">" & vbcrlf & "            <input type=""hidden"" name=""px"" value="""
	Response.write px
	Response.write """>" & vbcrlf & "            <INPUT TYPE=""hidden"" NAME=""page_count"" VALUE="""
	Response.write page_count
	Response.write """>" & vbcrlf & "            <div id=""ht1"" style=""border-top:1px solid #ccc;display:none""></div>" & vbcrlf & "         </form>" & vbcrlf & "         </td>" & vbcrlf & "           </tr>" & vbcrlf & "    </table>" & vbcrlf & "    <form action=""../../SYSN/view/finan/payback/BatchAddPayback.ashx?fromtype=0"" method=""post"" id=""BatchAddPayback"" name=""date2"" style=""margin:0"" target=""newpage"">" & vbcrlf & "    <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "     <tr height=""27"" class=""top"">" & vbcrlf & "        <td width=""3%""><div align=""center"">选择</div></td>" & vbcrlf & "        <td width=""8%""><div align=""center"">签订日期</div></td>" & vbcrlf & "        <td width=""12%""><div align=""center"">"
	Response.write khname
	Response.write "</div></td>" & vbcrlf & "        <td width=""12%""><div align=""center"">合同主题</div></td>" & vbcrlf & "        <td width=""10%""><div align=""center"">优惠后总额</div></td>" & vbcrlf & "        <td width=""10%""><div align=""center"">收款计划金额</div></td>" & vbcrlf & "        <td width=""10%""><div align=""center"">实收金额</div></td>" & vbcrlf & "        <td width=""10%""><div align=""center"">收款计划余额</div></td>" & vbcrlf & "        <td width=""15%""><div align=""center"">收款计划进展</div></td>" & vbcrlf & "        <td width=""10%""><div align=""center"">销售人员</div></td>" & vbcrlf & "       </tr>" & vbcrlf & "   "
	dim n,k,moneyjh
	money8_all = 0
	Rmb_Money_All8 = 0
	money1_all = 0
	Rmb_Money_All1 = 0
	money2_all = 0
	Rmb_Money_All2 = 0
	money5_all = 0
	Rmb_Money_All5 = 0
	sql="select sum(c.money1-isnull(dkh.thMoney3,0)) as money8_all,sum((c.money1-isnull(dkh.thMoney3,0)) * isnull(h.hl,1)) as Rmb_Money_All8,"&_
	"sum(isnull(p.allmoney,0)+isnull(th.thmoney,0)) as money1_all,sum((isnull(p.allmoney,0)+isnull(th.thmoney,0))* isnull(h.hl,1)) as Rmb_Money_All1, "&_
	"sum(isnull(p.ysmoney,0)) as money2_all ,sum(isnull(p.ysmoney,0)* isnull(h.hl,1)) as Rmb_Money_All2 , "&_
	"sum(c.money1* ISNULL(h.hl, 1)-isnull(dkh.thMoney3,0)* ISNULL(h.hl, 1)) - isnull(sum(isnull(p.allmoney,0)* ISNULL(h.hl, 1) +isnull(th.thmoney,0)* ISNULL(h.hl, 1)),0) as money5_all,sum((c.money1-isnull(dkh.thMoney3,0))* isnull(h.hl,1)) - isnull(sum((isnull(p.allmoney,0) +isnull(th.thmoney, 0))* isnull(h.hl,1)),0) as Rmb_Money_All5 "&_
	" from contract c WITH(NOLOCK) "&_
	" inner join sortbz b WITH(NOLOCK) on b.id = c.bz " &_
	" left join hl h WITH(NOLOCK) on h.bz=c.bz and h.date1 = c.date3"&_
	" left join gate g WITH(NOLOCK) on g.ord= c.cateid "&_
	" left join tel t WITH(NOLOCK) on t.del=1 and t.ord=c.company "&_
	" left join ("&_
	"       select contract, isnull(sum(money1),0) as allmoney, sum(case when complete=3 then money1 else 0 end) as ysmoney "&_
	"       from payback WITH(NOLOCK) "&_
	"       where del=1 group by contract "&_
	"   )  p on p.contract = c.ord "&_
	" left join ("&_
	"       select a.contract, isnull(sum(pl.money1),0) as thmoney "&_
	"       from payback a WITH(NOLOCK) "&_
	"       inner join paybacklist pl on a.ord = pl.payback and pl.contractlist<0 "&_
	"       where a.del=1 group by a.contract "&_
	"   )  th on th.contract = c.ord "&_
	"  left join(                                                                                                              "&_
	"       select sa.contract, sum(sd.money3) thMoney3                                                                               "&_
	"          from contractthlist sa WITH(NOLOCK)                                                                                 "&_
	"          inner join (                                                                                                        "&_
	"              SELECT SUM(money2) AS money2, SUM(CASE WHEN thtype='GOODS' then money1 ELSE 0 end) AS money3 , contractthlist   "&_
	"              FROM contractthListDetail WITH(NOLOCK) WHERE del = 1                                                            "&_
	"              GROUP BY contractthlist                                                                                         "&_
	"          ) sd on sd.contractthlist = sa.id                                                                                   "&_
	"          inner join contractth sb WITH(NOLOCK) on sb.ord=sa.caigou and sb.del=1 and sb.sp<>-1                                "&_
	"          group by sa.contract                                                                                                "&_
	"       ) dkh on dkh.contract = c.ord                                                                                             "&_
	" where isnull(c.importPayback,0)<>1 and c.del=1 and isnull(c.isTerminated,0)<>1 AND c.[status] IN ( -1, 1 ) and c.money1-isnull(dkh.thMoney3,0) >isnull(p.allmoney,0)+ isnull(th.thmoney,0) "& Str_Result
	set rs = conn.execute(sql)
	if rs.eof=false then
		money8_all      = rs("money8_all")
		Rmb_Money_All8  = rs("Rmb_Money_All8")
		money1_all      = rs("money1_all")
		Rmb_Money_All1  = rs("Rmb_Money_All1")
		money2_all      = rs("money2_all")
		Rmb_Money_All2  = rs("Rmb_Money_All2")
		money5_all      = rs("money5_all")
		Rmb_Money_All5  = rs("Rmb_Money_All5")
	end if
	rs.close
	n=0
	k=""
	moneyjh=0
	has = false
	currbzName = sdk.getSqlValue("select top 1 intro from sortbz where id=14","RMB")
	summoney8 = 0
	Rmb_SumMoney8 = 0
	summoney1 = 0
	Rmb_SumMoney1 = 0
	summoney2 = 0
	Rmb_SumMoney2 = 0
	summoney5 = 0
	Rmb_SumMoney5 = 0
	set rs=server.CreateObject("adodb.recordset")
	sql="select c.ord,c.date3,isnull(c.cateid,0) as cateid,isnull(g.name,'') as cateidname,c.title,c.company,c.bz,isnull(t.name,'') as companyname,"&_
	"   isnull(t.cateid,0) as cateid_kh,ISNULL(t.share,'-222') as khshare,t.sort3,ISNULL(c.share,'-222') as htshare ,b.intro as bzname," &_
	"   c.money1,isnull(p.allmoney,0) as allmoney,isnull(p.ysmoney,0) as ysmoney , isnull(th.thmoney,0) thmoney , isnull(h.hl,1) hl,c.htid ,isnull(dkh.thMoney3,0) as money3"&_
	" from contract c WITH(NOLOCK) "&_
	" inner join sortbz b WITH(NOLOCK) on b.id = c.bz " &_
	" left join hl h WITH(NOLOCK) on h.bz=c.bz and h.date1 = c.date3"&_
	" left join gate g WITH(NOLOCK) on g.ord= c.cateid "&_
	" left join tel t WITH(NOLOCK) on t.del=1 and t.ord=c.company "&_
	" left join ("&_
	"       select contract, isnull(sum(money1),0) as allmoney, sum(case when complete=3 then money1 else 0 end) as ysmoney "&_
	"       from payback WITH(NOLOCK) "&_
	"       where del=1 group by contract "&_
	"   )  p on p.contract = c.ord "&_
	" left join ("&_
	"       select a.contract, isnull(sum(pl.money1),0) as thmoney "&_
	"       from payback a WITH(NOLOCK) "&_
	"       inner join paybacklist pl on a.ord = pl.payback and pl.contractlist<0 "&_
	"       where a.del=1 group by a.contract "&_
	"   )  th on th.contract = c.ord "&_
	"  left join(                                                                                                              "&_
	"       select sa.contract, sum(sd.money3) thMoney3                                                                               "&_
	"          from contractthlist sa WITH(NOLOCK)                                                                                 "&_
	"          inner join (                                                                                                        "&_
	"              SELECT SUM(money2) AS money2, SUM(CASE WHEN thtype='GOODS' then money1 ELSE 0 end) AS money3 , contractthlist   "&_
	"              FROM contractthListDetail WITH(NOLOCK) WHERE del = 1                                                            "&_
	"              GROUP BY contractthlist                                                                                         "&_
	"          ) sd on sd.contractthlist = sa.id                                                                                   "&_
	"          inner join contractth sb WITH(NOLOCK) on sb.ord=sa.caigou and sb.del=1 and sb.sp<>-1                                "&_
	"          group by sa.contract                                                                                                "&_
	"       ) dkh on dkh.contract = c.ord                                                                                             "&_
	" where isnull(c.importPayback,0)<>1 and c.del=1 and isnull(c.status,-1) in (-1,1) and isnull(c.isTerminated,0)<>1 and c.money1-isnull(dkh.thMoney3,0)>isnull(p.allmoney,0)+ isnull(th.thmoney,0) "& Str_Result & px_Result
	rs.open sql,conn,1,1
	if rs.RecordCount<=0 then
		Response.write "<table><tr><td>没有信息!</td></tr></table>"
	else
		has = true
		rs.PageSize=page_count
		PageCount=clng(rs.PageCount)
		if CurrPage<=0 or CurrPage="" Then CurrPage=1
		if CurrPage>=PageCount Then CurrPage=PageCount
		rs.absolutePage = CurrPage
		do until rs.eof
			contract=rs("ord")
			contracttitle = rs("title")
			cateid=rs("cateid")
			cateidname = rs("cateidname")
			company = rs("company")
			cateid_kh =rs("cateid_kh")
			companyname = rs("companyname")
			sortbz=rs("bzname")
			money3 =  CDbl(rs("money3"))
			money1 = CDbl(rs("money1"))-money3
			money3 =  CDbl(rs("money3"))
			thmoney = cdbl(rs("thmoney"))
			allmoney = CDbl(rs("allmoney")) + thmoney
			thmoney = cdbl(rs("thmoney"))
			ysmoney = CDbl(rs("ysmoney"))
			khshare = rs("khshare")
			htshare = rs("htshare")
			sort3 = rs("sort3")
			date3 = rs("date3").value
			hl = rs("hl").value
			leftMoney = cdbl(money1) - cdbl(allmoney)
'hl = rs("hl").value
			summoney8 =  cdbl(summoney8) + cdbl(money1)
'hl = rs("hl").value
			Rmb_SumMoney8 = cdbl(Rmb_SumMoney8) + cdbl(money1)* cdbl(hl)
'hl = rs("hl").value
			summoney1 = cdbl(summoney1) +cdbl(allmoney)
'hl = rs("hl").value
			Rmb_SumMoney1 = cdbl(Rmb_SumMoney1) + cdbl(allmoney)* cdbl(hl)
'hl = rs("hl").value
			summoney2 =  cdbl(summoney2) +cdbl(ysmoney)
'hl = rs("hl").value
			Rmb_SumMoney2 = cdbl(Rmb_SumMoney2) + cdbl(ysmoney)* cdbl(hl)
'hl = rs("hl").value
			summoney5 =  cdbl(summoney5) +cdbl(leftMoney)
'hl = rs("hl").value
			Rmb_SumMoney5 = cdbl(Rmb_SumMoney5) + cdbl(leftMoney)* cdbl(hl)
'hl = rs("hl").value
			Response.write " " & vbcrlf & "                <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                       <td align=""center""><span class=""red"">"
			if open_7_3=3 or (CheckPurview(intro_7_3,trim(cateid))=True  And cateid<>0  ) then
				Response.write "<input name=""ids"" type=""checkbox"" id=""ids"" value="""
				Response.write contract
				Response.write """>"
			end if
			Response.write "</span></td>" & vbcrlf & "                <td><div align=""center"">"
			Response.write date3
			Response.write "</div></td>" & vbcrlf & "            <td align=""center"" height=""24""><div align=""left"">" & vbcrlf & "                "
			If Len(companyname)=0 Then
				Response.write "客户已被删除"
			else
				If sort3="2" Then
					if open_26_1=3 or (open_26_1=1 and CheckPurview(intro_26_1,trim(cateid_kh))=True And cateid_kh<>0 ) then
						if open_26_14=3 or (open_26_14=1 and CheckPurview(intro_26_14,trim(cateid_kh))=True And cateid_kh<>0 ) then
							Response.write "" & vbcrlf & "                                             <a href=""#"" onclick=""javascript:window.open('../work2/content.asp?ord="
							Response.write pwurl(company)
							Response.write "','newwin','width=' + 800 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title=""点击查看客户详情"">"
							'Response.write pwurl(company)
							Response.write companyname
							Response.write "</a>" & vbcrlf & "                                 "
						else
							Response.write companyname
						end if
					end if
				else
					if open_1_1=3 or (open_1_1=1 and CheckPurview(intro_1_1,trim(cateid_kh))=True And cateid_kh<>0 ) Or InStr(1,","&khshare&",", ","&session("personzbintel2007")&",",1) > 0 Or khshare = "1" then
						if open_1_14=3 or (open_1_14=1 and CheckPurview(intro_1_14,trim(cateid_kh))=True And cateid_kh<>0 ) then
							Response.write "" & vbcrlf & "                                             <a href=""#"" onclick=""javascript:window.open('../work/content.asp?ord="
							Response.write pwurl(company)
							Response.write "','newwin','width=' + 800 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title=""点击查看客户详情"">"
							Response.write pwurl(company)
							Response.write companyname
							Response.write "</a>" & vbcrlf & "                                 "
						else
							Response.write companyname
						end if
					end if
				end if
			end if
			Response.write "" & vbcrlf & "                </div></td>" & vbcrlf & "              <td ><div align=""left"">" & vbcrlf & "                       "
			if open_5_1=3 or (open_5_1=1 and CheckPurview(intro_5_1,trim(cateid))=True And cateid<>0) Or InStr(1,","&htshare&",", ","&session("personzbintel2007")&",",1) > 0 Or htshare = "1" Then
				if open_5_14=3 or (open_5_14=1 and CheckPurview(intro_5_14,trim(cateid))=True  And cateid<>0) then
					Response.write "" & vbcrlf & "                                     <a href=""#"" onclick=""javascript:window.open('../../SYSN/view/sales/contract/ContractDetails.ashx?ord="
					Response.write pwurl(contract)
					Response.write "&view=details','newwinht','width=' + 1000 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title=""点击查看合同详情"">"
					'Response.write pwurl(contract)
					Response.write contracttitle
					Response.write "</a>" & vbcrlf & "                             "
				else
					Response.write contracttitle
				end if
			end if
			Response.write "" & vbcrlf & "                     </div></td>" & vbcrlf & "             <td height=""27"" ><div align=""right"">"
			Response.write sortbz
			Response.write Formatnumber(money1,num_dot_xs,-1)
			'Response.write sortbz
			Response.write "</div></td>" & vbcrlf & "              <td><div align=""right"">" & vbcrlf & "                "
			if open_7_1= 3 or open_7_1= 1 then
				Response.write "" & vbcrlf & "                    <a href=""#"" onclick=""javascript:window.open('../money/planall2.asp?B=htid&C="
				Response.write rs("htid")
				Response.write "&ret="
				Response.write date3
				Response.write "','newwinplan','width=' + 1000 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title=""点击查看收款计划列表"">"
				'Response.write date3
				Response.write sortbz
				Response.write Formatnumber(allmoney,num_dot_xs,-1)
				'Response.write sortbz
				Response.write "</a>" & vbcrlf & "                "
			else
				Response.write sortbz
				Response.write Formatnumber(allmoney,num_dot_xs,-1)
				'Response.write sortbz
			end if
			Response.write "" & vbcrlf & "                     </div></td>" & vbcrlf & "                 <td><div align=""right"">" & vbcrlf & "                   "
			if open_7_1= 3 or open_7_1= 1 then
				Response.write "" & vbcrlf & "                        <a href=""#"" onclick=""javascript:window.open('../money/planall2.asp?B=htid&C="
				Response.write rs("htid")
				Response.write "&ret="
				Response.write date3
				Response.write "&A=3','newwinplan','width=' + 1000 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title=""点击查看收款列表"">"
				'Response.write date3
				Response.write sortbz
				Response.write Formatnumber(ysmoney,num_dot_xs,-1)
				'Response.write sortbz
				Response.write "</a>" & vbcrlf & "                   "
			else
				Response.write sortbz
				Response.write Formatnumber(ysmoney,num_dot_xs,-1)
				'Response.write sortbz
			end if
			Response.write "" & vbcrlf & "                       </div></td>" & vbcrlf & "            <td><div align=""right"">"
			Response.write sortbz
			Response.write Formatnumber(leftMoney,num_dot_xs,-1)
			Response.write sortbz
			Response.write "</div></td>" & vbcrlf & "                <td><div align=""center""><font class=""gray"">"
			if cdbl(allmoney)=0 then
				Response.write "未生成"
			elseif cdbl(allmoney)<cdbl(money1) then
				Response.write "部分生成"
			end if
			Response.write "</font>"
			if cdbl(thmoney)>0 then
				Response.write "<font color=""red"" title=""退货金额"
				Response.write Formatnumber(thmoney,num_dot_xs,-1)
				Response.write "<font color=""red"" title=""退货金额"
				Response.write """>(有退货)</font>"
			end if
			if open_7_13=3 or (open_7_13=1 and CheckPurview(intro_7_13,trim(cateid))=True And cateid<>0) then
				Response.write "<img src=""../images/jiantou.gif"" width=""17"" height=""12""><a href=""#"" onclick=""javascript:window.open('../money/addht.asp?ord="
				Response.write pwurl(contract)
				Response.write "','plancor5','width=' + 800 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=250');return false;""><font class=""blue2"">生成收款计划</font></a>"
				'Response.write pwurl(contract)
			end if
			Response.write "</div></td>" & vbcrlf & "               <td><div align=""center"">"
			Response.write cateidname
			Response.write "</div></td>" & vbcrlf & "               </tr>" & vbcrlf & "                   "
			n=n+1
			'Response.write "</div></td>" & vbcrlf & "               </tr>" & vbcrlf & "                   "
			rs.movenext
			if rs.eof or n>=rs.pagesize then exit do
		loop
		Response.write "      " & vbcrlf & "        <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "            <td class=""name"" height=""27""></td>" & vbcrlf & "            <td class=""name"" height=""27""></td>" & vbcrlf & "            <td class=""name"" height=""27""></td>" & vbcrlf &     "     <td class=""name"" height=""27""><div align=""right"">本页合计：</div></td>" & vbcrlf &   "       <td ><div align=""right""><span class=""red"">"
		Response.write Formatnumber(summoney8,num_dot_xs,-1)
		Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		Response.write Formatnumber(summoney1,num_dot_xs,-1)
		'Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		Response.write Formatnumber(summoney2,num_dot_xs,-1)
		'Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		Response.write Formatnumber(summoney5,num_dot_xs,-1)
		'Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		Response.write "</span></div></td>" & vbcrlf & "            <td class=""name"" height=""27""></td>" & vbcrlf & "            <td class=""name"" height=""27""></td>" & vbcrlf & "                </tr>" & vbcrlf & "        <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf &        "     <td class=""name"" height=""27""></td> "& vbcrlf &       "      <td class=""name"" height=""27""></td>" & vbcrlf &         "    <td class=""name"" height=""27""></td>" & vbcrlf &     "      <td class=""name"" height=""27""><div align=""right"">&nbsp;</div></td>" & "         <td ><div align=""right""><span class=""red"">"
		Response.write currbzName
		Response.write Formatnumber(Rmb_SumMoney8,num_dot_xs,-1)
		'Response.write currbzName
		Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		'Response.write currbzName
		Response.write Formatnumber(Rmb_SumMoney1,num_dot_xs,-1)
		'Response.write currbzName
		Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		'Response.write currbzName
		Response.write Formatnumber(Rmb_SumMoney2,num_dot_xs,-1)
		'Response.write currbzName
		Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		'Response.write currbzName
		Response.write Formatnumber(Rmb_SumMoney5,num_dot_xs,-1)
		'Response.write currbzName
		Response.write "</span></div></td>" & vbcrlf & "            <td class=""name"" height=""27""></td>" & vbcrlf & "            <td class=""name"" height=""27""></td>" & vbcrlf & "                </tr>" & vbcrlf & "        <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'""> "& vbcrlf &   "          <td class=""name"" height=""27""></td>" & vbcrlf &          "   <td class=""name"" height=""27""></td> "& vbcrlf &     "        <td class=""name"" height=""27""></td>" & vbcrlf &    "       <td class=""name"" height=""27""><div align=""right"">所有合计：</div></td> "& vbcrlf &"          <td ><div align=""right""><span class=""red"">"
		Response.write Formatnumber(money8_all,num_dot_xs,-1)
'"          <td ><div align=""right""><span class=""red"">"
		Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		Response.write Formatnumber(money1_all,num_dot_xs,-1)
		'Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		Response.write Formatnumber(money2_all,num_dot_xs,-1)
		'Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		Response.write Formatnumber(money5_all,num_dot_xs,-1)
		'Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		Response.write "</span></div></td>" & vbcrlf & "            <td class=""name"" height=""27""></td>" & vbcrlf & "            <td class=""name"" height=""27""></td>" & vbcrlf & "                </tr> " & vbcrlf & "        <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "            <td class=""name"" height=""27""></td>" & vbcrlf & "            <td class=""name"" height=""27""></td>" & vbcrlf & "            <td class=""name"" height=""27""></td>" & vbcrlf & "         <td class=""name"" height=""27""><div align=""right"">&nbsp;</div></td>" & vbcrlf& "                <td ><div align=""right""><span class=""red"">"
		Response.write currbzName
		Response.write Formatnumber(Rmb_Money_All8,num_dot_xs,-1)
		'Response.write currbzName
		Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		'Response.write currbzName
		Response.write Formatnumber(Rmb_Money_All1,num_dot_xs,-1)
		'Response.write currbzName
		Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		'Response.write currbzName
		Response.write Formatnumber(Rmb_Money_All2,num_dot_xs,-1)
		'Response.write currbzName
		Response.write "</span></div></td>" & vbcrlf & "            <td ><div align=""right""><span class=""red"">"
		'Response.write currbzName
		Response.write Formatnumber(Rmb_Money_All5,num_dot_xs,-1)
		'Response.write currbzName
		Response.write "</span></div></td>" & vbcrlf & "            <td class=""name"" height=""27""></td>" & vbcrlf & "            <td class=""name"" height=""27""></td>" & vbcrlf & "                </tr> " & vbcrlf & "            "
		m=n
		pagesize = rs.pagesize
		pagecount = rs.pagecount
		RecordCount = rs.RecordCount
	end if
	rs.close
	set rs=nothing
	if has then
		Response.write "" & vbcrlf & "        </table>" & vbcrlf & "        </form>" & vbcrlf & "        </td>" & vbcrlf & "        </tr>" & vbcrlf & "        <tr>" & vbcrlf & "     <td  class=""page"">" & vbcrlf & "        <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "        <tr>" & vbcrlf & "   <td width=""5%"" height=""30""><div align=""center"">全选<input name=""chkall"" type=""checkbox"" id=""chkall"" value=""all"" onclick=""mm($('#BatchAddPayback')[0])"" /></div></td>" & vbcrlf & "            <td>"
		if open_7_13=3 or open_7_13=1 then
			Response.write "<input type=""submit"" name=""Submit422"" value=""批量生成收款计划""  onclick=""BatchAdd()"" class=""anybutton2""/>"
		end if
		Response.write "</td>" & vbcrlf & "            <td width=""79%""><div align=""right"">" & vbcrlf & "            <span class=""black"">"
		Response.write RecordCount
		Response.write "个 | "
		Response.write currpage
		Response.write "/"
		Response.write pagecount
		Response.write "页 | &nbsp;"
		Response.write pagesize
		Response.write "条信息/页</span>&nbsp;&nbsp;" & vbcrlf & "            <input name=""currpage"" id=""currpage"" type=""text"" onkeyup=""value=value.replace(/[^\d]/g,'')""  size=""3"">" & vbcrlf & "            <input type=""submit"" name=""Submit422"" value=""跳转"" onClick=""gotourl('currPage=' + document.getElementById('currpage').value);""  class=""anybutton2""/>" & vbcrlf & "            "
		if currpage=1 then
			Response.write "" & vbcrlf & "            <input type=""button"" name=""Submit4"" value=""首页""  class=""page""/> <input type=""button"" name=""Submit42"" value=""上一页""  class=""page""/>" & vbcrlf & "            "
		else
			Response.write "" & vbcrlf & "            <input type=""button"" name=""Submit4"" value=""首页""   class=""page"" onClick=""gotourl('currPage=1');""/> <input type=""button"" name=""Submit42"" value=""上一页""  onClick=""gotourl('currPage="
			Response.write  currpage -1
			Response.write "');"" class=""page""/>" & vbcrlf & "            "
		end if
		if currpage=pagecount then
			Response.write "" & vbcrlf & "            <input type=""button"" name=""Submit43"" value=""下一页"" class=""page""/> <input type=""button"" name=""Submit44"" value=""尾页""  class=""page""/>" & vbcrlf & "            "
		else
			Response.write "" & vbcrlf & "            <input type=""button"" name=""Submit43"" value=""下一页"" onClick=""gotourl('currPage="
			Response.write  currpage + 1
			Response.write "');"" class=""page""/> <input type=""button"" name=""Submit43"" value=""尾页""  onClick=""gotourl('currPage="
			Response.write  PageCount
			Response.write "');"" class=""page""/>" & vbcrlf & "            "
		end if
		Response.write "" & vbcrlf & "            </div></td>" & vbcrlf & "        </tr>" & vbcrlf & "        <tr><td height=""38"" colspan=""3""><div align=""right""><p>&nbsp;</p></div></td></tr>" & vbcrlf & "        </table>" & vbcrlf & "        <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "            <tr><td width=""100%"" height=""10""><img src=""../image/pixel.gif"" width=""1"" height=""1""></td></tr>" & vbcrlf & "            <tr><td height=""10"">&nbsp;</td></tr>" & vbcrlf & "            "
	end if
	Response.write "" & vbcrlf & "</table>" & vbcrlf & "</td>" & vbcrlf & "</tr>" & vbcrlf & "</table>" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	action1="待建立应收账款合同"
	call close_list(1)
	
%>
