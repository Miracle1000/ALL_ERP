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
		Response.write "" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "        var getIEVer = function () {" & vbcrlf & "            var browser = navigator.appName;" & vbcrlf & "                if(window.ActiveXObject && top.document.compatMode==""BackCompat"") {return 5;}" & vbcrlf & "             var b_version = navigator.appVersion;" & vbcrlf & "             var version = b_version.split("";"");" & vbcrlf & "               if(document.documentMode && isNaN(document.documentMode)==false) { return document.documentMode; }" & vbcrlf & "              if (window.ActiveXObject) {" & vbcrlf & "                     var v = version[1].replace(/[ ]/g, """");" & vbcrlf & "                   if (v == ""MSIE10.0"") 			{return 10;}" & vbcrlf & "                        if (v == ""MSIE9.0"") {return 9;}" & vbcrlf & "                   if (v == ""MSIE8.0"") {return 8;}" & vbcrlf & "                   if (v == ""MSIE7.0"") {return 7;}" & vbcrlf & "                   if (v == ""MSIE6.0"") {return 6;}" & vbcrlf & "                   if (v == ""MSIE5.0"") {return 5;" & vbcrlf & "                    } else {return 11}" & 			vbcrlf & "         }" & vbcrlf & "               else {" & vbcrlf & "                  return 100;" & vbcrlf & "             }" & vbcrlf & "       };" & vbcrlf & "      try{ document.getElementsByTagName(""html"")[0].className = ""IE"" + getIEVer() ; } catch(exa){}" & vbcrlf & "        window.uizoom = "
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
			'GetPowerIntro = r
		end if
		rs.close
		set rs = nothing
	end function
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=1 and sort2=12"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_1_12=0
		intro_1_12=0
	else
		open_1_12=rs1("qx_open")
		intro_1_12=rs1("qx_intro")
	end if
	rs1.close
	set rs1=nothing
	dim W1,W2,W3,A1,A2,B,C,E,F,H
	W1=request("W1")
	W2=request("W2")
	W3=request("W3")
	A1=request("A1")
	A2=request("A2")
	A3=request("A3")
	B=request("B")
	C=Request.QueryString("C")
	D=request("D")
	E=request("E")
	F=request("F")
	H=request("H")
	m1=request("ret")
	m2=request("ret2")
	if W3<>"" then
		if Str_Result="" then
			str_Result="where  cateid ="&W3&""
		else
			Str_Result=Str_Result+"and  cateid ="&W3&""
			str_Result="where  cateid ="&W3&""
		end if
	elseif W2<>"" then
		if Str_Result="" then
			str_Result="where  cateid3 ="&W2&""
		else
			Str_Result=Str_Result+"and  cateid3 ="&W2&""
			str_Result="where  cateid3 ="&W2&""
		end if
	elseif W1<>"" then
		if Str_Result="" then
			str_Result="where  cateid2 ="&W1&""
		else
			Str_Result=Str_Result+"and  cateid2 ="&W1&""
			str_Result="where  cateid2 ="&W1&""
		end if
	end if
	function menu(id1)
		set rsarea=server.CreateObject("adodb.recordset")
		sqlarea="select id from menuarea where id1="&id1&" "
		rsarea.open sqlarea,conn,1,1
		if rsarea.eof=False then
			do until rsarea.eof
				gateord22=rsarea("id")
				If Len(area_list) = 0 Then
					area_list = "" & gateord22 & ""
				ElseIf InStr( area_list, gateord22 ) <= 0 Then
					area_list = area_list & ", " & gateord22 & ""
				end if
				menu(rsarea("id"))
				rsarea.movenext
			loop
		end if
		rsarea.close
		set rsarea=nothing
	end function
	if A2<>"" then
		area_list="0"
		menu(A2)
		if area_list="0" Then area_list=A2
	end if
	if  A2<>"" then
		if Str_Result="" then
			Str_Result="where area in ("&area_list&")"
		else
			Str_Result=Str_Result+"and  area in ("&area_list&")"
			Str_Result="where area in ("&area_list&")"
		end if
	end if
	if A1<>"" then
		if Str_Result="" then
			str_Result="where  zt1="&A1&""
		else
			Str_Result=Str_Result+"and  zt1="&A1&""
			str_Result="where  zt1="&A1&""
		end if
	end if
	if A3<>"" then
		if Str_Result="" then
			str_Result="where  zt2="&A3&""
		else
			Str_Result=Str_Result+"and  zt2="&A3&""
			str_Result="where  zt2="&A3&""
		end if
	end if
	if D<>"" then
		if Str_Result="" then
			str_Result="where  trade="&D&""
		else
			Str_Result=Str_Result+"and  trade="&D&""
			str_Result="where  trade="&D&""
		end if
	end if
	if E<>"" then
		if Str_Result="" then
			str_Result="where  complete1="&E&""
		else
			Str_Result=Str_Result+"and  complete1="&E&""
			str_Result="where  complete1="&E&""
		end if
	end if
	if F<>"" then
		if Str_Result="" then
			str_Result="where  sort='"&F&"'"
		else
			Str_Result=Str_Result+"and  sort='"&F&"'"
			str_Result="where  sort='"&F&"'"
		end if
	end if
	if B = "htzt" then
		if Str_Result="" then
			str_Result="where  title like '%"& C &"%'"
		else
			Str_Result=Str_Result+"and  title like '%"& C &"%'"
			str_Result="where  title like '%"& C &"%'"
		end if
	elseif B = "htid" then
		if Str_Result="" then
			str_Result="where  htid like '%"& C &"%'"
		else
			Str_Result=Str_Result+"and htid like '%"& C &"%'"
			str_Result="where  htid like '%"& C &"%'"
		end if
	elseif B = "htgy" then
		if Str_Result="" then
			str_Result="where  intro like '%"& C &"%'"
		else
			Str_Result=Str_Result+"and  intro like '%"& C &"%'"
			str_Result="where  intro like '%"& C &"%'"
		end if
	end if
	if m1<>"" then
		if Str_Result="" then
			Str_Result="where date3>='"&m1&"' "
		else
			Str_Result=Str_Result+"and date3>='"&m1&"' "
			Str_Result="where date3>='"&m1&"' "
		end if
	end if
	if m2<>"" then
		if Str_Result="" then
			Str_Result="where date3<='"&m2&"' "
		else
			Str_Result=Str_Result+"and date3<='"&m2&"' "
			Str_Result="where date3<='"&m2&"' "
		end if
	end if
	currpage=Request("currpage")
	if currpage<="0" or currpage="" Then currpage=1
	currpage=clng(currpage)
	if request("page_count")="" then
		page_count=10
	else
		page_count=cint(request("page_count"))
	end if
	px=request.QueryString("px")
	if px="" Then px=1
	if px=1 then
		px_Result="order by date7 desc"
	elseif px=2 then
		px_Result="order by date7 asc"
	elseif px=3 then
		px_Result="order by title desc"
	elseif px=4 then
		px_Result="order by title asc"
	elseif px=5 then
		px_Result="order by htid desc"
	elseif px=6 then
		px_Result="order by htid asc"
	elseif px=7 then
		px_Result="order by date3 desc"
	elseif px=8 then
		px_Result="order by date3 asc"
	elseif px=9 then
		px_Result="order by date2 desc"
	elseif px=10 then
		px_Result="order by date2 asc"
	end if
	dim sort, isnew, useragent, ischange
	sort=request("sort")
	isnew = request("isnew")
	If isnew&""="" Then isnew = "0"
	useragent=Request.ServerVariables("HTTP_USER_AGENT")
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
	'useragent=Request.ServerVariables("HTTP_USER_AGENT")
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body {" & vbcrlf & "    margin-top: 0px;" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & ".top_btns input.anybutton{margin-bottom:-2px;}" & vbcrlf & "</style>" & vbcrlf & "" & vbcrlf & "</head>" & vbcrlf & "<body oncontextmenu=self.event.returnValue=false>" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "<tr>" & vbcrlf & "    <td width=""100%"" valign=""top"">" & vbcrlf & "        <table width=""100%"" border=""0"" cellpadding=""0"" cellspacin		g=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "          <tr>" & vbcrlf & "            <td class=""place"">"
	if sort=41001 then  Response.redirect "planall_out.asp?" & replace(request.QueryString,"41001","44009")
	Select Case sort
	Case 1 : Response.write "合同"
	Case 11001 : Response.write "合同"
	Case 2 : Response.write "报价"
	Case 3 : Response.write "采购"
	Case 68001 : Response.write "发货"
	Case 4 : Response.write "发货"
	Case 5 : Response.write "售后"
	Case 6 : Response.write "入库"
	Case 61 : Response.write "入库条码(简)"
	Case 62 : Response.write "入库条码(详)"
	Case 7 : Response.write "信封"
	Case 8 : Response.write "采购退货"
	Case 16 : Response.write "开票计划"
	Case 17 : sort=43003 : Response.write "回款"
	Case 19 : Response.write "费用使用"
	Case 20 : Response.write "费用返还"
	Case 21 : Response.write "费用报销"
	Case 22 : Response.write "费用借款"
	Case 23 : Response.write "费用申请"
	Case 26 : Response.write "固定资产卡片"
	Case 28 : Response.write "质检"
	Case 9 : Response.write "项目"
	Case 62001 : Response.write "出库"
	Case 11 : Response.write "二维码"
	Case 41 : Response.write "退货"
	Case 45 : Response.write "受理单"
	Case 101: Response.write "车辆申请"
	Case 102: Response.write "询价"
	Case 126: Response.write "供应商"
	Case 2003: Response.write "产品"
	Case 150: Response.write "凭证"
	Case 61011: Response.write "产品编码"
	Case 72001 : Response.write "预购"
	Case 18001 : Response.write "售后服务"
	Case 41002 : Response.write "收票计划"
	Case 75 : Response.write "供应商对账"
	Case 74 : Response.write "客户对账"
	Case 76 : Response.write "总账"
	Case 77 : Response.write "明细账"
	Case 43011 : Response.write "实际收款"
	Case 43012 : Response.write "实际开票"
	Case 44009 : Response.write "付款计划"
	Case 44011 : Response.write "实际付款"
	Case 44012 : Response.write "实际收票"
	Case 43003 : Response.write "收款计划"
	End Select
	Response.write "打印模板</td><td>&nbsp;</td>" & vbcrlf & ""
	Dim addurl : addurl = ""
	Select Case sort
	Case 2,3, 4,68001,6, 62001,11 ,2003,150, 61011,102,1,16,17,19,20,21,43003,28,22,23,11001,72001,18001,44009,41002,75,74,76,77,43011,8,43012,44011,44012:
	If isnew="1" Then
		addurl = "../../SYSN/view/comm/TemplateSetting.ashx?Sort="& sort
	Elseif isnew="2" Then
		addurl = "../../SYSN/view/comm/TemplateSettingClient.ashx?sort="& sort
	Elseif sort=18001 then
		addurl = "correct_out2.asp?sort="&sort&"&main=1"
	else
		addurl = "moban_add.asp?sort="&sort&"&main=1"
	end if
	Case 5 :
	addurl = "moban_add.asp?sort="&sort&"&main=1"
	Case Else
	addurl = "moban_add.asp?sort="&sort&"&main=1"
	End Select
	Response.write "" & vbcrlf & "            <td align=""right"" class='top_btns'>" & vbcrlf & "                        "
	Select Case sort
	Case 2, 3, 4,68001,6, 62001, 11, 2003, 150, 102, 1, 16, 17,19,20,21, 43003, 28, 22,23, 11001, 72001, 18001, 44009, 41002,75, 74, 76, 77,43011,8,43012,44011,44012:
	listurl = ""
	Set rs = conn.execute("select oldurl from PrintTemplate_Type where ord="& sort)
	If rs.eof = False Then listurl = rs("oldurl")
	rs.close
	set rs = nothing
	If listurl&"" <> "" Then
		If instr(listurl,"?")>0 Then
			listurl = listurl &"&"
		else
			listurl = listurl &"?"
		end if
		If sort<>72001 Then
			if (sort=2003 or sort=62001 or sort=4 or sort=68001) then
				Response.write "" & vbcrlf & "                        <input type='radio' id='print3' onclick=""javascript: window.location.href = '"
				Response.write listurl
				Response.write "isnew=2&ischange=1';"" "
				If isnew="2" Then
					Response.write "checked"
				end if
				Response.write "><lable for='newprint'>打印 2020</lable>" & vbcrlf & "                        "
			end if
			if sort<>11 then
				Response.write "" & vbcrlf & "                                         &nbsp;<input type='radio' id='newprint' onclick=""javascript: window.location.href = '"
				Response.write listurl
				Response.write "isnew=1&ischange=1';"" "
				If isnew="1" Then
					Response.write "checked"
				end if
				Response.write "><lable for='newprint'>打印 2017</lable>" & vbcrlf & "                        "
			end if
		end if
		If sort<>2003 And sort<>150 and sort<>72001 and sort<>11 and sort<>75 and sort<>74 and sort<>76 and sort<>77 Then
			Response.write "" & vbcrlf & "                        &nbsp;<input type='radio' id='oldprint' onclick=""javascript: window.location.href = '"
			Response.write listurl
			Response.write "isnew=0&ischange=1';"" "
			If isnew="0" Then
				Response.write "checked"
			end if
			Response.write "><lable for='oldprint'>打印 2010</lable>" & vbcrlf & "                                     "
		end if
	end if
	End Select
	Response.write "" & vbcrlf & "                     &nbsp;" & vbcrlf & "                  "
	if isnew="2" then
		Response.write "" & vbcrlf & "                             <input name=""Submit45629"" type=""button"" onClick=""javascript: window.open('"
		Response.write addurl
		Response.write "'," & vbcrlf & "                                   'newprintset', 'width=' + 1400 + ',height=' + 768 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left='+(screen.availWidth-1400)/2+',top=0');"" class=""anybutton"" value=""添加模板"" />" & vbcrlf & "                      "
		'Response.write addurl
	else
		Response.write "" & vbcrlf & "                             <input name=""Submit45629"" type=""button"" onClick=""window.location.href='"
		Response.write addurl
		Response.write "'"" class=""anybutton"" value=""添加模板"" />" & vbcrlf & "                      "
	end if
	Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "            <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "          </tr>" & vbcrlf & "      </table> " & vbcrlf & "       <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & " <tr class=""top resetGroupTableBg"">" & vbcrlf & "        <td width=""49%"" height=""27"" align=""center""><div align=""center"">模板名称</div></td>" & vbcrlf & "      <td width=""26%"" ><div align=""center"">添加人员</div></td>" & vbcrlf & "    <td width=""25%"" ><div align=""center"" style=""white-space:nowrap;""> "& vbcrlf &"                         <select name=""select5"" onChange=""if(this.selectedIndex && this.selectedIndex!=0){gotourl(this.value);}"" style=""HEIGHT: 20px;font-size:12px;font-weight: bold;color:#2F496E;overflow:hidden""> "& vbcrlf &"                   <option>-请选择-</option> "& vbcrlf &"                                <option		value=""page_count=10"" "
	if page_count=10 then
		Response.write "selected"
	end if
	Response.write ">每页显示10条</option>" & vbcrlf & "                               <option value=""page_count=20"" "
	if page_count=20 then
		Response.write "selected"
	end if
	Response.write ">每页显示20条</option>" & vbcrlf & "                               <option value=""page_count=30"" "
	if page_count=30 then
		Response.write "selected"
	end if
	Response.write ">每页显示30条</option>" & vbcrlf & "                               <option value=""page_count=50"" "
	if page_count=50 then
		Response.write "selected"
	end if
	Response.write ">每页显示50条</option>" & vbcrlf & "                               <option value=""page_count=100"" "
	if page_count=100 then
		Response.write "selected"
	end if
	Response.write ">每页显示100条</option>" & vbcrlf & "                              <option value=""page_count=200"" "
	if page_count=200 then
		Response.write "selected"
	end if
	Response.write ">每页显示200条</option>" & vbcrlf & "                      </select>" & vbcrlf & "               </div>" & vbcrlf & "  </td>" & vbcrlf & "   </tr>" & vbcrlf & ""
	If isnew = "1" Then
		wheresql = " and isnull(PrintID,0)>0 "
		if sort="62001"  Then
			wheresql = " and isnull(PrintID,0)=62001 "
		end if
	elseif isnew = "2" then
		wheresql = " and isnull(PrintID,0)<0 "
		if sort="62001"  Then
			wheresql = " and isnull(PrintID,0)= -62001 "
'if sort="62001"  Then
		end if
	else
		wheresql = " and isnull(PrintID,0)=0 "
	end if
	set rs=server.CreateObject("adodb.recordset")
	sql="select * from contract_out  where sort="&sort&" and (main=2 or main=7 or main=3) "&  wheresql &" and del=1 order by main desc ,id desc"
	rs.open sql,conn,1,1
	if rs.RecordCount<=0 then
		Response.write "<table><tr><td>没有信息!</td></tr></table>"
	else
		n=0
		rs.pagesize=page_count
		pagecount=clng(rs.PageCount)
		if currpage>=PageCount Then currpage=PageCount
		rs.absolutePage = currpage
		set k=rs("title")
		set main=rs("main")
		set cateid=rs("cateid")
		do until rs.eof
			k2=""
			if main=7  Then k2="<font class='red'>（主模板）</font>"
			If rs("isSUNMI") = 1 Then k2 = k2&"<font class='red'>【适用蓝牙】</font>"
			catename=""
			if cateid<>"" Then
				sql7="select name from gate where ord="&cateid&""
				set rs7=conn.execute(sql7)
				if rs7.eof=False Then catename=rs7("name")
				rs7.close
				set rs7=nothing
			end if
			isstop= rs("isstop")
			If isstop&""="" Then isstop = 0
			If isstop = 0 Then
				stopText = "停用"
			else
				stopText = "启用"
			end if
			Response.write "" & vbcrlf & "             <tr onmouseout=""this.style.backgroundColor=''"" onmouseover=""this.style.backgroundColor='efefef'"">" & vbcrlf & "           <td align=""center""><div align=""left"">"
			Response.write ""&k & k2&""
			Response.write "</div></td> " & vbcrlf & "         <td class=""name"" ><div align=""center"">"
			Response.write ""&catename&""
			Response.write "</div></td>" & vbcrlf & "          <td class=""func""> " & vbcrlf & "                      <div align=""center"">" & vbcrlf & "                            "
			if session("personzbintel2007")=rs("cateid") or  session("top1zbintel2007")="1" Then
				Select Case sort
				Case 2,3, 4,68001,6 ,62001, 11 , 2003, 150, 102,1,16,17,19,20,21,43003,28,22,23,61011,11001,72001,44009,41002,75,74,76,77,43011,8,43012,44011,44012:
				If isnew="1" Then
					Response.write "<input name=""Submit45629"" type=""button"" onClick=""window.location.href='../../SYSN/view/comm/TemplateSetting.ashx?Sort="
					Response.write rs("sort")
					Response.write "&ord="
					Response.write rs("id")
					Response.write "&currpage="
					Response.write currpage
					Response.write "'""   class=""anybutton"" value=""详情"" /> " & vbcrlf & "                                                       "
				Elseif isnew="2" Then
					Response.write "<input name=""Submit45629"" type=""button"" onClick=""javascript: window.open('../../SYSN/view/comm/TemplateSettingClient.ashx?sort="
					Response.write rs("sort")
					Response.write "&ord="
					Response.write rs("id")
					Response.write "&currpage="
					Response.write currpage
					Response.write "'," & vbcrlf & "                                                            'newprintset', 'width=' + 1400 + ',height=' + 768 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left='+(screen.availWidth-1400)/2+',top=0');""  class=""anybutton"" value=""详情"" /> " & vbcrlf & "                                                       "
					Response.write currpage
				else
					Response.write "<input name=""Submit45629"" type=""button"" onClick=""window.location.href='moban_content.asp?id="
					Response.write rs("id")
					Response.write "&sort="
					Response.write rs("sort")
					Response.write "&main="
					Response.write rs("main")
					Response.write "&currpage="
					Response.write currpage
					Response.write "'""   class=""anybutton"" value=""详情"" />"
				end if
				If sort = 150 Then
					Response.write "<input name=""stopmoban"" type=""button"" onClick=""doSetUse("
					Response.write isstop
					Response.write ","
					Response.write rs("id")
					Response.write ")""   class=""anybutton"" value="""
					Response.write stopText
					Response.write """ />"
				end if
				Case 18001 :
				If isnew="1" Then
					Response.write "<input name=""Submit45629"" type=""button"" onClick=""window.location.href='../../SYSN/view/comm/TemplateSetting.ashx?Sort="
					Response.write rs("sort")
					Response.write "&ord="
					Response.write rs("id")
					Response.write "&currpage="
					Response.write currpage
					Response.write "'""   class=""anybutton"" value=""详情"" /> " & vbcrlf & "                                                       "
				Elseif isnew="2" Then
					Response.write "<input name=""Submit45629"" type=""button"" onClick=""javascript: window.open('../../SYSN/view/comm/TemplateSettingClient.ashx?sort="
					Response.write rs("sort")
					Response.write "&ord="
					Response.write rs("id")
					Response.write "&currpage="
					Response.write currpage
					Response.write "'," & vbcrlf & "                                                           'newprintset', 'width=' + 1400 + ',height=' + 768 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left='+(screen.availWidth-1400)/2+',top=0');""  class=""anybutton"" value=""详情"" /> " & vbcrlf & "                                                        "
					'Response.write currpage
				else
					Response.write "<input name=""Submit45629"" type=""button"" onClick=""window.location.href='content_out2.asp?id="
					Response.write rs("id")
					Response.write "&sort="
					Response.write rs("sort")
					Response.write "&main="
					Response.write rs("main")
					Response.write "&currpage="
					Response.write currpage
					Response.write "'""   class=""anybutton"" value=""详情"" /> " & vbcrlf & "                                               "
				end if
				Case Else
				Response.write "" & vbcrlf & "                                             <input name=""Submit45629"" type=""button"" onClick=""window.location.href='moban_content.asp?id="
				Response.write rs("id")
				Response.write "&sort="
				Response.write rs("sort")
				Response.write "&main="
				Response.write rs("main")
				Response.write "&currpage="
				Response.write currpage
				Response.write "'""   class=""anybutton"" value=""详情"" />" & vbcrlf & "                                                "
				end Select
				Response.write "" & vbcrlf & "                                     <input type=""button"" name=""Submitdel"" value=""删除"" onClick=""if(confirm('确认删除？')){window.location.href='Deleteout.asp?id="
				Response.write rs("id")
				Response.write "&sort="
				Response.write sort
				Response.write "&main="
				Response.write main
				Response.write "&isnew="
				Response.write isnew
				Response.write "'}""/>"
			end if
			Response.write "</div>" & vbcrlf & "             </td>" & vbcrlf & "             </tr>" & vbcrlf & "    "
			n=n+1
			Response.write "</div>" & vbcrlf & "             </td>" & vbcrlf & "             </tr>" & vbcrlf & "    "
			If n>=page_count Then Exit Do
			rs.movenext
		loop
		m=n
		Response.write "" & vbcrlf & "      </table>" & vbcrlf & "   </td>" & vbcrlf & "         </tr>" & vbcrlf & "   <tr>" & vbcrlf & "    <td  class=""page"">" & vbcrlf & "              <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "         <tr>" & vbcrlf & "            <td width=""10%"" height=""30""></td>" & vbcrlf & "           <td ></t		d>" & vbcrlf & "          <td width=""55%""><div align=""right"">" & vbcrlf & "         "
		Response.write rs.RecordCount
		Response.write "个 | "
		Response.write currpage
		Response.write "/"
		Response.write PageCount
		Response.write "页 | &nbsp;"
		Response.write page_count
		Response.write "条信息/页&nbsp;&nbsp;" & vbcrlf & "          <input id=""curp1"" name=""currpage""  type=text  onkeyup=""value=value.replace(/[^\d\.]/g,'')""  size=3  maxlength=8/>&nbsp;" & vbcrlf & "               <input type=""button"" name=""Submit422"" value=""跳转"" onClick=""gotourl('currPage='+document.getElementById('curp1').value);""  class=""anybutton2""/>" & vbcrlf & "         "
		if currpage=1 then
			Response.write "" & vbcrlf & "               <input type=""button"" name=""Submit4"" value=""首页""  class=""page""/> <input type=""button"" name=""Submit42"" value=""上一页""  class=""page""/>" & vbcrlf & "            "
		else
			Response.write "" & vbcrlf & "               <input type=""button"" name=""Submit4"" value=""首页""   class=""page"" onClick=""gotourl('currPage=1')""/> <input type=""button"" name=""Submit42"" value=""上一页""  onClick=""gotourl('currPage="
			Response.write  currpage -1
			Response.write "')"" class=""page""/>" & vbcrlf & "            "
		end if
		if Clng(currpage)=PageCount then
			Response.write "" & vbcrlf & "              <input type=""button"" name=""Submit43"" value=""下一页""  class=""page""/> <input type=""button"" name=""Submit44"" value=""尾页""  class=""page""/>" & vbcrlf & "           "
		else
			Response.write "" & vbcrlf & "              <input type=""button"" name=""Submit43"" value=""下一页""  onClick=""gotourl('currPage="
			Response.write  currpage + 1
			Response.write "')"" class=""page""/> <input type=""button"" name=""Submit43"" value=""尾页""  onClick=""gotourl('currPage="
			Response.write  PageCount
			Response.write "')"" class=""page""/>" & vbcrlf & "           "
		end if
		Response.write "" & vbcrlf & "              </div></td>" & vbcrlf & "             </tr>" & vbcrlf & "           <tr>" & vbcrlf & "            <td height=""38"" colspan=""3""><div align=""right""><p>&nbsp;" & vbcrlf & "              </p>" & vbcrlf & "            </div></td>" & vbcrlf & "             </tr>" & vbcrlf & "           </table>                 " & vbcrlf & ""
	end if
	rs.close
	set rs=nothing
	action1="模板列表"
	call close_list(1)
	Response.write "   " & vbcrlf & "      <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "              <tr> " & vbcrlf & "                <td height=""10"" colspan=""2""><img src=""../image/pixel.gif"" width=""1"" height=""1""></td>" & vbcrlf & "              </tr> " & vbcrlf & "                         <tr>" & vbcrlf & "                      <td width=""16%"" height=""10""><div align=""right""></div></td>" & vbcrlf & "                    <td width=""84%"">&nbsp;</td>" & vbcrlf & "       </tr>" & vbcrlf & "                         <tr>" & vbcrlf & "                      <td height=""10"" colspan=""2"">&nbsp;</td>" & vbcrlf & "     </tr>" & vbcrlf& "                          <tr>" & vbcrlf & "                      <td height=""10"" colspan=""2"">&nbsp;</td>" & vbcrlf & "     </tr>" & vbcrlf & "      </table>" & vbcrlf & " </td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "<script language=javascript>" & vbcrlf & "        function test(){" & vbcrlf & "          if(!confirm('确认删除吗？')) return false;" & vbcrlf & "  }" & vbcrlf & "        " & vbcrlf & "       function mm(){" & vbcrlf & "          var a = document.getElementsByTagName(""input"");" & vbcrlf & "           if(a[0].checked==true){" & vbcrlf & "                 for (var i=0; i<a.length; i++){" & vbcrlf & "                         if (a[i].type == ""checkbox""){ a[i].checked = false;}" & vbcrlf & "                  }" & vbcrlf & "               }" & vbcrlf & "               else{" & vbcrlf & "                   for (var i=0; i<a.length; i++){" & vbcrlf & "                         if (a[i].type == ""checkbox""){ a[i].checked = true;}" & vbcrlf & "                       }" & vbcrlf & "               }" & vbcrlf & "       }" & vbcrlf & "" & vbcrlf & "       function doSetUse(s , id){" & vbcrlf & "              var text = '';" & vbcrlf & "               if(s == 0)" & vbcrlf & "                      text ='确定停用？';" & vbcrlf & "             else" & vbcrlf & "                    text='确定启用？';" & vbcrlf & "              if(confirm(text))" & vbcrlf & "               {" & vbcrlf & "                       $.get(""moban_set.asp"",{id:id,stype:s} ,function(e){" & vbcrlf & "                                               window.location.reload();" & vbcrlf & "		});" & vbcrlf & "             }" & vbcrlf & "       }" & vbcrlf & "" & vbcrlf & "</script>" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	
%>
