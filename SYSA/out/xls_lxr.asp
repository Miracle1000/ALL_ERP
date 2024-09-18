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
	
	class moveHeaderColItem
		public colspan
		public text
		public rowspan
		public fullname
		public splitCell
		Public htmlid
		Public parenthtmlid
	end class
	Class zdyMapsItem
		Public title
		Public width
		Public dbIndex
		Public name
		Public visible
	End Class
	Class InsertValueItem
		Public name
		Public value
	End Class
	Class lvwDataCollection
		Dim datas()
		Dim names()
		Public count
		public sub class_initialize
			count = 0
		end sub
		Public Default Function item(ByVal index)
			Dim i
			If isnumeric(index) Then
				item = datas(index)
			else
				For i=0 To count -1
					item = datas(index)
					If names(i) = LCase(index) Then
						item = datas(i)
						Exit function
					end if
				next
				item = ""
			end if
		end function
		Public Function add(name, value)
			add = count
			ReDim Preserve datas(count)
			ReDim Preserve names(count)
			names(count) = LCase(name)
			datas(count) = value
			count = count + 1
'datas(count) = value
		end function
	End class
	class lvwColumn
		public display
		public visible
		public title
		Public ectitle
		public dbname
		private mwidth
		public selid
		public defHTML
		public edit
		Public bz
		public ico
		public selfItem
		public cssName
		public dbIndex
		public align
		public align2
		public canSum
		Public cangroupsum
		public formatText
		public minWidth
		Public sortType
		Public ContentStyle
		Public itemstyle
		Public formatbit
		public execdisplay
		public splitCell
		public evalName
		public evalCode
		Public IsaccWidth
		Public distinctSpaceCol
		Public Formula
		Public JoinFields
		Public JoinVisible
		Private mlinkFormat
		private linkFormatArray
		Public excelAlign
		Public tryCurrSumWhenRepeat
		Public formulaIsRowRepeat
		Public ignoreNonnumeric
		Public ignoreHTMLTag
		Public cansort
		Public url
		Private muiType, mdbtype
		Public defaultValue
		Public notnull
		Public maxsize
		Public minvalue
		Public maxvalue
		Public vailmsg
		Public source
		Public boxWidth
		Public unit
		Public EditLock
		Public onclick
		Public js
		Public onchange
		Public onlyread
		Public canhide
		Public canBatchInput
		Private mSourceData
		Public treesource
		Public Function CreateTreeSource
			If Not app.existsProc("app_sys_treeviewCallBack") Then
				Err.raise 9085, "ListView.CreateTreeSource执行失败", "缺少TreeClass对象，创建Tree结构数据源，需要先应用/sdk/treeview.asp公共文件。"
			end if
			source = "tree:"
			Set treesource = New TreeView
			Set CreateTreeSource = treesource
		end function
		Public Property get dbtype
		dbtype = mdbtype
		End Property
		Public Property Let dbtype(nv)
		Select Case LCase(nv)
		Case "str"
		Case "int" : formatbit = 0
		Case "money" : formatbit = Info.moneynumber
		case "commprice" :  formatbit = Info.CommPriceDotNum
		case "salesprice" : formatbit = Info.SalesPriceDotNum
		case "storeprice" : formatbit = Info.StorePriceDotNum
		case "financeprice":formatbit = Info.FinancePriceDotNum
		Case "number": formatbit = Info.floatnumber
		Case "hl"  : formatbit = Info.hlnumber
		Case "zk"  : formatbit = Info.DiscountNumber
		Case "datetime":
		Case Else
		Err.raise 1000 , "组件参数问题",  "ListView无法识别列【" & dbname & "】的DB类型【" & nv & "】，目前只支持类型：str, int, money, number, hl, zk"
		End Select
		mdbtype = nv
		End property
		Public Property get uiType
		uiType = muiType
		End Property
		Public Property Let uiType(nv)
		Select Case LCase(nv)
		Case "text"
		Case "money"
		Case "number"
		Case "hl"
		Case "zk"
		Case "int"
		Case "datetime"
		Case "time"
		Case "date"
		Case "select"
		Case "checkbox"
		Case "radio"
		Case "textarea"
		Case "html"
		Case "list"
		Case "hidden"
		Case "indexcol11"
		Case "indexcol10"
		Case "indexcol01"
		Case "editcol"
		Case "tree"
		Case ""
		Case Else
		Err.raise 1000 , "组件参数问题",  "ListView无法识别列【" & dbname & "】的UI类型【" & nv & "】，目前只支持类型：text、datetime、date、select、checkbox、radio、textarea、html"
		End Select
		muiType = nv
		End Property
		Public property Get linkFormat
		linkFormat = mlinkFormat
		End Property
		Public Property let linkFormat(v)
		mlinkFormat = v
		If Len(v) > 0 Then
			Dim rs
			linkFormatArray = Split(v,Chr(1))
			ReDim Preserve linkFormatArray(7)
			linkFormatArray(7) = linkFormatArray(5)
			linkFormatArray(5) = app.power.GetPowerIntro(linkFormatArray(3), 1)
			If linkFormatArray(3) = 21 Then
				if app.power.existsPower(21, 14) Then
					linkFormatArray(6) = ""
				else
					linkFormatArray(6) = "0"
				end if
			else
				linkFormatArray(6) = app.power.GetPowerIntro(linkFormatArray(3), 14)
			end if
		end if
		End property
		public property get Width
		width = mwidth
		end Property
		public property let Width(v)
		if isnumeric(v) and minwidth > 0 then
			if v < minwidth then
				v = minwidth
			end if
		end if
		mwidth = v
		end Property
		Public Property Get EditAttrs
		Dim msize : msize = maxsize
		If muiType <> "" Then
			Select Case muiType
			Case "number", "money"
			If isnumeric(msize) = False Or msize = "" Then msize = 32
			If CLng(msize) > 32 Then msize = 32
			EditAttrs = " ei=1 ui='" & muiType & "' ldb=1 maxlength='" & msize & "' nu=" & Abs(notnull) & " max='"& maxvalue &"' min='" & minvalue  &"' "
			Case Else
			If isnumeric(msize) = False Or msize = "" Then msize = 200
			EditAttrs = " ei=1 ui='" & muiType & "' ldb=1 nu=" & Abs(notnull) & " max='"& msize &"'"
			End Select
		end if
		End Property
		Public Property Get EditAttrsJson
		Dim msize : msize = maxsize
		If muiType <> "" Then
			Select Case muiType
			Case "number", "money"
			If isnumeric(msize) = False Or msize = "" Then msize = 32
			If CLng(msize) > 32 Then msize = 32
			EditAttrsJson = "{maxsize:""" & msize & """,nu:" & Abs(notnull) & ",max:"""& maxvalue &""",min:""" & minvalue  &"""}"
			Case Else
			If isnumeric(msize) = False Or msize = "" Then msize = 200
			EditAttrsJson = "{nu:" & Abs(notnull) & ",maxsize:"""& msize &"""}"
			End Select
		else
			EditAttrsJson = "null"
		end if
		End Property
		Public Function doReadHtml(ByVal cvalue)
			Select Case muiType
			Case "select":
			If mSourceData Is Nothing Then
				Set mSourceData = app.GetSource(source)
			end if
			doReadHtml = mSourceData.getText(cvalue)
				Case else
				doReadHtml = cvalue
					End select
				end function
		Public Function doEditHtml(ByVal nv, ByVal cvalue ,ByVal extAttr)
			Dim w1, options, njs , vstr
			If InStr(boxWidth, "%") > 0 Then
				If Isnumeric(width) then
					w1 = CLng(width * CDbl(Replace(boxWidth, "%", "")) / 100) & "px"
				end if
			else
				w1 = boxWidth & "px"
			end if
			njs = js
			If Len(cvalue)>0 Then cvalue = "_" & cvalue
			If onclick <> "" Then njs = njs & " onclick=""" & Replace(onclick, """", "\""") & """"
			If onchange <> "" Then njs = njs & " onpropertychange='app.lvweditor.__U_C(this)' "
			Select Case muiType
			Case "text"               :       doEditHtml = "<input type='text' name='" & dbname &  cvalue & "' " & njs & " style='width:" & w1 & "' maxlength='" & maxsize & "' value='" & app.HtmlConvert(nv) & "'>" & app.iif(notnull, " <span class='red'>*</span>", "")
			Case "money"  :       doEditHtml = "<input type='text' name='" & dbname &  cvalue & "' " & njs & " extAttr='"&extAttr&"'  style='width:70px;text-align:right' maxlength='32' value='" & app.HtmlConvert(Replace(nv&"",",","")) & "'  onpropertychange=""formatData(this,'money',2);"" onkeyup=""value=value.replace(/[^\d\.\-]/g,'');checkDot(this,'" & Info.moneynumber & "')"" >" & app.iif(notnull, " <span class='red'>*</span>", "")
			Case "commprice"      :       doEditHtml = "<input type='text' name='" & dbname &  cvalue & "' " & njs & " extAttr='"&extAttr&"'  style='width:70px;text-align:right' maxlength='32' value='" & app.HtmlConvert(Replace(nv&"",",","")) & "'  onpropertychange=""formatData(this,'CommPrice',2);"" onkeyup=""value=value.replace(/[^\d\.\-]/g,'');checkDot(this,' & Info.CommPriceDotNum & ')"" > "& app.iif(notnull, " <span class='red'>*</span>", "")
			Case "salesprice"     :       doEditHtml = "<input type='text' name='" & dbname &  cvalue & "' " & njs & " extAttr='"&extAttr&"'  style='width:70px;text-align:right' maxlength='32' value='" & app.HtmlConvert(Replace(nv&"",",","")) & "'  onpropertychange=""formatData(this,'SalesPrice',2);"" onkeyup=""value=value.replace(/[^\d\.\-]/g,'');checkDot(this,'" & Info.SalesPriceDotNum & "')"" >" & app.iif(notnull, " <span class='red'>*</span>", "")
			Case "storeprice"     :       doEditHtml = "<input type='text' name='" & dbname &  cvalue & "' " & njs & " extAttr='"&extAttr&"'  style='width:70px;text-align:right' maxlength='32' value='" & app.HtmlConvert(Replace(nv&"",",","")) & "'  onpropertychange=""formatData(this,'StorePrice',2);"" onkeyup=""value=value.replace(/[^\d\.\-]/g,'');checkDot(this,'" & Info.StorePriceDotNum & "')"" >" & app.iif(notnull, " <span class='red'>*</span>", "")
			Case "financeprice"   :       doEditHtml = "<input type='text' name='" & dbname &  cvalue & "' " & njs & " extAttr='"&extAttr&"'  style='width:70px;text-align:right' maxlength='32' value='" & app.HtmlConvert(Replace(nv&"",",","")) & "'  onpropertychange=""formatData(this,'FinancePrice',2);"" onkeyup=""value=value.replace(/[^\d\.\-]/g,'');checkDot(this,'" & Info.FinancePriceDotNum & "')"" >" & app.iif(notnull, " <span class='red'>*</span>", "")
			Case "number" :       doEditHtml = "<input type='text' name='" & dbname &  cvalue & "' " & njs & " style='width:80px' maxlength='32' value='" & app.HtmlConvert(Replace(nv&"",",","")) & "'  onpropertychange=""formatData(this,'number',2);"" onkeyup=""value=value.replace(/[^\d\.]/g,'');checkDot(this,'" & Info.floatnumber & "')"" >" & app.iif(notnull, " <span class='red'>*</span>", "")
			Case "hl"             :       doEditHtml = "<input type='text' name='" & dbname &  cvalue & "' " & njs & " style='width:45px' maxlength='32' value='" & app.HtmlConvert(nv) & "' onkeyup=""value=value.replace(/[^\d\.]/g,'');checkDot(this,'" & Info.HlNumber & "')"" >" & app.iif(notnull, " <span class='red'>*</span>", "")
			Case "zk"             :       doEditHtml = "<input type='text' name='" & dbname &  cvalue & "' " & njs & " style='width:80px' maxlength='32' value='" & app.HtmlConvert(nv) & "' onkeyup=""value=value.replace(/[^\d\.]/g,'');checkDot(this,'" & Info.DiscountNumber & "')"" >" & app.iif(notnull, " <span class='red'>*</span>", "")
			Case "datetime"   :       doEditHtml = "<input type='text' name='" & dbname &  cvalue & "' " & njs & " style='width:135px' maxlength='' onclick='datedlg.showDateTime()' readonly value='" & app.format(nv, "yyyy-mm-dd hh:nn:ss") & "'>" & app.iif(notnull, " <span class='red'>*</span>", "")
'span>", "")
			Case "time"               :       doEditHtml = "<input type='text' name='" & dbname &  cvalue & "' " & njs & " style='width:85px' maxlength='' onclick='datedlg.showTime()' readonly value='" & app.format(nv, "yyyy-mm-dd hh:nn:ss") & "'>" & app.iif(notnull, " <span class='red'>*</span>", "")
'span>", "")
			Case "date"               :       doEditHtml = "<input type='text' name='" & dbname &  cvalue & "' " & njs & " style='width:85px' onclick='datedlg.show()' readonly value='" & app.format(nv, "yyyy-mm-dd") & "'>" & app.iif(notnull, " <span class='red'>*</span>", "")
'span>", "")
			Case "select"     :
			If mSourceData Is Nothing Then
				Set mSourceData = app.GetSource(source)
			end if
			If InStr(1,njs, "disabled",1) > 0 Then
				doEditHtml = "<input type='hidden' name='" & dbname &  cvalue & "' value=""" & app.HtmlConvert(nv)  & """><select " & njs & " id='" & dbname  &  cvalue & "'>" & mSourceData.createHTML("select", nv & "") & "<select>"
				else
					doEditHtml = "<select " & njs & " name='" & dbname &  cvalue & "'>" & mSourceData.createHTML("select", nv & "") & "<select>"
					end if
					Case "checkbox" : doEditHtml = "<input  " & njs & " type='checkbox'>"
					Case "radio"      :       doEditHtml = "<input  " & njs & " type='radio'>"
					Case "textarea" : doEditHtml = "<textarea  " & njs & " class='l_e_tarea' style='width:" & w1 & "px;height:18px'>" & app.HtmlConvert(nv) & "</textarea>"
					Case "html"     : doEditHtml = nv
					Case "hidden"   :
					doEditHtml = nv
						vstr = nv
						If mdbtype="money" Or mdbtype="number" Or mdbtype="hl" Or mdbtype="zk" Then vstr = Replace(vstr,",","")
						doEditHtml = doEditHtml & "<input type='hidden' name='" & dbname &  cvalue & "' " & njs & " extAttr='"&extAttr&"' style='width:" & w1 & "' maxlength='" & maxsize & "' value='" & app.HtmlConvert(vstr) & "'>"
							Case ""     :             doEditHtml = nv
							End Select
						end function
		Private Sub Class_Terminate()
			Set mSourceData = nothing
		end sub
		public sub class_initialize
			display = ""
			visible = true
			mdbtype = ""
			selid = 0
			defhtml = ""
			edit = false
			width= 140
			ico = ""
			selfItem = false
			cssName = "lvw_cell"
			dbIndex = -1
'cssName = "lvw_cell"
			align = "center"
			minWidth = 0
			sortType = 0
			formatbit = Info.floatnumber
			execdisplay = ""
			splitCell  = false
			canSum = True
			cangroupsum = True
			JoinVisible = False
			onlyread = false
			excelAlign = ""
			tryCurrSumWhenRepeat = True
			ignoreNonnumeric = False
			ignoreHTMLTag = True
			notnull     = false
			maxsize = 200
			vailmsg = ""
			boxWidth="70%"
			canhide = True
			cansort = true
			Set mSourceData = nothing
		end sub
		Public Default Property get items(index)
		Select Case index
		Case 1: defhtml
		Case 2: evalName
		Case 3: evalCode
		Case 4: title
		Case 5: display
		Case 6: visible
		Case 7: width
		Case 8: dbtype
		Case 9: formattext
		Case 10: Formula
		Case 11: selid
		Case 12: edit
		Case 13: ico
		Case 14: selfitem
		Case 15: cssname
		Case 16: dbIndex
		Case 17: align
		Case 18: sorttype
		Case 19: linkFormat
		Case 20: align2
		Case 21: canSum
		Case 22: JoinVisible
		Case 23: JoinFields
		Case 24: formulaIsRowRepeat
		Case 25: tryCurrSumWhenRepeat
		Case 26: ignoreNonnumeric
		Case 27: ignoreHTMLTag
		Case 28: cangroupsum
		Case 29: uiType
		Case 30: defaultValue
		Case 31: notnull
		Case 32: maxsize
		Case 33: vailmsg
		Case 34: source
		Case 35: boxWidth
		Case 36: unit
		Case 37: EditLock
		Case 38: js
		Case 39: onclick
		Case 40: onchange
		Case 41: minvalue
		Case 42: maxvalue
		Case 43: canhide
		Case 44: cansort
		Case 45: canBatchInput
		Case 46: excelAlign
		case 47: ContentStyle
		End select
		End Property
		Public Property let items(index, v)
		Select Case index
		Case 1: defhtml = v
		Case 2: evalName = v
		Case 3: evalCode = v
		Case 4: title = v
		Case 5: display = v
		Case 6: visible = v
		Case 7: width = v
		Case 8: dbtype = v
		Case 9: formattext = v
		Case 10: Formula = v
		Case 11: selid = v
		Case 12: edit = v
		Case 13: ico = v
		Case 14: selfitem = v
		Case 15: cssname = v
		Case 16: dbIndex = v
		Case 17: align = v
		Case 18: sorttype = v
		Case 19: linkFormat = v
		Case 20: align2 = v
		Case 21: canSum = v
		Case 22: JoinVisible = v
		Case 23: JoinFields = v
		Case 24: formulaIsRowRepeat = v
		Case 25: tryCurrSumWhenRepeat = v
		Case 26: ignoreNonnumeric = v
		Case 27: ignoreHTMLTag = v
		Case 28: cangroupsum = v
		Case 29: uiType=v
		Case 30: defaultValue=v
		Case 31: notnull=v
		Case 32: maxsize=v
		Case 33: vailmsg=v
		Case 34: source=v
		Case 35: boxWidth=v
		Case 36: unit=v
		Case 37: EditLock=v
		Case 38: js = v
		Case 40: onchange = v
		Case 41: minvalue = v
		Case 42: maxvalue = v
		Case 43: canhide = v
		Case 44: cansort = v
		Case 45: canBatchInput=v
		Case 46: excelAlign = v
		case 47: ContentStyle = v
		End select
		End Property
		Public Sub setLink(titleCell,IDcell, CreatorCell,   qxlb, billID)
			linkFormat = titleCell & Chr(1) & IDcell & Chr(1) &  CreatorCell & Chr(1) & qxlb & Chr(1) & billID & chr(1) & ""
		end sub
		Public Sub setLink2(titleCell,IDcell, CreatorCell,   qxlb, billID, shareFields)
			linkFormat = titleCell & Chr(1) & IDcell & Chr(1) &  CreatorCell & Chr(1) & qxlb & Chr(1) & billID & chr(1) &  shareFields
		end sub
		Public Function CLinkHtml(rs, isExcel, currvalue)
			Dim title, lnk
			Dim ID, share, isshare
			If rs.eof= True Then CLinkHtml = ""  : Exit function
			Dim creator : creator = rs.fields(linkFormatArray(2)).value
			Dim qxlb : qxlb = linkFormatArray(3)
			Dim OrderId : OrderId = linkFormatArray(4)
			If Len(linkFormatArray(0)) > 0 Then
				title = rs.fields(linkFormatArray(0)).value
			else
				title = currvalue
			end if
			If linkFormatArray(5) <> "" Then
				isshare = false
				If len(linkFormatArray(7)) > 0 Then
					share = rs(linkFormatArray(7))
					If share = "" Or ISNULL(share) Then share = "-222"
'share = rs(linkFormatArray(7))
					isshare = ( share = "1" Or InStr(1, ","&share&"," , ","& info.user &"," ,1)>0)
				end if
				If isshare=1 Or isshare=True Then isshare = True
				If InStr("," & linkFormatArray(5) & ",", "," & creator & ",") = 0 and not isshare Then
					CLinkHtml = ""
					Exit function
				end if
			end if
			If len(linkFormatArray(1))>0 then
				Id = rs.fields(linkFormatArray(1)).value
			else
				id = -1
				Id = rs.fields(linkFormatArray(1)).value
			end if
			If ID & "" = "" Or Not isnumeric(ID) Then ID = -1
			Id = rs.fields(linkFormatArray(1)).value
			If isExcel = True Or id <0 Then CLinkHtml = title  : Exit Function
			lnk  = True
			If linkFormatArray(6) <> "" Then
				If InStr("," & linkFormatArray(6) & ",", "," & creator & ",") = 0 Then
					lnk  = false
				end if
			end if
			If Len(title) = 0 Then title = "<i>主题为空</i>"
			If lnk = False Then CLinkHtml = title : Exit Function
			If OrderId > 0 Then
				If Len(ID&"") = 0 or ID <= 0 Then
					CLinkHtml = "【已被删除】"
				else
					CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "manufacture/inc/readbill.asp?orderID=" & orderID & "&Id=" & ID & "','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				end if
			else
				Select Case OrderId
				case "-1":
'Select Case OrderId
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "../SYSN/view/sales/contract/ContractDetails.ashx?ord="&app.base64.pwurl(ID)&"&view=details','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				case "-2":
'false;"">" & title & "</a>"
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "../SYSN/view/store/kuout/kuoutdetails.ashx?ord=" & app.base64.pwurl(ID) & "&view=details','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				case "-3"
'lse;"">" & title & "</a>"
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "../SYSN/view/store/kuin/kuin.ashx?ord=" & app.base64.pwurl(ID) & "&view=details','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				case "-4"
'& title & "</a>"
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "../SYSN/view/store/yugou/YuGou.ashx?view=details&ord=" & app.base64.pwurl(ID) & "','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">"& title & "</a>"
				case "-5"
'& title & </a>
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "pay/paydetail.asp?ord=" & app.base64.pwurl(ID) & "','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				case "-6"
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "product/content.asp?ord=" & app.base64.pwurl(ID) & "','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				Case "-7"
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "chance/content.asp?ord=" & app.base64.pwurl(ID) & "','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				case "-8"
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "Repair/RepairOrderContent.asp?id=" & ID & "','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				case "-9"
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "work/content.asp?ord=" & app.base64.pwurl(ID) & "','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				case "-10"
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "person/content.asp?ord=" & app.base64.pwurl(ID) & "','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				Case "-11"
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "contractth/content.asp?ord=" & app.base64.pwurl(ID) & "','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				case "-12"
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "Repair/Content.asp?ord=" & app.base64.pwurl(ID) & "','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				case "-13"
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "work2/content.asp?ord=" & app.base64.pwurl(ID) & "','newwin_gys','width=900,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				case "-14"
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "../SYSN/view/store/caigou/caigoudetails.ashx?view=details&ord=" & app.base64.pwurl(ID) & "','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				case "-15"
'false;"">" & title & "</a>"
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "MicroMsg/goods/content.asp?ID=" & app.base64.pwurl(ID) & "','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				case "-1001"
				CLinkHtml = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "hrm/perform_content.asp?ord=" & app.base64.pwurl(ID) & "','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				Case Else
				CLinkHtml = "不识别【" & orderID & "】链接项"
				End Select
			end if
		end function
	end class
	class lvwColCollection
		private cols
		public count
		Public isZdyMode
		public selcol
		public sub class_initialize
			count = 0
			isZdyMode = 0
			Set selcol = nothing
			redim cols(0)
		end sub
		Public Sub clearColWidth
			Dim i
			for i = 0 to ubound(cols)
				cols(i).width = ""
			next
		end sub
		public function add(title,dbname)
			dim index , nd, c
			count = count + 1
'dim index , nd, c
			index = count - 1
'dim index , nd, c
			if count > 1 then
				redim preserve cols(index)
			end if
			set cols(index) = new lvwColumn
			set c = cols(index)
			c.title =  title
			c.dbname = dbname
			set add = c
		end function
		public function insert(title , dbname , index)
			dim i, nitem
			if index > count then
				set insert = add(title,dbname)
				exit function
			end if
			set nitem = add(title,dbname)
			if index <1  then index = 1
			for i =  count - 1  to index  step -1
'if index <1  then index = 1
				set cols(i) = cols(i-1)
'if index <1  then index = 1
			next
			set cols(index-1) = nitem
'if index <1  then index = 1
			set insert = nitem
		end function
		Public Function cItem(ByVal dbname)
			dbname = Replace(dbname,Chr(1),"")
			Set cItem = add(dbname,dbname)
		end function
		public default function Item(index)
			dim i, isdb
			if isnumeric(index)  And Len(index & "")<4 then
				on error resume next
				set item = cols(index-1)
'if isnumeric(index)  And Len(index & "")<4 then
				if err.number <> 0 then
					response.clear
					Response.write "组件listivw警告：不存在下标为【" & index & "】的列。"
					cn.close
					call AppEnd
				end if
			else
				If index = "@@选择" Or index="@@序号" Then
					If selcol Is Nothing Then  Set selcol = New lvwColumn
					Set item = selcol
					Exit function
				end if
				isdb = InStr(index, Chr(1)) > 0
				index = replace(index,Chr(1),"")
				If isdb then
					for i = 0 to ubound(cols)
						set item = cols(i)
						if lcase(Replace(item.dbname,"<br>","")) = lcase(Replace(index,"<br>","")) Then
							exit function
						end if
					next
				else
					for i = 0 to ubound(cols)
						set item = cols(i)
						if lcase(Replace(item.dbname,"<br>","")) = lcase(Replace(index,"<br>","")) Then
							exit function
						end if
					next
				end if
				set item = New lvwColumn
			end if
		end function
		Public Function GetItemByDBname(dbname)
			Dim c , i
			for i = 0 to ubound(cols)
				set c = cols(i)
				if  LCase(c.dbname)=LCase(dbname) Then
					Set  GetItemByDBname = c
					exit function
				end if
			next
			Set  GetItemByDBname = nothing
			response.clear
			Response.write "组件listivw警告：不存在dbname为【" & dbname & "】的列。"
			cn.close
			call AppEnd
		end function
		public sub clear
			count = 0
			redim cols(0)
		end sub
		public sub remove(index)
			dim i
			count = count - 1
'dim i
			for i = index - 1 to  count-1
'dim i
				set cols(i) = cols(i+1)
'dim i
			next
			redim preserve cols(count-1)
'dim i
		end sub
	end Class
	
	Class listViewEditConfig
		private misOpen
		Public candel
		Public candelExpress
		Public canistexpress
		Public canadd
		Public rowmove
		Public rowedit
		Public rowhide
		Public Default Property Get isOpen
		isOpen = misOpen
		End Property
		Public  Property let isOpen(nvalue)
		misOpen = nvalue
		If nvalue = True Then
			If app.ismobile = False Then
				If request.form("__msgid") = "" Then
					app.addScriptPath app.virpath & "skin/" & info.Skin & "/js/listview.edit.js"
				end if
			end if
		end if
		End Property
		Public sub class_initialize
			misOpen = false
			candel = true
			canadd = True
			rowmove = True
			rowedit = True
			rowhide = false
		end sub
	End class
	class listview
		public id
		private rs
		Private rs_group_sum
		private msql
		private mrecordcount
		private htmlarray
		private htmlcount, htmlubound
		public pagesize
		public dbmodel
		public checkbox
		public indexbox
		Public checkvalue   '选择框的值字段, 如lvw.checkvalue="ID"
		Public extAttribute '编辑模式下 对象扩展属性  如lvw.extAttribute="ORD"
		Public rowcolorkey
		public toolbar
		public headers
		public pageindex
		public width
		Public endHtml
		Public height
		public addlink
		private fs
		public border
		public scroll
		public Autoresize
		public excelmode
		Public excelextIntro
		Public showNullDate
		public moreheadermode
		public minCellwidth
		Public cansort
		Public sortSql
		Public showfullopen
		Public CurrSum
		Public AllSum
		public CanPageSize
		public splitColor
		public isCallback
		public fixedCell
		Public fixedHead
		public ZoreColor
		Public isshow_ymc
		public isshow_xmc
		Public isshow_anotherName
		Public isshow_formula
		Public isshow_visible
		Public isPageReckon
		Public FaStr
		Public excelsql
		Public headExplan
		Public headExplanName
		Public MulExplan
		Private msettag
		Private mtagData
		Public noscrollModel
		Public colbackPost
		Public dataAttr
		Public ServerConfig
		Public headNameJoin
		Public PreMsg
		Public IsAccWidth
		Public IsAbsWidth
		Public distinctSpaceCol
		Public IsSqlSort
		Public cbWaitMsg
		Public PageButtonAlign
		Public FinanDBModel
		Private xlsApp, xsheet
		Private exportRecCnt
		Private exportRecIdx
		Private exportRecCurCnt
		Private exportSheetCnt
		Private exportSqlGroupIdx
		Private exportSheetCntByGroup
		Private exportFileCnt
		Private exportHeaderHtml
		Private prevValues()
		Private PreRptProcIndex
		Private anotherstr, anothers, mEdit
		Public pageMode
		Public excelcallbackproc
		Public mxzdyId
		Private zdyMaps
		Private zdycount
		Private errsql
		Private checkvalueIndex
		Private prer_owindex
		Public css
		Public PageBar
		Public datawidth
		Public isInsertModel
		Public oldPageSizeUI
		Public HeaderPageSizeUI
		Public checkboxwidth
		Private mHeaderConfigKey
		Public currsumarray
		Public allsumarray
		Public recordPerSheet
		Public sheetPerFile
		Public exportFileName
		Public canSplitFormula_And
		Public canSplitFormula_Or
		Private curSheetTitle
		Private needWriteFile
		Private exportJsInitFlag
		Private meditkey
		Public RowSplitFields
		Public RowSplitSum
		Public ResetSql
		Public RowEditlock  '行编辑锁定表达式， 如 RowEditlock ="rs"
		Public recordcanedit
		Public vPath
		Public CacheKeys
		Public CacheRules
		Public layout
		Public colResize
		Public jsonEditModel
		Public cellborder
		Private m_autoAppendUrlParams
		Public istreegrid
		Public Property Get HeaderConfigKey
		HeaderConfigKey = mHeaderConfigKey
		End Property
		Public Property let HeaderConfigKey(v)
		mHeaderConfigKey = v
		mMd5Key16 = ""
		End property
		Public Property Let autoAppendUrlParams(v)
		If typename(v) <> "Boolean" Then
			Err.raise 10000, "listview属性错误", " 属性【autoAppendUrlParams】只支持布尔类型"
		else
			m_autoAppendUrlParams = v
		end if
		End Property
		Private editvalues
		Private ColMaps
		Private curr_rowindex, userconfig, mMd5Key16
		Public DataOverflow
		Public Property Get record
		Set record=rs
		End Property
		Public Property set record(ByVal newrs)
		Set rs=newrs
		End property
		Public Property Get editkey         '编辑模式下唯一标识字段名称， 如 me.editkey = "id"
		editkey = meditkey
		End Property
		Public Property let editkey(nv)             '编辑模式下唯一标识字段名称， 如 me.editkey = "id"
		If Len(msql) > 0 Then
			Err.raise 10000, "listview组件错误", " 只有在【sql】属性赋值前才能对【EditKey】属性进行赋值。"
		end if
		meditkey = LCase(nv)
		End Property
		Public  Property Get Edit
		Set edit = mEdit
		End Property
		Public  Property let Edit(nv)
		mEdit.isopen = nv
		End property
		Public property get tagData
		tagData = mtagdata
		end Property
		Public property let tagData(v)
		If msettag = False then
			mtagdata = v
		end if
		end Property
		Public Property Get EditDatas(ByVal dbname)
		Dim c, i
		If isarray(editvalues) Then
			c = ubound(editvalues)
			For i = 0 To c
				If LCase(editvalues(i)(0)) = LCase(dbname) Then
					EditDatas = editvalues(i)(1)
					Exit property
				end if
			next
		end if
		EditDatas = rs(dbname).value
		End Property
		Private Function getCurrEditValue(ByVal dbname)
			getCurrEditValue = EditDatas(dbname)
		end function
		Public Property let EditDatas(ByVal dbname, ByVal nvalue)
		Dim c, i
		If isarray(editvalues) Then
			c = ubound(editvalues)
			For i = 0 To c
				If LCase(editvalues(i)(0)) = LCase(dbname) Then
					editvalues(i)(1) = nvalue
					Exit property
				end if
			next
			ReDim Preserve editvalues(c+1)
			Exit property
			editvalues(c + 1) =  array(dbname,nvalue)
			Exit property
		else
			ReDim editvalues(0)
			editvalues(0) = array(dbname,nvalue)
		end if
		End Property
		Private Sub AutoSplitSheetOrFile(rowData,isRepeatRow)
			If App.existsProc("App_OnListviewExcelAddSheet") Then
				Dim newHeader : newHeader = false
				If App_OnListviewExcelAddSheet(me,  rowData , isRepeatRow , newHeader) Then
					If exportSheetCnt < sheetPerFile Then
						Call export_NewSheet
					Else
						Call addexcelfooter
						Call addexcelheader
					end if
					If newHeader = False Then
						addHtml exportHeaderHtml
					else
						Call CreateHeadHtml
					end if
					Exit Sub
				end if
			end if
			If exportRecCurCnt < recordPerSheet  Then
				exportRecCurCnt = exportRecCurCnt + 1
'If exportRecCurCnt < recordPerSheet  Then
			else
				Dim canSplitAnd,canSplitOr
				canSplitAnd = True
				canSplitOr = False
				If isEmpty(canSplitFormula_And) = False Then canSplitAnd = eval(canSplitFormula_And)
				If isEmpty(canSplitFormula_Or) = False Then canSplitOr = eval(canSplitFormula_Or)
				If (isRepeatRow = False And canSplitAnd Or canSplitOr) Then
					If exportSheetCnt < sheetPerFile Then
						Call export_NewSheet
					Else
						Call addexcelfooter
						Call addexcelheader
					end if
					addHtml exportHeaderHtml
				else
					exportRecCurCnt = exportRecCurCnt + 1
					addHtml exportHeaderHtml
				end if
			end if
		end sub
		Public Sub InsertZdyMap(ByVal  parentDBName, ByVal dbName, ByVal title,  ByVal width)
			Dim pos, i, defw
			If parentDBName = "" Then
				pos = 0
				defw = 100
			else
				For i = 0 To zdycount - 1
					defw = 100
					If lcase(zdyMaps(i).name) = lcase(parentDBName) Then
						defw = zdyMaps(i).width
						pos = i + 1
'defw = zdyMaps(i).width
						Exit for
					end if
				next
			end if
			If Len(width & "") > 0 Then
				defw = width
			end if
			Dim zdyobj
			ReDim Preserve  zdyMaps(zdycount)
			For i =  zdycount To pos + 1 Step - 1
'ReDim Preserve  zdyMaps(zdycount)
				Set zdyMaps(i) = zdyMaps(i-1)
'ReDim Preserve  zdyMaps(zdycount)
			next
			Set zdyobj = New zdyMapsItem
			zdyobj.name = dbName
			zdyobj.title = title
			zdyobj.visible = 1
			For i = 0 To rs.fields.count -1
'zdyobj.visible = 1
				If LCase(rs.fields(i).name)  = Lcase(dbName) Then
					zdyobj.dbindex = i
				end if
			next
			zdyobj.width = defw
			Set zdyMaps(pos) = zdyobj
			zdycount = zdycount + 1
'Set zdyMaps(pos) = zdyobj
		end sub
		public Sub addJoinFields(ByVal joinFields)
			Call  addJoinFeilds(joinFields)
		end sub
		Public Sub addJoinFeilds(ByVal joinFields)
			Dim fs, i, ii, h, item
			fs = Split(Replace(joinFields, ",", ";"), ";")
			For i = 0 To ubound(fs)
				item = Trim(LCase(fs(i)))
				fs(i) = item
			next
			Dim nfs, vsb
			vsb = True
			nfs = Join(fs, ";")
			For i = 0 To ubound(fs)
				item = fs(i)
				For ii = 1 To headers.count
					Set h = headers(ii)
					If LCase(h.dbname)= item Then
						h.joinFields = nfs
						If vsb = True Then
							vsb = False
							h.joinvisible = True
						else
							h.joinvisible = false
						end if
					end if
				next
			next
		end sub
		Public Sub settagData(v)
			msettag = True
			mtagData = v
		end sub
		private function ColorFormat(v)
			if len(v & "") = 0 then  ColorFormat = "": exit function
			if len(ZoreColor) > 0 then
				if instr(v,"<") = 0 then
					if isnumeric(v)=true then
						if v&"" = "0" then
							ColorFormat = "<span style='color:" & zoreColor & "'>" & v & "</span>"
							exit function
						end if
					end if
				else
					if instr(v,">0") > 0 then
						if instr(v,">0<") > 0 then  ColorFormat = replace(v,">0<","><span style='color:" & zoreColor & "'>0</span><") : exit function
						if instr(v,">0.0<") > 0 then  ColorFormat = replace(v,">0.0<","><span style='color:" & zoreColor & "'>0.0</span><") : exit function
						if instr(v,">0.00<") > 0 then  ColorFormat = replace(v,">0.00<","><span style='color:" & zoreColor & "'>0.00</span><") : exit function
						if instr(v,">0.000<") > 0 then  ColorFormat = replace(v,">0.000<","><span style='color:" & zoreColor & "'>0.000</span><") : exit function
						if instr(v,">0.0000<") > 0 then  ColorFormat = replace(v,">0.0000<","><span style='color:" & zoreColor & "'>0.0000</span><") : exit function
						if instr(v,">0.00000<") > 0 then  ColorFormat = replace(v,">0.00000<","><span style='color:" & zoreColor & "'>0.00000</span><") : exit function
					end if
				end if
			end if
			ColorFormat = v
		end function
		public property get recordcount
		recordcount = mrecordcount
		end Property
		Public Sub setRecordcount(ByVal v)
			mrecordcount = v
		end sub
		public property get sql
		sql = msql
		end property
		Dim arrname,arrvalue,currPageRecordcount,parampageindex
		public property let sql(nvalue)
		dim i, h, s , t, isxls, cmd
		on error resume next
		If nvalue = "" Then Exit property
		rs.close
		On Error GoTo 0
		If app.ismobile Then
			cmd = ""
		else
			cmd = request.form("cmd")
		end if
		err.clear
		select Case cmd
		case "newPageIndex"
		pageindex = abs(request.form("value"))
		case "newPageSize"
		pagesize = abs(request.form("value"))
		pageindex = abs(request.form("pageindex"))
		Case Else
		If HeaderPageSizeUI = true Then
			Dim attrs
			Dim currks : currks = app.Attributes("rcs_" & GetSboxHeaderConfigMd5)
			If Len(currks) > 0 Then
				attrs = Split(currks, ";")
				pagesize = Replace(attrs(ubound(attrs)), "!", "")
			end if
		end if
		End Select
		isxls  = (cmd = "cexcel" Or Me.excelmode)
		headers.clear
		msql = nvalue
		If app.ismobile = False Then
			If request.form("__msgid") = "sys_lvw_callback" Then
				If cmd = "lvwsortevent" Then
					me.sortsql = app.getText("value")
				end if
			end if
		end if
		if cmd = "cexcel" Then
			if len(me.excelsql)>0 Then
				s = replace(me.excelsql,"<br>","")
			else
				s = replace(msql,"<br>","")
			end if
			s = Replace(s,"&tagData","'" & Replace(tagData,"'","''") & "'")
			s = Replace(s,"&excelmode",Abs(cmd = "cexcel"),1,-1,1)
's = Replace(s,"&tagData","'" & Replace(tagData,"'","''") & "'")
			s = Replace(s,"&pagesize", "100000" ,1,-1,1)
's = Replace(s,"&tagData","'" & Replace(tagData,"'","''") & "'")
			s = Replace(s,"&pageindex", "1" ,1,-1,1)
's = Replace(s,"&tagData","'" & Replace(tagData,"'","''") & "'")
			s = Replace(s,"&headerconfig", "'" & Me.Md5Key16 & "'" ,1,-1,1)
's = Replace(s,"&tagData","'" & Replace(tagData,"'","''") & "'")
			If InStr(1,s, "&sortSql",1) > 0 then
				s = Replace(s,"&sortSql","'" & Replace(convertSortField(me.sortSql),"'","''") & "'",1,-1,1)
'If InStr(1,s, "&sortSql",1) > 0 then
				IsSqlSort = True
			else
				IsSqlSort = false
			end if
			If InStr(s, "/*必须动态游标*/")>0 Then
				cn.cursorlocation = 2
			ElseIf InStr(s, "/*必须静态游标*/")>0 Then
				cn.cursorlocation = 3
				rs.CursorLocation = 3
			else
				If (isSqlSort Or Len(Me.sortSql)= 0) Then
					cn.cursorlocation = 2
				else
					cn.cursorlocation = 3
					rs.CursorLocation = 3
				end if
			end if
			errsql = s
			on error resume next
			If Me.FinanDBModel = true then
				Set rs = app.crecord(s, 1, 1)
			else
				Set rs = cn.execute(s)
			end if
			Dim errss : errss = Err.description
			Dim errnn : errnn = Err.number
			On Error GoTo 0
			If errnn <> 0 Then
				Err.raise 10908, "listview", "导出过程出现错误，" & errss &"，相关错误代码：" & s & "。"
			end if
			errsql = ""
			If LCase(rs.fields(0).name) = "recordcount" Then
				ReDim arrname(rs.fields.count-1),arrvalue(rs.fields.count-1)
'If LCase(rs.fields(0).name) = "recordcount" Then
				For arr=1 To ubound(arrname)
					arrname(arr-1)=rs.fields(arr).name
'For arr=1 To ubound(arrname)
					arrvalue(arr-1)=rs.fields(arr).value
'For arr=1 To ubound(arrname)
				next
				mrecordcount = rs.fields(0).value
				Set rs = rs.nextrecordset
				currPageRecordcount = rs.recordcount
				pageMode = True
			else
				mrecordcount = rs.recordcount
				pageMode = false
			end if
			If App.existsProc("App_PreListviewExcel") Then Call App_PreListviewExcel(Me)
		Else
			cn.cursorlocation = 3
			rs.CursorLocation = 3
			If InStr(msql,"&MulHeaderExpanName") > 0 Then
				me.sortSql = ""
				headExplan = True
				If cmd = "lvwHeaderExplan" Then
					t = app.gettext("xpname")
					If MulExplan = False then
						Me.headExplanName = app.iif(app.getint("mtype")=0,"",t)
					else
						If app.getint("mtype")=0 Then
							If InStr("^" & Me.headExplanName & "^","^" & t & "^") > 0 Then
								Me.headExplanName = Replace(Me.headExplanName,t,"")
								Me.headExplanName = Replace(Me.headExplanName,"^" & "^","^")
								If Me.headExplanName = "^" then
									Me.headExplanName = ""
								end if
							end if
						else
							If InStr("^" & Me.headExplanName & "^","^" & t & "^") = 0 Then
								Me.headExplanName = Me.headExplanName & app.iif(Len(Me.headExplanName) > 0, "^" & t, t)
							end if
						end if
					end if
				end if
				s = Replace(msql,"&MulHeaderExpanName", "'" & Me.headExplanName & "'")
			else
				headExplan = False
				s = msql
			end if
			s = Replace(s,"&tagData","'" & Replace(tagData,"'","''") & "'")
			s = Replace(s,"&excelmode",Abs(cmd = "cexcel"),1,-1,1)
			s = Replace(s,"&tagData","'" & Replace(tagData,"'","''") & "'")
			s = Replace(s,"&pagesize", Me.pagesize ,1,-1,1)
			s = Replace(s,"&tagData","'" & Replace(tagData,"'","''") & "'")
			s = Replace(s,"&pageindex", Me.pageindex ,1,-1,1)
			s = Replace(s,"&tagData","'" & Replace(tagData,"'","''") & "'")
			s = Replace(s,"&headerconfig", "'" & Me.Md5Key16 & "'" ,1,-1,1)
			s = Replace(s,"&tagData","'" & Replace(tagData,"'","''") & "'")
			If InStr(1,s, "&sortSql",1) > 0 then
				s = Replace(s,"&sortSql","'" & Replace(convertSortField(me.sortSql),"'","''") & "'",1,-1,1)
'If InStr(1,s, "&sortSql",1) > 0 then
				IsSqlSort = True
			else
				IsSqlSort = false
			end if
			If isInsertModel Then
				s =  "set RowCount 100;"  &  s & ";set RowCount 0"
			end if
			errsql = s
			If app.getInt("debug")=1 Then Response.write errsql
			on error resume next
			If Len(Me.CacheRules) > 0 Then
				Set rs = app.getCacheRecord(s, Me.CacheRules, true, true, Me.CacheKeys)
			else
				If Me.FinanDBModel = true Then
					If me.recordcanedit Then
						Set rs = app.crecord(s, 1, 3)
					else
						Set rs = app.crecord(s, 1, 1)
					end if
				else
					If me.recordcanedit Then
						rs.open s, cn , 1, 3
					else
						rs.open s, cn , 1, 1
					end if
				end if
			end if
			If Err.number <> 0 Then
				Dim e_nm, e_sc, e_ds
				e_nm = err.number : e_sc = err.Source :  e_ds = Err.Description
				If app.issub("erp_sys_onlistviewError") Then
					Call erp_sys_onlistviewError(me, e_nm, e_sc, e_ds, s)
				end if
				On Error GoTo 0
				If e_nm <> 0 then
					Err.Raise e_nm, e_sc, e_ds & vbcrlf & "<br><hr style='margin-top:8px;border-top:1px dashed #d2d3e4;height:1px'/><div style='padding:5px;color:#1325a6;'>" & s & "</div>"
'If e_nm <> 0 then
				end if
				Exit property
			end if
			On Error GoTo 0
			errsql = ""
			Dim arr
			If LCase(rs.fields(0).name) = "recordcount" Then
				ReDim arrname(rs.fields.count-1),arrvalue(rs.fields.count-1)
'If LCase(rs.fields(0).name) = "recordcount" Then
				For arr=1 To ubound(arrname)
					arrname(arr-1)=rs.fields(arr).name
'For arr=1 To ubound(arrname)
					arrvalue(arr-1)=rs.fields(arr).value
'For arr=1 To ubound(arrname)
				next
				mrecordcount = rs.fields(0).value
				on error resume next
				Set rs = rs.nextrecordset
				If Err.number <> 0 Then
					e_nm = err.number : e_sc = err.Source :  e_ds = Err.Description
					On Error GoTo 0
					Err.Raise e_nm, e_sc, e_ds & vbcrlf & "<br><hr style='margin-top:8px;border-top:1px dashed #d2d3e4;height:1px'/><div style='padding:5px;color:#1325a6;'>" & s & "</div>"
'On Error GoTo 0
					Exit Property
				else
					On Error GoTo 0
				end if
				currPageRecordcount = rs.recordcount
				pageMode = True
			else
				mrecordcount = rs.recordcount
				If recordcanedit And mrecordcount = -1 Then
					'mrecordcount = rs.recordcount
					mrecordcount = 1
				end if
				pageMode = false
			end if
		end if
		if err.number <> 0 then
			If PreMsg<>"" Then
				app.showerr  "信息提示" , PreMsg
			else
				app.showerr  "列表组件(listview)数据源错误" , "SQL源:" & s & err.description
			end if
		end if
		Call handleFieldsMap
		If mrecordcount < 0 Then
			Dim rst
			on error resume next
			If InStr(1, s , "select ", 1) > 0 Then
				s = "select count(1) from (" & Replace(s, "select ", "select top 50000000 ", 1, 1, 1) & ") t"
				Set rst = cn.execute(s)
				If rst.eof = False Then
					mrecordcount = rst.fields(0).value
				end if
				rst.close
				Set rst = Nothing
			end if
			On Error GoTo 0
		end if
		if mrecordcount < 0 then
			mrecordcount = 0
			while rs.eof = false
				mrecordcount = mrecordcount + 1
'while rs.eof = false
				rs.movenext
			wend
			if rs.bof = false then
				rs.movefirst
			end if
		end if
		end Property
		private Sub HandleFieldsMap
			Dim zdyobj, i, h
			If Me.mxzdyId > 0 Then
				headers.isZdyMode = 1
				Dim rs2
				Set rs2 = cn.execute("select id,title,kd,name,sorce, set_open from zdymx where sort1=" & Me.mxzdyId  & " order by gate1 asc ")
				While rs2.eof = False
					for i = 0 to rs.fields.count - 1
'While rs2.eof = False
						If LCase(rs.fields(i).name) = LCase(rs2("name").value ) Then
							ReDim Preserve zdyMaps(zdycount )
							Set zdyobj =  New zdyMapsItem
							zdyobj.dbIndex  = i
							zdyobj.name = rs.fields(i).name
							zdyobj.title = rs2("title").value
							zdyobj.width = rs2("kd").value
							zdyobj.visible = rs2("set_open").value
							Set zdyMaps(zdycount ) = zdyobj
							zdycount = zdycount + 1
'Set zdyMaps(zdycount ) = zdyobj
							Exit for
						end if
					next
					rs2.movenext
				wend
				rs2.close
				If App.existsProc("App_ListviewZdySet") Then Call App_ListviewZdySet(Me)
				Dim hs
				For i = 0 To rs.fields.count - 1
'Dim hs
					hs  = False
					For ii = 0 To  zdycount-1
'hs  = False
						If LCase(zdyMaps(ii).name) = LCase(rs.fields(i).name)  Then
							hs = True
							Exit for
						end if
					next
					If hs = False Then
						Set zdyobj =  New zdyMapsItem
						zdyobj.dbIndex  = i
						zdyobj.name = rs.fields(i).name
						zdyobj.title = rs.fields(i).name
						zdyobj.width = 100
						zdyobj.visible = 1
						ReDim Preserve zdyMaps(zdycount )
						Set zdyMaps(zdycount ) = zdyobj
						zdycount = zdycount + 1
						'Set zdyMaps(zdycount ) = zdyobj
					end if
				next
			end if
			On Error GoTo 0
			Dim ii
			If Me.mxzdyId > 0 Then
				redim preserve fs(zdycount - 1)
'If Me.mxzdyId > 0 Then
				for i = 0 to zdycount - 1
'If Me.mxzdyId > 0 Then
					set fs(i) = rs.fields(i)
					Set zdyobj = zdyMaps(i)
					If isnumeric(zdyobj.dbindex) = False Or Len(zdyobj.dbindex) = 0 Then
						app.showerr "ListView自定义字段错误","数据源中无法找到【" & zdyobj.name & "】字段"
					End If
					if fs(i).name<>"models"  And LCase(fs(i).name & "")<>editkey Then
						set h = headers.add(zdyobj.title ,zdyobj.name)
						h.minwidth = me.mincellwidth
						h.width = zdyobj.width
						h.dbIndex = zdyobj.dbindex
						If zdyobj.visible = 0 Then
							h.display = "none"
						end if
					end if
				next
			else
				redim preserve fs(rs.fields.count - 1)
				'h.display = "none"
				for i = 0 to rs.fields.count - 1
'h.display = "none"
					set fs(i) = rs.fields(i)
					if fs(i).name<>"models" And LCase(fs(i).name & "")<>editkey then
						set h = headers.add(fs(i).name ,fs(i).name)
						h.minwidth = me.mincellwidth
						h.dbIndex = i
					end if
				next
			end if
		end sub
		public Sub SetfsByRsForTreeView()
			Dim i
			redim preserve fs(rs.fields.count - 1)
'Dim i
			for i = 0 to rs.fields.count - 1
'Dim i
				set fs(i) = rs.fields(i)
				if fs(i).name<>"models" And LCase(fs(i).name & "")<>editkey Then
					headers(fs(i).name).dbindex = i
				end if
			next
		end sub
		Public Function getSqlSumValue(header)
			Dim getvalue,i,nbit,hs
			hs = False
			getvalue = ""
			For i=0 To ubound(arrname)
				If Trim(arrname(i))=Trim(header.dbname) Then
					nbit = Info.FloatNumber
					If header.dbtype="money" Then nbit = Info.moneyNumber
					If header.dbtype="commprice" Then nbit = Info.CommPriceDotNum
					If header.dbtype="salesprice" Then nbit = Info.SalesPriceDotNum
					If header.dbtype="storeprice" Then nbit = Info.StorePriceDotNum
					If header.dbtype="financeprice" Then nbit = Info.FinancePriceDotNum
					If header.dbtype="hl" Then nbit = Info.hlNumber
					getvalue=Formatnumber(arrvalue(i),nbit,-1)
'If header.dbtype="hl" Then nbit = Info.hlNumber
					hs = true
				end if
			next
			If getvalue="" And hs = true Then getvalue="0"
			getSqlSumValue=getvalue
		end function
		public sub class_initialize
			css = ""
			colresize = false
			checkvalue = ""
			extAttribute = ""
			msettag = false
			dbmodel = "sql"
			mxzdyId = 0
			checkbox = true
			indexbox = true
			toolbar = false
			scroll = False
			DataOverflow = "hidden"
			CanPageSize = True
			ServerConfig = false
			headNameJoin = True
			RowSplitSum = False
			jsonEditModel = false
			set rs = server.CreateObject("adodb.recordset")
			set rs_group_sum = server.CreateObject("adodb.recordset")
			set headers = new lvwColCollection
			Set mEdit = New ListViewEditConfig
			pagesize = 10
			pageindex = 1
			redim fs(0)
			set fs(0) = nothing
			addlink = "添加"
			border = 1
			excelmode = False
			excelextIntro = ""
			showNullDate = True
			minCellwidth = 0
			cansort = True
			showfullopen = False
			currSum = false
			allSum = false
			splitColor = "#777788"
			isCallback = false
			fixedCell = 0
			Autoresize=true
			isshow_visible=True
			isshow_ymc  =       False
			isshow_xmc  =   False
			isshow_anotherName  =False
			isshow_formula      =False
			isPageReckon =      False
			FaStr=""
			excelsql=""
			MulExplan = False
			noScrollModel = False
			colbackPost = True
			IsaccWidth =  False
			IsAbsWidth = false
			IsSqlSort = False
			PreRptProcIndex = -1
'IsSqlSort = False
			pageMode=False
			PageButtonAlign = "left"
			PageBar = true
			zdycount = 0
			oldPageSizeUI = False
			HeaderPageSizeUI = False
			If app.ismobile then
				isInsertModel = False
				Set layout = server.createobject("ZSMLLibrary.LayoutClass")
			else
				isInsertModel = (request.form("__msgId") = "sys_lvw_callback" And request.Form("cmd") = "insertRow" )
				If request("title")<>"" Then exportFileName = request("title")
			end if
			curr_rowindex = app.getInt("_insert_rowindex")
			checkboxwidth = 0
			ReDim zdyMaps(0)
			recordPerSheet = 10000
			sheetPerFile = 1
			exportRecCnt = 0
			exportRecCurCnt = 0
			exportSheetCnt = 0
			exportFileCnt = 0
			exportHeaderHtml = ""
			vPath = App.virPath
			needWriteFile = True
			curSheetTitle = ""
			exportJsInitFlag = False
			exportSqlGroupIdx = 0
			exportRecIdx = 1
			finanDBModel = False
			recordcanedit = False
			fixedHead = false
			ReDim exportSheetCntByGroup(exportSqlGroupIdx)
			exportSheetCntByGroup(exportSqlGroupIdx) = 0
			m_autoAppendUrlParams = False
			istreegrid = false
		end sub
		Private Sub Class_Terminate()
			If Len(errsql) > 0 Then
				Response.write "<div><a href='javascript:void(0)' onclick='var box = document.getElementById(""lvwsqlerr"");box.style.display = box.style.display == ""none"" ? """" : ""none""' style='color:red'>点击错误附加信息</a><div id='lvwsqlerr' style='display:none;padding:20px;background-color:#f4f4ff;clear:both'><div style='padding:6px;background-color:white;border:1px solid #e5e6ee'><pre>" & errsql & "</pre></div></div></div>"
'If Len(errsql) > 0 Then
			end if
			on error resume next
			rs.close
			set rs =  nothing
		end sub
		public sub clearHtml()
			htmlcount = 0
			htmlubound = 0
			redim htmlarray(0)
		end sub
		public Function addHtml(strt)
			If excelmode Then
				addHtml=xsheet.writehtml(strt)
				Exit Function
			end if
			If htmlubound < htmlcount Then
				htmlubound = htmlubound + 500
'If htmlubound < htmlcount Then
				redim Preserve htmlarray(htmlubound)
			end if
			htmlarray(htmlcount) = strt
			addHtml = htmlcount
			htmlcount = htmlcount + 1
'addHtml = htmlcount
		end function
		Private function isDisSortCol(h)
			Dim colname : colname = h.title
			If h.cansort then
				isDisSortCol = InStr(colname,"操作")>0
				If Not isDisSortCol Then  isDisSortCol = InStr(colname,"编辑")>0
				If Not isDisSortCol Then  isDisSortCol = InStr(colname,"选择")>0
			else
				isDisSortCol = true
			end if
		end function
		sub addexcelheader
			Call export_NewExcelObj
			Call export_NewFile
			Call export_NewSheet
		end sub
		Private Sub export_createJsFunction
			If exportJsInitFlag Then Exit Sub
			Response.write "" & vbcrlf & "                              <script>" & vbcrlf & "                                        var boxInitFlag = false;" & vbcrlf & "                                        function initFileLinkBox(){" & vbcrlf & "                                             var $box = parent.jQuery('#lxls_by');" & vbcrlf & "                                           var $div = parent.jQuery('#lxls_by_flist');" & vbcrlf & "                                             if ($div.size()==0){" & vbcrlf & "                                    $div = parent.jQuery(""<div id='lxls_by_flist' style='background-color:#fff;line-height:22px;padding-bottom:0px'>""+" & vbcrlf & "                                                                                                                ""<b style='color:green;display:inline-block;margin-bottom:10px;'>生成Excel文档成功。</b>""+" & vbcrlf & "                                                                                                                ""<br>""+" & vbcrlf & "                                                                                                           ""<span>文件下载链接：</span>""+" & vbcrlf & "                                                                                                               ""<div style='text-align:center'>""+" & vbcrlf & "                                                                                                                        ""<a class='closeBtn' onclick=\""jQuery('#lvw_xls_proc_bar').hide()\"" style='' href='javascript:void(0)'>关闭对话框</a>""+" & vbcrlf & "                                                                                                             ""</div>""+" & vbcrlf & "                                                                                                 ""</div>"");" & vbcrlf & "                                                 $box.append($div);" & vbcrlf & "                                              }else{" & vbcrlf & "                                                  $div.find('.lxls_by_flink').remove();" & vbcrlf & "                                           }" & vbcrlf & "                                               boxInitFlag = true;" & vbcrlf & "                                     }" & vbcrlf & "" & vbcrlf & "                                       function addFileLink(obj){" & vbcrlf & "                                              if (!boxInitFlag){" & vbcrlf & "                                                   initFileLinkBox();" & vbcrlf & "                                              }" & vbcrlf & "                                               var $file = parent.jQuery((obj.fileCnt>1?""<br/>"":"""")+'<a class=""lxls_by_flink"" style=""Text-Decoration:underline;"" href="""
'If exportJsInitFlag Then Exit Sub
			Response.write Me.vPath
			Response.write "out/downfile.asp?fileSpec=' + obj.fileUrl + '"">'+obj.fileName+'</a>').insertBefore(parent.jQuery('#lxls_by_flist div:last'));" & vbcrlf & "                                      }" & vbcrlf & "" & vbcrlf & "                                       function showExcelProgress(v,total,current){" & vbcrlf & "                                            parent.jQuery('#lxls_pv').css('width',v+'%');" & vbcrlf & "                                            parent.jQuery('#lxls_t').html(v+'%'+'('+current+'/'+total+')');" & vbcrlf & "                                         if (v==""100""){" & vbcrlf & "                                                    parent.jQuery('#lxls_status').html('导出成功！导出记录'+total+'条','请点击链接下载导出文件');" & vbcrlf & "                                           }" & vbcrlf & "                                       }" & vbcrlf & "                               </script>" & vbcrlf & "                       "
			Response.write Me.vPath
			exportJsInitFlag = True
			Response.flush
		end sub
		Private Sub export_NewExcelObj
			If isEmpty(xlsApp) Or typename(xlsApp)<>"HtmlExcelApplication" Then
				Set xlsApp = server.createobject(ZBRLibDLLNameSN & ".HtmlExcelApplication")
				xlsApp.init app.PageScript,  cn
				xlsApp.DisAutoRow = true
			end if
		end sub
		Private Sub export_NewFile
			If exportSheetCnt = 0 Or exportSheetCnt >= sheetPerFile Then
				exportFileCnt = exportFileCnt + 1
'If exportSheetCnt = 0 Or exportSheetCnt >= sheetPerFile Then
				exportSheetCnt = 0
			end if
		end sub
		Private Sub export_NewSheet
			exportSheetCnt = exportSheetCnt + 1
'Private Sub export_NewSheet
			exportSheetCntByGroup(exportSqlGroupIdx) = exportSheetCntByGroup(exportSqlGroupIdx) + 1
'Private Sub export_NewSheet
			dim title
			title = app.iif(Len(curSheetTitle)>0,curSheetTitle &_
			app.iif(exportSheetCntByGroup(exportSqlGroupIdx)=1,"""",exportSheetCntByGroup(exportSqlGroupIdx)) , _
			app.iif(Len(request("title"))>0,request("title"),"导出数据" & exportSheetCnt))
			Set xsheet = xlsApp.sheets.add(title)
			exportRecCurCnt = 1
		end sub
		Private Sub export_SaveExcelFile
			Dim url
			dim title, tit
			title = Me.exportFileName
			if len(title) = 0 then title = "导出数据"
			Err.clear
			on error resume next
			tit = xlsApp.cFileName(title)
			url = server.mappath(App.virPath & "out/HtmlExcel/" & tit & "-" & exportFileCnt & ".xls")
'tit = xlsApp.cFileName(title)
			xlsApp.save url
			If Abs(Err.number) > 0 then
				Response.write "<script>parent.document.getElementById('lxls_status').innerHTML=""导出过程出现错误:" & Err.description & """;</script>"
			else
				Response.write "" & vbcrlf & "                      <script>addFileLink({fileUrl:"""
				Response.write xlsapp.HexEncode(url)
				Response.write """,fileName:"""
				Response.write tit& "-" & exportFileCnt & ".xls"
				Response.write """,fileName:"""
				Response.write """,fileCnt:"
				Response.write exportFileCnt
				Response.write "});</script>" & vbcrlf & "                  "
			end if
		end sub
		Public Function multiSqlExport(sheetTitle,isLastSql,sqlIdx)
			curSheetTitle = sheetTitle
			needWriteFile = isLastSql
			exportSqlGroupIdx = sqlIdx
			ReDim Preserve exportSheetCntByGroup(exportSqlGroupIdx)
			exportSheetCntByGroup(exportSqlGroupIdx) = 0
			multiSqlExport = html()
			If isLastSql Then
				Response.write "<script language='javascript'>showExcelProgress('100','"&exportRecCnt&"','"&exportRecCnt&"');</script>"
			end if
		end function
		sub addexcelfooter
			Call export_SaveExcelFile
			xlsApp.Dispose
			Set xlsApp = Nothing
		end sub
		public function GetWidth
			dim i, w, c, t , iw
			for i = 1 to headers.count
				set c = headers(i)
				if c.display <> "none" and c.visible = true then
					if IsVisibleCol(c.title) then
						t = c.title
						if instr(t,"_") > 0 then
							t = split(t,"_")
							iw = app.byteLen(t(ubound(t)))*16
						else
							iw =  app.byteLen(w)*16
						end if
						if iw < 60 then iw = 60
						w = w + iw
'if iw < 60 then iw = 60
					end if
				end if
			next
			GetWidth = w
		end function
		private function convertSortField(byval msortsql)
			dim s , item , i
			s = split(msortsql, ",")
			for i = 0 to rs.fields.count - 1
's = split(msortsql, ",")
				item = rs.fields(i).name
				if instr(item,"#sort_") = 1 then
					item = replace(item, "#sort_","")
					msortsql = replace(msortsql , "[" & item & "]", "[#sort_" & item & "]")
				end if
			next
			convertSortField = msortsql
		end function
		Function isExplanHeader(txt)
			Dim a , i
			If Me.mulexplan=true Then
				a = Split(Me.headexplanname,"^")
				isExplanHeader = false
				For i = 0 To ubound(a)
					isExplanHeader = (a(i) & "#" = txt)
					If isExplanHeader Then Exit function
				next
			else
				isExplanHeader = (Me.headexplanname & "#" = txt)
			end if
		end function
		function showExcelProc(ByVal count , ByVal procv)
			If exportJsInitFlag = False Then Call export_createJsFunction
			Dim jd
			If procv > 100 Then procv = 100
			If procv <= PreRptProcIndex Then
				showExcelProc = True
				Exit Function
			end if
			If Response.IsClientConnected = False Then
				Err.raise 4908, "ListView", "客户端已经断开连接，ExcelProc过程强制终止。"
				showExcelProc =  False
				Exit Function
			else
				showExcelProc = True
			end if
			PreRptProcIndex = procv
			Response.write "<script language='javascript'>showExcelProgress('"&procv&"','"&mrecordcount&"','"&exportRecIdx&"');</script>"
			Response.flush
		end function
		Private Sub showSelectHeaderList(h)
			Dim item, i
			Dim dn : dn = h.dbname
			Dim fs : fs = Split(h.joinFields, ";")
			For i = 0 To ubound(fs)
				Set item = headers.GetItemByDBname(fs(i))
				If item Is Nothing Then
					addhtml "<option value=''>[" & fs(i) & "]</option>"
				else
					If h.dbname = item.dbname Then
						addhtml "<option value='" & item.dbname & "' selected >" & item.title & "</option>"
					else
						addhtml "<option value='" & item.dbname & "'>" & item.title & "</option>"
					end if
				end if
			next
		end sub
		public Function GetSboxHeaderConfigMd5()
			Dim sdkeyn : sdkeyn = request.servervariables("url") & "?" & id & "? " & HeaderConfigKey
			sdkeyn= app.base64.MD5(sdkeyn)
			If Len(sdkeyn) > 32 Then sdkeyn = Left(sdkeyn, 32)
			GetSboxHeaderConfigMd5  = sdkeyn
		end function
		public Property Get Md5Key16()
		If Len(mMd5Key16) = 0 Then
			mMd5Key16 = Mid(GetSboxHeaderConfigMd5 , 8,16)
		end if
		Md5Key16 = mMd5Key16
		End Property
		Private Sub showheaderPageSize()
			Dim i, ii, h, ks
			addHtml "<select class='lvwhselbox' onchange='lvw_cpsize(this.value,""" & id & """)'>"
			Dim nums : nums = Split("10;20;30;50;100;200",";")
			Dim sboxHTML, trBtnHtml
			For i = 0 To ubound(nums)
				ii = nums(i)
				If CLng(pagesize) = CLng(ii) Then
					sboxHTML = sboxHTML & "<option value='" & ii & "' selected>每页显示" & ii & "条</option>"
				else
					sboxHTML = sboxHTML & "<option value='" & ii & "'>每页显示" & ii & "条</option>"
				end if
			next
			addHtml sboxHTML
			addhtml "</select>"
			Dim hsjoin : hsjoin = false
			Dim currks, hsck, defks, k1
			For i = 1 To headers.count
				Set h = headers(i)
				If len(Trim(h.joinfields)) > 0 Then
					k1 = Trim(LCase(Split(Replace(h.joinfields, ",", ";"), ";")(0)))
					If k1 = LCase(Trim(h.dbname)) then
						If Len(defks) > 0 Then defks = defks & ";"
						defks = defks & k1
					end if
					hsjoin = true
				end if
				If h.joinVisible = True Then
					If Len(ks) >0 Then ks = ks & ";"
					ks = ks & Trim(LCase(h.dbname))
				end if
			next
			If Len(ks) >0 Then ks = ks & ";"
			ks = ks & ";!" & pagesize
			If hsjoin = True Then
				Dim sdkeyn : sdkeyn = GetSboxHeaderConfigMd5
				currks = app.Attributes("rcs_" & sdkeyn)
				hsck = ((Len(currks) = 0 And ks = defks) Or currks = ks)
				If hsck Then
					addhtml "<input onmouseover='this.title=this.checked?""取消标题栏"":""默认标题栏""' type=checkbox checked  onclick='__lvwsaveselBoxDef(""" & sdkeyn & """,""" & ks & """,this)'>"
				else
					addhtml "<input onmouseover='this.title=this.checked?""取消标题栏"":""默认标题栏""' type=checkbox onclick='__lvwsaveselBoxDef(""" & sdkeyn & """,""" & ks & """,this)'>"
				end if
			end if
		end sub
		Private Sub loadDefSBoxHeaderVisible
			Dim i, ii, h
			If request.form("__msgid") <> "sys_lvw_callback" Then
				Dim hsboxheader : hsboxheader = False
				Dim currks , currkslist
				for i = 1 to headers.count
					set h = headers(i)
					If Len(h.joinfields) > 0 Then
						If hsboxheader = False Then
							currks = app.Attributes("rcs_" & GetSboxHeaderConfigMd5)
							If Len(currks) > 0 Then
								currkslist = Split(currks, ";")
							end if
						end if
						hsboxheader = True
						If Len(currks) > 0 Then
							For ii = 0 To ubound(currkslist)
								If InStr(";" & h.joinfields & ";", ";" & currkslist(ii) & ";") > 0 Then
									h.joinvisible = (LCase(h.dbname) = currkslist(ii))
								end if
							next
						end if
					end if
				next
			end if
		end sub
		private Sub ReplaceEvalValue(ByRef v, ByVal currvalue, ByVal calltype, ByVal i)
			Dim tv_1, tv_2, tv_num
			tv_2 = 1
			Dim boolcode , cellValue, rowindex
			rowindex = i
			boolcode=(instr(v,"code:") = 1)
			tv_1 = instr(tv_2,v,"@cells[",1)
			while tv_1 > 0
				tv_2 = InStr(tv_1,v,"]")
				If tv_2 > 0 Then
					tv_num = Mid(v,tv_1+7, tv_2-tv_1-7)
'If tv_2 > 0 Then
					If isnumeric(tv_num) Then
						cellValue =fs(headers(tv_num).dbindex).value & ""
						If boolcode Then cellValue = Replace(cellValue , """", """""")
						v =  replace(v,"@cells[" & tv_num & "]", cellValue , 1, -1, 1)
'If boolcode Then cellValue = Replace(cellValue , """", """""")
						tv_1 = instr(tv_1,v,"@cells[",1)
						tv_2 = 1
					else
						tv_num = Replace(tv_num, """","")
						If InStr(1, v, "@cells[""" & tv_num & """]", 1) > 0 Then
							cellValue = fs(headers(tv_num).dbindex).value & ""
							If boolcode Then cellValue = Replace(cellValue , """", """""")
							v =  replace(v,"@cells[""" & tv_num & """]", cellValue , 1, -1, 1)
'If boolcode Then cellValue = Replace(cellValue , """", """""")
							tv_1 = instr(tv_1,v,"@cells[",1)
							tv_2 = 1
						else
							tv_1 = 0
						end if
					end if
				else
					tv_1 = 0
				end if
			wend
			tv_2 = 1
			tv_1 = instr(tv_2,v,"@ucells[",1)
			while tv_1 > 0
				tv_2 = InStr(tv_1,v,"]")
				If tv_2 > 0 Then
					tv_num = Mid(v,tv_1+8, tv_2-tv_1-8)
'If tv_2 > 0 Then
					If isnumeric(tv_num) Then
						v =  replace(v,"@ucells[" & tv_num & "]", server.urlencode(fs(headers(tv_num).dbindex).value & ""), 1, -1, 1)
'If isnumeric(tv_num) Then
						tv_1 = instr(tv_1,v,"@ucells[",1)
						tv_2 = 1
					else
						tv_num = Replace(tv_num, """","")
						If InStr(1, v, "@ucells[""" & tv_num & """]", 1) > 0 Then
							v =  replace(v,"@ucells[""" & tv_num & """]", server.urlencode(fs(headers(tv_num).dbindex).value & ""), 1, -1, 1)
'If InStr(1, v, "@ucells[""" & tv_num & """]", 1) > 0 Then
							tv_1 = instr(tv_1,v,"@ucells[",1)
							tv_2 = 1
						else
							tv_1 = 0
						end if
					end if
				else
					tv_1 = 0
				end if
			wend
			tv_2 = 1
			tv_1 = instr(tv_2,v,"@encells[",1)
			while tv_1 > 0
				tv_2 = InStr(tv_1,v,"]")
				If tv_2 > 0 Then
					tv_num = Mid(v,tv_1+9, tv_2-tv_1-9)
'If tv_2 > 0 Then
					If isnumeric(tv_num) Then
						v =  replace(v,"@encells[" & tv_num & "]", app.base64.pwurl(fs(headers(tv_num).dbindex).value & ""), 1, -1, 1)
'If isnumeric(tv_num) Then
						tv_1 = instr(tv_1,v,"@encells[",1)
						tv_2 = 1
					else
						tv_num = Replace(tv_num, """","")
						If InStr(1, v, "@encells[""" & tv_num & """]", 1) > 0 Then
							v =  replace(v,"@encells[""" & tv_num & """]", app.base64.pwurl(fs(headers(tv_num).dbindex).value & ""), 1, -1, 1)
'If InStr(1, v, "@encells[""" & tv_num & """]", 1) > 0 Then
							tv_1 = instr(tv_1,v,"@encells[",1)
							tv_2 = 1
						else
							tv_1 = 0
						end if
					end if
				else
					tv_1 = 0
				end if
			wend
			if instr(v,"code:") = 1 Then
				v = replace( v,"""@value""", "currvalue", 1,-1,1)
'if instr(v,"code:") = 1 Then
				v = replace( v,"@value", "currvalue", 1,-1,1)
'if instr(v,"code:") = 1 Then
				on error resume next
				Call fillValue(v , eval(right(v,len(v)-5)) )
'if instr(v,"code:") = 1 Then
				If Err.number <> 0 Then
					v = "格式化【" & right(v,len(v)-5) & "】失败，" & Err.description & "。"
'If Err.number <> 0 Then
				end if
			else
				v = replace(v,"@value",currvalue & "")
			end if
			On Error GoTo 0
		end sub
		Private Sub fillValue(ByRef v ,byval r)
			If isobject(r) Then
				Set v = r
			else
				v = r
			end if
		end sub
		Private Sub showListSum(currsumarray, allsumarray)
			Dim i, ii, c, sHtml, dbname, allsumvalue
			Dim sumtit : sumtit = False
			Dim sumcindex : sumcindex = 0
			Dim hssumProc : hssumProc = App.existsProc("App_lvw_OnSumProc")
			Dim hssumProcInit : hssumProcInit = App.existsProc("App_lvw_OnSumProcInit")
			Dim dosum
			If currsum = True Then
				addhtml "<tr>"
				If Me.excelmode = False then
					For i = 1 To headers.count
						Set c = headers(colmaps(i))
						If c.execdisplay <> "none" Then
							dosum = isnumeric(currsumarray(i)) and c.canSum = True And (sumcindex > 0 Or sumtit = true)
								If hssumProcInit Then
									Call App_lvw_OnSumProcInit(Me, c, i, dosum)
								end if
								If dosum Then
									If sumtit = False Then
										sumtit = True
										addhtml "<td colspan='" & sumcindex & "' class='" & c.cssName & " lvw_smcellb' align='" & c.align & "'"
										If me.indexbox Then
											addhtml " style='height:28px'"
										end if
										addhtml ">"
										If sumcindex > 1 Then
											sHtml = "<div align='right'>本页合计：</div>"
										else
											sHtml = "本页合计"
										end if
										If hssumProc then
											App_lvw_OnSumProc  me, "@label", 0, sHtml
										end if
										addhtml sHtml
										addhtml "</td>"
									else
										If sumcindex > 0 Then addhtml "<td colspan='" & sumcindex & "' style='" & iif(c.splitCell,"border-right:2px solid " & splitColor, "") & "' class='" & c.cssName & " " & c.dbtype & "sum'>&nbsp;</td>"
										addhtml "</td>"
									end if
									sumcindex = 0
									addhtml "<td style='" & iif(c.splitCell,"border-right:2px solid " & splitColor, "") & "' class='" & c.cssName & " " & c.dbtype & "sum lvw_smceldb' align='" & c.align & "'>"
'sumcindex = 0
									If isnumeric(currsumarray(i)) then
										sHtml = ColorFormat(FormatNumber(currsumarray(i),c.formatbit,-1))
'If isnumeric(currsumarray(i)) then
									else
										sHtml = ""
									end if
									If hssumProc then
										App_lvw_OnSumProc me, c.dbname, 0, sHtml
									end if
									addhtml sHtml & "</td>"
								else
									sumcindex = sumcindex + 1
									addhtml sHtml & "</td>"
								end if
							end if
						next
						If sumcindex > 0 Then
							addhtml "<td colspan='" & sumcindex & "' style='" & iif(c.splitCell,"border-right:2px solid " & splitColor, "") & "' class='" & c.cssName & " " & c.dbtype & "sum'>&nbsp;</td>"
'If sumcindex > 0 Then
						end if
					else
						For i = 1 To headers.count
							Set c = headers(colmaps(i))
							If c.execdisplay <> "none" Then
								dosum = isnumeric(currsumarray(i)) and c.canSum = True And sumcindex > 0
									If hssumProcInit Then
										Call App_lvw_OnSumProcInit(Me, c, i, dosum)
									end if
									If dosum Then
										If sumtit = False Then
											sumtit = True
											addhtml "<td align='right' colspan='" & sumcindex & "'>合计：</td>"
										end if
										If isnumeric(currsumarray(i)) then
											sHtml = ColorFormat(FormatNumber(currsumarray(i),c.formatbit,-1))
'If isnumeric(currsumarray(i)) then
										else
											sHtml = ""
										end if
										If hssumProc then
											App_lvw_OnSumProc me, c.dbname, 0, sHtml
										end if
										addhtml "<td class='" & c.dbtype & "'>" & sHtml & "</td>"
									else
										If sumtit Then addhtml "<td></td>"
										sumcindex = sumcindex + 1
'If sumtit Then addhtml "<td></td>"
									end if
								end if
							next
						end if
						addhtml "</tr>"
					end if
					sumtit = False
					sumcindex = 0
					If allsum = True Then
						If Me.excelmode = False Then
							If PageMode = True Then
								For i = 1 To headers.count
									allsumvalue = getSqlSumValue(headers(colmaps(i)))
									allsumarray(i) = allsumvalue
								next
							end if
							addhtml "<tr>"
							For i = 1 To headers.count
								Set c = headers(colmaps(i))
								If c.execdisplay <> "none" Then
									dosum = isnumeric(allsumarray(i)) and c.canSum = True And (sumcindex > 0 Or sumtit = true)
										If hssumProcInit Then
											Call App_lvw_OnSumProcInit(Me, c, i, dosum)
										end if
										If dosum Then
											If sumtit = False Then
												sumtit = True
												addhtml "<td class='" & c.cssName & " lvw_smcellb' colspan='" & sumcindex & "' "
												If me.indexbox Then
													addhtml " style='height:28px'"
												end if
												addhtml " align='" & c.align & "'>"
												If sumcindex > 1 Then
													sHtml = "<div align='right'>所有合计：</div>"
												else
													sHtml = "所有合计"
												end if
												If hssumProc then
													App_lvw_OnSumProc me,"@label", 1, sHtml
												end if
												addhtml sHtml
												addhtml "</td>"
											else
												If sumcindex > 0 Then
													addhtml "<td  colspan='" & sumcindex & "' style='" & iif(c.splitCell,"border-right:2px solid " & splitColor, "") & "' class='" & c.cssName & "'>&nbsp;</td>"
'If sumcindex > 0 Then
												end if
											end if
											sumcindex = 0
											addhtml "<td style='" & iif(c.splitCell,"border-right:2px solid " & splitColor, "") & "' class='" & c.cssName & " " & c.dbtype & "sum lvw_smceldb' align='" & c.align & "'>"
											sumcindex = 0
											If isnumeric(allsumarray(i)) then
												if c.dbtype="number" or c.uiType = "number" then
													sHtml = ColorFormat(FormatNumber(allsumarray(i),Info.FloatNumber,-1,0,-1))
'if c.dbtype="number" or c.uiType = "number" then
												else
													sHtml = ColorFormat(FormatNumber(allsumarray(i),Info.moneynumber,-1,0,-1))
'if c.dbtype="number" or c.uiType = "number" then
												end if
											else
												sHtml = ""
											end if
											If hssumProc then
												App_lvw_OnSumProc me, c.dbname, 1,  sHtml
											end if
											addhtml sHtml & "</td>"
										else
											sumcindex = sumcindex + 1
											addhtml sHtml & "</td>"
										end if
									end if
								next
								If sumcindex > 0 Then addhtml "<td  colspan='" & sumcindex & "' style='" & iif(c.splitCell,"border-right:2px solid " & splitColor, "") & "' class='" & c.cssName & "'>&nbsp;</td>"
								addhtml sHtml & "</td>"
								addhtml "</tr>"
							ElseIf currsum = False Then
								addhtml "<tr>"
								For i = 1 To headers.count
									Set c = headers(colmaps(i))
									If c.execdisplay <> "none" Or 1=1 Then
										dosum = isnumeric(allsumarray(i)) and c.canSum = True And sumcindex > 0
											If hssumProcInit Then
												Call App_lvw_OnSumProcInit(Me, c, i, dosum)
											end if
											If dosum Then
												If sumtit = False Then
													sumtit = True
													addhtml "<td align='right' colspan='" & sumcindex & "'>合计：</td>"
												end if
												If isnumeric(allsumarray(i)) then
													sHtml = ColorFormat(FormatNumber(allsumarray(i),c.formatbit,-1,0,-1,0,-1))
'If isnumeric(allsumarray(i)) then
												else
													sHtml = ""
												end if
												If hssumProc then
													App_lvw_OnSumProc me, c.dbname, 0, sHtml
												end if
												addhtml "<td class='" & c.dbtype & "'>" & sHtml & "</td>"
											else
												If sumtit Then addhtml "<td></td>"
												sumcindex = sumcindex + 1
'If sumtit Then addhtml "<td></td>"
											end if
										end if
									next
									addhtml "</tr>"
								end if
							end if
						end sub
						Private Sub RegRowSplitData(ByRef RowSplitF_count, ByRef RowSplitF_n, ByRef RowSplitF_prenv, ByRef RowSplitF_v, ByRef hcount, ByVal calltype, ByVal startpost, ByRef isRepeatRow, ByVal rowindex)
							Dim i, ii, iii, currf_v, rowsplitregin, v, c, fcount, cv, htmlv, cells, bgcolor
							fcount = headers.count
							Dim isReatColm : ReDim isReatColm(fcount) : isReatColm(0) = False
							If RowSplitF_count > 0 Then
								For  ii = 0 To RowSplitF_count - 1
'If RowSplitF_count > 0 Then
									rowsplitregin = false
									If calltype = 2 Then
										currf_v = ""
									else
										currf_v = rs(RowSplitF_n(ii))
										rowsplitregin =  (currf_v <> RowSplitF_prenv(ii) and RowSplitF_prenv(ii)<>"")
									end if
									If (rowsplitregin = true And calltype=1) Or calltype=2   Then
										Set cells = new lvwDataCollection
										For iii = 1 To fcount
											cells.add  headers(colmaps(iii)).dbname, RowSplitF_v(ii)(iii)
										next
										bgcolor = ""
										If Len(Me.rowcolorkey) > 0 Then
											If App.ExistsProc("lvw_onGroupSumCell") Then
												Call lvw_onGroupSumCell(me, headers(Me.rowcolorkey), RowSplitF_n(ii),  RowSplitF_prenv(ii), bgcolor, cells)
											end if
										end if
										If Len(Me.RowSplitFields) > 0 And (rowindex>startpost Or calltype<>1) Then
											If Len(bgcolor) > 0 Then
												addhtml "<tr l_r=1 bgcolor='" & bgcolor & "'>"
											else
												addhtml "<tr l_r=1 onmouseover='this.bgColor=""#EAEAEA""' onmouseout='this.bgColor=""transparent""'>"
											end if
											For i = 1 To fcount
												set c = headers(colmaps(i))
												htmlv = RowSplitF_v(ii)(i)
												If RowSplitSum = True And c.cangroupsum =True And excelMode = False Then
													rs_group_sum.Filter = "  " & RowSplitF_n(ii) & "=" & RowSplitF_prenv(ii)
													If rs_group_sum.eof= False Then
														htmlv =  rs_group_sum(c.dbname).value &""
													else
														htmlv = "0"
													end if
												end if
												If c.cangroupsum = False Or isnumeric(htmlv)=False Then htmlv = ""
												If App.ExistsProc("lvw_onGroupSumCell") Then
													Call lvw_onGroupSumCell(me, c, RowSplitF_n(ii),  RowSplitF_prenv(ii), htmlv, cells)
												end if
												Call createCellHtml(c, htmlv, fcount, false, isReatColm, fcount, startpost, isRepeatRow,0,0,2,0)
											next
											Set cells = nothing
											addhtml "</tr>"
										end if
									end if
									If rowsplitregin Then
										For iii = 1 To hcount
											RowSplitF_v(ii)(iii) = ""
										next
									end if
									If Len(currf_v) > 0 then
										For iii = 1 To hcount
											set c = headers(colmaps(iii))
											If fcount > c.dbindex And c.dbindex >= 0 then
												v = fs(c.dbindex).value & ""
												If isnumeric(v) = True  And c.cangroupsum = True Then
													If Len(v) = 0 Then v = 0
													cv = RowSplitF_v(ii)(iii)
													If Len(cv & "") = 0 Then cv = 0
													If isnumeric(cv) = False Then cv = 0
													RowSplitF_v(ii)(iii) = cv*1 + v*1
'If isnumeric(cv) = False Then cv = 0
												else
													If Len(v & "") > 0 then
														RowSplitF_v(ii)(iii) = v & " "
													end if
												end if
											end if
										next
									end if
									RowSplitF_prenv(ii) = currf_v
								next
							end if
						end sub
						Public Function html
							If RowSplitSum = True And excelMode=False Then
								Set rs_group_sum = rs.nextrecordset
							end if
							dim i , h , startpos , endpos , ii , iii, iiii
							dim eof , bof , pagecount , isBack, fcount
							dim itemstyle , v, c , scls
							Dim currvalue , xlsSign
							dim maxheader
							call clearHtml()
							Server.ScriptTimeOut = 99999
							If Len(Me.rowcolorkey) > 0 Then
								headers(Me.rowcolorkey).display = "none"
							end if
							If IsAbsWidth Then IsaccWidth       = true
							datawidth = 0
							If excelMode Then
								xlsSign = "3D"
								If mrecordcount > 1000000 Then
								end if
							end if
							If jsonEditModel Then
								IsAbsWidth = True
								IsaccWidth = True
								For i = 1 To Me.headers.count
									If headers(i).uitype = "hidden" Then
										headers(i).display = "none"
									end if
								next
							end if
							Call applyFormulaConfig
							If isPageReckon Then Call PageReckon
							If Len(Me.sortSql) > 0 And IsSqlSort=false Then
								on error resume next
								If excelmode Then
									Me.sortSql = Replace(Me.sortSql, "<br>", "",1,-1,1)
'If excelmode Then
								end if
								rs.sort =  convertSortField(Me.sortSql)
								On Error GoTo 0
							end if
							If pagesize <=0 Then pagesize = 10
							if excelmode then
								Call export_createJsFunction
								Call addexcelheader
								exportRecCurCnt = 0
								pagesize = app.iif(mrecordcount=0,1,mrecordcount)
								pageindex = 1
							end if
							fcount = rs.fields.count
							isBack = iscallback
							If Not excelmode Then
								if (checkbox or indexbox) then
									set h = headers.insert("选择","",1)
									If request.form("resized") = "" then
										h.width = abs(checkbox)*35 + abs(indexbox)*35+checkboxwidth
'If request.form("resized") = "" then
									else
										Dim rsnw, rsnwv :  rsnw = Split(request.form("resized"), "[!sfd]=")
										If ubound(rsnw)>0 Then
											rsnwv = Split(rsnw(1),";")
											h.width = rsnwv(0)
											Erase rsnwv
										else
											h.width = abs(checkbox)*35 + abs(indexbox)*35+checkboxwidth
											Erase rsnwv
										end if
										Erase rsnw
									end if
									h.selfitem = true
									if indexbox then h.title = "序号"
									h.cssName = "lvw_index"
									If JsonEditModel Then h.uitype = "indexcol" & Abs(indexbox) & Abs(checkbox)
									If Not headers.selcol Is Nothing Then
										Dim scol : Set scol = headers.selcol
										h.width = scol.width
										If Len(scol.title)>0 Then h.title = scol.title
										Set scol = Nothing
										Set headers.selcol = nothing
									end if
								end if
							end if
							Call loadDefSBoxHeaderVisible
							Call LoadUserConfig
							If app.existsProc("lvw_OnLoadUserConfig") Then Call lvw_OnLoadUserConfig(Me, colMaps)
							Dim bcss
							bcss = app.iif(border=1,"1","0")
							if isBack = false Then
								if len(width) = 0 then
									addhtml "<div jEM='" & Abs(jsonEditModel) & "' class='listview' fixheight='" & Abs(len(Me.height) > 0) & "' cbWaitMsg='" & cbWaitMsg & "' id=""lvw_" & id & """ style='" & iif(Me.height <> "", "height:" & height & "px;", "") & "border-width:" & bcss & "px;" & iif(noscrollModel,"overflow:visible", "") & ">"
								else
									addhtml "<div jEM='" & Abs(jsonEditModel) & "'  class='listview' fixheight='" & Abs(len(Me.height) > 0) & "' cbWaitMsg='" & cbWaitMsg & "' id=""lvw_" & id & """ style='" & iif(Me.height <> "", "height:" & height & "px;", "") & "width:" & width & "px;border-width:" & bcss & "px;" & iif(noscrollModel,"overflow:visible","") & "' autoAppendUrlParams='" & Abs(m_autoAppendUrlParams) & "'>"
								end if
							else
								if len(width) > 0 And  Not excelmode then
									addhtml "<ajaxscript>document.getElementById('lvw_" & id & "').style.width='" & width & "'</ajaxscript>"
								end if
							end if
							If Me.jsonEditModel And Me.toolbar Then
								addhtml "<div class='lvwtooldiv resetTransparent' id='lvwtooldiv_" & id & "'><script>__lvw_je_inittoptooldiv(""" & id & """);</script></div>"
							end if
							If Me.edit = True And excelMode = False  Then
								If (Me.edit.candel or Me.edit.canadd or Me.edit.rowmove) And Me.edit.rowedit then
									Set h = headers.add("&nbsp;","@editcol")
									h.uitype = "editcol"
									Dim nhindex : nhindex = ubound(ColMaps)+1
'h.uitype = "editcol"
									ReDim preserve ColMaps(nhindex)
									ColMaps(nhindex) = headers.count
									Dim h_w : h_w = Abs(Me.edit.candel)*40 + Abs(Me.edit.canadd)*40 + Abs(Me.edit.rowmove)*50 + 10
'ColMaps(nhindex) = headers.count
									If h_w < 40 Then h_w = 40
									h.width =  h_w
									h.defhtml = "<div align='center' style='" & h.width & "px;font-family:arial'>"
'h.width =  h_w
									If Me.edit.canistexpress <> "" Then
										h.defhtml = h.defhtml & "<!--@插入按钮-->"
'If Me.edit.canistexpress <> "" Then
									else
										If Me.edit.canadd Then  h.defhtml = h.defhtml & "<button type='button' class='zb-btn fs' onclick='app.lvweditor.insertRow(this,1)' title='插入增加'>增</button>"
'If Me.edit.canistexpress <> "" Then
									end if
									If Me.edit.candelExpress <> "" Then
										h.defhtml = h.defhtml & "<!--@删除按钮-->"
'If Me.edit.candelExpress <> "" Then
									else
										If Me.edit.candel Then  h.defhtml = h.defhtml & "<button type='button' class='zb-btn fs' onclick='app.lvweditor.deleteRow(this)' title='删除'>删</button>"
'If Me.edit.candelExpress <> "" Then
									end if
									If Me.edit.rowmove Then
										h.defhtml = h.defhtml & "<button type='button' class='zb-btn fs' onclick='app.lvweditor.moveRow(this,-1)' title='行上移'>↑</button>"
'If Me.edit.rowmove Then
										h.defhtml = h.defhtml & "<button type='button' class='zb-btn fs' onclick='app.lvweditor.moveRow(this,1)' title='行下移'>↓</button>"
'If Me.edit.rowmove Then
									end if
									h.defhtml = h.defhtml & "</div>"
									h.selfitem = True
								end if
								pagebar = False
								pageindex = 1
								If Not jsonEditModel Then pagesize = 1000
							end if
							If Not excelmode Then
								If Me.height = "" then
									addhtml "<div style='overflow:visible' id='lvw_tbodybg_" & id & "' class='" & Me.css & "'>"
								else
									addhtml "<div style='overflow:hidden;height:" & (height-36) & "px;' id='lvw_tbodybg_" & id & "' class='" & Me.css & "'>"
									addhtml "<div style='overflow:visible' id='lvw_tbodybg_" & id & "' class='" & Me.css & "'>"
								end if
							end if
							if dbmodel <> "sql" then
								addhtml "<div class='lvw_scrollbar' id='lvw_sclbar_" & id & "'>&nbsp;</div>"
							end if
							Dim colresized : colresized = Len(request.form("resized")) > 0
							dim vheaders , vheaderscount
							redim vheaders(0)
							for i = 1 to headers.count
								set h = headers(ColMaps(i))
								if h.display <> "none" then
									if IsVisibleCol(h.dbname) then
										If Len(h.joinfields) > 0 And Not excelmode  Then
											If h.joinvisible = True Then
												h.execdisplay = ""
											else
												h.execdisplay = "none"
											end if
										else
											h.execdisplay = ""
										end if
									else
										h.execdisplay = "none"
									end if
								else
									h.execdisplay = "none"
								end if
								if h.execdisplay <> "none" then
									vheaderscount = vheaderscount + 1
'if h.execdisplay <> "none" then
									redim preserve vheaders(vheaderscount)
									set vheaders(vheaderscount) = h
								end if
							next
							maxheader = 0
							dim chdeep, isabcw
							isabcw = true
							for i = vheaderscount to 1 step - 1
'isabcw = true
								set h = vheaders(i)
								If isnumeric(h.width)  And h.display<> "none" then
									datawidth = datawidth*1 + CLng(h.width)
'If isnumeric(h.width)  And h.display<> "none" then
								else
									If Len(h.width & "") > 0 Then
										isabcw = False
									end if
								end if
								if dbmodel = "sql" then
									h.selid = -abs(h.selid)
'if dbmodel = "sql" then
								else
									h.selid = abs(h.selid)
								end if
								h.ectitle = replace(h.ectitle , "__","_~")
								if instr(h.ectitle,"_") > 0 then
									chdeep = ubound(split(h.ectitle,"_"))
									if chdeep > maxheader then
										maxheader = chdeep
									end if
								end if
							next
							If isabcw = False Then datawidth = ""
							dim mvheaders, tmparr , mcolspan, item , currht, currht2, mrowspan, fullname
							redim mvheaders(maxheader, vheaderscount)
							for i = 1 to vheaderscount
								set h = vheaders(i)
								tmparr = split(h.ectitle & "_________________", "_")
								mrowspan = 0
								for ii =  maxheader to 0 step - 1
'mrowspan = 0
									set mvheaders(ii,i) = new moveHeaderColItem
									set item = mvheaders(ii,i)
									item.text = tmparr(ii)
									item.splitCell = h.splitCell
									fullname = ""
									for iii = 0 to  ii
										fullname =  fullname  & "_" & tmparr(iii)
									next
									item.fullname = fullname
									item.rowspan = mrowspan
									if item.text  = "" And h.dbname<>"@editcol" then
										mrowspan = mrowspan + 1
'if item.text  = "" And h.dbname<>"@editcol" then
										item.rowspan = 0
									else
										if ii > 0 then
											if  item.text  =  tmparr(ii-1)  then
'if ii > 0 then
												item.text = ""
												item.rowspan = 0
												mrowspan = mrowspan + 1
'item.rowspan = 0
											else
												mrowspan = mrowspan + 1
												item.rowspan = 0
												item.rowspan = mrowspan
												mrowspan = 0
											end if
										else
											mrowspan = mrowspan + 1
											mrowspan = 0
											item.rowspan = mrowspan
										end if
									end if
								next
							next
							for i = 0 to maxheader
								mcolspan = 0
								for ii = vheaderscount to 1 step -1
'mcolspan = 0
									set item = mvheaders(i,ii)
									if ii > 1 Then
										if item.fullname <> mvheaders(i,ii-1).fullname Or Me.headNameJoin=False or maxheader=0 then
'if ii > 1 Then
											mcolspan = mcolspan + 1
'if ii > 1 Then
											item.colspan = mcolspan
											mcolspan  = 0
										else
											mcolspan =  mcolspan + 1
											mcolspan  = 0
											item.colspan = 0
											mvheaders(i,ii-1).splitCell = item.splitCell
'item.colspan = 0
										end if
									else
										mcolspan =  mcolspan + 1
										item.colspan = 0
										item.colspan = mcolspan
									end if
								next
							next
							Dim item2
							for i = 0 to maxheader
								iii = 0
								for ii = 1 To vheaderscount
									set item = mvheaders(i,ii)
									If i = 0 Then
										If item.colspan > 0 Then
											iii = iii + 1
'If item.colspan > 0 Then
											item.htmlid = "lvwH_" & Me.id & "_" & i  & "_" & iii
										end if
									else
										If item.colspan > 0 Then
											item.htmlid = "lvwH_" & Me.id & "_" & i  & "_" & iii
											For iiii = 1 To  vheaderscount-1
'item.htmlid = "lvwH_" & Me.id & "_" & i  & "_" & iii
												Set item2 = mvheaders(i-1,iiii)
'item.htmlid = "lvwH_" & Me.id & "_" & i  & "_" & iii
												If item2.colspan > 1 Then
													If  left(item.fullname,Len(item2.fullname))=item2.fullname Then
														item.parenthtmlid = item2.htmlid
													end if
												end if
											next
										end if
									end if
								next
							next
							Dim fixh
							fixh = Len(Me.height) > 0
							Dim hsvisiblecol : hsvisiblecol = false
							if not me.excelmode then
								addhtml "<div fixedCell='" & fixedCell & "'"
								If Abs(fixedHead) = 1 Then
									addhtml " onmousedown=""__lvwdisMiddleBtn(this)"" "
								end if
								addhtml " fixh='" & Abs(Me.fixedHead) & "' onmousewheel='try{return __lvwscrollousewheel(this," &Abs(jsonEditModel)& ")}catch(e){}' onscroll='return __lvwscrollfixed(this)'  name='lvw_tablebgs' class='lvw_tablebg' style='"
								If Me.height <> "" Then
									addhtml "height:" & (Me.height-36) & "px;position:" & iif(Me.fixedHead Or Me.fixedCell>0, "relative","static") & ";width:100%;"
'If Me.height <> "" Then
								end if
								If jsonEditModel Then
									addhtml "border:1px solid #ccc;width:auto;_width:100%"
								ElseIf (scroll or noScrollModel) Then
									addhtml "width:auto;overflow:visible;"
								else
									addhtml ""
								end if
								If IsAbsWidth Then addhtml "width:" & datawidth & "px"
								addhtml "' id='lvw_tablebg_" & id & "'"
								addhtml " onresize='__tvwcolresize(this,""" & id & """," & Abs(me.Autoresize) & ")'"
								addhtml ">"
								If Me.border= 0 And jsonEditModel=false Then
									css = css & ";border-top:0px solid #cccddc; border-left:0px solid #cccddc;top:0px;left:0px"
'If Me.border= 0 And jsonEditModel=false Then
								else
									css = css & ";border-top:0px; border-left:0px;border-bottom:0px"
'If Me.border= 0 And jsonEditModel=false Then
								end if
								If IsAbsWidth Then css = css & ";width:" & datawidth & "px"
								If Len(datawidth) = 0 Then css = css & ";width:100%;"
								If Len(Me.height) > 0 Then css = css & ";position:static;margin-right:1px;margin-bottom:1px;"
'If Len(datawidth) = 0 Then css = css & ";width:100%;"
								addhtml "<table hckey='" & HeaderConfigKey & "' key16='" & md5key16 & "' class='" & iif(jsonEditModel,"je lvwframe2 detailTableList","lvwframe2 detailTableList") &"' style='" & css & "' " & iif(noScrollModel,"style='table-layout:auto'","") & " datawidth='" & datawidth & "' id='lvw_dbtable_" & id & "' maxheads='" & (maxheader+1) & "' colresize='" & abs(Me.colresize) & "' " & iif(colresized, "colresized='1'","") & iif(jsonEditModel,"onmousedown='__lvw_jn_tbmd(this)'","") & ">"
'If Len(datawidth) = 0 Then css = css & ";width:100%;"
								for ii = 1 to vheaderscount
									set h = vheaders(ii)
									If h.display = "none" then
										If headers.isZdyMode = 0 Then
											addhtml  "<col style='width:0px;background:;display:none' dbname='" & h.dbname & "' title='" & app.htmlconvert(h.ectitle) & "' cansort='0'/>"
										end if
									else
										If IsAbsWidth Then
											addhtml  "<col style='width:" & h.width & "px;background:;' dbname='" & h.dbname & "' title='" & app.htmlconvert(h.ectitle) & "' cansort='" & Abs(h.cansort) & "' />"
										else
											addhtml  "<col style='background:;' dbname='" & h.dbname & "'  title='" & app.htmlconvert(h.ectitle) & "' cansort='" & Abs(h.cansort) & "'/>"
										end if
										hsvisiblecol = true
									end if
								next
							end if
							dim vcolspan
							vcolspan = 0
							Dim jsleefheader
							Dim firstvRows
							Dim expHTML
							Dim whtml, rsizehtml
							firstvRows = 0
							for ii = 1 to vheaderscount
								set item = mvheaders(0,ii)
								if item.colspan > 0 and item.rowspan > 0 then
									firstvRows = firstvRows + 1
'if item.colspan > 0 and item.rowspan > 0 then
								end if
							next
							Dim idxBegin,idxEnd
							If excelmode Then
								idxBegin = xsheet.getCurrCacheIndex()
							end if
							Dim isIE :isIE=(InStr(1,sdk.vbl.GetBrowser(request),"Internet Explorer",1)>0)
							addhtml "<tbody id='lvw_tby_" & id & "' class='" & app.iif(Me.fixedHead And isIE , "fxh", "") & "' sumr=" & Abs(Abs(Me.currsum) + Abs(Me.allsum)) & " "
'Dim isIE :isIE=(InStr(1,sdk.vbl.GetBrowser(request),"Internet Explorer",1)>0)
							Dim edithtmlpos
							If Me.edit then
								Dim dbcols
								ReDim dbcols( rs.fields.count - 1)
'Dim dbcols
								For i = 0 To rs.fields.count - 1
'Dim dbcols
									dbcols(i) = rs.fields(i).name  & "&#02;" & rs.fields(i).type & "&#02;" & headers(rs.fields(i).name).defaultValue & "&#02;" & headers(rs.fields(i).name).onchange
								next
								addhtml " coldatas=""" & Join(dbcols, "&#01;") & """ "
								addhtml " indexbox=" & Abs(indexbox) & " "
								edithtmlpos = addhtml(" startpos=@startpos endpos=@endpos ")
							end if
							addhtml ">"
							If excelmode Then
								If request("title") <> "" Then
									addhtml "<tr><td colspan='"& app.iif(checkbox or indexbox ,vheaderscount-1 , vheaderscount)  &"' style='text-align:center;font-weight:bold;'>" & request("title") & "</td></tr>"
'If request("title") <> "" Then
								end if
								If app.existsProc("App_lvw_onExcelProc") Then
									Dim itemhtml , sty
									Call App_lvw_onExcelProc(Me,"head", itemhtml , sty)
									If Len(itemhtml)>0 Then
										If sty = 0 Then
											addhtml "<tr><td colspan='"& app.iif(checkbox And indexbox ,vheaderscount-1 , vheaderscount)  &"'>"& itemhtml &"</td></tr>"
'If sty = 0 Then
										else
											addhtml itemhtml
										end if
									end if
								end if
							end if
							If colresize And Not excelmode Then  rsizehtml = " onmousemove='__lv_recolsize(this,0)' onmousedown='__lv_recolsize(this,1)' "
							for i = 0 to maxheader
								addhtml "<tr id='" & iif(jsonEditModel,"je","") & "'>"
								for ii = 1 to vheaderscount
									set h = vheaders(ii)
									set item = mvheaders(i,ii)
									if me.excelmode then
										if isnumeric(item.text) then
											item.text = chr(2) & item.text
										end if
									end if
									if i = 0 then
										if lcase(h.execdisplay) <> "none" and h.visible = true then
											vcolspan = vcolspan + 1
'if lcase(h.execdisplay) <> "none" and h.visible = true then
										end if
									end if
									if item.colspan > 0 and item.rowspan > 0 then
										if me.excelmode then
											If  ii = vheaderscount And headerPageSizeUI Then
												h.execdisplay = "none"
											end if
											if  h.execdisplay  <> "none" Then
												addhtml "<" & app.iif(i=0,"th","td") & " colspan='" & item.colspan & "' rowspan='" & item.rowspan & "' class='lvwheader' style=" & xlsSign & "'width:" & h.width & ";" & iif(len(h.execdisplay)>0,"display:" & h.execdisplay & ";","") & "'>" & Replace(item.text,"=","＝") & "</" & app.iif(i=0,"th", "td") & ">"
											end if
										else
											If isnumeric(Me.width) And Len(Me.width & "") > 0 Then
												addhtml "<" & app.iif(i=0,"th","td") & rsizehtml & " pid='" & item.parenthtmlid & "' id='" & item.htmlid & "' colspan='" & item.colspan & "' rowspan='" & item.rowspan & "' class='lvwheader" &  iif(i=0," h_1"," h_2") & iif(ii=1," l_1","") & "' "
												If i = maxheader Then
													addhtml " dbname=""" & h.dbname & """ "
													If h.onchange <> "" Then
														addhtml " eonchange=""" & h.onchange & """ "
													end if
												end if
												addhtml " style='" & iif(item.splitCell,"border-right:2px solid " & splitColor,"") & ";width:" &  clng(h.width*item.colspan) & "px;" & iif(len(h.execdisplay)>0,"display:" & h.display & ";","") & "' cindex='" & ii &"'><table class='lvwframe4" & iif(Len(Me.height) > 0, "_h","") & "' align='center' " & iif(noScrollModel,"style='table-layout:auto'","")  & " ><tr>"
												addhtml " eonchange=""" & h.onchange & """ "
											else
												If me.IsaccWidth = true then
													whtml = "width:" & h.width*item.colspan & "px;"
												else
													if firstvRows>50 Then
														whtml = "width:1%;"
													else
														If Len(datawidth) = 0 Then
															If isnumeric(h.width) then
																whtml = "width:" & h.width*item.colspan & "px;"
															else
																whtml = "width:" & h.width & ";"
															end if
														else
															If isnumeric(h.width) then
																whtml = "width:" & CLng(h.width*100/datawidth)*item.colspan & "%;"
															else
																whtml = "width:" & h.width  & ";"
															end if
														end if
													end if
												end if
												addhtml "<" & app.iif(i=0,"th","td")  & rsizehtml & " pid='" & item.parenthtmlid & "' id='" & item.htmlid & "' colspan='" & item.colspan & "' rowspan='" & item.rowspan & "' class='lvwheader" & app.iif(i=0," h_1"," h_2") & iif(ii=1," l_1","") & "' "
												If i = maxheader Then
													addhtml " dbname=""" & h.dbname & """ "
													If h.onchange<> "" Then
														addhtml " eonchange=""" & h.onchange & """ "
													end if
												end if
												addhtml " style='" & iif(item.splitCell,"border-right:2px solid " & splitColor,"") & ";"
												addhtml " eonchange=""" & h.onchange & """ "
												addhtml whtml
												addhtml iif(len(h.execdisplay)>0,"display:" & h.display & ";","") & "' cindex='" & ii &"'><table class='lvwframe4"& iif(Len(Me.height) > 0, "_h","") & "' align='center' " & iif(noScrollModel,"style='table-layout:auto'","") & " ><tr>"
'addhtml whtml
											end if
											expHTML = ""
											If Me.headexplan  Then
												If Len(item.Text)>4 Then
													If Right(item.Text,4) = "#" then
														If i = 0 Then
															If isExplanHeader(item.Text) then
																expHTML = "<input style='cursor:pointer' onclick='__lvw_expheader(0,""" & Replace(Replace(item.text,"#",""),"""","\""") & """,""" & Me.id & """)' type=image src='" & app.GetVirPath() & "/skin/" & Info.skin & "/images/12.gif'>"
															else
																expHTML = "<input style='cursor:pointer' onclick='__lvw_expheader(1,""" & Replace(Replace(item.text,"#",""),"""","\""") & """,""" & Me.id & """)' type=image src='" & app.GetVirPath() & "/skin/" & Info.skin & "/images/11.gif'>"
															end if
														end if
														item.Text = Replace(item.text,"#","")
													end if
												end if
											end if
											if len(h.ico) > 0 then
												addhtml "<td style='width:16px'><img src='" & h.ico & "'></td>"
											else
												addhtml "<td style='display:none'></td>"
											end if
											jsleefheader = True
											If maxheader > 0 then
												If Len(item.text) = Len(h.title) Then
													jsleefheader = True
												ElseIf Len(item.text) < Len(h.title) then
													jsleefheader = Right(h.title, Len(item.text) + 1) = "_" & item.Text Or InStr(h.title, item.Text & "#X#") > 0
'ElseIf Len(item.text) < Len(h.title) then
												else
													jsleefheader = false
												end if
											end if
											Dim cvs
											If  ii = vheaderscount And headerPageSizeUI Then
												addhtml "<" & app.iif(i=0,"th","td")  & ">"
												Call showHeaderPagesize
												addhtml "</" & app.iif(i=0,"th","td")  & ">"
											else
												If jsleefheader  And Len(h.joinFields) > 0 Then
													addhtml "<" & app.iif(i=0,"th","td") & ">"
													addHtml "<select class='lvwhselbox' onchange='__lvwHeaderChange(this,""" & id & """)'>"
													Call showSelectHeaderList( h )
													addhtml "</select>"
													addhtml "</" & app.iif(i=0,"th","td") & ">"
												else
													If Me.cansort And jsleefheader And Not isdisSortCol(h) Then
														If h.sortType = 1 Then
															scls = "<input class='lvwsort1' type=button>"
														ElseIf h.sortType = 2 Then
															scls = "<input class='lvwsort2' type=button>"
														else
															scls = ""
														end if
														addhtml "<" & app.iif(i=0,"th","td") & " noWrap pid='s_" & item.parenthtmlid & "' id='s_" & item.htmlid & "' dbname=""" & h.dbname & """  style='height:" & app.iif(i=0,"38", "38") & "px;cursor:pointer;'  title='点击排序' onmouseover='app.unline(this,1)' onclick='__lvwsort(this," & h.sortType &" ," & id & ")"
													else
														If jsonEditModel Then
															If  checkbox And i = 0 And ii=1 Then
																item.Text = "<input type='checkbox' onclick=""__lvw_je_checkall(this,'" & id & "')""><span style='color: #dddddf;'>|</span>" & item.Text
															end if
														end if
														addhtml "<" & app.iif(i=0,"th","td") & " noWrap pid='s_" & item.parenthtmlid & "' id='s_" & item.htmlid & "' dbname=""" & h.dbname & """  style='height:" & app.iif(i=0,"38", "38") & "px;cursor:default;' " & rsizehtml & ">" & expHTML & item.text & "</" & app.iif(i=0,"th","td") & ">"
													end if
												end if
											end if
											if h.selid > 0 then
												addhtml "<td style='width:16px'><button class='button'></button></td>"
											else
												addhtml "<td style='display:none'></td>"
											end if
											addhtml "</tr></table></" & app.iif(i=0,"th","td") & ">"
										end if
									end if
								next
								addhtml "</tr>"
							next
							If excelmode Then
								idxEnd = xsheet.getCurrCacheIndex()
								exportHeaderHtml = ""
								For i = idxBegin To idxEnd
									exportHeaderHtml = exportHeaderHtml & xsheet.getHtmlFromCacheByIndex(i)
								next
							end if
							If pageMode=True Then
								startpos=1
								endpos = currPageRecordcount
								pagecount = int( mrecordcount / pagesize) + abs( mrecordcount mod pagesize > 0)
'endpos = currPageRecordcount
								If pagecount &"" = "0" Then pagecount = 1
								If pageindex>pagecount Then pageindex =  pagecount
							else
								if dbmodel = "sql" then
									startpos = (pageIndex-1)*pageSize + 1
'if dbmodel = "sql" then
									if startpos >= mrecordcount then startpos = int( mrecordcount / pagesize)*pagesize + 1
'if dbmodel = "sql" then
									if startpos < 1 then startpos = 1
									endpos = startpos  + pagesize - 1
'if startpos < 1 then startpos = 1
									if endpos >  mrecordcount then endpos = mrecordcount
									bof = (startpos <= 1)
									eof = endpos >= mrecordcount
									pagecount = int( mrecordcount / pagesize) + abs( mrecordcount mod pagesize > 0)
'eof = endpos >= mrecordcount
									pageindex = int(startpos / pagesize) + 1
'eof = endpos >= mrecordcount
									if pageindex > pagecount and pagecount > 0 then
										pageindex = pagecount
										startpos = (pageIndex-1)*pageSize + 1
'pageindex = pagecount
										endpos = mrecordcount
									end if
								else
									startpos = 1
									endpos = mrecordcount
									pageindex = 1
								end if
							end if
							Dim f, n, hcount
							hcount = headers.count
							ReDim currsumarray(hcount), allsumarray(hcount)
							Dim RowSplitF_n, RowSplitF_v(), RowSplitF_prenv(), RowSplitF_count, currf_v, rowsplitregin, RowS_data()
							If Len(Me.RowSplitFields) > 0  Then
								RowSplitF_n = Split(Me.RowSplitFields, "|")
								RowSplitF_count = ubound(RowSplitF_n) + 1
'RowSplitF_n = Split(Me.RowSplitFields, "|")
								ReDim RowSplitF_v(RowSplitF_count-1)
'RowSplitF_n = Split(Me.RowSplitFields, "|")
								ReDim RowSplitF_prenv(RowSplitF_count-1)
'RowSplitF_n = Split(Me.RowSplitFields, "|")
								ReDim RowS_data(hcount)
								For i = 0 To RowSplitF_count - 1
'ReDim RowS_data(hcount)
									RowSplitF_v(i) = RowS_data
								next
							else
								ReDim RowSplitF_n(0)
								RowSplitF_count = 0
							end if
							for ii = 1 to hcount
								If allsum = true Then
									allsumarray(ii) = 0
								else
									allsumarray(ii) = "t"
								end if
								If currsum = true Then
									currsumarray(ii) = 0
								else
									currsumarray(ii) = "t"
								end if
							next
							if me.excelmode then
								startpos = 1
								endpos = mrecordcount
								showExcelProc 100, 2
							end if
							for i=1 to startpos - 1
								showExcelProc 100, 2
								Call regRowSplitData(RowSplitF_count, RowSplitF_n, RowSplitF_prenv, RowSplitF_v, hcount, 0, startpos, isRepeatRow, i)
								If  allsum = True Then
									for ii = 1 to  headers.count
										set c = headers(colmaps(ii))
										If fcount > c.dbindex And c.dbindex >= 0 then
											v = fs(c.dbindex).value & ""
											If isnumeric(v) = True And isnumeric(allsumarray(ii)) = true Then
												If Len(v) = 0 Then v = 0
												allsumarray(ii) = allsumarray(ii)*1 + v*1
'If Len(v) = 0 Then v = 0
											end if
										end if
									next
								end if
								rs.movenext
							next
							htmlarray(edithtmlpos) = Replace( htmlarray(edithtmlpos) & "", "@startpos", startpos)
							htmlarray(edithtmlpos) = Replace( htmlarray(edithtmlpos) & "", "@endpos", endpos)
							Dim dSColList(), dSPColListV(), dSCColListV() , isReatCol(), ndReatIf, mspc, onlygroupCol,cvalue
							Dim celldS , ccount, tmpcl, repeatGroups, nm, RepeatColdeep, di
							If Len(trim(distinctSpaceCol)) > 0 Then
								repeatGroups = Split(distinctSpaceCol,"|")
								RepeatColdeep = ubound(repeatGroups)
								ReDim dSColList(RepeatColdeep)
								ReDim dSPColListV(RepeatColdeep)
								ReDim dSCColListV(RepeatColdeep)
								ReDim isReatCol(RepeatColdeep)
								ReDim onlygroupCol(RepeatColdeep)
								ReDim mspc(RepeatColdeep)
								For i = 0 To RepeatColdeep
									nm = repeatGroups(i)
									tmpcl = Split(nm & "",";")
									dSColList(i) = Split(tmpcl(0),",")
									mspc(i) = "," & tmpcl(0) & ","
									If ubound(tmpcl) = 1 Then
										onlygroupCol(i) = "," & tmpcl(1) & ","
									else
										onlygroupCol(i) = ""
									end if
								next
								ndReatIf = True
							else
								repeatColdeep = -1
								ndReatIf = True
								ndReatIf = False
								ReDim isReatCol(0)
								isReatCol(0) = false
							end if
							Dim fh, fv
							checkvalueIndex = 0
							If isInsertModel = True Then
								Dim ofs,  insertDatas, fsdata
								For i = 0 To ubound(fs)
									fsdata = fsdata & Chr(1) & Chr(5) & Chr(3)
								next
								insertDatas = Split(request.form("newData") & fsdata, Chr(1) & Chr(5) & Chr(3))
								For i = 0 To ubound(fs)
									Set ofs = new InsertValueItem
									ofs.name = fs(i).name
									ofs.value = insertDatas(i)
									Set fs(i) = ofs
									If LCase(ofs.name) =  checkvalue Then
										checkvalueIndex = i
									end if
								next
								startpos = mrecordcount
								endpos = mrecordcount
								call clearHtml()
							end if
							If excelmode Then
								ReDim Preserve prevValues(1,headers.count)
							end if
							addhtml "<!--#lvw_data_begin#-->"
							ReDim Preserve prevValues(1,headers.count)
							Dim isRepeatRow
							If jsonEditModel = false Then
								for i = startpos to endpos
									If LCase(Me.DataOverflow) = "hidden" Then
										If i - startpos - pagesize = 0 Then Exit for
'If LCase(Me.DataOverflow) = "hidden" Then
									end if
									exportRecIdx = i
									exportRecCnt = exportRecCnt + 1
'exportRecIdx = i
									isRepeatRow = False
									Call regRowSplitData(RowSplitF_count, RowSplitF_n, RowSplitF_prenv, RowSplitF_v, hcount, 1, startpos, isRepeatRow, i)
									If ndReatIf Then
										For di = 0 To RepeatColdeep
											dSCColListV(di) = ""
											For ii = 0 To ubound(dSColList(di))
												dSCColListV(di) = rs(dSColList(di)(ii)).value & Chr(1) & dSCColListV(di)
											next
											If dSCColListV(di) = dSPColListV(di) Then
												isReatCol(di) = True
												isRepeatRow = True
											else
												isReatCol(di) = false
												dSPColListV(di) = dSCColListV(di)
											end if
										next
									end if
									If excelmode Then
										Call AutoSplitSheetOrFile(rs,isRepeatRow)
									end if
									Dim bgcolor
									bgcolor = ""
									If Len(Me.rowcolorkey) > 0 Then
										bgcolor = rs(Me.rowcolorkey).value & ""
									end if
									If Len(bgcolor) > 0 Then
										addhtml "<tr l_r=1 bgcolor='" & bgcolor & "'>"
									else
										addhtml "<tr l_r=1 onmouseover='this.bgColor=""#EAEAEA""' onmouseout='this.bgColor=""transparent""'>"
									end if
									ccount = headers.count
									for ii = 1 to ccount
										set c = headers(colmaps(ii))
										celldS = false
										If c.dbindex = -1 Then
'celldS = false
											currvalue = c.defhtml
										else
											If Me.recordcanedit then
												currvalue = getCurrEditValue(c.dbname)
											else
												currvalue = fs(c.dbindex).value
											end if
											For di = 0 To RepeatColdeep
												If isReatCol(di) = True Then
													nm = fs(c.dbindex).name
													If InStr(mspc(di) , "," & nm & ",") > 0 Then
														If Len(onlygroupCol(di))=0 or InStr(onlygroupCol(di) ,"," & nm & ",") = 0 Then
															If Len(c.Formula) > 0 Or Len(c.LinkFormat) > 0 then
																currvalue = "@isRepeat!"
															else
																currvalue = ""
															end if
															celldS = True
														end if
													end if
												end if
											next
										end if
										If excelmode Then
											prevValues(0,ii) = c.dbName
											prevValues(1,ii) = currvalue
										end if
										Call createCellHtml(c, currvalue, fcount, celldS, isReatCol, ccount, startpos, isRepeatRow, currsumarray(ii), allsumarray(ii), 1, i)
									next
									If excelmode Then
										If showExcelProc(100, CLng(2 +  ((i - startpos)*1.0/(endpos-startpos+0.0001))*96)) = False Then
'If excelmode Then
											Exit function
										end if
									end if
									addhtml "</tr>"
									rs.movenext
									If rs.eof = True Then Exit For
								next
								If pageindex = pagecount And recordcount>0 then
									Call regRowSplitData(RowSplitF_count, RowSplitF_n, RowSplitF_prenv, RowSplitF_v, hcount, 2, startpos, isRepeatRow,endpos)
								else
									If rs.eof = False Then
										Call regRowSplitData(RowSplitF_count, RowSplitF_n, RowSplitF_prenv, RowSplitF_v, hcount, 1, startpos, isRepeatRow,endpos)
									end if
								end if
								If isInsertModel = True Then
									html = join(htmlarray,"")
									Exit function
								end if
								If allsum = True Then
									While Not rs.eof
										for ii = 1 to headers.count
											set c = headers(ii)
											If c.dbindex > -1 then
'set c = headers(ii)
												v = fs(c.dbindex).value
												If isnumeric(v & "") = True And isnumeric(allsumarray(ii)) = true Then
													If Len(v) = 0 Then v = 0
													Select Case c.dbtype
													Case "number" : v = FormatNumber(v, Info.FloatNumber,-1,0,-1)
'Select Case c.dbtype
													Case "money" : v = FormatNumber(v, Info.moneyNumber,-1,0,-1)
'Select Case c.dbtype
													end select
													allsumarray(ii) = CDbl(allsumarray(ii))*1 + CDbl(v) * 1
'end select
												end if
											end if
										next
										rs.movenext
									wend
								end if
								if endpos  < startpos And Me.showNullDate Then
									If Me.excelmode = False Then
										addhtml "<tr><td colspan=" & vcolspan &  "  class='lvw_cell nulldata'>"
										If App.ExistsProc("App_lvw_onnullData") Then
											Call App_lvw_onnullData(me)
										else
											addhtml "<div class='lvw_nulldata'>&nbsp;</div>"
										end if
										addhtml "</td></tr>"
									else
										addhtml "<tr><td colspan=" & vcolspan &  "  class='lvw_cell' rowspan=2>&nbsp;&nbsp;没有数据信息...</td></tr>"
									end if
									hsvisiblecol = true
								else
									Call showlistSum(currsumarray, allsumarray)
								end if
							else
								addhtml "<script id='lvw_Json_" & Me.id & "'>window.lvw_JsonData_" & Me.id & "="
								If me.iscallback Then clearHtml
								addhtml "{id:""" & Me.id & """,istreegrid:"& Abs(istreegrid) &",allsum:" & Abs(Me.allsum) & ",pagesize:" & pagesize & ","
								addhtml "selpos:0,rowhide:" & Abs(Me.edit.rowhide) & ","
								addhtml "checkvalue:"""& Me.checkvalue &""",pagebar:"& Abs(pagebar) &","
								addhtml "pageindex:" & pageindex & ",recordcount:" & recordcount & ",headers:[" & vbcrlf
								ccount = headers.count
								For i = 1 To ccount
									Set h =  headers(colmaps(i))
									If h.dbtype="" then
										Select Case h.uitype
										Case "money" : h.dbtype = "money"
										Case "number" : h.dbtype = "number"
										Case "hl" : h.dbtype = "hl"
										Case "kz" : h.dbtype = "kz"
										Case "datetime","time","date": h.dbtype = "datetime"
										Case Else h.dbtype = "str"
										End select
									end if
									If i> 1 Then addhtml "," & vbcrlf
									addhtml "{i:" & (i-1) & ",dbname:""" & h.dbname & """,eAttr:" & h.EditAttrsJson & ","
'If i> 1 Then addhtml "," & vbcrlf
									If h.title <> "" Then addhtml "title:""" & h.title & ""","
									If h.dbtype <> "" Then addhtml "dbtype:""" & h.dbtype & ""","
									If h.excelAlign<>"" Then addhtml "excelAlign:""" & h.excelAlign & ""","
									If h.ContentStyle<> "" Then addhtml "ContentStyle:""" & h.ContentStyle & ""","
									If h.uitype <> "" Then addhtml "uitype:""" & h.uitype & ""","
									If h.canBatchInput <> "" Then addhtml "canBatchInput:""" & h.canBatchInput & ""","
									If h.display <> "" Then addhtml "display:""" & h.display & ""","
									If h.align <> "" Then addhtml "align:""" & h.align & ""","
									If h.boxWidth<>"" And h.boxWidth<>"70%" Then addhtml "boxwidth:""" & h.boxWidth & ""","
									If Abs(h.cansum)<>1 Then addhtml "csum:" & Abs(h.cansum) & ","
									addhtml "defval:""" & app.ConvertJsText(h.defaultValue) & """,oread:" & Abs(h.onlyread) & ","
									If Len(h.source)>0 Then
										If InStr(1,h.source,"url:",1)=1 Then
											addhtml "srcScript:""__lvw_je_sorceurlOpen('" & app.ConvertJsText(Replace(h.source,"url:","",1,1,1)) & "',this)"","
										elseIf InStr(1,h.source,"script:",1)=1  Then
											addhtml "srcScript:""" & app.ConvertJsText(Replace(h.source,"script:","",1,1,1)) & ""","
										else
											Dim tmsrc : Set tmsrc = app.GetSource(h.source)
											If tmsrc.stype = 9 Then
												addhtml "source:{stype:""tree"",nodes:" & h.treesource.JSON(false) & "},"
												Set h.treesource = nothing
											else
												addhtml "source:" & tmsrc.createJSON() & ","
											end if
											If Len(tmsrc.filterexpress) > 0 Then
												For ii = 1 To headers.count
													If LCase(headers(ii).dbname) = LCase(tmsrc.filterexpress) Then
														addHtml "filter:""" &  (ii-1) & ""","
'If LCase(headers(ii).dbname) = LCase(tmsrc.filterexpress) Then
													end if
												next
											end if
											Set tmsrc = nothing
										end if
									end if
									addhtml "notnull:" & Abs(h.notnull) & ",editlock:""" &  app.ConvertJsText(h.EditLock) & ""","
									addhtml "width:""" & h.width & ""","
									addhtml "fmhtml:""" & app.ConvertJsText(h.formatText) & """"
									addhtml "}"
								next
								addhtml "]," & vbcrlf & "edit:{"
								addhtml "candel:" & Abs(me.edit.candel) & ",canadd:" & Abs(me.edit.canadd) & ",rowmove:" & Abs(Me.edit.rowmove)
								addhtml "}," & vbcrlf
								addhtml "rows:["
								i = 0
								While rs.eof = False
									If i > 0 Then addhtml ","
									addhtml "["
									For ii = 1 To ccount
										set c = headers(colmaps(ii))
										celldS = false
										If c.dbindex = -1 Then
											celldS = false
											currvalue = c.defhtml
										else
											If Me.recordcanedit then
												currvalue = getCurrEditValue(c.dbname)
											else
												currvalue = fs(c.dbindex).value
											end if
											For di = 0 To RepeatColdeep
												If isReatCol(di) = True Then
													nm = fs(c.dbindex).name
													If InStr(mspc(di) , "," & nm & ",") > 0 Or  InStr(onlygroupCol(di) ,"," & nm & ",") > 0 Then
														If Len(c.Formula) > 0 Or Len(c.LinkFormat) > 0 then
															currvalue = "@isRepeat!"
														else
															currvalue = ""
														end if
														celldS = True
													end if
												end if
											next
										end if
										If ii>1 Then addhtml ","
										If c.dbname = "@editcol" then  currvalue = ""
										Call createCellHtml(c, currvalue, fcount, celldS, isReatCol, ccount, startpos, false, currsumarray(ii), allsumarray(ii), 1, i)
									next
									addhtml "]"
									i = i + 1
'addhtml "]"
									rs.movenext
								wend
								addhtml "],"
								addhtml "sums:["
								For ii = 1 To ccount
									If ii > 1 Then addhtml ","
									If isnumeric(allsumarray(ii)) Then
										addhtml allsumarray(ii)
									else
										addhtml """*"""
									end if
								next
								Dim StrRows
								If recordcount > 0 Then StrRows = "0"
								For ii = 1 To recordcount-1
'If recordcount > 0 Then StrRows = "0"
									StrRows = StrRows & ("," & ii)
								next
								addhtml "],VRows:[" & StrRows & "],"
								addhtml "Refresh:function(){___RefreshListViewByJson(window.lvw_JsonData_" & id & ");},"
								addhtml "addNew:__lvw_je_addNewProx(""" & id & """),"
								addhtml "insertRow:__lvw_je_insertRow(""" & id & """),"
								addhtml "insertRows:__lvw_je_insertRows(""" & id & """),"
								addhtml "deleteRow:__lvw_je_deleteRow(""" & id & """),"
								addhtml "deleteRows:__lvw_je_deleteRows(""" & id & """),"
								addhtml "doSum:function(){___ReSumListViewByJsonData(window.lvw_JsonData_" & id &");}"
								addhtml "}"
								If Me.iscallback Then html = join(htmlarray,"") : Exit function
								addhtml ";___ResponseListViewByJson(window.lvw_JsonData_" & Me.id & ");"
								addhtml "</script>"
							end if
							addhtml "<!--#lvw_data_end#-->"
							addhtml "</script>"
							if not me.excelmode then
								addhtml "</tbody></table>"
								If hsvisiblecol = False Then
									addhtml "<div style='padding:20px;text-align:center;border:1px solid #cdcfe4;'><b>温馨提示</b>：当前列表没有可显示的列，请确认相关设置是否正确。</div>"
'If hsvisiblecol = False Then
								end if
								if len(Me.endHtml & "") > 0 Then addhtml Me.endHtml
								addhtml "</div>"
								If jsonEditModel Then
									addhtml "<div class='lvwjsnscrollbar' style='display:" & iif(recordcount>pagesize,"","none") & ";' id='lvwjsnscrollbar_" & Me.id & "' onscroll='__lvwjneditscroll(""" & Me.id & """)'><div class='lvwscrollbar' id='lvwscrollbar_" & Me.id & "' style='height:" & clng((recordcount/pagesize)*100+1) & "%'>&nbsp;</div></div><script>__lvw_handlescrolbar_init(""" & id & """);__lvw_initbtmtooldiv(""" & id & """);</script>"
									addhtml "<input type='hidden' id='__viewstate_lvw_" & id & "' value='" & getViewState() & "'>"
								else
									addhtml "<div class='lvw_pagebar' style=' "
									If len(Me.addlink & "") = 0 And showfullopen = False And PageBar = False And ( Me.edit= False or (Me.edit= true And (Me.edit.rowedit = False Or Me.edit.canadd = False) ) ) Then
										addhtml "display:none;"
									end if
									If IsAbsWidth Then addhtml "width:px;"
									addhtml "' id='lvw_pagebar_" & id & "'><div style='width:100%;height:2px;overflow:hidden'></div>"
									if len(Me.addlink & "") > 0 Or Me.showfullopen = True Or Me.edit then
										addhtml "<div class='left' style='width:10px;'>&nbsp;</div><div class='lvwbg00010' id='lvw_alink_" & id & "'>"
										If showfullopen Then
											addhtml "<form method=post style='display:inline' onsubmit='return __onlvwshowfull(this,""" & id & """)'  target='_blank'><input type='hidden' name='viewdata'><input type='hidden' name='headhtml'><input type='hidden' name='__msgid' value='sys_lvwshowfull'><input type='submit' value='全屏查看' class='button' style='width:70px;height:21px;line-height:18px;padding:0px'></form>"
'If showfullopen Then
										end if
										If Me.edit And Me.edit.canadd And Me.edit.rowedit Then
											If Me.edit.canadd then
												addhtml "<a onclick='app.lvweditor.insertRow(this,0)' href='javascript:void(0)' class='fun'><b>+</b> 添加新行</a>"
'If Me.edit.canadd then
											else
												If addlink = "添加" Then
												end if
											end if
										else
											If Len(addlink ) > 0 Then
												If instr(addlink,"html:") = 1 Then
													addhtml Right(addlink, Len(addlink)-5)
'If instr(addlink,"html:") = 1 Then
												else
													addhtml "<a onclick='lvw_onaddnew(""" & id & """)' href='javascript:void(0)' class='fun'>" & addlink & "</a>"
												end if
											end if
										end if
										addhtml "</div><div class='left' style='width:20px;'>&nbsp;</div>"
									end if
									If LCase(PageButtonAlign) = "right" Then
										addhtml "<div style='position:static;float:right;left:-10px' class='lvwbg0010'>"
'If LCase(PageButtonAlign) = "right" Then
									end if
									If PageBar =False Then
										addhtml "<div id='lvw_nopagebar_" & id & "' style='display:none'>"
									end if
									If oldPageSizeUI = False Then
										addhtml "<div class='lvwbg0006'>&nbsp;共<b id='jlCount_" & id & "'>" & mrecordcount & "</b>条记录&nbsp;&nbsp;</div>"
										if bof Or 1=Me.pageindex then
											addhtml "<div class='toolitem' id='lvw_firstpage_" & id & "' title='首页'  disabled><div><div class='toolitem_ico i0001'></div></div></div><div class='toolitem' id='lvw_prepage_" & id & "' title='上一页' disabled><div><div class='toolitem_ico i0002'></div></div></div>"
										else
											addhtml "<div class='toolitem' id='lvw_firstpage_" & id & "' title='首页' onclick='lvw_pageto(1,""" & id & """)' onmouseover='lvw_tm(this)' onmouseout='lvw_tu(this)'><div><div class='toolitem_ico i0003'></div></div></div><div class='toolitem' onclick='lvw_pageto("" & (pageindex-1)" & ",""" & id & ")' id='lvw_prepage_ & id & ' title='上一页' onmouseover='lvw_tm(this)' onmouseout='lvw_tu(this)'><div><div class='toolitem_ico i0004"
										end if
										addhtml "<div class='lvw_ywrow'>第&nbsp;</div><div class='lvw_ywrow'><input style='margin:1px;' onfocus='this.select()' onkeypress=""return __lvwpboxkey(this,'" & id & "')"" type=text class=lvwpitext maxlength=8  value='" & pageindex  & "' id='lvw_pindex_" & id & "' max='" & pagecount & "' title='输入正确的分页序号，按回车键执行分页' onpropertychange=formatData(this,'int')>"
										addhtml "</div><div class='lvw_ywrow'>&nbsp;/" & pagecount & "页</div>"
										if eof Or pagecount=Me.pageindex then
											addhtml "<div class='toolitem' id='nextpage_" & id & "' title='下一页' disabled><div><div class='toolitem_ico i0005'></div></div></div><div class='toolitem' id='lastpage' title='尾页'  disabled><div><div class='toolitem_ico i0006'></div></div></div>"
										else
											addhtml "<div class='toolitem' id='nextpage_" & id & "' title='下一页' onmouseover='lvw_tm(this)' onmouseout='lvw_tu(this)' onclick='lvw_pageto(" & (pageindex+1) & ",""" & id & """)'><div><div class='toolitem_ico i0007'></div></div></div><div class='toolitem' id='lastpage' title='尾页' onmouseover='lvw_tm(this)' onmouseout='lvw_tu(this)'   onclick='lvw_pageto(" & (pagecount) & ",""" & id & """)'><div><div class='toolitem_ico i0008'></div></div></div>"
										end if
									Else
										addhtml "<div class='lvwbg0006'>&nbsp;<span id='jlCount_" & id & "'>" & mrecordcount & "</span>个&nbsp;|&nbsp;" & pageindex & "/" & pagecount & "页&nbsp;|&nbsp;&nbsp;" & pagesize & "条信息/页&nbsp;</div>"
										addhtml "<div class='lvw_ywrow'>&nbsp;</div><div class='lvw_ywrow'><input style='margin:1px' onfocus='this.select()' onkeypress=""return __lvwpboxkey(this,'" & id & "')"" type=text size=3 maxlength=8  value='" & pageindex  & "' id='lvw_pindex_" & id & "' max='" & pagecount & "' title='输入正确的分页序号，按回车键执行分页' onpropertychange=formatData(this,'int')>"
										addhtml "</div><div class='lvw_ywrow'>&nbsp;<button onclick=""__lvwpboxkey($ID('lvw_pindex_" & id & "'),'" & id & "',1)"" class='oldbutton4'>跳转</button></div>"
										if bof Or 1=Me.pageindex then
											addhtml "<div class='lvw_ywrow'>&nbsp;<button class='oldbutton' id='lvw_firstpage_" & id & "' disabled2>首页</button></div><div class='lvw_ywrow'>&nbsp;<button class='oldbutton' id='lvw_prepage_" & id & "' disabled2>上一页</button></div>"
										else
											addhtml "<div class='lvw_ywrow'>&nbsp;<button class='oldbutton' id='lvw_firstpage_" & id & "' onclick='lvw_pageto(1,""" & id & """)'>首页</button></div><div class='lvw_ywrow'>&nbsp;<button class='oldbutton' onclick='lvw_pageto(" & (pageindex-1) & ",""" & id & """)' id='lvw_prepage_" & id & "' >上一页</button></div>"
										end if
										if eof Or pagecount=Me.pageindex Then
											addhtml "<div class='lvw_ywrow'>&nbsp;<button class='oldbutton' id='nextpage_" & id & "' disabled2>下一页</button></div><div class='lvw_ywrow'>&nbsp;<button class='oldbutton' id='lastpage_" & id & "' disabled2>尾页</button></div>"
										else
											addhtml "<div class='lvw_ywrow'>&nbsp;<button class='oldbutton' id='nextpage_" & id & "'  onclick='lvw_pageto(" & (pageindex+1) & ",""" & id & """)'>下一页</button></div><div class='lvw_ywrow'>&nbsp;<button class='oldbutton' id='lastpage_" & id & "' onclick='lvw_pageto(" & (pagecount) & ",""" & id & """)'>尾页</button></div>"
										end if
										addhtml "<div class='lvw_ywrow'>&nbsp;</div>"
									end if
									If PageBar =False Then
										addhtml "</div>"
									end if
									If LCase(PageButtonAlign) = "right" Then
										addhtml "</div>"
									end if
									If PageBar =True Then
										addhtml "<div class='lvwbg007'><table align='right'"
										If oldPageSizeUI Then
											addHtml " style='display:none'"
										end if
										addhtml "><tr><td width='60px' valign='top' align='right' class='lvwpagesizearea'>"
										addhtml "每页行数：</td><td width='55px' align='left' class='lvwpagesizearea'><select id='lvw_pgsize_sel" & id & "' style='width:50px;" & app.iif(CanPageSize,"","display:none") & "' class='lvw_pgsize' onchange='lvw_cpsize(this.value,""" & id & """)'>"
										dim pagesizes
										pagesizes = split("5,10,15,20,30,50,70,100,200,500",",")
										for i = 0 to ubound(pagesizes)
											if pagesizes(i) - pagesize = 0 then
'for i = 0 to ubound(pagesizes)
												addhtml "<option value=" & pagesizes(i)  & " selected>" & pagesizes(i)  & "</option>"
											else
												addhtml "<option value=" & pagesizes(i)  & ">" & pagesizes(i)  & "</option>"
											end if
										next
										addhtml "</select>"
										if CanPageSize = false then
											addhtml pagesize
										end if
										addhtml " 行</td><td style='display:none' id='lvw_sbar_" & id & "' valign='top'><button class='lvwscrollp' onclick='__lvwmvarea(""" & id & """,-1)' onmouseout='app.swpCss(this)' title='左滚动数据区域' onmouseover='app.swpCss(this)'></button><button class='lvwscrolln' onclick='__lvwmvarea(""" & id & """,1)' onmouseout='app.swpCss(this)' onmouseover='app.swpCss(this)' title='右滚动数据区域'></button>&nbsp;</td></tr></table></div>"
									end if
									addhtml "<div style='width:100%;height:2px;clear:both;overflow:hidden'></div>"
									addhtml "</div>"
									addhtml "<input type='hidden' id='__viewstate_lvw_" & id & "' value='" & getViewState() & "'>"
									addhtml "<input type='hidden' id='__sortstate_lvw_" & id & "' value='" & Me.sortsql & "'>"
									addhtml "<div id='lvw_excelfrm_form" & id & "' style='position:absolute;left:-1000px'>&nbsp;</div>"
'addhtml "<input type='hidden' id='__sortstate_lvw_" & id & "' value='" & Me.sortsql & "'>"
								end if
							else
								showExcelProc 100, 99
							end if
							if isBack = false then
								addhtml "</div>"
								If Me.fixedhead Then
									Me.addhtml "<div style='position:absolute;top:0px;height:2px;z-index:1000;overflow:hidden;width:100%;border-left:2px solid #ccc'>&nbsp;</div>"
'If Me.fixedhead Then
								end if
								addhtml "</div>"
							end if
							if me.excelmode Then
								If needWriteFile = True Or exportSheetCnt >= sheetPerFile Then
									call addexcelfooter
								end if
								showExcelProc 100, 100
								app.Log.remark =exportFileName & "导出"
								app.Log.href=""
							else
								html = join(htmlarray,"")
							end if
						end function
		Public Function JsonCode
			clearHtml
			Call GetEditJSONCode
			JsonCode = join(htmlarray,"")
		end function
		Public Function createsource()
			Dim source : Set source = server.createobject("ZSMLLibrary.sourceClass")
			Dim tb : Set tb = source.createType("table")
			tb.layout = Me.layout
			Dim v
			If Me.pagesize=0 Then Me.pagesize = 1000
			Dim rs : Set rs = Me.record
			If me.recordcount > 0 Then
				tb.page.pageindex = me.pageindex
				tb.page.pagecount = me.recordcount\me.pagesize  + abs(me.recordcount mod me.pagesize  > 0)
'tb.page.pageindex = me.pageindex
				tb.page.pagesize = me.pagesize
				tb.page.recordcount = me.recordcount
				Dim vcols, c , iii
				c = 0
				ReDim vcols(0)
				For iii = 1 To me.headers.count
					If me.headers(iii).visible = True And InStr(me.headers(iii).dbname, "@")=0 And len(me.headers(iii).dbname)>0 Then
						c = c + 1
						ReDim Preserve vcols(c)
						vcols(c) = me.headers(iii).dbname
					end if
				next
				For iii = 1 To ubound(vcols)
					Dim f : Set f = rs.fields(vcols(iii))
					tb.addcol f.name, me.getTypeById(f.type)
				next
				Dim pc
				If me.pageMode = false Then
					For iii = 1 To (tb.page.pageindex-1)*tb.page.pagesize
'If me.pageMode = false Then
						rs.movenext
					next
					pc = me.pagesize
				else
					pc = me.recordcount + 10
					pc = me.pagesize
				end if
				Dim tv_1 , tv_2, tv_num
				While rs.eof = False And pc > 0
					Dim row : Set row = server.createobject("ZSMLLibrary.ASPCollection")
					tb.addRow row
					For iii = 1 To ubound(vcols)
						v = rs.fields(vcols(iii)).value & ""
						If Len(me.headers(iii).formattext &"")>0 Then
							v = me.headers(iii).formattext
							Call ReplaceEvalValue(v , rs.fields(vcols(iii)).value , 1, pc)
						end if
						If me.headers(iii).dbtype="money" Then
							If isnumeric(v) = False Then v = "0"
							row.add FormatNumber( v ,  Info.moneyNumber ,-1,0,-1)
'If isnumeric(v) = False Then v = "0"
						ElseIf me.headers(iii).dbtype="commprice" Then
'If isnumeric(v) = False Then v = "0"
							row.add FormatNumber( v ,  Info.CommPriceDotNum ,-1,0,-1)
'If isnumeric(v) = False Then v = "0"
						ElseIf me.headers(iii).dbtype="salesprice" Then
'If isnumeric(v) = False Then v = "0"
							row.add FormatNumber( v ,  Info.SalesPriceDotNum ,-1,0,-1)
'If isnumeric(v) = False Then v = "0"
						ElseIf me.headers(iii).dbtype="storeprice" Then
'If isnumeric(v) = False Then v = "0"
							row.add FormatNumber( v ,  Info.StorePriceDotNum ,-1,0,-1)
'If isnumeric(v) = False Then v = "0"
						ElseIf me.headers(iii).dbtype="financeprice" Then
'If isnumeric(v) = False Then v = "0"
							row.add FormatNumber( v ,  Info.FinancePriceDotNum ,-1,0,-1)
'If isnumeric(v) = False Then v = "0"
						ElseIf me.headers(iii).dbtype="number" Then
'If isnumeric(v) = False Then v = "0"
							row.add FormatNumber(v,  Info.FloatNumber ,-1,0,-1)
'If isnumeric(v) = False Then v = "0"
						ElseIf me.headers(iii).dbtype="zk" Then
'If isnumeric(v) = False Then v = "0"
							row.add FormatNumber(v,  Info.DiscountNumber ,-1,0,-1)
'If isnumeric(v) = False Then v = "0"
						else
							If isobject(v) Then
								row.add app.getjson(v)
							else
								If Len(me.headers(iii).formattext &"")=0 Then v = app.htmltotext(v &"")
								row.add v
							end if
						end if
					next
					Set row = Nothing
					If app.existsProc("bill_onMoreList") Then Call bill_onMoreList(tb ,rs)
					pc = pc - 1
'If app.existsProc("bill_onMoreList") Then Call bill_onMoreList(tb ,rs)
					rs.movenext
				wend
			end if
			Set tb = Nothing
			Set createsource = source
		end function
		Public Function EvalExpress(ByVal lvw, ByVal ename, ByVal EvalCode, ByVal rs, ByVal deep)
			Dim i, dbname
			If deep > 15 Then EvalExpress = 0 : Exit Function
			For i = 1 To lvw.headers.count
				If lvw.headers(i).evalname = ename And ename <> "" Then
					dbname = lvw.headers(i).dbname
					If EvalCode = "" Then  EvalCode =  lvw.headers(i).EvalCode
					Exit for
				end if
			next
			If dbname<>"" Then
				on error resume next
				evalCode = Replace(evalCode , ename , rs(dbname).value )
				On Error GoTo 0
			end if
			If ename = evalCode Or evalCode = "" Then
				on error resume next
				EvalExpress = 0
				EvalExpress = rs(dbname).value
				On Error GoTo 0
			else
				For i = Asc("A") to Asc("Z")
					If InStr(evalcode, Chr(i)) > 0  Then
						evalcode = Replace(evalcode, Chr(i), EvalExpress(lvw, Chr(i), "", rs, deep+1))
'If InStr(evalcode, Chr(i)) > 0  Then
					end if
				next
				on error resume next
				EvalExpress = 0
				EvalExpress = eval(evalcode)
				On Error GoTo 0
			end if
		end function
		Private Sub applyFormulaConfig
			Dim sql, rs, h
			sql = "select b.dbname, b.evalname, b.formula  from erp_sys_LvwConfig a inner join erp_sys_LvwcolConfig b on a.uid=0 and a.lvwid='" & md5key16 & "' and a.id=b.cfgid"
			Set rs = cn.execute(sql)
			While rs.eof = False
				Set h = headers( rs("dbname") )
				If h.display <> "none" And h.evalname <> "" Then
					If  rs("formula").value & "" <> "" Then h.evalcode = rs("formula").value
					If  rs("evalname").value & "" <> "" Then h.evalname = rs("evalname").value
				end if
				rs.movenext
			wend
			rs.close
			set rs = nothing
		end sub
		Private Sub PageReckon
			Dim n
			For n = 1 To headers.count
				If headers(n).evalcode<>"" Then
					headers(n).formula = "EvalExpress(me, """ & headers(n).evalName & """,  """ & headers(n).evalcode & """, rs, 0)"
				end if
			next
		end sub
		Private Sub createCellHtml(ByRef cell, Byref currvalue, ByRef  fcount, ByRef  celldS, Byval  isReatCol, Byref  ccount, ByVal startpos, ByRef isRepeatRow, ByRef currsumarrayv, ByRef allsumarrayv, ByVal calltype, ByVal rowindex)
			Dim f, c, v, i, ii, n, fh, fv, cvalue , extAttr
			Set c = cell
			If curr_rowindex > 0 Then
				rowindex = curr_rowindex
			end if
			If len(c.Formula) > 0 Then
				If currvalue = "@isRepeat!" Then
					currvalue = ""
				else
					Dim ls1
					ls1 = Replace(Replace(Replace(Replace(sdk.base64.Utf8CharHtmlConvert(currvalue) & "", """", """"""),vbcrlf, """ & vbcrlf & """), vbcr, """ & vbcr & """), vblf, """ & vblf & """)
					f = Replace(Replace(c.Formula, "@value", """" & sdk.base64.Utf8CharHtmlConvert(ls1) & """", 1, -1, 1) , "@ReatCol" , Abs(isReatCol(0)), 1, -1, 1)
					f = Replace(Replace(f, "@row", """" & i & """", 1, -1, 1) , "@me" , "me", 1, -1, 1)
					If InStr(1, f, "@encells[", 1) > 0  Then
						For n = 1 To ccount
							Set fh = headers(n)
							If fh.dbindex > -1 then
'Set fh = headers(n)
								fv = app.base64.pwurl(fs(fh.dbindex).value)
								f = Replace(f, "@encells[" & n & "]" , """" & fv & """", 1, -1, 1)
'fv = app.base64.pwurl(fs(fh.dbindex).value)
								f = Replace(f, "@encells[""" & fh.dbname & """]" , """" & fv & """", 1, -1, 1)
'fv = app.base64.pwurl(fs(fh.dbindex).value)
							end if
						next
					end if
					If InStr(1, f, "@cells[", 1) > 0  Then
						For n = 1 To ccount
							Set fh = headers(n)
							If fh.dbindex > -1 Then
								Set fh = headers(n)
								fv = fs(headers(n).dbindex).value
								f = Replace(f, "@cells[" & n & "]" , """" & Replace(Replace(Replace(fv&"","""",""""""),vbcr,""" & vbcr & """),vblf,""" & vblf & """) & """", 1, -1, 1)
'fv = fs(headers(n).dbindex).value
								f = Replace(f, "@cells[""" & fh.dbname & """]" , """" & Replace(Replace(Replace(fv&"","""",""""""),vbcr,""" & vbcr & """),vblf,""" & vblf & """) & """", 1, -1, 1)
'fv = fs(headers(n).dbindex).value
							end if
						next
					end if
					currvalue = eval(f)
				end if
			end if
			Dim moneybzv
			Select Case c.dbtype
			Case "number" :
			If isnumeric(currvalue & "") = true then
				currvalue = FormatNumber(currvalue, Info.FloatNumber,-1, 0,-1)
'If isnumeric(currvalue & "") = true then
			else
				if currvalue & "" = "" then
					currvalue = ""
				else
					If celldS = False Then
						If c.ignoreNonnumeric = True Then
							currvalue = ""
						else
							app.showerr "列表数据输出问题","列“" & c.title & "”中存在非数字值【" & currvalue &"】。"
						end if
					end if
				end if
			end if
			If Len(c.align2) > 0 Then c.align = c.align2
			Case "money","commprice","salesprice","storeprice","financeprice" :
			If isnumeric(currvalue & "") = true Then
				dim cformatbit : cformatbit = 2
				Select Case c.dbtype
				Case "money" : cformatbit = Info.moneynumber
				case "commprice" :  cformatbit = Info.CommPriceDotNum
				case "salesprice" : cformatbit = Info.SalesPriceDotNum
				case "storeprice" : cformatbit = Info.StorePriceDotNum
				case "financeprice":cformatbit = Info.FinancePriceDotNum
				end select
				if Me.jsonEditModel then
					currvalue =  FormatNumber(currvalue, cformatbit,-1 ,0 ,0)
'if Me.jsonEditModel then
				else
					currvalue =  FormatNumber(currvalue, cformatbit,-1 ,0 ,-1)
'if Me.jsonEditModel then
				end if
				c.align = "right"
				If c.bz<>"" Then
					moneybzv = currvalue
					If rs.eof=False Then
						If calltype <> 2 Then currvalue =rs(c.bz).value & " " & currvalue
					end if
				end if
			else
				If isNull(currvalue) = True Or c.ignoreNonnumeric = True Then
					currvalue = ""
				else
					If celldS = False then
						app.showerr "列表数据输出问题","列“" & c.title & "”中存在非金额值【" & currvalue &"】。"
					end if
				end if
			end if
			If Len(c.align2) > 0 Then c.align = c.align2
			Case "hl" :
			If isnumeric(currvalue & "") = true Then
				currvalue =  Replace(FormatNumber(currvalue, Info.hlnumber,-1),",","") : c.align = "right"
'If isnumeric(currvalue & "") = true Then
			else
				If isNull(currvalue) = True Or c.ignoreNonnumeric = True Then
					currvalue = ""
				else
					If celldS = False then
						app.showerr "列表数据输出问题","列“" & c.title & "”中存在非数值【" & currvalue &"】。"
					end if
				end if
			end if
			If Len(c.align2) > 0 Then c.align = c.align2
			Case "str" :
			c.align = ""
			If Len(c.align2) > 0 Then c.align = c.align2
			Case "zk" :
			If isnumeric(currvalue & "") = true Then
				currvalue =  Replace(FormatNumber(currvalue, Info.DiscountNumber,-1),",","") : c.align = "center"
'If isnumeric(currvalue & "") = true Then
			else
				If isNull(currvalue) = True Or c.ignoreNonnumeric = True Then
					currvalue = ""
				else
					If celldS = False then
						app.showerr "列表数据输出问题","列“" & c.title & "”中存在非数值【" & currvalue &"】。"
					end if
				end if
			end if
			If Len(c.align2) > 0 Then c.align = c.align2
			End select
			f=c.evalcode
			If f <> c.evalname And isPageReckon=True Then
				Dim topRows : topRows = 2
				For n=1 To ccount
					f = replace(f, headers(n).evalName,"{"&n&"}" )
				next
				If Len(me.FaStr)>0 Then
					anotherStr=Split(me.FaStr,":")
					For n=0 To ubound(anotherStr)
						anothers=Split(anotherStr(n),"=")
						f=replace(f,anothers(0),anothers(1))
					next
				end if
				For n=1 To ccount
					f = replace(f,"{"&n&"}",chr(64 + n) & (rowindex+topRows))
'For n=1 To ccount
				next
				f="x:fmla='IF(ISNUMBER("& f &"),"& f &",0)'"
			end if
			If (isnumeric(allsumarrayv) = True Or isnumeric(currsumarrayv) = True) And fcount > c.dbindex Then
				v = currvalue & ""
				If c.bz <> "" And  c.dbtype = "money" Then
					v = moneybzv
				end if
				If i =  startpos Then
					If Len(c.dbtype) = 0 Then
						If InStr(v,".") = 0 then
							c.formatbit = 0
						else
							c.formatbit = Len(Split(v,".")(1))
						end if
					end if
				end if
				Dim cIsRepeatRow
				cIsRepeatRow = app.iif(Len(c.formulaIsRowRepeat&"")>0,eval(c.formulaIsRowRepeat),isRepeatRow)
				If isnumeric(v) = True and c.canSum = True Then
					If c.tryCurrSumWhenRepeat = True Or cIsRepeatRow = False Then
						If Len(v) = 0 Then v = 0
						If isnumeric(v) = True Then
							If isnumeric(allsumarrayv) = True Then allsumarrayv = allsumarrayv*1 + v*1
'If isnumeric(v) = True Then
							If isnumeric(currsumarrayv) = true Then currsumarrayv = currsumarrayv*1 + v*1
'If isnumeric(v) = True Then
						end if
					end if
				else
					If (c.tryCurrSumWhenRepeat = True Or cIsRepeatRow = False) And c.ignoreNonnumeric = False Then
						allsumarrayv = "t"
						currsumarrayv = "t"
					end if
				end if
			end if
			Dim itemstyle
			itemstyle = ""
			if len(c.execdisplay) > 0 then itemstyle = itemstyle & "display:" & c.execdisplay & ";"
			if c.splitCell then itemstyle = itemstyle & ";border-right:2px solid " & splitColor
'if len(c.execdisplay) > 0 then itemstyle = itemstyle & "display:" & c.execdisplay & ";"
			if len(itemstyle) > 0 then itemstyle = "style=""" & itemstyle & """"
			If Len(c.LinkFormat) > 0 And rowindex>0 Then
				If currvalue = "@isRepeat!" Then
					currvalue = ""
				else
					currvalue = c.CLinkHtml(rs, excelmode, currvalue)
				end if
			end if
			If Me.jsonEditModel Then
				If c.dbtype = "number" Or c.dbtype = "money" Then
					If currvalue & "" = "" Then
						addhtml "null"
					else
						addhtml Replace(currvalue & "",",","")
					end if
				else
					If c.uitype = "tree" Then
						addhtml currvalue
					else
						addhtml """" & app.ConvertJsText(currvalue & "") & """"
					end if
				end if
				Exit sub
			end if
			if me.excelmode Then
				If c.execdisplay <> "none" then
					Dim excelAlign:excelAlign=""
					If c.excelAlign<>"" Then
						excelAlign="A" & LCase(Left(c.excelAlign,1)) & ""
					end if
					addhtml "<td class='" & c.dbtype & excelAlign & "' " & Replace(Replace(f,">","&gt;"),"<","&lt;") & ">"
					if c.selfitem then
						select case c.title
						case "序号" : addhtml rowindex
						case "选择" :
						case Else   : addhtml c.defhtml
						end select
					else
						if c.dbindex >= 0 And fcount > c.dbindex Then
							If c.ignoreHTMLTag = True And c.dbType = "str" Then
								If InStr(currvalue,"<") > 0 Then
									addhtml ColorFormat(Replace(RegReplace(currvalue&"","<[^>]+>",""),"=","&#61;"))
'If InStr(currvalue,"<") > 0 Then
								else
									addhtml ColorFormat(Replace(currvalue&"","=","&#61;")) & ""
								end if
							else
								addhtml ColorFormat(Replace(currvalue&"","=","&#61;")) & ""
							end if
						else
							addhtml ColorFormat(Replace(currvalue&"","=","&#61;")) & ""
						end if
					end if
					addhtml "</td>"
				end if
			else
				If c.execdisplay <> "none" then
					if len(c.align2) = 0 then
						addhtml "<td class='" & RTrim(c.cssName & " " & c.dbtype) & "' " & itemstyle & "  " &  Replace(Replace(f,">","&gt;"),"<","&lt;") & ">"
					else
						addhtml "<td class='" & RTrim(c.cssName & " " & c.dbtype) & " lcm_" & c.align2 & "' " & itemstyle & "  " &  Replace(Replace(f,">","&gt;"),"<","&lt;") & ">"
					end if
					if c.selfitem Then
						cvalue=""
						If Len(checkvalue)>0 Then
							If isInsertModel Then
								cvalue=fs(checkvalueindex).value
							else
								cvalue=rs(checkvalue).value
							end if
						end if
						select case c.title
						case "序号"
						if checkbox Then
							addhtml "<table align='center'><tr><td><input id='" & id & "_ckv_" & cvalue & "' class='lvcbox' name='sys_lvw_ckbox' type=checkbox value='"& cvalue &"'></td><td>" & rowindex & "</td></tr></table>"
						else
							addhtml rowindex
						end if
						case "选择"
						Dim ckhtml
						ckhtml =  "<input type=checkbox class='lvcbox' id='" & id & "_ckv_" & cvalue & "' name='sys_lvw_ckbox' value='" & cvalue & "'>"
						If app.existsProc("lvw_onCreateCheckBox") Then
							Call lvw_onCreateCheckBox(me, rs, ckhtml)
						end if
						Call addhtml( ckhtml )
						case Else
						If c.dbname = "@editcol" Then
							Dim c_defhtml
							c_defhtml = c.defhtml
							If Me.edit.candelexpress <> "" Then
								If eval(Me.edit.candelexpress) Then
									c_defhtml =  Replace(c_defhtml, "<!--@删除按钮-->","")
'If eval(Me.edit.candelexpress) Then
								else
									c_defhtml =  Replace(c_defhtml, "<!--@删除按钮-->", "<button type='button' class='zb-btn fs' onclick='app.lvweditor.deleteRow(this)' title='删除'>删</button>")
'If eval(Me.edit.candelexpress) Then
								end if
							end if
							If Me.edit.canistexpress <> "" Then
								If eval(Me.edit.canistexpress) Then
									c_defhtml =  Replace(c_defhtml, "<!--@插入按钮-->","")
'If eval(Me.edit.canistexpress) Then
								else
									c_defhtml =  Replace(c_defhtml, "<!--@插入按钮-->", "<button type='button' class='zb-btn fs' onclick='app.lvweditor.insertRow(this,1)' title='插入增加'>增</button>")
'If eval(Me.edit.canistexpress) Then
								end if
							end if
							addhtml c_defhtml
						else
							addhtml c.defhtml
						end if
						end select
					else
						if c.dbindex >= 0 And fcount > c.dbindex Then
							if len(c.formatText) > 0 And currvalue & ""<>"分类合计" And celldS=False Then
								v = c.formattext & ""
								v = Replace(v, "@ReatCol" , Abs(isReatCol(0)), 1, -1, 1)
'v = c.formattext & ""
								Call ReplaceEvalValue(v, currvalue, calltype, rowindex)
								If jsonEditModel Then
									addhtml "<div class='lvw_algn_" & c.align & "'>"
								else
									addhtml "<table " & iif( len(c.align) > 0,"align='" & c.align & "'", "") & "><tr><td"& iif( len(c.align) > 0," style='text-align:" & c.align & "'", "") &">"
									addhtml "<div class='lvw_algn_" & c.align & "'>"
								end if
								addhtml ColorFormat(v)
							else
								If Me.edit And Len(c.uitype) > 0 Then
									cvalue=""
									If Len(checkvalue)>0 Then
										If isInsertModel Then
											cvalue=fs(checkvalueindex).value
										else
											cvalue=rs(checkvalue).value
										end if
									end if
									extAttr = ""
									If Len(extAttribute)>0 Then
										If isInsertModel Then
											extAttr=fs(extAttribute).value
										else
											extAttr=rs(extAttribute).value
										end if
									end if
									If canRowEdit(rs, rowindex) And canCellEdit(c.EditLock, rs ,c, rowindex) Then
										If jsonEditModel Then
											addhtml "<div class='lvw_algn_" & c.align & "' " & c.editAttrs  & ">"
										else
											addhtml "<table " & iif( len(c.align) > 0,"align='" & c.align & "'", "") & "><tr><td " & c.editAttrs  & ">"
										end if
										addhtml c.doEditHtml(currvalue,cvalue , extAttr)
									else
										If jsonEditModel Then
											addhtml "<div class='lvw_algn_" & c.align & "' " & c.editAttrs  & ">"
										else
											addhtml "<table " & iif( len(c.align) > 0,"align='" & c.align & "'", "") & "><tr><td >"
										end if
										addhtml ColorFormat(c.doReadHtml(currvalue))
										addhtml "<span style='display:none'>" &  c.doEditHtml(currvalue,cvalue , extAttr) & "</span>"
									end if
								else
									If jsonEditModel Then
										addhtml "<div class='lvw_algn_" & c.align & "'>"
									else
										addhtml "<table " & iif( len(c.align) > 0,"align='" & c.align & "'", "") & "><tr><td>"
									end if
									dim vcss : vcss = ""
									if len(c.ContentStyle)>0 then
										vcss = c.ContentStyle
										Call ReplaceEvalValue(vcss, c.defhtml, calltype, rowindex)
										addhtml "<span style='"& vcss &"'>"&ColorFormat(c.doReadHtml(currvalue)) & "</span>"
									else
										addhtml ColorFormat(c.doReadHtml(currvalue)) & ""
									end if
								end if
							end if
							Dim extraHtml : extraHtml = ""
							If c.unit <> "" Then
								If InStr(c.unit, "@") > 0 Then
									Dim un_v, un_i : un_v = c.unit
									For un_i = 0 To rs.fields.count - 1
'Dim un_v, un_i : un_v = c.unit
										un_v = Replace(un_v, "@" &  rs.fields(un_i).name,  rs.fields(un_i).value & "",1,-1,1)
'Dim un_v, un_i : un_v = c.unit
									next
								else
									un_v = c.unit
								end if
								If InStr(un_v, "code:") Then
									un_v = right(un_v, Len(un_v)-5)
'If InStr(un_v, "code:") Then
									un_v = eval(un_v)
								end if
								extraHtml=un_v
							end if
							if c.selid > 0 then extraHtml = extraHtml & "<button class='button'>v</button>"
							if Me.edit And Len(Me.editkey) > 0 And rowindex <> prer_owindex Then
								prer_owindex = rowindex
								Dim editid : editid = rs(Me.editkey).value
								If editid & "" = "" Then  editid = "0"
								If jsonEditModel then
									extraHtml = extraHtml & "<input type='hidden' name='" & Me.editkey & "' value='" & editid & "'>"
								else
									extraHtml = extraHtml & "</td><td style='width:1px'><input type='hidden' name='" & Me.editkey & "' value='" & editid & "'>"
								end if
							end if
							If jsonEditModel Then
								addhtml extraHtml & "</div>"
							else
								addhtml "</td>"
								If Len(extraHtml)>0 Then addhtml "<td style='text-align: left;'>"& extraHtml &"</td>"
								addhtml "</td>"
								addhtml "</tr></table>"
							end if
						else
							If Len(c.formattext)>0 Then
								v = c.formattext & ""
								v = Replace(v , "@ReatCol" , Abs(isReatCol(0)), 1, -1, 1)
								v = c.formattext & ""
								Call ReplaceEvalValue(v, c.defhtml, calltype, rowindex)
								addhtml v
							else
								addhtml currvalue
							end if
						end if
					end if
					addhtml "</td>"
				end if
			end if
		end sub
		Private m_rowindex, m_CanRowEdit_v
		Private Function CanRowEdit(ByVal rs, ByVal rowindex)
			If rowindex = m_rowindex Then
				CanRowEdit = m_CanRowEdit_v
			else
				m_rowindex = rowindex
				If RowEditlock = "" Then
					m_CanRowEdit_v = True
				ElseIf isnumeric(RowEditlock) Then
					m_CanRowEdit_v = CLng(RowEditlock) > 0
				else
					If InStr(1, RowEditlock, "code:", 1) = 0 Then
						m_CanRowEdit_v = Abs(rs(RowEditlock).value) > 0
					else
						m_CanRowEdit_v = Abs(eval(Replace(RowEditlock, "code:", ""))) > 0
					end if
				end if
				CanRowEdit = m_CanRowEdit_v
			end if
		end function
		Private Function canCellEdit(ByVal lockkey, ByVal rs ,ByVal col, ByVal rowindex)
			If lockkey = "" Then
				CanCellEdit = True
			ElseIf isnumeric(lockkey) Then
				canCellEdit = CLng(lockkey) > 0
			else
				If InStr(1, lockkey, "code:", 1) = 0 Then
					CanCellEdit = Abs(rs(lockkey).value) > 0
				else
					CanCellEdit = Abs(eval(Replace(lockkey, "code:", ""))) > 0
				end if
			end if
		end function
		Public Sub showFormulConfigPage
			Dim i, ii, rs, h, sql, i0, i1, i2, res, configid
			Call clearHtml
			configid = 0
			Set rs = cn.execute("select top 1 id from [erp_sys_LvwConfig] where lvwid='" & Md5Key16 & "' and uid=0")
			If rs.eof = False Then
				configid = rs(0).value
			end if
			rs.close
			res = app.virpath & "/skin/" & Info.skin & "/"
			addhtml "<div style='display:block;overflow:auto;border:0px;margin-right:"
'res = app.virpath & "/skin/" & Info.skin & "/"
			i0 = addhtml("18")
			addhtml "px;height:41px;z-index:20px;overflow:hidden;position:relative;border-top:1px solid #ccc'>"
'i0 = addhtml("18")
			addhtml "<table class='lvwframe2' style='position:static;text-align:center;background-color:white;left:0px;height:26px'>"
'i0 = addhtml("18")
			addhtml "<col style='width:186px;*width:192px;background:'><col style='width:158px;*width:162px;background:'><col style='width:"
			i1 = addhtml("298")
			addhtml "px;background:'>"
			addhtml "<tr>"
			addhtml "<th class='lvwheader' style='border-top:0px'>列名称</th>"
			addhtml "<tr>"
			addhtml "<th class='lvwheader' style='border-top:0px'>公式别名</th>"
			addhtml "<tr>"
			addhtml "<th class='lvwheader' style='border-top:0px'>公式表达式</th>"
			addhtml "<tr>"
			addhtml "</tr>"
			addhtml "</table>"
			addhtml "</div>"
			addhtml "<div style='display:block;height:344px;overflow:auto;overflow-x:hidden;border-top:0px;border:1px solid #ccc;margin-top:-42px;padding-top:40px'>"
			addhtml "</div>"
			addhtml "<table  id='lvw_ac_ptb_" & id & "' class='lvwframe2' style='position:static;text-align:center;background:'>"
			addhtml "</div>"
			addhtml "<col style='width:190px;background:'><col style='width:160px;background:'><col style='width:"
			i2 = addhtml("298")
			addhtml "px;background:'>"
			ii = 0
			if (checkbox or indexbox) Then set h = headers.insert("选择","",1)
			sql = "set nocount on;create table #tmp_rpt_c3 (dbname nvarchar(300), ci int, fv varchar(50), evalname varchar(30));"
			For i = 1 To headers.count
				Set h = headers(i)
				If h.display <> "none" Then
					ii = ii + 1
'If h.display <> "none" Then
					sql = sql & "insert into #tmp_rpt_c3( dbname, ci, fv, evalname) values ('" & Replace(h.dbname,"'","''") & "'," & ii & ",'" & Replace(h.evalcode ,"''","'") & "','" & Replace(h.evalname,"'","''") & "');"
				end if
			next
			i = 0
			sql = sql & "select isnull(b.evalname,a.evalname) as evalname, isnull(b.formula, a.fv) as formula, a.dbname as dbn, a.ci from #tmp_rpt_c3 a left join [erp_sys_LvwcolConfig] b on a.dbname = b.dbname and b.cfgid=" & configid & " order by a.ci;set nocount off"
			cn.execute "update erp_sys_LvwcolConfig set evalname = null where cfgid=" & configid & " and len(evalname)=0"
			cn.execute "update erp_sys_LvwcolConfig set formula = null where cfgid=" & configid & " and len(formula)=0"
			Set rs = cn.execute(sql)
			While rs.eof = False
				Set h = headers(rs("dbn").value)
				If Len(rs("evalname").value & "") > 0 Then
					i = i + 1
'If Len(rs("evalname").value & "") > 0 Then
					addhtml "<tr>"
					addhtml "<td class='lvw_cell' style='border-left:0px'>" & h.title & "<input id='s_rcf_dn_" & i & "' type='hidden' value=""" & Replace(iif(rs("dbn").value & ""= "","[!null]",rs("dbn").value),"""","&#34;") & """></td>"
					addhtml "<tr>"
					addhtml "<td class='lvw_cell'><input dataType='Limit' min='1' max='10' msg='必填' size=10 maxlength=10 id='s_rcf_fvn_" & i & "' type='textbox' value='" & rs("evalname").value & "'></td>"
					addhtml "<td class='lvw_cell'><input dataType='Limit' min='1' max='50' msg='必填' size=20 maxlength=50 id='s_rcf_fml_" & i & "' type='textbox' value='" & rs("formula").value & "'></td>"
					addhtml "</tr>"
				end if
				rs.movenext
			wend
			addhtml "</table>"
			addhtml "</div>"
			If i < 13 Then
				htmlarray(i0) = "0"
				htmlarray(i1) = "316"
				htmlarray(i2) = "316"
			end if
			Response.write Join(htmlarray,"")
			Erase htmlarray
		end sub
		Public Sub showConfigPage
			Dim i, ii, rs, h, sql, i0, i1, i2, res, configid
			Call clearHtml
			configid = 0
			Set rs = cn.execute("select top 1 id from [erp_sys_LvwConfig] where lvwid='" & Md5Key16 & "' and uid=" & Info.user)
			If rs.eof = False Then
				configid = rs(0).value
			end if
			rs.close
			res = app.virpath & "/skin/" & Info.skin & "/"
			addhtml "<div style='display:block;overflow:auto;border:0px;margin-right:"
'res = app.virpath & "/skin/" & Info.skin & "/"
			i0 = addhtml("18")
			addhtml "px;height:41px;z-index:20px;overflow:hidden;position:relative;border-top:1px solid #ccc'>"
'i0 = addhtml("18")
			addhtml "<table class='lvwframe2' style='position:static;text-align:center;background-color:white;left:0px;height:26px;'>"
'i0 = addhtml("18")
			addhtml "<col style='width:149px;*width:153px;background:'><col style='width:102px;*width:107px;background:'>"
			addhtml "<col style='width:102px;*width:107px;background:'><col style='width:102px;*width:107px;background:'><col style='width:176px;*width:"
			i1 = addhtml("178")
			addhtml "px;background:'>"
			addhtml "<tr>"
			addhtml "<th class='lvwheader' style='border-top:0px'>列名称</th>"
			addhtml "<tr>"
			addhtml "<th class='lvwheader' style='border-top:0px' id='lvw_ac_v_" & id & "'>是否显示<input onclick='__lvwconfigvckAll(this)' type='checkbox'></th>"
			addhtml "<tr>"
			addhtml "<th class='lvwheader' style='border-top:0px'>显示顺序</th>"
			addhtml "<tr>"
			addhtml "<th class='lvwheader' style='border-top:0px'>列宽</th>"
			addhtml "<tr>"
			addhtml "<th class='lvwheader' style='border-top:0px'>列别名</th>"
			addhtml "<tr>"
			addhtml "</tr>"
			addhtml "</table>"
			addhtml "</div>"
			addhtml "<div style='display:block;height:344px;overflow:auto;overflow-x:hidden;border:1px solid #ccc;margin-top:-42px;padding-top:40px'>"
			addhtml "</div>"
			addhtml "<table  id='lvw_ac_ptb_" & id & "' class='lvwframe2' style='position:static;text-align:center;background:'>"
			addhtml "</div>"
			addhtml "<col style='width:148px;*width:151px;background:'><col style='width:102px;*width:105px;background:'>"
			addhtml "<col style='width:102px;*width:105px;background:'><col style='width:102px;*width:105px;background:'><col style='width:"
			i2 = addhtml("176")
			addhtml "px;background:'>"
			ii = 0
			if (checkbox or indexbox) Then set h = headers.insert("选择","",1)
			sql = "set nocount on;create table #tmp_rpt_c (dbname nvarchar(300), ci int, dbi int);"
			For i = 1 To headers.count
				Set h = headers(i)
				If h.display <> "none" Then
					ii = ii + 1
'If h.display <> "none" Then
					sql = sql & "insert into #tmp_rpt_c( dbname, ci, dbi) values ('" & Replace(h.dbname,"'","''") & "'," & ii & "," &  i & ");"
				end if
			next
			i = 0
			sql = sql & "select isnull(b.visible,1) as visible, isnull(b.sort, a.ci) as sort, b.width, b.title, a.dbname as dbn, a.ci, a.dbi from #tmp_rpt_c a left join [erp_sys_LvwcolConfig] b on a.dbname = b.dbname and b.cfgid=" & configid & ";set nocount off"
			Set rs = cn.execute(sql)
			While rs.eof = False
				i = i + 1
'While rs.eof = False
				Set h = headers(rs("dbn").value)
				addhtml "<tr>"
				addhtml "<td class='lvw_cell' style='border-left:0px'>" & h.title & "<input id='rcf_dn_" & i & "' type='hidden' value=""" & Replace(iif(rs("dbn").value & ""= "","[!null]",rs("dbn").value),"""","&#34;") & """></td>"
				addhtml "<tr>"
				addhtml "<td class='lvw_cell'>" & iif(h.canhide, "<input id='rcf_vs_" & i & "' type='checkbox' " & iif(rs("visible").value,"checked","") & ">","") & "</td>"
				addhtml "<td class='lvw_cell'><select id='rcf_ci_" & i & "'>" & getselecthtml(rs("sort").value,ii) & "</select><input  id='rcf_defci_" & i & "' type='hidden' value='" & rs("ci").value & "'><input  id='rcf_dbi_" & i & "' type='hidden' value='" & rs("dbi").value & "'></td>"
				addhtml "<td class='lvw_cell'>" & rs("width").value & "<input readonly id='rcf_wd_" & i & "' onpropertychange=formatData(this,'int') maxlength=6  type='hidden' size=6 value='" & rs("width").value & "'></td>"
				addhtml "<td class='lvw_cell'><input id='rcf_tit_" & i & "' maxlength=50 type='textbox' value='" & app.htmlconvert(rs("title").value & "") & "'></td>"
				addhtml "</tr>"
				rs.movenext
			wend
			addhtml "</table>"
			addhtml "</div>"
			If ii < 13 Then
				htmlarray(i0) = "0"
				htmlarray(i1) = "194"
				htmlarray(i2) = "194"
			end if
			Response.write Join(htmlarray,"")
			Erase htmlarray
		end sub
		Public Function ClearConfigPage
			Dim rs1, configid
			configid = 0
			Set rs1 = cn.execute("select id from erp_sys_LvwConfig where lvwid='" & Md5Key16 & "' and uid=" &  Info.User)
			If rs1.eof = False Then
				configid = rs1(0).value
			end if
			rs1.close
			If configid > 0 Then
				cn.execute "delete erp_sys_LvwConfig where id=" & configid
				cn.execute "delete erp_sys_LvwColConfig where cfgid=" & configid
			end if
		end function
		Public Function ClearformulConfigPage
			Dim rs1, configid
			configid = 0
			Set rs1 = cn.execute("select id from erp_sys_LvwConfig where lvwid='" & Md5Key16 & "' and uid=0")
			If rs1.eof = False Then
				configid = rs1(0).value
			end if
			rs1.close
			If configid > 0 Then
				cn.execute "update erp_sys_LvwColConfig set evalname=null, formula=null where cfgid=" & configid
			end if
		end function
		Public Function SaveConfigPage
			Dim rs1, configid, i, dbname, visible, sortv, sortv_def , width, title, md5key, uid, oldvisble, clearwidth, dbi
			md5key = Md5Key16
			uid = Info.User
			clearwidth =  false
			Set rs1 = server.CreateObject("adodb.recordset")
			rs1.open "select id, lvwid, uid, width from erp_sys_LvwConfig where lvwid='" & md5key & "' and uid=" & uid, cn, 1, 3
			If rs1.eof Then
				rs1.addnew
				rs1("lvwid").value = md5key
				rs1("uid").value = uid
				rs1.update
			else
				configid = rs1(0).value
				rs1("width") = null
				rs1.update
			end if
			rs1.close
			If configid = 0 Then
				Set rs1 = cn.execute("select id from erp_sys_LvwConfig where lvwid='" & md5key & "' and uid=" & uid)
				configid = rs1(0).value
				rs1.close
			end if
			For i = 1 To 500
				If Len(request.form("rcf_dn_" & i)) = 0 Then Exit For
				dbname  = request.form("rcf_dn_" & i)
				visible = request.form("rcf_vs_" & i)
				sortv =  request.form("rcf_ci_" & i)
				sortv_def =  request.form("rcf_defci_" & i)
				dbi =  request.form("rcf_dbi_" & i)
				width =  request.form("rcf_wd_" & i)
				title =  request.form("rcf_tit_" & i)
				If dbname = "[!null]" Then dbname = ""
				rs1.open "select * from erp_sys_LvwColConfig where cfgid=" & configid & " and dbname='" & Replace(dbname,"'","") & "'", cn, 1, 3
				If rs1.eof  Then
					rs1.addnew
					rs1("cfgid").value = configid
					rs1("dbname").value = dbname
				end if
				rs1("title").value = title
				If Len(Trim(width)) > 0 Then
					rs1("width").value = width
				else
					rs1("width").value = null
				end if
				rs1("colindex").value = sortv_def
				rs1("dbindex").value = dbi
				rs1("sort").value =sortv
				oldvisble = rs1("visible").value
				If Len(visible) > 0 Then  rs1("visible").value = visible
				If rs1("visible").value  <>  oldvisble Then
					clearwidth = true
				end if
				rs1.update
				rs1.close
			next
			i = 0
			rs1.open "select sort, colindex from erp_sys_LvwColConfig where cfgid=" & configid & " order by sort, colindex", cn, 1, 3
			While rs1.eof = False
				i = i + 1
'While rs1.eof = False
				rs1(0).value = i
				rs1.update
				rs1.movenext
			wend
			rs1.close
			Set rs1 = Nothing
			cn.execute "update a set a.newdbindex= b.dbindex  from erp_sys_LvwColConfig a inner join erp_sys_LvwColConfig b on a.cfgid=" & configid & " and b.cfgid=" & configid & " and a.sort = b.colindex"
			If clearwidth Then
				cn.execute "update erp_sys_LvwConfig set width = null where id=" & configid
				cn.execute "update erp_sys_LvwColConfig set width = null where cfgid=" & configid
			end if
		end function
		Public Function SaveformulConfigPage
			Dim rs1, configid, i, dbname, evalname, formula,  title, md5key
			md5key = Md5Key16
			If Info.issupperadmin = False Then Err.raise "908", "ZBRLib3175", "您没有设置公式的权限"
			Set rs1 = server.CreateObject("adodb.recordset")
			rs1.open "select id, lvwid, uid, width from erp_sys_LvwConfig where lvwid='" & md5key & "' and uid=0", cn, 1, 3
			If rs1.eof Then
				rs1.addnew
				rs1("lvwid").value = md5key
				rs1("uid").value = 0
				rs1.update
			else
				configid = rs1(0).value
			end if
			rs1.close
			If configid = 0 Then
				Set rs1 = cn.execute("select id from erp_sys_LvwConfig where lvwid='" & md5key & "' and uid=0")
				configid = rs1(0).value
				rs1.close
			end if
			For i = 1 To 500
				If Len(request.form("s_rcf_dn_" & i)) = 0 Then Exit For
				evalname  = request.form("s_rcf_fvn_" & i)
				formula = request.form("s_rcf_fml_" & i)
				dbname = request.form("s_rcf_dn_" & i)
				If Len(evalname) > 0 and Len(formula) > 0 then
					If dbname = "[!null]" Then dbname = ""
					rs1.open "select cfgid, dbname, evalname, formula from erp_sys_LvwColConfig where cfgid=" & configid & " and dbname='" & Replace(dbname,"'","") & "'", cn, 1, 3
					If rs1.eof  Then
						rs1.addnew
						rs1("cfgid").value = configid
						rs1("dbname").value = dbname
					end if
					rs1("evalname").value = evalname
					rs1("formula").value = formula
					rs1.update
					rs1.close
				end if
			next
		end function
		Private Function getselecthtml(ByVal ci, ByVal ct)
			Dim i, r
			For i = 1 To ct
				If i = ci Then
					r = r & "<option value=" & i & " selected>" & i & "</option>"
				else
					r = r & "<option value=" & i & ">" & i & "</option>"
				end if
			next
			getselecthtml = r
		end function
		Function getViewState()
			dim nlvw , dat , i , h, nh, ls
			set nlvw =  new listview
			if me.dbmodel <> nlvw.dbmodel then dat = dat & ":l.dbmodel=""" & me.dbmodel & """"
			If Len(Me.HeaderConfigKey & "") > 0 Then dat = dat & ":l.HeaderConfigKey=""" & replace(me.HeaderConfigKey,"""","""""") & """"
			If Me.finanDBModel = true Then  dat = dat & ":l.FinanDBModel=true"
			If Me.editkey <> nlvw.editkey Then dat = dat & ":l.editkey=""" & Replace(me.editkey, """", "") & """"
			if me.sortSql <> "" then dat = dat & ":l.sortSql=""" & me.sortSql & """"
			if me.recordPerSheet <> nlvw.recordPerSheet then dat = dat & ":l.recordPerSheet=""" & me.recordPerSheet & """"
			if me.sheetPerFile <> nlvw.sheetPerFile then dat = dat & ":l.sheetPerFile=""" & me.sheetPerFile & """"
			if me.id <> nlvw.id then dat = dat & ":l.id=""" & me.id & """"
			if me.jsonEditModel <> nlvw.jsonEditModel then dat = dat & ":l.jsonEditModel=" & me.jsonEditModel
			if me.checkbox <> nlvw.checkbox then dat = dat & ":l.checkbox=" & me.checkbox
			if me.checkvalue <> nlvw.checkvalue then dat = dat & ":l.checkvalue=""" & me.checkvalue & """"
			if me.extAttribute <> nlvw.extAttribute then dat = dat & ":l.extAttribute=""" & me.extAttribute & """"
			if me.indexbox <> nlvw.indexbox then dat = dat & ":l.indexbox=" & me.indexbox
			if me.toolbar <> nlvw.toolbar then dat = dat & ":l.toolbar=" & me.toolbar
			if me.pagesize <> nlvw.pagesize  then dat = dat & ":l.pagesize=" & me.pagesize
			if me.scroll = true  then dat = dat & ":l.scroll=true"
			If me.colresize = True Then  dat = dat & ":l.colresize=true"
			if Len(me.width & "") > 0 then dat = dat & ":l.width=""" & Me.width & """"
			if me.allsum = true  then dat = dat & ":l.allsum=true"
			If Me.PageButtonAlign = "right" Then dat = dat & ":l.PageButtonAlign=""right"""
			if me.isshow_visible=False then dat = dat & ":l.isshow_visible=false"
			if me.Autoresize=false then dat = dat & ":l.Autoresize=false"
			if me.isshow_ymc=True then dat = dat & ":l.isshow_ymc=True"
			if me.isshow_xmc=True then dat = dat & ":l.isshow_xmc=True"
			If lcase(Me.dataoverflow) <> "hidden" Then  dat = dat & ":l.isshow_xmc=""" & Me.dataoverflow & """"
			if me.isshow_anotherName=True then dat = dat & ":l.isshow_anotherName=True"
			if me.isshow_formula=True then dat = dat & ":l.isshow_formula=True"
			If me.isPageReckon = True Then dat = dat & ":l.isPageReckon=True"
			If Len(me.FaStr & "") > 0 Then  dat = dat & ":l.FaStr=""" &Me.FaStr&""""
			if me.excelsql<>"" then dat = dat & ":l.excelsql="""& replace(me.excelsql,"""","""""")  &""""
			if me.currsum = true  then dat = dat & ":l.currsum=true"
			if me.CanPageSize = false then dat = dat & ":l.CanPageSize=false"
			if me.showfullopen = true then dat = dat & ":l.showfullopen=true"
			if me.pageindex <> nlvw.pageindex  then dat = dat & ":l.pageindex=" & me.pageindex
			if me.addlink <> nlvw.addlink then dat = dat & ":l.addlink=""" & replace(me.addlink,"""","""""") & """"
			if me.ZoreColor <> nlvw.ZoreColor then dat = dat & ":l.ZoreColor=""" & me.ZoreColor & """"
			if me.headExplanName <> "" then dat = dat & ":l.headExplanName=""" & me.headExplanName & """"
			if me.PreMsg <> "" then dat = dat & ":l.PreMsg=""" & replace( me.PreMsg,"""","""""") & """"
			If me.distinctSpaceCol <> "" then dat = dat & ":l.distinctSpaceCol=""" & replace(me.distinctSpaceCol,"""","""""") & """"
			if me.dataAttr <> "" then dat = dat & ":l.dataAttr=""" & me.dataAttr & """"
			if me.tagData <> "" then dat = dat & ":l.tagData=""" & me.tagData & """"
			If Me.ServerConfig = True Then dat = dat & ":l.ServerConfig =true"
			if me.MulExplan <> false then dat = dat & ":l.MulExplan=true"
			if me.noScrollModel = True Then dat = dat & ":l.noScrollModel=true"
			if me.fixedCell > 0 then dat = dat & ":l.fixedCell=" & me.fixedCell
			If Me.IsaccWidth = True Then dat = dat & ":l.IsaccWidth=true"
			If Me.IsAbsWidth = True Then dat = dat & ":l.IsAbsWidth=true"
			If Me.cbWaitMsg <> "" Then dat = dat & ":l.cbWaitMsg=""" & Me.cbWaitMsg & """"
			If Me.excelcallbackproc <> "" Then dat = dat & ":l.excelcallbackproc=""" & Me.excelcallbackproc & """"
			If Me.mxzdyId <> 0 Then  dat = dat & ":l.mxzdyId=" & Me.mxzdyId
			If Me.css <> "" Then dat = dat & ":l.css=""" & Me.css & """"
			If Me.PageBar = False Then dat = dat &  ":l.PageBar=false"
			If Me.oldPageSizeUI = True then dat = dat & ":l.oldPageSizeUI=true"
			If Me.HeaderPageSizeUI = True Then dat = dat & ":l.HeaderPageSizeUI=true"
			If Me.cansort = False Then  dat = dat & ":l.cansort=false"
			If Me.checkboxwidth > 0 Then dat = dat & ":l.checkboxwidth=" & Me.checkboxwidth
			If Me.headNameJoin = False then dat = dat & ":l.headNameJoin=False"
			If Me.RowSplitFields <> "" Then dat = dat & ":l.RowSplitFields=""" & replace(me.RowSplitFields,"""","""""") & """"
			If Me.RowSplitSum = True Then dat = dat & ":l.RowSplitSum=true"
			If Me.rowcolorkey <> "" Then dat = dat & ":l.rowcolorkey=""" & replace(me.rowcolorkey,"""","""""") & """"
			If Me.edit = true Then dat = dat & ":l.edit=true"
			If Me.edit.canadd = false Then dat = dat & ":l.edit.canadd=false"
			If Me.edit.candel = false Then dat = dat & ":l.edit.candel=false"
			If Me.edit.rowmove = false Then dat = dat & ":l.edit.rowmove=false"
			If Me.excelextIntro <> "" Then dat = dat & ":l.excelextIntro=""" & replace(me.excelextIntro,"""","""""") & """"
			If Me.edit.candelexpress <> "" Then dat = dat & ":l.edit.candelexpress=""" & Replace(Me.edit.candelexpress, """","""""") & """"
			If Me.edit.canistexpress <> "" Then dat = dat & ":l.edit.canistexpress=""" & Replace(Me.edit.canistexpress, """","""""") & """"
			If Me.CacheKeys <> "" Then dat = dat & ":l.CacheKeys=""" & CacheKeys & """"
			If Me.CacheRules <> "" Then dat = dat & ":l.CacheRules=DB(""" & replace(app.base64.encode(Me.CacheRules),"""","""""") & """)"
			dat = dat & ":if l.ResetSql="""" then: l.sql=DB(""" & replace(app.base64.encode(msql),"""","""""") & """): else: l.sql=l.resetsql: end if"
			set nlvw =  nothing
			set nh = new lvwColumn
			dat = dat & ":if l.colbackpost=true and (len(l.excelcallbackproc)=0 or request(""cmd"")<>""cexcel"") then"
			for i = 1 to headers.count
				set h = headers(i)
				If (me.checkbox Or Me.indexbox) And (h.title = "选择" Or h.title="序号") And  h.dbname="" Then
				else
					if len(h.dbname) = 0 then
						dat = dat & ":set h=l.headers.insert(""" & replace(h.title,"""","""""") & """,""""," & i & ")"
						dat = dat & ":h(1)=""" & replace(h.defhtml,"""","""""") & """"
					else
						If Me.istreegrid Then
							ls = ":set h=l.headers.cItem(""" & Chr(1) & Replace(h.dbname,"""","""""") & Chr(1) & """)"
						else
							ls = ":set h=l.headers(""" & Chr(1) & Replace(h.dbname,"""","""""") & Chr(1) & """)"
						end if
						dat = dat & ls
					end if
					if len(h.evalName) > 0 then dat = dat & ":h(2)=""" & replace(h.evalName,"""","""""") & """"
					if len(h.evalCode) > 0 then dat = dat & ":h(3)=""" & replace(h.evalCode,"""","""""") & """"
					if h.dbname <> h.title then dat = dat & ":h(4)=""" & replace(h.title,"""","""""") & """"
					if h.display <> nh.display then dat = dat & ":h(5)=""" & h.display & """"
					if h.visible <> nh.visible then dat = dat & ":h(6)=" & h.visible
					if h.width <> nh.width then dat = dat & ":h(7)=""" & h.width & """"
					if h.dbtype <> nh.dbtype then dat = dat & ":h(8)=""" & h.dbtype & """"
					if h.formattext <> nh.formattext then dat = dat & ":h(9)=""" & replace(h.formattext,"""","""""") & """"
					if h.Formula <> nh.Formula then dat = dat & ":h(10)=""" & replace(h.Formula,"""","""""") & """"
					if h.selid <> nh.selid then dat = dat & ":h(11)=" & h.selid
					if h.edit <> nh.edit then dat = dat & ":h(12)=" & h.edit
					if h.ico <> nh.ico then dat = dat & ":h(13)=""" & h.ico & """"
					if h.selfitem <> nh.selfitem then dat = dat & ":h(14)=" & h.selfitem
					if h.cssname <> nh.cssname then dat = dat & ":h(15)=""" & h.cssname & """"
					if h.dbIndex <> nh.dbIndex then dat = dat & ":h(16)=" & h.dbIndex
					if h.align <> nh.align then dat = dat & ":h(17)=""" & h.align & """"
					if h.splitCell = true then dat = dat & ":h.splitCell=true"
					If h.sorttype <>  nh.sorttype Then dat = dat & ":h(18)=" & h.sorttype
					If h.linkFormat <> "" Then   dat = dat & ":h(19)=""" & h.linkFormat & """"
					If h.align2 <> "" Then   dat = dat & ":h(20)=""" & h.align2 & """"
					If h.canSum = false then  dat = dat & ":h(21)=false"
					If h.bz <> nh.bz then  dat = dat & ":h.bz=""" & h.bz & """"
					If Len(h.JoinFields) > 0 Then
						dat = dat & ":h(22)=" & h.JoinVisible & ""
						dat = dat & ":h(23)=""" & Replace(h.JoinFields,"""","""""") & """"
					end if
					If h.formulaIsRowRepeat <> nh.formulaIsRowRepeat Then dat = dat & ":h(24)=""" & h.formulaIsRowRepeat & """"
					If h.tryCurrSumWhenRepeat <> nh.tryCurrSumWhenRepeat Then dat = dat & ":h(25)=" & h.tryCurrSumWhenRepeat
					If h.ignoreNonnumeric <> nh.ignoreNonnumeric Then dat = dat & ":h(26)=" & h.ignoreNonnumeric
					If h.cangroupsum <> nh.cangroupsum Then dat = dat & ":h(28)=" & h.cangroupsum
					If h.uiType <> nh.uiType Then dat = dat & ":h(29)=""" & h.uiType & """"
					If h.defaultValue <> nh.defaultValue Then dat = dat & ":h(30)=""" & replace(h.defaultValue,"""","""""") & """"
					If h.notnull <> false Then dat = dat & ":h(31)=true"
					If h.maxsize <> nh.maxsize Then dat = dat & ":h(32)=" & h.maxsize & ""
					If h.vailmsg <> nh.vailmsg Then dat = dat & ":h(33)=""" &  replace(h.vailmsg,"""","""""") & """"
					If h.source <> nh.source Then dat = dat & ":h(34)=""" & replace(h.source,"""","""""") & """"
					If h.boxWidth <> nh.boxWidth Then dat = dat & ":h(35)=" & h.boxWidth
					If h.unit <> nh.unit Then dat = dat & ":h(36)=""" & Replace(h.unit,"""","""""") & """"
					If h.EditLock <> nh.EditLock Then
						If isnumeric(h.EditLock) Then
							dat = dat & ":h(37)=" & h.EditLock
						else
							dat = dat & ":h(37)=""" & replace(h.EditLock,"""","""""") & """"
						end if
					end if
					If h.js <> nh.js Then dat = dat & ":h(38)=""" & replace(h.js,"""","""""") & """"
					If h.onclick <> nh.onclick Then dat = dat & ":h(39)=""" & replace(h.onclick,"""","""""") & """"
					If h.onchange <> nh.onchange Then dat = dat & ":h(40)=""" & replace(h.onchange,"""","""""") & """"
					If h.minvalue <> nh.minvalue Then dat = dat & ":h(41)=" & h.minvalue & ""
					If h.maxvalue <> nh.maxvalue Then dat = dat & ":h(42)=" & h.maxvalue & ""
					If h.canhide = False Then  dat = dat & ":h(43)=false"
					If h.cansort = False Then  dat = dat & ":h(44)=false"
					If h.canBatchInput & "" <> "" Then dat = dat & ":h(45)=" & CLng(h.canBatchInput)
					If h.excelAlign&""<>"" Then dat = dat & ":h(46)=""" & h.excelAlign &""""
					If h.ContentStyle&""<>"" Then dat = dat & ":h(47)=""" &  replace(h.ContentStyle,"""","""""")  &""""
					If h.url&""<>"" Then dat = dat & ":h.url=""" & h.url &""""
				end if
			next
			dat = dat & ":end if"
			If Len(Me.excelcallbackproc) > 0 Then
				dat = dat & ":if len(l.excelcallbackproc)>0 and request(""cmd"")=""cexcel"" then"
				dat = dat & ":call " & Me.excelcallbackproc & "(l)"
				dat = dat & ":end if"
			end if
			If Me.colbackPost = False Then dat = dat & ":l.colbackPost=false"
			getViewState = app.base64.encode(dat)
		end function
		private function iif(express , truev , falsev)
			if express then
				iif = truev
			else
				iif = falsev
			end if
		end function
		Private Sub LoadUserConfigData
			Dim s, i
			If isArray(userconfig) = false Then
				Dim rsx : set rsx = cn.execute("select a.dbname, a.width, abs(visible), a.title, a.newdbindex from [erp_sys_LvwConfig] b inner join [erp_sys_LvwColConfig] a on a.cfgid=b.id and b.uid=" & info.user & " and b.lvwid='" & md5key16 & "'")
				If rsx.eof = False then
					s = rsx.GetString(2,-1,chr(1),chr(2),"")
'If rsx.eof = False then
				end if
				rsx.close
				userconfig = Split(s & "", Chr(2))
				For i = 0 To ubound(userconfig)
					userconfig(i) = Split(userconfig(i),Chr(1))
				next
			end if
		end sub
		Private sub getUserConfigItem(Byval colname, ByRef  width, ByRef title, ByRef ci, byval headercount)
			Dim s, i, item
			Call loadUserConfigData
			For i = 0 To ubound(userconfig) - 1
'Call loadUserConfigData
				item = userconfig(i)
				If item(0) = colname Then
					on error resume next
					width =  CLng(item(1))
					title =  item(3)
					If not Me.excelmode Then
						ci = item(4)
					else
						If headercount&"" =  (ubound(userconfig)+1)&"" Then
							ci = item(4)
							ci = item(4)
						end if
					end if
					Exit sub
				end if
			next
			ci = ""
		end sub
		Private Function IsVisibleCol(Byval colname)
			Dim s, i, item
			if instr(colname,"#sort_") = 1 Then  IsVisibleCol = False : exit function
			Call loadUserConfigData
			For i = 0 To ubound(userconfig) - 1
'Call loadUserConfigData
				item = userconfig(i)
				If item(0) = colname Then
					on error resume next
					IsVisibleCol = item(2) <> "0"
					Exit function
				end if
			next
			IsVisibleCol = true
		end function
		Private Function LoadUserConfig
			Dim i, h, w, hs, rsx, title, ci, ii
			hs = False
			ReDim colMaps(headers.count)
			For i = 1 To headers.count
				Set h = headers(i)
				title = ""
				If ServerConfig Then Call getUserConfigItem(h.dbname, w, title, ci, headers.count)
				If h.display = "none" Or h.execdisplay = "none" Then
					h.width = 0
				else
					If Len(w) > 0 Then
						h.width = w
						IsAbsWidth = True
						IsAccWidth = True
						hs = true
					end if
				end if
				If Len(ci) = 0 Then
					ColMaps(i) = i
				else
					ColMaps(ci) = i
				end if
				If Len(title) > 0 then
					h.ectitle = title
				else
					h.ectitle = h.title
				end if
				If InStr(h.title, h.evalcode) = 0 And Len(h.evalname) > 0 Then
					h.ectitle = h.ectitle & "<br>(" & h.evalname & "=" & h.evalcode & ")"
				end if
			next
			dim x , y , exist
			For i = 1 To ubound(colmaps)
				If Len(colmaps(i)) = 0 Then
					for x=1 to headers.count
						exist = false
						for y = 1 to headers.count
							if x = colmaps(y) then
								exist = true
								exit for
							end if
						next
						if  exist = false then
							colmaps(i) = x
							exit for
						end if
					next
				end if
			next
			For i = 1 To ubound(colmaps)
				If Len(colmaps(i)) = 0 Then colmaps(i) = i
			next
			If hs Then
				set rsx = cn.execute("select width from [erp_sys_LvwConfig] b where b.uid=" & info.user & " and b.lvwid='" & md5key16 & "'")
				If rsx.eof = False Then
					width = rsx("width").value
				end if
				rsx.close
				Set rsx = nothing
			end if
		end function
		Private regExObj
		Private Function RegReplace(s,p,strReplace)
			If isEmpty(regExObj) Then
				Set regExObj = New RegExp
			end if
			regExObj.Pattern = p
			regExObj.IgnoreCase = True
			regExObj.Global = True
			RegReplace=regExObj.replace(s,strReplace)
		end function
		Public Function getTypeById(typeId)
			Dim r
			If (typeId > 1 And typeId < 7) Or (typeId > 15 And typeID < 22 ) Or typeId - 131 = 0 Then
'Dim r
				If typeId =2 Or typeId=3 Then
					r = "int"
				ElseIf  typeId>=17 and typeId<=19 Then
					r = "int"
				else
					r = "number"
				end if
			else
				Select Case typeId
				Case 7: r = "date"
				Case 11: r = "bool"
				Case 64: r = "date"
				Case 133: r = "date"
				Case 134: r = "date"
				Case 135: r = "date"
				Case Else: r= "string"
				End Select
			end if
			getTypeById = r
		end function
	end Class
	Sub lvw_defCallBack(defv, defv2)
	end sub
	Public Function DB(s)
		DB  = app.base64.decode(s)
	end function
	Function lvw_getFTypeById(typeId)
		Dim r
		If (typeId > 1 And typeId < 7) Or (typeId > 15 And typeID < 22 ) Or typeId - 131 = 0 Then
'Dim r
			If typeId = 2 Or typeId = 3 Or (typeId > 15 And  typeId < 20) Then
				r = "int"
			else
				r = "float"
			end if
		else
			Select Case typeId
			Case 7: r = "datetime"
			Case 11: r = "bit"
			Case 64: r = "datetime"
			Case 133: r = "datetime"
			Case 134: r = "datetime"
			Case 135: r = "datetime"
			Case Else: r= "nvarchar(500)"
			End Select
		end if
		lvw_getFTypeById = r
	end function
	Sub app_sys_lvw_EditRowOnChange(ByVal l)
		Dim backcode, html, cols, currs,  i, ii,  itm, db
		Dim currdata, cv, itemvs
		currdata = Split(request.form("currvalues") & "", Chr(1) & Chr(4))
		Set db = New DBCommand
		cols = Split(app.getText("cols"), Chr(1))
		Dim exc : exc = Replace(Replace(Replace(Trim(app.getText("exc")), ":", ""), vbcrlf , ""), "(", "")
		For i = 0 To ubound(cols)
			itm = Split(cols(i), Chr(2))
			cv = "NULL"
			For ii = 0 To ubound(currdata)
				itemvs = Split(currdata(ii), Chr(2) & Chr(1))
				If LCase(itemvs(0)) = LCase(itm(0)) Then
					If itemvs(1) <> "" Then
						If isnumeric(itemvs(1)) = False then
							cv = "'" & Replace(itemvs(1), "'", "''") & "'"
						else
							cv = itemvs(1)
						end if
					end if
				end if
			next
			cols(i) = "cast(" & cv & " as " & lvw_getFTypeById(CLng(itm(1))) & ") as [" & itm(0) & "]"
		next
		l.resetsql = "select " & Join(cols, ",")
		l.recordcanedit = true
		backcode = app.base64.decode(request.form("backdata"))
		execute backcode
		l.currsum = False
		l.allsum = False
		l.pageindex = 1
		If app.ExistsProc("App_lvw_onCellChange") Then
			Call App_lvw_onCellChange(l, exc, request("value"))
		end if
		html = l.HTML
		Dim i1, i2
		i1 = InStr(html, "<!--#lvw_data_begin#-->") + Len("<!--#lvw_data_begin#-->")
'Dim i1, i2
		i2 = InStr(html, "<!--#lvw_data_end#-->")
'Dim i1, i2
		Response.write Mid(html, i1, i2 - i1)
'Dim i1, i2
	end sub
	Sub app_sys_lvw_getnullRowHTML(ByVal l)
		Dim backcode, html, cols, i, itm, db
		Set db = New DBCommand
		cols = Split(app.getText("cols"), Chr(1))
		For i = 0 To ubound(cols)
			itm = Split(cols(i), Chr(2))
			If itm(2) = "" Then
				itm(2) = "NULL"
			else
				If False = isnumeric(itm(2)) Then
					itm(2) = "'" & Replace(itm(2), "'","''") & "'"
				end if
			end if
			cols(i) = "cast(" & itm(2) & " as " & lvw_getFTypeById(CLng(itm(1))) & ") as [" & itm(0) & "]"
		next
		l.resetsql = "select " & Join(cols, ",")
		backcode = app.base64.decode(request.form("backdata"))
		execute backcode
		l.currsum = False
		l.allsum = False
		l.pageindex = 1
		html = l.HTML
		Dim i1, i2
		i1 = InStr(html, "<!--#lvw_data_begin#-->") + Len("<!--#lvw_data_begin#-->")
'Dim i1, i2
		i2 = InStr(html, "<!--#lvw_data_end#-->")
'Dim i1, i2
		Response.write Mid(html, i1, i2 - i1)
'Dim i1, i2
	end sub
	Function app_sys_lvw_getcacheLvwID(ByVal data)
		Dim i1 : On Error Resume next
		i1 = InStr(1, data, "l.id=""", 1)
		app_sys_lvw_getcacheLvwID = Split(Mid(data, i1+6, 50), """")(0)
'i1 = InStr(1, data, "l.id=""", 1)
	end function
	Sub lvw_refreshTreeNode(l)
		Dim id : id = app.gettext("lvwid")
		If app.existsProc("app_sys_treeviewCallBack") = False Then
			Response.write "{err:""未包含treeview.asp页面""}"
			Exit sub
		end if
		Dim tvw : Set tvw = New TreeView
		Set tvw.headers = l.headers
		If app.existsproc("App_TreeListCallBack") Then
			tvw.id = id
			Call App_TreeListCallBack(tvw)
		end if
		Dim lvw: Set lvw = tvw.createListView()
		lvw.iscallback = true
		Response.write lvw.HTML
		Set lvw = nothing
	end sub
	sub app_sys_lvw_callback
		dim l , backcode ,h, i
		set l = new listview
		l.isCallback = True
		backcode = Trim(request.form("backdata"))
		backcode = app.base64.decode(backcode)
		select case request.form("cmd")
		Case "lvwHeaderExplan"
		l.colbackPost = False
		Case "svselhdconfig"
		If app.getInt("ht") = 0 Then
			app.Attributes("rcs_" & app.getText("an")) = ""
		else
			app.Attributes("rcs_" & app.getText("an")) = app.getText("av")
		end if
		If app.existsProc("lvw_onUIConfig") Then
			Call lvw_onUIConfig (app.getText("an"), app.getInt("ht"))
		end if
		Exit Sub
		Case "GetNullRowHTML"
		Call app_sys_lvw_getnullRowHTML(l)
		Exit Sub
		Case "EditRowOnChange"
		Call app_sys_lvw_EditRowOnChange(l)
		Exit Sub
		case "colsettingSave"
		l.id = app_sys_lvw_getcacheLvwID(backcode)
		call lvw_colsettingSave(l.GetSboxHeaderConfigMd5)
		end Select
		execute backcode
		If app.existsProc("lvw_onCallback") Then
			Call lvw_onCallback(l)
		end if
		select case request.form("cmd")
		case "newPageIndex"
		l.pageindex = abs(request.form("value"))
		case "newPageSize"
		l.pagesize = abs(request.form("value"))
		l.pageindex = Abs(request.form("pageindex"))
		Case "insertRow"
		Case "lvwsortevent"
		l.sortsql =  app.getText("value")
		for i = 1 to l.headers.count
			set h = l.headers(i)
			if  "[" & h.dbname & "]" = app.getText("dbname") then
				h.sorttype =  app.getText("dbsort")
			else
				h.sorttype = 0
			end if
		next
		case "cexcel"
		l.excelmode = True
		l.showExcelProc 100, 2
		Case "colsettingReset"
		Call lvw_colsettingReset(l.GetSboxHeaderConfigMd5)
		call lvw_defCallBack(request.form("cmd"),l)
		Case "headerchance"
		Call lvw_headerChange(l)
		Case "refreshTreeNode"
		Call lvw_refreshTreeNode(l)
		Set l = Nothing
		Exit sub
		case Else
		call lvw_defCallBack(request.form("cmd"),l)
		end Select
		If request.form("resized") <> "" Then
			Call lvw_setNewColWidth(l, request.form("resized"))
		end if
		Response.write l.HTML
	end sub
	sub lvw_setNewColWidth(l, nData)
		on error resume next
		Dim i, s, item : s = Split(ndata, ";")
		For i = 0 To ubound(s)
			item = Split(s(i),"=")
			If items(0) <> "" Then
				If item(0) = "[!sfd]" Then
				else
					l.headers(item(0)).width = item(1)
				end if
			end if
		next
		l.IsAccWidth = true
		l.IsAbsWidth = true
	end sub
	Sub lvw_headerChange(ByVal l)
		Dim i, ofd
		Dim changekey : changekey = app.gettext("value")
		Dim item : Set item = l.headers.getitembydbname(changekey)
		Dim fs : fs = Split(item.joinfields, ";")
		item.joinVisible = True
		Dim ohc : ohc = app.existsProc("lvw_onHeaderChange")
		For i = 0 To ubound(fs)
			If LCase(fs(i)) <> LCase(changekey) then
				l.headers.getitembydbname(fs(i)).joinvisible = false
				If ohc Then Call lvw_onHeaderChange(l , fs(i) ,changekey ,item  )
			end if
		next
	end sub
	Sub app_sys_lvwshowfull
		dim l , backcode ,h, i
		set l = new listview
		backcode = request.form("viewdata")
		if len(backcode) = 0 then
			exit sub
		end if
		execute app.base64.decode(backcode)
		Response.write "<!DOCTYPE html><html style='overflow:auto'>"
		Response.write "<head>"
		Response.write request.form("headhtml")
		Response.write "</head><body><div style='width:" & cint(l.getwidth()*1.5) & "px;position:relative;overflow:visible'>"
		l.width = "100%"
		Response.write l.html
		Response.write "</div></body></html>"
	end sub
	Function getDeepName(nm, deep)
		on error resume next
		If InStr( nm,"_") > 0 Then
			getDeepName = Split(nm,"_")(deep)
		else
			getDeepName =  nm
		end if
		If Err.number <> 0 Then
			getDeepName = nm
		end if
	end function
	sub lvw_colsettingSave(id)
		dim data, i, lvw, path , rs, item, ii, formula,anotherName,ss,s,Rturn
		path = replace(replace(request.ServerVariables("url"),"/",""),".asp","")
		data = split(app.getText("value"),"|")
		set rs = server.CreateObject("adodb.recordset")
		On Error GoTo 0
		cn.BeginTrans
		for i = 0 to ubound(data)
			item = split(data(i),",")
			if instrRev(item(0),"("&item(2)&"=")>0 then item(0)= left(item(0),instrRev(item(0),"("&item(2)&"=")-1)
'item = split(data(i),",")
			if instrRev(item(1),"("&item(2)&"=")>0 then item(1)= left(item(1),instrRev(item(1),"("&item(2)&"=")-1)
'item = split(data(i),",")
			rs.open "select * from erp_sys_listviewConfig where uid=" & info.user & " and attrn='colv' and path='" & path & "' and lvwid='" & id & "' and colname='" & replace(item(0),"'","''") & "'" , cn , 1, 3
			if item(4) = "0" then
				if rs.eof then
					rs.addnew
					rs.fields("uid").value = info.user
					rs.fields("path").value = path
					rs.fields("lvwid").value = id
					rs.fields("colname").value = item(0)
					rs.fields("attrn").value = "colv"
					rs.fields("attrv").value = 0
					rs.update
				end if
			else
				if rs.eof = false then
					rs.delete
					rs.update
				end if
			end if
			rs.close
			rs.open "select * from erp_sys_listviewConfig where uid=" & info.user & " and attrn='nowmc' and path='" & path & "' and lvwid='" & id & "' and colname='" & replace(item(0),"'","''") & "'" , cn , 1, 1
			if len(item(1)) > "0" then
				if rs.eof then
					cn.execute("insert into erp_sys_listviewConfig (uid,path,lvwid,colname,attrn,attrv) values ("&info.user&",'"&path&"','"& id &"','"&item(0)&"','nowmc','"&item(1)&"')")
				else
					cn.execute("UPDATE erp_sys_listviewConfig SET attrv='"&item(1)&"' where uid=" & info.user & " and attrn='nowmc' and path='" & path & "' and lvwid='" & id & "' and colname='" & replace(item(0),"'","''") & "'")
				end if
			end if
			rs.close
			rs.open "select * from erp_sys_listviewConfig where attrn='anotherName' and path='" & path & "' and lvwid='" & id & "' and colname='" & replace(item(0),"'","''") & "'" , cn , 1, 1
			if len(item(2)) > 0 then
				if rs.eof then
					cn.execute("insert into erp_sys_listviewConfig (uid,path,lvwid,colname,attrn,attrv) values ("&info.user&",'"&path&"','"& id &"','"&item(0)&"','anotherName','"&item(2)&"')")
				else
					cn.execute("UPDATE erp_sys_listviewConfig SET attrv='"&item(2)&"' where attrn='anotherName' and path='" & path & "' and lvwid='" & id & "' and colname='" & replace(item(0),"'","''") & "'")
				end if
			end if
			rs.close
			Dim retitle
			Set rs =  cn.execute("select  top 1 attrv from erp_sys_listviewConfig where  uid=" & info.user & " and attrn='nowmc' and charindex('_', colname)=0 and path='" & path & "' and lvwid='" & id & "'   group by attrv having count(1)>1 " )
			If rs.eof = False Then
				retitle= rs(0)
			end if
			rs.close
			If Len(retitle&"")>0 Then
				cn.rollbacktrans
				Response.write "<ajaxscript>app.Alert('【"&retitle&"】字段别名相同!')</ajaxscript>"
				Exit Sub
			end if
			if len(item(3))>0 then
				formula=Trim(item(3))
				ReDim ss(ubound(data))
				For ii=0 to ubound(data)
					anotherName=split(data(ii),",")
					If Len(anotherName(2))>0 Then
						ss(ii)=anotherName(2)
					end if
				next
				For ii=1 To Len(formula)
					s=Mid(formula,ii,1)
					If IsNumeric(s)=False Then
						Rturn=False
						If InStr(Join(ss,"")&"N",s)>0 Then
							Rturn=True
							If ii<Len(formula) then
								If InStr("+-*/()<>",Mid(formula,ii+1,1))=0 Then
'If ii<Len(formula) then
									Rturn=False
									Exit For
								end if
							end if
						else
							If InStr("+-*/()<>",s)>0 Then
								Exit For
								Rturn=True
							ElseIf s="." Then
								If ii<Len(formula) then
									If IsNumeric(Mid(formula,ii+1,1)) Then
'If ii<Len(formula) then
										Rturn=True
									end if
								end if
							end if
						end if
						If Rturn=False Then Exit For
					end if
				next
				on error resume next
				Randomize
				If Rturn=True Then
					For ii=0 To ubound(ss)
						If Len(ss(ii)&"")>0 Then
							formula=Replace(formula,ss(ii),int(rnd*100)/100)
						end if
					next
					formula=Replace(formula,"N",rnd())
				else
					cn.rollbacktrans
					Response.write "<ajaxscript>app.Alert('公式("& item(3) &")设置错误,请确认后再保存!')</ajaxscript>"
					Exit For
				end if
				Execute "Option Explicit " & vbcrlf &" dim aaa:aaa=("& formula&")"
				If Err.number<>0 Then
					cn.rollbacktrans
					Response.write "<ajaxscript>app.Alert('公式("&item(3)&")设置错误,请确认后再保存!')</ajaxscript>"
					Exit For
				end if
				s=eval(formula)
				If Err.number<>0 Or s="" Then
					cn.rollbacktrans
					Response.write "<ajaxscript>app.Alert('公式("&item(3)&")设置错误,请确认后再保存!')</ajaxscript>"
					Exit For
				end if
				If IsNumeric(s) Then
					rs.open "select * from erp_sys_listviewConfig where attrn='formula' and path='" & path & "' and lvwid='" & id & "' and colname='" & replace(item(0),"'","''") & "'" , cn , 1, 1
					if rs.eof then
						cn.execute("insert into erp_sys_listviewConfig (uid,path,lvwid,colname,attrn,attrv) values ("&info.user&",'"&path&"','"& id &"','"&item(0)&"','formula','"&item(3)&"')")
					else
						cn.execute("UPDATE erp_sys_listviewConfig SET attrv='"&item(3)&"' where attrn='formula' and path='" & path & "' and lvwid='" & id & "' and colname='" & replace(item(0),"'","''") & "'")
					end if
					rs.close
				else
					cn.rollbacktrans
					Response.write "<ajaxscript>app.Alert('公式("&item(3)&")设置错误,请确认后再保存!')</ajaxscript>"
					Exit For
				end if
				On Error GoTo 0
			end if
		next
		cn.CommitTrans
		set rs = nothing
	end sub
	Sub lvw_colsettingReset(id)
		dim path
		path = replace(replace(request.ServerVariables("url"),"/",""),".asp","")
		cn.execute("delete from erp_sys_listviewConfig where path='" & path & "' and (attrn='anotherName' or attrn='formula' or uid='" & Info.user & "') and lvwid='" & id &"'")
	end sub
	Function ReplaceEditVirPath(intro)
		intro = replace(intro,"href=""/edit/", "href=""" & app.virpath & "/edit/",1,1)
		ReplaceEditVirPath = replace(intro,"src=""/edit/", "src=""" & app.virpath & "/edit/",1,1)
	end function
	Sub app_sys_lvw_SavelvwColwidth
		Dim i, lvwid, dbname, width, rs, cols, allw, configid
		cols = app.getint("cols")
		lvwid = app.getText("key16")
		allw = app.getInt("allw")
		Set rs = server.CreateObject("adodb.recordset")
		rs.open "select id,uid,lvwid, width from erp_sys_LvwConfig where uid=" & Info.User & " and lvwid='" & lvwid & "' ", cn, 1, 3
		If rs.eof = False Then
			configid = rs("id").value
		else
			rs.addnew
			rs("uid").value = Info.User
			rs("lvwid").value = lvwid
		end if
		rs("width").value = allw
		rs.update
		rs.close
		If configid = 0 Then
			Set rs = cn.execute("select id from erp_sys_LvwConfig where uid=" & Info.User & " and lvwid='" & lvwid & "'")
			configid = rs("id").value
			rs.close
		end if
		For i = 1  To  cols
			dbname = app.getText("dbname_" & i)
			width = app.getInt("width_" & i)
			rs.open "select cfgid, width, dbname from erp_sys_LvwColConfig where cfgid=" & configid & " and dbname='" & dbname & "' ", cn, 1, 3
			If rs.eof Then
				rs.addnew
				rs("cfgid").value = configid
				rs("dbname").value = dbname
			end if
			If rs("width").value & "" <> width Then
				rs("width").value = width
				rs.update
			end if
			rs.close
		next
		set rs = nothing
	end sub
	Const EX_WIDTH_TEXT = 205
	Const EX_WIDTH_MULTILINE = 245
	Const EX_WIDTH_DATE = 165
	Const EX_WIDTH_DIGIT = 101
	Const EX_WIDTH_SELECT = 87
	Const EX_WIDTH_PERSON = 80
	Const EX_WIDTH_TEL = 110
	Const EX_WIDTH_MAIL = 110
	Class ExcelExportAdapter
		Private olvw
		Private soruces
		Private properties
		Public vPath
		Private Sub Class_Initialize
			Set olvw = New ListView
			olvw.excelmode = True
			recordPerSheet = 10000
			sheetPerFile = 1
			Set soruces = New SQLSoruces
			properties = Split("dbname;1,dbindex;2,display;1,title;1,width;2,dbtype;1,align;1,align2;1,canSum;2,formatText;1,minWidth;2,formatbit;2,distinctSpaceCol;1,Formula;1,excelAlign;1,formulaIsRowRepeat;1,tryCurrSumWhenRepeat;2,ignoreNonnumeric;2,subCall;3,ignoreHTMLTag;2",",")
		end sub
		Public Function headers()
			Set headers = olvw.headers
		end function
		Public Property Let recordPerSheet(n)
		olvw.recordPerSheet = n
		End Property
		Public Property Let sheetPerFile(n)
		olvw.sheetPerFile = n
		End Property
		Public Property Let canSplitFormula_And(v)
		olvw.canSplitFormula_And = v
		End Property
		Public Property Let canSplitFormula_Or(v)
		olvw.canSplitFormula_Or = v
		End Property
		Public Property Get lvw
		Set lvw = olvw
		End Property
		Public Property Get sqls
		Set sqls = soruces
		End Property
		Public Property Let fileName(fname)
		olvw.exportFileName = fname
		End Property
		Public Sub export
			Dim i
			If Len(Me.vPath)>0 Then olvw.vPath = Me.vPath
			For i = 0 To soruces.count - 1
'If Len(Me.vPath)>0 Then olvw.vPath = Me.vPath
				olvw.sql =ConvertListPower(soruces(i).sql)
				olvw.Currsum = True
				If Not isEmpty(soruces(i).headerSettings) Then
					Dim props,prop,k
					Set props = soruces(i).headerSettings
					For k=0 To props.count -1
						'Set props = soruces(i).headerSettings
						Dim hd
						Set prop = props(k)
						If Not isEmpty(prop.dbname) And prop.dbname<>"" Then
							Set hd = olvw.headers.GetItemByDBname(prop.dbname)
						ElseIf Not isEmpty(prop.dbindex) And prop.dbindex<>"" Then
							Set hd = olvw.headers(prop.dbindex)
						end if
						Dim item,j
						For j = 0 To ubound(properties)
							item = Split(properties(j),";")
							If item(0) <> "dbname" And item(0) <> "dbindex" Then
								If item(1) = "3" Then
									If eval("isEmpty(prop."&item(0)&")") = False Then
										execute("hd."& eval("prop."& item(0)))
									end if
								else
'If eval("isEmpty(prop."&item(0)&")") = False Then
									'execute "hd."&item(0)&"=prop."&item(0)&""
									If Abs(Err.number) <> 0 then
										on error goto 0
										'execute "hd."&item(0)&"=prop."&item(0)&"&"""""
										if item(0)<>"display" and item(0)<>"dbtype" and item(0)<>"excelAlign" and item(0)<>"title" Then
											Response.clear
											Response.write "" & vbcrlf & "                                            <script>" & vbcrlf & "                                              alert(""字段配置出错，字段名："
											Response.write item(0)
											Response.write ",错误信息："
											Response.write err.description
											Response.write """);" & vbcrlf & "                                            </script>" & vbcrlf & "                                            "
											Response.end
										end if
									end if
								end if
							end if
						next
					next
				end if
				On Error GoTo 0
				Response.write olvw.multiSqlExport(soruces(i).title,i=soruces.count-1,i)
'On Error GoTo 0
			next
		end sub
		Private Function ConvertListPower(ByVal sql)
			Dim i1, i2, i3, newsql, psign, psql, rs, s1, s2, ptype, catef, introw
			i1 = InStr(1, sql, "/*dis.p.out.b*/",1)
			If i1 > 0 Then i2 = InStr(i1, sql, "/*dis.p.out.e*/",1)
			i3 = 0
			While i2>i1 And i1>0 And i3 <20
				sql = Replace(sql, Mid(sql, i1, i2+15-i1),"")
'While i2>i1 And i1>0 And i3 <20
				i1 = InStr(1, sql, "/*dis.p.out.b*/",1)
'If i1 > 0 Then i2 = InStr(i1, sql, "/*dis.p.out.e*/",1)
				i3 = i3 +1
'If i1 > 0 Then i2 = InStr(i1, sql, "/*dis.p.out.e*/",1)
			wend
			i1 = InStr(1, sql, "/*p-", 1)
'If i1 > 0 Then i2 = InStr(i1, sql, "/*dis.p.out.e*/",1)
			i2 = InStr(1, sql, "/*pe*/", 1)
			If i1 > 0 And i2 > i1 Then
				i3 = InStr(i1, sql, "*/", 1)
				psign = Split(Replace(Replace(Mid(sql, i1, i3 - i1), "/*p-", ""), "-s", "") & "-", "-")
				'i3 = InStr(i1, sql, "*/", 1)
				If IsNumeric(psign(0)) And Len(psign(1))>0 Then
					Set rs = cn.execute("select sort, sort2 from qxlblist where name='导出' and sort1=" & psign(0))
					If rs.eof Then
						ConvertListPower = sql
						Exit function
					else
						catef = psign(1)
						s1 = psign(0)
						s2 = rs(1).value
						ptype = rs(0).value
					end if
					rs.close
					If ptype = 1 Then
						psql = app.iif(app.power.existsPower(s1,s2), "1=1", "1=0")
					else
						introw = app.power.GetPowerIntro(s1,s2)
						If Len(introw) = 0 Then
							psql = "1=1"
						else
							psql = catef & " in (" & introw & ") "
						end if
					end if
					newsql = Left(sql, i1 - 1) & psql & Mid(sql, i2 + 6)
					psql = catef & " in (" & introw & ") "
					ConvertListPower = newsql
				else
					ConvertListPower = sql
				end if
			else
				ConvertListPower = sql
			end if
		end function
	End Class
	Class SQLSoruce
		Public sql
		Public title
		Public headerSettings
		Public Sub class_initialize
			sql = ""
			title = ""
			Set headerSettings = New HeaderColumnSettings
		end sub
	End Class
	Class SQLSoruces
		private sqls
		public count
		public sub class_initialize
			count = 0
			redim sqls(0)
		end sub
		public function Add(soruce)
			dim index,s
			count = count + 1
'dim index,s
			index = count - 1
'dim index,s
			if count > 1 then
				redim preserve sqls(index)
			end if
			set sqls(index) = soruce
			set Add = sqls(index)
		end function
		public default function Item(index)
			dim i
			if isnumeric(index) then
				on error resume next
				set item = sqls(index)
				if err.number <> 0 then
					response.clear
					Response.write "组件ExcelExportAdapter警告：SQLSoruces下标【"&index&"】越界。"
					cn.close
					call AppEnd
				end if
			else
				response.clear
				Response.write "组件ExcelExportAdapter警告：SQLSoruces下标【"&index&"】必须为数字。"
				cn.close
				call AppEnd
			end if
		end function
		public sub clear
			count = 0
			redim sqls(0)
		end sub
		public sub remove(index)
			dim i
			count = count - 1
'dim i
			for i = index - 1 to  count-1
'dim i
				set sqls(i) = sqls(i+1)
'dim i
			next
			redim preserve sqls(count-1)
'dim i
		end sub
	End Class
	Class HeaderColumnSetting
		public dbname
		public dbindex
		public display
		public title
		public width
		public dbtype
		public align
		public align2
		public canSum
		public formatText
		public minWidth
		Public formatbit
		Public excelAlign
		Public tryCurrSumWhenRepeat
		Public formulaIsRowRepeat
		Public distinctSpaceCol
		Public Formula
		Public ignoreNonnumeric
		Public subCall
			Public ignoreHTMLTag
		End Class
		Class HeaderColumnSettings
			private oHeaders
			public count
			public sub class_initialize
				count = 0
				redim oHeaders(0)
			end sub
			public function Add(headerSetting)
				dim index,s
				count = count + 1
'dim index,s
				index = count - 1
'dim index,s
				if count > 1 then
					redim preserve oHeaders(index)
				end if
				set oHeaders(index) = headerSetting
				set Add = oHeaders(index)
			end function
			public default function Item(index)
				dim i
				if isnumeric(index) then
					on error resume next
					set item = oHeaders(index)
					if err.number <> 0 then
						response.clear
						Response.write "组件ExportSetting警告：HeaderColumns下标【"&index&"】越界。"
						Response.end
					end if
				else
					response.clear
					Response.write "组件ExportSetting警告：HeaderColumns下标【"&index&"】必须为数字。"
					Response.end
				end if
			end function
			public sub clear
				count = 0
				redim oHeaders(0)
			end sub
			public sub remove(index)
				dim i
				count = count - 1
'dim i
				for i = index - 1 to  count-1
'dim i
					set oHeaders(i) = oHeaders(i+1)
'dim i
				next
				redim preserve oHeaders(count-1)
'dim i
			end sub
		End Class
		Sub fillPowerInfo(sort1,sort2,ByRef qxopen,ByRef qxintro)
			Dim rsPower
			Set rsPower = cn.execute("select qx_open,qx_intro from power where ord="&session("personzbintel2007")&" and sort1="&sort1&" and sort2="&sort2)
			if rsPower.eof then
				qxopen=0
				qxintro="0"
			else
				qxopen=rsPower("qx_open")
				qxintro=rsPower("qx_intro")
			end if
			rsPower.close
			set rsPower=nothing
		end sub
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
			Set rs = conn.execute("select isnull(sum(case datediff(d,date2,getdate()) when 0 then 1 else 0 end),0) as v1 , count(1) as v2, isnull(sum(case cateid when cateadd then (case datediff(d,date2,getdate()) when 0 then 1 else 0 end) else 0 end),0) as v3, isnull(sum(case cateid when cateadd then 1 else 0end),0) as v4 from tel where cateid = "  & uid & " and sort3=1 and isnull(sp,0)=0 and del=1")
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
			Response.write "" & vbcrlf & "       <tr class=""top accordion"" id=""cpBasezdygroup"">" & vbcrlf & "      <td colspan=""6"" class=""accordion-bar-bg"">" & vbcrlf & "           <div  class=""accordion-bar-tit"" style=""padding-top:6px;"">" & vbcrlf & "                   自定义字段 <span class=""accordion-arrow-down""></span>" & vbcrlf & "             </div>" &vbcrlf & "          <div onclick=""app.stopDomEvent();return false"" style=""float:left;padding:5px"">" & vbcrlf & "              &nbsp;" & vbcrlf & "          "
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
		
		Dim area_list
		Sub page_load
			dim MODULES,conn
			Set conn = cn
			MODULES=session("zbintel2010ms")
			Dim s3 : s3=request("s3")
			if s3="" Then s3=1
			If s3=1 Then
				Dim arrShow(),arrName(),arrFelds(),arrInt(),intgate1
				Dim rs : Set rs=cn.execute("select (case when isnull(name,'')='' then oldname else name end ) as name, (case when show>0 then 1 else 0 end) as show,fieldName,gate1 from setfields where show>0 and  sort2=2 and gate1<>26 order by gate1 asc ")
				Dim intk : intk=0
				While Not rs.eof
					intgate1=rs("gate1")
					redim Preserve arrInt(intk)
					redim Preserve arrShow(intgate1)
					redim Preserve arrName(intgate1)
					redim Preserve arrFelds(intgate1)
					arrInt(intk)=intgate1
					arrShow(intgate1)=rs("show")
					arrName(intgate1)=rs("name")
					arrFelds(intgate1)=rs("fieldName")
					intk=intk+1
					arrFelds(intgate1)=rs("fieldName")
					rs.movenext
				wend
				rs.close
			end if
			Dim EXPORT_FIELDS,allFieldsName,allFieldWidth
			EXPORT_FIELDS = ""
			allFieldWidth = ""
			allFieldsName = Chr(1) & Chr(2)
			If s3=1 Then
				Dim n
				For n=0 To ubound(arrInt)
					If arrShow(arrInt(n)) = 1 Then
						EXPORT_FIELDS = EXPORT_FIELDS & getFieldSql(arrInt(n),arrFelds(arrInt(n)),arrName(arrInt(n)),2)
						allFieldsName =  allFieldsName & "," & arrName(arrInt(n))
						allFieldWidth = allFieldWidth & "," & getFieldWidth(arrInt(n))
					end if
				next
			else
				EXPORT_FIELDS = EXPORT_FIELDS & "a.name [姓名],"
				EXPORT_FIELDS = EXPORT_FIELDS & "a.sex [性别],"
				EXPORT_FIELDS = EXPORT_FIELDS & "a.age [年龄],"
				EXPORT_FIELDS = EXPORT_FIELDS & "a.part1 [部门],"
				EXPORT_FIELDS = EXPORT_FIELDS & "a.job [职务],"
				EXPORT_FIELDS = EXPORT_FIELDS & "a.phone [办公电话],"
				EXPORT_FIELDS = EXPORT_FIELDS & "a.fax [传真],"
				EXPORT_FIELDS = EXPORT_FIELDS & "a.mobile [手机],"
				EXPORT_FIELDS = EXPORT_FIELDS & "a.mobile2 [手机2],"
				EXPORT_FIELDS = EXPORT_FIELDS & "a.email [电子邮件],"
				EXPORT_FIELDS = EXPORT_FIELDS & "a.qq [QQ],"
				EXPORT_FIELDS = EXPORT_FIELDS & "a.weixinAcc [微信号],"
				EXPORT_FIELDS = EXPORT_FIELDS & "a.msn [MSN],"
				EXPORT_FIELDS = EXPORT_FIELDS & "a.phone2 [家庭电话],"
				allFieldsName = allFieldsName & ",姓名,性别,年龄,部门,职务,办公电话,传真,手机,手机2,电子邮件,QQ,微信号,MSN,家庭电话"
				allFieldWidth = allFieldWidth & ",80,80,80,80,,110,110,110,110,110,110,110,110,110"
			end if
			EXPORT_FIELDS = EXPORT_FIELDS & "a.address [家庭地址],"
			EXPORT_FIELDS = EXPORT_FIELDS & "a.tezheng [明显特征],"
			EXPORT_FIELDS = EXPORT_FIELDS & "a.joy [爱好特长],"
			EXPORT_FIELDS = EXPORT_FIELDS & "a.intro [备注],"
			allFieldsName =  allFieldsName & ",家庭地址,明显特征,爱好特长,备注"
			allFieldWidth = allFieldWidth & ",205,205,205,245"
			Dim strGLName,strCGName
			if s3=1 Then
				strGLName="isnull(t.name,'') [关联客户],"
				strCGName="isnull(gt.name,'') [销售人员],"
				allFieldsName =  allFieldsName & ",关联客户"
			else
				strGLName="isnull(t.name,'') [关联供应商],"
				strCGName="isnull(gt.name,'') [采购人员],"
				allFieldsName =  allFieldsName & ",关联供应商"
			end if
			EXPORT_FIELDS = EXPORT_FIELDS & strGLName
			allFieldWidth = allFieldWidth & ",205"
			if ZBRuntime.MC(12002) then
				EXPORT_FIELDS = EXPORT_FIELDS & "gj.rpType [跟进方式],"
				EXPORT_FIELDS = EXPORT_FIELDS & "convert(varchar,gj.date7,120) + '：' + gj.intro [洽谈进展],"
				EXPORT_FIELDS = EXPORT_FIELDS & "gj.rpType [跟进方式],"
				EXPORT_FIELDS = EXPORT_FIELDS & strCGName
				if s3=1 then
					allFieldsName =  allFieldsName & ",跟进方式,洽谈进展,销售人员"
				else
					allFieldsName =  allFieldsName & ",跟进方式,洽谈进展,采购人员"
				end if
				allFieldWidth = allFieldWidth & ",205,245,80"
			else
				EXPORT_FIELDS = EXPORT_FIELDS & strCGName
				if s3=1 then
					allFieldsName =  allFieldsName & ",销售人员"
				else
					allFieldsName =  allFieldsName & ",采购人员"
				end if
				allFieldWidth = allFieldWidth & ",80"
			end if
			EXPORT_FIELDS = EXPORT_FIELDS & "a.date7 [添加时间]"
			allFieldsName =  allFieldsName & ",添加时间"
			allFieldWidth = allFieldWidth & ",165"
			Set rs=conn.execute("select short_str from dbo.split('"&Replace(allFieldsName,"'","''")&"',',') group by short_str having count(*)>1")
			If rs.eof = False Then
				Response.write "" & vbcrlf & "<script>" & vbcrlf & "     parent.jQuery('#lvw_xls_proc_bar').hide();" & vbcrlf & "      alert(""【"
				Response.write rs(0)
				Response.write "】字段名称重复，请修改后再导出"");" & vbcrlf & "</script>" & vbcrlf & ""
				rs.close
				conn.close
				Response.end
			end if
			Dim SQL, BC
			Dim px_Result , Str_Result
			Set BC = server.createobject(ZBRLibDLLNameSN & ".Base64Class")
			px_Result = BC.SafeDeCode(request.form("px_v"))
			px_Result = replace(px_Result ,"tel.","t.")
			Str_Result = BC.safeDeCode(request.form("Str_Result_v"))
			Set BC = nothing
			SQL = "select a.ord 联系人ID,"&EXPORT_FIELDS&" from person a " & vbcrlf &_
			" inner join (select a.ord as t_oid from person a  left join tel WITH(NOLOCK) on a.company=tel.ord where 1=1 " & Str_Result &") xx on xx.t_oid=a.ord " & vbcrlf &_
			"left join tel t on t.ord=a.company "& vbcrlf &_
			"left join gate gt on gt.ord=t.cateid "& vbcrlf &_
			"left join sort9 st9 on st9.ord=a.role "& vbcrlf &_
			"left join (" & vbcrlf &_
			"Select distinct ssc.sort1 rpType,cast(ssb.intro as varchar(8000)) as intro,ssb.ord2,ssb.date7 From ("&vbcrlf &_
			"select max(id) as id from (SELECT ord2, max(date7) as date7 FROM reply where sort1=8 GROUP BY ord2) x inner join  reply y on y.sort1=8 and x.date7=y.date7 and x.ord2=y.ord2 group by  y.ord2  "&vbcrlf&_
			") ssa " & vbcrlf &_
			"inner join reply ssb on ssa.id=ssb.id " & vbcrlf &_
			"inner join sortonehy ssc on ssc.ord=ssb.sort98 "&vbcrlf &_
			") gj on gj.ord2=a.ord " & vbcrlf & px_Result
			Dim adapter
			Dim sqls,sheetSetting,i,item
			Set adapter = New ExcelExportAdapter
			adapter.fileName = "联系人资料"
			Set sheetSetting = New SqlSoruce
			sheetSetting.sql = SQL
			sheetSetting.title = "联系人资料"
			Dim hd,arrFieldNames,arrFieldWidth
			arrFieldNames = Split(allFieldsName,",")
			arrFieldWidth = Split(allFieldWidth,",")
			For i = 1 To ubound(arrFieldNames)
				Set hd = New HeaderColumnSetting
				hd.dbname = arrFieldNames(i)
				hd.cansum = False
				hd.dbtype = "str"
				If arrFieldWidth(i)<>"" Then
					hd.width = arrFieldWidth(i)
				end if
				If arrFieldNames(i)="备注" Then
					hd.width = EX_WIDTH_MULTILINE
					hd.Formula = "noHTML(rs("""&arrFieldNames(i)&"""))"
				end if
				sheetSetting.headerSettings.add(hd)
			next
			Set hd = New HeaderColumnSetting
			hd.dbname = "联系人ID"
			hd.display = "none"
			sheetSetting.headerSettings.add(hd)
			adapter.sqls.add(sheetSetting)
			adapter.export
		end sub
		function noHTML(str)
			dim re
			Set re=new RegExp
			re.IgnoreCase =true
			re.Global=True
			re.Pattern="(\<.[^\<]*\>)"
			str=re.replace(str&"","")
			noHtml=str
			set re=nothing
		end function
		Function getFieldWidth(idx)
			Select Case idx
			Case 17,27,30 : getFieldWidth="80"
			Case 18,19,20,21,22,23,24: getFieldWidth="110"
			Case 31,32 : getFieldWidth="80"
			Case Else
			getFieldWidth = ""
			End Select
		end function
		Function getFieldSql(gate1,fieldValue,nameValue,sortValue)
			Select Case gate1
			Case 17: getFieldSql = "a.name ["&nameValue&"],"
			Case 26: getFieldSql = "isnull(t.faren,'') [" & nameValue & "],"
			Case 29: getFieldSql = "isnull(st9.sort1,'') [" & nameValue & "],"
			Case Else
			getFieldSql = "a." & fieldValue & " as [" & nameValue & "],"
			End Select
		end function
		
%>
