<%@ language=VBScript %>
<%
	Response.CharSet = "UTF-8"
	Response.ContentType = "text/html"
	Response.Expires = -9999
	Response.ContentType = "text/html"
	Response.AddHeader "Pragma", "no-cache"
	Response.ContentType = "text/html"
	Response.AddHeader "Cache-control", "no-cache"
	Response.ContentType = "text/html"
	Response.Buffer = True
	Response.ExpiresAbsolute = Now - 1000
	Response.Buffer = True
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
		'Set ZBRuntime = app.Library
		'If ZBRuntime.loadOK Then
		'	ZBRuntime.getLibrary "ZBIntel2013CheckBitString"
		'	If ZBRuntime.loadOK then
		'		if app.isMobile then
		'			response.clear
		'			response.CharSet = "utf-8"
		'			response.clear
		'			Response.BinaryWrite app.base64.UnicodeToUtf8("系统【服务端】未正常启动，请检查服务器环境是否正常。")
		'			Response.end
		'		else
		'			Response.write "<script>top.window.location.href ='" & app.virpath & "index2.asp?id2=8'</script>"
		'		end if
		'		Set app = Nothing
		'		Set ZBRuntime = Nothing
		'		Exit Sub
		'	end if
		'end if
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
	
	ZBRLibDLLNameSN = "ZBRLib3205"
	Class customFieldClass
		Public dbname
		Public Key
		Public show
		Public name
		Public point
		Public enter
		Public sort2
		Public required
		Public extra
		Public isformat
		Public sorttype
		Public search
		Public import
		Public export
		Public census
	End Class
	Function GetFields(sort)
		If sort&""="" Then sort = 1
		Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim rs ,sql, field
		sql = "select (case when isnull(name,'')='' then oldname else name end ) as name,(case when show>0 then 1 else 0 end) as show,(case when Required>0 then 1 else 0 end ) as Required ,"&_
		"   gate1 ,point ,enter, sort2,extra , format ,type , fieldName "&_
		"   from setfields where sort="& sort &" order by sort2, order1 asc "
		set rs = conn.execute(sql)
		While rs.eof = False
			Set field = New customFieldClass
			With field
			.dbname = rs("fieldName").value
			.Key    = rs("gate1").value
			.show   = (rs("show").value = "1")
			.name   = rs("name").value
			.point  = (rs("point").value = "1" And rs("show").value = "1")
			.enter  = (rs("enter").value = "1" And rs("show").value = "1")
			.sort2  = CInt(rs("sort2").value)
			.required=(rs("required").value = "1" And rs("show").value = "1")
			.extra  = rs("extra").value&""
			.isformat=(rs("format").value = "1" And rs("show").value = "1")
			.sorttype   = CInt(rs("type").value)
			End With
			fields.add field
			rs.movenext
		wend
		rs.close
		Set GetFields = fields
	end function
	Function hasOpenZdy(sort)
		If sort&""="" Then sort = 1
		hasOpenZdy = (conn.execute("select 1 from zdy where sort1="& sort &" and set_open = 1 ").eof = false)
	end function
	Function GetZdyFields(sort)
		If sort&""="" Then sort = 1
		Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim rs ,sql, field
		sql = "select * from zdy where sort1="& sort &" order by gate1 asc "
		set rs = conn.execute(sql)
		While rs.eof = False
			Set field = New customFieldClass
			With field
			.dbname = rs("name").value
			.Key    = rs("id").value
			.show   = (rs("set_open").value = "1")
			.name   = rs("title").value
			.point  = (rs("ts").value = "1" And rs("set_open").value = "1")
			.enter  = (rs("jz").value = "1" And rs("set_open").value = "1")
			.required=(rs("bt").value = "1" And rs("set_open").value = "1")
			.extra  = rs("gl").value
			.sorttype   = CInt(rs("sort").value)
			.search = (rs("js").value = "1" And rs("set_open").value = "1")
			.import = (rs("dr").value = "1" And rs("set_open").value = "1")
			.export = (rs("dc").value = "1" And rs("set_open").value = "1")
			.census = (rs("tj").value = "1" And rs("set_open").value = "1")
			End With
			fields.add field
			rs.movenext
		wend
		rs.close
		Set GetZdyFields = fields
	end function
	Function hasOpenExtra(sort)
		If sort&""="" Then sort = 1
		hasOpenExtra = (conn.execute("select 1 from ERP_CustomFields where TName="& sort &" and IsUsing=1 and del=1 ").eof = False)
	end function
	Function GetExtraFields(sort)
		If sort&""="" Then sort = 1
		Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim rs ,sql, field
		sql = "select f.id,f.IsUsing ,f.FType,f.FName,f.MustFillin, ((case f.FType when 1 then 'danh_' when 2 then 'duoh_' when 3 then 'date_' when 4 then 'Numr_' when 5 then 'beiz_' when 6 then 'IsNot_' else 'meju_' end ) + cast(f.id as varchar(20)) ) as dbname,f.CanSearch,f.CanInport ,f.CanExport, f.CanStat  from ERP_CustomFields f where f.TName="& sort &" and f.del=1 order by f.FOrder asc "
		set rs = conn.execute(sql)
		While rs.eof = False
			Set field = New customFieldClass
			With field
			.dbname = rs("dbname").value
			.Key    = rs("id").value
			.show   = rs("IsUsing").value
			.name   = rs("FName").value
			.required=(rs("MustFillin").value And rs("IsUsing").value)
			.extra  = rs("id").value
			.sorttype   = CInt(rs("FType").value)
			.search = (rs("CanSearch").value  And rs("IsUsing").value )
			.import = (rs("CanInport").value  And rs("IsUsing").value )
			.export = (rs("CanExport").value  And rs("IsUsing").value )
			.census = (rs("CanStat").value  And rs("IsUsing").value )
			End With
			fields.add field
			rs.movenext
		wend
		rs.close
		Set GetExtraFields = fields
	end function
	Dim checkmustcontentPersons
	Function getbacktel(ord,v2,needtype)
		getbacktel =  getbackteldata(ord,v2,needtype, 1)
	end function
	Function getbacktelForTmp(ord,v2,needtype)
		getbacktelForTmp =  getbackteldata(ord,v2,needtype, 2)
	end function
	Function getbackteldata(ord,v2,needtype, dtype)
		Dim f_rs,f_sql,remind,reminddays,tord,n,backday,cansum,sql_result
		Dim basesql
		n=0
		If needtype>0 Then
			If needtype=3 Then sql_result=" and backdays<=3 "
			If needtype=7 Then sql_result=" and backdays<=7  and backdays>3 "
			If needtype=10 Then sql_result=" and backdays<=10 and backdays>7 "
			If needtype=15 Then sql_result=" and backdays<=15 and backdays>10 "
			If needtype=999999 Then sql_result=" and backdays>15 "
		else
			sql_result=" and canremind=1 and  backdays<=reminddays "
		end if
		basesql = "select ord into #tmpbacktel from dbo.erp_sale_getBackList('" & v2 & "',0) a where a.cateid in (" & ord & ")  " & sql_result
		If dtype = 1 Then
			getbackteldata = Replace(basesql,"into #tmpbacktel"," ")
			Exit Function
		else
			conn.execute basesql
		end if
	end function
	Function getTelList(ord,v2)
		Dim f_sql,f_rs,v,v1, m
		If len(ord) = 0 Then
			f_sql = "select x.ord from dbo.erp_sale_getWillReplyList('" & v2 & "',0) x"
		else
			f_sql = "select x.ord from dbo.erp_sale_getWillReplyList('" & v2 & "',0) x where x.cateid in (" & ord & ")"
		end if
		Set f_rs=conn.execute(f_sql)
		Do While Not f_rs.eof
			If v1="" Then
				v1=f_rs(0).value
			else
				v1=v1 & "," & f_rs(0).value
			end if
			f_rs.movenext
		Loop
		f_rs.close : Set f_rs=Nothing
		getTelList=v1
	end function
	sub error(message)
		Response.write "" & vbcrlf & "     <script>alert('"
		Response.write message
		Response.write "');if(!parent.window.iswork){history.back()}</script>" & vbcrlf & "        "
		call db_close : Response.end
	end sub
	Function GetSortBtFields(byval sort, byval sort1)
		Dim list : Set list = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim MustContentType : MustContentType = 0
		Dim currgate2 : currgate2 = 0
		Dim rs ,sql
		Set rs =  conn.execute("select isnull(MustContentType,0) as MustContentType, gate2 from sort5 where sort1=" & sort & " and ord=" & sort1)
		if rs.eof= False Then
			MustContentType = rs("MustContentType").value
			currgate2 = rs("gate2").value
		end if
		rs.close
		sql = "select musthas, MustContentType, isnull(mustContent,'') as mustContent,isnull(mustRole,'') as mustRole, isnull(mustzdy,'') as mustzdy, isnull(mustkz_zdy,'') as mustkz_zdy  from sort5  where sort1=" & sort
		if MustContentType = 2 Then
			sql = sql & " and (gate2 >" & currgate2 & " or ord=" & sort1 & ") and MustContentType > 0 "
		elseif MustContentType = 1 then
			sql = sql & " and ord =" & sort1
		else
			sql = sql & " and 1=0 "
		end if
		Dim amustcontent :amustcontent = ""
		Dim amustrole : amustrole = ""
		Dim amustzdy : amustzdy = ""
		Dim amustkz_zdy : amustkz_zdy = ""
		Dim C : C = ""
		Dim R : R = ""
		Dim Z : Z = ""
		Dim K : K = ""
		set rs = conn.execute(sql)
		While rs.eof= False
			C = rs("mustContent").value
			R = rs("mustRole").value
			Z = rs("mustzdy").value
			K = rs("mustkz_zdy").value
			if Len(C)> 0 Then
				if Len(amustcontent)> 0 Then  amustcontent = amustcontent & ","
				amustcontent = amustcontent & Replace(C ," ", "")
			end if
			if Len(R) > 0 Then
				if len(amustrole) > 0 Then amustrole = amustrole & ","
				amustrole = amustrole & Replace(R ," ", "")
			end if
			if len(Z)> 0 Then
				if len(amustzdy)> 0 then amustzdy = amustzdy & ","
				amustzdy = amustzdy & Replace(Z ," ", "")
			end if
			if Len(K)>0 Then
				if len(amustkz_zdy) > 0 Then amustkz_zdy = amustkz_zdy & ","
				amustkz_zdy = amustkz_zdy & Replace(K ," ", "")
			end if
			rs.movenext
		wend
		rs.close
		list.Add amustcontent
		list.Add amustrole
		list.Add amustzdy
		list.Add amustkz_zdy
		Set GetSortBtFields = list
	end function
	Function CustomStageWatchs(byval ID , isCurrentNext, sort, sort1, type_ChangeSort, id_ChangeSort, intro_ChangeSort)
		Dim rs
		Dim v1 : v1 = ""
		Dim v2 : v2 = ""
		Dim v3 : v3 = ""
		Dim v4 : v4 = ""
		Dim list
		Set list = GetSortBtFields(sort, sort1)
		v1 = checkmustcontent(list.item(0), list.item(1),ID)
		v2 = checkrole(list.item(1),list.item(0),ID)
		v3 = checkzdy(list.item(2),ID)
		v4 = checkkz_zdy(list.item(3), ID)
		if Len(v1 & v2 & v3 & v4)> 0 Then
			Dim s : s = IntToStr(1 ,v1, v2 , v3 , v4)
			CustomStageWatchs ="本阶段有必填项未填写，请填写后再保存！" & s & ""
			Exit Function
		end if
		If isCurrentNext = False Then CustomStageWatchs = "" : Exit Function
		Call saveSort5change(ID, sort, sort1, type_ChangeSort, id_ChangeSort , intro_ChangeSort)
		Set rs = conn.execute("select s.ord, s.sort1, s.sort2, isnull(s.mustHas,0) as  mustHas, s.gate2,s.AutoNext from sort5 s inner join tel t on t.sort=s.sort1 and t.ord=" & id & " and gate2<(select gate2 from sort5 where ord=t.sort1) order by gate2 desc")
		Do While rs.eof = False
			if rs("AutoNext") = "1" Then
				sort = rs("sort1")
				sort1 = rs("ord")
				Set list = GetSortBtFields(sort, sort1)
				v1 = checkmustcontent(list.item(0), list.item(1),ID)
				v2 = checkrole(list.item(1),list.item(0),ID)
				v3 = checkzdy(list.item(2),ID)
				v4 = checkkz_zdy(list.item(3), ID)
				if Len(v1 & v2 & v3 & v4)=0 Then
					Call saveSort5change(ID, sort, sort1, 0, 0, "系统自动跳转")
				else
					Exit Do
				end if
			else
				Exit Do
			end if
			if rs("mustHas").value = "1" Then  Exit Do
			rs.movenext
		Loop
		rs.close
		CustomStageWatchs = ""
	end function
	Function  Sort1FieldsTest(ord, sort, sort1)
		Sort1FieldsTest = False
		Dim returnStr : returnStr= CustomStageWatchs(ord, False , sort, sort1, 1, ord ,"")
		If Len(returnStr)>0 Then
			Error returnStr
		end if
		Sort1FieldsTest = true
	end function
	Function autoSkipSort(ord,sort,sort1,reason,reasonid,nosortmode,slient,intro)
		autoSkipSort=True
		Dim presort,presort1,gate2,tgate2
		Dim f_rs,n
		n=0
		Dim mustcontent,mustrole,mustzdy,mustkz_zdy,Aend,autonext,autonext1
		Dim amustcontent,amustrole,amustzdy,amustkz_zdy,mustContentType
		Dim mustcon_tip,mustrole_tip,mustzdy_tip,mustkz_tip,isbt,namelist
		Aend=0
		If Len(ord&"")=0 Then ord=0
		If Len(sort&"")=0 Then sort=0
		If Len(sort1&"")=0 Then sort1=0
		Set f_rs=conn.execute("select isnull(sort,0) as sort,isnull(sort1,0) as sort1 from tel where ord="&ord)
		If f_rs.eof=False Then
			presort=f_rs(0).value
			presort1=f_rs(1).value
		else
			presort=0 : presort1=0 : autoSkipSort=False : Exit function
		end if
		f_rs.close
		If Len(presort&"")=0 Then presort=0
		If Len(presort1&"")=0 Then presort1=0
		If nosortmode Then sort=presort : sort1=presort1
		Dim returnStr : returnStr= CustomStageWatchs(ord ,True , sort, sort1, reason , reasonid ,intro)
		if Len(returnStr) > 0 And slient = True Then
			If ismobileApp = False Then Error returnStr
			autoSkipSort = False
			Exit function
		end if
		autoSkipSort = True
	end function
	Function getnextsort(sort,sort1)
		Dim Frs,Fsql
		Set Frs=conn.execute("select * from sort5 where sort1="&sort&" and ord<>" & sort1 & " and gate2<=(select gate2 from sort5 where sort1="&sort&" and ord="&sort1&") order by gate2 desc")
		If Frs.eof=False Then
			getnextsort=Frs("ord")
		else
			getnextsort=0
		end if
		Frs.close : Set Frs=nothing
	end function
	Function saveSort5change(ord,sort,sort1,reason,reasonid,Fintro)
		Dim state : state = "0"
		Dim rs , sql
		Dim oldsort : oldsort = 0
		Dim oldsort1 : oldsort1 = 0
		Set rs =conn.execute("select top 1 isnull(sort,0) as sort,isnull(sort1,0) as sort1 from tel where ord=" & ord)
		If rs.eof = False Then
			oldsort = rs("sort")
			oldsort1 =rs("sort1")
		end if
		rs.close
		if oldsort1<>sort1 or sort<0 Then
			if sort < 0 Then
				sort = oldsort
				sort1 = oldsort1
				state = "0"
			else
				state = getstate(oldsort,oldsort1,sort,sort1,ord)
			end if
		end if
		sql = "insert into tel_sort_change_log(tord,sort3,preSort,preSort1,newSort,newSort1,cateid,cateid2,cateid3,reason,reasonid,intro,state,date2,date7,cateadd) " &_
		"select ord ,sort3,sort,sort1,'"  & sort &  "','"  & sort1 &"',cateid , cateid2 ,cateid3,'" & reason &"','" & reasonid & "','" & Fintro & "','" & state & "',date2,getdate()," & session("personzbintel2007") &  " from tel where ord = " & ord
		conn.execute(sql)
		If state<>"0" Then conn.execute("update tel set sort=" & sort &",sort1="  & sort1 & " where ord=" & ord)
	end function
	Function getstate(psort,psort1,nsort,nsort1,ord)
		Dim f_rs ,sortSql
		If psort1=0 And nsort1<>0 Then
			getstate=1
			Exit Function
		end if
		If psort&""<>nsort&"" Then
			sortSql="set nocount on;"&_
			"select identity(int,1,1) as id1,cast(ord as int) as ord into #sort4 from (select top 100000000 ord from sort4 order by gate1 desc) a ;"&_
			"select * from #sort4 where ord=" & nsort & " and id1>(select id1 from #sort4 where ord=" & psort & ");"&_
			"drop table #sort4;set nocount off;"
			Set f_rs=conn.execute(sortSql)
			If f_rs.eof=false Then
				getstate=1
			else
				getstate=-1
				getstate=1
			end if
			Exit Function
		end if
		if psort1&""=nsort1&"" then getstate=0 : exit function
		If Len(psort&"")=0 Then psort=0
		If Len(psort1&"")=0 Then psort1=0
		If Len(nsort1&"")=0 Then nsort1=0
		sortSql="set nocount on;"&_
		"select identity(int,1,1) as id1,cast(ord as int) as ord,sort1 into #sort5 from (select top 100000000 ord,sort1 from sort5 where sort1=" & psort & " order by gate2 desc) a;"&_
		"select * from #sort5 where ord=" & nsort1 & " and id1>(select id1 from #sort5 where ord=" & psort1 & ");"&_
		"drop table #sort5;set nocount off;"
		Set f_rs=conn.execute(sortSql)
		If f_rs.eof=false Then
			getstate=1
		else
			getstate=-1
			getstate=1
		end if
		f_rs.close : Set f_rs=Nothing
	end function
	Function getContentName(value,isid)
		Dim v,s,i
		v=Split("6,7,8,9,10,11,12,13,14,15,25,27,28,18,19,20,21,23,24,22,92,93,94,95,96,97,98,99,100",",")
		s=Split("来源,区域,行业,价值,网址,到款,地址,邮编,法人,注册资本,籍贯,部门,职务,家庭电话,办公电话,手机,传真,QQ,MSN,电子邮件,联系人,客户电话,客户传真,客户邮件,已联系,建立项目,已报价,已成交,关联售后",",")
		If isid=True And value&""<>"" Then
			For i=0 To ubound(v)
				If value&""=v(i)&"" Then getContentName=s(i) : Exit For : Exit Function
			next
		else
			For i=0 To ubound(s)
				If value&""=s(i)&"" Then getContentName=v(i) : Exit For : Exit Function
			next
		end if
	end function
	Function patchrep(strs,str1)
		Dim allstr,tstr,f_i
		If Len(str1&"")=0 Then patchrep=strs : Exit Function
		If Len(strs&"")=0 Then patchrep=str1 : Exit Function
		allstr = strs & "," & str1
		allstr = Replace(allstr," ","")
		tstr = Split(allstr,",")
		allstr=""
		For f_i=0 To ubound(tstr)
			If InStr(1,"," & allstr & ",","," & tstr(f_i) & ",",1)=0 Then
				If allstr="" then
					allstr=tstr(f_i)
				else
					allstr=allstr & "," &tstr(f_i)
				end if
			end if
		next
		patchrep=allstr
	end function
	Function patchrep2(strs,str1)
		Dim allstr,tstr,f_i
		If Len(str1&"")=0 Then patchrep2="" : Exit Function
		If Len(strs&"")=0 Then patchrep2="" : Exit Function
		allstr = Replace(str1," ","")
		tstr = Split(allstr,",")
		allstr=""
		For f_i=0 To ubound(tstr)
			If InStr(1,"," & strs & ",","," & tstr(f_i) & ",",1)>0 Then
				If allstr="" then
					allstr=tstr(f_i)
				else
					allstr=allstr & "," &tstr(f_i)
				end if
			end if
		next
		patchrep2=allstr
	end function
	Function ifarray(obj)
		If Not isArray(obj) Then ifarray=False
		Dim v,n
		v=Err.number
		on error resume next
		n=ubound(obj)
		If Abs(Err.number)<>Abs(v) Then
			ifarray=False
		else
			ifarray=True
		end if
		Err.number=v
		On Error GoTo 0
	end function
	Sub showlyEndMsg(ByVal msg)
		Response.write"<script language=javascript>window.alert(""" & Replace( msg, """", "\""" ) & """);if(parent.window.iswork){}else{history.back();}</script>"
		call db_close
		Response.end
	end sub
	Function WatchCustomNumber(ByVal gord, byval addnum, ByVal IsAdd)
		Dim rs, uid
		uid = gord  & ""
		If uid = "" Or uid = "0" Then
			Exit Function
		end if
		Dim hasly_all, hasly_day, hasly_day_add,  hasly_all_add
		Dim openA1, openA2, openB1, openB2, NumA, NumB
		openA1 = 0 : openA2 = 0 : openB1 = 0 : openB2 = 0 : NumA = 0 : NumB = 0
		Set rs = conn.execute("select isnull(sum(case datediff(d,date2,getdate()) when 0 then 1 else 0 end),0) as v1 , count(1) as v2, isnull(sum(case cateid when cateadd then (case datediff(d,date2,getdate()) when 0 then 1 else 0 end) else 0 end),0) as v3, isnull(sum(case cateid when cateadd then 1 else 0 end),0) as v4 from tel where cateid = "  & uid & " and sort3=1 and isnull(sp,0)=0 and del=1")
		If rs.eof = False then
			hasly_day = rs(0).value
			hasly_all = rs(1).value
			hasly_day_add = rs(2).value
			hasly_all_add = rs(3).value
		end if
		rs.close
		Set rs = conn.execute("select isnull(intro,'0'), isnull(extra,'0') from setopen  where sort1=25")
		If rs.eof = False then
			openA1 = rs(0).value
			openA2 = rs(1).value
		end if
		rs.close
		Set rs = conn.execute("select isnull(intro,'0'), isnull(extra,'0') from setopen  where sort1=37")
		If rs.eof = False then
			openB1 = rs(0).value
			openB2 = rs(1).value
		end if
		rs.close
		Set rs = conn.execute("select isnull(num_4,0) as maxnum,isnull(num_ly,0) as maxly from gate where ord=" & uid)
		If rs.eof = False Then
			NumA = rs(0).value
			numB = rs(1).value
		end if
		rs.close
		If openA1 >= 1 Then
			If openA2 = 1 Then
				If hasly_all + addnum > NumA Then
'If openA2 = 1 Then
					WatchCustomNumber = "账号最多可以领用" & NumA & "个客户，已领用了" & hasly_all & "个，最多还可领用" & (NumA-hasly_all) & "个客户！"
'If openA2 = 1 Then
					Exit Function
				end if
			else
				If IsAdd = 1 Then addnum = 0
				If (hasly_all - hasly_all_add) + addnum > NumA Then
'If IsAdd = 1 Then addnum = 0
					WatchCustomNumber = "账号最多可以领用" & NumA & "个客户，已领用了" & (hasly_all-hasly_all_add) & "个，最多还可领用" & (NumA-hasly_all + hasly_all_add) & "个客户！"
'If IsAdd = 1 Then addnum = 0
					Exit Function
				end if
			end if
		end if
		If openB1 >= 1 Then
			If openB2 = 1 Then
				If hasly_day + addnum > numB Then
'If openB2 = 1 Then
					WatchCustomNumber = "账号今日最多可以领用" & numB & "个客户，已领用了" & hasly_day & "个，最多还可领用" & (numB-hasly_day) & "个客户！"
