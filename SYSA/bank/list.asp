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
		Response.write "" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "        var getIEVer = function () {" & vbcrlf & "            var browser = navigator.appName;" & vbcrlf & "                if(window.ActiveXObject && top.document.compatMode==""BackCompat"") {return 5;}" & vbcrlf & "             var b_version = navigator.appVersion;" & vbcrlf & "             var version = b_version.split("";"");" & vbcrlf & "               if(document.documentMode && isNaN(document.documentMode)==false) { return document.documentMode; }" & vbcrlf & "              if (window.ActiveXObject) {" & vbcrlf & "                     var v = version[1].replace(/[ ]/g, """");" & vbcrlf & "                   if (v == ""MSIE10.0"") {return 10;}" & vbcrlf & "                        if (v == ""MSIE9.0"") {return 9;}" & vbcrlf & "                   if (v == ""MSIE8.0"") {return 8;}" & vbcrlf & "                   if (v == ""MSIE7.0"") {return 7;}" & vbcrlf & "                   if (v == ""MSIE6.0"") {return 6;}" & vbcrlf & "                   if (v == ""MSIE5.0"") {return 5;" & vbcrlf & "                    } else {return 11}" &vbcrlf & "         }" & vbcrlf & "               else {" & vbcrlf & "                  return 100;" & vbcrlf & "             }" & vbcrlf & "       };" & vbcrlf & "      try{ document.getElementsByTagName(""html"")[0].className = ""IE"" + getIEVer() ; } catch(exa){}" & vbcrlf & "        window.uizoom = "
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
	
	dim open_11_1,intro_11_1,kh_list
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=11 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_11_1=0
		intro_11_1=0
	else
		open_11_1=rs1("qx_open")
		intro_11_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=11 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_11_14=0
		intro_11_14=0
	else
		open_11_14=rs1("qx_open")
		intro_11_14=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=11 and sort2=2"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_11_2=0
		intro_11_2=0
	else
		open_11_2=rs1("qx_open")
		intro_11_2=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=11 and sort2=3"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_11_3=0
		intro_11_3=0
	else
		open_11_3=rs1("qx_open")
		intro_11_3=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=11 and sort2=7"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_11_7=0
		intro_11_7=0
	else
		open_11_7=rs1("qx_open")
		intro_11_7=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=11 and sort2=8"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_11_8=0
		intro_11_8=0
	else
		open_11_8=rs1("qx_open")
		intro_11_8=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=11 and sort2=10"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_11_10=0
		intro_11_10=0
	else
		open_11_10=rs1("qx_open")
		intro_11_10=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=11 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_11_13=0
		intro_11_13=0
	else
		open_11_13=rs1("qx_open")
		intro_11_13=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	if open_11_1=3 then
		list=""
	elseif open_11_1=1 then
		list="and cateid in ("&intro_11_1&")"
	else
		list="and cateid=0"
	end if
	dim rs,sql,Str_Result,Str_Result2
	Str_Result="where del=1  "&list&""
	Str_Result2="and del=1  "&list&""
	
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
	
	Dim IF_BZ_OPEN
	IF_BZ_OPEN=getsetbz
	function gethl(Byval idstr,Byval typestr)
		if isnul(idstr) then gethl=1 : exit function
		dim isbz
		isbz = IF_BZ_OPEN
		if isbz = 0 then gethl=1 : exit function
		dim hl
		select case typestr
		case "wages"
		hl = getrsval("select hl from hl inner join wages on wages.bz=hl.bz and wages.date1=hl.date1  where wages.id ="&idstr)
		case "bank"
		hl = getrsval("select hl from hl inner join sortbank on sortbank.bz=hl.bz and hl.date1='"&date&"'  where sortbank.id ="&idstr)
		case "chance"
		hl =getrsval("select hl from hl inner join chance on chance.bz=hl.bz and chance.date1=hl.date1  where chance.ord="&idstr)
		case "contract"
		hl = getrsval("select hl from hl inner join contract on contract.bz=hl.bz and datediff(d,contract.date3,hl.date1)=0 where contract.ord="&idstr)
		case "caigou"
		hl = getrsval("select hl from hl inner join caigou on caigou.bz=hl.bz and datediff(d,caigou.date3,hl.date1)=0 where caigou.ord="&idstr)
		case "ZDWW", "GXWW"
		hl = getrsval("select h.hl from hl h inner join M2_OutOrder on M2_OutOrder.bz=h.bz and datediff(d,M2_OutOrder.odate,h.date1)=0 where M2_OutOrder.id="&idstr)
		case "WWD"
		hl = 1
		case "contractth"
		hl = getrsval("select hl from hl inner join contractth on contractth.bz=hl.bz and contractth.date3=hl.date1  where contractth.ord="&idstr)
		case "bzid"
		hl = getrsval("select hl from hl where bz="&idstr)
		end select
		if isnul(hl) then hl = 1
		gethl = hl
	end function
	function getye(byval company)
		if isnul(company) then getye = 0 : exit function
		dim rsobj
		set rsobj = conn.execute ("select isnull(money1,0) as money1,bz from telbank where company="&company&" and del=1")
		while not  rsobj.eof
			money_ye =   money_ye+(rsobj("money1")*cdbl(gethl(rsobj("bz"),"bzid")))
'while not  rsobj.eof
			rsobj.movenext
		wend
		rsobj.close : set rsobj = nothing
		if isnul(money_ye) then money_ye = 0
		getye = money_ye
	end function
	function getgatearray(byval oid)
		dim rs
		set rs = conn.execute ("select name  ,(select  sort1 from gate1 where id = sorce) as sorce1cn, (select  sort2 from gate2 where sort1=sorce and  id = sorce2) as sorce2cn ,sorce,sorce2 from gate where  ord = "&oid)
		if not rs.eof then
			getgatearray = rs.getrows
		end if
		rs.close
		set rs = nothing
	end function
	function getsetbz
		dim setbz
		setbz = getrsval("select top 1 bz from setbz")
		if isnul(setbz) then setbz = 0
		getsetbz = setbz
	end function
	dim setbzflag
	setbzflag = getsetbz
	function getbzflag(byval strid,byval typestr)
		if isnul(strid) then getbzflag="" : exit function
		select case typestr
		case "bankname"
		getbzflag = getrsval("select top 1 intro from sortbz where id = (select top 1 bz from sortbank where sort1 ='"&strid&"')")
		case "bankid"
		getbzflag = getrsval("select top 1 intro from sortbz where id = (select top 1 bz from sortbank where id ='"&strid&"')")
		case "caigouid"
		getbzflag = getrsval("select top 1 intro from sortbz where id = (select top 1 bz from caigou where ord ="&strid&")")
		case "contractid"
		getbzflag = getrsval("select top 1 intro from sortbz where id = (select top 1 bz from contract where ord ="&strid&")")
		case "bzid"
		getbzflag = getrsval("select top 1 intro from sortbz where id ="&strid)
		case "wagesid"
		getbzflag = getrsval("select top 1 intro from sortbz where id = (select top 1 bz from wages where id ="&strid&")")
		case "contractthid"
		getbzflag = getrsval("select top 1 intro from sortbz where id = (select top 1 bz from contractth where ord ="&strid&")")
		Case "M_OutOrderid"
		getbzflag = getrsval("select top 1 intro from sortbz where id =14")
		Case "M2_OutOrderid"
		getbzflag = getrsval("select top 1 intro from sortbz where id = (select top 1 bz from M2_OutOrder where id ="&strid&")")
		end select
	end function
	function getbankhtml(byval bankid,byval cateid)
		if IsNull(bankid) or bankid="" then
			Response.write ""
		else
			dim rsobj
			set rsobj = conn.execute ("select * from sortbank where id="&bankid)
			if rsobj.eof then
				Response.write ""
				rsobj.close
				set rsobj = nothing
			else
				if IsNull(cateid) or cateid="" then
					Response.write rsobj("sort1")
				else
					if instr(","&rsobj("person")&",","," & cateid & ",")>0 then
						Response.write rsobj("sort1")
					else
						Response.write ""
					end if
				end if
				rsobj.close
				set rsobj = nothing
			end if
		end if
	end function
	function getbz(byval idstr,byval typeid)
		if isnull(idstr) then getbz = 14 : exit function
		select case typeid
		case "bankid"
		bz=14
		bz = getrsval("select top 1  bz from sortbank where id="&idstr)
		if isnull(bz) then bz = 14
		end select
		getbz = bz
	end function
	function getbankye(byval bankid)
		dim sqlstr
		sqlstr  = "select (isnull(sum(money1),0)- isnull(sum(money2),0)) as money1 from bank where del=1 and bank="&bankid
'dim sqlstr
		getbankye = getrsval(sqlstr)
		if isnul(getbankye) then getbankye = 0
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
	
	dim MODULES
	MODULES=session("zbintel2010ms")
	dim id
	if request("id")<>"" then
		id=request("id")
	end if
	from = Request("from")
	m1=request("ret")
	m2=request("ret2")
	B=request("B")
	C=request("C")
	D=request("D")
	if B="" or IsNull(B) then
		B=0
	end if
	Str_Result=""
	if id<>"" and id>0 then
		Str_Result=Str_Result+" and bank="&id&" "
'if id<>"" and id>0 then
	end if
	px=request.QueryString("px")
	if px<>1 then
		if m1="" then
			m1=cdate(year(date)&"-"&month(date)&"-1")
'if m1="" then
		end if
	end if
	If from = "chart" Then
		m1 = ""
	end if
	if px<>1 then
		if m2="" then
			m2=date
		end if
	end if
	if B<>"0" then
		Str_Result=Str_Result+" and sort in("&B&") "
'if B<>"0" then
	end if
	if C<>"" then
		if D="jsr" then
			Str_Result=Str_Result+" and cateid in (select ord from gate where name like '%"&C&"%') "
'if D="jsr" then
		end if
	end if
	if not ZBRuntime.MC(23001) then
		Str_Result=Str_Result+" and sort<>1 and sort<>101 and sort<>102 "
'if not ZBRuntime.MC(23001) then
	end if
	if not ZBRuntime.MC(24001) then
		Str_Result=Str_Result+" and sort<>2 and sort<>202 and sort<>201 "
'if not ZBRuntime.MC(24001) then
	end if
	if not ZBRuntime.MC(26000) then
		Str_Result=Str_Result+" and sort<>3 "
'if not ZBRuntime.MC(26000) then
	end if
	if not ZBRuntime.MC(27000) then
		Str_Result=Str_Result+" and sort<>4 and sort<>40 and sort<>50 "
'if not ZBRuntime.MC(27000) then
	end if
	if not ZBRuntime.MC(22000) then
		Str_Result=Str_Result+" and sort<>5 and sort<>6 "
'if not ZBRuntime.MC(22000) then
	end if
	if not ZBRuntime.MC(21000) then
		Str_Result=Str_Result+" and sort<>7 "
'if not ZBRuntime.MC(21000) then
	end if
	if not ZBRuntime.MC(25001) then
		Str_Result=Str_Result+" and sort<>8 "
'if not ZBRuntime.MC(25001) then
	end if
	if not ZBRuntime.MC(23002) then
		Str_Result=Str_Result+" and sort<>9 and sort<>13 "
'if not ZBRuntime.MC(23002) then
	end if
	if not ZBRuntime.MC(20000) then
		Str_Result=Str_Result+" and sort<>10 "
'if not ZBRuntime.MC(20000) then
	end if
	if not ZBRuntime.MC(24002) then
		Str_Result=Str_Result+" and sort<>11 and sort<>12 "
'if not ZBRuntime.MC(24002) then
	end if
	if not ZBRuntime.MC(25002) then
		Str_Result=Str_Result+" and sort<>14 "
'if not ZBRuntime.MC(25002) then
	end if
	if not ZBRuntime.MC(20001) Then
		Str_Result=Str_Result+" and sort<>301 and sort<>302 and sort<>303  "
'if not ZBRuntime.MC(20001) Then
	end if
	W1=replace(request("W1")," ","")
	W2=replace(request("W2")," ","")
	W3=replace(request("W3")," ","")
	if W1="" then W1=0
	if W2="" then W2=0
	if W3="" then W3=0
	W3=getW3(W1,W2,W3)
	W3=getLimitedW3(W3,2,4,0,session("personzbintel2007"))
	W4=replace(W3,"0","")
	W4=replace(W4,",","")
	if W4<>"" Then
		tmp=split(getW1W2(W3),";")
		W1=tmp(0)
		W2=tmp(1)
		Str_Result=Str_Result+" and  cateid in("& W3 &")"
		W2=tmp(1)
	end if
	if Request("bankname")<>"" then
		str_Result=str_Result+" and bank in (select id from sortbank where sort1 like '%"& request("bankname") &"%')"
'if Request("bankname")<>"" then
	end if
	if  Request("duepaydate1")<>"" and Request("duepaydate2")<>"" then
		m1=request("duepaydate1")
		m2=request("duepaydate2")
	end if
	if  Request("duemoney1")<>"" and Request("duemoney2")<>"" then
		str_Result=str_Result+" and money1 between "&Request("duemoney1")&" and "&Request("duemoney2")&""
'if  Request("duemoney1")<>"" and Request("duemoney2")<>"" then
	end if
	if  Request("duemoney3")<>"" and Request("duemoney4")<>"" then
		str_Result=str_Result+" and isnull(money2,0) between "&Request("duemoney3")&" and "&Request("duemoney4")&""
'if  Request("duemoney3")<>"" and Request("duemoney4")<>"" then
	end if
	intro=request("intro")
	if intro<>"" then
		if request("glcz")<>"" then
			str_Result=str_Result+" and sort in ("& intro &") and ((gl in (select ord from contract where title like '%"&request("glcz")&"%') and sort=1) or (gl in (select ord from caigou where title like '%"&request("glcz")&"%') and sort=2) or (gl in (select id from wages where title like '%"&request("glcz")&"%') and sort=3) or (gl in (select ord from pay where sort like '%"&request("glcz")&"%') and sort=4) or (gl in (select id from bankmove where title like '%"&request("glcz")&"%') and (sort=5 or sort=6)) or (gl in (select id from bankin where title like '%"&request("glcz")&"%') and sort=7) or (gl in (select ord from contractth where title like '%"&request("glcz")&"%') and sort=8) or (gl in (select id from bankin2 where company in (select ord from tel where sort3=1 and name like '%"&request("glcz")&"%')) and sort=9) or (gl in (select id from bankout where title like '%"&request("glcz")&"%') and sort=10) or (gl in (select id from bankout2 where company in (select ord from tel where sort3=2 and name like '%"&request("glcz")&"%')) and sort=11) or (gl in (select id from bankout3 where company in (select ord from tel where sort3=2 and name like '%"&request("glcz")&"%')) and sort=12) or (gl in (select id from bankin3 where company in (select ord from tel where sort3=1 and name like '%"&request("glcz")&"%')) and sort=13) or (gl in (select id from M_OutOrder where title like '%"&request("glcz")&"%') and sort=15) or (gl in (select id from paybx where title like '%"&request("glcz")&"%') and sort=40)or (gl in (select id from AcceptanceDraft where SN like '%"&request("glcz")&"%') and sort IN (301,302,303)) or (gl in (select id from PayoutSure where title like '%"&request("glcz")&"%') and sort IN (201,202)) or (gl in (select id from PayBackSure where title like '%"&request("glcz")&"%') and sort IN (101,102))  ) "
		else
			str_Result=str_Result+" and sort in ("& intro &") "
		end if
	else
		if request("glcz")<>"" then
			str_Result=str_Result+" and ((gl in (select ord from contract where title like '%"&request("glcz")&"%') and sort=1) or (gl in (select ord from caigou where title like '%"&request("glcz")&"%') and sort=2) or (gl in (select id from wages where title like '%"&request("glcz")&"%') and sort=3) or (gl in (select ord from pay where sort like '%"&request("glcz")&"%') and sort=4) or (gl in (select id from bankmove where title like '%"&request("glcz")&"%') and (sort=5 or sort=6)) or (gl in (select id from bankin where title like '%"&request("glcz")&"%') and sort=7) or (gl in (select ord from contractth where title like '%"&request("glcz")&"%') and sort=8) or (gl in (select id from bankin2 where company in (select ord from tel where sort3=1 and name like '%"&request("glcz")&"%')) and sort=9) or (gl in (select id from bankout where title like '%"&request("glcz")&"%') and sort=10) or (gl in (selectid from bankout2 where company in (select ord from tel where sort3=2 and name like '%"&request("glcz")&"%')) and sort=11) or (gl in (select id from bankout3 where company in (select ord from tel where sort3=2 and name like '%"&request("glcz")&"%')) and sort=12) or (gl in (select id from bankin3 where company in (select ord from tel where sort3=1 and name like '%"&request("glcz")&"%')) and sort=13) or (gl in (select id from M_OutOrder where title like '%"&request("glcz")&"%') and sort=15) or (gl in (select id from paybx where title like '%"&request("glcz")&"%') and sort=40) or (gl in (select id from AcceptanceDraft where SN like '%"&request("glcz")&"%') and sort IN (301,302,303)) or (gl in (select id from PayoutSure where title like '%"&request("glcz")&"%') and sort IN (201,202)) or (gl in (select id from PayBackSure where title like '%"&request("glcz")&"%') and sort IN (101,102))) "
		end if
	end if
	if request("bz")<>"" then
		if cint(request("bz"))>0 then
			str_Result=str_Result+" and bank in (select id from sortbank where bz = "&cint(request("bz"))&")"
'if cint(request("bz"))>0 then
		end if
	end if
	if request("link") = "yes" and replace(request("bz01")," ","")<>"" then
		str_Result=str_Result + " and bank in (select id from sortbank where bz in(" & replace(request("bz01")," ","") & "))"
'if request("link") = "yes" and replace(request("bz01")," ","")<>"" then
	end if
	px=request.QueryString("px")
	if px="" Then px=1
	if px=1 then
		px_Result = " order by date1 desc,date7 desc,id desc"
	elseif px=2 then
		px_Result = " order by date1 asc,date7 asc,id asc"
	end if
	if request("page_count")="" then
		page_count=10
	else
		page_count=request("page_count")
	end if
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
	page_count=request("page_count")
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
	Response.write """></script>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style>" & vbcrlf & ".IE5 .top_btns input.anybutton{height:18px;line-height:16px;margin-bottom:-0.5px;}" & vbcrlf & "" & vbcrlf & "</style>" & vbcrlf & "</head>" & vbcrlf & "<body "
	'Response.write Application("sys.info.jsver")
	if open_11_8=0 then
		Response.write " oncontextmenu=""return false"" onselectstart=""return false"" ondragstart=""return false"" onbeforecopy=""return false"" oncopy=document.selection.empty()"
	end if
	Response.write " onMouseOver=""window.status='none';return true;"">" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "<tr>" & vbcrlf & "   <td>" & vbcrlf & "            <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0""background=""../images/m_mpbg.gif""> "& vbcrlf &    "      <tr> "& vbcrlf &   "          <td class=""place2"" style="" background:url(../images/content_tab.png) no-repeat;height:42px;"">银行账户明细表</td> "& vbcrlf &   "          <td align=""left"">&nbsp;<a href=""###"" onClick=""Myopen(User);return false;"" class=""sortRule"">排序规则<img src=""../images/i10.gif"" width=""9"" height=""5"" border=""0""></a></td>" & vbcrlf & "          <td height=""32"" align=""right"">" & vbcrlf & "              <div align=""right"">" & vbcrlf & "               <select name=""select2""  onChange=""if(this.selectedIndex && this.selectedIndex!=0){gotourl(this.value);}"" >" & vbcrlf & "            <option>-请选择-</option>" & vbcrlf & "               <option value=""page_count=10"" "
	if page_count=10 then
		Response.write "selected"
	end if
	Response.write ">每页显示10条</option>" & vbcrlf & "               <option value=""page_count=20"" "
	if page_count=20 then
		Response.write "selected"
	end if
	Response.write ">每页显示20条</option>" & vbcrlf & "               <option value=""page_count=30"" "
	if page_count=30 then
		Response.write "selected"
	end if
	Response.write ">每页显示30条</option>" & vbcrlf & "               <option value=""page_count=50"" "
	if page_count=50 then
		Response.write "selected"
	end if
	Response.write ">每页显示50条</option>" & vbcrlf & "               <option value=""page_count=100"" "
	if page_count=100 then
		Response.write "selected"
	end if
	Response.write ">每页显示100条</option>" & vbcrlf & "              <option value=""page_count=200"" "
	if page_count=200 then
		Response.write "selected"
	end if
	Response.write ">每页显示200条</option>" & vbcrlf & "              </select>  " & vbcrlf & "             </div></td>" & vbcrlf & "             </tr>" & vbcrlf & "           </table>" & vbcrlf & "        </td>" & vbcrlf & "</tr>" & vbcrlf & "<tr>" & vbcrlf & "  <td>" & vbcrlf & "         <form method=""get"" action=""list.asp?id="
	Response.write id
	Response.write "&px="
	Response.write px
	Response.write """ id=""demo"" onSubmit=""return Validator.Validate(this,2)"" name=""date"">" & vbcrlf & "                   <table class=""resetHeadBg cancelBorder"" width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" style='height:50px;background:#f4fafe;border-top:1px solid #c0ccdd'>" & vbcrlf & "                      <input type=""hidden"" name=""id"" value="""
	Response.write id
	Response.write """>" & vbcrlf & "                        <input type=""hidden"" name=""px"" value="""
	Response.write px
	Response.write """>" & vbcrlf & "                        <input type=""hidden"" name=""page_count"" value="""
	Response.write page_count
	Response.write """>" & vbcrlf & "                        <tr>" & vbcrlf & "                    <td>&nbsp;</td>" & vbcrlf & "                 <td align=""right"" class=""top_btns"">" & vbcrlf & "                 自：<INPUT name=""ret"" size=""9"" readonly id=""daysOfMonthPos"" onMouseUp=""toggleDatePicker('daysOfMonth','date.ret')"" value="""
	Response.write m1
	Response.write """><DIV id=daysOfMonth style=""POSITION: absolute""></DIV>" & vbcrlf & "                     &nbsp;至：<INPUT name=""ret2"" size=""9"" readonly id=""daysOfMonth2Pos"" onMouseUp=""toggleDatePicker('daysOfMonth2','date.ret2')""  value="""
	Response.write m2
	Response.write """>&nbsp;" & vbcrlf & "                  <DIV id=""daysOfMonth2"" " & vbcrlf & "                   style=""POSITION: absolute""></DIV>" & vbcrlf & "                 <SCRIPT language=JavaScript1.2>" & vbcrlf & "                 function Cancel() {hideElement(""daysOfMonth"");}" & vbcrlf & "                   </SCRIPT>" & vbcrlf & "                       <SCRIPT language=JavaScript1.2>" &vbcrlf & "                        <!--" & vbcrlf & "                    hideElement('daysOfMonth');" & vbcrlf & "                     hideElement('daysOfMonth2');" & vbcrlf & "                    //-->" & vbcrlf & "                   </SCRIPT>" & vbcrlf & "                       <select name=""B"">" & vbcrlf & "                 <option value=""0"">摘要</option>" & vbcrlf & "                   "
	Response.write m2
	if ZBRuntime.MC(23001) then
		Response.write "" & vbcrlf & "                     <option value=""1,101"" "
		if B=1 then
			Response.write "selected "
		ELSEIF B="1,101" then
			Response.write "selected "
		end if
		Response.write ">合同收款</option>" & vbcrlf & "                   "
	end if
	if ZBRuntime.MC(15000) or ZBRuntime.MC(18700) then
		Response.write "" & vbcrlf & "                     <option value=""2,201"" "
		if B=2 then
			Response.write "selected "
		ELSEIF B="2,201" then
			Response.write "selected "
		end if
		Response.write ">供应商付款</option>" & vbcrlf & "                 "
	end if
	if ZBRuntime.MC(26000) then
		Response.write "" & vbcrlf & "                     <option value=""3"" "
		if B=3 then
			Response.write "selected"
		end if
		Response.write ">支付工资</option>" & vbcrlf & "                   "
	end if
	if ZBRuntime.MC(27000) then
		Response.write "" & vbcrlf & "                     <option value=""4"" "
		if B=4 then
			Response.write "selected"
		end if
		Response.write ">费用返还</option>" & vbcrlf & "                   <option value=""40"" "
		if B=40 then
			Response.write "selected"
		end if
		Response.write ">费用报销</option>" & vbcrlf & "                   <option value=""50"" "
		if B=50 then
			Response.write "selected"
		end if
		Response.write ">费用借款</option>" & vbcrlf & "                   "
	end if
	if ZBRuntime.MC(22000) then
		Response.write "" & vbcrlf & "                     <option value=""5"" "
		if B=5 then
			Response.write "selected"
		end if
		Response.write ">账间转出</option>" & vbcrlf & "                   <option value=""6"" "
		if B=6 then
			Response.write "selected"
		end if
		Response.write ">账间转入</option>" & vbcrlf & "                   "
	end if
	if ZBRuntime.MC(21000) then
		Response.write "" & vbcrlf & "                     <option value=""7"" "
		if B=7 then
			Response.write "selected"
		end if
		Response.write ">直接入账</option>" & vbcrlf & "                   "
	end if
	if ZBRuntime.MC(25001) then
		Response.write "" & vbcrlf & "                     <option value=""8"" "
		if B=8 then
			Response.write "selected"
		end if
		Response.write ">销售退款</option>" & vbcrlf & "                   "
	end if
	if ZBRuntime.MC(23002) then
		Response.write "" & vbcrlf & "                     <option value=""9"" "
		if B=9 then
			Response.write "selected"
		end if
		Response.write ">客户预收款</option>" & vbcrlf & "                 <option value=""13"" "
		if B=13 then
			Response.write "selected"
		end if
		Response.write ">退客户预收款</option>" & vbcrlf & "                       "
	end if
	if ZBRuntime.MC(20001) then
		Response.write "" & vbcrlf & "                     <option value=""301"" "
		if B=301 then
			Response.write "selected"
		end if
		Response.write ">承兑入账" & vbcrlf & "                    "
	end if
	if ZBRuntime.MC(20000) then
		Response.write "" & vbcrlf & "                     <option value=""10"" "
		if B=10 then
			Response.write "selected"
		end if
		Response.write ">直接出账</option>" & vbcrlf & "                   "
	end if
	if ZBRuntime.MC(24002) then
		Response.write "" & vbcrlf & "                     <option value=""11"" "
		if B=11 then
			Response.write "selected"
		end if
		Response.write ">供应商预付款</option>" & vbcrlf & "                       <option value=""12"" "
		if B=12 then
			Response.write "selected"
		end if
		Response.write ">退供应商预付款</option>" & vbcrlf & "                     "
	end if
	if ZBRuntime.MC(25002) then
		Response.write "" & vbcrlf & "                     <option value=""14"" "
		if B=14 then
			Response.write "selected"
		end if
		Response.write ">采购退款</option>" & vbcrlf & "                   "
	end if
	if ZBRuntime.MC(20001) then
		Response.write "" & vbcrlf & "                     <option value=""302"" "
		if B=302 then
			Response.write "selected"
		end if
		Response.write ">承兑出账" & vbcrlf & "                    "
	end if
	if ZBRuntime.MC(23001) or  ZBRuntime.MC(24001) or ZBRuntime.MC(20001) then
		Response.write "" & vbcrlf & "                     <option value=""102,202,303"" "
		if B="102,202,303" then
			Response.write "selected"
		end if
		Response.write ">手续费" & vbcrlf & "                      "
	end if
	Response.write "" & vbcrlf & "                     </select>" & vbcrlf & "                       <select name=""D"">" & vbcrlf & "                 <option value=""jsr"">经手人</option>" & vbcrlf & "                       </select>" & vbcrlf & "                       <input type=""text"" size=""8"" name=""C"" value="""
	Response.write C
	Response.write """ />" & vbcrlf & "                      <input type=""submit"" name=""Submit422"" value=""检索""  class=""anybutton""/>" & vbcrlf & "                 <input type=""hidden"" name=""from"" value="""
	Response.write from
	Response.write """ />" & vbcrlf & "                      <input type=""button"" name=""openbn"" id=""openbn"" value=""高级检索""  class=""anybutton"" onclick=""document.getElementById('w').style.display='';$('#w').window('open');""/>" & vbcrlf & "                        "
	if open_11_10=1 or open_11_10=3 then
		Response.write "<input type=""button"" name=""Submitdel2"" value=""明细导出"" onClick=""if (confirm('确认导出为EXCEL文档？')) { exportExcel({ from: 'form_with_page_action', page: '../out/xls_banklist.asp?id="
		Response.write id
		Response.write "&W1="
		Response.write request("W1")
		Response.write "&W2="
		Response.write request("W2")
		Response.write "&W3="
		Response.write request("W3")
		Response.write "&A1="
		Response.write A1
		Response.write "&A2="
		Response.write A2
		Response.write "&A3="
		Response.write A3
		Response.write "&B="
		Response.write B
		Response.write "&C="
		Response.write Server.UrlEncode(C)
		Response.write "&D="
		Response.write D
		Response.write "&E="
		Response.write E
		Response.write "&F="
		Response.write F
		Response.write "&H="
		Response.write H
		Response.write "&px="
		Response.write px
		Response.write "&ret="
		Response.write m1
		Response.write "&ret2="
		Response.write m2
		Response.write "&bankname="
		Response.write Request("bankname")
		Response.write "&duepaydate1="
		Response.write Request("duepaydate1")
		Response.write "&duepaydate2="
		Response.write Request("duepaydate2")
		Response.write "&duemoney1="
		Response.write Request("duemoney1")
		Response.write "&duemoney2="
		Response.write Request("duemoney2")
		Response.write "&duemoney3="
		Response.write Request("duemoney3")
		Response.write "&duemoney4="
		Response.write Request("duemoney4")
		Response.write "&intro="
		Response.write intro
		Response.write "&bz="
		Response.write Request("bz")
		Response.write "&glcz="
		Response.write Request("glcz")
		Response.write "&from="
		Response.write from
		Response.write "' }); }"" class=""anybutton""/>"
	end if
	if open_11_7=1 or open_11_7=3 then
		Response.write "<input type=""button"" name=""Submit43"" value=""打印""  onClick=""window.print();""  class=""anybutton""/>"
	end if
	Response.write "</td>" & vbcrlf & "                        <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "                      </tr>" & vbcrlf & "                   </table>" & vbcrlf & "                </form>" & vbcrlf & " </td>" & vbcrlf & "</tr>" & vbcrlf & "<tr>" & vbcrlf & "  <td width=""100%"" valign=""top"">" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"" style=""margin-top:0px;"">" & vbcrlf & "                        <tr class=""top"">" & vbcrlf & "                  <td height=""27"" width=""12%""><div align=""center"">日期</div></td>" & vbcrlf & "                       <td width=""16%""><div align=""center"">账户名称</div></td>" & vbcrlf &      "               <td width=""12%""><div align=""center"">收入</div></td> "& vbcrlf &"                  <td width=""12%""><div align=""center"">支出</div></td> "& vbcrlf & "                 <td width=""12%""><div align=""center"">余额</div></td> "& vbcrlf &"                  <td width=""10%""><div align=""center"">摘要</div></td>" & vbcrlf & "                       <td width=""10%""><div align=""center"">经手人</div></td>" & vbcrlf & "                       <td width=""16%""><div align=""center"">关联操作</div></td>" & vbcrlf & "                     </tr>" & vbcrlf & "                   "
	dim moneyall1,moneyall2,moneyall3,gl2
	money1_all=0
	money2_all=0
	set rs88=conn.execute("select isnull(sum(round(money1,"&num_dot_xs&")),0) as money1,isnull(sum(round(money2,"&num_dot_xs&")),0) as money2 from bank where del=1 "&Str_Result&" and date1>='"&m1&"' and (len(isnull('"&m2&"',''))=0 or date1<='"&m2&"') ")
	money1_all=rs88(0).value
	money2_all=rs88(1).value
	set rs88=nothing
	set rs7=server.CreateObject("adodb.recordset")
	set rs=server.CreateObject("adodb.recordset")
	function getTotalByBankId(bankId,date1)
		strSql="select isnull(sum(round(money1,"&num_dot_xs&"))-sum(round(money2,"&num_dot_xs&")),0) as total from bank where  del=1 and bank="&bankId&"  and date1<'"&date1&"' "
'function getTotalByBankId(bankId,date1)
		intTotal=conn.execute(strSql)(0)
		getTotalByBankId=intTotal
	end function
	dim moneyall
	moneyall=0
	moneyall=getTotalByBankId(id,m1)
	strs="select IDENTITY( INT,1,1 ) inx,bank,round(money1,"&num_dot_xs&") as money1,round(money2,"&num_dot_xs&") as money2" &_
	",sort,intro,gl,isnull(cateid,0) as cateid ,date1,date7,gl2 into #BillList   from bank where del=1 "&Str_Result&"  "&_
	"and (len(isnull('"&m1&"',''))=0 or date1>='"&m1&"') " &_
	"and (len(isnull('"&m2&"',''))=0 or date1<='"&m2&"') "&px_Result&" "
	conn.execute(strs)
	if px=1 then
		pxsal="select a.inx , "&_
		""&moneyall&"+isnull(sum(round(isnull(b.money1,0),"&num_dot_xs&"))-sum(round(isnull(b.money2,0),"&num_dot_xs&")),0) blanance "&_
		"into #data from #BillList a "&_
		" left join #BillList b on b.inx>=a.inx"&_
		" group by a.inx  "
	else
		pxsal="select a.inx , "&_
		""&moneyall&"+isnull(sum(round(isnull(b.money1,0),"&num_dot_xs&"))-sum(round(isnull(b.money2,0),"&num_dot_xs&")),0) blanance "&_
		"into #data from #BillList a "&_
		" left join #BillList b on b.inx<=a.inx"&_
		" group by a.inx  "
	end if
	conn.execute(pxsal)
	sql="select bank,money1,money2,sort,intro,gl,cateid,date1,date7 ,gl2,t.blanance "&_
	"from  #BillList left join ( "&_
	"select * from #data " &_
	" )t on  #BillList.inx=t.inx  "
	rs.open sql,conn,1,1
	if rs.RecordCount<=0  then
		Response.write "<table style='width:100%;background:#fff;border-collapse:collapse;'><tr><td>没有信息!</td></tr><tr><td height='60'> </td></tr></table>"
'if rs.RecordCount<=0  then
	else
		rs.PageSize=page_count
		n=0
		PageCount=clng(rs.PageCount)
		CurrPage=cdbl(Request("CurrPage"))
		if CurrPage<=0 or CurrPage="" Then CurrPage=1
		if CurrPage>=PageCount Then CurrPage=PageCount
		BookNum=rs.RecordCount
		rs.absolutePage = CurrPage
		dim numcg1,numcg2,ord2,title2,k,ord,sort,k2,ord3,title3,k3,date1
		do while not rs.eof
			sort=rs("sort")
			bank=rs("bank")
			gl2 = rs("gl2")
			numcg1=0
			numcg2=0
			date1=""
			ord2=""
			ord3=""
			numcg1=zbcdbl(rs("money1"))
			numcg2=zbcdbl(rs("money2"))
			if numcg1="" or isnull(numcg1) then numcg1=0
			if numcg2="" or isnull(numcg2) then numcg2=0
			intro=rs("intro")
			date1=rs("date1")
			gl=rs("gl")
			cateid=""
			if gl="" or IsNull(gl) then
				gl=0
			end if
			moneyall=zbcdbl(rs("blanance"))
			sql7="select id,sort1 from sortbank where  id="&bank&""
			rs7.open sql7,conn,1,1
			if rs7.eof then
				title2="账户已被暂停使用或删除"
				k2="账户已被暂停使用或删除"
			else
				ord2=rs7("id")
				title2=rs7("sort1")
				k2=rs7("sort1")
			end if
			rs7.close
			sql7="select name from gate where ord="&rs("cateid")&""
			rs7.open sql7,conn,1,1
			if not rs7.eof then
				cateid=rs7("name")
			end if
			rs7.close
			if sort=1 then
				sql7="select a.ord,a.title,"&_
				"dbo.checkPower(a.cateid,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.cateid,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from contract a "&_
				"left join power b on b.sort1=5 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=5 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.ord="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="合同已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("title")
					bh=rs7("ord")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../../SYSN/view/sales/contract/ContractDetails.ashx?view=details&ord="&pwurl(bh)
				rs7.close
			elseif sort=2 Then
				sql7="select a.ord,a.title,"&_
				"dbo.checkPower(a.cateid,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.cateid,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from caigou a "&_
				"left join power b on b.sort1=22 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=22 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.ord="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="采购单已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("title")
					bh=rs7("ord")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../../SYSN/view/store/caigou/caigoudetails.ashx?view=details&ord="&pwurl(bh)
				rs7.close
			elseif sort=3 then
				sql7="select a.id,a.title, "&_
				"dbo.checkPower(a.cateid,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.cateid,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from wages a "&_
				"left join power b on b.sort1=10 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=10 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.id="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="工资单已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("title")
					bh=rs7("id")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../wages/content.asp?ord="&pwurl(bh)
				rs7.close
			elseif sort=4 then
				sql7="select a.ord,a.title,"&_
				"dbo.checkPower(a.cateid,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.cateid,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from pay a "&_
				"left join power b on b.sort1=6 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=6 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.ord="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="费用返还单已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					if Isnull(rs7("title")) or rs7("title")="" then
						title="费用返还"
					else
						title=rs7("title")
					end if
					bh=rs7("ord")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../pay/content3.asp?ord="&pwurl(bh)
				rs7.close
			elseif sort=5 or sort=6 then
				sql7="select a.id,a.title,"&_
				"dbo.checkPower(a.cateid,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.cateid,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from bankmove a "&_
				"left join power b on b.sort1=11 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=11 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.id="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="转账单已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("title")
					bh=rs7("id")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../bank/contentdb.asp?ord="&pwurl(bh)
				rs7.close
			elseif sort=7 then
				sql7="select a.id,a.title,"&_
				"dbo.checkPower(a.cateid,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.cateid,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from bankin a "&_
				"left join power b on b.sort1=11 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=11 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.id="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="入账单已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("title")
					bh=rs7("id")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../../sysn/view/finan/CashBank/DirectInOrOut/DirectCreditDetail.ashx?ord="&pwurl(bh)+"&view=details"
				hasDetailPower = (rs7("hasDetailPower") = 1)
				rs7.close
			elseif sort=8 then
				sql7="select a.ord,a.title,"&_
				"dbo.checkPower(a.cateid,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.cateid,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from contractth a "&_
				"left join power b on b.sort1=41 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=41 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.ord="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="退货单已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("title")
					bh=rs7("ord")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../contractth/content.asp?ord="&pwurl(bh)
				rs7.close
			elseif sort=9 then
				sql7="select a.ID, a.title, " &_
				"dbo.checkPower(a.cateid,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.cateid,c.qx_open,c.qx_intro) as hasDetailPower "&_
				" from bankin2 a "&_
				"left join power b on b.sort1=7 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=7 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.id="&gl&" and a.del=1 "
				rs7.open sql7,conn,1,1
				if rs7.eof then
					bh=0
					title="客户预收款已被删除"
					hasListPower = False
					hasDetailPower = False
				else
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
					title=rs7("title")
					bh=rs7("ID")
				end if
				rs7.close
				url = "../../sysn/view/finan/payback/PaybackPre/BankIn2.ashx?ord="&pwurl(bh)+"&view=details"
				rs7.close
			elseif sort=10 then
				sql7="select a.id,a.title,"&_
				"dbo.checkPower(a.cateid,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.cateid,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from bankout a "&_
				"left join power b on b.sort1=11 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=11 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.id="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="出账单已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("title")
					bh=rs7("id")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../../sysn/view/finan/CashBank/DirectInOrOut/DirectCreditOutDetail.ashx?&view=details&ord="&pwurl(bh)
				rs7.close
			elseif sort=11 then
				sql7="select a.id,a.title,"&_
				"dbo.checkPower(a.Creator,b.qx_open,b.qx_intro) as hasListPower, "&_
				"dbo.checkPower(a.Creator,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from bankout2 a "&_
				"left join power b on b.sort1=8 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=8 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.id="&gl&" and a.del=1 "
				rs7.open sql7,conn,1,1
				if rs7.eof then
					gys=0
					bh=0
					title="供应商预付款已被删除"
					hasListPower = True
					hasDetailPower = False
				else
					title=rs7("title")
					bh=rs7("id")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../../sysn/view/finan/payout/payoutpre/AdvanceCharge.ashx?view=details&ord="&pwurl(bh)
				rs7.close
			elseif sort=12 then
				sql7="select company from bankout3 where id="&gl&" and del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					gyst=0
					bh=0
					title="供应商退预付款已被删除"
					hasListPower = True
					hasDetailPower = False
				else
					gyst=rs7("company")
				end if
				url = "../wages/content.asp?ord="&pwurl(bh)
				rs7.close
				If gyst <> 0 Then
					rs7.open "select a.ord,a.name,"&_
					"dbo.checkPower(a.cateid,b.qx_open,b.qx_intro) as hasListPower,"&_
					"dbo.checkPower(a.cateid,c.qx_open,c.qx_intro) as hasDetailPower "&_
					"from tel a "&_
					"left join power b on b.sort1=26 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
					"left join power c on c.sort1=26 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
					"where a.ord="&gyst&" and a.del=1",conn,1,1
					if rs7.eof then
						title="供应商已被删除"
						bh=0
						hasListPower = False
						hasDetailPower = False
					else
						title=rs7("name")
						bh=rs7("ord")
						hasListPower = (rs7("hasListPower") = 1)
						hasDetailPower = (rs7("hasDetailPower") = 1)
					end if
					rs7.close
				end if
				url = "../work2/content.asp?ord="&pwurl(bh)
			elseif sort=13 then
				sql7="select company from bankin3 where id="&gl&" and del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					kht=0
					bh=0
					title="客户退预收款已被删除"
					hasListPower = True
					hasDetailPower = False
				else
					kht=rs7("company")
				end if
				rs7.close
				If kht<>0 Then
					rs7.open "select a.ord,a.name,"&_
					"dbo.checkPower(a.cateid,b.qx_open,b.qx_intro) as hasListPower,"&_
					"dbo.checkPower(a.cateid,c.qx_open,c.qx_intro) as hasDetailPower "&_
					"from tel a "&_
					"left join power b on b.sort1=1 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
					"left join power c on c.sort1=1 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
					"where a.ord="&kht&" and a.del=1",conn,1,1
					if rs7.eof then
						title="客户已被删除"
						bh=0
						hasListPower = False
						hasDetailPower = False
					else
						title=rs7("name")
						bh=rs7("ord")
						hasListPower = (rs7("hasListPower") = 1)
						hasDetailPower = (rs7("hasDetailPower") = 1)
					end if
					rs7.close
				end if
				url = "../work/content.asp?ord="&pwurl(bh)
			elseif sort=14 then
				sql7="select a.ord,(case when a.fromtype=1 then cgt.title when a.fromtype=2 then cg.title when a.fromtype in (3,4) then moo.title else '' end ) as title ,"&_
				"dbo.checkPower(a.cateid,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.cateid,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from payout3 a "&_
				"left join caigouth cgt on a.caigouth=cgt.ord and cgt.del=1 and a.fromtype=1 "&_
				"left join caigou cg on a.frombillid=cg.ord and cg.del=1 and a.fromtype=2 " &_
				"left join M2_OutOrder moo on a.frombillid=moo.ID and moo.del=1 and a.fromtype in (3,4)" &_
				"left join power b on b.sort1=76 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=76 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.ord="&gl2&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="关联单据已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("title")
					bh=rs7("ord")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../../SYSN/view/finan/payout/PayRefund.ashx?ord="&pwurl(gl2)
				rs7.close
			ElseIf sort = 15 Then
				sql7="select a.id,a.title," &_
				"dbo.checkPower(a.creator,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.creator,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from M_OutOrder a "&_
				"left join power b on b.sort1=5025 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=5025 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.id="&gl&" and a.del=0"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="委外单已被删除"
					intro="委外付款"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("title")
					intro="委外付款"
					bh=rs7("id")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				rs7.close
				url = "../Manufacture/inc/readbill.asp?orderid=25&id="&bh
			ElseIf sort = 19 Then
				sql7="select a.id,a.title," &_
				"dbo.checkPower(a.creator,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.creator,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from M2_OutOrder a "&_
				"left join power b on b.sort1=5025 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=5025 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.id="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="整单委外已被删除"
					intro="整单委外付款"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("title")
					intro="整单委外付款"
					bh=rs7("id")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				rs7.close
				url = "../../SYSN/view/produceV2/ProductionOutsource/ProOutsourceAdd.ashx?ord="&pwurl(bh)&"&view=details"
			ElseIf sort = 18 Then
				sql7="select a.id,a.title," &_
				"dbo.checkPower(a.creator,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.creator,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from M2_OutOrder a "&_
				"left join power b on b.sort1=5026 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=5026 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.id="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="工序委外已被删除"
					intro="工序委外付款"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("title")
					intro="工序委外付款"
					bh=rs7("id")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				rs7.close
				url = "../../SYSN/view/produceV2/OutProcedure/AddOutProcedure.ashx?ord="&pwurl(bh)&"&view=details"
			elseif sort=40 then
				sql7="select a.id,a.title,"&_
				"dbo.checkPower((select top 1 y.cateid from paybxlist x inner join pay y on x.payid=y.ord where x.bxid=a.id),b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower((select top 1 y.cateid from paybxlist x inner join pay y on x.payid=y.ord where x.bxid=a.id),c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from paybx a "&_
				"left join power b on b.sort1=6 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=6 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.id="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="费用报销单已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("title")
					bh=rs7("id")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../pay/paybxcontent.asp?paybxid="&bh
				rs7.close
				if title="" or isnull(title) then title="无标题"
			elseif sort=50 then
				sql7="select a.id,a.title,"&_
				"dbo.checkPower(a.sorce2,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.sorce2,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from payjk a "&_
				"left join power b on b.sort1=6 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=6 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.id="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="费用借款单已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("title")
					bh=rs7("id")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../pay/jkdetail.asp?ord="&pwurl(bh)
				rs7.close
			elseif sort=302 then
				sql7="select a.id,a.SN ,"&_
				"dbo.checkPower(a.Creator,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.Creator,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from AcceptanceDraft a "&_
				"left join power b on b.sort1=1101 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=1101 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.id="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("SN")
					bh=rs7("id")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../../SYSN/view/finan/CashBank/AcceptanceBill/Bill.ashx?view=details&ord="&pwurl(bh)
				rs7.close
			elseif sort=301 then
				sql7="select a.id,a.SN ,"&_
				"dbo.checkPower(a.Creator,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.Creator,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from AcceptanceDraft a "&_
				"left join power b on b.sort1=1101 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=1101 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.id="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("SN")
					bh=rs7("id")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../../SYSN/view/finan/CashBank/AcceptanceBill/Bill.ashx?view=details&ord="&pwurl(bh)
				rs7.close
			elseif sort=202 or sort=201 then
				sql7="select a.id,a.title,"&_
				"dbo.checkPower(a.Creator,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.Creator,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from PayoutSure a "&_
				"left join power b on b.sort1=8 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=8 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.id="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("title")
					bh=rs7("id")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../../SYSN/view/finan/payout/PayoutSureDetail.ashx?view=details&ord="&pwurl(bh)
				rs7.close
			elseif sort=102 or sort=101  then
				sql7="select a.id,a.title,"&_
				"dbo.checkPower(t.cateid,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(t.cateid,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from PayBackSure a "&_
				"left join tel t on t.ord=a.company "&_
				"inner join PayBackSureList bb on bb.SureID=a.ID "&_
				"left join power b on b.sort1=7 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=7 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where bb.id="&gl2&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="费用借款单已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("title")
					bh=rs7("id")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../../SYSN/view/finan/payback/PayBackSureDetail.ashx?ord="&pwurl(bh)
				rs7.close
			elseif sort=303 then
				sql7="select a.id,a.SN,"&_
				"dbo.checkPower(a.Creator,b.qx_open,b.qx_intro) as hasListPower,"&_
				"dbo.checkPower(a.Creator,c.qx_open,c.qx_intro) as hasDetailPower "&_
				"from AcceptanceDraft a "&_
				"left join power b on b.sort1=1101 and b.sort2=1 and b.ord=" & session("personzbintel2007") & " " &_
				"left join power c on c.sort1=1101 and c.sort2=14 and c.ord=" & session("personzbintel2007") & " " &_
				"where a.id="&gl&" and a.del=1"
				rs7.open sql7,conn,1,1
				if rs7.eof then
					title="承兑汇票已被删除"
					bh=0
					hasListPower = False
					hasDetailPower = False
				else
					title=rs7("SN")
					bh=rs7("id")
					hasListPower = (rs7("hasListPower") = 1)
					hasDetailPower = (rs7("hasDetailPower") = 1)
				end if
				url = "../../SYSN/view/finan/CashBank/AcceptanceBill/Bill.ashx?view=details&ord="&pwurl(bh)
				rs7.close
			end if
			moneyall1 =cdbl(moneyall1)+cdbl(numcg1)
			rs7.close
			moneyall2 =cdbl(moneyall2)+cdbl(numcg2)
			rs7.close
			moneyall3 =cdbl(moneyall3)+cdbl(moneyall)
			rs7.close
			Response.write "       " & vbcrlf & "                                       <tr height=""27"" onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                                 <td align=""center"">"
			Response.write date1
			Response.write "</td>" & vbcrlf & "                                 <td align=""center"">"
			Response.write k2
			Response.write "</td>" & vbcrlf & "                                 <td align=""center""><div align=""right"">"
			Response.write Formatnumber(numcg1,num_dot_xs,-1)
			Response.write "</div></td>" & vbcrlf & "                                   <td align=""center""><div align=""right""><font class=""red"">"
			Response.write Formatnumber(numcg2,num_dot_xs,-1)
			Response.write "</font></div></td>" & vbcrlf & "                                    <td align=""center""><div align=""right"">"
			Response.write Formatnumber(moneyall,num_dot_xs,-1)
			Response.write "</div></td>" & vbcrlf & "                                   <td align=""center"">"
			Response.write intro
			Response.write "</td>" & vbcrlf & "                                 <td align=""center"">"
			Response.write cateid
			Response.write "</td>" & vbcrlf & "                                 <td align=""left"">" & vbcrlf & "                                 "
			If hasListPower = False Then title=""
			If bh > 0 And hasDetailPower = True Then
				Response.write "" & vbcrlf & "                                              <a class=""tableLinks"" href=""javascript:;"" onclick=""window.open('"
				Response.write url
				Response.write "','new"
				Response.write sort
				Response.write "win','width=900,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');return false;"">" & vbcrlf & "                                            "
				Response.write title
				Response.write "</a>" & vbcrlf & "                                          "
			else
				Response.write title
			end if
			Response.write "" & vbcrlf & "                                      </td>" & vbcrlf & "                                   "
			n=n+1
			rs.movenext
			if rs.eof or n>=rs.pagesize then exit do
		loop
		conn.execute("drop table #BillList")
		Response.write "        " & vbcrlf & "                              </tr>" & vbcrlf & "                           <tr height=""27"" onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                         <td class=""name"" colspan=""2""><div align=""right"">本页合计：</div></td>" & vbcrlf & "                         <td class=""red"" align=""right"">&nbsp;"
		Response.write Formatnumber(moneyall1,num_dot_xs,-1)
		Response.write "</td>" & vbcrlf & "                         <td class=""red"" align=""right"">&nbsp;"
		Response.write Formatnumber(moneyall2,num_dot_xs,-1)
		Response.write "</td>" & vbcrlf & "                         <td class=""red"" align=""right"">&nbsp;"
		Response.write "</td>" & vbcrlf & "                         <td align=""center"">&nbsp;</td>" & vbcrlf & "                            <td align=""center"">&nbsp;</td>" & vbcrlf & "                            <td align=""center"">&nbsp;</td>" & vbcrlf & "                            <td align=""center"">&nbsp;</td>" & vbcrlf & "                            </tr>" & vbcrlf & "                           <tr height=""27"" onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                            <td class=""name"" colspan=""2""><div align=""right"">所有合计：</div></td>" & vbcrlf & "                         <td class=""red"" align=""right"">&nbsp;"
		Response.write Formatnumber(money1_all,num_dot_xs,-1)
		Response.write "</td>" & vbcrlf & "                                <td class=""red"" align=""right"">&nbsp;"
		Response.write Formatnumber(money2_all,num_dot_xs,-1)
		Response.write "</td>" & vbcrlf & "                                <td class=""red"" align=""right"">&nbsp;"
		Response.write "</td>" & vbcrlf & "                                <td align=""center"">&nbsp;</td>" & vbcrlf & "                            <td align=""center"">&nbsp;</td>" & vbcrlf & "                            <td align=""center"">&nbsp;</td>" & vbcrlf & "                            <td align=""center"">&nbsp;</td>" & vbcrlf & "                            </tr>" & vbcrlf & "                           </table>" & vbcrlf & "                </td>" & vbcrlf & "     </tr>" & vbcrlf & "   <tr>" & vbcrlf & "    <td  class=""page"">" & vbcrlf & "       <table width=""100%"" border=""0"" align=""left"" class=""resetBgColor3F"">" & vbcrlf & "  <tr>" & vbcrlf & "    <td height=""30""><div align=""center""></div>      <div align=""right"">" & vbcrlf & "      "
		Response.write rs.RecordCount
		Response.write "个 | "
		Response.write currpage
		Response.write "/"
		Response.write rs.pagecount
		Response.write "页 | &nbsp;"
		Response.write rs.pagesize
		Response.write "条信息/页&nbsp;&nbsp;" & vbcrlf & "      "
		if currpage=1 then
			Response.write "" & vbcrlf & "      <input type=""button"" name=""Submit4"" value=""首页""  class=""page""/> <input type=""button"" name=""Submit42"" value=""上一页""  class=""page""/>" & vbcrlf & "      "
		else
			Response.write "" & vbcrlf & "      <input type=""button"" name=""Submit4"" value=""首页""   class=""page"" onClick=""gotourl('currPage=1')""/> <input type=""button"" name=""Submit42"" value=""上一页""  onClick=""gotourl('currPage="
			Response.write currpage-1
			Response.write "')"" class=""page""/>" & vbcrlf & "      "
		end if
		if currpage=rs.pagecount then
			Response.write "" & vbcrlf & "      <input type=""button"" name=""Submit43"" value=""下一页""  class=""page""/> <input type=""button"" name=""Submit44"" value=""尾页""  class=""page""/>" & vbcrlf & "      "
		else
			Response.write "" & vbcrlf & "     <input type=""button"" name=""Submit43"" value=""下一页""  onClick=""gotourl('currPage="
			Response.write currpage+1
			Response.write "')"" class=""page""/> <input type=""button"" name=""Submit43"" value=""尾页""  onClick=""gotourl('currPage="
			Response.write rs.PageCount
			Response.write "')"" class=""page""/>" & vbcrlf & "      "
		end if
		Response.write "" & vbcrlf & "      </div></td>" & vbcrlf & "    </tr>" & vbcrlf & " " & vbcrlf & "</table>" & vbcrlf & "" & vbcrlf & ""
	end if
	rs.close
	set rs=nothing
	set rs7=nothing
	Response.write "  " & vbcrlf & "   </td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "<p style='height:50px;'>&nbsp;</p>" & vbcrlf & ""
	Response.Flush : Response.Clear
	Response.write "" & vbcrlf & "<div id=""w"" class=""easyui-window"" title=""高级检索""  style=""width:500px;height:420px;padding:5px;background: #fafafa;top:60px;display:none;overflow-x:hidden""  closed=""true"" >" & vbcrlf & "                  <form method=""get"" action=""list.asp?id="
	Response.Flush : Response.Clear
	Response.write id
	Response.write """ id=""date1"" onSubmit=""return Validator.Validate(this,2)"" name=""date22"">" & vbcrlf & "                        <div region=""center"" border=""false"" style=""padding:10px;background:#fff;border:1px solid #ccc;width:99%"">" & vbcrlf & "                     <input type=""hidden"" name=""px"" value="""
	Response.write px
	Response.write """>" & vbcrlf & "                        <input type=""hidden"" name=""page_count"" value="""
	Response.write page_count
	Response.write """>" & vbcrlf & "                        <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "                        <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "                  <td width=""24%"" class=""func""><div align=""right"">账户名称</div></td>" & vbcrlf & "                  <td width=""76%""><label> <input name=""bankname"" type=""text"" id=""bankname""><input type=""hidden"" name=""id"" value="""
	Response.write id
	Response.write """></label></td>" & vbcrlf & "              </tr>" & vbcrlf & "               <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "                 <td><div align=""right"">经手人</div></td>" & vbcrlf & "                 <td>"
	if sort_zjjg="" or isnull(sort_zjjg) then
		sort_zjjg=1
	end if
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select sort1,qx_open,w1,w2,w3 from power2  where cateid="&session("personzbintel2007")&" and sort1="&sort_zjjg&" "
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_1_1=0
	else
		open_1_1=rs1("qx_open")
		w1=rs1("w1")
		w2=rs1("w2")
		w3=rs1("w3")
	end if
	rs1.close
	set rs1=nothing
	if open_1_1=1 then
		str_w1="and ord in ("&w1&")"
		str_w2="and ord in ("&w2&")"
		str_w3="and ord in ("&w3&")"
	elseif open_1_1=3 then
		str_w1=""
		str_w2=""
		str_w3=""
	else
		str_w1="and ord=0"
		str_w2="and ord=0"
		str_w3="and ord=0"
	end if
	Correct_W1=0
	Correct_W2=0
	Correct_W3=user_list
	if Correct_W3<>"" and Correct_W3<>"0" then
		tmp=split(getW1W2(Correct_W3),";")
		Correct_W1=tmp(0)
		Correct_W2=tmp(1)
	end if
	Dim SeaStr
	SeaStr = ""
	If IsType = 1 Then
		If Len(dongjie)>0 And dongjie=1 then
			SeaStr = SeaStr & " or del = 2"
		end if
		If Len(huishouzhan)>0 And huishouzhan=1 then
			SeaStr = SeaStr & " or del = 5"
		end if
	end if
	ReDim d_at(54)
	d_at(0) = "Class UserTreeNodeItem"
	d_at(1) = "  Public Nodes,  NodeText,  NodeId,  orgstype,  wsign,del, parent, checked"
	d_at(4) = "  Public Sub setparent(ByRef p) : Set parent = p : End sub"
	d_at(5) = "  Public Function GetJSON()"
	d_at(6) = "          GetJSON = ""{text:"""""" & NodeText & """""",value:"" & NodeId & "",datas:[0,"" & orgstype & ""],wsign:"" & wsign & "", checked:"" & Abs(checked) & "",nodes:"" & nodes.GetJSON & "",del:"" & del & "" }"""
	d_at(7) = "  End function"
	d_at(8) = "End Class"
	d_at(11) = "Class UserTreeNodeList"
	d_at(12) = "        public items,  count, curr"
	d_at(13) = "        Public Sub setcurr(ByRef c)"
	d_at(14) = "                Set curr = c"
	d_at(15) = "        End sub"
	d_at(17) = "        Public Sub Dispose"
	d_at(18) = "                Dim i : Set curr = nothing"
	d_at(19) = "                For i = 0 To count-1"
