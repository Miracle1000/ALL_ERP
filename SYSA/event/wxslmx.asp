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
	
	Function GetIdentity(tableName,fieldName,addPerson,connStr)
		dim rs, errmsg, errnum
		err.clear
		on error resume next
		Set rs=cn.Execute("SELECT TOP 1 "&fieldName&" FROM "&tableName&" WHERE "&addPerson&"=" & SESSION("personzbintel2007") & " ORDER BY "&fieldName&" DESC")
		errmsg = err.description
		errnum = Err.Number
		if errnum = 0 then
			if rs.eof = true then
				errnum = -10000
'if rs.eof = true then
				errmsg = "没有获取最新的标识数据。"
			else
				GetIdentity = rs(0).value
			end if
		end if
		if errnum <> 0 then
			cn.close
			Response.write  "GetIdentity函数执行错误:" & errmsg & "<br>tableName=[" &tableName& "]<br>fieldName=[" &fieldName& "]<br>addPerson=[" &addPerson& "] "
			Response.end
		end if
	end function
	Function getNum_cpmx
		dim rs, sqlStr, num_cpmx
		num_cpmx = 500
		set rs = cn.execute("select num1 from setjm3  where ord=3")
		if rs.eof then
			sqlStr="Insert Into setjm3(ord,num1) values('"
			sqlStr=sqlStr & 3 & "','"
			sqlStr=sqlStr & num_cpmx & "')"
			cn.execute(sqlStr)
		else
			num_cpmx =zbcdbl( rs("num1"))
		end if
		rs.close
		set rs = nothing
		getNum_cpmx = num_cpmx
	end function
	Function getMenuPagesize
		dim rs
		set rs=cn.execute("select num1 from setjm3 where ord=25")
		if not rs.eof then
			getMenuPagesize=rs(0)
		else
			cn.execute "insert into setjm3(ord,num1) values(25,20)"
			getMenuPagesize=20
		end if
		rs.close
		set rs=nothing
	end function
	Function getCpDefSelect
		dim rs
		set rs=cn.execute("select intro from setopen  where sort1=17")
		if not rs.eof then
			getCpDefSelect=rs(0)
		else
			getCpDefSelect=1
		end if
		rs.close
		set rs=nothing
	end function
	Function getMenuZhan
		dim rs, isZhan
		set rs=cn.execute("select num1 from setjm3 where ord=7")
		if not rs.eof then
			isZhan=rs(0)
		else
			isZhan = 0
		end if
		rs.close
		set rs=Nothing
		If isZhan = 1 Then
			getMenuZhan = True
		else
			getMenuZhan = False
		end if
	end function
	sub strCheckBH(bhid,table,strBhID,str)
		if strBhID<>"" then
			Err.Clear
			Dim sqlStr, rs
			set rs=server.CreateObject("adodb.recordset")
			sqlStr="select "&bhid&" from "&table&" where del<>7 and "&bhid&"='"&strBhID&"'"
			rs.open sqlStr,cn,1,1
			if not rs.eof then
				Response.write"<script language=javascript>alert('该"&str&"编号已存在！请返回重试');window.history.back(-1);</script>"
'if not rs.eof then
				Response.end
			end if
			rs.close
			set rs=nothing
		else
		end if
	end sub
	Function editExtended(TName,ord,extValue)
		dim rs_kz_zdy, rs_kz_zdy_88, sql, rs7, sql7, rs_zdy, len_rszdy, MustFillin, nextFType
		dim columns, num1, i_jm, j_jm, c_Value, KZ_LIMITID
		Dim FType, cols, ycols, FName, FKZID, arr_extValue, arr_FValue, i, k
		cols = 1 : ycols = 1 : i_jm = 0 : j_jm = 0
		columns=2
		set rs_kz_zdy=cn.execute("select id, FType, FName, MustFillin from ERP_CustomFields where TName="&TName&" "& KZ_LIMITID &" and IsUsing=1 and del=1 order by FOrder asc ")
		if rs_kz_zdy.eof = False Then
			rs_zdy = rs_kz_zdy.GetRows()
		end if
		rs_kz_zdy.close
		set rs_kz_zdy = Nothing
		if isArray(rs_zdy) then
			len_rszdy = ubound(rs_zdy,2)
		else
			len_rszdy = -1
			len_rszdy = ubound(rs_zdy,2)
		end if
		num1 = 0
		for i=0 to len_rszdy
			If  num1 Mod columns = 0 Then Response.write "<tr>"
			FKZID = rs_zdy(0,i)
			FType = rs_zdy(1,i)
			FName =rs_zdy(2,i)
			MustFillin =rs_zdy(3,i)
			If columns = 2 Then
				Select Case FType
				Case "2","5" : cols = 3
				Case Else : cols = 1
				End Select
			end if
			If i < len_rszdy Then
				nextFType = rs_zdy(1,i+1)
