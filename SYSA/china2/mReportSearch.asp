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
		' Set ZBRuntime = app.Library
		' If ZBRuntime.loadOK Then
		' 	ZBRuntime.getLibrary "ZBIntel2013CheckBitString"
		' 	If ZBRuntime.loadOK then
		' 		if app.isMobile then
		' 			response.clear
		' 			response.CharSet = "utf-8"
		' 			response.clear
		' 			Response.BinaryWrite app.base64.UnicodeToUtf8("系统【服务端】未正常启动，请检查服务器环境是否正常。")
		' 			Response.end
		' 		else
		' 			Response.write "<script>top.window.location.href ='" & app.virpath & "index2.asp?id2=8'</script>"
		' 		end if
		' 		Set app = Nothing
		' 		Set ZBRuntime = Nothing
		' 		Exit Sub
		' 	end if
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
	Function GetReportLinks(n , f, data, col)
		Dim r , rs,sql,i
		Select Case n
		Case "合同跟进"
		Select Case f
		Case "今日新增合同_数量"
		r = "../contract/planall.asp?tj=1&W3=@cells[1]&ret=" & date & "&ret2=" & date & ""
		Case "今日新增合同_金额"
		r = "../contract/planall.asp?tj=1&W3=@cells[1]&ret=" & date & "&ret2=" & date & ""
		case "待回款合同_数量"
		r = "../contract/planall.asp?link=dhk&W3=@cells[1]&ret=@t1&ret2=@t2"
		case "待回款合同_金额"
		r = "../contract/planall.asp?link=dhk&W3=@cells[1]&ret=@t1&ret2=@t2"
		case "待出库合同_数量"
		r = "../contract/planall.asp?tj=1&zt=100&W3=@cells[1]&ret=@t1&ret2=@t2"
		case "待出库合同_金额"
		r = "../contract/planall.asp?tj=1&zt=100&W3=@cells[1]&ret=@t1&ret2=@t2"
		case "待发货合同_数量"
		r = "../contract/planall.asp?tj=1&zt=101&W3=@cells[1]&ret=@t1&ret2=@t2"
		case "待发货合同_金额"
		r = "../contract/planall.asp?tj=1&zt=101&W3=@cells[1]&ret=@t1&ret2=@t2"
		case "即将到期合同_数量"
		r = "../contract/planlist.asp?link=yes&b=5555555&W3=@cells[1]&ret=@t1&ret2=@t2"
		case "即将到期合同_金额"
		r = "../contract/planlist.asp?link=yes&b=5555555&W3=@cells[1]&ret=@t1&ret2=@t2"
		case "待审批合同_数量"
		r = "../contract/planall.asp?link=dsp&SH=5555555&uid=@cells[1]&ret=@t1&ret2=@t2"
		case "待审批合同_金额"
		r = "../contract/planall.asp?link=dsp&SH=5555555&uid=@cells[1]&ret=@t1&ret2=@t2"
		case "所有合同_数量"
		r = "../contract/planall.asp?tj=1&W3=@cells[1]"
		case "所有合同_金额"
		r = "../contract/planall.asp?tj=1&W3=@cells[1]"
		case "审批未通过合同_数量"
		r = "../contract/planall.asp?tj=1&sp=2&W3=@cells[1]&ret=@t1&ret2=@t2"
		case "审批未通过合同_金额"
		r = "../contract/planall.asp?tj=1&sp=2&W3=@cells[1]&ret=@t1&ret2=@t2"
		Case else
		End Select
		Case "项目跟进"
		set rs=server.CreateObject("adodb.recordset")
		sql = "select ord,sort1 from sortjh2 where sort1='" & Replace(Replace(Replace(f + "-", "_数量-",""),"_金额-",""),"'","''") & "'"
'set rs=server.CreateObject("adodb.recordset")
		rs.open sql,cn,1,1
		If rs.eof = False then
			Select Case f
			Case rs("sort1")&"_数量"
			r = "../chance/result.asp?D=@trade&E=@complete1&F="& rs("ord") &"&A1=@complete2&A2=&zdy5=&zdy6=&W3=@cells[2]&B2=xmzt&C2=&ret=@t1&ret2=@t2"
			Case rs("sort1")&"_金额"
			r = "../chance/result.asp?D=@trade&E=@complete1&F="& rs("ord") &"&A1=@complete2&A2=&zdy5=&zdy6=&W3=@cells[2]&B2=xmzt&C2=&ret=@t1&ret2=@t2"
			Case else
			End Select
		end if
		rs.close
		if f = "无阶段项目" then
			r = "../chance/result.asp?D=@trade&E=@complete1&F=0&A1=@complete2&A2=&zdy5=&zdy6=&W3=@cells[2]&B2=xmzt&C2=&ret=@t1&ret2=@t2"
		end if
		Case "供应商分布"
		set rs = server.CreateObject("adodb.recordset")
		sql = "select ord,sort1 from sortonehy s where gate2 = 17 or gate2 = 18"
		rs.open sql,cn,1,1
		for i = 1 to rs.RecordCount*2
			Select Case f
			Case "分类_"&rs("sort1")
			r = "../work2/telhy.asp?w3=@ucells[2]&E="&rs("ord")&"&ret=@t1&ret2=@t2&D=@trade&A2=@area&F1=1&F2=@name&S1=1&S2=@pym&G1=1&G2=@phone&P1=1&P2=@fax&J1=1&J2=@address&T1=1&T2=@intro&K1=1&K2=@zip"
			Case "级别_"&rs("sort1")
			r = "../work2/telhy.asp?w3=@ucells[2]&A3="&rs("ord")&"&ret=@t1&ret2=@t2&D=@trade&A2=@area&F1=1&F2=@name&S1=1&S2=@pym&G1=1&G2=@phone&P1=1&P2=@fax&J1=1&J2=@address&T1=1&T2=@intro&K1=1&K2=@zip"
			Case "分类_无分类"
			r = "../work2/telhy.asp?w3=@ucells[2]&E=-1&ret=@t1&ret2=@t2&D=@trade&A2=@area&F1=1&F2=@name&S1=1&S2=@pym&G1=1&G2=@phone&P1=1&P2=@fax&J1=1&J2=@address&T1=1&T2=@intro&K1=1&K2=@zip"
'Case "分类_无分类"
			Case "级别_无级别"
			r = "../work2/telhy.asp?w3=@ucells[2]&A3=-1&ret=@t1&ret2=@t2&D=@trade&A2=@area&F1=1&F2=@name&S1=1&S2=@pym&G1=1&G2=@phone&P1=1&P2=@fax&J1=1&J2=@address&T1=1&T2=@intro&K1=1&K2=@zip"
'Case "级别_无级别"
			Case "所有供应商"
			r = "../work2/telhy.asp?w3=@ucells[2]&ret=@t1&ret2=@t2&D=@trade&A2=@area&F1=1&F2=@name&S1=1&S2=@pym&G1=1&G2=@phone&P1=1&P2=@fax&J1=1&J2=@address&T1=1&T2=@intro&K1=1&K2=@zip"
			Case else
			End Select
			i = i + 1
'End Select
			rs.movenext
		next
		Case "客户分布"
		set rs = server.CreateObject("adodb.recordset")
		sql = "select distinct s4.sort1,isnull(s5.sort2,'') as sort2,s4.ord as o4,s5.ord as o5 from sort4 s4 left join sort5 s5 on s4.ord = s5.sort1"
		rs.open sql,cn,1,1
		for i = 1 to rs.RecordCount*2
			Select Case Replace(f,"#","")
			Case rs("sort1")& "_" &rs("sort2")
			r="../work/telhy.asp?link=yes&H=21&px=1&W3=@cells[1]&E="&rs("o4")&"&F="&rs("o5")&"&A3=@ly&A1=@jz&zdy5=&A2=@area&D=@trade&F1=1&F2=@tel_name&S1=1&S2=@tel_pym&G1=1&G2=@tel_phone&P1=1&P2=@tel_fax&J1=1&J2=@tel_address&K1=1&K2=@tel_zip&T1=1&T2=@tel_intro&ret=@t1&time1=00&time2=00&ret2=@t2&time3=23&time4=59"
			Case rs("sort1")
			r="../work/telhy.asp?link=yes&H=21&px=1&W3=@cells[1]&E="&rs("o4")&"&F=@khgj&A3=@ly&A1=@jz&zdy5=&A2=@area&D=@trade&F1=1&F2=@tel_name&S1=1&S2=@tel_pym&G1=1&G2=@tel_phone&P1=1&P2=@tel_fax&J1=1&J2=@tel_address&K1=1&K2=@tel_zip&T1=1&T2=@tel_intro&ret=@t1&time1=00&time2=00&ret2=@t2&time3=23&time4=59"
			Case rs("sort1") & "_合计"
			r="../work/telhy.asp?link=yes&H=21&px=1&W3=@cells[1]&E="&rs("o4")&"&F=@khgj&A3=@ly&A1=@jz&zdy5=&A2=@area&D=@trade&F1=1&F2=@tel_name&S1=1&S2=@tel_pym&G1=1&G2=@tel_phone&P1=1&P2=@tel_fax&J1=1&J2=@tel_address&K1=1&K2=@tel_zip&T1=1&T2=@tel_intro&ret=@t1&time1=00&time2=00&ret2=@t2&time3=23&time4=59"
			Case rs("sort1") & "_无跟进程度"
			r="../work/telhy.asp?link=yes&H=21&px=1&W3=@cells[1]&E="&rs("o4")&"&F=-100001&A3=@ly&A1=@jz&zdy5=&A2=@area&D=@trade&F1=1&F2=@tel_name&S1=1&S2=@tel_pym&G1=1&G2=@tel_phone&P1=1&P2=@tel_fax&J1=1&J2=@tel_address&K1=1&K2=@tel_zip&T1=1&T2=@tel_intro&ret=@t1&time1=00&time2=00&ret2=@t2&time3=23&time4=59"
			Case "无分类"
			r = "../work/telhy.asp?link=yes&fl=no&H=21&px=1&W3=@cells[1]&E=&F=&A3=@ly&A1=@jz&zdy5=&A2=@area&D=@trade&F1=1&F2=@tel_name&S1=1&S2=@tel_pym&G1=1&G2=@tel_phone&P1=1&P2=@tel_fax&J1=1&J2=@tel_address&K1=1&K2=@tel_zip&T1=1&T2=@tel_intro&ret=@t1&time1=00&time2=00&ret2=@t2&time3=23&time4=59"
			Case Else
			End Select
			i = i + 1
