<%@ language=VBScript %>
<%
	Response.CharSet = "UTF-8"
	Response.ContentType = "text/html"
	Response.Expires = -9999
	'Response.ContentType = "text/html"
	Response.AddHeader "Pragma", "no-cache"
	'Response.ContentType = "text/html"
	Response.AddHeader "Cache-control", "no-cache"
	'Response.ContentType = "text/html"
	Response.Buffer = True
	Response.ExpiresAbsolute = Now - 1000
	'Response.Buffer = True
	Response.Expires = 0
	sub AppEnd()
		call db_close : Response.end
	end sub
	function zbcdbl(byval v)
		if len(v & "") = 0 then  zbcdbl = 0 : exit function
		zbcdbl = 0
		on error resume next
		zbcdbl = cdbl(v & "")
	end function
	function IsNumeric(byval v)
		dim r :  r = ""
		if len(v & "")=0 then IsNumeric = false : exit function
		on error resume next
		r  = replace((v & ""),",","")*1
		IsNumeric = len(r & "") >0
	end function
	ZBRLibDLLNameSN = "ZBRLib3205"
	Set zblog = server.createobject(ZBRLibDLLNameSN & ".ZBSysLog")
	zblog.init me
	Class DBCommand
		public CreateAutoField
		public conn
		Public Property Get user
		user = Session("_sys_db_user")
		End Property
		Private Sub Class_Initialize()
			Set conn =  nothing
		end sub
		Private Sub Class_Terminate()
			If Not conn Is Nothing Then
				on error resume next
			end if
		end sub
		Public Property Get password
		password = Session("_sys_db_pass")
		End Property
		Private Function DeCrypt(c)
			Dim A_Key
			A_Key = split("96,44,63,80",",")
			Dim strChar, iKeyChar, iStringChar, I_pro,k_pro,strDecrypted,iDeCryptChar
			k_pro=0
			for I_pro = 1 to Len(c)
				iKeyChar =cint(A_Key(k_pro))
				iStringChar = Asc(mid(c,I_pro,1))
				iDeCryptChar = iKeyChar Xor iStringChar
				If k_pro<3 Then
					k_pro=k_pro+1
'If k_pro<3 Then
				else
					k_pro=0
				end if
				strDecrypted = strDecrypted & Chr(iDeCryptChar)
			next
			DeCrypt = strDecrypted
		end function
		Public Function getConnectionText()
			Dim txt : txt = Application("_sys_connection")
			if len(txt) = 0 Then
				Dim comm
				Set comm = server.createobject(ZBRLibDLLNameSN & ".CommClass")
				txt = comm.database.ConnectionText
				Set comm = nothing
			end if
			getConnectionText = txt
		end function
		Public Function getConnection()
			Dim connText
			if request.querystring("updateconnection")="1" then
				Application("_sys_connection") = ""
			end if
			connText = Application("_sys_connection") & ""
			If Len(connText) = 0 Then
				connText =  getConnectionText()
			end if
			Set conn = server.CreateObject("adodb.connection")
			on error resume next
			conn.open (connText)
			conn.cursorlocation = 3
			If Application("__nosqlcahace")="1" Then conn.execute "DBCC DROPCLEANBUFFERS"
			conn.CommandTimeout = 600
			if abs(err.number) > 0 then
				Response.write "数据库链接失败 - [" & err.Description & "]"
'if abs(err.number) > 0 then
				call AppEnd
			end if
			Set getConnection = conn
		end function
		Public Sub CreateDbTableByRecordSet(tname,rs)
			Dim sql , i , nrs
			On Error goto 0
			sql = "if exists (select * from dbo.sysobjects where id = object_id(N'" & tname & "')) drop table " & tname & vbcrlf & vbcrlf
			sql = sql & "CREATE TABLE " & tname & "(" & vbcrlf
			For i = 0 To rs.fields.count -1
				sql = sql & "CREATE TABLE " & tname & "(" & vbcrlf
				sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
				If i <  rs.fields.count -1 Then sql = sql & "," & vbcrlf
				sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
			next
			if CreateAutoField = true then
				sql = sql & ",[autokeyindex] [int] IDENTITY(1,1) NOT NULL" & vbcrlf
			end if
			sql = sql & ")"
			cn.execute sql
			Set nrs = server.CreateObject("adodb.recordset")
			nrs.open "select * from " & tname, cn, 1,3
			While not rs.eof
				nrs.addnew
				For i = 0 To rs.fields.count - 1
					nrs.addnew
					nrs.fields(i).value = rs.fields(i).value
				next
				nrs.update
				rs.movenext
			wend
		end sub
		Public Sub CreateDbTableBySql(tname,sqlText)
			Dim sql , i , rs
			On Error goto 0
			set rs = cn.execute(sqltext)
			sql = "if exists (select * from dbo.sysobjects where id = object_id(N'" & tname & "')) drop table " & tname & vbcrlf & vbcrlf
			sql = sql & "CREATE TABLE " & tname & "(" & vbcrlf
			For i = 0 To rs.fields.count -1
				sql = sql & "CREATE TABLE " & tname & "(" & vbcrlf
				sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
				If i <  rs.fields.count -1 Then sql = sql & "," & vbcrlf
				sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
			next
			if CreateAutoField = true then
				sql = sql & ",[autokeyindex] [int] IDENTITY(1,1) NOT NULL" & vbcrlf
			end if
			sql = sql & ")" & vbcrlf
			sql = sql & "insert into " & tname & "("
			For i = 0 To rs.fields.count -1
				sql = sql & "insert into " & tname & "("
				sql = sql  & "[" & rs.fields(i).name & "]"
				If i <  rs.fields.count -1 Then sql = sql & ","
				sql = sql  & "[" & rs.fields(i).name & "]"
			next
			sql = sql & ")" & vbcrlf  & sqltext
			cn.execute sql
		end sub
		Public function GetDbColText(rs)
			Dim sql , i
			on error resume next
			For i = 0 To rs.fields.count -1
