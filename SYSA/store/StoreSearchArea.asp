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
		If n = "value" Then  Me.value = v : Exit Property
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
			if not mIsCallback then addHtml "</div>"
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
	
	function MessagePost(msgId)
		select case msgId
		case ""
		call page_load
		end select
	end function
	Sub page_load
		Response.write app.DefheadHTML("../","")
		Response.write "" & vbcrlf & "<body>" & vbcrlf & "        <script language='javascript'>" & vbcrlf & "          function __on_tvw_checkBoxClick(box)" & vbcrlf & "            {" & vbcrlf & "                       if(window.parent.storeListChange)" & vbcrlf & "                       {" & vbcrlf & "                               if(box && box.checked==false) {" & vbcrlf & "                                 document.getElementById(""cktreeack"").checked =false; "& vbcrlf &                   "         }" & vbcrlf &                             "   if(document.getElementById(""cktreeack"").checked == true) "& vbcrlf &                     "      { "& vbcrlf &                                      "  window.parent.storeListChange(null);"& vbcrlf &                 "           } "& vbcrlf &              "                  else "& vbcrlf &                       "    { "& vbcrlf &                           "             window.parent.storeListChange(tvw.getcheckBoxAttrs(""cktree"",""value"",""""));" & vbcrlf & "                                }" & vbcrlf & "                       }" & vbcrlf & "               }" & vbcrlf & "       </script>" & vbcrlf & "       "
		Call showStoreCls(0, nothing)
		Response.write "" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	end sub
	Sub showStoreCls(pid, ByRef pnd)
		Dim tvw, rs, rs2,  i, ii, v, nd, nd2
		If pid = 0 Then
			Response.write "<input type=""checkbox""  id='cktreeack' onClick=""__tvw_checkboxSet('cktree',this.checked);__on_tvw_checkBoxClick()"">全选<div>"
			Set tvw = New treeview
			tvw.id = "cktree"
			tvw.checkbox = True
			tvw.pagesize = 20
			tvw.defexplan = False
			tvw.pagedataemodel = "all"
			Call tvw.addAllNodes(tvw.nodes, "exec erp_selbox_createStoreNode " & Info.User & ",0,0,'',@parentid,@pagesize,@pageindex,0,''", false, 1, 0)
			Response.write tvw.HTML & "</div>"
		end if
	end sub
	
%>
