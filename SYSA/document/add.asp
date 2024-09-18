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
	
	Dim allowExt
	allowExt="|doc|docx|ppt|xls|xlsx|avi|bmp|jpeg|png|rmvb|gif|jpg|txt|pdm|zip|7z|rar|iso|apk|pdf|dwg|pptx|dwt|exb|eps|wmf|jfif|tif|tiff|xmind|psd|swf|mpeg|mp4|mov|flv|3gp|mp3|PDF|wps|WPS|"
	Dim MaxUploadSize
	MaxUploadSize=524288000
	
	Dim findex : findex = 0
	sub getUploadFileList(cn,documentID,edit)
		set rs88 = cn.execute("select isnull(spFlag,1) as spFlag from document where id='"&documentID&"' and del=1")
		If Not rs88.eof then
			spdel=rs88(0).value
		else
			spdel = 1
		end if
		set rs88=nothing
		findex = 0
		sql="select * from documentlist where document='"&documentID&"' and del=1 "
		set rsAtt=cn.execute(sql)
		if not rsAtt.eof then
			Response.write "" & vbcrlf & "              <TR class=top>" & vbcrlf & "                  <TD><CENTER><SPAN class=""tableTitleLinks"" style=""FONT-WEIGHT: bolder; COLOR: #5b7cae"">文件名</SPAN></CENTER></TD>" & vbcrlf & "                   <TD><CENTER><SPAN class=""tableTitleLinks"" style=""FONT-WEIGHT: bolder; COLOR: #5b7cae"">文件大小</SPAN></CENTER></TD>"& vbcrlf & "                       <TD><CENTER><SPAN class=""tableTitleLinks"" style=""FONT-WEIGHT: bolder; COLOR: #5b7cae"">文件描述</SPAN></CENTER></TD>" & vbcrlf & "                 <TD><center><span class=""tableTitleLinks"" style='FONT-WEIGHT: bolder; COLOR: #5b7cae'>有效期限</span></center></TD>" & vbcrlf & "                       <TD><CENTER><SPAN class=""tableTitleLinks"" style=""FONT-WEIGHT: bolder; COLOR: #5b7cae"">操作</SPAN></CENTER></TD>" & vbcrlf & "                </TR>" & vbcrlf & "           "
