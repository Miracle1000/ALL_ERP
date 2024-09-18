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
'sql = sql & "CREATE TABLE " & tname & "(" & vbcrlf
				sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
				If i <  rs.fields.count -1 Then sql = sql & "," & vbcrlf
'sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
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
'nrs.addnew
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
'sql = sql & "CREATE TABLE " & tname & "(" & vbcrlf
				sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
				If i <  rs.fields.count -1 Then sql = sql & "," & vbcrlf
'sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
			next
			if CreateAutoField = true then
				sql = sql & ",[autokeyindex] [int] IDENTITY(1,1) NOT NULL" & vbcrlf
			end if
			sql = sql & ")" & vbcrlf
			sql = sql & "insert into " & tname & "("
			For i = 0 To rs.fields.count -1
'sql = sql & "insert into " & tname & "("
				sql = sql  & "[" & rs.fields(i).name & "]"
				If i <  rs.fields.count -1 Then sql = sql & ","
'sql = sql  & "[" & rs.fields(i).name & "]"
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
'sql = sql  & "[" & rs.fields(i).name & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
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
'Dim z : Set z = server.createobject(ZBRLibDLLNameSN & ".Library")
'z.GetLibrary "ZBIntel2013CheckBitString"
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
'Set ZBRuntime = app.Library
' 		If ZBRuntime.loadOK = False Then
' 			ZBRuntime.getLibrary "ZBIntel2013CheckBitString"
' 			If  ZBRuntime.loadOK = False then
' 				if app.isMobile then
' 					response.clear
' 					response.CharSet = "utf-8"
' 'response.clear
' 					Response.BinaryWrite app.base64.UnicodeToUtf8("系统【服务端】未正常启动，请检查服务器环境是否正常。")
' 					Response.end
' 				else
' 					Response.write "<script>top.window.location.href ='" & app.virpath & "index2.asp?id2=8'</script>"
' 				end if
' 				Set app = Nothing
' 				Set ZBRuntime = Nothing
' 				Exit Sub
' 			end if
' 		end if
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
	Dim productpower
	Class ReportGroupItem
		Public title
		Public sql
		Public gType
		Public dMode
		Public vname
	End Class
	Class ReportDataClass
		Public Function GetUrl(ByVal urlname)
			GetUrl = request(urlname)
		end function
		Public Function GetInt(ByVal urlname)
			GetInt = app.getInt(urlname)
		end function
		Public Function GetText(ByVal urlname)
			GetText = app.getText(urlname)
		end function
		Public Function GetSearchInt(ByVal urlname)
			GetSearchInt = app.getInt("rpt_f_"&urlname)
		end function
		Public Function GetSearchText(ByVal urlname)
			GetSearchText = app.getText("rpt_f_"&urlname)
		end function
	End Class
	Class ReportSettingPanel
		Private sets()
		Private mcount
		Private mcolset, mformulaset
		Public Property Get colset
		colset = mcolset
		End Property
		Public Property let colset(mvalue)
		If mvalue = mcolset Then Exit Property
		mcolset = mvalue
		If mvalue Then
			add "基本设置", "@@colset"
		else
			remove "@@colset"
		end if
		End Property
		Public Property Get formulaset
		formulaset = mformulaset
		End Property
		Public Property let formulaset(mvalue)
		If mvalue = mformulaset Then Exit Property
		mformulaset = mvalue
		If mvalue Then
			add "公式设置", "@@formulset"
		else
			remove "@@formulset"
		end if
		End Property
		Public Sub remove(ByVal keytxt)
			Dim i, item, selecti
			selecti = -1
'Dim i, item, selecti
			For i = 0 To mcount-1
'Dim i, item, selecti
				item = Split(sets(i),Chr(1))
				If ubound(item) > 0 Then
					If item(1) = keytxt Then
						selecti = i
						Exit For
					end if
				end if
			next
			If selecti >= 0 Then
				mcount = mcount - 1
'If selecti >= 0 Then
				For i = selecti To ubound(sets)-1
'If selecti >= 0 Then
					sets(i) = sets(i+1)
'If selecti >= 0 Then
				next
				ReDim Preserve sets(ubound(sets)-1)
'If selecti >= 0 Then
			end if
		end sub
		Public Property Get Count
		Count = mcount
		End Property
		Public Sub Add(ByVal title, ByVal msgid)
			ReDim Preserve sets(mcount)
			sets(mcount) = title & Chr(1) & msgid
			mcount = mcount + 1
'sets(mcount) = title & Chr(1) & msgid
		end sub
		Public Default Property Get Item(ByVal i)
		Item = Split(sets(i),Chr(1))
		End property
		Public Sub Class_Initialize
			mcount = 0
			colset = True
			formulaset = false
		end sub
		Public Sub clear
			mcount = 0
			Erase sets
		end sub
	End Class
	Class ReportClass
		Public title
		Dim n1 , n2, n3 , n4, n5, n6, n7
		Dim groups
		Dim mgate
		Public groupCount
		Public fieldCount
		Public canExcel
		Public canPrint
		Public cancolset
		Public cancopy
		Public toolminWidth
		Public firstSpace
		Public bodywidth
		Public aSearch
		Private ajaxReturn
		Private mBillListUIModel
		Private mfinanceUIModel
		Private mSettings
		Public sql
		Public headHTML
		Public buttonsHTML
		Public beforeBtnsHTML
		Public bottomhtml
		Public nosearchBar
		Public adSearchAutoHide
		Public PageButtonAlign
		Public fullWidthMode
		Public onlyadSearchModel
		public mSorts
		Public showtoppagesize
		Public ckboxdbname
		Public batbuttons
		Public oldReportUI
		Private mPageSize
		Public canflick
		Public cansearch
		Public searchbtntext
		Public fixHeader
		Public excelextIntro
		public mobReport
		Public SortUiType
		Public ServerLinkCols
		Public jsonEditModel
		Public Property Get Settings
		Set Settings = mSettings
		End Property
		Public Property Get PageSize
		PageSize = mPageSize
		End Property
		Public Property let PageSize(nvalue)
		mPageSize = nvalue
		If nvalue = 10 Then
			oldReportUI = true
		end if
		End Property
		Public Property Let BillListUIModel(nv)
		mBillListUIModel = nv
		If mBillListUIModel = true Then
			showtoppagesize = false
			PageSize = 10
		else
			showtoppagesize = true
			PageSize = 20
		end if
		End Property
		Public Property get BillListUIModel
		BillListUIModel = mBillListUIModel
		End Property
		Public Property get financeUIModel
		financeUIModel = mfinanceUIModel
		End Property
		Public Property let financeUIModel(nv)
		mfinanceUIModel = nv
		BillListUIModel = nv
		showtoppagesize = True
		End Property
		Public Function AddSort(ByVal name, ByVal value)
			Dim cx, jschars, i
			jschars = Split(vbcr & " " & vblf & " \ "" < >", " ")
			For i = 0 To ubound(jschars)
				name = Replace(name, jschars(i), "\u00" & Hex(Asc(jschars(i))))
			next
			If Not isarray(msorts) Then
				ReDim msorts(0)
				msorts(0) = name & Chr(1) & value
			else
				cx = ubound(msorts)+1
				msorts(0) = name & Chr(1) & value
				ReDim Preserve msorts(cx)
				msorts(cx) = name & Chr(1) & value
			end if
		end function
		Public Sub AddSortByCol : AddSort "__col__", "__col__" : End sub
		Public Function addMobSearch(ByVal id, ByVal mvalue, ByVal mdescription ,ByVal post)
			If Me.mobReport Is Nothing Then Exit Function
			With Me.mobReport.search.keybox
			.id = id
			.value =  mvalue
			.description= mdescription
			.post = post
			End With
		end function
		Public Function AddTool(ByVal caption, ByVal ico, ByVal action,ByVal  url, ByVal method, ByVal target)
			If Me.mobReport Is Nothing Then Exit Function
			Set AddTool = Me.mobReport.addTool(caption,  ico,  action,  url,  method,  target)
		end function
		Public Function addMobGroup(ByVal caption, ByVal mvalue, ByVal action,ByVal url, ByVal method)
			If Me.mobReport Is Nothing Then Exit Function
			Me.mobReport.addGroup caption, mvalue, action, url, method
		end function
		Public Function getGroupsData
			Dim i, obj , o
			If  groupCount = 0 Then Exit function
			ReDim o(groupCount - 1)
'If  groupCount = 0 Then Exit function
			For i = 0 To groupCount - 1
'If  groupCount = 0 Then Exit function
				Set obj = groups(i)
				o(i) = obj.title & "^!^%" & obj.sql & "^!^%" & obj.gType & "^!^%" & obj.dMode & "^!^%" & obj.vname
			next
			getGroupsData = Join(o, "#^%!!")
		end function
		Public Function getselDataBySql(ByVal sql)
			Dim rs, r, i
			i = 0
			ReDim r(0)
			If Me.financeUIModel = True Then
				Set rs = app.cRecord(sql)
			else
				Set rs = cn.execute(sql)
			end if
			While rs.eof = False
				ReDim Preserve r(i)
				r(i) = rs.fields(0).value & Chr(1) & rs.fields(1).value
				i = i + 1
'r(i) = rs.fields(0).value & Chr(1) & rs.fields(1).value
				rs.movenext
			wend
			rs.close
			getselDataBySql = Join(r, Chr(2))
		end function
		Public Function getselDataByTxt(ByVal txt)
			txt = Replace(txt & "", "&,", Chr(3))
			getselDataByTxt = Replace(Replace(Replace(Replace(txt, ";", Chr(2)), ",", Chr(2)), "=", Chr(1)), Chr(3), ",")
		end function
		Private Sub Class_Initialize()
			ReDim n1(0) , n2(0), n3(0), n4(0), n5(0), n6(0), n7(0)
			ReDim groups(0)
			fieldCount = 0
			groupCount = 0
			jsonEditModel = false
			canExcel = True
			canPrint = True
			cancolset = False
			cancopy = True
			firstSpace = 80
			ajaxReturn = False
			nosearchBar = False
			adSearchAutoHide = false
			PageButtonAlign = "left"
			Set aSearch = New AdvanceSearchClass
			PageSize = 20
			fullWidthMode = False
			onlyadSearchModel = False
			showtoppagesize = True
			mBillListUIModel = False
			mfinanceUIModel = False
			canflick = False
			cansearch = True
			searchbtntext = "检索"
			excelextIntro = ""
			fixHeader = False
			Set mSettings = New ReportSettingPanel
			Set mobReport = Nothing
			SortUiType = 0
		end sub
		Private Sub Class_Terminate()
			Set aSearch = Nothing
			Set mSettings = nothing
		end sub
		Public Function addgroup(title, sql, gt, dm, vname)
			ReDim Preserve groups(groupCount)
			Dim obj : Set obj = New ReportGroupItem
			Set groups(groupCount) =  obj
			obj.title = title
			obj.sql = sql
			obj.gType=gt
			obj.dMode = dm
			obj.vname = vname
			groupCount = groupCount + 1
'obj.vname = vname
			Set addgroup = obj
		end function
		Public function AddField(fName, fType, fKey, ftag, cEvent, defv)
			Dim c : c = fieldCount
			ReDim Preserve n1(c), n2(c), n3(c), n4(c), n5(c) , n6(c), n7(c)
			n1(c) = fname
			n2(c) = fType
			n3(c) = fKey
			n4(c) = ftag
			n5(c) = cEvent
			n6(c) = defv
			AddField = c
			fieldCount = fieldCount  + 1
'AddField = c
		end function
		Public function AddField2(fName, fType, fKey, ftag, cEvent, defv, nullMsg)
			Dim c : c = AddField(fName, fType, fKey, ftag, cEvent, defv)
			n7(c) = nullMsg
		end function
		Public Function SetNullMsg(findex, value)
			n7(findex) = value
		end function
		Function ExistsField(item)
			Dim i
			ExistsField = False
			For i = 0 To fieldCount-1
'ExistsField = False
				If LCase(n3(i)) = LCase(item) Then
					If n2(i) = "dates" Or n2(i) = "datetimes" Or n2(i) = "datetime" Then
						n6(i) = Split(Request.QueryString(item),",")
					else
						n6(i) = Request.QueryString(item)
					end if
					ExistsField = True
					Exit For
				end if
			next
		end function
		public Sub AutoAddUrlParam
			Dim item
			For Each item In Request.QueryString
				If ExistsField(item) = False Then
					Call AddField("", "URLText", item, "", "", Request.QueryString(item))
				end if
			next
		end sub
		Public Sub ajaxUpdateField(fName, fType, fKey, ftag, cEvent, defv)
			Dim c : c = fieldCount
			ReDim Preserve n1(c), n2(c), n3(c), n4(c), n5(c) , n6(c), n7(c)
			n1(c) = fname
			n2(c) = fType
			n3(c) = fKey
			n4(c) = ftag
			n5(c) = cEvent
			n6(c) = defv
			fieldCount = fieldCount  + 1
'n6(c) = defv
			ajaxReturn = True
			Response.write fkey & Chr(3) & Chr(1)
			Call showFields()
		end sub
		Public Sub ajaxUpdateField2(fName, fType, fKey, ftag, cEvent, defv, nullMsg)
			Dim c : c = fieldCount
			ReDim Preserve n1(c), n2(c), n3(c), n4(c), n5(c) , n6(c), n7(c)
			n1(c) = fname
			n2(c) = fType
			n3(c) = fKey
			n4(c) = ftag
			n5(c) = cEvent
			n6(c) = defv
			n7(c) = nullMsg
			fieldCount = fieldCount  + 1
