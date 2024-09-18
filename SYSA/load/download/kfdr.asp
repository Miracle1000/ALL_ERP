<%@ language=VBScript %>
<%
	server.scripttimeout = 3600
	Response.CharSet = "UTF-8"
	Class Base64Class
		Private obj
		Private Sub cobject
			If obj Is Nothing Then Set obj = server.createobject(ZBRLibDLLNameSN & ".Base64Class")
		end sub
		Public Function base64Decode(ByVal p)
			cobject : base64Decode = obj.base64Decode(p)
		end function
		Public Function base64Encode(ByVal p)
			cobject : base64Encode = obj.base64Encode(p)
		end function
		Public Function DeCode(ByVal p)
			cobject : DeCode = obj.DeCode(p)
		end function
		Public Function DeCrypt(ByVal p)
			cobject : DeCrypt = obj.DeCrypt(p)
		end function
		Public Function deurl(ByVal p)
			cobject : deurl = obj.deurl(p)
		end function
		Public Function pwurl(ByVal p)
			cobject : pwurl = obj.pwurl(p)
		end function
		Public Function URLDecode(ByVal p)
			cobject : URLDecode = obj.URLDecode(p)
		end function
		Public Function EnCode(ByVal p)
			cobject : EnCode = obj.EnCode(p)
		end function
		Public Function EnCrypt(ByVal p)
			cobject : EnCrypt = obj.EnCrypt(p)
		end function
		Public Function MD5(ByVal p)
			cobject : MD5 = obj.MD5(p)
		end function
	End Class
	ZBRLibDLLNameSN = "ZBRLib3205"
	Set zblog = server.createobject(ZBRLibDLLNameSN & ".ZBSysLog")
	zblog.init me
	Class DBCommand
		public CreateAutoField
		Public Property Get user
		user = Session("_sys_db_user")
		End Property
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
			server_1 = Application("_sys_sql_svr")
			sql_1 = Application("_sys_sql_db")
			user_1 = Application("_sys_sql_uid")
			pw_1 = Application("_sys_sql_pwd")
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
			conn.cursorlocation = 3
			conn.open (connText)
			conn.CommandTimeout = 600
			if abs(err.number) > 0 then
				Response.write "数据库链接失败 - [" & err.Description & "]"
'if abs(err.number) > 0 then
				Response.end
			end if
			Set getConnection = conn
		end function
		Public Sub CreateDbTableByRecordSet(tname,rs)
			Dim sql , i
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
			on error resume next
			cn.execute sql
			if  abs(err.number) > 0 then
				app.showerr "dbCommand.CreateDbTableByRecordSet失败：" , err.description & "<br>相关SQL:" & sql
				Response.end
				exit sub
			end if
			on error goto 0
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
			Dim sql , i , ii, repcols, fn
			on error resume next
			For i = 0 To rs.fields.count -1
'Dim sql , i , ii, repcols, fn
				fn = rs.fields(i).name
				If InStr(repcols, Chr(1) & fn & Chr(1)) >0 Then
					fn = fn & "1"
					ii = 0
					While  InStr(repcols, Chr(1) & fn & Chr(1)) >0 And ii <10
						fn = fn & "1"
						ii = ii+1
'fn = fn & "1"
					wend
				end if
				sql = sql  & "[" & fn & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
				If i <  rs.fields.count -1 Then sql = sql & "," & vbcrlf
'sql = sql  & "[" & fn & "]  " & GetSqlDBTypeText(rs.fields(i)) & "  NULL"
				repcols = repcols & Chr(1) & fn & Chr(1)
			next
			GetDbColText = Replace(Replace(sql & "@###",",@###",""),"@###","")
		end function
		Public Function GetSqlDBTypeText(fld)
			Dim r , fSize
			fSize = fld.DefinedSize
			if fSize = 0 then fSize = 1000
			If (fld.type = 131 Or fld.type = 139) And fSize<25 Then fSize = 25
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
			If typeId = 3 Then
				r = "int"
			elseIf (typeId > 1 And typeId < 7) Or (typeId > 15 And typeID < 22 ) Or typeId - 131 = 0 Then
'r = "int"
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
	Class AppInfo
		Private musername
		private is_admin
		private mtitle
		private mFloatNumber
		private mCommPriceNumber
		private mSalesPriceMoney
		private mStorePriceMoney
		private mFinancePriceMoney
		public function FloatNumber
			if len( mFloatNumber) = 0 then
				dim rs
				set rs = cn.execute("select num1 from setjm3  where ord=88")
				if rs.eof = false then
					mFloatNumber = rs.fields(0).value
				end if
				rs.close
			end if
			FloatNumber = mfloatnumber
		end function
		public function MoneyNumber
			if len( mMoneyNumber) = 0 then
				dim rs
				set rs = cn.execute("select num1 from setjm3  where ord=1")
				if rs.eof = false then
					mMoneyNumber = rs.fields(0).value
				end if
				rs.close
			end if
			MoneyNumber = mMoneyNumber
		end function
		public function CommPriceNumber
			if len( mCommPriceNumber) = 0 then
				dim rs
				set rs = cn.execute("select num1 from setjm3  where ord=2019042801")
				if rs.eof = false then
					mCommPriceNumber = rs.fields(0).value
				end if
				rs.close
			end if
			CommPriceNumber = mCommPriceNumber
		end function
		public function SalesPriceNumber
			if len( mSalesPriceMoney) = 0 then
				dim rs
				set rs = cn.execute("select num1 from setjm3  where ord=2019042802")
				if rs.eof = false then
					mSalesPriceMoney = rs.fields(0).value
				end if
				rs.close
			end if
			SalesPriceNumber = mSalesPriceMoney
		end function
		public function StorePriceNumber
			if len( mStorePriceMoney) = 0 then
				dim rs
				set rs = cn.execute("select num1 from setjm3  where ord=2019042803")
				if rs.eof = false then
					mStorePriceMoney = rs.fields(0).value
				end if
				rs.close
			end if
			StorePriceNumber = mStorePriceMoney
		end function
		public function FinancePriceNumber
			if len( mFinancePriceMoney) = 0 then
				dim rs
				set rs = cn.execute("select num1 from setjm3  where ord=2019042804")
				if rs.eof = false then
					mFinancePriceMoney = rs.fields(0).value
				end if
				rs.close
			end if
			FinancePriceNumber = mFinancePriceMoney
		end function
		Public Property Get title()
		dim rs
		if len(mtitle) = 0 then
			set rs = cn.execute("select intro from setjm3  where ord=6")
			if rs.eof = false then
				mtitle = rs.fields(0).value
			end if
			rs.close
		end if
		if len(mtitle) = 0 then mtitle = "智邦国际"
		title = mtitle
		End Property
		Public Property Get version
		version = "2.0"
		End Property
		Public Property Get CompanyName
		CompanyName="智邦国际"
		End Property
		Public Property Get fullCompanyName
		fullCompanyName="智邦国际软件科技有限公司"
		End Property
		Public Property Get user
		user = session("personzbintel2007") & ""
		If Len(user) = 0 Then
			user =  request.querystring("__sys_uid_sign")
			if isnumeric(user)= false then
				user = 0
			else
				user = clng(user)
			end if
		end if
		End Property
		Public Property Get isAdmin
		if len(is_admin) = 0 then
			Set rs = cn.execute("select top1 from gate where ord=" & me.user)
			if rs.eof then
				is_admin = false
			else
				is_admin = (rs.fields(0).value & "" = "1")
			end if
			rs.close
		end if
		isAdmin = is_admin
		End Property
		Public Property Get username
		If Len(musername) = 0 Then
			Set rs = cn.execute("select name from gate where ord=" & me.user)
			If rs.eof Then
				musername = "未知用户"
			else
				musername = rs.fields(0).value
			end if
			rs.close
		end if
		username = musername
		End Property
		Public Property Get DebugMode
		DebugMode = True
		End Property
		Private Sub Class_Initialize()
		end sub
	End Class
	Class Collection
		Public Items
		Public Count
		Public Sub Class_Initialize()
			ReDim Items(0)
			Count = 0
		end sub
		Public Sub RedimUBound(uIndex)
			ReDim preserve Items(uIndex)
			Count = uIndex
		end sub
		Public Sub Add(Item)
			Count = Count + 1
'Public Sub Add(Item)
			ReDim preserve Items(Count)
			If IsObject(Item) Then
				Set Items(Count) = item
			else
				items(count) = item
			end if
		end sub
		Public Sub InsertAfter(ByVal Item, ByVal index)
			Dim i
			Count = Count + 1
'Dim i
			ReDim preserve Items(Count)
			For i=(count-1) To (index*1+1) Step -1
'ReDim preserve Items(Count)
				If IsObject(items(i)) Then
					Set items(i+1) = items(i)
'If IsObject(items(i)) Then
				else
					items(i+1) = items(i)
'If IsObject(items(i)) Then
				end if
			next
			If isobject(Item) Then
				Set Items(index+1) = Item
'If isobject(Item) Then
			else
				Items(index+1) = Item
'If isobject(Item) Then
			end if
		end sub
		Public Sub ReMove(index)
			Dim i
			For I=index + 1 To Count
'Dim i
				If IsObject(items(i)) Then
					Set items(i-1) = items(i)
'If IsObject(items(i)) Then
				else
					items(i-1) = items(i)
'If IsObject(items(i)) Then
				end if
			next
			count = count - 1
'If IsObject(items(i)) Then
			ReDim preserve items(count)
		end sub
	End Class
	Class PowerClass
		Public Function CheckPower(byval sort1, byval sort2, byval CreatorID)
			Select Case sort1
			Case 5: If ZBRuntime.mc(7000) = False Then  CheckPower = False : Exit Function
			Case 3: If ZBRuntime.mc(3000) = False Then  CheckPower = False : Exit function
			End select
			Dim sql_qx,qx_type,qx_open,qx_intro
			sql_qx="select isnull(sort,0) as sort from qxlblist where sort1=" & sort1 & " and sort2="& sort2
			set rs_qx=cn.execute(sql_qx)
			if not rs_qx.eof then
				qx_type=rs_qx(0)
			else
				qx_type=0
			end if
			rs_qx.close
			set rs_qx=nothing
			if qx_type<>0 then
				sql_qx="select isnull(qx_open,0) as qx_open,isnull(qx_intro,'') as qx_intro from [power] where sort1=" & sort1 & " and sort2="&sort2&" and ord=" & app.info.user
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
				If Len(CreatorID & "") = 0 Then CreatorID = 0
				if qx_open=qx_type or (qx_open=1 and CheckIntro(qx_intro,cstr(CreatorID))>0) then
					CheckPower=true
				else
					CheckPower=false
				end if
			else
				CheckPower=false
			end if
		end function
		Public Function ExistsPower(byval sort1,byval sort2)
			Select Case sort1
			Case 5:  If ZBRuntime.mc(7000) = False Then  ExistsPower = False : Exit Function
			Case 3:  If ZBRuntime.mc(3000) = False Then  ExistsPower = False : Exit function
			End select
			sql = "select top 1 1 from [power] a inner join qxlblist b on a.sort1 = b.sort1 and a.sort2 = b.sort2 where a.ord=" & app.info.user & " and a.sort1=" & sort1 & " and a.sort2=" & sort2 & " and (a.qx_open = 1 or (a.qx_open=3 and b.sort<>1)) "
			ExistsPower = not cn.execute(sql).eof
		end function
		function CheckIntro(str1,str2)
			CheckIntro = instr(","&replace(str1 & ""," ","")&",",","&replace(str2 & ""," ","")&",")
		end function
		Public Function CanAdd(qx_sort)
			CanAdd = CheckPower(qx_sort,13,0)
		end function
		Public Function CanChange(qx_sort,creator)
			CanChange = CheckPower(qx_sort,21,creator)
		end function
		Public Function CanModify (qx_sort,creator)
			CanModify  = CheckPower(qx_sort,2,creator)
		end function
		Public Function CanRead(byval qx_sort,byval creator)
			Dim orderid
			orderid = request.querystring("orderid")
			Select Case orderid
			Case 1023, 1027
			CanRead = CheckPower(qx_sort,14,creator)
			Case Else
			Select Case qx_sort
			Case 5:  If ZBRuntime.mc(7000) = False Then  CanRead = False : Exit Function
			Case 3:  If ZBRuntime.mc(3000) = False Then  CanRead = False : Exit function
			End select
			If CheckPower(qx_sort,1,creator) Then
				CanRead = CheckPower(qx_sort,14,creator)
			else
				CanRead = False
			end if
			End Select
		end function
		Public Function CanDelete(qx_sort,creator)
			CanDelete = CheckPower(qx_sort,3,creator)
		end function
		Public Function CanApproval(qx_sort,creator)
			CanApproval =  CheckPower(qx_sort,16,creator)
		end function
		Public Function CanConfig(qx_sort)
			CanConfig  =  CheckPower(qx_sort,12,0)
		end function
		Public Function CanPrint(qx_sort,creator)
			CanPrint     =       CheckPower(qx_sort,7,creator)
		end function
		Public Function CanCopy (qx_sort,creator)
			CanCopy      =       CheckPower(qx_sort,8,creator)
		end function
		Public Function CanReply(byval qx_sort,byval creator)
			CanReply = CheckPower(qx_sort,5,creator)
		end function
		Public Function GetBillQXID(orderId)
			dim rs
			if len(orderId) = 0 then GetBillQXID = 0 : exit function
			set rs = cn.execute("select qxlb from M_OrderSettings where id=" & orderId)
			if rs.eof then
				GetBillQXID = 0
			else
				GetBillQXID = rs.fields(0).value
			end if
			rs.close
		end function
		public function CanReadBill(byval oid ,byval id)
			dim rs , qx , tb ,ky , creator
			set rs = cn.execute("select qxlb,MainTable,PKColumn from M_OrderSettings where id=" & oid)
			if rs.eof then
				canreadbill = false
				rs.close
				exit function
			else
				qx = rs.fields(0).value
				tb = rs.fields(1).value
				ky = rs.fields(2).value
			end if
			rs.close
			if len(id) = 0 then id = 0
			if not isnumeric(id) then id = 0
			set rs = cn.execute("select creator from " & tb & " where " & ky & " = " & id)
			if rs.eof then
				canreadbill = false
				rs.close
				exit function
			else
				creator = rs.fields(0).value
			end if
			rs.close
			CanReadBill = CanRead(qx,creator)
		end function
		public function CanReplyBill(byval oid ,byval id)
			dim rs , qx , tb ,ky , creator
			set rs = cn.execute("select top 1 qxlb,MainTable,PKColumn from M_OrderSettings where id=" & oid)
			if rs.eof then
				CanReply = false
				rs.close
				exit function
			else
				qx = rs.fields(0).value
				tb = rs.fields(1).value
				ky = rs.fields(2).value
			end if
			rs.close
			if len(id) = 0 then id = 0
			if not isnumeric(id) then id = 0
			set rs = cn.execute("select top 1 creator from " & tb & " where " & ky & " = " & id)
			if rs.eof then
				CanReplybill = false
				rs.close
				exit function
			else
				creator = rs.fields(0).value
			end if
			rs.close
			CanReplyBill = CanReply(qx,creator)
		end function
		public function GetPowerIntro(byval s1, byval s2)
			dim sql ,r , rs
			sql = "select case a.qx_open when 3 then '' when 1 then qx_intro else '-222' end from power a where a.sort1 = " & s1 & " and a.sort2 = " & s2 & " and ord=" & app.info.user
'dim sql ,r , rs
			set rs = cn.execute(sql)
			if not rs.eof then
				r = rs.fields(0).value
				if len(r) > 0 then
					r =  replace("" & r & ""," ","")
					while instr(r,",,") > 0
						r = replace(r,",,",",")
					wend
					r = replace(replace(replace("x" & r & "x","x,",""),",x",""),"x","")
				end if
				GetPowerIntro = r
			else
				GetPowerIntro = "-222"
				GetPowerIntro = r
			end if
			rs.close
			set rs = nothing
		end function
		End  Class
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
		Dim cn
		response.expires=-1
