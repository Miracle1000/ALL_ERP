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
				'sql = sql & "CREATE TABLE " & tname & "(" & vbcrlf
				sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
				If i <  rs.fields.count -1 Then sql = sql & "," & vbcrlf
				'sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
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
				'sql = sql & "CREATE TABLE " & tname & "(" & vbcrlf
				sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
				If i <  rs.fields.count -1 Then sql = sql & "," & vbcrlf
				'sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
			next
			if CreateAutoField = true then
				sql = sql & ",[autokeyindex] [int] IDENTITY(1,1) NOT NULL" & vbcrlf
			end if
			sql = sql & ")" & vbcrlf
			sql = sql & "insert into " & tname & "("
			For i = 0 To rs.fields.count -1
				'sql = sql & "insert into " & tname & "("
				sql = sql  & "[" & rs.fields(i).name & "]"
				If i <  rs.fields.count -1 Then sql = sql & ","
				'sql = sql  & "[" & rs.fields(i).name & "]"
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
				'sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
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
				' Call retrieveSys(vPath)
				' Call JmgToUrl(redirectURL)
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
		' if len(Application("_ZBM_Lib_Cache") & "") = 0 then
		' 	Dim z : Set z = server.createobject(ZBRLibDLLNameSN & ".Library")
		' 	z.GetLibrary "ZBIntel2013CheckBitString"
		' end if
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
		If ZBRuntime.loadOK Then
			ZBRuntime.getLibrary "ZBIntel2013CheckBitString"
			If ZBRuntime.loadOK then
				if app.isMobile then
					response.clear
					response.CharSet = "utf-8"
					response.clear
					Response.BinaryWrite app.base64.UnicodeToUtf8("系统【服务端】未正常启动，请检查服务器环境是否正常。")
					Response.end
				else
					Response.write "<script>top.window.location.href ='" & app.virpath & "index2.asp?id2=8'</script>"
				end if
				Set app = Nothing
				Set ZBRuntime = Nothing
				Exit Sub
			end if
		end if
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
	Class IcoItem
		Public index
		Public text
		Public url
		Public linktype
		Public image
		Public tag
		Public clickScript
		Public parent
		Public hide
		Public root
		Sub Class_Initialize()
			Set parent = Nothing
			Set root = Nothing
			hide = 0
		end sub
	End Class
	Class IcoCollection
		Dim list
		Public count
		Public parent
		Public root
		public default function Item(index)
			If count = 0 Then
				Set item = nothing
			else
				Set item = list(index-1)
'Set item = nothing
			end if
		end function
		Public function add(txt,url,linktype,image)
			Dim n
			ReDim Preserve list(count)
			Set list(count) = New IcoItem
			Set n =  list(count)
			Set n.parent = Me
			Set n.root = parent
			n.Text =  txt
			n.image = image
			n.linktype = linktype
			n.url = url
			count = count + 1
'n.url = url
			Set add = n
		end function
		Public function delete(index)
			Dim i
			If index < 0 Or index > count-1 Then
'Dim i
				app.showerr "", "IcoCollection.delete(index)下标越界, index=" & index
			end if
			For i = index-1 To count-2
'app.showerr "", "IcoCollection.delete(index)下标越界, index=" & index
				Set list(i) = list(i+1)
				app.showerr "", "IcoCollection.delete(index)下标越界, index=" & index
			next
			count = count - 1
'app.showerr "", "IcoCollection.delete(index)下标越界, index=" & index
			ReDim Preserve list(count)
		end function
		Public function swapItem(index1,index2)
			Dim n
			Set n = list(index1-1)
'Dim n
			Set list(index1-1) = list(index2-1)
'Dim n
			Set list(index2-1) = n
'Dim n
		end function
		Private Sub Class_Initialize()
			count = 0
			ReDim list(0)
		end sub
	End Class
	Class GroupItem
		Public index
		Public text
		Public image
		Public tag
		Public items
		Public root
		Public parent
		Private Sub Class_Initialize()
			Set items = New IcoCollection
			Set items.parent = me
		end sub
	End Class
	Class GroupCollection
		Dim list
		Public count
		Public parent
		public default function Item(index)
			If count = 0 Then
				Set item = nothing
			else
				Set item = list(index-1)
'Set item = nothing
			end if
		end function
		Public function add(txt,image)
			Dim n
			ReDim Preserve list(count)
			Set list(count) = New GroupItem
			Set n =  list(count)
			Set n.parent = Me
			Set n.root = parent
			n.Text =  txt
			n.image = image
			count = count + 1
'n.image = image
			Set add = n
		end function
		Public function delete(index)
			Dim i
			If index < 0 Or index > count-1 Then
'Dim i
				app.showerr "", "GroupCollection.delete(index)下标越界, index=" & index
			end if
			For i = index-1 To count-2
				app.showerr "", "GroupCollection.delete(index)下标越界, index=" & index
				Set list(i) = list(i+1)
'app.showerr "", "GroupCollection.delete(index)下标越界, index=" & index
			next
			count = count - 1
			app.showerr "", "GroupCollection.delete(index)下标越界, index=" & index
			ReDim Preserve list(count)
		end function
		Public Sub swapItem(index1,index2)
			Dim n
			Set n = list(index1-1)
'Dim n
			Set list(index1-1) = list(index2-1)
'Dim n
			Set list(index2-1) = n
'Dim n
		end sub
		Private Sub Class_Initialize()
			count = 0
			ReDim list(0)
		end sub
	End Class
	Class IcoView
		Public id
		Public groups
		Public tag
		Public size
		Public lineSpace
		Public CellSpace
		Public ItemWidth
		Public ItemHeight
		Private htmls
		Public canConfig
		Public editmode
		Public icoAlign
		Public onlyImage
		Public csstext
		Private w_i
		Private function w(htmltext)
			ReDim Preserve htmls(w_i)
			htmls(w_i) = htmltext
			w_i = w_i + 1