'if not rsAtt.eof then
			Dim l_validity ,fid
			findex = 0
			dim strdiv ,strc1,strc2 ,sec , l_date3 , l_date4
			while not rsAtt.eof
				FileName=rsAtt("WDUrl")
				FileNameArr=split(FileName,"/")
				if ubound(FileNameArr)=4 then
					FileNameNew=FileNameArr(4)
					FolderName=FileNameArr(3)
				end if
				FileNameOld=rsAtt("oldname")
				FileSize=rsAtt("WDSize")
				FileDesc=rsAtt("fileDes")
				FileAccessID=rsAtt("id")
				archive=rsAtt("archive")
				l_validity = rsAtt("l_validity")
				fid =  rsAtt("id")
				findex = findex +1
				fid =  rsAtt("id")
				strdiv = ""
				strc1 = ""
				strc2 =""
				sec = 0
				if l_validity="2"  Then
					strc2 = "checked='checked'"
					strdiv = "display:inline;"
					sec = 2
					l_date3 = rsAtt("l_date3")
					l_date4 = rsAtt("l_date4")
				else
					strc1 = "checked='checked'"
					strdiv = "display:none;"
					sec = 2
					l_date3 = ""
					l_date4 = ""
				end if
				Response.write "" & vbcrlf & "                                                              <TR class=top style=""HEIGHT: 22px"">" & vbcrlf & "                                                                       <TD style=""PADDING-RIGHT: 10px; PADDING-LEFT: 10px"">" & vbcrlf & "                                                                              <CENTER>" & vbcrlf & "                                                                                <SPAN style=""FONT-WEIGHT: lighter; COLOR: #5b7cae"">" & vbcrlf & "                                                                                       <A href='down.asp?WDUrl="
				Response.write FileName
				Response.write "&oldname="
				Response.write  Server.URLEncode(FileNameOld)
				Response.write "&fromtype=mxlist' target='_blank'>"
				Response.write FileNameOld
				Response.write "</A>" & vbcrlf & "                                                                                  <INPUT type=hidden value="""
				Response.write FileNameNew
				Response.write """ name=""FileNameNew"">" & vbcrlf & "                                                                                        <INPUT type=hidden value="""
				Response.write FolderName
				Response.write """ name=""FolderName"">" & vbcrlf & "                                                                                 <INPUT type=hidden value="""
				Response.write FileNameOld
				Response.write """ name=""FileNameOld"">" & vbcrlf & "                                                                                        <INPUT type=hidden value="""
				Response.write FileDesc
				Response.write """ name=""FileDesc"">" & vbcrlf & "                                                                                   <INPUT type=hidden value="""
				Response.write FileSize
				Response.write """ name=""FileSize"">" & vbcrlf & "                                                                                   <INPUT type=hidden value="""
				Response.write FileSize
				Response.write """ name=""FileSize1"">" & vbcrlf & "                                                                                  <INPUT type=hidden value="""
				Response.write now()
				Response.write """ name=""FileInDate"">" & vbcrlf & "                                                                                 <INPUT type=hidden value="""
				Response.write FileAccessID
				Response.write """ name=""FileAccessID"">" & vbcrlf & "                                                                                       <INPUT type=hidden value="""
				Response.write fid
				Response.write """ name=""fid"">" & vbcrlf & "                                                                                </SPAN>" & vbcrlf & "                                                                         </CENTER>" & vbcrlf & "                                                                       </TD>" & vbcrlf & "                                                                   <TD style=""PADDING-RIGHT: 10px; PADDING-LEFT: 10px"">" & vbcrlf & "                                                                              <CENTER><SPAN class=""reseetTextColor"" style=""FONT-WEIGHT: lighter; COLOR: #5b7cae"">"
				Response.write FormatFileSize2(Clng(FileSize))
				Response.write "</SPAN></CENTER>" & vbcrlf & "                                                                      </TD>" & vbcrlf & "                                                                   <TD style=""PADDING-RIGHT: 10px; PADDING-LEFT: 10px"">" & vbcrlf & "                                                                              <CENTER><SPAN class=""reseetTextColor"" style=""FONT-WEIGHT: lighter; COLOR: #5b7cae;word-break:break-all"">"
				Response.write FormatFileSize2(Clng(FileSize))
				Response.write FileDesc
				Response.write "</SPAN></CENTER>" & vbcrlf & "                                                                      </TD>" & vbcrlf & "                                                                   <TD style=""PADDING-RIGHT: 10px; PADDING-LEFT: 10px"">"
				Response.write FileDesc
				Response.write "" & vbcrlf & "                                                                      <input  name=""l_validity"
				Response.write findex
				Response.write """ id=""l_validity"
				Response.write findex
				Response.write """ value=""1""  type=radio  onclick=""change_l("
				Response.write findex
				Response.write ")"" "
				Response.write strc1
				Response.write "> 永久 <input  name=""l_validity"
				Response.write findex
				Response.write """ id=""l_validity"
				Response.write findex
				Response.write """  type=radio  onclick=""change1_l("
				Response.write findex
				Response.write ")"" value=""2"" "
				Response.write strc2
				Response.write ">短期&nbsp;<div id=""l_mxh"
				Response.write findex
				Response.write """ style="""
				Response.write strdiv
				Response.write """><input name=""l_date3_"
				Response.write findex
				Response.write """ type=""text""   id=""l_date3_"
				Response.write findex
				Response.write """ size=""10"" maxlength=""50"" Class=""DatePick"" style=""width:70px"" onclick=""datedlg.show();"" onChange=""secShortDate_l("
				Response.write findex
				Response.write ")"" readonly=""readonly"" value="""
				Response.write l_date3
				Response.write """> 至：<input name=""l_date4_"
				Response.write findex
				Response.write """ type=""text"" id=""l_date4_"
				Response.write findex
				Response.write """ size=""10"" maxlength=""50"" Class=""DatePick"" style=""width:70px"" onclick=""datedlg.show();"" onChange=""secShortDate_l("
				Response.write findex
				Response.write ")"" readonly=""readonly"" value="""
				Response.write l_date4
				Response.write """><input type=""hidden"" name=""shortSec"
				Response.write findex
				Response.write """ id=""shortSec"
				Response.write findex
				Response.write """ value="""
				Response.write sec
				Response.write """ dataType=""Range"" min=2 max=2  msg=""请选择起止日期""> <span class=""red"">*</span><input type='hidden' name='findex' value='"
				Response.write findex
				Response.write "'></div>" & vbcrlf & "                                                                     </TD>" & vbcrlf & "                                                                   <TD style=""PADDING-RIGHT: 10px; PADDING-LEFT: 10px"">                                                              " & vbcrlf & "                                                                                <CENTER>" & vbcrlf & "                                                                                        "
				Response.write findex
				if edit="edit" and (archive = 0 or spdel <> 1)then
					Response.write "" & vbcrlf & "                                                                                     <a class='fileUpdate-btn' fid='"
'if edit="edit" and (archive = 0 or spdel <> 1)then
					Response.write FileAccessID
					Response.write "' href='javascript:;' onClick=""showUploadForm(this);"">修改</a>" & vbcrlf & "                                                                                 <SPAN style=""FONT-WEIGHT: lighter; COLOR: #5b7cae""><A onclick=delRow(this,"
					Response.write FileAccessID
					Response.write FileAccessID
					Response.write ",'"
					Response.write edit
					Response.write "'); href=""###"">删除</A></SPAN>" & vbcrlf & "                                                                                 "
				else
					Response.write "" & vbcrlf & "                                                                                     <SPAN style=""FONT-WEIGHT: lighter; COLOR: #5b7cae"">只读</SPAN>" & vbcrlf & "                                                                                    "
				end if
				Response.write "" & vbcrlf & "                                                                             <CENTER>" & vbcrlf & "                                                                        </TD>" & vbcrlf & "                                                           </TR>" & vbcrlf & ""
				rsAtt.movenext
			wend
		end if
		rsAtt.close
		set rsAtt=nothing
	end sub
	Function FormatFileSize2(fsize)
		Dim radio,k,m,g,unitTMP
		k = 1024
		m = 1024*1024
		g = 1024*1024*1024
		radio = 1
		If Fix(fsize / g) > 0.0 Then
			unitTMP = "GB"
			radio = g
		ElseIf Fix(fsize / m) > 0 Then
			unitTMP = "MB"
			radio = m
		ElseIf Fix(fsize / k) > 0 Then
			unitTMP = "KB"
			radio = k
		else
			unitTMP = "B"
			radio = 1
		end if
		If radio = 1 Then
			FormatFileSize2 = fsize & "&nbsp;" & unitTMP
		else
			FormatFileSize2 = FormatNumber(fsize/radio,3) & unitTMP
		end if
	end function
	
	Dim xmlPath,rs1,sql1,skd,commSP,nextSpId,nextGates,ordtype,i,arr_gates1,arr_gates2,bakll
	Dim ord, headtitle ,rs ,title,  bh , bz ,intro ,mode ,mxcss, money1, spord ,sp ,cateid_sp,status
	Dim lead , startdate ,enddate,hzcss, money_hz,money_mx ,updatecss,C_Level,sql,rs88,khid,sqlStr,rd,draft,isAccess
	Sub messagePost(msgid)
		If msgid = "" then
			Call Page_Load
		elseif msgid = "getPostList" then
			Call app_getPostList
		end if
	end sub
	Sub Page_Load
		if not app.power.existsPower2(78,13) then
			Response.write "no power!"
			exit sub
		end if
		headtitle="文档添加"
		status="Add"
		bakll = Trim(request("bakll"))
		sql="Delete document where addcate="& info.user &" and del=7"
		cn.Execute(sql)
		set rs88 = cn.execute("EXEC erp_getdjbh 78,"&session("personzbintel2007"))
		khid=rs88(0).value
		set rs88=nothing
		sqlStr="Insert Into document(addcate,date7,wdid,del) values('"
		sqlStr=sqlStr &  info.user  & "','"
		sqlStr=sqlStr & now & "','"
		sqlStr=sqlStr & khid & "','"
		sqlStr=sqlStr & 7 & "')"
		cn.execute(sqlStr)
		rd = app.GetIdentity("document","id","addcate","")
		app.addDefaultScript
		Response.write app.DefTopBarHTML(app.virPath, "", headtitle, "")
		session("zbintel_Documentsubmit")=now()
		Response.write "" & vbcrlf & "<script>window.rd ="
		Response.write rd
		Response.write "; </script>" & vbcrlf & ""
		Response.write "<!--上传文件模块开始-->"
		Dim xmlPath,allowExts
		xmlPath = "../../sysa/document/upload/" & Timer & ".xml"
		allowExts = "|doc|docx|ppt|pptx|xls|xlsx|avi|bmp|jpeg|png|rmvb|gif|jpg|txt|pdm|zip|7z|rar|iso|apk|pdf|dwg|pptx|dwt|exb|eps|wmf|jfif|tif|tiff|xmind|psd|swf|mpeg|mp4|mov|flv|3gp|mp3|PDF|wps|"
		Response.write "" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "/*#bg{ display:none;position:absolute;top:0%;left:0%;width:100%;height:100%;background-color:#B9C5DD;z-index:1001;-moz-opacity:0.7;opacity:.70;filter:alpha(opacity=50);}" & vbcrlf & "*/" & vbcrlf & ".progress {" & vbcrlf & "    position: absolute;" & vbcrlf & "    filter:alpha(opacity=80);" & vbcrlf & "    padding: 4px;" & vbcrlf & "    top: 50px;" & vbcrlf & "    left: 400px;" & vbcrlf & "    font-family: Verdana, Helvetica, Arial, sans-serif;" & vbcrlf & "    font-size: 9px;" & vbcrlf & "    z-index:1002px;" & vbcrlf & "    width: 250px;" & vbcrlf & "    height:100px;" & vbcrlf & "    background: #DAEAFA;" & vbcrlf & "    color: #3D2C05;" & vbcrlf & "    border: 1px solid #715208;" & vbcrlf & "    /* Mozilla proprietary */" & vbcrlf & "    -moz-border-radius: 5px;" & vbcrlf & "    /*-moz-opacity: 0.95; */" & vbcrlf & "}" & vbcrlf & ".progress table,.progress td{" & vbcrlf & "  font-size:9pt;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".Bar{" & vbcrlf & "  width:100%;" & vbcrlf & "    height:13px;" & vbcrlf & "    background-color:#CCCCCC;" & vbcrlf & "    border: 1px inset #666666;" & vbcrlf & "    margin-bottom:4px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".ProgressPercent{" & vbcrlf & "    font-size: 9pt;" & vbcrlf & "    color:#FFFFFF;" & vbcrlf & "    height: 13px;" & vbcrlf & "      line-height:13px; " & vbcrlf & "    position: absolute;" & vbcrlf & "    z-index: 20;" & vbcrlf & "    width: 100%;" & vbcrlf & "    text-align: center;      " & vbcrlf & "}" & vbcrlf & ".ProgressBar{" & vbcrlf & "  background-color:blue;" & vbcrlf & "    width:1px;" & vbcrlf & "    height:13px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "#sash_left { width:430px; float:left; }" & vbcrlf & "#sash_left ul { text-align:left; vertical-align:middle; padding-left:75px; }" & vbcrlf & "#sash_left ul li { line-height:16px; margin:2px 0; }" & vbcrlf & ".b1, .b2, .b3, .b4 { font-size:1px; overflow:hidden; display:block; }" & vbcrlf & ".b1 { height:1px; background:#aaa; margin:0 5px; }" & vbcrlf & ".b2 { height:1px; background:url(../sysa/../images/up_1.gif); border-right:2px solid #AAA; border-left:2px solid #AAA; margin:0 3px; }" & vbcrlf & ".b3 { height:1px; background:url(../sysa/../images/up_1.gif); border-right:1px solid #AAA; border-left:1px solid #AAA; margin:0 2px; }" & vbcrlf & ".b4 { height:2px; background:url(../sysa/../images/up_1.gif); border-right:1px solid #AAA; border-left:1px solid #AAA; margin:0 1px; }" & vbcrlf & ".contentb { height:99px; background:url(../sysa/../images/up_1.gif); border-right:1px solid #AAA; border-left:1px solid #AAA; }" & vbcrlf & "</style>" & vbcrlf & "<div id=""fupload"" style=""position:absolute;display:none;width:300px;box-shadow:0 0 10px #666;background:#bbb"">" & vbcrlf & "        <b class=""b1""></b><b class=""b2""></b><b class=""b3""></b><b class=""b4""></b>" & vbcrlf & "        <div class=""contentb"" style=""padding-left:10px;padding-top:10px;padding-right:10px"">" & vbcrlf & "                <form name=""upform2"" method=""post"" action=""ProcUpload.asp?opt=Upload&xmlPath="
		Response.write xmlPath
		Response.write """ onsubmit=""return chkFrm();"" enctype=""multipart/form-data"" target=""if1"" style=""margin:0;padding:0;"">" & vbcrlf & "                      <div class=""reseetTextColor"" style=""float:right;cursor:pointer"" onmouseover=""this.style.color='red'"" onmouseout=""this.style.color='#2F496E';"" onclick=""document.getElementById('fupload').style.display='none';"" id=""fclose"">关闭</div>" & vbcrlf & "                   <div class=""reseetTextColor"" style=""font-weight:bolder"">文件上传</div>" & vbcrlf & "                      <div class=""reseetTextColor"" style=""height:40px;position:absolute"">选择文件：<input type=""text"" id=""txt"" disabled style=""width:150px"" name=""txt"" />" & vbcrlf & "                             <input type=""button"" name=""sbtn"" id=""sbtn"" value=""浏览"" class=""oldbutton"" style=""margin:0""><input type=""file"" name=""filefield"" id=""filefield""  hidefocus=""hidefocus"" onclick=""sbtn.click"" style=""filter:alpha(opacity=0);-moz-opacity:0;opacity:0;position:relative;top:-23px;left:60px;"" onchange=""txt.value=this.value"">" & vbcrlf & "                       </div>" & vbcrlf & "                  <div class=""reseetTextColor"" style=""position:absolute;top:72px;color:#5B7CAE"">文件描述：<input type=""text"" style=""width:150px"" name=""filedesc"">" & vbcrlf & "                           <inputtype=""submit"" value=""上传"" class=""oldbutton"" style='border:1px solid #EFEFEF;margin:0'>" & vbcrlf & "                           <input type=""hidden"" name=""edit"" value=""0"" id=""edit"">" & vbcrlf & "                           <input type=""hidden"" name=""fid"" value=""0"" id=""fid"">" & vbcrlf & "                             <input type=""hidden"" name=""pageType"" value=""0"" id=""pageType"">" & vbcrlf & "                        </div>" & vbcrlf & "          </form>" & vbcrlf & " </div>" & vbcrlf & "  <b class=""b4""></b><b class=""b3""></b><b class=""b2""></b><b class=""b1""></b>" & vbcrlf & "</div>" & vbcrlf & "<iframe name=""if1"" style=""width:100px;height:100px;display:none"" src=""""></iframe>" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "" & vbcrlf & "var allowExts="""
		Response.write allowExts
		Response.write """;" & vbcrlf & "var findex = 0;" & vbcrlf & "function addAtt(strName,strSize,strDesc,strDelLink)" & vbcrlf & "{" & vbcrlf & "      var tbobj=document.getElementById(""atttb"");" & vbcrlf & "       if(tbobj.rows.length==0)" & vbcrlf & "        {" & vbcrlf & "               var th=tbobj.insertRow(-1);" & vbcrlf & "             th.className="""";" & vbcrlf & "               th.style.height=""25px""" & vbcrlf & "            var th1=th.insertCell(-1);" & vbcrlf & "              var th2=th.insertCell(-1);" & vbcrlf & "              var th3=th.insertCell(-1);" & vbcrlf & "              var th4=th.insertCell(-1);" & vbcrlf & "              var th5=th.insertCell(-1);" & vbcrlf & "              th1.innerHTML=""<center><span class='reseetTextColor' style='font-weight:bolder'>文件名</span></center>"";" & vbcrlf & "         th2.innerHTML=""<center><span class='reseetTextColor' style='font-weight:bolder'>文件大小</span></center>"";" & vbcrlf & "                th3.innerHTML=""<center><span class='reseetTextColor' style='font-weight:bolder'>文件描述</span></center>"";" & vbcrlf & "                th4.innerHTML=""<center><span class='reseetTextColor' style='font-weight:bolder'>有效期限</span></center>"";" & vbcrlf & "                th5.innerHTML=""<center><span class='reseetTextColor' style='font-weight:bolder'>删除</span></center>"";" & vbcrlf & "    }" & vbcrlf & "       findex = $ID(""maxfindex"").value;" & vbcrlf & "   findex = findex*1 + 1;" & vbcrlf & "  $ID(""maxfindex"").value = findex;" & vbcrlf & "  var newtr=tbobj.insertRow(-1);" & vbcrlf & "  var newcell1=newtr.insertCell(-1);" & vbcrlf & "      var newcell2=newtr.insertCell(-1);" & vbcrlf & "      var newcell3=newtr.insertCell(-1);"& vbcrlf &      "var newcell4=newtr.insertCell(-1);" & vbcrlf &       "var newcell5=newtr.insertCell(-1);" & vbcrlf &       "var l_validity = $(""input[name=validity]:checked"").val();" & vbcrlf &  "var strdiv = """";" & vbcrlf &   "var strc1 = """";" & vbcrlf &    "var strc2 = """";" & vbcrlf &    "var l_date3 = """";" & vbcrlf &         "var l_date4 = """";" & vbcrlf &  "var sec = 0;" & vbcrlf &     "var msg = ""选择起止日期"";" & vbcrlf &  "if (l_validity==""2"")" & vbcrlf &       "{" & vbcrlf &                "strc2 = ""checked=\""checked\"""";" & vbcrlf &               "strdiv = ""display:inline;"";" & vbcrlf &                "sec = $ID(""shortSec"").value;" & vbcrlf & "            msg = $ID(""shortSec"").getAttribute(""msg"");" & vbcrlf & "          l_date3 =  $ID(""date3"").value;" & vbcrlf & "            l_date4 =  $ID(""date4"").value;" & vbcrlf & "    }else{" & vbcrlf & "          strc1 = ""checked=\""checked\"""";" & vbcrlf & "              strdiv = ""display:none;"";" & vbcrlf & "         sec = 2;" & vbcrlf& "" & vbcrlf & "        }" & vbcrlf & "       var strvalidity = ""<input  name=\""l_validity""+ findex +""\"" id=\""l_validity""+ findex +""\"" value=\""1\""  type=radio  onclick=\""change_l(""+ findex +"")\"" ""+ strc1+""> 永久 <input  name=\""l_validity""+ findex +""\"" id=\""l_validity""+ findex +""\""  type=radio  onclick=\""change1_l(""+ findex +"")\"" value=\""2\"" ""+ strc2+"">短期&nbsp;<div id=\""l_mxh""+ findex +""\"" style=\""""+ strdiv +""\""><input name=\""l_date3_""+ findex +""\"" type=\""text\""   id=\""l_date3_""+ findex +""\"" size=\""10\"" maxlength=\""50\"" Class=\""DatePick\"" style=\""width:70px;\""  onclick=\""datedlg.show();\"" onChange=\""secShortDate_l(""+ findex +"")\"" readonly=\""readonly\"" value=\""""+l_date3+""\""> 至 <input name=\""l_date4_""+ findex +""\"" type=\""text\"" id=\""l_date4_""+ findex +""\"" size=\""10\"" maxlength=\""50\"" Class=\""DatePick\"" style=\""width:70px;\""  onclick=\""datedlg.show();\"" onChange=\""secShortDate_l(""+ findex +"")\"" readonly=\""readonly\"" value=\""""+l_date4+""\""><input type=\""hidden\"" name=\""shortSec""+findex+""\"" id=\""shortSec""+findex+""\"" value=\"""" + sec + ""\"" dataType=\""Range\"" min=2 max=2  msg=\""""+ msg +""yle='font-weight:lighter'>""+strName+""</span></center>"";" & vbcrlf & "     newcell2.style.paddingLeft=""20px"";" & vbcrlf & "        newcell2.style.paddingRight=""20px"";" & vbcrlf & "       newcell2.innerHTML=""<center><span class='reseetTextColor' style='font-weight:lighter'>""+strSize+""</span></center>"";" & vbcrlf & "   newcell3.style.paddingLeft=""20px"";" & vbcrlf & "        newcell3.style.paddingRight=""20px"";" & vbcrlf & "       newcell3.innerHTML=""<center><span class='reseetTextColor' style='font-weight:lighter;word-break:break-all'>""+strDesc+""</span></center>"";" & vbcrlf & "    newcell4.style.paddingLeft=""10px"";" & vbcrlf & "       newcell4.style.paddingRight=""10px"";" & vbcrlf & "       newcell4.innerHTML=""<span class='reseetTextColor' style='font-weight:lighter'>""+strvalidity+""</span>"";" & vbcrlf & "      newcell5.style.paddingLeft=""20px"";" & vbcrlf & "        newcell5.style.paddingRight=""20px"";" & vbcrlf & "       newcell5.innerHTML=""<center><span style='font-weight:lighter'>""+strDelLink+""</span></center>"";" & vbcrlf & "        var tmpFrame;" & vbcrlf & "   if(tmpFrame=parent.document.getElementById(""cFF"")){tmpFrame.style.height=document.body.scrollHeight+0+""px"";}" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function change_l(index){" & vbcrlf & "     $ID(""l_mxh""+index).style.display=""none"";" & vbcrlf & "    $ID(""shortSec""+index+"""").value=2;" & vbcrlf & "}" & vbcrlf & "function change1_l(index){" & vbcrlf & "        $ID(""l_mxh""+index).style.display=""inline"";" & vbcrlf & "  secShortDate_l(index);" & vbcrlf & "}" & vbcrlf & "function secShortDate_l(index){" & vbcrlf & "    var beginDate=$ID(""l_date3_""+ index +"""").value;" & vbcrlf & "     var endDate=$ID(""l_date4_""+ index +"""").value;" & vbcrlf & "       if(beginDate!="""" && endDate!=""""){" & vbcrlf & "           $ID(""shortSec""+index+"""").value=2;" & vbcrlf & "           var d1 = new Date(beginDate.replace(/\-/g, ""\/""));" & vbcrlf & "              var d2 = new Date(endDate.replace(/\-/g, ""\/""));" & vbcrlf & "          if(d1>=d2){" & vbcrlf & "                     $ID(""shortSec""+index+"""").value=1;" & vbcrlf & "                   $ID(""shortSec""+index+"""").setAttribute(""msg"",""开始时间不能大于或等于结束时间"");" & vbcrlf & "          }" & vbcrlf & "   }else{" & vbcrlf & "          $ID(""shortSec""+index+"""").value=1;" & vbcrlf & "           $ID(""shortSec""+index+"""").setAttribute(""msg"",""选择起止日期"");" & vbcrlf & "    }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function delRow(obj,ord,actionac)" & vbcrlf & "{" & vbcrlf & "    var xmlhttp = createXMLHttps();"& vbcrlf &      "if(confirm(""确定要删除此文件吗（删除后不可恢复）？""))" & vbcrlf &      "{" & vbcrlf &                "var trobj=obj.parentElement.parentElement.parentElement.parentElement;" & vbcrlf &           "var hidobj=trobj.getElementsByTagName(""input"")" & vbcrlf &             "var fname=hidobj[0].value;" & vbcrlf &               "var foname=hidobj[1].value;" & vbcrlf & "           var ajaxurl=""ProcDelFile.asp?t=0&ord=""+ord+""&f=""+escape(foname+""/""+fname)+""&actionac=""+actionac+""&t=""+Math.random();" & vbcrlf & "              xmlhttp.open(""GET"",ajaxurl,true);" & vbcrlf & "         xmlhttp.send(null);" & vbcrlf & "             xmlHttp.onreadystatechange = function(){" & vbcrlf & "if (xmlHttp.readyState < 4) {" & vbcrlf & "           }" & vbcrlf & "               if (xmlHttp.readyState == 4) {" & vbcrlf & "          var response = xmlHttp.responseText.split(""</noscript>"")[1];" & vbcrlf & "              xmlHttp.abort();" & vbcrlf & "                }" & vbcrlf & "               };" & vbcrlf & "              //              xmlHttp.send(null);" & vbcrlf & "             trobj.parentElement.removeChild(trobj);" & vbcrlf & "            var tbobj=document.getElementById(""atttb"");" & vbcrlf & "               if(tbobj.rows.length==1) tbobj.deleteRow(0);" & vbcrlf & "    }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function GetCurObjectPos(element){" & vbcrlf & "    if(arguments.length !=1||element==null){return null;}" & vbcrlf & "      var elmt=element;" & vbcrlf & "       var offsetTop=elmt.offsetTop;" & vbcrlf & "   var offsetLeft=elmt.offsetLeft;" & vbcrlf & " var offsetWidth=elmt.offsetWidth;" & vbcrlf & "       var offsetHeight=elmt.offsetHeight;" & vbcrlf & "     while (elmt=elmt.offsetParent){if(elmt.style.position=='absolute'||elmt.style.position=='relative'" & vbcrlf & "     || (elmt.style.overflow!='visible'&&elmt.style.overflow !='')){break;}" & vbcrlf & "  offsetTop+=elmt.offsetTop;" & vbcrlf & "      offsetLeft +=elmt.offsetLeft;}" & vbcrlf & "  return{top:offsetTop,left:offsetLeft,width:offsetWidth,height:offsetHeight};" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "// 维护窗口唯一性" & vbcrlf & "function uniqueWin(){" & vbcrlf & "    var f = $(""form[name=upform2]"").parents(""#fupload"");        " & vbcrlf & "        var pp = $("".ProgressPercent"");" & vbcrlf & "   var pb = $("".ProgressBar""); " & vbcrlf & "      var usize = $(""uploadSize"");" & vbcrlf & "   var uspeed = $(""uploadSpeed"");" & vbcrlf & "    var tTime = $(""totalTime"");" & vbcrlf & "       var lTime = $(""leftTime"");" & vbcrlf & "        if(f.size() > 1){f.eq(0).remove(); };" & vbcrlf & "   if(pp.size() > 1){pp.eq(0).remove(); };" & vbcrlf & " if(pb.size() > 1){pb.eq(0).remove(); };" & vbcrlf & "" & vbcrlf & "     if(usize.size() > 1){usize.eq(0).remove(); };" & vbcrlf & "   if(uspeed.size() > 1){uspeed.eq(0).remove(); };" & vbcrlf & " if(tTime.size() > 1){tTime.eq(0).remove(); };" & vbcrlf & "   if(lTime.size() > 1){lTime.eq(0).remove(); };" & vbcrlf & "};" & vbcrlf &"" & vbcrlf & "" & vbcrlf & "function showUploadForm(obj)" & vbcrlf & "{" & vbcrlf & "     uniqueWin();" & vbcrlf & "    var xy = GetCurObjectPos(obj);" & vbcrlf & "  var showobj=document.getElementById(""fupload"");" & vbcrlf & "           showobj.style.display=""block"";" & vbcrlf & "            showobj.style.left=xy.left + ""px"";" & vbcrlf & "                showobj.style.top= (xy.top + 12) + ""px"";" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "$(""form[name=upform2]"").find(""#fclose"").click(function(){" & vbcrlf & "   uniqueWin();" & vbcrlf & "});" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "function chkFrm()" & vbcrlf & "{" & vbcrlf& "  uniqueWin();" & vbcrlf & "" & vbcrlf & "  var objFrm = document.getElementsByName(""upform2"")[0];" & vbcrlf & "  if(objFrm.filefield.value=="""")" & vbcrlf & "  {" & vbcrlf & "           app.Alert(""请选择一个文件"");" & vbcrlf & "              return false;" & vbcrlf & "  }" & vbcrlf & "  if(objFrm.filedesc.value.length>200)" & vbcrlf & "  {" & vbcrlf & "    app.Alert(""文件描述不能超过200字"");" & vbcrlf & "       return false;" & vbcrlf & "  }" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "  var arrExt=objFrm.txt.value.split(""."");" & vbcrlf & "  var fExt=arrExt[arrExt.length-1];" & vbcrlf & "  if(allowExts.toLowerCase().indexOf('|'+fExt.toLowerCase()+'|')<0 && arrExt.length!=0)" & vbcrlf & "  {" & vbcrlf & "        app.Alert(""上传的文件不合法,只能上传"
		Response.write allowExts
		Response.write mid(replace(allowExts,"|","，"),2,len(allowExts)-2)
		Response.write allowExts
		Response.write "格式的文件！"");" & vbcrlf & "    return false;" & vbcrlf & "  }" & vbcrlf & "" & vbcrlf & "  //objFrm.action = ""ProcUpload.asp?opt=Upload&xmlPath="
		Response.write xmlPath
		Response.write """;" & vbcrlf & "  document.getElementById(""fupload"").style.display=""none"";" & vbcrlf & "  document.getElementById(""bg"").style.display=""block"";" & vbcrlf & "" & vbcrlf & " ProgressPercent.innerHTML = ""0%"";" & vbcrlf & " ProgressBar.style.width = ""0%"";" & vbcrlf & "   uploadSize.innerHTML = '0';" & vbcrlf & "  uploadSpeed.innerHTML = '0';" & vbcrlf & "    totalTime.innerHTML = '0';" & vbcrlf & "      leftTime.innerHTML = '0';" & vbcrlf & "  startProgress('"
		Response.write xmlPath
		Response.write "');//启动进度条" & vbcrlf & "  return true;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "//启动进度条" & vbcrlf & "function startProgress(xmlPath)" & vbcrlf & "{" & vbcrlf & "  displayProgress();" & vbcrlf & "  setProgressDivPos();" & vbcrlf & "  setTimeout(""DisplayProgressBar('"" + xmlPath + ""')"",500);"& vbcrlf &" } "& vbcrlf & vbcrlf & vbcrlf &" function xmlNodeValue(nd){ "& vbcrlf &"     return nd.text || nd.textContent; "& vbcrlf &" } "& vbcrlf &" function DisplayProgressBar(xmlPath) "& vbcrlf &" { "& vbcrlf &"     var xmlhttp = window.XMLHttpRequest ? ( new window.XMLHttpRequest()) :  (new ActiveXObject(""MSXML2.XMLHTTP""));" & vbcrlf & "    xmlhttp.open(""GET"", xmlPath, false);" & vbcrlf & "    xmlhttp.send();" & vbcrlf & "    var xmlDoc = xmlhttp.responseXML;" & vbcrlf & "    if(xmlDoc==null){ return; }" & vbcrlf & "    var root = xmlDoc.documentElement;   //根节点" & vbcrlf& "    if(root==null){ return; }" & vbcrlf & "    var totalbytes =xmlNodeValue(root.childNodes[0]);" & vbcrlf & "    var uploadbytes = xmlNodeValue(root.childNodes[1]);" & vbcrlf & "    var percent =xmlNodeValue(root.childNodes[2]);" & vbcrlf & "    document.getElementById(""ProgressPercent"").innerHTML = percent + ""%"";" & vbcrlf & "    document.getElementById(""ProgressBar"").style.width = percent + ""%"";" & vbcrlf & "    document.getElementById(""uploadSize"").innerHTML = uploadbytes;" & vbcrlf & "    document.getElementById(""uploadSpeed"").innerHTML = xmlNodeValue(root.childNodes[3]);"& vbcrlf & "    document.getElementById(""totalTime"").innerHTML = xmlNodeValue(root.childNodes[4]);" & vbcrlf & "    document.getElementById(""leftTime"").innerHTML = xmlNodeValue(root.childNodes[5]);" & vbcrlf & "    if (percent<100)" & vbcrlf & "    {" & vbcrlf & "        setTimeout(""DisplayProgressBar('"" + xmlPath + ""')"",1000);" & vbcrlf & "    }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function displayProgress()" & vbcrlf & "{" & vbcrlf & "  var objProgress = document.getElementById(""Progress"");" & vbcrlf & "  objProgress.style.display = """";" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function closeProgress()" & vbcrlf & "{" & vbcrlf & "  var objProgress = document.getElementById(""Progress"");" & vbcrlf & "  objProgress.style.display = ""none"";" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function setProgressDivPos()" & vbcrlf & "{" & vbcrlf & "       var objProgress = document.getElementById(""Progress"");" & vbcrlf & "       objProgress.style.top = document.body.scrollTop+(document.body.clientHeight-document.getElementById(""Progress"").offsetHeight)/2" & vbcrlf & "   objProgress.style.left = document.body.scrollLeft+(document.body.clientWidth-document.getElementById(""Progress"").offsetWidth)/2;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "// KILLER.2015.10.28 修改上传文件框位置" & vbcrlf & "setTimeout(function(){" & vbcrlf & "        $("".fileUpdate-btn"").live(""click"",function(){       " & vbcrlf & "                var f = $(""#fupload"");" & vbcrlf & "            var w = f.width();" & vbcrlf & "              var left = parseInt(f.css(""left"")) - w;" & vbcrlf & "" & vbcrlf & "               $(""#fupload"").css({left:left+""px""});" & vbcrlf & "" & vbcrlf & "                var fid = $(this).attr(""fid"");" & vbcrlf & "            var pType = $(this).attr(""pageType"");" & vbcrlf & "             " & vbcrlf & "                f.find(""#edit"").val(1);" & vbcrlf & "           f.find(""#fid"").val(fid);" & vbcrlf & "             f.find(""#pageType"").val(pType);" & vbcrlf & "           " & vbcrlf & "        });" & vbcrlf & "},500);" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "// KILLER.2015.10.28 处理文件修改" & vbcrlf & "function fileUpdate(obj){    " & vbcrlf & "        if(obj.ptype == ""mxList""){        // 明细列表修改文件" & vbcrlf &"          var url = ""ajax.asp"";" & vbcrlf & "             var fid = obj.fid," & vbcrlf & "                      fname = obj.fname," & vbcrlf & "                      fsize = obj.fsize," & vbcrlf & "                      fsizeInt = obj.fsizeInt," & vbcrlf & "                        ftype = obj.ftype," & vbcrlf & "                      fUrl = obj.fUrl," & vbcrlf & "                        fDesc = obj.fDesc" & vbcrlf & "" & vbcrlf &"          // 临时修改数据" & vbcrlf & "         $.post(url,{act:""fileTempUpdate"",fid:fid},function(data){" & vbcrlf & "                 var obj = eval(""var o = "" + data + "";o"");" & vbcrlf & "                   " & vbcrlf & "                        if(obj.err !== ""0""){" & vbcrlf & "                              app.Alert(obj.err);" & vbcrlf & "                             return false;" & vbcrlf & "                   };" & vbcrlf & "" & vbcrlf & "                     // 上传文件后更新界面信息" & vbcrlf & "                       var td = $("".fileUpdate-btn[fid=""+ fid +""]"").parent().parent().siblings(""td"");" & vbcrlf & "                        td.eq(2).find(""div"").html(fname);         " & vbcrlf & "                        var lie = $(""#lie_1"").val();              " & vbcrlf & "                        if(lie == 0){" & vbcrlf & "                           td.eq(3).find(""div"").html(fsize);" & vbcrlf & "                        }else if(lie == 1){" & vbcrlf & "                             td.eq(3).find(""div"").html(ftype);" & vbcrlf & "                 };" & vbcrlf & "                      " & vbcrlf & "                        // 弹出选择审批人界面                   " & vbcrlf & "                        spclient.onProcComplete = function(){" & vbcrlf & "                           var sp_id = $(""#sp_id"").val();" & vbcrlf & "var cateid_sp = $(""#spuser"").val();" & vbcrlf & "                               " & vbcrlf & "                                // 不需要审批" & vbcrlf & "                           if(typeof(sp_id) == 'undefined'){" & vbcrlf & "                                       savefile();" & vbcrlf & "                             };" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "                              $(""#_sp_sbmit"").click(function(e){" & vbcrlf & "                                        savefile();" & vbcrlf & "                                });" & vbcrlf & "                             " & vbcrlf & "                                // 保存数据" & vbcrlf & "                             function savefile(){" & vbcrlf & "                                    " & vbcrlf & "                                        var data = {" & vbcrlf & "                                            act : ""fileSave""," & vbcrlf & "                                         fid : fid," & vbcrlf & "                                              documentID : obj.documentID," & vbcrlf & "                                            cid : obj.cid," & vbcrlf & "                                            fname : escape(fname)," & vbcrlf & "                                          fsize : fsizeInt," & vbcrlf & "                                               ftype : ftype," & vbcrlf & "                                          fUrl : fUrl," & vbcrlf & "                                            fDesc : escape(fDesc)," & vbcrlf & "                                          cateid_sp : cateid_sp," & vbcrlf & "                                          sp_id : sp_id" & vbcrlf & "                                   };" & vbcrlf & "              " & vbcrlf & "                                        $.post(url,data,function(data){" & vbcrlf & "                                         var obj = eval(""var o = "" + data + "";o"");" & vbcrlf & "                                           " & vbcrlf & "                                                select_psize(1);" & vbcrlf & "                                        });" & vbcrlf & "" & vbcrlf & "                             };" & vbcrlf & "" & vbcrlf & "                      };" & vbcrlf & "" & vbcrlf & "                      spclient.GetNextSP('document',obj.documentID,0,obj.cid,"
		Response.write session("personzbintel2007")
		Response.write ",1);" & vbcrlf & "" & vbcrlf & "          " & vbcrlf & "                        // 处理选择审批人的取消操作" & vbcrlf & "                     $(""#_sp_close"").unbind(""click"");" & vbcrlf & "                    $("".panel-tool-close"").unbind(""click"");" & vbcrlf & "                     $(""#_sp_close,.panel-tool-close"").click(function(e){" & vbcrlf & "                              e.preventDefault();" & vbcrlf & "                             e.stopPropagation();" & vbcrlf & "                            if(confirm(""提示：不提交审批，您的修改将不会生效！\n　　　点击取消按钮重新选择审批人；\n　　　点击确定按钮将放弃修改！"")){" & vbcrlf & "                                        " & vbcrlf & "                                        $('#_sp_usr').window('close');" & vbcrlf & "                                  " & vbcrlf & "                                        //恢复临时修改的数据" & vbcrlf & "                                    $.post(url,{act:""fileTempRollback""},function(data){" & vbcrlf & "                                          try{" & vbcrlf & "                                                    var obj = eval(""var o = "" + data + "";o"");" & vbcrlf & "                                                   if(obj.err != ""0""){" & vbcrlf & "                                                               app.Alert(obj.err);" & vbcrlf & "                                                             return false;" & vbcrlf & "                                                   };" & vbcrlf & "                                                      " & vbcrlf & "                                                        select_psize(1);"& vbcrlf &                                              "}catch(e){};" & vbcrlf & vbcrlf &                                     "});" & vbcrlf &                              "};" & vbcrlf &                       "});" & vbcrlf & vbcrlf & vbcrlf & vbcrlf &              "});" & vbcrlf & vbcrlf &        ""       & vbcrlf &        ""          & vbcrlf &         "}else{  // 修改页面修改文件" & vbcrlf &              "var td = $("".fileUpdate-btn[fid=""+obj.fid +""]"").parent().parent().siblings(""td"");" & vbcrlf & "         td.eq(0).find(""center"").html(obj.flink);" & vbcrlf & "          td.eq(1).find(""center"").html(obj.fsize);" & vbcrlf & "          td.eq(2).find(""center"").html(obj.fDesc);" & vbcrlf & "  };" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "}" & vbcrlf & ""& vbcrlf & vbcrlf & "// 文件删除" & vbcrlf & "$("".fileDel-btn"").live(""click"",function(){" & vbcrlf &     "if(confirm(""确认要删除此文件吗（删除后不可恢复）？"")){" & vbcrlf &             "var p = $(this).parents(""tr"");" & vbcrlf &             "var fid = $(this).attr(""fid"");" & vbcrlf & vbcrlf &             "$.post(""ajax.asp"",{act:""fileDel"",fid:fid},function(){" & vbcrlf & "                     p.remove();" & vbcrlf & "                     select_psize(1);" & vbcrlf & "                });" & vbcrlf & "                             " & vbcrlf & "        };" & vbcrlf & "" & vbcrlf & "});" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "</script>" & vbcrlf & "<div id=""Progress"" style=""display:none;"" class=""progress"">" & vbcrlf & "    <div class=""bar"" style=""background-color:#CCCCCC; border: 1px inset #666666;"">" & vbcrlf & "        <div id=""ProgressPercent"" class=""ProgressPercent"">0%</div>" & vbcrlf & "        <div id=""ProgressBar"" class=""ProgressBar""></div>" & vbcrlf & "    </div>" & vbcrlf & "<table border=""0"" cellspacing=""0"" cellpadding=""1"" style=""table-layout:fixed;"">" & vbcrlf &         "<tr>" & vbcrlf &             "<td width=""55"">已经上传</td>" & vbcrlf &             "<td width=""5"">:</td>" & vbcrlf &             "<td width=""190"" id=""uploadSize""></td> & vbcrlf & </tr>" & vbcrlf & "        <tr>" & vbcrlf & "            <td>上传速度</td>" & vbcrlf & "            <td>:</td>" & vbcrlf & "            <td id=""uploadSpeed"" align=""left"">&nbsp;</td>" & vbcrlf & "        </tr>" & vbcrlf & "        <tr>" & vbcrlf & "            <td>共需时间</td>" & vbcrlf & "       <td>:</td>" & vbcrlf & "            <td id=""totalTime"" align=""left"">&nbsp;</td>" & vbcrlf & "        </tr>" & vbcrlf & "        <tr>" & vbcrlf & "            <td>剩余时间</td>" & vbcrlf & "            <td>:</td>" & vbcrlf & "            <td id=""leftTime"" align=""left"">&nbsp;</td>" & vbcrlf &"        </tr>" & vbcrlf & "    </table>" & vbcrlf & "</div>" & vbcrlf & "<div id=""bg""></div>" & vbcrlf & "<!--上传模块结束-->" & vbcrlf & ""
		'Response.write session("personzbintel2007")
		
		Response.write "" & vbcrlf & "<style type=""text/css"">" & vbcrlf & ".label{" & vbcrlf & "  border-top:0px;" & vbcrlf & " text-align:right;               " & vbcrlf & "        padding-right:4px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "#content .label {" & vbcrlf & "    height:28px;" & vbcrlf & "}" & vbcrlf & "#content tr.top  td.label {" & vbcrlf & "       height:28px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".labe2{" & vbcrlf & "    border-top:0px;" & vbcrlf & " padding-left:6px;" & vbcrlf & "}" & vbcrlf & "form{margin:0; padding:0;}" & vbcrlf & "    html{padding: 10px 10px 0;background: #efefef;box-sizing:border-box;}" & vbcrlf & "   body{background: #ffffff;}" & vbcrlf & "#atttb td{" & vbcrlf & "  border:1px solid rgb(204, 204, 204);" & vbcrlf & "}" & vbcrlf & "</style>" & vbcrlf & "<script language=""javascript"" src=""AjaxSubmit.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """ type=""text/javascript""></script>" & vbcrlf & ""
		session("uploadfile") = ""
		Response.write "" & vbcrlf & "<script language=""JavaScript"" type=""text/JavaScript"">" & vbcrlf & "    window.onload = function () {" & vbcrlf & "        //表单是iframe，获取值需要等表单加载完成以后，所以需要延迟加载" & vbcrlf & "        setInterval(askshareinit(), 200)" & vbcrlf & "    }" & vbcrlf & "    function askshareinit() {" & vbcrlf & "        var sortid = $BI(""ordtype"").value;//获取前一个默认值" & vbcrlf & "        if (sortid != """") {" & vbcrlf & "            $.post(""add.asp"", { __msgid: ""getPostList"", sortid: sortid, rd: window.rd }, function (data) {" & vbcrlf & "                $(""#ShowGXR"").html(data);" & vbcrlf & "            });" & vbcrlf & "        }" & vbcrlf & "    }" & vbcrlf & "" & vbcrlf & "</script>" & vbcrlf & "" & vbcrlf & "<script src= ""../Script/dt_add.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """  language=""javascript""></script>" & vbcrlf & "<script src= ""../Script/dt_add_2.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """ language=""javascript"" type=""text/javascript""></script>" & vbcrlf & "       <form method='POST' action='save.asp?ord="
		Response.write rd
		Response.write "' id='demo' onsubmit='delunload();return Validator.Validate(this,2);' name='demo'>    " & vbcrlf & "        <table width=""100%""  id=""content""> " & vbcrlf & " <tr class=""top"">" & vbcrlf & "          <td class=""label"" colspan=""4""><div class=""reseetTextColor"" style=""float:left; width:200px;color:#2f496e;"" align=""left"">&nbsp;<b>基本信息</b></div>" & vbcrlf & "        <div style=""float:right; width:200px;""><input type='submit' name='Submit42' id=""Submit42"" value='保存' class='oldbutton'/>&nbsp;&nbsp;<input type='button' onclick=""restbon()"" value='重填' class='oldbutton' name='B2' id=""B2"">&nbsp;</div>" & vbcrlf & "        </td>" & vbcrlf & "       </tr>" & vbcrlf & "   <tr>" & vbcrlf & "            <td class=""label"" valign=""middle""><div align=""right"">标&nbsp;&nbsp;&nbsp;&nbsp;题：</div></td>" & vbcrlf & "                <td colspan=""3"" class=""labe2"" valign=""middle""><div align=""left""><input id=""title"" type=""text"" name=""title"" size=""50""  dataType=""Limit"" min=""1"" max=""100"" msg=""标题必须在1至100字之间""/> <span class=""red"">*</span></div></td>" & vbcrlf & "        </tr>" & vbcrlf & " <tr>" & vbcrlf & "      <td valign=""middle"" class=""label"" width=""12%""><div align=""right"">文档分类：</div></td>" & vbcrlf & "         <td valign=""middle"" class=""labe2"" width=""30%""><div align=""left""><IFRAME name=""I2"" id=""I2"" SRC=""../sort3/correct_document2.asp?ID=company"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""170"" HEIGHT=""30""></IFRAME><input type=hidden name=""ordtype"" id=""ordtype""  value="""
		Response.write ordtype
		Response.write """ dataType=""Limit"" min=""1"" max=""60"" msg=""请选择分类"" onchange=""askshareinit()""><span class=""red"" id=""title_tip"" style=""vertical-align: 8px;margin-left: 3px;"">*</span></div></td>" & vbcrlf & "          <td valign=""middle"" class=""label"" width=""11%"" ><div align=""right"">机密级别：</div></td>" & vbcrlf & "            <td valign=""middle"" class=""labe2"" width=""47%""><select name=""C_Level"" id=""C_Level"">" & vbcrlf & "                        "
		Set rs=cn.execute("select id,Sort1,gate1 from sortonehy where gate2='79' order by gate1 desc ")
		do while rs.eof = False
			Response.write "<option value='" & rs("id")& "' "
			If C_Level=rs("id") Then Response.write " selected "
			Response.write ">"& rs("sort1") &"</option>"
			rs.movenext
		loop
		set rs=nothing
		Response.write "" & vbcrlf & "        </select>     </td>" & vbcrlf & "   </tr>" & vbcrlf & "   <tr>" & vbcrlf & "            <td class=""label""><div align=""right"">文档编号：</div></td>" & vbcrlf & "          <td class=""labe2""><div align=""left"">" & vbcrlf & "          <input name=""wdid"" id=""wdid"" type=""text""  value="""
		Response.write khid
		Response.write """ size=""15"" " & vbcrlf & "                 dataType=""Limit"" min=""1"" max=""50""  msg=""长度必须在1至50个字之间"" " & vbcrlf & "                       class='jquery-auto-bh' autobh-options='cfgId:78,recId:"
		Response.write khid
		Response.write rd
		Response.write ",autoCreate:false'" & vbcrlf & "                    >" & vbcrlf & "            <span class=""red"">*</span></div></td>" & vbcrlf & "                <td class=""label""><div align=""right"">有效期限：</div></td>" & vbcrlf & "    <td valign=""middle"" nowrap=""nowrap"" class=""labe2""><input  name=""validity"" id=""validity"" value=""1""  type=radio  onclick=""change()"" checked=""checked""> 永久 <input  name=""validity"" id=""validity""  type=radio  onclick=""change1()"" value=""2"">短期&nbsp;<div id=mxh1 style=""display:none;""><input name=""date3"" type=""text""   id=""date3"" size=""10"" maxlength=""50"" Class=""DatePick""  onclick=""datedlg.show();"" onChange=""secShortDate()"" readonly=""readonly""> 至 <input name=""date4"" type=""text"" id=""date4"" size=""10"" maxlength=""50"" Class=""DatePick""  onclick=""datedlg.show();"" onChange=""secShortDate()"" readonly=""readonly""><input type=""hidden"" name=""shortSec"" id=""shortSec"" value=""2"" dataType=""Range"" min=2 max=2  msg=""选择起止日期""> <span class=""red"">*</span></div></td>" & vbcrlf &    "</tr>" & vbcrlf &    "<tr>" & vbcrlf &             "<td class=""label""><div align=""right"">共享人员：</div></td>" & vbcrlf &           "<td colspan=""3"" class=""labe2"">" & vbcrlf &               "<p style=text-align:left;""><span class=""tableLinks"" style=""font-family:Arial;font-size:13px;font-weight:normal;font-style:normal;text-decoration:underline;color:#5b7cae;cursor:pointer;"" onClick=""window.open('setShare.asp?id="""
		Response.write rd
		Response.write app.base64.pwurl(rd)
		Response.write "','neww37win','width=420,height=500,fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=300,top=200');"">设置</span></p>" & vbcrlf & "        <div id=""ShowGXR""><!--显示分享人框--></div>" & vbcrlf & "        </td>" & vbcrlf & "      </tr>" & vbcrlf & " <tr>" & vbcrlf & "            <td class=""label""><div align=""right"">附&nbsp;&nbsp;&nbsp;&nbsp;件：</div></td>" & vbcrlf & "            <td colspan=""3"" class=""labe2""><div align=""left"">"
		Response.write "" & vbcrlf & "                <table id=""atttb"" class=""fileAccess"" cellspacing=""0"" cellpadding=""0"" border=""1"" style=""width:100%;table-layout:fixed; margin-top:2px;"">" & vbcrlf & "                             <col span=""1"" width=""25%""></col>" & vbcrlf & "                            <col span=""1"" width=""8%""></col>" & vbcrlf & "                              <col span=""1"" width=""20%""></col>" & vbcrlf & "                            <col span=""1"" width=""39%""></col>" & vbcrlf & "                            <col span=""1"" width=""8%""></col>" & vbcrlf & "                  "
		if isnumeric(draft) and draft<>"" and isAccess=1 Then call getUploadFileList(conn,draft,82)
		Response.write "" & vbcrlf & "                </table>" & vbcrlf & "              </div>" & vbcrlf & "              <span style=""cursor:pointer"" onClick=""showUploadForm(this);"" id=""sfe""><img src='../images/smico/3.gif'/>添加文件 </span><font color=""#FF0000""> （支持上传小于500MB的文件作为附件）</font></td>" & vbcrlf & "      </tr>        " & vbcrlf & "      <tr>" & vbcrlf & "            <td class=""label""><div align=""right"">详细描述：</div></td>" & vbcrlf & "          <td class=""labe2"" colspan=""3"" style='padding:5px'>  " & vbcrlf & "                <textarea name=""intro"" id=""intro"" cols=""90"" rows=""8"" datatype=""Limit"" min=""0"" max=""2000""  msg=""必须在2000个字之内！""></textarea><br /></td>" & vbcrlf & "        </tr>" & vbcrlf & "        " & vbcrlf & "   <tr class=""top"" id=""contentSP"" style=""display:none; background-image:url(../images/m_table_top.jpg); TEXT-ALIGN: left;""><td colspan=""4"" >&nbsp;<b>审批设置</b></td></tr>" & vbcrlf & "        <tr id=""contentSP1"" style=""display:none"">" & vbcrlf & "         <td class=""label""><div align=""right"">审批人：</div></td>" & vbcrlf & "            <td colspan=""3"" class=""labe2""><div id=""ShowSPR"" style=""position:relative""><select name='cateid_sp' id='cateid_sp' dataType='Limit' min='1' max='10' msg='请选择审批人' style='width:80px;'><option></option></select></div></td>" & vbcrlf & " </tr>     " & vbcrlf & "      <tr height=""30""><td class='gray' colspan=""4"" style='border-bottom:0px'><div align='center' style=""margin-top:8px;"">" & vbcrlf & "   <input type=""hidden"" name=""status"" id=""status"" value="""
'if isnumeric(draft) and draft<>"" and isAccess=1 Then call getUploadFileList(conn,draft,82)
		Response.write status
		Response.write """>" & vbcrlf & " <input type=""hidden"" name=""bakll"" id=""bakll"" value="""
		Response.write bakll
		Response.write """>" & vbcrlf & "    <input type=""hidden"" name=""maxfindex"" id=""maxfindex"" value="""
		Response.write findex
		Response.write """>" & vbcrlf & " <input type='submit' name='Submit42' id=""Submit42"" value='保存' class='oldbutton'/>&nbsp;&nbsp;&nbsp;&nbsp;<input type='button' value='重填' class='oldbutton' name='B2' id=""B2"" onclick=""restbon()""><br /><br /></div></td></tr>" & vbcrlf & "    </table>" & vbcrlf & "    </form>" & vbcrlf & "   <div class='bottomdiv'>&nbsp;</div>" & vbcrlf & "<script src= ""../Script/dt_add_1.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """ ></script>" & vbcrlf & ""
	end sub
	Sub app_getPostList
		Dim rs,sql,id,postView,postDown,result ,stype ,share1 ,share2
		id = Request("rd")
		sortid = request("sortid")
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT postView,postDown,share1,share2 FROM DocSortsAndSharingRelation WHERE sortonehyid = "& sortid &" "
		rs.Open sql,cn,1,1
		If Not rs.Eof Then
			postView = rs("postView").Value
			postDown = rs("postDown").Value
			share1 =rs("share1").Value
			share2 = rs("share2").Value
		end if
		rs.close
		set rs = nothing
		sqlupdate="UPDATE document SET postView = '"& postView &"', postDown = '"& postDown&"',share1='"& share1 &"',share2='"& share2 &"' WHERE id = "& id &" "
		cn.execute sqlupdate
		if share1&"" = "" and share2&"" = "" then
			stype=1
		else
			stype=0
		end if
		If stype&"" ="1" Then
			If postView&"" = "" Then postView = "-1"
'If stype&"" ="1" Then
			If postDown&"" = "" Then postDown = "-1"
'If stype&"" ="1" Then
			Dim pList : pList = postView & "," & postDown
			Set rs = server.CreateObject("adodb.recordset")
			sql = "SELECT ord,sort1 FROM sortonehy WHERE ord IN ("& pList &") ORDER BY gate1 DESC"
			rs.open sql,conn,1,1
			If Not rs.Eof Then
				Do While Not rs.Eof
					Dim pid,pname,rangeStr
					pid = rs("ord")
					pname = rs("sort1")
					If InStr(1,","& postView &",",","& pid &",",1) > 0 Then
						rangeStr = "浏览"
					else
						rangeStr = ""
					end if
					If InStr(1,","& postDown &",",","& pid &",",1) > 0 And rangeStr <> "" Then
						rangeStr = rangeStr & "，下载"
					ElseIf InStr(1,","& postDown &",",","& pid &",",1) > 0 And rangeStr = "" Then
						rangeStr = rangeStr & "下载"
					end if
					result = result & pname &"("& rangeStr &")"
					rs.movenext
					If rs.Eof = False Then result = result & "，"
				Loop
			end if
			rs.close
			set rs = nothing
		else
			If share1&"" = "" Then share1 = "-1"
'Loop
			If share2&"" = "" Then share2 = "-1"
'Loop
			set rs=server.CreateObject("adodb.recordset")
			sql="select ord, name from gate where ord in ("&share1&","&share2&") order by cateid asc,del asc,ord asc,name asc"
			rs.open sql,conn,1,1
			result = ""
			if not rs.eof then
				do while not rs.eof
					Dim ckd , ckd2 , bhao , chkSonIU , k ,chkSonIU2
					ckd=""
					ckd2=""
					bhao = ""
					chkSonIU = Split(share1, ",")
					For k = 0 To UBound(chkSonIU)
						If int(chkSonIU(k)) = int(rs("ord")) Then
							ckd = "浏览"
							exit for
						end if
					next
					chkSonIU2 = Split(share2, ",")
					For k = 0 To UBound(chkSonIU2)
						If int(chkSonIU2(k)) = int(rs("ord")) Then
							ckd2 = "下载"
							exit for
						end if
					next
					if ckd <> "" and ckd2 <> "" Then  bhao  = ","
					result = result&rs("name")&"("&ckd&bhao&ckd2&")，"
					rs.movenext
				loop
				result = left(result,len(result)-1)
'loop
			end if
		end if
		Response.write result
		Response.end
	end sub
	
%>