'End Select
			rs.movenext
		next
		rs.close
		Case "报价跟进"
		Select Case f
		Case "今日新增报价"
		r = "../../SYSN/view/sales/price/pricelist.ashx?W3=@cells[1]&ret="& date&"&ret2="& date
		Case "待询价"
		r = "../../SYSN/view/sales/price/pricelist.ashx?H=&select5=page_count%3D10&46=b%3D7&b=1&W3=@cells[1]&E=&F=&A2=@area&D=@trade&"& groupurl(data, "B1", "@tel_name,@tel_pym,@tel_intro","mc,pym,bz", "C1") &"B2=bjzt&C2=&ret=@t1&ret2=@t2"
		Case "询价中"
		r = "../../SYSN/view/sales/price/pricelist.ashx?H=&select5=page_count%3D10&46=b%3D7&b=8&W3=@cells[1]&E=&F=&A2=@area&D=@trade&"& groupurl(data, "B1", "@tel_name,@tel_pym,@tel_intro","mc,pym,bz", "C1") &"B2=bjzt&C2=&ret=@t1&ret2=@t2"
		Case "待正式报价"
		r = "../../SYSN/view/sales/price/pricelist.ashx?H=&select5=page_count%3D10&46=b%3D7&b=2&W3=@cells[1]&E=&F=&A2=@area&D=@trade&"& groupurl(data, "B1", "@tel_name,@tel_pym,@tel_intro","mc,pym,bz", "C1") &"B2=bjzt&C2=&ret=@t1&ret2=@t2"
		Case "待审批_数量"
		r = "../../SYSN/view/sales/price/pricelist.ashx?H=&select5=page_count%3D10&46=b%3D7&b=3&fromTJ=1&W3=@cells[1]&E=&F=&A2=@area&D=@trade&"& groupurl(data, "B1", "@tel_name,@tel_pym,@tel_intro","mc,pym,bz", "C1") &"B2=bjzt&C2=&ret=@t1&ret2=@t2"
		Case "待审批_金额"
		r = "../../SYSN/view/sales/price/pricelist.ashx?H=&select5=page_count%3D10&46=b%3D7&b=3&fromTJ=1&W3=@cells[1]&E=&F=&A2=@area&D=@trade&"& groupurl(data, "B1", "@tel_name,@tel_pym,@tel_intro","mc,pym,bz", "C1") &"B2=bjzt&C2=&ret=@t1&ret2=@t2"
		Case "审批已通过_数量"
		r = "../../SYSN/view/sales/price/pricelist.ashx?H=&select5=page_count%3D10&46=b%3D7&b=0&W3=@cells[1]&E=&F=&A2=@area&D=@trade&"& groupurl(data, "B1", "@tel_name,@tel_pym,@tel_intro","mc,pym,bz", "C1") &"B2=bjzt&C2=&ret=@t1&ret2=@t2"
		Case "审批已通过_金额"
		r = "../../SYSN/view/sales/price/pricelist.ashx?H=&select5=page_count%3D10&46=b%3D7&b=0&W3=@cells[1]&E=&F=&A2=@area&D=@trade&"& groupurl(data, "B1", "@tel_name,@tel_pym,@tel_intro","mc,pym,bz", "C1") &"B2=bjzt&C2=&ret=@t1&ret2=@t2"
		Case "审批未通过_数量"
		r = "../../SYSN/view/sales/price/pricelist.ashx?H=&select5=page_count%3D10&46=b%3D7&b=-1&W3=@cells[1]&E=&F=&A2=@area&D=@trade&"& groupurl(data, "B1", "@tel_name,@tel_pym,@tel_intro","mc,pym,bz", "C1") &"B2=bjzt&C2=&ret=@t1&ret2=@t2"
'Case "审批未通过_数量"
		Case "审批未通过_金额"
		r = "../../SYSN/view/sales/price/pricelist.ashx?H=&select5=page_count%3D10&46=b%3D7&b=-1&W3=@cells[1]&E=&F=&A2=@area&D=@trade&"& groupurl(data, "B1", "@tel_name,@tel_pym,@tel_intro","mc,pym,bz", "C1") &"B2=bjzt&C2=&ret=@t1&ret2=@t2"
'Case "审批未通过_金额"
		Case "成功报价_数量"
		r = "../../SYSN/view/sales/price/pricelist.ashx?H=&select5=page_count%3D10&46=b%3D7&b=4&W3=@cells[1]&E=&F=&A2=@area&D=@trade&"& groupurl(data, "B1", "@tel_name,@tel_pym,@tel_intro","mc,pym,bz", "C1") &"B2=bjzt&C2=&ret=@t1&ret2=@t2"
		Case "成功报价_金额"
		r = "../../SYSN/view/sales/price/pricelist.ashx?H=&select5=page_count%3D10&46=b%3D7&b=4&W3=@cells[1]&E=&F=&A2=@area&D=@trade&"& groupurl(data, "B1", "@tel_name,@tel_pym,@tel_intro","mc,pym,bz", "C1") &"B2=bjzt&C2=&ret=@t1&ret2=@t2"
		Case "未成功报价_数量"
		r = "../../SYSN/view/sales/price/pricelist.ashx?H=&select5=page_count%3D10&46=b%3D7&b=5&W3=@cells[1]&E=&F=&A2=@area&D=@trade&"& groupurl(data, "B1", "@tel_name,@tel_pym,@tel_intro","mc,pym,bz", "C1") &"B2=bjzt&C2=&ret=@t1&ret2=@t2"
		Case "未成功报价_金额"
		r = "../../SYSN/view/sales/price/pricelist.ashx?H=&select5=page_count%3D10&46=b%3D7&b=5&W3=@cells[1]&E=&F=&A2=@area&D=@trade&"& groupurl(data, "B1", "@tel_name,@tel_pym,@tel_intro","mc,pym,bz", "C1") &"B2=bjzt&C2=&ret=@t1&ret2=@t2"
		Case else
		End Select
		Case "销售业绩每月对比"
		Select Case f
		Case "销售额业绩对比_今日成果"
		r="../contract/planall.asp?tj=1&W3=@cells[1]&F=@sort&E=@complete1&A2=@area&D=@trade&zdy5=@zdy5&zdy6=@zdy6&F1=1&F2=@name&G1=1&G2=@title&P1=1&P2=@htid&I1=1&I2=@intro&zdy1_1=1&zdy1_2=@zdy1&zdy2_1=1&zdy2_2=@zdy2&zdy3_1=1&zdy3_2=@zdy3&zdy4_1=1&zdy4_2=@zdy4&ret="& date &"&ret2="& date &""
		Case "销售额业绩对比_本月总计"
		r = "../contract/planall.asp?tj=1&W3=@cells[1]&F=@sort&E=@complete1&A2=@area&D=@trade&zdy5=@zdy5&zdy6=@zdy6&F1=1&F2=@name&G1=1&G2=@title&P1=1&P2=@htid&I1=1&I2=@intro&zdy1_1=1&zdy1_2=@zdy1&zdy2_1=1&zdy2_2=@zdy2&zdy3_1=1&zdy3_2=@zdy3&zdy4_1=1&zdy4_2=@zdy4&ret=@t1&ret2=@t2"
		Case "销售额业绩对比_上月同期"
		r = "../contract/planall.asp?tj=1&W3=@cells[1]&F=@sort&E=@complete1&A2=@area&D=@trade&zdy5=@zdy5&zdy6=@zdy6&F1=1&F2=@name&G1=1&G2=@title&P1=1&P2=@htid&I1=1&I2=@intro&zdy1_1=1&zdy1_2=@zdy1&zdy2_1=1&zdy2_2=@zdy2&zdy3_1=1&zdy3_2=@zdy3&zdy4_1=1&zdy4_2=@zdy4&ret=@t3&ret2=@t4"
		Case "销售额业绩对比_同期应完成"
		Case "销售额业绩对比_同期比较"
		r = "code:app.iif(@value < 0, ""<span style='color:green'>↓</span>""&replace(""@value"",""-"","""")&"""",app.iif(@value=0,""@value"",""<span style='color:red'>↑</span>""+@value))"
'Case "销售额业绩对比_同期比较"
		Case "回款额业绩对比_同期比较"
		r = "code:app.iif(@value < 0, ""<span style='color:green'>↓</span>""&replace(""@value"",""-"","""")&"""",app.iif(@value=0,""@value"",""<span style='color:red'>↑</span>""+@value))"
'Case "回款额业绩对比_同期比较"
		Case "回款额业绩对比_今日成果"
		r = "../money/planall2.asp?link=yes&W3=@cells[1]&com=@complete1&sort=@sort&area=@area&D=@trade&skfs=@pay&contractname=@title&htbh=@htid&intro=@intro&zdy1=@zdy1&zdy2=@zdy2&zdy3=@zdy3&zdy4=@zdy4&zdy5=@zdy5&zdy6=@zdy6&khmc=@name&khpym=@pym&khbh=@khid&khremark=@khremark&hkzt=3&paydate1="&date&"&paydate2="&date
		Case "回款额业绩对比_本月总计"
		r = "../money/planall2.asp?link=yes&W3=@cells[1]&com=@complete1&sort=@sort&area=@area&D=@trade&skfs=@pay&contractname=@title&htbh=@htid&intro=@intro&zdy1=@zdy1&zdy2=@zdy2&zdy3=@zdy3&zdy4=@zdy4&zdy5=@zdy5&zdy6=@zdy6&khmc=@name&khpym=@pym&khbh=@khid&khremark=@khremark&hkzt=3&paydate1=@t1&paydate2=@t2"
		Case "回款额业绩对比_上月同期"
		r = "../money/planall2.asp?link=yes&W3=@cells[1]&com=@complete1&sort=@sort&area=@area&D=@trade&skfs=@pay&contractname=@title&htbh=@htid&intro=@intro&zdy1=@zdy1&zdy2=@zdy2&zdy3=@zdy3&zdy4=@zdy4&zdy5=@zdy5&zdy6=@zdy6&khmc=@name&khpym=@pym&khbh=@khid&khremark=@khremark&hkzt=3&paydate1=@t3&paydate2=@t4"
		Case "回款额业绩对比_同期应完成"
