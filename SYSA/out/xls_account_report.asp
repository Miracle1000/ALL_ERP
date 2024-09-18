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
	
	Dim evalbody : evalbody=""
	Function getFormulaValue(body ,date1)
		If len(body) = 0 Then
			resultstr = "0"
		else
			Dim subjects_str,cell_fun ,cellstr,subject , money1, typ ,minIndex,nextMinIndex , kh , zkh , ykh , direction
			subjects_str = body
			subject = 0
			nextMinIndex=-1
			subject = 0
			minIndex = getMinIndex_reckon(body)
			if minIndex = 0 Then
				if instr(body,"getYearPartBegMoney")>0 Then
					evalbody = ""
					resultstr = resultstr & getMoney(body,date1,8,1)
				elseif instr(body,"getMonthPartBegMoney")>0 Then
					evalbody = ""
					resultstr = resultstr & getMoney(body,date1,9,1)
				else
					resultstr = resultstr & body
				end if
			else
				cellstr = left(subjects_str,minIndex-1)
				resultstr = resultstr & body
				kh = right(left(subjects_str,minIndex),1)
				body = right(subjects_str,len(subjects_str)-minIndex)
				kh = right(left(subjects_str,minIndex),1)
				if len(cellstr)>0 Then
					If InStr(cellstr,"getPartEndBlnMoney")>0 Or InStr(cellstr,"getYearBegBlnMoney")>0 Or InStr(cellstr,"getYearMltMoney")>0 Or InStr(cellstr,"getMonthMltMoney")>0 Then
						cell_fun = cellstr
						cellstr = ""
						if kh="(" And len(body)>0 Then
							zkh = 1
							ykh = 0
							nextMinIndex = getMinIndex_reckon(body)
							if nextMinIndex>0 Then
								Do while nextMinIndex>0
									cellstr = cellstr + left(body,nextMinIndex-1)
'Do while nextMinIndex>0
									if right(left(body,nextMinIndex),1) = ")" Then ykh = ykh +1
'Do while nextMinIndex>0
									if right(left(body,nextMinIndex),1) = "(" Then zkh = zkh +1
'Do while nextMinIndex>0
									If zkh<>ykh Then cellstr = cellstr + Right(left(body,nextMinIndex),1)
'Do while nextMinIndex>0
									body = right(body,len(body)-nextMinIndex)