'Dim cn
		Public ZBRuntime, M_SDK
		Set M_SDK = nothing
		set ZBRuntime = server.createobject(ZBRLibDLLNameSN & ".Library")
		ZBRuntime.loadok
		Class InitSDKClass
			Public conn
			Public ZBRuntime
			Public Function GetSDK
				Set GetSDK = Server.createobject(ZBRLibDLLNameSN & ".CommClass")
				GetSDK.init me
			end function
		End Class
		Public Function SDK
			If M_SDK Is Nothing Then
				Dim obj : Set obj = New InitSDKClass
				Set obj.conn = cn
				Set obj.ZBRuntime = ZBRuntime
				Set M_SDK = obj.getsdk
				Set obj = nothing
			end if
			Set SDK = M_SDK
		end function
		Class Page
			Public autoHead
			Public execMode
			Public controls
			Public eventname
			Public Power
			Public Base64
			Public svrIP
			Public cltIP
			Public db
			Private mIsLocal
			Public IsIE
			public vPath
			Private mInfo
			Public Property Get Info
			If mInfo Is Nothing Then
				Set mInfo = new AppInfo
			end if
			Set Info = mInfo
			End Property
			Public Function ExistsModel(byval str)
				ExistsModel=ZBRuntime.MC(str)
			end function
			Private mRegTempTable
			Public Sub RegTempTable(tbname)
				mRegTempTable = tbname
			end sub
			Private Function  GetCurrPath
				dim fso
				set fso = server.createObject("Scripting.FileSystemObject")
				if fso.FileExists(server.mappath("../serverlooks.asp")) then
					GetCurrPath = "../"
					set fso =  nothing
					exit function
				end if
				if fso.FileExists(server.mappath("../../serverlooks.asp")) then
					GetCurrPath = "../../"
					set fso =  nothing
					exit function
				end if
				if fso.FileExists(server.mappath("../../../serverlooks.asp")) then
					GetCurrPath = "../../../"
					set fso =  nothing
					exit function
				end if
				if fso.FileExists(server.mappath("serverlooks.asp")) then
					GetCurrPath = ""
					set fso =  nothing
					exit function
				end if
				if fso.FileExists(server.mappath("../../../../serverlooks.asp")) then
					GetCurrPath = "../../../../"
					set fso =  nothing
					exit function
				end if
				set fso  = nothing
				GetCurrPath = ""
			end function
			public property get AbsPath
			AbsPath = GetCurrPath
			end property
			function operationsystem()
				dim agent
				agent = Request.ServerVariables("HTTP_USER_AGENT")
				if Instr(agent,"NT 5.2")>0 then
					SystemVer="Windows Server 2003"
				elseif Instr(agent,"NT 5.1")>0 then
					SystemVer="Windows XP"
				elseif Instr(agent,"NT 5.0")>0 then
					SystemVer="Windows 2000"
				elseif Instr(agent,"NT 4.0")>0 or Instr(agent,"NT 3.1")>0 or Instr(agent,"NT 3.5")>0 or Instr(agent,"NT 3.51 ")>0 then
					SystemVer="老版本Windows NT4"
				elseif Instr(agent,"4.9")>0 then
					SystemVer="Windows ME"
				elseif Instr(agent,"98")>0 then
					SystemVer="Windows 98"
				elseif Instr(agent,"95")>0 then
					SystemVer="Windows 95"
				elseif Instr(agent,"Vista")>0 then
					SystemVer="Windows Vista"
				elseif Instr(agent,"Windows 7")>0 then
					SystemVer="Windows 7"
				elseif Instr(agent,"Windows 8")>0 then
					SystemVer="Windows 8"
				elseif Instr(agent,"Server 2008 R2")>0 then
					SystemVer="Windows Server 2008 R2"
				elseif Instr(agent,"Server 2008")>0 then
					SystemVer="Windows Server 2008"
				elseif Instr(agent,"Server 2010")>0 then
					SystemVer="Windows Server 2010"
				elseif Instr(agent,"NT 6.2")>0 then
					SystemVer="Windows Slate"
				elseif Instr(agent,"CE")>0 then
					SystemVer="Windows CE"
				elseif Instr(agent,"PE")>0 then
					SystemVer="Windows PE"
				else
					SystemVer=""
				end if
				operationsystem=SystemVer
			end function
			function browser()
				dim agent
				agent = Request.ServerVariables("HTTP_USER_AGENT")
				if Instr(agent,"MSIE 6.0")>0 then
					browserVer="Internet Explorer 6.0"
				elseif Instr(agent,"MSIE 5.5")>0 then
					browserVer="Internet Explorer 5.5"
				elseif Instr(agent,"MSIE 5.01")>0 then
					browserVer="Internet Explorer 5.01"
				elseif Instr(agent,"MSIE 5.0")>0 then
					browserVer="Internet Explorer 5.00"
				elseif Instr(agent,"MSIE 4.0")>0 then
					browserVer="Internet Explorer 4.0"
				elseif Instr(agent,"TencentTraveler")>0 then
					browserVer="腾讯 TT"
				elseif Instr(agent,"Firefox")>0 then
					browserVer="Firefox"
				elseif Instr(agent,"Opera")>0 then
					browserVer="Opera"
				elseif Instr(agent,"Wap")>0 then
					browserVer="Wap浏览器"
				elseif Instr(agent,"Maxthon")>0 then
					browserVer="Maxthon"
				elseif Instr(agent,"MSIE 7.0")>0 then
					browserVer="Internet Explorer 7.0"
				elseif Instr(agent,"MSIE 8.0")>0 then
					browserVer="Internet Explorer 8.0"
				else
					browserVer=""
				end if
				browser=browserVer
			end function
			public Function GetUrl()
				Dim ScriptAddress,Servername,qs
				If Len(Request.form)>0 Then
					GetUrl = ""
					Exit Function
				end if
				ScriptAddress = CStr(Request.ServerVariables("SCRIPT_NAME"))
				Servername = CStr(Request.ServerVariables("Server_Name"))
				qs=Request.QueryString
				if qs<>"" then
					GetUrl = ScriptAddress &"?"&qs
				else
					GetUrl = ScriptAddress
				end if
			end function
			public sub add_log(args,action1)
				on error resume next
				call sdk.setup.add_logs(application, session, request, server, args, action1)
			end sub
			public Function GetFloderPath(fso, path, childpath)
				Dim fd
				If fso.FolderExists(path & "\" & childpath) Then
					GetFloderPath = path & "\" & childpath
				else
					For Each fd In fso.GetFolder(path).SubFolders
						GetFloderPath = GetFloderPath(fso, fd.path, childpath)
						If Len(GetFloderPath) > 0 Then
							Exit Function
						end if
					next
					GetFloderPath = ""
				end if
			end function
			Public Sub ClearDB
				on error resume next
				If Len(mRegTempTable) > 0 Then
					cn.execute "drop table " & mRegTempTable
					mRegTempTable = ""
				end if
				cn.close()
				Set cn = Nothing
				Set db = nothing
			end sub
			public property Get IsAdmin
			isAdmin = (cstr(session("top1zbintel2007") & "") = "1")
			end Property
			Public Property Get IsLocal()
			IsLocal =  mIsLocal
			End Property
			Private Sub IPHand
				clt = Request.ServerVariables("Remote_Addr")
				svr = Request.ServerVariables("Local_Addr")
				mIsLocal  = (svr = svr)
			end sub
			Private Sub IETest
				exit sub
				If InStr(Request.ServerVariables("HTTP_USER_AGENT")," MSIE ") = 0 and request.querystring("MustIE") <> "0" Then
					IsIE = false
					app.showerr "系统运行环境要求" ,"<div class=full style='text-align:left;color:#444;font-family:arial'><br><br>系统暂时只支持IE内核系列浏览器（如IE6+、360、遨游、QQ、搜狗等）。<br><br>推荐使用 <b>Internet Explorer 8</b>&nbsp;<a href='http://www.skycn.com/soft/30276.html' target=_blank style='color:blue' title='参考下载地址：天空下载'>下载IE8</a><br><br><span style='color:#aaa'>对于部分国产多核浏览器(如搜狗、腾讯、360)，如果在高速或极速模式下运行出现本次提示，请启用兼容性模式浏览</span></div>"
					call db_close : Response.end
				end if
			end sub
			Private Sub init(isFile)
				IsIE = true
				Call IPHand
				Set db = new DBCommand
				Set cn = db.getConnection()
				Call checkSuperDog(cn, "../../",False)
				Set controls = new collection
				Set base64 = new  Base64Class
				db.getConnection()
				Set Power= new PowerClass
				autoHead = True
				if not isFile Then
					on error resume next
					execMode = Len(request.Form("__execMode") & "") > 0
					If Err.number = &h80004005 Then
						Response.write "由于提交的单据数据量大小超出了IIS的允许范围，所以系统拒绝了您的本次会话请求，如有疑问请联系服务器管理员。 <br>(注：一般IIS有200K的数据提交限制。)"
						Call db_close : Response.end
					end if
				else
					execMode = false
				end if
			end sub
			Public Function ConverProcductDefSql(ByVal sql)
				ConverProcductDefSql = ConverProcductDefSqlCore(sql, 0)
			end function
			Public Function ConverProcductDefSqlCore(ByVal sql, ByVal typ)
				Dim sql2, c1, c3, rs
				If InStr(sql,"@ProductDefFields") > 0 Then
					c1 = InStr(sql,"@ProductDefFields")
					sql2 = Right(sql, Len(sql)-c1+1)
'c1 = InStr(sql,"@ProductDefFields")
					c3 = Replace(Replace(Left(sql2, InStr(sql2,"]")),"@ProductDefFields[","",1,-1,1),"]","")
'c1 = InStr(sql,"@ProductDefFields")
					If typ = 0 then
						Set rs = cn.execute("select dbo.erp_getProductZDYFields('" & c3 & ".')")
					else
						Set rs = cn.execute("select dbo.erp_getProductZDYFields_core('" & c3 & ".'," & typ & ")")
					end if
					sql2 = rs.fields(0).value
					rs.close
					If Left(sql2,1)="," Then
						sql2 =  Right(sql2,Len(sql2)-1)
'If Left(sql2,1)="," Then
					end if
					If Len(sql2) > 0 then
						sql = Replace(sql,"@ProductDefFields[" & c3 & "]", sql2)
					else
						sql = Replace(sql,",@ProductDefFields[" & c3 & "]", "")
						sql = Replace(sql,"@ProductDefFields[" & c3 & "],", "")
					end if
				end if
				ConverProcductDefSqlCore = sql
			end function
			Public Sub printl(str)
				Response.write str & vbcrlf
			end sub
			Public Sub print(ByVal data)
				Dim l, i, spcount
				l = Len(data)
				spcount = 3000000
				If l < spcount Then
					Response.write data
				else
					For i = 1 To int(l/spcount)
						response.flush
						Response.write Mid(data, (i-1)*spcount+1 , spcount)
						response.flush
					next
					i = l Mod spcount
					If i > 0 Then
						response.flush
						Response.write right(data, i)
					end if
				end if
			end sub
			public function StrLen(v)
				dim i , StrLenV , ac
				StrLenV = len(v)
				for i = 1 to  StrLenV
					ac = asc(mid(v,i,1))
					if ac > 256 or ac < 0 then
						StrLen = StrLen +  0
'if ac > 256 or ac < 0 then
					end if
				next
				StrLen = StrLen + StrLenV
'if ac > 256 or ac < 0 then
			end function
			Public Sub run()
				Dim msgId , isFile
				session("sys_userlastvistime") = now
				isFile = request.querystring("__isfileupload") = "1"
				call init(isFile)
				msgId = request.querystring("__msgId") & ""
				if len(msgId) = 0 then
					msgId = request.form("__msgId") & ""
				end if
				if instr(lcase(server.mappath("a")),"\manufacture\inc") > 0 then
					vpath = "../inc/"
				end if
				Call SDK()
				If isSub("Page_Init") Then Call Page_Init()
				If Len(msgId) = 0 Then
					If autoHead Then print HeadHTML()
					Call IETest
					If isSub("Page_Load") Then
						Call Page_load()
					end if
					If autoHead Then print BottomHTML()
				else
					app.eventname = msgId
					If isSub("App_"  &  msgId ) Then
						Execute "call App_" &  msgId & "()"
					else
						If execMode Then
							print "alert('Exception Code - 0x00001\n\nThe process is not defined. ');"
'If execMode Then
						else
							print "Exception Code - 0x00001\n\nThe process is not defined."
'If execMode Then
						end if
					end if
				end if
				Call ClearDB()
			end sub
			Public Function isSub(subName)
				on error resume next
				Call TypeName(getref(subName))
				isSub = (Len(Err.description)=0)
			end function
			Public Function BottomHTML()
				BottomHTML = vbcrlf & "<script language=javascript>if(window.initevents){initevents.exec();}</script></html>"
			end function
			Public Function HeadHTML()
				if len(vPath) = 0 then vPath = me.AbsPath & "manufacture/inc/"
				Dim html , brand
				html = "<!DOCTYPE html>" & vbcrlf & "<html xmlns=""http://www.w3.org/1999/xhtml"">"
				html = html & vbcrlf & "   <head>"
				html = html & vbcrlf & "           <meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">"
'html = html & vbcrlf & "   <head>"
				html = html & vbcrlf & "           <meta http-equiv=""X-UA-Compatible"" content=""IE=EmulateIE7"" />"
'html = html & vbcrlf & "   <head>"
				html = html & vbcrlf & "           <title>" & Info.title & "</title>"
				brand = ""
				if (application("sys.info.configindex") & "") = "3" then  brand = ".mozi"
				if me.isIE then
					html = html & vbcrlf & "           <link href=""" & vPath & "comm" & brand & ".css"" rel=""stylesheet"" type=""text/css""/>"
				else
					html = html & vbcrlf & "           <link href=""" & vPath & "Standard" & brand & ".css"" rel=""stylesheet"" type=""text/css""/>"
				end if
				Dim uizoom : uizoom = CSng("0" & SDK.Attributes("uizoom"))
				If uizoom >1 Then
					html = html & vbcrlf & "           <script>if(top==window){document.write('<style>body{position:relative;zoom:" & uizoom & "}</style>')}</script>"
				end if
				html = html & vbcrlf & "           <script language=javascript src='../../inc/jQuery-1.6.2.min.js'></script>"
				html = html & vbcrlf & "           <script language=javascript src='" & vPath & "base.js?ver="& Application("sys.info.jsver") &"'></script>"
				html = html & vbcrlf & "           <script language=javascript src='../../inc/jQuery-autobh.js'></script>"
				if len(vPath) > 0 then html = html & vbcrlf & "            <script language=javascript>window.sys_verPath=""" & lcase(vPath) & """;window.floatnumber=" & app.info.floatnumber & ";window.MoneyNumber=" & app.info.MoneyNumber &";window.StorePriceNumber=" &app.info.StorePriceNumber&";</script>"
				If IsSub("Page_OnHead") Then
					html = html  &  Page_Onhead
				end if
				html = html & vbcrlf & "   </head>"
				HeadHTML = html
			end function
			Public Sub alert(msg)
				msg = msg & ""
				app.print "window.alert(""" & Replace(Replace(msg,"""","\"""),vbcrlf,"\n") & """);"
			end sub
			Public Sub ClientRefresh()
				app.print "window.location.href = window.location.href;"
			end sub
			Public Sub confirm(msg)
				app.print "window.confirm(""" & Replace(Replace(msg,"""","\"""),"\n") & """);"
			end sub
			Public Function IIF(bool,v1,v2)
				If Not IsNumeric(bool) Then bool = false
				If bool Then
					IIF = v1
				else
					IIF = v2
				end if
			end function
			Function GetDataRecord(rs)
				Dim I , s
				on error resume next
				Set GetDataRecord = rs
				s = rs.Source
				While GetDataRecord.fields.count = 0 And I <10000
					Set GetDataRecord = GetDataRecord.NextRecordset
					If abs(Err.number) > 0 then
						app.showerr "数据逻辑错误","当前数据源没有数据集返回,即NextRecordset不存在" & iif(info.debugmode, "<br><br>& 源:" &  s ,"")
						cn.close
						call db_close : Response.end
					end if
					i = i + 1
					call db_close : Response.end
				wend
			end function
			Public Function  AddStrArrayItem(ByRef Arrays , ByVal Str ,ByVal  Repeat)
				Dim lStr , i , ii
				If Not IsArray(Arrays) Then
					ReDim Arrays(0)
				end if
				i = UBound(Arrays)
				lStr = RTrim(Str)
				If Not Repeat Then
					For ii = 1 To UBound(Arrays)
						If Arrays(ii) = lStr Then
							AddStrArrayItem = False
							Exit Function
						end if
					next
				end if
				ReDim preserve Arrays(i + 1)
				Exit Function
				Arrays(i + 1) = lStr
				Exit Function
				AddStrArrayItem = true
			end function
			Function GetDBField(rs,fname)
				on error resume next
				GetDBField = rs.fields(fname).value
				If abs(Err.number) > 0 Then
					ShowErr "提取数据字段失败。","您使用的数据库字段[<span class=c_r>" & fname & "</span>]不存在。"
					cn.close
					call db_close : Response.end
				end if
			end function
			Function GetRecord(cn,sql)
				on error resume next
				sql = SqlExtension(sql)
				Set GetRecord = cn.execute(sql)
				If abs(Err.number)> 0 Then
					Response.write "<link href='comm.css' rel='stylesheet' type='text/css'/>"
					ShowErr "提取数据源失败。" , "<br><span class=c_r>您使用的以下SQL查询语句错误</span><br><br><span class=c_g>" & sql & "</span><br><br>错误描述:<br>&nbsp;&nbsp;<span class=c_r>" & err.Description & "</span>"
					cn.close
					call db_close : Response.end
				end if
			end function
			Public Sub ShowErr (title,Body)
				Dim width , height
				title = replace(title,":"," ")
				title = replace(title,"："," ")
				width  = 520 : height = 220
				response.clear
				Response.write app.headhtml
				Response.write "" & vbcrlf & "             <div class='DisDivBgCss' id=""divdlg_ErrBox_bg""></div>" & vbcrlf & "             <div style = ""z-index:4000;position:absolute;width:"
				Response.write app.headhtml
				Response.write width
				Response.write "px;height:"
				Response.write height
				Response.write "px;top:100px;left:100px;"" id=""divdlg_ErrBox"">" & vbcrlf & "               <table onselectstart='return false' style='width:"
				Response.write width-4
				Response.write "px;height:"
				Response.write height-7
				Response.write "px;height:"
				Response.write "px;' class='divForm' style='border:1px solid #777786'>" & vbcrlf & "               <tr style='cursor:move' onmousedown='window.onmovediv=this.parentElement.parentElement.parentElement'>" & vbcrlf & "                  <td style='width:"
				Response.write width-40
				Response.write "px;text-align:left;height:22px;padding:2px;padding-left:5px;'><b style='color:#0000aa'>警告：</b></td> " & vbcrlf & "                      <td style='text-align:right;;width:42px;cursor:default;'>" & vbcrlf & "                               <b style='font-family:Webdings' title='关闭' onmouseover='this.style.color=""red""' onmouseout='this.style.color=""#000""' onclick='errdlgClose()'>"
				Response.write app.iif(app.IsIE,"r","")
				Response.write "</b>&nbsp;&nbsp;" & vbcrlf & "                     </td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td colspan=2 style='padding:7px;height:"
				Response.write height-44
				Response.write "px' valign=top>" & vbcrlf & "                              <div class='divdlgBody' style='width:"
				Response.write width-30
				Response.write "px' valign=top>" & vbcrlf & "                              <div class='divdlgBody' style='width:"
				Response.write "px;height:"
				Response.write height-58
				Response.write "px;height:"
				Response.write "px;overflow:auto;padding:4px;text-align:center;'>" & vbcrlf & "                                    <table style='width:"
				Response.write "px;height:"
				Response.write width-50
				Response.write "px;height:"
				Response.write "px' align=center>" & vbcrlf & "                                            <tr>" & vbcrlf & "                                                    <td style='height:120px;width:10%;padding:10px' valign='top'><img src='../../images/smico/BWarning.gif'></td>" & vbcrlf & "                                                   <td style='padding-right:10px;display:block;text-align:left;color:#777' onselectstart='window.event.cancelBubble=true;return true;' valign='top'>" & vbcrlf & "                                                         <br>" & vbcrlf & "                                                            "
				Response.write title
				Response.write "(<a href='javascript:void(0)' style='color:blue' onclick='document.getElementById(""sdsdffc"").style.display=document.getElementById(""sdsdffc"").style.display==""block""?""none"":""block""'>详情</a>)" & vbcrlf & "                                                         <br><br><div style='border:1px dashed #ddd;background-color:white;padding:5px;display:none;height:90px;overflow:auto' id=""sdsdffc"">"
				Response.write body
				Response.write "</div>" & vbcrlf & "                                                 </td>" & vbcrlf & "                                           </tr>" & vbcrlf & "                                   </table>" & vbcrlf & "                                </div>" & vbcrlf & "                  </td>" & vbcrlf & "           </tr>" & vbcrlf & "           </table>" & vbcrlf & "                </div>" & vbcrlf & "          <script language=javascript>" & vbcrlf & "                    document.body.style.cssText = ""overflow:hidden;""" & vbcrlf & "                      var win = document.getElementById(""divdlg_ErrBox"");" & vbcrlf & "                       var w = document.children[1].offsetWidth;" & vbcrlf & "                       if(isNaN(w) || w == 0){" & vbcrlf & "                         w = screen.availWidth" & vbcrlf & "                   }" & vbcrlf & "                       win.style.left = ((w-"
				Response.write width
				Response.write ")/2) + ""px"";" & vbcrlf & "                     function errdlgClose(){" & vbcrlf & "                         document.getElementById(""divdlg_ErrBox_bg"").style.display = ""none"";" & vbcrlf & "                         document.getElementById(""divdlg_ErrBox"").style.display = ""none"";" & vbcrlf & "                            var inputs = document.getElementsByTagName(""button"")" & vbcrlf & "                             for (var i=0;i<inputs.length;i++)" & vbcrlf & "                               {inputs[i].disabled = true;}" & vbcrlf & "                            var inputs = document.getElementsByTagName(""input"")" & vbcrlf & "                               for (var i=0;i<inputs.length;i++)" & vbcrlf & "                               {inputs[i].disabled = true;}" & vbcrlf & "                    }" & vbcrlf& "         </script>" & vbcrlf & "               "
				on error resume next
				cn.close
				Set cn = nothing
				call db_close : Response.end
			end sub
			Public Function LenC(str)
				Dim n , StrLen
				StrLen = 0
				For n = 1 To Len(str)
					If abs(Ascw(Mid(str, n, 1))) >256 Then
						StrLen = StrLen + 2
'If abs(Ascw(Mid(str, n, 1))) >256 Then
					else
						StrLen = StrLen + 1
'If abs(Ascw(Mid(str, n, 1))) >256 Then
					end if
				next
				LenC = strLen
			end function
			Public Function TryExecute(sql)
				on error resume next
				cn.execute SqlExtension(sql)
				If abs(Err.number) > 0 Then
					If execMode Then
						Dim errText
						errText = "数据库存储失败，请联系系统管理人员。\n\n错误原因： Sql语法错误 。"
						If isLocal Then
							errText = errText & "\n\nSql源:" & sql
						end if
						alert errText
					end if
					call db_close : Response.end
				end if
			end function
			Public Function GetArrayItem(datArray,itemValue)
				itemValue = LCase(itemValue)
				GetArrayItem = -1
				itemValue = LCase(itemValue)
				If IsArray(datArray) Then
					For i = 0 To UBound(datArray)
						If LCase(datArray(i)) = itemValue Then
							GetArrayItem = i
							Exit Function
						end if
					next
				end if
			end function
			Public Function dbFilter(PostStr)
				dbFilter = Replace(PostStr & "","'","")
			end function
			Public Function SqlExtension(ByVal sql)
				on error resume next
				Dim osql , oc
				osql = sql
				sql = handlePowerVar(sql)
				If InStr(sql,"@asp.")>0 Then
					Dim rg, m, c , v
					Set rg =  New RegExp
					rg.Global = True
					rg.MultiLine = True
					rg.IgnoreCase = True
					If InStr(sql,"@asp.eval")>0 Then
						rg.Pattern = "\@asp.eval\[[^\]]*\]"
						Set r = rg.Execute(sql)
						For i = 0 To r.Count - 1
'Set r = rg.Execute(sql)
							m = r(i).Value
							c = Replace(Replace(Replace(Replace(m, "@asp.eval[", "", 1,-1, 1), "]", ""), "【", "["), "】", "]")
							'm = r(i).Value
							oc = c
							v = eval(c)
							If IsNumeric(v) And Len(v) > 0 Then
								sql = Replace(sql,m,v)
							else
								sql = Replace(sql,m ,"'" & v & "'")
							end if
						next
					end if
					If InStr(sql,"@asp.form")>0 Then
						rg.Pattern = "\@asp.form\[[^\]]*\]"
						Set r = rg.Execute(sql)
						For i = 0 To r.Count - 1
							Set r = rg.Execute(sql)
							m = r(i).Value
							c = Replace(Replace(Replace(Replace(m, "@asp.form[", "",1,-1, 1), "]", ""), "【", "["), "】", "]")
							'm = r(i).Value
							v = request.form(c)
							If IsNumeric(v) And Len(v) > 0 Then
								sql = Replace(sql,m,v)
							else
								sql = Replace(sql,m ,"'" & v & "'")
							end if
						next
					end if
					If InStr(sql,"@asp.querystring")>0 Then
						rg.Pattern = "\@asp.querystring\[[^\]]*\]"
						Set r = rg.Execute(sql)
						For i = 0 To r.Count - 1
							Set r = rg.Execute(sql)
							m = r(i).Value
							c = Replace(Replace(Replace(Replace(m, "@asp.querystring[", "",1,-1, 1), "]", ""), "【", "["), "】", "]")
							'm = r(i).Value
							v = request.querystring(c)
							If IsNumeric(v) And Len(v) > 0 Then
								sql = Replace(sql,m,v)
							else
								sql = Replace(sql,m, "'" & v & "'")
							end if
						next
					end if
					Set rg = Nothing
				end if
				sql = replace(sql,"@uid",app.info.user)
				SqlExtension = sql
				If abs(Err.number) > 0 Then
					showerr "sql扩展语法错误" , "sql源:<br>" & osql  & "<br><br>错误描述:<span class=c_r>" & err.Description  & "</span><br><br>" & iif(Len(oc)>0,"错误代码:" & oc , "")
					call db_close : Response.end
				end if
			end function
			Public Function CNum(v)
				If not IsNumeric(v) Or Len(v) = 0 Then
					cNum = 0
				else
					cNum = v
				end if
			end function
			Public Function formatNum(byval v)
				if isnumeric(v) then
					if instr(v,".") > 0 then
						v = formatnumber(v,app.info.FloatNumber,-1)*1
'if instr(v,".") > 0 then
						if abs(v) < 1 then
							if left(cstr(v),1) = "." then
								v = 0 & v
							end if
						end if
					end if
					formatNum = replace(v,",","")
				else
					formatNum = v
				end if
			end function
			Public Sub ShowYellowAlert(msg)
				Response.write "<div style='padding:10px;border:1px solid #cccc88;background-color:#ffffcc;top:20px;width:80%;left:10%;z-index:1200;position:absolute;height:40px;font-size:12px'><div style='float:right;margin-top:-5px;'><span style='cursor:default' onmouseover='this.style.color=""blue"";this.style.textDecoration=""underline""' onmouseout='this.style.color=""#000"";this.style.textDecoration=""none""' onclick='this.parentElement.parentElement.style.display=""none""'>关闭</span></div>" & msg & "</div>"
			end sub
			public function Form(fName)
				dim v
				v = request.form(fname)
				form = replace(v,"'","")
			end function
			Private Sub Class_Initialize()
				Set minfo =  nothing
			end sub
			Private Sub Class_Terminate()
				Dim mdb, mcn
				If Len(mRegTempTable) > 0 Then
					On  Error Resume next
					Set mdb = new DBCommand
					Set mcn = mdb.getConnection()
					mcn.execute "drop table " & mRegTempTable
					mRegTempTable = ""
					mcn.close
				end if
				Set mInfo = nothing
			end sub
			Function handlePowerVar(ByVal sql)
				Dim p1, p2, sqll, isql, sar , rs
				p1 = InStr(1,sql,"@PowerIntro_",1)
				If p1 = 0 Then handlePowerVar = sql : Exit Function
				p2 = InStr(p1,sql,",",1)
				If p2 = 0 Then      p2 = InStr(p1,sql," ",1)
				If p2 = 0 Then      p2 = InStr(p1,sql,"(",1)
				If p2 = 0 Then      p2 = InStr(p1,sql,")",1)
				If p2 = 0 Then      p2 = InStr(p1,sql,"=",1)
				If p2 = 0 Then      p2 = InStr(p1,sql,"+",1)
'If p2 = 0 Then      p2 = InStr(p1,sql,"=",1)
'If p2 = 0 Then      p2 = InStr(p1,sql,"+",1)
'If p2 = 0 Then      p2 = InStr(p1,sql,"=",1)
				sqll = Len(sql)
				If p2 < p1 Then
					isql = Right(sql, sqll-p1)
'If p2 < p1 Then
				else
					isql = Mid(sql, p1, p2-p1)
'If p2 < p1 Then
				end if
				sar = Split(isql, "_")
				If ubound(sar) = 2 Then
					Set rs = cn.execute("select case qx_open when 3 then '' when 1 then qx_intro else '0' end as r from power a where a.sort1=" & sar(1) & " and a.sort2=" & sar(2) & " and ord=" & app.Info.user)
					If rs.eof = False then
						sql = Replace(sql, isql, "'" & Replace(rs.fields(0).value & ""," ","") & "'",1,-1,1)
'If rs.eof = False then
					else
						sql = Replace(sql, isql, "'0'",1,-1,1)
'If rs.eof = False then
					end if
					rs.close
				else
					sql = Replace(sql, isql, "''")
				end if
				If InStr(1,sql,"@PowerIntro_",1) > 0 Then
					sql = handlePowerVar(sql)
				end if
				handlePowerVar = sql
			end function
		End Class
		Public Function getIP()
			Dim strIPAddr
			If Request.ServerVariables("HTTP_X_FORWARDED_FOR") = "" OR InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), "unknown") > 0 Then
				strIPAddr = Request.ServerVariables("REMOTE_ADDR")
			ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ",") > 0 Then
				strIPAddr = Mid(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), 1, InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ",")-1)
'ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ",") > 0 Then
			ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ";") > 0 Then
				strIPAddr = Mid(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), 1, InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ";")-1)
'ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ";") > 0 Then
			else
				strIPAddr = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
			end if
			getIP = Trim(Mid(strIPAddr, 1, 30))
		end function
		Sub MsgBox(str)
			app.alert str
		end sub
		Sub App_sys_debug_getTextFile
			Response.Charset= "UTF-8"
'Sub App_sys_debug_getTextFile
			Call Response.AddHeader("content-type","text/plain")
'Sub App_sys_debug_getTextFile
			Call Response.AddHeader("Content-Disposition","attachment;filename=调试数据文件.txt")
'Sub App_sys_debug_getTextFile
			Call Response.AddHeader("Pragma","No-Cache")
'Sub App_sys_debug_getTextFile
			Response.write request.Form("sys_debug_body")
		end sub
		Sub db_close
			on error resume next
			If typename(cn) <> "Empty" And typename(cn) <> "Nothing" then
				cn.close
				Set cn = Nothing
			end if
		end sub
		Set app = new Page
		If app.Info.User > 0 Or Len(Request("__currUserId") & "") > 0 then
			app.run
		else
			'Response.write "" & vbcrlf & "//<!--" & vbcrlf & "window.location.href = ""../../index2.asp""" & vbcrlf & "//--><script>window.location.href = ""../../index2.asp""</script>" & vbcrlf & ""
			app.run
		end if
		app.ClearDB
		Set app = Nothing
		
		Const REC_PER_SHEET_IN_IMPORT_REPORT = 10000
		Const HOW_MANY_REC_TO_USE_EXCEL = 200
		Class OptionClass
			public name
			public options
			public count
			public selectIndex
			private mkey
			public  property let key(nv)
			dim v
			mkey = nv
			v = request.cookies("updoptindex" & nv)
			if  isnumeric(v) and len(v) > 0 then
				selectindex = v
			end if
			end property
			public  property get key()
			key = mkey
			end property
			public sub Class_Initialize
				count = -1
'public sub Class_Initialize
				selectIndex = 0
				redim options(0)
			end sub
			public sub Add(name,value)
				count = count + 1
'public sub Add(name,value)
				redim preserve options(count)
				options(count) = split(name & "#werlp%sd#" & value , "#werlp%sd#")
			end sub
		end Class
		class UpLoadAttrClass
			public title
			public filters
			public helpFilePath
			public smpFilePath
			public remark
			public fileName
			public autosave
			public allowSize
			public modelCls
			public optionItems
			public optionCount
			public arr_items
			public sub Class_Initialize
				optionCount = -1
'public sub Class_Initialize
				redim optionItems(0)
			end sub
			public function addOption
				optionCount = optionCount + 1
'public function addOption
				redim preserve optionItems(optionCount)
				set optionItems(optionCount) = new OptionClass
				set addOption = optionItems(optionCount)
			end function
		end class
		class UpLoadFileClass
			Public FileName
			public FilePath
			Public FileType
			Public ContentType
			private mFileSize
			public savefilename
			public baseCols
			public defColSort
			public defdbtable
			private hsReport
			public  uAttrs
			public ReportTables
			private ErrSign
			public disDelete
			public callurl
			Public tagData
			public property get FileSize
			FileSize = mFileSize
			end property
			public property get SavedPath
			SavedPath = savePath
			end property
			private savePath
			public sub RegRptItem(t, cls)
				dim i
				if isArray(ReportTables) then
					i = ubound(ReportTables) + 1
'if isArray(ReportTables) then
					redim preserve ReportTables(i)
					ReportTables(i) = t & "|||" & cls
				else
					redim ReportTables(0)
					ReportTables(0) = t & "|||" & cls
				end if
			end sub
			public function GetInfoByHead(byval htext)
				set rs = server.CreateObject("adodb.recordset")
				dim items , tms , v
				htext = replace(htext,chr(13),";")
				items = split(htext,";")
				for I = 0 to ubound(items)
					items(i) = trim(items(i))
					if instr(1,items(i),"filename=""",1) = 1 then
						FilePath = replace(replace(items(i),"filename=""","",1,-1,1),"""","")
'if instr(1,items(i),"filename=""",1) = 1 then
					end if
					if instr(1,items(i),"Content-Type:",1) > 0 then