'r = "../money/planall2.asp?link=yes&W3=@cells[1]&com=@complete1&sort=@sort&area=@area&D=@trade&skfs=@pay&contractname=@title&htbh=@htid&intro=@intro&zdy1=@zdy1&zdy2=@zdy2&zdy3=@zdy3&zdy4=@zdy4&zdy5=@zdy5&zdy6=@zdy6&khmc=@name&khpym=@pym&khbh=@khid&khremark=@khremark&hkzt=3&paydate1=@t1&paydate2=@t2"
		Case else
		End Select
		Case "仓库操作导航"
		Select Case f
		Case "待合并预购"
		if app.power.existsModel(14000) = false then
			col.display = "none"
		else
			r = "../../SYSN/view/store/yugou/Yugoulist.ashx?link=yes&uid=@cells[1]&zt1=02&select5=page_count%3D10&ret=@t1&ret2=@t2"
		end if
		Case "采购审批"
		if app.power.existsModel(15000) = false then
			col.display = "none"
		else
			r = "../../SYSN/view/store/caigou/caigoulist.ashx?ApproveStatus=2&Cateid=@cells[1]&sort=@sort_cg&ret=@t1&ret2=@t2"
		end if
		Case "采购到货提醒"
		if app.power.existsModel(15000) = false then
			col.display = "none"
		else
			r = "../../SYSN/view/store/caigou/caigoulist.ashx?remind=9"
		end if
		Case "待申请入库"
		if app.power.existsModel(17000) = false and app.power.existsModel(17002) = false then
			col.display = "none"
		else
			r = "../../SYSN/view/store/caigou/caigoulist.ashx?Cateid=@cells[1]&sort=@sort_cg&ret=@t1&ret2=@t2"
		end if
		Case "待入库单"
		if app.power.existsModel(17000) = false and app.power.existsModel(17002) = false then
			col.display = "none"
		else
			r = "../store/planall2.asp?link=yes&select2=page_count%3D10&a=1&uid=@cells[1]&sort1=@sort_rk&ret=@t1&ret2=@t2"
		end if
		Case "待出库单"
		if app.power.existsModel(17000) = false and app.power.existsModel(17003) = false then
			col.display = "none"
		else
			r = "../store/planall3.asp?link=yes&uid=@cells[1]&sort1=@sort_ck&page_count=10&select2=page_count%3D10&ret=@t1&ret2=@t2&D=33&a=1"
		end if
		Case "调拨审批"
		if app.power.existsModel(17000) = false and app.power.existsModel(17004) = false then
			col.display = "none"
		else
			r = "../store/planalldb.asp?link=yes&uid=@cells[1]&select2=page_count%3D10&ret=@t1&ret2=@t2&a=1"
		end if
		Case "待提交发货"
		if app.power.existsModel(17000) = false and app.power.existsModel(17003) = false and app.power.existsModel(17008) = false then
			col.display = "none"
		else
			r = "../store/planall3.asp?link=yes&a=4&uid=@cells[1]&sort1=@sort_ck&px=3&page_count=10&select2=page_count%3D10&ret=@t1&ret2=@t2&D=33"
		end if
		Case "待确认发货"
		if app.power.existsModel(17008) = false then
			col.display = "none"
		else
			r = "../sent/planall.asp?link=sent&a=0&select2=page_count%3D10&ksjs=khmc&ksjs2=&gatetype=1&userid=@cells[1]&F1=1&F2=&G1=1&G2=&P1=1&P2=&zdy1=1&zdy12=&ret=@t1&ret2=@t2"
		end if
		End Select
		Case "库存信息追踪"
		Select Case f
		Case "期初库存"
		r = "../tongji/hzkc3_hz.asp?sort=@cells[2]&sort1=@cells[1]&" &    groupurl(data, "B", "@pro_name,@pro_order1,@pro_type1" , "cpmc,cpbh,cpxh" , "C") & "ret=@t1&ret2=@t2"
		Case "入库数量"
		r = "../tongji/hzkc3_hz.asp?sort=@cells[2]&sort1=@cells[1]&"       &      groupurl(data, "B", "@pro_name,@pro_order1,@pro_type1" , "cpmc,cpbh,cpxh" , "C") & "ret=@t1&ret2=@t2"
		Case "出库数量"
		r = "../tongji/hzkc3_hz.asp?sort=@cells[2]&sort1=@cells[1]&"       &      groupurl(data, "B", "@pro_name,@pro_order1,@pro_type1" , "cpmc,cpbh,cpxh" , "C") & "ret=@t1&ret2=@t2"
		Case "期末库存"
		r = "../tongji/hzkc3_hz.asp?sort=@cells[2]&sort1=@cells[1]&"       &      groupurl(data, "B", "@pro_name,@pro_order1,@pro_type1" , "cpmc,cpbh,cpxh" , "C") & "ret=@t1&ret2=@t2"
		Case "期初成本"
		r = "../tongji/hzkc3_hz.asp?sort=@cells[2]&sort1=@cells[1]&"       &      groupurl(data, "B", "@pro_name,@pro_order1,@pro_type1" , "cpmc,cpbh,cpxh" , "C") & "ret=@t1&ret2=@t2"
		Case "入库成本"
		r = "../tongji/hzkc3_hz.asp?sort=@cells[2]&sort1=@cells[1]&"       &      groupurl(data, "B", "@pro_name,@pro_order1,@pro_type1" , "cpmc,cpbh,cpxh" , "C") & "ret=@t1&ret2=@t2"
		Case "出库成本"
		r = "../tongji/hzkc3_hz.asp?sort=@cells[2]&sort1=@cells[1]&"       &      groupurl(data, "B", "@pro_name,@pro_order1,@pro_type1" , "cpmc,cpbh,cpxh" , "C") & "ret=@t1&ret2=@t2"
		Case "期末成本"
		r = "../tongji/hzkc3_hz.asp?sort=@cells[2]&sort1=@cells[1]&"       &      groupurl(data, "B", "@pro_name,@pro_order1,@pro_type1" , "cpmc,cpbh,cpxh" , "C") & "ret=@t1&ret2=@t2"
		Case "操作日志"
		r = "../tongji/hzkc3_hz.asp?sort=@cells[2]&sort1=@cells[1]&"       &      groupurl(data, "B", "@pro_name,@pro_order1,@pro_type1" , "cpmc,cpbh,cpxh" , "C") & "ret=@t1&ret2=@t2"
		End Select
		Case "产品信息追踪"
		Select Case f
		Case "产品名称"
		Dim qxOpen,qxIntro
		sdk.setup.getpowerattr 21,14,qxOpen, qxIntro
		If qxOpen > 0 Then
			r = "../product/content.asp?ord=@encells[1]&unit=@cells[2]"
		else
			r = ""
		end if
		Case "预定库存"
		r = "../contract/content_yd.asp?ord=@encells[1]&unit=@cells[2]&ret=@t1&ret2=@t2"
		Case "当前库存"
		r = "../../SYSN/view/store/inventory/InventorySummary.ashx?link=yes&ord=@encells[1]&product_ty=@ucells[3]&sflg=1&ck=@ckid&unit=@cells[2]"
		Case "在途库存"
		r = "../caigou/content_zt.asp?ord=@encells[1]&unit=@cells[2]&ret=@t1&ret2=@t2"
		Case "待审批入库"
		r = "../store/planall2.asp?link=yes&a=1&pro_ord=@encells[1]&unit=@cells[2]&ret=@t1&ret2=@t2"
		Case "预计采购"
		r = "../../SYSN/view/store/yugou/Yugoulist.ashx?link=yes&pro_ord=@encells[1]&unit=@cells[2]&ret=@t1&ret2=@t2&zt1=02"
		case "可选供应商"
		r = "@value <input type='image' title='点击查看详情' src='../images/arrow_d.gif' onclick='showSupplierList(""@cells[1]"")'>"
		Case else
		End Select
		Case "现金银行记录"
		Select Case f
		Case "本期收入"
		r = "../bank/list.asp?link=yes&id=@cells[1]&W3=@gate&ret=@t1&ret2=@t2&intro=@sort&bz01=@bz"
		Case "本期支出"
		r = "../bank/list.asp?link=yes&id=@cells[1]&W3=@gate&ret=@t1&ret2=@t2&intro=@sort&bz01=@bz"
		Case "查看明细"
		r = "../bank/list.asp?link=yes&id=@cells[1]&W3=@gate&ret=@t1&ret2=@t2&intro=@sort&bz01=@bz"
		Case else
		End Select
		Case "收支汇总表"
		Select Case f
		Case "应收总额"
		if app.power.existsModel(23000) = false then
			col.display="none"
		else
			r = "../money/planall2.asp?link=yes&khmc=@name_tel&W3=@cells[1]&skfs=@pay&duepaydate1=@t1&duepaydate2=@t2&A=1"
		end if
		Case "实收总额"
		if app.power.existsModel(23000) = false then
			col.display="none"
		else
			r = "../money/planall2.asp?link=yes&khmc=@name_tel&W3=@cells[1]&skfs=@pay&paydate1=@t1&paydate2=@t2&A=3"
		end if
		Case "已开发票"
		if app.power.existsModel(23000) = false then
			col.display="none"
		else
			r = "../money/paybackInvoice_List.asp?link=yes&khmc=@name_tel&W3=@cells[1]&invdate1=@t1&invdate2=@t2&invtype=@tik&A=5"
		end if
		Case "未开发票"
		if app.power.existsModel(23000) = false then
			col.display="none"
		else
			r = "../money/paybackInvoice_List.asp?link=yes&khmc=@name_tel&W3=@cells[1]&ret=@t1&ret2=@t2&invtype=@tik&A=4"
		end if
		Case "应付总额"
		if app.power.existsModel(24000) = false then
			col.display="none"
		else
			r = "../money2/planall2.asp?link=yes&khmc=@name_gys&W3=@cells[1]&skfs=@pay&duepaydate1=@t1&duepaydate2=@t2&A=1"
		end if
		Case "实付总额"
		if app.power.existsModel(24000) = false then
			col.display="none"
		else
			r = "../money2/planall2.asp?link=yes&khmc=@name_gys&W3=@cells[1]&skfs=@pay&paydate1=@t1&paydate2=@t2&A=2"
		end if
		Case "待收发票"
		if app.power.existsModel(24000) = false then
			col.display="none"
		else
			r = "../../sysn/view/finan/payout/payoutinvoice_list.ashx?invoice=0,11&khmc=@name_gys&W3=@cells[1]&duepaydate1=@t1&duepaydate2=@t2&invtype=@tik"
		end if
		Case "已收发票"
		if app.power.existsModel(24000) = false then
			col.display="none"
		else
			r = "../../sysn/view/finan/payout/payoutinvoice_list.ashx?invoice=1&khmc=@name_gys&W3=@cells[1]&duepaydate1=@t1&duepaydate2=@t2&invtype=@tik"
		end if
		Case "销售退款"
		if app.power.existsModel(25000)=false or app.power.existsModel(25001)=false then
			col.display="none"
		else
			r = "../money3/planall2.asp?link=yes&W3=@cells[1]&skfs=@pay&ret=@t1&ret2=@t2&B=khmc&C=@name_tel"
		end if
		Case "采购退款"
		if app.power.existsModel(25000)=false or app.power.existsModel(25002)=false then
			col.display = "none"
		else
			r = "../money4/planall2.asp?link=yes&W3=@cells[1]&skfs=@pay&ret=@t1&ret2=@t2&B=khmc&C=@name_gys"
		end if
		Case "工资支出"
		if  app.power.existsModel(26000)=false then
			col.display="none"
		else
			r = "../wages/planall.asp?origin=home&a=1&W3=@cells[1]&ret=@t1&ret2=@t2"
		end if
		Case "费用支出"
		if  app.power.existsModel(27000)= false then
			col.display="none"
		else
			r = "../pay/paybxdet.asp?typ=1&link=yes&title=@title_bx&f=@sort&rett=@t1&rett2=@t2&W3=@cells[1]"
		end if
		End Select
		Case "费用管理"
		Select Case f
		Case "待报销总额"
		r="../pay/paydet.asp?title=@title_sy&rett=@t1&rett2=@t2&W3=@cells[1]&bx=0&f=@sort"
		Case "报销中总额"
		r = "../pay/paybxdet.asp?title=@title_bx&rett=@t1&rett2=@t2&W3=@cells[1]&typ=10&f=@sort"
		Case "已报销总额"
		r = "../pay/paybxdet.asp?title=@title_bx&rett=@t1&rett2=@t2&W3=@cells[1]&typ=1&f=@sort"
		Case "待借款总额"
		r = "../pay/jklist.asp?title=@title_jk&ret=@t1&ret2=@t2&typ=5&W3=@cells[1]"
		Case "已借款总额"
		r = "../pay/jklist.asp?title=@title_jk&rett=@t1&rett2=@t2&typ=1&W3=@cells[1]"
		Case "待返还总额"
		r = "../pay/fhlist.asp?title=@title_fh&rett=@t1&rett2=@t2&typ=711&W3=@cells[1]"
		Case "已返还总额"
		r = "../pay/fhlist.asp?title=@title_fh&rett=@t1&rett2=@t2&typ=3&listbz=&W3=@cells[1]"
		Case else
		End Select
		Case "待办事务"
		Select Case f
		Case "待完成日程"
		r = "../plan/result.asp?C=1&D=@intro_day&ret=@t1&ret2=@t2&W3=@cells[1]"
		Case "已完成日程"
		r = "../plan/result.asp?C=2&D=@intro_day&ret=@t1&ret2=@t2&W3=@cells[1]"
		Case "延误日程_本时间段"
		r = "../plan/result.asp?C=3&D=@intro_day&ret=@t1&ret2=@t2&W3=@cells[1]"
		Case "延误日程_所有"
		r = "../plan/result.asp?C=3&D=@intro_day&W3=@cells[1]"
		Case "周报_计划"
		r = "../plan/reportlist.asp?reportType=1&ret=@tweek1&ret2=@tweek2&"& groupurl2(data,"intro1","@intro_jh_wk,@intro_zj_wk") & "W3=@cells[1]"
		Case "周报_总结"
		r = "../plan/reportlist.asp?reportType=1&ret=@tweek1&ret2=@tweek2&"& groupurl2(data,"intro1","@intro_jh_wk,@intro_zj_wk") & "W3=@cells[1]"
		Case "月报_计划"
		r = "../plan/reportlist.asp?reportType=2&ret=@tmonth1&ret2=@tmonth2&"& groupurl2(data,"intro2","@intro_jh_month,@intro_zj_month") & "W3=@cells[1]"
		Case "月报_总结"
		r = "../plan/reportlist.asp?reportType=2&ret=@tmonth1&ret2=@tmonth2&"& groupurl2(data,"intro2","@intro_jh_month,@intro_zj_month") & "W3=@cells[1]"
		Case "年报_计划"
		r = "../plan/reportlist.asp?reportType=3&ret=@tyear1&ret2=@tyear2&"& groupurl2(data,"intro3","@intro_jh_year,@intro_zj_year") & "W3=@cells[1]"
		Case "年报_总结"
		r = "../plan/reportlist.asp?reportType=3&ret=@tyear1&ret2=@tyear2&"& groupurl2(data,"intro3","@intro_jh_year,@intro_zj_year") & "W3=@cells[1]"
		End Select
		Case "售后跟进"
		Select Case f
		Case "待处理"
		r = "../service/event.asp?link=dcl&H=2&ret=&ret2=&way=@way1&great=@great1&" & groupurl(data, "B", "@title,@title,@intro2" , "shzt,shnr,clyj", "C") & "userid=@cells[1]&sort=@sort1"
		Case "处理中"
		r = "../service/event.asp?link=yes&way=@way1&great=@great1&E=0&" & groupurl(data, "B", "@title,@title,@intro2" , "shzt,shnr,clyj", "C") & "userid=@cells[1]&sort=@sort1"
		Case "处理完毕"
		r = "../service/event.asp?link=yes&way=@way1&great=@great1&E=1&" & groupurl(data, "B", "@title,@title,@intro2" , "shzt,shnr,clyj", "C") & "userid=@cells[1]&sort=@sort1"
		Case "新增"
		r = "../service/event.asp?link=yes&ret=@t1&ret2=@t2&way=@way1&great=@great1&" & groupurl(data, "B", "@title,@title,@intro2" , "shzt,shnr,clyj", "C") & "userid=@cells[1]&sort=@sort1"
		Case "经手"
		r = "../service/event.asp?link=js&ret=@t1&ret2=@t2&way=@way1&great=@great1&" & groupurl(data, "B", "@title,@title,@intro2" , "shzt,shnr,clyj", "C") & "userid=@cells[1]&sort=@sort1"
		End Select
		Case "客户跟进每月对比"
		Select Case f
		Case "洽谈进展数对比_今日成果"
		r = "../work/genjin.asp?link=yes&W3=@cells[1]&area=@area&ly=@ly&trade=@trade&jz=@jz&"&groupurl(data, "B", "@tel_name,@tel_pym,@tel_phone,@product,@zdy1,@zdy2,@zdy3,@zdy4,@tel_fax,@tel_address,@tel_intro,@tel_zip" , "name,pym,phone,product,zdy1,zdy2,zdy3,zdy4,fax,address,intro,zip", "C") & "ret="& date &"&ret2="& date &"&time1=0"
		Case "跟进客户数对比_今日成果"
		r="../work/telsearch.asp?link=qtjz&uid=@cells[1]&A2=@area&A3=@ly&D=@trade&A1=@jz&F1=1&F2=@tel_name&S1=1&S2=@tel_pym&G1=1&G2=@tel_phone&zdy1_1=1&zdy1_2=@zdy1&zdy2_1=1&zdy2_2=@zdy2&zdy3_1=1&zdy3_2=@zdy3&zdy4_1=1&zdy4_2=@zdy4&P1=1&P2=@tel_fax&J1=1&J2=@tel_address&T1=1&T2=@tel_intro&K1=1&K2=@tel_zip&product=@product&ret="& date &"&time1=00&time2=00&ret2="& date &"&time3=23&time4=59"
		Case "洽谈进展数对比_本月总计"
		r = "../work/genjin.asp?link=yes&W3=@cells[1]&area=@area&ly=@ly&trade=@trade&jz=@jz&"&groupurl(data, "B", "@tel_name,@tel_pym,@tel_phone,@product,@zdy1,@zdy2,@zdy3,@zdy4,@tel_fax,@tel_address,@tel_intro,@tel_zip" , "name,pym,phone,product,zdy1,zdy2,zdy3,zdy4,fax,address,intro,zip", "C") & "ret=@t1&ret2=@t2&time1=0"
		Case "跟进客户数对比_本月总计"
		r="../work/telsearch.asp?link=qtjz&uid=@cells[1]&A2=@area&A3=@ly&D=@trade&A1=@jz&F1=1&F2=@tel_name&S1=1&S2=@tel_pym&G1=1&G2=@tel_phone&zdy1_1=1&zdy1_2=@zdy1&zdy2_1=1&zdy2_2=@zdy2&zdy3_1=1&zdy3_2=@zdy3&zdy4_1=1&zdy4_2=@zdy4&P1=1&P2=@tel_fax&J1=1&J2=@tel_address&T1=1&T2=@tel_intro&K1=1&K2=@tel_zip&product=@product&ret=@t1&ret2=@t2&time3=23&time4=59"
		Case "洽谈进展数对比_同期比较"
		r = "code:app.iif(@value < 0, ""<span style='color:green'>↓</span>""&replace(""@value"",""-"","""")&"""",app.iif(@value=0,""@value"",""<span style='color:red'>↑</span>""+@value))"
