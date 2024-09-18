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
			Response.write "</td></td></tr></table><table width='100%' cellspacing='0' style='border-top:1px solid #c0ccdd'><tr><td class='page'>&nbsp;</td></tr></table><script>function showerror(){var box=document.getElementById(""errordiv"").style;box.display=box.display==""none""?""block"":""none""}</script></body><				/html>"
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
							VendorCode3 = "KzclLlNKmiU9pTIkRRyUqlzFtcEnhEjwamZxKCqp1ppaom0A5X72DEDnSMBg0rdCayaxJh/VrqtRv2Wujjx5acac1r+N7aaCjNiUer5X7ZExbWWIcRNxxwgFLZNALO5FliaHyopyWg4RQTbGGyZKdZ3RfiZJdfJLu0PApMQN+8ersyK2m7LMSY8eZc83D1vTX8BoZWY/HXvOsju2M039UnKUU+v00tdeT5/xhB3fNe6RSjcZXa/ZofLDQzHOj/2xRIAGISJ0JtQivr5jsgOQuhj				Jk9PthL5eFzYL+pYA0zdMIP5C42Go7MgAZSPLwMiEIOuyIeLep9ZR5iRcBl1fVyVjyaCVrn9Qt+Glcpj0lziam3SsGnl1WdXxM6yEc0nmmVrr0DSA=="
