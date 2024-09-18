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
	
	Class adSearchField
		Public fname
		Public fType
		Public fKey
		Public fSql
		Public fText
		Public fvisible
		Public fcanset
	End Class
	Class AdvanceSearchClass
		Dim n1 , n2, n3 , n4, n5
		Dim mgate
		Public openkzzdy
		Public fieldCount
		Public adSearchAutoHide
		private fields
		Private item
		Private Sub Class_Initialize()
			ReDim n1(0)  , n2(0), n3(0), n4(0), n5(0)
			fieldCount = 0
			adSearchAutoHide = False
			openkzzdy = false
			Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		end sub
		Public Function addSetField(fName, fType, fKey, fSql ,fvisible , fcanset )
			Call AddField(fName, fType, fKey,  fSql)
			item.fvisible = fvisible
			item.fcanset = fcanset
			Set addSetField = item
		end function
		Public Function GetField(index)
			Set GetField = fields.item(index)
		end function
		Public Sub AddField(fName, fType, fKey,  fSql)
			Set item = New adSearchField
			fields.add item
			item.fname = fname
			item.fType = fType
			item.fKey = fKey
			item.fSql = fSql
			ReDim Preserve n1(fieldCount), n2(fieldCount), n3(fieldCount), n4(fieldCount)
			n1(fieldCount) = fname
			n2(fieldCount) = fType
			n3(fieldCount) = fKey
			n4(fieldCount) = fSql
			fieldCount = fieldCount  + 1
'n4(fieldCount) = fSql
		end sub
		Public Sub AddField2(fName, fType, fKey,  fSql, fText)
			Set item = New adSearchField
			fields.add item
			item.fname = fname
			item.fType = fType
			item.fKey = fKey
			item.fSql = fSql
			item.fText = fText
			ReDim Preserve n1(fieldCount), n2(fieldCount), n3(fieldCount), n4(fieldCount), n5(fieldCount)
			n1(fieldCount) = fname
			n2(fieldCount) = fType
			n3(fieldCount) = fKey
			n4(fieldCount) = fSql
			n5(fieldCount) = fText
			fieldCount = fieldCount  + 1
'n5(fieldCount) = fText
		end sub
		Public Function GetNV(ByVal i, ByVal ii)
			Select Case i
			Case 0 :  GetNV = n1(ii)
			Case 1 :  GetNV = n2(ii)
			Case 2 :  GetNV = n3(ii)
			Case 3 :  GetNV = n4(ii)
			Case 4 :  GetNV = n5(ii)
			End select
		end function
		Public Function GetGates(ty)
			Dim W1,W2,W3, WT
			W1 = me.GetText("W1")
			W2 = me.GetText("W2")
			W3 = me.GetText("W3")
			WT = me.GetText("WT")
			If Len(mgate) > 0 Then
				getgates =  mgate
				Exit Function
			end if
			if len(w1 & w2 & w3) > 0 then
				If app.ismobile Then
					GetGates = getW_3("||" & w3,ty)
				else
					GetGates = getW_3(w1 & "|" & w2 & "|" & w3,ty)
				end if
			else
				GetGates = ""
			end if
		end function
		Public Function getW_3(ByVal Wlist, byval ty)
			Dim rs , r, uid
			uid = session("personzbintel2007")
			If Len(uid & "") = 0 Then uid = 0
			Wlist = Split(Replace(Wlist," ",""), "|")
			Set rs =  cn.execute("exec erp_comm_getW3 '" &  Wlist(0) & "','" &  Wlist(1) & "','" &  Wlist(2) &"'," & ty & "," & uid)
			while rs.eof = False
				r = r & rs.fields(0).value
				rs.movenext
				If rs.eof = False Then r = r & ","
			wend
			rs.close
			Set rs =  Nothing
			getW_3 = r
		end function
		Public Function GetText(keyName)
			GetText = request(keyname)
		end function
		Private Function getVirPath()
			Dim r
			r = "../../"
			on error resume next
			r = app.virPath
			getVirPath = r
		end function
		Private Sub doTreeChecksItem(dn, sql, pid)
			Dim v
			Dim rs : Set rs = cn.execute(Replace(sql, "@parentid", pid, 1, -1, 1))
'Dim v
			If rs.eof = False Then
				Response.write "<div id='tck_" & dn & "_" & pid & "_b' "
				If pid > 0 Then
					Response.write " style='padding-left:20px;clear:both;display:none'"
'If pid > 0 Then
				else
					Response.write " style=''"
				end if
				Response.write ">"
				While rs.eof = False
					v =  rs("id").value
					Response.write "<div style='float:left;'><pre style='display:inline'><input value='" & v & "' onclick='__as_tck_nck(this)' id='tck_" & dn & "_" & v & "' name='" & dn & "' type='checkbox'>" & rs("name").value & "</pre></div>"
					Call doTreeChecksItem(dn, sql, v )
					rs.movenext
				wend
				Response.write "<div><br></div></div>"
			end if
			rs.close
		end sub
		Private Sub loadStaticFile(ByVal fpath)
			on error resume next
			Dim data : data = app.sdk.file.readalltext(fpath)
			If InStr(1,data,".GetHtml(",1) > 0 Then
				If InStr(1,fpath,"search_area" & Application("__saas__company") & ".asp",1) > 0 then
					data =  ZBRuntime.SDK.DHL.GetHtml(cn, 0)
				ElseIf InStr(1,fpath, "search_area_Select" & Application("__saas__company") & ".asp",1)>0 Then
					data =  ZBRuntime.SDK.DHL.GetHtml(cn, 1)
				else
					data =  ZBRuntime.SDK.DHL.GetHtml(cn, 2)
				end if
				ZBRuntime.SDK.File.WriteAllText fpath, data
			end if
			Response.write data
			If Err.number <> 0 Then
				Response.write "无法加载文件“" & Replace(fpath & "", server.mappath("../"), "") & "”。"
				Err.clear
			end if
		end sub
		Public Sub doTreeChecks(ByVal dn, ByVal sql )
			Dim ocn
			ocn = cn.cursorlocation
			cn.cursorlocation = 3
			Call doTreeChecksItem(dn, sql, 0)
			cn.cursorlocation = ocn
		end sub
		Public function GetListInputHtml(ByVal fname, ByVal source, ByVal inputtype, ByVal checkedv)
			Dim htm(), ops, ops2, ik1, ik2,c,ii, ckv, v,rs
			If InStr(1,source, "options:",1) <> 1 Then
				Set rs =  cn.execute(Replace(Replace(source,"@sortsql",""),"sql:",""))
				If LCase(rs.fields(0).name) = "name" Or  LCase(rs.fields(1).name) = "name" Then
					ik1 = "name"
					ik2 = "value"
				else
					ik1 = 0
					ik2 = 1
				end if
				ii=0 : c = rs.recordcount
				If c =-1 Then c = 100
'ii=0 : c = rs.recordcount
				ReDim htm(c-1)
'ii=0 : c = rs.recordcount
				While Not rs.eof
					ckv = "" : v = rs.fields(ik2).value & ""
					If v & "" = checkedv Then ckv = "checked"
					If ii>c-1 Then c=c+100 : ReDim Preserve htm(c)
