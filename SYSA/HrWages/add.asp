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
		set rs = cnn.execute("select uid from UniqueLogin where  abs(datediff(n, LastActiveTime, getdate()))<15 and status='online' and sessionId='" &  replace(sessionid,"'","") & "'")
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
	
	Response.write vbcrlf
	
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
	
	msgid = request("msgid")
	If msgid &"" <> "" Then
		response.clear
		Response.CharSet = "UTF-8"
		response.clear
		Select Case msgid
		Case "getImportBonus" : Call getImportBonus()
		Case "getImportWages" :Call getImportWages()
		End Select
		call db_close : Response.end
	end if
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_1=0
		intro_10_1=0
	else
		open_10_1=rs1("qx_open")
		intro_10_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_14=0
		intro_10_14=0
	else
		open_10_14=rs1("qx_open")
		intro_10_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_3=0
		intro_10_3=0
	else
		open_10_3=rs1("qx_open")
		intro_10_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_7=0
		intro_10_7=0
	else
		open_10_7=rs1("qx_open")
		intro_10_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_8=0
		intro_10_8=0
	else
		open_10_8=rs1("qx_open")
		intro_10_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_10=0
		intro_10_10=0
	else
		open_10_10=rs1("qx_open")
		intro_10_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_13=0
		intro_10_13 = 0
	else
		open_10_13=rs1("qx_open")
		intro_10_13 = rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=10 and sort2=16"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_10_16=0
		intro_10_16=0
	else
		open_10_16=rs1("qx_open")
		intro_10_16=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	if open_10_1=3 then
		list=""
	elseif open_10_1=1 then
		list="and ord in ("&intro_10_1&")"
		listgz="and id in ("&intro_10_1&")"
	else
		list="and ord=0"
		listgz="and id=0"
	end if
	Str_Result="where del=1 "&list&""
	Str_Result2="and del=1 "&listgz&""
	Str_Result3="and del=1 "&listgz&""
	
	dim open_bz
	set rs=server.CreateObject("adodb.recordset")
	sql="select top 1 bz from setbz "
	rs.open sql,conn,1,1
	if not rs.eof then
		open_bz=rs("bz")
	end if
	rs.close
	set rs=nothing
	Function ChW_sortbz(id,num)
		Dim rs1 ,sql1 ,sort1
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select sort1,intro from sortbz where id="&cint(id)&""
		rs1.open sql1,conn,1,1
		if rs1.eof then
			Response.write "此币种已被删除"
		else
			if num=0 then
				sort1=rs1("sort1")
				sort1=sort1&"("&rs1("intro")&")"
			else
				sort1=rs1("intro")
			end if
			Response.write sort1
		end if
		rs1.close
		set rs1=nothing
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
	TdYear=year(date())
	Tdmonth=month(date())
	TdDay=day(date())
	TdStartDay=year(date())&"-"&month(date())&"-1"
'TdDay=day(date())
	TdNextMonthday=dateadd("m",1,TdStartDay)
	TdTol=datediff("d",TdStartDay,TdNextMonthday)
	TdEndDay=year(date())&"-"&month(date())&"-"&TdTol&""
'TdTol=datediff("d",TdStartDay,TdNextMonthday)
	set rslog=server.CreateObject("adodb.recordset")
	sqllog="select * from hr_KQ_config where del=0 and datediff(d,startTime,'"&date()&"')>=0 and datediff(d,endTime,'"&date()&"')<=0"
	rslog.open sqllog,conn,1,1
	if not rslog.eof then
		HR_login_M=rslog("login_M")*60
		HR_leave_M=rslog("leave_M")*60
		HR_overtime_M=rslog("overtime_M")*60
		HR_work_H=rslog("work_H")
		HR_login_Pat=rslog("login_Pat")
		HR_overtime_to_int=rslog("overtime_to_int")
		HR_hoDay_Ref=rslog("hoDay_Ref")*60
		HR_comType=rslog("companyType")
		HR_Test=rslog("publicTest")
	else
		HR_login_M=0
		HR_leave_M=0
		HR_overtime_M=8
		HR_login_Pat=4
		HR_overtime_to_int=30
		HR_work_H=1
		HR_hoDay_Ref=2*60
		HR_comType=1
		HR_Test=1
	end if
	rslog.close
	set rslog=nothing
	if isnumeric(HR_hoDay_Ref)=false then HR_hoDay_Ref=2*60
	function getCliIP()
		CliIP = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
		If CliIP = "" Or IsNull(CliIP) Then CliIP = Request.ServerVariables("REMOTE_ADDR")
		If InStr(CliIP, ",") Then CliIP = Split(CliIP, ",")(0)
		CliIP = CStr(CliIP)
		getCliIP=CliIP
	end function
	sub dayLog(rusult)
		dim thisIPStr
		thisIPStr=getCliIP()
		conn.execute "insert into  hr_Log (creator,inDate,result,ip,del) values("&session("personzbintel2007")&",'"&now()&"',"&rusult&",'"&thisIPStr&"',0)"
	end sub
	sub hr_login_C()
		set rslog1=server.CreateObject("adodb.recordset")
		sqllog1="select * from hr_LoginList where del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
		rslog1.open sqllog1,conn,1,1
		if rslog1.eof then
			Com_login_Time=getWorkClassListC(date,session("personzbintel2007"),1)
			Com_out_Time=getWorkClassListC(date,session("personzbintel2007"),2)
			if isdate(Com_login_Time)=true then
				if abs(datediff("n",Com_login_Time,now()))<=HR_hoDay_Ref then
					if datediff("s",now(),Com_login_Time)<=HR_login_M then
						conn.execute "insert into  hr_LoginList (creator,today,loginTime,del,week,kt,c_loginTime,c_outTime,result) values("&session("personzbintel2007")&",'"&date&"','"&now()&"',0,'"&WeekdayName(Weekday(Date))&"',0,'"&Com_login_Time&"','"&Com_out_Time&"','|6')"
					else
						conn.execute "insert into  hr_LoginList (creator,today,loginTime,del,week,kt,c_loginTime,c_outTime,result) values("&session("personzbintel2007")&",'"&date&"','"&now()&"',0,'"&WeekdayName(Weekday(Date))&"',0,'"&Com_login_Time&"','"&Com_out_Time&"','')"
					end if
				end if
			else
			end if
		else
		end if
		rslog1.close
		set rslog1=nothing
	end sub
	sub hr_out_C()
		dim oldresult
		set rslog1=server.CreateObject("adodb.recordset")
		sqllog1="select * from hr_LoginList where del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
		rslog1.open sqllog1,conn,1,1
		if not rslog1.eof then
			oldresult=rslog1("result")
			Com_out_Time=getWorkClassListC(date,session("personzbintel2007"),2)
			if isdate(Com_out_Time)=false then
			else
				if abs(datediff("n",Com_out_Time,now()))<=HR_hoDay_Ref then
					if datediff("s",now(),Com_out_Time)<=0 then
						if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
							if gethrResultCount(now(),now(),session("personzbintel2007"),15)>0 then
								conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','') where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
							elseif gethrResultCount(now(),now(),session("personzbintel2007"),15)=0 and oldresult="" then
								conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','')+'|15' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
							elseif gethrResultCount(now(),now(),session("personzbintel2007"),15)=0 and oldresult="" then
							else
								conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','') where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
							end if
						else
							resultStr=conn.execute("select result from  hr_LoginList  where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'")(0)
							if isnull(resultStr) or resultStr="" then
								conn.execute "update  hr_LoginList set outTime='"&now()&"',result=result+'|15' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
'if isnull(resultStr) or resultStr="" then
							else
								conn.execute "update  hr_LoginList set outTime='"&now()&"' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
							end if
						end if
					else
						if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
							conn.execute "update  hr_LoginList set outTime='"&now()&"' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
						else
							conn.execute "update  hr_LoginList set outTime='"&now()&"',result=result+'|7' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
						end if
					end if
				end if
			end if
		else
		end if
		rslog1.close
		set rslog1=nothing
	end sub
	sub hr_login_F()
		set rslog9=server.CreateObject("adodb.recordset")
		sqllog9="select top 1 * from hr_LoginList where del=0 and creator="&session("personzbintel2007")&" order by id desc"
		rslog9.open sqllog9,conn,1,1
		if rslog9.eof then
			call hr_f_LoginAdd()
		else
			hr_f_loginTime=rslog9("c_loginTime")
			hr_f_outTime=rslog9("c_outTime")
			hr_f_kt=rslog9("kt")
			hr_f_id=rslog9("id")
			if hr_f_kt="" or isnumeric(hr_f_kt)=false then hr_f_kt=0
			if isdate(hr_c_loginTime) and isdate(hr_c_outTime) then
				if datediff("d",now(),hr_f_loginTime)<=0 and datediff("d",now(),hr_f_outTime)>=0 and hr_f_kt>0 then
				else
					set rslog10=server.CreateObject("adodb.recordset")
					sqllog10="select * from hr_LoginList where del=0 and creator="&session("personzbintel2007")&" today='"&date&"'"
					rslog10.open sqllog10,conn,1,1
					if rslog10.eof then
						call hr_f_LoginAdd()
					else
					end if
					rslog10.close
					set rslog10=nothing
				end if
			else
			end if
		end if
		rslog9.close
		set rslog9=nothing
	end sub
	sub hr_f_LoginAdd()
		f_login_Time=getFcClassListC(date,session("personzbintel2007"),1)
		f_out_Time=getFcClassListC(date,session("personzbintel2007"),2)
		f_kt=getWorkKT(date,session("personzbintel2007"))
		if isnumeric(f_kt)=false then f_kt=0
		result_add=""
		if isdate(f_login_Time)=true and abs(datediff("n",f_login_Time,now()))<=HR_hoDay_Ref then
			if datediff("s",now(),f_login_Time)<=HR_login_M then
				result_add="|6"
			else
				result_add=""
			end if
			conn.execute "insert into  hr_LoginList (creator,today,loginTime,del,week,kt,c_loginTime,c_outTime,result) values("&session("personzbintel2007")&",'"&date&"','"&now()&"',0,'"&WeekdayName(Weekday(Date))&"',"&f_kt&",'"&f_login_Time&"','"&f_out_Time&"','"&result_add&"')"
		else
		end if
	end sub
	sub hr_f_LoginEdit(id)
		conn.execute "update  hr_LoginList set outTime='"&now()&"' where  del=0 and creator="&session("personzbintel2007")&" and id="&id&""
	end sub
	sub hr_out_F()
		set rslog8=server.CreateObject("adodb.recordset")
		sqllog8="select top 1 * from hr_LoginList where del=0 and creator="&session("personzbintel2007")&" order by id desc"
		rslog8.open sqllog8,conn,1,1
		if rslog8.eof then
		else
			outOld=rslog8("c_outTime")
			loginOld=rslog8("c_loginTime")
			ktOld=rslog8("kt")
			oldresult=rslog8("result")
			if ktOld="" or isnumeric(ktOld)=false then ktOld=0
			if  isdate(outOld) and isdate(loginOld)   then
				if datediff("s",loginOld,now())>=0 and datediff("s",outOld,now())<=0 and ktOld>0 then
					if abs(datediff("n",outOld,now()))<=HR_hoDay_Ref then
						if datediff("s",now(),outOld)<=0 then
							if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
								if gethrResultCount(now(),now(),session("personzbintel2007"),15)>0 then
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','') where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'"
'if gethrResultCount(now(),now(),session("personzbintel2007"),15)>0 then
								elseif gethrResultCount(now(),now(),session("personzbintel2007"),15)=0 and oldresult="" then
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','')+'|15' where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'"
'elseif gethrResultCount(now(),now(),session("personzbintel2007"),15)=0 and oldresult="" then
								else
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','') where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'"
'else
								end if
							else
								resultStr=conn.execute("select result from  hr_LoginList  where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'")(0)
'else
								if isnull(resultStr) or resultStr="" then
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=result+'|15' where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'"
'if isnull(resultStr) or resultStr="" then
								else
									conn.execute "update  hr_LoginList set outTime='"&now()&"' where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'"
'else
								end if
							end if
						else
							if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
								conn.execute "update  hr_LoginList set outTime='"&now()&"' where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'"
'if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
							else
								conn.execute "update  hr_LoginList set outTime='"&now()&"',result=result+'|7' where  del=0 and creator="&session("personzbintel2007")&" and today='"&dateadd("d",-(ktOld),date)&"'"
'if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
							end if
						end if
					end if
				elseif ktold=0 then
					TdOutTime=conn.execute("select outTime from  hr_LoginList  where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'")(0)
					Tdresult=conn.execute("select result from  hr_LoginList  where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'")(0)
					if isdate(TdoutTime)=false then exit sub
					if abs(datediff("n",TdOutTime,now()))<=HR_hoDay_Ref then
						if datediff("s",now(),TdOutTime)<=0 then
							if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
								if gethrResultCount(now(),now(),session("personzbintel2007"),15)>0 then
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','') where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
								elseif gethrResultCount(now(),now(),session("personzbintel2007"),15)=0 and Tdresult="" then
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','')+'|15' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
'elseif gethrResultCount(now(),now(),session("personzbintel2007"),15)=0 and Tdresult="" then
								else
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=replace(result,'|7','') where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
								end if
							else
								Tdresult=conn.execute("select result from  hr_LoginList  where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'")(0)
								if isnull(Tdresult) or Tdresult="" then
									conn.execute "update  hr_LoginList set outTime='"&now()&"',result=result+'|15' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
'if isnull(Tdresult) or Tdresult="" then
								else
									conn.execute "update  hr_LoginList set outTime='"&now()&"' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
								end if
							end if
						else
							if gethrResultCount(now(),now(),session("personzbintel2007"),7)>0 then
								conn.execute "update  hr_LoginList set outTime='"&now()&"' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
							else
								conn.execute "update  hr_LoginList set outTime='"&now()&"',result=result+'|7' where  del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
							end if
						end if
					end if
				end if
			else
			end if
		end if
		rslog8.close
		Set rslog8=Nothing
		set rslog=server.CreateObject("adodb.recordset")
		sqllog="select * from hr_LoginList where del=0 and creator="&session("personzbintel2007")&" and today='"&date&"'"
		rslog.open sqllog,conn,1,1
		if rslog.eof then
		else
			outRS=rslog("c_outTime")
			if isdate(outRS) then
			end if
			conn.execute "insert into  hr_LoginList (creator,today,loginTime,del,week) values("&session("personzbintel2007")&",'"&date&"','"&now()&"',0,'"&WeekdayName(Weekday(Date))&"')"
		end if
		rslog.close
		set rslog=nothing
	end sub
	function haveLogData(num)
		dim hr_newDate
		hr_newDate=dateadd("d",-num,date)
'dim hr_newDate
		set rslog2=server.CreateObject("adodb.recordset")
		sqllog2="select * from hr_LoginList where del=0 and creator="&session("personzbintel2007")&" and today='"&hr_newDate&"'"
		rslog2.open sqllog2,conn,1,1
		if not rslog2.eof then
			haveLogData=true
		else
			haveLogData=false
		end if
		rslog2.close
		set rslog2=nothing
	end function
	function getPersonID(pid)
		set rslog3=server.CreateObject("adodb.recordset")
		sqllog3="select * from hr_PersonClass where del=0 and ','+user_list+',' like '%,"&pid&",%'"