'd_at(18) = "                Dim i : Set curr = nothing"
	d_at(20) = "                        items(i).Dispose :  Set items(i) = nothing"
	d_at(21) = "                Next"
	d_at(22) = "                Erase items"
	d_at(23) = "        End sub"
	d_at(24) = "        Public function Add(ByRef rs, ByRef w3v, ByRef orgsv, byref realw3)"
	d_at(25) = "                Dim item : Set item = New UserTreeNodeItem"
	d_at(26) = "                If isobject(curr) then  item.setparent curr"
	d_at(27) = "                item.nodetext = rs(""NodeText"").value"
	d_at(28) = "                item.nodeid = rs(""NodeId"").value"
	d_at(29) = "                item.del = rs(""del"").value"
	d_at(30) = "                item.orgstype =  rs(""orgstype"").value"
	d_at(31) = "                item.wsign = rs(""wsign"").value"
	d_at(32) = "                If item.wsign = 3 Then "
	d_at(33) = "                         item.checked = InStr("","" & w3v & "","",  "","" & item.nodeid & "","") > 0 " & vbcrlf & _
	"   if item.checked then " & vbcrlf & _
	"           if len(realw3)>0 then realw3 = realw3 & "","" " & vbcrlf & _
	"           realw3 = realw3 & item.nodeid " & vbcrlf &_
	"   end if"
	d_at(34) = "                Else"
	d_at(35) = "                         item.checked = InStr("","" & orgsv & "","",  "","" & item.nodeid & "","") > 0"
	d_at(36) = "                End If"
	d_at(37) = "                ReDim Preserve items(count)"
	d_at(38) = "                Set items(count) = item"
	d_at(39) = "                Set Add = item"
	d_at(40) = "                count = count + 1"