'If v & "" = checkedv Then ckv = "checked"
					htm(ii) = "<input value='" & v & "' " & ckv & " type='" & inputtype & "' name='c_" & Replace(fname,"@","") & "' id='c_" & Replace(fname,"@","") & "_" & ii & "'><label for='c_" & Replace(fname,"@","") & "_" & ii & "'>" &  rs.fields(ik1).value  & "</label>&nbsp;"
					ii = ii + 1
					rs.movenext
				wend
				rs.close
				set rs = nothing
			else
				ops = Split(Right(source, Len(source)-8),";")
				c = ubound(ops)
				ReDim htm(c)
				For ii = 0 To c
					If InStr(ops(ii) & "","=") > 0 Then
						ops2 = Split(ops(ii),"=")
						ckv = "" : v = ops2(0) & ""
						If v & "" = checkedv Then ckv = "checked"
						htm(ii) = "<input value='" & v & "' " & ckv & " type='" & inputtype & "' name='c_" & Replace(fname,"@","") & "' id='c_" & Replace(fname,"@","") & "_" & ii & "'><label for='c_" & Replace(fname,"@","") & "_" & ii & "'>" &  ops2(1)  & "</label>&nbsp;"
					end if
				next
			end if
			GetListInputHtml = Join(htm,"")
		end function
		Public Sub showButton
			Dim i, ii, rs,asing, fname, v, ops, ops2
			Dim  minvalue , maxvalue
			asing = request.querystring("asing")
			If asing <> "1" Then asing = 0
			asing  = int(asing)
			Response.write "" & vbcrlf & "             <script>" & vbcrlf & "                function sys_comm_adsearchchange(model){" & vbcrlf & "//                      if(document.getElementById(""commfieldsBox"")){" & vbcrlf & "//                           document.getElementById(""commfieldsBox"").style.display= (model==1 ? ""none"" : """");" & vbcrlf & "//                   };" & vbcrlf & "//                    if(document.getElementById(""asearchlinkBg"")){" & vbcrlf & "//                                document.getElementById(""asearchlinkBg"").style.display= (model==1 ? ""none"" : """");" & vbcrlf & "//                   };" & vbcrlf & "                      if(document.getElementById(""kh"")){" & vbcrlf & "                                document.getElementById(""kh"").style.display= (model==1 ? ""none"" : """");" & vbcrlf & "                       };" & vbcrlf & "                      if(document.getElementById(""toolbar1"")){" & vbcrlf & "                          document.getElementById(""toolbar1"").style.display= (model==1 ? ""none"" : """");" & vbcrlf & "                  };" & vbcrlf & "                      document.getElementById(""searchitemsbutton"").style.display=(mod"").value=model; "& vbcrlf & "//                        document.getElementById(""fieldsBox"").style{" & vbcrlf & "                   if(obj.keyCode == 13){" & vbcrlf & "                          searchClick();"
			If adSearchAutoHide Then
				Response.write "if(document.getElementById(""kh"")){document.getElementById(""kh"").style.display="""";};document.getElementById(""as_ing"").value=0;document.getElementById(""searchitemsbutton"").style.display=""block"";document.getElementById(""searchitemspanel"").style.display=""none"";"
			end if
			Response.write "" & vbcrlf & "                             obj.returnValue = false;" & vbcrlf & "                        } " & vbcrlf & "              }" & vbcrlf & "               </script>" & vbcrlf & "               <div style='color:#cc0000;position:absolute;top:40px;right:20px;cursor:pointer;"
			If asing = 1 Then Response.write "display:none"
			Response.write "' id='searchitemsbutton' onclick='sys_comm_adsearchchange(1)'><U><font class=""advanSearch"">高级检索</font></U></div>" & vbcrlf & "           <input type='hidden' name='asing' id='as_ing' value='"
			Response.write asing
			Response.write "'>" & vbcrlf & "           <div id='searchitemspanel' style='"
			If asing = 0 Then Response.write "display:none"
			Response.write "' onkeydown='EnterSubmit(event)'>"
			For i = 0 To fieldCount - 1
				Response.write "' onkeydown='EnterSubmit(event)'>"
				If LCase(n2(i)) = "hidden" Then
					Response.write "<input type=hidden name='hiddedatas' id='" & n3(i) & "' value=""" & Replace(n4(i),"""","&quot;") & """>"
				end if
			next
			Response.write "" & vbcrlf & "            <table border=""1"" bordercolor='#CCC' style='table-layout:fixed;width:100%;border-collapse:collapse;margin-bottom:10px;'>" & vbcrlf & "                   <tr><td style='border:0;height:0;' width='100px'></td><td style='border:0;height:0' ></td></tr>" & vbcrlf & "                 <tr>" & vbcrlf & "<td align='left' height='40px' colspan='2' style='border-top:0px;height:40px;' > "& vbcrlf &                                " <div style='color:#cc0000;float:left;cursor:pointer;height:40px;line-height:40px;' id='searchitemsbutton2'  onclick='sys_comm_adsearchchange(0)'><U class=""advanSearch"">正常检索</U></div>" & vbcrlf &"</td>" & vbcrlf & "                   </tr>"
			For i = 0 To fieldCount - 1
'</td> & vbcrlf &                    </tr>
				fname=n3(i)
				If LCase(n2(i)) <> "hidden" then
					Response.write "" & vbcrlf & "                     <tr>" & vbcrlf & "                            <td class='ad_sear_td' align='right' style='padding:6px;'>"
					Response.write n1(i)
					Response.write "：</td>" & vbcrlf & "                              <td class='asearchdatatd' style='padding:6px;line-height:20px;height:27px !important' id='sfields_"
					Response.write n1(i)
					Response.write n3(i)
					Response.write "' ftype='"
					Response.write LCase(n2(i))
					Response.write "'>" & vbcrlf & "                           "
					Select Case LCase(n2(i))
					Case "select"
					Dim ik1, ik2
					Response.write "&nbsp;<select name='" & n3(i) & "' id='" & n3(i) & "'>"
					If InStr(1,n4(i), "options:",1) <> 1 Then
						Set rs =  cn.execute(Replace(n4(i),"@sortsql",""))
						If LCase(rs.fields(0).name) = "name" Or  LCase(rs.fields(1).name) = "name" Then
							ik1 = "name"
							ik2 = "value"
						else
							ik1 = 0
							ik2 = 1
						end if
						Response.write "<option value=''>不限</option>"
						While Not rs.eof
							Response.write "<option value='" & rs.fields(ik2).value & "'>" & rs.fields(ik1).value & "</option>"
							rs.movenext
						wend
						rs.close
						set rs = nothing
					else
						Response.write "<option value=''>不限</option>"
						ops = Split(Right(n4(i), Len(n4(i))-8),";")
						Response.write "<option value=''>不限</option>"
						For ii = 0 To ubound(ops)
							ops2 = Split(ops(ii),"=")
							Response.write "<option value='" & ops2(0) & "'>" & ops2(1) & "</option>"
						next
					end if
					Case "gates"
					Call doGateList(1,GetGates(1),n3(i))
					Case "gates2"
					Call doGateList(2,GetGates(2),n3(i))
					Case "gates3"
					Call doGateList(3,GetGates(3),n3(i))
					Case "gates4"
					Call doGateList(4,GetGates(4),n3(i))
					Case "gategroup"
					Call doGroupList(1,GetGates(1),n3(i))
					Case "gategroup2"
					Call doGroupList(2,GetGates(2),n3(i))
					Case "gategroup3"
					Call doGroupList(3,GetGates(3),n3(i))
					Case "gategroup4"
					Call doGroupList(4,GetGates(4),n3(i))
					Case "gateoption"
					Call GroupOption(n5(i))
					Call doGateList(1,GetGates(1),n3(i))
					Case "wages"
					Call doWages()
					Case "khfl"
					Call doGatekhfl()
					Case "sortonehy"
					Call dosortonehy(i)
					Case "radios"
					Response.write GetListInputHtml(fname, n4(i), "radio", n5(i))
					Case "checks"
					Response.write GetListInputHtml(fname, n4(i), "checkbox", "")
					Case "khqy"
					Response.write "<div id=""khqy"">"
					on error resume next
					execute sdk.vbs("../manager/search_area" & Application("__saas__company") & ".asp")
					on error goto 0
					Response.write "</div>"
					Case "cpfl"
					dim dynStr
					dynStr="p"
					Response.write "<div id=""cplx"">"
					execute sdk.vbs("../manager/search_product.asp")
					Response.write "</div>"
					Case "months"
					If Len(n1(i)) = 0 Then n1(i) = "自："
					If ubound(v)>1 Then minvalue = v(2)
					If ubound(v)>2 Then maxvalue = v(3)
					Response.write "" & vbcrlf & "                                                     <table style='table-layout:auto;width:auto'><tr>" & vbcrlf & "                                                        <td style='padding:6px;'><input type='text' id='"
'If ubound(v)>2 Then maxvalue = v(3)
					Response.write n3(i)
					Response.write "_v_0' onmousedown='datedlg.showYearMonth(this)' minDate="""
					Response.write minValue
					Response.write """ maxDate="""
					Response.write maxvalue
					Response.write """ max readonly size='8' maxlength=10 value='"
					Response.write v(0)
					Response.write "'></td>" & vbcrlf & "                                                      <td>至：</td>" & vbcrlf & "                                                   <td><input type='text' id='"
					Response.write n3(i)
					Response.write "_v_1' onmousedown='datedlg.showYearMonth(this)' minDate="""
					Response.write minValue
					Response.write """ maxDate="""
					Response.write maxvalue
					Response.write """ readonly size='8' maxlength=10 value='"
					Response.write v(1)
					Response.write "'></td>" & vbcrlf & "                                                      </tr></table>" & vbcrlf & "                                                   "
					Case "date"
					Response.write "" & vbcrlf & "                                                     <div style='width:400px;'>" & vbcrlf & "                                                      <div style='float:left'><input type='text' id="""
					Response.write n3(i)
					Response.write "_0"" onmousedown='datedlg.show()' readonly size='13' maxlength=10 value='"
					Response.write v
					Response.write "'></div>" & vbcrlf & "                                                     </div>" & vbcrlf & "                                                  "
					Case "dates"
					If Len(n1(i)) = 0 Then n1(i) = "自："
					v = Split(n4(i) & ";;;",";")
					Response.write "" & vbcrlf & "                                                     <div style='width:400px;'>" & vbcrlf & "                                                      <div style='float:left'><input type='text' id="""
					Response.write n3(i)
					Response.write "_0"" onmousedown='datedlg.show()' readonly size='13' maxlength=10 value='"
					Response.write v(0)
					Response.write "'></div>" & vbcrlf & "                                                     <div style='float:left;width:24px;text-align:center;padding-left:6px;padding-top:3px'>至：</div>" & vbcrlf & "                                                        <div style='float:left'><input type='text' id="""
					Response.write v(0)
					Response.write n3(i)
					Response.write "_1"" onmousedown='datedlg.show()' readonly size='13' maxlength=10 value='"
					Response.write v(1)
					Response.write "'></div>" & vbcrlf & "                                                     </div>" & vbcrlf & "                                                  "
					Case "datetime","datetimes"
					If Len(n1(i)) = 0 Then n1(i) = "自："
					v = Split(n4(i) & ";;;",";")
					Response.write "" & vbcrlf & "                                                     <div style='width:400px;'>" & vbcrlf & "                                                      <div style='float:left'><input type='text' id="""
					Response.write n3(i)
					Response.write "_0"" onclick='window.event.cancelBubble=true;return false;' onmousedown='datedlg.showDateTime();window.event.cancelBubble=true;return false;' readonly size='18' maxlength=15 value='"
					Response.write v(0)
					Response.write "'></div>" & vbcrlf & "                                                     <div style='float:left;width:22px;text-align:center;padding-left:4px;padding-top:3px'>至：</div>" & vbcrlf & "                                                        <div style='float:left'><input type='text' id="""
					Response.write v(0)
					Response.write n3(i)
					Response.write "_1"" onclick='window.event.cancelBubble=true;return false;' onmousedown='datedlg.showDateTime();window.event.cancelBubble=true;return false;' readonly size='18' maxlength=15 value='"
					Response.write v(1)
					Response.write "'></div>" & vbcrlf & "                                                     </div>" & vbcrlf & "                                                  "
					Case "numsfile"
					If Len(n1(i)) = 0 Then n1(i) = "自："
					v = Split(n4(i) & ";;;",";")
					Response.write "" & vbcrlf & "                                                     <div style='width:400px;'>" & vbcrlf & "                                                      <div style='float:left'><input type='text' id="""
					Response.write n3(i)
					Response.write "_0"" onpropertychange='formatData(this,""float"")' size='10' maxlength=10 value='"
					Response.write v(0)
					Response.write "'></div>" & vbcrlf & "                                                     <div style='float:left;width:22px;text-align:center;'>-</div>" & vbcrlf & "                                                   <div style='float:left'><input type='text' id="""
					Response.write v(0)
					Response.write n3(i)
					Response.write "_1"" onpropertychange='formatData(this,""float"")' size='10' maxlength=10 value='"
					Response.write v(1)
					Response.write "'></div>" & vbcrlf & "                                                     <div style='float:left'><select name=""f_unit"" id = ""f_unit""><option value=0>B</option><option value=1 selected>KB</option><option value=2>MB</option></select></div>" & vbcrlf & "                                                        </div>" & vbcrlf & "                                                  "
					Case "moneys"
					If Len(n1(i)) = 0 Then n1(i) = "自："
					v = Split(n4(i) & ";;;",";")
					Response.write "" & vbcrlf & "                                                     <div style='width:400px;'>" & vbcrlf & "                                                      <div style='float:left'><input type='text' id="""
					Response.write n3(i)
					Response.write "_0"" onpropertychange='formatData(this,""money"")' cannull=""1"" size='10' maxlength=10 value='"
					Response.write v(0)
					Response.write "'></div>" & vbcrlf & "                                                     <div style='float:left;width:22px;text-align:center;'>-</div>" & vbcrlf & "                                                   <div style='float:left'><input type='text' id="""
					Response.write v(0)
					Response.write n3(i)
					Response.write "_1"" onpropertychange='formatData(this,""money"")' cannull=""1"" size='10' maxlength=10 value='"
					Response.write v(1)
					Response.write "'></div>" & vbcrlf & "                                                     </div>" & vbcrlf & "                                                  "
					Case "numbers"
					If Len(n1(i)) = 0 Then n1(i) = "自："
					v = Split(n4(i) & ";;;",";")
					Response.write "" & vbcrlf & "                                                     <div style='width:400px;'>" & vbcrlf & "                                                      <div style='float:left'><input type='text' id="""
					Response.write n3(i)
					Response.write "_0"" onpropertychange='formatData(this,""number"")' size='10' maxlength=10 value='"
					Response.write v(0)
					Response.write "'></div>" & vbcrlf & "                                                     <div style='float:left;width:22px;text-align:center;'>-</div>" & vbcrlf & "                                                   <div style='float:left'><input type='text' id="""
					Response.write v(0)
					Response.write n3(i)
					Response.write "_1"" onpropertychange='formatData(this,""number"")' size='10' maxlength=10 value='"
					Response.write v(1)
					Response.write "'></div>" & vbcrlf & "                                                     </div>" & vbcrlf & "                                                  "
					Case "ints"
					If Len(n1(i)) = 0 Then n1(i) = "自："
					v = Split(n4(i) & ";;;",";")
					Response.write "" & vbcrlf & "                                                     <div style='width:400px;'>" & vbcrlf & "                                                      <div style='float:left'><input type='text' id="""
					Response.write n3(i)
					Response.write "_0"" onpropertychange='formatData(this,""int"")' size='10' maxlength=10 value='"
					Response.write v(0)
					Response.write "'></div>" & vbcrlf & "                                                     <div style='float:left;width:22px;text-align:center;'>-</div>" & vbcrlf & "                                                   <div style='float:left'><input type='text' id="""
					Response.write v(0)
					Response.write n3(i)
					Response.write "_1"" onpropertychange='formatData(this,""int"")' size='10' maxlength=10 value='"
					Response.write v(1)
					Response.write "'></div>" & vbcrlf & "                                                     </div>" & vbcrlf & "                                                  "
					Case "treechecks"
					Call doTreeChecks(n3(i), n4(i))
					Case "text"
					Response.write "<input type=text id='" & n3(i) & "' name='" & n3(i) & "' value='" & request.querystring(n3(i)) & "'>"
					Case "selectys"
					If Len(n1(i)) = 0 Then n1(i) = "："
					v = Split(n4(i) & ";;;",";")
					Response.write "" & vbcrlf & "                        <SELECT id="""
					Response.write n3(i)
					Response.write "_0"" name="""
					Response.write n3(i)
					Response.write "_0"">" & vbcrlf & "                           <option value=""1"">包含</option>" & vbcrlf & "                           <option value=""2"">不包含</option>" & vbcrlf & "                           <option value=""3"">等于</option>" & vbcrlf & "                           <option value=""4"">不等于</option>" & vbcrlf & "                           <option value=""5"">以..开始</option>" & vbcrlf & "                           <option value=""6"">以..结束</option>" & vbcrlf & "                        </SELECT>&nbsp;<font color=""#FFFFFF"">：</font><input type=text id="""
					Response.write n3(i)
					Response.write "_1"" name="""
					Response.write n3(i)
					Response.write "_1"" value='"
					Response.write v(1)
					Response.write "'>" & vbcrlf & "                                           "
					Case "checkszt"
					Response.write "             " & vbcrlf & "                                <INPUT name=""checkszt"" id=""checkszt"" type=""checkbox""  value='1'/> 通过                " & vbcrlf & "                                <INPUT name=""checkszt"" id=""checkszt"" type=""checkbox""  value='-1'/> 未通过             " & vbcrlf & "                                <INPUT name=""checkszt"" id=""checkszt"" type=""checkbox""  value='2'/> 审批中         " & vbcrlf & "                                <INPUT name=""checkszt"" id=""checkszt"" type=""checkbox""  value='3'/> 待审批              " & vbcrlf & "                                <INPUT name=""checkszt"" id=""checkszt"" type=""checkbox""  value='4'/> 已归档              " & vbcrlf &"                         <INPUT name=""checkszt"" id=""checkszt"" type=""checkbox""  value='5'/> 部分归档" & vbcrlf & "                            <INPUT name=""checkszt"" id=""checkszt"" type=""checkbox""  value='6'/> 未归档                            " & vbcrlf & "                                          "
					Case "khqy"
					Call CreateKhqy
					Case "telcls"
					Call showtelCls()
					Case "paycls"
					Call showpayCls()
					Case "ckcls"
					Call showckCls()
					End Select
					Response.write "" & vbcrlf & "                             </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   "
				end if
			next
			Response.write "" & vbcrlf & "                     <tr>" & vbcrlf & "                            <td style='height:30px;'></td>" & vbcrlf & "                          <td style='height:30px;'>" & vbcrlf & "                                       &nbsp;<input type='button' value='检索' class='oldbutton' onclick='searchClick();"
			If adSearchAutoHide Then
				Response.write "if(document.getElementById(""kh"")){document.getElementById(""kh"").style.display="""";};document.getElementById(""as_ing"").value=0;document.getElementById(""searchitemsbutton"").style.display=""block"";document.getElementById(""searchitemspanel"").style.display=""none"";"
			end if
			Response.write "'>&nbsp;&nbsp;<input class='oldbutton' value='重填' type='reset' onclick=""resetClick()"">" & vbcrlf & "                               </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   </table>" & vbcrlf & "                </div>" & vbcrlf & "  "
		end sub
		Sub CreateKhqy
			Response.write "<div id=""khqy"">"
			Call loadStaticFile(server.mappath("../manager/search_area" & Application("__saas__company") & ".asp"))
			Response.write "</div>"
			Response.write "" & vbcrlf & "<script language='javascript'>" & vbcrlf & "       var data = ["
			Response.write request("A2")
			Response.write "];" & vbcrlf & "   if(data.length>0) {" & vbcrlf & "             var datastr = "",,"" + data.join("","") + "",""" & vbcrlf & "             var boxs = document.getElementsByName(""A2"");" & vbcrlf & "              for (var i = 0 ; i < boxs.length ;  i ++)" & vbcrlf & "               {" & vbcrlf & "                       var box = boxs[i];" & vbcrlf & "                      if(datastr.indexOf("","" + box.value + "","")>0)" & vbcrlf & "                   {" & vbcrlf & "                               box.click();" & vbcrlf & "                    }" & vbcrlf & "               }" & vbcrlf & "       }" & vbcrlf & "</script>" & vbcrlf & "      "
			Response.write request("A2")
		end sub
		Sub showtelCls
			Dim zbintel_sort_history, zbintel_sort1_history
			zbintel_sort_history=request("E")
			zbintel_sort1_history=request("F")
			dim i5, rs1, rs2
			i5=2
			set rs1=cn.execute("select * from sort4 order by ord")
			do until rs1.eof
				Response.write "<input name='E' type='checkbox' value='"& rs1("ord")&"' id='e" & i5& "' onClick=document.getElementById('u"& i5 &"').style.display=(this.checked==1?'':'none');checkAll2('"& i5& "') "
				if CheckPurview(zbintel_sort_history,trim(rs1("ord")))=True Then Response.write " checked='checked' "
				Response.write ">"& rs1("sort1") &" "
				Response.write "<div id='u"& i5 &"' "
				if CheckPurview(zbintel_sort_history,trim(rs1("ord")))=True  Then
					Response.write " style='border:1px  dotted  #ecf5ff;margin-left:20px;'"
'if CheckPurview(zbintel_sort_history,trim(rs1("ord")))=True  Then
				else
					Response.write " style='border:1px  dotted  #ecf5ff;display:none;margin-left:20px;' "
'if CheckPurview(zbintel_sort_history,trim(rs1("ord")))=True  Then
				end if
				Response.write ">"
				set rs2=cn.execute("select * from sort5  where sort1="&rs1("ord")&" order by ord")
				do until rs2.eof
					Response.write "<span><input name='F' type='checkbox' value='"& rs2("ord")&"' "
					if CheckPurview(zbintel_sort1_history,trim(rs2("ord")))=True Then Response.write " checked='checked' "
					Response.write ">"& rs2("sort2") &"</span>"
					rs2.movenext
				loop
				rs2.close
				Response.write "</div>"
				i5=i5+1
				rs1.movenext
			loop
			rs1.close
		end sub
		Sub showpayCls
			Dim zbintel_paysort, zbintel_paytype
			zbintel_paysort=request("paysort")
			zbintel_paytype=request("paytype")
			dim i5, rs1, rs2
			i5=2
			set rs1=cn.execute("select sort1,ord from sortonehy where gate2=41 order by gate1 desc")
			do until rs1.eof
				Response.write "<input name='paysort' type='checkbox' value='"& rs1("ord")&"' id='paysort" & i5& "' onClick=document.getElementById('pt"& i5 &"').style.display=(this.checked==1?'':'none'); "
				if CheckPurview(zbintel_paysort,trim(rs1("ord")))=True Then Response.write " checked='checked' "
				Response.write ">"& rs1("sort1") &" "
				Response.write "<div id='pt"& i5 &"' "
				if CheckPurview(zbintel_paysort,trim(rs1("ord")))=True  Then
					Response.write " style='border:1px  dotted  #ecf5ff;margin-left:20px;'"
'if CheckPurview(zbintel_paysort,trim(rs1("ord")))=True  Then
				else
					Response.write " style='border:1px  dotted  #ecf5ff;display:none;margin-left:20px;' "
'if CheckPurview(zbintel_paysort,trim(rs1("ord")))=True  Then
				end if
				Response.write ">"
				set rs2=cn.execute("select sort1,id from paytype where sort2="&rs1("ord")&" order by gate2 desc")
				do until rs2.eof
					Response.write "<span><input name='paytype' type='checkbox' value='"& rs2("id")&"' "
					if CheckPurview(zbintel_paytype,trim(rs2("id")))=True Then Response.write " checked='checked' "
					Response.write ">"& rs2("sort1") &"</span>"
					rs2.movenext
				loop
				rs2.close
				Response.write "</div>"
				i5=i5+1
				Response.write "</div>"
				rs1.movenext
			loop
			rs1.close
		end sub
		Sub showckCls
			If app.existsProc("app_sys_treeviewCallBack") Then
				Response.write "<input type=""checkbox""  id='cktreeack' onClick=""__tvw_checkboxSet('cktree',this.checked);"">全选<div style='height:160px;overflow:auto;overflow-x:hidden;position:relative'>"
'If app.existsProc("app_sys_treeviewCallBack") Then
				Dim tvw : Set tvw = New treeview
				tvw.id = "cktree"
				tvw.checkbox = True
				tvw.pagesize = 80
				tvw.defexplan = False
				tvw.pagedataemodel = "all"
				Call tvw.addAllNodes(tvw.nodes, "exec erp_selbox_createStoreNode " & sdk.Info.user & ",0,0,'',@parentid,@pagesize,@pageindex,0,''", false, 1, 0)
				Response.write tvw.HTML & "</div>"
			else
				Response.write "<span style='color:red'>未加载treeview.asp文件</span>"
			end if
		end sub
		Private Sub dosortonehy(ByVal i)
			Dim ii: ii = 0
			Dim rs, tmdata
			Set rs =  cn.execute("select sort1, ord  from sortonehy where gate2=" & n4(i) & " and del=1 order by gate1 desc")
			tmdata = Replace("," & request("asft_" & n3(i)) & ","," ","")
			While Not rs.eof
				ii = ii + 1
'While Not rs.eof
				Response.write "<input type='checkbox' name='" & "asft_" & n3(i) & "' id='"& "asft_" & n3(i) & "_" & ii & "' value='" & rs.fields(1).value & "'"
				If   InStr(tmdata, "," & rs.fields(1).value & ",") >0  Then
					Response.write " checked "
				end if
				Response.write "><label for='"& "asft_" & n3(i) & "'> " & rs.fields(0).value & "</label>&nbsp;"
				rs.movenext
			wend
			rs.close
			set rs = nothing
		end sub
		Private function getW1W2(strW3)
			dim rtnW1,rtnW2,frs,fsql
			rtnW1=""
			rtnW2=""
			if strW3<>"" then
				fsql="select sorce,sorce2 from gate where ord in ("&strW3&")"
				set frs=cn.execute(fsql)
				while not frs.eof
					if rtnW1="" then
						rtnW1=frs(0)
					else
						rtnW1=rtnW1&","&frs(0)
					end if
					if rtnW2="" then
						rtnW2=frs(1)
					else
						rtnW2=rtnW2&","&frs(1)
					end if
					frs.movenext
				wend
			end if
			if rtnW1="" then rtnW1="0"
			if rtnW2="" then rtnW2="0"
			getW1W2=rtnW1&";"&rtnW2
		end function
		Sub GroupOption(arr_text)
			Dim i, j, defCheck
			If arr_text&""<>"" Then
				arr_text = Split(arr_text,Chr(2))
				If ubound(arr_text) > 0 Then
					Response.write "<div style='height:27px; line-height:23px; '>"
'If ubound(arr_text) > 0 Then
					For j = 0 To ubound(arr_text)
						defCheck = ""
						If j = 0 Then defCheck = "checked"
						Response.write "<input type='radio' name='WT' id='WT"& j &"' value='"& j+1 &"' "& defCheck &">"& arr_text(j) &" &nbsp;"
'If j = 0 Then defCheck = "checked"
					next
					Response.write "</div>"
				end if
			end if
		end sub
		Sub doGateList(sort_zjjg,user_list, id)
			Call doGateListBase(sort_zjjg,user_list, id, true)
		end sub
		Public Sub doGroupList(sort_zjjg,user_list, id)
			Call doGateListBase(sort_zjjg,user_list, id, false)
		end sub
		Sub doGateListBase(sort_zjjg,user_list, id, showPerson)
			Dim rs1 , str_w1 , str_w2 , str_w3 , open_1_1
			Dim sql1, Correct_W1, Correct_W2, Correct_W3
			Dim rs8, sql, i, j6 , zhanshi2 , zk2, tmp
			Dim w1, w2, w3, zhanshi, zhanshi1, rs3, sql3, rs2, sql2
			Dim zhanshi3, zk3, zhanshi4
			Dim uid : uid = session("personzbintel2007")
			If Len(uid & "") = 0 Then uid = 0
			set rs1=server.CreateObject("adodb.recordset")
			sql1="select sort1,qx_open,w1,w2,w3 from power2  where cateid="& uid &" and sort1="&sort_zjjg&" "
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
			Dim basesql
			basesql="select ord,orgsid from gate where del=1 "&str_w3&""
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
			Response.write CBaseUserTreeHtml(basesql,"orgs", "W1","W2","W3",  Correct_W1  & "," & Correct_W2 , Correct_W1, Correct_W2,  Correct_W3)
		end sub
		Sub doWages()
			dim i5 ,rs1,rs2,sql1,sql2
			i5=2
			set rs1=server.CreateObject("adodb.recordset")
			If app.power.existsModel(39002) Then  sql1="select title,id ,gongzi from hr_gongziclass where del=0 "
			If app.power.existsModel(26000) And app.power.existsModel(26001) Then
				If Len(sql1)>0 Then sql1 = sql1 & " union all "
				sql1=  sql1 & "select '财务工资项目' as title , 0 as id,'' as gongzi "
			end if
			If Len(sql1)>0 Then sql1 = "select * from ("& sql1 &") a order by id "
			rs1.open sql1,cn,1,1
			if rs1.RecordCount<=0 then
				Response.write "&nbsp;"
			else
				do until rs1.eof
					Response.write "" & vbcrlf & "                             <div id=""wagediv"
					Response.write rs1("id")
					Response.write """ style=""border:0px dotted #000000;display:none; padding-left:20px;""></div>" & vbcrlf & "                         <input name=""wage"" type=""checkbox"" value="""
					Response.write rs1("id")
					Response.write rs1("id")
					Response.write """ id=""wages"
					Response.write i5
					Response.write """ onClick=document.getElementById('wage"
					Response.write rs1("id")
					Response.write "').style.display=(this.checked==1?'':'none');document.getElementById(""wagediv"
					Response.write rs1("id")
					Response.write """).style.display=(this.checked==1?'':'none');>"
					Response.write rs1("title")
					Response.write "<div  id=""wage"
					Response.write rs1("id")
					Response.write """ style=""border:0px  dotted  #000000;display:none;padding-left:20px;"">" & vbcrlf & "                              "
					Response.write rs1("id")
					set rs2=server.CreateObject("adodb.recordset")
					sql2="select sort1,id from (select sort1,id,gate1 from sortwages union all select '财务计件工资',-1,-1) a  where (charindex(','+cast(id as varchar(20))+',',',"& rs1("gongzi") &",')>0 or "& rs1("id") &"=0)order by gate1 desc,sort1 asc "
'set rs2=server.CreateObject("adodb.recordset")
					rs2.open sql2,cn,1,1
					if rs2.RecordCount<=0 then
						Response.write "&nbsp;"
					else
						do until rs2.eof
							Response.write "<input name='wsort' type='checkbox' value='"
							Response.write rs2("id")
							Response.write "'>"
							Response.write rs2("sort1")
							rs2.movenext
						loop
					end if
					rs2.close
					set rs2=nothing
					Response.write "" & vbcrlf & "                             </div>" & vbcrlf & "                          "
					i5=i5+1
					Response.write "" & vbcrlf & "                             </div>" & vbcrlf & "                          "
					rs1.movenext
				loop
			end if
			rs1.close
			set rs1=nothing
		end sub
		Sub doGatekhfl()
			dim i5 ,rs1,rs2,sql1,sql2
			i5=2
			set rs1=server.CreateObject("adodb.recordset")
			sql1="select * from sort4  order by ord"
			rs1.open sql1,cn,1,1
			if rs1.RecordCount<=0 then
				Response.write "&nbsp;"
			else
				do until rs1.eof
					Response.write "" & vbcrlf & "                             <input name=""E"" type=""checkbox"" value="""
					Response.write rs1("ord")
					Response.write """ id=""e"
					Response.write i5
					Response.write """ onClick=document.getElementById('u"
					Response.write i5
					Response.write "').style.display=(this.checked==1?'':'none');checkAll2("""
					Response.write i5
					Response.write """)>"
					Response.write rs1("sort1")
					Response.write "<div   id=""u"
					Response.write i5
					Response.write """ style=""border:1px  dotted  #000000;display:none;"">" & vbcrlf & "                                "
					set rs2=server.CreateObject("adodb.recordset")
					sql2="select * from sort5  where sort1="&rs1("ord")&" order by ord"
					rs2.open sql2,cn,1,1
					if rs2.RecordCount<=0 then
						Response.write "&nbsp;"
					else
						do until rs2.eof
							Response.write "" & vbcrlf & "                                             <span class='gray'><input name='F' type='checkbox' value='"
							Response.write rs2("ord")
							Response.write "'>"
							Response.write rs2("sort2")
							Response.write "</span>" & vbcrlf & "                                              "
							rs2.movenext
						loop
					end if
					rs2.close
					set rs2=nothing
					Response.write "" & vbcrlf & "                             </div>" & vbcrlf & "                          "
					i5=i5+1
					Response.write "" & vbcrlf & "                             </div>" & vbcrlf & "                          "
					rs1.movenext
				loop
			end if
			rs1.close
			set rs1=nothing
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
		Public Sub addZdyFields(zdyId)
			Dim i , rs, gl , db
			i = 0
			Set rs = cn.execute("select title,name,sort,set_open,gl,js from zdy where sort1=" & zdyId & " order by gate1")
			While rs.eof = False
				i = i + 1
'While rs.eof = False
				db = Replace(rs.fields("name"),"zdy","zdy" & zdyid & "_")
				If rs.fields("set_open").value = 1 And  rs.fields("js").value = 1 Then
					gl = rs.fields("gl").value
					If gl > 0 Then
						addField rs.fields("title").value, "checks", db ,"select sort1,ord from sortonehy where gate2=" & gl
					else
						addField rs.fields("title").value, "text", db ,""
					end if
				else
					addField "", "hidden", db ,""
				end if
				rs.movenext
			wend
			rs.close
		end sub
		Public Sub addKzZdyFields(zdyId)
			Dim i , rs, gl , db : i = 0
			openkzzdy =  true
			Set rs = cn.execute("select ID, FName, FType, OptionID from ERP_CustomFields where TName=" & zdyid & " and CanSearch=1 and isusing=1 order by FOrder")
			While rs.eof = False
				gl = CLng("0" & rs.fields("optionID").value)
				db = "A_dFx_" & zdyid & "_" & rs("ID").value
				If rs("FType").value=7 Then
					addField rs.fields("FName").value, "checks", db ,"select CValue ,CValue as ord from ERP_CustomOptions where CFID=" & rs("ID").value
				else
					Select Case rs("FType").value
					Case 3:
					addField rs.fields("FName").value, "dates", db ,""
					Case 4:
					addField rs.fields("FName").value, "numbers", db ,""
					Case 6:
					addField rs.fields("FName").value, "checks", db ,"select '是' as sort1,  '是' as ord union all select '否' as sort1, '否' as ord"
					Case else:
					addField rs.fields("FName").value, "text", db ,""
					End Select
				end if
				rs.movenext
			wend
			rs.close
		end sub
		Public Sub dispose
			fields.dispose
			Set fields = nothing
		end sub
	End Class
	
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
	
	Response.write "<!--上传文件模块开始-->"
	Dim xmlPath,allowExts
	xmlPath = "../../sysa/document/upload/" & Timer & ".xml"
	allowExts = "|doc|docx|ppt|pptx|xls|xlsx|avi|bmp|jpeg|png|rmvb|gif|jpg|txt|pdm|zip|7z|rar|iso|apk|pdf|dwg|pptx|dwt|exb|eps|wmf|jfif|tif|tiff|xmind|psd|swf|mpeg|mp4|mov|flv|3gp|mp3|PDF|wps|"
	Response.write "" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "/*#bg{ display:none;position:absolute;top:0%;left:0%;width:100%;height:100%;background-color:#B9C5DD;z-index:1001;-moz-opacity:0.7;opacity:.70;filter:alpha(opacity=50);}" & vbcrlf & "*/" & vbcrlf & ".progress {" & vbcrlf & "    position: absolute;" & vbcrlf & "    filter:alpha(opacity=80);" & vbcrlf & "    padding: 4px;" & vbcrlf & "    top: 50px;" & vbcrlf & "    left: 400px;" & vbcrlf & "    font-family: Verdana, Helvetica, Arial, sans-serif;" & vbcrlf & "    font-size: 9px;" & vbcrlf & "    z-index:1002px;" & vbcrlf & "    width: 250px;" & vbcrlf & "    height:100px;" & vbcrlf & "    background: #DAEAFA;" & vbcrlf & "    color: #3D2C05;" & vbcrlf & "    border: 1px solid #715208;" & vbcrlf & "    /* Mozilla proprietary */" & vbcrlf & "    -moz-border-radius: 5px;" & vbcrlf & "    /*-moz-opacity: 0.95; */" & vbcrlf & "}" & vbcrlf & ".progress table,.progress td{" & vbcrlf & "  font-size:9pt;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".Bar{" & vbcrlf & "  width:100%;" & vbcrlf & "    height:13px;" & vbcrlf & "    background-color:#CCCCCC;" & vbcrlf & "    border: 1px inset #666666;" & vbcrlf & "    margin-bottom:4px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".ProgressPercent{" & vbcrlf & "    font-size: 9pt;" & vbcrlf & "    color:#FFFFFF;" & vbcrlf & "    height: 13px;" & vbcrlf & "      line-height:13px; " & vbcrlf & "    position: absolute;" & vbcrlf & "    z-index: 20;" & vbcrlf & "    width: 100%;" & vbcrlf & "    text-align: center;      " & vbcrlf & "}" & vbcrlf & ".ProgressBar{" & vbcrlf & "  background-color:blue;" & vbcrlf & "    width:1px;" & vbcrlf & "    height:13px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "#sash_left { width:430px; float:left; }" & vbcrlf & "#sash_left ul { text-align:left; vertical-align:middle; padding-left:75px; }" & vbcrlf & "#sash_left ul li { line-height:16px; margin:2px 0; }" & vbcrlf & ".b1, .b2, .b3, .b4 { font-size:1px; overflow:hidden; display:block; }" & vbcrlf & ".b1 { height:1px; background:#aaa; margin:0 5px; }" & vbcrlf & ".b2 { height:1px; background:url(../sysa/../images/up_1.gif); border-right:2px solid #AAA; border-left:2px solid #AAA; margin:0 3px; }" & vbcrlf & ".b3 { height:1px; background:url(../sysa/../images/up_1.gif); border-right:1px solid #AAA; border-left:1px solid #AAA; margin:0 2px; }" & vbcrlf & ".b4 { height:2px; background:url(../sysa/../images/up_1.gif); border-right:1px solid #AAA; border-left:1px solid #AAA; margin:0 1px; }" & vbcrlf & ".contentb { height:99px; background:url(../sysa/../images/up_1.gif); border-right:1px solid #AAA; border-left:1px solid #AAA; }" & vbcrlf & "</style>" & vbcrlf & "<div id=""fupload"" style=""position:absolute;display:none;width:300px;box-shadow:0 0 10px #666;background:#bbb"">" & vbcrlf & "        <b class=""b1""></b><b class=""b2""></b><b class=""b3""></b><b class=""b4""></b>" & vbcrlf & "        <div class=""contentb"" style=""padding-left:10px;padding-top:10px;padding-right:10px"">" & vbcrlf & "                <form name=""upform2"" method=""post"" action=""ProcUpload.asp?opt=Upload&xmlPath="
	Response.write xmlPath
	Response.write """ onsubmit=""return chkFrm();"" enctype=""multipart/form-data"" target=""if1"" style=""margin:0;padding:0;"">" & vbcrlf & "                      <div class=""reseetTextColor"" style=""float:right;cursor:pointer"" onmouseover=""this.style.color='red'"" onmouseout=""this.style.color='#2F496E';"" onclick=""document.getElementById('fupload').style.display='none';"" id=""fclose"">关闭</div>" & vbcrlf & "                   <div class=""reseetTextColor"" style=""font-weight:bolder"">文件上传</div>" & vbcrlf & "                      <div class=""reseetTextColor"" style=""height:40px;position:absolute"">选择文件：<input type=""text"" id=""txt"" disabled style=""width:150px"" name=""txt"" />" & vbcrlf & "                             <input type=""button"" name=""sbtn"" id=""sbtn"" value=""浏览"" class=""oldbutton"" style=""margin:0""><input type=""file"" name=""filefield"" id=""filefield""  hidefocus=""hidefocus"" onclick=""sbtn.click"" style=""filter:alpha(opacity=0);-moz-opacity:0;opacity:0;position:relative;top:-23px;left:60px;"" onchange=""txt.value=this.value"">" & vbcrlf & "                       </div>" & vbcrlf & "                  <div class=""reseetTextColor"" style=""position:absolute;top:72px;color:#5B7CAE"">文件描述：<input type=""text"" style=""width:150px"" name=""filedesc"">" & vbcrlf & "                           <inputtype=""submit"" value=""上传"" class=""oldbutton"" style='border:1px solid #EFEFEF;margin:0'>" & vbcrlf & "                           <input type=""hidden"" name=""edit"" value=""0"" id=""edit"">" & vbcrlf & "                           <input type=""hidden"" name=""fid"" value=""0"" id=""fid"">" & vbcrlf & "                             <input type=""hidden"" name=""pageType"" value=""0"" id=""pageType"">" & vbcrlf & "                        </div>" & vbcrlf & "          </form>" & vbcrlf & " </div>" & vbcrlf & "  <b class=""b4""></b><b class=""b3""></b><b class=""b2""></b><b class=""b1""></b>" & vbcrlf & "</div>" & vbcrlf & "<iframe name=""if1"" style=""width:100px;height:100px;display:none"" src=""""></iframe>" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "" & vbcrlf & "var allowExts="""
	Response.write allowExts
	Response.write """;" & vbcrlf & "var findex = 0;" & vbcrlf & "function addAtt(strName,strSize,strDesc,strDelLink)" & vbcrlf & "{" & vbcrlf & "      var tbobj=document.getElementById(""atttb"");" & vbcrlf & "       if(tbobj.rows.length==0)" & vbcrlf & "        {" & vbcrlf & "               var th=tbobj.insertRow(-1);" & vbcrlf & "             th.className="""";" & vbcrlf & "               th.style.height=""25px""" & vbcrlf & "            var th1=th.insertCell(-1);" & vbcrlf & "              var th2=th.insertCell(-1);" & vbcrlf & "              var th3=th.insertCell(-1);" & vbcrlf & "              var th4=th.insertCell(-1);" & vbcrlf & "              var th5=th.insertCell(-1);" & vbcrlf & "              th1.innerHTML=""<center><span class='reseetTextColor' style='font-weight:bolder'>文件名</span></center>"";" & vbcrlf & "         th2.innerHTML=""<center><span class='reseetTextColor' style='font-weight:bolder'>文件大小</span></center>"";" & vbcrlf & "                th3.innerHTML=""<center><span class='reseetTextColor' style='font-weight:bolder'>文件描述</span></center>"";" & vbcrlf & "                th4.innerHTML=""<center><span class='reseetTextColor' style='font-weight:bolder'>有效期限</span></center>"";" & vbcrlf & "                th5.innerHTML=""<center><span class='reseetTextColor' style='font-weight:bolder'>删除</span></center>"";" & vbcrlf & "    }" & vbcrlf & "       findex = $ID(""maxfindex"").value;" & vbcrlf & "   findex = findex*1 + 1;" & vbcrlf & "  $ID(""maxfindex"").value = findex;" & vbcrlf & "  var newtr=tbobj.insertRow(-1);" & vbcrlf & "  var newcell1=newtr.insertCell(-1);" & vbcrlf & "      var newcell2=newtr.insertCell(-1);" & vbcrlf & "      var newcell3=newtr.insertCell(-1);"& vbcrlf &      "var newcell4=newtr.insertCell(-1);" & vbcrlf &       "var newcell5=newtr.insertCell(-1);" & vbcrlf &       "var l_validity = $(""input[name=validity]:checked"").val();" & vbcrlf &  "var strdiv = "";" & vbcrlf &   "var strc1 = "";" & vbcrlf &    "var strc2 = "";" & vbcrlf &    "var l_date3 = "";" & vbcrlf &         "var l_date4 = "";" & vbcrlf &  "var sec = 0;" & vbcrlf &     "var msg = ""选择起止日期"";" & vbcrlf &  "if (l_validity==""2"")" & vbcrlf &       "{" & vbcrlf &                "strc2 = ""checked=\""checked\"";" & vbcrlf &               "strdiv = ""display:inline;"";" & vbcrlf &                "sec = $ID(""shortSec"").value;" & vbcrlf & "            msg = $ID(""shortSec"").getAttribute(""msg"");" & vbcrlf & "          l_date3 =  $ID(""date3"").value;" & vbcrlf & "            l_date4 =  $ID(""date4"").value;" & vbcrlf & "    }else{" & vbcrlf & "          strc1 = ""checked=\""checked\"""";" & vbcrlf & "              strdiv = ""display:none;"";" & vbcrlf & "         sec = 2;" & vbcrlf& "" & vbcrlf & "        }" & vbcrlf & "       var strvalidity = ""<input  name=\""l_validity""+ findex +""\"" id=\""l_validity""+ findex +""\"" value=\""1\""  type=radio  onclick=\""change_l(""+ findex +"")\"" ""+ strc1+""> 永久 <input  name=\""l_validity""+ findex +""\"" id=\""l_validity""+ findex +""\""  type=radio  onclick=\""change1_l(""+ findex +"")\"" value=\""2\"" ""+ strc2+"">短期&nbsp;<div id=\""l_mxh""+ findex +""\"" style=\""""+ strdiv +""\""><input name=\""l_date3_""+ findex +""\"" type=\""text\""   id=\""l_date3_""+ findex +""\"" size=\""10\"" maxlength=\""50\"" Class=\""DatePick\"" style=\""width:70px;\""  onclick=\""datedlg.show();\"" onChange=\""secShortDate_l(""+ findex +"")\"" readonly=\""readonly\"" value=\""""+l_date3+""\""> 至 <input name=\""l_date4_""+ findex +""\"" type=\""text\"" id=\""l_date4_""+ findex +""\"" size=\""10\"" maxlength=\""50\"" Class=\""DatePick\"" style=\""width:70px;\""  onclick=\""datedlg.show();\"" onChange=\""secShortDate_l(""+ findex +"")\"" readonly=\""readonly\"" value=\""""+l_date4+""\""><input type=\""hidden\"" name=\""shortSec""+findex+""\"" id=\""shortSec""+findex+""\"" value=\"""" + sec + ""\"" dataType=\""Range\"" min=2 max=2  msg=\""""+ msg +""yle='font-weight:lighter'>""+strName+""</span></center>"";" & vbcrlf & "     newcell2.style.paddingLeft=""20px"";" & vbcrlf & "        newcell2.style.paddingRight=""20px"";" & vbcrlf & "       newcell2.innerHTML=""<center><span class='reseetTextColor' style='font-weight:lighter'>""+strSize+""</span></center>"";" & vbcrlf & "   newcell3.style.paddingLeft=""20px"";" & vbcrlf & "        newcell3.style.paddingRight=""20px"";" & vbcrlf & "       newcell3.innerHTML=""<center><span class='reseetTextColor' style='font-weight:lighter;word-break:break-all'>""+strDesc+""</span></center>"";" & vbcrlf & "    newcell4.style.paddingLeft=""10px"";" & vbcrlf & "       newcell4.style.paddingRight=""10px"";" & vbcrlf & "       newcell4.innerHTML=""<span class='reseetTextColor' style='font-weight:lighter'>""+strvalidity+""</span>"";" & vbcrlf & "      newcell5.style.paddingLeft=""20px"";" & vbcrlf & "        newcell5.style.paddingRight=""20px"";" & vbcrlf & "       newcell5.innerHTML=""<center><span style='font-weight:lighter'>""+strDelLink+""</span></center>"";" & vbcrlf & "        var tmpFrame;" & vbcrlf & "   if(tmpFrame=parent.document.getElementById(""cFF"")){tmpFrame.style.height=document.body.scrollHeight+0+""px"";}" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function change_l(index){" & vbcrlf & "     $ID(""l_mxh""+index).style.display=""none"";" & vbcrlf & "    $ID(""shortSec""+index+"""").value=2;" & vbcrlf & "}" & vbcrlf & "function change1_l(index){" & vbcrlf & "        $ID(""l_mxh""+index).style.display=""inline"";" & vbcrlf & "  secShortDate_l(index);" & vbcrlf & "}" & vbcrlf & "function secShortDate_l(index){" & vbcrlf & "    var beginDate=$ID(""l_date3_""+ index +"""").value;" & vbcrlf & "     var endDate=$ID(""l_date4_""+ index +"""").value;" & vbcrlf & "       if(beginDate!="""" && endDate!=""""){" & vbcrlf & "           $ID(""shortSec""+index+"""").value=2;" & vbcrlf & "           var d1 = new Date(beginDate.replace(/\-/g, ""\/""));" & vbcrlf & "              var d2 = new Date(endDate.replace(/\-/g, ""\/""));" & vbcrlf & "          if(d1>=d2){" & vbcrlf & "                     $ID(""shortSec""+index+"""").value=1;" & vbcrlf & "                   $ID(""shortSec""+index+"""").setAttribute(""msg"",""开始时间不能大于或等于结束时间"");" & vbcrlf & "          }" & vbcrlf & "   }else{" & vbcrlf & "          $ID(""shortSec""+index+"""").value=1;" & vbcrlf & "           $ID(""shortSec""+index+"""").setAttribute(""msg"",""选择起止日期"");" & vbcrlf & "    }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function delRow(obj,ord,actionac)" & vbcrlf & "{" & vbcrlf & "    var xmlhttp = createXMLHttps();"& vbcrlf &      "if(confirm(""确定要删除此文件吗（删除后不可恢复）？""))" & vbcrlf &      "{" & vbcrlf &                "var trobj=obj.parentElement.parentElement.parentElement.parentElement;" & vbcrlf &           "var hidobj=trobj.getElementsByTagName(""input"")" & vbcrlf &             "var fname=hidobj[0].value;" & vbcrlf &               "var foname=hidobj[1].value;" & vbcrlf & "           var ajaxurl=""ProcDelFile.asp?t=0&ord=""+ord+""&f=""+escape(foname+""/""+fname)+""&actionac=""+actionac+""&t=""+Math.random();" & vbcrlf & "              xmlhttp.open(""GET"",ajaxurl,true);" & vbcrlf & "         xmlhttp.send(null);" & vbcrlf & "             xmlHttp.onreadystatechange = function(){" & vbcrlf & "if (xmlHttp.readyState < 4) {" & vbcrlf & "           }" & vbcrlf & "               if (xmlHttp.readyState == 4) {" & vbcrlf & "          var response = xmlHttp.responseText.split(""</noscript>"")[1];" & vbcrlf & "              xmlHttp.abort();" & vbcrlf & "                }" & vbcrlf & "               };" & vbcrlf & "              //              xmlHttp.send(null);" & vbcrlf & "             trobj.parentElement.removeChild(trobj);" & vbcrlf & "            var tbobj=document.getElementById(""atttb"");" & vbcrlf & "               if(tbobj.rows.length==1) tbobj.deleteRow(0);" & vbcrlf & "    }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function GetCurObjectPos(element){" & vbcrlf & "    if(arguments.length !=1||element==null){return null;}" & vbcrlf & "      var elmt=element;" & vbcrlf & "       var offsetTop=elmt.offsetTop;" & vbcrlf & "   var offsetLeft=elmt.offsetLeft;" & vbcrlf & " var offsetWidth=elmt.offsetWidth;" & vbcrlf & "       var offsetHeight=elmt.offsetHeight;" & vbcrlf & "     while (elmt=elmt.offsetParent){if(elmt.style.position=='absolute'||elmt.style.position=='relative'" & vbcrlf & "     || (elmt.style.overflow!='visible'&&elmt.style.overflow !='')){break;}" & vbcrlf & "  offsetTop+=elmt.offsetTop;" & vbcrlf & "      offsetLeft +=elmt.offsetLeft;}" & vbcrlf & "  return{top:offsetTop,left:offsetLeft,width:offsetWidth,height:offsetHeight};" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "// 维护窗口唯一性" & vbcrlf & "function uniqueWin(){" & vbcrlf & "    var f = $(""form[name=upform2]"").parents(""#fupload"");        " & vbcrlf & "        var pp = $("".ProgressPercent"");" & vbcrlf & "   var pb = $("".ProgressBar""); " & vbcrlf & "      var usize = $(""uploadSize"");" & vbcrlf & "   var uspeed = $(""uploadSpeed"");" & vbcrlf & "    var tTime = $(""totalTime"");" & vbcrlf & "       var lTime = $(""leftTime"");" & vbcrlf & "        if(f.size() > 1){f.eq(0).remove(); };" & vbcrlf & "   if(pp.size() > 1){pp.eq(0).remove(); };" & vbcrlf & " if(pb.size() > 1){pb.eq(0).remove(); };" & vbcrlf & "" & vbcrlf & "     if(usize.size() > 1){usize.eq(0).remove(); };" & vbcrlf & "   if(uspeed.size() > 1){uspeed.eq(0).remove(); };" & vbcrlf & " if(tTime.size() > 1){tTime.eq(0).remove(); };" & vbcrlf & "   if(lTime.size() > 1){lTime.eq(0).remove(); };" & vbcrlf & "};" & vbcrlf &"" & vbcrlf & "" & vbcrlf & "function showUploadForm(obj)" & vbcrlf & "{" & vbcrlf & "     uniqueWin();" & vbcrlf & "    var xy = GetCurObjectPos(obj);" & vbcrlf & "  var showobj=document.getElementById(""fupload"");" & vbcrlf & "           showobj.style.display=""block"";" & vbcrlf & "            showobj.style.left=xy.left + ""px"";" & vbcrlf & "                showobj.style.top= (xy.top + 12) + ""px"";" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "$(""form[name=upform2]"").find(""#fclose"").click(function(){" & vbcrlf & "   uniqueWin();" & vbcrlf & "});" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "function chkFrm()" & vbcrlf & "{" & vbcrlf& "  uniqueWin();" & vbcrlf & "" & vbcrlf & "  var objFrm = document.getElementsByName(""upform2"")[0];" & vbcrlf & "  if(objFrm.filefield.value=="""")" & vbcrlf & "  {" & vbcrlf & "           app.Alert(""请选择一个文件"");" & vbcrlf & "              return false;" & vbcrlf & "  }" & vbcrlf & "  if(objFrm.filedesc.value.length>200)" & vbcrlf & "  {" & vbcrlf & "    app.Alert(""文件描述不能超过200字"");" & vbcrlf & "       return false;" & vbcrlf & "  }" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "  var arrExt=objFrm.txt.value.split(""."");" & vbcrlf & "  var fExt=arrExt[arrExt.length-1];" & vbcrlf & "  if(allowExts.toLowerCase().indexOf('|'+fExt.toLowerCase()+'|')<0 && arrExt.length!=0)" & vbcrlf & "  {" & vbcrlf & "        app.Alert(""上传的文件不合法,只能上传"
	Response.write allowExts
	Response.write mid(replace(allowExts,"|","，"),2,len(allowExts)-2)
	Response.write allowExts
	Response.write "格式的文件！"");" & vbcrlf & "    return false;" & vbcrlf & "  }" & vbcrlf & "" & vbcrlf & "  //objFrm.action = ""ProcUpload.asp?opt=Upload&xmlPath="
	Response.write xmlPath
	Response.write """;" & vbcrlf & "  document.getElementById(""fupload"").style.display=""none"";" & vbcrlf & "  document.getElementById(""bg"").style.display=""block"";" & vbcrlf & "" & vbcrlf & " ProgressPercent.innerHTML = ""0%"";" & vbcrlf & " ProgressBar.style.width = ""0%"";" & vbcrlf & "   uploadSize.innerHTML = '0';" & vbcrlf & "  uploadSpeed.innerHTML = '0';" & vbcrlf & "    totalTime.innerHTML = '0';" & vbcrlf & "      leftTime.innerHTML = '0';" & vbcrlf & "  startProgress('"
	Response.write xmlPath
	Response.write "');//启动进度条" & vbcrlf & "  return true;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "//启动进度条" & vbcrlf & "function startProgress(xmlPath)" & vbcrlf & "{" & vbcrlf & "  displayProgress();" & vbcrlf & "  setProgressDivPos();" & vbcrlf & "  setTimeout(""DisplayProgressBar('"" + xmlPath + ""')"",500);& vbcrlf & } & vbcrlf & vbcrlf & vbcrlf & function xmlNodeValue(nd){ & vbcrlf &     return nd.text || nd.textContent; & vbcrlf & } & vbcrlf & function DisplayProgressBar(xmlPath) & vbcrlf & { & vbcrlf &     var xmlhttp = window.XMLHttpRequest ? ( new window.XMLHttpRequest()) :  (new ActiveXObject(""MSXML2.XMLHTTP""));" & vbcrlf & "    xmlhttp.open(""GET"", xmlPath, false);" & vbcrlf & "    xmlhttp.send();" & vbcrlf & "    var xmlDoc = xmlhttp.responseXML;" & vbcrlf & "    if(xmlDoc==null){ return; }" & vbcrlf & "    var root = xmlDoc.documentElement;   //根节点" & vbcrlf& "    if(root==null){ return; }" & vbcrlf & "    var totalbytes =xmlNodeValue(root.childNodes[0]);" & vbcrlf & "    var uploadbytes = xmlNodeValue(root.childNodes[1]);" & vbcrlf & "    var percent =xmlNodeValue(root.childNodes[2]);" & vbcrlf & "    document.getElementById(""ProgressPercent"").innerHTML = percent + ""%"";" & vbcrlf & "    document.getElementById(""ProgressBar"").style.width = percent + ""%"";" & vbcrlf & "    document.getElementById(""uploadSize"").innerHTML = uploadbytes;" & vbcrlf & "    document.getElementById(""uploadSpeed"").innerHTML = xmlNodeValue(root.childNodes[3]);"& vbcrlf & "    document.getElementById(""totalTime"").innerHTML = xmlNodeValue(root.childNodes[4]);" & vbcrlf & "    document.getElementById(""leftTime"").innerHTML = xmlNodeValue(root.childNodes[5]);" & vbcrlf & "    if (percent<100)" & vbcrlf & "    {" & vbcrlf & "        setTimeout(""DisplayProgressBar('"" + xmlPath + ""')"",1000);" & vbcrlf & "    }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function displayProgress()" & vbcrlf & "{" & vbcrlf & "  var objProgress = document.getElementById(""Progress"");" & vbcrlf & "  objProgress.style.display = """";" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function closeProgress()" & vbcrlf & "{" & vbcrlf & "  var objProgress = document.getElementById(""Progress"");" & vbcrlf & "  objProgress.style.display = ""none"";" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function setProgressDivPos()" & vbcrlf & "{" & vbcrlf & "       var objProgress = document.getElementById(""Progress"");" & vbcrlf & "       objProgress.style.top = document.body.scrollTop+(document.body.clientHeight-document.getElementById(""Progress"").offsetHeight)/2" & vbcrlf & "   objProgress.style.left = document.body.scrollLeft+(document.body.clientWidth-document.getElementById(""Progress"").offsetWidth)/2;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "// KILLER.2015.10.28 修改上传文件框位置" & vbcrlf & "setTimeout(function(){" & vbcrlf & "        $("".fileUpdate-btn"").live(""click"",function(){       " & vbcrlf & "                var f = $(""#fupload"");" & vbcrlf & "            var w = f.width();" & vbcrlf & "              var left = parseInt(f.css(""left"")) - w;" & vbcrlf & "" & vbcrlf & "               $(""#fupload"").css({left:left+""px""});" & vbcrlf & "" & vbcrlf & "                var fid = $(this).attr(""fid"");" & vbcrlf & "            var pType = $(this).attr(""pageType"");" & vbcrlf & "             " & vbcrlf & "                f.find(""#edit"").val(1);" & vbcrlf & "           f.find(""#fid"").val(fid);" & vbcrlf & "             f.find(""#pageType"").val(pType);" & vbcrlf & "           " & vbcrlf & "        });" & vbcrlf & "},500);" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "// KILLER.2015.10.28 处理文件修改" & vbcrlf & "function fileUpdate(obj){    " & vbcrlf & "        if(obj.ptype == ""mxList""){        // 明细列表修改文件" & vbcrlf &"          var url = ""ajax.asp"";" & vbcrlf & "             var fid = obj.fid," & vbcrlf & "                      fname = obj.fname," & vbcrlf & "                      fsize = obj.fsize," & vbcrlf & "                      fsizeInt = obj.fsizeInt," & vbcrlf & "                        ftype = obj.ftype," & vbcrlf & "                      fUrl = obj.fUrl," & vbcrlf & "                        fDesc = obj.fDesc" & vbcrlf & "" & vbcrlf &"          // 临时修改数据" & vbcrlf & "         $.post(url,{act:""fileTempUpdate"",fid:fid},function(data){" & vbcrlf & "                 var obj = eval(""var o = "" + data + "";o"");" & vbcrlf & "                   " & vbcrlf & "                        if(obj.err !== ""0""){" & vbcrlf & "                              app.Alert(obj.err);" & vbcrlf & "                             return false;" & vbcrlf & "                   };" & vbcrlf & "" & vbcrlf & "                     // 上传文件后更新界面信息" & vbcrlf & "                       var td = $("".fileUpdate-btn[fid=""+ fid +""]"").parent().parent().siblings(""td"");" & vbcrlf & "                        td.eq(2).find(""div"").html(fname);         " & vbcrlf & "                        var lie = $(""#lie_1"").val();              " & vbcrlf & "                        if(lie == 0){" & vbcrlf & "                           td.eq(3).find(""div"").html(fsize);" & vbcrlf & "                        }else if(lie == 1){" & vbcrlf & "                             td.eq(3).find(""div"").html(ftype);" & vbcrlf & "                 };" & vbcrlf & "                      " & vbcrlf & "                        // 弹出选择审批人界面                   " & vbcrlf & "                        spclient.onProcComplete = function(){" & vbcrlf & "                           var sp_id = $(""#sp_id"").val();" & vbcrlf & "var cateid_sp = $(""#spuser"").val();" & vbcrlf & "                               " & vbcrlf & "                                // 不需要审批" & vbcrlf & "                           if(typeof(sp_id) == 'undefined'){" & vbcrlf & "                                       savefile();" & vbcrlf & "                             };" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "                              $(""#_sp_sbmit"").click(function(e){" & vbcrlf & "                                        savefile();" & vbcrlf & "                                });" & vbcrlf & "                             " & vbcrlf & "                                // 保存数据" & vbcrlf & "                             function savefile(){" & vbcrlf & "                                    " & vbcrlf & "                                        var data = {" & vbcrlf & "                                            act : ""fileSave""," & vbcrlf & "                                         fid : fid," & vbcrlf & "                                              documentID : obj.documentID," & vbcrlf & "                                            cid : obj.cid," & vbcrlf & "                                            fname : escape(fname)," & vbcrlf & "                                          fsize : fsizeInt," & vbcrlf & "                                               ftype : ftype," & vbcrlf & "                                          fUrl : fUrl," & vbcrlf & "                                            fDesc : escape(fDesc)," & vbcrlf & "                                          cateid_sp : cateid_sp," & vbcrlf & "                                          sp_id : sp_id" & vbcrlf & "                                   };" & vbcrlf & "              " & vbcrlf & "                                        $.post(url,data,function(data){" & vbcrlf & "                                         var obj = eval(""var o = "" + data + "";o"");" & vbcrlf & "                                           " & vbcrlf & "                                                select_psize(1);" & vbcrlf & "                                        });" & vbcrlf & "" & vbcrlf & "                             };" & vbcrlf & "" & vbcrlf & "                      };" & vbcrlf & "" & vbcrlf & "                      spclient.GetNextSP('document',obj.documentID,0,obj.cid,"
	Response.write session("personzbintel2007")
	Response.write ",1);" & vbcrlf & "" & vbcrlf & "          " & vbcrlf & "                        // 处理选择审批人的取消操作" & vbcrlf & "                     $(""#_sp_close"").unbind(""click"");" & vbcrlf & "                    $("".panel-tool-close"").unbind(""click"");" & vbcrlf & "                     $(""#_sp_close,.panel-tool-close"").click(function(e){" & vbcrlf & "                              e.preventDefault();" & vbcrlf & "                             e.stopPropagation();" & vbcrlf & "                            if(confirm(""提示：不提交审批，您的修改将不会生效！\n　　　点击取消按钮重新选择审批人；\n　　　点击确定按钮将放弃修改！"")){" & vbcrlf & "                                        " & vbcrlf & "                                        $('#_sp_usr').window('close');" & vbcrlf & "                                  " & vbcrlf & "                                        //恢复临时修改的数据" & vbcrlf & "                                    $.post(url,{act:""fileTempRollback""},function(data){" & vbcrlf & "                                          try{" & vbcrlf & "                                                    var obj = eval(""var o = "" + data + "";o"");" & vbcrlf & "                                                   if(obj.err != ""0""){" & vbcrlf & "                                                               app.Alert(obj.err);" & vbcrlf & "                                                             return false;" & vbcrlf & "                                                   };" & vbcrlf & "                                                      " & vbcrlf & "                                                        select_psize(1);"& vbcrlf &                                              "}catch(e){};" & vbcrlf & vbcrlf &                                     "});" & vbcrlf &                              "};" & vbcrlf &                       "});" & vbcrlf & vbcrlf & vbcrlf & vbcrlf &              "});" & vbcrlf & vbcrlf &        ""       & vbcrlf &        ""          & vbcrlf &         "}else{  // 修改页面修改文件" & vbcrlf &              "var td = $("".fileUpdate-btn[fid=""+obj.fid +""]"").parent().parent().siblings(""td"");" & vbcrlf & "         td.eq(0).find(""center"").html(obj.flink);" & vbcrlf & "          td.eq(1).find(""center"").html(obj.fsize);" & vbcrlf & "          td.eq(2).find(""center"").html(obj.fDesc);" & vbcrlf & "  };" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "}" & vbcrlf & ""& vbcrlf & vbcrlf & "// 文件删除" & vbcrlf & "$("".fileDel-btn"").live(""click"",function(){" & vbcrlf &     "if(confirm(""确认要删除此文件吗（删除后不可恢复）？"")){" & vbcrlf &             "var p = $(this).parents(""tr"");" & vbcrlf &             "var fid = $(this).attr(""fid"");" & vbcrlf & vbcrlf &             "$.post(""ajax.asp"",{act:""fileDel"",fid:fid},function(){" & vbcrlf & "                     p.remove();" & vbcrlf & "                     select_psize(1);" & vbcrlf & "                });" & vbcrlf & "                             " & vbcrlf & "        };" & vbcrlf & "" & vbcrlf & "});" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "</script>" & vbcrlf & "<div id=""Progress"" style=""display:none;"" class=""progress"">" & vbcrlf & "    <div class=""bar"" style=""background-color:#CCCCCC; border: 1px inset #666666;"">" & vbcrlf & "        <div id=""ProgressPercent"" class=""ProgressPercent"">0%</div>" & vbcrlf & "        <div id=""ProgressBar"" class=""ProgressBar""></div>" & vbcrlf & "    </div>" & vbcrlf & "<table border=""0"" cellspacing=""0"" cellpadding=""1"" style=""table-layout:fixed;"">" & vbcrlf &         "<tr>" & vbcrlf &             "<td width=""55"">已经上传</td>" & vbcrlf &             "<td width=""5"">:</td>" & vbcrlf &             "<td width=""190"" id=""uploadSize""></td> & vbcrlf & </tr>" & vbcrlf & "        <tr>" & vbcrlf & "            <td>上传速度</td>" & vbcrlf & "            <td>:</td>" & vbcrlf & "            <td id=""uploadSpeed"" align=""left"">&nbsp;</td>" & vbcrlf & "        </tr>" & vbcrlf & "        <tr>" & vbcrlf & "            <td>共需时间</td>" & vbcrlf & "       <td>:</td>" & vbcrlf & "            <td id=""totalTime"" align=""left"">&nbsp;</td>" & vbcrlf & "        </tr>" & vbcrlf & "        <tr>" & vbcrlf & "            <td>剩余时间</td>" & vbcrlf & "            <td>:</td>" & vbcrlf & "            <td id=""leftTime"" align=""left"">&nbsp;</td>" & vbcrlf &"        </tr>" & vbcrlf & "    </table>" & vbcrlf & "</div>" & vbcrlf & "<div id=""bg""></div>" & vbcrlf & "<!--上传模块结束-->" & vbcrlf & ""
	'Response.write session("personzbintel2007")
	
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
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) "&_
			" [CANCELJOINTABLE] " & _
			"inner join learntz b on a.orderId=b.ord and b.del=1 " &_
			" where a.reminderConfig=" & configId & " [CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "isnull(b.ord,0) [id],isnull(b.title,'【已删除数据】') title,isnull(convert(varchar(19),b.date7,21),'----') dt,"&_
			"datediff(s,' & actDate & ',isnull(b.date7,'2000-01-01"
'where a.reminderConfig= & configId &  [CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
'where c.del=1 and b.state<>2 and a.reminderConfig= & configId &  [CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by b.stime desc"
			Case 7:
			Dim nowDays : nowDays = datediff("d",CDate(year(date)&"-01-01"),date)
'Case 7:
			Call fillinPower(m_qxlb,m_listqx,qOpen,qIntro)
			if m_fw1&""="0" then
				if qOpen=3 then
					cateCondition=""
				elseif qOpen=1 then
					cateCondition=cateCondition & " and (tl.cateid in ("&qIntro&") "&_
					"or tl.share='1' "&_
					"or charindex(',"&uid&",',','+tl.share+',')>0) "
'or tl.share='1
				else
					cateCondition=cateCondition & " and (tl.share='1' or charindex(',"&uid&",',','+tl.share+',')>0) "
'or tl.share='1
				end if
			else
				cateCondition=cateCondition & " and tl.cateid="&uid&" or (tl.share='1' or charindex(',"&uid&",',','+tl.share+',')>0) "
'or tl.share='1
			end if
			cateCondition=cateCondition & " and bDays - "&nowDays&" >=0 and bDays - "&nowDays&" <= " & m_tq1 & " " & vbcrlf
'or tl.share='1
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
'inner join product b  with(nolock) on b.ord=c.ord  & vbcrlf &_
			fields = "c.id [id],d.title+'['+b.title+']' title,convert(varchar(10),c.date2,23) dt,datediff(s,'""&actDate&""',a.inDate) newTag,a.id [rid],c.cateid"""
'inner join product b  with(nolock) on b.ord=c.ord  & vbcrlf &_
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
'where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
'where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
			"cateCondition = "" and ("""&_
			") " & tmpCondition & vbcrlf
			cateCondition = cateCondition & " and datediff(d,getdate(),b.date2)<=" & m_tq1
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join contract b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 and isnull(b.status,-1) in (-1,1)  " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
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
			sql="select COUNT(*) REMIND_CNT from tousu  with(nolock) where del=1 [CATECONDITION] and result1=0 [ORDERBY]"
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
'where 1=1 [CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "order by c.date2 desc,c.date7 desc"
			Case 39:
			cateCondition = "and learnhd.cateid="&uid
			sql="SELECT COUNT(*) REMIND_CNT FROM replyhd  with(nolock) "&_
			"LEFT JOIN learnhd  with(nolock) ON replyhd.ord = learnhd.ord "&_
			"where learnhd.del=1 and replyhd.alt=1 [CATECONDITION] [ORDERBY]"
			fields = "replyhd.id as [id],learnhd.title as title,replyhd.date7 as dt,-1 newTag,0 [rid],learnhd.cateid as cateid,learnhd.ord as ord"
'where learnhd.del=1 and replyhd.alt=1 [CATECONDITION] [ORDERBY]
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
			"IIf(withoutCateCondition,"""",""and (cast(ck.intro as varchar(10))='0' "&_
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
			"and isnull(c.DealPerson,a.DealPerson) = " & uid &" "&_
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
			" and " & vbcrlf &_
			")" & vbcrlf & _
			")" & vbcrlf &_
			" and datediff(d,getdate(),BeginTimePlan)<="& m_tq1&" " & cateCondition & vbcrlf &_
			") a [ORDERBY]"
			fields = "[id],title,dt,-1 newTag,0 [rid],MainExecutor cateid"
') a [ORDERBY]
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
'Case 104:
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join tel b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.name title,convert(varchar(19),b.date1,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "order by a.inDate desc,b.ord desc"
			Case 54:
			cateCondition = " AND (CHARINDEX(',"&uid&",',','+b.share+',')>0 OR share='1') "
'Case 54:
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN chance b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(19),b.date1,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 201:
			cateCondition = " AND (CHARINDEX(',"&uid&",',','+b.share+',')>0 OR share='1') "
'Case 201:
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN contract b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.ord AND b.del=1 " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],b.title title,convert(varchar(10),b.date3,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
			orderBy = "ORDER BY a.inDate DESC,b.ord DESC"
			Case 202:
			cateCondition = " AND (CHARINDEX(',"&uid&",',','+b.share+',')>0 OR share='1') "
'Case 202:
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			cateCondition = getCondition(m_qxlb,m_listqx,"b.cateid")
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"where b.price=p.ord)"&_
			")C left join power pow on pow.ord= "&uid&"  and pow.sort1=24 and pow.sort2=13    WHERE (pow.qx_open=3 or CHARINDEX(','+CAST(C.cateid AS VARCHAR(20))+',',','+CAST(pow.qx_intro AS VARCHAR(8000))+',') > 0) AND 1=1"& _
			"where b.price=p.ord)"&_
			"[ORDERBY]"
			fields = "C.id [id],(case when C.ismode=1 THEN '来自预购:'+ C.title else '来自报价:'+ C.title end) title,0 [rid],C.cateid,-1 newTag, CAST(CONVERT(varchar(10), C.date1 , 120)as datetime)  dt"
'[ORDERBY]
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
'(CASE WHEN (kg = 0 OR complete1 IN (2,3)) THEN 1 ELSE 0 END) canCancelAlt,  &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.Creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.Creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
'(CASE WHEN (cateid_sp = 0 OR complete < 0 OR complete = 3) THEN 1 ELSE 0 END) canCancelAlt,  &_
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
'(CASE WHEN (isnull(gate_sp,0) = 0 OR sp_id < 0) THEN 1 ELSE 0 END) canCancelAlt, &_
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
			" [CANCELJOINTABLE] " & _
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.ord [id],'@code:FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(19),a.inDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
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
'Case 210:
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
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 212:
			cateCondition = getConditionByFW(m_qxlb,m_listqx,"b.cateid")
			sql = "SELECT COUNT(*) REMIND_CNT FROM reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"INNER JOIN payoutInvoice b  with(nolock) ON a.reminderConfig=" & configId & " AND a.orderId = b.id AND b.del = 1 " & vbcrlf &_
			"WHERE 1 = 1 AND b.del = 1 AND b.isInvoiced in (1,2) " & vbcrlf &_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.[id],'@code:FormatNumber('+CAST(b.money1 AS VARCHAR)+'," & moneyDigit & ",-1,0,-1)' title,convert(varchar(19),b.invoiceDate,21) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.cateid "
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
'ElseIf qOpen = 1 Then
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
				"and ("& vbcrlf &_
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
			cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1 & " "
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
			"AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
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
			cateCondition = cateCondition & " AND datediff(d,getdate(),b.date2)<=" & m_tq1 & " "
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
			"AND LEN(CAST(z.share AS VARCHAR(10))) > 0 " & vbcrlf & _
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
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
			"CAST(ISNULL(ck.intro,'') AS VARCHAR(4000)) = '0' " & vbcrlf &_
			") " & vbcrlf &_
			"AND p.del = 1 " & vbcrlf &_
			"AND k.num2 > 0 " & vbcrlf &_
			"AND p.RemindNum > 0 " & vbcrlf &_
			"AND CHARINDEX(',"&uid&",', ',' + ISNULL(p.RemindPerson, '') + ',') > 0 " & vbcrlf &_
			"AND p.RemindNum > 0 " & vbcrlf &_
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
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
'(CASE WHEN (cateid_sp = 0 OR id_sp < 0) THEN 1 ELSE 0 END) canCancelAlt, &_
			orderBy = "ORDER BY a.inDate DESC,b.id DESC"
			Case 218:
			cateCondition = getCondition(m_qxlb,15,"c.designer")
			cateCondition = cateCondition & " AND  charindex(',"& uid &",',','+replace(reminders,' ','')+',')>0 "
			cateCondition = getCondition(m_qxlb,15,"c.designer")
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
			"inner join product p  with(nolock) on p.ord = b.productid "&_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title +' ('+ p.title +')' as title,a.inDate dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
			"inner join product p  with(nolock) on p.ord = b.productid "&_
			"[CATECONDITION] [CANCELCONDITION] [ORDERBY]"
			fields = "b.id [id],b.title +' ('+ p.title +')' as title ,b.dateEnd dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.creator cateid"
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
			"where  del=1 " & vbcrlf &_
			"or (b.addcate="& uid &" and  (b.spFlag = 1 or b.spFlag=-1)) "&_
			"where  del=1 " & vbcrlf &_
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
			"datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],b.addcate cateid," &_
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
					&" or (member1 is not null and member1<>0 and member1 in ("&qIntro&")) "_
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
				&" or (member1 is not null and member1<>0 and member1 in ("&uid&")) "_
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
'ElseIf qOpen=1 Then
			else
				cateCondition = " and (share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0)"
'ElseIf qOpen=1 Then
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
'ElseIf qOpen=1 Then
			else
				cateCondition = " and (share='1' or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0)"
'ElseIf qOpen=1 Then
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
'ElseIf qOpen=1 Then
			else
				cateCondition = " and (1=2 or charindex(','+cast(" & uid & " as varchar(12))+',',','+replace(cast(share as varchar(8000)),' ','')+',')>0)"
'ElseIf qOpen=1 Then
			end if
			cateCondition = " " & tmpCondition & " " & cateCondition & vbcrlf
			sql = "select COUNT(*) REMIND_CNT from reminderQueue a  with(nolock) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
			"inner join contract b  with(nolock) on a.reminderConfig=" & configId & " and a.orderId = b.ord and b.del=1 and isnull(b.status,-1) in (-1,1) " & vbcrlf &_
			" [CANCELJOINTABLE] " & _
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
			"where sendOrReceive = 1 and readed = 0 " & vbcrlf &_
			") m on u.id=m.userid " & vbcrlf &_
			"left join (" & vbcrlf &_
			"    select p.ord,tl.cateid from person p  with(nolock) " & vbcrlf &_
			"    left join tel tl on tl.ord = p.company " & vbcrlf &_
			") t on u.person=t.ord " & vbcrlf &_
			"where 1=1 " & vbcrlf &_
			"[CATECONDITION] [ORDERBY]"
			fields = "u.id [id],u.nickname + '(' + cast(cnt as varchar) + ')' title,dateadd(hh,8,dateadd(s,lastTime,'1970-1-1 0:0:0')) dt,"&_
			"datediff(s,'&actDate&',dateadd(hh,8,dateadd(s,lastTime,'1970-1-1 0:0:0"
'[CATECONDITION] [ORDERBY]
			orderBy = "order by m.lastTime desc"
			Case 219:
			cateCondition =  " AND (charindex(',"& uid &",',','+replace(share,' ','')+',')>0 or b.share='1' or exists(select 1 from noticelist  with(nolock) where notice = b.id and cateid = "& uid &") ) "
'Case 219:
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
'0 canCancelAlt,  &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.CreateID="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
'where b.del=1 and b.ptype=0 and tempSave=0 and b.[status]<>2 & vbcrlf &_
			else
				cateCondition = " and 1=2"
			end if
			cateCondition = cateCondition & "and (" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
			"or (c.ApprovalFlowStatus in (2,4,5) and charindex(',"& uid &",',','+ c.SurplusApprover +',')>0) /*待审批的提醒给审批人*/" & vbcrlf &_
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
				"left join M2_WorkingProcedures M2WP  with(nolock) on M2WP.ID = M2WFPA.WPID  " & vbcrlf &_
				"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" and plist.sort1=5031 AND plist.sort2=1" & vbcrlf &_
				" where M2WFPA.del=1 and isnull(M2WFPA.isOut,0)=0  and tempSave=0 " & vbcrlf &_
				" AND (plist.qx_open = 3 or dbo.existsPower2(plist.qx_intro, isnull(M2WFPA.cateid, '') + ',' + isnull(M2WA.Cateid_WA, ''), ',') = 1) "& vbcrlf &_
				" where M2WFPA.del=1 and isnull(M2WFPA.isOut,0)=0  and tempSave=0 " & vbcrlf &_
				" AND M2WA.[Status]<>2  AND M2WA.wastatus!='生产完毕' AND ISNULL(M2WA.SPStatus,-1) IN(-1,1)"& vbcrlf &_
				" where M2WFPA.del=1 and isnull(M2WFPA.isOut,0)=0  and tempSave=0 " & vbcrlf &_
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
			"left join M2_WorkingProcedures M2WP  with(nolock) on M2WP.ID = M2WFPA.WPID   " & vbcrlf &_
			"left join dbo.power plist  with(nolock) ON plist.ord = "& uid &" and plist.sort1=5031 AND plist.sort2=1 " & vbcrlf &_
			"WHERE  M2WFPA.del=1 and isnull(M2WFPA.isOut,0)=0  and charindex(','+cast(" & uid & " as varchar(12))+',',','+isnull(M2WFPA.cateid,'')+','+isnull(M2WA.Cateid_WA,'')+','+isnull(M2WP.Wheelman,'')+',')>0 and tempSave=0 " & vbcrlf &_
			" AND M2WA.[Status]<>2  AND M2WA.wastatus!='生产完毕' AND ISNULL(M2WA.SPStatus,-1) IN(-1,1) "& vbcrlf &_
			" AND ISNULL(M2WFPA.Finished, 0) = 0"& vbcrlf &_
			" AND NOT EXISTS(SELECT 1 FROM M2_CostComputation  with(nolock) WHERE complete1=1 and datediff(mm,date1,M2WA.DateStart)=0) "& vbcrlf &_
			"[CATECONDITION]  "& vbcrlf &_
			" GROUP BY  M2WFPA.id,M2WA.title,M2WP.WPName,M2WFPA.DateEnd,M2WFPA.cateid,M2WA.indate) M2WFPA ON  a.reminderConfig=" & configId & " and a.orderId = M2WFPA.id  "& vbcrlf &_
			"[CANCELCONDITION] [ORDERBY]"
			fields = "M2WFPA.id,isnull(M2WFPA.title,'')+'['+ISNULL(M2WFPA.WPName,'')+']' as title ,convert(varchar(10),M2WFPA.DateEnd,23) dt,datediff(s,'"&actDate&"',a.inDate) newTag,a.id [rid],M2WFPA.cateid"
'[CANCELCONDITION] [ORDERBY]
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
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
'[CATECONDITION] [CANCELCONDITION] [ORDERBY]
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(c.ApprovalFlowStatus in (0,1,2,3)  and b.creator="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(b.[status] in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
			"(b.[status] in (0,1,2,3)  and b.cateid="& uid &") /*审批通过或终止的提醒给添加人*/" & vbcrlf &_
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
	End Class
	Sub messagePost(msgid)
		If msgid = "" then
			Call Page_Load
		ElseIf msgid="dosearch" Then
			Call App_doSearch
		ElseIf msgid="setheads" Then
			Call App_setheads
		ElseIf msgid="setall" Then
			Call App_doSetall
		ElseIf msgid="setunplace" Then
			Call App_setUnplace
		end if
	end sub
	Sub Page_Load
		dim rpttitle
		Set rs=cn.execute("select id,Sort1,gate1 from sortonehy where gate2='10' and (id='"&app.getInt("areamenu_list")&"' or id='"&app.getInt("areamenu2")&"')")
		IF not rs.eof Then
			rpttitle = rs("Sort1")
		else
			rpttitle = "文档明细表"
		end if
		set rs=nothing
		Dim remind : remind = app.getint("remind")
		app.addDefaultScript
		Response.write(app.DefTopBarHTML(app.virPath, "", ""&rpttitle&"", "<table id='contents' style='background-image:url();border:0px;background-color:transparent;margin-top:2px'><tr><td align='right' style='border-top:0px;border-bottom:0px;border-left:0px'><input type='hidden' id='px' value='1'/><a id='pxgz' class='sortRule' href='javascript:void();' onclick='showmenu(this);return false' style='position: absolute; top: 22px; left: 213px;' >排序规则<img class='resetElementHidden' src='../images/i10.gif' width='9' height='5' border='0'><img class='resetElementShowNoAlign' style='display:none' src='../skin/default/images/MoZihometop/content/r_down2.png' width='9' height='5' border='0'></a></td></tr></table><span id='tmv'></span>")) & vbCrLf
		Dim rs
		Response.write "" & vbcrlf & "      <div style='background-color:white;'>" & vbcrlf & "   <link rel=stylesheet type=text/css href=""../inc/themes/default/easyui.css?ver="
'Dim rs
		Response.write Application("sys.info.jsver")
		Response.write """>" & vbcrlf & " <script type=""text/JavaScript"" src=""../inc/jquery.easyui.min.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "        <script type=""text/JavaScript"" src=""../inc/CommSPAjax.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "    <script type=""text/javascript"" src=""../script/dt_planall_mx.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "        <script>" & vbcrlf & "        $(function(){" & vbcrlf & "" & vbcrlf & "     $(""#pxgz"").css({""left"":$(""#comm_itembarText"").width()+130})" & vbcrlf & " })" & vbcrlf & "      </script>" & vbcrlf & "       <style>" & vbcrlf & " #toolbar1{height:54px;}" & vbcrlf & " #content.docDetails>tbody>tr>td{padding:0!important;border:1px solid #CCC}" & vbcrlf & "      </style>" & vbcrlf & "        <div style='background-image:url(../images/112.gif);width:100%;' id='toolbar1' align=""right"">" & vbcrlf & "             <table style='width:auto;table-layout:auto;border-collapse:separate' cellspacing='3' id=""kh"">"& vbcrlf & "               <tr>" & vbcrlf & "            <td align=""right"" style='border-top:0px;border-bottom:0px;border-left:0px;'>" & vbcrlf & "              上传时间：" & vbcrlf & "              <input type=""text"" id=""indate1"" onclick=""datedlg.showDateTime()"" size=""20"" readonly=""readonly"" /> " & vbcrlf & "                至 <input type=""text"" id=""indate2"" onclick=""datedlg"".showDateTime()"" size=""20"" readonly=""readonly"" />　 "& vbcrlf &                 "<select name=""spflag"" id=""spflag"">" & vbcrlf &           "<option value="">状态</option>" & vbcrlf &             "<option value=""2"">未审批</option>" & vbcrlf &          "<option value=""3"">审批中</option>" & vbcrlf &          "<option value=""1"">审批通过</option>" & vbcrlf & "                <option value=""4"">已归档</option>" & vbcrlf & "         </select>" & vbcrlf & "               <select name=""tbi"" id=""tbi"">" & vbcrlf & "                <option value=""0"">文件名称</option>" & vbcrlf & "               <option value=""1"">添加人员</option>" & vbcrlf & "               </select>" & vbcrlf & "               <input type=""text""  id=""key"" maxlength=""20"" /> " & vbcrlf & "               <input type=""hidden"" id=""jstype"" value="""
		Response.write app.getInt("jstype")
		Response.write """>" & vbcrlf & "         <input type=""hidden"" id=""remind"" value="""
		Response.write remind
		Response.write """>" & vbcrlf & "         <input type=""hidden"" id=""gdlist"" value="""">" & vbcrlf & "            <input type=""hidden"" id=""areamenu_list"" value="""
		Response.write app.getInt("areamenu_list")
		Response.write """>" & vbcrlf & "         <input type=""hidden"" id=""areamenu2"" value="""
		Response.write app.getInt("areamenu2")
		Response.write """>" & vbcrlf & "         <input type=""button"" value="" 检索 "" class=""oldbutton"" onclick=""doSearch(0);"" />&nbsp;" & vbcrlf & "           </td>" & vbcrlf & "           <td style='width:120px'><div style='width:120px'>&nbsp;</div></td>" & vbcrlf & "              </tr>" & vbcrlf & "           </table>" & vbcrlf & "        </div>" & vbcrlf & "  "
		Dim asearch
		Set aSearch = New AdvanceSearchClass
		aSearch.AddField "添加人员", "gates", "g_tjry" , ""
		aSearch.AddField "状态", "checks", "zt" , "select 2 as value, '未审批' as name union all select 3, '审批中'  union all select 1, '审批通过' union all select 4, '已归档'"
		aSearch.AddField "文件名称", "selectys", "swdname" , ""
		aSearch.AddField "关联文档", "selectys", "swdtitle" , ""
		aSearch.AddField "文档编号", "selectys", "swdid" , ""
		aSearch.AddField "文件类型", "selectys", "WDType" , ""
		aSearch.AddField "文件大小", "numsfile", "WDSize" , ""
		aSearch.AddField "上传时间", "datetime", "date7" , ""
		aSearch.AddField "有效期限", "dates", "date3" , ""
		Call aSearch.showButton
		Response.write "" & vbcrlf & "      <script type=""text/javascript"">" & vbcrlf & "           document.getElementById(""contents"").swapNode(document.getElementById(""tmv""));" & vbcrlf & "               function cancelRemind(rid){" & vbcrlf & "                     sendCancelRequest(rid,"
		Response.write remind
		Response.write ",0,'','' , function(){" & vbcrlf & "                                doSearch(0);" & vbcrlf & "                    });" & vbcrlf & "             }" & vbcrlf & "       </script>" & vbcrlf & "       <style>" & vbcrlf & "         .lvw_pagebar" & vbcrlf & "            {" & vbcrlf & "                       background-image:url(../images/m_table_b.jpg);" & vbcrlf & "          }" & vbcrlf & "               .lvwpagesizearea {"& vbcrlf &                      "display:none;" & vbcrlf &            "}" & vbcrlf &                "td.lvw_index {background-image:url()}" & vbcrlf &            ".body {" & vbcrlf &                  "overflow-x: hidden;" & vbcrlf &                      "overflow-y:auto;" & vbcrlf &                         "position:relative;" & vbcrlf &               "}" & vbcrlf &        "</style>" & vbcrlf &         "<div style=""overflow:hidden;min-width:900px;box-sizing:border-box"" id='lvwbody'>" & vbcrlf & "           "
		'Response.write remind
		App_doSearch
		Response.write "</table></div></div></body></html>"
	end sub
	Sub App_setheads
		Dim o, ld
		o = app.getint("isopen")
		ld = app.gettext("ldata")
		app.attributes("doclieOpen") = o
		If o = 1 Then
			app.attributes("documentcols") = ld
		else
			app.attributes("documentcols") = ""
		end if
	end sub
	Function search_scope(strField, strValue, intType)
		Dim str_Result
		If Len(intType&"")=0 Or intType=0 Then intType=1
		If strValue<>"" Then
			Select Case intType
			Case 1 : str_Result=str_Result+" and "& strField &" like ''%"& strValue &"%''"
'Select Case intType
			Case 2 : str_Result=str_Result+" and "& strField &" not like ''%"& strValue &"%''"
'Select Case intType
			Case 3 : str_Result=str_Result+" and  "& strField &"=''"&strValue&"''"
'Select Case intType
			Case 4 : str_Result=str_Result+" and "& strField &"<>''"&strValue&"''"
'Select Case intType
			Case 5 : str_Result=str_Result+" and "& strField &" like ''"& strValue &"%''"
'Select Case intType
			Case 6 : str_Result=str_Result+" and "& strField &" like ''%"& strValue &"''"
'Select Case intType
			End Select
		end if
		search_scope = str_Result
	end function
	Function App_doSearch
		Dim jstype,spflag, indate1,indate2,status,bz,lead,tbi, Keystr ,Psize,pageindex,delHtml , px , swdname , swdname_0 ,swdtitle , swdtitle_0, swdid , swdid_0, WDType, WDType_0, WDSize_0, WDSize_1 , personName, personIds , strSql ,lie_1 , lie_2, lie_3, lieOpen ,liedata , areamenu_list ,W1 ,w2  ,w3 , rss, WDSize , rd ,WDunit , Punit,areamenu2 , date3 , date4
		jstype    = app.getInt("jstype")
		personIds = ""
		indate1   = app.GetText("indate1")
		indate2   = app.GetText("indate2")
		date3   = app.GetText("date3")
		date4   = app.GetText("date4")
		spflag        = app.GetText("spflag")
		w1            = app.GetText("w1")
		w2            = app.GetText("w2")
		w3            = app.GetText("w3")
		tbi           = app.getInt("tbi")
		swdname   = app.GetText("swdname")
		swdname_0 = app.getInt("swdname_0")
		If Len(swdname)=0 Then  : If tbi=0 Then swdname = app.GetText("key")
		If tbi=1 Then  personName = app.GetText("key")
		swdtitle   = app.GetText("swdtitle")
		swdtitle_0 = app.getInt("swdtitle_0")
		swdid      = app.GetText("swdid")
		swdid_0    = app.getInt("swdid_0")
		WDType     = app.GetText("WDType")
		WDType_0   = app.getInt("WDType_0")
		WDSize_0   = app.GetText("WDSize_0")
		WDSize_1   = app.GetText("WDSize_1")
		areamenu_list = app.getInt("areamenu_list")
		areamenu2 = app.getInt("areamenu2")
		Dim remind : remind = app.getint("remind")
		strSql = search_scope("oldname",swdname,swdname_0)
		strSql = strSql & search_scope("title",swdtitle,swdtitle_0)
		strSql = strSql & search_scope("bh",swdid,swdid_0)
		strSql = strSql & search_scope("WDType",WDType,WDType_0)
		WDunit     = app.getInt("WDunit")
		Punit = 1
		If WDunit = 0 Then
			Punit = 1
		ElseIf WDunit = 1 Then
			Punit = 1024
		ElseIf WDunit = 2 Then
			Punit = 1024*1024
		end if
		If Len(WDSize_0)>0 And isnumeric(WDSize_0) Then strSql = strSql & " and   WDSize>= " & WDSize_0 * Punit &" "
		If Len(WDSize_1)>0 And isnumeric(WDSize_1) Then strSql = strSql & " and   WDSize<= " & WDSize_1 * Punit &" "
		'If Len(spflag)>0 Then strSql = strSql & " and zt in (" & Replace(spflag,6,1) & ") "
		If Len(indate1)>0 Then strSql = strSql & " and  date7>= ''" & indate1 &"'' "
		If Len(indate2)>0 Then strSql = strSql & " and  date7 <= ''" & indate2 &"'' "
		If Len(date3)>0 Or Len(date4)>0 Then
			strSql = strSql & " and l_validity=2 "
			If Len(date3)>0 Then strSql = strSql & " and  l_date4>= ''" & date3 &"'' "
			If Len(date4)>0 Then strSql = strSql & " and  l_date4<= ''" & date4 &"'' "
		end if
		If Len(personName)>0 Then strSql = strSql & " and  addcatename like ''%" & personName &"%'' "
		If areamenu_list> 0 and areamenu2 = 0 Then strSql = strSql & " and  sort =" & areamenu_list &" "
		If areamenu_list= 0 and areamenu2 > 0 Then strSql = strSql & " and  sort in (select id from #tmp1) "
		If w1<>"" Or w2<>"" Or w3 <>"" Then
			Dim persons
			persons="0"
			Set rss = cn.execute("exec erp_comm_getW3 '"&w1&"','"&w2&"','"&w3&"',2,"& Info.user)
			While rss.eof = False
				persons = persons &","& rss(0)
				rss.movenext
			wend
			rss.close
			strSql = strSql & " and addcate in (" & persons &" ) "
		end if
		Psize         = app.getInt("Psize")
		pageindex = app.getInt("pageindex")
		px            = app.getInt("px")
		If isnumeric(Replace(pageindex,",","_")) = False Then pageindex = "1"
		If px=0 Then px=1
		If Psize = 0 Then Psize = 10
		If pageindex = 0 Then pageindex = 1
		If app.GetText("lie_1")="" Then
			lieOpen = app.Attributes("doclieOpen")
			If lieOpen = "" Or lieOpen="0" Then
				lie_1 = 0
				lie_2 = 0
				lie_3 = 0
			else
				liedata = app.Attributes("documentcols")
				lie_1 = Split(liedata&";;;",";")(0)
				lie_2 = Split(liedata&";;;",";")(1)
				lie_3 = Split(liedata&";;;",";")(2)
			end if
		else
			lie_1 = app.getInt("lie_1")
			lie_2 = app.getInt("lie_2")
			lie_3 = app.getInt("lie_3")
		end if
		liedata=lie_1&";"&lie_2&";"&lie_3
		Response.write "" & vbcrlf & "     <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""0"" id=""content"" class=""docDetails detailTableList"">" & vbcrlf & "     <tr class=""tbheader"" style=""font-weight:bold"">" & vbcrlf & "              <td width=""5%""><div align=""center"">选择</div></td>" & vbcrlf & "          <td width=""5%""><div align=""center"">序号</div></td>" & vbcrlf & "             <td width=""20%""><div align=""center"">文件名称</div></td>" & vbcrlf & "             <td width=""15%""><div align=""center"">" & vbcrlf & "                        <select name=""lie_1"" id=""lie_1"" onchange=""javascript:select_psize(1)"" style=""FONT-WEIGHT: bold;"">" &  vbcrlf & "                   <option style=""color:#2f496e"" value=""0"" "
		if lie_1=0 then
			Response.write "selected"
		end if
		Response.write ">文件大小</option>" & vbcrlf & "                   <option style=""color:#2f496e"" value=""1"" "
		if lie_1=1 then
			Response.write "selected"
		end if
		Response.write ">文件类型</option>" & vbcrlf & "                   <option style=""color:#2f496e"" value=""2"" "
		if lie_1=2 then
			Response.write "selected"
		end if
		Response.write ">文档分类</option>" & vbcrlf & "                   <option style=""color:#2f496e"" value=""3"" "
		if lie_1=3 then
			Response.write "selected"
		end if
		Response.write ">关联文档</option>" & vbcrlf & "                   <option style=""color:#2f496e"" value=""4"" "
		if lie_1=4 then
			Response.write "selected"
		end if
		Response.write ">文档编号</option>" & vbcrlf & "                   </select>" & vbcrlf & "                       </div></td>" & vbcrlf & "             <td width=""10%""><div align=""center"">阅读/下载</div></td>" & vbcrlf & "            <td width=""10%""><div align=""center"">" & vbcrlf & "                        <select name=""lie_2"" id=""lie_2"" onchange=""javascript:select_psize(1)"" style=""FONT-WEIGHT: bold;"">" & vbcrlf & "                        <option style=""color:#2f496e"" value=""0"" "
		'Response.write "selected"
		if lie_2=0 then
			Response.write "selected"
		end if
		Response.write ">状态</option>" & vbcrlf & "                       <option style=""color:#2f496e"" value=""1"" "
		if lie_2=1 then
			Response.write "selected"
		end if
		Response.write ">有效期限</option>" & vbcrlf & "                   </select>" & vbcrlf & "                       </div></td>" & vbcrlf & "             <td width=""15%""><div align=""center"">" & vbcrlf & "                        <select name=""lie_3"" id=""lie_3"" onchange=""javascript:select_psize(1)"" style=""FONT-WEIGHT: bold;"">" & vbcrlf & "                       <option style=""color:#2f496e""value=""0"" "
		if lie_3=0 then
			Response.write "selected"
		end if
		Response.write ">添加人员</option>" & vbcrlf & "                   <option style=""color:#2f496e"" value=""1"" "
		if lie_3=1 then
			Response.write "selected"
		end if
		Response.write ">添加时间</option>" & vbcrlf & "                   </select>" & vbcrlf & "                       </div></td>" & vbcrlf & "             <td width=""20%""><div align=""center"">" & vbcrlf & "                        <select id=""sizepage"" name=""sizepage"" onchange=""select_psize(0)"" style=""FONT-WEIGHT: bold;"">" & vbcrlf & "                    <option style=""color:#2f496e"" value=""10"" "
		if Psize=10 then
			Response.write "selected"
		end if
		Response.write ">每页显示10条</option>" & vbcrlf & "                       <option style=""color:#2f496e"" value=""20"" "
		if Psize=20 then
			Response.write "selected"
		end if
		Response.write ">每页显示20条</option>" & vbcrlf & "                       <option style=""color:#2f496e"" value=""30"" "
		if Psize=30 then
			Response.write "selected"
		end if
		Response.write ">每页显示30条</option>" & vbcrlf & "                       <option style=""color:#2f496e"" value=""50"" "
		if Psize=50 then
			Response.write "selected"
		end if
		Response.write ">每页显示50条</option>" & vbcrlf & "                       <option style=""color:#2f496e"" value=""100"" "
		if Psize=100 then
			Response.write "selected"
		end if
		Response.write ">每页显示100条</option>" & vbcrlf & "                      <option style=""color:#2f496e"" value=""200"" "
		if Psize=200 then
			Response.write "selected"
		end if
		Response.write ">每页显示200条</option>" & vbcrlf & "                      </select>&nbsp;<input type=""checkbox"" id=""LockItems"" onClick=""setLockItems(this,'"
		Response.write lieData
		Response.write "')"" "
		if lieOpen="1" then
			Response.write " title=""取消标题栏"" checked "
		else
			Response.write " title=""默认标题栏"" "
		end if
		Response.write ">" & vbcrlf & "                    </div></td>" & vbcrlf & "     </tr>" & vbcrlf & "   "
		Dim mrecordcount ,rs ,pagecount ,helper ,remindIds ,rid ,canCancel
		If remind > 0 Then
			Set helper = CreateReminderHelper(cn, remind ,0)
			remindIds = helper.listSQL("ids_withOutOrderBy")
			strSql = strSql & " and id in ("& remindIds &")"
		end if
		Set rs = cn.execute("exec erp_document_flist "& Info.user &",'" & strSql & "'," & px & ","& Psize &", " & pageindex &"," & areamenu2)
		mrecordcount = rs.fields(0).value
		pagecount = (mrecordcount)\psize + Abs(CInt((mrecordcount) Mod psize>0))
		'mrecordcount = rs.fields(0).value
		If pageindex-pagecount>0 Then pageindex = pagecount
		'mrecordcount = rs.fields(0).value
		If mrecordcount=0 Then
			Response.write "<tr><td colspan='8' align='center' ><div class='lvw_nulldata'></div></td></tr></table><div class='bottomdiv' style='border-top:0px;'></div>"
'If mrecordcount=0 Then
			Exit Function
		else
			Set rs = rs.nextrecordset
			Dim n : n = 1
			Dim gdlist : gdlist=app.GetText("gdlist")
			Dim arrS : arrS = Split(gdlist&"","||")
			While rs.eof = False
				rid = 0
				canCancel = False
				If remind> 0 Then
					rid = helper.getRemindIdByOID(rs("id"))
					if helper.canCancelOrder(rid) Then canCancel=true
				end if
				Response.write "" & vbcrlf & "                     <tr><td><div align=""center""><input type=""checkbox"" name=""selectid"" value="""
				Response.write rs("id")
				Response.write """ class=""lvcbox""></div></td>" & vbcrlf & "                                <td><div align=""center"">"
				Response.write n
				Response.write "</div></td>" & vbcrlf & "                          <td><div align=""left"">"
				Response.write rs("oldname")
				If gdlist<>"" Then
					If InStr("," & arrS(0) & ",",","&rs("id")&",")>0 Or InStr("," & arrS(1) & ",",","&rs("id")&",")>0 Or InStr("," & arrS(2) & ",",","&rs("id")&",")>0 Then Response.write "&nbsp;<font color=red>不允许归档</font>"
				end if
				Response.write "" & vbcrlf & "                             </div></td>" & vbcrlf & "                             <td>"
				Select Case lie_1
				Case 0 :
				Response.write "<div align='center'>"
				WDSize=0
				If Len(rs("WDSize")&"")>0 Then WDSize=CDbl(rs("WDSize"))
				if WDSize>=1048576 then
					Response.write(formatNumB(WDSize/1048576,3) &"MB")
				elseif WDSize>=1024 then
					Response.write(formatNumB(WDSize/1024,3) &"KB")
				else
					Response.write(formatNumB(WDSize,3) &"B")
				end if
				Response.write "</div>"
				Case 1 : Response.write "<div align='center'>"&rs("WDType")&"</div>"
				Case 2 : Response.write "<div align='center'>"&GetFullSort(rs("sort"))&"</div>"
				Case 3 : Response.write "<div align='left'>"&documentLinkHTML(rs("pid"),rs("title"),rs("addcate"))&"</div>"
				Case 4 : Response.write "<div align='left'>"&documentLinkHTML(rs("pid"),rs("bh"),rs("addcate")) &"</div>"
				End Select
				Response.write "</td>" & vbcrlf & "                                <td><div align=""center"">"
				Response.write rs("readnum")&"/"&rs("downnum")
				Response.write "</div></td>" & vbcrlf & "                          <td><div align=""center"">"

				Select Case lie_2
				Case 0 :
				Select Case rs("zt")
				Case -1 : Response.write "审批未通过"
'Select Case rs("zt")
				Case 1  : Response.write "审批通过"
				Case 2  : Response.write "未审批"
				Case 3  : Response.write "审批中"
				Case 4  : Response.write "已归档"
				End Select
				Case 1 :
				If rs("l_validity")="2" Then
					Response.write "从："&rs("l_date3")&"<br>至："&rs("l_date4")
				else
					Response.write "永久"
				end if
				End Select
				Response.write "</div></td>" & vbcrlf & "                          <td><div align=""center"">"
				Select Case lie_3
				Case 0 : Response.write rs("addcatename")
				Case 1 : Response.write rs("date7")
				End Select
				Response.write "</div></td>" & vbcrlf & "                          <td><div align=""center"">"
				Response.write workButtonHTML(rs("s_yl"),rs("s_xz"),rs("s_gd"),rs("id"),rs("spFlag"),canCancel, rid , rs("addcate"))
				'Response.write "</div></td>" & vbcrlf & "                  "
				n = n + 1
				'Response.write "</div></td>" & vbcrlf & "                  "
				rs.movenext
			wend
			rs.close
			Response.write "" & vbcrlf & "             </table>" & vbcrlf & "                <div class='bottomdiv' style='border-top:0px;'>" & vbcrlf & "         <table class='bottomdiv' style='border-top:0px;width:100%'>" & vbcrlf & "             <tr>" & vbcrlf & "            "
			Response.write "</div></td>" & vbcrlf & "                  "
			if app.power.existsPower(78,20) Then
				Response.write "" & vbcrlf & "                     <td width=""8%"" height=""30""><div align=""center"">全选 <input name=""chkall"" type=""checkbox"" id=""chkall"" value=""all"" onclick=""checkall(this)"" /></div></td>" & vbcrlf & "                 <td width=""19%"" ><input type=""submit"" name=""Submit422"" value=""批量归档""  onclick=""setall(0);"" class=""oldbutton3""/></td>" & vbcrlf & "              "
			else
			end if
			Response.write "" & vbcrlf & "             <td width=""6%"">" & vbcrlf & "           <td width=""67%""><div align=""right"">" & vbcrlf & "         共"
			Response.write mrecordcount
			Response.write "条  &nbsp;"
			Response.write psize
			Response.write "/页  "
			Response.write pageindex
			Response.write "/"
			Response.write pagecount
			Response.write "页&nbsp;" & vbcrlf & "             <input name=""pindex"" id=""pindex""  type=text   onkeyup=""value=value.replace(/[^\d]/g,'')"" maxlength=""8"" size=""3"" value="""
    
			Response.write pageindex
			Response.write """" & vbcrlf & "                 onkeydown=""if(event.keyCode==13) return false;""" & vbcrlf & "           >" & vbcrlf & "               &nbsp;<input type=""button"" name=""Submit422"" value=""跳转"" onclick=""javascript:page_Pre_Next(document.getElementById('pindex').value)""  class=""oldbutton""/>" & vbcrlf & "         "
			if pageindex=1 then
				Response.write "" & vbcrlf & "                     <input type=""button"" name=""Submit4"" value=""首页""  class=""oldbutton""/> <input type=""button"" name=""Submit42"" value=""上一页""  class=""oldbutton""/>" & vbcrlf & "          "
			else
				Response.write "" & vbcrlf & "                     <input type=""button"" name=""Submit4"" value=""首页""  class=""oldbutton"" onClick=""page_Pre_Next(1)""/> <input type=""button"" name=""Submit42"" value=""上一页""  onClick=""page_Pre_Next("
				Response.write (pageindex-1)
				Response.write ")"" class=""oldbutton""/>" & vbcrlf & "              "
			end if
			if pageindex=pagecount then
				Response.write "" & vbcrlf & "                     <input type=""button"" name=""Submit43"" value=""下一页""  class=""oldbutton""/> <input type=""button"" name=""Submit44"" value=""尾页""  class=""oldbutton""/>" & vbcrlf & "         "
			else
				Response.write "" & vbcrlf & "                     <input type=""button"" name=""Submit43"" value=""下一页""  onClick=""page_Pre_Next("
				Response.write (pageindex+1)
				Response.write ");"" class=""oldbutton""/> <input type=""button"" name=""Submit43"" value=""尾页""  onClick=""page_Pre_Next("
				Response.write pagecount
				Response.write ")"" class=""oldbutton""/>" & vbcrlf & "              "
			end if
			Response.write "" & vbcrlf & "             &nbsp;" & vbcrlf & "          </div></td>" & vbcrlf & "             </tr>" & vbcrlf & "           </table>" & vbcrlf & "                </div>" & vbcrlf & "          "
		end if
		Set rs=Nothing
	end function
	function GetFullSort(sortID)
		dim rsf, rst, sortStr, id1, sort1
		sortStr=""
		Set rsf = cn.execute("select id1,sort1 from sortonehy where id=" & sortID)
		If rsf.Eof = False Then
			id1 = rsf(0)
			sort1 = TRIM(rsf(1))
			sortStr = sort1
			Dim sort_i
			For sort_i = 1 To 20
				Set rst=cn.execute("select id1,sort1 from sortonehy where id=" & id1)
				If rst.eof = true Then Exit For
				sortStr = TRIM(rst(1))& "-" & sortStr
				'If rst.eof = true Then Exit For
				id1 = rst(0)
				rst.Close
				Set rst = Nothing
			next
		end if
		rsf.Close
		Set rsf = Nothing
		GetFullSort = sortStr
	end function
	Function documentLinkHTML(id, bgtit, creator)
		Dim GetPowerB,GetPower
		If GetPowerB = "" Then
			GetPowerB = True
			GetPower = app.power.GetPowerIntro(78,14)
		end if
		If Len(GetPower) > 0 Then
			If InStr("," & GetPower & ",","," & creator & ",") > 0 And creator<>0 Then
				documentLinkHTML = "<a href='content.asp?ord=" & app.base64.pwurl(Id) & "' target='_blank'>" & bgtit & "</a>"
				else
					documentLinkHTML = bgtit
					end if
				else
					documentLinkHTML = "<a href='content.asp?ord=" & app.base64.pwurl(Id) & "' target='_blank'>" & bgtit & "</a>"
					end if
				end function
	Function workButtonHTML(yl, xz, gd, id,spFlag ,canCancel ,rid , addcate)
		Dim html,status
		spFlag = spFlag&""
		status = spFlag = "1" Or spFlag = "2" Or spFlag = "-1"
		'spFlag = spFlag&""
		If canCancel Then html = html & "<img src='../images/alt3.gif' alt='取消提醒' border='0' style='cursor:hand' onclick='cancelRemind("& rid &")'>"
		If yl = 1 Then html = html & "<input type=""button"" value=""预览"" class=""oldbutton2"" onclick=""javascript:window.open('preview.asp?ord=" & app.base64.pwurl(Id)  & "','xq','width=1100,height=700,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');""/> "
		If xz = 1 Then html = html & "<input type=""button"" value=""下载"" class=""oldbutton2"" onclick=""window.open('download.asp?ord=" & app.base64.pwurl(Id)  & "&fromtype=mxlist','sp');""/> "
		If gd <> 2 Then
			If app.power.existsPowerIntro(78,2 , addcate) And status Then
				html = html & "<input type=""button"" value=""修改"" class=""oldbutton2 fileUpdate-btn"" fid="""& id &""" pageType=""mxList"" onClick=""showUploadForm(this);"" /> "
'If app.power.existsPowerIntro(78,2 , addcate) And status Then
			end if
			If app.power.existsPowerIntro(78,3 , addcate) And status Then
				html = html & "<input type=""button"" value=""删除"" class=""oldbutton2 fileDel-btn"" fid='"& id &"' /> "
'If app.power.existsPowerIntro(78,3 , addcate) And status Then
			end if
		end if
		If gd = 1 Then
			html = html & "<input type=""button"" value=""归档"" class=""oldbutton2"" onclick=""javascript:setall("&Id&")"" /> "
		ElseIf gd = 2 Then
			html = html & "<input type=""button"" value=""取消归档"" class=""oldbutton3"" onclick=""javascript:setUnPlace("&Id&")"" /> "
		end if
		workButtonHTML = html
	end function
	Sub App_doSetall()
		Dim rs, ordlist, oSQL, pwgd ,s1,s2,s3
		s1="0"
		s2="0"
		s3="0"
		ordlist = app.GetText("ordlist")
		If Len(ordlist)>0 Then
			Set rs=cn.execute("select id from documentlist where id in ("& ordlist &" ) and archive=1 ")
			While rs.eof=False
				s1 = s1 & "," & rs(0)
				rs.movenext
			wend
			rs.close
			Set rs=cn.execute("select id from documentlist a where id in ("& ordlist &" ) and archive=0 and exists(select top 1 1 from document where id=a.document and spflag<>1) ")
			While rs.eof=False
				s2 = s2 & "," & rs(0)
				rs.movenext
			wend
			rs.close
			pwgd = app.power.GetPowerIntro(78,20)
			Set rs=cn.execute("select id from documentlist a where id in ("& ordlist &" ) and archive=0 and not exists(select top 1 1 from document where id=a.document and spflag=1 and ('" & pwgd & "'='' or charindex(','+ cast(addcate as varchar(10)) +',',',"& pwgd &",')>0)) ")
			'pwgd = app.power.GetPowerIntro(78,20)
			While rs.eof=False
				s3 = s3 & "," & rs(0)
				rs.movenext
			wend
			rs.close
			Response.write s1&"||"&s2&"||"&s3
			oSQL = "update a set a.archive=1,a.archcate="& Info.user &",a.archdate=getdate() from documentlist a inner join document b on b.id=a.document and b.del=1 and b.archive<>2 and b.spflag=1 and ( '" & pwgd & "'='' or charindex(','+ cast(b.addcate as varchar(10)) +',',',"& pwgd &",')>0 ) where a.archive=0 and a.id in ( "& ordlist &" ) "
			cn.Execute(oSQL)
			cn.execute("update document set archive=2,archcate="& Info.user &",archdate=getdate() where archive<>2 and id in (select distinct document from documentlist where id in ("&ordlist&")) and not exists(select top 1 1 from documentlist where archive=0 and document=document.id)")
			cn.execute("update document set archive=1,archcate="& Info.user &",archdate=getdate() where archive=0 and id in (select distinct document from documentlist where id in ("&ordlist&")) and exists(select top 1 1 from documentlist where archive=1 and document=document.id)")
		else
			Response.write("0")
		end if
		call db_close : Response.end()
	end sub
	Sub App_setUnplace()
		Dim rs, ordlist, oSQL, pwgd
		ordlist = app.GetText("ordlist")
		If Len(ordlist)>0 Then
			pwgd = app.power.GetPowerIntro(78,20)
			cn.execute("update documentlist set archive=0,archcate=0,archdate=null where id in ("& ordlist &") and ( '" & pwgd & "'='' or charindex(','+ cast(addcate as varchar(10)) +',',',"& pwgd &",')>0 )")
			'pwgd = app.power.GetPowerIntro(78,20)
			cn.execute("update document set archive=1,archcate="& Info.user &",archdate=getdate() where archive=2 and id in (select distinct document from documentlist where id in ("&ordlist&")) and exists(select top 1 1 from documentlist where archive=0 and document=document.id)")
			cn.execute("update document set archive=0,archcate="& Info.user &",archdate=getdate() where archive<>0 and id in (select distinct document from documentlist where id in ("&ordlist&")) and not exists(select top 1 1 from documentlist where archive=1 and document=document.id)")
			Response.write("1")
		else
			Response.write("0")
		end if
		call db_close : Response.end()
	end sub
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
	end Function
	
%>