'set rslog3=server.CreateObject("adodb.recordset")
		rslog3.open sqllog3,conn,1,1
		if not rslog3.eof then
			getPersonID=rslog3("id")
		else
			getPersonID=""
		end if
		rslog3.close
		set rslog3=nothing
	end function
	function getcomType()
		set rslog4=server.CreateObject("adodb.recordset")
		sqllog4="select * from hr_KQ_config "
		rslog4.open sqllog4,conn,1,1
		if not rslog4.eof then
			getcomType=rslog4("companyType")
		else
			getcomType=1
		end if
		rslog4.close
		set rslog4=nothing
	end function
	function getWorkClassListC(timestr,ord,result)
		dim Lg_startTimeList(6),Lg_endTimeList(6),Lg_openList(6)
		if isdate(timestr) then
			weekNum=weekday(timestr)-2
'if isdate(timestr) then
			W_today=FormatDateTime(year(timestr)&"-"&month(timestr)&"-"&day(timestr))
'if isdate(timestr) then
			set rslog=server.CreateObject("adodb.recordset")
			sqllog="select * from hr_com_time where del=0 and (isall=1 or (isall=0 and ','+cast(user_list as nvarchar)+',' like '%,"&ord&",%')) and DateDiff(d,startTime,'"&timestr&"') >=0 and DateDiff(d,endTime,'"&timestr&"')<=0"
'set rslog=server.CreateObject("adodb.recordset")
			rslog.open sqllog,conn,1,1
			if not rslog.eof then
				Lg_startTimeList(0)=W_today&" "&rslog("stime1")
				Lg_startTimeList(1)=W_today&" "&rslog("stime2")
				Lg_startTimeList(2)=W_today&" "&rslog("stime3")
				Lg_startTimeList(3)=W_today&" "&rslog("stime4")
				Lg_startTimeList(4)=(W_today&" "&rslog("stime5"))
				Lg_startTimeList(5)=(W_today&" "&rslog("stime6"))
				Lg_startTimeList(6)=(W_today&" "&rslog("stime7"))
				Lg_endTimeList(0)=(W_today&" "&rslog("etime1"))
				Lg_endTimeList(1)=(W_today&" "&rslog("etime2"))
				Lg_endTimeList(2)=(W_today&" "&rslog("etime3"))
				Lg_endTimeList(3)=(W_today&" "&rslog("etime4"))
				Lg_endTimeList(4)=(W_today&" "&rslog("etime5"))
				Lg_endTimeList(5)=(W_today&" "&rslog("etime6"))
				Lg_endTimeList(6)=(W_today&" "&rslog("etime7"))
				Lg_openList(0)=rslog("open1")
				Lg_openList(1)=rslog("open2")
				Lg_openList(2)=rslog("open3")
				Lg_openList(3)=rslog("open4")
				Lg_openList(4)=rslog("open5")
				Lg_openList(5)=rslog("open6")
				Lg_openList(6)=rslog("open7")
				for i=0 to 6
					if weekNum<>"" and weekNum=i then
						Lg_open=Lg_openList(i)
						if Lg_open=1 then
							Lg_startTime=Lg_startTimeList(i)
							Lg_endTime=Lg_endTimeList(i)
						elseif Lg_open=2 then
							Lg_startTime="0"
							Lg_endTime="0"
						end if
					end if
				next
			else
				Lg_startTime=""
				Lg_endTime=""
			end if
			rslog.close
			set rslog=nothing
		else
			Lg_startTime=""
			Lg_endTime=""
		end if
		if isnumeric(result) and result=1 then
			getWorkClassListC=Lg_startTime
		elseif isnumeric(result) and result=2 then
			getWorkClassListC=Lg_endTime
		else
			getWorkClassListC=""
		end if
	end function
	function getFcClassListC(timestr,ord,result)
		if isdate(timestr) then
			personid=getPersonID(ord)
			set rslog=server.CreateObject("adodb.recordset")
			sqllog="select * from hr_Fc_time where del=0 and personClass="&personid&" and DateDiff(d,d1,'"&timestr&"') >=0 and DateDiff(d,d2,'"&timestr&"')>=0"
			rslog.open sqllog,conn,1,1
			if not rslog.eof then
				workID=rslog("workClass")
				if workID<>"" and isnumeric(workID) then
					if workID=0 then
						getFcClassListC="0"
					else
						set rs_wi=server.CreateObject("adodb.recordset")
						sql_wi="select * from hr_dayWorkTime where del=0 and id="&workID&""
						rs_wi.open sql_wi,conn,1,1
						if not rs_wi.eof then
							W_today=FormatDateTime(year(timestr)&"-"&month(timestr)&"-"&day(timestr))
'if not rs_wi.eof then
							Lg_startTime=FormatDateTime(W_today&" "&rs_wi("dateStart"))
							Lg_endTime=rs_wi("dateEnd")
							kt=rs_wi("kt")
							if kt<>"0" then
								Lg_endTime=FormatDateTime(dateadd("d",kt,W_today)&" "&Lg_endTime)
							else
								Lg_endTime=FormatDateTime(W_today&" "&Lg_endTime)
							end if
						else
							Lg_startTime=""
							Lg_endTime=""
						end if
						rs_wi.close
						set rs_wi=nothing
					end if
				else
					Lg_startTime=""
					Lg_endTime=""
				end if
			else
				Lg_startTime=""
				Lg_endTime=""
			end if
			rslog.close
			set rslog=nothing
		else
			Lg_startTime=""
			Lg_endTime=""
		end if
		if isnumeric(result) and result=1 then
			getFcClassListC=Lg_startTime
		elseif isnumeric(result) and result=2 then
			getFcClassListC=Lg_endTime
		else
			getFcClassListC=""
		end if
	end function
	function getWorkKT(timestr,ord)
		if isdate(timestr) then
			personid=getPersonID(ord)
			set rslog=server.CreateObject("adodb.recordset")
			sqllog="select * from hr_Fc_time where del=0 and personClass="&personid&" and DateDiff(d,d1,'"&timestr&"') <=0 and DateDiff(d,d2,'"&timestr&"')<=0"
			rslog.open sqllog,conn,1,1
			if not rslog.eof then
				workID=rslog("workClass")
				if workID<>"" and isnumeric(workID) then
					set rs_wi=server.CreateObject("adodb.recordset")
					sql_wi="select * from hr_dayWorkTime where del=0 and id="&workID&""
					rs_wi.open sql_wi,conn,1,1
					if not rs_wi.eof then
						getWorkKT=rs_wi("kt")
					else
						getWorkKT=0
					end if
					rs_wi.close
					set rs_wi=nothing
				else
					getWorkKT=0
				end if
			else
				getWorkKT=0
			end if
			rslog.close
			set rslog=nothing
		else
			getWorkKT=0
		end if
	end function
	function getSalaryClassName(id)
		if id<>"" and isnumeric(id) then
			set rs_scn=server.CreateObject("adodb.recordset")
			sql_scn="select * from hr_SalaryClass where del=0 and id="&id&""
			rs_scn.open sql_scn,conn,1,1
			if not rs_scn.eof then
				getSalaryClassName=rs_scn("title")
			else
				getSalaryClassName=""
			end if
			rs_scn.close
			set rs_scn=nothing
		else
			getSalaryClassName=""
		end if
	end function
	function getSalary(flag,gateid,tsdate)
		dim pubBasicWage,pubReguldate,pubProbSalary,pubEntrydate
		tsyear=year(tsdate)
		tsmonth=month(tsdate)
		tsDay=year(tsdate)&"-"&month(tsdate)&"-1"
'tsmonth=month(tsdate)
		nextmonthday=dateadd("m",1,tsDay)
		tsTol=datediff("d",tsDay,nextmonthday)
		tsDayEnd=year(tsdate)&"-"&month(tsdate)&"-"&tsTol&""
'tsTol=datediff("d",tsDay,nextmonthday)
		set rs_s=server.CreateObject("adodb.recordset")
		sql_s="select * from hr_SalaryClass where del=0 "
		rs_s.open sql_s,conn,1,1
		if not rs_s.eof then
			redim SalaryClass(1,rs_s.recordCount)
			i=0
			do while not rs_s.eof
				SalaryClass(0,i)=rs_s("title")
				SalaryClass(1,i)=rs_s("flag")
				i=i+1
'SalaryClass(1,i)=rs_s("flag")
				rs_s.movenext
			loop
		else
			SalaryClass(0,0)=""
			SalaryClass(1,0)=""
		end if
		rs_s.close
		set rs_s=nothing
		if flag<>"" and gateid<>"" and isnumeric(gateid) then
			set rs_s=server.CreateObject("adodb.recordset")
			sql_s="select * from hr_person where del=0 and userID="&gateid&" and datediff(d,Entrydate,'"&tsDayEnd&"')>=0"
			rs_s.open sql_s,conn,1,1
			if not rs_s.eof then
				pubBasicWage=Formatnumber(cdbl(rs_s("BasicSalary")),1,-1,0,0)
'if not rs_s.eof then
				pubReguldate=rs_s("Reguldate")
				pubProbSalary=Formatnumber(cdbl(rs_s("ProbSalary")),1-1,0,0)
'pubReguldate=rs_s("Reguldate")
				pubEntrydate=rs_s("Entrydate")
				nowStatus=rs_s("nowStatus")
			else
				pubBasicWage=0
				pubProbSalary=0
				nowStatus=0
				pubReguldate=""
				pubEntrydate=""
			end if
			rs_s.close
			set rs_s=nothing
			pubWordDays=Formatnumber(getRealWordDay(tsdate,tsDayEnd,gateid),4,-1,0,0)
'set rs_s=nothing
			pubNeedWorkDays=Formatnumber(getMonthWrokDay(tsdate,tsDayEnd,gateid),4,-1,0,0)
'set rs_s=nothing
			pubBaseSalary=0
			pubLateTimes=gethrResultCount(tsdate,tsDayEnd,gate,resultid)
			if isdate(pubReguldate) and isdate(tsdate) then
				if datediff("d",pubReguldate,tsdate)>=0 and nowStatus=1 then
					pubBaseSalary=pubBasicWage
				elseif datediff("d",pubReguldate,tsdate)<0 and datediff("d",pubReguldate,tsDayEnd)<0 and nowStatus=2 then
					pubBaseSalary=pubProbSalary
				elseif  datediff("d",pubReguldate,tsdate)<0 and datediff("d",pubReguldate,tsDayEnd)>=0  and nowStatus=2 then
					if pubNeedWorkDays>0 then
						pubBaseSalary=(pubProbSalary*(datediff("d",tsdate,pubReguldate)/pubNeedWorkDays))+pubBasicWage*(pubNeedWorkDays-datediff("d",tsdate,pubReguldate)/pubNeedWorkDays)
'if pubNeedWorkDays>0 then
					else
					end if
				else
					pubBaseSalary=0
				end if
			else
				pubBaseSalary=0
			end if
			pubLateTimes=Formatnumber(gethrResultCount(tsdate,tsDayEnd,gateid,6),4,-1,0,0)
'pubBaseSalary=0
			pubLeaveTimes=Formatnumber(gethrResultCount(tsdate,tsDayEnd,gateid,7),4,-1,0,0)
'pubBaseSalary=0
			pubPersion=Formatnumber(makeWelfare(1,gateid,tsdate,tsDayEnd),4,-1,0,0)
'pubBaseSalary=0
			pubHealth=Formatnumber(makeWelfare(2,gateid,tsdate,tsDayEnd),4,-1,0,0)
'pubBaseSalary=0
			pubUnplo=Formatnumber(makeWelfare(3,gateid,tsdate,tsDayEnd),4,-1,0,0)
'pubBaseSalary=0
			pubInjury=Formatnumber(makeWelfare(4,gateid,tsdate,tsDayEnd),4,-1,0,0)
'pubBaseSalary=0
			pubMater=Formatnumber(makeWelfare(5,gateid,tsdate,tsDayEnd),4,-1,0,0)
'pubBaseSalary=0
			pubHouse=Formatnumber(makeWelfare(6,gateid,tsdate,tsDayEnd),4,-1,0,0)
'pubBaseSalary=0
			if flag<>"" then
				if instr(flag,"{基本工资}")>0 then
					flag=replace(flag,"{基本工资}",pubBaseSalary)
				end if
				if instr(flag,"{实际出勤天数}")>0 then
					flag=replace(flag,"{实际出勤天数}",pubWordDays)
				end if
				if instr(flag,"{应出勤天数}")>0 then
					flag=replace(flag,"{应出勤天数}",pubNeedWorkDays)
				end if
				if instr(flag,"{迟到次数}")>0 then
					flag=replace(flag,"{迟到次数}",pubLateTimes)
				end if
				if instr(flag,"{早退次数}")>0 then
					flag=replace(flag,"{早退次数}",pubLeaveTimes)
				end if
				if instr(flag,"{养老保险}")>0 then
					flag=replace(flag,"{养老保险}",pubPersion)
				end if
				if instr(flag,"{医疗保险}")>0 then
					flag=replace(flag,"{医疗保险}",pubHealth)
				end if
				if instr(flag,"{失业保险}")>0 then
					flag=replace(flag,"{失业保险}",pubUnplo)
				end if
				if instr(flag,"{工伤保险}")>0 then
					flag=replace(flag,"{工伤保险}",pubInjury)
				end if
				if instr(flag,"{生育保险}")>0 then
					flag=replace(flag,"{生育保险}",pubMater)
				end if
				if instr(flag,"{住房公积金}")>0 then
					flag=replace(flag,"{住房公积金}",pubHouse)
				end if
				set rs9=server.CreateObject("adodb.recordset")
				sql9="select *  from hr_KQClass where del=0 and isprice=1 and sortid in(1,2,3) and UnitType is not null and sortID<>0"
				rs9.open sql9,conn,1,1
				if not rs9.eof then
					do while not rs9.eof
						kcTitle=rs9("title")
						kcUnitType=UnitTypeName(rs9("UnitType"))
						kcOrd=rs9("id")
						kcUnit=rs9("UnitType")
						if instr(flag,"{"&kcTitle&""&kcUnitType&"}")>0 then
							flag=replace(flag,"{"&kcTitle&""&kcUnitType&"}",Formatnumber(PriceAppDay(tsdate,tsDayEnd,gateid,kcOrd,kcUnit),4,-1,0,0))
'if instr(flag,"{"&kcTitle&""&kcUnitType&"}")>0 then
						end if
						rs9.movenext
					loop
				end if
				rs9.close
				set rs9=nothing
			else
				flag=0.0
			end if
			getSalaryClassNum=strtoint(flag)
		else
			getSalaryClassNum=0
		end if
		getSalary=getSalaryClassNum
	end function
	function getRealWordDay(SDate,EDate,gateid)
		set rs_s=server.CreateObject("adodb.recordset")
		sql_s="select count(*) as co from hr_LoginList where del=0 and creator="&gateid&" and datediff(HH,loginTime,outTime)>="&HR_login_Pat&" and datediff(d,'"&SDate&"',today)>=0 and datediff(d,'"&EDate&"',today)<=0"
		rs_s.open sql_s,conn,1,1
		if not rs_s.eof then
			getRealWordDay=rs_s(0)
		else
			getRealWordDay=0
		end if
		rs_s.close
		set rs_s=nothing
	end function
	function getMonthWrokDay(cwDate,cwDayEnd,gateid)
		dim cw_open(6)
		dim tolWorkMonth
		tolWorkMonth=0
		if isdate(cwDate) and isnumeric(gateid) then
			cwDay=day(cwDate)
			cwTol=datediff("d",cwDate,cwDayEnd)
			cwDayEnd=year(cwdate)&"-"&month(cwdate)&"-"&cwTol&""