'Dim sql , i
				sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
				If i <  rs.fields.count -1 Then sql = sql & "," & vbcrlf
				sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
			next
			GetDbColText = Replace(Replace(sql & "@###",",@###",""),"@###","")
		end function
		Public Function GetSqlDBTypeText(fld)
			Dim r , fSize
			fSize = fld.DefinedSize
			if fSize = 0 then fSize = 1000
			Select Case fld.type
			Case 2:r = "[int]"
			Case 3:r = "[int]"
			Case 4:r = "[float](8)"
			Case 5:r = "[float](12)"
			Case 6:r = "[money]"
			Case 7:r = "[DateTime]"
			Case 11:r = "[bit]"
			Case 14:r = "[decimal]"
			Case 16:r = "[Int]"
			Case 17:r = "[Int]"
			Case 18:r = "[Int]"
			Case 19:r = "[Int]"
			Case 20:r = "[BigInt]"
			Case 21:r = "[BigInt]"
			Case 64:r = "[dateTime]"
			Case 128:r = "[Binary](" & fSize & ")"
			Case 129:r = "[Char](" & fSize & ")"
			Case 130:r = "[nChar](" & fSize & ")"
			Case 131:r = "[Numeric](" & fSize & "," & fld.NumericScale & ")"
			Case 133:r = "[dateTime]"
			Case 134:r = "[dateTime]"
			Case 135:r = "[dateTime]"
			Case 139:r = "[Numeric](" & fSize & "," & fld.NumericScale & ")"
			Case 200:r = "[VarChar](" & fSize & ")"
			Case 201:r = "[text]"
			Case 202:r = "[nVarChar](" & fSize & ")"
			Case 203:r = "[ntext]"
			Case 204:r = "[Binary](" & fSize & ")"
			Case 205:r = "[Binary](" & fSize & ")"
			Case 8192:r = "[Binary](" & fSize & ")"
			Case Else:r = "[varchar](" & fSize & ")"
			End Select
			GetSqlDBTypeText = r
		end function
		Public Function getTypeById(typeId)
			Dim r
			If (typeId > 1 And typeId < 7) Or (typeId > 15 And typeID < 22 ) Or typeId - 131 = 0 Then
'Dim r
				r = "number"
			else
				Select Case typeId
				Case 7: r = "date"
				Case 11: r = "bit"
				Case 64: r = "date"
				Case 133: r = "date"
				Case 134: r = "date"
				Case 135: r = "date"
				Case Else: r= "text"
				End Select
			end if
			getTypeById = r
		end function
	End Class
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
		'	Dim z : Set z = server.createobject(ZBRLibDLLNameSN & ".Library")
		'	z.GetLibrary "ZBIntel2013CheckBitString"
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
	Public Function ExistsProc(subName)
		on error resume next
		Call TypeName(getref(subName))
		ExistsProc = (Len(Err.description)=0)
		Err.clear
	end function
	Sub loadzblogobj
		On Error Resume Next : app.zblog = zblog
	end sub
	Sub App_bll_ajax_page
		Dim k : k = request.form("key")
		Dim ap : Set ap = Server.createobject(ZBRLibDLLNameSN & ".AjaxPageClass")
		k = Replace(Replace(Replace(Replace(Replace(k & ""," ", ""), "(", ""), ":", ""), ",", ""), vbcrlf, "")
		If App.existsProc("bill_AjaxWindow_" & k) Then
			execute "call bill_AjaxWindow_" & k & " ( ap ) "
		else
			Response.write "<div style='padding:10px'>'您需要在服务器端定义过程:<br>sub bill_AjaxWindow_" & k & "(byval win)<br><br>end sub</div>"
		end if
		ap.ReturnAjaxJoin
		Set ap = nothing
	end sub
	Function GetSetJm3Value(keysign,  nullvalue)
		If isnumeric(nullvalue) And Len(nullvalue & "")>0 then
			GetSetJm3Value = sdk.setup.GetSetjm3(keysign, nullvalue)
		else
			GetSetJm3Value = sdk.setup.GetSetjm3Text(keysign, CLng("0" & nullvalue) )
		end if
	end function
	Function IsNetProduce()
		Dim jm2017112116 : jm2017112116 = GetSetJm3Value(2017112116, 0)
		if ZBRuntime.MC(35000) = False  And ZBRuntime.MC(18100)=false Then
			jm2017112116 = -1
'if ZBRuntime.MC(35000) = False  And ZBRuntime.MC(18100)=false Then
		else
			If ZBRuntime.MC(35000) = False Then
				jm2017112116 = 0
			ElseIf  ZBRuntime.MC(18100)=false  Then
				jm2017112116 = 1
			end if
		end if
		IsNetProduce = (jm2017112116=0)
	end function
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
	function GetHttpType
		dim loginurl
		loginurl = session("clientloginurl")
		if instr(1, loginurl, "https://", 1)>0 then
			GetHttpType = "https"
		else
			GetHttpType = "http"
		end if
	end function
	Sub Main
		dim db , msgId , formproxy
		If Application("sys.info.SaasModel") = "" Then Server.Createobject  ZBRLibDLLNameSN & ".Library"
		AppDataVersion= Application("sys.info.jsver")
		AppDataVersion = split(AppDataVersion&".",".")(0)
		if AppDataVersion&""="" then AppDataVersion = 3100
		Set db = new DBCommand
		Set cn = db.getConnection()
		Set conn = cn
		Call ProxyUserCheck()
		set app = server.createobject(ZBRLibDLLNameSN & ".PageClass")
		app.init Me, 1
		Set ZBRuntime = app.Library
		If ZBRuntime.SplitVersion <3173 Then Response.write "<br><br><br><br><center style='color:red;font-size:12px'>系统提示：运行库组件版本不正确。</center>" : Response.end
