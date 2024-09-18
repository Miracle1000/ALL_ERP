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
	Dim x_t
	Sub MessagePost(msg)
		cn.cursorlocation = 3
		Dim t : t = now
		x_t = now
		Select Case msg
		Case ""
		Call page_load
		Case "salesreport_needdo"
		Call salesreport_needdo
		Case "salesreport_report"
		Call salesreport_report
		Case "salesreport_tellist"
		Call salesreport_tellist(1)
		Case "salesreport_tellist2"
		Call salesreport_tellist(2)
		Case "salesreport_tellist3"
		Call salesreport_tellist(3)
		Case "showperson1"
		Call showperson(1)
		Case "showperson2"
		Call showperson(2)
		Case "showperson3"
		Call showperson(3)
		Case "showperson4"
		Call showperson(4)
		Case "showperson5"
		Call showperson(5)
		Case "showperson6"
		Call showperson(6)
		Case "showperson7"
		Call showperson(7)
		Case "showperson8"
		Call showperson(8)
		Case "report_person1"
		Call report_person(1)
		Case "report_sort1"
		Call report_sort(1)
		Case "report_person2"
		Call report_person(2)
		Case "report_sort2"
		Call report_sort(2)
		Case "report_apply"
		Call report_apply
		Case "report_person3"
		Call report_person(3)
		Case "report_sort3"
		Call report_sort(3)
		Case "report_person4"
		Call report_person(4)
		Case "report_person5"
		Call report_person(5)
		Case "report_person6"
		Call report_person(6)
		Case "report_person7"
		Call report_person(7)
		Case "report_sort4"
		Call report_sort(4)
		Case "report_sort5"
		Call report_sort(5)
		Case "report_sort6"
		Call report_sort(6)
		Case "report_backtype"
		Call report_backtype
		Case "salereports"
		Call salereports
		Case "salereportsmap"
		Call salereportsmap
		Case "tel_sort_list"
		Call tel_sort_list
		End Select
	end sub
	Sub page_load
		app.docmodel = "IE=EmulateIE7"
		app.addDefaultScript
		Dim css
		css = vbcrlf &_
		"<link href='../skin/default/css/ReportCls.css' rel='stylesheet' type='text/css'/>"& vbcrlf &_
		"<script type='text/JavaScript' src='../skin/default/js/VmlGraphics.js'></script>"& vbcrlf &_
		"<script type='text/JavaScript' src='../inc/echarts.min.js'></script>"& vbcrlf &_
		"<meta name=""vs_targetSchema"" content=""http://schemas.microsoft.com/intellisense/ie5""/>" & vbcrlf & _
		"<style>" & vbcrlf & _
		"    v\:shape { Behavior: url(#default#VML) }" & vbcrlf & _
		"    o\:extrusion { Behavior: url(#default#VML) }" & vbcrlf & _
		"</style>"
		Response.write Replace(app.deftopbarHTML("../", css,"销售分析中心",""),"<html>","<html  xmlns:v=""urn:schemas-microsoft-com:vml"" xmlns:o=""urn:schemas-microsoft-com:office:office"">")
'</style>
		Response.write "" & vbcrlf & "      <body>" & vbcrlf & "  <style>" & vbcrlf & " input.anybutton{margin:0 5px;*padding-top:3px; line-height:13px;}" & vbcrlf & "       .home tr.top td{background-image:url(../images/m_table_top.jpg);background-repeat:repeat-x;text-align:center;line-height:14px;font-weight:bold;color:#2F496E;}.home tr.top2 td{background-image:url(../images/m_table_top.jpg);background-repeat:repeat-x;text-align:center;line-height:14px;color:#2F496E;}.home tr.top div.left{color:#2F496E;}.home tr.title td{color:#2F496E;font-weight:bold;background-color:#F3F7FC;}.home td.name,.home td.name{color:#2F496E;}"& vbcrlf & "       #mycontent td{color:#000;border-color:#CCC!important}" & vbcrlf & "   .datesel {color:#2F496E;font-weight:bold;border:0px;width:70px;background-image:url('../images/m_table_top.jpg');}" & vbcrlf & "      table {table-layout:fixed;border-collapse:separate;}" & vbcrlf & "    #comm_itembarbg{height:60px!important;}" & vbcrlf & "    /*标题*/" & vbcrlf & ".resetTableBg:before{" & vbcrlf & "   position: absolute;" & vbcrlf & "    content: '';" & vbcrlf & "    width: 100%;" & vbcrlf & "    height: 10px;" & vbcrlf & "    background: #EFEFEF;" & vbcrlf & "    left: 0px;" & vbcrlf & "    top: 0px;" & vbcrlf & "    border-top: 30px solid #fff;" & vbcrlf & "}" & vbcrlf & ".resetTableBg{" & vbcrlf & "        padding: 30px 0px 0px 42px!important;" & vbcrlf & "    background-image: url(../images/top_left.png)!important;" & vbcrlf & "    background-repeat: no-repeat!important;" & vbcrlf & "    background-position: 32px 68px!important;" & vbcrlf & "    height: 120px!important;" & vbcrlf & "    position: relative;" & vbcrlf & "    box-sizing: border-box;" & vbcrlf & "}" & vbcrlf & ".resetFirstTableBg{" & vbcrlf & "     padding: 0px 0px 0px 42px!important;" & vbcrlf & "    background-image: url(""../images/top_left.png"")!important;" & vbcrlf & "   background-repeat: no-repeat!important;" & vbcrlf & " background-position: 32px 20px!important;" & vbcrlf & "       height: 50px!important;" & vbcrlf & " line-height:50px;" & vbcrlf & "       position: relative;" & vbcrlf & "}" & vbcrlf & ".resetFirstTableBg:after{" & vbcrlf & "   top:54px;" & vbcrlf & "}" & vbcrlf & ".resetTableBg:after,.resetFirstTableBg:after{" & vbcrlf & "        width: auto;" & vbcrlf & "    height: 1px;" & vbcrlf & "    content: '';" & vbcrlf & "    background-color: #ccc;" & vbcrlf & "    position: relative;" & vbcrlf & "    left: 30px;" & vbcrlf & "    right: 0px;" & vbcrlf & "    display: block;" & vbcrlf & "    bottom: 24px;" & vbcrlf & "    position: absolute;" & vbcrlf & "}" & vbcrlf & ".resetBorderColor{" & vbcrlf & " border:0!important;" & vbcrlf & "}" & vbcrlf & "/*表格*/" & vbcrlf & "#lvw_tby{" & vbcrlf & "   font-size:14px;" & vbcrlf & "}" & vbcrlf & ".home td{" & vbcrlf & "      border:1px solid #CCC;" & vbcrlf & "}" & vbcrlf & ".listview{" & vbcrlf & "       border-right:0;" & vbcrlf & "}" & vbcrlf & "        </style>" & vbcrlf & "        <TABLE id='mycontent' style=""BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; WORD-BREAK: break-all;table-layout:fixed;"" border=0 cellPadding=3 width=""100%"">" & vbcrlf & "             <TBODY>" & vbcrlf & "         <TR>" & vbcrlf & "                    <TD class=""resetHeadBg resetBorderColor"" style=""text-align:left"" height=""35"" valign='middle' width=""14%"" align=middle>" & vbcrlf & "     </style>"
		Response.write "<div style='float:left'><lable><input type='radio' onclick=""location.href='salecenter.asp'"">销售工作台</lable>&nbsp;</div>"
		Response.write "<div style='float:right;right:10px;position:absolute'>"
		Response.write openbutton1("要事提醒","alt_list.asp?complete=1&open=1&t2="&date&"",1220,500,150,150)
		If ZBRuntime.MC(201101) Then
			Response.write openbutton1("待审核客户","teltop_sp.asp",1200,500,150,150)
		end if
		Response.write openbutton1("客户池","teltop.asp",1200,500,150,150)
		Response.write openbutton1("客户列表","telhy.asp",1200,500,150,150)
		if app.power.existsModel(2000) And (app.power.existsPower(2,13) or app.power.existsPower(2,13)) And app.power.existsPower(2,19)<>1 Then
			Response.write openbutton1("联系人列表","../person/telall.asp?q=1&s3=1",1200,500,150,150)
		end if
		if app.power.existsModel(7000)  And (app.power.existsPower(5,13) or app.power.existsPower(5,13)) And app.power.existsPower(5,19)<>1 Then
			Response.write openbutton1("合同列表","../contract/planall.asp",1200,700,150,50)
		end if
		if app.power.existsModel(31000) And (app.power.existsPower(71,19)) Then
			Response.write openbutton1("日程管理","../china/tophome2.asp",1100,700,150,50)
		end if
		Response.write "</div>"
		Response.write "" & vbcrlf & "                     </TD>" & vbcrlf & "           </TR>   " & vbcrlf & "                <tr>" & vbcrlf & "                    <td>" & vbcrlf & "                            <div id=""needdo""><textarea id='hidden1' style='display:none'>" & vbcrlf & "                             "
		Call salesreport_needdo
		Response.write "</textarea>" & vbcrlf & "                          </div>" & vbcrlf & "                  </td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td style=""padding:0"">" & vbcrlf & "                            <div id=""report""><textarea id='hidden23' style='display:none'>" & vbcrlf & "                            "
		'Call salesreport_report
		Response.write "</textarea>" & vbcrlf & "                          </div>" & vbcrlf & "                  </td>" & vbcrlf & "           </tr>           " & vbcrlf & "                <tr>" & vbcrlf & "                    <td>" & vbcrlf & "                            <div id=""telsort""></div>" & vbcrlf & "                  </td>" & vbcrlf & "           </tr>           " & vbcrlf & "                <tr>" & vbcrlf & "                    <td>" & vbcrlf & "                    <TABLE style=""BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; WORD-BREAK: break-all;table-layout:fixed"" border=0 cellPadding=3 width=""100%"">" & vbcrlf & "                              <TBODY>" & vbcrlf & "                         <TR>" & vbcrlf & "                            <td style=""text-align:left;BORDER-BOTTOM: #c0ccdd 1px solid; BORDER-LEFT: #c0ccdd 1px solid; BORDER-TOP: #c0ccdd 1px solid; BORDER-RIGHT: #c0ccdd 1px solid;padding-left:15px;"">" & vbcrlf & "                           <div style=""width:50%;text-align:left;"">" & vbcrlf & "                                  <li><a href=""../report/index.asp?id=-2"" target=""_blank"">新增客户分布</a></li>" & vbcrlf & "                                       <li><a href=""../report/index.asp?id=-3"" target=""_blank"">领用客户分布</a></li>" & vbcrlf & "                                       <li><a href=""../report/index.asp?id=-4"" target=""_blank"">跟进客户分布</a></li>" & vbcrlf & "                                       <li><a href=""../report/index.asp?id=-5"" target=""_blank"">回收客户分布</a></li>" & vbcrlf & "                               </div>" & vbcrlf & "                          </td>" & vbcrlf & "                           <td style=""text-align:left;BORDER-BOTTOM: #c0ccdd 1px solid; BORDER-LEFT: #c0ccdd 1px solid; BORDER-TOP: #c0ccdd 1px solid; BORDER-RIGHT: #c0ccdd 1px solid;padding-left:15px;"">" & vbcrlf & "                            <div style=""width:50%;text-align:left;"">" & vbcrlf & "                                          "
		'Call salesreport_report
		if (app.power.existsModel(1000) Or app.power.existsModel(12000) Or app.power.existsModel(12001)) then
			Response.write "" & vbcrlf & "                                             <li><a href=""../china2/mReportSearch.asp?id=8"" target=""_blank"">客户跟进对比</a></li>" & vbcrlf & "                                                "
		end if
		if app.power.existsPower(1,11) and (app.power.existsModel(11000) and (app.power.existsModel(12001) or app.power.existsModel(12002) or app.power.existsModel(12003) or app.power.existsModel(12004) or app.power.existsModel(12006) or app.power.existsModel(12007) or app.power.existsModel(12008) or app.power.existsModel(12010))) then
			Response.write "" & vbcrlf & "                                             <li><a href=""../tongji/kh_gj4.asp"" target=""_blank"">客户跟进每日走势</a></li>" & vbcrlf & "                                                <li><a href=""../tongji/kh_gj5.asp"" target=""_blank"">客户跟进每周走势</a></li>" & vbcrlf & "                                                <li><a href=""../tongji/kh_gj6.asp"" target=""_blank"">客户跟进每月走势</a></li>" & vbcrlf & "                                "
		end if
		Response.write "" & vbcrlf & "                             </div>" & vbcrlf & "                          </td>" & vbcrlf & "                           </tr>" & vbcrlf & "                           </tbody>" & vbcrlf & "                        </table>" & vbcrlf & "                        </td>" & vbcrlf & "           </tr>" & vbcrlf & "           "
		if (app.power.existsModel(7000)  Or app.power.existsModel(23001)) then
			Response.write "" & vbcrlf & "             <tr>" & vbcrlf & "                    <td  class=""resetBorderColor resetTableBg"" style=""text-align:left;font-weight:bold;"" height=""35"" valign='middle' width=""100%"" align=middle>" & vbcrlf & "                     &nbsp;销售业绩分析" & vbcrlf & "                      <span style=""margin-left:300px;"">" & vbcrlf & "                 <input type='text' name='t3_1' id=""t3_1""  value='"
			Response.write year(date)&"-"&month(date)&"-01"
'text' name='t3_1' id=""t3_1""  value='"
			Response.write "' readonly class='smdate' onmouseup='datedlg.show()' style=""MARGIN-TOP:0px; HEIGHT:22px!important;width:101px; line-height:22px!important;top:4px; padding-top:0px;"" >&nbsp;<font style=""font-weight:normal"">至</span>&nbsp;<input type='text' value='"
'text' name='t3_1' id=""t3_1""  value='"
			Response.write dateadd("d",-1,dateadd("m",1,CDate(year(now())&"-"&month(now())&"-01")))
'text' name='t3_1' id=""t3_1""  value='"
			Response.write "' class='smdate' onmouseup='datedlg.show()' name='t3_2' id='t3_2' readonly style=""MARGIN-TOP:0px; HEIGHT:22px!important;width:101px; line-height:22px!important;top:4px; padding-top:0px;"">" & vbcrlf & "                    <input type='button' class='oldbutton' onclick='javascript:ajax.regEvent(""salereports"");ajax.addParam(""v1"",document.getElementById(""t3_1"").value);ajax.addParam(""v2"",document.getElementById(""t3_2"").value);document.getElementById(""salereports"").innerHTML=ajax.send();' value='检索' id='dosbutton'>" & vbcrlf & "                     <span>" & vbcrlf & "                  </td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                 <td id=""salereports"">" & vbcrlf & "                     </td>" & vbcrlf & "           </tr>" & vbcrlf & "           "
		end if
		Response.write "" & vbcrlf & "" & vbcrlf & "             <tr>" & vbcrlf & "                    <td>" & vbcrlf & "                    <span style=""margin-left:700px;"">" & vbcrlf & "                 <input type='text' name='t4_1' id=""t4_1""  value='"
		Response.write year(date)&"-"&month(date)&"-01"
		Response.write "' readonly class='smdate' onmouseup='datedlg.show()' style=""MARGIN-TOP:0px; HEIGHT:17px;width:101px; line-height:17px; padding-top:0px;"">&nbsp;至&nbsp;<input type='text' value='"
		Response.write dateadd("d",-1,dateadd("m",1,CDate(year(now())&"-"&month(now())&"-01")))
		Response.write "' class='smdate' onmouseup='datedlg.show()' name='t4_2' id=""t4_2"" style=""MARGIN-TOP:0px; HEIGHT:17px;width:101px; line-height:17px; padding-top:0px;"" readonly>" & vbcrlf & "                  <input type='button' class='oldbutton' onclick='javascript:ajax.regEvent(""salereportsmap"");ajax.addParam(""v1"",document.getElementById(""t4_1"").value);ajax.addParam(""v2"",document.getElementById(""t4_2"").value);document.getElementById(""salereportsmap"").innerHTML=ajax.send();' value='检索' id='dosbutton'>" & vbcrlf & "                     <span>" & vbcrlf & "                  </td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td id=""salereportsmap"">" & vbcrlf & "                      </td>" & vbcrlf & "           </tr>" & vbcrlf & "           "
		if (app.power.existsModel(7000)  Or app.power.existsModel(23001)) then
			Response.write "" & vbcrlf & "             <tr>" & vbcrlf & "                    <td>" & vbcrlf & "                    <TABLE style=""BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; WORD-BREAK: break-all;table-layout:fixed"" border=0 cellPadding=3 width=""100%"">" & vbcrlf & "                              <TBODY>" & vbcrlf & "                         <TR>" & vbcrlf & "                            "
'if (app.power.existsModel(7000)  Or app.power.existsModel(23001)) then
			If app.power.existsModel(7000) then
				Response.write "" & vbcrlf & "                             <td style=""text-align:left;BORDER-BOTTOM: #c0ccdd 1px solid; BORDER-LEFT: #c0ccdd 1px solid; BORDER-TOP: #c0ccdd 1px solid; BORDER-RIGHT: #c0ccdd 1px solid;padding-left:15px;"">" & vbcrlf & "                          <div style=""width:50%;text-align:left;"">" & vbcrlf & "                                  "
