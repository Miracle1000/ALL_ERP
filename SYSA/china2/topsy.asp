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
' sql = sql & "CREATE TABLE " & tname & "(" & vbcrlf
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
'nrs.addnew
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
'msgId = Replace(msgId, " ", "")
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
	class MenuClass
		public nextMenu
		public preMenu
		public parentMenu
		public text
		public ico
		public Menus
		public maxcount
		public deepData
		public value
		private mroot
		private mdeep
		public property get deep
		deep = mdeep
		end property
		public property let deep(nvalue)
		If Len(nvalue) = 0 Then
			nvalue = 0
		end if
		mdeep = nvalue
		Menus.deep = nvalue + 1
'mdeep = nvalue
		end property
		public property get root
		set root = mroot
		end property
		public property set root(value)
		set mroot = value
		set Menus.root = value
		end property
		public expand
		public sub class_initialize
			set Menus = new MenuCollection
			ico = ""
			maxcount  = 1000000
			deepData = ""
			set Menus.parentMenu = me
			expand = true
			set mroot = nothing
			set nextMenu = nothing
		end sub
		public sub addhtmls(id,w)
			dim fll
			fll = ( root.LenC(text) > root.ItemMaxSize)
			root.addhtml "<li class='menu_t_line" & root.ieCssSign & "' value=""" & replace(value,"""","#&34;") & """ id='" & id & "'"
			if menus.count = 0 then
				root.addhtml " onclick=""__OnMenuItemClick('" & root.id & "',this)"" "
			end if
			root.addhtml " onmouseout='return __MenuEvents(this,4)' onmouseover='return __MenuEvents(this,3)'><table class='menu_u_c_ws_s0  m" & abs(menus.count>0) & "'><tr><td class='menu_u_c_ws_s1'></td>"
			if fll then
				root.addHtml "<td class='menu_u_c_ws_s2' title=""" & replace(text,"""","&#34;") & """>"
			else
				root.addHtml "<td class='menu_u_c_ws_s2' >"
			end if
			root.addhtml "<div class='menu_t_ico'></div>"
			if menus.count > 0 then
				root.addhtml "<div class='menu_t_more_ico'>"
			else
				root.addhtml "<div class='menu_t_more'>"
			end if
			if fll then
				root.addhtml "</div>" & left(text,root.ItemMaxSize-12) & "..."
'if fll then
			else
				root.addhtml "</div>" & text
			end if
			root.addHtml "</td><td class='menu_u_c_ws_s3'></td></tr></table>"
			if menus.count > 0 then
				menus.addhtmls id , w
			end if
			root.addHtml "</li>"
		end sub
	end Class
	Class MenuCollection
		private Menus
		public count
		public parentMenu
		public root
		public deep
		public sub class_initialize
			count = 0
			redim Menus(0)
		end sub
		public function add()
			dim index , nd
			count = count + 1
'dim index , nd
			index = count - 1
'dim index , nd
			if count > 1 then
				redim preserve Menus(index)
			end if
			set Menus(index) = new MenuClass
			set nd = Menus(index)
			set nd.parentMenu =  parentMenu
			set nd.root = root
			nd.text = "新节点"
			if count > 1 then
				set nd.preMenu = Menus(index-1)
'if count > 1 then
				set Menus(index-1).nextMenu = nd
'if count > 1 then
			else
				set nd.preMenu = nothing
				set nd.nextMenu = nothing
			end if
			Menus(index).deep = deep
			set add = Menus(index)
		end function
		public default property get Item(index)
		set item = Menus(index-1)
'public default property get Item(index)
		end property
		public  property set Item(index , nobj)
		set Menus(index-1) = nobj
'public  property set Item(index , nobj)
		end property
		public sub addhtmls(id,w)
			dim i , iw , iwidth , cl, h
			iw = 0
			for i = 0 to count-1
'iw = 0
				cl = root.LenC(trim(menus(i).text))
				if cl > root.ItemMaxSize then cl= root.ItemMaxSize
				if iw < cint(cl*9) then iw = cint(cl*9)
			next
			if iw < 90 then iw = 90
			iwidth = iw + 44
'if iw < 90 then iw = 90
			if w > 0 then
				root.addhtml "<ul class='menu_ul" & deep & " menu_ul_cnitem" & root.ieCssSign & "' style='width:" & iwidth & "px;left:" & (w-15) & "px;top:-22px;'  id='" & id & "_p'>"
'if w > 0 then
			else
				root.addhtml "<ul class='menu_ul" & deep & " menu_ul_cnitem" & root.ieCssSign & "' style='width:" & iwidth & "px;'  id='" & id & "_p'>"
			end if
			root.addhtml "<li class='menu_ul_cnitem_lts'><table><tr><td class='menu_u_c_ts_s1'></td><td class='menu_u_c_ts_s2'></td><td class='menu_u_c_ts_s3'></td></tr></table></li>"
			for i = 0 to count-1
				Menus(i).addhtmls id & "_" & i , iwidth
			next
			root.addhtml "<li class='menu_ul_cnitem_lbs'><table><tr><td class='menu_u_c_ls_s1'></td><td class='menu_u_c_ls_s2'></td><td class='menu_u_c_ls_s3'></td></tr></table></li>"
			root.addhtml "</ul>"
		end sub
	end Class
	Class MenuView
		public Menus
		public id
		private htmlarray
		private htmlcount
		public stylecss
		public firstMenu
		private mIsCallback
		public isIE6
		public isoIE
		Public ieCssSign
		public width
		public ItemWidth
		public topItemMaxSize
		public itemMaxSize
		public property get IsCallBack
		isCallBack = mIsCallback
		end property
		private sub SortMenusDeep(nds , pdeep)
			dim i, nd
			for i = 1 to nds.count
				set nd = nds(i)
				nd.deepData =  pdeep
				if nd.Menus.count > 0 then
					if nd.nextMenu is nothing then
						call SortMenusDeep(nd.Menus , pdeep & "0")
					else
						call SortMenusDeep(nd.Menus , pdeep & "1")
					end if
				end if
			next
		end sub
		public sub class_initialize
			topItemMaxSize  = 12
			itemMaxSize = 36
			set Menus = new MenuCollection
			set Menus.parentMenu = nothing
			set Menus.root = me
			Menus.deep = 0
			mIsCallback = (lcase(request.form("__msgId")) = "sys_menuviewcallback")
			isIE6 = (InStr(Request.ServerVariables("Http_User_Agent"),"MSIE 6") > 0)
			isoIE =  isIE6 Or (InStr(Request.ServerVariables("Http_User_Agent"),"MSIE 7") > 0)
			ieCssSign = ""
			width = "a"
		end sub
		public sub clearHtml()
			htmlcount = 0
			redim htmlarray(0)
			firstMenu = true
		end sub
		public sub addHtml(str)
			redim preserve htmlarray(htmlcount)
			htmlarray(htmlcount) = str
			htmlcount = htmlcount + 1
'htmlarray(htmlcount) = str
		end sub
		public function HTML
			dim mc , hsmore , cl , i , ms
			dim iw
			dim iwidth
			dim rootsize
			hsmore = false
			call clearHtml()
			Call SortMenusDeep(Menus,"")
			mc = menus.count
			iw = 0
			for i = 1 to mc
				cl = LenC(trim(menus(i).text))
				if cl > topItemMaxSize then cl= topItemMaxSize
				if iw < cint(cl*7.2) then iw = cint(cl*7.2)
			next
			rootsize = mc
			if isnumeric(me.itemwidth) then
				iwidth = me.itemwidth
			else
				iwidth = iw*1 + 25
'iwidth = me.itemwidth
			end if
			if not isnumeric(width) then
				width = iwidth*mc
			else
				if width < iwidth then width = iwidth
				for i = 1 to mc
					if iwidth*i > (width) then
						rootsize = i - 1
'if iwidth*i > (width) then
						exit for
					end if
				next
			end if
			if rootsize <  mc then width = width + 22
'exit for
			if mIsCallback then
				select case lcase(request.form("cmd") & "")
				case "moreclick"
				if rootsize <  mc then call sortByMoreClick(rootsize)
				end select
			end if
			stylecss  = stylecss  & ";width:" & (width+10) & "px;"
'end select
			if not mIsCallback then addHtml "<div class='menu' id='mvw_" & id & "' style='" & stylecss & "'>"
			addHTML "<ul>"
			for i = 1 to rootsize
				addHTML "<li class='menu_topitem' onmouseout='return __MenuEvents(this,2)' onmouseover='return __MenuEvents(this,1)' style='width:" & (iwidth) & "px'><table cellspacing=0 class='menu_topitem'><tr><td class='menu_topitem_il'></td><td class='menu_topitem_txt' style='width:" & iw & "px'><div>" &  menus(i).text & "</div></td><td class='menu_topitem_ir' valign='top'><div></div></td></tr></table>"
				call menus(i).menus.addhtmls("mvw_" & id & "_" & i,0)
				addHTML "</li>"
			next
			if rootsize  < mc then
				set ms = new MenuCollection
				set ms.root =  me
				set ms.parentMenu = nothing
				for i = rootsize + 1 to mc
'set ms.parentMenu = nothing
					with ms.add
					.value = menus(i).value & "&%__sysMore"
					.text = menus(i).text & "<span class='moretop'> 置顶↑</span>"
					end with
				next
				addHTML "<li class='menu_morebar' onmouseout='return __MenuEvents(this,6)' onmouseover='return __MenuEvents(this,5)'><a href='javascript:void(0)' class='menumore' onclick='return false'><div class='mrico'></div></a>"
				call ms.addhtmls("mvw_" & id & "_" & mc,-10)
				addHTML "</li>"
				set ms = nothing
			end if
			addHTML "</ul>"
			If rootsize >= mc Then addHTML "<div class='left last" & Abs(mc>0) & "'></div>"
			if not mIsCallback then addHtml "</div>"
			html = join(htmlarray,"")
		end function
		public function LenC(byval ps)
			Dim n ,i
			Dim StrLen , s , ns
			ps = ps & ""
			if instr(ps,"<") > 0 then
				ps = replace(replace(replace(ps,"</",chr(1)),"<",chr(1)),">",chr(1))
				s = split(ps,chr(1))
				ps = " "
				for i = 0 to ubound(s) step 2
					ps = ps + s(i)
'for i = 0 to ubound(s) step 2
				next
			end if
			For n = 1 To Len(ps)
				If Ascw(Mid(ps, n, 1)) >256 Then
					StrLen = StrLen + 2
'If Ascw(Mid(ps, n, 1)) >256 Then
				else
					StrLen = StrLen + 1
'If Ascw(Mid(ps, n, 1)) >256 Then
				end if
			next
			lenc = strLen
		end function
		public sub sortByMoreClick(nsort)
			dim v , i , n
			v = request.form("value")
			for i = 1 to menus.count
				if menus(i).value = v then
					set n = menus(i)
					set menus(i) =  menus(nsort)
					set menus(nsort)  = n
					exit sub
				end if
			next
		end sub
	end Class
	sub app_sys_menuviewCallBack
		dim id
		id = request.form("id")
		call App_onCreateMenu(id)
	end sub
	class ToolButton
		public ico
		Public ico2
		public text
		public value
		public root
		public num
	end class
	class ToolButtonConntion
		private items
		public count
		public root
		public sub class_initialize
			count = 0
			redim items(0)
		end sub
		public function add()
			dim index , nd
			count = count + 1
'dim index , nd
			index = count - 1
'dim index , nd
			if count > 1 then
				redim preserve items(index)
			end if
			set items(index) = new ToolButton
			set items(index).root = root
			set add = items(index)
		end function
		public default property get Item(index)
		set item = items(index-1)
'public default property get Item(index)
		end property
		public  property set Item(index , nobj)
		set items(index-1) = nobj
'public  property set Item(index , nobj)
		end property
	end Class
	class ToolBar
		public buttons
		public itemWidth
		public itemHeight
		public id
		private htmlarray
		private htmlcount
		public pagesize
		public vpath
		public cellspacing
		Public textalign
		Public uimodel
		public sub class_initialize
			set buttons = new ToolButtonConntion
			set buttons.root = me
			ItemWidth = 30
			itemHeight = 30
			pagesize = 10
			cellspacing = 5
			textalign = "none"
			uimodel = ""
		end sub
		public sub clearHtml()
			htmlcount = 0
			redim htmlarray(0)
			if isnumeric(itemheight) = false or len(itemheight)=0 then
				itemheight = 0
			end if
		end sub
		public sub addHtml(str)
			redim preserve htmlarray(htmlcount)
			htmlarray(htmlcount) = str
			htmlcount = htmlcount + 1
'htmlarray(htmlcount) = str
		end sub
		public function html
			dim mc , bn , moredata, i
			call clearHtml()
			addhtml "<div id='toolbar_" & id & "' class='toolbar'>"
			for i = 1 to buttons.count
				set bn = buttons(i)
				if i = pagesize+1 then
'set bn = buttons(i)
					addhtml "<div class=""arrow""  style='height:" & (itemHeight+2) & "px;' onmouseout='this.className=""arrow""' onmousedown='__toolbarshowmore(this)' onmouseover='this.className=""arrow_hover""'>"
'set bn = buttons(i)
					exit for
				end if
				addhtml "<div id='toolbar_" & id & "_" & i & "' sort="& i &" uimodel='" & Me.uimodel & "' class=""btnlist"" value=""" & replace((bn.text & "#-#" & bn.value & "#-#" & bn.ico & "#-#" & bn.num & "#-#" & i & "#-#" & id),"""","&#34;") & """ style='height:" & (itemHeight+2) & "px;' onclick='__toolbarclick(this)' ico1='" & bn.ico & "' ico2='" & bn.ico2 & "' title=""" & replace(bn.text & "","""","&#34;") & """ onmouseover='_toolbarmv(this,true)' onmouseout='_toolbarmv(this,false)'><div class='btnimg' style='height:" & (itemHeight) & "px;width:" & (itemWidth) & "px;overflow:hidden;padding:0px;'><divstyle='background:transparent url(" &  vpath & "skin/" & info.Skin & "/images/toolbar/" & bn.ico & ") no-repeat center " & app.iif(textalign ="bottom", "4px", "center") & ";width:100%;height:100%;_FILTER: progid:DXImageTransform.Microsoft.AlphaImageLoader(src=""" &  vpath & "skin/" & info.Skin & "/images/toolbar/" & bn.ico & """);_background:transparent;'>"
				If textalign = "bottom" Then
					addhtml "<div style='text-align:center;padding-top:" & (itemHeight-18) & "px;' istext=1>" & bn.Text & "</div>"
'If textalign = "bottom" Then
				end if
				addhtml "</div></div>"
				if len(bn.num) = 0 then bn.num = 0
				if bn.num > 0 then
					addhtml "<div class=""num"" style=''>" & bn.num & "</div>"
				end if
				addhtml "</div>"
				addhtml "<div style='width:" & cellspacing  & "px;' class='spc'>&nbsp;</div>"
			next
			if buttons.count > pagesize  then
				moredata = ""
				for i = pagesize+1  to buttons.count
'moredata = ""
					set bn = buttons(i)
					moredata = moredata & "$%#4" & bn.text & "#-#" & bn.value & "#-#" & bn.ico & "#-#" & bn.num & "#-#" & i & "#-#" & id
					set bn = buttons(i)
				next
				addhtml "<input type='hidden' value=""" & replace(moredata ,"""","&#34;") & """></div>"
			end if
			addhtml "</div>"
			html = join(htmlarray,"")
		end function
	end Class
	ZBRLibDLLNameSN = "ZBRLib3205"
	Function IsSaasModel(ByVal path)
		Dim cn
		Dim rv : rv = Application("__is__saasmodel") & ""
		If rv = "" Then
			Dim rs , dbpath
			on error resume next
			dbpath = app.ConfigDBPath
			If Len(dbpath & "")= 0 Then dbpath = sdk.ConfigDBPath
			If Len(dbpath & "") = 0 Then dbpath = server.mappath("update/db.asp")
			Set cn = server.CreateObject("adodb.connection")
			cn.Open "Driver={SQLite3 ODBC Driver};Database=" & dbpath & ""
			Set rs = cn.execute("select value from SysInfo where key='SaasModel'")
			If rs.eof = False Then
				rv = rs(0).value & ""
			else
				rv = "0"
			end if
			rs.close
			If rv = "1" Then
				Set rs = cn.execute("select value from SysInfo where key='configselectedindex'")
				If rs.eof = False Then
					rv = rs(0).value & ""
				end if
				rs.close
			end if
			If rv = "" Then rv = "0"
			set rs = nothing
			cn.close
			Set cn = Nothing
			Application("__is__saasmodel")=CLng(rv)
		end if
		IsSaasModel = CLng(rv)
	end function
	Function LoadSaasModel(p)
		Dim pooln : pooln = Request.ServerVariables("APP_POOL_ID")
		Dim pool : pool = Replace(pooln, "W","")
		If isnumeric(pool) And Left(pooln & "XX",1)="W" then
			If IsSaasModel(p) Then
				Application("__saas__company") = CLng(pool)
			end if
		end if
	end function
	Function getSaasSignKey
		Dim skey : skey = Application("__saas__company")
		If Len(skey) > 0 Then
			getSaasSignKey = "." & CLng(skey)
		else
			getSaasSignKey = ""
		end if
	end function
	Sub UpdateHomeConfigData(byref errnum, byref lg)
		dim models, omodels
		dim mdbcn , mdbconntext , sql , rs , rs1 , n
		dim hsmodel , modelvalues, i
		on error resume next
		modelvalues  = "," & session("zbintel2010ms") & ","
		set rs =  server.CreateObject("adodb.recordset")
		mdbconntext = "Driver={SQLite3 ODBC Driver};Database=" & app.ConfigDBPath & ""
		set mdbcn = server.CreateObject("adodb.connection")
		mdbcn.open mdbconntext
		if abs(err.number) > 0  then
			errnum = errnum + 1
			If Not lg Is Nothing Then lg.write errnum & ".打开db配置失败，" & Err.description & "<br>" & vbcrlf
			Err.clear
			Exit sub
		end if
		Err.clear
		cn.execute "truncate table home_toolbar_comm"
		set rs1 = mdbcn.execute("select * from home_toolbars")
		rs.open  "select * from home_toolbar_comm" , cn , 1, 3
		if abs(err.number) > 0  then
			errnum = errnum + 1
			If Not lg Is Nothing Then lg.write errnum & ".读取home_toolbars配置失败，" & Err.description & "<br>" & vbcrlf
			Err.clear
		else
			while rs1.eof =  false
				rs.addnew
				rs.fields("ID").value = rs1.fields("ID").value
				rs.fields("title").value = rs1.fields("title").value & ""
				rs.fields("url").value = rs1.fields("url").value & ""
				rs.fields("target").value = rs1.fields("target").value & ""
				rs.fields("img").value = rs1.fields("img").value & ""
				if len(rs1.fields("qxlb").value & "") > 0 then
					rs.fields("qxlb").value = rs1.fields("qxlb").value
				else
					rs.fields("qxlb").value = 0
				end if
				if len(rs1.fields("qxlblist").value & "") > 0 then
					rs.fields("qxlblist").value = rs1.fields("qxlblist").value
				else
					rs.fields("qxlblist").value = 0
				end if
				if len(rs1.fields("sort1").value & "") > 0 then
					rs.fields("sortnum").value = rs1.fields("sort1").value
				else
					rs.fields("sortnum").value = 0
				end if
				if len(rs1.fields("models").value & "") > 0 then
					rs.fields("models").value = rs1.fields("models").value & ""
				else
					rs.fields("models").value = 0
				end if
				rs.update
				rs1.movenext
			wend
		end if
		rs.close
		rs1.close
		dim arr_models
		cn.execute "delete home_search_config_def where usign='" & Info.uniqueName & "' or usign=''"
		set rs1 = mdbcn.execute("select ID,cls,fields,qxlb,qxlblist,model from home_search_config")
		rs.open  "select ID,cls,fields,qxlb,qxlblist,usign from home_search_config_def" , cn , 1, 3
		if abs(err.number) > 0  then
			errnum = errnum + 1
			If Not lg Is Nothing Then lg.write errnum & ".读取home_search_config_def配置失败，" & Err.description & "<br>" & vbcrlf
			Err.clear
		else
			while rs1.eof =  false
				models = rs1.fields("model").value & ""
				if len(models) = 0 then
					hsmodel = true
					models  = ""
				else
					if isnumeric(models) then
						hsmodel = ZBRuntime.MC(models)
						models  = ""
					else
						if instr(models,"@models")>0 then
							hsmodel = ZBRuntime.MC(models)
							models  = ""
						else
							hsmodel = true
						end if
					end if
				end if
				if hsmodel = true then
					rs.addnew
					for i = 0 to rs.fields.count-2
'rs.addnew
						rs.fields(rs1.fields(i).name).value = rs1.fields(i).value
					next
					rs.fields("usign").value = Info.uniqueName
					rs.update
				end if
				rs1.movenext
			wend
		end if
		rs.close
		rs1.close
		cn.execute "delete home_topmenu_item_def where usign='" & Info.UniqueName  & "' or len(usign) = 0"
		cn.execute "delete home_topmenu_cls_def where usign='" & Info.UniqueName  & "' or len(usign) = 0"
		set rs1 = mdbcn.execute("select * from home_topmenu_cls")
		rs.open  "select * from home_topmenu_cls_def" , cn , 1, 3
		if abs(err.number) > 0  then
			errnum = errnum + 1
			If Not lg Is Nothing Then lg.write errnum & ".读取home_topmenu_item_cls配置失败，" & Err.description & "<br>" & vbcrlf
			Err.clear
		else
			while rs1.eof =  False
				rs.addnew
				for i = 0 to rs.fields.count-2
'rs.addnew
					rs.fields(rs1.fields(i).name).value = rs1.fields(i).value
				next
				rs.fields("usign").value = Info.UniqueName
				rs.update
				rs1.movenext
			wend
		end if
		rs.close
		rs1.close
		set rs1 = mdbcn.execute("select ID,title,sort,cls,remark,url,qxlb,qxlist,otype,ModelExpress from home_topmenu_item")
		rs.open  "select ID,title,sort,cls,remark,url,qxlb,qxlist,otype,ModelExpress,usign from home_topmenu_item_def" , cn , 1, 3
		if abs(err.number) > 0  then
			errnum = errnum + 1
'if abs(err.number) > 0  then
			If Not lg Is Nothing Then lg.write errnum & ".读取home_topmenu_item_def配置失败，" & Err.description & "<br>" & vbcrlf
			Err.clear
		else
			while rs1.eof =  false
				models = rs1.fields("ModelExpress").value & ""
				if len(models) = 0 then
					hsmodel = true
					models  = ""
				else
					if isnumeric(models) then
						hsmodel = ZBRuntime.MC(models)
						models  = ""
					else
						if instr(models,"@models")>0 then
							hsmodel = ZBRuntime.MC(models)
							models  = ""
						else
							hsmodel = true
						end if
					end if
				end if
				if hsmodel = true then
					rs.addnew
					for i = 0 to rs.fields.count-2
'rs.addnew
						rs.fields(rs1.fields(i).name).value = rs1.fields(i).value
					next
					rs.fields("usign").value = Info.UniqueName
					rs.update
				end if
				rs1.movenext
			wend
		end if
		rs.close
		rs1.close
		Dim xxx : xxx = 0
		sql = "delete from home_topmenu_cls_def where ID >0 and usign='" & Info.UniqueName & "' and ID not in (select PID from home_topmenu_cls_def where usign='" & Info.UniqueName & "' union select cls from home_topmenu_item_def where usign='" & Info.UniqueName & "')"
		cn.execute sql, n
		while n>0 And xxx < 1000000
'cn.execute sql, n
			xxx = xxx + 1
			cn.execute sql, n
		wend
		cn.execute "truncate table home_maincards_def"
		dim v
		set rs1 = mdbcn.execute("select ID,cardClass,title,ranking,[sql],sql2,colspan,maxspan,sort,qxlb,qxlblist,mustadmin,canadd,canset,canmore,canclose,visible,monthjs,defjs,gjjs,models as model,powers,attrs,setJM,fw,defRows,canqt,addUrl,addqxlb from [home_maincards]")
		rs.open "select ID,cardClass,title,ranking,[sql],sql2,colspan,maxspan,sort,qxlb,qxlblist,mustadmin,canadd,canset,canmore,canclose,visible,monthjs,defjs,gjjs,model,powers,attrs,setJM,fw,defRows,canqt,addUrl,addqxlb   from home_maincards_def" , cn , 1, 3
		if abs(err.number) > 0  then
			errnum = errnum + 1
			If Not lg Is Nothing Then lg.write errnum & ".读取home_maincards配置失败，" & Err.description & "<br>" & vbcrlf
			Err.clear
		else
			while rs1.eof =  false
				rs.addnew
				for i = 0 to rs.fields.count-1
'rs.addnew
					on error resume next
					v =  rs1.fields(i).value
					if isnull(v) then  v = v & ""
					if lcase(typename(v)) = "boolean" then v = abs(v)
					rs.fields(rs1.fields(i).name).value = v
					if err.number <> 0 then
						Response.write "[" & rs.fields(i).name & "=" & rs1.fields(i).value & "]"
						cn.close
						call db_close : Response.end
					end if
				next
				rs.update
				rs1.movenext
			wend
		end if
		rs.close
		rs1.close
		cn.execute "update u set u.title=d.title,u.sql=d.sql,u.qxlb=d.qxlb,u.qxlblist=d.qxlblist,u.model=d.model,u.powers=d.powers from home_maincards_us u inner join home_maincards_def d on u.id=d.id"
		mdbcn.close
		set mdbcn = nothing
		If lg Is Nothing Then Exit sub
		cn.execute "delete home_leftMenu where parentID  > 0 and parentID not in (select ID from home_leftMenu)" , n
		while n > 0
			cn.execute "delete home_leftMenu where parentID  > 0 and parentID not in (select ID from home_leftMenu)" , n
		wend
		cn.Execute "UPDATE contract SET paybacktype = 0 WHERE paybacktype <> 1"
	end sub
	Sub addrTopItem(ByVal ico, ByVal txt, ByVal url)
		Dim sk : sk = Info.skin
		Dim us: us = Split(url & "|","|")
		Dim u , ck : u = us(0)
		If Len(u) = 0 Then u = "javascript:void(0)"
		If Len(us(1)) > 0 Then ck = "onclick=""" & us(1) & """"
		Response.write "<a href=""" & u & """ " & ck & " target='"
		If txt <> "退出" Then Response.write "mainFrame"
		Response.write "'><img src=""../skin/" & sk & "/images/hometop/" & ico & """ class=""ico"" />" & txt & "</a><img src=""../skin/" & sk & "/images/ico_top_menu_line.gif"" class=""line"" />"
	end sub
	Sub Page_Load
		If request.querystring("ASP") <> "1" then
			Response.redirect "../../SYSN/view/init/home.ashx"
			Exit sub
		end if
		Dim sk : sk = Info.skin
		Dim zm : zm = request.querystring("zoom")
		If Len(zm)>0 Then app.Attributes("uizoom") = zm
		zm = app.Attributes("uizoom")
		If zm & "" = "1" Then zm = ""
		if info.user = 0 then
			cn.close
			Response.redirect "../index2.asp?sign=nologin"
			Exit sub
		end if
		If ZBRuntime.SystemType = 1 Then
			Response.redirect "../china/topsy.asp?" & request.querystring
			Exit sub
		end if
		If cn.execute("select top 1 1 as r from home_search_config_def").eof = true Then
			Call UpdateHomeConfigData(0, nothing)
		end if
		dim headHTML ,htmlHTML , sql
		dim rs , i , display
		app.addcsspath "../skin/" & sk & "/css/home.css"
		app.addscriptpath "../skin/" & sk & "/js/home.js"
		app.addscriptpath "../inc/CheckOnLine.js"
		app.addscriptpath "../inc/system.js"
		Response.write app.DefHeadHTML("../","")
		Response.write "" & vbcrlf & "<body onload='onload();txmFocus();' uizoom='"
		Response.write zm
		Response.write "' onresize='body_resize()' onscroll='window.scrollTo(0,0)' onclick=""TexTxmFocus(event);"" id='homebody'> " & vbcrlf & ""
		If app.power.existsModel(60000) Then
			Dim isjmg
			isjmg=session("jmgou")
			If isjmg="1" Then
				Response.write "      " & vbcrlf & "                <OBJECT classid=clsid:EA3BA67D-8F11-4936-B01B-760B2E0208F6 id=NT120Client name=NT120Client  STYLE='LEFT: 0px; TOP: 0px;display:none' width=50 height=50></OBJECT>" & vbcrlf & "               <script src='../jmgou.js?ver="
'If isjmg="1" Then
				Response.write Application("sys.info.jsver")
				Response.write "' language='javascript' type='text/javascript'></script>" & vbcrlf & "              <script language='javascript' type='text/javascript'>" & vbcrlf & "                   var NT120Client=document.getElementById(""NT120Client"");" & vbcrlf & "                   window.jmgpwd="""
				Response.write session("jmgpwd")
				Response.write """;" & vbcrlf & "         </script>" & vbcrlf & "               <script language='javascript' type='text/javascript'>setTimeout(""CheckJmgOnline(NT120Client,window.jmgpwd)"", 1000);</script>" & vbcrlf & "      "
			end if
		end if
		Response.write "" & vbcrlf & "<img  onpropertychange='logoicochange(this)' src="""" id='logoBox'/>" & vbcrlf & ""
		If IsSaasModel("../") = 1 Then
			If sdk.file.existsfile("../skin/" & sk & "/images/logo/logo_" & info.SoftType & getSaasSignKey & ".png") Then
				Response.write "<script>document.getElementById(""logoBox"").src = ""../skin/" & sk & "/images/logo/logo_" & info.SoftType & getSaasSignKey & ".png?t=" & cdbl(now) & """;</script>"
			else
				Response.write "<script>document.getElementById(""logoBox"").src = ""../skin/" & sk & "/images/logo/logo_" & info.SoftType & ".png?t=" & cdbl(now) & """;</script>"
			end if
		else
			Response.write "<script>document.getElementById(""logoBox"").src = ""../skin/" & sk & "/images/logo/logo_" & info.SoftType & ".png?t=" & cdbl(now) & """;</script>"
		end if
		If app.isie6 then
			Response.write "" & vbcrlf & "<script type=""text/javascript"" src=""../inc/jquery.bgiframe.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write """></script>" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "   $(function() {" & vbcrlf & "          $('ul.menu_ul1').bgiframe();" & vbcrlf & "            $('ul.menu_ul2').bgiframe();" & vbcrlf & "    });" & vbcrlf & "</script>" & vbcrlf & ""
		end if
		Response.write "" & vbcrlf & "<div id='topmenuarea'>" & vbcrlf & "        <div class=""home-btn left"">" & vbcrlf & "               <div class='top_goback' onmouseover='app.swpCss(this)' onmouseout='app.swpCss(this)' onclick='homeGoBack()' title='后退'></div>" & vbcrlf & "         <div class='top_gohome' onmouseover='app.swpCss(this)' onmouseout='app.swpCss(this)' title='首页' onclick='goHome()'></div>" & vbcrlf & "           <div class='top_goforward' onmouseover='app.swpCss(this)' onmouseout='app.swpCss(this)' onclick='homeGoNext()' title='前进'></div>" & vbcrlf & "      </div>" & vbcrlf & "  <div class=""main-menu left"">" & vbcrlf & "      "
		call App_onCreateMenu("topmenu")
		Response.write "" & vbcrlf & "      </div>" & vbcrlf & "  <script>$ID(""mvw_topmenu"").style.width = ""auto"";</script>" & vbcrlf & "</div>" & vbcrlf & "<div id='topbararea'>" & vbcrlf & "        "
		Call App_onCreateToolBar("topbar")
		Response.write "" & vbcrlf & "</div>" & vbcrlf & "<div id='topdiv'>" & vbcrlf & "  <div id=""top"">" & vbcrlf & "    <div class=""logo left"">" & vbcrlf & "        </div>" & vbcrlf & "    <div class=""t-m-menu"">" & vbcrlf & "      <div class=""t-m"">" & vbcrlf & "        <div class=""link-right right"">" & vbcrlf &"          "
		if app.power.existsModel(31000) And app.power.existsPower(71,19) And (app.power.existsPower(71,1) Or app.power.existsPower(71,2) Or app.power.existsPower(71,3) Or app.power.existsPower(71,6) Or app.power.existsPower(71,7) Or app.power.existsPower(71,8) Or app.power.existsPower(71,10) Or app.power.existsPower(71,14) Or app.power.existsPower(71,16)) Then
			Call addrTopItem("rc.gif", "日程", "../china/tophome2.asp")
		end if
		if app.power.existsModel(28006) Then
			Response.write "<input type=""hidden"" id=""allowPop"" value=""1"" />"
			Call addrTopItem("tx.gif", "提醒", "../china/topalt.asp")
		else
			Response.write "<input type=""hidden"" id=""allowPop"" value=""0"" />"
		end if
		Call addrTopItem("us.gif", "账号", "../china/topadd.asp")
		if app.power.existsModel(28005) Then Call addrTopItem("set.gif", "设置", "homeseting/index.asp")
		Call addrTopItem("jm.png", "界面", "|formconfig();return false;")
		Call addrTopItem("exit.gif", "退出", "../inc/logout.asp|return doExit()")
		Response.write "" & vbcrlf & "              </div>" & vbcrlf & "      </div>" & vbcrlf & "      <div class=""t-s"">" & vbcrlf & "         "
'Call addrTopItem("exit.gif", "退出", "../inc/logout.asp|return doExit()")
		call App_onCreateSearchBar()
		Response.write "" & vbcrlf & "      </div>" & vbcrlf & "    </div>" & vbcrlf & "  </div>" & vbcrlf & "</div>" & vbcrlf & "<div id='bodydiv' style='z-index:100;'>" & vbcrlf & "  <iframe src=""default.asp?cache=0"" frameborder=""0"" id=""frmbody"" scrolling=""no""></iframe>" & vbcrlf & "</div>" & vbcrlf & "<div id='buttomdiv'>" & vbcrlf & "  <div id=""footer"">" & vbcrlf & "            <div class=""t-line"">" & vbcrlf & "                      <div class=""user-name""><img src=""../skin/"
'call App_onCreateSearchBar()
		Response.write sk
		Response.write "/images/ico_footer_01.gif""  class=""ico_user"" />用户："
		Response.write info.username
		Response.write "<img src=""../skin/"
		Response.write sk
		Response.write "/images/ico_footer_02.gif""  class=""ico_line"" />" & vbcrlf & "                     <a href='javascript:void(0)' onclick='showDatePanel();return false;' id='DateStWords' title='鼠标单击查看日历'>"
		Response.write GetFormatDate()
		Response.write "</a><img src=""../skin/"
		Response.write sk
		Response.write "/images/ico_footer_02.gif"" class=""ico_line"" />在线(<a id='onlinenumber' style='color:#fff' href='javascript:void(0)' "
		If Info.isSupperAdmin then
			Response.write " onclick='window.open(""?__msgID=onlines&t=" & CDbl(now) & """,""xxxonline"",""width=640px,height=420px,left=200px,top=150px,resizable=1,scrollbars=1"");return false' "
		else
			Response.write " onclick='return false' "
		end if
		Response.write ">"
		Dim uobj
		Set uobj = server.createobject(ZBRLibDLLNameSN & ".UserListV2Class")
		uobj.tryLoginOut false
		Response.write uobj.UserCount
		Response.write "</a>)"
		Dim currcss,accountname
		accountname = ""
		If session("f_account")<>"" Then
			currcss = " "
			Set rs = cn.Execute("SELECT title FROM accountsys WHERE ord ="& session("f_account"))
			If rs.eof = False Then
				accountname = rs("title")
			end if
			rs.close
		else
			currcss = " display:none; "
		end if
		Response.write "" & vbcrlf & "                     <span id=""curraccount"" style="""
		Response.write currcss
		Response.write """><img src=""../skin/"
		Response.write sk
		Response.write "/images/ico_footer_02.gif""  class=""ico_line"" /><span id=""curraccountname"">"
		Response.write accountname
		Response.write "</span></span><img src=""../skin/"
		Response.write sk
		Response.write "/images/ico_footer_02.gif""  class=""ico_line"" /><a href='javascript:void(0)' id='UserStWords' onclick='setStimulusWords();return false;' title='鼠标单击设置您的激励语'>"
		Response.write getStimulusWords()
		Response.write "</a>" & vbcrlf & "                 "
		Dim sysstate, rmc
		rmc = 0
		If Application("__nosqlcahace") = "1" Then sysstate = "  ◆ 无数据缓存模式" : rmc = rmc + 1
'rmc = 0
		If Application("sys_debug") = "1" Then sysstate = sysstate & "\n  ◆ 调试模式": rmc = rmc + 1
'rmc = 0
		If rmc > 0 And Info.issupperadmin Then
			Response.write "" & vbcrlf & "                     <img src=""../skin/"
			Response.write sk
			Response.write "/images/ico_footer_02.gif"" class=""ico_line"" /><a style='color:#465670' href='javascript:void(0)' onclick='app.Alert(""系统正在以下列模式运行：\n\n"
			Response.write sysstate
			Response.write "\n\n不同的模式用于方便检测系统的相关状态，但可能对性能有一些影响，如有疑问，请联系系统管理员。"");return false;'>系统模式("
			Response.write rmc
			Response.write ")</a>" & vbcrlf & "                        "
		end if
		Response.write "" & vbcrlf & "                     </div>" & vbcrlf & "                  <div class=""copyright"">" & vbcrlf & "            "
		Response.write "<a href='javascript:void(0)' onclick=""window.open('help.asp?V=" & Replace(CDbl(now) & "", ".","") & "', 'helpwindow', fwAttr());return false""  class='bottomlink'>帮助</a>"
		Response.write "<img src=""../skin/" & sk & "/images/ico_footer_02.gif""  class=""ico_line"" />"
		Response.write "<a href=""javascript:void(0);"" onClick=""toDesktop('"
		Response.write Info.title
		Response.write "');return false;"" class='bottomlink'>创建快捷方式</a><img src=""../skin/"
		Response.write sk
		Response.write "/images/ico_footer_02.gif""  class=""ico_line"" /><a href='http://www.zbintel.com/product/advice_cus.asp?uid="
		Response.write Session("UniqueName")
		Response.write "' target='_blank'  class='bottomlink'>建议</a><img src=""../skin/"
		Response.write sk
		Response.write "/images/ico_footer_02.gif""  class=""ico_line"" />v"
		Response.write info.version
		Response.write "" & vbcrlf & "                     <img src=""../skin/"
		Response.write sk
		Response.write "/images/ico_footer_02.gif""  class=""ico_line"" /><img value='0' onclick='zoomfBox(this)' title='点击界面全屏' id='zoomf' src='../skin/"
		Response.write sk
		Response.write "/images/hometop/allp.png'>" & vbcrlf & "                   </div>" & vbcrlf & "          </div>" & vbcrlf & "  </div>" & vbcrlf & "</div>" & vbcrlf & "<script language='javascript'>" & vbcrlf & "      window.propmTimer="
		Response.write info.propmTimer
		Response.write ";//提醒间隔//此变量为超时的时候取用户变量时用，勿删" & vbcrlf & "  var UserUniqueID="""
		Response.write session("personzbintel2007")
		Response.write """;" & vbcrlf & "        var UserUniqueSID="""
		Response.write session("SessionID")
		Response.write """;" & vbcrlf & "        "
		uobj.setAttribute "phbox", "0"
		if app.power.existsmodel(32000) then
			if app.power.existsPowerCls(74) then
				if not cn.execute("select 1 from gate where callModel=1 and ord=" & info.user).eof then
					dim uT : uT = ubound(split(uobj.FilterUserByAttrs("phbox","1") & "", ",")) + 1
'if not cn.execute("select 1 from gate where callModel=1 and ord=" & info.user).eof then
					if uT < ZBRuntime.LimitT then
						uobj.setAttribute "phbox", "1"
						Response.write "window.addPhone=1; //max=" & ZBRuntime.LimitT & vbcrlf
					else
						if ZBRuntime.LimitT < 0 then
							Response.write "app.Alert('电话使用用户数上限为0，请联系智邦国际开通。'); //max=" & ZBRuntime.LimitT  & vbcrlf
						else
							Response.write "app.Alert('电话使用用户数超过上限" & ZBRuntime.LimitT & "，请联系智邦国际开通。'); //max=" & ZBRuntime.LimitT  & vbcrlf
						end if
					end if
				else
					uobj.setAttribute "phbox", "0"
				end if
			else
				uobj.setAttribute "phbox", "0"
			end if
		end if
		set uobj = nothing
		dim UserTimeout
		set rs = cn.execute("select num1 from setjm3 where ord=2")
		if rs.eof = false then
			UserTimeout = rs.fields(0).value
		else
			UserTimeout = 0
		end if
		rs.close
		set rs = nothing
		Response.write "var UserTimeout="""
		Response.write UserTimeout
		Response.write """;" & vbcrlf & "        //自动调整框架出现空白的问题" & vbcrlf & "    var needlistresize =  0;" & vbcrlf & "        function listResize() {" & vbcrlf & "         $ID(""frmbody"").style.height = $ID(""bodydiv"").offsetHeight + ""px"";" & vbcrlf & "     }" & vbcrlf & "       function body_resize() {" & vbcrlf & "                if(document.body.offsetHeight>300) { autosizeframe(); }" & vbcrlf & "               listResize();" & vbcrlf & "   }" & vbcrlf & "       body_resize();" & vbcrlf & "  //binary.IE11JS刷新高度" & vbcrlf & " window.onmainFrameLoad = function() {" & vbcrlf & "           listResize();" & vbcrlf & "           return  $ID(""bodydiv"").offsetHeight;" & vbcrlf & "      }" & vbcrlf & "put type='hidden' name='I1' id='I1'><!-- 兼容老代码对框架名称为I1的错误，防止报错 -->"
		Response.write UserTimeout
		If app.power.existsModel(17000) Then
			Response.write "" & vbcrlf & "<form method=""post""  id=""txmfrom""  name=""txmfrom"" style=""width:0; height:0;border:0 0 0 0;margin: 0px;padding: 0px;"">" & vbcrlf & "        <input name=""txm"" autocomplete=""off"" type=""text"" style="" width:0px; height:0px; border:0 0 0 0;margin: 0px;padding: 0px;"" onkeypress=""if(event.keyCode==13) {TopScan('topmenu',this);this.value='';unEnterDown();}"" onFocus=""this.value=''"" size=""10"">" & vbcrlf & "</form>" & vbcrlf & ""
		end if
		Response.write "" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	end sub
	function GetFormatDate()
		dim yy , mm , dd , d
		d = date()
		yy = year(d)
		mm = month(d)
		dd = day(d)
		if mm < 10 then mm = "0" & mm
		if dd < 10 then dd = "0" & dd
		GetFormatDate = yy & "年" & mm & "月" & dd & "日"
	end function
	Function rearrName(ByVal no)
		Dim openzdy5,openzdy6,intgate1,zdy5name,zdy6name,rs
		openzdy5=0
		openzdy6=0
		Dim arrShow()
		Dim arrNames()
		Dim arrFelds()
		Set rs=cn.execute("select (case when isnull(name,'')='' then oldname else name end ) as name, (case when show>0 then 1 else 0 end) as show,fieldName,gate1 from setfields order by gate1 asc ")
		While Not rs.eof
			intgate1=rs("gate1")
			redim Preserve arrShow(intgate1)
			redim Preserve arrNames(intgate1)
			redim Preserve arrFelds(intgate1)
			arrShow(intgate1)=rs("show")
			arrNames(intgate1)=rs("name")
			arrFelds(intgate1)=rs("fieldName")
			rs.movenext
		wend
		rs.close
		Set rs=cn.execute("select id,title,name,sort,gl from zdy where (name='zdy5' or name='zdy6') and sort1=1 and set_open=1 order by gate1 asc")
		While Not rs.eof
			If rs("name")="zdy5" Then zdy5name=rs("title") : openzdy5=1
			If rs("name")="zdy6" Then zdy6name=rs("title") : openzdy6=1
			rs.movenext
		wend
		rs.close
		Dim v,s
		v=Split(no,"|")
		For s=0 To ubound(v)
			Select Case v(s)
			Case "客户名称"
			v(s)=arrNames(1)
			Case "拼音码"
			v(s)=arrNames(2)
			Case "客户编号"
			v(s)=arrNames(3)
			Case "客户电话"
			v(s)=arrNames(19)
			Case "客户传真"
			v(s)=arrNames(21)
			Case "客户地址"
			v(s)=arrNames(12)
			Case "客户邮编"
			v(s)=arrNames(13)
			Case "电子邮件"
			v(s)=arrNames(22)
			Case "客户网址"
			v(s)=arrNames(10)
			Case "客户备注"
			v(s)=arrNames(37)
			Case "客户分类"
			v(s)=arrNames(4)
			Case "跟进程度"
			v(s)=arrNames(5)
			Case "客户来源"
			v(s)=arrNames(6)
			Case "客户行业"
			v(s)=arrNames(8)
			Case "客户价值"
			v(s)=arrNames(9)
			Case "联系人姓名"
			v(s)=arrNames(17)
			End Select
		next
		rearrName=Join(v,"|")
	end function
	sub App_onCreateSearchBar
		dim rs , i, ii, iii , html1 , farray , disfarray , rv , morev ,narray
		dim disarray, hasc : hasc = false
		set rs = cn.execute("select x.cls,x.ID,x.fields,z.stopfields from home_search_config_def x left join home_search_config_us z on x.id= z.id and z.uid=" & info.user & " where x.usign='" & Info.uniqueName & "' and  isnull(z.stoped,0) = 0 and ( x.qxlb = 0 or (exists(select 1 from power y where ord=" & info.user & " and x.qxlb=y.sort1 and ((abs(qx_open-2)=1 and y.sort2<>19) or (y.sort2=19 and isnull(qx_open,1)<>1)) and x.qxlblist=y.sort2)  and not exists(select 1 from power y where qx_open=1 and ord=" & info.user & " and x.qxlb=y.sort1 and y.sort2=19))) order by isnull(z.sort,x.id) ")
'dim disarray, hasc : hasc = false
		i = 0
		while rs.eof = False
			hasc = true
			farray = split(rs.fields("fields").value,"|")
			if len(rs.fields("stopfields").value & "") > 0 then
				disarray = split(rs.fields("stopfields").value & "","|")
				for ii = 0 to ubound(disarray)
					for iii = 0 to ubound(farray)
						if farray(iii) = disarray(ii) then
							farray(iii) = ""
						end if
					next
				next
			end if
			If rs.fields("id").value&""="1" Then
				narray=rearrName(join(farray,"|"))
				While InStr(narray, "||")  > 0
					narray = Replace(narray, "||","|")
				wend
				narray = Replace(Replace(Replace("xxx" & narray & "xxx", "xxx|",""),"|xxx",""), "xxx", "")
			end if
			farray=join(farray,"|")
			if i < 3 then
				if i = 0 then
					html1 = "<a onclick='srTypeChane(this);return false;' id='srcitem" & i & "' onfocus='this.blur()' href='javascript:void(0)' value=""" & replace(farray,"""","&#34;") & """ class='a01'>" & rs.fields("cls").value & "</a>" + html1
'if i = 0 then
				else
					html1 = "<a onclick='srTypeChane(this);return false;' id='srcitem" & i & "' onfocus='this.blur()' href='javascript:void(0)' value=""" & replace(farray,"""","&#34;") & """ class='a02'>" & rs.fields("cls").value & "</a>" + html1
'if i = 0 then
				end if
				i = i + 1
'if i = 0 then
			else
				morev = morev + "#$" + rs.fields("cls").value & "|" & farray
'if i = 0 then
			end if
			rs.movenext
		wend
		rs.close
		Response.write "" & vbcrlf & "     <div class=""search-right""><div class=""link"" id='currsrfield'>无检索项</div>" & vbcrlf & "          <div style=""display:none"" id='currsrfield2' value="""
		if i = 0 then
			Response.write narray
			Response.write """></div>" & vbcrlf & "           <div class=""link2"" onmousedown='showsrfields(this)'>&nbsp;</div>" & vbcrlf & "          <form action='search.asp' method='post' style='display:inline' id='s_form' target='mainFrame'>" & vbcrlf & "                 <input type='hidden' name='s_cls' id='s_cls1'>" & vbcrlf & "                  <input type='hidden' name='s_fld' id='s_fld1'>" & vbcrlf & "                 <input type='hidden' name='s_key' id='s_key1'>" & vbcrlf & "            <input type='hidden' name='s_fname' id='s_fname1'>" & vbcrlf & "             </form>" & vbcrlf & "                 <input type=""text"" onclick='this.focus()' id='searchKeyText' onkeypress='return sKeyText_onkeydow(0)'/>" & vbcrlf & "                 <div class='sr_button' onclick='sKeyText_onkeydow(1)' onmouseover='this.className=""sr_button_over""' onmouseout='this.className=""sr_button""'></div>" & vbcrlf & " </div>" & vbcrlf & "  <div class=""link-search-right"">" & vbcrlf & "   "
			Response.write narray
		end if
		If Len(morev) > 0 then
			Response.write "" & vbcrlf & "     <a onmousedown='showMoreSearch(this);' onclick='return false' onfocus='this.blur()' href=""javascript:void(0)"" class=""a04"" value="""
			Response.write morev
			Response.write """>&nbsp;</a>" & vbcrlf & "      "
		ElseIf hasc Then
			Response.write "" & vbcrlf & "     <a click='return false' onfocus='this.blur()' href=""javascript:void(0)"" class=""a04_dis"">&nbsp;</a>" & vbcrlf & "  "
		end if
		Response.write html1
		Response.write "" & vbcrlf & "     </div>" & vbcrlf & "" & vbcrlf & "  <script type=""text/javascript"">" & vbcrlf & "           var tmsobj = document.getElementById(""srcitem0"");" & vbcrlf & "         if(tmsobj) {srTypeChane(tmsobj);}" & vbcrlf & "       </script>" & vbcrlf & ""
	end sub
	function getStimulusWords()
		dim rs
		set rs = cn.execute("select words from home_StimulusWords where uid=" & info.user)
		if rs.eof = false then
			getStimulusWords = rs.fields("words").value
		end if
		rs.close
		if len(trim(replace(getStimulusWords, vbcrlf , ""))) = 0 then
			getStimulusWords = "未设置激励语"
		else
			getStimulusWords = replace(replace(getStimulusWords,"<","&#60;"),">","&#62;")
		end if
	end function
	sub app_setStimulusWords
		dim word
		word = getStimulusWords()
		Response.write "" & vbcrlf & "     <table style='width:100%' cellspacing=0 cellpadding=0>" & vbcrlf & "  <tr><td style='height:10px'></td></tr>" & vbcrlf & "  <tr><td align='center'><textarea id=""StimulusWordsBox"" class='textbox' style='width:90%;height:70px'>"
		Response.write word
		Response.write "</textarea></td></tr>" & vbcrlf & "        <tr><td style='height:7px'></td></tr>" & vbcrlf & "   <tr>" & vbcrlf & "            <td align='center'><button class='button' style='width:60px' onclick='saveStimulusWords()'>确定</button>&nbsp;&nbsp;" & vbcrlf & "            <button class='button' style='width:60px' onclick='app.closeWindow(""StimulusWords"")'>取消</button></td>" & vbcrlf & "       </tr>" & vbcrlf & "   </table>" & vbcrlf & ""
	end sub
	sub app_saveStimulusWords
		dim word, rs
		word = request.form("word")
		set rs = server.CreateObject("adodb.recordset")
		rs.open "select * from home_StimulusWords where uid=" & info.user , cn , 1 , 3
		if rs.eof then
			rs.addnew
			rs.fields("uid").value = info.user
		end if
		rs.fields("words").value = word
		rs.update
		rs.close
	end sub
	function MessagePost(msgId)
		select case msgId
		case ""
		call Page_Load
		case "setStimulusWords"
		call App_setStimulusWords
		case "saveStimulusWords"
		call App_saveStimulusWords
		case "addMyMenuCls"
		call App_addMyMenuCls
		case "addMyMenu"
		call App_addMyMenu
		case "InitWork"
		call App_InitWork
		Case "onlines"
		Call App_onlines
		Case "help"
		Call App_help
		Case "GetMyMenuClsInfos"
		Call App_GetMyMenuClsInfos
		Case "deleteMyMenuCls"
		Call App_deleteMyMenuCls
		case else
		Response.write "no defualt"
		end select
	end function
	sub App_addMyMenu
		dim mtxt, mcls , mord , murl, rs
		mtxt = request.form("mtit")
		mcls = request.form("mcls")
		mord = abs(request.form("mord"))
		murl = request.form("murl")
		If request.form("utf8") = "1" Then
			mtxt = app.base64.urldecodebyutf8(mtxt)
			mcls = app.base64.urldecodebyutf8(mcls)
			mord = app.base64.urldecodebyutf8(mord)
			murl = app.base64.urldecodebyutf8(murl)
		end if
		set rs = server.CreateObject("adodb.recordset")
		rs.open "select * from wddh where id=" & mord & " and cateid=" & info.user, cn , 1, 3
		if rs.eof then
			rs.addnew
			rs.fields("ord").value = "t" & info.user & "_" & cstr(cdbl(now))
			rs.fields("date7").value = now
			rs.fields("gate1").value = cn.execute("select isnull(max(gate1),0) + 1 from wddh where cateid=" & info.user & " and sort=" & mcls).fields(0).value
'rs.fields("date7").value = now
			rs.fields("cateid").value = info.user
			rs.fields("sort1").value = 1
			rs.fields("sort2").value = 1
		end if
		rs.fields("title2").value = mtxt
		rs.fields("url").value = murl
		rs.fields("sort").value = mcls
		rs.update
		rs.close
		Response.write "1"
	end sub
	sub App_addMyMenuCls
		dim txt , rs , r
		txt = request.form("clsName")
		If request.form("utf8") = "1" Then
			txt = app.base64.urldecodebyutf8(txt)
		end if
		set rs = server.CreateObject("adodb.recordset")
		rs.open "select id,sort1,cateid,gate1,zt from  sort_dh where sort1 = '" & replace(txt,"'","''") & "' and cateid=" & info.user , cn , 1 , 3
		if rs.eof then
			rs.addnew
			rs.fields("sort1").value = txt
			rs.fields("cateid").value = info.user
			rs.fields("zt").value = 1
			rs.fields("gate1").value = cn.execute("select isnull(max(gate1),0) + 1 as r from  sort_dh where cateid=" & info.user).fields(0).value
'rs.fields("zt").value = 1
			rs.update
			rs.close
			set rs = cn.execute("select id from sort_dh where sort1 = '" & replace(txt,"'","''") & "' and cateid=" & info.user)
			if rs.eof = false then
				r = rs.fields(0).value
			else
				r = "未知原因导致添加不成功。"
			end if
			rs.close
		else
			r = 0
			rs.close
		end if
		set rs = nothing
		Response.write r
	end sub
	Function App_GetMyMenuClsInfos()
		Dim result, rs, clsid : clsid =  request.form("clsid")
		Set rs = cn.execute("select count(1) from wddh where cateid=" & Info.user & " and sort=" & clsid)
		result = rs.fields(0).value
		rs.close
		Response.write result
	end function
	Function App_deleteMyMenuCls()
		Dim result, rs, clsid : clsid =  request.form("clsid")
		cn.execute "delete wddh where cateid=" & Info.user & " and sort=" & clsid
		cn.execute "delete sort_dh where cateid=" & Info.user & "  and id=" & clsid
		Response.write "1"
	end function
	Sub App_OnCreateMenu(id)
		dim mvw
		set mvw = new MenuView
		mvw.id = id
		mvw.itemwidth = 90
		mvw.width = 360
		call AddTopMenus(mvw.menus,0)
		Response.write mvw.html
		set mvw = nothing
	end sub
	sub App_onCreateToolBar(id)
		dim tbar , rs , bn,models
		set tbar = new ToolBar
		tbar.id = "topbar"
		tbar.cellspacing = 12
		tbar.pagesize = 9
		tbar.itemwidth = 24
		set rs = cn.execute("exec home_gettopbarlist " & info.user & ",0,'" & ZBRuntime.ModulesText & "'")
		tbar.vpath = "../"
		while not rs.eof
			models=rs.fields("models").value&""
			if len(models)=0 then models=0
			if models>0 then
				if App.Power.existsModel(cstr(models)) then
					set bn = tbar.buttons.add
					bn.text = rs.fields("主题").value
					bn.value = rs.fields("打开方式").value & "??" & rs.fields("查看网址").value & "??" & rs.fields("即时网址").value & "??" &  rs.fields("ID").value
					bn.ico = rs.fields("图标").value
				end if
			else
				set bn = tbar.buttons.add
				bn.text = rs.fields("主题").value
				bn.value = rs.fields("打开方式").value & "??" & rs.fields("查看网址").value & "??" & rs.fields("即时网址").value & "??" &  rs.fields("ID").value
				bn.ico = rs.fields("图标").value
			end if
			rs.movenext
		wend
		rs.close
		Response.write tbar.html
		set tbar = nothing
	end sub
	sub AddTopMenus(ms,pid)
		dim rs, nm
		set rs = cn.execute("exec home_getTopUserMenus " & info.user & "," & pid & ",'" & Info.UniqueName & "'")
		while rs.eof = false
			dim module
			module = rs.fields("ModelExpress").value
			If ZBRuntime.MC(module) Or LEN(module) = 0 Then
				set nm = ms.add()
				nm.text = rs.fields("title").value
				nm.value =  replace(rs.fields("url").value & "","sys:","") & "??" &  rs.fields("otype").value & "??" & rs.fields("ID").value
			end if
			if rs.fields("mtype").value = 0 then
				call AddTopMenus(nm.menus,rs.fields("ID").value)
			end if
			rs.movenext
		wend
		rs.close
	end sub
	sub App_InitWork
		cn.execute "exec sys_onload_init " & info.user
		Response.write "ok"
	end sub
	Sub App_onlines
		Response.write "<script>window.location.href='../../SYSN/view/init/onlinelist.ashx?t="  & cdbl(now) & "'</script>"
	end sub
	
%>
