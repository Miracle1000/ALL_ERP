<%@ language=VBScript %>
<%
	Response.CharSet = "UTF-8"
	Response.ContentType = "text/html"
	Response.Expires = -9999
	'Response.ContentType = "text/html"
	Response.AddHeader "Pragma", "no-cache"
	'Response.ContentType = "text/html"
	Response.AddHeader "Cache-control", "no-cache"
	'Response.ContentType = "text/html"
	Response.Buffer = True
	Response.ExpiresAbsolute = Now - 1000
	'Response.Buffer = True
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
	
	Const GET_TOKEN_URL = "https://api.weixin.qq.com/cgi-bin/token?"
	Const SEND_MSG_URL = "https://api.weixin.qq.com/cgi-bin/message/custom/send?"
	Const SET_MENU_URL = "https://api.weixin.qq.com/cgi-bin/menu/create?"
	Const GET_MENU_URL = "https://api.weixin.qq.com/cgi-bin/get_current_selfmenu_info?"
	Const GET_USER_LIST_URL = "https://api.weixin.qq.com/cgi-bin/user/get?"
	Const GET_USER_INFO_URL = "https://api.weixin.qq.com/cgi-bin/user/info?"
	Const GET_USER_INFO_BATCH_URL = "https://api.weixin.qq.com/cgi-bin/user/info/batchget?"
	Const GET_GROUP_LIST_URL = "https://api.weixin.qq.com/cgi-bin/groups/get?"
	Const GET_MEDIA_DATA_URL = "https://api.weixin.qq.com/cgi-bin/media/get?"
	Const GET_JSAPI_TICKET = "https://api.weixin.qq.com/cgi-bin/ticket/getticket?"
	Const DEL_MENU_URL = "https://api.weixin.qq.com/cgi-bin/menu/delete?"
	Const WX_CREATE_PRE_ORDER_URL = "https://api.mch.weixin.qq.com/pay/unifiedorder"
	Const GET_AUTHORIZE_URL="https://open.weixin.qq.com/connect/oauth2/authorize?appid="
	Const GET_ACCESSTOKEN_URL="https://api.weixin.qq.com/sns/oauth2/access_token?appid="
	Const GET_USERINFO_URL="https://api.weixin.qq.com/sns/userinfo?access_token="
	Const CAPICOM_HASH_ALGORITHM_MD2 = 1
	Const CAPICOM_HASH_ALGORITHM_MD4 = 2
	Const CAPICOM_HASH_ALGORITHM_MD5 = 3
	Const CAPICOM_HASH_ALGORITHM_SHA1 = 0
	Const CAPICOM_HASH_ALGORITHM_SHA_256 = 4
	Const CAPICOM_HASH_ALGORITHM_SHA_384 = 5
	Const CAPICOM_HASH_ALGORITHM_SHA_512 = 6
	Const WX_PAY_ID = 2
	ZBRLibDLLNameSN = "ZBRLib3205"
	Function CreateMicroMsgHelper(cn,accId)
		Dim helper : Set helper = New MicroMsgClass
		helper.init cn,accId
		Dim appLog
		Set appLog = server.createobject(ZBRLibDLLNameSN & ".ZBSysLog")
		appLog.init Me
		Set helper.Log = appLog
		Set CreateMicroMsgHelper = helper
	end function
	Function CreateHelper(cn,accId, mFromType)
		Dim helper : Set helper = New MicroMsgClass
		helper.SetFromType(mFromType)
		helper.init cn,accId
		Dim appLog
		Set appLog = server.createobject(ZBRLibDLLNameSN & ".ZBSysLog")
		appLog.init Me
		Set helper.Log = appLog
		Set CreateHelper = helper
	end function
	Class MicroMsgClass
		Dim sc4Json
		Public cn, conn
		Private accId
		Public sdk
		Private appLog
		Private base64
		Private ZBRuntime
		Private AppId
		Private open_id
		Private Appsecret
		Private Access_Token
		Private Token_Time
		Private Expires_In
		Private token
		Private hostname
		Private merchantName
		Private VirFolder
		private FromType
		Public Function merchantId(paymentid)
			Dim rs : Set rs = cn.execute("select * from Shop_Payments where id=" & paymentid)
			If rs.eof = False Then
				merchantId = rs("merchant")
			else
				merchantId = ""
			end if
			rs.close
			set rs = nothing
		end function
		Public Function merchantKey(paymentid)
			Dim rs : Set rs = cn.execute("select * from Shop_Payments where id=" & paymentid)
			If rs.eof = False Then
				merchantKey = rs("mKey")
			else
				merchantKey = ""
			end if
			rs.close
			set rs = nothing
		end function
		Public Property Get base64Util
		Set base64Util = base64
		End Property
		Public Property Get Log
		Set Log = appLog
		End Property
		Public Property Set Log(l)
		Set appLog =  l
		End Property
		public function SetFromType(mfromtype)
			FromType = mfromtype
		end function
		Public Property Get AccessToken
		AccessToken = Access_Token
		End Property
		Public Property Get App_Id
		App_Id = AppId
		End Property
		Public Property Get App_secret
		App_secret = Appsecret
		End Property
		Public Property Get getServiceLink
		getServiceLink = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" & appId & "&redirect_uri=" & Replace(server.urlencode(hostname & "/" & _
		"IIF(Len(VirFolder)>0,VirFolder & ""/"","""") & ""SYSA/MicroMsg/mobile/index.asp""),""%2E"",""."") & ""&response_type=code&scope=snsapi_userinfo&state=state#wechat_redirect"""))
		End Property
		Public Property Get getAuthorizeUser
		getAuthorizeUser=GET_AUTHORIZE_URL& appId &"&redirect_uri="& Replace(server.urlencode(hostname & "/" &_
		"IIF(Len(VirFolder)>0,VirFolder & ""/"","""")),""%2E"",""."") &""/SYSA/MicroMsg/CallBack.asp?scope=snsapi_userinfo&response_type=code&scope=snsapi_userinfo&state=STATE#wechat_redirect"""))
		End Property
		Private Sub Class_Initialize
		end sub
		Public Sub init(ByVal connection,cfgId)
			Set cn = connection
			Set conn = cn
			accId = cfgId
			Dim page : Set page = Nothing
			on error resume next
			Set page = app
			On Error GoTo 0
			If page Is Nothing Then
				Set ZBRuntime = server.createobject(ZBRLibDLLNameSN & ".Library")
				Call ZBRuntime.setDefLCID(Session)
				Set Me.sdk = server.createobject(ZBRLibDLLNameSN & ".CommClass")
				Me.sdk.init Me
				Set base64 = server.createobject(ZBRLibDLLNameSN & ".base64Class")
			else
				Set Me.sdk = app.sdk
				Set base64 = app.base64
				Set ZBRuntime = app.Library
			end if
			If accId & "" = "" Or Not isnumeric(accId) Then
				Err.raise "908", "zbintel", "公众号id无效"
			end if
			Access_Token = GetToken()
			If Access_Token = "" Then
				if FromType&""="" then
					Response.write "{success:false,msg:'无法获取Access_Token,请检查公众号绑定设置'}"
					Response.end
				else
					Err.raise "909", "zbintel", "无法获取Access_Token,请检查公众号绑定设置"
				end if
			end if
		end sub
		Private Function GetToken()
			Dim rs,sql,strJson,objTest
			sql="select * from MMsg_Config where id=" & accId
			Set rs = cn.execute(sql)
			If rs.eof Then
				GetToken = ""
				Exit Function
			end if
			AppId = rs("AppId")
			open_id = rs("openid")
			Appsecret = rs("Appsecret")
			Access_token = rs("Access_token")
			Token_Time = rs("Token_Time")
			token = rs("token")
			Expires_In = rs("Expires_In")
			hostname = rs("hostname") & ""
			merchantName = rs("openName") & ""
			If Right(hostname,1) <> "/" Then hostname = hostname & "/"
			If Len(VirFolder)>0 Then
				If Left(VirFolder,1) <> "/" Then VirFolder = "/" & VirFolder
				If Right(VirFolder,1) <> "/" Then VirFolder = VirFolder & "/"
			end if
			rs.close
			Set rs=Nothing
			GetToken=Access_token
			If Abs(datediff("s",Token_Time,Now())) > Expires_In then
				Token_Time = now
				strJson = GetURL(GET_TOKEN_URL & "grant_type=client_credential&appid=" & AppId & "&secret=" & Appsecret & "")
				if InStr(strJson,"errcode")>0 then GetToken="":exit function
				Call InitScriptControl:Set objTest = getJSONObject(strJson)
				Access_token = objTest.access_token
				Expires_In = objTest.expires_in
				cn.execute "update MMsg_Config set Access_token='" & Access_token & "'," & _
				"Token_Time=' " & Token_Time & "'," &_
				"Expires_In=" & Expires_In & " " &_
				"where id=" & accId
				GetToken = Access_token
			end if
		end function
		Public Function ReturnText(fromusername,tousername,returnstr)
			ReturnText="<xml>" &_
			"<ToUserName><![CDATA["&fromusername&"]]></ToUserName>" &_
			"<FromUserName><![CDATA["&tousername&"]]></FromUserName>" &_
			"<CreateTime>"&now&"</CreateTime>" &_
			"<MsgType><![CDATA[text]]></MsgType>" &_
			"<Content><![CDATA[" & dehtml(returnstr) & "]]></Content>" &_
			"</xml>"
		end function
		Public Function ReturnPicText(fromusername,tousername,title,descriptions,PicUrl,url)
			dim t:t="<xml>"
			t=t&"<ToUserName><![CDATA["&fromusername&"]]></ToUserName>"
			t=t&"<FromUserName><![CDATA["&tousername&"]]></FromUserName>"
			t=t&"<CreateTime>"&now&"</CreateTime>"
			t=t&"<MsgType><![CDATA[news]]></MsgType>"
			t=t&"<ArticleCount>1</ArticleCount>"
			t=t&"<Articles>"
			t=t&"<item>"
			t=t&"<Title><![CDATA["&title&"]]></Title>"
			if Len(descriptions&"")>0 then
				t=t&"<Description><![CDATA["&descriptions&"]]></Description>"
			end if
			if Len(PicUrl&"")>0 then
				if InStr(LCase(PicUrl), "http://") <= 0 then
					if left(PicUrl,1)<>"/" then
						PicUrl = hostname & virPath & PicUrl
					else
						PicUrl = hostname & PicUrl
					end if
				end if
				t= t & "<PicUrl><![CDATA["&PicUrl&"]]></PicUrl>"
			end if
			t=t&"<Url><![CDATA["&url&"]]></Url>"
			t=t&"</item>"
			t=t&"</Articles>"
			t=t&"</xml>"
			ReturnPicText = t
		end function
		Public Function PostMsg(ByVal userId,ByVal StrMsg)
			Dim Sendtext,strJson,objTest,rs,sql,mgID
			Dim uid
			uid = getOpenIdByUserId(userId)
			If uid = "" Then
				PostMsg = "0无法获取用户id"
				Exit Function
			end if
			If InStr(StrMsg,"html")>0 and InStr(StrMsg,".html?")=0 Then
				StrMsg = Replace(StrMsg,"html","",1,-1,1)
'If InStr(StrMsg,"html")>0 and InStr(StrMsg,".html?")=0 Then
				StrMsg = Replace(StrMsg,"{","",1,-1,1)
'If InStr(StrMsg,"html")>0 and InStr(StrMsg,".html?")=0 Then
				StrMsg = Replace(StrMsg,"overflow-x:hidden;","",1,-1,1)
'If InStr(StrMsg,"html")>0 and InStr(StrMsg,".html?")=0 Then
				StrMsg = Replace(StrMsg,"overflow-y:auto;","",1,-1,1)
'If InStr(StrMsg,"html")>0 and InStr(StrMsg,".html?")=0 Then
				StrMsg = Replace(StrMsg,"&#125;","",1,-1,1)
'If InStr(StrMsg,"html")>0 and InStr(StrMsg,".html?")=0 Then
				StrMsg = Replace(StrMsg,"}","",1,-1,1)