'		Set ZBRuntime = app.Library
'		If ZBRuntime.loadOK Then
'			ZBRuntime.getLibrary "ZBIntel2013CheckBitString"
'			If ZBRuntime.loadOK then
'				if app.isMobile then
'					response.clear
'					response.CharSet = "utf-8"
'					response.clear
'					Response.BinaryWrite app.base64.UnicodeToUtf8("系统【服务端】未正常启动，请检查服务器环境是否正常。")
'					Response.end
'				else
'					Response.write "<script>top.window.location.href ='" & app.virpath & "index2.asp?id2=8'</script>"
'				end if
'				Set app = Nothing
'				Set ZBRuntime = Nothing
'				Exit Sub
'			end if
'		end if
		set info = server.createobject(ZBRLibDLLNameSN & ".AppInfo")
		Info.init Me
		Set sdk = app.sdk
		If Not app.init(Me) Then
			If App.ExistsProc("App_UserNoLogin") = False Then
				If app.IsMobile Then Call App.mobile.flush
				cn.close
				set info  = nothing
				set app = nothing
				Set cn = nothing
				Exit Sub
			else
				Call App_UserNoLogin
			end if
		else
			dim uid : uid =  Info.User
			if uid>0 then
				if cn.execute("select 1 from gate where ord=" & uid & " and del=1").eof then
					uid = 0
				end if
			end if
			If uid = 0 Then
				If  App.ExistsProc("App_UserNoLogin") = False Then
					If request.querystring("apihelp") <> "1" then
						Response.write "<script>top.window.location.href ='" & app.virpath & "index2.asp?sign=nologincomm'</script>"
						cn.close
						set info  = nothing
						set app = nothing
						Set cn = Nothing
						Exit Sub
					end if
				else
					call App_UserNoLogin
				end if
			end if
		end if
		Call loadzblogobj
		Call checkSuperDog(cn, app.virpath , app.IsMobile )
		formproxy = False
		If app.IsMobile Then Response.clear
		if instr(lcase(request.ServerVariables("content_type")),"multipart/form-data")=0 _
		and instr(lcase(request.ServerVariables("content_type")),"json")=0 _
		and instr(lcase(request.ServerVariables("content_type")),"zsml")=0 _
		and instr(lcase(request.ServerVariables("content_type")),"xml")=0 _
		and (request.querystring("isfile") & "") <> "1" _
		and (request.querystring("apihelp") & "") <> "1" then
			msgId =  request.form("__msgId")
			formproxy = request("__formproxymodel") = "1"
		end if
		if len(msgId) = 0 then  msgId = request.QueryString("__msgId")
		if lcase(msgid) <> "setthreathcontrol" then
			session("sys_userlastvistime") = now
		end if
		msgId = Replace(Replace(Replace(msgId, ":", ""), "(", ""), """","")
		msgId = Replace(msgId, " ", "")
		If formproxy Then Response.write "<body><!--__formproxy.init" & vbcrlf
		msgId = Replace(msgId, " ", "")
		If msgId = "" Then
			If app.IsMobile Then
				If Len(app.mobile.post.cmdkey & "") >0 Then
					msgId = app.mobile.post.cmdkey
				else
					msgId = request.querystring("action")
				end if
			end if
		end if
		select case msgId
		case "__sys_ajax_clientE_Fun"
		call app_sys_ajx_clientE_Fun
		case "sys_lvw_callback"
		call app_sys_lvw_callback
		case "sys_treeviewCallBack"
		call app_sys_treeviewCallBack
		case "sys_menuviewcallback"
		call app_sys_menuviewCallBack
		case "sys_TabSriptloadItem"
		call App_Sys_OnLoadTabItem
		case "sys_ctl_cardloaditem"
		call App_sys_cardloaditem
		Case "sys_ctl_cardcloseitem"
		call App_sys_cardcloseitem
		case "sys_getsystime"
		call app.returnSysTime
		Case "sys_lvwshowfull"
		Call app_sys_lvwshowfull
		Case "sys_urldecode"
		Response.write request.form("v")
		Case "sys_saveprintLog"
		app.Log.remark = app.getText("title") & ".打印"
		case Else
		If App.ExistsProc("MessagePost") Then
			call MessagePost(msgId)
		else
			If msgId = "" Then
				If App.ExistsProc("Page_load") Then
					Call Page_load
				else
					Response.write "页面没用定义 Page_load 启动过程"
				end if
			else
				App.TryExecuteProc "App_" & msgId
			end if
		end if
		end Select
		app.onpagecomplete
		on error resume next
		cn.close
		If formproxy Then Response.write vbcrlf & "__formproxy.end--></body>"
		cn.close
		If app.IsMobile Then
			If Err.number<>0 Then app.mobile.document.body.CreateModel("message","").text = "服务器异常: 【"& Err.description & "】"
			Call App.mobile.flush
		end if
		set cn = Nothing
		set conn = nothing
		set info  = Nothing
		Set sdk = nothing
		set app = Nothing
		Set zbruntime = nothing
	end sub
	Sub db_close
		on error resume next
		If typename(cn) <> "Empty" And typename(cn) <> "Nothing" then
			cn.close
			conn.close
			Set cn = Nothing
			set conn = nothing
		end if
	end sub
	Public Function ShowApihelp(ByVal title, ByVal returnmodels, ByVal cmdkey)
		If app.ApiHelpModel = False Then showApihelp = False: Exit Function
		app.mobile.Document.ClearPost
		execute sdk.vbs(app.virpath & "apidoc/item.asp")
		showApihelp = True
	end function
	Sub clearBHTempRec(bhConfigId)
		cn.execute "delete BHTempTable where configId="&bhConfigId&" and addCate=" & session("personzbintel2007")
	end sub
	Sub app_sys_ajx_clientE_Fun
		Dim serverFun: serverFun = app.gettext("serverFun")
		serverFun = Replace(Replace(Replace(Replace(Replace(Replace(serverFun,vbcr,""), vblf, ""), "(",""), " ", ""), ".",""),":","")
		If app.existsProc(serverFun) Then
			execute serverFun
		else
			app.window.alert "提示：当前挂载的事件【" & serverFun & "】未注册。"
		end if
	end sub
	Public Function GetKzzdyTable(ByVal tid)
		Select Case CLng(tid)
		Case 1:  GetKzzdyTable = "tel"
		Case 3:  GetKzzdyTable = "chance"
		Case 5:  GetKzzdyTable = "contract"
		Case 21: GetKzzdyTable = "product"
		Case 22: GetKzzdyTable = "caigou"
		Case 28: GetKzzdyTable = "caigouQC"
		Case 41: GetKzzdyTable = "contractth"
		Case 45: GetKzzdyTable = "repair_sl"
		Case 88: GetKzzdyTable = "tousu"
		Case 95: GetKzzdyTable = "payback"
		Case 96: GetKzzdyTable = "paybackinvoice"
		Case 1001: GetKzzdyTable = "payjk"
		Case Else: GetKzzdyTable = ""
		End Select
	end function
	Public Function GetKzzdyKeyField(ByVal tid)
		Select Case CLng(tid)
		Case 96: GetKzzdyKeyField = "id"
		Case Else: GetKzzdyKeyField = "ord"
		End Select
	end function
	public function AddFullLog(byval cls,  byval data)
		dim i, islogmodel
		islogmodel = application("__sys_local_fulllog_model")
		if islogmodel = "" then
			dim configv :  configv = sdk.file.ReadAllText( server.MapPath(app.virpath & "../Web.config") )
			islogmodel = instrb(1, configv, "key=""LocalFullLogModel"" value=""1""", 1)
			if islogmodel > 0 then
				application("__sys_local_fulllog_model")   = "1"
			else
				application("__sys_local_fulllog_model")   = "0"
			end if
			islogmodel =        application("__sys_local_fulllog_model")
		end if
		if islogmodel = "0" then exit function
		dim vs : vs = split("\,/,:,*,?,"",<,>,|",",")
		for i = 0 to ubound(vs)
			cls = replace(cls, vs(i), "")
		next
		dim logf : logf = server.MapPath(app.virpath & "manager/logfiles/fulllog." & lcase(cls)  & ".gbk.txt")
		sdk.file.AppendText logf,  "【" &  now & "】【" & info.User & "】【" & info.UserName & "】" & vbcrlf &  data &vbcrlf
	end function
	dim cn ,conn, info , app, zblog, sdk, ZBRuntime , AppDataVersion
	call Main
	
	Sub messagePost(msgid)
		If msgid = "" then
			Call Page_Load
		ElseIf msgid = "checkMoney" Then
			Call App_checkMoney
		end if
	end sub
	Sub Page_Load
		Dim ord, headtitle ,rs ,title,sort,obj_ord,  bh ,setbz, bz ,intro ,mode ,mxcss, money1, spord ,sp ,cateid_sp,status, lead , startdate ,enddate,hzcss, money_hz,money_mx ,updatecss , isupdate
		headtitle="预算添加"
		ord = app.base64.deurl(request("ord"))
		sort=0
		If ord&""<>"" Then
			headtitle="预算修改"
			Set rs= cn.execute("select * from budget where ord=" & ord & " and del=1 ")
			If rs.eof = False Then
				title = rs("title").value
				bh    = rs("bh").value
				mode  = rs("mode").value
				intro = rs("intro").value
				money1=zbcdbl( rs("money1").value)
				sp    = rs("sp").value
				status= rs("status").value
				cateid_sp=rs("cateid_sp").value
				sort  = rs("sort").value
				obj_ord=rs("obj_ord").value
				lead  = sort & "_" & obj_ord
				startdate=rs("startdate").value
				enddate  =rs("enddate").value
				bz    = rs("bz").value
			end if
			rs.close
			spord=ord
		else
			bh   = getNewbh(6201,"budget" , "ord" ,"creator","bh" , "indate")
			ord  = getNeword("budget" , "ord", "creator" , "bh" , "indate", bh)
			mode = 0
			intro=""
			money1=0
			spord=0
			sp   =""
			cateid_sp=0
			status=0
			lead =""
			startdate=""
			enddate  =""
		end if
		money_hz=0
		money_mx=0
		If mode=0 Then
			mxcss=" display: none;"
			money_hz=money1
		else
			hzcss=" display: none;"
			money_mx=money1
		end if
		isupdate=0
		If (sp="0" Or status=2) Then
			updatecss = " style = 'display: none;' "
			mxcss = " display: none;"
			isupdate=1
		end if
		app.addDefaultScript
		Response.write app.DefTopBarHTML(app.virPath, "", headtitle, "")
		Response.write "" & vbcrlf & "      <style>" & vbcrlf & "         .label{" & vbcrlf & "                 width:140px;" & vbcrlf & "                    text-align:right;               " & vbcrlf & "                        padding-right:6px;" & vbcrlf & "" & vbcrlf & "              }" & vbcrlf & "               .labe2{" & vbcrlf & "                 border-top:0px;" & vbcrlf & "                 padding-top:6px;        " & vbcrlf & "                        padding-left:6px;" & vbcrlf & "                }" & vbcrlf & "               #content tr td {height:30px;}" & vbcrlf & "           #content tr.top td{height:30px;}" & vbcrlf & "                html{padding: 0px 10px 0;background: #efefef;box-sizing:border-box;}" & vbcrlf & "            body{background: #ffffff;}" & vbcrlf & "      </style>" & vbcrlf & "        <link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/default/easyui.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write """>" & vbcrlf & " <script type=""text/javascript"" src=""../inc/jquery.easyui.min.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "        <script language=""javascript"">" & vbcrlf & "    function toclick(objname) {" & vbcrlf & "             document.getElementById(objname).click();" & vbcrlf & "       }" & vbcrlf & "       function changeMode(inttype){" & vbcrlf & "           var hz  =document.getElementById(""hz"");" & vbcrlf & "           varmx  =document.getElementById(""mx"");" & vbcrlf & "           var mx_1=document.getElementById(""mx_1"");" & vbcrlf & "         var mx_2=document.getElementById(""mx_2"");" & vbcrlf & "         if (inttype==0)" & vbcrlf & "         {" & vbcrlf & "                       hz.style.display="""";" & vbcrlf & "                      mx.style.display=""none"";" & vbcrlf & "mx_1.style.display=""none"";" & vbcrlf & "                        mx_2.style.display=""none"";" & vbcrlf & "                }" & vbcrlf & "               else" & vbcrlf & "            {" & vbcrlf & "                       hz.style.display=""none"";" & vbcrlf & "                  mx.style.display="""";" & vbcrlf & "                      mx_1.style.display="""";" & vbcrlf & "                    mx_2.style.display="""";" & vbcrlf & "                    summation();" & vbcrlf & "            }" & vbcrlf & "       }" & vbcrlf & "" & vbcrlf & "       function summation(){" & vbcrlf & "           var inputs=$("".input"");" & vbcrlf & "           var num_dot_xs="
		Response.write info.MoneyNumber
		Response.write ";" & vbcrlf & "             var val=0;" & vbcrlf & "              var sum=0;" & vbcrlf & "              for (var i=0;i<inputs.length ;i++ )" & vbcrlf & "             {" & vbcrlf & "                       val=inputs[i].value             ;" & vbcrlf & "                       if (val.length==0)" & vbcrlf & "                      {" & vbcrlf & "                               val=0;" & vbcrlf & "                  }" & vbcrlf & "                       sum = (sum* Math.pow(10,num_dot_xs) + val*Math.pow(10,num_dot_xs))/Math.pow(10,num_dot_xs);" & vbcrlf & "                }" & vbcrlf & "               document.getElementById(""money_mx"").value=sum;" & vbcrlf & "    }" & vbcrlf & "" & vbcrlf & "       function expansion(flID){" & vbcrlf & "               var j=document.getElementById(""j_""+flID);" & vbcrlf & "         var flmx=document.getElementById(""flmx_""+flID);" & vbcrlf & "             var flmxbt=document.getElementById(""flmxbt_""+flID);" & vbcrlf & "               if (j.innerText==""+"")" & vbcrlf & "             {" & vbcrlf & "                       j.innerText=""-"";" & vbcrlf & "                  flmx.style.display="""";" & vbcrlf & "                    flmxbt.style.borderBottom=""0px"";" & vbcrlf & "          }" & vbcrlf & "               else" & vbcrlf & "            {" & vbcrlf & "                       j.innerText=""+"";" & vbcrlf & "                  flmx.style.display=""none"";" & vbcrlf & "                        flmxbt.style.borderBottom=""#ccc 1px solid"";" & vbcrlf & "               }" & vbcrlf & "       }" & vbcrlf & "       " & vbcrlf & "        function checkMoney()" & vbcrlf & "   {" & vbcrlf & "              var isupdate="
		Response.write isupdate
		Response.write ";" & vbcrlf & "             if (isupdate==1)" & vbcrlf & "                {" & vbcrlf & "                       return true;" & vbcrlf & "            }" & vbcrlf & "               var ret=false;" & vbcrlf & "          ajax.regEvent(""checkMoney"")" & vbcrlf & "               ajax.addParam('ord', "
		Response.write ord
		Response.write ");" & vbcrlf & "            ajax.addParam('lead', $('#lead').val());" & vbcrlf & "                ajax.addParam('startDate', $('#startDate').val());" & vbcrlf & "        ajax.addParam('endDate', $('#endDate').val());" & vbcrlf & "        ajax.addParam('bz', $('#bz').val());" & vbcrlf & "            ajax.addParam('bh', $('#bh').val());" & vbcrlf & "        r=ajax.send()" & vbcrlf & "                if(r==""0"")" & vbcrlf & "                {" & vbcrlf & "                       ret = true;" & vbcrlf & "             }" & vbcrlf & "               else " & vbcrlf & "           {                       " & vbcrlf & "                        if (r==""1"")" & vbcrlf & "                       {" & vbcrlf & "                               $(""#queryresult_enddare"").html(""截止日期必须大于开始日期"");" & vbcrlf & "                       }" & vbcrlf & "                       else if (r==""2"")" & vbcrlf & "                  {" & vbcrlf & "                               $(""#queryresult_bh"").html(""编号重复"");" & vbcrlf & "                      }" & vbcrlf & "                       else" & vbcrlf & "                    {" & vbcrlf & "                               app.Alert(r);" & vbcrlf & "                   }" & vbcrlf & "                       ret= false;" & vbcrlf & "             }" & vbcrlf & "               return ret;" & vbcrlf & "  }" & vbcrlf & "       function checksp()" & vbcrlf & "      {       " & vbcrlf & "                var ret=false;          " & vbcrlf & "                var money1=0;" & vbcrlf & "           if (document.getElementById(""mod1""))" & vbcrlf & "              {" & vbcrlf & "                       if (document.getElementById(""mod1"").checked==true )" & vbcrlf & "                       {       " & vbcrlf & "                        money1=$('#money_hz').val();" & vbcrlf & "                    }" & vbcrlf & "                       else" & vbcrlf & "                    {" & vbcrlf & "                               money1=$('#money_mx').val();" & vbcrlf & "                    }                       " & vbcrlf & "                        if (money1==""0"" || money1=="""")" & vbcrlf & "                      {" & vbcrlf & "                               app.Alert(""预算总额必须大于0"");" & vbcrlf & "                           return ret;" & vbcrlf & "                    }" & vbcrlf & "               }" & vbcrlf & "               var isupdate="
		Response.write isupdate
		Response.write ";" & vbcrlf & "             if (isupdate==1)" & vbcrlf & "                {       " & vbcrlf & "                        return true;" & vbcrlf & "            }" & vbcrlf & "               var sp= document.getElementById(""sp"");" & vbcrlf & "            if (sp.value=="""")" & vbcrlf & "         {       " & vbcrlf & "                        //KILLER IE 11 不能正确执行审批流程问题" & vbcrlf & "                 try" & vbcrlf & "                     {" & vbcrlf & "                            var cateid_sp = document.getElementById(""cateid_sp"");" & vbcrlf & "                             var status =document.getElementById(""status"");    " & vbcrlf & "                                var url=ajax.url;" & vbcrlf & "                               ajax.url=""../inc/CommSPAjax.asp"";" & vbcrlf & "                         ajax.regEvent("""");" & vbcrlf & "                                ajax.addParam('ty',2);"
		Response.write "" & vbcrlf & "                            ajax.addParam('bill', ""budget"");" & vbcrlf & "                          ajax.addParam('money1', money1);" & vbcrlf & "                                ajax.addParam('reback', 1);" & vbcrlf & "                             r=ajax.send();" & vbcrlf & "                          ajax.url=url;" & vbcrlf & "                           var spid=r.split(""$#"")[0];" & vbcrlf & "                                if(spid!=""0"")" &vbcrlf & "                         {" & vbcrlf & "                                       if (window[""console""]){" & vbcrlf & "                                           console.log(""审批返回值：""+r);" & vbcrlf & "                                    }" & vbcrlf & "" & vbcrlf & "                                       var html=""<table width='100%' style='border:1px solid #ccc' cellpadding='6' cellspacing='0' bgcolor='#ccc' id='content'><tr class='top' style='height:35px'><td colspan='2'>&nbsp;&nbsp;<b>请选择下级审批人</b></td></tr><tr><td align='right' style='30%'>下级审批人：</td><td><select id='spord'><option value=''></option>"";" & vbcrlf & "                                       var cates=r.split(""$#"")[1].split(""|"");" & vbcrlf & "                                      for (var i=0 ;i<cates.length ;i++ )" & vbcrlf & "                                     {" & vbcrlf & "                                            if (cates[i].length>0)" & vbcrlf & "                                          {" & vbcrlf & "                                                       html = html + ""<option value='""+ cates[i].split(""="")[0] +""'>""+ cates[i].split(""="")[1] +""</option>"";" & vbcrlf & "                                               }" & vbcrlf & "                                       }" & vbcrlf & "                                       html = html + ""</select> <span class='red'>*</span></td></tr><tr><td colspan=2 align='center'><input type='button' class='oldbutton' value='确定' onclick=\""setsp(""+ spid +"",$('#spord').val())\"">&nbsp;&nbsp;<input type='button' class='oldbutton' value='取消' onclick=\""$('#w').window('close');\""></td></tr></table>"";" & vbcrlf & "                                  document.getElementById(""w"").innerHTML=html;" & vbcrlf & "                                  var inttop=(200+document.documentElement.scrollTop+document.body.scrollTop)+""px"";" & vbcrlf & "                                 $('#w').window({top:inttop});" & vbcrlf & "                                   $('#w').window('open');" & vbcrlf & "                                 ret=false ;" & vbcrlf & "                             }" & vbcrlf & "                               else " & vbcrlf & "                          {" & vbcrlf & "                                       //KILLER 记录日志" & vbcrlf & "                                       if (window[""console""]){" & vbcrlf & "                                           console.log(r);" & vbcrlf & "                                 }" & vbcrlf & "" & vbcrlf & "                                       sp.value=0;" & vbcrlf & "                                     cateid_sp.value=0;" & vbcrlf & "                                      status.value =0;" & vbcrlf & "                                        ret=true;" & vbcrlf & "                         }                               " & vbcrlf & "                        }" & vbcrlf & "                       catch (err)" & vbcrlf & "                     {" & vbcrlf & "                               //KILLER 弹出错误信息" & vbcrlf & "           　　　　app.Alert(""错误名称: "" + err.name + ""\n错误描述: "" + err.message);" & vbcrlf & "                          return false;" & vbcrlf & "                   }" & vbcrlf & "" & vbcrlf & "               }" & vbcrlf & "               else" & vbcrlf & "               {" & vbcrlf & "                        ret=true;" & vbcrlf & "              }" & vbcrlf & "               return ret;" & vbcrlf & "     }" & vbcrlf & "       function setsp(sp,spord)" & vbcrlf & "        {" & vbcrlf & "               if (spord.length>0)" & vbcrlf & "             {" & vbcrlf & "                       document.getElementById(""sp"").value=sp;" & vbcrlf & "                   document.getElementById(""cateid_sp"").value=spord;" & vbcrlf & "                     document.getElementById(""status"").value=1;" & vbcrlf & "                        toclick(""Submit42"");" & vbcrlf & "              }" & vbcrlf & "               else" & vbcrlf & "            {" & vbcrlf & "                       app.Alert(""请选择下级审批人"");" & vbcrlf & "            }" & vbcrlf & "       }" & vbcrlf & "" & vbcrlf & "       </script>" & vbcrlf & "   <form method='POST' action='save.asp?ord="
		Response.write ord
		Response.write "&isupdate="
		Response.write isupdate
		Response.write "' autocomplete='off' id='demo' onsubmit='return Validator.Validate(this,2) && checkMoney() && checksp();' name='date' style='display:inline'>" & vbcrlf & "        <table width=""100%"" id=""content"" > " & vbcrlf & " <tr class=""top resetTableBgColor resetBorderTop"">" & vbcrlf & "         <td class=""label"" colspan=""5""><div align=""left"">&nbsp;<b>基本信息</b></div></td><td class=""label"" style=""position:relative;""><div style=""position:absolute; right:30px; top:8px;line-height:44px""><button classon class='oldbutton' style='margin-right:5px' onclick=""toclick('B2')"" type=""button"">重填</button></div></td>" & vbcrlf & "    </tr>" & vbcrlf & "   <tr>" & vbcrlf & "            <td class=""label"" width='11%'><div align=""right"">预算主题：</div></td>" & vbcrlf & "              <td class=""labe2"" width='"
		Response.write isupdate
		If isupdate=0 Then
			Response.write "44%"
		else
			Response.write "68%"
		end if
		Response.write "' colspan="""
		If isupdate=0 Then
			Response.write "3"
		else
			Response.write "5"
		end if
		Response.write """><div align=""left"">" & vbcrlf & "                          <input name=""title"" type=""text"" size=""40"" id=""title""  dataType=""Limit"" min=""1"" max=""200"" msg=""必须在1到200个字之间"" value="""
		Response.write title
		Response.write """>" & vbcrlf & "                          <span class=""red"" id=""title_tip"">*</span><span id=""queryresult"" class=""red""></span></div>" & vbcrlf & "             </td>" & vbcrlf & "           "
		If isupdate=0 Then
			Response.write "" & vbcrlf & "                     <td class=""label"" "
			Response.write updatecss
			Response.write " width='11%'><div align=""right"">预算编号：</div></td>" & vbcrlf & "                  <td class=""labe2"" "
			Response.write updatecss
			Response.write " width='22%'><div align=""left"">" & vbcrlf & "                                  <input name=""bh"" type=""text"" size=""20"" id=""bh"" value="""
			Response.write bh
			Response.write """ " & vbcrlf & "                                  dataType=""Limit"" min=""1"" max=""100"" msg=""必须在1到100个字之间""" & vbcrlf & "                           class='jquery-auto-bh' autobh-options='cfgId:6201,recId:"
			Response.write bh
			Response.write ord
			Response.write ",autoCreate:false,autoCheck:false' />" & vbcrlf & "                                  <span class=""red"" id=""title_tip"">*</span>&nbsp;" & vbcrlf & "                             <span id=""queryresult_bh"" class=""red""></span></div>" & vbcrlf & "                       </td>" & vbcrlf & "           "
		end if
		Response.write "" & vbcrlf & "     </tr>" & vbcrlf & "   "
		If isupdate=0 Then
			Response.write "" & vbcrlf & "     <tr "
			Response.write updatecss
			Response.write ">" & vbcrlf & "            <td class=""label"" width='11%'><div align=""right"">使用范围：</div></td>" & vbcrlf & "              <td class=""labe2"" width='22%'><div align=""left"">" & vbcrlf & "                    <select name=""lead"" id=""lead"" dataType=""Limit"" min=""1"" max=""60"" msg=""必选"" style=""width:100px;"">" & vbcrlf & "      <option value="""">选择范围</option>" & vbcrlf & "                        "
			Dim W1,W3 ,csql ,ssql, w1sql ,w3sql
			Set rs=cn.execute("select qx_open, w1,w3 from power2 where sort1=4 and cateid=" & Info.User &"")
			If rs.eof=False Then
				If rs("qx_open")=1 Then
					W1= rs("w1")
					W3= rs("w3")
					w1sql=" and charindex(','+cast(id as varchar(10))+',', ',"&Replace(W1," ","")&",')>0 "
					W3= rs("w3")
					w3sql=" and charindex(','+cast(ord as varchar(10))+',', ',"&Replace(W3," ","")&",')>0  "
					W3= rs("w3")
				ElseIf rs("qx_open")=0 Then
					w1sql= " and 1=0 "
					w3sql= " and 1=0 "
				end if
			end if
			rs.close
			If sort=2 Then
				Set rs=cn.execute("select name from gate where ord="&obj_ord)
				If rs.eof=False Then
					Response.write "<option value='2_" & obj_ord & "' selected>" & rs(0).value & "</option>"
				end if
				rs.close
				csql=" and ord<>"& obj_ord &" "
			end if
			Set rs=cn.execute("select ord ,name from gate where sorce=0 and del=1 "& csql &" " & w3sql &" order by ord ")
			While rs.eof = False
				Response.write "<option value='2_" & rs(0).value & "' "
				If lead="2_" & rs(0).value Then Response.write " selected"
				Response.write ">" & rs(1).value & "</option>"
				rs.movenext
			wend
			rs.close
			If sort=1 Then
				Set rs=cn.execute("select name from orgs_parts where PID=0 and id="&obj_ord)
				If rs.eof=False Then
					Response.write "<option value='1_" & obj_ord & "' selected>" & rs(0).value & "</option>"
				end if
				rs.close
				ssql=" and id<>"& obj_ord &" "
			end if
			Set rs=cn.execute("select ID,name from orgs_parts where PID=0 "& w1sql &" "& ssql &" order by fullids ")
			While rs.eof = False
				Response.write "<option value='1_" & rs(0).value & "' "
				If lead="1_" & rs(0).value Then Response.write " selected"
				Response.write ">" & rs(1).value & "</option>"
				rs.movenext
			wend
			rs.close
			Response.write "" & vbcrlf & "                     </select>" & vbcrlf & "                       <span class=""red"" id=""title_tip"">*</span><span id=""queryresult"" class=""red""></span></div>" & vbcrlf & "               </td>" & vbcrlf & "           <td class=""label"" width='11%'><div align=""right"">开始日期：</div></td>" & vbcrlf & "              <td class=""labe2"" width='22%'><div align=""left"">" & vbcrlf & "                            <input type='text' name=""startDate"" id=""startDate"" onmousedown='datedlg.show()' readonly size='10' value="""
			Response.write startdate
			Response.write """ dataType=""Limit"" min=""1"" max=""10"" msg=""必填"" maxlength=10 value=''>" & vbcrlf & "                             <span class=""red"" id=""title_tip"">*</span><span id=""queryresult"" class=""red""></span></div>" & vbcrlf & "               </td>" & vbcrlf & "           <td class=""label"" width='11%'><div align=""right"">截止日期：</div></td>" & vbcrlf & "         <td class=""labe2"" width='22%'><div align=""left"">" & vbcrlf & "                      <input type='text' name=""endDate"" id=""endDate"" onmousedown='datedlg.show()' readonly size='10' maxlength=10  value="""
			Response.write enddate
			Response.write """  dataType=""Limit"" min=""1"" max=""10"" msg=""必填"" value=''>" & vbcrlf & "                   <span class=""red"" id=""title_tip"">*</span><span id=""queryresult_enddare"" class=""red""></span></div>" & vbcrlf & "             </td>" & vbcrlf & "   </tr>" & vbcrlf & "   <tr "
			Response.write updatecss
			Response.write ">" & vbcrlf & "            <td class=""label""><div align=""right"">预算模式：</div></td>" & vbcrlf & "          <td class=""labe2""><div align=""left"">" & vbcrlf & "                        <input type=""radio"" value=""0"" name=""mode"" "
			If mode=0 Then
				Response.write "checked "
			end if
			Response.write " id=""mod1"" onclick=""changeMode(0)""> 汇总 " & vbcrlf & "                        <input type=""radio"" value=""1"" name=""mode"" "
			If mode=1 Then
				Response.write "checked "
			end if
			Response.write " onclick=""changeMode(1)""> 明细" & vbcrlf & "                 </select><span class=""red"" id=""title_tip"">*</span><span id=""queryresult"" class=""red""></span></div>" & vbcrlf & "              </td>" & vbcrlf & "           <td class=""label""><div align=""right"">币　　种：</div></td>" & vbcrlf & "          <td class=""labe2""><div align=""left""> "& vbcrlf &            "                    <select name=""bz"" id=""bz"" dataType=""Limit"" min=""1"" max=""60"" msg=""必选"">" & vbcrlf &                 "             <option value="""">选择币种</option>" & vbcrlf &     "       "
			Dim bzsql
			Set rs=cn.execute("select bz from setbz")
			If rs.eof= False Then
				setbz=rs(0).value
			end if
			rs.close
			If setbz=0 Then bzsql=" where id=14 " : bz=14
			set rs=cn.execute("select id,sort1 from sortbz "& bzsql &" order by gate1 desc")
			do while rs.eof = False
				Response.write "<option value='" & rs("id")& "' "
				If bz=rs("id") Then Response.write " selected "
				Response.write ">"& rs("sort1") &"</option>"
				rs.movenext
			loop
			set rs=nothing
			Response.write "" & vbcrlf & "                             </select>" & vbcrlf & "                               <span class=""red"" id=""title_tip"">*</span><span id=""queryresult"" class=""red""></span></div>" & vbcrlf & "               </td>" & vbcrlf & "           <td class=""label""><div align=""right"">预算总额：</div></td>" & vbcrlf & "          <td class=""labe2"">" & vbcrlf & "                          <div align=""left"" id=""hz"" style="""
			Response.write hzcss
			Response.write """>" & vbcrlf & "                          <input name=""money_hz"" type=""text"" size=""20"" id=""money_hz"" oldvalue="""
			Response.write money_hz
			Response.write """ value="""
			Response.write money_hz
			Response.write """ dataType=""Limit"" min=""1"" max=""15"" maxlength=15 msg=""必须是15位数字以内金额""  onfocus=""this.select()"" onpropertychange=""formatData(this,'money')"" >" & vbcrlf & "                    <span class=""red"" id=""title_tip"">*</span><span id=""queryresult"" class=""red""></span></div>" & vbcrlf & "                       <div align=""left"" id=""mx"" style="""
			Response.write mxcss
			Response.write """>" & vbcrlf & "                          <input name=""money_mx"" type=""text"" size=""20"" id=""money_mx"" oldvalue="""
			Response.write money_mx
			Response.write """ value="""
			Response.write money_mx
			Response.write """ style=""background-color:#f4f5ff;color:#999999;"" dataType=""Limit"" readonly min=""1"" max=""15"" maxlength=15 msg=""必须是15位数字以内金额""  onfocus=""this.select()"" onpropertychange=""formatData(this,'money')"" >" & vbcrlf & "                     <span class=""red"" id=""title_tip"">*</span><span id=""queryresult"" class=""red""></span></div>" & vbcrlf & "              </td>" & vbcrlf & "   </tr>" & vbcrlf & "   <tr class=""resetTableBg"" name=""mxtr"" id=""mx_1"" style=""background:;"
			Response.write mxcss
			Response.write """><td class=""label"" colspan=""6""><div align=""left"" style=""padding-left:42px;"">&nbsp;<b style=""padding-left: 12px;border-left: 2px solid #000;"">预算明细</b></div></td></tr>" & vbcrlf & "  <tr name=""mxtr"" id=""mx_2"" style="""
			Response.write mxcss
			Response.write mxcss
			Response.write """>" & vbcrlf & "                <td colspan=""6"" style=""padding:0 42px"">" & vbcrlf & "                     "
			Dim rss,i, n ,j_str ,trcss ,trcss_border
			Dim flcount, sql2
			sql2 = ""
			If ZBRuntime.MC(18500) = False Then
				sql2 = sql2 &" and isnull(id1,0) not in(5,7)"
			end if
			If ZBRuntime.MC(18900) = False Then
				sql2 = sql2 &" and isnull(id1,0)<>6"
			end if
			If ZBRuntime.MC(18700) = False Then
				sql2 = sql2 &" and isnull(id1,0)<>8"
			end if
			If ZBRuntime.MC(18610) = False Then
				sql2 = sql2 &" and isnull(id1,0)<>9"
			end if
			flcount=cn.execute("select count(ord) from sortonehy where gate2=41 "& sql2 &" and del=1")(0).value
			Set rs=cn.execute("select ord,sort1 from sortonehy where gate2=41 "& sql2 &" and del=1 order by gate1 desc")
			If rs.eof=False Then
				Response.write "" & vbcrlf & "                             <table style=""width:100%;border-top:#ccc 1px solid;padding:4px;table-layout:auto"">" & vbcrlf & "                                        "
'If rs.eof=False Then
				i=0
				j_str="-"
				i=0
				trcss=""
				trcss_border = " border-bottom:0; "
				trcss=""
				While rs.eof= False
					If i>0 Then
						j_str="+"
'If i>0 Then
						trcss=" style='display:none' "
						trcss_border="border-bottom:1px solid #ccc;"
						trcss=" style='display:none' "
					end if
					If i=flcount-1 Then trcss_border="border-bottom:1px solid #ccc;"
					trcss=" style='display:none' "
					Response.write "<tr class='resetTableBg' style=''><td id='flmxbt_"& rs("ord") &"' class='label' colspan='6' style='border-top:0;"&trcss_border&"' ><div align='left' onclick='expansion("&rs("ord")&")'>&nbsp;<b><span id='j_"& rs("ord") &"'>"&j_str&"</span>" & rs("sort1") &"</b></div></td></tr>"
					trcss=" style='display:none' "
					Response.write "<tr id='flmx_"&rs("ord")&"' "& trcss &"><td class='label' colspan='6' style='padding: 0;border:0;width:100%;'><table style='width:100%;table-layout:auto;border-color:#ccc;' border='1'><tr  ><td class='label'><div align='center'>序号</div></td><td class='label'><div align='center'>子分类</div></td><td class='label'><div align='center'>预算金额</div></td><td class='label' colspan='3'><div align='center'>备注</div></td></tr>"
					Set rss=cn.execute("select p.id,p.sort1,isnull(b.money1,0) as money1,b.intro from paytype p left join budgetlist b on b.sort=p.id and b.pid="&ord&" where p.sort2="&  rs("ord") &" and p.del=1 order by gate2 desc")
					n=1
					While rss.eof=False
						Response.write "<tr><td style='width:20%'><div align='center'>" & n &"</div></td>"
						Response.write "<td style='width:20%'><div align='center'>" & rss("sort1") &"</div></td>"
						Response.write "<td style='width:20%'><div align='center'> <input class='input' name='money1_"& rss("id") &"' type='text' size='20' id='money1_"& rss("id") &"'   dataType='Limit' min='1' max='15' msg='必须是15位数字以内金额' maxlength=15 style='text-align:right' onfocus='this.select()' oldvalue='"&zbcdbl( rss("money1")) &"' value='" &zbcdbl( rss("money1")) & "'onpropertychange=""formatData(this,'money');summation()""></div></td>"
						Response.write "<td colspan='3' style='width:40%'><div align='center'><input name='intro_" & rss("id") &"' type='text' size='60' id='intro_" & rss("id") &"'  dataType='Limit' min='0' max='200' msg='必须在1到200个字之间' value='"& rss("intro") &"'></div></td></tr>"
						n=n+1
						rss.movenext
					wend
					rss.close
					Response.write "</table></td></tr>"
					i=i+1
					Response.write "</table></td></tr>"
					rs.movenext
				wend
				Response.write "" & vbcrlf & "                             </table>" & vbcrlf & "                                "
			else
				Response.write "请设置费用分类！"
			end if
			rs.close
			Response.write "" & vbcrlf & "             </td>" & vbcrlf & "   </tr>" & vbcrlf & "   "
		end if
		Response.write "" & vbcrlf & "     <tr><td style=""padding:0;height:30px!important;""></td></tr>" & vbcrlf & "       <tr>" & vbcrlf & "            <td class=""label""><div align=""right"">预算概要：</div></td>" & vbcrlf & "          <td class=""labe2"" colspan=""5"">      " & vbcrlf & "                        <textarea name=""intro"" style=""display:none"" cols=""1""rows=""1"">"
		if intro<>"" then Response.write intro
		Response.write "</textarea>" & vbcrlf & "                  <IFRAME ID=""eWebEditor1"" SRC=""../edit/ewebeditor.asp?id=intro&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""300"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME>" & vbcrlf & "               </td>" & vbcrlf & "   </tr>" & vbcrlf & "   <tr><td class='gray' colspan=""6""><div align='center'>" & vbcrlf & "      <input type=""hidden"" name=""sp"" id=""sp"" value="""">" & vbcrlf & "        <input type=""hidden"" name=""cateid_sp"" id=""cateid_sp"" value="""">" & vbcrlf & "  <input type=""hidden"" name=""status"" id=""status"" value="""">" & vbcrlf & "        <input type='submit' name='Submit42' id=""Submit42"" value='保存' class='oldbutton'/>&nbsp;&nbsp;&nbsp;&nbsp;<input type='reset' value='重填' class='oldbutton' name='B2' id=""B2""></div></td></tr>" & vbcrlf & "        </table>" & vbcrlf & "        </form>" & vbcrlf & " <div id=""w"" class=""easyui-window"" title=""审批人选择""  style=""width:350px;height:205px;padding:5px;background: #fafafa;top:350px;left:450px;""  modal=""true"" closed=""true"" ></div>" & vbcrlf & "    "
		Response.write "<div class='bottomdiv' style='border-top:0px;'></div></body></html>"
	end sub
	Sub App_checkMoney
		Dim rs,ord,startDate,endDate,bz,lead, returnstr,bh
		ord   = app.getInt("ord")
		lead          = app.GetText("lead")
		startDate = app.GetText("startDate")
		endDate   = app.GetText("endDate")
		bz            = app.getInt("bz")
		bh            = app.GetText("bh")
		returnstr = "0"
		If datediff("d",startDate,endDate)<=0 Then
			Response.write "1"
			Exit Sub
		end if
		If cn.execute("select count(1) from budget where bh='"&bh&"' and ord<>"& ord &"")(0)>0 Then
			Response.write "2"
			Exit Sub
		end if
		Dim ts_ord ,ts_sql
		ts_ord=""
		ts_sql=""
		Set rs=cn.execute("select ord,startDate,endDate from budget where status<>3 and del<>2 and sort=" & Split(lead,"_")(0) &" and obj_ord="& Split(lead,"_")(1) &" and bz= "& bz&" and startDate>='"& startDate &"' and endDate<='" & endDate & "' and ord<>"& ord &"")
		If rs.eof=False Then
			If Len(returnstr)>1 Then
				returnstr=returnstr & vbcrlf
			else
				returnstr=""
			end if
			ts_ord = rs("ord").value
			returnstr= returnstr & rs("startDate").value &" 至 " & rs("endDate").value &" 已经有预算金额，请更改预算开始日期或截止日期 "
		end if
		rs.close
		If ts_ord="" Then
			Set rs=cn.execute("select ord,startDate,endDate from budget where status<>3 and del<>2 and sort=" & Split(lead,"_")(0) &" and obj_ord="& Split(lead,"_")(1) &" and bz= "& bz&" and startDate<='"& startDate &"' and endDate>='" & startDate & "' and ord<>"& ord &"" )
			If rs.eof=False Then
				If Len(returnstr)>1 Then
					returnstr=returnstr & vbcrlf
				else
					returnstr=""
				end if
				ts_ord = rs("ord").value
				returnstr=returnstr & rs("startDate").value &" 至 " & rs("endDate").value &" 已经有预算金额，请更改预算开始日期 "
			end if
			rs.close
			If ts_ord<>"" Then ts_sql = " and ord<>"& ts_ord & " "
			Set rs=cn.execute("select ord, startDate,endDate from budget where status<>3 and del<>2 and sort=" & Split(lead,"_")(0) &" and obj_ord="& Split(lead,"_")(1) &" and bz= "& bz&" and startDate<='"& endDate &"' and endDate>='" & endDate & "' and ord<>"& ord & ts_sql &"")
			If rs.eof=False Then
				If Len(returnstr)>1 Then
					returnstr=returnstr & vbcrlf
				else
					returnstr=""
				end if
				returnstr= returnstr & rs("startDate").value &" 至 " & rs("endDate").value &" 已经有预算金额，请更改预算截止日期 "
			end if
			rs.close
		end if
		Response.write returnstr
	end sub
	Function getNewbh(bhid, table , Key , creat , bh ,indate)
		Dim rsbh,bhvalue
		cn.execute("Delete " & table & " where " & creat &" =" & Info.User & " and del=7")
		Set rsbh=cn.execute("EXEC erp_getdjbh "& bhid &","&session("personzbintel2007"))
		bhvalue=rsbh(0).value
		set rsbh=Nothing
		getNewbh =  bhvalue
	end function
	Function getNeword(table , Key , creat , bh, indate, bhvalue )
		Dim rskey, rd
		cn.execute("Insert Into "& table &" ("& creat &","& indate &","& bh &",del) values(" & Info.User & ",'"& now &"','"& bhvalue &"',7)")
		Set rskey= cn.execute("select top 1 "& Key &" from "& table &" where "& creat &"=" & Info.User  &" and del=7 order by " & Key &" desc ")
		If rskey.eof= False Then
			rd=rskey(0).value
		end if
		getNeword=rd
	end function
	
%>
