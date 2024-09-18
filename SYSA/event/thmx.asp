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
			set rs=server.CreateObject("adodb.recordset")
			sqlStr="select "&bhid&" from "&table&" where del<>7 and "&bhid&"='"&strBhID&"'"
			rs.open sqlStr,cn,1,1
			if not rs.eof then
				Response.write"<script language=javascript>alert('该"&str&"编号已存在！请返回重试');window.history.back(-1);</script>"
'if not rs.eof then
				Response.end
			end if
			rs.close
			set rs=nothing
		else
		end if
	end sub
	Function editExtended(TName,ord,extValue)
		dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7, rs_zdy, len_rszdy, MustFillin, nextFType
		dim columns, num1, i_jm, j_jm, c_Value, KZ_LIMITID
		Dim FType, cols, ycols, FName, FKZID, arr_extValue, arr_FValue, i, k
		cols = 1 : ycols = 1 : i_jm = 0 : j_jm = 0
		columns=2
		set rs_kz_zdy=cn.execute("select id, FType, FName, MustFillin from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 order by FOrder asc ")
		if rs_kz_zdy.eof = False Then
			rs_zdy = rs_kz_zdy.GetRows()
		end if
		rs_kz_zdy.close
		set rs_kz_zdy = Nothing
		if isArray(rs_zdy) then
			len_rszdy = ubound(rs_zdy,2)
		else
			len_rszdy = -1
			len_rszdy = ubound(rs_zdy,2)
		end if
		num1 = 0
		for i=0 to len_rszdy
			If  num1 Mod columns = 0 Then Response.write "<tr>"
			FKZID = rs_zdy(0,i)
			FType = rs_zdy(1,i)
			FName =rs_zdy(2,i)
			MustFillin =rs_zdy(3,i)
			If columns = 2 Then
				Select Case FType
				Case "2","5" : cols = 3
				Case Else : cols = 1
				End Select
			end if
			If i < len_rszdy Then
				nextFType = rs_zdy(1,i+1)