'Dim VendorCode1, VendorCode2, VendorCode3
							VendorCode2 = "Yi4m7PAjeQ4n7FGAPxnO63MrESMHczwVh9uod/MbrU7RYOiM90y6Cu9lNBpibp1LDERxDWctlxBEldMry6QLEG705q6ie6aQncWu9evLTsmkMsw4PDWoowCwyW431Wzc/+8EAk6gLkA2m6Jkf+Qooqu5Q5UQlJvDa8BQZqU7Lx2ZRqI3RGW7APIqWGFk1Bdrvedg16+zHL6/J9V7b5+KBAq9cAreJhcLN8WZ1yID1RZ5gDqSDu25Yajso92uXyN+M65WmMatEPxD4pZbUPRTxGr				CRghIYzzWjpWRbg1ZVyyOT4RJpgu/9dF1UqooTD+jrT/VA121EYPt2FyMMYtVINiUH1LumPukUPH2s0D6Lk8UhNEvckutzCZtZ+ipswOzEac"
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
		if rs.eof  Then qxopenv=0  :  qxintrov="-222" :   rs.close :  Exit Function
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
		Response.write "" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "var getIEVer = function () {" & vbcrlf & "var browser = navigator.appName;" & vbcrlf & "if(window.ActiveXObject && top.document.compatMode==""BackCompat"") {return 5;}" & vbcrlf & " var b_version = navigator.appVersion;" & vbcrlf & " var version = b_version.split("";"");" & vbcrlf & "   if(document.documentMode && isNaN(document.documentMode)==false) { return document.documentMode; }" & vbcrlf & "  if (window.ActiveXObject) {" & vbcrlf & " var v = version[1].replace(/[ ]/g, """");" & vbcrlf & "   if (v == ""MSIE10.0"") 			{return 10;}" & vbcrlf & "if (v == ""MSIE9.0"") {return 9;}" & vbcrlf & "   if (v == ""MSIE8.0"") {return 8;}" & vbcrlf & "   if (v == ""MSIE7.0"") {return 7;}" & vbcrlf & "   if (v == ""MSIE6.0"") {return 6;}" & vbcrlf & "   if (v == ""MSIE5.0"") {return 5;" & vbcrlf & "} else {return 11}" & vbcrlf & " }" & vbcrlf & "   else {" & vbcrlf & "  return 100;" & vbcrlf & " }" & vbcrlf & "   };" & vbcrlf & "  try{ document.getElementsByTagName(""html"")[0].className = ""IE"" + getIEVer() ; } catch(exa){}" & vbcrlf & "window.uizoom = "
'If szmx="" Then szmx = "1"
		Response.write szmx
		Response.write ";" & vbcrlf & "if( (top==window ||  (top.app && top.app.IeVer>=100) ) && uizoom!=1){document.write(""<style>body{position:relative;zoom:"" + window.uizoom + ""}</style>"");}" & vbcrlf & "  window.sysConfig = {BrandIndex:"""
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
		Response.write """;" & vbcrlf & "window.currUser = """
		Response.write sdk.user
		Response.write """;" & vbcrlf & "window.SessionId ="""
		Response.write session("SessionID")
		Response.write """;" & vbcrlf & "window.nowTime = """
		Response.write now()
		Response.write """;" & vbcrlf & "window.nowDate = """
		Response.write date()
		Response.write """;" & vbcrlf & "window.syssoftversion = """
		Response.write Application("__sys_soft_ver")
		Response.write """" & vbcrlf & " window.currForm = """
		if len(request.form) < 1000 then Response.write replace(request.form,"""","\""")
		Response.write """;" & vbcrlf & "window.currQueryString = """
		Response.write replace(replace(request.querystring,"\","\\"),"""","\""")
		Response.write """;" & vbcrlf & "window.ConflictPageUrllist = """
		Response.write ConflictPageUrllist
		Response.write """; //冲突的页面" & vbcrlf & "   "
		Dim PATH_INFO : PATH_INFO = Request.ServerVariables("PATH_INFO")
		if instr(1,PATH_INFO,"/tongji/",1)>0 or instr(1,PATH_INFO,"/out/",1)>0 then
			Response.write "" & vbcrlf & " window.isGatherListPage=1;" & vbcrlf & "  "
		end if
		Response.write "" & vbcrlf & " document.title="""
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
		Response.write "<!Doctype html><html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""X-UA-Compatible"" content =""IE=edge,chrome=1"">" & vbcrlf & "<meta name=""vs_targetSchema"" content=""http://schemas.microsoft.com/intellisense/ie5""/>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html;			charset=UTF-8"">" & vbcrlf & "<meta name=""format-detection"" content=""telephone=no"">" & vbcrlf & ""
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
		sql = "select case a.qx_open when 3 then '' when 1 then (case ql.sort when 3 then qx_intro when 1 then '' end) else '-222' end from power a inner join qxlblist ql on ql.sort1=" & s1 & " and ql.sort2=" & s2 & " where a.sort1 = " & s1 & " and a.sort2 = " & s2 & " and ord=" & session("personzbintel200		7")
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
	Response.write "" & vbcrlf & "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">" & vbcrlf & "<html xmlns=""http://www.w3.org/1999/xhtml"">" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset	=UTF-8"" />" & vbcrlf & "<title>"
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"" />" & vbcrlf & "<link href=""../inc/main.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"" />" & vbcrlf & "<script src=""../inc/menu.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ language=""javascript"" type=""text/javascript""></script>" & vbcrlf & "" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "#demo table{margin-top:-1px}" & vbcrlf & "</style>" & vbcrlf & "<script src= ""../Script/ca_tophome1.js?ver="
	'Response.write Application("sys.info.jsver")
	Response.write Application("sys.info.jsver")
	Response.write """  type=""text/javascript"" language=""javascript""></script>" & vbcrlf & "" & vbcrlf & "</head>" & vbcrlf & "<body onLoad=""cateinit();"" oncontextmenu=self.event.returnValue=false >" & vbcrlf & ""
	CHG_OPEN=1
	if request("cateid")="" or isnull(request("cateid")) then
		cateid=session("personzbintel2007")
	else
		cateid=request("cateid")
	end if
	set rs88=conn.execute("select top 0 sorce,sorce2,ord from gate where ord="&cateid&" ")
	If rs88.eof = False Then
		W1=rs88(0).value
		W2=rs88(1).value
		W3=rs88(2).value
	end if
	set rs88=nothing
	Response.write "" & vbcrlf & "<script>" & vbcrlf & "  function cateinit()" & vbcrlf & " {" & vbcrlf & "   $$(""W1"").value='"
	Response.write W1
	Response.write "'=='0'?'':'"
	Response.write W1
	Response.write "';" & vbcrlf & "if($$(""W1"").value!='') chgOthers(1);" & vbcrlf & "  $$(""W2"").value='"
	Response.write W2
	Response.write "'=='0'?'':'"
	Response.write W2
	Response.write "';" & vbcrlf & "if($$(""W2"").value!='') chgOthers(2);" & vbcrlf & "  $$(""W3"").value='"
	Response.write W3
	Response.write "'=='0'?'':'"
	Response.write W3
	Response.write "';" & vbcrlf & "jQuery(""#content"").parent().attr(""id"",""content_bg"");" & vbcrlf & "  //document.getElementById(""content"").parentElement.id=""content_bg"";" & vbcrlf & " }" & vbcrlf & "   window.ajaxRefreshPage = function() {" & vbcrlf & "   RreshElement(""content_bg"",function(){__ImgBig	ToSmall()});" & vbcrlf & " }" & vbcrlf & "</script>  " & vbcrlf & ""
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=71 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_71_1=0
		intro_71_1=0
	else
		open_71_1=rs1("qx_open")
		intro_71_1=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	Str_power=""
	Str_power22=""
	Str_power33=""
	sorce=0
	sorce2=0
	sorce3=0
	if open_71_1="1"  then
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select ord,name,sorce,sorce2 from gate  where ord in ("&intro_71_1&") and del=1 order by sorce asc,sorce2 asc ,cateid asc ,ord asc"
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
		sorce = sdk.FormatNumList(sorce)
		sorce2 = sdk.FormatNumList(sorce2)
		sorce3 = sdk.FormatNumList(sorce3)
		Str_power="where ord in ("&sorce&")"
		Str_power11="and ord in ("&sorce&")"
		Str_power2="and ord in ("&sorce2&")"
		Str_power22="where ord in ("&sorce2&")"
		Str_power3="and (ord in ("&sorce3&") or ord="&session("personzbintel2007")&" ) and del=1"
		Str_power33="where ord in ("&sorce3&") and del=1"
	elseif open_71_1="3" then
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
	Function IsHasReply(pid)
		Dim sql,rs
		sql = "SELECT TOP 1 ord FROM Reply WHERE del = 1 AND plan1 = "& pid &"  "
		set rs = conn.execute(sql)
		If Not rs.Eof Then
			IsHasReply = True
		else
			IsHasReply = False
		end if
		rs.close
		set rs = nothing
	end function
	function CheckPurview(AllPurviews,strPurview)
		if isNull(AllPurviews) or AllPurviews="" or strPurview="" then
			CheckPurview=False
			exit function
		end if
		CheckPurview=False
		if instr(","&AllPurviews&",",","&strPurview&",")>0 then
			CheckPurview=True
		end if
	end function
	dim MODULES
	MODULES=session("zbintel2010ms")
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
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=1 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_1_13=0
		intro_1_13=0
	else
		open_1_13=rs1("qx_open")
		intro_1_13=rs1("qx_intro")
	end if
	rs1.close
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
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=71 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_71_1=0
		intro_71_1=0
	else
		open_71_1=rs1("qx_open")
		intro_71_1=rs1("qx_intro")
	end if
	rs1.close
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=71 and sort2=2"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_71_2=0
		intro_71_2=0
	else
		open_71_2=rs1("qx_open")
		intro_71_2=rs1("qx_intro")
	end if
	rs1.close
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=71 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_71_14=0
		intro_71_14=0
	else
		open_71_14=rs1("qx_open")
		intro_71_14=rs1("qx_intro")
	end if
	rs1.close
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=71 and sort2=16"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_71_16=0
		intro_71_16=0
	else
		open_71_16=rs1("qx_open")
		intro_71_16=rs1("qx_intro")
	end if
	rs1.close
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=2 and sort2=1"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_2_1=0
		intro_2_1=0
	else
		open_2_1=rs1("qx_open")
		intro_2_1=rs1("qx_intro")
	end if
	rs1.close
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=2 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_2_13=0
	else
		open_2_13=rs1("qx_open")
	end if
	rs1.close
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=2 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_2_14=0
		intro_2_14=0
	else
		open_2_14=rs1("qx_open")
		intro_2_14=rs1("qx_intro")
	end if
	rs1.close
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
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=3 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_3_14=0
		intro_3_14=0
	else
		open_3_14=rs1("qx_open")
		intro_3_14=rs1("qx_intro")
	end if
	rs1.close
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
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=6 and sort2=14"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_6_14=0
		intro_6_14=0
	else
		open_6_14=rs1("qx_open")
		intro_6_14=rs1("qx_intro")
	end if
	rs1.close
	set rs=server.CreateObject("adodb.recordset")
	sql="select isnull(num1,0) as num1 from gate where ord="&cateid&" "
	rs.open sql,conn,1,1
	num_del=rs("num1")
	if num_del<>"" then
	else
		num_del=0
	end if
	rs.close
	set rs=nothing
	if request.Form("hiddendate")="" then
		tdate=date()
		if request("jtdate")<>"" then
			tdate=request("jtdate")
		end if
	else
		if request.Form("hiddenflag")="1" then
			tdate=DateAdd("d",-1,cdate(request.Form("hiddendate")))
'if request.Form("hiddenflag")="1" then
		elseif request.Form("hiddenflag")="2" then
			tdate=DateAdd("d",1,cdate(request.Form("hiddendate")))
		else
			tdate=DateAdd("d",0,cdate(request.Form("hiddendate")))
		end if
	end if
	flag=0
	td=cdate(tdate)
	Dim gate_person
	gate_person="gate"
	Dim uid
	uid = session("personzbintel2007") & ""
	Dim PowerV_71_1 : PowerV_71_1 = (open_71_1=1 And CheckPurview(intro_71_1,cateid)=true) Or open_71_1=3
	Response.write "" & vbcrlf & "<script src= ""../Script/ca_home1.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """  language=JavaScript1.2></SCRIPT>" & vbcrlf & "<script>" & vbcrlf & "  function setDay(day,eltName) {" & vbcrlf & "   displayElement.value =displayYear+""-""+(displayMonth + 1)+ ""-"" +day;" & vbcrlf & "   hideElement(eltName);" & vbcrlf & "document.location.href=""tophome1.			asp?jtdate=""+displayYear+""-""+(displayMonth + 1)+ ""-"" +day+""&cateid="
	'Response.write Application("sys.info.jsver")
	Response.write cateid
	Response.write """" & vbcrlf & " }" & vbcrlf & "</script>" & vbcrlf & "<style>#w1, #w2, #w3{width:100px;}</style>" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""1"">" & vbcrlf & "  <tr>" & vbcrlf & "<td valign=""top"">" & vbcrlf & "<form action="""" method=""post""　id=""demo"" onsubmit=""return Validator.Validate(this,2)"" name=""date"" >" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "<tr>" & vbcrlf & "  <td><table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"" style='margin-top:-1px'>" & vbcrlf & "  <tr>" & vbcrlf & "<td  class=""place2"" style='height:42px;width:220px;background-position:right top;padding-left:20px;border-left:1px solid #c0ccdc'>销售日报表</td>" & vbcrlf & "<td  width=""280"">" & vbcrlf & " <table width=""100%"" cellspacing=""2"">" & vbcrlf & "<tr height=""25"">" & vbcrlf & "  <td align=""center""><a href=""javascript:void(0)"" onClick=""date.hiddenflag.value=1;date.submit();return false;""><img src=""../images/main_2.gif"" width=""8"" height=""8""			border=""0"" /> 前一天</a></td>" & vbcrlf & "  <td colspan=""3"" align=""center"">"
	Response.write td
	Response.write "</td>" & vbcrlf & "  <td align=""center""><a href=""javascript:void(0)"" onClick=""date.hiddenflag.value=2;date.submit();return false;"">后一天 <img src=""../images/main_1.gif"" width=""8"" height=""8"" border=""0"" /></a></td>" & vbcrlf & " <td><INPUT name=""ret1"" type=""hidden""size=10 >" & vbcrlf & "  <input type=""button"" class=""anybutton"" value=""日期"" align=""absMiddle""  border=""0""  id=""daysOfMonth1Pos"" name=""daysOfMonth1Pos""  onmouseup=""toggleDatePicker('daysOfMonth1','date.ret1')"" />" & vbcrlf & "  <DIV id=daysOfMonth1 style=""POSITION: absolute""></DIV></td>" & vbcrlf & "</tr>" & vbcrlf & "</table></td>" & vbcrlf & "<td align=""right"">" & vbcrlf & "   <input type=""button"" name=""Submit43"" value=""打印""  onClick=""window.print()""  class=""anybutton""/><input name=""Submit6"" type=""button"" onClick=""window.location.href='tophome2.asp?cateid="
	Response.write cateid
	Response.write "'"" class=""anybutton"" value=""周报"" /><input name=""Submit6"" type=""button"" onClick=""window.location.href='tophome3.asp?cateid="
	Response.write cateid
	Response.write "'"" class=""anybutton"" value=""月报"" /><input name=""Submit6"" type=""button"" onClick=""window.location.href='tophome4.asp?cateid="
	Response.write cateid
	Response.write "'"" class=""anybutton"" value=""年报"" />" & vbcrlf & "  "
	ww111 = request("w1")
	ww222= request("w2")
	ww333 = request("w3")
	on error resume next
	if len(ww111 & "")=0 then ww111 = w1
	if len(ww222 & "")=0 then ww222 = w2
	if len(ww333 & "")=0 then ww333 = w3
	Response.write replace(sdk.setup.Select_Tj_Html(gate_person, CHG_OPEN, sysCurrPath , Str_power, Str_power2 , Str_power3, ww111, ww222, ww333),"""gatetreeselbox""","""gatetreeselbox""  ismulti=0 SID=4 ")
	Response.write "" & vbcrlf & " </td>" & vbcrlf & "<td  width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "  </tr>" & vbcrlf & "</table></td>" & vbcrlf & "</tr>" & vbcrlf & "<tr>" & vbcrlf & "  <td>" & vbcrlf & " <table class=""detailTable"" width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content""  style=""margin-top:0px"">" & vbcrlf & "  <tr class=""top"">" & vbcrlf & "<td colspan=""3"" width=""16%""><div align=""center"">日期</div></td>"			& vbcrlf & "<td width=""18%""><div align=""center"">日程</div></td>" & vbcrlf & "<td width=""6%""><div align=""center"">客户</div></td>" & vbcrlf & " "
	if ZBRuntime.MC(3000) then
		lie=lie+1
'if ZBRuntime.MC(3000) then
		Response.write "" & vbcrlf & "<td width=""12%""><div align=""center"">项目</div></td>" & vbcrlf & "  "
	end if
	Response.write "" & vbcrlf & "<td width=""6%""><div align=""center"">联系人</div></td>" & vbcrlf & " "
	if ZBRuntime.MC(3000) then
		lie=lie+1
'if ZBRuntime.MC(3000) then
		Response.write "" & vbcrlf & "<td width=""6%""><div align=""center"">里程碑</div></td>" & vbcrlf & " "
	end if
	Response.write "" & vbcrlf & "<td width=""12%""><div align=""center"">洽谈进展</div></td>" & vbcrlf & "  "
	if ZBRuntime.MC(27000) then
		lie=lie+1
'if ZBRuntime.MC(27000) then
		Response.write "" & vbcrlf & "<td width=""9%""><div align=""center"">费用</div></td>" & vbcrlf & "   "
	end if
	Response.write "" & vbcrlf & "</tr>" & vbcrlf & ""
	Dim power_uid, kh_list
	Dim open_1_1,open_1_2,open_1_3,open_1_4,open_1_5,open_1_6,open_1_7,open_1_8,open_1_9,open_1_10,open_1_11,open_1_13
	Dim open_1_14,open_1_15,open_1_16,open_1_17,open_1_21,open_1_25
	Dim intro_1_1,intro_1_2,intro_1_3,intro_1_4,intro_1_5,intro_1_6,intro_1_7,intro_1_8,intro_1_9,intro_1_10,intro_1_11
	Dim intro_1_13,intro_1_14,intro_1_15,intro_1_16,intro_1_17,intro_1_21,intro_1_25
	Dim open_2_1,open_2_3,intro_2_3,open_2_13,open_2_14,open_2_19,intro_2_1,  intro_2_13,intro_2_14,intro_2_19
	Dim open_3_1,open_3_13,open_3_14,open_3_19,open_3_21,intro_3_1,intro_3_13,intro_3_14,intro_3_19,intro_3_21
	Dim open_4_1,open_4_13,open_4_14,open_4_19,open_4_21,intro_4_1,intro_4_13,intro_4_14,intro_4_19,intro_4_21,open_4_23,intro_4_23
	Dim open_5_1,open_5_11,open_5_13,open_5_14,open_5_19,open_5_21,intro_5_1,intro_5_11,intro_5_13,intro_5_14,intro_5_19,intro_5_21
	Dim open_6_1,open_6_13,open_6_14,open_6_19,intro_6_1,intro_6_13,intro_6_14,intro_6_19
	Dim open_7_1,open_7_2,open_7_3,open_7_13,open_7_14,open_7_19,open_7_20,open_7_21,open_7_22
	Dim intro_7_1,intro_7_2,intro_7_3,intro_7_13,intro_7_14,intro_7_19,intro_7_20,intro_7_21,intro_7_22
	Dim open_7001_1,open_7001_2,open_7001_3,open_7001_13,open_7001_14,open_7001_19,open_7001_20,open_7001_21,open_7001_22
	Dim intro_7001_1,intro_7001_2,intro_7001_3,intro_7001_13,intro_7001_14,intro_7001_19,intro_7001_20,intro_7001_21,intro_7001_22
	Dim open_26_1 , intro_26_1,open_26_14 , intro_26_14
	Dim open_33_1,open_33_13,open_33_14,open_33_19,intro_33_1,intro_33_13,intro_33_14,intro_33_19
	Dim open_41_1,open_41_14,open_41_19,intro_41_1,intro_41_14,intro_41_19
	Dim open_42_1,open_42_13,open_42_14,open_42_19,intro_42_1,intro_42_13,intro_42_14,intro_42_19
	Dim open_43_13,open_43_19,intro_43_13,intro_43_19
	Dim open_74_1,open_74_19,intro_74_1,intro_74_19
	Dim open_108_5,intro_108_5
	sub g_p_v(byval s1,byval s2,byref p1,byref p2)
		sdk.setup.getpowerattr s1,s2,p1,p2
	end sub
	g_p_v 1,1,open_1_1,intro_1_1
	g_p_v 1,2,open_1_2,intro_1_2
	g_p_v 1,3,open_1_3,intro_1_3
	g_p_v 1,4,open_1_4,intro_1_4
	g_p_v 1,5,open_1_5,intro_1_5
	g_p_v 1,6,open_1_6,intro_1_6
	g_p_v 1,7,open_1_7,intro_1_7
	g_p_v 1,8,open_1_8,intro_1_8
	g_p_v 1,9,open_1_9,intro_1_9
	g_p_v 1,10,open_1_10,intro_1_10
	g_p_v 1,11,open_1_11,intro_1_11
	g_p_v 1,13,open_1_13,intro_1_13
	g_p_v 1,14,open_1_14,intro_1_14
	g_p_v 1,15,open_1_15,intro_1_15
	g_p_v 1,16,open_1_16,intro_1_16
	g_p_v 1,17,open_1_17,intro_1_17
	g_p_v 1,21,open_1_21,intro_1_21
	g_p_v 1,25,open_1_25,intro_1_25
	g_p_v 2,1,open_2_1,intro_2_1
	g_p_v 2,3,open_2_3,intro_2_3
	g_p_v 2,13,open_2_13,intro_2_13
	g_p_v 2,14,open_2_14,intro_2_14
	g_p_v 2,19,open_2_19,intro_2_19
	g_p_v 108,5,open_108_5,intro_108_5
	g_p_v 3,1,open_3_1,intro_3_1
	g_p_v 3,13,open_3_13,intro_3_13
	g_p_v 3,14,open_3_14,intro_3_14
	g_p_v 3,19,open_3_19,intro_3_19
	g_p_v 3,21,open_3_21,intro_3_21
	g_p_v 4,1,open_4_1,intro_4_1
	g_p_v 4,13,open_4_13,intro_4_13
	g_p_v 4,14,open_4_14,intro_4_14
	g_p_v 4,19,open_4_19,intro_4_19
	g_p_v 4,21,open_4_21,intro_4_21
	g_p_v 4,23,open_4_23,intro_4_23
	g_p_v 5,1,open_5_1,intro_5_1
	g_p_v 5,11,open_5_11,intro_5_11
	g_p_v 5,13,open_5_13,intro_5_13
	g_p_v 5,14,open_5_14,intro_5_14
	g_p_v 5,19,open_5_19,intro_5_19
	g_p_v 5,21,open_5_21,intro_5_21
	g_p_v 6,1,open_6_1,intro_6_1
	g_p_v 6,13,open_6_13,intro_6_13
	g_p_v 6,14,open_6_14,intro_6_14
	g_p_v 6,19,open_6_19,intro_6_19
	g_p_v 7,1,open_7_1,intro_7_1
	g_p_v 7,2,open_7_2,intro_7_2
	g_p_v 7,3,open_7_3,intro_7_3
	g_p_v 7,13,open_7_13,intro_7_13
	g_p_v 7,14,open_7_14,intro_7_14
	g_p_v 7,19,open_7_19,intro_7_19
	g_p_v 7,20,open_7_20,intro_7_20
	g_p_v 7,21,open_7_21,intro_7_21
	g_p_v 7,25,open_7_22,intro_7_22
	g_p_v 7001,1,open_7001_1,intro_7001_1
	g_p_v 7001,2,open_7001_2,intro_7001_2
	g_p_v 7001,3,open_7001_3,intro_7001_3
	g_p_v 7001,13,open_7001_13,intro_7001_13
	g_p_v 7001,14,open_7001_14,intro_7001_14
	g_p_v 7001,19,open_7001_19,intro_7001_19
	g_p_v 7001,20,open_7001_20,intro_7001_20
	g_p_v 7001,21,open_7001_21,intro_7001_21
	g_p_v 7001,25,open_7001_22,intro_7001_22
	g_p_v 26,1,open_26_1,intro_26_1
	g_p_v 26,14,open_26_14,intro_26_14
	g_p_v 33,1,open_33_1,intro_33_1
	g_p_v 33,13,open_33_13,intro_33_13
	g_p_v 33,14,open_33_14,intro_33_14
	g_p_v 33,19,open_33_19,intro_33_19
	g_p_v 41,1,open_41_1,intro_41_1
	g_p_v 41,13,open_41_13,intro_41_13
	g_p_v 41,14,open_41_14,intro_41_14
	g_p_v 41,19,open_41_19,intro_41_19
	g_p_v 42,1,open_42_1,intro_42_1
	g_p_v 42,13,open_42_13,intro_42_13
	g_p_v 42,14,open_42_14,intro_42_14
	g_p_v 42,19,open_42_19,intro_42_19
	g_p_v 43,14,open_43_14,intro_43_14
	g_p_v 43,19,open_43_19,intro_43_19
	g_p_v 74,1,open_74_1,intro_74_1
	g_p_v 74,19,open_74_19,intro_74_19
	power_uid = session("personzbintel2007")
	if open_1_1=3 then
		list=" 1=1 "
		list2=" 1=1 "
	elseif open_1_1=1 then
		list=" cateid in ("&iif(intro_1_1&""="","0",intro_1_1)&") and cateid>0 "
		list2=" cateadd in ("&iif(intro_1_1&""="","0",intro_1_1)&") and cateadd>0 "
	else
		list=" 1=2 "
		list2=" 0=1 "
	end if
	dim rs,sql,Str_Result,Str_Result2
	str_temp_where = "and ((" & vbcrlf & "/*p-1-cateid-s*/" & vbcrlf & list & vbcrlf & "/*pe*/" & vbcrlf & ") or (CHARINDEX(',"&power_uid&",' , ','+REPLACE(share,' ','')+',') > 0 or share='1'))"
'dim rs,sql,Str_Result,Str_Result2
'dim rs,sql,Str_Result,Str_Result2
	Str_Result=" where del=1 and sort3=1   "&str_temp_where&""
	Str_Result2=" and (del=1 and sort3=1 and (("&list&") or (CHARINDEX(',"&power_uid&",' , ','+REPLACE(share,' ','')+',') > 0 or share='1')) "
'Str_Result=" where del=1 and sort3=1   "&str_temp_where&""
	Str_Result3=" where del=1 and sort3=1 and (("&list2&") or (CHARINDEX(',"&power_uid&",' , ','+REPLACE(share,' ','')+',') > 0 or share='1'))"
'Str_Result=" where del=1 and sort3=1   "&str_temp_where&""
	rowspan=0
	set rss=server.CreateObject("adodb.recordset")
	set rs2=server.CreateObject("adodb.recordset")
	strSql="select charSpId,charName,intLevel from sp_schedule order by intLevel"
	rss.open strSql,conn
	do while not rss.eof
		strSql2="select ord from power where sort1=71 and sort2=16 and ((qx_open=1 and ','+cast(qx_intro as varchar(max))+',' like '%,"&cateid&",%') or qx_open=3)"
'do while not rss.eof
		rs2.open strSql2,conn
		do while not rs2.eof
			if CheckPurview(rss("charSpId"),rs2("ord")) then
				rowspan=rowspan+1
'if CheckPurview(rss("charSpId"),rs2("ord")) then
				exit do
			end if
			rs2.movenext
		loop
		rs2.close
		rss.movenext
	loop
	rss.close
	Set rs2=Nothing
	Str_Resultgj1="where cateid="&cateid&"  and del=1"
	Str_Resultgj2="and cateid="&cateid&" and del=1"
	set rs=server.CreateObject("adodb.recordset")
	sql="select ord from tel "&Str_Result &" and cateid="&cateid &" and sort3=1"
	rs.open sql,conn,1,1
	dim numallzj
	numallzj=0
	numallzj=rs.recordcount
	rs.close
	set rs=nothing
	set rs=server.CreateObject("adodb.recordset")
	sql="select ord from  tel where  year(date1)='"&year(date())&"' and month(date1)='"&month(date())&"' and day(date1)='"&day(date())&"'  and  cateid="&cateid&" and del=1"
	rs.open sql,conn,1,1
	dim numallzj2
	numallzj2=0
	numallzj2=rs.recordcount
	rs.close
	set rs=nothing
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select * from sort5  order by sort1 desc "
	rs1.open sql1,conn,1,1
	if rs1.RecordCount<=0 then
		Response.write "<table><tr><td>没有设置阶段!</td></tr></table>"
	else
		i=0
		Response.write "" & vbcrlf & "  <tr>" & vbcrlf & "<td colspan=""3""><div align=""center"">客户统计</div></td>" & vbcrlf & "<td colspan="""
		Response.write lie+4
		Response.write """><a href=""javascript:void(0)""  onClick=""javascript:window.open('../work/telhy.asp?W3="
		Response.write cateid
		Response.write "','_blank','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">客户总数<font class=""red""><strong>"
		'Response.write cateid
		Response.write numallzj
		Response.write "</strong></font>个</a>，&nbsp;&nbsp;" & vbcrlf & ""
		do until rs1.eof
			j=0
			set rs=server.CreateObject("adodb.recordset")
			sql="select ord from tel   where sort1="&rs1("ord")&" "&Str_Resultgj2&""
			rs.open sql,conn,1,1
			numzj=0
			numzj=rs.recordcount
			rs.close
			set rs=nothing
			Response.write "" & vbcrlf & "<a href=""javascript:void(0)""  onClick=""javascript:window.open('../work/telhy.asp?W3="
			Response.write cateid
			Response.write "&F="
			Response.write rs1("ord")
			Response.write "','_blank','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">"
			'Response.write rs1("ord")
			Response.write rs1("sort2")
			Response.write "<font class=""red""><strong>"
			Response.write numzj
			Response.write "</strong></font>个</a>，" & vbcrlf & ""
			i=i+1
			'Response.write "</strong></font>个</a>，" & vbcrlf & ""
			rs1.movenext
		loop
	end if
	rs1.close
	set rs1=nothing
	Response.write " &nbsp;&nbsp;当日新增客户<font class=""red""><strong>"
	Response.write numallzj2
	Response.write "</strong></font>个。" & vbcrlf & " </td>" & vbcrlf & "</tr>" & vbcrlf & "" & vbcrlf & ""
	for j=1 to 1
		tdmonth=month(td)
		tdyear=year(td)
		tdweek=weekdayname(Weekday(td))
		if td=date() then
			tian="<font color=red style='font-size:14pt'><b>"&day(td)&"日</b></font>"
'if td=date() then
		else
			tian=""&day(td)&"日"
		end if
		dim n,n1
		m1=0
		m2=0
		set rs=server.CreateObject("adodb.recordset")
		set rs1=server.CreateObject("adodb.recordset")
		sql="select top 300 a.ord,a.intro,a.company,a.person,a.chance,a.lcb,a.intro2,a.pay,a.startdate1,a.date1,a.order1,a.time1,a.time2,a.starttime1,a.starttime2," &_
		"ISNULL(c.name,'') AS addPerson,a.date8 AS date7,ISNULL(d.name,c.name) AS r_addPerson,ISNULL(b.date7,a.date8) AS r_date7 " &_
		"from plan1 a " &_
		"LEFT JOIN (SELECT MAX(date7) date7,ISNULL(plan1,0) plan1,MAX(cateid) cateid FROM reply GROUP BY ISNULL(plan1,0)) b ON b.plan1 = a.ord " &_
		"LEFT JOIN gate c ON c.ord = ISNULL(a.order1,a.cateid) " &_
		"LEFT JOIN gate d ON d.ord = b.cateid " &_
		"where  a.startdate1='"&td&"' and a.starttime1<12 and a.cateid="&cateid&" and a.complete<>'7' order by a.time1,a.time2,a.gate desc"
		rs.open sql,conn,1,1
		sql1="select top 300 a.ord,a.intro,a.company,a.person,a.chance,a.lcb,a.intro2,a.pay,a.startdate1,a.date1,a.order1,a.time1,a.time2,a.starttime1,a.starttime2," &_
		"ISNULL(c.name,'') AS addPerson,a.date8 AS date7,ISNULL(d.name,c.name) AS r_addPerson,ISNULL(b.date7,a.date8) AS r_date7 " &_
		"from plan1 a " &_
		"LEFT JOIN (SELECT MAX(date7) date7,ISNULL(plan1,0) plan1,MAX(cateid) cateid FROM reply GROUP BY ISNULL(plan1,0)) b ON b.plan1 = a.ord " &_
		"LEFT JOIN gate c ON c.ord = ISNULL(a.order1,a.cateid) " &_
		"LEFT JOIN gate d ON d.ord = b.cateid " &_
		"where a.startdate1='"&td&"' and a.starttime1>=12 and a.cateid="&cateid&" and a.complete<>'7' order by a.time1,a.time2,a.gate desc"
		rs1.open sql1,conn,1,1
		m1=rs.RecordCount
		m2=rs1.RecordCount
		if m1=0 then
			count2=1
		else
			count2=m1
		end if
		if m2=0 then
			count3=1
		else
			count3=m2
		end if
		count1=count2+count3+1+rowspan
		count3=m2
		If rowspan=0 Then count1=count1+1
		count3=m2
		Response.write "" & vbcrlf & "   <tr>" & vbcrlf & "<td width=""8%"" rowspan="""
		Response.write count1
		Response.write """ align=""center"" bgcolor=""#FFFFFF"">"
		Response.write tdyear
		Response.write "年"
		Response.write tdmonth
		Response.write "月" & vbcrlf & "  <a href=""tophome1.asp?jtdate="
		Response.write td
		Response.write "&cateid="
		Response.write cateid
		Response.write """ target=""_self"" ><div class=""daynumber"">"
		Response.write tian
		Response.write "</div></a> "
		Response.write tdweek
		Response.write "</td>" & vbcrlf & "<td width=""8%"" rowspan="""
		Response.write count2
		Response.write """ colspan=""2"" align=""center"" bgcolor=""#FFFFFF"" "
		if now<=dateadd("h",num_del,td)+1 then
			'Response.write """ colspan=""2"" align=""center"" bgcolor=""#FFFFFF"" "
			Response.write " onClick=""javascript:window.open('../plan/addhome.asp?date1="
			Response.write td
			Response.write "&time1=08','_blank_1','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;""  style=""cursor:hand""  title=""点击添加更多日程"" "
			'Response.write td
		else
			Response.write " onClick=""confirm('"
			Response.write num_del
			Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
		end if
		Response.write ">上午</td>" & vbcrlf & "   "
		if m1>0 then
			k=""
			n=1
			do until rs.eof
				pid = rs("ord")
				If rs("starttime1")="" Or isnull(rs("starttime1")) Then
					starttime="00：00 - "
'If rs("starttime1")="" Or isnull(rs("starttime1")) Then
				else
					starttime=rs("starttime1")&"："&rs("starttime2")&" - "
'If rs("starttime1")="" Or isnull(rs("starttime1")) Then
				end if
				dim k
				if datediff("d",rs("startdate1"),rs("date1"))=0 then
					k="<b><font class=name>"&starttime & rs("time1")&"："&rs("time2")&"</font></b>"&" "&rs("intro") &"<span class=""addTime"">("&rs("addPerson")&"&nbsp;"& rs("date7") &")</span>"
				else
					k="<b><font class=name>"&starttime & "(" & rs("date1") & ") " & rs("time1")&"："&rs("time2")&"</font></b>"&" "&rs("intro") &"<span class=""addTime"">("&rs("addPerson")&"&nbsp;"& rs("date7") &")</span>"
				end if
				Response.write "" & vbcrlf & "  <td>" & vbcrlf & ""
				If (open_71_1=1 And CheckPurview(intro_71_1,cateid)=true) Or open_71_1=3 Then
					If (open_71_14=1 And CheckPurview(intro_71_14,cateid)=true) Or open_71_14=3 Then
						Response.write "" & vbcrlf & " <a href=""javascript:void(0)"" class=""ewebeditorImg_plan"" onclick=""javascript:window.open('../plan/content.asp?ord="
						Response.write pwurl(rs("ord"))
						Response.write "','_blank_2','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">"
'Response.write pwurl(rs("ord"))
					else
						Response.write "<a class=""ewebeditorImg"">"
					end if
					if rs("order1")<>"" And rs("order1")<>"0" then
						Response.write "<font class=""red"">"
					else
						Response.write "<font color=""#5B7CAE"">"
					end if
					Response.write k
					Response.write "</font></a>" & vbcrlf & "  "
				end if
				Response.write "" & vbcrlf & "  </td>" & vbcrlf & "" & vbcrlf & ""
				dim company,companyord
				company=""
				company2=""
				companyord=0
				if rs("company")<>"0" then
					set rs7=server.CreateObject("adodb.recordset")
					sql7="select ord,name,cateid,ISNULL(share,0) share,sort3 from tel where ord="&rs("company")&" and del=1"
					rs7.open sql7,conn,1,1
					if rs7.eof then
						company="对应客户已被删除"
						company2="对应客户已被删除"
						cateid2=0
						share=0
						sort3=1
					else
						share=rs7("share")
						company=rs7("name")
						company2=rs7("name")
						companyord=rs7("ord")
						cateid2=rs7("cateid")
						sort3=CLng(rs7("sort3"))
					end if
					rs7.close
					set rs7=Nothing
				else
					sort3=1
				end if
				Response.write "" & vbcrlf & "<td "
				if rs("company")="0" And (rs("order1") & "" = uid Or rs("order1")&"" = "" Or  rs("order1")&"" = "0")  And Not IsHasReply(pid)  Then
					if now<=dateadd("h",num_del,rs("date1"))+1 then
						If (sort3=1 And (open_1_1=1 Or open_1_1=3)) Or (sort3=2 And (open_26_1=1 Or open_26_1=3)) _
						And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) Then
							Response.write "" & vbcrlf & " onClick=""javascript:window.open('../search/result4home.asp?ord="
							Response.write rs("ord")
							Response.write "&intfrom=1&cangys=1','newwin3','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" style=""cursor:hand""  title=""点击关联客户"" " & vbcrlf & ""
							'Response.write rs("ord")
						end if
					else
						Response.write " onClick=""confirm('"
						Response.write num_del
						Response.write "小时后不能再对前一天及以前的日程进行任何修改！')""" & vbcrlf & "   "
					end if
				end if
				Response.write ">" & vbcrlf & ""
				if (sort3 = 1 And (open_1_1=3 or (open_1_1=1 And CheckPurview(intro_1_1,trim(cateid2))=True) Or share&""="1" Or CheckPurview(replace(share&""," ",""),trim(session("personzbintel2007"))))) _
				Or (sort3 = 2 And (open_26_1=3 or (open_26_1=1 And CheckPurview(intro_1_1,trim(cateid2))=True))) Then
					if (sort3 = 1 And (open_1_14=3 or CheckPurview(intro_1_14,trim(cateid2))=True)) _
					Or (sort3 = 2 And (open_26_14=3 or CheckPurview(intro_26_14,trim(cateid2))=True)) Then
						Response.write "" & vbcrlf & "  <a href=""javascript:void(0)"" onclick=""javascript:window.open('../work"
						Response.write iif(sort3=2,"2","")
						Response.write "/content.asp?ord="
						Response.write pwurl(companyord)
						Response.write "','_blank','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title="""
						'Response.write pwurl(companyord)
						Response.write company
						Response.write """>" & vbcrlf & ""
					end if
					Response.write "" & vbcrlf & "  <font color=""#5B7CAE"">"
					Response.write company2
					Response.write "</a>" & vbcrlf & ""
				end if
				If   Not IsHasReply(pid) _
				And rs("company") > 0 _
				And (rs("order1")&"" = uid Or rs("order1")&"" = "" Or  rs("order1")&"" = "0") _
				And Now <= DateAdd("h",num_del,rs("date1")) + 1 _
				And (rs("order1")&"" = uid Or rs("order1")&"" = "" Or  rs("order1")&"" = "0") _
				And ( _
				(sort3 = 1 And ( _
				open_1_1 = 3 _
				Or (open_1_1=1 And CheckPurview(intro_1_1,trim(cateid2))=True) _
				Or share&""="1" _
				Or CheckPurview(replace(share&""," ",""),trim(session("personzbintel2007"))) _
				)) _
				Or _
				(sort3 = 2 And ( _
				open_26_1=3 _
				Or (open_26_1=1 And CheckPurview(intro_26_1,trim(cateid2))=True) _
				)) _
				) And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) Then
					Response.write "" & vbcrlf & "<div style=""margin-top:5px; text-align:right;"">" & vbcrlf & " <img src=""../images/jiantou.gif""><a href=""javascript:void(0)"" onClick=""javascript:window.open('../search/result4home.asp?ord="
') And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) Then
					Response.write rs("ord")
					Response.write "&intfrom=1&cangys=1','newwin','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;""><font style=""color:#5b7cae"">更改<font></a>" & vbcrlf & "</div>" & vbcrlf & ""
'Response.write rs("ord")
				end if
				Response.write "" & vbcrlf & "  </td>" & vbcrlf & " "
				dim chance,chanceord,result2
				chance=""
				chance2=""
				chanceord=0
				result2=""
				if rs("chance")<>"0" then
					set rs7=server.CreateObject("adodb.recordset")
					sql7="select ord,title,cateid,ISNULL(share,0) share,(select color from sortjh2 where ord=a.complete2) as color  from chance a where ord="&rs("chance")&" and del=1"
					rs7.open sql7,conn,1,1
					if rs7.eof then
						chance="对应项目已被删除"
						chance2="对应项目已被删除"
						cateid2=0
						share=0
					else
						chance=rs7("title")
						chance2=rs7("title")
						chanceord=rs7("ord")
						cateid2=rs7("cateid")
						share=rs7("share")
						color=rs7("color")
					end if
					rs7.close
					set rs7=nothing
				end if
				if ZBRuntime.MC(3000) then
					Response.write "" & vbcrlf & " <td "
					if rs("chance")="0" And (rs("order1") & "" = uid Or rs("order1")&"" = "" Or  rs("order1")&"" = "0")  And Not IsHasReply(pid)  Then
						if now<=dateadd("h",num_del,rs("date1"))+1 then
							If (open_3_1=1 Or open_3_1=3) And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) Then
								Response.write "" & vbcrlf & "  onClick=""javascript:window.open('../chance/resulthome.asp?ord="
								Response.write rs("ord")
								Response.write "&intfrom=1','newwin4','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" style=""cursor:hand""  title=""点击添加关联项目"" " & vbcrlf & "  "
								'Response.write rs("ord")
							end if
						else
							Response.write " onClick=""confirm('"
							Response.write num_del
							Response.write "小时后不能再对前一天及以前的日程进行任何修改！')""" & vbcrlf & "  "
						end if
					end if
					Response.write ">" & vbcrlf & "  "
					if open_3_1=3 or CheckPurview(intro_3_1,trim(cateid2))=True Or share&""="1" Or CheckPurview(replace(share&""," ",""),trim(session("personzbintel2007"))) then
						if open_3_14=3 or CheckPurview(intro_3_14,trim(cateid2))=True then
							Response.write "<a href=""javascript:void(0)"" onclick=""javascript:window.open('../chance/content.asp?ord="
							Response.write pwurl(chanceord)
							Response.write "','_blank','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title="""
							'Response.write pwurl(chanceord)
							Response.write chance
							Response.write """>"
						end if
						Response.write "<span style=""color:"
						Response.write color
						Response.write """>"
						Response.write chance2
						Response.write "</span></a>" & vbcrlf & " "
					end if
					If   Not IsHasReply(pid) _
					And rs("chance") > 0 _
					And (rs("order1") = uid Or rs("order1")&"" = "" Or  rs("order1")&"" = "0") _
					And Now <= DateAdd("h",num_del,rs("date1")) + 1 _
					And (rs("order1") = uid Or rs("order1")&"" = "" Or  rs("order1")&"" = "0") _
					And ( _
					open_3_1=3 _
					or (open_3_1=1 And CheckPurview(intro_3_1,trim(cateid2))=True) _
					Or share&""="1" _
					Or CheckPurview(replace(share&""," ",""),trim(session("personzbintel2007"))) _
					) And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) Then
						Response.write "" & vbcrlf & "<div style=""margin-top:5px; text-align:right;"">" & vbcrlf & "<img src=""../images/jiantou.gif""><a href=""javascript:void(0)"" onClick=""javascript:window.open('../chance/resulthome.asp?ord="
') And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) Then
						Response.write rs("ord")
						Response.write "&intfrom=1','newwin','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;""><font style=""color:#5b7cae"">更改<font></a>" & vbcrlf & "</div>" & vbcrlf & ""
'Response.write rs("ord")
					end if
					Response.write "" & vbcrlf & " </td>" & vbcrlf & ""
				end if
				dim person,personord
				person="" : person2="" : personord=0 : khcateid = 0 : khshare = "" : sharecontact = 0
				if rs("person")<>"0" then
					set rs7=server.CreateObject("adodb.recordset")
					sql7="select p.ord,p.name,isnull(t.cateid,0) khcateid,isnull(t.share,'') share,isnull(t.sharecontact,0) sharecontact  from person p left join tel t on p.company=t.ord where p.ord="&rs("person")&" and p.del=1"
					rs7.open sql7,conn,1,1
					if rs7.eof then
						person="联系人已被删除"
						person2="联系人已被删除"
					else
						person=rs7("name")
						person2=rs7("name")
						personord=rs7("ord")
						khcateid = rs7("khcateid") : khshare = rs7("share") : sharecontact = rs7("sharecontact")
						if right(person2,3)<>"" then
							if len(person2)>4 then person2=left(person2,4)
						end if
					end if
					rs7.close
					set rs7=nothing
				end if
				Response.write "" & vbcrlf & " <td align=""center"" "
				if rs("person")="0" And (rs("order1") & "" = uid Or rs("order1")&"" = "" Or  rs("order1")&"" = "0") And Not IsHasReply(pid) Then
					if now<=dateadd("h",num_del,rs("date1"))+1 then
						If (open_2_1=1 Or open_2_1=3) And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) Then
							Response.write "" & vbcrlf & " onClick=""javascript:window.open('../search2/resulthome.asp?ord="
							Response.write rs("ord")
							Response.write "&intfrom=1','newwin5','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')"" style=""cursor:hand""  title=""点击关联联系人"" " & vbcrlf & " "
							'Response.write rs("ord")
						end if
					else
						Response.write " onClick=""confirm('"
						Response.write num_del
						Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
					end if
				end if
				Response.write ">" & vbcrlf & "   "
				if open_2_1=3 or (open_2_1=1 And (CheckPurview(intro_2_1,trim(khcateid))=True Or (sharecontact=1 And (khshare="1" Or CheckPurview(khshare,trim(session("personzbintel2007")))=True) ))) then
					if open_2_14=3 or CheckPurview(intro_2_14,trim(khcateid))=True then
						Response.write "<a href=""javascript:void(0)"" onclick=""javascript:window.open('../person/content.asp?ord="
						Response.write pwurl(personord)
						Response.write "','_blank','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title="""
						'Response.write pwurl(personord)
						Response.write person
						Response.write """>"
					end if
					Response.write "<font color=""#5B7CAE"">"
					Response.write person2
					Response.write "</a>"
				end if
				If  Not IsHasReply(pid) _
				And rs("person") > 0 _
				And (rs("order1")&"" = uid Or rs("order1")&"" = "" Or  rs("order1")&"" = "0") _
				And Now <= DateAdd("h",num_del,rs("date1")) + 1 _
				And (rs("order1")&"" = uid Or rs("order1")&"" = "" Or  rs("order1")&"" = "0") _
				And (open_2_1=1 Or open_2_1=3) And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) Then
					Response.write "" & vbcrlf & "<div style=""margin-top:5px; text-align:right;"">" & vbcrlf & "<img src=""../images/jiantou.gif""><a href=""javascript:void(0)"" onClick=""javascript:window.open('../search2/resulthome.asp?ord="""
