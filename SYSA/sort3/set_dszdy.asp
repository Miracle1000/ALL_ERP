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
	
	Function MessagePost(msg)
		Select Case msg
		Case "doSave"
		Call doSave()
		Case "doEdit"
		Call doEdit()
		Case "doDel"
		Call doDel()
		Case Else
		Call PageLoad()
		End Select
	end function
	Sub PageLoad()
		Dim strFilePath, strAddInnerHtml
		strAddInnerHtml = "<span style=""margin-right:10px;line-height:30px;""><input type=""button"" value=""添加"" class=""oldbutton"" onclick=""AddSend();""></span>"
'Dim strFilePath, strAddInnerHtml
		strFilePath = "<script type=""text/javascript"" src=""../inc/jquery.js""></script>"
		Response.write(app.DefTopBarHTML("../", strFilePath, "项目对手字段自定义", strAddInnerHtml))
		Response.write "" & vbcrlf & "<script src= ""../Script/s3_set_dszdy.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """  type=""text/javascript""></script>" & vbcrlf & "<style>" & vbcrlf & "#content td{ height:30px;}" & vbcrlf & "</style>" & vbcrlf & "<form action=""?__msgId=doEdit"" method=""post"" name=""myform"" onsubmit=""return CheckForm();"">" & vbcrlf & "  <table width=""100%"" id='content' border=""0"" align=""left"" cellpadding=""0"" cellspacing=""0"" style"
		Dim i,oRs,oSQL,iNum,CountNum
		i = 1
		Set oRs = server.CreateObject("adodb.recordset")
		oSQL = "Select id,OrderID,OrderlistID,fieldName,fieldtype,fieldemun,IsDel,IsSearch,IsExport,IsRequired,"
		oSQL = oSQL & "sort1 From sys_billfieldconfig Where OrderID = 1 order by sort1 asc"
		oRs.Open oSQL, cn, 1, 1
		If Not oRs.EOF Then
			iNum = ChkNumEric(oRs.RecordCount)
			CountNum = iNum
			Do While Not oRs.EOF
				Response.write "" & vbcrlf & "                              <!-- #region -->" & vbcrlf & "                                  <tr class=""top2"">" & vbcrlf & "                                       <td height=""27"" colspan=""2"" align=""left"" style='border-right:0px'><a  style='font-size:12px;font-weight:bold;color:#2F496E' target=""_self"" href=""javascript:void(0);"" onClick=""ShowDiv("
