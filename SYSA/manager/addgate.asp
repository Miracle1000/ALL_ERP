<%@ language=VBScript %>
<%
	Response.Charset="UTF-8"
	Response.ExpiresAbsolute = Now() - 1
	Response.Expires = 0
	Response.CacheControl = "no-cache"
'Response.Expires = 0
	Response.AddHeader "Pragma", "No-Cache"
'Response.Expires = 0
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
'arrStr=split(inputstr,"$")
					Response.write(arrStr(i)&"<br/>")
					tmpstr=tmpstr&Chr(arrStr(i)-rdNum)
'Response.write(arrStr(i)&"<br/>")
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
'GBStr=GBStr & ConvChinese(mid(UTFStr,Dig,9))
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
'Unicode=""
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
'i=0
			if mid(x,len(x)-i,1)="1" then c2to10=c2to10+2^(i)
'i=0
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
'CWebHost=false
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
'd = cstr(day(s_Time))
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
'randomize
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
'formatNumB = "0"& round(numf,num1)
					formatNumB = "-0"& round(numf,num1)
'formatNumB = "0"& round(numf,num1)
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
'pricesFun(1) = CDbl(priceValue)
				If Err.number <> 0 Then  pricesFun(0) = pricesFun(1)
			Else
				pricesFun(0) = CDbl(priceValue)
				pricesFun(1) = CDbl(priceValue) * (1  + cdbl(rsFun("taxRate"))* 0.01 )
'pricesFun(0) = CDbl(priceValue)
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
	Public Function MD5(sMessage)
		Dim b64 : Set b64 = server.createobject(ZBRLibDLLNameSN & ".base64Class")
		MD5 = b64.md5(sMessage & "")
		Set b64 = Nothing
	end function
	dim limitBind
	dim bindSet
	limitBind = ZBRuntime.LimitB
	If limitBind&""="" Then limitBind=-1
	limitBind = ZBRuntime.LimitB
	if limitBind=-1 then
'limitBind = ZBRuntime.LimitB
		bindSet = 21
	else
		bindSet = 1
	end if
	function checkBindUser(userid)
		dim dbindNum
		dbindNum = 0
		if limitBind>0 then
			dim sqlf
			sqlf = "select count(*) from gate where del=1 and isMobileLoginOn = 1"
			if userid&""<>"" then
				sqlf = sqlf & " and ord<>" & userid
			end if
			set rsf = conn.execute(sqlf)
			dbindNum = rsf(0)
			rsf.close
			set rsf = nothing
			if dbindNum >= limitBind then
				checkBindUser = false
			else
				checkBindUser = true
			end if
		else
			checkBindUser = true
		end if
	end function
	Function macBind_list(userid)
		toUseBind = 1
		if len(userid)=0 or userid&""="" then userid=0
		if bindSet<>1 then
			toUseBind = 0
		end if
		Dim isMobileLoginOn : isMobileLoginOn = conn.execute("select top 1 1 from gate where ord=" & userid & " and isMobileLoginOn=1").eof = False
		if toUseBind = 1 then
			Response.write "" & vbcrlf & "    <table width=""100%"" border=""1"" cellpadding=""3"" cellspacing=""0"" bordercolor=""#c0ccdc""  style=""border-collapse:collapse"">" & vbcrlf & "       <tr class="""">" & vbcrlf & "                     <td colspan=""6""><div align=""left""><span style=""font-weight:600; float:left; margin-top:3px; margin-left:10px;"">移动绑定列表 <span style=""font-weight:normal;color:#9999aa"">(注：不添加绑定则移动登录不作任何设备限制 )</span> </span>" & vbcrlf & "                <span style=""float:right;""><input type=""button""  value=""添加绑定"" class=""bindAddBtn anybutton"" onClick=""addBinding('')""></span>" & vbcrlf & "    <div style=""clear:both""></div>" & vbcrlf & "            </div></td>" & vbcrlf & "              </tr>" & vbcrlf & "        <tr>" & vbcrlf & "                       <td colspan=""6"" style=""padding:4px!important"" class=""nopadding32"">" & vbcrlf & "                    <table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""bdlist"">" & vbcrlf & "                        <tr class=""top"">" & vbcrlf & "                        <td style=""text-align:center;height:30px;width:23%"" >手机串号</td>" & vbcrlf & "                        <td style=""text-align:center;width:8%"">状态</td>" & vbcrlf & "<td style=""text-align:center;width:25%;"">备注</td>" & vbcrlf & "                        <td style=""text-align:center;width:10%"">添加人员</td>" & vbcrlf & "                        <td style=""text-align:center;width:12%"">添加时间</td>" & vbcrlf & "                        <td style=""text-align:center;width:22%"">操作</td>" & vbcrlf & "                    </tr>" & vbcrlf & "                    "
			set rs = conn.execute("" &_
			"select a.id,CONVERT(varchar(30),a.date1,20) date1,a.macsn,a.useBind,a.phone,CONVERT(varchar(30),a.date7,20) date7,a.del,a.MobileModel,a.AppVersion," & vbcrlf &_
			"b.name as addName " & vbcrlf &_
			"from Mob_UserMacMap a " & vbcrlf &_
			"left join gate b on a.addcate=b.ord " & vbcrlf &_
			"where userid="& userid &" order by a.date7 desc")
			if rs.eof then
				Response.write "" & vbcrlf & "                    <tr  style=""display:table-row"">" & vbcrlf & "                     <td align=""center""  style=""display:table-cell"" colspan=""6"" class=""blue2"" height=""27"" >暂无绑定</td>" & vbcrlf & "                    </tr>" & vbcrlf & "                    "
'if rs.eof then
			else
				while not rs.eof
					bindid = rs("id")
					date1 = rs("date1")
					macsn = rs("macsn")
					useBind = rs("useBind")
					phone = rs("phone")
					date7 = rs("date7")
					del = rs("del")
					addName = rs("addName")
					mobileModel = rs("mobilemodel")
					appVersion = rs("appversion")
					Response.write "" & vbcrlf & "                    <tr align=""center"" class=""blue2"" id=""tr"
					Response.write bindid
					Response.write """ style=""display:table-row"">" & vbcrlf & "                        <td height=""27"">"
					Response.write bindid
					Response.write macsn
					Response.write "</td>" & vbcrlf & "                        <td>"
					if useBind=True And del = False then Response.write("启用") else Response.write("停用")
					Response.write "</td>" & vbcrlf & "                                         <td>"
					Response.write phone
					Response.write "</td>" & vbcrlf & "                        <td>"
					Response.write addName
					Response.write "</td>" & vbcrlf & "                        <td>"
					Response.write date7
					Response.write "</td>" & vbcrlf & "                        <td><input type=""button"" value="""
					if useBind=True And del = False then Response.write("停用") else Response.write("启用")
					Response.write """ class=""anybutton"" onClick=""bindUse("
					Response.write bindid
					Response.write ","
					if useBind=True And del = False then Response.write("0") else Response.write("1")
					Response.write ")"">" & vbcrlf & "                                                        <input type=""button"" value=""修改"" class=""anybutton"" onClick=""addBinding("
					Response.write bindid
					Response.write ")"">" & vbcrlf & "                                                        <input type=""button"" value=""删除"" class=""anybutton"" onClick=""delBind("
					Response.write bindid
					Response.write ")""></td>" & vbcrlf & "                    </tr>" & vbcrlf & "                                  "
					rs.movenext
				wend
			end if
			rs.close
			set rs = nothing
			Response.write "" & vbcrlf & "                </table>" & vbcrlf & "                      </td>" & vbcrlf & "           </tr>" & vbcrlf & "    </table>" & vbcrlf & ""
		end if
	end function
	Function macBind_add(act, userid, ord, user)
		dim str1 , str2
		if act="add2" then
			str1="修改"
			str2 = " 修 改 "
			if (len(userid)=0 or userid&""="") and (len(ord)=0 or ord&""="") then
				useBind = request("useBind")
				macsn = trim(request("macsn"))
				phone = trim(request("phone"))
				bdNum = trim(request("bdNum"))
			else
				set rs8 = conn.execute("select useBind,macsn,phone from Mob_UserMacMap where id="& ord)
				if not rs8.eof then
					useBind = rs8("useBind")
					macsn = rs8("macsn")
					phone = rs8("phone")
					if useBind=true then useBind=1 else useBind=0
				end if
				rs8.close
				set rs8 = nothing
			end if
		else
			str1="添加"
			str2 = " 添 加 "
		end if
		Response.write "" & vbcrlf & "     <form action=""MacBind.asp"" method=""post"" name=""bind"">    " & vbcrlf & "    <table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "        <tr class=""top"">" & vbcrlf & "                 <td colspan=""2"" height=""30"">&nbsp;&nbsp;移动绑定"
		Response.write str1
		if user="" then
			Response.write "" & vbcrlf & "            <input type=""hidden"" name=""userid"" value="""
			Response.write userid
			Response.write """>" & vbcrlf & "            "
		end if
		Response.write "" & vbcrlf & "            <input type=""hidden"" name=""ord"" value="""
		Response.write ord
		Response.write """></td>" & vbcrlf & "           </tr>" & vbcrlf & "        <tr>" & vbcrlf & "                       <td height=""27"" width=""20%"" align=""right"">是否启用：</td>" & vbcrlf & "            <td width=""80%""><input type=""radio"" name=""useBind"" value=""1"""
		if useBind&""="" or useBind&""="1" then Response.write(" checked")
		Response.write ">启用&nbsp;&nbsp;&nbsp;" & vbcrlf & "            <input type=""radio"" name=""useBind"" value=""0"""
		if useBind&""="0" then Response.write(" checked")
		Response.write ">停用" & vbcrlf & "            <span class=""red"" style=""margin-left:10px"">*</span></td>" & vbcrlf & "                </tr>" & vbcrlf & "        "