'cwTol=datediff("d",cwDate,cwDayEnd)
			if HR_comType=1 then
				for c=0 to cwTol
					thisCWDay=dateadd("d",c,cwDate)
					set rs_scn=server.CreateObject("adodb.recordset")
					sql_scn="select * from hr_com_time where del=0 and datediff(d,startTime,'"&thisCWDay&"')>=0 and datediff(d,endTime,'"&thisCWDay&"')<=0 and charindex(','+cast("&gateid&" as varchar)+',',cast(user_list as varchar))>0"
'set rs_scn=server.CreateObject("adodb.recordset")
					rs_scn.open sql_scn,conn,1,1
					if not rs_scn.eof then
						cw_open(0)=rs_scn("open7")
						cw_open(1)=rs_scn("open1")
						cw_open(2)=rs_scn("open2")
						cw_open(3)=rs_scn("open3")
						cw_open(4)=rs_scn("open4")
						cw_open(5)=rs_scn("open5")
						cw_open(6)=rs_scn("open6")
					else
					end if
					rs_scn.close
					set rs_scn=nothing
					for o=0 to ubound(cw_open)
						if cw_open(o)=1 and weekday(thisCWDay)=(o+1) then
'for o=0 to ubound(cw_open)
							tolWorkMonth=tolWorkMonth+1
'for o=0 to ubound(cw_open)
						end if
					next
					if HR_Test=1 then
						tolWorkMonth=tolWorkMonth-getHolidayTNum(cwDate,cwDayEnd,1)
'if HR_Test=1 then
						tolWorkMonth=tolWorkMonth+getHolidayTNum(cwDate,cwDayEnd,2)
'if HR_Test=1 then
					end if
				next
			elseif HR_comType=2 then
				set rs_scn=server.CreateObject("adodb.recordset")
				sql_scn="select * from hr_Fc_time where personClass=(select id from hr_PersonClass where workClass<>0 and del=0 and( (isall=0 and (','+user_list+',' like '%,"&gateid&",%') ) or isall=1)) and del=0 and datediff(d,d1,'"&cwDate&"')<=0 and datediff(d,d2,'"&cwDayEnd&"')>=0 "
				set rs_scn=server.CreateObject("adodb.recordset")
				rs_scn.open sql_scn,conn,1,1
				if not rs_scn.eof then
					do while not rs_scn.eof
						tolWorkMonth=tolWorkMonth+1
'do while not rs_scn.eof
						rs_scn.movenext
					loop
				end if
				rs_scn.close
				set rs_scn=nothing
			end if
		end if
		getMonthWrokDay=tolWorkMonth
	end function
	function getHolidayTNum(dateStart,dateEnd,typeID)
		if isdate(dateStart) then
			startYear=year(dateStart)
			endYear=year(dateEnd)
		else
			startYear=year(now())
			endYear=year(now())
		end if
		if typeID="" or isnumeric(typeID)=false then typeID=0
		noNeedWork=""
		NeedWork=""
		set rs_ghd=server.CreateObject("adodb.recordset")
		sql_ghd="select * from hr_holiday where del=0 and datediff(y,HdYear,'"&startYear&"')<=0 and datediff(y,HdYear,'"&endYear&"')>=0"
		rs_ghd.open sql_ghd,conn,1,1
		if not rs_ghd.eof then
			do while not rs_ghd.eof
				noNeedWork=noNeedWork&rs_ghd("noNeedWork")
				NeedWork=NeedWork&rs_ghd("NeedWork")
				rs_ghd.movenext
			loop
		else
			noNeedWork=""
			NeedWork=""
		end if
		rs_ghd.close
		set rs_ghd=nothing
		if typeID=1 then
			if noNeedWork<>"" and isnull(noNeedWork)=false then
				if instr(noNeedWork,"|")=1 then
					noNeedWork=right(noNeedWork,len(noNeedWork)-1)
'if instr(noNeedWork,"|")=1 then
				end if
				oldGetHolidayTArr=split(noNeedWork,"|")
				dim newHolidayTArr,newHolidayTStr
				if oldGetHolidayTArr<>"" and isnull(oldGetHolidayTArr)=false then
					for wk=0 to ubound(oldGetHolidayTArr)
						if datediff("d",dateStart,oldGetHolidayTArr(wk))>=0 and datediff("d",dateEnd,oldGetHolidayTArr(wk))<=0 then
							newHolidayTStr=newHolidayTStr&"|"&oldGetHolidayTArr(wk)
						end if
					next
				else
					newHolidayTStr=""
				end if
				if newHolidayTStr<>"" then
					if instr(newHolidayTStr,"|")=1 then
						newHolidayTStr=right(newHolidayTStr,len(newHolidayTStr)-1)
'if instr(newHolidayTStr,"|")=1 then
						getHolidayTNum=ubound(split(newHolidayTStr,"|"))+1
'if instr(newHolidayTStr,"|")=1 then
					else
						getHolidayTNum=0
					end if
				else
					getHolidayTNum=0
				end if
			else
				getHolidayTNum=0
			end if
		elseif typeID=2 then
			if NeedWork<>"" and isnull(NeedWork)=false then
				if instr(NeedWork,"|")=1 then
					NeedWork=right(NeedWork,len(NeedWork)-1)
'if instr(NeedWork,"|")=1 then
				end if
				oldGetHolidayWArr=split(NeedWork,"|")
			else
				oldGetHolidayWArr=""
			end if
			dim newHolidayWArr,newHolidayWStr
			if oldGetHolidayWArr<>"" and isnull(oldGetHolidayWArr)=false then
				for wk=0 to ubound(oldGetHolidayWArr)
					if datediff("d",dateStart,oldGetHolidayWArr(wk))>=0 and datediff("d",dateEnd,oldGetHolidayWArr(wk))<=0 then
						newHolidayWStr=newHolidayWStr&"|"&oldGetHolidayWArr(wk)
					end if
				next
			else
				newHolidayWStr=""
			end if
			if newHolidayWStr<>"" then
				if instr(newHolidayWStr,"|")=1 then
					newHolidayWStr=right(newHolidayWStr,len(newHolidayWStr)-1)
'if instr(newHolidayWStr,"|")=1 then
					getHolidayTArr=ubound(split(newHolidayWStr,"|"))+1
'if instr(newHolidayWStr,"|")=1 then
				else
					getHolidayTNum=0
				end if
			else
				getHolidayTNum=0
			end if
		else
			getHolidayTNum=0
		end if
	end function
	function getresult(str)
		resultList=""
		if str<>""  then
			reArr=split(str,"|")
			for gt=0 to ubound(reArr)
				if reArr(gt)<>"" and isnumeric(reArr(gt)) then
					resultList=resultList&" "&gethrResult(reArr(gt))
				end if
			next
		else
			resultList=""
		end if
		getresult=resultList
	end function
	function gethrResult(id)
		if id<>"" and isnumeric(id) then
			set rs_g=server.CreateObject("adodb.recordset")
			sql_g="select * from hr_KQClass where del=0 and id="&id&" and sortid=5"
			rs_g.open sql_g,conn,1,1
			if not rs_g.eof then
				kqTitle=rs_g("title")
				if id<>15 then
					gethrResult="<span style='color:#ff0000'>"&kqTitle&"</span>"
				else
					gethrResult=rs_g("title")
				end if
			else
				gethrResult=""
				kqTitle=""
			end if
			rs_g.close
			set rs_g=nothing
		else
			gethrResult=""
		end if
	end function
	function gethrResultCount(sdate,edate,gate,resultid)
		if isdate(sdate)=false then sdate=TdStartDay
		if isdate(edate)=false then edate=TdEndDay
		if gate<>"" and isnumeric(gate) and isdate(sdate) and isdate(edate) and isnumeric(resultid) then
			dim ResultList
			ResultNum=0
			set rs_g=server.CreateObject("adodb.recordset")
			sql_g="select * from hr_LoginList where del=0 and datediff(d,'"&sdate&"',today)>=0 and datediff(d,'"&edate&"',today)<=0 and creator="&gate&""
			rs_g.open sql_g,conn,1,1
			if not rs_g.eof then
				do while not rs_g.eof
					C_result="|"&rs_g("result")&"|"
					if instr(C_result,"|"&resultid&"|")>0 then
						ResultNum=ResultNum+1
'if instr(C_result,"|"&resultid&"|")>0 then
					end if
					rs_g.movenext
				loop
			else
				ResultNum=0
			end if
			rs_g.close
			set rs_g=nothing
			gethrResultCount=ResultNum
		else
			gethrResultCount=""
		end if
	end function
	function strtoint(str)
		str=trim(str)
		if str="" or isnull(str) then
			strtoint=0
			exit function
		else
			if RegTest(str,"^[\d\+\-\*\/\(\)\.]+$") then
				exit function
				set rs9=server.CreateObject("adodb.recordset")
				Errdivi=true
				if instr(str,"/")>0 then
					dividentArr=split(str,"/")
					for s=0 to ubound(dividentArr)
						if s <>0 then
							if instr(dividentArr(s),")")>0 then
								divident=split(dividentArr(s),")")(0)
							else
								divident=dividentArr(s)
							end if
							if instr(divident,"+")>0 then
								divident=split(divident,"+")(0)
							end if
							if instr(divident,"+")>0 then
								divident=split(divident,"+")(0)
							end if
							if instr(divident,"+")>0 then
								divident=split(divident,"+")(0)
							end if
							if divident="" or isnumeric(divident)=false then divident=1
							if divident=0 then Errdivi=false
						end if
					next
				end if
				if Errdivi=false then
					strtoint=0
					exit function
				end if
				sql9="select "&str&""
				rs9.open sql9,conn,1,1
				if not rs9.eof then
					strtoint=rs9(0)
				else
					strtoint=0
				end if
				rs9.close
				set rs9=nothing
			else
				strtoint=0
			end if
		end if
	end function
	Function RegExpStr(patrn, strng)
		Dim regEx, Match, Matches
		Set regEx = New RegExp
		regEx.Pattern = patrn          ' 设置模式。'"\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