'And (open_2_1=1 Or open_2_1=3) And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) Then
					Response.write rs("ord")
					Response.write "&intfrom=1','newwin','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')""><font style=""color:#5b7cae"">更改<font></a>" & vbcrlf & "  </div>" & vbcrlf & ""
'Response.write rs("ord")
				end if
				Response.write "" & vbcrlf & "" & vbcrlf & " </td>" & vbcrlf & ""
				dim lcb,lcbord
				lcb=""
				lcb2=""
				lcbord=""
				if rs("lcb")<>"0" then
					set rs7=server.CreateObject("adodb.recordset")
					sql7="select ord,sort1  from sortjh2 where ord="&rs("lcb")&""
					rs7.open sql7,conn,1,1
					if rs7.eof then
						lcb="对应阶段已被删除"
						lcb2="对应阶段已被删除"
					else
						lcb=rs7("sort1")
						lcb2=rs7("sort1")
						lcbord=rs7("ord")
						if right(lcb2,3)<>"" then
							if len(lcb2)>4 then lcb2=left(lcb2,4)
						end if
					end if
					rs7.close
					set rs7=nothing
				end if
				if ZBRuntime.MC(3000) then
					Response.write "" & vbcrlf & "<td align=""center""  "
					if rs("lcb")="0"  And (open_3_13=1 Or open_3_13=3 )  And Not IsHasReply(pid) then
						if now<=dateadd("h",num_del,rs("date1"))+1 then
