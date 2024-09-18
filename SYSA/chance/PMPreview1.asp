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
' Dim z : Set z = server.createobject(ZBRLibDLLNameSN & ".Library")
' z.GetLibrary "ZBIntel2013CheckBitString"
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
		Set ZBRuntime = app.Library
' If ZBRuntime.loadOK Then
' ZBRuntime.getLibrary "ZBIntel2013CheckBitString"
' If ZBRuntime.loadOK then
' if app.isMobile then
' response.clear
' response.CharSet = "utf-8"
' response.clear
' Response.BinaryWrite app.base64.UnicodeToUtf8("系统【服务端】未正常启动，请检查服务器环境是否正常。")
' Response.end
' else
' Response.write "<script>top.window.location.href ='" & app.virpath & "index2.asp?id2=8'</script>"
' end if
' Set app = Nothing
' Set ZBRuntime = Nothing
' Exit Sub
' end if
' end if
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
	
	class FlowChartClass
		Public title
		Public id
		Public fontsize
		Public color
		Public linecolor
		Public bordercolor
		Private remarks
		Private js
		Private jscount
		Public formattext
		Private Sub addcode(ByVal code)
			js(jscount) = code
			jscount = jscount + 1
			js(jscount) = code
		end sub
		Public Sub AddRemark(ByVal html, ByVal remark)
			Dim c : c = ubound(remarks) + 1
'Public Sub AddRemark(ByVal html, ByVal remark)
			ReDim Preserve remarks(c)
			remarks(c) = html & Chr(1) & remark
		end sub
		Public Property Get RemarkHtml
		Dim i, ii, items, htmls()
		Dim c : c = ubound(remarks)
		If c = 0 Then Exit property
		ReDim htmls(c+5)
'If c = 0 Then Exit property
		htmls(0) = "<table style='table-layout:fixed;width:100%'><col style='width:34%;'><col style='width:66%;'>"
'If c = 0 Then Exit property
		For i = 1 To c
			ii = ii + 1