'Set regEx = New RegExp
		regEx.IgnoreCase = True
		regEx.Global = True
		Set Matches = regEx.Execute(strng)
		For Each Match In Matches
			RetStr = RetStr & Match.Value & "|"
		next
		RegExpTest = RetStr
	end function
	function getWelfare(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			select case id
			case 1:getWelfare="养老保险"
			case 2:getWelfare="医疗保险"
			case 3:getWelfare="失业保险"
			case 4:getWelfare="工伤保险"
			case 5:getWelfare="生育保险"
			case 6:getWelfare="住房公积金"
			case else :getWelfare=""
			end select
		else
			getWelfare=""
		end if
	end function
	function getPersonStatus(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			select case id
			case 1:getPersonStatus="正常"
			case 2:getPersonStatus="退休"
			case 3:getPersonStatus="离职未发工资"
			case 4:getPersonStatus="离职"
			case 5:getPersonStatus="试用期"
			case 6:getPersonStatus="休职"
			case 7:getPersonStatus="离职申请"
			case else :getPersonStatus=""
			end select
		else
			getPersonStatus=""
		end if
	end function
	function makeWelfare(id,gateid,sdate,edate)
		if id<>"" and isnumeric(id) and gateid<>"" and isnumeric(gateid) then
			set rsW=server.CreateObject("adodb.recordset")
			sqlW="select * from hr_Welfare where del=0 and classid="&id&" and ((isall=0 and ','+cast(user_list as nvarchar)+',' like '%,"&gateid&",%') or isall=1) order by id desc"
'set rsW=server.CreateObject("adodb.recordset")
			rsW.open sqlW,conn,1,1
			if not rsW.eof then
				w_base=noNum(rsW("base"),0)
				w_limit=noNum(rsW("limit"),0)
				w_lower=noNum(rsW("lower"),0)
				w_Propm_person=noNum(rsW("Propm_person"),0)
				w_Propm_personJia=noNum(rsW("Propm_personJia"),0)
				if w_base=0 then
					makeWelfare=0
				else
					if w_limit>0 then
						if w_base>w_limit then
							w_base=w_limit
						end if
					end if
					if w_lower>0 then
						if w_base<w_lower then
							w_base=w_lower
						end if
					end if
					makeWelfare=w_base*(w_Propm_person*0.01)+w_Propm_personJia
					w_base=w_lower
				end if
			else
				makeWelfare=0
			end if
			rsW.close
			set rsW=nothing
		else
			makeWelfare=0
		end if
	end function
	function noNum(str,zero)
		if str="" or isnull(str) or isnumeric(str)=false then
			noNum=zero
		else
			noNum=str
		end if
	end function
	function WelfareActin(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			select case id
			case 1:WelfareActin="一月计算"
			case 2:WelfareActin="实际天数"
			case 3:WelfareActin="忽略不计"
			case else :WelfareActin=""
			end select
		else
			WelfareActin=""
		end if
	end function
	function getSorceName(id)
		if id<>"" and isnumeric(id) and isnull(id)=false then
			set rs9=server.CreateObject("adodb.recordset")
			sql9="select sort1 from gate1 where ord="&id&""
			rs9.open sql9,conn,1,1
			if rs9.eof then
				getSorceName=""
			else
				getSorceName=rs9("sort1")
			end if
			rs9.close
			set rs9=nothing
		else
			getSorceName=""
		end if
	end function
	function getAppHolidayNum(startDate,endDate,cateid,sortid,unit)
		if startDate<>"" and isdate(startDate) and endDate<>"" and isdate(endDate) and cateid<>"" and isnull(cateid)=false  and isnumeric(cateid) and sortid<>"" and isnull(sortid)=false and isnumeric(sortid) and unit<>"" then
			getAppHolidayNum=conn.execute("select dbo.HrPriceAppDay('"&startDate&"','"&endDate&"',"&cateid&","&sortid&","&unit&")")(0)
		else
			getAppHolidayNum=0
		end if
	end function
	function getAppHolidayDay(startDate,endDate,cateid,sortid)
		if startDate<>"" and isdate(startDate) and endDate<>"" and isdate(endDate) and cateid<>"" and isnull(cateid)=false  and isnumeric(cateid) and sortid<>"" and isnull(sortid)=false and isnumeric(sortid) then
			set rs9=server.CreateObject("adodb.recordset")
			sql9="select *  from hr_AppHoliday where KQClass ="&sortid&" and creator="&cateid&" and ((datediff(d,'"&startDate&"',endTime)>=0 and datediff(d,'"&endDate&"',endTime)<=0)  or (datediff(d,'"&startDate&"',startTime)>=0 and datediff(d,'"&endDate&"',startTime)<=0))"
			rs9.open sql9,conn,1,1
			if rs9.eof then
				getAppHolidayDay=0
			else
				appDayNum=0
				do while not rs9.eof
					ad_endTime=rs9("endTime")
					ad_startTime=rs9("startTime")
					if ad_endTime<>"" and isnull(ad_endTime)=false and isnull(ad_startTime)=false and ad_startTime<>"" and  isdate(ad_endTime) and isdate(ad_startTime) then appDayNum=appDayNum+(datediff("h",ad_startTime,ad_endTime))
'ad_startTime=rs9("startTime")
					rs9.movenext
				loop
				getAppHolidayDay=appDayNum
			end if
			rs9.close
			set rs9=nothing
		else
			getAppHolidayDay=0
		end if
	end function
	function PriceAppDay(startDate,endDate,cateid,sortid,unit)
		if startDate<>"" and isdate(startDate) and endDate<>"" and isdate(endDate) and cateid<>"" and isnull(cateid)=false  and isnumeric(cateid) and sortid<>"" and isnull(sortid)=false and isnumeric(sortid) then
			set rs9=server.CreateObject("adodb.recordset")
			if unit=1 then
				sql9="select count(*) as co from hr_AppHoliday where KQClass ="&sortid&"  and creator="&cateid&" and ((datediff(d,'"&startDate&"',endTime)>=0 and datediff(d,'"&endDate&"',endTime)<=0)  or (datediff(d,'"&startDate&"',startTime)>=0 and datediff(d,'"&endDate&"',startTime)<=0))"
			else
				sql9="select *  from hr_AppHoliday where KQClass ="&sortid&" and creator="&cateid&" and ((datediff(d,'"&startDate&"',endTime)>=0 and datediff(d,'"&endDate&"',endTime)<=0)  or (datediff(d,'"&startDate&"',startTime)>=0 and datediff(d,'"&endDate&"',startTime)<=0))"
			end if
			rs9.open sql9,conn,1,1
			if rs9.eof then
				PriceAppDay=0
			else
				if unit=1 then
					PriceAppDay=rs9("co")
				else
					appDayNum=0
					do while not rs9.eof
						ad_endTime=rs9("endTime")
						ad_startTime=rs9("startTime")
						if unit=2 then
							if ad_endTime<>"" and isnull(ad_endTime)=false and isnull(ad_startTime)=false and ad_startTime<>"" and  isdate(ad_endTime) and isdate(ad_startTime) then appDayNum=appDayNum+(datediff("h",ad_startTime,ad_endTime))
'if unit=2 then
						elseif unit=3 then
							if ad_endTime<>"" and isnull(ad_endTime)=false and isnull(ad_startTime)=false and ad_startTime<>"" and  isdate(ad_endTime) and isdate(ad_startTime) then appDayNum=appDayNum+(getMonthWrokDay(ad_startTime,ad_endTime,cateid))
'elseif unit=3 then
						else
							appDayNum=0
						end if
						rs9.movenext
					loop
					PriceAppDay=appDayNum
				end if
			end if
			rs9.close
			set rs9=nothing
		else
			PriceAppDay=0
		end if
	end function
	function GetKQClassName(id)
		if id<>"" and isnumeric(id) and isnull(id)=false then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select * from hr_kqclass where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				GetKQClassName=rs9("title")
				if instr(GetKQClassName,"正常")=0 and instr(GetKQClassName,"休息")=0  and instr(GetKQClassName,"放假")=0 then
					GetKQClassName="<span style=""color:#ff0000"">"&GetKQClassName&"</span>"
				end if
			else
				GetKQClassName=""
			end if
			rs9.close
			set rs9=nothing
		else
			GetKQClassName=""
		end if
	end function
	function GetKQClassName1(id)
		if id<>"" and isnumeric(id) and isnull(id)=false then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select * from hr_kqclass where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				GetKQClassName1=rs9("title")
			else
				GetKQClassName1=""
			end if
			rs9.close
			set rs9=nothing
		else
			GetKQClassName1=""
		end if
	end function
	function WorKClassLi(personSort,tday)
		if personSort<>"" and isnumeric(personSort) and isnull(personSort)=false and isdate(tday) and tday<>"" then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select workclass from hr_fc_time where personclass="&personSort&" and datediff(d,d1,'"&tday&"')>=0 and datediff(d,d2,'"&tday&"')<=0"
			rs9.open sql,conn,1,1
			if not rs9.eof then
				workclass=rs9("workclass")
			else
				workclass=0
				WorKClassLi=""
				exit function
			end if
			rs9.close
			set rs9=nothing
			if workclass=0 then
				WorKClassLi="休息"
			else
				set rs9=server.CreateObject("adodb.recordset")
				sql="select * from hr_dayWorkTime where del=0 and id="&workclass&""
				rs9.open sql,conn,1,1
				if not rs9.eof then
					WorKClassLi=rs9("title")
				else
					WorKClassLi=""
				end if
				rs9.close
				set rs9=nothing
			end if
		else
			WorKClassLi=""
		end if
	end function
	function WorKClassLiID(personSort,tday)
		if personSort<>"" and isnumeric(personSort) and isnull(personSort)=false and isdate(tday) and tday<>"" then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select workclass from hr_fc_time where personclass="&personSort&" and datediff(d,d1,'"&tday&"')>=0 and datediff(d,d2,'"&tday&"')<=0"
			rs9.open sql,conn,1,1
			if not rs9.eof then
				workclass=rs9("workclass")
			else
				workclass=0
				WorKClassLiID=0
				exit function
			end if
			rs9.close
			set rs9=nothing
			if workclass=0 then
				WorKClassLiID=0
			else
				set rs9=server.CreateObject("adodb.recordset")
				sql="select * from hr_dayWorkTime where del=0 and id="&workclass&""
				rs9.open sql,conn,1,1
				if not rs9.eof then
					WorKClassLiID=rs9("id")
				else
					WorKClassLiID=0
				end if
				rs9.close
				set rs9=nothing
			end if
		else
			WorKClassLiID=0
		end if
	end function
	function WorKClassLiColor(personSort,tday)
		if personSort<>"" and isnumeric(personSort) and isnull(personSort)=false and isdate(tday) and tday<>"" then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select workclass from hr_fc_time where personclass="&personSort&" and datediff(d,d1,'"&tday&"')>=0 and datediff(d,d2,'"&tday&"')<=0"
			rs9.open sql,conn,1,1
			if not rs9.eof then
				workclass=rs9("workclass")
			else
				workclass=0
				WorKClassLiColor=""
				exit function
			end if
			rs9.close
			set rs9=nothing
			if workclass=0 then
				WorKClassLiColor="#ffffff"
			else
				set rs9=server.CreateObject("adodb.recordset")
				sql="select * from hr_dayWorkTime where del=0 and id="&workclass&""
				rs9.open sql,conn,1,1
				if not rs9.eof then
					WorKClassLiColor=rs9("color")
					if instr(WorKClassLiColor,"#")=0 then WorKClassLiColor="#ffffff"
				else
					WorKClassLiColor="#ffffff"
				end if
				rs9.close
				set rs9=nothing
			end if
		else
			WorKClassLiColor="#ffffff"
		end if
	end function
	function GetWorKClassName(id,num)
		if num="" then num=1
		if id<>"" and isnumeric(id) and isnull(id)=false  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select * from hr_dayWorkTime where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				title=rs9("title")
				PrefixCode=rs9("PrefixCode")
			else
				title=""
				color=""
				PrefixCode=""
			end if
			rs9.close
			set rs9=nothing
			if color<>"" then
				title="<font style=color:"&color&">"&title&"</font>"
			end if
			if num=1 then
				GetWorKClassName=title
			elseif num=2 then
				GetWorKClassName=color
			elseif num=3 then
				GetWorKClassName=PrefixCode
			end if
		else
			GetWorKClassName=""
		end if
	end function
	function UnitTypeName(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			select case id
			case 1:UnitTypeName="次数"
			case 2:UnitTypeName="小时"
			case 3:UnitTypeName="天数"
			case else :
			UnitTypeName=""
			end select
		else
			UnitTypeName=""
		end if
	end function
	function UnitName(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			select case id
			case 1:UnitName="次数"
			case 2:UnitName="小时"
			case 0:UnitName="天数"
			Case 3:UnitName ="分钟"
			case else :
			UnitName=""
			end select
		else
			UnitName=""
		end if
	end function
	function TaxLvName(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			select case id
			case 1:TaxLvName="一级"
			case 2:TaxLvName="二级"
			case 3:TaxLvName="三级"
			case 4:TaxLvName="四级"
			case 5:TaxLvName="五级"
			case 6:TaxLvName="六级"
			case 7:TaxLvName="七级"
			case 8:TaxLvName="八级"
			case 9:TaxLvName="九级"
			case 10:TaxLvName="十级"
			case else :TaxLvName="无"
			end select
		else
			TaxLvName="无"
		end if
	end function
	function belongGzClass(gateid,id)
		belongGzClass=false
		if id<>"" and isnull(id)=false and isnumeric(id) and isnumeric(gateid) then
			set rs9=server.CreateObject("adodb.recordset")
			sql="declare @str varchar(500) select @str=gongzi from hr_gongziclass where isall=1 or (isall=0 and charindex(','+cast("&gateid&" as varchar)+',',','+cast(user_list as varchar)+',')>0)  select count(id) as co from sortwages where id="&id&" and  id in (select short_str from dbo.split(@str,','))"
'set rs9=server.CreateObject("adodb.recordset")
			rs9.open sql,conn,1,1
			if not rs9.eof then
				if rs9("co")>0 then
					belongGzClass=true
				else
					belongGzClass=false
				end if
			else
				belongGzClass=false
			end if
			rs9.close
			set rs9=nothing
		else
			belongGzClass=false
		end if
	end function
	function GzClassName(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select title from hr_gongziclass where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				GzClassName=rs9("title")
			else
				GzClassName=""
			end if
			rs9.close
			set rs9=nothing
		else
			GzClassName=""
		end if
	end function
	sub checkDbPerson(table,allcansee,W3,id)
		ThisHad=false
		if allcansee=1 then
			hasNum=conn.execute("select count(*) from "&table&" where del=0 and id<>"&id&"")(0)
			if hasNum>0 then
				ThisHad=true
			end if
		else
			if W3<>"" then
				hasNumStr=split(W3,",")
				for j=0 to ubound(hasNumStr)
					if hasNumStr(j)<>"" and hasNumStr(j)<>"0" then
						hasNum=conn.execute("select count(*) from "&table&" where del=0 and id<>"&id&" and (isall=1 or (isall=0 and charindex(','+cast("& hasNumStr(j) &" as varchar)+',',','+user_list+',')>0))")(0)
'if hasNumStr(j)<>"" and hasNumStr(j)<>"0" then
						if hasNum>0 then
							ThisHad=true
						end if
					end if
				next
			end if
		end if
		if thisHad then
			call jsBack("每个分组中的人员不能与别的分组重复")
		end if
	end sub
	sub DateDiffFun(typeStr,sDAte,eDate)
		if isdate(sDAte) and isdate(eDate) then
			if datediff(typeStr,sDAte,eDate)<0 then
				call jsBack("开始时间必须小于截止时间")
			end if
		else
			call jsBack("时间格式不正确")
		end if
	end sub
	sub DateDiffDoub(typeStr,sDate,eDate,sdata,edata,table,id)
		if isdate(sDAte) and isdate(eDate) then
			call DateDiffFun(typeStr,sDate,eDate)
			sql="select count("&id&") from "&table&" where del=0  and"&_
			"("&_
			"(datediff("&typeStr&","&sdata&",'"&sDate&"')>=0 and datediff("&typeStr&","&edata&",'"&sDate&"')<=0) or"&_
			"(datediff("&typeStr&","&sdata&",'"&eDate&"')>=0 and datediff("&typeStr&","&edata&",'"&eDate&"')<=0)  or"&_
			"(datediff("&typeStr&","&sdata&",'"&sDate&"')<0 and datediff("&typeStr&","&edata&",'"&eDate&"')>0)"&_
			")"
			county=conn.execute(sql)(0)
			if county>0 then
				call jsBack("时间段存在交叉！")
				call db_close : Response.end
			end if
		else
			call jsBack("时间格式不正确")
			call db_close : Response.end
		end if
	end sub
	function GetUserList(P_user_list)
		if P_user_list<>"" and isnull(P_user_list)=false and replace(replace(P_user_list,",","")," ","")<>"" then
			set rs9=server.CreateObject("adodb.recordset")
			sql_pl="select * from gate  where ord in("&P_user_list&") and dbo.HrIsShowGate('"&date()&"',ord)=1"
			rs9.open sql_pl,conn,1,1
			if not rs9.eof then
				GetUserList=""
				do while not rs9.eof
					GetUserList=GetUserList&"<span style='padding:4px'>"&rs9("name")&"</span>"
					rs9.movenext
				loop
			else
				GetUserList="无"
			end if
			rs9.close
			set rs9=nothing
		else
			GetUserList="无"
		end if
	end function
	function performClassName(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select title from hr_perform_sp where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				performClassName=rs9("title")
			else
				performClassName=""
			end if
			rs9.close
			set rs9=nothing
		else
			performClassName=""
		end if
	end function
	function performSortName(id)
		if id<>"" and isnull(id)=false and isnumeric(id) then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select title from hr_perform_sort where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				performSortName=rs9("title")
			else
				performSortName=""
			end if
			rs9.close
			set rs9=nothing
		else
			performSortName=""
		end if
	end function
	function GetPerformScore(id,project,spid)
		if id<>"" and isnull(id)=false and isnumeric(id) and isnumeric(project) and isnumeric(spid)  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select score from hr_perform_score where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				GetPerformScore=rs9("score")
			else
				GetPerformScore=0
			end if
			rs9.close
			set rs9=nothing
		else
			GetPerformScore=0
		end if
	end function
	function taxSortName(id)
		if id<>"" and isnull(id)=false  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select title from hr_PersonTaxSort where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				taxSortName=rs9("title")
			else
				taxSortName=""
			end if
			rs9.close
			set rs9=nothing
		else
			taxSortName=""
		end if
	end function
	function KQClassUnitName(id)
		if id<>"" and isnull(id)=false  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select UnitType from hr_KQClass where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				KQClassUnitName=UnitTypeName(rs9("UnitType"))
			else
				KQClassUnitName=""
			end if
			rs9.close
			set rs9=nothing
		else
			KQClassUnitName=""
		end if
	end function
	function KQClassTitle(id)
		if id<>"" and isnull(id)=false  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select title from hr_KQClass where del=0 and id="&id&""
			rs9.open sql,conn,1,1
			if not rs9.eof then
				KQClassTitle=(rs9("title"))
			else
				KQClassTitle=""
			end if
			rs9.close
			set rs9=nothing
		else
			KQClassTitle=""
		end if
	end function
	function KQClassSort(id)
		if id<>"" and isnull(id)=false  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select  title  from hr_KQClass where del=0 and id=(select top 1 sortid from hr_KQClass where del=0 and id="&id&")"
			rs9.open sql,conn,1,1
			if not rs9.eof then
				KQClassSort=(rs9("title"))
			else
				KQClassSort=""
			end if
			rs9.close
			set rs9=nothing
		else
			KQClassSort=""
		end if
	end function
	function todayWorkColor(today,uid)
		if today<>"" and isdate(today)=true and uid<>""  then
			todayID=conn.execute("select dbo.HrTodayNeedWork('"&today&"',"&uid&")")(0)
			select case todayID
			case 1 todayWorkColor="hrNomer"
			case 2 todayWorkColor="hrTest"
			case 3 todayWorkColor="hrHoliday"
			case 4 todayWorkColor="hrNWork"
			case else todayWorkColor="Dday"
			end select
		else
			todayWorkColor="hrNoWrite"
		end if
	end function
	function todayKQResult(today,uid)
		if today<>"" and isdate(today)=true and uid<>"" then
			if  datediff("d",now(),today)>0  then
				todayKQResult=""
			else
				if conn.execute("select dbo.HrIsShowGate('"&today&"','"&uid&"')")(0)=1 then
					todayKQResult=conn.execute("select dbo.HrKQClassName(dbo.HrGetKQResult('"&today&"',"&uid&"))")(0)
				else
					todayKQResult=""
				end if
			end if
		else
			todayKQResult=""
		end if
	end function
	sub hrDelPower(id,table,openStr,intro)
		if openStr=3 then
			sql="select count(*) as co from "&table&" where del=0 and id="&id&" "
		elseif openStr=1 then
			sql="select count(*) as co from "&table&" where del=0 and id="&id&"  and  creator in("&intro&")"
		else
			call jsBack("您目前没有该单据的删除权限！")
			call db_close : Response.end
		end if
		set rs9=server.CreateObject("adodb.recordset")
		rs9.open sql,conn,1,1
		if not rs9.eof then
			if rs9("co")>0 then
				exit sub
			else
				call jsBack("您目前没有该单据的删除权限！")
				call db_close : Response.end
			end if
		else
			call jsBack("您目前没有该单据的删除权限！")
			call db_close : Response.end
		end if
		rs9.close
		set rs9=nothing
	end sub
	sub chkdoub(table,data1,val1,id)
		set rs9=server.CreateObject("adodb.recordset")
		sql9="select "&data1&" from "&table&" where "&data1&"='"&val1&"' and id<>"&id&""
		rs9.open sql9,conn,1,1
		if not  rs9.eof then
			call jsAlert("编号不能重复！")
			call db_close : Response.end
		end if
		rs9.close
		set rs9=nothing
	end sub
	sub chkgate(table,data1,val1,id)
		set rs9=server.CreateObject("adodb.recordset")
		sql9="select "&data1&" from "&table&" where "&data1&"='"&val1&"' and ord<>"&id&""
		rs9.open sql9,conn,1,1
		if not  rs9.eof then
			call jsAlert("编号不能重复！")
			call db_close : Response.end
		end if
		rs9.close
		set rs9=nothing
	end sub
	function getW3(strW1,strW2,strW3,nowstatus)
		dim i,status, sW4
		status=""
		If nowstatus<>"" Then status = " and nowstatus in ("& nowstatus &")"
		sW3 = Replace(strW3 & ""," ","")
		For i = 0 To 5
			sW3 = Replace(sW3,  ",,", ",")
		next
		If Len(sW3 & "") = 0 Then sW3 = "0"
		If status<>"" Then
			Set rs=conn.execute("select userid from hr_person where userid in ("&sW3&")" & status )
			If Not rs.eof Then
				While Not rs.eof
					sW4=rs("userid")&","&sW4
					rs.movenext
				wend
				sW3=Left(Trim(sW4),Len(Trim(sW4))-1)
				sW4=rs("userid")&","&sW4
			end if
			rs.close
			Set rs=Nothing
		end if
		getW3=sW3
	end function
	function getLimitedW3(strw3,stype,sort1,sort2,cid)
		dim i
		if (stype<>1 and stype<>2) or not isnumeric(sort1) or not isnumeric(sort2) or not isnumeric(cid) then
			Response.write "参数错误"
			call db_close : Response.end
		end if
		if strw3="-1" or strw3="0" then
			call db_close : Response.end
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
				getLimitedW3=tmpW3
			elseif qx_open="0" then
				getLimitedW3="0"
			elseif qx_open="3" then
				getLimitedW3=strw3
			end if
		end if
	end function
	function getW1W2(strW3)
		dim rtnW1,rtnW2,frs,fsql
		rtnW1=""
		rtnW2=""
		if strW3<>"" then
			fsql="select sorce,sorce2 from gate where ord in ("&strW3&")"
			set frs=conn.execute(fsql)
			while not frs.eof
				if rtnW1="" then
					rtnW1=frs(0)
				else
					rtnW1=rtnW1&","&frs(0)
				end if
				if rtnW2="" then
					rtnW2=frs(1)
				else
					rtnW2=rtnW2&","&frs(1)
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
		sW1=strW1:sW2=strW2:sW3=strW3
		W2list=0:W2list2=0:W3list=0:W3list2=0
		if sW1="" then sW1=0
		if sW2="" then sW2=0
		if sW3="" then sW3=0
		if sW1<>"" then
			set rsfunc=server.CreateObject("adodb.recordset")
			sql1="select ord from gate1  where ord in  ("&sW1&") order by gate1 asc"
			rsfunc.open sql1,conn,1,1
			if not rsfunc.eof then
				gate2="true"
				do until rsfunc.eof
					W2list=0
					set rs2=server.CreateObject("adodb.recordset")
					sql2="select ord from gate2  where sort1="&rsfunc("ord")&" order by gate2 asc"
					rs2.open sql2,conn,1,1
					if rs2.eof then
						gate2="false"
					else
						do until rs2.eof
							Products=rs2("ord")
							If CheckPurview(sW2,trim(Products))=True Then
								W2list="0"
								exit do
							else
								W2list=W2list&","&Products
							end if
							rs2.movenext
						loop
					end if
					rs2.close
					set rs2=nothing
					set rs2=server.CreateObject("adodb.recordset")
					sql2="select ord from gate where sorce="&rsfunc("ord")&" order by ord asc"
					rs2.open sql2,conn,1,1
					if not rs2.eof then
						do until rs2.eof
							Products=rs2("ord")
							If CheckPurview(sW3,trim(Products))=True Then
								W2list="0"
								exit do
							end if
							rs2.movenext
						loop
					end if
					rs2.close
					set rs2=nothing
					if W2list<>"0" or gate2="false" then
						set rs2=server.CreateObject("adodb.recordset")
						sql2="select ord from gate  where sorce="&rsfunc("ord")&" and cateid=2 order by ord asc"
						rs2.open sql2,conn,1,1
						if not rs2.eof then
							do until rs2.eof
								Products=rs2("ord")
								If CheckPurview(sW3,trim(Products))<>True Then
									sW3=sW3&","&Products
								end if
								rs2.movenext
							loop
						end if
						rs2.close
						set rs2=nothing
					end if
					W2list2=W2list2&","&W2list
					rsfunc.movenext
				loop
			end if
			rsfunc.close
			set rsfunc=nothing
		end if
		sW2 =sW2&","&W2list2
		if sW2<>"" and sW2<>"0" then
			set rsfunc=server.CreateObject("adodb.recordset")
			sql1="select ord from gate2  where ord in  ("&sW2&") order by gate2 desc"
			rsfunc.open sql1,conn,1,1
			if not rsfunc.eof then
				do until rsfunc.eof
					W3list="0"
					set rs2=server.CreateObject("adodb.recordset")
					sql2="select ord from gate  where sorce2="&rsfunc("ord")&" order by ord asc"
					rs2.open sql2,conn,1,1
					if not rs2.eof then
						do until rs2.eof
							Products =rs2("ord")
							If CheckPurview(sW3,trim(Products))=True Then
								W3list="0"
								exit do
							else
								W3list =W3list&","&Products
							end if
							rs2.movenext
						loop
					end if
					rs2.close
					set rs2=nothing
					if W3list<>"" then
						W3list2 = W3list2&","&W3list
					end if
					rsfunc.movenext
				loop
			end if
			rsfunc.close
			set rsfunc=nothing
		end if
		sW3=sW3&","&W3list2 & ""
		if sW3<>"0" and sW3<>"" then
			set rsfunc=server.CreateObject("adodb.recordset")
			sql1="select ord,name,sorce,sorce2 from gate  where ord in ("&sW3&") order by sorce asc,sorce2 asc ,cateid asc ,ord asc"
			rsfunc.open sql1,conn,1,1
			if rsfunc.eof then
				member2=""
			else
				do until rsfunc.eof
					if sW1<>"" then
						if ((not CheckPurview(sW1,trim(rsfunc("sorce")))) or (not CheckPurview(sW2,trim(rsfunc("sorce2"))))) and ((rsfunc("sorce2")<>0 and rsfunc("sorce")<>0) or (rsfunc("sorce2")=0 and rsfunc("sorce")<>0)) Then
							sW3=replace(sW3,rsfunc("ord")&",","")
						end if
					end if
					sW3=replace(sW3,",0,",",")
					rsfunc.movenext
				loop
			end if
			rsfunc.close
			set rsfunc=nothing
		end if
		dim zmrlist : zmrlist="0"
		if open_5_11=1 then
			dim zmrarriy : zmrarriy=split(intro_5_11,",")
			dim ryarriy : ryarriy=split(sW3,",")
			for i=lbound(zmrarriy) to ubound(zmrarriy)
				for j=lbound(ryarriy) to ubound(ryarriy)
					if CheckPurview(zmrarriy(i),ryarriy(j))=True Then
						zmrlist =zmrlist&","&ryarriy(j)
					end if
				next
			next
			getW3WithLock=zmrlist
		else
			getW3WithLock=sW3
		end if
	end function
	function GetSoreName(id)
		if id<>"" and isnull(id)=false and isnumeric(id)  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select sort1 from gate1 where ord=isnull((select sorce from gate where ord="&id&"),0)"
			rs9.open sql,conn,1,1
			if not rs9.eof then
				GetSoreName=rs9("sort1")
			else
				GetSoreName=""
			end if
			rs9.close
			set rs9=nothing
		else
			GetSoreName=""
		end if
	end function
	function GetSore2Name(id)
		if id<>"" and isnull(id)=false and isnumeric(id)  then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select sort2 from gate2 where ord=isnull((select sorce2 from gate where ord="&id&"),0)"
			rs9.open sql,conn,1,1
			if not rs9.eof then
				GetSore2Name=rs9("sort2")
			else
				GetSore2Name=""
			end if
			rs9.close
			set rs9=nothing
		else
			GetSore2Name=""
		end if
	end function
	function personFile(id)
		personFile=true
		if id<>"" and isnull(id)=false   then
			set rs9=server.CreateObject("adodb.recordset")
			sql="select id from wageslist where cateid in("&id&") and del=1"
			rs9.open sql,conn,1,1
			if not rs9.eof then
				personFile=false
			end if
			rs9.close
			set rs9=nothing
		end if
	end function
	Function checkWFWages(gateid, ynowStatus, nowStatus, contractEnd, act)
		If ((ynowStatus&""<>"2"  Or ynowStatus&""<>"4") And (nowStatus&""="2"  Or nowStatus&""="4")) Or datediff("d",contractEnd,Date)>0 Then
			Dim SCrs, altStr , intro
			If gateid&"" = "" Then gateid = 0
			Set SCrs = conn.execute("select isnull(sum((case when b.del=1 then 1 else 0 end)),0) as zcnum,isnull(sum((case when b.del<>1 then 1 else 0 end)),0) as delnum from wageslist a inner join wages b on a.wages=b.id and isnull(b.complete1,0)=0 where a.cateid="& gateid)
			If SCrs.eof = False Then
				intro = ""
				If SCrs(0).value>0 Then intro = "工资单列表"
				If SCrs(1).value>0 Then
					If Len(intro)>0 Then intro = intro & "和"
					intro = intro & "工资单回收站列表"
				end if
				If intro&""<>"" Then
					Select Case act
					Case "update" : altStr = "更新为离职或退休"
					Case "freeze" : altStr = "冻结"
					Case "delete" : altStr = "删除"
					End Select
					Call jsBack("该人员"& intro & "有未发放的工资，不可以"& altStr)
				end if
			end if
			SCrs.close
			Set SCrs = Nothing
		end if
	end function
	
	salaryClass=(trim(request.QueryString("salaryClass")))
	if salaryClass="" or isnumeric(salaryClass)=false or isnull(salaryClass) then
		sql_Salary=" and 1=2"
		sql_uid=" and 1=2"
		Cid = 0
	else
		Cid=salaryClass
		set rs8=server.CreateObject("adodb.recordset")
		sql8="select * from hr_gongziclass where del=0 and id="&salaryClass&""
		rs8.open sql8,conn,1,1
		if not rs8.eof Then
			salaryList=rs8("gongzi")
			userList=rs8("user_list")
			isAll=rs8("isall")
			if isAll=0 then
				sql_uid=" and charindex(','+cast(ord as varchar)+',',','+'"&userList&"'+',')>0 "
'if isAll=0 then
			else
				sql_uid=""
			end if
			if salaryList<>0 then
				sql_Salary=" and charindex(','+cast(id as varchar)+',',','+'"&salaryList&"'+',')>0 "
'if salaryList<>0 then
			else
				sql_Salary=""
			end if
		else
			sql_Salary=" and 1=2"
			sql_uid=" and 1=2"
		end if
	end if
	if salaryClass="" then salaryClass=0
	if request.Form("hiddendate")="" then
		tdate=date()
		if request("jtdate")<>"" Then tdate=request("jtdate")
	else
		if request.Form("hiddenflag")="1" then
			tdate=DateAdd("m",-1,cdate(request.Form("hiddendate")))
'if request.Form("hiddenflag")="1" then
		elseif request.Form("hiddenflag")="2" then
			tdate=DateAdd("m",1,cdate(request.Form("hiddendate")))
		elseif request.Form("hiddenflag")="3" then
			tdate=date()
			if request("jtdate")<>"" Then tdate=request("jtdate")
		end if
	end if
	tdmonth=month(tdate)
	tdyear=year(tdate)
	tdyear2=year(tdate)-1
	tdyear=year(tdate)
	s_tdDay1=tdyear&"-"&tdmonth&"-1"
	tdyear=year(tdate)
	s_TdDay1Next=dateadd("m",1,s_tdDay1)
	s_TdDayTol=datediff("d",s_tdDay1,s_TdDay1Next)
	s_TdEndDay=tdyear&"-"&tdmonth&"-"&s_TdDayTol&""
	s_TdDayTol=datediff("d",s_tdDay1,s_TdDay1Next)
	flag=0
	tdw=cdate(year(tdate)&"-"&month(tdate)&"-1")    ''
	flag=0
	tdmonth=month(tdate)    ''
	tdyear=year(tdate)
	tflag=0
	b=Weekday(tdw)
	td2=tdw-b+1
	b=Weekday(tdw)
	dim ord,title
	ord=request("ord")
	title=request("title")
	Set commSP = New CommSPHandle
	Call commSP.init("wages",0)
	Call commSP.loadNextSp()
	nextSpId = commSP.nextSpId
	nextGates = commSP.nextGates
	Set commSP = nothing
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
	Set commSP = nothing
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<script src=""../inc/jquery-1.4.2.min.js?ver="
	Response.write title_xtjm
	Response.write Application("sys.info.jsver")
	Response.write """ type=""text/javascript"" language=""javascript""></script>" & vbcrlf & "<script language=""JavaScript"" src=""../inc/system.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ type=""text/javascript""></script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"" src=""../contract/formatnumber.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""JavaScript"" type=""text/javascript"">" & vbcrlf & "window.s_tdDay1 = """
	Response.write s_tdDay1
	Response.write """;" & vbcrlf & "window.s_TdEndDay = """
	Response.write s_TdEndDay
	Response.write """;" & vbcrlf & "</script>" & vbcrlf & "<script src= ""../Script/Hs_add.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """  language=""JavaScript"" type=""text/javascript""></SCRIPT>" & vbcrlf & "<script language=""JavaScript"" type=""text/javascript"">" & vbcrlf & "    function setDay(day,eltName) {       " & vbcrlf & "        var qy=0;" & vbcrlf & "        if (jQuery(""#qy"").size() > 0) {" & vbcrlf & "      if (jQuery(""#qy"").attr(""checked"")) {" & vbcrlf & "                qy=1;" & vbcrlf & "            }" & vbcrlf & "        }" & vbcrlf & "       displayElement.value =displayYear+""-""+(displayMonth + 1)+ ""-"" +day;" & vbcrlf & "       hideElement(eltName);" & vbcrlf & "       document.location.href=""add.asp?salaryClass="
	Response.write salaryClass
	Response.write "&qy=""+qy+""&px="
	Response.write salaryClass
	Response.write px
	Response.write "&C="
	Response.write C
	Response.write "&x=1&jtdate=""+displayYear+""-""+(displayMonth + 1)+""""" & vbcrlf & "     }" & vbcrlf & "" & vbcrlf & "  function getSalaryClass(id){" & vbcrlf & "      var qy=0;" & vbcrlf & "          if (jQuery(""#qy"").size() > 0) {" & vbcrlf & "          jQuery(""#qy"").attr(""checked"", ""true"")" & vbcrlf & "qy=1;" & vbcrlf & "      }" & vbcrlf & "      window.location.href='add.asp?salaryClass='+id+'&jtdate="
	Response.write C
	Response.write tdate
	Response.write "&qy='+qy+'';" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function checkSubmit(){" & vbcrlf & " var salaryClass = $(""select[name='salaryClass']"").val();" & vbcrlf & "  var gztitle = $(""input[name='title']"").val();" & vbcrlf & "     var salaryClass = $(""select[name='salaryClass']"").val();" & vbcrlf & "     var gztitle = $(""input[name='title']"").val();" & vbcrlf & "     if(gztitle.length==0){" & vbcrlf & "          alert('请输入工资单主题!'); " & vbcrlf & "            $('#progress').hide();" & vbcrlf & "          $(""input[name='title']"").focus();" & vbcrlf & "         return false;" & vbcrlf & "   }" & vbcrlf & "       if(salaryClass.length==0){" & vbcrlf & "      alert('请选择工资账套!'); " & vbcrlf & "      $('#progress').hide();" & vbcrlf & "         " & vbcrlf & "         return false;" & vbcrlf & "       }" & vbcrlf & "       "
	if nextSpId>0 then
		Response.write "" & vbcrlf & "     var cateid_sp = $(""select[name='cateid_sp']"").val();" & vbcrlf & "      if(salaryClass.length>0 && cateid_sp.length==0){" & vbcrlf & "                alert('请选择审批人!'); " & vbcrlf & "                $('#progress').hide();" & vbcrlf & "          $(""select[name='cateid_sp']"").focus();" & vbcrlf & "            return false;" & vbcrlf & "  }" & vbcrlf & "       "
	end if
	Response.write "" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function ask() {" & vbcrlf & "    var salaryClass = $(""select[name='salaryClass']"").val();" & vbcrlf & "  var gztitle = $(""input[name='title']"").val();" & vbcrlf & "     if(gztitle.length==0){" & vbcrlf & "          alert('请输入工资单主题!'); " & vbcrlf & "            $('#progress').hide();" & vbcrlf & "         $(""input[name='title']"").focus();" & vbcrlf & "         return;" & vbcrlf & " }" & vbcrlf & "       if(salaryClass.length==0){" & vbcrlf & "          alert('请选择工资账套!'); " & vbcrlf & "      $('#progress').hide();" & vbcrlf & "         " & vbcrlf & "         return;" & vbcrlf & "     }" & vbcrlf & "       "
	if nextSpId>0 then
		Response.write "" & vbcrlf & "     var cateid_sp = $(""select[name='cateid_sp']"").val();" & vbcrlf & "      if(salaryClass.length>0 && cateid_sp.length==0){" & vbcrlf & "                alert('请选择审批人!'); " & vbcrlf & "                $('#progress').hide();" & vbcrlf & "          $(""select[name='cateid_sp']"").focus();" & vbcrlf & "            return;" & vbcrlf & "        }" & vbcrlf & "       "
	end if
	Response.write "" & vbcrlf & "     $(""#gzact"").val(""add"");" & vbcrlf & "    $(""#progress"").show();" & vbcrlf & "     $(""#progress"").height(document.body.scrollHeight);" & vbcrlf & "        $(""#progress"").width(document.body.scrollWidth);" & vbcrlf & "  $(""#imgs"").css(""top"",document.body.scrollHeight/2+document.body.scrollTop/2-50);" & vbcrlf & "       $(""#imgs"").css(""left"",document.body.scrollWidth/2+document.body.scrollLeft/2-50);" & vbcrlf & "   document.all.date.action = ""save.asp?salaryClass=" & "        }" & vbcrlf & "       "
	Response.write salaryClass
	Response.write """;" & vbcrlf & "        document.all.date.submit();" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function ask2() {" & vbcrlf & "   var salaryClass = $(""select[name='salaryClass']"").val();" & vbcrlf & "  var gztitle = $(""input[name='title']"").val();" & vbcrlf & "     if(gztitle.length==0){" & vbcrlf & "          alert('请输入工资单主题!'); " & vbcrlf & "         $('#progress').hide();" & vbcrlf & "          $(""input[name='title']"").focus();" & vbcrlf & "         return;" & vbcrlf & " }" & vbcrlf & "       if(salaryClass.length==0){" & vbcrlf & "          alert('请选择工资账套!'); " & vbcrlf & "      $('#progress').hide();" & vbcrlf & "        " & vbcrlf & "       return;" & vbcrlf & "  }" & vbcrlf & "       $(""#gzact"").val(""zancun"");" & vbcrlf & "    $(""#progress"").show();" & vbcrlf & "  $(""#progress"").height(document.body.scrollHeight);" & vbcrlf & "        $(""#progress"").width(document.body.scrollWidth);" & vbcrlf & "  $(""#imgs"").css(""top"",document.body.scrollHeight/2+document.body.scrollTop/2-50);" & vbcrlf & "        $(""#imgs"").css(""left"",document.body.scrollWidth/2+document.body.scrollLeft/2-50);" & vbcrlf & "   document.all.date.action = ""save.asp?salaryClass="
	Response.write salaryClass
	Response.write salaryClass
	Response.write """;" & vbcrlf & "        document.all.date.submit();" & vbcrlf & "}" & vbcrlf & "function OpenImportPage() {" & vbcrlf & "    var salaryClass = $(""select[name='salaryClass']"").val();" & vbcrlf & "    if(salaryClass.length==0){" & vbcrlf & "        alert('请选择工资账套!'); " & vbcrlf & "        return;" &vbcrlf & "    }" & vbcrlf & "    window.open('../../SYSN/view/hrm/HrWagesImport.ashx?salaryClass="
	Response.write salaryClass
	Response.write "&yearMonth="
	Response.write s_tdDay1
	Response.write "','Readbill','width=' + 1100 + ',height=' + 800 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "ResizeOnSub = function(){" & vbcrlf & "    var w = $(""#content"").width();" & vbcrlf & "    $(""#table_fixed"").css(""visibility"",""hidden"");" & vbcrlf & "    $(""#table_fixed"").css({""width"":w,""visibility"":""visible""});" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "BindOnResizeHwnd = 0;" & vbcrlf & "BindOnResize = function(){" & vbcrlf & "    if(BindOnResizeHwnd>0) { clearTimeout(BindOnResizeHwnd);BindOnResizeHwnd=0;  }" &vbcrlf & "    BindOnResizeHwnd=setTimeout(ResizeOnSub,100);" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function appendFixedTable(){" & vbcrlf & "    var tds = $(""#content tr.top td"");" & vbcrlf & "    $(""#table_container"").wrapAll(""<div id='table_relaDom'></div>"");" & vbcrlf & "    $(""#table_container"").before(""<div id='table_fixed'></div>"");" & vbcrlf & "    var w = $(""#content"").width();" & vbcrlf & "    $(""#table_fixed"").css({""width"":w});" & vbcrlf & "    $(""#table_fixed"").append(""<table border='0' cellpadding='6' cellspacing='0' bgcolor='#C0CCDD' id='fixedHeader' style='table-layout:fixed;'><tr class='top'></tr></table>"");" & vbcrlf & "    for(var i = 0;i<tds.length;i++){" & vbcrlf & "        $(""#fixedHeader tr.top"").append(tds[i].outerHTML.replace(/name=/g,""na="").replace(/id=/g,""dd=""));" & vbcrlf & "    }" & vbcrlf & "}" & vbcrlf & "setTimeout(function(){ "& vbcrlf & "    appendFixedTable(); " & vbcrlf & "    $(window).bind(""resize"",BindOnResize);" & vbcrlf & "},800)" & vbcrlf & "</script>" & vbcrlf & "" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style>" & vbcrlf & "#progress" & vbcrlf & "{" & vbcrlf & "    display:none;" & vbcrlf & "    position:absolute;" & vbcrlf & "    z-index:999;" & vbcrlf & "    BACKGROUND-COLOR:#9999aa;" & vbcrlf & "    filter:alpha(Opacity=60);" & vbcrlf &"    -moz-opacity:0.6;  " & vbcrlf & "    -khtml-opacity: 0.6;  " & vbcrlf & "    opacity: 0.6;" & vbcrlf & "}" & vbcrlf & "#table_relaDom {" & vbcrlf & "    overflow:hidden;" & vbcrlf & "    position:relative;" & vbcrlf & "}" & vbcrlf & "#table_fixed {" & vbcrlf & "    width:100%;" & vbcrlf & "   position:absolute;" & vbcrlf & "    overflow:hidden;" & vbcrlf & "    z-index:100;" & vbcrlf & "    top:0px;" & vbcrlf & "    left:0px;" & vbcrlf & "}" & vbcrlf & " #table_container {" & vbcrlf & "    width:100%;" & vbcrlf & "    height:570px !important;" & vbcrlf & "    overflow:auto;" & vbcrlf &" overflow-x:hidden;" & vbcrlf &   "  background:#FFF; "& vbcrlf & "}" & vbcrlf & " #table_container td{" & vbcrlf & "   font-weight:900;" & vbcrlf & " }" & vbcrlf & "#fixedHeader { "& vbcrlf & "    width:100%; "& vbcrlf & "    overflow:hidden; "& vbcrlf & "    color:#000;" & vbcrlf &  "   border-collapse:collapse;" & vbcrlf & "}" & vbcrlf & "#fixedHeader tr.top {" & vbcrlf & "    border-bottom: 1px solid #ccc;" & vbcrlf & "    background-color: #FFFFFF;" & vbcrlf & "}" & vbcrlf & "#fixedHeader tr.top td {" & vbcrlf & "    text-align: left;" & vbcrlf & "    overflow: hidden;" & vbcrlf & "    font-weight: bold;" & vbcrlf & "    color: #000;" & vbcrlf & "    cursor: default;" & vbcrlf & "    padding-top: 12px !important;" & vbcrlf & "    padding-bottom: 10px !important;" & vbcrlf & "    padding-left: 4px;" & vbcrlf & "    padding-right: 4px;" & vbcrlf & "    height: auto;" & vbcrlf & "    border:1px solid #c0ccdd;" & vbcrlf & "}" & vbcrlf & "#fixedHeader tr.top td div {" & vbcrlf & "    height: auto !important;" & vbcrlf & "    vertical-align: middle;" & vbcrlf & "}" & vbcrlf & "/*表头高度*/" & vbcrlf & "#table_fixed td{" & vbcrlf & "   border-color:#CCC!important;" & vbcrlf & "}" & vbcrlf & "#table_container .tbheader td {" & vbcrlf & "    padding: 12px  4px 10px !important;" & vbcrlf & "    line-height: 19px!important;" & vbcrlf & "}" & vbcrlf & "#table_container .tbheader td span{" & vbcrlf & "      line-height:19px;" & vbcrlf & "}" & vbcrlf & "</style>" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/default/easyui.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """>" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/icon.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """>" & vbcrlf & "<script type=""text/javascript"" src=""../inc/jquery.easyui.min.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "</head>" & vbcrlf & "<body style='min-width:1260px' class=""ReportUI"">" & vbcrlf & "<div id=""progress"">" & vbcrlf & " <div id=""imgs"" style=""position:absolute;margin:0 auto;"">&nbsp;&nbsp;&nbsp;&nbsp;<img src=""../skin/default/images/proc.gif""><br><font color=""green"">正在处理,请等待......</font></div>" & vbcrlf & "</div>" & vbcrlf & "<div id=""w2"" class=""easyui-window"" title=""批量导入年终奖"" style=""top:80px; left:330px;width:800px;height:680px;padding:5px;background: #fafafa; display:none;""  closed=""true"" collapsible=""true"" minimizable=""false"">" & vbcrlf & "    <div region=""center"" id=""importNzj"" border=""false"" style=""height:605px; background:#ffffff""></div>" & vbcrlf & "</div>" & vbcrlf & ""
	qy=request("qy")
	Response.write "" & vbcrlf & "<form method=""POST"" action=""add.asp?salaryClass="
	Response.write salaryClass
	Response.write """ id=""demo"" name=""date"">" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "    <tr>" & vbcrlf & "      <td width=""100%"" valign=""top"">" & vbcrlf & "               <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"" style=""border-bottom:0px solid #c0ccdc"">" & vbcrlf & "          <tr>" & vbcrlf & "            <td width=""240"" height=""30"" colspan=""2"" class=""place"" style=""width:240px;"">编制"
	Response.write salaryClass
	Response.write GzClassName(salaryClass)
	Response.write "工资表</td>" & vbcrlf & "              <td>是否启用累计扣税法<input name=""qy"" id=""qy"" "
	if qy=1 then
		Response.write "checked"
	end if
	Response.write "  onclick=""openform()"" type=""checkbox""  value=""1""></td>" & vbcrlf & "            <td align=""left"" colspan=""6""></td>" & vbcrlf & "          </tr>" & vbcrlf & "          <tr class=""resetHeadBg"" style=""background:url(../images/112.gif) repeat-x; background-position:0px -1px"">" & vbcrlf & "            <td height=""30"" width=""250"" align=""right"">工资账套：" & vbcrlf & "              <select id=""zt"" name=""salaryClass""  onChange=""getSalaryClass(this.value)"" style=""width:120px;"">" & vbcrlf & "                <option value="""" >请选择工资账套</option>" & vbcrlf & "                "
	set rs8=server.CreateObject("adodb.recordset")
	sql8="select id,title from hr_gongziclass where del=0"
	rs8.open sql8,conn,1,1
	do while not rs8.eof
		Response.write "<option value="""
		Response.write rs8("id")
		Response.write """ "
		if clng(salaryClass)=rs8("id") then
			Response.write "selected"
		end if
		Response.write ">"
		Response.write rs8("title")
		Response.write "</option>"
		rs8.movenext
	loop
	rs8.close
	set rs8=Nothing
	Response.write "" & vbcrlf & "              </select>" & vbcrlf & "              </td>" & vbcrlf & "              <td width=""210"" align=""left"" style=""padding-left:10px;height:40px"">主题：" & vbcrlf & "                            <input name=""title"" type=""text"" size=""15"" style=""width:120px;"" maxlength=""50"" value="""
	set rs8=Nothing
	Response.write title
	Response.write """ dataType=""Limit"" min=""1"" max=""50""  msg=""长度必须在1至50个字之间"" >" & vbcrlf & "                                <span class=""red"">*</span><input name=""ret""  type=""hidden"" size=""7""   value="""
	Response.write tdw
	Response.write """><input name=""ret2""  type=""hidden"" size=""7""   value="""
	Response.write dateadd("d",-1,dateadd("m",1,tdw))
	Response.write """><input name=""ret2""  type=""hidden"" size=""7""   value="""
	Response.write """><input type=""hidden"" name=""act"" id=""gzact"" value=""add""></td>" & vbcrlf & "              <td width=""360"" align=""left"" style=""padding-left:5px;"">" & vbcrlf & "                             <a href=""###"" onClick=""date.hiddenflag.value=1;date.submit();"">" & vbcrlf & "                                     <img src=""../images/main_2.gif"" width=""8"" height=""8"" border=""0"" /> 前一月</a>&nbsp;"
	Response.write tdyear
	Response.write "年"
	Response.write tdmonth
	Response.write "月份&nbsp;<a href=""#"" onClick=""date.hiddenflag.value=2;date.submit();"">后一月 <img src=""../images/main_1.gif"" width=""8"" height=""8"" border=""0"" /></a><input type=""button"" class=""anybutton"" value=""选择月份"" align=""absMiddle""  border=""0""  id=""daysOfMonth1Pos"" name=""daysOfMonth1Pos""onmouseup=""toggleDatePicker('daysOfMonth1','date.ret1')"" /> "& vbcrlf &  "                              <DIV id=daysOfMonth1 style=""POSITION: absolute;""></DIV><INPUT name=""ret1"" type=""hidden"" size=10 ></td> "& vbcrlf &   "            <td width=""160"" align=""left"" style=""padding-left:10px;"">币种：" & vbcrlf & ""
	if open_bz=0 then
		sql="select id,sort1 from sortbz where id=14"
	else
		sql="select id,sort1 from sortbz order by gate1 desc"
	end if
	set rs88=server.CreateObject("adodb.recordset")
	rs88.open sql,conn,1,1
	if not rs88.eof then
		Response.write "<select name=""bz"" style=""width:70px;"">"
		do while not rs88.eof
			Response.write "<option value="""
			Response.write rs88("id")
			Response.write """ "
			if cint(request("bz"))=rs88("id") then
				Response.write " selected"
			end if
			Response.write ">"
			Response.write rs88("sort1")
			Response.write "</option>"
			rs88.movenext
		loop
		Response.write "</select>"
	end if
	rs88.close
	set rs88=nothing
	Response.write "" & vbcrlf & "              </td>" & vbcrlf & "              <td width=""200"">" & vbcrlf & "                        "
	if nextSpId>0 then
		Response.write "" & vbcrlf & "                             审批人：" & vbcrlf & "                                <select name=""cateid_sp"" id=""cateid_sp"" style=""width:70px;"">" & vbcrlf & "                                  <option value="""">请选择</option>" & vbcrlf & "                                  "
		if nextGates&""<>"" then
			arr_gates1 = split(nextGates,"|")
			for i=0 to ubound(arr_gates1)
				if arr_gates1(i)&""<>"" then
					arr_gates2 = split(arr_gates1(i),"=")
					Response.write "<option value="""
					Response.write arr_gates2(0)
					Response.write """>"
					Response.write arr_gates2(1)
					Response.write "</option>"
				end if
			next
		end if
		Response.write "" & vbcrlf & "                             </select><input type=""hidden"" name=""sp"" value="""
		Response.write nextSpId
		Response.write """> <span class=""red"">*</span>" & vbcrlf & "              "
	end if
	Response.write "" & vbcrlf & "              </td>" & vbcrlf & "              <td width=""350"" align=""left"">" & vbcrlf & "                  <input type=""button"" name=""SubmitDR"" onclick=""OpenImportPage()"" value=""导入""  class=""page""/>" & vbcrlf & "                           "
	If hasNzjItem(salaryList) Then Response.write "<input type='button' name='Submit43' onclick=""openImportDiv()"" value='批量导入年终奖'  class='anybutton'  style='width:100px;' />"
	Response.write "<input type=""button"" name=""Submit40"" onclick=""ask2();"" value=""暂存""  class=""page""/>" & vbcrlf & "                            <input type=""button"" name=""Submit42"" onclick=""ask();"" value=""保存""  class=""page""/>" & vbcrlf & "                <input type=""reset"" value=""重填"" class=""page"" name=""B2"" style=""background-color:#EFEFEF"">" & vbcrlf & "              </td>" & vbcrlf & "              <td>" & vbcrlf & "                           <input type=""hidden"" id=""choosedate"" name=""hiddendate"" value="""
	Response.write tdate
	Response.write """>" & vbcrlf & "                                <input type=""hidden"" name=""hiddenflag""  value=""3"">" & vbcrlf & "                            <input type=""hidden""   name=""jtdate"" value="""
	Response.write tdate
	Response.write """>" & vbcrlf & "                          </td>" & vbcrlf & "          </tr> " & vbcrlf & "        </table>" & vbcrlf & "<div id=""table_container"">" & vbcrlf & "        <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"" style=""table-layout:fixed;"">" & vbcrlf & "                    <tr class=""top"">" & vbcrlf & "                          <td width=""100"">员工姓名<input type=""hidden"" name=""cmdShow"" value=""Yes""></td>" & vbcrlf & "                           "
	n=0
	Dim cellcount , cellid() ,cellsalaryClass(),cellintro(), cellisTax()
	set rs7=server.CreateObject("adodb.recordset")
	sql7="select id,sort1,intro,isnull(deductible,0)deductible,salaryClass, (case when charindex('{个人所得税}',salaryClass)>0 then 'YesTax' when charindex('{年终奖所得税}',salaryClass)>0 then 'NzjTax' when charindex('{年终奖}',salaryClass)>0 then 'NzjMoney' else 'NoTax' end) as isTax from sortwages where 1=1 "&sql_Salary&" order by gate1 desc,sort1 asc, id asc"
	rs7.open sql7,conn,1,1
	cellcount = rs7.recordcount-1
	ReDim cellid(cellcount), cellsalaryClass(cellcount) , cellintro(cellcount) , cellisTax(cellcount)
	do until rs7.eof
		Response.write "" & vbcrlf & "                                     <td colspan=""2"" width=""90""><div align=""center"">"
		Response.write rs7("sort1")
		Response.write "<input deductible="""
		Response.write rs7("deductible")
		Response.write """ name="""
		Response.write "p_" & n
		Response.write """ id="""
		Response.write "p_" & n
		Response.write """   type=""hidden"" size=""7""   value="""
		Response.write rs7("intro")
		Response.write """><input name="""
		Response.write "sort_" & n
		Response.write """  id="""
		Response.write "sort_" & n
		Response.write """  type=""hidden"" size=""7""   value="""
		Response.write rs7("id")
		Response.write """></div></td>" & vbcrlf & "                                     "
		cellsalaryClass(n) =rs7("salaryClass")
		cellintro(n) = rs7("intro")
		cellisTax(n) = rs7("isTax")
		cellid(n) = rs7("id")
		n=n+1
		cellid(n) = rs7("id")
		rs7.movenext
	loop
	rs7.close
	set rs7=nothing
	Response.write "" & vbcrlf & "                <td width=""90""><div align=""center""><span style=""width:60px; display:block"">子女教育</span></div></td>" & vbcrlf & "                <td width=""90""><div align=""center""><span style=""width:60px; display:block"">继续教育(学历)</span></div></td>" & vbcrlf & "          <td width=""90""><div align=""center""><span style=""width:60px; display:block"">继续教育(技能)</span></div></td>" & vbcrlf & "                <td width=""90""><div align=""center""><span style=""width:60px; display:block"">大病医疗</span></div></td>" & vbcrlf & "                <td width=""90""><div align=""center""><span style=""width:60px; display:block"">住房贷款</span></div></td>" & vbcrlf & "                <td width=""90""><div align=""center""><span style=""width:60px; display:block"">住房租金</span></div></td>" & vbcrlf & "                <td width=""90""><div align=""center""><span style=""width:60px; display:block"">赡养老人</span></div></td>" & vbcrlf & "                         <td width=""90""><div align=""center""><span style=""width:66px; display:block"">婴幼儿照护</span></div></td>" & vbcrlf & "                               <td width=""90""><div align=""center""><span style=""width:60px; display:block"">应发工资</span></div></td>" & vbcrlf &"                         <td width=""90""><div align=""center""><span style=""width:60px; display:block"">应扣工资</span></div></td>" & vbcrlf & "                         <td width=""90""><div align=""center""><span style=""width:60px; display:block"">实发工资</span></div></td>" & vbcrlf & "                         <td width=""100""><div align=""center"">备注</div></td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
	set rs1=server.CreateObject("adodb.recordset")
	If CDate(s_TdEndDay)>Date() Then s_TdEndDay=Date()
	if qy&""="" then qy = 0
	Dim mlist : Set mlist = conn.execute("exec [HrGetSalarylist] '"&s_tdDay1&"','"&s_TdEndDay&"',"& Cid &",'', "& qy &"")
	if open_10_13= 3 then
		sql1="select ord,name,isnull(ChildrenseDucation,0)ChildrenseDucation,isnull(ContinuingEducationxl,0)ContinuingEducationxl,isnull(ContinuingEducationjn,0)ContinuingEducationjn,isnull(medical,0)medical,isnull(Housingloans,0)Housingloans,isnull(payment,0)payment,isnull(SupportOldPeople,0)SupportOldPeople,isnull(InfantCare,0)InfantCare from gate_person left join hr_person hr on hr.userID=gate_person.ord where dbo.HrIsShowGate('"&s_TdEndDay&"',ord)=1 "&sql_uid&" and gate_person.nowStatus<>4 and gate_person.nowStatus<>2  and hr.del=0 and gate_person.contractEnd>='"&date&"' and gate_person.contractStart<='"&date&"'  order by ord asc"
	else
		if cstr(intro_10_13) = "0" then
			sql1="select ord,name,isnull(ChildrenseDucation,0)ChildrenseDucation,isnull(ContinuingEducationxl,0)ContinuingEducationxl,isnull(ContinuingEducationjn,0)ContinuingEducationjn,isnull(medical,0)medical,isnull(Housingloans,0)Housingloans,isnull(payment,0)payment,isnull(SupportOldPeople,0)SupportOldPeople,isnull(InfantCare,0)InfantCare from gate_person left join hr_person hr on hr.userID=gate_person.ord  where 1=0 and gate_person.nowStatus<>4 and gate_person.nowStatus<>2 and hr.del=0  and gate_person.contractEnd>='"&date&"' and gate_person.contractStart<='"&date&"' order by ord asc"
		else
			sql1="select ord,name,isnull(ChildrenseDucation,0)ChildrenseDucation,isnull(ContinuingEducationxl,0)ContinuingEducationxl,isnull(ContinuingEducationjn,0)ContinuingEducationjn,isnull(medical,0)medical,isnull(Housingloans,0)Housingloans,isnull(payment,0)payment,isnull(SupportOldPeople,0)SupportOldPeople,isnull(InfantCare,0)InfantCare from gate_person left join hr_person hr on hr.userID=gate_person.ord  where  ord in ("&intro_10_13&") "&sql_uid&" and  dbo.HrIsShowGate('"&s_TdEndDay&"',ord)=1 and gate_person.nowStatus<>4 and gate_person.nowStatus<>2 and gate_person.contractEnd>='"&date&"' andhr.del=0  and gate_person.contractStart<='"&date&"' order by ord asc"
		end if
	end if
	rs1.open sql1,conn,1,1
	if not rs1.eof then
		i=0
		do until rs1.eof
			Response.write "" & vbcrlf & "                                     <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"" id=""row_"
			Response.write i
			Response.write """>" & vbcrlf & "                                        <td><div align=""center"">"
			Response.write rs1("name")
			Response.write "<input name=""name_"
			Response.write i
			Response.write """ id=""name_"
			Response.write i
			Response.write """ type=""hidden"" value="""
			Response.write rs1("ord")
			Response.write """></div></td>" & vbcrlf & "                                     "
			j=0
			For j =0 To ubound(cellsalaryClass)
				salaryClass = cellsalaryClass(j)
				intro = cellintro(j)
				isTax = cellisTax(j)
				sortid = cellid(j)
				if salaryClass<>""  Then
					thisMoney = 0
					mlist.Filter = " ord= "& rs1("ord") &" and id="& sortid
					If mlist.eof = False Then thisMoney = mlist("v")
					if isnumeric(thisMoney)=false then thisMoney=0
					money1=cdbl(Formatnumber((thisMoney),num_dot_xs,-1))
					if isnumeric(thisMoney)=false then thisMoney=0
				else
					money1=cdbl(Formatnumber(0,num_dot_xs,-1))
					if isnumeric(thisMoney)=false then thisMoney=0
				end if
				if cdbl(money1)<>cdbl(Formatnumber(money1,num_dot_xs,-1)) then
					if isnumeric(thisMoney)=false then thisMoney=0
					money1=Formatnumber(money1,num_dot_xs,-1)
					if isnumeric(thisMoney)=false then thisMoney=0
				end if
				if intro=1 then
					money2=cdbl(money2)+cdbl(cdbl(money1)*intro)
'if intro=1 then
				elseif intro=-1 then
'if intro=1 then
					money3=cdbl(money3)-cdbl(cdbl(money1)*clng(intro))
'if intro=1 then
				end if
				money4=cdbl(money4)+cdbl(cdbl(money1)*intro)
'if intro=1 then
				Response.write "" & vbcrlf & "                                             <td colspan=""2"" >" & vbcrlf & "                                         <div align=""center"">" & vbcrlf & "                                                      "
				Response.write iif(instr(salaryClass,"{生产计件工资}")>0 Or instr(salaryClass,"{生产计时工资}")>0 Or instr(salaryClass,"{奖罚金额}")>0,FormatNumber(money1,num_dot_xs,-1),"")
				Response.write "" & vbcrlf & "                                                     <input name="""
				Response.write "Q_"& i&"_"&j
				Response.write """  id="""
				Response.write "Q_"& i&"_"&j&"_"&isTax
				Response.write """ " & vbcrlf & "                                                        type="""
				Response.write iif(instr(salaryClass,"{生产计件工资}")>0 Or instr(salaryClass,"{生产计时工资}")>0 Or instr(salaryClass,"{奖罚金额}")>0,"hidden","text")
				Response.write """" & vbcrlf & "                                                 value="""
				Response.write FormatNumber(money1,num_dot_xs,-1,0,0)
				'Response.write """" & vbcrlf & "                                                 value="""
				Response.write """ size=""7""  onpropertychange=""formatData(this,'money');"" onKeyUp=""checkDot('"
				Response.write "Q_" & i&"_"&j&"_"&isTax
				Response.write "','"
				Response.write num_dot_xs
				Response.write "')""                                                                       " & vbcrlf & "                                                        dataType=""Limit"" min=""1"" max=""15"" maxlength=""15""  msg=""金额不能为空并在15位之内"" "
				if money1=0 Then
					Response.write "" & vbcrlf & "                                                             onfocus=""if(value==defaultValue){value='';this.style.color='#000'}"" onblur=""getcount("
					Response.write i
					Response.write ");if(!value){value=defaultValue;this.style.color='#000'}""" & vbcrlf & "                                                         "
				else
					Response.write "" & vbcrlf & "                                                             onBlur=""getcount("
					Response.write i
					Response.write ")""" & vbcrlf & "                                                                "
				end if
				Response.write ">" & vbcrlf & "                                                    <input type=""hidden"" name=""salaryClassText_"
				Response.write i
				Response.write "_"
				Response.write j
				Response.write """ value="""
				Response.write salaryClass
				Response.write """/>" & vbcrlf & "                                                       "
				If instr(salaryClass,"{年终奖}")>0 Then
					Response.write "" & vbcrlf & "                                                             <input type=""hidden"" id=""catenzj_"
					Response.write rs1("ord")
					Response.write """ value="""
					Response.write "Q_"& i&"_"&j&"_"&isTax
					Response.write """/>" & vbcrlf & "                                                       "
				end if
				If instr(salaryClass,"{生产计件工资}")>0 Or instr(salaryClass,"{生产计时工资}")>0 Or instr(salaryClass,"{奖罚金额}")>0 Then
					Response.write "" & vbcrlf & "                                                             <input type=""hidden"" name=""oriMoney_"
					Response.write i&"_"&j
					Response.write """ value="""
					Response.write money1
					Response.write """/>" & vbcrlf & "                                                       "
				end if
				Response.write "" & vbcrlf & "                                             </div>" & vbcrlf & "                                          </td>" & vbcrlf & "                                           "
			next
			Response.write "" & vbcrlf & "                     <td>" & vbcrlf & "                        <div align=""center"">" & vbcrlf & "                        <input   name="""
			Response.write "Q_"& i&"_"&"1000"
			Response.write """ id="""
			Response.write "Q_"& i&"_"&"ChildrenseDucation"
			Response.write """ size=""7"" onpropertychange=""formatData(this,'money')""  onKeyUp=""checkDot('"
			'Response.write "Q_"& i&"_"&"ChildrenseDucation"
			Response.write "','"
			Response.write num_dot_xs
			Response.write "')"" dataType=""Limit"" min=""1"" max=""15"" maxlength=""15"" onBlur=""getcount("
			Response.write i
			Response.write ")""   value="""
			Response.write Formatnumber(rs1("ChildrenseDucation"),num_dot_xs,-1,0,0)
			'Response.write ")""   value="""
			Response.write """ msg=""金额不能为空并在15位之内"" >" & vbcrlf & "                        </div>" & vbcrlf & "                    </td>" & vbcrlf & "                     <td>" & vbcrlf & "                        <div align=""center"">" & vbcrlf & "                        <input   name="""
			Response.write "Q_"& i&"_"&"1001"
			Response.write """ id="""
			Response.write "Q_"& i&"_"&"ContinuingEducationxl"
			Response.write """ size=""7"" onpropertychange=""formatData(this,'money')""  onKeyUp=""checkDot('"
			'Response.write "Q_"& i&"_"&"ContinuingEducationxl"
			Response.write "','"
			Response.write num_dot_xs
			Response.write "')"" dataType=""Limit"" min=""1"" max=""15"" maxlength=""15"" onBlur=""getcount("
			Response.write i
			Response.write ")""  value="""
			Response.write Formatnumber(rs1("ContinuingEducationxl"),num_dot_xs,-1,0,0)
			Response.write ")""  value="""
			Response.write """ msg=""金额不能为空并在15位之内"" >" & vbcrlf & "                        </div>" & vbcrlf & "                    </td>" & vbcrlf & "                    <td>" & vbcrlf & "                        <div align=""right"">" & vbcrlf & "                        <input   name="""
			Response.write "Q_"& i&"_"&"1002"
			Response.write """ id="""
			Response.write "Q_"& i&"_"&"ContinuingEducationjn"
			Response.write """ size=""7"" onpropertychange=""formatData(this,'money')""  onKeyUp=""checkDot('"
			'Response.write "Q_"& i&"_"&"ContinuingEducationjn"
			Response.write "','"
			Response.write num_dot_xs
			Response.write "')"" dataType=""Limit"" min=""1"" max=""15"" maxlength=""15""  onBlur=""getcount("
			Response.write i
			Response.write ")"" value="""
			Response.write Formatnumber(rs1("ContinuingEducationjn"),num_dot_xs,-1,0,0)
			'Response.write ")"" value="""
			Response.write """ msg=""金额不能为空并在15位之内"" >" & vbcrlf & "                        </div>" & vbcrlf & "                    </td>" & vbcrlf & "                    <td>" & vbcrlf & "                        <div align=""center"">" & vbcrlf & "                        <input   name="""
			Response.write "Q_"& i&"_"&"1003"
			Response.write """ id="""
			Response.write "Q_"& i&"_"&"medical"
			Response.write """ size=""7"" onpropertychange=""formatData(this,'money')""  onKeyUp=""checkDot('"
			'Response.write "Q_"& i&"_"&"medical"
			Response.write "','"
			Response.write num_dot_xs
			Response.write "')"" dataType=""Limit"" min=""1"" max=""15"" maxlength=""15""  onBlur=""getcount("
			Response.write i
			Response.write ")"" value="""
			Response.write Formatnumber(rs1("medical"),num_dot_xs,-1,0,0)
			'Response.write ")"" value="""
			Response.write """ msg=""金额不能为空并在15位之内"" >" & vbcrlf & "                        </div>" & vbcrlf & "                    </td>" & vbcrlf & "                    <td>" & vbcrlf & "                        <div align=""center"">" & vbcrlf & "                        <input   name="""
			Response.write "Q_"& i&"_"&"1004"
			Response.write """ id="""
			Response.write "Q_"& i&"_"&"Housingloans"
			Response.write """ size=""7"" onpropertychange=""formatData(this,'money')""  onKeyUp=""checkDot('"
			'Response.write "Q_"& i&"_"&"Housingloans"
			Response.write "','"
			Response.write num_dot_xs
			Response.write "')"" dataType=""Limit"" min=""1"" max=""15"" maxlength=""15""  onBlur=""getcount("
			Response.write i
			Response.write ")"" value="""
			Response.write Formatnumber(rs1("Housingloans"),num_dot_xs,-1,0,0)
			'Response.write ")"" value="""
			Response.write """ msg=""金额不能为空并在15位之内"" >" & vbcrlf & "                        </div>" & vbcrlf & "                    </td>" & vbcrlf & "                    <td>" & vbcrlf & "                        <div align=""center"">" & vbcrlf & "                        <input   name="""
			Response.write "Q_"& i&"_"&"1005"
			Response.write """ id="""
			Response.write "Q_"& i&"_"&"payment"
			Response.write """ size=""7"" onpropertychange=""formatData(this,'money')""  onKeyUp=""checkDot('"
			'Response.write "Q_"& i&"_"&"payment"
			Response.write "','"
			Response.write num_dot_xs
			Response.write "')"" dataType=""Limit"" min=""1"" max=""15"" maxlength=""15"" onBlur=""getcount("
			Response.write i
			Response.write ")""  value="""
			Response.write Formatnumber(rs1("payment"),num_dot_xs,-1,0,0)
			'Response.write ")""  value="""
			Response.write """ msg=""金额不能为空并在15位之内"" >" & vbcrlf & "                        </div>" & vbcrlf & "                    </td>" & vbcrlf & "                    <td>" & vbcrlf & "                        <div align=""center"">" & vbcrlf & "                        <input   name="""
			Response.write "Q_"& i&"_"&"1006"
			Response.write """ id="""
			Response.write "Q_"& i&"_"&"SupportOldPeople"
			Response.write """ size=""7"" onpropertychange=""formatData(this,'money')""  onKeyUp=""checkDot('"
			'Response.write "Q_"& i&"_"&"SupportOldPeople"
			Response.write "','"
			Response.write num_dot_xs
			Response.write "')"" dataType=""Limit"" min=""1"" max=""15"" maxlength=""15""  onBlur=""getcount("
			Response.write i
			Response.write ")"" value="""
			Response.write Formatnumber(rs1("SupportOldPeople"),num_dot_xs,-1,0,0)
			'Response.write ")"" value="""
			Response.write """ msg=""金额不能为空并在15位之内"" >" & vbcrlf & "                        </div>" & vbcrlf & "                    </td>" & vbcrlf & "                                   <td>" & vbcrlf & "                        <div align=""center"">" & vbcrlf & "                        <input   name="""
			Response.write "Q_"& i&"_"&"1007"
			Response.write """ id="""
			Response.write "Q_"& i&"_"&"InfantCare"
			Response.write """ size=""7"" onpropertychange=""formatData(this,'money')""  onKeyUp=""checkDot('"
			'Response.write "Q_"& i&"_"&"InfantCare"
			Response.write "','"
			Response.write num_dot_xs
			Response.write "')"" dataType=""Limit"" min=""1"" max=""15"" maxlength=""15""  onBlur=""getcount("
			Response.write i
			Response.write ")"" value="""
			Response.write iif(tdyear < 2022,0,Formatnumber(rs1("InfantCare"),num_dot_xs,-1,0,0))
			'Response.write ")"" value="""
			Response.write """ msg=""金额不能为空并在15位之内"" "
			if tdyear < 2022 then Response.write "disabled"
			Response.write ">" & vbcrlf & "                        </div>" & vbcrlf & "                    </td>" & vbcrlf & "                                       <td><div align=""right"" id=""yf_all_"
			Response.write i
			Response.write """>"
			Response.write Formatnumber(money2,num_dot_xs,-1)
			'Response.write """>"
			Response.write "</div></td>" & vbcrlf & "                                   <td><div align=""right"" id=""yk_all_"
			Response.write i
			Response.write """>"
			Response.write Formatnumber(money3,num_dot_xs,-1)
			'Response.write """>"
			Response.write "</div></td>" & vbcrlf & "                                   <td><div align=""right"" id=""sj_all_"
			Response.write i
			Response.write """>"
			Response.write Formatnumber(money4,num_dot_xs,-1)
			'Response.write """>"
			Response.write "</div></td>" & vbcrlf & "                                   "
			If Request("cmdShow") = "Yes" Then
				intro= request("intro_" & i)
			else
				intro=""
			end if
			Response.write "" & vbcrlf & "                                      <td>" & vbcrlf & "                                    <div align=""center"">" & vbcrlf & "                                      <input name="""
			Response.write "intro_"&i
			Response.write """ id="""
			'Response.write "intro_"&i
			Response.write """ type=""text"" size=""12"" dataType=""Limit"" max=""500"" maxlength=""500"" msg=""备注长度不能超过500个字"" value="""
			Response.write intro
			Response.write """ >" & vbcrlf & "                                        </div>" & vbcrlf & "                                  </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   <script language=""javascript"">getcount("
			Response.write i
			Response.write ")</script>" & vbcrlf & "                                    "
			money1=0
			money2=0
			money3=0
			money4=0
			intro=""
			i=i+1
			intro=""
			rs1.movenext
		Loop
		ss=1
	else
		ss=0
	end if
	rs1.close
	set rs1=nothing
	Response.write "" & vbcrlf & "          <input name=""j""  type=""hidden"" size=""7""   value="""
	Response.write j-1
	'Response.write "" & vbcrlf & "          <input name=""j""  type=""hidden"" size=""7""   value="""
	Response.write """>" & vbcrlf & "          <input name=""i""  type=""hidden"" size=""7""   value="""
	Response.write i-1
	'Response.write """>" & vbcrlf & "          <input name=""i""  type=""hidden"" size=""7""   value="""
	Response.write """>" & vbcrlf & "        </table>" & vbcrlf & "    </div>" & vbcrlf & "         </td>" & vbcrlf & "    </tr>" & vbcrlf & "    <tr>" & vbcrlf & "      <td class=""page"">" & vbcrlf & "           <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "          <tr><td height=""30"" ><div align=""center"">" & vbcrlf & "               "
	If ss=1 Then
		Response.write "" & vbcrlf & "                                      <input type=""button"" name=""Submit40"" onclick=""ask2();"" value=""暂存""  class=""page""/>" & vbcrlf & "                                       <input type=""button"" name=""Submit42"" onclick=""ask();"" value=""保存""  class=""page""/>" & vbcrlf & "                                        <input type=""reset"" value=""重填"" class=""page"" name=""B2"">" & vbcrlf & "                                    "
	else
		If salaryClass<>0 then Response.write "系统找不到应用该账套的员工!"
	end if
	Response.write "" & vbcrlf & "              </div></td>" & vbcrlf & "          </tr>" & vbcrlf & "                      <tr><td height=""30""  style=""padding:0px""><div class=""bgfff"" style=""padding:0px 0px 12px 10px;"">温馨提示：工资月份考勤未存档，将导致无法调取考勤相关数据，请先将考勤存档；</div></td></tr>" & vbcrlf & "        </table>" & vbcrlf & "         </td>"& vbcrlf & "    </tr>" & vbcrlf & "</table>" & vbcrlf & "</form>" & vbcrlf & ""
	Function hasNzjItem(salaryList)
		Dim ret : ret = False
		If salaryList&""<>"" Then
			Dim rs
			Set rs = conn.execute("select top 1 1 from sortwages where id in("& salaryList &") and salaryClass like '%{年终奖}%'")
			If rs.eof = False Then
				ret = True
			end if
			rs.close
			set rs = nothing
		end if
		hasNzjItem = ret
	end function
	Sub getImportBonus()
		Dim rs, tempStr
		tempStr = ""
		Set rs = conn.execute("select cateid,money1 from wageslist_bonus where addcate="& session("personzbintel2007") )
		While rs.eof = False
			If tempStr&""<>"" Then tempStr = tempStr & "|"
			tempStr = tempStr & rs("cateid") & ":" & rs("money1")
			rs.movenext
		wend
		rs.close
		set rs = nothing
		conn.execute("delete from wageslist_bonus where addcate="& session("personzbintel2007") )
		Response.write tempStr
	end sub
	Sub getImportWages()
		Dim rs, tempStr
		tempStr = ""
		Set rs = conn.execute("select postdata from Wageslist_Importdata where addcate="& session("personzbintel2007") )
		While rs.eof = False
			tempStr =  rs("postdata")
			rs.movenext
		wend
		rs.close
		set rs = nothing
		conn.execute("delete from Wageslist_Importdata where addcate="& session("personzbintel2007") )
		Response.write tempStr
	end sub
	action1="编制工资表"
	call close_list(1)
	Response.write "" & vbcrlf & "</body>" & vbcrlf & "</html>"
	
%>