'Do while nextMinIndex>0
									if zkh = ykh Then
										Exit Do
									else
										nextMinIndex = getMinIndex_reckon(body)
									end if
								Loop
								if zkh = ykh Then
									typ = 0
									direction = 0
									if InStr(cell_fun,"getPartEndBlnMoney_j")>0 Then
										typ = 5
										direction = 1
									elseif InStr(cell_fun,"getPartEndBlnMoney_d")>0 Then
										typ = 5
										direction = 2
									elseif InStr(cell_fun,"getYearBegBlnMoney_j")>0 Then
										typ = 1
										direction = 1
									elseif InStr(cell_fun,"getYearBegBlnMoney_d")>0 Then
										typ = 1
										direction = 2
									elseif InStr(cell_fun,"getYearMltMoney_j")>0 Then
										typ = 4
										direction = 1
									elseif InStr(cell_fun,"getYearMltMoney_d")>0 Then
										typ = 4
										direction = 2
									ElseIf InStr(cell_fun,"getMonthMltMoney_j")>0 Then
										typ = 3
										direction = 1
									elseif InStr(cell_fun,"getMonthMltMoney_d")>0 Then
										typ = 3
										direction = 2
									elseif InStr(cell_fun,"getYearMltMoney_x")>0 Then
										typ = 6
									elseif InStr(cell_fun,"getMonthMltMoney_x")>0 Then
										typ = 7
									end if
									evalbody = ""
									resultstr = resultstr &  getMoney(cellstr,date1,typ,direction)
								else
									body = ""
								end if
							else
								body = ""
							end if
						else
							resultstr = resultstr & "0"
						end if
						kh = ""
					elseif instr(body,"getYearPartBegMoney")>0 Then
						evalbody = ""
						resultstr = resultstr & getMoney("",date1,8,1)
					elseif instr(body,"getMonthPartBegMoney")>0  Then
						evalbody = ""
						resultstr = resultstr & getMoney("",date1,9,1)
					else
						resultstr = resultstr & cellstr
					end if
				end if
				resultstr = resultstr & kh
				if len(body)>0 Then Call getFormulaValue(body ,date1)
			end if
		end if
		on error resume next
		getFormulaValue = eval(resultstr)
		If Err.number<>0 Then getFormulaValue = 0
		On Error GoTo 0
	end function
	Function getMinIndex_reckon(body)
		Dim minIndex, fz_index ,fy_index ,add_index,stn_index,mpt_index,dvs_index
		fz_index = InStr(body,"(")
		fy_index = InStr(body,")")
		add_index = InStr(body,"+")
		fy_index = InStr(body,")")
		stn_index = InStr(body,"-")
		fy_index = InStr(body,")")
		mpt_index = InStr(body,"*")
		dvs_index = InStr(body,"/")
		minIndex = 0
		if fz_index>0 Then minIndex = fz_index
		if (fy_index<minIndex and fy_index>0) or minIndex = 0 Then minIndex = fy_index
		if (add_index<minIndex and add_index>0) or minIndex =0 Then minIndex = add_index
		if (stn_index<minIndex and stn_index>0) or minIndex = 0 Then minIndex = stn_index
		if (mpt_index<minIndex and mpt_index>0) or minIndex = 0 Then minIndex = mpt_index
		if (dvs_index<minIndex and dvs_index>0) or minIndex = 0 Then minIndex = dvs_index
		getMinIndex_reckon =minIndex
	end function
	Function getItemData(subject, typ , direct)
		dataRecordset.Filter = "bh='" & subject &"'"
		Dim direction ,money1
		money1 = 0
		If dataRecordset.eof = False Then
			Select Case typ
			Case 1,8 :
			direction =app.iif(dataRecordset("b1").value="贷",2,1)
			money1 =  CDbl(dataRecordset("m1").value) * app.iif(direction=direct,1,-1)
			direction =app.iif(dataRecordset("b1").value="贷",2,1)
			Case 3 :
			If direct = 1 Then
				money1 =  CDbl(dataRecordset("m3_j").value) - CDbl(dataRecordset("m3_d").value)
'If direct = 1 Then
			else
				money1 =  CDbl(dataRecordset("m3_d").value) - CDbl(dataRecordset("m3_j").value)
'If direct = 1 Then
			end if
			Case 4 :
			If direct = 1 Then
				money1 =  CDbl(dataRecordset("m4_j").value) - CDbl(dataRecordset("m4_d").value)
'If direct = 1 Then
			else
				money1 =  CDbl(dataRecordset("m4_d").value) - CDbl(dataRecordset("m4_j").value)