'htmls(w_i) = htmltext
		end function
		Private sub wHtmlGroup(i)
			Dim n, ii
			Set n = groups(i)
			w "<div class='ivw_group' onmousedown='__ivw_G_dragBegin(this,""" & id & """)' id='ivw_" & id & "_g_" & i & "' t=""" & n.Text & """ d=""" & n.tag & """><div class='ivw_group_txt'"
			If Len(n.image) > 0 Then
				w " style='background:transparent url(" & n.image & ") no-repeat 5px center;padding-left:32px;padding-top:2px'"
'If Len(n.image) > 0 Then
			end if
			w  ">" & n.Text & "</div>"
			If canconfig Then
				w "<div style='float:right;padding:0px;height:30px'>"
				w "<div class='newico_st' onmousedown='return " & id & "_groupEditItem(""" & n.Text & """,""" & n.tag & """)' title='修改' src='../skin/" & Info.skin & "/images/newico_st.gif' onmouseover='app.swimg(this)' onmouseout='app.swimg(this)' style='cursor:pointer'></div>"
				If i > 1 Then
					w "<div class='newico_m_h' onmousedown='return " & id & "_onivwGroupMv(this," & (i-1) & ")' title='上移' src='../skin/" & Info.skin & "/images/newico_m_h.gif' onmouseover='app.swimg(this)' onmouseout='app.swimg(this)' style='cursor:pointer'></div>"
'If i > 1 Then
				end if
				If i < groups.count Then
					w "<div class='newico_m_v' onmousedown='return " & id & "_onivwGroupMv(this," & (i+1) & ")' title='下移' src='../skin/" & Info.skin & "/images/newico_m_v.gif' onmouseover='app.swimg(this)' onmouseout='app.swimg(this)' style='cursor:pointer'></div>"
'If i < groups.count Then
				end if
				w "<div class='newico_cle' onmousedown='" & id & "_onivwGroupDel(this," & (i+1) & ")' title='删除' src='../skin/" & Info.skin & "/images/newico_cle.gif' onmouseover='app.swimg(this)' onmouseout='app.swimg(this)' style='margin-top:3px;cursor:pointer'></div>"
'If i < groups.count Then
				w "&nbsp;</div>"
			end if
			w "</div>"
			w "<div class='ivw_groupchild' id='ivw_" & id & "_gbg_" & i & "' db='" & app.iif(Len(n.tag)>0,n.tag,n.Text) & "'>"
			If app.isIe6 Then
				w "<br style='font-size:1px;'>"
'If app.isIe6 Then
			end if
			For ii = 1 To n.items.count
				Call wHtmlIco(n.items(ii), i, ii)
			next
			If canConfig then
				w "<div class='lastitem ivw_item' onmouseover='app.swpCss(this)' onmouseout='app.swpCss(this)' style='position:static;margin-top:" & lineSpace & "px;margin-left:" & CellSpace & "px;width:" & itemwidth & "px;height:" & itemheight & "px' islast=1><table class='fulltb'><tr><td><div class='ivw_item_add' onclick='" & id & "_IcoItemAddClick(""" & n.Text & """,""" & n.tag & """)' title='点击添加新导航' ></div></td></tr></table></div>"
			end if
			w "<div style='clear:all;height:" &  clng(lineSpace*1) & "px;overflow:hidden;width:100%'></div></div>"
		end sub
		Private Sub wHtmlIco(item, gindex, iindex)
			Dim h, imgclick
			w "<div class='ivw_item"
			If item.hide = 1 Then w " lastitem"
			w "' tag=""" & item.tag & """ onmousedown='__ivw_dragBegin(this,""" & id & """)' onmouseover='app.swpCss(this)' onmouseout='app.swpCss(this)' id='ivw_item_" & id & "_" & gindex & "_" & iindex & "' style='margin-top:" & lineSpace & "px;margin-left:" & CellSpace & "px;width:" & itemwidth & "px;height:" & itemheight & "px'>"
			If Len(item.clickScript) = 0 Then
				Select Case item.linktype
				Case 0 : imgclick = "onclick='window.open(""" & item.url & """)'"
				Case 1 : imgclick = "onclick='window.open(""" & item.url & """,""_self"")'"
				Case Else
				imgclick = "onclick='window.open(""" & item.url & ""","""",""toolbar=0,resizable=1,scrollbars=1,width=1200,height=""+(screen.availHeight-40)+"",top=5"")'"
'Case Else
				End select
			else
				imgclick = "onclick='" & item.clickScript & "'"
			end if
			If Len(item.image) > 0 Then
				If icoAlign = "left" Then
					h = itemheight
					w "<div class='ivw_item_ico' " & imgclick & " style='background-image:url(" & item.image & ");width:" & size+2 & "px;height:" & h & "px'></div>"
'h = itemheight
				else
					h = (itemheight-27)
'h = itemheight
					w "<div class='ivw_item_ico' " & imgclick & " style='background-image:url(" & item.image & ");width:100%;height:" & h & "px;'></div>"
'h = itemheight
				end if
			end if
			If canConfig then
				w "<div class='ivw_item_tol' style='margin-top:-" & h & "px'><input type=button title='设置属性' onclick='return __ivw_onattritem(""" & id & """,this)' onmouseout='app.swpCss(this)' onmouseover='app.swpCss(this)' class='ivw_item_attr'>"
'If canConfig then
				w "<input type=button title='删除' onclick='return __ivw_ondelitem(""" & id & """,this)' onmouseout='app.swpCss(this)' onmouseover='app.swpCss(this)' class='ivw_item_del'></div>"
			end if
			If onlyImage = False  Then
				w "<div class='ivw_item_txt'"
				If icoAlign = "left" then
					w " style='width:" & (itemwidth-size-4) & "px;height:100%'"
'If icoAlign = "left" then
				else
					w " style='height:26px;width:100%;'"
				end if
				w "><table class='fulltb'><tr><td id='ivw_t_" & id & "_" & gindex & "_" & iindex & "'"
'If icoAlign = "left" Then
				w " align='left'>"
			else
				w " align='center' title=""" & item.text & """>"
			end if
			If Len(item.clickScript) = 0 Then
				Select Case item.linktype
				Case 0 : w "<a href='" & item.url & "' target=_blank>" & item.text & "</a>"
				Case 1 : w "<a href='" & item.url & "'>" & item.text & "</a>"
				Case Else
				w "<a href='javascript:void(0)' onclick='window.open(""" & item.url & ""","""",""toolbar=0,resizable=1,scrollbars=1,width=1200,height=""+(screen.availHeight-40)+ "",top=5"")'>" & item.text & "</a>"
'Case Else
				End select
			else
				w "<a href='javascript:void(0)' onclick='" & item.clickScript & "'>" & item.text & "</a>"
			end if
			w "</td></tr></table></div>"
			If canConfig then
				w "<div class='ivw_itemedit_txt'"
				If icoAlign = "left" then
					w " style='width:" & (itemwidth-size-4) & "px;height:100%'"
'If icoAlign = "left" then
				else
					w " style='height:26px;width:100%;'"
				end if
				w "><table class='fulltb'><tr><td id='ivw_et_" & id & "_" & gindex & "_" & iindex & "'"