'if rs("lcb")="0"  And (open_3_13=1 Or open_3_13=3 )  And Not IsHasReply(pid) then
							Response.write " onClick=""javascript:window.open('../chance/correctlcb.asp?ord="
							Response.write rs("ord")
							Response.write "','_blank_6','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')"" style=""cursor:hand""  title=""点击添加里程碑"""
							'Response.write rs("ord")
						else
							Response.write " onClick=""confirm('"
							Response.write num_del
							Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
						end if
					end if
					Response.write ">" & vbcrlf & " "
					if open_3_1=3 or CheckPurview(intro_3_1,trim(cateid2))=True then
						if open_3_14=3 or CheckPurview(intro_3_14,trim(cateid2))=True Then
							unsave = 0
							if now>dateadd("h",num_del,rs("date1"))+1 or ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=False) Or open_71_2=0) Or IsHasReply(pid)  Then unsave=1
'unsave = 0
							Response.write "" & vbcrlf & " <a href=""javascript:void(0)"" onclick=""javascript:window.open('../chance/correctlcb.asp?ord="
							Response.write rs("ord")
							Response.write "&unsave="
							Response.write unsave
							Response.write "','_blank','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title="""
							'Response.write unsave
							Response.write lcb
							Response.write """>"
						end if
						Response.write "<font color=""#5B7CAE"">"
						Response.write lcb2
						Response.write "</a>"
					end if
					Response.write "</td>" & vbcrlf & ""
				end if
				intro=""
				intro2=""
				introord=""
				if rs("intro2")<>"" and PowerV_71_1 then
					intro=rs("intro2")
					intro2=rs("intro2")
				end if
				Response.write "" & vbcrlf & " <td align=""left""  "
				if rs("intro2")<>"" then
					if now<=dateadd("h",num_del,rs("date1"))+1 And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) then
'if rs("intro2")<>"" then
						Response.write " " & vbcrlf & "onClick=""javascript:window.open('../plan/correctreply.asp?ord="
						Response.write rs("ord")
						Response.write "','newwin7','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" style=""cursor:hand""  title="""
						'Response.write rs("ord")
						Response.write HTMLDecode(intro)
						Response.write """ " & vbcrlf & ""
					end if
				else
					if now<=dateadd("h",num_del,rs("date1"))+1 then
						Response.write """ " & vbcrlf & ""
						Response.write " " & vbcrlf & "onClick=""javascript:window.open('../plan/replyhome.asp?ord="
						Response.write pwurl(rs("ord"))
						Response.write "&intfrom=1','newwin','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')"" style=""cursor:hand""  title=""点击添加洽谈进展"" " & vbcrlf & ""
						'Response.write pwurl(rs("ord"))
					else
						Response.write " " & vbcrlf & "onClick=""confirm('"
						Response.write num_del
						Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"" " & vbcrlf & ""
					end if
				end if
				Response.write ">" & vbcrlf & " "
				if rs("intro2")<>"" and PowerV_71_1 Then
					If now>dateadd("h",num_del,rs("date1"))+1 Or (now<=dateadd("h",num_del,rs("date1"))+1 And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=False ) Or open_71_2 = 0) )  Then