'For i = 1 To c'
			items = Split(remarks(i), Chr(1))
			htmls(ii) = "<tr><td style='text-align:center;'>" &  items(0) & "</td><td>" & items(1) & "</td></tr>"
			'items = Split(remarks(i), Chr(1))
		next
		ii = ii + 1
		'items = Split(remarks(i), Chr(1))
		htmls(ii) = "</table>"
		RemarkHtml = Join(htmls,"")
		Erase htmls
		End property
		Public Sub load(ByVal sql)
			Dim rs, ids, html
			ReDim js(5000) : jscount = 0
			cn.execute "select * into #flowtmp  from (" & sql & ") t "
			Set rs = cn.execute("select distinct id, txt, html, tag, color, bgcolor, gtype from #flowtmp t")
			While rs.eof = False
				html = rs("html").value & ""
				If Len(Formattext) > 0 Then
					html = Replace(Formattext, "@value", html)
					If InStr(html, "@") > 0 Then html = Replace(html, "@tag", rs("tag").value & "")
					If InStr(html, "@") > 0 Then html = Replace(html, "@id", rs("id").value & "")
					If InStr(html, "@") > 0 Then html = Replace(html, "@gtype", rs("gtype").value & "")
					If InStr(html, "@") > 0 Then html = Replace(html, "@color", rs("color").value & "")
					If InStr(html, "@") > 0 Then html = Replace(html, "@bgcolor", rs("bgcolor").value & "")
					If InStr(html, "@") > 0 Then html = Replace(html, "@txt", rs("@txt").value & "")
				end if
				Call addNode(rs("id").value, rs("txt").value & "", html & "", rs("tag").value & "", rs("color").value & "", rs("bgcolor").value & "", rs("gtype").value & "","")
				rs.movenext
			wend
			rs.close
			Set rs = cn.execute("select distinct id, id1 from #flowtmp t where id1>0 and id1 in (select id from #flowtmp)")
			While rs.eof = False
				Call addcode("g.addEdge(null, ""fn_" & id & "_" & rs("id1").value & """, ""fn_" & id & "_" & rs("id").value & """);"  & vbcrlf)
				rs.movenext
			wend
			rs.close
			set rs = nothing
			cn.execute "drop table #flowtmp"
		end sub
		Public Sub addNode(ByVal nodeid, ByVal innerText, ByVal innerHTML, ByVal tag, ByVal color, ByVal bgcolor, ByVal gtype, ByVal bordercolor)
			Dim txt
			txt = app.ConvertJsText(innerText)
			Call addcode("g.addNode(""fn_" & id & "_" & nodeid & """,{ label:""" & txt & """});" & vbcrlf)
			Call addcode("nodes[nodes.length]={id:""" & id & "_" & nodeid & """,txt:""" & app.convertjstext(innerHTML) & """,tag:""" & app.ConvertJsText(tag) & """,color:""" & color & """,bgcolor:""" & bgcolor & """,gtype:""" & gtype & """,brcolor:""" & bordercolor & """};" & vbcrlf)
		end sub
		Public Sub addMap(ByVal id1, ByVal id2)
			Call addcode("g.addEdge(null, ""fn_" & id & "_"  & id1 & """, ""fn_" & id & "_"  & id & """);")
		end sub
		Public Sub clear()
			ReDim js(5000)
		end sub
		Private Sub Class_Initialize()
			Call clear
			id = "c1"
			color = "#000"
			linecolor = "#aaa"
			bordercolor = "#73a6df"
			fontsize = "12px"
			ReDim remarks(0)
		end sub
		Public Sub Class_Terminate()
			Erase js
			Erase remarks
		end sub
		Public Function ScriptCode
			ScriptCode = Join(js,"")
		end function
		Public Property get ImageHtml()
		Dim  htmls(), htmli
		ReDim htmls(200) : htmli = 0
		htmls(0) = "<style>"
		htmli = htmli + 1: htmls(htmlI) = "#FCT_" & id & " text {font-weight: 300;font-size:" & fontsize & ";fill:white;} "
		htmls(0) = "<style>"
		htmli = htmli + 1: htmls(htmlI) = "#FCT_" & id & " .node rect {stroke: white;} "
		htmls(0) = "<style>"
		htmli = htmli + 1: htmls(htmlI) = "#FCT_" & id & " .edgePath path {stroke:" & linecolor & ";fill: none;} "
		htmls(0) = "<style>"
		htmli = htmli + 1: htmls(htmlI) = "#FCT_" & id & " div.noderect {position:absolute;text-align:center;color:" & color & ";font-size:" & fontsize & ";overflow:hidden;border:1px solid " & bordercolor & "}"
		htmls(0) = "<style>"
		htmli = htmli + 1: htmls(htmlI) = "#FCT_" & id & " div.nodetext  {font-family:宋体;position:absolute;text-align:center;color:" & color & ";font-size:" & fontsize & ";overflow:hidden;}"
		htmls(0) = "<style>"
		htmli = htmli + 1: htmls(htmlI) = "</style>"
		htmls(0) = "<style>"
		htmli = htmli + 1: htmls(htmlI) = "<div style='position:relative' bordercolor='" & bordercolor & "' id='FCT_" & id & "'><svg style='width:100%;height:100%' id='fmctl_" & id & "'>"
		htmls(0) = "<style>"
		htmli = htmli + 1: htmls(htmlI) = "<defs id='svg_defs_" & id & "'></defs>"
		htmls(0) = "<style>"
		htmli = htmli + 1: htmls(htmlI) = "</svg>"
		htmls(0) = "<style>"
		htmli = htmli + 1: htmls(htmlI) = "<div style='padding-top:10px;display:none' id='ie6msg_" & id & "'>"
		htmls(0) = "<style>"
		htmli = htmli + 1: htmls(htmlI) = "<span style='font-size:14px;color:red;'>抱歉，由于IE版本太低，系统无法加载图形，请安装图形支持组件。</span><br><br>"
		htmls(0) = "<style>"
		htmli = htmli + 1: htmls(htmlI) = "<div style='background-color:#f0f0f6;width:600px;padding:5px'>下载地址：&nbsp;<a style='color:blue' href='http://work.zbintel.com/help_a/downres.asp?svr=dx&f=GCframe.msi'>电信下载</a>&nbsp;&nbsp;<a href='http://work.zbintel.com/help_a/downres.asp?svr=wt&f=GCframe.msi' style='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) = "安装说明：<br>"
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) = "&nbsp;&nbsp;&nbsp;&nbsp;1、安装组件前，请关闭IE增强功能（window server默认是开启，window 8、window 7、window xp默认不开启）<br>"
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) = "&nbsp;&nbsp;&nbsp;&nbsp;2、安装组件后，请重新打开本页面。"
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) = "</div>"
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) = "<script language='javascript'>"
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) = "function DrawFlow(){"
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) =           "var g = new dagreD3.Digraph();"
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) =           "var nodes = new Array();"
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) =           me.scriptcode
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) =           "var renderer = new dagreD3.Renderer();"
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) =           "var svg = d3.select('svg');"
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) =           "var svgGroup = svg.append('g');"
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) =           "var layout = renderer.run(g, svgGroup);"
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) =           "DrawDefSelfNodes(nodes, """ & id & """);"
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) = "};"
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) = "window.autoPanelHeight(""" & id & """);"
'le='color:blue'>网通下载</a></div><br>"
		htmli = htmli + 1: htmls(htmlI) = "</script></div>"
'le='color:blue'>网通下载</a></div><br>"
		ImageHtml = Join(htmls, "")
		Erase htmls
		End property
	End class
	
	Sub page_load
		Dim flow : Set flow = New FlowChartClass
		If app.existsProc("App_OnInit") Then
			Call App_OnInit(flow)
		end if
		Response.write "<!DOCTYPE html>" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "    <meta charset=""UTF-8"">" & vbcrlf & "    <meta http-equiv=""X-UA-Compatible"" content=""chrome=1,IE=10"">" & vbcrlf & "        <title>"
		Response.write Info.title
		Response.write "</title>" & vbcrlf & "       <link rel=""stylesheet"" href="""
		Response.write app.virpath
		Response.write "skin/"
		Response.write Info.Skin
		Response.write "/css/comm.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write """ rel=""stylesheet"" type=""text/css""/>" & vbcrlf & "   <script type=""text/JavaScript"" src='"
		Response.write app.virpath
		Response.write "skin/"
		Response.write Info.Skin
		Response.write "/js/comm.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write "'></script>" & vbcrlf & "   <script type=""text/JavaScript"" src=""../inc/jquery-1.4.2.min.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "        <script type=""text/JavaScript"">window.onerror=function(){};</script>" & vbcrlf & "      <script type=""text/JavaScript"" src='"
		Response.write app.virpath
		Response.write "skin/"
		Response.write Info.Skin
		Response.write "/js/d3.min.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write "'></script>" & vbcrlf & "   <script type=""text/JavaScript"" src='"
		Response.write app.virpath
		Response.write "skin/"
		Response.write Info.Skin
		Response.write "/js/d3.flowchart.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write "'></script>"
		Dim i, jpath
		For i = 1 To 10
			jpath = app.getScriptPath(i)
			If Len(jpath)=0 Then Exit For
			Response.write vbcrlf & vbtab & "<script language='javascript' src='" & jpath & "'></script>"
		next
		Response.write "" & vbcrlf & "      <style>" & vbcrlf & "         @media print{ " & vbcrlf & "                  #comm_itembarbg {display:none;}" & vbcrlf & "                 body.defcomm {background-image:url();}" & vbcrlf & "          }" & vbcrlf & "               input[type=""button""] {min-width:1px;}" & vbcrlf & "     </style>" & vbcrlf & "</head>" & vbcrlf & "<body class='defcomm'><div id='comm_itembarbg'><div id='comm_itembarICO'></div><div id='comm_itembarText'><span>"
		Response.write flow.title
		Response.write "</span></div><div id='comm_itembarspc'></div><div id='comm_itembarright'><div style='float:left;padding-top:7px'><input type='button' class='oldbutton' value='打印' onclick='window.print()'></div>&nbsp;&nbsp;</div></div>" & vbcrlf & "<div style='position:absolute;top:74px;bottom:5px;left:20px;right:0px;overflow:auto'>" & vbcrlf & ""
		Response.write flow.ImageHtml
		Response.write "" & vbcrlf & "</div>" & vbcrlf & ""
		Dim rmhtml : rmhtml = flow.RemarkHtml
		If len(rmhtml) > 0 Then
			Response.write "<div style='width:150px;border:1px solid #ccc;top:84px;right:35px;position:fixed;padding-top:10px;padding-bottom:10px;background-color:white'>"