'If app.power.existsModel(7000) then
				if app.power.existsPower(5,11) then
					Response.write "" & vbcrlf & "                                             <li><a href=""../tongji/bbzj2.asp"" target=""_blank"">挑战纪录</a></li>" & vbcrlf & "                                         <li><a href=""../tongji/bbzj1.asp"" target=""_blank"">龙虎榜</a></li>" & vbcrlf & "                                           <li><a href=""../tongji/bbdd1_m.asp"" target=""_blank"">部门业绩对比</a></li>" & vbcrlf & "                                           <li><a href=""../tongji/bbdd2_m.asp"" target=""_blank"">小组业绩对比</a></li>" & vbcrlf & "                                 "
				end if
				Response.write "" & vbcrlf & "                             </div>" & vbcrlf & "                          </td>" & vbcrlf & "                           "
			end if
			If app.power.existsModel(23001) then
				Response.write "" & vbcrlf & "                             <td style=""text-align:left;BORDER-BOTTOM: #c0ccdd 1px solid; BORDER-LEFT: #c0ccdd 1px solid; BORDER-TOP: #c0ccdd 1px solid; BORDER-RIGHT: #c0ccdd 1px solid;vertical-align:top;padding-left:15px;"">" & vbcrlf & "                               <div style=""width:50%;text-align:left;"">" & vbcrlf & "                                  "
				if app.power.existsPower(1,11) then
					Response.write "" & vbcrlf & "                                             <li><a href=""../china2/mReportSearch.asp?id=9"" target=""_blank"">销售业绩每月对比</a></li>" & vbcrlf & "                                            "
				end if
				if app.power.existsPower(7,11) then
					Response.write "" & vbcrlf & "                                             <li><a href=""../money/planall2.asp?newstate=1"" target=""_blank"">应收账款信息</a></li>" & vbcrlf & "                                                <li><a href=""../money/paybackInvoice_List.asp?A=4"" target=""_blank"">应开发票信息</a></li>" & vbcrlf & "                                            "
				end if
				Response.write "" & vbcrlf & "                             </div>" & vbcrlf & "                          </td>" & vbcrlf & "                           "
			end if
			Response.write "" & vbcrlf & "                             </tr>" & vbcrlf & "                           </tbody>" & vbcrlf & "                        </table>" & vbcrlf & "                        </td>" & vbcrlf & "           </tr>   " & vbcrlf & "                "
		end if
		response.end
		Response.write "" & vbcrlf & "" & vbcrlf & "             <tr>" & vbcrlf & "                    <td class=""resetBorderColorresetTableBg"" style=""text-align:left;font-weight:bold;"" height=""35"" valign='middle' width=""100%"" align=middle>" & vbcrlf & "                      &nbsp;客户分布分析" & vbcrlf & "                      </td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                  <td>" & vbcrlf & "                    <TABLE style=""BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; WORD-BREAK: break-all;table-layout:fixed"" border=0 cellPadding=3 width=""100%"">" & vbcrlf & "                              <TBODY>" & vbcrlf & "                         <TR>" & vbcrlf & "                            <td style=""text-align:left;BORDER-BOTTOM: #c0ccdd 1px solid; BORDER-LEFT: #c0ccdd 1px solid; BORDER-TOP: #c0ccdd 1px solid; BORDER-RIGHT: #c0ccdd 1px solid"">" & vbcrlf & "                           <div style=""width:50%;height:300px;text-align:left;padding:5px;"" id=""tel_sort_list"">" & vbcrlf & "                                </div>" & vbcrlf & "                          </td>" & vbcrlf & "                           <td style=""text-align:left;BORDER-BOTTOM: #c0ccdd 1px solid; BORDER-LEFT: #c0ccdd 1px solid; BORDER-TOP: #c0ccdd 1px solid; BORDER-RIGHT: #c0ccdd 1px solid;vertical-align:top;padding-left:15px"">" & vbcrlf & "                                <div style=""width:50%;text-align:left;"">" & vbcrlf & "                                          "
		if app.power.existsPower(1,11) then
			Response.write "" & vbcrlf & "                                             <li><a href=""../china2/mReportSearch.asp?id=2"" target=""_blank"">客户分布</a></li>" & vbcrlf & "                                            "
		end if
		if app.power.existsPower(1,11) then
			Response.write "" & vbcrlf & "                                             <li><a href=""../tongji/kh6.asp"" target=""_blank"">"
			Response.write arrName(9)
			Response.write "数量对比</a></li>" & vbcrlf & "                                            <li><a href=""../tongji/kh8.asp"" target=""_blank"">"
			Response.write arrName(6)
			Response.write "数量对比</a></li>" & vbcrlf & "                                            <li><a href=""../tongji/kh7.asp"" target=""_blank"">"
			Response.write arrName(8)
			Response.write "数量对比</a></li>" & vbcrlf & "                                            <li><a href=""../tongji/kh9.asp"" target=""_blank"">"
			Response.write arrName(7)
			Response.write "数量对比</a></li>" & vbcrlf & "                                            <li><a href=""../tongji/kh10.asp"" target=""_blank"">客户新增每日走势</a></li>" & vbcrlf & "                                          <li><a href=""../tongji/kh11.asp"" target=""_blank"">客户新增每周走势</a></li>" & vbcrlf & "                                          <li><a href=""../tongji/kh12.asp"" target=""_blank"">客户新增每月走势</a></li>" & vbcrlf & "                                                <li><a href=""../tongji/kh13.asp"" target=""_blank"">客户新增每年走势</a></li>  " & vbcrlf & "                                                "
		end if
		Response.write "" & vbcrlf & "                             </div>" & vbcrlf & "                          </td>" & vbcrlf & "                           </tr>" & vbcrlf & "                           </tbody>" & vbcrlf & "                        </table>" & vbcrlf & "                        </td>" & vbcrlf & "           </tr>   " & vbcrlf & "                </TBODY>" & vbcrlf & "        </TABLE>" & vbcrlf & "        <script>" & vbcrlf & "        loadData();" & vbcrlf & "     function loadData() {" & vbcrlf & "         try{" & vbcrlf & "                    ajax.regEvent(""salereports"");" & vbcrlf & "                     ajax.addParam(""v1"",document.getElementById(""t3_1"").value);" & vbcrlf & "                  ajax.addParam(""v2"",document.getElementById(""t3_2"").value);" & vbcrlf & "                  var r=ajax.send();" & vbcrlf & "                      document.getElementById(""salereports"").innerHTML = r;" & vbcrlf & "            }catch(e){}" & vbcrlf & "             ajax.regEvent(""salereportsmap"");" & vbcrlf & "          ajax.addParam(""v1"",document.getElementById(""t4_1"").value);" & vbcrlf & "          ajax.addParam(""v2"",document.getElementById(""t4_2"").value);" & vbcrlf & "" & vbcrlf & "             ajax.regEvent(""tel_sort_list"");" & vbcrlf & "           setTimeout(function()" & vbcrlf & "           {" & vbcrlf & "                       $ID(""needdo"").innerHTML = $ID(""needdo"").children[0].value; //binary.2015.03.27.异步执行，防止VML图像加载不出来的问题" & vbcrlf & "                    $ID(""report"").innerHTML =ajax.PreScript($ID(""report"").children[0].value);" & vbcrlf & "           },100);" & vbcrlf & " }" & vbcrlf & "" & vbcrlf & "       function testobj(thisobj){" & vbcrlf & "              var v=event.toElement;" & vbcrlf & "          var i=0;" & vbcrlf & "                while (v&&i<100){" & vbcrlf & "                       if(v==thisobj) {return false;}" & vbcrlf & "                  v = v.parentNode;i++;" & vbcrlf & "           }" & vbcrlf & "         return true;" & vbcrlf & "  } " & vbcrlf & "      function movelist(id,ord,act){" & vbcrlf & "     var v1=document.getElementById(""hiddenflag_0"").value;" & vbcrlf & "           var v2=document.getElementById(""hiddenflagdate_0"").value;" & vbcrlf & "         if (parseInt(id)>0){ajax.regEvent(""salesreport_tellist""+id);}" & vbcrlf & "     else{ajax.regEvent(""salesreport_tellist"");}" & vbcrlf & "       ajax.addParam(""v1"", v1);" & vbcrlf & "         ajax.addParam(""v2"", v2);" & vbcrlf & "        ajax.addParam(""moveid"",ord);" & vbcrlf & "      ajax.addParam(""act"",act);" & vbcrlf & "         showDlgDiv(ajax.send(), true);" & vbcrlf & "       }" & vbcrlf & "       function getneeddolist(){" & vbcrlf & "          var v1=document.getElementById(""hiddenflag_0"").value;" & vbcrlf & "           var v2=document.getElementById(""hiddenflagdate_0"").value;" & vbcrlf & "              ajax.regEvent(""salesreport_needdo"");" & vbcrlf & "              ajax.addParam(""v1"", v1);" & vbcrlf & "          ajax.addParam(""v2"", v2);" & vbcrlf &"}" & vbcrlf & "       function getreportlist(){" & vbcrlf & "           var v1=document.getElementById(""hiddenflag_2"").value;" & vbcrlf & "     var v2=document.getElementById(""hiddenflagdate2"").value;" & vbcrlf & "              ajax.regEvent(""salesreport_report"");" & vbcrlf & "              ajax.addParam(""v1"", v1);" & vbcrlf & "                ajax.addParam(""v2"", v2);" & vbcrlf &"  }" & vbcrlf & "       function showDlgDiv(html, dispos) {" & vbcrlf & "             //页面的内容高度 " & vbcrlf & "               var sTop = document.documentElement.scrollTop; " & vbcrlf & "         var sLeft =  document.documentElement.scrollLeft; " & vbcrlf & "          var div = document.getElementById(""showDlgDivObj"");" & vbcrlf & "               if(!div) {" & vbcrlf & "                      div = document.createElement(""showDlgDivObj"");" & vbcrlf & "                    div.style.cssText = ""position:absolute;display:block;z-index:100000;display:none;margin-top:6px;margin-left:-3px;"";" & vbcrlf & "                      div.id = ""showDlgDivObj"";" & vbcrlf & "                 //div.onmouseleave = function(){trycleardlgDiv()};" & vbcrlf & "                      document.body.appendChild(div);" & vbcrlf & "         }" & vbcrlf & "               var xy = fGetXY(window.event.srcElement);" & vbcrlf & "               " & vbcrlf & "                div.style.display = ""block"";" & vbcrlf & "         div.style.margin = ""-5px 0 0 -10px"";" & vbcrlf & "              div.innerHTML =  html;" & vbcrlf & "          if(dispos!=true) {" & vbcrlf & "                      div.style.left = (xy.x + window.event.srcElement.offsetWidth) + ""px"";// window.event.clientX + sLeft - window.event.offsetX + window.event.srcElement.offsetLeft + window.event.srcElement.offsetWidth;" & vbcrlf & "                 div.style.top = (xy.y + window.event.srcElement.offsetHeight)+ ""px""; //window.event.clientY + sTop - window.event.offsetY + window.event.srcElement.offsetTop + window.event.srcElement.offsetHeight;" & vbcrlf & "             }" & vbcrlf & "             " & vbcrlf & "        }" & vbcrlf & "" & vbcrlf & "       function trycleardlgDiv() {" & vbcrlf & "             var div = document.getElementById(""showDlgDivObj"");" & vbcrlf & "               if(!div) {return;}" & vbcrlf & "              if(window.event.type==""click"")    {" & vbcrlf & "                       div.innerHTML = """";" & vbcrlf & "                       div.style.display = ""none"";" & vbcrlf & "                       return;" & vbcrlf & "         }" & vbcrlf & "               if(testobj(div)) {" & vbcrlf & "                      div.innerHTML = """";" & vbcrlf & "                       div.style.display = ""none"";" & vbcrlf & "               }" & vbcrlf & "       } " & vbcrlf & "      </script>" & vbcrlf & "       <input type=""hidden"" name=""hiddenflag0"" id=""hiddenflag_0""  value=""5"">" & vbcrlf & "    <input type=""hidden"" name=""hiddenflag"" id=""hiddenflag_2""  value=""4"">" & vbcrlf & "    <input type=""hidden"" name=""hiddenflag1"" id=""hiddenflag_3""  value=""4"">" & vbcrlf & "   "
        'Response.write "" & vbcrlf & "                             </div>" & vbcrlf & "                          </td>" & vbcrlf & "                           </tr>" & vbcrlf & "                           </tbody>" & vbcrlf & "                        </table>" & vbcrlf & "                        </td>" & vbcrlf & "           </tr>   " & vbcrlf & "                </TBODY>" & vbcrlf & "        </TABLE>" & vbcrlf & "        <script>" & vbcrlf & "        loadData();" & vbcrlf & "     function loadData() {" & vbcrlf & "         try{" & vbcrlf & "                    ajax.regEvent(""salereports"");" & vbcrlf & "                     ajax.addParam(""v1"",document.getElementById(""t3_1"").value);" & vbcrlf & "                  ajax.addParam(""v2"",document.getElementById(""t3_2"").value);" & vbcrlf & "                  var r=ajax.send();" & vbcrlf & "                      document.getElementById(""salereports"").innerHTML = r;" & vbcrlf & "            }catch(e){}" & vbcrlf & "             ajax.regEvent(""salereportsmap"");" & vbcrlf & "          ajax.addParam(""v1"",document.getElementById(""t4_1"").value);" & vbcrlf & "          ajax.addParam(""v2"",document.getElementById(""t4_2"").value);" & vbcrlf & "          document.getElementById(""salereportsmap"").innerHTML=ajax.send();" & vbcrlf & "" & vbcrlf & "             ajax.regEvent(""tel_sort_list"");" & vbcrlf & "           document.getElementById(""tel_sort_list"").innerHTML=ajax.send();" & vbcrlf & "           setTimeout(function()" & vbcrlf & "           {" & vbcrlf & "                       $ID(""needdo"").innerHTML = $ID(""needdo"").children[0].value; //binary.2015.03.27.异步执行，防止VML图像加载不出来的问题" & vbcrlf & "                    $ID(""report"").innerHTML =ajax.PreScript($ID(""report"").children[0].value);" & vbcrlf & "           },100);" & vbcrlf & " }" & vbcrlf & "" & vbcrlf & "       function testobj(thisobj){" & vbcrlf & "              var v=event.toElement;" & vbcrlf & "          var i=0;" & vbcrlf & "                while (v&&i<100){" & vbcrlf & "                       if(v==thisobj) {return false;}" & vbcrlf & "                  v = v.parentNode;i++;" & vbcrlf & "           }" & vbcrlf & "         return true;" & vbcrlf & "  } " & vbcrlf & "      function movelist(id,ord,act){" & vbcrlf & "     var v1=document.getElementById(""hiddenflag_0"").value;" & vbcrlf & "           var v2=document.getElementById(""hiddenflagdate_0"").value;" & vbcrlf & "         if (parseInt(id)>0){ajax.regEvent(""salesreport_tellist""+id);}" & vbcrlf & "     else{ajax.regEvent(""salesreport_tellist"");}" & vbcrlf & "       ajax.addParam(""v1"", v1);" & vbcrlf & "         ajax.addParam(""v2"", v2);" & vbcrlf & "        ajax.addParam(""moveid"",ord);" & vbcrlf & "      ajax.addParam(""act"",act);" & vbcrlf & "         showDlgDiv(ajax.send(), true);" & vbcrlf & "       }" & vbcrlf & "       function getneeddolist(){" & vbcrlf & "          var v1=document.getElementById(""hiddenflag_0"").value;" & vbcrlf & "           var v2=document.getElementById(""hiddenflagdate_0"").value;" & vbcrlf & "              ajax.regEvent(""salesreport_needdo"");" & vbcrlf & "              ajax.addParam(""v1"", v1);" & vbcrlf & "          ajax.addParam(""v2"", v2);" & vbcrlf & "          document.getElementById(""needdo"").innerHTML=ajax.send();" & vbcrlf & "}" & vbcrlf & "       function getreportlist(){" & vbcrlf & "           var v1=document.getElementById(""hiddenflag_2"").value;" & vbcrlf & "     var v2=document.getElementById(""hiddenflagdate2"").value;" & vbcrlf & "              ajax.regEvent(""salesreport_report"");" & vbcrlf & "              ajax.addParam(""v1"", v1);" & vbcrlf & "                ajax.addParam(""v2"", v2);" & vbcrlf & "          document.getElementById(""report"").innerHTML=ajax.send();" & vbcrlf & "  }" & vbcrlf & "       function showDlgDiv(html, dispos) {" & vbcrlf & "             //页面的内容高度 " & vbcrlf & "               var sTop = document.documentElement.scrollTop; " & vbcrlf & "         var sLeft =  document.documentElement.scrollLeft; " & vbcrlf & "          var div = document.getElementById(""showDlgDivObj"");" & vbcrlf & "               if(!div) {" & vbcrlf & "                      div = document.createElement(""showDlgDivObj"");" & vbcrlf & "                    div.style.cssText = ""position:absolute;display:block;z-index:100000;display:none;margin-top:6px;margin-left:-3px;"";" & vbcrlf & "                      div.id = ""showDlgDivObj"";" & vbcrlf & "                 //div.onmouseleave = function(){trycleardlgDiv()};" & vbcrlf & "                      document.body.appendChild(div);" & vbcrlf & "         }" & vbcrlf & "               var xy = fGetXY(window.event.srcElement);" & vbcrlf & "               " & vbcrlf & "                div.style.display = ""block"";" & vbcrlf & "         div.style.margin = ""-5px 0 0 -10px"";" & vbcrlf & "              div.innerHTML =  html;" & vbcrlf & "          if(dispos!=true) {" & vbcrlf & "                      div.style.left = (xy.x + window.event.srcElement.offsetWidth) + ""px"";// window.event.clientX + sLeft - window.event.offsetX + window.event.srcElement.offsetLeft + window.event.srcElement.offsetWidth;" & vbcrlf & "                 div.style.top = (xy.y + window.event.srcElement.offsetHeight)+ ""px""; //window.event.clientY + sTop - window.event.offsetY + window.event.srcElement.offsetTop + window.event.srcElement.offsetHeight;" & vbcrlf & "             }" & vbcrlf & "             " & vbcrlf & "        }" & vbcrlf & "" & vbcrlf & "       function trycleardlgDiv() {" & vbcrlf & "             var div = document.getElementById(""showDlgDivObj"");" & vbcrlf & "               if(!div) {return;}" & vbcrlf & "              if(window.event.type==""click"")    {" & vbcrlf & "                       div.innerHTML = """";" & vbcrlf & "                       div.style.display = ""none"";" & vbcrlf & "                       return;" & vbcrlf & "         }" & vbcrlf & "               if(testobj(div)) {" & vbcrlf & "                      div.innerHTML = """";" & vbcrlf & "                       div.style.display = ""none"";" & vbcrlf & "               }" & vbcrlf & "       } " & vbcrlf & "      </script>" & vbcrlf & "       <input type=""hidden"" name=""hiddenflag0"" id=""hiddenflag_0""  value=""5"">" & vbcrlf & "    <input type=""hidden"" name=""hiddenflag"" id=""hiddenflag_2""  value=""4"">" & vbcrlf & "    <input type=""hidden"" name=""hiddenflag1"" id=""hiddenflag_3""  value=""4"">" & vbcrlf & "   "
		Response.write "</body></html>"
	end sub
	Function CGlistUrl(ByVal glist)
		If InStr(1, glist, "select", 1) > 0 Or InStr(1, glist, "exec", 1) > 0 Then
			CGlistUrl = "S*" & app.base64.encode(glist)
		else
			CGlistUrl = glist
		end if
	end function
	Sub salesreport_needdo
		If request("__msgid") <> "" Then
			Response.clear
			Response.charset="UTF-8"
			Response.clear
		end if
		Dim v1,v2,needcfm,t2,t1
		v1=app.getint("v1")
		v2=app.GetText("v2")
		If isdate(v2)=False Then v2=date
		If v1>0 Then
			If v1=4 Then
				v2=DateAdd("d",-1,cdate(v2))
'If v1=4 Then
			else
				v2=DateAdd("d",1,cdate(v2))
			end if
		end if
		If isdate(v2) Then t2=" and datediff(d,stime,'"&v2&"')>=0 "
		Dim glist
		glist=GateGroupOrd_QX(1,1,3)
		Response.write "" & vbcrlf & "     <input type=""hidden"" name=""hiddenflagdate0"" id=""hiddenflagdate_0""  value="""
		Response.write v2
		Response.write """>" & vbcrlf & "        <table class=""resetBorderColor""  style=""BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; WORD-BREAK: break-all;table-layout:fixed;BORDER-BOTTOM: #c0ccdd 1px solid; BORDER-LEFT: #c0ccdd 1px solid; BORDER-TOP: #c0ccdd 1px solid; BORDER-RIGHT: #c0ccdd 1px solid"" cellPadding=3 width=""100%"">" & vbcrlf & "              <tr align=""left"">" & vbcrlf & "                 <td class=""resetBorderColor resetFirstTableBg"" style=""text-align:left;"" height=""26"" width=""100%"" align=middle>" & vbcrlf & "                          <div style=""text-align:left"">" & vbcrlf & "                             <span style=""padding:5px;font-weight:bold;vertical-align:middle"">待办事项分析</span>" & vbcrlf & "                         <span style=""padding:5px;margin-left:300px;vertical-align:middle"">" & vbcrlf & "                                "
		'Response.write v2
		If datediff("d",date,v2)>0 then
			Response.write "" & vbcrlf & "                             <a href=""javascript:void(0);"" onClick=""document.getElementById('hiddenflag_0').value=4;getneeddolist();""> <img class=""resetElementHidden"" src=""../images/main_2.gif"" width=""8"" height=""8"" border=""0"" /><img class=""resetElementShowNoAlign"" style=""display:none"" src=""../skin/default/images/ico16/lvwbar_2.png"" width=""8"" height=""8"" border=""0"" /> 前一天</a>" & vbcrlf & "                                "
		end if
		Response.write "" & vbcrlf & "                             <input type=""text"" class=""smdate"" value="""
		Response.write v2
		Response.write """ onchange='document.getElementById(""hiddenflag_0"").value=0;document.getElementById(""hiddenflagdate_0"").value=this.value;getneeddolist();' align=""absMiddle"" border=""0"" id=""daysOfMonth1Pos"" name=""daysOfMonth1Pos"" onMouseUp=""datedlg.show()"" minDate="""
		Response.write date
		Response.write """ style=""MARGIN-TOP:0px; HEIGHT:22px!important;width:101px; line-height:22px; padding-top:0px;"" readOnly />  " & vbcrlf & "                               </span>" & vbcrlf & "                         <a href=""javascript:void(0);"" onClick=""document.getElementById('hiddenflag_0').value=5;getneeddolist();"">后一天 <img class=""resetElementHidden"" src=""../images/main_1.gif"" width=""8"" height=""8"" border=""0"" /><img class=""resetElementShowNoAlign"" style=""display:none"" src=""../skin/default/images/ico16/lvwbar_3.png"" width=""8"" height=""8"" border=""0"" /></a>" & vbcrlf & "                         </div>" & vbcrlf & "                  </td>" & vbcrlf & "           </tr>"& vbcrlf &  "           <tr>   "& vbcrlf &"                   <td  colspan=""4"" style=""padding-left:30px;padding-top:32px""> "& vbcrlf &"                                 <table class=""resetBorderColor"" width=""100%"" border=""0"" cellpadding=""5"" cellspacing=""1"" bgcolor=""#CCC""  style=""BORDER-COLLAPSE: separate; WORD-WRAP: break-word; WORD-BREAK: break-all;table-layout:fixed"" border=""0"" cellPadding=""3"" width=""100%"" >" & vbcrlf & "                         "
		'Response.write date
		Dim imid(),imname() , ishave
		Dim im_rs,im_i,im_more,sbound
		im_more=False
		im_i=0
		ReDim imid(im_i)
		ReDim imname(im_i)
		ishave = False
		Set im_rs=cn.execute("select top 4 ord,sort1 from sort10 WITH(NOLOCK) where del=1 order by gate2 desc,ord")
		If im_rs.eof = False Then
			ishave = True
			Do While im_rs.eof=False
				ReDim Preserve imid(im_i)
				ReDim Preserve imname(im_i)
				imid(im_i)=im_rs("ord")
				imname(im_i)=im_rs("sort1")
				If im_i>2 Then im_more=True
				im_i=im_i+1
				If im_i>2 Then im_more=True
				im_rs.movenext
			Loop
			sbound = ubound(imname)
		else
			sbound = -1
			sbound = ubound(imname)
		end if
		im_rs.close : Set im_rs=Nothing
		Response.write "" & vbcrlf & "                               <tr align=""center""  >" & vbcrlf & "                                   "
		If ishave = True Then
			Response.write "<td class=""resetHeadBg"" style=""width:27%;background-color: #EEF2FD"" colspan="""
'If ishave = True Then
			Response.write app.iif(sbound+1>2,3,sbound+1)
'If ishave = True Then
			Response.write """>要事提醒</td>"
		end if
		Response.write "" & vbcrlf & "                                     <td style=""width:9%;background-color:#ffffff"" rowspan=""2"">新客户</td>" & vbcrlf & "                                       <td style=""width:9%;background-color:#ffffff"" rowspan=""2"">推荐联系</td>" & vbcrlf & "                                     <td style=""width:9%;background-color:#ffffff"" rowspan=""2"">即将收回</td>" & vbcrlf & "                                     <td style=""width:9%;background-color:#ffffff"" rowspan=""2"">保护客户</td>" & vbcrlf & "                                       <td style=""width:9%;background-color:#ffffff"" rowspan=""2"">保护即将到期</td>" & vbcrlf & "                                 <td class=""resetHeadBg"" style=""width:18%;background-color: #EEF2FD"" colspan=""2"">客户审批</td>" & vbcrlf & "                                 "
		'Response.write """>要事提醒</td>"
		If app.power.existsModel(7000) then
			Response.write "" & vbcrlf & "                                     <td style=""width:9%;background-color:#ffffff"" rowspan=""2"">合同审批</td>" & vbcrlf & "                                     "
'If app.power.existsModel(7000) then
		end if
		Response.write "" & vbcrlf & "                               </tr> " & vbcrlf & "                                  <tr align=""center""  >" & vbcrlf & "                                   "
		If sbound >= 0 Then Response.write "<td width='8%'  class='name resetHeadBg' style='background-color: #EEF2FD'>" & imname(0) & "</td>"
		If sbound >= 1 Then Response.write "<td width='8%'  class='name resetHeadBg' style='background-color: #EEF2FD'>" & imname(1) & "</td>"
		If sbound >= 2 Then
			Response.write "<td width='8%'  class='name resetHeadBg' style='background-color: #EEF2FD;text-align:center'><span style='margin-left:5px;'>" & imname(2) & "</span>"
'If sbound >= 2 Then
			If im_more Then
				Response.write "<span style='margin-left:5px;'>" & openbuttonT("<img class='resetElementHidden' src='../images/main_1.gif' width='8' height='8' border='0' /><img class='resetElementShowNoAlign' style='display:none' src='../skin/default/images/ico16/lvwbar_3.png' width='8' height='8' border='0' />","salecenter_imsg.asp?v2="&v2&"&w31="&CGlistUrl(glist),1200,600,150,150,"更多要事提醒") & "</span>"
			end if
			Response.write "</td>"
		end if
		Response.write "" & vbcrlf & "                                     <td width=""9%"" class=""resetHeadBg"" style=""background-color: #EEF2FD"">新增</td>" & vbcrlf & "                                        <td width=""9%"" class=""resetHeadBg"" style=""background-color: #EEF2FD"">领用</td>" & vbcrlf & "                                  </tr>" & vbcrlf & "                           <tr style=""text-align:center;background-color:#FFFFFF"">" & vbcrlf & "                                 "
		If ishave = True Then
			Response.write "" & vbcrlf & "                                             <td style=""background-color: #FFFFFF"" >" & vbcrlf & "                                           "