'if rs("intro2")<>"" and PowerV_71_1 Then
						Response.write "<a href=""javascript:void(0)"" onclick=""javascript:window.open('../plan/content_replay.asp?ord="
						Response.write pwurl(rs("ord"))
						Response.write "','newwin8','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title="""
						'Response.write pwurl(rs("ord"))
						Response.write HTMLDecode(intro)
						Response.write """>" & vbcrlf & ""
					end if
				end if
				Response.write "<font color=""#5B7CAE"">"
				Response.write intro2
				Response.write "</a>"
				If intro2<>"" Then
					Response.write "<span class=""addTime"">("
					Response.write rs("r_addPerson")
					Response.write "&nbsp;"
					Response.write rs("r_date7")
					Response.write ")</span>"
				end if
				Response.write "" & vbcrlf & "  " & vbcrlf & "   " & vbcrlf & "</td>" & vbcrlf & ""
				if ZBRuntime.MC(27000) then
					fee=0
					set rs2=server.CreateObject("adodb.recordset")
					strSql="select * from pay where richeng="&rs("ord")&" and del=1 and complete=3"
					rs2.open strSql,conn
					if not rs2.eof then
						fee=1
					end if
					rs2.close
					set rs2=nothing
					Response.write "" & vbcrlf & " <td align=""left""  "
					if fee=0 then
						if open_6_13=3 or CheckPurview(intro_6_13,trim(cateid))=True then
							if now<=dateadd("h",num_del,rs("date1"))+1 then
'if open_6_13=3 or CheckPurview(intro_6_13,trim(cateid))=True then
								Response.write " onClick=""javascript:window.open('../pay/add2.asp?qttype=richeng&qtord="
								Response.write pwurl(rs("ord"))
								Response.write "','newin9','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" style=""cursor:hand""  title=""点击添加费用"" "
								'Response.write pwurl(rs("ord"))
							else
								Response.write " onClick=""confirm('"
								Response.write num_del
								Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
							end if
						end if
					end if
					Response.write ">" & vbcrlf & ""
					sort=""
					pay=""
					intropay=""
					if rs("pay")="0" then
						set rs7=server.CreateObject("adodb.recordset")
						sql7="select * from pay where richeng="&rs("ord")&" and del=1 and complete=3 order by ord asc"
						rs7.open sql7,conn,1,1
						do until rs7.eof
							if rs7.eof then
								intropay="对应费用已被删除"
							else
								intropay=rs7("title")
								pay=rs7("money1")
								pay=Formatnumber(pay,num_dot_xs,-1)
								pay=rs7("money1")
								bz=rs7("bz")
								payord=rs7("fid")
								set rs8=server.CreateObject("adodb.recordset")
								sql8="select intro  from sortbz where id="&bz&""
								rs8.open sql8,conn,1,1
								bzname=rs8("intro")
								rs8.close
								set rs8=nothing
								pay=bzname&pay
								set rs8=server.CreateObject("adodb.recordset")
								sql8="select sort1,sort2  from paytype where id="&rs7("sort")&""
								rs8.open sql8,conn,1,1
								sort1name=rs8("sort1")
								sort2=rs8("sort2")
								rs8.close
								set rs8=nothing
								if sort2="" or isnull(sort2) then sort2=0
								set rs8=server.CreateObject("adodb.recordset")
								sql8="select sort1  from sortonehy where ord="&sort2&""
								rs8.open sql8,conn,1,1
								sort2name=rs8("sort1")
								rs8.close
								set rs8=nothing
							end if
							if open_6_1=3 or CheckPurview(intro_6_1,rs7("cateid"))=True then
								if open_6_14=3 or CheckPurview(intro_6_14,rs7("cateid"))=True then
									Response.write "" & vbcrlf & "<a href=""javascript:void(0);"" onclick=""javascript:window.open('../pay/paydetail.asp?ord="
									Response.write (payord)
									Response.write "','viewpay10','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title="""
									Response.write (payord)
									Response.write intropay
									Response.write """>"
								end if
								Response.write "<font color=""#5B7CAE"">"
								Response.write sort2name
								Response.write "→"
								Response.write sort1name
								Response.write "&nbsp;"
								Response.write pay
								Response.write "</font></a>" & vbcrlf & " <br>" & vbcrlf & " "
							end if
							i7=i7+1
'Response.write "</font></a>" & vbcrlf & " <br>" & vbcrlf & " "
							rs7.movenext
						loop
						rs7.close
						set rs7=nothing
					end if
					Response.write "" & vbcrlf & " </td>" & vbcrlf & ""
				end if
				Response.write "" & vbcrlf & "  </tr>" & vbcrlf & " "
				n=n+1
'Response.write "" & vbcrlf & "  </tr>" & vbcrlf & " "
				rs.movenext
				if rs.eof then exit do
			Loop
		else
			Response.write "" & vbcrlf & "  <td "
			if now<=dateadd("h",num_del,td)+1 then
				'Response.write "" & vbcrlf & "  <td "
				Response.write "  onClick=""javascript:window.open('../plan/addhome.asp?date1="
				Response.write td
				Response.write "&time1=08','_blank_21','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')""  style=""cursor:hand""  title=""点击添加日程""  "
				'Response.write td
			else
				Response.write "onClick=""confirm('"
				Response.write num_del
				Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
			end if
			Response.write "></td>" & vbcrlf & "  <td align=""center"" "
			if now<=dateadd("h",num_del,td)+1 then
				'Response.write "></td>" & vbcrlf & "  <td align=""center"" "
				Response.write "  onClick=""if(confirm('只有添加了日程后，才可以添加其对应的其它栏目内容，现在添加日程？')){window.open('../plan/addhome.asp?date1="
				Response.write td
				Response.write "&time1=08','_blank','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;}"""
				'Response.write td
			else
				Response.write " onClick=""confirm('"
				Response.write num_del
				Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
			end if
			Response.write "></td>" & vbcrlf & ""
			if ZBRuntime.MC(3000) then
				Response.write "" & vbcrlf & " <td align=""center"" "
				if now<=dateadd("h",num_del,td)+1 then
					'Response.write "" & vbcrlf & " <td align=""center"" "
					Response.write "  onClick=""if(confirm('只有添加了日程后，才可以添加其对应的其它栏目内容，现在添加日程？')){window.open('../plan/addhome.asp?date1="
					Response.write td
					Response.write "&time1=08','_blank_22','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;}"""
					'Response.write td
				else
					Response.write " onClick=""confirm('"
					Response.write num_del
					Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
				end if
				Response.write "></td>" & vbcrlf & ""
			end if
			Response.write "" & vbcrlf & "<td align=""center"" "
			if now<=dateadd("h",num_del,td)+1 then
				'Response.write "" & vbcrlf & "<td align=""center"" "
				Response.write "  onClick=""if(confirm('只有添加了日程后，才可以添加其对应的其它栏目内容，现在添加日程？')){window.open('../plan/addhome.asp?date1="
				Response.write td
				Response.write "&time1=08','_blank_23','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;}"""
				'Response.write td
			else
				Response.write " onClick=""confirm('"
				Response.write num_del
				Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
			end if
			Response.write "></td>" & vbcrlf & ""
			if ZBRuntime.MC(3000) then
				Response.write "" & vbcrlf & "  <td align=""center"" "
				if now<=dateadd("h",num_del,td)+1 then
					'Response.write "" & vbcrlf & "  <td align=""center"" "
					Response.write "  onClick=""if(confirm('只有添加了日程后，才可以添加其对应的其它栏目内容，现在添加日程？')){window.open('../plan/addhome.asp?date1="
					Response.write td
					Response.write "&time1=08','_blank_23','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;}"""
					'Response.write td
				else
					Response.write " onClick=""confirm('"
					Response.write num_del
					Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
				end if
				Response.write "></td>" & vbcrlf & ""
			end if
			Response.write "" & vbcrlf & "<td align=""center"" "
			if now<=dateadd("h",num_del,td)+1 then
				'Response.write "" & vbcrlf & "<td align=""center"" "
				Response.write "  onClick=""if(confirm('只有添加了日程后，才可以添加其对应的其它栏目内容，现在添加日程？')){window.open('../plan/addhome.asp?date1="
				Response.write td
				Response.write "&time1=08','_blank_23','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;}"""
				'Response.write td
			else
				Response.write " onClick=""confirm('"
				Response.write num_del
				Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
			end if
			Response.write "></td>" & vbcrlf & ""
			if ZBRuntime.MC(27000) then
				Response.write "" & vbcrlf & " <td align=""center"" "
				if now<=dateadd("h",num_del,td)+1 then
					'Response.write "" & vbcrlf & " <td align=""center"" "
					Response.write "  onClick=""if(confirm('只有添加了日程后，才可以添加其对应的其它栏目内容，现在添加日程？')){window.open('../plan/addhome.asp?date1="
					Response.write td
					Response.write "&time1=08','_blank_24','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;}"""
					'Response.write td
				else
					Response.write " onClick=""confirm('"
					Response.write num_del
					Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
				end if
				Response.write "></td>" & vbcrlf & ""
			end if
			Response.write "" & vbcrlf & "  </tr>" & vbcrlf & "  "
		end if
		Response.write "" & vbcrlf & "  <tr>" & vbcrlf & "<td rowspan="""
		Response.write count3
		Response.write """ colspan=""2"" align=""center"" bgcolor=""#FFFFFF"""
		if now<=dateadd("h",num_del,td)+1 then
			'Response.write """ colspan=""2"" align=""center"" bgcolor=""#FFFFFF"""
			Response.write "  onClick=""javascript:window.open('../plan/addhome.asp?date1="
			Response.write td
			Response.write "&time1=12','_blank_25','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')""  style=""cursor:hand""  title=""点击添加日程"" "
			'Response.write td
		else
			Response.write " onClick=""confirm('"
			Response.write num_del
			Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
		end if
		Response.write ">下午</td>" & vbcrlf & ""
		if m2>0 then
			k1=""
			n1=0
			do until rs1.eof
				pid1 = rs1("ord")
				If rs1("starttime1")="" Or isnull(rs1("starttime1")) Then
					starttime="12：00 - "
