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
			Case "number" :       doEditHtml = "<input type='text' name='" & dbname &  cvalue & "' " & njs & " style='width:80px' maxlength='32' value='" & app.HtmlConvert(Replace(nv&"",",","")) & "'  onpropertychange=""formatData(this,'number',2);"" onkeyup=""value=value.replace(/[^\d\.]/g,'');checkDot(this,'" &Info.floatnumber & "')"" >" & app.iif(notnull, " <span class='red'>*</span>", "")
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
			'response.clear
			'Response.write "组件listivw警告：不存在dbname为【" & dbname & "】的列。"
			'cn.close
			'call AppEnd
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
								addhtml "<table hckey='" & HeaderConfigKey & "' key16='" & md5key16 & "' class='" & iif(jsonEditModel,"je lvwframe2 detailTableList","lvwframe2 detailTableList") &"' style='" & css & "' " & iif(noScrollModel,"style='table-layout:auto'","") & " datawidth='" & datawidth & "' id='lvw_dbtable_" & id& "' maxheads='" & (maxheader+1) & "' colresize='" & abs(Me.colresize) & "' " & iif(colresized, "colresized='1'","") & iif(jsonEditModel,"onmousedown='__lvw_jn_tbmd(this)'","") & ">"
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
					'psql = catef & " in (" & introw & ") "
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
		
		If request("remind") <> "" Then
			Response.write "" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "try{" & vbcrlf & "       jQuery(function(){" & vbcrlf & "              jQuery('form').each(function(){" & vbcrlf & "                 jQuery('<input type=""hidden"" name=""remind"" value="""
			Response.write Request("remind")
			Response.write """/>').appendTo(this);" & vbcrlf & "               });" & vbcrlf & "     });" & vbcrlf & "}catch(e){}" & vbcrlf & "</script>" & vbcrlf & ""
		end if
		ZBRLibDLLNameSN = "ZBRLib3205"
		Function CreateReminderHelper(ByRef cn,cfgId,subCfgId)
			Dim remind
			Set remind = New Reminder
			Set remind.cn = cn
			Call remind.init(cfgId,subCfgId)
			Set CreateReminderHelper = remind
		end function
		Function CreateReminderHelperByRs(ByRef cn,ByRef rs)
			Dim remind
			Set remind = New Reminder
			Set remind.cn = cn
			Call remind.initByRs(rs)
			Set CreateReminderHelperByRs = remind
		end function
		Dim Global_Power
		Sub InitGlobalPower(ByRef cn)
			Dim sql,rs
			sql = "select a.sort1,a.sort2,isnull(b.qx_open,0) qx_open," &_
			"(case when b.qx_intro is null or datalength(b.qx_intro)=0 then '-255' else b.qx_intro end) qx_intro," &_
			"isnull(a.sort,1) qx_type, " &_
			"from qxlblist a  with(nolock) " &_
			"left join power b  with(nolock) on b.sort1=a.sort1 and b.sort2=a.sort2 and b.ord=" & session("personzbintel2007")
			Set rs = cn.execute(sql)
			If rs.eof = False Then
				Global_Power = rs.getRows()
			end if
			rs.close
			Set rs=Nothing
		end sub
		Class Reminder
			Public cn
			Private configId
			Private base64
			Private power
			Private regEx
			Private uid
			Private actDate
			Private m_subCfgId
			Private m_name
			Private m_setjmId
			Private m_mCondition
			Private m_remindMode
			Private m_qxlb
			Private m_listqx
			Private m_detailqx
			Private m_detailOpen
			Private m_detailIntro
			Private m_moreLinkUrl
			Private m_detailLinkUrl
			Private m_moreLinkUrl_mobile
			Private m_detailLinkUrl_mobile
			Private m_hasModule
			Private m_canCancel
			Private m_jointly
			Private m_num1
			Private m_opened
			Private m_gate1
			Private m_tq1
			Private m_fw1
			Private m_canShow
			Private m_remindCount
			Private m_titleMaxLength
			Private m_subSql
			Private m_lastReloadDate
			Private m_MOrderSetting
			Private m_MBusinessType
			Private m_canTQ
			Private m_fwSetting
			Private m_isMobileMode
			Private m_colCount
			Public displaySqlOnCount
			Public displaySqlOnShow
			Public isCleanMode
			Public dateBegin
			Public pageSize
			Public pageIndex
			Public showStatusField
			Private recCount
			Private pageCount
			Private m_existsPowerIntro
			Private m_expiCount
			Private m_UsingPowerCache
			Private m_cacheHelper
			Private m_cacheExpiredCondition
			Private m_usingLv2Cache
			Private m_hasAltField
			Private Function hasAltField(rs)
				If isEmpty(m_hasAltField) Then
					m_hasAltField = hasFieldInRs(rs,"canCancelAlt")
				end if
				hasAltField = m_hasAltField
			end function
			Public Sub setMobileMode
				m_isMobileMode = True
			end sub
			Public Property Get canCancel
			canCancel = m_canCancel
			End Property
			Public Property Get colCount
			colCount = iif(m_isMobileMode,m_colCount,-1)
'Public Property Get colCount
			End Property
			Public Property Get mobileDetailLinkUrl
			mobileDetailLinkUrl = m_detailLinkUrl_mobile
			End Property
			Private m_hasStatField
			Private Function hasStatField(rs)
				If isEmpty(m_hasStatField) Then
					m_hasStatField = hasFieldInRs(rs,"orderStat")
				end if
				hasStatField = m_hasStatField
			end function
			Private m_hasInfoField
			Private Function hasInfoField(rs)
				If isEmpty(m_hasInfoField) Then
					m_hasInfoField = hasInfoField = hasFieldInRs(rs,"otherInfo")
				end if
				hasInfoField = m_hasInfoField
			end function
			Public Property Get numDigit
			numDigit = cn.execute("select num1 from setjm3  with(nolock) where ord=88")(0)
			End Property
			Public Property Get moneyDigit
			moneyDigit = cn.execute("select num1 from setjm3  with(nolock) where ord=1")(0)
			End Property
			Public Property Get hlDigit
			hlDigit = cn.execute("select num1 from setjm3 with(nolock)  where ord=87")(0)
			End Property
			Public Property Get zkDigit
			zkDigit = cn.execute("select num1 from setjm3  with(nolock) where ord=2014053101")(0)
			End Property
			Public Property Get usingLv2Cache
			usingLv2Cache = m_usingLv2Cache
			End Property
			Public Property Let usingLv2Cache(v)
			m_usingLv2Cache = v
			End Property
			Public Property Get subSql
			subSql = m_subSql
			End Property
			Public Property Get lastReloadDate
			lastReloadDate = m_lastReloadDate
			End Property
			Public Property Get subConfigId
			subConfigId = m_subCfgId
			End Property
			Public Property Get moreLink
			moreLink = moreLinkURL()
			End Property
			Public Property Get num1
			num1 = m_num1
			End Property
			Public Property Let num1(v)
			m_num1 = v
			End Property
			Public Property Get gate1
			gate1 = m_gate1
			End Property
			Public Property Get name
			name = m_name
			End Property
			Public Property Get fw1
			fw1 = m_fw1
			End Property
			Public Property Get tq1
			tq1 = m_tq1
			End Property
			Public Property Get canTQ
			canTQ = m_canTQ
			End Property
			Public Property Get fwSetting
			fwSetting = m_fwSetting
			End Property
			Public Property Get setjmId
			setjmId = m_setjmId
			End Property
			Public Property Get canShow
			If isEmpty(m_canShow) Then
				If m_opened = False And isCleanMode <> True Then
					m_canShow = False
				else
					m_canShow = m_hasModule
				end if
			end if
			canShow = m_canShow
			End Property
			Public Property Get isOpened
			isOpened = m_opened
			End Property
			Public Property Get hasModule
			hasModule = m_hasModule
			End Property
			Private Sub class_initialize
				Set base64 = server.createobject(ZBRLibDLLNameSN &".Base64Class")
				Set power = server.createobject(ZBRLibDLLNameSN &".PowerClass")
				power.PowerCache = True
				uid = session("personzbintel2007")
				If uid = "" Then uid = 0
				actDate = session("timezbintel2007")
				If actDate = "" Then actDate = now
				session("timezbintel2007") = actDate
				Set regEx =New RegExp
				regEx.Pattern = "<[^>]+>"
				Set regEx =New RegExp
				regEx.IgnoreCase = True
				regEx.Global = True
				m_subCfgId = 0
				m_subSql = ""
				isCleanMode = False
				dateBegin = IIf(request.querystring("__dt")="",dateadd("m",-3,date),request.querystring("__dt"))
				isCleanMode = False
				pageSize = IIf(request.querystring("__pageSize")="",10,request.querystring("__pageSize"))
				pageIndex = IIf(request.querystring("__pageIndex")="",1,request.querystring("__pageIndex"))
				pageSize = CLng(pageSize)
				pageIndex = CLng(pageIndex)
				recCount = 0
				pageCount = 0
				displaySqlOnCount = False
				displaySqlOnShow = False
				redim m_existsPowerIntro(0)
				If isEmpty(Global_Power) Then
					m_UsingPowerCache = False
				else
					m_UsingPowerCache = True
				end if
				m_usingLv2Cache = False
				showStatusField = True
				m_isMobileMode = False
			end sub
			Public Function listSQL(mode)
		dim ismobile: ismobile= instr(1,mode & "","mobileplus:",1) = 1
		Dim sql,cateCondition,tmpCondition,qOpen,qIntro,fields,orderBy
		Dim withoutCateCondition,cancelCondition,withoutCancelCondition,i,withoutOrderBy,cancelJoinTable
		mode = replace(mode & "", "mobileplus:", "")
		withoutCateCondition = instr(1,mode,"withoutCateCondition",1) > 0
		withoutCancelCondition = instr(1,mode,"withoutCancelCondition",1) > 0
		withoutOrderBy = InStr(1,mode,"withoutOrderBy",1) > 0
		dim icsql : icsql = ""
		if ismobile then
			icsql = "union select cateid, reminderId from reminderPersonsForMobPush  with(nolock) where cateid=" & uid
		end if
		mode = LCase(Split(mode,"_")(0))
		cancelJoinTable = "left join (" & vbcrlf &_
		"select cateid as isCanceled,reminderId from reminderPersons  with(nolock)  where cateid=" & uid & " " & vbcrlf & icsql & vbcrlf &_
		") __rp on __rp.reminderId=a.id " & vbcrlf
		cancelCondition = " and __rp.isCanceled is null "
		Select Case m_setjmId
		Case 1:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"p.cateid")
		sql = "select COUNT(*) REMIND_CNT from plan1 p with(nolock) "&_
		"where complete='1' and option1<>'1' and "&_
		"(startdate1<'" & dateadd("d",m_tq1,date) & "' or "&_
		"(startdate1='" & dateadd("d",m_tq1,date) & "' and "&_
		"(starttime1<'"&hour(time)&"' or starttime1='"&hour(time)&"'and starttime2<'"&minute(time)&"')"&_
		")"&_
		") [CATECONDITION] [ORDERBY]"
		fields = "ord [id],intro title,case when startdate1 is null then convert(varchar(10),date1,21) + ' ' + time1 + ':' + time2 "&_
		"else convert(varchar(10),startdate1,21) + ' ' + starttime1 + ':" &_
		"datediff(s,'&actDate&"
		orderBy = "order by startdate1 desc,date8 desc "
		Case 2:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " and charindex(',"&uid&",',','+alt+',')<=0 "
		'cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) "&_
		" [CANCELJOINTABLE] " & _
		"inner join learntz b on a.orderId=b.ord and b.del=1 " &_
		" where a.reminderConfig=" & configId & " [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "isnull(b.ord,0) [id],isnull(b.title,'【已删除数据】') title,isnull(convert(varchar(19),b.date7,21),'----') dt,"&_
		"datediff(s,' & actDate & ',isnull(b.date7,'2000-01-01"
		
		orderBy = "order by a.id desc"
		Case 4:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.ecateid")
		cateCondition = cateCondition & " and datediff(d,getdate(),b.stime) <= " & m_tq1
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) "&_
		" [CANCELJOINTABLE] " & _
		"inner join importantMsg b on a.orderId=b.id and b.del=1 AND b.metype = "& m_subCfgId &" " &_
		"left join tel c on b.t_ord=c.ord " & vbcrlf &_
		" where c.del=1 and b.state<>2 and a.reminderConfig=" & configId & " [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],isnull(c.name,'【已删除数据】') title,isnull(convert(varchar(19),b.stime,21),'----') dt,"&_
		" where c.del=1 and b.state<>2 and a.reminderConfig=" & configId & " [CATECONDITION] [CANCELCONDITION] [ORDERBY]" &_
		"case when year(b.stime)<year(getdate()) then -1 else datediff(s,'&actDate&"
		
		orderBy = "order by b.stime desc"
		Case 7:
		Dim nowDays : nowDays = datediff("d",CDate(year(date)&"-01-01"),date)
		
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		if m_fw1&""="0" then
			if qOpen=3 then
				cateCondition=""
			elseif qOpen=1 then
				cateCondition=cateCondition & " and (tl.cateid in ("&qIntro&") "&_
				"or tl.share='1' "&_
				"or charindex(',"&uid&",',','+tl.share+',')>0) "
				'or tl.share=
			else
				cateCondition=cateCondition & " and (tl.share='1' or charindex(',"&uid&",',','+tl.share+',')>0) "
				'or tl.share=
			end if
		else
			cateCondition=cateCondition & " and tl.cateid="&uid&" or (tl.share='1' or charindex(',"&uid&",',','+tl.share+',')>0) "
			'or tl.share=
		end if
		cateCondition=cateCondition & " and bDays - "&nowDays&" >=0 and bDays - "&nowDays&" <= " & m_tq1 & " " & vbcrlf
		'or tl.share=
		sql = """" & vbcrlf &_
		"select COUNT(*) REMIND_CNT " & vbcrlf &_
		"from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join person p  with(nolock) on a.reminderConfig = 7 and a.orderId=p.ord and p.del=1 and p.sort3=1 and p.bDays >= 0 " & vbcrlf &_
		"left join tel tl on tl.ord = p.company " & vbcrlf &_
		"where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "p.ord [id]," & _
		"case when bDays - "&nowDays&" = 0 then p.name+CHAR(11)+CHAR(12)+'今日生日'" & _
		"else p.name+CHAR(11)+CHAR(12)+'还差'+cast(bDays - &nowDays& as varchar)+'天" &_
		"end as title," & _
		"convert(varchar(10),dateadd(d,p.bDays,'"&year(date)&"-01-01'),121)+'@'+cast(p.birthdayType as varchar) dt," & _
		"-1 as newTag,a.id [rid],tl.cateid "
		orderBy = "order by p.bDays asc"""
		Case 9:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"d.cateid")
		cateCondition = cateCondition & " and datediff(d,getdate(),c.date2)<=" & m_tq1
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join caigoulist c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.id and c.del=1 " & vbcrlf &_
		"inner join caigou d  with(nolock) on d.ord=c.caigou " & vbcrlf &_
		"inner join product b  with(nolock) on b.ord=c.ord " & vbcrlf &_
		"where d.del=1 and isnull(d.status,-1) IN (-1,1) and c.alt=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		
		fields = "c.id [id],d.title+'['+b.title+']' title,convert(varchar(10),c.date2,23) dt,datediff(s,'""&actDate&""',a.inDate) newTag,a.id [rid],c.cateid"""
		
		orderBy = "order by c.date2 desc,c.date7 desc"""
		Case 11:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"c.cateid")
		cateCondition = cateCondition & " and datediff(d,getdate(),c.date1)<=" & m_tq1
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join payback c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.ord and c.del=1 and c.complete='1' " & vbcrlf &_
		"left join contract ct  with(nolock) on ct.ord=c.contract " & vbcrlf &_
		"left join sortbz bz  with(nolock) on bz.id=ct.bz " & vbcrlf &_
		"where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "c.ord [id],'@code:""'+isnull(bz.intro,'RMB')+' "" & FormatNumber('+CAST(c.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(10),c.date1,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],c.cateid"
		
		orderBy = "order by c.date1 desc,c.date7 desc"
		Case 12:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"c.cateid")
		cateCondition = cateCondition & " and datediff(d,getdate(),c.date1)<=" & m_tq1
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join payout c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.ord and c.del=1 and c.complete='1' " & vbcrlf &_
		"left join (select ord,bz,0 cls from caigou union all select ID as ord,14 bz, 2 cls from M_OutOrder union all select ID as ord,bz, (case isnull(wwType,0) when 0 then 5 when 1 then 4 else 2 end) cls from M2_OutOrder  with(nolock) ) ct on ct.ord=c.contract and ct.cls=isnull(c.cls,0) " & vbcrlf &_
		"left join sortbz bz on bz.id=ct.bz " & vbcrlf &_
		"where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "c.ord [id],'@code:""'+isnull(bz.intro,'RMB')+' "" & FormatNumber('+CAST(c.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(10),c.date1,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],c.cateid"
		
		orderBy = "order by c.date1 desc,c.date7 desc"
		Case 21:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = ""
		If m_fw1&""="0" Then
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
				tmpCondition = " and (cateid is not null and cateid<>0)"
			else
				cateCondition = " and 1=2"
			end if
		else
			cateCondition = " and cateid=" & uid
		end if
		cateCondition = " and ("&_
		"(1=1"&cateCondition&") or charindex(',"&uid&",',','+replace(cast(share as varchar(8000)),' ','')+',')>0 or share='1'"&_
		") " & tmpCondition & vbcrlf
		cateCondition = cateCondition & " and datediff(d,getdate(),b.date2)<=" & m_tq1
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join contract b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 and isnull(b.status,-1) in (-1,1)  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title,convert(varchar(10),b.date2,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		orderBy = "order by b.date2 desc,b.date7 desc"
		Case 22:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			tmpCondition = ""
		ElseIf qOpen=1 Then
			tmpCondition = " and addcate in ("&qIntro&") "
		else
			tmpCondition = " and 1=2"
		end if
		If m_fw1&""="0" Then
			cateCondition = tmpCondition & " and isnull(catelead,0) > 0 "
		else
			cateCondition = tmpCondition & " and catelead=" & uid
		end if
		sql="select COUNT(*) REMIND_CNT from tousu  with(nolock) where del=1 [CATECONDITION] and result1=0 [ORDERBY]"
		fields = "ord [id],title,date1 dt,datediff(s,'" & actDate & "',isnull(date7,'2000-01-01')) newTag,0 [rid],addcate cateid"
		'sql="select COUNT(*) REMIND_CNT from tousu  with(nolock) where del=1 [CATECONDITION] and result1=0 [ORDERBY]"
		orderBy = "order by date1 desc,date7 desc"
		Case 23:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " and datediff(d,getdate(),c.date2)<=" & m_tq1
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join contractlist c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.id and c.del=1 " & vbcrlf &_
		"inner join contract b  with(nolock) on b.ord=c.contract and b.del=1 and isnull(b.status,-1) in (-1,1)  " & vbcrlf &_
		"left join product p  with(nolock) on p.ord=c.ord and p.del=1 " & vbcrlf &_
		"where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "c.id [id],b.title+'['+isnull(p.title,'产品被删除')+']' title,convert(varchar(10),c.date2,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		
		orderBy = "order by c.date2 desc,c.date7 desc"
		Case 39:
		cateCondition = "and learnhd.cateid="&uid
		sql="SELECT COUNT(*) REMIND_CNT FROM replyhd  with(nolock) "&_
		"LEFT JOIN learnhd  with(nolock) ON replyhd.ord = learnhd.ord "&_
		"where learnhd.del=1 and replyhd.alt=1 [CATECONDITION] [ORDERBY]"
		fields = "replyhd.id as [id],learnhd.title as title,replyhd.date7 as dt,-1 newTag,0 [rid],learnhd.cateid as cateid,learnhd.ord as ord"
		
		orderBy = "order by replyhd.date7 desc"
		Case 68:
		cateCondition = "and CHARINDEX(',"&uid&",',','+c.RemindPerson+',')>0 " & vbcrlf &_
		"AND daysFromNow <=  & (m_tq1 * 24)"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join ku b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
		"inner join product c  with(nolock) on c.ord=b.ord " & vbcrlf &_
		"inner join sortck ck  with(nolock) on b.ck=ck.ord and ck.del=1 " &_
		"IIf(withoutCateCondition,"""",""and (cast(ck.intro as varchar(10))='0' "&_
		"or CHARINDEX(',&uid&,',','+cast(ck.intro as varchar(4000))+'," &_
		"where isnull(b.locked,0)=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],c.title,"&_
		"CONVERT(varchar(10),dateadd(hh,a.daysFromNow,'"&date&"'),23) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],0 cateid"
		orderBy = "ORDER BY dt DESC,id DESC"
		Case 74:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and creator in ("&qIntro&") "
		else
			cateCondition = " and 1=2"
		end if
		cateCondition = cateCondition & " AND cateid=" & uid
		sql="SELECT COUNT(*) REMIND_CNT FROM sale_proposal  with(nolock) WHERE ISNULL(alt,0) = 0 AND del = 0 [CATECONDITION] [ORDERBY]"
		fields = "[id],title,ServerTime dt,datediff(s,'" & actDate & "',isnull(ServerTime,'2000-01-01')) newTag,0 [rid],ISNULL(creator,0) cateid"
		orderBy = "ORDER BY ServerTime DESC,id DESC"
		Case 73:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and cateid in ("&qIntro&") "
		else
			cateCondition = " and 1=2"
		end if
		cateCondition = cateCondition &  "AND NextOperator=" & uid &" "& cateCondition
		sql="SELECT COUNT(*) REMIND_CNT FROM sale_Complaints  with(nolock) WHERE del=0 and ISNULL(alt,0) = 0 [CATECONDITION] [ORDERBY]"
		fields = "[id],title,ServerTime dt,datediff(s,'" & actDate & "',isnull(ServerTime,'2000-01-01')) newTag,0 [rid],ISNULL(cateid,0) cateid"
		orderBy = "ORDER BY ServerTime DESC,id DESC"
		Case 72:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and cateid in ("&qIntro&") "
		else
			cateCondition = " and 1=2"
		end if
		sql="SELECT COUNT(*) REMIND_CNT FROM Sale_CallBack  with(nolock) where Del=1 and cateid=" & uid &_
		" and dbo.dateDiffByDay(ybackTime,2,0,"& m_tq1 &",GETDATE())>=0 and isback=0 and isnull(setalt,0)=0 "& cateCondition & " [ORDERBY]"
		fields = "[id],title,CONVERT(varchar, ybackTime,20) dt,-1 newTag,0 [rid],cateid"
		orderBy = "ORDER BY ServerTime DESC,id DESC"
		Case 100:
		sql = "select COUNT(*) REMIND_CNT from notebook with(nolock)  "&_
		"where (del=1 or del is null) and alt=0 and complete<>2 and cateid =" & uid &_
		"and datediff(d,getdate(),date7) <= " & m_tq1 & " [ORDERBY]"
		fields = "ord [id],'@code:htmldecode(rs(""real_title""))' title,convert(varchar,date7,120) dt,-1 newTag,0 [rid],cateid,cast(intro as varchar(8000)) real_title" &_
		"and datediff(d,getdate(),date7) <= " & m_tq1 & " [ORDERBY]"
		orderBy = "order by date7 desc"
		Case 101:
		sql = "    select COUNT(*) REMIND_CNT "&_
		"from learn  with(nolock) where (cateid=" & uid & " or CHARINDEX('," & uid & ",' , ','+share+',') > 0 or share = '1') " &_
		"and CHARINDEX(',&uid&,',','+alt+',"
		fields = "[id],title,convert(varchar,date7,120) dt,-1 newTag,0 [rid],cateid"
		'sql = "    select COUNT(*) REMIND_CNT "&_
		orderBy = "order by date7 desc"
		Case 102:
		cateCondition = getCondition(m_qxlb,m_listqx,"a.AddUser")
		sql= "SELECT COUNT(*) REMIND_CNT " & vbcrlf &_
		"FROM RepairOrder a  with(nolock) left join ( " &_
		"select id,title from Comm_ProcessSet  with(nolock) where type=1 " &_
		") b on b.id = a.ProcessID  where a.id in( "& vbcrlf &_
		"select a.id FROM RepairOrder a  with(nolock) " & vbcrlf &_
		"left join ( " & vbcrlf &_
		"select id,title from Comm_ProcessSet  with(nolock) where type=1 " & vbcrlf &_
		") b on b.id = a.ProcessID " & vbcrlf &_
		"left join ( " & vbcrlf &_
		"SELECT distinct a.RepairOrder,a.ProcessID,a.DealPerson,ActualBeginTime,NodeID FROM RepairDeal a  with(nolock) " & vbcrlf &_
		"LEFT JOIN Copy_ProcessNodeSet b with(nolock)  ON b.ID = a.NodeID AND b.del = 1 " & vbcrlf &_
		"WHERE a.del = 1 AND a.CurrentStatus = 0 " & vbcrlf &_
		") c on c.RepairOrder=a.id and c.ProcessID=a.ProcessID " & vbcrlf &_
		"WHERE a.del = 1 " & vbcrlf &_
		"and (a.Status = 0 or a.Status = 1) " & vbcrlf &_
		"and isnull(c.DealPerson,a.DealPerson) = " & uid &" "&_
		"and datediff(d,getdate(),isnull(c.ActualBeginTime,'1900-01-01'))<= " & m_tq1 & " " &_
		"cateCondition & "") [ORDERBY]"""
		fields = "a.[id],b.title+'['+a.Title+']' title,convert(varchar,a.addTime,120) dt,-1 newTag,0 [rid],a.AddUser cateid"
		'cateCondition & ") [ORDERBY]"
		orderBy = "order by a.addTime desc"
		Case 103:
		cateCondition = getCondition(m_qxlb,m_listqx,"MainExecutor")
		sql = "select COUNT(*) REMIND_CNT from (" & vbcrlf &_
		"select a.id,c.title+'['+b.name+']' title,convert(varchar,BeginTimePlan,120) dt,"& vbcrlf &_
		"a.BeginTimePlan,MainExecutor from ChanceProcRunLogs a  with(nolock) " & vbcrlf &_
		"inner join chanceProcNodesBak b  with(nolock) on a.ProcNodesBak = b.id " & vbcrlf &_
		"inner join chance c  with(nolock) on c.ord=a.chance AND c.del = 1 " & vbcrlf &_
		"where " & vbcrlf & _
		"(" & vbcrlf &_
		"(a.Status=0 and MainExecutor="&uid&")" & vbcrlf &_
		" or " & vbcrlf & _
		"(" & vbcrlf & _
		"(a.Status=1 or a.Status=9) " & vbcrlf &_
		" and " & vbcrlf &_
		"(MainExecutor="&uid&" or charindex(',"&uid&",',','+a.Executors+',')>0) " & vbcrlf &_
		")" & vbcrlf & _
		")" & vbcrlf &_
		" and datediff(d,getdate(),BeginTimePlan)<="& m_tq1&" " & cateCondition & vbcrlf &_
		") a [ORDERBY]"
		fields = "[id],title,dt,-1 newTag,0 [rid],MainExecutor cateid"
		
		orderBy = "order by BeginTimePlan desc"
		Case 216:
		Dim sort46Open,sort47Open,rs_setting
		Set rs_setting = cn.execute("select intro from setopen  with(nolock) where sort1=46 union all select 0")
		sort46Open = rs_setting("intro")
		rs_setting.close
		Set rs_setting = cn.execute("select intro from setopen  with(nolock) where sort1=47 union all select 0")
		sort47Open = rs_setting("intro")
		rs_setting.close
		Set rs_setting = Nothing
		Call fillinPower(1,18,qOpen,qIntro)
		qIntro = IIF(qIntro&""="","0",qIntro)
		if sort46Open<>0 and sort46Open<>"" then
			if qOpen = 1 then
				if sort46Open = 1 then
					if sort47Open = 1 then
						cateCondition = cateCondition & " and (order1<>2 and (cateadd in("& qIntro &"))) "
					elseif sort47Open = 2 then
						cateCondition = cateCondition & " and (order1<>2 and (cateidgq in("& qIntro &"))) "
					else
						cateCondition = cateCondition & " and (order1<>2 and (cateidgq in("& qIntro &") or cateadd in("& qIntro &"))) "
					end if
				elseif sort46Open=2 then
					if sort47Open=1 then
						cateCondition = cateCondition & " and (cateadd in("& qIntro &")) "
					elseif sort47Open = 2 then
						cateCondition = cateCondition & " and (cateidgq in("& qIntro &")) "
					elseif sort47Open = 3 then
						cateCondition = cateCondition & " and (cateid in("& qIntro &")) "
					else
						cateCondition = cateCondition & " and (cateidgq in("& qIntro &") or cateadd in(" & qIntro & ")) "
					end if
				end if
			ElseIf qOpen <> 3 And qOpen & "" <> "" Then
				cateCondition = cateCondition & " and 1=2 "
			end if
		end if
		Call fillinPower(1,6,qOpen,qIntro)
		tmpCondition = "" & _
		" AND (" & vbcrlf &_
		"(" & vbcrlf &_
		"order1 = 3 and (" & vbcrlf &_
		"qOpen & ""=3 or ("" & qOpen & ""=1 and charindex(','+cast(b.cateid4 as varchar)+',',',"" & qIntro & "",')>0)" & vbcrlf &_
		")" & vbcrlf &_
		") " & vbcrlf &_
		"OR (isnull(order1,0) = 0  AND cateid4 = "& uid &" )" & vbcrlf &_
		") "
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & tmpCondition & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.name title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
		"(CASE WHEN order1 <> 3 THEN 1 ELSE 0 END) canCancelAlt," & vbcrlf &_
		"(case WHEN order1 = 3 then 10 else 12 end) orderStat"
		orderBy = "order by a.inDate desc,b.ord desc"
		Case 104:
		cateCondition = " AND (charindex(',"&uid&",',','+b.share+',')>0 or share='1') "
		
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.name title,convert(varchar(19),b.date1,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		orderBy = "order by a.inDate desc,b.ord desc"
		Case 54:
		cateCondition = " AND (CHARINDEX(',"&uid&",',','+b.share+',')>0 OR share='1') "
		
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN chance b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(19),b.date1,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
		Case 201:
		cateCondition = " AND (CHARINDEX(',"&uid&",',','+b.share+',')>0 OR share='1') "
		
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN contract b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(10),b.date3,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
		Case 202:
		cateCondition = " AND (CHARINDEX(',"&uid&",',','+b.share+',')>0 OR share='1') "
		
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN tousu b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(19),b.date7,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate [cateid]"
		orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
		Case 203:
		Dim workPosition : workPosition = cn.execute("SELECT workPosition FROM gate WHERE ord = "& uid)(0).value
		cateCondition = " AND (CHARINDEX(',"&uid&",',','+cast(b.share1 as varchar(8000))+',')>0 OR CHARINDEX(',"&uid&",',','+cast(b.share2 as varchar(8000))+',')>0 OR CHARINDEX(',"&workPosition&",',','+cast(b.postView as varchar(8000))+',')>0 OR CHARINDEX(',"&workPosition&",',','+cast(b.postDown as varchar(8000))+',')>0) "
		'Dim workPosition : workPosition = cn.execute("SELECT workPosition FROM gate WHERE ord = "& uid)(0).value
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN document b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del=1 AND (b.sp = 0 AND b.cateid_sp = 0)" & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title title,convert(varchar(19),b.date7,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate [cateid]"
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 64:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND sp > 0) OR (cateid_sp = 0  AND ((ISNULL(cateid,0) = 0 AND addcate = " & uid & ") or (ISNULL(cateid,0) > 0 AND cateid = " & uid & ")))) "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN chance b ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3)  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid, " &_
		"(CASE WHEN (cateid_sp = 0 OR sp < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
		"(case sp when -1 then 12 when 0 then 11 else 10 end) orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
		Case 53:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateadd")
		cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND sp > 0) OR (cateid_sp = "& uid &" AND sp=-1) OR (cateid_sp = 0  AND cateadd = "& uid &" )) "
		'cateCondition = getCondition(m_qxlb,m_listqx,"b.cateadd")
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.name title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
		"(CASE WHEN (cateid_sp = 0 OR sp < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
		"(case when sp<0 then 15 when cateid_sp = 0 then 14 else 13 end) orderStat"
		orderBy = "order by a.inDate desc,b.ord desc"
		Case 13:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " AND b.ord in ( SELECT mr.ord FROM dbo.price mr  with(nolock)   "&_
		"   inner join sp_ApprovalInstance c  with(nolock) on c.gate2=13001 and c.PrimaryKeyID = mr.ord and c.BillPattern in (0,1)  "&_
		"   WHERE mr.del<>2 and ((mr.status in (-1,0,1) and isnull(mr.Cateid,mr.Addcate) =" & uid &") "&_
		"   or (mr.status in (2,4,5) and charindex('," & uid &",',','+ c.SurplusApprover +',')>0))) "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN price b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) " & vbcrlf &_
		"inner join sp_ApprovalInstance c on c.gate2=13001 and c.PrimaryKeyID = b.ord and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
		"(case when c.ApprovalFlowStatus in (-1,0,1,3) then 1 else 0 end) canCancelAlt," &_
		"(case status when 0 then 16 when 4 then 10 when 5 then 8 when 2 then 12 else 11 end) orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
		Case 14:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " AND b.ord in ( SELECT mr.ord FROM dbo.contract mr  with(nolock)   "&_
		"   inner join sp_ApprovalInstance c  with(nolock) on c.gate2=11001 and c.PrimaryKeyID = mr.ord and c.BillPattern in (0,1)  "&_
		"   WHERE mr.del<>2 and ((mr.status in (-1,0,1) and case when isnull(mr.Cateid,0)>0 then mr.Cateid else mr.Addcate end =" & uid &") "&_
		"   or (mr.status in (2,4,5) and charindex('," & uid &",',','+ c.SurplusApprover +',')>0))) "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN contract b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) "&vbcrlf &_
		"inner join sp_ApprovalInstance c on c.gate2=11001 and c.PrimaryKeyID = b.ord and c.BillPattern in (0,1) " &_
		"WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
		"(case when c.ApprovalFlowStatus in (-1,0,1,3) then 1 else 0 end) canCancelAlt," &_
		"(case status when 0 then 16 when 4 then 10 when 5 then 8 when 2 then 12 else 11 end) orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
		Case 69:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND sp > 0) OR (cateid_sp = 0  AND addcate = " & uid & "))  "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN contractth b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
		"(CASE WHEN (cateid_sp = 0 OR sp < 0) THEN 1 ELSE 0 END) canCancelAlt, " &_
		"(case sp when -1 then 12 when 0 then 11 else 10 end) orderStat" &_
		orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
		Case 16:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN caigou b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) "&_
		"inner join sp_ApprovalInstance c on c.gate2=73001 and c.PrimaryKeyID = b.ord and c.BillPattern in (0,1) " &_
		"WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
		" 0 canCancelAlt,(case b.status when -1 then 17 when 0 then 16 when 1 then 11 when 2 then 12 when 3 then 9 when 4 then 10 when 5 then 8 else 10 end)  orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
		Case 60:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " AND ( (kg = "& uid &" AND complete1 = 1 and isnull(b.status,-1) in (-1,1)) OR (complete1 > 1  AND cateid = "& uid &" ) ) "
		'cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN kuin b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del = 1 WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
		"(CASE WHEN (kg = 0 OR complete1 IN (2,3)) THEN 1 ELSE 0 END) canCancelAlt, " &_
		"(case isnull(status,-1) when 1 then 11 else 17 end) orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
		Case 61001:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join kuin b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c on c.gate2=61001 and c.PrimaryKeyID = b.ord and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title,b.date7 dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.date7 desc"
		Case 62001:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join kuout b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=62001 and c.PrimaryKeyID = b.ord and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title,b.date7 dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.date7 desc"
		Case 23701:
		DIM MCYG,MCBJ
		MCYG=FALSE
		MCBJ=FALSE
		if ZBRuntime.MC(14000) then
			MCYG=TRUE
		end if
		if ZBRuntime.MC(4000) then
			MCBJ=TRUE
		end if
		sql ="select COUNT(*) REMIND_CNT from"& _
		"("& _
		"select A.id,A.cateid,1 ismode,title,date1,date7  from"& _
		"("& _
		"select "& _
		"cai.id,count(c.id) cid,count(x.id)xid,cai.date7,cai.date1,cai.title,cai.cateid "& _
		"from caigou_yg cai  with(nolock)  "& _
		"inner join caigoulist_yg c  with(nolock) on  cai.id=c.caigou "& _
		"left join xunjialist x  with(nolock) on c.id=x.caigoulist_yg and x.caigoulist_yg>0 and x.del=1 "& _
		"left join xunjia xu  with(nolock) on xu.id=x.xunjia and xu.fromtype<>0 "&_
		"left join gate g  with(nolock) on g.ord=cai.cateid  "& _
		"left join power p  with(nolock) on p.ord="&uid&" and p.sort1=25 and p.sort2=1"&_
		"                                 ""where  cai.del=1 and cai.status=0  AND '""&MCYG&""'='TRUE'   and ISNULL(cai.xunjia,0)=0 and needxj=1 and (p.qx_open=3 or  CHARINDEX(','+CAST(cai.cateid AS VARCHAR(20))+',',','+CAST(p.qx_intro AS VARCHAR(8000))+',') > 0) GROUP BY cai.id,cai.date7,cai.date1,cai.title,g.name,cai.cateid,cai.ygid " & _
		")A WHERE (A.cid>0 AND xid=0) or(A.cid>0 And xid>0 And xid<A.cid)  "& _
		"union all  "& _
		"select p.ord,p.cateid cateid,0 ismode,p.title,p.date1,p.date7 from price p  with(nolock) "& _
		"left join gate gg  with(nolock) on gg.ord=p.addcate "& _
		" left join power po  with(nolock) on po.ord="&uid&" and po.sort1=4 and po.sort2=1"&_
		"where (p.complete=1 or p.complete=8) and p.del=1 AND '"&MCBJ&"'='TRUE' and p.xj=1 and  exists(select 1 from pricelist  with(nolock) where price =p.ord AND xunjiastatus!=1)"&_
		"AND NOT exists(select 1 from xunjialist a  with(nolock)  "&_
		"inner join xunjia b  with(nolock) on a.xunjia=b.id and b.del=1 "&_
		"INNER join tel c on a.gys=c.ord and c.sort3=2 "&_
		"where b.price=p.ord)"&_
		" and (po.qx_open=3 or CHARINDEX(','+CAST(p.cateid AS VARCHAR(20))+',',','+CAST(po.qx_intro AS VARCHAR(8000))+',') > 0)"& _
		")C left join power pow on pow.ord= "&uid&"  and pow.sort1=24 and pow.sort2=13    WHERE (pow.qx_open=3 or CHARINDEX(','+CAST(C.cateid AS VARCHAR(20))+',',','+CAST(pow.qx_intro AS VARCHAR(8000))+',') > 0) AND 1=1"& _
		"[ORDERBY]"
		fields = "C.id [id],(case when C.ismode=1 THEN '来自预购:'+ C.title else '来自报价:'+ C.title end) title,0 [rid],C.cateid,-1 newTag, CAST(CONVERT(varchar(10), C.date1 , 120)as datetime)  dt"
		
		orderBy = "ORDER BY C.date7 DESC"
		Case 61:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " AND ( (kg = "& uid &" AND complete1 = 1 and isnull(b.status,-1) in (-1,1)) ) "
		'cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN kuout b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del = 1 WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
		"(CASE WHEN (kg = 0 OR complete1 IN (2,3)) THEN 1 ELSE 0 END) canCancelAlt, " &_
		"(case isnull(status,-1) when 1 then 11 else 17 end) orderStat"
		
		orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
		Case 62:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " AND ( ("& iif(openPower(33,16) > 0,"1=1","1=2") &" AND complete1 = 0) OR (complete1 = 1  AND cateid = "& uid &" ) ) "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN send b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
		"(CASE WHEN (addcate = 0 OR complete1 = 1) THEN 1 ELSE 0 END) canCancelAlt," &_
		"(case complete1 when 0 then 10 when 1 then 11 else 10 end) orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
		Case 50:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.Creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN payoutsure b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ID AND b.del = 1  " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=44011 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.ID DESC"
		Case 43012:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.Creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.Creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock)  " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN PaybackInvoiceSure b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ID AND b.del = 1  " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=43012 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.ID DESC"
		Case 44012:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.Creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.Creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN PayoutInvoiceSure b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ID AND b.del = 1  " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=44012 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.ID DESC"
		Case 65:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN bankin2 b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) " & vbcrlf &_
		" inner join sp_ApprovalInstance c on c.gate2=43001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		" WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],cast(b.title as varchar(8000)) title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
		"(CASE WHEN (cateid_sp = 0 OR sp < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
		"(case status_sp when 2 then 12 when 1 then 11 else 10 end) orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 206:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN bankout2 b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) " & vbcrlf &_
		" inner join sp_ApprovalInstance c  with(nolock) on c.gate2=44001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		" WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],cast(b.title as varchar(8000)) title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator as cateid,"&_
		"(CASE WHEN (ISNULL(cateid_sp,0) = 0 OR ISNULL(sp,0) < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
		"(case status_sp when 2 then 12 when 1 then 11 else 10 end) orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 205:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.addcate")
		cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND complete = 2) OR (complete = 3  AND addcate = "& uid &" )) "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN caigouQC b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del = 1 WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate [cateid],"&_
		"(CASE WHEN (cateid_sp = 0 OR complete < 0 OR complete = 3) THEN 1 ELSE 0 END) canCancelAlt, " &_
		"(case complete when -1 then 12 when 3 then 11 else 10 end) orderStat"
		
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 40:
		cateCondition = getCondition(m_qxlb,m_listqx,"addcateid")
		cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND complete not in (1,3)) OR (complete in (1,3) AND addcateid = "& uid &" )) "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN paysq b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcateid [cateid],"&_
		"(CASE WHEN complete in (1,3) THEN 1 ELSE 0 END) canCancelAlt," &_
		"(case complete when 3 then 12 when 1 then 11 else 10 end) orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 41:
		cateCondition = getCondition(m_qxlb,m_listqx,"cateid")
		cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND complete not in (2,3)) OR (complete in (2,3) AND cateid = "& uid &" )) "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN paybx b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid [cateid],"&_
		"(CASE WHEN (cateid_sp = 0 OR sp_id < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
		"(case complete when 2 then 12 when 3 then 11 else 10 end) orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 42:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.sorce2")
		cateCondition = cateCondition & " AND ((isnull(gate_sp,0) = "& uid &" AND sp_id > 0) OR (isnull(sp_id,0) = 0  AND sorce2 = "& uid &" )) "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN payjk b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.sorce2 [cateid],"&_
		"(CASE WHEN (isnull(gate_sp,0) = 0 OR sp_id < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
		"(case sp_id when -1 then 12 when 0 then 11 else 10 end) orderStat"
		
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"""
		Case 43:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " AND ((cateid_sp = "& uid &" AND complete IN (7,11)) OR ((complete = 8 OR complete = 12)  AND addcate = "& uid &" )) "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN pay b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
		"(CASE WHEN (cateid_sp = 0 OR complete = 8 OR complete = 12) THEN 1 ELSE 0 END) canCancelAlt," &_
		"(case complete when 12 then 12 when 8 then 11 else 10 end) orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
		Case 71:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_NeedPerson b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(19),b.indate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 44:
		cateCondition = getCondition(m_qxlb,m_listqx,"c.use_cateid")
		cateCondition = cateCondition &" AND d.send_cateid = "& uid &" "
		sql = "SELECT COUNT(*) REMIND_CNT FROM (" & vbcrlf &_
		"select distinct b.id [id],c.use_title title,convert(varchar(19),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,b.id [rid],c.use_cateid [cateid],a.inDate,c.id cid " & vbcrlf &_
		"from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN O_MeetingSummary b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id " & vbcrlf &_
		"INNER JOIN O_MeetingUse c  with(nolock) ON c.id = b.sum_metId " & vbcrlf &_
		"INNER JOIN O_SummarySend d  with(nolock) ON d.send_meetingid = b.id " & vbcrlf &_
		"WHERE 1 = 1 AND d.send_type = 1 AND d.send_issucceed = 1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] "&vbcrlf &_
		") bbb [ORDERBY]"
		fields = "[id],title,dt,newTag,[rid],[cateid],inDate,cid"
		orderBy = "ORDER BY inDate DESC,cid DESC"
		Case 56:
		tmpCondition = ""
		If m_fw1&""="0" Then
			tmpCondition = ""
		else
			tmpCondition = " and c.cateid=" & uid & " "
		end if
		cateCondition = "and (" & vbcrlf
		Call fillinPower(1,5,qOpen,qIntro)
		cateCondition = cateCondition & " ( c.sort1=1 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(2,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( c.sort1=8 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(3,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( c.sort1=2 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(4,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( c.sort1=3 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(5,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( c.sort1=4 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(22,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( c.sort1=5 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(41,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( c.sort1=6 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(42,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( c.sort1=7 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(75,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( c.sort1=75 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(95,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( c.sort1=102001 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(96,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( c.sort1=102002 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (c.cateid is not null and c.cateid<>0 and c.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		cateCondition = cateCondition & " ) "
		cateCondition = " and (( 1=1 " & tmpCondition & " " & cateCondition & ") or c.share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(c.share as varchar(8000)),' ','')+',')>0)" & vbcrlf
		cateCondition = cateCondition & " ) "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN dianping b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id " &_
		"INNER JOIN reply c  with(nolock) ON c.id = b.ord " &_
		"LEFT JOIN tel d  with(nolock) ON d.ord = c.ord " &_
		"WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.intro title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],0 [cateid]"
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 57:
		cateCondition = " AND isnull(order1,0) = "& uid &" "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN plan1 b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord WHERE b.complete='2' " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.intro title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],0 [cateid]"
		orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
		Case 58:
		cateCondition = " AND isnull(cateid,0) = "& uid &" "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN plan2 b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.type IN (17,12,13,14,15,16) WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],cast(b.intro as varchar(8000)) title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],0 [cateid]"
		orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
		Case 18:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN payback b  with(nolock) ON a.reminderConfig=" & configId & " AND (a.orderId = -b.ord or a.orderId = b.ord) AND b.del = 1 AND complete = '3' WHERE 1 = 1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],'@code:FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		
		orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
		Case 207:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.ret_addcateid")
		cateCondition = cateCondition & " AND ((ret_bcateid = "& uid &" AND ret_state = 1 ) OR (ret_state > 1 AND Exit Sub_addcateid = "& uid &" )) "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN O_proReturn b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.ret_del = 1 WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.ret_title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.ret_addcateid [cateid],"&_
		"(CASE WHEN (ret_bcateid = 0 OR ret_state > 1) THEN 1 ELSE 0 END) canCancelAlt, " &_
		"(case ret_state when 3 then 12 when 2 then 11 else 10 end) orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 208:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.get_addcateid")
		cateCondition = cateCondition & " AND ((get_storecateid = "& uid &" AND get_store = 2 ) OR (get_store <> 2 AND get_addcateid = "& uid &" )) "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN O_productOut b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.get_del = 1 WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.get_title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.get_addcateid [cateid],"&_
		"(CASE WHEN (get_storecateid = 0 OR get_store <> 2) THEN 1 ELSE 0 END) canCancelAlt, " &_
		"(case get_store when 3 then 12 when 1 then 11 else 10 end) orderStat"
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 8:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
		cateCondition = " and ((1=1" & cateCondition & ") or CHARINDEX(',"&uid&",',','+b.share+',')>0 OR share='0') "
		'cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) "&_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN learnhd b  with(nolock) on a.orderId = b.ord AND b.del = 1 " &_
		" WHERE a.reminderConfig=" & configId & " [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "ISNULL(b.ord,0) [id],isnull(b.title,'【已删除数据】') title,isnull(convert(varchar(19),b.date7,21),'----') dt,"&_
		"DATEDIFF(s,' & actDate & "
		orderBy = "ORDER BY a.id DESC"
		Case 209:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN payoutsure b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ID AND b.del = 1  " & vbcrlf &_
		"left join sortbz d  with(nolock) on d.id=b.bz " & vbcrlf &_
		"WHERE 1 = 1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ID [id],  '@code:""'+b.title+'('+isnull(d.intro,'RMB')+' "" & FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)&""'+')'+'""' title,"&_
		"convert(varchar(19),a.inDate,21) dt,datediff(s,'&actDate&"
		orderBy = "ORDER BY a.inDate DESC,b.ID DESC"
		Case 210:
		cateCondition = " AND ((b.khzt <> 1 AND EXISTS (SELECT 1 FROM hr_perform_sp_list  with(nolock) WHERE sortID = b.sortid AND sp_id = "& uid &")) OR (b.khzt = 1 AND (CAST(b.user_list AS VARCHAR) = '0' OR CHARINDEX(',"& uid &",' , ','+ CAST(b.user_list AS VARCHAR) +',') > 0)) )"
		
		cateCondition = cateCondition & " AND DATEDIFF(d,sp_Time1,GETDATE()) >= 0 AND DATEDIFF(d,sp_Time2,GETDATE()) <= 0 "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN hr_perform_sort b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del = 0 WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator [cateid]"
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 211:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN paybackInvoice b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del = 1 " & vbcrlf &_
		"left join sortbz c  with(nolock) on c.id=b.bz " & vbcrlf &_
		"WHERE 1 = 1 AND b.isInvoiced <> 3  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],'@code:""'+isnull(c.intro,'RMB')+' "" & FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(10),b.invoiceDate,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 212:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN payoutInvoice b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del = 1 " & vbcrlf &_
		"WHERE 1 = 1 AND b.del = 1 AND b.isInvoiced in (1,2) " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.[id],'@code:FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(19),b.invoiceDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid "
		
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 10:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"c.cateid")
		cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN kujhlist b  with(nolock) on a.reminderConfig="&configId&" and a.orderId=b.id and b.del=1 " & vbcrlf &_
		"inner Join kujh c  with(nolock) on b.kujh=c.ord and c.del=1 " & vbcrlf &_
		"inner join product d on d.ord=b.ord " & vbcrlf &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],c.title+'('+d.title+')' title,CONVERT(VARCHAR(10),b.date2,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],c.cateid [cateid]"
		
		orderBy = "order by b.date2 DESC,b.date7 DESC"
		Case 20:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		storelist_sort5 = "0"
		Set rsUsConfig= conn.execute("select isnull(tvalue,'0') tvalue from home_usConfig where name='storelist_sort5' and isnull(uid, 0) =" &  session("personzbintel2007") )
		If rsUsConfig.eof= False Then
			storelist_sort5=rsUsConfig("tvalue")
		end if
		rsUsConfig.close
		showKuLimitZeroSQL = ""
		if storelist_sort5 = "0" then
			showKuLimitZeroSQL = " and (isnull(b.alert1,0)>0 or isnull(b.alert2,0)>0)"
		end if
		showzore =0
		Set rsUsConfig= conn.execute("select (case cast(tvalue as varchar(10)) when '1' then 1 else 0 end) v from home_usConfig  with(nolock) where uid="& session("personzbintel2007") &" and name='storelist_sort1' ")
		if rsUsConfig.eof=false  then
			showzore = rsUsConfig("v").value
		end if
		rsUsConfig.close
		unkuinwarning = 0
		if showzore="1" then
			Set rsUsConfig= conn.execute("select (case cast(tvalue as varchar(10)) when '1' then 1 else 0 end) v from home_usConfig  with(nolock) where uid="& session("personzbintel2007") &" and name='storelist_warning' ")
			if rsUsConfig.eof=false  then
				unkuinwarning = rsUsConfig("v").value
			end if
			rsUsConfig.close
		end if
		showZeroSQL = ""
		if showzore = "0" then
			showZeroSQL = " and isnull(b.ku_num,0)>0 "
		else
			if unkuinwarning="0" then
				showZeroSQL = " and exists(select 1 from ku where ord =a.ord) "
			end if
		end if
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen = 1 Then
			cateCondition = " and charindex(','+cast(b.addcate as varchar)+',',',"&qIntro&",')>0 "
			
		else
			cateCondition = " and 1=2 "
		end if
		If withoutCateCondition Then
			tmpCondition = ""
		else
			tmpCondition = "inner join sortck subc on subc.id = suba.ck "& vbcrlf &_
			"and subc.del=1 "& vbcrlf &_
			"and ("& vbcrlf &_
			"charindex('," & uid & ",',','+replace(cast(subc.intro as varchar(4000)),' ','')+',')>0 "& vbcrlf &_
			"or replace(cast(subc.intro as varchar(4000)),' ','') = '0'"& vbcrlf &_
			")"
		end if
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN ("&vbcrlf & _
		"SELECT a.ord,addcate,title," & vbcrlf & _
		"(CASE WHEN Isnull(aleat1, 0) = 0 THEN 0 ELSE Isnull(aleat1,0) END) AS alert1, " & vbcrlf & _
		"(CASE WHEN Isnull(aleat2, 0) = 0 THEN 0 ELSE Isnull(aleat2,0) END) AS alert2, " & vbcrlf & _
		"date7,Isnull(ku_num, 0) ku_num " & vbcrlf & _
		"FROM product a " & vbcrlf & _
		"LEFT JOIN ("&vbcrlf & _
		"SELECT ord,Sum(numjb) AS ku_num FROM ("&vbcrlf & _
		"SELECT suba.ord," & vbcrlf & _
		"(CASE WHEN suba.unit = subb.unitjb THEN num2 " & vbcrlf & _
		"ELSE num2 * Isnull((SELECT TOP 1 bl FROM jiage  with(nolock) WHERE product = suba.ord AND unit = suba.unit),0) " & vbcrlf & _
		"END) numjb " & vbcrlf & _
		"FROM ku suba  with(nolock) " & vbcrlf & _
		"INNER JOIN product subb  with(nolock) ON suba.ord = subb.ord " & vbcrlf & _
		"tmpCondition" & vbcrlf &_
		") subaa " & vbcrlf & _
		"GROUP BY ord " & vbcrlf & _
		") AS b ON a.ord = b.ord " & vbcrlf & _
		"WHERE a.del = 1 "& showZeroSQL&" AND (isnull(ku_num,0)<=aleat1 or isnull(ku_num,0)>aleat2) " & vbcrlf & _
		") AS b ON a.orderid = b.ord "& showKuLimitZeroSQL &" AND a.reminderConfig=" & configId & " " & vbcrlf & _
		"WHERE 1 = 1 " & vbcrlf & _
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title," &_
		"CASE WHEN [Ku_num]<[alert1] then '↓'+cast(dbo.formatnumber([Ku_num]," & numDigit & ",0) as nvarchar(50)) " & _
		"WHEN [Ku_num]>[alert2] then '↑" &_
		"END dt," &_
		"DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate [cateid]"
		orderBy = "order by title desc,date7 desc"
		Case 49:
		cateCondition = getCondition(m_qxlb,m_listqx,"c.personID")
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_person_health c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.id " & vbcrlf &_
		"INNER JOIN hr_person b  with(nolock) ON b.userID = c.personID " & vbcrlf & _
		"where 1=1 AND Isnull(c.alt, 1) < 2 and b.del = 0 AND c.lastdate IS NOT NULL "&_
		"AND c.zhouqi IS NOT NULL AND b.nowstatus NOT IN (2,3,4) " & vbcrlf &_
		"and DATEDIFF(m,GETDATE(),b.contractEnd)>0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]" & vbcrlf
		fields = "c.id [id],b.username title,CONVERT(VARCHAR(10)," & _
		"(CASE c.unit " & vbcrlf & _
		"WHEN 1 THEN Dateadd(yyyy, c.zhouqi, c.lastdate) " & vbcrlf & _
		"WHEN 2 THEN Dateadd(qq, c.zhouqi, c.lastdate) " & vbcrlf & _
		"WHEN 3 THEN Dateadd(m, c.zhouqi, c.lastdate) " & vbcrlf & _
		"WHEN 4 THEN Dateadd(ww, c.zhouqi, c.lastdate) " & vbcrlf & _
		"WHEN 5 THEN Dateadd(d, c.zhouqi, c.lastdate) " & vbcrlf & _
		"ELSE NULL " & vbcrlf & _
		"END )" & vbcrlf &_
		",23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],c.personID [cateid]"
		orderBy = "order by dt DESC"
		Case 66:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1 & " "
		cateCondition = cateCondition & " and charindex('," & uid &",',','+cast(isnull(b.alt,'') as varchar(4000))+',')=0"
		'cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1 & " "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN " & vbcrlf & _
		"(" & vbcrlf &_
		"SELECT z.id,t.name,t.cateid,s.title,z.date2,cast(isnull(z.alt,'') as varchar(4000)) alt,t.share " & vbcrlf & _
		"FROM tel t  with(nolock) " & vbcrlf & _
		"INNER JOIN sortFieldsContent z  with(nolock) " & vbcrlf & _
		"ON z.ord = t.ord " & vbcrlf & _
		"AND z.del = 1 " & vbcrlf & _
		"AND t.del = 1 " & vbcrlf & _
		"AND z.sort = 1 " & vbcrlf & _
		"AND t.sort3 = 2 " & vbcrlf & _
		"AND t.isNeedQuali = 1 " & vbcrlf & _
		"AND ISNULL(t.status_sp_qualifications, 0) = 0 " & vbcrlf & _
		"AND LEN(z.date2) > 0 " & vbcrlf & _
		"AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
		"AND CHARINDEX(',"& uid &",', ',' + CAST(z.share AS VARCHAR(4000)) + ',') > 0 " & vbcrlf & _
		"INNER JOIN sortClass s with(nolock)  " & vbcrlf & _
		"ON z.sortid = s.id " & vbcrlf & _
		"AND ISNULL(s.isStop, 0) = 0 " & vbcrlf & _
		"AND s.sort1 = 2 " & vbcrlf & _
		") b ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbcrlf & _
		"WHERE 1 = 1 " & vbcrlf & _
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.name title,CONVERT(VARCHAR(10),b.date2,23) dt,DATEDIFF(s,'"&actDate&"',b.date2) newTag,a.id [rid],b.cateid [cateid]"
		orderBy = "order by b.date2 DESC"
		Case 67:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1 & " "
		cateCondition = cateCondition & " and charindex('," & uid &",',','+cast(isnull(b.alt,'') as varchar(4000))+',')=0"
		'cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1 & " "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN " & vbcrlf & _
		"("&_
		"SELECT z.id,t.name,t.cateid,s.title,z.date2,cast(isnull(z.alt,'') as varchar(4000)) alt,t.share " & vbcrlf & _
		"FROM tel t  with(nolock) " & vbcrlf & _
		"INNER JOIN sortFieldsContent z  with(nolock) " & vbcrlf & _
		"ON z.ord = t.ord " & vbcrlf & _
		"AND z.del = 1 " & vbcrlf & _
		"AND t.del = 1 " & vbcrlf & _
		"AND z.sort = 1 " & vbcrlf & _
		"AND t.sort3 = 1 " & vbcrlf & _
		"AND t.isNeedQuali = 1 " & vbcrlf & _
		"AND ISNULL(t.status_sp_qualifications, 0) = 0 " & vbcrlf & _
		"AND LEN(z.date2) > 0 " & vbcrlf & _
		"AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
		"AND CHARINDEX(',"& uid &",', ',' + CAST(z.share AS VARCHAR(4000)) + ',') > 0 " & vbcrlf & _
		"INNER JOIN sortClass s  with(nolock) " & vbcrlf & _
		"ON z.sortid = s.id " & vbcrlf & _
		"AND ISNULL(s.isStop, 0) = 0 " & vbcrlf & _
		"AND s.sort1 = 2 " & vbcrlf & _
		") b ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbcrlf & _
		"WHERE 1 = 1 " & vbcrlf & _
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.name title,CONVERT(VARCHAR(10),b.date2,23) dt,DATEDIFF(s,'"&actDate&"',b.date2) newTag,a.id [rid],b.cateid [cateid]"
		orderBy = "ORDER BY b.date2 DESC"
		Case 213:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN " & vbcrlf & _
		"( " & vbCrLf &_
		"  SELECT a.id,a.date1,a.date7,a.cateid,ISNULL(a.money1,0) money1,b.intro bz FROM paybackinvoice a  with(nolock)  " & vbCrLf &_
		"  INNER JOIN sortbz b  with(nolock) ON b.id = a.bz " & vbCrLf &_
		"  WHERE a.del = 1 AND isInvoiced = 0  AND ISNULL(a.cateid,0) <> 0 " & vbCrLf &_
		") b ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
		"WHERE 1 = 1 " & vbcrlf & _
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],'@code:""'+isnull(b.bz,'RMG')+' "" & FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,CONVERT(VARCHAR(10),b.date1,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		
		orderBy = "ORDER BY b.date1 DESC,b.date7 DESC"
		Case 214:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN payoutInvoice b  with(nolock) ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
		"left JOIN sortbz d  with(nolock) ON d.id = b.bz " & vbCrLf &_
		"WHERE 1 = 1 AND b.del = 1 AND b.isInvoiced in (0,11) " & vbcrlf & _
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.[id],'@code:""'+isnull(d.intro,'RMB')+' "" & FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,CONVERT(VARCHAR(10),b.date1,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		
		orderBy = "ORDER BY b.date1 DESC,b.date7 DESC"
		Case 52:
		cateCondition = cateCondition & " AND daysFromNow <= " & m_tq1 * 24
		sql = "" &_
		"SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join ku k  with(nolock) on a.orderId=k.id and a.reminderConfig=" & configId &" " & vbcrlf &_
		"INNER JOIN product p  with(nolock) ON p.ord = k.ord " & vbcrlf &_
		"INNER JOIN sortck ck  with(nolock) ON k.ck = ck.ord AND ck.del = 1 " & vbcrlf &_
		"where (" & vbcrlf & _
		"CAST(ISNULL(ck.intro,'') AS VARCHAR(4000)) = '0' " & vbcrlf &_
		"OR CHARINDEX(',"&uid&",', ',' + CAST(ck.intro AS VARCHAR(4000)) + ',') > 0 " & vbcrlf &_
		") " & vbcrlf &_
		"AND p.del = 1 " & vbcrlf &_
		"AND k.num2 > 0 " & vbcrlf &_
		"AND p.RemindNum > 0 " & vbcrlf &_
		"AND CHARINDEX(',"&uid&",', ',' + ISNULL(p.RemindPerson, '') + ',') > 0 " & vbcrlf &_
		"AND k.dateyx IS NOT NULL " & vbcrlf &_
		"AND ISNULL(k.locked, 0) = 0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "k.id [id],p.title,CONVERT(VARCHAR(10),k.dateyx,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],p.addcate [cateid]"
		orderBy = "ORDER BY k.dateyx DESC,p.date7 DESC"
		Case 51:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.addcateid")
		cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1 & " AND b.addcateid = "& uid &" "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN " & vbcrlf & _
		"( " & vbCrLf &_
		"  SELECT a.id,d.id lid, c.bk_name, a.ld_rettime, d.addcateid " & vbcrlf &_
		"  FROM O_Lendbookmx a  with(nolock) " & vbcrlf &_
		"  LEFT JOIN O_Lendbook d  with(nolock) ON a.Ld_fid=d.id " & vbcrlf &_
		"  LEFT JOIN O_regbook c  with(nolock) ON a.Ld_bkid=c.id " & vbcrlf &_
		"  WHERE a.ld_num > (SELECT isnull(sum(Ret_num),0) AS Ret_num FROM O_RetBookmx  with(nolock) WHERE Ret_bkid=a.id) " & vbcrlf &_
		") b ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
		"WHERE 1 = 1 " & vbcrlf & _
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.lid [id],b.bk_name title,CONVERT(VARCHAR(10),b.ld_rettime,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcateid [cateid]"
		orderBy = "ORDER BY b.ld_rettime DESC"
		Case 59:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.userId")
		cateCondition = cateCondition & " AND DATEDIFF(d,getdate(),b.Reguldate)<=" & m_tq1 & " "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN " & vbcrlf & _
		"( " & vbCrLf &_
		"  SELECT a.ID,a.Reguldate,a.UserId,a.userName name " & vbcrlf &_
		"  FROM hr_person a  with(nolock) " & vbcrlf &_
		"  WHERE  a.nowStatus = 5 AND a.del = 0 " & vbcrlf &_
		") b ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
		"WHERE 1 = 1 " & vbcrlf & _
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.name title,CONVERT(VARCHAR(10),b.Reguldate,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.UserId [cateid]"
		orderBy = "ORDER BY b.Reguldate DESC"
		Case 215:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1 & " "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN " & vbcrlf & _
		"Chance b  with(nolock) ON a.orderID = b.ord AND a.reminderConfig=" & configId & " " & vbCrLf &_
		"WHERE 1 = 1 AND b.del = 1 AND b.cateid > 0 " & vbcrlf & _
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,'距离回收' + CAST(daysFromNow AS VARCHAR) + '天' dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid [cateid]"
		
		orderBy = "ORDER BY b.date7 DESC"
		Case 300:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.addcate")
		cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1 & " "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN " & vbcrlf & _
		"document b  with(nolock) ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
		"WHERE 1 = 1 AND b.del = 1  AND validity = 2 AND (b.sp = 0 AND b.cateid_sp = 0) AND b.addcate = "& uid &" " & vbcrlf & _
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title title,CONVERT(VARCHAR(10),b.date4,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate [cateid]"
		orderBy = "ORDER BY b.date7 DESC"
		Case 301:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.addcate")
		cateCondition = cateCondition & " AND a.daysFromNow<=" & m_tq1 & " "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN " & vbcrlf & _
		"documentlist b  with(nolock) ON a.orderID = b.id AND a.reminderConfig=" & configId & " " & vbCrLf &_
		"inner join document d on d.id = b.document "  & vbCrLf &_
		"WHERE 1 = 1 AND d.del = 1 and b.del=1  AND b.l_validity = 2 AND (d.sp = 0 AND d.cateid_sp = 0) AND d.addcate = "& uid &" " & vbcrlf & _
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.oldname title,CONVERT(VARCHAR(10),b.l_date4,23) dt,DATEDIFF(s,'"&actDate&"',a.inDate) newTag,a.id [rid],d.addcate [cateid]"
		orderBy = "ORDER BY b.date7 DESC"
		Case 105:
		tmpCondition = getConditionByFW(m_qxlb,m_listqx,"b.reg_addcateid")
		If withoutCateCondition Then tmpCondition = ""
		cateCondition = getConditionByFW(m_qxlb,15,"b.prod_addcateid")
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join o_product b on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
		"inner join ( " & vbcrlf &_
		"select replace(prod_id,' ','') as ProductID,replace(prod_unit,' ','') as UnitId,sum(prod_num) as ku_num " & vbcrlf &_
		"from o_kuinlist a  with(nolock) " & vbcrlf &_
		"left join o_kuin b  with(nolock) on a.reg_fid=b.id " & vbcrlf &_
		"where 1=1 " & tmpCondition & " " & vbcrlf &_
		"group by prod_id,prod_unit " & vbcrlf &_
		") c on b.id=c.ProductID and a.daysFromNow=c.UnitId " & vbcrlf &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.prod_name title,(" & _
		"CASE when [Ku_num]<[prod_less] then '↓'+cast(dbo.formatnumber([Ku_num]," & numDigit & ",0) as nvarchar(50)) " & _
		"fields = ""b.id [id],b.prod_name title,(""" &_
		"when [Ku_num]>[prod_more] then '↑"
		fields = "b.id [id],b.prod_name title,(" & _
		"end " & _
		") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.prod_addcateid cateid"
		orderBy = "order by b.prod_name desc"
		Case 106:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.name title,'距离回收' + cast(daysFromNow as varchar) + '天' dt,"&_
		"datediff(s,'&actDate&" &_
		orderBy = "order by daysFromNow asc"
		Case 107:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_AppHoliday b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where (" & vbcrlf &_
		"KQClass in (" & vbcrlf &_
		"select id from hr_KQClass  with(nolock) where sortID=1 and del=0 " & vbcrlf &_
		") or KQClass=1 " & vbcrlf &_
		") and del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(19),startTime,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.id desc"
		Case 108:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_AppHoliday b with(nolock)  on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where (" & vbcrlf &_
		"KQClass in (" & vbcrlf &_
		"select id from hr_KQClass  with(nolock) where sortID=2 and del=0 " & vbcrlf &_
		") or KQClass=2 " & vbcrlf &_
		") and del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(19),startTime,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 109:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_AppHoliday b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where (" & vbcrlf &_
		"KQClass in (" & vbcrlf &_
		"select id from hr_KQClass  with(nolock) where sortID=3 and del=0 " & vbcrlf &_
		") or KQClass=3 " & vbcrlf &_
		") and del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(19),startTime,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 110:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((sp=-1 or sp=0) and cateid="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"cateCondition = cateCondition & ""and (""" & vbcrlf &_
		"or (sp>0 and cateid_sp=&uid&) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join wages b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"where del=1 and isnull(salaryClass,0)>0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],title,cast(year(date2) as varchar)+'年'+cast(month(date2) as varchar)+'月' dt,"&_
		"datediff(s,'&actDate&" &_
		"(case when sp=-1 or sp=0 then 1 else 0 end) canCancelAlt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],cateid,"&_
		"(case sp when -1 then 12 when 0 then 11 else 10 end) orderStat"
		orderBy = "order by b.date7 desc,b.date3 desc"
		Case 111:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((sp=-1 or sp=0) and cateid="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"cateCondition = cateCondition & ""and (""" & vbcrlf &_
		"or (sp>0 and cateid_sp=&uid&) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join wages b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"where del=1 and isnull(salaryClass,0)=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],title,cast(year(date2) as varchar)+'年'+cast(month(date2) as varchar)+'月' dt,"&_
		"datediff(s,'&actDate&" &_
		"(case when sp=-1 or sp=0 then 1 else 0 end) canCancelAlt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],cateid,"&_
		"(case sp when -1 then 12 when 0 then 11 else 10 end) orderStat"
		orderBy = "order by b.date7 desc,b.date3 desc"
		Case 217:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.designer")
		cateCondition = cateCondition & " AND ( (cateid_sp = "& uid &" AND id_sp > 0) OR (cateid_sp = 0  AND designer = "& uid &" ) ) "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		" INNER JOIN design b  with(nolock) ON a.reminderConfig="& configId &" AND a.orderId = b.id and b.del=1 AND b.designstatus in (7,8,9) WHERE 1 = 1"& vbcrlf &_
		" [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id], b.title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.designer as cateid,"&_
		"(CASE WHEN (cateid_sp = 0 OR id_sp < 0) THEN 1 ELSE 0 END) canCancelAlt," &_
		"(case id_sp when -1 then 12 when 0 then 11 else 10 end) orderStat"
		
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 218:
		cateCondition = getCondition(m_qxlb,15,"c.designer")
		cateCondition = cateCondition & " AND  charindex(',"& uid &",',','+replace(reminders,' ','')+',')>0 "
		'cateCondition = getCondition(m_qxlb,15,"c.designer")
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		" INNER JOIN reply b  with(nolock) ON a.reminderConfig="& configId &" AND a.orderId = b.id AND b.del=1 and b.sort1 = 5029 "& vbcrlf &_
		" inner join design c  with(nolock) on c.id = b.ord2       "&_
		" where b.del =1 " & vbcrlf &_
		" [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id], b.title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid], b.cateid "
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 112:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and cateid_moi in ("&qIntro&") "
		else
			cateCondition = " and 1=2"
		end if
		cateCondition = cateCondition & " and Cateid_MOI=" & uid
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M_ManuOrderIssueds b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		orderBy = "order by b.inDate desc"
		Case 113:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and b.id in (select distinct b.id from reminderQueue a  with(nolock) " & vbcrlf &_
			"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"left join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+b.Cateid_WA+',')>0" & vbcrlf &_
			"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" AND plist.sort1 = 54 AND plist.sort2 = 1" & vbcrlf &_
			"where b.del=1 and b.ptype=0 and tempSave=0 and b.[status]<>2 AND ISNULL(b.SPStatus,-1) IN(-1,1)" & vbcrlf &_
			"and (plist.qx_open = 3 OR CHARINDEX(','+CAST(g1.ord AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0))"
		else
			cateCondition = " and 1=2"
		end if
		cateCondition = cateCondition & " and charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(Cateid_WA,' ','')+',')>0"
		cateCondition = " and 1=2"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join product p  with(nolock) on p.ord = b.productid "&_
		"where b.del=1 and ptype=0 and tempSave=0 and b.[status]<>2 AND ISNULL(b.SPStatus,-1) IN(-1,1) and CONVERT(varchar(10),b.inDate,120) <= CONVERT(varchar(10),GETDATE(),120)"&_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title +' ('+ p.title +')' as title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		
		orderBy = "order by b.inDate desc"
		Case 224:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = ""
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and b.id in (select distinct b.id from reminderQueue a  with(nolock) " & vbcrlf &_
			"inner join erp_M2_WorkAssigns_status b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"left join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+b.Cateid_WA+',')>0" & vbcrlf &_
			"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" AND plist.sort1 = 54 AND plist.sort2 = 1" & vbcrlf &_
			"where b.del=1 and b.ptype=0 and tempSave=0 and b.[status]<>2 and b.wastatus!='生产完毕' AND ISNULL(b.SPStatus,-1) IN(-1,1)" & vbcrlf &_
			"and (plist.qx_open = 3 OR CHARINDEX(','+CAST(g1.ord AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0))"
		else
			cateCondition = " and 1=2"
		end if
		If m_fw1&""="1" Then
			tmpCondition = " and charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(Cateid_WA,' ','')+',')>0"
			'If m_fw1&""="1" Then
		end if
		cateCondition =  " " & tmpCondition & " " & cateCondition & " and datediff(d,getdate(),b.dateEnd)<=" & m_tq1 & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join erp_M2_WorkAssigns_status b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join product p  with(nolock) on p.ord = b.productid "&_
		"where b.del=1 and b.ptype=0 and tempSave=0 and b.[status]<>2 and b.wastatus!='生产完毕' AND ISNULL(b.SPStatus,-1) IN(-1,1)" &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title +' ('+ p.title +')' as title ,b.dateEnd dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		
		orderBy = "order by b.DateEnd, b.inDate desc"
		Case 225:
		tmpCondition = ""
		cateCondition = ""
		sql = "select COUNT(*) REMIND_CNT from dbo.v_attendance_GetRemind a   with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"where exists(select top 1 g.ord from dbo.gate g  with(nolock) where g.ord="& uid &" and g.orgsid=a.orgsid and g.Partadmin=1)" &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "a.Id [id],a.userName as title,a.WorkLong,a.RemindUnit,GETDATE() as dt,a.LogDate as newTag,a.Id [rid],a.Id cateid"
		orderBy = "order by a.LogDate desc"
		Case 5013:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			cateCondition = ""
		else
			cateCondition = " and 1=2"
		end if
		cateCondition = cateCondition & " and charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(Cateid_WA,' ','')+',')>0"
		cateCondition = " and 1=2"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join product p  with(nolock) on p.ord = b.productid "&_
		"where b.del=1 and b.ptype=1 and tempSave=0 and b.[status]<>2 and CONVERT(varchar(10),b.inDate,120) = CONVERT(varchar(10),GETDATE(),120)" & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title +' ('+ p.title +')' as title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		
		orderBy = "order by b.inDate desc"
		Case 54015:
		tmpCondition = ""
		cateCondition = ""
		sql = "select COUNT(*) REMIND_CNT from erp_fn_GetForSJWorkAssigns(''," & uid & ") a " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_WorkAssigns b  with(nolock) on a.ID=b.ID "&_
		"where " &_
		" exists(" &_
		"SELECT 1 from dbo.gate gt  with(nolock) " &_
		"inner join power sjpow  with(nolock) ON sjpow.ord =" & uid & " AND sjpow.sort1 =(case isnull(b.ptype,0) when 0 then 54 else 62 end) and sjpow.sort2=1 " &_
		"WHERE  (sjpow.qx_open = 3 OR CHARINDEX(','+CAST(gt.ord AS VARCHAR(20))+',',','+CAST(sjpow.qx_intro AS VARCHAR(8000))+',') > 0) " &_
		"and CHARINDEX(','+CAST(gt.ord AS VARCHAR(20))+',',','+ISNULL(b.Cateid_WA,-1)+',') > 0)" &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "a.Id [id],a.title as title,a.inDate as dt,datediff(s,'"&actDate&"',a.inDate) as newTag,a.Id [rid],a.Creator cateid"
		orderBy = "order by a.inDate desc"
		Case 54106:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		cateCondition = ""
		cateCondition = cateCondition & " and (charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(QcCateid as varchar(12)),' ','')+',')>0 or exists(" &_
		"select top 1 1 from dbo.M2_OneSelfQualityTestingTaskList ttl  with(nolock) " &_
		" where ttl.TaskID=b.ID and charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(ttl.QcCateid as varchar(12)),' ','')+',')>0))"
		sql = "select COUNT(*) REMIND_CNT from (select MAX(b.id) as ID,b.orderId,reminderConfig,max(inDate) inDate from reminderQueue b  with(nolock) group by b.orderId,reminderConfig) a """ & vbcrlf &_
		"[CANCELJOINTABLE] " & _
		"inner join M2_OneSelfQualityTestingTask b with(nolock)  on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
		"where b.[QCStatus]<>2 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title +' ('+ b.TaskBh +')' as title,convert(varchar(10),b.TaskDate,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		
		orderBy = "order by b.inDate desc"
		Case 5014:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = ""
		If m_fw1&""="2" Then
			If qOpen = 3 Then
				tmpCondition = ""
			ElseIf qOpen=1 Then
				tmpCondition = " and b.id in (select distinct b.id from M2_WorkAssigns b  with(nolock)  " & vbcrlf &_
				"inner join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+b.Cateid_WA+',')>0" & vbcrlf &_
				"tmpCondition = "" and b.id in (select distinct b.id from M2_WorkAssigns b  with(nolock)  """ & vbcrlf &_
				"where g1.ord in (& qIntro &) )"
			else
				tmpCondition = " and 1=2"
			end if
		else
			tmpCondition = " and charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(Cateid_WA,' ','')+',')>0 "
			tmpCondition = " and 1=2"
		end if
		cateCondition =  " " & tmpCondition & " " & cateCondition & " and datediff(d,getdate(),b.dateEnd)<=" & m_tq1 & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join product p  with(nolock) on p.ord = b.productid "&_
		"where b.del=1 and ptype=1 and tempSave=0 and b.[status]<>2 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title +' ('+ p.title +')' as title ,b.dateEnd dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		
		orderBy = "order by b.inDate desc "
		Case 114:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M_ManuPlans b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 and b.status=3 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		orderBy = "order by b.inDate desc"
		Case 115:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M_ManuOrders b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 and b.status=3 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		orderBy = "order by b.inDate desc"
		Case 116:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M_OutOrder b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 and b.status=3 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		orderBy = "order by b.inDate desc"
		Case 117:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M_MaterialProgres b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		orderBy = "order by b.inDate desc"
		Case 118:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M_QualityTestings b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where b.qtype<>1 and del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		orderBy = "order by b.inDate desc"
		Case 119:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.creator")
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M_QualityTestings b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where b.qtype=1 and del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		orderBy = "order by b.inDate desc"
		Case 120:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.name title,'距离保护到期' + cast(daysFromNow as varchar) + '天' dt,"&_
		"datediff(s,'&actDate&"
		orderBy = "order by daysFromNow asc"
		Case 121:
		cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.name title,'下次联系：' + convert(varchar(10),dateadd(d,daysFromNow,'2014-01-01'),23) dt,"&_
		"datediff(s,'&actDate&"
		orderBy = "order by daysFromNow asc"
		Case 122:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_ret_plan b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.id desc"
		Case 123:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_Resume b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.keyword title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.id desc"
		Case 124:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_interview b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],dbo.HrGetResumeName(b.resumeID) title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.id desc"
		Case 125:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_train_plan b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.id desc"
		Case 126:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_expaper b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.id desc"
		Case 127:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_person_salary b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],ISNULL((SELECT TOP 1 name FROM gate  with(nolock) WHERE ord = b.cateid), '用户' + CAST(b.cateid AS varchar(10)) + '【已删】') title,"&_
		"convert(varchar(10),a.inDate,21) dt," &_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.id desc"
		Case 128:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_person_contract b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.id desc"
		Case 129:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_regime b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.id desc"
		Case 130:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_positive b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.id desc"
		Case 131:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_leave b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.id desc"
		Case 132:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_Transfer b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.id desc"
		Case 133:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_off_staff b with(nolock)  on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.gateName title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.id desc"
		Case 134:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=3 or status=2) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_reinstate b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.gateName title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=3 or status=2 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.id desc"
		Case 135:
		Set rs_setting = cn.execute("select workPosition FROM gate  with(nolock) WHERE ord ="& uid &"")
		workPosition = rs_setting("workPosition")
		If Len(workPosition&"") = 0 Then workPosition = 0
		rs_setting.close
		cateCondition = "and (" & vbcrlf &_
		"((spFlag=1 or spFlag=-1) and addcate="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"cateCondition = ""and (""" & vbcrlf &_
		"or ((spFlag=2 or spFlag=3) and cateid_sp=&uid&) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join document b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"left join power p  with(nolock) on p.ord="& uid &" and sort1=78 and sort2=1 " & vbcrlf &_
		"left join power p1  with(nolock) on p1.ord="& uid &" and p1.sort1=78 and p1.sort2=16 "&_
		"where  del=1 " & vbcrlf &_
		"and (p1.qx_open = 3  OR (CHARINDEX(','+CAST(b.addcate AS VARCHAR(20))+',',','+CAST(p1.qx_intro AS VARCHAR(max))+',') > 0)"& vbcrlf &_
		"or (b.addcate="& uid &" and  (b.spFlag = 1 or b.spFlag=-1)) "&_
		" ) "& vbcrlf &_
		"and (p.qx_open = 3 OR (CHARINDEX(','+CAST(b.addcate AS VARCHAR(20))+',',','+CAST(p.qx_intro AS VARCHAR(max))+',') > 0"& vbcrlf &_
		" ) "& vbcrlf &_
		"or  CHARINDEX(','+ CONVERT(varchar(20),"& uid &") +',', ','+isnull(cast(b.share1 as varchar(8000)),0)+',')>0  " & vbcrlf &_
		" ) "& vbcrlf &_
		"or CHARINDEX(','+ CONVERT(varchar(20),"& workPosition &") +',', ','+isnull(cast(b.postDown as varchar(8000)),0)+',')>0  "&_
		" ) "& vbcrlf &_
		"or CHARINDEX(','+ CONVERT(varchar(20),"& workPosition &") +',', ','+isnull(cast(b.postView as varchar(8000)),0)+',')>0  "&_
		" ) "& vbcrlf &_
		"or (b.addcate="& uid &" and  (b.spFlag = 1 or b.spFlag=-1)) "&_
		" ) "& vbcrlf &_
		"or  CHARINDEX(','+ CONVERT(varchar(20),"& uid &") +',', ','+isnull(cast(b.share2 as varchar(8000)),0)+',')>0  ))" & vbcrlf &_
		" ) "& vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate cateid," &_
		"(case when spFlag=1 or spFlag=-1 then 1 else 0 end) canCancelAlt,"&_
		"datediff(s,'&actDate&"
		orderBy = "order by b.id desc"
		Case 136:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = ""
		If m_fw1&""="0" Then
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
				tmpCondition = " and (cateid is not null and cateid<>0)"
			else
				cateCondition = " and 1=2"
			end if
		else
			cateCondition = " and cateid=" & uid
		end if
		cateCondition = " " & cateCondition & " " & tmpCondition & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join xunjia b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(10),b.date7,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		orderBy = "order by b.date7 desc"
		Case 137:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If m_fw1&""="0" Then
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and ("_
				&" (addcate is not null and addcate<>0 and addcate in ("&qIntro&")) "_
				&" or (catelead is not null and catelead<>0 and catelead in ("&qIntro&")) "_
				&" or (cate1 is not null and cate1<>0 and cate1 in ("&qIntro&")) "_
				&" or (cate2 is not null and cate2<>0 and cate2 in ("&qIntro&")) "_
				&" or (cate3 is not null and cate3<>0 and cate3 in ("&qIntro&")) "_
				&" or (cate4 is not null and cate4<>0 and cate4 in ("&qIntro&")) "_
				&" or (cate5 is not null and cate5<>0 and cate5 in ("&qIntro&")) "_
				&" or (cate6 is not null and cate6<>0 and cate6 in ("&qIntro&")) "_
				&" or (cate7 is not null and cate7<>0 and cate7 in ("&qIntro&")) "_
				&" or (cate8 is not null and cate8<>0 and cate8 in ("&qIntro&")) "_
				&" or (member1 is not null and member1<>0 and member1 in ("&qIntro&")) "_
				&" or share='0' or charindex(',"&uid&",',','+replace(share,' ','')+',')>0 "_
				&" )"
			else
				cateCondition = " and 1=2"
			end if
		else
			cateCondition = " and ("_
			&" (addcate is not null and addcate<>0 and addcate ="&uid&") "_
			&" or (catelead is not null and catelead<>0 and catelead in ("&uid&")) "_
			&" or (cate1 is not null and cate1<>0 and cate1 in ("&uid&")) "_
			&" or (cate2 is not null and cate2<>0 and cate2 in ("&uid&")) "_
			&" or (cate3 is not null and cate3<>0 and cate3 in ("&uid&")) "_
			&" or (cate4 is not null and cate4<>0 and cate4 in ("&uid&")) "_
			&" or (cate5 is not null and cate5<>0 and cate5 in ("&uid&")) "_
			&" or (cate6 is not null and cate6<>0 and cate6 in ("&uid&")) "_
			&" or (cate7 is not null and cate7<>0 and cate7 in ("&uid&")) "_
			&" or (cate8 is not null and cate8<>0 and cate8 in ("&uid&")) "_
			&" or (member1 is not null and member1<>0 and member1 in ("&uid&")) "_
			&" or share='0' or charindex(',"&uid&",',','+replace(share,' ','')+',')>0 "_
			&" )"
		end if
		cateCondition = " " & cateCondition & " " & tmpCondition & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join tousu b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title,convert(varchar(19),b.date7,"& iif(m_isMobileMode,"21","23") &") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate cateid"
		orderBy = "order by b.date7 desc"
		Case 138:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			cateCondition = ""
			tmpCondition = " and (catein = " & uid & ") "
		ElseIf qOpen=1 Then
			cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
			tmpCondition = " and (catein = " & uid & ") "
		else
			cateCondition = " and 1=2"
		end if
		cateCondition = cateCondition & tmpCondition
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join kumove b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"where del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid"
		orderBy = "order by b.ord desc"
		Case 139:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.addcate")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=0 or status=4) and addcate="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=1 or status=2) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join maintain b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"where del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate cateid," &_
		"(case when status=0 or status=4 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 0 then 11 when 4 then 12 else 10 end) orderStat"
		orderBy = "order by b.ord desc"
		Case 140:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
		else
			cateCondition = " and 1=2"
		end if
		tmpCondition = ""
		If m_fw1&""="0" Then
			tmpCondition = " "
		else
			tmpCondition = " and cateid=" & uid
		end if
		cateCondition = " " & cateCondition & " " & tmpCondition & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join caigou b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title,convert(varchar(10),b.date7,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		orderBy = "order by b.date7 desc"
		Case 141:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = ""
		If m_fw1&""="0" Then
			If qOpen = 3 Then
				cateCondition = ""
			ElseIf qOpen=1 Then
				cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
				tmpCondition = " and (cateid is not null and cateid<>0)"
			else
				cateCondition = " and 1=2"
			end if
		else
			cateCondition = " and cateid=" & uid
		end if
		cateCondition = " " & cateCondition & " " & tmpCondition & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join caigou_yg b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(10),b.date7,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		orderBy = "order by b.date7 desc"
		Case 142:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			cateCondition = ""
			tmpCondition = " and (cateout = " & uid & ") "
		ElseIf qOpen=1 Then
			cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
			tmpCondition = " and (cateout = " & uid & ") "
		else
			cateCondition = " and 1=2"
		end if
		cateCondition = cateCondition & tmpCondition
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join kumove b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"where del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid"
		orderBy = "order by b.ord desc"
		Case 143:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
		else
			cateCondition = " and 1=2"
		end if
		Call fillinPower(24,13,qOpen,qIntro)
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition &  " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		Call fillinPower(4,14,qOpen,qIntro)
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition &  " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & tmpCondition
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join price b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del in (3,1) and complete in (1,8)  " & vbcrlf &_
		"where del in (3,1) " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(10),b.date1,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid"
		orderBy = "order by b.ord desc"
		Case 144:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			cateCondition = ""
			tmpCondition = " and (Inspector = " & uid & ") "
		ElseIf qOpen=1 Then
			cateCondition = " and addcate is not null and addcate<>0 and addcate in ("&qIntro&") "
			tmpCondition = " and (Inspector = " & uid & ") "
		else
			cateCondition = " and 1=2"
		end if
		cateCondition = cateCondition & tmpCondition
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join caigouqc b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del = 1 and b.complete in (0,1)  " & vbcrlf &_
		"where del =1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate cateid"
		orderBy = "order by b.id desc"
		Case 145:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status=0 or status=3) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=1 or status=2) and cateid_sp="&uid&") /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join budget b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"where del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=0 or status=3 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 0 then 11 when 3 then 12 else 10 end) orderStat"
		orderBy = "order by b.ord desc"
		Case 146:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = ""
		If m_fw1="0" Then
			tmpCondition = ""
		else
			tmpCondition = " and (cateid=" & uid & ") "
		end if
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and ((cateid is not null and cateid<>0 and cateid in ("&qIntro&")) or share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0) "
			
		else
			cateCondition = " and (share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0)"
			
		end if
		cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join chance b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title,convert(varchar(19),b.date7,"& iif(m_isMobileMode,"21","23") &") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		orderBy = "order by b.date7 desc"
		Case 147:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = ""
		If m_fw1="0" Then
			tmpCondition = ""
		else
			tmpCondition = " and ((order1=1 or order1=2) and cateid=" & uid & ") "
		end if
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and ((cateid is not null and cateid<>0 and cateid in ("&qIntro&")) or share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0) "
			
		else
			cateCondition = " and (share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0)"
			
		end if
		cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"where del =1 and isnull(sp,0)=0 and sort3=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.name [title],convert(varchar(19),b.date2,"& iif(m_isMobileMode,"21","23") &") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		orderBy = " order by b.date2 desc "
		Case 148:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateadd")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((isnull(status_sp_qualifications,0)=0 or status_sp_qualifications=4) and isnull(cateid,cateadd)="&uid&") " & vbcrlf &_
		"/*审批通过或终止的提醒给采购人员或添加人*/" & vbcrlf &_
		"or " & vbcrlf &_
		"((status_sp_qualifications=1 or status_sp_qualifications=2) and cateid_sp_qualifications="&uid&") " & vbcrlf &_
		"/*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join sortFieldsContent c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.id and c.del = 1 " & vbcrlf &_
		"inner join tel b  with(nolock) on c.ord = b.ord and b.del=1 " & vbcrlf &_
		"where b.del=1 and sort3=2 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "c.id [id],b.name title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateadd cateid," &_
		"(case when isnull(status_sp_qualifications,0)=0 or status_sp_qualifications=4 then 1 else 0 end) canCancelAlt,"&_
		"(case isnull(status_sp_qualifications,0) when 0 then 11 when 4 then 12 else 10 end) orderStat"
		orderBy = "order by b.ord desc"
		Case 149:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateadd")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"((status_sp_qualifications=0 or status_sp_qualifications=4) and isnull(cateid,cateadd)=" & uid & ") " & vbcrlf &_
		"/*审批通过或终止的提醒给销售人员或添加人*/" & vbcrlf &_
		"or "&_
		"((status_sp_qualifications=1 or status_sp_qualifications=2) and cateid_sp_qualifications=" & uid & ") " & vbcrlf &_
		"/*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join sortFieldsContent c  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = c.id and c.del = 1 " & vbcrlf &_
		"inner join tel b  with(nolock) on c.ord = b.ord and b.del=1 " & vbcrlf &_
		"where b.sort3=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "c.id [id],b.name title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateadd cateid," &_
		"(case when isnull(status_sp_qualifications,0)=0 or status_sp_qualifications=4 then 1 else 0 end) canCancelAlt,"&_
		"(case isnull(status_sp_qualifications,0) when 0 then 11 when 4 then 12 else 10 end) orderStat"
		orderBy = "order by b.ord desc"
		Case 70:
		cateCondition = " @MyPower_1_102 and (" & vbcrlf &_
		"((use_complete=4 or use_complete=3) and use_addcateid="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((use_complete=1 or use_complete=2) and use_cateid_sp="&uid&" @MyPower_16_102) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			tmpCondition = ""
		ElseIf qOpen=1 Then
			tmpCondition = " and use_addcateid is not null and use_addcateid<>0 and use_addcateid in ("&qIntro&") "
		else
			tmpCondition = " and 1=2"
		end if
		cateCondition = Replace(cateCondition,"@MyPower_1_102",tmpCondition)
		tmpCondition = ""
		cateCondition = Replace(cateCondition,"@MyPower_16_102",tmpCondition)
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join O_carUse b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.use_id and b.use_del=1 " & vbcrlf &_
		"inner join gate g  with(nolock) on b.use_cateid = g.ord " & vbcrlf &_
		"where use_del=1 and use_type=1 and b.del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.use_id [id],g.name title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.use_addcateid cateid," &_
		"(case when use_complete=3 or use_complete=4 then 1 else 0 end) canCancelAlt,"&_
		"(case use_complete when 3 then 11 when 4 then 12 else 10 end) orderStat"
		orderBy = "order by b.use_id desc"
		Case 150:
		cateCondition = " @MyPower_1_102 and (" & vbcrlf &_
		"((status=2 or status=3) and creator="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or ((status=0 or status=1) and cateid_sp="&uid&" @MyPower_16_102) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			tmpCondition = ""
		ElseIf qOpen=1 Then
			tmpCondition = " and creator is not null and creator<>0 and creator in ("&qIntro&") "
		else
			tmpCondition = " and 1=2"
		end if
		cateCondition = Replace(cateCondition,"@MyPower_1_102",tmpCondition)
		tmpCondition = ""
		'cateCondition = Replace(cateCondition,"@MyPower_16_102",tmpCondition)
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join hr_perform_ss b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=0 " & vbcrlf &_
		"where del=0 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when status=2 or status=3 then 1 else 0 end) canCancelAlt,"&_
		"(case status when 3 then 11 when 2 then 12 else 10 end) orderStat"
		orderBy = "order by b.id desc"
		Case 151:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = ""
		If m_fw1&""="0" Then
			tmpCondition = ""
		else
			tmpCondition = " and cateid=" & uid & " "
		end if
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and ((addcate is not null and addcate<>0 and addcate in ("&qIntro&")) or share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0) "
			
		else
			cateCondition = " and (1=2 or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0)"
			
		end if
		cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join contract b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 and isnull(b.status,-1) in (-1,1) " & vbcrlf &_
		"where del =1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title [title],convert(varchar(19),b.date7,"& iif(m_isMobileMode,"21","23") &") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		orderBy = "order by b.date1 desc,b.date7 desc"
		Case 152:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = ""
		If m_fw1&""="0" Then
			tmpCondition = ""
		else
			tmpCondition = " and cateid=" & uid & " "
		end if
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and ((addcate is not null and addcate<>0 and addcate in ("&qIntro&"))) "
		else
			cateCondition = " and 1=2"
		end if
		cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join price b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del in (1,3) and complete not in (1,8) " & vbcrlf &_
		"where del in (1,3) " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title [title],convert(varchar(10),b.date7,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		orderBy = "order by b.date1 desc,b.date7 desc"
		Case 153:
		cateCondition = " @MyPower_1_102 and (" & vbcrlf &_
		"((complete1<>1) and cateid="&uid&") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (complete1=1 and kg="&uid&" @MyPower_16_102) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			tmpCondition = ""
		ElseIf qOpen=1 Then
			tmpCondition = " and cateid is not null and cateid<>0 and cateid in ("&qIntro&") "
		else
			tmpCondition = " and 1=2"
		end if
		cateCondition = Replace(cateCondition,"@MyPower_1_102",tmpCondition)
		tmpCondition = ""
		'cateCondition = Replace(cateCondition,"@MyPower_16_102",tmpCondition)
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join kumove b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"where del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.title title,convert(varchar(10),a.inDate,21) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid cateid," &_
		"(case when complete1<>1 then 1 else 0 end) canCancelAlt,"&_
		"(case when complete1=4 or complete1=3 or complete1=5 then 11 when complete1=2 then 12 else 10 end) orderStat"
		orderBy = "order by b.ord desc"
		Case 154:
		tmpCondition = ""
		If m_fw1&""="0" Then
			tmpCondition = ""
		else
			tmpCondition = " and b.cateid=" & uid & " "
		end if
		cateCondition = "and (" & vbcrlf
		Call fillinPower(1,5,qOpen,qIntro)
		cateCondition = cateCondition & " ( b.sort1=1 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(2,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( b.sort1=8 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(3,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( b.sort1=2 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(4,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( b.sort1=3 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(5,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( b.sort1=4 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(22,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( b.sort1=5 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(41,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( b.sort1=6 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(42,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( b.sort1=7 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(75,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( b.sort1=75 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(95,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( b.sort1=102001 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		Call fillinPower(96,5,qOpen,qIntro)
		cateCondition = cateCondition & " or ( b.sort1=102002 "
		If qOpen = 3 Then
			cateCondition = cateCondition & ""
		ElseIf qOpen=1 Then
			cateCondition = cateCondition & " and (b.cateid is not null and b.cateid<>0 and b.cateid in ("&qIntro&")) "
		else
			cateCondition = cateCondition & " and 1=2"
		end if
		cateCondition = cateCondition & " ) "
		cateCondition = cateCondition & " ) "
		cateCondition = " and (( 1=1 " & tmpCondition & " " & cateCondition & ") or b.share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(b.share as varchar(8000)),' ','')+',')>0)" & vbcrlf
		cateCondition = cateCondition & " ) "
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join reply b with(nolock)  on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and ISNULL(b.alt,0) = 0 and b.id1 is null " & vbcrlf &_
		"inner join tel t  with(nolock) on t.ord = b.ord and t.del=1 and t.sort3=1 " & vbcrlf &_
		"where b.del =1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],cast(b.intro as varchar(8000)) [title],convert(varchar(19),b.date7,"& iif(m_isMobileMode,"21","23") &") dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		orderBy = "order by b.date7 desc"
		Case 155:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = " and iss_cateid=" & uid & " "
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and ((iss_addcateid is not null and iss_addcateid<>0 and iss_addcateid in ("&qIntro&") and car_addcateid in ("&qIntro&"))) "
		else
			cateCondition = " and 1=2"
		end if
		cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join O_insure b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.iss_id and b.iss_del=1 and b.iss_warn = 1 and DATEDIFF(D,GETDATE(),b.iss_endtime)<= "& m_tq1 &" " & vbcrlf &_
		" inner join O_carData c  with(nolock) on c.car_id = b.iss_carid "& vbcrlf &_
		" inner join O_carSet s  with(nolock) on s.setType=3 and s.id=b.iss_type "&_
		"where iss_del =1 and b.del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.iss_id [id],c.car_code+' ('+s.setname+')' title,iss_endtime dt,"&_
		"datediff(s,'&actDate&"
		orderBy = "order by iss_endtime desc"
		Case 157:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and (isnull(t.cateid,u.cateid) is not null and isnull(t.cateid,u.cateid)<>0 and u.cateid in ("&qIntro&")) "
		else
			cateCondition = " and 1=2 "
		end if
		tmpCondition = ""
		If m_fw1&""="2" Then
			tmpCondition = " and (isnull(t.cateid,0)=" & uid & " or isnull(u.cateid,0)=" & uid & ") "
		else
			tmpCondition = " and isnull(u.cateid,0)=" & uid & " "
		end if
		cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from MMsg_User u  with(nolock) " & vbcrlf &_
		"inner join ( " & vbcrlf &_
		"select userid,1 cnt,createtime lastTime from MMsg_Message  with(nolock) " & vbcrlf &_
		"where sendOrReceive = 1 and readed = 0 " & vbcrlf &_
		"and datediff(hh,dateadd(s,createTime,'1970-1-1 0:0:0'),getdate()) < 56 " & vbcrlf &_
		") m on u.id=m.userid " & vbcrlf &_
		"left join (" & vbcrlf &_
		"    select p.ord,tl.cateid from person p  with(nolock) " & vbcrlf &_
		"    left join tel tl on tl.ord = p.company " & vbcrlf &_
		") t on u.person=t.ord " & vbcrlf &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [ORDERBY]"
		fields = "u.id [id],u.nickname + '(' + cast(cnt as varchar) + ')' title,dateadd(hh,8,dateadd(s,lastTime,'1970-1-1 0:0:0')) dt,"&_
		"datediff(s,'&actDate&',dateadd(hh,8,dateadd(s,lastTime,'1970-1-1 0:0:0"
		
		orderBy = "order by m.lastTime desc"
		Case 219:
		cateCondition =  " AND (charindex(',"& uid &",',','+replace(share,' ','')+',')>0 or b.share='1' or exists(select 1 from noticelist  with(nolock) where notice = b.id and cateid = "& uid &") ) "
		
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		" INNER JOIN notice b  with(nolock) ON a.reminderConfig="& configId &" AND a.orderId = b.id AND b.del=1 "& vbcrlf &_
		" where b.del =1 " & vbcrlf &_
		" [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id], b.title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid], b.creator as cateid "
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 220:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & " AND b.Id in ( SELECT mr.Id FROM dbo.caigou_yg mr  with(nolock)   "&_
		"   inner join sp_ApprovalInstance c  with(nolock) on c.gate2=72001 and c.PrimaryKeyID = mr.Id and c.BillPattern in (0,1)  "&_
		"   WHERE mr.del<>2 and ((mr.status in (-1,0,1) and isnull(mr.Cateid,mr.Addcate) =" & uid &") "&_
		"   or (mr.status in (2,4,5) and charindex('," & uid &",',','+ c.SurplusApprover +',')>0))) "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"INNER JOIN caigou_yg b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND (b.del = 1 OR b.del = 3) WHERE 1 = 1  " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid,"&_
		"0 canCancelAlt, " &_
		"(case status when -1 then 17 when 0 then 16 when 1 then 11 when 2 then 12 when 3 then 9 when 4 then 10 when 5 then 8 else 10 end) orderStat"
		
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 17:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = ""
		If m_fw1&""="0" Then
			tmpCondition = ""
		else
			tmpCondition = " and ord=" & uid & " "
		end if
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and ((ord is not null and ord<>0 and ord in ("&qIntro&"))) "
		else
			cateCondition = " and 1=2"
		end if
		cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join "& vbcrlf &_
		" (select *,(select TOP 1 id from hr_person  with(nolock) where del = 0 AND userid=ord) as id from gate_person where del=1) "& vbcrlf &_
		" b on a.reminderConfig=" & configId & " and a.orderId = b.id and nowStatus not in (2,4) " & vbcrlf &_
		"where b.del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.name title,date3 dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.ord cateid"
		orderBy = "order by date3 desc"
		Case 156:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = ""
		If Me.isSupperAdmin Then
			tmpCondition = ""
		else
			tmpCondition = " and 1 = 2 "
		end if
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and ((ord is not null and ord<>0 and ord in ("&qIntro&"))) "
		else
			cateCondition = " and 1=2"
		end if
		cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join gate b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
		"where del =1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ord [id],b.name title,date3 dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.ord cateid"
		orderBy = "order by date3 desc"
		Case 222:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If sdk.power.existsPower(80,17) Then
			cateCondition = "  "
		else
			cateCondition = " and 1=2"
		end if
		cateCondition =  cateCondition &" AND ((b.DisposeUser=" & uid & " and b.TreatmentStatus = -1) ) "
		cateCondition = " and 1=2"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join HrKQ_AttendanceAppeal b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ID " & vbcrlf &_
		"left join HrKQ_AttendanceType c with(nolock)  on c.onlyid = b.reason " &_
		"where 1 =1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.ID [id],c.title title,b.CreateDate dt, datediff(s,'"& actDate &"',a.inDate) newTag,a.id [rid],b.userid cateid"
		orderBy = "order by b.CreateDate desc"
		Case 223 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.createID")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.CreateID="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (4,5) and charindex(',"& uid &",',','+ c.Approver +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join HrKQ_AttendanceApply b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.isdel=0 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=8 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.CreateDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.createid cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.CreateDate desc"
		Case 52001 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_ManuPlansPre b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=52001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 51005 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_BOM b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=51005 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 54001 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_ManuOrders b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=54001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 54002 :
		Dim qxOpen,qxIntro
		Call fillInPower(m_qxlb,m_listqx,qxOpen,qxIntro)
		If qxOpen = 3 Then
			cateCondition = ""
		ElseIf qxOpen = 1 Then
			cateCondition = " and b.id in (select distinct b.id from reminderQueue a  with(nolock) " & vbcrlf &_
			"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"left join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+b.Cateid_WA+',')>0" & vbcrlf &_
			"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" AND plist.sort1 = 54 AND plist.sort2 = 1" & vbcrlf &_
			"where b.del=1 and b.ptype=0 and tempSave=0 and b.[status]<>2" & vbcrlf &_
			"and (plist.qx_open = 3 OR CHARINDEX(','+CAST(g1.ord AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0))"
			
		else
			cateCondition = " and 1=2"
		end if
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_WorkAssigns b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c with(nolock) on c.gate2=54002 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 54003 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_OutOrder b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=54003 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 52002 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_ManuPlans b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=52002 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 55001 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_MaterialOrders b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and b.MaterialType in (1,2) " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=55001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 55006 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_MaterialOrders b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and b.MaterialType = 3 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=55006 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 56001 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.Approver +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_PriceRate b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=56001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 55002 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_MaterialRegisters b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and b.OrderType = 2 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=55002 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 55003 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_MaterialRegisters b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and b.OrderType = 3 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=55003 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 56007 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.Approver +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_TimeWages b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=56007 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 56008 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.Approver +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_Wage_JS b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c with(nolock)  on c.gate2=56008 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 160 :
		cateCondition =  " AND "& uid &"=b.cateid "
		sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		" INNER JOIN M2_RewardPunish b  with(nolock) ON a.reminderConfig="& configId &" AND a.orderId = b.id AND b.del=1 "& vbcrlf &_
		" where b.del =1 " & vbcrlf &_
		" [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id], b.title,convert(varchar(10),b.RPdate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid], b.creator as cateid "
		orderBy = "ORDER BY a.inDate DESC,b.id DESC"
		Case 54007:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = ""
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and M2WFPA.id in (select  M2WFPA.id from reminderQueue a  with(nolock) " & vbcrlf &_
			"inner join (SELECT M2WFPA.ID FROM M2_WFP_Assigns M2WFPA  with(nolock) " & vbcrlf &_
			"left join erp_Gxdqtx_status M2WA  with(nolock) on M2WFPA.WAID = M2WA.ID and M2WA.del = 1 and M2WA.tempSave = 0 " & vbcrlf &_
			"left join M2_WorkingProcedures M2WP  with(nolock) on M2WP.ID = M2WFPA.WPID  " & vbcrlf &_
			"left join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+isnull(M2WFPA.cateid,'')+','+isnull(M2WA.Cateid_WA,'')+','+isnull(M2WP.Wheelman,'')+',')>0  " & vbcrlf &_
			"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" and plist.sort1=5031 AND plist.sort2=1" & vbcrlf &_
			" where M2WFPA.del=1 and isnull(M2WFPA.isOut,0)=0  and tempSave=0 " & vbcrlf &_
			" AND (plist.qx_open = 3 or dbo.existsPower2(plist.qx_intro, isnull(M2WFPA.cateid, '') + ',' + isnull(M2WA.Cateid_WA, ''), ',') = 1) "& vbcrlf &_
			" AND M2WA.[Status]<>2  AND M2WA.wastatus!='生产完毕' AND ISNULL(M2WA.SPStatus,-1) IN(-1,1)"& vbcrlf &_
			" AND ISNULL(M2WFPA.Finished, 0) = 0"& vbcrlf &_
			" AND NOT EXISTS(SELECT 1 FROM M2_CostComputation  with(nolock) WHERE complete1=1 and datediff(mm,date1,M2WA.DateStart)=0)  GROUP BY M2WFPA.ID)  M2WFPA  ON  a.reminderConfig= " & configId & "  and a.orderId = M2WFPA.id) "
		else
			cateCondition = " and 1=2"
		end if
		If m_fw1&""="1" Then
			tmpCondition = " and charindex(','+cast(" & uid & " as varchar(12))+',',','+isnull(M2WFPA.cateid,'')+','+isnull(M2WA.Cateid_WA,'')+','+isnull(M2WP.Wheelman,'')+',')>0"
			'If m_fw1&""="1" Then
		else
			tmpCondition = " and (plist.qx_open = 3  OR CHARINDEX(','+CAST(g1.ord AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0)"
			'If m_fw1&""="1" Then
		end if
		cateCondition =  " " & tmpCondition & " " & cateCondition & " and datediff(d,getdate(),M2WFPA.dateEnd)<=" & m_tq1 & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join (SELECT  M2WFPA.id,M2WA.title,M2WP.WPName,M2WFPA.DateEnd,M2WFPA.cateid,M2WA.indate  from M2_WFP_Assigns M2WFPA   with(nolock)    " & vbcrlf &_
		"left join erp_Gxdqtx_status M2WA  with(nolock) on M2WFPA.WAID = M2WA.ID and M2WA.del = 1 and M2WA.tempSave = 0  " & vbcrlf &_
		"left join M2_WorkingProcedures M2WP  with(nolock) on M2WP.ID = M2WFPA.WPID   " & vbcrlf &_
		"left join gate g1  with(nolock) on CHARINDEX(','+CONVERT(nvarchar(100),g1.ord)+',',','+isnull(M2WFPA.cateid,'')+','+isnull(M2WA.Cateid_WA,'')+','+isnull(M2WP.Wheelman,'')+',')>0 " & vbcrlf &_
		"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" and plist.sort1=5031 AND plist.sort2=1 " & vbcrlf &_
		"WHERE  M2WFPA.del=1 and isnull(M2WFPA.isOut,0)=0  and charindex(','+cast(" & uid & " as varchar(12))+',',','+isnull(M2WFPA.cateid,'')+','+isnull(M2WA.Cateid_WA,'')+','+isnull(M2WP.Wheelman,'')+',')>0 and tempSave=0 " & vbcrlf &_
		" AND M2WA.[Status]<>2  AND M2WA.wastatus!='生产完毕' AND ISNULL(M2WA.SPStatus,-1) IN(-1,1) "& vbcrlf &_
		" AND ISNULL(M2WFPA.Finished, 0) = 0"& vbcrlf &_
		" AND NOT EXISTS(SELECT 1 FROM M2_CostComputation  with(nolock) WHERE complete1=1 and datediff(mm,date1,M2WA.DateStart)=0) "& vbcrlf &_
		"[CATECONDITION]  "& vbcrlf &_
		" GROUP BY  M2WFPA.id,M2WA.title,M2WP.WPName,M2WFPA.DateEnd,M2WFPA.cateid,M2WA.indate) M2WFPA ON  a.reminderConfig=" & configId & " and a.orderId = M2WFPA.id  "& vbcrlf &_
		"[CANCELCONDITION] [ORDERBY]"
		fields = "M2WFPA.id,isnull(M2WFPA.title,'')+'['+ISNULL(M2WFPA.WPName,'')+']' as title ,convert(varchar(10),M2WFPA.DateEnd,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],M2WFPA.cateid"
		
		orderBy = "order by M2WFPA.indate desc"
		Case 540071:
		tmpCondition = ""
		cateCondition = ""
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_WFP_Assigns wfpa  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = wfpa.id and wfpa.del=1 and isnull(wfpa.ExecTask,0) = 1 " & vbcrlf &_
		"inner join M2_WorkAssigns wa  with(nolock) on wfpa.waid = wa.id and wa.del=1 " & vbcrlf &_
		"inner join M2_WorkingProcedures wp  with(nolock) on wfpa.wpid = wp.id and wp.del=1 " & vbcrlf &_
		"where 1=1 and (dbo.existsPower2(wp.wheelman,'" & uid & "',',') = 1 or dbo.existsPower2(wfpa.cateid,'" & uid & "',',') = 1)" & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "wfpa.id [id],wa.title+'('+wp.WPName+')' as title,wa.inDate dt,datediff(s,'"&actDate&"',wa.inDate) newTag,a.id [rid],(wa.Cateid_WA+','+wp.wheelman+','+wfpa.cateid) cateid"
		
		orderBy = "order by wa.inDate desc"
		Case 540072:
		tmpCondition = ""
		cateCondition = ""
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_WFPTask_Assigns task  with(nolock) on a.reminderConfig=""" & configId & " and a.orderId = task.id and task.beginStatus = 0 and not exists(select top 1 1 from M2_ProcedureProgres  with(nolock) where del = 1 and TaskID = task.ID) and dbo.existsPower2(task.cateid,'" & uid & "',',') = 1" & vbcrlf &_
		"inner join M2_WFP_Assigns wfpa  with(nolock) on task.wfpaid = wfpa.id and wfpa.del=1 " & vbcrlf &_
		"inner join M2_WorkAssigns wa  with(nolock) on wfpa.waid = wa.id and wa.del=1 " & vbcrlf &_
		"inner join M2_WorkingProcedures wp  with(nolock) on wfpa.wpid = wp.id and wp.del=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "task.id [id],wa.title+'('+wp.WPName+')' as title,task.inDate dt,datediff(s,'"&actDate&"',task.inDate) newTag,a.id [rid],(wa.Cateid_WA+','+wp.wheelman+','+wfpa.cateid) cateid"
		
		orderBy = "order by task.inDate desc"
		Case 540073:
		tmpCondition = ""
		cateCondition = ""
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join (" & vbcrlf &_
		"   select isnull(batchid,id) id,indate,creator,wfpaid from M2_ProcedureProgres with(nolock) " & vbcrlf &_
		"   where del = 1 and checkresult = 2 and CheckPerson = "& uid &_
		"   group by isnull(batchid,id),indate,creator,wfpaid" & vbcrlf &_
		") aa on a.reminderConfig =  " & configId & " and a.orderId = aa.id" & vbcrlf &_
		"inner join M2_WFP_Assigns wfpa  with(nolock) on aa.wfpaid = wfpa.id and wfpa.del=1 " & vbcrlf &_
		"inner join M2_WorkAssigns wa  with(nolock) on wa.id = wfpa.waid " & vbcrlf &_
		"inner join M2_WorkingProcedures wp  with(nolock) on wfpa.wpid = wp.id and wp.del=1" & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "aa.[id],wa.title+'('+wp.WPName+')' as title,aa.inDate dt,datediff(s,'"&actDate&"',aa.inDate) newTag,a.[id] [rid],(wa.Cateid_WA+','+wp.wheelman+','+wfpa.cateid+','+cast(aa.Creator as varchar(20))) cateid"
		
		orderBy = "order by aa.inDate desc"
		Case 51001:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = ""
		cateCondition = " and charindex(','+CAST(" & uid & " as varchar(10))+',',','+replace(CONVERT(VARCHAR(8000),remindPerson),' ','')+',')>0 " &_
		"AND DATEDIFF(d, GETDATE() ,(CASE remindunit WHEN 1 THEN DATEADD(HOUR,remindcyc,begindate)  " &_
		"  WHEN 2 THEN DATEADD(DAY,remindcyc,begindate) END))<=" & m_tq1
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_MachineComponent b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id,b.title,convert(varchar(10),(CASE remindunit WHEN 1 THEN DATEADD(HOUR,remindcyc,begindate) "  &_
		"  WHEN 2 THEN DATEADD(DAY,remindcyc,begindate) END),23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.remindPerson as cateid"
		orderBy = "order by (CASE remindunit WHEN 1 THEN DATEADD(HOUR,remindcyc,begindate) "  &_
		"  WHEN 2 THEN DATEADD(DAY,remindcyc,begindate) END) desc,b.indate desc"
		Case 55004 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_MaterialRegisters b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 and b.OrderType = 1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=55004 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.date1 dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.date1 desc"
		Case 51011:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = ""
		cateCondition = " and charindex(','+CAST(" & uid & " as varchar(10))+',',','+replace(CONVERT(VARCHAR(8000),cateid),' ','')+',')>0 " &_
		"AND DATEDIFF(d, GETDATE() ,(CASE Unit2 WHEN 0 THEN DATEADD(MINUTE,num2,date1) " &_
		"  WHEN 1 THEN DATEADD(HOUR,num2,date1) WHEN 2 THEN DATEADD(DAY,num2,date1) WHEN 3 THEN DATEADD(MONTH,num2,date1) " &_
		"  WHEN 4 THEN DATEADD(YEAR,num2,date1) end))<=" & m_tq1
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a with(nolock)  " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_maintain b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id,b.title,convert(varchar(10),(CASE Unit2 WHEN 0 THEN DATEADD(MINUTE,num2,date1) " & vbcrlf &_
		"  WHEN 1 THEN DATEADD(HOUR,num2,date1) WHEN 2 THEN DATEADD(DAY,num2,date1) WHEN 3 THEN DATEADD(MONTH,num2,date1) " & vbcrlf &_
		"  WHEN 4 THEN DATEADD(YEAR,num2,date1) end),23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
		orderBy = "order by (CASE Unit2 WHEN 0 THEN DATEADD(MINUTE,num2,date1) " & vbcrlf &_
		"  WHEN 1 THEN DATEADD(HOUR,num2,date1) WHEN 2 THEN DATEADD(DAY,num2,date1) WHEN 3 THEN DATEADD(MONTH,num2,date1) " & vbcrlf &_
		"  WHEN 4 THEN DATEADD(YEAR,num2,date1) end) desc,b.indate desc"
		Case 54013:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If m_fw1&""="1" Then
			tmpCondition = " AND b.ourperson="& uid &""
		end if
		cateCondition = " where isnull(ool.Mergeinx,0)>=0 " & tmpCondition & " AND (plist.qx_open = 3  OR CHARINDEX(','+CAST(b.ourperson AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0) AND DATEDIFF(d, GETDATE() ,DateDelivery)<=" & m_tq1
		tmpCondition = " AND b.ourperson="& uid &""
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		"inner join M2_OutOrder b  with(nolock) on b.wwType=0 and  a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
		"inner join M2_OutOrderlists ool  with(nolock) on ool.outID = b.ID " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"left join dbo.power plist  with(nolock) ON plist.ord = & uid & AND plist.sort1 = 5025 AND plist.sort2 = 1" & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id,b.title,convert(varchar(10),ool.DateDelivery,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		orderBy = "order by ool.DateDelivery desc,b.indate desc"
		Case 54016:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		If m_fw1&""="1" Then
			tmpCondition = " AND b.ourperson="& uid &""
		end if
		cateCondition = " where isnull(ool.Mergeinx,0)>=0 " & tmpCondition & " AND (plist.qx_open = 3  OR CHARINDEX(','+CAST(b.ourperson AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0) AND DATEDIFF(d, GETDATE() ,DateDelivery)<=" & m_tq1
		'tmpCondition = " AND b.ourperson="& uid &""
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		"inner join M2_OutOrder b  with(nolock) on b.wwType=1 and a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
		"inner join M2_OutOrderlists ool  with(nolock) on ool.outID = b.ID " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" AND plist.sort1 = 5026 AND plist.sort2 = 1" & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id,b.title,convert(varchar(10),ool.DateDelivery,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		orderBy = "order by ool.DateDelivery desc,b.indate desc"
		Case 54006:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a   with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_OutOrder b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=54006 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 51003 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_WorkingFlows b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=51003 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.WFName,b.indate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.indate desc"
		Case 51005 :
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_BOM b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=51005 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.inDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 54009:
		Call fillinPower(m_qxlb,m_listqx,qOpen,"b.creator")
		cateCondition = cateCondition &" and CKUser ="& uid &_
		"   and ool.QTResult>0 and isnull(b.CkStatus,0)=0  AND DATEDIFF(d, GETDATE() ,QTDate)<=" & m_tq1
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_QualityTestings b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
		"inner join (select QTID,sum(QTResult) QTResult from M2_QualityTestingLists  with(nolock) where del=1 group by QTID) ool on ool.QTID = b.ID " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id,b.title,convert(varchar(10),b.QTDate,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		orderBy = "order by b.QTDate desc"
		Case 54004:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition =cateCondition & " and CKUser ="& uid &_
		" and ool.QTResult>0 and isnull(b.CkStatus,0)=0 AND DATEDIFF(d, GETDATE() ,QTDate)<=" & m_tq1
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_QualityTestings b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id " & vbcrlf &_
		"inner join (select QTID,sum(QTResult) QTResult from M2_QualityTestingLists  with(nolock) where del=1 group by QTID) ool on ool.QTID = b.ID " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id,b.title,convert(varchar(10),b.QTDate,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		orderBy = "order by b.QTDate desc"
		Case 57004:
		tmpCondition = ""
		cateCondition = ""
		sql = "select COUNT(*) REMIND_CNT from (" & vbcrlf &_
		" SELECT t.ID,t.Title,t.TaskDate,t.Creator,tl.QcCateid FROM dbo.M2_GXQualityTestingTask t  with(nolock) " & vbcrlf &_
		" INNER JOIN dbo.M2_GXQualityTestingTaskList tl  with(nolock) ON t.ID = tl.TaskID " & vbcrlf &_
		" WHERE tl.QCStatus != 2 GROUP BY t.ID,t.Title,t.TaskDate,t.Creator,tl.QcCateid " & vbcrlf &_
		" ) a " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"where a.QcCateid ="& uid &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "a.ID [id],a.Title as title,a.TaskDate as dt,a.TaskDate as newTag,a.ID [rid],a.Creator cateid"
		orderBy = "order by a.TaskDate desc"
		Case 56004 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_Wage_JJ b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=56004 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.CountDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 56008 :
		cateCondition = getCondition(m_qxlb,m_listqx,"b.creator")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join M2_Wage_JS b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=56008 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,b.CountDate dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.inDate desc"
		Case 45001:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(b.[status] in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (b.[status] in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join bankin b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=45001 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(10),b.date3 ,120) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.date7 desc"
		Case 45002:
		cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
		cateCondition = cateCondition & "and (" & vbcrlf &_
		"(b.[status] in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
		"or (b.[status] in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
		")"
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join bankout b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"inner join sp_ApprovalInstance c  with(nolock) on c.gate2=45002 and c.PrimaryKeyID = b.id and c.BillPattern in (0,1) " &_
		"where 1=1 " & vbcrlf &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id [id],b.title,convert(varchar(10),b.date3 ,120) dt,"&_
		"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid," &_
		"(case when c.ApprovalFlowStatus in (0,1,2,3) then 1 else 0 end) canCancelAlt,"&_
		" (case c.ApprovalFlowStatus when 3 then 9 when 4 then 10 when 1 then 11 when 5 then 8 when 2 then 12 else 16 end) orderStat"
		orderBy = "order by b.date7 desc"
		Case 47003:
		Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
		tmpCondition = ""
		If qOpen = 3 Then
			cateCondition = ""
		ElseIf qOpen=1 Then
			cateCondition = " and b.id in (select distinct b.id from reminderQueue a  with(nolock) " & vbcrlf &_
			"inner join AcceptanceDraft b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
			"left join gate g1  with(nolock) on g1.ord = b.creator" & vbcrlf &_
			"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" AND plist.sort1 = 1101 AND plist.sort2 = 1" & vbcrlf &_
			"where b.del=1" & vbcrlf &_
			"and (plist.qx_open = 3 OR CHARINDEX(','+CAST(g1.ord AS VARCHAR(20))+',',','+CAST(plist.qx_intro AS VARCHAR(8000))+',') > 0))"
		else
			cateCondition = " and 1=2"
		end if
		If m_fw1&""="1" Then
			tmpCondition = " and "& uid &" = creator"
		end if
		cateCondition =  " " & tmpCondition & " " & cateCondition & " and datediff(d,getdate(),b.LimitEndDate)<=" & m_tq1 & vbcrlf
		sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
		" [CANCELJOINTABLE] " & _
		"inner join AcceptanceDraft b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.id and b.del=1 " & vbcrlf &_
		"where b.del=1" &_
		"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
		fields = "b.id,b.sn title ,b.LimitEndDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
		orderBy = "order by b.LimitEndDate"
		Case Else :
		sql = ""
		fields = ""
		End Select
		If withoutOrderBy Then
			sql = Replace(sql,"[ORDERBY]","")
		end if
		If mode = "cnt" Then
			sql = Replace(sql,"[ORDERBY]","")
		ElseIf mode = "top" Then
			sql = Replace(Replace(sql,"COUNT(*) REMIND_CNT","top " & (m_num1) & " " & fields),"[ORDERBY]", orderBy)
		ElseIf mode = "all" Then
			sql = Replace(Replace(sql,"COUNT(*) REMIND_CNT",fields),"[ORDERBY]", orderBy)
		ElseIf mode = "ids" Then
			fields = Split(fields,"[id],")(0)
			sql = Replace(Replace(sql,"COUNT(*) REMIND_CNT","top 100 percent " & fields & "id"),"[ORDERBY]", orderBy)
		ElseIf mode = "rids" Then
			fields = Split(fields,",")
			Dim findFlag
			findFlag = False
			For i = 0 To ubound(fields)
				If InStr(1,fields(i),"[rid]",1)>0 Then
					sql = Replace(Replace(sql,"COUNT(*) REMIND_CNT","top 100 percent " & fields(i)),"[ORDERBY]", orderBy)
					findFlag = True
					Exit For
				end if
			next
			If findFlag = False Then
				Response.write "sql语句里面缺少rid字段，无法提取该字段的语句"
				Response.end
			end if
		else
			Response.write "不支持的模式参数"
			Response.end
		end if
		If withoutCateCondition Then
			sql = Replace(sql,"[CATECONDITION]","")
		else
			sql = Replace(sql,"[CATECONDITION]",cateCondition)
		end if
		If withoutCancelCondition Then
			sql = Replace(Replace(sql,"[CANCELCONDITION]",""),"[CANCELJOINTABLE]","")
		else
			sql = Replace(Replace(sql,"[CANCELCONDITION]",cancelCondition),"[CANCELJOINTABLE]",cancelJoinTable)
		end if
		listSQL = sql
	end function

			Public Property Get remindCount
			Dim sql,rs
			If isEmpty(m_remindCount) Then
				If m_hasModule = False Then
					m_remindCount = 0
				else
					If isCleanMode Then
						sql = "select count(*) from reminderQueue a  with(nolock) "&_
						"inner join (" & listSQL("all_withoutCateCondition_withoutOrderBy_withoutCancelCondition") & ") b on a.id=b.rid " &_
						"where datediff(s,a.inDate,'"&dateBegin&"')>=0"
					else
						sql = listSQL("cnt")
					end if
					If displaySqlOnCount = true Then
						Response.write "<div style='border:1px solid red'>"&_
						"m_name&""(""&configId&"")---remindCount:<br>""&Replace(server.HTMLEncode(sql),vbcrlf,""<br>"")&""""&_"
						Response.write "<div style='border:1px solid red'>"&_
						"</div>"
					end if
					on error resume next
					Err.clear
					If m_usingLv2Cache And isCleanMode <> True Then
						m_remindCount = CLng(m_cacheHelper.GetCacheRecord(sql,m_cacheExpiredCondition,True,True,uid&"-"&configId&"-"&m_subCfgId&"-count")(0))
'If m_usingLv2Cache And isCleanMode <> True Then
					else
						m_remindCount = CLng(Me.cn.execute(sql)(0))
					end if
					If Err.number <> 0 Then
						Response.Clear()
						Response.write "提醒【"&m_name&"("&configId&")】读取过程中，以下语句执行错误：<br><hr>"
						Response.write Replace(server.HTMLEncode(sql),vbcrlf,"<br>") & "<hr>" & _
						"cacheExpiredCondition:<br>" & Replace(m_cacheExpiredCondition,vbcrlf,"<br>")
						Response.end
					end if
					On Error GoTo 0
				end if
			end if
			remindCount = m_remindCount
			End Property
			Public Sub remindShow
				If m_hasModule = False Then Exit Sub
				on error resume next
				Dim rs,sql,i,j
				Set rs = server.CreateObject("adodb.recordset")
				If isCleanMode Then
					If pageIndex < 1 Then pageIndex = 1
					sql = "select b.*,convert(varchar(19),a.inDate,21) inDate from reminderQueue a  with(nolock) "&_
					"inner join (" & listSQL("all_withoutCateCondition_withoutCancelCondition_withoutOrderBy") & ") b on a.id=b.rid "&_
					"where datediff(s,a.inDate,'"&dateBegin&"')>=0"
					rs.open sql,cn,1,1
					recCount = rs.RecordCount
					rs.PageSize = pageSize
					pageCount = rs.pageCount
					If CLng(pageIndex) > CLng(pageCount) Then pageIndex = pageCount
					If rs.eof = False Then
						rs.AbsolutePage = pageIndex
					end if
					If Err.number <> 0 Then
						Response.Clear()
						Response.write "提醒【"&m_name&"("&configId&")】读取过程中，以下语句执行错误：<br><hr>"
						Response.write Replace(server.HTMLEncode(sql),vbcrlf,"<br>") & "<hr>" & _
						"cacheExpiredCondition:<br>" & Replace(m_cacheExpiredCondition,vbcrlf,"<br>")
						Response.end
					end if
				else
					sql = listSQL("top")
					If m_usingLv2Cache Then
						Set rs = m_cacheHelper.GetCacheRecord(sql,m_cacheExpiredCondition,True,True,uid&"-"&configId&"-"&m_subCfgId&"list")
'If m_usingLv2Cache Then
					else
						rs.open sql,cn,1,1
					end if
					If Err.number <> 0 Then
						Response.Clear()
						Response.write "提醒【"&m_name&"("&configId&")】读取过程中，以下语句执行错误：<br><hr>"
						Response.write Replace(server.HTMLEncode(sql),vbcrlf,"<br>") & "<hr>" & _
						"cacheExpiredCondition:<br>" & Replace(m_cacheExpiredCondition,vbcrlf,"<br>")
						Response.end
					end if
				end if
				If displaySqlOnShow = true Then
					Response.write "<div style='border:1px solid red'>"&_
					"m_name&""(""&configId&"")---remindShow:<br>""&Replace(server.HTMLEncode(sql),vbcrlf,""<br>"")&""""&_"
					Response.write "<div style='border:1px solid red'>"&_
					"</div>"
				end if
				Response.write "" & vbcrlf & "             <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" " & vbcrlf & "                 "
				Response.write IIf(isCleanMode,"style='table-layout:fixed;'","")
				Response.write " bgcolor=""#C0CCDD"" class=""reminder home detailTable"" " & vbcrlf & "                    cfgId="""
				Response.write configId
				Response.write """ subId="""
				Response.write m_subCfgId
				Response.write """>" & vbcrlf & "                "
				If isCleanMode <> True Then
					Response.write "" & vbcrlf & "                     <tr class=""top tbheader OnlyHeader"">" & vbcrlf & "                              <td colspan=""2"" valign=""center"" height=""30"" onMouseOut=""RemObj.toggleBar(this,false);"" onmouseover=""RemObj.toggleBar(this,true);"">" & vbcrlf & "                                        <span style=""float:left"">"
					Response.write m_name
					Response.write "(<a href="""
					Response.write moreLinkURL()
					Response.write """ style='color:red'>"
					Response.write remindCount
					Response.write "</a>)</span>" & vbcrlf & "                                 <span class=""alt_title"" style=""float:left;display:none;"">" & vbcrlf & "                                           <a href=""javascript:void(0)"" onclick=""altChgOrder("
					Response.write m_setjmId
					Response.write ","
					Response.write m_subCfgId
					Response.write ",1,this)"" title=""左移"">←</a>" & vbcrlf & "                                               <a href=""javascript:void(0)"" onclick=""altChgOrder("
					Response.write m_setjmId
					Response.write ","
					Response.write m_subCfgId
					Response.write ",2,this)"" title=""上移"">↑</a>" & vbcrlf & "                                               <a href=""javascript:void(0)"" onclick=""altChgOrder("
					Response.write m_setjmId
					Response.write ","
					Response.write m_subCfgId
					Response.write ",3,this)"" title=""下移"">↓</a>" & vbcrlf & "                                               <a href=""javascript:void(0)"" onclick=""altChgOrder("
					Response.write m_setjmId
					Response.write ","
					Response.write m_subCfgId
					Response.write ",4,this)"" title=""右移"">→</a>" & vbcrlf & "                                               <a href=""javascript:void(0)"" onclick=""altChgOrder("
					Response.write m_setjmId
					Response.write ","
					Response.write m_subCfgId
					Response.write ",5,this)"" title=""关闭"">×</a>" & vbcrlf & "                                       </span>" & vbcrlf & "                                 <span style=""float:right;"">"
					Response.write getMoreLink()
					Response.write "</span>" & vbcrlf & "                      "
					If m_remindMode = "CYCLE" Then
						Response.write "" & vbcrlf & "                                     <span class=""alt_refreshBtn"" style=""float:right;padding-right:10px;"">" & vbcrlf & "                                               <img src=""../images/refresh.png"" class=""alt_refreshImg"" border=""0"" width=""12px"" alt=""手动更新""" & vbcrlf & "                                                    style=""cursor:pointer;"" onclick=""RemObj.refresh("
'If m_remindMode = "CYCLE" Then
						Response.write m_setjmId
						Response.write ","
						Response.write m_subCfgId
						Response.write ",this);""/>" & vbcrlf & "                                        </span>" & vbcrlf & "                                 <span class=""alt_refreshTime"" style=""float:right;font-weight:normal;padding-right:10px;"">上次更新："
						Response.write m_subCfgId
						Response.write m_lastReloadDate
						Response.write "</span>" & vbcrlf & "                                      "
					end if
					Response.write "" & vbcrlf & "                             </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
				Else
					Response.write "" & vbcrlf & "                     <tr class=""top"">" & vbcrlf & "                          <td width=""36"">&nbsp;</td>" & vbcrlf & "                                <td>主题</td>" & vbcrlf & "                           <td width=""150"">添加时间</td>" & vbcrlf & "                             <td width=""150"" style=""text-align:center"">" & vbcrlf & "                                  <select onchange=""loadList("
'Else
					Response.write pageIndex
					Response.write ",this.value);"">" & vbcrlf & "                                           <option value=""10"" "
					Response.write IIf(pageSize=10," selected","")
					Response.write ">每页显示10条</option>" & vbcrlf & "                                               <option value=""20"" "
					Response.write IIf(pageSize=20," selected","")
					Response.write ">每页显示20条</option>" & vbcrlf & "                                               <option value=""30"" "
					Response.write IIf(pageSize=30," selected","")
					Response.write ">每页显示30条</option>" & vbcrlf & "                                               <option value=""50"" "
					Response.write IIf(pageSize=50," selected","")
					Response.write ">每页显示50条</option>" & vbcrlf & "                                               <option value=""100"" "
					Response.write IIf(pageSize=100," selected","")
					Response.write ">每页显示100条</option>" & vbcrlf & "                                              <option value=""200"" "
					Response.write IIf(pageSize=200," selected","")
					Response.write ">每页显示200条</option>" & vbcrlf & "                                      </select>" & vbcrlf & "                               </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
				end if
				i = 0
				If rs.eof Then
					If remindCount > 0 Then
						Response.write "" & vbcrlf & "                     <tr><td colspan=""4"" align=""center"">您设置的显示行数为0，无信息可显示</td></tr>" & vbcrlf & "                      "
					else
						Response.write "" & vbcrlf & "                     <tr><td colspan=""4"" style=""height:107px"" align=""center"">没有信息！</td></tr>" & vbcrlf & "                  "
					end if
				else
					While rs.eof = False And ((isCleanMode = True And i < pageSize) Or isCleanMode = False)
						Response.write "" & vbcrlf & "                     <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "                           "
						If isCleanMode = True Then
							Response.write "<td><input type='checkbox' class='delRids' value='" & rs("rid") & "'/></td>" & vbcrlf
						end if
						Response.write "" & vbcrlf & "                             <td class=""name"" width=""57%"">"
						Response.write getTitleHTML(rs)
						Response.write "</td>" & vbcrlf & "                                <td align=""center"">"
						Response.write getDtHTML(rs)
						Response.write "</td>" & vbcrlf & "                                "
						If isCleanMode = True Then
							Response.write "" & vbcrlf & "                             <td align=""center""><input type=""button"" onclick=""dropRemind("
							Response.write rs("rid")
							Response.write ");"" value=""清理此提醒"" class=""anybutton2""/></td>" & vbcrlf & "                              "
						end if
						Response.write "" & vbcrlf & "                     </tr>" & vbcrlf & "                           "
						i=i+1
						Response.write "" & vbcrlf & "                     </tr>" & vbcrlf & "                           "
						rs.movenext
					wend
				end if
				If  isCleanMode <> True Then
					If remindCount > 0 Then
						For j=i To m_num1 - 1
'If remindCount > 0 Then
							Response.write "<tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">"&_
							"<td class=""name"" colspan=""4"">&nbsp;</td>"&_
							"</tr>"
						next
					end if
				else
					Response.write "" & vbcrlf & "                     <tr>" & vbcrlf & "                            <td><input type='checkbox' onclick=""checkAll(this);""/></td>" & vbcrlf & "                               <td colspan=""3"" align=""right"">" & vbcrlf & "                                      <table style=""width:100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "                                           <tr>" & vbcrlf & "                                                    <td width=""100px"">" & vbcrlf & "                                                             <input type=""button"" value=""批量清理"" class=""anybutton2"" onclick=""dropRemind();""/>" & vbcrlf & "                                                      </td>" & vbcrlf & "                                                   <td align=""right"">" & vbcrlf & "                                                                共"
					Response.write recCount
					Response.write "条&nbsp;"
					Response.write pageSize
					Response.write "/页&nbsp;"
					Response.write pageIndex
					Response.write "/"
					Response.write pageCount
					Response.write "页" & vbcrlf & "                                                             <input type=""text"" id=""jppgidx"" style=""width:40px"" maxlength=""8"" value="""
					Response.write pageIndex
					Response.write """ " & vbcrlf & "                                                                  onfocus=""this.select();""" & vbcrlf & "                                                                  onkeydown=""pageKeyup(this);""" & vbcrlf & "                                                                      title=""按回车可翻页""" & vbcrlf & "                                                              />" & vbcrlf & "                                                              <input type=""button"" value=""跳转"" class=""page"" onclick=""if(!isNaN($('#jppgidx').val())) loadList($('#jppgidx').val(),"
					Response.write pageSize
					Response.write ")""/>" & vbcrlf & "                                                               <input type=""button"" value=""首页"" class=""page"" onclick=""loadList("
					Response.write 1&","&pageSize
					Response.write ");""/>" & vbcrlf & "                                                              <input type=""button"" value=""上页"" class=""page"" onclick=""loadList("
					Response.write (pageIndex-1)&","&pageSize
					Response.write ");""/>" & vbcrlf & "                                                              <input type=""button"" value=""下页"" class=""page"" onclick=""loadList("
					Response.write (pageIndex+1)&","&pageSize
					Response.write ");""/>" & vbcrlf & "                                                              <input type=""button"" value=""尾页"" class=""page"" onclick=""loadList("
					Response.write pageCount&","&pageSize
					Response.write ");""/>" & vbcrlf & "                                                      </td>" & vbcrlf & "                                           </tr>" & vbcrlf & "                                   </table>" & vbcrlf & "                                </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
				end if
				Response.write "" & vbcrlf & "              </table>" & vbcrlf & "                "
				If Err.number<>0 Then
					dim errtxt
					errtxt = err.Description
					if instr(errtxt,"未找到项目")>0 then
						errtxt = errtxt & " <br>sql查询需要提供【rid】,【cateid】,【title】,【newTag】列，请检查SQL是否正确支持。"
					end if
					Response.write Replace("以下语句执行错误：<br>" & server.HTMLEncode(sql) & "<div style='padding:10px;background-color:#ffff00'>错误提示语：" & errtxt & "</div>", vbcrlf , "<br>")
					errtxt = errtxt & " <br>sql查询需要提供【rid】,【cateid】,【title】,【newTag】列，请检查SQL是否正确支持。"
					cn.close
					Response.end
				end if
			end sub
			Public Function getTitleHTML(ByRef rs)
				Dim ttArr,ttStr
				Select Case m_setjmId
				Case 7:
				ttArr = Split(rs("title"),Chr(11)&Chr(12))
				If m_isMobileMode Then
					getTitleHTML = getTitleHTML & ttArr(0)'rs("title")
				else
					getTitleHTML = getTitleHTML & "<span style='float:left;color:#5b7cae'>"&getTitleLink(ttArr(0),rs("id"),rs("cateid")) & "</span>"
					getTitleHTML = getTitleHTML & "<span style='float:right;'>("&ttArr(1)&")</span>"
				end if
				Case 225:
				Dim showTitle2
				showTitle2 = rs("title")
				If InStr(rs("title"),"@code:") > 0 Then
					showTitle2 = eval(REPLACE(rs("title"),"@code:",""))
				end if
				If m_isMobileMode Then
					getTitleHTML = getTitleHTML & showTitle2
				else
					getTitleHTML = getTitleHTML & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
					getTitleHTML = getTitleHTML & "     <tr>"&_
					"<td style=""background-Color:transparent;"">" &_
					"getTitleLink(showTitle2,rs(""id""),rs(""cateid""))" &_
					"<span style='float:right;'>"&rs("WorkLong")&"小时</span>" &_
					"IIf(rs(""newTag"")>=0,""<span class='alt_tx'></span>"","""")" &_
					"</td>" &_
					"</table>"
				end if
				Case Else:
				Dim showTitle
				showTitle = rs("title")
				If InStr(rs("title"),"@code:") > 0 Then
					showTitle = eval(REPLACE(rs("title"),"@code:",""))
				end if
				If m_isMobileMode Then
					getTitleHTML = getTitleHTML & showTitle
				else
					getTitleHTML = getTitleHTML & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
					getTitleHTML = getTitleHTML & "     <tr>"&_
					"<td style=""background-Color:transparent;color:#5b7cae"">" &_
					"getTitleLink(showTitle,rs(""id""),rs(""cateid""))" &_
					"IIf(rs(""newTag"")>=0,""<span class='alt_tx'></span>"","""")" &_
					"</td>"
				end if
				If hasStatField(rs) And showStatusField Then
					If rs("orderStat")>0 Then
						If m_isMobileMode Then
							getTitleHTML = getTitleHTML & Chr(11) & Chr(12) & "(" & getOrderStat(rs("orderStat")) & ")"
						else
							getTitleHTML = getTitleHTML & "<td width='80px' style=""background-Color:transparent;"">("&getOrderStat(rs("orderStat"))&")</td>"
'getTitleHTML = getTitleHTML & Chr(11) & Chr(12) & "(" & getOrderStat(rs("orderStat")) & ")"
						end if
					end if
				end if
				If Not m_isMobileMode Then
					getTitleHTML = getTitleHTML & "     </tr>" &_
					"</table>"
				end if
				End Select
			end function
			Public Function getDtHTML(ByRef rs)
				Dim dtArr,dtStr,dtType
				If isCleanMode Then
					getDtHTML = getDtHTML & rs("inDate")
				else
					If configId = 7 Then
						If m_isMobileMode Then
							dtArr = Split(rs("dt"),"@")
							dtStr = dtArr(0)
							dtType = dtArr(1)
							getDtHTML = getDtHTML & dtStr
						else
							Dim nlObj
							Set nlObj = New hlxNongLiGongLi
							dtArr = Split(rs("dt"),"@")
							dtStr = dtArr(0)
							dtType = dtArr(1)
							If dtType="2" Then
								getDtHTML = getDtHTML & "农历"&nlObj.getYearStr(dtStr)&"年"&_
								"nlObj.NongliMonth(nlObj.getMonthStr(dtStr))&""月""&_"
								nlObj.NongliDay(nlObj.getDayStr(dtStr))
							ElseIf dtType="3" Then
								getDtHTML = getDtHTML & "农历"&nlObj.getYearStr(dtStr)&"年闰"&_
								"nlObj.NongliMonth(nlObj.getMonthStr(dtStr))&""月""&_"
								nlObj.NongliDay(nlObj.getDayStr(dtStr))
							else
								getDtHTML = getDtHTML & "公历"&nlObj.getYearStr(dtStr)&"年"&_
								"nlObj.getMonthStr(dtStr)&""月""&_"
								nlObj.getDayStr(dtStr)&"日"
							end if
						end if
					else
						getDtHTML = getDtHTML & rs("dt")
					end if
				end if
				Dim canCancelAlt : canCancelAlt = False
				If m_canCancel = True And isCleanMode <> True And Not m_isMobileMode Then
					If hasAltField(rs) Then
						If CLng(rs("canCancelAlt")) = 1 Then
							canCancelAlt = True
						else
							canCancelAlt = False
						end if
					else
						canCancelAlt = True
					end if
					If canCancelAlt = True Then
						getDtHTML = getDtHTML & _
						"<img src='../images/alt3.gif' " &_
						"style='cursor:pointer;' " &_
						"onClick=""RemObj.cancel('" & rs("id") & "','" & rs("rid") & "'," & m_setjmId & "," & m_subCfgId & ")"" " &_
						"alt='取消提醒'"  &_
						"border='0'" &_
						"/>"
					end if
				end if
			end function
			Public Sub appendRemind(oid)
				Call appendRemindWithStat(oid,0)
			end sub
			Public Sub appendRemindWithStat(oid,stat)
				Call appendRemindWithInfo(oid,stat,"")
			end sub
			Public Sub appendRemindWithInfo(oid,stat,inf)
				Dim sql
				oid = Replace(oid," ","")
				If oid = "" Then
					Response.write "方法调用缺少必要的参数"
					Response.end
				end if
				sql = "select [id] from reminderQueue a  with(nolock) where reminderConfig=" & configId & " and subCfgId=" & m_subCfgId &_
				" And orderId in (" & oid & ") and orderStat=" & stat
				Me.cn.execute "delete reminderPersons where reminderId in ("&sql&")"
				Me.cn.execute "update reminderQueue set inDate =getdate() where id in ("&oid&")"
				Me.cn.execute "insert into reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,orderStat,otherInfo,inDate) " & _
				"select "&configId&","&m_subCfgId&_
				",cast(short_str as int),0,"&stat&",'"&inf&"',getdate() from dbo.split('"&oid&"',',') where cast(short_str as int) not in ("&Replace(sql,"[id]","[orderID]")&")"
			end sub
			Public Sub dropRemindByOID(oid)
				Call dropRemindByOidAndStat(oid,0)
			end sub
			Public Sub dropRemindByOidAndStat(oid,stat)
				If m_remindMode <> "PASSIVE" And m_remindMode <> "CYCLE" Then
					Response.write m_remindMode & "模式下不支持此过程调用！"
					Response.end
				end if
				oid = Replace(oid," ","")
				If oid = "" Then
					Response.write "方法调用缺少必要的参数"
					Response.end
				end if
				Me.cn.execute "delete reminderPersons where reminderId in " & _
				"(select id from reminderQueue  with(nolock) where orderId in (" & oid & ") and subCfgId="&m_subCfgId&_
				" and orderStat="&stat&" and reminderConfig=" & configId &")"
				Me.cn.execute "delete reminderQueue where orderId in (" & oid & ") and subCfgId="&m_subCfgId&_
				" and orderStat="&stat&" and reminderConfig=" & configId
			end sub
			Public Sub dropRemindByRID(rid)
				If m_remindMode <> "PASSIVE" And m_remindMode <> "CYCLE" Then
					Response.write m_remindMode & "模式下不支持此过程调用！"
					Response.end
				end if
				If rid = "" Then
					Response.write "方法调用缺少必要的参数"
					Response.end
				end if
				Me.cn.execute "delete reminderPersons where reminderId in (" & rid & ")"
				Me.cn.execute "delete reminderQueue where id in (" & rid & ")"
			end sub
			Public Sub cancelRemind(rid)
				Dim sql,rs,id
				If rid&""<>"0" And rid&""<>"" Then
					sql = iif(instr(rid,",")>0 , " id in (" & rid & ")", "id=" & rid)
					sql = "select id from reminderQueue  with(nolock) where " & sql
					Set rs=Me.cn.execute(sql)
					If rs.eof=True Then rs.close : Exit Sub
					While rs.eof = False
						id = CLng(rs(0))
						If canCancelOrder(id) Then
							If m_remindMode = "PASSIVE" Or m_remindMode = "CYCLE" Then
								If m_jointly = True Then
									If m_remindMode = "CYCLE" Then
										Me.cn.execute "insert into reminderPersons(reminderId,cateid) " & vbcrlf &_
										"select distinct "&id&",isnull(cateid," & uid & ") from setjm a  with(nolock) where ord="&m_setjmId&" " & vbcrlf &_
										"and not exists (select top 1 1 from reminderPersons  with(nolock) where reminderId="&id&" and cateid=isnull(a.cateid," & uid & "))"
									Else
										Call Me.dropRemindByRID(rid)
									end if
								else
									Me.cn.execute "if not exists (select 1 from reminderPersons  with(nolock) where reminderId=" & id & " and cateid=" & uid & ") " & vbcrlf &_
									"insert into reminderPersons(reminderId,cateid) values("&id&","&uid&")"
								end if
							end if
						end if
						rs.movenext
					wend
					rs.close
					set rs = nothing
				end if
			end sub
			Public Sub cancelRemindByOid(oid)
				Dim sql,rs,id,result,success
				If oid&""<>"0" And oid&""<>"" Then
					sql = "select distinct rid,cast(title as nvarchar(200)) as title from (" & listSql("all_withoutOrderBy") & ") a where [id] in (" & oid & ")"
					Set rs=Me.cn.execute(sql)
					If rs.eof=True Then Exit Sub
					result = ""
					While rs.eof = False
						id = CLng(rs("rid"))
						If canCancelOrder(id) Then
							If m_remindMode = "PASSIVE" Or m_remindMode = "CYCLE" Then
								If m_jointly = True Then
									If m_remindMode = "CYCLE" Then
										Me.cn.execute "insert into reminderPersons(reminderId,cateid) " & vbcrlf &_
										"select distinct "&id&",isnull(cateid," & uid & ") from setjm a  with(nolock) where ord="&m_setjmId&" " & vbcrlf &_
										"and not exists (select top 1 1 from reminderPersons  with(nolock) where reminderId="&id&" and cateid=isnull(a.cateid," & uid & ") )"
									Else
										Call Me.dropRemindByRID(rid)
									end if
								else
									Me.cn.execute "if not exists (select 1 from reminderPersons  with(nolock) where reminderId=" & id & " and cateid=" & uid & ") " & vbcrlf &_
									"insert into reminderPersons(reminderId,cateid) values("&id&","&uid&")"
								end if
							end if
							success = "true"
						else
							success = "false"
						end if
						result = result & "{""id"":"&id&",""name"":"""&IIF(Len(rs("title"))>0,rs("title"),"无标题")&""",""success"":"&success&"}"
						rs.movenext
						If rs.eof=False Then result = result & ","
					wend
					If Len(result)>0 Then
						Response.write "[" & result & "]"
					end if
				end if
			end sub
			Public Sub reloadRemind(withoutLimit)
				Dim sql,condition,qOpen,qIntro,fields,orderBy,rs,cfgId,cateid,rType,rAdvance,topNum,tmpCondition,lastReloadDate
				Me.cn.cursorLocation = 3
				If withoutLimit <> True Then
					sql = "select lastReloadDate from reminderConfigs  with(nolock) where setjmId=" & m_setjmId
					Set rs=Me.cn.execute(sql)
					If rs.eof Then
						Response.write "读取配置失败，请联系管理员"
						Response.end
					else
						lastReloadDate = now
						If datediff("s",rs(0),lastReloadDate) < RELOAD_INTERVAL_LIMIT And datediff("s",rs(0),lastReloadDate) > 0 Then
							Response.write "请不要频繁进行更新操作"
							Response.end
						end if
					end if
				else
					lastReloadDate = now
				end if
				sql = "select top 0 id,reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate into #reminderQueue from reminderQueue"
				Me.cn.execute sql
				Set rs = Me.cn.execute("select isnull(max(tq1),0) tq1 from setjm  with(nolock) where intro='1' and ord=" & m_setjmId)
				If rs.eof Then
					rAdvance = 0
				else
					rAdvance = rs(0)
				end if
				Select Case m_setjmId
				Case 7:
				Dim nowDays : nowDays = datediff("d",CDate(year(date)&"-01-01"),date)
'Case 7:
				sql = "exec erp_PersonBirthdayUpdate "&year(date)&",0"
				Me.cn.execute sql
				sql = "" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"select "&m_setjmId&",0,a.ord,year(getdate())+(case when isnull(a.bDays - "&nowDays&",0)=0 then 0 else 1 end)*100000,"&_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"a.bDays - "&nowDays&",getdate() " & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"From person a  with(nolock) " & vbcrlf &_
				"where bDays - "&nowDays&" >=0 and bDays - "&nowDays&" <= " & rAdvance & " " & vbcrlf &_
				"From person a  with(nolock) " & vbcrlf &_
				"and a.ord not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
				"order by a.bDays,a.ord"
				Me.cn.execute sql
				Case 9:
				sql = "" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"select " & m_setjmId & ",0,id,datediff(d,'2000-01-01',date2),datediff(d,getdate(),date2),getdate() from caigoulist a with(nolock)  " & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"where del=1 and alt=1 " & vbcrlf & _
				"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
				"and datediff(d,getdate(),date2)<=" & rAdvance & " and datediff(m,getdate(),date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
				"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
				"order by date2 desc,date7 desc"
				Me.cn.execute sql
				Case 11:
				sql = "" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"select "&m_setjmId&",0,ord,datediff(d,'2000-01-01',date1),datediff(d,getdate(),date1),getdate() from payback a with(nolock)  " & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"where del=1 and complete='1' " & vbcrlf &_
				"and datediff(d,getdate(),date1)<=" & rAdvance & " " & vbcrlf &_
				"and a.ord not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
				"order by date1 desc,date7 desc"
				Me.cn.execute sql
				Case 209:
				sql = "" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"select "&m_setjmId&",0,id,datediff(d,'2000-01-01',applydate),datediff(d,getdate(),applydate),getdate() from payoutsure a  with(nolock) " & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"where del=1 and (complete='0' and status in (-1,1) or complete='3')" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"and datediff(d,getdate(),applydate)<=" & rAdvance & " " & vbcrlf &_
				"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
				"order by applydate desc,InDate desc"
				Me.cn.execute sql
				Case 12:
				sql = "" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"select "&m_setjmId&",0,ord,datediff(d,'2000-01-01',date1),datediff(d,getdate(),date1),getdate() from payout a  with(nolock) " & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"where del=1 and complete='1' " & vbcrlf &_
				"and datediff(d,getdate(),date1)<=" & rAdvance & " " & vbcrlf &_
				"and a.ord not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
				"order by date1 desc,date7 desc"
				Me.cn.execute sql
				Case 21:
				sql = "" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"select " & m_setjmId & ",0,ord,datediff(d,'2000-01-01',date2),datediff(d,getdate(),date2),getdate() from contract a with(nolock)  " & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"where del=1 " & vbcrlf & _
				"and a.ord not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
				"and datediff(d,getdate(),date2)<=" & rAdvance & " and datediff(m,getdate(),date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
				"and a.ord not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
				"order by date2 desc,date7 desc"
				Me.cn.execute sql
				Case 23:
				sql = "" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"select " & m_setjmId & ",0,id,datediff(d,'2000-01-01',date2),datediff(d,getdate(),date2),getdate() from contractlist a with(nolock)  " & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"where a.del=1 and a.num2<a.num1 " & vbcrlf & _
				"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
				"and datediff(d,getdate(),date2)<=" & rAdvance & " and datediff(m,getdate(),date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
				"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
				"order by date2 desc,date7 desc"
				Me.cn.execute sql
				Case 68:
				sql = "" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"select " & m_setjmId & ",0,ku.id," & vbcrlf &_
				"MaintainUnit*10000 + MaintainNum * 10 + cast(ISNULL(m.date1,ISNULL(ku.datesc,'1970-1-1')) as int)," & vbcrlf &_
				"select " & m_setjmId & ",0,ku.id," & vbcrlf &_
				"datediff(hh,'"&date&"',ISNULL(m.date1,ISNULL(ku.datesc,'1970-1-1'))) + " & vbcrlf &_
				"select " & m_setjmId & ",0,ku.id," & vbcrlf &_
				"case " & vbcrlf &_
				"when MaintainUnit = 1 then MaintainNum " & vbcrlf &_
				"when MaintainUnit = 2 then MaintainNum * 24 " & vbcrlf &_
				"when MaintainUnit = 3 then MaintainNum * 24 * 7 " & vbcrlf &_
				"when MaintainUnit = 4 then MaintainNum * 24 * 30 " & vbcrlf &_
				"when MaintainUnit = 5 then MaintainNum * 24 * 365 " & vbcrlf &_
				"end " & vbcrlf &_
				",getdate() " & vbcrlf &_
				"from product p  with(nolock) " & vbcrlf &_
				"inner join ku  with(nolock) on p.ord=ku.ord and ku.num2<>0 and LEN(ku.datesc)>0 and p.del=1 " & vbcrlf &_
				"and ISNULL(p.MaintainNum,0)>0 and datalength(p.RemindPerson)>0 " & vbcrlf &_
				"left join ( " & vbcrlf &_
				"select m1.ord yhord,m2.ord,m2.ku,m3.date1 from maintain m1  with(nolock) " & vbcrlf &_
				"inner join ( " & vbcrlf &_
				"select maintain,ord,ku from maintainlist  with(nolock) " & vbcrlf &_
				"where del=1 " & vbcrlf &_
				"group by maintain,ord,ku " & vbcrlf &_
				") m2 on m2.maintain=m1.ord " & vbcrlf &_
				"inner join ( " & vbcrlf &_
				"select m2.ord, m2.ku, max(m1.date1) date1 " & vbcrlf &_
				"from maintain m1  with(nolock) " & vbcrlf &_
				"inner join maintainlist m2  with(nolock) on m2.maintain=m1.ord and m2.del=1 " & vbcrlf &_
				"inner join product p  with(nolock) on p.ord=m2.ord and p.del=1 " & vbcrlf &_
				"and ISNULL(p.MaintainNum,0)>0 and datalength(p.RemindPerson)>0 " & vbcrlf &_
				"where m1.del=1 and isnull(m1.status,0)=0 " & vbcrlf &_
				"group by m2.ord,m2.ku " & vbcrlf &_
				")m3 on m2.ord=m3.ord and m2.ku=m3.ku " & vbcrlf &_
				"where m1.del=1 and isnull(m1.status,0)=0 and m1.date1=m3.date1 " & vbcrlf &_
				") m on m.ku=ku.id and p.ord=m.ord " & vbcrlf &_
				"where isnull(ku.locked,0)=0 and len(ISNULL(m.date1,ku.datesc))>0 " & vbcrlf &_
				"and datediff(hh,'"&date&"',ISNULL(m.date1,ISNULL(ku.datesc,'1970-1-1'))) + " & vbcrlf &_
				"where isnull(ku.locked,0)=0 and len(ISNULL(m.date1,ku.datesc))>0 " & vbcrlf &_
				"case " & vbcrlf &_
				"when MaintainUnit = 1 then MaintainNum " & vbcrlf &_
				"when MaintainUnit = 2 then MaintainNum * 24 " & vbcrlf &_
				"when MaintainUnit = 3 then MaintainNum * 24 * 7 " & vbcrlf &_
				"when MaintainUnit = 4 then MaintainNum * 24 * 30 " & vbcrlf &_
				"when MaintainUnit = 5 then MaintainNum * 24 * 365 " & vbcrlf &_
				"end <= " & (rAdvance * 24)
				Me.cn.execute sql
				Case 105:
				sql = "" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"select "&m_setjmId&",0,ProductID,datediff(mi,'2014-01-01',getdate()),b.UnitId,getdate() " & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"from o_product a  with(nolock) " & vbcrlf &_
				"inner join ( " & vbcrlf &_
				"select replace(prod_id,' ','') as ProductID,replace(prod_unit,' ','') as UnitId,sum(prod_num) as ku_num " & vbcrlf &_
				"from o_kuinlist a  with(nolock) " & vbcrlf &_
				"inner join o_kuin b  with(nolock) on a.reg_fid=b.id " & vbcrlf &_
				"group by prod_id,prod_unit " & vbcrlf &_
				") b on a.id=b.ProductID " & vbcrlf &_
				"where " & vbcrlf &_
				"(case when Ku_num>prod_more and prod_more<>0 then "&_
				"(convert(decimal,(Ku_num-prod_more))/convert(decimal,prod_more))*100 else 0 end) > 0 " & vbcrlf &_
				"(case when Ku_num>prod_more and prod_more<>0 then "&_
				" or " & vbcrlf &_
				"(case when Ku_num<prod_less and prod_less<>0 then "&_
				"(convert(decimal,(prod_less-Ku_num))/convert(decimal,prod_less))*100 else 0 end) > 0 "
'(case when Ku_num<prod_less and prod_less<>0 then &_
				Me.cn.execute sql
				Case 106:
				sql = "" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"select distinct "&m_setjmId&",0,ord,isnull(min(type1),0) * 100000 + min(backdays),min(backdays),getdate() " & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"from dbo.erp_sale_getBackList('"&date&"',0) where canremind=1 and backdays<=reminddays " & vbcrlf &_
				"group by ord"
				Me.cn.execute sql
				Case 120:
				sql = "" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"select distinct "&m_setjmId&",0,a.ord,datediff(d,'2014-01-01',getdate()),datediff(d,'" & date & "',datepro+isnull(b.num2,0)),getdate() "&_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"from tel as a WITH(NOLOCK) "& vbcrlf &_
				"inner join num_bh b on a.sort1=b.kh and a.cateid=b.cateid "& vbcrlf &_
				"where a.profect1=1 "& vbcrlf &_
				"and datediff(d,'" & date & "',datepro+isnull(b.num2,0)) <= isnull(b.num3,0) "& vbcrlf &_
				"where a.profect1=1 "& vbcrlf &_
				"and a.del=1 and isnull(a.sp,0)=0 and a.sort3=1"
				Me.cn.execute sql
				Case 121:
				sql = "" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"select distinct "&m_setjmId&",0,ord,datediff(d,'2014-01-01',getdate()),datediff(d,'2014-01-01',isnull(nextReply,EndReplyDate)),getdate() "&_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"from dbo.erp_sale_getWillReplyList('"&date&"',0) "
				Me.cn.execute sql
				Case 10:
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT " & m_setjmId & ",0,a.id,DATEDIFF(d,'2000-01-01',a.date2),DATEDIFF(d,GETDATE(),a.date2),GETDATE() FROM kujhlist a  with(nolock) " & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"WHERE a.del = 1 AND a.num1 > a.num2 " & vbcrlf & _
				"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"AND DATEDIFF(d,GETDATE(),a.date2)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
				"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"ORDER BY a.date2 DESC,a.date7 DESC"
				Me.cn.execute sql
				Case 20:
				storelist_sort5 = "0"
				Set rsUsConfig= conn.execute("select isnull(tvalue,'0') tvalue from home_usConfig where name='storelist_sort5' and isnull(uid, 0) =" &  session("personzbintel2007") )
				If rsUsConfig.eof= False Then
					storelist_sort5=rsUsConfig("tvalue")
				end if
				rsUsConfig.close
				showKuLimitZeroSQL = ""
				if storelist_sort5 = "0" then
					showKuLimitZeroSQL = " and (isnull(a.alert1,0)>0 or isnull(a.alert2,0)>0)"
				end if
				showzore =0
				Set rsUsConfig= conn.execute("select (case cast(tvalue as varchar(10)) when '1' then 1 else 0 end) v from home_usConfig  with(nolock) where uid="& session("personzbintel2007") &" and name='storelist_sort1' ")
				if rsUsConfig.eof=false  then
					showzore = rsUsConfig("v").value
				end if
				rsUsConfig.close
				unkuinwarning = 0
				if showzore="1" then
					Set rsUsConfig= conn.execute("select (case cast(tvalue as varchar(10)) when '1' then 1 else 0 end) v from home_usConfig  with(nolock) where uid="& session("personzbintel2007") &" and name='storelist_warning' ")
					if rsUsConfig.eof=false  then
						unkuinwarning = rsUsConfig("v").value
					end if
					rsUsConfig.close
				end if
				showZeroSQL = ""
				if showzore = "0" then
					showZeroSQL = " and isnull(b.ku_num,0)>0 "
				else
					if unkuinwarning="0" then
						showZeroSQL = " and exists(select 1 from ku where ord =a.ord) "
					end if
				end if
				sql = "" & vbcrlf &_
				"select cateid from setjm a " & vbcrlf &_
				"inner join (" & vbcrlf &_
				"select ord from (" & vbcrlf &_
				"select ord from power  with(nolock) where (sort1=31 and sort2=13 and qx_open>0) " & vbcrlf &_
				"union all " & vbcrlf &_
				"select ord from power  with(nolock) where (sort1=31 and sort2=16 and qx_open>0) " & vbcrlf &_
				") a group by ord having count(*)=2 " & vbcrlf &_
				"union " & vbcrlf &_
				"select ord from (" & vbcrlf &_
				"select ord from power  with(nolock) where (sort1=32 and sort2=13 and qx_open>0) " & vbcrlf &_
				"union all " & vbcrlf &_
				"select ord from power  with(nolock) where (sort1=32 and sort2=16 and qx_open>0) " & vbcrlf &_
				") a group by ord having count(*)=2" & vbcrlf &_
				") b on a.cateid=b.ord " & vbcrlf &_
				"where a.intro=1 and a.ord=" & m_setjmId
				Set rs = Me.cn.execute(sql)
				While rs.eof = False
					sql = "" & vbcrlf &_
					"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
					"SELECT " & m_setjmId & ",0,a.ord,DATEDIFF(mi,'2000-01-01',a.date7),DATEDIFF(d,GETDATE(),a.date7),GETDATE() " & vbcrlf &_
					"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
					"FROM (" & vbcrlf &_
					"SELECT a.ord,addcate,title," & vbcrlf & _
					"(CASE WHEN Isnull(aleat1, 0) = 0 THEN 0 ELSE Isnull(aleat1, 0) END )  AS alert1, " & vbcrlf & _
					"(CASE WHEN Isnull(aleat2, 0) = 0 THEN 0 ELSE Isnull(aleat2, 0) END )  AS alert2, " & vbcrlf & _
					"date7,Isnull(ku_num, 0) ku_num " & vbcrlf & _
					"FROM product a  with(nolock) " & vbcrlf & _
					"LEFT JOIN (" & vbcrlf &_
					"SELECT ord,Sum(numjb) AS ku_num FROM ("&vbcrlf &_
					"SELECT suba.ord," & vbcrlf & _
					"(CASE " & vbcrlf & _
					"WHEN suba.unit = subb.unitjb THEN num2 " & vbcrlf & _
					"ELSE num2 * Isnull((SELECT TOP 1 bl FROM jiage WHERE  product = suba.ord AND unit = suba.unit), 0) " & vbcrlf & _
					"END) numjb " & vbcrlf & _
					"FROM ku suba  with(nolock) " & vbcrlf & _
					"INNER JOIN product subb  with(nolock) ON suba.ord = subb.ord " & vbcrlf & _
					"inner join sortck subc  with(nolock) on subc.id = suba.ck "& vbcrlf &_
					"and subc.del=1 "& vbcrlf &_
					"and ("& vbcrlf &_
					"charindex('," & rs(0) & ",',','+replace(cast(subc.intro as varchar(4000)),' ','')+',')>0 "& vbcrlf &_
					"and ("& vbcrlf &_
					"or replace(cast(subc.intro as varchar(4000)),' ','') = '0'"& vbcrlf &_
					")" & vbcrlf &_
					") subaa " & vbcrlf & _
					"GROUP BY ord " & vbcrlf & _
					") AS b ON a.ord = b.ord " & vbcrlf & _
					"WHERE a.del = 1 "& showZeroSQL&" AND (isnull(ku_num,0)<=aleat1 or isnull(ku_num,0)>aleat2)" & vbcrlf & _
					") AS a " & vbcrlf & _
					"WHERE not a.date7 is NULL "& showKuLimitZeroSQL &" " & vbcrlf & _
					"AND a.ord NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
					"ORDER BY a.date7 DESC"
					Me.cn.execute sql
					rs.movenext
				wend
				rs.close
				Case 49:
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT " & m_setjmId & ",0,a.id,DATEDIFF(mi,'2000-01-01',a.lastdate)+100000*isnull(a.zhouqi,0),DATEDIFF(d,GETDATE(),a.lastdate),GETDATE() " & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"FROM " & vbcrlf & _
				"(SELECT a.id,a.personID, b.username,a.lastdate,a.zhouqi, " & vbcrlf & _
				"  (CASE a.unit " & vbcrlf & _
				"     WHEN 1 THEN Dateadd(yyyy, a.zhouqi, a.lastdate) " & vbcrlf & _
				"     WHEN 2 THEN Dateadd(qq, a.zhouqi, a.lastdate) " & vbcrlf & _
				"     WHEN 3 THEN Dateadd(m, a.zhouqi, a.lastdate) " & vbcrlf & _
				"     WHEN 4 THEN Dateadd(ww, a.zhouqi, a.lastdate) " & vbcrlf & _
				"     WHEN 5 THEN Dateadd(d, a.zhouqi, a.lastdate) " & vbcrlf & _
				"     ELSE NULL " & vbcrlf & _
				"  END ) AS nextdate, " & vbcrlf & _
				"  Isnull(a.alt, 1) AS alt " & vbcrlf & _
				"FROM   hr_person_health a  with(nolock) " & vbcrlf & _
				"       INNER JOIN hr_person b  with(nolock) ON b.userID = a.personID " & vbcrlf & _
				"WHERE  b.del = 0 AND a.lastdate IS NOT NULL AND a.zhouqi IS NOT NULL AND b.nowstatus NOT IN (2,3,4) " & vbcrlf & _
				") a " & vbcrlf & _
				"WHERE 1 = 1 AND a.alt < 2 " & vbcrlf & _
				"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"AND DATEDIFF(d,GETDATE(),a.nextdate)<=" & rAdvance &_
				"AND DATEDIFF(m,GETDATE(),a.nextdate)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
				"AND DATEDIFF(d,GETDATE(),a.nextdate)<=" & rAdvance &_
				"ORDER BY a.lastdate DESC"
				Me.cn.execute sql
				Case 66:
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT " & m_setjmId & ",0,a.id,DATEDIFF(mi,'2000-01-01',a.date2),DATEDIFF(d,GETDATE(),a.date2),GETDATE() " & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"FROM " & vbcrlf & _
				"(SELECT z.id,t.name,t.cateid,s.title,z.date2,ISNULL(z.alt, '') alt " & vbcrlf & _
				"FROM   tel t  with(nolock) " & vbcrlf & _
				"INNER JOIN sortFieldsContent z " & vbcrlf & _
				"       ON z.ord = t.ord " & vbcrlf & _
				"          AND z.del = 1 " & vbcrlf & _
				"          AND t.del = 1 " & vbcrlf & _
				"          AND z.sort = 1 " & vbcrlf & _
				"          AND t.sort3 = 2 " & vbcrlf & _
				"          AND t.isNeedQuali = 1 " & vbcrlf & _
				"          AND ISNULL(t.status_sp_qualifications, 0) = 0 " & vbcrlf & _
				"          AND LEN(z.date2) > 0 " & vbcrlf & _
				"          AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
				"          AND CHARINDEX(',"& uid &",', ',' + CAST(z.share AS VARCHAR(4000)) + ',') > 0 " & vbcrlf & _
				"          AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
				"INNER JOIN sortClass s " & vbcrlf & _
				"       ON z.sortid = s.id " & vbcrlf & _
				"          AND ISNULL(s.isStop, 0) = 0 " & vbcrlf & _
				"          AND s.sort1 = 2 " & vbcrlf & _
				") a " & vbcrlf & _
				"WHERE 1 = 1 " & vbcrlf & _
				"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"AND DATEDIFF(d,GETDATE(),a.date2)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
				"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"ORDER BY a.date2 DESC"
				Me.cn.execute sql
				Case 67:
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT " & m_setjmId & ",0,a.id,DATEDIFF(mi,'2000-01-01',a.date2),DATEDIFF(d,GETDATE(),a.date2),GETDATE() " & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"FROM " & vbcrlf & _
				"(SELECT z.id,t.name,t.cateid,s.title,z.date2,ISNULL(z.alt, '') alt " & vbcrlf & _
				"FROM   tel t  with(nolock) " & vbcrlf & _
				"INNER JOIN sortFieldsContent z " & vbcrlf & _
				"       ON z.ord = t.ord " & vbcrlf & _
				"          AND z.del = 1 " & vbcrlf & _
				"          AND t.del = 1 " & vbcrlf & _
				"          AND z.sort = 1 " & vbcrlf & _
				"          AND t.sort3 = 1 " & vbcrlf & _
				"          AND t.isNeedQuali = 1 " & vbcrlf & _
				"          AND ISNULL(t.status_sp_qualifications, 0) = 0 " & vbcrlf & _
				"          AND LEN(z.date2) > 0 " & vbcrlf & _
				"          AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
				"          AND CHARINDEX(',"& uid &",', ',' + CAST(z.share AS VARCHAR(4000)) + ',') > 0 " & vbcrlf & _
				"          AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
				"INNER JOIN sortClass s " & vbcrlf & _
				"       ON z.sortid = s.id " & vbcrlf & _
				"          AND ISNULL(s.isStop, 0) = 0 " & vbcrlf & _
				"          AND s.sort1 = 2 " & vbcrlf & _
				") a " & vbcrlf & _
				"WHERE 1 = 1 " & vbcrlf & _
				"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"AND DATEDIFF(d,GETDATE(),a.date2)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.date2)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
				"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"ORDER BY a.date2 DESC"
				Me.cn.execute sql
				Case 213:
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT "&m_setjmId&",0,a.id,DATEDIFF(d,'2000-01-01',a.date1),DATEDIFF(d,GETDATE(),a.date1),GETDATE() " & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"FROM ( " & vbCrLf &_
				"  SELECT a.id,a.date1,a.date7 FROM paybackinvoice a   with(nolock) " & vbCrLf &_
				"  INNER JOIN sortbz b ON b.id = a.bz " & vbCrLf &_
				"  WHERE a.del = 1 AND isInvoiced = 0  AND ISNULL(a.cateid,0) <> 0 " & vbCrLf &_
				") a " & vbCrLf &_
				"WHERE 1 =1 " & vbcrlf &_
				"AND DATEDIFF(d,GETDATE(),a.date1)<=" & rAdvance & " " & vbcrlf &_
				"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"ORDER BY a.date1 DESC,a.date7 DESC"
				Me.cn.execute sql
				Case 214:
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT "&m_setjmId&",0,id,DATEDIFF(d,'2000-01-01',date1),DATEDIFF(d,GETDATE(),date1),GETDATE() " & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"FROM payoutInvoice  with(nolock) WHERE del = 1 AND isInvoiced=0 " & vbCrLf &_
				"AND DATEDIFF(d,GETDATE(),date1)<=" & rAdvance & "  " & vbcrlf &_
				"AND id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"ORDER BY date1 DESC,date7 DESC"
				Me.cn.execute sql
				Case 52:
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT "&m_setjmId&",0,id,RemindNum*100+RemindUnit*10+cast(getdate() as int)," & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"isnull(daysFromNow,0) - " & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"isnull(case " & vbcrlf &_
				"when RemindUnit = 1 then RemindNum " & vbcrlf &_
				"when RemindUnit = 2 then RemindNum * 24 " & vbcrlf &_
				"when RemindUnit = 3 then RemindNum * 24 * 7 " & vbcrlf &_
				"when RemindUnit = 4 then RemindNum * 24 * 30 " & vbcrlf &_
				"when RemindUnit = 5 then RemindNum * 24 * 365 " & vbcrlf &_
				"end,0)" & vbcrlf &_
				",GETDATE() " & vbcrlf &_
				"FROM ( " & vbCrLf &_
				"SELECT p.ord, p.title, p.addcate, k.dateyx, k.id,ISNULL(p.RemindUnit,0) RemindUnit,ISNULL(p.RemindNum,0) RemindNum," & vbcrlf &_
				"datediff(hh,getdate(),k.dateyx) daysFromNow " & vbcrlf &_
				"FROM ku k  with(nolock) " & vbcrlf &_
				"INNER JOIN product p  with(nolock) ON p.ord = k.ord " & vbcrlf &_
				"INNER JOIN sortck ck  with(nolock) ON k.ck = ck.ord AND ck.del = 1 " & vbcrlf &_
				"WHERE (CAST(ISNULL(ck.intro,'') AS VARCHAR(4000))='0' OR CHARINDEX(',"&uid&",',','+CAST(ck.intro AS VARCHAR(4000))+',')>0) " & vbcrlf &_
				"INNER JOIN sortck ck  with(nolock) ON k.ck = ck.ord AND ck.del = 1 " & vbcrlf &_
				"AND p.del = 1 " & vbcrlf &_
				"AND k.num2 > 0 " & vbcrlf &_
				"AND p.RemindNum > 0 " & vbcrlf &_
				"AND k.dateyx IS NOT NULL " & vbcrlf &_
				"AND ISNULL(k.locked, 0) = 0 " & vbcrlf &_
				") a " & vbCrLf &_
				"WHERE 1 =1 " & vbcrlf &_
				"AND daysFromNow <= " & (rAdvance*24) & " " & vbcrlf &_
				"AND ord NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"ORDER BY dateyx DESC"
				Me.cn.execute sql
				Case 51:
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT "&m_setjmId&",0,id,DATEDIFF(d,'2000-01-01',ld_rettime),DATEDIFF(d,GETDATE(),ld_rettime),GETDATE() " & vbcrlf &_
				"FROM ( " & vbCrLf &_
				"  SELECT a.id, c.bk_name, a.ld_rettime, d.addcateid " & vbcrlf &_
				"  FROM O_Lendbookmx a with(nolock)  " & vbcrlf &_
				"  LEFT JOIN O_Lendbook d  with(nolock) ON a.Ld_fid=d.id " & vbcrlf &_
				"  LEFT JOIN O_regbook c  with(nolock) ON a.Ld_bkid=c.id " & vbcrlf &_
				"  WHERE a.ld_num > (SELECT isnull(sum(Ret_num),0) AS Ret_num FROM O_RetBookmx WHERE Ret_bkid=a.id) " & vbcrlf &_
				") a " & vbCrLf &_
				"WHERE 1 =1 " & vbcrlf &_
				"AND DATEDIFF(d,GETDATE(),ld_rettime)<=" & rAdvance & " " & vbcrlf &_
				"AND id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"ORDER BY ld_rettime DESC"
				Me.cn.execute sql
				Case 59:
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT "&m_setjmId&",0,id,DATEDIFF(d,'2000-01-01',Reguldate),DATEDIFF(d,GETDATE(),Reguldate),GETDATE() " & vbcrlf &_
				"FROM ( " & vbCrLf &_
				"  SELECT a.ID,a.Reguldate " & vbcrlf &_
				"  FROM hr_person a  with(nolock) " & vbcrlf &_
				"  WHERE  a.nowStatus = 5 AND a.del = 0 " & vbcrlf &_
				") a " & vbCrLf &_
				"WHERE 1 =1 " & vbcrlf &_
				"AND DATEDIFF(d,GETDATE(),Reguldate)<=" & rAdvance & " " & vbcrlf &_
				"AND id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"ORDER BY Reguldate DESC"
				Me.cn.execute sql
				Case 215:
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT "&m_setjmId&",0,chanceID,DATEDIFF(d,'2000-01-01',GETDATE()) * 1000 + backdays,backDays,GETDATE() " & vbcrlf &_
				"FROM dbo.erp_chance_callbackList('"& Now() &"') a" & vbCrLf &_
				"WHERE 1 =1 AND a.backdays <= ISNULL((SELECT ISNULL(tq1,5) FROM setjm WHERE cateid = "& uid &" AND ord = "&m_setjmId&" AND intro = '1'),5)  " & vbcrlf &_
				"AND chanceID NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"ORDER BY chanceID DESC"
				Me.cn.execute sql
				Case 300:
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT "&m_setjmId&",0,id,ISNULL(DATEDIFF(d,'2000-01-01',date4),0),ISNULL(DATEDIFF(d,GETDATE(),date4),0),GETDATE() " & vbcrlf &_
				"FROM document with(nolock)  " & vbCrLf &_
				"WHERE del = 1 AND validity = 2 AND (sp = 0 AND cateid_sp = 0) AND addcate = "& uid &" AND date4 is not null  " & vbcrlf &_
				"AND id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"ORDER BY id DESC"
				Me.cn.execute sql
				Case 301:
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT "&m_setjmId&",0,l.id,ISNULL(DATEDIFF(d,'2000-01-01',l.l_date4),0),ISNULL(DATEDIFF(d,GETDATE(),l.l_date4),0),GETDATE() " & vbcrlf &_
				"FROM documentlist l  with(nolock) " & vbCrLf &_
				"inner join document d on d.id = l.document "&  vbCrLf &_
				"WHERE d.del = 1 and l.del=1 AND l.l_validity = 2 AND (d.sp = 0 AND d.cateid_sp = 0) AND l.l_date4 is not null  " & vbcrlf &_
				"AND l.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"ORDER BY l.id DESC"
				Me.cn.execute sql
				Case 155:
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT " & m_setjmId & ",0,a.iss_id,DATEDIFF(mi,'2000-01-01',a.iss_endtime),DATEDIFF(d,GETDATE(),a.iss_endtime),GETDATE() " & vbcrlf &_
				"FROM " & vbcrlf & _
				"O_insure a  with(nolock) " & vbcrlf & _
				"WHERE a.del=1 " & vbcrlf & _
				"AND a.iss_id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"AND DATEDIFF(d,GETDATE(),a.iss_endtime)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.iss_endtime)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
				"ORDER BY a.iss_endtime DESC"
				Me.cn.execute sql
				Case 17:
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT " & m_setjmId & ",0,a.id,DATEDIFF(mi,'2000-01-01',a.date3),DATEDIFF(d,GETDATE(),a.date3),GETDATE() " & vbcrlf &_
				"FROM " & vbcrlf & _
				"(select *,(select TOP 1 id from hr_person  with(nolock) where del = 0 AND userid=ord) as id from gate_person) a " & vbcrlf & _
				"WHERE 1 = 1 " & vbcrlf & _
				"and a.id IS NOT NULL " & vbcrlf & _
				"AND a.id NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"AND DATEDIFF(d,GETDATE(),a.date3)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.date3)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
				"ORDER BY a.date3 DESC"
				Me.cn.execute sql
				Case 156:
				sql = "" & vbcrlf &_
				"INSERT INTO #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"SELECT " & m_setjmId & ",0,a.ord,DATEDIFF(mi,'2000-01-01',a.date3),DATEDIFF(d,GETDATE(),a.date3),GETDATE() " & vbcrlf &_
				"FROM " & vbcrlf & _
				"gate a " & vbcrlf & _
				"WHERE 1 = 1 " & vbcrlf & _
				"and a.ord IS NOT NULL " & vbcrlf & _
				"AND a.ord NOT IN (SELECT orderId FROM #reminderQueue WHERE reminderConfig = "&m_setjmId&")" & vbcrlf &_
				"AND DATEDIFF(d,GETDATE(),a.date3)<=" & rAdvance & " AND DATEDIFF(m,GETDATE(),a.date3)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
				"ORDER BY a.date3 DESC"
				Me.cn.execute sql
				Case 224:
				sql = "" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"select " & m_setjmId & ",0,id,datediff(d,'2000-01-01',dateEnd),datediff(d,getdate(),dateEnd),getdate() from M_WorkAssigns a " & vbcrlf &_
				"left join (" & vbcrlf & _
				"  --需要质检的工序中-质检通过数量最少的数量值" & vbcrlf & _
				"  select M_WorkAssigns , min(pnum) as pnum " & vbcrlf & _
				"  from " & vbcrlf & _
				"(" & vbcrlf & _
				"            select n.id as M_WorkAssigns, w.id ,sum(isnull(r.num1,0)) as pnum " & vbcrlf & _
				"            from M_WorkAssigns n with(nolock) " & vbcrlf & _
				"            inner join M_WFP_Assigns w on w.WFid = n.WProID and w.result=1 --工艺流程中需要质检的工序" & vbcrlf & _
				"            from M_WorkAssigns n with(nolock) " & vbcrlf & _
				"            left join M_ProcedureProgres r on r.[Procedure]=w.id and r.del=0 and r.result = 1 --质检通过" & vbcrlf & _
				"            from M_WorkAssigns n with(nolock) " & vbcrlf & _
				"            group by n.id , w.id" & vbcrlf & _
				"    ) s group by M_WorkAssigns" & vbcrlf & _
				") d on d.M_WorkAssigns = a.id" & vbcrlf & _
				"left join (" & vbcrlf & _
				"    select m.WAID , sum(NumQualified) as qnum ,max(m.MPDate) as newInDate" & vbcrlf & _
				"   from M_MaterialProgres m " & vbcrlf & _
				"   inner join M_MaterialProgresDetail t on t.MPID = m.id and m.del=0 and t.del=0" & vbcrlf & _
				"   group by m.WAID" & vbcrlf & _
				") c on c.WAID = a.id" & vbcrlf & _
				"where a.del=0 " & vbcrlf &_
				"and (case when (isnull(d.pnum,-1)=-1 or isnull(d.pnum,-1)>=a.NumMake ) and isnull(c.qnum,0)>=a.NumMake then 1 else 0 end) = 0 " & vbcrlf &_
				"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
				"and datediff(d,getdate(),dateEnd)<=" & rAdvance & " and datediff(m,getdate(),dateEnd)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
				"order by dateEnd desc,indate desc"
				Me.cn.execute sql
				Case 47003:
				sql = "" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"select " & m_setjmId & ",0,id,datediff(d,'2000-01-01',LimitEndDate),datediff(d,getdate(),LimitEndDate),getdate() from AcceptanceDraft a  with(nolock) " & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"where a.del=1 " & vbcrlf &_
				"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
				"and datediff(d,getdate(),LimitEndDate)<=" & rAdvance & " and datediff(m,getdate(),LimitEndDate)>=-" & AUTO_CLEAR_INTERVAL & " " & vbcrlf &_
				"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
				"order by LimitEndDate"
				Me.cn.execute sql
				Case 51011:
				sql = "" & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"select " & m_setjmId & ",0,id,datediff(d,'2000-01-01',date1),datediff(d,getdate(),date1),getdate() from dbo.M2_maintain a  with(nolock) " & vbcrlf &_
				"insert into #reminderQueue(reminderConfig,subCfgId,orderId,reloadFlag,daysFromNow,inDate) " & vbcrlf &_
				"where 1=1 " & vbcrlf & _
				"and a.id not in (select orderId from #reminderQueue where reminderConfig="&m_setjmId&")" & vbcrlf &_
				"AND DATEDIFF(d, GETDATE() ,(CASE Unit2 WHEN 0 THEN DATEADD(MINUTE,num2,date1) " & vbcrlf &_
				"WHEN 1 THEN DATEADD(HOUR,num2,date1) WHEN 2 THEN DATEADD(DAY,num2,date1) WHEN 3 THEN DATEADD(MONTH,num2,date1) " & vbcrlf &_
				"WHEN 4 THEN DATEADD(YEAR,num2,date1) end))<=" & rAdvance & " " & vbcrlf &_
				"order by date1 desc"
				Me.cn.execute sql
				End Select
				sql = "select * from setjm  with(nolock) where intro='1' and ord=" & m_setjmId
				Set rs = Me.cn.execute(sql)
				While rs.eof = False
					cfgId = rs("ord")
					cateid = rs("cateid")
					rType = rs("fw1")
					rAdvance = rs("tq1")
					topNum = rs("num1")
					Select Case cfgId
					Case Else :
					End Select
					rs.movenext
				wend
				cn.execute "exec erp_UpdateReminderQueue " & configId & "," & m_subCfgId & ",'" & lastReloadDate & "'"
			end sub
			Public Function getRemindIdByOID(oid)
				getRemindIdByOID = getRemindIdByOIDAndStat(oid,0)
			end function
			Public Function getRemindIdByOIDAndStat(oid,stat)
				Dim sql,rs
				sql = "select top 1 id from reminderQueue  with(nolock) where reminderConfig=" & configId & " and subCfgId="&m_subCfgId&_
				" and orderId=" & oid & " and orderStat=" & stat & " and id in " &_
				"("&listSql("rids")&")"
				Set rs = Me.cn.execute(sql)
				If rs.eof Then
					getRemindIdByOIDAndStat = -1
'If rs.eof Then
				else
					getRemindIdByOIDAndStat = CLng(rs(0))
				end if
			end function
			Public Function canCancelOrder(rid)
				If rid <= 0 Then
					canCancelOrder = False
				else
					Dim rs,sql
					sql = Me.listSql("all_withoutOrderBy")
					If InStr(sql,"canCancelAlt")>0 Then
						sql = "select top 1 * from (" & sql & ") a where rid=" & rid & " and canCancelAlt = 1"
					else
						sql = "select top 1 * from (" & sql & ") a where rid=" & rid
					end if
					Set rs = cn.execute(sql)
					If rs.eof Then
						canCancelOrder = False
					else
						canCancelOrder = Me.cn.execute("select top 1 reminderId from reminderPersons  with(nolock) where reminderId = " & rid & " and cateid=" & uid).eof
					end if
				end if
			end function
			Private Function getConditionByFW(s1,s2,cateField)
				Dim qOpen,qIntro
				Call fillInPower(s1,s2,qOpen,qIntro)
				if m_fw1&""="0" Then
					if qOpen = 3 then
						getConditionByFW = ""
					elseif qOpen = 1 then
						getConditionByFW=" and "&cateField&" in ("&qIntro&") "
					else
						getConditionByFW=" and 1=2 "
					end if
				else
					getConditionByFW=" and "&cateField&"="&uid&" and ("&qOpen&"=3 or ("&qOpen&"=1 and CHARINDEX(','+cast("&cateField&" as varchar)+',', ',"&qIntro&",') > 0))"
'getConditionByFW=" and 1=2 "
				end if
			end function
			Private Function getConditionWithShare(s1,s2,cateField,shareField)
				Dim qOpen,qIntro
				Call fillInPower(s1,s2,qOpen,qIntro)
				if qOpen = 3 then
					getConditionWithShare = ""
				elseif qOpen = 1 then
					getConditionWithShare = " AND ("&cateField&" IN ("&qIntro&") OR ("&shareField&" = '1' OR CHARINDEX(',"& uid &",', ',' + "& shareField &" + ',') > 0  ))"
'elseif qOpen = 1 then
				else
					getConditionWithShare = " AND ("&shareField&" = '1' OR CHARINDEX(',"& uid &",', ',' + "& shareField &" + ',') > 0  )"
'elseif qOpen = 1 then
				end if
			end function
			Private Function getCondition(s1,s2,cateField)
				Dim qOpen,qIntro
				Call fillInPower(s1,s2,qOpen,qIntro)
				if qOpen = 3 then
					getCondition = ""
				elseif qOpen = 1 then
					getCondition=" and "&cateField&" in ("&qIntro&") "
				else
					getCondition=" and "&cateField&"=0 and ("&qOpen&"=3 or ("&qOpen&"=1 and CHARINDEX(','+cast("&cateField&" as varchar)+',', ',"&qIntro&",') > 0))"
'getCondition=" and "&cateField&" in ("&qIntro&") "
				end if
			end function
			Private Sub findPower(arrPower,ByVal find_s1,ByVal find_s2,ByRef qx_open,ByRef qx_intro,ByRef qx_type)
				Dim i
				For i = 0 To ubound(arrPower,2)
					If find_s1 = arrPower(0,i) And find_s2 = arrPower(1,i) Then
						qx_open = arrPower(2,i)
						qx_intro = arrPower(3,i)
						qx_type = arrPower(4,i)
						Exit Sub
					end if
				next
				qx_open = 0
				qx_intro = "-255"
				qx_open = 0
				qx_type = 1
			end sub
			Private Sub fillInPower(s1,s2,ByRef qx_open,ByRef qx_intro)
				Dim rsPower
				If m_UsingPowerCache Then
					Call findPower(Global_Power,s1,s2,qx_open,qx_intro,"")
				else
					Set rsPower = Me.cn.execute("select qx_open,qx_intro from power  with(nolock) where ord="&uid&" and sort1="&s1&" and sort2="&s2)
					if rsPower.eof then
						qx_open = 0
						qx_intro = "-222"
						qx_open = 0
					else
						qx_open=rsPower("qx_open")
						If rsPower("qx_intro") & "" = "" Or Len(rsPower("qx_intro"))=0 Then
							qx_intro = "-222"
'If rsPower("qx_intro") & "" = "" Or Len(rsPower("qx_intro"))=0 Then
						else
							qx_intro = rsPower("qx_intro")
						end if
					end if
					rsPower.close
					set rsPower=Nothing
				end if
			end sub
			Public Sub initByRs(ByRef rs)
				Dim subRs
				configId = rs("id")
				m_subSql = rs("subSql")
				m_subCfgId = rs("subCfgId")
				If m_subCfgId > 0 Then
					Set subRs = Me.cn.execute(m_subSql&" and id="&m_subCfgId)
					If subRs.eof Then
						m_hasModule = False
						Exit Sub
					else
						m_name = Me.cn.execute(m_subSql&" and id="&m_subCfgId)(1)
					end if
				else
					m_name = rs("name")
				end if
				m_setjmId = rs("setjmId")
				m_mCondition = rs("mCondition")
				m_remindMode = rs("remindMode")
				m_qxlb = rs("qxlb")
				m_listqx = rs("listqx")
				m_detailqx = rs("detailqx")
				m_num1 = rs("num1")
				m_opened = (rs("opened") = "1")
				m_gate1 = rs("gate1")
				m_tq1 = rs("tq1")
				If m_tq1 & "" = "" Then  m_tq1 = 0
				m_fw1 = rs("fw1")
				m_moreLinkUrl = rs("moreLinkUrl")
				m_detailLinkUrl = rs("detailLinkUrl")
				m_moreLinkUrl_mobile = rs("moreLinkUrl_mobile")
				m_detailLinkUrl_mobile = rs("detailLinkUrl_mobile")
				m_canCancel = rs("canCancel")
				m_jointly = rs("jointly")
				m_titleMaxLength = rs("titleMaxLength")
				m_lastReloadDate = rs("lastReloadDate")
				m_MOrderSetting = rs("MOrderSetting")
				m_MBusinessType = rs("MBusinessType")
				m_cacheExpiredCondition = rs("cacheExpiredCondition") & ""
				m_canTQ = rs("canTQ")
				m_fwSetting = rs("fwSetting")
				If m_usingLv2Cache = True And Len(m_cacheExpiredCondition) > 0 Then
					m_cacheExpiredCondition = base64.URLDecode(base64.Base64Decode(m_cacheExpiredCondition))
					m_cacheExpiredCondition = m_cacheExpiredCondition & ";" & vbcrlf &_
					"select reminderId from ReminderPersons a  with(nolock) "&_
					"inner join reminderQueue b  with(nolock) on a.reminderId=b.id and a.cateid=" & uid &" "&_
					"and b.reminderConfig="&configId&";" & vbcrlf &_
					"select '" & Date &"' from qxlb  with(nolock) where sort1=1 "
				end if
				If Len(m_mCondition) = 0 Then
					m_hasModule = True
				else
					on error resume next
					m_hasModule = eval(base64.URLDecode(base64.Base64Decode(m_mCondition)))
					If Abs(Err.number)>0 Then
						m_hasModule = False
					end if
					On Error GoTo 0
				end if
				If m_usingLv2Cache = True Then
					Set m_cacheHelper = server.createobject(ZBRLibDLLNameSN & ".PageClass")
					Call m_cacheHelper.init(Me)
				end if
			end sub
			Public Sub init(cfgId,subCfgId)
				If InStr(cfgId,",") > 0 Then
					cfgId = Split(cfgId,",")(0)
				end if
				If Not isnumeric(cfgId) Or cfgId&""="" Then
					Response.write "参数cfgId不正确，类初始化失败！"
					Response.end
				end if
				configId = cfgId
				Dim sql,rs
				If subCfgId > 0 Then
					m_subCfgId = subCfgId
					sql = "select a.*,isnull(b.num1,4) num1,isnull(b.intro,'0') opened,isnull(b.gate1,1) gate1,b.tq1,b.fw1,"&subCfgId&" subCfgId from reminderConfigs a  with(nolock) " &_
					"left join setjm b  with(nolock) on a.setjmId=b.ord and b.cateid="&uid&" and b.subCfgId="&subCfgId&" where a.id=" & configId
				else
					sql = "select a.*,isnull(b.num1,4) num1,isnull(b.intro,'0') opened,isnull(b.gate1,1) gate1,b.tq1,b.fw1,0 subCfgId from reminderConfigs a  with(nolock) " &_
					"left join setjm b  with(nolock) on a.setjmId=b.ord and b.cateid="&uid&" where a.id=" & configId
				end if
				Set rs = Me.cn.execute(sql)
				If rs.eof Then
					Response.write "错误：未能读取到提醒配置信息！"
					Response.end
				end if
				Call initByRs(rs)
				rs.close
				Set rs=Nothing
			end sub
			Private Function getMoreLink()
				getMoreLink = "<a href=""" & moreLinkURL() & """><font style='font-weight:normal;'>更多&gt;&gt;&gt;</font></a>"
'Private Function getMoreLink()
			end function
			Public Function moreLinkURL()
				moreLinkURL = replaceTemplete(iif(m_isMobileMode,m_moreLinkURL_mobile,m_moreLinkURL))
			end function
			Private Function replaceTemplete(v)
				Dim r
				r = Replace(v,"@subId",m_subCfgId)
				r = Replace(r,"@date",date)
				r = Replace(r,"@MOrderId",m_MOrderSetting)
				r = Replace(r,"@cfgId",m_setjmId)
				replaceTemplete = r
			end function
			Private Function getTitleLink(title,orderId,cateid)
				If orderId&"" = "" Or orderId&"" = "0" Then
					getTitleLink = "【已删除数据】"
					Exit Function
				end if
				title = regEx.replace(title&"","")
				Dim url : url = m_detailLinkUrl
				If m_titleMaxLength > 0 Then
					If Len(title) > m_titleMaxLength Then title = Left(title,m_titleMaxLength-1) & "..."
'If m_titleMaxLength > 0 Then
				end if
				If title = "" Then title = "【无标题】"
				If Len(url&"") = 0 Then
					getTitleLink = title
					Exit Function
				end if
				If InStr(url,"@encodeId") > 0 Then
					url = Replace(url,"@encodeId",base64.pwurl(orderId))
				else
					url = Replace(url,"@id",orderId)
				end if
				url = replaceTemplete(url)
				If hasDetailPower(cateid) Then
					getTitleLink = "<a href='javascript:void(0)' class='remind_detail_link' onclick=""RemObj.openWin('" & url & "','remindWin"&configId&"');"">" & title & "</a>"
				else
					getTitleLink = title
				end if
			end function
			Public Function hasDetailPower(cateid)
				If m_detailqx = 0 Then
					hasDetailPower = True
				ElseIf existsPowerIntro(m_qxlb,m_detailqx,cateid) Then
					hasDetailPower = True
				else
					hasDetailPower = False
				end if
			end function
			Private Function getOrderStat(st)
				Select Case st
				Case 1:
				getOrderStat = "共享"
				Case 2:
				getOrderStat = "取消共享"
				Case 8 :
				getOrderStat = "审批中"
				Case 9 :
				getOrderStat = "待提交"
				Case 10:
				getOrderStat = "待审批"
				Case 11:
				getOrderStat = "审批通过"
				Case 12:
				getOrderStat = "审批退回"
				Case 16:
				getOrderStat = "未通过"
				Case 13:
				getOrderStat = "待审核"
				Case 14:
				getOrderStat = "审核通过"
				Case 15:
				getOrderStat = "审核退回"
				case 17:
				getOrderStat = "无需审批"
				Case Else
				End Select
			end function
			Private Function hasFieldInRs(ByRef r,ByVal fd)
				Dim kk
				For kk=0 To r.fields.count - 1
'Dim kk
					If r.fields(kk).name = fd Then
						hasFieldInRs = True
						Exit Function
					end if
				next
				hasFieldInRs = False
			end function
			Private Function openPower(x1,x2)
				Dim sql1,rs1,isOpen
				if x1<>"" and x2<>"" Then
					If m_UsingPowerCache Then
						Call findPower(Global_Power,x1,x2,isOpen,"","")
						openPower = isOpen
					else
						set rs1=server.CreateObject("adodb.recordset")
						sql1="select qx_open from power  with(nolock)  where ord="&uid&" and sort1="&x1&" and sort2="&x2&""
						rs1.open sql1,cn,1,1
						if rs1.eof Then
							openPower=0
							If x2=19 Then
								If cn.execute("select 1 from power with(nolock)  where ord="&uid&" and sort1="&x1&"").eof Then openPower = 1
							end if
						else
							openPower=rs1("qx_open")
						end if
						rs1.close
						set rs1=nothing
					end if
				else
					openPower=0
				end if
			end function
			Private Function IIf(e,v1,v2)
				If e = True Then
					iif = v1
				else
					iif = v2
				end if
			end function
			Public Function existsPowerIntro(byval sort1,byval sort2, byval CreatorID)
				Dim sql_qx,qx_type,qx_open,qx_intro
				dim i , item, hs, rs_qx
				hs = false
				for i = 0 to ubound(m_existsPowerIntro)
					if isarray(m_existsPowerIntro(i)) then
						item = m_existsPowerIntro(i)
						if item(0) = sort1 and item(1) = sort2 then
							qx_type = item(2)
							qx_open = item(3)
							qx_intro = item(4)
							hs = true
							exit for
						end if
					end if
				next
				if hs = false then
					sql_qx="select isnull(sort,0) as sort from qxlblist  with(nolock) where sort1=" & sort1 & " and sort2="& sort2
					set rs_qx=cn.execute(sql_qx)
					if not rs_qx.eof then
						qx_type=rs_qx(0)
					else
						qx_type=0
					end if
					rs_qx.close
					sql_qx="select isnull(qx_open,0) as qx_open,isnull(qx_intro,'') as qx_intro from [power]  with(nolock) where sort1=" & sort1 & " and sort2="&sort2&" and ord=" & uid
					set rs_qx=cn.execute(sql_qx)
					if not rs_qx.eof then
						qx_open=rs_qx(0)
						qx_intro=rs_qx(1)
					else
						qx_open=0
						qx_intro=""
					end if
					rs_qx.close
					set rs_qx=nothing
					redim preserve m_existsPowerIntro(m_expiCount)
					m_existsPowerIntro(m_expiCount) = split(sort1 & chr(1) & sort2 & chr(1) & qx_type & chr(1) & qx_open & chr(1) & qx_intro, chr(1))
					m_expiCount = m_expiCount+ 1
				end if
				if len(qx_open & "") = 0 then qx_open = 0
				qx_open = clng(qx_open)
				if qx_type = 1 then
					existsPowerIntro = (qx_open = 1)
				else
					if qx_open = 3 then
						existsPowerIntro = true
					elseif qx_open = 1 then
						existsPowerIntro =  CheckIntro(qx_intro,CreatorID&"")>0 And CreatorID > 0
					else
						existsPowerIntro = false
					end if
				end if
			end function
			private function CheckIntro(str1,str2)
				dim ids: ids = split(replace(str2 & ""," ",""),",")
				dim inx : inx = 0
				for n=0 to ubound(ids)
					if ids(n)&""<>"" and ids(n)&""<>"0" then
						inx = instr(","&replace(str1 & ""," ","")&",",","& ids(n) &",")
						if inx>0 then exit for
					end if
				next
				CheckIntro = inx
			end function
			Public Property Get user
			user = session("personzbintel2007") & ""
			If Len(user) = 0 Then
				user = request.querystring("__sys_uid_sign")
				if isnumeric(user)= false then
					user = 0
				else
					user = clng(user)
				end if
			end if
			End Property
			Public Property Get isAdmin
			dim rs
			if len(is_admin) = 0 then
				Set rs = cn.execute("select top1 from gate  with(nolock) where ord=" & me.user)
				if rs.eof then
					is_admin = false
				else
					is_admin = (rs.fields(0).value & "" = "1")
				end if
				rs.close
			end if
			isAdmin = is_admin
			End Property
			Public Property Get isSupperAdmin
			Dim rs
			If Len(is_supperadmin) = 0 Then
				If Me.isAdmin  Then
					Set rs = cn.execute("select qx_open from power  with(nolock) where sort1=66 and sort2=12 and ord=" & Me.User & " and qx_open=1")
					is_supperadmin = Not rs.eof
					rs.close
				else
					is_supperadmin = false
				end if
			end if
			isSupperAdmin = is_supperadmin
			End Property
			Private Function HTMLDecode(fString)
				if not isnull(fString) Then
					fString = replace(fString, "&gt;", ">")
					fString = replace(fString, "&lt;", "<")
					fString = Replace(fString, "&nbsp;",CHR(32) )
					fString = Replace(fString, "&quot;",CHR(34) )
					fString = Replace(fString, "&#39;",CHR(39) )
					fString = Replace(fString, "",CHR(13))
					fString = Replace(fString, "</P><P>",CHR(10) & CHR(10))
					fString = Replace(fString, "<br>",CHR(10))
					HTMLDecode = fString
				end if
			end function
		End Class
		Class StringBuffer
			Private m_idx
			Private m_contents
			Private m_maxIdx
			Public Sub push(v)
				m_contents(m_idx) = v : m_idx = m_idx + 1
'Public Sub push(v)
				If m_idx > m_maxIdx Then
					m_maxIdx = m_maxIdx + 500
'If m_idx > m_maxIdx Then
					ReDim Preserve m_maxIdx(m_maxIdx)
				end if
			end sub
			Public Property Get toString
			toString = Join(m_contents,"")
			End Property
			Private Sub Class_Initialize
				m_idx = 0
				m_maxIdx = 500
				ReDim m_contents(m_maxIdx)
			end sub
			Private Sub Class_Teriminate
				Erase m_contents
			end sub
		End Class
		Class ReminderList
			Private m_reminders()
			Public m_rIdx
			Public m_popIdx
			Public Sub push(remindObj)
				m_rIdx = m_rIdx + 1
'Public Sub push(remindObj)
				ReDim Preserve m_reminders(m_rIdx)
				Set m_reminders(m_rIdx) = remindObj
			end sub
			Public Function pop
				If Me.hasRemind = False Then Exit Function
				Set pop = m_reminders(m_popIdx)
				m_popIdx = m_popIdx + 1
				Set pop = m_reminders(m_popIdx)
			end function
			Public Property Get reminders
			reminders = m_reminders
			End Property
			Public Property Get hasRemind
			hasRemind = m_rIdx >=0 And m_popIdx <= m_rIdx
			End Property
			Private Sub Class_Initialize
				m_rIdx = -1
'Private Sub Class_Initialize
				m_popIdx = 0
			end sub
			Private Sub Class_Teriminate
				Dim i
				For i = 0 To ubound(m_reminders)
					Set m_reminders(i) = Nothing
				next
			end sub
		end class
		
		Dim Str_Result2,Str_Result3,str_temp_where
		Dim open_2_1,intro_2_1, open_1_5, intro_1_5
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
		
		Function getint(v)
			If isnumeric(v) And Len(v & "") > 0 then
				getint = CLng(v)
			else
				getint = 0
			end if
		end function
		Sub page_load
			Dim rs
			Set conn = cn
			Dim arrShow()
			Dim arrName()
			Dim arrField()
			Dim arrSort()
			Dim intgate1
			Call fillPowerInfo(2,1,open_2_1,intro_2_1)
			Call fillPowerInfo(1,5,open_1_5,intro_1_5)
			xlstype=request("xlstype")
			Set rs=conn.execute("select (case when isnull(name,'')='' then oldname else name end ) as name, (case when show>0 then 1 else 0 end) as show,gate1,fieldName,sort2 from setfields order by gate1 asc ")
			While Not rs.eof
				intgate1=rs("gate1")
				redim Preserve arrShow(intgate1)
				redim Preserve arrName(intgate1)
				redim Preserve arrField(intgate1)
				redim Preserve arrSort(intgate1)
				arrShow(intgate1)=rs("show")
				if rs("fieldName")&""="hk_xz" then
					arrName(intgate1)=Replace(rs("name")&"（%）"," ","")
				else
					arrName(intgate1)=Replace(rs("name")," ","")
				end if
				arrField(intgate1)=rs("fieldName")
				arrSort(intgate1)=CInt(rs("sort2"))
				rs.movenext
			wend
			rs.close
			Dim fields,i,allFieldsName,Export_FILEDS,allFieldWidth
			Export_FILEDS=""
			allFieldWidth = ""
			allFieldsName = Chr(1) & Chr(2)
			If ZBRuntime.MC(207101) Then
				fields = Array(1,3,4,5,6,7,8,9,52,10,11,16,12,13,14,15,33,34,35,36,37,38,39,50,40,41,42,43,44,45,51,46,47,48,49,17,30,31,27,28,29,19,21,20,22,23,24,100)
			else
				fields = Array(1,3,4,5,6,7,8,9,10,11,16,12,13,14,15,33,34,35,36,37,38,39,50,40,41,42,43,44,45,51,46,47,48,49,17,30,31,27,28,29,19,21,20,22,23,24,100)
			end if
			For i=0 To ubound(fields)
				If arrShow(fields(i)) = 1 Then
					if fields(i)=16 then
						Export_FILEDS = Export_FILEDS & "tel.pernum1 ["&arrName(16)&"(销售)],tel.pernum2 ["&arrName(16)&"(技术)],"
						allFieldsName = allFieldsName & ","&arrName(16)&"(销售),"&arrName(16)&"(技术)"
						allFieldWidth = allFieldWidth & ",87,87"
					else
						Export_FILEDS = Export_FILEDS & getFieldSql(fields(i),arrField(fields(i)),arrName(fields(i)),arrSort(fields(i)))
						allFieldsName = allFieldsName & "," & arrName(fields(i))
						allFieldWidth = allFieldWidth & "," & getFieldWidth(fields(i))
					end if
				end if
			next
			Export_FILEDS = Export_FILEDS &"tel.fkdays as [账期],tel.fkdate as [结算日期],"
			Dim sql1,zdy_join_sql,gl,fname,tt, rs1
			set rs1=server.CreateObject("adodb.recordset")
			sql1="select id,title,name,sort,gl from zdy where sort1=1 and set_open=1 and dc=1 order by gate1 asc "
			rs1.open sql1,conn,1,1
			zdy_join_sql = ""
			if not rs1.eof then
				do until rs1.eof
					gl = rs1("gl")
					fname = rs1("name")
					tt = rs1("title")
					If rs1("sort") = 1 Then
						Export_FILEDS=Export_FILEDS & "jj_"&fname&".sort1 as ["& tt &"],"
						zdy_join_sql = zdy_join_sql & " left join sortonehy jj_"&fname&" on jj_"&fname&".ord=tel."&fname & " " & vbcrlf
						allFieldWidth = allFieldWidth & ",87"
					else
						Export_FILEDS=Export_FILEDS & "tel." & fname & " as ["& tt &"],"
						allFieldWidth = allFieldWidth & ",205"
					end if
					allFieldsName = allFieldsName & "," & tt
					rs1.movenext
				loop
			end if
			rs1.close
			set rs1=Nothing
			Dim aliasIdx,exzdy_join_sql,kz_sql,rs_kz_zdy
			set rs_kz_zdy=server.CreateObject("adodb.recordset")
			aliasIdx = 1
			exzdy_join_sql = ""
			kz_sql="select FName,id,FType from erp_customFields  where TName=1 and IsUsing=1 and canExport=1 order by FOrder asc"
			rs_kz_zdy.open kz_sql,conn,1,1
			do while not rs_kz_zdy.eof
				if rs_kz_zdy("FType")=5 then
					Export_FILEDS=Export_FILEDS&"dbo.TrimHTML(c_f_"&aliasIdx &".FValue) as ["&rs_kz_zdy("FName")&"],"
				else
					Export_FILEDS=Export_FILEDS&"c_f_"&aliasIdx &".FValue as ["&rs_kz_zdy("FName")&"],"
				end if
				exzdy_join_sql = exzdy_join_sql & _
				" left join erp_customValues c_f_"&aliasIdx & " on tel.ord=c_f_"&aliasIdx&".orderid AND c_f_"&aliasIdx & ".FieldsID="&rs_kz_zdy("ID") & vbcrlf
				aliasIdx = aliasIdx + 1
				allFieldsName = allFieldsName & "," & rs_kz_zdy("FName")
				Select Case rs_kz_zdy("FType")
				Case 1 : allFieldWidth = allFieldWidth & ",205"
				Case 2,5 : allFieldWidth = allFieldWidth & ",245"
				Case 3,4 : allFieldWidth = allFieldWidth & ",165"
				Case 6 : allFieldWidth = allFieldWidth & ",80"
				Case 7 : allFieldWidth = allFieldWidth & ",87"
				Case Else :
				End Select
				rs_kz_zdy.movenext
			loop
			rs_kz_zdy.close
			set rs_kz_zdy =nothing
			if ZBRuntime.MC(12001) then
				Export_FILEDS=Export_FILEDS & "(SELECT top 1  CHAR(13)+CHAR(10)+(select sort1 from sortonehy where ord=reply.sort98)+CHAR(13)+CHAR(10) FROM reply where sort1=1 and del=1 and ord=tel.ord and (" & open_1_5 & "=3 or (" & open_1_5 & "=1 and (charindex(','+cast(isnull(cateid,-234) as varchar(10))+',','," & intro_1_5 & ",')>0 or (charindex(',"& session("personzbintel2007") &",',','+replace(isnull(share,0),' ','')+',')>0 or share = '1')) )  or ((" & open_1_5 & "=0 or (charindex(',"& session("personzbintel2007") &",',','+replace(isnull(share,'0'),' ','')+',')>0 or share = '1' )) ) ) ORDER BY date7 desc) as [跟进方式],(SELECT top 1  CHAR(13)+CHAR(10)+'跟进：'+NAME+(CASE ISNULL(NAME2,'') WHEN '' THEN ' ' ELSE ' 对方联系人：'+NAME2+' ' END)+convert(varchar(20),date7,120)+CHAR(13)+CHAR(10)+dbo.TrimHTML(intro)+' '+CHAR(13)+CHAR(10) FROM reply where sort1=1 and del=1 and ord=tel.ord and (" & open_1_5 & "=3 or ("& open_1_5 & "=1 and (charindex(','+cast(isnull(cateid,-234) as varchar(10))+',','," & intro_1_5 & ",')>0 or (charindex(',"& session("personzbintel2007") &",',','+replace(isnull(share,0),' ','')+',')>0 or share = '1')) )  or ((" & open_1_5 & "=0 or (charindex(',"& session("personzbintel2007") &",',','+replace(isnull(share,'0'),' ','')+',')>0 or share = '1' )) ) ) ORDER BY date7 desc) as [洽谈进展],"
'if ZBRuntime.MC(12001) then '
				allFieldsName = allFieldsName & ",跟进方式,洽谈进展"
				allFieldWidth = allFieldWidth & ",205,245"
			end if
			Set rs=conn.execute("select short_str from dbo.split('"&Replace(allFieldsName,"'","''")&"',',') group by short_str having count(*)>1")
			If rs.eof = False Then
				Response.write "" & vbcrlf & "        <script>" & vbcrlf & "             parent.jQuery('#lvw_xls_proc_bar').hide();" & vbcrlf & "              alert(""【"
				Response.write rs(0)
				Response.write "】字段名称重复，请修改后再导出"");" & vbcrlf & "        </script>" & vbcrlf & "        "
				rs.close
				conn.close
				Response.end
			end if
			Dim SQL, BC
			Dim px , Str_Result, join_Str_Result, persons_result
			Set BC = server.createobject(ZBRLibDLLNameSN & ".Base64Class")
			px = BC.SafeDeCode(request.form("px_v"))
			Str_Result = BC.safeDeCode(request.form("Str_Result_v"))
			Dim dcPowerCondition,intro_dc
			intro_dc = app.power.GetPowerIntro(1,10)
			join_Str_Result = BC.SafeDeCode(request.form("join_Str_Result_v"))
			persons_result = BC.SafeDeCode(request.form("persons_result_v"))
			If Len(persons_result) > 0 Then persons_result = persons_result & ";"
			SQL= "set nocount on;" & persons_result & "select "&Export_FILEDS&"tel.date1 as [添加时间]," & vbcrlf &_
			" gt1.name as [销售人员] ,gt2.name as [添加人员], " & vbcrlf &_
			" (select top 1 date7 from reply where ord=tel.ord order by date7 desc) as ctdate , " & vbcrlf &_
			" (case isnull(tel.cateid_sp,0) when 0 then isnull(tel.intro_sp_cateid,0) else isnull(tel.cateid_sp,0) end ) as cateidSpPx "&vbcrlf&_
			" from tel " & vbcrlf &_
			" inner join (select ord as t_oid from tel " & join_Str_Result & " " & Str_Result &") xx on xx.t_oid=tel.ord " & vbcrlf &_
			" left join person B on tel.person=b.ord  " & vbcrlf &_
			" left join sort4 st4 on st4.ord=tel.sort " & vbcrlf &_
			" left join sort5 st5 on st5.ord=tel.sort1 " & vbcrlf &_
			" left join sortonehy so1 on so1.ord=tel.jz " & vbcrlf &_
			" left join sortonehy so2 on so2.ord=tel.ly " & vbcrlf &_
			" left join sortonehy so3 on so3.ord=tel.trade " & vbcrlf &_
			" left join sortonehy so4 on so4.ord=tel.credit " & vbcrlf &_
			" left join menuarea ma on ma.id=tel.area " & vbcrlf &_
			" left join sort9 st9 on st9.ord=B.role " & vbcrlf &_
			" left join gate gt1 on gt1.ord=tel.cateid " & vbcrlf &_
			" left join gate gt2 on gt2.ord=tel.cateadd " & vbcrlf &_
			zdy_join_sql & exzdy_join_sql & app.iif(intro_dc="",""," where "&app.iif(xlstype="1"," tel.cateid"," tel.cateidgq ")&"  in (" & intro_dc & ")") & px  & "; set nocount off"
			Dim adapter
			Dim sqls,sheetSetting,item
			Set adapter = New ExcelExportAdapter
			adapter.fileName = "客户资料"
			Set sheetSetting = New SqlSoruce
			sheetSetting.sql = SQL
			sheetSetting.title = "客户资料"
			Dim hd,arrFieldNames,arrFieldWidth
			arrFieldNames = Split(allFieldsName,",")
			arrFieldWidth = Split(allFieldWidth,",")
			For i = 1 To ubound(arrFieldNames)
				Set hd = New HeaderColumnSetting
				hd.dbname = arrFieldNames(i)
				hd.dbtype = "str"
				hd.canSum = False
				If arrFieldWidth(i)<>"" Then
					hd.width = arrFieldWidth(i)
				end if
				sheetSetting.headerSettings.add(hd)
			next
			if arrShow(15)=1 then
				Set hd = New HeaderColumnSetting
				hd.dbname = arrName(15)
				hd.dbType = "money"
				hd.align = "center"
				hd.align2 = "center"
				hd.canSum = True
				sheetSetting.headerSettings.add(hd)
			end if
			Set hd = New HeaderColumnSetting
			hd.dbname = "ctdate"
			hd.display = "none"
			sheetSetting.headerSettings.add(hd)
			Set hd = New HeaderColumnSetting
			hd.dbname = "销售人员"
			hd.dbtype = "str"
			hd.canSum = False
			sheetSetting.headerSettings.add(hd)
			Set hd = New HeaderColumnSetting
			hd.dbname = "添加人员"
			hd.dbtype = "str"
			hd.canSum = False
			sheetSetting.headerSettings.add(hd)
			Set hd = New HeaderColumnSetting
			hd.dbname = "cateidSpPx"
			hd.display = "none"
			sheetSetting.headerSettings.add(hd)
			adapter.sqls.add(sheetSetting)
			adapter.export
		end sub
		Function getFieldWidth(idx)
			Select Case idx
			Case 1: getFieldWidth="205"
			Case 3: getFieldWidth="205"
			Case 4: getFieldWidth="87"
			Case 5: getFieldWidth="205"
			Case 6: getFieldWidth="87"
			Case 7: getFieldWidth="87"
			Case 8: getFieldWidth="87"
			Case 9: getFieldWidth="87"
			Case 10: getFieldWidth="205"
			Case 11: getFieldWidth="87"
			Case 12: getFieldWidth="205"
			Case 13: getFieldWidth="110"
			Case 14: getFieldWidth="80"
			Case 15: getFieldWidth="165"
			Case 17: getFieldWidth="80"
			Case 19: getFieldWidth="110"
			Case 20: getFieldWidth="110"
			Case 21: getFieldWidth="110"
			Case 22: getFieldWidth="110"
			Case 23: getFieldWidth="110"
			Case 24: getFieldWidth="110"
			Case 27: getFieldWidth=""
			Case 28: getFieldWidth=""
			Case 29: getFieldWidth=""
			Case 30: getFieldWidth="80"
			Case 31: getFieldWidth=""
			Case 33: getFieldWidth="245"
			Case 34: getFieldWidth="205"
			Case 35: getFieldWidth="205"
			Case 36: getFieldWidth="205"
			Case 37: getFieldWidth="245"
			Case 38: getFieldWidth="205"
			Case 39: getFieldWidth="205"
			Case 40: getFieldWidth="205"
			Case 44: getFieldWidth="205"
			Case 45: getFieldWidth="205"
			Case 46: getFieldWidth="205"
			Case 50: getFieldWidth="205"
			Case 51: getFieldWidth="205"
			Case 52: getFieldWidth="87"
			Case Else
			getFieldWidth = ""
			End Select
		end function
		Sub search_scope(strField, strValue, intType)
			If strValue<>"" Then
				Select Case intType
				Case 1 : str_Result=str_Result+" and "& strField &" like '%"& strValue &"%'"
'Select Case intType
				Case 2 : str_Result=str_Result+" and "& strField &" not like '%"& strValue &"%'"
'Select Case intType
				Case 3 : str_Result=str_Result+" and  "& strField &"='"&strValue&"'"
'Select Case intType
				Case 4 : str_Result=str_Result+" and "& strField &"<>'"&strValue&"'"
'Select Case intType
				Case 5 : str_Result=str_Result+" and "& strField &" like '"& strValue &"%'"
'Select Case intType
				Case 6 : str_Result=str_Result+" and "& strField &" like '%"& strValue &"'"
'Select Case intType
				Case 7 : str_Result=str_Result+" and exists(select 1 from person b where del=1 and (tel.person=b.ord or b.company=tel.ord) and name like '%"&strValue&"%' )"
'Select Case intType
				Case 8 : str_Result=str_Result+" and exists(select 1 from person b where del=1 and (tel.person=b.ord or b.company=tel.ord) and phone like '%"&strValue&"%')"
'Select Case intType
				Case 9 : str_Result=str_Result+" and exists(select 1 from person b where del=1 and (tel.person=b.ord or b.company=tel.ord) and mobile like '%"&strValue&"%')"
'Select Case intType
				End Select
			end if
		end sub
		Function getTelList(ByVal ord,ByVal v2)
			Dim f_sql,f_rs,v, m
			If InStr(1,ord, "select",1) > 0 Then
				ord = ""
				getTelList = "select 1 from dbo.erp_sale_getWillReplyList('" & v2 & "',0) x where x.ord=tel.ord"
			else
				ord = Replace(ord, " ", "")
				getTelList = "select 1 from dbo.erp_sale_getWillReplyList('" & v2 & "',0) x where  x.cateid in (" & ord & ") and x.ord=tel.ord"
			end if
		end function
		Sub search_scope_kz_inttype(strField, id, strValue, intType)
			If strValue<>"" Then
				Select Case intType
				Case 1 : str_Result=str_Result+" and "&strField&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& strValue &"%')"
'Select Case intType
				Case 2 : str_Result=str_Result+" and "&strField&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue not like '%"& strValue &"%')"
'Select Case intType
				Case 3 : str_Result=str_Result+" and "&strField&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& strValue &"')"
'Select Case intType
				Case 4 : str_Result=str_Result+" and "&strField&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue<>'"& strValue &"')"
'Select Case intType
				Case 5 : str_Result=str_Result+" and "&strField&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '"& strValue &"%')"
'Select Case intType
				Case 6 : str_Result=str_Result+" and "&strField&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue like '%"& strValue &"')"
'Select Case intType
				Case 7 : str_Result=str_Result+" and exists(select 1 from person b where del=1 and (tel.person=b.ord or b.company=tel.ord) and name like '%"&strValue&"%' )"
'Select Case intType
				Case 8 : str_Result=str_Result+" and exists(select 1 from person b where del=1 and (tel.person=b.ord or b.company=tel.ord) and phone like '%"&strValue&"%')"
'Select Case intType
				Case 9 : str_Result=str_Result+" and exists(select 1 from person b where del=1 and (tel.person=b.ord or b.company=tel.ord) and mobile like '%"&strValue&"%')"
'Select Case intType
				End Select
			end if
		end sub
		Sub search_scope_kz(strField, id, FType, strValue, intType)
			Dim sqldate
			Select Case FType
			Case 1,2,4,5 : Call search_scope_kz_inttype(strField, id, strValue, intType)
			Case 3 :
			sqldate=""
			If intType<>"" Then sqldate=" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime) end)>=cast('"& intType &"'as datetime)"
			sqldate=""
			If strValue<>"" Then sqldate=sqldate&" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime) end)<=cast('"& strValue &"' as datetime)"
			sqldate=""
			If sqldate<>"" Then str_Result=str_Result+" and "&strField&" in (select OrderID from ERP_CustomValues where FieldsID="&id&""&sqldate&")"
			sqldate=""
			Case Else
			str_Result=str_Result+" and "&strField&" in (select OrderID from ERP_CustomValues where FieldsID="&id&" and FValue='"& strValue &"')"
'Case Else
			End Select
		end sub
		Function SameList(ByVal RequestData, ByVal ConfigData)
			If Len(RequestData) = 0 Then SameList = ConfigData : Exit function
			If Len(ConfigData) = 0 Then SameList = RequestData : Exit Function
			Dim arr1 : arr1 = Split(Replace(RequestData , " ", ""), ",")
			Dim arr2 : arr2 = "," & Replace(ConfigData," ","") & ","
			Dim arr3 : ReDim arr3(0)
			Dim i, x : x = 0
			For i = 0 To ubound(arr1)
				If InStr(arr2, "," & arr1(i) & ",") > 0 Then
					ReDim Preserve arr3(x)
					arr3(x) = arr1(i)
					x = x + 1
					arr3(x) = arr1(i)
				end if
			next
			If x = 0 Then
				SameList = "-1"
'If x = 0 Then
			else
				SameList = Join(arr3, ",")
			end if
		end function
		Function menuarea2(khqy,tb)
			if khqy&""<>"" then
				dim kharea , rsf
				kharea = ""
				khqy = replace(khqy," ","")
				set rsf = conn.execute("select khqy=dbo.GetMenuArea('"& khqy &"','"& tb &"')")
				if not rsf.eof then
					kharea = rsf(0)
				end if
				rsf.close
				set rsf = nothing
				menuarea2 = kharea
			end if
		end function
		Function getFieldSql(gate1,fieldValue,nameValue,sortValue)
			Select Case gate1
			Case 4: getFieldSql = "isnull(st4.sort1,'') as [" & nameValue & "],"
			Case 5: getFieldSql = "isnull(st5.sort2,'') as [" & nameValue & "],"
			Case 9: getFieldSql = "isnull(so1.sort1,'') as [" & nameValue & "],"
			Case 6: getFieldSql = "isnull(so2.sort1,'') as [" & nameValue & "],"
			Case 7: getFieldSql = "isnull(ma.menuname,'') as [" & nameValue & "],"
			Case 8: getFieldSql = "isnull(so3.sort1,'') as [" & nameValue & "],"
			Case 29: getFieldSql = "isnull(st9.sort1,'') as [" & nameValue & "],"
			Case 17: getFieldSql = "case when "&open_2_1&"=3 or ("&open_2_1&"=1 and "&_
			"charindex(','+cast(tel.cateidgq as varchar)+',',',"&intro_2_1&",')>0) or "&_
			"sharecontact=1 then b.name else '' end [&nameValue&],"
			Case 15: getFieldSql = "isnull(tel." & fieldValue & ",0) as [" & nameValue & "],"
			Case 52: getFieldSql = "isnull(so4.sort1,'') as [" & nameValue & "],"
			Case Else
			If sortValue=1 Or sortValue=3 Or sortValue =4 Then
				getFieldSql = "tel." & fieldValue & " as [" & nameValue & "],"
			ElseIf sortValue=2 Then
				getFieldSql = "B." & fieldValue & " as [" & nameValue & "],"
			else
				getFieldSql = ""
			end if
			End Select
		end function
		
%>