'If ishave = True Then
			needcfm=0
			needcfm=cn.execute("select count(1) from importantMsg WITH(NOLOCK) where exists(select 1 from tel WITH(NOLOCK) where ord=importantMsg.t_ord and sort3=1 and del=1) and  metype="&imid(0)&" and state=1 and ecateid in(" & glist & ")" & t2)(0).value
			ift0 needcfm,"alt_list.asp?metype="&imid(0)&"&t2=" & v2 & "&complete=1&open=1&ecateid=" & CGlistUrl(glist) & "","待联"
			Response.write "" & vbcrlf & "                                             <IMG style=""CURSOR: hand"" onClick=""ajax.regEvent('showperson1');ajax.addParam('partid', '0');ajax.addParam('v2', '"
			Response.write v2
			Response.write "');showDlgDiv(ajax.send());"" border=0 src=""../images/116.png"" title=""点击查看更多"">" & vbcrlf & "                                           </td>" & vbcrlf & "                                           "
			If sbound>=1 then
				Response.write "" & vbcrlf & "                                             <td >" & vbcrlf & "                                           "
				needcfm=0
				needcfm=cn.execute("select count(1) from importantMsg WITH(NOLOCK) where exists(select top 1 1 from tel WITH(NOLOCK) where ord=importantMsg.t_ord and sort3=1 and del=1)  and metype="&imid(1)&" and state=1 and ecateid in(" & glist & ")" & t2)(0).value
				ift0 needcfm,"alt_list.asp?metype="&imid(1)&"&t2=" & v2 & "&complete=1&open=1&ecateid=" & CGlistUrl(glist) & "","待邮"
				Response.write "" & vbcrlf & "                                             <IMG style=""CURSOR: hand"" onClick=""ajax.regEvent('showperson2');ajax.addParam('partid', '0');ajax.addParam('v2', '"
				Response.write v2
				Response.write "');showDlgDiv(ajax.send());"" border=0 src=""../images/116.png"" title=""点击查看更多"">" & vbcrlf & "                                           </td>" & vbcrlf & "                                           "
			end if
			If sbound>=2 then
				Response.write "" & vbcrlf & "                                             <td >"
				needcfm=0
				needcfm=cn.execute("select count(1) from importantMsg WITH(NOLOCK) where exists(select top 1 1 from tel WITH(NOLOCK) where ord=importantMsg.t_ord and sort3=1 and del=1) and metype="&imid(2)&" and state=1 and ecateid in(" & glist & ")" & t2)(0).value
				ift0 needcfm,"alt_list.asp?metype="&imid(2)&"&t2=" & v2 & "&complete=1&open=1&ecateid=" & CGlistUrl(glist) & "","待查"
				Response.write "" & vbcrlf & "                                             <IMG style=""CURSOR: hand"" onClick=""ajax.regEvent('showperson3');ajax.addParam('partid', '0');ajax.addParam('v2', '"
				Response.write v2
				Response.write "');showDlgDiv(ajax.send());"" border=0 src=""../images/116.png"" title=""点击查看更多"">" & vbcrlf & "                                           </td>" & vbcrlf & "                                           "
			end if
		end if
		Response.write "" & vbcrlf & "                                     <td class=""name"" style=""background-color: #FFFFFF"" >"
		needcfm=0
		needcfm=cn.execute("select count(1) from tel WITH(NOLOCK) where (cateid in(" & glist & ") and datediff(d,date2,'"&v2&"')=0) and isnull(sp,0)=0 and del=1 and sort3=1 and isnull((select top 1 1 from reply WITH(NOLOCK) where ord=tel.ord and sort1=1 and del=1 and date7>tel.date2),0)=0" )(0).value
		ift0 needcfm,"telhy.asp?H=31&W31="& CGlistUrl(glist) &"&salestype=4&Center_t2=" & v2 &"","新客户"
		Response.write "" & vbcrlf & "                                     <IMG style=""CURSOR: hand"" onClick=""ajax.regEvent('salesreport_tellist');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv('<div><img src=../images/loading2.gif border=0></div>');ajax.send(function(r){document.getElementById('showDlgDivObj').innerHTML = r;});"" border=0 src=""../images/116.png"" title=""点击查看更多"">" & vbcrlf & "                                        </td>" & vbcrlf & "                                   <td style=""background-color: #FFFFFF"">" & vbcrlf & "                                           "
		ift0 getTelList(glist,v2),"telhy.asp?H=31&salestype=5&W31="& CGlistUrl(glist) &"&Center_t2=" & v2 &"","推荐联系"
		Response.write "" & vbcrlf & "                                             <IMG style=""CURSOR: hand"" onClick=""ajax.regEvent('salesreport_tellist2');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv('<div><img src=../images/loading2.gif border=0></div>');ajax.send(function(r){document.getElementById('showDlgDivObj').innerHTML = r;});"" border=0 src=""../images/116.png"" title=""点击查看更多"">" & vbcrlf & "                                        </td>" & vbcrlf & "                                   <td class=""name"" style=""background-color: #FFFFFF""  >" & vbcrlf & "                                               "
		ift0 getbacktel(glist,v2),"telhy.asp?H=31&salestype=6&W31="& CGlistUrl(glist) &"&Center_t2=" & v2 &"","即将收回"
		Response.write "" & vbcrlf & "                                             <IMG style=""CURSOR: hand"" onClick=""ajax.regEvent('salesreport_tellist3');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv('<div><img src=../images/loading2.gif border=0></div>');ajax.send(function(r){document.getElementById('showDlgDivObj').innerHTML = r;});"" border=0 src=""../images/116.png"" title=""点击查看更多"">" & vbcrlf & "                                                <SPAN style=""POSITION: absolute; MARGIN-LEFT: -200px;z-index:1;"" id=""tellist3""></span>" & vbcrlf & "                                   </td>" & vbcrlf & "                                   <td  style=""background-color: #FFFFFF"" >" & vbcrlf & "                                  "
		Response.write v2
		needcfm=0
		needcfm=cn.execute("select count(*) from tel WITH(NOLOCK) where profect1=1 and cateid in("& glist &") and sort3=1 and del=1 and isnull(sp,0)=0")(0).value
		ift0 needcfm,"telhy.asp?H=31&w31=" & CGlistUrl(glist) & "&salestype=10&lie_3=10","保护客户"
		Response.write "" & vbcrlf & "                                     <span style=""CURSOR: hand"" onClick=""ajax.regEvent('showperson7');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/person_group.png"" border=0></span>&nbsp;<span style=""CURSOR: hand"" onClick=""ajax.regEvent('report_sort5');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/category.png"" border=0></span>" & vbcrlf & "                                 </td>" & vbcrlf & "                                   <td class=""name"" style=""background-color: #FFFFFF"" >" & vbcrlf & "                                        "
		Response.write v2
		needcfm=0
		needcfm=cn.execute("select count(1) from tel WITH(NOLOCK) where profect1=1 and datediff(d,'" & v2 & "',datepro+(select isnull(num2,0) from num_bh WITH(NOLOCK) where kh=tel.sort1 and cateid=tel.cateid))<=(select isnull(num3,0) from num_bh WITH(NOLOCK) where kh=tel.sort1 and cateid=tel.cateid) and cateid in("& glist &") and del=1 and isnull(sp,0)=0 and sort3=1")(0).value
		ift0 needcfm,"telhy.asp?lie_3=10&H=31&salestype=11&Center_t2=" & v2 &"&w31=" & CGlistUrl(glist) & "","保护即将到期"
		Response.write "" & vbcrlf & "                                     <span style=""CURSOR: hand"" onClick=""ajax.regEvent('showperson8');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/person_group.png"" border=0></span>&nbsp;<span style=""CURSOR: hand"" onClick=""ajax.regEvent('report_sort6');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0><img src=""../images/category.png"" border=0 title=""点击查看更多""></span>" & vbcrlf & "                                 </td>" & vbcrlf & "                                   <td class=""name"">" & vbcrlf & "                                 "
		needcfm=0
		needcfm=cn.execute("select count(1) from tel WITH(NOLOCK) where datediff(d,date1,'" & v2 & "')>=0 and (isnull(sp,0)>0 or isnull(sp,0)=-1) and  del=1 and  sort3=1 and  cateadd in  ("&glist&")")(0).value
		needcfm=0
		ift0 needcfm,"teltop_sp.asp?H=31&v2="&v2&"&w31=" & CGlistUrl(glist) & "","新增"
		Response.write "" & vbcrlf & "                                     <IMG style=""CURSOR: hand"" onClick=""ajax.regEvent('showperson4');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 src=""../images/116.png"" title=""点击查看更多"">" & vbcrlf & "                                   </td>" & vbcrlf & "                                   <td class=""name"">" & vbcrlf & "                                 "
		needcfm=0
		needcfm=cn.execute("select count(1) from tel WITH(NOLOCK) where datediff(d,date2,'" & v2 & "')>=0 and isnull(sp,0)=0 and del=1 and  sort3=1 and  order1 =3 and cateid4 in("&glist&")")(0).value
		ift0 needcfm,"teltop.asp?H=31&G=3&v2="&v2&"&w31=" & CGlistUrl(glist),"领用"
		Response.write "" & vbcrlf & "                                     <IMG style=""CURSOR: hand"" onClick=""ajax.regEvent('showperson5');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 src=""../images/116.png"" title=""点击查看更多"">" & vbcrlf & "                                   </td>" & vbcrlf & "                                   "
		If app.power.existsModel(7000) then
			Response.write "" & vbcrlf & "                                     <td class=""name"">" & vbcrlf & "                                 "
			Dim allpower : allpower = Abs(app.power.existsPowerIntro(5,1,-1))
			glist=GateGroupOrd_QX(5,1,3)
			needcfm=0
			needcfm=cn.execute("select count(1) from contract WITH(NOLOCK) where del<>2 and isnull(status,-1) not in (-1,0,1) and (1=" & allpower & " or cateid in("&glist&"))")(0).value
			needcfm=0
			ift0 needcfm,"../contract/planall.asp?sp=1&H=31&v2=" & v2 &"&w31=" & CGlistUrl(glist),"合同审批"
			Response.write "" & vbcrlf & "                                     <IMG style=""CURSOR: hand"" onClick=""ajax.regEvent('showperson6');ajax.addParam('partid', '0');ajax.addParam('v2', '"
			Response.write v2
			Response.write "');showDlgDiv(ajax.send());"" border=0 src=""../images/116.png"" title=""点击查看更多"">" & vbcrlf & "                                   "
		end if
		Response.write "" & vbcrlf & "                                     </td>" & vbcrlf & "                             </tr>" & vbcrlf & "                         </table>" & vbcrlf & "                        </td>" & vbcrlf & "           </tr>" & vbcrlf & "   </table>" & vbcrlf & "        "
	end sub
	Sub salesreport_report
		If request("__msgid") <> "" then
			Response.clear
			Response.charset="UTF-8"
			Response.clear
		end if
		Dim v1,v2,needcfm,t2,reportweek,reportmonth,rs
		v1=app.getInt("v1")
		v2=app.getText("v2")
		If isdate(v2)=False Then v2=date
		If v1>0 Then
			If v1=4 Then
				v2=DateAdd("d",-1,cdate(v2))
'If v1=4 Then
			else
				v2=DateAdd("d",1,cdate(v2))
			end if
		end if
		If isdate(v2) Then t2=" and datediff(d,stime,'"&v2&"')=0 "
		Dim glist
		glist=GateGroupOrd(3)
		Response.write "" & vbcrlf & "     <input type=""hidden"" name=""hiddenflagdate_2"" id=""hiddenflagdate2""  value="""
		Response.write v2
		Response.write """>" & vbcrlf & "        <table class=""resetBorderColor"" style=""BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; WORD-BREAK: break-all;table-layout:fixed;BORDER-BOTTOM: #c0ccdd 1px solid; BORDER-LEFT: #c0ccdd 1px solid; BORDER-TOP: #c0ccdd 1px solid; BORDER-RIGHT: #c0ccdd 1px solid"" border=0 cellPadding=3 width=""100%"">" & vbcrlf & "                <tr align=""left"" class=""top"" style=""height:30px;"">" & vbcrlf & "                  <td  class=""resetBorderColor resetTableBg"" style=""text-align:left"" height=""26"" width=""100%"" align=middle>" & vbcrlf & "                               <div style=""text-align:left;float:left"">" & vbcrlf& "                               <span style=""padding:5px;margin-left:10px;font-weight:bold;"">销售跟进分析</span>" & vbcrlf & "                          <span style=""margin-left:300px;"">" & vbcrlf & "                         <a href=""#"" onClick=""document.getElementById('hiddenflag_2').value=4;getreportlist();""> <img class=""resetElementHidden"" src=""../images/main_2.gif"" width=""8"" height=""8"" border=""0"" /><img class=""resetElementShowNoAlign"" style=""display:none"" src=""../skin/default/images/ico16/lvwbar_2.png"" width=""8"" height=""8"" border=""0"" /> 前一天 </a></span>" & vbcrlf & "                         <span style=""padding:5px"">" & vbcrlf & "                                <input type=""text"" class=""smdate"" value="
		Response.write v2
		Response.write """ onchange='document.getElementById(""hiddenflag_2"").value=0;document.getElementById(""hiddenflagdate2"").value=this.value;getreportlist();' align=""absMiddle""  border=""0""  id=""daysOfMonth1Pos"" name=""daysOfMonth1Pos""  onmouseup=""datedlg.show()"" style=""MARGIN-TOP: 0px; HEIGHT:22px!important;width:101px; line-height:22px!important;top:4px; padding-top:0px;"" readOnly type=text />" & vbcrlf & "                                </span>" & vbcrlf & "                         <a href=""#"" onClick=""document.getElementById('hiddenflag_2').value=5;getreportlist();"">后一天 <img class=""resetElementHidden"" src=""../images/main_1.gif"" width=""8"" height=""8"" border=""0"" /><img class=""resetElementShowNoAlign"" style=""display:none"" src=""../skin/default/images/ico16/lvwbar_3.png"" width=""8"" height=""8"" border=""0"" /></a>" & vbcrlf & "                             <DIV id=daysOfMonth1 style=""POSITION: absolute""></div>" & vbcrlf & "                            </div>" & vbcrlf & "                            <div style=""float:right;right:10px;position:absolute;"">" & vbcrlf & "                                   "
		If app.power.existsPower(1,17) Then
			Response.write openbutton1("人员变更","salesChangeList.asp",1200,500,150,150)
			Response.write openbutton1("阶段变更","sortChangeList.asp",1200,500,150,150)
			Response.write openbutton1("销售推进记录","salesProcessList.asp",1440,500,0,150)
		end if
		Response.write "" & vbcrlf & "                             </div>" & vbcrlf & "                  </td>" & vbcrlf & "             </tr>" & vbcrlf & "           <tr>  " & vbcrlf & "            <td  colspan=""4"" valign=""center"" style=""padding-left:27px"">" & vbcrlf & "                               <table width=""100%"" border=""0"" cellpadding=""5"" cellspacing=""1"" class=""home""border-collapse: collapse; style=""border-collapse: collapse;"">" & vbcrlf & "                                 <tr align=""center"" >" & vbcrlf & "                                    <td width=""8%""  style=""background-color: #FFFFFF"" colspan=""2"">当天新增</td>" & vbcrlf & "                                   <td width=""8%"" style=""background-color:#ffffff""  colspan=""2"" rowspan=""2"">当天联系</td>" & vbcrlf & "                                        <td width=""16%""  style=""background-color: #FFFFFF"" colspan=""3"">当天推进</td>" & vbcrlf & "                                  <td width=""8%"" style=""width:9%;background-color:#ffffff"" rowspan=""2"">当天回收</td>" & vbcrlf & "                              </tr>" & vbcrlf & "                           <tr align=""center"" >" & vbcrlf & "                                    <td width=""8%""  style=""background-color: #FFFFFF"">添加</td> "& vbcrlf &"                                        <td width=""8%""  style=""background-color: #FFFFFF"">领用</td> "& vbcrlf &"                                  <td width=""8%""  style=""background-color: #FFFFFF"">前进</td> "& vbcrlf &"                                  <td width=""8%""  style=""background-color: #FFFFFF"">后退</td> "& vbcrlf & "                                      <td width=""8%""  style=""background-color: #FFFFFF"">原地</td>" & vbcrlf & "                           </tr>" & vbcrlf & "                           <tr style=""text-align:center"">" & vbcrlf & "                                  <td width=""8%"" style=""background-color:#ffffff""  >" & vbcrlf & "                                  "
		Response.write openbutton1("销售推进记录","salesProcessList.asp",1440,500,0,150)
		needcfm=0
		needcfm=cn.execute("select count(1) from tel WITH(NOLOCK) where  datediff(d,date1,'" & v2 & "')=0 and isnull(sp,0)=0 and del=1 and sort3=1 and cateadd in(" & glist &")" )(0).value
		ift0 needcfm,"telhy.asp?H=31&salestype=33&Center_t2=" & v2 & "&W31="&glist&"","当天新增添加"
		Response.write " " & vbcrlf & "                                    <span style=""CURSOR: hand"" onClick=""ajax.regEvent('report_person1');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/person_group.png"" border=0></span>" & vbcrlf & "                                     <span style=""CURSOR: hand"" onClick=""ajax.regEvent('report_sort1');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/category.png"" border=0></span>" & vbcrlf & "                                 </td>" & vbcrlf & "                                   <td width=""8%""  style=""background-color:#ffffff""   >" & vbcrlf & "                                        "
		Response.write v2
		needcfm=0
		needcfm=cn.execute("select count(1) from tel WITH(NOLOCK) where  datediff(d,date2,'" & v2 & "')=0 and isnull(sp,0)=0 and del=1 and sort3=1 and cateid in(" & glist &")")(0).value
		ift0 needcfm,"telhy.asp?H=31&salestype=34&Center_t2=" & v2 & "&w31="&glist&"","当天新增领用"
		Response.write "" & vbcrlf & "                                     <span style=""CURSOR: hand;"" onClick=""ajax.regEvent('report_person2');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/person_group.png"" border=0></span>" & vbcrlf & "                                     <span style=""CURSOR: hand;"" onClick=""ajax.regEvent('report_apply');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/type.png"" border=0></span>" & vbcrlf & "                                     <span style=""CURSOR: hand;"" onClick=""ajax.regEvent('report_sort2');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/category.png"" border=0></span>" & vbcrlf & "                                 " & vbcrlf & "                                        </td>" & vbcrlf & "                                   <td width=""8%""  style=""background-color:#ffffff"" colspan=""2""  >"
		Response.write v2
		needcfm=0
		needcfm=cn.execute("select count(distinct(ord)) from reply WITH(NOLOCK) where sort1=1 and cateid in(" & glist & ") and del=1 and ord in(select ord from tel WITH(NOLOCK) where del=1 and isnull(sp,0)=0 and sort3=1 and cateid=reply.cateid) and datediff(d,date7,'" & v2 & "')=0 ")(0).value
		ift0 needcfm,"telhy.asp?H=31&salestype=32&Center_t2=" & v2 & "&W31="&glist&"","当天联系"
		Response.write "" & vbcrlf & "                                     <span style=""CURSOR: hand"" onClick=""ajax.regEvent('report_person3');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/person_group.png"" border=0></span>" & vbcrlf & "                                     <SPAN style=""POSITION: absolute; MARGIN-LEFT: 0px:z-index:5;"" id=""report_person3""></span>" & vbcrlf & "                                   <span style=""CURSOR: hand"" onClick=""ajax.regEvent('report_sort3');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/category.png"" border=0></span>" & vbcrlf & "                                 </td>" & vbcrlf & "                                   <td width=""8%""  style=""background-color:#ffffff""   >"
		Response.write v2
		needcfm=0
		needcfm=cn.execute("select count(distinct(a.tord)) from [tel_sort_change_log] a WITH(NOLOCK) inner join tel b on a.tord=b.ord where a.state=1 and b.del=1 and isnull(b.sp,0)=0 and b.sort3=1 and a.id in(select max(id) from [tel_sort_change_log] WITH(NOLOCK) where cateid in(" & glist & ") and datediff(d,date7,'" & v2 &"')=0 group by tord)")(0)
		ift0 needcfm,"telhy.asp?lie_2=5&H=30&salestype=1&w31=" & CGlistUrl(glist) & "&Center_t2=" & v2 & "","前进"
		Response.write "" & vbcrlf & "                                     <span style=""CURSOR: hand"" onClick=""ajax.regEvent('report_person4');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/person_group.png"" border=0></span>" & vbcrlf & "                                     </td>" & vbcrlf & "                                   <td width=""8%""  style=""background-color:#ffffff""   >"
		Response.write v2
		needcfm=0
		needcfm=cn.execute("select count(distinct(a.tord)) from [tel_sort_change_log] a WITH(NOLOCK) inner join tel b on a.tord=b.ord where a.state=-1 and b.del=1 and isnull(b.sp,0)=0 and b.sort3=1 and a.id in(select max(id) from [tel_sort_change_log] WITH(NOLOCK) where cateid in(" & glist & ") and datediff(d,date7,'" & v2 &"')=0 group by tord)")(0)
		ift0 needcfm,"telhy.asp?lie_2=5&H=30&salestype=2&w31=" & CGlistUrl(glist) & "&Center_t2=" & v2 & "","后退"
		Response.write "" & vbcrlf & "                                     <span style=""CURSOR: hand"" onClick=""ajax.regEvent('report_person5');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/person_group.png"" border=0></span>" & vbcrlf & "                                     </td>" & vbcrlf & "                                   <td width=""8%""  style=""background-color:#ffffff"">"
		Response.write v2
		needcfm=0
		needcfm=cn.execute("select count(distinct(a.tord)) from [tel_sort_change_log] a WITH(NOLOCK) inner join tel b on a.tord=b.ord inner join (select max(id) as maxid from [tel_sort_change_log] WITH(NOLOCK) where cateid in(" & glist & ") and datediff(d,date7,'" & v2 &"')=0 group by tord) z on a.id=z.maxid where a.state=0 and b.del=1 and isnull(b.sp,0)=0 and b.sort3=1")(0)
		ift0 needcfm,"telhy.asp?lie_2=5&H=30&salestype=3&w31=" & CGlistUrl(glist) & "&Center_t2=" & v2 & "","原地"
		Response.write "" & vbcrlf & "                                     <span style=""CURSOR: hand"" onClick=""ajax.regEvent('report_person6');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/person_group.png"" border=0></span>" & vbcrlf & "                                     </td>" & vbcrlf & "                                   <td width=""8%""  style=""background-color:#ffffff""  >" & vbcrlf & "                                         "
		Response.write v2
		needcfm=0
		needcfm=cn.execute("select count(1) from tel_sales_change_log where precateid in(" & glist & ") and reason=4 and datediff(d,date7,'" & v2 &"')=0")(0).value
		ift0 needcfm,"saleschangeList.asp?cateid=" & glist & "&e_ret=" & v2 & "&e_ret2=" & v2 & "&conditions2=4","当天回收"
		Response.write "" & vbcrlf & "                                     <span style=""CURSOR: hand"" onClick=""ajax.regEvent('report_person7');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/person_group.png"" border=0></span>" & vbcrlf & "                                     <SPAN style=""POSITION: absolute; MARGIN-LEFT: 0px;z-index:5;"" id=""report_person7""></span>" & vbcrlf & "                                   <span style=""CURSOR: hand"" onClick=""ajax.regEvent('report_backtype');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/type.png"" border=0></span>" & vbcrlf & "                                       <SPAN style=""POSITION: absolute; MARGIN-LEFT: 0px;z-index:5;"" id=""report_backtype""></span>" & vbcrlf & "                                  <span style=""CURSOR: hand"" onClick=""ajax.regEvent('report_sort4');ajax.addParam('partid', '0');ajax.addParam('v2', '"
		Response.write v2
		Response.write "');showDlgDiv(ajax.send());"" border=0 title=""点击查看更多""><img src=""../images/category.png"" border=0></span>" & vbcrlf & "                                   <SPAN style=""POSITION: absolute; MARGIN-LEFT: 0px;z-index:5;"" id=""report_sort4""></span>" & vbcrlf & "                                     </td>" & vbcrlf & "                             </tr>" & vbcrlf & "                         </table>"& vbcrlf & "                        </td>" & vbcrlf & "           </tr>" & vbcrlf & "   </table>" & vbcrlf & "        <table  style=""BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; WORD-BREAK: break-all;width:1200px"" border=""0"" cellPadding=3 align=center>" & vbcrlf & " <tr>" & vbcrlf & "    <td align=""center"">" & vbcrlf & "       <div style='position:relative;height:300px'>" & vbcrlf & "     "
		Dim v : Set v = New VmlGraphics
		Set rs = cn.execute("select top 10 * from (select name,gate.ord as userid,(select count(1) from tel WITH(NOLOCK) where cateadd in (" & glist &") and cateadd=gate.ord and datediff(d,date1,'" & v2 & "')=0 and isnull(sp,0)=0 and del=1 and sort3=1) as ord from gate WITH(NOLOCK) where del=1 and ord in (& glist &) ) e order by ord desc,name asc")
		v.width = 580
		v.id = "aa"
		v.height = 300
		v.title = "客户新增TOP10"
		v.url="@../work/telhy.asp?H=31&salestype=33&Center_t2="&v2&"&w31=@ord"
		v.loadDataByRecord rs
		v.draw "pie"
		rs.close
		Response.write "</div>"
		Response.write "" & vbcrlf & "      </td>" & vbcrlf & "   <td style=""text-align:center;"">" & vbcrlf & "   <div style='position:relative;height:300px;margin-left:10px'>" & vbcrlf & "   "
		Response.write "</div>"
		Dim csql
		csql="select top 10 y.name,y.ord as userid, x.rcount as ord from gate y WITH(NOLOCK) left join (select cateid, count(ord) as rcount from (select  distinct a.cateid, a.ord from reply a WITH(NOLOCK) inner join tel b WITH(NOLOCK) on a.ord=b.ord and a.cateid=b.cateid and b.del=1 and b.sort3=1 and isnull(b.sp,0)=0 and b.cateid in(" & glist & ") where a.del=1 and a.sort1=1 and datediff(d,a.date7,'" & v2 & "')=0 ) t group by cateid ) x on x.cateid = y.ord where y.del=1 and ord in (" & glist &") order by rcount desc, y.name asc"
		Set v = New VmlGraphics
		Set rs = cn.execute(csql)
		v.width = 580
		v.id = "bb"
		v.height = 300
		v.title = "客户跟进TOP10"
		v.url="@../work/telhy.asp?H=36&Center_t2="&v2&"&w3=@ord"
		v.loadDataByRecord rs
		v.draw "pie"
		rs.close
		Response.write "</div></td></tr></table>"
	end sub
	Sub salereports
		Dim lvw
		Dim v1,v2,n, defv1, defv2
		v1=app.getText("v1")
		v2=app.getText("v2")
		defv1 = CDate(year(date)&"-"&month(date)&"-01")
		v2=app.getText("v2")
		defv2 = dateadd("d",-1,dateadd("m",1,CDate(year(now())&"-"&month(now())&"-01")))
		v2=app.getText("v2")
		If v1="" Then v1=defv1
		If v2="" Then v2=defv2
		Set lvw = New listview
		If CDate(v1) = defv1 And CDate(v2) = defv2 then
			lvw.CacheRules = "select cateid,date3,money2,ord,sp,del,bz from contract where del=1;select complete,money1,del,ord, date5, [contract] from payback where del=1;select * from sys_bill_TarSet;select ord from gate where del=1"
			lvw.CacheKeys = "home_report_SalesPerformance_sakesreports"
		end if
		lvw.sql = "exec home_report_SalesPerformance "&session("personzbintel2007")&",'','','','','','','','','','','','','','','','','','','"&v1&"','"&v2&"','','销售人员','asc'"
		lvw.checkbox = False
		lvw.indexbox = False
		lvw.CurrSum=True
		lvw.AllSum=True
		lvw.pagesize = 5
		lvw.addlink=""
		lvw.headers(1).display="none"
		lvw.zoreColor = "#C2C2C2"
		lvw.IsaccWidth=false
		For n=1 To 14
			If (app.power.existsModel(7000)) And n<9 Then
				If app.power.existsPower2(5,21) = false And n>2 And n<9  Then lvw.headers(n).display = "none"
				lvw.headers(n).width="92"
				lvw.IsaccWidth=true
			ElseIf (app.power.existsModel(23001)) And n>=9 Then
				If app.power.existsPower2(5,21) = false Then
					lvw.headers(n).width="184"
				else
					lvw.headers(n).width="92"
					lvw.IsaccWidth=true
				end if
			else
				lvw.headers(n).display="none"
			end if
		next
		lvw.headers(3).formattext = GetReportLinks("销售额业绩对比_今日成果",v1,v2)
		lvw.headers(4).formattext = GetReportLinks("销售额业绩对比_本月总计",v1,v2)
		lvw.headers(6).formattext = GetReportLinks("销售额业绩对比_上月同期",v1,v2)
		lvw.headers(8).formattext = GetReportLinks("销售额业绩对比_同期比较",v1,v2)
		lvw.headers(9).formattext = GetReportLinks("回款额业绩对比_今日成果",v1,v2)
		lvw.headers(10).formattext = GetReportLinks("回款额业绩对比_本月总计",v1,v2)
		lvw.headers(12).formattext = GetReportLinks("回款额业绩对比_上月同期",v1,v2)
		lvw.headers(14).formattext = GetReportLinks("回款额业绩对比_同期比较",v1,v2)
		Response.write lvw.HTML
	end sub
	Function GetReportLinks(f,v1,v2)
		Dim v3, v4
		Dim r , rs,sql,i
		v3 = dateadd("m", -1, v1)