'n7(c) = nullMsg
			ajaxReturn = True
			Response.write fkey & Chr(3) & Chr(1)
			Call showFields()
		end sub
		Public Sub AddHtmlField(html)
			Dim c : c = fieldCount
			ReDim Preserve n1(c), n2(c), n3(c), n4(c), n5(c) , n6(c), n7(c)
			n1(c) = "html" & fieldCount
			n2(c) = "html"
			n4(c) = html
			fieldCount = fieldCount  + 1
'n4(c) = html
		end sub
		Private Function cdatestr(ByVal v)
			If Len(v) > 0 Then
				v = Replace(v,"/","-")
'If Len(v) > 0 Then
				v = Replace(v,".","-")
'If Len(v) > 0 Then
				v = Replace(v,"年","-")
'If Len(v) > 0 Then
				v = Replace(v,"月","-")
'If Len(v) > 0 Then
				v = Replace(v,"日"," ")
				v = Replace(v,"上午"," ")
				v = Replace(v,"下午"," ")
				v = Replace(v,"AM"," ")
				v = Replace(v,"PM"," ")
				v = Replace(v,"  "," ")
				cdatestr = v
			end if
		end function
		Public Sub showFields()
			Dim i, row, item, ii, v, ft
			Dim vcount ,minvalue , maxvalue
			vcount = fieldCount
			For i = 0 To fieldCount-1
'vcount = fieldCount
				ft = n2(i)
				If ft="datetimes" Then ft="dates"
				If ajaxReturn = False Then Response.write "<div nowrap class='sfield' ftype='" & ft & "' id='sfields_" & n3(i) & "'>"
				v = n6(i)
				Select Case n2(i)
				Case "html"
				Response.write  n4(i)
				vcount = vcount - 1
				Response.write  n4(i)
				Case "radio"
				Response.write "<table style='table-layout:auto;width:auto'><tr>"
'Case "radio"
				If n1(i)<> "" Then Response.write "<td>" & n1(i) & "</td>"
				Response.write "<td>"
				Response.write asearch.GetListInputHtml(n3(i), n4(i), "radio",v)
				Response.write "</td></tr></table>"
				Case "months"
				If Len(n1(i)) = 0 Then n1(i) = "自："
				If ubound(v)>1 Then minvalue = v(2)
				If ubound(v)>2 Then maxvalue = v(3)
				Response.write "" & vbcrlf & "                                     <table style='table-layout:auto;width:auto'><tr>" & vbcrlf & "                                        <td>"