'If i < len_rszdy Then
				If  (nextFType = "2" Or nextFType = "5" ) And cols = 1 And num1 Mod columns=0 Then cols = 3
			else
				If   cols = 1  And num1 Mod columns=0  Then cols = 3
			end if
			c_Value = ""
			If InStr(Chr(3)&Chr(4)& extValue , Chr(3)&Chr(4)& FKZID & Chr(1)&Chr(2))>0 Then
				arr_extValue = Split(extValue,Chr(3)&Chr(4))
				For k = 0 To ubound(arr_extValue)
					If arr_extValue(k)&""<>"" Then
						If InStr(Chr(3)&Chr(4)& arr_extValue(k) , Chr(3)&Chr(4)& FKZID & Chr(1)&Chr(2))>0 Then
							arr_FValue = Split(arr_extValue(k),Chr(1)&Chr(2))
							If arr_FValue(2)&""<>"" Then
								c_Value = arr_FValue(2)
							else
								c_Value = ""
							end if
						end if
					end if
				next
			end if
			If c_Value&""<>"" Then
				c_Value = vbsUnEscape(c_Value)
			end if
			Response.write "" & vbcrlf & "         <td width=""15%"" align=""right"" height=25 style=""min-height:25px;"">"
			c_Value = vbsUnEscape(c_Value)
			Response.write FName
			Response.write "：</td>" & vbcrlf & "              <td  colspan="""
			Response.write cols
			Response.write """>" & vbcrlf & ""
			if FType="1" Then
				Response.write "" & vbcrlf & "             <input name=""danh_"
				Response.write FKZID
				Response.write """ type=""text"" size=""15"" id=""danh_"
				Response.write FKZID
				Response.write """ value="""
				Response.write c_Value
				Response.write """ dataType=""Limit"" "
				if MustFillin Or Len(KZ_LIMITID&"")>0  then
					Response.write " min=""1"" "
				end if
				Response.write "  max=""500""  msg=""必须在1到500个字符"" maxlength=""4000"">" & vbcrlf & ""
			Elseif FType="2" then
				If c_Value &""<>"" Then c_Value = Replace(Replace(Replace(c_Value,"<Chr(13)>",Chr(13)),"  ",""),"<Chr(32)>",Chr(32))
				Response.write "" & vbcrlf & "             <textarea name=""duoh_"
				Response.write FKZID
				Response.write """ id=""duoh_"
				Response.write FKZID
				Response.write """ style=""overflow-y:auto;word-break:break-all;width:80%;"" rows=""4""  dataType=""Limit"" "
				Response.write FKZID
				if MustFillin Or Len(KZ_LIMITID&"")>0  then
					Response.write " min=""1"" "
				end if
				Response.write " max=""500""  msg=""必须在1到500个字符"">"
				Response.write c_Value
				Response.write "</textarea>" & vbcrlf & ""
			elseif FType="3" Then
				Response.write "" & vbcrlf & "             <input readonly name=""date_"
				Response.write FKZID
				Response.write """ value="""
				Response.write c_Value
				Response.write """ size=""15"" id=""date_"
				Response.write FKZID
				Response.write """  onclick='datedlg.show();' "
				if MustFillin Or Len(KZ_LIMITID&"")>0  then
					Response.write " min=""1"" "
				end if
				Response.write " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:right;background-repeat:no-repeat;"">" & vbcrlf & ""
				Response.write " min=""1"" "
			ElseIf FType="4" then
				Response.write "" & vbcrlf & "             <input name=""Numr_"
				Response.write FKZID
				Response.write """ type=""text"" value="""
				Response.write c_Value
				Response.write """ size=""15"" id=""Numr_"
				Response.write FKZID
				Response.write """ onkeyup=value=value.replace(/[^\d\.]/g,'') dataType=""Limit"" "
				if MustFillin Or Len(KZ_LIMITID&"")>0  then
					Response.write " min=""1"" "
				end if
				Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & ""
			ElseIf FType="5" then
				Response.write "" & vbcrlf & "             <textarea name=""beiz_"
				Response.write FKZID
				Response.write """ id=""beiz_"
				Response.write FKZID
				Response.write """ dataType=""Limit""  max=""4000""  msg=""备注长度不能超过4000个字"" style=""display:none""  cols=""1"" rows=""1"">"
				if c_Value<>"" then Response.write c_Value End if
				Response.write "</textarea>" & vbcrlf & "          <IFRAME ID=""eWebEditor_"
				Response.write FKZID
				Response.write """ SRC=""../edit/ewebeditor.asp?id=beiz_"
				Response.write FKZID
				Response.write "&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""240"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME>" & vbcrlf & ""
			ElseIf FType="6" then
				Response.write "" & vbcrlf & "             <select name=""IsNot_"
				Response.write FKZID
				Response.write """ id=""IsNot_"
				Response.write FKZID
				Response.write """  dataType=""Limit"" "
				if MustFillin Or Len(KZ_LIMITID&"")>0  then
					Response.write " min=""1"" "
				end if
				Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                   <option value=""是"" "
				If c_Value="是" then
					Response.write "selected"
				end if
				Response.write ">是</option>" & vbcrlf & "                 <option value=""否"" "
				If c_Value="否" then
					Response.write "selected"
				end if
				Response.write ">否</option>" & vbcrlf & "         </select>" & vbcrlf & ""
			else
				Response.write "" & vbcrlf & "             <select name=""meju_"
				Response.write FKZID
				Response.write """ id=""meju_"
				Response.write FKZID
				Response.write """  dataType=""Limit"" "
				if MustFillin Or Len(KZ_LIMITID&"")>0  then
					Response.write " min=""1"" "
				end if
				Response.write "  max=""500""  msg=""必须在1到500个字符"" style=""width:150px;"">" & vbcrlf & ""
				set rs7=server.CreateObject("adodb.recordset")
				sql7="select id,CValue from ERP_CustomOptions where CFID="&FKZID&" order by id asc "
				rs7.open sql7,cn,1,1
				do until rs7.eof
					Response.write "" & vbcrlf & "                             <option value="""
					Response.write rs7("id")
					Response.write """ "
					If rs7("CValue")=c_Value then
						Response.write "selected"
					end if
					Response.write ">"
					Response.write rs7("CValue")
					Response.write "</option>" & vbcrlf & ""
					rs7.movenext
				loop
				rs7.close
				set rs7=nothing
				Response.write "" & vbcrlf & "           </select>" & vbcrlf & ""
			end if
			if  MustFillin Or Len(KZ_LIMITID&"")>0  Then
				Response.write "" & vbcrlf & "                      &nbsp;<span class=""red"">*</span>" & vbcrlf & ""
			end if
			Response.write "" & vbcrlf & "             </td>" & vbcrlf & ""
			If cols = 1 Then
				num1 = num1 +1
'If cols = 1 Then
			else
				num1 = num1 +2
'If cols = 1 Then
			end if
			If  num1 Mod columns = 0 Then Response.write "</tr>"
		next
	end function
	Function vbsUnEscape(str)
		dim i,s,c
		s=""
		For i=1 to Len(str)
			c=Mid(str,i,1)
			If Mid(str,i,2)="%u" and i<=Len(str)-5 Then
				c=Mid(str,i,1)
				If IsNumeric("&H" & Mid(str,i+2,4)) Then
'c=Mid(str,i,1)
					s = s & CHRW(CInt("&H" & Mid(str,i+2,4)))
'c=Mid(str,i,1)
					i = i+5
'c=Mid(str,i,1)
				else
					s = s & c
				end if
			ElseIf c="%" and i<=Len(str)-2 Then
				s = s & c
				If IsNumeric("&H" & Mid(str,i+1,2)) Then
's = s & c
					s = s & CHRW(CInt("&H" & Mid(str,i+1,2)))
's = s & c
					i = i+2
's = s & c
				else
					s = s & c
				end if
			else
				s = s & c
			end if
		next
		vbsUnEscape = s
	end function
	Function showExtended2(jianIntro)
		If jianIntro&""<>"" Then
			dim columns, num1, c_Value, KZ_LIMITID
			Dim arr_intro, extValue, v_vid, rs, nextFType
			Dim FType, JFtype, cols, ycols, FName, FKZID, arr_extValue, extItem, arr_extItem, arr_FValue, i
			cols = 1 : ycols = 1
			columns=2
			arr_intro = Split(jianIntro,Chr(4)&Chr(5)&Chr(6))
			JFtype = arr_intro(0)
			If JFtype&""<>"" Then JFtype = CLng(JFtype) Else JFtype=0
			extValue = arr_intro(1)
			arr_extValue = Split(extValue,Chr(3)&Chr(4))
			num1 = 0
			For i = 0 To ubound(arr_extValue)
				If arr_extValue(i)&""<>"" Then
					extItem = arr_extValue(i)
					arr_extItem = Split(extItem,Chr(1)&Chr(2))
					If arr_extItem(1)&""<>"" Then
						If  num1 Mod columns = 0 Then Response.write "<tr>"
						v_vid = arr_extItem(0) : FName = arr_extItem(1) : FType = arr_extItem(2) : c_Value = arr_extItem(3)
						If v_vid&""="" Then v_vid = 0
						Select Case FType
						Case "2","5" : cols = 3
						Case Else : cols = 1
						End Select
						If  i < ubound(arr_extValue) Then
							nextFType  =  Split(arr_extValue(i+1),Chr(1)&Chr(2))(2)
'If  i < ubound(arr_extValue) Then
							If  (nextFType = "2" Or nextFType = "5" ) And cols = 1 And num1 Mod columns=0 Then cols = 3
						else
							If   cols = 1  And num1 Mod columns=0  Then cols = 3
						end if
						Response.write "" & vbcrlf & "                                     <td width=""11%"" align=""right"" height=25 style=""min-height:25px;"">"
'If   cols = 1  And num1 Mod columns=0  Then cols = 3
						Response.write FName
						Response.write "：</td>" & vbcrlf & "                                      <td width=""22%"" colspan="""
						Response.write cols
						Response.write """>"
						If FType&""="5" And c_Value&""<>"" Then
							Dim arr_img
							arr_img = split(c_Value,"<img",-1,1)
'Dim arr_img
							if ubound(arr_img)>0 Then
								Response.write "" & vbcrlf & "                                                     <div href=""javascript:;"" onClick=""window.open('info.asp?ord="
								Response.write app.base64.pwurl(v_vid)
								Response.write "&sort1=3&sort2=intro','neww6768999in','width=' + 1600 + ',height=' + 800 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=0,top=150');return false;"" onMouseOver=""window.status='none';return true;"" title=""放大查看"">"
								Response.write app.base64.pwurl(v_vid)
								Response.write c_Value
								Response.write "</div>" & vbcrlf & "                                                       "
							else
								If c_Value&""<>"" Then  Response.write(Replace(Replace(c_Value,Chr(13),"<br>"),Chr(32),"&nbsp;"))
							end if
						ElseIf FType&""="7"  Then
							If c_Value&""<>"" Then
								Set rs = cn.execute("select CValue from ERP_CustomOptions where id="&c_Value&"")
								If rs.eof = False Then  Response.write rs("CValue")
								rs.close
								set rs = nothing
							end if
						else
							If c_Value&""<>"" Then  Response.write(Replace(Replace(c_Value,Chr(13),"<br>"),Chr(32),"&nbsp;"))
						end if
						Response.write "" & vbcrlf & "                                     </td>" & vbcrlf & "                                   "
					end if
					If cols = 1 Then
						num1 = num1 +1
'If cols = 1 Then
					else
						num1 = num1 +2
'If cols = 1 Then
					end if
					If  num1 Mod columns = 0 Then Response.write "</tr>"
				end if
			next
		end if
	end function
	Function replaceIntroHtml(intro)
		If intro&""<>"" Then
			replaceIntroHtml = Replace(Replace(intro,Chr(13),"<br>"),Chr(32),"&nbsp;")
		else
			replaceIntroHtml = ""
		end if
	end function
	Function GetProcessBox(PID,mxid)
		Dim rs,sql,strHTML,ID,Title
		If (mxid&""<>"" And mxid&""<>"0") Or mxid="pi" Then
			If mxid="pi" Then
				strHTML = "<select id='ProcessID_pi' name='ProcessID_pi' style='width:110px;'>"
			else
				strHTML = "<select id='ProcessID_"& mxid &"' name='ProcessID' dataType='Limit' min='1' max='50' msg='必填' style='width:110px;'>"
			end if
		else
			strHTML = "<select id='ProcessID' name='ProcessID' class='select' dataType='Limit' min='1' max='50' msg='必填' style='width:110px;'>"
		end if
		strHTML = strHTML&"<option value=''>请选择维修流程</option>"
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT ID,Title FROM Comm_ProcessSet WHERE Type = 1 AND IsUse = 1 ORDER BY Ranking DESC,AddTime DESC"
		rs.Open sql,cn,1,1
		If Not rs.Eof Then
			Do While rs.Eof = False
				ID = rs("ID")
				Title = rs("Title")
				strHTML = strHTML&"<option value='"&ID&"' "
				If ID = PID Then
					strHTML = strHTML&"selected"
				end if
				strHTML = strHTML&">"&Title&"</option>"
				rs.movenext
			Loop
		end if
		rs.close
		set rs = nothing
		strHTML = strHTML&"</select>"
		GetProcessBox = strHTML
	end function
	Function saveRepairOrder(slord, slid, ProcessID, DealPerson)
		Dim sql, sql2, sql3, rs, rs88, SerialNumber,wxTitle, arr_slid, arr_ProcessID, arr_DealPerson, i
		Dim pgnum, pgmoney, htord, htlid, wxid, cpord, date1, cptitle
		sql = "" : sql2 = "" : sql3 = ""
		If slord&""<>"" And slid&""="" Then
			Set rs =  cn.execute("select id,repair_sl,Contract,ContractList,num1,money1,ord,date1 from repair_sl_list where repair_sl="& slord &" and del<>2 and isnull(num2,0)=0 order by id")
			While rs.eof = False
				Set rs88 = cn.Execute("EXEC erp_getdjbh 46,"&session("personzbintel2007"))
				SerialNumber = rs88(0).value
				Set rs88 = Nothing
				If SerialNumber="error" Then
					cn.rollbacktrans
					Response.write "<script language='javascript'>alert('维修单编号顺序递增位数已占满，请联系系统管理员，重新调整维修单编号顺序递增位数！');history.back();</script>"
					Response.end
				end if
				slid = rs("id") : htord = rs("Contract") : htlid = rs("ContractList") : pgnum =zbcdbl( rs("num1")) : pgmoney =zbcdbl( rs("money1"))
				cpord = rs("ord") : date1 = rs("date1")
				If date1&""="" Then
					sql2 = ",[DeliveryDate]" : sql3 = " '"&date1&"' ,"
				end if
				Set rs88 = cn.Execute("select top 1 title from product where ord="& cpord)
				cptitle = rs88(0).value
				Set rs88 = Nothing
				wxTitle = SerialNumber & cptitle & "维修单"
				If Len(wxTitle)>100 Then wxTitle = Left(wxTitle,100)
				sql = "INSERT INTO RepairOrder " &_
				"([Title],[SerialNumber],[ProcessID],[DealPerson],[Status],[Repair_sl],[Repair_sl_list],[ProID]," &_
				"[Num],[Cost]"& sql2 &",[Contract],[ContractList],[Del],[AddUser]) " &_
				"VALUES " &_
				"(  "&_
				" '"&wxTitle&"' , " &_
				" '"&SerialNumber&"' , " &_
				" "&ProcessID&" , "&_
				" "&DealPerson&" , "&_
				" 0 , " &_
				" "&slord&" , " &_
				" "&slid&" , " &_
				" "&cpord&" , " &_
				" "&pgnum&" , " &_
				" "&pgmoney&" , " & sql3 &_
				" "&htord&" , " &_
				" "&htlid&" , " &_
				" 1 , " &_
				" "& Info.User &" " &_
				")"
				cn.Execute(sql)
				wxid = cn.Execute("SELECT ISNULL(SCOPE_IDENTITY(),0) ID")(0)
				sql = "INSERT INTO Copy_ProcessSet SELECT [Id], [Title], [IsUse], [Ranking], [Type], "&wxid&",1,[AddUser], [AddTime] " &_
				"FROM Comm_ProcessSet WHERE ID = "&ProcessID&" "
				cn.Execute(sql)
				sql = "INSERT INTO Copy_ProcessNodeSet SELECT [Id] ,[Title] ,[NodeType] ,[Duration] ,[Ranking] ,[Relation] ,[DealPerson] ," &_
				"[CurrentNodeType] ,[BeforeNodeType] ,[Remark] ,[RelatedBill] ,[ProcessSet] ,[Type] , "&wxid&",1,[AddUser] ,[AddTime] " &_
				"FROM Comm_ProcessNodeSet WHERE ProcessSet = "&ProcessID&" "
				cn.Execute(sql)
				sql = "INSERT INTO Copy_NodesMap SELECT [Id] ,[NodeID] ,[NextNodeID] ,[IsSelected] ,[ProcessSet],"&wxid&",1,[AddUser] FROM Comm_NodesMap WHERE ProcessSet = "&ProcessID&" "
				cn.Execute(sql)
				sql = "INSERT INTO Copy_CustomFields SELECT [ID] ,[TName] ,[IsMaster] ,[FOrder] ,[FName] ,[FType] ,[MustFillin] ,[OptionID], " &_
				"[FStyle] ,[IsUsing] ,[CanExport] ,[CanInport] ,[CanSearch] ,[CanStat],[del],"&wxid&" FROM [ERP_CustomFields] WHERE " &_
				"EXISTS (SELECT 1 FROM Comm_ProcessNodeSet WHERE ProcessSet = "&ProcessID&" " &_
				"HAVING TName BETWEEN ISNULL(300000+MIN(ID),0)  AND ISNULL(300000+MAX(ID),0) ) "
				cn.Execute(sql)
				If htlid>0 Then
					Dim wxNum
					wxNum = getCPwxNum(cpord, htlid)
					If wxNum&""<>"" Then
						sql = "update contractlist set wxNum="& wxNum &" where id="& htlid
						cn.Execute(sql)
					end if
				end if
				rs.movenext
			wend
			rs.close
			set rs = nothing
		end if
	end function
	Function getPGNum(slid)
		Dim rs, pgNum
		pgNum = 0
		If slid&""<>"" Then
			Set rs = cn.execute("select isnull(num2,0) from repair_sl_list where del=1 and id="& slid)
			If rs.eof = False Then
				pgNum = CDbl(rs(0))
			end if
			rs.close
			set rs = nothing
		end if
		getPGNum = pgNum
	end function
	Function getPGstatus(slord)
		Dim rs, slNum, pgNum, complete1
		slNum = 0 : pgNum = 0 : complete1 = 0
		If slord&""<>"" Then
			Set rs = cn.execute("select isnull(SUM(isnull(num1,0)),0),isnull(SUM(isnull(num2,0)),0) from repair_sl_list where del=1 and repair_sl="& slord)
			If rs.eof = False Then
				slNum = CDbl(rs(0)) : pgNum = CDbl(rs(1))
			end if
			rs.close
			set rs = nothing
		end if
		If slNum>0 Then
			If slNum = pgNum Then
				complete1 = 2
			ElseIf slNum > pgNum And pgNum>0 Then
				complete1 = 1
			ElseIf pgNum = 0 Then
				complete1 =0
			end if
		else
			complete1 = 0
		end if
		getPGstatus = complete1
	end function
	Function getCPwxNum(cpord, htListid)
		Dim rs, wxNum
		wxNum = 0
		If cpord&""<>"" And htListid&""<>"" Then
			Set rs = cn.execute("select isnull(sum(Num),0) from RepairOrder where del=1 and ProID="& cpord &" and contractlist="& htListid)
			If rs.eof = False Then
				wxNum = CDbl(rs(0))
			end if
			rs.close
			set rs = nothing
		end if
		getCPwxNum = wxNum
	end function
	Function RepairPJMXToHtml(mode, repID)
		dim rs, rs_zdy, len_rszdy, i, sql, currCate, strWhere, hjIndex1, proID
		dim z5Select, z6Select, set_open, widthkd
		currCate = session("personzbintel2007")
		If currCate&"" = "" Then currCate = 0
		hjIndex1 = 1
		Select Case mode
		Case "pjMxShow1", "pjMxShow2" : sql = "select id,title,name,sort,sorce,set_open,kd from zdymx where sort1=91 and set_open=1 order by gate1 asc"
		Case "AddPjMx", "EditPjMx" : sql = "select id,title,name,sort,sorce,set_open from zdymx where sort1=91 order by gate1 asc"
		End Select
		set rs = conn.execute(sql)
		if not rs.eof then
			rs_zdy = rs.GetRows()
		end if
		rs.close
		set rs = nothing
		if isArray(rs_zdy) then
			len_rszdy = ubound(rs_zdy,2)
		else
			len_rszdy = -1
			len_rszdy = ubound(rs_zdy,2)
		end if
		Select Case mode
		Case "pjMxShow1"
		Response.write "" & vbcrlf & "      <table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "    <tr class=""top"">" & vbcrlf & "        <td colspan=""13"">新增配件</td>" & vbcrlf & "    </tr>" & vbcrlf & "    <tr class=""tableHead"">" & vbcrlf & "       "
		for i=0 to len_rszdy
			Response.write "" & vbcrlf & "        <th>"
			Response.write rs_zdy(1,i)
			Response.write "</th>" & vbcrlf & " "
		next
		Response.write "      " & vbcrlf & "    </tr>" & vbcrlf & "       "
		Referer              = Request("Referer")
		PID                  = Request("PID")
		NID                  = Request("NID")
		repSl_list   = Request("repSl_list")
		strWhere = "(a.del = 7 AND a.AddUser = "&currCate&") OR (a.RepairOrder = "&repID&" AND a.ProcessID = "&PID&" AND a.NodeID = "&NID&" AND a.del = 1)"
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT b.Title proName,b.Order1 proSN,b.Type1 proModel,c.sort1 proUnit,a.[ProID] ,a.[Num] ,a.[UseDate] ,a.[Remark] ," &_
		"a.[zdy1] ,a.[zdy2] ,a.[zdy3] ,a.[zdy4] ,(SELECT sort1 FROM sortonehy WHERE ID = a.[zdy5]) zdy5 ,(SELECT sort1 FROM sortonehy WHERE ID = a.[zdy6]) zdy6 ,a.[NodeID] ,a.[ProcessID] ,a.[RepairOrder] " &_
		"FROM RepairNewParts a " &_
		"LEFT JOIN Product b ON b.ord = a.proID " &_
		"LEFT JOIN sortonehy c ON c.id = a.Unit " &_
		"WHERE "&strWhere&" " &_
		"ORDER BY a.ID ASC"
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While rs.Eof = False
				proName      = rs("proName")
				proSN        = rs("proSN")
				proModel     = rs("proModel")
				proUnit      = rs("proUnit")
				Num =zbcdbl( rs("Num"))
				UseDate = rs("UseDate")
				Remark = rs("Remark")
				zdy1 = rs("zdy1")
				zdy2 = rs("zdy2")
				zdy3 = rs("zdy3")
				zdy4 = rs("zdy4")
				zdy5 = rs("zdy5")
				zdy6 = rs("zdy6")
				Response.write "      " & vbcrlf & "    <tr class=""has-border"">" & vbcrlf & "      "
				zdy6 = rs("zdy6")
				for i=0 to len_rszdy
					Select Case rs_zdy(4,i)&""
					Case "1" : Response.write "<td class='t-left'>"& proName &"</td>"
'Select Case rs_zdy(4,i)&""
					Case "2" : Response.write "<td class='t-left'>"& proSN &"</td>"
'Select Case rs_zdy(4,i)&""
					Case "3" : Response.write "<td class='t-left'>"& proModel &"</td>"
'Select Case rs_zdy(4,i)&""
					Case "4" : Response.write "<td>"& proUnit &"</td>"
					Case "5" : Response.write "<td>"& FormatNumber(Num,numScale,-1) &"</td>" : hjIndex1 = i+1
'Case "4" : Response.write "<td>"& proUnit &"</td>"
					Case "6" : Response.write "<td>"& Remark &"</td>"
					Case "7" : Response.write "<td>"& UseDate &"</td>"
					Case "8" : Response.write "<td>"& zdy1 &"</td>"
					Case "9" : Response.write "<td>"& zdy2 &"</td>"
					Case "10" : Response.write "<td>"& zdy3 &"</td>"
					Case "11" : Response.write "<td>"& zdy4 &"</td>"
					Case "12" : Response.write "<td>"& zdy5 &"</td>"
					Case "13" : Response.write "<td>"& zdy6 &"</td>"
					End Select
				next
				Response.write "" & vbcrlf & "     </tr>  " & vbcrlf & " "
				rs.movenext
			Loop
			total = Conn.Execute("SELECT SUM(Num) total FROM RepairNewParts a WHERE "&strWhere&" ")(0)
			Response.write "" & vbcrlf & "     <tr>" & vbcrlf & "            "
			if hjIndex1 > 1 then
				Response.write "" & vbcrlf & "             <td colspan="""
				Response.write hjIndex1-1
				Response.write "" & vbcrlf & "             <td colspan="""
				Response.write """>合计 " & vbcrlf & "           "
				If Referer <> "dealContent" Then
					Response.write "" & vbcrlf & "             <img src=""../images/jiantou.gif""><a href=""#"" onClick=""javascript:window.open('proListAdd.asp?repID="
					Response.write repID
					Response.write "&repSl_list="
					Response.write repSl_list
					Response.write "&PID="
					Response.write PID
					Response.write "&NID="
					Response.write NID
					Response.write "','plancor5','width=1200,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=30');return false;"" title=""点击编辑明细""><font class=""blue2"">重新编辑</font></a>" & vbcrlf & "               "
				end if
				Response.write "" & vbcrlf & "             </td>" & vbcrlf & "           "
			end if
			Response.write "     " & vbcrlf & "                <td>"
			Response.write FormatNumber(total,numScale,-1)
			Response.write "     " & vbcrlf & "                <td>"
			Response.write "</td>" & vbcrlf & "                "
			for i = hjIndex1 to len_rszdy
				Response.write "" & vbcrlf & "             <td>&nbsp;</td>" & vbcrlf & "         "
			next
			Response.write "" & vbcrlf & "     </tr>" & vbcrlf & "" & vbcrlf & "   "
		else
			Response.write "" & vbcrlf & "     <tr>" & vbcrlf & "            <td colspan="""
			Response.write len_rszdy+1
			Response.write "" & vbcrlf & "     <tr>" & vbcrlf & "            <td colspan="""
			Response.write """>暂无明细 " & vbcrlf & "               "
			If Referer <> "dealContent" Then
				Response.write "" & vbcrlf & "             <img src=""../images/jiantou.gif""><a href=""#"" onClick=""javascript:window.open('proListAdd.asp?repID="
				Response.write repID
				Response.write "&repSl_list="
				Response.write repSl_list
				Response.write "&PID="
				Response.write PID
				Response.write "&NID="
				Response.write NID
				Response.write "','plancor5','width=' + 1000 + ',height=' + 700 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=30');return false;"" title=""点击添加产品明细""><font class=""blue2"">添加产品明细</font></a>" & vbcrlf & "            "
				Response.write NID
			end if
			Response.write "" & vbcrlf & "             </td>" & vbcrlf & "   </tr>" & vbcrlf & "   "
		end if
		rs.close
		set rs = nothing
		Response.write "    " & vbcrlf & " </table>" & vbcrlf & "        "
		Case "pjMxShow2"
		Referer     = Request("Referer")
		If Referer = "recycle" Then
			delVal = 0
		else
			delVal = 1
		end if
		Response.write "" & vbcrlf & "     <table border=""0"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "               <tr class=""top"" style=""height:80px;"">" & vbcrlf & "                       <td colspan="""
		Response.write len_rszdy+3
		Response.write """><a href=""javascript:void(0);"">新增配件</a></td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr><td colspan="""
		Response.write len_rszdy+3
		Response.write """>" & vbcrlf & "                        <table class=""detailTable"" width=""100%"">" & vbcrlf & "                    <tr class=""top"">" & vbcrlf & "                  "
		for i=0 to len_rszdy
			widthkd = rs_zdy(6,i)
			Select Case rs_zdy(4,i)&""
			Case "5"
			Response.write "" & vbcrlf & "                             <td style=""width:"
			Response.write widthkd
			Response.write "px"">"
			Response.write rs_zdy(1,i)
			Response.write "</td>" & vbcrlf & "                                <td style=""width:80px"" align=""center"">生成</td>" & vbcrlf & "                     "
			Case Else
			Response.write "" & vbcrlf & "                             <td style=""width:"
			Response.write widthkd
			Response.write "px"">"
			Response.write rs_zdy(1,i)
			Response.write "</td>" & vbcrlf & "                        "
			End Select
		next
		Response.write "                             " & vbcrlf & "                                <td style=""width:100px"" align=""center"">合同状态</td>                " & vbcrlf & "                        </tr>" & vbcrlf & "                   "
		PID         = Request("PID")
		NID         = Request("NID")
		strWhere = "a.RepairOrder = "& repID &" AND a.del = "&delVal&" "
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT b.Title proName,b.Order1 proSN,b.Type1 proModel,c.sort1 proUnit,a.[ProID] ,isnull(a.[Num],0) Num ,a.[UseDate] ,a.[Remark] ," &_
		"a.[zdy1] ,a.[zdy2] ,a.[zdy3] ,a.[zdy4] ,(SELECT sort1 FROM sortonehy WHERE ID = a.[zdy5]) zdy5 ," &_
		"(SELECT sort1 FROM sortonehy WHERE ID = a.[zdy6]) zdy6 ,a.[NodeID] ,a.[ProcessID] ,a.[RepairOrder],d.date1 DeliveryDate, " &_
		"(CASE d.baoxiu WHEN 0 THEN '保内' WHEN 1 THEN '保外' WHEN 2 THEN '其他' END) baoxiu,ISNULL(e.num1,0) scNum " &_
		"FROM RepairNewParts a " &_
		"LEFT JOIN Product b ON b.ord = a.proID " &_
		"LEFT JOIN sortonehy c ON c.id = a.Unit " &_
		"LEFT JOIN repair_sl_list d ON d.id = a.repair_sl_list " &_
		"LEFT JOIN contractlist e ON e.repairNewPartsId = a.id AND e.del = 1 " &_
		"WHERE "&strWhere&" " &_
		"ORDER BY a.ID ASC"
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While rs.Eof = False
				proName     = rs("proName")
				proSN       = rs("proSN")
				proModel    = rs("proModel")
				proUnit     = rs("proUnit")
				Num = CDbl(rs("Num"))
				DeliveryDate        = rs("DeliveryDate")
				UseDate = rs("UseDate")
				Remark = rs("Remark")
				zdy1 = rs("zdy1")
				zdy2 = rs("zdy2")
				zdy3 = rs("zdy3")
				zdy4 = rs("zdy4")
				zdy5 = rs("zdy5")
				zdy6 = rs("zdy6")
				baoxiu      = rs("baoxiu")
				scNum       = CDbl(rs("scNum"))
				If scNum = 0 Then
					htStatus = "未生成"
				ElseIf scNum > Num Then
					htStatus = "超额生成"
				ElseIf Num > scNum AND scNum > 0 Then
					htStatus = "部分生成"
				ElseIf Num = scNum AND scNum > 0 Then
					htStatus = "生成完毕"
				end if
				Response.write "      " & vbcrlf & "                                       <tr>" & vbcrlf & "                                    "
				for i=0 to len_rszdy
					Select Case rs_zdy(4,i)&""
					Case "1" : Response.write "<td class='t-left'>"& proName &"</td>"
'Select Case rs_zdy(4,i)&""
					Case "2" : Response.write "<td class='t-left'>"& proSN &"</td>"
'Select Case rs_zdy(4,i)&""
					Case "3" : Response.write "<td class='t-left'>"& proModel &"</td>"
'Select Case rs_zdy(4,i)&""
					Case "4" : Response.write "<td>"& proUnit &"</td>"
					Case "5"
					Response.write "<td>"& FormatNumber(Num,numScale,-1) &"</td>" : hjIndex1 = i+1
'Case "5"
					Response.write "<td>"& FormatNumber(scNum,numScale,-1) &"</td>"
'Case "5"
					Case "6" : Response.write "<td>"& Remark &"</td>"
					Case "7" : Response.write "<td>"& UseDate &"</td>"
					Case "8" : Response.write "<td>"& zdy1 &"</td>"
					Case "9" : Response.write "<td>"& zdy2 &"</td>"
					Case "10" : Response.write "<td>"& zdy3 &"</td>"
					Case "11" : Response.write "<td>"& zdy4 &"</td>"
					Case "12" : Response.write "<td>"& zdy5 &"</td>"
					Case "13" : Response.write "<td>"& zdy6 &"</td>"
					End Select
				next
				Response.write "" & vbcrlf & "                                             <td>"
				Response.write htStatus
				Response.write "</td>" & vbcrlf & "                                        </tr>  " & vbcrlf & "                         "
				rs.movenext
			Loop
			total = Conn.Execute("SELECT ISNULL(SUM(Num),0) total FROM RepairNewParts a WHERE "&strWhere&" ")(0)
			sql = "SELECT ISNULL(SUM(Num1),0) total FROM contractlist WHERE del = 1 AND RepairNewPartsID IN " &_
			"(SELECT ID FROM RepairNewParts a WHERE "&strWhere&") "
			scTotal = Conn.Execute(sql)(0)
			Response.write "" & vbcrlf & "                             <tr>" & vbcrlf & "                                    "
			if hjIndex1 > 1 then
				Response.write "" & vbcrlf & "                                     <td colspan="""
				Response.write hjIndex1-1
				Response.write "" & vbcrlf & "                                     <td colspan="""
				Response.write """ class=""t-right"">合计：</td>" & vbcrlf & "                                       "
				Response.write "" & vbcrlf & "                                     <td colspan="""
			end if
			Response.write "     " & vbcrlf & "                                        <td>"
			Response.write FormatNumber(total,numScale,-1)
			Response.write "     " & vbcrlf & "                                        <td>"
			Response.write "</td>" & vbcrlf & "                                        <td>"
			Response.write FormatNumber(scTotal,numScale,-1)
			Response.write "</td>" & vbcrlf & "                                        <td>"
			Response.write "</td>" & vbcrlf & "                                        "
			for i = hjIndex1 to len_rszdy
				Response.write "" & vbcrlf & "                                     <td>&nbsp;</td>" & vbcrlf & "                                 "
			next
			Response.write "" & vbcrlf & "                                     <td></td>" & vbcrlf & "                               </tr>" & vbcrlf & "" & vbcrlf & "                           "
		else
			Response.write "" & vbcrlf & "                             <tr>" & vbcrlf & "                                    <td colspan="""
			Response.write len_rszdy+3
			Response.write """ style=""text-align:center"">暂无明细</td>" & vbcrlf & "                           </tr>" & vbcrlf & "                           "
		end if
		rs.close
		set rs = nothing
		Response.write "    " & vbcrlf & "                         </table></td></tr>" & vbcrlf & "      </table>" & vbcrlf & "        "
		Case "AddPjMx"
		proID = repID
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT Title,Order1,Type1,ISNULL(Unit,'0') Unit,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6 " &_
		"FROM Product WHERE ord = "&proID&" "
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			proName             = rs("Title")
			proSN               = rs("Order1")
			proModel    = rs("Type1")
			proUnit             = rs("Unit")
			uList = Split(proUnit,",")
			uSelect = "<select name='proUnit'>"
			For i = 0 To UBound(uList)
				Set rs0 = server.CreateObject("adodb.recordset")
				sql0 = "SELECT sort1 FROM sortonehy WHERE id = "&uList(i)&" "
				rs0.Open sql0,conn,1,1
				If Not rs0.Eof Then
					uName = rs0("sort1")
					uSelect = uSelect & "<option value='"&uList(i)&"'>"&uName&"</option>"
				end if
				rs0.Close
				Set rs0 = Nothing
			next
			uSelect = uSelect & "</select>"
			zdy1                = rs("zdy1")
			zdy2                = rs("zdy2")
			zdy3                = rs("zdy3")
			zdy4                = rs("zdy4")
			zdy5                = rs("zdy5")
			Set rs0 = server.CreateObject("adodb.recordset")
			sql0 = "SELECT ID,sort1 FROM sortonehy WHERE gate2 = 2101 ORDER BY gate1 DESC"
			rs0.Open sql0,conn,1,1
			z5Select = "<select name='zdy5'>"
			If Not rs0.Eof Then
				Do While rs0.Eof = False
					ID = rs0("ID")
					sort1 = rs0("sort1")
					z5Select = z5Select &"<option value='"&ID&"' "
					If zdy5 = ID Then
						z5Select = z5Select &"selected"
					end if
					z5Select = z5Select &">"&sort1&"</option>"
					rs0.MoveNext
				Loop
			else
				z5Select = z5Select &"<option value=''></option>"
			end if
			z5Select = z5Select &"</select>"
			rs0.Close
			Set rs0 = Nothing
			zdy6                = rs("zdy6")
			Set rs0 = server.CreateObject("adodb.recordset")
			sql0 = "SELECT ID,sort1 FROM sortonehy WHERE gate2 = 2102 ORDER BY gate1 DESC"
			rs0.Open sql0,conn,1,1
			z6Select = "<select name='zdy6'>"
			If Not rs0.Eof Then
				Do While rs0.Eof = False
					ID = rs0("ID")
					sort1 = rs0("sort1")
					z6Select = z6Select &"<option value='"&ID&"' "
					If zdy6 = ID Then
						z6Select = z6Select &"selected"
					end if
					z6Select = z6Select &">"&sort1&"</option>"
					rs0.MoveNext
				Loop
			else
				z6Select = z6Select &"<option value=''></option>"
			end if
			z6Select = z6Select &"</select>"
			rs0.Close
			Set rs0 = Nothing
			Response.write "" & vbcrlf & "     <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "   "
			for i=0 to len_rszdy
				set_open = rs_zdy(5,i)
				If set_open&"" = "" Then set_open = 0
				Select Case rs_zdy(4,i)&""
				Case "1"
				Response.write "" & vbcrlf & "             <td class=""t-left"" "
'Case "1"
				Response.write iif(set_open&""="0"," style='display:none'","")
				Response.write "><input name=""listID"" type=""hidden"" value="""
				Response.write listID
				Response.write """ />"
				Response.write proName
				Response.write "<input name=""proID"" type=""hidden"" value="""
				Response.write proID
				Response.write """><span class=""del-btn""></span></td>" & vbcrlf & "        "
				Response.write proID
				Case "2" : Response.write "<td class='t-left' "& iif(set_open&""="0"," style='display:none'","") &">"& proSN &"</td>"
				Response.write proID
				Case "3" : Response.write "<td class='t-left' "& iif(set_open&""="0"," style='display:none'","") &">"& proModel &"</td>"
				Response.write proID
				Case "4" : Response.write "<td "& iif(set_open&""="0"," style='display:none'","") &">"& uSelect &"</td>"
				Case "5"
				Response.write "" & vbcrlf & "             <td "
				Response.write iif(set_open&""="0"," style='display:none'","")
				Response.write "><input name=""Num"" id=""num"
				Response.write proID
				Response.write """ style=""width: 50px; height: 19px; font-size: 9pt;"" onKeyUp=""value=value.replace(/[^\d\.]/g,'');checkDot('num"
				Response.write proID
				Response.write proID
				Response.write "','"
				Response.write numScale
				Response.write "');"" onFocus=""if(value==defaultValue){value='';this.style.color='#000'};"" onBlur=""if(!value){value=defaultValue;this.style.color='#000'};checkDot('num"
				Response.write proID
				Response.write "','"
				Response.write numScale
				Response.write "')""  type=""text"" maxLength=""20"" max=""20"" min=""1"" msg=""不能为空"" dataType=""Limit"" value="""
				Response.write FormatNumber(1,numScale,-1,0,0)
				Response.write """/></td>" & vbcrlf & "  "
				Case "6"
				Response.write "" & vbcrlf & "             <td "
				Response.write iif(set_open&""="0"," style='display:none'","")
				Response.write "><textarea name=""Remark"" id=""remark_"
				Response.write proID
				Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""50"" min=""0"" msg=""不要超过50个字"" datatype=""Limit"">"
				Response.write proID
				Response.write remark
				Response.write "</textarea></td>" & vbcrlf & "     "
				Case "7"
				Response.write "" & vbcrlf & "             <td style=""width:66px;"
				Response.write iif(set_open&""="0"," display:none","")
				Response.write """><input name=""UseDate"" id=""daysdate1_"
				Response.write proID
				Response.write "Pos"" style=""width: 66px; height: 19px; font-size: 9pt;"" onMouseUp=""toggleDatePicker('daysdate1_"
				Response.write proID
				Response.write proID
				Response.write "','date.UseDate_"
				Response.write proID
				Response.write "')"" msg=""日期格式不正确"" dataType=""Date"" format=""ymd"" value="""
				Response.write Date()
				Response.write """/><div id=""daysdate1_"
				Response.write proID
				Response.write """ style=""position: absolute;""/></td>" & vbcrlf & "        "
				Case "8"
				Response.write "" & vbcrlf & "             <td "
				Response.write iif(set_open&""="0"," style='display:none'","")
				Response.write "><textarea name=""zdy1"" id=""zdy1_"
				Response.write proID
				Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
				Response.write proID
				Response.write zdy1
				Response.write "</textarea></td>" & vbcrlf & "     "
				Case "9"
				Response.write " " & vbcrlf & "            <td "
				Response.write iif(set_open&""="0"," style='display:none'","")
				Response.write "><textarea name=""zdy2"" id=""zdy2_"
				Response.write proID
				Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
				Response.write proID
				Response.write zdy2
				Response.write "</textarea></td>" & vbcrlf & "     "
				Case "10"
				Response.write "" & vbcrlf & "             <td "
				Response.write iif(set_open&""="0"," style='display:none'","")
				Response.write "><textarea name=""zdy3"" id=""zdy3_"
				Response.write proID
				Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
				Response.write proID
				Response.write zdy3
				Response.write "</textarea></td>" & vbcrlf & "     "
				Case "11"
				Response.write " " & vbcrlf & "            <td "
				Response.write iif(set_open&""="0"," style='display:none'","")
				Response.write "><textarea name=""zdy4"" id=""zdy4_"
				Response.write proID
				Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
				Response.write proID
				Response.write zdy4
				Response.write "</textarea></td>" & vbcrlf & "     "
				Case "12" : Response.write "<td "& iif(set_open&""="0"," style='display:none'","") &">"& z5Select &"</td>"
				Case "13" : Response.write "<td "& iif(set_open&""="0"," style='display:none'","") &">"& z6Select &"</td>"
				End Select
			next
			Response.write "             " & vbcrlf & "        </tr>" & vbcrlf & "   "
		end if
		rs.close
		set rs = nothing
		Case "EditPjMx"
		PID                 = Request("PID")
		NID                 = Request("NID")
		Response.write "" & vbcrlf & "     <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" id=""proList"">" & vbcrlf & "        <tr class=""tableHead"">" & vbcrlf & "          "
		for i=0 to len_rszdy
			set_open = rs_zdy(5,i)
			If set_open&"" = "" Then set_open = 0
			Response.write "" & vbcrlf & "                     <th "
			Response.write iif(i=0," height='28'","")
			Response.write iif(set_open&""="0"," style='display:none'","")
			Response.write ">"
			Response.write rs_zdy(1,i)
			Response.write "</th>" & vbcrlf & "                "
		next
		Response.write "                     " & vbcrlf & "        </tr>" & vbcrlf & "   "
		strWhere = "(a.del = 7 AND a.AddUser = "& currCate &") OR (a.RepairOrder = "&repID&" AND a.ProcessID = "&PID&" AND a.NodeID = "&NID&" AND a.del = 1)"
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT a.ID listID,b.Title proName,b.Order1 proSN,b.Type1 proModel,a.Unit proUnit,a.[ProID] ,a.[Num] ,a.[UseDate] ,a.[Remark] ," &_
		"a.[zdy1] ,a.[zdy2] ,a.[zdy3] ,a.[zdy4] ,a.[zdy5] ,a.[zdy6] ,a.[NodeID] ,a.[ProcessID] ,a.[RepairOrder],ISNULL(d.ID,0) contractList " &_
		"FROM RepairNewParts a " &_
		"LEFT JOIN Product b ON b.ord = a.proID " &_
		"LEFT JOIN sortonehy c ON c.id = a.Unit " &_
		"LEFT JOIN contractlist d ON d.repairNewPartsId = a.ID AND d.del = 1 " &_
		"WHERE "&strWhere&" " &_
		"ORDER BY a.ID ASC"
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While rs.Eof = False
				listID                = rs("listID")
				proID                 = rs("proID")
				proName               = rs("proName")
				proSN         = rs("proSN")
				proModel      = rs("proModel")
				proUnit               = rs("proUnit")
				contractList = rs("contractList")
				uList                 = Split(proUnit,",")
				uSelect = "<select name='proUnit'>"
				For i = 0 To UBound(uList)
					Set rs0 = server.CreateObject("adodb.recordset")
					sql0 = "SELECT sort1 FROM sortonehy WHERE ID = "&uList(i)&" "
					rs0.Open sql0,conn,1,1
					If Not rs0.Eof Then
						uName = rs0("sort1")
						uSelect = uSelect & "<option value='"&uList(i)&"'>"&uName&"</option>"
					end if
					rs0.Close
					Set rs0 = Nothing
				next
				uSelect = uSelect & "</select>"
				Num  =zbcdbl( rs("Num"))
				UseDate = rs("UseDate")
				Remark = rs("Remark")
				zdy1 = rs("zdy1")
				zdy2 = rs("zdy2")
				zdy3 = rs("zdy3")
				zdy4 = rs("zdy4")
				zdy5 = rs("zdy5")
				Set rs0 = server.CreateObject("adodb.recordset")
				sql0 = "SELECT ID,sort1 FROM sortonehy WHERE gate2 = 2101 ORDER BY gate1 DESC"
				rs0.Open sql0,conn,1,1
				z5Select = "<select name='zdy5'>"
				If Not rs0.Eof Then
					Do While rs0.Eof = False
						ID = rs0("ID")
						sort1 = rs0("sort1")
						z5Select = z5Select &"<option value='"&ID&"' "
						If zdy5*1 = ID*1 Then
							z5Select = z5Select &"selected"
						end if
						z5Select = z5Select &">"&sort1&"</option>"
						rs0.MoveNext
					Loop
				else
					z5Select = z5Select &"<option value=''></option>"
				end if
				z5Select = z5Select &"</select>"
				rs0.Close
				Set rs0 = Nothing
				zdy6         = rs("zdy6")
				Set rs0 = server.CreateObject("adodb.recordset")
				sql0 = "SELECT ID,sort1 FROM sortonehy WHERE gate2 = 2102 ORDER BY gate1 DESC"
				rs0.Open sql0,conn,1,1
				z6Select = "<select name='zdy6'>"
				If Not rs0.Eof Then
					Do While rs0.Eof = False
						ID = rs0("ID")
						sort1 = rs0("sort1")
						z6Select = z6Select &"<option value='"&ID&"' "
						If zdy6*1 = ID*1 Then
							z6Select = z6Select &"selected"
						end if
						z6Select = z6Select &">"&sort1&"</option>"
						rs0.MoveNext
					Loop
				else
					z6Select = z6Select &"<option value=''></option>"
				end if
				z6Select = z6Select &"</select>"
				rs0.Close
				Set rs0 = Nothing
				Response.write "      " & vbcrlf & "        <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "   "
				for i=0 to len_rszdy
					set_open = rs_zdy(5,i)
					If set_open&"" = "" Then set_open = 0
					Select Case rs_zdy(4,i)&""
					Case "1"
					Response.write "" & vbcrlf & "              <td class=""t-left"" "
'Case "1"
					Response.write iif(set_open&""="0"," style='display:none'","")
					Response.write "><input name=""listID"" type=""hidden"" value="""
					Response.write listID
					Response.write """ />"
					Response.write proName
					Response.write "<input name=""proID"" type=""hidden"" value="""
					Response.write proID
					Response.write """  />"
					If contractList = 0 Then
						Response.write "<span class=""del-btn""></span>"
'If contractList = 0 Then
					end if
					Response.write "</td>" & vbcrlf & " "
					Case "2" : Response.write "<td class='t-left' "& iif(set_open&""="0"," style='display:none'","") &">"& proSN &"</td>"
					Response.write "</td>" & vbcrlf & " "
					Case "3" : Response.write "<td class='t-left' "& iif(set_open&""="0"," style='display:none'","") &">"& proModel &"</td>"
					Response.write "</td>" & vbcrlf & " "
					Case "4" : Response.write "<td "& iif(set_open&""="0"," style='display:none'","") &">"& uSelect &"</td>"
					Case "5"
					Response.write "" & vbcrlf & "              <td "
					Response.write iif(set_open&""="0"," style='display:none'","")
					Response.write "><input name=""Num"" id=""num"
					Response.write proID
					Response.write """ style=""width: 50px; height: 19px; font-size: 9pt;"" onKeyUp=""value=value.replace(/[^\d\.]/g,'');checkDot('num"
					Response.write proID
					Response.write proID
					Response.write "','"
					Response.write numScale
					Response.write "');"" onFocus=""if(value==defaultValue){value='';this.style.color='#000'};"" onBlur=""if(!value){value=defaultValue;this.style.color='#000'};checkDot('num"
					Response.write proID
					Response.write "','"
					Response.write numScale
					Response.write "')""  type=""text"" maxLength=""20"" max=""20"" min=""1"" msg=""不能为空"" dataType=""Limit"" value="""
					Response.write FormatNumber(Num,numScale,-1,0,0)
					Response.write """/></td>" & vbcrlf & "  "
					Case "6"
					Response.write "             " & vbcrlf & "                <td "
					Response.write iif(set_open&""="0"," style='display:none'","")
					Response.write "><textarea name=""Remark"" id=""remark_"
					Response.write proID
					Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""50"" min=""0"" msg=""不要超过50个字"" datatype=""Limit"">"
					Response.write proID
					Response.write remark
					Response.write "</textarea></td>" & vbcrlf & "     "
					Case "7"
					Response.write "" & vbcrlf & "             <td style=""width:66px;"
					Response.write iif(set_open&""="0","display:none;","")
					Response.write """><input name=""UseDate"" id=""daysdate1_"
					Response.write proID
					Response.write "Pos"" style=""width: 60px; height: 19px; font-size: 9pt;"" onMouseUp=""toggleDatePicker('daysdate1_"
					Response.write proID
					Response.write proID
					Response.write "','date.UseDate_"
					Response.write proID
					Response.write "')"" msg=""日期格式不正确"" dataType=""Date"" format=""ymd"" value="""
					Response.write UseDate
					Response.write """/><div id=""daysdate1_"
					Response.write proID
					Response.write """ style=""position: absolute;""/></td>" & vbcrlf & "        "
					Case "8"
					Response.write "" & vbcrlf & "             <td "
					Response.write iif(set_open&""="0"," style='display:none'","")
					Response.write "><textarea name=""zdy1"" id=""zdy1_"
					Response.write proID
					Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
					Response.write proID
					Response.write zdy1
					Response.write "</textarea></td>" & vbcrlf & "     "
					Case "9"
					Response.write " " & vbcrlf & "            <td "
					Response.write iif(set_open&""="0"," style='display:none'","")
					Response.write "><textarea name=""zdy2"" id=""zdy2_"
					Response.write proID
					Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
					Response.write proID
					Response.write zdy2
					Response.write "</textarea></td>" & vbcrlf & "     "
					Case "10"
					Response.write "" & vbcrlf & "             <td "
					Response.write iif(set_open&""="0"," style='display:none'","")
					Response.write "><textarea name=""zdy3"" id=""zdy3_"
					Response.write proID
					Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
					Response.write proID
					Response.write zdy3
					Response.write "</textarea></td>" & vbcrlf & "     "
					Case "11"
					Response.write " " & vbcrlf & "            <td "
					Response.write iif(set_open&""="0"," style='display:none'","")
					Response.write "><textarea name=""zdy4"" id=""zdy4_"
					Response.write proID
					Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
					Response.write proID
					Response.write zdy4
					Response.write "</textarea></td>" & vbcrlf & "     "
					Case "12" : Response.write "<td "& iif(set_open&""="0"," style='display:none'","") &">"& z5Select &"</td>"
					Case "13" : Response.write "<td "& iif(set_open&""="0"," style='display:none'","") &">"& z6Select &"</td>"
					End Select
				next
				Response.write "                     " & vbcrlf & "        </tr>" & vbcrlf & "   "
				rs.movenext
			Loop
			total = Conn.Execute("SELECT SUM(Num) total FROM RepairNewParts a WHERE "&strWhere&" ")(0)
		else
			Response.write "" & vbcrlf & "                     <tr id=""noList""><td colspan="""
			Response.write len_rszdy+1
			Response.write "" & vbcrlf & "                     <tr id=""noList""><td colspan="""
			Response.write """ class=""t-left"">无产品明细！</td></tr>" & vbcrlf & "     "
			Response.write "" & vbcrlf & "                     <tr id=""noList""><td colspan="""
		end if
		rs.close
		set rs = nothing
		Response.write "        " & vbcrlf & "     </table>" & vbcrlf & "        "
		End Select
	end function
	
	dim CurrProductAttrsHandler
	Function isOpenProductAttr
		isOpenProductAttr = (ZBRuntime.MC(213104) and conn.execute("select nvalue from home_usConfig where name='ProductAttributeTactics' and nvalue=1 ").eof=false)
	end function
	function IsApplyProductAttr(ord, AttrID)
		dim SearchText: SearchText = "(ProductAttr1>0 or ProductAttr2>0)"
		if AttrID > 0 then SearchText = "(ProductAttr1="& AttrID & " or ProductAttr2="& AttrID & ")"
		dim cmdtext
		cmdtext = "select top 1 1 x from contractlist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from kuoutlist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from kuoutlist2 where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from kuinlist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from contractthlist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from kumovelist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from caigoulist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from ku where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
		"     union all   "&_
		"     select top 1 1 from bomlist where " & SearchText & " and (Product=" & ord & " or "& ord &" = 0) " &_
		"     union all   "&_
		"     select top 1 1 from bom where " & SearchText & " and (Product=" & ord & " or "& ord &" = 0) " &_
		"     union all   "&_
		"     select top 1 1 from BOM_Structure_List where " & SearchText & " and (ProOrd=" & ord & " or "& ord &" = 0) "
		IsApplyProductAttr =  (conn.execute(cmdtext).eof=false)
	end function
	function ProductAttrsCmdText(ord , loadmodel)
		dim CmdText, cmdwhere
		if loadmodel = "by_fields" then cmdwhere = " and st.pid = 0 "
		if loadmodel = "by_config" then cmdwhere = " and st.isstop = 0 "
		CmdText = "select 1 from product p  with(nolock) inner join menu m  with(nolock) on m.id = p.sort1 inner join Shop_GoodsAttr st  with(nolock) on st.proCategory = m.RootId and st.pid = 0 where p.ord = " & ord
		if conn.execute(CmdText).eof=false then
			CmdText = "select st.id ,st.pid ,st.title , st.sort ,st.isstop,  isnull(st.isTiled,0)isTiled "&_
			"   from product p  with(nolock)  "&_
			"   inner join menu m  with(nolock) on m.id = p.sort1 "&_
			"   inner join Shop_GoodsAttr st  with(nolock) on st.proCategory = m.RootId " & cmdwhere &"   "&_
			"   where p.ord = " & ord &" "&_
			"   order by st.isTiled desc,st.pid ,st.sort desc , st.id desc"
		else
			CmdText ="select st.id ,st.pid , st.title , st.sort ,st.isstop, isnull(st.isTiled,0)isTiled "&_
			"   from Shop_GoodsAttr st  with(nolock) "&_
			"   where st.proCategory = -1 "& cmdwhere &" "&_
			"   from Shop_GoodsAttr st  with(nolock) "&_
			"   order by st.isTiled desc,st.pid ,st.sort desc , st.id desc"
		end if
		ProductAttrsCmdText = CmdText
	end function
	function ProductAttrsByOrd(ord)
		dim attrs , CmdText
		CmdText = ProductAttrsCmdText(ord , "by_fields")
		set ProductAttrsByOrd = conn.execute(CmdText)
	end function
	Function GetProductAttr1Title(ord)
		Dim attrs ,s : s= "产品属性1"
		set attrs =ProductAttrsByOrd(ord)
		while attrs.eof=false
			if attrs("isTiled").value=1 then s = attrs("title").value
			attrs.movenext
		wend
		attrs.close
		GetProductAttr1Title = s
	end function
	Function GetProductAttr2Title(ord)
		Dim attrs ,s : s= "产品属性2"
		set attrs =ProductAttrsByOrd(ord)
		while attrs.eof=false
			if attrs("isTiled").value&""<>"1" then s = attrs("title").value
			attrs.movenext
		wend
		attrs.close
		GetProductAttr2Title = s
	end function
	function GetProductAttrNameById(productAttrId)
		if productAttrId<>"" and productAttrId<>"0" then
			dim rs7
			set rs7=server.CreateObject("adodb.recordset")
			sql7="select title from Shop_GoodsAttr where id="&productAttrId&""
			rs7.open sql7,conn,1,1
			if rs7.eof then
				GetProductAttrNameById=""
			else
				GetProductAttrNameById=rs7("title")
			end if
			rs7.close
			set rs7=nothing
		else
			GetProductAttrNameById=""
		end if
	end function
	function GetProductAttrOption(ord,isTiled)
		dim rs7 , hasAttr
		hasAttr = false
		set rs7 = ProductAttrsByOrd(ord)
		while rs7.eof=false
			if rs7("isTiled").value &""= isTiled&"" then
				set GetProductAttrOption = conn.execute(" select title,id from (select '' as title, 0 as id,999999 sort union all select title, id ,sort from Shop_GoodsAttr where isstop = 0 and pid = "&rs7("id").value  &") a order by  sort desc , id desc ")
				hasAttr = true
			end if
			rs7.movenext
		wend
		rs7.close
		if hasAttr=false then set GetProductAttrOption = conn.execute("select top  0 '' title , 0 id ")
	end function
	class ProductAttrCellClass
		public Attr1
		public Num
		public BillListId
		Public ParentListId
		public  function  GetJSON
			GetJSON = "{num:" &  Num & ",billistid:" & BillListId & ",attr1:" &  clng("0" & Attr1) & ",parentbilllistid:" & ParentListId & "}"
		end function
		public  sub  SetJson(byval  json)
			dim i, ks
			dim s : s = mid(json,2, len(json)-2)
'dim i, ks
			dim items :  items =  split(s, ",")
			for i = 0 to  ubound(items)
				ks = split(items(i), ":")
				select case ks(0)
				case "attr1" :   Attr1 = clng("0" & ks(1))
				case "num" :   Num = cdbl(ks(1))
				case "billistid" :   me.BillListId = clng(ks(1))
				case "parentbilllistid" :
				If ks(1)&"" = "" Then me.ParentListId = 0 Else me.ParentListId = CDBL(ks(1))
				end select
			next
			if err.number<>0 then
				Response.write "【" & json & "|" &  ubound(items) & "|"  & BillListId& "】"
			end if
		end sub
	end class
	class ProductAttrConfigCollection
		public id
		public title
		public options
		public sub Class_Initialize
			options = split("",",")
		end sub
		public sub Addtem(byval title,  byval id,  byval istop)
			dim c: c =ubound(options) + 1
'public sub Addtem(byval title,  byval id,  byval istop)
			redim preserve  options(c)
			options(c) = split( id & chr(1) & title & chr(1) & istop,   chr(1))
			options(c)(0) = clng( options(c)(0) )
			options(c)(2) = clng( "0" & options(c)(2) )
		end sub
		public sub RemoveAt(index)
			dim         j , i, c
			j = -1
'dim         j , i, c
			c = UBound(options)
			For i = 0 To c
				If i <> index Then
					j = j + 1
'If i <> index Then
					options(j) =options(i)
				end if
			next
			if j >=0 then
				redim preserve options(j)
			else
				options = split("",",")
			end if
		end sub
	end class
	class ProductAttrCellCollection
		public Cells
		public Attr2
		public SumNum
		public BatchId
		public Attr1Configs
		public Attr2Configs
		private currrs
		public  LoadModel
		public MxpxId
		public OldListData
		private isOpened
		private currlistrs
		public  StrongInherit
		public sub Class_Initialize
			set Attr1Configs =  nothing
			set Attr2Configs =  nothing
			LoadModel = "by_config"
			Cells = split("",",")
			isOpened = true
			StrongInherit = false
			set currlistrs = nothing
		end sub
		public function InitByNoOpened (byref rs)
			isOpened = false
			set currlistrs= rs
		end function
		public function Items(byval itemname)
			dim i, ns
			if isOpened = false then
				on error resume next
				if  not currlistrs is nothing then
					Items = currlistrs(itemname).value
				end if
				exit function
			end if
			if isarray(OldListData) then
				for i = 0 to ubound(OldListData)
					ns = split(OldListData(i), chr(1))
					if lcase(ns(0)) = lcase(itemname) then
						Items = ns(1)
						exit function
					end if
				next
			end if
			Items = ""
		end function
		public sub Bind(byval rs)
			SumNum =   0
			BatchId = rs("ProductAttrBatchId").value
			Attr2 = clng("0" & rs("ProductAttr2").value)
			Cells = split("",",")
			set currrs =  rs
		end sub
		public sub AddCell(ByRef listid,ByRef attr1Id, ByRef numv, ByRef parentlistid)
			dim obj
			set obj = new ProductAttrCellClass
			numv = cdbl(numv & "")
			obj.BillListId =  listid
			obj.ParentListId =  parentlistid
			obj.Num =  numv
			obj.Attr1 =  attr1Id
			SumNum = SumNum + numv
'obj.Attr1 =  attr1Id
			dim c : c =ubound(cells) + 1
'obj.Attr1 =  attr1Id
			redim preserve cells(c)
			set  cells(c) =  obj
			call  Update
		end sub
		public  function  GetJSON
			dim json, c,  i
			json = "{batchid:" & BatchId & "," &_
			"attr2:" & Attr2 & "," &_
			"sumnum:" & sumnum & "," &_
			"cells:["
			c = ubound(cells)
			for i = 0 to c
				if i>0 then json = json & ","
				json = json  & cells(i).GetJson
			next
			json = json & "]"
			GetJSON = json
		end function
		public  function  LoadJSON (byval jsondata)
			dim s : s = split(jsondata,  ",cells:")
			dim baseinfo:  baseinfo = mid(s(0), 2,  len(s(0))-1)
'dim s : s = split(jsondata,  ",cells:")
			dim cellsinfo :  cellsinfo = mid(s(1), 2,  len(s(1))-2)
'dim s : s = split(jsondata,  ",cells:")
			dim i, bi,  bs :  bs = split(baseinfo, ",")
			for i = 0 to ubound(bs)
				bi = split(bs(i), ":")
				select case bi(0)
				case "attr2" :  attr2 =  clng("0" & bi(1))
				case "batchid" :  batchid =  clng("0" & bi(1))
				case "sumnum" :  sumnum =  cdbl(bi(1))
				end select
			next
			dim cellsinfos :  cellsinfos = split(cellsinfo, "},{")
			dim  c : c = ubound(cellsinfos)
			if c = -1 then
'dim  c : c = ubound(cellsinfos)
				cells =  split("",",")
			else
				dim cjson
				redim cells(c)
				for i = 0 to c
					cjson = cellsinfos(i)
					if i <> 0 then  cjson = "{" & cjson
					if i <> c  then cjson =  cjson & "}"
					set cells(i) = new ProductAttrCellClass
					cells(i).SetJson cjson
				next
			end if
		end function
		private  sub Update
			currrs("ProductAttrsJson").value  = GetJSON()
			currrs.update
		end sub
		public sub  DelNullDataConfig
			dim i, ii,  exists
			if Attr2 =0 then set Attr2Configs =  nothing
			if not Attr1Configs is nothing then
				for i = ubound(Attr1Configs.options) to 0 step -1
'if not Attr1Configs is nothing then
					exists = false
					for ii = 0 to ubound(Cells)
						if Cells(ii).Attr1  =  Attr1Configs.options(i)(0) then
							exists  = true :  exit for
						end if
					next
					if exists = false then
						Attr1Configs.RemoveAt(i)
					end if
				next
				if ubound(Attr1Configs.options) = - 1 then  set Attr1Configs =  nothing
				Attr1Configs.RemoveAt(i)
			end if
			if not Attr2Configs is nothing then
				for i = ubound(Attr2Configs.options) to 0 step -1
'if not Attr2Configs is nothing then
					exists = false
					for ii = 0 to ubound(Cells)
						if attr2  =  Attr2Configs.options(i)(0) then
							exists  = true :  exit for
						end if
					next
					if exists = false and Attr2Configs.options(i)(2)=1 then
						Attr2Configs.RemoveAt(i)
					end if
				next
				if ubound(Attr2Configs.options) = - 1 then  set Attr2Configs =  nothing
				Attr2Configs.RemoveAt(i)
			end if
		end sub
		public sub  DelNullDataStopConfig
			dim i, ii,  exists
			if not Attr1Configs is nothing then
				for i = ubound(Attr1Configs.options) to 0 step -1
'if not Attr1Configs is nothing then
					exists = false
					for ii = 0 to ubound(Cells)
						if Cells(ii).Attr1  =  Attr1Configs.options(i)(0) then
							exists  = true :  exit for
						end if
					next
					if exists = false and Attr1Configs.options(i)(2)=1 then
						Attr1Configs.RemoveAt(i)
					end if
				next
				if ubound(Attr1Configs.options) = - 1 then
					Attr1Configs.RemoveAt(i)
					set Attr1Configs =  nothing
				end if
			end if
			if not Attr2Configs is nothing then
				for i = ubound(Attr2Configs.options) to 0 step -1
'if not Attr2Configs is nothing then
					exists = false
					for ii = 0 to ubound(Cells)
						if attr2  =  Attr2Configs.options(i)(0) then
							exists  = true :  exit for
						end if
					next
					if exists = false and Attr2Configs.options(i)(2)=1 then
						Attr2Configs.RemoveAt(i)
					end if
				next
				if ubound(Attr2Configs.options) = - 1 then
					Attr2Configs.RemoveAt(i)
					set Attr2Configs =  nothing
				end if
			end if
		end sub
		public sub AddConfig(byval id, byval pid, byval title, byval istop,  byval isNumAttr)
			if pid = 0 then
				if isNumAttr then
					set Attr1Configs = new  ProductAttrConfigCollection
					Attr1Configs.id = id
					Attr1Configs.title = title
				else
					set Attr2Configs = new  ProductAttrConfigCollection
					Attr2Configs.id = id
					Attr2Configs.title = title
				end if
			else
				if not Attr1Configs is nothing then
					if pid = Attr1Configs.id then
						Attr1Configs.Addtem title,  id,  istop
					else
						Attr2Configs.Addtem title,  id,  istop
					end if
				else
					Attr2Configs.Addtem title,  id,  istop
				end if
			end if
		end sub
		public function GetEachCount()
			if Attr1Configs is nothing then GetEachCount = 0 : exit function
			select case LoadModel
			case "by_data" :  GetEachCount =  ubound(Attr1Configs.options)+1
'select case LoadModel
			case "by_config" :  GetEachCount =  ubound(Attr1Configs.options)+1
'select case LoadModel
			case "by_config_or_data" : GetEachCount =  ubound(Attr1Configs.options)+1
'select case LoadModel
			case else
			err.Raise 1000, 1, "GetEachCount 暂不支持【" & loadmodel & "】模式"
			end select
		end function
		private eachdataindex
		public sub  GetEachData(byval eindex,  byref attr1,  byref numv,  byref  billlistid,  byref mxpx)
			dim i
			eachdataindex = -1
'dim i
			if LoadModel  = "by_config" or  LoadModel  = "by_data" or LoadModel  = "by_config_or_data" then
				attr1 = 0:  numv = "":  billlistid = 0
				if not Attr1Configs is nothing then
					if eindex <= ubound(Attr1Configs.options) then
						attr1 = clng(Attr1Configs.options(eindex)(0))
					end if
				end if
				if attr1>0 then
					for i = 0 to ubound(cells)
						if cells(i).Attr1 = attr1 then
							numv = cells(i).num
							billlistid = cells(i).BillListId
							mxpx = "AttrsBatch_Attr1_" & mxpxid & "_" &  attr1 & "_" &  cells(i).BillListId & "_" &  cells(i).ParentListId
							eachdataindex =  i
							exit sub
						end if
					next
					billlistid = 0
					if ubound(cells) = 0 then
						mxpx = "AttrsBatch_Attr1_" & mxpxid & "_" &  attr1 & "_0_" &  cells(0).ParentListId
					else
						mxpx = "AttrsBatch_Attr1_" & mxpxid & "_" &  attr1 & "_0_0"
					end if
				else
					billlistid =  BatchId
					numv = SumNum
					mxpx = mxpxid
					eachdataindex = -1
'mxpx = mxpxid
				end if
			else
				err.Raise 1000, 1, "GetEachData 暂不支持【" & loadmodel & "】模式"
			end if
		end sub
		public sub SetOldListData(datas)
			if EachDataIndex <0 then
				OldListData = split("",",")
			else
				OldListData = split( split(datas, chr(3))(EachDataIndex), chr(2))
			end if
		end sub
		public function GetEachNumValue(byval eindex)
			select case LoadModel
			case "by_config" :
			dim i,  attrid :  attrid =  Attr1Configs.options(eindex)(0)
			for i = 0 to ubound(cells)
				if cells(i).Attr1 = attrid then
					exit function
				end if
			next
			case else
			err.Raise 1000, 1, "GetEachNumValue 暂不支持【" & loadmodel & "】模式"
			end select
		end function
	end Class
	class ProductAttrsHelperClass
		private CurrNumField
		private CurrPrimaryKeyField
		Private CurrParentPrimaryKeyField
		private CurrJoinnumFields
		private ListRecordset
		private ProductField
		public ForEachIndex
		public EachObject
		private ForEachListId
		private CurrLoadModel
		private CurrEditDispaly
		private IsAddModel
		public StrongInheritModel
		private IsOpened
		private mbit
		public sub Class_Initialize
			ForEachListId = "**"
			CurrLoadModel = "by_config"
			CurrEditDispaly = "editable"
			IsAddModel = false
			BufferModel= false
			StrongInheritModel = false
			IsOpened =  isOpenProductAttr
			set CurrProductAttrsHandler =  me
			mbit= sdk.GetSqlValue("select num1 from setjm3 where ord in (1)",6)
		end sub
		public sub InitAsAddNew(byval  productid,  byval initnum1)
			dim proxyrs  :  set proxyrs = nothing
			if IsOpened then
				set proxyrs = server.CreateObject("adodb.recordset")
				proxyrs.fields.Append  "Attrf_Productid",  3,  4,  120
				proxyrs.fields.Append  "Attrf_Num1",  5,  19,  120
				proxyrs.fields.Append  "Attrf_billlist",  3,  4,  120
				proxyrs.fields.Append  "Attrf_money1",  5,  19,  120
				proxyrs.fields.Append  "ProductAttr1",  3,  4,  120
				proxyrs.fields.Append  "ProductAttr2",  3,  4,  120
				proxyrs.fields.Append  "ProductAttrBatchId",  3,  4,  120
				proxyrs.Open
				proxyrs.AddNew
				proxyrs("Attrf_Productid").Value =  productid
				proxyrs("Attrf_Num1").Value =  cdbl(initnum1)
				proxyrs("Attrf_billlist").Value =  0
				proxyrs("Attrf_money1").Value =  0
				proxyrs.Update
				IsAddModel = true
			end if
			HandleRecordSet proxyrs,  "Attrf_billlist" , "",  "Attrf_Productid",  "Attrf_Num1",  "Attrf_money1"
		end sub
		public sub InitAsAddNewByAttrs(byval  productid,  byval initnum1Str, ByVal ProductAttr1Str, ByVal ProductAttr2, ByVal AttrBatchId, ByVal billListIdStr, ByVal parentListIdStr)
			dim proxyrs  :  set proxyrs = nothing
			dim initnum1, i, arr_cpord, arr_num1, arr_attr1, arr_billListId, arr_parentListId
			if IsOpened then
				set proxyrs = server.CreateObject("adodb.recordset")
				proxyrs.fields.Append  "Attrf_Productid",  3,  4,  120
				proxyrs.fields.Append  "Attrf_Num1",  5,  19,  120
				proxyrs.fields.Append  "Attrf_billlist",  3,  4,  120
				proxyrs.fields.Append  "Attrf_money1",  5,  19,  120
				proxyrs.fields.Append  "ProductAttr1",  3,  4,  120
				proxyrs.fields.Append  "ProductAttr2",  3,  4,  120
				proxyrs.fields.Append  "ProductAttrBatchId",  3,  4,  120
				proxyrs.fields.Append  "parentListId",  3,  4,  120
				proxyrs.Open
				if ProductAttr1Str&"" = "" then
					If parentListIdStr&""="" Then
						parentListIdStr = "0"
					else
						parentListIdStr = split(parentListIdStr&"",",")(0)
					end if
					proxyrs.AddNew
					proxyrs("Attrf_Productid").Value =  productid
					proxyrs("Attrf_Num1").Value =  zbcdbl(initnum1Str)
					proxyrs("ProductAttr2").Value =  ProductAttr2
					proxyrs("ProductAttrBatchId").Value =  AttrBatchId
					proxyrs("Attrf_billlist").Value =  billListIdStr
					proxyrs("Attrf_money1").Value =  0
					proxyrs("parentListId").Value =  parentListIdStr
					proxyrs.Update
				else
					arr_num1 = split(initnum1Str&"",",")
					arr_attr1 = split(ProductAttr1Str&"",",")
					arr_billListId = split(billListIdStr&"",",")
					arr_parentListId = split(parentListIdStr&"",",")
					for i=0 to ubound(arr_num1)
						if arr_num1(i)&""<>"" then
							proxyrs.AddNew
							proxyrs("Attrf_Productid").Value =  productid
							proxyrs("ProductAttr1").Value =  arr_attr1(i)
							proxyrs("Attrf_Num1").Value =  cdbl(arr_num1(i))
							proxyrs("ProductAttr2").Value =  ProductAttr2
							proxyrs("ProductAttrBatchId").Value =  AttrBatchId
							proxyrs("Attrf_billlist").Value =  arr_billListId(i)
							proxyrs("Attrf_money1").Value =  0
							proxyrs("parentListId").Value =  arr_parentListId(i)
							proxyrs.Update
						end if
					next
				end if
				IsAddModel = true
			end if
			HandleRecordSet proxyrs,  "Attrf_billlist" , "parentListId",  "Attrf_Productid",  "Attrf_Num1",  "Attrf_money1"
		end sub
		private function existsRsField(byref rs, byref fieldname)
			dim i, c
			for i = 0 to rs.fields.count - 1
'dim i, c
				set c = rs.fields(i)
				if lcase(c.name) = lcase(fieldname) then
					existsRsField = true
					exit function
				end if
			next
			existsRsField = false
		end function
		public sub HandleRecordSet(byref rs,  byval billlistf,   ByVal parentbilllistf,   byval pfield,   byval numfield,  byval joinnumFields)
			dim i,  ii,  newrs ,  c,  newc,  colhas,  parentlistid, rowindexkey
			dim attrbatchid,  signkeys,  soruce,  ctype
			if IsOpened = false then
				set ListRecordset = rs
				exit sub
			end if
			CurrNumField = numfield
			dim JoinnumField : JoinnumField = numfield
			if len(joinnumFields)>0 then JoinnumField = joinnumFields & "," & numfield
			CurrJoinnumFields  =  split(JoinnumField ,",")
			CurrPrimaryKeyField = billlistf
			CurrParentPrimaryKeyField = parentbilllistf
			ProductField = pfield
			signkeys = split("ProductAttr1,ProductAttr2,ProductAttrBatchId," & numfield & "," & joinnumFields,",")
			soruce = rs.Source
			set  rs.ActiveConnection = nothing
			rs.Sort = "ProductAttrBatchId, " & billlistf
			for ii=0 to ubound(signkeys)
				if len(signkeys(ii))>0 and existsRsField(rs, signkeys(ii)) = false then
					err.Raise 1000,1000, "<div style='color:red;padding:20px;margin:5px 0px;background-color:#ffffaa;font-size:14px;font-family:微软雅黑;line-height:18px'>ProductAttrsClass.HandleRecordSet 转换失败! " &_
					"<br>请确认要处理的明细数据源中是否提供了【 & join(signkeys, 】、【) & 】 列.  <br> 数据源命令：   & soruce & </div>"
				end if
			next
			dim fieldmap : fieldmap = "|"
			set newrs = server.CreateObject("adodb.recordset")
			for i = 0 to rs.fields.count - 1
'set newrs = server.CreateObject("adodb.recordset")
				set c = rs.fields(i)
				if instr(fieldmap, "|" & lcase(c.name) & "|") = 0 then
					newrs.fields.Append c.Name,  c.type,  c.DefinedSize, c.Attributes
					set newc = newrs.Fields(c.Name)
					newc.DataFormat = c.DataFormat
					newc.NumericScale = c.NumericScale
					newc.Precision = c.Precision
					fieldmap=  fieldmap & lcase(c.name) & "|"
				end if
			next
			newrs.fields.Append  "ProductAttrsJson",  202, 4000
			newrs.fields.Append  "ProductAttrsOldDatas",  202, 8000
			newrs.open
			dim  attrs,  PreAttrbatchid :  PreAttrbatchid  = -1
'newrs.open
			while rs.eof = False
				parentlistid = 0
				attrbatchid = clng("0" & rs("ProductAttrBatchId").value)
				If Len(CurrParentPrimaryKeyField) > 0 Then  parentlistid = rs(CurrParentPrimaryKeyField).value
				if PreAttrbatchid = attrbatchid  and  attrbatchid <>0  then
					call attrs.AddCell ( rs(CurrPrimaryKeyField).value ,  rs("ProductAttr1").value ,  rs(numfield).value,  parentlistid)
					call AddNeedSumFields(newrs,  rs)
					call AddOldListFieldDatas(newrs, rs)
				else
					newrs.AddNew
					for i = 0 to rs.fields.count - 1
'newrs.AddNew
						set c = rs.fields(i)
						on error resume next
						newrs.Fields(c.name).Value = c.value
						on error goto 0
					next
					set attrs= new ProductAttrCellCollection
					call attrs.Bind( newrs )
					call attrs.AddCell (rs(CurrPrimaryKeyField).value ,  rs("ProductAttr1").value ,  rs(numfield).value,  parentlistid)
					call AddOldListFieldDatas(newrs, rs)
					PreAttrbatchid = attrbatchid
				end if
				rs.movenext
			wend
			rs.close
			set rs = newrs
			if  existsRsField(rs, "rowindex") then
				rs.sort = "rowindex," &  billlistf
			else
				rs.sort =  billlistf
			end if
			if rs.eof = false then rs.movefirst
			set ListRecordset = rs
		end sub
		private sub AddNeedSumFields(byval newrs,  byval oldrs)
			dim i,  f,  newv, oldv
			for i = 0 to ubound(CurrJoinnumFields)
				f = CurrJoinnumFields(i)
				oldv =  oldrs(f).Value :  if len(oldv & "") = 0 then oldv = 0
				newv =  newrs(f).Value :  if len(newv & "") = 0 then newv = 0
				newrs(f).Value = cdbl(oldv) + cdbl(newv)
'newv =  newrs(f).Value :  if len(newv & "") = 0 then newv = 0
				newrs.Update
			next
		end sub
		public sub  AddOldListFieldDatas(byval newrs, byval oldrs)
			dim i,  n, v,  attrs,  itemc
			attrs =newrs("ProductAttrsOldDatas").Value & ""
			itemc = ""
			for i = 0 to oldrs.fields.count - 1
'itemc = ""
				v =  oldrs(i).value & ""
				if len(v)>0 and isnumeric(v) then
					if len(itemc) > 0 then  itemc =  itemc & chr(2)
					itemc =  itemc & oldrs(i).name & chr(1) & v
				end if
			next
			if len(attrs) > 0 then attrs = attrs & chr(3)
			attrs = attrs & itemc
			newrs("ProductAttrsOldDatas").Value  =  attrs
		end sub
		public function GetForEachAttrObject (byval json ,  byval  productid,  byval loadmodel)
			dim i,  existsids,  attrobj, rs,  onlynostop
			set attrobj = new  ProductAttrCellCollection
			attrobj.loadmodel = loadmodel
			attrobj.LoadJSON  json
			dim  sql : sql = ProductAttrsCmdText(productid , loadmodel)
			set rs = conn.execute(sql)
			dim existspid : existspid =  false
			while rs.eof = false
				if existspid = false then existspid =  clng("0" &  rs("pid").value)
				attrobj.AddConfig  rs("id").value ,   rs("pid").value,  rs("title").value,  rs("isstop").value,  (rs("isTiled").value & "")="1"
				rs.movenext
			wend
			rs.close
			set rs =  nothing
			attrobj.StrongInherit =   (StrongInheritModel=true and  existspid )
			if loadmodel = "by_data"  or  attrobj.StrongInherit  then
				attrobj.DelNullDataConfig
			elseif loadmodel = "by_config_or_data" then
				attrobj.DelNullDataStopConfig
			end if
			set GetForEachAttrObject = attrobj
		end function
		private function GetExistsDataIdsSql(attrobj)
			dim i
			dim attr2id : attr2id = attrobj.Attr2
			dim attr2parentids :   attr2parentids =  "0"
			if attr2id>0 then attr2parentids = attr2id & "," & conn.execute("select pid  from Shop_GoodsAttr where id=" & attr2id).value
			dim attrs1ids :  attrs1ids = "0"
			for i = 0 to ubound(attrobj.Cells)
				attrs1ids = attrs1ids
			next
		end function
		public sub SetLoadModel(byval loadmodel, byval display)
			loadmodel = lcase(loadmodel)
			if loadmodel <> "by_config" and  loadmodel <> "by_data" and loadmodel<>"by_config_or_data" then
				err.Raise 1000,1000, "产品属性 loadmodel参数只支持：  by_config（仅按配置加区域）  by_data (仅按数据加载区域) 和  by_config_or_data（按配置和数据加载区域，取并集）"
			end if
			if display <> "editable" and  display <> "readonly"  then
				err.Raise 1000,1000, "产品属性display 参数只支持：  editable（编辑模式）  readonly (只读模式) "
			end if
			CurrLoadModel = loadmodel
			CurrEditDispaly= display
		end sub
		public BufferModel
		public BuffterModelHtml
		public function WriteHtml(byval html)
			response_Write html
		end function
		public function getBufferHtml()
			getBufferHtml = BuffterModelHtml
			BuffterModelHtml = ""
		end function
		private currnumtext
		public function ForEach(byref mxid, byref billistid ,  byref  attr1id, byref  attr2id,  byref num1, byref  inputattrs)
			if ForEachIndex = -100 then
				inputattrs = ""
				attr1id = 0  :  attr2id = 0
				ForEachIndex=0 :  ForEach = false
				exit function
			end if
			if IsOpened = false then
				set EachObject = new ProductAttrCellCollection
				EachObject.InitByNoOpened ListRecordset
				attr1id = 0  :  attr2id = 0
				ForEachIndex=-100  :  ForEach = true
'attr1id = 0  :  attr2id = 0
				exit function
			end if
			dim rs : set rs = ListRecordset
			if ForEachListId <>  rs(CurrPrimaryKeyField).value then
				ForEachIndex = 0
				ForEachListId = rs(CurrPrimaryKeyField).value
				set EachObject = GetForEachAttrObject( rs("ProductAttrsJson").value,  rs(ProductField).value ,  CurrLoadModel)
				EachObject.MxpxId = mxid
				if  EachObject.Attr1Configs is nothing  and   EachObject.Attr2Configs is nothing  then
					ForEachIndex = - 100
'if  EachObject.Attr1Configs is nothing  and   EachObject.Attr2Configs is nothing  then
					set EachObject = nothing
					ForEach = true
					exit function
				else
					if (EachObject.batchid & "") = ""  or  (EachObject.batchid & "")  = "0" then
						EachObject.batchid =  ForEachListId
					end if
				end if
			else
				ForEachIndex = ForEachIndex + 1
				EachObject.batchid =  ForEachListId
			end if
			if ForEachIndex = 0 then
				currnumtext = ""
				CStartAttrTableHtml  loadmodel
			end if
			if  ForEachIndex > EachObject.GetEachCount() then
				CEndAttrTableHtml
				ForEach = false
			else
				call EachObject.GetEachData( ForEachIndex,   attr1id,   num1,    billistid,  mxid)
				call EachObject.SetOldListData (rs("ProductAttrsOldDatas").value)
				attr2id = EachObject.attr2
				inputattrs = GetNewInputHtmlAttrs(mxid)
				CItemAttrTableHtml mxid
				currnumtext = currnumtext & num1
				ForEach = true
			end if
		end function
		public RowIndexTick
		public sub UpdateFieldValue(byval  rs,   byval mxid)
			dim v1, v2, v3
			v1= request.Form("AttrsBatch_Attr1_" & mxid)
			v2 = request.Form("AttrsBatch_Attr2_" & mxid)
			v3 = request.Form("AttrsBatch_BatchId_" & mxid)
			if len(v1 & "")=0 then v1 = 0
			rs("ProductAttr1").value = v1
			if len(v2 & "")=0 then v2 = 0
			rs("ProductAttr2").value =  v2
			if len(v3 & "")>0 then rs("ProductAttrBatchId").value = v3
			RowIndexTick = RowIndexTick + 1
'if len(v3 & "")>0 then rs("ProductAttrBatchId").value = v3
			on error resume next
			rs("rowindex").value = RowIndexTick
			on error goto 0
		end sub
		public function  InitScript()
			Response.write "<script src='" & sdk.GetVirPath  & "inc/ProductAttrhelper.js'></script>"
			Response.write "<style>.attrreadsum input, .attrreadNumInput{background-color:#e0e0e0; color:#666;}</style>"
			Response.write "<script src='" & sdk.GetVirPath  & "inc/ProductAttrhelper.js'></script>"
		end function
		private  function  GetNewInputHtmlAttrs(mxid)
			dim itemhtml
			if instr(mxid & "","AttrsBatch_Attr1")>0 then
				if IsAddModel then
					itemhtml = " min='' "
				end if
				GetNewInputHtmlAttrs = " IsAttrCellBox=1 onblur='void(0)'  onkeyup='void(0)'  onpropertychange=""formatData(this,'number');""  "  & itemhtml
			else
				GetNewInputHtmlAttrs = " IsAttrSumBox=1 "
				if IsReadSumCell(mxid) then GetNewInputHtmlAttrs =  GetNewInputHtmlAttrs & " readonly "
			end if
		end function
		private function IsReadSumCell(byval mxid)
			IsReadSumCell = len(currnumtext & "")>0 and instr(mxid & "","AttrsBatch_Attr1")=0  and  ForEachIndex>0
		end function
		private sub CItemAttrTableHtml(byval mxid)
			if ForEachIndex>0 then Response.write "</td>"
			if IsReadSumCell(mxid) then
				response_Write "<td align=center isattrcell=1 class='attrreadsum' >"
			else
				response_Write "<td align=center isattrcell=1 >"
			end if
		end sub
		private sub response_Write(byval html)
			if BufferModel = false then
				Response.write html
			else
				BuffterModelHtml = BuffterModelHtml & html
			end if
		end sub
		private sub  CStartAttrTableHtml(byval loadmodel)
			dim oitems, i
			dim attr1 :  set attr1 =  EachObject.Attr1Configs
			dim attr2 :  set attr2 =  EachObject.Attr2Configs
			response_Write "<input type='hidden'  name='__sys_productattrs_batchid' value='" & EachObject.mxpxid & "'>"
			response_Write "<input type='hidden'  id='__sy_pa_fs_" &   EachObject.mxpxid & "' name='__sys_productattrs_fields_" &   EachObject.mxpxid & "' value=''>"
			response_Write "<table class='productattrstable'><tr class='header'>"
			if not attr2 is nothing then
				response_Write "<td>" & attr2.title & "</td>"
			end if
			if not attr1 is nothing then
				for i = 0 to ubound(attr1.options)
					oitems = attr1.options(i)
					response_Write "<td>" & oitems(1)  & "</td>"
				next
			end if
			response_Write "<td>小计</td></tr>"
			response_Write "<tr class=data>"
			dim IsEdit :  IsEdit =CurrEditDispaly = "editable"
			if not attr2 is nothing then
				response_Write "<td align=center>"
				if IsEdit then
					response_Write "<select name='AttrsBatch_Attr2_" & EachObject.mxpxid & "'>"
					if EachObject.StrongInherit = false then  response_Write "<option value=0 selected ></option>"
				end if
				for i = 0 to ubound(attr2.options)
					dim oid : oid= attr2.options(i)(0)
					dim otit : otit = attr2.options(i)(1)
					if (oid & "")=  (EachObject.Attr2 & "") then
						if IsEdit then
							response_Write "<option value=" & oid &" selected >" & otit & "</option>"
						else
							response_Write otit & "<input type='hidden' name='AttrsBatch_Attr2_" & EachObject.mxpxid & "' value='" & oid & "'>"
						end if
					else
						if IsEdit and EachObject.StrongInherit= false then  response_Write "<option value=" & oid &" >" & otit & "</option>"
					end if
				next
				if IsEdit then response_Write "</select>"
				response_Write "</td>"
			end if
		end sub
		private sub CEndAttrTableHtml
			response_Write "</td></tr></table>"
		end sub
		private CurrMaxMXPXID
		Public Function  CreateProxyRequest(ByVal  mxidname,  ByVal  billlistidname,  ByVal  parentbilllistidname,  ByVal numname,  ByVal joinfilednames)
			if isOpened = false then exit Function
			Dim mxid, n, i
			ExecuteGlobal "public Request"
			Set Request =  new ProductAttrProxyRequst
			For Each n In SystemRequestObject.form
				Request.AddFormValue n, CStr( SystemRequestObject.form(n))
			next
			CurrMaxMXPXID = 0
			dim rs : set rs = conn.execute("select max(id) from mxpx")
			if rs.eof = false then CurrMaxMXPXID = rs(0).value
			rs.close
			dim  mxids :  mxids =  split(SystemRequestObject.Form("__sys_productattrs_batchid"), ",")
			for i = 0 to ubound(mxids)
				mxid = clng(mxids(i))
				HanleFormBatchItemData mxid,  mxidname,  billlistidname,  parentbilllistidname,  numname,  joinfilednames
			next
		end function
		private sub HanleFormBatchItemData(byval  batchid,  ByVal  mxidname,  ByVal  billlistidname,  ByVal  parentbilllistidname,  ByVal numname,  ByVal joinfilednames)
			dim n, v, c, joinfs, i, ii,  attsns
			dim  isallmodel : isallmodel = false
			dim attr1s :  attr1s= split("", ",")
			for each n in SystemRequestObject.Form
				if  instr(n,  numname  & "AttrsBatch_Attr1_" & batchid & "_" ) = 1 then
					v  = SystemRequestObject.Form(n)
					if len(v & "")>0 then
						ArrayAppend attr1s,  array(n, v)
					end if
				end if
			next
			if ubound(attr1s)  <0  then exit sub
			joinfs = split(joinfilednames, ",")
			ArrayAppend joinfs,  numname
			dim  sumvalues, usedvalues, sumsize
			sumsize = ubound(joinfs)
			redim usedvalues(sumsize)
			dim item_batchid,  item_attr1_id,  item_billlistid ,   item_parentbilllistid
			dim currbilllistid :  currbilllistid = CStr(SystemRequestObject.Form( billlistidname & batchid ))
			currbilllistid = clng("0" & currbilllistid)
			dim isdeleted : isdeleted = cellcount>=0
			dim sumnum : sumnum =  cdbl(replace(CStr(SystemRequestObject.Form( numname & batchid )) ,",",""))
			dim cellcount :  cellcount = ubound(attr1s)
			for i = 0 to cellcount
				n  = attr1s(i)(0)
				v =  cdbl(replace(attr1s(i)(1), ",",""))
				attsns = split( split(n, "AttrsBatch_Attr1_")(1) , "_")
				item_batchid = clng(attsns(0))
				item_attr1_id = clng(attsns(1))
				item_billlistid = clng(attsns(2))
				item_parentbilllistid = clng(attsns(3))
				if isdeleted then
					if  item_billlistid = currbilllistid  and currbilllistid> 0 then  isdeleted = false
				end if
				if item_billlistid = 0  or item_billlistid<>currbilllistid  then
					CurrMaxMXPXID = CurrMaxMXPXID+1
'if item_billlistid = 0  or item_billlistid<>currbilllistid  then
					dim currformv : currformv = Request.Form(mxidname)
					if len(currformv & "") > 0 then  currformv = currformv & ","
					Request.SetFormValue mxidname,  InsertMxIdAfter(currformv ,  CurrMaxMXPXID, batchid)
					AddNewFormItem  batchid,  CurrMaxMXPXID,  item_billlistid, item_attr1_id,  billlistidname,  parentbilllistidname,  item_parentbilllistid,  numname,  joinfs ,   usedvalues,  sumnum,  v ,  i=cellcount
				else
					UpdateFormItem  batchid,   item_attr1_id,  billlistidname,  parentbilllistidname,  numname,  joinfs ,   usedvalues,  sumnum,  v ,   i=cellcount
				end if
			next
			if isdeleted then
				currformv = replace(Request.Form(mxidname), " ", "")
				currformv  = replace("," & currformv & ",", "," &  batchid & ",", ",")
				currformv =  replace(currformv, ",,", ",")
				currformv =  replace(currformv, ",,", ",")
				currformv =  replace(currformv, ",,", ",")
				currformv =  replace(currformv, ",,", ",")
				if left(currformv, 1) = "," then currformv = mid(currformv, 2)
				if right(currformv, 1) = "," then currformv = mid(currformv, 1, len(currformv)-1)
'if left(currformv, 1) = "," then currformv = mid(currformv, 2)
				Request.setFormValue mxidname,  currformv
				dim  fms :  fms = split(request.Form("__sys_productattrs_fields_" &  batchid), "|")
				for i = 0 to ubound(fms)
					Request.SetFormValue fms(i) & batchid ,  ""
				next
			end if
		end sub
		private function InsertMxIdAfter(byval  mxliststr,  byval newmxid,  byval beforemxid)
			mxliststr = "," & replace(mxliststr, " ", "") & ","
			mxliststr = replace(mxliststr, ("," & beforemxid & ",") ,  ("," & beforemxid & "," & newmxid & ","))
			mxliststr = ClearArrayStr(mxliststr, ",")
			InsertMxIdAfter =mxliststr
		end function
		private function ClearArrayStr(byval arrtxt, byval splitkey)
			dim arr1 :  arr1 = split(arrtxt, splitkey)
			dim i,  j,  arr2 : j = 0
			arr2 = split("", ",")
			for i=0 to ubound(arr1)
				if len(arr1(i))>0 then
					redim preserve arr2(j)
					arr2(j) = arr1(i)
					j=j+1
'arr2(j) = arr1(i)
				end if
			next
			ClearArrayStr = join(arr2,  splitkey)
		end function
		private sub  AddNewFormItem(byval copybatchid, byval newmxid,  byval itembilllistid, byval attr1id, byval billlistidname,  byval parentbilllistidname, byval item_parentbilllistid, byval numf,  byval joinfs ,  byref useds,  byval  allnum,  byval  itemnum ,  byval iseof)
			Request.AddFormValue billlistidname & newmxid,  itembilllistid
			if len(parentbilllistidname) >0 then  Request.AddFormValue parentbilllistidname & newmxid,  item_parentbilllistid
			Request.AddFormValue "AttrsBatch_Attr2_" & newmxid,  Request.Form("AttrsBatch_Attr2_" & copybatchid)
			Request.AddFormValue "AttrsBatch_Attr1_" & newmxid,  attr1id
			Request.AddFormValue "AttrsBatch_BatchId_" & newmxid,  copybatchid
			dim allfs : allfs = split(request.Form("__sys_productattrs_fields_" & copybatchid), "|")
			dim joinftxt : joinftxt = "|" & lcase( join(joinfs, "|") ) & "|"
			dim i, ii, iii
			for ii = 0 to ubound(allfs)
				dim itemn : itemn =  allfs(ii)
				dim litemn:  litemn = lcase(itemn)
				if litemn = lcase(billlistidname) or litemn = lcase(parentbilllistidname)  then
				else
					if  instr( joinftxt,  "|" &  litemn & "|") >0  then
						dim newjoinitemv
						newjoinitemv = 0
						if litemn =  lcase(numf) then
							newjoinitemv =  itemnum
						else
							dim oldsumv :  oldsumv = CStr(SystemRequestObject.Form(itemn & copybatchid))
							if len(oldsumv & "")=0 then  oldsumv = 0
							if isnumeric(oldsumv) = false then oldsumv = 0
							oldsumv = cdbl(replace(oldsumv & "",",",""))
							if  oldsumv <> 0 and  allnum<>0 then
								dim ji : ji = ArrayIndexOf(joinfs,  itemn)
								if ji>=0 then
									if iseof then
										newjoinitemv =  cdbl(oldsumv)*1  -  cdbl(useds(ji))
'if iseof then
									else
										newjoinitemv = cdbl(oldsumv)*cdbl(itemnum/allnum)
										newjoinitemv = sdk.getsqlvalue("select round("& newjoinitemv &","& mbit &")",0)
										useds(ji) = cdbl(useds(ji)) + cdbl(newjoinitemv)
'newjoinitemv = sdk.getsqlvalue("select round("& newjoinitemv &","& mbit &")",0)
									end if
								end if
							end if
						end if
						Request.AddFormValue itemn & newmxid,  newjoinitemv
					else
						Request.AddFormValue itemn & newmxid,  CStr(SystemRequestObject.Form(itemn & copybatchid))
					end if
				end if
			next
		end sub
		private sub  UpdateFormItem(byval currmxid,  byval attr1id,  byval billlistidname,  byval parentbilllistidname, byval numf,   byval joinfs ,   byref useds,  byval  allnum,  byval  itemnum ,  byval iseof)
			Request.AddFormValue "AttrsBatch_Attr1_" & currmxid,  attr1id
			Request.AddFormValue "AttrsBatch_BatchId_" & currmxid,  currmxid
			dim allfs : allfs = split(request.Form("__sys_productattrs_fields_" & currmxid), "|")
			dim joinftxt : joinftxt = "|" & lcase( join(joinfs, "|") ) & "|"
			dim i, ii, iii
			for ii = 0 to ubound(allfs)
				dim itemn : itemn =  allfs(ii)
				dim litemn:  litemn = lcase(itemn)
				if litemn = lcase(billlistidname) or litemn = lcase(parentbilllistidname)  then
				else
					if  instr( joinftxt,  "|" &  litemn & "|") >0  then
						dim newjoinitemv
						newjoinitemv = 0
						if litemn =  lcase(numf) then
							newjoinitemv =  itemnum
						else
							dim oldsumv :  oldsumv = CStr(SystemRequestObject.Form(itemn & currmxid))
							if len(oldsumv & "")=0 then  oldsumv = 0
							oldsumv = cdbl(replace(oldsumv & "",",",""))
							if  oldsumv <> 0 and  allnum<>0 then
								dim ji : ji = ArrayIndexOf(joinfs,  itemn)
								if ji>=0 then
									if iseof then
										newjoinitemv = oldsumv*1  -  cdbl(useds(ji))
'if iseof then
									else
										newjoinitemv = oldsumv *  cdbl(itemnum/allnum)
										newjoinitemv = sdk.getsqlvalue("select round("& newjoinitemv &","& mbit &")",0)
										useds(ji) = cdbl(useds(ji)) + newjoinitemv
'newjoinitemv = sdk.getsqlvalue("select round("& newjoinitemv &","& mbit &")",0)
									end if
								end if
							end if
						end if
						Request.SetFormValue litemn & currmxid,  newjoinitemv
					end if
				end if
			next
		end sub
		public sub ShowFormValues
			dim i
			for i = 0 to ubound(request.FormValues)
				Response.write  request.FormValues(i)(0) & "===" & request.FormValues(i)(1) & "<br>"
			next
			Response.end
		end sub
		public sub ArrayAppend(byref arr,  byref v)
			dim c :  c = ubound(arr)+1
'public sub ArrayAppend(byref arr,  byref v)
			redim preserve arr(c)
			arr(c) =  v
		end sub
		private function ArrayIndexOf(byref arr,  byref v)
			dim i
			for i = 0 to  ubound(arr)
				if lcase(arr(i)) = lcase(v) then ArrayIndexOf = i : exit function
			next
			ArrayIndexOf =  -1
			if lcase(arr(i)) = lcase(v) then ArrayIndexOf = i : exit function
		end function
	end Class
	Public  SystemRequestObject :  Set SystemRequestObject = Request
	Class  ProductAttrProxyRequst
		Public QueryString
		Public ServerVariables
		Public Cookies
		Public  TotalBytes
		Public  FormValues
		Public Function BinaryRead(ByVal count)
			BinaryRead = SystemRequestObject.BinaryRead(count)
		end function
		Public Function AddFormValue(name,  value)
			Dim c: c = ubound(FormValues) + 1
'Public Function AddFormValue(name,  value)
			ReDim Preserve FormValues(c)
			FormValues(c) =  Array(name, value)
		end function
		Public Function SetFormValue(name,  value)
			name = LCase(name)
			For i = 0 To  ubound(FormValues)
				If LCase(FormValues(i)(0)) = name  Then
					FormValues(i)(1) =  value
					Exit Function
				end if
			next
			AddFormValue name, value
		end function
		Public Function Form(byval name)
			dim i
			name = LCase(name)
			For i = 0 To  ubound(FormValues)
				If LCase(FormValues(i)(0)) = name  Then
					Form = FormValues(i)(1)
					Exit Function
				end if
			next
		end function
		Public  Default Function  items(ByVal name)
			Dim r : r = QueryString(name)
			If Len(r & "") = 0 Then r = Form(name)
			items = r
		end function
		public sub Class_Initialize
			FormValues = Split("",",")
			TotalBytes = SystemRequestObject.TotalBytes
			Set QueryString = SystemRequestObject.QueryString
			Set ServerVariables = SystemRequestObject.ServerVariables
			Set Cookies = SystemRequestObject.Cookies
		end sub
	End Class
	
	dim rs, rs2, sql, sql2
	dim rs_zdy, len_rszdy, num1_dot, num_dot_xs
	Sub MessagePost(msgId)
		Select Case msgId
		Case ""
		Call Page_load
		End Select
	end sub
	Sub Page_load
		app.docmodel = "IE=8"
		Response.write app.DefHeadHTML(app.virPath, "") & vbcrlf & ""
		if session("contractth_idzbintel")&""="" then
			Response.write "<script>app.Alert('参数丢失请重新打开此页面');</script>"
			Response.end()
		end if
		dim ord, currTel
		ord=clng(session("contractth_idzbintel"))
		currTel = session("companyzbintel")
		If app.isIE7 Or app.isIE6 Then
			Response.write "<html style='overflow:auto;overflow-x:auto;overflow-y:hidden; scrollbar-3dlight-color:#d0d0e8; scrollbar-highlight-color:#fff; scrollbar-face-color:#f0f0ff; scrollbar-arrow-color:#c0c0e8; scrollbar-shadow-color:#d0d0e8; scrollbar-darkshadow-color:#fff; scrollbar-base-color:#ffffff; scrollbar-track-color:#fff;'>"
'If app.isIE7 Or app.isIE6 Then
		end if
		Response.write "" & vbcrlf & "<style>" & vbcrlf & "#content{table-layout: fixed}" & vbcrlf & "#content td{overflow: hidden;word-break: break-all;word-wrap: break-word}" & vbcrlf & "#content td a:hover{ text-decoration:underline}" & vbcrlf & "</style>" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "function editSLItems(winWidth){                //点击编辑明细 "& vbcrlf & "  var currTel, dataTel , currBz, dataBz ;" & vbcrlf &  "if(window.parent.document.getElementById(""companyOrd"")){" & vbcrlf &   "        var telOrd = window.parent.document.getElementById(""companyOrd"").value;" & vbcrlf & "           var telBz = window.parent.document.getElementById(""bz"").value;" & vbcrlf & "               var cateid=window.parent.document.getElementById(""W3"").value;" & vbcrlf & "             if(telOrd=="""" || telBz ==""""||cateid==""""){" & vbcrlf & "                 if (telOrd=="""" ){app.Alert(""请选择关联客户"");}" & vbcrlf & "              else if(cateid==""""){app.Alert(""请选择销售人员"");}" & vbcrlf &  "                 else{app.Alert(""请选择退货单币种"");}" & vbcrlf & "          }else{" & vbcrlf & "                  winWidth = Number(winWidth);" & vbcrlf & "                    currTel = Number(telOrd);" & vbcrlf & "                       dataTel = 0; "& vbcrlf &  "                   dataTel = GetMxAttr1("
		Response.write ord
		Response.write ",""getMxCompany1"");" & vbcrlf & "                      currBz =  Number(telBz);" & vbcrlf & "                        dataBz =  GetMxAttr1("
		Response.write ord
		Response.write ",""GetMxBz1"");" & vbcrlf & "                   if((currTel == dataTel || dataTel==0) && (currBz == dataBz || dataBz ==0)){" & vbcrlf & "                         window.open('../contractth/eventlistadd.asp?top="
		Response.write app.base64.pwurl(ord)
		Response.write "&cateid='+cateid+'&f=101&bz='+currBz,'planthmx8','width=' + (winWidth+300) + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');" & vbcrlf & "                       }else if(dataTel>0 && currTel != dataTel){" & vbcrlf & "                              if(confirm(""已编辑的退货明细不是该客户购买的,确定要继续吗？"")){" & vbcrlf & "                                      window.open('../contractth/eventlistadd.asp?top="
		Response.write app.base64.pwurl(ord)
		Response.write "&f=101&bz='+currBz,'planthmx8','width=' + (winWidth+300) + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100'); //在打开的明细编辑页把更换关联客户前的客户的产品明细都删除" & vbcrlf & "                              }else{" & vbcrlf & "                                  return; " & vbcrlf & "                                }" & vbcrlf & "                       }else if(dataBz>0 && currBz!= dataBz){" & vbcrlf & "                         if(confirm(""已编辑的退货明细不是所选币种,确定要继续吗？"")){" & vbcrlf & "                                       window.open('../contractth/eventlistadd.asp?top="
		Response.write app.base64.pwurl(ord)
		Response.write "&f=101&bz='+currBz,'planthmx8','width=' + (winWidth+300) + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100'); //在打开的明细编辑页把更换币种前的产品明细都删除" & vbcrlf & "                                }else{" & vbcrlf & "                                  return; " & vbcrlf & "                                }                               " & vbcrlf & "                        }" & vbcrlf & "               }" & vbcrlf& "        }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function GetMxAttr1(ord,funName){                     //查看当前添加的明细中的客户，参数为当前退货单的id" & vbcrlf & "      ajax.regEvent(funName,""../contractth/eventlistadd.asp"");" & vbcrlf & "  $ap(""ord"",ord)" & vbcrlf & "    var r = ajax.send();" & vbcrlf & "    if(r != """"){" & vbcrlf & "              if(!isNaN(r)){" & vbcrlf & "                   return r;" & vbcrlf & "               }else{" & vbcrlf & "                  app.Alert(""未知错误"");" & vbcrlf & "            }" & vbcrlf & "       }else{" & vbcrlf & "          app.Alert(""未知错误"");" & vbcrlf & "    }" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "<body style='overflow:auto;overflow-x:auto;overflow-y:hidden; scrollbar-3dlight-color:#d0d0e8; scrollbar-highlight-color:#fff; scrollbar-face-color:#f0f0ff; scrollbar-arrow-color:#c0c0e8; scrollbar-shadow-color:#d0d0e8; scrollbar-darkshadow-color:#fff; scrollbar-base-color:#ffffff; scrollbar-track-color:#fff;'>" & vbcrlf & ""
		'Response.write app.base64.pwurl(ord)
		num1_dot = info.FloatNumber
		num_dot_xs = info.MoneyNumber
		set rs2 = cn.execute("select id,title,kd,name,sorce from zdymx where sort1=41 and set_open=1 order by gate1 asc")
		if rs2.eof=false then
			rs_zdy = rs2.GetRows()
		end if
		rs2.close
		set rs2 = nothing
		if isArray(rs_zdy) then
			len_rszdy = ubound(rs_zdy,2)
		else
			len_rszdy = -1
			len_rszdy = ubound(rs_zdy,2)
		end if
		dim k, n, num_gate5, num_max, arr_num1, arr_num2, sumkd, sumkd2, sum, summoney1, num1,price1, money1, mxIntro, guzhang, cptitle
		dim zdyTitle, kd, fieldname,zdySorce, htord, htcateid, htListPower, htInfoPower
		dim gate1, gate2, gate3, item1, item2, item3
		n=0 : num_gate5=0 : num_max=0 : num_max=0 : sumkd=0 : sumkd2=0 : sum = 0 : summoney1 = 0
		arr_num1 = ""
		arr_num2 = ""
		if len_rszdy>=0 then
			for k=0 to len_rszdy
				kd = rs_zdy(2,k)
				sumkd = sumkd + kd
				kd = rs_zdy(2,k)
			next
			If sumkd<=730 Then
				sumkd2 = sumkd +66
'If sumkd<=730 Then
			else
				sumkd2 = 800
			end if
			Response.write "" & vbcrlf & "        <table  style='border:1px solid #ccc;' border=""1"" maxspan=""2"" cellpadding=""5"" cellspacing=""0"" id=""content"" style=""width:"
			If sumkd<900 Then Response.write "100%" Else Response.write sumkd &"px"
			Response.write ";table-layout: fixed; "">" & vbcrlf & "        <tr class=""list-top"">" & vbcrlf & "        "
			'If sumkd<900 Then Response.write "100%" Else Response.write sumkd &"px"
			for k=0 to len_rszdy
				n = n + 1
'for k=0 to len_rszdy
				zdyTitle = rs_zdy(1,k)
				kd = rs_zdy(2,k)
				zdySorce = rs_zdy(4,k)
				if kd&""<>"" then kd=cint(kd) else kd=0
				if zdySorce&""<>"" then zdySorce=cint(zdySorce) else zdySorce=0
				if zdySorce=6 then
					arr_num1 = arr_num1 &"sum,"
					arr_num2 = arr_num2 & n &","
				elseif zdySorce=7 then
					arr_num1 = arr_num1 &"summoney,"
					arr_num2 = arr_num2 & n &","
				elseif zdySorce=27 then
					arr_num1 = arr_num1 &"InitMoney,"
					arr_num2 = arr_num2 & n &","
				elseif zdySorce=26 then
					arr_num1 = arr_num1 &"taxValue,"
					arr_num2 = arr_num2 & n &","
				end if
				Response.write "" & vbcrlf & "            <td style=""color:#2f496e"" width="""
				Response.write kd
				Response.write """><div align=""center""><strong>"
				Response.write zdyTitle
				Response.write "</strong></div></td>  " & vbcrlf & "            "
				if zdySorce=4 and isOpenProductAttr then
					n = n + 2
'if zdySorce=4 and isOpenProductAttr then
					Response.write "" & vbcrlf & "                <td style=""color:#2f496e"" width=""100""><div align=""center""><strong>产品属性1</strong></div></td>" & vbcrlf & "                <td style=""color:#2f496e"" width=""100""><div align=""center""><strong>产品属性2</strong></div></td>" & vbcrlf & "                "
				end if
				if zdySorce=17 and ZBRuntime.MC(17002) then
					n = n + 1
'if zdySorce=17 and ZBRuntime.MC(17002) then
					Response.write "" & vbcrlf & "                <td style=""color:#2f496e"" width=""100""><div align=""center""><strong>是否入库</strong></div></td>" & vbcrlf & "                "
				end if
			next
			Response.write "" & vbcrlf & "      </tr>" & vbcrlf & "    "
			if ZBRuntime.MC(17002) then
				clum=1
			else
				clum=0
			end if
			sql = "select isnull(b.title,'') as title, "&_
			"ISNULL(b.order1,0) as order1,ISNULL(b.type1,'') as type1,a.ph,a.xlh, "&_
			"ISNULL(a.unit,0) as unitall,s.sort1 as unitname,a.num1,a.price1, "&_
			"a.money1,a.datesc,a.dateyx,a.date2,a.intro, "&_
			"isnull(g.name,'') as cateid, isnull(d.title,'') as contract, a.htdate, "&_
			"a.zdy1,a.zdy2,a.zdy3,a.zdy4,isnull(a.zdy5,0) zdy5,isnull(a.zdy6,0) zdy6, a.id, a.ord, ISNULL(d.cateid,0) as htcateid, ISNULL(d.ord,0) as contractOrd,sga1.title as ProductAttr1,sga2.title as ProductAttr2, "&_
			"a.InitPrice,a.InitMoney,a.taxRate,a.taxValue,a.invoiceType,case isnull(a.NoNeedInKu,0) when 1 then '是' else '否' end NoNeedInKu "&_
			"from contractthlist a "&_
			"left join product b on a.ord=b.ord and b.del=1 "&_
			"left join sortonehy s on s.ord=a.unit "&_
			"left join contract d on ISNULL(a.contract,0)=d.ord and d.del=1  "&_
			"left join gate g on g.del=1 and g.ord = d.cateid " &_
			"left join Shop_GoodsAttr sga1 WITH(NOLOCK) on sga1.id=a.ProductAttr1 "&_
			"left join Shop_GoodsAttr sga2 WITH(NOLOCK) on sga2.id=a.ProductAttr2 "&_
			"where a.caigou="& ord &" and a.del2<>2 order by a.date7 asc,a.id asc"
			set rs = cn.execute(sql)
			if rs.eof = true then
				Response.write "" & vbcrlf & "             <tr><td style=""border:0;"" colspan="""
				if isOpenProductAttr then Response.write len_rszdy+3+clum else Response.write len_rszdy+1+clum
				Response.write "" & vbcrlf & "             <tr><td style=""border:0;"" colspan="""
				Response.write """><div style="""
				If sumkd<900 Then Response.write "text-align:center;" Else Response.write "text-align:left;margin-left:400px;"
				Response.write """><div style="""
				Response.write """>" & vbcrlf & "                        <img src=""../../SYSN/skin/default/img/lvw_nulldata_logo.png"" /><br>" & vbcrlf & "                       <span class=""lvw_nulldata_tle"">您还没有添加任何数据</span> <br>" & vbcrlf & "                   <a href=""javascript:;""style="""
				If sumkd<900 Then Response.write "margin-left:0;" Else Response.write "margin-left:43px;"
				Response.write """ onclick=""editSLItems('"
				Response.write sumkd2
				Response.write "')"" class=""editmx lvw_nulldata_addbtn"">去添加</a></div></td>" & vbcrlf & "                </tr>" & vbcrlf & "           "
			elseif rs.eof = false Then
				htListPower = app.power.GetPowerIntro(5,1)
				htInfoPower = app.power.GetPowerIntro(5,14)
				while rs.eof = false
					Response.write "<tr>"
					for k=0 to len_rszdy
						fieldname = rs_zdy(3,k)
						kd = rs_zdy(2,k)
						zdySorce = rs_zdy(4,k)
						if kd&""<>"" then kd=cint(kd) else kd=0
						if zdySorce&""<>"" then zdySorce=cint(zdySorce) else zdySorce=0
						Select Case zdySorce
						Case 1 :
						Response.write "<td align=""left"">"
						cptitle = rs("title")
						If cptitle&""= "" Then cptitle = ""
						If cptitle = "<span style='color:#ff0000'>产品已被删除</span>" Then
							Response.write "<span style='color:#ff0000'>产品已被删除</span>"
						else
							If app.power.existsPower(21,14) Then
								Response.write "<a href=""javascript:;"" onClick=""javascript:window.open('../product/content.asp?ord="
								Response.write app.base64.pwurl(rs("ord"))
								Response.write "','newdfwin','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=150,top=150')"" title=""点击可查看此产品详情"">"
								Response.write app.base64.pwurl(rs("ord"))
								Response.write cptitle
								Response.write "</a>"
							else
								Response.write cptitle
							end if
						end if
						Response.write "</td>"
						Case 2 :
						Response.write "<td align=""center"">"
						Response.write rs("order1")
						Response.write "</td>"
						Case 3 :
						Response.write "<td align=""center"">"
						Response.write rs("type1")
						Response.write "</td>"
						Case 4 :
						Response.write "" & vbcrlf & "                <td align=""center"">"
						Response.write rs("unitname")
						Response.write "</td>" & vbcrlf & "                "
						if isOpenProductAttr then
							Response.write "" & vbcrlf & "                    <td align=""center"">"
							Response.write rs("ProductAttr1")
							Response.write "</td>" & vbcrlf & "                    <td align=""center"">"
							Response.write rs("ProductAttr2")
							Response.write "</td>" & vbcrlf & "                "
						end if
						Case 5 :
						price1 = CDbl(rs("price1"))
						price1 = Formatnumber(price1,sdk.Info.SalesPriceDotNum,-1)
						price1 = CDbl(rs("price1"))
						price1 = CDbl(price1)
						Response.write "<td align=""right"">"
						Response.write Formatnumber(price1,sdk.Info.SalesPriceDotNum,-1)
						Response.write "<td align=""right"">"
						Response.write "</td>"
						Case 6 :
						num1 = CDbl(rs("num1"))
						num1 = Formatnumber(num1,num1_dot,-1)
						num1 = CDbl(rs("num1"))
						num1 = CDbl(num1)
						sum = sum + num1
						num1 = CDbl(num1)
						Response.write "<td align=""center"">"
						Response.write Formatnumber(num1,num1_dot,-1)
						Response.write "<td align=""center"">"
						Response.write "</td>"
						Case 7 :
						money1= CDbl(rs("money1"))
						money1 = Formatnumber(money1,num_dot_xs,-1)
						money1= CDbl(rs("money1"))
						money1 = CDbl(money1)
						summoney1 = summoney1 + money1
						money1 = CDbl(money1)
						Response.write "<td align=""right"">"
						Response.write Formatnumber(money1,num_dot_xs,-1)
						Response.write "<td align=""right"">"
						Response.write "</td>" & vbcrlf & "                                      " & vbcrlf & "                    "
						Case 8 :
						Response.write "<td align=""left"">"
						Response.write rs("date2")
						Response.write "</td>"
						Case 9 :
						Response.write "<td align=""center"">"
						Response.write replace(replace(rs("intro")&"",vbcrlf,"<br>"),chr(10),"<br>")
						Response.write "</td>"
						Case 10,11,12,13 :
						Response.write "<td height=""20"" align=""center"">"
						Response.write rs(""&fieldname&"")
						Response.write "</td>"
						Case 14 :
						Dim zdy5 : zdy5 = rs("zdy5")
						Dim zdy5Title : zdy5Title = ""
						If zdy5&""<>"" Then
							Set rs2 = cn.execute("select sort1 from sortonehy where id="& rs("zdy5"))
							If rs2.eof = False Then
								zdy5Title = rs2("sort1")
							end if
							rs2.close
							Set rs2 = Nothing
						end if
						Response.write "<td align=""center"">"
						Response.write zdy5Title
						Response.write "</td>"
						Case 15 :
						Dim zdy6 : zdy6 = rs("zdy5")
						Dim zdy6Title : zdy6Title = ""
						If zdy6&""<>"" Then
							Set rs2 = cn.execute("select sort1 from sortonehy where id="& rs("zdy6"))
							If rs2.eof = False Then
								zdy6Title = rs2("sort1")
							end if
							rs2.close
							Set rs2 = Nothing
						end if
						Response.write "<td align=""center"">"
						Response.write zdy6Title
						Response.write "</td>"
						Case 16 :
						Response.write "<td align=""center"">"
						Response.write rs("ph")
						Response.write "</td>"
						Case 17 :
						Response.write "<td align=""center"">"
						Response.write rs("xlh")
						Response.write "</td>" & vbcrlf & "                    "
						if ZBRuntime.MC(17000) and ZBRuntime.MC(17002) then
							Response.write "<td height=""20"" align=""center"">"
							Response.write rs("NoNeedInKu")
							Response.write "</td>"
						end if
						Case 18 :
						Response.write "<td align=""center"">"
						Response.write rs("datesc")
						Response.write "</td>"
						Case 19 :
						Response.write "<td align=""center"">"
						Response.write rs("dateyx")
						Response.write "</td>"
						Case 28 :
						htord = rs("contractOrd") : htcateid = rs("htcateid")
						Response.write "<td align=""center"">"
						if htord>0 Then
							If htListPower = "" Or instr(","& htListPower &"," , ","& htcateid &",")>0 then
'If htInfoPower = "" Or instr(","& htInfoPower &"," , ","& htcateid &",")>0 Then
								Response.write "<a href='javascript:void(0)' onclick=javascript:window.open('../../SYSN/view/sales/contract/ContractDetails.ashx?view=details&ord="& app.base64.pwurl(htord)&"','newwin25','width='+800+',height='+500+',toolbar=0,scrollbars=1,resizable=1,left=100,top=100');return false; alt='查看合同详情'>"& rs("contract") &"</a>"
							else
								Response.write(rs("contract"))
							end if
						end if
'end if
						Response.write "</td>                  " & vbcrlf & "                    "
						Case 29 :
						Response.write "<td align=""center"">"
						Response.write rs("cateid")
						Response.write "</td>"
						Case 30 :
						Response.write "" & vbcrlf & "                    <td align=""center"">"
						Response.write rs("htdate")
						Response.write "</td>" & vbcrlf & "                    "
						Case 23 :
						InitPrice = CDbl(rs("InitPrice"))
						InitPrice = Formatnumber(InitPrice,sdk.Info.SalesPriceDotNum,-1)
						InitPrice = CDbl(rs("InitPrice"))
						InitPrice = CDbl(InitPrice)
						Response.write "<td align=""right"">"
						Response.write Formatnumber(InitPrice,sdk.Info.SalesPriceDotNum,-1)
						Response.write "<td align=""right"">"
						Response.write "</td>" & vbcrlf & "                    "
						Case 24 :
						invoiceType=rs("invoiceType")
						Set rs2 = cn.execute("select sort1 from sortonehy  where gate2=34 and isnull(id1,0)<>-65535 and id="&invoiceType)
						invoiceType=rs("invoiceType")
						If rs2.eof = False Then
							invoiceName = rs2("sort1")
						else
							invoiceName = "不开票"
						end if
						rs2.close
						Set rs2 = Nothing
						Response.write "" & vbcrlf & "                    <td align=""center"">"
						Response.write invoiceName
						Response.write "</td>" & vbcrlf & "                    "
						Case 25 :
						taxRate=CDbl(rs("taxRate"))
						taxRate=Formatnumber(taxRate,num_dot_xs,-1)
						taxRate=CDbl(rs("taxRate"))
						taxRate=CDbl(taxRate)
						Response.write "" & vbcrlf & "                    <td align=""center"">"
						Response.write Formatnumber(taxRate,num_dot_xs,-1)
						Response.write "" & vbcrlf & "                    <td align=""center"">"
						Response.write "</td>" & vbcrlf & "                    "
						Case 26 :
						taxValue=CDbl(rs("taxValue"))
						taxValue=Formatnumber(taxValue,num_dot_xs,-1)
						taxValue=CDbl(rs("taxValue"))
						taxValue=CDbl(taxValue)
						sumtaxValue=sumtaxValue+taxValue
						taxValue=CDbl(taxValue)
						Response.write "" & vbcrlf & "                    <td align=""right"">"
						Response.write Formatnumber(taxValue,num_dot_xs,-1)
						Response.write "" & vbcrlf & "                    <td align=""right"">"
						Response.write "</td>" & vbcrlf & "                    "
						Case 27 :
						InitMoney=CDbl(rs("InitMoney"))
						InitMoney=Formatnumber(InitMoney,num_dot_xs,-1)
						InitMoney=CDbl(rs("InitMoney"))
						InitMoney=CDbl(InitMoney)
						sumInitMoney = sumInitMoney + InitMoney
						InitMoney=CDbl(InitMoney)
						Response.write "" & vbcrlf & "                    <td align=""right"">"
						Response.write Formatnumber(InitMoney,num_dot_xs,-1)
						Response.write "" & vbcrlf & "                    <td align=""right"">"
						Response.write "</td>" & vbcrlf & "                    "
						end Select
					next
					Response.write "</tr>"
					rs.movenext
				wend
				arr_number = ""
				for k=0 to len_rszdy
					zdySorce = rs_zdy(4,k)
					if zdySorce&""<>"" then zdySorce=cint(zdySorce) else zdySorce=0
					if zdySorce=6 then
						arr_number = arr_number & Formatnumber(sum,num1_dot,-1) &"|"
'if zdySorce=6 then  '
					elseif zdySorce=7 then
						arr_number = arr_number & Formatnumber(summoney1,num_dot_xs,-1) & "|"
'elseif zdySorce=7 then   '
					elseif zdySorce=27 then
						arr_number = arr_number & Formatnumber(sumInitMoney,num_dot_xs,-1) &"|"
'elseif zdySorce=27 then  '
					elseif zdySorce=26 then
						arr_number = arr_number & Formatnumber(sumtaxValue,num_dot_xs,-1) &"|"
'elseif zdySorce=26 then  '
					end if
				next
				Col0 = 0
				Sum0 = 0
				Col1 = 0
				Sum1 = 0
				Col2 = 0
				Sum2 = 0
				Col3 = 0
				Sum3 = 0
				numindex = 0
				indexArray = split(arr_num2,",")
				dbnameArray = split(arr_num1,",")
				numberArray = split(arr_number ,"|")
				align_mx_num="text-align:center"
				numberArray = split(arr_number ,"|")
				align_mx_money="text-align:right"
				numberArray = split(arr_number ,"|")
				align_mx0 = align_mx_money
				align_mx1 = align_mx_money
				align_mx2 = align_mx_money
				align_mx3 = align_mx_money
				lastinx = 0
				for m= 0 to ubound(indexArray)
					if m= 0 then
						Col0 = indexArray(0) : Sum0 = numberArray(0) : lastinx=  Col0 :  if dbnameArray(m)= "sum" then align_mx0= align_mx_num
					end if
					if m= 1 then
						Col1 = indexArray(1) : Sum1 = numberArray(1) : lastinx=  Col1 :  if dbnameArray(m)= "sum" then align_mx1= align_mx_num
					end if
					if m= 2 then
						Col2 = indexArray(2) : Sum2 = numberArray(2) : lastinx=  Col2 :  if dbnameArray(m)= "sum" then align_mx2= align_mx_num
					end if
					if m= 3 then
						Col3 = indexArray(3) : Sum3 = numberArray(3) : lastinx=  Col3 :  if dbnameArray(m)= "sum" then align_mx3= align_mx_num
					end if
				next
				Response.write " " & vbcrlf & "<tr>" & vbcrlf & ""
				if Col0>1 then
					Response.write "" & vbcrlf & "        <td align=""center"" colspan="""
					Response.write Col0-1
					Response.write "" & vbcrlf & "        <td align=""center"" colspan="""
					Response.write """>合计<img class='resetElementHidden' src='../images/jiantou.gif' /><img class='resetElementShow' style='display:none;' src='../skin/default/images/MoZihometop/content/lvw_addrow_btn.png' /><a href=""javascript:;"" onclick=""editSLItems('"
					Response.write sumkd2
					Response.write "')"" title=""点击编辑明细"" class=""editmx"">重新编辑</a></td>" & vbcrlf & "        "
				end if
				Response.write "" & vbcrlf & "    <td class=""red"" style="""
				Response.write align_mx0
				Response.write """>"
				Response.write Sum0
				Response.write "</td>" & vbcrlf & "    "
				if Col1-Col0>1 then
					Response.write "</td>" & vbcrlf & "    "
					Response.write "" & vbcrlf & "        <td colspan="""
					Response.write Col1-Col0-1
					Response.write "" & vbcrlf & "        <td colspan="""
					Response.write """>&nbsp;</td>" & vbcrlf & "        "
				end if
				if Col1>0 then
					Response.write "" & vbcrlf & "        <td class=""red"" style="" "
					Response.write align_mx1
					Response.write """>"
					Response.write Sum1
					Response.write "</td>" & vbcrlf & "        "
				end if
				if Col2-Col1>1 then
					Response.write "</td>" & vbcrlf & "        "
					Response.write "" & vbcrlf & "    <td colspan="""
					Response.write Col2-Col1-1
					Response.write "" & vbcrlf & "    <td colspan="""
					Response.write """>&nbsp;</td>" & vbcrlf & "    "
				end if
				if Col2>0 then
					Response.write "" & vbcrlf & "        <td class=""red"" style="" "
					Response.write align_mx2
					Response.write """>"
					Response.write Sum2
					Response.write "</td>" & vbcrlf & "        "
				end if
				if Col3-Col2>1 then
					Response.write "</td>" & vbcrlf & "        "
					Response.write "" & vbcrlf & "        <td colspan="""
					Response.write Col3-Col2-1
					Response.write "" & vbcrlf & "        <td colspan="""
					Response.write """>&nbsp;</td>" & vbcrlf & "        "
				end if
				if Col3>0 then
					Response.write "<td class=""red"" style="" "
					Response.write align_mx3
					Response.write """>"
					Response.write Sum3
					Response.write "</td>"
				end if
				if Col0=1 and n-lastinx>0 then
					Response.write "</td>"
					Response.write "" & vbcrlf & "        <td colspan="""
					Response.write n-lastinx
					Response.write "" & vbcrlf & "        <td colspan="""
					Response.write """> 合计<img class='resetElementHidden' src='../images/jiantou.gif' /><img class='resetElementShow' style='display:none;' src='../skin/default/images/MoZihometop/content/lvw_addrow_btn.png' /><a href=""#"" onClick=""editSLItems('"
					Response.write sumkd2
					Response.write "')"" title=""点击编辑明细"">重新编辑</a></td>" & vbcrlf & "        "
				elseif n-lastinx>0 then
					Response.write "')"" title=""点击编辑明细"">重新编辑</a></td>" & vbcrlf & "        "
					Response.write "" & vbcrlf & "        <td colspan="""
					Response.write n-lastinx
					Response.write "" & vbcrlf & "        <td colspan="""
					Response.write """>&nbsp;</td>" & vbcrlf & "        "
				end if
				Response.write "" & vbcrlf & "    </tr>" & vbcrlf & "    "
			end if
			rs.close
			set rs = nothing
			Set rs=cn.execute("select * from contractthbz where contractth="&ord&"")
			if rs.eof= False then
				Response.write "" & vbcrlf & "     <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "   <td height=""27""><div align=""center"">退款方式</div></td>" & vbcrlf & "     <td height=""20"" colspan="""
				Response.write n+1
				Response.write """>"
				Response.write rs("intro3")
				Response.write "</td>" & vbcrlf & "        </tr>" & vbcrlf & "   <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "   <td height=""27""><div align=""center"">退货地址</div></td>" & vbcrlf & "     <td height=""20"" colspan="""
				Response.write n+1
				Response.write """>"
				Response.write rs("intro4")
				Response.write "</td>" & vbcrlf & "        </tr>" & vbcrlf & "   <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "   <td height=""27""><div align=""center"">退货方式</div></td>" & vbcrlf & "     <td height=""20"" colspan="""
				Response.write n+1
				Response.write """>"
				Response.write rs("intro5")
				Response.write "</td>" & vbcrlf & "        </tr>" & vbcrlf & "   <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "   <td height=""27""><div align=""center"">退货时间</div></td>" & vbcrlf & "     <td height=""20"" colspan="""
				Response.write n+1
				Response.write """>"
				Response.write rs("intro6")
				Response.write "</td>" & vbcrlf & "        </tr>" & vbcrlf & "   <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "   <td height=""27""><div align=""center"">配件</div></td>" & vbcrlf & " <td height=""20"" colspan="""
				Response.write n+1
				Response.write """>"
				Response.write rs("intro1")
				Response.write "</td>" & vbcrlf & "        </tr>" & vbcrlf & "   <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "   <td height=""27""><div align=""center"">备注</div></td>" & vbcrlf & " <td height=""20"" colspan="""
				Response.write n+1
				Response.write """ >"
				Response.write rs("intro2")
				Response.write "</td>" & vbcrlf & "        </tr>" & vbcrlf & "   "
			end if
			rs.close
			Response.write "" & vbcrlf & "    </table><div style=""height:4px; margin-top:4px;"" id=""mxPos""></div>" & vbcrlf & "    "
			Response.write "</td>" & vbcrlf & "        </tr>" & vbcrlf & "   "
		end if
		Response.write "" & vbcrlf & "     <script language=""javascript"">" & vbcrlf & "            if (window.parent)" & vbcrlf & "              {" & vbcrlf & "                       window.parent.document.getElementById(""moneyall"").value="""
		Response.write summoney1
		Response.write """;" & vbcrlf & "                }" & vbcrlf & "       </script>" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	end sub
	
%>