'If i < len_rszdy Then
				If  (nextFType = "2" Or nextFType = "5" ) And cols = 1 And num1 Mod columns=0 Then cols = 3
			else
				If   cols = 1  And num1 Mod columns=0  Then cols = 3
			end if
			c_Value = ""
			If InStr(Chr(3)&Chr(4)& extValue , Chr(3)&Chr(4)& FKZID & Chr(1)&Chr(2))>0 Then
				arr_extValue = Split(extValue,Chr(3)&Chr(4))
				For k = 0 To ubound(arr_extValue)
					If arr_extValue(k)&""<>"" Then
						If InStr(Chr(3)&Chr(4)& arr_extValue(k) , Chr(3)&Chr(4)& FKZID & Chr(1)&Chr(2))>0 Then
							arr_FValue = Split(arr_extValue(k),Chr(1)&Chr(2))
							If arr_FValue(2)&""<>"" Then
								c_Value = arr_FValue(2)
							else
								c_Value = ""
							end if
						end if
					end if
				next
			end if
			If c_Value&""<>"" Then
				c_Value = vbsUnEscape(c_Value)
			end if
			Response.write "" & vbcrlf & "         <td width=""15%"" align=""right"" height=25 style=""min-height:25px;"">"
			c_Value = vbsUnEscape(c_Value)
			Response.write FName
			Response.write "：</td>" & vbcrlf & "              <td  colspan="""
			Response.write cols
			Response.write """>" & vbcrlf & ""
			if FType="1" Then
				Response.write "" & vbcrlf & "             <input name=""danh_"
				Response.write FKZID
				Response.write """ type=""text"" size=""15"" id=""danh_"
				Response.write FKZID
				Response.write """ value="""
				Response.write c_Value
				Response.write """ dataType=""Limit"" "
				if MustFillin Or Len(KZ_LIMITID&"")>0  then
					Response.write " min=""1"" "
				end if
				Response.write "  max=""500""  msg=""必须在1到500个字符"" maxlength=""4000"">" & vbcrlf & ""
			Elseif FType="2" then
				If c_Value &""<>"" Then c_Value = Replace(Replace(Replace(c_Value,"<Chr(13)>",Chr(13)),"  ",""),"<Chr(32)>",Chr(32))
				Response.write "" & vbcrlf & "             <textarea name=""duoh_"
				Response.write FKZID
				Response.write """ id=""duoh_"
				Response.write FKZID
				Response.write """ style=""overflow-y:auto;word-break:break-all;width:80%;"" rows=""4""  dataType=""Limit"" "
				Response.write FKZID
				if MustFillin Or Len(KZ_LIMITID&"")>0  then
					Response.write " min=""1"" "
				end if
				Response.write " max=""500""  msg=""必须在1到500个字符"">"
				Response.write c_Value
				Response.write "</textarea>" & vbcrlf & ""
			elseif FType="3" Then
				Response.write "" & vbcrlf & "             <input readonly name=""date_"
				Response.write FKZID
				Response.write """ value="""
				Response.write c_Value
				Response.write """ size=""15"" id=""date_"
				Response.write FKZID
				Response.write """  onclick='datedlg.show();' "
				if MustFillin Or Len(KZ_LIMITID&"")>0  then
					Response.write " min=""1"" "
				end if
				Response.write " max=""500"" msg=""请选择日期"" style=""background-image:url(../images/datePicker.gif);background-position:right;background-repeat:no-repeat;"">" & vbcrlf & ""
				Response.write " min=""1"" "
			ElseIf FType="4" then
				Response.write "" & vbcrlf & "             <input name=""Numr_"
				Response.write FKZID
				Response.write """ type=""text"" value="""
				Response.write c_Value
				Response.write """ size=""15"" id=""Numr_"
				Response.write FKZID
				Response.write """ onkeyup=value=value.replace(/[^\d\.]/g,'') dataType=""Limit"" "
				if MustFillin Or Len(KZ_LIMITID&"")>0  then
					Response.write " min=""1"" "
				end if
				Response.write "  max=""500""  msg=""必须在1到500个字符"" >" & vbcrlf & ""
			ElseIf FType="5" then
				Response.write "" & vbcrlf & "             <textarea name=""beiz_"
				Response.write FKZID
				Response.write """ id=""beiz_"
				Response.write FKZID
				Response.write """ dataType=""Limit""  max=""4000""  msg=""备注长度不能超过4000个字"" style=""display:none""  cols=""1"" rows=""1"">"
				if c_Value<>"" then Response.write c_Value End if
				Response.write "</textarea>" & vbcrlf & "          <IFRAME ID=""eWebEditor_"
				Response.write FKZID
				Response.write """ SRC=""../edit/ewebeditor.asp?id=beiz_"
				Response.write FKZID
				Response.write "&style=news"" FRAMEBORDER=""0"" SCROLLING=""no"" WIDTH=""100%"" HEIGHT=""240"" marginwidth=""1"" marginheight=""1"" name=""wfasdg""></IFRAME>" & vbcrlf & ""
			ElseIf FType="6" then
				Response.write "" & vbcrlf & "             <select name=""IsNot_"
				Response.write FKZID
				Response.write """ id=""IsNot_"
				Response.write FKZID
				Response.write """  dataType=""Limit"" "
				if MustFillin Or Len(KZ_LIMITID&"")>0  then
					Response.write " min=""1"" "
				end if
				Response.write "  max=""500""  msg=""必须在1到500个字符"">" & vbcrlf & "                   <option value=""是"" "
				If c_Value="是" then
					Response.write "selected"
				end if
				Response.write ">是</option>" & vbcrlf & "                 <option value=""否"" "
				If c_Value="否" then
					Response.write "selected"
				end if
				Response.write ">否</option>" & vbcrlf & "         </select>" & vbcrlf & ""
			else
				Response.write "" & vbcrlf & "             <select name=""meju_"
				Response.write FKZID
				Response.write """ id=""meju_"
				Response.write FKZID
				Response.write """  dataType=""Limit"" "
				if MustFillin Or Len(KZ_LIMITID&"")>0  then
					Response.write " min=""1"" "
				end if
				Response.write "  max=""500""  msg=""必须在1到500个字符"" style=""width:150px;"">" & vbcrlf & ""
				set rs7=server.CreateObject("adodb.recordset")
				sql7="select id,CValue from ERP_CustomOptions where CFID="&FKZID&" order by id asc "
				rs7.open sql7,cn,1,1
				do until rs7.eof
					Response.write "" & vbcrlf & "                             <option value="""
					Response.write rs7("id")
					Response.write """ "
					If rs7("CValue")=c_Value then
						Response.write "selected"
					end if
					Response.write ">"
					Response.write rs7("CValue")
					Response.write "</option>" & vbcrlf & ""
					rs7.movenext
				loop
				rs7.close
				set rs7=nothing
				Response.write "" & vbcrlf & "           </select>" & vbcrlf & ""
			end if
			if  MustFillin Or Len(KZ_LIMITID&"")>0  Then
				Response.write "" & vbcrlf & "                      &nbsp;<span class=""red"">*</span>" & vbcrlf & ""
			end if
			Response.write "" & vbcrlf & "             </td>" & vbcrlf & ""
			If cols = 1 Then
				num1 = num1 +1
'If cols = 1 Then
			else
				num1 = num1 +2
'If cols = 1 Then
			end if
			If  num1 Mod columns = 0 Then Response.write "</tr>"
		next
	end function
	Function vbsUnEscape(str)
		dim i,s,c
		s=""
		For i=1 to Len(str)
			c=Mid(str,i,1)
			If Mid(str,i,2)="%u" and i<=Len(str)-5 Then
				c=Mid(str,i,1)
				If IsNumeric("&H" & Mid(str,i+2,4)) Then
'c=Mid(str,i,1)
					s = s & CHRW(CInt("&H" & Mid(str,i+2,4)))
'c=Mid(str,i,1)
					i = i+5
'c=Mid(str,i,1)
				else
					s = s & c
				end if
			ElseIf c="%" and i<=Len(str)-2 Then
				s = s & c
				If IsNumeric("&H" & Mid(str,i+1,2)) Then
's = s & c
					s = s & CHRW(CInt("&H" & Mid(str,i+1,2)))
's = s & c
					i = i+2
's = s & c
				else
					s = s & c
				end if
			else
				s = s & c
			end if
		next
		vbsUnEscape = s
	end function
	Function showExtended2(jianIntro)
		If jianIntro&""<>"" Then
			dim columns, num1, c_Value, KZ_LIMITID
			Dim arr_intro, extValue, v_vid, rs, nextFType
			Dim FType, JFtype, cols, ycols, FName, FKZID, arr_extValue, extItem, arr_extItem, arr_FValue, i
			cols = 1 : ycols = 1
			columns=2
			arr_intro = Split(jianIntro,Chr(4)&Chr(5)&Chr(6))
			JFtype = arr_intro(0)
			If JFtype&""<>"" Then JFtype = CLng(JFtype) Else JFtype=0
			extValue = arr_intro(1)
			arr_extValue = Split(extValue,Chr(3)&Chr(4))
			num1 = 0
			For i = 0 To ubound(arr_extValue)
				If arr_extValue(i)&""<>"" Then
					extItem = arr_extValue(i)
					arr_extItem = Split(extItem,Chr(1)&Chr(2))
					If arr_extItem(1)&""<>"" Then
						If  num1 Mod columns = 0 Then Response.write "<tr>"
						v_vid = arr_extItem(0) : FName = arr_extItem(1) : FType = arr_extItem(2) : c_Value = arr_extItem(3)
						If v_vid&""="" Then v_vid = 0
						Select Case FType
						Case "2","5" : cols = 3
						Case Else : cols = 1
						End Select
						If  i < ubound(arr_extValue) Then
							nextFType  =  Split(arr_extValue(i+1),Chr(1)&Chr(2))(2)
'If  i < ubound(arr_extValue) Then
							If  (nextFType = "2" Or nextFType = "5" ) And cols = 1 And num1 Mod columns=0 Then cols = 3
						else
							If   cols = 1  And num1 Mod columns=0  Then cols = 3
						end if
						Response.write "" & vbcrlf & "                                     <td width=""11%"" align=""right"" height=25 style=""min-height:25px;"">"
'If   cols = 1  And num1 Mod columns=0  Then cols = 3
						Response.write FName
						Response.write "：</td>" & vbcrlf & "                                      <td width=""22%"" colspan="""
						Response.write cols
						Response.write """>"
						If FType&""="5" And c_Value&""<>"" Then
							Dim arr_img
							arr_img = split(c_Value,"<img",-1,1)
'Dim arr_img
							if ubound(arr_img)>0 Then
								Response.write "" & vbcrlf & "                                                     <div href=""javascript:;"" onClick=""window.open('info.asp?ord="
								Response.write app.base64.pwurl(v_vid)
								Response.write "&sort1=3&sort2=intro','neww6768999in','width=' + 1600 + ',height=' + 800 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=0,top=150');return false;"" onMouseOver=""window.status='none';return true;"" title=""放大查看"">"
								Response.write app.base64.pwurl(v_vid)
								Response.write c_Value
								Response.write "</div>" & vbcrlf & "                                                       "
							else
								If c_Value&""<>"" Then  Response.write(Replace(Replace(c_Value,Chr(13),"<br>"),Chr(32),"&nbsp;"))
							end if
						ElseIf FType&""="7"  Then
							If c_Value&""<>"" Then
								Set rs = cn.execute("select CValue from ERP_CustomOptions where id="&c_Value&"")
								If rs.eof = False Then  Response.write rs("CValue")
								rs.close
								set rs = nothing
							end if
						else
							If c_Value&""<>"" Then  Response.write(Replace(Replace(c_Value,Chr(13),"<br>"),Chr(32),"&nbsp;"))
						end if
						Response.write "" & vbcrlf & "                                     </td>" & vbcrlf & "                                   "
					end if
					If cols = 1 Then
						num1 = num1 +1
'If cols = 1 Then
					else
						num1 = num1 +2
'If cols = 1 Then
					end if
					If  num1 Mod columns = 0 Then Response.write "</tr>"
				end if
			next
		end if
	end function
	Function replaceIntroHtml(intro)
		If intro&""<>"" Then
			replaceIntroHtml = Replace(Replace(intro,Chr(13),"<br>"),Chr(32),"&nbsp;")
		else
			replaceIntroHtml = ""
		end if
	end function
	Function GetProcessBox(PID,mxid)
		Dim rs,sql,strHTML,ID,Title
		If (mxid&""<>"" And mxid&""<>"0") Or mxid="pi" Then
			If mxid="pi" Then
				strHTML = "<select id='ProcessID_pi' name='ProcessID_pi' style='width:110px;'>"
			else
				strHTML = "<select id='ProcessID_"& mxid &"' name='ProcessID' dataType='Limit' min='1' max='50' msg='必填' style='width:110px;'>"
			end if
		else
			strHTML = "<select id='ProcessID' name='ProcessID' class='select' dataType='Limit' min='1' max='50' msg='必填' style='width:110px;'>"
		end if
		strHTML = strHTML&"<option value=''>请选择维修流程</option>"
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT ID,Title FROM Comm_ProcessSet WHERE Type = 1 AND IsUse = 1 ORDER BY Ranking DESC,AddTime DESC"
		rs.Open sql,cn,1,1
		If Not rs.Eof Then
			Do While rs.Eof = False
				ID = rs("ID")
				Title = rs("Title")
				strHTML = strHTML&"<option value='"&ID&"' "
				If ID = PID Then
					strHTML = strHTML&"selected"
				end if
				strHTML = strHTML&">"&Title&"</option>"
				rs.movenext
			Loop
		end if
		rs.close
		set rs = nothing
		strHTML = strHTML&"</select>"
		GetProcessBox = strHTML
	end function
	Function saveRepairOrder(slord, slid, ProcessID, DealPerson)
		Dim sql, sql2, sql3, rs, rs88, SerialNumber,wxTitle, arr_slid, arr_ProcessID, arr_DealPerson, i
		Dim pgnum, pgmoney, htord, htlid, wxid, cpord, date1, cptitle
		sql = "" : sql2 = "" : sql3 = ""
		If slord&""<>"" And slid&""="" Then
			Set rs =  cn.execute("select id,repair_sl,Contract,ContractList,num1,money1,ord,date1 from repair_sl_list where repair_sl="& slord &" and del<>2 and isnull(num2,0)=0 order by id")
			While rs.eof = False
				Set rs88 = cn.Execute("EXEC erp_getdjbh 46,"&session("personzbintel2007"))
				SerialNumber = rs88(0).value
				Set rs88 = Nothing
				If SerialNumber="error" Then
					cn.rollbacktrans
					Response.write "<script language='javascript'>alert('维修单编号顺序递增位数已占满，请联系系统管理员，重新调整维修单编号顺序递增位数！');history.back();</script>"
					Response.end
				end if
				slid = rs("id") : htord = rs("Contract") : htlid = rs("ContractList") : pgnum =zbcdbl( rs("num1")) : pgmoney =zbcdbl( rs("money1"))
				cpord = rs("ord") : date1 = rs("date1")
				If date1&""="" Then
					sql2 = ",[DeliveryDate]" : sql3 = " '"&date1&"' ,"
				end if
				Set rs88 = cn.Execute("select top 1 title from product where ord="& cpord)
				cptitle = rs88(0).value
				Set rs88 = Nothing
				wxTitle = SerialNumber & cptitle & "维修单"
				If Len(wxTitle)>100 Then wxTitle = Left(wxTitle,100)
				sql = "INSERT INTO RepairOrder " &_
				"([Title],[SerialNumber],[ProcessID],[DealPerson],[Status],[Repair_sl],[Repair_sl_list],[ProID]," &_
				"[Num],[Cost]"& sql2 &",[Contract],[ContractList],[Del],[AddUser]) " &_
				"VALUES " &_
				"(  "&_
				" '"&wxTitle&"' , " &_
				" '"&SerialNumber&"' , " &_
				" "&ProcessID&" , "&_
				" "&DealPerson&" , "&_
				" 0 , " &_
				" "&slord&" , " &_
				" "&slid&" , " &_
				" "&cpord&" , " &_
				" "&pgnum&" , " &_
				" "&pgmoney&" , " & sql3 &_
				" "&htord&" , " &_
				" "&htlid&" , " &_
				" 1 , " &_
				" "& Info.User &" " &_
				")"
				cn.Execute(sql)
				wxid = cn.Execute("SELECT ISNULL(SCOPE_IDENTITY(),0) ID")(0)
				sql = "INSERT INTO Copy_ProcessSet SELECT [Id], [Title], [IsUse], [Ranking], [Type], "&wxid&",1,[AddUser], [AddTime] " &_
				"FROM Comm_ProcessSet WHERE ID = "&ProcessID&" "
				cn.Execute(sql)
				sql = "INSERT INTO Copy_ProcessNodeSet SELECT [Id] ,[Title] ,[NodeType] ,[Duration] ,[Ranking] ,[Relation] ,[DealPerson] ," &_
				"[CurrentNodeType] ,[BeforeNodeType] ,[Remark] ,[RelatedBill] ,[ProcessSet] ,[Type] , "&wxid&",1,[AddUser] ,[AddTime] " &_
				"FROM Comm_ProcessNodeSet WHERE ProcessSet = "&ProcessID&" "
				cn.Execute(sql)
				sql = "INSERT INTO Copy_NodesMap SELECT [Id] ,[NodeID] ,[NextNodeID] ,[IsSelected] ,[ProcessSet],"&wxid&",1,[AddUser] FROM Comm_NodesMap WHERE ProcessSet = "&ProcessID&" "
				cn.Execute(sql)
				sql = "INSERT INTO Copy_CustomFields SELECT [ID] ,[TName] ,[IsMaster] ,[FOrder] ,[FName] ,[FType] ,[MustFillin] ,[OptionID], " &_
				"[FStyle] ,[IsUsing] ,[CanExport] ,[CanInport] ,[CanSearch] ,[CanStat],[del],"&wxid&" FROM [ERP_CustomFields] WHERE " &_
				"EXISTS (SELECT 1 FROM Comm_ProcessNodeSet WHERE ProcessSet = "&ProcessID&" " &_
				"HAVING TName BETWEEN ISNULL(300000+MIN(ID),0)  AND ISNULL(300000+MAX(ID),0) ) "
				cn.Execute(sql)
				If htlid>0 Then
					Dim wxNum
					wxNum = getCPwxNum(cpord, htlid)
					If wxNum&""<>"" Then
						sql = "update contractlist set wxNum="& wxNum &" where id="& htlid
						cn.Execute(sql)
					end if
				end if
				rs.movenext
			wend
			rs.close
			set rs = nothing
		end if
	end function
	Function getPGNum(slid)
		Dim rs, pgNum
		pgNum = 0
		If slid&""<>"" Then
			Set rs = cn.execute("select isnull(num2,0) from repair_sl_list where del=1 and id="& slid)
			If rs.eof = False Then
				pgNum = CDbl(rs(0))
			end if
			rs.close
			set rs = nothing
		end if
		getPGNum = pgNum
	end function
	Function getPGstatus(slord)
		Dim rs, slNum, pgNum, complete1
		slNum = 0 : pgNum = 0 : complete1 = 0
		If slord&""<>"" Then
			Set rs = cn.execute("select isnull(SUM(isnull(num1,0)),0),isnull(SUM(isnull(num2,0)),0) from repair_sl_list where del=1 and repair_sl="& slord)
			If rs.eof = False Then
				slNum = CDbl(rs(0)) : pgNum = CDbl(rs(1))
			end if
			rs.close
			set rs = nothing
		end if
		If slNum>0 Then
			If slNum = pgNum Then
				complete1 = 2
			ElseIf slNum > pgNum And pgNum>0 Then
				complete1 = 1
			ElseIf pgNum = 0 Then
				complete1 =0
			end if
		else
			complete1 = 0
		end if
		getPGstatus = complete1
	end function
	Function getCPwxNum(cpord, htListid)
		Dim rs, wxNum
		wxNum = 0
		If cpord&""<>"" And htListid&""<>"" Then
			Set rs = cn.execute("select isnull(sum(Num),0) from RepairOrder where del=1 and ProID="& cpord &" and contractlist="& htListid)
			If rs.eof = False Then
				wxNum = CDbl(rs(0))
			end if
			rs.close
			set rs = nothing
		end if
		getCPwxNum = wxNum
	end function
	Function RepairPJMXToHtml(mode, repID)
		dim rs, rs_zdy, len_rszdy, i, sql, currCate, strWhere, hjIndex1, proID
		dim z5Select, z6Select, set_open, widthkd
		currCate = session("personzbintel2007")
		If currCate&"" = "" Then currCate = 0
		hjIndex1 = 1
		Select Case mode
		Case "pjMxShow1", "pjMxShow2" : sql = "select id,title,name,sort,sorce,set_open,kd from zdymx where sort1=91 and set_open=1 order by gate1 asc"
		Case "AddPjMx", "EditPjMx" : sql = "select id,title,name,sort,sorce,set_open from zdymx where sort1=91 order by gate1 asc"
		End Select
		set rs = conn.execute(sql)
		if not rs.eof then
			rs_zdy = rs.GetRows()
		end if
		rs.close
		set rs = nothing
		if isArray(rs_zdy) then
			len_rszdy = ubound(rs_zdy,2)
		else
			len_rszdy = -1
			len_rszdy = ubound(rs_zdy,2)
		end if
		Select Case mode
		Case "pjMxShow1"
		Response.write "" & vbcrlf & "      <table width=""100%"" border=""0"" cellpadding=""3"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "    <tr class=""top"">" & vbcrlf & "        <td colspan=""13"">新增配件</td>" & vbcrlf & "    </tr>" & vbcrlf & "    <tr class=""tableHead"">" & vbcrlf & "       "
		for i=0 to len_rszdy
			Response.write "" & vbcrlf & "        <th>"
			Response.write rs_zdy(1,i)
			Response.write "</th>" & vbcrlf & " "
		next
		Response.write "      " & vbcrlf & "    </tr>" & vbcrlf & "       "
		Referer              = Request("Referer")
		PID                  = Request("PID")
		NID                  = Request("NID")
		repSl_list   = Request("repSl_list")
		strWhere = "(a.del = 7 AND a.AddUser = "&currCate&") OR (a.RepairOrder = "&repID&" AND a.ProcessID = "&PID&" AND a.NodeID = "&NID&" AND a.del = 1)"
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT b.Title proName,b.Order1 proSN,b.Type1 proModel,c.sort1 proUnit,a.[ProID] ,a.[Num] ,a.[UseDate] ,a.[Remark] ," &_
		"a.[zdy1] ,a.[zdy2] ,a.[zdy3] ,a.[zdy4] ,(SELECT sort1 FROM sortonehy WHERE ID = a.[zdy5]) zdy5 ,(SELECT sort1 FROM sortonehy WHERE ID = a.[zdy6]) zdy6 ,a.[NodeID] ,a.[ProcessID] ,a.[RepairOrder] " &_
		"FROM RepairNewParts a " &_
		"LEFT JOIN Product b ON b.ord = a.proID " &_
		"LEFT JOIN sortonehy c ON c.id = a.Unit " &_
		"WHERE "&strWhere&" " &_
		"ORDER BY a.ID ASC"
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While rs.Eof = False
				proName      = rs("proName")
				proSN        = rs("proSN")
				proModel     = rs("proModel")
				proUnit      = rs("proUnit")
				Num =zbcdbl( rs("Num"))
				UseDate = rs("UseDate")
				Remark = rs("Remark")
				zdy1 = rs("zdy1")
				zdy2 = rs("zdy2")
				zdy3 = rs("zdy3")
				zdy4 = rs("zdy4")
				zdy5 = rs("zdy5")
				zdy6 = rs("zdy6")
				Response.write "      " & vbcrlf & "    <tr class=""has-border"">" & vbcrlf & "      "
				zdy6 = rs("zdy6")
				for i=0 to len_rszdy
					Select Case rs_zdy(4,i)&""
					Case "1" : Response.write "<td class='t-left'>"& proName &"</td>"
'Select Case rs_zdy(4,i)&""
					Case "2" : Response.write "<td class='t-left'>"& proSN &"</td>"
'Select Case rs_zdy(4,i)&""
					Case "3" : Response.write "<td class='t-left'>"& proModel &"</td>"
'Select Case rs_zdy(4,i)&""
					Case "4" : Response.write "<td>"& proUnit &"</td>"
					Case "5" : Response.write "<td>"& FormatNumber(Num,numScale,-1) &"</td>" : hjIndex1 = i+1
'Case "4" : Response.write "<td>"& proUnit &"</td>"
					Case "6" : Response.write "<td>"& Remark &"</td>"
					Case "7" : Response.write "<td>"& UseDate &"</td>"
					Case "8" : Response.write "<td>"& zdy1 &"</td>"
					Case "9" : Response.write "<td>"& zdy2 &"</td>"
					Case "10" : Response.write "<td>"& zdy3 &"</td>"
					Case "11" : Response.write "<td>"& zdy4 &"</td>"
					Case "12" : Response.write "<td>"& zdy5 &"</td>"
					Case "13" : Response.write "<td>"& zdy6 &"</td>"
					End Select
				next
				Response.write "" & vbcrlf & "     </tr>  " & vbcrlf & " "
				rs.movenext
			Loop
			total = Conn.Execute("SELECT SUM(Num) total FROM RepairNewParts a WHERE "&strWhere&" ")(0)
			Response.write "" & vbcrlf & "     <tr>" & vbcrlf & "            "
			if hjIndex1 > 1 then
				Response.write "" & vbcrlf & "             <td colspan="""
				Response.write hjIndex1-1
				Response.write "" & vbcrlf & "             <td colspan="""
				Response.write """>合计 " & vbcrlf & "           "
				If Referer <> "dealContent" Then
					Response.write "" & vbcrlf & "             <img src=""../images/jiantou.gif""><a href=""#"" onClick=""javascript:window.open('proListAdd.asp?repID="
					Response.write repID
					Response.write "&repSl_list="
					Response.write repSl_list
					Response.write "&PID="
					Response.write PID
					Response.write "&NID="
					Response.write NID
					Response.write "','plancor5','width=1200,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=30');return false;"" title=""点击编辑明细""><font class=""blue2"">重新编辑</font></a>" & vbcrlf & "               "
				end if
				Response.write "" & vbcrlf & "             </td>" & vbcrlf & "           "
			end if
			Response.write "     " & vbcrlf & "                <td>"
			Response.write FormatNumber(total,numScale,-1)
			Response.write "     " & vbcrlf & "                <td>"
			Response.write "</td>" & vbcrlf & "                "
			for i = hjIndex1 to len_rszdy
				Response.write "" & vbcrlf & "             <td>&nbsp;</td>" & vbcrlf & "         "
			next
			Response.write "" & vbcrlf & "     </tr>" & vbcrlf & "" & vbcrlf & "   "
		else
			Response.write "" & vbcrlf & "     <tr>" & vbcrlf & "            <td colspan="""
			Response.write len_rszdy+1
			Response.write "" & vbcrlf & "     <tr>" & vbcrlf & "            <td colspan="""
			Response.write """>暂无明细 " & vbcrlf & "               "
			If Referer <> "dealContent" Then
				Response.write "" & vbcrlf & "             <img src=""../images/jiantou.gif""><a href=""#"" onClick=""javascript:window.open('proListAdd.asp?repID="
				Response.write repID
				Response.write "&repSl_list="
				Response.write repSl_list
				Response.write "&PID="
				Response.write PID
				Response.write "&NID="
				Response.write NID
				Response.write "','plancor5','width=' + 1000 + ',height=' + 700 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=30');return false;"" title=""点击添加产品明细""><font class=""blue2"">添加产品明细</font></a>" & vbcrlf & "            "
				Response.write NID
			end if
			Response.write "" & vbcrlf & "             </td>" & vbcrlf & "   </tr>" & vbcrlf & "   "
		end if
		rs.close
		set rs = nothing
		Response.write "    " & vbcrlf & " </table>" & vbcrlf & "        "
		Case "pjMxShow2"
		Referer     = Request("Referer")
		If Referer = "recycle" Then
			delVal = 0
		else
			delVal = 1
		end if
		Response.write "" & vbcrlf & "     <table border=""0"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "               <tr class=""top"" style=""height:80px;"">" & vbcrlf & "                       <td colspan="""
		Response.write len_rszdy+3
		Response.write """><a href=""javascript:void(0);"">新增配件</a></td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr><td colspan="""
		Response.write len_rszdy+3
		Response.write """>" & vbcrlf & "                        <table class=""detailTable"" width=""100%"">" & vbcrlf & "                    <tr class=""top"">" & vbcrlf & "                  "
		for i=0 to len_rszdy
			widthkd = rs_zdy(6,i)
			Select Case rs_zdy(4,i)&""
			Case "5"
			Response.write "" & vbcrlf & "                             <td style=""width:"
			Response.write widthkd
			Response.write "px"">"
			Response.write rs_zdy(1,i)
			Response.write "</td>" & vbcrlf & "                                <td style=""width:80px"" align=""center"">生成</td>" & vbcrlf & "                     "
			Case Else
			Response.write "" & vbcrlf & "                             <td style=""width:"
			Response.write widthkd
			Response.write "px"">"
			Response.write rs_zdy(1,i)
			Response.write "</td>" & vbcrlf & "                        "
			End Select
		next
		Response.write "                             " & vbcrlf & "                                <td style=""width:100px"" align=""center"">合同状态</td>                " & vbcrlf & "                        </tr>" & vbcrlf & "                   "
		PID         = Request("PID")
		NID         = Request("NID")
		strWhere = "a.RepairOrder = "& repID &" AND a.del = "&delVal&" "
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT b.Title proName,b.Order1 proSN,b.Type1 proModel,c.sort1 proUnit,a.[ProID] ,isnull(a.[Num],0) Num ,a.[UseDate] ,a.[Remark] ," &_
		"a.[zdy1] ,a.[zdy2] ,a.[zdy3] ,a.[zdy4] ,(SELECT sort1 FROM sortonehy WHERE ID = a.[zdy5]) zdy5 ," &_
		"(SELECT sort1 FROM sortonehy WHERE ID = a.[zdy6]) zdy6 ,a.[NodeID] ,a.[ProcessID] ,a.[RepairOrder],d.date1 DeliveryDate, " &_
		"(CASE d.baoxiu WHEN 0 THEN '保内' WHEN 1 THEN '保外' WHEN 2 THEN '其他' END) baoxiu,ISNULL(e.num1,0) scNum " &_
		"FROM RepairNewParts a " &_
		"LEFT JOIN Product b ON b.ord = a.proID " &_
		"LEFT JOIN sortonehy c ON c.id = a.Unit " &_
		"LEFT JOIN repair_sl_list d ON d.id = a.repair_sl_list " &_
		"LEFT JOIN contractlist e ON e.repairNewPartsId = a.id AND e.del = 1 " &_
		"WHERE "&strWhere&" " &_
		"ORDER BY a.ID ASC"
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While rs.Eof = False
				proName     = rs("proName")
				proSN       = rs("proSN")
				proModel    = rs("proModel")
				proUnit     = rs("proUnit")
				Num = CDbl(rs("Num"))
				DeliveryDate        = rs("DeliveryDate")
				UseDate = rs("UseDate")
				Remark = rs("Remark")
				zdy1 = rs("zdy1")
				zdy2 = rs("zdy2")
				zdy3 = rs("zdy3")
				zdy4 = rs("zdy4")
				zdy5 = rs("zdy5")
				zdy6 = rs("zdy6")
				baoxiu      = rs("baoxiu")
				scNum       = CDbl(rs("scNum"))
				If scNum = 0 Then
					htStatus = "未生成"
				ElseIf scNum > Num Then
					htStatus = "超额生成"
				ElseIf Num > scNum AND scNum > 0 Then
					htStatus = "部分生成"
				ElseIf Num = scNum AND scNum > 0 Then
					htStatus = "生成完毕"
				end if
				Response.write "      " & vbcrlf & "                                       <tr>" & vbcrlf & "                                    "
				for i=0 to len_rszdy
					Select Case rs_zdy(4,i)&""
					Case "1" : Response.write "<td class='t-left'>"& proName &"</td>"
'Select Case rs_zdy(4,i)&""
					Case "2" : Response.write "<td class='t-left'>"& proSN &"</td>"
'Select Case rs_zdy(4,i)&""
					Case "3" : Response.write "<td class='t-left'>"& proModel &"</td>"
'Select Case rs_zdy(4,i)&""
					Case "4" : Response.write "<td>"& proUnit &"</td>"
					Case "5"
					Response.write "<td>"& FormatNumber(Num,numScale,-1) &"</td>" : hjIndex1 = i+1
'Case "5"
					Response.write "<td>"& FormatNumber(scNum,numScale,-1) &"</td>"
'Case "5"
					Case "6" : Response.write "<td>"& Remark &"</td>"
					Case "7" : Response.write "<td>"& UseDate &"</td>"
					Case "8" : Response.write "<td>"& zdy1 &"</td>"
					Case "9" : Response.write "<td>"& zdy2 &"</td>"
					Case "10" : Response.write "<td>"& zdy3 &"</td>"
					Case "11" : Response.write "<td>"& zdy4 &"</td>"
					Case "12" : Response.write "<td>"& zdy5 &"</td>"
					Case "13" : Response.write "<td>"& zdy6 &"</td>"
					End Select
				next
				Response.write "" & vbcrlf & "                                             <td>"
				Response.write htStatus
				Response.write "</td>" & vbcrlf & "                                        </tr>  " & vbcrlf & "                         "
				rs.movenext
			Loop
			total = Conn.Execute("SELECT ISNULL(SUM(Num),0) total FROM RepairNewParts a WHERE "&strWhere&" ")(0)
			sql = "SELECT ISNULL(SUM(Num1),0) total FROM contractlist WHERE del = 1 AND RepairNewPartsID IN " &_
			"(SELECT ID FROM RepairNewParts a WHERE "&strWhere&") "
			scTotal = Conn.Execute(sql)(0)
			Response.write "" & vbcrlf & "                             <tr>" & vbcrlf & "                                    "
			if hjIndex1 > 1 then
				Response.write "" & vbcrlf & "                                     <td colspan="""
				Response.write hjIndex1-1
				Response.write "" & vbcrlf & "                                     <td colspan="""
				Response.write """ class=""t-right"">合计：</td>" & vbcrlf & "                                       "
				Response.write "" & vbcrlf & "                                     <td colspan="""
			end if
			Response.write "     " & vbcrlf & "                                        <td>"
			Response.write FormatNumber(total,numScale,-1)
			Response.write "     " & vbcrlf & "                                        <td>"
			Response.write "</td>" & vbcrlf & "                                        <td>"
			Response.write FormatNumber(scTotal,numScale,-1)
			Response.write "</td>" & vbcrlf & "                                        <td>"
			Response.write "</td>" & vbcrlf & "                                        "
			for i = hjIndex1 to len_rszdy
				Response.write "" & vbcrlf & "                                     <td>&nbsp;</td>" & vbcrlf & "                                 "
			next
			Response.write "" & vbcrlf & "                                     <td></td>" & vbcrlf & "                               </tr>" & vbcrlf & "" & vbcrlf & "                           "
		else
			Response.write "" & vbcrlf & "                             <tr>" & vbcrlf & "                                    <td colspan="""
			Response.write len_rszdy+3
			Response.write """ style=""text-align:center"">暂无明细</td>" & vbcrlf & "                           </tr>" & vbcrlf & "                           "
		end if
		rs.close
		set rs = nothing
		Response.write "    " & vbcrlf & "                         </table></td></tr>" & vbcrlf & "      </table>" & vbcrlf & "        "
		Case "AddPjMx"
		proID = repID
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT Title,Order1,Type1,ISNULL(Unit,'0') Unit,zdy1,zdy2,zdy3,zdy4,zdy5,zdy6 " &_
		"FROM Product WHERE ord = "&proID&" "
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			proName             = rs("Title")
			proSN               = rs("Order1")
			proModel    = rs("Type1")
			proUnit             = rs("Unit")
			uList = Split(proUnit,",")
			uSelect = "<select name='proUnit'>"
			For i = 0 To UBound(uList)
				Set rs0 = server.CreateObject("adodb.recordset")
				sql0 = "SELECT sort1 FROM sortonehy WHERE id = "&uList(i)&" "
				rs0.Open sql0,conn,1,1
				If Not rs0.Eof Then
					uName = rs0("sort1")
					uSelect = uSelect & "<option value='"&uList(i)&"'>"&uName&"</option>"
				end if
				rs0.Close
				Set rs0 = Nothing
			next
			uSelect = uSelect & "</select>"
			zdy1                = rs("zdy1")
			zdy2                = rs("zdy2")
			zdy3                = rs("zdy3")
			zdy4                = rs("zdy4")
			zdy5                = rs("zdy5")
			Set rs0 = server.CreateObject("adodb.recordset")
			sql0 = "SELECT ID,sort1 FROM sortonehy WHERE gate2 = 2101 ORDER BY gate1 DESC"
			rs0.Open sql0,conn,1,1
			z5Select = "<select name='zdy5'>"
			If Not rs0.Eof Then
				Do While rs0.Eof = False
					ID = rs0("ID")
					sort1 = rs0("sort1")
					z5Select = z5Select &"<option value='"&ID&"' "
					If zdy5 = ID Then
						z5Select = z5Select &"selected"
					end if
					z5Select = z5Select &">"&sort1&"</option>"
					rs0.MoveNext
				Loop
			else
				z5Select = z5Select &"<option value=''></option>"
			end if
			z5Select = z5Select &"</select>"
			rs0.Close
			Set rs0 = Nothing
			zdy6                = rs("zdy6")
			Set rs0 = server.CreateObject("adodb.recordset")
			sql0 = "SELECT ID,sort1 FROM sortonehy WHERE gate2 = 2102 ORDER BY gate1 DESC"
			rs0.Open sql0,conn,1,1
			z6Select = "<select name='zdy6'>"
			If Not rs0.Eof Then
				Do While rs0.Eof = False
					ID = rs0("ID")
					sort1 = rs0("sort1")
					z6Select = z6Select &"<option value='"&ID&"' "
					If zdy6 = ID Then
						z6Select = z6Select &"selected"
					end if
					z6Select = z6Select &">"&sort1&"</option>"
					rs0.MoveNext
				Loop
			else
				z6Select = z6Select &"<option value=''></option>"
			end if
			z6Select = z6Select &"</select>"
			rs0.Close
			Set rs0 = Nothing
			Response.write "" & vbcrlf & "     <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "   "
			for i=0 to len_rszdy
				set_open = rs_zdy(5,i)
				If set_open&"" = "" Then set_open = 0
				Select Case rs_zdy(4,i)&""
				Case "1"
				Response.write "" & vbcrlf & "             <td class=""t-left"" "
'Case "1"
				Response.write iif(set_open&""="0"," style='display:none'","")
				Response.write "><input name=""listID"" type=""hidden"" value="""
				Response.write listID
				Response.write """ />"
				Response.write proName
				Response.write "<input name=""proID"" type=""hidden"" value="""
				Response.write proID
				Response.write """><span class=""del-btn""></span></td>" & vbcrlf & "        "
				Response.write proID
				Case "2" : Response.write "<td class='t-left' "& iif(set_open&""="0"," style='display:none'","") &">"& proSN &"</td>"
				Response.write proID
				Case "3" : Response.write "<td class='t-left' "& iif(set_open&""="0"," style='display:none'","") &">"& proModel &"</td>"
				Response.write proID
				Case "4" : Response.write "<td "& iif(set_open&""="0"," style='display:none'","") &">"& uSelect &"</td>"
				Case "5"
				Response.write "" & vbcrlf & "             <td "
				Response.write iif(set_open&""="0"," style='display:none'","")
				Response.write "><input name=""Num"" id=""num"
				Response.write proID
				Response.write """ style=""width: 50px; height: 19px; font-size: 9pt;"" onKeyUp=""value=value.replace(/[^\d\.]/g,'');checkDot('num"
				Response.write proID
				Response.write proID
				Response.write "','"
				Response.write numScale
				Response.write "');"" onFocus=""if(value==defaultValue){value='';this.style.color='#000'};"" onBlur=""if(!value){value=defaultValue;this.style.color='#000'};checkDot('num"
				Response.write proID
				Response.write "','"
				Response.write numScale
				Response.write "')""  type=""text"" maxLength=""20"" max=""20"" min=""1"" msg=""不能为空"" dataType=""Limit"" value="""
				Response.write FormatNumber(1,numScale,-1,0,0)
				Response.write """/></td>" & vbcrlf & "  "
				Case "6"
				Response.write "" & vbcrlf & "             <td "
				Response.write iif(set_open&""="0"," style='display:none'","")
				Response.write "><textarea name=""Remark"" id=""remark_"
				Response.write proID
				Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""50"" min=""0"" msg=""不要超过50个字"" datatype=""Limit"">"
				Response.write proID
				Response.write remark
				Response.write "</textarea></td>" & vbcrlf & "     "
				Case "7"
				Response.write "" & vbcrlf & "             <td style=""width:66px;"
				Response.write iif(set_open&""="0"," display:none","")
				Response.write """><input name=""UseDate"" id=""daysdate1_"
				Response.write proID
				Response.write "Pos"" style=""width: 66px; height: 19px; font-size: 9pt;"" onMouseUp=""toggleDatePicker('daysdate1_"
				Response.write proID
				Response.write proID
				Response.write "','date.UseDate_"
				Response.write proID
				Response.write "')"" msg=""日期格式不正确"" dataType=""Date"" format=""ymd"" value="""
				Response.write Date()
				Response.write """/><div id=""daysdate1_"
				Response.write proID
				Response.write """ style=""position: absolute;""/></td>" & vbcrlf & "        "
				Case "8"
				Response.write "" & vbcrlf & "             <td "
				Response.write iif(set_open&""="0"," style='display:none'","")
				Response.write "><textarea name=""zdy1"" id=""zdy1_"
				Response.write proID
				Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
				Response.write proID
				Response.write zdy1
				Response.write "</textarea></td>" & vbcrlf & "     "
				Case "9"
				Response.write " " & vbcrlf & "            <td "
				Response.write iif(set_open&""="0"," style='display:none'","")
				Response.write "><textarea name=""zdy2"" id=""zdy2_"
				Response.write proID
				Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
				Response.write proID
				Response.write zdy2
				Response.write "</textarea></td>" & vbcrlf & "     "
				Case "10"
				Response.write "" & vbcrlf & "             <td "
				Response.write iif(set_open&""="0"," style='display:none'","")
				Response.write "><textarea name=""zdy3"" id=""zdy3_"
				Response.write proID
				Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
				Response.write proID
				Response.write zdy3
				Response.write "</textarea></td>" & vbcrlf & "     "
				Case "11"
				Response.write " " & vbcrlf & "            <td "
				Response.write iif(set_open&""="0"," style='display:none'","")
				Response.write "><textarea name=""zdy4"" id=""zdy4_"
				Response.write proID
				Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
				Response.write proID
				Response.write zdy4
				Response.write "</textarea></td>" & vbcrlf & "     "
				Case "12" : Response.write "<td "& iif(set_open&""="0"," style='display:none'","") &">"& z5Select &"</td>"
				Case "13" : Response.write "<td "& iif(set_open&""="0"," style='display:none'","") &">"& z6Select &"</td>"
				End Select
			next
			Response.write "             " & vbcrlf & "        </tr>" & vbcrlf & "   "
		end if
		rs.close
		set rs = nothing
		Case "EditPjMx"
		PID                 = Request("PID")
		NID                 = Request("NID")
		Response.write "" & vbcrlf & "     <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" id=""proList"">" & vbcrlf & "        <tr class=""tableHead"">" & vbcrlf & "          "
		for i=0 to len_rszdy
			set_open = rs_zdy(5,i)
			If set_open&"" = "" Then set_open = 0
			Response.write "" & vbcrlf & "                     <th "
			Response.write iif(i=0," height='28'","")
			Response.write iif(set_open&""="0"," style='display:none'","")
			Response.write ">"
			Response.write rs_zdy(1,i)
			Response.write "</th>" & vbcrlf & "                "
		next
		Response.write "                     " & vbcrlf & "        </tr>" & vbcrlf & "   "
		strWhere = "(a.del = 7 AND a.AddUser = "& currCate &") OR (a.RepairOrder = "&repID&" AND a.ProcessID = "&PID&" AND a.NodeID = "&NID&" AND a.del = 1)"
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT a.ID listID,b.Title proName,b.Order1 proSN,b.Type1 proModel,a.Unit proUnit,a.[ProID] ,a.[Num] ,a.[UseDate] ,a.[Remark] ," &_
		"a.[zdy1] ,a.[zdy2] ,a.[zdy3] ,a.[zdy4] ,a.[zdy5] ,a.[zdy6] ,a.[NodeID] ,a.[ProcessID] ,a.[RepairOrder],ISNULL(d.ID,0) contractList " &_
		"FROM RepairNewParts a " &_
		"LEFT JOIN Product b ON b.ord = a.proID " &_
		"LEFT JOIN sortonehy c ON c.id = a.Unit " &_
		"LEFT JOIN contractlist d ON d.repairNewPartsId = a.ID AND d.del = 1 " &_
		"WHERE "&strWhere&" " &_
		"ORDER BY a.ID ASC"
		rs.open sql,conn,1,1
		If Not rs.Eof Then
			Do While rs.Eof = False
				listID                = rs("listID")
				proID                 = rs("proID")
				proName               = rs("proName")
				proSN         = rs("proSN")
				proModel      = rs("proModel")
				proUnit               = rs("proUnit")
				contractList = rs("contractList")
				uList                 = Split(proUnit,",")
				uSelect = "<select name='proUnit'>"
				For i = 0 To UBound(uList)
					Set rs0 = server.CreateObject("adodb.recordset")
					sql0 = "SELECT sort1 FROM sortonehy WHERE ID = "&uList(i)&" "
					rs0.Open sql0,conn,1,1
					If Not rs0.Eof Then
						uName = rs0("sort1")
						uSelect = uSelect & "<option value='"&uList(i)&"'>"&uName&"</option>"
					end if
					rs0.Close
					Set rs0 = Nothing
				next
				uSelect = uSelect & "</select>"
				Num  =zbcdbl( rs("Num"))
				UseDate = rs("UseDate")
				Remark = rs("Remark")
				zdy1 = rs("zdy1")
				zdy2 = rs("zdy2")
				zdy3 = rs("zdy3")
				zdy4 = rs("zdy4")
				zdy5 = rs("zdy5")
				Set rs0 = server.CreateObject("adodb.recordset")
				sql0 = "SELECT ID,sort1 FROM sortonehy WHERE gate2 = 2101 ORDER BY gate1 DESC"
				rs0.Open sql0,conn,1,1
				z5Select = "<select name='zdy5'>"
				If Not rs0.Eof Then
					Do While rs0.Eof = False
						ID = rs0("ID")
						sort1 = rs0("sort1")
						z5Select = z5Select &"<option value='"&ID&"' "
						If zdy5*1 = ID*1 Then
							z5Select = z5Select &"selected"
						end if
						z5Select = z5Select &">"&sort1&"</option>"
						rs0.MoveNext
					Loop
				else
					z5Select = z5Select &"<option value=''></option>"
				end if
				z5Select = z5Select &"</select>"
				rs0.Close
				Set rs0 = Nothing
				zdy6         = rs("zdy6")
				Set rs0 = server.CreateObject("adodb.recordset")
				sql0 = "SELECT ID,sort1 FROM sortonehy WHERE gate2 = 2102 ORDER BY gate1 DESC"
				rs0.Open sql0,conn,1,1
				z6Select = "<select name='zdy6'>"
				If Not rs0.Eof Then
					Do While rs0.Eof = False
						ID = rs0("ID")
						sort1 = rs0("sort1")
						z6Select = z6Select &"<option value='"&ID&"' "
						If zdy6*1 = ID*1 Then
							z6Select = z6Select &"selected"
						end if
						z6Select = z6Select &">"&sort1&"</option>"
						rs0.MoveNext
					Loop
				else
					z6Select = z6Select &"<option value=''></option>"
				end if
				z6Select = z6Select &"</select>"
				rs0.Close
				Set rs0 = Nothing
				Response.write "      " & vbcrlf & "        <tr onMouseOut=""this.style.backgroundColor=''"" onMouseOver=""this.style.backgroundColor='efefef'"">" & vbcrlf & "   "
				for i=0 to len_rszdy
					set_open = rs_zdy(5,i)
					If set_open&"" = "" Then set_open = 0
					Select Case rs_zdy(4,i)&""
					Case "1"
					Response.write "" & vbcrlf & "              <td class=""t-left"" "
'Case "1"
					Response.write iif(set_open&""="0"," style='display:none'","")
					Response.write "><input name=""listID"" type=""hidden"" value="""
					Response.write listID
					Response.write """ />"
					Response.write proName
					Response.write "<input name=""proID"" type=""hidden"" value="""
					Response.write proID
					Response.write """  />"
					If contractList = 0 Then
						Response.write "<span class=""del-btn""></span>"
'If contractList = 0 Then
					end if
					Response.write "</td>" & vbcrlf & " "
					Case "2" : Response.write "<td class='t-left' "& iif(set_open&""="0"," style='display:none'","") &">"& proSN &"</td>"
					Response.write "</td>" & vbcrlf & " "
					Case "3" : Response.write "<td class='t-left' "& iif(set_open&""="0"," style='display:none'","") &">"& proModel &"</td>"
					Response.write "</td>" & vbcrlf & " "
					Case "4" : Response.write "<td "& iif(set_open&""="0"," style='display:none'","") &">"& uSelect &"</td>"
					Case "5"
					Response.write "" & vbcrlf & "              <td "
					Response.write iif(set_open&""="0"," style='display:none'","")
					Response.write "><input name=""Num"" id=""num"
					Response.write proID
					Response.write """ style=""width: 50px; height: 19px; font-size: 9pt;"" onKeyUp=""value=value.replace(/[^\d\.]/g,'');checkDot('num"
					Response.write proID
					Response.write proID
					Response.write "','"
					Response.write numScale
					Response.write "');"" onFocus=""if(value==defaultValue){value='';this.style.color='#000'};"" onBlur=""if(!value){value=defaultValue;this.style.color='#000'};checkDot('num"
					Response.write proID
					Response.write "','"
					Response.write numScale
					Response.write "')""  type=""text"" maxLength=""20"" max=""20"" min=""1"" msg=""不能为空"" dataType=""Limit"" value="""
					Response.write FormatNumber(Num,numScale,-1,0,0)
					Response.write """/></td>" & vbcrlf & "  "
					Case "6"
					Response.write "             " & vbcrlf & "                <td "
					Response.write iif(set_open&""="0"," style='display:none'","")
					Response.write "><textarea name=""Remark"" id=""remark_"
					Response.write proID
					Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""50"" min=""0"" msg=""不要超过50个字"" datatype=""Limit"">"
					Response.write proID
					Response.write remark
					Response.write "</textarea></td>" & vbcrlf & "     "
					Case "7"
					Response.write "" & vbcrlf & "             <td style=""width:66px;"
					Response.write iif(set_open&""="0","display:none;","")
					Response.write """><input name=""UseDate"" id=""daysdate1_"
					Response.write proID
					Response.write "Pos"" style=""width: 60px; height: 19px; font-size: 9pt;"" onMouseUp=""toggleDatePicker('daysdate1_"
					Response.write proID
					Response.write proID
					Response.write "','date.UseDate_"
					Response.write proID
					Response.write "')"" msg=""日期格式不正确"" dataType=""Date"" format=""ymd"" value="""
					Response.write UseDate
					Response.write """/><div id=""daysdate1_"
					Response.write proID
					Response.write """ style=""position: absolute;""/></td>" & vbcrlf & "        "
					Case "8"
					Response.write "" & vbcrlf & "             <td "
					Response.write iif(set_open&""="0"," style='display:none'","")
					Response.write "><textarea name=""zdy1"" id=""zdy1_"
					Response.write proID
					Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
					Response.write proID
					Response.write zdy1
					Response.write "</textarea></td>" & vbcrlf & "     "
					Case "9"
					Response.write " " & vbcrlf & "            <td "
					Response.write iif(set_open&""="0"," style='display:none'","")
					Response.write "><textarea name=""zdy2"" id=""zdy2_"
					Response.write proID
					Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
					Response.write proID
					Response.write zdy2
					Response.write "</textarea></td>" & vbcrlf & "     "
					Case "10"
					Response.write "" & vbcrlf & "             <td "
					Response.write iif(set_open&""="0"," style='display:none'","")
					Response.write "><textarea name=""zdy3"" id=""zdy3_"
					Response.write proID
					Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
					Response.write proID
					Response.write zdy3
					Response.write "</textarea></td>" & vbcrlf & "     "
					Case "11"
					Response.write " " & vbcrlf & "            <td "
					Response.write iif(set_open&""="0"," style='display:none'","")
					Response.write "><textarea name=""zdy4"" id=""zdy4_"
					Response.write proID
					Response.write """ style=""width: 100%; word-break: break-all; overflow-y: hidden;"" onFocus=""this.style.posHeight=this.scrollHeight"" onpropertychange=""this.style.posHeight=this.scrollHeight"" rows=""1"" max=""200"" min=""0"" msg=""不要超过200个字"" datatype=""Limit"">"
					Response.write proID
					Response.write zdy4
					Response.write "</textarea></td>" & vbcrlf & "     "
					Case "12" : Response.write "<td "& iif(set_open&""="0"," style='display:none'","") &">"& z5Select &"</td>"
					Case "13" : Response.write "<td "& iif(set_open&""="0"," style='display:none'","") &">"& z6Select &"</td>"
					End Select
				next
				Response.write "                     " & vbcrlf & "        </tr>" & vbcrlf & "   "
				rs.movenext
			Loop
			total = Conn.Execute("SELECT SUM(Num) total FROM RepairNewParts a WHERE "&strWhere&" ")(0)
		else
			Response.write "" & vbcrlf & "                     <tr id=""noList""><td colspan="""
			Response.write len_rszdy+1
			Response.write "" & vbcrlf & "                     <tr id=""noList""><td colspan="""
			Response.write """ class=""t-left"">无产品明细！</td></tr>" & vbcrlf & "     "
			Response.write "" & vbcrlf & "                     <tr id=""noList""><td colspan="""
		end if
		rs.close
		set rs = nothing
		Response.write "        " & vbcrlf & "     </table>" & vbcrlf & "        "
		End Select
	end function
	
	dim rs, rs2, sql, sql2
	dim rs_zdy, len_rszdy, num1_dot, num_dot_xs
	Sub MessagePost(msgId)
		Select Case msgId
		Case ""
		Call Page_load
		End Select
	end sub
	Sub Page_load
		app.docmodel = "IE=8"
		Response.write app.DefHeadHTML(app.virPath, "") & vbcrlf & ""
		if session("repair_sl_idzbintel")&""="" then
			Response.write "<script>app.Alert('参数丢失请重新打开此页面');</script>"
			Response.end()
		end if
		dim ord, currTel
		ord=clng(session("repair_sl_idzbintel"))
		currTel = session("companyzbintel")
		If app.isIE7 Or app.isIE6 Then
			Response.write "<html style='overflow:auto;overflow-x:auto;overflow-y:hidden; scrollbar-3dlight-color:#d0d0e8; scrollbar-highlight-color:#fff; scrollbar-face-color:#f0f0ff; scrollbar-arrow-color:#c0c0e8; scrollbar-shadow-color:#d0d0e8; scrollbar-darkshadow-color:#fff; scrollbar-base-color:#ffffff; scrollbar-track-color:#fff;'>"
'If app.isIE7 Or app.isIE6 Then
		end if
		Response.write "" & vbcrlf & "<style>" & vbcrlf & "#content td a:hover{ text-decoration:underline}" & vbcrlf & "</style>" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "function editSLItems(winWidth){            //点击编辑明细" & vbcrlf & "  var currTel, dataTel;" & vbcrlf & "   if(window.parent.document.getElementById(""companyOrd"")){" & vbcrlf & "            var telOrd = window.parent.document.getElementById(""companyOrd"").value;" & vbcrlf & "           if(telOrd==""""){" & vbcrlf & "                   app.Alert(""请先选择关联客户"");" & vbcrlf & "            }else{" & vbcrlf & "                  winWidth = Number(winWidth);" & vbcrlf & "                    currTel =telOrd;" & vbcrlf & "                currTel = Number(currTel);" & vbcrlf & "                      dataTel = 0;" & vbcrlf & "                    dataTel = getMxCompany1("
		Response.write ord
		Response.write ");" & vbcrlf & "                    if(currTel == dataTel || dataTel==0){" & vbcrlf & "                           window.open('../repair/topadd.asp?top="
		Response.write app.base64.pwurl(ord)
		Response.write "&f=101','planslmx8','width=' + (winWidth+300) + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');" & vbcrlf & "                    }else if(dataTel>0 && currTel != dataTel){" & vbcrlf & "                              if(confirm(""维修产品不是该客户购买的,确定要要继续吗？"")){" & vbcrlf & "                                 window.open('../repair/topadd.asp?top="
		Response.write app.base64.pwurl(ord)
		Response.write "&f=101','planslmx8','width=' + (winWidth+300) + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');    //在打开的明细编辑页把更换关联客户前的客户的产品明细都删除" & vbcrlf & "                              }else{" & vbcrlf & "                                  return; " & vbcrlf & "                                }" & vbcrlf & "                       }" & vbcrlf & "               }" & vbcrlf & "       }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function getMxCompany1(ord){                     //查看当前添加的明细中的客户，参数为当前repair_sl的id" & vbcrlf & "   ajax.regEvent(""getMxCompany1"",""../repair/topadd.asp"");" & vbcrlf & "      $ap(""ord"",ord)" & vbcrlf & "    var r = ajax.send();" & vbcrlf & "    if(r != """"){" & vbcrlf & "              if(!isNaN(r)){" & vbcrlf & "                    return r;" & vbcrlf & "               }else{" & vbcrlf & "                  app.Alert(""未知错误"");" & vbcrlf & "            }" & vbcrlf & "       }else{" & vbcrlf & "          app.Alert(""未知错误"");" & vbcrlf & "    }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function getJiejianInfo(mxid){                //显示接件情况层" & vbcrlf & "        if(mxid != """"){" & vbcrlf & "              var JianContent = window.parent.document.getElementById(""JianContent"");" & vbcrlf & "           window.parent.$('#wJian').window('open');               " & vbcrlf & "                window.parent.document.getElementById('wJian').style.display = ""block"";" & vbcrlf & "           JianContent.innerHTML=""loading..."";" & vbcrlf & "               ajax.regEvent(""getJiejianInfo"",""../repair/content.asp"");" & vbcrlf & "           $ap(""mxid"",mxid);" & vbcrlf & "         var r = ajax.send();    " & vbcrlf & "                if(r!=""""){" & vbcrlf & "                        JianContent.innerHTML=r;" & vbcrlf & "                        var grayImg = JianContent.getElementsByTagName(""img"");" & vbcrlf & "                    if(grayImg.length>0){" & vbcrlf & "                           for(i=0; i<grayImg.length; i++){" & vbcrlf & "                                        if(grayImg[i].width>300){" & vbcrlf & "                                               grayImg[i].width = 300;" & vbcrlf & "                                 }" & vbcrlf & "                                       if(grayImg[i].height>100){" & vbcrlf & "                                              grayImg[i].height = 100;" & vbcrlf & "                                        }" & vbcrlf & "                               }" & vbcrlf & "                   }" & vbcrlf & "               }" & vbcrlf & "       }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "</script>" & vbcrlf & "<body style='overflow:auto;overflow-x:auto;overflow-y:hidden; scrollbar-3dlight-color:#d0d0e8; scrollbar-highlight-color:#fff; scrollbar-face-color:#f0f0ff; scrollbar-arrow-color:#c0c0e8; scrollbar-shadow-color:#d0d0e8; scrollbar-darkshadow-color:#fff; scrollbar-base-color:#ffffff; scrollbar-track-color:#fff;'>" & vbcrlf & ""
		'Response.write app.base64.pwurl(ord)
		num1_dot = info.FloatNumber
		num_dot_xs = info.MoneyNumber
		set rs2 = cn.execute("select id,title,kd,name,sorce from zdymx where sort1=45 and set_open=1 order by gate1 asc")
		if rs2.eof=false then
			rs_zdy = rs2.GetRows()
		end if
		rs2.close
		set rs2 = nothing
		if isArray(rs_zdy) then
			len_rszdy = ubound(rs_zdy,2)
		else
			len_rszdy = -1
			len_rszdy = ubound(rs_zdy,2)
		end if
		dim k, n, num_gate5, num_max, arr_num1, arr_num2, sumkd, sumkd2, sum, summoney1, num1, money1, mxIntro, guzhang, cptitle
		dim zdyTitle, kd, zdySorce, htord, htcateid, htListPower, htInfoPower
		dim gate1, gate2, gate3, item1, item2, item3
		n=0 : num_gate5=0 : num_max=0 : num_max=0 : sumkd=0 : sumkd2=0 : sum = 0 : summoney1 = 0
		arr_num1 = ""
		arr_num2 = ""
		if len_rszdy>=0 then
			for k=0 to len_rszdy
				kd = rs_zdy(2,k)
				sumkd = sumkd + kd
				kd = rs_zdy(2,k)
			next
			If sumkd<=730 Then
				sumkd2 = sumkd +66
'If sumkd<=730 Then
			else
				sumkd2 = 800
			end if
			Response.write "" & vbcrlf & "    <table border=""1""  cellpadding=""5"" cellspacing=""0"" id=""content"" style=""width:"
			If sumkd<900 Then Response.write "100%" Else Response.write sumkd &"px"
			Response.write ";"">" & vbcrlf & "      <tr class=""list-top"">" & vbcrlf & "    "
			'If sumkd<900 Then Response.write "100%" Else Response.write sumkd &"px"
			for k=0 to len_rszdy
				n = n + 1
'for k=0 to len_rszdy
				zdyTitle = rs_zdy(1,k)
				kd = rs_zdy(2,k)
				zdySorce = rs_zdy(4,k)
				if kd&""<>"" then kd=cint(kd) else kd=0
				if zdySorce&""<>"" then zdySorce=cint(zdySorce) else zdySorce=0
				if zdySorce=5 then
					arr_num1 = arr_num1 &"sl,"
					arr_num2 = arr_num2 & n &","
				elseif zdySorce=6 then
					arr_num1 = arr_num1 &"wxfy,"
					arr_num2 = arr_num2 & n &","
				end if
				Response.write "" & vbcrlf & "            <td style=""color:#2f496e"" width="""
				Response.write kd
				Response.write """><div align=""center""><strong>"
				Response.write zdyTitle
				Response.write "</strong></div></td>" & vbcrlf & "  "
			next
			Response.write "" & vbcrlf & "      </tr>" & vbcrlf & "    "
			sql = "select a.id, ISNULL(b.title,'<span style=''color:#ff0000''>产品已被删除</span>') cptitle, " &_
			"ISNULL(b.ord,0) cpord,ISNULL(b.order1,0) order1,ISNULL(b.type1,'') type1, " &_
			"ISNULL(c.sort1,'') cpUnit,isnull(a.num1,0) num1,isnull(a.money1,0) money1,  " &_
			"(case a.baoxiu when 0 then '保外' when 1 then '保内' when 2 then '其他' else '' end) baoxiu, " &_
			"a.guzhang,(case a.ruku when 1 then '是' when 0 then '否' else '' end) isRuku,a.date1,a.intro,ISNULL(d.title,'合同已删除') bill, " &_
			"ISNULL(d.ord,0) htord,ISNULL(d.cateid,0) htcateid,a.date2,a.ph,a.xlh,a.datesc,a.dateyx, " &_
			"a.zdy1,a.zdy2,a.zdy3,a.zdy4,a.zdy5,a.zdy6 " &_
			"from repair_sl_list a left join product b on a.ord=b.ord and b.del=1 " &_
			"left join sortonehy c on ISNULL(a.unit,0)=c.ord  " &_
			"left join contract d on ISNULL(a.contract,0)=d.ord and d.del=1 " &_
			"where a.repair_sl="&ord&" and a.del2<>7 order by a.date7 asc,a.id asc "
			set rs = cn.execute(sql)
			if rs.eof = true then
				Response.write "" & vbcrlf & "      <tr>" & vbcrlf & "           <td colspan="""
				Response.write len_rszdy+1
				Response.write "" & vbcrlf & "      <tr>" & vbcrlf & "           <td colspan="""
				Response.write """><div style="""
				If sumkd<900 Then Response.write "text-align:center;" Else Response.write "text-align:left;margin-left:400px;"
				Response.write """><div style="""
				Response.write """>" & vbcrlf & "                          <img src=""../../SYSN/skin/default/img/lvw_nulldata_logo.png"" /><br>" & vbcrlf & "                     <span class=""lvw_nulldata_tle"">您还没有添加任何数据</span> <br>" & vbcrlf & "                     <a href=""javascript:;"" style="""
				If sumkd<900 Then Response.write "margin-left:0;" Else Response.write "margin-left:43px;"
				Response.write """ onclick=""editSLItems('"
				Response.write sumkd2
				Response.write "')"" class=""editmx lvw_nulldata_addbtn"">去添加</a></div></td>" & vbcrlf & "      </tr>" & vbcrlf & "    "
			elseif rs.eof = false Then
				htListPower = app.power.GetPowerIntro(5,1)
				htInfoPower = app.power.GetPowerIntro(5,14)
				while rs.eof = false
					Response.write "" & vbcrlf & "      <tr>" & vbcrlf & "    "
					Dim qxOpen,qxIntro
					sdk.setup.getpowerattr 21,14,qxOpen, qxIntro
					for k=0 to len_rszdy
						zdyTitle = rs_zdy(1,k)
						kd = rs_zdy(2,k)
						zdySorce = rs_zdy(4,k)
						if kd&""<>"" then kd=cint(kd) else kd=0
						if zdySorce&""<>"" then zdySorce=cint(zdySorce) else zdySorce=0
						if zdySorce=1 then
							Response.write "" & vbcrlf & "             <td align=""left"">"
							cptitle = rs("cptitle")
							If cptitle&""= "" Then cptitle = ""
							If cptitle = "<span style='color:#ff0000'>产品已被删除</span>" Then
								Response.write "<span style='color:#ff0000'>产品已被删除</span>"
							else
								If qxOpen > 0 Then
									Response.write "" & vbcrlf & "             <a href=""javascript:;"" onClick=""javascript:window.open('../product/content.asp?ord="
									Response.write app.base64.pwurl(rs("cpord"))
									Response.write "','newdfwin','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=150,top=150')"" title=""点击可查看此产品详情"">" & vbcrlf & "              "
									Response.write app.base64.pwurl(rs("cpord"))
								end if
								Response.write rs("cptitle")
								Response.write "</a>"
							end if
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=2 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write rs("order1")
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=3 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write rs("type1")
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=4 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write rs("cpUnit")
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=5 then
							num1 = CDbl(rs("num1"))
							num1 = Formatnumber(num1,num1_dot,-1)
							'num1 = CDbl(rs("num1"))
							num1 = CDbl(num1)
							sum = sum + num1
							'num1 = CDbl(num1)
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write Formatnumber(num1,num1_dot,-1)
							'Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=6 then
							money1 = CDbl(rs("money1"))
							money1 = Formatnumber(money1,num_dot_xs,-1)
							'money1 = CDbl(rs("money1"))
							money1 = CDbl(money1)
							summoney1 = summoney1 + money1
							'money1 = CDbl(money1)
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write Formatnumber(money1,num_dot_xs,-1)
							'Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=7 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write rs("baoxiu")
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=8 then
							Response.write "" & vbcrlf & "             <td align=""left"">"
							Response.write replaceIntroHtml(rs("guzhang"))
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=9 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write JiejianToHtml(rs("id"))
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=10 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write rs("isRuku")
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=11 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write rs("date1")
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=12 then
							Response.write "" & vbcrlf & "             <td align=""left"">"
							Response.write replaceIntroHtml(rs("intro"))
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=13 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							htord = rs("htord") : htcateid = rs("htcateid")
							if htord>0 Then
								If htListPower = "" Or instr(","& htListPower &"," , ","& htcateid &",")>0 then
									If htInfoPower = "" Or instr(","& htInfoPower &"," , ","& htcateid &",")>0 Then
										Response.write "<a href='javascript:void(0)' onclick=javascript:window.open('../../SYSN/view/sales/contract/ContractDetails.ashx?view=details&ord="& app.base64.pwurl(htord)&"','newwin25','width='+800+',height='+500+',toolbar=0,scrollbars=1,resizable=1,left=100,top=100');return false; alt='查看合同详情'>"& rs("bill") &"</a>"
									else
										Response.write(rs("bill"))
									end if
								end if
							end if
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=14 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write rs("date2")
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=15 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write rs("ph")
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=16 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write rs("xlh")
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=17 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write rs("datesc")
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=18 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write rs("dateyx")
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=19 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write rs("zdy1")
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=20 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write rs("zdy2")
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=21 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write rs("zdy3")
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=22 then
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write rs("zdy4")
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=23 then
							Dim zdy5 : zdy5 = rs("zdy5")
							Dim zdy5Title : zdy5Title = ""
							If zdy5&""<>"" Then
								Set rs2 = cn.execute("select sort1 from sortonehy where id="& rs("zdy5"))
								If rs2.eof = False Then
									zdy5Title = rs2("sort1")
								end if
								rs2.close
								Set rs2 = Nothing
							end if
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write zdy5Title
							Response.write "</td>" & vbcrlf & "    "
						end if
						if zdySorce=24 then
							Dim zdy6 : zdy6 = rs("zdy5")
							Dim zdy6Title : zdy6Title = ""
							If zdy6&""<>"" Then
								Set rs2 = cn.execute("select sort1 from sortonehy where id="& rs("zdy6"))
								If rs2.eof = False Then
									zdy6Title = rs2("sort1")
								end if
								rs2.close
								Set rs2 = Nothing
							end if
							Response.write "" & vbcrlf & "             <td align=""center"">"
							Response.write zdy6Title
							Response.write "</td>" & vbcrlf & "    "
						end if
					next
					Response.write "" & vbcrlf & "      </tr>" & vbcrlf & "    "
					rs.movenext
				wend
				dim all_1, all_2, align_mx1, align_mx2, num_ls2
				if arr_num1<>"" and arr_num2<>"" then
					num_ls2 = len_rszdy + 1
'if arr_num1<>"" and arr_num2<>"" then
					arr_num1 = split(arr_num1,",")
					arr_num2 = split(arr_num2,",")
					gate1 = 0 : gate2 = 0 : gate3 = 0
					item1 = "" : item2 = "" : item3 = ""
					if arr_num1(0)&""<>"" then
						item1 = arr_num1(0)
						gate1 = cint(arr_num2(0))
						num_max = gate1
						select case arr_num1(0)
						case "sl"
						all_1=Formatnumber(sum,num1_dot,-1)
'case "sl" '
						align_mx1="text-align:center"
'case "sl" '
						case "wxfy"
						all_1=Formatnumber(summoney1,num_dot_xs,-1)
'case "wxfy"       '
						align_mx1="text-align:right"
'case "wxfy"       '
						end select
					end if
					if arr_num1(1)&""<>"" then
						item2 = arr_num1(1)
						gate2 = cint(arr_num2(1))
						num_max = gate2
						select case arr_num1(1)
						case "sl"
						all_2=Formatnumber(sum,num1_dot,-1)
						'case "sl"
						align_mx2="text-align:center"
						'case "sl"
						case "wxfy"
						all_2=Formatnumber(summoney1,num_dot_xs,-1)
						'case "wxfy"
						align_mx2="text-align:right"
						'case "wxfy"
						end select
					end if
				end if
				Response.write "" & vbcrlf & "    " & vbcrlf & "      <tr>" & vbcrlf & "    "
				if gate1>1 then
					Response.write "" & vbcrlf & "     <td align=""center"" colspan="""
					Response.write gate1-1
					Response.write "" & vbcrlf & "     <td align=""center"" colspan="""
					Response.write """>合计<img src=""../images/jiantou.gif""><a href=""javascript:;"" onclick=""editSLItems('"
					Response.write sumkd2
					Response.write "')"" title=""点击编辑明细"" class=""editmx"">重新编辑</a></td>" & vbcrlf & "    "
				end if
				Response.write "" & vbcrlf & "     <td class=""red"" style="" "
				Response.write align_mx1
				Response.write """>"
				Response.write all_1
				Response.write "</td>" & vbcrlf & "    "
				if abs(gate2-gate1)>1 then
					Response.write "</td>" & vbcrlf & "    "
					Response.write "" & vbcrlf & "     <td colspan="""
					Response.write abs(gate2-gate1)-1
					Response.write "" & vbcrlf & "     <td colspan="""
					Response.write """>&nbsp;</td>" & vbcrlf & "    "
				end if
				Response.write "" & vbcrlf & "     <td class=""red"" style="" "
				Response.write align_mx2
				Response.write """>"
				Response.write all_2
				Response.write "</td>" & vbcrlf & "    "
				if num_ls2-num_max>0 then
					Response.write "</td>" & vbcrlf & "    "
					Response.write "" & vbcrlf & "     <td colspan="""
					Response.write num_ls2-num_max
					'Response.write "" & vbcrlf & "     <td colspan="""
					Response.write """>" & vbcrlf & "    "
					if gate1=1 then
						Response.write "" & vbcrlf & "     合计<img src=""../images/jiantou.gif""><a href=""#"" onClick=""javascript:window.open('../repair/topadd.asp?top="
						Response.write app.base64.pwurl(ord)
						Response.write "&f=101','planslmx8','width=' + "
						'Response.write app.base64.pwurl(ord)
						Response.write sumkd+200
						'Response.write app.base64.pwurl(ord)
						Response.write " + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=0,top=100');"" title=""点击编辑明细"">重新编辑</a>" & vbcrlf & "    "
						'Response.write app.base64.pwurl(ord)
					end if
					Response.write "   " & vbcrlf & "        </td>" & vbcrlf & "    "
				end if
				Response.write "" & vbcrlf & "      </tr>" & vbcrlf & "    " & vbcrlf & "    "
			end if
			rs.close
			set rs = nothing
			Response.write "" & vbcrlf & "    </table><div style=""height:4px; margin-top:4px;"" id=""mxPos""></div>" & vbcrlf & "    "
			Response.write "" & vbcrlf & "      </tr>" & vbcrlf & "    " & vbcrlf & "    "
		end if
		Response.write "" & vbcrlf & "" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
	end sub
	Function JiejianToHtml(mxid)
		Dim tempStr, rs, jiejianStr, JFtype
		jiejianStr = "" : JFtype = ""
		If mxid&""<>"" Then
			Set rs = cn.execute("select top 1 id from repair_sl_jian where repair_sl_list = "& mxid &" and del=7")
			If rs.eof = False Then
				tempStr = "<img src='../images/116.png'  border=0 style='cursor:hand' onClick='getJiejianInfo("& mxid &");'>"
			end if
			rs.close
			set rs = nothing
		end if
		JiejianToHtml = tempStr
	end function
	
%>