'If ubound(v)>2 Then maxvalue = v(3)
				Response.write n1(i)
				Response.write "</td>" & vbcrlf & "                                        <td><input type='text' id='"
				Response.write n3(i)
				Response.write "_v_0' onmousedown='datedlg.showYearMonth(this)' onchange=""datedlg.setRange('"
				Response.write n3(i)
				Response.write "_v_0','"
				Response.write n3(i)
				Response.write "_v_1',1,'months')""  minDate="""
				Response.write minValue
				Response.write """ maxDate="""
				Response.write maxvalue
				Response.write """ max readonly size='8' maxlength=10 value='"
				Response.write v(0)
				Response.write "'></td>" & vbcrlf & "                                      <td>至：</td>" & vbcrlf & "                                   <td><input type='text' id='"
				Response.write n3(i)
				Response.write "_v_1' onmousedown='datedlg.showYearMonth(this)' onchange=""datedlg.setRange('"
				Response.write n3(i)
				Response.write "_v_0','"
				Response.write n3(i)
				Response.write "_v_1',2,'months')"" minDate="""
				Response.write minValue
				Response.write """ maxDate="""
				Response.write maxvalue
				Response.write """ readonly size='8' maxlength=10 value='"
				Response.write v(1)
				Response.write "'></td>" & vbcrlf & "                                      </tr></table>" & vbcrlf & "                                   "
				Case "date"
				Response.write "" & vbcrlf & "                                     <table style='table-layout:auto;width:auto'><tr>" & vbcrlf & "                                        <td>"
'Case "date"
				Response.write n1(i)
				Response.write "</td>" & vbcrlf & "                                        <td><input type='text' id='"
				Response.write n3(i)
				Response.write "_v_0' onmousedown='datedlg.show()' readonly size='10' maxlength=10 value='"
				Response.write cdatestr(v)
				Response.write "'></td>" & vbcrlf & "                                      </tr></table>" & vbcrlf & "                                   "
				Case "dates"
				If Len(n1(i)) = 0 Then n1(i) = "自："
				Response.write "" & vbcrlf & "                                     <table style='table-layout:auto;width:auto'><tr>" & vbcrlf & "                                        <td>"
'If Len(n1(i)) = 0 Then n1(i) = "自："
				Response.write n1(i)
				Response.write "</td>" & vbcrlf & "                                        <td><input type='text' id='"
				Response.write n3(i)
				Response.write "_v_0' onmousedown='datedlg.show()' readonly size='10' maxlength=10 value='"
				Response.write cdatestr(v(0))
				Response.write "'></td>" & vbcrlf & "                                      <td>至：</td>" & vbcrlf & "                                   <td><input type='text' id='"
				Response.write n3(i)
				Response.write "_v_1' onmousedown='datedlg.show()' readonly size='10' maxlength=10 value='"
				Response.write cdatestr(v(1))
				Response.write "'></td>" & vbcrlf & "                                      </tr></table>" & vbcrlf & "                                   "
				Case "datetimes"
				If Len(n1(i)) = 0 Then n1(i) = "自："
				Response.write "" & vbcrlf & "                                     <table style='table-layout:auto;width:auto'><tr>" & vbcrlf & "                                        <td>"
'If Len(n1(i)) = 0 Then n1(i) = "自："
				Response.write n1(i)
				Response.write "</td>" & vbcrlf & "                                        <td><input type='text' onmousedown='datedlg.showDateTime()' readonly size='18' maxlength=20 value='"
				Response.write cdatestr(v(0))
				Response.write "'></td>" & vbcrlf & "                                      <td>至：</td>" & vbcrlf & "                                   <td><input type='text' onmousedown='datedlg.showDateTime()' readonly size='18' maxlength=20 value='"
				Response.write cdatestr(v(1))
				Response.write "'></td>" & vbcrlf & "                                      </tr></table>" & vbcrlf & "                                   "
				Case "datetime"
				If Len(n1(i)) = 0 Then n1(i) = "自："
				Response.write "" & vbcrlf & "                                     <table style='table-layout:auto;width:auto'><tr>" & vbcrlf & "                                        <td>"
'If Len(n1(i)) = 0 Then n1(i) = "自："
				Response.write n1(i)
				Response.write "</td>" & vbcrlf & "                                        <td><input type='text' onmousedown='datedlg.showDateTime()' readonly size='15' maxlength=10 value='"
				Response.write cdatestr(v(0))
				Response.write "'></td>" & vbcrlf & "                                      <td>至：</td>" & vbcrlf & "                                   <td><input type='text' onmousedown='datedlg.showDateTime()' readonly size='15' maxlength=10 value='"
				Response.write cdatestr(v(1))
				Response.write "'></td>" & vbcrlf & "                                      </tr></table>" & vbcrlf & "                                   "
				Case "select"
				Call createSelectSearchField(i, "select")
				Case "sortonehy":
				Call createSelectSearchField(i, "sortonehy")
				Case "text"
				Response.write "<div style='float:left;'><div style='float:left;padding-right:2px'>" & n1(i) & "</div><input type=text maxlength=100 size=15 value='" & v & "'></div>"
'Case "text"
				Case "URLText"
				Response.write "<div style='float:left;display:none;'>" & n1(i) & "<input type=text maxlength=100 size=15 value='" & v & "'></div>"
				Case "rate"
				If Len(n1(i)) > 0 Then
					Response.write "<div style='float:left;'>" & n1(i) & "：</div>"
				end if
				Response.write "<div style='float:left;'><input type='text' style='text-align:center' onpropertychange='formatData(this,""float"")' maxlength=5 size=3 value='" & v & "'>"
				If Len(n3(i)) > 0 Then
					Response.write n4(i) & "&nbsp;"
				end if
				Response.write "</div>"
				Case "gategroup"
				Call GateGroupSelBox(n1(i), n3(i), 1)
				Case "gategroup2"
				Call GateGroupSelBox(n1(i), n3(i), 2)
				Case "gategroup3"
				Call GateGroupSelBox(n1(i), n3(i), 3)
				Case "gategroup4"
				Call GateGroupSelBox(n1(i), n3(i), 4)
				Case "telcls"
				Call telclsSelBox(n1(i), n3(i))
				Case "stores"
				Call showStoresField ( n1(i), n3(i) )
				case "hidden"
				Response.write "<input type=hidden value='" & v & "'>"
				End Select
				If ajaxReturn = False Then  Response.write "</div>"
				If n2(i) <> "URLText" And n2(i) <> "hidden" then Response.write "<div class='sfield' style='width:6px'></div>"
			next
			If ajaxReturn = False And vcount >0 Then  Response.write "<div class='ser_btn'  style='float:left;'><input type=submit class='oldbutton' value='" & Me.searchbtntext & "' onclick='searchQuickClick()'></div><div style='float:left'></div>"
		end sub
		Private Sub showStoresField(ByVal lname, ByVal id)
			Response.write "<table style='table-layout:auto;width:auto'><tr><td>" & lname & "</td><td>&nbsp;"
'Private Sub showStoresField(ByVal lname, ByVal id)
			Response.write "<LABEL id='sfields_" & id & "_txt'>选择仓库</LABEL></td><td>"
			Response.write "<IMG onclick=selectCK(this,event); style='CURSOR: hand; border:0px;width:16px' src='../images/11645.png' mi='sfields_" & id & "' mid='0'>"
			Response.write "<INPUT id='sfields_" & id & "_v' name='sfields_" & id & "_n' type=hidden>"
			Response.write "</td><td>&nbsp;</td>"
			Response.write "</tr></table>"
		end sub
		Private Sub telclsSelBox(ByVal lname , ByVal Id)
			Dim rs, rs2, glistHTML
			Response.write "<table style='table-layout:auto;width:auto'><tr><td><!-名称--></td><td>"
'Dim rs, rs2, glistHTML
			Response.write "<select id='sfields_" & id & "_g1' onchange='gategroup1change(this)'><option value=''>=不限=</option>"
			Set rs = cn.execute("select ord, sort1 from sort4 order by gate1 desc")
			While rs.eof = False
				glistHTML = ""
				Set rs2 = cn.execute("select ord, sort2 from sort5 where sort1=" &  rs(0).value & " order by gate2 desc")
				While rs2.eof = False
					If Len(glistHTML) > 0 Then
						glistHTML = glistHTML & "|*|"
					end if
					glistHTML = glistHTML & rs2(0).value & "$#%" & rs2(1).value
					rs2.movenext
				wend
				rs2.close
				Response.write "<option value='" & rs(0).value & "' gatelist=""" & glistHTML & """>" & rs(1).value & "</option>"
				rs.movenext
			wend
			rs.close
			Response.write "</select></td><td><select id='sfields_" & Id & "_g2'><option value=''>==不限==</option></select></td></tr></table>"
		end sub
		Private Sub GateGroupSelBox(ByVal lname, ByVal Id, ByVal sType)
			Response.write "<table style='table-layout:auto;width:auto'><tr><td>" & lname & "</td><td>"
'Private Sub GateGroupSelBox(ByVal lname, ByVal Id, ByVal sType)
			Response.write "<select id='sfields_" & id & "_g1' onchange='gategroup1change(this)'><option value=''>=不限=</option>"
			Dim rs, rs2, open_1_1, w1, w2, w3, glistHTML
			open_1_1=0
			Set rs = cn.execute("select sort1,qx_open,w1,w2,w3 from power2  where cateid="& Info.user &" and sort1=" & sType)
			if rs.eof = false then
				open_1_1=rs("qx_open").value
				w1=rs("w1").value
				w2=rs("w2").value
				w3=rs("w3").value
			end if
			rs.close
			if open_1_1=1 then
				w1="where ord in ("&w1&")"
				w2="and ord in ("&w2&")"
			elseif open_1_1=3 then
				w1=""
				w2=""
				w3=""
			else
				Exit sub
			end if
			Set rs = cn.execute("select ord, sort1 from gate1 " & w1 & " order by gate1 desc")
			While rs.eof = False
				glistHTML = ""
				Set rs2 = cn.execute("select ord, sort2 from gate2 where sort1=" &  rs(0).value & " " & w2 & " order by gate2 desc")
				While rs2.eof = False
					If Len(glistHTML) > 0 Then
						glistHTML = glistHTML & "|*|"
					end if
					glistHTML = glistHTML & rs2(0).value & "$#%" & rs2(1).value
					rs2.movenext
				wend
				rs2.close
				Response.write "<option value='" & rs(0).value & "' gatelist=""" & glistHTML & """>" & rs(1).value & "</option>"
				rs.movenext
			wend
			rs.close
			Response.write "</select></td><td><select id='sfields_" & Id & "_g2'><option value=''>==不限==</option></select></td></tr></table>"
		end sub
		Private Sub createSelectSearchField(ByVal i, ByVal dataMode)
			Dim ii, row, rs, item, v, nullv, nullv_n, nullv_v
			v = n6(i) & ""
			nullv = n7(i)
			If InStr(nullv,"=") > 0 Then
				nullv_n = Split(nullv, "=")(0)
				nullv_v = Split(nullv, "=")(1)
				If  Len(nullv_v) > 0 Then
					If isnumeric(nullv_v) Or InStr(nullv_v,"#")=1 Then
						nullv = Replace(Chr(1) & nullv_n, Chr(1) & "#", "")
						nullv_v = Replace(Chr(1) & nullv_v, Chr(1) &  "#", "")
						nullv = Replace(nullv, Chr(1), "")
						nullv_v = Replace(nullv_v, Chr(1), "")
					end if
				end if
			end if
			Response.write "<div style='float:left;'>"
			If Len(n1(i)) > 0 Then
				Response.write "<div style='float:left;padding-top:3px'>" & n1(i) & "</div>"
'If Len(n1(i)) > 0 Then
			end if
			If Len(n5(i)) = 0 then
				Response.write "<div style='float:left;'><select id='fsitem_" & n3(i) & "'>"
			else
				Response.write "<div style='float:left;'><select id='fsitem_" & n3(i) & "' onchange='joinFieldUpdate(""" & n5(i) & """, this.value, this)'>"
			end if
			Select Case dataMode
			Case "select"
			If Len(n4(i)) = 0 Then
				If nullv <> "null" then
					If Len(nullv) = 0 Then  nullv = "--无--"
'If nullv <> "null" then
					Response.write "<option value='" & nullv_v & "'>" & nullv & "</option>"
				end if
			else
				row = Split(n4(i), Chr(2))
				If nullv <> "null" then
					If Len(nullv) = 0 Then  nullv = "==不限=="
					Response.write "<option value='" & nullv_v & "' title='"& nullv &"'>" & nullv & "</option>"
				end if
				For ii = 0 To ubound(row)
					item = Split(row(ii),Chr(1))
					If v=item(1) Then
						Response.write "<option value='" & item(1) & "' selected title='"& item(0) &"'>" & item(0) & "</option>"
					else
						Response.write "<option value='" & item(1) & "' title='"& item(0) &"'>" & item(0) & "</option>"
					end if
				next
			end if
			Case "sortonehy"
			Set rs = cn.execute("select sort1, ord from sortonehy where gate2=" & n4(i) & " order by gate1 desc")
			If rs.eof = true Then
				If nullv <> "null" then
					If Len(nullv) = 0 Then  nullv = "--无--"
'If nullv <> "null" then
					Response.write "<option value='" & nullv_v & "'>" & nullv & "</option>"
				end if
			else
				If nullv <> "null" then
					If Len(nullv) = 0 Then  nullv = "==不限=="
					Response.write "<option value='" & nullv_v & "' selected>" & nullv & "</option>"
				end if
				While rs.eof = False
					If v=rs(1).value&"" Then
						Response.write "<option value='" & rs(1).value & "' selected>" & rs(0).value & "</option>"
					else
						Response.write "<option value='" & rs(1).value & "'>" & rs(0).value & "</option>"
					end if
					rs.movenext
				wend
			end if
			rs.close
			End select
			Response.write "</select></div></div>"
		end sub
		Public Sub setBatHandle(ByVal ckbox_dbname, ByVal bat_buttons)
			ckboxdbname = ckbox_dbname
			batbuttons = bat_buttons
		end sub
		Private Function GetASearchApiRemark(ByVal fd, ByRef df)
			Dim result
			Select Case LCase(fd.ftype)
			Case "select"
			If InStr(fd.fsql,"options:")=1 Then
				result = "整数，默认为空，枚举类型：" & Replace(fd.fsql, "options:", "")
				on error resume next
				df = Split(Split(replace(fd.fsql,"options:",""),";")(0),"=")(1)
			else
				result = "整数，默认为空，" & fd.fsql
			end if
			Case "sortonehy"
			result = "文本，默认为空，多选项检索条件，枚举类型，多个值之间用逗号隔开(如：11,23...)。<br>枚举数据接口：<a href='" & app.virpath & "mobilephone/source.asp?enumid=" & fd.fsql & "&apihelp=1' target=_blank>/mobilephone/source.asp?enumid=" & fd.fsql & "</a>"
			Case "text"
			result = "文本，默认为空，模糊检索条件"
			Case "checks"
			result = "文本，默认为空，多选项检索条件，枚举类型，多个值之间用逗号隔开。<br>"
			If InStr(fd.fsql&"","options:") Then
				result = result & "如："& Replace(fd.fsql&"","options:","")
			else
				result = result & "枚举数据接口：<a style='word-wrap:break-word' href='" & app.virpath & "mobilephone/source.asp?enumsrc=" & server.urlencode(app.base64.EncodeText(fd.fsql,"xifcx")) & "&cls=table&apihelp=1' target=_blank>/mobilephone/source.asp?cls=table&enumsrc=******</a>"
				result = result & "如："& Replace(fd.fsql&"","options:","")
			end if
			Case "source"
			result = "文本，默认为空，多选项检索条件，枚举类型，多个值之间用逗号隔开(如：11,23...)。<br>枚举数据接口：<a href='" & app.virpath & "" & fd.fsql & "&apihelp=1' target=_blank>/" & fd.fsql & "</a>"
			Case Else
			result = fd.ftype
			End Select
			GetASearchApiRemark = result
		end function
		Public Sub showReportHelpApi()
			Dim fd, i, remark, defv
			For i = 0 To asearch.fieldCount - 1
'Dim fd, i, remark, defv
				Set fd = asearch.GetField(i)
				defv = "": remark = GetASearchApiRemark(fd, defv)
				Select Case fd.ftype
				Case "rangebox"
				app.mobile.addHelpField  fd.fKey & "_0",  fd.fname & "上限", "数字，该条件允许为空，表示无穷小", defv
				app.mobile.addHelpField  fd.fKey & "_1",  fd.fname & "下限", "数字，该条件允许为空，表示无穷大", defv
				Case "dates" ,"datetimes"
				app.mobile.addHelpField  fd.fKey & "_0",  fd.fname , "文本，默认为空，日期段检索条件（起始日期）", defv
				app.mobile.addHelpField  fd.fKey & "_1",  fd.fname , "文本，默认为空，日期段检索条件（截止日期）", defv
				case else
				app.mobile.addHelpField  fd.fKey,  fd.fname, remark, defv
				End Select
			next
			on error resume next
			If Len(Me.mobReport.search.keybox.id)>0 Then
				app.mobile.addHelpField  Me.mobReport.search.keybox.id,  "快速检索条件", "文本，对返回列表中所有文本列进行匹配筛选，默认为空", ""
			end if
			On Error GoTo 0
			app.mobile.addHelpField "pagesize", "每页记录数", "整型，列表分页参数，默认为空，则每页显示20条记录", "20"
			app.mobile.addHelpField "pageindex", "数据页标", "整型，列表分页参数，表示返回第几页数据，默认为空，则返回第1页数据", "1"
			app.mobile.addHelpField "_rpt_sort", "排序字段", "文本，列表排序条件，内容为列名称，即和返回对象中的source.table.cols[n].id值相同，该内容前加负号表示倒序，不加表示正序，默认可为空，示例-sortcol，表示按结果中的sortcol列倒序（注：该排序是数据库范围内排序，并非返回结果范围内排序）", ""
'app.mobile.addHelpField "pageindex", "数据页标", "整型，列表分页参数，表示返回第几页数据，默认为空，则返回第1页数据", "1"
			Select Case LCase(request.querystring("reportmodel"))
			Case "tree"
			call ShowApihelp(me.title, "<trees>SourceClass", "refresh")
			Case Else
			call ShowApihelp(me.title, "<table>SourceClass", "refresh")
			End select
		end sub
	End Class
	Class BatResultClass
		Public RefreshList
		Private m_msgs, m_ids, count
		Private Sub Class_Initialize()
			RefreshList = True
			ReDim m_msgs(0)
			ReDim m_ids(0)
			count = 0
		end sub
		Public Sub AddResult(message, keyid, color)
			Dim i
			For i = 0 To count-1
'Dim i
				If m_msgs(i) = message & Chr(1) & color Then
					If Len(m_ids(i)) > 0 Then
						m_ids(i) = m_ids(i) & "," & keyid
					else
						m_ids(i) =  keyid
					end if
					Exit sub
				end if
			next
			ReDim Preserve m_msgs(count)
			ReDim Preserve m_ids(count)
			m_msgs(count) = message & Chr(1) & color
			m_ids(count) = keyid
			count = count + 1
'm_ids(count) = keyid
		end sub
		Public Sub WriteScript
			Dim i
			Response.write "__rpt_addBatResultClear();"
			For i = 0 To count-1
				Response.write "__rpt_addBatResultClear();"
				Response.write "__rpt_addBatResult(""" & Replace(m_msgs(i), Chr(1), """,""") & """,""" &  m_ids(i) & """," & Abs(Not RefreshList) & ");"
			next
			If RefreshList Then
				Response.write "__rpt_BatResultRefreshList();"
			end if
		end sub
	End class
	Class customSetFieldClass
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
		Set rs = cn.execute(sql)
		While rs.eof = False
			Set field = New customSetFieldClass
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
		hasOpenZdy = (cn.execute("select 1 from zdy where sort1="& sort &" and set_open = 1 ").eof = false)
	end function
	Function GetZdyFields(sort)
		If sort&""="" Then sort = 1
		Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim rs ,sql, field
		sql = "select * from zdy where sort1="& sort &" order by gate1 asc "
		Set rs = cn.execute(sql)
		While rs.eof = False
			Set field = New customSetFieldClass
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
		If sort = 21 Then
			sql = "SELECT 1  FROM dbo.sys_sdk_BillFieldInfo WHERE BillType =16001 AND IsUsed = 1"
		else
			sql = "select 1 from ERP_CustomFields where TName="& sort &" and IsUsing=1 and del=1"
		end if
		hasOpenExtra = (cn.execute(sql).eof = False)
	end function
	Function GetExtraFields(sort)
		If sort&""="" Then sort = 1
		Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim rs ,sql, field
		if sort = 21 then
			sql = "select dbname ,id, isused,title , MustFillin , "&_
			"   case when charindex('ext',dbname)>0 then replace(dbname,'ext','') else isnull((select gl from zdy where sort1=21 and name=a.dbname),0) end extra ,"&_
			"   case isnull(UiType,0) when 0 then 1 when 10 then 2 when 1 then 3 when 2 then 4 when 13 then 5 when 4 then 6 when 5 then 7 when 31 then 31 else 1 end UiType, "&_
			"   CanSearch,candr,candc,cantj "&_
			" from sys_sdk_BillFieldInfo a "&_
			" where billtype=16001 and ListType='0' order by Showindex "
'select f.id,f.IsUsing ,f.FType,f.FName,f.MustFillin, ((case f.FType when 1 then 'danh_' when 2 then 'duoh_' when 3 then 'date_' when 4 then 'Numr_' when 5 then 'beiz_' when 6 then 'IsNot_' else 'meju_' end ) + cast(f.id as varchar(20)) ) as dbname,f.CanSearch,f.CanInport ,f.CanExport, f.CanStat  from ERP_CustomFields f where f.TName="& sort &" and f.del=1 order by f.FOrder asc "
		else
			sql = "select f.id,f.IsUsing ,f.FType,f.FName,f.MustFillin, "&_
			"   ((case f.FType when 1 then 'danh_' when 2 then 'duoh_' when 3 then 'date_' when 4 then 'Numr_' when 5 then 'beiz_' when 6 then 'IsNot_' else 'meju_' end ) + cast(f.id as varchar(20)) ) as dbname,"&_
			"sql = ""select f.id,f.IsUsing ,f.FType,f.FName,f.MustFillin, ""&_"
			f.CanSearch,f.CanInport ,f.CanExport, f.CanStat  &_
			" from ERP_CustomFields f "&_
			" where f.TName="& sort &" and f.del=1 order by f.FOrder asc "
		end if
		Set rs = cn.execute(sql)
		While rs.eof = False
			Set field = New customSetFieldClass
			if sort = 21 then
				With field
				.dbname = rs("dbname").value
				.Key    = rs("id").value
				.show   = (rs("isused").value=1)
				.name   = rs("title").value
				.required=(rs("MustFillin").value=1 And rs("isused").value=1)
				.extra  = rs("extra").value
				.sorttype   = CInt(rs("UiType").value)
				.search = (rs("CanSearch").value=1  And rs("isused").value=1 )
				.import = (rs("candr").value=1  And rs("isused").value=1 )
				.export = (rs("candc").value=1  And rs("isused").value=1 )
				.census = (rs("CanTj").value=1  And rs("isused").value=1   )
				End With
			else
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
			end if
			fields.add field
			rs.movenext
		wend
		rs.close
		Set GetExtraFields = fields
	end function
	Function GetZdyMxFields(sort)
		If sort&""="" Then sort = 1
		Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim rs ,sql, field
		sql = "select * from zdymx where sort1="& sort &" order by gate1 asc "
		Set rs = cn.execute(sql)
		While rs.eof = False
			Set field = New customSetFieldClass
			With field
			.dbname = rs("name").value
			.Key    = rs("id").value
			.show   = (rs("set_open").value = "1")
			.name   = rs("title").value
			.sorttype   = CInt(rs("sort").value)
			End With
			fields.add field
			rs.movenext
		wend
		rs.close
		Set GetZdyMxFields = fields
	end function
	Function GetPaySortFields(sort)
		If sort&""="" Then sort = 0
		Dim fields : Set fields = server.createobject(ZBRLibDLLNameSN & ".ASPCollection")
		Dim rs ,sql, field
		sql = "select f.id,(case f.name when 'tel' then 'company' when 'intro' then 'note' when 'mdd' then 'endaddr' when 'smdd' then 'staraddr' when 'lic' then 'lc' when 'jtgj' then 'bus' when 'hatol' then 'hotel' when 'ggdate' then 'ggtime' when 'ggdx' then 'ggcate' when 'ggsy' then 'ggintro' when 'lw' then 'gglw' else f.name end ) as name ,f.set_open,f.title, (case when sort=1 and f.name<>'num' then 1 else 0 end ) as required,(case when name ='money1' then 5 when name ='num' then 9 when name = 'lic' then 6 when name in ('startime','endtime','retime') then 11 when name in ('caigou','fahuo','iwork','contract','jkid','tel','person','richeng','shouhou','chance') then 4 when name ='ggdate' then 10 else 2 end ) as FType from zdymx f where f.sort1="& sort &" and name not in('jkid','scdd','zdww','gxww','scsb') order by f.gate1 asc,id asc "
		Set rs = cn.execute(sql)
		While rs.eof = False
			Set field = New customSetFieldClass
			With field
			.dbname = rs("name").value
			.Key    = rs("id").value
			.show   = (rs("set_open").value = "1")
			.name   = rs("title").value
			.required=(rs("required").value = "1" And rs("set_open").value = "1")
			.sorttype   = CInt(rs("FType").value)
			End With
			fields.add field
			rs.movenext
		wend
		rs.close
		Set GetPaySortFields = fields
	end function
	Public Sub setZdyCol(lvw ,sort ,pername)
		Dim h, i ,zdyfields ,field
		Set zdyfields = GetZdyFields(sort)
		If zdyfields.count=0 Then
			For i = 1 To 6
				Set h = lvw.headers.getItemByDbname(pername &"zdy" & i)
				h.width = 0
				h.display = "none"
			next
		else
			For i = 0 To zdyfields.count-1
				h.display = "none"
				Set field = zdyfields.item(i)
				Set h = lvw.headers.getItemByDbname(pername & field.dbname)
				If Not h Is Nothing then
					If field.show = True Then
						If  request("cmd")="cexcel" And field.export =False Then
							h.display = "none"
							h.width = 0
						else
							h.title = field.name
							h.width = 100
							h.cansum=False
							If field.extra > 0 Then h.width = 80
						end if
					else
						h.width = 0
						h.display = "none"
					end if
				end if
			next
		end if
	end sub
	Function Getuploadfile(ids)
		Dim f_rs,v
		If Len(ids&"")=0 Then Exit Function
		ids = sdk.FormatNumList(ids)
		Set f_rs=cn.execute("select * from reply_file_Access where ord in(" & ids & ")")
		Do While Not f_rs.eof
			If v="" Then
				v=uploadtoShow(f_rs("Access_url"),f_rs("oldname"))
			else
				v=v & uploadtoShow(f_rs("Access_url"),f_rs("oldname"))
			end if
			f_rs.movenext
		Loop
		f_rs.close
		Getuploadfile=v
	end function
	Function uploadtoShow(upfile,oldname)
		Dim allowExt,v
		allowExt="bmp,jpeg,png,gif,jpg"
		v=Split(upfile,".")(ubound(Split(upfile,".")))
		If InStr(1,allowExt,v,1)>0 Then
			uploadtoShow="&nbsp;<span><a href='../../WebSource.ashx?disshowname=1&pf=" & server.URLEncode(ZBRuntime.BSEnString( "0000" & upfile & "??", 1024 ))&"' class='preview' title='" & oldname & "' target='_blank'><img src='../images/smico/p_tool_img.gif' alt='" & oldname & "' border='0'/></a></span>"
		else
			uploadtoShow="&nbsp;<span><a href='../../WebSource.ashx?pf=" & server.URLEncode( ZBRuntime.BSEnString("0000"& upfile & "??" & oldname, 1024)) &"' >" & oldname & "</a></span>"
		end if
	end function
	Function bill_AjaxWindow_ShowGateDlg(byref ajaxpage)
		Dim bid ,sortStr , sort1 ,pord ,share
		bid = app.gettext("bid")
		sortStr =  app.gettext("sort")
		pord = app.gettext("pord")
		share = pord
		ajaxpage.title = "选择人员"
		ajaxpage.width = 600
		ajaxpage.height = 400
		Dim open_1_1 , w1_list , w2_list, w3_list , str_w1 , str_w2 , str_w3
		Dim rs ,rs1 , rs2 ,delsql
		open_1_1=0
		delsql = " and del=1 "
		Select Case sortStr
		Case "design" :
		sort1 = 5
		open_1_1 = 1
		w1_list = " select g.sorce from power p inner join gate g on g.ord=p.ord where p.sort1=5029 and p.sort2=17 and p.qx_open=1 "
		w2_list = " select g.sorce2 from power p inner join gate g on g.ord=p.ord where p.sort1=5029 and p.sort2=17 and p.qx_open=1 "
		w3_list = " select p.ord from power p where p.sort1=5029 and p.sort2=17 and p.qx_open=1 "
		Case "produce" :
		sort1 = 6
		open_1_1 = 1
		If sdk.power.existsModel(39000) And sdk.power.existsModel(39004) Then
			w1_list = " select sorce from hr_person where  piecework=1 and del=0 and nowstatus in (1,5,7) and contractEnd>=CONVERT(VARCHAR(10),GETDATE(),120) and contractStart<=CONVERT(VARCHAR(10),GETDATE(),120) "
			w2_list = " select sorce2 from hr_person where  piecework=1 and del=0 and nowstatus in (1,5,7) and contractEnd>=CONVERT(VARCHAR(10),GETDATE(),120) and contractStart<=CONVERT(VARCHAR(10),GETDATE(),120) "
			w3_list = " select userid from hr_person where  piecework=1 and del=0 and nowstatus in (1,5,7) and contractEnd>=CONVERT(VARCHAR(10),GETDATE(),120) and contractStart<=CONVERT(VARCHAR(10),GETDATE(),120) "
			delsql = ""
		else
			w1_list = " select sorce from gate where del=1 and jjgz = 1 "
			w2_list = " select sorce2 from gate where del=1 and jjgz = 1 "
			w3_list = " select ord from gate where del=1 and jjgz = 1 "
		end if
		Case Else
		sort1 = 4
		set rs1=cn.execute("select sort1,qx_open,w1,w2,w3 from power2  where cateid="&session("personzbintel2007")&" and sort1= "& sort1)
		if rs1.eof=false then
			open_1_1=rs1("qx_open")
			w1_list=rs1("w1")
			w2_list=rs1("w2")
			w3_list=rs1("w3")
		end if
		rs1.close
		End Select
		if open_1_1=1 then
			str_w1="and ord in ("&w1_list&")"
			str_w2="and ord in ("&w2_list&")"
			str_w3="and ord in ("&w3_list&") " & delsql
		elseif open_1_1=3 then
			str_w1=""
			str_w2=""
			str_w3= delsql
		else
			str_w1="and ord=0"
			str_w2="and ord=0"
			str_w3="and ord=0 " & delsql
		end if
		Response.write "" & vbcrlf & "     <div region=""center"" border=""false"" style=""background:#fff;border:0px solid #ccc; width:100%;height:100%"">" & vbcrlf & "    "
		Call InitUserGateObject
		Dim basesql
		basesql="select ord,orgsid from gate where 1=1 "&str_w3&""
		Response.write CBaseUserTreeHtmlRadioCE(basesql,"", "","","member2", "", "" , "", share,"if(node.value && node.value!='" &  share & "'){window.updateBoxSel('ShowGateDlg','" & bid & "',node.text, node.value)}")
		Response.write "" & vbcrlf & "     </div>" & vbcrlf & "  "
	end function
	Function bill_ShowGateList(sort1,user_list, id, showPerson)
		Dim rs1 , str_w1 , str_w2 , str_w3 , open_1_1
		Dim sql1, Correct_W1, Correct_W2, Correct_W3
		Dim rs8, sql, i, j6 , zhanshi2 , zk2, tmp
		Dim w1, w2, w3, zhanshi, zhanshi1, rs3, sql3, rs2, sql2
		Dim zhanshi3, zk3, zhanshi4
		Dim uid : uid = Info.User
		If Len(uid & "") = 0 Then uid = 0
		set rs1=server.CreateObject("adodb.recordset")
		sql1="select sort1,qx_open,w1,w2,w3 from power2  where cateid="& uid &" and sort1="&sort1&" "
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
		Correct_W3=replace(user_list," ","")
		if Correct_W3<>"" and Correct_W3<>"0" then
			tmp=split(getW1W2(Correct_W3),";")
			Correct_W1=tmp(0)
			Correct_W2=tmp(1)
		end if
		Dim basesql
		Call InitUserGateObject
		If showPerson Then
			basesql="select ord,orgsid from gate where del=1 "&str_w3&""
			Response.write CBaseUserTreeHtml(basesql,"", "W1","W2","W3", "", Correct_W1, Correct_W2, Correct_W3)
		else
			Response.write CBaseUserTreeHtml(basesql,"", "W1","W2","W3", "", Correct_W1, Correct_W2, Correct_W3)
		end if
		Response.write "" & vbcrlf & "             </div>" & vbcrlf & "          "
	end function
	Sub InitUserGateObject
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
	end sub
	Sub App___doBatHandle
		Dim cmd, data, result
		cmd = Replace(app.gettext("command"), "'","")
		data = Replace(app.gettext("checkvalues"), "'", "")
		If app.existsProc("App_doBatHandle") Then
			Set result = New BatResultClass
			Call App_doBatHandle(cmd, data, result)
			result.WriteScript
			Set result = nothing
		end if
	end sub
	Sub MessagePost(msgId)
		Select Case msgId
		Case ""
		Call Page_load
		Case "loadlistview"
		Call App_loadlistview
		Case "ReportJoinField"
		Call App_doReportJoinField
		Case "ReportSubmit"
		Call App_ReportSubmit
		Case Else
		App.TryExecuteProc "App_" & msgId
		End Select
	end sub
	Sub App_adsearch
		Dim ads, rpt, svs, gp, i, ii, fd, item ,adsfield
		If Not app.ismobile Then Exit sub
		Set ads = app.mobile.body.CreateModel("bill","init")
		Set rpt = New ReportClass
		Call onReportInit(rpt, 1)
		svs =  replace(request.servervariables("script_name"),"/","")
		ads.caption = "高级检索"
		ads.id = Replace(svs, ".asp", "_ads")
		ads.uitype = "bill.adsearch"
		If  rpt.asearch.fieldCount > 0 Then
			Set gp = server.createobject("ZSMLLibrary.GroupClass")
			ads.groups.add gp
			For i = 0 To rpt.asearch.fieldCount -1
'ads.groups.add gp
				Set adsfield = rpt.asearch.GetField(i)
				Set fd = server.createobject("ZSMLLibrary.FieldClass")
				fd.caption = adsfield.fname
				fd.type_ = adsfield.fType
				fd.id = adsfield.fKey
				If adsfield.fvisible&""<>"" Then
					fd.visible = adsfield.fvisible
					fd.canset = adsfield.fcanset
				end if
				fd.post = 1
				fd.edit = True
				Select Case fd.type_
				Case "date","dates","datetime" : fd.dbtype = "datetime"
				Case "select","ints" : fd.dbtype = "int"
				Case "numbers" :
				fd.dbtype = "number"
				fd.maxv = FormatNumber(99999999.999999,Info.FloatNumber,-1,0,0)
'fd.dbtype = "number"
				Case "moneys" : fd.dbtype = "money"
				Case Else
				fd.dbtype = "string"
				fd.maxl = 100
				End Select
				Dim sqlv : sqlv = adsfield.fSql
				If Len(sqlv) > 0 Then
					If isnumeric(sqlv) And fd.type_="sortonehy" Then
						Dim  rs
						Call fd.source.createType("options")
						Set rs = cn.execute("select sort1, ord from sortonehy where gate2=" & sqlv & " order by gate1 desc ")
						While rs.eof = False
							fd.source.addoption rs(0).value, rs(1).value
							rs.movenext
						wend
						rs.close
						fd.type_="check"
					ElseIf InStr(1,fd.type_ ,"source",1)>0 Then
						fd.action = "_url"
						fd.url = sqlv
						fd.type_="source"
					ElseIf InStr(1,sqlv, "options:",1) = 1 Then
						svs = Split(Replace(Chr(1) & sqlv, Chr(1) & "options:", ""), ";")
						Call fd.source.createType("options")
						For ii = 0 To ubound(svs)
							item = Split(svs(ii) & "==", "=")
							fd.source.addoption item(0),item(1)
						next
						If fd.type_="checks" Then fd.type_ = "check"
					ElseIf InStr(1,sqlv, "sql:",1) = 1 Then
						Call fd.source.createType("options")
						Set rs = cn.execute(Replace(Chr(1) & sqlv, Chr(1) & "sql:", ""))
						While rs.eof = False
							fd.source.addoption rs(0).value,rs(1).value
							rs.movenext
						wend
						rs.close
						If fd.type_="checks" Then fd.type_ = "check"
					end if
				end if
				If fd.canset = True Then
					If cn.execute("select 1 from  erp_sys_listviewConfig where uid="& Info.User & " and lvwid='"& ads.id &"' and attrn = 'adfieldname' and colname = '"& fd.id  &"'").eof= False Then
						fd.visible = True
					end if
				end if
				gp.fields.add fd
			next
			Set gp = nothing
		end if
		Set rpt = Nothing
	end sub
	Sub LoadMobileReport(ByVal rpt)
		Dim mrp : Set mrp = rpt.mobReport
		Dim i, svs , url
		url = request.servervariables("script_name")
		If Left(url,1) = "/" Then url = Right(url , Len(url)-1)
'url = request.servervariables("script_name")
		svs =  Replace(replace(url,"/",""), ".asp", "_list")
		mrp.caption = rpt.title
		mrp.id = svs
		If isarray(rpt.msorts)  Then
			mrp.sorts.post = 1
			mrp.sorts.id = "_rpt_sort"
			mrp.sorts.value = Split(rpt.msorts(0) & Chr(1), Chr(1))(1)
			For i = 0 To ubound(rpt.msorts)
				svs = Split(rpt.msorts(i) & Chr(1), Chr(1))
				mrp.sorts.addsortoption svs(0) & "(升)", svs(1)
				mrp.sorts.addsortoption svs(0) & "(降)", "-" & svs(1)
'mrp.sorts.addsortoption svs(0) & "(升)", svs(1)
			next
		end if
		If rpt.canflick = True Then
			if ZBRuntime.MC(63000) Then mrp.addTool "扫一扫", "flick", "flick", "", "get", ""
		end if
		If rpt.asearch.fieldCount > 0 Then
			For i = 0 To mrp.tools.count - 1
'If rpt.asearch.fieldCount > 0 Then
				If mrp.tools.item(i).action = "adsearch" Then
					Exit sub
				end if
			next
			mrp.addTool "高级检索", "adsearch","adsearch","", "", ""
		end if
		Dim arrurl : arrurl = Split("/"& LCase(url),"/mobilephone/")
		url = "mobilephone/" & arrurl(ubound(arrurl))
		If mrp.Group.count = 0 Then rpt.addMobGroup rpt.title,  1,"_url",url & app.iif(Len(request.servervariables("QUERY_STRING"))>0,"?","") &  request.servervariables("QUERY_STRING") ,"get"
	end sub
	Sub App_doReportJoinField
		Dim rpt
		Set rpt = New ReportClass
		Call App_ReportJoinField(rpt, app.gettext("name"), app.gettext("value"))
		Set rpt = nothing
	end sub
	Sub Page_load
		Dim rpt, tmpath, ash, i, ii, openScanf
		Dim vmlcss
		Set rpt = New ReportClass
		If app.ismobile Then Set rpt.mobReport = app.mobile.body.CreateModel("report","init")
		cn.CursorLocation  = 3
		If app.existsproc("onReportInit") Then
			Call onReportInit(rpt, 1)
			If app.ApiHelpModel Then
				rpt.showReportHelpApi
				Exit sub
			end if
			Call rpt.AutoAddUrlParam
		else
			Call RptCls_showHelp
			Exit sub
		end if
		openScanf = InStr(1,rpt.sql, "&scantext",1)
		If app.ismobile Then Call LoadMobileReport(rpt) : Set rpt = nothing:  Exit Sub
		tmpath = app.virPath & "skin/" & Info.skin
		Dim nums : nums = Split("10;20;30;50;100;200",";")
		Dim sboxHTML, trBtnHtml
		For i = 0 To ubound(nums)
			ii = nums(i)
			If CLng(rpt.pagesize) = CLng(ii) Then
				sboxHTML = sboxHTML & "<option value='" & ii & "' selected>每页显示" & ii & "条</option>"
			else
				sboxHTML = sboxHTML & "<option value='" & ii & "'>每页显示" & ii & "条</option>"
			end if
		next
		app.docmodel = "IE=EmulateIE7"
		If rpt.groupcount > 0 Then
			vmlcss = vbcrlf & "<meta name=""vs_targetSchema"" content=""http://schemas.microsoft.com/intellisense/ie5""/>" & vbcrlf & _
			"<style>" & vbcrlf & _
			"    v\:* { Behavior: url(#default#VML) }" & vbcrlf & _
			"    o\:* { behavior: url(#default#VML) } #comm_itembarright{padding-top:4px;}" & vbcrlf & _
			"</style>"
		end if
		trBtnHtml = trBtnHtml & rpt.beforeBtnsHTML &"&nbsp;"
		rpt.Settings.colset  = rpt.cancolset
		If rpt.Settings.count > 0 Then
			trBtnHtml = trBtnHtml &  "<button class='oldbutton' type='button' onclick='__rpt_showsettingPanel()'>设置</button>&nbsp;"
		end if
		If rpt.canExcel then
			trBtnHtml = trBtnHtml &  "<button class='oldbutton' type='button' onclick='(new Listview(""mlistvw"")).cexcel(""" & rpt.title & """)'>导出</button>&nbsp;"
		end if
		If rpt.canPrint Then
			app.Log.printlog = true
			trBtnHtml = trBtnHtml &  "<button class='oldbutton' type='button' onclick='window.print()'>打印</button>"
		end if
		trBtnHtml = trBtnHtml & rpt.buttonsHTML
		If Len(trBtnHtml) > 0 Then
			trBtnHtml = "<div id='btnsdiv' style='float:left;padding-top:7px'>" & trBtnHtml & "&nbsp;</div>"
'If Len(trBtnHtml) > 0 Then
		end if
		Dim tophtml, barHTML
		ReDim tophtml(4)
		Dim sortkey
		sortkey = request("ReportSortKey")
		If Len(sortkey) = 0 Then
			If rpt.billlistUiModel = true Then
				Dim lv : Set lv = New Listview
				lv.id = "mlistvw"
				sortkey = app.Attributes("rpt_s_" & lv.GetSboxHeaderConfigMd5)
				Set lv = nothing
			end if
		end if
		app.addScriptPath app.virpath & "inc/jquery.easyui.min.js"
		app.addCssPath app.virpath & "inc/themes/default/easyui.css"
		app.addScriptPath app.virpath & "inc/echarts.min.js"
		tophtml(0) = app.DefHeadHTML(app.virPath,"<link href='" & tmpath & "/css/ReportCls.css' rel='stylesheet' type='text/css'/>" & vbcrlf & "<script type='text/javascript'  language='javascript' defer=true src='" & tmpath & "/js/ReportCls.js'></script>" & vbcrlf & "<script type='text/javascript'  language='javascript' defer=true src='" & tmpath & "/js/VmlGraphics.js'></script></script><script language='javascript'>window.__ReportSortKey='"& sortkey &"';window.__canScanSearch=" & Abs(openScanf>0) & ";</script>" & VmlCss)
		app.Log.remark = rpt.title
		tophtml(1) = "<body class='defcomm resetHeadBg resetTitleBgLine44' onresize='OnReportBodyResize()' "
		If not rpt.cancopy Then
			tophtml(1) = tophtml(1) & " oncontextmenu='return false' onselectstart='return false' ondragstart='return false' onbeforecopy='return false' oncopy=document.selection.empty() "
		end if
		tophtml(1) = tophtml(1) & "><div id='comm_itembarbg'><div id='comm_itembarICO'></div><div id='comm_itembarText'><span>" &  rpt.title & "</span></div><div id='comm_itembarspc'></div>"
		If isarray(rpt.mSorts) Then
			tophtml(2) = "<div style='float:left;padding-top:20px'>&nbsp;<a class='tableTitleLinks sortRule' style='cursor:pointer;font-weight:bold' onclick='rpt_showsortdlg(this)' href='javascript:void(0)'>排序规则<img class='resetElementHidden' width='9' height='5' src='" & app.virPath & "images/i10.gif' border='0' style='border:0px;position:relative;left:5px;top:-1px'/><img class='resetElementShowNoAlign' width='9' height='5' src='" & app.virPath & "skin/default/images/MoZihometop/content/r_down2.png' border='0' style='border:0px;position:relative;left:5px;top:-1px;display:none;'/></a></div>"
'If isarray(rpt.mSorts) Then
			tophtml(2) = tophtml(2) & "<script language='javascript'>window.SortUiType=" & CLng(rpt.SortUiType) & ";window.reportSorts=[[""" & Replace(Join(rpt.mSorts, """],["""), Chr(1), """,""") & """]];</script>"
		end if
		Dim hhtml : hhtml = "<div id='comm_itembarright'>" & trBtnHtml
		If rpt.showtoppagesize = True Then
			hhtml = hhtml & "<select onchange='ReportSubmit()' id='PageSizeBox'>" & sboxHTML & "</select>"
		else
			hhtml = hhtml & "<select onchange='ReportSubmit()' style='display:none' id='PageSizeBox'>" & sboxHTML & "</select>"
		end if
		tophtml(3) = hhtml & "&nbsp;&nbsp;</div></div>"
		If rpt.groupcount > 0 Then
			tophtml(0) = Replace(tophtml(0), "<html", "<html xmlns:v=""urn:schemas-microsoft-com:vml"" xmlns:o=""urn:schemas-microsoft-com:office:office"" ")
'If rpt.groupcount > 0 Then
		end if
		Response.write Join(tophtml, "")
		Response.write rpt.headHTML
		Response.write "<style>"
		If rpt.fullWidthMode Then
			Response.write "#lvw_dbtable_mlistvw{width:100%;} #lvwbody{float:auto;}" & vbcrlf
		end if
		If rpt.oldReportUI = true Then
			Response.write "#lvw_mlistvw .lvw_smceldb {color:red;}" & vbcrlf
			Response.write "#lvw_mlistvw .lvw_smcellb {color:#2f496e;}" & vbcrlf
			If rpt.pagesize < 20 Or rpt.pagesize > 10000 then
				Response.write "#lvw_mlistvw .lvwheader {height:27px}"  & vbcrlf
				Response.write "#lvw_mlistvw .lvw_cell {height:27px}"  & vbcrlf
			end if
		end if
		Response.write "</style>"
		If rpt.groupcount > 0 Then
		end if
		If rpt.financeUIModel = True Then app.cRecord("select 1 from f_account")
		Response.write "" & vbcrlf & "     <div id='toparea' style=""overflow:hidden;"
		If Len(rpt.toolminWidth)> 0 And isnumeric(rpt.toolminWidth) Then
			Response.write "min-width:" & rpt.toolminWidth & "px;"
'If Len(rpt.toolminWidth)> 0 And isnumeric(rpt.toolminWidth) Then
		end if
		If rpt.nosearchBar = true Then
			Response.write "display:none;"
		end if
		Response.write """>" & vbcrlf & "        <style>" & vbcrlf & " #lvw_dbtable_mlistvw{border-top:0!important;width:100%!important}/*统计-销售栏目统计-客户统计分析-客户数量统计-回收客户分布-表头双边匡-添加此行*/" & vbcrlf & "       .panel .lvwframe2{width:100%;}" & vbcrlf & "  .lvw_cell.str a:hover{  /*库存-产品养护-库存列表-养护主题*/" & vbcrlf & "             text-decoration:underline!important;" & vbcrlf & "        }" & vbcrlf & "       </style>" & vbcrlf & "                <div style='float:right;padding:2px;padding-right:10px' id='asearchlinkBg'>" & vbcrlf & "                     <span id='asearchlink'></span>" & vbcrlf & "          </div>" & vbcrlf & "          <div class=""resetHeadBg"" style='padding-top:13px;overflow:visible;height:auto;' id='fieldsBox'>" & vbcrlf & "                    <!-- 显示字段 -->"
		'Response.write "display:none;"
		Response.write "<div id='commfieldsBox' onlyadSearchModel='" & Abs(rpt.onlyadSearchModel) & "' style='float:right'>"
		Response.write "<div  class='sfield'></div>"
		Call  rpt.showFields()
		Response.write "</div>"
		If rpt.aSearch.fieldCount > 0 Then
			rpt.aSearch.adSearchAutoHide = rpt.adSearchAutoHide
			rpt.aSearch.showButton
		end if
		Response.write "" & vbcrlf & "                     <table style=""width: 100%;""><tr><td></td></tr></table><!-- 该空table用于改变IE对区域toparea的解释 -->" & vbcrlf & "             </div>" & vbcrlf & "  </div>" & vbcrlf & "  <div jsonEditModel="""
		'rpt.aSearch.showButton
		Response.write abs(rpt.jsonEditModel)
		Response.write """ id='lvwbody'"
		Response.write app.iif(rpt.jsonEditModel, "style='width:100%'", app.iif(Len(rpt.bodywidth)>0," style='width:" & rpt.bodywidth & "px'",""))
		Response.write ">"
		If rpt.jsonEditModel Then Call App_LoadJsonListView(rpt)
		Response.write "</div>" & vbcrlf & "       "
		Response.write rpt.bottomhtml
		Response.write "" & vbcrlf & "     <div class='bottomdiv2' id='bottomdiv'"
		Response.write app.iif(rpt.groupcount>0,""," style='border-top:0px;'")
		Response.write "" & vbcrlf & "     <div class='bottomdiv2' id='bottomdiv'"
		Response.write ">" & vbcrlf & "    <input type='hidden' value='"
		Response.write app.base64.encode(TextZip(rpt.sql))
		Response.write "' id='dbtxt'>" & vbcrlf & "        <input type='hidden' value='"
		Response.write app.base64.encode(TextZip(rpt.getGroupsData()))
		Response.write "' id='groups'>" & vbcrlf & "       <input type='hidden' value='"
		Response.write Abs(rpt.nosearchBar)
		Response.write "' id='hidebar'>" & vbcrlf & "      <input type='hidden' value='"
		Response.write Abs(rpt.cancolset)
		Response.write "' id='cancolset'>" & vbcrlf & "    <input type='hidden' value='"
		Response.write rpt.PageButtonAlign
		Response.write "' id='pbtnalign'>" & vbcrlf & "    <input type='hidden' value='"
		Response.write app.docmodel
		Response.write "' id='IEModel'>" & vbcrlf & "      <input type='hidden' value='"
		Response.write Abs(rpt.BillListUIModel)
		Response.write "' id='BillListUIModel'>" & vbcrlf & "      <input type='hidden' value='"
		Response.write Abs(rpt.financeUIModel)
		Response.write "' id='financeUIModel'>" & vbcrlf & "       <input type='hidden' value='"
		Response.write rpt.excelextIntro
		Response.write "' id='excelextIntro'>" & vbcrlf & "        <input type='hidden' value='"
		Response.write rpt.ckboxdbname
		Response.write "' id='ckboxdbname'>" & vbcrlf & "  <input type='hidden' value='"
		Response.write rpt.batbuttons
		Response.write "' id='batbuttons'>" & vbcrlf & "   <input type='hidden' value='"
		Response.write Abs(rpt.fixHeader)
		Response.write "' id='fixheader'>" & vbcrlf & "    <input type='hidden' value='"
		Response.write Abs(rpt.asearch.openkzzdy)
		Response.write "' id='openkzzdy'>" & vbcrlf & "    <input type='hidden' value='"
		Response.write rpt.ServerLinkCols
		Response.write "' id='ServerLinkCols'>" & vbcrlf & "       </div>" & vbcrlf & "  <div style='position:relative;clear:both'>"
		Call App.TryExecuteProc("OnReportBottom")
		Response.write "</div>" & vbcrlf & "</body>" & vbcrlf & "</html>" & vbcrlf & ""
		Set rpt = nothing
	end sub
	Public Function TextZip(txt)
		TextZip = txt
	end function
	Function CRName(ByVal n)
		CRName = Replace(n,",","_")
	end function
	Function NullTo0(ByVal v)
		Dim vv, i
		If Len(v) > 0 Then
			vv = Split(v,",")
			For i = 0 To ubound(vv)
				If isnumeric(vv(i)) = False Then
					NullTo0 = "-1"
'If isnumeric(vv(i)) = False Then
					Exit function
				end if
			next
			NullTo0 = v
		else
			NullTo0 = "-1"
			NullTo0 = v
		end if
	end function
	Function RemoveSqlAttr(ByVal sql)
		Dim si, ei, sql1, sql2, slen
		Dim v, i,  nsql
		si = InStr(sql, "@")
		If si > 0 Then
			ei = -1
'If si > 0 Then
			slen = Len(sql)
			For i = si To slen
				v = Mid(sql, i, 1)
				If v = " " Or v = "," Or v = ")" Or v = "=" Or v = "+" Or v = "+" Or v = "*" Or v = "/" Or v = "%" Or v = vbCr Or v = vbLf Or v = vbTab Then
'v = Mid(sql, i, 1)
					ei = i
					Exit For
				end if
				If v = "'" Then
					RemoveSqlAttr = Left(sql,i) & RemoveSqlAttr(Right(sql, Len(sql)-i))
'If v = "'" Then
					Exit function
				end if
			next
			If i = slen + 1 Then
				Exit function
				ei = slen
				sql1 = Left(sql, si - 1)
'ei = slen
				nsql = sql1 & "''"
			else
				If ei > 0 Then
					sql1 = Left(sql, si - 1)
'If ei > 0 Then
					sql2 = Right(sql, Len(sql) - ei + 1)
'If ei > 0 Then
					nsql = RemoveSqlAttr(sql1 & "NULL" & sql2)
				else
					nsql = sql
				end if
			end if
		else
			nsql = sql
		end if
		nsql = Replace(Replace(nsql,"dbo.charLen(NULL)","0"), "like '%' + NULL + '%'", "like '%%'", 1, -1, 1)
		'nsql = sql
		If App.ExistsProc("ReportSqlHandle") Then
			nsql = ReportSqlHandle(nsql)
		end if
		RemoveSqlAttr = nsql
	end function
	Function SqlItemReplace(ByVal sql, ByVal nm , byVal value)
		Dim kv : kv = Chr(1) & Chr(3)
		sql = sql & " "
		sql = Replace(sql,"@" & nm & " ", kv & " ")
		sql = Replace(sql,"@" & nm & ")", kv & ")")
		sql = Replace(sql,"@" & nm & "=", kv & "=")
		sql = Replace(sql,"@" & nm & "+", kv & "+")
'sql = Replace(sql,"@" & nm & "=", kv & "=")
		sql = Replace(sql,"@" & nm & "-", kv & "-")
'sql = Replace(sql,"@" & nm & "=", kv & "=")
		sql = Replace(sql,"@" & nm & "*", kv & "*")
		sql = Replace(sql,"@" & nm & "/", kv & "/")
		sql = Replace(sql,"@" & nm & ",", kv & ",")
		sql = Replace(sql,"@" & nm & vbcr,kv & vbcr)
		sql = Replace(sql,"@" & nm & vblf,kv & vblf)
		sql = Replace(sql, " in (" & kv & ")", " in (" & NullTo0(Replace(value,"'","")) & ")")
		sql = Replace(sql, kv , "'" & Replace(value,"'","''") & "'")
		SqlItemReplace = sql
	end function
	Function getCurrSql(ByRef sql, ByRef groups, ByRef gobjs)
		sql = app.base64.decode(app.gettext("dbtxt"))
		Call getCurrReplaceFiledsSql(sql, groups, gobjs)
		getCurrSql = sql
	end function
	Function getCurrReplaceFiledsSql(ByRef sql, ByRef groups, ByRef gobjs)
		Dim AttrsData
		Dim h,  n, v, id , i, ts, ds, ii
		Dim asearch, gs, gsc, gscd, obj
		gs = app.base64.decode(app.gettext("groups"))
		If Len(gs) > 0 Then
			groups = Split(gs, "#^%!!")
			gsc = ubound(groups)
			ReDim gobjs(gsc)
			For i = 0 To gsc
				gscd = Split(groups(i), "^!^%")
				Set obj = new ReportGroupItem
				obj.title = gscd(0)
				obj.sql = gscd(1)
				obj.gtype = gscd(2)
				obj.dmode = gscd(3)
				obj.vname = gscd(4)
				Set gobjs(i) = obj
			next
		else
			gsc = -1
			'Set gobjs(i) = obj
		end if
		Set asearch  = New  AdvanceSearchClass
		For Each n In request.form
			id = Replace(n, "rpt_f_", "")
			If InStr(n,"rpt_f_") = 1 Then
				v = request.form(n)
				ts = False
				If InStr(v, Chr(1)) > 0 Then
					ts = true
					v = Split(v, Chr(1))
					For i = 0 To ubound(v)
						if v(i)<>"" then
							sql = SqlItemReplace(sql,CRName(id) & "_" & i , v(i))
							For ii = 0 To gsc
								gobjs(ii).sql = SqlItemReplace(gobjs(ii).sql, CRName(id) & "_" & i, v(i))
							next
						end if
					next
				end if
				If ts = False Then
					If InStr(v,"@sysgt=") = 1 Then
						ts = True
						ds = Split(v & "|||" , "|")
						v = Replace(ds(0), "@sysgt=gates","",1,-1,1)
'ds = Split(v & "|||" , "|")
						v = Replace(v, "@sysgt=gategroup","",1,-1,1)
'ds = Split(v & "|||" , "|")
						v = Replace(v, "@sysgt=gateoption","",1,-1,1)
'ds = Split(v & "|||" , "|")
						If Len(v) = 0 Then  v = 1
						If Len(ds(1))=0 and Len(ds(2)) = 0 and Len(ds(3)) = 0 Then
							v = ""
						else
							If app.ismobile Then
								v = asearch.getW_3("||" & ds(3), v)
							else
								v = asearch.getW_3(ds(1) & "|" & ds(2) & "|" & ds(3), v)
							end if
						end if
						sql = SqlItemReplace(sql, CRName(id), v)
						For ii = 0 To gsc
							gobjs(ii).sql =  SqlItemReplace(gobjs(ii).sql, CRName(id),v)
						next
					end if
				end if
				If ts = False Then
					If InStr(v, "@area=") = 1 Then
						ts = True
						v = Replace(v, "@area=","",1,-1,1)
'ts = True
						v = cn.execute("select dbo.GetMenuArea('" & v & "', 'menuarea') as r")(0).value
						sql = SqlItemReplace(sql, CRName(id), v)
						For ii = 0 To gsc
							gobjs(ii).sql =  SqlItemReplace(gobjs(ii).sql, CRName(id),v)
						next
					ElseIf InStr(v, "@cpfl=") = 1 Then
						ts = True
						v = Replace(v, "@cpfl=","",1,-1,1)
'ts = True
						v = cn.execute("select dbo.GetMenuArea('" & v & "', 'menu') as r")(0).value
						sql = SqlItemReplace(sql, CRName(id), v)
						For ii = 0 To gsc
							gobjs(ii).sql =  SqlItemReplace(gobjs(ii).sql, CRName(id),v)
						next
					ElseIf InStr(v, "@ckcls=") = 1 Then
						ts = True
						v = Replace(v, "@ckcls=","",1,-1,1)
'ts = True
						ds = Split(v& "||" ,"|")
						If Len(ds(0)) = 0 Then
							v = ds(1)
						else
							v = cn.execute("select dbo.GetMenuSorkCk('" & ds(0) & "', '"& ds(1) &"') as r")(0).value
						end if
						sql = SqlItemReplace(sql, CRName(id), v)
						For ii = 0 To gsc
							gobjs(ii).sql =  SqlItemReplace(gobjs(ii).sql, CRName(id),v)
						next
					ElseIf InStr(v, "@cateid=") = 1 or instr(v,"@w3=")=1 Then
						ts = True
						v = Replace(v, "@cateid=","",1,-1,1)
						ts = True
						v = Replace(v, "@w3=","",1,-1,1)
						ts = True
						ds = Split(v& "|||" ,"|")
						If Len(ds(0))=0 and Len(ds(1)) = 0 and Len(ds(2)) = 0 Then
							v = ""
						else
							If app.ismobile Then
								v = asearch.getW_3("||" & ds(2), v)
							else
								v = asearch.getW_3(ds(0) & "|" & ds(1) & "|" & ds(2), v)
							end if
						end if
						sql = SqlItemReplace(sql, CRName(id), v)
						For ii = 0 To gsc
							gobjs(ii).sql =  SqlItemReplace(gobjs(ii).sql, CRName(id),v)
						next
					ElseIf InStr(v, "@"& CRName(id) &"=") = 1 Then
						ts = True
						v = Replace(v, "@"& CRName(id) &"=","",1,-1,1)
						ts = True
						v = Split(v ,"|")
						For ii = 0 To ubound(v)
							gobjs(ii).sql =  SqlItemReplace(gobjs(ii).sql, CRName(id)&"_"& ii ,v(ii) )
						next
					end if
				end if
				If ts = False Then
					sql = SqlItemReplace(sql,CRName(id), v)
					For ii = 0 To gsc
						gobjs(ii).sql =  SqlItemReplace(gobjs(ii).sql, CRName(id),v)
					next
				end if
			end if
		next
		Set asearch = Nothing
		getCurrReplaceFiledsSql = sql
	end function
	Sub App_LoadJsonListView(ByRef rpt)
		Dim lvw
		Set lvw = New Listview
		lvw.border = 0
		lvw.id = "mlistvw"
		If Len(rpt.sql) > 0 Then lvw.sql = rpt.sql
		lvw.jsonEditModel = True
		lvw.pagesize = 15
		lvw.colresize = True
		If app.ExistsProc("app_oncreate") Then
			Call app_oncreate(lvw)
		end if
		Response.write lvw.HTML
	end sub
	Sub App_Refresh
		Dim sql, rpt, lvw, i ,ReportSort
		Dim src , asearch , ds , v , ii
		Set rpt = New ReportClass
		Call onReportInit(rpt, 1)
		Set lvw = New Listview
		If app.ExistsProc("app_onlistInit") Then
			Call app_onlistInit(lvw)
		end if
		ReportSort = app.mobile("_rpt_sort")
		If ReportSort&"" = "" Then ReportSort = ""
		sql = rpt.sql
		sql = Replace(sql, "&ReportSort", "'" & Replace(ReportSort,"'","''") & "'" )
		sql = Replace(sql, "&SearchMode", "0")
		lvw.pagesize = CLng("0" & app.mobile("pagesize"))
		lvw.pageindex = CLng("0" & app.mobile("pageindex"))
		If lvw.pagesize = 0 Then lvw.pagesize = 20
		If lvw.pageindex = 0 Then lvw.pageindex =1
		sql = Replace(sql, "&pagesize", lvw.pagesize)
		sql = Replace(sql, "&pageindex", lvw.pageindex)
		Set asearch  = New  AdvanceSearchClass
		If Not app.mobile.post.datas Is Nothing Then
			Dim item
			For i = 1 To app.mobile.post.datas.count
				v = ""
				Set item = app.mobile.Post.datas(i)
				If InStr(item.id, "cateid") >= 1 And InStr(item.val, "|")>0 Then
					ds = Split(item.Val& "|||" ,"|")
					If Len(ds(0))=0 and Len(ds(1)) = 0 and Len(ds(2)) = 0 Then
						v = ""
					else
						If app.ismobile Then
							v = asearch.getW_3("||" & ds(2), 1)
						else
							v = asearch.getW_3(ds(0) & "|" & ds(1) & "|" & ds(2), 1)
						end if
					end if
					sql = Replace(sql, "@" & item.id, "'" & Replace(v & "","'","''") & "'",1,-1,1)
					v = asearch.getW_3(ds(0) & "|" & ds(1) & "|" & ds(2), 1)
				ElseIf InStr(item.id, "telsort") = 1 Then
					ds = Split(item.Val& "||" ,"|")
					For ii = 0 To ubound(ds)
						sql = Replace(sql, "@" & item.id &"_"& ii, "'" & Replace(ds(ii) & "","'","''") & "'",1,-1,1)
'For ii = 0 To ubound(ds)
					next
				ElseIf InStr(item.id, "area") = 1 Then
					If Len(item.Val)>0 Then
						v = cn.execute("select dbo.GetMenuArea('" & item.Val & "', 'menuarea') as r")(0).value
					else
						v = ""
					end if
					sql = Replace(sql, "@" & item.id, "'" & Replace(v & "","'","''") & "'",1,-1,1)
					v = ""
				else
					sql = Replace(sql, "@" & item.id, "'" & Replace(item.Val & "","'","''") & "'",1,-1,1)
					v = ""
				end if
			next
		end if
		Set asearch = Nothing
		If Len(lvw.sql) = 0 Then
			lvw.sql = RemoveSqlAttr(sql)
		end if
		Dim rs : Set rs = lvw.record
		Dim reportModel : reportModel = app.getText("reportmodel")
		Select Case reportmodel
		Case "tree" : Call App_reportTree(lvw , rs)
		Case "option" : Call App_reportOption(lvw , rs)
		Case Else
		Call App_reportTable(lvw , rs)
		End Select
		Set lvw = nothing
	end sub
	Sub App_reportTable(lvw , rs)
		Dim  i , pc
		If app.ExistsProc("app_oncreate") Then
			Call app_oncreate(lvw)
		elseIf app.ExistsProc("app_onCreateList") Then
			Dim rptdata
			Set rptdata = New ReportDataClass
			Call app_onCreateList(lvw, rptdata)
			Set rptdata = nothing
		end if
		With app.mobile.body.createModel("source", "table" ,lvw.createsource())
		.uitype = app.gettext("checktype")
		.Text = lvw.id
		End With
	end sub
	Sub App_reportTree(lvw , rs)
		If app.ExistsProc("app_onMobileTree") Then
			Dim src
			Set src = app.mobile.body.createModel("source", "trees")
			src.createType("trees")
			Call app_onMobileTree(src , rs)
			Set src = nothing
		end if
	end sub
	Sub App_reportOption(lvw , rs)
		Dim src
		Set src = app.mobile.body.createModel("source", "options")
		src.createType("options")
		While rs.eof = False
			src.addoption rs(0).value,rs(1).value
			rs.movenext
		Wend
		Set src = nothing
	end sub
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
	Sub GetKzzdySql(ByRef sql)
		Dim f, item, kzsql, itemc, rs, hskz, kzid
		Dim tname, fcount, optionf, wsql, frmv, tField
		Dim numsf, datesf, vs
		hskz = false
		For Each item in request.form
			If InStr(item, "A_dFx_") = 1 Then
				hskz = true
				itemc = Split(item & "_0_0","_")
				frmv = request.form(item)
				If Len(tname) = 0 Then
					kzid = itemc(2)
					tname = getKzzdyTable(kzid)
					tField = GetKzzdyKeyField(kzid)
					fcount = 0
					Set rs = cn.execute("select ftype, id from ERP_CustomFields where TName=" & kzid & " and del=1 and isusing=1 and cansearch=1")
					While rs.eof = False
						If rs("ftype").value = 6 Or rs("ftype").value = 7 Then
							optionf = optionf & "," & rs("id").value
						end if
						If rs("ftype").value = 4 Then numsf = numsf & "," &  rs("id").value
						If rs("ftype").value = 3 Then datesf = datesf & "," &  rs("id").value
						fcount = fcount + 1
'If rs("ftype").value = 3 Then datesf = datesf & "," &  rs("id").value
						rs.movenext
					wend
					optionf = optionf & ","
					numsf = numsf & ","
					datesf = datesf & ","
					rs.close
				end if
				If Len(Replace(frmv, Chr(1),""))>0 Then
					If Len(wsql) > 0 Then wsql =  wsql & vbcrlf & "and "
					If InStr(optionf, "," & itemc(3) & ",")>0 Then
						wsql = wsql & " (b.id<>" & itemc(3) & " or charindex(fvalue,'" & frmv & "')>0) "
					else
						If  InStr(numsf, "," & itemc(3) & ",")>0 Then
							vs = Split(frmv, Chr(1))
							If Len(vs(0)) = 0 Then vs(0) = "-9999999999"
'vs = Split(frmv, Chr(1))
							If Len(vs(1)) = 0 Then vs(1) = "9999999999"
							wsql = wsql & " (b.id<>" & itemc(3) & " or (isnumeric(fvalue)=1 and (cast(fvalue as float) between " & vs(0) & " and " & vs(1) & "))) "
						ElseIf InStr(datesf, "," & itemc(3) & ",")>0 Then
							vs = Split(frmv, Chr(1))
							If Len(vs(0)) = 0 Then vs(0) = "1920-1-1"
							vs = Split(frmv, Chr(1))
							If Len(vs(1)) = 0 Then vs(1) = "2920-1-1"
							vs = Split(frmv, Chr(1))
							wsql = wsql & " (b.id<>" & itemc(3) & " or (isdate(fvalue)=1 and (cast(fvalue as datetime) between '" & vs(0) & "' and '" & vs(1) & " 23:59:59'))) "
						else
							wsql = wsql & " (b.id<>" & itemc(3) & " or charindex('" & frmv & "',fvalue)>0) "
						end if
					end if
				end if
			end if
		next
		If Len(tname) > 0 Then
			kzsql = "select a."& tField &" as tmpord into #erp_kzzdy_tmp from " & tname & " a " & vbcrlf &_
			"inner join ERP_CustomFields b on b.TName=" & kzid & " and b.del=1 and b.isusing=1 and b.cansearch=1 " & vbcrlf &_
			"left join ERP_CustomValues c on a."& tField &"= c.OrderID and c.FieldsID = b.ID" & vbcrlf
			If Len(wsql)>0 Then
				kzsql = kzsql & " where " & wsql & vbcrlf
				kzsql = kzsql & "group by a."& tField &" having COUNT(1)=" & fcount
			else
				kzsql = "select -1 as tmpord into #erp_kzzdy_tmp"
				kzsql = kzsql & "group by a."& tField &" having COUNT(1)=" & fcount
			end if
			sql = "/*必须静态游标*/" & vbcrlf & "set nocount on;" & kzsql & ";" & sql & ";drop table #erp_kzzdy_tmp;set nocount off"
		else
			sql = "/*必须静态游标*/" & vbcrlf & "set nocount on;select -1 as tmpord into #erp_kzzdy_tmp;" & sql & ";drop table #erp_kzzdy_tmp;set nocount off"
		end if
	end sub
	Sub App_ReportSubmit
		Dim lvw, h
		Dim sql, groups, w
		Dim asearch, gs, gsc, gobjs, obj
		Dim i, ii, IsIE8, IEVer, BillListUIModel, financeUIModel, fixheader , excelextIntro , ServerLinkCols
		Call getCurrSql(sql, groups, gobjs)
		If app.getint("openkzzdy")=1 Then
			Call GetKzzdySql(sql)
		end if
		If isArray(groups) then
			gsc = ubound(groups)
		else
			gsc = -1
			'gsc = ubound(groups)
		end if
		IsIE8 = app.getint("IsIE8")
		For i = 8 To 20
			If InStr(Request.ServerVariables("Http_User_Agent"),"MSIE " & i & ".0")>0 Then
				IEVer = i
				Exit for
			end if
		next
		BillListUIModel = app.getint("BillListUIModel")
		financeUIModel = app.getint("financeUIModel")
		fixheader = app.getint("fixheader")
		excelextIntro = app.getText("excelextIntro")
		ServerLinkCols = app.getText("ServerLinkCols")
		If IEVer = 8 Then  IsIE8=1
		sql = Replace(sql, "&ReportSort", "'" & Replace(app.gettext("sortkey"),"'","''") & "'",1,-1,1)
'If IEVer = 8 Then  IsIE8=1
		sql = Replace(sql, "&ScanText", "'" & Replace(app.gettext("scantext"),"'","''") & "'",1,-1,1)
'If IEVer = 8 Then  IsIE8=1
		sql = Replace(sql, "&SearchMode", app.getint("asrcm") & "", 1, -1, 1)
'If IEVer = 8 Then  IsIE8=1
		Set lvw = New listview
		lvw.PageButtonAlign = Trim(LCase(app.getText("pbtnalign")))
		lvw.colresize = true
		If BillListUIModel = 1 Then
			lvw.oldPageSizeUI = True
			lvw.HeaderPageSizeUI = True
			lvw.PageButtonAlign = "right"
			lvw.checkboxwidth = 30
		end if
		If Len(excelextIntro)>0 Then lvw.excelextIntro = excelextIntro
		If financeUIModel = 1 Then
			lvw.HeaderPageSizeUI = False
			lvw.FinanDBModel = true
			lvw.RowSplitFields = "" '月|年"
		end if
		If app.ExistsProc("app_onlistInit") Then
			Call app_onlistInit(lvw)
		end if
		If fixheader = 1 Then
			lvw.fixedhead = True
			lvw.height = 300
		end if
		lvw.id = "mlistvw"
		lvw.pagesize = app.getInt("pagesize")
		If Len(lvw.sql) = 0 Then
			lvw.sql = RemoveSqlAttr(sql)
		end if
		lvw.checkbox = False
		lvw.addlink = ""
		lvw.canpagesize = False
		lvw.indexbox = False
		lvw.border = 0
		If app.getInt("cancolset") =  1 Then
			lvw.isshow_ymc = True
			lvw.ServerConfig = true
		end if
		If Len(app.gettext("ckboxdbname")) > 0 Then
			lvw.checkbox = True
			lvw.checkvalue = app.gettext("ckboxdbname")
		end if
		If Len(app.gettext("batbuttons")) > 0 Then
			Dim s : s = Replace(Replace(app.gettext("batbuttons"),",",";"),";","</button><button class='oldbutton3 batbtn' onclick='rpt_batbtnClick(this)'>")
			lvw.addlink = "html:<input type='checkbox' onclick='rpt__allck(this)' id='rptallck'><label for=rptallck>全选</label><button class='oldbutton3 batbtn' onclick='rpt_batbtnClick(this)'>" & s & "</button>"
		end if
		If app.ExistsProc("app_oncreate") Then
			Call app_oncreate(lvw)
		elseIf app.ExistsProc("app_onCreateList") Then
			Dim rptdata
			Set rptdata = New ReportDataClass
			Call app_onCreateList(lvw, rptdata)
			Set rptdata = nothing
		end if
		If Len(ServerLinkCols)>0 Then
			Dim skey : skey = Split(ServerLinkCols,"|")(1)
			Dim cols : cols = Split(Split(ServerLinkCols,"|")(0),",")
			For i = 0 To ubound(cols)
				lvw.headers(cols(i)).formattext = "code:app_cellLinkHTML("""& cols(i) &""",rs("""& skey &"""), @value)"
			next
		end if
		If  lvw.IsaccWidth = True Then
			Dim w2 : w2 = w
			For i = 1 To lvw.headers.count
				Set h = lvw.headers(i)
				If isnumeric(h.width) Then
					If h.display <> "none" then
						w = w + h.width + IsIE8*2
'If h.display <> "none" then
						w2 = w2 + h.width + 3
'If h.display <> "none" then
					end if
				else
					w = w + 100 + IsIE8*2
'If h.display <> "none" then
					w2 = w2 + 103
'If h.display <> "none" then
				end if
			next
			If IEVer < 9 Then
				lvw.css = "width:" & w2 & "px"
			else
				lvw.css = "width:" & w & "px"
			end if
			Response.write "<ajaxscript>document.getElementById('lvwbody').style.width = (app.IeVer <9 ? '" & w2 & "px': 'auto');</ajaxscript>"
		end if
		Response.write  lvw.html
		set lvw = Nothing
		cn.CursorLocation = 3
		If gsc >=0 Then
			Response.write "<div style='max-width:1440px'><div id='ImageGroupArea'>"
'If gsc >=0 Then
			For ii = 0 To gsc
				Set obj = gobjs(ii)
				Call ShowImageGroupItem(obj , ii)
			next
			Response.write "</div></div><center><div style='clear:both;height:20px;overflow:hidden'>&nbsp;</div>"
		end if
	end sub
	Sub ShowImageGroupItem(ByRef g, ByVal ii)
		Dim img : Set img = New VmlGraphics
		dim csql : csql = RemoveSqlAttr(g.sql)
		err.clear
		on error resume next
		Dim rs : Set rs = cn.execute(csql)
		If Err.number<> 0 Then
			Response.write "<textarea style='display:none' id='GroupErrSql" & ii & "'>"
			If InStr(Request.ServerVariables("LOCAL_ADDR"), "127.0.0.1")  > 0 then
				Response.write RemoveSqlAttr(g.sql)
			end if
			Response.write "</textarea>"
			Set rs = cn.execute("select '<a href=""javascript:showgrouperrSql(" & ii & ")""><b style=""color:red"">统计出错</b></a>' as n , 0 as v")
		end if
		On Error GoTo 0
		Dim sql : sql = "set nocount on;create table #nm(n nvarchar(500), v float);"
		Dim i
		If g.dMode = "col" Then
			For i = 0 To rs.fields.count - 1
'If g.dMode = "col" Then
				sql = sql & "insert into #nm(n, v) values ('" & Replace(rs.fields(i).name,"'","''") & "','" & rs.fields(i).value & "');"
			next
			rs.close
			sql = sql & "select n, v from #nm order by v desc;set nocount off;"
			on error resume next
			Set rs = cn.execute(sql)
			If Err.number <> 0 Then
			end if
		end if
		img.height = 310
		img.width = 520
		img.loadDataByRecord rs
		img.title = "按" & g.title & "统计"
		img.id = "RMG" & ii
		Response.write "<div class='gmitem resetTableBg' style='_display:inline'>"
		Call img.Draw("pie")
		Response.write "</div>"
		Set img = nothing
		rs.close
	end sub
	Function FormatNumHTML(v, t)
		v = Replace(v&"",",","")
		If t =  "money" Then
			If v = 0 Then
				FormatNumHTML = FormatNumber(v, Info.moneynumber, -1)
'If v = 0 Then
			else
				If v > 0 Then
					FormatNumHTML = "<span style='color:red'>↑" & FormatNumber(v, Info.moneynumber, -1) & "</span>"
'If v > 0 Then
				else
					FormatNumHTML = "<span style='color:#009900'>↓" & FormatNumber(Abs(v), Info.moneynumber, -1) & "</span>"
'If v > 0 Then
				end if
			end if
			Exit function
		end if
		If t =  "number" Then
			If v = 0 Then
				FormatNumHTML = FormatNumber(v, Info.floatnumber, -1)
'If v = 0 Then
			else
				If v > 0 Then
					FormatNumHTML = "<span style='color:red'>↑" & FormatNumber(v, Info.floatnumber, -1) & "</span>"
'If v > 0 Then
				else
					FormatNumHTML = "<span style='color:#009900'>↓" & FormatNumber(Abs(v), Info.floatnumber, -1) & "</span>"
'If v > 0 Then
				end if
			end if
			Exit function
		end if
	end function
	Function app_cellLinkHTML(dbname ,skey, v)
		app_cellLinkHTML = "<a href='javascript:void(0)' onclick='ReportCellClick("""  & dbname & ""","& skey &")'>"& v &"</a>"
	end function
	Function ProductLinkHTML(ProductId, ProductName)
		If Len(productpower) = 0 Then
			productpower = app.power.existsPower(21,14)
		end if
		If app.power.existsPower(21,1) Then
			If productpower = True Then
				ProductLinkHTML = "<a target=_blank href='" & app.virpath & "product/content.asp?ord=" & app.base64.pwurl(ProductId) & "'>" &  ProductName & "</a>"
			else
				ProductLinkHTML = ProductName
			end if
		else
			ProductLinkHTML=""
		end if
	end function
	Sub lvw_onUIConfig(md5key, mtype)
		If mtype = 1 Then
			app.Attributes("rpt_s_" & md5key) = app.gettext("sortkey")
		else
			app.Attributes("rpt_s_" & md5key) = ""
		end if
	end sub
	Sub RptCls_ShowHelp
		Response.write sdk.res.html("rpt_null_msg")
	end sub
	Sub bill_AjaxWindow_showReportSettings( ap )
		With ap
		.width = 700
		.height = 490
		.top = 100
		.title = "报表设置"
		.canmax = False
		.canmin = False
		.canCollapse = False
		.canresize = False
		.backgroundColor = "#E4F0FF"
		.modal=1
		End With
		Dim execdata : execdata =  app.base64.decode(app.getText("stateview"))
		Dim rpt : Set rpt = New ReportClass
		If app.existsproc("onReportInit") Then
			Call onReportInit(rpt, 3)
		end if
		Dim l: Set l = New ListView
		cn.execute "set rowcount 100"
		execute execdata
		cn.execute "set rowcount 0"
		Response.write "<form style='display:inline' id='rpt_config_frm'><div id='rsetting' class='easyui-tabs' style='height:435px;overflow-y:hidden'>"
'cn.execute "set rowcount 0"
		Dim i, items
		For i = 0 To rpt.Settings.count - 1
'Dim i, items
			items = rpt.Settings.item(i)
			Response.write "<div class='rpt_cfg_panel' title=""" & items(0) & """ id='rpt_cs_p_" & i & "' style=""padding:5px;display:none;overflow-x:hidden;padding-bottom:0px""><input id='r_pc_" & items(1) & "' type='hidden' value=1>"
'items = rpt.Settings.item(i)
			Select Case items(1)
			Case "@@colset":  l.showConfigPage
			Case "@@formulset": l.showFormulConfigPage
			Case Else
			execute "App_" & items(1)
			End Select
			Response.write "</div> "
		next
		Response.write "</div>"
		Response.write "<div style='height:3px;overflow:hidden;background-color:white'></div>"
		Response.write "</div>"
		Response.write "<div style='margin:0px -5px 0px -5px;border-top:0px solid #95b8e7;text-align:center;padding-top:4px'>"
		Response.write "</div>"
		Response.write "<button class='oldbutton HighLight' onclick='__Report_cfg_Save(0);return false;'>保存</button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button class='oldbutton' onclick='__Report_cfg_Save(1);return false;'>还原</button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button class='oldbutton' onclick='app.easyui.closeWindow(""showReportSettings"");return false;"
		Response.write "</div></form>"
		Response.write "<ajaxscript>setTimeout(function(){try{$('#rsetting').tabs({border:false,onSelect:function(title){try{var index = $('#rsetting').tabs('getTabIndex',$('#rsetting').tabs('getSelected'));$('#rpt_cs_p_'+index).css('display','block').tabs('resize');}catch(e){}}});}catch(e){}},10);</ajaxscript>"
		Response.write "</div></form>"
		Set rpt = Nothing
		Set l = Nothing
	end sub
	Sub App_sys_ReportConfig
		Dim rs, l, htype
		htype = app.getInt("htype")
		Set l = New listview
		l.id = "mlistvw"
		l.iscallback = True
		l.HeaderConfigKey = app.GetText("HCKey")
		If htype = 0 Then
			If app.getInt("r_pc_@@colset") = 1 Then Call l.SaveConfigPage
			If app.getInt("r_pc_@@formulset") = 1 Then Call l.SaveformulConfigPage
		else
			If app.getInt("r_pc_@@colset") = 1 Then Call l.ClearConfigPage
			If app.getInt("r_pc_@@formulset") = 1 Then Call l.ClearformulConfigPage
		end if
		If app.existsProc("App_PreReportExtraConfig") Then Call App_PreReportExtraConfig(l)
		Call execute(app.base64.decode(request.form("backdata")))
		If app.existsProc("App_AftReportExtraConfig") Then Call App_AftReportExtraConfig(l)
		Response.write l.HTML
		Set l = nothing
	end sub
	Sub App_ReportServerLink
		Dim rptdata , colname ,keyord
		Set rptdata = New ReportDataClass
		colname = rptdata.getText("__coldbname")
		keyord = rptdata.getText("__keyord")
		If app.existsProc("App_ReportServerLinkData") Then
			Call App_ReportServerLinkData(colname ,keyord , rptdata)
		end if
	end sub
	
	Function fromOrderLinkHTML(fromType,orderId,title)
		If fromType=1 Then
			If app.power.existsPower(5,1) Then
				If app.power.existsPower(5,14) Then
					fromOrderLinkHTML = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "../SYSN/view/sales/contract/ContractDetails.ashx?view=details&ord=" & app.base64.pwurl(orderId) & "','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				else
					fromOrderLinkHTML = title
				end if
			else
				fromOrderLinkHTML = ""
			end if
		Else
			If app.power.existsPower(52,1) Then
				If app.power.existsPower(52,14) Then
					fromOrderLinkHTML = "<a href='javascript:void(0)' onClick=""javascript:window.open('" & app.virpath & "manufacture/inc/readbill.asp?orderID=1&Id=" & orderId & "','newwin','width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');return false;"">" & title & "</a>"
				else
					fromOrderLinkHTML = title
				end if
			else
				fromOrderLinkHTML = ""
			end if
		end if
	end function
	Sub onReportInit(rpt, state)
		Dim dat, rs, zdy
		Call app.addDefaultScript()
		dat = Split(year(now) & "-" & month(now) & "-1," & date, ",")
		'Call app.addDefaultScript()
		rpt.title = "计件工资明细表"
		rpt.addfield "&nbsp;汇报时间：","dates","date1","","", dat
		Dim strWP
		strWP = "产量登记" & Chr(1) & "0"
		Set rs= cn.execute("select id,WPName from M_workingprocedures where del = 0")
		While rs.eof = False
			strWP = strWP & Chr(2) & rs(1) & Chr(1) & rs(0)
			rs.movenext
		wend
		rpt.addfield "","select","wpid",strWP,"",""
		rpt.addfield "","select","state", "已发放" & Chr(1) & "PAID" &_
		"已核算" & Chr(1) & "CHECKED" & Chr(2) & "未发放" & Chr(1) & "NOT_PAID","",""
		rpt.addfield "","select","searchType", "产品名称" & Chr(1) & "PRODUCT" & Chr(2) & "生产人员" & Chr(1) & "HUMAN" & Chr(2) & "生产计划" & Chr(1) & "PLAN" & Chr(2) & "生产订单" & Chr(1) & "ORDER","",""
		rpt.SetNullMsg 1,"-选择工序-"
		rpt.SetNullMsg 2,"-选择状态-"
		rpt.SetNullMsg 3,"-检索条件-"
		rpt.addfield "","text","searckKey", "", "", ""
		rpt.sql = "exec erp_list_PieceWageReportForms @wpid ,@state, @date1_0, @date1_1, @searchType,@searckKey,"&Info.User&", 55, 14"
		rpt.canexcel =  true
		rpt.canprint =  app.power.existsPower(55,7)
	end sub
	Sub app_oncreate(lvw)
		Dim h, i
		lvw.IsaccWidth = True
		lvw.PageButtonAlign = "right"
		Set h = lvw.headers(1)
		h.width = 100
		Set h = lvw.headers(2)
		h.display = "none"
		h.width = 0
		Set h = lvw.headers(3)
		h.width = 140
		h.setLink   "", "产品ID", "产品添加人ID", 21, -6
		h.width = 140
		h.dbtype = "str"
		Set h = lvw.headers(4)
		h.width = 0
		h.display = "none"
		Set h = lvw.headers(5)
		h.width = 100
		Set h = lvw.headers(6)
		h.width = 110
		Set h = lvw.headers(7)
		h.width = 60
		Set h = lvw.headers(8)
		h.width = 0
		h.display = "none"
		Set h = lvw.headers(9)
		h.width = 140
		h.setLink   "", "工序ID", "工序添加人ID", 59, 9
		h.dbtype = "str"
		Set h = lvw.headers(10)
		h.width = 0
		h.display = "none"
		Set h = lvw.headers(11)
		h.width = 80
		h.dbtype = "number"
		Set h = lvw.headers(12)
		h.width = 80
		h.dbtype = "money"
		Set h = lvw.headers(13)
		h.width = 80
		h.dbtype = "money"
		Set h = lvw.headers(14)
		h.width = 80
		h.dbtype = "money"
		Set h = lvw.headers(15)
		h.width = 80
		Set h = lvw.headers(16)
		h.width = 80
		Set h = lvw.headers(17)
		h.width = 0
		h.display = "none"
		Set h = lvw.headers(18)
		h.width = 150
		h.formattext = "code:fromOrderLinkHTML(@cells[17],@cells[19],""@value"")"
		h.dbtype = "str"
		Set h = lvw.headers(19)
		h.width = 0
		h.display = "none"
		Set h = lvw.headers(20)
		h.width = 0
		h.display = "none"
		Set h = lvw.headers(21)
		h.width = 140
		h.setLink   "", "生产计划ID", "生产计划添加人ID", 50, 3
		h.dbtype = "str"
		Set h = lvw.headers(22)
		h.width = 0
		h.display = "none"
		Set h = lvw.headers(23)
		h.width = 0
		h.display = "none"
		Set h = lvw.headers(24)
		h.width = 140
		h.setLink   "", "生产订单ID", "生产订单添加人ID", 51, 2
		h.dbtype = "str"
		Set h = lvw.headers(25)
		h.width = 0
		h.display = "none"
		Set h = lvw.headers(26)
		h.width = 0
		h.display = "none"
		Set h = lvw.headers(27)
		h.width = 140
		h.setLink   "", "进度汇报单ID", "进度汇报单添加人ID", 55, 11
		h.dbtype = "str"
		Set h = lvw.headers(28)
		h.width = 0
		h.display = "none"
	end sub
	Sub OnReportBottom
		Response.write "" & vbcrlf & "<div style='position:relative;top:-30px;'>" & vbcrlf & "   <table style='table-layout:auto;width:auto'>" & vbcrlf & "    <tr>" & vbcrlf & "            <td>&nbsp;</td>" & vbcrlf & "         <td width='20'>&nbsp;</td>" & vbcrlf & "              <td>" & vbcrlf & "                    <form action='' target='_blank' id='mfrm' method='post' style='display:inline'>" & vbcrlf & "                               <input type='hidden' name='handle' id='handle' value=1>" & vbcrlf & "                         <input type='hidden' name='selectid' id='selectid'>" & vbcrlf & "                     </form>" & vbcrlf & "         </td>" & vbcrlf & "   </tr>" & vbcrlf & "   </table>" & vbcrlf & "</div>" & vbcrlf & ""
	end sub
	
%>
