<%@ language=VBScript %>
<%
	Response.write "" & vbcrlf & "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">" & vbcrlf & ""
	dim estimation :estimation = request.querystring("estimation")
	Response.write "" & vbcrlf & "<html xmlns=""http://www.w3.org/1999/xhtml"">" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"" />" & vbcrlf & "<title>"
'dim estimation :estimation = request.querystring("estimation")
	Response.write title_xtjm
	Response.write "</title>" & vbcrlf & ""
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
	Class MXZDYClass
		public col_open()
		Public col_kd()
		public col_counter()
		public col_needSum()
		public col_sumValue()
		public col_DBName()
		public sellPriceControl
		public buyPriceControl
		Public Sub arrayInit(ByVal sortNum)
			Me.sellPriceControl = ",price1,money1,discount,priceAfterDiscount,priceAfterTaxPre,priceAfterTax,taxValue,moneyBeforeTax,moneyAfterTax,priceIncludeTax,concessions,moneyAfterConcessions,"
			Me.buyPriceControl = ",pricejy,tpricejy,"
			ReDim col_needSum(0)
			ReDim col_sumValue(1,0)
			sql = NewMxZDYSql(11001 , 1 , 0 , "")
			Set rs=conn.execute(sql)
			Dim i ,FieldName
			i=1
			While rs.eof = False
				ReDim Preserve col_counter(rs("inx"))
				FieldName = rs("FieldName")
				sql=" select 1 where (charindex(',"& FieldName &",','"&Me.sellPriceControl&"')=0 or (charindex(',"& FieldName &",','"&Me.sellPriceControl&"')>0 and "&open_5_21&"<>0)) "&_
				" and (charindex(',"& FieldName &",','"&Me.buyPriceControl&"')=0 or (charindex(',"& FieldName &",','"&Me.buyPriceControl&"')>0 and "&open_5_24&"<>0)) "
				if conn.execute(sql).eof=false then
					col_counter(rs("inx")) = -1
'if conn.execute(sql).eof=false then
					i=i+1
'if conn.execute(sql).eof=false then
				end if
				rs.movenext
			wend
			rs.close
			Set rs=conn.execute(NewMxZDYSql(11001 , 1 , 0,""))
			While rs.eof = False
				ReDim Preserve col_open(rs("inx"))
				ReDim Preserve col_kd(rs("inx"))
				redim Preserve col_DBName(rs("inx"))
				col_open(rs("inx")) = rs("IsUsed").value*1
				col_kd(rs("inx")) = rs("kd").value
				col_DBName(rs("inx")) =  rs("tName").value
				rs.movenext
			wend
			rs.close
		end sub
		Public Function getIndexOfOpenFieldByDBName(ByVal dbname)
			Dim idx,ii
			idx = 0
			For ii = 1 To ubound(col_open)
				if col_open(ii) = 1 then
					idx = idx + 1
'if col_open(ii) = 1 then
					if col_DBName(ii) = dbname  then exit for
				end if
			next
			getIndexOfOpenFieldByDBName = idx
		end function
		Public Sub addSumField(ByVal idx,ByVal fieldIdx, ByVal fieldValue,ByVal dot_num)
			col_counter(fieldIdx) = idx
			Dim foundIdx
			foundIdx = -1
'Dim foundIdx
			For ii = 0 To ubound(col_needSum)
				If col_needSum(ii)&"" = fieldIdx&"" Then
					foundIdx = ii
					Exit For
				end if
			next
			If foundIdx = -1 then
'Exit For
				ReDim Preserve col_needSum(ubound(col_needSum)+1)
'Exit For
				ReDim Preserve col_sumValue(1,ubound(col_sumValue,2)+1)
'Exit For
				col_needSum(ubound(col_needSum)) = fieldIdx
				col_sumValue(0,ubound(col_sumValue,2)) = fieldValue
				col_sumValue(1,ubound(col_sumValue,2)) = dot_num
			else
				col_needSum(foundIdx) = fieldIdx
				col_sumValue(0,foundIdx) = cdbl(col_sumValue(0,foundIdx)) + cdbl(fieldValue)
'col_needSum(foundIdx) = fieldIdx
			end if
		end sub
		Public Function isNeedSum()
			For ii = 1 To ubound(col_needSum)
				If col_counter(col_needSum(ii)) > 0 Then
					isNeedSum = True
					Exit function
				end if
			next
			isNeedSum = false
		end function
		Public Function getIndexOfFirstFieldNeedSum(ByVal colCnt)
			Dim idx
			idx = colCnt
			For ii = 1 To ubound(col_needSum)
				If col_counter(col_needSum(ii)) < idx And col_counter(col_needSum(ii)) >= 0 Then
					idx = col_counter(col_needSum(ii))
				end if
			next
			getIndexOfFirstFieldNeedSum = idx
		end function
		Public Function getSumFieldIdxBySorce(ByVal showIdx)
			Dim foundIdx
			foundIdx=-1
'Dim foundIdx
			For ii = 1 To ubound(col_needSum)
				If col_needSum(ii)&"" = showIdx&"" Then
					foundIdx = ii
					Exit For
				end if
			next
			getSumFieldIdxBySorce = foundIdx
		end function
		Public Function getSumFieldIdxByIndex(ByVal showIdx)
			Dim foundIdx
			foundIdx=-1
'Dim foundIdx
			For ii = 1 To ubound(col_needSum)
				If col_counter(col_needSum(ii)) = showIdx Then
					foundIdx = ii
					Exit For
				end if
			next
			getSumFieldIdxByIndex = foundIdx
		end function
		Public Function getSumValue(ByVal colIdx)
			getSumValue = Formatnumber(col_sumValue(0,colIdx),col_sumValue(1,colIdx),-1)
'Public Function getSumValue(ByVal colIdx)
		end function
		Public Function getFieldIsOpen(ByVal sorceNum)
			getFieldIsOpen = col_open(sorceNum)
		end function
		Public Function getFieldWidth(ByVal sorceNum)
			getFieldWidth = col_kd(sorceNum)
		end function
		Public Function getFieldSorceByIndex(ByVal fIdx)
			Dim foundIdx
			foundIdx=-1
'Dim foundIdx
			For ii = 1 To ubound(col_counter)
				If col_counter(ii) = fIdx Then
					foundIdx = ii
					Exit For
				end if
			next
			getFieldSorceByIndex = foundIdx
		end function
		Public Sub showBatchTr(htType)
			Dim rs, showBatTr, sql, zdySorce, strDisplay, rsInvoice, name
			showBatTr = False
			Set rs = conn.execute(NewMxZDYSql(11001 , 1 , 1 , " and (t.fieldname = 'invoiceType' or  t.fieldname ='date2') ") )
			If rs.eof = False Then
				showBatTr = True
			end if
			rs.close
			set rs = nothing
			If showBatTr Then
				Response.write "" & vbcrlf & "             <table width=""100%"" border=""0""  background=""../images/m_table_top.jpg"" cellspacing='0' cellpadding=""3"" style=""word-break:break-all;word-wrap:break-word;border-collapse:collapse;table-layout:fixed;border:#C0CCDD 1px solid;"">" & vbcrlf & "           <tr>" & vbcrlf & "           "
				if num20190823=1 AND (htType="JH" OR htType="") then
					Response.write "<td width=""70""></td>"
				end if
				Select Case htType
				Case "JH" : Response.write "<td width='30'>&nbsp;</td>"
				End Select
				set rs=server.CreateObject("adodb.recordset")
				sql=NewMxZDYSql(11001 , 1 , 0 ,  "")
				rs.open sql,conn,1,1
				do until rs.eof
					zdySorce = rs("fieldname")
					if rs("IsUsed")&""="1" And ((InStr(mxzdy.sellPriceControl,","&zdySorce&",")>0 and open_5_21<>0) or InStr(mxzdy.sellPriceControl,","&zdySorce&",")<=0) and ((InStr(mxzdy.buyPriceControl,","&zdySorce&",")>0 and open_5_24<>0) or  InStr(mxzdy.buyPriceControl,","&zdySorce&",")<=0) Then
						strDisplay = ""
					else
						strDisplay = "display:none;"
					end if
					Response.write "" & vbcrlf & "                     <td width="""
					Response.write rs("kd")
					Response.write """ height=""30"" align=""center"" class=""pltdcss"" style="""
					Response.write strDisplay
					Response.write """>" & vbcrlf & "                        "
					Select Case zdySorce&""
					case "num1":
					Response.write "" & vbcrlf & "                             <div align=""center"" style=""padding-left:"
'case "num1":
					Response.write Tcolspan/2
					Response.write "px"">" & vbcrlf & "                              <INPUT Name=""sorce"
					Response.write zdySorce
					Response.write """ id=""dayssorce"
					Response.write zdySorce
					Response.write "Pos"" size=9  maxlength=""20""  style=""height:19px; solid;font-size: 9pt;width:70px;""" & vbcrlf & "                        style=""width:50px;height: 19px; solid;font-size: 9pt;"" onfocus=""this.select();""" & vbcrlf & "                        onBlur=""if(!this.value){this.value=this.default Value;this.style.color='#000';};setall_num_price('num',this,'"
					Response.write num_dot_xs
					Response.write "');"" " & vbcrlf & "                        onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('dayssorce"
					Response.write zdySorce
					Response.write "Pos','"
					Response.write num1_dot
					Response.write "');setall_num_price('num',this,'"
					Response.write num_dot_xs
					Response.write "');""  " & vbcrlf & "                        type=""text"" ><DIV id='dayssorce"
					Response.write zdySorce
					Response.write "' style='POSITION: absolute'></DIV></DIV>" & vbcrlf & "                        "
					case "discount"
					if canChangePrice<>"0" then
						Response.write "" & vbcrlf & "                    <input type=""text"" name=""sorce"
						Response.write zdySorce
						Response.write """ id=""sorce"
						Response.write zdySorce
						Response.write """ style=""width:90%;text-align:right"" " & vbcrlf & "                               onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'}"" " & vbcrlf & "                               onBlur=if(!this.value){this.value=this.defaultValue;this.style.color='#000';setall_num_price('discount',this,'"
						Response.write zdySorce
						Response.write num_dot_xs
						Response.write "');)} " & vbcrlf & "                               onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('sorce"
						Response.write zdySorce
						Response.write "','"
						Response.write DISCOUNT_DOT_NUM
						Response.write "');setall_num_price('discount',this,'"
						Response.write num_dot_xs
						Response.write "');""" & vbcrlf & "                              msg=""折扣必须控制在0-"
						Response.write num_dot_xs
						Response.write FormatNumber(DISCOUNT_MAX_VALUE,DISCOUNT_DOT_NUM,-1,0,0)
						Response.write num_dot_xs
						Response.write "之间"" dataType=""Range"" min=""0"" max="""
						Response.write DISCOUNT_MAX_VALUE
						Response.write """" & vbcrlf & "                         />" & vbcrlf & "                    "
					end if
					Case "date2":
					Response.write "" & vbcrlf & "                             <div align=""center"" style=""padding-left:"
'Case "date2":
					Response.write Tcolspan/2
					Response.write "px"">" & vbcrlf & "                              <INPUT Name=""sorce"
					Response.write zdySorce
					Response.write """ id=""dayssorce"
					Response.write zdySorce
					Response.write "Pos"" size=9 style=""height:19px; solid;font-size: 9pt;width:70px;"" onmouseup=toggleDatePicker('dayssorce"
					Response.write zdySorce
					Response.write zdySorce
					Response.write "','date.sorce"
					Response.write zdySorce
					Response.write "')  dataType=""Date"" format=""ymd""  msg=""日期格式不正确"" onchange=setall_num_price('date',this,'"
					Response.write num_dot_xs
					Response.write "'); type=""text"" ><DIV id='dayssorce"
					Response.write zdySorce
					Response.write "' style='POSITION: absolute'></DIV></DIV>" & vbcrlf & "                    "
					Case "invoiceType"
					sql="select * from ("&_
					"select a.id,a.sort1,b.taxRate,b.priceFormula,b.priceBeforeTaxFormula,1 as topRow,a.gate1,a.id1 from sortonehy a inner join invoiceConfig b on a.id=b.typeid where gate2 = 34 and isStop=0 and isnull(id1,0)<>-65535 "&_
					"union all ("&_
					"select 0,'不开票',taxRate,priceFormula,priceBeforeTaxFormula,0 as topRow,-9999999,a.id1 from sortonehy a,invoiceConfig b where a.id=b.typeid and isnull(a.id1,0)=-65535"&_
					"union all ("&_
					")"&_
					") bb order by topRow,gate1 desc,isnull(id1,0) asc, id desc"
					Response.write "" & vbcrlf & "                             <div align=""center"" style=""padding-left:"
