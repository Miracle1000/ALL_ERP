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
'cn.close
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
	class BillObjectCollection
		private objs, mcount
		public Property Get count
		count = mcount
		End property
		public sub class_initialize
			mcount = 0 : redim objs(0)
		end sub
		public sub add(item)
			dim index , nd, c
			mcount = mcount + 1 : index = mcount - 1
'dim index , nd, c
			if mcount > 1 Then redim preserve objs(index)
			set objs(index) = item
		end sub
		Public sub [Insert](ByVal item, ByVal index)
			Dim i
			ReDim Preserve objs(mcount)
			For i = mcount To index + 1 Step -1
'ReDim Preserve objs(mcount)
				Set objs(i) = objs(i-1)
'ReDim Preserve objs(mcount)
			next
			Set objs(index) =  item
			mcount = mcount + 1
'Set objs(index) =  item
		end sub
		Public Function Swap(ByVal item1, ByVal item2)
			If item2>=0 And item1>=0 then
				Dim o : Set o = objs(item1)
				Set objs(item1) = objs(item2)
				Set objs(item2) = o
				Set o = Nothing
			end if
		end function
		Public Default Function item(ByVal index)
			on error resume next
			Dim errtext, errnum
			If isnumeric(index) = 0 Then index = getIndex(index)
			Set item = objs(index)
			If Err.number = 0 Then Exit Function
			errtext = Err.description
			errnum = Err.number
			errtext = "Item(" & index & ")函数调用失败，" & errtext & "; "
			errtext = errtext & "count=" & mcount & "; "
			errtext = errtext & "ubound(元素集)=" & ubound(objs) & "; "
			errtext = errtext & "typename(元素0)=" & typename(objs(0)) & ";"
			Err.clear
			On Error GoTo 0
			err.Raise 908, "zbintel.erp.BillObjectCollection." & Info.version, errtext
		end function
		public sub clear
			mcount = 0 : redim objs(0)
		end sub
		Public Function getIndex(ByVal dbname)
			Dim i
			for i = 0 to mcount-1
'Dim i
				If LCase(objs(i).dbName) = LCase(dbname) then
					getIndex = i
					Exit function
				end if
			next
			getIndex = -1
			Exit function
		end function
		public sub remove(index)
			dim i
			If isnumeric(index) = 0 Then index = getIndex(index)
			mcount = mcount - 1
'If isnumeric(index) = 0 Then index = getIndex(index)
			on error resume next
			objs(index).dispose
			On Error GoTo 0
			Set objs(index) = nothing
			for i = index to  mcount-2
'Set objs(index) = nothing
				set objs(i) = objs(i+1)
'Set objs(index) = nothing
			next
			redim preserve objs(mcount-1)
'Set objs(index) = nothing
		end sub
		Public Sub Dispose
			Dim i
			for i = 0 to mcount-1
'Dim i
				objs(i).dispose
				Set objs(i) = nothing
			next
			mcount = 0 : redim objs(0)
		end sub
		Public Function GetItemByDbName(ByVal dbname )
			Dim i
			for i = 0 to mcount-1
'Dim i
				If LCase(objs(i).dbName) = LCase(dbname) then
					Set GetItemByDbName = objs(i)
					Exit function
				end if
			next
			Set GetItemByDbName = nothing
		end function
	end Class
	Class BillField
		Private m_maxlimit
		Public title
		Public dbname
		Public defvalue
		Public Formula
		Public visible
		Public edit
		Public js
		Public onlyRead
		Public rowspan
		Public disabled
		Public hidden
		Public source
		Public sourceCanNull
		Public parentgroup
		Public value
		Public linkvalue
		Public linktype
		Public save
		Public unit
		Public remark
		Public ApihelpString
		Public ByteValid
		Public NullSelectMsg
		Public minlimit
		Public maxValue
		Public minValue
		Private mIsNumber
		private mdbtype
		Private muitype
		Private mnotnull
		Private mcolspan
		Public width
		Public valign
		Public ValidCode
		Public ValidText
		Public canConvertHtml
		Public ImageAutoSize
		Public ImageVMLGraphic
		Public Inline
		Public openproc
		Public showImg
		Public ui
		Public url
		Public callback '移动端回调描述；格式：EventName:  EventProc; 例如 item.callback = "click:onXXXXClick"
		Public Property Get maxlimit
		If m_maxlimit = -1 Then
'Public Property Get maxlimit
			If muitype="number" Or muitype="money" Then
				maxlimit = 999999999
			else
				maxlimit = 50
			end if
		else
			maxlimit = m_maxlimit
		end if
		End Property
		Public Property Get bill
		Set bill = parentgroup.bill
		End Property
		Public Property let maxlimit(nvalue)
		m_maxlimit = nvalue
		End property
		Public Property Get colspan
		colspan = mcolspan
		End Property
		Public Property let colspan(nvalue)
		mcolspan = CLng(nvalue)
		If mcolspan < 1 Then mcolspan = 1
		If mcolspan > parentgroup.bill.maxspan Then mcolspan = parentgroup.bill.maxspan
		End Property
		Public Property Get dbbind
		If Len(dbname) = 0 Then
			dbbind = false
		else
			dbbind = InStr(dbname, "@") <> 1
		end if
		End Property
		Public Property Get notnull
		notnull = mnotnull
		End Property
		Public Property let notnull(nvalue)
		mnotnull = nvalue
		End Property
		Public Property Get IsNumber
		IsNumber = mIsNumber
		End Property
		Public Property Get uiType
		uiType = muitype
		End Property
		Public Property let uiType(nvalue)
		Dim types
		nvalue = LCase(Trim(nvalue))
		types = "|text|date|number|money|gate|gates|tel|person|chance|textarea|area|image|images|picture|select|selectlink|selectbox|checkbox|html|space|editor|hidden|radio|radiolink|radiosearch|datetime|listview|listtree|colorpicker|source|treebox|radiobox|linkbox|file|callbox|discount|boolbox|"
		If nvalue = "image" Or nvalue = "images" Or nvalue = "picture" Then
			If Me.parentgroup.bill.dbname="" Then
				err.Raise 908, "zbintel.erp.billfield." & Info.version, "设置image、images或picture类型的字段，必须先设置bill对象的【dbname】属性值。"
			end if
			Me.rowspan = 5
		end if
		If InStr(types,"|" & nvalue & "|") = 0 then
			err.Raise 908, "zbintel.erp.billfield." & Info.version, "“" & title & "”字段设置的UI类型“" & nvalue & "”无效， 目前支持的类型为：" & Replace(types, "|", "、")
		end if
		muitype = nvalue
		End Property
		Public Property get dbType
		dbType = mdbtype
		End Property
		Public Property let dbType(nvalue)
		nvalue = LCase(Trim(nvalue))
		Select Case nvalue
		Case "int"        : mIsNumber = True
		Case "float" : mIsNumber = true
		Case "money" : mIsNumber = true
		Case "commprice","salesprice","storeprice","financeprice" : mIsNumber = true
		Case "numeric" : mIsNumber = true
		Case "number" : mIsNumber = true
		Case "datetime" : mIsNumber = false
		Case "varchar" : mIsNumber = false
		Case "text" : mIsNumber = false
		Case "zip" : mIsNumber = false
		Case "phone" : mIsNumber = False
		Case "mobile" : mIsNumber = False
		Case "email" : mIsNumber = False
		Case "qq" : mIsNumber = False
		Case "object" : misNumber = False
		Case "null" : misnumber = False
		Case Else
		err.Raise 908, "zbintel.erp.billfield." & Info.version, "“" & title & "”字段设置的数据类型“" & nvalue & "”无效， 目前支持的类型为：int、float、money、numeric、datetime、varchar、text、object、null。"
		End Select
		mdbtype = nvalue
		End Property
		Public Sub setLink()
		end sub
		Public Sub Class_Initialize()
			ByteValid = False
			m_maxlimit = -1
'ByteValid = False
			minlimit = 0
			edit = True
			visible = True
			notnull = False
			uiType = "text"
			dbType = "varchar"
			onlyRead = False
			mcolspan = 1
			rowspan = 1
			disabled = False
			hidden = False
			mIsNumber = false
			save = True
			value = null
			inline = True
			canConvertHtml = True
			sourceCanNull = False
			ImageAutoSize = False
			ImageVMLGraphic = False
			openproc = False
			showImg = False
		end sub
		Public Function SwapField(ByVal dbName)
			parentgroup.fields.Swap Me.dbname, dbname
		end function
	End Class
	class BillFieldCollection
		private objs
		Public ParentGroup
		Public Property get count : count = objs.count : End Property
		public sub class_initialize : Set objs = New BillObjectCollection : end Sub
		Public Function Add(ByVal title, ByVal dbname)
			dim c : Set c = New BillField
			c.title = title
			c.dbname = dbname
			Set c.ParentGroup = ParentGroup
			objs.add c
			set add = c
		end function
		Public Function Swap(ByVal item1, ByVal item2)
			If isnumeric(item1) And isnumeric(item2) Then
				objs.Swap item1, item2
			else
				objs.Swap objs.getIndex(item1), objs.getIndex(item2)
			end if
		end function
		Public Function addHidden(ByVal dbname, ByVal dbType,  ByVal defvalue)
			Dim r
			Set r = add1(dbname, dbname, "hidden", dbType, false, false,  false , true)
			r.defvalue = defvalue
			If r.dbbind = false Then
				r.value = r.defvalue
			end if
			Set addHidden = r
		end function
		Public Function addText(ByVal title,  ByVal defvalue)
			Dim r
			Set r = add1(title, "@" & title, "text", "varchar", false, false,  false , true)
			If InStr(defvalue,"@")=1 Then
				r.dbname = Replace(defvalue, "@", "")
			else
				r.defvalue = defvalue
				If r.dbbind = false Then
					r.value = r.defvalue
				end if
			end if
			r.edit = False
			r.save = False
			Set addText = r
		end function
		public function add1(ByVal title,ByVal dbname,ByVal uiType,ByVal dbType,ByVal visible,ByVal edit,ByVal notnull, ByVal onlyRead)
			dim c : Set c = New BillField
			Set c.ParentGroup = ParentGroup
			c.title = title
			c.dbname = dbname
			c.uitype = uitype
			c.dbtype = dbtype
			c.edit = edit
			c.notnull = notnull
			c.onlyRead = onlyRead
			c.visible = visible
			c.colspan = 1
			c.rowspan = 1
			objs.add c
			set add1 = c
		end function
		public Function add2(ByVal title,ByVal dbname,ByVal uiType,ByVal dbType,ByVal visible,ByVal edit,ByVal notnull ,ByVal onlyRead, ByVal colspan, ByVal rowspan)
			Dim r
			Set r = add1(title, dbname, uiType, dbType, visible, edit,  notnull ,  onlyRead)
			r.colspan = colspan
			r.rowspan = rowspan
			Set add2 = r
		end function
		Public Function addsortonehy(ByVal title, ByVal dbname, ByVal uiType, ByVal dbType,ByVal visible,  ByVal edit, ByVal notnull, ByVal sortonehyId)
			Dim r
			Set r = add1(title, dbname, uiType, dbType, visible, edit,  notnull , true)
			r.source = "sortonehy:" & sortonehyId
			Set addsortonehy = r
		end function
		Public Function addHtml(ByVal title, ByVal exechtmlProc, ByVal colspan, ByVal rowspan)
			Dim r
			Set r = add1(title, "", "html", "object", true, true,  false , true)
			r.source = exechtmlProc
			r.colspan = colspan
			r.rowspan = rowspan
			Set addHtml = r
		end function
		Public Function addoptions(ByVal title,ByVal dbname,ByVal uiType,ByVal dbType,ByVal visible,ByVal edit,ByVal notnull, ByVal onlyRead, ByVal source)
			Dim r
			Set r = add1(title, dbname, uiType, dbType, visible, edit,  notnull ,  onlyRead)
			r.source = source
			Set addoptions = r
		end function
		Public Function addListView(ByVal title, ByVal dbname)
			dim c : Set c = New BillField
			Set c.ParentGroup = ParentGroup
			c.title = title
			c.dbname = dbname
			c.uitype = "listview"
			c.dbtype = "object"
			c.colspan = ParentGroup.bill.maxspan
			objs.add c
			set addListView = c
		end function
		Public Function addListTree(ByVal title, ByVal dbname)
			dim c : Set c = New BillField
			Set c.ParentGroup = ParentGroup
			c.title = title
			c.dbname = dbname
			c.uitype = "listtree"
			c.dbtype = "object"
			c.colspan = ParentGroup.bill.maxspan
			objs.add c
			set addListTree = c
		end function
		public sub clear : objs.clear : end Sub
		public sub remove(index) : objs.remove index : end Sub
		Public Function GetItemByDbName(ByVal dbname) : Set  GetItemByDbName = objs.GetItemByDbName(dbname) : End Function
		Public Sub addZdyFields()
		end sub
		Public Sub addSpaceCell
			call add1("&nbsp;", "", "space", "null", true, false,  false ,  true)
		end sub
		Public Default Function Item(ByVal index) : Set item = objs.item(index) : End function
		public function Insert(ByVal index, ByVal title,ByVal dbname,ByVal uiType,ByVal dbType,ByVal visible,ByVal edit,ByVal notnull, ByVal onlyRead)
			dim c : Set c = New BillField
			Set c.ParentGroup = ParentGroup
			c.title = title
			c.dbname = dbname
			c.uitype = uitype
			c.dbtype = dbtype
			c.edit = edit
			c.notnull = notnull
			c.visible = visible
			c.colspan = 1
			c.rowspan = 1
			objs.insert c, index
			set Insert = c
		end function
	end Class
	Class BillFieldGroup
		Public title
		Public dbname
		Public fields
		Public showbar
		Public visible
		Public bill
		Public buttons
		Public bar
		Public barHTML
		Public foldable
		Public Isfold
		public sub class_initialize
			Set fields = New BillFieldCollection
			Set buttons =  new BillButtonCollection
			Set fields.ParentGroup = Me
			visible = True
			showbar = True
			foldable = True
			Isfold = false
		end sub
		Public Sub dispose
			fields.dispose
			Set fields = nothing
		end sub
	End Class
	class BillFieldGroupCollection
		private objs
		Public bill
		Public Property get count : count = objs.count : End Property
		public sub class_initialize : Set objs = New BillObjectCollection : end Sub
		public function add(title, dbname)
			dim c : Set c = New BillFieldGroup
			c.title = title
			c.dbname = dbname
			Set c.bill = bill
			objs.add c
			set add = c
		end function
		public function Insert(ByVal index, ByVal title,ByVal dbname)
			dim c : Set c = New BillFieldGroup
			c.title = title
			c.dbname = dbname
			Set c.bill = bill
			objs.insert c, index
			set Insert = c
		end function
		public sub clear : objs.clear : end Sub
		public sub remove(index) : objs.remove index : end Sub
		Public Function GetItemByDbName(ByVal dbname) : Set  GetItemByDbName = objs.GetItemByDbName(dbname) : End Function
		Public Default Function Item(ByVal index) : Set item = objs.item(index) : End function
	end Class
	Class BillButtonItem
		Public title
		Public dbname
		Public onclick
		Public TopVisible
		Public BottomVisible
	End class
	class BillButtonCollection
		private objs
		Public Property get count
		count = objs.count
		End Property
		public sub class_initialize : Set objs = New BillObjectCollection : end Sub
		public function add(title, name, onclick, TopVisible, BottomVisible)
			dim c : Set c = New BillButtonItem
			c.title = title
			c.dbname = name
			c.onclick = onclick
			c.TopVisible = TopVisible
			c.BottomVisible = BottomVisible
			objs.add c
			set add = c
		end function
		public function additem(title, name, onclick)
			dim c : Set c = New BillButtonItem
			c.title = title
			c.dbname = name
			c.onclick = onclick
			c.TopVisible = true
			c.BottomVisible = false
			objs.add c
			set additem = c
		end function
		public function Insert(title, name, onclick, TopVisible, BottomVisible, index)
			dim c : Set c = New BillButtonItem
			c.title = title
			c.dbname = name
			c.onclick = onclick
			c.TopVisible = TopVisible
			c.BottomVisible = BottomVisible
			objs.insert c, index
			set  [Insert] = c
		end function
		public sub clear : objs.clear : end Sub
		public sub remove(index) : objs.remove index : end Sub
		Public Function GetItemByDbName(ByVal dbname) : Set  GetItemByDbName = objs.GetItemByDbName(dbname) : End Function
		Public Default Function Item(ByVal index) : Set item = objs.item(index) : End function
	end Class
	Class BillPage
		Public title
		Public headerhtml
		Public groups
		Public sql
		Public uitype
		Private mFields
		Private mButtons
		Private mIsAddModel
		Private mdbname
		Private mrs
		Private m_id
		Public debug
		Public FinanDBModel
		Public ahonegp
		Public loadEasyUI
		Public loadJs
		Public loadVml
		Public cancopy
		Public canscan
		Public cansave
		Public canApprove
		Public needSetApprove
		Public canupdate
		Public printMode
		Public candel
		Public Vborder
		Public canPrintPage
		Public edit
		Public mobBill
		Public extra
		Public approve
		Public reBackApprove
		Public neword
		Public MobileRefresh
		Private mmaxspan, mcolwidths
		Public Property Get maxspan
		maxspan = mmaxspan
		End Property
		Public Property let maxspan(ByVal v)
		Dim i, w_c: mmaxspan = CLng(v)
		ReDim mcolwidths(mmaxspan*2-1)
'Dim i, w_c: mmaxspan = CLng(v)
		w_c = CLng(100/mmaxspan)
		For i = 0 To mmaxspan*2-1
'w_c = CLng(100/mmaxspan)
			mcolwidths(i) = CLng(w_c*0.333*(1+ (i Mod 2) ))
'w_c = CLng(100/mmaxspan)
		next
		End Property
		Public Property Get ColWidth(ByVal index)
		ColWidth = mcolwidths(index)
		End Property
		Public Property let ColWidth(ByVal index, ByVal v)
		mcolwidths(index) = CLng(v)
		End Property
		public Property Get dbname
		dbname = mdbname
		End Property
		public  Property let dbname(nv)
		If Len(nv) > 20 Then
			Err.raise -908, "BillPage",  "“" & nv & "”不是有效的【dbname】属性值， 单据的【dbname】属性值只能是长度不超过20的字符串。"
'If Len(nv) > 20 Then
		end if
		mdbname = nv
		End Property
		Public Property Get Data
		If mrs Is Nothing And Len(sql) > 0 Then
			Call LoadDBData
		end if
		Set data = mrs
		End Property
		Public Property Get IsAddModel
		IsAddModel = mIsAddModel
		End Property
		Public Property Get Fields
		Set Fields =  mFields
		End Property
		Public Property Get Buttons
		Set Buttons =  mButtons
		End Property
		Public Sub setCurrGroup(ByVal dbname)
			Dim obj
			Set obj = groups.GetItemByDbName(dbname)
			If obj is Nothing Then
				Err.raise -908, "BillPage", "调用setCurrGroup函数失败，组内部名称“" & dbname & "”无效。"
'If obj is Nothing Then
			end if
			Set mfields =  obj.fields
		end sub
		Public Function AddTool(ByVal caption, ByVal ico, ByVal action,ByVal  url, ByVal method, ByVal target)
			If Me.mobBill Is Nothing Then Exit Function
			Set AddTool = Me.mobBill.addTool(caption,  ico,  action,  url,  method,  target)
		end function
		Public function AddCurrGroup(ByVal title, ByVal dbname)
			Set AddCurrGroup = groups.add(title, dbname)
			setCurrGroup dbname
		end function
		Public function InsertGroup(ByVal index ,ByVal title, ByVal dbname)
			Set InsertGroup = groups.insert(index, title, dbname)
			setCurrGroup dbname
		end function
		public function setBillId(byval newid)
			if len(m_id & "") = 0 or m_id & ""= "0" then
				m_id = newid
			else
				err.raise 908, "ZBRLibary", "该状态下禁止修改单据ID"
			end if
		end function
		Public Sub setBillIdWithoutLimit(ByVal newid)
			m_id = newid
		end sub
		Public Sub  Class_Initialize
			Set mrs = nothing
			Set groups = New BillFieldGroupCollection
			Set groups.bill = Me
			Set mButtons = New BillButtonCollection
			ahonegp = True
			loadEasyUI = False
			loadJs = False
			cancopy = True
			canscan = False
			loadVml = False
			cansave     = False
			canApprove = False
			needSetApprove= False
			reBackApprove =False
			canupdate= False
			printMode = 0
			candel= False
			canPrintPage = False
			Vborder = True
			edit = True
			maxspan = 3
			mIsAddModel = (request.querystring("ord") = "")
			FinanDBModel = False
			headerhtml = ""
			Me.debug = (request.querystring("debug") = "1" And Info.isadmin)
			Set mFields = groups.add("基本信息", "base").fields
			mButtons.add "保存", "save", "bill.doSave(this)", true, True
			mButtons.add "增加", "insert", "bill.doSaveAdd(this)", false, false
			mButtons.add "重填", "reset", "bill.doReset(this)", true, True
			Set mobBill = nothing
		end sub
		Private Sub Class_Terminate()
			on error resume next
			groups.dispose
			Set groups = Nothing
			If Not mrs Is Nothing then
				mrs.close
				Set mrs = Nothing
			end if
			Err.clear
		end sub
		public Property Get ID
		If Len(m_id & "") = 0 Then
			m_id = app.gettext("ord","数据唯一标识", "整数，泛指当前单据的数据标识值，如客户ID、合同ID等等，可从相应的列表接口获取该值。","0")
			If len(m_id) > 20 Or InStr(m_id,"PW")=1 Then
				m_id = app.base64.deurl(m_id)
			end if
			If Len(m_id) = 0 Or isnumeric(m_id) =  0  Then
				m_id = 0
			end if
		end if
		ID = m_id
		End Property
		Private Function GetMainSql()
			GetMainSql = Replace(sql, "@id", id, 1,-1,1)
'Private Function GetMainSql()
		end function
		Public Function FormTexts(ByVal kname, ByVal index)
			If index & "" = "" Then
				FormTexts = Replace(request(kname) & "", "'", "''")
			else
				FormTexts = Replace(request(kname)(index) & "", "'", "''")
			end if
		end function
		Public Function FormNums(ByVal kname, ByVal index)
			If index & "" = "" Then
				FormNums = cdbl(request(kname)) & ""
			else
				FormNums = cdbl(request(kname)(index)) & ""
			end if
		end function
		Public Function ReplaceFieldAttr(byval code, ByVal codetype)
			Dim  gp, fd , i, ii, fs, dtype
			For i = 0 To groups.count-1
'Dim  gp, fd , i, ii, fs, dtype
				Set gp = groups(i)
				For ii = 0 To gp.fields.count - 1
'Set gp = groups(i)
					Set fd = gp.fields(ii)
					Dim v : v = app.iif(me.isAddmodel , fd.defvalue, fd.value)
					dtype = LCase(fd.dbtype)
					If Len(fd.dbname) > 0 Then
						If fd.isnumber Then
							If Len(v & "") = 0 Then
								v = app.iif(codetype=0, "NULL", "0")
							end if
							code = Replace(code, "@" & fd.dbname, v, 1, -1, 1)
							v = app.iif(codetype=0, "NULL", "0")
						else
							If codetype=0 Then
								v = "'" & Replace(v & "", "'", "''") & "'"
							elseIf codetype=1 Then
								v = """" & Replace(Replace(v & "", """", """"""), vbcrlf, """ & vbcrlf & """) & """"
							ElseIf codetype=2 then
								v = v & ""
							else
							end if
							code = Replace(code, "@" & fd.dbname, v, 1, -1, 1)
							v = v & ""
						end if
					end if
				next
			next
			ReplaceFieldAttr = Replace(code, "@id", id, 1,-1,1)
			v = v & ""
		end function
		Public Property Get DataFields
		Call LoadDBData
		Set DataFields =  mrs.fields
		End Property
		Public Property Get exists
		Call LoadDBData
		exists =(mrs.eof=false)
		End Property
		Private Sub LoadDBData
			on error resume next
			If Not mrs Is Nothing Then Exit Sub
			Err.clear
			If Me.FinanDBModel Then
				Set mrs = app.cRecord(GetMainSql)
			else
				Set mrs = cn.execute(GetMainSql)
			end if
			Dim errn : errn = Err.number
			Dim errt : errt = Err.description
			On Error GoTo 0
			If errn <> 0 Then
				Err.raise 908, "BillClass", "单据加载主数据源失败，对应sql为：" & GetMainSql & errt
			end if
		end sub
		Public Function LoadData
			Dim  gp, fd , i, ii, fs, hasdefproc, err_n, err_t
			mIsAddModel = (id = 0)
			hasdefproc = app.existsproc("Bill_OnLoadFieldData")
			If mIsAddModel = false Then
				Call LoadDBData
				If mrs.eof = False then
					Set fs = mrs.fields
					For i = 0 To groups.count-1
'Set fs = mrs.fields
						Set gp = groups(i)
						For ii = 0 To gp.fields.count - 1
'Set gp = groups(i)
							Set fd = gp.fields(ii)
							If Len(fd.dbname) > 0 And fd.dbbind = true Then
								Call TrySetValue(fd, mrs)
							end if
						next
					next
				end if
			end if
			If hasdefproc Then
				Call Bill_OnLoadFieldData(me)
			end if
			LoadData = True
		end function
		Public Sub LoadCallBacktData
		end sub
		Private Sub TrySetValue(field, rs)
			on error resume next
			Dim errnum
			If  LCase(typename(field.value)) = "null" Then
				field.value = rs(field.dbname).value
			end if
			errnum = Err.number
			Err.clear
			On Error GoTo 0
			If errnum = 3265 Then
				err.Raise 908, "zbintel.erp.sdk.billclass." & Info.version, "字段【" & field.title & "】的dbname值“" & field.dbname & "”无效，非数据源字段DBName值必须加@符号。"
			end if
		end sub
		Public sub GetSourceData(ByRef options, ByVal field)
			Dim source : source = field.source
			Dim dataobj, code, i, nm, n1, n2
			Dim sql, rs, c, errnum, errtext
			c = -1
'Dim sql, rs, c, errnum, errtext
			If InStr(1,source, "options:", 1) = 1 Then
				source = Replace(source, "=", Chr(2))
				source = Replace(source, ",", Chr(1))
				source = Replace(source, ";", Chr(1))
				source = Replace(source, "options:", "text:")
			end if
			If InStr(1,source, "sortonehy:", 1) = 1 Then
				source = Replace(source, "sortonehy:", "", 1, -1, 1)
'If InStr(1,source, "sortonehy:", 1) = 1 Then
				sql = "select sort1, ord from sortonehy where gate2=" & source & " order by gate1 desc"
			ElseIf InStr(1,source, "sql:",1) = 1 Then
				source = Replace(Chr(1) & source, Chr(1) & "sql:", "", 1, -1, 1)
'ElseIf InStr(1,source, "sql:",1) = 1 Then
				sql = me.ReplaceFieldAttr(source, 0)
			ElseIf InStr(1,source, "snumber:", 1) = 1 Then
				nm = Split("0,0," & Replace(source, "snumber:",""), ",")
				n1 = CLng(nm(ubound(nm)-1))
'nm = Split("0,0," & Replace(source, "snumber:",""), ",")
				n2 = CLng(nm(ubound(nm)))
				ReDim options(n2-n1)
'n2 = CLng(nm(ubound(nm)))
				For i = n1 To n2
					options(i-n1) = Array(i, i)
'For i = n1 To n2
				next
				Exit sub
			ElseIf InStr(1,source, "asp:",1) = 1 Then
				source = Replace(Chr(1) & source, Chr(1) & "asp:", "", 1, -1, 1)
'ElseIf InStr(1,source, "asp:",1) = 1 Then
				code = me.ReplaceFieldAttr(source,1)
				on error resume next
				Set dataobj = eval("" & code & "")
				errnum = Err.number
				errtext = Err.description
				On Error GoTo 0
				If errnum <> 0 Then
					If errnum = 424 then
						err.Raise 908, "zbintel.erp.sdk.billclass." & Info.version, "加载数据源" & field.source & " 失败；该数据源返回值不是有效的BillAspFieldSoureData对象。"
					else
						err.Raise 908, "zbintel.erp.sdk.billclass." & Info.version, "加载数据源" & field.source & " 失败；实际执行代码：" & code & "；失败原因：" & errtext
					end if
				else
					If typename(dataobj) <> "BillAspFieldSoureData" Then
						err.Raise 908, "zbintel.erp.sdk.billclass." & Info.version, "加载数据源" & field.source & " 失败；该数据源返回值不是有效的BillAspFieldSoureData对象。"
					end if
				end if
				If dataobj.hasdata then
					options = dataobj.data
					dataobj.dispose
				end if
				Set dataobj = nothing
				Exit Sub
			ElseIf InStr(1,source, "text:",1) = 1 Then
				source = Replace(Chr(5) & source, Chr(5) & "text:", "", 1, -1, 1)
'ElseIf InStr(1,source, "text:",1) = 1 Then
				If len(Trim(source)) > 0 then
					options = Split(me.ReplaceFieldAttr(source & "", 2), Chr(1))
					For i = 0 To ubound(options)
						If InStr(options(i), Chr(2)) > 0 Then
							options(i) = Split(options(i), Chr(2))
						else
							options(i) = array(options(i), options(i))
						end if
					next
				else
					If field.sourceCanNull = false then
						err.Raise 908, "zbintel.erp.sdk.billclass." & Info.version, "数据源text类型的数据内容不能为空。"
					end if
				end if
				Exit sub
			else
				err.Raise 908, "zbintel.erp.sdk.billclass." & Info.version, "无法识别数据源" & field.source & "的类型，目前支持的数据源的类型：sortonehy、sql、asp、text、options。"
			end if
			If Len(sql) > 0 Then
				on error resume next
				Set rs = cn.execute(sql)
				errnum = Err.number
				errtext = Err.description
				On Error GoTo 0
				If errnum <> 0 Then
					err.Raise 908, "zbintel.erp.sdk.billclass." & Info.version, "加载数据源" & field.source & " 失败；实际执行代码：" & sql & "；失败原因：" & errtext
				end if
				While rs.eof = False
					c = c + 1
'While rs.eof = False
					If c = 0 Then
						ReDim options(0)
					else
						ReDim Preserve options(c)
					end if
					options(c) = array(rs(0).value , rs(1).value)
					rs.movenext
				wend
				rs.close
			end if
		end sub
		Public function LoadPostData()
			LoadPostData = true
		end function
		Public function DoDataValids
			DoDataValids = true
			end function
		Public Sub alert(msg)
			Response.write "<script>alert(""" & Replace(Replace(msg, vbcrlf, "\r\n"), """", "\""") & """);</script>"
		end sub
		Public Sub showSaveResultEx(ByVal message, ByVal closeWindow, ByVal RefreshTarget, ByVal newUrl)
			If app.ismobile = False Then
				Response.write "<meta http-equiv='content-type' content='text/html;charset=UTF-8'>"
'If app.ismobile = False Then
				Response.write "<script language='javascript'>var tmpmsg=""" & Replace(Replace(Replace(message, "\", "\\"), vbcrlf , "\r\n"), """", "\""") & """;if(parent.bill){parent.bill.showSaveResultEx(tmpmsg," & Abs(closeWindow) & ",""" & Trim(RefreshTarget) & """, """ & Replace(newUrl, """", "\""") & """);}else{(window.app?app.Alert:alert)(tmpmsg);if(top==this){window.close()}else{history.go(-1);}}</script>"
'If app.ismobile = False Then
			else
				Dim target
				If closeWindow Then
					target = "close"
				else
					target = RefreshTarget
				end if
				With app.mobile.document.body.CreateModel("message","")
				.Text = message
				.target =target
				.url = newUrl
				End With
			end if
		end sub
		Public Sub showSaveResult(ByVal message)
			Call showSaveResultEx(message, true, "opener", "")
		end sub
		Public Sub showSaveResult2(ByVal message, ByVal listUrl)
			Call showSaveResultEx(message, false, "self", listUrl)
		end sub
		Public Sub showSaveAlert(ByVal message)
			Call showSaveResultEx(message, false, "self", "")
		end sub
		Public Sub ReportBack(ByVal message)
			Response.write "<meta http-equiv='content-type' content='text/html;charset=UTF-8'>"
'Public Sub ReportBack(ByVal message)
			Response.write "<script language='javascript'>" & vbcrlf
			If message<> "" Then
				Response.write "window.alert(""" & Replace(message, """","\""") & """);"
			end if
			Response.write "if(parent.parent.ReportURLBack){parent.parent.ReportURLBack();}else{alert('ReportBack函数只适合单据页面位于列表页面的子框架中时刷新\n\n如果是要刷新父列表，建议调用ReportRefresh函数。')}"
			Response.write "</script>"
		end sub
		Public Sub ReportRefresh(ByVal message)
			Response.write "<meta http-equiv='content-type' content='text/html;charset=UTF-8'>"
'Public Sub ReportRefresh(ByVal message)
			Response.write "<script language='javascript'>" & vbcrlf
			If message<> "" Then
				Response.write "window.alert(""" & Replace(message, """","\""") & """);"
			end if
			Response.write "top.opener.DoRefresh();top.close();"
			Response.write "</script>"
		end sub
		Public Sub deleteTempRes(ByVal sourceKey)
			Dim rs
			Set rs = cn.execute("select id, fpath from sys_upload_res where id1=0 and addcate=" & Info.user & " and charindex('" & sourceKey & "',source)=1")
			While rs.eof = False
				on error resume next
				app.sdk.file.deletefile rs("fpath").value
				cn.execute "delete sys_upload_res where id=" & rs("id").value
				rs.movenext
			wend
			rs.close
		end sub
		Public Sub CreateApiHelp(ByVal mtype)
			Dim rmk, defv
			Select Case mtype
			Case "save":
			Dim i,ii,gp,fd, bill, tmv
			app.mobile.clearHelpField
			Set bill = app.mobile.document.body.bill
			If InStr(1, app.url, "custom/add.asp", 1) = 0 then
				app.mobile.addHelpField  "ord",  "数据唯一标识", "整型，通用型字段，一般添加新资料时不需要传该字段，修改资料时为对应资料的唯一标识字段值，可从相应的列表接口获取。", ""
			else
				app.mobile.addHelpField  "ord",  "数据唯一标识", "整型，通用型字段，添加新客户需要传【分配新客户ID】接口返回的标识值，修改客户资料时传已经存在的客户资料标识即可，可从客户列表接口获取该值", ""
			end if
			For i = 0 To bill.groups.count-1
				Set gp = bill.groups.item(i)
				For ii = 0 To gp.fields.count - 1
'Set gp = bill.groups.item(i)
					Set fd = gp.fields.item(ii)
					If fd.post = "1" And Len(fd.id)>0 Then
						rmk = getApiRemark(fd)
						defv =  fd.value
						If instr(rmk,"枚举类型，如：")>0 Then
							tmv = Split(rmk,"枚举类型，如：")(1)
							If InStr(tmv,":") > 0 then
								defv = Split(tmv,":")(0)
							else
								rmk = Replace(rmk,"枚举类型，如：","")
							end if
						end if
						If instr(rmk,"来自树结构数据：")>0 Then
							Dim nodes
							Set nodes = fd.source.trees.nodes
							defv = ""
							while nodes.count > 0
								defv = defv & nodes.item(0).value
								Set nodes = nodes.item(0).nodes
								If nodes.count > 0 Then defv = defv & ","
							wend
						end if
						app.mobile.addHelpField  fd.id,  fd.caption, rmk, defv
					end if
				next
			next
			Case "new":
			End select
		end sub
		Private Function getApiRemark(fd)
			Dim lx, result, i, item, c, sourceurl, rs
			Select Case LCase(fd.dbtype)
			Case "float","numeric","number","money","commprice","salesprice","storeprice","financeprice":
			result = "数字"
			If fd.notnull Then result = result & "，必填"
			Select Case LCase(fd.type_)
			Case "float","numeric","number","money","commprice","salesprice","storeprice","financeprice"
			If fd.maxl > 0 Then  result = result & "，" & fd.maxl & "以内"
			End Select
			Case "int":
			result = "整型"
			If fd.notnull Then result = result & "，必填"
			Case "datetime" :
			result = "日期"
			If fd.notnull Then result = result & "，必填"
			Case Else
			result = "文本"
			If fd.notnull Then result = result & "，必填"
			If fd.maxl > 0 Then  result = result & "，" & fd.maxl & "字以内"
			End Select
			If Not fd.source Is Nothing Then
				If Trim(fd.source.type_) = "options" Then
					sourceurl = ""
					result = result & "，枚举类型，如："
					c = fd.source.options.count
					If c >5 Then c = 5
					For i = 0 To c-1
'If c >5 Then c = 5
						Set item = fd.source.options.item(i)
						result = result & item.v & ":" & item.n
						If i = 0 And isnumeric(item.v) Then
							Set rs = cn.execute("select gate2 from sortonehy where ord='" & item.v & "' and sort1='" & Replace(item.n,"'","''") & "'" )
							If rs.eof = False Then
								sourceurl = app.virpath & "mobilephone/source.asp?enumid=" & rs("gate2").value
								sourceurl = " <br>来自接口：<a href='" & app.virpath & "mobilephone/source.asp?enumid=" & rs("gate2").value & "&apihelp=1' target=_blank>/mobilephone/source.asp?enumid=" & rs("gate2").value & "</a>"
							end if
							rs.close
							set rs = nothing
						end if
						If i < c-1 Then
							result = result & "、"
						end if
					next
					result = result & "。<b class='vbk'>" & sourceurl & "</b>"
					If Len(sourceurl) > 0 And InStr(result, "文本") = 1 Then
						result = Replace(result, "文本，" & fd.maxl & "字以内", "整型", 1, 1, 1)
					end if
				end if
				If fd.source.type_ = "trees" Then
					result = result & "，<b class='vbk'> 来自树结构数据：<a href='javascript:void(0)' onclick='showtreeSource(this)'>点击查看数据</a>。</b><span style='display:none' istree=1>" & app.getJSON(fd.source.trees) & "</span>"
				end if
			end if
			If fd.edit And fd.url <> "" Then
				If InStr(result,"整数") > 0 Or InStr(result,"整型") > 0 Then
					Dim url, urls, urls2 : url = fd.url
					If InStr(url,"@")>0 And InStr(url,"?")>0 Then
						urls = Split(url,"?")
						urls2 = Split(urls(1),"&")
						For i = 0 To ubound(urls2)
							If InStr(urls2(i),"@")>0 Then
								urls2(i) = ""
							end if
						next
						urls(1) = Join(urls2,"&")
						url = sdk.ClearUrl(Join(urls,"?"))
					end if
					result = result & " <b class='vbk'> 来自接口：<a href='" & app.virpath & url & "&apihelp=1" & "' target=_blank>" & url & "</a></b>"
				end if
			end if
			getApiRemark = result
		end function
	End Class
	Class BillAspFieldSoureData
		Private mdata, c, mhasdata
		Public Sub Add(ByVal name, ByVal value)
			c = c + 1
'Public Sub Add(ByVal name, ByVal value)
			If c = 0 Then
				ReDim mdata(c)
			else
				ReDim Preserve mdata(c)
			end if
			mhasdata = true
			mdata(c) = array(name, value)
		end sub
		Private Sub Class_Initialize()
			c = -1
'Private Sub Class_Initialize()
			mhasdata = false
		end sub
		Public Property Get data
		data = mdata
		End Property
		Public Property Get hasdata
		hasdata = mhasdata
		End Property
		Public Sub dispose
			If hasdata Then
				Erase mdata
			end if
		end sub
	End Class
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
'Exit property
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
's = Replace(s,"&tagData","'" & Replace(tagData,"'","''") & "'")
			s = Replace(s,"&pagesize", Me.pagesize ,1,-1,1)
's = Replace(s,"&tagData","'" & Replace(tagData,"'","''") & "'")
			s = Replace(s,"&pageindex", Me.pageindex ,1,-1,1)
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
'sumcindex = 0
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
								addhtml "<div class='lvwtooldiv' resetTransparent id='lvwtooldiv_" & id & "'><script>__lvw_je_inittoptooldiv(""" & id & """);</script></div>"
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
												'addhtml " eonchange=""" & h.onchange & """ "
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
'Set fh = headers(n)
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
'v = c.formattext & ""
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
	Class customSetFieldClass
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
		Set rs = cn.execute(sql)
		While rs.eof = False
			Set field = New customSetFieldClass
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
		hasOpenZdy = (cn.execute("select 1 from zdy where sort1="& sort &" and set_open = 1 ").eof = false)
	end function
	Function GetZdyFields(sort)
		If sort&""="" Then sort = 1
		Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim rs ,sql, field
		sql = "select * from zdy where sort1="& sort &" order by gate1 asc "
		Set rs = cn.execute(sql)
		While rs.eof = False
			Set field = New customSetFieldClass
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
		If sort = 21 Then
			sql = "SELECT 1  FROM dbo.sys_sdk_BillFieldInfo WHERE BillType =16001 AND IsUsed = 1"
		else
			sql = "select 1 from ERP_CustomFields where TName="& sort &" and IsUsing=1 and del=1"
		end if
		hasOpenExtra = (cn.execute(sql).eof = False)
	end function
	Function GetExtraFields(sort)
		If sort&""="" Then sort = 1
		Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim rs ,sql, field
		if sort = 21 then
			sql = "select dbname ,id, isused,title , MustFillin , "&_
			"   case when charindex('ext',dbname)>0 then replace(dbname,'ext','') else isnull((select gl from zdy where sort1=21 and name=a.dbname),0) end extra ,"&_
			"   case isnull(UiType,0) when 0 then 1 when 10 then 2 when 1 then 3 when 2 then 4 when 13 then 5 when 4 then 6 when 5 then 7 when 31 then 31 else 1 end UiType, "&_
			"   CanSearch,candr,candc,cantj "&_
			" from sys_sdk_BillFieldInfo a "&_
			" where billtype=16001 and ListType='0' order by Showindex "
'select f.id,f.IsUsing ,f.FType,f.FName,f.MustFillin, ((case f.FType when 1 then 'danh_' when 2 then 'duoh_' when 3 then 'date_' when 4 then 'Numr_' when 5 then 'beiz_' when 6 then 'IsNot_' else 'meju_' end ) + cast(f.id as varchar(20)) ) as dbname,f.CanSearch,f.CanInport ,f.CanExport, f.CanStat  from ERP_CustomFields f where f.TName="& sort &" and f.del=1 order by f.FOrder asc "
		else
			sql = "select f.id,f.IsUsing ,f.FType,f.FName,f.MustFillin, "&_
			"   ((case f.FType when 1 then 'danh_' when 2 then 'duoh_' when 3 then 'date_' when 4 then 'Numr_' when 5 then 'beiz_' when 6 then 'IsNot_' else 'meju_' end ) + cast(f.id as varchar(20)) ) as dbname,"&_
			"sql = ""select f.id,f.IsUsing ,f.FType,f.FName,f.MustFillin, ""&_"
			f.CanSearch,f.CanInport ,f.CanExport, f.CanStat  &_
			" from ERP_CustomFields f "&_
			" where f.TName="& sort &" and f.del=1 order by f.FOrder asc "
		end if
		Set rs = cn.execute(sql)
		While rs.eof = False
			Set field = New customSetFieldClass
			if sort = 21 then
				With field
				.dbname = rs("dbname").value
				.Key    = rs("id").value
				.show   = (rs("isused").value=1)
				.name   = rs("title").value
				.required=(rs("MustFillin").value=1 And rs("isused").value=1)
				.extra  = rs("extra").value
				.sorttype   = CInt(rs("UiType").value)
				.search = (rs("CanSearch").value=1  And rs("isused").value=1 )
				.import = (rs("candr").value=1  And rs("isused").value=1 )
				.export = (rs("candc").value=1  And rs("isused").value=1 )
				.census = (rs("CanTj").value=1  And rs("isused").value=1   )
				End With
			else
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
			end if
			fields.add field
			rs.movenext
		wend
		rs.close
		Set GetExtraFields = fields
	end function
	Function GetZdyMxFields(sort)
		If sort&""="" Then sort = 1
		Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim rs ,sql, field
		sql = "select * from zdymx where sort1="& sort &" order by gate1 asc "
		Set rs = cn.execute(sql)
		While rs.eof = False
			Set field = New customSetFieldClass
			With field
			.dbname = rs("name").value
			.Key    = rs("id").value
			.show   = (rs("set_open").value = "1")
			.name   = rs("title").value
			.sorttype   = CInt(rs("sort").value)
			End With
			fields.add field
			rs.movenext
		wend
		rs.close
		Set GetZdyMxFields = fields
	end function
	Function GetPaySortFields(sort)
		If sort&""="" Then sort = 0
		Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim rs ,sql, field
		sql = "select f.id,(case f.name when 'tel' then 'company' when 'intro' then 'note' when 'mdd' then 'endaddr' when 'smdd' then 'staraddr' when 'lic' then 'lc' when 'jtgj' then 'bus' when 'hatol' then 'hotel' when 'ggdate' then 'ggtime' when 'ggdx' then 'ggcate' when 'ggsy' then 'ggintro' when 'lw' then 'gglw' else f.name end ) as name ,f.set_open,f.title, (case when sort=1 and f.name<>'num' then 1 else 0 end ) as required,(case when name ='money1' then 5 when name ='num' then 9 when name = 'lic' then 6 when name in ('startime','endtime','retime') then 11 when name in ('caigou','fahuo','iwork','contract','jkid','tel','person','richeng','shouhou','chance') then 4 when name ='ggdate' then 10 else 2 end ) as FType from zdymx f where f.sort1="& sort &" and name not in('jkid','scdd','zdww','gxww','scsb') order by f.gate1 asc,id asc "
		Set rs = cn.execute(sql)
		While rs.eof = False
			Set field = New customSetFieldClass
			With field
			.dbname = rs("name").value
			.Key    = rs("id").value
			.show   = (rs("set_open").value = "1")
			.name   = rs("title").value
			.required=(rs("required").value = "1" And rs("set_open").value = "1")
			.sorttype   = CInt(rs("FType").value)
			End With
			fields.add field
			rs.movenext
		wend
		rs.close
		Set GetPaySortFields = fields
	end function
	Public Sub setZdyCol(lvw ,sort ,pername)
		Dim h, i ,zdyfields ,field
		Set zdyfields = GetZdyFields(sort)
		If zdyfields.count=0 Then
			For i = 1 To 6
				Set h = lvw.headers.getItemByDbname(pername &"zdy" & i)
				h.width = 0
				h.display = "none"
			next
		else
			For i = 0 To zdyfields.count-1
				h.display = "none"
				Set field = zdyfields.item(i)
				Set h = lvw.headers.getItemByDbname(pername & field.dbname)
				If Not h Is Nothing then
					If field.show = True Then
						If  request("cmd")="cexcel" And field.export =False Then
							h.display = "none"
							h.width = 0
						else
							h.title = field.name
							h.width = 100
							h.cansum=False
							If field.extra > 0 Then h.width = 80
						end if
					else
						h.width = 0
						h.display = "none"
					end if
				end if
			next
		end if
	end sub
	Function Getuploadfile(ids)
		Dim f_rs,v
		If Len(ids&"")=0 Then Exit Function
		ids = sdk.FormatNumList(ids)
		Set f_rs=cn.execute("select * from reply_file_Access where ord in(" & ids & ")")
		Do While Not f_rs.eof
			If v="" Then
				v=uploadtoShow(f_rs("Access_url"),f_rs("oldname"))
			else
				v=v & uploadtoShow(f_rs("Access_url"),f_rs("oldname"))
			end if
			f_rs.movenext
		Loop
		f_rs.close
		Getuploadfile=v
	end function
	Function uploadtoShow(upfile,oldname)
		Dim allowExt,v
		allowExt="bmp,jpeg,png,gif,jpg"
		v=Split(upfile,".")(ubound(Split(upfile,".")))
		If InStr(1,allowExt,v,1)>0 Then
			uploadtoShow="&nbsp;<span><a href='../../WebSource.ashx?disshowname=1&pf=" & server.URLEncode(ZBRuntime.BSEnString( "0000" & upfile & "??", 1024 ))&"' class='preview' title='" & oldname & "' target='_blank'><img src='../images/smico/p_tool_img.gif' alt='" & oldname & "' border='0'/></a></span>"
		else
			uploadtoShow="&nbsp;<span><a href='../../WebSource.ashx?pf=" & server.URLEncode( ZBRuntime.BSEnString("0000"& upfile & "??" & oldname, 1024)) &"' >" & oldname & "</a></span>"
		end if
	end function
	Function bill_AjaxWindow_ShowGateDlg(byref ajaxpage)
		Dim bid ,sortStr , sort1 ,pord ,share
		bid = app.gettext("bid")
		sortStr =  app.gettext("sort")
		pord = app.gettext("pord")
		share = pord
		ajaxpage.title = "选择人员"
		ajaxpage.width = 600
		ajaxpage.height = 400
		Dim open_1_1 , w1_list , w2_list, w3_list , str_w1 , str_w2 , str_w3
		Dim rs ,rs1 , rs2 ,delsql
		open_1_1=0
		delsql = " and del=1 "
		Select Case sortStr
		Case "design" :
		sort1 = 5
		open_1_1 = 1
		w1_list = " select g.sorce from power p inner join gate g on g.ord=p.ord where p.sort1=5029 and p.sort2=17 and p.qx_open=1 "
		w2_list = " select g.sorce2 from power p inner join gate g on g.ord=p.ord where p.sort1=5029 and p.sort2=17 and p.qx_open=1 "
		w3_list = " select p.ord from power p where p.sort1=5029 and p.sort2=17 and p.qx_open=1 "
		Case "produce" :
		sort1 = 6
		open_1_1 = 1
		If sdk.power.existsModel(39000) And sdk.power.existsModel(39004) Then
			w1_list = " select sorce from hr_person where  piecework=1 and del=0 and nowstatus in (1,5,7) and contractEnd>=CONVERT(VARCHAR(10),GETDATE(),120) and contractStart<=CONVERT(VARCHAR(10),GETDATE(),120) "
			w2_list = " select sorce2 from hr_person where  piecework=1 and del=0 and nowstatus in (1,5,7) and contractEnd>=CONVERT(VARCHAR(10),GETDATE(),120) and contractStart<=CONVERT(VARCHAR(10),GETDATE(),120) "
			w3_list = " select userid from hr_person where  piecework=1 and del=0 and nowstatus in (1,5,7) and contractEnd>=CONVERT(VARCHAR(10),GETDATE(),120) and contractStart<=CONVERT(VARCHAR(10),GETDATE(),120) "
			delsql = ""
		else
			w1_list = " select sorce from gate where del=1 and jjgz = 1 "
			w2_list = " select sorce2 from gate where del=1 and jjgz = 1 "
			w3_list = " select ord from gate where del=1 and jjgz = 1 "
		end if
		Case Else
		sort1 = 4
		set rs1=cn.execute("select sort1,qx_open,w1,w2,w3 from power2  where cateid="&session("personzbintel2007")&" and sort1= "& sort1)
		if rs1.eof=false then
			open_1_1=rs1("qx_open")
			w1_list=rs1("w1")
			w2_list=rs1("w2")
			w3_list=rs1("w3")
		end if
		rs1.close
		End Select
		if open_1_1=1 then
			str_w1="and ord in ("&w1_list&")"
			str_w2="and ord in ("&w2_list&")"
			str_w3="and ord in ("&w3_list&") " & delsql
		elseif open_1_1=3 then
			str_w1=""
			str_w2=""
			str_w3= delsql
		else
			str_w1="and ord=0"
			str_w2="and ord=0"
			str_w3="and ord=0 " & delsql
		end if
		Response.write "" & vbcrlf & "     <div region=""center"" border=""false"" style=""background:#fff;border:0px solid #ccc; width:100%;height:100%"">" & vbcrlf & "    "
		Call InitUserGateObject
		Dim basesql
		basesql="select ord,orgsid from gate where 1=1 "&str_w3&""
		Response.write CBaseUserTreeHtmlRadioCE(basesql,"", "","","member2", "", "" , "", share,"if(node.value && node.value!='" &  share & "'){window.updateBoxSel('ShowGateDlg','" & bid & "',node.text, node.value)}")
		Response.write "" & vbcrlf & "     </div>" & vbcrlf & "  "
	end function
	Function bill_ShowGateList(sort1,user_list, id, showPerson)
		Dim rs1 , str_w1 , str_w2 , str_w3 , open_1_1
		Dim sql1, Correct_W1, Correct_W2, Correct_W3
		Dim rs8, sql, i, j6 , zhanshi2 , zk2, tmp
		Dim w1, w2, w3, zhanshi, zhanshi1, rs3, sql3, rs2, sql2
		Dim zhanshi3, zk3, zhanshi4
		Dim uid : uid = Info.User
		If Len(uid & "") = 0 Then uid = 0
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select sort1,qx_open,w1,w2,w3 from power2  where cateid="& uid &" and sort1="&sort1&" "
		rs1.open sql1,cn,1,1
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
		Correct_W3=replace(user_list," ","")
		if Correct_W3<>"" and Correct_W3<>"0" then
			tmp=split(getW1W2(Correct_W3),";")
			Correct_W1=tmp(0)
			Correct_W2=tmp(1)
		end if
		Dim basesql
		Call InitUserGateObject
		If showPerson Then
			basesql="select ord,orgsid from gate where del=1 "&str_w3&""
			Response.write CBaseUserTreeHtml(basesql,"", "W1","W2","W3", "", Correct_W1, Correct_W2, Correct_W3)
		else
			Response.write CBaseUserTreeHtml(basesql,"", "W1","W2","W3", "", Correct_W1, Correct_W2, Correct_W3)
		end if
		Response.write "" & vbcrlf & "             </div>" & vbcrlf & "          "
	end function
	Sub InitUserGateObject
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
		d_at(23) = "		End Sub"
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
	end sub
	Class VmlGraphics
		Dim Labels
		Dim Values
		Dim Ords
		Dim Pies
		Dim SumValue
		Dim Count
		Public Title
		Public Unit
		public ID
		public Url
		Public Urls
		Dim colors
		Public width
		Public height
		Public PieOffsetR
		Private PieXys
		Dim repos
		Dim nodata
		Dim maxCount
		Public backgroundColor
		Public backgroundBorder
		Public Sub class_Initialize
			ReDim Labels(0)
			ReDim Values(0)
			ReDim Ords(0)
			ReDim Urls(0)
			Colors = Split("#ff8c19;#ff1919;#ffff00;#1919ff;#00ee19;#fc0000;#3cc000;#ff19ff;#993300;#f60000",";")
			Count = 0
			width = 550
			height = 340
			PieOffsetR = 36
			maxCount = 10
			backgroundColor = "#fbfbfb"
			backgroundBorder = "1px solid #e0e0e0"
		end sub
		Public Sub Draw(ByVal mType)
			mType = LCase(mtype)
			Select Case mType
			Case "饼图" : mType = "pie"
			Case "圆锥" : mType = "cone"
			End select
			Select Case mType
			Case "pie"
			CreatePieImage 0, 0, width, height
			Case "cone"
			CreateConeImage 0, 0, width, height
			End Select
		end sub
		Public sub loadDataByRecord(ByVal rs)
			Dim c : c = rs.fields.count
			on error resume next
			If ubound(urls)<>rs.recordcount Then
				If c = 2 Then
					rs.sort =  rs(1).name  & " desc"
				else
					rs.sort =  rs(c-1).name  & " desc"
					rs.sort =  rs(1).name  & " desc"
				end if
			end if
			On Error GoTo 0
			While rs.eof = False And count < maxCount
				ReDim preserve       Labels(count)
				ReDim preserve       Values(count)
				ReDim preserve       Ords(count)
				Ords(count)=0
				If c = 2 then
					Labels(count) = rs(0).value
					Values(count) = rs(1).value
				else
					Labels(count) = rs(0).value
					Values(count) = rs(c-1).value
'Labels(count) = rs(0).value
					If c>2 Then Ords(count)=rs(c-2).value
					Labels(count) = rs(0).value
				end if
				count = count + 1
				Labels(count) = rs(0).value
				rs.movenext
			wend
			Call InitData
		end sub
		Private Sub InitData
			Dim i, sump
			Count = ubound(Values) + 1
'Dim i, sump
			SumValue = 0
			for i = 0 To Count - 1
'SumValue = 0
				If Len(Trim(Values(i) & "")) = 0 Then Values(i) = 0
				SumValue = cdbl(SumValue) + cdbl(Values(i))*1
'If Len(Trim(Values(i) & "")) = 0 Then Values(i) = 0
			next
			ReDim Pies(count - 1)
			If Len(Trim(Values(i) & "")) = 0 Then Values(i) = 0
			If Count > 0 Then
				sump = 0
				for i = 0 To Count - 1
'sump = 0
					If len(Trim(Values(i) & "")) = 0 Then Values(i) = 0
					If SumValue > 0 then
						Pies(i) =  FormatNumber(cdbl(Values(i))*1.00/cdbl(SumValue), 4,-1,0,-1)
'If SumValue > 0 then
					else
						Pies(i) = 0
					end if
					sump = cdbl(sump) + cdbl(Pies(i))
					Pies(i) = 0
				next
				nodata = CDbl(sump) = 0
				If Pies(count-1)  < 0 Then Pies(count-1) =0
'nodata = CDbl(sump) = 0
			end if
		end sub
		Private Sub AddHtml(ByRef data, ByVal html)
			Dim C : C = ubound(data) + 1
'Private Sub AddHtml(ByRef data, ByVal html)
			ReDim Preserve data(C)
			data(c) = html
		end sub
		Function showlabel(ByVal n)
			Dim nn
			If InStr(n,"_") Then
				Dim s
				s = Split(n, "_")
				nn = s(ubound(s))
			else
				nn = n
			end if
			If App.ByteLen(nn) > 12 And InStr(1, nn, "<i>",1)=0 then
				nn = "<span title='" & n & "'>…" & App.ByteRight(nn,9) & "</span>"
			else
				If Len(Trim(nn&"")) = 0 Then nn = "<i>空</i> "
			end if
			showlabel = nn
		end function
		Sub WriteHTML(ByRef html)
			Response.write Join(html, "")
			Erase html
		end sub
		function  IsOldIE()
			dim IEversion,EXP,IEver
			EXP=Request.ServerVariables("HTTP_USER_AGENT")
			if InStr(EXP, "MSIE") > 0 Then
				IEver=Split(EXP,";")(1)
				IEversion=Split(IEver,"MSIE")(1)
				if IEversion*1<9 Then
					IsOldIE=true
				end if
			elseif InStr(EXP, "Trident") > 0 Then
				IEver=Split(EXP,":")(1)
				IEversion=Split(IEver,".")(0)
				if IEversion*1<9 Then
					IsOldIE=true
				end if
			else
				IsOldIE=false
			end if
		end function
		Private Sub CreateConeImage(ByVal mLeft ,ByVal mTop,ByVal mWidth,ByVal mHeight)
			Dim html, i, ii, iii, clen, spc
			Dim imgW, imgH, imgT, imgL, dtw
			Dim w, t, c, h, x1, y1, x2, y2, x3, y3, x4, y4, y0
			Dim xlist, ylist, ct ,surl, isIE, msvdata , murl
			clen = ubound(colors)
			ReDim html(0)
			addHTML html, "<div style='position:relative;width:" & mWidth & "px;height:" & mHeight & "px'>"
			isIE=isOldIE()
			imgT = 0
			imgL = 0
			mHeight = mHeight
			mWidth =  mWidth
			imgW = mWidth - 250
'mWidth =  mWidth
			imgH = mHeight + 20
'mWidth =  mWidth
			dtw = (imgW/imgH)*0.7
			spc = 8
			t = 0.00
			ct = ubound(values)
			msvdata = imgW & "|" & imgH
			For i = 0 To ct
				c = colors(i Mod clen)
				h =  CLng(pies(i)*imgH)
				y0 = CLng(t*imgH)
				w = CLng(imgW - y0*dtw)
'y0 = CLng(t*imgH)
				x1 = CLng(y0*dtw/2)
				x2 = w + x1
'x1 = CLng(y0*dtw/2)
				y1 = y0 : y2 = y0
				y3 = CLng((t+pies(i))*imgH) : y4 = y3
'y1 = y0 : y2 = y0
				x4 = CLng((y0+h)*dtw/2)
'y1 = y0 : y2 = y0
				x3 =  CLng(imgW - x4)
'y1 = y0 : y2 = y0
				xlist = x3 - 10
'y1 = y0 : y2 = y0
				ylist = CLng((y2+y3)/2)
'y1 = y0 : y2 = y0
				If isIE then
					Call addHTML(html, "<v:shape  CoordOrig='0,0' CoordSize='" & (imgw+10) & "," & imgH & "'  path='m " & x1 & ",0 l " & x2 & ",0  l " & x3 & "," & (y3-y2) & " l " & x4 & "," & (y4-y2) & " l " & x1 & ",0 xe' style='position:absolute;top:" &  (y1+40+i*spc) & "px;left:20px;width:" & (imgw+10) & "px;height:" & imgH & "px;z-index:" & (count-i+12) & "' fillcolor='" & c & "'><o:extrusion v:ext='view' on='t'/></v:shape>")
'If isIE then
				else
					msvdata = msvdata & "|" & pies(i)
				end if
				t = t + pies(i)
				msvdata = msvdata & "|" & pies(i)
				y0 = clng(y1 + 40 + i*spc + (y3-y2)/2 - 6)
'msvdata = msvdata & "|" & pies(i)
				x1 = CLng((x2 + x3)/2 + 28)
'msvdata = msvdata & "|" & pies(i)
				w = imgW - x1 + 60
'msvdata = msvdata & "|" & pies(i)
				Call addHTML(html, "<div style='position:absolute;top:" & y0 & "px;left:" & x1 & "px;width:" & w & "px;;height:1px;overflow:hidden;background-color:#e3e4ea;z-index:" &  (count-i+100) & "'></div>")
'msvdata = msvdata & "|" & pies(i)
				Call addHTML(html, "<div style='width:200px;position:absolute;top:" & (y0-8) & "px;left:" & (x1+w+3) & "px;z-index:" &  (count-i+100) & "'>" )
'msvdata = msvdata & "|" & pies(i)
				If Len(Url)>0 Then
					murl = Url
				ElseIf ubound(Urls)>=ct Then
					murl = Urls(i)
				end if
				If murl<>"" Then
					sUrl=Replace(murl,"@ord",Ords(i))
					If instr(sUrl,"@") = 1 Then
						Call addHTML(html, "<a href='javascript:void(0);' onClick=""javascript:window.OpenNoUrl('" & Replace(sUrl,"@","") & "','newwin22','width=' + 1200 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150')"">")
'If instr(sUrl,"@") = 1 Then
					else
						Call addHTML(html, "<a href='"&sUrl&"' target=_blank>")
					end if
				end if
				Call addHTML(html, labels(i) & "：&nbsp;" & values(i) & " (百分比：" & FormatNumber(pies(i)*100,2,-1,0,-1) & "%)")
				Call addHTML(html, "<a href='"&sUrl&"' target=_blank>")
				If murl<>"" Then Call addHTML(html, "</a>")
				Call addHTML(html, "</div>")
			next
			If isIE = False Then
				randomize
				Dim cansvId : cansvId = "ID" & Replace(CDbl(now) & "", ".","") & CLng(rnd*1000)
				addHTML html , "<canvas style='position:absolute;left:20px;top:14px;' id='vml_con_" & cansvId & "' width='" & (imgW+10) & "' height='" & (imgH+20) & "'></canvas>"
'Dim cansvId : cansvId = "ID" & Replace(CDbl(now) & "", ".","") & CLng(rnd*1000)
				addHTML html , "<ajaxscript>setTimeout(""app.drawVMLCone('" & cansvId & "','" & msvdata & "')"",500);</ajaxscript>"
			end if
			t = 0.00
			AddHtml html, "</div>"
			Call WriteHTML(html)
		end sub
		Private Sub CreatePieImage(ByVal mLeft ,ByVal mTop,ByVal mWidth,ByVal mHeight)
			Dim i, ci, A1, A2, tit, zp, pc
			Dim R, zIndex, clen, c, html, items,surl
			ReDim html(0)
			ReDim PieXys(0)
			clen = ubound(colors)
			R = mWidth
			zIndex = 10000
			If R > mHeight Then R = mHeight
			R = CLng(R/2)
			R = R - PieOffsetR
'R = CLng(R/2)
			A1 = 0
			addhtml html, "<div style='position:relative;width:" & mWidth & "px;height:" & mHeight & "px;background-color:" & backgroundColor &_
			";border: & backgroundBorder & ;' name='vm_pie_sn' onmouseover='vmp_focus(this)' onmouseover='vmp_focus(this)"
			addhtml html, "<div style='height:30px;overflow:hidden;'><div style='height:8px;overflow:hidden'>&nbsp;</div><div style='color:#2f496e;font-weight:bold;text-align:center'>" & title & "</div></div>"
			Dim BrowserString,isIE
			isIE=IsOldIE()
			If Not isIE And Not nodata Then
				addhtml html, "<div id='echarts_"& Id &"' style='width:510px; height: 270px;'></div>"
				Dim valueJson ,murl
				valueJson = "["
				For i = 0 To ubound(pies)
					items = Labels(i)
					items = Replace(Replace(items&"","\","\\"),"""","\\""")
					If Len(Url)>0 Then
						murl = Url
					ElseIf ubound(Urls)>=ubound(pies) Then
						murl = Urls(i)
					end if
					sUrl = ""
					If murl<>"" Then sUrl=Replace(Replace(murl,"@ord",Ords(i)),"@","")
					valueJson = valueJson &"{value:"& values(i) &",name:"""& items &""",url:"""& sUrl &"""}"
					If i < Ubound(values) Then  valueJson = valueJson &","
				next
				valueJson = valueJson &"]"
				addhtml html, "<ajaxscript>setTimeout(function(){showECharts('pie','','"& valueJson &"','echarts_"& Id &"') },1000);</ajaxscript>"
			end if
			addhtml html, "<div style='position:absolute;left:" & CLng((mWidth-2*R)/2) & "px;'>"
			zp = 0
			pc =  ubound(pies)
			If nodata = True Then
				For i = 0 To pc
					pies(i)  = CDbl(1.00/(pc+1))
'For i = 0 To pc
				next
			end if
			For i = 0 To ubound(pies)
				If pies(i)*100 < 1 Then
					zp = zp + 1
'If pies(i)*100 < 1 Then
				end if
			next
			If nodata Then
				addhtml html, "<div class='lvw_nulldata' style='width:" & R*2 & "px;height:" & R*2 & "px;'>&nbsp;</div>"
			else
				If isIE Then
					For i = 0 To ubound(pies)
						c = colors(i Mod clen)
						A2 = CLng(A1 + pies(i)*360)
'c = colors(i Mod clen)
						items = Split(Labels(i)&" ","_")
						tit = Trim(items(ubound(items)))
						If Len(tit) = 0 Then
							tit = "<i>空</i>"
						end if
						If nodata Then
							tit = tit & "(<B>0.00%</B>)"
							c = "white"
						else
							Dim txtv
							If isnumeric(Values(i)) Then
								If InStr(title,"额")>0 then
									txtv = Replace(FormatNumber(Values(i),sdk.Info.moneynumber,-1,0,-1),",","")
'If InStr(title,"额")>0 then
								else
									txtv = Replace(FormatNumber(Values(i),sdk.Info.floatnumber,-1,0,-1),",","")
'If InStr(title,"额")>0 then
								end if
							else
								txtv = Values(i)
							end if
							tit = tit & "(<B><b>" & txtv & "，" &  FormatNumber(pies(i)*100,2,-1,0,-1) & "%</b></B>)"
							txtv = Values(i)
						end if
						If Len(Url)>0 Then
							murl = Url
						ElseIf ubound(Urls)>=ubound(pies) Then
							murl = Urls(i)
						end if
						If murl<>"" Then
							sUrl=Replace(murl,"@ord",Ords(i))
							If instr(sUrl,"@") = 1 Then
								tit="<a href='javascript:void(0);' onClick=""javascript:window.OpenNoUrl('" & Replace(sUrl,"@","") & "','newwin22','width=' + 1200 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150')"">"&tit&"</a>"
'If instr(sUrl,"@") = 1 Then
							else
								tit="<a href='"&sUrl&"' target=_blank>"&tit&"</a>"
							end if
						end if
						addhtml html, CreatePieImageItem(A1, A2, R, c,  tit, zIndex, 55, "vml_piegrs_" & Id & "_" & i, 30-zp*6, Id)
						tit="<a href='"&sUrl&"' target=_blank>"&tit&"</a>"
						A1 = A2
					next
				end if
			end if
			addhtml html, "</div>"
			AddHtml html, "</div>"
			Call WriteHTML(html)
		end sub
		Private Function CreatePieImageItem(ByVal A1, ByVal A2, ByVal R, ByVal Color, ByVal title, ByRef zIndex, ByRef rJ, ByVal htmlId, ByVal offsetY0, ByVal imgid)
			Dim html, zoom,  i
			Dim PI : PI = 3.14159265
			Dim R2 : R2 = R*2
			Dim YR : YR = CLng(Cos((rJ/180)*PI)*R - offsetY0)
'Dim R2 : R2 = R*2
			If A2 > 360 Then A2 = 360
			If A2 = 0 Then A2 = 1
			If A1 >= 360 Then A1 = 359
			if A1 < 180 then
				zIndex = zIndex + 1
'if A1 < 180 then
			else
				zIndex = zIndex - 1
'if A1 < 180 then
			end if
			If A1 = A2 And A1<=359 Then
				A2 = A1+1
'If A1 = A2 And A1<=359 Then
			end if
			zoom = 2400
			Dim fs : fs = PI*A1/180
			Dim fe : fe = PI*A2/180
			Dim sx : sx = CLng(R*sin(fs))
			Dim sy : sy = CLng(-R*cos(fs))
'Dim sx : sx = CLng(R*sin(fs))
			Dim ex : ex = CLng(R*sin(fe))
			Dim ey : ey = CLng(-R*cos(fe))
'Dim ex : ex = CLng(R*sin(fe))
			html = "<v:shape onmouseout='vml_pieout(this)' onmouseover='vml_pieover(this)' id='" & htmlId & "' style='position:absolute;z-index:" & zIndex & ";width:" & R2 & ";height:" & R2 & ";left:" & R & "px;top:" & (YR+PieOffsetR) & "px'  CoordSize='" & R2*zoom &"," & R2*zoom & "' strokeweight='0pt' StrokeColor='" & color & "' fillcolor='" & color & "'"
			html = html & " path='m " & sx*zoom & "," & sy*zoom & " l " & sx*zoom & "," & sy*zoom & " ar -" & r*zoom & ",-" & r*zoom & "," & r*zoom & "," & r*zoom & "," & ex*zoom & "," & ey*zoom & "," & sx*zoom & "," & sy*zoom & " l0,0 x e' deep='" & CLng(R/8) & "' oTop='" &  (YR+PieOffsetR) & "'>"
'eColor='" & color & "' fillcolor='" & color & "'"
			html = html & "<v:fill opacity='60293f' color2='fill lighten(200)' o:opacity2='60293f' rotate='t' angle='-135' method='linear sigma' focus='100%' type='gradient'/>"
'eColor='" & color & "' fillcolor='" & color & "'"
			html = html &  "<o:extrusion v:ext='view' on='t'  rotationangle='" & rJ & "' skewamt='0' backdepth='" & CLng(R/8) & "' viewpoint='0,0' viewpointorigin='0,0' lightposition='-50000,-50000' lightposition2='50000'/>"
'eColor='" & color & "' fillcolor='" & color & "'"
			html = html &  "</v:shape>"
			Dim Ao : Ao = CLng((A1 + A2) / 2)
'html = html &  "</v:shape>"
			Dim x1, y1, x2, y2
			x1 = CLng((R-10) * Sin(Ao*PI/180))
'Dim x1, y1, x2, y2
			y1 = CLng(-(R-10)* cos(Ao*PI/180))
'Dim x1, y1, x2, y2
			y1 = CLng(y1 * Cos(rJ*PI/180))
			x1 = x1 + R
'y1 = CLng(y1 * Cos(rJ*PI/180))
			y1 = y1 + R + PieOffsetR - offsetY0
'y1 = CLng(y1 * Cos(rJ*PI/180))
			x2 = CLng((R+10) * Sin((Ao)*PI/180))
'y1 = CLng(y1 * Cos(rJ*PI/180))
			y2 = CLng(-(R+10)* cos(Ao*PI/180))
'y1 = CLng(y1 * Cos(rJ*PI/180))
			y2 = CLng(y2 * Cos(rJ*PI/180))
			x2 = x2 + R
'y2 = CLng(y2 * Cos(rJ*PI/180))
			y2 = y2 + R  + PieOffsetR - offsetY0
'y2 = CLng(y2 * Cos(rJ*PI/180))
			Dim x3, xl, align
			align = abs(x2 > R)
			If x2 = x1 Then
				xl = 2.2
			else
				xl = (y2 - y1)/(x2-x1)
				xl = 2.2
			end if
			If ubound(PieXys) = 1 Then
				Dim oxl, oy2
				oxl = PieXys(0)
				oy2 = PieXys(1)
				If oxl*xl > 0 Then
					If align=1 Then
						If y2 - oy2 < 13 Then
'If align=1 Then
							y2 = oy2 + 13
'If align=1 Then
						end if
					else
						If oy2 - y2 < 13 Then
'If align=1 Then
							y2 = oy2 - 13
'If align=1 Then
						end if
					end if
				end if
			end if
			If align = 0 Then
				x3 = CLng(x2 - (R-abs(x2-R))*0.6 - 10)
'If align = 0 Then
			else
				x3 = CLng(x2 + (R-abs(x2-R))*0.6 + 10)
'If align = 0 Then
			end if
			html = html & "<v:line id='" & htmlId & "_l1' strokecolor='#cccccc' style='position:absolute;z-index:100000' from='" & x1 & "," & y1 & "' to='" & x2 & "," & y2 & "'/>"
			If align = 0 Then
				html = html & "<v:line id='" & htmlId & "_l2' strokecolor='#cccccc' style='position:absolute;z-index:100000' from='" & x2 & "," & y2 & "' to='" & x3 & "," & y2 & "'/>"
'If align = 0 Then
'If align = 0 Then
				html = html & "<div id='" & htmlId & "_txt' name='vmtxt_" & imgid & "' oTop='" & (y2-8) & "' style='padding-left:2px;padding-right:2px;position:absolute;z-index:100001;text-align:right;width:200px;left:" & (x3-205) & "px;top:" & (y2-8) & "px' onmouseover='__vmtxtv(this,1)' onmouseout='__vmtxtv(this,0)'>" & title & "</div>"
			else
				html = html & "<div id='" & htmlId & "_txt' name='vmtxt_" & imgid & "' oTop='" & (y2-8) & "' style='padding-left:2px;padding-right:2px;position:absolute;z-index:100001;text-align:left;width:200px;left:" & (x3+5) & "px;top:" & (y2-8) & "px' onmouseover='__vmtxtv(this,1)' onmouseout='__vmtxtv(this,0)'>" & title & "</div>"
			end if
			PieXys = Split(xl & "|" & y2 , "|")
			CreatePieImageItem = html
		end function
	End Class
	Class ImageVmlClass
		Public title
		Public sql
		Public gType
		Public dMode
		Public vname
		Public index
		Public Itype
		Public urls
		Public filterText
		Public Sub Class_Initialize()
			Itype = "pie"
			dMode = "col"
			ReDim urls(0)
		end sub
		Public Function ShowImageDivItem(ByVal cn)
			Dim img : Set img = New VmlGraphics
			on error resume next
			Dim rs : Set rs = cn.execute(sql)
			If Err.number<> 0 Then
				Response.write "<textarea style='display:none' id='GroupErrSql" & index & "'>"
				If InStr(Request.ServerVariables("LOCAL_ADDR"), "127.0.0.1")  > 0 Then Response.write sql
				Response.write "</textarea>"
				Set rs = cn.execute("select '<a href=""javascript:showgrouperrSql(" & index & ")""><b style=""color:red"">统计出错</b></a>' as n , 0 as v")
			end if
			On Error GoTo 0
			Dim msql : msql = "set nocount on;create table #nm(id int identity(1,1), n nvarchar(500), v float);"
			Dim i
			If dMode = "col" Then
				For i = 0 To rs.fields.count - 1
'If dMode = "col" Then
					msql = msql & "insert into #nm(n, v) values ('" & Replace(rs.fields(i).name,"'","''") & "','" & rs.fields(i).value & "');"
				next
				rs.close
				msql = msql & "select n, v from #nm order by id asc ;set nocount off;"
				on error resume next
				Set rs = cn.execute(msql)
				If Err.number <> 0 Then Response.write msql
			end if
			If len(filterText)>0 Then rs.Filter = filterText
			img.height = 310
			img.width = 520
			img.Urls = urls
			img.loadDataByRecord rs
			img.title = "按" & title & "统计"
			img.id = "RMG" & index
			Response.write "<div class='gmitem' style='_display:inline;' align='center'>"
			Call img.Draw(Itype)
			Response.write "</div>"
			Set img = nothing
			rs.close
		end function
	End Class
	Class CommSPConfig
		Public con
		Public bill
		Public moneyLimit
		Public useHL
		Public useBT
		Public clsID
		Public tabName
		Public keyField
		Public addField
		Public addField2
		Public sprField
		Public stateField
		Public stateOK
		Public stateDai
		Public stateShen
		Public stateFou
		Public moneyField
		Public swicthField
		Public name
		Public remind_sp
		Public remind_sp_sort
		Public sp
		Public saveBillMoneyField
		Public saveBillMoneySub
		Public titleField
		Public isExtract
		Public Enable
		Public Sub Class_Initialize()
			Me.moneyLimit = True
			Me.useHL = False
			Me.useBT = False
			Me.clsID = 0
			Me.keyField = "ord"
			Me.addField="addcate"
			Me.addField2 = ""
			Me.sprField = "cateid_sp"
			Me.sp="sp"
			Me.stateField = "status"
			Me.stateOK = 0
			Me.stateDai = 1
			Me.stateShen = 2
			Me.stateFou = 4
			Me.saveBillMoneyField = ""
			Me.saveBillMoneySub = ""
			Me.isExtract = False
			Me.Enable = true
			Me.remind_sp = False
			me.remind_sp_sort = 0
		end sub
		Public Sub Init(bill)
			dim s
			Me.bill = bill
			on error resume next
			s = conn.connectionstring
			if err.number = 0 then
				set Me.con = conn
			else
				set Me.con = cn
			end if
			On Error GoTo 0
			Me.titleField = "title"
			Select Case Me.bill
			Case "tel"
			Me.tabName = "tel"
			Me.addField="cateadd"
			Me.clsId = 92
			Me.name = "客户"
			Me.sp = "sp_qualifications"
			Me.sprField="cateid_sp_qualifications"
			Me.stateField="status_sp_qualifications"
			Me.titleField = "name"
			Case "gys"
			Me.tabName = "tel"
			Me.addField="cateid"
			Me.clsId = 93
			Me.name = "供应商"
			Me.sp = "sp_qualifications"
			Me.sprField="cateid_sp_qualifications"
			Me.stateField="status_sp_qualifications"
			Me.titleField = "name"
			Case "chance"
			Me.tabName = "chance"
			Me.moneyField = "money1"
			Me.swicthField = "trade"
			Me.addField="cateid"
			Me.clsId = 25
			Me.name = "项目"
			Me.stateField = "del"
			Me.stateOK = 1
			Me.stateDai = 3
			Me.stateShen = 3
			Me.stateFou = 3
			Me.isExtract = True
			Case "contract"
			Me.tabName = "contract"
			Me.moneyField = "money1"
			Me.swicthField = "sort"
			Me.addField="addcate"
			Me.addField2="cateid"
			Me.clsId = 2
			Me.name = "合同"
			Me.stateField = "del"
			Me.stateOK = 1
			Me.stateDai = 3
			Me.stateShen = 3
			Me.stateFou = 3
			Me.isExtract = True
			Case "yugou"
			Me.tabName = "caigou_yg"
			Me.keyField = "id"
			Me.moneyField = "money1"
			Me.swicthField = "sort1"
			Me.addField="cateid"
			Me.clsId = 26
			Me.name = "预购"
			Me.stateField = "status"
			Me.stateOK = 0
			Me.stateDai = 1
			Me.stateShen = 2
			Me.stateFou = -1
			Me.stateShen = 2
			Me.isExtract = False
			Case "caigou"
			Me.tabName = "caigou"
			Me.moneyField = "money1"
			Me.swicthField = "sort"
			Me.addField="cateid"
			Me.clsId = 3
			Me.name = "采购"
			Me.stateField = "del"
			Me.stateOK = 1
			Me.stateDai = 3
			Me.stateShen = 3
			Me.stateFou = 3
			Me.isExtract = True
			Me.remind_sp = True
			Me.remind_sp_sort = 16
			Case "contractth"
			Me.tabName = "contractth"
			Me.moneyField = "money1"
			Me.addField="addcate"
			Me.clsId = 41
			Me.name = "销售退货"
			Me.stateField = "del"
			Me.stateOK = 1
			Me.stateDai = 3
			Me.stateShen = 3
			Me.stateFou = 3
			Me.isExtract = True
			Case "wages"
			Me.moneyLimit = False
			Me.tabName = "wages"
			Me.keyField = "id"
			Me.addField="cateid"
			Me.clsId = 10
			Me.name = "工资"
			Me.stateField = "complete2"
			Me.stateOK = 1
			Me.stateDai = 2
			Me.stateShen = 3
			Me.stateFou = -1
			Me.stateShen = 3
			Me.Enable = ZBRuntime.MC(226100)
			Case "paybx"
			Me.tabName = "paybx"
			Me.moneyField = "dkmoney"
			Me.addField="addcate"
			Me.addField2="cateid"
			Me.keyField = "id"
			Me.clsId = 4
			Me.name = "报销"
			Me.stateField = "complete"
			Me.stateOK = 3
			Me.stateDai = 0
			Me.stateShen = 1
			Me.stateFou = 2
			Me.sp="sp_id"
			Me.swicthField = "bxtype"
			Case "payout" :
			Me.tabName = "payout"
			Me.moneyField = "money1"
			Me.addField="cateid"
			Me.clsId = 50
			Me.name = "付款"
			Me.stateField = "status_sp"
			Me.stateOK = 0
			Me.stateDai = 2
			Me.stateShen = 3
			Me.stateFou = 4
			Me.swicthField = "pay"
			Me.isExtract = True
			Me.remind_sp = True
			Me.remind_sp_sort = 50
			Case "bankout" :
			Me.tabName = "bankout2"
			Me.moneyField = "money1"
			Me.addField="cateid"
			Me.keyField = "id"
			Me.clsId = 51
			Me.name = "预付款"
			Me.stateField = "status_sp"
			Me.stateOK = 0
			Me.stateDai = 2
			Me.stateShen = 3
			Me.stateFou = 4
			Me.isExtract = True
			Me.remind_sp = True
			Me.remind_sp_sort = 206
			Case "budget"
			Me.tabName = "budget"
			Me.moneyField = "money1"
			Me.addField="creator"
			Me.clsId = 62
			Me.name = "预算"
			Me.stateFou = 3
			Case "document"
			Me.tabName = "document"
			Me.keyField = "id"
			Me.clsId = 78
			Me.name = "文档"
			Me.stateField = "spFlag"
			Me.stateOK = 1
			Me.stateDai = 2
			Me.stateShen = 3
			Me.stateFou = -1
			Me.stateShen = 3
			Me.swicthField = "sort"
			Case "paysq"
			Me.tabName = "paysq"
			Me.moneyField = "sqmoney"
			Me.keyField = "id"
			Me.addField="addcateid"
			Me.addField2="cateid"
			Me.sprField = "cateid_sp"
			Me.clsId = 7
			Me.name = "费用申请"
			Me.stateField = "complete"
			Me.stateOK = 1
			Me.stateDai = 0
			Me.stateShen = 2
			Me.stateFou = 3
			Me.sp="sp"
			Me.saveBillMoneyField = "spmoney"
			Me.isExtract = True
			Me.remind_sp = True
			Me.remind_sp_sort = 40
			Case "payjk"
			Me.tabName = "payjk"
			Me.moneyField = "allmoney"
			Me.addField="addcate"
			Me.addField2="sorce2"
			Me.keyField = "id"
			Me.sprField = "gate_sp"
			Me.clsId = 6
			Me.name = "借款"
			Me.stateField = "spstate"
			Me.stateOK = 4
			Me.stateDai = 5
			Me.stateShen = 2
			Me.stateFou = 3
			Me.sp="sp_id"
			Me.saveBillMoneyField = "spmoney"
			Me.isExtract = True
			Case "payfh"
			Me.tabName = "pay"
			Me.moneyField = "money1"
			Me.keyField = "ord"
			Me.addField="addcate"
			Me.addField2="cateid"
			Me.sprField = "cateid_sp"
			Me.clsId = 5
			Me.name = "返还"
			Me.stateField = "complete"
			Me.stateOK = 8
			Me.stateDai = 11
			Me.stateShen = 7
			Me.stateFou = 12
			Me.sp="sp"
			Me.saveBillMoneyField = "money2"
			Me.isExtract = True
			Me.remind_sp = True
			Me.remind_sp_sort = 43
			Case "maintain"
			Me.tabName = "maintain"
			Me.clsId = 91
			Me.name = "养护"
			Me.isExtract = True
			Case "BOM_Structure_Info"
			Me.tabName = "BOM_Structure_Info"
			Me.sp = "sp"
			Me.sprField="cateid_sp"
			Me.stateField="status_sp"
			Me.titleField = "title"
			Me.clsId = 8040
			Me.stateFou = -1
'Me.clsId = 8040
			Me.name = "组装清单"
			Me.isExtract = True
			Case "Design"
			Me.tabName ="Design"
			Me.keyField = "id"
			Me.addField="creator"
			Me.addField2 = "designer"
			Me.sp = "id_sp"
			Me.sprField="cateid_sp"
			Me.stateField="designstatus"
			Me.stateOK = 8
			Me.stateDai = 7
			Me.stateShen = 7
			Me.stateFou = 9
			Me.titleField = "title"
			Me.clsId = 5029
			Me.name = "设计任务"
			Me.name = "设计任务"
			Me.isExtract = True
			Me.swicthField = "sort1"
			Me.remind_sp = True
			Me.remind_sp_sort = 217
			End Select
		end sub
		Public Sub init_sp(sort1)
			Select Case sort1&""
			Case "2" : Call Init("contract")
			Case "3" : Call Init("caigou")
			Case "4" : Call init("paybx")
			Case "5" : Call init("payfh")
			Case "6" : Call Init("payjk")
			Case "7" : Call Init("paysq")
			Case "25" : Call init("chance")
			Case "26" : Call init("yugou")
			Case "41" : Call Init("contractth")
			Case "50" : Call init("payout")
			Case "51" : Call init("bankout")
			Case "91" : Call Init("maintain")
			Case "92" : Call Init("tel")
			Case "93" : Call Init("gys")
			Case "94" : Call Init("teljf")
			Case "78" : Call Init("document")
			Case "8040" : Call Init("BOM_Structure_Info")
			Case "5029" : Call Init("Design")
			End Select
		end sub
		Public Function billExtract(billID, jg, sp)
			Dim helper
			If jg&"" = "1" and sp&"" = "0" Then
				Select Case Me.bill
				Case "paysq"
				Call savepaysqToJk(billID)
				Case "payjk"
				Me.con.execute("update "& Me.tabName &" set payid=1 where del=1 and id = "& billID)
				Case "chance"
				Me.con.execute("update chancelist set del=1 where chance = "& billID)
				Case "contract"
				Call onAfterContractSPAccess(billID)
				Call callExternalJk("htApprove",billID)
				Case "contractth"
				Call handlePassSp(billID)
				Case "caigou" , "payout" , "bankout"
				Call onAfterSPAccess(Me.con, Me.bill, billID)
				Case "maintain"
				Set helper = CreateReminderHelper(Me.con,68,0)
				Call helper.reloadRemind(True)
				Set helper = Nothing
				End Select
			Elseif jg&"" = "2" Then
				Select Case Me.bill
				Case "chance", "payout"
				Me.con.execute("update "& Me.tabName &" set sp=-1 where ord = "& billID)
'Case "chance", "payout"
				Case "caigou"
				Me.con.execute("update caigou set sp=-1,cateid_sp='',del=3 where ord = "& billID)
'Case "caigou"
				Me.con.execute("update caigoulist set del=3 where caigou = "& billID)
				Me.con.execute("update caigoubz set del=3 where caigou = "& billID)
				Case "contract"
				Call callExternalJk("htApprove",billID)
				case else
				Call onApproveNoPass(Me.con, Me.bill, billID)
				End Select
			elseif jg&""="3" then
				Select Case Me.bill
				Case "contract"
				Me.con.execute("update contract set sp=999999,cateid_sp=0,del=3 where ord = "& billID)
				case "contractth"
				end select
			end if
			If Me.remind_sp = True and (Me.con.execute("select 1 from sp_intro where ord="&billID&" and sort1="&Me.clsId&" ").eof=False or sp>0) Then
				CreateReminderHelper(Me.con,Me.remind_sp_sort,0).appendRemind billID
			end if
		end function
	End Class
	function ApproveIntroLog(conn, BillType, BillID ,ApproveSort, ApproveID, ApproveName , ApproveCateID , result , intro)
		dim Rs , lastID , lastlevel , ApproveSortType , currLevel
		ApproveSortType = 0
		currLevel = 0
		set rs= conn.execute("select isnull(Sptype,-1) as Sptype , gate1 from sp where id="& ApproveID)
'currLevel = 0
		if rs.eof=false then
			ApproveSortType = rs("Sptype").value
			currLevel = rs("gate1").value
		end if
		rs.close
		lastID = 0
		set rs = conn.execute("select top 1 s.sp_id as SpID from sp_intro s where sort1=" & ApproveSort &" and ord=" & BillID &" order by id desc")
		if rs.eof=false then
			lastID = rs("SpID").value
		end if
		rs.close
		lastlevel = 0
		if lastID>0 then
			set rs = conn.execute("select Gate1 as lastlevel from sp where id="& lastID )
			if rs.eof=false then
				lastlevel = rs("lastlevel").value
			end if
			rs.close
			if cdbl(lastlevel)>= cdbl(currLevel) then lastlevel = 0
		end if
		if cdbl(lastlevel)< cdbl(currLevel) then
			dim BillCateID , Creator , inx , Sp_Intro , BillCateName
			BillCateID = 0
			Creator = session("personzbintel2007")
			BillCateName = "业务人员"
			select case BillType
			case 11001:
			BillCateName = "销售人员"
			set rs = conn.execute("select cateid , addcate, cateid_sp from contract where ord="& BillID)
			if rs.eof=false then
				BillCateID = rs("cateid").value
				Creator = rs("addcate").value
				cateid_sp = rs("cateid_sp").value
			end if
			rs.close
			end select
			inx = 0
			set rs = conn.execute("select id, intro , sort1 from sp where Gate2="& ApproveSort &" and isnull(Sptype,-1)="& ApproveSortType &" and gate1>"& lastlevel &" and gate1<="& currLevel &"  order by gate1")
'inx = 0
			while rs.eof=false
				ApproveID = rs("id").value
				ApproveName = rs("sort1").value
				Sp_Intro = Replace(rs("intro").value&"" , " ","")
				if inx<>0 or len(intro)=0 then
					If BillCateID<>"0" and instr(","& Sp_Intro &"," , ","& BillCateID &",")>0 Then
						ApproveCateID=BillCateID
						intro= BillCateName & "默认审批通过"
					ElseIf instr(","& Sp_Intro &"," , ","& Creator &",")>0 Then
						ApproveCateID=Creator
						intro="添加人员默认审批通过"
					ElseIf  instr(","& Sp_Intro &"," , ","& session("personzbintel2007") &",")>0 and inx<>0 Then
						ApproveCateID=session("personzbintel2007")
						intro="当前审批人默认审批通过"
					end if
				end if
				call ApproveLog(conn, BillType, BillID ,ApproveSort, ApproveID, ApproveName , ApproveCateID , result , intro)
				inx = inx + 1
'call ApproveLog(conn, BillType, BillID ,ApproveSort, ApproveID, ApproveName , ApproveCateID , result , intro)
				rs.movenext
			wend
			rs.close
		end if
	end function
	function ApproveLog(conn, BillType, BillID ,ApproveSort, ApproveID, ApproveName , ApproveCateID , result , intro)
		set Rs = server.CreateObject("adodb.recordset")
		Rs.open "select top 0 * from sp_intro",conn,3,2
		Rs.addnew
		Rs("jg")=result
		Rs("intro")=intro
		Rs("date1")=now
		Rs("ord")=BillID
		Rs("sp")=ApproveName
		Rs("cateid")=ApproveCateID
		Rs("sort1")=ApproveSort
		Rs("sp_id")=ApproveID
		rs.update
		rs.close
		set rs = nothing
	end function
	Sub handlePassSp(ord)
		Dim rs
		Dim money_tk
		money_tk = CDbl(cn.execute("select isnull(sum(money1),0) from contractthList where caigou="&ord &" ")(0))
		If money_tk >0 And cn.execute("select count(1) from payout2 where contractth="&ord&" and del=1 ")(0)=0 Then
			Dim date1,area,trade,cateid,cateid2,cateid3,sorce_user3,sorce_user4 , BKPayModel
			BKPayModel = 0
			Set rs = cn.execute("select * from contractth where ord="& ord)
			If rs.eof = False Then
				date1 = rs("date3")
				sorce_user3=rs("addcate2")
				sorce_user4=rs("addcate3")
				area=rs("area")
				trade=rs("trade")
				cateid=rs("cateid")
				cateid2=rs("cateid2")
				cateid3=rs("cateid3")
				BKPayModel = rs("BKPayModel").value
				BZ=rs("BZ")
			end if
			rs.close
			if BKPayModel=1 then
				dim TkNo
				Set rs = cn.execute("exec [erp_getdjbh] 43010,"&session("personzbintel2007")&" ")
				If rs.eof= False Then
					TkNo=rs("cw_code")
				end if
				rs.close
				sql = "select top 0 * from payout2"
				Set Rs = server.CreateObject("adodb.recordset")
				Rs.open sql,cn,3,3
				Rs.addnew
				Rs("BH")=TkNo
				Rs("date1")=date1
				Rs("money1")=money_tk
				Rs("area")=area
				Rs("trade")=trade
				Rs("complete")=1
				Rs("cateid")=cateid
				Rs("cateid2")=cateid2
				Rs("cateid3")=cateid3
				Rs("addcate")=session("personzbintel2007")
				Rs("addcate2")=sorce_user3
				Rs("addcate3")=sorce_user4
				Rs("contractth")=ord
				Rs("date7")=now
				Rs("FromType") = 0
				Rs("del")=1
				Rs("PayBz")=BZ
				rs.update
				payout2ord = GetIdentity("payout2","ord","addcate","")
				if TkNo&""="" or TkNo="编号已满" then
					cn.execute("update payout2 set BH="&payout2ord&" where ord="&payout2ord)
					rs.close
					set rs = nothing
				end if
			end if
		end if
		dim checktax : checktax=0
		if ZBRuntime.MC(23004) then checktax=1 end if
		cn.execute("exec erp_contractTH_AutoInvoice "& session("personzbintel2007") &","& ord &",'"& date1 &"'," & checktax )
		cn.execute("update contractthlist set del=1 where caigou="&ord)
		cn.execute("Update contractthbz set del=1 where contractth="&ord&"")
		cn.execute("exec [dbo].[erp_contract_UpdateTHStatus] 'select distinct contract from contractthlist where caigou="& ord &" and isnull(contract,0)>0 '")
	end sub
	sub onApproveNoPass(con, bill, billID)
		Dim rs ,sql , company , curCate ,money1, ismobile
		curCate = session("personzbintel2007")
		If curCate&"" = "" Then curCate = 0
		Select Case bill
		Case "contractth"
		con.execute("update s2 set s2.HandleStatus =0 from S2_SerialNumberRelation s2 inner join contractthlist tl on s2.Billtype= 62001 and tl.kuoutlist2 = s2.ListID and s2.serialID = tl.serialID where tl.caigou =  " & billID)
		con.execute("update k2 set k2.thnum = case when isnull(k2.thnum,0) - tl.num1<0 then 0 else isnull(k2.thnum,0) - tl.num1 end from kuoutlist2 k2 inner join  (select kuoutlist2 ,sum(num1) num1 from  contractthlist where caigou =  " & billID &" group by kuoutlist2) tl on tl.kuoutlist2 = k2.ID ")
		con.execute("exec [dbo].[erp_contract_UpdateTHStatus] 'select distinct contract from contractthlist where caigou="& billID &" and isnull(contract,0)>0 '")
		end select
	end sub
	Sub savePaybxMoney(ord, money1)
		conn.execute("update paybxlist set money1=pay.money1 from pay where pay.ord=paybxlist.payid and bxid="& ord)
	end sub
	Sub savepaysqToJk(ord)
		Dim rs ,jktitle_length ,spstate, payid, spCount, spIntro, needSpLog
		jktitle_length=conn.execute("select length/2 from syscolumns where id=(select id from sysobjects where name='payjk') and name='title'")(0)
		Dim rsbh ,sqltext ,jkid, jkord, jkSpmoney, jkspid, jkSptitle
		set rsbh = conn.execute("EXEC erp_getdjbh 81,"&session("personzbintel2007"))
		jkid=rsbh(0).value
		rsbh.close
		set rsbh=Nothing
		spstate = 5
		payid = 4
		spCount = 0
		needSpLog = False
		Set rs = conn.execute("select TOP 1 id,sort1,intro from sp WHERE gate2=6 ORDER BY gate1 desc")
		If rs.eof = False Then
			spIntro = replace(rs("intro")&""," ","")
			Dim sq_cateid
			sq_cateid = CDbl(conn.execute("select cateid from paysq where id=" & ord &"")(0))
			If instr(","& spIntro &",", ","& session("personzbintel2007") &",")>0 or instr(","& spIntro &",", ","& sq_cateid &",")>0 Then
				spCount = 0 : needSpLog = True : jkspid = rs("id") : jkSptitle = rs("sort1")
			else
				spCount = 1
			end if
		end if
		rs.close
		set rs = nothing
		If jkspid&"" = "" Then jkspid = 0
		If spCount = 0 Then
			spstate = 1 : payid = 1
		end if
		sqltext="insert into payjk(title,datejk,sorce2,allmoney,spstate,spmoney,payid,bz,date7,sqid,del,addcate,sorce,sorce1,jktype,bh) "&_
		"select left('转费用申请:'+p.title,"& jktitle_length &"),'"&date&"',p.cateid,p.spmoney,"& spstate &",(case "& spCount &" when 0 then p.spmoney when 1 then 0 else p.spmoney end),"& payid &",p.bz,'"&now&"',p.id,1,p.addcateid,g.sorce,g.sorce2,1,'"& jkid &"' "&_
		" from paysq p inner join gate g on g.ord = p.cateid  where p.id = " & ord &" and p.jk=1 and p.complete=1 "
		conn.execute(sqltext)
		If needSpLog Then
			Set rs = conn.execute("select top 1 id, spmoney from payjk where del=1 and addcate='"&session("personzbintel2007")&"' and spstate="& spstate &" and payid="& payid &" and bh='"& jkid &"' and title like '转费用申请:%' order by date7 desc")
			If rs.eof = False Then
				jkord = rs("id") : jkSpmoney = rs("spmoney")
			end if
			rs.close
			set rs = nothing
			If jkord&"" = "" Then jkord = 0
			If jkSpmoney&"" = "" Then jkSpmoney = 0 Else jkSpmoney = CDbl(jkSpmoney)
			conn.execute("insert into sp_intro(jg, intro, date1, ord, sp, cateid, sort1, money1, sp_id) values (1,'添加人员默认审批通过', getdate()," & jkord & ",'" & jkSptitle & "', '" & session("personzbintel2007") & "',6,"& jkSpmoney &"," & jkspid &") ")
		end if
	end sub
	Sub onAfterContractSPAccess(ord)
		Dim money1,moneyRmb,company,date3,baojia,cateid1,cateid2,cateid3,paybackMode,yhmoney,invoiceMode,invoicePlan,invoiceType,plan
		Dim sql,sort2,jfsort,sum_jf,sql7,jf_single,jf,sum_tel,rs,sqltext,sqlStr
		Dim canInvoice
		set rs=server.CreateObject("adodb.recordset")
		sql="select sp,money1,money2,company,date3,cateid_sp,event1,cateid,cateid2,cateid3,sort,paybackMode,invoiceMode,yhmoney,fqhk,invoicePlan,invoicePlanType from contract where ord="& ord &" "
		rs.open sql,conn,1,1
		if Not rs.eof then
			money1=rs("money1")
			moneyRmb=rs("money2")
			company=rs("company")
			date3=rs("date3")
			baojia=rs("event1")
			cateid1=rs("cateid")
			cateid2=rs("cateid2")
			cateid3=rs("cateid3")
			paybackMode=CLng("0" & rs("paybackMode"))
			yhmoney=rs("yhmoney")
			invoiceMode=CLng("0" & rs("invoiceMode"))
			invoicePlan=CLng("0" & rs("invoicePlan"))
			invoiceType=CLng("0" & rs("invoicePlanType"))
			plan = CLng("0" & rs("fqhk"))
			if cateid1 & "" = "" Then cateid1=0
			if cateid2 & "" = "" Then cateid2=0
			if cateid3 & "" = "" Then cateid3=0
			If app.power.existsPowerIntro(7,13,cateid1) Then
				canInvoice = True
			else
				canInvoice = False
			end if
			CreateReminderHelper(conn,151,0).appendRemind ord
			Call getcontent(1,company, ord)
			sql="update contract set sp=0,cateid_sp='',del=1,alt=1 where ord=" & ord & " "
			conn.execute(sql)
			if baojia & "" <> "" then
				sql="Update price set complete=4 where ord=" & baojia & ""
				conn.execute(sql)
			end if
			conn.execute "Update contractlist set del=1 where contract=" & ord &""
			conn.execute "Update contractbz set del=1 where contract=" & ord &""
			if ZBRuntime.MC(18000) and ZBRuntime.MC(18100) then
				conn.execute("exec dbo.erp_auto_produce_CreateManuPlansPre @ContractId="&ord)
			end if
			Call CreateNewPayback(ord,cn)
			if plan="2" Then
				sqltext="update p set complete=1,complete2=2," &_
				"area=c.area,trade=c.trade," & vbcrlf &_
				"cateid=c.cateid,cateid2=c.cateid2,cateid3=c.cateid3," & vbcrlf &_
				"addcate=" & Info.User & ",addcate2=isnull(g.sorce,0),addcate3=isnull(g.sorce2,0)," & vbcrlf &_
				"company=c.company,date4=getdate(),del=1,paybackMode=c.paybackMode " & vbcrlf &_
				"from payback p " & vbcrlf &_
				"inner join contract c on p.contract=c.ord " & vbcrlf &_
				"left join gate g on g.ord=" & Info.User & " " & vbcrlf &_
				"where p.contract = " & ord & " "
				conn.execute sqltext
				sqltext="update plan_hk set del=1 where contract="& ord &" "
'conn.execute sqltext
				conn.execute "update payback set complete=3 where money1=0 and contract ="& ord
			end if
			If plan=2 then
				conn.execute "update payback set complete=3 where money1=0 and contract =" & ord
			end if
			If invoiceMode <> 0 and canInvoice = true Then
				Call AutoCompletePayBackInvoice(cn,invoiceMode,company,invoiceType,ord,yhmoney)
			end if
			call ContractJFHandle(conn , company ,ord, company)
			Call autoSkipSort(company,0,0,8,0,true,false,"合同审批")
			cn.execute("exec autoChangeSort1 " & Info.User & "," & company )
		else
			rs.close
			set rs=nothing
			Exit Sub
		end if
		cn.execute("update contract set del=1,sp=0,cateid_sp=0 where ord=" & ord)
	end sub
	Sub setPayoutMx(ord,caigouord , money1, ismobile,NeedDel)
		dim rs, num_mx, money_mx, money2, yhmoney, sql, cls,sum
		money2=0
		If ismobile = False Then
			Set rs = conn.execute("select isnull(cls,0) cls from payout where ord="& ord)
			If rs.eof = False Then
				cls = rs("cls")
			end if
			rs.close
			set rs = nothing
			If cls&"" = "" Then cls = 0
			Select Case cls
			Case 0 : sql = "select id,ord from caigoulist where caigou="&caigouord
			Case 2 : sql = "select id,productid ord from M_OutOrderlists where outID="&caigouord
			Case 4,5 : sql = "select id,productid ord from M2_OutOrderlists where outID="&caigouord
			End Select
			Set rs=conn.execute(sql)
			While rs.eof = False
				If ismobile Then
					money_mx=app.mobile("mx_"&rs("id"))
					num_mx=app.mobile("num_"&rs("id"))
				else
					money_mx=request("mx_"&rs("id"))
					num_mx=request("num_"&rs("id"))
					sum=cdbl(sum)+cdbl(num_mx)
					num_mx=request("num_"&rs("id"))
				end if
				If num_mx&""<>"" and money_mx&""<>"" Then
					If conn.execute("select top 1 1 from payoutlist where caigoulist="&rs("id")&" and payout="&ord).eof =False Then
						conn.execute ("update payoutlist set money1="& money_mx &",num1="& num_mx &" where caigoulist="&rs("id")&" and payout="&ord)
					else
						conn.execute ("insert into payoutlist (product,caigoulist,payout,money1,num1,del) values ("&rs("ord")&","&rs("id")&","&ord&","& money_mx &","&num_mx&",1)")
					end if
					money2 = cdbl(money2) + cdbl(money_mx)
				else
					if NeedDel then
						If conn.execute("select top 1 1 from payoutlist where caigoulist="&rs("id")&" and payout="&ord).eof =False Then
							conn.execute ("update payoutlist set money1=0,num1=0,del=2 where caigoulist="&rs("id")&" and caigoulist>0 and payout="&ord)
						end if
					end if
				end if
				rs.movenext
			wend
			rs.close
			If (num_mx&""<>"" and money_mx&""<>"") or sum&""<>"" Then
				If ismobile Then
					yhmoney = app.mobile("yhmoney")
				else
					yhmoney = request("yhmoney")
				end if
				If yhmoney&""<>"" Then
					If conn.execute("select top 1 1 from payoutlist where caigoulist=0 and payout="&ord).eof =False Then
						conn.execute ("update payoutlist set money1="& yhmoney &" where caigoulist=0 and payout="&ord)
					else
						conn.execute ("insert into payoutlist (product,caigoulist,payout,money1,del) values (0,0,"&ord&","& yhmoney &",1)")
					end if
					money2 = cdbl(money2) - cdbl(yhmoney)
				end if
				If cdbl(FormatNumber(money2,3,-1,0,0))<>cdbl(FormatNumber(money1,3,-1,0,0)) Then
					canCommit = False
					errStr = "付款明细总额和单据总额不一致"
					Exit Sub
				end if
			end if
		end if
		conn.execute("update payout set money1 = "& money1 &" where ord="&ord)
	end sub
	Sub onAfterSPAccess(con, bill, billID)
		Dim rs ,sql , company , curCate ,money1, ismobile
		curCate = session("personzbintel2007")
		If curCate&"" = "" Then curCate = 0
		Select Case bill
		Case "caigou"
		con.execute("update caigou set alt=1 where ord="&billID&" ")
		con.execute("Update caigoulist set del=1 where caigou="&billID&" ")
		con.execute("Update caigoubz set  del=1 where caigou="&billID&" ")
		con.execute("exec erp_UpdateStatus_Caigou_QC '" &billID& "','' " )
		Dim invoicePlan ,payplan
		company = 0 :  payplan = 0: invoicePlan= 0
		money1 = 0
		Set rs = con.execute("select company ,isnull(fyhk,0) fyhk,isnull(invoicePlan,0) as invoicePlan, isnull(money1,0) as money1 from caigou where ord="& billID)
		If rs.eof = False Then
			company = rs("company")
			payplan = rs("fyhk")
			invoicePlan = rs("invoicePlan")
			money1 = rs("money1").value
		end if
		rs.close
		set rs = nothing
		dim status_sp:status_sp=1
		dim noSP:noSP = con.execute("select 1 from sp where gate2=50 and (isnull(sptype,0)=0 or isnull(sptype,0)=(select sort from caigou where ord="&billID&"))").eof
		if noSP then status_sp=0
		dim autotype : autotype=0
		if payplan = 0 or payplan= 2  then autotype=payplan*1+1
'dim autotype : autotype=0
		if invoiceplan = 0 or invoiceplan = 2  then autotype = (invoiceplan+1)*10+ autotype
'dim autotype : autotype=0
		if autotype>0 and cdbl(money1)>0 then
			creatorurl = sdk.getvirpath() & "../SYSN/view/finan/payout/AutoCreator.ashx?autotype=" &  autotype & "&fromtype=caigou&fromid=" & billID & "&t=" & cdbl(now)
			Response.write  "<script>var xhttp=new XMLHttpRequest(); xhttp.open('GET','" &creatorurl & "&disGotoPayoutList=1',false);xhttp.send();</script>"
		end if
		if payplan = 5 then
			con.execute("update plan_fk set del=1 where del=3 and caigou="& billID)
			con.execute("update payout set del=1,status_sp=" & status_sp & " where del=3 and contract="& billID)
			con.execute("update payoutList set del=1 where payout in(select ord from payout where del=3 and contract="& billID &")")
			con.execute("update payoutList set del=1 where payout in(select ord from payout where del=1 and contract="& billID &") and del=3")
			con.execute("update plan_fk set del2=1 where del=2 and del2=3 and caigou="& billID)
			con.execute("update payout set del2=1,status_sp=" & status_sp & " where del=2 and del2=3 and contract="& billID)
			con.execute("update payoutList set del2=1 where payout in(select ord from payout where del=2 and del2=3 and contract="& billID &")")
		end if
		Case "payout"
		Dim caigouid, cls, fkTitle
		caigouid = 0 : cls = 0 : fkTitle = ""
		money1=  0
		Set rs = con.execute("select contract, isnull(cls,0) cls , money1, title from payout where ord="& billID &" and isnull(cls,0) not in(2) ")
		If rs.eof = False Then
			caigouid = rs("contract") : cls = rs("cls") : money1 = rs("money1") : fkTitle = rs("title")
		end if
		rs.close
		set rs = nothing
		If caigouid&""="0" Then caigouid = 0
		If cls&""="0" Then cls = 0
		If caigouid>0 Then
			on error resume next
			ismobile = app.ismobile
			if err.number > 0 then
				ismobile = False
			end if
			On Error GoTo 0
			if not (cls = 0 and fkTitle&"" = "期初应付") then
				call setPayoutMx(billID, caigouid , money1, ismobile,false)
			end if
		end if
		Case "bankout"
		If conn.execute("select top 1 1 from bank where sort=11 and gl="&billID&" and gl2="&billID).eof =False Then
			Response.write "<script>alert('此数据已提交！');</script>"
			Exit Sub
		end if
		Dim bz ,money_last ,money_list ,money_new ,invoiceMode , invoiceType , planDate
		sql = "insert into bank (bank , money2 , sort , intro , gl ,gl2 ,cateid ,date1, date7 ) "&_
		"  select bank, money1 , 11 , '供应商预付款', id,id, "& curCate &",date3,'"& now &"' from bankout2 where id="& billID
		con.execute(sql)
		bz = 14
		company = 0
		money1 = 0
		invoiceMode = 0
		invoiceType = 0
		planDate = Date
		Set rs = con.execute("select company , isnull(bank,0) bank, isnull(money1,0) money1 ,isnull(invoiceMode,0) as invoiceMode,isnull(invoiceType,0) as invoiceType ,planDate from bankout2 where id="& billID)
		If rs.eof = False Then
			bz = sdk.GetSqlValue("select top 1  bz from sortbank where id="& rs("bank"),14)
			company = rs("company")
			money1 = rs("money1")
			invoiceMode = rs("invoiceMode")
			invoiceType = rs("invoiceType")
			planDate = rs("planDate")
		end if
		rs.close
		If money1&"" = "" Then money1 = 0 Else money1 = CDBL(money1)
		money_last = getMoneyLeft(con,company,bz,2)
		con.execute("update bankout2 set money_left = money1 where id="& billID)
		If invoiceMode ="2" Then
			Dim isInvoiced , hasInvoice, taxValue
			isInvoiced = 0
			Set rs = con.execute("select isInvoiced from payoutInvoice where fromType='PREOUT' and fromid="& billID &"")
			If rs.eof=False Then
				hasInvoice = True
				isInvoiced = rs("isInvoiced")
			else
				hasInvoice = False
			end if
			rs.close
			Set rs = con.execute("select taxRate from invoiceConfig where typeid="& invoiceType &"")
			If rs.eof=False Then
				taxRate = rs("taxRate")
			end if
			rs.close
			If taxRate&"" = "" Then taxRate = 0 Else taxRate = CDbl(taxRate)
			taxValue = cdbl(money1) / (1+cdbl(taxRate)/100) * (cdbl(taxRate)/100)
'If taxRate&"" = "" Then taxRate = 0 Else taxRate = CDbl(taxRate)
			If hasInvoice = False Then
				sql = "insert into payoutInvoice(company,fromType,fromId,invoiceType,invoiceMode,taxRate,taxValue,date1,date7,money1,bz,money_left,cateid,addcate,isInvoiced,del) " &_
				" select company,'PREOUT',id,invoiceType,1,"& taxRate &","& taxValue &",planDate,'"&now()&"',money1,bz,0,cateid,"& curCate &",0,1 from bankout2 where id="& billID
				con.execute(sql)
			ElseIf isInvoiced<>1 Then
				conn.execute("update payoutInvoice set invoiceType="& invoiceType &",date1='"& planDate &"',date7='"& now() &"' where fromType='PREOUT' and fromid="& billID &"")
			end if
		end if
		money_list=money1
		money_new=cdbl(money_last)+cdbl(money_list)
'money_list=money1
		Call ChangeLog_Yfk(1,"添加预付款",money_last,money_list,money_new,bz,company, billID , curCate ,session("name2006chen"))
		End Select
	end sub
	Class CommSPHandle
		Private rs, sql, rs2
		Public currgate
		public currSpr
		Public nextSpId
		Public nextGates
		Public cateid_sp
		Public actCate
		Public addCate
		Public useCate
		Public BillID
		Public backSPInfo
		Public swicthFieldValue
		Public moneyFieldValue
		Public MoneySpFieldValue
		Public stateFieldValue
		Public reBack
		Public nextSPOK
		Public jg
		Public yspGate
		public config
		Public newmoney
		Public MoneyNumber
		Public ReturnIntro
		Public isSdkSave
		Private logOn
		Private ArrLog       ()
		Private logIdx
		Private logFile
		Public Sub initById(billid , approve)
			Me.BillID = BillID
			Set config = New CommSPConfig
			config.init_sp(approve)
			Call init2
			Call setSwicthFieldValue(billid , approve)
			Me.isSdkSave = True
		end sub
		Function setSwicthFieldValue(billid , approve)
			Select Case approve
			Case 4
			Call checkBudget(billid)
			Case 50
			Call getPayoutSwicthValue(billid)
			Case 78
			call getCommBillSwitchValue(approve, billid)
			End Select
		end function
		Function getCommBillSwitchValue(approve, billid)
			dim sql
			Select Case approve
			Case 78
			sql = "select isnull(dbo.Fn_XQgenfenlei(sort),0) wdRoot from document Where id="& BillID
			End Select
			if sql&""<>"" then
				Set rs = config.con.execute(sql)
				If rs.eof = False Then
					Me.swicthFieldValue = rs(0).value
				end if
				rs.close
				set rs = nothing
			end if
			If Me.swicthFieldValue&"" = "" Then Me.swicthFieldValue = 0
		end function
		Function getPayoutSwicthValue(billid)
			Dim rs,sp_id : sp_id = 0
			Set rs = config.con.execute("select isnull("& config.sp &",0) as sp from "& config.tabName &" where "& config.keyField &"="& BillID)
			If rs.eof= False Then
				sp_id = rs(0).value
			end if
			rs.close
			If sp_id>0 Then
				Set rs = config.con.execute("select sptype from sp where id= "& sp_id)
				If rs.eof= False Then
					Me.swicthFieldValue = rs(0).value
				end if
				rs.close
				If Me.swicthFieldValue&"" = "" Then Me.swicthFieldValue = 0
				Exit Function
			else
				Set rs = config.con.execute("select sort from caigou where ord=(select isnull(contract,0) contract from "& config.tabName &" where "& config.keyField &"="& BillID &" and isnull(cls,0)=0)")
				If rs.eof = False Then
					Me.swicthFieldValue = rs(0).value
				end if
				rs.close
				set rs = nothing
				If Me.swicthFieldValue&"" = "" Then Me.swicthFieldValue = 0
			end if
		end function
		Function checkBudget(billid)
			Dim rs,sp_id : sp_id = 0
			Set rs = config.con.execute("select isnull("& config.sp &",0) as sp from "& config.tabName &" where "& config.keyField &"="& BillID)
			If rs.eof= False Then
				sp_id = rs(0).value
			end if
			rs.close
			If sp_id>0 Then
				Set rs = config.con.execute("select sptype from sp where id= "& sp_id)
				If rs.eof= False Then
					Me.swicthFieldValue = rs(0).value
				end if
				rs.close
				Exit Function
			end if
			dim strateget
			strateget = 0
			set rs = config.con.execute("select sort from strategy where gate2=1")
			if rs.eof = False And ZBRuntime.MC(80000) then
				strateget = rs.fields(0).value
			end if
			rs.close
			set rs = nothing
			If strateget = 2 Or strateget = 1 Then
				Dim sorce : sorce= ""
				Dim uid : uid = 0
				Dim bz : bz = 14
				Dim ret : ret = Date
				Dim money : money = 0
				Set rs = config.con.execute("select cateid,bz,bxdate,(select sum(isnull(money1,0)) as spmoney from paybxlist where bxid =p.id ) as spmoney from paybx p where id = "& billid &"")
				If rs.eof =False Then
					uid = rs(0).value
					bz = rs(1).value
					ret = rs(2).value
					money = rs(3).value
				end if
				rs.close
				Set rs=config.con.execute("select isnull(sorce,0) as sorce from gate where del=1 and ord="& uid &"")
				If rs.eof = False Then
					sorce=rs("sorce").value
				else
					Exit Function
				end if
				rs.close
				Dim rss ,rss1 ,sortsql, bxsql ,mode , startdate,enddate , money1 ,money2 , atStr
				If sorce<>"" Then
					If sorce>0 Then
						sortsql=" and sort=1 and obj_ord="&sorce&" "
						bxsql=" and cateid2=" & sorce & " "
					else
						sortsql=" and sort=2 and obj_ord="& uid &" "
						bxsql=" and cateid="& uid &" and isnull(cateid2,0)=0 "
					end if
					Set rs=config.con.execute("select ord,mode,money1,startdate,enddate from budget where del=1 and isnull(status,0)=0  "& sortsql &" and bz= "& bz &" and startDate<='"& ret &"' and endDate>='" & ret & "'")
					If rs.eof = False Then
						mode=rs("mode").value
						startdate=rs("startdate").value
						enddate=rs("enddate").value
						If mode=0 then
							money1=cdbl(rs("money1").value)
							money2=0
							Set rss=config.con.execute("select isnull(sum(isnull(money1,0)),0) as money2 from paybxlist where bxid in (select id from paybx where complete<>2 and complete<>0 and bxdate between '"&startdate&"' and '"& enddate &"' and isnull(bz,14)="& bz &" "& bxsql &") and bxid <> " & billid)
							If rss.eof= False Then
								money2=cdbl(rss("money2").value)
							end if
							rss.close
							Set rss=config.con.execute("select isnull(sum(isnull(money1,0)),0) as money2 from pay where ord in (select payid from paybxlist s1 inner join paybx s2 on s1.bxid=s2.id and s2.complete=0 and s2.bxdate between '"&startdate&"' and '"&enddate&"' and isnull(s2.bz,14)="& bz &" "& bxsql &" and s1.bxid <> " & billid & ")")
							If rss.eof= False Then
								money2=cdbl(money2) + cdbl(rss("money2").value)
'If rss.eof= False Then
							end if
							rss.close
							If CDbl(money)>cdbl(money1)-cdbl(money2) Then
'rss.close
								atStr = "预算总额："& formatnumber(money1,Me.MoneyNumber,-1)&"  使用总额："&formatnumber(money2,Me.MoneyNumber,-1)&"  剩余总额："&FormatNumber((money1-money2),Me.MoneyNumber,-1)&"，本次报销金额"&formatnumber(money,Me.MoneyNumber,-1)&"，大于剩余总额"&FormatNumber((money1-money2),Me.MoneyNumber,-1)
'rss.close
							end if
						else
							Set rss=config.con.execute("select sort,money1,sortName from budgetlist where pid="& rs("ord").value &"")
							If rss.eof =False Then
								While rss.eof = False
									money1=cdbl(rss("money1"))
									money2=0
									Set rss1=config.con.execute("select isnull(sum(isnull(money1,0)),0)as money2 from paybxlist where sort="&rss("sort").value &" and bxid in (select id from paybx where complete<>2 and complete<>0 and bxdate between '"&startdate&"' and '"&enddate&"' and isnull(bz,14)="& bz &" "& bxsql &") and bxid <> " & billid)
									If rss1.eof= False Then
										money2=cdbl(rss1("money2").value)
									end if
									rss1.close
									Set rss1=config.con.execute("select isnull(sum(isnull(money1,0)),0) as money2 from pay where  sort="&rss("sort").value &" and ord in (select payid from paybxlist s1 inner join paybx s2 on s1.bxid=s2.id and s2.complete=0 and s2.bxdate between '"&startdate&"' and '"&enddate&"' and isnull(s2.bz,14)="& bz &" "& bxsql &" and s1.bxid <> " & billid & ")")
									If rss1.eof= False Then
										money2=money2 + cdbl(rss1("money2").value)
'If rss1.eof= False Then
									end if
									rss1.close
									Set rss1=config.con.execute("select isnull(sum(isnull(money1,0)),0) as money from pay where sort="&rss("sort").value &" and ord in (select payid from paybxlist where bxid="& billid &" )")
									If rss1.eof= False Then
										money=cdbl(rss1("money").value)
									else
										money=0
									end if
									rss1.close
									If money>0 And money1>0 And money>money1-money2 Then
										rss1.close
										If Len(atStr)>0 Then atStr=atStr & vbcrlf
										atStr= atStr &  ""& rss("sortName").value &"预算总额："& formatnumber(money1,Me.MoneyNumber,-1)&"  使用总额："&formatnumber(money2,Me.MoneyNumber,-1)&"  剩余总额："&FormatNumber((money1-money2),Me.MoneyNumber,-1)&"，本次报销金额"&formatnumber(money,Me.MoneyNumber,-1)&"大于剩余总额"&FormatNumber((money1-money2),Me.MoneyNumber,-1)
'If Len(atStr)>0 Then atStr=atStr & vbcrlf
									end if
									rss.movenext
								wend
							end if
							rss.close
						end if
					end if
					rs.close
				end if
				If Len(atStr)>0 Then
					If strateget = 2 Then
						If config.con.execute("select COUNT(1) from sp where gate2=4 and sptype = 1")(0)>0 Then Me.swicthFieldValue = 1
					else
						Me.ReturnIntro = atStr
					end if
				end if
			end if
		end function
		Public Function loadNextBySdk(NeedMoney , spmoney)
			Dim rs
			If NeedMoney=True Then
				spmoney = Me.moneyFieldValue
			else
				Me.moneyFieldValue = spmoney
			end if
			Call loadNextSp2(swicthFieldValue, spmoney)
		end function
		Public Sub init(Bill, BillID)
			Set config = New CommSPConfig
			config.init Bill
			If Len(config.tabName)=0 Then
				Me.ReturnIntro = "请初始定义审批类型"
				Exit Sub
			end if
			Me.BillID = BillID
			Call init2
			Call setSwicthFieldValue(BillID , config.clsId)
		end sub
		Private Sub init2()
			Me.isSdkSave = False
			Me.swicthFieldValue = 0
			Me.moneyFieldValue = 0
			Me.MoneyNumber = 2
			Me.ReturnIntro = ""
			Me.currgate = 0
			Me.nextSPOK = False
			Me.actCate = session("personzbintel2007")
			Me.addCate = session("personzbintel2007")
			Me.useCate = 0
			Me.reBack = False
			Me.yspGate = 0
			ReDim ArrLog(5000)
			logIdx = 0
			logOn = false
			logFile = "../../inc/commSPLog.txt"
			Dim rs ,sql
			Set rs = config.con.execute("select num1 from setjm3  where ord=1 ")
			If rs.eof = False Then
				Me.MoneyNumber = rs("num1").value
			end if
			rs.close
			If Len(config.swicthField)>0 Then
				sql = "isnull("&config.swicthField&",0) as " & config.swicthField
			else
				sql = "0"
			end if
			If Len(config.moneyField)>0 Then
				sql = sql &"," & "isnull("&config.moneyField&",0) as " & config.moneyField
			else
				sql = sql &",0"
			end if
			If Len(config.saveBillMoneyField)>0 Then
				sql = sql &"," & "isnull("&config.saveBillMoneyField&",0) as " & config.saveBillMoneyField
			else
				sql = sql &",0"
			end if
			sql = sql & "," & config.stateField &"," & config.sprField
			Set rs = config.con.execute("select "& sql &" from "& config.tabName &" where "& config.keyField &"="& Me.BillID)
			If rs.eof= False Then
				Me.swicthFieldValue = rs(0).value
				Me.moneyFieldValue = rs(1).value
				Me.MoneySpFieldValue = rs(2).value
				Me.stateFieldValue = rs(3).value
				Me.currSpr = rs(4).value
			end if
			rs.close
			If config.clsId = 4 Then
				Me.moneyFieldValue = config.con.execute("select isnull(sum(isnull(money1,0)),0) as spmoney from paybxlist where bxid ="& Me.BillID)(0).value
			end if
		end sub
		public property let UseCateid(v)
		if isnumeric(v) then
			Me.useCate = CLng(v)
		end if
		end Property
		public property let LogFilePath(v)
		if v&"" <> "" Then logFile = v
		end Property
		Public Function loadNextSp2(swicthFieldValue, moneyFieldValue)
			if Me.moneyFieldValue&""="" then Me.moneyFieldValue = 0
			If swicthFieldValue&""="" Then swicthFieldValue=0
			Me.swicthFieldValue = swicthFieldValue
			If moneyFieldValue&""="" Then moneyFieldValue=0 Else moneyFieldValue = CDbl(moneyFieldValue)
			If CDbl(Me.moneyFieldValue)< CDbl(moneyFieldValue) Then  Me.moneyFieldValue = CDbl(moneyFieldValue)
			Call loadNextSp()
		end function
		Public  Function loadNextSp()
			Dim sp      ,currMaxMoney, nextbt ,isCont,maxMoney,currbt,stateField
			cateid_sp = 0
			Me.currgate = 0
			Me.nextSpId = 0
			Me.nextGates = ""
			If Me.moneyFieldValue&""="" Then Me.moneyFieldValue = 0
			Me.moneyFieldValue = CDbl(Me.moneyFieldValue)
			currbt = 0
			If config.Enable = False Then Exit Function
			If Me.BillID>0 Then
				Set rs = config.con.execute("select "& config.sprField &", "& config.sp &", "& config.addField & iif(Len(config.addField2)>0,"," & config.addField2 &"","") &","& config.stateField &" from "& config.tabName &" where "& config.keyField &"="& Me.BillID)
				If rs.eof=False  Then
					cateid_sp = rs(""& config.sprField &"")
					If cateid_sp&"" = "" Then cateid_sp = 0
					sp = rs(""&config.sp&"")
					stateField=rs(""&config.stateField&"")
					If stateField&""="" Then stateField=0 Else stateField = CLng(stateField)
					If Me.reBack = True Then
						sp = 0
					else
						If Clng(cateid_sp)<>Clng(Me.actCate) And Clng(cateid_sp)>0 Then
							Me.nextSpId = -3
'If Clng(cateid_sp)<>Clng(Me.actCate) And Clng(cateid_sp)>0 Then
							Exit Function
						elseif stateField=Clng(config.stateOK) or (Clng(config.stateFou)<>Clng(config.stateShen) and stateField=Clng(config.stateFou) ) or (Clng(config.stateFou)=Clng(config.stateShen) and stateField=Clng(config.stateFou) and sp = -1 ) then
'Exit Function
							Me.nextSpId = -3
'Exit Function
							Exit Function
						end if
					end if
					Me.addCate = rs(""& config.addField & "")
					If Len(config.addField2)>0 Then
						Me.useCate = rs(""& config.addField2 &"")
					end if
					If Me.addCate & "" = "" Then Me.addCate = 0
					If Me.useCate & "" = "" Then Me.useCate = 0
					If sp&""="" Then sp=0 Else sp = CLng(sp)
					currMaxMoney = 0 : nextbt = 0 : maxMoney = 0 : currbt = 0
					Set rs2 = config.con.execute("select gate1, isnull(money2,0) as currMaxMoney, isnull(bt,0) bt from sp where id="& sp)
					If rs2.eof=False Then
						Me.currgate = rs2("gate1")
						currMaxMoney = zbcdbl(rs2("currMaxMoney")) : currbt = rs2("bt")
					end if
					rs2.close
					Set rs2 = Nothing
					If sp>0 Then
						If Clng(cateid_sp)<>Clng(Me.actCate) And Clng(cateid_sp)>0 Then
							Me.nextSpId = -3
'If Clng(cateid_sp)<>Clng(Me.actCate) And Clng(cateid_sp)>0 Then
							Exit Function
						end if
					end if
				else
					cateid_sp = 0
					Me.nextSpId = -2
					cateid_sp = 0
					Exit Function
				end if
				rs.close
				set rs = nothing
			end if
			If sp&""="" Then sp=0 Else sp = CLng(sp)
			Dim spord,sptitle,gates,m1,m2,bt, gate1
			if cdbl(Me.swicthFieldValue)>0 then
				set rs = config.con.execute("select count(ord) from sp where gate2="& config.clsId &" and ("& sp &"=0 or "& sp &"=-1 or "& sp &"=999999 or id="& sp &") and isnull(sptype,0)="& Me.swicthFieldValue &"")
'if cdbl(Me.swicthFieldValue)>0 then
				if rs(0)=0 then
					Me.swicthFieldValue = 0
				end if
				rs.close
				set rs = nothing
			end if
			isCont = False
			If currbt > 0 And config.moneyLimit = True And config.moneyField &"" <> "" Then
				If checkLastMoney(Me.currgate,Me.moneyFieldValue) > 0 Then
					isCont = True
					Call Log("[BillID="& Me.BillID &"][currgate="& Me.currgate &"][currbt > 0 And checkLastMoney = True][当前级是必经且上面流程已结束]")
				end if
			end if
			If isCont = False And config.moneyLimit = True And config.moneyField &"" <> "" Then
				If Me.moneyFieldValue< currMaxMoney And currbt=0 Then
					nextbt = checkNextBT(Me.currgate)
					If nextbt>0 Then
						isCont = True
						Call Log("[BillID="& Me.BillID &"][currgate="& Me.currgate &"][nextbt > 0 And moneyFieldValue:"& Me.moneyFieldValue &" < currMaxMoney:"& currMaxMoney &"][到当前级结束，后面只走必经流程]")
					end if
				end if
			end if
			Set rs = config.con.execute("select ord, sort1, dbo.erp_bill_GetSpLinkMan("& iif(Me.useCate>0, Me.useCate, Me.addCate) &", replace(intro,' ',''), gate3) as intro, money1, money2,gate1, isnull(bt,0) as bt from sp where gate1 > "& Me.currgate &" and gate2="& config.clsId &" and isnull(sptype,0)="& Me.swicthFieldValue &"   order by gate1")
			If rs.eof=False Then
				Do While rs.eof=False
					spord = rs("ord")
					sptitle = rs("sort1")
					If rs("intro")&""<>"" Then gates = Replace(rs("intro")," ","") Else gates = ""
					m1 = CDbl(rs("money1")) : bt = rs("bt") : m2 = CDbl(rs("money2")) : gate1 = rs("gate1")
					If (InStr(gates,"|"& Me.actCate &"=")=0 and InStr(gates,"|"& Me.addCate &"=")=0) _
					And (Me.useCate=0 Or (Me.useCate>0 And InStr(gates,"|"& Me.useCate &"=")=0)) Then
						If bt=1 Then
							Me.nextSpId = spord
							Me.nextGates = gates
							Call Log("[gate1="& gate1 &"][bt = 1][nextSpId="& spord &"][nextGates="& gates &"][此级必经]")
							Exit Do
						ElseIf isCont = False Then
							If config.moneyLimit = True And config.moneyField &"" <> "" then
								If Me.moneyFieldValue >= m1 And Me.moneyFieldValue >=currMaxMoney Then
									Me.nextSpId = spord
									Me.nextGates = gates
									Call Log("[BillID="& Me.BillID &"][gate1="& gate1 &"][nextSpId="& spord &"][nextGates="& gates &"][moneyFieldValue:"& Me.moneyFieldValue &" >= m1:"& m1 &"][进入此级流程]")
									Exit Do
								else
									isCont= true
									Call Log("[gate1="& gate1 &"][moneyFieldValue:"& moneyFieldValue &" < m1:"& m1 &" And nextbt > 0][审批流程到此结束，后面只走必经流程]")
								end if
							else
								Me.nextSpId = spord
								Me.nextGates = gates
								Call Log("[BillID="& Me.BillID &"][gate1="& gate1 &"][nextSpId="& spord &"][nextGates="& gates &"][进入此级流程]")
								Exit Do
							end if
						end if
					Else
						If isCont = False And config.moneyLimit = True And config.moneyField &"" <> "" Then
							nextbt = checkNextBT(gate1)
							If Me.moneyFieldValue< m2 Then
								If nextbt>0 Then
									isCont = True
									Call Log("[gate1="& gate1 &"][moneyFieldValue:"& moneyFieldValue &" < m2:"& m2 &" And nextbt > 0][审批流程到此结束，后面只走必经流程]")
								Else
									Me.nextSpId = 0
									Me.nextGates = ""
									Call Log("[gate1="& gate1 &"][nextSpId = "& nextSpId &"][nextGates = "& nextGates &"][审批流程结束]")
									Exit Function
								end if
							end if
						end if
					end if
					rs.movenext
				Loop
			else
				Me.nextSpId = 0
				Me.nextGates = ""
				Call Log("[BillID="& Me.BillID &"][nextSpId = "& nextSpId &"][nextGates = "& nextGates &"][后面没有审批流程，审批流程结束]")
			end if
			rs.close
			set rs = nothing
		end function
		Private Function checkNextBT(gate1)
			checkNextBT = config.con.execute("select count(1) from sp where gate1 > "& gate1 &" and gate2="& config.clsId &" and isnull(sptype,0)="& Me.swicthFieldValue &" and bt=1 ")(0)
		end function
		Private Function checkLastMoney(gate1,spMoney)
			checkLastMoney = config.con.execute("select COUNT(1) from sp_intro a inner join sp b on a.sp_id=b.id and b.gate2="& config.clsId &" where a.sort1="& config.clsId &" and a.ord="& Me.BillID &" and a.jg=1 and b.money2>"& spMoney &" and isnull(b.bt,0)=0 and isnull(b.sptype,0)="& Me.swicthFieldValue &"")(0)
		end function
		Public Function saveBillBySdk(nextSpId, cateid_sp)
			Call saveBill2(nextSpId, cateid_sp, Me.swicthFieldValue, Me.moneyFieldValue)
		end function
		Public Function saveBill2(nextSpId, cateid_sp, nowSpID, reMoney)
			Dim spIdStr, arr_allSp, i, spId, spCates, spCate, remark2, sptitle
			if nextSpId&""="" or isnull(nextSpId) then nextSpId=0
			if cateid_sp&""="" or isnull(cateid_sp) then cateid_sp=0
			if nextSpId>0 and cateid_sp=0 then
				Me.nextSpId = -2
'if nextSpId>0 and cateid_sp=0 then
				Exit Function
			end if
			if nowSpID&""="" then nowSpID=0
			if reMoney&""="" then reMoney=0 else reMoney=cdbl(reMoney)
			Me.swicthFieldValue = nowSpID
			Me.newmoney = reMoney
			If CDbl(Me.moneyFieldValue)< CDbl(reMoney) Then  Me.moneyFieldValue = CDbl(reMoney)
			If Me.BillID>0 and not me.reBack Then
				dim lastState ,nowSpGate
				nowSpGate = 0
				Set rs = config.con.execute("select isnull(a."&config.sp&",0) sp,isnull(b.gate1,0) gate1,isnull("& config.stateField &",0) state, "& config.addField & iif(Len(config.addField2)>0,"," & config.addField2 &"","") &",isnull("& config.sprField &",0) as "& config.sprField &" from "& config.tabName &" a left join sp b on a."&config.sp&"=b.id where a."& config.keyField &"="& Me.BillID)
				If rs.eof=False Then
					nowSpGate = rs("gate1").value
					lastState = rs("state")
					Me.addCate = rs(""& config.addField & "")
					If Len(config.addField2)>0 Then
						Me.useCate = rs(""& config.addField2 &"")
					end if
					If Me.addCate & "" = "" Then Me.addCate = 0
					If Me.useCate & "" = "" Then Me.useCate = 0
				end if
				rs.close
				set rs = nothing
				If cdbl(nowSpGate)>0 And Me.currgate<>nowSpGate Then
					Me.nextSpId = -1
'If cdbl(nowSpGate)>0 And Me.currgate<>nowSpGate Then
					Exit Function
				end if
			end if
			spIdStr = ""
			spIdStr = nextSpList()
			if spIdStr&""<>"" then
				arr_allSp = Split(spIdStr,",")
				for i=0 to ubound(arr_allSp)
					if arr_allSp(i)&""<>"" then
						spId = clng(arr_allSp(i))
						if spId = nextSpId then
							exit for
						end if
						spCates = ""
						set rs = config.con.execute("select sort1,intro from sp where gate2="& config.clsId &" and ord="& spId)
						if rs.eof=false then
							sptitle = rs("sort1")
							spCates = rs("intro")
							If spCates&""<>"" Then spCates=Replace(spCates," ","")
						end if
						rs.close
						set rs = nothing
						if instr(","& spCates &",",","& Me.actCate &",")>0 Or instr(","& spCates &",",","& Me.addCate &",")>0 Or (Me.useCate>0 And instr(","& spCates &",",","& Me.useCate &",")>0) then
							If instr(","& spCates &",",","& Me.addCate &",")>0 then
								remark2 = "添加人员默认审批通过"
								spCate = Me.addCate
							ElseIf instr(","& spCates &",",","& Me.actCate &",")>0 Then
								remark2 = "当前审批人默认审批通过"
								spCate = Me.actCate
							ElseIf Me.useCate>0 And instr(","& spCates &",",","& Me.useCate &",")>0 Then
								remark2 = getGateName(Me.useCate) & " 默认审批通过"        '"使用人员默认通过"
								spCate = Me.useCate
							end if
							Call Log("审批记录：[BillID = "& Me.BillID &"][spId = "& spId &"][result = 1][sptitle = "& sptitle &"][spCate = "& spCate &"][remark2 = "& remark2 &"][clsId = "& config.clsId &"][reMoney="& reMoney &"]")
							config.con.execute("insert into sp_intro(jg, intro, date1, ord, sp, cateid, sort1, money1, sp_id) values (1,'" & remark2 & "', getdate()," & Me.BillID & ",'" & sptitle & "', " & spCate & "," & config.clsId & ","& reMoney &"," & spId &") ")
						else
							exit for
						end if
					end if
				next
			end if
			call saveBill(nextSpId, cateid_sp)
		end function
		Public  Sub saveBill(nextSpId, cateid_sp)
			Dim spNum , lastJG, lastState
			spNum = 0
			lastJG = 1
			if nextSpId&""="" or isnull(nextSpId) then nextSpId=0
			if cateid_sp&""="" or isnull(cateid_sp) then cateid_sp=0
			sql = "select top 1 jg from sp_intro where sort1="& config.clsId &" and ord= "& Me.BillID &" order by date1 desc,id desc"
			Set rs = server.CreateObject("adodb.recordset")
			rs.open sql,config.con,1,1
			spNum = rs.RecordCount
			If spNum<0 Then spNum=0
			If rs.eof=False Then
				lastJG = rs("jg")
			end if
			rs.close
			set rs = nothing
			If lastJG&""="2" Or Me.reback Then spNum=0 ': lastJG = 1     ' Or lastJG&""="3" 临后是APP退回直接审批通过
			Set rs = config.con.execute("select isnull("& config.stateField &",0) from "& config.tabName &" where  "& config.keyField &"="& Me.BillID)
			If rs.eof = False Then
				lastState = rs(0)
			end if
			rs.close
			set rs = nothing
			sql = "update "& config.tabName &" set "&config.sp&"="& nextSpID &",  "& config.sprField &"="& cateid_sp
			If nextSpID=0 Then
				If Me.jg&""="3" Then
					sql = sql &", "& config.stateField &"="& nextSpID
				else
					if config.stateField = "del" then
						sql = sql &", "& config.stateField &"=(case "& config.stateField &" when "& config.stateShen &" then "& config.stateOK &" else "& config.stateField &" end)"
					else
						sql = sql &", "& config.stateField &"="& config.stateOK &""
					end if
				end if
			ElseIf nextSpID>0 And spNum=0 Then
				sql = sql &", "& config.stateField &"="& config.stateDai
			ElseIf nextSpID>0 And spNum>0 Then
				If lastState&""<>"" Then
					If lastState&"" = config.stateOK&"" Or lastState&"" = config.stateFou&"" Then
						sql = sql &", "& config.stateField &"="& config.stateDai
					else
						sql = sql &", "& config.stateField &"="& config.stateShen
					end if
				else
					sql = sql &", "& config.stateField &"="& config.stateShen
				end if
			ElseIf nextSpId=-1 Then
				sql = sql &", "& config.stateField &"="& config.stateShen
				sql = sql &", "& config.stateField &"="& config.stateFou
			end if
			sql = sql &" where "& config.keyField &"="& Me.BillID
			config.con.execute(sql)
			If (nextSpID=0 Or spNum>0) And Me.newmoney>0 And lastJG&""="1" And (config.saveBillMoneyField <> "" Or config.saveBillMoneySub <>"") Then
				If config.saveBillMoneySub <> "" Then
					If Not ExistsProc(config.saveBillMoneySub) Then
						config.con.rollbacktrans
						Response.write "<script>alert('请定义函数【"& config.saveBillMoneySub &"】');history.back();</script>"
						Exit Sub
					else
						TryExecuteProc "call "& config.saveBillMoneySub &"("& Me.BillID &","& Me.newmoney &")"
					end if
				ElseIf config.saveBillMoneyField <> "" Then
					config.con.execute("update "& config.tabName &" set "& config.saveBillMoneyField &" = "& Me.newmoney &" where "& config.keyField &"="& Me.BillID)
				end if
			end if
			If config.isExtract = True Then
				Call config.billExtract(Me.BillID, lastJG, nextSpID)
			end if
		end sub
		Public  Function saveBillBySdkSP2(result, remark, nextSpID, nextSpCateid, reMoney)
			If reMoney&""<>"" Then reMoney = Replace(reMoney&"",",","")
			saveBillBySdkSP2 = saveSP2(result, remark, nextSpID, nextSpCateid, Me.swicthFieldValue, reMoney)
		end function
		Public  Function saveSP2(result, remark, nextSpID, nextSpCateid, swicthValue, reMoney)
			If swicthValue&""="" Then swicthValue=0
			Me.swicthFieldValue=swicthValue
			if nextSpID&""="" or isnull(nextSpID) then nextSpID=0
			if nextSpCateid&""="" or isnull(nextSpID) then nextSpCateid=0
			If reMoney&""<>"" Then reMoney = Replace(reMoney&"",",","")
			saveSP2 = saveSP(result, remark, nextSpID, nextSpCateid, reMoney)
		end function
		Public  Function saveSP(result, remark, nextSpID, nextSpCateid, reMoney)
			Dim i, nowSpID, nowSpGate, sptitle, nextSpGate, sp_title, remark2
			Dim spIdStr, allSpStr, arr_allSp, spId, spGate, spIntro, spCate, nowSpCate, lastSpId
			Dim preSpCate
			nowSpID = 0
			nowSpGate = 0
			nowSpCate = 0
			sptitle = ""
			nextSpGate = 0
			spIdStr = ""
			remark2 = ""
			If reMoney&""<>"" Then reMoney = Replace(reMoney&"",",","")
			If reMoney&""="" Then reMoney=0 else reMoney=cdbl(reMoney)
			Me.jg = result
			Me.newmoney = reMoney
			If CDbl(Me.moneyFieldValue)< reMoney Then  Me.moneyFieldValue = reMoney
			if nextSpID&""="" or isnull(nextSpID) then
				nextSpID=0
			else
				nextSpID = CLng(nextSpID)
			end if
			if nextSpCateid&""="" or isnull(nextSpCateid) then
				nextSpCateid=0
			else
				nextSpCateid = CLng(nextSpCateid)
			end if
			If Me.reBack = True Then
				config.con.execute("update "& config.tabName &" set "&config.sp&"=0 where "& config.keyField &"="& Me.BillID)
			end if
			Set rs = config.con.execute("select isnull(a."&config.sp&",0) sp,isnull(b.gate1,0) gate1,"& config.addField & iif(Len(config.addField2)>0,"," & config.addField2 &"","") &",isnull("& config.sprField &",0) as "& config.sprField &" from "& config.tabName &" a left join sp b on a."&config.sp&"=b.id where a."& config.keyField &"="& Me.BillID)
			If rs.eof=False Then
				nowSpID = rs("sp")
				nowSpGate = rs("gate1")
				Me.addCate = rs(""& config.addField & "")
				If Len(config.addField2)>0 Then
					Me.useCate = rs(""& config.addField2 &"")
				end if
				If Me.addCate & "" = "" Then Me.addCate = 0
				If Me.useCate & "" = "" Then Me.useCate = 0
				nowSpCate = rs(""& config.sprField &"")
			end if
			rs.close
			set rs = nothing
			If Me.yspGate>0 And Me.yspGate<>nowSpGate Then
				saveSP = "-1"
'If Me.yspGate>0 And Me.yspGate<>nowSpGate Then
				Me.nextSpId = -1
'If Me.yspGate>0 And Me.yspGate<>nowSpGate Then
				Exit Function
			end if
			If result&""="1" Then
				spIdStr = nextSpList()
			ElseIf result&""="2" Then
				If nowSpCate&""<>Me.actCate&"" Then
					Me.nextSpId = -1
'If nowSpCate&""<>Me.actCate&"" Then
					saveSP = "-1"
'If nowSpCate&""<>Me.actCate&"" Then
					Exit Function
				end if
				spIdStr = nowSpID &","
				nowSpGate = -1
'spIdStr = nowSpID &","
				nextSpGate = -1
'spIdStr = nowSpID &","
				nextSpID = -1
'spIdStr = nowSpID &","
			ElseIf result&""="3" Then
				nowSpGate = nextSpGate
				spIdStr = nowSpID &","
			end if
			If Me.isSdkSave = False Then
				config.con.CursorLocation = 3
				config.con.begintrans
			end if
			If spIdStr&""<>"" Then
				lastSpId = 0
				If spIdStr&""="0" Then spIdStr = nowSpID &","
				arr_allSp = Split(spIdStr,",")
				if nextSpID>0 then
					lastSpId = nextSpID
				else
					lastSpId = arr_allSp(ubound(arr_allSp)-1)
					lastSpId = nextSpID
				end if
				For i=0 To ubound(arr_allSp)
					remark2 = ""
					If arr_allSp(i)&""<>"" Then
						spId = CLng(arr_allSp(i))
						Set rs = config.con.execute("select sort1, gate1, intro from sp where id="& spId)
						If rs.eof=False Then
							sptitle = rs("sort1")
							spGate = rs("gate1")
							spCate = 0
							if nowSpID&""=spId&"" then
								if remark&""="" then remark=""
								remark2 = replace(remark,"'","''")
								spCate = session("personzbintel2007")
							Else
								spIntro = rs("intro")
								if spIntro&""="" then
									spIntro="0"
								else
									spIntro = replace(spIntro," ","")
								end if
								if instr(","& spIntro &",","," & Me.addCate &",")>0 then
									remark2 = "添加人员默认审批通过"
									spCate = Me.addCate
								elseif instr(","& spIntro &",","," & Me.actCate &",")>0 then
									remark2 = "当前审批人默认审批通过"
									spCate = Me.actCate
									if spCate = preSpCate then
										remark2 = "上一级审批人员默认审批通过"
									end if
								ElseIf Me.useCate>0 And instr(","& spIntro &",",","& Me.useCate &",")>0 Then
									remark2 = getGateName(Me.useCate) & " 默认审批通过"       '"使用人员默认通过"
									spCate = Me.useCate
								else
									if nextSpID=spId and nextSpCateid&""<>"" then
										spCate = nextSpCateid
									else
										spCate = session("personzbintel2007")
									end if
									if spCate = preSpCate then
										remark2 = "上一级审批人员默认审批通过"
									end if
								end if
							end if
							If remark2&""<>"" Then
								If Len(remark2)>500 Then
									remark2 = Left(remark2,500)
								end if
							end if
							spCate = CLng(spCate)
							nowSpCate = CLng(nowSpCate)
							if spCate>0 And nowSpCate=spCate or spCate = Me.addCate or spCate = Me.useCate Then
								Call Log("审批记录：[BillID = "& Me.BillID &"][spId = "& spId &"][result = "& result &"][sptitle = "& sptitle &"][spCate = "& spCate &"][remark2 = "& remark2 &"][clsId = "& config.clsId &"][reMoney="& reMoney &"]")
								config.con.execute("insert into sp_intro(jg, intro, date1, ord, sp, cateid, sort1, money1, sp_id) values (" & result & ",'" & remark2 & "', getdate()," & Me.BillID & ",'" & sptitle & "', " & spCate & "," & config.clsId & ","& reMoney &"," & spId &") ")
							end if
							preSpCate = spCate
						end if
						rs.close
						set rs = nothing
						if lastSpId>0 and lastSpId=spID then
							exit for
						end if
					end if
				next
			end if
			Call saveBill(nextSpID, nextSpCateid)
			if err.number<>0 then
				If Me.isSdkSave = False Then config.con.rollbacktrans
				saveSP = False
				Exit Function
			else
				If Me.isSdkSave = False Then config.con.CommitTrans
				saveSP = True
			end if
		end function
		Public  Function nextSpList()
			Dim sp      ,currMaxMoney, nextbt, isCont
			Dim spords, gate1
			cateid_sp = 0 :spords = "" : isCont = False
			If Me.moneyFieldValue&""="" Then Me.moneyFieldValue = 0
			Me.moneyFieldValue = CDbl(Me.moneyFieldValue)
			If Me.BillID>0 Then
				Set rs = config.con.execute("select "& config.sprField &", "& config.sp &", "& config.addField & iif(Len(config.addField2)>0,"," & config.addField2 &"","") & " from "& config.tabName &" where "& config.keyField &"="& Me.BillID)
				If rs.eof=False Then
					cateid_sp = rs(""& config.sprField &"")
					sp = rs(""& config.sp &"")
					Me.addCate = rs(""& config.addField & "")
					If Len(config.addField2)>0 Then
						Me.useCate = rs(""& config.addField2 &"")
					end if
					If Me.addCate & "" = "" Then Me.addCate = 0
					If Me.useCate & "" = "" Then Me.useCate = 0
					If sp&""="" Then sp=0
					Set rs2 = config.con.execute("select gate1 from sp where id="& sp)
					If rs2.eof=False Then
						Me.currgate = rs2("gate1")
					end if
					rs2.close
					Set rs2 = Nothing
				end if
				rs.close
				set rs = nothing
			end if
			If sp&"" = "" Then sp = 0
			Dim spord,sptitle,gates,m1,bt
			if cdbl(Me.swicthFieldValue)>0 then
				set rs = config.con.execute("select count(ord) from sp where gate2="& config.clsId &" and ("& sp &"=0 or "& sp &"=-1 or "& sp &"=999999 or id="& sp &") and isnull(sptype,0)="& Me.swicthFieldValue &"")
'if cdbl(Me.swicthFieldValue)>0 then
				if rs(0)=0 then
					Me.swicthFieldValue = 0
				end if
				rs.close
				set rs = nothing
			end if
			Set rs = config.con.execute("select ord, sort1, dbo.erp_bill_GetSpLinkMan("& iif(Me.useCate>0, Me.useCate, Me.addCate) &", replace(intro,' ',''), gate3) as intro, money1, isnull(bt,0) as bt, isnull(money2,0) as currMaxMoney, gate1 from sp where gate1 >= "& Me.currgate &" and gate2="& config.clsId &" and isnull(sptype,0)="& Me.swicthFieldValue &" order by gate1")
			If rs.eof=False Then
				Do While rs.eof=False
					spord = rs("ord")
					sptitle = rs("sort1")
					gate1 = rs("gate1")
					If rs("intro")&""<>"" Then gates = Replace(rs("intro")," ","") Else gates = ""
					m1 = CDbl(rs("money1"))
					bt = rs("bt")
					If bt=1 Then
						spords = spords & spord &","
						Call Log("审批流程：[gate1 = "& gate1 &"][bt = "& bt &"][spord = "& spord &"][此级必经]")
					ElseIf isCont = False Then
						If config.moneyLimit = True And config.moneyField &"" <> "" then
							currMaxMoney = rs("currMaxMoney").value
							If Me.moneyFieldValue< cdbl(currMaxMoney) Then
								nextbt = checkNextBT(gate1)
								If nextbt>0 Then
									isCont = True
									If Me.moneyFieldValue >= m1 Then
										spords = spords & spord &","
										Call Log("审批流程：[gate1 = "& gate1 &"][moneyFieldValue:"& moneyFieldValue &" < currMaxMoney:"& currMaxMoney &" And nextbt > 0 And moneyFieldValue:"& moneyFieldValue &" > m1:"& m1 &"][spord = "& spord &"][后面走必经流程]")
									else
										Call Log("审批流程：[gate1 = "& gate1 &"][moneyFieldValue:"& moneyFieldValue &" < currMaxMoney:"& currMaxMoney &" And nextbt > 0 And moneyFieldValue:"& moneyFieldValue &" > m1:"& m1 &"][后面走必经流程]")
									end if
								else
									If checkLastMoney(gate1,Me.moneyFieldValue) > 0 Then
										isCont = True
										Call Log("审批流程：[gate1 = "& gate1 &"][moneyFieldValue:"& moneyFieldValue &" < currMaxMoney:"& currMaxMoney &" And nextbt = 0 And checkLastMoney > 0][前面流程已结束，后面走必经流程]")
									else
										If Me.moneyFieldValue >= m1 Then
											spords = spords & spord &","
											Call Log("审批流程：[gate1 = "& gate1 &"][spord = "& spord &"][moneyFieldValue:"& moneyFieldValue &" < currMaxMoney:"& currMaxMoney &" And moneyFieldValue >= m1:"& m1 &"][后面没有必经流程，到此结束]")
											Exit Do
										end if
									end if
								end if
							else
								If Me.moneyFieldValue >= m1 Then
									spords = spords & spord &","
									Call Log("审批流程：[gate1 = "& gate1 &"][spord = "& spord &"][moneyFieldValue:"& moneyFieldValue &" > currMaxMoney:"& currMaxMoney &" And moneyFieldValue >= m1:"& m1 &"]")
								end if
							end if
						else
							spords = spords & spord &","
							Call Log("审批流程：[gate1 = "& gate1 &"][spord = "& spord &"]")
						end if
					end if
					rs.movenext
				Loop
			else
				spords = 0
			end if
			rs.close
			set rs = nothing
			nextSpList = spords
		end function
		Public  Function spRollback()
			Dim backSPStr, nowSpGate
			backSPStr = ""
			nowSpGate = 0
			Set rs = config.con.execute("select  b.gate1 from "& config.tabName &" a left join sp b on a.sp=b.id where a."& config.keyField &"="& Me.BillID)
			If rs.eof=False Then
				nowSpGate = rs("gate1")
			end if
			rs.close
			set rs = nothing
			sql ="select t1.sp_id, t1.sp, t1.cateid, e.name from sp_intro t1 inner join( "&_
			"  select MAX(a.id) maxOrd,c.gate1 "&_
			"  from sp_intro a left join sp c on ISNULL(a.sp_id,0)=c.id "&_
			"  where a.sort1="& config.clsId &" and a.ord="& Me.BillID &" and ISNULL(c.gate1,0)>0 and a.jg=1 "&_
			"  group by c.gate1 "&_
			") t2 on t1.id=t2.maxOrd "&_
			"left join sp d on ISNULL(t1.sp_id,0)=d.id "&_
			"left join gate e on t1.cateid=e.ord and e.del=1 "&_
			"where d.gate1<"& nowSpGate &" order by t1.date1 desc"
			Set rs = config.con.execute(sql)
			While rs.eof=False
				backSPStr = backSPStr & rs("sp_id") &"[|]"& rs("sp") &"[|]"& rs("cateid") &"="& rs("name") &"{|}"
				rs.movenext
			wend
			rs.close
			set rs = nothing
			Me.backSPInfo = backSPStr
		end function
		Function nextSPSelect(showType, swicthFieldValue, moneyFieldValue)
			Dim nextSpId, nextGates, tempStr, i, arr_gates1, arr_gates2
			If showType&"" = "" Then showType = "Select"
			Call loadNextSp2(swicthFieldValue, moneyFieldValue)
			nextSpId = Me.nextSpId
			nextGates = Me.nextGates
			tempStr = ""
			If showType = "Select" Then
				tempStr = tempStr &"<select name='cateid_sp' id='cateid_sp' datatype='Limit'  min='1' max='50' msg='请选择审批人'>"
				tempStr = tempStr &"<option value=''>请选择</option>"
				if nextGates&""<>"" then
					arr_gates1 = split(nextGates,"|")
					for i=0 to ubound(arr_gates1)
						if arr_gates1(i)&""<>"" then
							arr_gates2 = split(arr_gates1(i),"=")
							tempStr = tempStr &"<option value='"& arr_gates2(0) &"'>"& arr_gates2(1) &"</option>"
						end if
					next
				end if
				tempStr = tempStr &"</select><input type='hidden' name='sp' value='"& nextSpId &"'>"
				tempStr = tempStr &" <span class='red'>*</span>"
			ElseIf showType = "sql"   Then
				if nextGates&""<>"" then
					arr_gates1 = split(nextGates,"|")
					for i=0 to ubound(arr_gates1)
						if arr_gates1(i)&""<>"" then
							arr_gates2 = split(arr_gates1(i),"=")
							If tempStr <>"" Then  tempStr = tempStr & " union all  "
							tempStr = tempStr & " select '"& arr_gates2(1) &"' as name, "&arr_gates2(0)&" as ord "
						end if
					next
				end if
			end if
			nextSPSelect = tempStr
		end function
		Function showSpRecords(cn,sort1,ord,cols)
			Dim Rs0, sql0, spname, resultStr, col2, rssp, sp_id
			If cols&"" = "" Then cols = 6
			If cols = 6 Or cols = 4 Then
				col2 = 1
			ElseIf cols = 8 Then
				col2 = 2
			end if
			Response.write "" & vbcrlf & "             <tr class=""top resetTableBg""><td height=""30"" class='fcell' colspan="""
			Response.write cols
			Response.write """><div class='group-title'>审批记录</div></td></tr>" & vbcrlf & "         <tr><td height=""30"" colspan="""
			Response.write cols
			Response.write """>" & vbcrlf & "          <table style='width:100%' border='0' cellpadding='4' cellspacing='1' bgcolor='#C0CCDD' id='content'>" & vbcrlf & "            <tr height=""27"" class=""top resetGroupTableBg"">" & vbcrlf & "                      <td width=""20%""><div align=""center"">审批阶段</div></td>" & vbcrlf & "                     <td width=""15%"" colspan="""
			Response.write col2
			Response.write """><div align=""center"">审批时间</div></td>" & vbcrlf & "                     <td width=""15%""><div align=""center"">审批结果</div></td>" & vbcrlf & "                     <td width=""20%"" colspan="""
			Response.write col2
			Response.write """><div align=""center"">审批人员</div></td>" & vbcrlf & "                     <td width=""30%"" colspan="""
			Response.write col2
			Response.write """><div align=""center"">审批意见</div></td>" & vbcrlf & "             </tr>" & vbcrlf & "           "
			sql0= "select a.sp, a.date1, a.cateid, a.jg, a.intro, a.sp_id, b.sort1 spname from sp_intro a left join sp b on isnull(a.sp_id,0)=b.id where a.ord="&ord&" and a.sort1="& sort1 &" order by a.id asc "
			Set Rs0 = server.CreateObject("adodb.recordset")
			Rs0.open sql0,cn,1,1
			if rs0.eof = False then
				do until rs0.eof=True
					spname=rs0("sp") : sp_id = rs0("sp_id")
					if sp_id&""="" And isnumeric(spname) then
						set rssp=cn.execute("select sort1 from sp where gate2="& sort1 &" and id=" & spname)
						if not rssp.eof then spname=rssp(0)
						rssp.close
						Set rssp = Nothing
					end if
					if not isnull(rs0("spname")) then spname=rs0("spname")
					If Rs0("jg")=1 Then
						resultStr="同意"
					else
						resultStr="否决"
					end if
					Response.write "" & vbcrlf & "                              <tr>" & vbcrlf & "                            <td height=""27"" class=""gray""><div align=""center"">"
					Response.write spname
					Response.write "</div></td>" & vbcrlf & "                           <td height=""27"" colspan="""
					Response.write col2
					Response.write """ class=""gray""><div align=""center"">"
					Response.write rs0("date1")
					Response.write "</div></td>" & vbcrlf & "                           <td height=""27""  class=""gray""><div align=""center"">"
					Response.write resultStr
					Response.write "</div></td>" & vbcrlf & "                           <td width=""11%"" height=""27"" colspan="""
					Response.write col2
					Response.write """ class=""gray""><div align=""center"">"
					Response.write ShowSignImage(setname("gate","ord",rs0("cateid"),"name"),rs0("cateid"),rs0("date1"))
					Response.write "</div></td>   " & vbcrlf & "                                <td width=""15%"" height=""27"" colspan="""
					Response.write col2
					Response.write """ class=""gray""><div align=""center"">"
					Response.write rs0("intro")
					Response.write "</div></td>" & vbcrlf & "                           </tr>" & vbcrlf & "                           "
					rs0.movenext
				loop
			else
				Response.write "<tr><td colspan="& cols &" align=center height=27>暂无记录</td></tr>"
			end if
			Response.write "</table>" & vbcrlf & "              </td></tr>" & vbcrlf & "              "
			rs0.close
			Set rs0 = Nothing
		end function
		Sub setBillSwith()
			dim sql2
			sql2 = ""
			if config.swicthField &""<>"" then
				sql2 = sql2 & "isnull("& config.swicthField & ",0) "
			else
				sql2 = sql2 & "0 "
			end if
			if config.moneyField &""<>"" then
				sql2 = sql2 &", isnull("& config.moneyField &",0) "
			else
				sql2 = sql2 & ", 0 "
			end if
			set rs = config.con.execute("select "& sql2 &" from "& config.tabName &" where "& config.keyField &"="& Me.BillID)
			if rs.eof = false then
				Me.swicthFieldValue = rs(0)
				Me.moneyFieldValue = rs(1)
			end if
			rs.close
			set rs = nothing
			Call setSwicthFieldValue(Me.BillID , config.clsId)
		end sub
		Private function iif(byval cv,byval ov1,byval ov2)
			if cv then iif=ov1 : exit function
			iif=ov2
		end function
		Private Function getGateName(ord)
			If ord&"" = "" Or isnumeric(ord&"") = False Then
				Exit Function
			end if
			Dim rs, cateName
			cateName = ""
			Set rs = config.con.Execute("select name from gate where ord="& ord)
			If rs.eof = False Then
				cateName = rs("name")
			end if
			rs.close
			set rs = nothing
			getGateName = cateName
		end function
		Private function ShowSignImage(catename, cateid, billdate)
			dim rs , sql
			sql =  "if exists(select 1 from setjm3 where ord=201207051 and num1=1)" & vbcrlf & _
			"begin" & vbcrlf & _
			"    select top 1 id from erp_filedatas where title='" & cateid & "' and datediff(d,date,'" & billdate & "')>=0 and folder='私人章' order by date desc, id " & vbcrlf & _
			"end" & vbcrlf & _
			"else" & vbcrlf & "begin" & vbcrlf & " select top 0 0 as id" & vbcrlf & "end"
			set rs = config.con.Execute(sql)
			if rs.eof = false then
				ShowSignImage = "<img src='../sdk/getdata.asp?id=" & rs.fields("id").value & "'>"
			else
				ShowSignImage = catename
			end if
			rs.close
		end function
		Private Function setname(tname,zname,values,rname)
			Dim names, rs
			names=""
			if values<>"" Then
				Set rs = config.con.execute("select * from "&tname&" where "&zname&"="&values&" ")
				if not rs.eof then
					names=rs(""&rname&"")
				end if
				rs.close
				set rs=nothing
			end if
			setname=names
		end function
		Private Function ExistsProc(subName)
			on error resume next
			Call TypeName(getref(subName))
			ExistsProc = (Len(Err.description)=0)
		end function
		Private Sub TryExecuteProc(subName)
			Execute subName
		end sub
		Private Sub  Log(v)
			If logOn <> True Then Exit Sub
			ArrLog(logIdx) = (logIdx+1) &". "& v & vbcrlf
'If logOn <> True Then Exit Sub
			logIdx = logIdx + 1
'If logOn <> True Then Exit Sub
		end sub
		Private Sub saveLog()
			If logOn <> True Then Exit Sub
			Dim strHTML, fso, fw, filepath, f
			set fso=server.CreateObject("Scripting.FileSystemObject")
			filepath=server.mappath(logFile)
			if fso.FileExists(filepath) then
				set f=fso.getfile(filepath)
				if f.attributes and 1 then f.attributes=f.attributes-1
'set f=fso.getfile(filepath)
				set f=nothing
			end if
			set fw = fso.opentextfile(filepath,8,TRUE,TristateTrue)
			strHTML = Join(ArrLog,"")
			fw.Write strHTML & vbcrlf
			fw.close
			set fw=nothing
			set fso=nothing
		end sub
		Private Sub Class_Terminate()
			Call saveLog()
		end sub
	End Class
	ZBRLibDLLNameSN = "ZBRLib3205"
	Sub noCache
		Response.ExpiresAbsolute = #2000-01-01#
'Sub noCache
		Response.AddHeader "pragma", "no-cache"
'Sub noCache
		Response.AddHeader "cache-control", "private, no-cache, must-revalidate"
'Sub noCache
	end sub
	Sub echo(Byval str)
		Response.write(str)
		response.Flush()
	end sub
	Sub die(Byval str)
		if not isNul(str) then
			echo str
		end if
		call db_close : Response.end()
	end sub
	Function IsNum(Str)
		IsNum=False
		If Str<>"" then
			If RegTest(Str,"^[\d]+$")=True Then
'If Str<>"" then
				IsNum=True
			end if
		end if
	end function
	Function IsMoney(Str)
		IsMoney=False
		If Str<>"" then
			If RegTest(Str,"^[\d]+\.?[\d]+?$")=True Then
'If Str<>"" then
				IsMoney=True
			end if
		end if
	end function
	Function IsNegMoney(Str)
		IsNegMoney=False
		If Str<>"" then
			If RegTest(Str,"^\-[\d]+\.?[\d]+?$")=True Then
'If Str<>"" then
				IsNegMoney=True
			end if
		end if
	end function
	Function isNul(Byval str)
		if isnull(str) then
			isNul = true : exit function
		else
			if isarray(str) then isNul = false : exit function
			if str= "" then
				isNul = true : exit function
			else
				isNul = false : exit function
			end if
		end if
	end function
	Sub closers(byval rsobj)
		if isobject(rsobj) then
			rsobj.close
			set rsobj =nothing
		end if
	end sub
	Function getrsval(Byval sqlstr)
		dim rs
		set rs = conn.execute (sqlstr)
		if rs.eof then
			getrsval = ""
		else
			If isnumeric(rs(0)) Then
				getrsval = zbcdbl(rs(0))
			else
				getrsval = rs(0)
			end if
		end if
		call closers(rs)
	end function
	Function getrs(Byval sqlstr)
		set getrs = server.CreateObject("adodb.recordset")
		getrs.open sqlstr ,conn,1,3
	end function
	Function getrsArray(Byval sqlstr)
		set rsobj = getrs(sqlstr)
		if not rsobj.eof then
			getrsArray = rsobj.getrows
		end if
		call closers(rsobj)
	end function
	Function closeconn
		if isobject(conn) then
			conn.close
			set conn =nothing
		end if
	end function
	Function jsStr(Byval str)
		jsStr = "<script language=""JavaScript"" type=""text/javascript"">"&str&"</script>"
	end function
	Function alert(Byval str)
		alert = jsStr("alert("""&str&""")")
	end function
	Function alertgo(Byval str,Byval url)
		alertgo = alert(str)&jsStr("location.href="""&url&"""")
	end function
	Function confirm(Byval str,Byval url1,Byval url2)
		confirm = jsstr("if(confirm("""&str&""")){location.href="""&url1&"""}else{location.href="""&url2&"""}")
	end function
	Function jsPageGo(Byval page)
		if isnumeric(page) then
			jsPageGo = jsStr("history.go("&page&")")
		else
			jsPageGo = jsStr("location.href="""&page&"""")
		end if
	end function
	Function Historyback(msg)
		Historyback=JavaScriptSet("alert('"& msg &"');history.go(-1)")
'Function Historyback(msg)
	end function
	Function jspageback
		jspageback = jsPageGo(-1)
'Function jspageback
	end function
	Function JavaScriptSet(str)
		JavaScriptSet = "<script language=""JavaScript"" type=""text/javascript"">"&str&"</script>"
	end function
	function CloseSelf(msg)
		CloseSelf=JavaScriptSet("try{alert('"&Replace(msg,"'","")&"'); window.opener=null;window.open('','_self');window.close();}catch(e){}")
	end function
	function ReloadCloseSelf(msg)
		ReloadCloseSelf=JavaScriptSet("alert('"&Replace(msg,"'","")&"'); try{window.opener.location.reload();}catch(e1){} try{window.opener=null;window.open('','_self');window.close();}catch(e){}")
	end function
	function strLength(str)
		on error resume next
		dim WINNT_CHINESE
		WINNT_CHINESE    = (len("中国")=2)
		if WINNT_CHINESE then
			dim l,t,c
			dim i
			l=len(str)
			t=l
			for i=1 to l
				c=asc(mid(str,i,1))
				if c<0 then c=c+65536
'c=asc(mid(str,i,1))
				if c>255 then
					t=t+1
'if c>255 then
				end if
			next
			strLength=t
		else
			strLength=len(str)
		end if
		if err.number<>0 then err.clear
	end function
	function checkphone(str,num_code)
		dim arr_num,tmpnum,tmparr,areacode
		dim i
		if trim(str)="" or isnull(str) then exit function
		str=replace(replace(str,"/","-"),"\","-")
'if trim(str)="" or isnull(str) then exit function
		arr_num=split(str,"-")
'if trim(str)="" or isnull(str) then exit function
		tmpnum=""
		for i=0 to ubound(arr_num)
			tmparr=arr_num(i)
			if i=0 then
				if left(tmparr,1)="0" and (len(tmparr)=3 or len(tmparr)=4) then
					areacode=tmparr
				else
					tmpnum=tmparr
				end if
			else
				if left(tmparr,3)="400" or left(tmparr,3)="800" then
					areacode=""
				elseif left(str,1)="1" and len(str)=11 then
					areacode=""
				end if
				if tmpnum="" then
					tmpnum=tmparr
				else
					tmpnum=tmpnum & "-" & tmparr
				end if
			end if
		next
		if areacode=num_code then areacode=""
		checkphone=areacode & tmpnum
	end function
	function strFreMobil(strMobil)
		strFreMobil=""
		Set rs = server.CreateObject("adodb.recordset")
		for i=4 to 11
			sql="select areacode  from MOBILEAREA where shortno like ''+substring('"&strMobil&"', 1, "&i&")+'%'"
'for i=4 to 11
			rs.open sql,conn,3,1
			if not rs.eof then
				if rs.recordcount=1 then
					strFreMobil=rs("areacode")
					rs.close
					exit for
				else
					strFreMobil=""
				end if
			else
				strFreMobil=""
			end if
			rs.close
		next
		set rs=nothing
	end function
	function fenjiNum(StrNum)
		StrNum=replace(StrNum,"-",",,,,,,,,,,")
'function fenjiNum(StrNum)
		fenjiNum=StrNum
	end function
	function unfenjiNum(StrNum)
		StrNum=replace(StrNum,",,,,,,,,,,","-")
'function unfenjiNum(StrNum)
		unfenjiNum=StrNum
	end function
	Function RegTest(a,p)
		Dim reg
		RegTest=false
		Set reg = New RegExp
		reg.pattern=p
		reg.IgnoreCase = True
		If reg.test(a)Then
			RegTest=true
		else
			RegTest=false
		end if
	end function
	Function RegReplace(s,p,strReplace)
		Dim r
		Set r =New RegExp
		r.Pattern = p
		r.IgnoreCase = True
		r.Global = True
		RegReplace=r.replace(s,strReplace)
	end function
	Function GetRegExpCon(strng,patrn)
		Dim regEx, Match, Matches,RetStr
		RetStr=""
		Set regEx = New RegExp
		regEx.Pattern = patrn          ' 设置模式。'"\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
'Set regEx = New RegExp
		regEx.IgnoreCase = True
		regEx.Global = True
		Set Matches = regEx.Execute(strng)
		For Each Match In Matches
			if RetStr="" then
				RetStr=Match.Value
			else
				RetStr=RetStr&"$"&Match.Value
			end if
		next
		GetRegExpCon = RetStr
	end function
	function unPhone(StrNum)
		sqlci = "select callPreNum from gate where ord="&session("personzbintel2007")&""
		Set Rsci = server.CreateObject("adodb.recordset")
		Rsci.open sqlci,conn,1,1
		num_pre1=rsci("callPreNum")
		rsci.close
		set rsci=nothing
		if num_pre1<>"" then
			StrNum=RegReplace(StrNum,"^"&num_pre1&",","")
		end if
		if  RegTest(StrNum,"^0(13[0-9]|14[0-9]|15[^4]|17[0-9]|18[0-9])\d{8}$") then
			StrNum=RegReplace(StrNum,"^"&num_pre1&",","")
			StrNum=RegReplace(StrNum,"^0","")
		end if
		StrNum=unfenjiNum(StrNum)
		unPhone=StrNum
	end function
	sub strCheckBH(bhid,table,strBhID,str)
		if strBhID<>"" then
			Err.Clear
			set rs=server.CreateObject("adodb.recordset")
			sqlStr="select "&bhid&" from "&table&" where del<>7 and "&bhid&"='"&strBhID&"'"
			rs.open sqlStr,conn,1,1
			if not rs.eof then
				Response.write"<script language=javascript>alert('该"&str&"编号已存在！请返回重试');window.history.back(-1);</script>"
'if not rs.eof then
				call db_close : Response.end
			end if
			rs.close
			set rs=nothing
		end if
	end sub
	function getPersonSex(nameX,sexX)
		getPersonSex=""
		if nameX<>"" and sexX<>"" then
			if sexX="男" then
				getPersonSex=left(nameX,1)&"先生"
			elseif sexX="女" then
				getPersonSex=left(nameX,1)&"小姐"
			else
				getPersonSex=nameX
			end if
		else
			getPersonSex=nameX
		end if
	end function
	function getPersonJob(nameX,jobX)
		getPersonJob=""
		if nameX<>"" and jobX<>"" then
			if jobX<>"" then
				getPersonJob=left(nameX,1)&jobX
			else
				getPersonJob=nameX
			end if
		else
			getPersonJob=nameX
		end if
	end function
	function getNameJob(nameX,jobX)
		getNameJob=""
		if nameX<>"" and jobX<>"" then
			if jobX<>"" then
				getNameJob=nameX&jobX
			else
				getNameJob=nameX
			end if
		else
			getNameJob=nameX
		end if
	end function
	function isMobile(num1)
		isMobile=false
		if num1<>"" then
			isMobile=RegTest(num1,"^(13[0-9]|14[0-9]|15[^4]|16[0-9]|17[0-9]|18[0-9]|19[0-9])\d{8}$")
'if num1<>"" then
		else
			isMobile=false
		end if
	end function
	function myReplace(fString)
		myString=""
		if fString<>"" then
			myString=Replace(fString,"&","&amp;")
			myString=Replace(myString,"<","&lt;")
			myString=Replace(myString,">","&gt;")
			myString=Replace(myString,"&nbsp;","")
			myString=Replace(myString,chr(13),"")
			myString=Replace(myString,chr(10),"")
			myString=Replace(myString,chr(32),"&nbsp")
			myString=Replace(myString,chr(9),"")
			myString=Replace(myString,chr(39),"")
			myString=Replace(myString,chr(34),"&quot;")
			myString=Replace(myString,chr(8),"")
			myString=Replace(myString,chr(11),"")
			myString=Replace(myString,chr(12),"")
			myString=Replace(myString,Chr(32),"")
			myString=Replace(myString,Chr(26),"")
			myString=Replace(myString,Chr(27),"")
		end if
		myReplace=myString
	end function
	Function RemoveHTML(strHTML)
		Dim objRegExp, Match, Matches
		Set objRegExp = New Regexp
		objRegExp.IgnoreCase = True
		objRegExp.Global = True
		objRegExp.Pattern = "<.+?>"
'objRegExp.Global = True
		Set Matches = objRegExp.Execute(strHTML)
		For Each Match in Matches
			strHtml=Replace(strHTML,Match.Value,"")
		next
		RemoveHTML=strHTML
		Set objRegExp = Nothing
	end function
	Function getTitle(str,byVal lens)
		if isnull(str) then getTitle="":exit function
		if str="" then
			getTitle="":exit function
		else
			dim str1
			str1=str
			str1=RemoveHTML(str1)
			if len(str1)=0 and len(str)>0 then str1="."
			if str1<>"" then
				str1=myReplace(str1)
				if str1<>"" then str1=replace(replace(replace(replace(replace(replace(str1,"&amp;nbsp;",""),"&amp;quot;",""),"&amp;amp;",""),"&amp;lt;",""),"&amp;gt;",""),"&nbsp","")
				if len(str)>lens then
					str1=left(str1,lens)&"."
				else
					str1=left(str1,lens)
				end if
			end if
			getTitle=str1
		end if
	end function
	Function getFirstName(str)
		getFirstName=""
		if str<>"" then
			strXing="欧阳|太史|端木|上官|司马|东方|独孤|南宫|万俟|闻人|夏侯|诸葛|尉迟|公羊|赫连|澹台|皇甫|宗政|濮阳|公冶|太叔|申屠|公孙|慕容|仲孙|钟离|长孙|宇文|司徒|鲜于|司空|闾丘|子车|亓官|司寇|巫马|公西|颛孙|壤驷|公良|漆雕|乐正|宰父|谷梁|拓跋|夹谷|轩辕|令狐|段干|百里|呼延|东郭|南门|羊舌|微生|公户|公玉|公仪|梁丘|公仲|公上|公门|公山|公坚|左丘|公伯|西门|公祖|第五|公乘|贯丘|公皙|南荣|东里|东宫|仲长|子书|子桑|即墨|达奚|褚师|吴铭"
			if instr(strXing,left(str,2))>0 then
				getFirstName=left(str,2)
			else
				getFirstName=left(str,1)
			end if
		else
			getFirstName=""
		end if
	end function
	Function NongliMonth(m)
		If m>=1 And m<=12 Then
			MonthStr=",正,二,三,四,五,六,七,八,九,十,十一,腊"
			MonthStr=Split(MonthStr,",")
			NongliMonth=MonthStr(m)
		else
			NongliMonth=m
		end if
	end function
	Function NongliDay(d)
		If d>=1 And d<=30 Then
			DayStr=",初一,初二,初三,初四,初五,初六,初七,初八,初九,初十,十一,十二,十三,十四,十五,十六,十七,十八,十九,二十,廿一,廿二,廿三,廿四,廿五,廿六,廿七,廿八,廿九,三十"
			DayStr=Split(DayStr,",")
			NongliDay=DayStr(d)
		else
			NongliDay=d
		end if
	end function
	Function htmlspecialchars(str)
		if len(str&"") = 0 then
			exit function
		end if
		str = Replace(str, "&", "&amp;")
		str = Replace(str, "&amp;#", "&#")
		str = Replace(str, "<", "&lt;")
		str = Replace(str, ">", "&gt;")
		str = Replace(str, """", "&quot;")
		htmlspecialchars = str
	end function
	function isEmail(num1)
		isEmail=false
		if num1<>"" then
			isEmail=RegTest(num1,"^$|^(\w{0,10}\[)?\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*(\])?$")
'if num1<>"" then
			if isEmail=false then
				isEmail=RegTest(num1,"^$|^([a-zA-Z0-9_\u4e00-\u9fa5]+\[)?\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*(\])?\;(([a-zA-Z0-9_\u4e00-\u9fa5]+\[)?\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*(\])?)*$")
			end if
		else
			isEmail=false
		end if
	end function
	function isobjinstalled(strclassstring)
		on error resume next
		isobjinstalled = false
		err = 0
		dim xtestobj
		set xtestobj = server.createobject(strclassstring)
		if 0 = err then isobjinstalled = true
		set xtestobj = nothing
		err = 0
	end function
	function DelAttach(sql_at)
		set rs_At=server.CreateObject("adodb.recordset")
		rs_At.open sql_at, conn,1,1
		if not rs_At.eof then
			FileName_At=server.MapPath(rs_At(0))
			set fso_At=server.CreateObject("scripting.filesystemobject")
			if fso_At.FileExists(FileName_At) then
				fso_At.DeleteFile FileName_At
			end if
			set fso_At=nothing
		end if
		rs_At.close
		set rs_At=nothing
	end function
	function DelAllAttach(sql_at)
		set rs_At=server.CreateObject("adodb.recordset")
		rs_At.open sql_at, conn,1,1
		if not rs_At.eof then
			do while not rs_At.eof
				FileName_At=server.MapPath(rs_At(0))
				set fso_At=server.CreateObject("scripting.filesystemobject")
				if fso_At.FileExists(FileName_At) then
					fso_At.DeleteFile FileName_At
				end if
				set fso_At=nothing
				rs_At.movenext
			loop
		end if
		rs_At.close
		set rs_At=nothing
	end function
	function getGateName(id)
		getGateName=""
		if id<>"" and isnumeric(id) then
			set rs_Gate=server.CreateObject("adodb.recordset")
			sql_Gate="select name from gate where  ord="&id&""
			rs_Gate.open sql_Gate,conn,1,1
			if not rs_Gate.eof then
				getGateName=rs_Gate("name")
			end if
			rs_Gate.close
			set rs_Gate=nothing
		end if
	end function
	function getSorceName(id)
		getSorceName="无"
		if id<>"" and isnumeric(id) then
			set rs_Gate=server.CreateObject("adodb.recordset")
			sql_Gate="select sort1 from gate1 where  ord="&id&""
			rs_Gate.open sql_Gate,conn,1,1
			if not rs_Gate.eof then
				getSorceName=rs_Gate("sort1")
			end if
			rs_Gate.close
			set rs_Gate=nothing
		end if
	end function
	function getSorce2Name(id)
		getSorce2Name="无"
		if id<>"" and isnumeric(id) then
			set rs_Gate=server.CreateObject("adodb.recordset")
			sql_Gate="select sort2 from gate2 where  ord="&id&""
			rs_Gate.open sql_Gate,conn,1,1
			if not rs_Gate.eof then
				getSorce2Name=rs_Gate("sort1")
			end if
			rs_Gate.close
			set rs_Gate=nothing
		end if
	end function
	function getUidSorceName(id)
		getUidSorceName="无"
		if id<>"" and isnumeric(id) then
			set rs_Gate=server.CreateObject("adodb.recordset")
			sql_Gate="select a.sort1 from gate1 a inner join gate b on a.ord=b.sorce where  b.ord="&id&" "
			rs_Gate.open sql_Gate,conn,1,1
			if not rs_Gate.eof then
				getUidSorceName=rs_Gate("sort1")
			end if
			rs_Gate.close
			set rs_Gate=nothing
		end if
	end function
	function getUidSorce2Name(id)
		getUidSorce2Name="无"
		if id<>"" and isnumeric(id) then
			set rs_Gate=server.CreateObject("adodb.recordset")
			sql_Gate="select a.sort2 from gate2 a inner join gate b on a.ord=b.sorce2 where  b.ord="&id&" "
			rs_Gate.open sql_Gate,conn,1,1
			if not rs_Gate.eof then
				getUidSorce2Name=rs_Gate("sort2")
			end if
			rs_Gate.close
			set rs_Gate=nothing
		end if
	end function
	function TbCompanyName(id)
		TbCompanyName=""
		if id<>"" and isnumeric(id) then
			set rs_Gate=server.CreateObject("adodb.recordset")
			sql_Gate="select name from tel where  ord="&id&""
			rs_Gate.open sql_Gate,conn,1,1
			if not rs_Gate.eof then
				TbCompanyName=rs_Gate("name")
			end if
			rs_Gate.close
			set rs_Gate=nothing
		end if
	end function
	function TbPersonName(id)
		TbPersonName=""
		if id<>"" and isnumeric(id) then
			set rs_Gate=server.CreateObject("adodb.recordset")
			sql_Gate="select name from person where  ord="&id&""
			rs_Gate.open sql_Gate,conn,1,1
			if not rs_Gate.eof then
				TbPersonName=rs_Gate("name")
			end if
			rs_Gate.close
			set rs_Gate=nothing
		end if
	end function
	function zbintelEmailEncode(inputstr,inputtype,rdNum)
		tmpstr=""
		if inputtype=1 then
			for i=1 to len(inputstr)
				tmpstr=tmpstr&emailgetChar(mid(inputstr,i,1),inputtype,rdNum)
			next
		else
			inputstr=replace(inputstr,"%","$")
			inputstr=replace(inputstr,"*","$")
			inputstr=replace(inputstr,"#","$")
			inputstr=replace(inputstr,"@","$")
			inputstr=replace(inputstr,"a","$")
			inputstr=replace(inputstr,"b","$")
			inputstr=replace(inputstr,"c","$")
			inputstr=replace(inputstr,"d","$")
			inputstr=replace(inputstr,"e","$")
			inputstr=replace(inputstr,"f","$")
			inputstr=replace(inputstr,"g","$")
			inputstr=replace(inputstr,"h","$")
			inputstr=replace(inputstr,"i","$")
			inputstr=replace(inputstr,"j","$")
			inputstr=replace(inputstr,"k","$")
			inputstr=replace(inputstr,"l","$")
			inputstr=replace(inputstr,"m","$")
			inputstr=replace(inputstr,"n","$")
			if instr(inputstr,"$")>0 then
				arrStr=split(inputstr,"$")
				for i=0 to Ubound(arrStr)-1
'arrStr=split(inputstr,"$")
					Response.write(arrStr(i)&"<br/>")
					tmpstr=tmpstr&Chr(arrStr(i)-rdNum)
					Response.write(arrStr(i)&"<br/>")
				next
			end if
		end if
		zbintelEmailEncode=tmpstr
	end function
	function emailgetChar(inputchar,chartype,rdNum)
		if inputchar<>"" then
			emailgetChar=(asc(inputchar)+rdNum)&randomStr(1)
'if inputchar<>"" then
		else
			emailgetChar=""
		end if
	end function
	Function randomStr(intLength)
		strSeed = "$%*#@abcdefghijklmn"
		seedLength = Len(strSeed)
		Str = ""
		Randomize
		For i = 1 To intLength
			Str = Str + Mid(strSeed, Int(seedLength * Rnd) + 1, 1)
'For i = 1 To intLength
		next
		randomStr = Str
	end function
	function urldecode(encodestr)
		newstr=""
		havechar=false
		lastchar=""
		for i=1 to len(encodestr)
'char_c=mid(encodestr,i,1)
			if char_c="+" then
				char_c=mid(encodestr,i,1)
				newstr=newstr & " "
			elseif char_c="%" then
				next_1_c=mid(encodestr,i+1,2)
'elseif char_c="%" then
				next_1_num=cint("&H" & next_1_c)
				if havechar then
					havechar=false
					newstr=newstr & chr(cint("&H" & lastchar & next_1_c))
				else
					if abs(next_1_num)<=127 then
						newstr=newstr & chr(next_1_num)
					else
						havechar=true
						lastchar=next_1_c
					end if
				end if
				i=i+2
				lastchar=next_1_c
			else
				newstr=newstr & char_c
			end if
		next
		urldecode=newstr
	end function
	function UTF2GB(UTFStr)
		if instr(UTFStr,"%")>0 then
			for Dig=1 to len(UTFStr)
				if mid(UTFStr,Dig,1)="%" then
					if len(UTFStr) >= Dig+8 then
'if mid(UTFStr,Dig,1)="%" then
						GBStr=GBStr & ConvChinese(mid(UTFStr,Dig,9))
						Dig=Dig+8
						GBStr=GBStr & ConvChinese(mid(UTFStr,Dig,9))
					else
						GBStr=GBStr & mid(UTFStr,Dig,1)
					end if
				else
					GBStr=GBStr & mid(UTFStr,Dig,1)
				end if
			next
			UTF2GB=GBStr
		else
			UTF2GB=UTFStr
		end if
		if UTF2GB="" then UTF2GB=UTFStr
	end function
	function ConvChinese(x)
		A=split(mid(x,2),"%")
		i=0
		j=0
		for i=0 to ubound(A)
			A(i)=c16to2(A(i))
		next
		for i=0 to ubound(A)-1
			A(i)=c16to2(A(i))
			DigS=instr(A(i),"0")
			Unicode=""
			for j=1 to DigS-1
'Unicode=""
				if j=1 then
					A(i)=right(A(i),len(A(i))-DigS)
'if j=1 then
					Unicode=Unicode & A(i)
				else
					i=i+1
					Unicode=Unicode & A(i)
					A(i)=right(A(i),len(A(i))-2)
'Unicode=Unicode & A(i)
'Unicode=Unicode & A(i)
				end if
			next
			if len(c2to16(Unicode))=4 then
				ConvChinese=ConvChinese & chrw(int("&H" & c2to16(Unicode)))
			else
				ConvChinese=ConvChinese & chr(int("&H" & c2to16(Unicode)))
			end if
		next
	end function
	function c2to16(x)
		i=1
		for i=1 to len(x) step 4
			c2to16=c2to16 & hex(c2to10(mid(x,i,4)))
		next
	end function
	function c2to10(x)
		c2to10=0
		if x="0" then exit function
		i=0
		for i= 0 to len(x) -1
'i=0
			if mid(x,len(x)-i,1)="1" then c2to10=c2to10+2^(i)
'i=0
		next
	end function
	function c16to2(x)
		i=0
		for i=1 to len(trim(x))
			tempstr= c10to2(cint(int("&h" & mid(x,i,1))))
			do while len(tempstr)<4
				tempstr="0" & tempstr
			loop
			c16to2=c16to2 & tempstr
		next
	end function
	function c10to2(x)
		mysign=sgn(x)
		x=abs(x)
		DigS=1
		do
			if x<2^DigS then
				exit do
			else
				DigS=DigS+1
				exit do
			end if
		loop
		tempnum=x
		i=0
		for i=DigS to 1 step-1
'i=0
			if tempnum>=2^(i-1) then
'i=0
				tempnum=tempnum-2^(i-1)
'i=0
				c10to2=c10to2 & "1"
			else
				c10to2=c10to2 & "0"
			end if
		next
		if mysign=-1 then c10to2="-" & c10to2
		c10to2=c10to2 & "0"
	end function
	Function checkFolder(folderpath)
		If CheckDir(folderpath) = false Then
			MakeNewsDir(folderpath)
		end if
	end function
	Function CheckDir(FolderPath)
		folderpath=Server.MapPath(".")&"\"&folderpath
		Set fso= CreateObject("Scripting.FileSystemObject")
		If fso.FolderExists(FolderPath) then
			CheckDir = True
		else
			CheckDir = False
		end if
		Set fso= nothing
	end function
	Function MakeNewsDir(foldername)
		dim fs0
		Set fso= CreateObject("Scripting.FileSystemObject")
		Set fs0= fso.CreateFolder(foldername)
		Set fso = nothing
	end function
	sub jsBack(str)
		Response.write("<script language='javascript' type='text/javascript'>alert('"&str&"');history.back()</script>")
		call db_close : Response.end
	end sub
	sub jsLocat(str,url)
		Response.write("<script language='javascript' type='text/javascript'>alert('"&str&"');window.location.href='"&url&"';</script>")
		call db_close : Response.end
	end sub
	sub jsLocat2(str,url)
		Response.write("<script language='javascript' type='text/javascript'>alert('"&str&"');window.parent.location.href='"&url&"';</script>")
		call db_close : Response.end
	end sub
	sub jsAlert(msg)
		Response.write("<script language='javascript' type='text/javascript'>alert('"& replace(msg,"'","\'") &"');</script>")
		on error resume next
		conn.close
		call db_close : Response.end
	end sub
	function DateZeros(str)
		if isnumeric(str) then
			if str<10 then
				DateZeros="0"&str
			else
				DateZeros=str
			end if
		else
			DateZeros=str
		end if
	end function
	Function CLngIP1(asNewIP)
		Dim lnResults
		Dim lnIndex
		Dim lnIpAry
		lnIpAry = Split(asNewIP, ".", 4)
		For lnIndex = 0 To 3
			If Not lnIndex = 3 Then lnIpAry(lnIndex) = lnIpAry(lnIndex) * (256 ^ (3 - lnIndex))
'For lnIndex = 0 To 3
			lnResults = lnResults * 1 + lnIpAry(lnIndex)
'For lnIndex = 0 To 3
		next
		if lnResults="" then lnResults=0
		CLngIP1 = lnResults
	end function
	Function CWebHost()
		serverUrl=Request.ServerVariables("Http_Host")
		CWebHost=false
		if RegTest(serverUrl,"^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*(\:[0-9]*)?\/*[0-9]*$") then
			CWebHost=false
			if instr(serverUrl,":")>0 then serverUrl=split(serverUrl,":")(0)
			if (CLngIP1(serverUrl)>=3232235520 and CLngIP1(serverUrl)<=3232301055) or (CLngIP1(serverUrl)>=167772160 and CLngIP1(serverUrl)<=184549375) or (CLngIP1(serverUrl)>=2130706432 and CLngIP1(serverUrl)<=2147483647) or CLngIP1(serverUrl)=0  then
				CWebHost=false
			else
				CWebHost=true
			end if
		else
			CWebHost=true
		end if
	end function
	sub checkMod(table,dataid,id,val)
		set rs9=server.CreateObject("adodb.recordset")
		sql="select "&dataid&" from "&table&" where  "&dataid&"="&id&" and ModifyStamp='"&val&"'"
		rs9.open sql,conn,1,1
		if  rs9.eof then
			call jsBack("此单据在您编辑过程中已有其他人进行了操作，请返回刷新重试！")
			call db_close : Response.end
		end if
		rs9.close
		set rs9=nothing
	end sub
	Function CheckLocalFileExist(ByVal file_dir)
		If Len(file_dir)=0 Then CheckLocalFileExist = False : Exit Function
		Dim fs : Set fs = Server.createobject(ZBRLibDLLNameSN & ".CommFileClass")
		CheckLocalFileExist = fs.ExistsFile(server.mappath(file_dir))
		Set fs = Nothing
	end function
	Function FormatTime(s_Time)
		Dim y, m, d
		FormatTime = ""
		if s_Time="" then Exit Function
		s_Time=replace(s_Time," ","")
		if instr(s_Time,"$")>0 then
			arr_time=split(s_Time,"$")
			for i=0 to ubound(arr_time)
				If IsDate(arr_time(i)) = False Then arr_time(i) = Date
				y = cstr(year(arr_time(i)))
				m = cstr(month(arr_time(i)))
				d = cstr(day(arr_time(i)))
				if timeList="" then
					timeList=y&"-"&m & "-" & d
'if timeList="" then
				else
					timeList=timeList&"$"&y&"-"&m & "-" & d
'if timeList="" then
				end if
			next
			FormatTime =timeList
		else
			If IsDate(s_Time) = False Then Exit Function
			y = cstr(year(s_Time))
			m = cstr(month(s_Time))
			d = cstr(day(s_Time))
			FormatTime =y&"-"&m & "-" & d
'd = cstr(day(s_Time))
		end if
	end function
	Function HrGetDateUnit(id)
		If id="" Then
			HrGetDateUnit =""
			Exit Function
		else
			select case id
			case 1
			HrGetDateUnit ="年"
			case 2
			HrGetDateUnit ="季"
			case 3
			HrGetDateUnit ="月"
			case 4
			HrGetDateUnit ="周"
			case 5
			HrGetDateUnit ="日"
			case else
			HrGetDateUnit =""
			end select
		end if
	end function
	function ReplaceSQL(str)
		if str<>"" and isnull(str)=false then
			str=trim(replace(str,"'","&#39"))
			str=trim(replace(str,"""","&#34"))
		end if
		ReplaceSQL=str
	end function
	function SaveRequestUrl(str)
		SaveRequestUrl=ReplaceSQL(request.QueryString(str))
	end function
	function SaveRequestForm(str)
		SaveRequestForm=ReplaceSQL(request.form(str))
	end function
	function SaveRequest(str)
		SaveRequest=ReplaceSQL(request(str))
	end function
	Function SaveRequestUrlNum(Str)
		Dim Num
		Num=ReplaceSQL(Request.QueryString(Str))
		If IsNum(Num)=False Then Num=0
		SaveRequestUrlNum=Num
	end function
	function RandomName()
		randomize
		RandomName=chr(int(rnd*26)+65)&chr(int(rnd*26)+65)&chr(int(rnd*26)+65)&chr(int(rnd*26)+65)&year(now)&month(now)&day(now)&second(now)&int(second(now)*rnd)+100
		randomize
	end function
	function GetFileEx(str)
		if instr(str,".")>0 then
			ArrStr=split(str,".")
			GetFileEx=ArrStr(ubound(ArrStr))
		else
			GetFileEx=""
		end if
	end function
	function TodayFolderName()
		TodayFolderName=year(now)&month(now)&day(now)
	end function
	function getGateBH(id)
		getGateBH=""
		if id<>"" and isnumeric(id) then
			set rsbh=server.CreateObject("adodb.recordset")
			sql="select  userbh  from hr_person where userID="&id&""
			rsbh.open sql,conn,1,1
			if not rsbh.eof then
				getGateBH=rsbh("userbh")
			end if
			rsbh.close
			set rsbh=nothing
		end if
	end function
	function GetFullSort(theTable,sortID,filed_id1, filed_sort1, filed_keyId, mark)
		if theTable&""<>"" then
			If sortID&"" = "" Then sortID = 0
			if filed_id1&"" = "" then filed_id1 = "id1"
			if filed_sort1&"" = "" then filed_sort1 = "sort1"
			if filed_keyId&"" = "" then filed_keyId = "id"
			if mark&"" = "" then mark = "-"
'if filed_keyId&"" = "" then filed_keyId = "id"
			dim rsf, rst, sortStr, id1, sort1
			sortStr=""
			Set rsf = conn.execute("select "& filed_id1 &","& filed_sort1 &" from "& theTable &" where "& filed_keyId &"=" & sortID)
			If rsf.Eof = False Then
				id1 = rsf(0)
				sort1 = TRIM(rsf(1))
				sortStr = sort1
				Dim sort_i
				For sort_i = 1 To 20
					Set rst=conn.execute("select "& filed_id1 &","& filed_sort1 &" from "& theTable &" where "& filed_keyId &"=" & id1)
					If rst.eof = true Then Exit For
					sortStr = TRIM(rst(1))& mark & sortStr
					id1 = rst(0)
					rst.Close
					Set rst = Nothing
				next
			end if
			rsf.Close
			Set rsf = Nothing
			GetFullSort = sortStr
		end if
	end function
	function formatNumB(numf,num1)
		if numf&""<>"" then
			if numf>1 then
				formatNumB = round(numf,num1)
			elseif numf>0 and numf<1 then
				numf2 = cstr(round(numf,num1))
				if left(numf2,1)="." then
					formatNumB = "0"& round(numf,num1)
				elseif left(numf2,2)="-." then
'formatNumB = "0"& round(numf,num1)
					formatNumB = "-0"& round(numf,num1)
'formatNumB = "0"& round(numf,num1)
				else
					formatNumB = round(numf,num1)
				end if
			else
				formatNumB = round(numf,num1)
			end if
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
	Function HTMLEncode2(fString)
		if not isnull(fString) Then
			fString = Replace(fString, CHR(32), "&nbsp;")
			fString = Replace(fString, CHR(34), "&quot;")
			fString = Replace(fString, CHR(39), "&#39;")
			fString = Replace(fString, CHR(13) & CHR(10), "<br>")
			fString = Replace(fString, CHR(13), "<br>")
			fString = Replace(fString, CHR(10), "<br>")
			HTMLEncode2 = fString
		end if
	end function
	Function HTMLDecode(fString)
		if not isnull(fString) Then
			fString = replace(fString, "&gt;", ">")
			fString = replace(fString, "&lt;", "<")
			fString = Replace(fString, "&nbsp;",CHR(32) )
			fString = Replace(fString, "&quot;",CHR(34) )
			fString = Replace(fString, "&#39;",CHR(39) )
			fString = Replace(fString, "<br>",CHR(13) & CHR(10))
			fString = Replace(fString, "<br>",CHR(13))
			fString = Replace(fString, "<br>",CHR(10))
			HTMLDecode = fString
		end if
	end function
	Function getKindsOfPrices(m_includeTax,priceValue,invoiceType)
		Dim pricesFun(2),rsFun,sqlFun
		pricesFun(0) = priceValue
		pricesFun(1) = priceValue
		pricesFun(2) = priceValue
		getKindsOfPrices = pricesFun
		If Len(Trim(invoiceType)&"")="0" Or invoiceType = 0 then
			sqlFun = "select b.* from sortonehy a,invoiceConfig b where b.typeid=a.id and a.gate2=34 and a.id1=-65535"
'If Len(Trim(invoiceType)&"")="0" Or invoiceType = 0 then
		else
			sqlFun = "select b.* from sortonehy a,invoiceConfig b where b.typeid=a.id and a.id =" & invoiceType
		end if
		Set rsFun = conn.execute(sqlFun)
		If rsFun.eof Then
			Exit Function
		else
			Err.clear
			on error resume next
			If m_includeTax = 1 Then
				pricesFun(1) = CDbl(priceValue)
				pricesFun(0) = CDbl(priceValue)/(1+ cdbl(rsFun("taxRate"))*0.01)
'pricesFun(1) = CDbl(priceValue)
				If Err.number <> 0 Then  pricesFun(0) = pricesFun(1)
			Else
				pricesFun(0) = CDbl(priceValue)
				pricesFun(1) = CDbl(priceValue) * (1  + cdbl(rsFun("taxRate"))* 0.01 )
'pricesFun(0) = CDbl(priceValue)
				If Err.number <> 0 Then  pricesFun(1) = pricesFun(0)
			end if
			On Error GoTo 0
			pricesFun(2) = CDbl(rsFun("taxRate"))
		end if
		rsFun.close
		getKindsOfPrices = pricesFun
	end function
	Function getGateLTable(sql2)
		Dim rs2
		If sql2&""<>"" Then
			Set rs2 = conn.execute("exec erp_comm_UsersTreeBase '"& sql2 &"',0")
			If rs2.eof = False Then
				conn.execute("if exists(select top 1 1 from tempdb..sysobjects where name='tempdb..#gate') drop table #gate; create table #gate(id int identity(1,1) not null, ord int, name nvarchar(200), orgstype int, deep int) ")
				While rs2.eof = False
					if rs2("NodeText")&"" = "" then
						t_NodeText=""
					else
						t_NodeText=rs2("NodeText")
						t_NodeText=Replace(t_NodeText,"'","''")
					end if
					conn.execute("insert into #gate(ord, name, orgstype, deep) values("& rs2("NodeId") &",'"& t_NodeText &"',"& rs2("orgstype") &","& rs2("NodeDeep") &")")
					rs2.movenext
				wend
			end if
			rs2.close
			Set rs2 = Nothing
		end if
	end function
	Function GetProductPic(proID)
		Dim rs,sql,temp
		If Len(proID&"") = 0 Then proID = 0
		sql = "SELECT TOP 1 fpath FROM sys_upload_res WHERE source = 'productPic' AND id1 = "& proID &" AND id2 = 1"
		set rs = conn.execute(sql)
		If Not rs.Eof Then
			temp = "<div align='center'><a  href='../edit/upimages/product/"& rs(0) &"' target='_blank'><img style='vertical-align: middle;' border='0' src=""../edit/upimages/product/"& Replace(rs(0),".","_s.") &"""></a></div>"
'If Not rs.Eof Then
		else
			temp = ""
		end if
		rs.close
		set rs = nothing
		GetProductPic = temp
	end function
	Function showImageBarCode(stype ,v , code,title)
		Dim s ,imgurl
		If stype=2 Then
			imgurl = "../code2/view.asp?sn=view&ct=46&data=CLDJ:"& v &"&width=120&errorh=3"
			s = "<a href='javascript:void(0)' onclick=""javascript:window.open('../code2/viewImage.asp?title="& server.urlencode(code) &"&imgurl=" & server.urlencode(imgurl) & "','imgurl_2','width=' + 320 + ',height=' + 320 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')""><img width='30' title='合同编号二维码' src='"& imgurl &"' style='padding-top:10px;cursor:pointer'></a>"
'imgurl = "../code2/view.asp?sn=view&ct=46&data=CLDJ:"& v &"&width=120&errorh=3"
		else
			imgurl = "../code2/viewCode.asp?codeType=128&data=HTID:"& v &"&height=60"
			s = "<div style='width:auto; display:inline-block !important; *zoom:1; display:inline; '><div style='text-align:center'><a href='javascript:void(0)' onclick=""javascript:window.open('../code2/viewImage.asp?codeType=128&title="& server.urlencode(code) &"&imgurl=" & server.urlencode(imgurl) & "&t="&now()&"','imgurl_1','width=' + 320 + ',height=' + 320 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')""><img  height='30' title='"&title&"' src='"& imgurl &"' style='cursor:pointer;'></a></div><div style='text-align:center'>"&v&"</div></div>"
'imgurl = "../code2/viewCode.asp?codeType=128&data=HTID:"& v &"&height=60"
		end if
		showImageBarCode = s
	end function
	function GetCpimg()
		sql = "select num1 from setjm3 where ord=20190823"
		set rs=conn.execute(sql)
		if not rs.eof then
			GetCpimg=rs(0)
		else
			conn.execute "insert into setjm3(ord,num1) values(20190823,0)"
			GetCpimg=0
		end if
		rs.close
		set rs=Nothing
	end function
	function GetAssistUnitTactics()
		sql = "select nvalue from home_usConfig where name='AssistUnitTactics' "
		set rsGetAssistUnitTactics=conn.execute(sql)
		if not rsGetAssistUnitTactics.eof then
			GetAssistUnitTactics=rsGetAssistUnitTactics(0)
		else
			conn.execute "insert into home_usConfig(name,nvalue,uid) values('AssistUnitTactics',0,0) "
			GetAssistUnitTactics=0
		end if
		rsGetAssistUnitTactics.close
		set rsGetAssistUnitTactics=Nothing
	end function
	function GetConversionUnitTactics()
		sql = "select nvalue from home_usConfig where name='ConversionUnitTactics' "
		set rsGetConversionUnitTactics=conn.execute(sql)
		if not rsGetConversionUnitTactics.eof then
			GetConversionUnitTactics=rsGetConversionUnitTactics(0)
		else
			conn.execute "insert into home_usConfig(name,nvalue,uid) values('ConversionUnitTactics',0,0) "
			GetConversionUnitTactics=0
		end if
		rsGetConversionUnitTactics.close
		set rsGetConversionUnitTactics=Nothing
	end function
	function ConvertUnitData(ProductID,OldUnit,NewUnit,Num)
		sql = "select (cast(" & Num & " as decimal(25,12)) * cast(a.bl/b.bl as decimal(25,12))  ) as num "&_
		"          from erp_comm_unitRelation a  "&_
		"          inner join erp_comm_unitRelation b on a.ord=b.ord and b.unit = " & NewUnit &_
		"          where a.ord =" & ProductID & " and a.unit = " & OldUnit
		if OldUnit = 0 then sql = "select " & Num & " as num "
		set rsConvertUnitData=conn.execute(sql)
		if not rsConvertUnitData.eof then
			ConvertUnitData=rsConvertUnitData(0)
		else
			ConvertUnitData=0
		end if
		rsConvertUnitData.close
		set rsConvertUnitData=Nothing
	end function
	function GetHistoryAssistUnit(ord)
		set rsGetHistoryAssistUnit= conn.execute("select nvalue from home_usConfig where  name='productDefaultAssistUnit_"&ord&"'  and isnull(uid, 0) =0")
		if rsGetHistoryAssistUnit.eof=false then
			if not rsGetHistoryAssistUnit(0)&"" = "" then
				GetHistoryAssistUnit = rsGetHistoryAssistUnit(0)
			else
				GetHistoryAssistUnit=0
			end if
			rsGetHistoryAssistUnit.close
			set rsGetHistoryAssistUnit=Nothing
		end if
	end function
	Sub SetHistoryAssistUnit(ord,assistUnit)
		if GetAssistUnitTactics()=1 then
			set rsSetHistoryAssistUnit = conn.execute("select * from home_usConfig where name='productDefaultAssistUnit_"&ord&"'")
			if rsSetHistoryAssistUnit.eof then
				conn.execute("insert into home_usConfig(nvalue,name,uid) values('"&assistUnit&"','productDefaultAssistUnit_"&ord&"',0)")
			else
				conn.execute("update home_usConfig set nvalue ='"&assistUnit&"' where name = 'productDefaultAssistUnit_"&ord&"'")
			end if
			rsSetHistoryAssistUnit.close
			set rsSetHistoryAssistUnit=Nothing
		end if
	end sub
	function IsDeletePayout2(ords)
		sql = "select top 1 1 from payout2 where CompleteType=8 and ord in ("&ords&") "
		set rs11=conn.execute(sql)
		IsDeletePayout2=rs11.eof
		rs11.close
		set rs11=Nothing
	end function
	function IsDeletePayout2Bybankin2(payout2)
		sql = "select top 1 1 from bankin2 where Payout2 in ("&payout2&") and money_left<money1"
		set rs11=conn.execute(sql)
		IsDeletePayout2Bybankin2=rs11.eof
		rs11.close
		set rs11=Nothing
	end function
	function IsOpenVoucherCForSKInvoice
		IsOpenVoucherCForSKInvoice = (sdk.GetSqlValue("select 1 from home_usConfig where name='Payback_Invoice_Voucher_Constraint' and nvalue=1" ,"0")="1")
	end function
	function IsOpenVoucherCForFKInvoice
		IsOpenVoucherCForFKInvoice = (sdk.GetSqlValue("select 1 from home_usConfig where name='Payout_Invoice_Voucher_Constraint' and nvalue=1" ,"0")="1")
	end function
	function IsOpenVoucherCForXTK
		IsOpenVoucherCForXTK = (sdk.GetSqlValue("select 1 from home_usConfig where name='Payout2_ContractTH_Voucher_Constraint' and nvalue=1" ,"0")="1")
	end function
	function IsOpenVoucherCForCTK
		IsOpenVoucherCForCTK = (sdk.GetSqlValue("select 1 from home_usConfig where name='Payout3_CaigouTH_Voucher_Constraint' and nvalue=1" ,"0")="1")
	end function
	
	Class BillUIClass
		Public Sub CreateFieldsHtml(ByVal field)
			If InStr(1,field.source, "autocomplete:",1) = 1 Then
				Dim url ,textStr
				If App.ExistsProc("App_setAutoComplete") Then
					Call App_setAutoComplete(field ,Replace(field.source,"autocomplete:","" ,1,1) ,field.value, url , textStr)
					If len(url)>0 Then field.url = url
					If Len(textStr)>0 Then field.linkvalue = textStr
				end if
			else
				If field.edit = False And Len(field.value)=0 Then field.value = field.defvalue
				If Len(field.source)>0 Then
					If InStr(field.source,"sql:") = 0 Then field.url = field.source
				end if
			end if
			Select Case LCase(field.uitype)
			Case "text" :              Call CTextFieldHtml(field)
			Case "date" :              Call CDateFieldHtml(field,0)
			Case "datetime" :  Call CDateFieldHtml(field,1)
			Case "number" :            Call CNumberFieldHtml(field)
			Case "money" :             Call CMoneyFieldHtml(field)
			Case "gate" :              Call CGateFieldHtml(field)
			Case "gates" :             Call CGatesFieldHtml(field)
			Case "textarea":   Call CTextAreaFieldHtml(field)
			Case "area":               Call CAreaFieldHtml(field)
			Case "select":             Call CSelectHtml(field)
			Case "radio" :             Call CCKBHtml(field,"radio")
			Case "checkbox" :  Call CCKBHtml(field,"checkbox")
			Case "editor":             Call CEditorHtml(field)
			Case "listview":   Call Clistview(field)
			Case "listtree":   Call Clisttree(field)
			Case "image" :             Call CImageHtml(field)
			Case "images" :            Call CImagesHtml(field)
			Case "picture":            Call CPictureHtml(field)
			Case "colorpicker": Call CColorpickerHtml(field)
			Case "html" :              call CHtmlFieldHtml(field)
			Case "boolbox"             Call CBoolFieldHtml(field)
			End select
		end sub
		private sub CHtmlFieldHtml(field)
			if len(field.source) > 0 then
				execute  "" & field.source & " field"
			else
				Response.write "<div class='sub-field'>"
				'execute  "" & field.source & " field"
				Response.write field.value
				Response.write "</div>"
			end if
		end sub
		Private Sub  CColorpickerHtml(field)
			Dim v : v = app.iif(field.parentgroup.bill.isAddmodel, field.defvalue, field.value)
			Response.write "<div class='sub-field'>"
'Dim v : v = app.iif(field.parentgroup.bill.isAddmodel, field.defvalue, field.value)
			Response.write GetColorPickerHTML(field.dbname, "box", field.width, v)
			Response.write "</div>"
		end sub
		Public Function GetColorPickerHTML(ByVal dbname, ByVal mdl, ByVal width, ByVal color)
			Dim html
			If app.Items("__sys_color_pickerjs") = "" Then
				app.Items("__sys_color_pickerjs") = "1"
				html = "<script language='javascript' src='" & app.virpath & "skin/default/js/jquery.colorpicker.js'></script>"
			end if
			Select case mdl
			Case "box":
			html =       html & "<input type='hidden' id='" & dbname & "_0' name='" & dbname & "' onchange='$ID(""" & dbname & "_sbox"").style.backgroundColor=this.value;if(window.__onClrPickerChange){window.__onClrPickerChange(this);}' value=""" & color & """>" &_
			"<div title='点击选择颜色' onclick='' id='" & dbname & "_sbox' class='colorPicker' style='background-color:" & color & "'></div>" &_
			"<script language='javascript'>$(document).ready(function(){$.showcolor('" & dbname & "_sbox','" & dbname & "_0');});</script>"
			Case "text":
			End select
			GetColorPickerHTML = html
		end function
		Private Sub CPictureHtml(ByVal field)
			Dim bill : Set bill = field.parentgroup.bill
			Dim v : v = app.iif(bill.isAddmodel, field.defvalue, field.value)
			Dim oreadcode
			If field.onlyread Then oreadcode = "readonly "
			Response.write "<div class='sub-field ewebeditorImg' align='left'><input type='hidden' id='" & field.dbname & "_0' name='" & field.dbname & "' value='" & v & "'>"
'If field.onlyread Then oreadcode = "readonly "
			If bill.edit = False Then field.edit =False
			If field.edit = False Then
				If isnumeric(v) Then v =  app.virpath & "sdk/bill.upload.asp?v" & app.base64.rsaencode(v)
				Response.write "<img src='" & v & "' id='" & field.dbname & "_m' onerror='this.style.display=""none""'>"
			else
				Response.write UploaderImageHtml(field.dbname, v, "picture", field.remark, bill.dbname & "." & field.dbname, bill.id, 0, 0 , app.iif(field.openproc , 1,0) ,field.showImg)
			end if
			If Len(field.unit) > 0 Then  Response.write " " & field.unit
			Call ShowNotNullUI(field)
			Response.write "</div>"
			Set bill =  nothing
		end sub
		Private Sub CImageHtml(ByVal field)
			Dim bill : Set bill = field.parentgroup.bill
			Dim v : v = app.iif(bill.isAddmodel, field.defvalue, field.value)
			Dim oreadcode
			If field.onlyread Then oreadcode = "readonly "
			Response.write "<div class='sub-field ewebeditorImg' align='center'><input type='hidden' id='" & field.dbname & "_0' name='" & field.dbname & "' value='" & v & "'>"
'If field.onlyread Then oreadcode = "readonly "
			If bill.edit = False Then field.edit =False
			If field.edit = False Then
				If isnumeric(v) Then v =  app.virpath & "sdk/bill.upload.asp?v" & app.base64.rsaencode(v)
				Response.write "<img src='" & v & "' id='" & field.dbname & "_m' onerror='this.style.display=""none""'>"
			else
				Response.write UploaderImageHtml(field.dbname, v, "image", "", bill.dbname & "." & field.dbname, bill.id, 0, 0, app.iif(field.openproc , 1,0),field.showImg )
			end if
			If Len(field.unit) > 0 Then  Response.write " " & field.unit
			Call ShowNotNullUI(field)
			Response.write "</div>"
			Set bill =  nothing
		end sub
		Private Sub CImagesHtml(ByVal field)
			Dim bill : Set bill = field.parentgroup.bill
			Dim v : v = app.iif(bill.isAddmodel, field.defvalue, field.value)
			Dim oreadcode
			If field.onlyread Then oreadcode = "readonly "
			Response.write "<div class='sub-field' align='left'><input type='hidden' id='" & field.dbname & "_0' name='" & field.dbname & "' value='" & v & "'>"
'If field.onlyread Then oreadcode = "readonly "
			If bill.edit = False Then field.edit =False
			If field.edit = False Then
				If isnumeric(v) Then v =  app.virpath & "sdk/bill.upload.asp?v" & app.base64.rsaencode(v)
				Response.write "<img src='" & v & "' id='" & field.dbname & "_m' onerror='this.style.display=""none""'>"
			else
				Response.write UploaderImageHtml(field.dbname, v, "images", "", bill.dbname & "." & field.dbname, bill.id, 0, 0 , app.iif(field.openproc , 1,0), field.showImg )
			end if
			If Len(field.unit) > 0 Then  Response.write " " & field.unit
			Call ShowNotNullUI(field)
			Response.write "</div>"
			Set bill =  nothing
		end sub
		Public Function UploaderImageHtml(ByVal dbname, ByVal src, ByVal uitype,  ByVal msg, ByVal sourcename, ByVal id1, ByVal id2, ByVal id3 , ByVal isopenproc ,ByVal showImg )
			Dim html, srcv , i
			srcv = src
			If isnumeric(src) And Len(src & "") > 0 Then srcv =  app.virpath & "sdk/bill.upload.asp?v" & app.base64.rsaencode(src)
			If uitype = "image" Then
				If len(Trim(src & "")) = 0 Then srcv = app.virpath & "skin/default/images/avatar.png"
				html = html & "<div style='padding:6px'><table align='center' style='width:1.4in;margin-left:0;' class='blluploadbgtb'><tr><td class='blluploadbgtd' style='padding-top:8px;padding-bottom:8px' align='center'><img style='border:0px;width:1.2in;height:1.2in;' src='" & srcv & "' id='" & dbname & "_m'></td></tr><tr><td  class='blluploadbgtd'>"
				html = html & UploaderHtml(uitype, "选择图像" , dbname & "_0",  sourcename, id1, id2, id3, "jpg|jpeg|gif|png" , isopenproc)
				html = html & "</td></tr></table></div>"
			ElseIf uitype = "images" Then
				html = html & "<div style='padding:6px;float:left;box-sizing:border-box;' ><ul id='"& dbname &"_ul' style='list-style:none;margin:0;'>"
'ElseIf uitype = "images" Then
				Dim rs , id,ftype ,furl , fname ,arrExtra , extraName
				Set rs = cn.execute("select * from sys_upload_res where source='"& sourcename &"'  and id1="& id1 &" order by id " )
				If rs.eof = False Then
					i = 1
					While rs.eof=False
						id = rs("id")
						fname = rs("fname")
						ftype = Split(rs("ftype")&" ","/")(0)
						arrExtra = Split(fname,".")
						extraName = LCase(arrExtra(ubound(arrExtra)))
						Select Case extraName
						Case "png","bmp" : furl = "skin/default/images/png.png"
						Case "jpg","jpeg","gif" ,"tiff" ,"jfif" ,"wmf","xmind","eps","exb" , "dwt" ,"dwg": furl = "skin/default/images/image.png"
						Case "rar","zip" : furl = "skin/default/images/rar.png"
						Case "txt" : furl = "skin/default/images/txt.png"
						Case "psd" : furl = "skin/default/images/psd.png"
						Case "pdf" : furl = "skin/default/images/pdf.png"
						Case "docx" : furl = "skin/default/images/docx.png"
						Case "doc" : furl = "skin/default/images/doc.png"
						Case "xlsx" : furl = "skin/default/images/xlsx.png"
						Case "xls" : furl = "skin/default/images/xls.png"
						Case "swf" : furl = "skin/default/images/swf.png"
						Case "dxf" : furl = "skin/default/images/dxf.png"
						Case Else :
						furl = "skin/default/images/rar.png"
						End Select
						srcv = app.virpath & "sdk/bill.upload.asp?__msgId=view&srcid=" & id
						html = html & "<li class='showli' name='"& dbname &"_n' cid="& id &" title="""& fname &""" ftype='"& extraName &"'  onmouseover='bill.showDel(this)'  onclick=""bill.showBigImage(this)"" onmouseout='bill.hideDel(this)'>"
						If InStr(ftype,"image")>0 And showImg = True Then
							html = html & "<img src='" & srcv & "' >"
						else
							html = html & "<div class='showdiv' src='"& srcv &"'><img src='"& app.virpath & furl &"' style='height:1.0in;width:1.0in;margin-left:0.1in;border:0'><div align='center' style='width:100%;margin-top:-0.08in'><a>"& app.iif(app.ByteLen(fname)>16 , left(fname,8) &"..." ,fname) &"</a></div></div>"
							'html = html & "<img src='" & srcv & "' >"
						end if
						html = html & "</li>"
						i = i + 1
'html = html & "</li>"
						rs.movenext
					wend
				else
					If len(Trim(src & "")) = 0 Then srcv = app.virpath & "skin/default/images/u109.png"
					html = html & "<li class='showli' name='"& dbname &"_n' onmouseover='bill.showDel(this)' onclick='bill.showBigImage(this)' onmouseout='bill.hideDel(this)'><img src='" & srcv & "' ></li>"
				end if
				rs.close
				html = html & "<li class='showli' id='"& dbname &"_add_n'><div>"& UploaderHtml("images", "选择文件" , dbname & "_0", sourcename,  id1, id2, id3, "jpg|jpeg|gif|png|rar|docx|doc|xlsx|xls|pdf|txt|dwt|eps|wmf|bmp|jfif|tiff|dwg|exb|zip|xmind|psd|swf|mp3|mp4|dxf" , isopenproc) &"</div></li>"
				html = html & "</ul>"
				html = html & "</div>"
			else
				If len(Trim(src & "")) = 0 Then srcv = app.virpath & "skin/default/images/u109.png"
				html = html & "<table><tr>"
				html = html & "<td><div style='width:176px;padding-top:2px'>"
				'html = html & "<table><tr>"
				html = html & UploaderHtml(uitype, "选择图片", dbname & "_0", sourcename, id1, id2, id3, "jpg|jpeg|gif|png" , isopenproc)
				html = html & "</div></td>"
				html = html & "</tr>"
				html = html & "<tr><td style='padding-top:5px;padding-bottom:5px'><img style='border:0px; width:200px;' src='" & srcv & "' id='" & dbname & "_m'></td></tr>"
				'html = html & "</tr>"
				html = html & "<tr><td><span style='color:red'>" & msg & "</span></td></tr>"
				html = html & "</table>"
			end if
			UploaderImageHtml = html
		end function
		Public Function UploaderHtml(ByVal style, ByVal caption, ByVal valuebox, ByVal sourcename, ByVal id1, ByVal id2, ByVal id3, ByVal filters ,ByVal isopenproc)
			Dim attrs, cssname
			Select Case LCase(style)
			Case "image" : cssname = "bllUploadimageSkin"
			Case "images" : cssname = "bllUploadimagesSkin"
			Case "picture" : cssname = "bllUploadpicSkin"
			End Select
			attrs = " class='" & cssname & "' "
			UploaderHtml = "<button onmouseout='this.className=""" &  cssname & """' onmouseover='this.className=""" &  cssname & "_over""' " & attrs &_
			" onclick='bill.showUploadDlg(this,""" & valuebox & """,""" & sourcename & """," & id1 & "," & id2 & "," & id3 & ",""" & filters & ""","& LCase(isopenproc) &")'>" & caption & "</button>"
		end function
		Private Sub CEditorHtml(ByVal field)
			Dim bill: Set bill = field.parentgroup.bill
			Dim v : v = app.iif(bill.isAddmodel, field.defvalue, field.value)
			If bill.edit = False Then field.edit =False
			If field.edit = False Then
				Response.write "<div class='sub-field ewebeditorImg'>"
'If field.edit = False Then
				Response.write v
			else
				Response.write "<div class='sub-field'>"
				Response.write v
				Response.write "<textarea id='" & field.dbname & "_0' name='" & field.dbname & "' style='display:none' cols=1 rows=1>" & v & "</textarea>"
				Response.write "<IFRAME style='position:relative' tag='billlist' style='' ID='" & field.dbname & "_editor' SRC='"& app.virpath &"edit/ewebeditor.asp?id=" & field.dbname & "_0&style=news' FRAMEBORDER='0' SCROLLING='no' width='100%' height=300 marginwidth=1 marginheight=1 name='eWebEditor_MTnm" & field.dbname & "'></IFRAME>"
			end if
			Response.write "</div>"
		end sub
		Private Sub CCKBHtml(ByVal field, ByVal cktype)
			Dim i, item, crv, oreadcode
			Dim options, bill: Set bill = field.parentgroup.bill
			Dim v : v = app.iif(bill.isAddmodel, field.defvalue, field.value)
			Call bill.GetSourceData(options, field)
			If field.onlyread Then
				oreadcode = "onclick='return false' "
			else
				oreadcode = field.js
			end if
			Response.write "<div class='sub-field'>"
			oreadcode = field.js
			If bill.edit = False Then field.edit =False
			If field.edit = False Then
				v = v & ""
				For i = 0 To ubound(options)
					If options(i)(1) & "" = v Then
						Response.write options(i)(0) & " "
					end if
				next
			else
				If isarray(options) Then
					crv = "," & Trim(v & "") & ","
					For i = 0 To ubound(options)
						item =options(i)
						If InStr(1,crv, "," & item(1) & ",",1) > 0 Then
							Response.write "<input isfield=1 " & oreadcode & "name='" & field.dbname & "' id='" & field.dbname & "_" & i & "' type='" & cktype & "' checked value='" & item(1) & "'><label for='" & field.dbname & "_" & i & "' id='" & field.dbname & "_" & i & "_lb'>" & item(0) & "</label>&nbsp;"
						else
							Response.write "<input isfield=1 " & oreadcode & "name='" & field.dbname & "' id='" & field.dbname & "_" & i & "' type='" & cktype & "' value='" & item(1) & "'><label for='" & field.dbname & "_" & i & "' id='" & field.dbname & "_" & i & "_lb'>" & item(0) & "</label>&nbsp;"
						end if
					next
				end if
			end if
			Call ShowNotNullUI(field)
			Response.write "</div>"
		end sub
		Private Function ArrayUbound(ByRef arr)
			on error resume next
			ArrayUbound = ubound(arr)
			If Err.number = 13 Or Err.number = 9 Then
				ArrayUbound = -1
'If Err.number = 13 Or Err.number = 9 Then
				Err.clear
			end if
		end function
		Private Sub  CSelectHtml(ByVal field)
			Dim bill :  Set bill = field.parentgroup.bill
			Dim v : v = app.iif(bill.isAddmodel, field.defvalue, field.value)
			Dim options, item, i, sd, oreadcode
			If field.onlyread Then oreadcode = "onfocus='this.blur()' "
			Response.write "<div class='sub-field'>"
'If field.onlyread Then oreadcode = "onfocus='this.blur()' "
			Call bill.GetSourceData(options, field)
			If bill.edit = False Then field.edit =False
			If field.edit = False Then
				v = v & ""
				For i = 0 To ArrayUbound(options)
					If options(i)(1) & "" = v Then
						Response.write options(i)(0)
						If Len(field.unit) > 0 Then  Response.write " " & field.unit
						Exit sub
					end if
				next
				If isnumeric(v & "") And app.getint("debug")=1 Then
					Response.write "[" & v & "]"
				end if
			else
				Response.write "<select isfield=1 " & oreadcode & " " & field.js & "name='" & field.dbname & "' id='" & field.dbname & "_0'>"
				If Len(field.NullSelectMsg) > 0 Then
					item = Split(field.NullSelectMsg, Chr(1))
					Response.write "<option selected value='" & item(1) & "'>" & item(0) & "</option>"
				end if
				If isarray(options) Then
					For i = 0 To ubound(options)
						item =options(i)
						If v & "" = item(1) & "" Then
							Response.write "<option selected value='" & item(1) & "'>" & item(0) & "</option>"
						else
							Response.write "<option value='" & item(1) & "'>" & item(0) & "</option>"
						end if
					next
				else
					If  Len(field.NullSelectMsg) = 0 then
						Response.write "<option value=''>==无选择项==</option>"
					end if
				end if
				Response.write "</select>"
			end if
			If Len(field.unit) > 0 Then  Response.write " " & field.unit
			Call ShowNotNullUI(field)
			Response.write "</div>"
		end sub
		Private Sub CAreaFieldHtml(ByVal field)
			Dim v : v = app.iif(field.parentgroup.bill.isAddmodel, field.defvalue, field.value)
			Dim rs, nv
			If Len(v & "") > 0 Then
				Set rs = cn.execute("select menuname from menuarea where id=" & v)
				If rs.eof = False Then  nv = rs.fields(0).value
				rs.close
			end if
			Response.write "<div class='sub-field'>"
			If rs.eof = False Then  nv = rs.fields(0).value
			If field.parentgroup.bill.edit = False Then field.edit =False
			If field.edit = False Then
				Response.write app.HtmlConvert(nv)
			else
				Response.write "<input size='10' maxlength='30' readonly isfield=1 type='text' name='" & field.dbname & "_nv' id='" & field.dbname & "_nv_0' value=""" & app.HtmlConvert(nv) & """><input type='hidden' value='" & v & "' name='" & field.dbname & "' id='" & field.dbname & "_0'>"
				If field.onlyread = False Then
					Response.write " <a href='javascript:void(0)' onClick=""window.open('../work/arealist.asp?sdk_bill=1&k=" & field.dbname & "','evenartcom','width=' + 300 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"" ><span class='blue2'>更改<img src='../images/jiantou.gif'  border='0'></span></a>"
				end if
			end if
			Call ShowNotNullUI(field)
			Response.write "</div>"
		end sub
		Private Sub CTextAreaFieldHtml(ByVal field)
			Dim v : v = app.iif(field.parentgroup.bill.isAddmodel, field.defvalue, field.value)
			Dim oreadcode
			If field.onlyread Then oreadcode = "readonly "
			Response.write "<div class='sub-field'>"
'If field.onlyread Then oreadcode = "readonly "
			If field.parentgroup.bill.edit = False Then field.edit =False
			If field.edit = False Then
				Response.write HTMLEncode(app.HtmlConvert(v))
			else
				Response.write "<textarea " & oreadcode & "isfield=1 style='width:80%;' rows=4 name='" & field.dbname & "' id='" & field.dbname & "_0'>" & app.HtmlConvert(v) & "</textarea>"
			end if
			If Len(field.unit) > 0 Then  Response.write " " & field.unit
			Call ShowNotNullUI(field)
			Response.write "</div>"
		end sub
		Private Sub CGateFieldHtml(ByVal field)
			Dim v : v = app.iif(field.parentgroup.bill.isAddmodel, field.defvalue, field.value)
			dim rs1, nm, oreadcode , sort1
			v = Replace(Replace(v & "", "'",""), " ", "")
			If Len(v) = 0 Then v = "0"
			If InStr(v, ",") > 0 then
				Set rs1 = cn.execute("select name from gate where ord in (" & v & ")")
			ElseIf v = "0" Then
				Set rs1 = cn.execute("select top 0 '' as r")
			else
				Set rs1 = cn.execute("select name from gate where ord = " & v & "")
			end if
			While rs1.eof = False
				nm = nm & rs1.fields(0).value & " "
				rs1.movenext
			wend
			rs1.close
			nm = Trim(nm)
			Response.write "<div class='sub-field'>"
'nm = Trim(nm)
			If field.onlyread Then oreadcode = "readonly "
			If field.parentgroup.bill.edit = False Then field.edit =False
			If field.edit = False Then
				Response.write app.HtmlConvert(nm)
			else
				sort1 = field.source
				If sort1 = "" Then sort1 = "appoint"
				Response.write "<input size='15' maxlength='30' " & oreadcode & " "& app.iif(field.onlyread , " onclick='bill.showGateDlg(this,"""& field.dbname &""","""&  sort1 &""")' " ,"") &" isfield=1 type='text' name='" & field.dbname & "_nv' id='" & field.dbname & "_nv_0' value=""" & app.HtmlConvert(nm) & """ ><input type='hidden' value='" & v & "' name='" & field.dbname & "' id='" & field.dbname & "_0'>"
			end if
			If Len(field.unit) > 0 Then  Response.write " " & field.unit
			Call ShowNotNullUI(field)
			Response.write "</div>"
		end sub
		Private Sub CGatesFieldHtml(ByVal field)
			Dim v : v = app.iif(field.parentgroup.bill.isAddmodel, field.defvalue, field.value)
			dim rs1, nm, oreadcode , sort1
			v = Replace(Replace(v & "", "'",""), " ", "")
			If Len(v) = 0 Then v = "0"
			If InStr(v, ",") > 0 then
				Set rs1 = cn.execute("select name from gate where ord in (" & v & ")")
			ElseIf v = "0" Then
				Set rs1 = cn.execute("select top 0 '' as r")
			else
				Set rs1 = cn.execute("select name from gate where ord = " & v & "")
			end if
			While rs1.eof = False
				nm = nm & rs1.fields(0).value & " "
				rs1.movenext
			wend
			rs1.close
			nm = Trim(nm)
			If v="1" Then nm = "所有人员"
			Response.write "<div class='sub-field'>"
'If v="1" Then nm = "所有人员"
			If field.onlyread Then oreadcode = " disabled "
			If field.parentgroup.bill.edit = False Then field.edit =False
			If field.edit = False Then
				Response.write app.HtmlConvert(nm)
			else
				sort1 = field.source
				If sort1 = "" Then sort1 = "2"
				Response.write "<input type='radio' " & oreadcode & " "& app.iif(field.onlyread , "", " onclick='$(""#" & field.dbname & "_gate"").hide()' ") &" isfield=1  name='" & field.dbname & "_nv' id='" & field.dbname & "_nv_0' value=""1"" "& app.iif(v="1" , " checked='checked' " , "") &"><label for='" & field.dbname & "_nv_0'><strong>所有人员</strong></label>&nbsp;"
				Response.write "<input type='radio' " & oreadcode & " "& app.iif(field.onlyread ,"", " onclick='$(""#" & field.dbname & "_gate"").show()' " ) &" isfield=1  name='" & field.dbname & "_nv' id='" & field.dbname & "_nv_1' value=""2"" "& app.iif(v="1" , "" , " checked='checked' ") &"><label for='" & field.dbname & "_nv_1' ><strong>以下人员</strong></label>"
				Response.write "<div id='" & field.dbname & "_gate' style='"& app.iif(v="1" , " display:none " , "") &"'>"
				Call bill_ShowGateList(sort1, v , field.dbname , True)
				Response.write "</div>"
			end if
			If Len(field.unit) > 0 Then  Response.write " " & field.unit
			Call ShowNotNullUI(field)
			Response.write "</div>"
		end sub
		Private Sub CMoneyFieldHtml(ByVal field)
			Dim v : v = app.iif(field.parentgroup.bill.isAddmodel, field.defvalue, field.value)
			Dim oreadcode, fieldDotNum
			If field.onlyread Then oreadcode = "readonly "
			fieldDotNum = Info.moneyNumber
			If Len(v & "") > 0 And isnumeric(v & "") = true Then
				Select Case field.dbtype
				Case "commprice" : fieldDotNum = Info.CommPriceDotNum
				Case "salesprice" : fieldDotNum = Info.SalesPriceDotNum
				Case "storeprice" : fieldDotNum = Info.StorePriceDotNum
				Case "financeprice" : fieldDotNum = Info.FinancePriceDotNum
				Case else : fieldDotNum = Info.moneyNumber
				End Select
				v = FormatNumber(v, fieldDotNum, -1)
'End Select
			end if
			Response.write "<div class='sub-field'>"
'End Select
			If field.parentgroup.bill.edit = False Then field.edit =False
			If field.edit = False Then
				Response.write app.HtmlConvert(v)
			else
				Response.write "<input onkeyup=""value=value.replace(/[^\d\.]/g,'');checkDot(this.id,'" & fieldDotNum & "')""  " & oreadcode & "dataType='' size='15' maxlength='15' isfield=1 type=""text"" name='" & field.dbname & "' id='" & field.dbname & "_0' value=""" & Replace(app.HtmlConvert(v),",","") & """>"
			end if
			If Len(field.unit) > 0 Then  Response.write " " & field.unit
			Call ShowNotNullUI(field)
			Response.write "</div>"
		end sub
		Private Sub CNumberFieldHtml(ByVal field)
			Dim v : v = app.iif(field.parentgroup.bill.isAddmodel , field.defvalue, field.value)
			Dim oreadcode
			If field.onlyread Then oreadcode = "readonly "
			If Len(v & "") > 0 And isnumeric(v & "") = true Then
				If field.dbtype = "int" Then
					v = FormatNumber(v, 0, -1)
'If field.dbtype = "int" Then
				else
					v = FormatNumber(v, Info.floatNumber, -1)
'If field.dbtype = "int" Then
				end if
			end if
			Response.write "<div class='sub-field'  id='" & field.dbname & "_div'>"
'If field.dbtype = "int" Then
			If field.parentgroup.bill.edit = False Then field.edit =False
			If field.edit = False Then
				Response.write app.HtmlConvert(v)
			else
				Response.write "<input onkeyup=""if((event.keyCode>36 && event.keyCode<41)||event.keyCode==8){return true;};value=value.replace(/[^\d\.]/g,'');checkDot(this.id,'" & Info.floatnumber & "')"" " & oreadcode & "size='15' maxlength='15' isfield=1 type=""text"" name='" & field.dbname & "' id='" & field.dbname & "_0' value=" & Replace(app.HtmlConvert(v),",","") & ">"
			end if
			If Len(field.unit) > 0 Then  Response.write " " & field.unit
			Call ShowNotNullUI(field)
			Response.write "</div>"
		end sub
		Private Sub CTextFieldHtml(ByVal field)
			Dim oreadcode, css
			If field.onlyread Then oreadcode = "readonly "
			If field.width <> "" Then Call AddCssItem(css, "width:" & field.width & app.iif(isnumeric(field.width),"px", "") )
			Dim v : v = app.iif(field.parentgroup.bill.isAddmodel, field.defvalue, field.value)
			Response.write "<div class='sub-field gray' id='" & field.dbname & "_div'>"
'Dim v : v = app.iif(field.parentgroup.bill.isAddmodel, field.defvalue, field.value)
			If field.parentgroup.bill.edit = False Then field.edit =False
			If field.edit = False Then
				If len(field.linkvalue &"")>0 Then
					Response.write app.iif(Len(field.url)>0 ,"<a href='javascript:void(0)' onclick=""javascript:window.open('"& app.virpath & field.url &"','newwin_"&field.dbname&"','width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=200')"">","")
'If len(field.linkvalue &"")>0 Then
					Response.write app.HtmlConvert(field.linkvalue &"")
					Response.write app.iif(Len(field.url)>0 ,"</a>","")
					Response.write "<input type='hidden' value='" & v & "' name='" & field.dbname & "' id='" & field.dbname & "_0'>"
				else
					If LCase(Left(field.source,13))="autocomplete:" Then
						Response.write ""
					elseIf field.canConvertHtml Then
						Response.write app.HtmlConvert(v & "")
					else
						Response.write v
					end if
				end if
			else
				If len(field.url)>0 Or len(field.linktype)>0 Then
					Response.write "<input " & oreadcode & " " & field.js & " isfield=1 type='text'  " & css & "  name='" & field.dbname & "_nv' id='" & field.dbname & "_nv_0' value=""" & app.HtmlConvert(field.linkvalue &"") & """><img src='" & app.virpath & "images/11645.png' onclick='bill.setAutoComplete(this,"""& field.dbname &""","""&  field.title &""","""& field.linktype &""","""& field.url &""",1)' style='background:white;height:13px;cursor:pointer;margin-left:-17px;margin-right:4px'><input type='hidden' value='" & v & "' name='" & field.dbname & "' id='" & field.dbname & "_0'>"
'If len(field.url)>0 Or len(field.linktype)>0 Then
				else
					Response.write "<input " & oreadcode & " " & field.js & " isfield=1 type=""text"" " & css & " name='" & field.dbname & "' id='" & field.dbname & "_0' value=""" & app.HtmlConvert(v & "") & """>"
				end if
			end if
			If Len(field.unit) > 0 Then  Response.write " " & field.unit
			Call ShowNotNullUI(field)
			Response.write "</div>"
		end sub
		Private Sub CBoolFieldHtml(ByVal field)
			Dim oreadcode, css
			If field.onlyread Then oreadcode = "readonly "
			If field.width <> "" Then Call AddCssItem(css, "width:" & field.width & app.iif(isnumeric(field.width),"px", "") )
			Dim v : v = app.iif(field.parentgroup.bill.isAddmodel, field.defvalue, field.value)
			Response.write "<div class='sub-field gray' >"
'Dim v : v = app.iif(field.parentgroup.bill.isAddmodel, field.defvalue, field.value)
			If field.parentgroup.bill.edit = False Then field.edit =False
			If field.edit = False Then
				If field.canConvertHtml Then
					Response.write app.HtmlConvert(v & "")
				else
					Response.write v
				end if
			else
				Response.write "<input "
				If isnumeric(v) Then
					If Abs(v) = 1 Then Response.write "checked "
				end if
				Response.write oreadcode & " " & field.js & " isfield=1 type=""checkbox"" " & css & " name='" & field.dbname & "' id='" & field.dbname & "_0' value=1>"
			end if
			If Len(field.unit) > 0 Then  Response.write " " & field.unit
			Call ShowNotNullUI(field)
			Response.write "</div>"
		end sub
		Private Sub CDateFieldHtml(ByVal field, ByVal dt)
			Dim v : v = app.iif(field.parentgroup.bill.isAddmodel, field.defvalue, field.value)
			Dim oreadcode
			oreadcode = "readonly "
			If Len(v) > 0 And isdate(v) Then
				If dt=0 then
					v = year(v) & "-" & right("00" & month(v),2) & "-" & Right("000" & day(v), 2)
'If dt=0 then
				else
					v = year(v) & "-" & right("00" & month(v),2) & "-" & Right("000" & day(v), 2) & Right("00" & hour(v),2) & ":" & Right("00" & Minute(v),2) & ":" & Right("00" & Second(v),2)
'If dt=0 then
'If dt=0 then
				end if
			end if
			Response.write "<div class='sub-field'>"
'& Right(00 & hour(v),2) & : & Right(00 & Minute(v),2) & : & Right(00 & Second(v),2)
			If field.parentgroup.bill.edit = False Then field.edit =False
			If field.edit = False Then
				Response.write v
			else
				Response.write "<input " & oreadcode & " " & field.js & "maxlength='10' isfield=1 type=""text"" name='" & field.dbname & "' id='" & field.dbname & "_0' "
				If field.onlyread = False then
					If dt = 0 then
						Response.write " size=12 style='width:80px' onclick='datedlg.show()' minDate='"&field.minValue&"' maxDate='"&field.maxValue&"' "
					else
						Response.write " size=20 onclick='datedlg.showDateTime()'"
					end if
				end if
				Response.write " value=""" & app.HtmlConvert(v & "") & """>"
			end if
			If Len(field.unit) > 0 Then  Response.write " " & field.unit
			Call ShowNotNullUI(field)
			Response.write "</div>"
		end sub
		Private Sub Clistview(ByVal field)
			If app.existsProc("bill_onListCreate") Then
				Dim lvw
				Set lvw = New listview
				lvw.border = 0
				lvw.PageButtonAlign = "right"
				lvw.oldPageSizeUI = True
				lvw.PageBar = False
				lvw.addlink = ""
				lvw.checkbox = False
				lvw.cansort = False
				lvw.pagesize = 500
				lvw.colresize = true
				If field.parentgroup.bill.FinanDBModel = True Then lvw.FinanDBModel = True
				If field.parentgroup.bill.edit=False Then
					lvw.edit =False
				else
					lvw.edit =True
				end if
				lvw.id = "bllst_" & field.dbname
				If app.existsProc("bill_onListCreate") And field.dbname<>"@bill.approve.list" Then
					Call bill_onListCreate(field, lvw)
				ElseIf Len(field.parentgroup.bill.approve)>0 Then
					Call bill_onApproveCreate(field, lvw)
				end if
				If lvw.jsonEditModel Then
					lvw.PageBar = True
					if lvw.pagesize = 500 Then lvw.pagesize = 10
				end if
				Response.write "<div id='bll_lvwbg_" & field.dbname & "'>"
				Response.write lvw.HTML
				If Len(field.source)>0 Then
					Response.write "<div style='width:100%;text-align:right;height:27px'><a href='javascript:void(0)' style='color:red' onclick=""javascript:window.open('"& app.virpath & field.source &"','newwin','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150')"">>>>"& field.value &"</a></div>"
				ElseIf field.ImageVMLGraphic Then
					Response.write "<div style='width:100%;padding-top:3px;' align='center' id='vml_"&field.dbname&"'></div>"
'ElseIf field.ImageVMLGraphic Then
				end if
				Response.write "</div>"
				Set lvw =  nothing
			else
				Response.write "<div style='padding:5px'>虽然加载了列表（listview）字段，但是您还未定义列表的处理过程：<br><span style='color:blue'>sub</span> bill_onListCreate(<span style='color:blue'>byref</span> field, <span style='color:blue'>byref</span> lvw)<br>'code....<br><span style='color:blue'>end sub</span></div>"
			end if
		end sub
		Private Sub Clisttree(ByVal field)
			If app.existsProc("bill_onTreeCreate") Then
				Dim tvw : Set tvw = New treeview
				tvw.id = "bill_tree_" & field.dbname
				If app.existsProc("bill_onTreeCreate") Then Call bill_onTreeCreate(field, tvw)
				If tvw.headers.count = 0 Then
					Response.write "<div style='padding:5px'>虽然加载了列表（listtree）字段，但是您还未加载树形列表的headers：<br> tvw.headers.add(<span style='color:blue'>byval</span> title, <span style='color:blue'>byval</span> dbname)</div>"
					Exit Sub
				end if
				Dim lvw : Set lvw = tvw.createListView
				If field.parentgroup.bill.FinanDBModel = True Then lvw.FinanDBModel = True
				If field.parentgroup.bill.edit Then lvw.edit =True
				lvw.id = "bllst_" & field.dbname
				lvw.border = 0
				lvw.PageButtonAlign = "right"
				lvw.oldPageSizeUI = True
				lvw.PageBar = False
				lvw.addlink = ""
				lvw.checkbox = False
				lvw.cansort = False
				lvw.pagesize = tvw.pagesize
				lvw.colresize = True
				lvw.edit =False
				If app.existsProc("bill_onListCreate") Then Call bill_onListCreate(field, lvw)
				If lvw.jsonEditModel and lvw.pagesize = 500 Then lvw.pagesize = 10
				Response.write "<div id='bll_lvwbg_" & field.dbname & "'>" & vbcrlf
				Response.write lvw.HTML
				Response.write "</div>"
				Set lvw = Nothing
				Set tvw = Nothing
			else
				Response.write "<div style='padding:5px'>虽然加载了列表（listtree）字段，但是您还未定义树形列表的处理过程：<br><span style='color:blue'>sub</span> bill_onTreeCreate(<span style='color:blue'>byref</span> field, <span style='color:blue'>byref</span> tvw)<br>'code....<br><span style='color:blue'>end sub</span></div>"
			end if
		end sub
		Private Sub ShowNotNullUI(ByVal field)
			If field.notnull And field.edit=true Then Response.write " <input class='notnull' title='必填' type='button' value='*'>"
		end sub
		Private Sub AddCssItem(Byref cssText, ByVal item)
			If cssText = "" Then
				cssText = "style=""" & item & """"
			else
				cssText = Left(cssText, Len(cssText)-1) & ";" & item & """"
				'cssText = "style=""" & item & """"
			end if
		end sub
		Public function showBillButtons(ByVal control, ByVal pos)
			Dim i , buttons, btn, rhtml
			pos = LCase(pos)
			Set buttons = control.buttons
			For i = 0 To buttons.count-1
'Set buttons = control.buttons
				Set btn = buttons(i)
				If pos = "top" then
					If btn.TopVisible Then
						rhtml = rhtml & "<input onmousedown='if(bill.onbtnMouseDown){bill.onbtnMouseDown(this)}' onclick='return " & btn.onclick & "' type='button' class='zb-button' value='" & btn.title & "'>"
'If btn.TopVisible Then
					end if
				ElseIf pos = "bottom" then
					If btn.BottomVisible Then
						rhtml = rhtml & "<input onmousedown='if(bill.onbtnMouseDown){bill.onbtnMouseDown(this)}' onclick='return " & btn.onclick & "' type='button' class='zb-button' value='" & btn.title & "'>"
'If btn.BottomVisible Then
					end if
				end if
			next
			showBillButtons = rhtml
		end function
		Public Sub showFieldsHtml(ByRef gp, ByRef vcss)
			Dim i,  ii, iii, Pos()
			Dim PosCount : PosCount = 0
			Dim maxspan : maxspan = gp.bill.maxspan
			Dim clspan, valign , tdcss
			i = 0
			While  i < gp.fields.count
				Call LayoutAdd(pos, poscount, maxspan , gp.fields(i), gp, i)
			wend
			Dim field , maxy
			maxy = 0
			For i = 0 To PosCount - 1
'maxy = 0
				If maxy < Pos(i).y2 Then
					maxy = Pos(i).y2
				end if
			next
			For i = 1 To maxy
				Response.write "<tr class='s_f_d" & Abs(gp.isfold) & "' dbname='" & gp.dbname & "' " & vcss & ">"
				For ii = 1 To maxspan
					For iii = 0 To PosCount - 1
'For ii = 1 To maxspan
						If Pos(iii).x1 = ii And Pos(iii).y1 = i Then
							Set field = Pos(iii).field
							clspan = Pos(iii).x2 - Pos(iii).x1 + 1
'Set field = Pos(iii).field
							valign = ""
							If field.valign <> "" Then valign = " valign='" & field.valign & "' "
							tdcss = ""
							If field.hidden = True Then tdcss = " style='display:none' "
							If Len(field.title) > 0 Then
								If field.title = "&nbsp;" Then
									Response.write "<td class='fcell sub-title' "& tdcss &" id='" & field.dbname & "_tit' rowspan=" & field.rowspan & ">&nbsp;</td>"
'If field.title = "&nbsp;" Then
								else
									Response.write "<td class='fcell sub-title' "& tdcss &" id='" & field.dbname & "_tit' rowspan=" & field.rowspan & ">" & field.title & "：</td>"
'If field.title = "&nbsp;" Then
								end if
								Response.write "<td class='fcell' "& tdcss &" validcode='" & app.HtmlConvert(field.ValidCode & "") & "' validtext='" & app.HtmlConvert(field.ValidText & "") & "' ei='" & Abs(field.edit) & "' max=" & Abs(field.maxlimit) & " nu='" & Abs(field.notnull) & "' ui='" & field.uitype & "' id='" & field.dbname &"_cel' colspan='" & (clspan*2-1) & "' rowspan=" & field.rowspan & valign & ">"
'If field.title = "&nbsp;" Then
							else
								Response.write "<td class='fcell' "& tdcss &"  validcode='" & app.HtmlConvert(field.ValidCode & "") & "' validtext='" & app.HtmlConvert(field.ValidText & "") & "' ei='" & Abs(field.edit) & "' max=" & Abs(field.maxlimit) & " nu='" & Abs(field.notnull) & "' ui='" & field.uitype & "' id='" & field.dbname & "_cel' colspan='" & (clspan*2) & "' rowspan=" & field.rowspan & valign & ">"
							end if
							If field.ImageAutoSize Then Response.write "<div class='ewebeditorImg'>"
							Call me.CreateFieldsHtml(field)
							If field.ImageAutoSize Then Response.write "</div>"
							Response.write "</td>"
						end if
					next
					If ExistsFreePos(i, ii, pos, posCount) Then
						If ExistsFreePos(i, ii-1, pos, posCount) Then
'If ExistsFreePos(i, ii, pos, posCount) Then
							Response.write "<td class='fcell' style='border:0px'>&nbsp;</td><td class='fcell' style='border:0px'>&nbsp;</td>"
						else
							Response.write "<td class='fcell'>&nbsp;</td><td class='fcell'>&nbsp;</td>"
						end if
					end if
				next
				Response.write "</tr>"
			next
			For i = 0 To PosCount - 1
				Response.write "</tr>"
				Set  Pos(i).field =  Nothing
				Set  Pos(i) = Nothing
			next
			Erase Pos
		end sub
		Private Sub LayoutAdd(ByRef pos, ByRef posCount, ByVal maxspan, ByVal field, ByVal gp, ByRef moveindex)
			Dim ri, ci,  i, ii, fr, x, x2
			moveindex = moveindex + 1
'Dim ri, ci,  i, ii, fr, x, x2
			If field.uitype = "hidden" Then Exit Sub
			ri = 1 : ci = 1
			fr = ExistsFreePos(1, 1, pos, posCount)
			While fr = false
				ci = ci + 1
'While fr = false
				If ci > maxspan Then ci = 1 : ri = ri + 1
'While fr = false
				fr = ExistsFreePos(ri, ci,  pos, posCount)
			wend
			x = ci + field.colspan - 1
			fr = ExistsFreePos(ri, ci,  pos, posCount)
			If field.inline = False Then
				x2 = ci
				For i = ci+1 To app.iif(x > maxspan, maxspan, x)
'x2 = ci
					If Not ExistsFreePos(ri, i, pos, posCount) Then  Exit For
                        x2 = i
				next
				x2 = x2 - ci
'x2 = i
				If x2 < field.colspan-1 Then
'x2 = i
					For i =  0 To x2
						Call gp.fields.insert ( moveindex-1, "", "@f_sys_nullspc_" & moveindex & "_" & i, "text", "varchar", true, false, false,  false)
'For i =  0 To x2
					next
					field.title = "!sys_h_s" & Chr(1) &  field.title
					moveindex = moveindex - 1
'field.title = "!sys_h_s" & Chr(1) &  field.title
					Exit sub
				end if
			end if
			If  InStr(field.title,"!sys_h_s" & Chr(1))=1 Then
				field.title = Replace(field.title, "!sys_h_s" & Chr(1), "")
			end if
			ReDim Preserve pos(posCount)
			Set pos(posCount) = New BillUiPosClass
			pos(posCount).x1 = ci
			pos(posCount).y1 = ri
			pos(posCount).y2 = ri + field.rowspan - 1
'pos(posCount).y1 = ri
			x2 = ci
			For i = ci+1 To app.iif(x > maxspan, maxspan, x)
				x2 = ci
				If Not ExistsFreePos(ri, i, pos, posCount) Then
					Exit For
				else
					x2 = i
				end if
			next
			pos(posCount).x2 = x2
			Set pos(posCount).field = field
			posCount = posCount + 1
'Set pos(posCount).field = field
		end sub
		Private Function ExistsFreePos(ByVal rindex, ByVal cindex,  ByRef pos, ByVal posCount)
			Dim i , p
			For i = 0 To posCount - 1
'Dim i , p
				Set p = pos(i)
				If p.x1 <= cindex And cindex <= p.x2 And  p.y1 <= rindex And rindex <= p.y2 Then
					ExistsFreePos = false
					Exit function
				end if
			next
			ExistsFreePos = true
		end function
		Private Function GetPos(ByVal rindex, ByVal cindex, ByVal f, ByRef pos, ByVal posCount)
			Dim i , p
			For i = 0 To posCount - 1
'Dim i , p
				Set p = pos(i)
				If p.x1 <= cindex And cindex <= p.x2 And  p.y1 <= rindex And rindex <= p.y2 Then
					Set GetPos = New BillUiPosClass
					Exit function
				end if
			next
			Set p = New BillUiPosClass
		end function
	End Class
	Class BillUiPosClass
		Public x1, y1 , x2 , y2, field
	End Class
	Class BillMobileRefreshClass
		Dim codes, codesL
		Public Function GetRefreshCode
			GetRefreshCode = Join(codes,"|||")
		end function
		Public Sub DeleteGroups(ByVal groups)
			addCode "deleteGroups::" & GetItemsDBName(groups)
		end sub
		Public Sub insertGroupsBefore(ByVal newGroups,  ByVal beforeGroup)
			addCode "insertGroupsBefore::" & GetItemsDBName(newGroups) & "::" & GetItemsDBName(beforeGroup)
		end sub
		Public Sub deleteFields(ByVal fields)
			addCode "deleteFields::" & GetItemsDBName(fields)
		end sub
		Public Sub insertFieldsBefore(gpname, newfields, beforefield)
			addCode "insertFieldsBefore::" & GetItemsDBName(gpname) &_
			"::" & GetItemsDBName(newfields) &_
			"::" & GetItemsDBName(beforefield)
		end sub
		Public Sub UpdateFields(newfields)
			addCode "updateFields::" & GetItemsDBName(newfields)
		end sub
		Private Function GetItemsDBName(items)
			Dim i, dbs
			If isobject(items) Then
				If InStr(typename(items),"Collection")>0 Then
					For i = 0 To items.count - 1
'If InStr(typename(items),"Collection")>0 Then
						If i > 0 Then dbs = dbs & ";"
						dbs = dbs & items(i).dbname
					next
				else
					dbs = items.dbname
				end if
			else
				dbs =  items
			end if
			GetItemsDBName = dbs
		end function
		Private Sub addCode(ByVal codev)
			ReDim Preserve codes(codesL)
			codes(codesL) = codev
			codesL = codesL + 1
'codes(codesL) = codev
		end sub
		Public Sub class_initialize
			codesL = 0
			ReDim codes(0)
		end sub
	End Class
	Sub LoadMobileBill(ByVal bill)
		Dim mbill : Set mbill = bill.mobBill
		If Len(bill.sql) > 0 Then Call bill.LoadData
		If cn.execute("select id from setjm where ord=802 and intro='1'").eof = False Then
			app.Log.remark = bill.title
		end if
		Dim rs1,i,url, svs , gc , gp , mgroup , ii ,mfield , iii , options , textStr , field , muitype , mtype , murl , buttons , btn , v
		url = request.servervariables("script_name")
		url = Right(url , Len(url)-1)
'url = request.servervariables("script_name")
		svs =  Replace(replace(url,"/",""), ".asp", "_bill")
		If CLng("0" & bill.neword)> 0 Then
			mbill.value =  bill.neword
		else
			mbill.value =  bill.id
		end if
		mbill.id = svs
		mbill.caption = bill.title
		mbill.uitype = bill.uitype
		Dim arrurl : arrurl = Split("/"& LCase(url),"/mobilephone/")
		url = "mobilephone/" & arrurl(ubound(arrurl))
		If bill.cansave =True Then bill.addTool "保存","save","_url",url &"?__msgid=__sys_dosave&ord="& bill.id , "post" , "_none"
		If bill.needSetApprove = True Then bill.addTool "提交审批","approve","_url","mobilephone/systemmanage/setapprove.asp?approve="& bill.approve &"&ord="& bill.id , "get" , "_none"
		If bill.canApprove =True Then bill.addTool "审批","approve","_url","mobilephone/systemmanage/approve.asp?dtype="& bill.approve &"&ord="& bill.id , "get" , "_none"
		If bill.canupdate =True Then bill.addTool "修改","update","_url",url &"?ord="& bill.id , "get" , "_none"
		If bill.candel =True Then bill.addTool ("删除","delete","_url",url &"?__msgid=delete&ord="& bill.id , "get" , "_none").remark = "确认删除？"
		If bill.printMode>0 And sdk.power.existsModel(207103) Then bill.addTool ("打印","print","_url","../SYSN/view/comm/AppTemplatePrint.ashx?sort="& bill.printMode &"&ord="& bill.id , "get" , "_none").remark = "确认打印？"
		gc = bill.groups.count
		For i = 0 To gc-1
'gc = bill.groups.count
			Set gp = bill.groups(i)
			Set mgroup= mbill.addGroup(gp.dbname ,gp.title)
			For ii = 0 To gp.fields.count-1
'Set mgroup= mbill.addGroup(gp.dbname ,gp.title)
				options = ""
				Set mfield = gp.fields(ii)
				If isnull( mfield.notnull ) Then  mfield.notnull = false
				If InStr(mfield.dbname,"@")>0 Then
					textStr = mfield.defvalue&""
					v = mfield.defvalue&""
				else
					textStr = app.iif(mfield.parentgroup.bill.isAddmodel, mfield.defvalue & "", mfield.value&"")
					v = app.iif(mfield.parentgroup.bill.isAddmodel, mfield.defvalue & "", mfield.value&"")
				end if
				Select Case mfield.dbtype
				Case "varchar" : mtype = "string"
				Case "float" : mtype = "number"
				Case "money" :
				If Len(textStr & "") > 0 And isnumeric(textStr & "") = True And mfield.edit=false Then textStr = FormatNumber(textStr, Info.moneyNumber, -1)
'Case "money" :
				If Len(v & "") > 0 And isnumeric(v & "") = True And mfield.edit=False And bill.edit=false Then v = FormatNumber(v, Info.moneyNumber, -1)
'Case "money" :
				mtype = mfield.dbtype
				Case Else
				mtype = mfield.dbtype
				End Select
				murl = ""
				Select Case mfield.uitype
				Case "editor" :
				muitype = "webbox"
				If mfield.edit = False And Len(textStr)=0 Then
					textStr = mfield.defvalue
				else
					If mfield.edit = True Then murl = "mobilephone/upload.asp?__urlencode=1&userid="& app.mobile.post.session
				end if
				textStr = replace(textStr & "", "WebSource.ashx?","WebSource.ashx?MobTaken=" & app.mobile.post.session & "&MobCookie=" & request.Cookies("ZBERPSystemSessionID") & "&")
				Case "file" :
				muitype = "file"
				If mfield.edit = False And Len(textStr)=0 Then
					textStr = mfield.defvalue
				else
					If mfield.edit = True Then murl = "mobilephone/uploadfile.asp?__urlencode=1&userid="& app.mobile.post.session
				end if
				Case "gate":
				muitype = "source"
				If mfield.edit = True Then murl = mfield.source
				If Len(v&"")=0 Then v = 0
				textStr = ""
				Set rs1 = cn.execute("select name from gate where ord in (" & v & ")")
				While rs1.eof = False
					textStr = textStr & rs1.fields(0).value & " "
					rs1.movenext
				wend
				rs1.close
				Dim w1: w1 = ""
				Set rs1 = cn.execute("select distinct ord from gate1 where ord in (select sorce from gate where ord in (" & v & "))")
				While rs1.eof= False
					If Len(w1)>0 Then w1 = w1 &","
					w1 = w1 & rs1("ord").value
					rs1.movenext
				wend
				rs1.close
				If Len(w1)=0 Then w1 = "0"
				Dim w2 : w2 = ""
				Set rs1 = cn.execute("select distinct ord from gate2 where ord in (select sorce2 from gate where ord in (" & v & "))")
				While rs1.eof= False
					If Len(w2)>0 Then w2 = w2 &","
					w2 = w2 & rs1("ord").value
					rs1.movenext
				wend
				rs1.close
				If Len(w2)=0 Then w2 = "0"
				If Len(v)>0 Then v = w1 &"|" & w2 & "|" & v
				Case "select" ,"radio" ,"radiolink","radiosearch","selectlink"
				muitype = mfield.uitype
				Call bill.GetSourceData(options, mfield)
				If InStr(mfield.dbname,"@")>0 And mfield.edit = False Then
					textStr = mfield.defvalue
				else
					textStr = ""
					If isarray(options) Then
						For iii = 0 To ubound(options)
							If options(iii)(1) & "" = v & "" Then textStr = options(iii)(0)
						next
					end if
				end if
				Case Else
				muitype = mfield.uitype
				If InStr(1,mfield.source, "autocomplete:",1) = 1 Then
					If muitype<>"radiobox" And muitype<>"selectbox" Then
						muitype = "source"
						If Len(v&"")=0 Then v = 0
					else
						v = v&""
					end if
					If App.ExistsProc("App_setAutoComplete") Then
						Call App_setAutoComplete(mfield ,Replace(mfield.source,"autocomplete:","" ,1,1) ,v, murl , textStr)
					end if
				else
					If mfield.edit = False And Len(textStr)=0 Then textStr = mfield.defvalue
					If Len(mfield.source)>0 Then
						If InStr(mfield.source,"sql:") = 0 Then murl = mfield.source
					end if
				end if
				End Select
				Dim canAddField : canAddField = True
				Dim source : Set source = server.createobject("ZSMLLibrary.sourceClass")
				Select Case mfield.uitype
				Case "select","radio","radiobox","radiolink","radiosearch","selectlink","selectbox","checkbox":
				If mfield.parentgroup.bill.edit=True  Then
					If mfield.uitype = "radiobox" Or mfield.uitype = "selectbox" Or mfield.uitype = "checkbox"  Then
						Call bill.GetSourceData(options, mfield)
					end if
					source.createType "options"
					If isarray(options) Then
						For iii = 0 To ubound(options)
							source.addoption options(iii)(0), options(iii)(1)
							If v & "" = options(iii)(1) & "" Then
								textStr  = options(iii)(0)
							end if
						next
					end if
				end if
				Case "treebox" :
				If app.existsProc("bill_onTreeCreate") Then
					If Len(v&"")=0 Then v = 0
					Dim tree : Set tree = source.createType("trees")
					source.uitype =app.iif(InStr(mfield.ui,"check")>0 , "check" , "radio")
					Call bill_onTreeCreate(mfield, tree , v, textStr)
					If mfield.edit = True Then
						murl = mfield.source
					else
						murl = ""
					end if
					Set tree = Nothing
					If mfield.parentgroup.bill.edit=False Then Set source= Nothing
				end if
				Case "listview" :
				Dim lvw : Set lvw = New listview
				If app.existsProc("bill_onListCreate") And mfield.dbname<>"@bill.approve.list" Then
					Call bill_onListCreate(mfield, lvw)
				ElseIf Len(bill.approve)>0 Then
					Call bill_onApproveCreate(mfield, lvw)
				end if
				If mfield.parentgroup.bill.edit=False Then
					lvw.edit =False
				else
					lvw.edit =True
				end if
				Set source = lvw.createsource()
				Set lvw =  Nothing
				If mfield.edit = True Then murl = mfield.source
				Case "hidden" :
				If InStr(mfield.source,"sql:") > 0 Then
					Call bill.GetSourceData(options, mfield)
					source.createType "options"
					If isarray(options) Then
						For iii = 0 To ubound(options)
							source.addoption options(iii)(0), options(iii)(1)
						next
					end if
				end if
				End Select
				If canAddField = True Then
					Set field = mgroup.addField(mfield.dbname & "", mfield.title&"", mtype & "" , muitype & "", textStr & "", app.iif(bill.edit ,v,""), 1 , mfield.ui & "",  mfield.notnull & "" )
					field.OnlyRead = mfield.onlyRead
					field.minl = mfield.minlimit
					field.maxl = mfield.maxlimit
					field.edit = mfield.edit
					field.minv = mfield.minValue
					field.maxv = mfield.maxValue
					field.remark = mfield.remark
					If mfield.edit = False And Len(murl)>0 Then field.action= "_url"
					If mfield.callback <> "" Then  field.action= "sys.bill.action.callback." & mfield.callback
					If Len(murl)>0 Then field.url = murl
					If mfield.edit=true Or mfield.uitype="listview" Then field.source = source
				end if
			next
			Set buttons = gp.buttons
			For ii = 0 To buttons.count-1
'Set buttons = gp.buttons
				Set btn = buttons(ii)
				Set field = mgroup.addField(btn.dbname, "", "" , "button", btn.title &"", btn.title &"", 0 , app.iif( InStr(btn.onclick,"{@")>0,"bill.action.seturl","bill.button.link"),  false)
				field.action = "_url"
				field.url = btn.onclick
			next
			If Len(gp.bar)>0 Then
				mgroup.bar(true).url = gp.bar
				If bill.edit = True Then
					With mgroup.bar
					.caption = "编辑"
					.type_ = "edit"
					End With
				end if
			end if
			mgroup.visible = gp.visible
		next
	end sub
	Sub Page_load
		Dim b_title , b_title_display, bi, bn
		b_title_display = (Len(request.querystring("title_display")&"")=0)
		Dim bill : Set bill = New BillPage
		If app.ismobile Then  Set bill.mobBill = app.mobile.document.body.CreateModel("bill","init")
		Dim billUI : Set billUI = New BillUIClass
		Dim vPath  : vPath = app.virPath
		cn.cursorlocation = 3
		If app.ismobile And app.ApiHelpModel Then
			cn.BeginTrans
		end if
		app.addCssPath vpath & "skin/" & Info.skin & "/css/bill.css"
		Call Bill_OnInit(bill, 0)
		If bill.id>0 And Len(bill.sql)>0 Then
			If bill.exists=False Then
				bill.showSaveResult("抱歉，您访问的单据已被删除！")
				Exit Sub
			end if
		end if
		If len(bill.extra)>0 Then Call bill_onGroupCreate_Extra(bill)
		If len(bill.approve)>0 Then Call bill_onGroupCreate_Approve(bill)
		If app.ismobile Then
			Call LoadMobileBill(bill)
			If app.ApiHelpModel Then
				Select Case LCase(request.querystring("apihelptype") & "")
				Case "save" :
				bill.CreateApiHelp "save"
				call ShowApihelp(bill.title, "MessageClass", "__sys_dosave")
				Case "new" :
				call ShowApihelp(bill.title, "BillClass", "")
				Case "get" :
				call ShowApihelp(bill.title, "BillClass", "")
				Case Else
				call ShowApihelp(bill.title, "BillClass", "")
				End Select
				conn.RollbackTrans
			end if
			Set bill = Nothing
			Exit Sub
		end if
		If bill.loadEasyUI Then
			app.addCssPath vpath & "inc/themes/default/easyui.css"
			app.addCssPath vpath & "inc/themes/icon.css"
			app.addScriptPath vpath & "inc/jquery.easyui.min.js"
		end if
		app.addScriptPath vpath & "skin/" & Info.skin & "/js/billpage.js"
		app.addScriptPath vpath & "skin/" & Info.skin & "/js/json2.js"
		If bill.loadJs Then Call app.addDefaultScript() '加载本文件关联JS ="../skin/default/js/*.js
		If bill.loadVml Then
			app.addScriptPath vpath & "skin/" & Info.skin & "/js/VmlGraphics.js"
			app.addScriptPath vpath & "inc/echarts.min.js"
		end if
		If bill.canPrintPage Then bill.Buttons.add "打印", "printpage", "window.print()", true, False
		For bi = 0 To bill.buttons.count-1
'If bill.canPrintPage Then bill.Buttons.add "打印", "printpage", "window.print()", true, False
			Set bn = bill.buttons.item(bi)
			If bn.title = "打印" Then
				If bn.topvisible Or bn.bottomvisible Then
					app.Log.printlog = True
					Exit for
				end if
			end if
		next
		If bill.loadVml Then
			Response.write Replace(app.defheadhtml(app.getvirpath, ""),"<html>","<html xmlns:v=""urn:schemas-microsoft-com:vml"" xmlns:o=""urn:schemas-microsoft-com:office:office""><meta name=""vs_targetSchema"" content=""http://schemas.microsoft.com/intellisense/ie5""/>")
'If bill.loadVml Then
			Response.write "" & vbcrlf & "             <style>" & vbcrlf & "                 v\:* { Behavior: url(#default#VML) } " & vbcrlf & "                   o\:* { behavior: url(#default#VML) }" & vbcrlf & "            </style>" & vbcrlf & "                "
		else
			Response.write app.defheadhtml(app.getvirpath, "")
		end if
		b_title = bill.title
		If Len(b_title) = 0 Then b_title = "<i>未设置标题...</i>"
		app.TryExecuteProc "Bill_OnPageInit"
		Response.write "<body onload='__bill__onload()' "
		If Not bill.cancopy Then
			Response.write " oncontextmenu='return false' onselectstart='return false' ondragstart='return false' onbeforecopy='return false' oncopy=document.selection.empty() "
		end if
		If bill.canscan Then
			Response.write " onclick='bill.TexTxmFocus(event);' "
		end if
		Response.write ">"
		If b_title_display Then
			app.Log.remark = b_title
			Response.write "" & vbcrlf & "             <div id='comm_itembarbg'>" & vbcrlf & "               <div id='comm_itembarICO'></div><div id='comm_itembarText'><span>"
			Response.write b_title
			Response.write "</span></div>" & vbcrlf & "                <div id='comm_itembarspc'></div>" & vbcrlf & "                <div style='float:left;padding-top:8px'>&nbsp;</div>" & vbcrlf & "                    <div id='comm_itembarright'>"
			'Response.write b_title
			Response.write bill.headerhtml
			Response.write "" & vbcrlf & "                     &nbsp;&nbsp;"
			If bill.canscan Then
				Response.write "<input name=""txm"" autocomplete=""off"" type=""text"" style=""width:0px; height:0px; border:0 0 0 0;margin: 0px;padding: 0px;"" onkeypress=""if(event.keyCode==13){bill.txmAjaxSubmit(this);this.value='';}"" onFocus=""this.value=''"" size=""10"">"
			end if
			Response.write "" & vbcrlf & "                     </div>" & vbcrlf & "          </div>" & vbcrlf & "          "
		end if
		If bill.Vborder = 0 then
			Response.write "<style>#editbody .fcell {border-left-width:0px;border-right-width:0px;border-top:0px!important;}</style>"
'If bill.Vborder = 0 then
		end if
		Response.write "" & vbcrlf & "     <form method='post' target='callbackfrm' style='display:inline' id='mainform'><input type='hidden' name='sys_ad_model' id='sys_ad_model'>" & vbcrlf & "       <table style='width:100%;_width:99%;"
		If bill.groups.count >0 Then
			If bill.groups(0).showbar = False Then
				Response.write ""
			end if
		end if
		Response.write "' border=0 class='edit-body detailTable' id='editbody' onkeyup='bill.editBodyKeyUp()'>" & vbcrlf & "       "
		Response.write ""
		Dim findex, cellIndex, rowindex, i, ii, iii, gp
		Dim field, gc, vcss, hiddenbody ,tcss, bill_maxspan, hasImageAutoSize
		Dim rowspans
		cellIndex = 0
		rowindex = 0
		findex = 0
		hasImageAutoSize = false
		bill_maxspan = bill.maxspan
		For i = 1 To bill_maxspan
			Response.write "<col style='width:"  & bill.ColWidth((i-1)*2) & "%'><col style='width:"  & bill.ColWidth((i-1)*2+1)  & "%'>"
'For i = 1 To bill_maxspan
		next
		If Len(bill.sql) > 0 Then Call bill.LoadData
		gc = bill.groups.count
		For i = 0 To gc-1
'gc = bill.groups.count
			cellindex = 0
			rowindex = 0
			ReDim rowspans(bill_maxspan)
			For ii = 0 To bill_maxspan
				rowspans(ii) = 0
			next
			Set gp = bill.groups(i)
			vcss = app.iif(gp.visible=True, "", "style='display:none'")
			tcss = ""
			If vcss="" Then tcss =  app.iif(gp.showbar=true , "", "style='display:none'")
			Response.write "<tr class='sub-thead' dbname='" & gp.dbname & "' " & vcss & "  " & tcss & "><td class='fcell' style='padding-right:10px' colspan=" & bill.maxspan*2 & ">"
'If vcss="" Then tcss =  app.iif(gp.showbar=true , "", "style='display:none'")
			If gc > 1 Or bill.ahonegp = False Then
				Response.write "<div class='group-title'>" & gp.title & "</div>"
'If gc > 1 Or bill.ahonegp = False Then
				If gp.foldable Then
					Response.write "<div class='group-fold'><img class='resetElementHidden' height='15' onclick='bill.foldGroup(this)' title='" & app.Iif(gp.Isfold,"点击展开","点击折叠") & "' src='" & app.virpath & "images/r_down.png'><img height='15' class='resetElementShow' style='display:none;vertical-align:middle;' onclick='bill.foldGroup(this)' title='" & app.Iif(gp.Isfold,"点击展开","点击折叠") & "' src='" & app.virpath & "skin/default/images/MoZihometop/content/r_down.png'></div>"
				end if
			else
				Response.write "&nbsp;"
			end if
			Response.write gp.barHTML
			If i = 0 Then
				Response.write billUI.showBillButtons(bill, "top")
			end if
			Response.write billUI.showBillButtons(gp, "top")
			Response.write "</td></tr>"
			Call billUI.showFieldsHtml(gp, vcss)
			For ii = 0 To gp.fields.count-1
'Call billUI.showFieldsHtml(gp, vcss)
				Set field = gp.fields(ii)
				If field.uiType ="hidden" Then
					Dim v : v = app.iif(bill.isAddmodel Or Not field.dbbind , field.defvalue, field.value)
					hiddenbody = hiddenbody & "<input type='hidden' name='" & field.dbname & "' id='" & field.dbname & "_0' value=""" & app.htmlconvert(v) & """>"
				else
					hasImageAutoSize = hasImageAutoSize or field.ImageAutoSize
				end if
			next
		next
		Dim bhtml : bhtml = billUI.showBillButtons(bill, "bottom")
		If Len(bhtml) > 0 then
			Response.write "<tr class='btns-bar' dbname='__funbar'><td colspan=" & bill.maxspan*2 & " class='fcell'><div style='position:relative;'>"
'If Len(bhtml) > 0 then
			Response.write bhtml
			Response.write "</div></td></tr>"
		end if
		Response.write "" & vbcrlf & "     </table>" & vbcrlf & "        <input type='hidden' name='__msgid' id='eventName'>" & vbcrlf & "     <input type='hidden' name='ord' id='__ord' value='"
		Response.write bill.id
		Response.write "'>" & vbcrlf & "   <input type='hidden' name='evtbtnname' id='evtbtnname' value=''>" & vbcrlf & "        "
		Response.write hiddenbody
		Response.write "" & vbcrlf & "     <iframe frameborder=0 name='callbackfrm' style='"
		If bill.debug Then
			Response.write "width:99%;height:120px;border:1px solid #aaa;"
		else
			Response.write "position:absolute;left:-100px;height:1px;width:1px;"
			'Response.write "width:99%;height:120px;border:1px solid #aaa;"
		end if
		Response.write "'></iframe>" & vbcrlf & "  </form>" & vbcrlf & " <div class='bottomdiv' style='border-top:0px'>&nbsp;</div>" & vbcrlf & "      "
		'Response.write "width:99%;height:120px;border:1px solid #aaa;"
		If app.existsProc("bill_onBottomSub") Then Call bill_onBottomSub(bill)
		If hasImageAutoSize then
			Response.write "" & vbcrlf & "     <script>" & vbcrlf & "                window.__ShowImgBigToSmall = true" & vbcrlf & "       </script>" & vbcrlf & "       "
		end if
		Response.write "     " & vbcrlf & "        </body>" & vbcrlf & "" & vbcrlf & " </html>" & vbcrlf & " "
		Set billUI = Nothing
		Set bill = Nothing
	end sub
	Sub App_sysfieldcallback
		Dim cbevent :  cbevent =  app.mobile("__billbackevent")
		If InStr(cbevent, " ")>0 Or InStr(cbevent, "(")>0 Or InStr(cbevent, ".")>0 or InStr(cbevent, vbtab)>0 Or InStr(cbevent, """")>0 Or InStr(cbevent, "=")>0 Then Exit Sub
		cn.cursorlocation = 3
		If app.ApiHelpModel Then  cn.BeginTrans
		Dim bill : Set bill = New BillPage
		Dim billid : billid =  app.mobile("__billid")
		bill.edit = true
		bill.setBillId billid
		Set bill.mobBill = app.mobile.document.body.CreateModel("bill","init")
		Set bill.MobileRefresh = New BillMobileRefreshClass
		If app.existsProc("App_" & cbevent) Then
			execute "call App_" & cbevent & "(bill)"
		end if
		Dim cmd : cmd = bill.MobileRefresh.GetRefreshCode
		If Len(cmd) > 0 Then
			app.mobile.header.message = "BillRefreshCmd:"  & cmd
		end if
		Call LoadMobileBill(bill)
		If app.ApiHelpModel Then call ShowApihelp("字段刷新", "BillClass", "")
	end sub
	Sub App___sys_dosave
		Dim bill, errnum, errtext
		Dim result : result = False
		cn.cursorlocation = 3
		Set bill = New BillPage
		Call Bill_OnInit(bill, 1)
		app.Log.remark = bill.title & ".保存"
		If Len(bill.sql) > 0 Then
			If bill.LoadData() = False Then Exit sub
		end if
		If bill.LoadPostData() = False Then Exit sub
		If Bill.DoDataValids() = False Then Exit Sub
		If bill.FinanDBModel = True Then Call app.setAccDataBase()
		cn.BeginTrans
		If App.ExistsProc("Bill_OnSave") Then result = Bill_OnSave(Bill)
		If result = True And len(bill.extra)>0 Then result = bill_onSave_Extra(bill)
		If result = True And Len(bill.approve&"")>0 Then
			If App.ExistsProc("Bill_OnSaveNeedApprove") Then
				If Bill_OnSaveNeedApprove(bill) Then result = bill_onSave_Approve(bill)
			end if
		end if
		If result = True Then
			cn.CommitTrans
			If App.ExistsProc("Bill_OnSaveSuccess") Then Call Bill_OnSaveSuccess(Bill)
		else
			cn.RollbackTrans
		end if
		If bill.FinanDBModel = True Then Call app.setErpDataBase()
	end sub
	Sub App_billpage_lvw_callback
		Dim l , backcode , cmd
		cmd = Replace(Replace(Replace(Replace(request("cmd") & "", "(", ""), ":", ""), " ", ""), "@", "")
		backcode = app.base64.decode(request.form("backdata"))
		Set l = New listview
		l.border = 0
		l.PageButtonAlign = "right"
		l.oldPageSizeUI = True
		l.PageBar = False
		l.addlink = ""
		l.checkbox = False
		l.cansort = False
		l.pagesize = 500
		l.id = "bllst_" & request("fname")
		If app.existsProc("bill_listview_On" & cmd) Then
			execute backcode & vbcrlf &  "call bill_listview_On" & cmd & "(app.getint(""billid""), l)"
		end if
		Response.write l.HTML
		Set l =  nothing
	end sub
	Sub App_billpage_lvw_onCreateVML
		Dim sql ,title , index , backdata , cmd  , i  ,urls
		Dim vml : Set vml =New ImageVmlClass
		cmd = Replace(Replace(Replace(Replace(request("cmd") & "", "(", ""), ":", ""), " ", ""), "@", "")
		backdata = app.getText("backdata")
		If Len(backdata)>0 Then
			Dim l,backcode
			backcode = app.base64.decode(backdata)
			Set l = New listview
			execute backcode
			vml.sql = l.sql
			ReDim urls(0)
			For i = 1 To l.headers.count
				ReDim preserve urls(i-1)
'For i = 1 To l.headers.count
				urls(i-1)=l.headers(i).url
'For i = 1 To l.headers.count
			next
			vml.urls = urls
			Set l =  nothing
		end if
		If app.existsProc("bill_OnVmlCreate") Then
			Call bill_OnVmlCreate(cmd , vml)
		else
			Response.write "开启了统计图显示数据 请先设置bill_OnVmlCreate过程!"
			Exit Sub
		end if
		call vml.ShowImageDivItem(cn)
	end sub
	Sub App_billpage_images_delete
		Dim id : id = app.getint("id")
		cn.execute("delete from sys_upload_res where id="& id)
	end sub
	Sub App_Sys_onAddAllNodes(ByRef tvw , ByRef rs)
		Dim i
		For i = 0 To rs.fields.count-1
'Dim i
			tvw.headers.add "",rs.fields(i).name
		next
	end sub
	Sub App_sys_onAddAllNode(ByRef rs,ByRef nodesobj, ByRef nd)
		Dim i
		For i = 0 To rs.fields.count-1
'Dim i
			nd(rs.fields(i).name&"")  = rs(i).value
		next
	end sub
	Sub bill_onGroupCreate_Approve(ByRef Bill)
		If bill.edit=True And (bill.isAddmodel= True Or bill.uitype ="bill.approve") Then
			Dim commSP : Set commSP = New CommSPHandle
			Call commSP.initById(bill.id , bill.approve)
			If bill.reBackApprove = True Then commSP.reBack = True
			If Len(commSP.config.swicthField)=0 And Len(commSP.config.moneyField)=0 Then
				Call commSP.loadNextBySdk(false,0)
				Dim i,cates , optionStr
				cates = Split(commSP.nextGates&"","|")
				For i = 0 To ubound(cates)
					If Len(cates(i))>0 Then
						If Len(optionStr)>0 then optionStr = optionStr & ";"
						optionStr = optionStr & Split(cates(i) , "=")(1) & "=" & Split(cates(i) , "=")(0)
					end if
				next
				Bill.fields.add1( "", "@__sp_level_id", "hidden", "int",  true, True, true , False).defvalue = commSP.nextSpId
				If commSP.nextSpId>0 Then
					Bill.fields.addoptions("下级审批人员", "@__sp_cateid","select", "int",  true, true, True ,False,"options:" & optionStr).sourceCanNull = true
				end if
			end if
		end if
		If bill.edit = False Or bill.uitype ="bill.approve" Then
			bill.AddCurrGroup "审批记录","bill.approve.list_"& bill.approve
			With Bill.fields.addListView("", "@bill.approve.list")
			.edit = False
			.ui = "bill.listinfo.hidden.approve"
			End With
		end if
		If app.existsProc("bill_OnloadAfterApprove") Then Call bill_OnloadAfterApprove(Bill)
	end sub
	Sub bill_onApproveCreate(byref field, byref lvw)
		Dim basesql , sp_sort
		sp_sort = field.parentgroup.bill.approve
		Select Case sp_sort
		Case 50
		basesql = "select s.date1,s.sp ,g.name ,s.money1,(case s.jg when 1 then '审批通过' when 3 then '审批退回' else '审批未通过' end) as status,s.intro "&_
		"  from sp_intro s left join gate g on g.ord=s.cateid "&_
		"  left join payout p on s.ord=(case isnull(p.oldid,0) when 0 then p.ord else p.oldid end) "&_
		"  where p.ord="& field.parentgroup.bill.id &" and s.sort1="& sp_sort &" order by s.id "
		Case 73001
		basesql = "select s.date1,s.sp ,g.name ,s.money1,(case s.jg when 0 then '否决' when 2 then '退回' else '通过' end) as status,s.intro "&_
		"  from sp_intro s left join gate g on g.ord=s.cateid where s.ord="& field.parentgroup.bill.id &" and s.sort1="& sp_sort &" order by s.id "
		Case Else
		basesql = "select s.date1,s.sp ,g.name ,s.money1,(case s.jg when 1 then '审批通过' when 3 then '审批退回' else '审批未通过' end) as status,s.intro "&_
		"  from sp_intro s left join gate g on g.ord=s.cateid where s.ord="& field.parentgroup.bill.id &" and s.sort1="& sp_sort &" order by s.id "
		End Select
		lvw.sql = basesql
		lvw.pagesize = 1000
		If app.ismobile Then
			With lvw.layout
			.uitype = "bill.listinfo.hidden.approve"
			.addField "", "", "label","{@sp}","","",""
			.addField "", "", "label","{@name}","","",""
			.addField "", "时间", "label","{@date1}","","",""
			.addField "", "结果", "label","{@status}","","",""
			Select Case sp_sort
			Case 4,6,7:
			.addField "", "金额", "label","{@money1}","","",""
			End Select
			.addField "", "意见", "label","{@intro}","","",""
			End With
			lvw.headers(4).dbtype="money"
		else
			With lvw.headers("date1")
			.title = "审批时间"
			.width = 100
			End With
			With lvw.headers("sp")
			.title = "审批阶段"
			.width = 100
			End With
			With lvw.headers("name")
			.title = "审批人"
			.width = 100
			End With
			Select Case sp_sort
			Case 4,6,7:
			With lvw.headers("money1")
			.title = "审批金额"
			.width = 100
			End With
			Case Else:
			lvw.headers("money1").display = "none"
			End Select
			With lvw.headers("status")
			.title = "审批结果"
			.width = 100
			End with
			With lvw.headers("intro")
			.title = "审批意见"
			.width = 200
			End with
		end if
	end sub
	Sub bill_onGroupCreate_Extra(ByRef Bill)
		Dim rs ,stype, showType ,v, tb , tbname
		Dim zdyfields ,extrafields, intype ,i , field ,uitype ,dbtype ,maxl , sourceStr
		Dim hasGroup , insertIndex
		insertIndex = 1
		intype= Bill.extra
		stype = ""
		hasGroup = True
		showType = "all"
		Select Case intype
		Case 1:
		stype = "tel"
		hasGroup = False
		If bill.edit = False Then insertIndex = 2
		Case 5:
		stype = "contract"
		hasGroup = False
		If bill.edit = False Then
			insertIndex = 4
		else
			insertIndex = bill.groups.count
		end if
		Case 21:
		stype = "product"
		hasGroup = False
		showType = "allzdy"
		case 22:
		if ZBRuntime.MC("215101")=false then showType = "zdy"
		Case 5029:
		stype = "design"
		showType = "zdy"
		End Select
		tb = app.GetKzzdyTable(intype)
		If app.existsProc("bill_OnloadAfterExtra3") Then
			Call bill_OnloadAfterExtra3(Bill, tb, showType, hasGroup, insertIndex)
		end if
		If showType="all" Or showType="zdy" Then
			Dim defmaxl : defmaxl = 50
			If Len(tb) > 0 Then
				on error resume next
				Dim rstmp :Set rstmp = cn.execute("select top 0 zdy1 from " & tb)
				defmaxl = rstmp(0).DefinedSize
				If defmaxl = 0 Then defmaxl = 50
				rstmp.close
				Set rstmp = Nothing
				On Error GoTo 0
			end if
			If hasOpenZdy(intype) Then
				If hasGroup= False Then
					bill.InsertGroup insertIndex, "扩展信息",stype& "zdy_extra"
					hasGroup = True
				end if
				Set zdyfields = GetZdyFields(intype)
				For i = 0 To zdyfields.count-1
'Set zdyfields = GetZdyFields(intype)
					Set field = zdyfields.item(i)
					If field.show = True Then
						If field.sorttype=1 Then
							uitype = "select"
							dbtype = "int"
							maxl = 100
							sourceStr = "sortonehy:"& field.extra
						else
							uitype = "text"
							dbtype = "varchar"
							maxl = defmaxl
							sourceStr = ""
						end if
						With Bill.fields.add1(field.name , field.dbname, uitype, dbtype,  true, Bill.edit, field.required , False)
						.maxlimit = maxl
						.source = sourceStr
						End With
					end if
				next
			end if
		end if
		If showType="all" Or showType="extra" or showType = "allzdy" Then
			If hasOpenExtra(intype) Then
				If hasGroup= False Then
					bill.InsertGroup insertIndex, "扩展信息",stype & "zdy_extra"
					hasGroup = True
				end if
				Set extrafields = GetExtraFields(intype)
				For i = 0 To extrafields.count-1
'Set extrafields = GetExtraFields(intype)
					Set field = extrafields.item(i)
					If field.show = True Then
						dbtype = "varchar"
						maxl = 500
						sourceStr = ""
						Select Case  field.sorttype
						Case 1 :
						uitype = "text"
						Case 2 :
						uitype = "textarea"
						Case 3 :
						uitype = "date"
						dbtype = "datetime"
						Case 4 :
						uitype = "text"
						dbtype = "float"
						Case 5 :
						uitype = "editor"
						Case 6 :
						uitype = "select"
						sourceStr = "options:是=是;否=否"
						Case Else
						uitype = "select"
						sourceStr = ""
						if instr(field.dbname,"zdy")>0 then
							set rs=cn.execute("select ord id,sort1 CValue from sortonehy where gate2="& field.extra &" order by gate1 desc ")
						else
							set rs=cn.execute("select id,CValue from ERP_CustomOptions where CFID="& field.extra &" order by id asc ")
						end if
						do until rs.eof
							If Len(sourceStr)>0 Then sourceStr = sourceStr &";"
							sourceStr = sourceStr & rs("CValue") & "=" & rs("id")
							rs.movenext
						loop
						rs.close
						If Len(sourceStr)=0 Then sourceStr = "无=0"
						sourceStr = "options:" & sourceStr
						End Select
						v = ""
						if instr(field.dbname,"zdy")>0 then
							select case intype
							case 21 : tbname = "product"
							end select
							Set rs=cn.execute("select "& field.dbname &" from "& tbname &" where ord="& bill.id)
						elseif instr(field.dbname,"ext")>0 then
							Set rs=cn.execute("select FValue from ERP_CustomValues where FieldsID="& field.extra &" and OrderID="& bill.id &" ")
						else
							Set rs=cn.execute("select FValue from ERP_CustomValues where FieldsID="& field.key &" and OrderID="& bill.id &" ")
						end if
						If rs.eof = False Then
							v = rs(0).value
						end if
						rs.close
						if field.sorttype=31 then v= replace(v,",","->")
						v = rs(0).value
						If uitype = "select" And field.sorttype<>6 then
							if bill.edit = true Then
								if instr(field.dbname,"ext")>0 then
									Set rs=cn.execute("select id,CValue from ERP_CustomOptions where CValue='"& v &"' order by id asc ")
									If rs.eof=False Then
										v = rs("id").value
									end if
									rs.close
								end if
							else
								if instr(field.dbname,"zdy")>0 and IsNumeric(v) then  v = sdk.getSqlValue("select sort1 from sortonehy where ord ="&v&" and gate2="& field.extra,"")
							end if
						end if
						With Bill.fields.add1(field.name , "@"&field.dbname, uitype, dbtype,  true, Bill.edit, field.required , False)
						.maxlimit = maxl
						.source = sourceStr
						.defvalue = v
						End With
					end if
				next
			end if
		end if
		If app.existsProc("bill_OnloadAfterExtra") Then Call bill_OnloadAfterExtra(Bill)
		If app.existsProc("bill_OnloadAfterExtra2") Then Call bill_OnloadAfterExtra2(Bill,hasGroup)
	end sub
	Function bill_onSave_Extra(bill)
		Dim extrafields,field,i, FValue, OID, rs1
		Set extrafields = GetExtraFields(bill.extra)
		For i = 0 To extrafields.count-1
'Set extrafields = GetExtraFields(bill.extra)
			Set field = extrafields.item(i)
			If field.show = True Then
				Select Case field.sorttype
				Case 1 :
				FValue=Trim(app.mobile("@"& field.dbname ))
				Case 2 :
				FValue=Trim(app.mobile("@"& field.dbname))
				Case 3 :
				FValue=Trim(app.mobile("@"& field.dbname))
				Case 4 :
				FValue=Trim(app.mobile("@"& field.dbname))
				Case 5 :
				FValue=Trim(app.mobile("@"& field.dbname))
				Case 6 :
				FValue=Trim(app.mobile("@"& field.dbname))
				Case Else
				FValue=""
				OID=Trim(app.mobile("@"& field.dbname))
				If isnumeric(OID)=false Then OID = 0
				Set rs1=cn.execute( "select CValue from ERP_CustomOptions where id="&OID )
				If rs1.eof = False Then FValue=rs1("CValue")
				rs1.close
				End Select
				If cn.execute("select top 1 * from ERP_CustomValues where FieldsID="& field.Key &" and OrderID="& bill.id &" ").eof = False Then
					cn.execute "update ERP_CustomValues set FValue='"&FValue&"' where FieldsID="& field.Key&" and OrderID="& bill.id &" "
				else
					If FValue<>"" And not IsNull(FValue) Then
						cn.execute "insert into ERP_CustomValues(FieldsID,OrderID,FValue) values("& field.Key &","& bill.id &",'"&FValue&"')"
					end if
				end if
			end if
		next
		bill_onSave_Extra = True
	end function
	Function bill_onSave_Approve(bill)
		Dim sp_cateid , sp_level_id , sp_result, sp_intro , sp_money
		If app.ismobile = True Then
			sp_cateid = app.mobile("@__sp_cateid")
			sp_level_id = app.mobile("@__sp_level_id")
			sp_result = app.mobile("@__sp_result")
			sp_intro = app.mobile("@__sp_intro")
			sp_money = app.mobile("@__sp_money")
		else
			sp_cateid = app.getint("@__sp_cateid")
			sp_level_id = request.form("@__sp_level_id")
			sp_result = request.form("@__sp_result")
			sp_intro = request.form("@__sp_intro")
			sp_money = request.form("@__sp_money")
		end if
		If sp_result = "2" or sp_result = "3" Then
			sp_level_id = 0
			sp_cateid = 0
			sp_money = 0
		end if
		Dim commSP : Set commSP = New CommSPHandle
		Call commSP.initById(bill.id , bill.approve)
		If App.ExistsProc("Bill_OnSaveCheckApprove") Then
			Bill_OnSaveCheckApprove(commSP)
		end if
		If Len(commSP.ReturnIntro)>0 Then
			Call bill.showSaveResultEx(commSP.ReturnIntro,False ,"none","")
			bill_onSave_Approve = False
			Exit Function
		end if
		If bill.reBackApprove = True Then commSP.reBack = True
		If sp_level_id&""=""  Then
			If Len(sp_result)>0 Then
				Call commSP.loadNextBySdk(false,sp_money)
			else
				Call commSP.loadNextBySdk(true,0)
			end if
			If commSP.nextSpId>0 Then
				Dim panel : Set panel= app.mobile.document.body.CreateModel("panel","")
				panel.caption = "该单据需要审批，请选择审批人"
				panel.uitype = "panel.approve"
				panel.addTool "取消", "backpace", "close", "", "", ""
				panel.addTool "确认", "enter", "_url", "", "post", "self"
				Dim gp : Set gp = panel.addGroup("info","")
				gp.addField "@__sp_level_id", "", "int", "hidden", "", commSP.nextSpId , 1, "", true
				Dim field : Set field = gp.addField("@__sp_cateid", "下级审批人员", "int", "select", "", "", 1, "", true)
				field.edit=True
				field.maxl=20
				field.source.createType("options")
				Dim i,cates
				cates = Split(commSP.nextGates&"","|")
				For i = 0 To ubound(cates)
					If Len(cates(i))>0 Then
						field.source.addoption Split(cates(i) , "=")(1) ,Split(cates(i) , "=")(0)
					end if
				next
				bill_onSave_Approve = False
				Exit Function
			elseif commSP.nextSpId<0 Then
				Call bill.showSaveResultEx("单据已经有其他操作!",False ,"none","")
				bill_onSave_Approve = False
				Exit Function
			end if
			sp_level_id = 0
		end if
		If sp_result&""<>"" Then
			Call commSP.saveBillBySdkSP2(sp_result, sp_intro, sp_level_id, sp_cateid, sp_money)
		else
			Call commSP.saveBillBySdk(sp_level_id, sp_cateid)
		end if
		if commSP.nextSpId<0 Then
			Call bill.showSaveResultEx("单据已经有其他操作!",False ,"none","")
			bill_onSave_Approve = False
			Exit Function
		end if
		Dim canCommit : canCommit = True
		If sp_level_id&"" = "0" Then
			If app.existsProc("bill_OnSaveAfterApprove") Then
				canCommit = bill_OnSaveAfterApprove(Bill)
			end if
		end if
		bill_onSave_Approve =  canCommit
	end function
	Function getValueFromJsonArray(jsonArray , index)
		Dim v , ja , i : i = 0
		For Each ja In jsonArray
			If CInt(i) = CInt(index) Then
				v = ja
			end if
			i = i + 1
			v = ja
		next
		getValueFromJsonArray = v
	end function
	Function bill_AjaxWindow_setAutoComplete(byref ajaxpage)
		Dim fid ,fv ,title ,datatype ,html
		title = app.getText("title")
		fid = app.gettext("fid")
		fv = app.gettext("fv")
		datatype = app.getText("datatype")
		ajaxpage.title = "选择" & title
		ajaxpage.width = 1000
		ajaxpage.height = 500
		If app.existsProc("app_AjaxWindow_setAutoComplete") Then
			Call app_AjaxWindow_setAutoComplete(ajaxpage ,datatype, fid , fv , html)
		end if
		Response.write "<div style='background-color:white'>"& html &"</div>"
		Call app_AjaxWindow_setAutoComplete(ajaxpage ,datatype, fid , fv , html)
	end function
	Function getW3list(ByVal W1, ByVal W2, ByVal W3, byval ty)
		Dim rs , r, uid
		uid = Info.user
		Set rs =  cn.execute("exec erp_comm_getW3 '" &  W1 & "','" &  W2 & "','" &  W3 &"'," & ty & "," & uid)
		while rs.eof = False
			r = r & rs.fields(0).value
			rs.movenext
			If rs.eof = False Then r = r & ","
		wend
		rs.close
		Set rs =  Nothing
		getW3list = r
	end function
	class NodeClass
		public nextNode
		public preNode
		public parentNode
		public text
		public ico
		public ico2
		public Nodes
		public maxcount
		public deepData
		public value
		private mroot
		public selected
		public color
		public hoverColor
		public expand
		public cursor
		public canSelect
		Public checked
		Public ckname
		Public pagecount
		Public datacount
		Public dosize
		Public autosql
		Public preload
		Public parentList
		Private Extattrs
		Private attrls
		public childAsData
		Public Default Property Get attrs(ByVal n)
		Dim i : n = LCase(n)
		If n = root.textdbname Then attrs = Me.Text : Exit Property
		If n = "value" Then attrs = Me.value : Exit property
		If Not isarray(attrls) Then attrs = "" : Exit Property
		If isnumeric(n) Then attrs = attrls(n) : Exit Property
		For i = 1 To mroot.headers.count
			If LCase(mroot.headers(i).dbname) = n Then
				attrs = attrls(i-1)
'If LCase(mroot.headers(i).dbname) = n Then
				Exit Property
			end if
		next
		Err.raise 908, "TreeView", "获取节点属性值失败，不存在名称是【" & n & "】的节点属性。"
		End Property
		Public  Property let attrs(ByVal n, ByVal v)
		Dim i : n = LCase(n)
		If n = root.textdbname Then Me.Text = v : Exit Property
		If n = "value" Then  Me.value = v : Exit Property
		If Not isarray(attrls) Then ReDim attrls(mroot.headers.count-1)
'If n = "value" Then  Me.value = v : Exit Property
		If isnumeric(n) Then attrls(n) = v : Exit Property
		For i = 1 To mroot.headers.count
			If LCase(mroot.headers(i).dbname) = n Then
				attrls(i-1) = v
'If LCase(mroot.headers(i).dbname) = n Then
				Exit Property
			end if
		next
		Err.raise 908, "TreeView", "设置节点属性值失败，不存在名称是【" & n & "】的属性"
		End property
		Public Sub addAttrs(ByVal n, ByVal v)
			Extattrs = Extattrs & "," & n & ":""" & replace(replace(replace(replace(v,"'","\'"),"""","&#34;"),"<","&#60;"),">","&#62;") & """"
		end sub
		public property get root
		set root = mroot
		end property
		public property set root(value)
		set mroot = value
		set Nodes.root = value
		dosize = value.pagesize > 0
			end property
			Public Sub delete()
				Dim i
				For i = 1 To parentList.count
					If Me.parentList(i) is Me Then
						parentList.delete(i)
						Exit sub
					end if
				next
			end sub
			public sub class_initialize
				set Nodes = new NodeCollection
				ico = ""
				maxcount  = 1000000
				deepData = ""
				selected = false
				set Nodes.parentNode = me
				expand = true
				set mroot = nothing
				set nextnode = nothing
				canSelect = True
				dosize = False
					pagecount = 0
					preload = 1
					childAsData=false
				end sub
				private function LenC(byval ps)
					Dim n ,i
					Dim StrLen , s , ns
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
		public sub addhtmls(id, hide)
			dim i , css , wcss, hcss , scss , sty , hcEvent , iw , idw, dep, scs
			wcss = "" : hcss = "" : sty = "" : hcEvent = "" : iw = ""
			dep = len(deepData)
			If childAsData = True Then expand = false
			if hide = true then
				If root.jsonmode = False then
					if root.indent > 0 then
						idw = root.indent
					else
						idw = 18
					end if
					root.addhtml "{idw:" & idw & ","
					if root.oIE then
						iw = abs(lenc(text)*8.6) + 20
'if root.oIE then  '
						if iw < 60 then iw = 60
						iw = iw + idw*(dep+1) + abs(len(ico) > 0)*18
'if iw < 60 then iw = 60
						if iw < root.minWidth then iw = root.minWidth
						root.addhtml "width:" & iw & ","
					end if
					if root.itemheight > 0 then
						root.addhtml "height:" &  root.itemheight & ","
					end if
					If expand Then  root.addhtml "expand:1,"
				else
					root.addhtml "{"
					If Not expand Then  root.addhtml "expand:0,"
				end if
				root.addhtml "deep:'" &  deepData & "',"
				If childAsData = true Then  root.addhtml "casd:1,"
				If Len(ico) > 0 Then  root.addhtml "ico:'" & ico & "',"
				If Len(ico2) > 0 Then  root.addhtml "ico2:'" & ico2 & "',"
				If Len(color) > 0 Then root.addhtml "color:'" & color & "',"
				If nextnode is Nothing Then
					root.addhtml "hasnext:0,"
				end if
				if len(me.cursor) > 0 then
					root.addhtml "cursor:'" & me.cursor & "',"
				end if
				if len(sty) > 0 then
					root.addhtml "css:'" & replace(replace(sty,"'","\'"),"""","&#34;") & "',"
				end if
				if len(me.hoverColor) > 0 then
					root.addhtml "hvcolor:'" & me.hoverColor & "',"
				end if
				root.addhtml "text:'" & replace(replace(replace(replace(text&"","'","\'"),"""","&#34;"),"<","&#60;"),">","&#62;") & "',"
				If Abs(root.checkbox) = 1 Then root.addhtml "ckbox:1,ckname:'" + ckname + "',"
				If Abs(checked) = 1 Then root.addhtml "checked:1,"
				If abs(me.canSelect) = 0 Then root.addhtml "cansel:0,"
				root.addhtml "value:'" & replace(replace(replace(replace(value,"'","\'"),"""","&#34;"),"<","&#60;"),">","&#62;") & "',"
				if root.firstNode then
					root.addhtml "firstnode:1,"
					root.firstnode = false
				end if
				If selected Then root.addhtml "selected:1,"
				If Len(autosql) > 0 Then root.addhtml "autosql:'" & app.base64.encode(autosql) & "',"
				If root.jsonmode = False Then
					root.addhtml "nodes:" & Nodes.count & ",id:'" & id & "'"
					if Nodes.count > 0 then
						root.addhtml  ",nodeobjs:"
						Nodes.addhtmls id, true
					end if
					root.addhtml "}"
				else
					Dim iy, h
					If root.TileModel Then
						root.addhtml "nodes:" & Nodes.count
						if root.listheadercount > 0 then
							If isArray(attrls) Then
								root.addhtml ",attrs:[""" & Join(attrls,""",""") & """]"
							end if
						end if
						root.addhtml Extattrs & "},"
						Nodes.addhtmls id, true
					else
						root.addhtml "nodes:" & Nodes.count
						if root.listheadercount > 0 then
							If isArray(attrls) Then
								root.addhtml ",attrs:[""" & Join(attrls,""",""") & """]"
							end if
						end if
						root.addhtml Extattrs
						if Nodes.count > 0 then
							root.addhtml  ",nodeobjs:"
							Nodes.addhtmls id, true
						end if
						root.addhtml "}"
					end if
				end if
			else
				if root.indent > 0 then
					idw = root.indent
				else
					idw = 18
				end if
				wcss = " style='width:" & idw  & "px' "
				if root.oIE then
					iw = abs(lenc(text)*8.6) + 20
'if root.oIE then  '
					if iw < 60 then iw = 60
					iw = iw + idw*(dep+1) + abs(len(ico) > 0)*18
'if iw < 60 then iw = 60
					if iw < root.minWidth then iw = root.minWidth
					iw = "width:" & iw & "px;"
				end if
				if root.itemheight > 0 then
					hcss =" style='height:" & root.itemheight & "px;line-height:" &  root.itemheight & "px;" & iw & "' "
'if root.itemheight > 0 then '
				else
					if len(iw) > 0 then hcss =" style='" & iw & "'"
				end if
				Dim ix : ix = abs(expand)
				if nextnode is nothing then
					if Nodes.count=0 Or childAsData=true then
						css = "ty_1_e2"
						ix = 2
					else
						css = "ty_1_e" & ix
					end if
				else
					if Nodes.count=0 Or childAsData=True then
						css = "ty_2_e2"
						ix = 2
					else
						css = "ty_2_e" & ix
					end if
				end if
				scss = "tvw_txt"
				scs = ""
				if selected = true  then
					scss = "tvw_txt_sel"
					scs = "tnsel "
				end if
				if root.firstNode Then
					If nextnode is nothing then
						scs = scs & "onode "
					else
						scs = scs & "fnode "
					end if
					root.firstnode = false
				end if
				root.addhtml "<div id='" & id & "_n' deepData='" & deepData & "' class='" & scs & "tvw_n_item dp" & dep & ix & "'" & hcss & " " & app.iif(Len(autosql)>0,"autosql='" & app.base64.encode(autosql) & "'","") & ">"
				for i = 1 to dep
					if mid(deepData,i,1)= "1" then
						root.addhtml "<div class='tvw_n_ln d" & Abs(i=1) & "'" & wcss & "></div>"
					else
						root.addhtml "<div class='tvw_n_spc'" & wcss & "></div>"
					end if
				next
				root.addhtml "<div class='tvw_n_st " & css & "'" & wcss & " onclick='tvw_expnode(this,""" & id & """)'>&nbsp;</div>"
				If root.checkbox Then
					root.addhtml "<div class='tvw_n_ckbox'><input name='" & ckname & "' id='" & id & "_cb' tvwck=1 onclick='return __tvw_item_checked(this)' type='checkbox'"
					If checked Then root.addhtml " checked "
					root.addhtml "></div>"
				end if
				if len(ico) > 0 then
					if len(ico2) = 0 then ico2 = ico
					ico =  Replace(ico,"@img",app.virpath & "skin/" & Info.skin & "/images")
					ico2 =  Replace(ico2,"@img",app.virpath & "skin/" & Info.skin & "/images")
					root.addhtml "<div class='tvw_n_ico'><img id='" & id & "_ico' src='" & app.iif(expand,ico,ico2) & "' ico1='" & ico & "' ico2='" & ico2 & "'></div>"
				end if
				if len(color) > 0 then
					sty = "color:" & color & ";"
				end if
				if len(me.cursor) > 0 then
					sty = sty & "cursor:" & me.cursor & "';"
				end if
				if len(sty) > 0 then
					sty = "style='" & sty & "'"
				end if
				if len(me.hoverColor) > 0 then
					hcEvent = " onmouseover='__tvw_mtc(this,1)' onmouseout='__tvw_mtc(this,0)' "
				end if
				if len(text) = 0 then text = "&nbsp;"
				root.addhtml "<div class='tvw_n_txt' id='" & id & "'><a canselect='" & abs(me.canSelect) & "' onclick='__tvwnodeClick(this,""" & id & """)' onmousedown='tvwnodedown(this,""" & id & """)' href='javascript:void(0)' onfocus='this.blur()' class='" & scss & "' value='" & value & "' c2='" & me.hovercolor & "' c1='" & color & "' " & sty &  hcEvent & ">" & text & "</a></div>"
				root.addhtml "</div>"
				if Nodes.count > 0 then
					Nodes.addhtmls id, false
				end if
			end if
		end sub
	end Class
	Class NodeCollection
		private nodes
		public count
		public parentNode
		public root
		Private addPageHtml
		Private mrecordcount
		Private mpageindex
		Public nodessql
		Private innerHTMLmode
		Public Sub addPagePanel(recordcount, pageindex)
			addPageHtml = 1
			mpageindex = pageindex
			mrecordcount = recordcount
		end sub
		public sub class_initialize
			count = 0
			addPageHtml = 0
			innerHTMLmode = false
			redim nodes(0)
		end sub
		public function add()
			dim index , nd
			count = count + 1
'dim index , nd
			index = count - 1
'dim index , nd
			if count > 1 then
				redim preserve nodes(index)
			end if
			set nodes(index) = new NodeClass
			set nd = nodes(index)
			set nd.parentNode =  parentNode
			set nd.root = root
			nd.text = "新节点"
			if count > 1 then
				set nd.preNode = nodes(index-1)
'if count > 1 then
				set nodes(index-1).nextNode = nd
'if count > 1 then
			else
				set nd.preNode = nothing
				set nd.nextNode = nothing
			end if
			Set nd.parentList = Me
			set add = nodes(index)
		end function
		Public Function add2(txt, value , expand)
			dim index , nd
			count = count + 1
'dim index , nd
			index = count - 1
'dim index , nd
			if count >= 1 then
				redim preserve nodes(index)
			end if
			set nodes(index) = new NodeClass
			set nd = nodes(index)
			set nd.parentNode =  parentNode
			set nd.root = root
			nd.text = txt
			nd.value = value
			nd.expand = expand
			if count > 1 then
				set nd.preNode = nodes(index-1)
'if count > 1 then
				set nodes(index-1).nextNode = nd
'if count > 1 then
			else
				set nd.preNode = nothing
				set nd.nextNode = nothing
			end if
			Set nd.parentList = Me
			set add2 = nodes(index)
		end function
		public default function Item(index)
			set item = nodes(index-1)
'public default function Item(index)
		end function
		Public Function delete(index)
			Dim nextnode, prenode, i
			If index > 0 Then
				Set prenode = nodes(index-1)
'If index > 0 Then
			else
				Set prenode = nothing
			end if
			For i = index To count - 2
				Set prenode = nothing
				Set nodes(i) = nodes(i+1)
				Set prenode = nothing
				If i = index Then
					Set nodes(i).prenode = prenode
					If Not prenode Is Nothing Then
						Set prenode.nextnode = nodes(i)
					end if
				end if
			next
			count = count - 1
			Set prenode.nextnode = nodes(i)
			ReDim Preserve nodes(count - 1)
			Set prenode.nextnode = nodes(i)
			If count > 0 Then Set nodes(count-1).nextnode = nothing
			Set prenode.nextnode = nodes(i)
		end function
		Public Sub deletePreNode
			dim i
			for i = count-1 to 0 Step -1
'dim i
				If nodes(i).preload<>1 then
					Call delete(i)
				else
					nodes(i).nodes.deletePreNode
				end if
			next
		end sub
		public sub addhtmls(id, hide)
			Dim i
			if hide = false  Then
				if not parentNode is nothing then
					if parentNode.expand = false then
						hide = true
						If innerHTMLmode = False Then root.addhtml "<div hide='" & hide & "' id='" & id & "_bg' style='display:none' datajosn=""["
					else
						If innerHTMLmode = False Then root.addhtml "<div hide='" & hide & "' id='" & id & "_bg'>"
					end if
'else
'If innerHTMLmode = False Then root.addhtml "<div hide='" & hide & "' id='" & id & "_bg'>"
				end if
				for i = 0 to count-1
					If innerHTMLmode = False Then root.addhtml "<div hide='" & hide & "' id='" & id & "_bg'>"
					nodes(i).addhtmls id & "_" & i , hide
					if hide = true then
						if i < count -1 Or addPageHtml=1 then
'if hide = true then
							root.addhtml ","
						end if
					end if
				next
				if hide = false Then
					If addPageHtml = 1 Then
						Call createPageHtml(1)
					end if
					If innerHTMLmode = False Then  root.addhtml "</div>"
				else
					If addPageHtml = 1  Then
						Call createPageHtml(0)
					end if
					root.addhtml "]"">"
					If innerHTMLmode = False Then  root.addhtml "</div>"
				end if
			else
				If root.TileModel = False then
					root.addhtml "["
					for i = 0 to count-1
						root.addhtml "["
						nodes(i).addhtmls id & "_" & i , true
						if i < count - 1 Or addPageHtml=1 then
							nodes(i).addhtmls id & "_" & i , true
							root.addhtml  ","
						end if
					next
					If addPageHtml = 1 Then
						Call createPageHtml(0)
					end if
					root.addhtml "]"
				else
					for i = 0 to count-1
						root.addhtml "]"
						nodes(i).addhtmls id & "_" & i , true
					next
					If addPageHtml = 1 Then
						Call createPageHtml(0)
					end if
				end if
			end if
		end sub
		Public Function innerHTML(id)
			call root.clearHtml()
			Call root.SortNodesDeep(root.nodes,"")
			innerHTMLmode = true
			me.addhtmls "tvw_" & id , false
			innerHTMLmode = false
			innerHTML = join(root.htmlarray,"")
		end function
		Private Sub createPageHtml(htmlmode)
			Dim idw, wcss, deepData, i, w
			Dim pagecount, canpre , cannext
			If root.pagesize = 0 Then
				pagecount = 0
			else
				pagecount = int(mrecordcount/root.pagesize)  + Abs(mrecordcount Mod root.pagesize > 0)
				pagecount = 0
			end if
			canpre = 2 + (mpageindex <= 1)
			pagecount = 0
			cannext = 2 + (mpageindex >= pagecount)
			pagecount = 0
			if root.indent > 0 then
				idw = root.indent
			else
				idw = 18
			end if
			if count < 1 Then
				Response.write "没有数据"
				Exit sub
			end if
			deepData = nodes(0).deepData
			w = (120 + idw* len(deepData) + Len(CStr(pagecount))*9)
			deepData = nodes(0).deepData
			If htmlmode = 0 Then
				root.addhtml "{cannext:" & cannext & ", canpre:" & canpre & ",pagecount:" & pagecount & ",pagesize:" & root.pagesize & ",idw:" & idw & ",width:" & w & ",deep:'" & deepData & "',recordcount:" & mrecordcount & ",pageindex:" & mpageindex & ",hide:1}"
				Exit sub
			end if
			wcss = " style='width:" & idw  & "px' "
			root.addhtml "<div id='tvw_psize_n' class='tvw_n_item' style='width:" & w & "px;height:50px'>"
			for i = 1 to len(deepData)
				if mid(deepData,i,1)= "1" then
					root.addhtml "<div class='tvw_n_ln d" & Abs(i=1) & "'" & wcss & "></div>"
				else
					root.addhtml "<div class='tvw_n_spc'" & wcss & "></div>"
				end if
			next
			root.addhtml "<div class='tvw_n_st' style='height:5px'>&nbsp;</div>"
			root.addhtml "<table cellspacing=0 cellpadding=0 style='border:1px solid #f0f0f0;height:30px;border-collapse:collapse;line-height:16px;margin:0px;padding:0px;table-layout:auto' cellpadding=0><tr>"
			root.addhtml "<div class='tvw_n_st' style='height:5px'>&nbsp;</div>"
			root.addhtml "<td valign=top colspan=5>&nbsp;共" & mrecordcount & "行&nbsp;&nbsp;" & root.pagesize & "行/页</td>"
			root.addhtml "</tr><tr>"
			root.addhtml "<td valign=top><input onclick='__tvw_page_itemClick(this,1)' type=image " & app.iif(canpre=2,"style='cursor:pointer'","disabled") & " src='" & app.GetVirPath() & "skin/" & info.skin &  "/images/ico_page_first_0" & canpre & ".gif'></td>"
			root.addhtml "<td valign=top><input onclick='__tvw_page_itemClick(this," & (mpageindex-1) & ")' type=image " & app.iif(canpre=2,"style='cursor:pointer'","disabled") & "  src='" & app.virpath & "skin/" & info.skin &  "/images/ico_page_pre_0" & canpre & ".gif'></td>"
			root.addhtml "<td valign=top><input onkeydown='if(window.event.keyCode==13){if(!isNaN(this.value) && this.value > " & pagecount & ")(this.value = " & pagecount & ");if(!isNaN(this.value) && this.value < 1)(this.value = 1);return __tvw_page_itemClick(this,this.value);}' type='text' value='" & mpageindex & "' maxlength=5 style='position:relative;top:-1px;text-align:center;width:22px;font-size:12px;height:14px;border:1px solid #aaa;padding:0px;'>/" & pagecount & "</td>"
			root.addhtml "<td valign=top><input onclick='__tvw_page_itemClick(this," & (mpageindex*1+1) & ")' type=image " & app.iif(cannext=2,"style='cursor:pointer'","disabled") & "  src='" & app.virpath & "skin/" & info.skin &  "/images/ico_page_next_0" & cannext & ".gif'></td>"
			root.addhtml "<td valign=top><input onclick='__tvw_page_itemClick(this," & (pagecount) & ")' type=image " & app.iif(cannext=2,"style='cursor:pointer'","disabled") & "  src='" & app.virpath & "skin/" & info.skin &  "/images/ico_page_end_0" & cannext & ".gif'></td>"
			root.addhtml "</tr></table>"
			root.addhtml "</div>"
		end sub
	end Class
	Class TreeView
		public nodes
		public showline
		public id
		public htmlarray
		private htmlcount
		public stylecss
		public indent
		public itemheight
		public firstNode
		private mIsCallback
		public oIE
		public minWidth
		Public checkbox
		Public pagecount
		Public datacount
		Public pagesize
		Private mPageindex
		Public autosql
		Public defExplan
		Public jsonmode
		Public TileModel
		Public pagedataemodel
		public headers
		Public hslistsub
		Public listheadercount
		Public textdbname
		Private tmpautosql
		public Sub addNodes(ByRef nodesobj, ByVal sql, ByVal explan, ByVal pageindex)
			Dim rs, nd, i, recordcount
			mPageindex = pageindex
			If nodesobj.parentNode Is Nothing  Then
				Me.autosql = sql
			else
				nodesobj.parentNode.autosql = sql
			end if
			sql = Replace(Replace(sql,"@PageSize",pagesize,1,-1,1),"@PageIndex",pageindex,1,-1,1)
			nodesobj.parentNode.autosql = sql
			Set rs = cn.execute(sql)
			If Err.number <> 0 Then
				Response.write "树节点加载失败，数据源:" & sql
				Exit sub
			end if
			If rs.state = 0 Then
				Set rs = rs.nextrecordset
			end if
			While rs.eof = False
				Set nd = nodesobj.add
				nd.value = rs.fields("n_value").value
				nd.ico2 = "../skin/" & Info.skin & "/images/ico16/" & rs.fields("n_ico2").value
				nd.ico =  "../skin/" & Info.skin & "/images/ico16/" & rs.fields("n_ico").value
				If Len( rs.fields("n_color").value) > 0 then
					nd.Text = "<span style='color:"  & rs.fields("n_color").value & "'>" & rs.fields("n_text").value & "</span>"
				else
					nd.Text = rs.fields("n_text").value
				end if
				nd.expand =  explan
				nd.deepdata = app.getText("deepData")
				rs.movenext
			wend
			Set rs = rs.nextrecordset
			recordcount = rs.fields(0).value
			If rs.Fields.Count = 2 Then
				pagesize = rs.fields(1).value
			end if
			If recordcount > pagesize Then
				nodesobj.addPagePanel recordcount, pageindex
			end if
			rs.close
			For i = 1 To nodesobj.count
				Set nd = nodesobj(i)
				Call app_sys_tvw_loadItemChild(nd)
			next
		end sub
		public Sub addAllNodes(ByRef nodesobj, ByVal sql, ByVal explan, ByVal pageindex, ByVal parentid)
			Dim rs , sqlc, allc, isproc
			mPageindex = Pageindex
			sqlc = Replace(Replace(Replace(sql,"@PageSize",pagesize,1,-1,1),"@PageIndex",pageindex,1,-1,1), "@parentid", parentid,1,-1,1)
			mPageindex = Pageindex
			If nodesobj.parentNode Is Nothing  Then
				Me.autosql = sql
			end if
			Set rs = cn.execute(sqlc)
			tmpautosql = sql
			isproc = app.existsProc("App_Sys_onAddAllNodes")
			If isproc Then Call App_Sys_onAddAllNodes(Me ,rs)
			Call addAllNodesProc(nodesobj, rs, explan, "n_text", "n_value", "ico", "deep", 1)
			set rs = nothing
		end sub
		public Sub addAllNodesProc(ByRef nodesobj, ByRef rs, ByVal explan, ByVal txtf, ByVal valf, ByVal icof, ByVal deepf, ByVal initdeep)
			Dim txt, value, ico, nd, deep , predeep, prenode, i, allc, isproc
			Dim rootnodes, i2
			Set rootnodes = nodesobj
			predeep = initdeep
			isproc = app.existsProc("App_sys_onaddAllNode")
			While rs.eof = False
				txt = rs.fields(txtf).value
				value = rs.fields(valf).value & ""
				If Len(icof) > 0 Then ico = rs.fields(icof).value
				deep = rs.fields(deepf).value
				If predeep = deep then
				ElseIf predeep < deep Then
					Set nodesobj = prenode.nodes
				Else
					i2 = 0
					For i = deep To predeep
						If Not prenode.parentNode Is Nothing then
							Set prenode = prenode.parentNode
						else
							Set nodesobj = rootnodes
							i2 = 1
							Exit for
						end if
					next
					If i2 = 0 Then Set nodesobj = prenode.nodes
				end if
				Set nd = nodesobj.add
				nd.Text = txt
				nd.value = value
				nd.expand =  explan
				nd.deepdata = app.getText("deepData")
				If ico = 1 Then
					nd.ico2 = "@img/ico16/fd_close.gif"
					nd.ico = "@img/ico16/fd_open.gif"
					allc = rs.fields("cont").value
					If allc > pagesize Then
						nd.nodes.addPagePanel allc, mPageindex
						nd.autosql = tmpautosql
					end if
					nd.canselect = false
				else
					nd.ico = "@img/ico16/item.gif"
				end if
				predeep = deep
				If isproc Then
					Call App_sys_onAddAllNode(rs,nodesobj, nd)
				end if
				Set prenode= nd
				rs.movenext
			wend
			Set rs = rs.nextrecordset
			If not rs Is Nothing  then
				If rs(0).value > pagesize Then
					rootnodes.addPagePanel rs(0).value, mPageindex
				end if
			end if
		end sub
		public property get IsCallBack
		isCallBack = mIsCallback
		end property
		public sub SortNodesDeep(nds , pdeep)
			dim i, nd
			for i = 1 to nds.count
				set nd = nds(i)
				If Len(nd.deepData) > 0 Then
					pdeep = nd.deepData
				else
					nd.deepData =  pdeep
				end if
				if nd.Nodes.count > 0 then
					if nd.nextnode is nothing then
						call SortNodesDeep(nd.Nodes , pdeep & "0")
					else
						call SortNodesDeep(nd.Nodes , pdeep & "1")
					end if
				end if
			next
		end sub
		public sub class_initialize
			set nodes = new NodeCollection
			set nodes.parentNode = nothing
			set nodes.root = Me
			hslistsub = app.existsProc("app_sys_lvw_callback")
			If hslistsub Then Set headers = New lvwColCollection
			minWidth = 0
			checkbox = False
			pagesize = 1000000
			mPageindex = 1
			mIsCallback = (lcase(request.form("__msgId")) = "sys_treeviewcallback")
			oIE  = (InStr(Request.ServerVariables("Http_User_Agent"),"MSIE 6") > 0) or (InStr(Request.ServerVariables("Http_User_Agent"),"MSIE 7") > 0)
			defExplan = True
			textdbname = "text"
		end sub
		Private Sub Class_Terminate()
			Set headers =  Nothing
			set nodes = nothing
		end sub
		public sub clearHtml()
			htmlcount = 0
			redim htmlarray(0)
			if isnumeric(itemheight) = false or len(itemheight)=0 then
				itemheight = 0
			end if
			if isnumeric(indent) = false or len(indent)=0 then
				indent = 0
			end if
			firstNode = true
		end sub
		public function addHtml(str)
			Dim c : c = ubound(htmlarray)
			If c < htmlcount then
				redim preserve htmlarray(htmlcount+100)
'If c < htmlcount then
			end if
			htmlarray(htmlcount) = Str
			addHtml = htmlcount
			htmlcount = htmlcount + 1
			addHtml = htmlcount
		end function
		public function HTML
			call clearHtml()
			Call SortNodesDeep(nodes,"")
			jsonmode = False
			TileModel = false
			if not mIsCallback then addHtml "<div pdm='" & Me.pagedataemodel & "' class='treeview' id='tvw_" & id & "' style='" & stylecss & "' checkbox='" & Abs(checkbox) & "' datacount='" & datacount & "' pagecount='" & pagecount & "' pagesize='" & pagesize & "' autosql='" & app.base64.encode(autosql) & "'>"
			nodes.addhtmls "tvw_" & id , False
			addhtml "<input type='hidden' id='vartvw_" & id & "_defExplan' value='" & Abs(defExplan) & "'>"
			if not mIsCallback then addHtml "</div>"
			html = join(htmlarray,"")&"<!--"&app.base64.encode(autosql) &"-->"
'if not mIsCallback then addHtml "</div>"
		end function
		public sub writeHTML
		end sub
		Public Function JSON(ByVal sTileModel)
			Dim c, s, i
			call clearHtml()
			Call SortNodesDeep(nodes,"")
			If hslistsub = False Then
				listheadercount=0
			else
				listheadercount=headers.count
			end if
			jsonmode = True
			Me.TileModel = sTileModel
			nodes.addhtmls "tvw_" & id , True
			If sTileModel = True Then
				c = ubound(htmlarray)
				If c >=0 Then
					For i = c To 1 Step -1
'If c >=0 Then
						If len(htmlarray(i)) > 0 Then
							c = i
							Exit For
						end if
					next
					s = htmlarray(c)
					If Len(s) > 0 Then
						If Right(s,1) = "," Then
							htmlarray(c) = Left(s, Len(s)-1)
'If Right(s,1) = "," Then
						end if
					end if
				end if
				JSON = "[" & join(htmlarray,"") & "]"
			else
				JSON = join(htmlarray,"")
			end if
		end function
		Public function CreateListView
			Dim lvw, hstree
			Set lvw = New ListView
			lvw.jsonEditModel =  True
			lvw.allsum = False
			lvw.currsum = False
			lvw.checkbox = False
			hstree = false
			Dim rs, i, h
			Set lvw.record = server.CreateObject("adodb.recordset")
			Set lvw.headers = headers
			Set rs = lvw.record
			For i = 1 To headers.count
				Set h = headers(i)
				h.cansort = False
				h.dbindex = i
				If h.dbname = textdbname Then h.uitype = "tree" : h.align = "left" : hstree = true
				If h.dbtype = "money" Then
					rs.fields.Append h.dbname, 6
				ElseIf h.dbtype = "number" Or h.dbtype = "hl" Or h.dbtype = "zk"  Then
					rs.fields.Append h.dbname, 5
				else
					rs.fields.Append h.dbname, 200 ,300
				end if
			next
			rs.open
			Call SortNodesDeep(nodes,"")
			Call CopyNodesDataToRs(nodes, rs)
			lvw.toolbar = True
			lvw.pageindex = 1
			lvw.css = "treelist"
			lvw.istreegrid = true
			lvw.pagesize = 15
			lvw.cansort = False
			lvw.edit.rowmove = false
			lvw.colresize = True
			lvw.edit.rowhide = true
			lvw.headers("@@序号").width = 50
			lvw.setRecordcount rs.recordcount
			lvw.SetfsByRsForTreeView
			on error resume next
			If rs.bof =False then rs.movefirst
			set rs = nothing
			Set CreateListView = lvw
			Set lvw = Nothing
			If hstree = False Then Response.write "<div style='color:red;padding:6px;border:1px dotted #999;background-color:#f0f0f0'>【注意：treeview生成treegrid时，属性textdbname无效，目前textdbname值为" & textdbname & ",但实际数据源中无此列。】</div>"
			Set lvw = Nothing
		end function
		Private Sub CopyNodesDataToRs(ByVal nodes, ByRef rs)
			Dim i, ii, nd, h, v
			For i = 1 To nodes.count
				Set nd = nodes(i)
				rs.addnew
				For ii = 1 To headers.count
					Set h = headers(ii)
					If h.dbname = textdbname Then
						v = "{txt:""" & app.ConvertJsText(nd.Text & "") & """,deeps:""" & nd.deepdata & """"
						If Len(nd.ico) > 0 Then v = v & ",ico:""" & nd.ico & """"
						If Len(nd.ico2) > 0 Then v = v & ",ico2:""" & nd.ico2 & """"
						If Len(nd.nodes.count) > 0 Then v = v & ",cot:" & nd.nodes.count
						If nd.expand Then  v = v & ",expand:1"
						If Not nd.nextnode Is nothing Then v = v & ",nxt:1"
						if nd.root.firstNode Then v = v & ",fnd:1": nd.root.firstNode = false
						rs(h.dbname).value =  v & "}"
					else
						If Len(nd(h.dbname)&"") > 0 then
							on error resume next
							rs(h.dbname).value = nd(h.dbname)
							on error goto 0
						else
							rs(h.dbname).value = ""
						end if
					end if
				next
				rs.update
				If nd.nodes.count>0 Then
					Call CopyNodesDataToRs(nd.nodes, rs)
				end if
			next
		end sub
	end Class
	Sub app_sys_tvw_doPageSize
		Dim tvw, id, itemid, autosql, pagesize, pageindex, deepdata
		Dim pnode, nd, deeps, explan, pnodevalue
		Dim i, ii
		id = app.gettext("id")
		itemid = app.gettext("itemid")
		autosql = app.base64.decode(app.gettext("autosql"))
		pagesize = app.getint("pagesize")
		pageindex = app.getint("pageindex")
		deepdata = app.gettext("deepdata")
		pnodevalue = app.getText("pnodevalue")
		explan = (app.getint("explan")<>0)
		Set tvw = New treeview
		tvw.id = id
		tvw.pagesize = pagesize
		tvw.checkbox =  (app.getint("checkbox") = 1)
		If itemid = id Then
			If app.getText("pdm") = "all" Then
				Call tvw.addAllNodes(tvw.nodes, autosql, explan, pageindex, pnodevalue)
			else
				Call tvw.addnodes(tvw.nodes, autosql, explan, pageindex)
			end if
			Response.write tvw.nodes.innerHTML(Replace(itemid,"_n",""))
		else
			deeps = Split(Replace(Replace(itemid,id & "_",""),"_n",""),"_")
			Set pnode = tvw
			For i = 0 To ubound(deeps)
				For ii = 0 To deeps(i)
					Set nd = pnode.nodes.add()
				next
				Set pnode = nd
			next
			If app.getText("pdm") = "all" Then
				Call tvw.addAllNodes(nd.nodes, autosql, explan, pageindex, pnodevalue)
			else
				Call tvw.addnodes(nd.nodes, autosql, explan, pageindex)
			end if
			Response.write nd.nodes.innerHTML(Replace(itemid,"_n",""))
		end if
	end sub
	sub app_sys_treeviewCallBack
		dim id, cmd
		id = request.form("id")
		cmd = request.form("cmd")
		Select Case cmd
		Case "doPageSize"
		Call app_sys_tvw_doPageSize()
		Case Else
		execute "call " & id & "_ctree"
		End select
	end sub
	
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
	
	Dim remark, bomord
	Dim isCopy:isCopy = False
	Dim isUpdate:isUpdate = False
	Sub Bill_OnPageInit
		Response.write "" & vbcrlf & "       <style>" & vbcrlf & "         html{padding:0px 10px;background:#EFEFEF}" & vbcrlf & "               #lvw_tby_bllst_clist > tr ,.fcell .listview,.lvw_tablebg .lvwframe2.detailTableList >tbody >tr{border-top:1px solid #ccc}" & vbcrlf & "       </style>" & vbcrlf & "        "
'Sub Bill_OnPageInit
		Dim css
		css = "<link href='BomList_Add.css' rel='stylesheet' type='text/css' />"
		Response.write(css)
		Dim JS
		JS = "<script>bomadd.ord = '" & request("bomord") & "';</script>"
		Response.write(JS)
	end sub
	Sub Bill_OnInit(ByVal Bill, ByVal initType)
		app.addDefaultScript()
		bill.loadEasyUI = True
		bill.reBackApprove = True
		bomord = app.base64.deurl(app.getText("bomord"))
		If isnumeric(bomord & "") = False Then
			bomord = "0"
		end if
		dim rs, edit, add
		edit = app.getint("edit")
		If edit = "0" Then
			edit = True
		else
			edit = False
		end if
		bill.edit = edit
		add = app.getint("add")
		If add = "0" Then
			add = True
		else
			add = False
		end if
		If bomord > 0 And edit = False Then
			bill.title = "组装清单详情"
			Call bill.setBillId(bomord)
		ElseIf bomord > 0 And add = False Then
			bill.title = "组装清单修改"
			bill.setBillId(bomord)
			isUpdate = True
		ElseIf bomord > 0 And add = True Then
			bill.title = "组装清单复制"
			isCopy = True
		else
			bill.title = "组装清单添加"
		end if
		Dim title, BBH, BH, date1, sxDate, zfDate, mainBOM, zdy1, zdy2, zdy3, zdy4, zdy5, zdy6, cateid_sp, Creator
		date1 = now()
		sxDate       = now()
		zfDate       = dateadd("yyyy",1,now())
		mainBOM = 0
		If bomord > 0 Then
			Set rs = cn.execute("select b.*,g.name cateid_sp_name from BOM_Structure_Info b left join gate g on g.ord = b.cateid_sp where b.ord = " & bomord)
			If rs.eof = False Then
				title        = rs("title")
				If isCopy = True Then
					title = "复制：" & title
				end if
				BH           = rs("BH")
				date1        = rs("addDate")
				If isCopy = True Then
					date1        = now()
					BBH          = ""
					sxDate       = rs("sxDate")
					zfDate       = rs("zfDate")
				else
					BBH          = rs("BBH")
					sxDate       = rs("sxDate")
					zfDate       = rs("zfDate")
				end if
				mainBOM      = rs("ismain")
				remark       = rs("remark")
				zdy1 = rs("zdy1")
				zdy2 = rs("zdy2")
				zdy3 = rs("zdy3")
				zdy4 = rs("zdy4")
				zdy5 = rs("zdy5")
				zdy6 = rs("zdy6")
				cateid_sp = rs("cateid_sp_name")
				Creator = rs("addcate")
			else
				title        = ""
				BBH          = ""
				BH           = ""
				date1        = now()
				sxDate       = ""
				zfDate       = ""
				mainBOM      = ""
				remark       = ""
				zdy1 = ""
				zdy2 = ""
				zdy3 = ""
				zdy4 = ""
				zdy5 = ""
				zdy6 = ""
				cateid_sp = ""
				Creator = ""
			end if
			rs.close
			set rs = nothing
		end if
		If edit = False Then
			bill.buttons.getItemByDbname("save").topvisible = False
			bill.buttons.getItemByDbname("save").bottomvisible = False
			bill.buttons.getItemByDbname("reset").topvisible = False
			bill.buttons.getItemByDbname("reset").bottomvisible = False
			bill.canapprove = True
			If app.power.existsPower(56,13) Then
				bill.Buttons.add "复制", "copy", "bomadd.copy(this)", true, False
			end if
			If app.power.existsPowerIntro(56,2,Creator) Then
				bill.Buttons.add "修改", "edit", "bomadd.edit(this)", true, False
			end if
		end if
		dim f
		Set f = Bill.fields.add("组装清单名称", "title")
		f.notnull = True
		f.value = title
		f.defvalue = title
		f.maxlimit = 100
		Set f = Bill.fields.add("版本号", "BBH")
		f.notnull = True
		f.value = BBH
		f.defvalue = BBH
		f.maxlimit = 25
		If add Or isCopy Then
			set rs = cn.execute("EXEC erp_getdjbh 8040," & Info.User & " ")
			bh=rs(0).value
			set rs=Nothing
		end if
		If add = False Then
			remark = "<div class='ewebeditorImg'>" & remark & "</div>"
		end if
		Set f = Bill.fields.add("组装清单编号", "BH")
		f.value = bh
		f.defvalue = bh
		f.notnull = true
		f.maxlimit = 50
		Set f = Bill.fields.add("添加日期", "date1")
		f.notnull = True
		f.value = date1
		f.defvalue = date1
		f.uitype = "date"
		Set f = Bill.fields.add("生效日期", "sxDate")
		f.notnull = True
		f.value = sxDate
		f.defvalue = sxDate
		f.uitype = "date"
		Set f = Bill.fields.add("作废日期", "zfDate")
		f.notnull = True
		f.value = zfDate
		f.defvalue = zfDate
		f.uitype = "date"
		Set f = Bill.fields.add("是否是主BOM", "mainBOM")
		f.value = mainBOM
		f.defvalue = mainBOM
		f.notnull = true
		f.uitype = "radio"
		f.source = "options:主BOM=1,副BOM=0"
		If edit = False And bomord > 0 Then
			Set f = Bill.fields.add("当前审批人", "cateid_sp")
			f.value = cateid_sp
			f.defvalue = cateid_sp
			f.maxlimit = 200
		end if
		If bomord > 0 Then
			Dim rsZdy, v
			Set rsZdy = cn.execute("select * from zdy where sort1 = 8040 and set_open = 1 order by gate1")
			While rsZdy.eof = False
				execute("v = " & rsZdy("name"))
				Set f = Bill.fields.add(rsZdy("title"), rsZdy("name"))
				f.value = v
				f.defvalue = v
				If rsZdy("name") = "zdy5" Or rsZdy("name") = "zdy6" Then
					f.uitype = "select"
					f.source = "sql:select sort1,ord from sortonehy where gate2 = " & rsZdy("gl")
				else
					f.uitype = "text"
					f.maxlimit = 50
				end if
				rsZdy.movenext
			wend
			rsZdy.close
			Set rsZdy = Nothing
			bill_OnloadAfterExtra(bill)
		else
			bill.extra = 8040
		end if
		bill.approve = 8040
	end sub
	Sub bill_OnloadAfterExtra(ByVal bill)
		dim rs, edit, add, sql
		edit = app.getint("edit")
		If edit = "0" Then
			edit = True
		else
			edit = False
		end if
		bomord = app.getText("bomord")
		If IsNumeric(bomord & "") = False Then
			if len(bomord)>0 then
				bomord = app.base64.deurl(app.getText("bomord"))
				If IsNumeric(bomord & "") = False Then
					bomord = 0
				end if
			else
				bomord = 0
			end if
		end if
		Dim proName, ProOrd, ProType, proBH, proXH, proUnit, proNum, proSX, sproType, proCode, sCode, zdy1, zdy2, zdy3, zdy4, zdy5, zdy6, unitAll, unit
		dim includeTax, sumPriceXS, sumPriceBZ, sumPriceCB
		proNum      = "1" : includeTax = 1 : sumPriceXS = 0 : sumPriceBZ = 0 : sumPriceCB = 0
		If bomord > 0 Then
			sql = "select " &_
			"  case b.ProType when 0 then pn.name else p.title end proName, " &_
			"  b.ProOrd,b.ProType, " &_
			"  case b.protype when 0 then '--' else p.order1 end proBH, " &_
			"  case b.protype when 0 then '--' else p.type1 end proXH, " &_
			"  case b.protype when 0 then '--' else u.sort1 end proUnit, " &_
			"  b.ProductAttr1,b.ProductAttr2,sg1.Title ProductAttr1Name,sg2.Title ProductAttr2Name, " &_
			"  case b.protype when 0 then '--' else u.sort1 end proUnit, " &_
			"  b.num proNum, b.unit, " &_
			"  b.includeTax, b.PriceXS sumPriceXS, b.PriceBZ sumPriceBZ, b.PriceJY sumPriceCB, " &_
			"  case b.protype when 0 then '--' else case p.canOutStore when 0 then '虚拟' else '实体' end end proSX, " &_
			"  isnull(b.sType,0) sproType,c.title proCode,isnull(b.sCode,0) sCode, " &_
			"  p.zdy1,p.zdy2,p.zdy3,p.zdy4,z5.sort1 zdy5,z6.sort1 zdy6,p.unit unitAll " &_
			" from  " &_
			" (select * from BOM_Structure_List where bomOrd = " & bomord & " and isMain = 1) b " &_
			" left join product p on p.ord = b.ProOrd and b.ProType = 1 " &_
			" left join Bom_ProName pn on pn.ord = b.ProOrd and b.ProType = 0 " &_
			" left join sortonehy z5 on z5.ord = p.zdy5 " &_
			" left join sortonehy z6 on z6.ord = p.zdy6 " &_
			" left join sortonehy u on u.ord = b.unit " &_
			" left join Shop_GoodsAttr sg1 on sg1.id=b.ProductAttr1 " &_
			" left join Shop_GoodsAttr sg2 on sg2.id=b.ProductAttr2 " &_
			" left join (select * from Bom_Code where isMain = 0) c on b.sCode = c.ord "
			Set rs = cn.execute(sql)
			If rs.eof = False Then
				proName     = rs("proName")
				ProOrd      = rs("ProOrd")
				ProType     = rs("ProType")
				proBH       = rs("proBH")
				proXH       = rs("proXH")
				proUnit     = rs("proUnit")
				unit        = rs("unit")
				includeTax  = rs("includeTax") : sumPriceXS       = rs("sumPriceXS") : sumPriceBZ       = rs("sumPriceBZ") : sumPriceCB       = rs("sumPriceCB")
				proNum      = rs("proNum")
				proSX       = rs("proSX")
				sproType    = rs("sproType")
				proCode     = rs("proCode")
				sCode       = rs("sCode")
				zdy1        = rs("zdy1")
				zdy2        = rs("zdy2")
				zdy3        = rs("zdy3")
				zdy4        = rs("zdy4")
				zdy5        = rs("zdy5")
				zdy6        = rs("zdy6")
				unitAll     = rs("unitAll")
				ProductAttr1Name    = rs("ProductAttr1Name")
				ProductAttr2Name    = rs("ProductAttr2Name")
				ProductAttr1        = rs("ProductAttr1")
				ProductAttr2        = rs("ProductAttr2")
			else
				proName     = ""
				ProOrd      = ""
				ProType     = ""
				proBH       = ""
				proXH       = ""
				proUnit     = ""
				unit        = ""
				proNum      = "1"
				proSX       = ""
				sproType    = ""
				proCode     = ""
				sCode       = ""
				zdy1        = ""
				zdy2        = ""
				zdy3        = ""
				zdy4        = ""
				zdy5        = ""
				zdy6        = ""
				unitAll     = ""
				ProductAttr1Name=""
				ProductAttr2Name=""
				ProductAttr1 =0
				ProductAttr2 =0
			end if
			rs.close
			set rs = nothing
		end if
		If app.power.existsPower(21,14) And Len(ProOrd & "") > 0 And ProType = "1" And edit = False Then
			proName = "<a href='../product/content.asp?ord=" & app.base64.pwurl(ProOrd) & "' target='_blank'>" & proName & "</a>"
		end if
		Call Bill.AddCurrGroup("父件信息", "p_ExecBody")
		Dim f
		Set f = Bill.fields.add("产品名称", "p_proName")
		f.uitype = "text"
		f.value = proName
		f.defvalue = proName
		f.notnull = True
		f.OnlyRead = True
		f.maxlimit = 2000
		f.canconvertHTML = False
		f.js = " onclick='bomadd.showProductSelect(this)' "
		Set f = Bill.fields.add("产品ord", "p_proOrd")
		f.value = proOrd
		f.defvalue = proOrd
		f.uitype = "hidden"
		Set f = Bill.fields.add("产品类型", "p_pType")
		f.value = ProType
		f.defvalue = ProType
		f.uitype = "hidden"
		Set f = Bill.fields.add("产品编号", "p_proBH")
		f.value = "<span id='p_proBH'>" & proBH & "</span>"
		f.uitype = "html"
		Set f = Bill.fields.add("产品型号", "p_proXH")
		f.value = "<span id='p_proXH'>" & proXH & "</span>"
		f.uitype = "html"
		Set f = Bill.fields.add("产品单位", "p_proUnit")
		f.value = proUnit
		f.defvalue = proUnit
		If isCopy = True Or isUpdate = True Then
			f.value = unit
			f.defvalue = unit
		end if
		f.notnull = True
		If edit Then
			f.uitype = "select"
			If Len(unitAll & "") > 0 Then
				f.source = "sql:select sort1,ord from sortonehy where gate2 = 61 and ord in (" & unitAll & ")"
			else
				f.source = "sql:select '请选择产品单位',null"
			end if
		else
			f.uitype = "text"
		end if
		If ProType & "" = "0" Then
			f.onlyread = True
			f.notnull = False
		end if
		set rs7 = ProductAttrsByOrd(app.iif(ProOrd&""="",0,ProOrd))
		dim attrNameArray(1)
		i=0
		attrNameArray(0)="产品属性1"
		attrNameArray(1)="产品属性2"
		if rs7.eof or ProOrd&""="" then
		else
			do until rs7.eof
				isTiled=rs7("isTiled")
				if isTiled=1 then
					attrNameArray(0)=rs7("title").value
				end if
				if isTiled=0 then
					attrNameArray(1)=rs7("title").value
				end if
				i=i+1
				attrNameArray(1)=rs7("title").value
				rs7.movenext
			loop
		end if
		Set f = Bill.fields.add(attrNameArray(0), "p_ProductAttr1Name")
		f.value = ProductAttr1Name
		f.defvalue = ProductAttr1Name
		If isCopy = True Or isUpdate = True Then
			f.value = ProductAttr1
			f.defvalue = ProductAttr1
		end if
		f.notnull = false
		If isOpenProductAttr = False Then
			f.uitype = "hidden"
		end if
		If edit Then
			f.uitype = "select"
			if ProOrd&""="" then ProOrd=0
			f.source = "sql:select '' as title,0 as id union all                                                          "&_
			"   select st.title,st.id                                                                                                                               "&_
			"   from shop_goodsattr sx                                                                                                                     "&_
			"   inner join (                                                                                                                               "&_
			"       select p1.ord,(case when exists(select 1 from shop_goodsattr where proCategory = m.rootid) then m.rootid else -1 end) cp_sort1         "&_
			"       from product p1                                                                                                                        "&_
			"       inner join menu m on m.id = p1.sort1 where p1.ord ="&ProOrd&"                                                                               "&_
			"   ) s on s.cp_sort1 = sx.proCategory                                                                                                         "&_
			"   inner join Shop_GoodsAttr st on st.proCategory = s.cp_sort1 and st.pid <> 0 and st.isStop=0  and sx.id=st.pid                              "&_
			"   where sx.pid = 0 and sx.isTiled=1"
		else
			f.uitype = "text"
		end if
		If isOpenProductAttr = False Then
			f.uitype = "hidden"
		end if
		Set f = Bill.fields.add(attrNameArray(1), "p_ProductAttr2Name")
		f.value = ProductAttr2Name
		f.defvalue = ProductAttr2Name
		If isCopy = True Or isUpdate = True Then
			f.value = ProductAttr2
			f.defvalue = ProductAttr2
		end if
		f.notnull = false
		If edit Then
			f.uitype = "select"
			if ProOrd&""="" then ProOrd=0
			f.source = "sql:select '' as title,0 as id union all                                                          "&_
			"   select st.title,st.id                                                                                                                               "&_
			"   from shop_goodsattr sx                                                                                                                     "&_
			"   inner join (                                                                                                                               "&_
			"       select p1.ord,(case when exists(select 1 from shop_goodsattr where proCategory = m.rootid) then m.rootid else -1 end) cp_sort1         "&_
			"       from product p1                                                                                                                        "&_
			"       inner join menu m on m.id = p1.sort1 where p1.ord ="&ProOrd&"                                                                               "&_
			"   ) s on s.cp_sort1 = sx.proCategory                                                                                                         "&_
			"   inner join Shop_GoodsAttr st on st.proCategory = s.cp_sort1 and st.pid <> 0 and st.isStop=0  and sx.id=st.pid                              "&_
			"   where sx.pid = 0 and sx.isTiled=0"
		else
			f.uitype = "text"
		end if
		If isOpenProductAttr = False Then
			f.uitype = "hidden"
		end if
		Set f = Bill.fields.add("数量", "P_proNum")
		f.value = proNum
		f.defvalue = proNum
		f.uitype = "html"
		Set f = Bill.fields.add("产品属性", "p_proSX")
		f.value = "<span id='p_proSX'>" & proSX & "</span>"
		f.uitype = "html"
		Set f = Bill.fields.add("是否含税", "includeTax")
		f.value = includeTax
		f.defvalue = includeTax
		f.uitype = "radio"
		f.source = "options:是=1,否=0"
		Set f = Bill.fields.add("销售价之和", "sumPriceXS")
		f.uitype = app.iif(app.power.existsPower(21,22),"money","hidden")
		f.dbtype = "salesprice"
		f.onlyread = True
		f.defvalue = sumPriceXS
		Set f = Bill.fields.add("标准价之和", "sumPriceBZ")
		f.uitype = app.iif(app.power.existsPower(21,22),"money","hidden")
		f.dbtype = "salesprice"
		f.onlyread = True
		f.defvalue = sumPriceBZ
		Set f = Bill.fields.add("结构类型", "p_proType")
		f.uitype = "select"
		f.value = sproType
		f.defvalue = sproType
		If edit Then
			f.source = "sql:select '请选择结构类型' title,null ord,999 gate1 union all select title,ord,gate1 from Bom_Code where isMain = 1 order by gate1 desc,ord desc"
		else
			f.source = "sql:select '' title,0 ord,999 gate1 union all select title,ord,gate1 from Bom_Code where isMain = 1 order by gate1 desc,ord desc"
		end if
		f.js = "onchange='bomadd.ChangeProType(this)' "
		Set f = Bill.fields.add("结构编码", "p_proCode")
		f.value = proCode
		f.defvalue = proCode
		If edit Then
			f.uitype = "select"
			If edit And bomord > 0 Then
				f.value = sCode
				f.defvalue = sCode
				f.source = "sql:select title,ord from bom_code where p_ord = " & sproType
			else
				f.source = "sql:select '请选择结构编码',null"
			end if
		else
			f.uitype = "text"
		end if
		Set f = Bill.fields.add("成本价之和", "sumPriceCB")
		f.dbtype = "money"
		f.uitype = app.iif(app.power.existsPower(21,21),"money","hidden")
		f.onlyread = True
		f.defvalue = sumPriceCB
		Dim v
		Set rs = cn.execute("select name, title from zdy where sort1 = 21 and set_open = 1 order by gate1")
		While rs.eof = False
			execute("v = " & rs("name"))
			With Bill.fields.add(rs("title"), "p_" & rs("name") & "_21")
			If ProType & "" = "0" Then
				.value = "<span id='p_" & rs("name") & "_21'>--</span>"
'If ProType & "" = "0" Then
			else
				.value = "<span id='p_" & rs("name") & "_21'>" & v & "</span>"
			end if
			.uitype = "html"
			End With
			rs.movenext
		wend
		rs.close
		set rs = nothing
		Call Bill.AddCurrGroup("子件信息", "s_ExecBody")
		Dim html, titles, lens, i
		Set f = Bill.fields.addListView("","clist")
		Call Bill.AddCurrGroup("备注信息", "r_ExecBody")
		Set f = Bill.fields.add("", "remark")
		f.colspan = 3
		f.value = remark
		f.defvalue = remark
		f.uitype = "editor"
		f.maxlimit = 2000
		Dim a : a = Split("sType,notNull,canEdit,proOrd,proType,unit,num,sProType,sCode,PriceXS,PriceBZ,PriceJY,ProductAttr1,ProductAttr2",",")
		For i = 0 To ubound(a)
			With Bill.fields.add("s_" & a(i), "s_" & a(i))
			.uitype = "hidden"
			.maxlimit = "99999999999"
			End With
		next
		With Bill.fields.add("edit","edit")
		.uitype = "hidden"
		.maxlimit = "9999999"
		.value = app.getInt("edit")
		.defvalue = app.getInt("edit")
		End With
		With Bill.fields.add("add","add")
		.uitype = "hidden"
		.maxlimit = "9999999"
		.value = app.getInt("add")
		.defvalue = app.getInt("add")
		End With
		With Bill.fields.add("bomord","bomord")
		.uitype = "hidden"
		.maxlimit = "9999999"
		.value = bomord
		.defvalue = bomord
		End With
	end sub
	sub bill_onListCreate(byref field, byref lvw)
		Dim edit
		edit = app.getint("edit")
		If edit = "0" Then
			edit = True
		else
			edit = False
		end if
		lvw.colResize = True
		If bomord = 0 Then
			lvw.jsonEditModel =  True
			lvw.sql = "select 0 类型,1 必选,NULL 编辑,'' 产品名称 ,0 proOrd, 0 proType, NULL 产品编号, NULL 产品型号, NULL 单位,0 产品属性1,0 产品属性2,0 ProductAttr1OptionIds,0 ProductAttr2OptionIds , NULL 单位值, 1 as 数量, 0 销售单价, 0 标准单价, 0 建议进价, NULL 产品属性, NULL 结构类型, NULL 结构编码"
		else
			lvw.edit = edit
			If edit Then
				lvw.jsonEditModel =  True
				lvw.sql = " select " &_
				"   b.sProType  类型, " &_
				"   b.notNull 必选, " &_
				"   b.canEdit 编辑, " &_
				"   case b.protype when 0 then pn.name else p.title end 产品名称, " &_
				"   b.proOrd,b.proType, " &_
				"   case b.protype when 0 then '--' else p.order1 end 产品编号, " &_
				"   b.proOrd,b.proType, " &_
				"   case b.protype when 0 then '--' else p.type1 end 产品型号, " &_
				"   b.proOrd,b.proType, " &_
				"   b.unit 单位, " &_
				"   b.ProductAttr1 产品属性1, " &_
				"   b.ProductAttr2 产品属性2, " &_
				"   (select cast(id as varchar(10))+',' from (select 0 as id union all                                                                                                   "&_
				"   b.ProductAttr2 产品属性2, " &_
				"   select st.id                                                                                                               "&_
				"   from shop_goodsattr sx                                                                                                     "&_
				"   inner join (                                                                                                               "&_
				"       select p1.ord,(case when exists(select 1 from shop_goodsattr where proCategory = m.rootid) then m.rootid else -1 end) cp_sort1  "&_
				"       from product p1                                                                                                         "&_
				"       inner join menu m on m.id = p1.sort1 where p1.ord =p.ord                                                                   "&_
				"   ) s on s.cp_sort1 = sx.proCategory                                                                                         "&_
				"   inner join Shop_GoodsAttr st on st.proCategory = s.cp_sort1 and st.pid <> 0 and st.isStop=0  and sx.id=st.pid             "&_
				"   where sx.pid = 0 and sx.isTiled =1 )t  for xml path('')) as ProductAttr1OptionIds,"&_
				"   (select cast(id as varchar(10))+',' from (select 0 as id union all                                                                                                   "&_
				"   where sx.pid = 0 and sx.isTiled =1 )t  for xml path('')) as ProductAttr1OptionIds,"&_
				"   select st.id                                                                                                               "&_
				"   from shop_goodsattr sx                                                                                                     "&_
				"   inner join (                                                                                                               "&_
				"       select p1.ord,(case when exists(select 1 from shop_goodsattr where proCategory = m.rootid) then m.rootid else -1 end) cp_sort1  "&_
				"       from product p1                                                                                                         "&_
				"       inner join menu m on m.id = p1.sort1 where p1.ord =p.ord                                                                   "&_
				"   ) s on s.cp_sort1 = sx.proCategory                                                                                         "&_
				"   inner join Shop_GoodsAttr st on st.proCategory = s.cp_sort1 and st.pid <> 0 and st.isStop=0  and sx.id=st.pid "&_
				"   where sx.pid = 0 and sx.isTiled =0 )t  for xml path('')) as ProductAttr2OptionIds,"&_
				"   case b.protype when 0 then '--' else p.unit end 单位值, " &_
				"   where sx.pid = 0 and sx.isTiled =0 )t  for xml path('')) as ProductAttr2OptionIds,"&_
				"   b.num 数量, " &_
				"   b.PriceXS 销售单价, " &_
				"   b.PriceBZ 标准单价, " &_
				"   b.PriceJY 建议进价, " &_
				"   case b.protype when 0 then '--' else case p.canOutStore when 0 then '虚拟' else '实体' end end 产品属性, " &_
				"   b.PriceJY 建议进价, " &_
				"   isnull(b.sType,0) 结构类型,isnull(b.sCode,0) 结构编码 " &_
				" from " &_
				" (select * from BOM_Structure_List where del in (1,2) and bomOrd = " & bomord & " and isMain = 0) b " &_
				" left join product p on p.ord = b.ProOrd and b.ProType = 1 " &_
				" left join Bom_ProName pn on pn.ord = b.ProOrd and b.ProType = 0 " &_
				" left join (select * from Bom_Code where isMain = 1) t on b.sProType = t.ord " &_
				" left join (select * from Bom_Code where isMain = 0) c on b.sCode = c.ord order by b.ord "
			else
				lvw.sql = " select " &_
				"   b.sProType  类型, " &_
				"   case b.notNull when 0 then '否' when 1 then '是' end 必选, " &_
				"  case b.canEdit when 0 then '否' when 1 then '是' end 编辑, " &_
				"  case b.protype when 0 then pn.name else p.title end 产品名称, " &_
				"  b.proOrd,b.proType, " &_
				"  case b.protype when 0 then '--' else p.order1 end 产品编号, " &_
				"  b.proOrd,b.proType, " &_
				"  case b.protype when 0 then '--' else p.type1 end 产品型号, " &_
				"  b.proOrd,b.proType, " &_
				"  case b.protype when 0 then '' else b.unit end 单位, " &_
				"  b.ProductAttr1 产品属性1, " &_
				"  b.ProductAttr2 产品属性2, " &_
				"  (select cast(id as varchar(10))+',' from (select 0 as id union all                                                                                                   "&_
				"  b.ProductAttr2 产品属性2, " &_
				"   select st.id                                                                                                               "&_
				"   from shop_goodsattr sx                                                                                                     "&_
				"   inner join (                                                                                                               "&_
				"       select p1.ord,(case when exists(select 1 from shop_goodsattr where proCategory = m.rootid) then m.rootid else -1 end) cp_sort1  "&_
				"       from product p1                                                                                                         "&_
				"       inner join menu m on m.id = p1.sort1 where p1.ord =p.ord                                                                   "&_
				"   ) s on s.cp_sort1 = sx.proCategory                                                                                         "&_
				"   inner join Shop_GoodsAttr st on st.proCategory = s.cp_sort1 and st.pid <> 0 and st.isStop=0  and sx.id=st.pid             "&_
				"   where sx.pid = 0 and sx.isTiled =1 )t  for xml path('')) as ProductAttr1OptionIds,"&_
				"  (select cast(id as varchar(10))+',' from (select 0 as id union all                                                                                                   "&_
				"   where sx.pid = 0 and sx.isTiled =1 )t  for xml path('')) as ProductAttr1OptionIds,"&_
				"   select st.id                                                                                                               "&_
				"   from shop_goodsattr sx                                                                                                     "&_
				"   inner join (                                                                                                               "&_
				"       select p1.ord,(case when exists(select 1 from shop_goodsattr where proCategory = m.rootid) then m.rootid else -1 end) cp_sort1  "&_
				"       from product p1                                                                                                         "&_
				"       inner join menu m on m.id = p1.sort1 where p1.ord =p.ord                                                                   "&_
				"   ) s on s.cp_sort1 = sx.proCategory                                                                                         "&_
				"   inner join Shop_GoodsAttr st on st.proCategory = s.cp_sort1 and st.pid <> 0 and st.isStop=0  and sx.id=st.pid "&_
				"   where sx.pid = 0 and sx.isTiled =0 )t  for xml path('')) as ProductAttr2OptionIds,"&_
				"  case b.protype when 0 then '--' else p.unit end 单位值, " &_
				"   where sx.pid = 0 and sx.isTiled =0 )t  for xml path('')) as ProductAttr2OptionIds,"&_
				"  b.num 数量, " &_
				"  b.PriceXS 销售单价, " &_
				"  b.PriceBZ 标准单价, " &_
				"  b.PriceJY 建议进价, " &_
				"  case b.protype when 0 then '--' else case p.canOutStore when 0 then '虚拟' else '实体' end end 产品属性, " &_
				"  b.PriceJY 建议进价, " &_
				"  t.title 结构类型,c.title 结构编码 " &_
				" from " &_
				" (select * from BOM_Structure_List where del in (1,2) and bomOrd = " & bomord & " and isMain = 0) b " &_
				" left join product p on p.ord = b.ProOrd and b.ProType = 1 " &_
				" left join Bom_ProName pn on pn.ord = b.ProOrd and b.ProType = 0 " &_
				" left join (select * from Bom_Code where isMain = 1) t on b.sType = t.ord " &_
				" left join (select * from Bom_Code where isMain = 0) c on b.sCode = c.ord order by b.ord"
			end if
		end if
		lvw.toolbar = true
		lvw.checkbox = false
		lvw.allsum = true
		lvw.indexbox = True
		lvw.headers("@@序号").width = 65
		With lvw.headers("类型")
		.width = 100
		.uiType = "select"
		.source = "options:固定=0,单选=1,复选=2"
		.cansum = False
		End With
		With lvw.headers("必选")
		.width = 80
		.uiType = "checkbox"
		.EditLock = "code:""@cells[""类型""]""==0"
		.defaultvalue = "1"
		.canBatchInput = 1
		.cansum = False
		End With
		With lvw.headers("编辑")
		.width = 80
		.uiType = "checkbox"
		.cansum = False
		End With
		With lvw.headers("产品名称")
		.width = 130
		.uitype = "text"
		.notnull = True
		.source = "script:window.open('add_top.asp','bom_list_add_top','width=1300,height=650,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=0,top=100')"
		.EditLock = "lock"
		.canBatchInput = 1
		.formattext = "code:ListCellsFormat(""产品名称"",rs)"
		.cansum = False
		End With
		With lvw.headers("proOrd")
		.uitype = "text"
		.display = "none"
		.cansum = False
		End With
		With lvw.headers("proType")
		.uitype = "text"
		.display = "none"
		.cansum = False
		End With
		With lvw.headers("ProductAttr1OptionIds")
		.uitype = "text"
		.display = "none"
		.cansum = False
		End With
		With lvw.headers("ProductAttr2OptionIds")
		.uitype = "text"
		.display = "none"
		.cansum = False
		End With
		With lvw.headers("产品编号")
		.width = 130
		.canBatchInput = 1
		.cansum = False
		End With
		With lvw.headers("产品型号")
		.width = 130
		.canBatchInput = 1
		.cansum = False
		End With
		With lvw.headers("单位")
		.width = 90
		.uiType = "select"
		.source = "sortonehy:61;filter:单位值"
		.notnull = True
		.cansum = False
		.canBatchInput = 1
		.EditLock = "code:@cells[""proType""]==""0""||@cells[""proType""]=="""""
		End With
		With lvw.headers("单位值")
		.width = 90
		.uiType = "text"
		.display = "none"
		.cansum = False
		End With
		With lvw.headers("产品属性1")
		.width = 90
		.uiType = "select"
		.source = "select '' as title, 0 as id union all "&_
		" select st.title ,st.id from Shop_GoodsAttr st;filter:ProductAttr1OptionIds"
		.notnull = false
		.cansum = False
		.canBatchInput = 1
		If isOpenProductAttr = False Then
			.display = "none"
		end if
		End With
		With lvw.headers("产品属性2")
		.width = 90
		.uiType = "select"
		.source = "select '' as title, 0 as id union all "&_
		" select st.title ,st.id from Shop_GoodsAttr st;filter:ProductAttr2OptionIds"
		.notnull = false
		.cansum = False
		.canBatchInput = 1
		If isOpenProductAttr = False Then
			.display = "none"
		end if
		End With
		With lvw.headers("数量")
		.width = 90
		.uiType = "number"
		.dbtype = "number"
		.notnull = True
		.defaultvalue = 1
		End With
		With lvw.headers("销售单价")
		.width = 90
		.uiType = "money"
		.dbtype = "salesprice"
		.defaultvalue = 0
		If app.power.existsPower(21,22) = False Then
			.display = "none"
		end if
		End With
		With lvw.headers("标准单价")
		.width = 90
		.uiType = "money"
		.dbtype = "salesprice"
		.defaultvalue = 0
		If app.power.existsPower(21,22) = False Then
			.display = "none"
		end if
		End With
		With lvw.headers("建议进价")
		.width = 90
		.uiType = "money"
		.dbtype = "storeprice"
		.defaultvalue = 0
		If app.power.existsPower(21,21) = False Then
			.display = "none"
		end if
		End With
		With lvw.headers("产品属性")
		.width = 100
		.canBatchInput = 1
		.cansum = False
		End With
		With lvw.headers("结构类型")
		.width = 100
		.cansum = False
		If edit Then
			.uiType = "select"
			Dim tvw,  rs, nd, nd1, rs2
			Set tvw = .createTreeSource
			Set rs = cn.execute("select title,ord from " &_
			"  ( " &_
			"          select title,ord,gate1 from Bom_Code where isMain = 1 " &_
			"          union all " &_
			"          select '请选择',0,99999 " &_
			"  ) x " &_
			"  order by gate1 desc,ord desc ")
			While rs.eof = False
				Set nd = tvw.nodes.add
				nd.Text = rs(0).value
				nd.value = rs(1).value
				Set rs2 = cn.execute("select title,ord from " &_
				"  (       " &_
				"          select title, ord,gate1 from Bom_Code where isMain=0 and p_ord = " & rs(1) & " " &_
				"          union all " &_
				"          select '请选择',0,99999 " &_
				"  ) x " &_
				"  order by gate1 desc,ord desc ")
				While rs2.eof = False
					Set nd1 = nd.nodes.add
					nd1.Text = rs2(0).value
					nd1.value = rs2(1).value
					rs2.movenext
				wend
				rs2.close
				rs.movenext
			wend
			rs.close
			set rs = nothing
		else
			.uitype = "text"
		end if
		End With
		With lvw.headers("结构编码")
		.width = 100
		.cansum = False
		If edit Then
			.source = "treenode:结构类型"
			.uiType = "select"
		else
			.uiType = "text"
		end if
		End With
	end sub
	Function Bill_OnSave(ByVal bill)
		Dim b_Title, b_BBH, b_BH, b_addCate, b_sxDate, b_zfDate, b_isMain, b_remark
		b_Title             = app.getText("title")
		b_BBH               = app.getText("BBH")
		b_BH                = app.getText("BH")
		b_addCate   = app.getText("date1")
		b_sxDate    = app.getText("sxDate")
		b_zfDate    = app.getText("zfDate")
		b_isMain    = app.getText("mainBOM")
		b_remark    = app.getText("remark")
		b_remark    = Left(b_remark,2000)
		bomord = app.getText("bomord")
		Dim p_proOrd, p_pType, p_proUnit, p_proType, p_proCode, includeTax, sumPriceXS, sumPriceBZ, sumPriceCB
		p_proOrd    = app.getText("p_proOrd")
		p_pType             = app.getText("p_pType")
		p_proUnit   = app.getText("p_proUnit")
		p_proType   = app.getText("p_proType")
		p_proCode   = app.getText("p_proCode")
		includeTax  = app.getInt("includeTax")
		p_ProductAttr1Name  = app.getInt("p_ProductAttr1Name")
		p_ProductAttr2Name  = app.getInt("p_ProductAttr2Name")
		sumPriceXS  = app.getText("sumPriceXS")
		sumPriceBZ  = app.getText("sumPriceBZ")
		sumPriceCB  = app.getText("sumPriceCB")
		If includeTax&"" = "" Then includeTax = 0
		If sumPriceXS&"" = "" Then sumPriceXS = 0
		If sumPriceBZ&"" = "" Then sumPriceBZ = 0
		If sumPriceCB&"" = "" Then sumPriceCB = 0
		If p_ProductAttr1Name&"" = "" Then p_ProductAttr1Name = 0
		If p_ProductAttr2Name&"" = "" Then p_ProductAttr2Name = 0
		Dim add, edit
		add = app.getInt("add")
		edit= app.getInt("edit")
		Dim rs, rsZdy, sql
		If add = "0" Then
			sql = "select * from BOM_Structure_Info where BH = '" & b_BH & "'"
		Else
			sql = "select * from BOM_Structure_Info where BH = '" & b_BH & "' and ord <> " & bomord
		end if
		Set rs = cn.execute(sql)
		If rs.eof = False Then
			bill.alert("组装清单编号已存在！")
			Bill_OnSave = False
			Exit Function
		end if
		rs.close
		set rs = nothing
		If add = "0" Then
			sql = "select * from BOM_Structure_Info where BBH = '" & Replace(b_BBH,"'","""") & "' and ProOrd = " & p_proOrd & " and pType = " & p_pType
		Else
			sql = "select * from BOM_Structure_Info where BBH = '" & Replace(b_BBH,"'","""") &"' and ProOrd = " & p_proOrd & " and pType = " & p_pType & " and ord <> " & bomord
		end if
		Set rs = cn.execute(sql)
		If rs.eof = False Then
			bill.alert("该产品版本号已存在！")
			Bill_OnSave = False
			Exit Function
		end if
		rs.close
		set rs = nothing
		If b_isMain = "1" Then
			If add = "0" Then
				sql = "select * from BOM_Structure_Info where ismain = 1 and ProOrd = " & p_proOrd & " and pType = " & p_pType
			Else
				sql = "select * from BOM_Structure_Info where ismain = 1  and ProOrd = " & p_proOrd & " and pType = " & p_pType & " and ord <> " & bomord
			end if
			Set rs = cn.execute(sql)
			If rs.eof = False Then
				bill.alert("该产品已存在主BOM！")
				Bill_OnSave = False
				Exit Function
			end if
			rs.close
			set rs = nothing
		end if
		If isdate(b_zfDate) = False Or isdate(b_sxDate) = False Then
			bill.alert("请选择正确的生效日期和作废日期")
			Bill_OnSave = False
		end if
		If datediff("s",b_sxDate,b_zfDate) < 0 Then
			bill.alert("生效日期不可以大于作废日期！")
			Bill_OnSave = False
			Exit Function
		end if
		Dim s_sType, s_notNull, s_canEdit, s_proOrd, s_proType, s_unit, s_num, s_sProType, s_sCode
		dim s_PriceXS, s_PriceBZ, s_PriceJY
		s_sType             = app.getText("s_sType")
		s_notNull   = app.getText("s_notNull")
		s_canEdit   = app.getText("s_canEdit")
		s_proOrd    = app.getText("s_proOrd")
		s_proType   = app.getText("s_proType")
		s_unit                      = app.getText("s_unit")
		s_num                       = app.getText("s_num")
		s_sProType  = app.getText("s_sProType")
		s_sCode             = app.getText("s_sCode")
		s_PriceXS   = app.getText("s_PriceXS")
		s_PriceBZ   = app.getText("s_PriceBZ")
		s_PriceJY   = app.getText("s_PriceJY")
		s_ProductAttr1      = app.getText("s_ProductAttr1")
		s_ProductAttr2      = app.getText("s_ProductAttr2")
		s_sType             = Split(s_sType,",")
		s_notNull   = Split(s_notNull,",")
		s_canEdit   = Split(s_canEdit,",")
		s_proOrd    = Split(s_proOrd,",")
		s_proType   = Split(s_proType,",")
		s_unit              = Split(s_unit,",")
		s_num               = Split(s_num,",")
		s_sProType  = Split(s_sProType,",")
		s_sCode             = Split(s_sCode,",")
		s_PriceXS   = Split(s_PriceXS,",")
		s_PriceBZ   = Split(s_PriceBZ,",")
		s_PriceJY   = Split(s_PriceJY,",")
		s_ProductAttr1      = Split(s_ProductAttr1,",")
		s_ProductAttr2      = Split(s_ProductAttr2,",")
		Dim zdyText, addCate
		Set rs = server.CreateObject("adodb.recordset")
		If add = "0" Then
			sql = "select top 1 * from BOM_Structure_Info where 1 = 2"
			rs.open sql,cn,3,3
			rs.addnew
		Else
			sql = "select top 1 * from BOM_Structure_Info where ord = " & bomord
			rs.open sql,cn,3,3
		end if
		rs("title").value         = b_Title & ""
		rs("BBH").value                   = b_BBH & ""
		rs("BH").value                    = b_BH & ""
		rs("addDate").value               = b_addCate & ""
		rs("sxDate").value                = b_sxDate & ""
		rs("zfDate").value                = b_zfDate & ""
		If add = 0 then
			rs("addCate").value               = Info.User
		else
			addCate = rs("addCate").value & ""
		end if
		rs("date1").value         = now()
		rs("del").value                     = "1"
		Set rsZdy = cn.execute("select name from zdy where sort1 = 8040 and set_open = 1 order by gate1")
		While rsZdy.eof = False
			zdyText = app.getText(rsZdy("name"))
			If zdyText = "" And (rsZdy("name") = "zdy5" Or rsZdy("name") = "zdy6") Then
			else
				rs(Trim(rsZdy("name")) & "").value = zdyText & ""
			end if
			rsZdy.movenext
		wend
		rsZdy.close
		Set rsZdy = Nothing
		rs("ismain").value         = b_isMain & ""
		rs("ProOrd").value         = p_proOrd & ""
		rs("pType").value          = p_pType & ""
		rs("remark").value         = b_remark & ""
		rs.update
		rs.close
		set rs = nothing
		Dim i
		If add = 0 Then
			bomOrd = app.GetIdentity("BOM_Structure_Info","ord","addcate","")
		else
			bomOrd = bomord
		end if
		cn.execute("delete from BOM_Structure_List where bomord = " & bomord)
		Set rs = server.CreateObject("adodb.recordset")
		sql = "select top 1 * from BOM_Structure_List where 1 = 2"
		rs.open sql,cn,3,3
		rs.addnew
		rs("bomOrd").value = bomOrd
		rs("ProOrd").value = p_proOrd
		rs("ProType").value        = p_pType
		rs("isMain").value = "1"
		rs("includeTax").value     = includeTax
		If isnumeric(sumPriceXS & "") = true Then
			rs("PriceXS").value        = sumPriceXS
		end if
		If isnumeric(sumPriceBZ & "") = true Then
			rs("PriceBZ").value        = sumPriceBZ
		end if
		If isnumeric(sumPriceCB & "") = true Then
			rs("PriceJY").value= sumPriceCB
		end if
		If isnumeric(p_proUnit & "") = true Then
			rs("unit").value   = p_proUnit
		end if
		rs("num").value            = "1"
		If isnumeric(p_proCode & "") Then
			rs("sCode").value  = p_proCode
		end if
		If isnumeric(p_proType & "") Then
			rs("sType").value  = p_proType
		end if
		If isnumeric(p_ProductAttr1Name & "") Then
			rs("ProductAttr1").value   = p_ProductAttr1Name
		end if
		If isnumeric(p_ProductAttr2Name & "") Then
			rs("ProductAttr2").value   = p_ProductAttr2Name
		end if
		rs("del").value            = "1"
		If add = 0 Then
			rs("addCate").value        = Info.User
		else
			rs("addCate").value        = addCate
		end if
		rs("addDate").value        = now()
		For i = 0 To ubound(s_proOrd)
			rs.addnew
			rs("bomOrd").value = bomOrd
			rs("ProOrd").value = s_proOrd(i)
			rs("ProType").value        = s_proType(i)
			rs("isMain").value = "0"
			If isnumeric(s_unit(i)) Then
				rs("unit").value   = s_unit(i)
			end if
			rs("num").value            = s_num(i)
			If isnumeric(s_PriceXS(i) & "") Then
				rs("PriceXS").value        = s_PriceXS(i)
			else
				rs("PriceXS").value        = 0
			end if
			If isnumeric(s_PriceBZ(i) & "") Then
				rs("PriceBZ").value        = s_PriceBZ(i)
			else
				rs("PriceBZ").value        = 0
			end if
			If isnumeric(s_PriceJY(i) & "") Then
				rs("PriceJY").value        = s_PriceJY(i)
			else
				rs("PriceJY").value        = 0
			end if
			If isnumeric(s_sProType(i) & "") Then
				rs("sType").value  = s_sProType(i)
			end if
			If isnumeric(s_sCode(i) & "") Then
				rs("sCode").value  = s_sCode(i)
			end if
			If isnumeric(s_sType(i)&"") = False Then
				s_sType(i) = "0"
			end if
			rs("sProType").value= s_sType(i)
			If isnumeric(s_notNull(i)&"") = False Then
				s_notNull(i) = "0"
			end if
			rs("notNull").value       = s_notNull(i)
			If isnumeric(s_canEdit(i)&"") = False Then
				s_canEdit(i) = "0"
			end if
			rs("ProductAttr2").value  = s_ProductAttr2(i)
			If isnumeric(s_ProductAttr2(i)&"") = False Then
				s_ProductAttr2(i) = "0"
			end if
			rs("ProductAttr1").value  = s_ProductAttr1(i)
			If isnumeric(s_ProductAttr1(i)&"") = False Then
				s_ProductAttr1(i) = "0"
			end if
			rs("canEdit").value       = s_canEdit(i)
			rs("del").value           = "1"
			rs("addCate").value       = Info.User
			rs("addDate").value       = now()
		next
		rs.update
		rs.close
		set rs = nothing
		Dim hasErr
		Set rs = cn.execute("exec [Bom_Data_Check] " & bomord)
		hasErr = rs(0)
		rs.close
		set rs = nothing
		bill.setBillId(bomord)
		If CInt(hasErr) > 0 Then
			Set rs = cn.execute("exec [Bom_Data_Check1] " & bomord)
			If rs.eof = False Then
				Response.write("<script type=""text/javascript"">parent.bomadd.showErrProInfo('" & rs("pord") & "', '" & rs("ptype") & "', '" & rs("unit") & "')</script>")
			end if
			rs.close
			set rs = nothing
			bill.alert("物料结构不正确，不能作为此父件的子件！")
			Bill_OnSave = False
		else
			If app.getText("bomord") <> "" and app.getText("bomord") <> "0" Then
				Call bill.showSaveResult("组装清单保存成功！")
			else
				Call bill.showSaveResult2("组装清单保存成功！","list.asp")
			end if
			Bill_OnSave = true
		end if
	end function
	Sub App_ChangeProType
		Dim ord : ord = request.form("ord")
		Dim rs, options
		options = "<option value=''>请选择结构编码</option>"
		Set rs = cn.execute("select * from Bom_Code where p_Ord = " & ord & " order by gate1 desc,ord desc")
		If rs.eof Then
			Response.write(options)
		else
			While rs.eof = False
				options = options & "<option value='" & rs("ord") & "'>" & rs("title") & "</option>"
				rs.movenext
			wend
			Response.write(options)
		end if
		rs.close
		set rs = nothing
	end sub
	Function Bill_OnSaveNeedApprove(bill)
		Bill_OnSaveNeedApprove = True
	end function
	Sub App_getProInfo
		Dim pid, ptype, json
		pid = request.form("pid")
		ptype = request.form("ptype")
		json = getProInfo(pid,ptype)
		Response.write(json)
	end sub
	Sub App_getProInfos
		Dim pid, ptype, json, data, arr, i
		data = request.form("data")
		arr = Split(data,Chr(1))
		json = ""
		For i = 0 To ubound(arr)
			pid = Split(arr(i),Chr(2))(0)
			ptype = Split(arr(i),Chr(2))(1)
			If i > 0 Then
				json = json & Chr(1)
			end if
			json = json & getProInfo(pid,ptype)
		next
		Response.write(json)
	end sub
	Function getProInfo(pid,ptype)
		Dim rs, json, unit, unitall, rs1, rs2, SX, sql, bm, price1jy, price2jy, price2,ProductAttr1,ProductAttr2
		If ptype = "1" Then
			bm = sdk.getSqlValue("select sorce from gate where ord="& info.user &" " , 0)
			sql = "select " &_
			" title,order1,type1,unit,unitjb,canOutStore,zdy1,zdy2,zdy3,zdy4,z5.sort1 zdy5,z6.sort1 zdy6 " &_
			" from product p " &_
			" left join sortonehy z5 on z5.ord = p.zdy5 " &_
			" left join sortonehy z6 on z6.ord = p.zdy6 " &_
			" where p.ord = " & pid & " and (user_list = '' or isnull(user_list,0) = '0' or user_list = '0,0' or CHARINDEX('" & Info.User & "',User_List) > 0) "
			Set rs = cn.execute(sql)
			If rs.eof Then
				json = "{msg:'false'"
			else
				unit = "<option value=\'\'>请选择产品单位</option>"
				unitall = rs("unit")
				If Len(unitall & "") = 0 Then
					unitall = "0"
				end if
				If rs("canOutStore") = "1" Then
					SX = "实体"
				else
					SX = "虚拟"
				end if
				if bm=0 then
					Set rs1 = cn.execute("select price1jy, price2jy, price2 from jiage where product="& pid &" and unit="& rs("unitjb") &" and bm=0")
					If rs1.eof = False Then
						price1jy = rs1("price1jy") : price2jy = rs1("price2jy") : price2 = rs1("price2")
					end if
					rs1.close
					Set rs1 = Nothing
					If price1jy &"" = "" Then price1jy = 0
					If price2jy &"" = "" Then price2jy = 0
					If price2 &"" = "" Then price2 = 0
				else
					set rs1 = cn.execute("select ord,sort1 from pricegate1 where num1=1 and ord in (select bm from jiage where product="& pid &" and unit="& rs("unitjb") &" and bm>0)  and  ord="& bm)
					if rs1.eof = false then
						Set rs2 = cn.execute("select price1jy, price2jy, price2 from jiage where product="& pid &" and unit="& rs("unitjb") &" and bm="& bm &" ")
						If rs2.eof = False Then
							price1jy = rs2("price1jy") : price2jy = rs2("price2jy") : price2 = rs2("price2")
						end if
						rs2.close
						Set rs2 = Nothing
					else
						Set rs2 = cn.execute("select price1jy, price2jy, price2 from jiage where product="& pid &" and unit="& rs("unitjb") &" and bm=0 ")
						If rs2.eof = False Then
							price1jy = rs2("price1jy") : price2jy = rs2("price2jy") : price2 = rs2("price2")
						end if
						rs2.close
						Set rs2 = Nothing
					end if
					rs1.close
					set rs1 = Nothing
					If price1jy &"" = "" Then price1jy = 0
					If price2jy &"" = "" Then price2jy = 0
					If price2 &"" = "" Then price2 = 0
				end if
				json = "{msg:'true'," &_
				"title:'" & Replace(rs("title")&"","'","\'") & "'," &_
				"haslink:'" & Abs(app.power.existsPower(21,14)) & "'," &_
				"ord:'" & pid & "'," &_
				"pword:'" & app.base64.pwurl(pid) & "'," &_
				"ptype:'" & ptype & "'," &_
				"BH:'" & Replace(rs("order1")&"","'","\'") & "'," &_
				"XH:'" & Replace(rs("type1")&"","'","\'") & "'," &_
				"price2jy:'"& price2jy &"'," &_
				"price2:'"& price2 &"'," &_
				"price1jy:'"& price1jy &"'," &_
				"SX:'" & SX & "'," &_
				"zdy1:'" & Replace(rs("zdy1")&"","'","\'") & "'," &_
				"zdy2:'" & Replace(rs("zdy2")&"","'","\'") & "'," &_
				"zdy3:'" & Replace(rs("zdy3")&"","'","\'") & "'," &_
				"zdy4:'" & Replace(rs("zdy4")&"","'","\'") & "'," &_
				"zdy5:'" & Replace(rs("zdy5")&"","'","\'") & "'," &_
				"zdy6:'" & Replace(rs("zdy6")&"","'","\'") & "'," &_
				"UnitJB:'" & rs("unitjb")&"" & "'," &_
				"UnitAll:'" & rs("unit")&"" & "'," &_
				"Unit:"
				Set rs1 = cn.execute("select * from  sortonehy where gate2 = 61 and ord in (" & unitall & ")")
				While rs1.eof = False
					unit = unit & "<option value=\'" & rs1("ord") & "\'>" & Replace(rs1("sort1"),"'","\'") & "</option>"
					rs1.movenext
				wend
				rs1.close
				Set rs1 = Nothing
				json = json & "'" & unit & "',"&_
				"ProductAttr1Option:"
				Set rs1 =  GetProductAttrOption(pid,1)
				ProductAttr1OptionIds=""
				While rs1.eof = False
					ProductAttr1 = ProductAttr1 & "<option value=\'" & rs1("id") & "\'>" & Replace(rs1("title"),"'","\'") & "</option>"
					ProductAttr1OptionIds=ProductAttr1OptionIds&rs1("id")&","
					rs1.movenext
				wend
				rs1.close
				Set rs1 = Nothing
				json = json & "'" & ProductAttr1 & "',"
				json = json & "ProductAttr1OptionIds:'" & ProductAttr1OptionIds & "',"&_
				"ProductAttr2Option:"
				Set rs1 =  GetProductAttrOption(pid,0)
				ProductAttr2OptionIds=""
				While rs1.eof = False
					ProductAttr2 = ProductAttr2 & "<option value=\'" & rs1("id") & "\'>" & Replace(rs1("title"),"'","\'") & "</option>"
					ProductAttr2OptionIds=ProductAttr2OptionIds&rs1("id")&","
					rs1.movenext
				wend
				rs1.close
				Set rs1 = Nothing
				json = json & "'" & ProductAttr2 & "',"
				json = json & "ProductAttr2OptionIds:'" & ProductAttr2OptionIds & "'"
			end if
			rs.close
			set rs = nothing
			Set rs1 = ProductAttrsByOrd(pid)
			attr1Name="产品属性1："
			attr2Name="产品属性2："
			i=0
			While rs1.eof = False
				if rs1("isTiled")=1 then
					attr1Name=rs1("title")&"："
				elseif rs1("isTiled")=0 then
					attr2Name = rs1("title")&"："
				end if
				rs1.movenext
				i=i+1
				rs1.movenext
			wend
			rs1.close
			set rs1 = Nothing
			json=json&",ProductAttrsName:'"&attr1Name&"___"&attr2Name&"'"
			getProInfo = json & "}"
		Else
			Set rs = cn.execute("select * from Bom_ProName where ord =  " & pid)
			If rs.eof Then
				json = "{msg:'false'}"
			else
				json = "{msg:'true'," &_
				"title:'" & Replace(rs("name"),"'","\'") & "'," &_
				"haslink:'0'," &_
				"ord:'" & pid & "'," &_
				"pword:'" & app.base64.pwurl(pid) & "'," &_
				"ptype:'" & ptype & "'," &_
				"BH:'--'," &_
				"ptype:'" & ptype & "'," &_
				"XH:'--'," &_
				"ptype:'" & ptype & "'," &_
				"price2jy:'0'," &_
				"price2:'0'," &_
				"price1jy:'0'," &_
				"SX:'--'," &_
				"price1jy:'0'," &_
				"zdy1:'--'," &_
				"price1jy:'0'," &_
				"zdy2:'--'," &_
				"price1jy:'0'," &_
				"zdy3:'--'," &_
				"price1jy:'0'," &_
				"zdy4:'--'," &_
				"price1jy:'0'," &_
				"zdy5:'--'," &_
				"price1jy:'0'," &_
				"zdy6:'--'," &_
				"price1jy:'0'," &_
				"UnitJB:'0'," &_
				"UnitAll:'0'," &_
				"Unit:'0'," &_
				"ProductAttr1Option:'0'," &_
				"ProductAttr2Option:'0',"&_
				"ProductAttrsName:''"&_
				"}"
			end if
			rs.close
			set rs = nothing
			getProInfo = json
		end if
	end function
	Sub App_changeUnit
		Dim rs, rs1, cpord, bm, price1jy, price2jy, unit, price2
		bm = sdk.getSqlValue("select sorce from gate where ord="& info.user &" " , 0)
		cpord = app.getInt("ord")
		unit = app.getInt("unit")
		if bm=0 then
			Set rs1 = cn.execute("select price1jy, price2jy,price2 from jiage where product="& cpord &" and unit="& unit &" and bm=0")
			If rs1.eof = False Then
				price1jy = rs1("price1jy") : price2jy = rs1("price2jy") : price2 = rs1("price2")
			end if
			rs1.close
			Set rs1 = Nothing
			If price1jy &"" = "" Then price1jy = 0
			If price2jy &"" = "" Then price2jy = 0
			If price2 &"" = "" Then price2 = 0
		else
			set rs1 = cn.execute("select ord,sort1 from pricegate1 where num1=1 and ord in (select bm from jiage where product="& cpord &" and unit="& unit &" and bm>0)  and  ord="& bm)
			if rs1.eof = false then
				Set rs2 = cn.execute("select price1jy, price2jy,price2 from jiage where product="& cpord &" and unit="& unit &" and bm="& bm &" ")
				If rs2.eof = False Then
					price1jy = rs2("price1jy") : price2jy = rs2("price2jy") : price2 = rs1("price2")
				end if
				rs2.close
				Set rs2 = Nothing
			else
				Set rs2 = cn.execute("select price1jy, price2jy, price2 from jiage where product="& cpord &" and unit="& unit &" and bm=0 ")
				If rs2.eof = False Then
					price1jy = rs2("price1jy") : price2jy = rs2("price2jy") : price2 = rs2("price2")
				end if
				rs2.close
				Set rs2 = Nothing
			end if
			rs1.close
			set rs1 = Nothing
			If price1jy &"" = "" Then price1jy = 0
			If price2jy &"" = "" Then price2jy = 0
			If price2 &"" = "" Then price2 = 0
		end if
		Response.write price1jy & Chr(1) & price2jy & Chr(1) & price2
	end sub
	Sub App_getProType
		Dim arr, rs, i
		arr = "[['请选择','']"
		Set rs = cn.execute("select ord,title from Bom_Code where isMain = 1 order by gate1 desc, ord desc")
		While rs.eof = False
			arr = arr & ",['" & Replace(rs("title")&"","'","\'") & "','" & rs("ord") & "']"
			rs.movenext
		wend
		rs.close
		set rs = nothing
		arr = arr & "]"
		Response.write(arr)
	end sub
	Function ListCellsFormat(ByVal cellsTitle,ByVal rs)
		Select Case cellsTitle
		Case "产品名称":
		If app.power.existsPower(21,14) And rs("proType") = "1" Then
			ListCellsFormat = "<a href='../product/content.asp?ord=" & app.base64.pwurl(rs("ProOrd")) & "' target='_blank'>" & rs(cellsTitle) & "</a>"
		else
			ListCellsFormat = rs(cellsTitle)
		end if
		Case Else
		ListCellsFormat = ""
		End Select
	end function
	Function ProductAttrHTML(id)
		stop
		ProductAttrHTML = "<option value='0'>222</option>"
	end function
	
%>