'If icoAlign = "left" Then
				w " align='left'>"
			else
				w " align='center'>"
			end if
			w "<a href='javascript:void(0)' onclick='return __onicoitemEdit(""" & id & """, this)'>" & item.text & "</a>"
			w "</td></tr></table></div>"
'end if
'end if
			w "</div>"
		end sub
		Public Property Get Html
		Dim i
		w_i = 0
		ReDim htmls(0)
		If editmode = 0 then
			w "<div class='icoview' id='icoview_" & id & "'>"
		else
			w "<div class='icoviewedit' id='icoview_" & id & "'>"
		end if
		For i = 1 To groups.count
			Call wHtmlGroup(i)
		next
		If canConfig Then
			w "<div style='clear:both;margin-top:4px' class='lstgrp'><div style='height:5px;overflow:hidden'>&nbsp;</div><div class='ivw_groupchild' style='padding-top:5px;padding-bottom:10px;'><div class='ivw_groupadd'><div style='padding-left:52px;cursor:pointer;' onclick='if(window." & id & "_onAddGroup){return " & id & "_onAddGroup();}'><a href='javascript:void(0)' style='color:#395294;font-size:16px;font-weight:bold'>添加新栏目</a></div></div></div></div>"
'If canConfig Then
		end if
		w "</div>"
		html = Join(htmls,"")
		End  Property
		Private Sub Class_Initialize()
			icoAlign = "top"
			onlyImage = false
			ItemHeight = 54
			ItemWidth = 90
			size = 32
			CellSpace = 2
			lineSpace = 6
			Set groups = New GroupCollection
			Set groups.parent = Me
			canConfig = false
		end sub
		Private Sub Class_Terminate()
			Set groups = nothing
		end sub
	End Class
	Sub MessagePost(id)
		Select Case id
		Case ""
		Call Page_Load
		Case "editgroup"
		Call app_editGroup
		Case "savecls"
		Call app_savecls
		Case "DoRefresh"
		Call loadicoview
		Case "editLinkItem"
		Call editLinkItem
		Case "urlsorce"
		Call app_urlsorce
		Case "saveLinkItem"
		Call App_saveLinkItem
		Case "delLinkItem"
		Call App_delLinkItem
		Case "hyLinkItem"
		Call App_hyLinkItem
		Case "saveLinkItemText"
		Call saveLinkItemText
		Case "updateIcoPos"
		Call updateIcoPos
		Case "updateGroupPos"
		Call updateGroupPos
		Case "groupHide"
		Call groupHide
		Case "hfSysIcoItem"
		Call hfSysIcoItem
		Call App_saveLinkItem
		Case "dragGroupEnd"
		Call dragGroupEnd
		End select
	end sub
	Sub Page_Load
		app.addDefaultScript
		app.docmodel = "IE=8"
		Response.write app.defheadhtml("../","")
		Response.write "" & vbcrlf & "<body id=""hmainbody"">" & vbcrlf & "<div style='position:absolute;top:0px;left:0px;width:100%'>" & vbcrlf & "        <style style='display:none'>" & vbcrlf & "            html{_overflow-x:hidden;}" & vbcrlf & "               div.groupEditDiv{border:1px solid #c3c7d2; background-color:#f6f6f8;position:relative;top:-3px;overflow:hidden;}" & vbcrlf & "         a.lnk:hover{Text-Decoration:underline;}" & vbcrlf & "         input.usbutton {background-color:white;border:1px solid #c3c7d2;border-bottom:1px solid white;position:absolute;width:64px;height:22px;top:5px;font-size:12px;background-color:white;}" & vbcrlf & "          #usifrm{position:absolute;border:1px solid #c3c7d2;z-index:99;top:26px;left:364px;width:290px;height:420px;}" & vbcrlf & "            .oldbutton{" & vbcrlf & "                     background-color:#FFF;" & vbcrlf & "          }" & vbcrlf & "       </style><input value='进入设置' onmouseout='app.unline(this,0)' onmouseover='app.unline(this,1)' style='background:transparent url(../skin/"
		Response.write Info.skin
		Response.write "/images/ico16/set.gif) no-repeat;padding-top:2px;border:0px;padding-left:18px;font-size:12px;font-family:宋体;color:#555566;cursor:pointer;position:absolute;top:12px;right:5px;_right:10px;width:80px;text-align:left;display:none' onclick='changeModel(this)' type='button'><div style='margin-left:30px;margin-right:10px;border-top:0px;clear:both;_margin-right:20px;' id='icosbody'>" & vbcrlf & "          "
		'Response.write Info.skin
		Call loadicoview()
		Response.write "" & vbcrlf & "              <br>" & vbcrlf & "    </div>" & vbcrlf & "</div>" & vbcrlf & "<script>" & vbcrlf & "    try" & vbcrlf & "     {" & vbcrlf & "               if(parent.parent.closeproc)" & vbcrlf & "             {" & vbcrlf & "                       parent.parent.closeproc();" & vbcrlf & "              }" & vbcrlf & "       }" & vbcrlf & "       catch(e){}" & vbcrlf & "</script>" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & "        "
	end sub
	Sub loadicoview
		set rs=server.CreateObject("adodb.recordset")
		sql="select num1 from setjm3 where ord=2017121601"
		rs.open sql,cn,1,1
		scpower=rs("num1")
		Dim ivw , i, rs , rs1 , g , n, tg, icoid, icourl, id
		Dim editmode , imgu, item
		editmode = app.getint("editmode")
		Set ivw = New icoview
		ivw.id = "h"
		ivw.size = 32
		ivw.itemheight = 90
		ivw.canConfig = True
		ivw.editmode = editmode
		cn.cursorlocation = 3
		Set rs = cn.execute(ClsListSql)
		While rs.eof = False
			If rs.fields("del").value & "" <> "1" then
				n = rs.fields("agpname").value & ""
				tg = rs.fields("n").value
				If Len(n) = 0 Then
					n = tg
				end if
				Set g = ivw.groups.add(n,"")
				g.tag = tg
				Set rs1 = cn.execute("select id,title,ISNULL(url,'') url,otype,icoid,icourl,sort,gpname,powerCode,del from home_mainlink_config_fun(" & Info.user & ") a where a.del=0 and a.gpname='" & tg & "' order by a.sort, a.id")
				While rs1.eof = False
					id = rs1.fields("id").value
					icourl = rs1.fields("icourl").value
					icoid = rs1.fields("icoid").value
					If existsLinkPower(rs1.fields("powerCode").value) then
						If Len(icourl) > 0 Then
							imgu = icourl
						else
							If icoid > 0 Then
								imgu = "homelinksico.asp?__msgid=gm&i=" & icoid
							else
								imgu = "homelinksico.asp?__msgid=gm&i=" & id
							end if
						end if
						if(id=24 or id=25) then
						if(scpower=1)then
						Set item = g.items.add(rs1.fields("title").value, "homelinkOpenxy.asp?u=" & server.urlencode(Replace(rs1.fields("url").value,"sys:","")),  rs1.fields("otype").value , imgu)
						item.tag = id
					end if
				else
'Set item = g.items.add(rs1.fields("title").value, "homelinkOpenxy.asp?u=" & server.urlencode(Replace(rs1.fields("url").value,"sys:","")),  rs1.fields("otype").value , imgu)
					item.tag = id
				end if
			end if
			rs1.movenext
		wend
		rs1.close
	end if
	rs.movenext
	wend
	rs.close
	Response.write ivw.html
	end sub
	Function existsLinkPower(code)
		If Len(Trim(code & "")) = 0 Then existsLinkPower = True : Exit Function
		code = Replace(Replace(code,"{","app.power.existsModel("),"}",")",1,-1,1)
		'If Len(Trim(code & "")) = 0 Then existsLinkPower = True : Exit Function
		code = Replace(Replace(code,"[","app.power.existsPower("),"]",")",1,-1,1)
		'If Len(Trim(code & "")) = 0 Then existsLinkPower = True : Exit Function
		code = Replace(code,"@admin","info.isSupperAdmin",1,-1,1)
		If Len(Trim(code & "")) = 0 Then existsLinkPower = True : Exit Function
		code = Replace(Replace(code,"+"," and "),"|"," or ")
		'If Len(Trim(code & "")) = 0 Then existsLinkPower = True : Exit Function
		existsLinkPower = eval(code)
	end function
	Function ClsListSql()
		ClsListSql = "select isnull(a.gpname,b.gpname) as n, b.agpname, b.intro, max(isnull(a.id,0)) as id, b.sort, b.del from dbo.home_mainlink_config_fun(" & Info.user & ") a full join (select * from home_mainlinkcls_config x where x.uid=" & Info.user & ") b on a.gpname=b.gpname where isnull(a.del,0)=0 group by a.gpname,b.gpname, b.agpname, b.intro, b.sort, b.del order by b.sort, n"
	end function
	Function AllClsListSql()
		AllClsListSql = "select isnull(a.gpname,b.gpname) as n, b.agpname, b.intro, max(isnull(a.id,0)) as id, b.sort, b.del from dbo.home_mainlink_config_fun(" & Info.user & ") a full join (select * from home_mainlinkcls_config x where x.uid=" & Info.user & ") b on a.gpname=b.gpname group by a.gpname,b.gpname, b.agpname, b.intro, b.sort, b.del order by b.sort, n"
	end function
	Sub app_editGroup
		Dim nm, rs, v1, v2, v3, v4, ef, id, i, gdel
		nm = app.gettext("nm")
		v1 = ""
		ef = True
		id = 0
		v3 = 0
		Response.write "" & vbcrlf & "<div style='height:330px;overflow:auto;width:180px;border-right:1px solid #c3c7d2;position:absolute;top:0px;left:0px;'>" & vbcrlf & ""
'v3 = 0
		Set rs = cn.execute(ClsListSql)
		If rs.eof = False Then
			Response.write "<ol style='width:130px;_margin-top:10px;'>"
'If rs.eof = False Then
			While rs.eof = False
				If nm = rs.fields(0).value Then
					v1 = nm
					v2 = rs.fields("agpname").value
					v3 = rs.fields("sort").value
					v4 = rs.fields("intro").value
					id = rs.fields("id").value
					gdel = rs.fields("del").value
					ef  = False
					Response.write "<li style='background-color:#e0e0ef'>"
'ef  = False
				else
					Response.write "<li>"
				end if
				Response.write "<a href='javascript:void(0)' class='lnk' onclick=UpdateGroup(""" & Replace(rs.fields(0).value,"""","\""") & """) >" & rs.fields(0).value & "</a></li>"
				rs.movenext
			wend
			Response.write "</ol>"
		else
			Response.write "<br><center>目前还没有分类</center>"
		end if
		rs.close
		If Len(gdel & "") = 0 Then gdel = 0
		Response.write "" & vbcrlf & "</div>" & vbcrlf & "<div style='height:330px;overflow:hidden;width:380px;position:absolute;top:0px;left:181px;'>" & vbcrlf & "   <div style='height:290px;'><br>" & vbcrlf & "         <table style='color:#000;margin-left:20px;table-layout:auto;'>" & vbcrlf & "          <tr>" & vbcrlf & "                    <td height='40px'>分类名称：</td>" & vbcrlf & "                  "
		If id > 0 then
			Response.write "" & vbcrlf & "                     <td><input type='text' id='g_v1' maxlength=20 style='width:220px;background-color:#e0e0e0' readonly value='"
