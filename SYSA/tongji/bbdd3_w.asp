﻿<%@ language=VBScript %>
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
	
	Response.write vbcrlf
	
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
	list="and 1=0"
	
	Response.write vbcrlf
	Const Btn_tz="<span class='page'>跳转</span>"
	Const Btn_First="<span class='page'>首页</span>"
	Const Btn_Prev ="<span class='page'>上一页</span>"
	Const Btn_Next ="<span class='page'>下一页</span>"
	Const Btn_Last ="<span class='page'>尾页</span>"
	Const XD_Align ="Center"
	Const XD_Width ="100%"
	Class fenye_cla
		Private XD_PageCount,XD_Conn,XD_Rs,XD_SQL,XD_PageSize,Str_errors
		Private int_curpage,str_URL,int_totalPage,int_totalRecord,XD_sURL
		Public Property Let PageSize(int_PageSize)
		If IsNumeric(Int_Pagesize) Then
			XD_PageSize=CLng(int_PageSize)
		else
			str_error=str_error & "PageSize的参数不正确"
			ShowError()
		end if
		End Property
		Public Property Get PageSize
		If XD_PageSize="" or (not(IsNumeric(XD_PageSize))) Then
			PageSize=10
		else
			PageSize=XD_PageSize
		end if
		End Property
		Public Property Get GetRs()
		Set XD_Rs=server.CreateObject("adodb.recordset")
		XD_Rs.PageSize=PageSize
		XD_Rs.Open XD_SQL,XD_Conn,1,1
		If not(XD_Rs.eof and XD_RS.BOF) Then
			If int_curpage>XD_RS.PageCount Then
				int_curpage=XD_RS.PageCount
			end if
			XD_Rs.AbsolutePage=int_curpage
		end if
		Set GetRs=XD_RS
		End Property
		Public Property Let GetConn(obj_Conn)
		Set XD_Conn=obj_Conn
		End Property
		Public Property Let GetSQL(str_sql)
		XD_SQL=str_sql
		End Property
		Private Sub Class_Initialize
			XD_PageSize=10
			If request("page")="" Then
				int_curpage=1
			ElseIf not(IsNumeric(request("page"))) Then
				int_curpage=1
			ElseIf CInt(Trim(request("page")))<1 Then
				int_curpage=1
			else
				Int_curpage=CInt(Trim(request("page")))
			end if
		end sub
		Public Sub ShowPage()
			Dim str_tmp
			XD_sURL = GetUrl()
			int_totalRecord=XD_RS.RecordCount
			If int_totalRecord<=0 Then
				str_error=str_error & "总记录数为零，请输入数据"
				Call ShowError()
			end if
			If int_totalRecord="" then
				int_TotalPage=1
			else
				int_TotalPage = int(int_TotalRecord / XD_PageSize) + Abs(int_TotalRecord Mod XD_PageSize > 0)
				int_TotalPage=1
			end if
			If Int_curpage>int_Totalpage Then
				int_curpage=int_TotalPage
			end if
			Response.write ""
			Response.write vbcrlf & ShowPageInfo
			Response.write vbcrlf & ShowFirstPrv
			Response.write vbcrlf & showNumBtn
			Response.write vbcrlf & ShowNextLast
			Response.write ""
		end sub
		Private Function ShowFirstPrv()
			Dim Str_tmp,int_prvpage
			If int_curpage=1 Then
				str_tmp=Btn_First&" "&Btn_Prev
			else
				int_prvpage=int_curpage-1
				str_tmp=Btn_First&" "&Btn_Prev
				str_tmp="<a href="""&XD_sURL & "1" & """>" & Btn_First&"</a> <a href=""" & XD_sURL & CStr(int_prvpage) & """>" & Btn_Prev&"</a>"
			end if
			ShowFirstPrv=str_tmp
		end function
		Private Function ShowNextLast()
			Dim str_tmp,int_Nextpage
			If Int_curpage>=int_totalpage Then
				str_tmp=Btn_Next & " " & Btn_Last
			else
				Int_NextPage=int_curpage+1
				str_tmp=Btn_Next & " " & Btn_Last
				str_tmp="<a href=""" & XD_sURL & CStr(int_nextpage) & """>" & Btn_Next&"</a> <a href="""& XD_sURL & CStr(int_totalpage) & """>" &  Btn_Last&"</a>"
			end if
			ShowNextLast=str_tmp
		end function
		Private Function showNumBtn()
			Dim i,str_tmp
			For i=1 to int_totalpage
			next
			showNumBtn=str_tmp
		end function
		Private Function ShowPageInfo()
			Dim str_tmp
			str_tmp="共"&int_totalrecord&"条 "&XD_PageSize&"/页 "&int_curpage&"/"&int_totalpage&"页"
			ShowPageInfo=str_tmp
		end function
		Private Function GetURL()
			Dim strurl,str_url,i,j,search_str,result_url
			dim zdystr
			search_str="page="
			zdystr="zmr=0421"
			strurl=Request.ServerVariables("URL")
			Strurl=split(strurl,"/")
			i=UBound(strurl,1)
			str_url=strurl(i)
			str_params=Trim(Request.ServerVariables("QUERY_STRING"))
			If str_params="" Then
				result_url=str_url & "?"&zdystr&"&page="
			else
				If InstrRev(str_params,search_str)=0 Then
					result_url=str_url & "?" & str_params &"&"&zdystr&"&page="
				else
					j=InstrRev(str_params,search_str)-2
					result_url=str_url & "?" & str_params &"&"&zdystr&"&page="
					If j=-1 Then
						result_url=str_url & "?" & str_params &"&"&zdystr&"&page="
						result_url=str_url & "?"&zdystr&"&page="
					else
						urls = str_url & "?"
						paras = split(str_params,"&")
						pageText=""
						for i=0 to ubound(paras)
							if instr(paras(i),"page=") then
								pageText="page="
							else
								urls = urls   & paras(i) & "&"
							end if
						next
						result_url = urls&pageText
					end if
				end if
			end if
			GetURL=result_url
		end function
		Private Sub Class_Terminate
			Set XD_RS=nothing
		end sub
		Private Sub ShowError()
			If str_Error <> "" Then
				Response.write("" & str_Error & "")
				call db_close : Response.end
			end if
		end sub
	End class
	
	Class Pubclass
		Function SetIdToName(FieldId,TabName,FieldName,QueryTj)
			dim OutValues : OutValues=""
			Set rs=server.CreateObject("adodb.recordset")
			sql="select "& trim(FieldName) &" from "& trim(TabName) &" "& trim(QueryTj) &""
			rs.open sql,conn,1,1
			if not rs.eof then
				OutValues=rs(FieldName).value
			end if
			SetIdToName=OutValues
		end function
		Function DateList(Datetype,DateNum,StartNum,EndNum)
			dim i : i=0
			dim outstr ': outstr=""
			if trim(StartNum)>0 and trim(EndNum)>0 then
				For i=StartNum to EndNum
					if DateNum=i then
						outstr=outstr & vbcrlf & "<option value='"& i &"' selected='selected'>" & i & "</option>"
					else
						outstr=outstr & vbcrlf & "<option value='"& i &"'>" & i & "</option>"
					end if
				next
			end if
			DateList=outstr
		end function
		Function Date_List(Datetype,DateNum,StartNum,EndNum)
			dim i : i=0
			dim outstr ': outstr=""
			if trim(StartNum)>0 and trim(EndNum)>0 then
				For i=StartNum to EndNum
					dim jd
					if DateNum=1 or DateNum=2 or DateNum=3 then
						jd=1
					elseif DateNum=4 or DateNum=5 or DateNum=6 then
						jd=2
					elseif DateNum=7 or DateNum=8 or DateNum=9 then
						jd=3
					else
						jd=4
					end if
					if i=jd then
						outstr=outstr & vbcrlf & "<option value='"& i &"' selected='selected'>第" & i & type_name & "季度</option>"
					else
						outstr=outstr & vbcrlf & "<option value='"& i &"'>第" & i & type_name &"季度</option>"
					end if
				next
			end if
			Date_List=outstr
		end function
	End Class
	
	Dim IsDisReportBar, RptHasVisible, PreRptProcIndex
	Sub DisReportBar()
		IsDisReportBar = True
		Response.write "" & vbcrlf & "<script language='javascript'>" & vbcrlf & " var obj_box = document.getElementById(""rpt_proc_bar"");" & vbcrlf & "    if(obj_box) {obj_box.style.display = ""none"";}" & vbcrlf & "</script>" & vbcrlf & "    "
	end sub
	Sub InitReportBar(ByVal labeltxt)
		IsDisReportBar = False
		RptHasVisible = False
		Response.write "" & vbcrlf & "       <div id='rpt_proc_bar' style='display:none;width:400px;position:absolute;left:30%;top:26%;z-index:10000'>" & vbcrlf & "       <TABLE class=sys_dbgtab8 cellSpacing=0 cellPadding=0  style='width:400px;' align='center'><TBODY>" & vbcrlf & "       <TR>" & vbcrlf & "    <TD style=""HEIGHT: 20px"" class=sys_dbtl></TD>" & vbcrlf & "   <TD class=sys_dbtc></TD>" & vbcrlf & "        <TD class=sys_dbtr></TD></TR>" & vbcrlf & "   <TR>" & vbcrlf & "    <TD class=sys_dbcl></TD>" & vbcrlf & "        <TD style='border:1px solid #bbb;background-color:white;padding:22px;color:#000;background-color:#fff' valign='top'>" & vbcrlf & "               正在加载“"
		Response.write labeltxt
		Response.write "”,<span id='rpt_proc_bar_st'>请稍后<input type='button' id='r_p_nv' style='display:inline;background-color:white;border:0px;font-size:12px;height:13px;padding:0px'></span>...</span>" & vbcrlf & "                <div style='margin-top:5px;margin-bottom:5px;border:1px solid #c0ccdd;height:12px;background-color:white'>" & vbcrlf & "                       <div id='rpt_proc_v' style='height:10px;background-color:#4475e6;width:0%;background-image:url(../images/bj_tiao2.gif);margin:1px'></div>" & vbcrlf & "               </div>" & vbcrlf & "  </TD>" & vbcrlf & "   <TD class=sys_dbcr></TD></TR>" & vbcrlf & "   <TR>" & vbcrlf & "    <TD class=sys_dbbl></TD>" & vbcrlf & " <TD class=sys_dbbc></TD>" & vbcrlf & "        <TD class=sys_dbbr></TD></TR></TBODY></TABLE></div>" & vbcrlf & "     "
		PreRptProcIndex = -1
	end sub
	Sub doProc(ByVal count , ByVal procv)
		Dim jd
		If IsDisReportBar = true Then  Exit Sub
		If count > 0 Then
			procv = CInt((procv*1.00 / count)*100)
			If procv > 100 Then procv = 100
		else
			procv = 0
		end if
		If procv <= PreRptProcIndex Then
			Exit sub
		end if
		PreRptProcIndex = procv
		Response.write "<script language='javascript'>document.getElementById('rpt_proc_v').style.width='" & procv & "%';document.getElementById('r_p_nv').value='(" & procv & "%)';"
		If RptHasVisible = False Then
			Response.write "document.getElementById('rpt_proc_bar').style.display = 'block';"
			RptHasVisible = true
		end if
		Response.write "</script>"
		Response.flush
	end sub
	Sub closeReportBar()
		If IsDisReportBar = true Then  Exit sub
		Response.write "" & vbcrlf & "      <script language='javascript'>" & vbcrlf & "  document.getElementById('rpt_proc_v').style.width='100%'" & vbcrlf & "        document.getElementById(""rpt_proc_bar_st"").innerText = ""加载完毕。""" & vbcrlf & " setTimeout( function () {" & vbcrlf & "               document.getElementById(""rpt_proc_bar"").style.display = ""none""" & vbcrlf & "        },50);" & vbcrlf & "  </script>" & vbcrlf & ""
		Response.flush
	end sub
	
	if request("hiddendate")="" then
		tdate=date()
		if request("jtdate")<>"" then
			tdate=request("jtdate")
		end if
	else
		if request("hiddenflag")="1" then
			tdate=DateAdd("m",-1,cdate(request("hiddendate")))