'Dim r , rs,sql,i
		v4 = dateadd("m", -1, v2)
'Dim r , rs,sql,i
		Select Case f
		Case "销售额业绩对比_今日成果"
		r="../contract/planall.asp?tj=1&W3=@cells[1]&F1=1&G1=1&P1=1&I1=1&zdy1_1=1&&zdy2_1=1&zdy3_1=1&zdy4_1=1&ret="& date &" 00:00:00&ret2="& date &" 23:59:59"
		Case "销售额业绩对比_本月总计"
		r = "../contract/planall.asp?tj=1&W3=@cells[1]&F1=1&G1=1&P1=1&I1=1&zdy1_1=1&&zdy2_1=1&zdy3_1=1&zdy4_1=1&ret="& v1 &"&ret2="& v2 &""
		Case "销售额业绩对比_上月同期"
		r = "../contract/planall.asp?tj=1&W3=@cells[1]&F1=1&G1=1&P1=1&I1=1&zdy1_1=1&&zdy2_1=1&zdy3_1=1&zdy4_1=1&ret="& v3 &"&ret2="& v4 &""
		Case "销售额业绩对比_同期应完成"
		Case "销售额业绩对比_同期比较"
		r = "code:app.iif(@value < 0, ""<span style='color:green'>↓</span>""&replace(""@value"",""-"","""")&"""",app.iif(@value=0,""@value"",""<span style='color:red'>↑</span>"" & @value))"
		Case "销售额业绩对比_同期比较"
		Case "回款额业绩对比_同期比较"
		r = "code:app.iif(@value < 0, ""<span style='color:green'>↓</span>""&replace(""@value"",""-"","""")&"""",app.iif(@value=0,""@value"",""<span style='color:red'>↑</span>"" & @value))"
		Case "回款额业绩对比_同期比较"
		Case "回款额业绩对比_今日成果"
		r = "../money/planall2.asp?link=yes&W3=@cells[1]&hkzt=3&paydate1="&date&"&paydate2="&date
		Case "回款额业绩对比_本月总计"
		r = "../money/planall2.asp?link=yes&W3=@cells[1]&hkzt=3&paydate1="& v1 &"&paydate2="& v2 &""
		Case "回款额业绩对比_上月同期"
		r = "../money/planall2.asp?link=yes&W3=@cells[1]&hkzt=3&paydate1="& v3 &"&paydate2="& v4 &""
		Case "回款额业绩对比_同期应完成"
		Case else
		End Select
		If Len(r) > 0 Then
			if instr(1,r,".asp",1) = 0 then
				GetReportLinks = r
			else
				r = Convertlnk(Replace(r,"%2C",",",1,-1,1))
				GetReportLinks = r
				GetReportLinks = "<a href='" & r & "' target='_blank' class='rptlink'>@value</a>"
			end if
		else
			GetReportLinks=""
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
	Sub salereportsmap
		Dim v1,v2
		v1=app.getText("v1")
		v2=app.getText("v2")
		Dim glist,rs
		glist=GateGroupOrd_QX(5,1,3)
		If v1="" Then v1=CDate(year(date)&"-"&month(date)&"-01")
		glist=GateGroupOrd_QX(5,1,3)
		If v2="" Then v2=dateadd("d",-1,dateadd("m",1,CDate(year(now())&"-"&month(now())&"-01")))
		glist=GateGroupOrd_QX(5,1,3)
		Response.write "" & vbcrlf & "     <table  style=""BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; WORD-BREAK: break-all;width:1200px"" border=""0"" cellPadding=""3"" align=""center"">" & vbcrlf & " <tr>"
		glist=GateGroupOrd_QX(5,1,3)
		If app.power.existsModel(7000) then
			Response.write "" & vbcrlf & "             <td align=""center"">" & vbcrlf & "               <div style='position:relative;height:300px;'>" & vbcrlf & "           "
			Dim v : Set v = New VmlGraphics
			Set rs = cn.execute("select top 10 * from (select name,ord as Gord,(select dbo.formatNumber(sum(isnull(money2,0)),'" & Info.MoneyNumber & "',0) from contract WITH(NOLOCK) where del=1 and isnull(status,-1) in (-1,1) and cateid in("&glist&") and cateid=gate.ord and datediff(d,'" & v1 &"',date3)>=0 and datediff(d,date3,'" & v2 &"')>=0) as ord from gate WITH(NOLOCK) where del=1 and ord in (" & glist & ")) e order by CAST(isnull(ord,0) AS decimal(25,12)) desc,name asc")
			v.width = 580
			v.id = "aa3"
			v.height = 300
			v.title = "销售额 TOP 10"
			v.url="@../contract/planall.asp?tj=1&W3=@ord&ret="&v1&"&ret2="&v2&""
			v.loadDataByRecord rs
			v.draw "pie"
			rs.close
			Response.write "</div>"
			Response.write "</td>"
		end if
		If app.power.existsModel(23001) then
			Response.write "<td style=""text-align:center;"">" & vbcrlf & "                <div style='position:relative;height:300px;margin-left:10px'>" & vbcrlf & "           "
'If app.power.existsModel(23001) then
			glist=GateGroupOrd_QX(7,1,3)
			Set v = New VmlGraphics
			Set rs = cn.execute("select top 10  Max(a.name) as name,max(a.ord),CAST(dbo.formatNumber(sum(isnull(b.money1,0)*isnull(hl.hl,1)),'" & Info.MoneyNumber & "',0) AS money) as money from gate a WITH(NOLOCK) left join payback b WITH(NOLOCK) on b.del=1 and b.complete=3 and b.cateid=a.ord and datediff(d,'" & v1 &"',date5)>=0 and datediff(d,date5,'" & v2 &"')>=0 left join contract c WITH(NOLOCK) on b.contract=c.ord left join hl WITH(NOLOCK) on c.bz=hl.bz and c.date3=hl.date1 where a.del=1 and a.ord in("&glist&") group by a.ord order by money desc,name asc")
			v.width = 580
			v.id = "bb3"
			v.height = 300
			v.title = "回款额 TOP 10"
			v.url="@../money/planall2.asp?link=yes&W3=@ord&hkzt=3&paydate1="&v1&"&paydate2="&v2&""
			v.loadDataByRecord rs
			v.draw "pie"
			rs.close
			Response.write "</div></td>"
		end if
		Response.write "</tr></table>"
	end sub
	Sub tel_sort_list
		Dim rs,r,sort4,v,n
		Dim glist
		glist=GateGroupOrd(3)
		sort4=app.getint("sort4")
		If sort4=0 then
			Set rs=cn.execute("select top 1 isnull(report7,0) as report7 from salecenter where ord=" & Info.user)
			If rs.eof=False Then
				sort4=rs(0).value
			end if
		else
			Set rs=cn.execute("select top 1 isnull(report7,0) as report7 from salecenter where ord=" & Info.user)
			If rs.eof=False Then
				cn.execute("update salecenter set report7='"&sort4&"' where ord=" & Info.user)
			else
				cn.execute("insert into salecenter(ord,report7) values('"& Info.user &"','" & sort4 & "')")
			end if
		end if
		n=0
		Set rs=cn.execute("select sort1,ord from sort4 order by gate1 desc")
		r="<select name='sort4' onchange=""ajax.regEvent('tel_sort_list');ajax.addParam('sort4', this.value);document.getElementById('tel_sort_list').innerHTML=ajax.send();"">"
		Do While not rs.eof
			If n=0 And sort4=0 Then n=rs(1).value
			r=r&"<option value='"&rs(1).value&"'"
			If sort4&""=rs(1).value&"" Then r=r&" selected "
			r=r&">"&rs(0).value&"</option>"
			rs.movenext
		Loop
		r=r&"</select>"
		Response.write r
		If sort4>0 Then n=sort4
		Set v = New VmlGraphics
		Set rs = cn.execute("select top 10 max(b.sort2) as sort,max(b.gate2) as gate2 ,max(b.ord) as sort1,count(a.ord) from sort5 b WITH(NOLOCK) left join tel a WITH(NOLOCK) on a.sort=b.sort1 and a.sort1=b.ord and a.del=1 and isnull(a.sp,0)=0 and a.sort3=1 And a.cateid in("&glist&") where b.sort1="&n&" group by b.sort1,b.ord order by gate2 desc")
		v.width = 350
		v.id = "tel_sort_list"
		v.url = "@../work/telhy.asp?H=35&w3="&glist&"&sort="&n&"&sort1=@ord"
		v.height = 150
		v.title = "客户分布"
		v.loadDataByRecord rs
		v.draw "cone"
		rs.close
	end sub
	Sub report_person(stype)
		Dim f_rs,v2,v3,j_v3,vn,uid,fsql,t2,selpart,fsql1,fsql2
		v2=app.GetText("v2")
		If isdate(v2)=False Then v2=date
		Dim glist
		glist=GateGroupOrd(3)
		uid=session("personzbintel2007")
		vn=0
		If stype=4 Or stype=5 Or stype=6 Then vn=2
		Select Case stype
		Case 1:j_v3="当天新增："
		Case 2:j_v3="当天领用："
		Case 3:j_v3="当天联系："
		Case 4:j_v3="当天推进（前进）："
		Case 5:j_v3="当天推进（后退）："
		Case 6:j_v3="当天推进（原地）："
		Case 7:j_v3="当天回收："
		End Select
		Select Case stype
		Case 1,2,3,4,5,6,7: j_v3=j_v3 & "人员分布"
		End Select
		selpart=app.GetText("selpart")
		If selpart="clear" Then Response.end
		v3=v3 & "<div style='position:absolute;width:240px;"
		If stype=7 Then v3=v3&" margin-left:-230px; "
		v3=v3 & "<div style='position:absolute;width:240px;"
		Select Case stype
		Case 3,4,5,6: v3=v3&" margin-left:-130px; "
