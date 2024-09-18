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
	
	Response.write vbcrlf
	
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
	
	Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN""" & vbcrlf & """http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "    <meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "    <title>"
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "    <link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "    <link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/default/easyui.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """>" & vbcrlf & "    <script type=""text/javascript"" src=""../inc/jquery.easyui.min.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "    <style type=""text/css"">" & vbcrlf & "        <!--" & vbcrlf & "        body {" & vbcrlf & "            margin-top: 0px;" & vbcrlf & "            background-color: #FFFFFF;" & vbcrlf & "            margin-left: 0px;" & vbcrlf & "            margin-right: 0px;" & 		vbcrlf & "            margin-bottom: 0px;" & vbcrlf & "        }" & vbcrlf & "        -->" & vbcrlf & "    </style>" & vbcrlf & "</head>" & vbcrlf & "" & vbcrlf & "<body>" & vbcrlf & "    "
	'Response.write Application("sys.info.jsver")
	dim  ord,name,ord37
	ord=deurl( request("ord") & "")
	CurrBookID=deurl( request("id") & "")
	set rs=server.CreateObject("adodb.recordset")
	sql="select title from zdy where gl="&ord&" "
	rs.open sql,conn,1,1
	if rs.eof then
		zdy_zd=""
	else
		zdy_zd=rs("title")
	end if
	rs.close
	sql="select numv from erp_sys_temp_attr where [key]='是否开启票据类型'"
	rs.open sql,conn,1,1
	if rs.eof then
		ord37 = "0"
	else
		ord37 = Cstr(rs("numv"))
	end if
	rs.close
	set rs=nothing
	if ord=11 then
		name="客户行业"
	elseif ord=12 then
		name="过滤关键词"
	elseif ord=13 then
		name="客户来源"
	elseif ord=14 then
		name="客户价值"
	elseif ord=15 then
		name="威胁级别"
	elseif ord=16 then
		name="企业性质"
	elseif ord=17 then
		name="供应商分类"
	elseif ord=18 then
		name="供应商级别"
	elseif ord=19 then
		name="信用等级"
	elseif ord=21 then
		name="项目状态"
	elseif ord=23 then
		name="项目来源"
	elseif ord=24 then
		name="项目分类"
	ElseIf ord="25" Then
		name="预购分类"
	elseif ord=31 then
		name="合同分类"
	elseif ord=32 then
		name="合同状态"
	elseif ord=33 then
		name="支付方式"
	elseif ord=34 then
		name="票据类型"
	elseif ord=35 then
		name="退货分类"
	elseif ord=36 then
		name="退货状态"
	elseif ord=37 then
		name="票据来源"
	elseif ord=41 then
		name="费用分类"
	elseif ord=45 then
		name="接待方式"
	elseif ord=46 then
		name="紧急程度"
	elseif ord=47 then
		name="接件类型"
	elseif ord=48 then
		name="节点类型"
	elseif ord=51 then
		name="售后分类"
	elseif ord=52 then
		name="紧急程度"
	elseif ord=53 then
		name="处理结果"
	elseif ord=54 then
		name="处理时间"
	elseif ord=55 then
		name="售后方式"
	elseif ord=56 then
		name="回访方式"
	elseif ord=57 then
		name="回访状态"
	elseif ord=58 then
		name="关怀方式"
	elseif ord=59 then
		name="关怀类型"
	elseif ord=61 then
		name="产品单位"
	elseif ord=63 then
		name="产品自定义分组"
	elseif ord=71 then
		name="采购分类"
	elseif ord=75 then
		name="采购退货分类"
	elseif ord=76 then
		name="采购退货状态"
	elseif ord=78 then
		name="质检等级"
	elseif ord=79 then
		name="机密级别"
	elseif ord=81 then
		name="发货方式"
	elseif ord=82 then
		name="包装方式"
	elseif ord=83 then
		name="快递公司"
	elseif ord=85 then
		name="奖罚分类"
	elseif ord=91 then
		name="公告分类"
	elseif ord=92 then
		name="导航分类"
	elseif ord=93 then
		name="工作互动分类"
	elseif ord=94 then
		name="设备分类"
	elseif ord=95 or ord=96 then
		name="通讯录分类"
	ElseIf ord=97 Then
		name="工艺流程分类"
	ElseIf ord=98 Then
		name="跟进方式"
	ElseIf ord=99 Then
		name="工序分类"
	ElseIf ord=100 Then
		name="报废原因"
	elseif ord=8004 then
		name="知识库级别"
	elseif ord=9090 then
		name="质量等级"
	elseif ord=9091 then
		name="质检类型"
	ElseIf ord=1080 Then
		name="岗位名称"
	ElseIf ord = 10001 Then
		name = "费用报销分类"
	ElseIf ord = 80 Then
		name  = "商品分类"
	ElseIf ord=5029 Then
		name="设计分类"
	ElseIf ord=5030 Then
		name="设计等级"
	ElseIf ord=3001 Then
		name="质检方案"
	ElseIf ord=157 Then
		name="退料原因"
	ElseIf ord=158 Then
		name="废料原因"
	ElseIf ord=54001 Then
		name="不合格原因"
	ElseIf ord=54002 Then
		name="报废原因"
	ElseIf ord=54003 Then
		name="质检等级"
	ElseIf ord=54004 Then
		name="不合格原因"
	ElseIf ord=54005 Then
		name="质检等级"
	ElseIf ord=45001 Then
		name="直接入账分类"
	ElseIf ord=45002 Then
		name="直接出账分类"
	ElseIf ord=57000 Then
		name="质检项分组"
	ElseIf ord=57010 Then
		name="质检项单位"
	ElseIf ord=57005 Then
		name="不合格原因"
	ElseIf ord=57006 Then
		name="报废原因"
	ElseIf ord=57007 Then
		name="质检等级"
	ElseIf ord=13001 Then
		name="报价分类"
	elseif (ord>100 and ord<5000) Or (ord>800000 And ord<1000000) Or (ord>502900 And ord<502999)  then
		name=zdy_zd
	end if
	Dim strChecker
	strChecker = ""
	if ord=37 then
		strChecker = strChecker & "&&Mycheckdata(" & num_dot_xs & ")"
	end if
	if ord=19 then
		strChecker = strChecker & "&&checkNowMoney()"
	end if
	If ord=34 then
		strChecker = strChecker & "&&checkTaxRate()&&checkFormula()&&checkCustomFields()&&saveFields()"
	end if
	If ord=47 Or ord=3001 then
		strChecker = strChecker & "&&checkFrameForm()"
	end if
	If ord=46 Or ord=25 Then
		Response.write "" & vbcrlf & "    <script src=""../hrm/js/jQuery.ColorPicker.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """ type=""text/javascript"" language=""javascript""></script>" & vbcrlf & "    <script src=""../Script/s3_correct.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """ language=""javascript"" type=""text/javascript""></script>" & vbcrlf & "    "
	end if
	if ord=31 Or ord=71 then
		Response.write "" & vbcrlf & "        <script type=""text/javascript"" src=""../inc/comm.pym.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "    "
	end if
	Response.write "" & vbcrlf & "    <script src=""../Script/s3_correct_1.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ language=""javascript""></script>" & vbcrlf & "    <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"">" & vbcrlf & "        <tr>" & vbcrlf & "            <td width=""100%"" valign=""top"">" & vbcrlf & "                <form method=""post"" action=""Updatecp.asp?ord="
	Response.write ord
	Response.write "&id="
	Response.write CurrBookID
	Response.write """ id=""demo"" onsubmit=""return Validator.Validate(this,2)"
	Response.write strChecker
	Response.write """ name=""date"" target=""saveform"" style=""margin: 0"">" & vbcrlf & "                    <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" height=""42"" disDetailTable=""1"">" & vbcrlf & "                        <tr class=""top"">" & vbcrlf & "                           <td width=""5%"" height=""42"" background=""../images/contentbg.gif"">" & vbcrlf & "                                <div align=""center"" style=""width: 20px; height: 42px; margin-left: 15px;""></div>" & vbcrlf & "                            </td>" & vbcrlf & "                            <td width=		""60%"" style"
	Response.write name
	Response.write "</font></strong></td>" & vbcrlf & "                            <td width="" align=""right"" background=""../images/contentbg.gif"">" & vbcrlf & "                                <input type=""submit"" name=""Submit422"" value=""保存"" class=""page"" />" & vbcrlf & "                             		<input type=""reset"" value=""重填"" class=""page"" name=""B2"">&nbsp;" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                    </table>" & vbcrlf & "                    "
	conn.execute("update sortonehy set ord=id where id="&CurrBookID)
	set rs=server.CreateObject("adodb.recordset")
	If ord = 34 Then
		sql = "select a.*,b.id as configId,taxRate,adTax, maxAmount,maxCount,titleShowName,taxNoShowName,taxNoOpenFlag,taxNoMustIn,addrShowName,addrOpenFlag,addrMustIn,phoneShowName,phoneOpenFlag,phoneMustIn,bankShowName,bankOpenFlag,bankMustIn,accountShowName,accountOpenFlag,accountMustIn,priceFormula,pri		ceBeforeTaxFormula from sortonehy a inner join invoiceConfig b on a.id = b.typeid where gate2='"&ord&"' and a.id="& CurrBookID &" order by gate1 desc"
	else
		sql="select a.*,b.name,b.url from sortonehy a left join sortonehyfiles b on a.id = b.sortonehy Where a.id = "&CurrBookID&" "
	end if
	rs.open sql,conn,1,1
	If rs.eof Then
		Response.write"<script language=javascript>alert('此记录不存在！');history.back()</script>"
		Response.write"<script language=javascript>window.open('','_self');window.close();</script>"
		call db_close : Response.end
	end if
	id1=rs("id1")
	If ord=34 And id1=-65535 Then
		id1=rs("id1")
		isDefaultInvoiceType = true
	else
		isDefaultInvoiceType = false
	end if
	Dim maxWordNum
	maxWordNum = 20
	If ord = 80 Then maxWordNum = 4
	Response.write "" & vbcrlf & "                    <table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "                        <tr class=""top"">" & vbcrlf & "                            <td colspan=""2"">修改"
	Response.write name
	Response.write " </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td width=""40%"" height=""19"">" & vbcrlf & "                                <div align=""right"">"
	select case ord
	case 63 : Response.write "分组名称"
	case else: Response.write name
	end select
	Response.write "：</div>" & vbcrlf & "                            </td>" & vbcrlf & "                            <td width=""60%"">" & vbcrlf & "                                "
	If ord=83 Then
		Response.write rs("sort1")
	else
		Response.write "<input type=""text"" name=""sort1"" value="""
		Response.write rs("sort1")
		Response.write """ size=""30"" maxlength=""100"" "
		if ord=31 or ord=71 then
			Response.write "  oninput=""ff4(this.value,document.getElementById('shortName'));"" onKeyUp=""ff4(this.value,document.getElementById('shortName'));"""
		end if
		Response.write "   datatype=""Limit"" min=""1"" max="""
		Response.write maxWordNum
		Response.write """ msg=""长度必须在1个至"
		Response.write maxWordNum
		Response.write "个字之间"" "
		If isDefaultInvoiceType Then Response.write "readonly='readonly' style='background-color:lightgray'"
		Response.write "个字之间"" "
		Response.write ">" & vbcrlf & "                                <span class=""red"">*</span>"
	end if
	Response.write "" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        "
	If ord = 34 Then
		conn.execute("delete from ERP_CustomFields where TName=-255 and Creator="&session("personzbintel2007"))
'If ord = 34 Then
		taxRate = rs("taxRate")
		if taxRate&""="" then taxRate = 0
		taxRate = formatnumber(taxRate , num_dot_xs , -1,0,0)
'if taxRate&""="" then taxRate = 0
		maxAmount = rs("maxAmount")
		if maxAmount&""="" then maxAmount = 0
		maxAmount = formatnumber(maxAmount , num_dot_xs , -1,0,0)
'if maxAmount&""="" then maxAmount = 0
		Response.write "" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td width=""33%"">" & vbcrlf & "                                <div align=""right"">税率(%)：</div>" & vbcrlf & "                            </td>" & vbcrlf & "                            <td width=""67%"">" & vbcrlf & "                                <input name=""taxRate"" id=""taxRate"" type=""text"" value="""
		Response.write taxRate
		Response.write """ size=""15"" maxlength=""20"" style=""text-align: left"" datatype=""Limit"" min=""1"" max=""15"" msg=""必须是1—15位的数字"" onkeyup=""value=value.replace(/[^\d\.]/g,'');checkDot('taxRate','"
		Response.write taxRate
		Response.write num_dot_xs
		Response.write "')"">% <span class=""red"">*</span></td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td width=""33%"">" & vbcrlf & "                                <div align=""right"">价税分离：</div>" & vbcrlf & "                 		</td>" & vbcrlf & "                            <td width=""67%"">" & vbcrlf & "                                <input name=""adTax"" type=""radio"" value=""1"" "
		If rs("adTax").value=1 Then
			Response.write "checked"
		end if
		Response.write ">是 &nbsp;" & vbcrlf & "                                <input name=""adTax"" type=""radio"" value=""0"" "
		If rs("adTax").value=0 Then
			Response.write "checked"
		end if
		Response.write ">否 </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td width=""33%"">" & vbcrlf & "                                <div align=""right"">发票最大金额：</div>" & vbcrlf & "                            </td>" & vbcrlf & "		<td width=""67%"">" & vbcrlf & "                                <input name=""maxAmount"" id=""maxAmount"" type=""text"" value="""
		Response.write maxAmount
		Response.write """ size=""15"" maxlength="""
		Response.write 13+CInt(num_dot_xs)
		Response.write """ size=""15"" maxlength="""
		Response.write """ setuphacked=""1"" datatype=""Limit"" min=""1"" max="""
		Response.write 13+CInt(num_dot_xs)
		Response.write """ setuphacked=""1"" datatype=""Limit"" min=""1"" max="""
		Response.write """ msg=""必须是1—"
		Response.write 13+CInt(num_dot_xs)
		Response.write """ msg=""必须是1—"
		Response.write "位的数字"" style=""text-align: left"" onkeyup=""value=value.replace(/[^\d\.]/g,'');checkDot('maxAmount','"
		Response.write """ msg=""必须是1—"
		Response.write num_dot_xs
		Response.write "')"">" & vbcrlf & "                                <span class=""red"">*</span></td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td width=""33%"">" & vbcrlf & "                                <div align=""right""		>发票最大明细：</div>" & vbcrlf & "                            </td>" & vbcrlf & "                            <td width=""67%""> "& vbcrlf & "                                <input name=""maxCount"" id=""maxCount"" type=""text"" value="
		Response.write rs("maxCount")
		Response.write """ size=""15"" maxlength=""4"" setuphacked=""1"" datatype=""Limit"" min=""1"" max=""4"" msg=""必须是1—4位的数字"" style=""text-align: left"" onkeyup=""value=value.replace(/[^\d]/g,'');checkDot('maxCount','"
		Response.write rs("maxCount")
		Response.write num_dot_xs
		Response.write "')"">" & vbcrlf & "                                <span class=""red"">*</span></td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        "
	end if
	if ord=61 Or ord=25 Or ord=85 Or ord=157 Or ord=158 Or ord=54001 Or ord=54002   Or ord=54003 Or ord=54004 Or ord=54005 Or ord=57005 Or ord=57006 Or ord=57007 then
		Response.write "" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td height=""19"">" & vbcrlf & "                                <div align=""right"">启用状态：</div>" & vbcrlf & "                            </td>" & vbcrlf & "                            <td>" & vbcrlf & "       		<input type=""radio"" name=""isStop"" value=""0"" "
		if rs("isStop")=0 or isNull(rs("isStop")) then
			Response.write "checked=""checked"" "
		end if
		Response.write ">启用&nbsp;&nbsp;&nbsp;<input type=""radio"" name=""isStop"" value=""1"" "
		if rs("isStop")=1 then
			Response.write "checked=""checked"" "
		end if
		Response.write ">停用</td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        "
	end if
	If (ord = 37 and ord37 = "1") Then
		Response.write "" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td height=""19"">" & vbcrlf & "                                <div align=""right"">期初票据余额：</div>" & vbcrlf & "                            </td>" & vbcrlf & "                            <td>" & vbcrlf & "     		<input type=""text"" name=""NowMoney"" value="""
		Response.write rs("NowMoney")
		Response.write """ max='9999999999' datatype=""number"" size=""30"" maxlength=""20"" style=""text-align: left"" onkeypress=""return (/[\d.-]/.test(String.fromCharCode(event.keyCode)));"" onblur=""checkdata()"" onfocus=""selectText(this);"">" & vbcrlf & "                                <span class=""red"" id=""		moneytwo"">*</span></td> "& vbcrlf & "                        </tr>" & vbcrlf & "                      "
	end if
	If ord = 91 Then
		Response.write "" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td width=""33%"">" & vbcrlf & "                                <div align=""right"">分类图示：</div>" & vbcrlf & "                            </td>" & vbcrlf & "                            <td width=""67%"">" & vbcrlf & "                                <input name=""ClassPic_Show"" id=""ClassPic_Show"" type=""text"" value="""
		Response.write rs("name")
		Response.write """ style=""text-align: left"" readonly>" & vbcrlf & "                                <input name=""ClassPic_Main"" id=""ClassPic_Main"" type=""hidden"" value="""
		Response.write rs("name")
		Response.write rs("url")
		Response.write """ style=""text-align: left"">" & vbcrlf & "                                <input type=""button"" name=""openbn"" id=""openbn"" value=""上传"" class=""anybutton"" onclick=""$('#upPic').window('open');"" />" & vbcrlf & "                                <span>（注：参考尺寸为90*100的JPG/GIF/PNG/JPEG）图片</sp		an>" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        "
	end if
	If ord = 19 Then
		Response.write "" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td height=""19"">" & vbcrlf & "                                <div align=""right"">信用金额：</div>" & vbcrlf & "                            </td>" & vbcrlf & "                            <td>" & vbcrlf & "       		<input type=""text"" name=""NowMoney"" value="""
		Response.write rs("NowMoney")
		Response.write """ max='9999999999' datatype=""number"" size=""30"" maxlength=""20"" style=""text-align: left"" onkeypress=""return (/[\d.-]/.test(String.fromCharCode(event.keyCode)));"" onkeyup=""checkDot('NowMoney','"
		Response.write rs("NowMoney")
		Response.write num_dot_xs
		Response.write "')"" onblur=""checkDot('NowMoney','"
		Response.write num_dot_xs
		Response.write "')"">" & vbcrlf & "                                (RMB) <span class=""red"">*</span><span class=""red"" id=""moneytwo""></span></td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        "
	elseIf ord = 1080 Then
		NowMoney = rs("NowMoney")
		If NowMoney&""="" Then NowMoney = 0
		Response.write "" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td height=""19"">" & vbcrlf & "                                <div align=""right"">定额能力：</div>" & vbcrlf & "                            </td>" & vbcrlf & "                            <td>" & vbcrlf & "       		<input type=""text"" name=""NowMoney"" value="""
		Response.write NowMoney
		Response.write """ max='9999999999' datatype=""number"" size=""15"" maxlength=""20"" style=""text-align: left"" onpropertychange=""formatData(this,'float');"" onkeyup=""checkDot('NowMoney','"
		Response.write NowMoney
		Response.write 1
		Response.write "')"" onblur=""checkDot('NowMoney','"
		Response.write 1
		Response.write "')""><span class=""red"" id=""moneytwo""></span></td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        "
	end if
	If ord = 46 Or ord=25 Then
		color = rs("color")
		If color&""="" Then color="#2f496e"
		Response.write "" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td width=""33%"">" & vbcrlf & "                                <div align=""right"">代表颜色：</div>" & vbcrlf & "                            </td>" & vbcrlf & "                            <td width=""67%"">" & vbcrlf & "                                <input name=""color"" type=""text"" id=""color"" value="""
		Response.write color
		Response.write """ size=""10"" maxlength=""50"" style=""color: "
		Response.write color
		Response.write """ readonly datatype=""Limit"" min=""0"" max=""15"" msg=""必填"">" & vbcrlf & "                                <img src=""../hrm/img/color.jpg"" alt=""选择颜色"" id=""selectColor"" width=""16"" height=""16"">(默认为蓝黑色)</td>" & vbcrlf & "                        </tr>" & vbcrlf & "                      		"
	ElseIf ord = 47 Or ord=83 Or ord=3001  Then
		isStop = rs("isStop")
		Response.write "" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td width=""33%"">" & vbcrlf & "                                <div align=""right"">是否启用：</div>" & vbcrlf & "                            </td>" & vbcrlf & "                            <td width=""67%"">" & vbcrlf & "                                <input name=""isStop"" type=""radio"" id=""isStop0"" value=""0"" "
		If isStop&""="0" Or isStop&""="" Then Response.write "checked"
		Response.write ">启用&nbsp;&nbsp;<input name=""isStop"" type=""radio"" id=""isStop1"" value=""1"" "
		If isStop&""="1" Then Response.write "checked"
		Response.write ">停用</td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        "
	end if
	if ord=31 Or ord=71 then
		Response.write "" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td width=""33%"">" & vbcrlf & "                                <div align=""right"">简称：</div>" & vbcrlf & "                            </td>" & vbcrlf & "                            <td width=""67%"">" & vbcrlf & "                                <input name=""color"" type=""text"" id=""shortName""  size=""30"" maxlength=""100""  value="""
		Response.write rs("color")
		Response.write """ datatype=""Limit"" min=""0""  max=""20"" msg=""长度必须在0个至20个字之间"">" & vbcrlf & "                                <!--<span class=""red"">*</span>-->" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "    "
		Response.write rs("color")
	end if
	Response.write "" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td height=""25"">" & vbcrlf & "                                <div align=""right"">重要指数：</div>" & vbcrlf & "                            </td>" & vbcrlf & "                            <td height=""25"">" & vbcrlf & "                                <select name=""gate1"" size=""1"">" & vbcrlf & "                                    "
	for i=1 to 40
		Response.write "" & vbcrlf & "                                    <option "
		if i=rs("gate1") then
			Response.write "selected "
		end if
		Response.write ">"
		Response.write i
		Response.write "</option>" & vbcrlf & "                                    "
	next
	Response.write "" & vbcrlf & "                                </select>（指数越高排在越前面）" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        "
	If ord = 34 Then
		If isDefaultInvoiceType = False Then
			Response.write "" & vbcrlf & "                        <tr class=""top"">" & vbcrlf & "                            <td colspan=""2"">" & vbcrlf & "                                <div style=""float: right"">" & vbcrlf & "                                    <input type=""button"" class=""anybutton"" onclick=""addField();"" value=""添加字段"" "
			If isDefaultInvoiceType Then Response.write "style='display:none'"
			Response.write " />" & vbcrlf & "                                </div>" & vbcrlf & "                                <div style=""float: left"">发票设置</div>" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        <tr>" & vbcrlf & "          <td colspan=""2"">" & vbcrlf & "                                <table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "                                    <tr>" & vbcrlf & "                                        <td width=""14%"">" & vbcrlf & "                                            <div align=""right"">公司名称：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "                                        <td width=""20%"">" & vbcrlf & "                                            <input 		name=""titleShowName"" class=""fieldName"" id=""titleShowName"" type=""text"" value="""
			Response.write rs("titleShowName")
			Response.write """ size=""15"" maxlength=""20"" datatype=""Limit"" min=""1"" max=""20"" msg=""长度必须在1个至20个字之间"" style=""text-align: left"">" & vbcrlf & "                                            <span class=""red"">*</span></td>" & vbcrlf & "                                        <td width=""13%"">" & vbcrlf & "                                            <div align=""right"">是否启用：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "                                        <td width=""20%"">" & vbcrlf & "                                            <input type=""radio"" checked>启用" & vbcrlf & "                                                <span class=""red"">*</span></td>" & vbcrlf & "                                        <td width=""13%"">" & vbcrlf & "                                            <div align=""right"">是否必填：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "          <td width=""20%"">" & vbcrlf & "                                            <input type=""radio"" checked>是" & vbcrlf & "                                                <span class=""red"">*</span></td>" & vbcrlf & "                                    </tr>" & vbcrlf & "                                    <tr>"& vbcrlf & "                                        <td width=""14%"">" & vbcrlf & "                                            <div align=""right"">税号：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "                                        <td width=""20%"">" & vbcrlf		& "                                            <input name=""taxNoShowName"" class=""fieldName"" id=""taxNoShowName"" type=""text"" value="""
			Response.write rs("taxNoShowName")
			Response.write """ size=""15"" maxlength=""20"" datatype=""Limit"" min=""1"" max=""20"" msg=""长度必须在1个至20个字之间"" style=""text-align: left"">" & vbcrlf & "                                            <span class=""red"">*</span></td>" & vbcrlf & "                                        <td width=""13%"">" & vbcrlf & "                                            <div align=""right"">是否启用：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "                                        <td width=""20%"">" & vbcrlf & "                                            <input type=""radio"" name=""t	axNoOpenFlag"" value=""1"" "
			If rs("taxNoOpenFlag")=1 Then
				Response.write "checked"
			end if
			Response.write ">启用" & vbcrlf & "                                                <input type=""radio"" name=""taxNoOpenFlag"" value=""0"" "
			If rs("taxNoOpenFlag")=0 Then
				Response.write "checked"
			end if
			Response.write ">不启用" & vbcrlf & "                                              <span class=""red"">*</span></td>" & vbcrlf & "                                        <td width=""13%"">" & vbcrlf & "                                            <div align=""right"">是否必填：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "  		<td width=""20%"">" & vbcrlf & "                                            <input type=""radio"" name=""taxNoMustIn"" value=""1"" "
			If rs("taxNoMustIn")=1 Then
				Response.write "checked"
			end if
			Response.write ">是" & vbcrlf & "                                          <input type=""radio"" name=""taxNoMustIn"" value=""0"" "
			If rs("taxNoMustIn")=0 Then
				Response.write "checked"
			end if
			Response.write ">否" & vbcrlf & "                                          <span class=""red"">*</span></td>" & vbcrlf & "                                    </tr>" & vbcrlf & "                                    <tr>" & vbcrlf & "                                        <td width=""14%"">" & vbcrlf & "                                            <div align=""right"">公司地址：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "                                        <td width=""20%"">" & vbcrlf & "                                            <input name=""addrShowName"" class=""fieldName"" id=""addrShowName"" type=""text"" value="""
			Response.write rs("addrShowName")
			Response.write """ size=""15"" maxlength=""20"" datatype=""Limit"" min=""1"" max=""20"" msg=""长度必须在1个至20个字之间"" style=""text-align: left"">" & vbcrlf & "                                            <span class=""red"">*</span></td>" & vbcrlf & "                                        <td width=""13%"">" & vbcrlf & "                                            <div align=""right"">是否启用：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "                                        <td width=""20%"">" & vbcrlf & "                                            <input type=""radio"" name=""a	ddrOpenFlag"" value=""1"" "
			If rs("addrOpenFlag")=1 Then
				Response.write "checked"
			end if
			Response.write ">启用" & vbcrlf & "                                                <input type=""radio"" name=""addrOpenFlag"" value=""0"" "
			If rs("addrOpenFlag")=0 Then
				Response.write "checked"
			end if
			Response.write ">不启用" & vbcrlf & "                                              <span class=""red"">*</span></td>" & vbcrlf & "                                        <td width=""13%"">" & vbcrlf & "                                            <div align=""right"">是否必填：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "  		<td width=""20%"">" & vbcrlf & "                                            <input type=""radio"" name=""addrMustIn"" value=""1"" "
			If rs("addrMustIn")=1 Then
				Response.write "checked"
			end if
			Response.write ">是" & vbcrlf & "                                          <input type=""radio"" name=""addrMustIn"" value=""0"" "
			If rs("addrMustIn")=0 Then
				Response.write "checked"
			end if
			Response.write ">否" & vbcrlf & "                                          <span class=""red"">*</span></td>" & vbcrlf & "                                    </tr>" & vbcrlf & "                                    <tr>" & vbcrlf & "                                        <td width=""14%"">" & vbcrlf & "                                            <div align=""right"">公司电话：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "                                        <td width=""20%"">" & vbcrlf & "                                            <input name=""phoneShowName"" class=""fieldName"" id=""phoneShowName"" type=""text"" value="""
			Response.write rs("phoneShowName")
			Response.write """ size=""15"" maxlength=""20"" datatype=""Limit"" min=""1"" max=""20"" msg=""长度必须在1个至20个字之间"" style=""text-align: left"">" & vbcrlf & "                                            <span class=""red"">*</span></td>" & vbcrlf & "                                        <td width=""13%"">" & vbcrlf & "                                            <div align=""right"">是否启用：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "                                        <td width=""20%"">" & vbcrlf & "                                            <input type=""radio"" name=""p	honeOpenFlag"" value=""1"" "
			If rs("phoneOpenFlag")=1 Then
				Response.write "checked"
			end if
			Response.write ">启用" & vbcrlf & "                                                <input type=""radio"" name=""phoneOpenFlag"" value=""0"" "
			If rs("phoneOpenFlag")=0 Then
				Response.write "checked"
			end if
			Response.write ">不启用" & vbcrlf & "                                              <span class=""red"">*</span></td>" & vbcrlf & "                                        <td width=""13%"">" & vbcrlf & "                                            <div align=""right"">是否必填：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "  		<td width=""20%"">" & vbcrlf & "                                            <input type=""radio"" name=""phoneMustIn"" value=""1"" "
			If rs("phoneMustIn")=1 Then
				Response.write "checked"
			end if
			Response.write ">是" & vbcrlf & "                                          <input type=""radio"" name=""phoneMustIn"" value=""0"" "
			If rs("phoneMustIn")=0 Then
				Response.write "checked"
			end if
			Response.write ">否" & vbcrlf & "                                          <span class=""red"">*</span></td>" & vbcrlf & "                                    </tr>" & vbcrlf & "                                    <tr>" & vbcrlf & "                                        <td width=""14%"">" & vbcrlf & "                                            <div align=""right"">开户行：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "                                        <td width=""20%"">" & vbcrlf & "                                            <input name=""bankShowName"" class=""fieldName"" id=""bankShowName"" type=""text	"" value="
			Response.write rs("bankShowName")
			Response.write """ size=""15"" maxlength=""20"" datatype=""Limit"" min=""1"" max=""20"" msg=""长度必须在1个至20个字之间"" style=""text-align: left"">" & vbcrlf & "                                            <span class=""red"">*</span></td>" & vbcrlf & "                                        <td width=""13%"">" & vbcrlf & "                                            <div align=""right"">是否启用：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "                                        <td width=""20%"">" & vbcrlf & "                                            <input type=""radio"" name=""b		ankOpenFlag"" value=""1"" "
			If rs("bankOpenFlag")=1 Then
				Response.write "checked"
			end if
			Response.write ">启用" & vbcrlf & "                                          <input type=""radio"" name=""bankOpenFlag"" value=""0"" "
			If rs("bankOpenFlag")=0 Then
				Response.write "checked"
			end if
			Response.write ">不启用" & vbcrlf & "                                               <span class=""red"">*</span></td>" & vbcrlf & "                                        <td width=""13%"">" & vbcrlf & "                                            <div align=""right"">是否必填：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "  		<td width=""20%"">" & vbcrlf & "                                            <input type=""radio"" name=""bankMustIn"" value=""1"" "
			If rs("bankMustIn")=1 Then
				Response.write "checked"
			end if
			Response.write ">是" & vbcrlf & "                                           <input type=""radio"" name=""bankMustIn"" value=""0"" "
			If rs("bankMustIn")=0 Then
				Response.write "checked"
			end if
			Response.write ">否" & vbcrlf & "                                           <span class=""red"">*</span></td>" & vbcrlf & "                                    </tr>" & vbcrlf & "                                    <tr>" & vbcrlf & "                                        <td width=""14%"">" & vbcrlf & "                                            <div align=""right"">开户行账号：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "                                        <td width=""20%"">" & vbcrlf & "                                            <input name=""accountShowName"" class=""fieldName"" id=""accountShowName"" typ		e=""text"" value="""
			Response.write rs("accountShowName")
			Response.write """ size=""15"" maxlength=""20"" datatype=""Limit"" min=""1"" max=""20"" msg=""长度必须在1个至20个字之间"" style=""text-align: left"">" & vbcrlf & "                                            <span class=""red"">*</span></td>" & vbcrlf & "                                        <td width=""13%"">" & vbcrlf & "                                            <div align=""right"">是否启用：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "                                        <td width=""20%"">" & vbcrlf & "                                            <input type=""radio"" name=""a		ccountOpenFlag"" value=""1"" "
			If rs("accountOpenFlag")=1 Then
				Response.write "checked"
			end if
			Response.write ">启用" & vbcrlf & "                                         <input type=""radio"" name=""accountOpenFlag"" value=""0"" "
			If rs("accountOpenFlag")=0 Then
				Response.write "checked"
			end if
			Response.write ">不启用" & vbcrlf & "                                               <span class=""red"">*</span></td>" & vbcrlf & "                                        <td width=""13%"">" & vbcrlf & "                                            <div align=""right"">是否必填：</div>" & vbcrlf & "                                        </td>" & vbcrlf & "  		<td width=""20%"">" & vbcrlf & "                                            <input type=""radio"" name=""accountMustIn"" value=""1"" "
			If rs("accountMustIn")=1 Then
				Response.write "checked"
			end if
			Response.write ">是" & vbcrlf & "                                           <input type=""radio"" name=""accountMustIn"" value=""0"" "
			If rs("accountMustIn")=0 Then
				Response.write "checked"
			end if
			Response.write ">否" & vbcrlf & "                                           <span class=""red"">*</span></td>" & vbcrlf & "                                    </tr>" & vbcrlf & "                                </table>" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        "
		end if
		Response.write "" & vbcrlf & "                        <tr "
		If isDefaultInvoiceType Then Response.write "style='display:none'"
		Response.write ">" & vbcrlf & "                            <td colspan=""2"">" & vbcrlf & "                                <iframe width=""100%"" id=""customFieldsFrame"" frameborder=""0"" src=""../sort3/set_tzzd.asp?TName="
		Response.write (CLng(rs("id"))+100000)
		Response.write """ onload=""this.style.height=this.contentWindow.document.body.scrollHeight + 'px';""></iframe>" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        "
	ElseIf ord=47 Then
		Response.write "" & vbcrlf & "                        <tr class=""top"">" & vbcrlf & "                            <td colspan=""2"">" & vbcrlf & "                                <div style=""float: right"">" & vbcrlf & "                                    <input type=""button"" class=""anybutton"" onclick=""addField();"" value=""添加字段"" />" & vbcrlf & "                                </div>" & vbcrlf & "                                <div style=""float: left"">接件情况设置</div>" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        <tr>"		& vbcrlf & "                            <td colspan=""2"">" & vbcrlf & "                                <iframe width=""100%"" id=""customFieldsFrame"" frameborder=""0"" src=""../sort3/set_tzzd.asp?TName="
		Response.write (CLng(rs("id"))+200000)
		Response.write """ onload=""this.style.height=this.contentWindow.document.body.scrollHeight + 'px';""></iframe>" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        "
	ElseIf ord=3001 Then
		Response.write "" & vbcrlf & "                        <tr class=""top"">" & vbcrlf & "                            <td colspan=""2"">" & vbcrlf & "                                <div style=""float: right"">" & vbcrlf & "                                    <input type=""button"" class=""anybutton"" onclick=""addField();"" value=""添加字段"" />" & vbcrlf & "                                </div>" & vbcrlf & "                                <div style=""float: left"">质检项目设置</div>" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        <tr>"		& vbcrlf & "                            <td colspan=""2"">" & vbcrlf & "                                <iframe width=""100%"" id=""customFieldsFrame"" frameborder=""0"" src=""../sort3/set_tzzd.asp?Tsort="
		Response.write ord
		Response.write "&TName="
		Response.write (CLng(rs("id"))+200000)
		Response.write "&TName="
		Response.write """></iframe>" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                        "
	end if
	Response.write "" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td colspan=""2"">" & vbcrlf & "                                <div align=""center"">" & vbcrlf & "                                    <input type=""submit"" name=""Submit422"" value=""保存"" class=""page"" />" & vbcrlf & "                                    <input type=""reset"" value=""重填"" class=""page"" name=""B2"">" & vbcrlf & "                                </div>" & vbcrlf & "                            </td>" & vbcrlf & "                        </tr>" & vbcrlf & "                    </table>" & vbcrlf & "                </form>" & vbcrlf & "            </td>" & vbcrlf & "        </tr>" & vbcrlf & "        <tr>" & vbcrlf & "            <td class=""page"">" & vbcrlf & "                <table width=""100%"" border=""0"" align=""left"">" & vbcrlf & "                    <tr>" & vbcrlf & "        <td height=""80"">" & vbcrlf & "                            <div align=""center""></div>" & vbcrlf & "                        </td>" & vbcrlf & "                    </tr>" & vbcrlf & "                </table>" & vbcrlf & "            </td>" & vbcrlf & "        </tr>" & vbcrlf & "    		</table>" & vbcrlf & "    "
	rs.close
	set rs=nothing
	conn.close
	set conn=nothing
	Response.write "" & vbcrlf & "    <iframe name=""saveform"" id=""saveform"" style=""display: none; width: 0px; height: 0px""></iframe>" & vbcrlf & "    <!--上传图片控件-->" & vbcrlf & "    <IFRAME style=""display:none"" name=""I5"" id=""I5"" FRAMEBORDER=""0"" SCROLLING=""no"" marginwidth=""1"" marginheight=""1""></IFRAME>" & vbcrlf & "    <div id=""upPic"" class=""easyui-window"" title=""上传图示"" style=""width: 500px; height: 218px; padding: 5px; background: #fafafa; top: 60px; left: 100px;"" closed=""true"">" & vbcrlf & "        <div region=""center"" border=""false"" style=""padding: 5px; background: #fff; border: 0px solid #ccc; width: 450px"">" & vbcrlf & "            <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""contentimg"">" & vbcrlf & "                <form action=""saveimg.asp"" method=""post"" enctype=""multipart/form-data"" name=""updata"" id=""updata_img"" target=""I5"">" & vbcrlf & "                    <tr>" & vbcrlf & "                        <td width=""28%"" height=""45"" valign=""middle"">" & vbcrlf & "                            <div align=""right"">路径：</div>" & vbcrlf & "                        </td>" & vbcrlf & "                  <td width=""72%"" align=""left"" valign=""middle"">" & vbcrlf & "                            <div align=""left"">" & vbcrlf & "                                <input name=""imgurl"" class=""anybutton"" type=""file"" id=""imgurl"" style=""background-color: #FFFFFF;"">" & vbcrlf & "             <input name=""t"" id=""t"" type=""hidden"" value=""3"">" & vbcrlf & "                            </div>" & vbcrlf & "                        </td>" & vbcrlf & "                    </tr>" & vbcrlf & "                    <tr>" & vbcrlf & "                        <td colspan=""2"" align=""center"">友情提示：请将上传文件大小控制在20MB以内。<br />" & vbcrlf & "                            最佳尺寸：90*100(px)  &nbsp;格式要求：JPG/GIF/PNG/JPEG </td>" & vbcrlf & "                    </tr>" & vbcrlf & "                </form>" & vbcrlf & "            </table>" & vbcrlf & "        </div>" & vbcrlf & "        <br />" & vbcrlf & "        <div region=""south"" border=""false"" style=""text-align: center; height: 30px; line-height: 30px;"">" & vbcrlf & "            <a class=""easyui-linkbutton"" href=""###"" onclick=""document.getElementById('updata_img').submit()"">确认</a>" & vbcrlf & "            <a class=""ea		syui-linkbutton"" href=""###"" onclick=""$('#upPic').window('close');"">取消</a>" & vbcrlf & "        </div>" & vbcrlf & "    </div>" & vbcrlf & "    <!--上传图片控件-->" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	set conn=nothing
	
%>
