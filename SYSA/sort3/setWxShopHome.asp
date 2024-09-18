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
		' If ZBRuntime.loadOK = False Then
		' 	ZBRuntime.getLibrary "ZBIntel2013CheckBitString"
		' 	If ZBRuntime.loadOK = False then
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
					mrecordcount = rs.recordcount
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
						Set zdyMaps(zdycount ) = zdyobj
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
			.Open "POST", url, false ,"" ,""
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
						rsSub("pid") = menuId
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
				getUserIdByOpenId = CLng(rs(0))
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
	
	Sub page_load
		Call App_MenuSetting
	end sub
	Sub App_loadLocalMenuData
		Response.clear
		Dim sql,rs,json,count
		sql =         "SELECT id,0 AS pid,name,sort FROM  Shop_HomeGroups ORDER  BY sort DESC "
		Set rs = cn.execute(sql)
		json = "["
		While rs.eof = False
			json = json & "{"&_
			"""id"":""" & rs("id") & """," &_
			"""pid"":""" & rs("pid") & """," &_
			"""text"":""" & JsonStringFilter(rs("name")) & """," &_
			"""attributes"":{"&_
			"""sort"":""" & rs("sort") & """" &_
			"}" &_
			"}"
			rs.movenext
			If rs.eof = False Then json = json & ","
		wend
		rs.close
		json = json & "]"
		Response.write json
	end sub
	Sub App_mainPage
		Dim rs,sql,id,sType,proCategory,count,attrName,addBtn,editBtn,delBtn,stopBtn,attrStatus,sort,isUsing,disabled
		sType = Request("sType")
		count = 0
		proCategory = 0
		Call WriteHeadHtml
		Dim lvw : Set lvw =  New ListView
		sql =        "SELECT a.id,c.fpath AS 图片展示,a.link AS 图片地址,'' AS 操作  " &_
		"FROM Shop_HomeGroupItems a " &_
		"INNER JOIN Shop_HomeGroups b ON b.id = a.groupId " &_
		"LEFT JOIN sys_upload_res c ON c.id = a.source " &_
		"WHERE b.[type] = 'BANNER' " &_
		"ORDER BY a.sort DESC "
		lvw.sql = sql
		lvw.id = 1
		lvw.addlink = ""
		lvw.checkbox = False
		lvw.indexbox = True
		lvw.PageBar = False
		lvw.cansort = False
		count = lvw.recordcount
		lvw.pagesize = 4
		lvw.headers("id").display = "none"
		lvw.headers("图片展示").width = "253"
		lvw.headers("图片展示").FormatText = "code:showPic(""@value"")"
		lvw.headers("图片地址").width = "480"
		lvw.headers("操作").width = "100"
		lvw.headers("操作").formattext = "code:GetOptionCol(@cells[""id""])"
		lvw.addlink = "<div><input id='addBannerBtn' class='anybutton2' type='button' onclick='window.parent.openUploadDlg(0)' value='添加'></div>"
		Response.write lvw.html()
		Response.Flush()
		Response.write "" & vbcrlf & "<script>" & vbcrlf & "window.parent.dealBannerAddBtnState();" & vbcrlf & "parent.document.getElementById(self.name).height=document.body.scrollHeight;" & vbcrlf & "" & vbcrlf & "//window.__ImgBigToSmall(250,100);" & vbcrlf & "" & vbcrlf & "window.onlistviewRefresh=function(){" & vbcrlf & "  setTimeout(function(){" & vbcrlf & "          //维护banner添加按钮的状态" & vbcrlf & "              window.parent.dealBannerAddBtnState();" & vbcrlf & "          parent.document.getElementById(self.name).height=document.body.scrollHeight;" & vbcrlf & "    },100);" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & ""
	end sub
	Function showPic(fpath)
		Dim temp
		If fpath <> "" Then
			fpath = "../edit/upimages/shop/"&fpath
		end if
		temp = "<div><a href='"& fpath &"' target='_blank'><img src='"& fpath &"' style='width:216px; height:130px; margin:5px;'></div>"
		showPic = temp
	end function
	Function GetOptionCol(id)
		Dim str
		str = "<input clsss=""editAttrBtn"" type=""button"" value=""修改"" onclick=""window.parent.openUploadDlg("& id &");"" class=""anybutton2""/>"
		str = str &" <input clsss=""delAttrBtn"" type=""button"" value=""删除"" onclick=""window.parent.delBanner("& id &");"" class=""anybutton2""/>"
		GetOptionCol = str
	end function
	Sub App_goodsListPage
		Dim rs,sql,groupid,id,sType,count,attrName,addBtn,editBtn,delBtn,stopBtn,attrStatus,sort,isUsing,disabled,col
		groupid = Request("groupid")
		count = 0
		Call WriteHeadHtml
		Dim lvw : Set lvw =  New ListView
		sql =        "SELECT a.id AS itemID,a.sort AS itemSort,b.* FROM Shop_HomeGroupItems a " &_
		"INNER JOIN ( " &_
		"   SELECT a.id, e.fpath AS 缩略图, a.bh AS 商品编号, a.name AS 商品名称, b.sort1 AS 单位, '' AS 商品属性,  " &_
		"   a.price1 AS 市场价,  " &_
		"   ISNULL((SELECT SUM(num) num " &_
		"   FROM    " &_
		"   ( " &_
		"           SELECT SUM(num1) num " &_
		"           FROM   Shop_StorageAppendLog " &_
		"           WHERE  goodsId = a.id " &_
		"           UNION ALL " &_
		"           SELECT ISNULL(SUM(num1), 0) *- 1 num " &_
		"           UNION ALL " &_
		"           FROM   contractlist aaa " &_
		"           INNER JOIN contract bbb ON aaa.contract = bbb.ord " &_
		"           WHERE  1 = 1 " &_
		"           AND aaa.goodsId = a.id " &_
		"           AND ( bbb.payStatus = 1   " &_
		"                     OR bbb.payStatus = 2 " &_
		"                    OR (bbb.payKind = 2 AND bbb.del = 1 ) " &_
		"                    OR (bbb.payKind = 1 and bbb.del = 1 AND DATEDIFF(mi,bbb.date7,GETDATE()) <= 3) " &_
		"                  ) " &_
		"  ) aa),0) AS 可售数量, c.sort1 AS 所属分类,'' AS 操作,a.creator " &_
		"  FROM Shop_Goods a " &_
		"  LEFT JOIN sortonehy b ON b.ord = a.unit " &_
		"  LEFT JOIN sortonehy c ON c.ord = a.sortonehy " &_
		"  LEFT JOIN gate d ON d.ord = a.creator " &_
		"  LEFT JOIN sys_upload_res e ON e.id1 = a.id AND e.id2 = 1 " &_
		"  WHERE a.del = 1 " &_
		") b ON a.source = b.id AND a.groupid = "& groupid &" " &_
		"ORDER BY itemSort DESC "
		lvw.sql = sql
		lvw.id = 1
		lvw.addlink = ""
		lvw.checkbox = False
		lvw.indexbox = True
		lvw.oldPageSizeUI = True
		lvw.PageButtonAlign = "right"
		lvw.cansort = False
		lvw.pagesize = 10
		lvw.headers("@@序号").width = 50
		lvw.headers("缩略图").width = 100
		lvw.headers("商品编号").width = 100
		lvw.headers("商品名称").width = 200
		lvw.headers("单位").width = 100
		lvw.headers("商品属性").width = 150
		lvw.headers("市场价").width = 100
		lvw.headers("可售数量").width = 100
		lvw.headers("所属分类").width = 150
		lvw.headers("操作").width = 150
		lvw.headers("id").display = "none"
		lvw.headers("creator").display = "none"
		lvw.headers("itemID").display = "none"
		lvw.headers("itemSort").display = "none"
		lvw.headers("缩略图").FormatText = "code:showGoodsPic(@cells[""id""])"
		lvw.headers("商品属性").FormatText = "code:GetGoodsAttr(@cells[""id""])"
		Set col = lvw.headers("商品名称")
		col.dbtype = "str"
		col.setlink "商品名称","id", "creator" , 109, -15
		col.dbtype = "str"
		Set col = lvw.headers("市场价")
		col.dbtype = "money"
		col.formattext = "￥@value"
		col.canSum = True
		Set col = lvw.headers("可售数量")
		col.dbtype = "number"
		col.canSum = True
		lvw.headers("操作").formattext = "code:GetGoodsOptionCol(@cells[""itemID""])"
		lvw.addlink = "<div><button id=""addGoodsBtn"" class=""anybutton"" onclick='javascript:window.open(""../MicroMsg/goods/list.asp?Referrer=setWxShopHome&groupid="& groupid &""",""setWxShopHome"",""width="" + 1000 + "",height="" + 550 + "",fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=100"");return false;'>添加新行</button></div>"
		Response.write lvw.html()
		Response.Flush()
		Response.write "" & vbcrlf & "<script>" & vbcrlf & "goods_dealAddBtn(0);" & vbcrlf & "" & vbcrlf & "parent.document.getElementById(self.name).height=document.body.scrollHeight;" & vbcrlf & "" & vbcrlf & "function __tvwcolresize(){" & vbcrlf & "   " & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "// 刷新方法" & vbcrlf & "function goods_refresh(){" & vbcrlf & "    lvw_refresh(1);" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "// 处理添加新行按钮" & vbcrlf & "function goods_dealAddBtn(num){" & vbcrlf & "     return false;" & vbcrlf & "   num = $(""#lvw_tby_1 tr[l_r=1]"").size() || num;" & vbcrlf & "    if(num >= 12){" & vbcrlf & "          $(""#addGoodsBtn"").attr(""disabled"",""disabled"");" & vbcrlf & "        };" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "// 商品列表排序操作" & vbcrlf & "function upMove(id,obj){" & vbcrlf & " //上移" & vbcrlf & "  var $tr = $(obj).parents(""tr[l_r]"")," & vbcrlf & "              siblingID = $tr.prev(""tr[l_r=1]"").find("".upbtn"").attr(""itemid"") || 0;" & vbcrlf & " var curNum = $tr.find("".lvw_index"").text();" & vbcrlf & "       var prevNum = $tr.prev(""tr[l_r=1]"").find("".lvw_index"").text();" & vbcrlf & "      if ($tr.index() != 1) {" & vbcrlf & "         $.post(""?__msgid=sortGoods"",{id:id,siblingID:siblingID,sType:""up""},function(data){" & vbcrlf & "                  $tr.find("".lvw_index"").text(prevNum);" & vbcrlf & "                     $tr.prev(""tr[l_r=1]"").find("".lvw_index"").text(curNum);" & vbcrlf & "                      $tr.prev(""tr[l_r=1]"").before($tr);" & vbcrlf & "                });" & vbcrlf & "     }" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "// 商品列表排序操作" & vbcrlf & "function downMove(id,obj){" & vbcrlf & "    //下移" & vbcrlf & "  var trLength = $(""button.downbtn"").length;" & vbcrlf & "        var $tr = $(obj).parents(""tr[l_r]"")," & vbcrlf & "              siblingID = $tr.next(""tr[l_r=1]"").find("".upbtn"").attr(""itemid"") || 0;" & vbcrlf & " var curNum = $tr.find("".lvw_index"").text();" & vbcrlf & "      var nextNum = $tr.next(""tr[l_r=1]"").find("".lvw_index"").text();" & vbcrlf & "" & vbcrlf & "      if ($tr.index() != trLength) {                                  " & vbcrlf & "                $.post(""?__msgid=sortGoods"",{id:id,siblingID:siblingID,sType:""down""},function(data){" & vbcrlf & "                        $tr.find("".lvw_index"").text(nextNum);" & vbcrlf & "                 $tr.next(""tr[l_r=1]"").find("".lvw_index"").text(curNum);" & vbcrlf & "                      $tr.next().after($tr);" & vbcrlf & "          });" & vbcrlf & "     }" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "// 删除商品" & vbcrlf & "function delGoods(id){" & vbcrlf & "    if(!confirm(""确定要删除吗？删除后将不可恢复！"")){" &vbcrlf & "                return false;" & vbcrlf & "   };" & vbcrlf & "" & vbcrlf & "      $.post(""?__msgid=delGoods"",{id:id},function(data){" & vbcrlf & "                lvw_refresh(1);" & vbcrlf & "         goods_dealAddBtn(0);" & vbcrlf & "    });" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "window.onlistviewRefresh=function(){" & vbcrlf & " setTimeout(function(){" & vbcrlf & "          //维护banner添加按钮的状态" & vbcrlf & "              window.parent.dealBannerAddBtnState();" & vbcrlf & "          parent.document.getElementById(self.name).height=document.body.scrollHeight;" & vbcrlf & "    },100);" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "</script>" & vbcrlf & ""
	end sub
	Function showGoodsPic(gID)
		Dim rs,sql,temp
		sql = "SELECT TOP 1 fpath FROM sys_upload_res WHERE id1 = "& gID &" AND id2 = 1"
		Set rs = cn.Execute(sql)
		If Not rs.Eof Then
			temp = "<a href='../edit/upimages/shop/"& rs(0) &"' target='_blank'><img border='0' src=""../edit/upimages/shop/"& Replace(rs(0),".","_s.") &"""></a>"
		else
			temp = ""
		end if
		rs.close
		set rs = nothing
		showGoodsPic = temp
	end function
	Function GetGoodsAttr(gID)
		Dim rs,sql,temp
		sql = "SELECT attrVal FROM Shop_GoodsAttrValue a " &_
		"LEFT JOIN Shop_GoodsAttr b ON a.attrID = b.id " &_
		"WHERE goodsID = "& gID &" " &_
		"ORDER BY b.sort DESC "
		Set rs = cn.Execute(sql)
		If Not rs.Eof Then
			Do While Not rs.Eof
				temp = temp & rs("attrVal")
				rs.movenext
				If Not rs.Eof And temp <> "" Then temp = temp & "<span class='separator'>/</span>"
			Loop
		end if
		rs.close
		set rs = nothing
		GetGoodsAttr = temp
	end function
	Function GetGoodsOptionCol(id)
		Dim str
		str = str &"<button onclick=""upMove("& id &",this)"" itemid="""& id &""" title=行上移 class=""anybutton fs upbtn"">↑</button>"
		str = str &"<button onclick=""downMove("& id &",this)"" title=行下移 class=""anybutton fs downbtn"" style='margin-left:5px;margin-right:5px;'>↓</button>"
		str = str &"<button class=""anybutton"" onclick=""delGoods("& id &");"" />删除</button>"
		GetGoodsOptionCol = str
	end function
	Sub App_saveEdit
		Dim id,title,sort,rs,count
		id = Request("id")
		title = Request("title")
		sort = Request("sort")
		count = 0
		If id = "" Then id = 0
		If id = "0" Then
			cn.Execute("INSERT INTO Shop_HomeGroups ([type],name,sort) VALUES ('OTHER','"& title &"',"& sort &")")
		else
			cn.Execute("UPDATE Shop_HomeGroups SET name = '"& title &"', sort = "& sort &" WHERE id = "& id &" ")
		end if
		Set rs = cn.Execute("SELECT ISNULL(COUNT(*),0) FROM Shop_HomeGroups ")
		If Not rs.Eof Then
			count = rs(0)
		end if
		rs.close
		set rs = nothing
		Response.write count
	end sub
	Function GetFileNameRule(Ext)
		on error resume next
		Dim physicalPath,folderName,myFso,filename
		folderName = Year(Date) & Right("0" & Month(Date),2) & Right("0" & Day(Date),2)
		physicalPath = Server.MapPath("../edit/upimages/shop/"& folderName)
		Set myFso = Server.Createobject("scripting.filesystemobject")
		If Not myFso.FolderExists(physicalPath) Then myFso.CreateFolder(physicalPath)
		If Application("__saas__company") & "" <> "" Then
			folderName = folderName & "/SAS" & Application("__saas__company")
			If Not myFso.FolderExists(physicalPath) Then myFso.CreateFolder(physicalPath)
		end if
		filename = Replace(Replace(Replace(Replace(now, "/", ""),":","")," ",""),"-","")&"."& Ext
		If Not myFso.FolderExists(physicalPath) Then myFso.CreateFolder(physicalPath)
		GetFileNameRule = folderName & "/" &filename
	end function
	Sub App_saveBanner
		on error resume next
		Dim id,groupid,sort,rs,sql,count,link,FilePath,FileType,FileName,FileSize,FilesExt,fso
		count = 0
		Dim size
		size = Request.TotalBytes
		If size > 204800 Then
			Response.write "<script>alert('上传图片不能大于200kb,请重新选择图片上传！');</script>"
			Response.end
		end if
		Dim upload : Set upload = server.createobject(ZBRLibDLLNameSN & ".UploadClass")
		id = Request.Querystring("id")
		groupid = Request.Querystring("groupid")
		If id = "" Then id = 0
		link = upload.Form("link")
		sort = upload.Form("sort")
		Dim file : Set file = upload.file("FilePath")
		Dim fileIsOk
		If file.FileName <> "" Then
			fileIsOk = True
		else
			fileIsOk = False
		end if
		If fileIsOk Then
			FileType = file.FileType
			FileName = file.FileName
			FileSize = file.FileSize
			FilesExt = file.ExtType
			FilePath = "../edit/upimages/shop/"& GetFileNameRule(FilesExt) &""
			upload.Save Server.MapPath(FilePath) ,"FilePath"
			If Err.Number > 0 Then
				Response.write "<script>alert('上传失败："& Err.Description &"');</script>"
				Response.end
			end if
			If id > 0 Then
				sql =       "SELECT TOP 1 c.fpath FROM Shop_HomeGroupItems a " &_
				"INNER JOIN Shop_HomeGroups b ON b.id = a.groupId " &_
				"LEFT JOIN sys_upload_res c ON c.id = a.source " &_
				"WHERE b.[type] = 'BANNER' AND a.id = "& id &" "
				Set rs = cn.Execute(sql)
				If Not rs.Eof Then
					Dim oldPath,oldFileName
					oldFileName = rs(0)
					oldPath = Server.MapPath("../edit/upimages/shop/"& oldFileName)
					Set fso = Server.CreateObject("scripting.FileSystemObject")
					If fso.FileExists(oldPath) Then
						fso.DeleteFile (oldPath),True
					end if
				end if
				rs.close
				set rs = nothing
			end if
			Dim curFileName
			curFileName = GetFileNameRule(FilesExt)
			sql =       "INSERT INTO sys_upload_res " &_
			"(source,id1,ftype,fname,fpath,fsize,addcate,addtime) " &_
			"VALUES " &_
			"('wxBanner',"& id &",'"& FileType &"','"& FileName  &"','"& curFileName  &"','"& FileSize  &"','"& Info.User &"','"& Now() &"') "
			cn.Execute(sql)
		end if
		If id = "0" Then
			cn.Execute("INSERT INTO Shop_HomeGroupItems (groupid,source,link,sort) VALUES ("& groupid &",ISNULL(SCOPE_IDENTITY(),0),'"& link &"',"& sort &")")
		else
			cn.Execute("UPDATE Shop_HomeGroupItems SET source = ISNULL(SCOPE_IDENTITY(),source),link = '"& link &"',sort ="& sort &" WHERE id = "& id &" ")
		end if
		sql =       "SELECT ISNULL(COUNT(*),0) FROM Shop_HomeGroupItems a " &_
		"INNER JOIN Shop_HomeGroups b ON a.groupId = b.id " &_
		"WHERE b.[type] = 'BANNER' "
		Set rs = cn.Execute(sql)
		If Not rs.Eof Then
			count = rs(0)
		end if
		rs.close
		set rs = nothing
		Response.write "" & vbcrlf & "<script>" & vbcrlf & "window.onlistviewRefresh=function(){" & vbcrlf & " parent.document.getElementById(self.name).height=document.body.scrollHeight;" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & ""
		Response.write count
	end sub
	Sub App_delBanner
		Dim id,rs,filename,fpath,fso,sql
		id = Request("id")
		sql =       "SELECT c.fpath FROM Shop_HomeGroupItems a " &_
		"INNER JOIN sys_upload_res c ON c.id = a.source " &_
		"WHERE a.id = "& id &" "
		Set rs = cn.Execute(sql)
		If Not rs.Eof Then
			filename = rs(0)
		end if
		rs.close
		set rs = nothing
		fpath = Server.MapPath("../edit/upimages/shop/"& filename)
		Set fso = Server.CreateObject("scripting.FileSystemObject")
		If fso.FileExists(fpath) Then
			fso.DeleteFile (fpath),True
		end if
		cn.Execute("DELETE Shop_HomeGroupItems WHERE id = "& id &" ")
		Response.write "" & vbcrlf & "<script>" & vbcrlf & "//ifrmae 框架自适应高度" & vbcrlf & "parent.document.getElementById(self.name).height=document.body.scrollHeight;" & vbcrlf & "" & vbcrlf & "window.onlistviewRefresh=function(){" & vbcrlf & "      parent.document.getElementById(self.name).height=document.body.scrollHeight;" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "" & vbcrlf & ""
	end sub
	Sub App_delGoods
		Dim id,rs
		id = Request("id")
		cn.Execute("DELETE Shop_HomeGroupItems WHERE id = "& id &" ")
		Response.write "" & vbcrlf & "<script>" & vbcrlf & "//ifrmae 框架自适应高度" & vbcrlf & "parent.document.getElementById(self.name).height=document.body.scrollHeight;" & vbcrlf & "" & vbcrlf & "window.onlistviewRefresh=function(){" & vbcrlf & "      parent.document.getElementById(self.name).height=document.body.scrollHeight;" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "" & vbcrlf & ""
	end sub
	Sub App_sortGoods
		Dim id,siblingID,sType,rs
		id = Request("id")
		siblingID = Request("siblingID")
		sType = Request("sType")
		cn.Execute("UPDATE Shop_HomeGroupItems SET sort = (CASE '"& sType &"' WHEN 'up' THEN sort + 1 WHEN 'down' THEN sort - 1 END)  WHERE id = "& id &"")
		sType = Request("sType")
		cn.Execute("UPDATE Shop_HomeGroupItems SET sort = (CASE '"& sType &"' WHEN 'up' THEN sort - 1 WHEN 'down' THEN sort + 1 END)  WHERE id = "& siblingID &"")
		sType = Request("sType")
	end sub
	Sub App_delMenu
		Dim id
		id = Request("id")
		cn.Execute("DELETE Shop_HomeGroupItems WHERE groupid = "& id &" ")
		cn.Execute("DELETE Shop_HomeGroups WHERE id = "& id &" ")
	end sub
	Sub App_sortMenu
		Dim id,siblingID,sort,rs
		id = Request("id")
		siblingID = Request("siblingID")
		Set rs = cn.Execute("SELECT ISNULL(sort,1) sort FROM Shop_HomeGroups WHERE id = "& id &" ")
		If Not rs.Eof Then
			sort = rs(0)
		else
			sort = 1
		end if
		rs.close
		set rs = nothing
		cn.Execute("UPDATE Shop_HomeGroups SET sort = (SELECT TOP 1 ISNULL(sort,0) FROM Shop_HomeGroups WHERE id = "& siblingID &")  WHERE id = "& id &"")
		cn.Execute("UPDATE Shop_HomeGroups SET sort = "& sort &"  WHERE id = "& siblingID &"")
	end sub
	Sub App_editPage
		Dim id,fname,rs,sql,title,sort
		id = Request("id")
		If id = "" Then id = 0
		Set rs = server.CreateObject("adodb.recordset")
		sql = "SELECT * FROM Shop_HomeGroups WHERE id = "& id &" "
		rs.Open sql,cn,1,1
		If Not rs.Eof Then
			title = rs("name")
			sort = rs("sort")
		else
			title = ""
			sort = 1
		end if
		rs.close
		set rs = nothing
		If id = "0" Then
			Set rs = cn.Execute("SELECT ISNULL(MAX(sort) + 1,1) sort FROM Shop_HomeGroups WHERE [type] <> 'BANNER'")
'If id = "0" Then
			If Not rs.Eof Then
				sort = rs("sort")
			else
				sort = 1
			end if
			rs.close
			set rs = nothing
		end if
		Response.write "" & vbcrlf & "<style>" & vbcrlf & ".edit-page {" & vbcrlf & "  padding: 20px 10px;" & vbcrlf & "}" & vbcrlf & ".edit-page input.f-text {" & vbcrlf & "   width: 150px;" & vbcrlf & "   height: 16px;" & vbcrlf & "   line-height: 16px;" & vbcrlf & "}" & vbcrlf & ".edit-page input.sort {" & vbcrlf & "      width: 50px;" & vbcrlf & "}" & vbcrlf & "#content {" & vbcrlf & "        width: 100%;" & vbcrlf & "    border: 1px solid #c0ccdd;" & vbcrlf & "      border-collapse: collapse;" & vbcrlf & "      background-image: none;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "#content th, #content td {" & vbcrlf & "      border: 1px solid #c0ccdd;" & vbcrlf & "       padding: 5px;" & vbcrlf & "   height: 24px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "#content th{" & vbcrlf & "      width: 25%;" & vbcrlf & "     text-align: right;      " & vbcrlf & "}" & vbcrlf & "</style>" & vbcrlf & "<div class=""edit-page"">" & vbcrlf & "  <form id=""editFormMod"" name=""editFormMod"" method=""post"" action=""?"">" & vbcrlf & "                <table id=""content"">" & vbcrlf & "                      <tbody>" & vbcrlf & "                         <tr>" & vbcrlf & "                                    <th>模块名称：</th>" & vbcrlf & "                                     <td><input class=""f-text"" type=""text"" name=""title"" value="""
		sort = 1
		Response.write title
		Response.write """ min=""1"" max=""10"" dataType=""Limit"" msg=""长度必须在1个至10个字之间"" onblur=""value=value.replace(/\'/g,'');""> <span class=""red"">*</span> </td>" & vbcrlf & "                         </tr>" & vbcrlf & "                           <tr>" & vbcrlf & "                                    <th>重要指数：</th>" & vbcrlf & "                                     <td><input class=""f-text sort"" type=""text"" name=""sort"" value="""
		Response.write sort
		Response.write """ onkeyup=""value=value.replace(/[^\d]/g,'');this.value=this.value.substr(0,3);"" min=""1"" max=""999"" dataType=""number"" msg=""请输入正确的数值！"">（指数越高排在越前面）</td>" & vbcrlf & "                            </tr>" & vbcrlf & "                   </tbody>" & vbcrlf & "                </table>                " & vbcrlf & "        </form>" & vbcrlf & "</div>" & vbcrlf & ""
	end sub
	Sub App_bannerPage
		Dim id,fname,rs,sql,filePath,sort,bannerID, link
		id = Request("id")
		If id = "" Then id = 0
		Set rs = server.CreateObject("adodb.recordset")
		sql =       "SELECT c.fpath,a.link,a.sort FROM Shop_HomeGroupItems a " &_
		"INNER JOIN sys_upload_res c ON c.id = a.source " &_
		"WHERE a.id = "& id &" "
		rs.Open sql,cn,1,1
		If Not rs.Eof Then
			filePath = rs("fpath")
			link = rs("link")
			sort = rs("sort")
		else
			filePath = ""
			sort = 1
		end if
		rs.close
		set rs = nothing
		If id = "0" Then
			sql =       "SELECT ISNULL(MAX(a.sort) + 1,1) sort FROM Shop_HomeGroupItems a " &_
			"INNER JOIN Shop_HomeGroups b ON a.groupId = b.id"  &_
			"WHERE [type] = 'BANNER' "
			Set rs = cn.Execute(sql)
			If Not rs.Eof Then
				sort = rs("sort")
			else
				sort = 1
			end if
			rs.close
			set rs = nothing
		end if
		Response.write "" & vbcrlf & "<style>" & vbcrlf & ".edit-page {" & vbcrlf & "  padding: 20px 10px;" & vbcrlf & "}" & vbcrlf & ".edit-page input.f-text {" & vbcrlf & "   width: 250px;" & vbcrlf & "   height: 16px;" & vbcrlf & "   line-height: 16px;" & vbcrlf & "}" & vbcrlf & ".edit-page input.sort {" & vbcrlf & "      width: 50px;" & vbcrlf & "}" & vbcrlf & "#content {" & vbcrlf & "        width: 100%;" & vbcrlf & "    border: 1px solid #c0ccdd;" & vbcrlf & "      border-collapse: collapse;" & vbcrlf & "      background-image: none;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "#content th, #content td {" & vbcrlf & "      border: 1px solid #c0ccdd;" & vbcrlf & "       padding: 5px;" & vbcrlf & "   height: 24px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "#content th{" & vbcrlf & "      width: 25%;" & vbcrlf & "     text-align: right;" & vbcrlf & "}" & vbcrlf & "/* 文件浏览按钮样式 */" & vbcrlf & ".file-btn-box{display:inline-block; width:40px; height:22px; position:relative; overflow:hidden; vertical-align:-9px;}" & vbcrlf & ".file-btn{" & vbcrlf & "        position: absolute; " & vbcrlf & "    top: 0; " & vbcrlf & "        right: 0; " & vbcrlf & "      z-index: 10;" & vbcrlf & "    background-image: url(../images/anybutton_bg.gif);" & vbcrlf & "      background-repeat: repeat-x;" & vbcrlf & "     border: 1px solid #9FA3BC;" & vbcrlf & "      height: 20px;" & vbcrlf & "   color: #486D9E;" & vbcrlf & " font-size: 12px;" & vbcrlf & "        margin:0 0px;" & vbcrlf & "   padding-top: 1px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".file-input{position:absolute; right:0; top:0; z-index:20; font-size:100px;opacity:0; filter:alpha(opacity=0); cursor: pointer;}" & vbcrlf & "" & vbcrlf & "</style>" & vbcrlf & "" & vbcrlf & "<div class=""edit-page"">" & vbcrlf & " <form id=""editFormBanner"" name=""editFormBanner"" method=""post"" action=""?__msgid=saveBanner""  enctype=""multipart/form-data"">" & vbcrlf& "               <table id=""content"">" & vbcrlf & "                      <tbody>" & vbcrlf & "                         <tr>" & vbcrlf & "                                    <th>上传图片：</th>" & vbcrlf & "                                     <td>" & vbcrlf & "                                    <input class=""f-text"" type=""text"" id=""fPath"" name=""fPath"" value="""
		sort = 1
		Response.write filePath
		Response.write """ disabled min=""1"" max=""1000"" dataType=""Limit"" msg=""请选择要上传的图片"">" & vbcrlf & "                                  <span class=""file-btn-box""><input class=""file-btn"" type=""button"" name=""sbtn"" value=""浏览"" class=""page""><input class=""file-input"" type=""file"" name=""filePath"" value="""
		'Response.write filePath
		Response.write filePath
		Response.write """ onchange=""fPath.value = this.value""></span>" & vbcrlf & "                                       <span class=""red"">*</span> </td>" & vbcrlf & "                          </tr>" & vbcrlf & "                           <tr>" & vbcrlf & "                                    <th>链接地址：</th>" & vbcrlf & "                                     <td><input class=""f-text"" type=""text"" name=""link"" value="""
		'Response.write filePath
		Response.write link
		Response.write """ min=""0"" max=""10"" dataType=""Url"" msg=""请填写正确的链接地址""> <span class=""red"">*</span> </td>" & vbcrlf & "                              </tr>" & vbcrlf & "                           <tr>" & vbcrlf & "                                    <th>重要指数：</th>" & vbcrlf & "                                     <td><input class=""f-text sort"" type=""text"" name=""sort"" value="""
		'Response.write link
		Response.write sort
		Response.write """ onkeyup=""value=value.replace(/[^\d]/g,'');this.value=this.value.substr(0,3);"" min=""1"" max=""999"" dataType=""number"" msg=""请输入正确的数值！"">（指数越高排在越前面）</td>" & vbcrlf & "                            </tr>" & vbcrlf & "                           <tr>" & vbcrlf & "                                    <td colspan=""2"">" & vbcrlf & "                                          <ul style=""padding-left: 80px;"">" & vbcrlf & "                                                   <li> </li>" & vbcrlf & "                                                      <li>友情提示：请将上传文件大小控制在200k以内。</li>" & vbcrlf & "                                                     <li>最佳尺寸：800 * 480 (px) 格式要求：JPEG/JPG/GIF/PNG</li>" & vbcrlf & "                                                    <li></li>" & vbcrlf & "                                               </ul>" & vbcrlf & "                                   </td>" & vbcrlf & "                           </tr>" & vbcrlf & "                   </tbody>" & vbcrlf & "                </table>" & vbcrlf & "     </form>" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "</div>" & vbcrlf & ""
	end sub
	Sub WriteHeadHtml
		Response.write "" & vbcrlf & "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN"" ""http://www.w3.org/TR/html4/loose.dtd"">" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & "<meta http-equiv=""X-UA-Compatible"" content=""IE=EmulateIE7""> "& vbcrlf & "<title>微信商城首页设置</title>" & vbcrlf & "<link href=""../inc/themes/default/easyui.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write """ rel=""stylesheet"" type=""text/css""/>" & vbcrlf & "<link href=""../skin/default/css/comm.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write """ rel=""stylesheet"" type=""text/css""/>" & vbcrlf & "<link href=""../inc/cskt.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<script src=""../inc/dateid.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "<script src=""../inc/jquery-1.8.0.min.js?ver="
		'Response.write Application("sys.info.jsver")
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "<script type=""text/JavaScript"" src=""../skin/default/js/comm.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "<script type=""text/JavaScript"" src=""../skin/default/js/comm.listview.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "" & vbcrlf & "<link href=""../inc/themes/icon.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write """ rel=""stylesheet"" type=""text/css""/>" & vbcrlf & "<link href='../inc/showLoading.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write "' rel='stylesheet' type='text/css'/>" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "<!--" & vbcrlf & "body {" & vbcrlf & "   background-color: #FFFFFF!important;" & vbcrlf & "    scrollbar-highlight-color:#fff;" & vbcrlf & " scrollbar-face-color:#f0f0ff;" & vbcrlf & "   scrollbar-arrow-color:#c0c0e8;" & vbcrlf & "        scrollbar-shadow-color:#d0d0e8;" & vbcrlf & " scrollbar-darkshadow-color:#fff;" & vbcrlf & "        scrollbar-base-color:#ffffff;" & vbcrlf & "   scrollbar-track-color:#fff;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".listview {" & vbcrlf & " margin: 10px;" & vbcrlf & "}" & vbcrlf & ".lvwpagesizearea {" & vbcrlf & "        display: none;" & vbcrlf & "}" & vbcrlf & ".lvwheader,.lvw_cell{" & vbcrlf & "    border-right:0px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "#mainIF{" & vbcrlf & "      padding-bottom:20px;" & vbcrlf & "}" & vbcrlf & ".no-date {" & vbcrlf & " text-align: center;" & vbcrlf & "     height: 30px;" & vbcrlf & "  line-height: 30px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "/* 不显示loading */" & vbcrlf & ".panel-loading {" & vbcrlf & "  display: none;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".lvw_cell TD {" & vbcrlf & "   color: #5b7cae;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".lvw_cell a {" & vbcrlf & "        color: #2f496e;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "#lvw_pindex_1 {height:15px;}" & vbcrlf & ".panel-header{" & vbcrlf & "      height:38px!important;" & vbcrlf & "  background-color:#FFF!important;" & vbcrlf & "}" & vbcrlf & "-->" & vbcrlf & "</style>" & vbcrlf & "<script type=""text/JavaScript"" src=""../inc/jquery.easyui.min.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write """></script>" & vbcrlf & "<script src='../inc/jquery.showLoading.min.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write "'></script>" & vbcrlf & "<!-- <script src='../inc/AjaxLoading.js?ver="
		'Response.write Application("sys.info.jsver")
		Response.write Application("sys.info.jsver")
		Response.write "'></script> -->" & vbcrlf & "<script>" & vbcrlf & "// 处理Banner添加按钮的状态" & vbcrlf & "function dealBannerAddBtnState() {" & vbcrlf & "  var ifrm = $(window.frames[""mainIF""].document);" & vbcrlf & "   var btn = ifrm.find(""#addBannerBtn"");" & vbcrlf & "     var num = ifrm.find(""#lvw_tby_1 tr[l_r=1]"").size();" & vbcrlf & "    if(num >= 4){" & vbcrlf & "           btn.attr(""disabled"",true);" & vbcrlf & "        }else {" & vbcrlf & "         btn.removeAttr(""disabled"");" & vbcrlf & "       };" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "// 维护模块添加按钮状态" & vbcrlf & "function dealMenuAddBtnState(){" & vbcrlf & "      var num = $(""#__menuTree li"").size();" & vbcrlf & "      if(num > 20){" & vbcrlf & "           $(""#addMenuBtn"").attr(""title"",""模块已经超过20个,不能再添加"");" & vbcrlf & " }else{" & vbcrlf & "          $(""#addMenuBtn"").removeAttr(""disabled"");" & vbcrlf & "            $(""#addMenuBtn"").attr(""title"","""");" & vbcrlf & "     };" & vbcrlf & "      " & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "$.fn.tree.defaults.loadFilter = function (data, parent) {" & vbcrlf & "     var opt = $(this).data().tree.options;" & vbcrlf & "  var idFiled, "& vbcrlf & "    textFiled," & vbcrlf & "      parentField;" & vbcrlf & "   if (opt.parentField) {" & vbcrlf & "          idFiled = opt.idFiled || 'id';" & vbcrlf & "          textFiled = opt.textFiled || 'text';" & vbcrlf & "            parentField = opt.parentField;" & vbcrlf & "          " & vbcrlf & "                var i," & vbcrlf & "          l," & vbcrlf & "              treeData = []," & vbcrlf & "          tmpMap = [];" & vbcrlf& "                " & vbcrlf & "                for (i = 0, l = data.length; i < l; i++) {" & vbcrlf & "                      tmpMap[data[i][idFiled]] = data[i];" & vbcrlf & "             }" & vbcrlf & "" & vbcrlf & "               for (i = 0, l = data.length; i < l; i++) {" & vbcrlf & "                      if (tmpMap[data[i][parentField]] && data[i][idFiled] != data[i][parentField]) {" & vbcrlf & "                            if (!tmpMap[data[i][parentField]]['children'])" & vbcrlf & "                                  tmpMap[data[i][parentField]]['children'] = [];" & vbcrlf & "                          data[i]['text'] = data[i][textFiled];" & vbcrlf & "                           tmpMap[data[i][parentField]]['children'].push(data[i]);" & vbcrlf & "                 } else {" & vbcrlf & "                        data[i]['text'] = data[i][textFiled];" & vbcrlf & "                           treeData.push(data[i]);" & vbcrlf & "                 }" & vbcrlf & "               }" & vbcrlf & "               return treeData;" & vbcrlf & "        }" & vbcrlf & "       return data;" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "$(function(){" & vbcrlf & "     treeInit();"& vbcrlf & "});" & vbcrlf & vbcrlf & "var curNode;" & vbcrlf & "function treeInit(){" & vbcrlf & "        $('#__menuTree').tree({" & vbcrlf & "         url:"""
		Response.write "?act=reminders""," & vbcrlf & "        $Click:function(node){" & vbcrlf & "                        curNode = node;" & vbcrlf & "                 //loadSetting(node.id);" & vbcrlf & "                 var text = node.text," & vbcrlf & "                           groupid = node.id," & vbcrlf & "                              sort = node.attributes.sort;" & vbcrlf & "                    $("".panel-title"").eq(1).html(""当前模块 -> <span class='red'>""+ text + ""</span>"");" & vbcrlf & "                    var url = ""?__msgid=mainPage"";" & vbcrlf & "                    if(sort != 99999){" & vbcrlf & "                              url = ""?__msgid=goodsListPage&groupid="" + groupid" & vbcrlf & "                 };" & vbcrlf & "                      document.getElementById(""mainIF"").src=url;" & vbcrlf & "                }," & vbcrlf & "              onContextMenu: function(e,node){" & vbcrlf & "                 e.preventDefault();" & vbcrlf & "                     var $tree = $(this),$mm = $('#mm');" & vbcrlf & "                     curNode = node;" & vbcrlf & "                 $tree.tree('select',node.target);" & vbcrlf & "" & vbcrlf & "                       var isFirst = $(node.target).text().indexOf(""首页Banner"") == 0;" & vbcrlf & "" & vbcrlf& "                        // 首页banner 不允许修改、删除" & vbcrlf & "                  $mm.menu($(node.target).parent().prevAll().size()==0?'disableItem':'enableItem',$mm.menu('findItem','修改').target);" & vbcrlf & "                    $mm.menu($(node.target).parent().prevAll().size()==0?'disableItem':'enableItem',$mm.menu('findItem','删除').target);" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "                 //上移菜单控制（最后一个菜单不允许上移）" & vbcrlf & "                        $mm.menu($(node.target).parent().prevAll().size()==1 || isFirst?'disableItem':'enableItem',$mm.menu('findItem','上移').target);" & vbcrlf & "                 //下移菜单控制（最后一个菜单不允许下移）" & vbcrlf & "                        $mm.menu($(node.target).parent().nextAll().size()==0 || isFirst?'disableItem':'enableItem',$mm.menu('findItem','下移').target);" & vbcrlf & "                      " & vbcrlf & "" & vbcrlf & "                        $mm.menu('show',{" & vbcrlf & "                               left: e.pageX," & vbcrlf & "                          top: e.pageY" & vbcrlf & "                    });" & vbcrlf & "             }," & vbcrlf & "              onLoadSuccess :function(node,data){" & vbcrlf & "                     var $tree = $(this);" & vbcrlf & "//                  alert(data[0].target)" & vbcrlf & "                   $tree.tree('select',$tree.tree('find',data[0].id).target);" & vbcrlf & "              }       " & vbcrlf & "                " & vbcrlf & "        });" & vbcrlf & "" & vbcrlf & "     // 维护添加模块按钮状态" & vbcrlf & " setTimeout(function(){" & vbcrlf & "          dealMenuAddBtnState();" & vbcrlf & "       },500);" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "function menuUp(){" & vbcrlf & "      var id = curNode.id;" & vbcrlf & "    var siblingID = $('#__menuTree').tree('getNode',$(curNode.target).parent().prev().children()[0]).id || 0;" & vbcrlf & "       $.post(""?__msgid=sortMenu"",{id:id,siblingID:siblingID},function(data){" & vbcrlf & "              $(curNode.target).parent()[0].swapNode($(curNode.target).parent().prev()[0]);" & vbcrlf & "   });" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "function menuDown(){" & vbcrlf & "       var id = curNode.id;" & vbcrlf & "    var siblingID = $('#__menuTree').tree('getNode',$(curNode.target).parent().next().children()[0]).id || 0;" & vbcrlf & "    $.post(""?__msgid=sortMenu"",{id:id,siblingID:siblingID},function(data){" & vbcrlf & "            $(curNode.target).parent()[0].swapNode($(curNode.target).parent().next()[0]);" & vbcrlf & "   });" & vbcrlf & "   " & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "// 删除模块" & vbcrlf & "function menuDelete(){" & vbcrlf & "      var id = curNode.id;" & vbcrlf & "    if(!confirm(""确定要删除吗？删除后将不可恢复！"")){" & vbcrlf & "         return false;" & vbcrlf & "   };" & vbcrlf & "      " & vbcrlf & "        $.post(""?__msgId=delMenu"",{id:id},function(data){" & vbcrlf & "             treeInit();" & vbcrlf & "             $(""#__menuTree li:first div"").trigger(""click"");" & vbcrlf & "     });" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "// 编辑模块" & vbcrlf & "function menuEdit(){" & vbcrlf & "    var id = curNode.id;" & vbcrlf & "    opendlg(id);" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "function loadSetting(nodeid,pid){" & vbcrlf & "        $.ajax({" & vbcrlf & "                url:'?__msgId=loadSingleNode'," & vbcrlf & "          data:{id:nodeid,pid:pid}," & vbcrlf & "               success:function(html){" & vbcrlf & "                 $('#settingPanel').html(html);" & vbcrlf & "                   $('#settingPanel').find('#content').children().children(':last').css({height:$('#settingPanel').parent().parent().height() - $('#settingPanel').find('#content').height()});" & vbcrlf & "            }" & vbcrlf & "       });" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "// 刷新方法" & vbcrlf & "function banner_refresh (){" & vbcrlf & "    document.getElementById('mainIF').contentWindow.lvw_refresh(1);" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "// 删除banner" & vbcrlf & "function delBanner(id) {" & vbcrlf & "  if(!confirm(""确定要删除吗？删除后将不可恢复！"")){" & vbcrlf & "         return false;" & vbcrlf & "   };" & vbcrlf & "      var parms = {" & vbcrlf & "           id : id" & vbcrlf & " };" & vbcrlf & "" & vbcrlf & "      $.post(""?__msgid=delBanner"",parms,function(data){         " & vbcrlf & "                banner_refresh();" & vbcrlf & "       });" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "// 验证文件扩展名" & vbcrlf & "function checkFileExt(){"& vbcrlf & "               var allowExt=""|jpeg|jpg|png|gif|"";" & vbcrlf & "                var arrExt = $(""#fPath"").val().split(""."");" & vbcrlf & "          var fExt = arrExt[arrExt.length-1];" & vbcrlf & "             if(allowExt.toLowerCase().indexOf('|'+fExt.toLowerCase()+'|')<0 && arrExt.length!=0)" & vbcrlf & "            {" & vbcrlf & "                       app.Alert(""上传的文件不合法,只能上传 ""+ allowExt +"" 格式的文件"")" & vbcrlf & "                   return false;" & vbcrlf & "           }else{" & vbcrlf & "                  return true;    " & vbcrlf & "                };" & vbcrlf & "};" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "// 添加banner 对话框" & vbcrlf & "var $uploadDlg;" & vbcrlf & "function openUploadDlg(id){" & vbcrlf & "      if(!!$dlg){     $dlg.dialog(""close"") };" & vbcrlf & "" & vbcrlf & "   id = id || 0;" & vbcrlf & "   try{" & vbcrlf & "            var groupid = $('#__menuTree').tree('getSelected').id || 0;" & vbcrlf & "     }catch(e){" & vbcrlf & "              alert(e);" & vbcrlf & "               return false;" & vbcrlf & "   };" & vbcrlf & "      var posturl = '?__msgid=saveBanner&groupid='+ groupid +'&id='+ id +''" & vbcrlf & " var btns;       " & vbcrlf & "        btns = [" & vbcrlf & "                        {" & vbcrlf & "                               text: '保存'," & vbcrlf & "                           iconCls: 'icon-save'," & vbcrlf & "                           handler: function () {" & vbcrlf & "                                  $('#editFormBanner').form({" & vbcrlf & "                                             url:posturl," & vbcrlf & "                                                    onSubmit:function(){" & vbcrlf & "                                                            // 表单验证                                                             " & vbcrlf & "                                                                if(!Validator.Validate(this,2)){" & vbcrlf & "                                                                        return false;   " & vbcrlf & "                                                                };" & vbcrlf & "                                                              if(!checkFileExt()){" & vbcrlf & "                                                                    return false;" & vbcrlf & "           };" & vbcrlf & "                                                      }," & vbcrlf & "                                                      success:function(data){ " & vbcrlf & "                                                                banner_refresh();" & vbcrlf & "                                                               $uploadDlg.dialog('close');" & vbcrlf & "                                                     }," & vbcrlf & "                                                      error:function(){" & vbcrlf & "                                                               alert('error');" & vbcrlf & "                                                 }" & vbcrlf & "               }).submit();" & vbcrlf & "" & vbcrlf & "                            }" & vbcrlf & "                       }," & vbcrlf & "                      {" & vbcrlf & "                               text: '增加'," & vbcrlf & "                           iconCls: 'icon-add'," & vbcrlf & "                            handler: function () {" & vbcrlf & "                                  $('#editFormBanner').form({" & vbcrlf & "                                                     url:posturl," & vbcrlf & "                                                    onSubmit:function(){" & vbcrlf & "                                                                // 表单验证                                                             " & vbcrlf & "                                                                if(!Validator.Validate(this,2)){" & vbcrlf & "                                                                        return false;   " & vbcrlf & "                                                                };" & vbcrlf & "                                                              if(!checkFileExt()){" & vbcrlf & "                                                                    return false;" & vbcrlf & "                                                           };" & vbcrlf & "                                                      }," & vbcrlf& "                                                        success:function(data){" & vbcrlf & "                                                         banner_refresh();" & vbcrlf & "                                                               $uploadDlg.dialog('close');" & vbcrlf & "                                                             // 限定最多可以添加4个" & vbcrlf & "                                                          if(data < 4){" & vbcrlf & "                                                                   openUploadDlg(id);" & vbcrlf & "                                                              }" & vbcrlf & "                                                       }," & vbcrlf & "                                                      error:function(){" & vbcrlf & "                                                            alert('error');" & vbcrlf & "                                                 }" & vbcrlf & "                                               }).submit();" & vbcrlf & "" & vbcrlf & "                                    " & vbcrlf & "                                }" & vbcrlf & "                       }," & vbcrlf & "                      {" & vbcrlf & "                               text: '重填'," & vbcrlf & "                           iconCls: 'icon-undo'," & vbcrlf & "                           handler: function() {" & vbcrlf & "                                        $('#editFormBanner').form('reset');" & vbcrlf & "                             }" & vbcrlf & "                       }" & vbcrlf & "               ];" & vbcrlf & "" & vbcrlf & "      var curTitle,status,sname;" & vbcrlf & "      sname = 'Banner';" & vbcrlf & "       switch(id) {" & vbcrlf & "            case 0 :" & vbcrlf & "                        status = ""添加"";" & vbcrlf & "  break;" & vbcrlf & "          default :" & vbcrlf & "                       status = ""修改"";" & vbcrlf & "                  btns.splice(1,1);" & vbcrlf & "                       break;" & vbcrlf & "  };" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "      curTitle = status + sname;      " & vbcrlf & "" & vbcrlf & "                " & vbcrlf & "        if(!$uploadDlg){" & vbcrlf & "                $uploadDlg = $('<div>').appendTo(document.body);" & vbcrlf & "  };" & vbcrlf & "      $uploadDlg.dialog({" & vbcrlf & "             title: curTitle," & vbcrlf & "                width:500," & vbcrlf & "              top: ""20%""," & vbcrlf & "               href:""?__msgId=bannerPage&id=""+ id +""""," & vbcrlf & "             buttons: btns" & vbcrlf & "   }).dialog();" & vbcrlf &"};" & vbcrlf & "" & vbcrlf & "// 创建对话框" & vbcrlf & "var $dlg;" & vbcrlf & "function opendlg(id){" & vbcrlf & "     if(!!$uploadDlg){ $uploadDlg.dialog(""close"") };" & vbcrlf & "   id = id || 0;" & vbcrlf & "   if (id==0){" & vbcrlf & "             var num = $(""#__menuTree li"").size();" & vbcrlf & "             if(num > 20){" & vbcrlf & "                     alert(""模块已经超过20个,不能再添加"");" & vbcrlf & "             }" & vbcrlf & "       }" & vbcrlf & "" & vbcrlf & "       var btns;" & vbcrlf & "       btns = [" & vbcrlf & "                        {" & vbcrlf & "                               text: '保存'," & vbcrlf & "                           iconCls: 'icon-save'," & vbcrlf & "                           handler: function () {" & vbcrlf & "                                  $('#editFormMod')   .form({" & vbcrlf & "                                                      url:'?__msgid=saveEdit&id='+ id +''," & vbcrlf & "                                                    onSubmit:function(){" & vbcrlf & "                                                            // 表单验证" & vbcrlf & "                                                             return Validator.Validate(this,2);" & vbcrlf & "                                                      }," & vbcrlf & "                                                      success:function(data){" & vbcrlf & "                                                         treeInit();" & vbcrlf& "                                                                $dlg.dialog('close');" & vbcrlf & "                                                   }," & vbcrlf & "                                                      error:function(){" & vbcrlf & "                                                               alert('error');" & vbcrlf & "                                                 }" & vbcrlf & "                                               }).submit();" & vbcrlf & "" & vbcrlf & "                            }" & vbcrlf & "                       }," & vbcrlf & "                      {" & vbcrlf & "                               text: '重填'," & vbcrlf & "           iconCls: 'icon-undo'," & vbcrlf & "                           handler: function () {" & vbcrlf & "                                  $('#editFormMod').form('reset');" & vbcrlf & "                                }" & vbcrlf & "                       }" & vbcrlf & "               ];" & vbcrlf & "" & vbcrlf & "      var curTitle,status,sname;" & vbcrlf & "      switch(id) {" & vbcrlf & "            case 0 :" & vbcrlf & "                        status =""添加"";" & vbcrlf & "                       break;" & vbcrlf & "          default :" & vbcrlf & "                       status = ""修改"";" & vbcrlf & "                  btns.splice(1,1);" & vbcrlf & "                       break;" & vbcrlf & "  };" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "      curTitle = status + sname;      " & vbcrlf & "" & vbcrlf & "        curTitle = status+""模块"";" & vbcrlf & "           " & vbcrlf & "        if(!$dlg){" & vbcrlf & "              $dlg = $('<div>').appendTo(document.body);" & vbcrlf & "      };" & vbcrlf & "      $dlg.dialog({" & vbcrlf & "           title: curTitle," & vbcrlf & "                width:500," & vbcrlf & "              top: ""20" & Chr(37) & """," & vbcrlf & "               href:""?__msgId=editPage&id=""+ id +""""," & vbcrlf & "               buttons: " & "btns," & vbcrlf & "                loadingMessage: """"" & vbcrlf & "        }).dialog();" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "</head>" & vbcrlf & ""
	end sub
	Sub App_MenuSetting
		Call WriteHeadHtml
		Response.write "" & vbcrlf & "      <body class=""easyui-layout"">" & vbcrlf & "              <div region='north' split=""false"" style=""height:34px;overflow:hidden;"">" & vbcrlf & "                     <div class=""resetPopupBg"" style=""width:100%;height:100%;background-color:#FFF"">" & vbcrlf & "                             <div style=""float:left;width:255px;height:100%;line-height:36px;color:#2f496e"" class=""place"">" & vbcrlf & "                              微信商城首页设置" & vbcrlf & "                                </div>" & vbcrlf & "                          <div style=""float:right;padding-right:10px;padding-top:6px;"">" & vbcrlf & "                                     <button id=""addMenuBtn"" onclick=""opendlg(0);""  class=""anybutton"" style=""cursor:pointer""/>添加模块</button>" & vbcrlf & "                              </div>" & vbcrlf & "                  </div>" & vbcrlf & "          </div>" & vbcrlf & "          <div regionrlf" & "             </div>" & vbcrlf & "          <div id=""navTitle"" region='center' title='设置内容' style=""padding:0px;"">           " & vbcrlf & "                        <div id=""settingPanel"" style=""height:100%;overflow:hidden;"" onselect=""return false;"">" & vbcrlf & "                         <iframe id=""mainIF"" name=""mainIF"" src=""?__msgid=mainPage"" width=""100%"" height=""100%"" frameborder=""0"" scrolling=""no""></iframe>" & vbcrlf & "                      </div>" & vbcrlf & "          </div>" & vbcrlf & "" & vbcrlf & "          <div id=""mm"" class=""easyui-menu"" style=""width:120px;height:auto;"">" & vbcrlf & "                    <div onclick=""menuUp()"" data-options=""iconCls:'icon-up'"">上移</div>" & vbcrlf & "                 <div onclick=""menuDown()"" data-options=""iconCls:'icon-down'"">下移</div>" & vbcrlf & "                     <div class=""menu-sep""></div>" & vbcrlf & "                      <div onclick=""menuEdit()"" data-options=""iconCls:'icon-edit'"">修改</div>" & vbcrlf & "                     <div onclick=""menuDelete()"" data-options=""iconCls:'icon-cancel'"">删除</div>" & vbcrlf & "                </div>" & vbcrlf & "" & vbcrlf & "  </body>" & vbcrlf & " </html>" & vbcrlf & " "
		'Call WriteHeadHtml
	end sub
	
%>