'If rs1("starttime1")="" Or isnull(rs1("starttime1")) Then
				else
					starttime=rs1("starttime1")&"："&rs1("starttime2")&" - "
'If rs1("starttime1")="" Or isnull(rs1("starttime1")) Then
				end if
				dim k1
				if datediff("d",rs1("startdate1"),rs1("date1"))=0 then
					k1="<b><font class=name>"&starttime & rs1("time1")&"："&rs1("time2")&"</font></b>"&" "&rs1("intro") &"<span class=""addTime"">("&rs1("addPerson")&"&nbsp;"& rs1("date7") &")</span>"
				else
					k1="<b><font class=name>"&starttime & "(" & rs1("date1") & ") " & rs1("time1")&"："&rs1("time2")&"</font></b>"&" "&rs1("intro") &"<span class=""addTime"">("&rs1("addPerson")&"&nbsp;"& rs1("date7") &")</span>"
				end if
				Response.write "" & vbcrlf & " <td>" & vbcrlf & ""
				If (open_71_1=1 And CheckPurview(intro_71_1,cateid)=true) Or open_71_1=3 Then
					If (open_71_14=1 And CheckPurview(intro_71_14,cateid)=true) Or open_71_14=3 Then
						Response.write "" & vbcrlf & " <a class=""ewebeditorImg_plan"" href=""javascript:void(0)"" onclick=""javascript:window.open('../plan/content.asp?ord="
						Response.write pwurl(rs1("ord"))
						Response.write "','_blank_22','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">"
						'Response.write pwurl(rs1("ord"))
					else
						Response.write "<a class=""ewebeditorImg"">"
					end if
					if rs1("order1")<>"" And rs1("order1")<>"0"  then
						Response.write "<font class=""red"">"
					else
						Response.write "<font color=""#5B7CAE"">"
					end if
					Response.write k1
					Response.write "</font></a>"
				end if
				Response.write "</td>" & vbcrlf & "   "
				company=""
				company2=""
				companyord=0
				if rs1("company")<>"0" then
					set rs7=server.CreateObject("adodb.recordset")
					sql7="select ord,name,cateid,ISNULL(share,0) share,sort3  from tel where ord="&rs1("company")&" and del=1 "
					rs7.open sql7,conn,1,1
					if rs7.eof then
						company="对应客户已被删除"
						company2="对应客户已被删除"
						cateid2=0
						share=0
						sort3=1
					else
						share=rs7("share")
						company=rs7("name")
						company2=rs7("name")
						companyord=rs7("ord")
						cateid2=rs7("cateid")
						sort3=CLng(rs7("sort3"))
					end if
					rs7.close
					set rs7=nothing
				end if
				Response.write "" & vbcrlf & "<td " & vbcrlf & ""
				if rs1("company")="0" And (rs1("order1") & "" = uid Or rs1("order1")&"" = "" Or  rs1("order1")&"" = "0")  And Not IsHasReply(pid1)  Then
					if now<=dateadd("h",num_del,rs1("date1"))+1 then
						If (open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3 Then
							Response.write "" & vbcrlf & "  onClick=""javascript:window.open('../search/result4home.asp?ord="
							Response.write rs1("ord")
							Response.write "&intfrom=1&cangys=1','newwin21','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" style=""cursor:hand""  title=""点击关联客户"" " & vbcrlf & ""
							'Response.write rs1("ord")
						end if
					else
						Response.write "" & vbcrlf & "  onClick=""confirm('"
						Response.write num_del
						Response.write "小时后不能再对前一天及以前的日程进行任何修改！')""" & vbcrlf & ""
					end if
				end if
				Response.write "" & vbcrlf & "  >   " & vbcrlf & ""
				if (sort3 = 1 And (open_1_1=3 or (open_1_1=1 And CheckPurview(intro_1_1,trim(cateid2))=True) Or share&""="1" Or CheckPurview(replace(share&""," ",""),trim(session("personzbintel2007"))))) _
				Or (sort3 = 2 And (open_26_1=3 or (open_26_1=1 And CheckPurview(intro_1_1,trim(cateid2))=True))) Then
					if (sort3 = 1 And (open_1_14=3 or CheckPurview(intro_1_14,trim(cateid2))=True)) _
					Or (sort3 = 2 And (open_26_14=3 or CheckPurview(intro_26_14,trim(cateid2))=True)) Then
						Response.write "" & vbcrlf & "  <a href=""javascript:void(0)"" onclick=""javascript:window.open('../work"
						Response.write iif(sort3=2,"2","")
						Response.write "/content.asp?ord="
						Response.write pwurl(companyord)
						Response.write "','_blank_20','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title="""
						'Response.write pwurl(companyord)
						Response.write company
						Response.write """>" & vbcrlf & ""
					end if
					Response.write "" & vbcrlf & "  <font color=""#5B7CAE"">"
					Response.write company2
					Response.write "</a>" & vbcrlf & ""
				end if
				If   Not IsHasReply(pid1) _
				And rs1("company") > 0 _
				And (rs1("order1")&"" = uid Or rs1("order1")&"" = "" Or  rs1("order1")&"" = "0") _
				And Now <= DateAdd("h",num_del,rs1("date1")) + 1 _
				And (rs1("order1")&"" = uid Or rs1("order1")&"" = "" Or  rs1("order1")&"" = "0") _
				And ( _
				(sort3 = 1 And ( _
				open_1_1 = 3 _
				Or (open_1_1=1 And CheckPurview(intro_1_1,trim(cateid2))=True) _
				Or share&""="1" _
				Or CheckPurview(replace(share&""," ",""),trim(session("personzbintel2007"))) _
				)) _
				Or _
				(sort3 = 2 And ( _
				open_26_1=3 _
				Or (open_26_1=1 And CheckPurview(intro_26_1,trim(cateid2))=True) _
				)) _
				)  Then
					Response.write "" & vbcrlf & "<div style=""margin-top:5px; text-align:right;"">" & vbcrlf & " <img src=""../images/jiantou.gif""><a href=""javascript:void(0)"" onClick=""javascript:window.open('../search/result4home.asp?ord="
')  Then
					Response.write rs1("ord")
					Response.write "&intfrom=1&cangys=1','newwin','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;""><font style=""color:#5b7cae"">更改<font></a>" & vbcrlf & "</div>" & vbcrlf & ""
					'Response.write rs1("ord")
				end if
				Response.write "" & vbcrlf & "" & vbcrlf & "  </td>" & vbcrlf & "  "
				chance=""
				chance2=""
				chanceord=0
				result2=""
				if rs1("chance")<>"0" then
					set rs7=server.CreateObject("adodb.recordset")
					sql7="select ord,title,cateid,ISNULL(share,0) share,(select color from sortjh2 where ord=a.complete2) as color  from chance a where ord="&rs1("chance")&" and del=1 "
					rs7.open sql7,conn,1,1
					if rs7.eof then
						chance="对应项目已被删除"
						chance2="对应项目已被删除"
						cateid2=0
						share=0
					else
						chance=rs7("title")
						chance2=rs7("title")
						chanceord=rs7("ord")
						cateid2=rs7("cateid")
						share=rs7("share")
						color=rs7("color")
						if right(chance2,3)<>"" then
							if len(chance2)>8 then chance2=left(chance2,8)
						end if
					end if
					rs7.close
					set rs7=nothing
				end if
				if ZBRuntime.MC(3000) then
					Response.write "" & vbcrlf & " <td "
					if rs1("chance")="0" And (rs1("order1") & "" = uid Or rs1("order1")&"" = "" Or  rs1("order1")&"" = "0") And Not IsHasReply(pid1)  Then
						if now<=dateadd("h",num_del,rs1("date1"))+1 then
							If (open_3_1=1 Or open_3_1=3) And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) Then
								Response.write "" & vbcrlf & " onClick=""javascript:window.open('../chance/resulthome.asp?ord="
								Response.write rs1("ord")
								Response.write "&intfrom=1','newwin19','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" style=""cursor:hand""  title=""点击添加关联项目"" " & vbcrlf & ""
								'Response.write rs1("ord")
							end if
						else
							Response.write " onClick=""confirm('"
							Response.write num_del
							Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
						end if
					end if
					Response.write ">" & vbcrlf & " "
					if open_3_1=3 or CheckPurview(intro_3_1,trim(cateid2))=True  Or share&""="1" Or CheckPurview(replace(share&""," ",""),trim(session("personzbintel2007")))  then
						if open_3_14=3 or CheckPurview(intro_3_14,trim(cateid2))=True then
							Response.write "<a href=""javascript:void(0)"" onclick=""javascript:window.open('../chance/content.asp?ord="
							Response.write pwurl(chanceord)
							Response.write "','_blank_18','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title="""
							'Response.write pwurl(chanceord)
							Response.write chance
							Response.write """>"
						end if
						Response.write "<span style=""color:"
						Response.write color
						Response.write """>"
						Response.write chance2
						Response.write "</span></a>" & vbcrlf & " "
					end if
					If  Not IsHasReply(pid1) _
					And rs1("chance") > 0 _
					And (rs1("order1")&"" = uid Or rs1("order1")&"" = "" Or  rs1("order1")&"" = "0") _
					And Now <= DateAdd("h",num_del,rs1("date1")) + 1 _
					And (rs1("order1")&"" = uid Or rs1("order1")&"" = "" Or  rs1("order1")&"" = "0") _
					And ( _
					open_3_1=3 _
					or (open_3_1=1 And CheckPurview(intro_3_1,trim(cateid2))=True) _
					Or share&""="1" _
					Or CheckPurview(replace(share&""," ",""),trim(session("personzbintel2007"))) _
					) and now<=dateadd("h",num_del,rs1("date1")) And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) Then
						Response.write "" & vbcrlf & "<div style=""margin-top:5px; text-align:right;"">" & vbcrlf & "<img src=""../images/jiantou.gif""><a href=""javascript:void(0)"" onClick=""javascript:window.open('../chance/resulthome.asp?ord="
						Response.write rs1("ord")
						Response.write "&intfrom=1','newwin','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;""><font style=""color:#5b7cae"">更改<font></a>" & vbcrlf & "</div>" & vbcrlf & ""
						'Response.write rs1("ord")
					end if
					Response.write "" & vbcrlf & " </td>" & vbcrlf & ""
				end if
				person=""
				person2=""
				personord=0
				if rs1("person")<>"0" then
					set rs7=server.CreateObject("adodb.recordset")
					sql7="select p.ord,p.name,isnull(t.cateid,0) as cateid,isnull(t.sharecontact,0) as sharecontact,t.share from person p left join tel t on p.company=t.ord where p.ord="&rs1("person")&" and p.del=1 "
					rs7.open sql7,conn,1,1
					if rs7.eof then
						person="联系人已被删除"
						preson2="联系人已被删除"
						cateid2=0
						sharecontact = 0
						share = ""
					else
						person=rs7("name")
						person2=rs7("name")
						personord=rs7("ord")
						cateid2=rs7("cateid")
						sharecontact = rs7("sharecontact")
						share = rs7("share")
						if right(person2,3)<>"" then
							if len(person2)>4 then person2=left(person2,4)
						end if
					end if
					rs7.close
					set rs7=nothing
				end if
				Response.write "" & vbcrlf & " <td align=""center"" "
				if rs1("person")="0" And (rs1("order1") & "" = uid Or rs1("order1")&"" = "" Or  rs1("order1")&"" = "0") And Not IsHasReply(pid1)  Then
					if now<=dateadd("h",num_del,rs1("date1"))+1 then
						If (open_2_1=1 Or open_2_1=3) And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) Then
							Response.write "" & vbcrlf & " onClick=""javascript:window.open('../search2/resulthome.asp?ord="
							Response.write rs1("ord")
							Response.write "&intfrom=1','newwin16','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')"" style=""cursor:hand""  title=""点击关联联系人"" " & vbcrlf & ""
							'Response.write rs1("ord")
						end if
					else
						Response.write " onClick=""confirm('"
						Response.write num_del
						Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
					end if
				end if
				Response.write ">" & vbcrlf & "   "
				if open_2_1=3 or CheckPurview(intro_2_1,trim(cateid2))=True Or ((share&""="1" Or CheckPurview(replace(share&""," ",""),trim(session("personzbintel2007")))) And sharecontact&""="1")  then
					if open_2_14=3 or CheckPurview(intro_2_14,trim(cateid2))=True then
						Response.write "<a href=""javascript:void(0)"" onclick=""javascript:window.open('../person/content.asp?ord="
						Response.write pwurl(personord)
						Response.write "','_blank_15','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title="""
						'Response.write pwurl(personord)
						Response.write person
						Response.write """>"
					end if
					Response.write "<font color=""#5B7CAE"">"
					Response.write person2
					Response.write "</a>" & vbcrlf & " "
				end if
				If  Not IsHasReply(pid1) _
				And rs1("person") > 0 _
				And (rs1("order1")&"" = uid Or rs1("order1")&"" = "" Or  rs1("order1")&"" = "0") _
				And Now <= DateAdd("h",num_del,rs1("date1")) + 1 _
				And (rs1("order1")&"" = uid Or rs1("order1")&"" = "" Or  rs1("order1")&"" = "0") _
				And (open_2_1=1 Or open_2_1=3) And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) Then
					Response.write "" & vbcrlf & "<div style=""margin-top:5px; text-align:right;"">" & vbcrlf & "<img src=""../images/jiantou.gif""><a href=""javascript:void(0)"" onClick=""javascript:window.open('../search2/resulthome.asp?ord="
'And (open_2_1=1 Or open_2_1=3) And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) Then
					Response.write rs1("ord")
					Response.write "&intfrom=1','newwin','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')""><font style=""color:#5b7cae"">更改<font></a>" & vbcrlf & "  </div>" & vbcrlf & ""
					'Response.write rs1("ord")
				end if
				Response.write "" & vbcrlf & " </td>" & vbcrlf & "   "
				lcb=""
				lcb2=""
				lcbord=0
				if rs1("lcb")<>"0" then
					set rs7=server.CreateObject("adodb.recordset")
					sql7="select ord,sort1  from sortjh2 where ord="&rs1("lcb")&""
					rs7.open sql7,conn,1,1
					if rs7.eof then
						lcb="对应阶段已被删除"
						lcb2="对应阶段已被删除"
					else
						lcb=rs7("sort1")
						lcb2=rs7("sort1")
						lcbord=rs7("ord")
						if right(lcb2,3)<>"" then
							if len(lcb2)>4 then lcb2=left(lcb2,4)
						end if
					end if
					rs7.close
					set rs7=nothing
				end if
				if ZBRuntime.MC(3000) then
					Response.write "" & vbcrlf & "<td align=""left"" "
					if rs1("lcb")="0" And (open_3_13=1 Or open_3_13=3 ) And Not IsHasReply(pid1)  then
						if now<=dateadd("h",num_del,rs1("date1"))+1 then
'if rs1("lcb")="0" And (open_3_13=1 Or open_3_13=3 ) And Not IsHasReply(pid1)  then
							Response.write " onClick=""javascript:window.open('../chance/correctlcb.asp?ord="
							Response.write rs1("ord")
							Response.write "','_blank_14','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')"" style=""cursor:hand""  title=""点击添加里程碑"" "
							'Response.write rs1("ord")
						else
							Response.write " onClick=""confirm('"
							Response.write num_del
							Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
						end if
					end if
					Response.write ">" & vbcrlf & ""
					if open_3_1=3 or CheckPurview(intro_3_1,trim(cateid2))=True then
						Response.write "" & vbcrlf & " <div align=""center"">  " & vbcrlf & ""
						if open_3_14=3 or CheckPurview(intro_3_14,trim(cateid2))=True Then
							unsave = 0
							if now>dateadd("h",num_del,rs1("date1"))+1  or ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=False) Or open_71_2=0) Or IsHasReply(pid1) Then unsave=1
							unsave = 0
							Response.write "" & vbcrlf & " <a href=""javascript:void(0)"" onclick=""javascript:window.open('../chance/correctlcb.asp?ord="
							Response.write rs1("ord")
							Response.write "&unsave="
							Response.write unsave
							Response.write "','_blank_13','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title="""
							'Response.write unsave
							Response.write lcb
							Response.write """>"
						end if
						Response.write "<font color=""#5B7CAE"">"
						Response.write lcb2
						Response.write "</a></div>" & vbcrlf & "   "
					end if
					Response.write "" & vbcrlf & " </td>" & vbcrlf & ""
				end if
				intro=""
				intro2=""
				introord=0
				if rs1("intro2")<>"" then
					intro=rs1("intro2")
					intro2=rs1("intro2")
				end if
				Response.write "" & vbcrlf & "<td "
				if rs1("intro2")<>"" then
					if now<=dateadd("h",num_del,rs1("date1"))+1 and now<=dateadd("h",num_del,rs1("date1")) And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) then
'if rs1("intro2")<>"" then
						Response.write " " & vbcrlf & "onClick=""javascript:window.open('../plan/correctreply.asp?ord="
						Response.write rs1("ord")
						Response.write "','newwin11','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" style=""cursor:hand""  title="""
						'Response.write rs1("ord")
						Response.write HTMLDecode(intro)
						Response.write """ " & vbcrlf & ""
					end if
				else
					if now<=dateadd("h",num_del,rs1("date1"))+1 then
						Response.write """ " & vbcrlf & ""
						Response.write " " & vbcrlf & "onClick=""javascript:window.open('../plan/replyhome.asp?ord="
						Response.write pwurl(rs1("ord"))
						Response.write "&intfrom=1','newwin12','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')"" style=""cursor:hand""  title=""点击添加洽谈进展"" " & vbcrlf & "  "
						'Response.write pwurl(rs1("ord"))
					else
						Response.write " " & vbcrlf & "onClick=""confirm('"
						Response.write num_del
						Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"" " & vbcrlf & ""
					end if
				end if
				Response.write ">" & vbcrlf & " "
				if rs1("intro2")<>"" and PowerV_71_1 Then
					If now>dateadd("h",num_del,rs1("date1"))+1 Or (now<=dateadd("h",num_del,rs1("date1"))+1 And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=False ) Or open_71_2 = 0) )  Then