'Select Case stype
		End Select
		v3=v3 &"'><TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""500"" bgColor=#c0ccdd><TBODY>"
		v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><div style='float:left;font-weight:bold'>&nbsp;" & j_v3 & "</div><div style='float:right;cursor:pointer' onclick=""trycleardlgDiv()"">【关闭】&nbsp;</div></TD></tr>"
		v3=v3 &"'><TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""500"" bgColor=#c0ccdd><TBODY>"
		v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=center>" & v2  & "</DIV></TD></tr>"
		v3=v3 &"'><TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""500"" bgColor=#c0ccdd><TBODY>"
		Select Case stype
		Case 1:
		fsql="select count(1) from tel WITH(NOLOCK) where cateadd=gate.ord and datediff(d,date1,'" & v2 & "')=0 and isnull(sp,0)=0 and del=1 and sort3=1"
		Set f_rs=cn.execute("select ("&fsql&") as num,name,ord from gate WITH(NOLOCK) where del=1 and ord in("&glist&") order by sorce,sorce2" )
		If f_rs.eof = True Then
			v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center>人员</DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr style='height:20px;'><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"telhy.asp?H=31&salestype=33&Center_t2=" & v2 & "&W31=" & f_rs.fields(2).value & "") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 2:
		fsql="select count(1) from tel WITH(NOLOCK) where cateid=gate.ord and datediff(d,date2,'" & v2 & "')=0 and isnull(sp,0)=0 and del=1 and sort3=1"
		Set f_rs=cn.execute("select ("&fsql&") as num,name,ord from gate where del=1 and ord in("&glist&") order by sorce,sorce2" )
		If f_rs.eof = True Then
			v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center>人员</DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr style='height:20px;'><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"telhy.asp?H=31&salestype=34&Center_t2=" & v2 & "&W31=" & f_rs.fields(2).value & "") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 3:
		fsql = "select sum(sign(t.cateid)) as num , t2.name, t2.ord from gate t2 WITH(NOLOCK) left join (Select distinct b.cateid, b.ord From tel a WITH(NOLOCK) inner Join reply b WITH(NOLOCK) On a.del=1 and isnull(a.sp,0)=0 and a.sort3=1 And a.ord = b.ord And b.cateid in(" & glist & ") And b.del=1 and datediff(d,b.date7,'" & v2 & "')=0 and a.cateid=b.cateid) t on t.cateid = t2.ord where t2.ord in  (" & glist & ") group by t2.ord, t2.name,t2.sorce,t2.sorce2 order by t2.sorce,t2.sorce2"
		Set f_rs=cn.execute(fsql)
		If f_rs.eof = True Then
			v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center>人员</DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr style='height:20px;'><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"telhy.asp?H=31&salestype=32&Center_t2=" & v2 & "&W31=" & f_rs.fields(2).value & "") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 4,5,6:
		fsql="select count(distinct(a.tord)) from [tel_sort_change_log] a WITH(NOLOCK) inner join tel b WITH(NOLOCK) on a.tord=b.ord where a.cateid=gate.ord and a.state=1 and b.del=1 and isnull(b.sp,0)=0 and b.sort3=1 and a.id in(select max(id) from [tel_sort_change_log] WITH(NOLOCK) where cateid in(" & glist & ") and datediff(d,date7,'" & v2 &"')=0 group by tord)"
		fsql1="select count(distinct(a.tord)) from [tel_sort_change_log] a WITH(NOLOCK) inner join tel b WITH(NOLOCK) on a.tord=b.ord where a.cateid=gate.ord and a.state=-1 and b.del=1 and isnull(b.sp,0)=0 and b.sort3=1 and a.id in(select max(id) from [tel_sort_change_log] WITH(NOLOCK) where cateid in(" & glist & ") and datediff(d,date7,'" & v2 &"')=0 group by tord)"
		fsql2="select count(distinct(a.tord)) from [tel_sort_change_log] a WITH(NOLOCK) inner join tel b WITH(NOLOCK) on a.tord=b.ord where a.cateid=gate.ord and a.state=0 and b.del=1 and isnull(b.sp,0)=0 and b.sort3=1 and a.id in(select max(id) from [tel_sort_change_log] WITH(NOLOCK) where cateid in(" &glist & ") and datediff(d,date7,'" & v2 &"')=0 group by tord)"
		Set f_rs=cn.execute("select ("&fsql&") as num,("&fsql1&") as num1,("&fsql2&") as num2,name,ord from gate where del=1 and ord in("&glist&") order by sorce,sorce2" )
		If f_rs.eof = True Then
			v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 4+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		Else
			v3=v3 & "<tr class='top'><TD width=""25%""><DIV align=center>人员</DIV></TD><TD width=""25%"""
			If stype=4 Then v3=v3&" class='resetHeadBg' style='background-color:#EEF2FD'"
			v3=v3 & "<tr class='top'><TD width=""25%""><DIV align=center>人员</DIV></TD><TD width=""25%"""
			v3=v3 & "><DIV align=center> 前进 </DIV></TD><TD width=""25%"""
			If stype=5 Then v3=v3&" class='resetHeadBg' style='background-color:#EEF2FD'"
			v3=v3 & "><DIV align=center> 前进 </DIV></TD><TD width=""25%"""
			v3=v3 & "><DIV align=center> 后退 </DIV></TD><TD width=""25%"""
			If stype=6 Then v3=v3&" class='resetHeadBg' style='background-color:#EEF2FD'"
			v3=v3 & "><DIV align=center> 后退 </DIV></TD><TD width=""25%"""
			v3=v3 & "><DIV align=center> 原地 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr style='height:20px;'>"&_
				"<TD width=""25%""><DIV align=center>" & f_rs.fields(3).value & "</DIV></TD>"
				v3=v3 & "<TD width=""25%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"telhy.asp?lie_2=5&H=30&salestype=1&W31=" & f_rs.fields(4).value & "&Center_t2=" & v2 & "") & "</DIV></TD>"
				v3=v3 & "<TD width=""25%""><DIV align=center>" & returnnum(f_rs.fields(1).value,"telhy.asp?lie_2=5&H=30&salestype=2&W31=" & f_rs.fields(4).value & "&Center_t2=" & v2 & "") & "</DIV></TD>"
				v3=v3 & "<TD width=""25%""><DIV align=center>" & returnnum(f_rs.fields(2).value,"telhy.asp?lie_2=5&H=30&salestype=3&W31=" & f_rs.fields(4).value & "&Center_t2=" & v2 & "") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 7:
		fsql="select count(1) from tel_sales_change_log WITH(NOLOCK) where precateid=gate.ord and reason=4 and datediff(d,date7,'" & v2 &"')=0"
		Set f_rs=cn.execute("select ("&fsql&") as num,name,ord from gate WITH(NOLOCK) where del=1 and ord in("&glist&") order by sorce,sorce2" )
		If f_rs.eof = True Then
			v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center>人员</DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr style='height:20px;'><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"saleschangeList.asp?cateid=" & f_rs.fields(2).value & "&e_ret=" & v2 & "&e_ret2=" & v2 & "&conditions2=4") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		End Select
		v3=v3 & "</TBODY></TABLE></div>"
		Response.write v3
	end sub
	Sub report_sort(stype)
		Dim f_rs,v2,v3,j_v3,vn,uid,fsql,t2,selpart
		v2=app.GetText("v2")
		If isdate(v2)=False Then v2=date
		Dim glist
		If stype=5 Or stype=6 Then
			glist=GateGroupOrd_QX(1,1,3)
		else
			glist=GateGroupOrd(3)
		end if
		uid=session("personzbintel2007")
		vn=1
		Select Case stype
		Case 1:j_v3="当天新增：客户分类分布"
		Case 2:j_v3="当天领用：客户分类分布"
		Case 3:j_v3="当天联系：客户分类分布"
		Case 4:j_v3="当天回收：客户分类分布"
		Case 5:j_v3="保护客户：客户分类分布"
		Case 6:j_v3="保护即将到期：客户分类分布"
		End Select
		selpart=app.GetText("selpart")
		If selpart="clear" Then Response.end
		v3=v3 & "<div style='position:absolute;width:300px; "
		If stype=4 Then v3=v3&" margin-left:-230px; "
		v3=v3 & "<div style='position:absolute;width:300px; "
		If stype=3 Then v3=v3&" margin-left:-130px; "
		v3=v3 & "<div style='position:absolute;width:300px; "
		v3=v3 &"'><TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""500"" bgColor=#c0ccdd><TBODY>"
		v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><div style='float:left;font-weight:bold'>&nbsp;" & j_v3 & "</div><div style='float:right;cursor:pointer' onclick=""trycleardlgDiv()"">【关闭】&nbsp;</div></TD></tr>"
		v3=v3 &"'><TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""500"" bgColor=#c0ccdd><TBODY>"
		Select Case stype
		Case 1:
		fsql="select count(1) from tel where cateadd in("&glist&") and datediff(d,date1,'" & v2 & "')=0 and isnull(sp,0)=0 and del=1 and sort3=1"
		v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=center> "&v2&"  当天新增：" &cn.execute(fsql)(0).value & "</DIV></TD></tr>"
		Set f_rs=cn.execute("select * from (select (case when e.s2=0 then ("&fsql&" and sort=e.s1) else ("&fsql&" and sort=e.s1 and sort1=e.s2) end) as num,sort1,sort2,s1,s2,nums,gate1,gate2 from (select a.sort1 as sort1,b.sort2 as sort2,0 as nums,a.gate1,b.gate2,a.ord as s1,b.ord as s2 from sort4 a WITH(NOLOCK),sort5 b WITH(NOLOCK) where a.ord=b.sort1 union all select sort1 as sort1,'小计' as sort2,(select count(1)+1 from sort5 WITH(NOLOCK) where sort1=sort4.ord) as nums,gate1,999 as gate2,ord as s1,0 as s2 from sort4 WITH(NOLOCK)) e ) e  order by gate1 desc,gate2 desc,num desc")
		v3=v3 & "<tr class='top'><TD width=""33%""><DIV align=center>"&arrName(4)&"</DIV></TD><TD width=""33%""><DIV align=center>"&arrName(5)&"</DIV></TD><TD width=""33%""><DIV align=center>数量</DIV></TD></tr>"
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			Do While not f_rs.eof
				v3 = v3 & "<tr>"
				If f_rs("nums")>0 Then
					v3 = v3 & "<TD width=""33.1%"" rowspan="& f_rs("nums") & "><div align=center>" & f_rs.fields(1).value & "</div></Td>"
				end if
				v3 = v3 & "<TD width=""33%""><DIV align=center>" & f_rs("sort2") & "</DIV></TD><TD width=""33%""><DIV align=center>" & returnnum(zbcdbl(f_rs("num")),"telhy.asp?H=31&salestype=33&ord=" & f_rs.fields(3).value & "&ord2=" & f_rs.fields(4).value & "&Center_t2=" & v2 &"&w31="&glist&"") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 2:
		fsql="select count(1) from tel WITH(NOLOCK) where cateid in("&glist&") and datediff(d,date2,'" & v2 & "')=0 and isnull(sp,0)=0 and del=1 and sort3=1"
		v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=center> "&v2&"  当天领用：" &cn.execute(fsql)(0).value & "</DIV></TD></tr>"
		Set f_rs=cn.execute("select * from (select (case when e.s2=0 then ("&fsql&" and sort=e.s1) else ("&fsql&" and sort=e.s1 and sort1=e.s2) end) as num,sort1,sort2,s1,s2,nums,gate1,gate2 from (select a.sort1 as sort1,b.sort2 as sort2,0 as nums,a.gate1,b.gate2,a.ord as s1,b.ord as s2 from sort4 a WITH(NOLOCK),sort5 b WITH(NOLOCK) where a.ord=b.sort1 union all select sort1 as sort1,'小计' as sort2,(select count(1)+1 from sort5 WITH(NOLOCK) where sort1=sort4.ord) as nums,gate1,999 as gate2,ord as s1,0 as s2 from sort4 WITH(NOLOCK)) e ) e  order by gate1 desc,gate2 desc,num desc")
		v3=v3 & "<tr class='top'><TD width=""33%""><DIV align=center>"&arrName(4)&"</DIV></TD><TD width=""33%""><DIV align=center>"&arrName(5)&"</DIV></TD><TD width=""33%""><DIV align=center>数量</DIV></TD></tr>"
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			Do While not f_rs.eof
				v3 = v3 & "<tr>"
				If f_rs("nums")>0 Then
					v3 = v3 & "<TD width=""33.1%"" rowspan="& f_rs("nums") & "><div align=center>" & f_rs.fields(1).value & "</div></Td>"
				end if
				v3 = v3 & "<TD width=""33%""><DIV align=center>" & f_rs("sort2") & "</DIV></TD><TD width=""33%""><DIV align=center>" & returnnum(zbcdbl(f_rs("num")),"telhy.asp?H=31&salestype=34&ord=" & f_rs.fields(3).value & "&ord2=" & f_rs.fields(4).value & "&Center_t2=" & v2 &"&w31="&glist&"") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 3:
		Dim rs_r
		fsql="select count(1) from tel WITH(NOLOCK) where ord in(select distinct(ord) from reply WITH(NOLOCK) where sort1=1 and del=1 and cateid in("&glist&") and datediff(d,date7,'" & v2 & "')=0 and cateid = tel.cateid) and isnull(sp,0)=0 and del=1 and sort3=1"
		v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=center> "&v2&"  当天联系：" &cn.execute(fsql)(0).value & "</DIV></TD></tr>"
		Set f_rs=cn.execute("select * from (select (case when e.s2=0 then ("&fsql&" and sort=e.s1) else ("&fsql&" and sort=e.s1 and sort1=e.s2) end) as num,sort1,sort2,s1,s2,nums,gate1,gate2 from (select a.sort1 as sort1,b.sort2 as sort2,0 as nums,a.gate1,b.gate2,a.ord as s1,b.ord as s2 from sort4 a WITH(NOLOCK),sort5 b WITH(NOLOCK) where a.ord=b.sort1 union all select sort1 as sort1,'小计' as sort2,(select count(1)+1 from sort5 WITH(NOLOCK) where sort1=sort4.ord) as nums,gate1,999 as gate2,ord as s1,0 as s2 from sort4 WITH(NOLOCK)) e ) e  order by gate1 desc,gate2 desc,num desc")
		v3=v3 & "<tr class='top'><TD width=""33%""><DIV align=center>"&arrName(4)&"</DIV></TD><TD width=""33%""><DIV align=center>"&arrName(5)&"</DIV></TD><TD width=""33%""><DIV align=center>数量</DIV></TD></tr>"
		If f_rs.eof = True Then
			Set  rs_r = cn.execute(fsql & " and not exists(select 1 from sort4 a WITH(NOLOCK) inner join sort5 b WITH(NOLOCK) on a.ord=b.sort1 and tel.sort1=a.ord and tel.sort2=b.ord) ")
			If rs_r.eof = False Then
			else
				v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If rs_r.eof = False Then
			end if
			rs_r.close
		else
			Do While not f_rs.eof
				v3 = v3 & "<tr>"
				If f_rs("nums")>0 Then
					v3 = v3 & "<TD width=""33.1%"" rowspan="& f_rs("nums") & "><div align=center>" & f_rs.fields(1).value & "</div></Td>"
				end if
				v3 = v3 & "<TD width=""33%""><DIV align=center>" & f_rs("sort2") & "</DIV></TD><TD width=""33%""><DIV align=center>" & returnnum(zbcdbl(f_rs("num")),"telhy.asp?H=31&salestype=36&ord=" & f_rs.fields(3).value & "&ord2=" & f_rs.fields(4).value & "&Center_t2=" & v2 &"&w31="&glist&"") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
			Set  rs_r = cn.execute(fsql & " and not exists(select 1 from sort4 a WITH(NOLOCK) inner join sort5 b WITH(NOLOCK) on a.ord=b.sort1 and tel.sort=a.ord and tel.sort1=b.ord) ")
			If rs_r.eof = False Then
				v3 = v3 & "<TD width=""33%"" colspan=2 align=''>无分类</td><td><DIV align=center>" & returnnum(rs_r(0),"telhy.asp?H=31&salestype=36&ord=0&Center_t2=" & v2 &"&w31="&glist&"") & "</DIV></TD></tr>"
			end if
			rs_r.close
		end if
		f_rs.close
		Case 4:
		fsql="select count(1) from tel_sales_change_log WITH(NOLOCK) where precateid in(" & glist & ") and reason=4 and datediff(d,date7,'" & v2 &"')=0"
		v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=center> "&v2&"  当天回收：" &cn.execute(fsql)(0).value & "</DIV></TD></tr>"
		Set f_rs=cn.execute("select * from (select (case when e.s2=0 then ("&fsql&" and sort=e.s1) else ("&fsql&" and sort=e.s1 and sort1=e.s2) end) as num,sort1,sort2,s1,s2,nums,gate1,gate2 from (select a.sort1 as sort1,b.sort2 as sort2,0 as nums,a.gate1,b.gate2,a.ord as s1,b.ord as s2 from sort4 a WITH(NOLOCK),sort5 b WITH(NOLOCK) where a.ord=b.sort1 union all select sort1 as sort1,'小计' as sort2,(select count(1)+1 from sort5 WITH(NOLOCK) where sort1=sort4.ord) as nums,gate1,999 as gate2,ord as s1,0 as s2 from sort4 WITH(NOLOCK)) e ) e  order by gate1 desc,gate2 desc,num desc")
		v3=v3 & "<tr class='top'><TD width=""33%""><DIV align=center>"&arrName(4)&"</DIV></TD><TD width=""33%""><DIV align=center>"&arrName(5)&"</DIV></TD><TD width=""33%""><DIV align=center>数量</DIV></TD></tr>"
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			Do While not f_rs.eof
				v3 = v3 & "<tr>"
				If f_rs("nums")>0 Then
					v3 = v3 & "<TD width=""33.1%"" rowspan="& f_rs("nums") & "><div align=center>" & f_rs.fields(1).value & "</div></Td>"
				end if
				v3 = v3 & "<TD width=""33%""><DIV align=center>" & f_rs("sort2") & "</DIV></TD><TD width=""33%""><DIV align=center>" & returnnum(zbcdbl(f_rs("num")),"saleschangeList.asp?sort=" & f_rs.fields(3).value & "&sort1="& f_rs.fields(4).value &"&e_ret=" & v2 & "&e_ret2=" & v2 & "&conditions2=4") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 5:
		fsql="select count(1) from tel WITH(NOLOCK) where profect1=1 and cateid in("& glist &") and sort3=1 and del=1 and isnull(sp,0)=0"
		v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=center> "&v2&"  保护客户：" &cn.execute(fsql)(0).value & "</DIV></TD></tr>"
		Set f_rs=cn.execute("select * from (select (case when e.s2=0 then ("&fsql&" and sort=e.s1) else ("&fsql&" and sort=e.s1 and sort1=e.s2) end) as num,sort1,sort2,s1,s2,nums,gate1,gate2 from (select a.sort1 as sort1,b.sort2 as sort2,0 as nums,a.gate1,b.gate2,a.ord as s1,b.ord as s2 from sort4 a,sort5 b where a.ord=b.sort1 union all select sort1 as sort1,'小计' as sort2,(select count(1)+1 from sort5 WITH(NOLOCK) where sort1=sort4.ord) as nums,gate1,999 as gate2,ord as s1,0 as s2 from sort4 WITH(NOLOCK)) e ) e  order by gate1 desc,gate2 desc,num desc")
		v3=v3 & "<tr class='top'><TD width=""33%""><DIV align=center>"&arrName(4)&"</DIV></TD><TD width=""33%""><DIV align=center>"&arrName(5)&"</DIV></TD><TD width=""33%""><DIV align=center>数量</DIV></TD></tr>"
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			Do While not f_rs.eof
				v3 = v3 & "<tr>"
				If f_rs("nums")>0 Then
					v3 = v3 & "<TD width=""33.1%"" rowspan="& f_rs("nums") & "><div align=center>" & f_rs.fields(1).value & "</div></Td>"
				end if
				v3 = v3 & "<TD width=""33%""><DIV align=center>" & f_rs("sort2") & "</DIV></TD><TD width=""33%""><DIV align=center>" & returnnum(zbcdbl(f_rs("num")),"telhy.asp?H=31&salestype=10&lie_3=10&ord=" & f_rs.fields(3).value & "&ord2="& f_rs.fields(4).value &"&Center_t2=" & v2 &"") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 6:
		fsql="select count(1) from tel WITH(NOLOCK) where profect1=1 and datediff(d,'" & v2 & "',datepro+(select isnull(num2,0) from num_bh WITH(NOLOCK) where kh=tel.sort1 and cateid=tel.cateid))<=(select isnull(num3,0) from num_bh WITH(NOLOCK) where kh=tel.sort1 and cateid=tel.cateid) and cateid in("& glist &") and del=1 and isnull(sp,0)=0 and sort3=1 "
		v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=center> "&v2&"  保护即将到期：" &cn.execute(fsql)(0).value & "</DIV></TD></tr>"
		Set f_rs=cn.execute("select * from (select (case when e.s2=0 then ("&fsql&" and sort=e.s1) else ("&fsql&" and sort=e.s1 and sort1=e.s2) end) as num,sort1,sort2,s1,s2,nums,gate1,gate2 from (select a.sort1 as sort1,b.sort2 as sort2,0 as nums,a.gate1,b.gate2,a.ord as s1,b.ord as s2 from sort4 a WITH(NOLOCK),sort5 b WITH(NOLOCK) where a.ord=b.sort1 union all select sort1 as sort1,'小计' as sort2,(select count(1)+1 from sort5 WITH(NOLOCK) where sort1=sort4.ord) as nums,gate1,999 as gate2,ord as s1,0 as s2 from sort4 WITH(NOLOCK)) e ) e  order by gate1 desc,gate2 desc,num desc")
		v3=v3 & "<tr class='top'><TD width=""33%""><DIV align=center>"&arrName(4)&"</DIV></TD><TD width=""33%""><DIV align=center>"&arrName(5)&"</DIV></TD><TD width=""33%""><DIV align=center>数量</DIV></TD></tr>"
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			Do While not f_rs.eof
				v3 = v3 & "<tr>"
				If f_rs("nums")>0 Then
					v3 = v3 & "<TD width=""33.1%"" rowspan="& f_rs("nums") & "><div align=center>" & f_rs.fields(1).value & "</div></Td>"
				end if
				v3 = v3 & "<TD width=""33%""><DIV align=center>" & f_rs("sort2") & "</DIV></TD><TD width=""33%""><DIV align=center>" & returnnum(zbcdbl(f_rs("num")),"telhy.asp?H=31&salestype=11&lie_3=10&ord=" & f_rs.fields(3).value & "&ord2="& f_rs.fields(4).value &"&Center_t2=" & v2 &"") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		End Select
		v3=v3 & "</TBODY></TABLE></div>"
		Response.write v3
	end sub
	Sub report_apply
		Dim f_rs,v2,v3,vn,uid,fsql,t2,selpart
		v2=app.GetText("v2")
		If isdate(v2)=False Then v2=date
		Dim glist
		glist=GateGroupOrd(3)
		uid=session("personzbintel2007")
		vn=1
		selpart=app.GetText("selpart")
		If selpart="clear" Then Response.end
		v3=v3 & "<div style='width:300px; "
		v3=v3 &"'><TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""500"" bgColor=#c0ccdd><TBODY>"
		v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><div style='float:left;font-weight:bold'>&nbsp;当天领用：领用方式分布</div><div style='float:right;cursor:pointer' onclick=""trycleardlgDiv()"">【关闭】&nbsp;</div></TD></tr>"
		v3=v3 &"'><TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""500"" bgColor=#c0ccdd><TBODY>"
		v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=center>" & v2  & "</DIV></TD></tr>"
		v3=v3 &"'><TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""500"" bgColor=#c0ccdd><TBODY>"
		fsql="select *,isnull((select top 1 reason from tel_sales_change_log WITH(NOLOCK) where tord=tel.ord and isnull(newcateid,0)>0 order by id desc),0) as reason from tel WITH(NOLOCK) where cateid in("&glist&") and datediff(d,date2,'" & v2 & "')=0 and isnull(cateid,0)>0 and isnull(sp,0)=0 and del=1 andsort3=1"
		Set f_rs=cn.execute("select * from (select (select count(1) from ("&fsql&") e where reason=1) as num,'添加' as sort1,1 as ordunion all select (select count(1) from  ("&fsql&") e  where reason=2) as num,'导入' as sort1,2 as ord union all       select (select count(1) from  ("&fsql&") e  where reason=3) as num,'指派' as sort1,3 as ord union all select (select count(1) from  ("&fsql&") e where reason=5) as num,'领用' as sort1,5 as ordunion all select (select count(1) from  ("&fsql&") e  where reason=7) as num,'转移' as sort1,7 as ord union all select (select count(1) from  ("&fsql&") e  where reason=0) as num,'其他' as sort1,0 as ord) eee order by num desc")
		If f_rs.eof = True Then
			v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center>领用方式</DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr style='height:20px;'><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"telhy.asp?H=31&salestype=35&Center_t2=" & v2 & "&W31=" & f_rs.fields(2).value & "") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		v3=v3 & "</TBODY></TABLE></div>"
		Response.write v3
	end sub
	Sub report_backtype
		Dim f_rs,v2,v3,vn,uid,fsql,t2,selpart
		v2=app.GetText("v2")
		If isdate(v2)=False Then v2=date
		Dim glist
		glist=GateGroupOrd(3)
		uid=session("personzbintel2007")
		vn=1
		selpart=app.GetText("selpart")
		If selpart="clear" Then Response.end
		v3=v3 & "<div style='position:absolute;width:300px; margin-left: -200px;"
		If selpart="clear" Then Response.end
		v3=v3 &"'><TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""500"" bgColor=#c0ccdd><TBODY>"
		v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><div style='float:left;font-weight:bold'>&nbsp;当天回收：回收方式分布</div><div style='float:right;cursor:pointer' onclick=""trycleardlgDiv()"">【关闭】&nbsp;</div></TD></tr>"
		v3=v3 &"'><TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""500"" bgColor=#c0ccdd><TBODY>"
		v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=center>" & v2  & "</DIV></TD></tr>"
		v3=v3 &"'><TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""500"" bgColor=#c0ccdd><TBODY>"
		fsql=" select * from tel_sales_change_log WITH(NOLOCK) where reason=4 and precateid in("&glist&") and datediff(d,date7,'" & v2 & "')=0"
		Set f_rs=cn.execute("select * from (select (select count(1) from ("&fsql&") e where reasonchildren=1) as num,'领用未联系' as sort1,1 as ord  union all select (select count(1) from  ("&fsql&") e  where reasonchildren=2) as num,'间隔未联系' as sort1,2 as ord union all select (select count(1) from  ("&fsql&") e where reasonchildren=3) as num,'跟进未成功' as sort1,3 as ord union all     select (select count(1) from ("&fsql&") e where reasonchildren=5) as num,'主动放弃' as sort1,5 as ord union all select (select count(1) from  ("&fsql&") e where reasonchildren=4) as num,'保护过期' as sort1,4 as ord      union all select (select count(1) from  ("&fsql&") e  where reasonchildren=6) as num,'主管回收' as sort1,6 as ord union all select (select count(1) from  ("&fsql&") e  where reasonchildren=7) as num,'跟进超期' as sort1,7 as ord union all select (select count(1) from  ("&fsql&") e  where isnull(reasonchildren,0)=8) as num,'领用超期' as sort1,8 as ord) eee order by num desc")
		If f_rs.eof = True Then
			v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center>回收方式</DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr style='height:20px;'><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"saleschangeList.asp?reasonchildren=" & f_rs.fields(2).value & "&e_ret=" & v2 & "&e_ret2=" & v2 & "&conditions2=4")& "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		v3=v3 & "</TBODY></TABLE></div>"
		Response.write v3
	end sub
	Sub showperson(stype)
		Dim f_rs,v2,v3,j_v3,vn,uid,fsql,t2,selpart
		selpart=app.GetText("selpart")
		If selpart="clear" Then Exit sub
		v2=app.GetText("v2")
		If isdate(v2)=False Then v2=date
		If isdate(v2) Then t2=" and datediff(d,stime,'"&v2&"')>=0 "
		Dim glist
		If stype=6 Then
			glist=GateGroupOrd_QX(5,1,3)
		else
			glist=GateGroupOrd_QX(1,1,3)
		end if
		uid=session("personzbintel2007")
		vn=0
		Dim imid(),imname()
		Dim im_rs,im_i
		im_i=0
		ReDim imid(im_i)
		ReDim imname(im_i)
		Select Case stype
		Case 1,2,3:
		Set im_rs=cn.execute("select top 4 ord,sort1 from sort10 WITH(NOLOCK) where del=1 order by gate2 desc,ord")
		Do While im_rs.eof=False
			ReDim Preserve imid(im_i)
			ReDim Preserve imname(im_i)
			imid(im_i)=im_rs("ord")
			imname(im_i)=im_rs("sort1")
			im_i=im_i+1
			imname(im_i)=im_rs("sort1")
			im_rs.movenext
		Loop
		im_rs.close : Set im_rs=nothing
		End Select
		Select Case stype
		Case 1 :j_v3=imname(0)&"："
		Case 2 :j_v3=imname(1)&"："
		Case 3 :j_v3=imname(2)&"："
		Case 4 :j_v3="客户新增审批："
		Case 5 :j_v3="客户领用审批："
		Case 6: j_v3="合同审批："
		Case 7: j_v3="保护客户："
		Case 8: j_v3="保护即将到期："
		End Select
		Select Case stype
		Case 1,2,3,4,5,6,7,8: j_v3=j_v3&"人员分布"
		End Select
		v3=v3 & "<div style='position:absolute;width:210px;margin-top:5px; "