'Case "洽谈进展数对比_同期比较"
		Case "跟进客户数对比_同期比较"
		r = "code:app.iif(@value < 0, ""<span style='color:green'>↓</span>""&replace(""@value"",""-"","""")&"""",app.iif(@value=0,""@value"",""<span style='color:red'>↑</span>""+@value))"
'Case "跟进客户数对比_同期比较"
		End Select
		Case else
		End select
		GetReportLinks = r
	end function
	function groupurl(datavar, guname, gnames, gutypes , guvalue)
		dim s ,i
		s = split(gnames,",")
		for i = 0 to ubound(s)
			if instr(datavar,"[" & s(i) & "]") > 0 then
				groupurl = guname & "=" & split(gutypes,",")(i) & "&" & guvalue & "=" & s(i) & "&"
				exit function
			end if
		next
	end function
	function groupurl2(datavar,guname,gnames)
		dim s,i
		s = split(gnames,",")
		for i = 0 to ubound(s)
			if instr(datavar,"["& s(i) & "]") > 0 then
				groupurl2 = guname & "=" & split(gnames,",")(i) & "&"
			end if
		next
	end function
	function getRightCardUrl(title, fw)
		dim rs1,sql1,open_1_1,intro_1_1,sql9,sid,rs9
		sid="1"
		If title = "最新客户" Then
			set rs1=server.CreateObject("adodb.recordset")
			sql1="select qx_open,qx_intro from power  where ord=" & info.user & " and sort1=1 and sort2=1"
			rs1.open sql1,cn,1,1
			if rs1.eof then
				open_1_1=0
				intro_1_1=0
			else
				open_1_1=rs1("qx_open")
				intro_1_1=rs1("qx_intro")
			end if
			rs1.close
			set rs1=Nothing
		end if
		select case title
		case "最新客户" : getRightCardurl = "../work/telhy.asp?ktype=1&stid="& app.iif(fw=0,"",app.iif(open_1_1=1 Or open_1_1=3,1,3))
		case "合同到期" : getRightCardurl = "../contract/planlist.asp?sp=3&b=cylm&newstate=1"
		case "最新询价" : getRightCardurl = "../xunjia/event.asp?b=7&newstate=1"
		case "采购到货" : getRightCardurl = "../caigou/planlist.asp?b=cylm&newstate=1"
		case "最新采购" : getRightCardurl = "../caigou/planall.asp?newstate=1"
		case "应付账款" : getRightCardurl = "../money2/planall2.asp?newstate=1"
		case "应收账款" : getRightCardurl = "../money/planall2.asp?newstate=1"
		case "报销审批" : getRightCardurl = "../pay/paybx.asp?e=" & info.user
		case "借款审批" : getRightCardurl = "../pay/jklist.asp?sid=1&newstate=1&typ=" & info.user
		case "返还审批" : getRightCardurl = "../pay/fhlist.asp?newstate=1"
		case "知识库" : getRightCardurl = "../learn/edit.asp?newstate=1&sort=0&s=0"
		case "最新跟进" : getRightCardurl = "../work/genjin.asp?newstate=1"
		case "最新报价" : getRightCardurl = "../../SYSN/view/sales/price/pricelist.ashx?newstate=1"
		case "最新预购" : getRightCardurl = "../../SYSN/view/store/yugou/Yugoulist.ashx?newstate=1"
		case "最新项目" : getRightCardurl = "../chance/result.asp?newstate=1"
		case "最新合同" : getRightCardurl = "../contract/planall.asp?newstate=1" & app.iif(fw=0,"","&w3=" & Info.user)
		case "最新售后" : getRightCardurl = "../service/event.asp?newstate=1"
		case "待发货" : getRightCardurl = "../sent/planall.asp?a=0&newstate=1"
		case "库存预警" : getRightCardurl = "../store/aleat.asp"
		case "入库审批" : getRightCardurl = "../store/planall2.asp?newstate=1"
		case "出库审批" : getRightCardurl = "../store/planall3.asp?newstate=1"
		case "费用申请审批" : getRightCardurl = "../pay/paysq.asp?newstate=1&T=5555555"
		case "公司公告" : getRightCardurl = "../learntz/edit.asp?newstate=1"
		case "工作互动" : getRightCardurl = "../learnhd/edit.asp?A=cylm&newstate=1"
		case "最新交流" : getRightCardurl = "../learnhd/edit.asp?A=9999999&newstate=1"
		case "日程提醒" : getRightCardurl = "../plan/option.asp?newstate=1&s=0"
		case "个性网址" : getRightCardurl = "../http/http2.asp"
		case "备忘录" : getRightCardurl = "../notebook/plan.asp"
		case "用品领用审批" : getRightCardurl = "../yp/outlist.asp?newstate=1"
		case "用品返还审批" : getRightCardurl = "../yp/returnlist.asp?newstate=1"
		case "用品库存预警" : getRightCardurl = "../tongji/yptong2.asp?newstate=1"
		case "车辆申请审批" : getRightCardurl = "../car/List_carUse.asp?newstate=1"
		case "车辆保险提醒" : getRightCardurl = "../car/List_insureT.asp?newstate=1"
		case "员工合同到期" :
		If app.power.existsModel(39000) Then
			getRightCardurl = "../hrm/personlist.asp?newstate=1"
		else
			getRightCardurl = "../manager/edit2.asp?qx=3&newstate=1&px=5"
		end if
		case "请假审批" : getRightCardurl = "../manufacture/inc/BillList.asp?orderid=1001&dbf_kqclass=1&cktype=1&newstate=1"
		case "加班审批" : getRightCardurl = "../manufacture/inc/BillList.asp?orderid=1002&dbf_kqclass=2&newstate=1"
		case "外勤审批" : getRightCardurl = "../manufacture/inc/Billlist.asp?orderid=1003&dbf_kqclass=3&newstate=1"
		case "申诉处理" : getRightCardurl = "../manufacture/inc/Billlist.asp?orderid=1015&newstate=1"
		Case "付款审批" : getRightCardurl = "../money2/planall2.asp?status_sp=2,3&link=yes&A=1"
		Case "预收款审批" : getRightCardurl = "../money/planall_yfk.asp?newstate=1"
		Case "待体检档案" : getRightCardurl = "../hrm/hzalttj.asp?newstate=1"
		Case "借阅返还" : getRightCardurl = "../book/List_Lend.asp?newstate=1"
		Case "客户审批" : getRightCardurl = "../work/teltop.asp?H=53"
		Case "产品到期","产品失效期到期" : getRightCardurl = "../../SYSN/view/store/inventory/InventoryDetails.ashx?newstate=1"
		Case "项目共享" : getRightCardurl = "../chance/result.asp?newstate=2"
		Case "项目审批" : getRightCardurl = "../chance/result.asp?spState=1&newstate=3"
		Case "进展领导点评" : getRightCardurl = "../work/dp.asp?newstate=1"
		Case "指派日程完成" : getRightCardurl = "../plan/option.asp?newstate=2&s=4"
		Case "日程领导点评" : getRightCardurl = "../plan/option_dp.asp?newstate=1"
		Case "客户资质到期" : getRightCardurl = "../qualifications/planall.asp?sort=4"
		Case "供应商资质到期" : getRightCardurl = "../qualifications/planall.asp?sort=6"
		Case "养护到期" : getRightCardurl = "../../SYSN/view/store/inventory/InventoryDetails.ashx?newstate=2"
		Case "用人申请审批" : getRightCardurl = "../manufacture/inc/Billlist.asp?orderid=1019&newstate=1"
		case "最新生产计划" :
		set rs9=server.CreateObject("adodb.recordset")
		sql9="select ord,intro,num1,tq1,fw1,gate1 from setjm2 where ord=60 and cateid=" & info.user & " order by gate1 desc"
		rs9.open sql9,cn,1,1
		if not rs9.eof then
			if rs9("fw1")="0" then
				sid="1"
			else
				sid="2"
			end if
		end if
		rs9.close
		set rs9=nothing
		getRightCardurl = "../manufacture/inc/Billlist.asp?orderid=3&newstate="&sid
		case "最新生产订单" :
		set rs9=server.CreateObject("adodb.recordset")
		sql9="select ord,intro,num1,tq1,fw1,gate1 from setjm2 where ord=61 and cateid=" & info.user & " order by gate1 desc"
		rs9.open sql9,cn,1,1
		if not rs9.eof then
			if rs9("fw1")="0" then
				sid="1"
			else
				sid="2"
			end if
		end if
		rs9.close
		set rs9=nothing
		getRightCardurl = "../manufacture/inc/Billlist.asp?orderid=2&newstate="&sid
		case "最新委外加工" :
		set rs9=server.CreateObject("adodb.recordset")
		sql9="select ord,intro,num1,tq1,fw1,gate1 from setjm2 where ord=62 and cateid=" & info.user & " order by gate1 desc"
		rs9.open sql9,cn,1,1
		if not rs9.eof then
			if rs9("fw1")="0" then
				sid="1"
			else
				sid="2"
			end if
		end if
		rs9.close
		set rs9=nothing
		getRightCardurl = "../manufacture/inc/Billlist.asp?orderid=25&newstate="&sid
		case "最新进度汇报" :
		set rs9=server.CreateObject("adodb.recordset")
		sql9="select ord,intro,num1,tq1,fw1,gate1 from setjm2 where ord=63 and cateid=" & info.user & " order by gate1 desc"
		rs9.open sql9,cn,1,1
		if not rs9.eof then
			if rs9("fw1")="0" then
				sid="1"
			else
				sid="2"
			end if
		end if
		rs9.close
		set rs9=nothing
		getRightCardurl = "../manufacture/inc/Billlist.asp?orderid=11&newstate="&sid
		case "最新质量检验" :
		set rs9=server.CreateObject("adodb.recordset")
		sql9="select ord,intro,num1,tq1,fw1,gate1 from setjm2 where ord=64 and cateid=" & info.user & " order by gate1 desc"
		rs9.open sql9,cn,1,1
		if not rs9.eof then
			if rs9("fw1")="0" then
				sid="1"
			else
				sid="2"
			end if
		end if
		rs9.close
		set rs9=nothing
		getRightCardurl = "../manufacture/inc/Billlist.asp?orderid=17&newstate="&sid
		end select
	end function
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
	d_at(23) = "        End sub"
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
	function GetAreas(t,sn)
		Dim ty, fso, r,vbscript
		Select Case t
		Case "product"
		Set sdk = server.createobject(ZBRLibDLLNameSN & ".CommClass")
		vbscript = sdk.vbs("../manager/search_product" &  Application("__saas__company")  & ".asp")
		vbscript = Split(vbscript,"Dim con")(0)
		ExecuteGlobal vbscript
		Dim cnn : Set cnn = cn
		r = GetProductClsHtml(cnn)
		r = Replace(r,"id=""s_s","id=""ps_s_s" & sn)
		r = Replace(r,"id=""d_s","id=""ps_d_s" & sn)
		r = Replace(r,"id=""t_s","id=""ps_t_s" & sn)
		r = Replace(r,"mentById('s_s","mentById('ps_s_s" & sn)
		r = Replace(r,"mentById('d_s","mentById('ps_d_s" & sn)
		r = Replace(r,"mentById('t_s","mentById('ps_t_s" & sn)
		End select
		GetAreas = r
	end function
	function MessagePost(msgId)
		If Info.User = 0 Then Exit function
		select case msgId
		case "showAdvWindow"
		call App_showAdvWindow
		Case ""
		Call PageLoad
		end select
	end function
	Sub PageLoad
		dim unit , rs , v , sql , i, colspan , lvw, ii , w , msql , sty, val , val1
		Dim defrow, htmlv, tmpv, fw , ReportId, e_key, e_t1, e_t2
		Dim datavar
		dim id , aSearchItems , sitem , aryReturn2, attrs , r
		Dim r_name, r_value, r_count
		ReportId = app.getInt("id")
		Dim xxx
		set rs = cn.execute("select sql, colspan, x.id, attrs, defrows , isnull(y.fw1,0) as fw,title  from home_maincards_us x left join setjm2 y on x.setjm = y.ord and y.cateid=" & Info.user & " where x.id='" & ReportId & "' and uid=" & Info.user)
		xxx = "1=select sql, colspan, x.id, attrs, defrows , isnull(y.fw1,0) as fw,title  from home_maincards_us x left join setjm2 y on x.setjm = y.ord and y.cateid=" & Info.user & " where x.id='" & ReportId & "' and uid=" & Info.user
		If rs.eof = True Then
			rs.close
			set rs = cn.execute("select sql, colspan, x.id, attrs, defrows, isnull(y.fw1,0) as fw,title  from home_maincards_def x left join setjm2 y on x.setjm = y.ord and y.cateid=" & Info.user & " where x.id='" & ReportId & "'")
			xxx = "2=select sql, colspan, x.id, attrs, defrows, isnull(y.fw1,0) as fw,title  from home_maincards_def x left join setjm2 y on x.setjm = y.ord and y.cateid=" & Info.user & " where x.id='" & ReportId & "'"
		end if
		if rs.eof = false then
			colspan = rs.fields(1).value
			sql = replace(rs.fields(0).value & "","@uid",info.user,1,-1,1)