'if request("hiddenflag")="1" then
		elseif request("hiddenflag")="2" then
			tdate=DateAdd("m",1,cdate(request("hiddendate")))
		elseif request("hiddenflag")="3" then
			tdate=date()
			if request("jtdate")<>"" then
				tdate=request("jtdate")
			end if
		end if
	end if
	tdmonth=month(tdate)
	tdyear=year(tdate)
	tdyear2=year(tdate)-1
	tdyear=year(tdate)
	flag=0
	tdw=cdate(year(tdate)&"-"&month(tdate)&"-1")    ''
	flag=0
	tdmonth=month(tdate)    ''
	tdyear=year(tdate)
	tflag=0
	b=Weekday(tdw)
	td2=tdw-b+1
	b=Weekday(tdw)
	dim px
	if px="" then
		px_Result="order by numcg1m desc"
	elseif px="1" then
		px_Result="order by numcg1 desc"
	elseif px="2" then
		px_Result="order by numcg2 desc"
	elseif px="3" then
		px_Result="order by numcg3 desc"
	elseif px="4" then
		px_Result="order by numcg4 desc"
	elseif px="5" then
		px_Result="order by numcg5 desc"
	elseif px="6" then
		px_Result="order by numcg6 desc"
	elseif px="m1" then
		px_Result="order by numcg1m desc"
	elseif px="m2" then
		px_Result="order by numcg2m desc"
	elseif px="m3" then
		px_Result="order by numcg3m desc"
	elseif px="m4" then
		px_Result="order by numcg4m desc"
	elseif px="m5" then
		px_Result="order by numcg5m desc"
	elseif px="m6" then
		px_Result="order by numcg6m desc"
	end if
	dim C,x
	x=request("x")
	C=request("C")
	if C <> "" then
		gate_result=" and  g.name like '%"& C &"%'"
	end if
	Response.write "" & vbcrlf & "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">" & vbcrlf & "<html xmlns=""http://www.w3.org/1999/xhtml"">" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<title>"
	gate_result=" and  g.name like '%"& C &"%'"
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<script src= ""../Script/ti_bbdd3_w.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """  language=JavaScript1.2></SCRIPT>" & vbcrlf & "<SCRIPT>" & vbcrlf & "      function setDay(day,eltName) {" & vbcrlf & "       displayElement.value =displayYear+""-""+(displayMonth + 1)+ ""-"" +day;" & vbcrlf & "       hideElement(eltName);" & vbcrlf & "     document.location.href=""bbdd3_w.asp?px="
	Response.write px
	Response.write "&C="
	Response.write C
	Response.write "&x=1&jtdate=""+displayYear+""-""+(displayMonth + 1)+""""" & vbcrlf & "     }" & vbcrlf & "" & vbcrlf & "</SCRIPT>" & vbcrlf & "</head>" & vbcrlf & "<body oncontextmenu=self.event.returnValue=false >" & vbcrlf & ""
	Response.write C
	Call InitReportBar("人员业绩周对比")
	action1="人员业绩周对比"
	Response.write "" & vbcrlf & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & " <tr>" & vbcrlf & "          <td><table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "             <form action=""bbdd3_w.asp?px="
	Response.write px
	Response.write "&jtdate="
	Response.write tdate
	Response.write "&C="
	Response.write C
	Response.write """ method=""get""　id=""demo"" onsubmit=""return Validator.Validate(this,2)"" name=""date"" >" & vbcrlf & "                         <tr>" & vbcrlf & "                <td  class=""place2"">人员业绩周对比</td>" & vbcrlf & "                <td  width=""450"">" & vbcrlf & "                              <table width=""100%"" cellspacing=""2"">" & vbcrlf & "            <tr height=""25"">" & vbcrlf & "            <td align=""center""><a href=""#"" onClick=""date.hiddenflag.value=1;date.submit();""><img src=""../images/main_2.gif"" width=""8"" height=""8"" border=""0"" /> 前一月</a></td>" & vbcrlf & "              <td colspan=""3"" align=""center"">"
	Response.write tdyear
	Response.write "年"
	Response.write tdmonth
	Response.write "月份</td>" & vbcrlf & "              <td align=""center""><a href=""#"" onClick=""date.hiddenflag.value=2;date.submit();"">后一月 <img src=""../images/main_1.gif"" width=""8"" height=""8"" border=""0"" /></a></td>" & vbcrlf & "                     <td align=""center""><input type=""button"" class=""anybutton"" value=""选择月份"" align=""absMiddle""  border=""0""  id=""daysOfMonth1Pos"" name=""daysOfMonth1Pos""  onmouseup=""toggleDatePicker('daysOfMonth1','date.ret1')"" />" & vbcrlf & "             <DIV id=daysOfMonth1 style=""POSITION: absolute""></DIV>" & vbcrlf & "            <INPUT name=""ret1"" type=""hidden"" size=10 >" & vbcrlf & "              <span style=""margin-left:20px;"">" & vbcrlf & "                         <input type=""radio"" name=""lhbtype"" id=""lhbtype"" value=""bbdd3_m.asp"" onClick=""window.location.href=this.value"">每月" & vbcrlf & "                                <input type=""radio"" name=""lhbtype"" id=""lhbtype2"" value=""bbdd3.asp"" onClick=""window.location.href=this.value"">每年" & vbcrlf & "           </span>" & vbcrlf & "                 </td>" & vbcrlf & "            </tr>" & vbcrlf & "                 </table></td>" & vbcrlf & "                <td align=""right"">" & vbcrlf & "" & vbcrlf & "                         <div align=""right"">关键词：" & vbcrlf & "                         <input name=""C"" type=""text"" size=""10""  value="""
	Response.write C
	Response.write """/>" & vbcrlf & "                           <input type=""submit"" name=""Submit45"" value=""检索""  class=""anybutton2""/>"
	if session("dy1zbintel2007")="1" then
		Response.write "" & vbcrlf & "                           <input type=""button"" name=""Submit43"" value=""打印""  onClick=""window.print()""   class=""anybutton2""/> "
	end if
	Response.write "" & vbcrlf & "                   </div></td>" & vbcrlf & "                                <td  width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "              </tr>" & vbcrlf & "            </table></td>" & vbcrlf & "  </tr>" & vbcrlf & "             <input type=""hidden"" name=""hiddendate"" value="""
	Response.write tdate
	Response.write """>" & vbcrlf & "            <input type=""hidden"" name=""hiddenflag""  value=""3"">" & vbcrlf & "                        <input type=""hidden"" name=""jtdate"" value="""
	Response.write tdate
	Response.write """>" & vbcrlf & "                </form>" & vbcrlf & "<tr>" & vbcrlf & "    <td width=""100%"" valign=""top"">" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"" class=""detailTable"" style=""width:100%"">" & vbcrlf & "  <tr class=""top"">" & vbcrlf & "         <td height=""26"" ><div align=""center"">姓名</div></td>" & vbcrlf & "        <td colspan=""12"" ><div align=""center"">业绩对比</div></td>" & vbcrlf & "   </tr>" & vbcrlf & " <tr>" & vbcrlf & "      <td height=""26""  width=""130"" ></td>" & vbcrlf & "         "
	dim m,j
	m=0
	for j=1 to 6
		Response.write "" & vbcrlf & "       <td  colspan=""2""  align=""center"">第"
		Response.write j
		Response.write "周（"
		Response.write month(td2)
		Response.write "月"
		Response.write day(td2)
		Response.write "日-"
		Response.write day(td2)
		Response.write month(td2+6)
		Response.write day(td2)
		Response.write "月"
		Response.write day(td2+6)
		Response.write "月"
		Response.write "日）</td>" & vbcrlf & " "
		m=m+1
		Response.write "日）</td>" & vbcrlf & " "
		tdw=tdw+7
		Response.write "日）</td>" & vbcrlf & " "
		td2=td2+7
		Response.write "日）</td>" & vbcrlf & " "
		if month(td2)<>tdmonth then
			tflag=1
			exit for
		end if
	next
	Response.write "" & vbcrlf & "       </tr>" & vbcrlf & "    <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "            <td align=""center"">&nbsp;</td>" & vbcrlf & "                "
	Select Case m
	Case 4
	w = "10%"
	Case 5
	w = "8%"
	Case 6
	w = "7%"
	Case Else
	End Select
	for j=1 to m
		Response.write "" & vbcrlf & "         <td  width="""
		Response.write w
		Response.write """ align=""center""><a href=""bbdd3_w.asp?px="
		Response.write j
		Response.write "&jtdate="
		Response.write tdate
		Response.write "&C="
		Response.write C
		Response.write "&x=1""><u>数量</u></a></td>" & vbcrlf & "            <td  width="""
		Response.write w
		Response.write """ align=""center""><a href=""bbdd3_w.asp?px=m"
		Response.write j
		Response.write "&jtdate="
		Response.write tdate
		Response.write "&C="
		Response.write C
		Response.write "&x=1""><u>金额</u></a></td>" & vbcrlf & "                "
	next
	Response.write "" & vbcrlf & "     </tr>" & vbcrlf & "   "
	tdw=cdate(year(tdate)&"-"&month(tdate)&"-1")-Weekday(cdate(year(tdate)&"-"&month(tdate)&"-1"))+1'cdate(year(tdate)&"-"&month(tdate)&"-1")    ''
	'Response.write "" & vbcrlf & "     </tr>" & vbcrlf & "   "
	sql7=""
	zd1=""
	zd2=",0,0,0,0,0,0,0,0,0,0"
	zd3=",0 as numcg2,0 as numcg2m,0 as numcg3,0 as numcg3m,0 as numcg4,0 as numcg4m,0 as numcg5,0 as numcg5m,0 as numcg6,0 as numcg6m"
	for j=1 to 6
		If sql7<>"" Then
			sql7=sql7 &" union all  select cateid,"& zd1 &" count(ord),isnull(sum(money2),0) "& zd2 &" from contract WITH(NOLOCK) where  date3>='"&cdate(tdw)&"' and date3<'"&cdate(tdw+7)&"' and del=1 and isnull(status,-1) in (-1,1)  group by cateid"
'If sql7<>"" Then
		else
			sql7=" select cateid,count(ord) as numcg1,isnull(sum(money2),0) as numcg1m "& zd3 &" from contract WITH(NOLOCK) where date3>='"&cdate(tdw)&"' and date3<'"&cdate(tdw+7)&"' and del=1 and isnull(status,-1) in (-1,1)  group by cateid"
'If sql7<>"" Then
		end if
		tdw=tdw+7
'If sql7<>"" Then
		zd1=zd1&"0,0,"
		If j<6 Then zd2=Left(zd2,Len(zd2)-4)
		'zd1=zd1&"0,0,"
	next
	if intro_5_11&""="" then intro_5_11 = "0"
	sql1 = "select * from (select g.ord,g.name,isnull(sum(c.numcg1),0) as numcg1,isnull(sum(c.numcg1m),0) as numcg1m,isnull(sum(c.numcg2),0) as numcg2,isnull(sum(c.numcg2m),0) as numcg2m,isnull(sum(c.numcg3),0) as numcg3,isnull(sum(c.numcg3m),0) as numcg3m,isnull(sum(c.numcg4),0) as numcg4,isnull(sum(c.numcg4m),0) as numcg4m,isnull(sum(c.numcg5),0) as numcg5,isnull(sum(c.numcg5m),0) as numcg5m,isnull(sum(c.numcg6),0) as numcg6,isnull(sum(c.numcg6m),0) as numcg6m from gate g WITH(NOLOCK) left join (" & sql7 &") c on c.cateid=g.ord where g.del=1 and ("&open_5_11&"=3 or ("&open_5_11&"=1 and g.ord in("&intro_5_11&") and g.ord>0)) "&gate_result&" group by g.ord,g.name ) aa "& px_Result
	Set benye=new fenye_cla
	benye.getconn =Conn
	benye.getsql  =Sql1
	benye.pagesize=15
	set Rs1=benye.getrs()
	if rs1.RecordCount<=0 then
		Response.write "<tr><td  colspan='25'>没有信息或无查看权限!</td></tr>"
	else
		for i=1 to benye.pagesize
			If Not rs1.eof Then
				title=rs1("name")
				numcg1=zbcdbl(rs1("numcg1"))
				numcg1m=zbcdbl(rs1("numcg1m"))
				numcg2=zbcdbl(rs1("numcg2"))
				numcg2m=zbcdbl(rs1("numcg2m"))
				numcg3=zbcdbl(rs1("numcg3"))
				numcg3m=zbcdbl(rs1("numcg3m"))
				numcg4=zbcdbl(rs1("numcg4"))
				numcg4m=zbcdbl(rs1("numcg4m"))
				numcg5=zbcdbl(rs1("numcg5"))
				numcg5m=zbcdbl(rs1("numcg5m"))
				numcg6=zbcdbl(rs1("numcg6"))
				numcg6m=zbcdbl(rs1("numcg6m"))
				sumcg1=sumcg1+numcg1
				numcg6m=zbcdbl(rs1("numcg6m"))
				sumcg2=sumcg2+numcg2
				numcg6m=zbcdbl(rs1("numcg6m"))
				sumcg3=sumcg3+numcg3
				numcg6m=zbcdbl(rs1("numcg6m"))
				sumcg4=sumcg4+numcg4
				numcg6m=zbcdbl(rs1("numcg6m"))
				sumcg5=sumcg5+numcg5
				numcg6m=zbcdbl(rs1("numcg6m"))
				sumcg6=sumcg6+numcg6
				numcg6m=zbcdbl(rs1("numcg6m"))
				sumcg1m=sumcg1m+numcg1m
				numcg6m=zbcdbl(rs1("numcg6m"))
				sumcg2m=sumcg2m+numcg2m
				numcg6m=zbcdbl(rs1("numcg6m"))
				sumcg3m=sumcg3m+numcg3m
				numcg6m=zbcdbl(rs1("numcg6m"))
				sumcg4m=sumcg4m+numcg4m
				numcg6m=zbcdbl(rs1("numcg6m"))
				sumcg5m=sumcg5m+numcg5m
				numcg6m=zbcdbl(rs1("numcg6m"))
				sumcg6m=sumcg6m+numcg6m
				numcg6m=zbcdbl(rs1("numcg6m"))
				Response.write "" & vbcrlf & "                     <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td align=""center"">"
				Response.write title
				Response.write "</td>" & vbcrlf & "                        <td align=""center"" class=""red"">"
				Response.write Formatnumber(numcg1,num1_dot,-1)
				Response.write "</td>" & vbcrlf & "                        <td align=""center"" class=""red"">"
				Response.write "</td>" & vbcrlf & "                        <td align=""right"">"
				Response.write Formatnumber(numcg1m,num_dot_xs,-1)
				Response.write "</td>" & vbcrlf & "                        <td align=""right"">"
				Response.write "</td>" & vbcrlf & "                        <td align=""center"" class=""red"">"
				Response.write Formatnumber(numcg2,num1_dot,-1)
				Response.write "</td>" & vbcrlf & "                        <td align=""center"" class=""red"">"
				Response.write "</td>" & vbcrlf & "                        <td align=""right"">"
				Response.write Formatnumber(numcg2m,num_dot_xs,-1)
				Response.write "</td>" & vbcrlf & "                        <td align=""right"">"
				Response.write "</td>" & vbcrlf & "                        <td align=""center"" class=""red"">"
				Response.write Formatnumber(numcg3,num1_dot,-1)
				Response.write "</td>" & vbcrlf & "                        <td align=""center"" class=""red"">"
				Response.write "</td>" & vbcrlf & "                        <td align=""right"">"
				Response.write Formatnumber(numcg3m,num_dot_xs,-1)
				Response.write "</td>" & vbcrlf & "                        <td align=""right"">"
				Response.write "</td>" & vbcrlf & "                        <td align=""center"" class=""red"">"
				Response.write Formatnumber(numcg4,num1_dot,-1)
				Response.write "</td>" & vbcrlf & "                        <td align=""center"" class=""red"">"
				Response.write "</td>" & vbcrlf & "                        <td align=""right"">"
				Response.write Formatnumber(numcg4m,num_dot_xs,-1)
				Response.write "</td>" & vbcrlf & "                        <td align=""right"">"
				Response.write "</td>" & vbcrlf & "                        "
				if m>=5 then
					Response.write "" & vbcrlf & "                     <td align=""center"" class=""red"">"
					Response.write Formatnumber(numcg5,num1_dot,-1)
					Response.write "" & vbcrlf & "                     <td align=""center"" class=""red"">"
					Response.write "</td>" & vbcrlf & "                        <td align=""right"">"
					Response.write Formatnumber(numcg5m,num_dot_xs,-1)
					Response.write "</td>" & vbcrlf & "                        <td align=""right"">"
					Response.write "</td>" & vbcrlf & "                        "
				end if
				if m=6 then
					Response.write "" & vbcrlf & "                     <td align=""center"" class=""red"">"
					Response.write Formatnumber(numcg6,num1_dot,-1)
					Response.write "" & vbcrlf & "                     <td align=""center"" class=""red"">"
					Response.write "</td>" & vbcrlf & "                        <td align=""right"">"
					Response.write Formatnumber(numcg6m,num_dot_xs,-1)
					Response.write "</td>" & vbcrlf & "                        <td align=""right"">"
					Response.write "</td>" & vbcrlf & "                        "
				end if
				Response.write "" & vbcrlf & "                     </tr>" & vbcrlf & "                   "
				Call doProc(benye.pagesize, i)
				Rs1.movenext
			else
				exit for
			end if
		next
		Response.write "" & vbcrlf & "             <tr>" & vbcrlf & "          <td ><div align=""center"">合计</div></td>" & vbcrlf & "          <td  align=""center"" class=""red"">"
		Response.write Formatnumber(sumcg1,num1_dot,-1)
		Response.write "</td>" & vbcrlf & "          <td  align=""right"">"
		Response.write Formatnumber(sumcg1m,num_dot_xs,-1)
		Response.write "</td>" & vbcrlf & "          <td  align=""right"">"
		Response.write "</td>" & vbcrlf & "          <td  align=""center"" class=""red"">"
		Response.write Formatnumber(sumcg2,num1_dot,-1)
		Response.write "</td>" & vbcrlf & "          <td  align=""center"" class=""red"">"
		Response.write "</td>" & vbcrlf & "          <td  align=""right"">"
		Response.write Formatnumber(sumcg2m,num_dot_xs,-1)
		Response.write "</td>" & vbcrlf & "          <td  align=""right"">"
		Response.write "</td>" & vbcrlf & "          <td  align=""center"" class=""red"">"
		Response.write Formatnumber(sumcg3,num1_dot,-1)
		Response.write "</td>" & vbcrlf & "          <td  align=""center"" class=""red"">"
		Response.write "</td>" & vbcrlf & "          <td  align=""right""><span class=""name"">"
		Response.write Formatnumber(sumcg3m,num_dot_xs,-1)
		Response.write "</td>" & vbcrlf & "          <td  align=""right""><span class=""name"">"
		Response.write "</span></td>" & vbcrlf & "          <td  align=""center"" class=""red"">"
		Response.write Formatnumber(sumcg4,num1_dot,-1)
		Response.write "</span></td>" & vbcrlf & "          <td  align=""center"" class=""red"">"
		Response.write "</td>" & vbcrlf & "          <td  align=""right"">"
		Response.write Formatnumber(sumcg4m,num_dot_xs,-1)
		Response.write "</td>" & vbcrlf & "          <td  align=""right"">"
		Response.write "</td>" & vbcrlf & "                  "
		if m>=5 then
			Response.write "" & vbcrlf & "          <td  align=""center"" class=""red"">"
			Response.write Formatnumber(sumcg5,num1_dot,-1)
			Response.write "" & vbcrlf & "          <td  align=""center"" class=""red"">"
			Response.write "</td>" & vbcrlf & "          <td  align=""right"">"
			Response.write Formatnumber(sumcg5m,num_dot_xs,-1)
			Response.write "</td>" & vbcrlf & "          <td  align=""right"">"
			Response.write "</td>" & vbcrlf & "                  "
		end if
		if m=6 then
			Response.write "" & vbcrlf & "             <td  align=""center"" class=""red"">"
			Response.write Formatnumber(sumcg6,num1_dot,-1)
			Response.write "" & vbcrlf & "             <td  align=""center"" class=""red"">"
			Response.write "</td>" & vbcrlf & "          <td  align=""right"">"
			Response.write Formatnumber(sumcg6m,num_dot_xs,-1)
			Response.write "</td>" & vbcrlf & "          <td  align=""right"">"
			Response.write "</td>" & vbcrlf & "                "
		end if
		Response.write "" & vbcrlf & "        </tr>" & vbcrlf & "                </table>" & vbcrlf & "                  </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   <tr>" & vbcrlf & "                    <td  class=""page"">" & vbcrlf & "                       <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "                  <tr>" & vbcrlf & "                  <td width=""10%"" height=""30""></td>" & vbcrlf & "                      <td ></td>" & vbcrlf & "                      <td width=""79%""><div align=""right"">"
		Response.write benye.showpage()
		Response.write "</div></td>" & vbcrlf & "            </tr>" & vbcrlf & "         "
	end if
	rs1.close
	set rs1=nothing
	Response.write "" & vbcrlf & "" & vbcrlf & "  <script src= ""../Script/ti_bbdd3_w_1.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """  language=javascript></script>" & vbcrlf & "  <tr>" & vbcrlf & "    <td height=""38"" colspan=""11""><div align=""right""><p>&nbsp;" & vbcrlf & "      </p>" & vbcrlf & "    </div></td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & "</form>" & vbcrlf & "      </td>" & vbcrlf & "  </tr>" & vbcrlf & "</table>" & vbcrlf & ""
	call close_list(1)
	Call closeReportBar()
	Response.write "" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	
%>