'If direct = 1 Then
			end if
			Case 5 :
			direction =app.iif(dataRecordset("b5").value="贷",2,1)
			money1 = CDbl(dataRecordset("m5").value) * app.iif(direction=direct,1,-1)
			direction =app.iif(dataRecordset("b5").value="贷",2,1)
			Case 9 :
			direction =app.iif(dataRecordset("b2").value="贷",2,1)
			money1 = CDbl(dataRecordset("m2").value) * app.iif(direction=direct,1,-1)
			direction =app.iif(dataRecordset("b2").value="贷",2,1)
			End Select
		end if
		getItemData = money1
	end function
	function getMoney(subjects,date1,typ,direction)
		Dim subjects_str,cellstr, subject, money1 , minIndex
		if typ = 8 Then
			subjects ="0"
			subjects =subjects + getItemData("1001",typ ,1)  'app.cRecord("select dbo.[erp_subjbalance_fun](0,'"&date1&"',2,"&subject&",1,1)")(0)
			subjects ="0"
			subjects =subjects + getItemData("1002",typ ,1)  'app.cRecord("select dbo.[erp_subjbalance_fun](0,'"&date1&"',2,"&subject&",1,1)")(0)
			subjects ="0"
			subjects =subjects + getItemData("1012",typ ,1)    'app.cRecord("select dbo.[erp_subjbalance_fun](0,'"&date1&"',2,"&subject&",1,1)")(0)
			subjects ="0"
			getMoney = subjects
			Exit Function
		elseif typ = 9 Then
			subjects ="0"
			subjects =subjects + getItemData("1001",typ ,1) 'app.cRecord("select dbo.[erp_subjbalance_fun](0,'"&date1&"',2,"&subject&",2,1)")(0)
			subjects ="0"
			subjects =subjects + getItemData("1002",typ ,1) 'app.cRecord("select dbo.[erp_subjbalance_fun](0,'"&date1&"',2,"&subject&",2,1)")(0)
			subjects ="0"
			subjects =subjects + getItemData("1012",typ ,1) 'app.cRecord("select dbo.[erp_subjbalance_fun](0,'"&date1&"',2,"&subject&",2,1)")(0)
			subjects ="0"
			getMoney = subjects
			Exit Function
		end if
		if len(subjects)>0 Then
			subjects_str = subjects
			subject = 0
			minIndex = getMinIndex_reckon(subjects)
			if minIndex = 0 Then
				if typ<6 Then
					evalbody = evalbody & getItemData(subjects,typ,direction) 'app.cRecord("select dbo.[erp_subjbalance_fun](0,'"&date1&"',2,"&subject&","&typ&","&direction&")")(0)
				else
					if typ = 6 Then
						evalbody = evalbody & getFlowMoney(subjects,date1,3)
					elseif typ = 7 Then
						evalbody = evalbody & getFlowMoney(subjects,date1,2)
					end If
				end if
			else
				cellstr = left(subjects,minIndex-1)
			end If
			if Len(cellstr)>0 Then Call getMoney(cellstr,date1,typ,direction)
			evalbody = evalbody & right(left(subjects_str,minIndex),1)
			if len(right(subjects_str,len(subjects_str)-minIndex))>0 Then Call getMoney(right(subjects_str,len(subjects_str)-minIndex),date1,typ,direction)
			evalbody = evalbody & right(left(subjects_str,minIndex),1)
		end if
'end if
		on error resume next
		getMoney = eval(evalbody)
		If Err.number<>0 Then getMoney = 0
		On Error GoTo 0
	end function
	Function subjectOrd(bh,typ)
		Dim rs , subject
		subject = 0
		Set rs = app.cRecord("select ord from [f_AccountSubject] where dbo.[getTopName](ord,2,1) ='"& bh &"'")
		If rs.eof = False Then subject = rs("ord")
		rs.close
		subjectOrd = subject
	end function
	Function getFlowMoney(subjects,date1,typ)
		Dim  rs ,money1, sql
		money1 = 0
		flowRecordset.Filter = "title='" & subjects &"'"
		If flowRecordset.eof = False Then
			If typ = 3 Then money1 = flowRecordset("m3")
			If typ = 2 Then money1 = flowRecordset("m2")
		end if
		getFlowMoney = money1
	end function
	Function isfirstYear(accountdate1 , month1, date1)
		Dim isfirst : isfirst = True
		Dim date_y
		if month1<=month(date1) Then
			date_y = year(date1) & "-" & month1 & "-01"
'if month1<=month(date1) Then  '
		Else
			date_y = (year(date1)-1) & "-" & month1 & "-01"