'colspan = rs.fields(1).value
			id = rs.fields("id").value
			attrs = rs.fields("attrs").value
			defrow = rs.fields("defrows").value
			fw = rs.fields("fw").value
			e_key = rs.fields("title").value
			If isnumeric(defrow) = False Then defrow = 0
		else
			Exit sub
		end if
		rs.close
		app.addDefaultScript
		Response.write app.DefTopBarHTML("../","<link href='../skin/" & info.skin & "/css/c2_main.css' rel='stylesheet' type='text/css'/>", e_key,"")
		Response.write "<style>html{overflow-x:auto;overflow-y:auto};</style>"
		If instr(1,"待办事务,客户跟进排名",e_key,1)  > 0 Then
			e_t1 = Date
			e_t2 = Date
		else
			e_t1 = year(date) & "-" & month(date) & "-1"
			e_t2 = Date
			e_t2 = CDate(e_t1) + 32
			'e_t2 = Date
			e_t2 = CDate(year(e_t2) & "-" & month(e_t2) & "-1") - 1
			'e_t2 = Date
		end if
		Call cSearchArea(attrs, e_key, id, e_t1, e_t2)
		r_count = 0
		ReDim r_name(0)
		ReDim r_value(0)
		msql = replace(sql,"@uid", info.user)
		ReDim Preserve r_name(r_count + 9)
		msql = replace(sql,"@uid", info.user)
		ReDim Preserve r_value(r_count + 9)
		msql = replace(sql,"@uid", info.user)
		r_name(r_count) = "@t1"
		r_value(r_count) = e_t1
		r_name(r_count + 1) = "@t2"
		r_value(r_count) = e_t1
		r_value(r_count+ 1) = e_t2
		r_value(r_count) = e_t1
		r_name(r_count+2) = "@t3"
		r_value(r_count) = e_t1
		r_value(r_count+2) = dateadd("m",-1,e_t1)
		r_value(r_count) = e_t1
		r_name(r_count+3) = "@t4"
		r_value(r_count) = e_t1
		r_value(r_count+3) = year(dateadd("m",-1,e_t2))&"-"&month(dateadd("m",-1,e_t2))&"-"&day(date)
		r_value(r_count) = e_t1
		r_name(r_count+4) = "@tweek1"
		r_value(r_count) = e_t1
		r_value(r_count+4) = dateadd("d",-weekday(e_t1)+2,e_t1)
		r_value(r_count) = e_t1
		r_name(r_count+5) = "@tweek2"
		r_value(r_count) = e_t1
		r_value(r_count+5) = dateadd("d",7-(DatePart("w",e_t2)-1),e_t2)
		r_value(r_count) = e_t1
		r_name(r_count+6) = "@tmonth1"
		r_value(r_count) = e_t1
		r_value(r_count+6) = dateadd("d",-day(e_t1)+1,e_t1)
		r_value(r_count) = e_t1
		r_name(r_count+7) = "@tmonth2"
		r_value(r_count) = e_t1
		r_value(r_count+7) = dateadd("d",-1,dateadd("m",1,dateadd("d",-day(e_t2)+1,e_t2)))
		r_value(r_count) = e_t1
		r_name(r_count+8) = "@tyear1"
		r_value(r_count) = e_t1
		r_value(r_count+8) = year(e_t1)&"-1-1" 'dateadd("d",-day(e_t1)+1,e_t1)
		r_value(r_count) = e_t1
		r_name(r_count+9) = "@tyear2"
		r_value(r_count) = e_t1
		r_value(r_count+9) = dateadd("d",-1,year(e_t2)+1&"-1-1") 'dateadd("d",-1,dateadd("m",1,dateadd("d",-day(e_t2)+1,e_t2)))
		r_value(r_count) = e_t1
		r_count = r_count + 9
		r_value(r_count) = e_t1
		msql = replace(msql ,"@t1", "'" &  e_t1 & "'")
		msql = replace(msql ,"@t2", "'" &  e_t2 & "'")
		msql = replace(msql,"@t3","'" & dateadd("m",-1,e_t1) & "'")
		msql = replace(msql ,"@t2", "'" &  e_t2 & "'")
		msql = replace(msql,"@t4","'" & year(dateadd("m",-1,e_t2))&"-"&month(dateadd("m",-1,e_t2))&"-"&day(date) & "'")
		msql = replace(msql ,"@t2", "'" &  e_t2 & "'")
		Dim oStr
		For i=0 To ubound(Split(attrs,"|"))
			If ostr<>"" then
				oStr = oStr &","& Split(Split(attrs,"|")(i),";")(2)
			else
				oStr =  Split(Split(attrs,"|")(i),";")(2)
			end if
		next
		attrs = Split(oStr,",")
		If isarray(attrs) then
			For i = 0 To ubound(attrs)
				If instr(attrs(i),"@")=1 and lcase(attrs(i))<>"@t1" and lcase(attrs(i)) <> "@t2" Then
					r_count = r_count + 1