'End Select
		If stype=5 Then v3=v3 & "margin-left:-200px;"
'End Select
		If stype=6 Then v3=v3 & "margin-left:-200px;"
'End Select
		v3=v3 &"'><TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""500"" bgColor=#c0ccdd><TBODY>"
		v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><div style='float:left;font-weight:bold'>&nbsp;" & j_v3 & "</div><div style='float:right;cursor:pointer' onclick=""trycleardlgDiv()"">【关闭】&nbsp;</div></TD></tr>"
		v3=v3 &"'><TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""500"" bgColor=#c0ccdd><TBODY>"
		v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=center>" & v2  & "</DIV></TD></tr>"
		v3=v3 &"'><TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""500"" bgColor=#c0ccdd><TBODY>"
		Select Case stype
		Case 1:
		fsql="select count(1) from importantMsg WITH(NOLOCK) where exists(select top 1 1 from tel WITH(NOLOCK) where ord=importantMsg.t_ord and sort3=1 and del=1) and metype="&imid(0)&" and state=1 and ecateid=gate.ord " & t2
		Set f_rs=cn.execute("select ("&fsql&") as num,name,ord from gate WITH(NOLOCK) where del=1 and ord in("&glist&") order by sorce,sorce2" )
		If f_rs.eof = True Then
			v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center>人员</DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr style='height:20px;'><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"alt_list.asp?metype="&imid(0)&"&t2=" & v2 & "&complete=1&open=1&ecateid=" & f_rs.fields(2).value & "") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 2:
		fsql="select count(1) from importantMsg WITH(NOLOCK) where exists(select top 1 1 from tel WITH(NOLOCK) where ord=importantMsg.t_ord and sort3=1 and del=1)  and metype="&imid(1)&" and state=1 and ecateid=gate.ord " & t2
		Set f_rs=cn.execute("select ("&fsql&") as num,name,ord from gate WITH(NOLOCK) where del=1 and ord in("&glist&") order by sorce,sorce2" )
		If f_rs.eof = True Then
			v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center>人员</DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr style='height:20px;'><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"alt_list.asp?metype="&imid(1)&"&t2=" & v2 & "&complete=1&open=1&ecateid=" & f_rs.fields(2).value & "") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 3:
		fsql="select count(1) from importantMsg WITH(NOLOCK) where exists(select top 1 1 from tel WITH(NOLOCK) where ord=importantMsg.t_ord and sort3=1 and del=1) and metype="&imid(2)&" and state=1 and ecateid=gate.ord " & t2
		Set f_rs=cn.execute("select ("&fsql&") as num,name,ord from gate WITH(NOLOCK) where del=1 and ord in("&glist&") order by sorce,sorce2" )
		If f_rs.eof = True Then
			v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center>人员</DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr style='height:20px;'><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"alt_list.asp?metype="&imid(2)&"&t2=" & v2 & "&complete=1&open=1&ecateid=" & f_rs.fields(2).value & "") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 4:
		fsql="select count(*) from tel WITH(NOLOCK) where datediff(d,date1,'" & v2 & "')>=0 and (isnull(sp,0)>0 or isnull(sp,0)=-1) and  del=1 and sort3=1 and  cateadd=gate.ord"
'Case 4:
		Set f_rs=cn.execute("select ("&fsql&") as num,name,ord from gate where del=1 and ord in("&glist&") order by sorce,sorce2" )
		If f_rs.eof = True Then
			v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center>人员</DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr style='height:20px;'><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"teltop_sp.asp?H=31&v2="&v2&"&w31=" & f_rs.fields(2).value & "") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 5:
		fsql="select count(*) from tel WITH(NOLOCK) where datediff(d,date2,'" & v2 & "')>=0 and isnull(sp,0)=0 and  del=1 and sort3=1 and order1 in (3) and cateid4=gate.ord"
		Set f_rs=cn.execute("select ("&fsql&") as num,name,ord from gate WITH(NOLOCK) where del=1 and ord in("&glist&") order by sorce,sorce2" )
		If f_rs.eof = True Then
			v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center>人员</DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr style='height:20px;'><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"teltop.asp?H=31&G=3&v2="&v2&"&w31=" & f_rs.fields(2).value & "") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 6:
		If app.power.existsPowerIntro(5,1,-1) Then
'Case 6:
			fsql = " isnull(t2.ord,0)=0 or "
		end if
		fsql="select t1.num, isnull(t2.name,'<i>无人员</i>'), isnull(t2.ord,0) as ord from  gate t2 full join (select count(1) as num, cateid from contract WITH(NOLOCK) where del=1 and isnull(status,-1) not in (-1,0,1) group by cateid) t1 on t1.cateid = t2.ord where " & fsql & " ord in("&glist&")  order by sign(isnull(t2.ord,0)) desc, t2.sorce, t2.sorce2"
		Set f_rs=cn.execute(fsql)
		If f_rs.eof = True Then
			v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center>人员</DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr style='height:20px;'><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"../contract/planall.asp?sp=1&H=31&v2=" & v2 &"&w31="& f_rs.fields(2).value & "") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 7:
		fsql="select count(1) from tel WITH(NOLOCK) where profect1=1 and cateid in("& glist &") and sort3=1 and del=1 and isnull(sp,0)=0 and cateid=gate.ord"
		Set f_rs=cn.execute("select ("&fsql&") as num,name,ord from gate where del=1 and ord in("&glist&") order by sorce,sorce2" )
		If f_rs.eof = True Then
			v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center>人员</DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr style='height:20px;'><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"telhy.asp?H=31&salestype=10&lie_3=10&Center_t2=" & v2 &"&w31="& f_rs.fields(2).value & "") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 8:
		fsql="select count(1) from tel WITH(NOLOCK) where profect1=1 and datediff(d,'" & v2 & "',datepro+(select isnull(num2,0) from num_bh WITH(NOLOCK) where kh=tel.sort1 and cateid=tel.cateid))<=(select isnull(num3,0) from num_bh WITH(NOLOCK) where kh=tel.sort1 and cateid=tel.cateid) and cateid in("& glist &") and del=1 and isnull(sp,0)=0 and sort3=1 and cateid=gate.ord"
		Set f_rs=cn.execute("select ("&fsql&") as num,name,ord from gate WITH(NOLOCK) where del=1 and ord in("&glist&") order by sorce,sorce2" )
		If f_rs.eof = True Then
			v3=v3 & "<tr style='height:20px;'><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center>人员</DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr style='height:20px;'><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"telhy.asp?H=31&salestype=11&lie_3=10&Center_t2=" & v2 &"&w31="& f_rs.fields(2).value & "") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		End Select
		v3=v3 & "</TBODY></TABLE></div>"
		Response.write v3
	end sub
	Sub salesreport_tellist(stype)
		Dim v2
		v2=request("v2")
		If isdate(v2)=False Then v2=Date
		Dim moveid,act
		moveid=app.getint("moveid")
		act=app.getText("act")
		If moveid>0 Then
			Call moveact(moveid,act,v2,stype)
			Response.end
		end if
		Dim selpart,partid
		selpart=app.getText("selpart")
		partid=app.getint("partid")
		Select Case selpart
		Case "clear": Response.end
		Case Else
		Call jzlist(stype,partid,v2)
		End Select
	end sub
	Sub jzlist(stype,id,v2)
		Dim topid,j_v3,j_v,jsql
		If stype=1 Then
			jsql="select isnull((select report4 from salecenter WITH(NOLOCK) where ord=" & session("personzbintel2007") & "),'')"
		ElseIf stype=2 Then
			jsql="select isnull((select report5 from salecenter WITH(NOLOCK) where ord=" & session("personzbintel2007") & "),'')"
		ElseIf stype=3 Then
			jsql="select isnull((select report6 from salecenter WITH(NOLOCK) where ord=" & session("personzbintel2007") & "),'')"
		end if
		If id=0 Then
			j_v=cn.execute(jsql)(0).value
			If j_v="" Then
				If stype=1 then
					j_v="9,1,2,3,4,5,6,7,8"
				ElseIf stype=2 Then
					j_v="11,1,4,3,2,9,10,6,5,7,8"
				ElseIf stype=3 Then
					j_v="8,1,2,3,4,5,6,7"
				end if
			end if
			id=Split(j_v,",")(0)
			If Len(id)=0 Or isnumeric(id)=False Then id=1
		end if
		If stype=1 then
			Select Case id
			Case 1: j_v3=arrName(9)&"分布"
			Case 2: j_v3="录入方式"
			Case 3: j_v3=arrName(6)&"分布"
			Case 4: j_v3=arrName(4)&"分布"
			Case 5: j_v3=arrName(7)&"分布"
			Case 6: j_v3=arrName(8)&"分布"
			Case 7: j_v3=arrName(-3)&"分布"
			Case 6: j_v3=arrName(8)&"分布"
			Case 8: j_v3=arrName(-4)&"分布"
			Case 6: j_v3=arrName(8)&"分布"
			Case 9: j_v3="人员分布"
			End Select
		ElseIf stype=2 Then
			Select Case id
			Case 1: j_v3=arrName(9)&"分布"
			Case 2: j_v3="未联系天数"
			Case 3: j_v3=arrName(6)&"分布"
			Case 4: j_v3=arrName(4)&"分布"
			Case 5: j_v3=arrName(7)&"分布"
			Case 6: j_v3=arrName(8)&"分布"
			Case 7: j_v3=arrName(-3)&"分布"
			Case 6: j_v3=arrName(8)&"分布"
			Case 8: j_v3=arrName(-4)&"分布"
			Case 6: j_v3=arrName(8)&"分布"
			Case 9: j_v3="联系次数"
			Case 10: j_v3="跟进总时间"
			Case 11: j_v3="人员分析"
			End Select
		ElseIf stype=3 Then
			Select Case id
			Case 1: j_v3=arrName(9)&"分布"
			Case 2: j_v3=arrName(6)&"分布"
			Case 3: j_v3=arrName(4)&"分布"
			Case 4: j_v3=arrName(7)&"分布"
			Case 5: j_v3=arrName(8)&"分布"
			Case 6: j_v3=arrName(-3)&"分布"
			Case 5: j_v3=arrName(8)&"分布"
			Case 7: j_v3=arrName(-4)&"分布"
			Case 5: j_v3=arrName(8)&"分布"
			Case 8: j_v3="人员分布"
			End Select
		end if
		If (stype<>3 And ((arrName(-1)=0 And id=7) Or (arrName(-2)=0 And id=8))) Or (stype=3 And ((arrName(-1)=0 And id=6) Or (arrName(-2)=0 And id=7))) Then
'End Select
		else
			Call showhead(stype,1,j_v3)
			If stype=1 then
				Response.write "<TABLE id=content border=0 cellSpacing=1 cellPadding=3 width=""100%"" bgColor=#c0ccdd><TBODY><TR>"
				Response.write "<TD width=""40%"" style='vertical-align:top;'><DIV style='text-align:center;'>" & showleftlist(id,topid) & "</DIV></TD>"
				Response.write "<TABLE id=content border=0 cellSpacing=1 cellPadding=3 width=""100%"" bgColor=#c0ccdd><TBODY><TR>"
				Response.write "<TD  style='vertical-align:top'>" & showpart(topid,v2) & "</TD>"
				Response.write "<TABLE id=content border=0 cellSpacing=1 cellPadding=3 width=""100%"" bgColor=#c0ccdd><TBODY><TR>"
				Response.write "</TR></TBODY></TABLE>"
			ElseIf stype=2 Then
				Response.write "<TABLE id=content border=0 cellSpacing=1 cellPadding=3 width=""100%"" bgColor=#c0ccdd><TBODY><TR>"
				Response.write "<TD width=""40%"" style='vertical-align:top;'><DIV style='text-align:center;'>" & showleftlist2(id,topid) & "</DIV></TD>"
				Response.write "<TABLE id=content border=0 cellSpacing=1 cellPadding=3 width=""100%"" bgColor=#c0ccdd><TBODY><TR>"
				Response.write "<TD  style='vertical-align:top;border-left:0px'>" & showpart2(topid,v2) & "</TD>"
				Response.write "<TABLE id=content border=0 cellSpacing=1 cellPadding=3 width=""100%"" bgColor=#c0ccdd><TBODY><TR>"
				Response.write "</TR></TBODY></TABLE>"
			ElseIf stype=3 Then
				Response.write "<TABLE id=content border=0 cellSpacing=1 cellPadding=3 width=""100%"" bgColor=#c0ccdd><TBODY><TR>"
				Response.write "<TD width=""30%"" style='vertical-align:top;'><DIV style='text-align:center;'>" & showleftlist3(id,topid) & "</DIV></TD>"
				Response.write "<TABLE id=content border=0 cellSpacing=1 cellPadding=3 width=""100%"" bgColor=#c0ccdd><TBODY><TR>"
				Response.write "<TD  style='vertical-align:top'>" & showpart3(topid,v2) & "</TD>"
				Response.write "<TABLE id=content border=0 cellSpacing=1 cellPadding=3 width=""100%"" bgColor=#c0ccdd><TBODY><TR>"
				Response.write "</TR></TBODY></TABLE>"
			end if
			Call showhead(stype,0,"")
		end if
	end sub
	Sub showhead(stype,t,v)
		Select Case t
		Case 1:
		If stype=3 Then
			Response.write "<div style=""position:absolute;width:700px;margin-left:-200px;margin-top:5px;""><TABLE id=content border=0 cellSpacing=0 cellPadding=2 width=500 bgColor=#c0ccdd><TBODY><TR class=top><TD colSpan=2><div style='float:left;font-weight:bold'>&nbsp;回收客户分析：" & v & "</div><div style='float:right;cursor:pointer' onclick=""trycleardlgDiv()"">【关闭】&nbsp;</div></TD></TR><TR><TD colSpan=2>"
		elseIf stype=2 Then
			Response.write "<div style=""position:absolute;width:500px;margin-left:-100px;margin-top:5px;""><TABLE id=content border=0 cellSpacing=0 cellPadding=2 width=500 bgColor=#c0ccdd><TBODY><TR class=top><TD colSpan=2><div style='float:left;font-weight:bold'>&nbsp;推荐联系：" & v & "</div><div style='float:right;cursor:pointer' onclick=""trycleardlgDiv()"">【关闭】&nbsp;</div></TD></TR><TR><TD colSpan=2>"
		else
			Response.write "<div style=""position:absolute;width:500px;margin-left:-100px;margin-top:5px;""><TABLE id=content border=0 cellSpacing=0 cellPadding=2 width=500 bgColor=#c0ccdd><TBODY><TR class=top><TD colSpan=2><div style='float:left;font-weight:bold'>&nbsp;新客户：" & v & "</div><div style='float:right;cursor:pointer' onclick=""trycleardlgDiv()"">【关闭】&nbsp;</div></TD></TR><TR><TD colSpan=2>"
		end if
		Case else
		Response.write "</TD></TR></TBODY></TABLE><TABLE border=0 cellSpacing=0 cellPadding=0 width='100%' height=27><TBODY><TR><TD height=27 background=../images/m_table_top.jpg></TD></TR></TBODY></TABLE></div>"
		End Select
	end sub
	Function showleftlist(n,topid)
		Dim v,uid,i,v1,v2,v3
		uid=session("personzbintel2007")
		v=cn.execute("select isnull((select report4 from salecenter WITH(NOLOCK) where ord=" & uid & "),'')")(0).value
		If v="" Then v="9,1,2,3,4,5,6,7,8"
		v=Split(v,",")
		For i=0 To ubound(v)
			If CStr(n)=CStr(v(i)) Then topid=v(i)
			v2=""
			If CStr(n)=CStr(v(i)) Then v2="color:red;font-weight:bold;"
			v2=""
			v3=""
			Select Case v(i)
			Case 1: v3=arrName(9)&"分布"
			Case 2: v3="录入方式"
			Case 3: v3=arrName(6)&"分布"
			Case 4: v3=arrName(4)&"分布"
			Case 5: v3=arrName(7)&"分布"
			Case 6: v3=arrName(8)&"分布"
			Case 7: v3=arrName(-3)&"分布"
			Case 6: v3=arrName(8)&"分布"
			Case 8: v3=arrName(-4)&"分布"
			Case 6: v3=arrName(8)&"分布"
			Case 9: v3="人员分布"
			End Select
			If (arrName(-1)=0 And v(i)=7) Or (arrName(-2)=0 And v(i)=8) Then