'Else '
		end if
		if datediff("m",date_y,accountdate1)<0 Then isfirst =False
		isfirstYear = isfirst
	end function
	
	Dim dataRecordset , flowRecordset , resultstr
	Sub Page_load
		app.docmodel = "IE=8"
		Dim rs ,ord ,companyName, reportTitle , abbreviated ,sourcesort, date1,accountdate1,mindate1 ,bz ,bzname, bzunit ,accountmonth1
		ord = request("sort")
		Dim moneynumber : moneynumber = Info.moneynumber
		accountmonth1 = 1
		If session("f_account")<>"" Then
			Set rs = cn.execute("select * from accountsys where ord="&session("f_account"))
			If rs.eof= False Then
				companyName = rs("companyName")
			end if
			rs.close
		end if
		sourcesort = 1
		Set rs = app.cRecord("select title,abbreviated , sourcesort from [f_Report] where ord=" &ord)
		If rs.eof = False Then
			reportTitle = rs("title")
			abbreviated = rs("abbreviated")
			sourcesort = rs("sourcesort")
		end if
		rs.close
		Call app.addDefaultScript() '加载本文件关联JS ="../skin/default/js/*.js
		Response.write "" & vbcrlf & "      <script>" & vbcrlf & "                var boxInitFlag = false;" & vbcrlf & "                function initFileLinkBox(){" & vbcrlf & "                     var $box = parent.jQuery('#lxls_by');" & vbcrlf & "                   var $div = parent.jQuery('#lxls_by_flist');" & vbcrlf & "                     if ($div.size()==0){" & vbcrlf & "                            $div = parent.jQuery(""<div id='lxls_by_flist' style='background-color:#fff;padding-top:5px;line-height:22px;padding-bottom:0px'>""+" & vbcrlf & "                                                                                        ""<b style='color:green'>生成Excel文档成功。</b>""+" & vbcrlf & "                                                                                 ""<br>""+" & vbcrlf & "                                                                                   ""<span style='color:#5b7cae'>文件下载链接：</span>""+" & vbcrlf &"                                                                                  ""<br>""+" & vbcrlf & "                                                                                   ""<div style='text-align:center'>""+" & vbcrlf & "                                                                                                ""<a onclick=\""jQuery('#lvw_xls_proc_bar').hide()\"" style='color:red' href='javascript:void(0)'>关闭对话框</a>""+" & vbcrlf & "                                                                                     ""</div>""+" & vbcrlf & "                                                                         ""</div>"");" & vbcrlf & "                               $box.append($div);" & vbcrlf & "                      }else{" & vbcrlf & "                          $div.find('.lxls_by_flink').remove();" & vbcrlf & "                   }" & vbcrlf & "                       boxInitFlag = true;" & vbcrlf & "             }" & vbcrlf & "" & vbcrlf & "               function addFileLink(obj){" & vbcrlf & "                      if (!boxInitFlag){" & vbcrlf & "                              initFileLinkBox();" & vbcrlf & "                  }" & vbcrlf & "                       var $file = parent.jQuery((obj.fileCnt>1?""<br/>"":"""")+'<a class=""lxls_by_flink"" style=""Text-Decoration:underline;"" href=""../../out/downfile.asp?fileSpec=' + obj.fileUrl + '"">'+obj.fileName+'</a>').insertBefore(parent.jQuery('#lxls_by_flist div:last'));"& vbcrlf & "               }" & vbcrlf & "" & vbcrlf & "               function showExcelProgress(v,total,current){" & vbcrlf & "                    parent.jQuery('#lxls_pv').css('width',v+'%');" & vbcrlf & "                   parent.jQuery('#lxls_t').html(v+'%'+'('+current+'/'+total+')');" & vbcrlf & "                 if (v==""100""){" & vbcrlf & "                            parent.jQuery('#lxls_status').html('导出成功！导出记录'+total+'条','请点击链接下载导出文件');" & vbcrlf & "                 }" & vbcrlf & "               }" & vbcrlf & "       </script>" & vbcrlf & "       "
		Call app.addDefaultScript() '加载本文件关联JS ="../skin/default/js/*.js
		Response.write app.DefTopBarHTML(app.virPath, "", reportTitle&"导出", "")
		app.Log.href=""
		bz = 14
		Set rs = app.cRecord("select accountdate1,bz,accountmonth1 from f_account")
		If rs.eof = False Then
			accountdate1 = rs("accountdate1")
			mindate1= rs("accountdate1")
			accountmonth1 = rs("accountmonth1")
			bz = rs("bz")
		end if
		rs.close
		Set rs = app.cRecord("select top 1 dateadd(m,1,date1) as accountdate1 from f_VoucherWord where isnull(status,0)=1 order by date1 desc")
		If rs.eof = False Then accountdate1 = rs("accountdate1")
		rs.close
		If request("date1")&""<>"" Then
			date1 = request("date1")
		else
			date1 = accountdate1
		end if
		Set rs = cn.execute("select sort1 from sortbz where id = "&bz)
		If rs.eof = False Then
			bzname = rs("sort1")
		end if
		rs.close
		Select Case bz
		Case 14 : bzunit = "元"
		Case Else
		bzunit = bzname
		End Select
		Dim xApp , xsheet
		Set xApp = server.createobject(ZBRLibDLLNameSN & ".HtmlExcelApplication")
		xApp.init Me, cn
		xApp.DisAutoRow = true
		Set xApp.cnn = cn
		Set xsheet = xApp.sheets.add(reportTitle)
		Dim cells : cells = app.cRecord("select count(1) from (select distinct groups from f_ReportHeaders where report="&ord&") cut ")(0) + app.cRecord("select count(1) from f_ReportHeaders where report="&ord)(0)
		Set xsheet = xApp.sheets.add(reportTitle)
		xsheet.WriteHtml "<table width='100%'><tr style='height:30px;'><td colspan='"& cells &"'><div align='center'><b>"& reportTitle &"</b></div></td></tr><tr style='height:30px;'><td colspan='"& cells &"'><div align='right'>"& abbreviated &"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td></tr>"&_
		"<tr style='height:30px;'>"&_
		"<td><div align='right'>编制单位：</div></td><td><div>"& companyName &"</div></td>"&_
		"<td><div align='right'>编制日期：</div></td><td><div>"& dateadd("d",-1 ,dateadd("m",1, date1)) &"</div></td>"&_
		"<td><div align='right'>编制单位：</div></td><td><div>"& companyName &"</div></td>"&_
		"<td><div align='right'><div>"&bzname&"&nbsp;</div></div></td><td><div>单位："& bzunit&"</div></td></tr>"
		Dim HeaderStr
		Dim count_cell ,count_group,groups_old
		count_cell = 0
		count_group = 0
		Set rs = app.cRecord("select * from [f_ReportHeaders] where report = "&ord&" order by groups,gate1 desc,id")
		While rs.eof = False
			If Len(HeaderStr)>0 Then HeaderStr = HeaderStr &","
			If groups_old<>rs("groups") then
				groups_old = rs("groups")
				count_group = count_group + 1
				groups_old = rs("groups")
				HeaderStr = HeaderStr  & "序号,"
			end if
			HeaderStr = HeaderStr  & rs("headerName")
			count_cell = count_cell+1
			HeaderStr = HeaderStr  & rs("headerName")
			rs.movenext
		wend
		rs.close
		xsheet.showHeader HeaderStr
		xsheet.movenext
		Response.Flush
		Dim rowIndex_old, i, groupcell_old , cell_index ,money1
		rowIndex_old = 0
		groupcell_old = 0
		cell_index = 0
		i = 0
		Dim currProcV , PreProcV
		Dim accountid : accountid = session("f_account")
		If accountid &""="" Then accountid = 0
		cn.cursorlocation = 3
		Dim sql,hascheckOut
		hascheckOut = 0
		If app.cRecord("select 1 from f_VoucherWord where  isnull(status,0)=1 and date1='"&dateadd("m",-1,date1)&"'").eof = False Then
			hascheckOut = 0
			hascheckOut = 1
		end if
		sql = "select "&_
		"app.iif(month(date1) = accountmonth1 ,""0"" , ""(case when isnull(m1.id,0)>0 or ""& hascheckOut &"" =1 then isnull(m1.money3,0) when isnull(m2.id,0)>0 then  isnull(m2.money3,0) else 0 end) "" )" &_
		"as m1,isnull(l.money2,0) as m2, (isnull(l.money2,0)+"&_
		") as m3,(select right('00'+bh,3) from f_FlowSubject where ord=s.parentid)+'.'+ right('00'+bh,3) as title" &_
		"  from [f_FlowSubject] s "&_
		"  left join ( "&_
		"          select b.[FlowSubject], isnull(sum(isnull(money_J,0)+isnull(money_D,0)),0) as money2 "&_
		"  left join ( "&_
		"          from [f_Voucher] a "&_
		"          inner join [f_VoucherList] b on a.[voucherHSmonth]='"&date1&"' and a.del=1 and a.[status]>1 and a.[status]<>4 and b.[Voucher] = a.ord and isnull(FlowSubject,0)>0 group by  b.[FlowSubject] "&_
		"          ) l on s.ord=l.FlowSubject "&_
		"  left join [f_accumulFlow] m1 on m1.sort1=1 and m1.FlowSubject = s.ord and m1.date1=dateadd(m,-1,'"&date1&"') "&_
		"          ) l on s.ord=l.FlowSubject "&_
		"  left join [f_accumulFlow] m2 on m2.sort1=0 and m2.FlowSubject = s.ord "
		Set flowRecordset = app.cRecord(sql)
		Dim C1 : C1 = app.cRecord("select count(1) from (select distinct rowindex from f_reportcells where header in (select id from f_ReportHeaders where report="& ord &")) cut ")(0)
		Set dataRecordset = app.cRecord("exec [erp_subjbalance_List]  "& Info.user &",'"&date1&"','2',0,"& sourcesort &"")
		Dim dbname : dbname = app.iif(accountid>1,"[ZB_FinanDB" & Application("__saas__company") & "_" & session("f_account") & "]..","")
		Set rs = app.GetCacheRecord("exec " & dbname &"erp_Acccount_report " & ord &",'"&date1&"'","select * from "& dbname &"f_report where ord="&ord& "; select * from "& dbname &"f_ReportHeaders where report="&ord& "; select * from "& dbname &"f_ReportCells;",false,false,"")
		While rs.eof=False
			If rowIndex_old <> rs("rowIndex") Then
				If rowIndex_old>0 Then
					xsheet.movenext
					cell_index = 0
					currProcV = Clng(rowIndex_old/C1*100)
					If PreProcV < currProcV Then
						showExcelProc 100, currProcV  ,C1 , rowIndex_old
						PreProcV = currProcV
						Response.Flush
					end if
				end if
				rowIndex_old = rs("rowIndex")
				groupcell_old = rs("groups")
				i = i + 1
				groupcell_old = rs("groups")
				xsheet.WriteHtmlCell i ,"align='center'"
			ElseIf groupcell_old<>rs("groups") Then
				groupcell_old = rs("groups")
				xsheet.WriteHtmlCell i ,"align='center'"
			end if
			If rs("attribute")=0 Then
				xsheet.writestr ""&rs("body")&""
			else
				If Len(rs("body"))>0 Then
					on error resume next
					resultstr = ""
					money1 =eval(getFormulaValue(rs("body"), date1 ))
					If Err.number<>0 Then money1 = 0
					On Error GoTo 0
					If Len(money1&"")=0 Then money1 = 0
					money1 = FormatNumber(money1,moneynumber,-1,0,-1)
					If Len(money1&"")=0 Then money1 = 0
					xsheet.WriteMoney money1
				else
					xsheet.writecell "&nbsp;"
				end if
			end if
			cell_index = cell_index + 1
			xsheet.writecell "&nbsp;"
			rs.movenext
		wend
		rs.close
		dataRecordset.close
		currProcV = Clng(rowIndex_old/C1*100)
		If PreProcV < currProcV Then
			showExcelProc 100, 100 ,C1 , C1
			PreProcV = currProcV
			Response.Flush
		end if
		Dim tfile
		Dim tit : tit = xApp.cFileName(reportTitle)
		tfile=Server.MapPath(tit & ".xls")
		xApp.save tfile
		xApp.dispose
		tfile = xApp.HexEncode(tfile)
		Set xApp = Nothing
		Response.write "" & vbcrlf & "     <script>addFileLink({fileUrl:"""
		Response.write tfile
		Response.write """,fileName:"""
		Response.write tit & ".xls"
		Response.write """,fileCnt:0});</script>  " & vbcrlf & " "
	end sub
	Function showExcelProc(ByVal count , ByVal procv , mrecordcount, exportRecIdx)
		Dim jd
		If procv > 100 Then procv = 100
		If Response.IsClientConnected = False Then
			Err.raise 4908, "ListView", "客户端已经断开连接，ExcelProc过程强制终止。"
			showExcelProc =  False
			Exit Function
		else
			showExcelProc = True
		end if
		Response.write "<script language='javascript'>showExcelProgress('"&procv&"','"&mrecordcount&"','"&exportRecIdx&"');</script>"
		Response.flush
	end function
	
%>