'If instr(attrs(i),"@")=1 and lcase(attrs(i))<>"@t1" and lcase(attrs(i)) <> "@t2" Then
					ReDim Preserve r_name(r_count)
					ReDim Preserve r_value(r_count)
					r_name(r_count) = attrs(i)
					r_value(r_count) = ""
					msql = replace(msql ,attrs(i), "''")
				end if
			next
		end if
		Dim vsql
		vsql = Split(Replace(Replace(msql,",","|")," ","|"),"|")
		r_count = ubound(r_name)
		If isarray(vsql) then
			For i = 0 To ubound(vsql)
				If instr(vsql(i),"@")=1 Then
					msql = replace(msql ,vsql(i), "''")
				end if
			next
		end if
		Dim link, h
		set lvw = new listview
		lvw.border = 0
		lvw.dataattr = e_key & "$$$" &  e_t1 & "$$$" & e_t2
		lvw.pageindex = 1
		lvw.mincellwidth = 50
		lvw.settagData "1"
		If e_key = "客户分布" Then
			Call expFirstNode(lvw)
		end if
		lvw.id = "advlisttable"
		lvw.addlink = ""
		lvw.showfullopen = true
		lvw.checkbox = false
		lvw.indexbox = False
		lvw.currsum = True
		lvw.allsum = true
		lvw.fixedCell = 1
		lvw.zoreColor = "#C2C2C2"
		lvw.Autoresize = False
		lvw.width = "auto"
		lvw.showfullopen = false
		lvw.MulExplan = True
		lvw.noscrollModel = True
		lvw.cbWaitMsg = "正在处理，请稍后..."
		lvw.sql = msql
		If ReportId = 13 Then
			If Not ZBRuntime.MC(17003) Then
				lvw.headers("待出库合同_金额").display = "none"
				lvw.headers("待出库合同_数量").display = "none"
			end if
			If Not ZBRuntime.MC(17008) Then
				lvw.headers("待发货合同_金额").display = "none"
				lvw.headers("待发货合同_数量").display = "none"
			end if
		end if
		Call setListViewCol(lvw, e_key, r_name, r_value)
		Response.write "<div class='ctlcarditem newskin' style='width:auto;float:left;position:relative;overflow:visible' lvwcansize=1>"
		Response.write lvw.html
		Response.write "</div><div class='bottomdiv'></div><script>document.onmousedown = datedlg.autohide;if(app.IeVer==6){document.body.style.overflow='auto'}</script></body></html>"
		Set lvw = nothing
	end sub
	Sub expFirstNode(lvw)
		Dim rs
		Set rs = cn.execute("select top 1 s4.sort1 from sort4 s4 inner join sort5 s5 on s4.ord=s5.sort1 inner join tel c on c.sort1 = s5.ord order by s4.gate1 desc")
		If rs.eof = False Then
			lvw.headExplanName = rs.fields(0).value
		end if
		rs.close
		set rs = nothing
	end sub
	Sub setListViewCol(lvw, k, r_name, r_value)
		Dim i, ii, h,  datavar, link
		For i = 1 To lvw.headers.count
			Set h =  lvw.headers(i)
			If InStr(1,h.dbname,"_id",1) > 0 Then
				h.display = "none"
			end if
			If right(h.dbname,2) = "数量" Then
				h.dbtype = "number"
			ElseIf instr(1,h.dbname,"_金额",1) > 0 Then
				h.dbtype = "money"
			elseIf right(h.dbname,2) = "成本" Then
				h.dbtype = "money"
			elseIf right(h.dbname,2) = "库存" or right(h.dbname,2) = "报价"  or right(h.dbname,2) = "询价" or right(h.dbname,3) = "询价中" Then
				h.dbtype = "number"
			elseIf right(h.dbname,1) = "价" Then
				h.dbtype = "money"
			ElseIf h.dbname="待审批入库" or  h.dbname="预计采购" then
				h.dbtype = "number"
			end if
			Select Case k
			Case "客户跟进每月对比", "销售业绩每月对比"
			If k = "客户跟进每月对比" And instr(h.dbname,"跟进人员") = 0 Then h.dbtype = "number"
			if ZBRuntime.MC(207102) <> True then
				If instr(1,h.dbname,"_本月任务",1) > 0 Or instr(1,h.dbname,"_同期应完成",1) > 0 Or instr(1,h.dbname,"_同期比较",1) > 0 Then h.display = "none"
			end if
			Case "仓库操作导航"
			If instr(h.dbname,"人员") = 0 Then h.dbtype = "number"
			End Select
			If h.formattext = "" then
				link = GetReportLinks(k , h.dbname, datavar , h)
				If Len(link) > 0 Then
					For ii = 0 To ubound(r_name)
						link = Replace(link, r_name(ii),server.urlencode(r_value(ii)))
					next
					if instr(1,link,".asp",1) = 0 And instr(1,link,".ashx",1) = 0 then
						h.formattext = link
					else
						link = Convertlnk(Replace(link,"%2C",",",1,-1,1))
						h.formattext = link
						h.formattext = "<a href='" & link & "' target='_blank' class='rptlink'>@value</a>"
					end if
				end if
			end if
		next
		If lvw.headers.count > 0 then
			If InStr(lvw.headers(2).dbname , "人员")>0 Then
				If InStr(lvw.headers(1).dbname,"_id")>0 Then
					lvw.headers(2).formattext = "<table><tr><td>@value</td><td><img src='../skin/" & Info.skin & "/images/dlgico/gate.gif' onmouseover=""showGateInfo('@cells[1]','@value')"" onmouseout =""out()""></td></tr></table>"
				end if
			end if
			If InStr(lvw.headers(1).dbname , "人员")>0 Then
				If InStr(lvw.headers(2).dbname,"_id")>0 Then
					lvw.headers(1).formattext = "<table><tr><td>@value</td><td><img src='../skin/" & Info.skin & "/images/dlgico/gate.gif' onmouseover=""showGateInfo('@cells[2]','@value')"" onmouseout =""out()""></td></tr></table>"
				end if
			end if
		end if
	end sub
	Sub cSearchArea(attr, title, id, t1, t2)
		Dim fields , i , item , rs, ii, failzdy
		Dim values , iii , labeltxt , rs2
		fields = Split(attr, "|")
		Response.write "<script>if(app.IeVer==6){document.body.onload = function(){document.body.style.overflow='hidden';}}</script><form style='display:inline'><table class='resetBorderColor' style='table-layout:auto;margin:5px;padding:5px;line-height:22px;' cellpadding=5 bordercolor='#e0e4ec' border=1 id='rptpanel_" & id & "'>"
		For i = 0 To ubound(fields)
			item = Split(fields(i) & ";;",";")
			values = Split(item(2) & ",=",",")
			For iii = 0 To ubound(values)
				values(iii) = Split(values(iii),"=")
			next
			labeltxt = item(0)
			failzdy = False
			If InStr(labeltxt,"zdy")=1 And InStr(labeltxt,"*")>1  Then
				on error resume next
				Set rs =  cn.execute("select title from zdy where set_open= 1 and name='" & Replace(labeltxt,"*","' and sort1="))
				If rs.eof = False Then
					labeltxt = rs.fields(0).value
				else
					failzdy = true
				end if
				rs.close
				set rs = nothing
				On Error GoTo 0
			end if
			If failzdy = False Then
				Response.write "<tr>"
				Select Case LCase(item(1))
				Case "checks"
				ii = 0
				Response.write "<td align='right' style='width:100px' uitype='checks' dbname='" & values(0)(0) & "'>" & labeltxt & "：</td><td>"
				Set rs = cn.execute("exec erp_Report_Home_CheckFields '" & title & "', '" & item(0) & "'")
				While Not rs.eof
					ii = ii + 1
'While Not rs.eof
					Response.write "<input style='border:0px;' value='" & rs.fields("v").value & "' type=checkbox name='" & id &  "_cb" & i & "' id='" & id &  "_cb" & i & "_" & ii & "'><label for='" & id &  "_cb" & i & "_" & ii & "'>"  & rs.fields("n").value & "</label>&nbsp;"
					rs.movenext
				wend
				rs.close
				set rs = nothing
				Response.write "</td>"
				Case "select"
				ii = 0
				Response.write "<td align='right' style='width:100px' uitype='text' dbname='" & values(0)(0) & "'>" & labeltxt & "：</td><td>&nbsp;<select>"
				Set rs = cn.execute("exec erp_Report_Home_CheckFields '" & title & "', '" & item(0) & "'")
				While Not rs.eof
					ii = ii + 1
'While Not rs.eof
					Response.write "<option value='" & rs.fields("v").value & "'>"  & rs.fields("n").value & "</option>"
					rs.movenext
				wend
				rs.close
				set rs = nothing
				Response.write "</select></td>"
				Case "areas"
				Response.write "" & vbcrlf & "                                     <td  align='right' valign='top'  uitype='areas' dbname='"
				Response.write values(0)(0)
				Response.write "'>"
				Response.write labeltxt
				Response.write "：</td><td class='areatd'>" & vbcrlf & "                                   "
				execute sdk.vbs("../manager/search_area" &  Application("__saas__company")  & ".asp")
				Response.write "" & vbcrlf & "                                     </td>" & vbcrlf & "                                   "
				Case "groups"
				Set rs = cn.execute("exec erp_Report_Home_groupsFields '" & title & "', '" & item(0) & "'")
				If rs.eof = False then
					Response.write "<td align='right' style='width:100px' uitype='groups'>"
					Response.write "<select>"
					While Not rs.eof
						Response.write "<option value='" & rs.fields("v").value & "'>" & rs.fields("n").value & "</option>"
						rs.movenext
					wend
					Response.write "</select>"
					Response.write "</td><td><input type=text class='text'></td>"
				end if
				rs.close
				set rs = nothing
				Case "gate"
				Response.write "<td align='right'  style='width:100px' valign='top' uitype='gate' dbname='" & values(0)(0) & "'>" & labeltxt & "：</td>"
				Response.write "<td>"
				Call doGateList(1,"")
				Response.write "</td>"
				Case "dates"
				Response.write "<td align='right'  style='width:100px' valign='top' uitype='dates'>" & item(0) & "：</td>"
				Response.write "<td><input type='text' dbname='" & values(0)(0) & "'  value='"& t1 &"' readonly class='text' onfocus='datedlg.show()' style='width:80px;'>&nbsp;至&nbsp;<input type='text' value='"& t2 &"' class='text' onfocus='datedlg.show()' dbname='" & values(1)(0) & "' style='width:80px;' readonly></td>"
				Case "text"
				Response.write "<td align='right'  style='width:100px' valign='top' uitype='text' dbname='" & values(0)(0) & "'>" & labeltxt & "：</td>"
				Response.write "<td><input type='text' class='text' style='width:100px;'></td>"
				Case "productcls"
				Response.write "<td  align='right'  style='width:100px' valign='top'  uitype='productcls' dbname='" & values(0)(0) & "'>" & labeltxt & "：</td><td class='areatd'>"
				Response.write GetAreas("product","")
				Response.write "</td>"
				Case "storecls"
				Response.write "<td align='right'  style='width:100px' valign='top' uitype='storecls' dbname='" & values(0)(0) & "'>" & labeltxt & "：</td>"
				Response.write "<td>"
				Call showStoreCls(0, nothing)
				Response.write "</td>"
				Case "telcls"
				Response.write "<td align='right'  style='width:100px' valign='top' uitype='telcls' dbname='" & values(0)(0) & "' dbname2='" & values(1)(0) & "'>" & labeltxt & "：</td>"
				Response.write "<td><select ><option value=','>不限</option>"
				Set rs = cn.execute("select ord,sort1 from sort4  order by gate1")
				While not rs.eof
					Response.write "<optgroup label='" & rs.fields(1).value & "' style='font-'>"