'if useBind&""="0" then Response.write(" checked")
		if user="need" then
			Response.write "" & vbcrlf & "        <tr>" & vbcrlf & "                 <td height=""27"" width=""20%"" align=""right"">姓名：</td>" & vbcrlf & "            <td width=""80%"">" & vbcrlf & "            "
			theUser = "请选择人员"
			if userid&""<>"" then
				set rs = conn.execute("select name from gate where ord="& userid)
				if not rs.eof then
					theUser = rs("name")
				end if
				rs.close
				set rs = nothing
			end if
			Response.write "" & vbcrlf & "            <input type=""text"" name=""bduser"" id=""bduser"" value="""
			Response.write theUser
			Response.write """ style=""color:#999999"" onClick=""this.blur();selectUser()"" readonly size=""15"">" & vbcrlf & "            <input type=""hidden"" name=""userid"" id=""userid"" value="""
			Response.write userid
			Response.write """ dataType=""Limit"" min=""1"" max=""50"" msg=""请选择人员""> <span class=""red"">*</span>" & vbcrlf & "            <input type=""hidden"" name=""bindNum"" id=""bindNum"" value="""
			Response.write bindNum
			Response.write """></td>" & vbcrlf & "           </tr>" & vbcrlf & "        "
		end if
		Response.write "" & vbcrlf & "        <tr>" & vbcrlf & "                 <td  align=""right"">手机串号：</td>" & vbcrlf & "            <td><input type=""text"" name=""macsn"" size=""28"" dataType=""Limit"" min=""1"" max=""50"" msg=""长度必须在1—50个字之间"" value="""
		Response.write macsn
		Response.write """>" & vbcrlf & "            <span class=""red"" style=""margin-left:5px"">*</span></td>" & vbcrlf & "         </tr>" & vbcrlf & "        <tr>" & vbcrlf & "                       <td height=""27"" align=""right"">备注：</td>" & vbcrlf & "            <td><input type=""text"" name=""phone"" size=""28"" dataType=""Limit"" min=""0"" max=""50"" msg=""请不要超过50个字"" value="""
		Response.write phone
		Response.write """></td>" & vbcrlf & "           </tr>" & vbcrlf & "        <tr>" & vbcrlf & "                       <td height=""32"" colspan=""2"" align=""center""><span>" & vbcrlf & "            <input type=""button"" value="""
		Response.write str2
		Response.write """ class=""anybutton"" onClick=""if(Validator.Validate(this.form,2)){saveBind(this.form,'"
		if len(ord)>0 or ord&""<>"" then Response.write(ord) else Response.write(bdNum)
		Response.write "')}"">&nbsp;&nbsp;" & vbcrlf & "            <input type=""reset"" value="" 重 填 "" class=""anybutton""></span></td>" & vbcrlf & "         </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td colspan=""2"" align=""center""> <span style=""line-height:22px"" class=""red"">温馨提示：打开APP绑定服务器地址界面，查看手机串号。</span> </td>" & vbcrlf & "           </tr>" & vbcrlf & "    </table>" & vbcrlf & "    </form>" & vbcrlf & ""
	end function
	Function macBind_save()
		userid = trim(request("userid"))
		ord = trim(request("ord"))
		useBind = request("useBind")
		macsn = trim(request("macsn"))
		bdphone = trim(request("phone"))
		addTime = now()
		if bindSet<>1 then
			toUseBind = 0
			Response.write(bindSet &"|")
			call db_close : Response.end
		end if
		if len(ord)>0 or ord&""<>"" then
			if len(userid)>0 or userid&""<>"" then
				set rs2=server.CreateObject("adodb.recordset")
				sql2="select * from Mob_UserMacMap where id="& ord &""
				rs2.open sql2,conn,3,3
				bindNum = rs2.recordCount
				if bindNum>3 then
					Response.write("3|")
					call db_close : Response.end
				else
					conn.begintrans
					set rs3 = conn.execute("select top 1 g.ord,g.name from Mob_UserMacMap m inner join gate g on m.userid=g.ord where m.id<>"& ord &" and m.macsn='"& macsn &"'")
					if not rs3.eof then
						If rs3(0)&"" = userid&"" And userid&""<>"" Then
							Response.write("4|{-/-自己-/-}")
'If rs3(0)&"" = userid&"" And userid&""<>"" Then
						else
							Response.write("4|"& rs3(1))
						end if
						call db_close : Response.end
					else
						yuseBind = rs2("useBind")
						if yuseBind=true then yuseBind="1" else yuseBind="0"
						if useBind="1" then rs2("useBind")=true else rs2("useBind")=False
						rs2("userid")=userid
						rs2("macsn")=macsn
						rs2("phone")=bdphone
						if yuseBind<>useBind then
							rs2("date1")=addTime
						end if
						rs2.update
					end if
					If conn.execute("select count(*) from Mob_UserMacMap where userid=" & userid)(0) > 3 Then
						conn.rollbacktrans
						Response.write("3|")
						call db_close : Response.end
					else
						conn.committrans
						rs3.close
						set rs3 = nothing
					end if
				end if
				rs2.close
				set rs2 = nothing
				if yuseBind<>useBind then
					Response.write("1|"& addTime)
				else
					Response.write("1|")
				end if
			else
				Response.write("0|")
			end if
		else
			if len(userid)>0 or userid&""<>"" then
				set rs2=server.CreateObject("adodb.recordset")
				sql2="select * from Mob_UserMacMap where userid="& userid &""
				rs2.open sql2,conn,3,3
				bindNum = rs2.recordCount
				if bindNum>=3 then
					Response.write("3|")
					call db_close : Response.end
				else
					set rs3 = conn.execute("select top 1 g.ord,g.name from Mob_UserMacMap m inner join gate g on m.userid=g.ord where m.macsn='"& macsn &"'")               'userid<>"& userid &" and
					if not rs3.eof Then
						If rs3(0)&"" = userid&"" And userid&""<>"" Then
							Response.write("4|{-/-自己-/-}")
'If rs3(0)&"" = userid&"" And userid&""<>"" Then
						else
							Response.write("4|"& rs3(1))
						end if
						call db_close : Response.end
					else
						rs2.addnew
						rs2("userid")=userid
						if useBind="1" then rs2("useBind")=true else rs2("useBind")=false
						rs2("macsn")=macsn
						rs2("phone")=bdphone
						rs2("date1")=addTime
						rs2("date7")=addTime
						rs2("del")=0
						rs2("addcate")=session("personzbintel2007")
						rs2.update
					end if
					rs3.close
					set rs3=nothing
				end if
				rs2.close
				set rs2 = nothing
				set rdrs=conn.execute("select IDENT_CURRENT('Mob_UserMacMap')")
				ord=rdrs(0)
				rdrs.close
				set rdrs=Nothing
				Response.write("1|"& ord)
			end if
		end if
	end function
	Function macBind_bindUse(ord, useBind)
		addTime = now
		ybdNum = 0
		if bindSet<>1 then
			toUseBind = 0
			Response.write(bindSet &"|")
			call db_close : Response.end
		end if
		set rs2=server.CreateObject("adodb.recordset")
		sql2="select * from Mob_UserMacMap where id="& ord &""
		rs2.open sql2,conn,3,3
		if rs2.eof then
			Response.write("0|")
		else
			userid = rs2("userid")
			yuseBind = rs2("useBind")
			ydel = rs2("del")
			date1 = rs2("date1")
			if yuseBind=True And ydel = False then yuseBind="1" else yuseBind="0"
			if useBind="1" then
				rs2("useBind")=True
				rs2("del")=0
			else
				rs2("useBind")=False
				rs2("del")=1
			end if
			if useBind<>yuseBind then
				rs2("date1") = addTime
				date1 = addTime
			end if
			rs2.update
			Response.write("1|"& date1)
		end if
		rs2.close
		set rs2 = nothing
	end function
	Function macBind_del(ord)
		userStr = "" : arr_user=""
		set rs8 = conn.execute("select distinct userid from Mob_UserMacMap where id in("& ord &")")
		while not rs8.eof
			userStr = userStr & rs8("userid")&","
			rs8.movenext
		wend
		rs8.close
		set rs8 = nothing
		conn.execute("delete from Mob_UserMacMap where id in("& ord &")")
		if userStr&""<>"" then
			arr_user = split(userStr,",")
			for i=0 to ubound(arr_user)
				if arr_user(i)&""<>"" then
					set rs8 = conn.execute("select userid from Mob_UserMacMap where userid="& arr_user(i) &" and useBind=1")
					if rs8.eof then
						conn.execute("update Mob_UserMacMap set del=1 where userid="& arr_user(i) &"")
					end if
					rs8.close
					set rs8 = nothing
				end if
			next
		end if
		macBind_del = "1"
	end function
	Function macBind_num(userid)
		if userid&""<>"" then
			set rs2 = conn.execute("select count(id) from Mob_UserMacMap where userid="& userid &"")
			if not rs2.eof then
				macBind_num = rs2(0)
			else
				macBind_num = "0"
			end if
		else
			macBind_num = "0"
		end if
	end function
	Function macBind_selectUser()
		Dim isSupperAdmin : isSupperAdmin = conn.execute("select top 1 1 from power where sort1=66 and sort2=12 and qx_open =1 and ord="&session("personzbintel2007")).eof = False
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1=66 and sort2=20"
		rs1.open sql1,conn,1,1
		if rs1.eof then
			open_66_20 = 0
		else
			open_66_20 = rs1("qx_open")
			intro_66_20 = rs1("qx_intro")
		end if
		rs1.close
		set rs1=nothing
		if replace(intro_66_20,",","")="" then intro_66_20="-1"
'set rs1=nothing
		Dim isNormalAdmin : isNormalAdmin = sdk.Info.isAdmin
		If isNormalAdmin Or isSupperAdmin Then
			if open_66_20=1 then
				str_w1=" and ord in (select sorce from gate where ord in (" & intro_66_20 & ") and del=1)"
				str_w2=" and ord in (select sorce2 from gate where ord in (" & intro_66_20 & ") and del=1)"
				str_w3=" and ord in (" & intro_66_20 & ") and del=1"
			elseif open_66_20=3 then
				str_w1=" and ord in (select sorce from gate where del=1)"
				str_w2=" and ord in (select sorce2 from gate where del=1)"
				str_w3=" and del=1"
			else
				str_w1=" and 1=2"
				str_w2=" and 1=2"
				str_w3=" and 1=2"
			end if
		else
			str_w1=" and ord in (select sorce from gate where ord= " & session("personzbintel2007") & " and del=1)"
			str_w2=" and ord in (select sorce2 from gate where ord= " & session("personzbintel2007") & " and del=1)"
			str_w3=" and ord= " & session("personzbintel2007") & " and del=1"
		end if
		str_w1 = str_w1 & " and ord in (select sorce from gate where isMobileLoginOn = 1 and del=1)"
		str_w2 = str_w2 & " and ord in (select sorce2 from gate where isMobileLoginOn = 1 and del=1)"
		str_w3 = str_w3 & " and isMobileLoginOn = 1 and del=1"
		Response.write "" & vbcrlf & "<form name=""secuser"">" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "        <tr>" & vbcrlf & "            <td colspan=""4"">" & vbcrlf & ""
		set rs=server.CreateObject("adodb.recordset")
		sql="select ord,name from gate where cateid=1 " & str_w3 & " order by ord asc"
		rs.open sql,conn,1,1
		if rs.RecordCount<=0 then
			Response.write "&nbsp;"
		else
			do until rs.eof
				Response.write "" & vbcrlf & "                     <input name=""member2"" id=""member2_"
				Response.write rs("ord")
				Response.write """ type=""radio"" value="""
				Response.write rs("name")
				Response.write """ "
				if gateord= rs("ord") then
					Response.write "checked"
				end if
				Response.write ">"
				Response.write rs("name")
				i=i+1
				Response.write rs("name")
				rs.movenext
			loop
		end if
		rs.close
		set rs=nothing
		Response.write "" & vbcrlf & "             </td>" & vbcrlf & "   </tr>" & vbcrlf & "" & vbcrlf & ""
		set rs8=server.CreateObject("adodb.recordset")
		sql8="select ord from gate1 where ord>0 "&str_w1&" order by gate1 desc"
		rs8.open sql8,conn,1,1
		if rs8.RecordCount<=0 then
		else
			do until rs8.eof
				set rs=server.CreateObject("adodb.recordset")
				sql="select ord,name from gate where cateid=2 and sorce="&rs8("ord")&" "&str_w3&" order by ord asc"
				rs.open sql,conn,1,1
				if rs.RecordCount<=0 then
				else
					do until rs.eof
						Response.write "" & vbcrlf & "     <tr>" & vbcrlf & "            <td width=""14%""><div align=""center""></div></td>" & vbcrlf & "             <td colspan=""3"">" & vbcrlf & "                  <input name=""member2""  id=""member2_"
						Response.write rs("ord")
						Response.write """ type=""radio"" value="""
						Response.write rs("name")
						Response.write """ "
						if gateord= rs("ord") then
							Response.write "checked"
						end if
						Response.write ">"
						Response.write rs("name")
						Response.write "" & vbcrlf & "             </td>" & vbcrlf & "   </tr>" & vbcrlf & ""
						rs.movenext
					loop
				end if
				rs.close
				set rs=nothing
				set rs9=server.CreateObject("adodb.recordset")
				sql9="select ord from gate2 where sort1="&rs8("ord")&"  "&str_w2&" order by gate2 desc"
				rs9.open sql9,conn,1,1
				if rs9.RecordCount<=0 then
				else
					do until rs9.eof
						set rs1=server.CreateObject("adodb.recordset")
						sql1="select ord,name from gate where sorce2="&rs9("ord")&" and cateid=3 "&str_w3&" order by ord asc"
						rs1.open sql1,conn,1,1
						if rs1.RecordCount<=0 then
						else
							do until rs1.eof
								Response.write "" & vbcrlf & "     <tr>" & vbcrlf & "            <td colspan=""2"">&nbsp;</td>" & vbcrlf & "               <td colspan=""2"">" & vbcrlf & "                  <input name=""member2"" id=""member2_"
								Response.write rs1("ord")
								Response.write """ type=""radio"" value="""
								Response.write rs1("name")
								Response.write """ "
								if gateord= rs1("ord") then
									Response.write "checked"
								end if
								Response.write ">"
								Response.write rs1("name")
								Response.write "" & vbcrlf & "                     <br>" & vbcrlf & "            </td>" & vbcrlf & "   </tr>" & vbcrlf & ""
								i3=i3+1
								rs1.movenext
							loop
						end if
						rs1.close
						set rs1=nothing
						set rs2=server.CreateObject("adodb.recordset")
						sql2="select ord,name from gate where sorce2="&rs9("ord")&" and cateid=4 "&str_w3&"  order by ord asc"
						rs2.open sql2,conn,1,1
						if rs2.RecordCount<=0 then
						else
							Response.write "" & vbcrlf & "     <tr>" & vbcrlf & "            <td colspan=""2"">&nbsp;</td>" & vbcrlf & "               <td width=""9%"">                   </td>" & vbcrlf & "           <td width=""68%"">" & vbcrlf & ""
							do until rs2.eof
								Response.write "" & vbcrlf & "                     <input name=""member2"" id=""member2_"
								Response.write rs2("ord")
								Response.write """ type=""radio"" value="""
								Response.write rs2("name")
								Response.write """ "
								if gateord= rs2("ord") then
									Response.write "checked"
								end if
								Response.write ">"
								Response.write rs2("name")
								i4=i4+1
								Response.write rs2("name")
								rs2.movenext
							loop
						end if
						rs2.close
						set rs2=nothing
						Response.write "" & vbcrlf & "             </td>" & vbcrlf & "   </tr>" & vbcrlf & ""
						rs9.movenext
					loop
				end if
				rs9.close
				set rs9=nothing
				rs8.movenext
			loop
		end if
		rs8.close
		set rs8=nothing
		Response.write "" & vbcrlf & "</table>" & vbcrlf & "</form>" & vbcrlf & ""
	end function
	Function macBind_chkMacsn(macsn)
		Dim gName
		set rs8 = conn.execute("select top 1 g.name from Mob_UserMacMap m inner join gate g on m.userid=g.ord where m.macsn='"& macsn &"'")
		if not rs8.eof then
			gName = rs8(0)
			macBind_chkMacsn = "2|"& gName
		else
			macBind_chkMacsn = "1|"
		end if
		rs8.close
		set rs8 = nothing
	end function
	Function macBind_bindOpen(ord,isOpen)
		If isOpen = 1 Then
			Dim limitCount : limitCount = ZbRuntime.LimitB
			If limitCount = -1 Or (limitCount > 0 And conn.execute("select count(*) from gate where del=1 and isMobileLoginOn=1")(0) >= limitCount) Then
'Dim limitCount : limitCount = ZbRuntime.LimitB
				macBind_bindOpen = "{success:false,msg:'移动端用户数已到最大限制'}"
				Exit Function
			end if
		end if
		conn.execute "update gate set isMobileLoginOn = " & isOpen & " where ord=" & ord
		macBind_bindOpen = "{success:true,msg:'操作成功！'}"
	end function
	currCate = session("personzbintel2007")
	If currCate&"" = "" Then currCate = 0
	Set rs = conn.execute("select top 1 isnull(qx_open,0) qx_open from power where ord="& currCate &" and sort1=66 and sort2 in(12,13) order by isnull(qx_open,0) desc")
	If rs.eof = False Then
		open_66_13 = rs("qx_open")
	end if
	rs.close
	set rs = nothing
	If open_66_13&"" = "" Then open_66_13 = 0
	if open_66_13&"" = "0" then
		Response.write "<script>alert('抱歉，您无权访问此页面！');window.close();</script>"
		call db_close : Response.end
	end if
	limitcount=ZBRuntime.LimitC
	CanUseOnlineSVR=1
	LimitOnlineSVR = ZBRuntime.LimitOnlineSVR
	If LimitOnlineSVR&""="" Then LimitOnlineSVR=-1
'LimitOnlineSVR = ZBRuntime.LimitOnlineSVR
	If LimitOnlineSVR<=0 Then CanUseOnlineSVR=0
	if limitcount<>0 then
		set rsCountNow=conn.execute("select count(*) from gate where del=1")
		if rsCountNow(0)>=limitcount then
			Response.write "<script>alert('当前总账号数【"&rsCountNow(0)&"】已达到上限值【"&limitcount&"】,不能再添加账号\n如有疑问请联系智邦国际！');window.close();</script>"
			rsCountNow.close
			call db_close : Response.end
		end if
		rsCountNow.close
	end if
	dim MODULES
	MODULES=session("zbintel2010ms")
	toUseBind = 1
	limitBind = ZBRuntime.LimitB
	If limitBind&""="" Then limitBind=-1
'limitBind = ZBRuntime.LimitB
	if limitBind=-1 then
'limitBind = ZBRuntime.LimitB
		toUseBind = 0
	end if
	dim h
	h=request("h")
	if h="" then h=1
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select sort1,qx_open,w1,w2,w3 from power2  where cateid="&session("personzbintel2007")&" and sort1=4"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_1_1=0
	else
		open_1_1=rs1("qx_open")
		w1_list=rs1("w1")
		w2_list=rs1("w2")
		w3_list=rs1("w3")
	end if
	rs1.close
	set rs1=nothing
	if open_1_1=1 Then
		If w1_list = "" Then w1_list = "-222"
'if open_1_1=1 Then
		If w2_list = "" Then w2_list = "-222"
'if open_1_1=1 Then
		If w3_list = "" Then w3_list = "-222"
'if open_1_1=1 Then
		str_w1="where ord in ("&w1_list&")"
		str_w2="ord in ("&w2_list&") and "
		str_w3="and ord in ("&w3_list&") and del=1"
	elseif open_1_1=3 then
		str_w1=""
		str_w2=""
		str_w3="and del=1"
	else
		str_w1="where ord=0"
		str_w2="ord=0 and "
		str_w3="and ord=0 and del=1"
	end if
	sql="Delete power where ord in (select ord from gate where del=7 and addcate="&session("personzbintel2007")&")"
	conn.Execute(sql)
	sql="delete sort5_gate where gateord in ( select ord from gate where del=7 and addcate="&session("personzbintel2007")&")"
	conn.execute(sql)
	sql="Delete gate where del=7 and addcate="&session("personzbintel2007")&""
	conn.Execute(sql)
	sql="insert into gate(addcate,del,date7) values('" & session("personzbintel2007") & "',7,getdate())"
	conn.execute(sql)
	Dim gord
	gord=0
	sql="select top 1 ord from gate where del=7 and addcate="&session("personzbintel2007")&" order by ord desc"
	gord=conn.execute(sql)(0).value
	sort_1=0
	set rs=conn.execute("select top 1 unreplyback1 from sort5 where unreplyback1=3")
	if rs.eof=false then
		sort_1=rs("unreplyback1")
	end if
	sort_2=0
	set rs=conn.execute("select top 1 unreplyback2 from sort5  where unreplyback2=3 ")
	if rs.eof=false then
		sort_2=rs("unreplyback2")
	end if
	sort_3=0
	set rs=conn.execute("select top 1 unsalesback from sort5  where unsalesback=3 ")
	if rs.eof=false then
		sort_3=rs("unsalesback")
	end if
	stayback=0
	set rs=conn.execute("select top 1 stayback from sort5  where stayback=3 ")
	if rs.eof=False then
		stayback=rs("stayback")
	end if
	maxback=0
	set rs=conn.execute("select top 1 maxback from sort5  where maxback=3 ")
	if rs.eof=false then
		maxback=rs("maxback")
	end if
	set rs=conn.execute("select intro from setopen  where sort1=25")
	if rs.eof then
		sort_4=0
	else
		sort_4=rs("intro")
	end if
	set rs=conn.execute("select intro from setopen  where sort1=37")
	if rs.eof then
		sort_ly=0
	else
		sort_ly=rs("intro")
	end if
	set rs=conn.execute("select intro from setopen  where sort1=26")
	if rs.eof then
		sort_5=0
	else
		sort_5=rs("intro")
	end if
	set rs=conn.execute("select intro from setopen  where sort1=27")
	if rs.eof then
		sort_6=0
	else
		sort_6=rs("intro")
	end if
	set rs=conn.execute("select intro from setopen  where sort1=3001")
	if rs.eof then
		sort_xm_1=0
	else
		sort_xm_1=rs("intro")
	end if
	set rs=conn.execute("select intro from setopen  where sort1=3002")
	if rs.eof then
		sort_xm_2=0
	else
		sort_xm_2=rs("intro")
	end if
	set rs=conn.execute("select intro from setopen  where sort1=3003")
	if rs.eof then
		sort_xm_3=0
	else
		sort_xm_3=rs("intro")
	end if
	set rs=conn.execute("select isnull(intro,0) as intro from setopen  where sort1=39 ")
	if rs.eof then
		sort_apply=0
	else
		sort_apply=rs("intro")
		rs.close
		set rs=Nothing
	end if
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
'set rs=Nothing
    Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<script language=""javascript"" src=""../sortcp/function.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=javascript>" & vbcrlf & "function ask() {" & vbcrlf & "document.all.date.action = ""writegate.asp?sort=2&h="
	Response.write h
	Response.write """;" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & ""
	Response.write "<script language=""javascript"">"&chr(13)
	Response.write "<!--"&chr(13)
	Response.write "<script language=""javascript"">"&chr(13)
	Response.write "var ListUserName=new Array();"&chr(13)
	Response.write "var ListUserId=new Array();"&chr(13)
	set rss=conn.execute("select * from gate1 "&str_w1&"")
	while not rss.eof
		sid=rss("id")
		Response.write "ListUserName["&sid&"]=new Array();"&chr(13)
		Response.write "ListUserId["&sid&"]=new Array();"&chr(13)
		Response.write "ListUserName["&sid&"][0]='--"& rss("sort1") & "--';"&chr(13)
		Response.write "ListUserId["&sid&"]=new Array();"&chr(13)
		Response.write "ListUserId["&sid&"][0]='';"&chr(13)
		set rsi=conn.execute("select * from gate2 where "&str_w2&" sort1="&rss("id"))
		index1=1
		while not rsi.eof
			Response.write "ListUserName["&sid&"]["&Index1&"]='"&rsi("sort2")&"';"&chr(13)
			Response.write "ListUserId["&sid&"]["&Index1&"]='"&rsi("Id")&"';"&chr(13)
			Index1=Index1+1
			'Response.write "ListUserId["&sid&"]["&Index1&"]='"&rsi("Id")&"';"&chr(13)
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
	Response.write "" & vbcrlf & "<script src= ""../Script/mr_addgate.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """  language=""javascript"" type=""text/javascript""></script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"">" & vbcrlf & "function checkLoginNameFlag(){" & vbcrlf & "      var flag=document.getElementById(""flag"").value;" & vbcrlf & "   if(flag==""1""){" & vbcrlf & "            document.getElementById(""checkflag"").innerHTML=""用户名已存在"";" & vbcrlf & "                return false;" & vbcrlf & "   }" & vbcrlf & "       "
	if toUseBind = 1 then
		Response.write "" & vbcrlf & "     else{" & vbcrlf & "   var url = ""../Mobile/Macbind.asp?act=checkAllBind&timestamp="" + new Date().getTime() + ""&date1=""+ Math.round(Math.random()*100);" & vbcrlf & "    xmlHttp.open(""GET"", url, false);" & vbcrlf & "  xmlHttp.send(null); " & vbcrlf & "    if (xmlHttp.readyState == 4){" & vbcrlf & "          var response = xmlHttp.responseText;" & vbcrlf & "            if(response==""20""){" & vbcrlf & "                       alert(""请输入数字签名!"");" & vbcrlf & "                 return false;" & vbcrlf & "           }else if(response==""21""){" & vbcrlf & "                 alert(""您的账号还不支持移动端绑定!"");" & vbcrlf & "                     return false;" & vbcrlf & "           }else if(response==""22""){" & vbcrlf & "                       alert(""移动端用户数已到最大限制"");" & vbcrlf & "                        return false;" & vbcrlf & "           }                       " & vbcrlf & "                xmlHttp.abort();" & vbcrlf & "        }" & vbcrlf & "" & vbcrlf & "       " & vbcrlf & "        }" & vbcrlf & "       "
	end if
	Response.write "" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function refreshUserList(){" & vbcrlf & " if(window.opener!=null){" & vbcrlf & "                window.setTimeout(function(){" & vbcrlf & "                   try{" & vbcrlf & "                            var obj = window.opener.window ;" & vbcrlf & "                                if (obj.parent.document.getElementById('cFF2')){" & vbcrlf & "                                        obj = window.opener.parent.window;" & vbcrlf & "                              }" & vbcrlf & "                               obj.jQuery('.nodeSwitch:hidden')[0].onclick.call(null,[]);" & vbcrlf & "                      }catch(e){" & vbcrlf & "                              " & vbcrlf & "                        }" & vbcrlf & "               },500);" & vbcrlf & " }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "window.OnFieldAutoCompleteCallBack  = function(obj){" & vbcrlf & "  document.getElementById(""orgsname"").value = obj.text;" & vbcrlf & "     document.getElementById(""orgsid"").value = obj.value;" & vbcrlf & "      document.getElementById(""orgsname"").style.color = ""#000"";" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function showPartSel(){" & vbcrlf & "     window.open(""../../SYSN/view/magr/OrganizList.ashx?linkbar=1"",""assfads"",""width=400px,height=600px,resizable=1,scrollbars=1"")" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "</head>" & vbcrlf & "<body onUnload=""refreshUserList();"">" & vbcrlf & "<table width=""100%""  border=""0"" align=""center"" cellpadding=""0"" cellspacing=""0"" bordercolor=""#E2E2E1"" bgcolor=""#FFFFFF"">" & vbcrlf & "  <tr>" & vbcrlf & "    <td width=""100%"" valign=""top"">" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" height=""27"">" &vbcrlf & "              <tr>" & vbcrlf & "                <td width=""5%"" height=""27""  background=""../images/contentbg.gif""><div align=""center""><img src=""../images/contenttop.gif""height=""27""> </div></td>" & vbcrlf & "                <td width=""47%""  background=""../images/contentbg.gif""> " & vbcrlf & "                  <strong><font color=""#1445A6"">添加账号</font></strong> </td> " & vbcrlf & "                <td width=""48%""  background=""../images/contentbg.gif"">&nbsp;</td> " & vbcrlf & "        </tr> " & vbcrlf & "      </table> " & vbcrlf & " <form action=""writegate.asp"" method=""post"" style='display:inline'　id=""demo"" onsubmit=""return Validator.Validate(this,2)&&checkLoginNameFlag()"" name=""date""> " & vbcrlf & " <table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content""> " & vbcrlf & "    <input type=""hidden"" id=""flag""  name=""flag"" value=""0"">" & vbcrlf & "      <tr class=""top"">" & vbcrlf & "        <td colspan=""4""><div align=""left"">用户账号信息</div></td>" & vbcrlf & "        <td colspan=""2"" align=""right""><div align=""right"">" & vbcrlf & "                  <input type=""hidden"" name=""gord"" value="""
	Response.write gord
	Response.write """ >" & vbcrlf & "            <input type=""submit"" name=""Submit422"" value=""保存"" class=""page""/>" & vbcrlf & "            <input type=""submit"" name=""Submit42"" value=""增加"" onClick=""ask();"" class=""page""/>" & vbcrlf & "            <input type=""reset"" value=""重填"" class=""page"" onclick='document.getElementById(""orgsname"").style.color = ""#ccc"";' name=""B2"">" & vbcrlf & "        </div></td>" & vbcrlf & "        </tr>" & vbcrlf & "      <tr>" & vbcrlf & "        <td><div align=""right"">所在部门：</div></td>" & vbcrlf & "        <td width=""24%""><div align=""left""><span class=""gray"">" & vbcrlf & "              <input name='orgsid' id='orgsid' type='hidden'  dataType=""Limit"" min=""1"" max=""500""  msg=""请选择部门"">" & vbcrlf & "           <input type='text'  id='orgsname'  onclick='showPartSel()' style=""width:130px;cursor:pointer;color:#ccc;text-align:center"" value='请点击选择部门'  readonly > <a href='javascript:void(0)' onclick='showPartSel()'>选择</a>" & vbcrlf & "</span></div></td>" & vbcrlf & "        <td width=""11%"">" & vbcrlf & "              <div align=""right"">职位名称：</div></td>" & vbcrlf & "        <td width=""18%""><input name=""title"" type=""text"" size=""10"" dataType=""Limit"" min=""1"" max=""20""  msg=""长度必须在1—20个字之间""><span class=""red""> *</span>" & vbcrlf & "              </td>" & vbcrlf & "        <td><div align=""right"">部门管理：</div></td>" & vbcrlf & "          <td><input name=""partadmin"" type=""radio"" value=""1"">是" & vbcrlf & "                        <input type=""radio"" name=""partadmin"" value=""0"" checked>否" & vbcrlf & "            </td>" & vbcrlf & "      </tr>" & vbcrlf & ""
	set rs7=server.CreateObject("adodb.recordset")
	sql7="select qx_open from power where ord="&session("personzbintel2007")&" and sort1=66 and sort2=12"
	rs7.open sql7,conn,1,1
	if rs7.eof then
		qx_fp=0
	else
		qx_fp=rs7("qx_open")
		if qx_fp<>"" then
		else
			qx_fp=0
		end if
	end if
	rs7.close
	set rs7=Nothing
	If ZBRuntime.MC(39000)=True Then
		strCols=""
	else
		strCols="colspan='5'"
	end if
	Response.write "" & vbcrlf & "      <tr>" & vbcrlf & "        <td width=""12%"">" & vbcrlf & "        <p align=""right"">用 户 名：</td>" & vbcrlf & "        <td><input name=""user"" type=""text"" id=""user""  style=""width:130px;"" dataType=""Limit"" min=""1"" max=""50""  msg=""用户名长度必须在1－50位之间"" onBlur=""checkLoginName(this.value)""/>" & vbcrlf & "           <span id=""test1"" class=""red""> * </span><span class=""red"" id=""checkflag""></span></td>" & vbcrlf & "              <td style='text-align:right'>岗  位：</td>" & vbcrlf & "              <td>" & vbcrlf & "                  <select name=""workPosition"" dataType=""Limit"" min=""1"" max=""20""  msg=""请选择岗位""> " & vbcrlf & "                           <option value=""></option> " & vbcrlf
	Set rspos = conn.execute("select * from sortonehy where gate2=1080 order by gate1 desc,ord")
	While rspos.eof = False
		Response.write "" & vbcrlf & "                             <option value="""
		Response.write rspos("id")
		Response.write """>"
		Response.write rspos("sort1")
		Response.write "</option>" & vbcrlf & ""
		rspos.movenext
	wend
	rspos.close
	Set rspos=Nothing
	Response.write "" & vbcrlf & "                     </select><span id=""test2"" class=""red""> * </span>" & vbcrlf & "              </td>" & vbcrlf & "        <td><div align=""right"">账号性质：</div></td>" & vbcrlf & "        <td><input name=""top1"" type=""radio"" value=""0"" checked>普通账号" & vbcrlf & "          "
	if qx_fp=1 then
		Response.write " <input type=""radio"" name=""top1"" value=""1"">管理员账号"
	end if
	Response.write "" & vbcrlf & "               </td>" & vbcrlf & "        </tr>" & vbcrlf & "      <tr>" & vbcrlf & "        <td>" & vbcrlf & "        <p align=""right"">密　　码：</td>" & vbcrlf & "        <td><div align=""left"">" & vbcrlf & "          <input type=""password"" name=""password""  style=""width:130px;"" dataType=""Limit"" min=""6"" max=""50""  msg=""密码长度必须在6—50位之间"">" & vbcrlf & "          <span class=""gray""><span id=""test1"" class=""red""> *<span id=""test1"" class=""red""></span> </span></span></div></td>" & vbcrlf & "        <td><div align=""right"">自动关联上级：</div></td>" & vbcrlf & "        <td colspan=""3""><div align=""left""><input type=""checkbox"" name=""autolink"" value=""1"">选中后保存将会自动给所有上级增加此账号权限</div></td>" & vbcrlf & "      </tr>" & vbcrlf & "      <tr>" & vbcrlf & "        <td>" & vbcrlf & "          <div align=""right"">密码确认：</div></td>" & vbcrlf & "        <td "
	Response.write strCols
	Response.write "><div align=""left"">" & vbcrlf & "          <input type=""password"" name=""Repeat""  style=""width:130px;"" dataType=""Repeat"" to=""password"" msg=""两次输入的密码不一致"">" & vbcrlf & "        </div></td>" & vbcrlf & "             "
	If strCols="" Then
		Response.write "" & vbcrlf & "                     <td><div align=""right"">生成档案：</div></td>" & vbcrlf & "                      <td colspan=""3""><div align=""left""><input type=""checkbox"" name=""autohrm"" value=""1"">选中后保存将会自动生成档案资料</div></td>" & vbcrlf & "               "
	end if
	Response.write "" & vbcrlf & "      </tr>" & vbcrlf & "  "
	if ZBRuntime.MC(60000) Then
		displaystr="style='display:none'"
		Set rsjmg=conn.execute("select isnull(num1,0) from setjm3 where ord=29")
		If Not rsjmg.eof Then
			If rsjmg(0)=1 Then
				displaystr=""
			end if
		end if
		rsjmg.close
		Response.write "" & vbcrlf & "             <tr "
		Response.write displaystr
		Response.write ">" & vbcrlf & "                    <td><div align=""right"">是否启用加密锁登录：</div></td>" & vbcrlf & "                    <td>" & vbcrlf & "                    <input type=""radio"" name=""jmgou""  value=""1"">启用" & vbcrlf & "                      <input type=""radio"" name=""jmgou""  value=""0"" checked>不启用" & vbcrlf & "                    </td>" & vbcrlf & "                   <td><div align=""right"">请选择加密锁：</div></td> " & vbcrlf & "                        <td colspan=""3""> " & vbcrlf & ""
		selected=""
		Set rs=conn.execute("select id,jmgxlh,jmgtitle,cateid from jmgoulist where isnull(isuse,0)=0 order by id asc")
		If Not rs.eof Then
			Response.write "<select id='jmgxlh' name='jmgxlh'><option value=''></option>"
			while Not rs.eof
				jmgid=rs("id")
				jmgtitle=rs("jmgtitle")
				cateid=rs("cateid")
				Response.write "<option value='"&jmgid&"'>"&jmgtitle&"</option>"
				rs.movenext
			wend
			Response.write "</select>"
		else
			Response.write "<span class='red'>没有可选择的加密锁</span>"
		end if
		rs.close
		Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "           </tr>" & vbcrlf & "   "
	end if
	if  sdk.Info.isSupperAdmin and CanUseOnlineSVR=1 then
		Response.write "" & vbcrlf & "             <tr>" & vbcrlf & "                    <td height=""30""><div align=""right"">启用在线客服：</div></td>" & vbcrlf & "                        <td colspan=""5"">" & vbcrlf & "                <input type=""radio"" name=""onlinesvr""  id=""onlinesvr1"" value=""1"" onClick=""saveOnlineOpen('0',1);"">启用" & vbcrlf & "                           <input type=""radio"" name=""onlinesvr""  id=""onlinesvr0"" onClick=""saveOnlineOpen('0',0);"" value=""0"" checked>不启用&nbsp;" & vbcrlf & "                              <span style=""color:#BBBBBB"">该功能用于贵公司企业软件对接人与专属客服在软件使用过程中进行沟通和交流</span>" & vbcrlf & "                 </td>" & vbcrlf & "           </tr>" & vbcrlf & "   "
	end if
	adminor = ""
	set rs2 = conn.execute("select top 1 name from gate where ord ="& session("personzbintel2007"))
	if not rs2.eof then
		adminor = rs2("name")
	end if
	rs2.close
	set rs2 = nothing
	intro_66_20 = sdk.Power.GetPowerIntro(66,20)
	If intro_66_20 = "" Then
		if toUseBind = 1 then
			Response.write "" & vbcrlf & "             <tr>" & vbcrlf & "                    <td height=""30""><div align=""right"">启用移动登录：</div></td>" & vbcrlf & "                        <td colspan=""5"">" & vbcrlf & "                <input type=""radio"" name=""bindMobile"" class=""bindRadio"" id=""bindMobile1"" value=""1"" " & vbcrlf & "                                 onClick=""saveBindingOpen('0',1);$('#mactr').show();loadBinding(1,true);"">启用" & vbcrlf & "                <input type=""radio"" name=""bindMobile"" class=""bindRadio"" id=""bindMobile0"" value=""0"" " & vbcrlf & "                                 checked onClick=""saveBindingOpen('0',0);$('#mactr').hide();loadBinding(0,true);"">不启用" & vbcrlf & "    <input type=""hidden"" name=""bindList"" id=""bindList"">" & vbcrlf & "                           "
			If zbruntime.mc(64000) then
				Response.write "" & vbcrlf & "                             <span id=""spn_OpenGPS"" style=""padding-left:30px;display:none"">" & vbcrlf & "                                      启动行动轨迹:<input type=""radio"" name=""OpenGPS"" id=""OpenGPS1"" value=""1"" "
'If zbruntime.mc(64000) then
				if GPS_Open="1" then Response.write("checked")
				Response.write " onClick=""this.blur();"">启用" & vbcrlf & "                                   <input type=""radio"" name=""OpenGPS"" id=""OpenGPS0"" value=""0"" "
				if GPS_Open<>"1" then Response.write("checked")
				Response.write " onClick=""this.blur();"">不启用" & vbcrlf & "                         </span>" & vbcrlf & "                         "
			end if
			Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr id=""mactr"" style=""display:none"">" & vbcrlf & "                        <td colspan=""6""><div id=""macBinding"">"
			Call macBind_list("0")
			Response.write "</div></td>" & vbcrlf & "          </tr>" & vbcrlf & ""
		end if
	end if
	if ZBRuntime.MC(12001) or ZBRuntime.MC(12002) or ZBRuntime.MC(12003) or ZBRuntime.MC(12004) or ZBRuntime.MC(12006) or ZBRuntime.MC(12007) or ZBRuntime.MC(12008) then
		if sort_1>2 or sort_xm_1>0 then Response.write "<tr>"
		ktmp=0
		if sort_1>2 then
			Response.write "" & vbcrlf & "                     <td><div align=""right"">(客户)领用未联系收回：</div></td>" & vbcrlf & "                  <td class=""gray"">&nbsp;<a href=""#"" onclick=""javascript:window.open('set_sort5back.asp?ord="
			Response.write pwurl(gord)
			Response.write "&sort=1','telapply','width=' + 800 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=50')"">设置</a> <span class=""red""> *</span></span></td>" & vbcrlf & ""
			'Response.write pwurl(gord)
			ktmp=ktmp+1
			'Response.write pwurl(gord)
		end if
		if sort_xm_1>0 then
			Response.write "" & vbcrlf & "                     <td><div align=""right"">(项目)领用未联系收回：</div></td>" & vbcrlf & "                  <td class=""gray""><input name=""num_xm_1"" type=""text"" size=""10"" maxlength=""4"" value="""
			Response.write num_xm_1
			Response.write """ onkeyup=""value=value.replace(/[^\d\.]/g,'')"" dataType=""Limit"" min=""1"" max=""15""  msg=""必填""><span class=""name""> 天<span class=""red""> *</span></span></td>" & vbcrlf & ""
			ktmp=ktmp+1
		end if
		if ktmp > 0 then Response.write "<td colspan='"&(3-ktmp)*2&"'><div></div></td>"
		if sort_1>2 or sort_xm_1>0 then Response.write "</tr>"
		if sort_2>2 or sort_xm_2>0 then Response.write "<tr>"
		ktmp=0
		if sort_2>2 then
			Response.write "" & vbcrlf & "                     <td><div align=""right"">(客户)间隔未联系收回：</div></td>" & vbcrlf & "                  <td class=""gray"">&nbsp;<a href=""#"" onclick=""javascript:window.open('set_sort5back.asp?ord="
			Response.write pwurl(gord)
			Response.write "&sort=2','telapply','width=' + 800 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=50')"">设置</a> <span class=""red""> *</span></span></td>" & vbcrlf & ""
			'Response.write pwurl(gord)
			ktmp=ktmp+1
			'Response.write pwurl(gord)
		end if
		if sort_xm_2>0 then
			Response.write "" & vbcrlf & "                     <td><div align=""right"">(项目)间隔未联系收回：</div></td>" & vbcrlf & "                  <td class=""gray""><input name=""num_xm_2"" type=""text"" size=""10"" maxlength=""4"" value="""
			Response.write num_xm_2
			Response.write """ onkeyup=""value=value.replace(/[^\d\.]/g,'')"" dataType=""Limit"" min=""1"" max=""15""  msg=""必填""><span class=""name""> 天<span class=""red""> *</span></span></td>" & vbcrlf & ""
			ktmp=ktmp+1
		end if
		if ktmp > 0 then Response.write "<td colspan='"&(3-ktmp)*2&"'><div></div></td>"
		if sort_2>2 or sort_xm_2>0 then Response.write "</tr>"
	end if
	if sort_3>2 or sort_xm_3>0 then Response.write "<tr>"
	ktmp=0
	if sort_3>2 then
		Response.write "" & vbcrlf & "                     <td><div align=""right"">(客户)跟进未成功收回：</div></td>" & vbcrlf & "                  <td class=""gray"">&nbsp;<a href=""#"" onclick=""javascript:window.open('set_sort5back.asp?ord="
		Response.write pwurl(gord)
		Response.write "&sort=3','telapply','width=' + 800 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=50')"">设置</a> <span class=""red""> *</span></span></td>" & vbcrlf & ""
		'Response.write pwurl(gord)
		ktmp=ktmp+1
		'Response.write pwurl(gord)
	end if
	if sort_xm_3>0 then
		Response.write "" & vbcrlf & "                     <td><div align=""right"">(项目)跟进未成功收回：</div></td>" & vbcrlf & "                  <td class=""gray""><input name=""num_xm_3"" type=""text"" size=""10"" maxlength=""4"" value="""
		Response.write num_xm_3
		Response.write """ onkeyup=""value=value.replace(/[^\d\.]/g,'')"" dataType=""Limit"" min=""1"" max=""15""  msg=""必填""><span class=""name""> 天<span class=""red""> *</span></span></td>" & vbcrlf & ""
		ktmp=ktmp+1
	end if
	if ktmp > 0 then Response.write "<td colspan='"&(3-ktmp)*2&"'><div></div></td>"
	if sort_3>2 or sort_xm_3>0 then Response.write "</tr>"
	if stayback>2 or maxback>0 then Response.write "<tr>"
	ktmp=0
	if stayback>2 then
		Response.write "" & vbcrlf & "                     <td style=""word-break:keep-all""><div align=""right"">客户跟进最大天数收回：</div></td>" & vbcrlf & "                        <td class=""gray"">&nbsp;<a href=""#"" onclick=""javascript:window.open('set_sort5back.asp?ord="
'if stayback>2 then
		Response.write pwurl(gord)
		Response.write "&sort=4','telapply','width=' + 800 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=50')"">设置</a> <span class=""red""> *</span></span></td>" & vbcrlf & ""
		'Response.write pwurl(gord)
		ktmp=ktmp+1
		'Response.write pwurl(gord)
	end if
	if maxback>2 then
		Response.write "" & vbcrlf & "                     <td style=""word-break:keep-all""><div align=""right"">领用最大天数收回：</div></td>" & vbcrlf & "                    <td class=""gray""><a href=""#"" onclick=""javascript:window.open('set_sort5back.asp?ord="
'if maxback>2 then
		Response.write pwurl(gord)
		Response.write "&sort=5','telapply','width=' + 800 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=50')"">设置</a><span class=""red""> *</span></span></td>" & vbcrlf & ""
		'Response.write pwurl(gord)
		ktmp=ktmp+1
		'Response.write pwurl(gord)
	end if
	if ktmp > 0 then Response.write "<td colspan='"&(3-ktmp)*2&"'><div></div></td>"
	'Response.write pwurl(gord)
	if stayback>2 or maxback>0 then Response.write "</tr>"
	if sort_4>0 Then
		If sort_4=2 Then
			set rs=server.CreateObject("adodb.recordset")
			sql="select top 1 num_4 from gate  where del=1 "
			rs.open sql,conn,1,1
			if rs.eof then
				num_4=""
			else
				num_4=rs("num_4")
			end if
			rs.close
			set rs=nothing
		end if
		Response.write "" & vbcrlf & "       <tr>" & vbcrlf & "      <td><div align=""right"">客户数量上限：</div></td>" & vbcrlf & "          <td  colspan=""5"" class=""gray""><input name=""num_4"" type=""text"" size=""10""  maxlength=""4""  value="""
		Response.write num_4
		Response.write """ onkeyup=""value=value.replace(/[^\d\.]/g,'')""   dataType=""Limit"" min=""1"" max=""15""  msg=""必填"">" & vbcrlf & "           <span class=""name""> 个 <span class=""red""> *</span></span></td>" & vbcrlf & "            </tr>" & vbcrlf & ""
	end if
	if sort_ly>0 Then
		If sort_ly=2 Then
			Set rs=conn.execute("select top 1 num_ly from gate  where del=1")
			If rs.eof Then
				num_ly=""
			else
				num_ly=rs(0)
			end if
			rs.close
		end if
		Response.write "" & vbcrlf & "       <tr>" & vbcrlf & "      <td><div align=""right"">每日领用上限：</div></td>" & vbcrlf & "          <td  colspan=""5"" class=""gray""><input name=""num_ly"" type=""text"" size=""8""  maxlength=""8""  value="""
		Response.write num_ly
		Response.write """ onkeyup=""value=value.replace(/[^\d\.]/g,'')""   dataType=""Limit"" min=""1"" max=""15""  msg=""必填"">" & vbcrlf & "           <span class=""name""> 个 <span class=""red""> *</span></span></td>" & vbcrlf & "            </tr>" & vbcrlf & ""
	end if
	if sort_apply>0 then
		Response.write "" & vbcrlf & "         <tr>" & vbcrlf & "            <td><div align=""right"">客户领用范围：</div></td>" & vbcrlf & "          <td  colspan=""5"" class=""gray"">" & vbcrlf & "          "
		Call show_tel_apply(gord)
		Response.write "" & vbcrlf & "          </td>" & vbcrlf & "          </tr>" & vbcrlf & "               "
	end if
	Response.write "" & vbcrlf & "             <tr class=""top"">" & vbcrlf & "        <td colspan=""6""><div align=""left"">员工基本信息</div></td>" & vbcrlf & "        </tr>" & vbcrlf & "                 <tr>" & vbcrlf & "        <td><div align=""right"">姓　　名：</div></td>" & vbcrlf & "        <td><input type=""text"" name=""name"" size=""15""class=""text"" dataType=""Limit"" min=""1"" max=""50""  msg=""长度必须在1—50个字之间"">" & vbcrlf & "          <span class=""gray""><span id=""test1"" class=""red""> *<span id=""test1"" class=""red""></span> </span></td>" & vbcrlf & "        <td><div align=""right"">员工编号：</div></td>" & vbcrlf & "        <td><input name=""ygid"" type=""text"" size=""15"" dataType=""Limit"" min=""0"" max=""50""  msg=""太长了""></td>" & vbcrlf & "        <td width=""10%""><div align=""right"">身份证号：</div></td>" & vbcrlf & "               <td width=""25%""><input name=""cardid"" type=""text"" size=""18"" dataType=""Limit"" min=""0"" max=""50""  msg=""太长了""></td>" & vbcrlf & "                </tr>" & vbcrlf & "         <tr>" & vbcrlf & "           <td><div align=""right"">性　　别：</div></td>" & vbcrlf & "           <td><input name=""sex"" type=""radio"" value=""男"" checked>" & vbcrlf & "             男" & vbcrlf & "             <input type=""radio"" name=""sex"" value=""女""> " & vbcrlf & "             女</td>  " & vbcrlf & "           <td><div align=""right"">籍　　贯：</div></td> " & vbcrlf & "            <td><input name=""jg"" type=""text"" size=""15"" dataType=""Limit"" min=""0"" max=""50""  msg=""太长了""></td> " & vbcrlf & "           <td><div align=""right"">民　　族：</div></td>" & vbcrlf & "           <td><input name=""mz"" type=""text"" size=""18"" dataType=""Limit"" min=""0"" max=""50""  msg=""太长了""></td>" & vbcrlf & "         </tr>" & vbcrlf & "            <tr>" & vbcrlf & "           <td><div align=""right"">出生日期：</div></td>" & vbcrlf & "           <td><INPUT name=ret3 size=15 readonly>" & vbcrlf & "           <DIV id=daysOfMonth3 style=""POSITION: absolute""></DIV><img src=""../images/i10.gif"" width=""9"" height=""5"" onmouseup=""toggleDatePicker('daysOfMonth3','date.ret3')"" id=""daysOfMonth3Pos""></td>" & vbcrlf & "           <td><div align=""right"">合同起始：</div></td> " & vbcrlf & "           <td><INPUT name=ret  size=15 readonly onmouseup=""toggleDatePicker('daysOfMonth','date.ret')""  id=""daysOfMonthPos""> " & vbcrlf & "            <DIV id=daysOfMonth style=""POSITION: absolute""></DIV></td> " & vbcrlf & "           <td><div align=""right"">合同截止：</div></td>" & vbcrlf & "           <td><INPUT name=ret2  size=18 readonly onmouseup=""toggleDatePicker('daysOfMonth2','date.ret2')"" id=""daysOfMonth2Pos"">" & vbcrlf & "           <DIV id=daysOfMonth2 style=""POSITION: absolute""></DIV></td>" & vbcrlf & "         </tr>" & vbcrlf & "          <tr>" & vbcrlf & "           <td><div align=""right"">学　　历：</div></td> " & vbcrlf & "           <td><select name=""xl""> " & vbcrlf & "             <option value=""小学"">小学</option> " & vbcrlf & "             <option value=""初中"">初中</option> " & vbcrlf & "             <option value=""高中"">高中</option> " & vbcrlf & "                      <option value=""技校"">技校</option>" & vbcrlf & "             <option value=""中专"">中专</option>" & vbcrlf & "             <option value=""大专"">大专</option>" & vbcrlf & "             <option value=""本科"" selected>本科</option>" & vbcrlf & "             <option value=""硕士"">硕士</option>" & vbcrlf & "<option value=""博士"">博士</option> " & vbcrlf & "           </select></td> " & vbcrlf & "           <td><div align=""right"">专　　业：</div></td> " & vbcrlf & "           <td><input name=""zy"" type=""text"" size=""15"" dataType=""Limit"" min=""0"" max=""50""  msg=""太长了""></td> " & vbcrlf & " <td><div align=""right"">毕业院校：</div></td>" & vbcrlf & "           <td><input name=""xx"" type=""text"" size=""18"" dataType=""Limit"" min=""0"" max=""50""  msg=""太长了""></td>" & vbcrlf & "         </tr>" & vbcrlf & "         <tr>" & vbcrlf & "           <td><div align=""right"">办公电话：</div></td>" & vbcrlf & "           <td><input name=""phone1"" type=""text"" size=""15"" dataType=""Limit"" min=""0"" max=""50""  msg=""太长了""></td>" & vbcrlf & "           <td><div align=""right"">家庭电话：</div></td>" & vbcrlf & "           <td><input name=""phone2"" type=""text"" size=""15"" dataType=""Limit"" min=""0"" max=""50""  msg=""太长了""></td>" & vbcrlf & "           <td><div align=""right"">手　　机：</div></td>" & vbcrlf & "           <td><input name=""mobile"" type=""text"" size=""18"" dataType=""Limit"" id=""mobile""  min=""0"" max=""50""  msg=""太长了"">"
	if open_67_13=1  and open_67_19<>1  then
		Response.write "" & vbcrlf & "            <img src=""../images/message.gif"" onClick=""sendSms(mobile.value);function sendSms(phone){if (phone.length==11){" & vbcrlf & "window.open('../message/topadd.asp?phone='+phone+'','newsSendSMS','width=900,height=800,fullscreen=no,scrollbars=0,toolbar=0,status=no,resizable=1,location=no,menubar=no,menubar=no,left=20,top=100');} else{ alert('请填写正确的号码！');}}""  style=""cursor:hand"" border=""0"" alt=""发送短信"" align=""absbottom"">" & vbcrlf & "            "
	end if
	Response.write "</td>" & vbcrlf & "         </tr>" & vbcrlf & "           <tr>" & vbcrlf & "              <td><div align=""right"">传　　真：</div></td>" & vbcrlf & "              <td><input name=""fax"" type=""text"" size=""15"" dataType=""Limit"" min=""0"" max=""50""  msg=""太长了""></td>" & vbcrlf & "             <td><div align=""right"">电子邮件：</div></td>" & vbcrlf & "                <td><input name=""email"" type=""text"" size=""15"" id=""email"" dataType=""Limit"" min=""0"" max=""50""  msg=""太长了"">"
	if open_77_13=1  and open_77_19<>1  then
		Response.write "<img src=""../images/email.gif"" onClick=""sendEmail(email.value);function sendEmail(email){if (email.indexOf('@')>0){" & vbcrlf & "window.open('../email/index.asp?email='+email+'','newsSendEmail','width=900,height=800,fullscreen=no,scrollbars=0,toolbar=0,status=no,resizable=1,location=no,menubar=no,menubar=no,left=20,top=100');} else{ alert('请输入正确的邮箱！');}}""  style=""cursor:hand"" border=""0"" alt=""发送邮件"" align=""absbottom"">"
	end if
	Response.write "</td>" & vbcrlf & "               <td><div align=""right"">家庭地址：</div></td>" & vbcrlf & "              <td><input name=""address"" type=""text"" size=""18"" dataType=""Limit"" min=""0"" max=""50""  msg=""太长了""></td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr>" & vbcrlf & "            <td><div align=""right"">合同提醒：</div></td> " & vbcrlf & "            <td><input name=""alt"" type=""radio"" value=""1""> " & vbcrlf & "              是  " & vbcrlf & "                <input name=""alt"" type=""radio"" value=""0"" checked> " & vbcrlf & "                否</td>" & vbcrlf &            " <!--<td><div align=""right"">提前天数：</div></td>" & vbcrlf & "            <td><input name=""datealt"" type=""text"" size=""15"" dataType=""Limit"" min=""0"" max=""50""  msg=""太长了""></td>-->"
	if ZBRuntime.MC(26002) then
		Response.write "" & vbcrlf & "                             <td><div align=""right"">计件工资：</div></td>" & vbcrlf & "                              <td><input name=""jjgz"" type=""radio"" value=""1"">" & vbcrlf & "                                计算" & vbcrlf & "                              <input name=""jjgz"" type=""radio"" value=""0"" checked>" & vbcrlf & "                          不计算</td>" & vbcrlf & "                     "
	else
		Response.write "" & vbcrlf & "                             <td>&nbsp;</td><td>&nbsp;</td>" & vbcrlf & "                  "
	end if
	if ZBRuntime.MC(39002) And ZBRuntime.MC(39000) then
		Response.write "" & vbcrlf & "                        <td><div align=""right"">工资账套：</div></td>" & vbcrlf & "                      <td>" & vbcrlf & "                                 <select id=""salaryClass"" name=""salaryClass"">" & vbcrlf & "                                        <option value=""""></option>" & vbcrlf & "                                        "
		Set SCrs=conn.execute("select id,title,user_list from hr_gongziClass where del=0")
		while Not SCrs.eof
			Response.write "" & vbcrlf & "                                             <option value="""
			Response.write SCrs("id")
			Response.write """>"
			Response.write SCrs("title")
			Response.write "</option>" & vbcrlf & "                                            "
			SCrs.movenext
		wend
		SCrs.close
		Response.write "" & vbcrlf & "                                     </select>" & vbcrlf & "                          </td>" & vbcrlf & "                        "
	else
		Response.write "" & vbcrlf & "                                        <td>&nbsp;</td><td>&nbsp;</td>" & vbcrlf & "                       "
	end if
	Response.write "" & vbcrlf & "              </tr>" & vbcrlf & "        "
	If ZBRuntime.MC(39001) Then
		Response.write "" & vbcrlf & "            <tr>" & vbcrlf & "                <td><div align=""right"">考勤分组：</div></td>" & vbcrlf & "                <td class=""gray"" colspan =""5"">" & vbcrlf & "                    <select id=""PersonGroup"" name=""PersonGroup"">" & vbcrlf & "                        <option value =""0"">请选择考勤分组</option>" & vbcrlf & "                        "
		Set SCrs = conn.execute("select ID,GroupName title from HrKQ_PersonGroup where ISNULL(Disable,0) = 0")
		While Not SCrs.eof
			Response.write "" & vbcrlf & "                                                       <option value="""
			Response.write SCrs("id")
			Response.write """>"
			Response.write SCrs("title")
			Response.write "</option>" & vbcrlf & "                            "
			SCrs.movenext
		wend
		Response.write "" & vbcrlf & "                        SCrs.close" & vbcrlf & "                    </select>" & vbcrlf & "                </td>" & vbcrlf & "            </tr>" & vbcrlf & "        "
	end if
	Response.write "" & vbcrlf & "         <tr>" & vbcrlf & "           <td><div align=""right"">特　　长：</div></td>" & vbcrlf & "           <td colspan=""5""><input name=""tc"" type=""text"" size=""70"" dataType=""Limit"" min=""0"" max=""100""  msg=""长度必须在1个汉字到100个字之间""></td>" & vbcrlf & "          </tr>" & vbcrlf & "         <tr>" & vbcrlf & "           <td><div align=""right"">爱　　好：</div></td>" & vbcrlf & "           <td colspan=""5""><input name=""ah"" type=""text"" size=""70"" dataType=""Limit"" min=""0"" max=""100""  msg=""长度必须在1个汉字到100个字之间""></td>" & vbcrlf & "          </tr>" & vbcrlf & "         <tr>"& vbcrlf & "        <td><div align=""right"">备　　注：</div></td>" & vbcrlf & "        <td colspan=""5""><textarea name=""intro"" cols=""70"" rows=""4""></textarea></td>" & vbcrlf & "        </tr>" & vbcrlf & "      <tr class=""top"">" & vbcrlf & "        <td colspan=""6""><div align=""left"">用户权限分配<input name=""id_show"" id=""id_show"" type=""hidden"" size=""1"" value=""""/></div></td>" & vbcrlf & "       </tr>" & vbcrlf & "         <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "             <td height=""60"" colspan=""6""><div align=""left"">&nbsp;&nbsp;&nbsp;&nbsp;用户权限在添加完用户基本资料后分配。<br><br>" & vbcrlf & "          &nbsp;&nbsp;&nbsp;&nbsp;操作步骤：账号管理=》账号列表中点对应账号详情=》详情界面=》分配权限</div></td>" & vbcrlf & "        </tr>" & vbcrlf & "      <tr>" & vbcrlf & "        <td valign=""top"">　</td>" & vbcrlf & "        <td  colspan=""5""><div align=""left""> "& vbcrlf & "            <input type=""submit"" name=""Submit422"" value=""保存"" class=""page""/> " & vbcrlf & "            <input type=""submit"" name=""Submit42"" value=""增加"" onClick=""ask();"" class=""page""/> " & vbcrlf & "            <input type=""reset"" value=""重填"" class=""page"" name=""B2"">     " & vbcrlf & "        </div></td> " & vbcrlf & "      </tr> " & vbcrlf & vbcrlf & "    </table></form> " & vbcrlf & "    </td> " & vbcrlf & "  </tr> " & vbcrlf & "  <tr> " & vbcrlf & "  <td  class=""page""> " & vbcrlf & "   <table width=""100%"" border=""0"" align=""left"" > " & vbcrlf & "  <tr>" &_
	"    <td height=""30"" ><div align=""center""></div></td>" & vbcrlf & "    </tr>" & vbcrlf & "</table>" & vbcrlf & "</td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & ""
	if toUseBind = 1 then
		Response.write "" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "window.adminor = """
		Response.write adminor
		Response.write """;" & vbcrlf & "</script>" & vbcrlf & "<script src= ""../Script/mr_addgate_1.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """  type=""text/javascript""></script>" & vbcrlf & ""
	end if
	if toUseBind = 1 then
		Response.write "" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/default/easyui.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write """>" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/icon.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write """>" & vbcrlf & "<script type=""text/javascript"" src=""../inc/jquery-1.4.2.min.js?ver="
		'Response.write Application("sys.info.jsver")
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "<script type=""text/javascript"" src=""../inc/jquery.easyui.min.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "<div id=""w"" class=""easyui-window"" title=""移动端绑定"" style=""width:540px;height:305px;padding:5px;background: #fafafa; display:none"" closed=""true"" modal=""true"">" & vbcrlf & "    <div region=""center"" id=""editBind"" border=""false"" style=""background:#fff; width:100%; margin-top:2px;""></div>" & vbcrlf & "</div>" & vbcrlf & "" & vbcrlf & ""
		'Response.write Application("sys.info.jsver")
	end if
	action1="添加用户"
	call close_list(1)
	Response.write "" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & "<script src= ""../Script/mr_addgate_2.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """  type=""text/javascript""></script>" & vbcrlf & ""
	sub show_tel_apply(ords)
		Dim f_rs,v
		Set f_rs=conn.execute("select top 1 * from tel_apply where cateid="&ords)
		If f_rs.eof=False Then
			Response.write "<a href=""#"" onclick=""javascript:window.open('set_telapply.asp?ord=" & pwurl(ords) & "','telapply','width=' + 800 + ',height=' + 600 + ',fullscreen " &_
			"=no,scrollbars=1,toolbar=0,resizable=1,left=50,top=50')"">修改</a><span class=""name""> </span> "
			id=f_rs("id")
			tvt=f_rs("condition")
			limitsort1=f_rs("limitsort1")
			limitsort2=f_rs("limitsort2")
			limitsort3=f_rs("limitsort3")
			limitsort4=f_rs("limitsort4")
			limitsort5=f_rs("limitsort5")
			limitsort6=f_rs("limitsort6")
			limitsort7=f_rs("limitsort7")
			limitsort8=f_rs("limitsort8")
			limitsort9=f_rs("limitsort9")
			f_rs.close
			Response.write "" & vbcrlf & "              <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "                      <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "                               <td width=""10%""><div align=""right"">客户分类：</div></td>" & vbcrlf & "                          <td>" & vbcrlf & "                                    "
			Set f_rs=conn.execute("select b.sort1,a.sort2 from sort5 a left join sort4 b on a.sort1=b.ord where charindex(','+cast(a.ord as varchar(10))+',',','+isnull((select top 1 limitsort2 from tel_apply where cateid=" & ords & "),0)+',')>0 order by b.gate1 desc,a.gate2 desc")
			Do While Not f_rs.eof
				If v&""<>f_rs(0).value&"" And v<>"" Then Response.write "<br />"
				v=f_rs(0).value
				Response.write " <span style='line-height:20px;'> " & v & " - " & f_rs(1).value & " </span> "
'v=f_rs(0).value
				f_rs.movenext
			Loop
			f_rs.close
			Response.write "" & vbcrlf & "                              </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "                               <td><div align=""right"">客户来源：</div></td>" & vbcrlf & "                              <td>" & vbcrlf & "                                    "
			Set f_rs=conn.execute("select sort1 from sortonehy where gate2=13 and charindex(','+cast(sortonehy.ord as varchar(10))+',',','+isnull((select top 1 limitsort3 from tel_apply where cateid=" & ords & "),0)+',')>0  order by gate1 desc")
			Do While Not f_rs.eof
				Response.write " <div style='line-height:20px;'> " & f_rs(0).value & " </div> "
'Do While Not f_rs.eof
				f_rs.movenext
			Loop
			f_rs.close
			Response.write "" & vbcrlf & "                              </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">               " & vbcrlf & "                                <td><div align=""right"">客户价值：</div></td>" & vbcrlf & "                              <td>" & vbcrlf & "                                    "
			Set f_rs=conn.execute("select sort1 from sortonehy where gate2=14 and charindex(','+cast(sortonehy.ord as varchar(10))+',',','+isnull((select top 1 limitsort4 from tel_apply where cateid=" & ords & "),0)+',')>0  order by gate1 desc")
			Do While Not f_rs.eof
				Response.write " <div style='line-height:20px;'> " & f_rs(0).value & " </div> "
'Do While Not f_rs.eof
				f_rs.movenext
			Loop
			f_rs.close
			Response.write "" & vbcrlf & "                              </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">       " & vbcrlf & "                                <td><div align=""right"">客户行业：</div></td>" & vbcrlf & "                              <td>" & vbcrlf & "                                    "
			Set f_rs=conn.execute("select sort1 from sortonehy where gate2=11 and charindex(','+cast(sortonehy.ord as varchar(10))+',',','+isnull((select top 1 limitsort5 from tel_apply where cateid=" & ords & "),0)+',')>0  order by gate1 desc")
			Do While Not f_rs.eof
				Response.write " <div style='line-height:20px;'> " & f_rs(0).value & " </div> "
'Do While Not f_rs.eof
				f_rs.movenext
			Loop
			f_rs.close
			Response.write "" & vbcrlf & "                              </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "                                       <td><div align=""right"">客户区域：</div></td><td>" & vbcrlf & "                                  "
			If limitsort6="1" Then
				Set rs=conn.execute("select area from tel_area where sort=2 and del=1 and ord="&ords)
				While Not rs.eof
					If arealist<>"" Then arealist=arealist&","
					arealist=arealist&""& rs("area")
					rs.movenext
				wend
				rs.close
			end if
			arealist=Replace(arealist," ","")
			Response.write menu(0)
			Response.write "" & vbcrlf & "                             </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
			num=5
			set rs=server.CreateObject("adodb.recordset")
			sql="select id,title,name,sort,gl from zdy where sort1=1 and set_open=1 and js=1 and sort=1 order by gate1 asc "
			rs.open sql,conn,1,1
			if Not rs.eof Then
				do until rs.eof
					If rs("name")="zdy6" Then
						strC=limitsort8
					else
						strC=limitsort7
					end if
					Response.write "" & vbcrlf & "                                     <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "                                       <td><div align=""right"">"
					Response.write rs("title")
					Response.write "：</div></td><td>" & vbcrlf & "                                    "
					set rs1=server.CreateObject("adodb.recordset")
					sql1="select ord,sort1 from sortonehy where gate2="&rs("gl")&" order by gate1 desc"
					rs1.open sql1,conn,1,1
					do until rs1.eof
						If InStr(","&strC&",",","&rs1("ord")&",")>0 Then Response.write " <div style='line-height:20px;'> " & rs1("sort1") & " </div> "
'do until rs1.eof
						rs1.movenext
					loop
					rs1.close
					set rs1=nothing
					Response.write "" & vbcrlf & "                                     </td></tr>" & vbcrlf & "                                      "
					num=num+1
					rs.movenext
				loop
			end if
			rs.close
			set rs=nothing
			call show_getExtended(1,num,limitsort9)
			Response.write "     " & vbcrlf & "          </table>" & vbcrlf & "" & vbcrlf & "              "
		else
			Response.write "<a href=""#"" onclick=""javascript:window.open('set_telapply.asp?ord=" & pwurl(ords) & "','telapply','width=' + 800 + ',height=' + 600 + ',fullscreen " &_
			"=no,scrollbars=1,toolbar=0,resizable=1,left=50,top=50')"">设置</a><span class=""name""> </span>"
			Response.write "     " & vbcrlf & "          </table>" & vbcrlf & "" & vbcrlf & "              "
		end if
	end sub
	
%>