'If len(rmhtml) > 0 Then
			Response.write rmhtml
			Response.write "</div>"
		end if
		Response.write "" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
		Set flow = nothing
	end sub
	Sub App_oninit(ByVal f)
		dim vmlcss,pmord,jh,jhIU,jdtype,execorder,timeproject,budgetmoney,executors,actors,intro,mustat,allOKModel,commFields,linkFields,zdyFields,splinktype,nextid,sort1,id1
		dim conn,k,rs1,sql1,PMID,rs,sql,mobanid,ntsIU,s,rs2,sql2,dp
		set conn = cn
		jh=Request("jhlist")
		jhIU = Split(Trim(jh), ",")
		conn.CursorLocation = 3
		conn.BeginTrans
		pmord=-1
		For k = 0 To UBound(jhIU)
			jdtype=app.getint("jdtype"&jhIU(k))
			execorder=app.getint("execorder"&jhIU(k))
			timeproject=Request.form("timeproject"&jhIU(k))
			budgetmoney=Request.form("budgetmoney"&jhIU(k))
			executors=Request.form("executors"&jhIU(k))
			actors=Request.form("actors"&jhIU(k))
			intro=app.gettext("intro"&jhIU(k))
			mustat=app.getint("mustat"&jhIU(k))
			allOKModel=app.getint("allOKModel"&jhIU(k))
			commFields=Request.form("commFields"&jhIU(k))
			linkFields=Request.form("linkFields"&jhIU(k))
			zdyFields=Request.form("zdyFields"&jhIU(k))
			splinktype=app.getint("splinktype"&jhIU(k))
			nextid=app.gettext("nextid"&jhIU(k))
			sort1=Request.form("sort1"&jhIU(k))
			id1=app.getint("id1"&jhIU(k))
			IF jdtype <> "" Then
				Set rs1 = server.CreateObject("adodb.recordset")
				sql1 = "select * from ProcModelsNodes where sortid='"&999&k&"'"
				rs1.Open sql1, cn, 1, 3
				If Not rs1.EOF Then
				else
					rs1.addnew
					rs1("name") = sort1
					rs1("chancePMid") = pmord
					rs1("sortid") = CLng(jhIU(k))
					rs1("sortid1") = id1
					rs1("addcate") = session("personzbintel2007")
					rs1("date7") = now
					rs1("jdtype") = jdtype
					rs1("execorder") = execorder
					IF timeproject <> "" Then
						rs1("timeproject") = timeproject
					end if
					IF budgetmoney <> "" Then
						rs1("budgetmoney") = budgetmoney
					else
						rs1("budgetmoney") = 0
					end if
					rs1("executors") = executors
					rs1("actors") = actors
					rs1("intro") = intro
					rs1("mustat") = mustat
					rs1("allOKModel") = allOKModel
					rs1("commFields") = commFields
					rs1("linkFields") = linkFields
					rs1("zdyFields") = zdyFields
					rs1("splinktype") = splinktype
					rs1.update
					PMID=rs1("id")
				end if
				rs1.Close
				Set rs1 = Nothing
				IF nextid <> "" Then
					ntsIU = Split(nextid, ",")
					For s = 0 To UBound(ntsIU)
						Set rs2 = server.CreateObject("adodb.recordset")
						sql2 = "select * from ProcNextNodes where nodeid='-320'"
						Set rs2 = server.CreateObject("adodb.recordset")
						rs2.Open sql2, cn, 1, 3
						If Not rs2.EOF Then
						else
							rs2.addnew
							rs2("nodeid") = PMID
							rs2("nextid") = ntsIU(s)
							rs2.update
						end if
						rs2.Close
						Set rs2 = Nothing
					next
				end if
			end if
		next
		cn.execute("update b set b.nextid=id from ProcNextNodes b inner join ProcModelsNodes a on b.nextid=a.sortid and a.chancePMid='"&pmord&"'")
		f.title = "项目模板流程图预览"
		f.addremark "<img src='../skin/default/images/lx.gif' style='width:28px;height:14px'>", "表示审核阶段"
		f.addremark "<input type='button' style='background-color:white;border:1px solid #888;overflow:hidden;width:24px;height:13px'>", "表示执行阶段"
		f.addremark "<img src='../skin/default/images/lx.gif' style='width:28px;height:14px'>", "表示审核阶段"
		f.addremark "<span style='color:#000'>◆</span>", "表示必经阶段"
		f.load "select * from  dbo.erp_chance_proc_models_imgNodes("&pmord&") t "
		cn.rollbacktrans
	end sub
	Response.write "" & vbcrlf & "<script>" & vbcrlf & "      document.body.style.background=""none""; " & vbcrlf & "   document.getElementById(""comm_itembarbg"").style.borderBottom = ""1px solid #acbadc""" & vbcrlf & "</script>"
	
%>