'End Select
			else
				v1= v1 & "<li style='line-height:24px;text-align:left;margin-left:10px;" & v2 & "' onmouseover=document.getElementById('listcon_"&v(i)&"').style.display='' onmouseout=document.getElementById('listcon_"&v(i)&"').style.display='none'><span style='cursor:pointer' onclick=""javascript:ajax.regEvent('salesreport_tellist');ajax.addParam('partid', '"&v(i)&"');ajax.addParam('v2',document.getElementById('hiddenflagdate_0').value);showDlgDiv(ajax.send(),true);""> " & v3 & " </span><span id='listcon_"&v(i)&"' style='display:none'><span style='cursor:pointer' onclick=""javascript:movelist(0," & v(i) & ",'top');"" title=""置顶显示"">△</span> <span style='cursor:pointer' onclick=""javascript:movelist(0," & v(i) & ",'up');"" title=""上移"">↑</span> <span style='cursor:pointer' onclick=""javascript:movelist(0," & v(i) & ",'down');"" title=""下移"">↓</span></span> </li>"
			end if
		next
		showleftlist=v1
	end function
	Function showpart(n,v2)
		Dim f_rs,v3,j_v3,vn,uid,sort4,sort
		Dim glist
		glist=GateGroupOrd_QX(1,1,3)
		uid=session("personzbintel2007")
		vn=0
		Select Case n
		Case 1: j_v3=arrName(9)&"分布"
		Case 2: j_v3="录入方式"
		Case 3: j_v3=arrName(6)&"分布"
		Case 4: j_v3=arrName(4) : vn=1
		Case 5: j_v3=arrName(7)&"分布"
		Case 6: j_v3=arrName(8)&"分布"
		Case 7: j_v3=arrName(-3)&"分布"
		Case 6: j_v3=arrName(8)&"分布"
		Case 8: j_v3=arrName(-4)&"分布"
		Case 6: j_v3=arrName(8)&"分布"
		Case 9: j_v3="人员分布"
		End Select
		v3=v3 & "<TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""100%"" bgColor=#c0ccdd><TBODY>"
		v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;" & j_v3  & "</DIV></TD></tr>"
		v3=v3 & "<TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""100%"" bgColor=#c0ccdd><TBODY>"
		v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;新客户："
		v3=v3 & "<TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""100%"" bgColor=#c0ccdd><TBODY>"
		v3=v3 & cn.execute("select count(1) as num from tel where (cateid in(" & glist & ") and datediff(d,date2,'"&v2&"')=0) and isnull(sp,0)=0 and del=1 and sort3=1 and isnull((select top 1 1 from reply where ord=tel.ord and sort1=1 and del=1 and date7>tel.date2),0)=0" )(0).value
		v3=v3 &"</DIV></TD></tr>"
		Select Case n
		Case 1:
		Set f_rs=cn.execute("exec sales_report_newtel " & uid & ",'" & v2 & "','',0,1,0,''" )
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center>" & arrName(9) & "</DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"telhy.asp?H=32&salestype=1&w31="&CGlistUrl(glist)&"&ord=" & f_rs.fields(2).value & "&Center_t2=" & v2 &"") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 2:
		Set f_rs=cn.execute("sales_report_newtel " & uid & ",'" & v2 & "','',0,2,0,''" )
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center> 录入方式 </DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"telhy.asp?H=32&salestype=2&w31="&CGlistUrl(glist)&"&ord=" & f_rs.fields(2).value & "&Center_t2=" & v2 &"") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 3:
		Set f_rs=cn.execute("sales_report_newtel " & uid & ",'" & v2 & "','',0,3,0,''" )
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center> " & arrName(6)&"分布" & " </DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"telhy.asp?H=32&salestype=3&w31="&CGlistUrl(glist)&"&ord=" & f_rs.fields(2).value & "&Center_t2=" & v2 &"") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 4:
		Set f_rs=cn.execute("sales_report_newtel " & uid & ",'" & v2 & "','',0,4,0,''")
		v3=v3 & "<tr class='top'><TD width=""33%""><DIV align=center>"&arrName(4)&"</DIV></TD><TD width=""33%""><DIV align=center>"&arrName(5)&"</DIV></TD><TD width=""33%""><DIV align=center>数量</DIV></TD></tr>"
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			Do While not f_rs.eof
				v3 = v3 & "<tr>"
				If f_rs("nums")>0 Then
					v3 = v3 & "<TD width=""33.1%"" rowspan="& f_rs("nums") & "><div align=center>" & f_rs.fields(1).value & "</div></Td>"
				end if
				v3 = v3 & "<TD width=""33%""><DIV align=center>" & f_rs("sort2") & "</DIV></TD><TD width=""33%""><DIV align=center>" & returnnum(zbcdbl(f_rs("num")),"telhy.asp?H=32&salestype=4&w31="&CGlistUrl(glist)&"&ord=" & f_rs.fields(3).value & "&ord2=" & f_rs.fields(4).value & "&Center_t2=" & v2 &"") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 5:
		Set f_rs=cn.execute("sales_report_newtel " & uid & ",'" & v2 & "','',0,5,0,''" )
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center> " & arrName(7)&"分布" & " </DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"telhy.asp?H=32&salestype=5&w31="&CGlistUrl(glist)&"&ord=" & f_rs.fields(2).value & "&Center_t2=" & v2 &"") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 6:
		Set f_rs=cn.execute("sales_report_newtel " & uid & ",'" & v2 & "','',0,6,0,''" )
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center> " & arrName(8)&"分布" & " </DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"telhy.asp?H=32&salestype=6&w31="&CGlistUrl(glist)&"&ord=" & f_rs.fields(2).value & "&Center_t2=" & v2 &"") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 7:
		Set f_rs=cn.execute("sales_report_newtel " & uid & ",'" & v2 & "','',0,7,0,''" )
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center> " & arrName(-3)&"分布" & " </DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
'If f_rs.eof = True Then
			Do While not f_rs.eof
				v3=v3 & "<tr><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"telhy.asp?H=32&salestype=7&w31="&CGlistUrl(glist)&"&ord=" & f_rs.fields(2).value & "&Center_t2=" & v2 &"") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 8:
		Set f_rs=cn.execute("sales_report_newtel " & uid & ",'" & v2 & "','',0,8,0,''" )
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center> " & arrName(-4)&"分布" & " </DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
'If f_rs.eof = True Then
			Do While not f_rs.eof
				v3=v3 & "<tr><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"telhy.asp?H=32&salestype=8&w31="&CGlistUrl(glist)&"&ord=" & f_rs.fields(2).value & "&Center_t2=" & v2 &"") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		Case 9:
		Set f_rs=cn.execute("sales_report_newtel " & uid & ",'" & v2 & "','',0,9,0,''" )
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""50%""><DIV align=center> " & "人员分布" & " </DIV></TD><TD width=""50%""><DIV align=center> 数量 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr><TD width=""50%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""50%""><DIV align=center>" & returnnum(f_rs.fields(0).value,"telhy.asp?H=32&salestype=9&ord=" & f_rs.fields(2).value & "&Center_t2=" & v2 &"") & "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		End Select
		v3=v3 & "</TBODY></TABLE>"
		showpart=v3
	end function
	Function showleftlist2(n,topid)
		Dim v,uid,i,v1,v2,v3
		uid=session("personzbintel2007")
		v=cn.execute("select isnull((select report5 from salecenter WITH(NOLOCK) where ord=" & uid & "),'')")(0).value
		If v="" Then v="11,1,4,3,2,9,10,6,5,7,8"
		v=Split(v,",")
		For i=0 To ubound(v)
			If CStr(n)=CStr(v(i)) Then topid=v(i)
			v2=""
			If CStr(n)=CStr(v(i)) Then v2="color:red;font-weight:bold;"
			v2=""
			v3=""
			Select Case v(i)
			Case 1: v3=arrName(9)&"分布"
			Case 2: v3="未联系天数"
			Case 3: v3=arrName(6)&"分布"
			Case 4: v3=arrName(4)&"分布"
			Case 5: v3=arrName(7)&"分布"
			Case 6: v3=arrName(8)&"分布"
			Case 7: v3=arrName(-3)&"分布"
			Case 6: v3=arrName(8)&"分布"
			Case 8: v3=arrName(-4)&"分布"
			Case 6: v3=arrName(8)&"分布"
			Case 9: v3="联系次数"
			Case 10: v3="跟进总时间"
			Case 11: v3="人员分析"
			End Select
			If (arrName(-1)=0 And v(i)=7) Or (arrName(-2)=0 And v(i)=8) Then
'End Select
			else
				v1= v1 & "<li style='line-height:24px;text-align:left;margin-left:10px;" & v2 & "' onmouseover=document.getElementById('listcon2_"&v(i)&"').style.display='' onmouseout=document.getElementById('listcon2_"&v(i)&"').style.display='none'><span style='cursor:pointer' onclick=""javascript:ajax.regEvent('salesreport_tellist2');ajax.addParam('partid', '"&v(i)&"');ajax.addParam('v2',document.getElementById('hiddenflagdate_0').value);showDlgDiv(ajax.send(),true);""> " & v3 & " </span><span id='listcon2_"&v(i)&"' style='display:none'><span style='cursor:pointer' onclick=""javascript:movelist(2," & v(i)& ",'top');"" title=""置顶显示"">△</span> <span style='cursor:pointer' onclick=""javascript:movelist(2," & v(i) & ",'up');"" title=""上移"">↑</span> <span style='cursor:pointer' onclick=""javascript:movelist(2," & v(i) & ",'down');"" title=""下移"">↓</span></span> </li>"
			end if
		next
		showleftlist2=v1
	end function
	Function addHtml(ByRef obj, ByVal html)
		Dim c
		If isArray(obj) Then
			c = ubound(obj) + 1
'If isArray(obj) Then
			ReDim Preserve obj(c)
			obj(c) = html
			addHtml = c
		else
			ReDim obj(0)
			obj(0) = html
			addHtml = 0
		end if
	end function
	Function showpart2(n,v2)
		Dim glist : glist = GateGroupOrd_QX(1,1,3)
		Dim basesql, sql, j_v3, v3, vn, uid, rs, html
		Dim title1, title2, zdyid
		uid = Info.User
		If Len(glist) > 0 Then
			basesql = "select x.ord, x.cateid, x.lastreply from dbo.erp_sale_getWillReplyList('" & v2 & "',0) x " &_
			"where  x.cateid in (" & glist & ") "
		else
			basesql = "select x.ord, x.cateid, x.lastreply from dbo.erp_sale_getWillReplyList('" & v2 & "',0) x"
		end if
		Select Case n
		Case 1:
		title1 = arrName(9) & "分布"
		title2 = arrName(9)
		sql = "select top 30000 sum(sign(a.ord)) as num, isnull(c.sort1,'无') as sort1, isnull(c.ord,0) as ord, c.gate1 from (" & basesql & ") a " &_
		"inner join tel b on a.ord=b.ord full join (select * from sortonehy t where t.gate2=14) c on b.jz=c.ord " &_
		"group by c.sort1, c.ord , c.gate1 " &_
		"order by isnull(sign(c.ord), 2), c.gate1 desc, c.ord"
		Case 2
		title1 = "未联系天数"
		title2 = title1
		basesql = Replace(basesql, "x.lastreply", "datediff(d, x.lastreply, '" & v2 & "') as dcount")
		sql = "(case when dcount <= 3 then 0 " &_
		"when dcount > 3 and dcount<=7 then 1 " &_
		"when dcount > 7 and dcount<=15 then 2 " &_
		"when dcount > 15 and dcount<=30 then 3 " &_
		"when dcount > 30 and dcount<=90 then 4 " &_
		"when dcount > 90 and dcount<=180 then 5 " &_
		"else 6 end) as dtype"
		sql = "select top 30000 sum(t2.c) as num, t1.sort1, t1.ord from " &_
		"(" &_
		"select '2天未联系' as sort1,0 as ord  union all " &_
		"select '3天未联系' as sort1,1 as ord  union all " &_
		"select '7天未联系',2  union all " &_
		"select '15天未联系',3 union all " &_
		"select '30天未联系',4 union all " &_
		"select '90天未联系',5 union all " &_
		"select '180天未联系',6) t1 " &_
		" left join (select "  & sql & ", ord, 1 as c from (" & basesql & ") t ) t2 on t1.ord=t2.dtype group by t1.ord, t1.sort1 order by t1.ord"
		Case 3
		title1 = arrName(6) & "分布"
		title2 = arrName(6)
		sql = "select top 30000  sum(sign(a.ord)) as num, isnull(c.sort1,'无') as sort1, isnull(c.ord,0) as ord, c.gate1 from (" & basesql & ") a " &_
		"inner join tel b WITH(NOLOCK) on a.ord=b.ord full join (select ord, sort1, gate2, gate1 from sortonehy t WITH(NOLOCK) where t.gate2=13)  c on b.ly=c.ord " &_
		"group by c.sort1, c.ord, c.gate1 " &_
		"order by isnull(sign(c.ord), 2), c.gate1 desc, c.ord"
		Case 4:
		vn = 1
		title1 = arrName(4)
		title2 = title1
		sql = "select top 30000  sum(sign(a.ord)) as num, c.sort1, c.sort2 , c.ord1, c.ord2, childcount from (" & basesql & ") a " &_
		"inner join tel b WITH(NOLOCK) on a.ord=b.ord full join " &_
		"(select x.sort1, y.sort2, x.ord as ord1, y.ord as ord2, x.gate1 , y.gate2 as gate2,  " &_
		"(select count(1) from sort5 where sort1=x.ord) as childcount from sort4 x " &_
		"          inner join sort5 y on x.ord=y.sort1  " &_
		") c on b.sort = c.ord1 and b.sort1 = c.ord2 " &_
		"group by c.sort1, c.sort2, c.ord1, c.ord2, c.gate1, c.gate2, c.childcount " &_
		"order by isnull(sign(c.ord1), 2), c.gate1 desc, c.ord1, c.gate2 desc, c.ord2"
		Case 5:
		title1 = arrName(7) & "分布"
		title2 = arrName(7)
		sql = "select top 30000  sum(sign(a.ord)) as num, isnull(c.menuname,'无') as sort1, isnull(c.id,0) as ord, c.gate1 from (" & basesql & ") a " &_
		"inner join tel b WITH(NOLOCK) on a.ord=b.ord left join menuarea c on b.area=c.id " &_
		"group by c.menuname, c.id, c.gate1 " &_
		"order by isnull(sign(c.id), 2), c.gate1 desc, c.id"
		Case 6:
		title1 = arrName(8) & "分布"
		title2 = arrName(8)
		sql = "select top 30000  sum(sign(a.ord)) as num, isnull(c.sort1,'无') as sort1, isnull(c.ord,0) as ord, c.gate1 from (" & basesql & ") a " &_
		"inner join tel b WITH(NOLOCK) on a.ord=b.ord full join (select ord, sort1, gate2, gate1 from sortonehy t where t.gate2=11) c  on b.trade=c.ord " &_
		"group by c.sort1, c.ord, c.gate1 " &_
		"order by isnull(sign(c.ord), 2), c.gate1 desc, c.ord"
		Case 7:
		zdyid = 0
		title1 = arrName(-3) & "分布"
		zdyid = 0
		title2 = arrName(-3)
		zdyid = 0
		Set rs = cn.execute("select gl from zdy where sort1=1 and name='zdy5' and set_open=1 and tj=1")
		If rs.eof = False Then
			zdyid = rs.fields(0).value
		end if
		rs.close
		sql = "select top 30000  sum(sign(a.ord)) as num, isnull(c.sort1,'无') as sort1, isnull(c.ord,0) as ord, c.gate1 from (" & basesql & ") a " &_
		"inner join tel b WITH(NOLOCK) on a.ord=b.ord full join (select ord, sort1, gate2, gate1 from sortonehy t where t.gate2=" & zdyid & ") c on b.zdy5=c.ord " &_
		"group by c.sort1, c.ord, c.gate1 " &_
		"order by isnull(sign(c.ord), 2), c.gate1 desc, c.ord"
		Case 8:
		zdyid = 0
		title1 = arrName(-4) & "分布"
		zdyid = 0
		title2 = arrName(-4)
		zdyid = 0
		Set rs = cn.execute("select gl from zdy where sort1=1 and name='zdy6' and set_open=1 and tj=1")
		If rs.eof = False Then
			zdyid = rs.fields(0).value
		end if
		rs.close
		sql = "select top 30000  sum(sign(a.ord)) as num, isnull(c.sort1,'无') as sort1, isnull(c.ord,0) as ord, c.gate1 from (" & basesql & ") a " &_
		"inner join tel b WITH(NOLOCK) on a.ord=b.ord full join (select ord, sort1, gate2, gate1 from sortonehy t where t.gate2=" & zdyid & ") c on b.zdy6=c.ord " &_
		"group by c.sort1, c.ord, c.gate1 " &_
		"order by isnull(sign(c.ord), 2), c.gate1 desc, c.ord"
		Case 9:
		title1 = "联系次数"
		title2 = title1
		basesql = Replace(basesql, "x.lastreply", "x.replycount as dcount ")
		sql =  "(case when dcount <= 5 then 1 " &_
		"when dcount > 5 and dcount<=10 then 2 " &_
		"when dcount > 10 and dcount<=20 then 3 " &_
		"when dcount > 20 and dcount<=30 then 4 " &_
		"when dcount > 30 and dcount<=50 then 5 " &_
		"when dcount > 50 and dcount<=100 then 6 " &_
		"else 7 end) as dtype"
		sql = "select top 30000 count(t2.dtype) as num, a.sort1, a.ord from ( " &_
		"select '5次以下' as sort1, 1 as ord union all " &_
		"select '10次以下' as sort1, 2 as ord union all " &_
		"select '20次以下' as sort1, 3 as ord union all " &_
		"select '30次以下' as sort1, 4 as ord union all " &_
		"select '50次以下' as sort1, 5 as ord union all " &_
		"select '100次以下' as sort1, 6 as ord union all " &_
		"select '100次以上' as sort1, 7 as ord  " &_
		") a left join (select "  & sql & " from (" & basesql & ") t ) t2 on a.ord= t2.dtype group by a.ord, a.sort1  order by a.ord"
		Case 10
		title1 = "跟进总时间"
		title2 = title1
		basesql = Replace(basesql, " x ", " x inner join tel y on x.ord=y.ord ")
		basesql = Replace(basesql, " x.lastreply ", " datediff(d,y.date2,'" & v2 & "') as dcount ")
		sql =  "(case when dcount <= 5 then 1 " &_
		"when dcount > 5 and dcount<=10 then 2 " &_
		"when dcount > 10 and dcount<=20 then 3 " &_
		"when dcount > 20 and dcount<=30 then 4 " &_
		"when dcount > 30 and dcount<=90 then 5 " &_
		"when dcount > 90 and dcount<=180 then 6 " &_
		"when dcount > 180 and dcount<=365 then 7 " &_
		"else 8 end) as dtype"
		sql = "select top 30000 count(t2.dtype) as num, a.sort1, a.ord from ( " &_
		"select '5天以下' as sort1, 1 as ord union all " &_
		"select '10天以下' as sort1, 2 as ord union all " &_
		"select '20天以下' as sort1, 3 as ord union all " &_
		"select '一个月以下' as sort1, 4 as ord union all " &_
		"select '三个月以下' as sort1, 5 as ord union all " &_
		"select '六个月以下' as sort1, 6 as ord union all " &_
		"select '1年以下' as sort1, 7 as ord union all " &_
		"select '1年以上' as sort1, 8 as ord  " &_
		") a left join (select "  & sql & " from (" & basesql & ") t ) t2 on a.ord= t2.dtype group by a.ord, a.sort1  order by a.ord"
		Case 11:
		title1 = "人员分析"
		title2 = title1
		sql = "select top 30000 sum(sign(a.ord)) as num, isnull(b.name,'无') as sort1, isnull(b.ord,0) as ord from (" & basesql & ") a " & _
		"full join gate b WITH(NOLOCK) on a.cateid=b.ord where b.ord in ("  & glist & ") group by b.ord, b.name " &_
		"order by isnull(sign(b.ord), 2), num desc, sort1"
		End Select
		Dim allsumvalue : allsumvalue = 0
		sql = "SET ANSI_WARNINGS OFF;set nocount on;select *, identity(int,1,1) as i into #tx from (" & sql & ") x; select isnull(sum(num),0) as sumv  from #tx; select * from #tx "& app.iif(n&""="2","WHERE ord>0","") &" order by i"
		Set rs = cn.execute(sql)
		If rs.eof = False Then
			allsumvalue = rs(0).value
		end if
		addHTML html, "<TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""100%"" bgColor=#c0ccdd><TBODY>"
		addHTML html, "<tr><TD width=""100%"" colspan='" & cstr(2+vn) & "'><DIV align=left>&nbsp;" & title1  & "</DIV></TD></tr>"
		addHTML html, "<tr><TD width=""100%"" colspan='" & cstr(2+vn) & "'><DIV align=left>&nbsp; 推荐联系：" & allsumvalue
		addHTML html, "</DIV></TD></tr>"
		Set rs = rs.nextrecordset
		If rs.eof = True Then
			addHTML html, "<tr><TD width=""100%"" colspan='" & cstr(2+vn) & "'><DIV align=left>无记录</DIV></TD></tr>"
'If rs.eof = True Then
		else
			If n = 4 Then
				addHTML html, "<tr class='top'><TD width=""33%""><DIV align=center>"&arrName(4)&"</DIV></TD><TD width=""33%""><DIV align=center>"&arrName(5)&"</DIV></TD><TD width=""33%""><DIV align=center>数量</DIV></TD></tr>"
				Dim pid : pid = -1
				While rs.eof = false
					addhtml html, "<tr>"
					If pid <> rs("ord1").value Then
						pid = rs("ord1").value
						addhtml html, "<TD width=""33.1%"" rowspan="& rs("childcount") & "><div align=center>" & rs.fields("sort1").value & "</div></Td>"
					end if
					addhtml html, "<TD width=""33%""><DIV align=center>" & rs("sort2") & "</DIV></TD><TD width=""33%""><DIV align=center>" & returnnum("zbcdbl(rs(""num"")),""telhy.asp?H=33&salestype=4&ord="" & rs.fields(""ord1"").value & "&ord2=" & rs.fields(""ord2"").value & "&Center_t2=" & v2 &"&W31="& CGlistUrl(glist) &") & "</DIV></TD></tr>"
					rs.movenext
				wend
			else
				addhtml html, "<tr class='top'><td width=""50%""><div align=center>" & title2 & "</div></td>"
				addhtml html, "<td width=""50%""><div align=center> 数量 </div></td></tr>"
				While rs.eof = false
					addhtml html, "<tr><td width=""50%""><div align=center>" & rs("sort1").value & "</div></td><td width=""50%""><div align=center>"
					addhtml html, returnnum(zbcdbl(rs.fields("num").value),"telhy.asp?h=33&salestype=" & n & "&ord=" & rs.fields("ord").value & "&Center_t2=" & v2 &"&w31=" & CGlistUrl(glist) & "")
					addhtml html, "</div></td></tr>"
					rs.movenext
				wend
			end if
		end if
		rs.close
		addHTML html, "</TBODY></TABLE>"
		showpart2 =  Join(html, "")
		Exit function
	end function
	Function showleftlist3(n,topid)
		Dim v,uid,i,v1,v2,v3
		uid=session("personzbintel2007")
		v=cn.execute("select isnull((select report6 from salecenter WITH(NOLOCK) where ord=" & uid & "),'')")(0).value
		If v="" Then v="8,1,2,3,4,5,6,7"
		v=Split(v,",")
		For i=0 To ubound(v)
			If CStr(n)=CStr(v(i)) Then topid=v(i)
			v2=""
			If CStr(n)=CStr(v(i)) Then v2="color:red;font-weight:bold;"
			v2=""
			v3=""
			Select Case v(i)
			Case 1: v3=arrName(9)&"分布"
			Case 2: v3=arrName(6)&"分布"
			Case 3: v3=arrName(4)&"分布"
			Case 4: v3=arrName(7)&"分布"
			Case 5: v3=arrName(8)&"分布"
			Case 6: v3=arrName(-3)&"分布"
			Case 5: v3=arrName(8)&"分布"
			Case 7: v3=arrName(-4)&"分布"
			Case 5: v3=arrName(8)&"分布"
			Case 8: v3="人员分析"
			End Select
			If (arrName(-1)=0 And v(i)=6) Or (arrName(-2)=0 And v(i)=7) Then