'If id > 0 then
			Response.write v1
			Response.write "'></td>" & vbcrlf & "                      "
		else
			Response.write "" & vbcrlf & "                     <td><input type='text' id='g_v1' maxlength=20 style='width:220px' value='"
			Response.write v1
			Response.write "'></td>" & vbcrlf & "                      "
		end if
		Response.write "" & vbcrlf & "             </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td height='40px'>分类别名：</td>" & vbcrlf & "                       <td><input type='text' id='g_v2' maxlength=20 style='width:220px' value='"
		Response.write v2
		Response.write "'></td>" & vbcrlf & "              </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td height='40px'>排序指数：</td>" & vbcrlf & "                       <td>" & vbcrlf & "                            <select id='g_v3' style='width:60px;'>" & vbcrlf & "                          "
		For i = 0 To 20
			Response.write "<option value='" & i*10 & "'"
			If i*10 = v3 Then Response.write " selected"
			Response.write  ">" & i & "</option>"
		next
		Response.write "" & vbcrlf & "                             </select>" & vbcrlf & "                       </td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td height='5px'></td>" & vbcrlf & "          </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td valign='top'>分类描述：</td>" & vbcrlf & "                        <td>" & vbcrlf & "                            <textarea maxlength=500  id='g_v4' cols=30 rows=6 style='width:220px'>"
		Response.write v4
		Response.write "</textarea>" & vbcrlf & "                          <input type='hidden' id='g_v5' value='"
		Response.write id
		Response.write "'>" & vbcrlf & "                   </td>" & vbcrlf & "           </tr>" & vbcrlf & "           </table>" & vbcrlf & "        </div>" & vbcrlf & "  <div style='background-color:#eaeaef;height:40px;text-align:center;;overflow;hidden;padding-top:10px'>" & vbcrlf & "          <input class='oldbutton' type='button' value='保存' onclick='savecls()'>&nbsp;" & vbcrlf & "               "
		If ef = False Then
			Set rs = cn.execute("select top 1 1 as r from dbo.home_mainlink_config_fun(" & Info.user & ") a where gpname='" & v1 & "'")
			ef = rs.eof
			rs.close
			If ef = False Then
				If gdel = 0 then
					Response.write "<input class='oldbutton' type='button' onclick='groupHide(""" & v1 & """,1)' value='删除'>&nbsp;"
				else
					Response.write "<input class='oldbutton' type='button' onclick='groupHide(""" & v1 & """,2)' value='还原'>&nbsp;"
				end if
			else
				Response.write "<input class='oldbutton' type='button' onclick='groupHide(""" & v1 & """,3)' value='删除'>&nbsp;"
			end if
		end if
		Response.write "" & vbcrlf & "             <input class='oldbutton' type='button' value='取消' onclick='app.closeWindow(""addasxc"");'>" & vbcrlf & "        </div>" & vbcrlf & "</div>" & vbcrlf & ""
	end sub
	Sub app_savecls
		Dim gn, ga, gs, gr, gi, rs, r
		gn = app.gettext("gn")
		ga = app.gettext("ga")
		gs = app.getint("gs")
		gr = app.gettext("gr")
		gi = app.getint("gi")
		Set rs = server.CreateObject("adodb.recordset")
		rs.open "select [gpName],[uid],[del],[sort],[intro],[agpname] from home_mainlinkcls_config where uid=" & Info.User & " and gpname='" & Replace(gn,"'","") & "'" , cn , 1, 3
		If rs.eof = False Then
			r = "修改成功"
		else
			r = "添加成功"
			rs.addnew
			rs.fields("gpname").value = gn
		end if
		rs.fields("agpname").value = ga
		rs.fields("sort").value = gs
		rs.fields("intro").value = gr
		rs.fields("del").value = 0
		rs.fields("uid").value = Info.User
		rs.update
		rs.close
		Response.write r
	end sub
	Sub editLinkItem
		Dim nm, rs, ef, id, i, linkid, eof
		Dim v_id, v_title,v_url, v_icoid, v_icourl, v_sort, v_role
		Dim v_del
		Dim v_gpname, v_powerCode, sysUrl
		nm = app.gettext("gpname")
		id = app.getint("linkid")
		Set rs = cn.execute("select * from home_mainlink_config_fun(" & Info.user & ") a where id=" & id)
		eof = rs.eof
		If rs.eof = False Then
			v_id = id
			v_title = rs.fields("title").value
			v_url = rs.fields("url").value
			v_icoid = rs.fields("icoid").value
			v_icourl = rs.fields("icourl").value
			v_sort = rs.fields("sort").value
			v_gpname = rs.fields("gpname").value
			v_powerCode = rs.fields("powerCode").value
			v_role = rs.fields("role").value
			v_del = rs.fields("del").value
		else
			v_gpname = nm
			v_id  = 0
			v_role = 0
			v_del = 0
		end if
		rs.close
		sysUrl = InStr(v_url,"sys:") = 1
		Response.write "" & vbcrlf & "<!-- width:700 height:500 -->" & vbcrlf & "<div style='height:450px;overflow:hidden;width:360px;border-right:1px solid #c3c7d2;position:absolute;top:0px;left:0px;'>" & vbcrlf & "       <input type='hidden' id='v_id' value='"
'sysUrl = InStr(v_url,"sys:") = 1
		Response.write v_id
		Response.write "'>" & vbcrlf & "   <div style='height:400px;'><br>" & vbcrlf & "         <table style='color:#000;margin-left:20px;table-layout:auto;'>" & vbcrlf & "          <tr>" & vbcrlf & "                    <td height='30px'>导航名称：</td>" & vbcrlf & "                       <td><input type='text' id='v_title' maxlength=20 style='width:220px' value='"
		'Response.write v_id
		Response.write v_title
		Response.write "'></td>" & vbcrlf & "              </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td height='30px'>导航网址：</td>" & vbcrlf & "                       <td>" & vbcrlf & "                            <input type='hidden' id='v_url' maxlength=500 style='width:220px' value='"
		Response.write v_url
		Response.write "'>" & vbcrlf & "                           "
		If sysUrl = True then
			Response.write "" & vbcrlf & "                                     <input type='text' id='v_url_txt' readonly onblur='updateUrlText()' maxlength=500 style='width:220px;color:#666' value='系统路径,不可编辑'>" & vbcrlf & "                             "
		else
			Response.write "" & vbcrlf & "                                     <input type='text' id='v_url_txt' onblur='updateUrlText()' maxlength=500 style='width:220px' value="""
			Response.write v_url
			Response.write """>" & vbcrlf & "                                "
		end if
		Response.write "" & vbcrlf & "                             <input type='hidden' id='v_powerCode' onblur='updateUrlText()' maxlength=500 style='width:220px' value="""
		Response.write v_powerCode
		Response.write """>" & vbcrlf & "                        </td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td style='height:10px'></td>" & vbcrlf & "                   <td style='height:10px;color:red;line-height:12px;'>请从右侧选择系统导航<br>自定义网址请以""http://""开头</td>" & vbcrlf & "              </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td height='30px'>排序指数：</td>" & vbcrlf & "                   <td>" & vbcrlf & "                            <select id='v_sort' style='width:60px;'>" & vbcrlf & "                                "
		For i = 0 To 30
			Response.write "<option value='" & i*10 & "'"
			If i*10 = v_sort Then Response.write " selected"
			Response.write  ">" & i & "</option>"
		next
		Response.write "" & vbcrlf & "                             </select>" & vbcrlf & "                       </td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td height='30px'>所属分类：</td>" & vbcrlf & "                       <td>" & vbcrlf & "                            <select id='v_gpname'>" & vbcrlf & "                          "
		Set rs =  cn.execute(AllClsListSql())
		If rs.eof = False then
			While rs.eof = False
				Response.write "<option value='" & rs.fields("n").value & "'"
				If v_gpname = rs.fields("n").value  Then
					Response.write " selected"
				end if
				Response.write ">"
				If Len(Trim(rs.fields("agpname").value & "")) > 0 Then
					Response.write rs.fields("agpname").value
				else
					Response.write rs.fields("n").value
				end if
				Response.write "</option>"
				rs.movenext
			wend
		else
			Response.write "<option value='无分类'>无分类</option>"
		end if
		rs.close
		Response.write "" & vbcrlf & "                             </select>" & vbcrlf & "                       </td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr><td colspan=2>" & vbcrlf & "              <input type='hidden' id='v_icourl' value='"
		Response.write v_icourl
		Response.write "'>" & vbcrlf & "           <input type='hidden' id='v_icoid' value='"
		Response.write v_icoid
		Response.write "'>" & vbcrlf & "           "
		Dim imgurl
		If Len(v_icourl) > 0 Then
			imgurl = v_icourl
		else
			If v_icoid > 0 Then
				imgurl = "homelinksIco.asp?__msgid=gm&i=" & v_icoid
			else
				imgurl = "homelinksIco.asp?__msgid=gm&i=" & v_id
			end if
		end if
		Response.write "" & vbcrlf & "             <fieldSet style='width:290px;height:150px'><legend>导航图标：</legend>" & vbcrlf & "                  <div>" & vbcrlf & "                           <div style='float:right;width:150px;height:70px;'>" & vbcrlf & "                                      <div style='margin-top:20px;margin-left:5px;'>" & vbcrlf & "                                  <!-- <input  style='height:20px;line-height:12px;font-size:12px' value='选择已有图标' type='button'>" & vbcrlf & "                                       <div style='height:4px;overflow:hidden'></div> -->" & vbcrlf & "                                      <input  style='height:20px;line-height:12px;font-size:12px' onclick='getWebIcoUrl()' value='使用网络图标' type='button'>" & vbcrlf & "                                        </div>" & vbcrlf & "                          </div>" & vbcrlf & "                              <div style='padding-top:6px'>" & vbcrlf & "                                   <table align='center' style='border:1px dashed #acaab2;width:72px;height:70px;background-color:white'>" & vbcrlf & "                                  <tr>" & vbcrlf & "                                            <td align='center' valign='center'>" & vbcrlf & "                                                     <img src='"
'imgurl = "homelinksIco.asp?__msgid=gm&i=" & v_id
		Response.write imgurl
		Response.write "' id='img_url' style='max-height:64px;max-width:64px;_height:64px;_width:64px'>" & vbcrlf & "                                              </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   </table>" & vbcrlf & "                                </div>" & vbcrlf & "                  </div>" & vbcrlf & "                  <div style='height:16px;overflow:hidden'></div>" & vbcrlf & "                 <div style='clear:both;background-color:#f0f0f0;border-top:1px solid #d0d0d0;padding-top:8px;padding-bottom:8px;_padding-bottom:6px;'>" & vbcrlf & "                         <center>" & vbcrlf & "                                        <form id='icoupfrm' action='homelinksIco.asp?__msgId=upTemp' method='post' target='icotmpiframe' enctype='multipart/form-data' style='display:inline'>" & vbcrlf & "                                  本地上传：<input type=file style='font-size:12px;width:210px' name='icofile' onchange='this.form.submit()'>" & vbcrlf & "                                     <iframe style='width:1px;height:1px;display:inline' frameborder=0 name='icotmpiframe' onaaload='app.Alert(this.contentWindow.document.documentElement.outerHTML)'></iframe>" & vbcrlf & "                                       </form>" & vbcrlf & "                         </center>" & vbcrlf & "                       </div>" & vbcrlf & "          </fieldset>" & vbcrlf & "             <div style='height:8px;overflow:hidden'></div>" & vbcrlf & "          <ol style='color:red'><li>支持上传的图标格式为jpg, gif, png 和 bmp。</li><li>上传图标大小需小于10kb。</li></ol>"& vbcrlf & "              </td></tr>" & vbcrlf & "              </table>" & vbcrlf & "        </div>" & vbcrlf & "  <div style='background-color:#eaeaef;height:40px;text-align:center;;overflow;hidden;padding-top:10px'>" & vbcrlf & "          "
		'Response.write imgurl
		If v_del=1 Then
			If v_role=3 then
				Response.write "<input class='oldbutton' type='button' value='添加' onclick='hfSysIcoItem(" & v_id & ");'>&nbsp;"
			else
				Response.write "<input class='oldbutton' type='button' value='添加' onclick='hfSysIcoItem(" & v_id & ");'>&nbsp;"
			end if
		else
			Response.write "<input class='oldbutton' type='button' value='保存' onclick='saveLinkItem()'>&nbsp;"
			If ef = False Then
				Response.write "<input class='oldbutton' type='button' value='删除' onclick='delIcoItem(" & v_id & ");attrIcoItem(" & v_id & ")'>&nbsp;"
			end if
			If v_id < 10000 And v_role=3 then
				Response.write "<input class='oldbutton' type='button' value='还原' onclick='hyIcoItem(" & v_id & ");attrIcoItem(" & v_id & ")'>&nbsp;"
			end if
		end if
		Response.write "" & vbcrlf & "             <input class='oldbutton' type='button' value='关闭' onclick='app.closeWindow(""linksedit"");'>" & vbcrlf & "      </div>" & vbcrlf & "</div>" & vbcrlf & "<input type='hidden' value='"
		Response.write v_powerCode
		Response.write "' id='v_powerCode'>" & vbcrlf & "<input type='button' id='usbutton1' onclick='usbuttonClick(1)' class='usbutton' style='z-Index:100;left:368px' value='常用报表'>" & vbcrlf & "<input type='button' id='usbutton2' onclick='usbuttonClick(2)' class='usbutton' style='left:435px;background-color:#f2f2f2'value='左侧导航'>" & vbcrlf & "<iframe src='?__msgid=urlsorce&t=1' id='usifrm' frameborder=0 onload='urlsorceiframeLoad()'></iframe>" & vbcrlf & "<div style='position:absolute;left:560px;top:6px;color:#000;'>选择系统导航</div>" & vbcrlf & ""
	end sub
	Function convertPowerUrl(ByVal v)
		Dim ls, i
		If instr(v,"LM:")=1 Then
			v = Replace(v,"LM:;;","")
			v = Replace(v,"LM:","")
			ls = Split(v,";;")
			For i = 0 To ubound(ls)
				If ls(i) = "***" Then
					ls(i) = "@admin"
				else
					If Len(Trim(ls(i))) > 0 then
						ls(i) = app.base64.decode(ls(i))
						ls(i) = Replace(Replace(ls(i), "app.power.existsModel(","{"),")","}")
						ls(i) = Replace(ls(i), "or","|",1,-1,1)
'ls(i) = Replace(Replace(ls(i), "app.power.existsModel(","{"),")","}")
						ls(i) = Replace(ls(i), "and","+",1,-1,1)
'ls(i) = Replace(Replace(ls(i), "app.power.existsModel(","{"),")","}")
						ls(i) = Replace(ls(i), "【","(")
						ls(i) = Replace(ls(i), "】",")")
						ls(i) = Replace(ls(i), "info.isSupperAdmin","@admin",1,-1,1)
'ls(i) = Replace(ls(i), "】",")")
						ls(i) = Replace(ls(i),Chr(0),"")
						If  Len(Trim(ls(i))) > 0 then
							ls(i) = "(" & Trim(ls(i)) & ")"
						else
							ls(i) = "true"
						end if
					else
						ls(i) = "true"
					end if
				end if
			next
			convertPowerUrl = Join(ls, "+")
			ls(i) = "true"
		else
			convertPowerUrl = v
		end if
	end function
	Sub App_saveLinkItem
		dim v_id            : v_id = app.getint("v_id")
		dim v_title         : v_title = app.getText("v_title")
		dim v_url           : v_url = app.getText("v_url")
		dim v_sort          : v_sort = app.getint("v_sort")
		dim v_gpname        : v_gpname = app.getText("v_gpname")
		dim v_icourl        : v_icourl = app.getText("v_icourl")
		dim v_icoid         : v_icoid = app.getint("v_icoid")
		dim v_icotype       : v_icotype = app.getText("v_icotype")
		Dim v_powerCode : v_powerCode = app.gettext("v_powerCode")
		If v_id = 0 Then v_id = app.getint("id")
		Dim rs , r , icodat
		Dim del , otp , role, intro
		Set rs = server.CreateObject("adodb.recordset")
		If v_id = 0 Then v_id = -100
'Set rs = server.CreateObject("adodb.recordset")
		Set rs = cn.execute("select id, role from home_mainlink_config_fun(" & Info.user & ") a where id=" &  v_id)
		If rs.eof = False then
			role = rs.fields("role").value
		else
			role = -100
'role = rs.fields("role").value
		end if
		rs.close
		v_powerCode = convertPowerUrl(v_powerCode)
		If role <> -100 And role<>3 Then
'v_powerCode = convertPowerUrl(v_powerCode)
			cn.execute "INSERT INTO home_mainlink_config(id,role,uid,title,url,otype,icodata,icosize,icotype,icoId,icourl,sort,gpname,del,intro,powerCode) " & vbcrlf & _
			"select id,3," & Info.user & ",title,url,otype,icodata,icosize,icotype,icoId,icourl,sort,gpname,0,intro,powerCode from home_mainlink_config where id=" & v_id & " and role=" & role
			role = 3
		end if
		rs.open "select id,role,uid,title,url,otype,icodata,icosize,icotype,icoId,icourl,sort,gpname,del,intro,powerCode from home_mainlink_config where id=" & v_id & " and role=" & role & " and (uid=" & Info.User & " or role<>3)", cn, 1, 3
		If rs.eof = True Then
			rs.addnew
			rs.fields("id").value = getMaxId()
			rs.fields("role").value = 3
			rs.fields("otype").value = 2
			rs.fields("del").value = 0
			rs.fields("intro").value = ""
			rs.fields("uid").value = Info.user
			r = "添加成功"
		else
			If rs.fields("role").value <> 3 Then
				del = rs.fields("del").value
				otp = rs.fields("otype").value
				intro = rs.fields("intro").value
				rs.addnew
				rs.fields("id").value = v_id
				rs.fields("uid").value = Info.User
				rs.fields("role").value = 3
				rs.fields("otype").value = otp
				rs.fields("del").value = del
				rs.fields("intro").value = intro
			end if
			r = "修改成功"
			If app.getint("id")>0 Then r = "添加成功"
		end if
		rs.fields("title").value = v_title
		rs.fields("url").value = v_url
		rs.fields("gpname").value = v_gpname
		rs.fields("icoid").value = v_icoid
		rs.fields("icourl").value = v_icourl
		rs.fields("sort").value = v_sort
		rs.fields("powerCode").value = v_powerCode
		If Len(v_icourl) = 0 And v_icoid = 0 Then
			If Len(v_icotype) > 0 Then
				Call updateImageField(rs, v_icotype)
			else
				If rs.fields("icosize").value = 0 Or "" & rs.fields("icosize").value = "" Then
					rs.fields("icourl").value  = "../images/hmlnk.gif"
				end if
			end if
		else
			rs.fields("icodata").value = null
			rs.fields("icosize").value = 0
			rs.fields("icotype").value = ""
		end if
		rs.update
		rs.close
		Response.write r
	end sub
	Sub updateImageField(ByRef rs, icot)
		Dim I, f, os
		on error resume next
		Err.clear
		f = server.mappath("../out/homelinks_tmp_" & Info.User & "." & icot)
		Set os = CreateObject("ADODB.Stream")
		os.Mode = 3
		os.Type = 1
		os.Open
		os.LoadFromFile f
		rs.fields("icodata").value = os.Read()
		rs.fields("icosize").value = os.Size
		rs.fields("icotype").value = icot
		os.Close
		Set os = Nothing
		If Abs(Err.number) > 0 Then
			rs.fields("icourl").value = "../images/hmlnkerr.gif"
			rs.fields("icodata").value = null
			rs.fields("icosize").value = 0
			rs.fields("icotype").value = ""
		end if
	end sub
	Function getMaxId()
		Dim id
		id = cn.execute("select isnull(max(id),0) from home_mainlink_config where uid=" & Info.user).fields(0).value
		If id < 10001 Then
			id = 10001
		else
			id = id + 1
'id = 10001
		end if
		getMaxId = id
	end function
	Sub App_delLinkItem
		Dim id, rs, role
		id = app.getint("id")
		Set rs = cn.execute("select id, role from home_mainlink_config_fun(" & Info.user & ") a where id=" & id)
		If rs.eof = False then
			role = rs.fields("role").value
		else
			role = -100
'role = rs.fields("role").value
		end if
		rs.close
		If role = -100 Then
'role = rs.fields("role").value
			Response.write "要删除的链接不存在。"
			Exit sub
		end if
		If role = 3 And id < 10000 Then
			cn.execute "update home_mainlink_config set del=1 where uid=" & Info.User & " and role=3 and id=" & id
		else
			If role = 3 Then
				cn.execute "delete home_mainlink_config where uid=" & Info.User & " and role=3 and id=" & id
			else
				cn.execute "INSERT INTO home_mainlink_config(id,role,uid,title,url,otype,icodata,icosize,icotype,icoId,icourl,sort,gpname,del,intro,powerCode) " & vbcrlf & _
				"select id,3," & Info.user & ",title,url,otype,icodata,icosize,icotype,icoId,icourl,sort,gpname,1,intro,powerCode from home_mainlink_config where id=" & id & " and role=" & role
			end if
		end if
	end sub
	Sub App_hyLinkItem
		Dim id
		id = app.getint("id")
		cn.execute "delete home_mainlink_config where uid=" & Info.User & " and role=3 and id=" & id & " and id<10000"
	end sub
	Sub saveLinkItemText
		Dim id, nText, role, rs
		id = app.getInt("id")
		nText = app.getText("newText")
		Set rs = cn.execute("select id, role from home_mainlink_config_fun(" & Info.user & ") a where id=" & id)
		If rs.eof = False then
			role = rs.fields("role").value
		else
			role = -100
'role = rs.fields("role").value
		end if
		rs.close
		If role = -100 Then
'role = rs.fields("role").value
			Response.write "要修改的链接不存在。"
			Exit sub
		end if
		If role = 3 Then
			cn.execute "update home_mainlink_config  set title='" & Replace(ntext,"'","''") & "' where uid=" & Info.User & " and role=3 and id=" & id
		else
			cn.execute "INSERT INTO home_mainlink_config(id,role,uid,title,url,otype,icodata,icosize,icotype,icoId,icourl,sort,gpname,del,intro,powerCode) " & vbcrlf & _
			"select id,3," & Info.user & ",'" &  Replace(ntext,"'","''") & "',url,otype,icodata,icosize,icotype,icoId,icourl,sort,gpname,0,intro,powerCode from home_mainlink_config where id=" & id & " and role=" & role
		end if
	end sub
	Sub updateIcoPos
		Dim nid, ngp, sid, sgp, rs, role, nsort
		nid = app.getInt("nid")
		ngp = app.gettext("ngp")
		sid = app.getInt("sid")
		sgp = app.gettext("sgp")
		Set rs = cn.execute("select id, role from home_mainlink_config_fun(" & Info.user & ") a where id=" & sid)
		If rs.eof = False then
			role = rs.fields("role").value
		else
			role = -100
'role = rs.fields("role").value
		end if
		rs.close
		If role = -100 then
'role = rs.fields("role").value
			Response.write "移动的图标不存在？"
			Exit sub
		end if
		If role <> 3 Then
			cn.execute "INSERT INTO home_mainlink_config(id,role,uid,title,url,otype,icodata,icosize,icotype,icoId,icourl,sort,gpname,del,intro,powerCode) " & vbcrlf & _
			"select id,3," & Info.user & ",title,url,otype,icodata,icosize,icotype,icoId,icourl,sort,gpname,0,intro,powerCode from home_mainlink_config where id=" & sid & " and role=" & role
		end if
		Call autoCreateLinkSort(ngp)
		Set rs = cn.execute("select sort from dbo.home_mainlink_config_fun(" & Info.user & ") where id=" & nid)
		If rs.eof = False then
			nsort = rs.fields("sort").value - 1
'If rs.eof = False then
		else
			nsort = 10000
		end if
		rs.close
		Set rs = server.CreateObject("adodb.recordset")
		rs.open "select gpname, sort from  home_mainlink_config where uid =" & Info.User & " and id=" & sid & " and role=3" , cn , 1, 3
		If rs.eof = False then
			rs.fields("gpname").value = ngp
			rs.fields("sort").value = nsort
			rs.update
		end if
		rs.close
		Call autoCreateLinkSort(ngp)
		Call autoCreateLinkSort(sgp)
	end sub
	Sub updateGroupPos
		Dim gp1 , gp2, rs, s1, s2
		gp1 = app.gettext("gp1")
		gp2 = app.gettext("gp2")
		Call autoCreateGroupSort()
		Set rs = cn.execute("select top 1 isnull(sort,0) as sort from home_mainlinkcls_config where uid=" & Info.User & " and gpname='" & gp1 & "'")
		If rs.eof = False Then
			s1 = rs.fields(0).value
		end if
		rs.close
		Set rs = cn.execute("select top 1 isnull(sort,0) as sort from home_mainlinkcls_config where uid=" & Info.User & " and gpname='" & gp2 & "'")
		If rs.eof = False Then
			s2 = rs.fields(0).value
		end if
		rs.close
		cn.execute "update home_mainlinkcls_config set sort=" & s2 & " where gpname='" &  gp1 & "' and uid=" & Info.User
		cn.execute "update home_mainlinkcls_config set sort=" & s1 & " where gpname='" &  gp2 & "' and uid=" & Info.user
	end sub
	Sub autoCreateGroupSort()
		Dim rs, i
		cn.execute "insert into home_mainlinkcls_config(gpname, uid, del,sort, intro, agpname) select distinct gpname," & Info.user & ",0,10000,'','' from dbo.home_mainlink_config_fun(" & Info.user & ") a where gpname not in (select gpname from dbo.home_mainlinkcls_config where uid=" & Info.user & ")"
		Set rs = cn.execute("select sort,gpname from home_mainlinkcls_config where uid=" & Info.User & " order by sort, gpname")
		While rs.eof = False
			i = i + 10
'While rs.eof = False
			If rs.fields("sort").value <> i Then
				cn.execute "update home_mainlinkcls_config set sort=" & i & " where gpname='" &  rs.fields("gpname").value & "' and uid=" & Info.user
			end if
			rs.movenext
		wend
		rs.close
	end sub
	Sub autoCreateLinkSort(gpname)
		Dim rs, i
		Set rs = cn.execute("select isnull(sort,0) as sort,role,id from dbo.home_mainlink_config_fun(" & Info.user & ") a where gpname='" & gpname & "' order by sort, id")
		While rs.eof = False
			i = i + 10
'While rs.eof = False
			If rs.fields("sort").value <> i Then
				If rs.fields("role") <> 3 Then
					cn.execute "INSERT INTO home_mainlink_config(id,role,uid,title,url,otype,icodata,icosize,icotype,icoId,icourl,sort,gpname,del,intro,powerCode) " & vbcrlf & _
					"select id,3," & Info.user & ",title,url,otype,icodata,icosize,icotype,icoId,icourl," & i & ",gpname,del,intro,powerCode from home_mainlink_config where id=" & rs.fields("id").value & " and role=" & rs.fields("role").value
				else
					cn.execute "update home_mainlink_config set sort=" & i & " where uid=" & Info.User & " and role=3 and id=" & rs.fields("id").value
				end if
			end if
			rs.movenext
		wend
		rs.close
	end sub
	Sub groupHide()
		Dim gn, t, rs
		gn = app.getText("gn")
		t = app.getInt("t")
		Select Case t
		Case 1:
		cn.execute "delete home_mainlink_config where gpname='" & gn & "' and id >= 10000 and role=3 and uid='" & Info.user & "'"
		cn.execute "update home_mainlink_config set del = 1 where gpname='" & gn & "' and id < 10000 and role=3 and uid='" & Info.user & "'"
		cn.execute "INSERT INTO home_mainlink_config(id,role,uid,title,url,otype,icodata,icosize,icotype,icoId,icourl,sort,gpname,del,intro,powerCode) " & vbcrlf &_
		"""select id,3,"" & Info.user & "",title,url,otype,icodata,icosize,icotype,icoId,icourl,sort,gpname,1 as del,intro,powerCode from home_mainlink_config where gpname='"" & gn & ""' and role=0 and id < 10000 and id not in (select id from home_mainlink_config where role=3 and uid="" & Info.user & "" and ""id<10000)"
		cn.execute "delete from home_mainlinkcls_config where gpname='" & gn & "' and uid=" & Info.user
		Case 2:
		cn.execute "update home_mainlinkcls_config set del=0 where gpname='" & gn & "' and uid=" & Info.User
		Case 3:
		cn.execute "delete home_mainlinkcls_config where gpname='" & gn & "' and uid=" & Info.User
		End select
	end sub
	Sub app_urlsorce
		Dim t, ivw, rs, icourl, icoid, n, tg, g, rs1, id
		Dim imgu, item
		t = app.getint("t")
		If t = 2 Then
			cn.close
			Response.redirect "menu.asp?aPower=1"
			Exit sub
		end if
		app.addDefaultScript
		Response.write app.defheadhtml("../","")
		Response.write "<body style='overflow:visible;'><style>html{overflow:auto} div.ivw_group{margin-right:2px;margin-left:2px} div.ivw_groupchild{margin-left:2px;margin-right:2px;}</style>"
		'Response.write app.defheadhtml("../","")
		Set ivw = New icoview
		ivw.id = "h"
		ivw.size = 10
		ivw.itemheight = 45
		ivw.itemwidth = 60
		ivw.canConfig = false
		Set rs = cn.execute(AllClsListSql)
		While rs.eof = False
			If rs.fields("del").value & "" <> "1" then
				n = rs.fields("agpname").value & ""
				tg = rs.fields("n").value
				If Len(n) = 0 Then
					n = tg
				end if
				Set rs1 = cn.execute("select id,title,url,otype,icoid,icourl,sort,gpname,powerCode,del from home_mainlink_config_fun(" & Info.user & ") a where a.del=1 and a.gpname='" & tg & "' order by a.sort, a.id")
				If rs1.eof = False Then
					Set g = ivw.groups.add(n,"")
					g.tag = tg
				end if
				While rs1.eof = False
					id = rs1.fields("id").value
					icourl = rs1.fields("icourl").value
					icoid = rs1.fields("icoid").value
					If existsLinkPower(rs1.fields("powerCode").value) then
						Set item = g.items.add(rs1.fields("title").value, "",  rs1.fields("otype").value , "../images/smico/dot.gif")
						item.tag = id
						item.clickScript  = "parent.attrIcoItem(" & id & ")"
					end if
					rs1.movenext
				wend
				rs1.close
			end if
			rs.movenext
		wend
		rs.close
		Response.write ivw.html
		Response.write "<script language='javascript'>window.h_onicoitemDragEnd = function(newObj, movObj){return false;}</script></body></html>"
	end sub
	Sub hfSysIcoItem
		Dim rs, id
		id = app.getint("id")
		Set rs = cn.execute("select 1 from  home_mainlink_config where id=" & id & " and role=3 and uid=" & Info.user)
		If rs.eof = False Then
			cn.execute "update home_mainlink_config set del = 0 where id=" & id & " and role=3 and uid=" & Info.User
		else
			cn.execute "INSERT INTO home_mainlink_config(id,role,uid,title,url,otype,icodata,icosize,icotype,icoId,icourl,sort,gpname,del,intro,powerCode) " & vbcrlf &_
			"select id,3," & Info.user & ",title,url,otype,icodata,icosize,icotype,icoId,icourl,sort,gpname,0,intro,powerCode from home_mainlink_config where id=" & id & " and role=0"
		end if
	end sub
	Sub dragGroupEnd
		Dim oT, nT, rs
		oT = app.getText("oT")
		nT = app.getText("nT")
		Call autoCreateGroupSort()
		If nT = Chr(1) & Chr(1) & Chr(1) Then
			cn.execute "update home_mainlinkcls_config set sort=10000000 where uid=" & Info.User & " and gpName='" & Replace(oT,"'","''") & "'"
		else
			Set rs = cn.execute("select sort from  home_mainlinkcls_config where uid=" & Info.User & " and gpName='" & Replace(nT,"'","''") & "'")
			If rs.eof = False then
				cn.execute "update home_mainlinkcls_config set sort=" & (rs.fields(0).value-1)  & " where uid=" & Info.User & " and gpName='" & Replace(oT,"'","''") & "'"
'If rs.eof = False then
			end if
			rs.close
		end if
		Call autoCreateGroupSort()
		Response.write "ok"
	end sub
	
%>