'd_at(39) = "                Set Add = item"
	d_at(41) = "        End Function"
	d_at(42) = "        Public Function GetJSON"
	d_at(43) = "                Dim i, html "
	'd_at(44) = "                If count>0 Then "
	d_at(45) = "                        ReDim html(count-1)"
''d_at(44) = "                If count>0 Then "
	d_at(46) = "                        For i = 0 To count -1 "
''d_at(44) = "                If count>0 Then "
	d_at(47) = "                                html(i) = items(i).getJSON()"
	d_at(48) = "                        Next"
	d_at(49) = "                        GetJSON = ""["" & Join(html,"","") & ""]"""
	d_at(50) = "                Else"
	d_at(51) = "                        GetJSON = ""[]"""
	d_at(52) = "                End if"
	d_at(53) = "        End function"
	d_at(54) = "End Class"
	execute "On Error Resume Next : ExecuteGlobal Join(d_at, vbcrlf)"
	ReDim d_at(61)
	d_at(0) = "'复选树" & vbCrLf
	d_at(1) = "Function CBaseUserTreeHtml(ByVal sql, ByVal orgsname, ByVal w1name, ByVal w2name, ByVal w3name, ByVal orgsvalue, ByVal w1value,  ByVal w2value,  ByVal w3value)" & vbCrLf
	d_at(2) = " CBaseUserTreeHtml = CBaseUserTreeHtmlCore(sql, orgsname, w1name, w2name, w3name, orgsvalue, w1value, w2value, w3value, ""checkbox"", """")" & vbCrLf
	d_at(3) = "End Function" & vbCrLf
	d_at(4) = "'单选树" & vbCrLf
	d_at(5) = "Function CBaseUserTreeHtmlRadio(ByVal sql, ByVal orgsname, ByVal w1name, ByVal w2name, ByVal w3name, ByVal orgsvalue, ByVal w1value,  ByVal w2value,  ByVal w3value)" & vbCrLf
	d_at(6) = " CBaseUserTreeHtmlRadio = CBaseUserTreeHtmlCore(sql, orgsname, w1name, w2name, w3name, orgsvalue, w1value, w2value, w3value, ""radio"", """")" & vbCrLf
	d_at(7) = "End Function" & vbCrLf
	d_at(8) = "'带事件的单选树" & vbCrLf
	d_at(9) = "Function CBaseUserTreeHtmlRadioCE(ByVal sql, ByVal orgsname, ByVal w1name, ByVal w2name, ByVal w3name, ByVal orgsvalue, ByVal w1value,  ByVal w2value,  ByVal w3value, ByVal changeEvent)" & vbCrLf
	d_at(10) = "        CBaseUserTreeHtmlRadioCE = CBaseUserTreeHtmlCore(sql, orgsname, w1name, w2name, w3name, orgsvalue, w1value, w2value, w3value, ""radio"",  changeEvent)" & vbCrLf
	d_at(11) = "End Function" & vbCrLf
	d_at(12) = "'生成树基本方法" & vbCrLf
	d_at(13) = "Function CBaseUserTreeHtmlCore(byref sql, byref orgsname, byref w1name, byref w2name, byref w3name, byref orgsvalue, byref w1value,  byref w2value,  byref w3value, ByVal checktype, ByVal changeEvent)" & vbCrLf
	d_at(14) = "        Dim htmlid,  htmlsortid, rs, pdeep, currdeep, i, fc, nd, basenodes, nodes, realw3" & vbCrLf
	d_at(15) = "        Randomize :     pdeep =  0 : fc = 0" & vbCrLf
	d_at(16) = "        w3value = Replace(w3value & """","" "","""")" & vbCrLf
	d_at(17) = "        orgsvalue = Replace(orgsvalue & """", "" "" , """")" & vbCrLf
	d_at(18) = "        htmlsortid =CLng(rnd*1000000)" & vbCrLf
	d_at(19) = "        htmlid = ""basetreedata"" & htmlsortid" & vbCrLf  & " on error resume next " & vbcrlf & "if isobject(conn) = false then set conn = cn" & vbcrlf
	d_at(20) = "        on error resume next : Set rs = conn.execute(""exec erp_comm_UsersTreeBase '"" & Replace(sql, ""'"", ""''"") & ""',0"")" & vbCrLf
	d_at(21) = "  if err.number <> 0 then CBaseUserTreeHtmlCore = ""UsersTreeBase错误，SQL:"" & ""exec erp_comm_UsersTreeBase '"" & Replace(sql, ""'"", ""''"") & ""',0"" & "","" & err.description : exit function" & vbcrlf
	d_at(22) = "        Set basenodes = New UserTreeNodeList" & vbCrLf
	d_at(23) = "        Set nodes = basenodes" & vbCrLf
	d_at(24) = "        while rs.eof = False" & vbCrLf
	d_at(25) = "                currdeep =  rs(""NodeDeep"").value" & vbCrLf
	d_at(26) = "                If currdeep > pdeep Then " & vbCrLf
	d_at(27) = "                        Set nodes = nd.nodes" & vbCrLf
	d_at(28) = "                ElseIf currdeep<pdeep then" & vbCrLf
	d_at(29) = "                        For i = currdeep To pdeep" & vbCrLf
	d_at(30) = "                                Set nd = nd.parent" & vbCrLf
	d_at(31) = "                        Next" & vbCrLf
	d_at(32) = "                        If nd Is Nothing Then Err.rasie ""1212"", ""asa"", currdeep & ""=="" & pdeep" & vbCrLf
	d_at(33) = "                        Set nodes = nd.nodes" & vbCrLf
	d_at(34) = "                End If" & vbCrLf
	d_at(35) = "                Set nd = nodes.Add(rs, w3value, orgsvalue, realw3)" & vbCrLf
	d_at(36) = "                pdeep = currdeep" & vbCrLf
	d_at(37) = "                rs.movenext" & vbCrLf
	d_at(38) = "        wend" & vbCrLf
	d_at(39) = "        rs.close" & vbCrLf
	d_at(40) = "       Set rs = Nothing" & vbCrLf
	d_at(41) = "       Dim json : json = ""{nodes:"" & basenodes.getJSON & ""}""" & vbCrLf
	d_at(42) = "       Set nodes = basenodes.Items(0).nodes" & vbCrLf
	d_at(43) = "       For i = 0 To nodes.count-1" & vbCrLf
