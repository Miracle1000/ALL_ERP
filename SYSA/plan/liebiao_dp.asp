<%@ language=VBScript %>
<%
	Response.Charset="UTF-8"
	Response.Buffer = True
	Response.ExpiresAbsolute = Now() - 1
	Response.Buffer = True
	Response.Expires = 0
	Response.CacheControl = "no-cache"
	Response.Expires = 0
	Response.AddHeader "Pragma", "No-Cache"
	Response.Expires = 0
	ZBRLibDLLNameSN = "ZBRLib3205"
	Set zblog = server.createobject(ZBRLibDLLNameSN & ".ZBSysLog")
	zblog.init me
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
	ZBRLibDLLNameSN = "ZBRLib3205"
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
'if v ="" Or isnumeric(v) = False then
			else
				deurl=v
			end if
		end if
	end function
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
	function getConnectionText()
		Dim txt : txt = Application("_sys_connection")
		if len(txt) = 0 Then txt = sdk.database.ConnectionText
		server_1 = Application("_sys_sql_svr")
		sql_1 = Application("_sys_sql_db")
		user_1 = Application("_sys_sql_uid")
		pw_1 = Application("_sys_sql_pwd")
		getConnectionText = txt
	end function
	dim conn
	Set conn = server.CreateObject("adodb.connection")
	conn.open getConnectionText
	dim errmsg
	if err.number=0 then
		errmsg="数据库操作成功！"
	else
		Response.redirect "index4.asp"
	end if
	dim num_dot_xs,num_timeout,num_cpmx_yl
	dim num1_dot
	set rs3=server.CreateObject("adodb.recordset")
	sql3="select num1 from setjm3 where ord=88"
	rs3.open sql3,conn,1,1
	if rs3.eof then
		num1_dot=2
		sqlStr="Insert Into setjm3(ord,num1) values('"
		sqlStr=sqlStr & 88 & "','"
		sqlStr=sqlStr & num1_dot & "')"
		Conn.execute(sqlStr)
	else
		num1_dot=rs3("num1")
	end if
	rs3.close
	set rs3=nothing
	set rs3=server.CreateObject("adodb.recordset")
	sql3="select num1 from setjm3  where ord=1"
	rs3.open sql3,conn,1,1
	if rs3.eof then
		num_dot_xs=2
		sqlStr="Insert Into setjm3(ord,num1) values('"
		sqlStr=sqlStr & 1 & "','"
		sqlStr=sqlStr & num_dot_xs & "')"
		Conn.execute(sqlStr)
	else
		num_dot_xs=rs3("num1")
	end if
	rs3.close
	set rs3=nothing
	set rs3=server.CreateObject("adodb.recordset")
	sql3="select num1 from setjm3 where ord=87"
	rs3.open sql3,conn,1,1
	if rs3.eof then
		hl_dot=2
		sqlStr="Insert Into setjm3(ord,num1) values('"
		sqlStr=sqlStr & 87 & "','"
		sqlStr=sqlStr & hl_dot & "')"
		Conn.execute(sqlStr)
	else
		hl_dot=rs3("num1")
	end if
	rs3.close
	set rs3=nothing
	set rs3=server.CreateObject("adodb.recordset")
	sql3="select num1 from setjm3  where ord=2"
	rs3.open sql3,conn,1,1
	if rs3.eof then
		num_timeout=120
		sqlStr="Insert Into setjm3(ord,num1) values('"
		sqlStr=sqlStr & 2 & "','"
		sqlStr=sqlStr & num_timeout & "')"
		Conn.execute(sqlStr)
	else
		num_timeout=rs3("num1")
	end if
	rs3.close
	set rs3=nothing
	set rs3=server.CreateObject("adodb.recordset")
	sql3="select num1 from setjm3  where ord=3"
	rs3.open sql3,conn,1,1
	if rs3.eof then
		num_cpmx_yl=500
		sqlStr="Insert Into setjm3(ord,num1) values('"
		sqlStr=sqlStr & 3 & "','"
		sqlStr=sqlStr & num_cpmx_yl & "')"
		Conn.execute(sqlStr)
	else
		num_cpmx_yl=rs3("num1")
	end if
	rs3.close
	set rs3=nothing
	set rs3=server.CreateObject("adodb.recordset")
	sql3="select intro from setjm3  where ord=6"
	rs3.open sql3,conn,1,1
	if rs3.eof then
		title_xtjm=""
	else
		title_xtjm=rs3("intro")
	end if
	rs3.close
	set rs3=nothing
	session.timeout=num_timeout
	session("adminokzbintel") = "true2006chen"
	session("personzbintel2007")= "63"
	if session("adminokzbintel")<>"true2006chen" or session("personzbintel2007")="" then
		Response.write" <script language='javascript'>alert(""请重新登陆！"");top.location.href ='../index2.asp'; </script>"
		call db_close : Response.end
	end if
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
	Private Function getIP()
		Dim strIPAddr
		If Request.ServerVariables("HTTP_X_FORWARDED_FOR") = "" OR InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), "unknown") > 0 Then
			strIPAddr = Request.ServerVariables("REMOTE_ADDR")
		ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ",") > 0 Then
			strIPAddr = Mid(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), 1, InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ",")-1)
'ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ",") > 0 Then
		ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ";") > 0 Then
			strIPAddr = Mid(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), 1, InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ";")-1)
'ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ";") > 0 Then
		else
			strIPAddr = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
		end if
		getIP = Trim(Mid(strIPAddr, 1, 30))
	end function
	Function GetUrl()
		Dim ScriptAddress,Servername,qs
		ScriptAddress = CStr(Request.ServerVariables("SCRIPT_NAME"))
		Servername = CStr(Request.ServerVariables("Server_Name"))
		qs=Request.QueryString
		if qs<>"" then
			GetUrl = ScriptAddress &"?"&qs
		else
			GetUrl = ScriptAddress
		end if
	end function
	function operationsystem()
		dim agent
		agent = Request.ServerVariables("HTTP_USER_AGENT")
		if Instr(agent,"NT 5.2")>0 then
			SystemVer="Windows Server 2003"
		elseif Instr(agent,"NT 5.1")>0 then
			SystemVer="Windows XP"
		elseif Instr(agent,"NT 5.0")>0 then
			SystemVer="Windows 2000"
		elseif Instr(agent,"NT 4.0")>0 or Instr(agent,"NT 3.1")>0 or Instr(agent,"NT 3.5")>0 or Instr(agent,"NT 3.51 ")>0 then
			SystemVer="老版本Windows NT4"
		elseif Instr(agent,"4.9")>0 then
			SystemVer="Windows ME"
		elseif Instr(agent,"98")>0 then
			SystemVer="Windows 98"
		elseif Instr(agent,"95")>0 then
			SystemVer="Windows 95"
		elseif Instr(agent,"Vista")>0 then
			SystemVer="Windows Vista"
		elseif Instr(agent,"Windows 7")>0 then
			SystemVer="Windows 7"
		elseif Instr(agent,"Windows 8")>0 then
			SystemVer="Windows 8"
		elseif Instr(agent,"Server 2008 R2")>0 then
			SystemVer="Windows Server 2008 R2"
		elseif Instr(agent,"Server 2008")>0 then
			SystemVer="Windows Server 2008"
		elseif Instr(agent,"Server 2010")>0 then
			SystemVer="Windows Server 2010"
		elseif Instr(agent,"NT 6.2")>0 then
			SystemVer="Windows Slate"
		elseif Instr(agent,"CE")>0 then
			SystemVer="Windows CE"
		elseif Instr(agent,"PE")>0 then
			SystemVer="Windows PE"
		else
			SystemVer=""
		end if
		operationsystem=SystemVer
	end function
	function browser()
		dim agent
		agent = Request.ServerVariables("HTTP_USER_AGENT")
		if Instr(agent,"MSIE 6.0")>0 then
			browserVer="Internet Explorer 6.0"
		elseif Instr(agent,"MSIE 5.5")>0 then
			browserVer="Internet Explorer 5.5"
		elseif Instr(agent,"MSIE 5.01")>0 then
			browserVer="Internet Explorer 5.01"
		elseif Instr(agent,"MSIE 5.0")>0 then
			browserVer="Internet Explorer 5.00"
		elseif Instr(agent,"MSIE 4.0")>0 then
			browserVer="Internet Explorer 4.0"
		elseif Instr(agent,"TencentTraveler")>0 then
			browserVer="腾讯 TT"
		elseif Instr(agent,"Firefox")>0 then
			browserVer="Firefox"
		elseif Instr(agent,"Opera")>0 then
			browserVer="Opera"
		elseif Instr(agent,"Wap")>0 then
			browserVer="Wap浏览器"
		elseif Instr(agent,"Maxthon")>0 then
			browserVer="Maxthon"
		elseif Instr(agent,"MSIE 7.0")>0 then
			browserVer="Internet Explorer 7.0"
		elseif Instr(agent,"MSIE 8.0")>0 then
			browserVer="Internet Explorer 8.0"
		else
			browserVer=""
		end if
		browser=browserVer
	end function
	sub close_list(args)
		open_rz_system = Application("_open_rz_system")
		if len(open_rz_system) = 0 then
			set rs3=server.CreateObject("adodb.recordset")
			sql3="select intro from setjm where ord=802"
			rs3.open sql3,conn,1,1
			if rs3.eof then
				open_rz_system=0
			else
				open_rz_system=rs3("intro")
			end if
			Application("_open_rz_system")=open_rz_system
			rs3.close
			set rs3=nothing
		end if
		if open_rz_system="1" then
			dim action_url,type_sys,type_brower
			action_url=GetUrl()
			type_sys=operationsystem()
			type_brower=browser()
			type_login=args
			sqlStr="Insert Into action_list(username,name,page1,time_login,type_sys,type_brower,type_login,action1) values("
			sqlStr=sqlStr & session("personzbintel2007") & ",'"
			sqlStr=sqlStr & session("name2006chen") & "','"
			sqlStr=sqlStr & action_url & "','"
			sqlStr=sqlStr & now & "','"
			sqlStr=sqlStr & type_sys & "','"
			sqlStr=sqlStr & type_brower & "',"
			sqlStr=sqlStr & type_login & ",'"
			sqlStr=sqlStr & action1 & "')"
			Conn.execute(sqlStr)
		end if
		conn.close
		set conn=nothing
	end sub
	function AccCanModify(urd)
		dim funcsql,funcrs
		set funcrs=server.CreateObject("adodb.recordset")
		funcsql="SELECT count(1) as c, isnull(max(a.ord),0) as ord FROM gate a "&_
		"INNER JOIN [power] b ON a.ord=b.ord AND b.sort1=66 AND b.sort2=13 AND b.qx_open=1 "&_
		"INNER JOIN [power] c ON a.ord=c.ord AND c.sort1=66 AND c.sort2=1 AND c.qx_open=3 "&_
		"INNER JOIN [power] d ON a.ord=d.ord AND d.sort1=66 AND d.sort2=14 AND d.qx_open=3 "&_
		"INNER JOIN [power] e ON a.ord=e.ord AND e.sort1=66 AND e.sort2=3 AND e.qx_open=3 "&_
		"INNER JOIN [power] f ON a.ord=f.ord AND f.sort1=66 AND f.sort2=2 AND f.qx_open=3 "&_
		"INNER JOIN [power] g ON a.ord=g.ord AND g.sort1=66 AND g.sort2=12 AND g.qx_open=1 "&_
		"WHERE a.del=1"
		funcrs.open funcsql,conn,1,1
		AccCanModify=True
		if not funcrs.eof then
			if funcrs("c").value = 1 and funcrs("ord").value =clng(urd) then
				AccCanModify=false
			end if
		end if
		funcrs.close
		set funcrs=nothing
	end function
	Function bytes2BSTR(arrBytes)
		on error resume next
		Dim strReturn,i,ThisCharCode,NextCharCode
		If Len(arrBytes&"")=0 Then Exit Function
		strReturn = ""
		For i = 1 To Len(arrBytes)
			ThisCharCode = Asc(Mid(arrBytes, i, 1))
			If ThisCharCode < &H80 Then
				strReturn = strReturn & Chr(ThisCharCode)
			else
				NextCharCode = Asc(Mid(arrBytes, i+1, 1))
				strReturn = strReturn & Chr(ThisCharCode)
				strReturn = strReturn & Chr(CLng(ThisCharCode) * &H100 + CInt(NextCharCode))