'If InStr(StrMsg,"html")>0 and InStr(StrMsg,".html?")=0 Then
			end if
			Sendtext="{""touser"":""" & uid & """,""msgtype"":""text"",""text"":{""content"":""" & JsonStringFilter(Replace(StrMsg,"/::’|","/::'|")) & """}}"
			strJson=PostURL(SEND_MSG_URL & "&access_token=" & Access_token,Sendtext)
			Call InitScriptControl:Set objTest = getJSONObject(strJson)
			if objTest.errcode="0" then
				Set rs = server.CreateObject("adodb.recordset")
				sql = "select * from MMsg_Message where 1=2"
				rs.open sql,cn,3,3
				rs.addNew
				rs("sendOrReceive") = 2
				rs("accId") = accId
				rs("userId") = userId
				rs("CreateTime") = ToUnixTime(now)
				rs("MsgType") = "text"
				rs("Content") = Replace(Replace(base64.Utf8CharHtmlConvert(StrMsg),"&#8217;","'"),"&#126;","~")
				rs("cateid") = Me.sdk.Info.User
				rs.update
				rs.close
				Set rs=Nothing
				mgID = Me.sdk.setup.GetIdentity("MMsg_Message","id",Me.sdk.Info.User)
				If mgID = 0 Then mgID = 1
				PostMsg = mgID
			else
				PostMsg="0" & errMessage(objTest.errcode)
				appLog.addlog errMessage(objTest.errcode)
			end if
		end function
		Public Function GetRecentlyMsg(ByVal userId)
			Dim rs,sql,avatar,msg,temp,content,flagTime,mgID
			temp = "{rows:["
			Set rs = server.CreateObject("adodb.recordset")
			sql =       "SELECT * FROM (" &_
			"  SELECT TOP 4 (case when a.SendOrReceive=1 then b.headimgPath else (select top 1 photos from hr_person hp where hp.userid=a.cateid) end) headimgPath, a.*  " &_
			"  FROM MMsg_Message a " &_
			"  INNER JOIN MMsg_User b ON a.userId = b.id " &_
			"  WHERE a.accId = 1 AND userId = "& userId &" " &_
			"  ORDER BY a.id DESC " &_
			") x ORDER BY x.id ASC"
			rs.Open sql,cn,1,1
			If Not rs.Eof Then
				While rs.Eof = False
					mgID = rs("ID")
					avatar = rs("headimgPath")
					msg = rs("Content")
					flagTime = FromUnixTime(rs("createTime"))
					Select Case LCase(rs("msgType"))
					Case "text":
					content = replaceFaces(Replace(msg,Chr(10),"<br>"))
					Case "image":
					content = "<img src='../MicroMsg/" & rs("PicUrl") & "' style='cursor:hand;height:90px;' onclick='showPic(this);' title='点击查看原图'/>"
					Case "audio","voice":
					content = "<a href='javascript:void(0);' file='" & HexEncode(server.mappath(rs("MediaPath"))) & "' style='cursor:hand;' onclick='downloadFile(this);' title='点击下载该音频文件'>[语音信息]</a>"
					Case "video","shortvideo":
					content = "<img src='../MicroMsg/" & rs("ThumbMediaId") & "' file='" & HexEncode(server.mappath(rs("MediaPath"))) & "' style='cursor:hand;height:90px;' onclick='downloadFile(this);' title='点击下载该视频文件'/>"
					Case "location":
					content = "<img src='http://st.map.qq.com/api?size=600*300&center="&rs("Location_Y")&","&rs("Location_X")&"&zoom="&rs("Scale")&"&markers="&rs("Location_Y")&","&rs("Location_X")&"' onclick='showPic(this);' title='" & rs("Label") & "[点击放大]' style='cursor:hand;height:90px;float:left'>"
					Case Else
					content = ""
					End Select
					temp = temp & "{"
					temp = temp & """type"":"""& rs("sendOrReceive") &""","
					temp = temp & """avatar"":"""& avatar &""","
					temp = temp & """msg"":"""& FilterStr(content) &""","
					temp = temp & """timeFlag"":"""& rs("timeFlag") &""","
					temp = temp & """flagTime"":"""& flagTime &""","
					temp = temp & """mgID"":"""& mgID &""""
					temp = temp & "}"
					cn.Execute("UPDATE MMsg_Message SET timeFlag = -1 WHERE timeFlag = 0 AND id = "& mgID &" ")
					temp = temp & "}"
					rs.movenext
					If rs.Eof = False Then temp = temp & ","
				wend
			end if
			rs.close
			set rs = nothing
			temp = temp & "],curDate:"""& Date() &"""}"
			GetRecentlyMsg = temp
		end function
		Public Function GetMoreMsg(ByVal userId,ByVal msgID)
			Dim rs,sql,avatar,msg,temp,content,flagTime,mgID
			temp = "["
			Set rs = server.CreateObject("adodb.recordset")
			sql =       "SELECT * FROM (" &_
			"  SELECT TOP 11 (case when a.SendOrReceive=1 then b.headimgPath else (select top 1 photos from hr_person hp where hp.userid=a.cateid) end) headimgPath, a.*  " &_
			"  FROM MMsg_Message a " &_
			"  INNER JOIN MMsg_User b ON a.userId = b.id " &_
			"  WHERE a.accId = 1 AND userId = "& userId &" AND a.id <= "& msgID &" " &_
			"  ORDER BY a.id DESC " &_
			") x ORDER BY x.id ASC"
			rs.Open sql,cn,1,1
			If Not rs.Eof Then
				While rs.Eof = False
					mgID = rs("ID")
					avatar = rs("headimgPath")
					msg = rs("Content")
					flagTime = FromUnixTime(rs("createTime"))
					Select Case LCase(rs("msgType"))
					Case "text":
					content = replaceFaces(Replace(msg,Chr(10),"<br>"))
					Case "image":
					content = "<img src='../MicroMsg/" & rs("PicUrl") & "' style='cursor:hand;height:90px;' onclick='showPic(this);' title='点击查看原图'/>"
					Case "audio","voice":
					content = "<a href='javascript:void(0);' file='" & HexEncode(server.mappath(rs("MediaPath"))) & "' style='cursor:hand;' onclick='downloadFile(this);' title='点击下载该音频文件'>[语音信息]</a>"
					Case "video","shortvideo":
					content = "<img src='../MicroMsg/" & rs("ThumbMediaId") & "' file='" & HexEncode(server.mappath(rs("MediaPath"))) & "' style='cursor:hand;height:90px;' onclick='downloadFile(this);' title='点击下载该视频文件'/>"
					Case "location":
					content = "<img src='http://st.map.qq.com/api?size=600*300&center="&rs("Location_Y")&","&rs("Location_X")&"&zoom="&rs("Scale")&"&markers="&rs("Location_Y")&","&rs("Location_X")&"' onclick='showPic(this);' title='" & rs("Label") & "[点击放大]' style='cursor:hand;height:90px;float:left'>"
					Case Else
					content = ""
					End Select
					temp = temp & "{"
					temp = temp & """type"":"""& rs("sendOrReceive") &""","
					temp = temp & """avatar"":"""& avatar &""","
					temp = temp & """msg"":"""& FilterStr(content) &""","
					temp = temp & """timeFlag"":"""& rs("timeFlag") &""","
					temp = temp & """flagTime"":"""& flagTime &""","
					temp = temp & """mgID"":"""& mgID &""""
					temp = temp & "}"
					cn.Execute("UPDATE MMsg_Message SET timeFlag = -1 WHERE timeFlag = 0 AND id = "& mgID &" ")
					temp = temp & "}"
					rs.movenext
					If rs.Eof = False Then temp = temp & ","
				wend
			end if
			rs.close
			set rs = nothing
			temp = temp & "]"
			GetMoreMsg = temp
		end function
		Public Function GetHisMsg(ByVal userId,ByVal pageIndex,ByVal pagesize,ByVal sDate)
			Dim rs,sql,avatar,msg,temp,content,flagTime,createTime,recordCount,pageCount,nickName
			temp = "{rows:["
			Set rs = server.CreateObject("adodb.recordset")
			Dim whereSql
			If sDate <> "" Then
				whereSql = " AND DATEDIFF(D,[dbo].[convertGMT](a.CreateTime),'"& sDate &"') = 0 "
			end if
			sql =       "      SELECT (case when a.SendOrReceive=1 then b.headimgPath else (select top 1 photos from hr_person hp where hp.userid=a.cateid) end) headimgPath, " &_
			"  (CASE WHEN a.SendOrReceive=1 THEN b.nickName ELSE (select top 1 username from hr_person hp where hp.userid=a.cateid)  END) AS nickName, a.* " &_
			"  FROM MMsg_Message a " &_
			"  INNER JOIN MMsg_User b ON a.userId = b.id " &_
			"  WHERE a.accId = 1 AND userId = "& userId &" "& whereSql &" " &_
			"  ORDER BY a.id DESC "
			rs.Open sql,cn,1,1
			If Not rs.Eof Then
				Dim i : i = 0
				If pagesize <= 0 Then pagesize= 10
				If pageindex <=0 Then pageindex = 1
				rs.PageSize = pagesize
				recordCount = rs.RecordCount
				pageCount = rs.PageCount
				If pageindex > pageCount Then pageindex = pageCount
				rs.AbsolutePage = pageindex
				While rs.eof = False And i < pagesize
					createTime = FromUnixTime(rs("createTime"))
					avatar = rs("headimgPath")
					msg = rs("Content")
					flagTime = FromUnixTime(rs("createTime"))
					nickName = rs("nickName")
					Select Case LCase(rs("msgType"))
					Case "text":
					content = replaceFaces(Replace(msg,Chr(10),"<br>"))
					Case "image":
					content = "<img src='../MicroMsg/" & rs("PicUrl") & "' style='cursor:hand;height:90px;' onclick='showPic(this);' title='点击查看原图'/>"
					Case "audio","voice":
					content = "<a href='javascript:void(0);' file='" & HexEncode(server.mappath(rs("MediaPath"))) & "' style='cursor:hand;' onclick='downloadFile(this);' title='点击下载该音频文件'>[语音信息]</a>"
					Case "video","shortvideo":
					content = "<img src='../MicroMsg/" & rs("ThumbMediaId") & "' file='" & HexEncode(server.mappath(rs("MediaPath"))) & "' style='cursor:hand;height:90px;' onclick='downloadFile(this);' title='点击下载该视频文件'/>"
					Case "location":
					content = "<img src='http://st.map.qq.com/api?size=600*300&center="&rs("Location_Y")&","&rs("Location_X")&"&zoom="&rs("Scale")&"&markers="&rs("Location_Y")&","&rs("Location_X")&"' onclick='showPic(this);' title='" & rs("Label") & "[点击放大]' style='cursor:hand;height:90px;float:left'>"
					Case Else
					content = ""
					End Select
					temp = temp & "{"
					temp = temp & """type"":"""& rs("sendOrReceive") &""","
					temp = temp & """avatar"":"""& avatar &""","
					temp = temp & """msg"":"""& FilterStr(content) &""","
					temp = temp & """timeFlag"":"""& rs("timeFlag") &""","
					temp = temp & """flagTime"":"""& flagTime &""","
					temp = temp & """createTime"":"""& createTime &""","
					temp = temp & """nickName"":"""& nickName &""""
					temp = temp & "}"
					i = i + 1
					temp = temp & "}"
					rs.movenext
					If rs.Eof = False And i < pagesize Then temp = temp & ","
				wend
			end if
			rs.close
			set rs = nothing
			temp = temp & "],pageinfo:{""pageindex"":"""& pageindex &""",""pagecount"":"""& pageCount &""",""curDate"":"""& Date() &"""}}"
			GetHisMsg = temp
		end function
		Public Function GetCurMsg(ByVal userId)
			Dim rs,sql,avatar,msg,temp,content,flagTime,mgID
			temp = "["
			Set rs = server.CreateObject("adodb.recordset")
			sql =       "SELECT TOP 1 a.id AS mgID,(case when a.SendOrReceive=1 then b.headimgPath else (select top 1 photos from hr_person hp where hp.userid=a.cateid) end) AS headimgPath,a.Content,ISNULL(a.timeFlag,0) timeFlag,a.createTime AS createTime, a.*  " &_
			"FROM MMsg_Message a " &_
			"INNER JOIN MMsg_User b ON a.userId = b.id " &_
			"WHERE a.accId = 1 AND sendOrReceive = 1 AND timeFlag = 0 AND userId = "& userId &" " &_
			"ORDER BY a.id asc"
			rs.Open sql,cn,1,1
			If Not rs.Eof Then
				avatar = rs("headimgPath")
				msg = rs("Content")
				flagTime = FromUnixTime(rs("createTime"))
				mgID = rs("mgID")
				Select Case LCase(rs("msgType"))
				Case "text":
				content = replaceFaces(Replace(msg,Chr(10),"<br>"))
				Case "image":
				content = "<img src='../MicroMsg/" & rs("PicUrl") & "' style='cursor:hand;height:90px;' onclick='showPic(this);' title='点击查看原图'/>"
				Case "audio","voice":
				content = "<a href='javascript:void(0);' file='" & HexEncode(server.mappath(rs("MediaPath"))) & "' style='cursor:hand;' onclick='downloadFile(this);' title='点击下载该音频文件'>[语音信息]</a>"
				Case "video","shortvideo":
				content = "<img src='../MicroMsg/" & rs("ThumbMediaId") & "' file='" & HexEncode(server.mappath(rs("MediaPath"))) & "' style='cursor:hand;height:90px;' onclick='downloadFile(this);' title='点击下载该视频文件'/>"
				Case "location":
				content = "<img src='http://st.map.qq.com/api?size=600*300&center="&rs("Location_Y")&","&rs("Location_X")&"&zoom="&rs("Scale")&"&markers="&rs("Location_Y")&","&rs("Location_X")&"' onclick='showPic(this);' title='" & rs("Label") & "[点击放大]' style='cursor:hand;height:90px;float:left'>"
				Case Else
				content = ""
				End Select
				temp = temp & "{"
				temp = temp & """type"":"""& rs("sendOrReceive") &""","
				temp = temp & """avatar"":"""& avatar &""","
				temp = temp & """msg"":"""& FilterStr(content) &""","
				temp = temp & """timeFlag"":"""& rs("timeFlag") &""","
				temp = temp & """flagTime"":"""& flagTime &""","
				temp = temp & """mgID"":"""& mgID &""""
				temp = temp & "}"
				rs.movenext
				If rs.Eof = False Then temp = temp & ","
			end if
			rs.close
			set rs = nothing
			temp = temp & "]"
			GetCurMsg = temp
		end function
		Public Sub loadFans(ByVal openid)
			Dim strJson,openidlist,objTest,i
			strJson = GetURL(GET_USER_LIST_URL & "access_token=" & Access_token & "&next_openid=" & openid)
			Call InitScriptControl:Set objTest = getJSONObject(strJson)
			if InStr(strJson,"errcode")>0 then
				appLog.addlog errMessage(objTest.errcode)
				Exit Sub
			else
				if objTest.total > 0 then
					openid = objTest.next_openid
					Dim openids : openids = ""
					Dim oid
					i = 0
					For Each oid In objTest.data.openid
						openids = openids & iif(openids&""="","",",") & oid
						If (i + 1) Mod 100 = 0 Then
							openids = openids & iif(openids&""="","",",") & oid
							appLog.addlog "openid长度：" & ubound(Split(openids,","))
							Call refreshUserInfo(openids)
							openids = ""
						end if
						i = i + 1
						openids = ""
					next
					If openids & "" <> "" Then
						appLog.addlog "openid长度：" & ubound(Split(openids,","))
						Call refreshUserInfo(openids)
					end if
					If objTest.count = 10000 Then Call loadFans(openid)
				end if
				Call loadGroups()
			end if
		end sub
		Public Sub onSubscribe(id)
			Dim strJson,rs,sql,objTest,headimgurl,newid,nickname
			strJson=GetURL(GET_USER_INFO_URL & "access_token=" & Access_token & "&openid=" & id & "")
			Call InitScriptControl:Set objTest = getJSONObject(strJson)
			if InStr(strJson,"errcode")>0 then
				appLog.addlog errMessage(objTest.errcode)
				Exit Sub
			end if
			headimgurl = objTest.headimgurl
			Set rs = server.CreateObject("adodb.recordset")
			sql = "select * from MMsg_User where openId='" & id & "'"
			rs.open sql,cn,3,3
			If rs.eof Then
				rs.addNew
				rs("accId") = accId
				rs("openId") = objTest.openid
				nickname = objTest.nickname
				rs("nickName") = nickname
				rs("sex") = objTest.sex
				rs("country") = objTest.country
				rs("province") = objTest.province
				rs("city") = objTest.city
				rs("language") = objTest.language
				rs("headimgurl") = headimgurl
				If Len(headimgurl) > 0 Then
					rs("headimgPath") = saveRemoteFile(headimgurl)
				end if
				rs("subscribe_time") = FromUnixTime(objTest.subscribe_time)
				rs("CreateTime") = now
				rs("subscribe_stat") = 1
				rs("groupId") = 0
				rs("stat") = 1
				rs.update
				rs.close
				Set rs=Nothing
				newid = cn.execute("select max(id) from MMsg_User where isnull(cateid,0) = 0")(0)
				cn.execute "exec MMsg_AutoAllocateUser " & newid
			else
				nickname = objTest.nickname
				If nickname & "" <> "" Then
					rs("nickName") = nickname
				end if
				rs("sex") = objTest.sex
				rs("country") = objTest.country
				rs("province") = objTest.province
				rs("city") = objTest.city
				rs("language") = objTest.language
				If headimgurl<>"" And headimgurl <> rs("headimgurl") Then
					rs("headimgurl") = headimgurl
					If Len(headimgurl) > 0 Then
						rs("headimgPath") = saveRemoteFile(headimgurl)
					else
						rs("headimgPath") = ""
					end if
				end if
				rs("subscribe_time") = now
				rs("subscribe_stat") = 1
				rs.update
				rs.close
				set rs = nothing
			end if
		end sub
		Public Function saveRemoteFile(sRemoteFileUrl)
			Dim folderName,fileName, virfd
			Randomize
			virfd = "remoteFiles/" & year(date) & Right("0"&month(date),2) & Right("0"&day(date),2)
			folderName = Me.sdk.GetVirPath() & "micromsg/remoteFiles/" & year(date) & Right("0"&month(date),2) & Right("0"&day(date),2)
			fileName = hour(now) & minute(now) & second(now) &  Int(Rnd * 10000)
			If Not Me.sdk.file.ExistsDir(folderName) Then Call Me.sdk.file.CreateFolder(folderName)
			fileName = Me.sdk.file.DownloadWebFile(sRemoteFileUrl,folderName,fileName)
			saveRemoteFile = virfd & "/" & fileName
		end function
		Public Sub refreshUserBaseInfo(userobj)
			Set rs = server.CreateObject("adodb.recordset")
			sql = "select top 1 * from MMsg_User where openId='" & userobj.openid & "'"
			rs.open sql,cn,3,3
			If rs.eof = False Then
				headimgurl = userobj.headimgurl
				nickname = userobj.nickname
				rs("nickName") = base64.Utf8CharHtmlConvert(nickname)
				rs("sex") = userobj.sex
				rs("country") = userobj.country
				rs("province") = userobj.province
				rs("city") = userobj.city
				rs("language") = userobj.language
				If headimgurl <> rs("headimgurl") Then
					rs("headimgurl") = ""
					If Len(headimgurl) > 0 Then
						headimgPath = saveRemoteFile(headimgurl)
						rs("headimgPath") = headimgPath
						If Len(headimgPath) > 0  Then
							If Me.sdk.file.existsFile(server.mappath(Me.sdk.getvirpath & "MicroMsg/" & headimgPath)) Then
								rs("headimgurl") = headimgurl
							end if
						end if
					end if
				end if
				rs.update
				rs.close
				set rs = nothing
			else
				rs.addNew
				rs("accId") = accId
				rs("openId") = userobj.openid
				nickname = userobj.nickname
				rs("nickName") = base64.Utf8CharHtmlConvert(nickname)
				rs("sex") = userobj.sex
				rs("country") = userobj.country
				rs("province") = userobj.province
				rs("city") = userobj.city
				rs("language") = userobj.language
				rs("headimgurl") = ""
				If Len(headimgurl) > 0 Then
					headimgPath = saveRemoteFile(headimgurl)
					rs("headimgPath") = headimgPath
					If Len(headimgPath) > 0  Then
						If Me.sdk.file.existsFile(server.mappath(Me.sdk.getvirpath & "MicroMsg/" & headimgPath)) Then
							rs("headimgurl") = headimgurl
						end if
					end if
				end if
				rs("subscribe_time") = FromUnixTime(userobj.subscribe_time)
				rs("CreateTime") = now
				rs("subscribe_stat") = 1
				rs("stat") = 1
				rs.update
				rs.close
				Set rs=Nothing
				newid = cn.execute("select max(id) from MMsg_User where isnull(cateid,0) = 0")(0)
				cn.execute "exec MMsg_AutoAllocateUser " & newid
			end if
		end sub
		Public Sub refreshUserInfo(ids)
			Dim strJson,i,arrId,objTest,rs,sql,newid
			strJson = "" &_
			"{" &_
			"""user_list"": ["
			arrId = Split(ids,",")
			For i = 0 To ubound(arrId)
				strJson = strJson & IIf(i=0,"",",") & "{""openid"": """ & arrId(i) & """,""lang"":""zh_CN""}"
			next
			strJson = strJson & "]" &_
			"}"
			strJson = PostURL(GET_USER_INFO_BATCH_URL & "&access_token=" & Access_token,strJson)
			Call InitScriptControl:Set objTest = getJSONObject(strJson)
			if InStr(strJson,"errcode")>0 then
				appLog.addlog errMessage(objTest.errcode)
				Exit Sub
			end if
			Dim userlist : Set userlist = objTest.user_info_list
			Dim userobj,headimgurl,nickname
			Dim headimgPath
			For Each userobj In userlist
				Set rs = server.CreateObject("adodb.recordset")
				sql = "select * from MMsg_User where openId='" & userobj.openid & "'"
				rs.open sql,cn,3,3
				If userobj.subscribe = 1 Then
					headimgurl = userobj.headimgurl
					If rs.eof = False Then
						nickname = userobj.nickname
						If nickname & "" <> "" Then
							rs("nickName") = base64.Utf8CharHtmlConvert(nickname)
						end if
						rs("sex") = userobj.sex
						rs("country") = userobj.country
						rs("province") = userobj.province
						rs("city") = userobj.city
						rs("language") = userobj.language
						If headimgurl<>"" And headimgurl <> rs("headimgurl") Then
							rs("headimgurl") = ""
							If Len(headimgurl) > 0 Then
								headimgPath = saveRemoteFile(headimgurl)
								rs("headimgPath") = headimgPath
								If Len(headimgPath) > 0  Then
									If Me.sdk.file.existsFile(server.mappath(Me.sdk.getvirpath & "MicroMsg/" & headimgPath)) Then
										rs("headimgurl") = headimgurl
									end if
								end if
							end if
						end if
						rs("groupId") = userobj.groupid
						rs.update
						rs.close
						set rs = nothing
					else
						rs.addNew
						rs("accId") = accId
						rs("openId") = userobj.openid
						nickname = userobj.nickname
						rs("nickName") = base64.Utf8CharHtmlConvert(nickname)
						rs("sex") = userobj.sex
						rs("country") = userobj.country
						rs("province") = userobj.province
						rs("city") = userobj.city
						rs("language") = userobj.language
						rs("headimgurl") = ""
						If Len(headimgurl) > 0 Then
							headimgPath = saveRemoteFile(headimgurl)
							rs("headimgPath") = headimgPath
							If Len(headimgPath) > 0  Then
								If Me.sdk.file.existsFile(server.mappath(Me.sdk.getvirpath & "MicroMsg/" & headimgPath)) Then
									rs("headimgurl") = headimgurl
								end if
							end if
						end if
						rs("subscribe_time") = FromUnixTime(userobj.subscribe_time)
						rs("CreateTime") = now
						rs("subscribe_stat") = 1
						rs("groupId") = userobj.groupid
						rs("stat") = 1
						rs.update
						rs.close
						Set rs=Nothing
						newid = cn.execute("select max(id) from MMsg_User where isnull(cateid,0) = 0")(0)
						cn.execute "exec MMsg_AutoAllocateUser " & newid
					end if
				end if
			next
			Call loadGroups()
		end sub
		Public Sub loadGroups()
			Dim strJson,objTest,gp,gpname
			strJson = GetURL(GET_GROUP_LIST_URL & "&access_token=" & Access_token)
			Call InitScriptControl:Set objTest = getJSONObject(strJson)
			if InStr(strJson,"errcode")>0 then
				appLog.addlog errMessage(objTest.errcode)
				Exit Sub
			end if
			Dim rs : Set rs = server.CreateObject("adodb.recordset")
			For Each gp In objTest.groups
				rs.open "select * from MMsg_Group where id=" & gp.id,cn,3,3
				If rs.eof Then
					rs.addNew
					rs("id") = gp.id
				end if
				gpname = gp.name
				rs("name") = gpname
				rs.update
				rs.close
			next
			set rs = nothing
		end sub
		Function getUserInfo(code)
			Dim objTest
			Dim url : url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=" & AppId & "&secret=" & Appsecret & _
			"&code=" & code & "&grant_type=authorization_code"
			Dim strJson : strJson = GetURL(url)
			Dim openid,accessToken,errmsg
			Call InitScriptControl:Set objTest = getJSONObject(strJson)
			if InStr(strJson,"errcode")>0 then
				appLog.addlog errMessage(objTest.errcode) & url
				getUserInfo = ""
				Exit Function
			end if
			getUserInfo = objTest.openid
		end function
		Function getUserBaseInfo(code)
			Dim objTest
			Dim url : url = GET_ACCESSTOKEN_URL & AppId & "&secret=" & Appsecret & "&code=" & code & "&grant_type=authorization_code"
			Dim strJson : strJson = GetURL(url)
			Dim openid,accessToken,errmsg
			Call InitScriptControl:Set objTest = getJSONObject(strJson)
			if InStr(strJson,"errcode")>0 then
				appLog.addlog errMessage(objTest.errcode) & url
				getUserInfo = null
				Exit Function
			end if
			openid = objTest.openid
			accessToken = objTest.access_token
			url = GET_USERINFO_URL& accessToken &"&openid="& openid &"&lang=zh_CN"
			strJson = GetURL(url)
			Call InitScriptControl:Set objTest = getJSONObject(strJson)
			if InStr(strJson,"errcode")>0 then
				appLog.addlog errMessage(objTest.errcode) & url
				getUserInfo = null
				Exit Function
			end if
			Set getUserBaseInfo = objTest
		end function
		Function GetJsApiTicket()
			Dim objTest
			Dim url : url = GET_JSAPI_TICKET&"access_token=" & accessToken & "&type=jsapi"
			Dim jsApi_time : jsApi_time = Request.cookies("jsApi_time")
			Dim expires_in : expires_in = Request.cookies("expires_in")
			Dim jsApi_ticket : jsApi_ticket = Request.cookies("jsApi_ticket")
			Dim strJson
			If Len(expires_in) > 0 And Len(jsApi_time) > 0 Then
				If DateDiff("s",jsApi_time,now()) > expires_in Then
					strJson = GetURL(url)
					If Len(strJson) = 0 Then
						GetJsApiTicket = "错误：请求服务器失败，请检查网络"
						log.addlog errMessage(objTest.errcode)
						Exit Function
					end if
					log.addlog strJson
					Call InitScriptControl:Set objTest = getJSONObject(strJson)
					If objTest.errcode <> "0" Then
						GetJsApiTicket = "错误：" & errMessage(objTest.errcode)
						log.addlog errMessage(objTest.errcode) & ",source:" & strJson
						Exit Function
					end if
					Response.cookies("jsApi_ticket") = objTest.ticket
					Response.cookies("expires_in") = objTest.expires_in
					Response.cookies("jsApi_time") = now()
					GetJsApiTicket = objTest.ticket
				else
					GetJsApiTicket = jsApi_ticket
				end if
			else
				strJson = GetURL(url)
				Call InitScriptControl:Set objTest = getJSONObject(strJson)
				If objTest.errcode <> "0" Then
					log.addlog errMessage(objTest.errcode)
					Exit Function
				end if
				GetJsApiTicket = objTest.ticket
			end if
		end function
		Public Function wxpay_GetPayParams(openid,body,attach,billno,ipaddr,amount)
			on error resume next
			Dim url : url = WX_CREATE_PRE_ORDER_URL
			Dim strJson
			Dim nonce_str : nonce_str = nonceStr(32)
			Dim mAppId : mAppId = appId
			Dim machId : machId = merchantId(WX_PAY_ID)
			Dim notify_url : notify_url =  hostname & "SYSA/MicroMsg/mobile/shop/wxnotify.asp"
			Dim signori : signori = "appid=" & mAppId & _
			"iif(attach&""""="""","""",""&attach="" & attach)" & _
			"iif(body&""="","","&body=" & body)" & _
			"&mch_id=" & machId & _
			"&nonce_str=" & nonce_str & _
			"&notify_url=" & notify_url & _
			"&openid=" & openid & _
			"&out_trade_no=" & billno & _
			"&spbill_create_ip=" & ipaddr & _
			"&total_fee=" & amount & _
			"&trade_type=JSAPI"
			Dim signstr
			Dim xml_dom,xmldata
			signstr = utf8md5(signori & "&key=" & merchantKey(WX_PAY_ID))
			If Err.number <> 0 Then
				appLog.addLog Err.description
			end if
			dim t:t="<xml>" & _
			"<appid>" & mAppId & "</appid>" & _
			"<attach><![CDATA[" & attach & "]]></attach>" & _
			"<body><![CDATA[" & body & "]]></body>" & _
			"<mch_id>" & machId & "</mch_id>" & _
			"<nonce_str>" & nonce_str & "</nonce_str>" & _
			"<notify_url>" & notify_url & "</notify_url>" & _
			"<openid>" & openid & "</openid>" & _
			"<out_trade_no>" & billno & "</out_trade_no>" & _
			"<spbill_create_ip>" & ipaddr & "</spbill_create_ip>" & _
			"<total_fee>" & amount & "</total_fee>" & _
			"<trade_type>JSAPI</trade_type>" & _
			"<sign>" & signstr & "</sign>" & _
			"</xml>"
			Err.clear
			Dim Retrieval
			Set Retrieval = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
			With Retrieval
			.Open "POST", url, false ,"" ,""
			.setRequestHeader "Content-Type", "text/xml; charset=UTF-8"
			'.Open "POST", url, false ,"" ,""
			.SetClientCertificate "CURRENT_USER\MY\" & merchantName
			.Send app.base64.UnicodeToUtf8(t)
			.WaitForResponse
			If Abs(Err.number) <> 0 Then
				If InStr(Err.description,"客户验证") > 0 Then
					strJson = "{success:false,msg:'请检查根证书是否正确安装！'}"
				else
					strJson = "{'success':false,'msg':'" & Replace(Replace(Err.description,"'","\'"),vbcrlf, "\r\n") & "'}"
				end if
				Set wxpay_GetPayParams = parseJSON(strjson)
				Exit Function
			end if
			Set xml_dom = Server.CreateObject("MSXML2.DOMDocument")
			xml_dom.resolveExternals = false
			xmldata = app.base64.Utf8ToUnicode(.responseBody, true)
			If xml_dom.loadxml(xmldata)=False Then
				appLog.addLog "xml解析错误，xml内容：" & xmldata
				Set wxpay_GetPayParams = parseJSON("{success:false,msg:'连接服务器失败，请检查服务器网络环境，如有疑问，请联系智邦国际'}")
				Exit Function
			else
				Dim return_code : return_code = xml_dom.getElementsByTagName("return_code").item(0).Text
				Dim return_msg : return_msg = xml_dom.getElementsByTagName("return_msg").item(0).Text
				If return_code <> "SUCCESS" Then
					appLog.addLog "支付接口调用失败，错误信息：" & return_msg
					Set wxpay_GetPayParams = parseJSON("{success:false,msg:'" & return_msg & "'}")
					Exit Function
				else
					Dim result_code : result_code =  xml_dom.getElementsByTagName("result_code").item(0).Text
					If result_code <> "SUCCESS" Then
						Dim err_code_des : err_code_des = xml_dom.getElementsByTagName("err_code_des").item(0).Text
						appLog.addLog "支付接口调用失败,错误信息：" & err_code_des
						Set wxpay_GetPayParams = parseJSON("{success:false,msg:'调用支付接口失败，消息：" & err_code_des & "'}")
						Exit Function
					else
						Dim prepay_id : prepay_id = xml_dom.getElementsByTagName("prepay_id").item(0).Text
						Set wxpay_GetPayParams = parseJSON("{success:true,msg:'ok',prepay_id:'" & prepay_id & "'}")
						Dim timeStamp : timeStamp = ToUnixTime(now)
						nonce_str = nonceStr(32)
						signori = "appId=" & mAppId & "&nonceStr=" & nonce_str & "&package=prepay_id="& prepay_id & "&signType=MD5&timeStamp=" & timeStamp
						Dim paySign : paySign = UCase(base64.MD5(signori & "&key=" & merchantKey(WX_PAY_ID)))
						Set wxpay_GetPayParams = parseJSON("{success:true,msg:'ok',params:{" & _
						"appId:'" & mAppId & "'," &_
						"timeStamp:'" & timeStamp & "'," &_
						"nonceStr:'" & nonce_str & "'," &_
						"package:'prepay_id=" & prepay_id & "'," &_
						"signType:'MD5'," &_
						"paySign:'" & paySign & "'" &_
						"}}")
					end if
				end if
			end if
			End With
			If Abs(Err.number) <> 0 Then
				strJson = "{success:false,msg:'连接服务器失败，请检查服务器网络环境，如有疑问，请联系智邦国际'}"
				Set wxpay_GetPayParams = parseJSON(strjson)
			end if
			Set Retrieval = Nothing
			On Error GoTo 0
		end function
		Public Sub onUnSubscribe(id)
			cn.execute("update MMsg_User set subscribe_stat=2,unsubscribe_time=getdate() where openId='" & id & "'")
		end sub
		Public Function loadLocalMenuJson()
			Dim rs,rsSub,json
			Set rs = cn.execute("select * from MMsg_Menu where pid=0 order by sort")
			If rs.eof Then
				loadLocalMenuJson = ""
				Exit Function
			end if
			json = "{""button"":["
			While rs.eof = False
				json = json & "{" &_
				"""name"":""" & FilterStr(rs("name")) & """," & _
				"""type"":""" & rs("actType") & """," & _
				"""url"":""" & FilterStr(rs("url")) & """," & _
				"""key"":""" & FilterStr(rs("Keyword")) & """"
				Set rsSub = cn.execute("select * from MMsg_Menu where pid=" & rs("id") & " order by sort")
				If rsSub.eof = False Then
					json = json & "," &_
					"""sub_button"":["
					While rsSub.eof = False
						json = json & "{" &_
						"""name"":""" & FilterStr(rsSub("name")) & """," & _
						"""type"":""" & rsSub("actType") & """," & _
						"""url"":""" & FilterStr(rsSub("url")) & """," & _
						"""key"":""" & FilterStr(rsSub("Keyword")) & """" &_
						"}"
						rsSub.movenext
						If rsSub.eof = False Then json = json & ","
					wend
					json = json & "]"
				end if
				rsSub.close
				Set rsSub = Nothing
				json = json & "}"
				rs.movenext
				If rs.eof = False Then json = json & ","
			wend
			rs.close
			set rs = nothing
			json = json & "]}"
			loadLocalMenuJson = json
		end function
		Public Function loadRemoteMenuToDB()
			Dim strJson,jsonObject,numbtn,rs,rsSub,menuId
			strJson = GetURL(GET_MENU_URL & "&access_token=" & Access_token)
			If InStr(strJson,"errcode")>0 Then
				loadRemoteMenuToDB = "远程菜单不存在"
				Exit Function
			end if
			strJson=left(strJson,len(strJson)-1)
			Exit Function
			strJson=Mid(strJson,35)
			strJson=replace(strJson,",""sub_button"":[]","")
			Set jsonObject = parseJSON(strJson)
			numbtn = jsonObject.button.length
			cn.CursorLocation = 3
			cn.beginTrans
			cn.execute "truncate table MMsg_Menu"
			Dim i,j,menuType
			Set rs = server.CreateObject("adodb.recordset")
			rs.open "select * from MMsg_Menu where 1=2",cn,3,3
			Set rsSub = server.CreateObject("adodb.recordset")
			rsSub.open "select * from MMsg_Menu where 1=2",cn,3,3
			For i = 0 To numbtn - 1
				rsSub.open "select * from MMsg_Menu where 1=2",cn,3,3
				rs.addNew
				rs("pid") = 0
				rs("name") = jsonObject.button.Get(i).name
				rs("sort") = cn.execute("select isnull(max(sort),0) + 1 from MMsg_Menu where pid=0")(0)
				rs("name") = jsonObject.button.Get(i).name
				rs.update
				menuId = cn.execute("select max(id) from MMsg_Menu")(0)
				If isEmpty(scriptCtrl.eval("result.button["& i &"].sub_button")) Then
					menuType = jsonObject.button.Get(i).type
					rs("actType") = menuType
					Select Case menuType
					case "click"
					rs("Keyword") = jsonObject.button.Get(i).Key
					case "view"
					rs("url") = jsonObject.button.Get(i).url
					End Select
					rs.update
				Else
					for j = 0 to jsonObject.button.Get(i).sub_button.list.length - 1
'Else
						rsSub.addNew
						rsSub("pid") = menuId
						rsSub("sort") = cn.execute("select isnull(max(sort),0) + 1 from MMsg_Menu where pid=" & menuId)(0)
						'rsSub("pid") = menuId
						rsSub("name") = jsonObject.button.Get(i).sub_button.list.Get(j).name
						menuType = jsonObject.button.Get(i).sub_button.list.Get(j).type
						rsSub("actType") = menuType
						select case menuType
						case "click"
						rsSub("Keyword") = jsonObject.button.Get(i).sub_button.list.Get(j).key
						case "view"
						rsSub("url") = jsonObject.button.Get(i).sub_button.list.Get(j).url
						End Select
						rsSub.update
					next
				end if
			next
			rsSub.close
			Set rsSub = Nothing
			rs.close
			Set rs=Nothing
			cn.commitTrans
			Set jsonObject = Nothing
			If IsObject(scriptCtrl) Then Set scriptCtrl = Nothing
			loadRemoteMenuToDB = ""
		end function
		Public Function getMenuJson()
			getMenuJson = GetURL(GET_MENU_URL & "&access_token=" & Access_token)
		end function
		Public Function setMenuJson(menujson)
			setMenuJson = PostURL(SET_MENU_URL & "&access_token=" & Access_token,menujson)
		end function
		Public Function delMenu()
			delMenu = GetURL(DEL_MENU_URL & "&access_token=" & Access_token)
		end function
		Public Function commitLocalMenuToServer()
			Dim menuJson : menuJson = loadLocalMenuJson()
			Dim strJson
			If menuJson = "" Then
				strJson = delMenu()
			else
				strJson = setMenuJson(menuJson)
			end if
			Dim objTest
			Call InitScriptControl:Set objTest = getJSONObject(strJson)
			if objTest.errcode="0" then
				commitLocalMenuToServer = ""
			else
				commitLocalMenuToServer = errMessage(objTest.errcode)
			end if
		end function
		Public Function isMsgExists(msgid)
			If msgid & "" = "" Then
				isMsgExists = False
			else
				isMsgExists = cn.execute("select top 1 1 from MMsg_Message where msgId=" & msgid).eof = False
			end if
		end function
		Public Function getUserIdByOpenId(openid)
			Dim rs
			Set rs = cn.execute("select id from MMsg_User where openid='" & openid & "'")
			If rs.eof = False Then
				getUserIdByOpenId = CLng(rs(0))
			else
				getUserIdByOpenId = -1
				'getUserIdByOpenId = CLng(rs(0))
			end if
			rs.close
			Set rs=Nothing
		end function
		Public Function getOpenIdByUserId(userid)
			Dim rs
			Set rs = cn.execute("select openid from MMsg_User where id=" & userid)
			If rs.eof = False Then
				getOpenIdByUserId = rs(0)
			else
				getOpenIdByUserId = ""
			end if
			rs.close
			Set rs=Nothing
		end function
		Public Sub saveMessage(accId,userId,CreateTime,MsgType,Content,PicUrl,MediaId,Format,Recognition,ThumbMediaId,_
			Location_X,Location_Y,Scale,Label,Title,Description,Url,MsgId,cateid)
			Dim sql,Rs,uid
			sql = "select top 1 * from MMsg_Message where msgid= " & MsgId
			Set Rs = server.CreateObject("adodb.recordset")
			Rs.Open sql,Conn,1,3
			If MsgId & "" <> "" And Not Rs.EOF Then
				rs.close
				set rs = nothing
				Exit Sub
			end if
			uid = getUserIdByOpenId(userId)
			If uid < 0 Then
				Call onSubscribe(userId)
				uid = getUserIdByOpenId(userId)
				If uid < 0 Then
					rs.close
					set rs = nothing
					Exit Sub
				end if
			end if
			Rs.addnew
			rs("sendOrReceive") = 1
			rs("accId") = accId
			rs("userId") = uid
			rs("CreateTime") = CreateTime
			rs("MsgType") = MsgType
			If Len(Content) > 0 Then rs("Content") = Left(Content,1024)
			If Len(PicUrl) > 0 Then
				PicUrl = saveRemoteFile(PicUrl)
				rs("PicUrl") = PicUrl
			end if
			If Len(MediaId) > 0 Then
				rs("MediaId") = MediaId
				rs("MediaPath") = saveRemoteFile(GET_MEDIA_DATA_URL & "access_token=" & Access_token & "&media_id=" & MediaId)
			end if
			If Len(Format) > 0 Then rs("Format") = Format
			If Len(Recognition) > 0 Then rs("Recognition") = Recognition
			If Len(ThumbMediaId) > 0 Then
				ThumbMediaId = saveRemoteFile(GET_MEDIA_DATA_URL & "access_token=" & Access_token & "&media_id=" & ThumbMediaId)
				rs("ThumbMediaId") = ThumbMediaId
			end if
			If Len(Location_X) > 0 Then rs("Location_X") = Location_X
			If Len(Location_Y) > 0 Then rs("Location_Y") = Location_Y
			If Len(Scale) > 0 Then rs("Scale") = Scale
			If Len(Label) > 0 Then rs("Label") = Label
			If Len(Title) > 0 Then rs("Title") = Title
			If Len(Description) > 0 Then rs("Description") = Description
			If Len(Url) > 0 Then rs("Url") = Url
			rs("MsgId") = MsgId
			If Len(cateid) > 0 Then rs("cateid") = cateid
			rs.update
			rs.close
			set rs = nothing
		end sub
		Public Sub saveTextMessage(userId,CreateTime,Content,MsgId)
			Call saveMessage(accId,userId,CreateTime,"text",Content,"","","","","","","","","","","","",MsgId,"")
		end sub
		Public Sub saveImageMessage(userId,CreateTime,PicUrl,MsgId)
			Call saveMessage(accId,userId,CreateTime,"image","",PicUrl,"","","","","","","","","","","",MsgId,"")
		end sub
		Public Sub saveVoiceMessage(userId,CreateTime,MediaId,Format,MsgId)
			Call saveMessage(accId,userId,CreateTime,"voice","","",MediaId,Format,"","","","","","","","","",MsgId,"")
		end sub
		Public Sub saveVideoMessage(userId,CreateTime,MediaId,ThumbMediaId,MsgId)
			Call saveMessage(accId,userId,CreateTime,"video","","",MediaId,"","",ThumbMediaId,"","","","","","","",MsgId,"")
		end sub
		Public Sub saveLocationMessage(userId,CreateTime,Location_X,Location_Y,Scale,Label,MsgId)
			Call saveMessage(accId,userId,CreateTime,"location","","","","","","",Location_X,Location_Y,Scale,Label,"","","",MsgId,"")
		end sub
		Public Sub saveLinkMessage(userId,CreateTime,Location_X,Location_Y,Scale,Label,MsgId)
			Call saveMessage(accId,userId,CreateTime,"link","","","","","","","","","","",Title,Description,Url,MsgId,"")
		end sub
		Function PostURL(url,PostStr)
			on error resume next
			Err.clear
			Dim XmlHttpControlName : XmlHttpControlName = Me.sdk.glAttribute("XmlHttpControlName")
			If XmlHttpControlName = "" Then XmlHttpControlName = "Msxml2.XMLHTTP"
			Dim Retrieval : Set Retrieval = Server.CreateObject(XmlHttpControlName)'Msxml2.ServerXMLHTTP")
			With Retrieval
			.Open "POST", url, false ,"" ,""
			.setRequestHeader "Content-Type","application/x-www-form-urlencoded"
			.Open "POST", url, false ,"" ,""
			.Send(PostStr)
			PostURL = .responsetext
			End With
			If Abs(Err.number) <> 0 Then
				appLog.addLog Err.description
				Err.clear
				XmlHttpControlName = IIF(XmlHttpControlName="Msxml2.XMLHTTP","Msxml2.ServerXMLHTTP","Msxml2.XMLHTTP")
				Set Retrieval = Server.CreateObject(XmlHttpControlName)
				With Retrieval
				.Open "POST", url, false ,"" ,""
				.setRequestHeader "Content-Type","application/x-www-form-urlencoded"
				.Open "POST", url, false ,"" ,""
				.Send(PostStr)
				PostURL = .responsetext
				End With
				If Abs(Err.number) <> 0 Then
					appLog.addLog Err.description
					Response.write "{success:false,msg:'连接微信服务器失败，请检查服务器网络环境，如有疑问，请联系智邦国际'}"
					Response.end
				end if
			end if
			Me.sdk.glAttribute("XmlHttpControlName") = XmlHttpControlName
			Set Retrieval = Nothing
			On Error GoTo 0
		end function
		Function GetURL(url)
			on error resume next
			Err.clear
			Dim XmlHttpControlName : XmlHttpControlName = Me.sdk.glAttribute("XmlHttpControlName")
			If XmlHttpControlName = "" Then XmlHttpControlName = "Msxml2.XMLHTTP"
			dim http : set http=server.createobject(XmlHttpControlName)
			http.open "get",url,false
			http.setRequestHeader "If-Modified-Since","0"
			http.open "get",url,false
			http.send()
			If Abs(Err.number) <> 0 Then
				appLog.addLog Err.description
				Err.clear
				XmlHttpControlName = IIF(XmlHttpControlName="Msxml2.XMLHTTP","Msxml2.ServerXMLHTTP","Msxml2.XMLHTTP")
				set http=server.createobject(XmlHttpControlName)
				http.open "get",url,false
				http.setRequestHeader "If-Modified-Since","0"
				http.open "get",url,false
				http.send()
				If Abs(Err.number) <> 0 Then
					Response.write "{success:false,msg:'连接微信服务器失败，请检查服务器网络环境，如有疑问，请联系智邦国际'}"
					appLog.addLog Err.description
					Response.end
				end if
			end if
			Me.sdk.glAttribute("XmlHttpControlName") = XmlHttpControlName
			GetURL = http.responsetext
			set http=Nothing
			On Error GoTo 0
		end function
		Private Sub InitScriptControl
			If Not isEmpty(sc4Json) Then Exit Sub
			Set sc4Json = Server.CreateObject("MSScriptControl.ScriptControl")
			sc4Json.Language = "JavaScript"
			sc4Json.AddCode "var itemTemp=null;function getJSArray(arr, index){itemTemp=arr[index];}"
		end sub
		Private Function getJSONObject(strJSON)
			sc4Json.AddCode "var jsonObject = " & strJSON
			Set getJSONObject = sc4Json.CodeObject.jsonObject
		end function
		Private Sub getJSArrayItem(objDest,objJSArray,index)
			on error resume next
			sc4Json.Run "getJSArray",objJSArray, index
			Set objDest = sc4Json.CodeObject.itemTemp
			If Err.number=0 Then Exit Sub
			objDest = sc4Json.CodeObject.itemTemp
		end sub
		Dim scriptCtrl
		Function parseJSON(str)
			If Not IsObject(scriptCtrl) Then
				Set scriptCtrl = Server.CreateObject("MSScriptControl.ScriptControl")
				scriptCtrl.Language = "JavaScript"
				scriptCtrl.AddCode "function ActiveXObject() {}"
				scriptCtrl.AddCode "function GetObject() {}"
				scriptCtrl.AddCode "Array.prototype.get = function(x) { return this[x]; }; var result = null;"
			end if
			on error resume next
			scriptCtrl.ExecuteStatement "var result = " & str & ";"
			Set parseJSON = scriptCtrl.CodeObject.result
			If Err Then
				Err.Clear
				Set parseJSON = Nothing
			end if
		end function
		Public Function getCert(ByVal certName,ByRef errmsg)
			on error resume next
			Dim store
			Set store = server.createobject("CAPICOM.Store")
			If Abs(Err.number) <> 0 Then
				errmsg = "组件创建失败，请检查是否正确安装证书组件"
				Set getCert = Nothing
				Exit Function
			end if
			On Error GoTo 0
			store.open 2,"MY",0
			Dim cnt : cnt = store.Certificates.count
			If cnt = 0 Then
				errmsg = "没有正确安装证书，请检查证书是否安装到“个人”下"
				Set getCert = Nothing
				Set store = Nothing
				Exit Function
			end if
			Dim i,cert
			For i = 1 To cnt
				If InStr(1,store.Certificates(i).SubjectName,certName,1) > 0 Then
					Set getCert = store.Certificates(i)
					errmsg = ""
					Set store = Nothing
					Exit Function
				end if
			next
			errmsg = "没有匹配到证书，请检查证书名称是否正确填写"
			Set store = Nothing
			Set getCert = Nothing
		end function
		Public Function getCertSerialNumber(ByVal certName)
			Dim cert,errmsg
			Set cert = getCert(certName,errmsg)
			If errmsg <> "" Then
				getSha1ByCert = errmsg
				Exit Function
			end if
			getCertSerialNumber = cert.SerialNumber
		end function
		Public Function getSha1ByCert(ByVal certName,ByVal content)
			Dim cert,errmsg
			Set cert = getCert(certName,errmsg)
			If errmsg <> "" Then
				getSha1ByCert = errmsg
				Exit Function
			end if
			Dim signer : Set signer = server.createobject("CAPICOM.Signer")
			Dim signedData : Set signedData = server.createobject("CAPICOM.SignedData")
			signer.Certificate = cert
			signedData.Content = content
			getSha1ByCert = signedData.Sign(signer,false,CAPICOM_HASH_ALGORITHM_SHA1)
		end function
		Function utf8md5(ByVal str)
			Dim md5Ctl
			Set md5Ctl = Server.CreateObject("MSScriptControl.ScriptControl")
			md5Ctl.Language = "JavaScript"
			md5Ctl.AddCode "" & vbcrlf &_
			"function md5(string) {   " & vbcrlf &_
			"    var x = Array();   " & vbcrlf &_
			"    var k, AA, BB, CC, DD, a, b, c, d;   " & vbcrlf &_
			"    var S11 = 7, S12 = 12, S13 = 17, S14 = 22;   " & vbcrlf &_
			"    var S21 = 5, S22 = 9, S23 = 14, S24 = 20;   " & vbcrlf &_
			"    var S31 = 4, S32 = 11, S33 = 16, S34 = 23;   " & vbcrlf &_
			"    var S41 = 6, S42 = 10, S43 = 15, S44 = 21;   " & vbcrlf &_
			"    string = Utf8Encode(string);   " & vbcrlf &_
			"    x = ConvertToWordArray(string);   " & vbcrlf &_
			"    a = 0x67452301;   " & vbcrlf &_
			"    b = 0xEFCDAB89;   " & vbcrlf &_
			"    c = 0x98BADCFE;   " & vbcrlf &_
			"    d = 0x10325476;   " & vbcrlf &_
			"    for (k=0; k<x.length; k += 16) {   " & vbcrlf &_
			"    d = 0x10325476;   " & vbcrlf &_
			"        AA = a;   " & vbcrlf &_
			"        BB = b;   " & vbcrlf &_
			"        CC = c;   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = FF(a, b, c, d, x[k+0], S11, 0xD76AA478);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = FF(d, a, b, c, x[k+1], S12, 0xE8C7B756);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = FF(c, d, a, b, x[k+2], S13, 0x242070DB);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = FF(b, c, d, a, x[k+3], S14, 0xC1BDCEEE);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = FF(a, b, c, d, x[k+4], S11, 0xF57C0FAF);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = FF(d, a, b, c, x[k+5], S12, 0x4787C62A);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = FF(c, d, a, b, x[k+6], S13, 0xA8304613);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = FF(b, c, d, a, x[k+7], S14, 0xFD469501);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = FF(a, b, c, d, x[k+8], S11, 0x698098D8);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = FF(d, a, b, c, x[k+9], S12, 0x8B44F7AF);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = FF(c, d, a, b, x[k+10], S13, 0xFFFF5BB1);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = FF(b, c, d, a, x[k+11], S14, 0x895CD7BE);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = FF(a, b, c, d, x[k+12], S11, 0x6B901122);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = FF(d, a, b, c, x[k+13], S12, 0xFD987193);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = FF(c, d, a, b, x[k+14], S13, 0xA679438E);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = FF(b, c, d, a, x[k+15], S14, 0x49B40821);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = GG(a, b, c, d, x[k+1], S21, 0xF61E2562);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = GG(d, a, b, c, x[k+6], S22, 0xC040B340);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = GG(c, d, a, b, x[k+11], S23, 0x265E5A51);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = GG(b, c, d, a, x[k+0], S24, 0xE9B6C7AA);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = GG(a, b, c, d, x[k+5], S21, 0xD62F105D);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = GG(d, a, b, c, x[k+10], S22, 0x2441453);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = GG(c, d, a, b, x[k+15], S23, 0xD8A1E681);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = GG(b, c, d, a, x[k+4], S24, 0xE7D3FBC8);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = GG(a, b, c, d, x[k+9], S21, 0x21E1CDE6);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = GG(d, a, b, c, x[k+14], S22, 0xC33707D6);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = GG(c, d, a, b, x[k+3], S23, 0xF4D50D87);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = GG(b, c, d, a, x[k+8], S24, 0x455A14ED);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = GG(a, b, c, d, x[k+13], S21, 0xA9E3E905);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = GG(d, a, b, c, x[k+2], S22, 0xFCEFA3F8);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = GG(c, d, a, b, x[k+7], S23, 0x676F02D9);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = GG(b, c, d, a, x[k+12], S24, 0x8D2A4C8A);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = HH(a, b, c, d, x[k+5], S31, 0xFFFA3942);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = HH(d, a, b, c, x[k+8], S32, 0x8771F681);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = HH(c, d, a, b, x[k+11], S33, 0x6D9D6122);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = HH(b, c, d, a, x[k+14], S34, 0xFDE5380C);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = HH(a, b, c, d, x[k+1], S31, 0xA4BEEA44);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = HH(d, a, b, c, x[k+4], S32, 0x4BDECFA9);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = HH(c, d, a, b, x[k+7], S33, 0xF6BB4B60);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = HH(b, c, d, a, x[k+10], S34, 0xBEBFBC70);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = HH(a, b, c, d, x[k+13], S31, 0x289B7EC6);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = HH(d, a, b, c, x[k+0], S32, 0xEAA127FA);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = HH(c, d, a, b, x[k+3], S33, 0xD4EF3085);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = HH(b, c, d, a, x[k+6], S34, 0x4881D05);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = HH(a, b, c, d, x[k+9], S31, 0xD9D4D039);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = HH(d, a, b, c, x[k+12], S32, 0xE6DB99E5);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = HH(c, d, a, b, x[k+15], S33, 0x1FA27CF8);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = HH(b, c, d, a, x[k+2], S34, 0xC4AC5665);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = II(a, b, c, d, x[k+0], S41, 0xF4292244);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = II(d, a, b, c, x[k+7], S42, 0x432AFF97);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = II(c, d, a, b, x[k+14], S43, 0xAB9423A7);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = II(b, c, d, a, x[k+5], S44, 0xFC93A039);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = II(a, b, c, d, x[k+12], S41, 0x655B59C3);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = II(d, a, b, c, x[k+3], S42, 0x8F0CCC92);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = II(c, d, a, b, x[k+10], S43, 0xFFEFF47D);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = II(b, c, d, a, x[k+1], S44, 0x85845DD1);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = II(a, b, c, d, x[k+8], S41, 0x6FA87E4F);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = II(d, a, b, c, x[k+15], S42, 0xFE2CE6E0);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = II(c, d, a, b, x[k+6], S43, 0xA3014314);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = II(b, c, d, a, x[k+13], S44, 0x4E0811A1);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = II(a, b, c, d, x[k+4], S41, 0xF7537E82);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        d = II(d, a, b, c, x[k+11], S42, 0xBD3AF235);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        c = II(c, d, a, b, x[k+2], S43, 0x2AD7D2BB);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        b = II(b, c, d, a, x[k+9], S44, 0xEB86D391);   " & vbcrlf &_
			"        DD = d;   " & vbcrlf &_
			"        a = AddUnsigned(a, AA);   " & vbcrlf &_
			"        b = AddUnsigned(b, BB);   " & vbcrlf &_
			"        c = AddUnsigned(c, CC);   " & vbcrlf &_
			"        d = AddUnsigned(d, DD);   " & vbcrlf &_
			"    }   " & vbcrlf &_
			"    var temp = WordToHex(a)+WordToHex(b)+WordToHex(c)+WordToHex(d);   " & vbcrlf &_
			"    }   " & vbcrlf &_
			"    return temp.toUpperCase();   " & vbcrlf &_
			"}   " & vbcrlf &_
			"function RotateLeft(lValue, iShiftBits) {   " & vbcrlf &_
			"    return (lValue << iShiftBits) | (lValue >>> (32-iShiftBits));   " & vbcrlf &_
			"function RotateLeft(lValue, iShiftBits) {   " & vbcrlf &_
			"}   " & vbcrlf &_
			"function AddUnsigned(lX, lY) {   " & vbcrlf &_
			"    var lX4, lY4, lX8, lY8, lResult;   " & vbcrlf &_
			"    lX8 = (lX & 0x80000000);   " & vbcrlf &_
			"    lY8 = (lY & 0x80000000);   " & vbcrlf &_
			"    lX4 = (lX & 0x40000000);   " & vbcrlf &_
			"    lY4 = (lY & 0x40000000);   " & vbcrlf &_
			"    lResult = (lX & 0x3FFFFFFF)+(lY & 0x3FFFFFFF);   " & vbcrlf &_
			"    lY4 = (lY & 0x40000000);   " & vbcrlf &_
			"    if (lX4 & lY4) {   " & vbcrlf &_
			"        return (lResult ^ 0x80000000 ^ lX8 ^ lY8);   " & vbcrlf &_
			"    }   " & vbcrlf &_
			"    if (lX4 | lY4) {   " & vbcrlf &_
			"        if (lResult & 0x40000000) {   " & vbcrlf &_
			"            return (lResult ^ 0xC0000000 ^ lX8 ^ lY8);   " & vbcrlf &_
			"        } else {   " & vbcrlf &_
			"            return (lResult ^ 0x40000000 ^ lX8 ^ lY8);   " & vbcrlf &_
			"        }   " & vbcrlf &_
			"    } else {   " & vbcrlf &_
			"        return (lResult ^ lX8 ^ lY8);   " & vbcrlf &_
			"    }   " & vbcrlf &_
			"}   " & vbcrlf &_
			"function F(x, y, z) {   " & vbcrlf &_
			"    return (x & y) | ((~x) & z);   " & vbcrlf &_
			"}   " & vbcrlf &_
			"function G(x, y, z) {   " & vbcrlf &_
			"    return (x & z) | (y & (~z));   " & vbcrlf &_
			"}   " & vbcrlf &_
			"function H(x, y, z) {   " & vbcrlf &_
			"    return (x ^ y ^ z);   " & vbcrlf &_
			"}   " & vbcrlf &_
			"function I(x, y, z) {   " & vbcrlf &_
			"    return (y ^ (x | (~z)));   " & vbcrlf &_
			"}   " & vbcrlf &_
			"function FF(a, b, c, d, x, s, ac) {   " & vbcrlf &_
			" a = AddUnsigned(a, AddUnsigned(AddUnsigned(F(b, c, d), x), ac));"    & vbcrlf &_
			"    return AddUnsigned(RotateLeft(a, s), b);   " & vbcrlf &_
			"}   " & vbcrlf &_
			"function GG(a, b, c, d, x, s, ac) {   " & vbcrlf &_
			"    a = AddUnsigned(a, AddUnsigned(AddUnsigned(G(b, c, d), x), ac));   " & vbcrlf &_
			"    return AddUnsigned(RotateLeft(a, s), b);   " & vbcrlf &_
			"}   " & vbcrlf &_
			"function HH(a, b, c, d, x, s, ac) {   " & vbcrlf &_
			"    a = AddUnsigned(a, AddUnsigned(AddUnsigned(H(b, c, d), x), ac));   " & vbcrlf &_
			"    return AddUnsigned(RotateLeft(a, s), b);   " & vbcrlf &_
			"}   " & vbcrlf &_
			"function II(a, b, c, d, x, s, ac) {   " & vbcrlf &_
			"    a = AddUnsigned(a, AddUnsigned(AddUnsigned(I(b, c, d), x), ac));   " & vbcrlf &_
			"    return AddUnsigned(RotateLeft(a, s), b);   " & vbcrlf &_
			"}   " & vbcrlf &_
			"function ConvertToWordArray(string) {   " & vbcrlf &_
			"    var lWordCount;   " & vbcrlf &_
			"    var lMessageLength = string.length;   " & vbcrlf &_
			"    var lNumberOfWords_temp1 = lMessageLength+8;   " & vbcrlf &_
			"    var lMessageLength = string.length;   " & vbcrlf &_
			"    var lNumberOfWords_temp2 = (lNumberOfWords_temp1-(lNumberOfWords_temp1%64))/64;   " & vbcrlf &_
			"    var lMessageLength = string.length;   " & vbcrlf &_
			"    var lNumberOfWords = (lNumberOfWords_temp2+1)*16;   " & vbcrlf &_
			"    var lMessageLength = string.length;   " & vbcrlf &_
			"    var lWordArray = Array(lNumberOfWords-1);   " & vbcrlf &_
			"    var lMessageLength = string.length;   " & vbcrlf &_
			"    var lBytePosition = 0;   " & vbcrlf &_
			"    var lByteCount = 0;   " & vbcrlf &_
			"    while (lByteCount<lMessageLength) {   " & vbcrlf &_
			"        lWordCount = (lByteCount-(lByteCount%4))/4;   " & vbcrlf &_
			"    while (lByteCount<lMessageLength) {   " & vbcrlf &_
			"        lBytePosition = (lByteCount%4)*8;   " & vbcrlf &_
			"        lWordArray[lWordCount] = (lWordArray[lWordCount] | (string.charCodeAt(lByteCount) << lBytePosition));   " & vbcrlf &_
			"        lByteCount++;   " & vbcrlf &_
			"    }   " & vbcrlf &_
			"    lWordCount = (lByteCount-(lByteCount%4))/4;   " & vbcrlf &_
			"    }   " & vbcrlf &_
			"    lBytePosition = (lByteCount%4)*8;   " & vbcrlf &_
			"    lWordArray[lWordCount] = lWordArray[lWordCount] | (0x80 << lBytePosition);   " & vbcrlf &_
			"    lWordArray[lNumberOfWords-2] = lMessageLength << 3;   " & vbcrlf &_
			"    lWordArray[lWordCount] = lWordArray[lWordCount] | (0x80 << lBytePosition);   " & vbcrlf &_
			"    lWordArray[lNumberOfWords-1] = lMessageLength >>> 29;   " & vbcrlf &_
			"    lWordArray[lWordCount] = lWordArray[lWordCount] | (0x80 << lBytePosition);   " & vbcrlf &_
			"    return lWordArray;   " & vbcrlf &_
			"}   " & vbcrlf &_
			"function WordToHex(lValue) {   " & vbcrlf &_
			"    var WordToHexValue = '', WordToHexValue_temp = '', lByte, lCount;   " & vbcrlf &_
			"    for (lCount=0; lCount<=3; lCount++) {   " & vbcrlf &_
			"    var WordToHexValue = '', WordToHexValue_temp = '', lByte, lCount;   " & vbcrlf &_
			"        lByte = (lValue >>> (lCount*8)) & 255;   " & vbcrlf &_
			"        WordToHexValue_temp = '0'+lByte.toString(16);   " & vbcrlf &_
			"        lByte = (lValue >>> (lCount*8)) & 255;   " & vbcrlf &_
			"        WordToHexValue = WordToHexValue+WordToHexValue_temp.substr(WordToHexValue_temp.length-2, 2);   " & vbcrlf &_
			"        lByte = (lValue >>> (lCount*8)) & 255;   " & vbcrlf &_
			"    }   " & vbcrlf &_
			"    return WordToHexValue;   " & vbcrlf &_
			"}   " & vbcrlf &_
			"function Utf8Encode(string) {   " & vbcrlf &_
			"    var utftext = '';   " & vbcrlf &_
			"    for (var n = 0; n<string.length; n++) {   " & vbcrlf &_
			"    var utftext = '';   " & vbcrlf &_
			"        var c = string.charCodeAt(n);   " & vbcrlf &_
			"        if (c<128) {   " & vbcrlf &_
			"            utftext += String.fromCharCode(c);   " & vbcrlf &_
			"        if (c<128) {   " & vbcrlf &_
			"        } else if ((c>127) && (c<2048)) {   " & vbcrlf &_
			"            utftext += String.fromCharCode((c >> 6) | 192);   " & vbcrlf &_
			"        } else if ((c>127) && (c<2048)) {   " & vbcrlf &_
			"            utftext += String.fromCharCode((c & 63) | 128);   " & vbcrlf &_
			"        } else if ((c>127) && (c<2048)) {   " & vbcrlf &_
			"        } else {   " & vbcrlf &_
			"            utftext += String.fromCharCode((c >> 12) | 224);   " & vbcrlf &_
			"        } else {   " & vbcrlf &_
			"            utftext += String.fromCharCode(((c >> 6) & 63) | 128);   " & vbcrlf &_
			"        } else {   " & vbcrlf &_
			"            utftext += String.fromCharCode((c & 63) | 128);   " & vbcrlf &_
			"        } else {   " & vbcrlf &_
			"        }   " & vbcrlf &_
			"    }   " & vbcrlf &_
			"    return utftext;   " & vbcrlf &_
			"}"
			on error resume next
			utf8md5 = md5Ctl.eval("md5('" & str & "')")
			If Err Then
				Err.Clear
				utf8md5 = ""
			end if
			Set md5Ctl = Nothing
		end function
		Public Function Utf8CharHtmlConvert(ByVal data)
			Dim S, ret
			ret = ""
			If data&""<>"" Then
				Dim i , w
				Dim C : C = Len(data)
				ReDim S(C - 1)
'Dim C : C = Len(data)
				For i = 0 To C - 1
'Dim C : C = Len(data)
					S(i) = Mid(data, i + 1, 1)
'Dim C : C = Len(data)
					w = AscW(S(i))
					If w < 125 Then
					else
						S(i) = "&#" & w & ";"
					end if
				next
				ret = Join(S, "")
			end if
			Utf8CharHtmlConvert = ret
		end function
		Public Function enHtml(byval t0)
			if isnull(t0) then enhtml="":exit function
			if t0="<p>&nbsp;</p>" then enhtml="":exit function
			t0=replace(t0,"&","&amp;")
			t0=replace(t0,"'","&#39;")
			t0=replace(t0,"""","&#34;")
			t0=replace(t0,"<","&lt;")
			t0=replace(t0,">","&gt;")
			set reg=new regexp
			reg.ignorecase=true
			reg.global=true
			reg.pattern="(w)(here)"
			t0=reg.replace(t0,"$1h&#101;re")
			reg.pattern="(s)(elect)"
			t0=reg.replace(t0,"$1el&#101;ct")
			reg.pattern="(i)(nsert)"
			t0=reg.replace(t0,"$1ns&#101;rt")
			reg.pattern="(c)(reate)"
			t0=reg.replace(t0,"$1r&#101;ate")
			reg.pattern="(d)(rop)"
			t0=reg.replace(t0,"$1ro&#112;")
			reg.pattern="(a)(lter)"
			t0=reg.replace(t0,"$1lt&#101;r")
			reg.pattern="(d)(elete)"
			t0=reg.replace(t0,"$1el&#101;te")
			reg.pattern="(u)(pdate)"
			t0=reg.replace(t0,"$1p&#100;ate")
			reg.pattern="(\s)(or)"
			t0=reg.replace(t0,"$1o&#114;")
			reg.pattern="(java)(script)"
			t0=reg.replace(t0,"$1scri&#112;t")
			reg.pattern="(j)(script)"
			t0=reg.replace(t0,"$1scri&#112;t")
			reg.pattern="(vb)(script)"
			t0=reg.replace(t0,"$1scri&#112;t")
			if instr(t0,"expression")<>0 then
				t0=replace(t0,"expression","e&#173;xpression",1,-1,0)
'if instr(t0,"expression")<>0 then
			end if
			enhtml=t0
		end function
		Public Function dehtml(ByVal t0)
			if isnull(t0) Then
				dehtml=""
				Exit Function
				End  If
				t0=replace(t0,"&amp;","&")
				t0=replace(t0,"&#39;","'")
				t0=replace(t0,"&#34;","""")
				t0=replace(t0,"&lt;","<")
				t0=replace(t0,"&gt;",">")
				t0=replace(t0,chr(10),vbcrlf)
				dehtml=t0
			end function
		Public function errMessage(byval t0)
			if isnull(t0) then
				errMessage = ""
				exit function
			end if
			dim t1
			select case t0
			case "-1" :       t1 = "系统繁忙，此时请开发者稍候再试"
'select case t0
			case "0" :        t1 = "请求成功"
			case "40001" :    t1 = "获取access_token时AppSecret错误，或者access_token无效。请开发者认真比对AppSecret的正确性，或查看是否正在为恰当的公众号调用接口"
			case "40002" :    t1 = "不合法的凭证类型"
			case "40003" :    t1 = "不合法的OpenID，请开发者确认OpenID（该用户）是否已关注公众号，或是否是其他公众号的OpenID"
			case "40004" :    t1 = "不合法的媒体文件类型"
			case "40005" :    t1 = "不合法的文件类型"
			case "40006" :    t1 = "不合法的文件大小"
			case "40007" :    t1 = "不合法的媒体文件id"
			case "40008" :    t1 = "不合法的消息类型"
			case "40009" :    t1 = "不合法的图片文件大小"
			case "40010" :    t1 = "不合法的语音文件大小"
			case "40011" :    t1 = "不合法的视频文件大小"
			case "40012" :    t1 = "不合法的缩略图文件大小"
			case "40013" :    t1 = "不合法的AppID，请开发者检查AppID的正确性，避免异常字符，注意大小写"
			case "40014" :    t1 = "不合法的access_token，请开发者认真比对access_token的有效性（如是否过期），或查看是否正在为恰当的公众号调用接口"
			case "40015" :    t1 = "不合法的菜单类型"
			case "40016" :    t1 = "不合法的按钮个数"
			case "40017" :    t1 = "不合法的按钮个数"
			case "40018" :    t1 = "不合法的按钮名字长度"
			case "40019" :    t1 = "不合法的按钮KEY长度"
			case "40020" :    t1 = "不合法的按钮URL长度"
			case "40021" :    t1 = "不合法的菜单版本号"
			case "40022" :    t1 = "不合法的子菜单级数"
			case "40023" :    t1 = "不合法的子菜单按钮个数"
			case "40024" :    t1 = "不合法的子菜单按钮类型"
			case "40025" :    t1 = "不合法的子菜单按钮名字长度"
			case "40026" :    t1 = "不合法的子菜单按钮KEY长度"
			case "40027" :    t1 = "不合法的子菜单按钮URL长度"
			case "40028" :    t1 = "不合法的自定义菜单使用用户"
			case "40029" :    t1 = "不合法的oauth_code"
			case "40030" :    t1 = "不合法的refresh_token"
			case "40031" :    t1 = "不合法的openid列表"
			case "40032" :    t1 = "不合法的openid列表长度"
			case "40033" :    t1 = "不合法的请求字符，不能包含\uxxxx格式的字符"
			case "40035" :    t1 = "不合法的参数"
			case "40038" :    t1 = "不合法的请求格式"
			case "40039" :    t1 = "不合法的URL长度"
			case "40050" :    t1 = "不合法的分组id"
			case "40051" :    t1 = "分组名字不合法"
			case "40117" :    t1 = "分组名字不合法"
			case "40118" :    t1 = "media_id大小不合法"
			case "40119" :    t1 = "button类型错误"
			case "40120" :    t1 = "button类型错误"
			case "40121" :    t1 = "不合法的media_id类型"
			case "40132" :    t1 = "微信号不合法"
			case "40137" :    t1 = "不支持的图片格式"
			case "41001" :    t1 = "缺少access_token参数"
			case "41002" :    t1 = "缺少appid参数"
			case "41003" :    t1 = "缺少refresh_token参数"
			case "41004" :    t1 = "缺少secret参数"
			case "41005" :    t1 = "缺少多媒体文件数据"
			case "41006" :    t1 = "缺少media_id参数"
			case "41007" :    t1 = "缺少子菜单数据"
			case "41008" :    t1 = "缺少oauth code"
			case "41009" :    t1 = "缺少openid"
			case "42001" :    t1 = "access_token超时，请检查access_token的有效期，请参考基础支持-获取access_token中，对access_token的详细机制说明"
			case "41009" :    t1 = "缺少openid"
			case "42002" :    t1 = "refresh_token超时"
			case "42003" :    t1 = "oauth_code超时"
			case "42007" :    t1 = "用户修改微信密码，accesstoken和refreshtoken失效，需要重新授权"
			case "43001" :    t1 = "需要GET请求"
			case "43002" :    t1 = "需要POST请求"
			case "43003" :    t1 = "需要HTTPS请求"
			case "43004" :    t1 = "需要接收者关注"
			case "43005" :    t1 = "需要好友关系"
			case "44001" :    t1 = "多媒体文件为空"
			case "44002" :    t1 = "POST的数据包为空"
			case "44003" :    t1 = "图文消息内容为空"
			case "44004" :    t1 = "文本消息内容为空"
			case "45001" :    t1 = "多媒体文件大小超过限制"
			case "45002" :    t1 = "消息内容超过限制"
			case "45003" :    t1 = "标题字段超过限制"
			case "45004" :    t1 = "描述字段超过限制"
			case "45005" :    t1 = "链接字段超过限制"
			case "45006" :    t1 = "图片链接字段超过限制"
			case "45007" :    t1 = "语音播放时间超过限制"
			case "45008" :    t1 = "图文消息超过限制"
			case "45009" :    t1 = "接口调用超过限制"
			case "45010" :    t1 = "创建菜单个数超过限制"
			case "45015" :    t1 = "回复时间超过限制"
			case "45016" :    t1 = "系统分组，不允许修改"
			case "45017" :    t1 = "分组名字过长"
			case "45018" :    t1 = "分组数量超过上限"
			case "45047" :    t1 = "客服接口下行条数超过上限"
			case "46001" :    t1 = "不存在媒体数据"
			case "46002" :    t1 = "不存在的菜单版本"
			case "46003" :    t1 = "不存在的菜单数据"
			case "46004" :    t1 = "不存在的用户"
			case "47001" :    t1 = "解析JSON/XML内容错误"
			case "48001" :    t1 = "api功能未授权，请确认公众号已获得该接口，可以在公众平台官网-开发者中心页中查看接口权限"
			case "47001" :    t1 = "解析JSON/XML内容错误"
			case "48004" :    t1 = "api接口被封禁，请登录mp.weixin.qq.com查看详情"
			case "50001" :    t1 = "用户未授权该api"
			case "50002" :    t1 = "用户受限，可能是违规后接口被封禁"
			case "61451" :    t1 = "参数错误(invalid parameter)"
			case "61452" :    t1 = "无效客服账号(invalid kf_account)"
			case "61453" :    t1 = "客服帐号已存在(kf_account exsited)"
			case "61454" :    t1 = "客服帐号名长度超过限制(仅允许10个英文字符，不包括@及@后的公众号的微信号)(invalid kf_acount length)"
			case "61455" :    t1 = "客服帐号名包含非法字符(仅允许英文+数字)(illegal character in kf_account)"
			case "61454" :    t1 = "客服帐号名长度超过限制(仅允许10个英文字符，不包括@及@后的公众号的微信号)(invalid kf_acount length)"
			case "61456" :    t1 = "客服帐号个数超过限制(10个客服账号)(kf_account count exceeded)"
			case "61457" :    t1 = "无效头像文件类型(invalid file type)"
			case "61450" :    t1 = "系统错误(system error)"
			case "61500" :    t1 = "日期格式错误"
			case "65301" :    t1 = "不存在此menuid对应的个性化菜单"
			case "65302" :    t1 = "没有相应的用户"
			case "65303" :    t1 = "没有默认菜单，不能创建个性化菜单"
			case "65304" :    t1 = "MatchRule信息为空"
			case "65305" :    t1 = "个性化菜单数量受限"
			case "65306" :    t1 = "不支持个性化菜单的帐号"
			case "65307" :    t1 = "个性化菜单信息为空"
			case "65308" :    t1 = "包含没有响应类型的button"
			case "65309" :    t1 = "个性化菜单开关处于关闭状态"
			case "65310" :    t1 = "填写了省份或城市信息，国家信息不能为空"
			case "65311" :    t1 = "填写了城市信息，省份信息不能为空"
			case "65312" :    t1 = "不合法的国家信息"
			case "65313" :    t1 = "不合法的省份信息"
			case "65314" :    t1 = "不合法的城市信息"
			case "65316" :    t1 = "该公众号的菜单设置了过多的域名外跳（最多跳转到3个域名的链接）"
			case "65317" :    t1 = "不合法的URL"
			case "9001001" :  t1 = "POST数据参数不合法"
			case "9001002" :  t1 = "远端服务不可用"
			case "9001003" :  t1 = "Ticket不合法"
			case "9001004" :  t1 = "获取摇周边用户信息失败"
			case "9001005" :  t1 = "获取商户信息失败"
			case "9001006" :  t1 = "获取OpenID失败"
			case "9001007" :  t1 = "上传文件缺失"
			case "9001008" :  t1 = "上传素材的文件类型不合法"
			case "9001009" :  t1 = "上传素材的文件尺寸不合法"
			case "9001010" :  t1 = "上传失败"
			case "9001020" :  t1 = "帐号不合法"
			case "9001021" :  t1 = "已有设备激活率低于50%，不能新增设备"
			case "9001022" :  t1 = "设备申请数不合法，必须为大于0的数字"
			case "9001023" :  t1 = "已存在审核中的设备ID申请"
			case "9001024" :  t1 = "一次查询设备ID数量不能超过50"
			case "9001025" :  t1 = "设备ID不合法"
			case "9001026" :  t1 = "页面ID不合法"
			case "9001027" :  t1 = "页面参数不合法"
			case "9001028" :  t1 = "一次删除页面ID数量不能超过10"
			case "9001029" :  t1 = "页面已应用在设备中，请先解除应用关系再删除"
			case "9001030" :  t1 = "一次查询页面ID数量不能超过50"
			case "9001031" :  t1 = "时间区间不合法"
			case "9001032" :  t1 = "保存设备与页面的绑定关系参数错误"
			case "9001033" :  t1 = "门店ID不合法"
			case "9001034" :  t1 = "设备备注信息过长"
			case "9001035" :  t1 = "设备申请参数不合法"
			case "9001036" :  t1 = "查询起始值begin不合法"
			case else:          t1="未知错误："&t0
			end select
			errMessage = t1
		end function
		Private Function Sort(ary)
			Dim KeepChecking,I,FirstValue,SecondValue
			KeepChecking = TRUE
			Do Until KeepChecking = FALSE
				KeepChecking = FALSE
				For I = 0 to UBound(ary)
					If I = UBound(ary) Then Exit For
					If ary(I) > ary(I+1) Then
'If I = UBound(ary) Then Exit For
						FirstValue = ary(I)
						SecondValue = ary(I+1)
						FirstValue = ary(I)
						ary(I) = SecondValue
						ary(I+1) = FirstValue
						ary(I) = SecondValue
						KeepChecking = TRUE
					end if
				next
			Loop
			Sort = ary
		end function
		Public Function checkSign(ByVal signature,ByVal nonce,ByVal timestamp,ByVal echostr)
			Dim chkString
			If echostr<>"" Then
				chkString = Join(Sort(Array(token,timestamp,nonce)),"")
				checkSign = signature = Lcase(base64.Sha1Encode(chkString))
			else
				checkSign = True
			end if
		end function
		Public Function nonceStr(intLength)
			Dim strSeed, seedLength, pos, Str, i
			strSeed = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
			seedLength = Len(strSeed)
			Str = ""
			Randomize
			For i = 1 To intLength
				Str = Str + Mid(strSeed, Int(seedLength * Rnd) + 1, 1)
'For i = 1 To intLength
			next
			nonceStr = Str
		end function
	End Class
	function FilterStr(strin)
		if isnull(strin) then
			FilterStr=""
		else
			FilterStr = Replace(Replace(Replace(replace(replace(replace(strin,"\","\\"),vbcrlf,"\n"),"'","\'"),vbcr,""),vblf,""),"""","\""")
		end if
	end function
	Function replaceFaces(byval t0)
		if t0 & "" = "" then
			replaceFaces="[未知表情]"
			exit function
		end if
		t0=replace(t0,"/::)","<img width=""24"" height=""24"" tag=""faces"" txt=""/::)"" src=""../MicroMsg/face/0.gif"">")
		t0=replace(t0,"/::~","<img width=""24"" height=""24"" tag=""faces"" txt=""/::~"" src=""../MicroMsg/face/1.gif"">")
		t0=replace(t0,"/::B","<img width=""24"" height=""24"" tag=""faces"" txt=""/::B"" src=""../MicroMsg/face/2.gif"">")
		t0=replace(t0,"/::|","<img width=""24"" height=""24"" tag=""faces"" txt=""/::|"" src=""../MicroMsg/face/3.gif"">")
		t0=replace(t0,"/:8-)","<img width=""24"" height=""24"" tag=""faces"" txt=""/:8-)"" src=""../MicroMsg/face/4.gif"">")
		t0=replace(t0,"/::<","<img width=""24"" height=""24"" tag=""faces"" txt=""/::<"" src=""../MicroMsg/face/5.gif"">")
		t0=replace(t0,"/::$","<img width=""24"" height=""24"" tag=""faces"" txt=""/::$"" src=""../MicroMsg/face/6.gif"">")
		t0=replace(t0,"/::X","<img width=""24"" height=""24"" tag=""faces"" txt=""/::X"" src=""../MicroMsg/face/7.gif"">")
		t0=replace(t0,"/::Z","<img width=""24"" height=""24"" tag=""faces"" txt=""/::Z"" src=""../MicroMsg/face/8.gif"">")
		t0=replace(t0,"/::'(","<img width=""24"" height=""24"" tag=""faces"" txt=""/::'("" src=""../MicroMsg/face/9.gif"">")
		t0=replace(t0,"/::-|","<img width=""24"" height=""24"" tag=""faces"" txt=""/::-|"" src=""../MicroMsg/face/10.gif"">")
		t0=replace(t0,"/::@","<img width=""24"" height=""24"" tag=""faces"" txt=""/::@"" src=""../MicroMsg/face/11.gif"">")
		t0=replace(t0,"/::P","<img width=""24"" height=""24"" tag=""faces"" txt=""/::P"" src=""../MicroMsg/face/12.gif"">")
		t0=replace(t0,"/::D","<img width=""24"" height=""24"" tag=""faces"" txt=""/::D"" src=""../MicroMsg/face/13.gif"">")
		t0=replace(t0,"/::O","<img width=""24"" height=""24"" tag=""faces"" txt=""/::O"" src=""../MicroMsg/face/14.gif"">")
		t0=replace(t0,"/::(","<img width=""24"" height=""24"" tag=""faces"" txt=""/::("" src=""../MicroMsg/face/15.gif"">")
		t0=replace(t0,"/::+","<img width=""24"" height=""24"" tag=""faces"" txt=""/::+"" src=""../MicroMsg/face/16.gif"">")
		t0=replace(t0,"/:--b","<img width=""24"" height=""24"" tag=""faces"" txt=""/:–b"" src=""../MicroMsg/face/17.gif"">")
		t0=replace(t0,"/::Q","<img width=""24"" height=""24"" tag=""faces"" txt=""/::Q"" src=""../MicroMsg/face/18.gif"">")
		t0=replace(t0,"/::T","<img width=""24"" height=""24"" tag=""faces"" txt=""/::T"" src=""../MicroMsg/face/19.gif"">")
		t0=replace(t0,"/:,@P","<img width=""24"" height=""24"" tag=""faces"" txt=""/:,@P"" src=""../MicroMsg/face/20.gif"">")
		t0=replace(t0,"/:,@-D","<img width=""24"" height=""24"" tag=""faces"" txt=""/:,@-D"" src=""../MicroMsg/face/21.gif"">")
		t0=replace(t0,"/::d","<img width=""24"" height=""24"" tag=""faces"" txt=""/::d"" src=""../MicroMsg/face/22.gif"">")
		t0=replace(t0,"/:,@o","<img width=""24"" height=""24"" tag=""faces"" txt=""/:,@o"" src=""../MicroMsg/face/23.gif"">")
		t0=replace(t0,"/::g","<img width=""24"" height=""24"" tag=""faces"" txt=""/::g"" src=""../MicroMsg/face/24.gif"">")
		t0=replace(t0,"/:|-)","<img width=""24"" height=""24"" tag=""faces"" txt=""/:|-)"" src=""../MicroMsg/face/25.gif"">")
		t0=replace(t0,"/::!","<img width=""24"" height=""24"" tag=""faces"" txt=""/::!"" src=""../MicroMsg/face/26.gif"">")
		t0=replace(t0,"/::L","<img width=""24"" height=""24"" tag=""faces"" txt=""/::L"" src=""../MicroMsg/face/27.gif"">")
		t0=replace(t0,"/::>","<img width=""24"" height=""24"" tag=""faces"" txt=""/::>"" src=""../MicroMsg/face/28.gif"">")
		t0=replace(t0,"/::,@","<img width=""24"" height=""24"" tag=""faces"" txt=""/::,@"" src=""../MicroMsg/face/29.gif"">")
		t0=replace(t0,"/:,@f","<img width=""24"" height=""24"" tag=""faces"" txt=""/:,@f"" src=""../MicroMsg/face/30.gif"">")
		t0=replace(t0,"/::-S","<img width=""24"" height=""24"" tag=""faces"" txt=""/::-S"" src=""../MicroMsg/face/31.gif"">")
		t0=replace(t0,"/:?","<img width=""24"" height=""24"" tag=""faces"" txt=""/:?"" src=""../MicroMsg/face/32.gif"">")
		t0=replace(t0,"/:,@x","<img width=""24"" height=""24"" tag=""faces"" txt=""/:,@x"" src=""../MicroMsg/face/33.gif"">")
		t0=replace(t0,"/:,@@","<img width=""24"" height=""24"" tag=""faces"" txt=""/:,@@"" src=""../MicroMsg/face/34.gif"">")
		t0=replace(t0,"/::8","<img width=""24"" height=""24"" tag=""faces"" txt=""/::8"" src=""../MicroMsg/face/35.gif"">")
		t0=replace(t0,"/:,@!","<img width=""24"" height=""24"" tag=""faces"" txt=""/:,@!"" src=""../MicroMsg/face/36.gif"">")
		t0=replace(t0,"/:!!!","<img width=""24"" height=""24"" tag=""faces"" txt=""/:!!!"" src=""../MicroMsg/face/37.gif"">")
		t0=replace(t0,"/:xx","<img width=""24"" height=""24"" tag=""faces"" txt=""/:xx"" src=""../MicroMsg/face/38.gif"">")
		t0=replace(t0,"/:bye","<img width=""24"" height=""24"" tag=""faces"" txt=""/:bye"" src=""../MicroMsg/face/39.gif"">")
		t0=replace(t0,"/:wipe","<img width=""24"" height=""24"" tag=""faces"" txt=""/:wipe"" src=""../MicroMsg/face/40.gif"">")
		t0=replace(t0,"/:dig","<img width=""24"" height=""24"" tag=""faces"" txt=""/:dig"" src=""../MicroMsg/face/41.gif"">")
		t0=replace(t0,"/:handclap","<img width=""24"" height=""24"" tag=""faces"" txt=""/:handclap"" src=""../MicroMsg/face/42.gif"">")
		t0=replace(t0,"/:&-(","<img width=""24"" height=""24"" tag=""faces"" txt=""/:&-("" src=""../MicroMsg/face/43.gif"">")
		t0=replace(t0,"/:B-)","<img width=""24"" height=""24"" tag=""faces"" txt=""/:B-)"" src=""../MicroMsg/face/44.gif"">")
		t0=replace(t0,"/:<@","<img width=""24"" height=""24"" tag=""faces"" txt=""/:<@"" src=""../MicroMsg/face/45.gif"">")
		t0=replace(t0,"/:@>","<img width=""24"" height=""24"" tag=""faces"" txt=""/:@>"" src=""../MicroMsg/face/46.gif"">")
		t0=replace(t0,"/::-O","<img width=""24"" height=""24"" tag=""faces"" txt=""/::-O"" src=""../MicroMsg/face/47.gif"">")
		t0=replace(t0,"/:>-|","<img width=""24"" height=""24"" tag=""faces"" txt=""/:>-|"" src=""../MicroMsg/face/48.gif"">")
		t0=replace(t0,"/:P-(","<img width=""24"" height=""24"" tag=""faces"" txt=""/:P-("" src=""../MicroMsg/face/49.gif"">")
		t0=replace(t0,"/::'|","<img width=""24"" height=""24"" tag=""faces"" txt=""/::'|"" src=""../MicroMsg/face/50.gif"">")
		t0=replace(t0,"/:X-)","<img width=""24"" height=""24"" tag=""faces"" txt=""/:X-)"" src=""../MicroMsg/face/51.gif"">")
		t0=replace(t0,"/::*","<img width=""24"" height=""24"" tag=""faces"" txt=""/::*"" src=""../MicroMsg/face/52.gif"">")
		t0=replace(t0,"/:@x","<img width=""24"" height=""24"" tag=""faces"" txt=""/:@x"" src=""../MicroMsg/face/53.gif"">")
		t0=replace(t0,"/:8*","<img width=""24"" height=""24"" tag=""faces"" txt=""/:8*"" src=""../MicroMsg/face/54.gif"">")
		t0=replace(t0,"/:pd","<img width=""24"" height=""24"" tag=""faces"" txt=""/:pd"" src=""../MicroMsg/face/55.gif"">")
		t0=replace(t0,"/:<W>","<img width=""24"" height=""24"" tag=""faces"" txt=""/:<W>"" src=""../MicroMsg/face/56.gif"">")
		t0=replace(t0,"/:beer","<img width=""24"" height=""24"" tag=""faces"" txt=""/:beer"" src=""../MicroMsg/face/57.gif"">")
		t0=replace(t0,"/:basketb","<img width=""24"" height=""24"" tag=""faces"" txt=""/:basketb"" src=""../MicroMsg/face/58.gif"">")
		t0=replace(t0,"/:oo","<img width=""24"" height=""24"" tag=""faces"" txt=""/:oo"" src=""../MicroMsg/face/59.gif"">")
		t0=replace(t0,"/:coffee","<img width=""24"" height=""24"" tag=""faces"" txt=""/:coffee"" src=""../MicroMsg/face/60.gif"">")
		t0=replace(t0,"/:eat","<img width=""24"" height=""24"" tag=""faces"" txt=""/:eat"" src=""../MicroMsg/face/61.gif"">")
		t0=replace(t0,"/:pig","<img width=""24"" height=""24"" tag=""faces"" txt=""/:pig"" src=""../MicroMsg/face/62.gif"">")
		t0=replace(t0,"/:rose","<img width=""24"" height=""24"" tag=""faces"" txt=""/:rose"" src=""../MicroMsg/face/63.gif"">")
		t0=replace(t0,"/:fade","<img width=""24"" height=""24"" tag=""faces"" txt=""/:fade"" src=""../MicroMsg/face/64.gif"">")
		t0=replace(t0,"/:showlove","<img width=""24"" height=""24"" tag=""faces"" txt=""/:showlove"" src=""../MicroMsg/face/65.gif"">")
		t0=replace(t0,"/:heart","<img width=""24"" height=""24"" tag=""faces"" txt=""/:heart"" src=""../MicroMsg/face/66.gif"">")
		t0=replace(t0,"/:break","<img width=""24"" height=""24"" tag=""faces"" txt=""/:break"" src=""../MicroMsg/face/67.gif"">")
		t0=replace(t0,"/:cake","<img width=""24"" height=""24"" tag=""faces"" txt=""/:cake"" src=""../MicroMsg/face/68.gif"">")
		t0=replace(t0,"/:li","<img width=""24"" height=""24"" tag=""faces"" txt=""/:li"" src=""../MicroMsg/face/69.gif"">")
		t0=replace(t0,"/:bome","<img width=""24"" height=""24"" tag=""faces"" txt=""/:bome"" src=""../MicroMsg/face/70.gif"">")
		t0=replace(t0,"/:kn","<img width=""24"" height=""24"" tag=""faces"" txt=""/:kn"" src=""../MicroMsg/face/71.gif"">")
		t0=replace(t0,"/:footb","<img width=""24"" height=""24"" tag=""faces"" txt=""/:footb"" src=""../MicroMsg/face/72.gif"">")
		t0=replace(t0,"/:ladybug","<img width=""24"" height=""24"" tag=""faces"" txt=""/:ladybug"" src=""../MicroMsg/face/73.gif"">")
		t0=replace(t0,"/:shit","<img width=""24"" height=""24"" tag=""faces"" txt=""/:shit"" src=""../MicroMsg/face/74.gif"">")
		t0=replace(t0,"/:moon","<img width=""24"" height=""24"" tag=""faces"" txt=""/:moon"" src=""../MicroMsg/face/75.gif"">")
		t0=replace(t0,"/:sun","<img width=""24"" height=""24"" tag=""faces"" txt=""/:sun"" src=""../MicroMsg/face/76.gif"">")
		t0=replace(t0,"/:gift","<img width=""24"" height=""24"" tag=""faces"" txt=""/:gift"" src=""../MicroMsg/face/77.gif"">")
		t0=replace(t0,"/:hug","<img width=""24"" height=""24"" tag=""faces"" txt=""/:hug"" src=""../MicroMsg/face/78.gif"">")
		t0=replace(t0,"/:strong","<img width=""24"" height=""24"" tag=""faces"" txt=""/:strong"" src=""../MicroMsg/face/79.gif"">")
		t0=replace(t0,"/:weak","<img width=""24"" height=""24"" tag=""faces"" txt=""/:weak"" src=""../MicroMsg/face/80.gif"">")
		t0=replace(t0,"/:share","<img width=""24"" height=""24"" tag=""faces"" txt=""/:share"" src=""../MicroMsg/face/81.gif"">")
		t0=replace(t0,"/:v","<img width=""24"" height=""24"" tag=""faces"" txt=""/:v"" src=""../MicroMsg/face/82.gif"">")
		t0=replace(t0,"/:@)","<img width=""24"" height=""24"" tag=""faces"" txt=""/:@)"" src=""../MicroMsg/face/83.gif"">")
		t0=replace(t0,"/:jj","<img width=""24"" height=""24"" tag=""faces"" txt=""/:jj"" src=""../MicroMsg/face/84.gif"">")
		t0=replace(t0,"/:@@","<img width=""24"" height=""24"" tag=""faces"" txt=""/:@@"" src=""../MicroMsg/face/85.gif"">")
		t0=replace(t0,"/:bad","<img width=""24"" height=""24"" tag=""faces"" txt=""/:bad"" src=""../MicroMsg/face/86.gif"">")
		t0=replace(t0,"/:lvu","<img width=""24"" height=""24"" tag=""faces"" txt=""/:lvu"" src=""../MicroMsg/face/87.gif"">")
		t0=replace(t0,"/:no","<img width=""24"" height=""24"" tag=""faces"" txt=""/:no"" src=""../MicroMsg/face/88.gif"">")
		t0=replace(t0,"/:ok","<img width=""24"" height=""24"" tag=""faces"" txt=""/:ok"" src=""../MicroMsg/face/89.gif"">")
		t0=replace(t0,"/:love","<img width=""24"" height=""24"" tag=""faces"" txt=""/:love"" src=""../MicroMsg/face/90.gif"">")
		t0=replace(t0,"/:<L>","<img width=""24"" height=""24"" tag=""faces"" txt=""/:<L>"" src=""../MicroMsg/face/91.gif"">")
		t0=replace(t0,"/:jump","<img width=""24"" height=""24"" tag=""faces"" txt=""/:jump"" src=""../MicroMsg/face/92.gif"">")
		t0=replace(t0,"/:shake","<img width=""24"" height=""24"" tag=""faces"" txt=""/:shake"" src=""../MicroMsg/face/93.gif"">")
		t0=replace(t0,"/:<O>","<img width=""24"" height=""24"" tag=""faces"" txt=""/:<O>"" src=""../MicroMsg/face/94.gif"">")
		t0=replace(t0,"/:circle","<img width=""24"" height=""24"" tag=""faces"" txt=""/:circle"" src=""../MicroMsg/face/95.gif"">")
		t0=replace(t0,"/:kotow","<img width=""24"" height=""24"" tag=""faces"" txt=""/:kotow"" src=""../MicroMsg/face/96.gif"">")
		t0=replace(t0,"/:turn","<img width=""24"" height=""24"" tag=""faces"" txt=""/:turn"" src=""../MicroMsg/face/97.gif"">")
		t0=replace(t0,"/:skip","<img width=""24"" height=""24"" tag=""faces"" txt=""/:skip"" src=""../MicroMsg/face/98.gif"">")
		t0=replace(t0,"/:oY","<img width=""24"" height=""24"" tag=""faces"" txt=""/:oY"" src=""../MicroMsg/face/99.gif"">")
		t0=replace(t0,"/:#-0","<img width=""24"" height=""24"" tag=""faces"" txt=""/:#-0"" src=""../MicroMsg/face/100.gif"">")
		t0=replace(t0,"/街舞","<img width=""24"" height=""24"" tag=""faces"" txt=""/街舞"" src=""../MicroMsg/face/101.gif"">")
		t0=replace(t0,"/:kiss","<img width=""24"" height=""24"" tag=""faces"" txt=""/:kiss"" src=""../MicroMsg/face/102.gif"">")
		t0=replace(t0,"/:<&","<img width=""24"" height=""24"" tag=""faces"" txt=""/:<&"" src=""../MicroMsg/face/103.gif"">")
		replaceFaces=t0
	end function
	Function getFaceChar(faceid)
		If Not isnumeric(faceid) Or Len(faceid) = 0 Then
			getFaceChar = ""
			Exit Function
		end if
		If CLng(faceid) > 103 Or CLng(faceid) < 0 Then
			getFaceChar = ""
			Exit Function
		end if
		Dim faces(103)
		faceses(0) = "/::)"
		faceses(1) = "/::~"
		faceses(2) = "/::B"
		faceses(3) = "/::|"
		faceses(4) = "/:8-)"
		faceses(3) = "/::|"
		faceses(5) = "/::<"
		faceses(6) = "/::$"
		faceses(7) = "/::X"
		faceses(8) = "/::Z"
		faceses(9) = "/::'("
		faceses(10) = "/::-|"
		faceses(9) = "/::'("
		faceses(11) = "/::@"
		faceses(12) = "/::P"
		faceses(13) = "/::D"
		faceses(14) = "/::O"
		faceses(15) = "/::("
		faceses(16) = "/::+"
		faceses(15) = "/::("
		faceses(17) = "/:--b"
		faceses(15) = "/::("
		faceses(18) = "/::Q"
		faceses(19) = "/::T"
		faceses(20) = "/:,@P"
		faceses(21) = "/:,@-D"
		faceses(20) = "/:,@P"
		faceses(22) = "/::d"
		faceses(23) = "/:,@o"
		faceses(24) = "/::g"
		faceses(25) = "/:|-)"
		faceses(24) = "/::g"
		faceses(26) = "/::!"
		faceses(27) = "/::L"
		faceses(28) = "/::>"
		faceses(29) = "/::,@"
		faceses(30) = "/:,@f"
		faceses(31) = "/::-S"
		faceses(30) = "/:,@f"
		faceses(32) = "/:?"
		faceses(33) = "/:,@x"
		faceses(34) = "/:,@@"
		faceses(35) = "/::8"
		faceses(36) = "/:,@!"
		faceses(37) = "/:!!!"
		faceses(38) = "/:xx"
		faceses(39) = "/:bye"
		faceses(40) = "/:wipe"
		faceses(41) = "/:dig"
		faceses(42) = "/:handclap"
		faceses(43) = "/:&-("
		faceses(42) = "/:handclap"
		faceses(44) = "/:B-)"
		faceses(42) = "/:handclap"
		faceses(45) = "/:<@"
		faceses(46) = "/:@>"
		faceses(47) = "/::-O"
		faceses(46) = "/:@>"
		faceses(48) = "/:>-|"
		faceses(46) = "/:@>"
		faceses(49) = "/:P-("
		faceses(46) = "/:@>"
		faceses(50) = "/::’|"
		faceses(51) = "/:X-)"
		faceses(50) = "/::’|"
		faceses(52) = "/::*"
		faceses(53) = "/:@x"
		faceses(54) = "/:8*"
		faceses(55) = "/:pd"
		faceses(56) = "/:<W>"
		faceses(57) = "/:beer"
		faceses(58) = "/:basketb"
		faceses(59) = "/:oo"
		faceses(60) = "/:coffee"
		faceses(61) = "/:eat"
		faceses(62) = "/:pig"
		faceses(63) = "/:rose"
		faceses(64) = "/:fade"
		faceses(65) = "/:showlove"
		faceses(66) = "/:heart"
		faceses(67) = "/:break"
		faceses(68) = "/:cake"
		faceses(69) = "/:li"
		faceses(70) = "/:bome"
		faceses(71) = "/:kn"
		faceses(72) = "/:footb"
		faceses(73) = "/:ladybug"
		faceses(74) = "/:shit"
		faceses(75) = "/:moon"
		faceses(76) = "/:sun"
		faceses(77) = "/:gift"
		faceses(78) = "/:hug"
		faceses(79) = "/:strong"
		faceses(80) = "/:weak"
		faceses(81) = "/:share"
		faceses(82) = "/:v"
		faceses(83) = "/:@)"
		faceses(84) = "/:jj"
		faceses(85) = "/:@@"
		faceses(86) = "/:bad"
		faceses(87) = "/:lvu"
		faceses(88) = "/:no"
		faceses(89) = "/:ok"
		faceses(90) = "/:love"
		faceses(91) = "/:<L>"
		faceses(92) = "/:jump"
		faceses(93) = "/:shake"
		faceses(94) = "/:<O>"
		faceses(95) = "/:circle"
		faceses(96) = "/:kotow"
		faceses(97) = "/:turn"
		faceses(98) = "/:skip"
		faceses(99) = "/:oY"
		faceses(100) = "/:#-0"
		faceses(99) = "/:oY"
		faceses(101) = "[街舞]"
		faceses(102) = "/:kiss"
		faceses(103) = "/:<&"
		getFaceChar = faceses(faceid)
	end function
	Sub HandleErrorStr(ByRef stdata)
		Dim i
		Err.clear
		on error resume next
		i = InStr(1, stdata, "<", 1)
		If  Err.number=0 Then Exit sub
		stdata = Replace(stdata, "。","ax1b1xc")
		stdata = Replace(stdata, "：","ax2b2xc")
		stdata = Replace(stdata, "、","ax3b3xc")
		stdata = Replace(stdata, "，","ax4b4xc")
		stdata = Me.sdk.base64.DataStrConv(stdata,8)
		stdata = Replace(stdata,"ax1b1xc", "。")
		stdata = Replace(stdata,"ax2b2xc", "：")
		stdata = Replace(stdata,"ax3b3xc", "、")
		stdata = Replace(stdata,"ax4b4xc", "，")
	end sub
	Function FromUnixTime(intTime)
		If IsEmpty(intTime) Or Not IsNumeric(intTime) Then
			FromUnixTime = Now()
			Exit Function
		end if
		FromUnixTime = DateAdd("s", intTime, "1970-1-1 0:0:0")
		Exit Function
		FromUnixTime = DateAdd("h", 8, FromUnixTime)
	end function
	Function ToUnixTime(ByVal dtTime)
		If IsEmpty(dtTime) Or Not IsNumeric(dtTime) Then
			dtTime = Now()
		end if
		dtTime = DateAdd("h",-8,dtTime)
		dtTime = Now()
		ToUnixTime = DateDiff("s","1970-1-1 0:0:0",dtTime)
		dtTime = Now()
	end function
	Public Function HexEncode(ByVal data)
		Dim s, c, i ,rnds, item
		c = Len(data) - 1
'Dim s, c, i ,rnds, item
		rnds = Split("g,h,i,j,k,l,m,n,o",",")
		If c = - 1 Then Exit function
		rnds = Split("g,h,i,j,k,l,m,n,o",",")
		For i = 0 To c
			If i > 0 Then
				s = s & rnds(int(rnd*9))
			end if
			item = LCase(Hex(Ascw(Mid(data, i+1, 1))))
			s = s & rnds(int(rnd*9))
			item = Replace(item,"0","q")
			item = Replace(item,"1","p")
			item = Replace(item,"2","t")
			item = Replace(item,"3","s")
			item = Replace(item,"4","x")
			item = Replace(item,"5","u")
			item = Replace(item,"6","v")
			item = Replace(item,"7","y")
			item = Replace(item,"8","z")
			item = Replace(item,"9","w")
			s = s & item
		next
		HexEncode = s
	end function
	Function IIf(ByVal expression,ByVal valTrue,ByVal valFalse)
		If expression Then
			IIf = valTrue
		else
			IIf = valFalse
		end if
	end function
	Function getSKUString(cn,goodsId,splitChar)
		Dim rs
		Set rs = cn.execute("" & vbcrlf &_
		"select sc.title,sa.attrVal from Shop_GoodsAttrValue sa " & vbcrlf &_
		"inner join Shop_GoodsAttr sb on sa.degreeID=sb.id " & vbcrlf &_
		"inner join Shop_GoodsAttr sc on sb.pid=sc.id " & vbcrlf &_
		"where sa.goodsid=" & goodsId & " " & vbcrlf &_
		"")
		If rs.eof Then
			getSKUString = ""
		else
			getSKUString = rs.getString(,,":",splitChar,"")
			If Right(getSKUString,Len(splitChar)) = splitChar Then getSKUString = Left(getSKUString,Len(getSKUString) - len(splitChar))
			getSKUString = rs.getString(,,":",splitChar,"")
		end if
		rs.close
		set rs = nothing
	end function
	Function JsonStringFilter(s)
		JsonStringFilter = Replace(Replace(s&"","\","\\"),"""","\""")
	end function
	Function quotValue(s)
		quotValue = Replace(s,"""","&#34;")
	end function
	Sub showReplyList(ord,cn,pageindex,pagesize)
		Response.write "" & vbcrlf & "<div class=""talk"">" & vbcrlf & ""
		Dim sql,rs,className,content,headimgPath,isReceive
		Dim recordCount,pageCount
		sql =  "select a.*,u.nickname muserName," & vbcrlf &_
		"case when a.SendOrReceive=1 then u.headimgPath else (select top 1 photos from hr_person hp where hp.userid=a.cateid) end headimgPath," &_
		"b.name guserName " & vbcrlf &_
		"from MMsg_Message a " & vbcrlf &_
		"left join gate b on b.ord=a.cateid " & vbcrlf &_
		"left join MMsg_User u on u.id=a.userId " & vbcrlf &_
		"where a.userid=" & ord & vbcrlf &_
		" order by a.id desc"
		Set rs = server.CreateObject("adodb.recordset")
		rs.open sql,cn,1,1
		If rs.eof Then
			recordCount = 0
			pageCount = 0
			Response.write "<div style='width:100%;line-height:25px;text-align:center;background-color:white'>没有信息！</div>"
			pageCount = 0
		else
			Dim i : i = 0
			Dim ids : ids = "0"
			If pagesize <= 0 Then pagesize= 10
			If pageindex <=0 Then pageindex = 1
			rs.PageSize = pagesize
			recordCount = rs.RecordCount
			pageCount = rs.PageCount
			If pageindex > pageCount Then pageindex = pageCount
			rs.AbsolutePage = pageindex
			While rs.eof = False And i < pagesize
				isReceive = rs("SendOrReceive") = 1
				className = IIf(isReceive,"receive","send")
				headimgPath = rs("headimgPath")
				If Len(headimgPath&"") = 0 Then
					headimgPath = "../hrm/img/noneperson.jpg"
				else
					If isReceive Then
						headimgPath = "../MicroMsg/" & headimgPath
					Else
						headimgPath = "../hrm/load/" & headimgPath
					end if
				end if
				Select Case LCase(rs("msgType"))
				Case "text":
				content = replaceFaces(Replace(rs("Content"),Chr(10),"<br>"))
				Case "image":
				content = "<img src='../MicroMsg/" & rs("PicUrl") & "' style='cursor:hand;height:90px;' onclick='showPic(this);' title='点击查看原图'/>"
				Case "audio","voice":
				content = "<a href='javascript:void(0);' file='" & HexEncode(server.mappath(rs("MediaPath"))) & "' style='cursor:hand;' onclick='downloadFile(this);' title='点击下载该音频文件'>[语音信息]</a>"
				Case "video","shortvideo":
				content = "<img src='../MicroMsg/" & rs("ThumbMediaId") & "' file='" & HexEncode(server.mappath(rs("MediaPath"))) & "' style='cursor:hand;height:90px;' onclick='downloadFile(this);' title='点击下载该视频文件'/>"
				Case "location":
				content = "<img src='http://st.map.qq.com/api?size=600*300&center="&rs("Location_Y")&","&rs("Location_X")&"&zoom="&rs("Scale")&"&markers="&rs("Location_Y")&","&rs("Location_X")&"' onclick='showPic(this);' title='" & rs("Label") & "[点击放大]' style='cursor:hand;height:90px;float:left'>"
				Case Else
				content = ""
				End Select
				Response.write "" & vbcrlf & "     <div class=""talk_box_"
				Response.write className
				Response.write """>" & vbcrlf & "                <div class=""user"">" & vbcrlf & "                        <img src="""
				Response.write headimgPath
				Response.write """ width=""45"" height=""45"" style=""display:block;cursor:hand;"" onclick=""showPic(this);""/>" & vbcrlf & "                    <div class=""talk_userName"">"
				Response.write IIf(isReceive,rs("muserName"),rs("guserName"))
				Response.write "</div>" & vbcrlf & "               </div>" & vbcrlf & "          <div class=""talk_arrow"">&nbsp;</div>" & vbcrlf & "              <div class=""talk_text"">" & vbcrlf & "                   <div class=""radius radius-left-top""></div>" & vbcrlf & "                        <div class=""radius radius-left-bottom""></div>" & vbcrlf & "                     <div class=""radius radius-right-bottom""></div>" & vbcrlf & "                       <div class=""radius radius-right-top""></div>" & vbcrlf & "                       <h3>"
				Response.write IIf(isReceive,rs("muserName"),rs("guserName"))
				Response.write content
				Response.write "</h3>" & vbcrlf & "                        <span class=""talk_time"">"
				Response.write FromUnixTime(rs("CreateTime"))
				Response.write "</span>" & vbcrlf & "              </div>" & vbcrlf & "  </div>" & vbcrlf & ""
				i = i + 1
				Response.write "</span>" & vbcrlf & "              </div>" & vbcrlf & "  </div>" & vbcrlf & ""
				ids = ids & "," & rs("id")
				rs.movenext
			wend
			Dim helper : Set helper = CreateReminderHelper(cn,157,0)
			cn.execute "update MMsg_Message set readed=1 where readed=0 and id in (" & ids & ") and SendOrReceive=1 and userid in (" & helper.listSQL("ids") & ")"
			Response.write "" & vbcrlf & "     <div>" & vbcrlf & "           <DIV id=lvw_pagebar_mlistvw class=lvw_pagebar>" & vbcrlf & "                  <DIV style=""WIDTH: 20px"" class=left>&nbsp;</DIV>" & vbcrlf & "                  <DIV class=lvwbg007 style=""width:130px"">" & vbcrlf & "                          <TABLE align=right>" & vbcrlf & "                                     <TR>" & vbcrlf & "                                            <TD class=lvwpagesizearea vAlign=top width=60 align=right>每页行数：</TD>" & vbcrlf & "                                         <TD class=lvwpagesizearea width=55 align=left>" & vbcrlf & "                                                  <SELECT style=""WIDTH: 50px;"" id=""r_pgsize"" onchange='ajaxPage("
			Response.write ord
			Response.write ",1,this.value);'>" & vbcrlf & "                                                            <OPTION "
			Response.write IIf(pageSize=5,"selected","")
			Response.write " value=5>5</OPTION>" & vbcrlf & "                                                          <OPTION "
			Response.write IIf(pageSize=10,"selected","")
			Response.write " value=10>10</OPTION>" & vbcrlf & "                                                                <OPTION "
			Response.write IIf(pageSize=15,"selected","")
			Response.write " value=15>15</OPTION>" & vbcrlf & "                                                                <OPTION "
			Response.write IIf(pageSize=20,"selected","")
			Response.write " value=20>20</OPTION>" & vbcrlf & "                                                                <OPTION "
			Response.write IIf(pageSize=30,"selected","")
			Response.write " value=30>30</OPTION>" & vbcrlf & "                                                                <OPTION "
			Response.write IIf(pageSize=50,"selected","")
			Response.write " value=50>50</OPTION>" & vbcrlf & "                                                                <OPTION "
			Response.write IIf(pageSize=70,"selected","")
			Response.write " value=70>70</OPTION>" & vbcrlf & "                                                                <OPTION "
			Response.write IIf(pageSize=100,"selected","")
			Response.write " value=100>100</OPTION>" & vbcrlf & "                                                              <OPTION "
			Response.write IIf(pageSize=200,"selected","")
			Response.write " value=200>200</OPTION>" & vbcrlf & "                                                              <OPTION "
			Response.write IIf(pageSize=500,"selected","")
			Response.write " value=500>500</OPTION>" & vbcrlf & "                                                      </SELECT>行" & vbcrlf & "                                             </TD>" & vbcrlf & "                                   </TR>" & vbcrlf & "                           </TABLE>" & vbcrlf & "                        </DIV>" & vbcrlf & "                  <DIV style=""POSITION: relative; FLOAT: right; LEFT: -10px"" class=lvwbg0010>" & vbcrlf & "                       <DIV style=""COLOR: #2f496e"" class=lvwbg0006><SPAN id=jlCount_mlistvw>"
			Response.write recordCount
			Response.write "</SPAN>个&nbsp;|&nbsp;"
			Response.write IIf(recordCount = 0,0,pageIndex)
			Response.write "/"
			Response.write pageCount
			Response.write "页&nbsp;|&nbsp;"
			Response.write pageSize
			Response.write "条信息/页&nbsp;</DIV>" & vbcrlf & "                        <DIV class=lvw_ywrow>&nbsp;</DIV>" & vbcrlf & "                       <DIV class=lvw_ywrow>" & vbcrlf & "                           <INPUT onfocus='this.select()' title='输入正确的分页序号，按回车键执行分页' onkeypress=""return pageboxkeypress(this,"
			Response.write ord
			Response.write ",$('#r_pgsize').val());"" value=1 maxLength=8 size=3 max=""2"" value="""
			Response.write pageindex
			Response.write """>" & vbcrlf & "                        </DIV>" & vbcrlf & "                  <DIV class=lvw_ywrow>" & vbcrlf & "                           <BUTTON class='oldbutton4' onclick="""">跳转</BUTTON>" & vbcrlf & "                       </DIV>" & vbcrlf & "                  <DIV class=lvw_ywrow>" & vbcrlf & "                           <BUTTON class='oldbutton " & vbcrlf & "                               "
			Response.write IIf(pageindex=1,"' disabled='disabled''","' onclick='ajaxPage("&ord&",1,$(""#r_pgsize"").val());'")
			Response.write "'" & vbcrlf & "                            >首页</BUTTON>" & vbcrlf & "                  </DIV>" & vbcrlf & "                  <DIV class=lvw_ywrow>" & vbcrlf & "                           <BUTTON class='oldbutton " & vbcrlf & "                               "
			Response.write IIf(pageindex=1,"' disabled='disabled'","' onclick='ajaxPage("&ord&","&(pageindex-1)&",$(""#r_pgsize"").val());'")
			Response.write "'" & vbcrlf & "                            >上一页</BUTTON>" & vbcrlf & "                        </DIV>" & vbcrlf & "                  <DIV class=lvw_ywrow>" & vbcrlf & "                           <BUTTON class='oldbutton " & vbcrlf & "                               "
			Response.write IIf(pageindex=pageCount,"' disabled='disabled'","' onclick='ajaxPage("&ord&","&(pageindex+1)&",$(""#r_pgsize"").val());'")
			Response.write "'" & vbcrlf & "                            >下一页</BUTTON>" & vbcrlf & "                        </DIV>" & vbcrlf & "                  <DIV class=lvw_ywrow>" & vbcrlf & "                           <BUTTON class='oldbutton " & vbcrlf & "                               "
			Response.write IIf(pageindex=pageCount,"' disabled='disabled'","' onclick='ajaxPage("&ord&","&pageCount&",$(""#r_pgsize"").val());'")
			Response.write "'" & vbcrlf & "                            >尾页</BUTTON>" & vbcrlf & "                  </DIV>" & vbcrlf & "                  <DIV class=lvw_ywrow>&nbsp;</DIV></DIV>" & vbcrlf & "                 <DIV style=""WIDTH: 100%; HEIGHT: 2px; CLEAR: both; OVERFLOW: hidden""></DIV>" & vbcrlf & "               </DIV>" & vbcrlf & "  </div>" & vbcrlf & "</div>" & vbcrlf & ""
		end if
		rs.close
		Set rs=Nothing
	end sub
	Function getAreaFullPath(cn,id)
		Dim rs
		Dim fullName : fullName = ""
		If id & "" <> "" Then
			Dim areaCnt : areaCnt = 1
			Set rs = cn.execute("select * from menuarea where id=" & id)
			While rs.eof = False And areaCnt < 100
				fullName = JsonStringFilter(rs("menuname")) & fullName
				Set rs = cn.execute("select * from menuarea where id=" & rs("id1"))
				If rs.eof = False Then fullName =  " " & fullName
				areaCnt = areaCnt + 1
'If rs.eof = False Then fullName =  " " & fullName
			wend
		end if
		getAreaFullPath = fullName
	end function
	Function isPhoneNumNeedMask(cn,company)
		Dim cateid,rsCate
		isPhoneNumNeedMask = False
		If company & "" = "" Then Exit Function
		Dim powerPhone
		If ZBRuntime.MC(2000) Then
			cateid = 0
			Set rsCate = cn.execute("select isnull(cateid,0) cateid from tel where ord in (" & sdk.FormatNumList(company) & ")")
			If rsCate.eof = False Then cateid = rsCate(0)
			rsCate.close
			Set rsCate = Nothing
			If sdk.power.ExistsModel(2000) Then
				powerPhone = sdk.power.getPowerIntro(2,6)
				If powerPhone <> "" Then
					isPhoneNumNeedMask = InStr("," & powerPhone & "," , "," & cateid & ",") <= 0
				end if
			end if
		end if
	end function
	Sub showAddrList(ord,ordType,pageindex,pagesize,cn,mode,shouhuoname,serchkey,serchtext,shadress)
		Dim condition,rs,sql,pageCount,recCount,i
		Dim cateid,rsCate,needMaskPhone : needMaskPhone = False
		If Not IsNumeric(pageindex) Then pageindex = 1
		If pageindex <= 0 Then pageindex = 1
		Select Case ordType
		Case "company" :
		condition = " and company = " & ord
		if shouhuoname<>""then
			condition=condition+" and (len(isnull('"&shouhuoname&"',''))=0 or receiver like '%"&shouhuoname&"%') "
'if shouhuoname<>""then
		end if
		if shadress<>"" then
			condition=condition+" and (len(isnull('"&shadress&"',''))=0 or CHARINDEX(ltrim(rtrim('"&shadress&"')),bb.fullPath) > 0 or CHARINDEX(ltrim(rtrim('"&shadress&"')),address) > 0) "
'if shadress<>"" then
		end if
		if serchtext<>"" then
			if serchkey=1 then
				condition=condition+" and (len(isnull('"&serchtext&"',''))=0 or CHARINDEX('"&serchtext&"',mobile) > 0)  "
'if serchkey=1 then
			else
				condition=condition+"  and (len(isnull('"&serchtext&"',''))=0 or CHARINDEX('"&serchtext&"',phone) > 0)  "
'if serchkey=1 then
			end if
		end if
		sql = "select isnull(b.cateid,0) cateid from tel b where b.ord=" & ord
		Case "person" :
		condition = " and person = " & ord
		sql = "select isnull(b.cateid,0) cateid from person a left join tel b on a.company=b.ord where a.ord=" & ord
		Case "wxUserId" :
		condition = " and wxUserId = " & ord
		End Select
		Dim powerPhone
		If ZBRuntime.MC(2000) Then
			If ordType <> "wxUserId" Then
				cateid = 0
				Set rsCate = cn.execute(sql)
				If rsCate.eof = False Then cateid = rsCate(0)
				rsCate.close
				Set rsCate = Nothing
				If sdk.power.ExistsModel(2000) Then
					powerPhone = sdk.power.getPowerIntro(2,6)
					If powerPhone <> "" Then
						needMaskPhone = InStr("," & powerPhone & "," , "," & cateid & ",") <= 0
					end if
				end if
			end if
		end if
		sql="set nocount on " & vbcrlf &_
		"declare @cnt int " & vbcrlf &_
		"set @cnt = 1 " & vbcrlf &_
		"select a.id,a.id1 as pid,cast(a.menuname as varchar(8000)) as fullPath into #area " & vbcrlf &_
		"from menuarea a " & vbcrlf &_
		"while exists(select 1 from #area where pid<>0) and @cnt < 100 " & vbcrlf &_
		"begin " & vbcrlf &_
		"update #area set fullPath = b.menuname + ' ' + fullPath , pid=b.id1  from menuarea b where b.id=#area.pid " & vbcrlf &_
		"begin " & vbcrlf &_
		"set @cnt = cnt + 1 " & vbcrlf &_
		"begin " & vbcrlf &_
		"end " & vbcrlf &_
		"select aa.*,bb.fullPath," & vbcrlf &_
		"(select count(*) from DeliveryAddress " & vbcrlf &_
		"where " & iif(ordType="wxUserId"," 1=1 "," showOnPc = 1 ") & condition & " " & vbcrlf &_
		"and id > aa.id) idx " & vbcrlf &_
		"from DeliveryAddress aa " & vbcrlf &_
		"left join #area bb on aa.areaId=bb.id " & vbcrlf &_
		"where " & iif(ordType="wxUserId"," 1=1 "," showOnPc = 1 ") & condition & " order by aa.id desc"
		Set rs = server.CreateObject("adodb.recordset")
		rs.open sql,cn,1,1
		if mode="select" then
			Response.write "" & vbcrlf & "        <div style=""margin-bottom:5px;margin-left:10px;"">收货人：<input value="""
'if mode="select" then
			Response.write shouhuoname
			Response.write """ style=""width:100px;"" id=""shouhuoname"" />" & vbcrlf & "            <select style=""margin-left:10px;"" id=""serchkey"">" & vbcrlf & "                <option  "
			Response.write shouhuoname
			if serchkey="1" then
				Response.write "selected"
			end if
			Response.write " value=""1"">手机</option>" & vbcrlf & "                <option "
			if serchkey="2" then
				Response.write "selected"
			end if
			Response.write "   value=""2"">固定电话</option>" & vbcrlf & "            </select>" & vbcrlf & "            <input style=""margin-left:10px;"" value="""
			Response.write "selected"
			Response.write serchtext
			Response.write """ id=""serchtext""/>" & vbcrlf & "            <span style=""margin-left:10px;"">收货地址：</span> " & vbcrlf & "             <input  value="""
			Response.write serchtext
			Response.write shadress
			Response.write """ id=""shadress""/>" & vbcrlf & "            <input type=""button"" id=""serch"" value=""检索"" onclick=""addrShowSelector('company');"" class=""page""/>" & vbcrlf & "        </div>" & vbcrlf & ""
		end if
		Response.write "" & vbcrlf & "             <table style=""width:100%;margin:0px;border-collapse:collapse;border:0px"" border=""0"" " & vbcrlf & "                        cellpadding=""0"" cellspacing=""0"" id=""personAddressList""" & vbcrlf & "                        ordType="""
		Response.write ordType
		Response.write """" & vbcrlf & "                 ord="""
		Response.write ord
		Response.write """" & vbcrlf & "                 mode="""
		Response.write mode
		Response.write """" & vbcrlf & "         >" & vbcrlf & "" & vbcrlf & ""
		If rs.eof Then
			pageindex = 1
			recCount = 0
			pageCount = 0
			Response.write "" & vbcrlf & "                     <tr>" & vbcrlf & "                            <td height=""30"" colspan=""6"" style=""border:0px solid #c0ccdd"" align=""center"">暂无记录！</td>" & vbcrlf & "                     </tr>" & vbcrlf & ""
		else
			rs.pageSize = pagesize
			pageCount = rs.PageCount
			If pageIndex > pageCount Then pageIndex = pageCount
			If pageIndex <=0 Then pageIndex = 1
			rs.absolutePage = pageindex
			recCount = rs.recordCount
			i = 0
			If mode = "list" Then
				Response.write "" & vbcrlf & "                     <tr class=""top"" height=""30"">" & vbcrlf & "                                <td align=""center"" style=""border:1px solid #c0ccdd"">序号</td>" & vbcrlf & "                               <td align=""center"" style=""border:1px solid #c0ccdd"">收货人</td>" & vbcrlf & "                             <td align=""center"" style=""border:1px solid #c0ccdd"">联系方式</td>" & vbcrlf & "                           <td align=""center"" style=""border:1px solid #c0ccdd"">操作</td>" & vbcrlf & "                       </tr>" & vbcrlf & ""
			end if
			While rs.eof = False And i < pagesize
				Response.write "" & vbcrlf & "                     <tr onmouseover=""this.style.backgroundColor='efefef'"" onmouseout=""this.style.backgroundColor=''"">" & vbcrlf & "                           <td width=""10%"" height=""30"" class=""name"" style=""border:1px solid #c0ccdd;white-space:normal;word-wrap:break-word;"" " & vbcrlf & "                                      oncopy=""returnfalse;"" oncut=""return false;"" onselectstart=""return false"" align=""center"">" & vbcrlf & ""
				If mode = "select" Then
					Response.write "<a addrId='" & rs("id") & "' href='javascript:void(0)' onclick='addrSelect(this);'>选择地址</a>"
				else
					Response.write rs("idx") + 1
					Response.write "<a addrId='" & rs("id") & "' href='javascript:void(0)' onclick='addrSelect(this);'>选择地址</a>"
				end if
				Response.write "" &_
				"<span class='addr_mobile' style='display:none'>" & rs("mobile") & "</span>" &_
				"<span class='addr_phone'  style='display:none'>" & rs("phone") & "</span>"
				Response.write "" & vbcrlf & "                             </td>" & vbcrlf & "                           <td width=""15%"" style=""border:1px solid #c0ccdd;white-space:normal;word-wrap:break-word;padding:5px"" align=""center"">" & vbcrlf & "                                  <span class=""addr_receiver"">" & vbcrlf &_
				"<span class='addr_phone'  style='display:none'"
				Response.write rs("receiver")
				Response.write "</span>" & vbcrlf & "                              </td>" & vbcrlf & "                           <td width=""60%"" class=""gray"" style=""border:1px solid #c0ccdd;white-space:normal;word-wrap:break-word;padding:5px"">" & vbcrlf & "                                    <span class=""addr_areaId"" style=""display:none"">"
				Response.write rs("receiver")
				Response.write rs("areaId")
				Response.write "</span>" & vbcrlf & "                                      <span class=""addr_mobile_show"">"
				Response.write IIF(needMaskPhone,String(Len(rs("mobile")),"*"),rs("mobile"))
				Response.write "</span>" & vbcrlf & "                                      <span class=""addr_phone_show"">"
				Response.write IIF(needMaskPhone,String(Len(rs("phone")),"*"),rs("phone"))
				Response.write "</span>" & vbcrlf & "                                      <span class=""addr_area"">"
				Response.write rs("fullPath")
				Response.write "</span>" & vbcrlf & "                                      <span class=""addr_address"">"
				Response.write rs("address")
				Response.write "</span>" & vbcrlf & "                                      <span class=""addr_zip"">"
				Response.write rs("zip")
				Response.write "</span>" & vbcrlf & "                                      <span class=""addr_isDefault"">" & vbcrlf & ""
				If ordType = "person" And rs("isPersonDefault") = 1 Or ordType = "company" And rs("isTelDefault") = 1 Then
					Response.write "[默认]"
				end if
				Response.write "" & vbcrlf & "                                     </span>" & vbcrlf & "                                 <span class=""addr_fromWx"">"
				Response.write iif(rs("fromWx")=1,"[微信]","")
				Response.write "</span>" & vbcrlf & "                              <td width=""15%"" class=""addrList_actionBtn addr_cell addr_right_border"" style=""border:1px solid #c0ccdd;"" align=""center"">" & vbcrlf & "                                        <a style=""margin:0px;padding:0px"" addrId="""
				Response.write rs("id")
				Response.write """ " & vbcrlf & "                                                href=""javascript:void(0);"" " & vbcrlf & "                                               onclick=""addrModify(this,"
				Response.write ord
				Response.write ",'"
				Response.write ordType
				Response.write "');"">修改</a>&nbsp;&nbsp;" & vbcrlf & "                                 <a style=""margin:0px;padding:0px"" addrId="""
				Response.write rs("id")
				Response.write """ " & vbcrlf & "                                                href=""javascript:void(0);"" " & vbcrlf & "                                               onclick=""addrDelete(this,'"
				Response.write ordType
				Response.write "');"" " & vbcrlf & "                                             style=""margin-right:30px;"">删除</a>" & vbcrlf & "                               </td>" & vbcrlf & "                   </tr>" & vbcrlf & ""
				Response.write ordType
				i = i + 1
				Response.write ordType
				rs.movenext
			wend
		end if
		Response.write "" & vbcrlf & "                     <tr "
		Response.write iif(mode="top"," style='display:none'","")
		Response.write ">" & vbcrlf & "                <td height=""30"" colspan=""6"" style=""border:1px solid #c0ccdd"">" & vbcrlf & "                                     <div align=""right"">" & vbcrlf & "                                               "
		Response.write recCount
		Response.write "个&nbsp;|" & vbcrlf & "                                            "
		Response.write IIf(recCount = 0,0,pageIndex)
		Response.write "/"
		Response.write pageCount
		Response.write "页&nbsp;|" & vbcrlf & "                                            "
		Response.write pageSize
		Response.write "条信息/页&nbsp;" & vbcrlf & "                                              <INPUT onfocus='this.select()' title='输入正确的分页序号，按回车键执行分页' onkeypress=""return addrPageBoxKeyDown(this);"" maxLength=""8"" size=""3"" max="""
		Response.write pageCount
		Response.write """ value="""
		Response.write pageindex
		Response.write """>&nbsp;" & vbcrlf & "                                          <BUTTON class='oldbutton4' id=""addrPageJumpBtn"" onclick=""if(isNaN($(this).prev().val())) {return};addrPage(parseInt($(this).prev().val())>parseInt($(this).prev().attr('max'))?$(this).prev().attr('max'):$(this).prev().val(),$('#addr_pgsize').val());"">跳转</BUTTON>&nbsp;<BUTTON class='oldbutton' " & vbcrlf & "                                            "
		Response.write IIf(pageindex<=1," disabled='disabled'"," onclick='addrPage(1,$(""#addr_pgsize"").val());'")
		Response.write "" & vbcrlf & "                                             >首页</BUTTON>&nbsp;<BUTTON class='oldbutton' " & vbcrlf & "                                          "
		Response.write IIf(pageindex<=1," disabled='disabled'"," onclick='addrPage("&(pageindex-1)&",$(""#addr_pgsize"").val());'")
		Response.write "" & vbcrlf & "                                             >上一页</BUTTON>&nbsp;<BUTTON class='oldbutton' " & vbcrlf & "                                                "
		Response.write IIf(pageindex>=pageCount," disabled='disabled'"," onclick='addrPage("&(pageindex+1)&",$(""#addr_pgsize"").val());'")
		Response.write "" & vbcrlf & "                                             >下一页</BUTTON>&nbsp;<BUTTON class='oldbutton' " & vbcrlf & "                                                "
		Response.write IIf(pageindex>=pageCount," disabled='disabled'"," onclick='addrPage("&pageCount&",$(""#addr_pgsize"").val());'")
		Response.write "" & vbcrlf & "                                             >尾页</BUTTON>&nbsp;每页行数：" & vbcrlf & "                                          <SELECT style=""WIDTH:50px;"" id=""addr_pgsize"" onchange='addrPage(1,this.value);'>" & vbcrlf & ""
		Dim pgsizes : pgsizes = Split("3,5,10,15,20,30,50,100",",")
		For i = 0 To ubound(pgsizes)
			Response.write "" & vbcrlf & "                                                     <OPTION "
			Response.write IIf(pageSize&""=pgsizes(i),"selected","")
			Response.write " value="""
			Response.write pgsizes(i)
			Response.write """>"
			Response.write pgsizes(i)
			Response.write "</OPTION>" & vbcrlf & ""
		next
		Response.write "" & vbcrlf & "                                               </SELECT>行" & vbcrlf & "                                     </div>" & vbcrlf & "                          </td>" & vbcrlf & "                   </tr>" & vbcrlf & ""
		If mode = "top" And recCount > pageSize Then
			Dim base64Util : Set base64Util = server.createobject(ZBRLibDLLNameSN & ".base64Class")
			Dim encryptOrd : encryptOrd = base64Util.pwurl(ord)
			Set base64Util = Nothing
			Response.write "" & vbcrlf & "                       <tr>" & vbcrlf & "                            <td height=""30"" colspan=""6"" style=""border:1px solid #c0ccdd"" align=""right"">" & vbcrlf & "                                     <a href=""#"" onclick=""javascript:window.open('../work/moreAddress.asp?ordType="
			Response.write ordType
			Response.write "&ord="
			Response.write encryptOrd
			Response.write "','newwinAddr','width=1200,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');return false;"" ><font class=""red"">查看更多收货地址..&gt;&gt;&gt;</font></a>" & vbcrlf & "                               " & vbcrlf & "                                </td>" & vbcrlf & "                   </tr>" & vbcrlf & ""
		end if
		rs.close
		Set rs=Nothing
		Response.write "" & vbcrlf & "              </table>" & vbcrlf & ""
		If mode = "select" Then
		else
			Response.write "" & vbcrlf & "      <script>" & vbcrlf & "                $(function(){" & vbcrlf & "                   $('#personAddressList tbody tr:first').children().css('border-top','0px');" & vbcrlf & "                      $('#personAddressList tbody tr:last').children().css('border-bottom','0px');" & vbcrlf & "            });" & vbcrlf & "     </script>" & vbcrlf & ""
'If mode = "select" Then
		end if
	end sub
	
	Sub Page_Load
		Call WriteHeadHtml
		Dim dt : dt = request("dt")
		If dt = "" Then dt = Date
		Dim dtBegin,dtEnd
		dtBegin = request("dtBegin")
		dtEnd = request("dtEnd")
		If dtBegin = "" And dtEnd = "" Then
			dtBegin = (Date - Day(Date-1))
'If dtBegin = "" And dtEnd = "" Then
			dtEnd = Dateadd("d",-1,Dateadd("m",1,dtBegin))
'If dtBegin = "" And dtEnd = "" Then
		end if
		Response.write "" & vbcrlf & "      <script type='text/JavaScript' src='../inc/echarts.min.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write "'></script>" & vbcrlf & "   <table width=""100%""  border=""0"" align=""left"" cellpadding=""0"" cellspacing=""0""  bordercolor=""#E2E2E1"" bgcolor=""#FFFFFF"">" & vbcrlf & "                <tr>" & vbcrlf & "                    <td width=""100%"" valign=""top"">" & vbcrlf & "                              <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">"& vbcrlf &                       "               <tr> "& vbcrlf &                                 "            <td class=""place"" style=""height:40px!important;"">分析工作台</td>" & vbcrlf &                                 "            <td>&nbsp;</td> "& vbcrlf &                         "                 <td align=""right"">&nbsp;</td> "& vbcrlf &                   "                          <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "                                     </tr>" & vbcrlf & "                           </table>" & vbcrlf & "                                <form name=""form1"" id=""form1"" method=""get"" action='' style=""margin:0px"">" & vbcrlf & "                                <table width=""100%"" border=""0"" cellpadding=""1"" cellspacing=""0""  bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf &                              "     <tr height=""30px"" class=""top content-split-bar"">" & vbcrlf &                               "              <td> "& vbcrlf &                                "                     <div style=""float:left;padding-left:15px;height:100%;padding-top:3px;display:inline-block;vertical-align:middle"">" & vbcrlf &                                                "          <img class=""content-split-icon"" src=""../images/r_down.png"" style=""border:0px;width:14px;height:14px;""/>" & vbcrlf & "                                                          <span style=""margin-left:0px"">今日数量统计</span>" & vbcrlf & "                                                 </div>" & vbcrlf & "                                                  <div style=""float:left;margin-left:200px;text-align:center;padding-top:5px;"" onclick=""event.cancelBubble=true;"">" & vbcrlf & "                                                               <a href=""javascript:void(0);"" onClick=""$(this).next().val('"
		Response.write dateadd("d",-1,dt)
		Response.write "').trigger('change');event.cancelBubble=true;""> <img class=""resetElementHidden"" src=""../images/main_2.gif"" width=""8"" height=""8"" border=""0""/><img class=""resetElementShowNoAlign"" style=""display:none;"" src=""../skin/default/images/ico16/lvwbar_1_1.png"" width=""8"" height=""8"" border=""0""/> 前一天</a>" & vbcrlf & "                                                           <input type=""text"" class=""smdate"" name=""dt"" value="""
		Response.write dt
		Response.write """ onClick=""event.cancelBubble=true;""" & vbcrlf & "                                                                 onchange=""$('#form1').submit();"" align=""absMiddle"" " & vbcrlf & "                                                                 border=""0"" id=""daysOfMonth1Pos"" readOnly " & vbcrlf & "                                                                   onMouseUp=""datedlg.show();event.cancelBubble=true;"" style=""MARGIN-TOP:0px;HEIGHT:17px;width:79px;line-height:17px;padding-top:0px;"" " & vbcrlf & "                                                         />" & vbcrlf & "                                                              <a href=""javascript:void(0);"" onClick=""$(this).prev().val('"
		'Response.write dt
		Response.write dateadd("d",1,dt)
		Response.write "').trigger('change');event.cancelBubble=true;"">后一天 <img class=""resetElementHidden"" src=""../images/main_1.gif"" width=""8"" height=""8"" border=""0""/><img class=""resetElementShowNoAlign"" style=""display:none;"" src=""../skin/default/images/ico16/lvwbar_4_1.png"" width=""8"" height=""8"" border=""0""/></a>" & vbcrlf & "                                                       </div>" & vbcrlf & "                                          </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   <tr height=""30px"">" & vbcrlf & "                                                <td class=""td_hasTable"">" & vbcrlf & ""
		Dim qxlist : qxlist = app.power.getPowerIntro(108,11)
		Dim powerCondition,rs
		If qxlist = "" Then
			powerCondition = ""
		else
			powerCondition = " and a.cateid in (" & qxlist & ")"
		end if
		Dim newUserCnt,convertCnt,successCnt,unSubscribeCnt
		newUserCnt = cn.execute("select count(*) from MMsg_User a where datediff(d,createtime,'" & dt & "') = 0" & powerCondition)(0)
		convertCnt = cn.execute("select count(*) from MMsg_User a where datediff(d,bindTime,'" & dt & "') = 0" & powerCondition)(0)
		successCnt = cn.execute("" &_
		"select count(*) from MMsg_User a " & vbcrlf &_
		"inner join person b on a.person = b.ord " & vbcrlf &_
		"inner join tel c on b.company = c.ord " & vbcrlf &_
		"where 1=1 " & vbcrlf &_
		powerCondition & vbcrlf &_
		"and exists (select top 1 1 from contract where company=c.ord and datediff(d,date7,'" & dt & "') = 0 and del=1 and isnull(cateid_sp,0) = 0)  "& vbcrlf &_
		"and not exists (" & vbcrlf &_
		"select top 1 1 from contract where company=c.ord and datediff(d,date7,'" & dt & "') > 0 and del=1 and isnull(cateid_sp,0) = 0)" & vbcrlf &_
		"")(0)
		unSubscribeCnt = cn.execute("select count(*) from MMsg_User a where subscribe_stat <> 1 and datediff(d,unsubscribe_time,'" & dt & "') = 0 " & powerCondition)(0)
		Response.write "" & vbcrlf & "                                                      <table class=""detailTable"" cellpadding=""0"" cellspacing=""1"" border=""0"" width=""100%"" bgcolor=""#c0ccdd"" style=""margin:-1px"">" & vbcrlf & "                                                             <tr height=""30px"" class=""top"">" & vbcrlf & "                                                                      <td align=""center"" width=""25%""><strong>净增用户数量</strong></td>" & vbcrlf & "                                                                 <td align=""center"" width=""25%""><strong>转客户数量</strong></td>" & vbcrlf & "                                                                     <td align=""center"" width=""25%""><strong>成功数量</strong></td>" & vbcrlf & "                                                                       <td align=""center"" width=""25%""><strong>关注取消数量</strong></td>" & vbcrlf & "                                                           </tr>" & vbcrlf & "<tr height=""30px"">" & vbcrlf & "                                                                        <td align=""center"">" & vbcrlf & "                                                                               "
		Response.write app.iif(newUserCnt=0,"<span style='color:#dddddd'>0</span>","<a href='javascript:void(0);' onclick=""openUserList('dt="&dt&"&tp=newUser');"">" & newUserCnt & "</a>")
		Response.write "" & vbcrlf & "                                                                      </td>" & vbcrlf & "                                                                   <td align=""center"">" & vbcrlf & "                                                                               "
		Response.write app.iif(convertCnt=0,"<span style='color:#dddddd'>0</span>","<a href='javascript:void(0);' onclick=""openUserList('dt="&dt&"&tp=convert');"">" & convertCnt & "</a>")
		Response.write "" & vbcrlf & "                                                                      </td>" & vbcrlf & "                                                                   <td align=""center"">" & vbcrlf & "                                                                               "
		Response.write app.iif(successCnt=0,"<span style='color:#dddddd'>0</span>","<a href='javascript:void(0);' onclick=""openUserList('dt="&dt&"&tp=success');"">" & successCnt & "</a>")
		Response.write "" & vbcrlf & "                                                                      </td>" & vbcrlf & "                                                                   <td align=""center"">" & vbcrlf & "                                                                               "
		Response.write app.iif(unSubscribeCnt=0,"<span style='color:#dddddd'>0</span>","<a href='javascript:void(0);' onclick=""openUserList('dt="&dt&"&tp=unSubscribe');"">" & unSubscribeCnt & "</a>")
		Response.write "" & vbcrlf & "                                                                      </td>" & vbcrlf & "                                                           </tr>" & vbcrlf & "                                                   </table>" & vbcrlf & "                                                </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   <tr height=""30px"" class=""top content-split-bar"">" & vbcrlf & "                                            <td style=""border-bottom:0px ;"">" & vbcrlf & "                                                  <div style=""float:left;padding-left:15px;height:100%;padding-top:3px;display:inline-block;vertical-align:middle"">" & vbcrlf & "                                                               <img class=""content-split-icon"" src=""../images/r_down.png"" style=""border:0px;width:14px;height:14px;""/>" & vbcrlf & "                                                               <span style=""margin-left:0px"">累计数量统计</span>" & vbcrlf & "                                                        </div>" & vbcrlf & "                                                  <div style=""float:left;margin-left:100px;text-align:center;padding-top:5px;"" onclick=""event.cancelBubble=true;"">" & vbcrlf & "                                                            <input type=""text"" class=""smdate"" name=""dtBegin"" value="""
		Response.write dtBegin
		Response.write """ onClick=""event.cancelBubble=true;""" & vbcrlf & "                                                                 onchange=""$('#form1').submit();"" align=""absMiddle"" " & vbcrlf & "                                                                 border=""0"" id=""daysOfMonth1Pos"" readOnly " & vbcrlf & "                                                                   onMouseUp=""datedlg.show();event.cancelBubble=true;"" style=""MARGIN-TOP:0px;HEIGHT:17px;width:79px;line-height:17px;padding-top:0px;"" " & vbcrlf & "                                                         />" & vbcrlf & "                                                              至" & vbcrlf & "                                                              <input type=""text"" class=""smdate"" name=""dtEnd"" value="""
		'Response.write dtBegin
		Response.write dtEnd
		Response.write """ onClick=""event.cancelBubble=true;""" & vbcrlf & "                                                                 onchange=""$('#form1').submit();"" align=""absMiddle"" " & vbcrlf & "                                                                 border=""0"" id=""daysOfMonth1Pos"" readOnly " & vbcrlf & "                                                                   onMouseUp=""datedlg.show();event.cancelBubble=true;"" style=""MARGIN-TOP:0px;HEIGHT:17px;width:79px;line-height:17px;padding-top:0px;"" " & vbcrlf & "                                                         />" & vbcrlf & "                                                      </div>" & vbcrlf & "                                          </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   <tr height=""30px"">" & vbcrlf & "                                                <td class=""td_hasTable"">" & vbcrlf & ""
		'Response.write dtEnd
		Dim newUserCntTotal,convertCntTotal,successCntTotal,convertRate,successRate
		newUserCntTotal = cn.execute("select count(*) from MMsg_User a where 1=1 " & vbcrlf & _
		IIf(dtBegin&""<>""," and datediff(d,'" & dtBegin&"',createtime) >=0 ","") & vbcrlf & _
		IIf(dtEnd & ""<>""," and datediff(d,'" & dtEnd & "',createtime) <=0 ","") & vbcrlf & _
		powerCondition)(0)
		convertCntTotal = cn.execute("select count(*) from MMsg_User a where isnull(person,0) <> 0" & vbcrlf & _
		IIf(dtBegin&""<>""," and datediff(d,'" & dtBegin&"',bindTime) >=0 ","") & vbcrlf & _
		IIf(dtEnd & ""<>""," and datediff(d,'" & dtEnd & "',bindTime) <=0 ","") & vbcrlf & _
		powerCondition)(0)
		successCntTotal = cn.execute("" &_
		"select count(*) from MMsg_User a " & vbcrlf &_
		"inner join person b on a.person = b.ord " & vbcrlf &_
		"inner join tel c on b.company = c.ord " & vbcrlf &_
		"where exists (" & vbcrlf &_
		"select top 1 1 from contract where company=c.ord and del=1 and isnull(cateid_sp,0) = 0 " & vbcrlf &_
		IIf(dtBegin&""<>""," and datediff(d,'" & dtBegin&"',date7) >=0 ","") & vbcrlf & _
		IIf(dtEnd & ""<>""," and datediff(d,'" & dtEnd & "',date7) <=0 ","") & vbcrlf & _
		")" & vbcrlf &_
		IIf(dtBegin&""<>"" Or dtEnd&""<>""," and not exists (" & vbcrlf & _
		"select top 1 1 from contract where company=c.ord and del=1 and isnull(cateid_sp,0) = 0  "& vbcrlf & _
		"and datediff(d,date7,'" & IIf(dtBegin&""<>"",dtBegin,dtEnd) & "') > 0 " & vbcrlf & _
		")","") & vbcrlf &_
		IIf(dtBegin&""<>""," and datediff(d,'" & dtBegin&"',createtime) >=0 ","") & vbcrlf & _
		IIf(dtEnd & ""<>""," and datediff(d,'" & dtEnd & "',createtime) <=0 ","") & vbcrlf & _
		powerCondition)(0)
		If newUserCntTotal = 0 Then
			convertRate = FormatNumber(0,2,-1,0,0)
'If newUserCntTotal = 0 Then
		else
			convertRate = FormatNumber(CDbl(convertCntTotal) / CDbl(newUserCntTotal) * 100,2,-1,0,0)
'If newUserCntTotal = 0 Then
		end if
		Response.write "" & vbcrlf & "                                                     <table class=""detailTable"" cellpadding=""0"" cellspacing=""1"" border=""0"" width=""100%"" bgcolor=""#c0ccdd"" style=""margin:-1px"">" & vbcrlf & "                                                             <tr height=""30px"" class=""top"">" & vbcrlf & "                                                                      <td align=""center"" width=""20%""><strong>净增用户数量</strong></td>" & vbcrlf & "                                                                        <td align=""center"" width=""20%""><strong>转客户数量</strong></td>" & vbcrlf & "                                                                     <td align=""center"" width=""20%""><strong>转化率</strong></td>" & vbcrlf & "                                                                 <td align=""center"" width=""20%""><strong>成功数量</strong></td>" & vbcrlf & "                                                                       <td align=""center"" width=""20%""><strong>成功转化率</strong></td>" & vbcrlf & "                                                          </tr>" & vbcrlf & "                                                           <tr height=""30px"">" & vbcrlf & "                                                                        <td align=""center"">" & vbcrlf & "                                                                               "
		Response.write app.iif(newUserCntTotal=0,"<span style='color:#dddddd'>0</span>","<a href='javascript:void(0);' onclick=""openUserList('tp=newUser&dtBegin="&dtBegin&"&dtEnd="&dtEnd&"');"">" & newUserCntTotal & "</a>")
		Response.write "" & vbcrlf & "                                                                     </td>" & vbcrlf & "                                                                   <td align=""center"">" & vbcrlf & "                                                                               "
		Response.write app.iif(convertCntTotal=0,"<span style='color:#dddddd'>0</span>","<a href='javascript:void(0);' onclick=""openUserList('tp=convert&dtBegin="&dtBegin&"&dtEnd="&dtEnd&"');"">" & convertCntTotal & "</a>")
		Response.write "" & vbcrlf & "                                                                     </td>" & vbcrlf & "                                                                   <td align=""center"">"
		Response.write convertRate
		Response.write "%</td>" & vbcrlf & "                                                                       <td align=""center"">" & vbcrlf & "                                                                               "
		Response.write app.iif(successCntTotal=0,"<span style='color:#dddddd'>0</span>","<a href='javascript:void(0);' onclick=""openUserList('tp=success&dtBegin="&dtBegin&"&dtEnd="&dtEnd&"');"">" & successCntTotal & "</a>")
		Response.write "" & vbcrlf & "                                                                     </td>" & vbcrlf & ""
		If newUserCntTotal = 0 Then
			successRate = FormatNumber(0,2,-1,0,0)
'If newUserCntTotal = 0 Then
		else
			successRate = FormatNumber(CDbl(successCntTotal) / CDbl(newUserCntTotal) * 100,2,-1,0,0)
'If newUserCntTotal = 0 Then
		end if
		Response.write "" & vbcrlf & "                                                                     <td align=""center"">"
		Response.write successRate
		Response.write "%</td>" & vbcrlf & "                                                               </tr>" & vbcrlf & "                                                   </table>" & vbcrlf & "                                                </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   <tr height=""30px"" class=""top content-split-bar"">" & vbcrlf & "                                            <td>" & vbcrlf & "                                                    <div style=""float:left;padding-left:15px;height:100%;padding-top:3px;display:inline-block;vertical-align:middle"">" & vbcrlf & "                                                          <img class=""content-split-icon"" src=""../images/r_down.png"" style=""border:0px;width:14px;height:14px;""/>" & vbcrlf & "                                                               <span style=""margin-left:0px"">用户分布分析</span>" & vbcrlf & "                                                 </div>" & vbcrlf & "                                          </td>" & vbcrlf & "                                       </tr>" & vbcrlf & "                                   <tr height=""30px"">" & vbcrlf & "                                                <td id=""picDrawPanel"">" & vbcrlf & "                                            </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                           </table>" & vbcrlf & "                                </form>" & vbcrlf & "                 </td>" & vbcrlf & "           </tr>" & vbcrlf & "   </table>" & vbcrlf & "        <script>" & vbcrlf & "           $(function(){" & vbcrlf & "            if(window.sysConfig.BrandIndex == 3){$("".content-split-icon"").attr(""src"",""../skin/default/images/MoZihometop/content/r_down.png"")}" & vbcrlf & "                   $('.content-split-bar').click(function(e){" & vbcrlf & "                              var $o=$(this);" & vbcrlf & "                         var flg = $o.attr('flg')||""0"";" & vbcrlf & "                var src = """";" & vbcrlf & "                if(window.sysConfig.BrandIndex == 3){" & vbcrlf & "                    src = flg==""0""?""../skin/default/images/MoZihometop/content/r_up.png"":""../skin/default/images/MoZihometop/content/r_down.png"";" & vbcrlf & "                }else{" & vbcrlf & "                    src = flg==""0""?""../images/r_up.png"":""../images/r_down.png"";" & vbcrlf & "                }" & vbcrlf & "                              var $tr = $o.nextUntil('tr.content-split-bar,.content-split-foot');" & vbcrlf & "                             flg==""0""?$tr.hide():$tr.show();" & vbcrlf & "                              $o.attr('flg',flg==""0""?""1"":""0"").find('.content-split-icon').attr(""src"",src);" & vbcrlf & "                    }).find(':reset,:button,:submit').click(function(e){" & vbcrlf & "                            e.stopPropagation();" & vbcrlf & "                    });" & vbcrlf & "                     ajax.regEvent(""loadChart"");" & vbcrlf &"                });" & vbcrlf & "" & vbcrlf & "             window.virpath = '../';" & vbcrlf & "         function openUserList(param){" & vbcrlf & "                   window.OpenNoUrl('../MicroMsg/MUserList.asp?fromTj=1&'+param,'MUserList','width=' + 1200 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');" & vbcrlf & "         }" & vbcrlf & "       </script>" & vbcrlf & ""
        'Response.write "%</td>" & vbcrlf & "                                                               </tr>" & vbcrlf & "                                                   </table>" & vbcrlf & "                                                </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   <tr height=""30px"" class=""top content-split-bar"">" & vbcrlf & "                                            <td>" & vbcrlf & "                                                    <div style=""float:left;padding-left:15px;height:100%;padding-top:3px;display:inline-block;vertical-align:middle"">" & vbcrlf & "                                                          <img class=""content-split-icon"" src=""../images/r_down.png"" style=""border:0px;width:14px;height:14px;""/>" & vbcrlf & "                                                               <span style=""margin-left:0px"">用户分布分析</span>" & vbcrlf & "                                                 </div>" & vbcrlf & "                                          </td>" & vbcrlf & "                                       </tr>" & vbcrlf & "                                   <tr height=""30px"">" & vbcrlf & "                                                <td id=""picDrawPanel"">" & vbcrlf & "                                            </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                           </table>" & vbcrlf & "                                </form>" & vbcrlf & "                 </td>" & vbcrlf & "           </tr>" & vbcrlf & "   </table>" & vbcrlf & "        <script>" & vbcrlf & "           $(function(){" & vbcrlf & "            if(window.sysConfig.BrandIndex == 3){$("".content-split-icon"").attr(""src"",""../skin/default/images/MoZihometop/content/r_down.png"")}" & vbcrlf & "                   $('.content-split-bar').click(function(e){" & vbcrlf & "                              var $o=$(this);" & vbcrlf & "                         var flg = $o.attr('flg')||""0"";" & vbcrlf & "                var src = """";" & vbcrlf & "                if(window.sysConfig.BrandIndex == 3){" & vbcrlf & "                    src = flg==""0""?""../skin/default/images/MoZihometop/content/r_up.png"":""../skin/default/images/MoZihometop/content/r_down.png"";" & vbcrlf & "                }else{" & vbcrlf & "                    src = flg==""0""?""../images/r_up.png"":""../images/r_down.png"";" & vbcrlf & "                }" & vbcrlf & "                              var $tr = $o.nextUntil('tr.content-split-bar,.content-split-foot');" & vbcrlf & "                             flg==""0""?$tr.hide():$tr.show();" & vbcrlf & "                              $o.attr('flg',flg==""0""?""1"":""0"").find('.content-split-icon').attr(""src"",src);" & vbcrlf & "                    }).find(':reset,:button,:submit').click(function(e){" & vbcrlf & "                            e.stopPropagation();" & vbcrlf & "                    });" & vbcrlf & "                     ajax.regEvent(""loadChart"");" & vbcrlf & "                       $('#picDrawPanel')[0].innerHTML = ajax.PreScript(ajax.send());" & vbcrlf & "                });" & vbcrlf & "" & vbcrlf & "             window.virpath = '../';" & vbcrlf & "         function openUserList(param){" & vbcrlf & "                   window.OpenNoUrl('../MicroMsg/MUserList.asp?fromTj=1&'+param,'MUserList','width=' + 1200 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');" & vbcrlf & "         }" & vbcrlf & "       </script>" & vbcrlf & ""
		'Response.write successRate
		app.Log.remark = "分析工作台"
		Call WriteFootHtml
	end sub
	Sub App_loadChart
		Response.clear
		Dim qxlist : qxlist = app.power.getPowerIntro(108,11)
		Dim powerCondition,rs
		If qxlist = "" Then
			powerCondition = ""
		else
			powerCondition = " and a.cateid in (" & qxlist & ")"
		end if
		Response.write "" & vbcrlf & "                                                     <table  style=""BORDER-COLLAPSE:initial;WORD-WRAP:break-word;WORD-BREAK:break-all;width:100%"" " & vbcrlf & "                                                             border=0 cellPadding=""1"" align=""center"" id=""content1""" & vbcrlf & "                                                           cellpadding=""0"" cellspacing=""1"" border=""0"" width=""100%"" bgcolor=""#c0ccdd"" style=""margin:0px""" & vbcrlf &                               "                                > "& vbcrlf &                         "                                       <tr> "& vbcrlf &                           "                                          <td align=""center"" width=""50%""> "& vbcrlf
		Dim nullBackground
		Set rs = cn.execute("" & vbcrlf &_
		"select top 10 a.name,a.id,isnull(b.cnt,0) cnt from MMsg_Group a " & vbcrlf &_
		"left join (" & vbcrlf &_
		"select count(*) cnt,groupid from MMsg_User a where 1=1 " & powerCondition & " group by groupid " & vbcrlf &_
		") b on b.groupid = a.id" & vbcrlf &_
		"order by a.id desc,a.name")
		If rs.eof Then
			nullBackground = "background:url(../skin/default/images/ico_main_nodate.gif) no-repeat center center"
'If rs.eof Then
		else
			nullBackground = ""
		end if
		Response.write "" & vbcrlf & "                                                                             <div style=""height:400px;"
		Response.write nullBackground
		Response.write """>" & vbcrlf & ""
		If rs.eof = False Then
			Dim v : Set v = New VmlGraphics
			v.width = 350
			v.id = "groupinfo"
			v.height = 250
			v.title = ""
			v.url="../MicroMsg/MUserList.asp?fromTj=1&groupId=@ord"
			v.backgroundColor = ""
			v.backgroundBorder = "0px"
			v.loadDataByRecord rs
			v.draw "cone"
		end if
		rs.close
		Response.write "" & vbcrlf & "                                                                             </div>" & vbcrlf & "                                                                  </td>" & vbcrlf & "                                                                   <td style=""text-align:center;"">" & vbcrlf & ""
		v.draw "cone"
		Dim newUserCntTotal,convertCntTotal
		newUserCntTotal = cn.execute("select count(*) from MMsg_User a where 1=1 " & powerCondition)(0)
		convertCntTotal = cn.execute("select count(*) from MMsg_User a where isnull(person,0) <> 0" & powerCondition)(0)
		If newUserCntTotal + convertCntTotal = 0 Then
			nullBackground = "background:url(../skin/default/images/ico_main_nodate.gif) no-repeat center center"
		else
			nullBackground = ""
		end if
		Response.write "" & vbcrlf & "                                                                             <div style=""height:400px;"
		Response.write nullBackground
		Response.write """>" & vbcrlf & ""
		If newUserCntTotal + convertCntTotal <> 0 Then
			Response.write """>" & vbcrlf & ""
			Set v = New VmlGraphics
			Set rs = cn.execute("" & vbcrlf &_
			"select '已转数量' name,2,"& (convertCntTotal) &_
			" union all " & vbcrlf &_
			"select '未转数量' name,1," & (newUserCntTotal - convertCntTotal))
'union all  & vbcrlf &_
			v.width = 300
			v.id = "convertInfo"
			v.height = 250
			v.title = ""
			v.url="../MicroMsg/MUserList.asp?fromTj=1&st=@ord"
			v.backgroundColor = ""
			v.backgroundBorder = "0px"
			v.loadDataByRecord rs
			v.draw "pie"
			rs.close
		end if
		Response.write "" & vbcrlf & "                                                                             </div>" & vbcrlf & "                                                                  </td>" & vbcrlf & "                                                           </tr>" & vbcrlf & "                                                   </table>" & vbcrlf & ""
	end sub
	Sub WriteHeadHtml
		Response.write "" & vbcrlf & "<!DOCTYPE html>" & vbcrlf & "<html xmlns:v=""urn:schemas-microsoft-com:vml"" xmlns:o=""urn:schemas-microsoft-com:office:office"">" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<meta http-equiv=""X-UA-Compatible"" content=""IE=EmulateIE7"">" & vbcrlf & "<meta name=""""vs_targetSchema"""" content=""""http://schemas.microsoft.com/intellisense/ie5""""/>" & vbcrlf & "<title>分析工作台</title>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<script src=""../inc/dateid.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "<script src=""../inc/jquery-1.8.0.min.js?ver="
		'Response.write Application("sys.info.jsver")
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "<link href=""../inc/themes/default/easyui.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write """ rel=""stylesheet"" type=""text/css""/>" & vbcrlf & "<link href='../skin/default/css/ReportCls.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write "' rel='stylesheet' type='text/css'/>" & vbcrlf & "<script src='../skin/default/js/comm.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write "'></script>" & vbcrlf & "<script src='../skin/default/js/VmlGraphics.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write "'></script>" & vbcrlf & "<script type=""text/JavaScript"" src=""../inc/jquery.easyui.min.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "<link href=""../MicroMsg/css/MicroMsgList.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write """ rel=""stylesheet"" type=""text/css""/>" & vbcrlf & "<script type=""text/JavaScript"" src=""../skin/default/js/mg_MUserList.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & " <script type=""text/JavaScript"">" & vbcrlf & " window.sysConfig = {BrandIndex:"""
		Response.write application("sys.info.configindex")
		Response.write """};" & vbcrlf & " </script>" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "v\:* { Behavior: url(#default#VML) }" & vbcrlf & "o\:* { behavior: url(#default#VML) }" & vbcrlf & "body {" & vbcrlf & "  margin-top: 0px;" & vbcrlf & "        background-color: #FFFFFF;" & vbcrlf & "      margin-left: 0px;" &vbcrlf & "        margin-right: 0px;" & vbcrlf & "      margin-bottom: 0px;" & vbcrlf & "}" & vbcrlf & ".smdate {" & vbcrlf & "   width:96px!important;" & vbcrlf & "   height:18px;padding-left:4px;line-height:18px;" & vbcrlf & "  background:transparent url(../skin/default/images/datebg.gif);" & vbcrlf & "  background-repeat:no-repeat;" & vbcrlf & " filter: progid:DXImageTransform.Microsoft.AlphaImageLoader(src='../skin/default/images/datebg.gif',sizingMethod='scale');" & vbcrlf & "       border:1px solid #CCC;cursor:default;color:#000;font-size:14px;font-family:宋体;" & vbcrlf & "        background-position:78px 6px;" & vbcrlf & "}" & vbcrlf & ".nopadding{" & vbcrlf & " padding:0px!important;" & vbcrlf & "}" & vbcrlf & "#picDrawPanel{" & vbcrlf & "   padding-left:32px!important;" & vbcrlf & "}" & vbcrlf & "</style>" & vbcrlf & "</head>" & vbcrlf & "<body>" & vbcrlf & ""
		'Response.write application("sys.info.configindex")
	end sub
	Sub WriteFootHtml
		Response.write "" & vbcrlf & "     </body>" & vbcrlf & "</html>" & vbcrlf & ""
	end sub
	
%>