'While not rs.eof
					Response.write "<option value='" & rs.fields(0).value & ",'>所有" & rs.fields(1).value  & "</option>"
					Set rs2 = cn.execute("select  ord,sort2 from sort5  where sort1=" & rs.fields(0).value)
					While Not rs2.eof
						Response.write "<option value='" & rs.fields(0).value & "," & rs2.fields(0).value & "'>" & rs2.fields(1).value & "</option>"
						rs2.movenext
					wend
					rs2.close
					Response.write "</optgroup>"
					rs.movenext
				wend
				rs.close
				Response.write "</select></td>"
				Case "telcls2"
				Response.write "<td align='right'  style='width:100px' valign='top' uitype='telcls2' dbname='" & values(0)(0) & "' dbname2='" & values(1)(0) & "'>" & labeltxt & "：</td>"
				Response.write "<td>"
				Call showtelClass
				Response.write "</td>"
				Case Else
				Response.write "<td uitype='" & item(1) & "' style='width:100px'>【未定义项:" & item(0) & "】</td><td>" & item(1) & "</td>"
				End Select
				Response.write "</tr>"
			end if
		next
		Response.write "<tr><td></td><td><input type='button' class='oldbutton' onclick='dorptsearch(""" & id & """)' value='检索' id='dosbutton'>&nbsp;&nbsp;&nbsp;&nbsp;<input type='reset' class='oldbutton' onclick='' value='重置'></td></tr>"
		Response.write "</table></form><input type='hidden' id='keyname' value='" & title & "'>"
	end sub
	Sub App_showAdvWindow
		Dim attr, title, id
		app.addDefaultScript
		Response.write app.DefTopBarHTML("../","<link href='../skin/" & info.skin & "/css/c2_main.css' rel='stylesheet' type='text/css'/>", app.gettext("tit") & "高级检索","")
		Response.write "<style>html{overflow-x:auto;overflow-y:auto}" & vbcrlf & "#lvw_tablebg_advlisttable, #lvw_advlisttable{min-width:1200px}</style>"
		attr = app.gettext("attr")
		title = app.gettext("tit")
		id = app.getText("id")
		Call cSearchArea(attr, title, id, request.form("date1_id"), request.form("date2_id"))
		dim l,      backcode
		set l = new listview
		backcode = app.base64.decode(app.gettext("lvw_data"))
		l.settagData "1"
		If title= "项目跟进" then
			l.colbackPost = False
		end if
		execute backcode
		l.Autoresize = False
		l.width = "auto"
		l.id = "advlisttable"
		l.cbWaitMsg = "正在处理，请稍后..."
		l.showfullopen = false
		l.MulExplan = True
		l.noscrollModel = True
		l.dataattr = Split(l.dataattr,"$$$")(0) & "$$$"
		If title= "客户分布" Then
			l.dataattr = "客户分布$$$@t1" & Chr(1) & "date" & Chr(1) & request.form("date1_id")  & Chr(2) & "@t2" & Chr(1) & "date" & Chr(1) & request.form("date2_id")
		end if
		If title= "项目跟进" Then
			l.dataattr = "项目跟进$$$@t1" & Chr(1) & "date" & Chr(1) & request.form("date1_id")  & Chr(2) & "@t2" & Chr(1) & "date" & Chr(1) & request.form("date2_id")
			Call lvw_defCallBack("lvwHeaderExplan", l)
		end if
		If title = "合同跟进" Then
			If Not ZBRuntime.MC(17003) Then
				l.headers("待出库合同_金额").display = "none"
				l.headers("待出库合同_数量").display = "none"
			end if
			If Not ZBRuntime.MC(17008) Then
				l.headers("待发货合同_金额").display = "none"
				l.headers("待发货合同_数量").display = "none"
			end if
		end if
		Response.write "<div class='ctlcarditem newskin' style='width:auto;float:left;position:relative;overflow:visible' lvwcansize=1>"
		Response.write l.html
		Response.write "</div><script>document.onmousedown = datedlg.autohide;if(app.IeVer==6){document.body.style.overflow='auto'}</script></body></html>"
	end sub
	Sub setColDefSet()
		For i = 1 To lvw.headers.count
			Set h =  lvw.headers(i)
			If InStr(1,h.dbname,"_id",1) > 0 Then
				h.display = "none"
			end if
			If right(h.dbname,2) = "数量" Then
				h.dbtype = "number"
			ElseIf instr(1,h.dbname,"_金额",1) > 0 Then
				h.dbtype = "money"
			elseIf right(h.dbname,2) = "成本" Then
				h.dbtype = "money"
			elseIf right(h.dbname,2) = "库存" Then
				h.dbtype = "number"
			elseIf right(h.dbname,1) = "价" Then
				h.dbtype = "money"
			ElseIf h.dbname="待审批入库" or  h.dbname="预计采购" then
				h.dbtype = "number"
			end if
			If e_key = "客户跟进每月对比" And instr(h.dbname,"跟进人员") = 0 Then h.dbtype = "number"
			If e_key = "仓库操作导航" And instr(h.dbname,"人员") = 0 Then h.dbtype = "number"
			link = GetReportLinks(e_key , h.dbname, datavar , h)
			If Len(link) > 0 Then
				For ii = 0 To ubound(r_name)
					link = Replace(link, r_name(ii),server.urlencode(r_value(ii)))
				next
				if instr(1,link,".asp",1) = 0 And instr(1,link,".ashx",1) = 0 then
					h.formattext = link
				else
					link = Convertlnk(Replace(link,"%2C",",",1,-1,1))
					h.formattext = link
					h.formattext = "<a href='" & link & "' target='_blank' class='rptlink'>@value</a>"
				end if
			end if
		next
		If lvw.headers.count > 0 then
			If InStr(lvw.headers(2).dbname , "人员")>0 Then
				If InStr(lvw.headers(1).dbname,"_id")>0 Then
					lvw.headers(2).formattext = "@value&nbsp;<img src='../skin/" & Info.skin & "/images/dlgico/gate.gif' class='gateico' onmouseover=""showGateInfo('@cells[1]','@value')"" onmouseout =""out()"">"
				end if
			end if
			If InStr(lvw.headers(1).dbname , "人员")>0 Then
				If InStr(lvw.headers(2).dbname,"_id")>0 Then
					lvw.headers(1).formattext = "@value&nbsp;<img src='../skin/" & Info.skin & "/images/dlgico/gate.gif' class='gateico' onmouseover=""showGateInfo('@cells[2]','@value')"" onmouseout='out()'>"
				end if
			end if
		end if
	end sub
	sub  lvw_defCallBack(cmd, l)
		dim rs , key , colspan,  id, attrs, defrow, aSearchItems, i, tmpv
		dim sitem, r_count, msql, datavar, h,  aryReturn2, s , eSearch
		Dim r_value, r_name, CostomerArea
		key = app.gettext("key")
		eSearch = app.gettext("eSearch")
		Select Case cmd
		Case "doSearch"
		l.dataattr = Key & "$$$" & Replace(Replace(eSearch,Chr(1),"^0x001^"),Chr(2),"^0x002^")
		Case "lvwHeaderExplan"
		s = Split(Replace(Replace(l.dataattr,"^0x001^",Chr(1)),"^0x002^",Chr(2)),"$$$")
		Key = s(0)
		eSearch = s(1)
		Case else
		Exit sub
		End select
		r_count = 0
		ReDim r_name(0)
		ReDim r_value(0)
		set rs = cn.execute("select sql, colspan, id, attrs, defrows from home_maincards_us where title='" & Key & "' and uid=" & Info.user)
		If rs.eof = True Then
			rs.close
			set rs = cn.execute("select sql, colspan, id, attrs, defrows from home_maincards_def where title='" & Key & "'")
		end if
		if rs.eof = false then
			colspan = rs.fields(1).value
			msql = replace(rs.fields(0).value & "","@uid",info.user,1,-1,1)
'colspan = rs.fields(1).value
			id = rs.fields("id").value
			attrs = Split(Replace(Replace(Replace(rs.fields("attrs").value & "",";","="),",","="),"|","="),"=")
			defrow = rs.fields("defrows").value
			If isnumeric(defrow) = False Then defrow = 0
		end if
		rs.close
		aSearchItems = Split(eSearch,Chr(2))
		For i = 0 To ubound(aSearchItems)
			sitem = Split(aSearchItems(i) & Chr(1) & Chr(1),Chr(1))
			ReDim Preserve r_name(r_count)
			ReDim Preserve r_value(r_count)
			r_name(r_count) = sitem(0)
			Select Case sitem(1)
			Case "gate"
			r_value(r_count) =  getW3(sitem(2))
			Case "areas"
			Dim area_list
			If Len(sitem(2)) > 0 Then
				CostomerArea = menuarea2(sitem(2),"menuarea")
				r_value(r_count) = CostomerArea
			else
				r_value(r_count) = ""
			end if
			Case "storecls"
			Dim v , ds
			v = sitem(2)
			ds = Split(v& "||" ,"|")
			If Len(ds(0)) = 0 Then
				v = ds(1)
			else
				v = cn.execute("select dbo.GetMenuSorkCk('" & ds(0) & "', '"& ds(1) &"') as r")(0).value
			end if
			r_value(r_count) =v
			Case Else
			r_value(r_count) = replace(sitem(2),"'","")
			End Select
			If Len(r_value(r_count)) > 0 Then  datavar = datavar & "[" & r_name(r_count) & "]"
			msql = replace(msql ,r_name(r_count), "'" & r_value(r_count) & "'")
			if r_name(r_count) = "@t1" then
				tmpv = r_value(r_count)
				r_count = r_count + 1
				tmpv = r_value(r_count)
				ReDim Preserve r_name(r_count)
				ReDim Preserve r_value(r_count)
				r_name(r_count)  = "@t3"
				if tmpv<>"" then
					r_value(r_count) = dateadd("m",-1,tmpv)
'if tmpv<>"" then
				else
					r_value(r_count) = ""
				end if
				r_count = r_count + 1
'r_value(r_count) = ""
				ReDim Preserve r_name(r_count)
				ReDim Preserve r_value(r_count)
				r_name(r_count)  = "@tweek1"
				if tmpv<>"" then
					r_value(r_count) = dateadd("d",-weekday(tmpv)+2,tmpv)
'if tmpv<>"" then
				else
					r_value(r_count) = ""
				end if
				r_count = r_count + 1
				r_value(r_count) = ""
				ReDim Preserve r_name(r_count)
				ReDim Preserve r_value(r_count)
				r_name(r_count)  = "@tmonth1"
				if tmpv<>"" then
					r_value(r_count) = cdate(tmpv)-day(cdate(tmpv)-1)
'if tmpv<>"" then
				else
					r_value(r_count) = ""
				end if
				r_count = r_count + 1
				r_value(r_count) = ""
				ReDim Preserve r_name(r_count)
				ReDim Preserve r_value(r_count)
				r_name(r_count)  = "@tyear1"
				if tmpv<>"" then
					r_value(r_count) = year(tmpv)&"-1-1"
'if tmpv<>"" then
				else
					r_value(r_count) = ""
				end if
			end if
			if r_name(r_count) = "@t2" then
				tmpv = r_value(r_count)
				r_count = r_count + 1
				tmpv = r_value(r_count)
				ReDim Preserve r_name(r_count)
				ReDim Preserve r_value(r_count)
				r_name(r_count)  = "@t4"
				if tmpv<>"" then
					r_value(r_count) = year(dateadd("m",-1,tmpv))&"-"&month(dateadd("m",-1,tmpv))&"-"&day(date)
'if tmpv<>"" then
				else
					r_value(r_count) = ""
				end if
				r_count = r_count + 1
'r_value(r_count) = ""
				ReDim Preserve r_name(r_count)
				ReDim Preserve r_value(r_count)
				r_name(r_count)  = "@tweek2"
				if tmpv<>"" then
					r_value(r_count) = dateadd("d",7-(DatePart("w",tmpv)-1),tmpv)
'if tmpv<>"" then
				else
					r_value(r_count) = ""
				end if
				r_count = r_count + 1
'r_value(r_count) = ""
				ReDim Preserve r_name(r_count)
				ReDim Preserve r_value(r_count)
				r_name(r_count)  = "@tmonth2"
				if tmpv<>"" then
					r_value(r_count) = dateadd("d",-1,dateadd("m",1,cdate(tmpv)-day(cdate(tmpv)-1)))
'if tmpv<>"" then
				else
					r_value(r_count) = ""
				end if
				r_count = r_count + 1
				r_value(r_count) = ""
				ReDim Preserve r_name(r_count)
				ReDim Preserve r_value(r_count)
				r_name(r_count)  = "@tyear2"
				if tmpv<>"" then
					r_value(r_count) = dateadd("d",-1,year(tmpv)+1&"-1-1")'dateadd("d",-1,dateadd("m",1,tmpv-day(tmpv-1)))
'if tmpv<>"" then
				else
					r_value(r_count) = ""
				end if
			end if
			r_count = r_count + 1
			r_value(r_count) = ""
		next
		Dim vsql
		vsql = Split(Replace(Replace(msql,",","|")," ","|"),"|")
		r_count = ubound(r_name)
		If isarray(vsql) then
			For i = 0 To ubound(vsql)
				If instr(vsql(i),"@")=1 Then
					msql = replace(msql ,vsql(i), "''")
					r_count = r_count + 1
					msql = replace(msql ,vsql(i), "''")
					ReDim Preserve r_name(r_count)
					ReDim Preserve r_value(r_count)
					r_name(r_count) = vsql(i)
					r_value(r_count) = ""
				end if
			next
		end if
		If cmd = "doSearch" Then
			l.cbWaitMsg = "正在处理，请稍后..."
			l.sql = msql
		end if
		dim lvw, link, ii
		set lvw = l
		If Key = "合同跟进" Then
			If Not ZBRuntime.MC(17003) Then
				l.headers("待出库合同_金额").display = "none"
				l.headers("待出库合同_数量").display = "none"
			end if
			If Not ZBRuntime.MC(17008) Then
				l.headers("待发货合同_金额").display = "none"
				l.headers("待发货合同_数量").display = "none"
			end if
		end if
		For i = 1 To lvw.headers.count
			Set h =  lvw.headers(i)
			If InStr(1,h.dbname,"_id",1) > 0 Then
				h.display = "none"
			end if
			If right(h.dbname,2) = "数量" Then
				h.dbtype = "number"
			ElseIf instr(1,h.dbname,"_金额",1) > 0 Then
				h.dbtype = "money"
			elseIf right(h.dbname,2) = "成本" Then
				h.dbtype = "money"
			elseIf right(h.dbname,2) = "库存" Then
				h.dbtype = "number"
			elseIf right(h.dbname,1) = "价" Then
				h.dbtype = "money"
			ElseIf h.dbname="待审批入库" or  h.dbname="预计采购" then
				h.dbtype = "number"
			end if
			If Key = "客户跟进每月对比" And instr(h.dbname,"跟进人员") = 0 Then h.dbtype = "number"
			If Key = "仓库操作导航" And instr(h.dbname,"人员") = 0 Then h.dbtype = "number"
			link = GetReportLinks(Key , h.dbname, datavar,h)
			If Len(link) > 0 Then
				For ii = 0 To ubound(r_name)
					link = Replace(link, r_name(ii),server.urlencode(r_value(ii)))
				next
				for ii = 1 to 6
					link = Replace(link, "@zdy" & ii, "")
				next
				link = Convertlnk(Replace(link,"%2C",",",1,-1,1))
				link = Replace(link, "@zdy" & ii, "")
				if instr(1,link,".asp",1) > 1 Or instr(1,link,".ashx",1) > 1 then
					h.formattext = "<a href='" & link & "' target='_blank' class='rptlink'>@value</a>"
				else
					h.formattext = link
				end if
			end if
		next
		If lvw.headers.count > 0 then
			If InStr(lvw.headers(2).dbname , "人员")>0 Then
				If InStr(lvw.headers(1).dbname,"_id")>0 Then
					lvw.headers(2).formattext = "@value&nbsp;<img src='../skin/" & Info.skin & "/images/dlgico/gate.gif' class='gateico' onclick=""showGateInfo(@cells[1],'@value')"">"
				end if
			end if
			If InStr(lvw.headers(1).dbname , "人员")>0 Then
				If InStr(lvw.headers(2).dbname,"_id")>0 Then
					lvw.headers(1).formattext = "@value&nbsp;<img src='../skin/" & Info.skin & "/images/dlgico/gate.gif' class='gateico' onclick=""showGateInfo(@cells[2],'@value')"">"
				end if
			end if
		end if
		Call setListViewCol(lvw, key, r_name, r_value)
	end sub
	function menuarea(ByRef area_list, ByVal id1)
		Dim rsarea, sqlarea, gateord22
		set rsarea=server.CreateObject("adodb.recordset")
		sqlarea="select id from menuarea where id1="& id1 &" "
		rsarea.open sqlarea,cn,1,1
		if rsarea.eof then
			gateord22 = id1
			If Len(area_list) = 0 Then
				area_list = "" & gateord22 & ""
			ElseIf InStr( area_list, gateord22 ) <= 0 Then
				area_list = area_list & ", " & gateord22 & ""
			end if
		else
			do until rsarea.eof
				gateord22=rsarea("id")
				If Len(area_list) = 0 Then
					area_list = "" & gateord22 & ""
				ElseIf InStr( area_list, gateord22 ) <= 0 Then
					area_list = area_list & ", " & gateord22 & ""
				end if
				Call menuarea(area_list, rsarea("id").value)
				rsarea.movenext
			loop
		end if
		rsarea.close
		set rsarea=nothing
	end function
	function menuarea2(khqy,tb)
		if khqy&""<>"" then
			dim kharea , rsf
			kharea = ""
			khqy = replace(khqy," ","")
			set rsf = cn.execute("select khqy=dbo.GetMenuArea('"& khqy &"','"& tb &"')")
			if not rsf.eof then
				kharea = rsf(0)
			end if
			rsf.close
			set rsf = nothing
			menuarea2 = kharea
		end if
	end function
	Function Convertlnk(ByVal r)
		Dim  s , n ,i
		If InStr(r,",") = 0 Then
			Convertlnk = r
			Exit function
		end if
		r = Split(r, "?")
		If ubound(r) > 0 Then
			s = Split(r(1), "&")
			For i = 0 To ubound(s)
				If InStr(s(i),",") > 0 And InStr(s(i),"=") > 0 Then
					n = Split(s(i),"=")
					s(i) = n(0) & "=" & Replace(n(1), "," , "&" & n(0) & "=")
				end if
			next
		end if
		if isArray(s) then
			Convertlnk = r(0) & "?" & Join(s,"&")
		else
			Convertlnk = r(0)
		end if
	end function
	Function getW3(ByVal Wlist)
		Dim rs , r
		Wlist = Split(Replace(Wlist," ",""), "|")
		Set rs =  cn.execute("exec erp_comm_getW3 '" &  Wlist(0) & "','" &  Wlist(1) & "','" &  Wlist(2) &"',1," & info.user)
		while rs.eof = False
			r = r & rs.fields(0).value
			rs.movenext
			If rs.eof = False Then r = r & ","
		wend
		rs.close
		Set rs =  Nothing
		getW3 = r
	end function
	Sub showtelClass
		dim i5, rs1, sql1, rs2 , sql2
		i5=1
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select * from sort4  order by ord"
		rs1.open sql1,cn,1,1
		if rs1.RecordCount<=0 then
			Response.write "&nbsp;"
		else
			do until rs1.eof
				Response.write "<input name=""E"" type=""checkbox"" value=""" & rs1("ord").value & """ id=""e" & i5  & """ onClick=document.getElementById('u" & i5  & "').style.display=(this.checked==1?'':'none');checkAll2(""" & i5  & """)>" & Server.HTMLEncode(rs1("sort1").value & "")
				Response.write "<div id=""u" & i5 & """  style=""border:1px  dotted  #000000;display:none;"">"
				set rs2=server.CreateObject("adodb.recordset")
				sql2="select * from sort5  where sort1 = "& rs1("ord") &" order by ord"
				rs2.open sql2,cn,1,1
				if rs2.RecordCount<=0 then
					Response.write "&nbsp;"
				else
					do until rs2.eof
						Response.write "<span class='gray'><input name='F' type='checkbox' value='" & rs2("ord").value & "' onClick=fixChk2('" & i5 & "')>" & Server.HTMLEncode(rs2("sort2").value & "") & "</span>"
						rs2.movenext
					loop
				end if
				rs2.close
				set rs2=nothing
				Response.write "</div>"
				i5=i5+1
				Response.write "</div>"
				rs1.movenext
			loop
		end if
		rs1.close
		set rs1=nothing
	end sub
	Function IsInList(v1, v2,v3)
		IsInList = false
	end function
	Sub showStoreCls(pid, ByRef pnd)
		Dim tvw, rs, rs2,  i, ii, v, nd, nd2
		If pid = 0 Then
			Response.write "<input type=""checkbox""  id='cktreeack' onClick=""__tvw_checkboxSet('cktree',this.checked);"">全选<div style='height:160px;overflow:auto;overflow-x:hidden;position:relative'>"
'If pid = 0 Then  '
			Set tvw = New treeview
			tvw.id = "cktree"
			tvw.checkbox = True
			tvw.pagesize = 80
			tvw.defexplan = false
			Call tvw.addAllNodes(tvw.nodes, "exec erp_selbox_createStoreNode " & Info.User & ",0,0,'',@parentid,@pagesize,@pageindex,0,''", false, 1, 0)
			Response.write tvw.HTML & "</div>"
		end if
	end sub
	Sub app_sys_tvw_loadItemChild(nd)
		Dim tvw, pid
		Set tvw = nd.root
		Dim keytxt, productid, unit, explan
		Select Case tvw.id
		Case "cktree"
		If nd.value < 0 Then
			pid = Abs(nd.value)
			explan = (app.gettext("explan") <> "0")
			keytxt = app.gettext("keytext")
			Call nd.root.addnodes(nd.nodes,  "exec erp_selbox_createStoreTmp " & Info.User & ",0,0,'" & Replace(keytxt,"'","''") & "',0," & pid & ",@pagesize,@pageindex,0", 0,1)
			nd.value = ""
		else
			nd.ckname = "storeck"
		end if
		Case Else
		End select
	end sub
	Sub doGateList(sort_zjjg,user_list)
		Dim rs1 , str_w1 , str_w2 , str_w3 , open_1_1
		Dim sql1, Correct_W1, Correct_W2, Correct_W3
		Dim rs8, sql, i, j6 , zhanshi2 , zk2
		Dim w1, w2, w3, zhanshi, zhanshi1, rs3, sql3, rs2, sql2
		Dim zhanshi3, zk3, zhanshi4
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select sort1,qx_open,w1,w2,w3 from power2  where cateid="& Info.User &" and sort1="&sort_zjjg&" "
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
		Correct_W3=user_list
		if Correct_W3<>"" and Correct_W3<>"0" then
			tmp=split(getW1W2(Correct_W3),";")
			Correct_W1=tmp(0)
			Correct_W2=tmp(1)
		end if
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
		'd_at(44) = "                If count>0 Then "
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
		Dim basesql : basesql="select ord,orgsid from gate where del=1 "&str_w3&""
		Response.write CBaseUserTreeHtml(basesql,"orgs", "W1","W2","W3",  Correct_W1  & "," & Correct_W2 , Correct_W1, Correct_W2,  Correct_W3)
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
	
%>