'End Select
			else
				v1= v1 & "<li style='line-height:24px;text-align:left;margin-left:10px;" & v2 & "' onmouseover=document.getElementById('listcon3_"&v(i)&"').style.display='' onmouseout=document.getElementById('listcon3_"&v(i)&"').style.display='none'><span style='cursor:pointer' onclick=""javascript:ajax.regEvent('salesreport_tellist3');ajax.addParam('partid', '"&v(i)&"');ajax.addParam('v2',document.getElementById('hiddenflagdate_0').value);showDlgDiv(ajax.send(),true);""> " & v3 & " </span><span id='listcon3_"&v(i)&"' style='display:none'><span style='cursor:pointer' onclick=""javascript:movelist(3," & v(i)& ",'top');"" title=""置顶显示"">△</span> <span style='cursor:pointer' onclick=""javascript:movelist(3," & v(i) & ",'up');"" title=""上移"">↑</span> <span style='cursor:pointer' onclick=""javascript:movelist(3," & v(i) & ",'down');"" title=""下移"">↓</span></span> </li>"
			end if
		next
		showleftlist3=v1
	end function
	Function showpart3(n,v2)
		Dim f_rs,v3,j_v3,vn,uid,sort4,sort
		uid=session("personzbintel2007")
		vn=0
		Select Case n
		Case 1: j_v3=arrName(9)&"分布"
		Case 2: j_v3=arrName(6)&"分布"
		Case 3: j_v3=arrName(4)&"分布" :vn=1
		Case 4: j_v3=arrName(7)&"分布"
		Case 5: j_v3=arrName(8)&"分布"
		Case 6: j_v3=arrName(-3)&"分布"
		Case 5: j_v3=arrName(8)&"分布"
		Case 7: j_v3=arrName(-4)&"分布"
		Case 5: j_v3=arrName(8)&"分布"
		Case 8: j_v3="人员分布"
		End Select
		Dim glist
		glist=GateGroupOrd_QX(1,1,3)
		v3=v3 & "<TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""100%"" bgColor=#c0ccdd><TBODY>"
		v3=v3 & "<tr><TD width=""100%"" colspan='"& 6+vn &"'><DIV align=left>&nbsp;" & j_v3  & "</DIV></TD></tr>"
		v3=v3 & "<TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""100%"" bgColor=#c0ccdd><TBODY>"
		v3=v3 & "<tr><TD width=""100%"" colspan='"& 6+vn &"'><DIV align=left>&nbsp;回收客户分析： "
		v3=v3 & "<TABLE id=content border=0 cellSpacing=0 cellPadding=0 width=""100%"" bgColor=#c0ccdd><TBODY>"
		v3=v3 & getbacktel(GateGroupOrd_QX(1,1,3),v2) & "/"
		v3=v3 & cn.execute("select count(1) as num from tel where cateid in(" & glist &") and isnull(sp,0)=0 and del=1 and sort3=1" )(0).value
		v3=v3 &"</DIV></TD></tr>"
		Select Case n
		Case 1:
		Set f_rs=cn.execute("exec sales_report_newtel3 " & uid & ",'" & v2 & "','',0,1,0,''" )
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 6+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""20%""><DIV align=center>" & arrName(9) & "</DIV></TD><TD width=""16%""><DIV align=center> 3天内 </DIV></TD><TD width=""16%""><DIV align=center> 7天内 </DIV></TD><TD width=""16%""><DIV align=center> 10天内 </DIV></TD><TD width=""16%""><DIV align=center> 15天内 </DIV></TD><TD width=""16%""><DIV align=center> 15天以上 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr><TD width=""20%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""16%""><DIV align=center>" & returnnum(f_rs.fields(3).value,"telhy.asp?H=34&salestype=1&days=3&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&Center_t2=" & v2 &"") & "</DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(4).value,"telhy.asp?H=34&salestype=1&days=7&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(5).value,"telhy.asp?H=34&salestype=1&days=10&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(6).value,"telhy.asp?H=34&salestype=1&days=15&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&Center_t2=" & v2 & ") &  </DIV></TD><TD width=""16%""><DIV align=center>  & returnnum(f_rs.fields(7).value,telhy.asp?H=34&salestype=1&days=999999&ord= & f_rs.fields(2).value & &w31= & CGlistUrl(glist) & &Center_t2= & v2 &") &  "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 2:
		Set f_rs=cn.execute("sales_report_newtel3 " & uid & ",'" & v2 & "','',0,2,0,''" )
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""20%""><DIV align=center>" & arrName(6)&"分布" & "</DIV></TD><TD width=""16%""><DIV align=center> 3天内 </DIV></TD><TD width=""16%""><DIV align=center> 7天内 </DIV></TD><TD width=""16%""><DIV align=center> 10天内 </DIV></TD><TD width=""16%""><DIV align=center>15天内</DIV></TD><TD width=""16%""><DIV align=center> 15天以上 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr><TD width=""20%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""16%""><DIV align=center>" & returnnum(f_rs.fields(3).value,"telhy.asp?H=34&salestype=2&days=3&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&Center_t2=" & v2 &"") & "</DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(4).value,"telhy.asp?H=34&salestype=2&days=7&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(5).value,"telhy.asp?H=34&salestype=2&days=10&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(6).value,"telhy.asp?H=34&salestype=2&days=15&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&Center_t2=" & v2 & ") &  </DIV></TD><TD width=""16%""><DIV align=center>  & returnnum(f_rs.fields(7).value,telhy.asp?H=34&salestype=2&days=999999&ord= & f_rs.fields(2).value & &w31= & CGlistUrl(glist) & &Center_t2= & v2 &") &  "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 3:
		Set f_rs=cn.execute("sales_report_newtel3 " & uid & ",'" & v2 & "','',0,3,0,''")
		v3=v3 & "<tr class='top'><TD width=""20%""><DIV align=center>"&arrName(4)&"</DIV></TD><TD width=""12%""><DIV align=center>"&arrName(5)&"</DIV></TD><TD width=""12%""><DIV align=center> 3天内 </DIV></TD><TD width=""12%""><DIV align=center> 7天内 </DIV></TD><TD width=""12%""><DIV align=center> 10天内 </DIV></TD><TD width=""12%""><DIV align=center> 15天内 </DIV></TD><TD width=""12%""><DIV align=center> 15天以上 </DIV></TD></tr>"
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			Do While not f_rs.eof
				v3 = v3 & "<tr>"
				If f_rs("nums")>0 or f_rs("sort1")="无" Then
					v3 = v3 & "<TD width=""20%"" rowspan="& f_rs("nums") & "><div align=center>" & f_rs.fields(1).value & "</div></Td>"
				end if
				v3 = v3 & "<TD width=""12%""><DIV align=center>" & f_rs("sort2") & "&nbsp;</DIV></TD><TD width=""12%""><DIV align=center>" & returnnum(f_rs("day3"),"telhy.asp?H=34&salestype=3&ord=" & f_rs("s1") & "&ord2=" & f_rs("s2") & "&w31=" & CGlistUrl(glist) & "&days=3&Center_t2=" & v2 &"") & "</DIV></TD><TD width=""12%""><DIV align=center> " & returnnum(f_rs.fields(4).value,"telhy.asp?H=34&salestype=3&ord=" & f_rs("s1") & "&ord2=" & f_rs("s2") & "&w31=" & CGlistUrl(glist) & "&days=7&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""12%""><DIV align=center> " & returnnum(f_rs.fields(5).value,"telhy.asp?H=34&salestype=3&ord=" & f_rs("s1") & "&ord2=" & f_rs("s2") & "&w31=" & CGlistUrl(glist) & "&days=10&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""12%""><DIV align=center> " & returnnum(f_rs.fields(6).value,"telhy.asp?H=34&salestype=3&ord=" & f_rs("s1") & "&ord2=" & f_rs("s2") & "&w31=" & CGlistUrl(glist) & "&days=15&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""12%""><DIV align=center> " & returnnum(f_rs.fields(7).value,"telhy.asp?H=34&salestype=3&ord=" & f_rs("s1") & "&ord2=" & f_rs("s2") & "&w31=" & CGlistUrl(glist) & "&days=999999&Center_t2=" & v2 &"") & " </DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 4:
		Set f_rs=cn.execute("sales_report_newtel3 " & uid & ",'" & v2 & "','',0,4,0,''" )
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""20%""><DIV align=center>" & arrName(7) & "</DIV></TD><TD width=""16%""><DIV align=center> 3天内 </DIV></TD><TD width=""16%""><DIV align=center> 7天内 </DIV></TD><TD width=""16%""><DIV align=center> 10天内 </DIV></TD><TD width=""16%""><DIV align=center> 15天内 </DIV></TD><TD width=""16%""><DIV align=center> 15天以上 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr><TD width=""20%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""16%""><DIV align=center>" & returnnum(f_rs.fields(3).value,"telhy.asp?H=34&salestype=4&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=3&Center_t2=" & v2 &"") & "</DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(4).value,"telhy.asp?H=34&salestype=4&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=7&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(5).value,"telhy.asp?H=34&salestype=4&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=10&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(6).value,"telhy.asp?H=34&salestype=4&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=15&Center_t2=" & v2 & ") &  </DIV></TD><TD width=""16%""><DIV align=center>  & returnnum(f_rs.fields(7).value,telhy.asp?H=34&salestype=4&ord= & f_rs.fields(2).value & &w31= & CGlistUrl(glist) & &days=999999&Center_t2= & v2 &") &  "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 5:
		Set f_rs=cn.execute("sales_report_newtel3 " & uid & ",'" & v2 & "','',0,5,0,''" )
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""20%""><DIV align=center>" & arrName(8) & "</DIV></TD><TD width=""16%""><DIV align=center> 3天内 </DIV></TD><TD width=""16%""><DIV align=center> 7天内 </DIV></TD><TD width=""16%""><DIV align=center> 10天内 </DIV></TD><TD width=""16%""><DIV align=center> 15天内 </DIV></TD><TD width=""16%""><DIV align=center> 15天以上 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr><TD width=""20%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""16%""><DIV align=center>" & returnnum(f_rs.fields(3).value,"telhy.asp?H=34&salestype=5&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=3&Center_t2=" & v2 &"") & "</DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(4).value,"telhy.asp?H=34&salestype=5&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=7&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(5).value,"telhy.asp?H=34&salestype=5&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=10&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(6).value,"telhy.asp?H=34&salestype=5&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=15&Center_t2=" & v2 & ") &  </DIV></TD><TD width=""16%""><DIV align=center>  & returnnum(f_rs.fields(7).value,telhy.asp?H=34&salestype=5&ord= & f_rs.fields(2).value & &w31= & CGlistUrl(glist) & &days=999999&Center_t2= & v2 &") &  "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 6:
		Set f_rs=cn.execute("sales_report_newtel3 " & uid & ",'" & v2 & "','',0,6,0,''" )
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""20%""><DIV align=center>" & arrName(-3)&"分布" & "</DIV></TD><TD width=""16%""><DIV align=center> 3天内 </DIV></TD><TD width=""16%""><DIV align=center> 7天内 </DIV></TD><TD width=""16%""><DIV align=center> 10天内 </DIV></TD><TD width=""16%""><DIV align=center> 15天内 </DIV></TD><TD width=""16%""><DIV align=center> 15天以上 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr><TD width=""20%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""16%""><DIV align=center>" & returnnum(f_rs.fields(3).value,"telhy.asp?H=34&salestype=6&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=3&Center_t2=" & v2 &"") & "</DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(4).value,"telhy.asp?H=34&salestype=6&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=7&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(5).value,"telhy.asp?H=34&salestype=6&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=10&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(6).value,"telhy.asp?H=34&salestype=6&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=15&Center_t2=" & v2 & ") &  </DIV></TD><TD width=""16%""><DIV align=center>  & returnnum(f_rs.fields(7).value,telhy.asp?H=34&salestype=6&ord= & f_rs.fields(2).value & &w31= & CGlistUrl(glist) & &days=999999&Center_t2= & v2 &") &  "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 7:
		Set f_rs=cn.execute("sales_report_newtel3 " & uid & ",'" & v2 & "','',0,7,0,''" )
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""20%""><DIV align=center>" & arrName(-4)&"分布" & "</DIV></TD><TD width=""16%""><DIV align=center> 3天内 </DIV></TD><TD width=""16%""><DIV align=center> 7天内 </DIV></TD><TD width=""16%""><DIV align=center> 10天内 </DIV></TD><TD width=""16%""><DIV align=center> 15天内 </DIV></TD><TD width=""16%""><DIV align=center> 15天以上 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr><TD width=""20%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""16%""><DIV align=center>" & returnnum(f_rs.fields(3).value,"telhy.asp?H=34&salestype=7&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=3&Center_t2=" & v2 &"") & "</DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(4).value,"telhy.asp?H=34&salestype=7&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=7&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(5).value,"telhy.asp?H=34&salestype=7&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=10&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(6).value,"telhy.asp?H=34&salestype=7&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=15&Center_t2=" & v2 & ") &  </DIV></TD><TD width=""16%""><DIV align=center>  & returnnum(f_rs.fields(7).value,telhy.asp?H=34&salestype=7&ord= & f_rs.fields(2).value & &w31= & CGlistUrl(glist) & &days=999999&Center_t2= & v2 &") &  "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		Case 8:
		Set f_rs=cn.execute("sales_report_newtel3 " & uid & ",'" & v2 & "','',0,8,0,''" )
		If f_rs.eof = True Then
			v3=v3 & "<tr><TD width=""100%"" colspan='"& 2+vn &"'><DIV align=left>&nbsp;无记录</DIV></TD></tr>"
'If f_rs.eof = True Then
		else
			v3=v3 & "<tr class='top'><TD width=""20%""><DIV align=center>" & arrName(-4)&"分布" & "</DIV></TD><TD width=""16%""><DIV align=center> 3天内 </DIV></TD><TD width=""16%""><DIV align=center> 7天内 </DIV></TD><TD width=""16%""><DIV align=center> 10天内 </DIV></TD><TD width=""16%""><DIV align=center> 15天内 </DIV></TD><TD width=""16%""><DIV align=center> 15天以上 </DIV></TD></tr>"
			Do While not f_rs.eof
				v3=v3 & "<tr><TD width=""20%""><DIV align=center>" & f_rs.fields(1).value & "</DIV></TD><TD width=""16%""><DIV align=center>" & returnnum(f_rs.fields(3).value,"telhy.asp?H=34&salestype=8&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=3&Center_t2=" & v2 &"") & "</DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(4).value,"telhy.asp?H=34&salestype=8&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=7&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(5).value,"telhy.asp?H=34&salestype=8&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=10&Center_t2=" & v2 &"") & " </DIV></TD><TD width=""16%""><DIV align=center> " & returnnum(f_rs.fields(6).value,"telhy.asp?H=34&salestype=8&ord=" & f_rs.fields(2).value & "&w31=" & CGlistUrl(glist) & "&days=15&Center_t2=" & v2 & ") &  </DIV></TD><TD width=""16%""><DIV align=center>  & returnnum(f_rs.fields(7).value,telhy.asp?H=34&salestype=8&ord= & f_rs.fields(2).value & &w31= & CGlistUrl(glist) & &days=999999&Center_t2= & v2 &") &  "</DIV></TD></tr>"
				f_rs.movenext
			Loop
		end if
		f_rs.close
		End Select
		v3=v3 & "</TBODY></TABLE>"
		showpart3=v3
	end function
	Sub moveact(moveid,act,ByVal v4,ByVal stype)
		Dim savecol,coldef
		If stype=1 Then
			savecol="report4"
			coldef="9,1,2,3,4,5,6,7,8"
		ElseIf stype=2 Then
			savecol="report5"
			coldef="11,1,4,3,2,9,10,6,5,7,8"
		ElseIf stype=3 Then
			savecol="report6"
			coldef="8,1,2,3,4,5,6,7"
		ElseIf stype=4 Then
			savecol="report7"
		end if
		Dim v,v1,v2,i
		Set v=cn.execute("select top 1 " & savecol & " from salecenter WITH(NOLOCK) where ord=" & session("personzbintel2007") )
		If v.eof=True Then
			cn.execute("insert into salecenter(ord," & savecol & ") values('" & session("personzbintel2007") & "','" & coldef & "')")
			v1=coldef
		else
			v1=v(0).value
		end if
		If Len(v1&"")<10 Then v1=coldef
		v.close : Set v=Nothing
		v=v1  :  v1=""
		v=Split(v,",")
		For i=0 To ubound(v)
			If CStr(v(i))=CStr(moveid) Then
				v2=i
			end if
		next
		For i=0 To ubound(v)
			If act="top" And i=0 Then
				v1=adddou(v1,moveid)
				If CStr(v(i))<>CStr(moveid) Then
					v1=adddou(v1,v(i))
				end if
			else
				If CStr(v(i))<>CStr(moveid) Then
					If (act="up" And i=v2-1) or (act="down" And i=v2+1) Then
'If CStr(v(i))<>CStr(moveid) Then
						v1=adddou(v1,moveid)
					else
						v1=adddou(v1,v(i))
					end if
				else
					If act="up" Then
						If i-1>=0 Then
'If act="up" Then
							v1 = adddou(v1,v(i-1))
'If act="up" Then
						else
							v1 = adddou(v1,v(i))
						end if
					Elseif act="down" Then
						If i+1<=ubound(v) Then
'Elseif act="down" Then
							v1 = adddou(v1,v(i+1))
'Elseif act="down" Then
						else
							v1 = adddou(v1,v(i))
						end if
					end if
				end if
			end if
		next
		cn.execute("update salecenter set " & savecol & "='" & v1 & "' where ord=" & session("personzbintel2007"))
		Call jzlist(stype,moveid,v4)
	end sub
	Function adddou(ins,adds)
		If ins="" Then
			adddou=adds
		else
			adddou=ins&","&adds
		end if
	end function
	Function arrName(ByVal no)
		Dim openzdy5,openzdy6,intgate1,zdy5name,zdy6name,rs
		openzdy5=0
		openzdy6=0
		Dim arrShow()
		Dim arrNames()
		Dim arrFelds()
		Set rs=cn.execute("select (case when isnull(name,'')='' then oldname else name end ) as name, (case when show>0 then 1 else 0 end) as show,fieldName,gate1 from setfields WITH(NOLOCK) order by gate1 asc ")
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
		Set rs=cn.execute("select id,title,name,sort,gl from zdy WITH(NOLOCK) where (name='zdy5' or name='zdy6') and sort1=1 and set_open=1 order by gate1 asc")
		While Not rs.eof
			If rs("name")="zdy5" Then zdy5name=rs("title") : openzdy5=1
			If rs("name")="zdy6" Then zdy6name=rs("title") : openzdy6=1
			rs.movenext
		wend
		rs.close
		If no>=0 then
			arrName=arrNames(no)
		ElseIf no=-1 Then
			arrName=arrNames(no)
			arrName=openzdy5
		ElseIf no=-2 Then
			arrName=openzdy5
			arrName=openzdy6
		ElseIf no=-3 Then
			arrName=openzdy6
			arrName=zdy5name
		ElseIf no=-4 Then
			arrName=zdy5name
			arrName=zdy6name
		end if
	end function
	Private Function GateGroupOrd(ByVal sType)
		Dim rs,v,open1_1,intro1_1
		Set rs=cn.execute("select qx_open,qx_intro from power WITH(NOLOCK) where ord=" & info.user & " and sort1=1 and sort2=11")
		If Not rs.eof Then
			open1_1=rs(0).value
			intro1_1=rs(1).value
		else
			open1_1=0
			intro1_1=0
		end if
		rs.close
		If open1_1=3  Then
			Set rs=cn.execute("select ord from gate WITH(NOLOCK) where del=1")
			Do While Not rs.eof
				If v="" Then
					v=rs(0).value
				else
					v=v & "," & rs(0).value
				end if
				rs.movenext
			Loop
			rs.close
		ElseIf open1_1=1 Then
			v=intro1_1
		else
			v=-1
			v=intro1_1
		end if
		If Len(v&"")=0 Then v=0
		GateGroupOrd=v
	end function
	Private Function GateGroupOrd_QX(sort1,sort2,ByVal sType)
		Dim rs,v,open1_1,intro1_1
		Set rs=cn.execute("SELect qx_open,qx_Intro From poWer WITH(NOLOCK) where ord=" & info.user & " aNd sort1="&sort1&" aNd sort2="&sort2&"")
		If Not rs.eof Then
			open1_1=rs(0).value
			intro1_1=rs(1).value
		else
			open1_1=0
			intro1_1=0
		end if
		rs.close
		If open1_1=3  Then
			v = "select ord from gate WITH(NOLOCK) where del=1"
		ElseIf open1_1=1 Then
			v=intro1_1
		else
			v=-1
			v=intro1_1
		end if
		If Len(v&"")=0 Then v=0
		GateGroupOrd_QX=v
	end function
	Function getTelList(ByVal ord,ByVal v2)
		Dim f_sql,f_rs,v, m
		If InStr(1,ord, "select",1) > 0 Then
			ord = ""
		else
			ord = Replace(ord, " ", "")
		end if
		f_sql="exec getTelList '" & ord & "','" & v2 & "',0"
		v=cn.execute(f_sql).fields(0).value
		getTelList=v
	end function
	Function getbacktel(ByVal ord, ByVal v2)
		Dim sql, rs
		sql = " select COUNT(1) from ( " & vbcrlf & _
		"  select 1 a from " & vbcrlf & _
		"  dbo.erp_sale_getBackList_core('" & v2 & "', 0) x " & vbcrlf & _
		"  where canremind=1 and backdays<=reminddays  " & vbcrlf
		If InStr(1,ord, "select",1) = 0 Then
			sql = sql & " and x.cateid in(" & ord & ") "
		else
			sql = sql & " and exists(select 1 from gate m where m.ord=x.cateid and m.del=1) "
		end if
		sql = sql & "      group by ord " & vbcrlf & _
		") y"
		Set rs = cn.execute(sql)
		If rs.eof = False Then
			getbacktel= rs.fields(0).value
		else
			getbacktel = 0
		end if
		rs.close
		set rs = nothing
	end function
	Function returnnum(v,linkurl)
		If Len(v)=0 Or isnumeric(v)=False Then v=0
		If v=0 Then
			returnnum= "<span style='color:#dddddd'>"&v&"</span>"
		else
			returnnum= openbutton(v,linkurl,1200,600,150,150)
		end if
	end function
	Function if0(v,linkurl)
		If Len(v)=0 Or isnumeric(v)=False Then v=0
		If v=0 Then
			Response.write "<span style='color:#dddddd'>"&v&"</span>"
		else
			Response.write openbutton(v,linkurl,1200,600,150,150)
		end if
	end function
	Function ift0(v,linkurl,title)
		If Len(v)=0 Or isnumeric(v)=False Then v=0
		If v=0 Then
			Response.write "<span style='color:#dddddd' title="""& title &""">"&v&"</span>"
		else
			Response.write openbuttonT(v,linkurl,1200,600,150,150,title)
		end if
	end function
	Function openbutton(v,url,w,h,l,t)
		openbutton="<a href=""javascript:void(0);"" onClick=""javascript:window.OpenNoUrl('" & url & "','newwin22','width=' + " & w & " + ',height=' + " & h & " + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=" & l & ",top=" & t & "')"">"&v&"</a>"
'Function openbutton(v,url,w,h,l,t)
	end function
	Function openbutton1(v,url,w,h,l,t)
		openbutton1="<input type='button' name='Submit4' value='" & v & "' onClick=""javascript:window.OpenNoUrl('" & url & "','newwin22','width=' + " & w & " + ',height=' + " & h & " + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=" & l & ",top=" & t & "')""  class='anybutton'/>"
'Function openbutton1(v,url,w,h,l,t)
	end function
	Function openbuttonT(v,url,w,h,l,t,title)
		openbuttonT="<a href=""javascript:void(0);"" onClick=""javascript:window.OpenNoUrl('" & url & "','newwin22','width=' + " & w & " + ',height=' + " & h & " + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=" & l & ",top=" & t & "')"" title="""& title &""">"&v&"</a>"
'Function openbuttonT(v,url,w,h,l,t,title)
	end function
	
%>