'd_at(42) = "       Set nodes = basenodes.Items(0).nodes" & vbCrLf
	d_at(44) = "               If nodes.items(i).orgstype = 0 Then" & vbCrLf
	d_at(45) = "                       fc = fc + 1" & vbCrLf
'd_at(44) = "               If nodes.items(i).orgstype = 0 Then" & vbCrLf
	d_at(46) = "               End if" & vbCrLf
	d_at(47) = "       next" & vbCrLf
	d_at(48) = "       basenodes.dispose" & vbCrLf
	d_at(49) = "       Set basenodes = nothing" & vbCrLf
	d_at(50) = "       json = Replace(json,"""""""",""&#34;"")" & vbCrLf
	d_at(51) = "       json = Replace(json,""<"",""&#60;"")" & vbCrLf
	d_at(52) = "       json = Replace(json,"">"",""&#62;"")" & vbCrLf
	d_at(53) = "       json = Replace(json,""&"",""&#38;"")" & vbCrLf
	d_at(54) = "       Dim inputhtml :  inputhtml = """"" & vbCrLf
	d_at(55) = "       If Len(orgsname)>0 Then inputhtml = inputhtml & ""<input checked type='"" & checktype & ""' style='display:none' id='"" & htmlid & ""_orgs' name='"" & orgsname & ""' value='"" &  orgsvalue & ""'>""" & vbCrLf
	d_at(56) = "       If Len(w1name)>0 Then inputhtml = inputhtml & ""<input checked type='"" & checktype & ""' style='display:none'  id='"" & htmlid & ""_w1' name='"" & w1name & ""' value='"" &  w1value & ""'>""" & vbCrLf
	d_at(57) = "       If Len(w2name)>0 Then inputhtml = inputhtml & ""<input checked type='"" & checktype & ""' style='display:none'  id='"" & htmlid & ""_w2' name='"" & w2name & ""' value='"" &  w2value & ""'>""" & vbCrLf
	d_at(58) = "       If Len(w3name)>0 Then inputhtml = inputhtml & ""<input checked type='"" & checktype & ""' style='display:none'  id='"" & htmlid & ""_w3' name='"" & w3name & ""' value='"" &  realw3 & ""'>""" & vbCrLf
	d_at(59) = "       If Len(changeEvent) > 0 Then changeEvent = "" changeEvent="""""" & Replace(changeEvent,"""""""",""&#34;"") & """""" """ & vbCrLf
	d_at(60) = "       CBaseUserTreeHtmlCore = (inputhtml & ""<iframe ""& changeEvent &"" id='"" & htmlid & ""' json="""""") &  json & ("""""" scrolling='no' frameborder='0' src='"" & sdk.getvirpath & ""sdk/baseusertree.htm?checktype="" & checktype &""&signid="" & htmlid & ""' style='background-color:white;display:block;width:96%;height:"" & ((fc+2)*20+12) & ""px'></iframe>"")" & vbCrLf
	d_at(61) = "End function"
	execute "On Error Resume Next : ExecuteGlobal Join(d_at, vbcrlf)"
	If Len(Correct_W3)=0 Then Correct_W3 = request.form("W3") & ""
	If Len(Correct_W3)=0 Then Correct_W3 = request.querystring("W3") & ""
	Response.write  CBaseUserTreeHtml("select ord,orgsid from gate where 1=1 "&str_w3&" and (del=1 "&SeaStr&")","orgsid", "W1","W2","W3",  "", w1, w2, Correct_W3)
	
	Response.write "</td>" & vbcrlf & "               </tr>" & vbcrlf & "               <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "                 <td><div align=""right"">收入金额</div></td>" & vbcrlf & "                 <td><input name=""duemoney1"" type=""text""  class=""easyui-numberbox"" id=""duemoney1"" size=""10"" maxlength=""25"" min=""0"" max=""999999999999999"" precision="""
	Response.write num_dot_xs
	Response.write """  value=""0"">" & vbcrlf & "                   -" & vbcrlf & "                 <input name=""duemoney2"" type=""text"" id=""duemoney2"" size=""10"" maxlength=""25"" class=""easyui-numberbox"" min=""0"" max=""999999999999999"" precision="""
	Response.write num_dot_xs
	Response.write num_dot_xs
	Response.write """  value=""999999999999999""></td>" & vbcrlf & "               </tr>" & vbcrlf & "                           <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "                 <td><div align=""right"">支出金额</div></td>" & vbcrlf & "                 <td><input name=""duemoney3"" type=""text""  class=""easyui-numberbox"" id=""duemoney3"" size=""10"" maxlength=""25"" min=""0"" max=""999999999999999"" precision="""
	Response.write num_dot_xs
	Response.write num_dot_xs
	Response.write """  value=""0"">" & vbcrlf & "                   -" & vbcrlf & "                 <input name=""duemoney4"" type=""text"" id=""duemoney4"" size=""10"" maxlength=""25"" class=""easyui-numberbox"" min=""0"" max=""999999999999999"" precision="""
	Response.write num_dot_xs
	Response.write num_dot_xs
	Response.write """  value=""999999999999999""></td>" & vbcrlf & "               </tr>" & vbcrlf & "               <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "                 <td><div align=""right"">日期</div></td>" & vbcrlf & "                <td>" & vbcrlf & "                                       <INPUT name=""duepaydate1"" size=""9""  id=""duepaydate1divPos"" onmouseup=toggleDatePicker(""duepaydate1div"",""date.duepaydate1"") value="""
	Response.write m1
	Response.write """><DIV id=""duepaydate1div"" style=""POSITION: absolute;z-index:10"" name =""duepaydate1div""></DIV>" & vbcrlf & "-" & vbcrlf & "         <INPUT name=""duepaydate2"" size=""9""  id=""duepaydate2divPos"" onmouseup=toggleDatePicker(""duepaydate2div"",""date.duepaydate2"") value="""
	Response.write m1
	Response.write m2
	Response.write """><DIV id=""duepaydate2div"" style=""POSITION: absolute;z-index:10"" name =""duepaydate2div""></DIV>                           </td>" & vbcrlf & "               </tr>" & vbcrlf & "               <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "         <td><div align=""right"">摘要</div></td>" & vbcrlf & "                 <td>" & vbcrlf & "         " & vbcrlf & "                           "
	Response.write "" & vbcrlf & "                                     <input value=""1,101"" type=""checkbox"" name=""intro"">合同收款" & vbcrlf & "                            "
'end if
	if ZBRuntime.MC(15000) or ZBRuntime.MC(18700) then
		Response.write "" & vbcrlf & "                                     <input value=""2,201"" type=""checkbox"" name=""intro"">供应商付款" & vbcrlf & "                          "
	end if
	if ZBRuntime.MC(26000) then
		Response.write "" & vbcrlf & "                                     <input value=""3"" type=""checkbox"" name=""intro"">支付工资" & vbcrlf & "                                "
	end if
	if ZBRuntime.MC(27000) then
		Response.write "" & vbcrlf & "                                     <input value=""4"" type=""checkbox"" name=""intro"">费用返还" & vbcrlf & "                                        <input value=""40"" type=""checkbox"" name=""intro"">费用报销" & vbcrlf & "                                       <input value=""50"" type=""checkbox"" name=""intro"">费用借款" & vbcrlf & "                               "
	end if
	if ZBRuntime.MC(22000) then
		Response.write "" & vbcrlf & "                                     <input value=""5"" type=""checkbox"" name=""intro"">账间转出" & vbcrlf & "                                        <input value=""6"" type=""checkbox"" name=""intro"">账间转入" & vbcrlf & "                                "
	end if
	if ZBRuntime.MC(21000) then
		Response.write "" & vbcrlf & "                                     <input value=""7"" type=""checkbox"" name=""intro"">直接入账" & vbcrlf & "                                "
	end if
	if ZBRuntime.MC(25001) then
		Response.write "" & vbcrlf & "                                     <input value=""8"" type=""checkbox"" name=""intro"">销售退款" & vbcrlf & "                                "
	end if
	if ZBRuntime.MC(23002) then
		Response.write "" & vbcrlf & "                                     <input value=""9"" type=""checkbox"" name=""intro"">客户预收款" & vbcrlf & "                                      <input value=""13"" type=""checkbox"" name=""intro"">退客户预收款" & vbcrlf & "                           "
	end if
	if ZBRuntime.MC(20001) then
		Response.write "" & vbcrlf & "                                     <input value=""301"" type=""checkbox"" name=""intro"">承兑入账" & vbcrlf & "                              "
	end if
	if ZBRuntime.MC(20000) then
		Response.write "" & vbcrlf & "                                     <input value=""10"" type=""checkbox"" name=""intro"">直接出账" & vbcrlf & "                               "
	end if
	if ZBRuntime.MC(24002) then
		Response.write "" & vbcrlf & "                                     <input value=""11"" type=""checkbox"" name=""intro"">供应商预付款" & vbcrlf & "                                   <input value=""12"" type=""checkbox"" name=""intro"">退供应商预付款" & vbcrlf & "                         "
	end if
	if ZBRuntime.MC(25002) then
		Response.write "" & vbcrlf & "                                     <input value=""14"" type=""checkbox"" name=""intro"">采购退款" & vbcrlf & "                               "
	end if
	if ZBRuntime.MC(20001) then
		Response.write "" & vbcrlf & "                                     <input value=""302"" type=""checkbox"" name=""intro"">承兑出账" & vbcrlf & "                              "
	end if
	if ZBRuntime.MC(23001) or  ZBRuntime.MC(24001) or ZBRuntime.MC(20001) then
		Response.write "" & vbcrlf & "                                     <input value=""102,202,303"" type=""checkbox"" name=""intro"">手续费" & vbcrlf & "                                "
	end if
	Response.write "" & vbcrlf & "                              </td>" & vbcrlf & "               </tr>" & vbcrlf & "                         <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "                 <td><div align=""right"">关联操作</div></td>" & vbcrlf & "                 <td><input type=""text"" name=""glcz""></td> "& vbcrlf &   "                   </tr> "& vbcrlf &    "           </table>" & vbcrlf &     "              </div> "& vbcrlf & "                  <div region=""south"" border=""false"" style=""text-align:right;height:30px;line-height:30px;padding:5px;padding-right:20px""> "& vbcrlf &    "                           <a class=""easyui-linkbutton""  href=""###"" onClick=""document.getElementById"""
	Response.write from
	Response.write """ />" & vbcrlf & "                      </div>" & vbcrlf & "          </form>" & vbcrlf & " </div>" & vbcrlf & "  " & vbcrlf & ""
	dim actinon1
	action1="银行账户明细"
	call close_list(1)
	Response.write "" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "function Myopen(divID){" & vbcrlf & "  if(divID.style.display==""""){" & vbcrlf & "              divID.style.display=""none""" & vbcrlf & "        }else{" & vbcrlf & "          divID.style.display=""""" & vbcrlf & "    }" & vbcrlf & "       divID.style.left=300;" & vbcrlf & "      divID.style.top=0;" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "<div id=""User"" style=""position:absolute;width:150; height:400;display:none;"">" & vbcrlf & "<table width=""150"" height="""
	if D<>"0" then
		Response.write "300"
	else
		Response.write "250"
	end if
	Response.write """  border=""0"" cellpadding=""-2"" cellspacing=""-2"">" & vbcrlf & "  <tr>" & vbcrlf & "    <td height=""139"">" & vbcrlf & "        <table width=""150"" height=""50"" bgcolor=""#ecf5ff"" border=""0"" >" & vbcrlf & "          <tr valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""###"" onclick=""gotourl('px=1')""><font color=""#2F496E"">按日期排序(降)</font></a></td>" & vbcrlf & "          </tr>" & vbcrlf & "             <tr  valign=""middle"">" & vbcrlf & "            <td height=""24"" colspan=""2"">&nbsp;&nbsp;<a href=""###"" onclick=""gotourl('px=2')""><font color=""#2F496E"">按日期排序(升)</font></a> </td>" & vbcrlf & "          </tr> "& vbcrlf &  "       </table> "& vbcrlf &  "   </td>" & vbcrlf &  " </tr>" & vbcrlf & "</table> "& vbcrlf & "</div>" & vbcrlf & "</body>" & vbcrlf & "</html> "& vbcrlf
	
	
%>