'Do While Not oRs.EOF
				Response.write oRs("id")
				Response.write ");return false;"">&nbsp;自定义字段"
				Response.write i
				Response.write "</a></td>" & vbcrlf & "                                     <td height=""27"" colspan=""2"" align=""right"" style='border-left:0px;text-align:right'><input type=""button"" value=""删除"" onclick=""if(confirm('确认删除？')){DelSend("
				'Response.write i
				Response.write oRs("id")
				Response.write ")}"" class=""oldbutton""/>&nbsp;&nbsp;</td>" & vbcrlf & "                               </tr>" & vbcrlf & "                           <tr id=""sz_"
				Response.write oRs("id")
				Response.write "_1"">" & vbcrlf & "                                       <td width=""10%"" height=""27"" align=""right"" style='font-size:12px;color:#2F496E'>字段名称：</td>" & vbcrlf & "                                        <td width=""18%"" height=""27"" align=""left"">&nbsp;&nbsp;<input name=""fieldName_"
				Response.write oRs("id")
				'Response.write oRs("id")
				Response.write """ id=""fieldName_"
				Response.write oRs("id")
				Response.write """ style='font-size:12px' class='textbox2' type=""text"" value="""
				'Response.write oRs("id")
				Response.write oRs("fieldName")
				Response.write """ size=""15"" maxlength=""100""> <span id=""msg_fieldName_"
				Response.write oRs("id")
				Response.write """ style='color:red'></span></td>" & vbcrlf & "                                   <td width=""10%"" height=""27"" align=""right"" style='font-size:12px;color:#2F496E'>字段样式：</td>" & vbcrlf & "                                        <td width=""62%"" height=""27"" align=""left"">&nbsp;&nbsp;<select name=""fieldtype_"
				Response.write oRs("id")
				'Response.write oRs("id")
				Response.write """ onchange=""dataTypeChange(this.value,"
				Response.write oRs("id")
				Response.write ")"">" & vbcrlf & "                                                <option value=""1"""
				Response.write app.iif(oRs("fieldtype") = 1," selected=""selected""","")
				Response.write ">单行文本</option>" & vbcrlf & "                                            <option value=""2"""
				Response.write app.iif(oRs("fieldtype") = 2," selected=""selected""","")
				Response.write ">多行文本</option>" & vbcrlf & "                                            <option value=""3"""
				Response.write app.iif(oRs("fieldtype") = 3," selected=""selected""","")
				Response.write ">日期</option>" & vbcrlf & "                                                <option value=""4"""
				Response.write app.iif(oRs("fieldtype") = 4," selected=""selected""","")
				Response.write ">数字</option>" & vbcrlf & "                                                <option value=""5"""
				Response.write app.iif(oRs("fieldtype") = 5," selected=""selected""","")
				Response.write ">备注</option>" & vbcrlf & "                                                <option value=""6"""
				Response.write app.iif(oRs("fieldtype") = 6," selected=""selected""","")
				Response.write ">是/否</option>" & vbcrlf & "                                               <option value=""7"""
				Response.write app.iif(oRs("fieldtype") = 7," selected=""selected""","")
				Response.write ">自定义列表</option>" & vbcrlf & "                                    </select></td>" & vbcrlf & "                                  </tr>" & vbcrlf & "                           <tr id=""sz_"
				Response.write oRs("id")
				Response.write "_2"">" & vbcrlf & "                                       <td height=""27"" align=""right"" style='font-size:12px;color:#2F496E'>是否启用：</td>" & vbcrlf & "                                  <td height=""27"" align=""left"">&nbsp;<input type=""radio"" name=""IsDel_"
				Response.write oRs("id")
				'Response.write oRs("id")
				Response.write """ value=""1"""
				Response.write app.iif(oRs("IsDel") = 1," checked=""checked""","")
				Response.write ">" & vbcrlf & "                                       启用" & vbcrlf & "                                    <input type=""radio"" name=""IsDel_"
				Response.write oRs("id")
				Response.write """ value=""0"""
				Response.write app.iif(oRs("IsDel") = 0," checked=""checked""","")
				Response.write ">" & vbcrlf & "                                       不启用</td>" & vbcrlf & "                                   <td height=""27"" align=""right"" style='font-size:12px;color:#2F496E'>排列顺序：</td>" & vbcrlf & "                                  <td height=""27"" align=""left"">&nbsp;&nbsp;<select name=""sort1_"
				'Response.write app.iif(oRs("IsDel") = 0," checked=""checked""","")
				Response.write oRs("id")
				Response.write """>" & vbcrlf & "                                         "
				Dim j,dispType
				For j = 1 To CountNum
					Response.write "" & vbcrlf & "                                              <option"
					Response.write app.iif(Trim(j) = Trim(oRs("sort1"))," selected=""selected""","")
					Response.write ">"
					Response.write j
					Response.write "</option>" & vbcrlf & "                                             "
				next
				Response.write "" & vbcrlf & "                                        </select></td>" & vbcrlf & "                                  </tr>" & vbcrlf & "                           "
				If oRs("fieldtype") = 3 Or oRs("fieldtype") = 5 Or oRs("fieldtype") = 6 Or oRs("fieldtype") = 7 Then
					dispType = " style=""display:none;"""
				end if
				Response.write "" & vbcrlf & "                                <tr id=""sz_"
				Response.write oRs("id")
				Response.write "_3"" style='display:none'>" & vbcrlf & "                                  <td height=""27"" align=""right"">增强功能：</td>" & vbcrlf & "                                       <td height=""27"" colspan=""3"" align=""left""><table border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "                                         <tr>" & vbcrlf & "" & vbcrlf & "                                              <td width=""80"" class=""null"" style='display:none'><input name=""IsSearch_"
				Response.write oRs("id")
				Response.write """ type=""checkbox"" value=""1"""
				Response.write app.iif(oRs("IsSearch") = 1," checked=""checked""","")
				Response.write ">" & vbcrlf & "                                                     检索</td>" & vbcrlf & "                                                 <td width=""80"" class=""null""  style='display:none'><input name=""IsExport_"
				Response.write oRs("id")
				Response.write """ type=""checkbox"" value=""1"""
				Response.write app.iif(oRs("IsExport") = 1," checked=""checked""","")
				Response.write ">" & vbcrlf & "                                                    导出</td>" & vbcrlf & "                                                 <td width=""80"" class=""null"" id=""dispType_"
				Response.write oRs("id")
				Response.write """"
				Response.write dispType
				Response.write "><input id=""IsRequired_"
				Response.write oRs("id")
				Response.write """ type=""checkbox"" value=""1"""
				Response.write app.iif(oRs("IsRequired") = 1," checked=""checked""","")
				Response.write ">" & vbcrlf & "                                                    必填</td>" & vbcrlf & "                                               </tr>" & vbcrlf & "                                     </table></td>" & vbcrlf & "                           </tr>" & vbcrlf & "                           <input type=""hidden"" name=""fieldemun_"
				Response.write oRs("id")
				Response.write """ id=""fieldemun_"
				Response.write oRs("id")
				Response.write """ value=""1000000"
				Response.write oRs("id")
				Response.write """ />" & vbcrlf & "                                <tr id=""sz_"
				Response.write oRs("id")
				Response.write "_4"""
				If oRs("fieldtype") = 7 Then
				else
					Response.write " style=""display:none"""
				end if
				Response.write ">" & vbcrlf & "                                    <td height=""27"" align=""right"">枚举内容：</td>" & vbcrlf & "                                       <td height=""27"" colspan=""3"" align=""left"" style=""padding:5px;""><iframe src=""../sort3/edit_tzzd.asp?CFID=1000000"
				Response.write oRs("id")
				Response.write """ width=""100%"" height=""330"" scrolling=""no"" frameborder=""0"" marginheight=""0"" marginwidth=""0""target=""_self"" ></iframe></td>" & vbcrlf & "                                 </tr>" & vbcrlf & "                         <!-- #endregion -->"
				'Response.write oRs("id")
				i = i + 1
				'Response.write oRs("id")
				oRs.MoveNext
			Loop
		end if
		oRs.Close
		Set oRs = Nothing
		Response.write "" & vbcrlf & "     <tr>" & vbcrlf & "            <td colspan=4 style='border:0px;border-top:1px'>" & vbcrlf & "                        <div class='bottomdiv' style='border-top:0px;text-align:center'>" & vbcrlf & "                                <span style='position:relative;top:6px;'>" & vbcrlf & "                               <input type=""submit"" value="" 保 存 ""  class=""oldbutton""/> &nbsp;" & vbcrlf & "                           <input type=""reset"" value="" 重 填 "" class=""oldbutton"">" & vbcrlf & "                                </span>" & vbcrlf & "                 </div>" & vbcrlf & "          </td>" & vbcrlf & "   </tr>" & vbcrlf & "  </table>" & vbcrlf & "         " & vbcrlf & " <input type='hidden' name='isAdd' id='addtype' value=0>" & vbcrlf & "" & vbcrlf & "</form>" & vbcrlf & ""
		Response.write("</body>") & vbCrLf
		Response.write("</html>") & vbCrLf
	end sub
	Sub doEdit()
		Dim oRs, oSQL, id, fieldName, fieldtype, sort1, IsDel, IsSearch, IsExport, IsRequired, fieldemun
		Dim SQL
		Set oRs = server.CreateObject("adodb.recordset")
		oSQL = "Select * From sys_billfieldconfig Where OrderID = 1 order by id asc "
		Cn.BeginTrans
		oRs.Open oSQL, cn, 1, 1
		If Not oRs.EOF Then
			Do While Not oRs.EOF
				id = oRs("id")
				fieldName = app.GetText("fieldName_"&id&"")
				If (fieldName = "" Or IsNull(fieldName)) Then
					Response.write ("<script type=""text/javascript"">") & vbCrLf
					Response.write ("alert('自定义字段名称不能为空，并且不能有重复!');") & vbCrLf
					Response.write ("history.go(-1);") & vbCrLf
					Response.write ("alert('自定义字段名称不能为空，并且不能有重复!');") & vbCrLf
					Response.write ("</script>") & vbCrLf
					call db_close : Response.end()
				end if
				fieldtype = ChkNumEric(app.GetInt("fieldtype_"&id&""))
				sort1 = ChkNumEric(app.GetInt("sort1_"&id&""))
				IsDel = ChkNumEric(app.GetInt("IsDel_"&id&""))
				IsSearch = ChkNumEric(app.GetInt("IsSearch_"&id&""))
				IsExport = ChkNumEric(app.GetInt("IsExport_"&id&""))
				IsRequired = ChkNumEric(app.GetInt("IsRequired_"&id&""))
				fieldemun = ChkNumEric(app.GetInt("fieldemun_"&id&""))
				on error resume next
				SQL = "Update sys_billfieldconfig Set fieldName = '"&fieldName&"',fieldtype = "&fieldtype&",fieldemun = "&fieldemun&",sort1 = "&sort1&",IsDel = "&IsDel&","
				SQL = SQL & "IsSearch = "&IsSearch&",IsExport = "&IsExport&",IsRequired = "&IsRequired&" Where OrderID = 1 And id = "& id &" "
				cn.Execute(SQL)
				If Err.Number <> 0 Then
					If Err.Number = "-2147217873" Then
'If Err.Number <> 0 Then
						Response.write ("<script type=""text/javascript"">") & vbCrLf
						Response.write ("alert('自定义字段名称不能有重复!');") & vbCrLf
						Response.write ("history.go(-1);") & vbCrLf
						Response.write ("alert('自定义字段名称不能有重复!');") & vbCrLf
						Response.write ("</script>") & vbCrLf
						call db_close : Response.end()
					end if
					Cn.RollbackTrans
					Exit Sub
				end if
				oRs.MoveNext
			Loop
		end if
		Cn.CommitTrans
		oRs.Close
		Set oRs = Nothing
		Response.write ("<script type=""text/javascript"">") & vbCrLf
		if request.form("isAdd") <> "1" then
			Response.write ("alert('保存成功!');") & vbCrLf
		else
			call doSave()
		end if
		Response.write ("window.location.href = 'set_dszdy.asp';") & vbCrLf
		Response.write ("</script>") & vbCrLf
	end sub
	Sub doDel()
		Dim id, typeid
		id = ChkNumEric(app.GetInt("id"))
		If cn.execute("select * from sys_billfieldsdata where fieldid=" & id).eof = False Then
			Response.write "该字段已经被使用，无法被删除。"
			Exit sub
		end if
		Cn.Execute("Delete From sys_billfieldconfig Where id = " & id & " ")
		typeid = ChkNumEric(app.GetInt("typeid"))
		Cn.Execute("Delete From ERP_CustomOptions Where CFID = " & typeid & " ")
		Response.write(1)
	end sub
	Sub doSave()
		Dim CountNum, SQL , sortNum
		CountNum = ChkNumEric(Cn.Execute("Select Max(id) From sys_billfieldconfig ")(0))
		sortNum = ChkNumEric(Cn.Execute("Select count(id)+1 From sys_billfieldconfig ")(0))
		CountNum = ChkNumEric(Cn.Execute("Select Max(id) From sys_billfieldconfig ")(0))
		SQL = "Insert Into sys_billfieldconfig(OrderID,OrderlistID,fieldName,fieldtype,fieldemun,IsDel,IsSearch,IsExport,IsRequired,sort1) "
		SQL = SQL & "Values(1,0,'新自定义字段" & sortNum & "',1,0,1,0,0,0,"&CountNum + 10&")"
		Cn.Execute(SQL)
	end sub
	Function ChkNumEric(ByVal CHECK_ID)
		If CHECK_ID <> "" And IsNumeric(CHECK_ID) Then
			If CHECK_ID < 0 Then CHECK_ID = 0
			If CHECK_ID > 2147483647 Then CHECK_ID = 0
			CHECK_ID = CLng(CHECK_ID)
		else
			CHECK_ID = 0
		end if
		ChkNumEric = CHECK_ID
	end function
	
%>