') bb order by topRow,gate1 desc,isnull(id1,0) asc, id desc
					Response.write Tcolspan/2
					Response.write "px"">" & vbcrlf & "                              <select name=""sorce"
					Response.write sorce
					Response.write """ style=""width:"
					Response.write rs("kd").value-5
					Response.write """ style=""width:"
					Response.write "px"" id=""sorce"
					Response.write sorce
					Response.write """ onchange=""setall_num_price('invoiceType',this,'"
					Response.write num_dot_xs
					Response.write "');"">" & vbcrlf & "                             "
					Set rsInvoice=conn.execute(sql)
					While rsInvoice.eof = false
						Response.write "" & vbcrlf & "                                     <option value="""
						Response.write rsInvoice(0)
						Response.write """>"
						Response.write rsInvoice(1)
						Response.write "</option>    " & vbcrlf & "                                        "
						rsInvoice.movenext
					wend
					rsInvoice.close
					Set rsInvoice = nothing
					Response.write "" & vbcrlf & "                             </select>" & vbcrlf & "                               </DIV>" & vbcrlf & "                  "
					Case Else
					Response.write "&nbsp;"
					End Select
					Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
					If isOpenMoreUnitAttr And zdySorce&"" = "unit" Then
						Response.write "<td width='110'>&nbsp;</td>"
					end if
					rs.movenext
				loop
				rs.close
				set rs=Nothing
				if jf="1" Then Response.write "<td width='70' >&nbsp;</td>"
				Response.write "" & vbcrlf & "             </tr>" & vbcrlf & "           </table>" & vbcrlf & "                "
			end if
		end sub
		Public Sub showHTMX
			Dim qxOpen,qxIntro
			sdk.setup.getpowerattr 21,14,qxOpen, qxIntro
			Dim zdyrs, num1, price1, money1
			set rs=server.CreateObject("adodb.recordset")
			sql=NewMxZDYSql(11001 , 1 , 1 , "")
			rs.open sql,conn,1,1
			do until rs.eof
				fcount=fcount+1
				sql=NewMxZDYSql(11001 , 1 , 1 , "")
				sorce=rs("FieldName")
				if sorce="title" then
					i=i+1
'if sorce="title" then
					Response.write "" & vbcrlf & "                 <td>" & vbcrlf & "                                 "
					If qxOpen > 0 Then
						Response.write "" & vbcrlf & "                              <a href=""javascript:void(0)"" onClick=""javascript:window.open('../product/content.asp?ord="
						Response.write pwurl(rss("ord"))
						Response.write "','newdfwin','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=150,top=150')"" title=""点击可查看此产品详情"">" & vbcrlf & "                               "
						Response.write pwurl(rss("ord"))
					end if
					Response.write title
					Response.write "</a></td>" & vbcrlf & ""
				elseif sorce="order1" Then
					i=i+1
'elseif sorce="order1" Then
					Response.write "" & vbcrlf & "                 <td>"
					Response.write order1
					Response.write "</td>" & vbcrlf & ""
				elseif sorce="type1" Then
					i=i+1
'elseif sorce="type1" Then
					Response.write "" & vbcrlf & "                 <td>"
					Response.write type1
					Response.write "</td>" & vbcrlf & ""
				elseif sorce="unit" Then
					i=i+1
'elseif sorce="unit" Then
					Response.write "" & vbcrlf & "                 <td align=""center"">"
					Response.write unitname
					Response.write "</td>" & vbcrlf & ""
					commUnitAttr = rss("commUnitAttr")
					If isOpenMoreUnitAttr Then
						Response.write "<td align=""center"">"
						Response.write LoadMoreUnit(0,commUnitAttr, 0 , 0,num1_dot)
						Response.write "</td>"
						i=i+1
						Response.write "</td>"
					end if
				elseif sorce="price1" and open_5_21<>0 then
					num_jgkz = num_jgkz + 1
'elseif sorce="price1" and open_5_21<>0 then
					i=i+1
'elseif sorce="price1" and open_5_21<>0 then
					Response.write "" & vbcrlf & "                 <td align=""right"">" & vbcrlf & ""
					if not isnull(rss("price1")) then
						Response.write Formatnumber(rss("price1"),SalesPrice_dot_num,-1)
'if not isnull(rss("price1")) then
					else
						Response.write "&nbsp;"
					end if
					Response.write "" & vbcrlf & "                              </td>" & vbcrlf & ""
				elseif sorce="num1" then
					num1 = rss("num1")
					If num1 &"" = "" Then num1 = 0 Else num1 = CDbl(num1)
					mxzdy.addSumField i,rs("inx"),num1,num1_dot
					i=i+1
					mxzdy.addSumField i,rs("inx"),num1,num1_dot
					Response.write "" & vbcrlf & "                 <td align=""center"">"
					dim mxid, attr1id,  attr2id, inputattrs, oldcontractlist
					while CurrProductAttrsHandler.ForEach(mxid, id,  attr1id,  attr2id,  num1,  inputattrs)
						Response.write  Formatnumber(num1,num1_dot,-1)
'while CurrProductAttrsHandler.ForEach(mxid, id,  attr1id,  attr2id,  num1,  inputattrs)
					wend
					Response.write "</td>" & vbcrlf & ""
				elseif sorce="date2" Then
					i=i+1
'elseif sorce="date2" Then
					Response.write "" & vbcrlf & "                 <td align=""center"">"
					Response.write rss("date2")
					Response.write "</td>" & vbcrlf & ""
				elseif sorce="intro" Then
					If IsNull(rss("intro")) Then
						intro_ht=""
					else
						intro_ht=rss("intro")
					end if
					i=i+1
					intro_ht=rss("intro")
					Response.write "" & vbcrlf & "                 <td>"
					Response.write replace(replace(intro_ht,vbcrlf,"<br>"),chr(10),"<br>")
					Response.write "</td>" & vbcrlf & ""
				elseif sorce="pricejy" and open_5_24<>0 then
					num_jgkz=num_jgkz+1
'elseif sorce="pricejy" and open_5_24<>0 then
					i=i+1
'elseif sorce="pricejy" and open_5_24<>0 then
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write Formatnumber(rss("spricejy"),StorePrice_dot_num,-1)
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write "</td>" & vbcrlf & ""
				elseif sorce="tpricejy" and open_5_24<>0 then
					num_jgkz=num_jgkz+1
'elseif sorce="tpricejy" and open_5_24<>0 then
					mxzdy.addSumField i,rs("inx"),CDbl(rss("stpricejy")),num_dot_xs
					i=i+1
'mxzdy.addSumField i,rs("inx"),CDbl(rss("stpricejy")),num_dot_xs
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write Formatnumber(rss("stpricejy"),num_dot_xs,-1)
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write "</td>" & vbcrlf & ""
				ElseIf sorce="discount" and open_5_21<>0 Then
					num_jgkz=num_jgkz+1
'ElseIf sorce="discount" and open_5_21<>0 Then
					i=i+1
'ElseIf sorce="discount" and open_5_21<>0 Then
					Response.write "" & vbcrlf & "                <td align=""center"">"
					Response.write Formatnumber(rss("discount"),sdk.Info.DiscountNumber,-1)
					Response.write "" & vbcrlf & "                <td align=""center"">"
					Response.write "</td>" & vbcrlf & ""
				ElseIf sorce="priceAfterDiscount" And open_5_21<>0 Then
					num_jgkz=num_jgkz+1
'ElseIf sorce="priceAfterDiscount" And open_5_21<>0 Then
					i=i+1
'ElseIf sorce="priceAfterDiscount" And open_5_21<>0 Then
					If price1_limit&""="" Then price1_limit = 0
					Response.write "" & vbcrlf & "                <td align=""right"">" & vbcrlf & "                             "
					Response.write Formatnumber(rss("priceAfterDiscount"),SalesPrice_dot_num,-1)
					Response.write "" & vbcrlf & "                <td align=""right"">" & vbcrlf & "                             "
					if CDbl(rss("priceAfterDiscount")) < CDbl(price1_limit) and sort19=1  then Response.write "&nbsp;&nbsp; <font color=""red"">低于限价</font>"
					Response.write "" & vbcrlf & "                             </td>" & vbcrlf & ""
				ElseIf sorce="invoiceType" Then
					i=i+1
'ElseIf sorce="invoiceType" Then
					Response.write "" & vbcrlf & "                <td align=""center"">"
					Response.write rss("invoiceType")
					Response.write "</td>" & vbcrlf & ""
				ElseIf sorce="taxRate" Then
					i=i+1
'ElseIf sorce="taxRate" Then
					Response.write "" & vbcrlf & "                <td align=""center"">"
					Response.write Formatnumber(rss("taxRate"),num_dot_xs,-1)
					Response.write "" & vbcrlf & "                <td align=""center"">"
					Response.write "%</td>" & vbcrlf & ""
				ElseIf sorce="priceIncludeTax" And open_5_21<>0 Then
					num_jgkz=num_jgkz+1
'ElseIf sorce="priceIncludeTax" And open_5_21<>0 Then
					i=i+1
'ElseIf sorce="priceIncludeTax" And open_5_21<>0 Then
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write Formatnumber(rss("priceIncludeTax"),SalesPrice_dot_num,-1)
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write "</td>" & vbcrlf & ""
				ElseIf sorce="priceAfterTaxPre" And open_5_21<>0 Then
					num_jgkz=num_jgkz+1
'ElseIf sorce="priceAfterTaxPre" And open_5_21<>0 Then
					i=i+1
'ElseIf sorce="priceAfterTaxPre" And open_5_21<>0 Then
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write Formatnumber(rss("priceAfterTaxPre"),SalesPrice_dot_num,-1)
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write "</td>" & vbcrlf & ""
				ElseIf sorce="moneyBeforeTax" And open_5_21<>0 Then
					num_jgkz=num_jgkz+1
'ElseIf sorce="moneyBeforeTax" And open_5_21<>0 Then
					mxzdy.addSumField i,rs("inx"),CDbl(rss("moneyBeforeTax")),num_dot_xs
					i=i+1
					mxzdy.addSumField i,rs("inx"),CDbl(rss("moneyBeforeTax")),num_dot_xs
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write Formatnumber(rss("moneyBeforeTax"),num_dot_xs,-1)
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write "</td>" & vbcrlf & ""
				ElseIf sorce="moneyAfterTax" And open_5_21<>0 Then
					num_jgkz=num_jgkz+1
'ElseIf sorce="moneyAfterTax" And open_5_21<>0 Then
					mxzdy.addSumField i,rs("inx"),CDbl(rss("moneyAfterTax")),num_dot_xs
					i=i+1
					mxzdy.addSumField i,rs("inx"),CDbl(rss("moneyAfterTax")),num_dot_xs
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write Formatnumber(rss("moneyAfterTax"),num_dot_xs,-1)
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write "</td>" & vbcrlf & ""
				ElseIf sorce="concessions" And open_5_21<>0 Then
					num_jgkz=num_jgkz+1
'ElseIf sorce="concessions" And open_5_21<>0 Then
					mxzdy.addSumField i,rs("inx"),CDbl(rss("concessions")),num_dot_xs
					i=i+1
'mxzdy.addSumField i,rs("inx"),CDbl(rss("concessions")),num_dot_xs
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write Formatnumber(rss("concessions"),num_dot_xs,-1)
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write "</td>" & vbcrlf & ""
				ElseIf sorce="priceAfterTax" And open_5_21<>0 Then
					num_jgkz=num_jgkz+1
'ElseIf sorce="priceAfterTax" And open_5_21<>0 Then
					i=i+1
'ElseIf sorce="priceAfterTax" And open_5_21<>0 Then
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write Formatnumber(rss("priceAfterTax"),SalesPrice_dot_num,-1)
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write "</td>" & vbcrlf & ""
				elseif sorce="moneyAfterConcessions" and open_5_21<>0 then
					num_jgkz=num_jgkz+1
'elseif sorce="moneyAfterConcessions" and open_5_21<>0 then
					moneyAfterConcessions = rss("moneyAfterConcessions")
					If money1 &"" = "" Then money1 = 0 Else moneyAfterConcessions = CDbl(moneyAfterConcessions)
					mxzdy.addSumField i,rs("inx"),moneyAfterConcessions,num_dot_xs
					i=i+1
'mxzdy.addSumField i,rs("inx"),moneyAfterConcessions,num_dot_xs
					Response.write "" & vbcrlf & "                 <td align=""right"">"
					Response.write Formatnumber(moneyAfterConcessions,num_dot_xs,-1)
					Response.write "" & vbcrlf & "                 <td align=""right"">"
					Response.write "</td>" & vbcrlf & ""
				ElseIf sorce="taxValue" And open_5_21<>0 Then
					mxzdy.addSumField i,rs("inx"),CDbl(rss("taxValue")),num_dot_xs
					num_jgkz=num_jgkz+1
'mxzdy.addSumField i,rs("inx"),CDbl(rss("taxValue")),num_dot_xs
					i=i+1
'mxzdy.addSumField i,rs("inx"),CDbl(rss("taxValue")),num_dot_xs
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write Formatnumber(rss("taxValue"),num_dot_xs,-1)
					Response.write "" & vbcrlf & "                <td align=""right"">"
					Response.write "</td>" & vbcrlf & ""
				elseif sorce="money1" and open_5_21<>0 then
					num_jgkz=num_jgkz+1
'elseif sorce="money1" and open_5_21<>0 then
					money1 = rss("money1")
					If money1 &"" = "" Then money1 = 0 Else money1 = CDbl(money1)
					mxzdy.addSumField i,rs("inx"),money1,num_dot_xs
					i=i+1
					mxzdy.addSumField i,rs("inx"),money1,num_dot_xs
					Response.write "" & vbcrlf & "                 <td align=""right"">"
					Response.write Formatnumber(money1,num_dot_xs,-1)
					Response.write "" & vbcrlf & "                 <td align=""right"">"
					Response.write "</td>" & vbcrlf & ""
				elseif rs("InheritId").value<>0 then
					dim zdytext : zdytext = NewMxZDYLoad(conn ,11001 , 1 , rss("contract").value, rss("id").value , rs("InheritId") )
					Response.write "" & vbcrlf & "                <td align=""center"">"
					Response.write zdytext
					Response.write "</td>" & vbcrlf & "                "
					i=i+1
					Response.write "</td>" & vbcrlf & "                "
				end if
				rs.movenext
			loop
			rs.close
			set rs=nothing
		end sub
		Public Sub showWithInput(httype)
			If invoiceTypes = "" Or isnull(invoiceTypes) Then
				invoiceTypes = "0"
			end if
			If isnull(invoiceType) Or invoiceType="" Then
				iType = 0
			else
				iType = invoiceType
			end if
			If minNum <> "" And minMoney <> "" Then
				editFlg = true
				If CDbl(minNum)>0 Or CDbl(minMoney)>0 Then
					rowCanDel = False
				else
					rowCanDel = True
				end if
			else
				editFlg = false
				rowCanDel = True
			end if
			If fromWx = True Then rowCanDel = False
			if rs("isUsed")&""="1" _
			And ((InStr(Me.sellPriceControl,","&sorce&",")>0 and open_5_21<>0) or InStr(Me.sellPriceControl,","&sorce&",")<=0) _
			And ((InStr(buyPriceControl,","&sorce&",")>0 and open_5_24<>0) or InStr(buyPriceControl,","&sorce&",")<=0) Then
				strDisplay = ""
			else
				strDisplay = "display:none;"
			end if
			if canChangeUnit&""="" then canChangeUnit = "1"
			if canChangePrice&""="" then canChangePrice = "1"
			if canChangeInvoice&""="" then canChangeInvoice = "1"
			if canChangeTaxRate&""="" then canChangeTaxRate = "1"
			if canChangeNum&""="" then canChangeNum = "1"
			select case sorce
			case "title"
			Response.write "" & vbcrlf & "        <td width="""
			Response.write kd
			Response.write """ class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "         <span id=""viewBom_"
			Response.write id
			Response.write """ "
			Response.write iif(treeord&""<>"" And treeord&""<>"0" and showICO&""="","class='ico5'","")
			Response.write " onmouseup=""showTreeSet('"
			Response.write pwurl(top)
			Response.write "',2,"
			Response.write id
			Response.write ")""  onmousedown='stopBubble(event)'></span>" & vbcrlf & "                "
			Dim qxOpen
			sdk.setup.getpowerattr 21,14,qxOpen, qxIntro
			If qxOpen > 0 Then
				Response.write "                      " & vbcrlf & "                        <a href=""javascript:void(0)""  onclick=javascript:window.open(""../product/content.asp?ord="
				Response.write pwurl(ord)
				Response.write """,""newwin21"",""width=800,height=500,toolbar=0,scrollbars=1,resizable=1,left=100,top=100"");return false; alt=""查看产品详情"">"
			end if
			Response.write "&nbsp;"
			Response.write k
			Response.write "</a> " & vbcrlf & ""
			If rowCanDel and canChangePrice = "1" and batchcorrect<>"1" Then
				Response.write "" & vbcrlf & "                      <a href=""javascript:void(0)"" onclick=""del('trpx"
				Response.write i-1
				Response.write "" & vbcrlf & "                      <a href=""javascript:void(0)"" onclick=""del('trpx"
				Response.write "','"
				Response.write id
				Response.write "',event);"" >" & vbcrlf & "                       <img src=""../images/del2.gif"" id='dels_"
				Response.write id
				Response.write "' border=0 alt=""删除此条数据"" >"
				Response.write batchcorrect
				Response.write "</a>&nbsp;"
				Response.write i
			else
				Response.write "" & vbcrlf & "                      <img src=""../images/del2.gif"" style=""filter:gray;-moz-opacity:.1;opacity:0.1;"" border=0 alt=""此条数据不允许删除"" >&nbsp;"
				Response.write i
				Response.write i
			end if
			Response.write "" & vbcrlf & "                      <dd style='display:none'>" & vbcrlf & "                               <input type='hidden' name='productId"
			Response.write id
			Response.write "' value='"
			Response.write ord
			Response.write "'>" & vbcrlf & "                            <input type='hidden' name='mxidlists' value='"
			Response.write id
			Response.write "'>" & vbcrlf & "                    </dd>" & vbcrlf & "           </td>" & vbcrlf & ""
			case "order1"
			Response.write "" & vbcrlf & "              <td class=""name dataCell inputCell"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>"
			Response.write order1
			Response.write "</td>" & vbcrlf & ""
			case "type1"
			Response.write "" & vbcrlf & "              <td class=""name dataCell inputCell"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>"
			Response.write type1
			Response.write "</td>" & vbcrlf & ""
			case "unit"
			Response.write "" & vbcrlf & "                  <td class=""name dataCell inputCell"" align=""center"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "                            <select name=""unit_"
			Response.write id
			Response.write """ id=""u_nametest"
			Response.write id
			Response.write """ oldValue="""
			Response.write unit
			Response.write """ " & vbcrlf & "                                    onChange=UnitChange(""test"
			Response.write id
			Response.write ""","""
			Response.write ord
			Response.write ""","""
			Response.write i-1
			Response.write ""","""
			Response.write ""","""
			Response.write id
			Response.write """"
			If editFlg Then Response.write ",true"
			Response.write ","""","""
			Response.write httype
			Response.write """); dataType=""Range"" msg=""不能为空"" min=""1"" max=""9999999999999"" hasInvoice="""
			Response.write hasInvoice
			Response.write """ >" & vbcrlf & "                                   <option value="""
			Response.write unit
			Response.write """>"
			Response.write unitname
			Response.write "</option>" & vbcrlf & "                "
			If (numKuout = "" Or numKuout & "" = "0") And fromWx <> True and canChangeUnit ="1" and canChangePrice="1" Then
				set rs7=server.CreateObject("adodb.recordset")
				If Len(unitall&"")=0 Then unitall=0
				If Len(unit&"")=0 Then unit=0
				sql7="select ord,sort1 from sortonehy where gate2=61 and id in ("&unitall&") and id<>"&unit&" order by gate1 desc"
				rs7.open sql7,conn,1,1
				do until rs7.eof
					Response.write "" & vbcrlf & "                        <option value="""
					Response.write rs7("ord")
					Response.write """ "
					if unit=rs7("ord") then
						Response.write " selected "
					end if
					Response.write " >"
					Response.write rs7("sort1")
					Response.write "</option>" & vbcrlf & "                        "
					rs7.movenext
				loop
				rs7.close
				set rs7=Nothing
			end if
			Response.write "" & vbcrlf & "                         </select>" & vbcrlf & "               </td>" & vbcrlf & "            "
			If isOpenMoreUnitAttr and htType<>"JH" Then
				Response.write "" & vbcrlf & "                         <td align=""center"" width=""110"" class=""name dataCell inputCell"" style="""
				Response.write strDisplay
				Response.write """>" & vbcrlf & "                                    "
				Response.write LoadMoreUnit(1,commUnitAttr, id , NumberValue,num1_dot)
				Response.write "" & vbcrlf & "                         </td>" & vbcrlf & "                           "
			end if
			case "price1"
			Response.write "" & vbcrlf & "             <td class=""name dataCell""  width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "                        <div align=""center"">" & vbcrlf & "                              <span id=""ttest"
			Response.write id
			Response.write """></span>" & vbcrlf & "                         <span id=""test"
			Response.write id
			Response.write """></span>" & vbcrlf & "                         <input name=""price1_"
			Response.write id
			Response.write """  id=""pricetest"
			Response.write id
			Response.write """ maxlength=""20"" type=""text""  value="""
			Response.write FormatNumber(price1,SalesPrice_dot_num,-1,0,0)
			Response.write """ maxlength=""20"" type=""text""  value="""
			Response.write """  "
			if canChangePrice="0" then
				Response.write "readonly"
			end if
			Response.write "" & vbcrlf & "                                     style=""height: 19px; solid;font-size: 9pt;text-align:right;width:50px"" " & vbcrlf & "                                   "
			Response.write "readonly"
			if canChangePrice<>"0" then
				Response.write " onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'}""  "
			end if
			Response.write "" & vbcrlf & "                                     onBlur=if(!this.value){this.value=this.defaultValue;this.style.color='#000';chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);};checkDot('pricetest"
			Response.write id
			Response.write "','"
			Response.write SalesPrice_dot_num
			Response.write "') " & vbcrlf & "                                  onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('pricetest"
			Response.write id
			Response.write "','"
			Response.write SalesPrice_dot_num
			Response.write "') """ & vbcrlf & "                                      onpropertychange=""chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);"" " & vbcrlf & "                                 dataType=""Range"" msg=""必须填写单价"" min=""-99999999999"" max=""999999999999""" & vbcrlf & "                               />" & vbcrlf & "                              <img src=""../images/112.png""  onmouseover=callServer2('test"
			Response.write jf
			Response.write id
			Response.write "','"
			Response.write ord
			Response.write "','"
			Response.write id
			Response.write "');  onmouseout=callServer3('test"
			Response.write id
			Response.write "','"
			Response.write ord
			Response.write "','"
			Response.write id
			Response.write "') border=0 style=""cursor:hand"">" & vbcrlf & "                               <span id=""tttest"
			Response.write id
			Response.write """  style=""position:absolute;margin-left:0;""></span>" & vbcrlf & "                 </div>" & vbcrlf & "          </td>" & vbcrlf & ""
			Response.write id
			case "num1"
			Response.write "" & vbcrlf & "             <td class=""name dataCell inputCell"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """><div align=""center"">" & vbcrlf & "                      "
			dim attr1id,  attr2id, inputattrs, eachobj, currbatchid , ominNum , ominMoney , numlimit
			currbatchid = id
			ominNum = minNum
			ominMoney = minMoney
			while CurrProductAttrsHandler.ForEach(id, oldcontractlist,  attr1id,  attr2id,  num1,  inputattrs)
				set eachobj = CurrProductAttrsHandler.EachObject
				if not eachobj is nothing then
					if attr1id >  0 then
						minNum =  eachobj.items("minNum") &""
						minMoney =  eachobj.items("minMoney")
					else
						minNum =  ominNum
						minMoney =  ominMoney
					end if
				end if
				numlimit = false
				If minNum <> "" And minMoney <> "" Then
					if minNum<>"0" then
						numlimit = true
						strMinNumLimit = " dataType=""Range"" min=""" & minNum & """ max=""999999999999"" msg=""不能小于"&FormatNumber(minNum,num1_dot,-1)&""""
						numlimit = true
						strMinMoneyLimit = " minValue=""" & minMoney & """ onpropertychange=""checkMXMoneyLimit(this);"""
					end if
				end if
				if numlimit=false then
					numlimit = true
					strMinNumLimit = " dataType=""Limit""  max=""25"" msg=""不能为空"""
					if attr1id= 0 then strMinNumLimit =  " dataType=""Number""  max=""999999999999"" msg=""不能为空"" limit=""0.000001""  "
					strMinMoneyLimit = ""
				end if
				dim numstr
				if len(num1 & "") > 0 then
					numstr = FormatNumber(num1,num1_dot,-1,0,0)