'strReturn = strReturn & Chr(ThisCharCode)
				i = i + 1
				strReturn = strReturn & Chr(ThisCharCode)
			end if
		next
		bytes2BSTR = strReturn
	end function
	Sub db_close
		on error resume next
		If typename(conn) <> "Empty" And typename(conn) <> "Nothing" then
			conn.close
			Set conn = Nothing
		end if
	end sub
	function iif(byval cv,byval ov1,byval ov2)
		if cv then iif=ov1 : exit function
		iif=ov2
	end function
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
	Response.write "" & vbcrlf & "<form name=""formSearch"" id=""formSearch"" method=""get"" action=""?reportType="
	Response.write request("reportType")
	Response.write """ style=""margin:0"">" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "        <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "      <td colspan=""2""><a href=""javascript"" class=""AfterQuickSearch"" onClick=""document.getElementById('More_Searchs').style.display='';document.getElementById('search_tj').style.display='none';return false;""><img class=""resetElementHidden"" src=""../images/icon_title.gif"" width=""18"" height=""7"" border=""0""><img class=""resetElementShowNoAlign"" src=""../skin/default/images/MoZihometop/leftNav/expand.png"" style=""display:none;"" width=""18"" height=""7"" border=""0""><u><font class=""advanSearch"">正常状态</font></u></a></td>" & vbcrlf & "        </tr>" & vbcrlf & "                <tr onMouseOut=this.style.backgroundColor=""" & vbcrlf & "onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf &            "<td><div align=""right"">类型：</div></td>" & vbcrlf &        "   <td><input type=""checkbox"" name=""rc_type"" value=""1"">日报<input type=""checkbox"" name=""rc_type"" value=""2"">周报<input type=""checkbox"" name=""rc_type"" value=""3"">月报<input type=""checkbox"" name=""rc_type"" value=""4"">年报</td>" & vbcrlf & "          </tr>" & vbcrlf & "           <tr onMouseOut=this.style.backgroundColor="""" onMouseOver=this.style.backgroundColor=""ecf5ff"">" & vbcrlf & "            <td><div align=""right"">被点评人选择：</div></td>" & vbcrlf & "          <td>"
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
	Response.write "</td>" & vbcrlf & "    </tr>" & vbcrlf & "           <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "             <td><div align=""right"">计划内容：</div></td>" & vbcrlf & "      <td><input name=""intro1"" type=""text"" id=""intro1"" size=""48""></td>" & vbcrlf & "          </tr>" & vbcrlf & "           <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "             <td><div align=""right"">总结内容：</div></td>" & vbcrlf & "      <td><input name=""intro2"" type=""text"" id=""intro2"" size=""48""></td>" & vbcrlf & "      </tr>" & vbcrlf & "           <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "             <td><div align=""right"">点评内容：</div></td>" & vbcrlf & "      <td><input name=""intro3"" type=""text"" id=""intro3"" size=""48""></td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "             <td><div align=""right"">开始时间：</div></td>" & vbcrlf & "      <td>"
	type_tj_v = request.querystring("type_tj")
	If Len(type_tj_v & "") = 0 Then
		type_tj_v = request.form("type_tj")
		If Len(type_tj_v) > 0 then
			type_tj = type_tj_v
		end if
	end if
	Response.write "&nbsp;自：<INPUT readonly=""true"" name=ret size=9  id=daysOfMonthPos  onmousedown=""datedlg.show()"" value="""
	Response.write m1
	Response.write """>&nbsp;至：<INPUT name=ret2 readonly=""true"" size=9  id=daysOfMonth2Pos onmousedown=""datedlg.show()"" value="""
	Response.write m2
	Response.write """>&nbsp;<input type='hidden' name='type_tj' value='"
	Response.write type_tj_v
	Response.write "'>"
	Response.write "</td>" & vbcrlf & "            </tr>" & vbcrlf & "           <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "             <td><div align=""right"">截止时间：</div></td>" & vbcrlf & "      <td>"
	Response.write "&nbsp;自：<INPUT readonly=""true"" name=ret3 size=9  id=daysOfMonth3Pos onmouseup=""toggleDatePicker('daysOfMonth3','date.ret3')"" value="""
	Response.write m3
	Response.write """><DIV id=daysOfMonth3 style=""POSITION: absolute;""></DIV>&nbsp;至：<INPUT name=ret4 readonly=""true""  size=9  id=daysOfMonth4Pos onmouseup=""toggleDatePicker('daysOfMonth4','date.ret4')"" value="""
	Response.write m4
	Response.write """>" & vbcrlf & "                   <DIV id=daysOfMonth4 style=""POSITION: absolute""></DIV>" & vbcrlf & "<SCRIPT language=JavaScript1.2>" & vbcrlf & "" & vbcrlf & "    function Cancel() {" & vbcrlf & "            hideElement(""daysOfMonth"");" & vbcrlf & "    }" & vbcrlf & "" & vbcrlf & "</SCRIPT>" & vbcrlf& "" & vbcrlf & "<SCRIPT language=JavaScript1.2>" & vbcrlf & "<!--" & vbcrlf & "hideElement('daysOfMonth3');" & vbcrlf & "hideElement('daysOfMonth4');" & vbcrlf & "//-->" & vbcrlf & "</SCRIPT>"
	Response.write m4
	Response.write "</td>" & vbcrlf & "            </tr>" & vbcrlf & "           <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "           <td width=""10%"">&nbsp;</td>" & vbcrlf & "       <td width=""90%""><input type=""submit"" name=""Submit45"" value=""检索""  class=""page""/>&nbsp;&nbsp;<input type=""reset"" value=""重填"" class=""page"" name=""B2""></td>" & vbcrlf & "     </tr>" & vbcrlf & "" & vbcrlf & "</table>" & vbcrlf & "</form>" & vbcrlf & ""
	conn.close
	set conn=nothing
	
%>