'if rs1("intro2")<>"" and PowerV_71_1 Then
						Response.write "" & vbcrlf & " <a href=""javascript:void(0)"" onclick=""javascript:window.open('../plan/content_replay.asp?ord="
						Response.write pwurl(rs1("ord"))
						Response.write "','newwin','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title="""
						'Response.write pwurl(rs1("ord"))
						Response.write HTMLDecode(intro)
						Response.write """>" & vbcrlf & ""
					end if
				end if
				Response.write "<font color=""#5B7CAE"">"
				Response.write intro2
				Response.write "</a>"
				If intro2 <> "" Then
					Response.write "<span class=""addTime"">("
					Response.write rs1("r_addPerson")
					Response.write "&nbsp;"
					Response.write rs1("r_date7")
					Response.write ")</span>"
				end if
				Response.write "" & vbcrlf & " </td>" & vbcrlf & ""
				if ZBRuntime.MC(27000) Then
					set rs2=server.CreateObject("adodb.recordset")
					fee=0
					strSql="select * from pay where richeng="&rs1("ord")&"  and del=1 and complete=3"
					rs2.open strSql,conn
					if not rs2.eof then
						fee=1
					end if
					rs2.close
					set rs2=nothing
					Response.write "" & vbcrlf & " <td align=""left"" "
					if fee=0 then
						if open_6_13=3 or CheckPurview(intro_6_13,trim(cateid))=True then
							if now<=dateadd("h",num_del,rs1("date1"))+1 then
'if open_6_13=3 or CheckPurview(intro_6_13,trim(cateid))=True then
								Response.write " onClick=""javascript:window.open('../pay/add2.asp?qttype=richeng&qtord="
								Response.write pwurl(rs1("ord"))
								Response.write "','_blank','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" style=""cursor:hand""  title=""点击添加费用""  "
								'Response.write pwurl(rs1("ord"))
							else
								Response.write " onClick=""confirm('"
								Response.write num_del
								Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
							end if
						end if
					end if
					Response.write ">" & vbcrlf & ""
					sort=""
					pay=""
					intropay2=""
					if rs1("pay")="0" then
						set rs7=server.CreateObject("adodb.recordset")
						sql7="select * from pay where richeng="&rs1("ord")&"  and del=1 and complete=3 order by ord asc"
						rs7.open sql7,conn,1,1
						do until rs7.eof
							if rs7.eof then
								intropay2="对应费用已被删除"
							else
								intropay=rs7("title")
								pay=rs7("money1")
								pay=Formatnumber(pay,num_dot_xs,-1)
								pay=rs7("money1")
								bz=rs7("bz")
								payord=rs7("fid")
								set rs8=server.CreateObject("adodb.recordset")
								sql8="select intro  from sortbz where id="&bz&""
								rs8.open sql8,conn,1,1
								bzname=rs8("intro")
								rs8.close
								set rs8=nothing
								pay=bzname&pay
								set rs8=server.CreateObject("adodb.recordset")
								sql8="select sort1,sort2  from paytype where id="&rs7("sort")&""
								rs8.open sql8,conn,1,1
								sort1name=rs8("sort1")
								sort2=rs8("sort2")
								rs8.close
								set rs8=nothing
								if sort2="" or isnull(sort2) then sort2=0
								set rs8=server.CreateObject("adodb.recordset")
								sql8="select sort1  from sortonehy where ord="&sort2&""
								rs8.open sql8,conn,1,1
								sort2name=rs8("sort1")
								rs8.close
								set rs8=nothing
							end if
							if open_6_1=3 or CheckPurview(intro_6_1,rs7("cateid"))=True then
								if open_6_14=3 or CheckPurview(intro_6_14,rs7("cateid"))=True then
									Response.write "" & vbcrlf & "<a href=""javascript:void(0);"" onclick=""javascript:window.open('../pay/paydetail.asp?ord="
									Response.write (payord)
									Response.write "','viewpay','width=' + 900 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" title="""
									Response.write (payord)
									Response.write intropay
									Response.write """>"
								end if
								Response.write "<font color=""#5B7CAE"">"
								Response.write sort2name
								Response.write "→"
								Response.write sort1name
								Response.write "&nbsp;"
								Response.write pay
								Response.write "</font></a>" & vbcrlf & " <br>"
							end if
							i7=i7+1
'Response.write "</font></a>" & vbcrlf & " <br>"
							rs7.movenext
						loop
						rs7.close
						set rs7=nothing
					end if
					Response.write "" & vbcrlf & " </td>" & vbcrlf & " "
				end if
				Response.write "" & vbcrlf & "  </tr>" & vbcrlf & " "
				n1=n1+1
'Response.write "" & vbcrlf & "  </tr>" & vbcrlf & " "
				rs1.movenext
				if rs1.eof then exit do
			loop
		else
			Response.write "" & vbcrlf & "  <td "
			if now<=dateadd("h",num_del,td)+1 then
				'Response.write "" & vbcrlf & "  <td "
				Response.write "  onClick=""javascript:window.open('../plan/addhome.asp?date1="
				Response.write td
				Response.write "&time1=12','_blank','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;""  style=""cursor:hand""  title=""点击添加日程""  "
				'Response.write td
			else
				Response.write "onClick=""confirm('"
				Response.write num_del
				Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
			end if
			Response.write "></td>" & vbcrlf & "  <td align=""center"" "
			if now<=dateadd("h",num_del,td)+1 then
				'Response.write "></td>" & vbcrlf & "  <td align=""center"" "
				Response.write "  onClick=""if(confirm('只有添加了日程后，才可以添加其对应的其它栏目内容，现在添加日程？')){window.open('../plan/addhome.asp?date1="
				Response.write td
				Response.write "&time1=08','_blank','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;}"""
				'Response.write td
			else
				Response.write " onClick=""confirm('"
				Response.write num_del
				Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
			end if
			Response.write "></td>" & vbcrlf & ""
			if ZBRuntime.MC(3000) then
				Response.write "" & vbcrlf & " <td align=""center"" "
				if now<=dateadd("h",num_del,td)+1 then
					'Response.write "" & vbcrlf & " <td align=""center"" "
					Response.write "  onClick=""if(confirm('只有添加了日程后，才可以添加其对应的其它栏目内容，现在添加日程？')){window.open('../plan/addhome.asp?date1="
					Response.write td
					Response.write "&time1=08','_blank','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;}"""
					'Response.write td
				else
					Response.write " onClick=""confirm('"
					Response.write num_del
					Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
				end if
				Response.write "></td>" & vbcrlf & ""
			end if
			Response.write "" & vbcrlf & "<td align=""center"" "
			if now<=dateadd("h",num_del,td)+1 then
				'Response.write "" & vbcrlf & "<td align=""center"" "
				Response.write "  onClick=""if(confirm('只有添加了日程后，才可以添加其对应的其它栏目内容，现在添加日程？')){window.open('../plan/addhome.asp?date1="
				Response.write td
				Response.write "&time1=08','_blank','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;}"""
				'Response.write td
			else
				Response.write " onClick=""confirm('"
				Response.write num_del
				Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
			end if
			Response.write "></td>" & vbcrlf & ""
			if ZBRuntime.MC(3000) then
				Response.write "" & vbcrlf & "  <td align=""center"" "
				if now<=dateadd("h",num_del,td)+1 then
					'Response.write "" & vbcrlf & "  <td align=""center"" "
					Response.write "  onClick=""if(confirm('只有添加了日程后，才可以添加其对应的其它栏目内容，现在添加日程？')){window.open('../plan/addhome.asp?date1="
					Response.write td
					Response.write "&time1=08','_blank','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;}"""
					'Response.write td
				else
					Response.write " onClick=""confirm('"
					Response.write num_del
					Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
				end if
				Response.write "></td>" & vbcrlf & ""
			end if
			Response.write "" & vbcrlf & "<td align=""center"" "
			if now<=dateadd("h",num_del,td)+1 then
				'Response.write "" & vbcrlf & "<td align=""center"" "
				Response.write "  onClick=""if(confirm('只有添加了日程后，才可以添加其对应的其它栏目内容，现在添加日程？')){window.open('../plan/addhome.asp?date1="
				Response.write td
				Response.write "&time1=08','_blank','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;}"""
				'Response.write td
			else
				Response.write " onClick=""confirm('"
				Response.write num_del
				Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
			end if
			Response.write "></td>" & vbcrlf & ""
			if ZBRuntime.MC(27000) then
				Response.write "" & vbcrlf & "   <td align=""center"" "
				if now<=dateadd("h",num_del,td)+1 then
					'Response.write "" & vbcrlf & "   <td align=""center"" "
					Response.write "  onClick=""if(confirm('只有添加了日程后，才可以添加其对应的其它栏目内容，现在添加日程？')){window.open('../plan/addhome.asp?date1="
					Response.write td
					Response.write "&time1=08','_blank','width=' + 900 + ',height=' + 600 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100');return false;}"""
					'Response.write td
				else
					Response.write " onClick=""confirm('"
					Response.write num_del
					Response.write "小时后不能再对前一天及以前的日程进行任何修改！')"""
				end if
				Response.write "></td>" & vbcrlf & ""
			end if
			Response.write "" & vbcrlf & "  </tr>" & vbcrlf & "   "
		end if
		if tflag=1 then exit for
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select ord,intro,date7,addcatename from plan2  where  date1='"&td&"' and type=11 and cateid="&cateid&" "
		rs1.open sql1,conn,1,1
		dim pord11,p11
		if rs1.eof then
			p11=""
			pord11=0
			date711=now
			addcatename = ""
		else
			pord11=rs1("ord")
			p11=rs1("intro")
			date711=rs1("date7")
			addcatename = rs1("addcatename")
		end if
		rs1.close
		set rs1=nothing
		Response.write "" & vbcrlf & "   <tr>" & vbcrlf & "<td align=""center"" colspan=""2""><b>当天总结</b></td>" & vbcrlf & "<td colspan=""7"" class=""ewebeditorImg"" "
		if now<=dateadd("h",num_del,td) and p11="" then
			Response.write "  onClick=""javascript:window.open('../plan/addhome2.asp?date1="
			Response.write td
			Response.write "&cateid="
			Response.write cateid
			Response.write "&H=11&time1=11','_blank','width=' + 800 + ',height=' + 500 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')"""
			'Response.write cateid
		elseif p11="" then
			Response.write " onClick=""confirm('"
			Response.write num_del
			Response.write "小时后不能再对前一天的总结进行填写！')"""
		end if
		Response.write "   style=""cursor:hand"" >" & vbcrlf & ""
		if p11<>"" and PowerV_71_1 then
			Response.write "<b>"
			Response.write p11
			Response.write "<span class=""addTime"">("
			Response.write addcatename
			Response.write "&nbsp;"
			Response.write date711
			Response.write ")</span>"
			if clng(cateid)=session("personzbintel2007") and now<=dateadd("h",num_del,td) And ((open_71_2=1 And CheckPurview(intro_71_2,cateid)=true) Or open_71_2=3) then
				Response.write "<a href=""javascript:void(0)"" onclick=""javascript:window.open('../plan/correcthome2.asp?id="
				Response.write pwurl(pord11)
				Response.write "&H=11','_blank','width=' + 800 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')"">【修改】</a>"
				'Response.write pwurl(pord11)
			end if
			Response.write "</b>" & vbcrlf & "  "
		end if
		Response.write "" & vbcrlf & "  </td>" & vbcrlf & "   </tr>" & vbcrlf & "   <tr>" & vbcrlf & "<td "
		If rowspan=0 Then
			Response.write " rowspan=""1"" colspan=""2"" "
		else
			Response.write "rowspan="""
			Response.write rowspan
			Response.write """ "
		end if
		Response.write " ><div align=""center"">领导评定</div></td>" & vbcrlf & ""
		set rs2=server.CreateObject("adodb.recordset")
		strSql="select charSpId,charName,intLevel,isnull(time1,0) as time1 from sp_schedule order by intLevel"
		rss.open strSql,conn
		do while not rss.eof
			flag=false
			time1=rss("time1")
			strSql2="select ord from power where sort1=71 and sort2=16 and ((qx_open=1 and ','+cast(qx_intro as varchar(max))+',' like '%,"&cateid&",%') or qx_open=3)"
			'time1=rss("time1")
			rs2.open strSql2,conn
			do while not rs2.eof
				if CheckPurview(rss("charSpId"),rs2("ord")) then
					flag=true
					exit do
				end if
				rs2.movenext
			loop
			rs2.close
			if flag and PowerV_71_1 then
				Response.write "" & vbcrlf & "  <td>"
				Response.write rss("charName")
				Response.write "</td>" & vbcrlf & " <td class=""ewebeditorImg"" colspan=""7"">" & vbcrlf & ""
				strSql2="select ord,intro,date7,cateid,addcatename,spid,spname from plan2  where date1='"&td&"'" & _
				" and type=17 and cateid="&cateid&" and spid in("&rss("charSpId")&") and lcb="&rss("intLevel")&" order by ord desc"
				rs2.open strSql2,conn
				if not rs2.eof then
					Response.write rs2("intro")
					Response.write " <font class=""red"">（"
					Response.write rs2("spname")&" "&rs2("date7")
					Response.write "）</font>" & vbcrlf & " "
					if int(rs2("spid"))=int(session("personzbintel2007")) and now()<=dateadd("h",time1,rs2("date7")) then
						Response.write "" & vbcrlf & "  <a href=""javascript:void(0)"" onClick=""javascript:window.open('../plan/correcthome2.asp?id="
						Response.write pwurl(rs2("ord"))
						Response.write "&H=17','_blank','width=' + 800 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')"">【修改】</a>" & vbcrlf & "   "
						'Response.write pwurl(rs2("ord"))
					end if
				else
					if CheckPurview(rss("charSpId"),session("personzbintel2007")) and ((open_71_16=1 and CheckPurview(intro_71_16,cateid)) or open_71_16=3) Then
						Response.write "" & vbcrlf & "  <a href=""javascript:;""onClick=""javascript:window.open('../plan/addhome2.asp?date1="
						Response.write td
						Response.write "&cateid="
						Response.write cateid
						Response.write "&spid="
						Response.write session("personzbintel2007")
						Response.write "&lcb="
						Response.write rss("intLevel")
						Response.write "&H=17&time1=11','_blank','width=' + 800 + ',height=' + 500 + ',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')"">【添加评定】</a>" & vbcrlf & ""
						'Response.write rss("intLevel")
					end if
				end if
				rs2.close
				Response.write "" & vbcrlf & " </td>" & vbcrlf & " </tr>" & vbcrlf & ""
			end if
			rss.movenext
		loop
		rss.close
		set rs2=nothing
		if rowspan=0 or not PowerV_71_1 then
			Response.write "" & vbcrlf & " <td colspan=""8""></td></tr>" & vbcrlf & ""
		end if
	next
	rs.close
	set rs=nothing
	action1="销售日报表"
	call close_list(1)
	Response.write "" & vbcrlf & "</table>" & vbcrlf & " </td>" & vbcrlf & " </tr>" & vbcrlf & "   <tr>" & vbcrlf & "  <td  class=""page"">" & vbcrlf & "   <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "  <tr>" & vbcrlf & "<td height=""60"" ><div align=""center""></di			v></td>" & vbcrlf & " </tr>" & vbcrlf & "   </table>" & vbcrlf & "</td>" & vbcrlf & "   </tr>" & vbcrlf & "   </table>" & vbcrlf & "   <input type=""hidden"" name=""hiddendate"" value="""
	Response.write tdate
	Response.write """>" & vbcrlf & "<input type=""hidden"" name=""hiddenflag"">" & vbcrlf & "</form>" & vbcrlf & "</td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & ""
	Response.write "" & vbcrlf & "</body>" & vbcrlf & "</html>"
	
%>