'If openB2 = 1 Then
					Exit Function
				end if
			else
				If IsAdd = 1 Then addnum = 0
				If (hasly_day - hasly_day_add) + addnum > numB Then
'If IsAdd = 1 Then addnum = 0
					WatchCustomNumber = "账号今日最多可以领用" & numB & "个客户，已领用了" & (hasly_day-hasly_day_add) & "个，最多还可领用" & (numB-hasly_day + hasly_day_add) & "个客户！"
'If IsAdd = 1 Then addnum = 0
					Exit Function
				end if
			end if
		end if
		WatchCustomNumber = ""
	end function
	sub check_tel_applynum(ByVal gord, byval addnum, ByVal IsAdd)
		message = WatchCustomNumber(gord ,addnum,IsAdd)
		If Len(message)> 0 Then
			showlyEndMsg message
			Exit sub
		end if
	end sub
	Sub salesChangeLog(tord,gord,reason,reasonchildren,f_intro)
		If Len(gord & "") = 0 Then gord = "-1"
'Sub salesChangeLog(tord,gord,reason,reasonchildren,f_intro)
		Dim sql
		sql = " insert into [tel_sales_change_log](tord,sort3,sort,sort1,precateid,newcateid,cateid,date2,date7,reason,reasonchildren,replynum,intro) " &_
		"select ord,sort3,sort,sort1,(case when  '"& reason &"'='1' then 0 else cateid end) as precateid,(case when '"& reason &"'='5' then cateid4 else "& gord &" end) as  newcateid ,'" & session("personzbintel2007") & "' as cateid ,isnull(date2,getdate()) as date2 ,getdate() as date7, '"& reason &"' as reason,'" & reasonchildren &"' as reasonchildren ,(select count(1) from reply where ord2=tel.ord) as replynum,'" & f_intro &"' as intro from tel where ord in (" & tord & ") and (('"& reason &"'<>'1' and isnull(cateid,0)<>"& gord &") or '"& reason &"'='1' ) "
		conn.execute(sql)
	end sub
	Function getOption(HourOrMinute)
		Dim v,vi
		If HourOrMinute="Hour" Then
			For vi=0 To 23
				If vi<10 Then
					v=v & "<option value='0" & vi & "'>0" & vi & "</option>"
				else
					v=v & "<option value='" & vi & "'>" & vi & "</option>"
				end if
			next
		ElseIf HourOrMinute="Minute" Then
			For vi=0 To 55
				If (vi Mod 5)=0 then
					If vi<10 Then
						v=v & "<option value='0" & vi & "'>0" & vi & "</option>"
					else
						v=v & "<option value='" & vi & "'>" & vi & "</option>"
					end if
				end if
			next
		end if
		getOption = v
	end function
	Function isbool(mustcon, strc)
		If InStr(1, "," & mustcon & ",", "," & strc & ",", 1) > 0 Then
			isbool = True
		else
			isbool = False
		end if
	end function
	Function isnuul(boolc, isint, strc)
		Dim ReturnB
		ReturnB = False
		If boolc Then
			If isint > 0 Then
				If strc&"" = "0" Then ReturnB = True
			else
				If Len(strc&"") = 0 Then ReturnB = True
			end if
		end if
		isnuul = ReturnB
	end function
	Function GetFieldID(ByVal name)
		Select Case UCase(Trim(name))
		Case "来源"               : GetFieldID = 6
		Case "区域"               : GetFieldID = 7
		Case "行业"               : GetFieldID = 8
		Case "价值"               : GetFieldID = 9
		Case "网址"               : GetFieldID = 10
		Case "到款"               : GetFieldID = 11
		Case "地址"               : GetFieldID = 12
		Case "邮编"               : GetFieldID = 13
		Case "法人"               : GetFieldID = 14
		Case "注册资本" : GetFieldID = 15
		Case "家庭电话" : GetFieldID = 18
		Case "办公电话" : GetFieldID = 19
		Case "手机"               : GetFieldID = 20
		Case "传真"               : GetFieldID = 21
		Case "电子邮件" : GetFieldID = 22
		Case "QQ"         : GetFieldID = 23
		Case "MSN"                : GetFieldID = 24
		Case "籍贯"               : GetFieldID = 25
		Case "部门"               : GetFieldID = 27
		Case "职务"               : GetFieldID = 28
		Case "联系人"     : GetFieldID = 92
		Case "客户电话" : GetFieldID = 93
		Case "客户传真" : GetFieldID = 94
		Case "客户邮件" : GetFieldID = 95
		Case "已联系"     : GetFieldID = 96
		Case "已项目"     : GetFieldID = 97
		Case "已报价"     : GetFieldID = 98
		Case "已合同"     : GetFieldID = 99
		Case "已收回"     : GetFieldID = 100
		End select
	end function
	Function checkmustcontent(ByVal mustcon,  ByVal mustrole, byval tord)
		checkmustcontent = checkmustcontentBase(mustcon, mustrole, tord, mustcon)
	end function
	Function checkmustcontentBase(ByVal mustcon,  ByVal mustrole, byval tord, ByVal allmustcon)
		Dim Rs, StrR,i,fields,fields1, fid, sql,person_ord
		StrR=""
		Set rs=conn.execute("select top 1 isnull(ly,0),isnull(area,0),isnull(trade,0),isnull(jz,0),len(isnull(url,'')),len(isnull(hk_xz,0)),len(isnull(address,'')),len(isnull(zip,'')),(case when len(isnull(faren,''))>0 or sort2=2 then 1 else 0 end),(case when isnull(zijin,0)>0 or sort2=2 then 1 else 0 end),len(isnull(phone,'')),len(isnull(fax,'')),len(isnull(email,'')) from tel where ord="&tord&"")
		If Not rs.eof Then
			fields=Split("来源,区域,行业,价值,网址,到款,地址,邮编,法人,注册资本,客户电话,客户传真,客户邮件",",")
			For i=0 To ubound(fields)
				fid = GetFieldID(fields(i))
				If isnuul(isbool(mustcon, fid),1,rs(i)) Then
					StrR = StrR & "," & fid
				end if
			next
		end if
		rs.close
		person_ord = ""
		If Len(session("tel_person")&"")>0 And isnumeric(session("tel_person")&"") Then
			person_ord = " and ord ="&session("tel_person")
		end if
		Set rs=conn.execute("select len(isnull(jg,'')),len(isnull(part1,'')),len(isnull(job,'')),len(isnull(phone,'')),len(isnull(phone2,'')),len(isnull(mobile,'')),len(isnull(fax,'')),len(isnull(email,'')),len(isnull(qq,'')),len(isnull(MSN,'')), name,role from person where del<>2 and company="&tord&" "&person_ord)
		checkmustcontentPersons = ""
		Dim itemstr, itemv
		While rs.eof = False
			itemstr = ""
			If isbool(mustcon,GetFieldID("联系人")) Or isbool(mustrole, rs("role").value) then
				fields1=Split("籍贯,部门,职务,办公电话,家庭电话,手机,传真,电子邮件,QQ,MSN",",")
				For i=0 To ubound(fields1)
					itemv = GetFieldID(fields1(i))
					If isnuul(isbool(mustcon,itemv),1, rs(i)) Then
						itemstr = itemstr & "," & itemv
						If InStr(1, "," & strR & "," , "," & itemv & ",", 1) = 0 Then
							strR = strR & "," & itemv
						end if
						If Len(itemstr) > 0 Then
							itemstr = itemstr & ","
						end if
						itemstr = itemstr & itemv
					end if
				next
				If Len(checkmustcontentPersons) > 0 Then
					checkmustcontentPersons = checkmustcontentPersons & "|"
				end if
				checkmustcontentPersons = checkmustcontentPersons & itemstr
			end if
			rs.movenext
		wend
		rs.close
		If isbool(mustcon, GetFieldID("联系人")) Then
			If conn.execute("select 1 from person a where del<>2 and company=" & tord&" "&person_ord).eof Then
				strR = strR & "," & GetFieldID("联系人")
			end if
		end if
		If isbool(mustcon, GetFieldID("已联系")) Then
			Dim resultok
			resultok = True
			If conn.execute("select top 1 1 from reply a inner join tel b on a.ord=b.ord and a.cateid=b.cateid and a.date7 > b.date2 and a.del=1 and a.ord =" & tord).eof=True Then
				resultok =  false
				strR = strR & "," & GetFieldID("已联系")
			end if
			If resultok And Len(mustrole)>0 Then
				arrRole=Split(mustrole,",")
				For i=0 To ubound(arrRole)
					sql = "select 1 from reply a inner join person b on a.del=1 and a.sort1=8 and a.ord2=b.ord " &_
					" and b.del<>2 and b.role='"&arrrole(i)&"' and b.company="& tord &" "&Replace(person_ord,"ord","b.ord") &_
					" and b.company=a.ord inner join tel c on a.ord=c.ord and a.date7 > c.date2"
					If conn.execute(sql).eof=True Then
						strR = strR & "," & GetFieldID("已联系")
						resultok = false
						Exit For
					end if
				next
			end if
			If resultok then
				If isbool(allmustcon, GetFieldID("联系人")) Then
					sql = "select 1 from person a inner join tel c on a.company=c.ord and a.del<>2 and c.ord=" & tord &" "&Replace(person_ord,"ord","a.ord") &_
					" left join reply b on a.ord=b.ord2 and b.sort1=8 and b.del<>2 and b.date7>c.date2 " &_
					" where b.ord is null"
					If conn.execute(sql).eof = false Then
						strR = strR & "," & GetFieldID("已联系")
						resultok = false
					end if
				end if
			end if
		end if
		If isbool(mustcon, GetFieldID("已项目")) Then
			sql = "select top 1 1 from chance where isnull(sp,0)=0 and cateid=(select top 1 cateid from tel where ord="&tord&") and del=1 and charindex('," & tord & ",',','+company+',')>0"
'If isbool(mustcon, GetFieldID("已项目")) Then
			If conn.execute(sql).eof= True Then
				strR = strR & "," & GetFieldID("已项目")
			end if
		end if
		If isbool(mustcon, GetFieldID("已报价")) Then
			sql = "select top 1 1 from price where del=1 and isnull(status,-1) in (-1,1) and cateid=(select top 1 cateid from tel where ord="&tord&") and company=" & tord
'If isbool(mustcon, GetFieldID("已报价")) Then
			If conn.execute(sql).eof=True Then
				strR = strR & "," & GetFieldID("已报价")
			end if
		end if
		If isbool(mustcon, GetFieldID("已合同")) Then
			sql = "select top 1 1 from contract where isnull(sp,0)=0 and cateid=(select top 1 cateid from tel where ord="&tord&") and del=1 and company=" & tord
			If conn.execute(sql).eof=True Then
				strR = strR & "," & GetFieldID("已合同")
			end if
		end if
		If isbool(mustcon, GetFieldID("已收回")) Then
			sql = "select top 1 1 from tousu where del=1 and cateid=(select top 1 cateid from tel where ord="&tord&") and company=" & tord
			If conn.execute(sql).eof=True then
				strR = strR & "," & GetFieldID("已收回")
			end if
		end if
		checkmustcontentBase=StrR
	end function
	Function checkkz_zdy(kzmustcon,tord)
		Dim v ,i, strR
		strR = ""
		v=kzmustcon
		v=Replace(v," ","")
		If v<>"" Then
			v=Split(v,",")
			For i=0 To ubound(v)
				If isnumeric(v(i)) Then
					If conn.execute("select top 1 1 from ERP_CustomValues where FieldsId=" & v(i) & " and OrderId=" & tord & " and isnull(Fvalue,'')<>''").eof=True Then strR = strR & "," & v(i)
				end if
			next
		end if
		checkkz_zdy=strR
	end function
	Function checkzdy(zdymustcon,tord)
		Dim v, i, strR
		strR = ""
		v=zdymustcon
		v=Replace(v," ","")
		If v<>"" Then
			v=Split(v,",")
			For i=0 To ubound(v)
				If isnumeric(v(i)) Then
					If conn.execute("select top 1 1 from tel where isnull(zdy" & v(i) & ",'')<>'' and ord=" & tord ).eof=True Then strR = strR & "," & v(i)
				end if
			next
		end if
		checkzdy=strR
	end function
	Function checkrole(mustrole,mustcon,tord)
		Dim strR,v,i,n
		v=mustrole
		If Len(v&"")>0 Then
			v=Split(v,",")
			For i=0 To ubound(v)
				n=Trim(v(i))
				If Len(n&"")=0 Or isnumeric(n)=False Then n=0
				If isbool(mustcon,96) Then
					If conn.execute("select top 1 1 from person where isnull(role,0)>0 and role=" & n & " and del<>2 and company=" & tord &" and ord in(select ord2 from reply where sort1=8 and del=1)").eof=True Then strR = strR & "," & n
				else
					If conn.execute("select top 1 1 from person where isnull(role,0)>0 and role=" & n & " and del<>2 and company=" & tord ).eof=True Then strR = strR & "," & n
				end if
			next
		end if
		checkrole=strR
	end function
	Function IntToStr(intType,mustConStr,mustRoleStr,mustZdyStr,mustKzStr)
		Dim intlist,nameList,nameList1,nameList2,rss
		intlist=""
		nameList=""
		If intType=1 Then
			If Len(Trim(mustConStr))>0 Then
				intlist=mustConStr
				If Left(intlist,1)="," Then intlist=Right(mustConStr,Len(mustConStr)-1)
'intlist=mustConStr
				Set rss=conn.execute("select gate1,(case when isnull(name,'')='' then oldname else name end ) as name,isnull(show,0) as show,point,enter,format from setfields where gate1 in ( 6,7,8,9,10,11,12,13,14,15,25,27,28,18,19,20,21,23,24,22) order by gate1")
				Do While Not rss.eof
					If isbool(mustConStr,rss(0)) Then nameList2=nameList2 & "【"&rss(1)&"】"
					If (isbool(mustConStr,93) And rss(0)=19) Or (isbool(mustConStr,94) And rss(0)=21) Or (isbool(mustConStr,95) And rss(0)=22) Then nameList1=nameList1 & "【"&rss(1)&"（客户）】"
					rss.movenext
				Loop
				rss.close : Set rss=Nothing
				nameList=nameList & nameList1
				If isbool(mustConStr,92) Then nameList=nameList & "【联系人】"
				nameList=nameList & nameList2
			end if
			If Len(Trim(mustRoleStr))>0 Then nameList=nameList & getmustContent("select ord,sort1 from sort9 where 1=1",1,"ord","sort1",mustRoleStr)
			If Len(Trim(mustZdyStr))>0 Then nameList=nameList & getmustContent("select id,title,name,sort,gl from zdy where sort1=1 and set_open=1 order by gate1 asc",2,"id","title",mustZdyStr)
			If Len(Trim(mustKzStr))>0 Then nameList=nameList & getmustContent("select id,fname from ERP_CustomFields where TName=1 and IsUsing=1 and del=1 order by FOrder asc",3,"id","fname",mustKzStr)
			If Len(Trim(mustConStr))>0 Then
				If isbool(mustConStr,96) Then nameList=nameList & "【已联系】"
				If isbool(mustConStr,97) Then nameList=nameList & "【建立项目】"
				If isbool(mustConStr,98) Then nameList=nameList & "【已报价】"
				If isbool(mustConStr,99) Then nameList=nameList & "【已成交】"
				If isbool(mustConStr,100) Then nameList=nameList & "【关联售后】"
			end if
		end if
		If nameList<>"" Then nameList="\n必填项有：" & nameList
		IntToStr=nameList
	end function
	Public Function getmustContent(sql,keyid,ids,names,model_id)
		Dim f_rs,s
		Set f_rs=conn.execute(sql)
		Do While Not f_rs.eof
			If isbool(model_id,f_rs(ids)) then
				s = s & "【" & f_rs(names) & "】"
			end if
			f_rs.movenext
		Loop
		f_rs.close : Set f_rs=nothing
		getmustContent=s
	end function
	Function canGetCompany(tel_ord,neednum, canly, needsort, intro , needGetApply ,condition,limitsort1,limitsort2,limitsort3,limitsort4,limitsort5,limitsort6,limitsort7,limitsort8,limitsort9, needGetTel, cateid4,sort,sort1,ly,jz,trade,area,zdy5,zdy6, needzdy, ishaszdy5, ishaszdy6)
		Dim islingy,telrs,rs1 , rss ,rss1
		islingy=True
		If Len(tel_ord&"") = 0 Then
			canGetCompany = islingy
			Exit Function
		end if
		If needGetTel = True Then
			set telrs=conn.execute("select * from tel where ord="& tel_ord &" ")
			If telrs.eof = False Then
				cateid4 = telrs("cateid4")
				sort=telrs("sort")
				sort1=telrs("sort1")
				ly=telrs("ly")
				jz=telrs("jz")
				trade=telrs("trade")
				area=telrs("area")
				zdy5=telrs("zdy5")
				zdy6=telrs("zdy6")
			end if
			telrs.close
		end if
		If cateid4&"" = "" Then cateid4 = 0
		If neednum = True Then
			If Len(WatchCustomNumber(member2, 1, 0))>0 Then islingy=False
		else
			islingy = canly
		end if
		If islingy = False Then
			canGetCompany = islingy
			Exit Function
		end if
		If needsort = True Then
			intro = 0
			set rs1=conn.execute("select isnull(intro,0) as intro from setopen where sort1=39 and isnull(intro,0)>0")
			If rs1.eof = False Then
				intro=rs1("intro")
			end if
			rs1.close
		end if
		Dim lysql, qysql
		If intro>0 Then
			If intro=2 Then
				lysql=" and cateid=0"
				qysql=" and ord =0 "
			else
				lysql=" and cateid="& cateid4 &" "
				qysql=" and ord = " & cateid4 &" "
			end if
			If needGetApply Then
				Set rss=conn.execute("select * from tel_apply where 1=1 " & lysql )
				If Not rss.eof Then
					condition=rss("condition")
					limitsort1=rss("limitsort1")
					limitsort2=rss("limitsort2")
					limitsort3=rss("limitsort3")
					limitsort4=rss("limitsort4")
					limitsort5=rss("limitsort5")
					limitsort6=rss("limitsort6")
					If limitsort6&""="" Then limitsort6 = 0
					limitsort7=rss("limitsort7")
					limitsort8=rss("limitsort8")
					limitsort9=rss("limitsort9")
				else
					canGetCompany = islingy
					Exit Function
				end if
				rss.close
			end if
			Dim isfl : isfl=False
			If limitsort1&""<>"" And Len(sort&"")>0 And sort&""<>"0" Then
				If InStr(","&Replace(limitsort1," ","")&",",","&sort&",")>0 Then isfl=True
			ElseIf condition=1 Then
				isfl=True
			ElseIf Len(limitsort1&"")>0 and (Len(sort&"")=0 Or sort&""="0") Then
				isfl=True
			end if
			Dim isgj : isgj=False
			If limitsort2&""<>"" And Len(sort1&"")>0 And sort1&""<>"0" Then
				If InStr(","&Replace(limitsort2," ","")&",",","&sort1&",")>0 Then isgj=True
			ElseIf condition=1 Then
				isgj=True
			ElseIf Len(limitsort2&"")>0 and (Len(sort1&"")=0 Or sort1&""="0") Then
				isgj=True
			end if
			Dim isly : isly=False
			If limitsort3&""<>"" And Len(ly&"")>0 And ly&""<>"0" Then
				If InStr(","&Replace(limitsort3," ","")&",",","&ly&",")>0 Then isly=True
			ElseIf condition=1 Then
				isly=True
			ElseIf Len(limitsort3&"")>0 and (Len(ly&"")=0 Or ly&""="0") Then
				isly=True
			end if
			Dim isjz : isjz=False
			If limitsort4&""<>"" And jz&""<>"0" And Len(jz&"")>0 Then
				If InStr(","&Replace(limitsort4," ","")&",",","&jz&",")>0 Then isjz=True
			ElseIf condition=1 Then
				isjz=True
			ElseIf Len(limitsort4&"")>0 and (Len(jz&"")=0 Or jz&""="0") Then
				isjz=True
			end if
			Dim ishy : ishy=False
			If limitsort5&""<>"" And Len(trade&"")>0 And trade&""<>"0"  Then
				If InStr(","&Replace(limitsort5," ","")&",",","&trade&",")>0 Then ishy=True
			ElseIf condition=1 Then
				ishy=True
			ElseIf Len(limitsort5&"")>0 and (Len(trade&"")>0 Or trade&""="0") Then
				ishy=True
			end if
			Dim isqy : isqy=False
			If limitsort6=1 And Len(area&"")>0 And area&""<>"0" Then
				If conn.execute("select count(id) from tel_area where sort=2 and area="& area &" " & qysql)(0)>0 Then isqy=True
			ElseIf condition=1 Then
				isqy=True
			ElseIf limitsort6=1 and (Len(area&"")=0 Or area&""="0") Then
				isqy=True
			end if
			If needzdy = True Then
				ishaszdy5 = (conn.execute("select 1 from zdy where sort1=1 and set_open=1 and name='zdy5' ").eof = false)
				ishaszdy6 = (conn.execute("select 1 from zdy where sort1=1 and set_open=1 and name='zdy6' ").eof = false)
			end if
			Dim iszdy5 : iszdy5=False
			If ishaszdy5 Then
				If limitsort7&""<>"" And Len(zdy5&"")>0 And zdy5&""<>"0" Then
					If InStr(","&Replace(limitsort7," ","")&",",","&zdy5&",")>0 Then iszdy5=True
				ElseIf condition=1 Then
					iszdy5=True
				ElseIf Len(limitsort7&"")>0 and (Len(zdy5&"")=0 Or zdy5&""="0") Then
					iszdy5=True
				end if
			ElseIf condition=1 Then
				iszdy5=True
			end if
			Dim iszdy6 : iszdy6=False
			If ishaszdy6 Then
				If limitsort8&""<>"" And Len(zdy6&"")>0 And zdy6&""<>"0" Then
					If InStr(","&Replace(limitsort8," ","")&",",","&zdy6&",")>0 Then iszdy6=True
				ElseIf condition=1 Then
					iszdy6=True
				ElseIf Len(limitsort8&"")>0 And (Len(zdy6&"")=0 Or zdy6&""="0") Then
					iszdy6=True
				end if
			ElseIf condition=1 Then
				iszdy6=True
			end if
			Dim iskz : iskz=False
			If limitsort9&""<>"" Then
				Dim kz_zdyfields()
				Dim kz_zdyValue()
				reDim kz_zdyfields(0)
				reDim kz_zdyValue(0)
				Dim j : j=0
				Dim iskz_zdy : iskz_zdy=False
				Set rss1=conn.execute("select id,FValue from ERP_CustomFields f left join (select FieldsID,o.id as FValue from ERP_CustomValues v inner join ERP_CustomOptions o on v.FValue=o.cvalue and o.del=1 where v.OrderID='"& tel_ord &"') a on a.FieldsID = f.id where TName=1 and FType=7 and IsUsing=1 and del=1 order by FOrder asc ")
				While Not rss1.eof
					iskz_zdy=True
					redim Preserve kz_zdyfields(j)
					redim Preserve kz_zdyValue(j)
					kz_zdyfields(j)=rss1("id")
					kz_zdyValue(j)=Trim(rss1("FValue"))
					j=j+1