'if len(num1 & "") > 0 then
				else
					numstr = ""
				end if
				if concessions&""="" then concessions = 0
				Response.write "" & vbcrlf & "                     <input "
				Response.write inputattrs
				Response.write "  Name=""num1_"
				Response.write id
				Response.write """ maxlength=""20"" id=""num"
				Response.write id
				Response.write """ type=""text"" value="""
				Response.write numstr
				Response.write """  " & vbcrlf & "                style=""width:50px;height: 19px; solid;font-size: 9pt;"" onfocus=""this.select();""" & vbcrlf & "                "
				Response.write numstr
				if (cdbl(concessions)>0 and canChangePrice="0") or canChangeNum="0" then
					Response.write " readonly " & vbcrlf & "                "
				else
					Response.write "" & vbcrlf & "                             onBlur=""if(!this.value){this.value=this.defaultValue;this.style.color='#000';};chtotal("
					Response.write id
					Response.write ","
					Response.write num_dot_xs
					Response.write ","
					Response.write jf
					Response.write ",this);checkDot('num"
					Response.write id
					Response.write "','"
					Response.write num1_dot
					Response.write "');eval('moneyjyall_"
					Response.write id
					Response.write "').value=FormatNumber(this.value*eval('pricejy_"
					Response.write id
					Response.write "').value,"
					Response.write num_dot_xs
					Response.write ");"" " & vbcrlf & "                              onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('num"
					Response.write id
					Response.write "','"
					Response.write num1_dot
					Response.write "');eval('moneyjyall_"
					Response.write id
					Response.write "').value=FormatNumber(this.value*eval('pricejy_"
					Response.write id
					Response.write "').value,"
					Response.write num_dot_xs
					Response.write ");""  " & vbcrlf & "                             onpropertychange=""chtotal("
					Response.write id
					Response.write ","
					Response.write num_dot_xs
					Response.write ","
					Response.write jf
					Response.write ",this);"" " & vbcrlf & "                "
				end if
				Response.write strMinNumLimit
				Response.write " />" & vbcrlf & ""
				if ZBRuntime.MC(17000) Then
					Set rssxx = conn.execute("select top 1 canoutstore from product where ord=" & ord & " and canoutstore=1")
					If rssxx.eof = False then
						ko = rssxx.fields(0).value
					else
						ko = 0
					end if
					rssxx.close
					dim attr2jsvar
					attr2jsvar = "0"
					if attr1id>0 then  attr2jsvar = "GetCurrAttr2Value('" & currbatchid & "')"
					Response.write "" & vbcrlf & "                     <img src=""../images/116.png"" class='ko"
					Response.write ko
					Response.write "' onmouseover=""callServer5('ttttest"
					Response.write id
					Response.write "','test"
					Response.write currbatchid
					Response.write "','"
					Response.write ord
					Response.write "','"
					Response.write id
					Response.write "','"
					Response.write attr1id
					Response.write "',"
					Response.write attr2jsvar
					Response.write ");""  onmouseout=callServer6('ttttest"
					Response.write id
					Response.write "','test"
					Response.write currbatchid
					Response.write "','"
					Response.write ord
					Response.write "','"
					Response.write id
					Response.write "') border=0 style=""cursor:hand"">" & vbcrlf & "" & vbcrlf & "                       <span id=""ttttest"
					Response.write id
					Response.write """   class='ko"
					Response.write ko
					Response.write "' style=""position:absolute;margin-left:0;""></span></div>" & vbcrlf & ""
					Response.write ko
					If Trim(num1_xyou)>0 Then
					else
						Response.write "<span style='color:red' class='ko" & ko & "'>没有库存</span>"
					end if
				end if
			wend
			Response.write "" & vbcrlf & "             </td>" & vbcrlf & ""
			case "money1"
			Response.write "" & vbcrlf & "             <td align=""center"" class=""name dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """> " & vbcrlf & "                       <input name=""moneyall_"
			Response.write id
			Response.write """ class=""proMoney"" maxlength=""20"" id=""moneyall"
			Response.write id
			Response.write """ type=""text"" value="""
			Response.write FormatNumber(money1,num_dot_xs,-1,0,0)
			Response.write """ type=""text"" value="""
			Response.write """ " & vbcrlf & "                                style=""text-align:right;width:100%;color:#666666;border: #CCCCCC 1px solid;"" readonly" & vbcrlf & "                             dataType=""Range"" min=""0"" msg=""请正确填写"" max=""999999999999""" & vbcrlf & "                            "
			Response.write """ type=""text"" value="""
			Response.write strMinMoneyLimit
			Response.write "" & vbcrlf & "                     />" & vbcrlf & "              </td>" & vbcrlf & ""
			case "date2"
			Response.write "" & vbcrlf & "             <td align=""center"" width="""
			Response.write kd
			Response.write """ class=""name dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "                        <INPUT name=""date1_"
			Response.write id
			Response.write """  id=""daysdate1_"
			Response.write id
			Response.write "Pos"" value="""
			Response.write date2
			Response.write """" & vbcrlf & "                         style=""width:80px;height: 19px; solid;font-size: 9pt;"" " & vbcrlf & "                           onmouseup=""toggleDatePicker('daysdate1_"
			Response.write date2
			Response.write id
			Response.write "','date.date1_"
			Response.write id
			Response.write "')""" & vbcrlf & "                               dataType=""Date"" format=""ymd"" msg=""日期格式不正确""" & vbcrlf & "                     />" & vbcrlf & "              <DIV id='daysdate1_"
			Response.write id
			Response.write "' style='POSITION: absolute'></DIV></td>" & vbcrlf & ""
			case "intro"
			Response.write "" & vbcrlf & "             <td align=""center"" class=""name dataCell inputCell"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "                <textarea rows=""1"" id=""intro_"
			Response.write id
			Response.write """ name=""intro_"
			Response.write id
			Response.write """  min=""0"" max=""200"" msg=""备注字数必须在0~200"" style=""overflow-y:hidden;word-break:break-all;width:100%;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight""  dataType=""Limit"" min=""0"" max=""2000"" msg=""不要超过2000个字"">"
			Response.write id
			Response.write sdk.HtmlConvert(replace(intro&"","<br>",chr(10)))
			Response.write "</textarea>" & vbcrlf & "          </td>" & vbcrlf & ""
			case "pricejy"
			Response.write "" & vbcrlf & "             <td align=""center"" width="""
			Response.write kd
			Response.write """ class=""name dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "            <input id=""pricejy"
			Response.write id
			Response.write """ dataType=""Range"" min=""0"" max=""999999999999.99999999"" msg=""金额必须在0-999999999999.99999999""" & vbcrlf & "                maxlength=""20"" name=""pricejy_"
			Response.write id
			Response.write id
			Response.write """" & vbcrlf & "                onblur=""if(!this.value){this.value=this.defaultValue;this.style.color='#000'}""" & vbcrlf & "                onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'}""" & vbcrlf & "                onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('pricejy"
			Response.write id
			Response.write "','"
			Response.write StorePrice_dot_num
			Response.write "');eval('moneyjyall_"
			Response.write id
			Response.write "').value=FormatNumber(this.value*eval('num1_"
			Response.write id
			Response.write "').value,"
			Response.write num_dot_xs
			Response.write ");""" & vbcrlf & "                style=""width:60px;height: 19px; solid;font-size: 9pt;text-align:right;"" type=""text""" & vbcrlf & "                value="""
			Response.write num_dot_xs
			Response.write FormatNumber(pricejy,StorePrice_dot_num,-1,0,0)
			Response.write num_dot_xs
			Response.write """ />" & vbcrlf & "              </td>" & vbcrlf & ""
			case "tpricejy"
			Response.write "" & vbcrlf & "             <td align=""center"" width="""
			Response.write kd
			Response.write """ class=""name dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "                        <input name=""moneyjyall_"
			Response.write id
			Response.write """ readonly id=""moneyjyall"
			Response.write id
			Response.write """ value="""
			Response.write FormatNumber(CDbl(pricejy)*CDbl(num1),num_dot_xs,-1,0,0)
			Response.write """ value="""
			Response.write """ type=""text"" " & vbcrlf & "                              style=""color:#666666;border: #CCCCCC 1px solid;text-align:right;width:60px;"">" & vbcrlf & "                     </td>" & vbcrlf & ""
			Response.write """ value="""
			case "discount"
			Response.write "" & vbcrlf & "             <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """> " & vbcrlf & "                       <input type=""text"" name=""discount_"
			Response.write id
			Response.write """ id=""discount_"
			Response.write id
			Response.write """ value="""
			Response.write FormatNumber(discount,DISCOUNT_DOT_NUM,-1,0,0)
			Response.write """ value="""
			Response.write """ style=""width:90%;text-align:right""  "
			Response.write """ value="""
			if canChangePrice="0" then
				Response.write "readonly"
			end if
			if canChangePrice<>"0" then
				Response.write " onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'}""  "
			end if
			Response.write "" & vbcrlf & "                     onBlur=if(!this.value){this.value=this.defaultValue;this.style.color='#000';chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this)} " & vbcrlf & "                     onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('discount_"
			Response.write id
			Response.write "','"
			Response.write DISCOUNT_DOT_NUM
			Response.write "');""" & vbcrlf & "                      msg=""折扣必须控制在0-"
			Response.write DISCOUNT_DOT_NUM
			Response.write FormatNumber(DISCOUNT_MAX_VALUE,DISCOUNT_DOT_NUM,-1,0,0)
			Response.write DISCOUNT_DOT_NUM
			Response.write "之间"" dataType=""Range"" min=""0"" max="""
			Response.write DISCOUNT_MAX_VALUE
			Response.write """" & vbcrlf & "                 onpropertychange=""chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this)""" & vbcrlf & "                   msgWhenHide=""折扣必须控制在0-"
			Response.write jf
			Response.write FormatNumber(DISCOUNT_MAX_VALUE,DISCOUNT_DOT_NUM,-1,0,0)
			Response.write jf
			Response.write "之间（请联系管理员在明细自定义中开启该字段）"" " & vbcrlf & "                    />" & vbcrlf & "                      <input type=""hidden"" name=""discountValue_"
			Response.write id
			Response.write """ id=""discountValue_"
			Response.write id
			Response.write """ value="""
			Response.write discount
			Response.write """/>" & vbcrlf & "               </td>" & vbcrlf & ""
			case "priceAfterDiscount"
			Response.write "" & vbcrlf & "               <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """>" & vbcrlf & "                  <input type=""text"" name=""priceAfterDiscount_"
			Response.write id
			Response.write """ id=""priceAfterDiscount_"
			Response.write id
			Response.write """ value="""
			Response.write FormatNumber(priceAfterDiscount,SalesPrice_dot_num,-1,0,0)
			Response.write """ value="""
			Response.write """ " & vbcrlf & "                 style=""width:90%;color:#666666;border: #CCCCCC 1px solid;text-align:right"" readonly dataType=""Range"" msg=""低于限价"" min="""
			Response.write """ value="""
			Response.write price1_limit
			Response.write """ max=""999999999999"" " & vbcrlf & "                        msgWhenHide = ""未税折后单价低于限价（请联系管理员在明细自定义中开启该字段）"" />" & vbcrlf & "                   <img src=""../images/112.png"" onmouseover=""showPrice("
			Response.write id
			Response.write ","
			Response.write ord
			Response.write ");"" onmouseout=""jQuery('#info_show_div').hide();"" border=0 style=""cursor:hand"">" & vbcrlf & "                </td>" & vbcrlf & ""
			case "invoiceType"
			sql="select * from ("&_
			"                                     ""select a.id,a.sort1,b.taxRate,b.priceFormula,b.priceBeforeTaxFormula,(case when a.id=""&iType&"" then 0 else 1 end) as topRow,a.gate1 from sortonehy a inner join invoiceConfig b on a.id=b.typeid where gate2 = 34 and isStop=0 and isnull(id1,0)<>-65535 and a.id in (""&iif(invoiceTypes="""",""0"",invoiceTypes)"&","&iType&")"&_
			"union all ("&_
			"select 0,'不开票',taxRate,priceFormula,priceBeforeTaxFormula,(case when "&iType&"=0 then 0 else 1 end) as topRow,-9999999 from sortonehy a,invoiceConfig b where a.id=b.typeid and isnull(a.id1,0)=-65535"&_
			"union all ("&_
			")"&_
			") bb "
			Response.write "" & vbcrlf & "              <td class=""dataCell inputCell"" align=""center"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "                 <select name=""invoiceType_"
			Response.write id
			Response.write """ id=""invoiceType_"
			Response.write id
			Response.write """ includeTax="""
			Response.write includeTax
			Response.write """ onchange=""changeInvoice("
			Response.write id
			Response.write ");"">" & vbcrlf & ""
			If (editFlg = True And (hasInvoice = True Or fromWx = True) ) or canChangePrice="0" or canChangeInvoice="0" Then
				sql=sql&" where id = " & invoiceType
			end if
			sql=sql & " order by topRow,gate1 desc "
			Set rsInvoice=conn.execute(sql)
			While rsInvoice.eof = false
				Response.write "" & vbcrlf & "                              <option value="""
				Response.write rsInvoice(0)
				Response.write """ taxRate="""
				Response.write FormatNumber(rsInvoice(2),num_dot_xs,-1,0,0)
				Response.write """ taxRate="""
				Response.write """ " & vbcrlf & "                                 formula="""
				Response.write rsInvoice(3)
				Response.write """ formula2="""
				Response.write rsInvoice(4)
				Response.write """>"
				Response.write rsInvoice(1)
				Response.write "</option>     " & vbcrlf & ""
				rsInvoice.movenext
			wend
			rsInvoice.close
			Set rsInvoice = Nothing
			Response.write "" & vbcrlf & "                      </select>" & vbcrlf & "               </td>" & vbcrlf & ""
			case "taxRate"
			Response.write "" & vbcrlf & "              <td class=""dataCell inputCell"" align=""center"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "                 <input type=""text"" name=""taxRate_"
			Response.write id
			Response.write """ id=""taxRate_"
			Response.write id
			Response.write """ value="""
			Response.write FormatNumber(taxRate,num_dot_xs,-1,0,0)
			Response.write """ value="""
			Response.write """  "
			if canChangePrice="0" or canChangeTaxRate="0" then
				Response.write "readonly"
			end if
			Response.write "" & vbcrlf & "                              style=""width:60%;text-align:right;"" " & vbcrlf & "                              msg=""只能输入0到1000之间的数字"" dataType=""Range"" min=""0"" max=""1000"" " & vbcrlf & "                            onBlur=""if(!this.value){this.value=this.defaultValue;this.style.color='#000';chtotal("
			Response.write "readonly"
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);}""" & vbcrlf & "                          onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('taxRate_"
			Response.write id
			Response.write "','"
			Response.write num_dot_xs
			Response.write "');""" & vbcrlf & "                               onpropertychange=""chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);""" & vbcrlf & "                   />%" & vbcrlf & "             </td>" & vbcrlf & ""
			case "priceAfterTaxPre"
			Response.write "" & vbcrlf & "              <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """>" & vbcrlf & "                 <input type=""text"" name=""priceAfterTaxPre_"
			Response.write id
			Response.write """ id=""priceAfterTaxPre_"
			Response.write id
			Response.write """ readonly value="""
			Response.write FormatNumber(priceAfterTaxPre,SalesPrice_dot_num,-1,0,0)
			Response.write """ readonly value="""
			Response.write """" & vbcrlf & "                 style=""width:90%;color:#666666;border: #CCCCCC 1px solid;text-align:right""/>" & vbcrlf & "                      <img src=""../images/112.png"" onmouseover=""showPrice("
			Response.write """ readonly value="""
			Response.write id
			Response.write ","
			Response.write ord
			Response.write ");"" " & vbcrlf & "                              onmouseout=""jQuery('#info_show_div').hide();"" border=0 style=""cursor:hand"">" & vbcrlf & "         </td>" & vbcrlf & ""
			case "priceAfterTax"
			Response.write "" & vbcrlf & "             <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """>" & vbcrlf & "                        <input type=""text"" name=""priceAfterTax_"
			Response.write id
			Response.write """ id=""priceAfterTax_"
			Response.write id
			Response.write """ readonly value="""
			Response.write FormatNumber(priceAfterTax,SalesPrice_dot_num,-1,0,0)
			Response.write """ readonly value="""
			Response.write """" & vbcrlf & "                 style=""width:90%;color:#666666;border: #CCCCCC 1px solid;text-align:right""/>" & vbcrlf & "                      <img src=""../images/112.png"" onmouseover=""showPrice("
			Response.write """ readonly value="""
			Response.write id
			Response.write ","
			Response.write ord
			Response.write ");""  onmouseout=""jQuery('#info_show_div').hide();"" border=0 style=""cursor:hand"">" & vbcrlf & "              </td>" & vbcrlf & ""
			case "taxValue"
			Response.write "" & vbcrlf & "             <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """>" & vbcrlf & "                        <input type=""text"" name=""taxValue_"
			Response.write id
			Response.write """ id=""taxValue_"
			Response.write id
			Response.write """ readonly value="""
			Response.write FormatNumber(taxValue,num_dot_xs,-1,0,0)
			Response.write """ readonly value="""
			Response.write """ style=""width:90%;color:#666666;border: #CCCCCC 1px solid;text-align:right""/>" & vbcrlf & "              </td>" & vbcrlf & ""
			Response.write """ readonly value="""
			case "moneyAfterConcessions"
			Response.write "" & vbcrlf & "             <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """>" & vbcrlf & "                        <input type=""text"" name=""moneyAfterConcessions_"
			Response.write id
			Response.write """ id=""moneyAfterConcessions_"
			Response.write id
			Response.write """ value="""
			Response.write FormatNumber(moneyAfterConcessions,num_dot_xs,-1,0,0)
			Response.write """ value="""
			Response.write """ "
			if canChangePrice="0" then
				Response.write "readonly"
			end if
			if canChangePrice<>"0" then
				Response.write " onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'}"" "
			end if
			Response.write "" & vbcrlf & "                         onBlur=""if(!this.value){this.value=this.defaultValue;this.style.color='#000';chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);}""" & vbcrlf & "                     onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('moneyAfterConcessions_"
			Response.write id
			Response.write "','"
			Response.write num_dot_xs
			Response.write "');""" & vbcrlf & "                          onpropertychange=""chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);""" & vbcrlf & "                      dataType=""Range"" msg=""请正确填写"" min=""-99999999999"" max=""999999999999"" " & vbcrlf & "                style=""width:90%;text-align:right""/>" & vbcrlf & "          </td>" & vbcrlf & ""
			Response.write jf
			case "moneyAfterTax"
			Response.write "" & vbcrlf & "             <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """>" & vbcrlf & "                        <input type=""text"" name=""moneyAfterTax_"
			Response.write id
			Response.write """ id=""moneyAfterTax_"
			Response.write id
			Response.write """ value="""
			Response.write FormatNumber(moneyAfterTax,num_dot_xs,-1,0,0)
			Response.write """ value="""
			Response.write """  "
			if canChangePrice="0" then
				Response.write "readonly"
			end if
			if canChangePrice<>"0" then
				Response.write " onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'}"" "
			end if
			Response.write "" & vbcrlf & "                         onBlur=""if(!this.value){this.value=this.defaultValue;this.style.color='#000';chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);}""" & vbcrlf & "                     onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('moneyAfterTax_"
			Response.write id
			Response.write "','"
			Response.write num_dot_xs
			Response.write "');""" & vbcrlf & "                          onpropertychange=""chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);""" & vbcrlf & "                      dataType=""Range"" msg=""必须填写"" min=""-99999999999"" max=""999999999999"" " & vbcrlf & "                style=""width:90%;text-align:right""/>" & vbcrlf & "            </td>" & vbcrlf & ""
			Response.write jf
			case "concessions"
			Response.write "" & vbcrlf & "             <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """>" & vbcrlf & "                        <input type=""text"" name=""concessions_"
			Response.write id
			Response.write """ id=""concessions_"
			Response.write id
			Response.write """ value="""
			Response.write FormatNumber(concessions,num_dot_xs,-1,0,0)
			Response.write """ value="""
			Response.write """  class=""concessionsInput"" "
			if canChangePrice="0" then
				Response.write "readonly"
			end if
			if canChangePrice<>"0" then
				Response.write " onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'}"" "
			end if
			Response.write "" & vbcrlf & "                     onBlur=""if(!this.value){this.value=this.defaultValue;this.style.color='#000';chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);}""" & vbcrlf & "                 onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('concessions_"
			Response.write id
			Response.write "','"
			Response.write num_dot_xs
			Response.write "');""" & vbcrlf & "                      onpropertychange=""chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);""" & vbcrlf & "                  dataType=""Range"" msg=""必须填写"" min=""-99999999999"" max=""999999999999"" " & vbcrlf & "                  style=""width:90%;text-align:right""/>" & vbcrlf & "              </td>" & vbcrlf & ""
			Response.write jf
			case "priceIncludeTax"
			Response.write "" & vbcrlf & "             <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """>" & vbcrlf & "                        <input type=""text"" name=""priceIncludeTax_"
			Response.write id
			Response.write """ id=""priceIncludeTax_"
			Response.write id
			Response.write """ value="""
			Response.write FormatNumber(priceIncludeTax,SalesPrice_dot_num,-1,0,0)
			Response.write """ value="""
			Response.write """  "
			if canChangePrice="0" then
				Response.write "readonly"
			end if
			if canChangePrice<>"0" then
				Response.write " onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'}"" "
			end if
			Response.write "" & vbcrlf & "                     onBlur=""if(!this.value){this.value=this.defaultValue;this.style.color='#000';chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);}""" & vbcrlf & "                 onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('priceIncludeTax_"
			Response.write id
			Response.write "','"
			Response.write SalesPrice_dot_num
			Response.write "');"" " & vbcrlf & "                     onpropertychange=""chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);""" & vbcrlf & "                  dataType=""Range"" msg=""必须填写"" min=""-99999999999"" max=""999999999999""  style=""width:90%;text-align:right""/>" & vbcrlf & "                       <img src=""../images/112.png"" onmouseover=""showPrice("
			Response.write jf
			Response.write id
			Response.write ","
			Response.write ord
			Response.write ");"" " & vbcrlf & "                              onmouseout=""jQuery('#info_show_div').hide();"" border=0 style=""cursor:hand"">" & vbcrlf & "         </td>" & vbcrlf & ""
			case else
			dim listid : listid= contractlistmxid
			if listid = 0 then listid = -ord
'dim listid : listid= contractlistmxid
			zdytext = NewMxZDYLoad(conn ,11001 , 1 , top,  listid , InheritId)
			select case UiType
			case 0, 10 , 13 :
			Response.write "" & vbcrlf & "                        <td class=""dataCell inputCell"" align=""center"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "                        <textarea name="""
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write """ rows=""1"" id="""
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write """  style=""overflow-y:hidden;word-break:break-all;width:100%;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight""  datatype=""Limit"" min=""0"" max=""2000"" msg=""不要超过2000个字"">"
			Response.write id
			Response.write replace(zdytext&"","<br>",chr(10))
			Response.write "</textarea>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
			case 1 :
			if isdate(zdytext)=false then zdytext = ""
			Response.write "" & vbcrlf & "                        <td align=""center"" width="""
			Response.write kd
			Response.write """ class=""name dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "                        <INPUT name="""
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write """  id=""days"
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write "Pos"" value="""
			Response.write zdytext
			Response.write """ style=""width:80px;height: 19px; solid;font-size: 9pt;"" " & vbcrlf & "                            onmouseup=""toggleDatePicker('days"
			Response.write zdytext
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write "','date."
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write "')"" dataType=""Date"" format=""ymd"" msg=""日期格式不正确""/>" & vbcrlf & "                        <DIV id='days"
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write "' style='POSITION: absolute'></DIV></td>" & vbcrlf & "                        "
			case 2 :
			if isnumeric(zdytext)=false then zdytext = "0"
			Response.write "" & vbcrlf & "                        <td class=""name dataCell inputCell"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """><div align=""center"">" & vbcrlf & "                        <input Name="""
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write """ maxlength=""20"" id="""
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write """ type=""text"" value="""
			Response.write FormatNumber(zdytext,num1_dot,-1,0,0)
			Response.write """ type=""text"" value="""
			Response.write """ " & vbcrlf & "                        style=""width:50px;height: 19px; solid;font-size: 9pt;width:50px"" " & vbcrlf & "                        onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'};"" " & vbcrlf & "                        onBlur=""if(!this.value){this.value=this.defaultValue;this.style.color='#000';};checkDot('"
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write "','"
			Response.write num1_dot
			Response.write "')"" " & vbcrlf & "                        onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('"
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write "','"
			Response.write num1_dot
			Response.write "');"" />" & vbcrlf & "                        </td>" & vbcrlf & "                        "
			case 4 :
			Response.write "" & vbcrlf & "                        <td align=""center"" class=""name dataCell inputCell"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "                        <select name="""
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write """>" & vbcrlf & "                        <option value=""是"" "
			if "是"=zdytext&"" then
				Response.write "selected"
			end if
			Response.write ">是</option>" & vbcrlf & "                        <option value=""否"" "
			if "否"=zdytext&"" then
				Response.write "selected"
			end if
			Response.write ">否</option>" & vbcrlf & "                        </select>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
			case 5:
			Response.write "" & vbcrlf & "                        <td align=""center"" class=""name dataCell inputCell"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "                        <select name="""
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write """>" & vbcrlf & "                        "
			set rs7=server.CreateObject("adodb.recordset")
			sql7="select id as ord, text as sort1 from sys_sdk_BillFieldOptionsSource where fieldid ="& InHeritID &" order by showindex "
			rs7.open sql7,conn,1,1
			do until rs7.eof
				Response.write "" & vbcrlf & "                        <option value="""
				Response.write rs7("ord")
				Response.write """ "
				if rs7("sort1")&""=zdytext&"" then
					Response.write "selected"
				end if
				Response.write ">"
				Response.write rs7("sort1")
				Response.write "</option>" & vbcrlf & "                        "
				rs7.movenext
			loop
			rs7.close
			set rs7=nothing
			Response.write "" & vbcrlf & "                        </select>" & vbcrlf & "                        </td>" & vbcrlf & "                        "
			end select
			End select
		end sub
		Public Sub showWithInputKD()
			If invoiceTypes = "" Or isnull(invoiceTypes) Then
				invoiceTypes = "0"
			end if
			If isnull(invoiceType) Or invoiceType="" Then
				iType = 0
			else
				iType = invoiceType
			end if
			strDisplay = "display:none;"
			if rs("isused")&""="1" And ((InStr(Me.sellPriceControl,","&sorce&",")>0 and open_5_21<>0) or InStr(Me.sellPriceControl,","&sorce&",")<=0) and ((InStr(buyPriceControl,","&sorce&",")>0 and open_5_24<>0) or InStr(buyPriceControl,","&sorce&",")<=0) Then
				strDisplay = ""
			end if
			select case sorce
			case "title"
			Response.write "" & vbcrlf & "            <td width="""
			Response.write kd
			Response.write """ class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "            "
			Dim qxOpen
			sdk.setup.getpowerattr 21,14,qxOpen, qxIntro
			If qxOpen > 0 Then
				Response.write "             " & vbcrlf & "            <a href=""javascript:void(0)""  onclick=javascript:window.open(""../product/content.asp?ord="
				Response.write pwurl(ord)
				Response.write """,""newwin21"",""width=""+800+"",height=""+500+"",toolbar=0,scrollbars=1,resizable=1,left=100,top=100"");return false; alt=""查看产品详情"">"
				Response.write pwurl(ord)
			end if
			Response.write "&nbsp;"
			Response.write k
			Response.write "</a> <a href=""javascript:void(0)"" onclick=del6(""trpx"
			Response.write i-1
			Response.write "</a> <a href=""javascript:void(0)"" onclick=del6(""trpx"
			Response.write "_"
			Response.write id
			Response.write ""","""
			Response.write id
			Response.write ""","
			Response.write num_dot_xs
			Response.write ");><img src=""../images/del2.gif""  border=0/ alt=""删除此条数据""></a>&nbsp;"
			Response.write i
			Response.write "<input name="""
			Response.write i
			Response.write """  id="""
			Response.write i
			Response.write """ value="""
			Response.write id
			Response.write """  type=""hidden""></td>" & vbcrlf & "            "
			case "order1"
			Response.write "" & vbcrlf & "            <td class=""name dataCell"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>"
			Response.write order1
			Response.write "</td>" & vbcrlf & "            "
			case "type1"
			Response.write "" & vbcrlf & "            <td class=""name dataCell"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>"
			Response.write type1
			Response.write "</td>" & vbcrlf & "            "
			case "unit"
			Response.write "" & vbcrlf & "            <td class=""name dataCell inputCell"" align=""center"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "            <select name=""unit_"
			Response.write id
			Response.write """ id=""u_nametest"
			Response.write id
			Response.write """ onChange=callServer(""test"
			Response.write id
			Response.write ""","""
			Response.write ord
			Response.write ""","""
			Response.write i-1
			Response.write ""","""
			Response.write ""","""
			Response.write id
			Response.write ""","
			Response.write num_dot_xs
			Response.write "); dataType=""Range"" msg=""不能为空"" min=""1"" max=""9999999999999"">" & vbcrlf & "            <option value="""
			Response.write unit
			Response.write """>"
			Response.write unitname
			Response.write "</option>" & vbcrlf & "            "
			set rs7=server.CreateObject("adodb.recordset")
			If Len(unitall&"")=0 Then unitall=0
			If Len(unit&"")=0 Then unit=0
			sql7="select ord,sort1 from sortonehy where gate2=61 and id in ("&unitall&") and id<>"&unit&" order by gate1 desc"
			rs7.open sql7,conn,1,1
			do until rs7.eof
				Response.write "" & vbcrlf & "            <option value="""
				Response.write rs7("ord")
				Response.write """ "
				if unit=rs7("ord") then
					Response.write " selected "
				end if
				Response.write " >"
				Response.write rs7("sort1")
				Response.write "</option>" & vbcrlf & "            "
				rs7.movenext
			loop
			rs7.close
			set rs7=nothing
			Response.write "" & vbcrlf & "            </select>" & vbcrlf & "            </td>" & vbcrlf & "            "
			case "price1"
			Response.write "" & vbcrlf & "            <td width="""
			Response.write kd
			Response.write """ class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "            <div align=""center"">" & vbcrlf & "            <span id=""ttest"
			Response.write id
			Response.write """></span><span id=""test"
			Response.write id
			Response.write """></span>" & vbcrlf & "            <input name=""price1_"
			Response.write id
			Response.write """ id=""pricetest"
			Response.write id
			Response.write """ type=""text"" value="""
			Response.write FormatNumber(price1,num_dot_xs,-1,0,0)
			Response.write """ type=""text"" value="""
			Response.write """ " & vbcrlf & "            onfocus=if(this.value==this.defaultValue){this.value='';this.style.color='#000'} " & vbcrlf & "            onBlur=if(!this.value){this.value=this.defaultValue;this.style.color='#000';chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);} " & vbcrlf & "            onkeyup=this.value=this.value.replace(/[^\d\.]/g,'');checkDot('pricetest"
			Response.write id
			Response.write "','"
			Response.write num_dot_xs
			Response.write "') " & vbcrlf & "            onpropertychange=chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this); " & vbcrlf & "            style=""height:19px;width:40px;solid;font-size:9pt;text-align:right;"" " & vbcrlf & "            dataType=""Range"" msg=""必须填写单价"" min=""-99999999999"" max=""999999999999""" & vbcrlf & "            /> " & vbcrlf & "            <img src=""../images/112.png""  onmouseover=callServer2('test"
			Response.write id
			Response.write "','"
			Response.write ord
			Response.write "','"
			Response.write id
			Response.write "'); " & vbcrlf & "            onmouseout=callServer6('test"
			Response.write id
			Response.write "','"
			Response.write ord
			Response.write "','"
			Response.write id
			Response.write "') border=0 style=""cursor:hand"">" & vbcrlf & "            <span id=""tttest"
			Response.write id
			Response.write """  style=""position:absolute;margin-left:0;""></span>" & vbcrlf & "            </div>" & vbcrlf & "            </td>" & vbcrlf & "            "
			Response.write id
			case "num1"
			Response.write "" & vbcrlf & "            <td width="""
			Response.write kd
			Response.write """ class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """><div align=""center"">" & vbcrlf & "            <input Name=""num1_"
			Response.write id
			Response.write """ id=""num"
			Response.write id
			Response.write """ type=""text"" value="""
			Response.write FormatNumber(num1,num1_dot,-1,0,0)
			Response.write """ type=""text"" value="""
			Response.write """ " & vbcrlf & "            onfocus=if(this.value==this.defaultValue){this.value='';this.style.color='#000'} " & vbcrlf & "            onBlur=if(!this.value){this.value=this.defaultValue;this.style.color='#000';chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);}  onkeyup=this.value=this.value.replace(/[^\d\.]/g,'');checkDot('num"
			Response.write id
			Response.write "','"
			Response.write num1_dot
			Response.write "');eval('moneyjyall_"
			Response.write id
			Response.write "').value=FormatNumber(value*eval('pricejy_"
			Response.write id
			Response.write "').value,"
			Response.write num_dot_xs
			Response.write "); " & vbcrlf & "            onpropertychange=chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this); " & vbcrlf & "            style=""height:19px;solid;font-size:9pt;width:30px"" " & vbcrlf & "            dataType=""Limit"" min=""1"" max=""100""  msg=""不能为空""" & vbcrlf & "            />" & vbcrlf & "            "
			Response.write jf
			if ZBRuntime.MC(17000) then
				Response.write "" & vbcrlf & "            <img src=""../images/116.png"" onmouseover=callServer5('ttttest"
				Response.write id
				Response.write "','test"
				Response.write id
				Response.write "','"
				Response.write ord
				Response.write "','"
				Response.write id
				Response.write "',this);  onmouseout=callServer6('ttttest"
				Response.write id
				Response.write "','test"
				Response.write id
				Response.write "','"
				Response.write ord
				Response.write "','"
				Response.write id
				Response.write "') border=0 style=""cursor:hand"">" & vbcrlf & "            "
			end if
			Response.write "" & vbcrlf & "            <span id=""ttttest"
			Response.write id
			Response.write """  style=""position:absolute;margin-left:0;""></span></div>" & vbcrlf & "            </td>" & vbcrlf & "            <td class=""dataCell inputCell"" width=""100"" style="""
			Response.write id
			Response.write strDisplay
			Response.write """>" & vbcrlf & "            <table border=0 width=""100"" cellspacing=0 cellpadding=0>" & vbcrlf & "            <tr>" & vbcrlf & "            <td width=""80"" style=""padding:0;background-color:transparent"" valign=""middle"">" & vbcrlf & "            "
			Response.write strDisplay
			ckname = ""
			if proStore=1 then
				sql1="select b.id,b.sort1 from jiage a inner join sortck b on a.MainStore=b.id and a.product="&ord&" and b.del=1 and a.bm=0 and a.unit="&unitjb&" and (cast(b.intro as varchar(8000))='0' or charindex(',"&session("personzbintel2007")&",',','+cast(b.intro as varchar(8000))+',')>0)"
'if proStore=1 then
				set rsstore=conn.execute(sql1)
				if not rsstore.eof then
					ckid=rsstore(0)
					ck=rsstore(0)
					ckname=rsstore(1)
				else
					ckid=""
					ck=""
					ckname=""
				end if
				rsstore.close
			end if
			if defck_open=1 then
				if tp<>"" then
					sorttype=204
				else
					sorttype=104
				end if
				sql1="select a.ord,a.sort1 from sortck a inner join UserStoreBinding b on b.sort="&sorttype&" and a.ord=b.StoreID "&_
				"and b.userid="&session("personzbintel2007")&_
				" and b.ProductID="&ord&" and b.Unit="&unitjb&" and a.ord in "&_
				"(select StoreID from ("&_
				"SELECT top 1 MainStore as StoreID FROM jiage WHERE product="&ord&" and unit="&unitjb&_
				"union "&_
				"select StoreID from ProductStoreBinding WHERE ProductID="&ord&" and unit="&unitjb&_
				") bb) and (cast(a.intro as varchar(8000))='0' or charindex(',"&session("personzbintel2007")&",',','+cast(a.intro as varchar(8000))+',')>0)"
'select StoreID from ProductStoreBinding WHERE ProductID=&ord& and unit=&unitjb&_
				set rsstore=conn.execute(sql1)
				if not rsstore.eof then
					ckid=rsstore(0)
					ck=rsstore(0)
					ckname=rsstore(1)
				end if
				rsstore.close
			end if
			if  isnumeric(ck) then
				if ck > 0 and ckname<>"" then
					set ckrs = conn.execute("select sort1 from sortck where ord=" & ck)
					if ckrs.eof = false then
						ckname = ckrs.fields(0).value
					end if
					ckrs.close
				end if
			end if
			list = "<input type='hidden' name='ck_"& id &"' id='ck"&i&"' text='" & ckname & "' value='" & ckid & "' onChange=ckxz6('"&ord&"','"&i&"','"&id&"','trpx"&(i-1)&"_"&id&"','2');  dataType='Limit' min='1' max='100' msg='请选择仓库'>" & _
			"<div style='float:left;'><input title=' & ckname & ' style='float:left;' id='for_ck&i&' type='button' class='storeButton' value="
			Response.write list
			Response.write "" & vbcrlf & "            </td>" & vbcrlf & "                    " & vbcrlf & "            <td width=""20"" style=""padding:0;background-color:transparent"" valign=""middle"">" & vbcrlf & "            "
			Response.write list
			list ="<img  style='cursor:pointer;' src='../images/11645.png' onclick=""showStoreDlg('ck"&i&"'," & ord & "," & unit & ")"">"
			Response.write list
			Response.write "" & vbcrlf & "            </td>" & vbcrlf & "            </tr>" & vbcrlf & "            </table>" & vbcrlf & "            "
			kcxz=""
			set rs0=server.CreateObject("adodb.recordset")
			if sort1=1 or (sort1=2 and ck&""<>"0") then
				sql="select sum(num2) as num1,ck,unit from ku  where ord="&ord&" and ck="&ck&" group by ck,unit having sum(num2)>0 order by ck asc"
			else
				sql="select sum(num2) as num1,ck,unit from ku where ord="&ord&" and ck in (select id from sortck where del=1 and (intro like '"&session("personzbintel2007")&",%' or intro like '%,"&session("personzbintel2007")&",%' or intro like '%, "&session("personzbintel2007")&",%' or intro like '%, "&session("personzbintel2007")&"'  or intro like '%,"&session("personzbintel2007")&"' or intro like '"&session("personzbintel2007")&"' or intro like '0'))   group by ck,unit having sum(num2)>0 order by ck asc"
			end if
			rs0.open sql,conn,1,1
			if rs0.RecordCount>0 then
				set rs7=server.CreateObject("adodb.recordset")
				set rs8=server.CreateObject("adodb.recordset")
				do until rs0.eof
					num_kc2=rs0("num1")
					unit2=rs0("unit")
					ck2=rs0("ck")
					if unit2="" then unit2=0
					sql7="select sort1 from sortonehy where id="&unit2&""
					rs7.open sql7,conn,1,1
					if rs7.eof then
						unit2name=""
					else
						unit2name=rs7("sort1")
					end if
					rs7.close
					sql7="select sort1,sort from sortck where del=1 and ord="&ck2&""
					rs7.open sql7,conn,1,1
					if rs7.eof then
						ckname=""
						ck1name=""
					else
						ckname=rs7("sort1")
						sql8="select sort1 from sortck1 where del=1 and id="&rs7("sort")&""
						rs8.open sql8,conn,1,1
						if rs8.eof then
							ck1name=""
						else
							ck1name=rs8("sort1")
						end if
						rs8.close
					end if
					rs7.close
					if clng(unit)=unit2 then
						kcxz=kcxz+"<span style='color:#5b7cae'>"
'if clng(unit)=unit2 then
						kcxz=kcxz+""&ck1name&"->"&ckname&"</span> <font class='red'><b>"& num_kc2&" "&unit2name&"</b></font>"
'if clng(unit)=unit2 then
						kcxz=kcxz+"<br>"
'if clng(unit)=unit2 then
					else
						kcxz=kcxz+"<span style='color:#5b7cae'>"&ck1name&"->"&ckname&" "&num_kc2&" "&unit2name&"</span>"
'if clng(unit)=unit2 then
						kcxz=kcxz+"&nbsp;<a href='javascript:void(0)' onclick=javascript:window.open('../store/ku_unit.asp?funindex=32&ord="&ord&"&unit="&unit&"&id="&id&"&ck="&ck&"&ck2="&ck2&"','newwin23','width='+800+',height='+400+',toolbar=0,scrollbars=1,resizable=1,left=100,top=100');><img src='../images/jiantou.gif' border='0' alt='选择'>拆分</a><br>"
					end if
					if num_kclimit="" then num_kclimit=0
					rs0.movenext
				loop
				set rs7=nothing
				set rs8=nothing
			end if
			rs0.close
			set rs0=nothing
			if kcxz="" then kcxz="没有库存！"
			Response.write("<span id='trpx"&"_"&id&"'></span>")
			Response.write "" & vbcrlf & "            </td>" & vbcrlf & "            <td  width='200' class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """><span id='ck2xz_"
			Response.write id
			Response.write "'>"
			Response.write kcxz
			Response.write "</span></td>" & vbcrlf & "            <td  width='150' class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "            <input type='radio' name='way1_"
			Response.write id
			Response.write "' onclick=del_zd('"
			Response.write id
			Response.write "'); value='1' checked/>随机&nbsp;" & vbcrlf & "            <input type='radio' name='way1_"
			Response.write id
			Response.write "' value='2' " & vbcrlf & "            onclick=""if(check_ckxz2('"
			Response.write i
			Response.write "')) window.open('../store/ku_select_kd.asp?ord="
			Response.write ord
			Response.write "&unit="
			Response.write unit
			Response.write "&id="
			Response.write id
			Response.write "&ck=' + getcurrck("
			Response.write id
			Response.write id
			Response.write ") +'&num1=' + getcurrnum1("
			Response.write id
			Response.write id
			Response.write ") + '&contractlist="
			Response.write id
			Response.write contractlist
			Response.write "&kuout="
			Response.write top
			Response.write "&kuoutlist="
			Response.write kuoutlist
			Response.write "&sort_ck=4','newwin23','width='+900+',height='+400+',toolbar=0,scrollbars=1,resizable=1,left=50,top=100');""/>指定" & vbcrlf & "            <span id='zdkc"
			Response.write kuoutlist
			Response.write id
			Response.write "'></span>" & vbcrlf & "            </td>" & vbcrlf & "            "
			case "money1"
			Response.write "" & vbcrlf & "            <td width="""
			Response.write kd
			Response.write """ class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "            <input name=""moneyall_"
			Response.write id
			Response.write """ id=""moneyall"
			Response.write id
			Response.write """ type=""text""  value="""
			Response.write Replace(money1,",","")
			Response.write """ readonly style=""width:100%;color:#666666;border: #CCCCCC 1px solid;text-align:right;"" dataType=""Range"" min=""0"" msg=""不能小于0""/>" & vbcrlf & "            </td>" & vbcrlf & "            "
			Response.write Replace(money1,",","")
			case "date2"
			Response.write "" & vbcrlf & "            <td align=""center"" width="""
			Response.write kd
			Response.write """ class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "            <INPUT name=""date1_"
			Response.write id
			Response.write """  id=""daysdate1_"
			Response.write id
			Response.write "Pos"" " & vbcrlf & "            style=""height:19px;solid;font-size:9pt;width:65"" " & vbcrlf & "            onmouseup=toggleDatePicker('daysdate1_"
			Response.write id
			Response.write id
			Response.write "','date.date1_"
			Response.write id
			Response.write "')  " & vbcrlf & "            dataType=""Date"" format=""ymd""  msg=""日期格式不正确""" & vbcrlf & "            />" & vbcrlf & "            <DIV id='daysdate1_"
			Response.write id
			Response.write "' style='POSITION: absolute'></DIV>" & vbcrlf & "            </td>" & vbcrlf & "            "
			case "intro"
			Response.write "" & vbcrlf & "            <td align=""center"" width="""
			Response.write kd
			Response.write """ class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "            <textarea rows=""1"" id=""intro_"
			Response.write id
			Response.write """ name=""intro_"
			Response.write id
			Response.write """ style=""overflow-y:hidden;word-break:break-all;width:100%"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight""  dataType=""Limit"" min=""0"" max=""2000"" msg=""不要超过2000个字""></textarea>" & vbcrlf & "            </td>" & vbcrlf & "  "
			case "pricejy"
			Response.write "" & vbcrlf & "            <td width="""
			Response.write kd
			Response.write """ class=""dataCell inputCell"" align=""center"" style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "            <input id=""pricejy"
			Response.write id
			Response.write """ dataType=""Range"" min=""0"" max=""999999999999.9999"" msg=""金额必须在0-999999999999.9999""" & vbcrlf & "            maxlength=""20"" name=""pricejy_"
			Response.write id
			Response.write id
			Response.write """" & vbcrlf & "            onblur=""if(!this.value){this.value=this.defaultValue;this.style.color='#000'}"" " & vbcrlf & "            onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'}"" " & vbcrlf & "            onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('pricejy"
			Response.write id
			Response.write "','"
			Response.write num_dot_xs
			Response.write "');eval('moneyjyall_"
			Response.write id
			Response.write "').value=FormatNumber(value*eval('num1_"
			Response.write id
			Response.write "').value,"
			Response.write num_dot_xs
			Response.write ");"" size=""7""" & vbcrlf & "            onpropertychange =""$('#moneyjyall"
			Response.write id
			Response.write "').val(FormatNumber($('#pricejy"
			Response.write id
			Response.write "').val()*$('#num"
			Response.write id
			Response.write "').val(),"
			Response.write num_dot_xs
			Response.write "));""" & vbcrlf & "            style=""height: 19px; solid;font-size: 9pt;text-align:right;"" type=""text"" " & vbcrlf & "            value="""
			Response.write num_dot_xs
			Response.write pricejy
			Response.write """ /></td>" & vbcrlf & "            "
			case "tpricejy"
			If pricejy&""="" Then pricejy = 0
			If num1 &""="" Then num1 = 0
			Response.write "" & vbcrlf & "            <td width="""
			Response.write kd
			Response.write """ class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center""><input name=""moneyjyall_"
			Response.write id
			Response.write """ readonly id=""moneyjyall"
			Response.write id
			Response.write """ value="""
			Response.write cdbl(pricejy)*cdbl(num1)
			Response.write """ type=""text"" size=""7"" style=""color: #666666;border: #CCCCCC 1px solid;text-align:right;"" onKeyUp=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('moneyjyall"
			Response.write cdbl(pricejy)*cdbl(num1)
			Response.write id
			Response.write "','"
			Response.write num_dot_xs
			Response.write "');""></td>" & vbcrlf & "            "
			case "discount"
			Response.write "" & vbcrlf & "            <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """>" & vbcrlf & "            <input type=""text"" name=""discount_"
			Response.write id
			Response.write """ id=""discount_"
			Response.write id
			Response.write """ " & vbcrlf & "            value="""
			Response.write FormatNumber(discount,DISCOUNT_DOT_NUM,-1,0,0)
			Response.write """ " & vbcrlf & "            value="""
			Response.write """ " & vbcrlf & "            style=""width:90%;text-align:right"" " & vbcrlf & "            onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'}"" " & vbcrlf & "            onBlur=if(!this.value){this.value=this.defaultValue;this.style.color='#000';chtotal("
			Response.write """ " & vbcrlf & "            value="""
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this)} " & vbcrlf & "            onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('discount_"
			Response.write id
			Response.write "','"
			Response.write DISCOUNT_DOT_NUM
			Response.write "');""" & vbcrlf & "            msg=""折扣必须控制在0-"
			Response.write DISCOUNT_DOT_NUM
			Response.write FormatNumber(DISCOUNT_MAX_VALUE,DISCOUNT_DOT_NUM,-1,0,0)
			Response.write DISCOUNT_DOT_NUM
			Response.write "之间"" dataType=""Range"" min=""0"" max="""
			Response.write DISCOUNT_MAX_VALUE
			Response.write """ " & vbcrlf & "            onpropertychange=""chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this)""" & vbcrlf & "            msgWhenHide=""折扣必须控制在0-"
			Response.write jf
			Response.write FormatNumber(DISCOUNT_MAX_VALUE,DISCOUNT_DOT_NUM,-1,0,0)
			Response.write jf
			Response.write "之间（请联系管理员在明细自定义中开启该字段）"" " & vbcrlf & "            />" & vbcrlf & "            <input type=""hidden"" name=""discountValue_"
			Response.write id
			Response.write """ id=""discountValue_"
			Response.write id
			Response.write """ value="""
			Response.write discount
			Response.write """/>" & vbcrlf & "            </td>" & vbcrlf & "            "
			case "priceAfterDiscount"
			Response.write "" & vbcrlf & "            <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write me.getFieldWidth(19)
			Response.write """>" & vbcrlf & "            <input type=""text"" name=""priceAfterDiscount_"
			Response.write id
			Response.write """ id=""priceAfterDiscount_"
			Response.write id
			Response.write """ " & vbcrlf & "            value="""
			Response.write FormatNumber(priceAfterDiscount,num_dot_xs,-1,0,0)
			Response.write """ " & vbcrlf & "            value="""
			Response.write """ " & vbcrlf & "            onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'}"" " & vbcrlf & "            onBlur=if(!this.value){this.value=this.defaultValue;this.style.color='#000';chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);} " & vbcrlf & "            onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('priceAfterDiscount_"
			Response.write id
			Response.write "','"
			Response.write num_dot_xs
			Response.write "');""" & vbcrlf & "            style=""width:90%;text-align:right"" dataType=""Range"" msg=""低于限价"" min="""
			Response.write num_dot_xs
			Response.write price1_limit
			Response.write """ max=""999999999999"" " & vbcrlf & "            msgWhenHide = ""未税折后单价低于限价（请联系管理员在明细自定义中开启该字段）""" & vbcrlf & "            onpropertychange=""chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);""" & vbcrlf & "            />" & vbcrlf & "            <img src=""../images/112.png"" onmouseover=""showPrice("
			Response.write id
			Response.write ","
			Response.write ord
			Response.write ");"" " & vbcrlf & "            onmouseout=""jQuery('#info_show_div').hide();"" border=0 style=""cursor:hand"">" & vbcrlf & "            </td>" & vbcrlf & "            "
			case "invoiceType"
			sql="select * from ("&_
			"select a.id,a.sort1,b.taxRate,b.priceFormula,b.priceBeforeTaxFormula,(case when a.id="&iType&" then 0 else 1 end) as topRow,a.gate1 from sortonehy a inner join invoiceConfig b on a.id=b.typeid where gate2 = 34 and isStop=0 and isnull(id1,0)<>-65535 and a.id in ("&invoiceTypes&")"&_
			"union all ("&_
			"select 0,'不开票',taxRate,priceFormula,priceBeforeTaxFormula,(case when "&iType&"=0 then 0 else 1 end) as topRow,-9999999 from sortonehy a,invoiceConfig b where a.id=b.typeid and isnull(a.id1,0)=-65535"&_
			"union all ("&_
			")"&_
			") bb order by topRow,gate1 desc "
			Response.write "" & vbcrlf & "            <td class=""dataCell inputCell"" align=""center"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "            <select name=""invoiceType_"
			Response.write id
			Response.write """ id=""invoiceType_"
			Response.write id
			Response.write """ includeTax="""
			Response.write includeTax
			Response.write """ onchange=""changeInvoice("
			Response.write id
			Response.write ");"">" & vbcrlf & "            "
			Set rsInvoice=conn.execute(sql)
			While rsInvoice.eof = false
				Response.write "" & vbcrlf & "            <option value="""
				Response.write rsInvoice(0)
				Response.write """ taxRate="""
				Response.write FormatNumber(rsInvoice(2),num_dot_xs,-1,0,0)
				Response.write """ taxRate="""
				Response.write """ formula="""
				Response.write rsInvoice(3)
				Response.write """ formula2="""
				Response.write rsInvoice(4)
				Response.write """>"
				Response.write rsInvoice(1)
				Response.write "</option>    " & vbcrlf & "            "
				rsInvoice.movenext
			wend
			rsInvoice.close
			Set rsInvoice = nothing
			Response.write "" & vbcrlf & "            </select>" & vbcrlf & "            </td>" & vbcrlf & "            "
			case "taxRate"
			Response.write "" & vbcrlf & "            <td class=""dataCell inputCell"" align=""center"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "            <input type=""text"" name=""taxRate_"
			Response.write id
			Response.write """ id=""taxRate_"
			Response.write id
			Response.write """ value="""
			Response.write FormatNumber(taxRate,num_dot_xs,-1,0,0)
			Response.write """ value="""
			Response.write """ " & vbcrlf & "            style=""width:60%;text-align:right"" " & vbcrlf & "            msg=""只能输入0到1000之间的数字"" dataType=""Range"" min=""0"" max=""1000"" " & vbcrlf & "            onBlur=""if(!this.value){this.value=this.defaultValue;this.style.color='#000';chtotal("
			Response.write """ value="""
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);}""" & vbcrlf & "            onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('taxRate_"
			Response.write id
			Response.write "','"
			Response.write num_dot_xs
			Response.write "');""" & vbcrlf & "            onpropertychange=""chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);""" & vbcrlf & "            />%" & vbcrlf & "            </td>" & vbcrlf & "            "
			case "priceAfterTax"
			Response.write "" & vbcrlf & "            <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """>" & vbcrlf & "            <input type=""text"" name=""priceAfterTax_"
			Response.write id
			Response.write """ id=""priceAfterTax_"
			Response.write id
			Response.write """ value="""
			Response.write FormatNumber(priceAfterTax,num_dot_xs,-1,0,0)
			Response.write """ value="""
			Response.write """" & vbcrlf & "            onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'}"" " & vbcrlf & "            onBlur=""if(!this.value){this.value=this.defaultValue;this.style.color='#000';chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this)}""" & vbcrlf & "            onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('priceAfterTax_"
			Response.write id
			Response.write "','"
			Response.write num_dot_xs
			Response.write "');""" & vbcrlf & "            onpropertychange=""chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this)""" & vbcrlf & "            dataType=""Range"" msg=""必须填写"" min=""-99999999999"" max=""999999999999"" " & vbcrlf & "            style=""width:90%;text-align:right""/>" & vbcrlf & "            <img src=""../images/112.png"" onmouseover=""showPrice("
			Response.write jf
			Response.write id
			Response.write ","
			Response.write ord
			Response.write ");"" " & vbcrlf & "            onmouseout=""jQuery('#info_show_div').hide();"" border=0 style=""cursor:hand"">" & vbcrlf & "            </td>" & vbcrlf & "            "
			case "taxValue"
			Response.write "" & vbcrlf & "            <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """>" & vbcrlf & "            <input type=""text"" name=""taxValue_"
			Response.write id
			Response.write """ id=""taxValue_"
			Response.write id
			Response.write """ readonly value="""
			Response.write FormatNumber(taxValue,num_dot_xs,-1,0,0)
			Response.write """ readonly value="""
			Response.write """ style=""width:90%;color:#666666;border: #CCCCCC 1px solid;text-align:right""/>" & vbcrlf & "            </td>" & vbcrlf & "            "
			Response.write """ readonly value="""
			case "moneyBeforeTax"
			Response.write "" & vbcrlf & "            <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """>" & vbcrlf & "            <input type=""text"" name=""moneyBeforeTax_"
			Response.write id
			Response.write """ id=""moneyBeforeTax_"
			Response.write id
			Response.write """ readonly value="""
			Response.write FormatNumber(moneyBeforeTax,num_dot_xs,-1,0,0)
			Response.write """ readonly value="""
			Response.write """ style=""width:90%;color:#666666;border: #CCCCCC 1px solid;text-align:right""/>" & vbcrlf & "            </td>" & vbcrlf & "            "
			Response.write """ readonly value="""
			case "moneyAfterTax"
			Response.write "" & vbcrlf & "            <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """>" & vbcrlf & "            <input type=""text"" name=""moneyAfterTax_"
			Response.write id
			Response.write """ id=""moneyAfterTax_"
			Response.write id
			Response.write """ readonly value="""
			Response.write FormatNumber(moneyAfterTax,num_dot_xs,-1,0,0)
			Response.write """ readonly value="""
			Response.write """ style=""width:90%;color:#666666;border: #CCCCCC 1px solid;text-align:right""/>" & vbcrlf & "            </td>" & vbcrlf & "            "
			Response.write """ readonly value="""
			case "concessions"
			Response.write "" & vbcrlf & "            <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """>" & vbcrlf & "            <input type=""text"" name=""concessions_"
			Response.write id
			Response.write """ id=""concessions_"
			Response.write id
			Response.write """ value="""
			Response.write FormatNumber(concessions,num_dot_xs,-1,0,0)
			Response.write """ value="""
			Response.write """ " & vbcrlf & "            onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'}"" " & vbcrlf & "            onBlur=""if(!this.value){this.value=this.defaultValue;this.style.color='#000';chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);}""" & vbcrlf & "            onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('concessions_"
			Response.write id
			Response.write "','"
			Response.write num_dot_xs
			Response.write "');""" & vbcrlf & "            onpropertychange=""chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);""" & vbcrlf & "            dataType=""Range"" msg=""必须填写"" min=""-99999999999"" max=""999999999999"" " & vbcrlf & "            style=""width:90%;text-align:right""/>" & vbcrlf & "            </td>" & vbcrlf & "            "
			Response.write jf
			case "priceIncludeTax"
			Response.write "" & vbcrlf & "            <td class=""dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """ align=""center"" width="""
			Response.write kd
			Response.write """>" & vbcrlf & "            <input type=""text"" name=""priceIncludeTax_"
			Response.write id
			Response.write """ id=""priceIncludeTax_"
			Response.write id
			Response.write """ value="""
			Response.write FormatNumber(priceIncludeTax,num_dot_xs,-1,0,0)
			Response.write """ value="""
			Response.write """ " & vbcrlf & "            onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'}"" " & vbcrlf & "            onBlur=""if(!this.value){this.value=this.defaultValue;this.style.color='#000';chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);}"" " & vbcrlf & "            onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('priceIncludeTax_"
			Response.write id
			Response.write "','"
			Response.write num_dot_xs
			Response.write "');"" " & vbcrlf & "            onpropertychange=""chtotal("
			Response.write id
			Response.write ","
			Response.write num_dot_xs
			Response.write ","
			Response.write jf
			Response.write ",this);"" " & vbcrlf & "            dataType=""Range"" msg=""必须填写"" min=""-999999999999"" max=""999999999999"" " & vbcrlf & "            style=""width:90%;text-align:right""/>" & vbcrlf & "            <img src=""../images/112.png"" onmouseover=""showPrice("
			Response.write jf
			Response.write id
			Response.write ","
			Response.write ord
			Response.write ");"" " & vbcrlf & "            onmouseout=""jQuery('#info_show_div').hide();"" border=0 style=""cursor:hand"">" & vbcrlf & "            </td>" & vbcrlf & "            "
			case else
			dim listid : listid= oldcontractlist
			if listid = 0 then listid = -ord
'dim listid : listid= oldcontractlist
			zdytext = NewMxZDYLoad(conn ,11001 , 1 , top,  listid , InheritId)
			select case UiType
			case 0, 10 , 13 :
			Response.write "" & vbcrlf & "                <td class=""dataCell inputCell"" align=""center"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "                <textarea name="""
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write """ rows=""1"" id="""
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write """  style=""overflow-y:hidden;word-break:break-all;width:100%;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight""  datatype=""Limit"" min=""0"" max=""2000"" msg=""不要超过2000个字"">"
			Response.write id
			Response.write replace(zdytext&"","<br>",chr(10))
			Response.write "</textarea>" & vbcrlf & "                </td>" & vbcrlf & "                "
			case 1 :
			if isdate(zdytext)=false then zdytext = ""
			Response.write "" & vbcrlf & "                <td align=""center"" width="""
			Response.write kd
			Response.write """ class=""name dataCell inputCell"" style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "                <INPUT name="""
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write """  id=""days"
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write "Pos"" value="""
			Response.write zdytext
			Response.write """ style=""width:80px;height: 19px; solid;font-size: 9pt;"" " & vbcrlf & "                    onmouseup=""toggleDatePicker('days"
			Response.write zdytext
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write "','date."
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write "')"" dataType=""Date"" format=""ymd"" msg=""日期格式不正确""/>" & vbcrlf & "                <DIV id='days"
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write "' style='POSITION: absolute'></DIV></td>" & vbcrlf & "                "
			case 2 :
			if isnumeric(zdytext)=false then zdytext = "0"
			Response.write "" & vbcrlf & "                <td class=""name dataCell inputCell"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """><div align=""center"">" & vbcrlf & "                <input Name="""
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write """ maxlength=""20"" id="""
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write """ type=""text"" value="""
			Response.write FormatNumber(zdytext,num1_dot,-1,0,0)
			Response.write """ type=""text"" value="""
			Response.write """ " & vbcrlf & "                style=""width:50px;height: 19px; solid;font-size: 9pt;width:50px"" " & vbcrlf & "                onfocus=""if(this.value==this.defaultValue){this.value='';this.style.color='#000'};"" " & vbcrlf & "                onBlur=""if(!this.value){this.value=this.default Value;this.style.color='#000';};checkDot('"
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write "','"
			Response.write num1_dot
			Response.write "')"" " & vbcrlf & "                onkeyup=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('"
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write "','"
			Response.write num1_dot
			Response.write "');"" />" & vbcrlf & "                </td>" & vbcrlf & "                "
			case 4 :
			Response.write "" & vbcrlf & "                <td align=""center"" class=""name dataCell inputCell"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "                <select name="""
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write """>" & vbcrlf & "                <option value=""是"" "
			if "是"=zdytext&"" then
				Response.write "selected"
			end if
			Response.write ">是</option>" & vbcrlf & "                <option value=""否"" "
			if "否"=zdytext&"" then
				Response.write "selected"
			end if
			Response.write ">否</option>" & vbcrlf & "                </select>" & vbcrlf & "                </td>" & vbcrlf & "                "
			case 5:
			Response.write "" & vbcrlf & "                <td align=""center"" class=""name dataCell inputCell"" width="""
			Response.write kd
			Response.write """ style="""
			Response.write strDisplay
			Response.write """>" & vbcrlf & "                <select name="""
			Response.write sorce
			Response.write "_"
			Response.write id
			Response.write """>" & vbcrlf & "                "
			set rs7=server.CreateObject("adodb.recordset")
			sql7="select id as ord, text as sort1 from sys_sdk_BillFieldOptionsSource where fieldid ="& InHeritID &" order by showindex "
			rs7.open sql7,conn,1,1
			do until rs7.eof
				Response.write "" & vbcrlf & "                <option value="""
				Response.write rs7("ord")
				Response.write """ "
				if rs7("sort1")&""=zdytext&"" then
					Response.write "selected"
				end if
				Response.write ">"
				Response.write rs7("sort1")
				Response.write "</option>" & vbcrlf & "                "
				rs7.movenext
			loop
			rs7.close
			set rs7=nothing
			Response.write "" & vbcrlf & "                </select>" & vbcrlf & "                </td>" & vbcrlf & "                "
			end select
			end select
		end sub
	End Class
	Public Function getProductPrices(priceValue,includeTax,invoiceType)
		Dim pricesFun(2),rsFun,sqlFun
		pricesFun(0) = priceValue
		pricesFun(1) = priceValue
		pricesFun(2) = priceValue
		getProductPrices = pricesFun
		If Len(Trim(invoiceType)&"")="0" Or invoiceType = 0 then
			sqlFun = "select b.* from sortonehy a,invoiceConfig b where b.typeid=a.id and a.gate2=34 and a.id1=-65535"
'If Len(Trim(invoiceType)&"")="0" Or invoiceType = 0 then
		else
			sqlFun = "select b.* from sortonehy a,invoiceConfig b where b.typeid=a.id and a.id =" & invoiceType
		end if
		Set rsFun = conn.execute(sqlFun)
		If rsFun.eof =False Then
			If includeTax = 1 Then
				pricesFun(1) = priceValue
				pricesFun(0) = eval(Replace(Replace(rsFun("priceBeforeTaxFormula"),"{含税单价}",CDbl(priceValue)),"{税率}",rsFun("taxRate")&"/100"))
			Else
				pricesFun(0) = priceValue
				pricesFun(1) = eval(Replace(Replace(rsFun("priceFormula"),"{未税单价}",CDbl(priceValue)),"{税率}",rsFun("taxRate")&"/100"))
			end if
			pricesFun(2) = rsFun("taxRate")
		end if
		rsFun.close
		getProductPrices = pricesFun
	end function
	function NewMxZDYSql(billType , listType , isUsed , existsSql)
		dim sql , msql
		select case billType
		case 11001:
		msql =  "    union all select '产品名称', 'InheritId_self_title',  0, 1,0,1,1,1,0 , 'title' ,140, 'title' "&_
		"    union all select '编号', 'InheritId_self_order1',  0, 2,0,0,1,1,0, 'order1',60, 'order1' "&_
		"    union all select '型号', 'InheritId_self_type1',  0, 3,0,0,1,1,0, 'type1',60, 'type1' "&_
		"    union all select '单位', 'InheritId_self_unit',  0, 4,0,1,1,1,0, 'unit',60, 'unit' "&_
		"    union all select '数量', 'InheritId_self_num1',  0, 5,0,1,1,1,0, 'num1',80, 'num1' "&_
		"    union all select '未税单价', 'InheritId_self_price1',  0, 6,0,0,1,1,0, 'price1',80, 'price1' "&_
		"    union all select '折扣', 'InheritId_self_discount',  0, 7,0,0,1,1,0, 'discount',70 , 'discount' "&_
		"    union all select '折后单价', 'InheritId_self_priceAfterDiscount',  0, 8,0,0,1,1,0, 'priceAfterDiscount',80, 'priceAfterDiscount' "&_
		"    union all select '含税单价', 'InheritId_self_priceIncludeTax',  0, 9,0,0,1,1,0, 'priceIncludeTax',80, 'priceIncludeTax' "&_
		"    union all select '含税折后单价', 'InheritId_self_priceAfterTaxPre',  0, 10,0,0,1,1,0, 'priceAfterTaxPre',80, 'priceAfterTaxPre' "&_
		"    union all select '票据类型', 'InheritId_self_invoiceType',  0, 11,0,0,1,1,0, 'invoiceType',80 , 'invoiceType'"&_
		"    union all select '税率', 'InheritId_self_taxRate',  0, 12,0,0,1,1,0, 'taxRate' ,70, 'taxRate' "&_
		"    union all select '税后总价', 'InheritId_self_moneyAfterTax',  0, 13,0,0,1,1,0, 'moneyAfterTax',80, 'moneyAfterTax' "&_
		"    union all select '明细优惠', 'InheritId_self_concessions',  0, 14,0,0,1,1,0, 'concessions',80, 'concessions' "&_
		"    union all select '优惠后单价', 'InheritId_self_priceAfterTax',  0, 15,0,0,1,1,0, 'priceAfterTax',80 , 'priceAfterTax'"&_
		"    union all select '金额', 'InheritId_self_moneyAfterConcessions',  0, 16,0,0,1,1,0, 'moneyAfterConcessions',80 , 'moneyAfterConcessions'"&_
		"    union all select '税额', 'InheritId_self_taxValue',  0, 17,0,0,1,1,0, 'taxValue',80 , 'taxValue' "&_
		"    union all select '优惠后总价', 'InheritId_self_money1',  0, 17,0,1,1,1,0, 'money1',80, 'money1' "&_
		"    union all select '建议进价', 'InheritId_self_pricejy',  0, 18,0,1,1,1,0, 'pricejy' ,80 , 'pricejy' "&_
		"    union all select '建议总价', 'InheritId_self_tpricejy',  0, 19,0,1,1,1,0, 'tpricejy',80, 'tpricejy' "&_
		"    union all select '交货日期', 'InheritId_self_date2',  0, 20,0,0,1,1,0, 'date2',80 , 'date2' "&_
		"    union all select '备注', 'InheritId_self_intro',  0, 21,0,0,1,1,0, 'intro',85 , 'intro' "
		case 62001:
		msql =  "    union all select '产品名称', 'InheritId_self_title',  0, 1,0,1,1,1,0 , 'title' ,80, 'title' "&_
		"    union all select '产品编号', 'InheritId_self_order1',  0, 2,0,0,1,1,0, 'order1',80, 'order1' "&_
		"    union all select '产品型号', 'InheritId_self_type1',  0, 3,0,0,1,1,0, 'type1',80, 'type1' "&_
		"    union all select '单位', 'InheritId_self_unit',  0, 4,0,1,1,1,0, 'unit',80, 'unit' "&_
		"    union all select '数量', 'InheritId_self_num1',  0, 5,0,1,1,1,0, 'num1',80, 'num1' "&_
		"    union all select '到货日期', 'InheritId_self_date2',  0, 6,0,0,1,1,0, 'date2',80, 'date2' "&_
		"    union all select '备注', 'InheritId_self_intro',  0, 7,0,0,1,1,0, 'intro',120 , 'intro' "
		case 73001:
		msql =  "    union all select '产品名称', 'InheritId_self_title',  0, 1,0,1,1,1,0 , 'title' ,140, 'title' "&_
		"    union all select '编号', 'InheritId_self_order1',  0, 2,0,0,1,1,0, 'order1',60, 'order1' "&_
		"    union all select '型号', 'InheritId_self_type1',  0, 3,0,0,1,1,0, 'type1',60, 'type1' "&_
		"    union all select '单位', 'InheritId_self_unit',  0, 4,0,1,1,1,0, 'unit',60, 'unit' "&_
		"    union all select '数量', 'InheritId_self_num1',  0, 5,0,1,1,1,0, 'num1',80, 'num1' "&_
		"    union all select '未税单价', 'InheritId_self_price1',  0, 6,0,0,1,1,0, 'price1',80, 'price1' "&_
		"    union all select '折扣',     'InheritId_self_discount',  0, 7,0,0,1,1,0, 'discount',70 , 'discount' "&_
		"    union all select '折后单价', 'InheritId_self_priceAfterDiscount',  0, 8,0,0,1,1,0, 'priceAfterDiscount',80, 'priceAfterDiscount' "&_
		"    union all select '含税单价', 'InheritId_self_priceAfterTax',  0, 9,0,0,1,1,0, 'priceAfterTax',80, 'priceAfterTax' "&_
		"    union all select '含税折后单价', 'InheritId_self_PriceAfterDiscountTaxPre',  0, 10,0,0,1,1,0, 'PriceAfterDiscountTaxPre',80, 'PriceAfterDiscountTaxPre' "&_
		"    union all select '票据类型', 'InheritId_self_invoiceType',  0, 11,0,0,1,1,0, 'invoiceType',80 , 'invoiceType'"&_
		"    union all select '税率',     'InheritId_self_taxRate',  0, 12,0,0,1,1,0, 'taxRate' ,70, 'taxRate' "&_
		"    union all select '总价', 'InheritId_self_TaxDstMoney', 0, 13,0,0,1,1,0, 'TaxDstMoney',80, 'TaxDstMoney' "&_
		"    union all select '明细优惠', 'InheritId_self_Concessions',  0, 14,0,0,1,1,0, 'Concessions',80, 'Concessions' "&_
		"    union all select '优惠后单价', 'InheritId_self_priceAfterDiscountTax',  0, 15,0,0,1,1,0, 'priceAfterDiscountTax',80 , 'priceAfterDiscountTax'"&_
		"    union all select '金额',     'InheritId_self_MoneyAfterDiscount',  0, 16,0,0,1,1,0, 'MoneyAfterDiscount',80 , 'MoneyAfterDiscount'"&_
		"    union all select '税额',     'InheritId_self_taxValue',  0, 17,0,0,1,1,0, 'taxValue',80 , 'taxValue' "&_
		"    union all select '优惠后总价', 'InheritId_self_money1',  0, 17,0,1,1,1,0, 'money1',80, 'money1' "&_
		"    union all select '建议进价', 'InheritId_self_pricejy',  0, 18,0,1,1,1,0, 'pricejy' ,80 , 'pricejy' "&_
		"    union all select '交货日期', 'InheritId_self_date2',  0, 20,0,0,1,1,0, 'date2',80 , 'date2' "&_
		"    union all select '备注',     'InheritId_self_intro',  0, 21,0,0,1,1,0, 'intro',85 , 'intro' "
		end select
		sql= "select b.id, isnull(b.title, t.title) as title, t.FieldName,  "&_
		"    isnull(t.UiType,b.UiType) as uitype, cast(isnull(b.IsUsed, t.defIsUsed) as int) as IsUsed, "&_
		"    BillType, ListType, "&_
		"    isnull(b.InheritId,t.id) as InheritId , case when isnull(b.defwidth,0)=0 then t.kd else b.defwidth end kd ,"&_
		"   ROW_NUMBER() over(order by isnull(b.showindex, t.ShowIndex)) as inx , t.tName "&_
		"from ( "&_
		"    select Title,  'InheritId_id_' + cast(id as varchar(12)) as dbname,  id, (showindex + 21) as showindex, uitype,  "&_
		"from ( "&_
		"        0 as mustshow,isUsed as defIsUsed, candr,mustfillin , 'InheritId_id_' + cast(id as varchar(12)) as FieldName , cast(75 as int) as kd ,dbname as tName "&_
		"from ( "&_
		"    from sys_sdk_BillFieldInfo  "&_
		"    where ListType=0 and BillType =16001 and BillType>0  "& msql &_
		") t  "&_
		"left join sys_sdk_BillFieldInfo b on t.dbname=b.dbname and b.BillType = "& billType &" and b.ListType='"& listType &"'  "&_
		"where (isnull(b.IsUsed, t.defIsUsed) = "& isUsed &"  "& existsSql &" ) or "& isUsed &" = 0 "&_
		"order by isnull(b.showindex, t.ShowIndex) "
		NewMxZDYSql = sql
	end function
	function NewMxZDYLoad(conn ,billType , listType , billID, ListID , InheritId)
		dim zdyrs , zdysql ,zdytext ,fieldid,DBName
		zdytext = ""
		fieldid = "0"
		DBName = ""
		if ListID&""="" or ListID&""="0" then ListID = 0
		if ListID< 0 then
			set zdyrs = conn.execute("select DBName, REPLACE(DBName,'ext','')  as fieldid from sys_sdk_BillFieldInfo where ID= "& InheritId &" and BillType=16001")
			if zdyrs.eof=false then
				fieldid = zdyrs("fieldid").value
				DBName = zdyrs("DBName").value
			end if
			zdyrs.close
			select case DBName
			case "zdy1","zdy2","zdy3","zdy4","zdy5","zdy6":
			zdysql = "select zdy1,zdy2,zdy3,zdy4,s5.sort1 as zdy5,s6.sort1 as zdy6 "&_
			"   from product p "&_
			"   left join sortonehy s5 on s5.id=p.zdy5 "&_
			"   left join sortonehy s6 on s6.id=p.zdy6 "&_
			"   where p.ord = abs(" & ListID &")"
			set zdyrs = conn.execute(zdysql)
			if zdyrs.eof=false then zdytext = zdyrs(DBName).value
			zdyrs.close
			case else :
			set zdyrs = conn.execute("select t2.FValue as v from ERP_CustomValues t2 where t2.FieldsID = " & fieldid &" and t2.orderid=abs(" & ListID &")")
			if zdyrs.eof=false then
				Dim apc : Set apc = server.createobject(ZBRLibDLLNameSN & ".PageClass")
				zdytext = apc.htmltotext(zdyrs("v").value)
			end if
			zdyrs.close
			end select
		else
			if billID&""="" then billID = 0
			if listType=0 then
				set zdyrs = conn.execute("select id from sys_sdk_BillFieldInfo where id= "& InheritId &" and BillType="& billType &"")
				if zdyrs.eof=false then
					fieldid = zdyrs("id").value
				end if
				zdyrs.close
			else
				set zdyrs = conn.execute("select id from sys_sdk_BillFieldInfo where InHeritID= "& InheritId &" and BillType="& billType &"")
				if zdyrs.eof=false then
					fieldid = zdyrs("id").value
				end if
				zdyrs.close
			end if
			set zdyrs = conn.execute("select top 1 case when isnull(cast(value as varchar(max)),'')='' then isnull(cast(Bigvalue as varchar(max)),'') else cast(value as varchar(max)) end as v from sys_sdk_BillFieldValue where BillType = "& billType &" and BillListType ="& listType &" and billid = "& billID &"  and listid= "& ListID &" and  fieldid  in ("& fieldid &"," & InheritId &")")
			if zdyrs.eof=false then zdytext = zdyrs("v").value
			zdyrs.close
		end if
		set zdyrs = conn.execute("select uitype from sys_sdk_BillFieldInfo where id = "& InheritId &"")
		if zdyrs.eof=false then
			dim uitype : uitype = zdyrs("uitype").value
			select case uitype
			case 2
			dim disNum : disNum = sdk.getSqlValue("select num1 from setjm3  where ord=88",2)
			if isnumeric(zdytext) = true then zdytext = Formatnumber(zdytext,disNum,-1 , 0, 0)
'dim disNum : disNum = sdk.getSqlValue("select num1 from setjm3  where ord=88",2)
			case 1
			zdytext = left(zdytext ,10)
			end select
		end if
		zdyrs.close
		NewMxZDYLoad  = zdytext
	end function
	function NewMxZDYSaveByOldBill(conn ,billType , listType , billID, ListID)
		dim sql
		sql = "    INSERT INTO [dbo].[sys_sdk_BillFieldValue]([BillType],[BillListType],[BillId],[ListID],[FieldId],[Value],[BigValue]) "&_
		" select   " & billType & ", " & listType & " ,  cl.contract, cl.id, a.id as [FieldId], case b.id when 1 then cl.zdy1 when 2 then cl.zdy2  when 3 then cl.zdy3  when 4 then cl.zdy4  when 5 then s1.sort1  when 6 then s2.sort1 end,null "&_
		"  from sys_sdk_BillFieldInfo a "&_
		"  inner join (select 1 id union all select 2 id union all select 3 id union all select 4 id union all select 5 id union all select 6 id) b on replace(a.dbname,'zdy','')=b.id "&_
		"  inner join contractlist cl on cl.contract= "& billID &" and (cl.id = "& ListID &" or "& ListID &"=0) "&_
		"  left join sortonehy s1 on b.id=5 and s1.ord= cl.zdy5  "&_
		"  left join sortonehy s2 on b.id=6 and s2.ord= cl.zdy6  "&_
		"  where a.ListType=0 and a.BillType =16001 and a.BillType>0 and a.dbname like 'zdy%' "&_
		"     AND ISNULL((case b.id when 1 then cl.zdy1 when 2 then cl.zdy2  when 3 then cl.zdy3  when 4 then cl.zdy4  when 5 then s1.sort1  when 6 then s2.sort1 end),'')<>'' "&_
		"     order by cl.id ,b.id"
		conn.execute(sql)
	end function
	function NewMxZDYSaveProc(conn ,billType , listType , billID, ListID ,tempID)
		dim InheritId , v
		dim rs7 : set rs7 = conn.execute(NewMxZDYSql(billType , listType , 1 , " and isnull(b.InheritId,t.id)>0  "))
		while rs7.eof=false
			InheritId = rs7("InheritId").value
			if InheritId>0 then
				v = request(rs7("fieldname").value &"_"& tempID)
				if rs7("uitype").value="5" then
					v = sdk.getSqlValue("select top 1 text from sys_sdk_BillFieldOptionsSource where id ='"& v &"'","")
				end if
				if conn.execute("select 1 from sys_sdk_BillFieldValue with(nolock) where BillType = "& billType &" and BillListType = "& listType &" and billid = "& billID &"  and listid= "& ListID &" and  fieldid = " & InheritId).eof=false then
					conn.execute("update sys_sdk_BillFieldValue set value='" & v &"' where BillType = "& billType &" and BillListType = "& listType &" and billid = "& billID &"  and listid= "& ListID &" and  fieldid = " & InheritId)
				else
					conn.execute("insert into sys_sdk_BillFieldValue([BillType],[BillListType],[BillId],[ListID],[FieldId],[Value]) select  "& billType &", "& listType &" , "& billID &","& ListID &"," & InheritId &",'"& v &"'")
				end if
			end if
			rs7.movenext
		wend
		rs7.close
	end function
	function NewMxZDYConvertToOldZDY(conn ,billType , listType , billID, ListID ,tempID, byref zdy1, byref zdy2, byref zdy3, byref zdy4, byref zdy5, byref zdy6)
		dim rs7 , dbname
		set rs7 = conn.execute("select id,dbname, 'InheritId_id_' + cast(id as varchar(12)) as fieldname from sys_sdk_BillFieldInfo where ListType=0 and BillType =16001 and BillType>0 and dbname in ('zdy1','zdy2','zdy3','zdy4','zdy5','zdy6')")
'dim rs7 , dbname
		while rs7.eof=false
			dbname = rs7("dbname").value
			if tempID>0 then
				select case dbname
				case "zdy1": zdy1 = request(rs7("fieldname").value &"_" & tempID )
				case "zdy2": zdy2 = request(rs7("fieldname").value &"_" & tempID )
				case "zdy3": zdy3 = request(rs7("fieldname").value &"_" & tempID )
				case "zdy4": zdy4 = request(rs7("fieldname").value &"_" & tempID )
				case "zdy5":
				zdy5 = request(rs7("fieldname").value &"_" & tempID )
				if isnumeric(zdy5)=false then zdy5= 0
				zdy5 = sdk.getSqlValue("select top 1 s.ord from sys_sdk_BillFieldOptionsSource a inner join sortonehy s on s.gate2=2101 and s.sort1 =a.text where a.id ='"& zdy5 &"'","0")
				case "zdy6":
				zdy6 = request(rs7("fieldname").value &"_" & tempID )
				if isnumeric(zdy6)=false then zdy6= 0
				zdy6 = sdk.getSqlValue("select top 1 s.ord from sys_sdk_BillFieldOptionsSource a inner join sortonehy s on s.gate2=2102 and s.sort1 =a.text where a.id ='"& zdy6 &"'","0")
				end select
			else
				select case dbname
				case "zdy1": zdy1 = NewMxZDYLoad(conn ,billType , listType , billID, ListID , rs7("id").value)
				case "zdy2": zdy2 = NewMxZDYLoad(conn ,billType , listType , billID, ListID , rs7("id").value)
				case "zdy3": zdy3 = NewMxZDYLoad(conn ,billType , listType , billID, ListID , rs7("id").value)
				case "zdy4": zdy4 = NewMxZDYLoad(conn ,billType , listType , billID, ListID , rs7("id").value)
				case "zdy5": zdy5 = NewMxZDYLoad(conn ,billType , listType , billID, ListID , rs7("id").value)
				case "zdy6": zdy6 = NewMxZDYLoad(conn ,billType , listType , billID, ListID , rs7("id").value)
				end select
			end if
			rs7.movenext
		wend
		rs7.close
	end function
	function LeftSearchNewMxZDY(cn ,billType , listType , byref ii , num1_dot)
		dim i , t ,rs, tname , UiType ,InHeritID ,chtml ,bText ,rs7,sql7
		i = 0
		set rs = cn.execute(NewMxZDYSql(billType , listType , 1 , " and isnull(b.InheritId,t.id)>0  "))
		if rs.eof=false then
			chtml = ""
			while not rs.eof
				bText = "font-size:12px;height:20px;line-height:18px;font-family:arial;font-weight:bold;"
'while not rs.eof
				ii = ii + 1
'while not rs.eof
				t = rs.fields("title").value
				tname = rs.fields("tname").value
				if i = 0 then
					chtml =  chtml & "<tr><td class='c_c'  style='text-align:right' height='28'>" & t & "：</td><td>"
'if i = 0 then
					bText = bText &"width:78px;"
				else
					chtml =  chtml & "<td class='c_c' style='width:63px;text-align:right'>" & t & "：</td><td>"
					bText = bText &"width:78px;"
					bText = bText &"width:100px;"
				end if
				UiType = rs.fields("UiType").value
				InHeritID = rs.fields("InHeritID").value
				select case UiType
				case 0, 10 , 13 :
				chtml =  chtml & "<input type=text db='" & tname & "_2' id='ht_a_s" & ii & "' class='text' style='" & bText & "' onkeydown='window.kdown(this)'>"
				case 1 :
				chtml =  chtml & "<INPUT db='" & tname & "_2' class='text' style='"& bText &"' id='ht_a_s" & ii & "' onclick='datedlg.show();' readonly>"
				case 2 :
				chtml =  chtml & "<INPUT db='" & tname & "_2' class='text' style='"& bText &"' id='ht_a_s" & ii & "' type='text' size='5' onKeyUp=""this.value=this.value.replace(/[^\d\.]/g,'');checkDot('ht_a_s" & ii & "','"& num1_dot &"')""  dataType='Number'>"
				case 4 :
				chtml =  chtml & "<select db='"& tname & "_1' id='ht_a_s"& ii&"'>"
				chtml =  chtml & "<option value=''></option>"
				chtml =  chtml & "<option value='是'>是</option>"
				chtml =  chtml & "<option value='否'>否</option>"
				chtml =  chtml & "</select>"
				case 5:
				chtml =  chtml & "<select db='"& tname & "_1' id='ht_a_s"& ii&"'>"
				chtml =  chtml & "<option value=''></option>"
				set rs7=server.CreateObject("adodb.recordset")
				sql7="select id as ord, text as sort1 from sys_sdk_BillFieldOptionsSource where fieldid ="& InHeritID &" order by showindex "
				rs7.open sql7,cn,1,1
				do until rs7.eof
					chtml =  chtml & "<option value='"& rs7("sort1") &"'>"& rs7("sort1") &"</option>"
					rs7.movenext
				loop
				rs7.close
				set rs7=nothing
				chtml =  chtml & "</select>"
				end select
				chtml =  chtml & "</td>"
				if i = 0 then
					i = i + 1
'if i = 0 then
				else
					i = 0
				end if
				rs.movenext
			wend
			if i = 1 then chtml =  chtml & "</tr>"
		end if
		rs.close
		LeftSearchNewMxZDY = chtml
	end function
	function LeftSearchNewMxZDYSQL(cn ,billType , listType , sv)
		dim i, ii ,fieldid,InheritId, msql , mmsql
		msql = ""
		mmsql = ""
		if len(sv)>0 then
			varry = split(sv,chr(1))
			set rs = cn.execute(NewMxZDYSql(billType , listType , 1 , " and isnull(b.InheritId,t.id)>0  "))
			if rs.eof=false then
				ii = 1
				msql = ""
				while  not rs.eof
					InheritId = rs("InheritId").value
					fieldid = rs("Id").value
					for i = 0 to ubound(varry)
						vv = split(varry(i),chr(3))
						if vv(0)&""= rs("inx").value&"" then
							mmsql = mmsql &" and listid in (select listid from sys_sdk_BillFieldValue where BillType = "& billType &" and BillListType ="& listType &" and fieldid  in ("& fieldid &"," & InheritId &") and (case when isnull(value,'')='' then isnull(Bigvalue,'') else value end) like '%"& vv(1) &"%' )"
						end if
					next
					ii = ii + 1
'(1) &"%' )"
					rs.movenext
				wend
				if len(mmsql)>0 then msql = "select distinct listid from sys_sdk_BillFieldValue where BillType = "& billType &" and BillListType ="& listType & mmsql
			end if
			rs.close
		end if
		LeftSearchNewMxZDYSQL = msql
	end function
	
	Class PriceTactices
		Private m_salePriceLimit
		Private m_salePriceSuggest
		Private m_salePriceHighest
		Private m_salePriceLowest
		Private m_salePriceAvg
		Private m_salePriceLast
		Private m_salePriceHighestWithKH
		Private m_salePriceLowestWithKH
		Private m_salePriceAvgWithKH
		Private m_salePriceLastWithKH
		Private m_salePriceTacticWithKH
		Private m_salePriceHighestWithTax
		Private m_salePriceLowestWithTax
		Private m_salePriceAvgWithTax
		Private m_salePriceLastWithTax
		Private m_salePriceDefaultValue
		Private m_buyPriceSuggest
		Private m_isDepartmentPriceTacticOn
		Private m_contractPrices
		Private m_sorce_user
		Private m_includeTax
		Private m_invoiceType
		Public default_invoiceType
		Private m_sort_jg
		Private m_cateType
		Private m_company
		Private m_product
		Private m_unit
		Private m_sort1
		Private m_cateid
		Private m_sort1_kh
		Private m_condition
		Private m_cn
		Private m_rs
		Private m_discount
		Private m_isHistoryDiscount
		Private Sub class_initalize
			default_invoiceType = 0
		end sub
		Public Property Get debug
		debug = "salePriceLimit=" & salePriceLimit & vbcrlf &_
		"salePriceSuggest=" & salePriceSuggest & vbcrlf &_
		"salePriceHighest=" & salePriceHighest & vbcrlf &_
		"salePriceLowest=" & salePriceLowest & vbcrlf &_
		"salePriceAvg=" & salePriceAvg & vbcrlf &_
		"salePriceLast=" & salePriceLast & vbcrlf &_
		"salePriceHighestWithKH=" & salePriceHighestWithKH & vbcrlf &_
		"salePriceLowestWithKH=" & salePriceLowestWithKH & vbcrlf &_
		"salePriceAvgWithKH=" & salePriceAvgWithKH & vbcrlf &_
		"salePriceLastWithKH=" & salePriceLastWithKH & vbcrlf &_
		"salePriceTacticWithKH=" & salePriceTacticWithKH & vbcrlf &_
		"salePriceHighestWithTax=" & salePriceHighestWithTax & vbcrlf &_
		"salePriceLowestWithTax=" & salePriceLowestWithTax & vbcrlf &_
		"salePriceAvgWithTax=" & salePriceAvgWithTax & vbcrlf &_
		"salePriceLastWithTax=" & salePriceLastWithTax & vbcrlf &_
		"salePriceDefaultValue=" & salePriceDefaultValue & vbcrlf &_
		"buyPriceSuggest=" & buyPriceSuggest & vbcrlf &_
		"isDepartmentPriceTacticOn=" & isDepartmentPriceTacticOn & vbcrlf &_
		"m_sorce_user=" & m_sorce_user & vbcrlf &_
		"m_sort_jg=" & m_sort_jg & vbcrlf &_
		"m_cateType=" & m_cateType & vbcrlf &_
		"m_company=" & m_company & vbcrlf &_
		"m_product=" & m_product & vbcrlf &_
		"m_unit=" & m_unit & vbcrlf &_
		"m_sort1=" & m_sort1 & vbcrlf &_
		"m_cateid=" & m_cateid & vbcrlf &_
		"m_sort1_kh=" & m_sort1_kh & vbcrlf &_
		"m_condition=" & m_condition
		End Property
		Public Property Get debugWithBR
		debugWithBR = Replace(Me.debug,vbcrlf,"<br>")
		End Property
		Public Property Get invoiceType
		invoiceType = m_invoiceType
		End Property
		Public Property Get getDepartmentId
		getDepartmentId = m_sorce_user
		End Property
		Public Property Let isHistoryDiscount(isHistory)
		m_isHistoryDiscount = isHistory
		End Property
		Public Property Get isHistoryDiscount
		isHistoryDiscount = m_isHistoryDiscount
		End Property
		Public Property Get isDepartmentPriceTacticOn
		If isEmpty(m_isDepartmentPriceTacticOn) Then
			m_isDepartmentPriceTacticOn = False
			set m_rs = m_cn.execute("select num1 from pricegate1  with(nolock) where ord="&m_sorce_user&" and num1=1")
			if m_rs.eof = False Then
				m_isDepartmentPriceTacticOn = True
			end if
			m_rs.close
		end if
		isDepartmentPriceTacticOn = m_isDepartmentPriceTacticOn
		End Property
		Public Property Get contractPrices
		If isEmpty(m_contractPrices) Then
			Me.salePriceDefaultValue
		end if
		contractPrices = m_contractPrices
		End Property
		Public Property Get salePriceDefaultValue
		Dim rsPrice
		m_discount = 1
		If SalesPrice_dot_num&"" = "" Then
			on error resume next
			SalesPrice_dot_num = info.SalesPriceDotNum
			on error goto 0
		end if
		If isEmpty(m_salePriceDefaultValue) Then
			If m_sort_jg = 1 Then
				If m_company > 0 Then
					Set rsPrice = m_cn.execute("" &_
					"select top 1 case when b.includeTax = 1 then round(a.priceAfterTaxPre/case when isnull(a.discount,0) =0 then 1 else a.discount end,"&SalesPrice_dot_num&") else a.price1 " & vbcrlf & _
					" end as price1,a.invoiceType,case when isnull(a.discount,0) =0 then 1 else a.discount end as discount " & vbcrlf & _
					"from contractlist a  with(nolock) " & vbcrlf &_
					"inner join product b  with(nolock) on a.ord=b.ord and CHARINDEX(','+CAST(a.invoiceType as varchar(10))+',',',0,'+case when len(isnull(b.invoiceTypes,''))=0 then '0' else b.invoiceTypes end+',')>0 "&_
					"from contractlist a  with(nolock) " & vbcrlf &_
					"where a.company in("&m_company&") and a.unit="&m_unit&" and a.ord="&m_product&" and a.del=1 " & m_condition & " order by a.date7 desc")
				else
					Set rsPrice = m_cn.execute("" &_
					"select top 1 case when b.includeTax = 1 then round(a.priceAfterTaxPre/case when isnull(a.discount,0) =0 then 1 else a.discount end,"&SalesPrice_dot_num&") else a.price1 " & vbcrlf & _
					" end as price1,a.invoiceType,case when isnull(a.discount,0) =0 then 1 else a.discount end as discount " & vbcrlf & _
					"from contractlist a  with(nolock) " & vbcrlf &_
					"inner join product b  with(nolock) on a.ord=b.ord and CHARINDEX(','+CAST(a.invoiceType as varchar(10))+',',',0,'+case when len(isnull(b.invoiceTypes,''))=0 then '0' else b.invoiceTypes end+',')>0 " & vbcrlf & _
					"from contractlist a  with(nolock) " & vbcrlf &_
					"where a.unit="&m_unit&" and a.ord=" & m_product & " and a.del=1 and a.addcate="&session("personzbintel2007") & " order by a.date7 desc")
				end if
				if rsPrice.eof = False Then
					m_salePriceDefaultValue = rsPrice("price1")
					m_invoiceType = rsPrice("invoiceType")
					m_contractPrices = Me.getKindsOfPrices(m_salePriceDefaultValue,invoiceType)
					if Me.isHistoryDiscount then m_discount = rsPrice("discount")
				Else
					if rsPrice.eof = True Then
						Set rsPrice = m_cn.execute("" &_
						"select top 1 case when b.includeTax = 1 then round(a.priceAfterTaxPre/case when isnull(a.discount,0) =0 then 1 else a.discount end,"&SalesPrice_dot_num&") else a.price1 " & vbcrlf & _
						" end as price1,a.invoiceType,case when isnull(a.discount,0) =0 then 1 else a.discount end as discount " & vbcrlf & _
						"from contractlist a  with(nolock) " & vbcrlf &_
						"inner join product b  with(nolock) on a.ord=b.ord and CHARINDEX(','+CAST(a.invoiceType as varchar(10))+',',',0,'+case when len(isnull(b.invoiceTypes,''))=0 then '0' else b.invoiceTypes end+',')>0 "&_
						"from contractlist a  with(nolock) " & vbcrlf &_
						"where a.company in("&m_company&") and a.unit="&m_unit&" and a.ord="&m_product&" and a.del=1 and a.addcate="&session("personzbintel2007") & " order by a.date7 desc")
					end if
					if rsPrice.eof = False Then
						m_salePriceDefaultValue = rsPrice("price1")
						m_invoiceType = rsPrice("invoiceType")
						m_contractPrices = Me.getKindsOfPrices(m_salePriceDefaultValue,invoiceType)
						if Me.isHistoryDiscount then m_discount = rsPrice("discount")
					else
						m_salePriceDefaultValue = Me.salePriceSuggest
						m_invoiceType = default_invoiceType
						m_contractPrices = Me.getKindsOfPrices(m_salePriceDefaultValue,default_invoiceType)
						if Me.isHistoryDiscount then m_discount = 1
					end if
				end if
				rsPrice.close
			Else
				m_salePriceDefaultValue = Me.salePriceSuggest
				m_invoiceType = default_invoiceType
				m_contractPrices = Me.getKindsOfPrices(m_salePriceDefaultValue,default_invoiceType)
				if Me.isHistoryDiscount then m_discount = 1
			end if
		end if
		if m_discount&"" = "" then m_discount = 1
		salePriceDefaultValue = m_salePriceDefaultValue
		End Property
		Public Property Get salePriceLimit
		Call fillinPrice
		salePriceLimit = m_salePriceLimit
		End Property
		Public Property Get salePriceSuggest
		Call fillinPrice
		salePriceSuggest = m_salePriceSuggest
		End Property
		Public Property Get discount
		discount = m_discount
		End Property
		Private Sub fillinPrice
			If isEmpty(m_salePriceSuggest) Then
				If m_sort1_kh > 0 Then
					m_salePriceSuggest = Me.salePriceTacticWithKH
				end if
				If Me.isDepartmentPriceTacticOn Then
					Set m_rs = m_cn.execute("select isnull(price2jy,0) price2jy,isnull(price2,0) price2,isnull(price1jy,0) price1jy from jiage  with(nolock) where product="&m_product&" and bm="&m_sorce_user&" and unit="&m_unit&"")
					if m_rs.eof = False Then
						If isEmpty(m_salePriceSuggest) Then m_salePriceSuggest = CDbl(m_rs("price2jy"))
						If isEmpty(m_salePriceLimit) Then m_salePriceLimit = CDbl(m_rs("price2"))
						If isEmpty(m_buyPriceSuggest) Then m_buyPriceSuggest = CDbl(m_rs("price1jy"))
					end if
					m_rs.close
				end if
				Set m_rs = m_cn.execute("select isnull(price2jy,0) price2jy,isnull(price2,0) price2,isnull(price1jy,0) price1jy from jiage  with(nolock) where product="&m_product&" and bm=0 and unit="&m_unit&"")
				If m_rs.eof = False Then
					If isEmpty(m_salePriceSuggest) Then m_salePriceSuggest = CDbl(m_rs("price2jy"))
					If isEmpty(m_salePriceLimit) Then m_salePriceLimit = CDbl(m_rs("price2"))
					If isEmpty(m_buyPriceSuggest) Then m_buyPriceSuggest = CDbl(m_rs("price1jy"))
				end if
				m_rs.close
				If isEmpty(m_salePriceSuggest) Then m_salePriceSuggest=0
				If isEmpty(m_salePriceLimit) Then m_salePriceLimit=0
				If isEmpty(m_buyPriceSuggest) Then m_buyPriceSuggest=0
			end if
		end sub
		Public Property Get salePriceHighest
		If isEmpty(m_salePriceHighest) Then
			m_salePriceHighest=0
			Set m_rs = m_cn.execute("select isnull(Max(price1),0) from contractlist a  with(nolock) where unit="&m_unit&" and ord="&m_product & m_condition & " and del=1 ")
			if m_rs.eof = False Then m_salePriceHighest = m_rs(0)
			m_rs.close
			if m_salePriceHighest&"" = "" then m_salePriceHighest = 0 else m_salePriceHighest = CDbl(m_salePriceHighest)
		end if
		salePriceHighest = m_salePriceHighest
		End Property
		Public Property Get salePriceLowest
		If isEmpty(m_salePriceLowest) Then
			m_salePriceLowest=0
			Set m_rs = m_cn.execute("select isnull(Min(price1),0) from contractlist a  with(nolock) where unit="&m_unit&" and ord="&m_product & m_condition &" and del=1 ")
			if m_rs.eof = False Then m_salePriceLowest = m_rs(0)
			m_rs.close
			if m_salePriceLowest&"" = "" then m_salePriceLowest = 0 else m_salePriceLowest = CDbl(m_salePriceLowest)
		end if
		salePriceLowest = m_salePriceLowest
		End Property
		Public Property Get salePriceAvg
		If isEmpty(m_salePriceAvg) Then
			m_salePriceAvg=0
			Set m_rs = m_cn.execute("select isnull(avg(price1),0) as price1 from contractlist a  with(nolock) where unit="&m_unit&" and ord="&m_product & m_condition&" and del=1 ")
			if m_rs.eof = False Then m_salePriceAvg = m_rs("price1")
			m_rs.close
			if m_salePriceAvg&"" = "" then m_salePriceAvg = 0 else m_salePriceAvg = CDbl(m_salePriceAvg)
		end if
		salePriceAvg = m_salePriceAvg
		End Property
		Public Property Get salePriceLast
		If isEmpty(m_salePriceLast) Then
			m_salePriceLast=0
			Set m_rs = m_cn.execute("select top 1 price1 from contractlist a  with(nolock) where unit="&m_unit&" and ord=" & m_product & m_condition & " and del=1 order by date7 desc")
			if m_rs.eof = False Then m_salePriceLast = m_rs("price1")
			m_rs.close
			if m_salePriceLast&"" = "" then m_salePriceLast = 0 else m_salePriceLast = CDbl(m_salePriceLast)
		end if
		salePriceLast = m_salePriceLast
		End Property
		Public Property Get salePriceHighestWithKH
		If isEmpty(m_salePriceHighestWithKH) Then
			m_salePriceHighestWithKH = 0
			If m_company > 0 Then
				Set m_rs = m_cn.execute("select isnull(Max(price1),0) from contractlist a with(nolock) where company in("&m_company&") and unit="&m_unit&" and ord="&m_product&" and del=1 " & m_condition)
				if m_rs.eof = False Then m_salePriceHighestWithKH = m_rs(0)
				m_rs.close
			end if
			if m_salePriceHighestWithKH&"" = "" then m_salePriceHighestWithKH = 0 else m_salePriceHighestWithKH = CDbl(m_salePriceHighestWithKH)
		end if
		salePriceHighestWithKH = m_salePriceHighestWithKH
		End Property
		Public Property Get salePriceLowestWithKH
		If isEmpty(m_salePriceLowestWithKH) Then
			m_salePriceLowestWithKH = 0
			If m_company > 0 Then
				Set m_rs = m_cn.execute("select isnull(Min(price1),0) from contractlist a  with(nolock) where company in("&m_company&") and unit="&m_unit&" and ord="&m_product&" and del=1 " & m_condition)
				if m_rs.eof = False Then m_salePriceLowestWithKH = m_rs(0)
				m_rs.close
			end if
			if m_salePriceLowestWithKH&"" = "" then m_salePriceLowestWithKH = 0 else m_salePriceLowestWithKH = CDbl(m_salePriceLowestWithKH)
		end if
		salePriceLowestWithKH = m_salePriceLowestWithKH
		End Property
		Public Property Get salePriceAvgWithKH
		If isEmpty(m_salePriceAvgWithKH) Then
			m_salePriceAvgWithKH = 0
			If m_company > 0 Then
				Set m_rs = m_cn.execute("select isnull(avg(price1),0) as price1 from contractlist a  with(nolock) "&_
				"where company in("&m_company&") and unit="&m_unit&" and ord="&m_product&" and del=1 " & m_condition)
				if m_rs.eof = False Then m_salePriceAvgWithKH = m_rs("price1")
				m_rs.close
			end if
			if m_salePriceAvgWithKH&"" = "" then m_salePriceAvgWithKH = 0 else m_salePriceAvgWithKH = CDbl(m_salePriceAvgWithKH)
		end if
		salePriceAvgWithKH = m_salePriceAvgWithKH
		End Property
		Public Property Get salePriceLastWithKH
		If isEmpty(m_salePriceLastWithKH) Then
			m_salePriceLastWithKH = 0
			If m_company > 0 Then
				Set m_rs = m_cn.execute("select top 1 price1 from contractlist a  with(nolock) "&_
				"where company in("&m_company&") and unit="&m_unit&" and ord="&m_product&" and del=1 " & m_condition & " order by date7 desc")
				if m_rs.eof = False Then m_salePriceLastWithKH = m_rs("price1")
				m_rs.close
			end if
			if m_salePriceLastWithKH&"" = "" then m_salePriceLastWithKH = 0 else m_salePriceLastWithKH = CDbl(m_salePriceLastWithKH)
		end if
		salePriceLastWithKH = m_salePriceLastWithKH
		End Property
		Public Property Get salePriceTacticWithKH
		If isEmpty(m_salePriceTacticWithKH) Then
			if m_sort1_kh>0 then
				Set m_rs = m_cn.execute("select price3 from jiage  with(nolock) where product="&m_product&" and bm="&m_sorce_user&" and unit="&m_unit&" and sort="&m_sort1_kh&" ")
				if m_rs.eof = False Then m_salePriceTacticWithKH = m_rs("price3")
				m_rs.close
			end if
			if m_salePriceTacticWithKH&"" = "" then m_salePriceTacticWithKH = 0 else m_salePriceTacticWithKH = CDbl(m_salePriceTacticWithKH)
		end if
		salePriceTacticWithKH = m_salePriceTacticWithKH
		End Property
		Public Property Get salePriceHighestWithTax
		If isEmpty(m_salePriceHighestWithTax) Then
			m_salePriceHighestWithTax = 0
			Set m_rs = m_cn.execute("select isnull(Max(priceAfterTaxPre),0) from contractlist a  with(nolock) where unit="&m_unit&" and ord="&m_product & m_condition&" and del=1 ")
			if m_rs.eof = False Then m_salePriceHighestWithTax = m_rs(0)
			m_rs.close
			if m_salePriceHighestWithTax&"" = "" then m_salePriceHighestWithTax = 0 else m_salePriceHighestWithTax = CDbl(m_salePriceHighestWithTax)
		end if
		salePriceHighestWithTax = m_salePriceHighestWithTax
		End Property
		Public Property Get salePriceLowestWithTax
		If isEmpty(m_salePriceLowestWithTax) Then
			m_salePriceLowestWithTax = 0
			Set m_rs = m_cn.execute("select isnull(Min(priceAfterTaxPre),0) from contractlist a  with(nolock) where unit="&m_unit&" and ord="&m_product & m_condition&" and del=1 ")
			if m_rs.eof = False Then m_salePriceLowestWithTax = m_rs(0)
			m_rs.close
			if m_salePriceLowestWithTax&"" = "" then m_salePriceLowestWithTax = 0 else m_salePriceLowestWithTax = CDbl(m_salePriceLowestWithTax)
		end if
		salePriceLowestWithTax = m_salePriceLowestWithTax
		End Property
		Public Property Get salePriceAvgWithTax
		If isEmpty(m_salePriceAvgWithTax) Then
			m_salePriceAvgWithTax = 0
			Set m_rs = m_cn.execute("select isnull(avg(priceAfterTaxPre),0) as price1 from contractlist a  with(nolock) where unit="&m_unit&" and ord="&m_product & m_condition&" and del=1 ")
			if m_rs.eof = False Then m_salePriceAvgWithTax = m_rs("price1")
			m_rs.close
			if m_salePriceAvgWithTax&"" = "" then m_salePriceAvgWithTax = 0 else m_salePriceAvgWithTax = CDbl(m_salePriceAvgWithTax)
		end if
		salePriceAvgWithTax = m_salePriceAvgWithTax
		End Property
		Public Property Get salePriceLastWithTax
		If isEmpty(m_salePriceLastWithTax) Then
			m_salePriceLastWithTax = 0
			Set m_rs = m_cn.execute("select top 1 priceAfterTaxPre price1 from contractlist a  with(nolock) where unit="&m_unit&" and ord=" & m_product & m_condition & " and del=1 order by date7 desc")
			if m_rs.eof = False Then m_salePriceLastWithTax = m_rs("price1")
			m_rs.close
			if m_salePriceLastWithTax&"" = "" then m_salePriceLastWithTax = 0 else m_salePriceLastWithTax = CDbl(m_salePriceLastWithTax)
		end if
		salePriceLastWithTax = m_salePriceLastWithTax
		End Property
		Public Property Get buyPriceSuggest
		Call fillinPrice
		buyPriceSuggest = m_buyPriceSuggest
		End Property
		Public Sub init(cnObj,companyOrd,productOrd,unitOrd)
			Set m_cn = cnObj
			If m_company = companyOrd And m_product = productOrd And m_unit = unitOrd Then Exit Sub
			m_company = companyOrd  : m_product = productOrd : m_unit = unitOrd
			If m_company&"" = "" Then m_company = 0
			If m_product&"" = "" Then m_product = 0
			If m_unit&"" = "" Then m_unit = 0
			Set m_rs = m_cn.execute("select includeTax from product  with(nolock) where ord="&m_product)
			If m_rs.eof = False Then
				m_includeTax = m_rs(0)
			else
				m_includeTax = 0
			end if
			m_rs.close
			If isEmpty(m_sort_jg) Then
				m_sort_jg=1
				set m_rs=m_cn.execute("select isnull(intro,1) intro from setopen  with(nolock) where sort1=1201")
				If m_rs.eof = False Then m_sort_jg=CLng(m_rs("intro"))
				m_rs.close
			end if
			If isEmpty(m_cateType) Then
				m_cateType=1
				Set m_rs = m_cn.execute("select isnull(intro,1) intro from setopen  with(nolock) where sort1=2014061301")
				if m_rs.eof = False Then m_cateType=CLng(m_rs("intro"))
				m_rs.close
			end if
			m_sort1=0
			m_cateid=0
			If m_company&""="" Or Not isNumeric(m_company) Then
				If session("companyzbintel") & "" = "" Then
					m_company=0
				else
					If InStr(session("companyzbintel"),",") > 0 Then
						Dim company__ord : company__ord = Split(session("companyzbintel"),",")(0)
						If company__ord <> "" Then
							m_company = CLng(company__ord)
						else
							m_company = 0
						end if
					else
						m_company = CLng(session("companyzbintel"))
					end if
				end if
			end if
			Set m_rs = m_cn.execute("select ord,name,isnull(sort1,0) sort1,cateid,cateadd,isnull(cateid,"&session("personzbintel2007")&") cid from tel  with(nolock) where ord in("&m_company&") and del=1")
			if m_rs.eof = False then
				m_sort1=CLng(m_rs("sort1"))
				If m_sort_jg=1 Then
					If m_cateType=1 Then
						m_cateid = session("personzbintel2007")
					Else
						m_cateid = m_rs("cid")
					end if
				Else
					m_cateid=m_rs("cateid")
				end if
			end if
			m_rs.close
			If m_cateid=0 Then
				If session("personzbintel2007")<>"" Then
					m_cateid=CLng(session("personzbintel2007"))
				end if
			end if
			If m_cateid&"" = "" Then m_cateid = 0
			m_sorce_user=0
			Set m_rs = m_cn.execute("select isnull(pricesorce,0) as  sorce from gate  with(nolock) where ord="&m_cateid&" ")
			if m_rs.eof = False Then m_sorce_user = m_rs("sorce")
			m_rs.close
			Set m_rs = m_cn.execute("select * from pricegate1  with(nolock) where ord="&m_sorce_user&" and num1=1")
			if m_rs.eof Then m_sorce_user=0
			m_rs.close
			If m_sorce_user&"" = "" Then m_sorce_user = 0
			If m_sort_jg=1 Then
				If m_cateType=1 Then
					m_condition = " and a.addcate=" & m_cateid
				Else
					m_condition = " and (case when isnull(a.cateid,0) = 0 or a.cateid = '' then a.addcate else a.cateid end)=" & m_cateid
				end if
			Else
				m_condition = " and a.cateid=" & m_cateid
			end if
			If m_company>0 Then
				m_sort1_kh=0
				set m_rs = m_cn.execute("select ord from sort5  with(nolock) where time1=1 and ord="&m_sort1&"")
				if m_rs.eof = False Then m_sort1_kh = m_rs("ord")
				m_rs.close
			end if
		end sub
		Private Function iif(e,v1,v2)
			If eval(e) Then
				iif = v1
			else
				iif = v2
			end if
		end function
		Public Function getKindsOfPrices(priceValue,invoiceType)
			Dim pricesFun(2),rsFun,sqlFun
			pricesFun(0) = priceValue
			pricesFun(1) = priceValue
			pricesFun(2) = priceValue
			getKindsOfPrices = pricesFun
			If Len(Trim(invoiceType)&"")="0" Or invoiceType = 0 then
				sqlFun = "select b.* from sortonehy a  with(nolock) ,invoiceConfig b  with(nolock) where b.typeid=a.id and a.gate2=34 and a.id1=-65535"
'If Len(Trim(invoiceType)&"")="0" Or invoiceType = 0 then
			else
				sqlFun = "select b.* from sortonehy a with(nolock) ,invoiceConfig b  with(nolock) where b.typeid=a.id and a.id =" & invoiceType
			end if
			Set rsFun = m_cn.execute(sqlFun)
			If rsFun.eof Then
				Exit Function
			else
				Err.clear
				on error resume next
				If m_includeTax = 1 Then
					pricesFun(1) = CDbl(priceValue)
					pricesFun(0) = CDbl(eval(Replace(Replace(rsFun("priceBeforeTaxFormula"),"{含税单价}",CDbl(priceValue)),"{税率}",rsFun("taxRate")&"/100")))
					If Err.number <> 0 Then  pricesFun(0) = pricesFun(1)
				Else
					pricesFun(0) = CDbl(priceValue)
					pricesFun(1) = CDbl(eval(Replace(Replace(rsFun("priceFormula"),"{未税单价}",CDbl(priceValue)),"{税率}",rsFun("taxRate")&"/100")))
					If Err.number <> 0 Then  pricesFun(1) = pricesFun(0)
				end if
				On Error GoTo 0
				pricesFun(2) = CDbl(rsFun("taxRate"))
			end if
			rsFun.close
			getKindsOfPrices = pricesFun
		end function
	end Class
	
	Response.write "" & vbcrlf & "<link href=""../inc/cskt.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"" />" & vbcrlf & "<script language=""javascript"" src=""../sortcp/function.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"" src=""../contract/formatnumber.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"" src=""../inc/ptdmanger.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script language=""javascript"" type=""text/javascript"" src=""cp_ajax.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<script type=""text/JavaScript"" src=""../skin/default/js/Bt_add.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "<link href=""BomList_Add.css?ver="
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css""/>" & vbcrlf & "<SCRIPT language=JavaScript1.2>" & vbcrlf & "//--产品选择列表事件类型：1 = 主页面添加父件；0 = 弹窗选择子件； 默认1，弹窗页面会设为0；" & vbcrlf & "//bomadd.addAction = ""0"";" & vbcrlf & "// 一个简单的测试是否IE浏览器的表达式" & vbcrlf & "isIE = (document.all ? true : false);" & vbcrlf & "// 得到IE中各元素真正的位移量，即使这个元素在一个表格中" & vbcrlf & "function getIEPosX(elt) { return getIEPos(elt,""Left""); }" & vbcrlf & "function getIEPosY(elt) { return getIEPos(elt,""Top""); }" & vbcrlf & "function getIEPos(elt,which) {" & vbcrlf & " iPos = 0" & vbcrlf & " while (elt!=null) {" & vbcrlf & "  iPos += elt[""offset"" + which]" & vbcrlf & "  elt = elt.offsetParent" & vbcrlf & " }" & vbcrlf & " return iPos" & vbcrlf & "}" & vbcrlf & "window.setParentProduct = function(pid,ptype){" & vbcrlf & "        document.getElementById(""Bom_Trees_View"").src = ""bom_trees_view.asp?estimation="
	Response.write Application("sys.info.jsver")
	Response.write estimation
	Response.write "&ord="" + pid + ""&ptype="" + ptype" & vbcrlf & "}" & vbcrlf & "// -->" & vbcrlf & "</SCRIPT>" & vbcrlf & "<style>" & vbcrlf & ".dataCell{" & vbcrlf & "    border-bottom:#ccc 1px solid;" & vbcrlf & "   border-left:#ccc 1px solid;" & vbcrlf & "     border-right:#ccc 1px solid;" & vbcrlf & "}" & vbcrlf &".inputCell{" & vbcrlf & "       overflow-x:hidden" & vbcrlf & "}" & vbcrlf & "#pro_tab{" & vbcrlf & "     width:100%;height:40px;padding-top:6px;" & vbcrlf & " text-align:center;" & vbcrlf & "      font-size:0;" & vbcrlf & "    background:#FFF;" & vbcrlf & "}" & vbcrlf & "#pro_tab span{" & vbcrlf & " width:49%;height:30px;line-height:30px;border-bottom:none;display:inline-block;cursor:pointer;" & vbcrlf & "     margin:0px;" & vbcrlf & "     padding:0px;" & vbcrlf & "    font-size:14px;" & vbcrlf & "}" & vbcrlf & "#productTree{width:}" & vbcrlf & "#lvw_tablebg_Bomtree{border-top:1px solid #ccc!important}" & vbcrlf & "</style>" & vbcrlf & "<script language=""javascript"" src=""../Inc/DelUnusedFiles.js?ver="
	Response.write Application("sys.info.jsver")
	Response.write """></script>" & vbcrlf & "</head>" & vbcrlf & "<body oncontextmenu=self.event.returnValue=false onmouseover=""jQuery('#info_show_div').hide();"">" & vbcrlf & ""
	set rs1=server.CreateObject("adodb.recordset")
	sql1="select qx_open,qx_intro from power  where ord="&session("personzbintel2007")&" and sort1=21 and sort2=13"
	rs1.open sql1,conn,1,1
	if rs1.eof then
		open_21_13=0
	else
		open_21_13=rs1("qx_open")
	end if
	rs1.close
	set rs1=nothing
	dim MODULES
	Dim cols()
	i = 0
	ReDim Preserve cols(i)
	cols(i)= "<td dbname=""index"" align=""center"" style=""border-top:#ccc 1px solid;border-bottom:#ccc 1px solid;border-left:#ccc 1px solid;border-right:#ccc 1px solid;text-align:center;width:60px;""><strong>序号</strong></td>"
'ReDim Preserve cols(i)
	i=i+1
'ReDim Preserve cols(i)
	ReDim Preserve cols(i)
	cols(i)= "<td dbname=""title"" align=""center"" style=""border-top:#ccc 1px solid;border-bottom:#ccc 1px solid;border-left:#ccc 1px solid;border-right:#ccc 1px solid;text-align:center""><strong>产品名称</strong></td>"
'ReDim Preserve cols(i)
	i=i+1
'ReDim Preserve cols(i)
	ReDim Preserve cols(i)
	cols(i)= "<td dbname=""order1"" align=""center"" style=""border-top:#ccc 1px solid;border-bottom:#ccc 1px solid;border-left:#ccc 1px solid;border-right:#ccc 1px solid;text-align:center""><strong>产品编号</strong></td>"
'ReDim Preserve cols(i)
	i=i+1
'ReDim Preserve cols(i)
	ReDim Preserve cols(i)
	cols(i)= "<td dbname=""type1"" align=""center"" style=""border-top:#ccc 1px solid;border-bottom:#ccc 1px solid;border-left:#ccc 1px solid;border-right:#ccc 1px solid;text-align:center""><strong>产品型号</strong></td>"
'ReDim Preserve cols(i)
	i=i+1
'ReDim Preserve cols(i)
	set rs=server.CreateObject("adodb.recordset")
	sql="select * from zdy where sort1 = 21 and set_open = 1 order by gate1 "
	rs.open sql,conn,1,1
	do until rs.eof
		ReDim Preserve cols(i)
		cols(i)= "<td dbname=""" & rs("name") & """ align=""center"" style=""border-top:#ccc 1px solid;border-bottom:#ccc 1px solid;border-left:#ccc 1px solid;border-right:#ccc 1px solid;text-align:center""><strong>" & rs("title") & "</strong></td>"
'ReDim Preserve cols(i)
		i=i+1
'ReDim Preserve cols(i)
		rs.movenext
	loop
	rs.close
	set rs=Nothing
	ReDim Preserve cols(i)
	cols(i)= "<td dbname=""link"" align=""center"" style=""border-top:#ccc 1px solid;border-bottom:#ccc 1px solid;border-left:#ccc 1px solid;border-right:#ccc 1px solid;text-align:center""><strong>操作</strong></td>"
'ReDim Preserve cols(i)
	i=i+1
'ReDim Preserve cols(i)
	Dim returnUnit : returnUnit = False
	Dim treeType : treeType = request.querystring("treeType")
	Response.write "" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""5"" >" & vbcrlf & "      <tr>" & vbcrlf & "            <td valign=""top"" style='width:233px;' class=""bgfff"">" & vbcrlf & "                        <div class=""resetHeadBg"" style=""BACKGROUND-IMAGE: url(../images/smico/tree_st_c.gif); HEIGHT: 64px; OVERFLOW: hidden"">" & vbcrlf & "                             <div class=""resetElementHidden"" style=""BACKGROUND-IMAGE: url(../images/smico/tree_st_l.gif); WIDTH: 15px; FLOAT: left; HEIGHT: 40px""></div> " & vbcrlf & "                                <div class=""resetElementHidden"" style=""BACKGROUND-IMAGE: url(../images/smico/tree_st_r.gif); WIDTH: 8px; FLOAT: right; HEIGHT: 40px""></div> " & vbcrlf & "                             <div class=""leftPageBgPd"" style=""HEIGHT: 64px; OVERFLOW: hidden;background:#EFEFEF""> " & vbcrlf & "                               <div class=""tableTitleLinks"" style=""line-height: 64px; WHITE-SPACE: nowrap; COLOR: #5555aa; MARGIN-LEFT: 1px; FONT-SIZE: 14px;FONT-WEIGHT: bold;background:#EFEFEF;padding-left:20px"">" & vbcrlf & "                                 组装清单产品选择" & vbcrlf & "                                </div>" & vbcrlf & "                          </div>" & vbcrlf & "                  </div>" & vbcrlf & "                  <div id=""pro_tab"" class='selected1'>" & vbcrlf & "                              <span id=""select_product"" onclick=""document.getElementById('proSelectFrame').src = 'select_product.asp?ShowOnlyHasBomProduct=1&hasAdvSearch=1';this.parentElement.className = 'selected1'"">产品</span> " & vbcrlf & "                               <span id=""select_productName"" onclick=""try{Left_adClose()}catch(e){};document.getElementById('proSelectFrame').src = 'select_productName.asp?ShowOnlyHasBomProduct=1';this.parentElement.className = 'selected2'"">虚拟</span> " & vbcrlf & "                 </div>" & vbcrlf & "                  <div style='border:1px solid #ccc;overflow:hidden'>" & vbcrlf & "                             <iframe style=""MARGIN-TOP: 0px; WIDTH: 230px; HEIGHT: 500px; MARGIN-LEFT: 2px"" id=""proSelectFrame"" border=""0"" src=""select_product.asp?ShowOnlyHasBomProduct=1&hasAdvSearch=1"" frameborder=""0"" scorlling=""no""></iframe>" & vbcrlf & "                      </div>" & vbcrlf & "          </td>" & vbcrlf & "           <td valign=""top"">" & vbcrlf & "                 <iframe id='Bom_Trees_View' style=""MARGIN-TOP: 0px; WIDTH: 100%; HEIGHT:700px; MARGIN-LEFT: 2px""id=""proSelectFrame"" border=""0"" src=""bom_trees_view.asp?estimation="
	Response.write estimation
	Response.write """ frameborder=""0"" scorlling=""yes""></iframe>" & vbcrlf & "                    "
	action1="树形结构查询"
	call close_list(2)
	Response.write "" & vbcrlf & "              </td>" & vbcrlf & "   </tr>" & vbcrlf & "</table>" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "<!--" & vbcrlf & "    function nodeClick(e,obj){" & vbcrlf & "              var nid = obj.getAttribute(""nid"");" & vbcrlf & "                document.getElementById(""Bom_Trees_View"").src = ""../bomlist/bom_trees_view.asp?treeType="
	Response.write treeType
	Response.write "&ord="" + nid + ""&ptype=1"";" & vbcrlf & "   }" & vbcrlf & "       function LVSelectProduct(nid)" & vbcrlf & "   {" & vbcrlf & "               document.getElementById(""Bom_Trees_View"").src = ""../bomlist/bom_trees_view.asp?treeType="
	Response.write treeType
	Response.write treeType
	Response.write "&currTree="
	Response.write currTree
	Response.write "&ord="" + nid + ""&ptype=1"";" & vbcrlf & "   }" & vbcrlf & "       function Left_adSearch(obj){" & vbcrlf & "            var sdivobj=document.getElementById(""adsDiv"");" & vbcrlf & "            if(sdivobj.style.display!=""none""){" & vbcrlf & "                        Left_adClose();" & vbcrlf & "         }else{" & vbcrlf & "                  var x=obj.offsetLeft,y=obj.offsetTop;" & vbcrlf & "                   var obj2=obj;" & vbcrlf & "                   var offsetx=0;" & vbcrlf & "                  while(obj2=obj2.offsetParent){" & vbcrlf & "                          x+=obj2.offsetLeft;" & vbcrlf & "                             y+=obj2.offsetTop;" & vbcrlf & "                      }" & vbcrlf & "                       sdivobj.style.left=x+33+""px"";" & vbcrlf & "                     sdivobj.style.top=y+""px"";" & vbcrlf & "                        sdivobj.style.display=""inline"";" & vbcrlf & "           }" & vbcrlf & "               document.getElementById('adsIF').style.height=document.getElementById('adsIF').contentWindow.document.getElementsByTagName('table')[1].offsetHeight+30+'px';" & vbcrlf & "            document.body.appendChild(sdivobj);"& vbcrlf & "       }" & vbcrlf & "       function refreshOpener(){" & vbcrlf & "               if (opener)" & vbcrlf & "             {" & vbcrlf & "                       if (opener.window.refreshBomInfo)" & vbcrlf & "                       {" & vbcrlf & "                               opener.window.refreshBomInfo();" & vbcrlf & "                 }" & vbcrlf & "               }" & vbcrlf & "       }" & vbcrlf & "//-->" & vbcrlf & "</script>"
	
%>