'if instr(1,items(i),"filename=""",1) = 1 then
						ContentType = replace(replace(items(i),"Content-Type:","",1,-1,1),"""","")
'if instr(1,items(i),"filename=""",1) = 1 then
					end if
				next
				tms = split(FilePath,"\")
				if isarray(tms) then
					if ubound(tms) < 0 then
						showalert "请选择要上传的文件。"
						call db_close : Response.end
					end if
					FileName = tms(ubound(tms))
					tms = split(FileName,".")
					filetype = tms(ubound(tms))
				end if
				Randomize()
				v =  cstr(cint(rnd*1000))
				v = left("0000" , 4-len(v)) & v
				'v =  cstr(cint(rnd*1000))
				savefilename = left("000000",6-len(cstr(app.info.user))) &  App.info.user & left(replace(cstr(cdbl(now)),".","") & "0000",12)  & v & "." & FileType
				'v =  cstr(cint(rnd*1000))
			end function
			private function GetTextByBinText(binText)
				dim obj
				set obj = server.createobject(ZBRLibDLLNameSN & ".StreamClass")
				obj.type_ = 2
				obj.Open_
				obj.writetext binText
				obj.Position=0
				obj.type_ =2
				obj.Charset="UTF-8"
				obj.type_ =2
				GetTextByBinText = obj.readText
				obj.close_
				set obj = nothing
			end function
			private function GetByteArray(SoureBytes , startPos , num)
				dim obj
				set obj = server.createobject(ZBRLibDLLNameSN & ".StreamClass")
				obj.type_ = 1
				obj.Open_
				obj.write_ SoureBytes
				obj.Position=startPos
				GetByteArray = obj.read(num)
				obj.close_
				set obj = nothing
			end function
			private function deletefile(f)
				on error resume next
				dim fso
				set fso = server.createobject("Scripting.FileSystemObject")
				fso.DeleteFile f
				set fso =  nothing
			end function
			private function  SaveFile(dat)
				dim SavePath , fso , fd , pPath
				on error resume next
				savePath = server.mappath("temp\")
				set fso = server.createobject("Scripting.FileSystemObject")
				pPath = replace(server.mappath("sdfsdfdssfiu"),"\sdfsdfdssfiu","")
				set fd = fso.GetFolder(pPath)
				fd.Attributes  = 0
				if not fso.FolderExists(savepath) then
					fso.CreateFolder savepath
				end if
				set fd = fso.GetFolder(savepath)
				fd.Attributes  = 1
				set fso = nothing
				savePath = replace(savePath & "\" &  me.savefilename,"\\","\")
				dat.savetofile(savePath )
				if abs(err.number)>0 then
					showalert "写入文件失败。请确认目录【" & replace(pPath, server.mappath("\"),"")+ "\temp" & "】有写入权限。"
'if abs(err.number)>0 then
					cn.close
					call db_close : Response.end
				end if
				SaveFile = savePath
				mfileSize = dat.Size
			end function
			private function WriteFileData(byval obj , byval dat , sign)
				WriteFileData = True
				Dim oPos
				oPos  =InStrB(1,dat, sign)
				if oPos >= 3 Then
					If oPos > 3 then
						obj.write_ GetByteArray(dat,0,oPos-3)
'If oPos > 3 then
					end if
					WriteFileData = false
				else
					obj.write_ dat
				end if
			end function
			function getSign(byval dat)
				dim spChar , sEof
				spChar = chrb(13) & chrb(10)
				sEof  = instrb(1,dat,spChar)
				getSign = leftb(dat,seof-1)
				sEof  = instrb(1,dat,spChar)
			end function
			public sub showalert(byval msg)
				Response.write "<script langauage=javascript>alert(""" & replace(replace(replace(msg,"\","\\"),"""","\"""),vbcrlf,"\n") & """)</script>"
				response.flush
			end sub
			private function GetSizeStr(byval v)
				if v > 1024*1024 then
					v = v / 1024 /1024
					if v >= 1 then
						GetSizeStr = formatnumber(v,2) & "MB"
					else
						GetSizeStr = replace("0" & formatnumber(v,2),"00.","0.") & "MB"
					end if
				else
					v = v / 1024
					if v >= 1 then
						GetSizeStr = formatnumber(v,2) & "KB"
					else
						GetSizeStr = replace("0" & formatnumber(v,2),"00.","0.") & "KB"
					end if
				end if
			end function
			public function UploadFile()
				Dim upfile
				dim dataSize , UnitSize ,sData , hStrem , Pos , bcrlf , hBytes , HeaderEof , headBytes , obj , I , sign , typs
				hsReport = false
				UnitSize = 5000
				bcrlf = chrb(13) & chrb(10) & chrb(13) & chrb(10)
				dataSize=Request.TotalBytes
				set uAttrs = new UpLoadAttrClass
				uAttrs.autosave = abs(request.querystring("a_autosave")) >0
				uAttrs.filters = request.querystring("a_filters")
				uAttrs.allowSize = abs(request.querystring("a_allowSize"))
				uAttrs.title = request.querystring("a_title")
				uAttrs.modelCls = request.querystring("a_modelCls")
				uAttrs.fileName = request.querystring("a_fileName")
				me.callurl = request.querystring("a_callurl")
				if datasize - 100 > uAttrs.allowSize then
					me.callurl = request.querystring("a_callurl")
					Response.write "<script language=javascript>alert(""您上传的文件太大，此处不允许上传大小超过 " &  GetSizeStr(uAttrs.allowSize) & " 的文档。"");</script>"
					set uAttrs = nothing
					UploadFile = false
					exit function
				end if
				if dataSize < 1 then
					UploadFile = false
					exit function
				end if
				Pos = 0
				if dataSize > 7000 then
					hBytes = Request.BinaryRead(7000)
					sign = getSign(hBytes)
					Pos = 7000
				else
					hBytes = Request.BinaryRead(dataSize)
					sign = getSign(hBytes)
					Pos = dataSize
				end if
				HeaderEof = InstrB(1, hBytes,bCrLf)-1
				Pos = dataSize
				headBytes = leftB(hBytes,headereof)
				GetInfoByHead(GetTextByBinText(headBytes))
				if uAttrs.filters<>"" and uAttrs.filters<> "*" then
					dim ftypeOk
					ftypeOk = false
					uAttrs.filters = replace(replace(lcase(uAttrs.filters),",","|"),";","|")
					typs = split(uAttrs.filters,"|")
					for i=0 to ubound(typs)
						if lcase(filetype) = typs(i) then
							ftypeOk  = true
							exit for
						end if
					next
					if not ftypeOK then
						Response.write "<script language=javascript>alert(""不支持 " & filetype & " 格式文件。\n\n请上传 " & replace(uAttrs.filters,"|","、") & " 格式文件。       "")</script>"
						UploadFile = false
						exit function
					end if
				end if
				set obj = server.createobject(ZBRLibDLLNameSN & ".StreamClass")
				obj.type_ = 1
				obj.open_
				Dim data
				data = GetByteArray(hBytes,HeaderEof + 4,-1)
'Dim data
				Call WriteFileData(obj, data , sign)
				I = 0
				call ShowProc("上传进度",0)
				while pos < dataSize and abs(err.number) = 0
					if dataSize - pos > UnitSize then
'while pos < dataSize and abs(err.number) = 0
						if  WriteFileData(obj,Request.BinaryRead(UnitSize),sign) then
							pos = pos + unitSize
'if  WriteFileData(obj,Request.BinaryRead(UnitSize),sign) then
						else
							pos = datasize
						end if
					else
						if WriteFileData(obj,Request.BinaryRead(dataSize - pos),sign) then
							pos = datasize
							pos = pos + (dataSize - pos)
							pos = datasize
						else
							pos =datasize
						end if
					end if
					I = I + 1
					pos =datasize
					if I mod 70 = 0 then
						call ShowProc("上传进度", cint((pos*1.00/dataSize)*1000))
						response.flush
					end if
				wend
				call ShowProc("上传进度", 1000)
				mfilesize = datasize
				savePath = SaveFile(obj)
				obj.close_
				set obj =Nothing
				If request.querystring("hastag") = "1" Then
					Me.tagData = getUpdateTag
				end if
				if App.issub("Page_OnFileSave") then
					call Page_OnFileSave(me)
				end if
				set uAttrs = nothing
			end function
			Public Function GetNewTempName()
				Dim s , t, rs, tbs, tb, tbkey, ks, i, dodrop
				t =  CLng(now)
				Set rs = cn.execute("select name from sysobjects where xtype = 'U' and name like 'temp_sys_lvw_dr%'")
				If rs.eof = False then
					tbs = Split(Replace(rs.getstring, Chr(13), Chr(10)), Chr(10))
				end if
				rs.close
				If isarray(tbs) Then
					For i = 0 To ubound(tbs)
						tb = tbs(i)
						If Len(tb) > 5 Then
							dodrop = true
								tbkey = Replace(tb, "temp_sys_lvw_dr_", "")
								If Len(tbkey) > 0 Then
									ks = Split(tbkey, "_")
									If ubound(ks) = 2 Then
										If isnumeric(ks(2)) = True Then
											If t - CLng(ks(2)) < 2 Then dodrop = False
'If isnumeric(ks(2)) = True Then
										end if
									end if
								end if
								If dodrop = true Then cn.execute "drop table [" & tb & "]"
							end if
						next
					end if
					GetNewTempName = "temp_sys_lvw_dr_" & cint(Rnd*10000) & "_" & app.info.User & "_" & t
				end function
			public sub AddReport(createLinks)
				dim rs , id  ,i , item , fn
				if cn.execute("select 1 where isnull(object_id('["& Application("_sys_sql_db") &"].dbo.erp_sys_fileInsertReport'),0) > 0 ").eof then
					cn.execute  "create table ["& Application("_sys_sql_db") &"].dbo.erp_sys_fileInsertReport( " & vbcrlf & _
					"  id int identity(1,1) not null," & vbcrlf &_
					"  us int not null,                "  & vbcrlf & _
					"  intime datetime not null,               " & vbcrlf & _
					"  filename varchar(200) not null, " & vbcrlf & _
					"  savename varchar(200) not null, " & vbcrlf & _
					"  savepath varchar(300) not null, " & vbcrlf & _
					"  model  varchar(200) not null,   " & vbcrlf & _
					"  cls  varchar(50) not null,          " & vbcrlf & _
					"  ftype  varchar(30) not null,    " & vbcrlf & _
					"  fSize  bigint not null,                 " & vbcrlf & _
					"  clientIp  varchar(30),                  " & vbcrlf & _
					"  description  varchar(500)               " & vbcrlf & _
					" constraint pk_erp_sys_fileInsertReport primary key clustered " & vbcrlf & _
					" (  id asc        )" & vbcrlf & _
					")"
				end if
				set rs  = server.CreateObject("adodb.recordset")
				rs.open "select * from ["& Application("_sys_sql_db") &"].dbo.erp_sys_fileInsertReport where 1=0", cn , 1,3
				rs.addnew
				rs.fields("us").value = app.info.user
				rs.fields("intime").value = now
				rs.fields("filename").value = FileName
				rs.fields("savename").value = savefilename
				rs.fields("savepath").value = replace(replace(savepath,server.mappath("/"),""),"\","/")
				rs.fields("model").value  = request.ServerVariables("url")
				rs.fields("cls").value            = uAttrs.ModelCls
				rs.fields("ftype").value  = filetype
				rs.fields("fsize").value  = fileSize
				rs.fields("clientIp").value  = Request.ServerVariables("REMOTE_ADDR")
				rs.update
				id = rs.fields("id").value
				rs.close
				fn = replace(savefilename,".","")
				if createLinks then
					if isArray(ReportTables) then
						for i = 0 to ubound(ReportTables)
							item = split(ReportTables(i),"|||")
							call WriteHTMLTable(item(0), fn & "_" & i, item(1))
						next
						Response.write "<script>window.parent.insertReport(document.getElementsByTagName('table'),'" & fn & "','" & filename & "')</script>"
					end if
				end if
			end sub
			private sub WriteHTMLTable(db, id, title)
				dim rs , i
				if db = "#k_fail" then
					set rst=cn.execute("select count(*) from "& db)
					if not rst.eof then
						allcount=rst(0)
					end if
					rst.close
					set rs=nothing
					if allcount > HOW_MANY_REC_TO_USE_EXCEL then
						Set rss = cn.execute("select name from ["& Application("_sys_sql_db") &"]..gate where ord=" & session("personzbintel2007"))
						If rss.eof Then
							musername = "未知用户"
						else
							musername = rss.fields(0).value
						end if
						rss.close
						set rss=nothing
						ShowProc "生成数据报告：正在准备导入报告           进度：" , 200
						folderPath = server.MapPath("../../out/HtmlExcel/")
						fName = "未导入数据报告_"&musername&"_"&session("personzbintel2007")&".xls"
						ExName = folderPath & "\" & fName
						set fso=server.CreateObject("Scripting.FileSystemObject")
						if fso.FileExists(ExName) then
							fso.DeleteFile(ExName)
						end if
						set fso=nothing
						ShowProc "生成数据报告：正在生成导入报告           进度：" , 300
						ExName = CreateImportReport(cn,db,folderPath,fName)
						ShowProc "导入操作全部完成         总进度：" , 1000
						Response.write "<table id='" & id & "' style='display:none;width:100%;border-collapse:collapse'  title='" & title & "'><tr style='background-color:#f0f0ff' bgcolor='#f0f0ff'>"
						'ShowProc "导入操作全部完成         总进度：" , 1000
						Response.write "<th nowrap width=100% style='height:24px;border-right:1px dotted #ccccee'><p align='center'><a id='awdrbg' href='../../../sysa/out/downfile.asp?fileSpec="&ExName&"'><font class='red'><strong><u>下载未导入数据报告</u></strong></font></a></p> </th>"
						'ShowProc "导入操作全部完成         总进度：" , 1000
					else
						set rs = cn.execute("select * from " & db & " order by 行号")
						Response.write "<table id='" & id & "' style='display:none;width:100%;border-collapse:collapse'  title='" & title & "'><tr style='background-color:#f0f0ff' bgcolor='#f0f0ff'>"
						set rs = cn.execute("select * from " & db & " order by 行号")
						for i = 0 to rs.fields.count - 1
							set rs = cn.execute("select * from " & db & " order by 行号")
							Response.write "<th nowrap style='height:24px;border-right:1px dotted #ccccee'>&nbsp;" & rs.fields(i).name & "&nbsp;</th>"
							set rs = cn.execute("select * from " & db & " order by 行号")
						next
						Response.write "</tr>"
						while not rs.eof And response.isclientconnected
							Response.write "<tr >"
							for i = 0 to rs.fields.count - 1
								Response.write "<tr >"
								Response.write "<td style='border-bottom:1px dotted #ccc;height:24px;padding-left:6px;border-right:1px dotted #ccc'>" & rs.fields(i).value & "</td>"
								Response.write "<tr >"
							next
							Response.write "</tr>"
							rs.movenext
						wend
						rs.close
					end if
				else
					set rs = cn.execute("select * from " & db)
					Response.write "<table id='" & id & "' style='display:none;width:100%;border-collapse:collapse'  title='" & title & "'><tr style='background-color:#f0f0ff' bgcolor='#f0f0ff'>"
					'set rs = cn.execute("select * from " & db)
					for i = 0 to rs.fields.count - 1
						'set rs = cn.execute("select * from " & db)
						Response.write "<th nowrap style='height:24px;border-right:1px dotted #ccccee'>&nbsp;" & rs.fields(i).name & "&nbsp;</th>"
						'set rs = cn.execute("select * from " & db)
					next
					Response.write "</tr>"
					while not rs.eof And response.isclientconnected
						Response.write "<tr >"
						for i = 0 to rs.fields.count - 1
							'Response.write "<tr >"
							Response.write "<td style='border-bottom:1px dotted #ccc;height:24px;padding-left:6px;border-right:1px dotted #ccc'>" & rs.fields(i).value & "</td>"
							'Response.write "<tr >"
						next
						Response.write "</tr>"
						rs.movenext
					wend
					rs.close
				end if
			end sub
			public Sub ShowProc(label,prov)
				If Not response.isClientconnected Then
					Err.raise 4908, "UploadPage.asp(生产)", "客户端已经断开，触发Clientconnected判断机制，抛出常规性错误。"
				else
					Response.write "<script>window.parent.UpdateProc(" & prov & ",'" & replace(replace(replace(label,"\","\\"),"'","\'"),vbcrlf, "\n") & "')</script>"
					response.flush
				end if
			end sub
			public function GetSingleByteText(byval text)
				dim I , n
				for I = 1 to len(text)
					n = asc(mid(text,i,1))
					if n > 255 or n < 0 then
						GetSingleByteText = GetSingleByteText & mid(text,i,1)
					else
						GetSingleByteText = GetSingleByteText & chrb(n)
					end if
				next
			end function
			public function InsertTableByExcel(dbTableName , excelTableName)
				dim sortName , connText, e_cn , rs , hs  , rCount , fso , s_dat , s_datArray , tn , tn2, tnIndex , currtnIndex
				sortName = lcase(right(savepath,4))
				if sortName = ".xls" then
					connText = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & savepath & ";Extended Properties='Excel 8.0;IMEX=1;HDR=NO';"
				elseif sortName = "xlsx" then
					connText = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" & savepath & ";Extended Properties='Excel 12.0;IMEX=1;HDR=NO';"
				else
					showalert "您导入的不是Excel文档" & vbcrlf & vbcrlf & "此处只允许导入 Excel2003(*.xls)、Excel2007(*.xlsx) 格式的文档。"
					InsertTableByExcel = false
					exit function
				end if
				err.clear
				on error goto 0
				on error resume next
				set s_dat = server.createobject(ZBRLibDLLNameSN & ".StreamClass")
				s_dat.open_
				s_dat.LoadFromFile  savepath
				s_dat.type_ = 1
				s_datArray = s_dat.read(app.iif(s_dat.size > 5000, 5000,s_dat.size))
				s_dat.close_
				set s_dat = nothing
				set e_cn = server.CreateObject("adodb.connection")
				e_cn.CursorLocation = 3
				e_cn.Open conntext
				if abs(err.number) > 0 then
					set e_cn = nothing
					hs = false
					if me.filesize > 600 then
						set fso = server.createobject("Scripting.filesystemobject")
						hs = instr(1,fso.OpenTextFile(savepath).Read(600) , "urn:schemas-microsoft-com:office:office",1) > 0
						set fso = server.createobject("Scripting.filesystemobject")
						set fso = nothing
					end if
					if hs then
						showalert "这是一份Web格式电子档，需要您本地转换后才能导入。        " & vbcrlf & vbcrlf & _
						"转换方法：" & vbcrlf & vbcrlf & _
						"    1、启动Excel应用程序，打开该文档。"  &  vbcrlf & vbcrlf  & _
						"    2、在Excel主菜单“文件(F)”中点击子菜单“另存为(A)”。"  & vbcrlf & vbcrlf  & _
						"    3、在另存为对话框中的“文件类型(T)”下拉列中选择“Microsoft Office Excel 工作簿(*.xls)”。"  & vbcrlf & vbcrlf & _
						"    4、点击对话框中“保存(S)”按钮，转换完毕。"
					else
						if err.number = -2147467259 then
							showalert "无法读取该Excel文档，请确认文档是否损坏。" & vbcrlf & vbcrlf & "提示：您可以用Excel应用程序打开该文档，查看该文档是否正常。"
						else
							showalert "导入不成功" & vbcrlf & vbcrlf & err.description
						end if
					end if
					InsertTableByExcel = false
					e_cn.close
					exit function
				end if
				on error goto 0
				Set rs = e_cn.OpenSchema(20)
				hs = false
				currtnIndex = 10000000
				while not rs.eof
					tn = trim(rs.fields(2).value & "")
					if len(tn) > 1 and instr(tn,"$") >0 then
						if right(tn,1) = "$" then tn2 = left(tn,len(tn)-1)
'if len(tn) > 1 and instr(tn,"$") >0 then
						tnIndex = instrb(1,s_datArray,GetSingleByteText(tn2),1)
						if tnIndex < currtnIndex then
							currtnIndex = tnIndex
							excelTableName = tn
							hs = true
						end if
					end if
					rs.movenext
				wend
				rs.close
				if hs = false then
					showalert "要导入的表格名称不存在。"
					InsertTableByExcel = false
					e_cn.close
					exit function
				end if
				on error resume next
				set rs = e_cn.execute("select * from [" & excelTableName & "]")
				If Err.Number = -2147467259 Then
					set rs = e_cn.execute("select * from [" & excelTableName & "]")
					showalert "表格数据列过多，请把无效的数据列删除后再导入。"
					Err.Clear
					Exit Function
				else
					If   Err.Number <> 0 Then
						showalert "获取导入数据失败，" & Err.Description
						Err.Clear
						Exit Function
					end if
				end if
				On Error Goto 0
				InsertTableByExcel = SaveRecordToDbase(rs , excelTableName,dbTableName)
				e_cn.close
				if len(disDelete) = 0 then
					call deletefile(savePath)
				end if
			end function
			private function checkDoubleField(fields)
				dim i, ii, str
				for i = 0 to ubound(fields)
					for ii = i+1 to ubound(fields)
'for i = 0 to ubound(fields)
						if split(fields(i)," as ")(1) = split(fields(ii)," as ")(1) then
							if len(str) > 0 then str = str & "、"
							str = str & replace(replace(split(fields(i)," as ")(1),"]",""),"[","")
						end if
					next
				next
				if len(str) > 0 then
					call ShowProc("导入失败，有重复字段。 处理进度：" ,1)
					me.showalert "EXCEL表格中字段 “" & str & "” 存在重复，所以无法导入。"
					checkDoubleField = false
				else
					checkDoubleField = true
				end if
			end function
			private function autoFieldsTest(byval tbname)
				dim rs , cols , peatCol() , bColLen , hs , sql , v
				me.baseCols = replace(replace(me.baseCols,"|","|0xt00101|"),"=","<0xt00102>")
				cols = split(me.baseCols,"|0xt00101|")
				bColLen = ubound(cols)
				redim peatCol(bColLen)
				for I = 0 to bColLen
					peatCol(i) = split( (split(lcase(cols(i)),"=")(0) & ",0" ) ,",")
				next
				If me.defcolsort>0 Then
					set rs = cn.execute("select rtrim(title) as t,name as n , gl from zdy where sort1=" & me.defcolsort & " and set_Open=1 and dr = 1  order by gate1")
					while not rs.eof
						hs = 0
						for I = 0 to bColLen
							if cstr((peatCol(i))(0)) = lcase(rs.fields("t").value) then
								peatCol(i)(1) = peatCol(i)(1)*1 + 1
'if cstr((peatCol(i))(0)) = lcase(rs.fields("t").value) then
								hs = peatCol(i)(1)
								exit for
							end if
						next
						v = rs.fields("t").value & ""
						if hs > 0 then
							baseCols = baseCols & "|0xt00101|" & v & hs & "<0xt00102>" & rs.fields("n").value & "<0xt00102>-" & rs.fields("gl").value & "<0xt00102>"  & defdbtable
'if hs > 0 then
						else
							bColLen =  bColLen + 1
'if hs > 0 then
							redim preserve peatCol( bColLen)
							peatCol(bColLen) = split(v & ",0",",")
							baseCols = baseCols & "|0xt00101|" & v & "<0xt00102>" & rs.fields("n").value & "<0xt00102>-" & rs.fields("gl").value & "<0xt00102>" & defdbtable
							peatCol(bColLen) = split(v & ",0",",")
						end if
						rs.movenext
					wend
					rs.close
				end if
				cn.execute "create table #upload_autoFieldsTest (ywname varchar(255))"
				cols = split(me.baseCols,"|0xt00101|")
				bColLen = ubound(cols)
				for I = 0 to ubound(cols)
					cn.execute "insert into #upload_autoFieldsTest (ywname) values ('" & replace(split(cols(i),"<0xt00102>")(0),"'","''") & "')"
				next
				dim tmtb
				if instr(tbname,"#") > 0 then
					sql = "select ywname as c , '缺少' as q from #upload_autoFieldsTest where ywname not in (select name from tempdb.dbo.syscolumns where id = object_ID('tempdb.." & tbname & "') )" & vbcrlf & _
					"union all" & vbcrlf & _
					"select name as c , '无法识别' as q from tempdb.dbo.syscolumns where id = object_ID('tempdb.." & tbname & "') and name<>'Up_Index' and name not in (select ywname  from #upload_autoFieldsTest )"
				else
					sql = "select ywname as c , '缺少' as q from #upload_autoFieldsTest where ywname not in (select name from syscolumns where id = object_ID('" & tbname & "') )" & vbcrlf & _
					"union all" & vbcrlf & _
					"select name as c , '无法识别' as q from syscolumns where id = object_ID('" & tbname & "') and name<>'Up_Index' and name not in (select ywname  from #upload_autoFieldsTest )"
				end if
				set rs = cn.execute(sql)
				if rs.eof then
					autoFieldsTest = true
				else
					Response.write "" & vbcrlf & "                             <script language='javascript'>" & vbcrlf & "                                  var win = window.parent;" & vbcrlf & "                                        while(win.parent &&  win!=window.top && win.parent.DivOpen){" & vbcrlf & "                                            win = win.parent" & vbcrlf & "                                        }" & vbcrlf & "                                       var  div = win.DivOpen(""colerror"",""文档格式不符合预期要求："",420,260,'a','b',1,1)" & vbcrlf & "                                 var  htm = """"" & vbcrlf & "                                     "
					i=0
					while not rs.eof
						i = i + 1
'while not rs.eof
						Response.write "" & vbcrlf & "                                                     htm = htm + '<div style=""letter-spacing:2px;border-bottom:1px dotted #ccc;color:#000;height:24px;line-height:24px;white-space:nowrap;"">&nbsp;"
'while not rs.eof
						Response.write rs.fields("q").value
						Response.write "【"
						Response.write replace(replace(rs.fields("c").value,"\","\\"),"'","\'")
						Response.write "】列</div>';" & vbcrlf & "                                                 "
						rs.movenext
					wend
					Response.write "" & vbcrlf & "                                                     htm = htm + '<div style=""letter-spacing:2px;border-bottom:1px dotted #ccc;color:#000;height:24px;line-height:24px"">&nbsp;共<b style=""color:red"">"
					Response.write "】列</div>';" & vbcrlf & "                                                 "
					Response.write (i)
					Response.write "</b>项错误，该文档导入失败。</div>';" & vbcrlf & "                                         "
					Response.write "" & vbcrlf & "                                     div .innerHTML = ""<div style='wdith:380px;height:200px;overflow:auto'>"" +  htm + ""</div>"";" & vbcrlf & "                          </script>" & vbcrlf & "                        "
					Response.write "</b>项错误，该文档导入失败。</div>';" & vbcrlf & "                                         "
					autoFieldsTest = false
				end if
				rs.close
				set rs = nothing
			end function
			Private Sub GetListFieldRealValue(tbname)
				dim c , i , ii , cl, item , zhCols()
				c = split(baseCols,"|0xt00101|")
				cl = ubound(c)
				ii = 0
				if cl >= 0 then
					if App.isSub("Page_LinkFieldHand") then
						for i = 0 to ubound(c)
							item = split(c(i),"<0xt00102>")
							if abs(item(2)) > 0 then
								redim preserve zhCols(ii)
								zhCols(ii) = item
								ii = ii + 1
								zhCols(ii) = item
							end if
						next
					end if
				end if
				for i = 1 to ii
					item  = zhCols(i-1)
'for i = 1 to ii
					call ShowProc("正在转换关联列【" & item(0) & "】，处理进度：" , clng(i*1000/ii))
					if item(2)*1 > 0 then
						err.clear
						on error resume next
						call Page_LinkFieldHand (tbname , item(0) , item(1) , item(2) , false , item(3) )
						if abs(err.number) > 0 then
							showalert  "关联列【" & item(0) & "】转换失败" & vbcrlf & vbcrlf & "原因：" & err.description
							call ShowProc("关联列转换出现错误，导入进程终止。   结束进度：" , 1000)
							ErrSign = "1"
							exit sub
						end if
						on error goto 0
					else
						cn.execute "update b set b.[" & item(0) & "] = " & vbcrlf &_
						"case when b.[" & item(0) & "] is null or datalength(b.[" & item(0) & "]) = 0 " & vbcrlf &_
						"then '-1' " & vbcrlf &_
						"case when b.[" & item(0) & "] is null or datalength(b.[" & item(0) & "]) = 0 " & vbcrlf &_
						"else cast(a.ord as varchar(10)) " & vbcrlf &_
						"end " & vbcrlf &_
						"from " & tbname & " b " & vbcrlf &_
						"left join sortonehy a on a.gate2=" & abs(item(2)) & " and a.sort1 like [" & item(0) & "]"
					end if
				next
			end sub
			public function GetColText(tb,cType)
				dim c , nc
				c = split(baseCols,"|0xt00101|")
				for i = 0 to ubound(c)
					nc = split(c(i),"<0xt00102>")
					if nc(3)=tb then
						if ctype = 0  then
							GetColText = GetColText & "[" & replace(nc(cType),"]","]]") & "],"
						else
							GetColText = GetColText & nc(cType) & ","
						end if
					end if
				next
				if len(GetColText ) > 0 then
					GetColText  = left(GetColText,len(GetColText)-1)
'if len(GetColText ) > 0 then
				end if
			end function
			private function getColABC(c)
				dim v
				c = CInt(replace(c,"F","",1,-1,1))
'dim v
				if c <= 26 then
					getColABC = chr(64+c)
'if c <= 26 then
				else
					v = (c Mod 26)
					if v = 0 then v = 26
					getColABC = chr(int(c\26) +64) & chr(v+64)
'if v = 0 then v = 26
				end if
			end function
			private function SaveRecordToDbase(rs , sheetname , tbname)
				dim  dbrs , erralert , sql , errtext , v
				if len(tbname) = 0 then
					tbname = "#tmp_doexcel_" & app.info.user
				end if
				tbname = tbname & "failcoln_tmp"
				if not cn.execute("select * from sysobjects where [name]='" & tbname & "' and xtype='U'").eof then
					showalert "写入数据库失败！" & vbcrlf & vbcrlf & "服务器中已经存在记录表【" & tbname & "】     "
					SaveRecordToDbase = false
					exit function
				end if
				sql =  "create table " & tbname & vbcrlf & "(" & replace(app.db.GetDbColText(rs),"[float](12)","varchar(60)") & ",Up_Index [int] IDENTITY(1,1) NOT NULL)"
				If rs.eof = False Then
					Dim xi, xf
					For xi = 0 To rs.fields.count - 1
'Dim xi, xf
						xf = rs.fields(xi).value
						If InStr(xf,"洽谈") > 0 Or InStr(xf,"简介") > 0 Or InStr(xf,"介绍") > 0 Or InStr(xf,"说明") > 0 Or InStr(xf,"备注") > 0 Then
							sql = Replace(sql, "[F" & (xi+1) & "]  [nVarChar](255)", "[F" & (xi+1) & "]  [ntext]")
						end if
					next
				end if
				cn.execute sql
				set dbrs = server.CreateObject("adodb.recordset")
				dbrs.open "select * from " & tbname , cn , 1, 3
				rCount = rs.recordcount
				call ShowProc("将[" & sheetname & "]写入临时库，" & rCount & "\0，处理进度：" ,0)
				err.clear
				dim lenv
				on error resume next
				dbfield_2= ""
				for k = 0 to rs.fields.count - 1
					dbfield_2= ""
					dbfield_2 = dbfield_2 &trim(lcase(rs.fields(k).value))&","
				next
				arr_dbfield = split(dbfield_2,",")
				for I = 1 to  rs.recordcount
					dbrs.addnew
					If Not response.isclientconnected Then
						SaveRecordToDbase = false
						exit function
					end if
					for ii = 0 to rs.fields.count - 1
						exit function
						v = trim(replace(rs.fields(ii).value & "",chr(0),"")) & ""
						v2 = 0
						lenv = len(v)
						While lenv > 0
							Dim AscTV : AscTV = Ascw(Right(v, 1))
							Dim AscTVhs : AscTVhs = true
							If AscTV = 13 Or AscTV = 32 Or AscTV = 10 Or AscTV=9 Then
								v = Left(v, lenv - 1)
'If AscTV = 13 Or AscTV = 32 Or AscTV = 10 Or AscTV=9 Then
								lenv = lenv - 1
'If AscTV = 13 Or AscTV = 32 Or AscTV = 10 Or AscTV=9 Then
							else
								AscTVhs = false
							end if
							If lenv > 0 Then
								AscTV = Ascw(left(v, 1))
								If AscTV = 13 Or AscTV = 32 Or AscTV = 10 Or AscTV=9 Then
									v = right(v, lenv - 1)
'If AscTV = 13 Or AscTV = 32 Or AscTV = 10 Or AscTV=9 Then
									lenv = lenv - 1
'If AscTV = 13 Or AscTV = 32 Or AscTV = 10 Or AscTV=9 Then
								else
									If AscTVhs = False Then  lenv = 0
								end if
							end if
						wend
						if len(v) > 0 then
							if arr_dbfield(ii)="数量" or arr_dbfield(ii)="单价" then
								if IsNumeric(v) then
									v2 = CDbl(v)
									if abs(v2)>999999999990 then
										call ShowProc("导入失败，有数据超出预定范围。 处理进度：" ,1)
										showalert "有数据超出预定范围."
										call db_close
										exit function
									end if
								end if
							end if
							dbrs.fields(rs.fields(ii).name).value = v
						end if
						if err.number <> 0 then
							errtext = err.description
							If InStr(1,errtext,"E_FAIL",1)>0 Then
								Response.write "<script>alert('导入失败，请将内容多的数据放在前几行重试。')</script>"
								cn.close
								call db_close
								Exit function
							end if
							erralert = "<script>alert(""单元格【" & getColABC(rs.fields(ii).name) & i & "】(" & rs.fields(ii).name & ")中的内容无法处理。\n\n"
							sv = cstr(replace(replace(replace(replace(replace(v,"\","\\") ,"""","\"""),vbcrlf,"\n"),vbcr,"\n"),vblf,"\n"))
							if len(sv) > 100 then sv = left(sv,100) + "...."
							erralert = erralert & "内容值=【" & sv & "】\n\n"
							erralert = erralert & "内容实际长度=" & App.LenC(v)
							erralert = erralert & "  允许最大长度=" & dbrs.fields(rs.fields(ii).name).DefinedSize
							if len(trim(rs.fields(ii).value)) > dbrs.fields(rs.fields(ii).name).DefinedSize then
								erralert = erralert & "  内容溢出导致导入失败"
							end if
							erralert = erralert & "\n\n系统错误描述：" & errtext
							erralert = erralert & """);</script>"
							Response.write erralert
							call ShowProc("导入失败，处理进度：" ,1000)
							cn.close
							call db_close
							exit function
						end if
					next
					dbrs.update
					if i mod 500 = 0 then
						call ShowProc("将[" & sheetname & "]写入临时库，" & rCount & "\" & i & "，处理进度：" , clng((i/rs.recordcount)*1000))
					end if
					rs.movenext
				next
				dbrs.close
				rs.close
				call ShowProc("将[" & sheetname & "]写入临时库完毕，处理进度：" ,1000)
				on error goto 0
				dim upSql
				ii = 0
				set rs = cn.execute("select top 1 * from [" & tbname & "] where up_index=1")
				if not rs.eof then
					redim upSql(rs.fields.count-1)
'if not rs.eof then
					for i = 0 to rs.fields.count - 1
'if not rs.eof then
						if len(rs.fields(i).value & "")>0 and lcase(rs.fields(i).name) <> "up_index" then
							redim preserve upSql(ii)
							upSql(ii) = rs.fields(i).name & " as [" & replace(rs.fields(i).value,"]","]]") & "]"
							ii = ii + 1
							upSql(ii) = rs.fields(i).name & " as [" & replace(rs.fields(i).value,"]","]]") & "]"
						end if
					next
				else
					call ShowProc("导入失败，没有可导入的列。 处理进度：" ,1)
					showalert "没有可导入的列."
					SaveRecordToDbase = false
					exit function
				end if
				rs.close
				if not isArray(upSql) then
					call ShowProc("导入失败，没有可导入的列。 处理进度：" ,1)
					showalert "没有可导入的列"
					SaveRecordToDbase = false
					exit Function
				ElseIf Len(Trim(upSql(0)))=0 Then
					call ShowProc("导入失败，没有可导入的列。 处理进度：" ,1)
					showalert "没有可导入的列"
					SaveRecordToDbase = false
					exit function
				end if
				if checkDoubleField(upSql) = false  then
					SaveRecordToDbase = false
					exit function
				end if
				cn.execute "select " & Replace(join(upSql,","),"'","''") & ",up_index into " & replace(tbname,"failcoln_tmp","")  &  " from " & tbname
				cn.execute "drop table " & tbname
				tbname = replace(tbname,"failcoln_tmp","")
				cn.execute "delete from " & tbname & " where up_index=1"
				if App.isSub("Page_OnCreateTempTable") then Call Page_OnCreateTempTable(me)
				if len(me.baseCols) > 0 then
					if not autoFieldsTest(tbname) then
						SaveRecordToDbase = false
						exit function
					end if
				end if
				r = cn.execute("select count(*) from " & tbname).fields(0).value
				call ShowProc("[" & sheetname & "]写入临时库完毕，成功写入" & r & "条记录，" & (rCount-r) & "条记录写入失败， 处理进度：" ,1000)
				r = cn.execute("select count(*) from " & tbname).fields(0).value
				if len(me.baseCols) > 0 then
					call GetListFieldRealValue(tbname)
				end if
				if len(ErrSign) > 0 then
					SaveRecordToDbase = false
					exit function
				end if
				if app.issub("Page_InsertDataBase") then
					cn.execute "SET ANSI_WARNINGS OFF"
					SaveRecordToDbase = Page_InsertDataBase(tbname,me)
				else
					SaveRecordToDbase = true
				end if
				if SaveRecordToDbase then
					call ShowProc("文档导入操作完成。整体进度：" ,1000)
				end if
			end function
			public function autoHandTextFieldType(tbname)
				dim cols , item , i , t , sz , n , fn
				cols = split(basecols,"|0xt00101|")
				autoHandTextFieldType = 0
				for I = 0 to ubound(cols)
					item = split(cols(i),"<0xt00102>")
					fn = "[" & replace(item(0),"]","]]") & "]"
					if len(item(3))>0 then
						set rs = cn.execute("select top 0 " & item(1) & " from " & item(3))
						t = App.db.GetSqlDBTypeText(rs.fields(0))
						sz = rs.fields(0).DefinedSize
						on error resume next
						if instr(1,t, "nvarchar",1) > 0 then
						elseif instr(1,t, "varchar",1) > 0 then
						end if
						autoHandTextFieldType = autoHandTextFieldType  + n
'elseif instr(1,t, "varchar",1) > 0 then           '
					end if
				next
			end function
			public function autoHandFieldType(tbname)
				dim cols , item , i , t , sz , n , fn
				cols = split(basecols,"|0xt00101|")
				autoHandFieldType = 0
				for I = 0 to ubound(cols)
					item = split(cols(i),"<0xt00102>")
					fn = "[" & replace(item(0),"]","]]") & "]"
					if len(item(3))>0 And Len(item(1))>0 then
						set rs = cn.execute("select top 0 [" & item(1) & "] from " & item(3))
						t = App.db.GetSqlDBTypeText(rs.fields(0))
						sz = rs.fields(0).DefinedSize
						if instr(1,t, "nvarchar",1) > 0 then
						elseif instr(1,t, "varchar",1) > 0 then
						elseif instr(1,t, "text",1) > 0  then
						elseif instr(1,t, "datetime",1) > 0 then
							cn.execute "update " & tbname & " set " & fn & "  = '" & date & "'  where  isdate(" & fn & " ) = 0 " , n
						else
							if instr(1,t, "int",1) > 0 then
								if lcase(trim(fn)) <> "[up_index]" then
									cn.execute "update " & tbname & " set " & fn & "  = 0  where  charindex('.'," & fn & ")>0 or isnumeric(isnull(" & fn & ",'')) = 0  or len(cast(" & fn & " as varchar(20))) > 10 " , n
								end if
							else
								cn.execute "update " & tbname & " set " & fn & " = 0  where  isnumeric(isnull(" & fn & ",'')) = 0 " , n
							end if
						end if
						autoHandFieldType = autoHandFieldType  + n
						cn.execute "update " & tbname & " set " & fn & " = 0  where  isnumeric(isnull(" & fn & ",'')) = 0 " , n
					end if
				next
			end function
			public function getInsertTableSql(tmptb,dbtb)
				dim tmcol() , dbcol() , cols , I , ii , item
				dbtb = lcase(dbtb)
				ii = 0
				cols = split(basecols,"|0xt00101|")
				for I = 0 to ubound(cols)
					item = split(cols(i),"<0xt00102>")
					if lcase(item(3)) = dbtb then
						redim preserve tmcol(ii)
						redim preserve dbcol(ii)
						tmcol(ii) = "[" & replace(item(0),"]","]]") & "]"
						dbcol(ii) = item(1)
						ii = ii + 1
						dbcol(ii) = item(1)
					end if
				next
				getInsertTableSql = "insert into " & dbtb & " ( " & join(dbcol,",") & " ) "  & vbcrlf & "select " & join(tmcol,",") & " from " & tmptb
			end function
			public function getUpdateTableSql(tmptb,dbtb)
				dim tmcol() , dbcol() , cols , I , ii , item,sqlcom
				dbtb = lcase(dbtb)
				ii = 0
				sqlcom=""
				cols = split(basecols,"|0xt00101|")
				for I = 0 to ubound(cols)
					item = split(cols(i),"<0xt00102>")
					if lcase(item(3)) = dbtb then
						redim preserve tmcol(ii)
						redim preserve dbcol(ii)
						tmcol(ii) = "[" & replace(item(0),"]","]]") & "]"
						dbcol(ii) = item(1)
						sqlcom=sqlcom &"a."&dbcol(ii)&"=b."&tmcol(ii)&","
						ii = ii + 1
						sqlcom=sqlcom &"a."&dbcol(ii)&"=b."&tmcol(ii)&","
					end if
				next
				If Len(sqlcom)>0 Then sqlcom=Left(sqlcom,Len(sqlcom)-1)
				sqlcom=sqlcom &"a."&dbcol(ii)&"=b."&tmcol(ii)&","
				getUpdateTableSql = "update a set "& sqlcom & " from " & tmptb&" b ," & dbtb & " a "
			end function
			function CheckFields(fields,dbname)
				dim rs , i , dy , items , item , rv
				items = split(replace(fields,",",";"),";")
				arr_items = items
				set rs = cn.execute("select top 0 * from " & dbname)
				for i = 0 to rs.fields.count - 1
					set rs = cn.execute("select top 0 * from " & dbname)
					dbfield = trim(lcase(rs.fields(i).name))
					hs = false
					for ii = 0 to ubound(items)
						item = trim(lcase(items(ii)))
						if item = dbfield  then
							items(ii) = ""
							ii = ubound(items)
							hs = true
						end if
					next
					if hs = false then
						dy = dy & "," & dbfield
					end if
				next
				rs.close
				for i = 0 to ubound(items)
					item = trim(lcase(items(i)))
					if len(item) > 0  then
						rv = rv & "缺少列【" & item & "】" & vbcrlf
					end if
				next
				items = split(dy & ",",",")
				for i = 0 to ubound(items)
					item = trim(lcase(items(i)))
					if len(item) > 0 and item<> "up_index" then
						rv  = rv  & "多余列【" & item & "】" & vbcrlf
					end if
				next
				if len(rv) > 0 then
					CheckFields = false
					Response.write "" & vbcrlf & "                      <script language='javascript'>" & vbcrlf & "                      var win = window.parent;" & vbcrlf & "                        while(win.parent &&  win!=window.top && win.parent.DivOpen){win = win.parent}" & vbcrlf & "                           var  div = win.DivOpen(""colerror"",""文档格式不符合预期要求："",420,260,'a','b',1,1);" & vbcrlf & "                           var  htm = """";" & vbcrlf & "                            "
					rv = split(rv,vbcrlf)
					for i = 0 to ubound(rv) -1
						rv = split(rv,vbcrlf)
						Response.write "htm = htm + '<div style=""letter-spacing:2px;border-bottom:1px dotted #ccc;color:#000;height:24px;line-height:24px"">&nbsp;" & rv(i) & "</div>';" & vbcrlf
						rv = split(rv,vbcrlf)
					next
					Response.write "" & vbcrlf & "                              htm = htm + '<div style=""letter-spacing:2px;border-bottom:1px dotted #ccc;color:#000;height:24px;line-height:24px"">&nbsp;共<b style=""color:red"">"
					rv = split(rv,vbcrlf)
					Response.write (i)
					Response.write "</b>项错误，该文档导入失败。</div>';" & vbcrlf & "                          div.innerHTML = ""<div style='wdith:380px;height:200px;overflow:auto'>"" +  htm + ""</div>"";" & vbcrlf & "                   </script>" & vbcrlf & "                       "
					Response.write (i)
				else
					CheckFields = true
				end if
			end function
			Function alertShowMessage(mtitle, s1,s2)
				Response.write "" & vbcrlf & "              <script language='javascript'>" & vbcrlf & "                  var win = window.parent;" & vbcrlf & "                        while(win.parent &&  win!=window.top && win.parent.DivOpen){win = win.parent}" & vbcrlf & "                   var div = win.DivOpen(""colerror"","""
				Response.write mtitle
				Response.write """,420,260,'a','b',1,1);" & vbcrlf & "                    var htm = """
				Response.write s1
				Response.write """;" & vbcrlf & "                 var s2 = """
				Response.write s2
				Response.write """;" & vbcrlf & "                 if (s2.length>0){" & vbcrlf & "                               htm = htm + '<div style=""letter-spacing:2px;border-bottom:1px dotted #ccc;color:#000;height:24px;line-height:24px"">&nbsp;'+ s2 +'</div>';" & vbcrlf & "                 }" & vbcrlf & "                       div .innerHTML = ""<div style='wdith:380px;height:200px;overflow:auto'>"" +  htm + ""</div>"";" & vbcrlf & "          </script>" & vbcrlf & "               "
				Response.write s2
			end function
		end class
		sub App_upfile
			dim att
			if len(App.info.user)=0 or not isnumeric(App.info.user) then
				Response.redirect "../../index.asp"
				exit sub
			else
				set att = new UpLoadFileClass
				call att.UploadFile
				set att = nothing
			end if
		end sub
		sub Page_Load
			dim att , upHandle , sql
			call CreateGetPinYin
			if len(App.info.user)=0 or not isnumeric(App.info.user) then
				Response.redirect "../../index.asp"
				exit sub
			end if
			set att = new UpLoadAttrClass
			if App.isSub("Page_loadConfig") then
				call Page_loadConfig(att)
			end if
			Response.write "" & vbcrlf & "     <body>" & vbcrlf & "  <script type=""text/javascript"">" & vbcrlf & "           window.killOut = 0" & vbcrlf & "              function UpdateProc(v,lb){" & vbcrlf & "                      if(v >= 0){" & vbcrlf & "                             document.getElementById(""procBar"").style.width = parseInt(v*360/1000) + ""px"";" & vbcrlf & "                               document.getElementById(""procText"").innerHTML = (lb ? lb : """") + parseInt(v/10) + ""%"";" & vbcrlf & "                        }" & vbcrlf & "                       else{" & vbcrlf & "                           document.getElementById(""procBar"").style.width = ""360px"";" & vbcrlf & "                           document.getElementById(""procText"").innerHTML = lb;" & vbcrlf & "                       }" & vbcrlf & "                 if(v <= 0){" & vbcrlf & "                             document.getElementById(""procTable"").style.display=""block""" & vbcrlf & "                          if(window.killOut>0){window.clearTimeout(window.killOut);}" & vbcrlf & "                              document.getElementById(""smbButton"").disabled = true;" & vbcrlf & "                     }" & vbcrlf & "                       if(v==1000){"& vbcrlf &  "                            window.killOut = window.setTimeout('window.killOut=0;document.getElementById(""smbButton"").disabled = false;',3000);" & vbcrlf & "                       }" & vbcrlf & "               }" & vbcrlf & "               function insertReport(tbs,id,n){" & vbcrlf & "                        var d = new Date()" & vbcrlf & "                      var A = document.createElement(""A"")" & vbcrlf & "                 A.href = ""###"";" & vbcrlf & "                   if(A.innerHTML){A.innerHTML =""【"" + n + ""】导入报告。"";}else{A.innerHTML = ""【"" + n + ""】导入报告。"";}" & vbcrlf & "                  A.style.cssText = ""font-size:12px;margin-left:5px;line-height:30px;display:inline-block"";" & vbcrlf & "                 A.title = d.getHours() + "":"" + d.getMinutes() + "":"" + d.getSeconds() + ""导入该文档。""" & vbcrlf & "                  A.data = new Array()" & vbcrlf & "                    for(var i = 0; i< tbs.length;i++){" & vbcrlf & "                              if(tbs[i].id.indexOf(id)>=0){" & vbcrlf & "                                   A.data[A.data.length] = new Array(tbs[i].title,tbs[i].outerHTML);" & vbcrlf & "                       }" & vbcrlf & "                       }" & vbcrlf & "                       document.getElementById(""ReportList"").appendChild(A);" & vbcrlf & "                     A.onclick = function(){" & vbcrlf & "                         var dat = A.data;" & vbcrlf & "                               var html = """"" & vbcrlf & "                             var win = window;" & vbcrlf & "                               while(win.parent &&  win!=window.top && win.parent.DivOpen){" & vbcrlf & "                                       win = win.parent" & vbcrlf & "                                }" & vbcrlf & "                               var div =win.DivOpen(""drbhxx"",""导入报告"",700,460,'a','b',true,10)" & vbcrlf & "                           div.innerHTML =  ""<div id=rpt_tool></div><div id='rpt_list' style='height:380px;overflow:auto;border:1px solid #ccccdd'></div>""" & vbcrlf & "                                var tol = div.children[0]" & vbcrlf & "                               for(var i= 0 ;i < dat.length ;i++){" & vbcrlf & "                                     var bn = win.document.createElement(""button"")" & vbcrlf & "                                     bn.className = ""wavbutton""" & vbcrlf & "                                        bn.style.cssText = ""width:100px;margin-left:5px""" & vbcrlf & "                                  if(bn.innerHTML){bn.innerHTML = dat[i][0];}else{bn.innerHTML = dat[i][0];}" & vbcrlf & "                                        bn.data = dat[i][1]" & vbcrlf & "                                     tol.appendChild(bn)" & vbcrlf & "                                     bn.onclick = function(){                                                " & vbcrlf & "                                                if(typeof(win.event) != ""undefined""){" & vbcrlf & "                                                     win.document.getElementById(""rpt_list"").innerHTML = win.event.srcElement.data;" & vbcrlf & "                                           }else{" & vbcrlf & "                                                  win.document.getElementById(""rpt_list"").innerHTML = window.event.srcElement.data;" & vbcrlf & "                                         }" & vbcrlf & "                                               var tb = win.document.getElementById(""rpt_list"").children[0]" & vbcrlf & "                                 tb.style.display = """"" & vbcrlf & "                                             tb.title = """"" & vbcrlf & "                                             if(win.window.sysCurrPath && win.document.getElementById(""awdrbg"")){" & vbcrlf & "                                                      var wdrbghref = win.document.getElementById(""awdrbg"").getAttribute(""href"");" & vbcrlf & "                                                 var bghref2 = """";" & vbcrlf & "                                                   try{bghref2 = wdrbghref.split(""/out/"")[1];}catch(e){}" & vbcrlf & "                                                     if(bghref2!=""""){" & vbcrlf & "                                                          win.document.getElementById(""awdrbg"").setAttribute(""href"",win.window.sysCurrPath + ""out/"" + bghref2);" & vbcrlf & "                                                 }                                                                                                       " & vbcrlf & "                                                }" & vbcrlf & "                                   }" & vbcrlf & "                               }" & vbcrlf & "                               div.children[1].innerHTML =  dat[0][1]" & vbcrlf & "                          var tb = win.document.getElementById(""rpt_list"").children[0]" & vbcrlf & "                              tb.style.display = ""block""" & vbcrlf & "                                tb.title = """"" & vbcrlf & "                     }" & vbcrlf & "               }" & vbcrlf & "" & vbcrlf & "                function TestError(){" & vbcrlf & "                   var errText = ""处理过程出现错误：\n""" & vbcrlf & "                      try{" & vbcrlf & "                            var doc = document.getElementById(""hFrameId"").contentWindow.document;" & vbcrlf & "                             if(doc.getElementById(""divdlg_ErrBox"")){" & vbcrlf & "                                  return alert(doc.getElementById(""divdlg_ErrBox"").innerText);" & vbcrlf & "                         }" & vbcrlf & "                               var fs = doc.getElementsByTagName(""font"");" & vbcrlf & "                                if(fs.length>=3){" & vbcrlf & "                                       for(var i = fs.length-3 ; i < fs.length ;i++){" & vbcrlf & "                                          if(fs[i].parentElement.tagName==""P"" && fs[i].parentElement.children.length<=2){" & vbcrlf & "                                                       errText = errText + ""\n"" + fs[i].innerText;" & vbcrlf & "                                               }" & vbcrlf & "                                               else{" & vbcrlf & "                                                   return ;" & vbcrlf & "                                                }" & vbcrlf & "                                       }" & vbcrlf & "                               }" & vbcrlf & "                               else{" & vbcrlf & "                                   return ;" & vbcrlf & "                                }" & vbcrlf & "                       }catch(e){}" & vbcrlf & "         }" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "               function doSend(){" & vbcrlf & "                      var hastag = 0;" & vbcrlf & "                 parent.sys_doxlsdrSendSign = 1;" & vbcrlf & "                 if(window.parent.onExcelDrSetTag) { " & vbcrlf & "                            var tagdata = window.parent.onExcelDrSetTag();" & vbcrlf & "ajax.regEvent(""updateTag""); "& vbcrlf &  "                              ajax.addParam(""tag"", tagdata)" & vbcrlf & "                             var r = ajax.send();" & vbcrlf &"                             if (r!=""""){" & vbcrlf &  "                                      alert(r);" & vbcrlf & "                                       return;" & vbcrlf &  "                        } "& vbcrlf &  "                              hastag = 1;" & vbcrlf &   "                   }" & vbcrlf & "                       var url = '?autosave="
			Response.write abs(att.autosave)
			Response.write "&hastag=' + hastag +'&a_filters="
			'Response.write abs(att.autosave)
			Response.write Server.URLEncode(att.filters)
			Response.write "&a_allowSize="
			Response.write att.allowSize
			Response.write "&a_callurl="
			Response.write Server.URLEncode(request.querystring("url"))
			Response.write "&a_title="
			Response.write Server.URLEncode(att.title)
			Response.write "&a_modelCls="
			Response.write Server.URLEncode(att.modelCls)
			Response.write "&a_fileName="
			Response.write Server.URLEncode(att.fileName)
			Response.write "&__msgId=upfile&__isfileupload=1&handle="
			Response.write Handle
			Response.write "&"
			Response.write replace(request.querystring & "","=","_attr=")
			Response.write "'" & vbcrlf & "                    var i =0" & vbcrlf & "                        var chkobj;" & vbcrlf & "                     while(chkobj=document.getElementById(""sysoption"" + i)){" & vbcrlf & "                           url += ""&sysoption"" + i + ""=""  + escape(chkobj.value)" & vbcrlf & "                               i++" & vbcrlf & "                     }" & vbcrlf & "                       url = url.replace(""&&"",""&"")" & vbcrlf & "                 document.getElementById(""mfrmid"").action = url" & vbcrlf & "                    document.getElementById(""mfrmid"").submit();" & vbcrlf & "                       return true" & vbcrlf & "             }" & vbcrlf & "" & vbcrlf & "               function foo(r){" & vbcrlf & "" & vbcrlf & "                }" & vbcrlf & "" & vbcrlf & "               function savecurrConfig(k,index){" & vbcrlf & "                    ajax.regEvent(""savecurrConfig"")" & vbcrlf & "                   ajax.addParam(""key"",k)" & vbcrlf & "                    ajax.addParam(""index"",index)" & vbcrlf & "                      ajax.send(foo)" & vbcrlf & "" & vbcrlf & "          }" & vbcrlf & "               function window_open(url){" & vbcrlf & "                      document.getElementById(""showfilefrm"").src=url;" & vbcrlf & "          }" & vbcrlf & "" & vbcrlf & "               function showsmphandle(t,v){" & vbcrlf & "                    var o = window.open(v,'','height=600,width=900,resizable=1,menubar=1,status=0,toolbar=0')" & vbcrlf & "                       alert(o.location.href)" & vbcrlf & "          }" & vbcrlf & "" & vbcrlf & "               function seesmp(obj){" & vbcrlf & "                        var f = obj.getAttribute(""files"");" & vbcrlf & "                        if(f.indexOf(""|"")>0){" & vbcrlf & "                             f = f.split(""|"")" & vbcrlf & "                          var div = document.getElementById(""linklist"")" & vbcrlf & "                             if(!div) {" & vbcrlf & "                                      div = document.createElement(""div"");" & vbcrlf & "                      div.id = ""linklist"";" & vbcrlf & "                                      div.style.cssText = ""z-index:100;position:absolute;top:28px;right:15px;padding:5px;background-color:white;border:5px solid #C6CBD8;min-width:60px;""" & vbcrlf & "                                       var html = """"" & vbcrlf & "                                     for(var i = 0 ; i < f.length ; i++)" & vbcrlf & "                                     {"& vbcrlf &   "                                          var  item = f[i].split(""="")" & vbcrlf &  "                                               html += ""<a onclick='this.parentNode.style.display=\""none\""' href='"" + item[1] + ""' target=_blank>"" + item[0] + ""</a><br>""" & vbcrlf & "                                      }" & vbcrlf & "                                       div.innerHTML = html" & vbcrlf & "                                    document.body.appendChild(div);" & vbcrlf & "                            }" & vbcrlf & "                               else{" & vbcrlf & "                                   div.style.display = ""block"";" & vbcrlf & "                              }" & vbcrlf & "                       }" & vbcrlf & "                       else" & vbcrlf & "                    {" & vbcrlf & "                               //防止部分浏览器下打不开的问题" & vbcrlf & "                          if(f.toLowerCase().indexOf("".asp"")==-1){" & vbcrlf & "                                  var nload = window.location.href.toLowerCase().indexOf(""newload"")>0;" & vbcrlf & "                                      var sysoption = document.getElementById(""sysoption0"");" & vbcrlf & "                                    if (sysoption){" & vbcrlf & "                                         var code = $(sysoption).attr(""key"");" & vbcrlf & "                                              var kid = $(sysoption).val();" & vbcrlf & "                                           switch(code){" & vbcrlf & "                                                     case ""MultiBomImport"" : " & vbcrlf & "                                                          f = f.replace(""/""+code+""."" , ""/""+ code+ kid +""."");" & vbcrlf & "                                                              break;" & vbcrlf & "                                          }" & vbcrlf & "                                       }" & vbcrlf & "                                       window.location.href = (nload?""../"":"""") + ""../out/downfile.asp?fileSpec=""+ escape(f) + ""&nload="" + (nload?1:0);" & vbcrlf &  "                            } else { "& vbcrlf & "                                        window.location.href = f;" & vbcrlf & "                               } "& vbcrlf &  "                      }" & vbcrlf &"                } "& vbcrlf &  "      </script> "& vbcrlf & "       <iframe name='hFrame' id='hFrameId' onload='TestError()' style='width:1px;height:1px;position:absolute;top:3px;left:1px' frameborder=0 onload='var MaxProc=-1'></iframe>" & vbcrlf & "   <iframe name='hFrame' id='showfilefrm' style='width:1px;height:1px;position:absolute;top:-3px;left:1px' frameborder=0 onload='var MaxProc=-1'></iframe>" & vbcrlf & " <div id='bodyDiv' style='margin-top:0px;padding:0'>" & vbcrlf & "               <div  id='billtopbardiv' style='margin:0px'>" & vbcrlf & "                    <table class=full>" & vbcrlf & "                        <tr>" & vbcrlf & "                          <td id=""billtitle"" class=""resetTextColor333"">"
			Response.write att.title
			Response.write "</td>" & vbcrlf & "                                <td>" & vbcrlf & "" & vbcrlf & "                            </td>" & vbcrlf & "                           <td align='right' valign='middle' style='display:table-cell;cursor:default'>" & vbcrlf & "                              "
			Response.write att.title
			if App.isSub("showbutton") then
				call showbutton()
			end if
			if len(att.helpFilePath) > 1 then
				Response.write "" & vbcrlf & "                               <button onClick=""window.open('"
				Response.write att.helpFilePath
				Response.write "','','height=600,width=900,resizable=1,menubar=1,status=0,toolbar=0')"" class=""button"">导入说明</button>"
			end if
			Response.write "&nbsp;"
			if len(att.smpFilePath) > 1 then
				Response.write "" & vbcrlf & "                               <button files='"
				Response.write att.smpFilePath
				Response.write "' onClick=""seesmp(this)"" class=""button"">查看范例</button>" & vbcrlf & "                                  "
			end if
			Response.write "" & vbcrlf & "                               &nbsp;" & vbcrlf & "                                </td>" & vbcrlf & "                           <td width=""3""><img src=""../../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "                     </tr>" & vbcrlf & "           </table>" & vbcrlf & "              </div>" & vbcrlf & "          <div class=""resetBorderColor"" style='border-left:#CCC 1px solid;border-right:#CCC 1px solid;border-bottom:#CCC 1px solid;border-top:0px;padding:10px'>" & vbcrlf & "                  <fieldset class=""resetBorderColor"" style='font-size:12px;border:1px solid #acaccc'><legend style='margin-left:10px'>" & vbcrlf & "                      "
			If InStr(att.title,"修改")>0 then
				Response.write "上传需要修改的"
			else
				Response.write "上传需要导入的"
			end if
			Response.write att.filename
			Response.write "</legend>" & vbcrlf & "                    "
			call app.add_log(2,att.filename& "导入")
			Response.write "" & vbcrlf & "                                     <table style='width:100%;height:70px'>" & vbcrlf & "                                  <tr>" & vbcrlf & "                                            <td style='height:30px;' align=center>" & vbcrlf & "                                                  <table align=center style='overflow:hidden'>" & vbcrlf & "                                                    <tr>" & vbcrlf & "                                                            <td style='height:30px;width:50px;text-align:center;color:#acaccc' valign='middle'>文件：</td>" & vbcrlf & "                                                          <td style='height:30px;width:350px' valign='middle'>" & vbcrlf & "                                                                    <div style='width:100%;height:30px;overflow:hidden;position:relative;top:4px'>" & vbcrlf & "                                                                          <div style='width:55px;float:right;overflow:hidden;position:relative'>" & vbcrlf & "                                                                                    <button class=button style='width:50px' id='llButon'>浏览</button>" & vbcrlf & "                                                                                      <form action='' method='post' enctype=""multipart/form-data"" name='mfrm' id='mfrmid' target='hFrame'>" & vbcrlf & "                                                                                              <input onfocus='' onchange='document.getElementById(""fNameText"").value=this.value' onmouseup='document.getElementById(""llButon"").style.borderColor="""";' onmousedown='document.getElementById(""llButon"").style.borderColor=""#222""' type=file name=file1 style='width:100%;position:absolute;left:0px;overflow:hidden;top:0px;filter:alpha(opacity=0);opacity:0.0; -moz-opacity:0.0'>" & vbcrlf & "                                                                                      </form>" & vbcrlf & "                                                                                </div>" & vbcrlf & "                                                                          <input type='text' id='fNameText' readonly style='color:#333388;width:285px;font-family:宋体;font-size:12px;height:17px;border:#CCC 1px solid;line-height:17px;padding-left:2px'>" & vbcrlf & "                                                                   </div>" & vbcrlf & "                                                          </td>" & vbcrlf & "                                                           <td style='height:50px;width:70px;text-align:center;padding-bottom:3px'>" & vbcrlf & "                                                                        <button class=button style='width:50px;position:relative;top:-1px' id='smbButton' onclick='doSend()'>导入</button>" & vbcrlf & "</td>" & vbcrlf & "                                                   </tr>" & vbcrlf & "                                                   </table>" & vbcrlf & "                                                </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "                                   </table>" & vbcrlf & "                                        <div style='position:relative;left:40px'>" & vbcrlf & "                                       <div style='color:#6666ee;padding:3px;width:auto'>"
			Response.write att.remark
			Response.write " </div>" & vbcrlf & "                                      "
			if att.optioncount >= 0 then
				dim ii , i , itm
				dim index
				index = request.Cookies("curruploadindex")
				if len(index) = 0 or not isnumeric(index) then index = 0
				for i=0 to att.optioncount
					set optobj = att.optionitems(i)
					Response.write "<div style='font-size:12px;color:#000;padding:8px;padding-left:0px'>○&nbsp;" & att.optionitems(i).name & "：<select style='color:red;padding-bottom:2px' id='sysoption" & i & "' key='" & optobj.key &"' onchange='savecurrConfig(""" & optobj.key & """,this.selectedIndex)'>"
					'set optobj = att.optionitems(i)
					for ii = 0 to optobj.count
						itm = optobj.options(ii)
						Response.write "<option " &  app.iif(cint(optobj.selectindex)=cint(ii),"selected","") & " value=""" & itm(1) & """>" & itm(0) & "</option>"
					next
					Response.write "</select>"
					Response.write "</div>"
				next
			end if
			Response.write "" & vbcrlf & "                                     </div>" & vbcrlf & "" & vbcrlf & "                                  <div style='height:20px'></div>" & vbcrlf & "                 </fieldset>" & vbcrlf & "             </div>" & vbcrlf & "          <div class=""resetBgWhite"" style='background-image:url(../../images/m_table_b.jpg);height:40px;'>" & vbcrlf & "                  <table align=center style='position:relative;top:10px;display:none' id='procTable'>" & vbcrlf & "                 <tr>" & vbcrlf & "                            <td valign=bottom style='color:#aaaacc'>处理进度：</td>" & vbcrlf & "                         <td valign=top>" & vbcrlf & "                                 <div style='width:360px;height:12px;background-color:white;;overflow:hidden' id='procBg'>" & vbcrlf & "                                                <div style='width:50px;background-color:#7777ff;filter:wave(phase=0,freq=0,lightStrength=20,Strength=0);height:12px;overflow:hidden;' id='procBar'></div>" & vbcrlf & "                                       </div>" & vbcrlf & "                          </td>" & vbcrlf & "                           <td style='width:100px;height:16px'></td>" & vbcrlf & "                       </tr>" & vbcrlf & "                      <tr>" & vbcrlf & "                            <td colspan=3 align='bottom' style='height:30px;text-align:left;font-family:arial;color:red' id='procText'><span>0%</span></td>" & vbcrlf & "                 </tr>" & vbcrlf & "                   </table>" & vbcrlf & "                </div>" & vbcrlf & "          <div style='height:20px;'></div>" & vbcrlf & "                <div id='ReportList'></div>" & vbcrlf & "   </div>" & vbcrlf & "  </body>" & vbcrlf & " "
			set att = nothing
		end sub
		Sub App_Report
			dim sn , u , n , f , fo , fn , un
			Response.write App.headhtml
			sn = replace(request.querystring("sn"),"'","")
			if len(sn) = 0  then  sn = 0
			if not isnumeric(sn) then sn = 0
			set rs = cn.execute("select savepath,filename,us,(select top 1 [name] from gate where ord=a.us) as uname from dbo.erp_sys_fileInsertReport a where id=" & sn)
			if rs.eof then
				rs.close
				app.showerr "无法访问" , "<span style=color:red>您要访问的文件不存在。</span>"
				exit sub
			else
				u = rs.fields("us").value
				fn = rs.fields("filename").value
				un = rs.fields("uname").value
				f = rs.fields("savepath").value
				set fo = server.createobject("Scripting.filesystemobject")
				if not fo.FileExists(server.mappath(f)) then
					set fo = nothing
					rs.close
					app.showerr "无法访问" , server.mappath(f) & "<span style=color:red>您访问的文件【" & fn & "】已经被删除。<br><br>如有疑问，请联系系统管理员。<span style='width:80px;display:inline-block'></span></span>"
					set fo = nothing
					exit sub
				end if
				set fo = nothing
			end if
			rs.close
			if u <> app.info.user * 1 then
				app.showerr "权限拒绝" , "<span style=color:red>您无法查看用户【" & un & "】所上传文档【" & fn & "】的上传报告。</span>"
				exit sub
			end if
			Response.redirect f
		end sub
		sub App_savecurrConfig
			Response.Cookies("updoptindex" & request.form("key")) = request.form("index")
		end sub
		Sub CreateGetPinYin()
			dim sql
			if cn.execute("select * from sysobjects where name='getPinYin'").eof = false then exit sub
			sql=sql & "CREATE FUNCTION getPinYin (@str varchar(500) = '') " & vbcrlf
			sql=sql & "RETURNS varchar(500) AS " & vbcrlf
			sql=sql & "/*-------------------用于获取中文名称的首字母---------------------------------*/ " & vbcrlf
			sql=sql & "RETURNS varchar(500) AS " & vbcrlf
			sql=sql & "BEGIN " & vbcrlf
			sql=sql & "Declare @strlen int, " & vbcrlf
			sql=sql & "@return varchar(500), " & vbcrlf
			sql=sql & "@ii int, " & vbcrlf
			sql=sql & "@c char(1), " & vbcrlf
			sql=sql & "@chn nchar(1) " & vbcrlf
			sql=sql & "Declare @pytable table( " & vbcrlf
			sql=sql & "chn char(2) COLLATE Chinese_PRC_CS_AS NOT NULL, " & vbcrlf
			sql=sql & "py char(1) COLLATE Chinese_PRC_CS_AS NULL, " & vbcrlf
			sql=sql & "PRIMARY KEY (chn) " & vbcrlf
			sql=sql & ") " & vbcrlf
			sql=sql & "insert into @pytable values('吖', 'A') " & vbcrlf
			sql=sql & "insert into @pytable values('八', 'B') " & vbcrlf
			sql=sql & "insert into @pytable values('嚓', 'C') " & vbcrlf
			sql=sql & "insert into @pytable values('咑', 'D') " & vbcrlf
			sql=sql & "insert into @pytable values('妸', 'E') " & vbcrlf
			sql=sql & "insert into @pytable values('发', 'F') " & vbcrlf
			sql=sql & "insert into @pytable values('旮', 'G') " & vbcrlf
			sql=sql & "insert into @pytable values('铪', 'H') " & vbcrlf
			sql=sql & "insert into @pytable values('丌', 'J') " & vbcrlf
			sql=sql & "insert into @pytable values('咔', 'K') " & vbcrlf
			sql=sql & "insert into @pytable values('垃', 'L') " & vbcrlf
			sql=sql & "insert into @pytable values('嘸', 'M') " & vbcrlf
			sql=sql & "insert into @pytable values('拏', 'N') " & vbcrlf
			sql=sql & "insert into @pytable values('噢', 'O') " & vbcrlf
			sql=sql & "insert into @pytable values('妑', 'P') " & vbcrlf
			sql=sql & "insert into @pytable values('七', 'Q') " & vbcrlf
			sql=sql & "insert into @pytable values('呥', 'R') " & vbcrlf
			sql=sql & "insert into @pytable values('仨', 'S') " & vbcrlf
			sql=sql & "insert into @pytable values('他', 'T') " & vbcrlf
			sql=sql & "insert into @pytable values('屲', 'W') " & vbcrlf
			sql=sql & "insert into @pytable values('夕', 'X') " & vbcrlf
			sql=sql & "insert into @pytable values('丫', 'Y') " & vbcrlf
			sql=sql & "insert into @pytable values('帀', 'Z') " & vbcrlf
			sql=sql & "select @strlen = len(@str), @return = '', @ii = 0 " & vbcrlf
			sql=sql & "while @ii < @strlen " & vbcrlf
			sql=sql & "begin " & vbcrlf
			sql=sql & "select @ii = ii + 1, @chn = substring(@str, @ii, 1) " & vbcrlf
			sql=sql & "begin " & vbcrlf
			sql=sql & "if @chn > 'z' --//检索输入的字符串中有中文字符" & vbcrlf
			sql=sql & "begin " & vbcrlf
			sql=sql & "SELECT @c = max(py) " & vbcrlf
			sql=sql & "FROM @pytable " & vbcrlf
			sql=sql & "where chn <= @chn " & vbcrlf
			sql=sql & "else " & vbcrlf
			sql=sql & "set @c=@chn " & vbcrlf
			sql=sql & "set @return=@return+@c " & vbcrlf
			sql=sql & "set @c=@chn " & vbcrlf
			sql=sql & "end " & vbcrlf
			sql=sql & "return @return " & vbcrlf
			sql=sql & "END" & vbcrlf
			cn.execute sql
		end sub
		Function CreateImportReport(ByRef cn,ByVal db,ByVal folderPath,ByVal fName)
			Dim xApp,i,arrInfo,fpath,j,k
			arrInfo = cn.execute("select * from "&db&" order by 行号").getRows()
			Set xApp = server.createobject(ZBRLibDLLNameSN & ".HtmlExcelApplication")
			xApp.init me, cn
			xApp.SavePath = folderPath
			Set xsheet = xApp.sheets.add("未导入数据报告")
			xsheet.showHeader "行号,失败原因"
			xsheet.movenext
			j = 1
			k = ubound(arrInfo,2)
			For i = 0 To k
				xsheet.writecell arrInfo(0,i)
				xsheet.writecell arrInfo(1,i)
				If (i + 1) Mod REC_PER_SHEET_IN_IMPORT_REPORT = 0 And i < k Then
					xsheet.writecell arrInfo(1,i)
					Set xsheet = xApp.sheets.add("未导入数据报告"&j)
					xsheet.showHeader "行号,失败原因"
					xsheet.movenext
					j=j+1
					xsheet.movenext
				else
					xsheet.movenext
				end if
			next
			fpath = folderPath & "\" & fName
			xApp.save fpath
			xApp.Dispose
			CreateImportReport = xApp.HexEncode(fpath)
			Set xApp = Nothing
		end function
		Sub App_updateTag
			Dim data : data =  request.form("tag")
			Dim aoo, vrp
			Set aoo = server.createobject(ZBRLibDLLNameSN & ".PageClass")
			aoo.init Me
			vrp = aoo.virpath
			aoo.sdk.file.CreateFolder vrp & "load\newload\temp"
			aoo.sdk.file.WriteAllText vrp & "load\newload\temp\upload.tag." & app.Info.User & ".tmp", data
			Set aoo = nothing
		end sub
		Function getUpdateTag
			Dim aoo, vrp
			Set aoo = server.createobject(ZBRLibDLLNameSN & ".PageClass")
			aoo.init Me
			vrp = aoo.virpath
			getUpdateTag = aoo.sdk.file.ReadAllText(vrp & "load\newload\temp\upload.tag." & app.Info.User & ".tmp")
			Set aoo = nothing
		end function
		
		sub error(message)
			Response.write "" & vbcrlf & "<script>alert('"
			Response.write message
			Response.write "');</script>" & vbcrlf & ""
		end sub
		Function autoSkipSort(ord,sort,sort1,reason,reasonid,nosortmode,intro)
			Dim presort,presort1,gate2,tgate2
			Dim f_rs,n
			n=0
			Dim mustcontent,mustrole,mustzdy,mustkz_zdy,Aend,autonext,autonext1
			Dim amustcontent,amustrole,amustzdy,amustkz_zdy,mustContentType
			Dim mustcon_tip
			Aend=0
			If Len(ord&"")=0 Then ord=0
			If Len(sort&"")=0 Then sort=0
			If Len(sort1&"")=0 Then sort1=0
			Set f_rs=cn.execute("select sort,sort1 from tel where ord="&ord)
			If f_rs.eof=False Then
				presort=f_rs(0).value
				presort1=f_rs(1).value
			else
				presort=0 : presort1=0 : autoSkipSort=False : Exit function
			end if
			f_rs.close : Set f_rs=Nothing
			If nosortmode Then
				sort=presort : sort1=presort1
			end if
			Set f_rs=cn.execute("select isnull(gate2,0) from sort5 where sort1="&sort&" and ord="&sort1)
			If f_rs.eof=False Then
				gate2=f_rs(0).value
			else
				gate2=0
			end if
			f_rs.close : Set f_rs=Nothing
			If Len(sort&"")=0 Or sort="0" Or Len(sort1&"")=0 Or sort1="0" Then
				Call saveSort5change(ord,presort,presort1,reason,reasonid,intro)
				Exit Function
			end if
			Set f_rs=cn.execute("select (case when ord=(select top 1 ord from sort5 where sort1="&sort&" order by gate2) then isnull(autonext,0) else isnull((select top 1 autonext from sort5 c where gate2<=sort5.gate2 and sort1="&sort&" and ord<>sort5.ord order by gate2 desc),0) end) as autonext1,* from sort5 where sort1="&sort&" order by gate2 desc")
			Do While Not f_rs.eof
				mustcontent="" : mustrole="" : mustzdy="" : mustkz_zdy="" : autonext=""
				mustcontent=f_rs("mustContent")
				mustrole=f_rs("mustRole")
				mustzdy=f_rs("mustzdy")
				mustkz_zdy=f_rs("mustkz_zdy")
				mustHas=f_rs("mustHas")
				autonext=f_rs("autonext")
				If Len(autonext&"")=0 Or isnumeric(autonext)=False Then autonext=0
				autonext1=f_rs("autonext1")
				If Len(autonext1&"")=0 Or isnumeric(autonext1)=False Then autonext1=0
				mustContentType=f_rs("mustContentType")
				sort1=f_rs("ord")
				tgate2=f_rs("gate2")
				If Len(tgate2&"")=0 Or isnumeric(tgate2)=False Then tgate2=0
				If Len(sort1&"")=0 Then sort1=0
				If Len(mustContentType&"")=0 Then mustContentType=0
				If mustContentType=2 Or mustContentType=1 then
					amustcontent=patchrep(amustcontent,mustcontent)
					amustrole=patchrep(amustrole,mustrole)
					amustzdy=patchrep(amustzdy,mustzdy)
					amustkz_zdy=patchrep(amustkz_zdy,mustkz_zdy)
				end if
				If tgate2<=gate2 Then
					If Aend=1 Then
						If autonext<>"1" Then
							autoSkipSort=True
							Exit Function
						end if
					else
						If autonext1<>"1" Then n=-1
						Exit Function
					end if
					If mustContentType=2 Then
						mustcon_tip=0 : mustcon_tip=checkmustcontent(amustcontent,amustrole,ord)
						If Aend=0 Then
							If mustcon_tip=0 And checkrole(amustrole,amustcontent,ord)=True And checkzdy(amustzdy,ord)=True And checkkz_zdy(amustkz_zdy,ord)=True Then
								Call saveSort5change(ord,sort,sort1,reason,reasonid,intro) : presort1=sort1
								Aend=1
							else
								If sort&""<>presort&"" Or sort1&""<>presort1&"" Then
									autoSkipSort=False
									Exit Do
									Exit Function
								else
									Call saveSort5change(ord,sort,sort1,reason,reasonid,intro)  : presort1=sort1 : Aend=1
								end if
							end if
						ElseIf Aend=1 Then
							If mustcon_tip=0 And checkrole(amustrole,amustcontent,ord)=True And checkzdy(amustzdy,ord)=True And checkkz_zdy(amustkz_zdy,ord)=True Then
								Call saveSort5change(ord,sort,sort1,0,0,"系统自动跳转") : presort1=sort1
							else
								autoSkipSort=True
								Exit Function
							end if
						end if
					ElseIf mustContentType=1 Then
						If Aend=0 Then
							If checkmustcontent(mustcontent,mustrole,ord)=0 And checkrole(mustrole,mustcontent,ord)=True And checkzdy(mustzdy,ord)=True And checkkz_zdy(mustkz_zdy,ord)=True Then
								Call saveSort5change(ord,sort,sort1,reason,reasonid,intro)  : presort1=sort1 : Aend=1
							else
								If sort&""<>presort&"" Or sort1&""<>presort1&"" Then
									autoSkipSort=False
									Exit do
									Exit Function
								else
									Call saveSort5change(ord,sort,sort1,reason,reasonid,intro)  : presort1=sort1 : Aend=1
								end if
							end if
						ElseIf Aend=1 Then
							If checkmustcontent(mustcontent,mustrole,ord)=0 And checkrole(mustrole,mustcontent,ord)=True And checkzdy(mustzdy,ord)=True And checkkz_zdy(mustkz_zdy,ord)=True Then
								Call saveSort5change(ord,sort,sort1,0,0,"系统自动跳转") : presort1=sort1
							else
								autoSkipSort=True : Exit Function
							end if
						end if
					Else
						If Aend=0 Then
							Call saveSort5change(ord,sort,sort1,reason,reasonid,intro)  : presort1=sort1 : Aend=1
						else
							Call saveSort5change(ord,sort,sort1,0,0,"系统自动跳转")  : presort1=sort1
						end if
					end if
					If n=-1 Then
						Call saveSort5change(ord,sort,sort1,0,0,"系统自动跳转")  : presort1=sort1
						autoSkipSort=True
						Exit Do
						Exit Function
					end if
				end if
				f_rs.movenext
			Loop
		end function
		Function getnextsort(sort,sort1)
			Dim Frs,Fsql
			Set Frs=cn.execute("select * from sort5 where sort1="&sort&" and ord<>" & sort1 & " and gate2<=(select gate2 from sort5 where sort1="&sort&" and ord="&sort1&") order by gate2 desc")
			If Frs.eof=False Then
				getnextsort=Frs("ord")
			else
				getnextsort=0
			end if
			Frs.close : Set Frs=nothing
		end function
		Function saveSort5change(ord,sort,sort1,reason,reasonid,Fintro)
			Dim Frs,Fsql
			Dim sort3,presort,presort1,perdays,cateid,cateid2,cateid3,replynum,state
			Set Frs=cn.execute("select top 1 * from tel where del=1 and ord=" & ord)
			If Frs.eof=False Then
				sort3=IIF(Frs("sort3")="2",2,1)
				presort=Frs("sort")
				presort=IIF(Len(presort&"")>0,presort,0)
				presort1=Frs("sort1")
				presort1=IIF(Len(presort1&"")>0,presort1,0)
				cateid=Frs("cateid")
				cateid2=Frs("cateid2")
				cateid3=Frs("cateid3")
				state=getstate(presort,presort1,sort,sort1,ord)
				date2=Frs("date2")
				Frs.close
				Set Frs=Nothing
				Fsql="insert into tel_sort_change_log(tord,sort3,preSort,preSort1,newSort,newSort1,cateid,cateid2,cateid3,reason,reasonid,intro,state,date2,date7,cateadd) " & _
				" values(" & ord & "," & sort3 & ",'" & presort & "','" & presort1 & "','" & sort & "','" & sort1 & "','" & cateid & "','" & cateid2 & "','" & cateid3 & "','" & reason & "','" & reasonid & "','" & Fintro & "','" & state & "',"
				If date2&""="" Then
					Fsql= Fsql &"NULL,'" & now & "'," & session("personzbintel2007") & ")"
				else
					Fsql= Fsql &"'" & date2 & "','" & now & "'," & session("personzbintel2007") & ")"
				end if
				cn.execute(Fsql)
				Fsql="update tel set sort1="&sort1&", sort=" & sort & " where ord=" & ord
				cn.execute(Fsql)
			else
				Frs.close : Set Frs=nothing
			end if
		end function
		Function getstate(psort,psort1,nsort,nsort1,ord)
			If psort&""<>nsort&"" Then
				cn.cursorLocation=3
				cn.execute("if OBJECT_ID('sort4_" & session("personzbintel2007") & "') is not null drop table sort4_" & session("personzbintel2007") & "")
				cn.execute("select identity(int,1,1) as id1,ord into sort4_" & session("personzbintel2007") & " from sort4 order by gate1 desc")
				Set f_rs=cn.execute("select top 1 * from sort4_" & session("personzbintel2007") & " where (select id1 from sort4_" & session("personzbintel2007") & " where ord=" & nsort & ")>(select id1 from sort4_" & session("personzbintel2007") & " where ord=" & psort & ")" )
				If f_rs.eof=false Then
					getstate=1
				else
					getstate=-1
					getstate=1
				end if
				Exit Function
			end if
			if psort1&""=nsort1&"" then getstate=0 : exit function
			If Len(psort&"")=0 Then psort=0
			If Len(psort1&"")=0 Then psort1=0
			If Len(nsort1&"")=0 Then nsort1=0
			cn.cursorLocation=3
			cn.execute("if OBJECT_ID('sort5_" & session("personzbintel2007") & "') is not null drop table sort5_" & session("personzbintel2007") & "")
			cn.execute("select identity(int,1,1) as id1,ord,sort1 into sort5_" & session("personzbintel2007") & " from sort5 where sort1=" & psort & " order by gate2 desc")
			Set f_rs=cn.execute("select top 1 isnull(sort1,0) as sort,isnull(ord,0) as sort1 from sort5_" & session("personzbintel2007") & " where (select id1 from sort5_" & session("personzbintel2007") & " where ord=" & nsort1 & ")>(select id1 from sort5_" & session("personzbintel2007") & " where ord=" & psort1 & ")" )
			If f_rs.eof=false Then
				getstate=1
			else
				getstate=-1
				getstate=1
			end if
			f_rs.close : Set f_rs=Nothing
		end function
		Function checkkz_zdy(mustcon,tord)
			Dim v,vi
			checkkz_zdy=True
			v=mustcon : If Len(v&"")=0 Then v=""
			v=Replace(v," ","")
			If v<>"" Then
				v=Split(v,",")
				For vi=0 To ubound(v)
					If isnumeric(v(vi)) Then
						If cn.execute("select top 1 1 from ERP_CustomValues where FieldsId=" & v(vi) & " and OrderId=" & tord & " and isnull(Fvalue,'')<>''").eof=True Then checkkz_zdy=False : Exit For : Exit Function
					end if
				next
			end if
		end function
		Function checkzdy(mustcon,tord)
			Dim v,vi
			checkzdy=True
			v=mustcon : If Len(v&"")=0 Then v=""
			v=Replace(v," ","")
			If v<>"" Then
				v=Split(v,",")
				For vi=0 To ubound(v)
					If isnumeric(v(vi)) Then
						If cn.execute("select top 1 1 from tel where isnull(zdy" & v(vi) & ",'')<>'' and del=1 and ord=" & tord ).eof=True   Then checkzdy=False : Exit For : Exit Function
					end if
				next
			end if
		end function
		Function checkrole(mustcon1,mustcon2,tord)
			If Len(mustcon1&"")=0 Then checkrole=True : Exit Function
			Dim v,i,n,s
			v=mustcon1
			If Len(v&"")=0 Then v=0
			v=Split(v,",")
			s=False
			For i=0 To ubound(v)
				n=Trim(v(i))
				If Len(n&"")=0 Or isnumeric(n)=False Then n=0
				If InStr(1,","&mustcon2&",",",96,",1)>0 Then
					If cn.execute("select top 1 1 from person where isnull(role,0)>0 and role=" & n & " and del=1 and company=" & tord &" and ord in(select ord2 from reply where sort1=8 and del=1)").eof=False  Then
						s=True
					else
						s=False
						Exit for
					end if
				else
					If cn.execute("select top 1 1 from person where isnull(role,0)>0 and role=" & n & " and del=1 and company=" & tord ).eof=False  Then
						s=True
					else
						s=False
						Exit for
					end if
				end if
			next
			checkrole=s
		end function
		Function checkmustcontent(mustcon,mustrole,tord)
			checkmustcontent=0
			If InStr(1,","&mustcon&",",",6,",1)>0 Then
				If cn.execute("select top 1 1 from tel where isnull(ly,0)>0 and del=1 and ord="&tord).eof=True Then checkmustcontent=6 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",7,",1)>0 Then
				If cn.execute("select top 1 1 from tel where isnull(area,0)>0 and del=1 and ord="&tord).eof=True Then checkmustcontent=7 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",8,",1)>0 Then
				If cn.execute("select top 1 1 from tel where isnull(trade,0)>0 and del=1 and ord="&tord).eof=True Then checkmustcontent=8 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",9,",1)>0 Then
				If cn.execute("select top 1 1 from tel where isnull(jz,0)>0 and del=1 and ord="&tord).eof=True Then checkmustcontent=9 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",10,",1)>0 Then
				If cn.execute("select top 1 1 from tel where len(isnull(url,''))>0 and del=1 and ord="&tord).eof=True Then checkmustcontent=10 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",11,",1)>0 Then
				If cn.execute("select top 1 1 from tel where isnull(hk_xz,0)>0 and del=1 and ord="&tord).eof=True Then checkmustcontent=11 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",12,",1)>0 Then
				If cn.execute("select top 1 1 from tel where len(isnull(address,''))>0 and del=1 and ord="&tord).eof=True Then checkmustcontent=12 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",13,",1)>0 Then
				If cn.execute("select top 1 1 from tel where len(isnull(zip,''))>0 and del=1 and ord="&tord).eof=True Then checkmustcontent=13 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",14,",1)>0 Then
				If cn.execute("select top 1 1 from tel where (len(isnull(faren,''))>0 or sort2=2) and del=1 and ord="&tord).eof=True Then checkmustcontent=14 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",15,",1)>0 Then
				If cn.execute("select top 1 1 from tel where (isnull(zijin,0)>0 or sort2=2) and del=1 and ord="&tord).eof=True Then checkmustcontent=15 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",93,",1)>0 Then
				If cn.execute("select top 1 1 from tel where len(isnull(phone,''))>0 and del=1 and ord="&tord).eof=True Then checkmustcontent=93 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",94,",1)>0 Then
				If cn.execute("select top 1 1 from tel where len(isnull(fax,''))>0 and del=1 and ord="&tord).eof=True Then checkmustcontent=94 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",95,",1)>0 Then
				If cn.execute("select top 1 1 from tel where len(isnull(email,''))>0 and del=1 and ord="&tord).eof=True Then checkmustcontent=95 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",92,",1)>0 Then
				If cn.execute("select top 1 1 from person where del=1 and company="&tord).eof=True Then checkmustcontent=92 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",25,",1)>0 Then
				If cn.execute("select top 1 1 from person where len(isnull(jg,''))>0 and del=1 and company="&tord).eof=True Then checkmustcontent=25 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",27,",1)>0 Then
				If cn.execute("select top 1 1 from person where len(isnull(part1,''))>0 and del=1 and company="&tord).eof=True Then checkmustcontent=27 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",28,",1)>0 Then
				If cn.execute("select top 1 1 from person where len(isnull(job,''))>0 and del=1 and company="&tord).eof=True Then checkmustcontent=28 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",19,",1)>0 Then
				If cn.execute("select top 1 1 from person where len(isnull(phone,''))>0 and del=1 and company="& tord ).eof=True Then checkmustcontent=19 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",18,",1)>0 Then
				If cn.execute("select top 1 1 from person where len(isnull(phone2,''))>0 and del=1 and company="& tord ).eof=True Then checkmustcontent=18 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",20,",1)>0 Then
				If cn.execute("select top 1 1 from person where len(isnull(mobile,''))>0 and del=1 and company="& tord ).eof=True Then checkmustcontent=20 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",21,",1)>0 Then
				If cn.execute("select top 1 1 from person where len(isnull(fax,''))>0 and del=1 and company="& tord ).eof=True Then checkmustcontent=21 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",22,",1)>0 Then
				If cn.execute("select top 1 1 from person where len(isnull(email,''))>0 and del=1 and company="& tord ).eof=True Then checkmustcontent=22 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",23,",1)>0 Then
				If cn.execute("select top 1 1 from person where len(isnull(qq,''))>0 and del=1 and company="& tord ).eof=True Then checkmustcontent=23 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",24,",1)>0 Then
				If cn.execute("select top 1 1 from person where len(isnull(msn,''))>0 and del=1 and company="& tord ).eof=True Then checkmustcontent=24 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",96,",1)>0 Then
				If Len(mustrole)>0 Then
					arrRole=Split(mustrole,",")
					For i=0 To ubound(arrRole)
						If cn.execute("select top 1 1 from reply where del=1 and sort1=8 and ord2=(select top 1 ord from person where del=1 and role='"&arrRole(i)&"' and company="& tord &") and ord=" & tord).eof=True Then
							checkmustcontent=96
							Exit Function
						end if
					next
				ElseIf InStr(1,","&mustcon&",",",92,",1)>0 Then
					If cn.execute("select top 1 1 from reply where del=1 and sort1=8 and ord2=(select top 1 ord from person where del=1 and company="& tord &") and ord=" & tord).eof=True Then checkmustcontent=96 : Exit Function
				else
					If cn.execute("select top 1 1 from reply where del=1 and cateid=(select top 1 cateid from tel where ord="&tord&") and ord=" & tord).eof=True Then checkmustcontent=96 : Exit Function
				end if
			end if
			If InStr(1,","&mustcon&",",",97,",1)>0 Then
				If cn.execute("select top 1 1 from chance where isnull(sp,0)=0 and cateid=(select top 1 cateid from tel where ord="&tord&") and del=1 and charindex('," & tord & ",',','+company+',')>0").eof=True Then checkmustcontent=97 : Exit Function
'If InStr(1,","&mustcon&",",",97,",1)>0 Then
			end if
			If InStr(1,","&mustcon&",",",98,",1)>0 Then
				If cn.execute("select top 1 1 from price where isnull(complete,0)=4 and cateid=(select top 1 cateid from tel where ord="&tord&") and del=1 and company=" & tord ).eof=True Then checkmustcontent=98 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",99,",1)>0 Then
				If cn.execute("select top 1 1 from contract where isnull(sp,0)=0 and cateid=(select top 1 cateid from tel where ord="&tord&") and del=1 and company=" & tord ).eof=True Then checkmustcontent=99 : Exit Function
			end if
			If InStr(1,","&mustcon&",",",100,",1)>0 Then
				If cn.execute("select top 1 1 from tousu where del=1 and cateid=(select top 1 cateid from tel where ord="&tord&") and company=" & tord ).eof=True Then checkmustcontent=100 : Exit Function
			end if
		end function
		Function patchrep(strs,str1)
			Dim allstr,tstr,f_i
			If Len(str1&"")=0 Then patchrep=strs : Exit Function
			If Len(strs&"")=0 Then patchrep=str1 : Exit Function
			allstr = strs & "," & str1
			allstr = Replace(allstr," ","")
			tstr = Split(allstr,",")
			allstr=""
			For f_i=0 To ubound(tstr)
				If InStr(1,"," & allstr & ",","," & tstr(f_i) & ",",1)=0 Then
					If allstr="" then
						allstr=tstr(f_i)
					else
						allstr=allstr & "," &tstr(f_i)
					end if
				end if
			next
			patchrep=allstr
		end function
		function IIF(cv,ov1,ov2)
			if cv then
				IIF=ov1
			else
				IIF=ov2
			end if
		end function
		Function getInt(str)
			if str="" or isNull(str) or not IsNumeric(str) then
				getInt=0
			else
				getInt=str
			end if
		end function
		
		sub page_init
			app.vpath = "../../manufacture/inc/"
			cn.cursorlocation = 3
		end sub
		Sub GetDefFieldName(ByRef arrShow, ByRef arrName,ByRef arrRequired)
			SqlStr="select * from ( "&_
			" select (case when isnull(name,'')='' then oldname else name end ) as name, "&_
			"(case when show>0 then 1 else 0 end) as show,required,gate1 "&_
			" from setfields "&_
			"union all "&_
			"select title,1,1,gate1+1000 "&_
			" from zdy "&_
			" where sort1=1 and set_open=1 and dr=1 and bt=1 "&_
			"union all "&_
			"select '账期',1,0,10001 "&_
			"union all "&_
			"select '结算日期',1,0,10002 "&_
			"union all "&_
			"select '添加人员',1,0,10004 "&_
			") a order by gate1 asc "
			Set rs=cn.execute(SqlStr)
			ReDim arrShow(0)
			ReDim arrName(0)
			ReDim arrRequired(0)
			While Not rs.eof
				intgate1=rs("gate1")
				redim Preserve arrShow(intgate1)
				redim Preserve arrName(intgate1)
				ReDim Preserve arrRequired(intgate1)
				arrShow(intgate1)=rs("show")
				if rs("name")&""="到款限制" then
					arrName(intgate1)=Replace(rs("name")&"(%)"," ","")&""
				else
					arrName(intgate1)=Replace(rs("name")," ","")
				end if
				arrRequired(intgate1)=rs("required")
				rs.movenext
			wend
			rs.close
		end sub
		Sub showbutton
			Dim pageurl
			pageurl=request.ServerVariables("URL")
			If InStr(pageurl,"replydr.asp")=0 Then
				Response.write "<button onclick='location.href=""replydr.asp"";' class=""button"" style='width:100px'>洽谈进展导入</button>&nbsp;&nbsp;"
			else
				Response.write "<button onclick='location.href=""kfdr.asp"";' class=""button"" style='width:80px'>客户导入</button>&nbsp;&nbsp;"
			end if
		end sub
		sub Page_loadConfig(uploadatt)
			dim opt
			with uploadatt
			.title = "客户资料导入"
			.fileName = "客户资料"
			.filters = "xls|xlsx"
			.helpFilePath = "../../in/caption.doc"
			.smpFilePath = "../../in/example.asp"
			.remark = "待传文件必须是EXCEL格式，请确认字段格式与数据库字段完全对应。"
			.autosave = true
			.allowSize = 200*1024*1024
			.modelCls = "客户资料"
			end With
			Dim arrShow, arrName,arrRequired
			Call GetDefFieldName(arrShow, arrName,arrRequired)
			set opt = uploadatt.addOption()
			opt.selectindex = 14
			opt.key = "kfdr"
			opt.name = "客户重复判断规则"
			call opt.add("不判断重复" , 0)
			If arrShow(1)=1 Then call opt.add(arrName(1)&"相同" , 1)
			If arrShow(3)=1 Then call opt.add(arrName(3)&"相同" , 2)
			If arrShow(19)=1 Then call opt.add(arrName(19)&"相同" , 3)
			If arrShow(20)=1 And arrShow(17)=1 Then call opt.add(arrName(20)&"相同 且 有"&arrName(17) , 4)
			If arrShow(1)=1 And arrShow(19)=1 Then call opt.add(arrName(1)&"和"&arrName(19)&"都相同" , 5)
			If arrShow(1)=1 And arrShow(20)=1 Then call opt.add(arrName(1)&"和"&arrName(20)&"都相同" , 6)
			If arrShow(1)=1 And arrShow(3)=1 Then call opt.add(arrName(1)&"和"&arrName(3)&"都相同" , 7)
			If arrShow(1)=1 Then call opt.add(arrName(1)&"和销售人员都相同" , 8)
			If arrShow(1)=1 And arrShow(20)=1 Then call opt.add(arrName(1)&"相同 或 "&arrName(20)&"相同" , 9)
			If arrShow(1)=1 And arrShow(19)=1 Then call opt.add(arrName(1)&"相同 或 "&arrName(19)&"相同" , 10)
			If arrShow(1)=1 And arrShow(19)=1 And arrShow(20)=1 Then call opt.add(arrName(1)&"、"&arrName(19)&"、"&arrName(20)&"都相同" , 11)
			If arrShow(1)=1 And arrShow(19)=1 And arrShow(20)=1 Then call opt.add(arrName(1)&"、"&arrName(19)&"、"&arrName(20)&"任意一项相同" , 12)
			If arrShow(1)=1 And arrShow(19)=1 And arrShow(20)=1 Then call opt.add(arrName(1)&"相同 或 "&arrName(19)&"与"&arrName(20)&"相同" , 13)
			If arrShow(1)=1 And arrShow(19)=1 And arrShow(20)=1 Then call opt.add(arrName(1)&"与"&arrName(19)&"相同 或 "&arrName(20)&"相同" , 14)
			if len(request.querystring("__msgId")) = 0 then
				if cn.execute("select top 1 [name] from syscolumns where name='person_excel_drSign'").eof then
					cn.execute "ALTER TABLE person ADD person_excel_drSign bigint NULL"
					cn.execute "ALTER TABLE person ADD person_excel_drUser int NULL"
					cn.execute "ALTER TABLE person_his ADD person_excel_drSign bigint NULL"
					cn.execute "ALTER TABLE person_his ADD person_excel_drUser int NULL"
				end if
				if cn.execute("select top 1 [name] from syscolumns where name='tel_excel_drSign'").eof then
					cn.execute "ALTER TABLE tel ADD tel_excel_drSign bigint NULL"
					cn.execute "ALTER TABLE tel ADD tel_excel_drUser int NULL"
					cn.execute "ALTER TABLE tel_his ADD tel_excel_drSign bigint NULL"
					cn.execute "ALTER TABLE tel_his ADD tel_excel_drUser int NULL"
				end if
			end if
		end sub
		function Page_InsertDataBase(dbname , uploader)
			dim n, n1 , sql , i , n2 , n3 , maxord , maxord2 , rType , usid
			dim t_ord1 , t_ord2, kxrs, fname
			Set kxrs=cn.execute("select top 0 *  from "&dbname)
			For i = 0 To kxrs.fields.count - 1
				Set kxrs=cn.execute("select top 0 *  from "&dbname)
				fname = kxrs.fields(i).name
				If cn.execute("select count(1) from "&dbname&" where isnumeric(cast(["&fname&"] as varchar(32)))=1 and charindex('e+',cast(["&fname&"] as varchar(4000)))>0")(0)>0 Then
					fname = kxrs.fields(i).name
					Response.write "<script>alert('导入失败：导入文档中列【"&fname&"】中存在超过8位的数字，请设置列的格式为文本格式后再导入！');</script>"
					Exit Function
				end if
			next
			kxrs.close
			call uploader.RegRptItem("#k_all","导入报告")
			call uploader.RegRptItem("#k_fail","未导入报告")
			call uploader.RegRptItem("#k_flink","无效关联数据")
			usid = app.info.user
			if usid = 0 then
				Response.write "<script>alert('登录超时，请重新登录!');</script>"
				exit function
			end if
			Dim arrShow, arrName,arrRequired,khName,khlxr,khphone,khmobile
			Call GetDefFieldName(arrShow, arrName,arrRequired)
			khName=arrName(1)
			khlxr=arrName(17)
			khphone=arrName(19)
			khmobile=arrName(20)
			rType =  request.querystring("sysoption0")
			cn.execute "create table #k_fail (行号 int, 失败原因 varchar(300))"
			cn.execute "create table #k_all (序号 int  IDENTITY(1,1) not null,内容 varchar(300), 说明 varchar(300))"
			uploader.ShowProc "写入客户资料：初始化导入记录            进度：" , 0
			cn.execute "insert into #k_all (内容) values ('初始化获取有效记录" & cn.execute("select count(*) from "& dbname ).fields(0).value & "条')"
			uploader.ShowProc "写入客户资料：删除空数据                进度：" , 100
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&khName&"为空' from #kfdrList where  len(isnull(replace(["&khName&"],' ',''),'')) = 0 and len(isnull(["&khlxr&"],''))=0"
			cn.execute "delete from #kfdrList where  len(isnull(replace(["&khName&"],' ',''),'')) = 0 and len(isnull(["&khlxr&"],''))=0" , n
			cn.execute "insert into #k_all  (内容)  values ('从导入文件删除" & n & "条空数据')"
			n = 0
			uploader.ShowProc "写入客户资料：删除无效扩展自定义数据            进度：" , 150
			set rs_kz_zdy=server.CreateObject("adodb.recordset")
			kz_sql="select id,FName,Ftype,MustFillin from erp_customFields  where TName=1  and IsUsing=1 and canInport=1 order by FOrder desc "
			rs_kz_zdy.open kz_sql,cn,2,3
			set rs_kz_zdy=cn.execute(kz_sql)
			If rs_kz_zdy.eof = False Then
				do while not rs_kz_zdy.eof
					kz_id=rs_kz_zdy("id")
					kz_fname=rs_kz_zdy("fname")
					kz_Ftype=rs_kz_zdy("ftype")
					kz_mustfillin=rs_kz_zdy("MustFillin")
					Ins_Kong_Sql="insert into #k_fail(行号,失败原因) select up_index,'客户扩展自定义字段【"&kz_fname&"】为空,必填' from #kfdrList " _
					& " where  len(isnull(rtrim(["&khName&"]),'')) > 0 and len(isnull(rtrim(cast(["&kz_fname&"] as varchar(100))),''))=0 "
					Del_Kong_Sql="delete from #kfdrList where len(isnull(rtrim(["&khName&"]),'')) > 0 and len(isnull(rtrim(cast(["&kz_fname&"] as varchar(100))),''))=0 "
					If kz_Ftype=1 or kz_Ftype=2 then
						if kz_mustfillin=true then
							cn.execute(Ins_Kong_Sql)
							cn.execute Del_Kong_Sql , i  :  n = n + i
							cn.execute(Ins_Kong_Sql)
						end if
					ElseIf kz_Ftype=3 then
						if kz_mustfillin=true then
							cn.execute("insert into #k_fail(行号,失败原因) select up_index,'客户扩展自定义字段【"&kz_fname&"】不是日期,需日期类型' from #kfdrList where  len(isnull(rtrim(["&khName&"]),'')) > 0 and ISDATE(cast(["&kz_fname&"] as varchar(100)))=0")
							cn.execute "delete from #kfdrList where len(isnull(rtrim(["&khName&"]),'')) > 0 and (cast(["&kz_fname&"] as varchar(100))='' or ISDATE(cast(["&kz_fname&"] as varchar(100)))=0)" , i  :  n = n + i
						else
							cn.execute("update #kfdrList set ["&kz_fname&"]='' where len(isnull(rtrim(["&khName&"]),'')) > 0 and (cast(["&kz_fname&"] as varchar(100))='' or ISDATE(cast(["&kz_fname&"] as varchar(100)))=0)")
						end if
					ElseIf kz_Ftype=4 then
						if kz_mustfillin=true Then
							Ins_Kong_Sql="insert into #k_fail(行号,失败原因) select up_index,'客户扩展自定义字段【"&kz_fname&"】不是数字,需数字类型' from #kfdrList where len(isnull(rtrim(["&khName&"]),'')) > 0 and ISNUMERIC(cast(["&kz_fname&"] as varchar(32)))=0"
							Del_Kong_Sql="delete from #kfdrList where len(isnull(rtrim(["&khName&"]),'')) > 0 and (cast(["&kz_fname&"] as varchar(100))='' or ISNUMERIC(cast(["&kz_fname&"] as varchar(32)))=0)"
							cn.execute(Ins_Kong_Sql)
							cn.execute Del_Kong_Sql , i  :  n = n + i
							cn.execute(Ins_Kong_Sql)
						else
							cn.execute("update #kfdrList set ["&kz_fname&"]='0' where len(isnull(rtrim(["&khName&"]),'')) > 0 and (cast(["&kz_fname&"] as varchar(10))='' or ISNUMERIC(cast(["&kz_fname&"] as varchar(32)))='0')")
						end if
					ElseIf kz_Ftype=6 then
						Ins_Sql="insert into #k_fail(行号,失败原因) select up_index,'客户扩展自定义字段【"&kz_fname&"】,必需为是或否' from #kfdrList  where len(isnull(rtrim(["&khName&"]),'')) > 0 and cast(["&kz_fname&"] as varchar(100)) not in ('是','否') "
						uploader.ShowProc Ins_Sql&"：" , 160
						Del_Sql="delete from #kfdrList where len(isnull(rtrim(["&khName&"]),'')) > 0 and cast(["&kz_fname&"] as varchar(100)) not in ('是','否')"
						cn.execute(Ins_Sql)
						cn.execute Del_Sql , i  :  n = n + i
						cn.execute(Ins_Sql)
					ElseIf kz_Ftype=7 then
						Ins_Sql="insert into #k_fail(行号,失败原因) select up_index,'客户扩展自定义字段【"&kz_fname&"】,必需是自定义字段里的一项' from #kfdrList  where len(isnull(rtrim(["&khName&"]),'')) > 0 and not exists (select 1 from erp_customOptions where cvalue=cast(["&kz_fname&"] as varchar(1000)) ) and cast(["&kz_fname&"] as varchar(12))<>'' "
						Del_Sql="delete from #kfdrList where len(isnull(rtrim(["&khName&"]),'')) > 0 and not exists (select * from erp_customOptions where cvalue=cast(["&kz_fname&"] as varchar(1000))) and cast(["&kz_fname&"] as varchar(12))<>'' "
						cn.execute(Ins_Sql)
						cn.execute Del_Sql , i  :  n = n + i
						cn.execute(Ins_Sql)
					end if
					rs_kz_zdy.movenext
				Loop
				cn.execute "insert into #k_all  (内容) values ('从导入文件删除" & n & "条客户扩展自定义字段不匹配的数据,请参见字段策略设置')"
			end if
			rs_kz_zdy.close
			set rs_kz_zdy=Nothing
			n = 0
			Dim countR
			For countR=0 To ubound(arrRequired)
				If arrShow(countR)>0 And arrRequired(countR)>0 And countR<>18 And countR<>25 Then
					If countR>=17 And countR<=32 Then
						cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(countR)&" 是必填字段,不能为空,无法导入。' from #kfdrList where len(isnull(cast(["&arrName(countR)&"] as varchar(500)),''))=0 "
						cn.execute "delete from #kfdrList where len(isnull(cast(["&arrName(countR)&"] as varchar(500)),''))=0 ", i
						cn.execute "insert into #k_all  (内容) values ('从导入文件删除" & i & "条"&arrName(countR)&" 为空数据,请参见字段策略设置')"
					else
						cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(countR)&" 是必填字段,不能为空,无法导入。' from #kfdrList where len(isnull(cast(["&arrName(countR)&"] as varchar(500)),''))=0 and len(isnull(["&khName&"],'')) > 0"
						cn.execute "delete from #kfdrList where len(isnull(cast(["&arrName(countR)&"] as varchar(500)),''))=0 and len(isnull(["&khName&"],'')) > 0", i
						cn.execute "insert into #k_all  (内容) values ('从导入文件删除" & i & "条"&arrName(countR)&" 为空数据,请参见字段策略设置')"
					end if
				end if
			next
			uploader.ShowProc "写入客户资料：分离非主联系人资料                进度：" , 100
			sql =       "select ["&khlxr&"],"
			If arrShow(30)=1 Then sql = sql & "[" & arrName(30) &"],"
			If arrShow(27)=1 Then sql = sql & "[" & arrName(27) &"],"
			If arrShow(31)=1 Then sql = sql &  "["&arrName(31)&"],"
			If arrShow(28)=1 Then sql = sql & "[" & arrName(28) &"],"
			If arrShow(29)=1 Then sql = sql & "[" & arrName(29) &"],"
			If arrShow(19)=1 Then sql = sql & "[" & khphone &"],"
			If arrShow(21)=1 Then sql = sql & "[" & arrName(21) &"],"
			If arrShow(20)=1 Then sql = sql & "[" & khmobile &"],"
			If arrShow(22)=1 Then sql = sql & "[" & arrName(22) &"],"
			If arrShow(23)=1 Then sql = sql & "[" & arrName(23) &"],"
			If arrShow(24)=1 Then sql = sql & "[" & arrName(24) &"],"
			If arrShow(100)=1 Then sql = sql & "[" & arrName(100) &"],"
			sql = sql & "销售人员,添加时间,bb.kfID  as 客户ID ,aa.up_index as 联系人ID into  #lxrtb "&_
			" from #kfdrList aa , "&_
			"  ( " & vbcrlf & _
			"          select  a.up_index as lxrID , max(b.kfID) as kfID  from #kfdrList a , (select up_index as kfID from #kfdrList b where len(["&khName&"]) > 0 )  b  " & vbcrlf & _
			"          where len(isnull(["&khName&"],'')) = 0 and a.up_index > b.kfID " & vbcrlf & _
			"          group by a.up_index  " & vbcrlf & _
			"  ) bb where aa.up_index = bb.lxrID and len(["&khlxr&"]) > 0"
			cn.execute sql , n
			cn.execute "update  #lxrtb set 销售人员 = cast(a.ord as varchar(10)) from gate a where a.name = 销售人员"
			cn.execute "delete from #kfdrList where len(isnull(["&khName&"],''))=0"
			cn.execute "select ["&khName&"],["&arrName(3)&"],up_index as kid into #kftb from #kfdrList"
			cn.execute "insert into #k_all  (内容)  values ('从导入文件获取" & n & "条非主联系人资料')"
			sql=""
			cn.execute  "update #kfdrList set ["&khName&"] = '' where ["&khName&"] is null"
			cn.execute  "update #kfdrList set ["&arrName(3)&"] = '' where ["&arrName(3)&"] is null"
			If arrShow(20)=1 Then cn.execute "update #kfdrList set ["&khmobile&"] = '' where ["&khmobile&"] is null"
			If arrShow(19)=1 Then cn.execute "update #kfdrList set ["&khphone&"] = '' where ["&khphone&"] is null"
			If arrShow(17)=1 Then cn.execute "update #kfdrList set ["&khlxr&"] = '' where ["&khlxr&"] is null"
			cn.execute  "update #kfdrList set 销售人员 = " & usid & " where isnumeric(isnull(cast(销售人员 as varchar(32)),''))=0"
			cn.execute "update #kfdrList set 跟进方式=0 where isnumeric(isnull(cast(跟进方式 as varchar(32)),'0'))=0 and datalength(isnull(洽谈进展,''))>0"
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'跟进方式为空或无法识别,洽谈进展无法导入' from  #kfdrList where (datalength(isnull(洽谈进展,''))>0 and isnull(跟进方式,0)=0) or (datalength(isnull(洽谈进展,''))>0 and isnull(跟进方式,0) not in (select ord from sortonehy where gate2=98 and del=1) )"
			cn.execute "delete from #kfdrList where (datalength(isnull(洽谈进展,''))>0 and isnull(跟进方式,0)=0) or (datalength(isnull(洽谈进展,''))>0 and isnull(跟进方式,0) not in (select ord from sortonehy where gate2=98 and del=1) )"
			uploader.ShowProc "写入客户资料：去重复记录                进度：" , 200
			select case rType
			case 0 :
			case 1 :
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&khName&"与第' + cast(isnull((select min(up_index) as id from #kfdrList b where a.["&khName&"]=b.["&khName&"]),0) as varchar(10)) + '行重复' from #kfdrList a where  up_index not in (select min(up_index) as id from #kfdrList group by ["&khName&"])"
			cn.execute "delete #kfdrList where up_index not in (select min(up_index) as id from #kfdrList group by ["&khName&"])" , n1
			sql="insert into #k_fail(行号,失败原因) select distinct up_index,'已存在客户:'+a.["&khName&"]+'(联系人:'+a.["&khName&"]+"
			If arrShow(20)=1 Then sql=sql & " '"&khmobile&":'+a.["&khmobile&"]+ "
			sql=sql & " ')' from #kfdrList a,erp_telandperson b where b.sort3=1 and a.["&khName&"]=b.客户名称"
			cn.execute sql
			sql=""
			cn.execute "delete #kfdrList where up_index in (select a.up_index from #kfdrList a,erp_telandperson b where b.sort3=1 and a.["&khName&"]=b.客户名称)" , n2
			case 2 :
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(3)&"与第' + cast(isnull((select min(up_index) as id from #kfdrList b where len(b.["&arrName(3)&"]) > 0  and isnull(a.["&arrName(3)&"],'')=isnull(b.["&arrName(3)&"],'')),0) as varchar(10)) + '行重复' from #kfdrList a where len(["&arrName(3)&"]) > 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&arrName(3)&"]) > 0  group by ["&arrName(3)&"])"
			cn.execute "delete #kfdrList where len(["&arrName(3)&"]) > 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&arrName(3)&"]) > 0  group by ["&arrName(3)&"])" , n1
			cn.execute "insert into #k_fail(行号,失败原因) select distinct up_index,'系统中已存在该"&arrName(3)&":'+cast(a.["&arrName(3)&"] as varchar(50)) from #kfdrList a,(select distinct khid as 客户编号 from tel where sort3=1 and del in (1,2)) b where a.["&arrName(3)&"]=b.客户编号 and len(a.["&arrName(3)&"]) > 0"
			cn.execute "delete #kfdrList where len(["&arrName(3)&"]) > 0 and up_index in (select a.up_index from #kfdrList a,(select distinct khid  as 客户编号 from tel where sort3=1 and del in (1,2)) b where a.["&arrName(3)&"]=b.客户编号 and len(a.["&arrName(3)&"])>0 )" , n2
			case 3 :
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&khphone&"与第' + cast(isnull((select min(up_index) as id from #kfdrList b where len(b.["&khphone&"]) > 0 and  isnull(a.["&khphone&"],'')=isnull(b.["&khphone&"],'')),0) as varchar(10)) + '行重复' from #kfdrList a where len(["&khphone&"])> 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khphone&"]) > 0 group by ["&khphone&"])"
			cn.execute "delete #kfdrList where len(["&khphone&"])> 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khphone&"])>0 group by ["&khphone&"])" , n1
			cn.execute "insert into #k_fail(行号,失败原因) select distinct up_index,'系统中已存在该"&khphone&":'+cast(a.["&khphone&"] as varchar(50)) from #kfdrList a,erp_telandperson b where b.sort3=1 and a.["&khphone&"]=b.电话 and len(a.["&khphone&"]) > 0"
			cn.execute "delete #kfdrList where len(["&khphone&"]) >0 and up_index in (select a.up_index from #kfdrList a,erp_telandperson b where b.sort3=1 and a.["&khphone&"]=b.电话 and len(a.["&khphone&"])>0 )" , n2
			case 4 :
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&khmobile&"与第' + cast(isnull((select min(up_index) as id from #kfdrList b where len(b.["&khmobile&"]) > 0 and isnull(a.["&khmobile&"],'')=isnull(b.["&khmobile&"],'')),0) as varchar(10)) + '行重复' from #kfdrList a where len(a.["&khlxr&"]) > 0 and len(["&khmobile&"]) >0 and  up_index not in (select min(up_index) as id from #kfdrList where len(["&khlxr&"]) >0 group by ["&khmobile&"])"
			cn.execute "delete #kfdrList where len(["&khlxr&"]) > 0 and len(["&khmobile&"]) >0 and up_index not in (select min(up_index) as id from #kfdrList x where len(x.["&khlxr&"]) > 0 and len(x.["&khmobile&"])>0 group by x.["&khmobile&"])" , n1
			cn.execute "insert into #k_fail(行号,失败原因) select distinct up_index,'系统中已存在该"&khmobile&":'+cast(a.["&khmobile&"] as varchar(50)) from #kfdrList a,erp_telandperson b where b.sort3=1 and a.["&khmobile&"]=b.[手机] and len(a.["&khmobile&"]) > 0 and len(a.["&khlxr&"])>0"
			cn.execute "delete #kfdrList where  len(["&khmobile&"]) >0 and len(["&khlxr&"])>0 and  up_index in (select a.up_index from #kfdrList a,erp_telandperson b where b.sort3=1 and a.["&khmobile&"]=b.[手机] and len(a.["&khmobile&"])>0 and len(a.["&khlxr&"]) > 0 )" , n2
			case 5 :
			cn.execute "insert into #k_fail(行号,失败原因)" & vbcrlf & _
			"                                            ""select up_index,'""&khName&""、""&khphone&""与第' + cast(isnull((select min(up_index) as id from #kfdrList b where a.[""&khName&""]=b.[""&khName&""] and a.[""&khphone&""]=b.[""&khphone&""] and len(b.[""&khphone&""])>0),0) as varchar(10)) + '行重复' from #kfdrList a where len([""&khphone&""]) > 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khphone&"]) > 0 group by ["&khName&"],["&khphone&"])"
			cn.execute "delete #kfdrList where len(["&khphone&"]) > 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khphone&"]) > 0 group by ["&khName&"],["&khphone&"])" , n1
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'系统中已经存在该"&khName&"和"&khphone&"组合('+a.["&khName&"]+cast(a.["&khphone&"] as varchar(50))+')' from #kfdrList a, erp_telandperson b where b.sort3=1 and a.["&khName&"]=b.客户名称 and a.["&khphone&"]=b.电话 and len(a.["&khphone&"])>0"
			cn.execute "delete #kfdrList where len(["&khphone&"])>0 and up_index in (select up_index from #kfdrList a, erp_telandperson b where b.sort3=1 and a.["&khName&"]=b.客户名称 and a.["&khphone&"]=b.电话 and len(a.["&khphone&"])>0)", n2
			case 6 :
			cn.execute "insert into #k_fail(行号,失败原因)" & vbcrlf & _
			"                                            ""select up_index,'""&khName&""、""&khmobile&""与第' + cast(isnull((select min(up_index) as id from #kfdrList b where a.[""&khName&""]=b.[""&khName&""] and a.[""&khmobile&""]=b.[""&khmobile&""] and len(b.[""&khmobile&""])>0),0) as varchar(10)) + '行重复' from #kfdrList a where len([""&khmobile&""]) > 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khmobile&"]) > 0 group by ["&khName&"],["&khmobile&"])"
			cn.execute "delete #kfdrList where len(["&khmobile&"]) > 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khmobile&"]) > 0 group by ["&khName&"],["&khmobile&"])" , n1
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'系统中已经存在该"&khName&"和"&khmobile&"组合('+a.["&khName&"]+cast(a.["&khmobile&"] as varchar(50))+')' from #kfdrList a, erp_telandperson b where b.sort3=1 and a.["&khName&"]=b.客户名称 and a.["&khmobile&"]=b.[手机] and len(a.["&khmobile&"])>0"
			cn.execute "delete #kfdrList where len(["&khmobile&"])>0 and up_index in (select up_index from #kfdrList a, erp_telandperson b where b.sort3=1 and a.["&khName&"]=b.客户名称 and a.["&khmobile&"]=b.[手机] and len(a.["&khmobile&"])>0)" , n2
			case 7 :
			cn.execute "insert into #k_fail(行号,失败原因)" & vbcrlf & _
			"                                            ""select up_index,'""&khName&""、""&arrName(3)&""与第' + cast(isnull((select min(up_index) as id from #kfdrList b where a.[""&khName&""]=b.[""&khName&""] and a.[""&arrName(3)&""]=b.[""&arrName(3)&""] and len(b.[""&arrName(3)&""])>0),0) as varchar(10)) + '行重复' from #kfdrList a where len([""&arrName(3)&""]) > 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&arrName(3)&"]) > 0 group by ["&khName&"],["&arrName(3)&"])"
			cn.execute "delete #kfdrList where len(["&arrName(3)&"]) > 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&arrName(3)&"]) > 0 group by ["&khName&"],["&arrName(3)&"])" , n1
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'系统中已经存在该"&khName&"和"&arrName(3)&"组合('+a.["&khName&"]+cast(a.["&arrName(3)&"] as varchar(50))+')' from #kfdrList a, erp_telandperson b where b.sort3=1 and a.["&khName&"]=b.客户名称 and a.["&arrName(3)&"]=b.客户编号 and len(a.["&arrName(3)&"])>0"
			cn.execute "delete #kfdrList where len(["&arrName(3)&"])>0 and up_index in (select up_index from #kfdrList a, erp_telandperson b where b.sort3=1 and a.["&khName&"]=b.客户名称 and a.["&arrName(3)&"]=b.客户编号 and len(a.["&arrName(3)&"])>0)" , n2
			case 8 :
			cn.execute "insert into #k_fail(行号,失败原因)" & vbcrlf & _
			"                                            ""select up_index,'""&khName&""、销售人员与第' + cast(isnull((select min(up_index) as id from #kfdrList b where a.[""&khName&""]=b.[""&khName&""] and a.销售人员=b.销售人员 and len(b.销售人员)>0),0) as varchar(10)) + '行重复' from #kfdrList a where len(销售人员) > 0 and up_index not in (select min(up_index) as id from #kfdrList where len(销售人员) > 0 group by ["&khName&"],销售人员)"
			cn.execute "delete #kfdrList where len(销售人员) > 0 and up_index not in (select min(up_index) as id from #kfdrList where len(销售人员) > 0 group by ["&khName&"],销售人员)" , n1
			cn.execute "insert into #k_fail(行号,失败原因) select distinct up_index,'系统中已经存在该"&khName&"和销售人员组合('+a.["&khName&"]+cast(a.销售人员 as varchar(50))+')' from #kfdrList a, erp_telandperson b where b.sort3=1 and a.["&khName&"]=b.客户名称 and a.销售人员=b.销售人员 and len(a.销售人员)>0"
			cn.execute "delete #kfdrList where len(销售人员)>0 and up_index in (select up_index from #kfdrList a, erp_telandperson b where b.sort3=1 and a.["&khName&"]=b.客户名称 and a.销售人员=b.销售人员 and len(a.销售人员)>0)" , n2
			case 9 :
			cn.execute "insert into #k_fail(行号,失败原因) select  up_index,'"&khName&"与第' + cast(isnull((select min(up_index) as id from #kfdrList b where a.["&khName&"]=b.["&khName&"]),0) as varchar(10)) + '行重复' from #kfdrList a where  up_index not in (select min(up_index) as id from #kfdrList group by ["&khName&"])"
			cn.execute "delete #kfdrList where up_index not in (select min(up_index) as id from #kfdrList group by ["&khName&"])" , n1
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&khmobile&"与第' + cast(isnull((select min(up_index) as id from #kfdrList b where len(b.["&khmobile&"]) > 0 and  isnull(a.["&khmobile&"],'')=isnull(b.["&khmobile&"],'')),0) as varchar(10)) + '行重复' from #kfdrList a where len(["&khmobile&"])>0 and  up_index not in (select min(up_index) as id from #kfdrList where len(["&khmobile&"]) > 0 group by ["&khmobile&"])"
			cn.execute "delete #kfdrList where len(["&khmobile&"])> 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khmobile&"])>0 group by ["&khmobile&"])" , n
			n1 = n1 + n
			cn.execute "insert into #k_fail(行号,失败原因) select distinct up_index,'系统中已经存在该"&khName&"或"&khmobile&"('+a.["&khName&"]+cast(a.["&khmobile&"] as varchar(50))+')' from #kfdrList a ,erp_telandperson  b where b.sort3=1 and (a.["&khName&"]=b.客户名称 or (a.["&khmobile&"]=b.[手机] and len(a.["&khmobile&"]) > 0)) "
			cn.execute "delete #kfdrList from erp_telandperson a where a.sort3=1 and (a.客户名称=#kfdrList.["&khName&"]  or (a.手机=#kfdrList.["&khmobile&"] and len(#kfdrList.["&khmobile&"]) > 0)) ",n2
			case 10:
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&khName&"与第' + cast(isnull((select min(up_index) as id from #kfdrList b where a.["&khName&"]=b.["&khName&"]),0) as varchar(10)) + '行重复' from #kfdrList a where  up_index not in (select min(up_index) as id from #kfdrList group by ["&khName&"])"
			cn.execute "delete #kfdrList where up_index not in (select min(up_index) as id from #kfdrList group by ["&khName&"])" , n1
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&khphone&"与第' + cast(isnull((select min(up_index) as id from #kfdrList b where len(b.["&khphone&"]) > 0 and  isnull(a.["&khphone&"],'')=isnull(b.["&khphone&"],'')),0) as varchar(10)) + '行重复' from #kfdrList a where  len(["&khphone&"])> 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khphone&"]) > 0 group by ["&khphone&"])"
			cn.execute "delete #kfdrList where len(["&khphone&"])> 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khphone&"])>0 group by ["&khphone&"])" , n
			n1 = n1 + n
			cn.execute "insert into #k_fail(行号,失败原因) select distinct up_index,'系统中已经存在该"&khName&"或"&khphone&"('+a.["&khName&"]+cast(a.["&khphone&"] as varchar(50))+')'  from  #kfdrList a ,erp_telandperson  b where b.sort3=1 and (a.["&khName&"]=b.客户名称  or (a.["&khphone&"]=b.电话 and len(a.["&khphone&"]) > 0)) "
			cn.execute "delete #kfdrList from erp_telandperson a where a.sort3=1 and (a.客户名称=#kfdrList.["&khName&"]  or (a.电话=#kfdrList.["&khphone&"] and len(#kfdrList.["&khphone&"]) > 0)) ",n2
			case 11:
			cn.execute "insert into #k_fail(行号,失败原因)" & vbcrlf & _
			"                                            ""select up_index,'""&khName&""、""&khphone&""与第' + cast(isnull((select min(up_index) as id from #kfdrList b where a.[""&khName&""]=b.[""&khName&""] and a.[""&khmobile&""]=b.[""&khmobile&""] and a.[""&khphone&""]=b.[""&khphone&""] and len(b.[""&khmobile&""]) >0  and len(b.[""&khphone&""])>0),0) as varchar(10)) + '行重复' from #kfdrList a where len(["&khphone&"]) > 0 and len(["&khmobile&"]) >0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khphone&"]) > 0 and len(["&khmobile&"]) >0  group by ["&khName&"],["&khphone&"],["&khmobile&"])"
			cn.execute "delete #kfdrList where len(["&khphone&"]) > 0 and len(["&khmobile&"]) >0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khphone&"]) > 0 and len(["&khmobile&"]) >0 group by ["&khName&"],["&khphone&"],["&khmobile&"])" , n1
			cn.execute "insert into #k_fail(行号,失败原因) select distinct  up_index,'系统中已经存在该"&khName&"、"&khphone&"与"&khmobile&"组合('+a.["&khName&"]+',["&khphone&"]:'+cast(a.["&khphone&"] as varchar(50))+'["&khmobile&"]:'+cast(a.["&khmobile&"] as varchar(50))+')'  from  #kfdrList a ,erp_telandperson  b where b.sort3=1 and a.["&khName&"]=b.客户名称  and a.["&khphone&"]=b.电话 and len(a.["&khphone&"]) > 0 and a.["&khmobile&"]=b.[手机] and len(a.["&khmobile&"]) > 0 "
			cn.execute "delete #kfdrList from erp_telandperson a where a.sort3=1 and a.客户名称=#kfdrList.["&khName&"]  and a.电话=#kfdrList.["&khphone&"] and len(#kfdrList.["&khphone&"]) > 0 and a.手机=#kfdrList.["&khmobile&"] and len(a.手机)>0",n2
			case 12:
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&khName&"与第' + cast(isnull((select min(up_index) as id from #kfdrList b where a.["&khName&"]=b.["&khName&"]),0) as varchar(10)) + '行重复' from #kfdrList a where  up_index not in (select min(up_index) as id from #kfdrList group by ["&khName&"])"
			cn.execute "delete #kfdrList where up_index not in (select min(up_index) as id from #kfdrList group by ["&khName&"])" , n1
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&khmobile&"与第' + cast(isnull((select min(up_index) as id from #kfdrList b where len(b.["&khmobile&"]) > 0 and  isnull(a.["&khmobile&"],'')=isnull(b.["&khmobile&"],'')),0) as varchar(10)) + '行重复' from #kfdrList a where len(["&khmobile&"])>0 and  up_index not in (select min(up_index) as id from #kfdrList where len(["&khmobile&"]) > 0 group by ["&khmobile&"])"
			cn.execute "delete #kfdrList where len(["&khmobile&"])> 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khmobile&"])>0 group by ["&khmobile&"])" , n
			n1 = n1 + n
			n = 0
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&khphone&"与第' + cast(isnull((select min(up_index) as id from #kfdrList b where len(b.["&khphone&"]) > 0 and  isnull(a.["&khphone&"],'')=isnull(b.["&khphone&"],'')),0) as varchar(10)) + '行重复' from #kfdrList a where len(["&khphone&"])> 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khphone&"]) > 0 group by ["&khphone&"])"
			cn.execute "delete #kfdrList where len(["&khphone&"])> 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khphone&"])>0 group by ["&khphone&"])" , n
			n1 = n1 + n
			cn.execute "insert into #k_fail(行号,失败原因) select distinct up_index,'系统中已经存在该"&khName&"或"&khphone&"或"&khmobile&"('+a.["&khName&"]+',["&khphone&"]:'+cast(a.["&khphone&"] as varchar(50))+'"&khmobile&":'+cast(a.["&khmobile&"] as varchar(50))+')' from  #kfdrList a ,erp_telandperson  b where b.sort3=1 and (a.["&khName&"]=b.客户名称  or (a.["&khphone&"]=b.电话 and len(a.["&khphone&"]) > 0) or (a.["&khmobile&"]=b.[手机] and len(a.["&khmobile&"]) > 0)) "
			cn.execute "delete #kfdrList from erp_telandperson a where a.sort3=1 and (a.客户名称=#kfdrList.["&khName&"]  or (a.电话=#kfdrList.["&khphone&"] and len(#kfdrList.["&khphone&"])> 0) or (a.手机=#kfdrList.["&khmobile&"] and len(a.手机)>0))",n2
			case 13:
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&khName&"与第' + cast(isnull((select min(up_index) as id from #kfdrList b where a.["&khName&"]=b.["&khName&"]),0) as varchar(10)) + '行重复' from #kfdrList a where  up_index not in (select min(up_index) as id from #kfdrList group by ["&khName&"])"
			cn.execute "delete #kfdrList where up_index not in (select min(up_index) as id from #kfdrList group by ["&khName&"])" , n1
			cn.execute "insert into #k_fail(行号,失败原因)" & vbcrlf & _
			"                                    ""select up_index,'""&khphone&""、""&khmobile&""与第' + cast(isnull((select min(up_index) as id from #kfdrList b where a.[""&khphone&""]=b.[""&khphone&""] and a.[""&khmobile&""]=b.[""&khmobile&""] and len(b.[""&khmobile&""])>0 and len(b.[""&khphone&""])>0),0) as varchar(10)) + '行重复' from #kfdrList a where len(["&khmobile&"]) > 0 and len(["&khphone&"]) >0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khmobile&"]) > 0 and len(["&khphone&"]) > 0 group by ["&khphone&"],["&khmobile&"])"
			cn.execute "delete #kfdrList where len(["&khmobile&"]) > 0 and len(["&khphone&"])>0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khmobile&"]) > 0 and len(["&khphone&"]) >0 group by ["&khphone&"],["&khmobile&"])" , n
			n1 = n1 + n
			cn.execute "insert into #k_fail(行号,失败原因) select distinct up_index,'系统中已经存在该"&khName&" 或 "&khphone&"与"&khmobile&"组合('+a.["&khName&"]+',["&khphone&"]:'+cast(a.["&khphone&"] as varchar(50))+'"&khmobile&":'+cast(a.["&khmobile&"] as varchar(50))+')' from #kfdrList a ,erp_telandperson  b where b.sort3=1 and (a.["&khName&"]=b.客户名称  or (a.["&khphone&"]=b.电话 and len(a.["&khphone&"]) > 0 and a.["&khmobile&"]=b.[手机] and len(a.["&khmobile&"]) > 0)) "
			cn.execute "delete #kfdrList from erp_telandperson a where a.sort3=1 and (a.客户名称=#kfdrList.["&khName&"]  or (a.电话=#kfdrList.["&khphone&"] and len(#kfdrList.["&khphone&"])> 0 and a.手机=#kfdrList.["&khmobile&"] and len(a.手机)>0))",n2
			case 14:
			cn.execute "insert into #k_fail(行号,失败原因)" & vbcrlf & _
			"                                            ""select up_index,'""&khName&""、""&khphone&""与第' + cast(isnull((select min(up_index) as id from #kfdrList b where a.[""&khName&""]=b.[""&khName&""] and a.[""&khphone&""]=b.[""&khphone&""] and len(b.[""&khphone&""])>0),0) as varchar(10)) + '行重复' from #kfdrList a where len([""&khphone&""]) > 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khphone&"]) > 0 group by ["&khName&"],["&khphone&"])"
			cn.execute "delete #kfdrList where len(["&khphone&"]) > 0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khphone&"]) > 0 group by ["&khName&"],["&khphone&"])" , n1
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&khmobile&"与第' + cast(isnull((select min(up_index) as id from #kfdrList b where len(b.["&khmobile&"]) > 0 and isnull(a.["&khmobile&"],'')=isnull(b.["&khmobile&"],'')),0) as varchar(10)) + '行重复' from #kfdrList a where len(["&khlxr&"]) > 0 and len(["&khmobile&"]) >0 and  up_index not in (select min(up_index) as id from #kfdrList where len(["&khlxr&"]) >0 group by ["&khmobile&"])"
			cn.execute "delete #kfdrList where len(["&khlxr&"]) > 0 and  len(["&khmobile&"]) >0 and up_index not in (select min(up_index) as id from #kfdrList where len(["&khlxr&"]) > 0 and len(["&khmobile&"])>0 group by ["&khmobile&"])" , n
			n1 = n1 + n
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'系统中已经存在该"&khName&"与"&khphone&"组合、"&khmobile&"('+a.["&khName&"]+',"&khphone&":'+cast(a.["&khphone&"] as varchar(50))+'["&khmobile&"]:'+cast(a.["&khmobile&"] as varchar(50))+')' from  #kfdrList a ,erp_telandperson  b where b.sort3=1 and ((a.["&khName&"]=b.客户名称  and a.["&khphone&"]=b.电话 and len(a.["&khphone&"]) > 0) or (a.["&khmobile&"]=b.[手机] and len(a.["&khmobile&"]) > 0)) "
			cn.execute "delete #kfdrList from erp_telandperson a where a.sort3=1 and ((a.客户名称=#kfdrList.["&khName&"]  and a.电话=#kfdrList.["&khphone&"] and len(#kfdrList.["&khphone&"])> 0) or (a.手机=#kfdrList.["&khmobile&"] and len(a.手机)>0))",n2
			case else
			unloader.showalert "无法识别判重条件"
			Page_InsertDataBase = false
			exit function
			end select
			cn.execute "insert into #k_all (内容,说明) values ('从导入文件删除" & n1 & "条重复记录," & n2 & "条系统已存在客户记录 ,同时删除了对应的主联系人','')"
			uploader.ShowProc "写入客户资料：删除无效关联空数据                进度：" ,300
			sql=sql & "select ["&arrName(4)&"] as 无效数据, '"&arrName(4)&"' as 无效数据列, count(["&arrName(4)&"] ) as 存在记录数量,'未导入' as 导入结果 from #kfdrList kl where isnumeric(isnull(cast(["&arrName(4)&"] as varchar(32)),'0'))=0 group by ["&arrName(4)&"] " & vbcrlf
			sql=sql & "union all" & vbcrlf
			sql=sql & "select ["&arrName(5)&"]  , '"&arrName(5)&"' , count(["&arrName(5)&"]),'未导入' from #kfdrList kl where isnumeric(isnull(cast(["&arrName(5)&"] as varchar(32)),'0'))=0   group  by  ["&arrName(5)&"]" & vbcrlf
			sql=sql & "union all" & vbcrlf
			sql=sql & "select ["&arrName(7)&"] , '"&arrName(7)&"' , count(["&arrName(7)&"]),'未导入' from #kfdrList kl where isnumeric(isnull(cast(["&arrName(7)&"] as varchar(32)),'0'))=0   group  by  ["&arrName(7)&"]" & vbcrlf
			sql=sql & "union all" & vbcrlf
			sql=sql & "select ["&arrName(8)&"] , '"&arrName(8)&"' , count(["&arrName(8)&"] ),'未导入' from #kfdrList kl where isnumeric(isnull(cast(["&arrName(8)&"] as varchar(32)),'0'))=0   group  by  ["&arrName(8)&"] " & vbcrlf
			sql=sql & "union all" & vbcrlf
			sql=sql & "select ["&arrName(9)&"] , '"&arrName(9)&"' , count(["&arrName(9)&"] ),'未导入' from #kfdrList kl where isnumeric(isnull(cast(["&arrName(9)&"] as varchar(32)),'0'))=0   group  by  ["&arrName(9)&"] " & vbcrlf
			If ZBRuntime.MC(207101) And ubound(arrShow)>=52 Then
				If arrShow(52)=1 Then
					sql=sql & "union all" & vbcrlf
					sql=sql & "select ["&arrName(52)&"] , '"&arrName(52)&"' , count(["&arrName(52)&"] ),'未导入' from #kfdrList kl where isnumeric(isnull(cast(["&arrName(52)&"] as varchar(32)),'0'))=0   group  by  ["&arrName(52)&"] " & vbcrlf
				end if
			end if
			sql=sql & "union all" & vbcrlf
			sql=sql & "select ["&arrName(6)&"] , '"&arrName(6)&"' , count(["&arrName(6)&"]),'未导入' from #kfdrList kl where isnumeric(isnull(cast(["&arrName(6)&"] as varchar(32)),'0'))=0   group  by  ["&arrName(6)&"]" & vbcrlf
			sql=sql & "union all" & vbcrlf
			sql=sql & "select 销售人员 , '销售人员' , count(销售人员),'未导入' from #kfdrList kl where isnumeric(isnull(cast(销售人员 as varchar(32)),'0'))=0   group  by  销售人员" & vbcrlf
			Set rs_kz_zdy = cn.execute("select title,gl from zdy where sort1=1 and sort=1 and set_open=1 and dr=1 and bt=1 order by gate1")
			While rs_kz_zdy.eof = False
				kz_fname=rs_kz_zdy("title")
				sql=sql & "union all" & vbcrlf
				sql=sql & "select cast(["& kz_fname &"] as varchar(32)), '"& kz_fname &"' , count(cast(["& kz_fname &"] as varchar(32))) ,'未导入' from #kfdrList kl where (isnumeric(isnull(cast(["& kz_fname &"] as varchar(32)),'0'))=0 or (isnumeric(isnull(cast(["& kz_fname &"] as varchar(32)),'0'))=1 and not exists(select top 1 1 from sortonehy where gate2="& rs_kz_zdy("gl") &" and ord=(case when isnumeric(isnull(cast(["& kz_fname &"] as varchar(32)),'0'))=0 then 0 else cast(["& kz_fname &"] as varchar(32)) end)))) group by cast(["& kz_fname &"] as varchar(32))" & vbcrlf
				rs_kz_zdy.movenext
			wend
			rs_kz_zdy.close
			Set rs_kz_zdy = Nothing
			cn.execute "select * into #k_flink from (" & sql & ") t"
			n = 0
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(4)&"无效,不识别“' + cast(["&arrName(4)&"] as varchar(255)) + '”。' from #kfdrList where isnumeric(isnull(cast(["&arrName(4)&"] as varchar(32)),'0'))=0"
			n = 0
			cn.execute "delete from #kfdrList where isnumeric(isnull(cast(["&arrName(4)&"] as varchar(32)),'0'))=0", i  :  n = n + i
			n = 0
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(5)&"无效,不识别“' + cast(["&arrName(5)&"] as varchar(255)) + '”。' from #kfdrList where isnumeric(isnull(cast(["&arrName(5)&"] as varchar(32)),'0'))=0"
			n = 0
			cn.execute "delete from #kfdrList where isnumeric(isnull(cast(["&arrName(5)&"] as varchar(32)),'0'))=0", i  :  n = n + i
			n = 0
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(7)&"无效,不识别“' + cast(["&arrName(7)&"] as varchar(255)) + '”。' from #kfdrList where isnumeric(isnull(cast(["&arrName(7)&"] as varchar(32)),'0'))=0"
			n = 0
			cn.execute "delete from #kfdrList where isnumeric(isnull(cast(["&arrName(7)&"] as varchar(32)),'0'))=0", i  :  n = n + i
			n = 0
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(8)&"无效,不识别“' + cast(["&arrName(8)&"]  as varchar(255)) + '”。' from #kfdrList where isnumeric(isnull(cast(["&arrName(8)&"] as varchar(32)) ,'0'))=0"
			n = 0
			cn.execute "delete from #kfdrList where isnumeric(isnull(cast(["&arrName(8)&"] as varchar(32)) ,'0'))=0", i  :  n = n + i
			n = 0
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(9)&"无效,不识别“' + cast(["&arrName(9)&"]  as varchar(255)) + '”。' from #kfdrList where isnumeric(isnull(cast(["&arrName(9)&"] as varchar(32)) ,'0'))=0"
			n = 0
			cn.execute "delete from #kfdrList where isnumeric(isnull(cast(["&arrName(9)&"] as varchar(32)) ,'0'))=0", i  :  n = n + i
			n = 0
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,replace(cast([添加人员] as varchar(255)),'@@@cateadd','') + '存在多人”。' from #kfdrList where charindex('@@@cateadd',isnull(cast([添加人员] as varchar(32)),''))>0 "
			n = 0
			cn.execute "delete from #kfdrList where charindex('@@@cateadd',isnull(cast([添加人员] as varchar(32)),''))>0", i  :  n = n + i
			n = 0
			cn.execute "update #kfdrList set [添加人员]="& usid &" where isnumeric(isnull(cast([添加人员] as varchar(32)) ,'0'))=0 or [添加人员]=''"
			if arrShow(16)=1 then
				cn.execute "update #kfdrList set ["&arrName(16)&"(技术)]=0 where isnumeric(isnull(cast(["&arrName(16)&"(技术)] as varchar(32)) ,'0'))=0"
				cn.execute "update #kfdrList set ["&arrName(16)&"(技术)]=0 where isnull(cast(["&arrName(16)&"(技术)] as decimal(25,12)),0)<0 "
				cn.execute "update #kfdrList set ["&arrName(16)&"(销售)]=0 where isnumeric(isnull(cast(["&arrName(16)&"(销售)] as varchar(32)) ,'0'))=0"
				cn.execute "update #kfdrList set ["&arrName(16)&"(销售)]=0 where isnull(cast(["&arrName(16)&"(销售)] as decimal(25,12)),0)<0 "
			end if
			if arrShow(11)=1 then
				cn.execute "update #kfdrList set ["&arrName(11)&"]=0 where isnumeric(isnull(cast(["&arrName(11)&"] as varchar(32)) ,'0'))=0"
				cn.execute "update #kfdrList set ["&arrName(11)&"]=0 where isnull(cast(["&arrName(11)&"] as decimal(25,12)),0)<0 or isnull(cast(["&arrName(11)&"] as decimal(25,12)),0)>100"
			end if
			cn.execute "update #kfdrList set ["&arrName(10001)&"]=0 where isnumeric(isnull(cast(["&arrName(10001)&"] as varchar(32)) ,'0'))=0"
			cn.execute "update #kfdrList set ["&arrName(10001)&"]=0 where isnull(cast(["&arrName(10001)&"] as decimal(25,12)),0)<0 or isnull(cast(["&arrName(10001)&"] as decimal(25,12)),0)>365"
			cn.execute "update #kfdrList set ["&arrName(10002)&"]=0 where isnumeric(isnull(cast(["&arrName(10002)&"] as varchar(32)) ,'0'))=0"
			cn.execute "update #kfdrList set ["&arrName(10002)&"]=0 where cast(isnull(["&arrName(10002)&"],0) as decimal(25,12))<0 or cast(isnull(["&arrName(10002)&"],0) as decimal(25,12))>31 "
			If ZBRuntime.MC(207101)  And ubound(arrShow)>=52 Then
				If arrShow(52)=1 Then
					cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(52)&"无效,不识别“' + cast(["&arrName(52)&"]  as varchar(255)) + '”。' from #kfdrList where isnumeric(isnull(cast(["&arrName(52)&"] as varchar(32)) ,'0'))=0"
'If arrShow(52)=1 Then
					cn.execute "delete from #kfdrList where isnumeric(isnull(cast(["&arrName(52)&"] as varchar(32)) ,'0'))=0", i  :  n = n + i
'If arrShow(52)=1 Then
				end if
			end if
			Set rs_kz_zdy = cn.execute("select title,gl from zdy where sort=1 and sort1=1 and set_open=1 and dr=1 and bt=1 order by gate1")
			While rs_kz_zdy.eof = False
				kz_fname=rs_kz_zdy("title")
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"& kz_fname &"无效,不识别第'+cast(up_index as varchar(10))+ '行"& kz_fname &"。' from #kfdrList where (isnumeric(isnull(cast(["& kz_fname &"] as varchar(32)),'0'))=0 or (isnumeric(isnull(cast(["& kz_fname &"] as varchar(32)),'0'))=1 and not exists(select top 1 1 from sortonehy where gate2="& rs_kz_zdy("gl") &" and ord=(case when isnumeric(isnull(cast(["& kz_fname &"] as varchar(32)),'0'))=0 then 0 else ["&kz_fname&"] end))))"
				cn.execute "delete from #kfdrList where (isnumeric(isnull(cast(["& kz_fname &"] as varchar(32)),'0'))=0 or (isnumeric(isnull(cast(["& kz_fname &"] as varchar(32)),'0'))=1 and not exists(select top 1 1 from sortonehy where gate2="& rs_kz_zdy("gl") &" and ord=(case when isnumeric(isnull(cast(["& kz_fname &"] as varchar(32)),'0'))=0 then 0 else ["&kz_fname&"] end))))", i  :  n = n + i
				rs_kz_zdy.movenext
			wend
			rs_kz_zdy.close
			Set rs_kz_zdy = Nothing
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(6)&"无效,不识别“' + cast(["&arrName(6)&"] as varchar(255)) + '”。' from #kfdrList where isnumeric(isnull(cast(["&arrName(6)&"] as varchar(32)),'0'))=0"
'Set rs_kz_zdy = Nothing
			cn.execute "delete from #kfdrList where isnumeric(isnull(cast(["&arrName(6)&"] as varchar(32)),'0'))=0", i  :  n = n + i
'Set rs_kz_zdy = Nothing
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'销售人员无效,不识别“' + cast(销售人员 as varchar(255)) + '”。' from #kfdrList where isnumeric(isnull(销售人员,'0'))=0"
'Set rs_kz_zdy = Nothing
			cn.execute "delete from #kfdrList where isnumeric(isnull(销售人员,'0'))=0", i  :  n = n + i
'Set rs_kz_zdy = Nothing
			If arrShow(29)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(29)&"无效,不识别“' + cast(["&arrName(29)&"] as varchar(255)) + '”。' from #kfdrList where isnumeric(isnull(cast(["&arrName(29)&"] as varchar(32)),'0'))=0"
'If arrShow(29)=1 Then
				cn.execute "delete from #kfdrList where isnumeric(isnull(cast(["&arrName(29)&"] as varchar(32)),'0'))=0", i  :  n = n + i
'If arrShow(29)=1 Then
			end if
			If arrShow(38)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(38)&" “' + cast( ["&arrName(38)&"] as nvarchar(255)) + '”超过50个字符,无法导入。' from #kfdrList where len(cast(["&arrName(38)&"] as nvarchar(500)))>50 "
'If arrShow(38)=1 Then
				cn.execute "delete from #kfdrList where len(cast(["&arrName(38)&"] as nvarchar(500)))>50 ", i  :  n = n + i
'If arrShow(38)=1 Then
			end if
			If arrShow(39)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(39)&" “' + cast( ["&arrName(39)&"] as nvarchar(255)) + '”超过50个字符,无法导入。' from #kfdrList where len(cast(["&arrName(39)&"] as nvarchar(500)))>50 "
'If arrShow(39)=1 Then
				cn.execute "delete from #kfdrList where len(cast(["&arrName(39)&"] as nvarchar(500)))>50 ", i  :  n = n + i
'If arrShow(39)=1 Then
			end if
			If arrShow(50)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(50)&" “' + cast( ["&arrName(50)&"] as nvarchar(255)) + '”超过50个字符,无法导入。' from #kfdrList where len(cast(["&arrName(50)&"] as nvarchar(500)))>50 "
'If arrShow(50)=1 Then
				cn.execute "delete from #kfdrList where len(cast(["&arrName(50)&"] as nvarchar(500)))>50 ", i  :  n = n + i
'If arrShow(50)=1 Then
			end if
			If arrShow(40)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(40)&" “' + cast( ["&arrName(40)&"] as nvarchar(255)) + '”超过50个字符,无法导入。' from #kfdrList where len(cast(["&arrName(40)&"] as nvarchar(500)))>50 "
'If arrShow(40)=1 Then
				cn.execute "delete from #kfdrList where len(cast(["&arrName(40)&"] as nvarchar(500)))>50 ", i  :  n = n + i
'If arrShow(40)=1 Then
			end if
			If arrShow(41)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(41)&" “' + cast( ["&arrName(41)&"] as nvarchar(255)) + '”超过50个字符,无法导入。' from #kfdrList where len(cast(["&arrName(41)&"] as nvarchar(500)))>50 "
'If arrShow(41)=1 Then
				cn.execute "delete from #kfdrList where len(cast(["&arrName(41)&"] as nvarchar(500)))>50 ", i  :  n = n + i
'If arrShow(41)=1 Then
			end if
			If arrShow(42)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(42)&" “' + cast( ["&arrName(42)&"] as nvarchar(255)) + '”超过50个字符,无法导入。' from #kfdrList where len(cast(["&arrName(42)&"] as nvarchar(500)))>50 "
'If arrShow(42)=1 Then
				cn.execute "delete from #kfdrList where len(cast(["&arrName(42)&"] as nvarchar(500)))>50 ", i  :  n = n + i
			end if
			If arrShow(43)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(43)&" “' + cast( ["&arrName(43)&"] as nvarchar(255)) + '”超过50个字符,无法导入。' from #kfdrList where len(cast(["&arrName(43)&"] as nvarchar(500)))>50 "
'If arrShow(43)=1 Then
				cn.execute "delete from #kfdrList where len(cast(["&arrName(43)&"] as nvarchar(500)))>50 ", i  :  n = n + i
'If arrShow(43)=1 Then
			end if
			If arrShow(44)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(44)&" “' + cast( ["&arrName(44)&"] as nvarchar(255)) + '”超过50个字符,无法导入。' from #kfdrList where len(cast(["&arrName(44)&"] as nvarchar(500)))>50 "
'If arrShow(44)=1 Then
				cn.execute "delete from #kfdrList where len(cast(["&arrName(44)&"] as nvarchar(500)))>50 ", i  :  n = n + i
'If arrShow(44)=1 Then
			end if
			If arrShow(45)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(45)&" “' + cast( ["&arrName(45)&"] as nvarchar(255)) + '”超过50个字符,无法导入。' from #kfdrList where len(cast(["&arrName(45)&"] as nvarchar(500)))>50 "
'If arrShow(45)=1 Then
				cn.execute "delete from #kfdrList where len(cast(["&arrName(45)&"] as nvarchar(500)))>50 ", i  :  n = n + i
'If arrShow(45)=1 Then
			end if
			If arrShow(51)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(51)&" “' + cast( ["&arrName(51)&"] as nvarchar(255)) + '”超过50个字符,无法导入。' from #kfdrList where len(cast(["&arrName(51)&"] as nvarchar(500)))>50 "
'If arrShow(51)=1 Then
				cn.execute "delete from #kfdrList where len(cast(["&arrName(51)&"] as nvarchar(500)))>50 ", i  :  n = n + i
'If arrShow(51)=1 Then
			end if
			If arrShow(46)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(46)&" “' + cast( ["&arrName(46)&"] as varchar(255)) + '”超过50个字符,无法导入。' from #kfdrList where len(cast(["&arrName(46)&"] as varchar(500)))>50 "
'If arrShow(46)=1 Then
				cn.execute "delete from #kfdrList where len(cast(["&arrName(46)&"] as varchar(500)))>50 ", i  :  n = n + i
'If arrShow(46)=1 Then
			end if
			If arrShow(47)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(47)&" “' + cast( ["&arrName(47)&"] as nvarchar(255)) + '”超过50个字符,无法导入。' from #kfdrList where len(cast(["&arrName(47)&"] as nvarchar(500)))>50 "
'If arrShow(47)=1 Then
				cn.execute "delete from #kfdrList where len(cast(["&arrName(47)&"] as nvarchar(500)))>50 ", i  :  n = n + i
'If arrShow(47)=1 Then
			end if
			If arrShow(48)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(48)&" “' + cast( ["&arrName(48)&"] as nvarchar(255)) + '”超过50个字符,无法导入。' from #kfdrList where len(cast(["&arrName(48)&"] as nvarchar(500)))>50 "
'If arrShow(48)=1 Then
				cn.execute "delete from #kfdrList where len(cast(["&arrName(48)&"] as nvarchar(500)))>50 ", i  :  n = n + i
'If arrShow(48)=1 Then
			end if
			If arrShow(49)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select up_index,'"&arrName(49)&" “' + cast( ["&arrName(49)&"] as nvarchar(255)) + '”超过50个字符,无法导入。' from #kfdrList where len(cast(["&arrName(49)&"] as nvarchar(500)))>50 "
'If arrShow(49)=1 Then
				cn.execute "delete from #kfdrList where len(cast(["&arrName(49)&"] as nvarchar(500)))>50 ", i  :  n = n + i
'If arrShow(49)=1 Then
			end if
			cn.execute "insert into #k_all  (内容) values ('从导入文件删除" & n & "条客户和主联系人无效关联空数据,请参见无效关联数据附表')"
			if request.querystring("updatebug") = "1" then
				call updatebug(dbname)
				exit function
			end if
			cn.execute "update person set person_excel_drSign = 0 where person_excel_drSign > 0 and  person_excel_drUser=" & usid
			cn.execute "update tel set tel_excel_drSign = 0 where tel_excel_drSign > 0 and  tel_excel_drUser=" & usid
			n = uploader.autoHandTextFieldType(dbname)
			uploader.ShowProc "写入客户资料：创建主联系人资料           进度：" ,450
			maxord2 = cn.execute("select isnull(max(ord),0) from person").fields(0).value
			sql="insert into person (date7,name,"
			If arrShow(30)=1 Then sql=sql & "sex,"
			If arrShow(27)=1 Then sql=sql & "part1,"
			If arrShow(31)=1 Then sql = sql & "year1,age,"
			sql = sql & "birthdayType,"
			If arrShow(28)=1 Then sql=sql & "p.[job],"
			If arrShow(29)=1 Then sql=sql & "p.[role],"
			If arrShow(19)=1 Then sql=sql & "phone,"
			If arrShow(21)=1 Then sql=sql & "fax,"
			If arrShow(20)=1 Then sql=sql & "mobile,"
			If arrShow(22)=1 Then sql=sql & "email,"
			If arrShow(23)=1 Then sql=sql & "qq,"
			If arrShow(24)=1 Then sql=sql & "msn,"
			If arrShow(100)=1 Then sql=sql & "weixinAcc,"
			sql=sql & "sort,sort1,del,cateid,area,trade,numc1,date4,date8,person_excel_drSign,person_excel_drUser)" & vbcrlf
			sql=sql & "select distinct getdate(),"
			sql=sql & "cast(["&khlxr&"] as varchar(50)),"
			If arrShow(30)=1 Then sql=sql & "cast(["&arrName(30)&"] as varchar(10)),"
			If arrShow(27)=1 Then sql=sql & "cast(["&arrName(27)&"] as varchar(50)),"
			If arrShow(31)=1 Then
				sql = sql &  "(case when isdate(["&arrName(31)&"])=1 then ["&arrName(31)&"] else null end),(case when isdate(["& arrName(31) &"])=1 then datediff(YY,isnull(["& arrName(31) &"],'1900-1-1'),getdate()) else null end),"
'If arrShow(31)=1 Then
			else
				sql = sql &  ""
			end if
			If arrShow(31)=1 Then
				sql=sql & "(case when len(["& arrName(31) &"])>0 then 1 else 0 end),"
			else
				sql=sql & "0,"
			end if
			If arrShow(28)=1 Then sql=sql & "cast(["&arrName(28)&"] as varchar(50)),"
			If arrShow(29)=1 Then sql=sql & "["&arrName(29)&"],"
			If arrShow(19)=1 Then sql=sql & "cast(["&khphone&"] as varchar(50)),"
			If arrShow(21)=1 Then sql=sql & "cast(["&arrName(21)&"] as varchar(50)),"
			If arrShow(20)=1 Then sql=sql & "cast(["&khmobile&"] as varchar(50)),"
			If arrShow(22)=1 Then sql=sql & "cast(["&arrName(22)&"] as varchar(50)),"
			If arrShow(23)=1 Then sql=sql & "cast(["&arrName(23)&"] as varchar(20)),"
			If arrShow(24)=1 Then sql=sql & "cast(["&arrName(24)&"] as varchar(50)),"
			If arrShow(100)=1 Then sql=sql & "cast(["&arrName(100)&"] as nvarchar(100)) as ["&arrName(100)&"],"
			sql=sql & "["&arrName(4)&"],"
			sql=sql & "["&arrName(5)&"],"
			sql=sql & "1," & usid & " ,["&arrName(7)&"],isnull(cast(["&arrName(8)&"] as varchar(20)),0),1,'" & date & "',getdate(),up_index," & usid & " from #kfdrList where len(rtrim(["&khlxr&"]))>0 and up_index<30000"
			cn.execute sql , n
			sql = replace(sql,"up_index<30000"," up_index>=30000")
			cn.execute sql , n1
			n =n + n1
			'cn.execute sql , n1
			cn.execute "insert into #k_all  (内容) values ('共创建" & n & "位新主联系人资料。')"
			n3 = 0
			n = 0
			uploader.ShowProc "写入客户资料：转换主联系人关联           进度：" ,500
			cn.execute "update #kfdrList set ["&khlxr&"]=cast(a.ord as varchar(12))  from person a where up_index=person_excel_drSign and person_excel_drUser=" & usid
			uploader.ShowProc "写入客户资料：数据类型检测匹配处理               进度：" ,700
			n = uploader.autoHandFieldType(dbname)
			maxord = cn.execute("select isnull(max(ord),0) as c from tel").fields(0).value
			uploader.ShowProc "写入客户资料：最终写入客户资料           进度：" ,850
			cn.execute uploader.getInsertTableSql(dbname,"tel") , n
			t_ord = cn.execute("select isnull(max(ord),0) as c from tel").fields(0).value + 1
			'cn.execute uploader.getInsertTableSql(dbname,"tel") , n
			cn.execute "update tel set tel.phone=a.phone , tel.fax = a.fax , tel.email = a.email from person a where a.ord = tel.person and tel.ord > " & maxord  & " and tel.ord < " & t_ord
			cn.execute "insert into #k_all (内容) values ('成功导入" & n & "条客户资料记录')"
			cn.execute "update tel set tel_excel_drUser = " & usid & " where isnull(tel_excel_drUser,0) = 0 and ord > " & maxord & " and ord < " & t_ord
			cn.execute "update tel set del = 1   where del is null and ord > " & maxord & " and ord < " & t_ord
			cn.execute "update tel set sort=0  where sort is null and ord > " & maxord & " and ord < " & t_ord
			cn.execute "update tel set sort1=0  where sort1 is null and ord > " & maxord & " and ord < " & t_ord
			cn.execute "update tel set cateadd = " & usid & " where cateadd is null and ord >" & maxord & " and ord < " & t_ord
			cn.execute "update tel set cateid = " & usid & " where (cateid is null or cateid = 0 ) and ord >" & maxord & " and ord < " & t_ord
			cn.execute "update tel set date2 = getdate() where ord >" & maxord & " and ord < " & t_ord
			cn.execute "update tel set date1 = '" & now & "' where datepart(hour,date1) =0 and datediff(d,date1,'" & date & "')=0 and ord > " & maxord  & " and ord < " & t_ord
			cn.execute "update tel set order1=2,cateid4='" & usid & "' where ord > " & maxord & " and ord < " & t_ord
			cn.execute "update tel set cateid2 = sorce , cateid3 = sorce2  from gate a where tel.cateid=a.ord and  tel.ord > " & maxord & " and tel.ord < " & t_ord
			cn.execute "update person set company= a.ord , sort = a.sort, sort1 = a.sort1 , cateid2=a.cateid2 , cateid3 = a.cateid3 from tel a where a.person=person.ord and person.ord >" &  maxord2
			cn.execute "delete from person  where  person.ord >" &  maxord2 & " and  company is null" , n
			cn.execute "insert into #k_all (内容) values ('取消导入" & n & "条主联系人资料,对应的客户资料已经存在数据库中')"
			cn.execute("insert into [tel_sales_change_log](tord,sort3,sort,sort1,precateid,newcateid,cateid,date2,date7,reason,reasonchildren,replynum,intro) select ord,sort3,sort,sort1,0,cateid,"& usid &",getdate(),getdate(),2,201,0,'客户导入' from tel where ord > " & maxord  & " and ord < " & t_ord)
			uploader.ShowProc "写入客户资料：写入洽谈进展              进度：" ,950
			cn.execute "update #kfdrList set 跟进方式=0 where isnumeric(isnull(cast(跟进方式 as varchar(32)),'0'))=0 and datalength(isnull(洽谈进展,''))>0"
			cn.execute "insert into #k_fail(行号,失败原因) select up_index,'跟进方式为空或无法识别,洽谈进展无法导入' from  #kfdrList where (datalength(isnull(洽谈进展,''))>0 and isnull(跟进方式,0)=0) or (datalength(isnull(洽谈进展,''))>0 and isnull(跟进方式,0) not in (select ord from sortonehy where gate2=98 and del=1) )"
			cn.execute "delete from #kfdrList where (datalength(isnull(洽谈进展,''))>0 and isnull(跟进方式,0)=0) or (datalength(isnull(洽谈进展,''))>0 and isnull(跟进方式,0) not in (select ord from sortonehy where gate2=98 and del=1) )"
			cn.execute "insert into reply (ord,ord2,sort1,gj1,gj2,name,name2,sort98,intro,cateid,date7,cateid2,cateid3,del)" & vbcrlf & _
			"                       ""select a.ord,a.ord,1,b.[""&arrName(4)&""],b.[""&arrName(5)&""],(select name from gate aa  where aa.ord=a.cateid),(select name from person where del=1 and ord=b.[""&arrName(17)&""]),b.跟进方式,b.洽谈进展,a.cateid,getdate(),-1,0,1 from tel a, #kfdrList b where a.tel_excel_drSign=b.up_index and datalength(isnull(b.洽谈进展,''))>0 and isnull(b.跟进方式,0)>0 and isnull(b.跟进方式,0) in (select ord from sortonehy where gate2=98 and del=1) and a.ord > " &  maxord
			cn.execute "insert into reply (ord,ord2,sort1,gj1,gj2,name,name2,sort98,intro,cateid,date7,cateid2,cateid3,del)" & vbcrlf & _
			"                       ""select a.ord,b.[""&arrName(17)&""],8,b.[""&arrName(4)&""],b.[""&arrName(5)&""],(select name from gate aa  where aa.ord=a.cateid),(select name from person where del=1 and ord=b.[""&arrName(17)&""]),b.跟进方式,b.洽谈进展,a.cateid,getdate(),-1,0,1 from tel a, #kfdrList b where a.tel_excel_drSign=b.up_index and datalength(isnull(b.洽谈进展,''))>0 and isnull(b.跟进方式,0)>0 and isnull(b.跟进方式,0) in (select ord from sortonehy where gate2=98 and del=1) and a.ord > " &  maxord
			cn.execute "update tel set datelast = getdate() where ord >" & maxord & " and ord < " & t_ord & "  and exists(select ord from reply where ord=tel.ord and sort1=1)"
			cn.execute  "update reply set cateid2 = bm , cateid3 = xz from (" & vbcrlf & _
			"  select sorce as bm, sorce2 as xz , ord  from gate" & vbcrlf & _
			") a where a.ord = cateid and cateid2=-1 "
'select sorce as bm, sorce2 as xz , ord  from gate & vbcrlf & _
			uploader.ShowProc "写入客户资料：写入完成            进度：" ,1000
			If arrShow(20)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) "&_
				"   select 联系人ID,'联系人与第' + cast(isnull((select min(联系人ID) from #lxrtb b "&_
				"where isnull(b.[&khmobile&],'')=isnull(a.[&khmobile&],'') and isnull(a.客户ID,0)=isnull(b.客户ID,0) ),0) as varchar(10)) +'行重复' "&_
				"from #lxrtb a "&_
				"   where len(isnull(["&khmobile&"],''))>0 and 联系人ID not in (select min(联系人ID) from #lxrtb group by ["&khmobile&"],客户ID )"
				cn.execute "delete from #lxrtb where len(isnull(["&khmobile&"],''))>0 "&_
				"   and 联系人ID not in (select min(联系人ID) from #lxrtb group by ["&khmobile&"],客户ID)" , n1
				cn.execute "insert into #k_fail(行号,失败原因) "&_
				"   select 联系人ID,'联系人与第' + cast(isnull((select min(联系人ID) from #lxrtb b "&_
				"where len(isnull([&khmobile&],''))=0 and isnull(a.[&khlxr&],'')=isnull(b.[&khlxr&],'') "&_
				"                                                   and isnull(a.客户ID,0)=isnull(b.客户ID,0)),0) as varchar(10)) +'行重复' "&_
				"   from #lxrtb a where len(isnull(["&khmobile&"],''))=0 "&_
				"   and 联系人ID not in (select min(联系人ID) from #lxrtb where len(isnull(["&khmobile&"],''))=0 group by ["&khlxr&"],客户ID)"
				cn.execute "delete from #lxrtb where len(isnull(["&khmobile&"],''))=0 "&_
				"   and 联系人ID not in (select min(联系人ID) from #lxrtb where len(isnull(["&khmobile&"],''))=0 group by ["&khlxr&"],客户ID)", n2
				cn.execute "insert into #k_all (内容) values ('从导入文件删除" & (n1+n2) & "条重复的非主联系人记录')"
				cn.execute "insert into #k_fail(行号,失败原因) select 联系人ID,'手机号码已存在' from #lxrtb b where len(isnull(["&khmobile&"],''))>0 "&_
				"   and ["&khmobile&"] in (select mobile from person where del in (1,2)) "
				cn.execute "delete from #lxrtb where len(isnull(["&khmobile&"],''))>0 and ["&khmobile&"] in (select mobile from person where del in (1,2))" , n1
				cn.execute "insert into #k_fail(行号,失败原因) select 联系人ID,'联系人已存在' from #lxrtb b "&_
				" where 联系人ID in (select a.联系人ID from #lxrtb a, #kftb b , tel c , person d "&_
				"                   where a.客户ID=b.kid and c.name=b.["&khName&"] and d.company =c.ord and c.del in (1,2) and d.del in (1,2) and d.name=a.["&khlxr&"] and len(d.mobile) = 0 ) and len(isnull(["&khmobile&"],''))=0  "
				cn.execute "delete from #lxrtb where  联系人ID in (select a.联系人ID "&_
				"                                       from #lxrtb a, #kftb b , tel c , person d where a.客户ID=b.kid and c.name=b.["&khName&"] "&_
				"                                       and d.company =c.ord and c.del in (1,2) and d.del in (1,2) and d.name=a.["&khlxr&"] and len(d.mobile) = 0 ) and len(isnull(["&khmobile&"],''))=0" , n2
				cn.execute "insert into #k_all (内容) values ('从导入文件删除" & n1 & "条手机号码已存在的非主联系人记录，删除" & n2 & "条联系人已存在的非主联系人记录')"
			end if
			If arrShow(29)=1 Then
				cn.execute "insert into #k_fail(行号,失败原因) select 联系人ID,'"&arrName(29)&"无效,不识别“' + cast(["&arrName(29)&"] as varchar(255)) + '”。' from #lxrtb where isnumeric(isnull(cast(["&arrName(29)&"] as varchar(32)),'0'))=0"
'If arrShow(29)=1 Then
				cn.execute "delete from #lxrtb where isnumeric(isnull(cast(["&arrName(29)&"] as varchar(32)),'0'))=0", n3
				cn.execute "insert into #k_all (内容) values ('从导入文件删除" & n3 & "条"&arrName(29)&"不识别记录')"
			end if
			cn.execute "insert into #k_fail(行号,失败原因) select 联系人ID,'关联客户未能成功导入,请核查对应客户未导入信息' from #lxrtb where 客户ID not in (select up_index from #kfdrList ) "
			cn.execute "delete from #lxrtb where 客户ID not in (select up_index from #kfdrList ) " , n3
			cn.execute "insert into #k_all (内容) values ('从导入文件删除" & n3 & "条关联客户未能成功导入的非主联系人记录') "
			n = uploader.autoHandTextFieldType("#kftb")
			n = uploader.autoHandTextFieldType("#lxrtb")
			sql = "insert into person (name,"
			If arrShow(30)=1 Then sql=sql & "sex,"
			If arrShow(27)=1 Then sql=sql & "part1,"
			If arrShow(31)=1 Then sql = sql & "year1,age,"
			sql = sql & "birthdayType,"
			If arrShow(28)=1 Then sql=sql & "p.[job],"
			If arrShow(29)=1 Then sql=sql & "p.[role],"
			If arrShow(19)=1 Then sql=sql & "phone,"
			If arrShow(21)=1 Then sql=sql & "fax,"
			If arrShow(20)=1 Then sql=sql & "mobile,"
			If arrShow(22)=1 Then sql=sql & "email,"
			If arrShow(23)=1 Then sql=sql & "qq,"
			If arrShow(24)=1 Then sql=sql & "msn,"
			If arrShow(100)=1 Then sql=sql & "weixinAcc,"
			sql = sql & "sort,sort1,del,cateid,date7,date4,company,area,trade,numc1,date8)"
			sql = sql & "select distinct cast(a.["&khlxr&"] as nvarchar(50)),"
			If arrShow(30)=1 Then sql=sql & "cast(a.["&arrName(30)&"] as nvarchar(10)),"
			If arrShow(27)=1 Then sql=sql & "cast(a.["&arrName(27)&"] as nvarchar(50)),"
			If arrShow(31)=1 Then
				sql = sql &  "(case when isdate(a.["&arrName(31)&"])=1 then a.["&arrName(31)&"] else null end),(case when isdate(["& arrName(31) &"])=1 then datediff(YY,isnull(["& arrName(31) &"],'1900-1-1'),getdate()) else null end),"
'If arrShow(31)=1 Then
			end if
			If arrShow(31)=1 Then
				sql=sql & "(case when len(["& arrName(31) &"])>0 then 1 else 0 end),"
			else
				sql=sql & "0,"
			end if
			If arrShow(28)=1 Then sql=sql & "cast(a.["&arrName(28)&"] as nvarchar(50)),"
			If arrShow(29)=1 Then sql=sql & "a.["&arrName(29)&"],"
			If arrShow(19)=1 Then sql=sql & "cast(a.["&khphone&"] as nvarchar(50)),"
			If arrShow(21)=1 Then sql=sql & "cast(a.["&arrName(21)&"] as nvarchar(50)),"
			If arrShow(20)=1 Then sql=sql & "cast(a.["&khmobile&"] as nvarchar(50)),"
			If arrShow(22)=1 Then sql=sql & "cast(a.["&arrName(22)&"] as nvarchar(50)),"
			If arrShow(23)=1 Then sql=sql & "cast(a.["&arrName(23)&"] as nvarchar(50)),"
			If arrShow(24)=1 Then sql=sql & "cast(a.["&arrName(24)&"] as nvarchar(50)),"
			If arrShow(100)=1 Then sql=sql & "cast(a.["&arrName(100)&"] as nvarchar(100)) as ["&arrName(100)&"],"
			sql = sql & "c.sort,c.sort1,1, " & app.info.user & ",'" & now & "','" & date & "',c.ord,c.area,cast(c.trade as nvarchar(20)),1,getdate()  from #lxrtb a , #kftb b , tel c where a.客户ID = b.kid and c.name = b.["&khName&"] and isnull(b.["&arrName(3)&"],'')=isnull(c.khid,'') and c.ord>"& maxord
			cn.execute sql , n
			cn.execute "update person set cateid2 = sorce , cateid3 = sorce2  from gate a where person.cateid=a.ord and person.ord>" & maxord2 & " and cateid2 is null"
			cn.execute "insert into #k_all (内容) values ('写入" & n & "条非主联系人记录')"
			uploader.ShowProc "写入客户资料：写入完成          进度：" ,1000
			uploader.ShowProc "写入客户扩展自定义： 写入数据           进度：" ,600
			kz_sql=""
			set rs_kz_zdy=server.CreateObject("adodb.recordset")
			kz_sql="select id,FName from erp_customFields  where TName=1  and IsUsing=1 and canInport=1 order by FOrder desc "
			rs_kz_zdy.open kz_sql,cn,1,1
			do while not rs_kz_zdy.eof
				kz_sql2="insert into erp_customValues(Fieldsid,orderid,fvalue) " _
				& " select "&rs_kz_zdy("id")&",a.ord,isnull(b.["&rs_kz_zdy("FName")&"],'') from tel a ,#kfdrList b where a.tel_excel_drSign=b.up_index and a.ord > " &  maxord
				kz_sql=kz_sql&" "&kz_sql2
				rs_kz_zdy.movenext
			loop
			rs_kz_zdy.close
			set rs_kz_zdy=nothing
			cn.execute(kz_sql)
			uploader.ShowProc "写入客户扩展自定义： 写入完成           进度：" ,1000
			cn.execute  "update person set age='' where age is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set jg='' where jg is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set part1='' where part1 is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set job='' where job is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set phone='' where phone is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set phone2='' where phone2 is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set fax='' where fax is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set mobile='' where mobile is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set email='' where email is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set msn='' where msn is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set qq='' where qq is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set zip='' where zip is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set address='' where address is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set year1='' where year1 is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set joy='' where joy is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set intro='' where intro is null and ord>" & maxord2 & vbcrlf
			cn.execute  "update person set pym=dbo.getPinYin(name), xl='',xw='',zy='',yx='',mz='',mobile2='',sg='',tz='',tx='',xm=''," & vbcrlf & _
			"xy='',xyname='',yj='',yjsort='',yjname='',yjsize='',hc='',hcsort='',jz='',jk='',jb='',sc='',scsort='',scys='',scpz='',tezheng=''" & vbcrlf & _
			"where xl is null and ord>" & maxord2
			sql = "update tel set pym = dbo.getPinYin(name) where pym is null and ord > " & maxord & vbcrlf
			sql=sql & "update tel set phone = '' where phone is null and ord > " & maxord & vbcrlf
			sql=sql & "update tel set fax = '' where fax is null and ord > " & maxord & vbcrlf
			sql=sql & "update tel set khid = '' where khid is null and ord > " & maxord & vbcrlf
			sql=sql & "update tel set email = '' where email is null and ord > " & maxord & vbcrlf
			sql=sql & "update tel set faren = '' where faren is null and ord > " & maxord & vbcrlf
			sql=sql & "update tel set url = '' where url is null and ord > " & maxord & vbcrlf
			sql=sql & "update tel set zip = '' where zip is null and ord > " & maxord & vbcrlf
			sql=sql & "update tel set address = '' where address is null and ord > " & maxord & vbcrlf
			sql=sql & "update tel set intro = '' where intro is null and ord > " & maxord & vbcrlf
			sql=sql & "update tel set gate=''" & vbcrlf
			sql=sql & "where gate is null and ord> " & maxord & vbcrlf
			sql=sql & "update tel set zdy1 = '' where zdy1 is null and ord> " & maxord & vbcrlf
			sql=sql & "update tel set zdy2 = '' where zdy2 is null and ord> " & maxord & vbcrlf
			sql=sql & "update tel set zdy3 = '' where zdy3 is null and ord> " & maxord & vbcrlf
			sql=sql & "update tel set zdy4 = '' where zdy4 is null and ord> " & maxord & vbcrlf
			sql=sql & "update tel set zdy5 = 0 where zdy5 is null and ord> " & maxord & vbcrlf
			sql=sql & "update tel set zdy6 = 0 where zdy6 is null and ord> " & maxord & vbcrlf
			sql=sql & "update tel set hk_xz = 0 where hk_xz is null and ord> " & maxord & vbcrlf
			set rs=server.CreateObject("adodb.recordset")
			sql="select num1 from setjm3  where ord=1"
			rs.open sql,cn,1,1
			if rs.eof then
				num1=""
			else
				num1=rs("num1")
			end if
			rs.close
			set rs=nothing
			sql=sql & "update tel set hk_xz = ROUND(hk_xz,"&num1&",1)  where ord> " & maxord & vbcrlf
			sql=sql & "update tel set share = 0 where share is null and ord> " & maxord & vbcrlf
			cn.execute sql
			Dim ordarr()
			Dim sortarr()
			Dim sort1arr()
			Dim replyarr()
			arr_i=0
			Dim crss
			Set crs=cn.execute("select a.ord,a.sort,a.sort1 from tel a where a.ord > " & maxord & " and a.ord < " & t_ord )
			If crs.eof=False then
				Do While Not crs.eof
					ReDim Preserve ordarr(arr_i)
					ReDim Preserve sortarr(arr_i)
					ReDim Preserve sort1arr(arr_i)
					ReDim Preserve replyarr(arr_i)
					ordarr(arr_i)=getInt(crs("ord"))
					sortarr(arr_i)=getInt(crs("sort"))
					sort1arr(arr_i)=getInt(crs("sort1"))
					Set crss=cn.execute("select top 1 id from reply where sort1=8 and del=1 and ord="&crs("ord")&" and id>"&maxord&" order by date7 desc")
					If crss.eof=False Then
						replyarr(arr_i)=crss(0).value
					else
						replyarr(arr_i)=0
					end if
					crss.close : Set crss=Nothing
					arr_i=arr_i+1
					crss.close : Set crss=Nothing
					crs.movenext
				Loop
			end if
			crs.close : Set crs=Nothing
			For vi=0 To arr_i-1
				crs.close : Set crs=Nothing
				If Len(sort1arr(vi))>0 And isnumeric(sort1arr(vi)) Then
					call autoSkipSort(ordarr(vi),sortarr(vi),sort1arr(vi),11,replyarr(vi),True,"客户导入")
				end if
			next
			cn.execute "update a set a.area = b.area  from person a inner join tel b on a.company = b.ord and a.area<>b.area"
			cn.execute "update a set a.trade = b.trade  from person a inner join tel b on a.company = b.ord and a.trade<>b.trade"
			cn.execute "SET ANSI_WARNINGS On"
			Page_InsertDataBase = true
		end function
		Sub Page_OnFileSave(uploader)
			if uploader.InsertTableByExcel("#kfdrList","") then
				uploader.AddReport true
				Response.write "<script language=javascript>alert('导入完成');</script>"
			end if
		end sub
		Sub Page_OnCreateTempTable(uploader)
			Dim arrShow, arrName,arrRequired
			Call GetDefFieldName(arrShow, arrName,arrRequired)
			chk_col=""
			set rs_kz_zdy=server.CreateObject("adodb.recordset")
			kz_sql="select id,FName from erp_customFields  where TName=1  and IsUsing=1 and canInport=1 order by FOrder desc"
			rs_kz_zdy.open kz_sql,cn,1,1
			do while not rs_kz_zdy.eof
				CHK_Fields=CHK_Fields&"|"&rs_kz_zdy("FName")&"="&rs_kz_zdy("FName")&"=0="
				rs_kz_zdy.movenext
			loop
			rs_kz_zdy.close
			set rs_kz_zdy=nothing
			Dim strcols
			strcols=""
			If arrShow(3)=1 Then strcols = strcols & arrName(3)& "=khid=0=tel"
			If arrShow(1)=1 Then strcols = strcols & "|" & arrName(1)& "=name=0=tel"
			If arrShow(4)=1 Then strcols = strcols & "|" & arrName(4)& "=sort=1=tel"
			If arrShow(5)=1 Then strcols = strcols & "|" & arrName(5)& "=sort1=1=tel"
			If arrShow(7)=1 Then strcols = strcols & "|" & arrName(7)& "=area=1=tel"
			If arrShow(8)=1 Then strcols = strcols & "|" & arrName(8)& "=trade=1=tel"
			If arrShow(6)=1 Then strcols = strcols & "|" & arrName(6)& "=ly=1=tel"
			If arrShow(9)=1 Then strcols = strcols & "|" & arrName(9)& "=jz=1=tel"
			If ZBRuntime.MC(207101) And ubound(arrShow)>=52 Then
				If arrShow(52)=1 Then strcols = strcols & "|" & arrName(52)& "=credit=1=tel"
			end if
			If arrShow(14)=1 Then strcols = strcols & "|" & arrName(14)& "=faren=0=tel"
			If arrShow(15)=1 Then strcols = strcols & "|" & arrName(15)& "=zijin=0=tel"
			If arrShow(10)=1 Then strcols = strcols & "|" & arrName(10)& "=url=0=tel"
			If arrShow(11)=1 Then strcols = strcols & "|" & arrName(11)& "=hk_xz=0=tel"
			If arrShow(12)=1 Then strcols = strcols & "|" & arrName(12)& "=address=0=tel"
			If arrShow(13)=1 Then strcols = strcols & "|" & arrName(13)& "=zip=0=tel"
			If arrShow(33)=1 Then strcols = strcols & "|" & arrName(33)& "=product=0=tel"
			If arrShow(34)=1 Then strcols = strcols & "|" & arrName(34)& "=c2=0=tel"
			If arrShow(35)=1 Then strcols = strcols & "|" & arrName(35)& "=c3=0=tel"
			If arrShow(36)=1 Then strcols = strcols & "|" & arrName(36)& "=c4=0=tel"
			If arrShow(37)=1 Then strcols = strcols & "|" & arrName(37)& "=intro=0=tel"
			If arrShow(38)=1 Then strcols = strcols & "|" & arrName(38)& "=bank_1=0=tel"
			If arrShow(39)=1 Then strcols = strcols & "|" & arrName(39)& "=bank_2=0=tel"
			If arrShow(50)=1 Then strcols = strcols & "|" & arrName(50)& "=bank_7=0=tel"
			If arrShow(40)=1 Then strcols = strcols & "|" & arrName(40)& "=bank_3=0=tel"
			If arrShow(41)=1 Then strcols = strcols & "|" & arrName(41)& "=bank_4=0=tel"
			If arrShow(42)=1 Then strcols = strcols & "|" & arrName(42)& "=bank_5=0=tel"
			If arrShow(43)=1 Then strcols = strcols & "|" & arrName(43)& "=bank_6=0=tel"
			If arrShow(44)=1 Then strcols = strcols & "|" & arrName(44)& "=bank2_1=0=tel"
			If arrShow(45)=1 Then strcols = strcols & "|" & arrName(45)& "=bank2_2=0=tel"
			If arrShow(51)=1 Then strcols = strcols & "|" & arrName(51)& "=bank2_7=0=tel"
			If arrShow(46)=1 Then strcols = strcols & "|" & arrName(46)& "=bank2_3=0=tel"
			If arrShow(47)=1 Then strcols = strcols & "|" & arrName(47)& "=bank2_4=0=tel"
			If arrShow(48)=1 Then strcols = strcols & "|" & arrName(48)& "=bank2_5=0=tel"
			If arrShow(49)=1 Then strcols = strcols & "|" & arrName(49)& "=bank2_6=0=tel"
			If arrShow(17)=1 Then strcols = strcols & "|" & arrName(17)& "=person=0=tel"
			If arrShow(19)=1 Then
				strcols = strcols & "|" & arrName(19)& "=phone=0=tel"
				strcols = strcols & "|" & arrName(19)& "=phone=0=person"
			end if
			If arrShow(21)=1 Then
				strcols = strcols & "|" & arrName(21)& "=fax=0=tel"
				strcols = strcols & "|" & arrName(21)& "=fax=0=person"
			end if
			If arrShow(22)=1 Then
				strcols = strcols & "|" & arrName(22)& "=email=0=tel"
				strcols = strcols & "|" & arrName(22)& "=email=0=person"
			end if
			strcols = strcols & "|销售人员=cateid=1=tel"
			strcols = strcols & "|添加时间=date1=0=tel"
			strcols = strcols & "|up_index=tel_excel_drSign=0=tel"
			If arrShow(30)=1 Then strcols = strcols & "|" & arrName(30)& "=sex=0=person"
			If arrShow(27)=1 Then strcols = strcols & "|" & arrName(27)& "=part1=0=person"
			If arrShow(28)=1 Then strcols = strcols & "|" & arrName(28)& "=job=0=person"
			If arrShow(29)=1 Then strcols = strcols & "|" & arrName(29)& "=role=1=person"
			If arrShow(20)=1 Then strcols = strcols & "|" & arrName(20)& "=mobile=0=person"
			If arrShow(23)=1 Then strcols = strcols & "|" & arrName(23)& "=qq=0=person"
			If arrShow(24)=1 Then strcols = strcols & "|" & arrName(24)& "=msn=0=person"
			If arrShow(31)=1 Then strcols = strcols & "|" & arrName(31)& "=year1=0=person"
			If arrShow(100)=1 Then strcols = strcols & "|" & arrName(100)& "=weixinAcc=0=person"
			strcols = strcols & "|跟进方式=sort98=1=reply|洽谈进展=intro=0=reply"
			strcols = strcols & "|账期=fkdays=0=tel|结算日期=fkdate=0=tel|添加人员=cateadd=1=tel"
			if arrShow(16)=1 then strcols = strcols & "|"&arrName(16)&"(技术)=pernum2=1=tel|"&arrName(16)&"(销售)=pernum1=1=tel"
			uploader.baseCols = strcols & CHK_Fields
			uploader.defdbtable = "tel"
			uploader.defColSort =  1
		end sub
		sub Page_LinkFieldHand(tmp , ywname , dbname , gl , UserDefCol, dbtable)
			Dim arrShow, arrName,arrRequired
			Call GetDefFieldName(arrShow, arrName,arrRequired)
			select case ywname
			case ""&arrName(4)&"" : cn.execute "update " & tmp & " set ["&arrName(4)&"] = cast(a.ord as varchar(10)) from sort4 a where a.sort1=["&arrName(4)&"]"
			case ""&arrName(5)&"" : cn.execute "update " & tmp & " set ["&arrName(5)&"] = cast(a.ord as varchar(10)) from sort5 a where a.sort2=["&arrName(5)&"] and ["&arrName(4)&"]=a.sort1 and isnumeric(cast(["&arrName(4)&"] as varchar(32)))=1 "
			case ""&arrName(7)&"" : cn.execute "update " & tmp & " set ["&arrName(7)&"] = cast(a.id as varchar(10)) from menuarea a where not exists(select top 1 1 from menuarea where id1=a.id) and a.menuname=["&arrName(7)&"]"
			case ""&arrName(8)&"" : cn.execute "update " & tmp & " set ["&arrName(8)&"] = cast(a.ord as varchar(10)) from sortonehy a where a.gate2=11 and a.sort1 = ["&arrName(8)&"]"
			case ""&arrName(6)&"" : cn.execute "update " & tmp & " set ["&arrName(6)&"] = cast(a.ord as varchar(10)) from sortonehy a where a.gate2=13 and a.sort1 = ["&arrName(6)&"]"
			case ""&arrName(9)&"" : cn.execute "update " & tmp & " set ["&arrName(9)&"] = cast(a.ord as varchar(10)) from sortonehy a where a.gate2=14 and a.sort1 = ["&arrName(9)&"]"
			case ""&arrName(29)&"" : cn.execute "update " & tmp & " set ["&arrName(29)&"] = cast(a.ord as varchar(10)) from sort9 a where a.sort1 = ["&arrName(29)&"]"
			case "跟进方式" : cn.execute "update " & tmp & " set 跟进方式 = cast(a.ord as varchar(10)) from sortonehy a where a.gate2=98 and a.sort1 = 跟进方式"
			case "销售人员" : cn.execute "update " & tmp & " set 销售人员 = cast(a.ord as varchar(10)) from gate a where a.name = 销售人员 and a.del=1"
			case "添加人员" :
			cn.execute "update " & tmp & " set 添加人员 =  (case when (select count(1) from gate where name=a.name and del=1)>1 then a.name+'@@@cateadd' else cast(a.ord as varchar(10)) end) from gate a where a.name = 添加人员 and a.del=1"
'case "添加人员" :
			cn.execute "update " & tmp & " set 添加人员 = cast('"& usid &"' as varchar(32)) where cast([添加人员] as varchar(32)) is null or cast([添加人员] as varchar(32))=''"
			end Select
			If ZBRuntime.MC(207101)  And ubound(arrShow)>=52 Then
				If ywname = ""&arrName(52)&"" Then
					cn.execute "update " & tmp & " set ["&arrName(52)&"] = cast(a.ord as varchar(10)) from sortonehy a where a.gate2=19 and a.sort1 = ["&arrName(52)&"]"
				end if
			end if
		end sub
		sub updatebug(tbname)
			Dim arrShow, arrName,arrRequired
			Call GetDefFieldName(arrShow, arrName,arrRequired)
			dim sql
			sql=sql & "select * into #errmap from ( " & vbcrlf
			sql=sql & "        select distinct a.ord  as tel_id,  a.person as per_id" & vbcrlf
			sql=sql & "         from tel a, tel b  where a.person = b.person and a.ord > b.ord" & vbcrlf
			sql=sql & "         and a.date1 >= '2011-7-5' and a.person > 0" & vbcrlf
			sql=sql & "         from tel a, tel b  where a.person = b.person and a.ord > b.ord" & vbcrlf
			sql=sql & ") t" & vbcrlf
			sql=sql & "select b.ord  as tel_id, c.ord as per_id into #okmap " & vbcrlf
			sql=sql & "from " & tbname & " a " & vbcrlf
			sql=sql & "inner join tel b  on a.["&arrName(1)&"]=b.name " & vbcrlf
			sql=sql & "inner join person c on " & vbcrlf
			sql=sql & "        isnull(c.name,'') = isnull(a.["&arrName(17)&"],'') " & vbcrlf
			If arrShow(19)=1 Then sql=sql & " and isnull(c.phone,'') = isnull(a.["&arrName(19)&"],'')"
			If arrShow(20)=1 Then sql=sql & "  and isnull(c.mobile,'') = isnull(a.["&arrName(20)&"],'')" & vbcrlf
			If arrShow(22)=1 Then sql=sql & "  and isnull(c.email,'')= isnull(a.["&arrName(22)&"],'')" & vbcrlf
			If arrShow(23)=1 Then sql=sql & "  and isnull(c.qq,'') = isnull(a.["&arrName(23)&"],'')" & vbcrlf
			sql=sql & "update tel set person =x.per_id  " & vbcrlf
			sql=sql & "from  #okmap x " & vbcrlf
			sql=sql & "where x.tel_id=tel.ord  and tel.ord in (select tel_id from #errmap)" & vbcrlf
			cn.execute sql
			Response.write "<script>alert('修复完毕');</script>"
		end sub
		
%>