'kz_zdyValue(j)=Trim(rss1("FValue"))
					rss1.movenext
				wend
				rss1.close
				If iskz_zdy Then
					Dim r , strlm,strlm2 ,strlm_one ,kz_zdy ,kz_id ,kz_str
					strlm=Split(limitsort9,"||")
					strlm2=Split(limitsort9,"||")
					For r=0 To ubound(strlm)
						strlm_one=strlm(r)
						If strlm_one<>"" Then
							kz_zdy=Split(strlm_one,":")
							strlm2(r)=kz_zdy(0)
							strlm(r)=kz_zdy(1)
						end if
					next
					kz_id=Join(strlm2,",")
					kz_str=Join(strlm,",")
					For r=0 To ubound(kz_zdyfields)
						If InStr(","&Replace(kz_id," ",""),","&kz_zdyfields(r)&",")>0 Then
							If InStr(","&Replace(kz_str," ",""),","&kz_zdyValue(r)&",")>0 Or (Len(kz_zdyValue(r))=0 Or kz_zdyValue(r)&""="0") Then
								iskz=True
								If condition=0 Then Exit For
							else
								iskz=False
								If condition=1 Then Exit For
							end if
						end if
					next
				ElseIf condition=1 Then
					iskz=True
				end if
			ElseIf condition=1 Then
				iskz=True
			end if
			If len(limitsort1&"")=0 and len(limitsort2&"")=0 and len(limitsort3&"")=0 and len(limitsort4&"")=0 and len(limitsort5&"")=0 and (len(limitsort6&"")=0 or limitsort6="0") and len(limitsort7&"")=0 and len(limitsort8&"")=0 and len(limitsort9&"")=0 Then
			else
				If condition=1 Then
					If isfl And isgj And isly And isjz And ishy And isqy And iszdy5 And iszdy6 And iskz Then
					else
						islingy=False
					end if
				else
					If (isfl and isgj) Or isly Or isjz Or ishy Or isqy Or iszdy5 Or iszdy6 Or iskz Then
					else
						islingy=False
					end if
				end if
			end if
		end if
		canGetCompany = islingy
	end function
	Function ismobileApp()
		ismobileApp = InStr(Trim(Request.ServerVariables("CONTENT_TYPE")), "application/zsml")>0 Or InStr(Trim(Request.ServerVariables("CONTENT_TYPE")) , "application/json")>0 Or Request.QueryString("__mobile2_debug") = "1"
	end function
	Function WatchCustomExtent(byval uid ,ByVal ID)
		Dim r : r = true
		Dim order1 : order1 = 0
		Dim rs
		Dim resort : resort = ""
		Dim resort1: resort1= ""
		Dim rely : rely =""
		Dim rejz: rejz = ""
		Dim retrade: retrade =""
		Dim rearea: rearea =""
		Dim rezdy5: rezdy5 = ""
		Dim rezdy6: rezdy6 = ""
		Dim rekz : rekz = ""
		Dim telarea : telarea = ""
		if ID> 0 Then
			Set rs = conn.execute("select a.*, b.sex,b.name as person,b.part1,b.job,b.mobile,b.QQ,b.email,b.phone2,b.msn from tel a left join person b on a.person=b.ord where a.ord=" & id )
			If rs.eof = False Then
				order1=rs("order1").value
				resort=rs("sort")
				resort1=rs("sort1")
				rely=rs("ly")
				rejz=rs("jz")
				retrade=rs("trade")
				rearea=rs("area")
				rezdy5=rs("zdy5")
				rezdy6=rs("zdy6")
				telarea = rs("area")
			end if
			rs.close
			Set rs = conn.execute("select id,CValue from ERP_CustomOptions where CFID in (select id from ERP_CustomFields where TName=1 and IsUsing=1 and del=1 and FType=7) and  CValue=(select top 1 FValue from ERP_CustomValues where  FieldsID=ERP_CustomOptions.CFID and OrderID="& id & " )")
			While rs.eof=False
				If Len(rekz)>0 Then rekz = rekz & ","
				rekz = rekz & rs("id")
				rs.movenext
			wend
			rs.close
		end if
		If order1<>1 Then
			Dim intro : intro = 0
			Set rs = conn.execute("select isnull(intro,0) as intro from setopen where sort1=39 and isnull(intro,0)>0")
			If rs.eof = False Then
				intro = rs("intro").value
			else
				WatchCustomExtent = True
				Exit Function
			end if
			rs.close
			Dim lysql: lySql = " and cateid=" & uid &  " and isnull(del,1)=1 "
			Dim qysql: qysql = " and ord=" & uid
			if intro = 2 Then
				lySql = " and cateid=0"
				qysql = " and ord=0 "
			end if
			Dim condition :condition = 0
			Set rs = conn.execute("select * from tel_apply where 1=1 " & lySql)
			If rs.eof = True Then
				WatchCustomExtent = True
				Exit Function
			else
				condition = rs("condition").value
				Dim sort , sort1 ,ly,jz,trade ,area ,zdy5 , zdy6
				If ismobileApp = True Then
					sort = Split(app.mobile("sort1"),",")(0)
					sort1 = Split(app.mobile("sort1"),",")(1)
					ly = app.mobile("ly")
					jz = app.mobile("jz")
					trade = app.mobile("trade")
					area = app.mobile("area")
					zdy5 = app.mobile("zdy5")
					zdy6 = app.mobile("zdy6")
				else
					sort = request("sort")
					sort1 = request("sort1")
					ly = request("ly")
					jz = request("jz")
					trade = request("trade")
					area =  request("area")
					zdy5 = request("zdy5")
					zdy6 = request("zdy6")
				end if
				Dim fields : Set fields = GetFields(1)
				Dim isfl : isfl = tel_canLy(condition, rs("limitsort1").value & "", sort, resort , fields.GetItemByDBname("sort").show)
				Dim isgj : isgj = tel_canLy(condition, rs("limitsort2").value & "", sort1, resort1, fields.GetItemByDBname("sort1").show)
				Dim isly : isly = tel_canLy(condition, rs("limitsort3").value & "", ly, rely, fields.GetItemByDBname("ly").show)
				Dim isjz : isjz = tel_canLy(condition, rs("limitsort4").value & "", jz, rejz, fields.GetItemByDBname("jz").show)
				Dim ishy : ishy = tel_canLy(condition, rs("limitsort5").value & "", trade, retrade, fields.GetItemByDBname("trade").show)
				Dim isqy : isqy = false
				if Len(area&"") = 0 then area = telarea
				if rs("limitsort6")= 1 and Len(area)>0 Then
					isqy = (conn.execute("select top 1 id from tel_area where sort=2 and area=" & area & qysql &"").eof =False )
					if area= rearea Then isqy = true
				elseif rs("limitsort6") = 0 and Len(area)= 0 And fields.GetItemByDBname("area").show=True Then
					isqy = true
				ElseIf condition=1 Then
					isqy = true
				end if
				Dim zdyfields : Set zdyfields = GetZdyFields(1)
				Dim iszdy5 : iszdy5 = tel_canLy(condition, rs("limitsort7").value & "", zdy5, rezdy5, zdyfields.GetItemByDBname("zdy5").show )
				Dim iszdy6 : iszdy6 = tel_canLy(condition, rs("limitsort8").value & "", zdy6, rezdy6, zdyfields.GetItemByDBname("zdy6").show )
				Dim limitsort9 : limitsort9 = rs("limitsort9").value & ""
				Dim iskz : iskz = ExtendedLy(condition, limitsort9, rekz)
				if Len(rs("limitsort1")&"")>0 Or Len(rs("limitsort2")&"")>0 Or Len(rs("limitsort3")&"")>0 Or Len(rs("limitsort4")&"")>0 Or Len(rs("limitsort5")&"")>0 Or rs("limitsort6")=1 Or Len(rs("limitsort7")&"")>0 Or Len(rs("limitsort8")&"")>0 Or Len(limitsort9&"")>0 Then
					if condition = 1 Then
						if isfl = false Or isgj = false or isly = false or isjz = false or ishy = false or isqy = false or iszdy5 = false or iszdy6 = false or iskz = False Then r = false
					else
						if (isfl and isgj) = false and isly = false and isjz = false and ishy = false and isqy = false and iszdy5 = false and iszdy6 = False and iskz = False Then r = false
					end if
				end if
			end if
			rs.close
		end if
		WatchCustomExtent = r
	end function
	Function tel_canLy(ByVal typeCondition ,byval limit ,byval  newValue , byval oldValue , byval show)
		Dim r : r = false
		limit = Replace(limit , " ", "")
		if Len(limit) > 0 And Len(newValue) > 0 Then
			if Len(oldValue)> 0 Then  limit = limit & "," & oldValue
			if instr("," & limit & "," , "," & newValue & ",") > 0 Then  r = true
		elseif  Len(limit) > 0 and Len(newValue)= 0 and show Then
			r = true
		elseif typeCondition = 1 Then
			r = true
		end if
		tel_canLy = r
	end function
	Function ExtendedLy(ByVal typeCondition, Byref limit ,ByVal oldValue)
		Dim i
		Dim r : r = False
		If Len(limit)>0 Then
			Dim kz_id : kz_id = ""
			Dim kz_str : kz_str = ""
			Dim strlm : strlm = Split(limit ,"or")
			For i = 0 To ubound(strlm)
				if Len(strlm(i))> 0 Then
					if len(kz_id)> 0 Then kz_id = kz_id & ","
					if len(kz_str)> 0 Then kz_str = kz_str & ","
					kz_id = kz_id & Split(strlm(i) ,":")(0)
					kz_str = kz_str & Split(strlm(i) ,":")(1)
				end if
				if Len(oldValue)> 0 Then kz_str = kz_str & "," & oldValue
			next
			Dim extrafields : Set extrafields = GetExtraFields(1)
			Dim OID , hasKz , field
			hasKz = False
			For i = 0 To extrafields.count-1
'hasKz = False
				Set field = extrafields.item(i)
				If field.show = True And field.sorttype = 7 Then
					If ismobileApp = True Then
						OID = app.mobile("meju_" & field.Key )
					else
						OID = request("meju_" & field.Key )
					end if
					if instr("," & kz_id & ",","," & field.Key & ",") > 0 Then
						hasKz = True
						if instr("," & kz_str & ",","," & OID & ",") > 0 Or Len(OID)=0 Then
							r = true
							if typeCondition = 0 Then Exit For
						else
							r = false
							if typeCondition = 1 Then Exit For
						end if
					end if
				end if
			next
			If hasKz = False Then
				limit = ""
				If typeCondition = 1 Then r = True
			end if
		elseif typeCondition = 1 Then
			r = true
		end if
		ExtendedLy= r
	end function
	Function CustomReviewWatchs(id)
		Dim r : r = False
		Dim rs , rss
		Dim fields : Set fields = GetFields(1)
		if id = 0 or ( id > 0 And conn.execute("select ord from tel where ord='" & id & "' and (datediff(d,getdate(),date1)>=0 or isnull(sp,0)<>0) ").eof= False ) Then
			Dim condition :condition = 0
			Set rs= conn.execute("select * from tel_review ")
			If rs.eof = False Then
				condition = rs("condition").value
				Dim sort , sort1 ,ly,jz,trade ,area ,zdy5 , zdy6
				If ismobileApp = True Then
					sort = Split(app.mobile("sort1"),",")(0)
					sort1 = Split(app.mobile("sort1"),",")(1)
					ly = app.mobile("ly")
					jz = app.mobile("jz")
					trade = app.mobile("trade")
					area = app.mobile("area")
					zdy5 = app.mobile("zdy5")
					zdy6 = app.mobile("zdy6")
				else
					sort = request("sort")
					sort1 = request("sort1")
					ly = request("ly")
					jz = request("jz")
					trade = request("trade")
					area =  request("area")
					zdy5 = request("zdy5")
					zdy6 = request("zdy6")
				end if
				Dim isfl : isfl = hasReview(condition, rs("limitsort1")&"", sort, fields.GetItemByDBname("sort").show)
				Dim isgj : isgj = hasReview(condition, rs("limitsort2")&"", sort1, fields.GetItemByDBname("sort1").show)
				Dim isly : isly = hasReview(condition, rs("limitsort3")&"", ly, fields.GetItemByDBname("ly").show)
				Dim isjz : isjz = hasReview(condition, rs("limitsort4")&"", jz, fields.GetItemByDBname("jz").show)
				Dim ishy : ishy = hasReview(condition, rs("limitsort5")&"", trade, fields.GetItemByDBname("trade").show)
				Dim isqy : isqy = false
				if rs("limitsort6")= 1 Then
					if Len(area)>0 Then
						isqy = (conn.execute("select top 1 id from tel_area where sort=1 and area=" & area &"").eof =False )
					elseif condition= 1 And fields.GetItemByDBname("area").show=False Then
						isqy = True
					end if
				Elseif condition= 1 Then
					isqy = True
				end if
				Dim zdyfields : Set zdyfields = GetZdyFields(1)
				Dim iszdy5 : iszdy5 = hasReview(condition, rs("limitsort7")&"", zdy5,  zdyfields.GetItemByDBname("zdy5").show )
				Dim iszdy6 : iszdy6 = hasReview(condition, rs("limitsort8")&"", zdy6, zdyfields.GetItemByDBname("zdy6").show )
				Dim limitsort9 : limitsort9 = rs("limitsort9")&""
				Dim iskz : iskz = ExtendedReview(condition, limitsort9)
				if Len(rs("limitsort1")&"")>0 Or Len(rs("limitsort2")&"")>0 Or Len(rs("limitsort3")&"")>0 Or Len(rs("limitsort4")&"")>0 Or Len(rs("limitsort5")&"")>0 Or rs("limitsort6")=1 Or Len(rs("limitsort7")&"")>0 Or Len(rs("limitsort8")&"")>0 Or Len(limitsort9&"")>0 Then
					if condition = 1 Then
						if isfl and isgj and isly and isjz and ishy and isqy and iszdy5 and iszdy6 and iskz Then  r = true
					else
						if (isfl and isgj) or isly or isjz or ishy or isqy or iszdy5 or iszdy6 or iskz Then  r = true
					end if
				end if
			end if
		end if
		CustomReviewWatchs = r
	end function
	Function hasReview(ByVal condition , ByVal limit , ByVal newValue ,ByVal show)
		Dim r : r = false
		limit = Replace(limit, " ", "")
		if Len(limit) > 0 Then
			if Len(newValue) > 0 Then
				If instr("," & limit & "," , "," & newValue & ",") > 0  Then  r = true
			elseif show=False and condition = 1 Then
				r = true
			end if
		elseif condition=1 Then
			r = True
		end if
		hasReview = r
	end function
	Function ExtendedReview(ByVal typeCondition, Byref limit)
		Dim r ,i ,field
		r = False
		If Len(limit)>0 Then
			Dim kz_id : kz_id = ""
			Dim kz_str : kz_str = ""
			Dim strlm : strlm = Split(limit ,"or")
			For i = 0 To ubound(strlm)
				if Len(strlm(i))> 0 Then
					if len(kz_id)> 0 Then kz_id = kz_id & ","
					if len(kz_str)> 0 Then kz_str = kz_str & ","
					kz_id = kz_id & Split(strlm(i) ,":")(0)
					kz_str = kz_str & Split(strlm(i) ,":")(1)
				end if
			next
			Dim extrafields : Set extrafields = GetExtraFields(1)
			Dim OID , hasKz
			hasKz = False
			For i = 0 To extrafields.count-1
'hasKz = False
				Set field = extrafields.item(i)
				If field.show = True And field.sorttype = 7 Then
					If ismobileApp = True Then
						OID = app.mobile("meju_" & field.Key )
					else
						OID = request("meju_" & field.Key )
					end if
					if instr("," & kz_id & ",","," & field.Key & ",") > 0 Then
						hasKz = True
						if instr("," & kz_str & ",","," & OID & ",") > 0 and Len(OID)>0 Then
							r = true
							if typeCondition = 0 Then Exit For
						else
							r = false
							if typeCondition = 1 Then Exit For
						end if
					end if
				end if
			next
			If hasKz = False Then
				limit = ""
				If typeCondition = 1 Then r = True
			end if
		elseif typeCondition = 1 Then
			r = true
		end if
		ExtendedReview = r
	end function
	Public pub_cf,KZ_LIMITID
	Function getExtended(TName,ord)
		Call showExtended(TName,ord,3,1,1)
	end function
	function ShowExtendedByProductGroup(byval TName,byval ord,byval columns, byval col1, byval col2 ,byval isIntro ,byval bzstr ,byval tsstr ,byval oldZdySort ,byval readonly,byval zdygroupid)
		if zdygroupid = 0 then zdygroupid = -1
		dim rss
		Response.write "" & vbcrlf & "       <tr class=""top accordion"" id=""cpBasezdygroup"">" & vbcrlf & "      <td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "           <div  class=""accordion-bar-tit"" style=""padding-top:6px;"">" & vbcrlf & "                   自定义字段 <span class=""accordion-arrow-down""></span>" & vbcrlf & "             </div>" & vbcrlf & "          <div onclick=""app.stopDomEvent();return false"" style=""float:left;padding:5px"">" & vbcrlf & "              &nbsp;" & vbcrlf & "          "
		if readonly then
			dim wsql : wsql = " and  ord="  & clng(zdygroupid)
			if zdygroupid = -1 then wsql=" and tagdata='1' "
'dim wsql : wsql = " and  ord="  & clng(zdygroupid)
			set rss = conn.execute("select ord, sort1, tagdata from sortonehy where gate2=63 and ord=" & zdygroupid)
			if rss.eof = false then
				Response.write rss("sort1").value
			end if
			rss.close
		else
			Response.write "" & vbcrlf & "              <select name=""zdygroupid"" style=""min-width:100px"" onchange=""refreshProductGroupArea("
			rss.close
			Response.write ord
			Response.write ", this)"">" & vbcrlf & "                  "
			set rss = conn.execute("select ord, (case tagdata when '1' then '' else sort1 end) as sort1, tagdata from sortonehy where gate2=63 order by gate1 desc")
			while rss.eof = false
				tagdata = rss("tagdata").value
				sortord =rss("ord").value
				if tagdata = "1" then sortord = 0
				if zdygroupid = sortord then
					Response.write "<option value='" & sortord & "' selected>" & rss("sort1").value & "</option>"
				else
					Response.write "<option value='" & sortord & "'>" & rss("sort1").value & "</option>"
				end if
				rss.movenext
			wend
			rss.close
			Response.write "" & vbcrlf & "              </select>" & vbcrlf & "               <script>" & vbcrlf & "                        function refreshProductGroupArea(billord,  sbox ){" & vbcrlf & "                              var  x = new XMLHttpRequest();" & vbcrlf & "                          x.open(""Get"", window.sysCurrPath + ""inc/GetExtended.ProductGroup.asp?t="" + (new Date()).getTime() + ""&billord="" + billord + ""&groupid="" + sbox.value,  false)" & vbcrlf & "                          x.send();" & vbcrlf & "                               var html = x.responseText;" & vbcrlf & "                              x = null;" & vbcrlf & "                               var myrow = $(""#cpBasezdygroup"");" & vbcrlf & "                         var currgprow = $(""tr.zdyrowgroup1"");" & vbcrlf & "                             currgprow.remove(); "& vbcrlf & "                               if(html.length>0 && html.indexOf(""<tr"")>=0) " & vbcrlf & "                              {" & vbcrlf & "                                               myrow.after(html)" & vbcrlf & "                               }" & vbcrlf & "                               if(window.BillExtSN){" & vbcrlf & "                                   window.BillExtSN.BindKeys = undefined;" & vbcrlf & "                                  jQuery(""input[type=text]"").unbind(""blur"", window.BillExtSN.Refresh).bind(""blur"", window.BillExtSN.Refresh);" & vbcrlf & "                                       jQuery(""input[type=checkbox]"").unbind(""click"", window.BillExtSN.Refresh).bind(""click"", window.BillExtSN.Refresh);" & vbcrlf & "                                     jQuery(""input[type=radio]"").unbind(""click"", window.BillExtSN.Refresh).bind(""click"", window.BillExtSN.Refresh)" & vbcrlf & "                                   jQuery(""select"").unbind(""change"", window.BillExtSN.Refresh).bind(""change"", window.BillExtSN.Refresh);" & vbcrlf & "                                 jQuery(""textarea"").unbind(""blur"", window.BillExtSN.Refresh).bind(""blur"", window.BillExtSN.Refresh);" & vbcrlf &"                                  var data = [];" & vbcrlf & "                                  var CatchFields = [];" & vbcrlf & "                                   var frm = document.getElementsByTagName(""form"")[0];" & vbcrlf & "                                       if (!frm) { return; }" & vbcrlf & "                                   var boxs = jQuery(frm).serializeArray();" & vbcrlf & "                                        for (var i = boxs.length - 1; i >= 0; i--) {" & vbcrlf & "                                           if (i > 0 && boxs[i].name == boxs[i - 1].name) {" & vbcrlf & "                                                        boxs[i - 1].value = boxs[i - 1].value + "","" + boxs[i].value;" & vbcrlf & "                                                      boxs[i].name = """";" & vbcrlf & "                                                } else {" & vbcrlf & "                                                        var n = boxs[i].name;" & vbcrlf & "                                                   var box = document.getElementsByName(n)[0];" & vbcrlf & "                                                        if (box.tagName == ""SELECT"") {" & vbcrlf & "                                                            boxs.push({ name: boxs[i].name + ""_selectvalue"", value: (boxs[i].value + """") });" & vbcrlf & "                                                            boxs[i].value = box.options[box.options.selectedIndex].text;" & vbcrlf & "                                                    }" & vbcrlf & "               }" & vbcrlf & "                                       }" & vbcrlf & "                                       for (var i = 0; i < boxs.length; i++) {" & vbcrlf & "                                         var ibox = boxs[i];" & vbcrlf & "                                             var n = ibox.name;" & vbcrlf & "                                              if (n) {" & vbcrlf & "                                                        CatchFields.push(n);" & vbcrlf & "                                                    if (ibox.value.length < 200) { //200字限制" & vbcrlf & "                                                         data.push(n + ""="" + encodeURIComponent(encodeURIComponent(ibox.value)));" & vbcrlf & "                                                  } else {" & vbcrlf & "                                                                data.push(n + ""="");" & vbcrlf & "                                                       }" & vbcrlf & "                                               }" & vbcrlf & "                                       }" & vbcrlf & "                                       data.push(""__CatchFields="" + encodeURIComponent(CatchFields.join(""|"")));" & vbcrlf & "                                  data.push(""__BillTypeId="" + window.BillExtSN.CodeType);" & vbcrlf & "                                   var xhttp = window.XMLHttpRequest ? (new XMLHttpRequest()):(new ActiveXObject(""Microsoft.XMLHTTP""));" & vbcrlf & "                                      xhttp.open(""POST"", ((window.sysCurrPath ? (window.sysCurrPath + ""../"") : window.SysConfig.VirPath) + ""SYSN/view/comm/GetBHValue.ashx?GB2312=1""), false);" & vbcrlf & "                                      xhttp.setRequestHeader(""content-type"", ""application/x-www-form-urlencoded"");" & vbcrlf & "                                        xhttp.send(data.join(""&""));" & vbcrlf & "                                       var obj = eval(""("" + xhttp.responseText + "")"");" & vbcrlf &                                   "  window.BillExtSN.BindKeys = obj.keys; "& vbcrlf &                                   " //window.BillExtSN.ReBindEvt();" & vbcrlf &                         " }" & vbcrlf &                       " } "& vbcrlf &               " </script> "& vbcrlf & ""
		end if
		Response.write "" & vbcrlf & "              </div>" & vbcrlf & "  </tr>" & vbcrlf & "   "
		call ShowExtendedByKZZDY( TName, ord, columns,  col1,  col2 , false , bzstr , tsstr , oldZdySort , readonly, zdygroupid)
		call ShowExtendedByKZZDY( TName, ord, 1,  col1,  columns*2-1 , true , bzstr , tsstr , oldZdySort , readonly, zdygroupid)
	end function
	function ShowExtendedByKZZDY(byval TName,byval ord,byval columns, byval col1, byval col2 ,byval isIntro ,byval bzstr ,byval tsstr ,byval oldZdySort ,byval readonly,byval zdygroupid)
		dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7 , introsql
		dim  num1, i_jm, j_jm, c_Value,colstr1,colstr2,rssort,moneyDigits,numDigits,priceDigits
		set rssort=conn.execute("select num1 from setjm3 where ord=1")
		if not rssort.eof then
			moneyDigits=rssort(0)
		else
			moneyDigits=2
		end if
		set rssort=conn.execute("select num1 from setjm3 where ord=2019042802")
		if not rssort.eof then
			priceDigits=rssort(0)
		else
			priceDigits=2
		end if
		set rssort=conn.execute("select num1 from setjm3 where ord=88")
		if not rssort.eof then
			numDigits=rssort(0)
		else
			numDigits=2
		end if
		If col1>1 Then colstr1= " colspan='"&col1&"'"
		If col2>1 Then colstr2= " colspan='"&col2&"'"
		if TName=1001 or ord=-1 Then columns=2
'If col2>1 Then colstr2= " colspan='"&col2&"'"
		If ord = "" Then ord=0
		if isIntro=false then
			introsql = " and uitype<>13  "
		else
			introsql = " and uitype=13  "
		end if
		dim id, FName , dname , UiType,MustFillin,TextLen
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select *,case Id when 1 then 7 when 2 then 8 when 3 then 9 when 4 then 10 when 5 then 11 when 6 then 12 else Id end zdyid, 0 as mustshow, ' ' as arename  "
		sql = sql + " from sys_sdk_BillFieldInfo where billtype="& TName &" and ListType='0' and isused = 1 "& introsql & " and ProductZdyGroupId=" & clng(zdygroupid)
		sql = sql + " order by RootDataType desc, Showindex "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if rs_kz_zdy.eof = False then
			Response.write("<tr class='zdyrowgroup" + cstr(abs(zdygroupid*1>0)) + "'>")
'if rs_kz_zdy.eof = False then
			do until rs_kz_zdy.eof
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr class='zdyrowgroup" + cstr(abs(zdygroupid*1>0)) + "'>")
'if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					j_jm=j_jm+1
'if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
				end if
				c_Value=""
				id = rs_kz_zdy("zdyid")
				FName = rs_kz_zdy("title")
				dname = rs_kz_zdy("dbname")
				UiType = rs_kz_zdy("UiType")
				MustFillin = rs_kz_zdy("MustFillin")
				netid = rs_kz_zdy("id")
				TextLen = rs_kz_zdy("TextLen")
				Response.write "" & vbcrlf & "                     <td width=""11%"" align=""right"" "
				Response.write colstr1
				Response.write ">"
				Response.write FName
				Response.write "：</td>" & vbcrlf & "                      <td width=""22%"" "
				if i_jm=num1-1  then
					Response.write "：</td>" & vbcrlf & "                      <td width=""22%"" "
					Response.write "colspan="""
					Response.write col2+(col1+col2)*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """ "
				else
					Response.write colstr2
				end if
				Response.write ">" & vbcrlf & "                    "
				if instr(dname,"ext")>0 then
					zid = replace(dname&"","ext","")
					Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="& zid &" and OrderID="&ord&" and OrderID>0 ")
					If rs_kz_zdy_88.eof = False  Then c_Value=rs_kz_zdy_88("FValue")
					rs_kz_zdy_88.close
					if readonly then
						select case UiType
						case 31 :
						Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
						Response.write replace(c_Value,",","->")
						Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
						Response.write "</span>"
						case 2 :
						Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
						Response.write getExtendedValue(c_Value,numDigits)
						Response.write "</span>"
						case 3 :
						Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
						Response.write getExtendedValue(c_Value,moneyDigits)
						Response.write "</span>"
						case 3000 :
						Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
						Response.write getExtendedValue(c_Value,priceDigits)
						Response.write "</span>"
						Case Else:
						Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
						Response.write c_Value
						Response.write "</span>"
						end select
					else
						c_Value=replace(replace(c_Value&"","""","&#34;"),"'","&#39;")
						select case UiType
						case 0 :
						Response.write "" & vbcrlf & "                                     <input name=""danh_"
						Response.write zid
						Response.write """ type=""text"" size=""15"" id=""danh_"
						Response.write zid
						Response.write """ value="""
						Response.write c_Value
						Response.write """ dataType=""Limit"" "
						if MustFillin=1  then
							Response.write " min=""1""  msg=""必须在1到"
							Response.write TextLen
							Response.write "个字符之间""  "
						else
							Response.write " msg=""长度不能超过"
							Response.write TextLen
							Response.write "个字"" "
						end if
						Response.write "  max="
						Response.write TextLen
						Response.write " maxlength=""4000"">" & vbcrlf & "                                     "
						case 1:
						Response.write "" & vbcrlf & "                                     <input class=""resetDataPickerBg"" readonly name=""date_"
						Response.write zid
						Response.write """ value="""
						Response.write c_Value
						Response.write """ size=""15"" id=""daysOfMonthPos"" onmouseup=""toggleDatePicker('daysOfMonth_"
						Response.write zid
						Response.write "','date_"
						Response.write zid
						Response.write "')"" dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:93px;width:111px;;background-repeat:no-repeat;""> <div id=""daysOfMonth_"
						Response.write " min=""1"" "
						Response.write zid
						Response.write """ style=""POSITION:absolute""></div>" & vbcrlf & "                                  "
						case 2:
						Response.write "" & vbcrlf & "                                     <input name=""Numr_"
						Response.write zid
						Response.write """ type=""text"" value="""
						Response.write c_Value
						Response.write """ size=""15"" id=""Numr_"
						Response.write zid
						Response.write """ onpropertychange=""formatData(this,'number')"" dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                                  "
						case 3:
						Response.write "" & vbcrlf & "                                     <input name=""danh_"
						Response.write zid
						Response.write """ type=""text"" value="""
						Response.write c_Value
						Response.write """ size=""15"" id=""Numr_"
						Response.write zid
						Response.write """ onpropertychange=""formatData(this,'money')""  dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                                  "
						case 36:
						Response.write "" & vbcrlf & "                                     <input name=""danh_"
						Response.write zid
						Response.write """ type=""text"" value="""
						Response.write c_Value
						Response.write """ size=""15"" id=""Numr_"
						Response.write zid
						Response.write """  onpropertychange=""formatData(this,'int')""   dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                                  "
						case 3000:
						Response.write "" & vbcrlf & "                                     <input name=""danh_"
						Response.write zid
						Response.write """ type=""text"" value="""
						Response.write c_Value
						Response.write """ size=""15"" id=""Numr_"
						Response.write zid
						Response.write """ onpropertychange=""formatData(this,'CommPrice')"" dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                                  "
						case 4:
						Response.write "" & vbcrlf & "                                     <select name=""IsNot_"
						Response.write zid
						Response.write """ id=""IsNot_"
						Response.write zid
						Response.write """  dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                                   <option value=""是"" "
						If c_Value="是" then
							Response.write "selected"
						end if
						Response.write ">是</option>" & vbcrlf & "                                 <option value=""否"" "
						If c_Value="否" then
							Response.write "selected"
						end if
						Response.write ">否</option>" & vbcrlf & "                                 </select>" & vbcrlf & "                                       "
						case 5:
						Response.write "" & vbcrlf & "                                     <select name=""meju_"
						Response.write zid
						Response.write """ id=""meju_"
						Response.write zid
						Response.write """  dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                                   "
						xxsql = "select t1.id, t1.CValue from (select id,CValue from ERP_CustomOptions x  where CFID="& zid &") t1 "
						xxsql = xxsql & " inner join  (select [text], ShowIndex  from  sys_sdk_BillFieldOptionsSource where  Stoped=0 and FieldId=" & netid & "  ) t2  " &_
						" on t1.CValue = t2.[text]  order by t2.showindex "
						set rs7=conn.execute(xxsql)
						do until rs7.eof
							Response.write "" & vbcrlf & "                                             <option value="""
							Response.write rs7("id")
							Response.write """ "
							If rs7("CValue")&""=c_Value&"" then
								Response.write "selected"
							end if
							Response.write ">"
							Response.write rs7("CValue")
							Response.write "</option>" & vbcrlf & "                                            "
							rs7.movenext
						loop
						rs7.close
						Response.write "" & vbcrlf & "                                 </select>" & vbcrlf & "                                   "
						case 54:
						cixx = 0
						xxsql = "select t1.id, t1.CValue from (select id,CValue from ERP_CustomOptions x  where CFID="& zid &") t1 "
						xxsql = xxsql & " inner join  (select [text], ShowIndex  from  sys_sdk_BillFieldOptionsSource where  Stoped=0 and FieldId=" & netid & "  ) t2  " &_
						" on t1.CValue = t2.[text]  order by t2.showindex "
						set rs7=conn.execute(xxsql)
						do until rs7.eof
							Response.write "" & vbcrlf & "                                                      <input name=""danh_"
							Response.write zid
							Response.write """ id=""danh_"
							Response.write zid
							Response.write "_"
							Response.write cixx
							Response.write """ "
							if  instr("," & c_value   & ",", "," & rs7("CValue").value & ",")>0 then Response.write "checked"
							Response.write "  type=""checkbox"" value="""
							Response.write replace(rs7("CValue").value & "", """","&#34")
							Response.write """ >" & vbcrlf & "                                                       <label for=""danh_"
							Response.write zid
							Response.write "_"
							Response.write cixx
							Response.write """>"
							Response.write replace(rs7("CValue").value & "", """","&#34")
							Response.write "</label>" & vbcrlf & "                                             "
							cixx = cixx +1
							Response.write "</label>" & vbcrlf & "                                             "
							rs7.movenext
						loop
						rs7.close
						case 31:
						Response.write "" & vbcrlf & "                                     <select name=""danh_"
						Response.write zid
						Response.write """ id=""danh_"
						Response.write zid
						Response.write """  dataType=""Limit"" "
						if MustFillin=1 then
							Response.write " min=""1"" "
						end if
						Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                                   "
						exitsgp = false
						ptxt = ""
						xxsql =  "select  [Text] as cvalue, deep  from sys_sdk_BillFieldOptionsSource a "
						xxsql = xxsql & " where  Stoped=0 and FieldId=" & netid & " "
						xxsql = xxsql & " and ( ParentId=0 or exists(select 1 from  sys_sdk_BillFieldOptionsSource b where a.ParentId=b.id and b.Stoped=0) )"
						xxsql = xxsql & " order by ShowIndex "
						set rs7=conn.execute(xxsql)
						do until rs7.eof
							if rs7("deep").value=0 then
								if exitsgp then Response.write "</optgroup>"
								Response.write " <optgroup label=""" &  rs7("cvalue")  & """>"
								ptxt  = rs7("cvalue").value
								exitsgp = true
							else
								myvalue = ptxt & "," & rs7("CValue")
								Response.write "" & vbcrlf & "                                             <option value="""
								Response.write myvalue
								Response.write """ "
								If myvalue&""=c_Value&"" then
									Response.write "selected"
								end if
								Response.write ">"
								Response.write rs7("CValue")
								Response.write "</option>" & vbcrlf & "                                            "
							end if
							rs7.movenext
						loop
						rs7.close
						if exitsgp then Response.write "</optgroup>"
						Response.write "" & vbcrlf & "                                 </select>" & vbcrlf & "                                   "
						case 10:
						Response.write "" & vbcrlf & "                        <textarea name=""duoh_"
						Response.write zid
						Response.write """ id=""duoh_"
						Response.write zid
						Response.write """ style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px;padding-left:4px;"" onfocus=""this.style.height=this.scrollHeight"" onpropertychange=""this.style.height=this.scrollHeight"" dataType=""Limit"" "
						Response.write zid
						if MustFillin=1 then
							Response.write " min=""1""   msg=""必须在1到"
							Response.write TextLen
							Response.write "个字符之间"" "
						else
							Response.write " msg=""长度不能超过"
							Response.write TextLen
							Response.write "个字"" "
						end if
						Response.write " max="
						Response.write TextLen
						Response.write ">"
						Response.write c_Value
						Response.write "</textarea>" & vbcrlf & "                        "
						case 13:
						Response.write "" & vbcrlf & "                        <textarea name=""beiz_"
						Response.write zid
						Response.write """ id=""beiz_"
						Response.write zid
						Response.write """ dataType=""Limit"" "
						If MustFillin=1 Then
							Response.write "min=""1"""
						end if
						Response.write "" & vbcrlf & "                            max=""4000""  msg=""备注长度不能超过4000个字"" style=""display:none;"" cols=""1"" rows=""1"">"
						if c_Value<>"" then Response.write c_Value End if
						Response.write "</textarea>" & vbcrlf & "                                  <IFRAME ID=""eWebEditor_"
						Response.write zid
						Response.write """ SRC=""../edit/ewebeditor.asp?id=beiz_"
						Response.write zid
						Response.write "&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""300"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME>" & vbcrlf & "                        "
						end select
					end if
				else
					dim tbname : tbname = ""
					select case TName
					case 16001 : tbname = "product"
					end select
					if ord<>0 then
						c_Value = sdk.getSqlValue("select "& dname &" from "& tbname & " where ord="& ord,"")
						if UiType<>0 and len(c_Value)>0 and readonly then
							c_Value = sdk.getSqlValue("select sort1 from sortonehy where ord= "& c_Value,"")
						end if
					end if
					if readonly then
						Response.write "<span class=""gray ewebeditorImg"">&nbsp;"
						Response.write c_Value
						Response.write "</span>"
					else
						if UiType=0 then
							c_Value=replace(replace(c_Value&"","""","&#34;"),"'","&#39;")
							Response.write "" & vbcrlf & "                        <input name="""
							Response.write dname
							Response.write """ type=""text"" size=""20"" id="""
							Response.write dname
							Response.write """ value="""
							Response.write c_Value
							Response.write """ "
							if CheckPurview(tsstr,dname)=True then
								Response.write "onChange=""callServer_ts('"
								Response.write id
								Response.write "','"
								Response.write dname
								Response.write "');"""
							end if
							Response.write " dataType=""Limit"" "
							if  CheckPurview(bzstr,dname)=True or MustFillin=1  then
								Response.write " min=""1"" "
							end if
							Response.write "  max=""200""  msg=""必须在1到200个字符之间"">" & vbcrlf & "                        "
						else
							Response.write "" & vbcrlf & "                        <select name="""
							Response.write dname
							Response.write """ "
							if CheckPurview(tsstr,dname)=True then
								Response.write "onChange=""callServer_ts('"
								Response.write id
								Response.write "','"
								Response.write dname
								Response.write "');"""
							end if
							Response.write " id="""
							Response.write dname
							Response.write """   dataType=""Limit"" "
							if  CheckPurview(btstr,dname)=True  then
								Response.write " min=""1"" "
							end if
							Response.write "  max=""50""  msg=""长度不能超过50个字"">" & vbcrlf & "                        "
							dim gl : gl = sdk.getSqlValue("select gl from zdy where sort1= "& oldZdySort & " and name='"& dname &"' ",0)
							set rs7=server.CreateObject("adodb.recordset")
							sql7="select ord,sort1 from sortonehy where gate2="& gl &" order by gate1 desc "
							rs7.open sql7,conn,1,1
							do until rs7.eof
								Response.write "" & vbcrlf & "                            <option value="""
								Response.write rs7("ord")
								Response.write """ "
								if rs7("ord").value &""=c_Value&"" then
									Response.write "selected"
								end if
								Response.write " >"
								Response.write rs7("sort1")
								Response.write "</option>" & vbcrlf & "                            "
								rs7.movenext
							loop
							rs7.close
							set rs7=nothing
							Response.write "" & vbcrlf & "                        </select>" & vbcrlf & "                        "
						end if
					end if
				end if
				Response.write " <span id=""test"
				Response.write id
				Response.write """ class=""red"">"
				if  (MustFillin=1 or CheckPurview(bzstr,dname)=true) and readonly=false Then
					Response.write "*"
				end if
				Response.write "</span>" & vbcrlf & "                      </td>" & vbcrlf & "                   "
				i_jm=i_jm+1
				Response.write "</span>" & vbcrlf & "                      </td>" & vbcrlf & "                   "
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function showExtended(TName,ord,columns,col1,col2)
		dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7
		dim  num1, i_jm, j_jm, c_Value,colstr1,colstr2
		If col1>1 Then colstr1= " colspan='"&col1&"'"
		If col2>1 Then colstr2= " colspan='"&col2&"'"
		if TName=1001 or ord=-1 Then columns=2
'If col2>1 Then colstr2= " colspan='"&col2&"'"
		If ord = "" Then ord=0
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 and FType<>'5' order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if rs_kz_zdy.eof = False then
			Response.write("<tr>")
			do until rs_kz_zdy.eof
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr>")
					j_jm=j_jm+1
					Response.write("</tr><tr>")
				end if
				c_Value=""
				Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy("id")&" and OrderID="&ord&" and OrderID>0 ")
				If rs_kz_zdy_88.eof = False  Then c_Value=rs_kz_zdy_88("FValue")
				rs_kz_zdy_88.close
				Response.write "" & vbcrlf & "                      <td width=""11%"" align=""right"" "
				Response.write colstr1
				Response.write ">"
				Response.write rs_kz_zdy("FName")
				Response.write "：</td>" & vbcrlf & "                       <td width=""22%"" "
				if i_jm=num1-1  then
					Response.write "：</td>" & vbcrlf & "                       <td width=""22%"" "
					Response.write "colspan="""
					Response.write col2+(col1+col2)*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """ "
				else
					Response.write colstr2
				end if
				Response.write ">" & vbcrlf & "                     "
				if rs_kz_zdy("FType")="1" Then
					Response.write "" & vbcrlf & "                              <input name=""danh_"
					Response.write rs_kz_zdy("id")
					Response.write """ type=""text"" size=""15"" id=""danh_"
					Response.write rs_kz_zdy("id")
					Response.write """ value="""
					Response.write c_Value
					Response.write """ dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1""  msg=""必须在1到200个字符之间""  "
					else
						Response.write " msg=""长度不能超过200个字"" "
					end if
					Response.write "  max=""200"" maxlength=""4000"">" & vbcrlf & "                             "
				Elseif rs_kz_zdy("FType")="2" then
					Response.write "" & vbcrlf & "                              <textarea name=""duoh_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""duoh_"
					Response.write rs_kz_zdy("id")
					Response.write """ style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px;padding-left:4px;"" onfocus=""this.style.height=this.scrollHeight"" onpropertychange=""this.style.height=this.scrollHeight"" dataType=""Limit"" "
					Response.write rs_kz_zdy("id")
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1""   msg=""必须在1到500个字符之间"" "
					else
						Response.write " msg=""长度不能超过500个字"" "
					end if
					Response.write " max=""500"">"
					Response.write c_Value
					Response.write "</textarea>" & vbcrlf & "                           "
				elseif rs_kz_zdy("FType")="3" Then
					Response.write "" & vbcrlf & "                              <input class=""resetDataPickerBg"" readonly name=""date_"
					Response.write rs_kz_zdy("id")
					Response.write """ value="""
					Response.write c_Value
					Response.write """ size=""15"" id=""daysOfMonthPos"" onmouseup=""toggleDatePicker('daysOfMonth_"
					Response.write rs_kz_zdy("id")
					Response.write "','date_"
					Response.write rs_kz_zdy("id")
					Response.write "')"" dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:93px;width:111px;;background-repeat:no-repeat;""> <div id=""daysOfMonth_"
					Response.write " min=""1"" "
					Response.write rs_kz_zdy("id")
					Response.write """ style=""POSITION:absolute""></div>" & vbcrlf & "                           "
				ElseIf rs_kz_zdy("FType")="4" then
					Response.write "" & vbcrlf & "                              <input name=""Numr_"
					Response.write rs_kz_zdy("id")
					Response.write """ type=""text"" value="""
					Response.write c_Value
					Response.write """ size=""15"" id=""Numr_"
					Response.write rs_kz_zdy("id")
					Response.write """ onkeyup=value=value.replace(/[^\d\.]/g,'') dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                           "
				ElseIf rs_kz_zdy("FType")="6" then
					Response.write "" & vbcrlf & "                              <select name=""IsNot_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""IsNot_"
					Response.write rs_kz_zdy("id")
					Response.write """  dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                            <option value=""是"" "
					If c_Value="是" then
						Response.write "selected"
					end if
					Response.write ">是</option>" & vbcrlf & "                          <option value=""否"" "
					If c_Value="否" then
						Response.write "selected"
					end if
					Response.write ">否</option>" & vbcrlf & "                          </select>" & vbcrlf & "                               "
				else
					Response.write "" & vbcrlf & "                              <select name=""meju_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""meju_"
					Response.write rs_kz_zdy("id")
					Response.write """  dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                           "
					set rs7=conn.execute("select id,CValue from ERP_CustomOptions where CFID="&rs_kz_zdy("id")&" order by id asc ")
					do until rs7.eof
						Response.write "" & vbcrlf & "                                     <option value="""
						Response.write rs7("id")
						Response.write """ "
						If rs7("CValue")&""=c_Value&"" then
							Response.write "selected"
						end if
						Response.write ">"
						Response.write rs7("CValue")
						Response.write "</option>" & vbcrlf & "                                    "
						rs7.movenext
					loop
					rs7.close
					Response.write "" & vbcrlf & "                        </select>" & vbcrlf & "                            "
				end if
				if  rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then
					Response.write " <span class=""red"">*</span>"
				end if
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
				i_jm=i_jm+1
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function showExtended2(TName,ord,columns,col1,col2)
		dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7
		dim  num1, i_jm, j_jm, c_Value,colstr1,colstr2
		If col1>1 Then colstr1= " colspan='"&col1&"'"
		If col2>1 Then colstr2= " colspan='"&col2&"'"
		if TName=1001 or ord=-1 Then columns=2
'If col2>1 Then colstr2= " colspan='"&col2&"'"
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 and FType<>'5' order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if rs_kz_zdy.eof = False then
			Response.write("<tr>")
			do until rs_kz_zdy.eof
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr>")
					j_jm=j_jm+1
					Response.write("</tr><tr>")
				end if
				c_Value=""
				Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy("id")&" and OrderID="&ord&" and OrderID>0 ")
				If rs_kz_zdy_88.eof = False  Then c_Value=rs_kz_zdy_88("FValue")
				rs_kz_zdy_88.close
				Response.write "" & vbcrlf & "                     <td align=""right"" "
				Response.write colstr1
				Response.write ">"
				Response.write rs_kz_zdy("FName")
				Response.write "：</td>" & vbcrlf & "                      <td "
				if i_jm=num1-1  then
					Response.write "：</td>" & vbcrlf & "                      <td "
					Response.write "colspan="""
					Response.write col2+(col1+col2)*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """ "
				else
					Response.write colstr2
				end if
				Response.write ">" & vbcrlf & "                    "
				if rs_kz_zdy("FType")="1" Then
					Response.write "" & vbcrlf & "                             <input name=""danh_"
					Response.write rs_kz_zdy("id")
					Response.write """ type=""text"" size=""15"" id=""danh_"
					Response.write rs_kz_zdy("id")
					Response.write """ value="""
					Response.write c_Value
					Response.write """ dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"" maxlength=""4000"">" & vbcrlf & "                            "
				Elseif rs_kz_zdy("FType")="2" then
					Response.write "" & vbcrlf & "                             <textarea name=""duoh_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""duoh_"
					Response.write rs_kz_zdy("id")
					Response.write """ style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px"" onfocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" dataType=""Limit"" "
					Response.write rs_kz_zdy("id")
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write " max=""500""  msg=""必须在1到500个字符"">"
					Response.write c_Value
					Response.write "</textarea>" & vbcrlf & "                          "
				elseif rs_kz_zdy("FType")="3" Then
					Response.write "" & vbcrlf & "                             <input readonly name=""date_"
					Response.write rs_kz_zdy("id")
					Response.write """ value="""
					Response.write c_Value
					Response.write """ size=""15"" id=""daysOfMonthPos"" onmouseup=""toggleDatePicker('daysOfMonth_"
					Response.write rs_kz_zdy("id")
					Response.write "','date_"
					Response.write rs_kz_zdy("id")
					Response.write "')"" dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:right;background-repeat:no-repeat;""> <div id=""daysOfMonth_"
					Response.write " min=""1"" "
					Response.write rs_kz_zdy("id")
					Response.write """ style=""POSITION:absolute""></div>" & vbcrlf & "                          "
				ElseIf rs_kz_zdy("FType")="4" then
					Response.write "" & vbcrlf & "                             <input name=""Numr_"
					Response.write rs_kz_zdy("id")
					Response.write """ type=""text"" value="""
					Response.write c_Value
					Response.write """ size=""15"" id=""Numr_"
					Response.write rs_kz_zdy("id")
					Response.write """ onkeyup=value=value.replace(/[^\d\.]/g,'') dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                          "
				ElseIf rs_kz_zdy("FType")="6" then
					Response.write "" & vbcrlf & "                             <select name=""IsNot_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""IsNot_"
					Response.write rs_kz_zdy("id")
					Response.write """  dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                           <option value=""是"" "
					If c_Value="是" then
						Response.write "selected"
					end if
					Response.write ">是</option>" & vbcrlf & "                         <option value=""否"" "
					If c_Value="否" then
						Response.write "selected"
					end if
					Response.write ">否</option>" & vbcrlf & "                         </select>" & vbcrlf & "                               "
				else
					Response.write "" & vbcrlf & "                             <select name=""meju_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""meju_"
					Response.write rs_kz_zdy("id")
					Response.write """  dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                           "
					set rs7=conn.execute("select id,CValue from ERP_CustomOptions where CFID="&rs_kz_zdy("id")&" order by id asc ")
					do until rs7.eof
						Response.write "" & vbcrlf & "                                     <option value="""
						Response.write rs7("id")
						Response.write """ "
						If rs7("CValue")&""=c_Value&"" then
							Response.write "selected"
						end if
						Response.write ">"
						Response.write rs7("CValue")
						Response.write "</option>" & vbcrlf & "                                    "
						rs7.movenext
					loop
					rs7.close
					Response.write "" & vbcrlf & "                        </select>" & vbcrlf & "                            "
				end if
				if  rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then
					Response.write " <span class=""red"">*</span>"
				end if
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
				i_jm=i_jm+1
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function getExtendedDeal(TName,ord,repID)
		Call showExtendedDeal(TName,ord,3,1,1,repID)
	end function
	Function showExtendedDeal(TName,ord,columns,col1,col2,repID)
		dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7
		dim  num1, i_jm, j_jm, c_Value,colstr1,colstr2
		If col1>1 Then colstr1= " colspan='"&col1&"'"
		If col2>1 Then colstr2= " colspan='"&col2&"'"
		columns = 2
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from Copy_CustomFields where TName="&TName&" AND RepairOrder = "&repID&" "& KZ_LIMITID &" and FType<>5 and IsUsing=1 and del=1 order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if rs_kz_zdy.eof = False then
			Response.write("<tr>")
			do until rs_kz_zdy.eof
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr>")
					j_jm=j_jm+1
					Response.write("</tr><tr>")
				end if
				c_Value=""
				Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy("id")&" and OrderID="&ord&" ")
				If rs_kz_zdy_88.eof = False  Then c_Value=rs_kz_zdy_88("FValue")
				rs_kz_zdy_88.close
				Response.write "" & vbcrlf & "                     <td width=""11%"" align=""right"" "
				Response.write colstr1
				Response.write ">"
				Response.write rs_kz_zdy("FName")
				Response.write "：</td>" & vbcrlf & "                      <td width=""22%"" "
				if i_jm=num1-1  then
					Response.write "：</td>" & vbcrlf & "                      <td width=""22%"" "
					Response.write "colspan="""
					Response.write col2+(col1+col2)*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """ "
				else
					Response.write colstr2
				end if
				Response.write ">" & vbcrlf & "                    "
				if rs_kz_zdy("FType")="1" Then
					Response.write "" & vbcrlf & "                             <input name=""danh_"
					Response.write rs_kz_zdy("id")
					Response.write """ type=""text"" size=""15"" id=""danh_"
					Response.write rs_kz_zdy("id")
					Response.write """ value="""
					Response.write c_Value
					Response.write """ dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"" maxlength=""4000"">" & vbcrlf & "                            "
				Elseif rs_kz_zdy("FType")="2" then
					Response.write "" & vbcrlf & "                             <textarea name=""duoh_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""duoh_"
					Response.write rs_kz_zdy("id")
					Response.write """ style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px;padding-left:4px;"" onfocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" dataType=""Limit"" "
					Response.write rs_kz_zdy("id")
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write " max=""500""  msg=""必须在1到500个字符"">"
					Response.write c_Value
					Response.write "</textarea>" & vbcrlf & "                          "
				Elseif rs_kz_zdy("FType")="5" then
					Response.write "" & vbcrlf & "                             <textarea name=""beiz_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""beiz_"
					Response.write rs_kz_zdy("id")
					Response.write """ style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px;padding-left:4px;"" onfocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" dataType=""Limit"" "
					Response.write rs_kz_zdy("id")
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write " max=""4000""  msg=""必须在1到4000个字符"">"
					Response.write c_Value
					Response.write "</textarea>" & vbcrlf & "                          "
				elseif rs_kz_zdy("FType")="3" Then
					Response.write "" & vbcrlf & "                             <input readonly name=""date_"
					Response.write rs_kz_zdy("id")
					Response.write """ value="""
					Response.write c_Value
					Response.write """ size=""15"" id=""daysOfMonthPos"" onmouseup=""toggleDatePicker('daysOfMonth_"
					Response.write rs_kz_zdy("id")
					Response.write "','date_"
					Response.write rs_kz_zdy("id")
					Response.write "')"" dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:right;background-repeat:no-repeat;""> <div id=""daysOfMonth_"
					Response.write " min=""1"" "
					Response.write rs_kz_zdy("id")
					Response.write """ style=""POSITION:absolute""></div>" & vbcrlf & "                          "
				ElseIf rs_kz_zdy("FType")="4" then
					Response.write "" & vbcrlf & "                             <input name=""Numr_"
					Response.write rs_kz_zdy("id")
					Response.write """ type=""text"" value="""
					Response.write c_Value
					Response.write """ size=""15"" id=""Numr_"
					Response.write rs_kz_zdy("id")
					Response.write """ onkeyup=value=value.replace(/[^\d\.]/g,'') dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & "                  "
				ElseIf rs_kz_zdy("FType")="6" then
					Response.write "" & vbcrlf & "                             <select name=""IsNot_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""IsNot_"
					Response.write rs_kz_zdy("id")
					Response.write """  dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                           <option value=""是"" "
					If c_Value="是" then
						Response.write "selected"
					end if
					Response.write ">是</option>" & vbcrlf & "                         <option value=""否"" "
					If c_Value="否" then
						Response.write "selected"
					end if
					Response.write ">否</option>" & vbcrlf & "                         </select>" & vbcrlf & "                               "
				else
					Response.write "" & vbcrlf & "                             <select name=""meju_"
					Response.write rs_kz_zdy("id")
					Response.write """ id=""meju_"
					Response.write rs_kz_zdy("id")
					Response.write """  dataType=""Limit"" "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then
						Response.write " min=""1"" "
					end if
					Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                           "
					set rs7=conn.execute("select id,CValue from ERP_CustomOptions where CFID="&rs_kz_zdy("id")&" order by id asc ")
					do until rs7.eof
						Response.write "" & vbcrlf & "                                     <option value="""
						Response.write rs7("id")
						Response.write """ "
						If rs7("CValue")&""=c_Value&"" then
							Response.write "selected"
						end if
						Response.write ">"
						Response.write rs7("CValue")
						Response.write "</option>" & vbcrlf & "                                    "
						rs7.movenext
					loop
					rs7.close
					Response.write "" & vbcrlf & "                        </select>" & vbcrlf & "                            "
				end if
				if  rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then
					Response.write " <span class=""red"">*</span>"
				end if
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
				i_jm=i_jm+1
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   "
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function showExtendedBzDeal(TName,ord, repID,col1,col2)
		Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
		if TName=1001 or ord=-1 Then col2=3
'Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
		If col1>1 Then colstr1= " colspan='"&col1&"'"
		If col2>1 Then colstr2= " colspan='"&col2&"'"
		Set rs_kz_zdy_8=server.CreateObject("adodb.recordset")
		rs_kz_zdy_8.open "select * from Copy_CustomFields where IsUsing=1 and TName="&TName&" AND RepairOrder = "&repID&" "& KZ_LIMITID &" and FType='5' order by FOrder asc",conn,1,1
		If Not rs_kz_zdy_8.eof Then
			Do While Not rs_kz_zdy_8.eof
				If Len(rs_kz_zdy_8("FName")&"") > 0 then
					c_Value=""
					Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy_8("id")&" and OrderID="&ord&" ")
					If Not rs_kz_zdy_88.eof Then c_Value=rs_kz_zdy_88("FValue")
					rs_kz_zdy_88.close
					Response.write "" & vbcrlf & "                         <tr>" & vbcrlf & "                                    <td "
					Response.write colstr1
					Response.write "><div align=""right"">"
					If (rs_kz_zdy_8("MustFillin") Or Len(KZ_LIMITID&"")>0 ) And (rs_kz_zdy_8("FType")=1 Or rs_kz_zdy_8("FType")=2 Or rs_kz_zdy_8("FType")=4) then
						Response.write " &nbsp;<span class=""red"">*&nbsp;</span>"
					end if
					Response.write rs_kz_zdy_8("FName")
					Response.write "：</div></td>" & vbcrlf & "                                    <td "
					Response.write colstr2
					Response.write "><textarea name=""beiz_"
					Response.write rs_kz_zdy_8("id")
					Response.write """ id=""beiz_"
					Response.write rs_kz_zdy_8("id")
					Response.write """ dataType=""Limit""  " & vbcrlf & "                    "
					If Len(KZ_LIMITID&"")>0 Then
						Response.write "min=""1"""
					end if
					Response.write "" & vbcrlf & "                    max=""4000""  msg=""备注长度不能超过4000个字"" style=""display:none;"" cols=""1"" rows=""1"">"
					if c_Value<>"" then Response.write c_Value End if
					Response.write "</textarea>" & vbcrlf & "                              <IFRAME ID=""eWebEditor_"
					Response.write rs_kz_zdy_8("id")
					Response.write """ SRC=""../edit/ewebeditor.asp?id=beiz_"
					Response.write rs_kz_zdy_8("id")
					Response.write "&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""300"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME></td>" & vbcrlf & "                         </tr>" & vbcrlf & "                       "
				end if
				rs_kz_zdy_8.movenext
			loop
		end if
		rs_kz_zdy_8.close
		Set rs_kz_zdy_8=Nothing
	end function
	Function getExtended2(TName,ord,ly_str)
		columns=3
		if TName=1001 or ord=-1 Then columns=2
'columns=3
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 and FType<>'5' order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if Not rs_kz_zdy.eof then
			Response.write("<tr>")
			do until rs_kz_zdy.eof
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr>")
					j_jm=j_jm+1
				end if
				c_Value=""
				Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy("id")&" and OrderID="&ord&" ")
				If Not rs_kz_zdy_88.eof Then c_Value=rs_kz_zdy_88("FValue")
				rs_kz_zdy_88.close
				Response.write "<td width='11%' align='right'>"&rs_kz_zdy("FName")&"：</td><td width='22%' "
				if i_jm=num1-1  Then Response.write "colspan="&(1+2*(j_jm*columns-num1))&" "
				Response.write "<td width='11%' align='right'>"&rs_kz_zdy("FName")&"：</td><td width='22%' "
				Response.write ">"
				if rs_kz_zdy("FType")="1" Then
					Response.write "<input name='danh_"&rs_kz_zdy("id")&"' type='text' size='15' id='danh_"&rs_kz_zdy("id")&"' value='"&c_Value&"' dataType='Limit' "
					if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
					Response.write " max='500'  msg='必须在1到500个字符' maxlength='4000'>"
				Elseif rs_kz_zdy("FType")="2" Then
					Response.write "<textarea name='duoh_"&rs_kz_zdy("id")&"' id='duoh_"&rs_kz_zdy("id")&"' style='overflow-y:hidden;word-break:break-all;width:160px;height:22px;padding-left:4px;' onfocus='this.style.posHeight=this.scrollHeight' onpropertychange='this.style.posHeight=this.scrollHeight' dataType='Limit' "
'Elseif rs_kz_zdy("FType")="2" Then
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
					Response.write " max='500'  msg='必须在1到500个字符'>"&c_Value&"</textarea>"
				elseif rs_kz_zdy("FType")="3" Then
					Response.write "<input readonly name='date_"&rs_kz_zdy("id")&"' value='"&c_Value&"' size='15' id='daysOfMonthPos' onmouseup=""toggleDatePicker('daysOfMonth_"&rs_kz_zdy("id")&"','date_"&rs_kz_zdy("id")&"')"" dataType='Limit' "
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
					Response.write " max='500' msg='请选择日期' style='background-image:url(../images/datePicker.gif);background-position:right;background-repeat:no-repeat;'> <div id='daysOfMonth_"&rs_kz_zdy("id")&"' style='POSITION:absolute'></div>"
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
				ElseIf rs_kz_zdy("FType")="4" then
					Response.write "<input name='Numr_"&rs_kz_zdy("id")&"' type='text' value='"&c_Value&"' size='15' id='Numr_"&rs_kz_zdy("id")&"' onkeyup=value=value.replace(/[^\d\.]/g,'') dataType='Limit' "
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1'  "
					Response.write " max='500'  msg='必须在1到500个字符' >"
				ElseIf rs_kz_zdy("FType")="6" then
					Response.write "<select name='IsNot_"&rs_kz_zdy("id")&"' id='IsNot_"&rs_kz_zdy("id")&"'  dataType='Limit' "
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
					Response.write " max='500'  msg='必须在1到500个字符'>"
					Response.write "<option value='是' "
					If c_Value="是" Then Response.write " selected "
					Response.write ">是</option>"
					Response.write "<option value='否' "
					If c_Value="否" Then Response.write " selected "
					Response.write ">否</option>"
					Response.write "</select>"
				else
					Response.write "<select name='meju_"&rs_kz_zdy("id")&"' id='meju_"&rs_kz_zdy("id")&"'  dataType='Limit' "
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then Response.write " min='1' "
					Response.write " max='500'  msg='必须在1到500个字符'>"
					Response.write "<option value=''></option>"
					ly_sql=""
					If c_Value<>"" And ly_str&""<>"" Then ly_str=ly_str&","&c_Value
					If ly_str&""<>"" Then ly_sql=" and id in ("&ly_str&")"
					set rs7=conn.execute("select id,CValue from ERP_CustomOptions where CFID="&rs_kz_zdy("id")&" "&ly_sql&" order by id asc ")
					do until rs7.eof
						Response.write "<option value='"&rs7("id")&"' "
						If rs7("CValue")&""=c_Value&"" Then Response.write " selected "
						Response.write ">"&rs7("CValue")&"</option>"
						rs7.movenext
					loop
					rs7.close
					Response.write "</select>"
				end if
				if  (rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0) And (rs_kz_zdy("FType")=1 Or rs_kz_zdy("FType")=2 Or rs_kz_zdy("FType")=4)  Then Response.write " &nbsp;<span class='red'>*</span>"
				Response.write "</td>"
				i_jm=i_jm+1
				Response.write "</td>"
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function getExtended1(TName,ord)
		Call showExtended1(TName,ord,1,1,5)
	end function
	Function showExtended1(TName,ord,columns ,col1,col2)
		Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
		if TName=1001 or ord=-1 Then col2=3
'Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
		If col1>1 Then colstr1= " colspan='"&col1&"'"
		If col2>1 Then colstr2= " colspan='"&col2&"'"
		Set rs_kz_zdy_8=server.CreateObject("adodb.recordset")
		rs_kz_zdy_8.open "select * from ERP_CustomFields where IsUsing=1 and TName="&TName&" "& KZ_LIMITID &" and FType='5' order by FOrder asc",conn,1,1
		If Not rs_kz_zdy_8.eof Then
			Do While Not rs_kz_zdy_8.eof
				c_Value=""
				Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy_8("id")&" and OrderID="&ord&" ")
				If Not rs_kz_zdy_88.eof Then c_Value=rs_kz_zdy_88("FValue")
				rs_kz_zdy_88.close
				Response.write "" & vbcrlf & "                      <tr>" & vbcrlf & "                            <td width=""11%"" "
				Response.write colstr1
				Response.write "><div align=""right"">"
				If (rs_kz_zdy_8("MustFillin") Or Len(KZ_LIMITID&"")>0 ) And (rs_kz_zdy_8("FType")=1 Or rs_kz_zdy_8("FType")=2 Or rs_kz_zdy_8("FType")=4) then
					Response.write " &nbsp;<span class=""red"">*&nbsp;</span>"
				end if
				Response.write rs_kz_zdy_8("FName")
				Response.write "：</div></td>" & vbcrlf & "                         <td "
				Response.write colstr2
				Response.write "><textarea name=""beiz_"
				Response.write rs_kz_zdy_8("id")
				Response.write """ id=""beiz_"
				Response.write rs_kz_zdy_8("id")
				Response.write """ dataType=""Limit""  " & vbcrlf & "                "
				If Len(KZ_LIMITID&"")>0 Then
					Response.write "min=""1"""
				end if
				Response.write "" & vbcrlf & "                max=""4000""  msg=""备注长度不能超过4000个字"" style=""display:none;"" cols=""1"" rows=""1"">"
				if c_Value<>"" then Response.write c_Value End if
				Response.write "</textarea>" & vbcrlf & "                           <IFRAME ID=""eWebEditor_"
				Response.write rs_kz_zdy_8("id")
				Response.write """ SRC=""../edit/ewebeditor.asp?id=beiz_"
				Response.write rs_kz_zdy_8("id")
				Response.write "&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""300"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME></td>" & vbcrlf & "                     </tr>" & vbcrlf & "                   "
				rs_kz_zdy_8.movenext
			loop
		end if
		rs_kz_zdy_8.close
		Set rs_kz_zdy_8=Nothing
	end function
	Function showExtended3(TName,ord,columns ,col1,col2)
		Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
		if TName=1001 or ord=-1 Then col2=3
'Dim  rs_kz_zdy_8, rs_kz_zdy_88, c_Value,colstr1,colstr2
		If col1>1 Then colstr1= " colspan='"&col1&"'"
		If col2>1 Then colstr2= " colspan='"&col2&"'"
		Set rs_kz_zdy_8=server.CreateObject("adodb.recordset")
		rs_kz_zdy_8.open "select * from ERP_CustomFields where IsUsing=1 and TName="&TName&" "& KZ_LIMITID &" and FType='5' order by FOrder asc",conn,1,1
		If Not rs_kz_zdy_8.eof Then
			Do While Not rs_kz_zdy_8.eof
				c_Value=""
				Set rs_kz_zdy_88=conn.execute("select FValue from ERP_CustomValues where FieldsID="&rs_kz_zdy_8("id")&" and OrderID="&ord&" ")
				If Not rs_kz_zdy_88.eof Then c_Value=rs_kz_zdy_88("FValue")
				rs_kz_zdy_88.close
				Response.write "" & vbcrlf & "                     <tr>" & vbcrlf & "                            <td "
				Response.write colstr1
				Response.write "><div align=""right"">"
				If (rs_kz_zdy_8("MustFillin") Or Len(KZ_LIMITID&"")>0 ) And (rs_kz_zdy_8("FType")=1 Or rs_kz_zdy_8("FType")=2 Or rs_kz_zdy_8("FType")=4) then
					Response.write " &nbsp;<span class=""red"">*&nbsp;</span>"
				end if
				Response.write rs_kz_zdy_8("FName")
				Response.write "：</div></td>" & vbcrlf & "                                <td "
				Response.write colstr2
				Response.write "><textarea name=""beiz_"
				Response.write rs_kz_zdy_8("id")
				Response.write """ id=""beiz_"
				Response.write rs_kz_zdy_8("id")
				Response.write """ dataType=""Limit""  " & vbcrlf & "                "
				If Len(KZ_LIMITID&"")>0 Then
					Response.write "min=""1"""
				end if
				Response.write "" & vbcrlf & "                max=""4000""  msg=""备注长度不能超过4000个字"" style=""display:none;"" cols=""1"" rows=""1"">"
				if c_Value<>"" then Response.write c_Value End if
				Response.write "</textarea>" & vbcrlf & "                          <IFRAME ID=""eWebEditor_"
				Response.write rs_kz_zdy_8("id")
				Response.write """ SRC=""../edit/ewebeditor.asp?id=beiz_"
				Response.write rs_kz_zdy_8("id")
				Response.write "&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""300"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME></td>" & vbcrlf & "                     </tr>" & vbcrlf & "                   "
				rs_kz_zdy_8.movenext
			loop
		end if
		rs_kz_zdy_8.close
		Set rs_kz_zdy_8=Nothing
	end function
	Function saveExtended(TName,ord)
		Dim rs_kz_zdy, FValue, OID, sql, id, rs0, rs1
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select *,(select uitype from sys_sdk_BillFieldInfo m where m.billtype=16001 and m.dbname='ext' +cast(t.id as varchar(12)) ) as utype from ERP_CustomFields t where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 order by FOrder asc "
'set rs_kz_zdy=server.CreateObject("adodb.recordset")
		rs_kz_zdy.open sql,conn,1,1
		If not rs_kz_zdy.eof Then
			Do While Not rs_kz_zdy.eof
				id=rs_kz_zdy("id")
				if rs_kz_zdy("FType")="1" Then
					if rs_kz_zdy("utype")="54" then
						FValue=replace(Trim(request.Form("danh_"&id)),", ",",")
					else
						FValue=Trim(request.Form("danh_"&id))
					end if
				ElseIf rs_kz_zdy("FType")="2" then
					FValue=Trim(request.Form("duoh_"&id))
				ElseIf rs_kz_zdy("FType")="3" then
					FValue=Trim(request.Form("date_"&id))
				ElseIf rs_kz_zdy("FType")="4"  then
					FValue=Trim(request.Form("Numr_"&id))
				ElseIf rs_kz_zdy("FType")="5" then
					FValue=Trim(request.Form("beiz_"&id))
				ElseIf rs_kz_zdy("FType")="6" then
					FValue=Trim(request.Form("IsNot_"&id))
				else
					OID=Trim(request.Form("meju_"&id))
					If OID="" Then OID=0
					Set rs1=server.CreateObject("adodb.recordset")
					rs1.open "select CValue from ERP_CustomOptions where id="&OID,conn,1,1
					If rs1.eof Then
						FValue=""
					else
						FValue=rs1("CValue")
					end if
					rs1.close
					Set rs1=nothing
				end if
				Set rs0=server.CreateObject("adodb.recordset")
				rs0.open "select top 1 * from ERP_CustomValues where FieldsID="&id&" and OrderID="&ord&" ",conn,1,1
				If rs0.eof Then
					If FValue<>"" And not IsNull(FValue) Then
						conn.execute "insert into ERP_CustomValues(FieldsID,OrderID,FValue) values("&id&","&ord&",N'"&FValue&"')"
					end if
				else
					conn.execute "update ERP_CustomValues set FValue=N'"&FValue&"' where FieldsID="&id&" and OrderID="&ord&" "
				end if
				rs0.close
				Set rs0=nothing
				rs_kz_zdy.movenext
			loop
		end if
		rs_kz_zdy.close
		Set rs_kz_zdy=Nothing
	end function
	Function searchExtended(TName,col)
		Dim sqldate
		Dim rs_kz_zdy_2 : set rs_kz_zdy_2=server.CreateObject("adodb.recordset")
		Dim sql2 : sql2="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 and CanSearch=1 order by FOrder asc "
		Dim str33,id,danh_1,danh_2,Numr_1,Numr_2,beiz_1,beiz_2,IsNot_1,meju_1,duoh_1,duoh_2,date_1,date_2
		rs_kz_zdy_2.open sql2,conn,1,1
		if rs_kz_zdy_2.eof then
		else
			str33=""
			do until rs_kz_zdy_2.eof
				id=rs_kz_zdy_2("id")
				If rs_kz_zdy_2("FType")="1" Then
					danh_1=request("danh_"&id&"_1")
					danh_2=request("danh_"&id&"_2")
					str33=str33+"&danh_"&id&"_1="+danh_1
'danh_2=request("danh_"&id&"_2")
					str33=str33+"&danh_"&id&"_2="+danh_2
'danh_2=request("danh_"&id&"_2")
					If danh_2<>"" Then
						If danh_1=1 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& danh_2 &"%')"
'If danh_1=1 Then
						Elseif danh_1=2 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue not like '%"& danh_2 &"%')"
'Elseif danh_1=2 Then
						Elseif danh_1=3 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& danh_2 &"')"
'Elseif danh_1=3 Then
						Elseif danh_1=4 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue<>'"& danh_2 &"')"
'Elseif danh_1=4 Then
						Elseif danh_1=5 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '"& danh_2 &"%')"
'Elseif danh_1=5 Then
						Elseif danh_1=6 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& danh_2 &"')"
'Elseif danh_1=6 Then
						end if
					end if
				ElseIf rs_kz_zdy_2("FType")="2" Then
					duoh_1=request("duoh_"&id&"_1")
					duoh_2=request("duoh_"&id&"_2")
					str33=str33+"&duoh_"&id&"_1="+duoh_1
'duoh_2=request("duoh_"&id&"_2")
					str33=str33+"&duoh_"&id&"_2="+duoh_2
'duoh_2=request("duoh_"&id&"_2")
					If duoh_2<>"" Then
						If duoh_1=1 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& duoh_2 &"%')"
'If duoh_1=1 Then
						Elseif duoh_1=2 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue not like '%"& duoh_2 &"%')"
'Elseif duoh_1=2 Then
						Elseif duoh_1=3 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& duoh_2 &"')"
'Elseif duoh_1=3 Then
						Elseif duoh_1=4 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue<>'"& duoh_2 &"')"
'Elseif duoh_1=4 Then
						Elseif duoh_1=5 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '"& duoh_2 &"%')"
'Elseif duoh_1=5 Then
						Elseif duoh_1=6 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& duoh_2 &"')"
'Elseif duoh_1=6 Then
						end if
					end if
				ElseIf rs_kz_zdy_2("FType")="3" Then
					date_1=request("date_"&id&"_1")
					date_2=request("date_"&id&"_2")
					str33=str33+"&date_"&id&"_1="+date_1
'date_2=request("date_"&id&"_2")
					str33=str33+"&date_"&id&"_2="+date_2
'date_2=request("date_"&id&"_2")
					If date_1<>"" or date_2<>"" Then
						If date_1<>"" Then
							sqldate=" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime) end)>=cast('"& date_1 &"'as datetime)"
'If date_1<>"" Then
						end if
						If date_2<>"" Then
							sqldate=sqldate&" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime) end)<=cast('"& date_2 &"' as datetime)"
'If date_2<>"" Then
						end if
						str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&""&sqldate&")"
'If date_2<>"" Then
					end if
				ElseIf rs_kz_zdy_2("FType")="4" Then
					Numr_1=request("Numr_"&id&"_1")
					Numr_2=request("Numr_"&id&"_2")
					str33=str33+"&Numr_"&id&"_1="+Numr_1
'Numr_2=request("Numr_"&id&"_2")
					str33=str33+"&Numr_"&id&"_2="+Numr_2
'Numr_2=request("Numr_"&id&"_2")
					If Numr_2<>"" Then
						If Numr_1=1 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& Numr_2 &"%')"
'If Numr_1=1 Then
						Elseif Numr_1=2 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue not like '%"& Numr_2 &"%')"
'Elseif Numr_1=2 Then
						Elseif Numr_1=3 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& Numr_2 &"')"
'Elseif Numr_1=3 Then
						Elseif Numr_1=4 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue<>'"& Numr_2 &"')"
'Elseif Numr_1=4 Then
						Elseif Numr_1=5 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '"& Numr_2 &"%')"
'Elseif Numr_1=5 Then
						Elseif Numr_1=6 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& Numr_2 &"')"
'Elseif Numr_1=6 Then
						end if
					end if
				ElseIf rs_kz_zdy_2("FType")="5" Then
					beiz_1=request("beiz_"&id&"_1")
					beiz_2=request("beiz_"&id&"_2")
					str33=str33+"&beiz_"&id&"_1="+beiz_1
'beiz_2=request("beiz_"&id&"_2")
					str33=str33+"&beiz_"&id&"_2="+beiz_2
					beiz_2=request("beiz_"&id&"_2")
					If beiz_2<>"" Then
						If beiz_1=1 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& beiz_2 &"%')"
'If beiz_1=1 Then
						Elseif beiz_1=2 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue not like '%"& beiz_2 &"%')"
'Elseif beiz_1=2 Then
						Elseif beiz_1=3 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& beiz_2 &"')"
'Elseif beiz_1=3 Then
						Elseif beiz_1=4 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue<>'"& beiz_2 &"')"
'Elseif beiz_1=4 Then
						Elseif beiz_1=5 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '"& beiz_2 &"%')"
'Elseif beiz_1=5 Then
						Elseif beiz_1=6 Then
							str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& beiz_2 &"')"
'Elseif beiz_1=6 Then
						end if
					end if
				ElseIf rs_kz_zdy_2("FType")="6" Then
					IsNot_1=request("IsNot_"&id&"_1")
					str33=str33+"&IsNot_"&id&"_1="+IsNot_1
'IsNot_1=request("IsNot_"&id&"_1")
					If IsNot_1<>"" Then
						str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& IsNot_1 &"')"
'If IsNot_1<>"" Then
					end if
				else
					meju_1=request("meju_"&id&"_1")
					str33=str33+"&meju_"&id&"_1="+Server.Urlencode(meju_1)
'meju_1=request("meju_"&id&"_1")
					If meju_1<>"" Then
						str_Result=str_Result+" and "&col&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& meju_1 &"')"
'If meju_1<>"" Then
					end if
				end if
				rs_kz_zdy_2.movenext
			Loop
		end if
		rs_kz_zdy_2.close
		Set rs_kz_zdy_2=Nothing
		pub_cf=str33
	end function
	Function Show_Extended_By_Type(TName,typ,ord,columns)
		Dim rs_kz_zdy, rs_kz_zdy_88, num1, i_jm, j_jm, classNamezdy, c_Value,sql,showWhere
		if columns="" or columns=0 then
			columns=3
		else
			columns=cint(columns)
		end if
		if typ="" then
			typ=0
		end if
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from ERP_CustomFields where TName='"&TName&"' and IsUsing=1 and del = 1 and FType in("&typ&") order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if Not rs_kz_zdy.eof then
			do until rs_kz_zdy.eof
				classNamezdy=""
				If rs_kz_zdy("FType")=5 Then classNamezdy="ywcss2"
				If i_jm=0 Then Response.write("<tr class='"&classNamezdy&"'>")
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr class='"&classNamezdy&"'>")
					j_jm=j_jm+1
					Response.write("</tr><tr class='"&classNamezdy&"'>")
				end if
				Set rs_kz_zdy_88=server.CreateObject("adodb.recordset")
				rs_kz_zdy_88.open "select case when b.ftype=3 and isnull(FValue,'')<>'' then convert(varchar(10),isnull(FValue,''),120) else isnull(FValue,'') end FValue from ERP_CustomValues a inner join ERP_CustomFields b on a.fieldsid = b.id where a.FieldsID='"&rs_kz_zdy("id")&"' and a.OrderID='"&ord&"' ",conn,1,1
				If Not rs_kz_zdy_88.eof Then
					c_Value=rs_kz_zdy_88("FValue")
					if rs_kz_zdy("FType")=2 then
						c_Value=replace(c_Value&"",Chr(13)&Chr(10),"<br>")
					end if
				else
					c_Value=""
				end if
				rs_kz_zdy_88.close
				Set rs_kz_zdy_88=nothing
				Response.write "" & vbcrlf & "                     <td align=""right"" height=""25"">"
				Response.write rs_kz_zdy("FName")
				Response.write "：</td>" & vbcrlf & "                      <td "
				if i_jm=num1-1  then
					Response.write "：</td>" & vbcrlf & "                      <td "
					Response.write "colspan="""
					Response.write 1+2*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """"
				end if
				Response.write " class=""gray ewebeditorImg"">&nbsp;"
				Response.write c_Value
				Response.write "</td>" & vbcrlf & "                        "
				i_jm=i_jm+1
				Response.write "</td>" & vbcrlf & "                        "
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function Show_Extended_By_TypeDeal(TName,typ,ord,columns,repID)
		Dim rs_kz_zdy, rs_kz_zdy_88, num1, i_jm, j_jm, classNamezdy, c_Value,sql,showWhere
		if columns="" or columns=0 then
			columns=3
		else
			columns=cint(columns)
		end if
		if typ="" then
			typ=0
		end if
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from Copy_CustomFields where TName='"&TName&"' AND RepairOrder = "&repID&" and IsUsing=1 and del = 1 and FType in("&typ&") order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if Not rs_kz_zdy.eof then
			do until rs_kz_zdy.eof
				classNamezdy=""
				If rs_kz_zdy("FType")=5 Then classNamezdy="ywcss2"
				If i_jm=0 Then Response.write("<tr class='"&classNamezdy&"'>")
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr class='"&classNamezdy&"'>")
					j_jm=j_jm+1
					Response.write("</tr><tr class='"&classNamezdy&"'>")
				end if
				Set rs_kz_zdy_88=server.CreateObject("adodb.recordset")
				rs_kz_zdy_88.open "select isnull(FValue,'') FValue from ERP_CustomValues where FieldsID='"&rs_kz_zdy("id")&"' and OrderID='"&ord&"' ",conn,1,1
				If Not rs_kz_zdy_88.eof Then
					c_Value=rs_kz_zdy_88("FValue")
					if rs_kz_zdy("FType")=2 then
						c_Value=replace(c_Value&"",Chr(13)&Chr(10),"<br>")
					end if
				else
					c_Value=""
				end if
				rs_kz_zdy_88.close
				Set rs_kz_zdy_88=nothing
				Response.write "" & vbcrlf & "                     <td align=""right"" height=""25"">"
				Response.write rs_kz_zdy("FName")
				Response.write "：</td>" & vbcrlf & "                      <td "
				if i_jm=num1-1  then
					Response.write "：</td>" & vbcrlf & "                      <td "
					Response.write "colspan="""
					Response.write 1+2*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """"
				end if
				Response.write " class=""gray ewebeditorImg"">"
				Response.write c_Value
				Response.write "&nbsp;</td>" & vbcrlf & "                  "
				i_jm=i_jm+1
				Response.write "&nbsp;</td>" & vbcrlf & "                  "
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function Show_Extended_By_TypeDealBZ(TName,typ,ord,columns,repID)
		Dim rs_kz_zdy, rs_kz_zdy_88, num1, i_jm, j_jm, classNamezdy, c_Value,sql,showWhere
		if columns="" or columns=0 then
			columns=3
		else
			columns=cint(columns)
		end if
		if typ="" then
			typ=0
		end if
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from Copy_CustomFields where TName='"&TName&"' AND RepairOrder = "&repID&" and IsUsing=1 and del = 1 and FType in("&typ&") order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if Not rs_kz_zdy.eof then
			do until rs_kz_zdy.eof
				classNamezdy=""
				If rs_kz_zdy("FType")=5 Then classNamezdy="ywcss2"
				Response.write("<tr class='"&classNamezdy&"'>")
				Set rs_kz_zdy_88=server.CreateObject("adodb.recordset")
				rs_kz_zdy_88.open "select isnull(FValue,'') FValue from ERP_CustomValues where FieldsID='"&rs_kz_zdy("id")&"' and OrderID='"&ord&"' ",conn,1,1
				If Not rs_kz_zdy_88.eof Then
					c_Value=rs_kz_zdy_88("FValue")
					if rs_kz_zdy("FType")=2 then
						c_Value=replace(c_Value&"",Chr(13)&Chr(10),"<br>")
					end if
				else
					c_Value=""
				end if
				rs_kz_zdy_88.close
				Set rs_kz_zdy_88=nothing
				Response.write "" & vbcrlf & "                     <td align=""right"" height=""25"">"
				Response.write rs_kz_zdy("FName")
				Response.write "：</td>" & vbcrlf & "                        <td colspan="""
				Response.write columns
				Response.write """ class=""gray ewebeditorImg"">"
				Response.write c_Value
				Response.write "&nbsp;</td>" & vbcrlf & "                    "
				i_jm=i_jm+1
				Response.write "&nbsp;</td>" & vbcrlf & "                    "
				Response.write("</tr>")
				rs_kz_zdy.movenext
			loop
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function Show_Extended_By_Type2(TName,typ,ord,columns,sort1,filed1)
		Dim rs_kz_zdy, rs_kz_zdy_88, num1, i_jm, j_jm, classNamezdy, c_Value, FVID
		if columns="" or columns=0 then
			columns=3
		else
			columns=cint(columns)
		end if
		if typ="" then
			typ=0
		end if
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		sql="select * from ERP_CustomFields where TName='"&TName&"' and IsUsing=1 and del=1 and FType in("&typ&") order by FOrder asc "
		rs_kz_zdy.open sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if Not rs_kz_zdy.eof then
			do until rs_kz_zdy.eof
				classNamezdy=""
				If rs_kz_zdy("FType")=5 Then classNamezdy="ywcss2"
				If i_jm=0 Then Response.write("<tr class='"&classNamezdy&"'>")
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr class='"&classNamezdy&"'>")
					j_jm=j_jm+1
					Response.write("</tr><tr class='"&classNamezdy&"'>")
				end if
				Set rs_kz_zdy_88=server.CreateObject("adodb.recordset")
				rs_kz_zdy_88.open "select isnull(FValue,'') FValue,id from ERP_CustomValues where FieldsID='"&rs_kz_zdy("id")&"' and OrderID='"&ord&"' ",conn,1,1
				If Not rs_kz_zdy_88.eof Then
					c_Value=rs_kz_zdy_88("FValue")
					FVID = rs_kz_zdy_88("id")
					if rs_kz_zdy("FType")=2 then
						c_Value=replace(c_Value&"",Chr(13)&Chr(10),"<br>")
					end if
				else
					c_Value=""
				end if
				rs_kz_zdy_88.close
				Set rs_kz_zdy_88=Nothing
				If FVID&"" = "" Then FVID=0
				Response.write "" & vbcrlf & "                      <td align=""right"" height=""25"">"
				Response.write rs_kz_zdy("FName")
				Response.write "：</td>" & vbcrlf & "                       <td "
				if i_jm=num1-1  then
					Response.write "：</td>" & vbcrlf & "                       <td "
					Response.write "colspan="""
					Response.write 1+2*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """"
				end if
				Response.write " class=""gray ewebeditorImg"">"
				If rs_kz_zdy("FType")=5 Then
					If c_Value&""<>"" Then
						Dim arr_img
						arr_img = split(c_Value,"<img",-1,1)
'Dim arr_img
						if ubound(arr_img)>0 then
							Response.write "" & vbcrlf & "                                              <a href=""javascript:;"" onClick=""window.open('info.asp?ord="
							Response.write app.base64.pwurl(FVID)
							Response.write "&sort1="
							Response.write sort1
							Response.write "&sort2="
							Response.write filed1
							Response.write "','neww6768999in','width=' + 1600 + ',height=' + 800 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=0,top=150');return false;"" onMouseOver=""window.status='none';return true;"" title=""放大查看"">"
							Response.write filed1
							Response.write c_Value
							Response.write "</a>" & vbcrlf & "                           "
						else
							Response.write(c_Value)
						end if
					end if
				else
					Response.write c_Value
				end if
				Response.write "&nbsp;</td>" & vbcrlf & "                   "
				i_jm=i_jm+1
				Response.write "&nbsp;</td>" & vbcrlf & "                   "
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function Del_Extended_Value(TName,ord)
		if ord="" Then ord=0
		sql="delete from ERP_CustomValues where id in(select b.id from ERP_CustomFields  a " _
		& " left join ERP_CustomValues b on a.id=b.fieldsid " _
		& " where a.tname='"&TName&"' and b.orderid in("&ord&")) "
		conn.execute(sql)
	end function
	Function Show_Search_Extended(TName)
		set rs_kz_zdy_2=server.CreateObject("adodb.recordset")
		sql2="select * from ERP_CustomFields where TName='"&TName&"' and IsUsing=1 and del=1 and CanSearch=1 order by FOrder asc "
		rs_kz_zdy_2.open sql2,conn,1,1
		if rs_kz_zdy_2.eof then
		else
			do until rs_kz_zdy_2.eof
				Response.write "" & vbcrlf & "                     <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td align=""right"">"
				Response.write rs_kz_zdy_2("FName")
				Response.write "：</td>" & vbcrlf & "                      <td align=""left"">" & vbcrlf & "                 "
				If rs_kz_zdy_2("FType")="1" then
					Response.write "" & vbcrlf & "                             <select name=""danh_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"">" & vbcrlf & "                              <option value=""1"">包含</option>" & vbcrlf & "                           <option value=""2"">不包含</option>" & vbcrlf & "                         <option value=""3"">等于</option>" & vbcrlf & "                           <option value=""4"">不等于</option>" & vbcrlf & "                         <option value=""5"">以..开始</option>" & vbcrlf & "                               <option value=""6"">以..结束</option>" & vbcrlf & "                             </select>" & vbcrlf & "                               <input name=""danh_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_2"" type=""text"" size=""15"">" & vbcrlf & "                            "
				ElseIf rs_kz_zdy_2("FType")="2" Then
					Response.write "" & vbcrlf & "                             <select name=""duoh_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"">" & vbcrlf & "                              <option value=""1"">包含</option>" & vbcrlf & "                           <option value=""2"">不包含</option>" & vbcrlf & "                         <option value=""3"">等于</option>" & vbcrlf & "                           <option value=""4"">不等于</option>" & vbcrlf & "                         <option value=""5"">以..开始</option>" & vbcrlf & "                               <option value=""6"">以..结束</option>" & vbcrlf & "                             </select>" & vbcrlf & "                               <input name=""duoh_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_2"" type=""text"" size=""15"">" & vbcrlf & "                            "
				ElseIf rs_kz_zdy_2("FType")="3" then
					Response.write "" & vbcrlf & "                             <INPUT name=""date_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"" size=""11""  id=""date_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"" onmouseup=toggleDatePicker(""paydate1div_"
					Response.write rs_kz_zdy_2("id")
					Response.write """,""date.date_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"")><DIV id=""paydate1div_"
					Response.write rs_kz_zdy_2("id")
					Response.write """ style=""POSITION: absolute"" name =""paydate1div_"
					Response.write rs_kz_zdy_2("id")
					Response.write """></DIV>&nbsp;-&nbsp;<INPUT name=""date_"
					Response.write rs_kz_zdy_2("id")
					Response.write rs_kz_zdy_2("id")
					Response.write "_2"" size=""11"" id=""date_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_2"" onmouseup=toggleDatePicker(""paydate2div_"
					Response.write rs_kz_zdy_2("id")
					Response.write """,""date.date_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_2"")><DIV id=""paydate2div_"
					Response.write rs_kz_zdy_2("id")
					Response.write """ style=""POSITION: absolute"" name =""paydate2div_"
					Response.write rs_kz_zdy_2("id")
					Response.write """></DIV>" & vbcrlf & "                          "
				ElseIf rs_kz_zdy_2("FType")="4" then
					Response.write "" & vbcrlf & "                             <select name=""Numr_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"">" & vbcrlf & "                              <option value=""1"">包含</option>" & vbcrlf & "                           <option value=""2"">不包含</option>" & vbcrlf & "                         <option value=""3"">等于</option>" & vbcrlf & "                           <option value=""4"">不等于</option>" & vbcrlf & "                         <option value=""5"">以..开始</option>" & vbcrlf & "                               <option value=""6"">以..结束</option>" & vbcrlf & "                             </select>" & vbcrlf & "                               <input name=""Numr_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_2"" type=""text"" size=""15"">" & vbcrlf & "                            "
				ElseIf rs_kz_zdy_2("FType")="5" then
					Response.write "" & vbcrlf & "                             <select name=""beiz_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"">" & vbcrlf & "                              <option value=""1"">包含</option>" & vbcrlf & "                           <option value=""2"">不包含</option>" & vbcrlf & "                         <option value=""3"">等于</option>" & vbcrlf & "                           <option value=""4"">不等于</option>" & vbcrlf & "                         <option value=""5"">以..开始</option>" & vbcrlf & "                               <option value=""6"">以..结束</option>" & vbcrlf & "                             </select>" & vbcrlf & "                               <input name=""beiz_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_2"" type=""text"" size=""15"">" & vbcrlf & "                            "
				ElseIf rs_kz_zdy_2("FType")="6" then
					Response.write "" & vbcrlf & "                             <select name=""IsNot_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"">" & vbcrlf & "                              <option value="""">选择</option>" & vbcrlf & "                            <option value=""是"">是</option>" & vbcrlf & "                            <option value=""否"">否</option>" & vbcrlf & "                            </select>" & vbcrlf & "                               "
				else
					Response.write "" & vbcrlf & "                             <select name=""meju_"
					Response.write rs_kz_zdy_2("id")
					Response.write "_1"">" & vbcrlf & "                              <option value="""">选择</option>" & vbcrlf & "                            "
					Set rs_kz_zdy_8=server.CreateObject("adodb.recordset")
					rs_kz_zdy_8.open "select * from ERP_CustomOptions where CFID="&rs_kz_zdy_2("id")&" ",conn,1,1
					If Not rs_kz_zdy_8.eof Then
						Do While Not rs_kz_zdy_8.eof
							Response.write "" & vbcrlf & "                                             <option value="""
							Response.write rs_kz_zdy_8("CValue")
							Response.write """>"
							Response.write rs_kz_zdy_8("CValue")
							Response.write "</option>" & vbcrlf & "                                            "
							rs_kz_zdy_8.movenext
						Loop
					end if
					rs_kz_zdy_8.close
					Set rs_kz_zdy_8=nothing
					Response.write "" & vbcrlf & "                             </select>" & vbcrlf & "                               "
				end if
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
				rs_kz_zdy_2.movenext
			loop
		end if
		rs_kz_zdy_2.close
		set rs_kz_zdy_2=Nothing
	end function
	Function Show_Search_Extended_Simple(TName)
		set rs_kz_zdy_2=server.CreateObject("adodb.recordset")
		sql2="select * from ERP_CustomFields where TName='"&TName&"' and IsUsing=1 and del=1 and CanSearch=1 order by FOrder asc "
		rs_kz_zdy_2.open sql2,conn,1,1
		if rs_kz_zdy_2.eof =False then
			do until rs_kz_zdy_2.eof
				Response.write "" & vbcrlf & "                     <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                   <td align=""right"">"
				Response.write rs_kz_zdy_2("FName")
				Response.write "：</td>" & vbcrlf & "                      <td align=""left"">" & vbcrlf & "                 "
				Select Case rs_kz_zdy_2("FType")
				Case "1" :
				Response.write "" & vbcrlf & "                             <input name=""danh_"
				Response.write rs_kz_zdy_2("id")
				Response.write """ type=""text"" size=""15"">" & vbcrlf & "                              "
				Case "2" :
				Response.write "" & vbcrlf & "                             <input name=""duoh_"
				Response.write rs_kz_zdy_2("id")
				Response.write """ type=""text"" size=""15"">" & vbcrlf & "                              "
				Case "3" :
				Response.write "" & vbcrlf & "                             <INPUT name=""date_"
				Response.write rs_kz_zdy_2("id")
				Response.write "_1"" size=""11""  id=""date_"
				Response.write rs_kz_zdy_2("id")
				Response.write "_1"" onmouseup=toggleDatePicker(""paydate1div_"
				Response.write rs_kz_zdy_2("id")
				Response.write """,""date.date_"
				Response.write rs_kz_zdy_2("id")
				Response.write "_1"")><DIV id=""paydate1div_"
				Response.write rs_kz_zdy_2("id")
				Response.write """ style=""POSITION: absolute"" name =""paydate1div_"
				Response.write rs_kz_zdy_2("id")
				Response.write """></DIV>&nbsp;-&nbsp;<INPUT name=""date_"
				Response.write rs_kz_zdy_2("id")
				Response.write rs_kz_zdy_2("id")
				Response.write "_2"" size=""11"" id=""date_"
				Response.write rs_kz_zdy_2("id")
				Response.write "_2"" onmouseup=toggleDatePicker(""paydate2div_"
				Response.write rs_kz_zdy_2("id")
				Response.write """,""date.date_"
				Response.write rs_kz_zdy_2("id")
				Response.write "_2"")><DIV id=""paydate2div_"
				Response.write rs_kz_zdy_2("id")
				Response.write """ style=""POSITION: absolute"" name =""paydate2div_"
				Response.write rs_kz_zdy_2("id")
				Response.write """></DIV>" & vbcrlf & "                          "
				Case "4" :
				Response.write "" & vbcrlf & "                             <input name=""Numr_"
				Response.write rs_kz_zdy_2("id")
				Response.write """ type=""text"" size=""15"">" & vbcrlf & "                              "
				Case "5" :
				Response.write "" & vbcrlf & "                             <input name=""beiz_"
				Response.write rs_kz_zdy_2("id")
				Response.write """ type=""text"" size=""15"">" & vbcrlf & "                              "
				Case "6" :
				Response.write "" & vbcrlf & "                             <select name=""IsNot_"
				Response.write rs_kz_zdy_2("id")
				Response.write """>" & vbcrlf & "                                <option value="""">选择</option>" & vbcrlf & "                            <option value=""是"">是</option>" & vbcrlf & "                            <option value=""否"">否</option>" & vbcrlf & "                            </select>" & vbcrlf & "                               "
				Case Else
				Response.write "" & vbcrlf & "                             <select name=""meju_"
				Response.write rs_kz_zdy_2("id")
				Response.write """>" & vbcrlf & "                                <option value="""">选择</option>" & vbcrlf & "                            "
				Set rs_kz_zdy_8=server.CreateObject("adodb.recordset")
				rs_kz_zdy_8.open "select * from ERP_CustomOptions where CFID="&rs_kz_zdy_2("id")&" ",conn,1,1
				If Not rs_kz_zdy_8.eof Then
					Do While Not rs_kz_zdy_8.eof
						Response.write "" & vbcrlf & "                                             <option value="""
						Response.write rs_kz_zdy_8("CValue")
						Response.write """>"
						Response.write rs_kz_zdy_8("CValue")
						Response.write "</option>" & vbcrlf & "                                            "
						rs_kz_zdy_8.movenext
					Loop
				end if
				rs_kz_zdy_8.close
				Set rs_kz_zdy_8=nothing
				Response.write "" & vbcrlf & "                             </select>" & vbcrlf & "                               "
				End Select
				Response.write "" & vbcrlf & "                     </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
				rs_kz_zdy_2.movenext
			loop
		end if
		rs_kz_zdy_2.close
		set rs_kz_zdy_2=Nothing
	end function
	Function searchExtended_Simple(TName,keycode)
		Dim rs_kz_zdy_2 ,searchsql
		set rs_kz_zdy_2=server.CreateObject("adodb.recordset")
		Dim sql2 : sql2="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 and CanSearch=1 order by FOrder asc "
		Dim str33,id,danh,Numr,beiz,IsNot_1,meju,duoh,date_1,date_2
		rs_kz_zdy_2.open sql2,conn,1,1
		if rs_kz_zdy_2.eof=False then
			str33=""
			do until rs_kz_zdy_2.eof
				id=rs_kz_zdy_2("id")
				Select Case rs_kz_zdy_2("FType")
				Case "1" :
				danh=request("danh_"&id&"")
				str33=str33+"&danh_"&id&"="+danh
'danh=request("danh_"&id&"")
				If danh<>"" Then
					searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& danh &"%')"
'If danh<>"" Then
				end if
				Case "2" :
				duoh=request("duoh_"&id&"")
				str33=str33+"&duoh_"&id&"="+duoh
'duoh=request("duoh_"&id&"")
				If duoh<>"" Then
					searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& duoh &"%')"
'If duoh<>"" Then
				end if
				Case "3" :
				date_1=request("date_"&id&"_1")
				date_2=request("date_"&id&"_2")
				str33=str33+"&date_"&id&"_1="+date_1
'date_2=request("date_"&id&"_2")
				str33=str33+"&date_"&id&"_2="+date_2
'date_2=request("date_"&id&"_2")
				If date_1<>"" or date_2<>"" Then
					Dim sqldate
					If date_1<>"" Then
						sqldate=" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime) end)>=cast('"& date_1 &"'as datetime)"
'If date_1<>"" Then
					end if
					If date_2<>"" Then
						sqldate=sqldate&" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime) end)<=cast('"& date_2 &"' as datetime)"
'If date_2<>"" Then
					end if
					searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" "&sqldate&")"
'If date_2<>"" Then
				end if
				Case "4" :
				Numr=request("Numr_"&id&"")
				str33=str33+"&Numr_"&id&"="+Numr
'Numr=request("Numr_"&id&"")
				If Numr<>"" Then
					searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& Numr &"%')"
'If Numr<>"" Then
				end if
				Case "5" :
				beiz=request("beiz_"&id&"")
				str33=str33+"&beiz_"&id&"="+beiz
'beiz=request("beiz_"&id&"")
				If beiz<>"" Then
					searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& beiz &"%')"
'If beiz<>"" Then
				end if
				Case "6" :
				IsNot_1=request("IsNot_"&id&"")
				str33=str33+"&IsNot_"&id&"_1="+IsNot_1
'IsNot_1=request("IsNot_"&id&"")
				If IsNot_1<>"" Then
					searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& IsNot_1 &"')"
'If IsNot_1<>"" Then
				end if
				Case Else
				meju=request("meju_"&id&"")
				str33=str33+"&meju_"&id&"="+Server.Urlencode(meju)
'meju=request("meju_"&id&"")
				If meju<>"" Then
					searchsql=searchsql+" and "&keycode&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& meju &"')"
'If meju<>"" Then
				end if
				End Select
				rs_kz_zdy_2.movenext
			Loop
		end if
		rs_kz_zdy_2.close
		Set rs_kz_zdy_2=Nothing
		pub_cf=str33
		searchExtended_Simple=searchsql
	end function
	Sub Export_xls_Extended(TName,typ,cols,columns,ord)
		IF typ=1 then
			set rs_kz_zdy=server.CreateObject("adodb.recordset")
			kz_sql="select 1 from erp_customFields  where TName='"&TName&"'  and IsUsing=1 and del=1 and canExport=1 order by FOrder asc"
			rs_kz_zdy.open kz_sql,conn,1,1
			do while not rs_kz_zdy.eof
				xlApplication.ActiveSheet.columns(columns).columnWidth=15
				xlApplication.ActiveSheet.columns(columns).HorizontalAlignment=3
				rs_kz_zdy.movenext
				columns=columns+1
'rs_kz_zdy.movenext
			loop
			rs_kz_zdy.close
			set rs_kz_zdy=nothing
		ElseIf typ=2 then
			set rs_kz_zdy=server.CreateObject("adodb.recordset")
			kz_sql="select FName from erp_customFields  where TName='"&TName&"' and IsUsing=1 and del=1 and canExport=1 order by FOrder asc"
			rs_kz_zdy.open kz_sql,conn,1,1
			do while not rs_kz_zdy.eof
				xlWorksheet.Cells(1,columns).Value = rs_kz_zdy("FName")
				xlWorksheet.Cells(1,columns).font.Size=10
				xlWorksheet.Cells(1,columns).font.bold=true
				rs_kz_zdy.movenext
				columns=columns+1
				rs_kz_zdy.movenext
			loop
			rs_kz_zdy.close
			set rs_kz_zdy =nothing
		ElseIf typ=3 then
			set rs_kz_zdy=server.CreateObject("adodb.recordset")
			kz_sql="select b.FValue from erp_customFields a left join (select fieldsid,fvalue,orderid from erp_customValues where orderid='"&ord&"') b " _
			& " on b.fieldsid=a.id where a.TName='"&TName&"' and a.IsUsing=1 and a.canExport=1 order by a.FOrder asc"
			rs_kz_zdy.open kz_sql,conn,1,1
			do while not rs_kz_zdy.eof
				xlWorksheet.Cells(1+cols,columns).Value = rs_kz_zdy("FValue")
'do while not rs_kz_zdy.eof
				xlWorksheet.Cells(1+cols,columns).font.Size=10
'do while not rs_kz_zdy.eof
				rs_kz_zdy.movenext
				columns=columns+1
				rs_kz_zdy.movenext
			loop
			rs_kz_zdy.close
			set rs_kz_zdy=nothing
		end if
	end sub
	Function dyExtended(TName,columns)
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		kz_sql="select * from ERP_CustomFields where TName="&TName&" and IsUsing=1 and del=1 order by FOrder asc "
		rs_kz_zdy.open kz_sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if rs_kz_zdy.eof then
		else
			Response.write("<table width='100%' border='0' cellpadding='0' cellspacing='0' id='content2' bgcolor='#000000'>")
			Response.write("<tr>")
			do until rs_kz_zdy.eof
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr>")
					j_jm=j_jm+1
					Response.write("</tr><tr>")
				end if
				Response.write "" & vbcrlf & "                     <td width=""42%"" height=""27"" "
				if i_jm=num1-1  then
					Response.write "" & vbcrlf & "                     <td width=""42%"" height=""27"" "
					Response.write "colspan="""
					Response.write 1+2*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """"
				end if
				Response.write ">" & vbcrlf & "                            {"
				Response.write rs_kz_zdy("fname")
				Response.write ":<span title=""点击复制"
				Response.write rs_kz_zdy("fname")
				Response.write """ id=""zdy"
				Response.write rs_kz_zdy("id")
				Response.write """ onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_"
				Response.write rs_kz_zdy("id")
				Response.write "_E</span>}" & vbcrlf & "                   " & vbcrlf & "                        </td>" & vbcrlf & "                   "
				i_jm=i_jm+1
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
			Response.write("</table>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function dyMxExtended(TName,columns)
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		If TName = 28 Then
			kz_sql="select a.id,a.fname,b.sort1 from ERP_CustomFields a inner join sortonehy b on b.ord+200000 = a.tname and b.gate2=3001 and b.del=1 and b.isStop = 0 and a.FType<>'5' and a.id>0 ORDER BY FOrder asc,a.id "
'If TName = 28 Then
		else
			kz_sql="select * from ERP_CustomFields where TName="&TName&" and IsUsing=1 and del=1 order by FOrder asc "
		end if
		rs_kz_zdy.open kz_sql,conn,1,1
		num1=rs_kz_zdy.RecordCount
		i_jm=0
		j_jm=1
		if rs_kz_zdy.eof then
		else
			Response.write("<table width='100%' border='0' cellpadding='0' cellspacing='0' id='content2' bgcolor='#000000'>")
			Response.write("<tr>")
			do until rs_kz_zdy.eof
				if clng(i_jm/columns)=i_jm/columns and i_jm<>0 then
					Response.write("</tr><tr>")
					j_jm=j_jm+1
					Response.write("</tr><tr>")
				end if
				Response.write "" & vbcrlf & "                     <td width=""42%"" height=""27"" "
				if i_jm=num1-1  then
					Response.write "" & vbcrlf & "                     <td width=""42%"" height=""27"" "
					Response.write "colspan="""
					Response.write 1+2*(j_jm*columns-num1)
					Response.write "colspan="""
					Response.write """"
				end if
				Response.write ">" & vbcrlf & "                            {"
				Response.write rs_kz_zdy("fname")
				Response.write "["
				Response.write rs_kz_zdy("sort1")
				Response.write "]：<span title=""点击复制"
				Response.write rs_kz_zdy("fname")
				Response.write """ id=""zdy"
				Response.write rs_kz_zdy("id")
				Response.write """ onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">Extended_"
				Response.write rs_kz_zdy("id")
				Response.write "_E</span>}" & vbcrlf & "                   " & vbcrlf & "                        </td>" & vbcrlf & "                   "
				i_jm=i_jm+1
				rs_kz_zdy.movenext
			loop
			Response.write("</tr>")
			Response.write("</table>")
		end if
		rs_kz_zdy.close
		set rs_kz_zdy=nothing
	end function
	Function dyExtended_kz(TName,columns)
		Response.write "" & vbcrlf & "     <table width='100%' border='0' cellpadding='4' cellspacing='1' id='content2' bgcolor='#C0CCDD'>" & vbcrlf & "         <tr class=top><td colspan="""
		Response.write columns
		Response.write """><strong>【公共字段】</strong></td></tr>" & vbcrlf & "         <td width=""33%"" height=""27"">{税号:<span title=""点击复制税号"" id=""zdy_taxno"" onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_taxno_E</span>}</td>" & vbcrlf & "           "
		If columns = 1 Then Response.write "</tr><tr>"
		Response.write "" & vbcrlf & "             <td width=""33%"" height=""27"">{公司地址:<span title=""点击复制公司地址"" id=""zdy_addr"" onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_addr_E</span>}</td>" & vbcrlf & "             "
		If 2 mod columns = 0 Then Response.write "</tr><tr>"
		Response.write "" & vbcrlf & "             <td width=""33%"" height=""27"">{公司电话:<span title=""点击复制公司电话"" id=""zdy_phone"" onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_phone_E</span>}</td>" & vbcrlf & "           "
		If 3 mod columns = 0 Then Response.write "</tr><tr>"
		Response.write "" & vbcrlf & "             <td width=""33%"" height=""27"">{开户行:<span title=""点击复制开户行"" id=""zdy_bank"" onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_bank_E</span>}</td>" & vbcrlf & "         "
		If 4 mod columns = 0 Then Response.write "</tr><tr>"
		Response.write "" & vbcrlf & "             <td width=""33%"" height=""27"">{开户行账号:<span title=""点击复制开户行账号"" id=""zdy_account"" onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_account_E</span>}</td>" & vbcrlf & "           "
		If 5 mod columns = 0 Then
			Response.write "</tr>"
		else
			Response.write "<td colspan="&(columns-(5 mod columns))&"></td></tr>"
			Response.write "</tr>"
		end if
		Set rs =conn.execute("select ord,sort1 from sortonehy where gate2="&TName&" and isnull(id1,0)=0")
		If rs.eof= False Then
			While rs.eof = False
				set rs_kz_zdy=server.CreateObject("adodb.recordset")
				kz_sql="select * from ERP_CustomFields where TName="&(rs("ord")*1+100000)&" and IsUsing=1 and del=1 order by FOrder asc "
'set rs_kz_zdy=server.CreateObject("adodb.recordset")
				rs_kz_zdy.open kz_sql,conn,1,1
				if rs_kz_zdy.eof= False Then
					Response.write "<tr class=top><td colspan="""
					Response.write columns
					Response.write """><strong>【"
					Response.write rs("sort1")
					Response.write "】</strong></td></tr>"
					num1 = 0
					do until rs_kz_zdy.eof
						If num1 Mod columns = 0 Then Response.write "<tr>"
						Response.write "" & vbcrlf & "                                              <td width=""33%"" height=""27"">" & vbcrlf & "                                                        {"
						Response.write rs_kz_zdy("fname")
						Response.write ":<span title=""点击复制"
						Response.write rs_kz_zdy("fname")
						Response.write """ id=""zdy"
						Response.write rs_kz_zdy("id")
						Response.write """ onclick=""if(!copyClick(this.id)){alert('复制成功');}"" style=""cursor:pointer"">expandfield_"
						Response.write rs_kz_zdy("id")
						Response.write "_E</span>}                                    " & vbcrlf & "                                                </td>" & vbcrlf & "                                           "
						num1=num1+1
						If num1 Mod columns = 0 Then Response.write "</tr>"
						rs_kz_zdy.movenext
					Loop
					If num1 Mod columns > 0  Then Response.write "<td colspan="&columns-(num1 Mod columns)&"></td></tr>"
'Loop
				end if
				rs_kz_zdy.close
				set rs_kz_zdy=Nothing
				rs.movenext
			wend
		end if
		rs.close
		Response.write "" & vbcrlf & "      </table>" & vbcrlf & "        "
	end function
	Function isUsingExtend(TName)
		Dim rs,sql
		Set rs = server.CreateObject("adodb.recordset")
		sql =        "SELECT TOP 1 ID FROM ERP_CustomFields WHERE TName = "& TName &" AND IsUsing=1 AND del=1 AND FType <> '5' " &_
		"UNION " &_
		"SELECT TOP 1 ID FROM zdy WHERE sort1 = "& TName &" AND set_open = 1"
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			isUsingExtend = True
		else
			isUsingExtend = False
		end if
		rs.close
		set rs = nothing
	end function
	Function getExtendedCount(TName)
		getExtendedCount = sdk.getSqlValue("select count(1) from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1", 0)
	end function
	Function showExtended_byListHeader(TName, ord, classStr)
		dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7
		sql="select FName from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 order by FOrder asc "
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		rs_kz_zdy.open sql,conn,1,1
		While rs_kz_zdy.eof = False
			Response.write "" & vbcrlf & "              <td width=""11%"" align=""center"" "
			Response.write classStr
			Response.write ">"
			Response.write rs_kz_zdy("FName")
			Response.write "</td>" & vbcrlf & " "
			rs_kz_zdy.movenext
		wend
		rs_kz_zdy.close
		Set rs_kz_zdy = Nothing
	end function
	Function showExtended_byLIsttdStr(TName, ord, classStr)
		dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7, retStr
		retStr = ""
		sql="select * from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 order by FOrder asc "
		set rs_kz_zdy=server.CreateObject("adodb.recordset")
		rs_kz_zdy.open sql,conn,1,1
		While rs_kz_zdy.eof = False
			retStr = retStr & "<td height=""30"" width=""10%"" class="""& classStr &""">"
			if rs_kz_zdy("FType")="1" Then
				retStr = retStr & "<input name=""danh_"& rs_kz_zdy("id") &""" type=""text"" size=""15"" id=""danh_"& rs_kz_zdy("id") &""" value="""& c_Value &""" dataType=""Limit"""
				if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then retStr = retStr & " min=""1"""
				retStr = retStr & " max=""500""  msg=""必须在1到500个字符"" maxlength=""4000"">"
			Elseif rs_kz_zdy("FType")="2" then
				retStr = retStr & "<textarea name=""duoh_"& rs_kz_zdy("id") &""" id=""duoh_"& rs_kz_zdy("id") &""" style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px"" onfocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" dataType=""Limit"""
				if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then retStr = retStr & " min=""1"" "
				retStr = retStr & "max=""500""  msg=""必须在1到500个字符"">"& c_Value &"</textarea>"
			elseif rs_kz_zdy("FType")="3" Then
				retStr = retStr & "<input readonly name=""date_"& rs_kz_zdy("id") &""" value="""& c_Value &""" size=""15"" id=""daysOfMonthPos"" onmouseup=""toggleDatePicker('daysOfMonth_"& rs_kz_zdy("id") &"','date_"& rs_kz_zdy("id") &"')"" dataType=""Limit"""
				if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then retStr = retStr & " min=""1"""
				retStr = retStr & " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:right;background-repeat:no-repeat;""> <div id=""daysOfMonth_"& rs_kz_zdy("id") &""" style=""POSITION:absolute""></div>"
'if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then retStr = retStr & " min=""1"""
			ElseIf rs_kz_zdy("FType")="4" then
				retStr = retStr & "<input name=""Numr_"& rs_kz_zdy("id") &""" type=""text"" value="""& c_Value &""" size=""8"" id=""Numr_"& rs_kz_zdy("id") &""" onkeyup=""value=value.replace(/[^\d\.]/g,'')"" dataType=""Limit"""
				if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then retStr = retStr & " min=""1"" "
				retStr = retStr & "max=""500""  msg=""必须在1到500个字符"" >"
			Elseif rs_kz_zdy("FType")="5" then
				retStr = retStr & "<textarea name=""beiz_"& rs_kz_zdy("id") &""" id=""beiz_"& rs_kz_zdy("id") &""" style=""overflow-y:hidden;word-break:break-all;width:160px;height:22px"" onfocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" dataType=""Limit"""
				if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  then retStr = retStr & " min=""1"""
				retStr = retStr & "max=""500""  msg=""必须在1到500个字符"">"& c_Value &"</textarea>"
			ElseIf rs_kz_zdy("FType")="6" then
				retStr = retStr & "<select name=""IsNot_"& rs_kz_zdy("id") &""" id=""IsNot_"& rs_kz_zdy("id") &"""  dataType=""Limit"""
				if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then retStr = retStr & " min=""1"""
				retStr = retStr & " max=""500""  msg=""必须在1到500个字符"">"
				retStr = retStr & "<option value=""是"""
				If c_Value="是" Then retStr = retStr & " selected"
				retStr = retStr & ">是</option>"
				retStr = retStr & "<option value=""否"""
				If c_Value="否" Then retStr = retStr & "selected"
				retStr = retStr & ">否</option>"
				retStr = retStr & "</select>"
			ElseIf rs_kz_zdy("FType")="7" then
				retStr = retStr & "<select name=""meju_" & rs_kz_zdy("id") &""" id=""meju_"& rs_kz_zdy("id") &"""  dataType=""Limit"""
				if rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then retStr = retStr & " min=""1"""
				retStr = retStr & " max=""500""  msg=""必须在1到500个字符"">"
				set rs7=conn.execute("select id,CValue from ERP_CustomOptions where CFID="&rs_kz_zdy("id")&" order by id asc ")
				do until rs7.eof
					retStr = retStr & "<option value="""& rs7("id") &""""
					If rs7("CValue")=c_Value Then retStr = retStr & " selected"
					retStr = retStr & ">"& rs7("CValue") &"</option>"
					rs7.movenext
				loop
				rs7.close
				retStr = retStr & "</select>"
			end if
			if  rs_kz_zdy("MustFillin") Or Len(KZ_LIMITID&"")>0  Then
				retStr = retStr & "&nbsp;<span class=""red"">*</span>"
			end if
			retStr = retStr & "</td>"
			rs_kz_zdy.movenext
		wend
		rs_kz_zdy.close
		Set rs_kz_zdy = Nothing
		showExtended_byLIsttdStr = retStr
	end function
	Function getExtendedValue(c_Value,priceDigits)
		if c_Value ="" then
			getExtendedValue=""
		else
			getExtendedValue=FormatNumber(zbcdbl(c_Value),priceDigits,-1,0,0)
			getExtendedValue=""
		end if
	end function
	Function GetIdentity(tableName,fieldName,addPerson,connStr)
		dim rs, errmsg, errnum
		err.clear
		on error resume next
		Set rs=cn.Execute("SELECT TOP 1 "&fieldName&" FROM "&tableName&" WHERE "&addPerson&"=" & SESSION("personzbintel2007") & " ORDER BY "&fieldName&" DESC")
		errmsg = err.description
		errnum = Err.Number
		if errnum = 0 then
			if rs.eof = true then
				errnum = -10000
'if rs.eof = true then
				errmsg = "没有获取最新的标识数据。"
			else
				GetIdentity = rs(0).value
			end if
		end if
		if errnum <> 0 then
			cn.close
			Response.write  "GetIdentity函数执行错误:" & errmsg & "<br>tableName=[" &tableName& "]<br>fieldName=[" &fieldName& "]<br>addPerson=[" &addPerson& "] "
			Response.end
		end if
	end function
	Function getNum_cpmx
		dim rs, sqlStr, num_cpmx
		num_cpmx = 500
		set rs = cn.execute("select num1 from setjm3  where ord=3")
		if rs.eof then
			sqlStr="Insert Into setjm3(ord,num1) values('"
			sqlStr=sqlStr & 3 & "','"
			sqlStr=sqlStr & num_cpmx & "')"
			cn.execute(sqlStr)
		else
			num_cpmx =zbcdbl( rs("num1"))
		end if
		rs.close
		set rs = nothing
		getNum_cpmx = num_cpmx
	end function
	Function getMenuPagesize
		dim rs
		set rs=cn.execute("select num1 from setjm3 where ord=25")
		if not rs.eof then
			getMenuPagesize=rs(0)
		else
			cn.execute "insert into setjm3(ord,num1) values(25,20)"
			getMenuPagesize=20
		end if
		rs.close
		set rs=nothing
	end function
	Function getCpDefSelect
		dim rs
		set rs=cn.execute("select intro from setopen  where sort1=17")
		if not rs.eof then
			getCpDefSelect=rs(0)
		else
			getCpDefSelect=1
		end if
		rs.close
		set rs=nothing
	end function
	Function getMenuZhan
		dim rs, isZhan
		set rs=cn.execute("select num1 from setjm3 where ord=7")
		if not rs.eof then
			isZhan=rs(0)
		else
			isZhan = 0
		end if
		rs.close
		set rs=Nothing
		If isZhan = 1 Then
			getMenuZhan = True
		else
			getMenuZhan = False
		end if
	end function
	sub strCheckBH(bhid,table,strBhID,str)
		if strBhID<>"" then
			Err.Clear
			Dim sqlStr, rs
			set rs=cn.execute("select "&bhid&" from "&table&" where del<>7 and "&bhid&"='"&strBhID&"'")
			if not rs.eof then
				Response.write"<script language=javascript>app.Alert('该"&str&"编号已存在！请返回重试');</script>"
				Response.end
			end if
			rs.close
		end if
	end sub
	Function vbsUnEscape(str)
		dim i,s,c
		s=""
		For i=1 to Len(str)
			c=Mid(str,i,1)
			If Mid(str,i,2)="%u" and i<=Len(str)-5 Then
				c=Mid(str,i,1)
				If IsNumeric("&H" & Mid(str,i+2,4)) Then
					c=Mid(str,i,1)
					s = s & CHRW(CInt("&H" & Mid(str,i+2,4)))
					c=Mid(str,i,1)
					i = i+5
					c=Mid(str,i,1)
				else
					s = s & c
				end if
			ElseIf c="%" and i<=Len(str)-2 Then
				s = s & c
				If IsNumeric("&H" & Mid(str,i+1,2)) Then
					s = s & c
					s = s & CHRW(CInt("&H" & Mid(str,i+1,2)))
					s = s & c
					i = i+2
					s = s & c
				else
					s = s & c
				end if
			else
				s = s & c
			end if
		next
		vbsUnEscape = s
	end function
	Function replaceIntroHtml(intro)
		If intro&""<>"" Then
			replaceIntroHtml = Replace(Replace(intro,Chr(13),"<br>"),Chr(32),"&nbsp;")
		else
			replaceIntroHtml = ""
		end if
	end function
	Dim  headtitle, bz
	Dim rs, rs88,rs7, sql,sql7, sqlStr, thid, rd
	Sub MessagePost(msgId)
		Select Case msgId
		Case ""
		Call Page_load
		case "getTelInfo"
		call getTelInfo
		Case "checkMxCount"
		Call checkMxCount
		Case "checkSLid"
		Call checkSLid
		End Select
	end sub
	Sub Page_load
		session("contractzbintel")=""
		session("contractthmoney_all")=0
		sql="Delete contractth where addcate="&info.user&" and del=7"
		cn.Execute(sql)
		sql="Delete contractthlist where addcate="&info.user&" and del=7"
		cn.Execute(sql)
		sql="Delete contractthListDetail where addcate="&info.user&" and del=7"
		cn.Execute(sql)
		sql="Delete contractthbz where addcate="&info.user&" and del=7"
		cn.Execute(sql)
		set rs88 = cn.execute("EXEC erp_getdjbh 41,"&session("personzbintel2007"))
		thid=rs88(0).value
		set rs88=nothing
		sqlStr="Insert Into contractth(addcate,del) values('"
		sqlStr=sqlStr & info.user & "','"
		sqlStr=sqlStr & 7 & "')"
		Cn.execute(sqlStr)
		dim rd
		rd = GetIdentity("contractth","ord","addcate","")
		session("contractth_idzbintel")=rd
		session("companyzbintel") = ""
		session("ContractthCateid")=""
		headtitle="退货添加"
		app.docmodel = "IE=8"
		Response.write app.DefTopBarHTML(app.virPath, "", headtitle, "")
		Dim contractOrd,companyName,companyOrd,contractbz
		contractOrd = app.base64.deurl(request("ord"))
		If contractOrd&""<>"" Then
			Set rs = cn.execute("select contract.company,(select name from tel where ord=contract.company) as companyName,contract.title,bz,contract.cateid,gate.name from contract left join gate on gate.ord=contract.cateid where contract.ord="&contractOrd)
			If rs.eof = False Then
				companyOrd = rs("company")
				session("companyzbintel") = companyOrd
				htcateid=rs("cateid")
				session("ContractthCateid")=htcateid
				companyName = rs("companyName")
				contractbz = rs("bz")
				htcatename= rs("name")
			end if
			rs.close
		end if
		If htcateid=0 Then htcateid = ""
		sql="select intro from setopen where sort1=202072414"
		set rs=conn.execute(sql)
		if rs.eof then
			sort4=0
		else
			sort4=rs("intro")
		end if
		sql="select intro from setopen where sort1=202072413"
		set rs=conn.execute(sql)
		if rs.eof then
			sort5=0
		else
			sort5=rs("intro")
		end if
		sql="select intro from setopen where sort1=202072412"
		set rs=conn.execute(sql)
		if rs.eof then
			sort6=0
		else
			sort6=rs("intro")
		end if
		Response.write "" & vbcrlf & "<script type=""text/JavaScript"" src=""../inc/CommSPAjax.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href=""../inc/themes/default/easyui.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write """>" & vbcrlf & "<script type=""text/javascript"" src=""../inc/jquery.easyui.min.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "<script type=""text/javascript"" src=""../inc/setup.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "    window.billTHrd = """
		Response.write rd
		Response.write """;" & vbcrlf & "    window.ConflictPageUrllist = """
		Response.write ConflictPageUrllist
		Response.write """; //冲突的页面" & vbcrlf & "</script>" & vbcrlf & "<script src= ""../Script/ch_addth.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """  type=""text/javascript""></script>" & vbcrlf & "<style type=""text/css"">" & vbcrlf & ".defcomm{overflow:auto;；overflow-x:hidden;}" & vbcrlf & "#content tr.top td {" & vbcrlf & "             text-align:left;" & vbcrlf & "                line-height:19px;" & vbcrlf & "               font-weight: bold;" & vbcrlf & "      }" & vbcrlf & "#spdiv #content input {" & vbcrlf & "  width:36px;" & vbcrlf & "     font-size:12px;" & vbcrlf & " cursor:pointer;" & vbcrlf & " padding: 0 3px;" & vbcrlf & " padding-top:0;" & vbcrlf & "  height: 28px;line-height:26px;" & vbcrlf & "  *line-height:25px;" & vbcrlf & "      background-size: 100% 100%;" & vbcrlf & "       transition:all 0.2s ease-in-out;" & vbcrlf & "        -moz-transition:all 0.2s ease-in-out;" & vbcrlf & "   -webkit-transition:all 0.2s ease-in-out;" & vbcrlf & "        -o-transition:all 0.2s ease-in-out;" & vbcrlf & "             padding:0px;" & vbcrlf & "    }" & vbcrlf & "       #_sp_usr{height:144px!important}" & vbcrlf & "#comm_itembarbg{border-bottom:1px solid #ccc!important}" & vbcrlf & " #_sp_usr tr.top td{border-top:1px solid #ccc;padding-left:5px;}" & vbcrlf & " input[type='text']{ border:1px solid #ccc; }" & vbcrlf & "    input[type='text']:focus{ outline:none;box-shadow: 0px 0px 2px 1px #4fa1e5; }" & vbcrlf & "   textarea{ border:1px solid #ccc; }" & vbcrlf & "   textarea:focus{ outline:none;box-shadow: 0px 0px 2px 1px #4fa1e5; }" & vbcrlf & "     html{padding: 10px 10px 0;background: #efefef;box-sizing:border-box;}" & vbcrlf & "   body{background: #ffffff;}" & vbcrlf & "      #spdiv td {" & vbcrlf & "             height:47px!important;" & vbcrlf & "        }" & vbcrlf & "</style>" & vbcrlf & "<body>" & vbcrlf & " <iframe name=""saveMainIframe"" id=""saveMainIframe"" style=""width:0;height:0 ;display:none""></iframe>" & vbcrlf & "    <form method='POST' action='saveth.asp?ord="
		Response.write app.base64.pwurl(rd)
		Response.write "' id='demo' name='demo'  target=""saveMainIframe"" style=""margin:0"">    " & vbcrlf & "   <table width=""100%""  id=""content"" cellpadding=""5"" style='margin-top:-1px' > " & vbcrlf & "  <tr class=""top2"" style=""height:19px;"">" & vbcrlf & "              <td colspan=""6"" style=""height:18px;""><div style=""float:left; width:200px; height:64px;"" align=""left"">&nbsp;<b>基本信息</b></div>" & vbcrlf & "        <div style=""float:right; width:200px; height:64px;""><input type='button' name='Submit42' id=""Submit42"" value='保存' class='oldbutton'  onclick=""checkSLForm()""/>&nbsp;&nbsp;&nbsp;&nbsp;<input type='reset' value='重填' class='oldbutton' name='B2' id=""B2""></div>" & vbcrlf & "        <b style=""clear:both; height:0px;""> </b></td>" & vbcrlf & "        </tr>" & vbcrlf & "   <tr height=""30"">" & vbcrlf & "          <td class=""label"" valign=""middle"" width=""11%""><div align=""right"">关联客户：</div></td>" & vbcrlf & "           <td class=""labe2"" valign=""middle"" width=""22%""><div align=""left"">" & vbcrlf & ""
		If contractOrd&""<>"" Then
			Response.write "" & vbcrlf & "             <select>" & vbcrlf & "                        <option>"
			Response.write companyName
			Response.write "</option>" & vbcrlf & "            </select>" & vbcrlf & ""
		else
			Response.write "" & vbcrlf & "             <input name=""company"" id=""khmc"" type=""text"" size=""20"" value="""
			Response.write companyName
			Response.write """ onClick=""javascript: this.blur(); window.open('../search/result4_onlykh.asp', 'eventcom', 'width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=100,top=100'); return false;"" readonly dataType=""Limit"" min=""1"" max=""100""  msg=""长度必须在1至100个字之间""> "& vbcrlf & ""
		end if
		Response.write "" & vbcrlf & "             <span class=""red"">*</span><input type=""hidden"" name=""companyOrd"" id=""companyOrd"" value="""
		Response.write companyOrd
		Response.write """ /></div></td>" & vbcrlf & "       <td valign=""middle"" class=""label"" width=""11%""><div align=""right"">退货编号：</div></td>" & vbcrlf & "              <td valign=""middle"" class=""labe2"" width=""17%""><div align=""left""><input id=""thid"" type=""text"" name=""thid"" size=""15"" value="""
		Response.write thid
		Response.write """ " & vbcrlf & "                        dataType=""Limit"" min=""1"" max=""50"" msg=""受理单号必须在1至50字之间""" & vbcrlf & "                       class='jquery-auto-bh' autobh-options='cfgId:41,recId:"
		Response.write thid
		Response.write rd
		Response.write ",autoCreate:false'" & vbcrlf & "           /> <span class=""red"">*</span></div></td>" & vbcrlf & "        <td class=""label""><div align=""right"">退货日期：</div></td>" & vbcrlf & "            <td class=""labe2""><div align=""left""><INPUT name='date1' type=""text"" size='15' readonly onclick='datedlg.show();' value='"
		Response.write date
		Response.write "' dataType=""Limit"" min=""1"" max=""50""  msg=""长度必须在1至50个字之间""> <span class=""red"">*</span></div></td>" & vbcrlf & "      </tr>" & vbcrlf & "   <tr height=""30"">" & vbcrlf & "          <td valign=""middle"" class=""label"" width=""11%"" ><div align=""right"">退货主题：</div></td>" & vbcrlf & "         <td valign=""middle"" class=""labe2"" width=""27%""><input type='text' id=""title"" name=""title"" size=""20""  dataType=""Limit"" min=""1"" max=""100"" msg=""主题必须在1至100字之间""/> <span class=""red"">*</span></td>" & vbcrlf & "     <td><div align=""right"">退货分类：</div></td>" & vbcrlf & "              <td><span class=""gray""><selectname=""sort"" class=""gray"">" & vbcrlf & "              "
		set rs7=cn.execute("select * from sortonehy where gate2=35 order by gate1 desc")
		do until rs7.eof
			Response.write "<option value='"&rs7("ord")&"'>"&rs7("sort1")&"</option>"
			rs7.movenext
		loop
		rs7.close
		Response.write "" & vbcrlf & "             </selectname=>" & vbcrlf & "               </span></td>" & vbcrlf & "        <td><div align=""right"">退货状态：</div></td>" & vbcrlf & "          <td><span class=""gray"">" & vbcrlf & "           "
		dim checked :checked=False
		set rs7=cn.execute("select * from sortonehy where gate2=36 order by gate1 desc")
		if rs7.eof =True then
			Response.write "<div style='color:red'>请设置退货状态</div>"
		else
			do until rs7.eof
				Response.write "<input name='complete1' type='radio' value='"&rs7("ord")&"' "
				If checked = False Then Response.write " checked " : checked = True
				Response.write ">"&rs7("sort1")
				rs7.movenext
			loop
			rs7.close
		end if
		Response.write "" & vbcrlf & "             </span></td>    " & vbcrlf & "        </tr>" & vbcrlf & "   <tr height=""30"">" & vbcrlf & "          <td width=""11%"" height=""27""><div align=""right"">销售人员：</div></td>" & vbcrlf & "        <td width=""22%"" height=""27"">" & vbcrlf & "            <input type=""hidden"" id=""W1"" name=""W1"" value="""">" & vbcrlf & "            <input type=""hidden"" id=""W2"" name=""W2"" value="""">" & vbcrlf & "            <input type=""hidden"" id=""W3"" name=""W3"" value='"
		Response.write htcateid
		Response.write "'>" & vbcrlf & "                   <input checked onclick=""window.gateTreeSearchClickTH(this, event);"" name='xsry' type='radio' />有<input type='text' style=""margin-left:5px;"" sid=""6"" readonly  name='htcatename' id='gatestreeselbox'  size='18' value='"
		Response.write htcateid
		Response.write htcatename
		Response.write "' "
		If conn.execute("select 1 from power2  where cateid="&session("personzbintel2007")&" and sort1=4").eof=false Then
			Response.write "onclick=""window.gateTreeSearchClickTH(this, event);"""
		end if
		Response.write " datatype=""Limit"" min=""1"" msg=""请选择销售人员""> <input   onclick=""choose(1);"" name='xsry' type='radio' />无 <span class=""red"">*</span>" & vbcrlf & "        </td>" & vbcrlf & "            <td><div align=""right"">退款计划：</div></td>" & vbcrlf & "              <td><select name=""BKPayModel"" id=""BKPayModel"" datatype=""Limit"" min=""1"" msg=""请选择退款计划"">" & vbcrlf & "            "
		Response.write "<option value=''>退款计划</option>"
		if sort4=1 then
			Response.write "<option value='1'>自动生成</option>"
		end if
		if sort5=1 then
			Response.write "<option value='2'>手动生成</option>"
		end if
		If ZBRuntime.MC(23003)  Then
			if sort6=1 then
				Response.write "<option value='3'>对账生成</option>"
			end if
		end if
		Response.write "" & vbcrlf & "             </select><span class=""red"">*</span></td>" & vbcrlf & "                  <td class=""label""><div align=""right"">币&nbsp;&nbsp;种：</div></td>" & vbcrlf & "          <td valign=""middle"" class=""labe2""><div align=""left""><select name=""bz"" id = ""bz"" dataType=""Limit"" min=""1"" msg=""请选择币种"">" & vbcrlf & "             "
		bz = 0
		set rs = cn.execute("Select top 1 bz from setbz")
		if rs.eof = false then
			if rs("bz") = 1 Then bz = 1
		end if
		rs.close
		if bz = 0 Then
			sql = "select id,sort1 from sortbz where id=14"
		else
			Response.write "<option value=''>选择币种</option>"
			sql = "select id,sort1 from sortbz order by gate1 desc"
		end if
		set rs = cn.execute(sql)
		while rs.eof = False
			Response.write "<option value='"&rs("id")&"'"
			If contractbz = rs("id") Then Response.write " selected "
			Response.write ">"&rs("sort1")&"</option>"
			rs.movenext
		wend
		rs.close
		Response.write "" & vbcrlf & "             </select> <span class=""red"">*</span></div></td><td style='border:0;' colspan=""2""><input type=""hidden"" name=""moneyall"" id=""moneyall"" value = ""0""></td>" & vbcrlf & "       </tr>" & vbcrlf & "" & vbcrlf & "   "
		Dim num1 , i_jm,j_jm
		set rs=server.CreateObject("adodb.recordset")
		sql="select id,title,name,sort,gl from zdy where sort1=41 and set_open=1 order by gate1 asc "
		rs.open sql,conn,1,1
		num1=rs.RecordCount
		i_jm=0
		j_jm=1
		if rs.eof = False then
			Response.write("<tr>")
			do until rs.eof
				if clng(i_jm/3)=i_jm/3 and i_jm<>0 then
					Response.write("</tr><tr>")
					j_jm=j_jm+1
					Response.write("</tr><tr>")
				end if
				Response.write "" & vbcrlf & "                     <td align=""right"">"
				Response.write rs("title")
				Response.write "：</td>" & vbcrlf & "                      <td "
				if i_jm=num1-1  then
					Response.write "：</td>" & vbcrlf & "                      <td "
					Response.write "colspan="""
					Response.write 1+2*(j_jm*2-num1)
					Response.write "colspan="""
					Response.write """"
				end if
				Response.write ">" & vbcrlf & "                    "
				if rs("sort")=2 then
					Response.write "" & vbcrlf & "                             <input name="""
					Response.write rs("name")
					Response.write """ type=""text"" size=""15"" dataType=""Limit"" max=""50"" msg=""长度不能超过50个字"" >" & vbcrlf & "                        "
				elseif rs("sort")=1 then
					Response.write "" & vbcrlf & "                             <select name="""
					Response.write rs("name")
					Response.write """>" & vbcrlf & "                                "
					set rs7=server.CreateObject("adodb.recordset")
					sql7="select ord,sort1 from sortonehy where gate2="&rs("gl")&" order by gate1 desc "
					rs7.open sql7,conn,1,1
					do until rs7.eof
						Response.write "" & vbcrlf & "                                     <option value="""
						Response.write rs7("ord")
						Response.write """>"
						Response.write rs7("sort1")
						Response.write "</option>" & vbcrlf & "                                    "
						rs7.movenext
					loop
					rs7.close
					set rs7=nothing
					Response.write "" & vbcrlf & "                             </select>" & vbcrlf & "                       "
				end if
				Response.write "             " & vbcrlf & "                        </td>" & vbcrlf & "                   "
				i_jm=i_jm+1
				Response.write "             " & vbcrlf & "                        </td>" & vbcrlf & "                   "
				rs.movenext
			loop
			Response.write("</tr>")
		end if
		rs.close
		set rs=nothing
		Response.write(getExtended(41,0))
		Response.write "" & vbcrlf & "     <tr class=""top2"">" & vbcrlf & "         <td colspan=""6"" style='border:0;'><div align=""left"">&nbsp;<b>退货明细</b></div></td>" & vbcrlf & "        </tr>" & vbcrlf & "   <tr>" & vbcrlf & "            <td class=""labe2"" colspan=""6"" height=""60"" style=""padding-bottom:0px; ""><IFRAME name=""I3"" id=""mxlist"" SRC=""../event/thmx.asp?r="
		Response.write now
		Response.write """ FRAMEBORDER=""0"" SCROLLING=""auto"" width=""100%"" HEIGHT=""63"" marginwidth=""1"" marginheight=""1"" style=""margin:0; padding:30px 37px;margin-top:5px;box-sizing:border-box;height:218px;"" onload=""frameResize()""></IFRAME></td>" & vbcrlf & " </tr>" & vbcrlf & "   <tr height=""100"">" & vbcrlf & "           <td class=""label""><div align=""right"">退货原因：</div></td>" & vbcrlf & "          <td class=""labe2"" colspan=""5"" style='padding-top:3px;'><div align=""left""><textarea name=""intro"" style=""display:none"" cols=""1"" rows=""1""></textarea><IFRAME ID=""eWebEditor1"" SRC=""../edit/ewebeditor.asp?id=intro&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""300"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME></div></td>" & vbcrlf & "    </tr>" & vbcrlf & "      "
		Response.write(getExtended1(41,0))
		Response.write "" & vbcrlf & "     <tr height=""30""><td class='gray'  style='border:0;' colspan=""6""><div align='center' style=""margin-top:8px;"">" & vbcrlf & "  <input type='button' name='Submit42' id=""Submit42"" value='保存' class='oldbutton' onClick=""checkSLForm()""/>&nbsp;&nbsp;&nbsp;&nbsp;<input type='reset' value='重填' class='oldbutton' name='B2' id=""B2""><br /><br /></div></td></tr>" & vbcrlf & "    </table> " & vbcrlf & " </form>" & vbcrlf & "    <div id=""w"" class=""easyui-window"" title=""销售人员""  style=""width:800px;height:500px;padding:5px;background: #fafafa;top:160px;left:200px;display:none""closed=""true"" ></div>" & vbcrlf &" </body>" & vbcrlf &" </html>  "  & vbcrlf
	end sub
	sub getTelInfo
		dim telord
		telord=request("ord")
		set rs = cn.execute("select t.name, t.address,t.cateid,g.name username from tel t left join gate g on g.ord=t.cateid where t.ord="& telord &" ")
		if rs.eof = false then
			Response.write("1{|}"& rs("name") &"{|}"& rs("address")&"{|}"&rs("cateid")&"{|}"&rs("username")&"")
		else
			Response.write("0{|}")
		end if
		rs.close
		set rs = nothing
	end sub
	Sub checkMxCount()
		Dim mxCount, thord
		thord = request("thord")
		mxCount = 0
		mxCount = cn.execute("select count(id) from contractthlist where del=7 and caigou="& thord)(0)
		Response.write mxCount
	end sub
	Sub checkSLid
		Dim thid, rs, chongBH
		thid = Trim(request("thid"))
		If thid&""<>"" Then
			chongBH = 0
			Set rs = cn.execute("select top 1 thid from contractth where del<>7 and thid='"& thid &"'")
			If rs.eof = False Then
				chongBH = 2
			end if
			rs.close
			set rs = nothing
			Response.write chongBH
		end if
	end sub
	
%>
