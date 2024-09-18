<%@ language=VBScript %>
<%
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
				'GetPowerIntro = r
			end if
			rs.close
			set rs = nothing
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
					'response.flush
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
			'Exit Function
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
			'Response.write app.headhtml
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
			'Response.write "px' valign=top>" & vbcrlf & "                              <div class='divdlgBody' style='width:"
			Response.write "px;height:"
			Response.write height-58
			'Response.write "px;height:"
			Response.write "px;overflow:auto;padding:4px;text-align:center;'>" & vbcrlf & "                                    <table style='width:"
			'Response.write "px;height:"
			Response.write width-50
			'Response.write "px;height:"
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
			'itemValue = LCase(itemValue)
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
	
	Function getConnection()
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
		conn.CommandTimeout = 600
		if abs(err.number) > 0 then
			Response.write "数据库链接失败 - [" & err.Description & "]"
'if abs(err.number) > 0 then
			call AppEnd
		end if
		Set getConnection = conn
	end function
	Function GetPrintNum(sort,ord)
		Dim cn : Set cn = getConnection()
		If sort&"" = "" Then sort = 0
		If ord&"" = "" Then ord = 0
		Dim rs_Print : Set rs_Print = cn.execute ("select count(1) as PrintNum from PrinterInfo where sort = " & sort & " and formID = " & ord)
		GetPrintNum = rs_Print("PrintNum")
		rs_Print.close
		Set rs_Print = nothing
	end function
	Function GetPrintInfo(cn, datatype , ord , rType)
		Dim rs , times ,csStr , statusStr
		Set rs = cn.execute("select times from printtimes where datatype ="& datatype &" and ord=" & ord)
		If rs.eof = False Then
			statusStr = "<font color=green>[已打印]</font>"
			times =  rs("times").value
		else
			statusStr = "<font color=red>[未打印]</font>"
			times = 0
		end if
		rs.close
		Set rs=Nothing
		Dim withs : withs = 84+8*Len(times)
		Set rs=Nothing
		If rType=2 Then
			csStr = "<input type='button' name='btnPrint1' value='打印记录("& times &"次)'   onClick='javascript:window.open(""../Manufacture/inc/PrinterRrcorderList.asp?formid="& sdk.base64.pwurl(ord)&"&sort="& datatype &""",""newwin88"",""width="" + 900 + "",height="" + 500 + "",fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150"")'  class='anybutton' />"
		else
			csStr = times
		end if
		If rType = 1 Then
			GetPrintInfo = statusStr
		else
			GetPrintInfo = csStr
		end if
	end function
	Function SavePrintInfo(cn)
		dim id, formid, html, rs, [sort], ord, ord1  ,isSum,count
		id = request("id")
		formid = request("ord")
		[sort] = request("sort")
		isSum = request("isSum")
		If isSum&""="" Then isSum = 0
		count = request("count")
		If count&""="" Then count = 0
		html= ""
		if len(formid) = 0 then exit Function
		if len(id) = 0 or isnumeric(id)=0 then exit Function
		if len(sort) = 0 or isnumeric(sort)=0 then exit Function
		Dim oldcount : oldcount = GetPrintInfo(cn,[sort],formid,3)
		If cdbl(oldcount)-CDbl(count)<>0 And count>=0 Then
'Dim oldcount : oldcount = GetPrintInfo(cn,[sort],formid,3)
			SavePrintInfo = "count"
			exit Function
		end if
		on error resume next
		cn.begintrans
		formid = split(formid,",")
		for i = 0 to ubound(formid)
			if isnumeric(formid(i)) Then
				If cn.execute("select 1 from printtimes where datatype ="& [sort] &" and ord=" & formid(i)).eof=true Then
					cn.execute("insert into printtimes (datatype , ord ,times)values ("& [sort] &","& formid(i) &",1) ")
				else
					cn.execute("update printtimes set times = times + 1 where datatype ="& [sort] &" and ord=" & formid(i))
					cn.execute("insert into printtimes (datatype , ord ,times)values ("& [sort] &","& formid(i) &",1) ")
				end if
				cn.execute("insert into PrinterInfo (templateID, formID, sort, html, addCate, addDate,isSum,isOld) values (" & id & ", " & formid(i) & ", " & [sort] & ", '" & html & "', " & session("personzbintel2007") & ", '" & now() & "','"& isSum &"',1)")
				ord = GetIdentity("PrinterInfo","id","addcate","")
				cn.execute ("update PrinterInfo set ord = id where id = " & ord)
				cn.execute ("insert into PrinterHistory (PrinterInfoID, PrintCate, PrintDate) values (" & ord & ", " & session("personzbintel2007") & ", '" & now() & "')")
				ord1 = GetIdentity("PrinterHistory","id","PrintCate","")
				cn.execute ("update PrinterHistory set ord = id where id = " & ord1)
			end if
		next
		if err.number <> 0 Then
			cn.RollBackTrans
			SavePrintInfo = "false"
		else
			cn.CommitTrans
			SavePrintInfo = "true"
		end if
	end function
	sub Prt_add_logs(args,action1,sort)
		Dim rs3
		open_rz_system = Application("_open_rz_system")
		if len(open_rz_system) = 0 then
			set rs3=server.CreateObject("adodb.recordset")
			sql3="select intro from setjm where ord=802"
			rs3.open sql3,cn,1,1
			if rs3.eof then
				open_rz_system=0
			else
				open_rz_system=rs3("intro")
			end if
			Application("_open_rz_system")=open_rz_system
			rs3.close
			set rs3=nothing
		end if
		if open_rz_system="1" Then
			dim action_url,type_sys,type_brower,title
			If isnumeric(sort) Then
				set rs3=server.CreateObject("adodb.recordset")
				sql3="select title from PrintTemplate_Type where ord = " & sort
				rs3.open sql3,cn,1,1
				if rs3.eof then
					title=""
				else
					title=rs3("title")
				end if
				rs3.close
				set rs3=nothing
			end if
			action_url=GetUrl()
			action_url=replace(action_url,"'","''")
			type_sys=operationsystem()
			type_brower=browser()
			type_login=args
			sqlStr="Insert Into action_list(username,name,page1,time_login,type_sys,type_brower,type_login,action1) values("
			sqlStr=sqlStr & session("personzbintel2007") & ",'"
			sqlStr=sqlStr & session("name2006chen") & "','"
			sqlStr=sqlStr & action_url & "','"
			sqlStr=sqlStr & now & "','"
			sqlStr=sqlStr & type_sys & "','"
			sqlStr=sqlStr & type_brower & "',"
			sqlStr=sqlStr & type_login & ",'"
			sqlStr=sqlStr & title & action1 & "')"
			on error resume next
			cn.execute(sqlStr)
		end if
	end sub
	Function GetUrl()
		Dim ScriptAddress,Servername,qs
		ScriptAddress = CStr(Request.ServerVariables("SCRIPT_NAME"))
		Servername = CStr(Request.ServerVariables("Server_Name"))
		qs=Request.QueryString
		if qs<>"" then
			GetUrl = ScriptAddress &"?"&qs
		else
			GetUrl = ScriptAddress
		end if
	end function
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
			SystemVer="Windows Server 2012"
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
		ElseIf InStr(agent, "MSIE 9.0") > 0 Then
			browserVer = "Internet Explorer 9.0"
		ElseIf InStr(agent, "MSIE 10.0") > 0 Then
			browserVer = "Internet Explorer 10.0"
		ElseIf InStr(agent, "MSIE 11.0") > 0 Then
			browserVer = "Internet Explorer 11.0"
		ElseIf InStr(agent, "MSIE 12.0") > 0 Then
			browserVer = "Internet Explorer 12.0"
		else
			browserVer=""
		end if
		browser=browserVer
	end function
	Dim Code128A, Code128B, Code128C, EAN128
	Code128A = 0
	Code128B = 1
	Code128C = 2
	EAN128 = 3
	Function Val(ByVal s)
		if s&"" = "" Or Not Isnumeric(s) Then
			val = 0
		else
			val = clng(s)
		end if
	end function
	Function GetCode128(ByVal Char, ByRef ID, ByRef CodingBin, ByVal CodingType)
		Dim FindText,MyArray
		ID = -1
'Dim FindText,MyArray
		Select Case CodingType
		Case 0
		Select Case UCase(Char)
		Case "FNC3": ID = 96: Case "FNC2": ID = 97: Case "SHIFT": ID = 98: Case "CODEC": ID = 99
		Case "CODEB": ID = 100: Case "FNC4": ID = 101: Case "FNC1": ID = 102: Case "STARTA": ID = 103
		Case "STARTB": ID = 104: Case "STARTC": ID = 105: Case "STOP": ID = 106
		Case Else
		FindText = " !""#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_"
'Case Else
		For i = 0 To 31
			FindText = FindText & Chr(i)
		next
		ID = InStr(FindText, UCase(Char)) - 1
		FindText = FindText & Chr(i)
		End Select
		Case 1
		Select Case UCase(Char)
		Case "FNC3": ID = 96: Case "FNC2": ID = 97: Case "SHIFT": ID = 98: Case "CODEC": ID = 99
		Case "FNC4": ID = 100: Case "CODEA": ID = 101: Case "FNC1": ID = 102: Case "STARTA": ID = 103
		Case "STARTB": ID = 104: Case "STARTC": ID = 105: Case "STOP": ID = 106
		Case Else
		FindText = " !""#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~" & Chr(127)
'Case Else
		ID = InStr(FindText, Char) - 1
'Case Else
		End Select
'Case Else
		Select Case UCase(Char)
		Case "CODEB": ID = 100: Case "CODEA": ID = 101: Case "FNC1": ID = 102: Case "STARTA": ID = 103
		Case "STARTB": ID = 104: Case "STARTC": ID = 105: Case "STOP": ID = 106
		Case Else
		ID = Val(Char)
		End Select
		End Select
		MyArray = Array("11011001100","11001101100","11001100110","10010011000","10010001100","10001001100","10011001000","10011000100","10001100100","11001001000","11001000100","11000100100","10110011100","10011011100","10011001110","10111001100","10011101100","10011100110","11001110010","11001011100","11001001110","11011100100","11001110100","11101101110","11101001100","11100101100","11100100110","11101100100","11100110100","11100110010","11011011000","11011000110","11000110110","10100011000","10001011000","10001000110","10110001000","10001101000","10001100010","11010001000","11000101000","11000100010","10110111000","10110001110","10001101110","10111011000","10111000110","10001110110","11101110110","11010001110","11000101110","11011101000","11011100010","11011101110","11101011000","11101000110","11100010110","11101101000","11101100010","11100011010","11101111010","11001000010","11110001010","10100110000","10100001100","10010110000","10010000110","10000101100","10000100110","10110010000","10110000100","10011010000","10011000010","10000110100","10000110010","11000010010","11001010000","11110111010","11000010100","10001111010","10100111100","10010111100","10010011110","10111100100","10011110100","10011110010","11110100100","11110010100","11110010010","11011011110","11011110110","11110110110","10101111000","10100011110","10001011110","10111101000","10111100010","11110101000","11110100010","10111011110","10111101110","11101011110","11110101110","11010000100","11010010000","11010011100","1100011101011")
		If id>=0 then
			CodingBin = MyArray(ID)
		else
			CodingBin = ""
		end if
	end function
	Function GetCode128_ID(ByVal ID)
		Dim MyArray
		MyArray = Array("11011001100","11001101100","11001100110","10010011000","10010001100","10001001100","10011001000","10011000100","10001100100","11001001000","11001000100","11000100100","10110011100","10011011100","10011001110","10111001100","10011101100","10011100110","11001110010","11001011100","11001001110","11011100100","11001110100","11101101110","11101001100","11100101100","11100100110","11101100100","11100110100","11100110010","11011011000","11011000110","11000110110","10100011000","10001011000","10001000110","10110001000","10001101000","10001100010","11010001000","11000101000","11000100010","10110111000","10110001110","10001101110","10111011000","10111000110","10001110110","11101110110","11010001110","11000101110","11011101000","11011100010","11011101110","11101011000","11101000110","11100010110","11101101000","11101100010","11100011010","11101111010","11001000010","11110001010","10100110000","10100001100","10010110000","10010000110","10000101100","10000100110","10110010000","10110000100","10011010000","10011000010","10000110100","10000110010","11000010010","11001010000","11110111010","11000010100","10001111010","10100111100","10010111100","10010011110","10111100100","10011110100","10011110010","11110100100","11110010100","11110010010","11011011110","11011110110","11110110110","10101111000","10100011110","10001011110","10111101000","10111100010","11110101000","11110100010","10111011110","10111101110","11101011110","11110101110","11010000100","11010010000","11010011100","1100011101011")
		If id >=0 then
			GetCode128_ID = MyArray(ID)
		else
			GetCode128_ID = ""
		end if
	end function
	Function Get_EAN_128_Binary(ByVal Data, ByVal CodingType)
		Dim i, Ci
		Dim ID, CodinBin
		Dim CheckSum, CheckCodeID
		Dim CodeStop
		CodeStop = "1100011101011"
		Select Case CodingType
		Case 0
		Get_EAN_128_Binary = "11010000100"
		For i = 1 To Len(Data)
			Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128A)
			CheckSum = CheckSum + i * ID
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128A)
			Get_EAN_128_Binary = Get_EAN_128_Binary + CodinBin
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128A)
		next
		CheckCodeID = (103 + CheckSum) Mod 103
		Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128A)
		Get_EAN_128_Binary = Get_EAN_128_Binary + GetCode128_ID(CheckCodeID) + CodeStop
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128A)
		Case 1
		Get_EAN_128_Binary = "11010010000"
		For i = 1 To Len(Data)
			Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128B)
			CheckSum = CheckSum + i * ID
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128B)
			Get_EAN_128_Binary = Get_EAN_128_Binary + CodinBin
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128B)
		next
		CheckCodeID = (104 + CheckSum) Mod 103
		Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128B)
		Get_EAN_128_Binary = Get_EAN_128_Binary + GetCode128_ID(CheckCodeID) + CodeStop
'Call GetCode128(Mid(Data, i, 1), ID, CodinBin, Code128B)
		Case 2
		Get_EAN_128_Binary = "11010011100"
		For i = 1 To Len(Data) Step 2
			Ci = Ci + 1
'For i = 1 To Len(Data) Step 2
			Call GetCode128(Mid(Data, i, 2), ID, CodinBin, Code128C)
			CheckSum = CheckSum + Ci * ID
'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, Code128C)
			Get_EAN_128_Binary = Get_EAN_128_Binary + CodinBin
'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, Code128C)
		next
		CheckCodeID = (105 + CheckSum) Mod 103
		'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, Code128C)
		Get_EAN_128_Binary = Get_EAN_128_Binary + GetCode128_ID(CheckCodeID) + CodeStop
		'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, Code128C)
		Case Else
		Ci = 1
		CheckSum = 102
		Get_EAN_128_Binary = "11010011100" & "11110101110"
		For i = 1 To Len(Data) Step 2
			Ci = Ci + 1
'For i = 1 To Len(Data) Step 2
			Call GetCode128(Mid(Data, i, 2), ID, CodinBin, EAN128)
			CheckSum = CheckSum + Ci * ID
'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, EAN128)
			Get_EAN_128_Binary = Get_EAN_128_Binary + CodinBin
'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, EAN128)
		next
		CheckCodeID = (105 + CheckSum) Mod 103
		'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, EAN128)
		Get_EAN_128_Binary = Get_EAN_128_Binary + GetCode128_ID(CheckCodeID) + CodeStop
'Call GetCode128(Mid(Data, i, 2), ID, CodinBin, EAN128)
		End Select
	end function
	Function Draw_Code128(ByVal Data, ByVal DrawWidth, ByVal ShowData, ByVal CodingType)
		Dim Binary128
		Dim Binary,CodeLineStr
		Dim i, J
		CodeLineStr=""
		If DrawWidth < 1 Then DrawWidth = 1
		Binary128 = Get_EAN_128_Binary(Data, CodingType)
		For i = 1 To Len(Binary128)
			Binary = Val(Mid(Binary128, i, 1))
			If Binary = 1 Then
				CodeLineStr = CodeLineStr & "1"
			else
				CodeLineStr = CodeLineStr & "0"
			end if
		next
		Draw_Code128 = "{w:'" & DrawWidth & "',d:'" & Data & "',code:'" & CodeLineStr & "'}"
	end function
	
	class PrinterCreator
		public name
		public remark
		public mainSql
		public childSql
		public mainfields
		public childfields
		public title
		public html
		public ord
		public ModelType
		public isModel
		public ismain
		public isDefalut
		public TemplateType
		Public gate1
		public Sub Class_Initialize()
			name = "打印模板测试"
			if App.isSub("priner_init") then
				call printer_init
			end if
		end sub
	end class
	sub page_load
		dim id , rs , rs1 , rcols , item , ptr , i , ii , iii , sql, sort
		id = request.querystring("id")
		[sort] = request.querystring("sort")
		ModelType = request.QueryString("ModelType")
		if (len(id) = 0 or isnumeric(id)=0) and (len([sort]) = 0 or isnumeric([sort])=0) then
			app.showerr "配置问题","无法识别传递的参数."
			exit sub
		end if
		if len(id) = 0 or isnumeric(id)=0 then
			id = 0
		end if
		set ptr = new  PrinterCreator
		sql="select a.title, b.ord, a.printtype, a.ismain, a.remark, a.isDefault, a.isModel,a.gate1 from PrintTemplates a inner join PrintTemplate_Type b on b.id=a.TemplateType where a.id="&id
		set rs = cn.execute(sql)
		if rs.eof=true then
			ptr.title = ""
			ptr.ord = [sort]
			ptr.ismain = "0"
			ptr.remark = ""
			ptr.isDefalut = "0"
			ptr.isModel = "0"
			ptr.gate1 = 1
		else
			ptr.title = rs.fields("title").value
			ptr.ord = rs.fields("ord").value
			ptr.ismain = rs.fields("ismain").value
			ptr.remark = rs.fields("remark").value
			ptr.isDefalut = rs.fields("isDefault").value
			ptr.isModel = rs.fields("isModel").value
			ptr.gate1 = rs.fields("gate1").value
		end if
		rs.close
		ptr.ModelType = ModelType
		sql = "select * from PrintTemplate_Type where ord = " & ptr.ord
		set rs = cn.execute (sql)
		if rs.eof=true then
			ptr.TemplateType = ""
		else
			ptr.TemplateType = rs.fields("title").value
		end if
		rs.close
		Response.write "" & vbcrlf & "<style media=""print"">" & vbcrlf & "   #divpage{" & vbcrlf & "               position:absolute;" & vbcrlf & "              top:0px;" & vbcrlf & "                left:0px;" & vbcrlf & "               right:0px;" & vbcrlf & "              bottom:0px;" & vbcrlf & "             width:210mm;height:297mm;" & vbcrlf & "               overflow:hidden;" & vbcrlf & "        }" & vbcrlf & "      #FramePage{" & vbcrlf & "             position:absolute;" & vbcrlf & "              left:0px;top:0px;" & vbcrlf & "               width:210mm;height:290mm;" & vbcrlf & "               z-index:1000;" & vbcrlf & "           font-size:12px;" & vbcrlf & " }" & vbcrlf & "       .PrintPage{ " & vbcrlf & "            position:relative;" & vbcrlf & "      }" & vbcrlf & "       #mFrame{" & vbcrlf & "           position:absolute;" & vbcrlf & "              top:0px;left:0px;" & vbcrlf & "               z-index:10000;" & vbcrlf & "  }" & vbcrlf & "       #billtopbardiv{display:none;}" & vbcrlf & "   #bottomMargin{display:none}" & vbcrlf & "     #framemargintop{display:none;}" & vbcrlf & "  #tool{display:none;}" & vbcrlf & "" & vbcrlf & "   #printlogo{" & vbcrlf & "             width:32px;" & vbcrlf & "             height:10mm;" & vbcrlf & "            background-image:url(../../images/printlogo.gif);" & vbcrlf & "               background-repeat:no-repeat;" & vbcrlf & "            background-position:center center;" & vbcrlf & "      }" & vbcrlf & "" & vbcrlf & "       .printerctl {" & vbcrlf & "             position:absolute;" & vbcrlf & "              width:auto;" & vbcrlf & "             height:auto;" & vbcrlf & "            overflow:hidden;" & vbcrlf & "                cursor:default;" & vbcrlf & "         padding:0px;" & vbcrlf & "            font-size:14px;" & vbcrlf & " }" & vbcrlf & "" & vbcrlf & "       div.printerctlbody {" & vbcrlf & "            padding:3px;" &vbcrlf & "         white-space: nowrap;" & vbcrlf & "            overflow:hidden;" & vbcrlf & "                position:relatve;" & vbcrlf & "       } " & vbcrlf & "      div.msout .printerctlbody {" & vbcrlf & "             padding:4px;" & vbcrlf & "            white-space: nowrap;" & vbcrlf & "            overflow:hidden;" & vbcrlf & "                position:relatve;" & vbcrlf & "}" & vbcrlf & "       div.msout .printercltool {" & vbcrlf & "              display:none;" & vbcrlf & "   }" & vbcrlf & "       div.msout .printerclresize {" & vbcrlf & "            display:none;" & vbcrlf & "   }" & vbcrlf & "" & vbcrlf & "       div.active .printerctlbody {" & vbcrlf & "            padding:4px;" & vbcrlf & "            white-space: nowrap;" &vbcrlf & "         overflow:hidden;" & vbcrlf & "                position:relatve;" & vbcrlf & "       }" & vbcrlf & "" & vbcrlf & "       div.active .printercltool {" & vbcrlf & "             display:none;" & vbcrlf & "   }" & vbcrlf & "       div.active .printerclresize {" & vbcrlf & "           display:none;" & vbcrlf & "   }" & vbcrlf & "       #billtopbartable{"& vbcrlf & " display : none ; "& vbcrlf & " }" & vbcrlf &  "table {display : none } "& vbcrlf &"  table.v { "& vbcrlf & " display : inline - block ; "& vbcrlf &"  } "& vbcrlf & vbcrlf &"  table.printertable {" & vbcrlf & " display : inline - block ; "& vbcrlf &  "border - collapse : separate ;" & vbcrlf & " border-bottom: 0pt;" & vbcrlf & "           border-left: #000000 0.5pt solid;" & vbcrlf & "               border-top: #000000 0.5pt solid;" & vbcrlf & "                border-right: 0pt;" & vbcrlf & "      }" & vbcrlf & "       table.printertable th{" & vbcrlf & "          padding:4px;" & vbcrlf & "    }" & vbcrlf & "       table.printertable td{" & vbcrlf & "          padding:4px;" & vbcrlf & "          border-bottom: #000000 0.5pt solid;" & vbcrlf & "             border-left: 0pt;" & vbcrlf & "               border-top: 0pt; " & vbcrlf & "               border-right: #000000 0.5pt solid;" & vbcrlf & "      }" & vbcrlf & "       .staff_XBody{" & vbcrlf & "           display:none;" & vbcrlf & "   }" & vbcrlf & "       .staff_YBody{" & vbcrlf & "           display:none;" & vbcrlf & "   }" & vbcrlf & "</style>" & vbcrlf & "<style media=""screen"">" & vbcrlf & "#framemargintop{" & vbcrlf & "   text-align:center;" & vbcrlf & "      line-height:20px;" & vbcrlf & "       font-weight:bold;" & vbcrlf & "       font-family:微软雅黑;" & vbcrlf & "   font-size:18px;" & vbcrlf & " color:#fff;" & vbcrlf & "     height:20px;" & vbcrlf & "    filter:Shadow(color=#000000,direction=145,strength=4);" & vbcrlf & "}" & vbcrlf & "/*打印元件*/" & vbcrlf & ".printerctl {" & vbcrlf & "        position:absolute;" & vbcrlf & "      width:auto;" & vbcrlf & "     /*overflow:hidden;*//*避免出现控件显示不全*/" & vbcrlf & "    cursor:default;" & vbcrlf & "        padding:0px;" & vbcrlf & "    font-size:14px;" & vbcrlf & " " & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".printerctlbody {" & vbcrlf & "      padding:3px;" & vbcrlf & "    white-space:nowrap;" & vbcrlf & "     font-size:12px;" & vbcrlf & "} " & vbcrlf & ".msout .printerctlbody {" & vbcrlf& "        padding:4px;" & vbcrlf & "    white-space: nowrap;" & vbcrlf & "}" & vbcrlf & ".msout .printercltool {" & vbcrlf & "    display:none;" & vbcrlf & "}" & vbcrlf & ".msout .printerclresize {" & vbcrlf & " display:none;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".active .printerctlbody {" & vbcrlf & " border:1px solid  #bbbbcc;" & vbcrlf & "      padding:3px;" & vbcrlf & "    background-color:white;" & vbcrlf & " white-space: nowrap;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".active .printercltool {" & vbcrlf & "/* font-size:12px;" & vbcrlf & " color:red;" & vbcrlf & "      position:absolute;" & vbcrlf & "      top:0px;left:0px;" & vbcrlf & " border:1px solid  #bbbbcc;" & vbcrlf & "      border-bottom:1px solid white;" & vbcrlf & "  padding:3px;" & vbcrlf & "    background-color:white;*/" & vbcrlf & "       /*filter:wave(strength=0,freq=1,lightstrength=6,phase=0);*/" & vbcrlf & "     display:none;" & vbcrlf & "}" & vbcrlf & ".active .printerclresize {" & vbcrlf & "       color:red;" & vbcrlf & "      position:absolute;" & vbcrlf & "      bottom:0px;right:0px;" & vbcrlf & "   border:2px solid  #ff6699;" & vbcrlf & "      height:0px;width:0px;" & vbcrlf & "   cursor: se-resize" & vbcrlf & "       /*background-color:white;*/" & vbcrlf & "     /*filter:wave(strength=0,freq=1,lightstrength=6,phase=0);*/" & vbcrlf & "}" & vbcrlf & ".active .CtrlTextBody{" & vbcrlf & "     background:#fff;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "/*打印元件结束*/" & vbcrlf & "#divpage{" & vbcrlf & "      position:absolute;" & vbcrlf & "      top:126px;" & vbcrlf & "      left:0px;" & vbcrlf & "   right:0px;" & vbcrlf & "      bottom:0px;" & vbcrlf & "     border-top:1px solid #8888aa;" & vbcrlf & "   _width:100%;" & vbcrlf & "    _height:expression((documentElement.clientHeight-99) + ""px"");" & vbcrlf & "}" & vbcrlf & "#pageinfo{" & vbcrlf & "  position:absolute;" & vbcrlf & "      top:32px;" & vbcrlf & "       left:0px;" & vbcrlf & "       right:0px;" & vbcrlf & "      bottom:0px;" & vbcrlf & "     border-top:1px solid #8888aa;" & vbcrlf & "   min-width:1024px;" & vbcrlf & "       _width:100%;" & vbcrlf & "    width:expression_r(document.body.clientWidth > 1024? ""1024px"": ""auto"" );" & vbcrlf & "    height:98px;" & vbcrlf & "} "& vbCrLf & "#billtopbardiv{ "& vbCrLf &   " min-width:1024px; "& vbCrLf &    "    _width:100%; "& vbCrLf &  "   width:expression_r(document.body.clientWidth > 1024? ""1024px"": ""auto"" ); "& vbCrLf &" }" & vbCrLf & "#pageinfo td{ "& vbCrLf &    "   line-height:20px; "& vbCrLf &    "    background-color:#FFF;"& vbCrlf & "      color:#2f496e;" & vbcrlf & "  padding:2px 4px;" & vbcrlf & "        height:26px;" & vbcrlf & "    overflow:hidden;" & vbcrlf & "        white-space:nowrap;" & vbcrlf & "     /*border:1px solid #c0ccdd;*/" & vbcrlf & "}" & vbcrlf & "#pageinfo td div{height:26px;overflow:hidden;}" & vbcrlf & "#pageinfo td span{" & vbcrlf & "   height:20px;" & vbcrlf & "    padding-right:10px;" & vbcrlf & "}" & vbcrlf & "#pageinfo table{" & vbcrlf & "    border-collapse:collapse;" & vbcrlf & "       white-space:nowrap;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "#tool{" & vbcrlf & "      position:absolute;" & vbcrlf & "      bottom:0px;top:0px;left:87%;"& vbcrlf & " width : 13 % ;background - color : #eee;" & vbcrlf &       "  _height:100%;" & vbcrlf &" } "& vbcrlf &" # List { "& vbcrlf &"  position : absolute ; "& vbcrlf &  "bottom : 0 px ;top : 0 px ;Left : 0 ; "& vbcrlf & " width : 13 % ;background - color : #eee;" & vbcrlf &   "      _height:100%; "& vbcrlf & "   overflow:auto; "& vbcrlf &"}" & vbcrlf & "" & vbcrlf & "# FramePage {" & vbCrLf & " position : absolute ;bottom : 0 px ;top : 0 px ;Left : 13 % ;width : 74 % ;" & vbCrLf & " background - color : #fff;overflow:auto;" & vbcrlf & "    border-right:1px solid # 555577 ;border - Left : 1 px solid #555577;" & vbcrlf & "   _height:100%;" & vbcrlf & "   overflow:scroll;"& vbcrlf & "       font-size:12px;" & vbcrlf & "}" & vbcrlf & ".grpItem {" & vbcrlf & "      height:25px;" & vbcrlf & "    font-size:12px;" & vbcrlf & " line-height:25px;" & vbcrlf & "       font-weight:bold;" & vbcrlf & "       padding-left:5px;" & vbcrlf & "       color:# 232345 ;" & vbCrLf & " width : 100 % ;" & vbCrLf & " }" & vbcrlf & ".toolbg {" & vbcrlf & "      height:25px;" & vbcrlf & "    width:25px;" & vbcrlf & "     overflow:hidden;" & vbcrlf & "        text-align:center;" & vbcrlf & "    vertical-align: middle;" & vbcrlf & "   background-repeat:no-repeat;" & vbcrlf & "    background-position:center center;" & vbcrlf & "      cursor:default;" & vbcrlf & "    margin:1px;" & vbcrlf & "}" & vbcrlf & ".control {" & vbcrlf & "  width:27px;" & vbcrlf & "     height:27px;" & vbcrlf & "    float:left;" & vbcrlf & "     margin:2px;" & vbcrlf & "}" & vbcrlf & "#FrameBorderPage{" & vbcrlf & "   margin-right:auto;" & vbcrlf & "      margin-left:auto;" & vbcrlf & "       position:relative;" & vbcrlf & "     padding-left:16px;" & vbcrlf & "}" & vbcrlf & "#FrameBorderPage li,#grpchild1000 li{ list-style:inside;}" & vbcrlf & "blockquote{ margin-left: 40px;}" & vbcrlf & "" & vbcrlf & ".PrintPage{" & vbcrlf & "  margin-right:auto;" & vbcrlf & "      margin-left:auto;" & vbcrlf & "       /*width:210mm;height:290mm;*/" & vbcrlf & " border-left:1px solid #000;border-top:1px solid #000;border-bottom:3px solid #000;border-right:3px solid #000;" & vbcrlf & "  background-color:#ddd;" & vbcrlf & "  overflow:hidden;" & vbcrlf & "        position:relative;" & vbcrlf & "}" & vbcrlf & ".ActivePage{" & vbcrlf & "background-color:white;" & vbCrLf &" } "& vbCrLf &" #printlogo{" & vbCrLf & "     width:32px; "& vbCrLf &    "  height:10mm; "& vbCrLf &  "   background-image:url(../../images/printlogo.gif);" & vbCrLf &    "    background-repeat:no-repeat;" & vbCrLf & "    background-position:center center; "& vbCrLf & "}"_
		& "td.attlabel{" & vbcrlf & "     border-bottom: 1px solid #aaa;" & vbcrlf & "  width:60px;" & vbcrlf & "     text-align:right;" & vbcrlf & "       height:20px;" & vbcrlf & "    min-width:60px;" & vbcrlf & "}" & vbcrlf & "td.attvalue {" & vbcrlf & "   border:1px solid #aaa;" & vbcrlf & "  background-color:white;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "td.attvalue table {" & vbcrlf & " width:100%;" & vbcrlf & "     border-right:1px inset;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "input.pattvalue{" & vbcrlf & "        padding-left:3px;" & vbcrlf & "       border:0px;" & vbcrlf & "     width:100%;" & vbcrlf & "     font-size:12px;" & vbcrlf & "      height:20px;" & vbcrlf & "    line-height:20px;" & vbcrlf & "       font-family:宋体;" & vbcrlf & "       background-color:transparent;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "td.attv2{" & vbcrlf & " width:100%;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "button.attcolorbutton{" & vbcrlf & "      border:1px solid #ccc;" & vbcrlf & "        background-color:white;" & vbcrlf & " width:16px;" & vbcrlf & "     height:16px;" & vbcrlf & "    margin-right:2px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "select.colorbox{" & vbcrlf & "      width:132px;" & vbcrlf & "    margin-left:-114px;" & vbcrlf & "     margin-top:-2px;" & vbcrlf & "        font-family:宋体;" & vbcrlf & "  font-size:12px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "select.fontbox{" & vbcrlf & " width:132px;" & vbcrlf & "    margin-left:-114px;" & vbcrlf & "     margin-top:-2px;" & vbcrlf & "        font-family:宋体;" & vbcrlf & "       font-size:12px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "textarea.pattvalue{" & vbcrlf & "  padding-left:3px;" & vbcrlf & "       border:0px;" & vbcrlf & "     width:100%;" & vbcrlf & "     font-size:12px;" & vbcrlf & " height:18px;" & vbcrlf & "    line-height:20px;" & vbcrlf & "       font-family:宋体;" & vbcrlf & "       background-color:transparent;" & vbcrlf & "   overflow:hidden;" & vbcrlf &" padding-top:2px;" & vbcrlf & "}" & vbcrlf & "div.pattvalue{" & vbcrlf & " padding-left:3px;" & vbcrlf & "       border:0px;" & vbcrlf & "     width:100%;" & vbcrlf & "     font-size:12px;" & vbcrlf & " line-height:20px;" & vbcrlf & "       font-family:宋体;" & vbcrlf & "       background-color:transparent;" & vbcrlf & "   overflow:hidden;" & vbcrlf & "       padding-top:2px;" & vbcrlf & "        word-break:break-all;" & vbcrlf & "   word-wrap:break-word;" & vbcrlf & "   white-space:normal;" & vbcrlf & "}" & vbcrlf & "img .control_img:{" & vbcrlf & "  width:100%;" & vbcrlf & "     height:100%;" & vbcrlf & "    display:block; margin:0px; padding:0px; border:none;" & vbcrlf & "   border:1px solid #f00;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "table.printertable {" & vbcrlf & "             display:inline-block;" & vbcrlf & "           border-collapse: separate;" & vbcrlf & "              border-bottom: 0pt;" & vbcrlf & "             border-left: #000000 0.5pt solid;" & vbcrlf & "               border-top: #000000 0.5pt solid;" & vbcrlf & "                border-right: 0pt;" & vbcrlf & "}" & vbcrlf & "table.printertable th{" & vbcrlf & "       padding:4px;" & vbcrlf & "}" & vbcrlf & "table.printertable td{" & vbcrlf & "     padding:4px;" & vbcrlf & "    border-bottom: #000000 0.5pt solid;" & vbcrlf & "     border-left: 0pt;"& vbcrlf & " border - top : 0 pt ;" & vbcrlf &"  border - Right : #000000 0.5pt solid; "& vbcrlf &" } "& vbcrlf &" textarea.arraylisttext{ "& vbcrlf &   "    width:99%; "& vbcrlf &  "     font-size:12px; "& vbcrlf &"  height:20px;" & vbcrlf &   "  overflow:hidden; "& vbcrlf &       "  border:1px solid # aaa ; "& vbcrlf & " }"& vbcrlf & "div.arraylisttext{" & vbcrlf & "     width:99%;" & vbcrlf & "      font-size:12px;" & vbcrlf & "" & vbcrlf & " line-height:18px;" & vbcrlf & "       overflow:hidden;" & vbcrlf & "        border:1px solid #aaa;" & vbcrlf & "}" & vbcrlf & "td.arraylisttext{" & vbcrlf & "        font-size:12px;" & vbcrlf & " height:18px;" & vbcrlf & "  line-height:18px;" & vbcrlf & "       overflow:hidden;" & vbcrlf & "        border:1px solid #aaa;" & vbcrlf & "}" & vbcrlf & ".DataBody{" & vbcrlf & "       margin:0px;" & vbcrlf & "     padding:0px 5px;" & vbcrlf & "        line-height:16px;" & vbcrlf & "       height:16px;" & vbcrlf & "    background-color:transparent;" & vbcrlf & "   border:1px solid #888;" & vbcrlf & "  color:#2932E1;" & vbcrlf & "  overflow:hidden;" & vbcrlf & "}" & vbcrlf & ".CountBody{" & vbcrlf & "    margin:0px;" & vbcrlf & "     padding:0px 5px;" & vbcrlf & "        line-height:16px;" & vbcrlf & "       height:16px;" & vbcrlf & "    background-color:transparent;" & vbcrlf & "       border:1px solid #f88;" & vbcrlf & "  color:#2932E1;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "/* ==标尺== */" & vbcrlf & ".staff_XBody{" & vbcrlf & "      overflow:hidden;" & vbcrlf & "        position: absolute;" & vbcrlf & "     height:16px;" & vbcrlf & "    width:210mm;" & vbcrlf & "    z-index:10;" & vbcrlf & "      left:350px;" & vbcrlf & "     background:#fff;" & vbcrlf & "}" & vbcrlf & ".staff_X{" & vbcrlf & "      position: absolute;" & vbcrlf & "     height:16px;" & vbcrlf & "    /*overflow: hidden;*/" & vbcrlf & "   z-index:15;" & vbcrlf & "}" & vbcrlf & ".staff_R{" & vbcrlf & "   background:#CDD1D6;" & vbcrlf & "     position:absolute;" & vbcrlf & "      width:10mm;" & vbcrlf & "     top:0px;" & vbcrlf & "        height:14px;" & vbcrlf & "    right:0px;" & vbcrlf & "      z-index:19;" & vbcrlf & "     border-top:1px solid #81878F;" & vbcrlf & "   /*border-left:1px solid #81878F;*/" & vbcrlf & "      border-bottom:1px solid #81878F;" & vbcrlf & "        overflow:hidden;" & vbcrlf & "        filter:alpha(opacity=50);" & vbcrlf & "       text-align:left;" & vbcrlf & "}" & vbcrlf & ".staff_R span{" & vbcrlf & " height:14px;" & vbcrlf & "    padding-left:0.5cm;" & vbcrlf & "     border-left:1px solid #81878F;" & vbcrlf & "  cursor:col-resize;" & vbcrlf & "      float:left;" & vbcrlf & "}" & vbcrlf & ".staff_X .PageCursor{" & vbcrlf & "        height:14px;" & vbcrlf & "    border:1px solid #81878F;" & vbcrlf & "       font-size:12px;" & vbcrlf & " line-height:12px;" & vbcrlf & "       color:#585B5E;" & vbcrlf & "  overflow:hidden;" & vbcrlf & "        margin:0px;" & vbcrlf & "     padding:0px;" & vbcrlf & "    position:absolute;" & vbcrlf & "    overflow:hidden;" & vbcrlf & "}" & vbcrlf & ".staff_X .PageCursor dd,.staff_X .PageCursor dt{" & vbcrlf & "       width:1cm;" & vbcrlf & "      height:14px;" & vbcrlf & "    line-height:14px;" & vbcrlf & "       margin:0px;" & vbcrlf & "     padding:0px;" & vbcrlf & "    text-align:right;" & vbcrlf & "    float:left;" & vbcrlf & "}" & vbcrlf & ".staff_X dd span{" & vbcrlf & "   height:14px;" & vbcrlf & "    border-left:1px solid #81878F;" & vbcrlf & "  float:right;" & vbcrlf & "}" & vbcrlf & ".staff_X .PageCursor dd{" & vbcrlf & "   background:#CDD1D6;" & vbcrlf & "     filter:alpha(opacity=50);" & vbcrlf & "}" & vbcrlf & ".staff_X .cursor_T{" & vbcrlf & "  width:9px;" & vbcrlf & "      height:8px;" & vbcrlf & "     background:url(../../images/smico/Cursor.gif) no-repeat 0px 0px;" & vbcrlf & "        position:absolute;" & vbcrlf & "      left:-4px;" & vbcrlf & "      top:0px;" & vbcrlf & "        cursor:pointer;" & vbcrlf & " overflow:hidden;" & vbcrlf & "}" & vbcrlf & ".staff_X .cursor_B{" & vbcrlf & "     width:9px;" & vbcrlf & "      height:8px;" & vbcrlf & "     background:url(../../images/smico/Cursor.gif) no-repeat 0px -7px;" & vbcrlf & "       position:absolute;" & vbcrlf & "      top:8px;" & vbcrlf & "        left:-4px;" & vbcrlf & "      cursor:pointer;" & vbcrlf & "   overflow:hidden;" & vbcrlf & "}" & vbcrlf & ".cursor_LineY{" & vbcrlf & " height:1000px;" & vbcrlf & "  width:0px;" & vbcrlf & "      border-left:1px dashed #aaa;" & vbcrlf & "    position:absolute;" & vbcrlf & "      display:none;" & vbcrlf & "   z-index:50;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf &".staff_YBody{" & vbcrlf & "    overflow:hidden;" & vbcrlf & "        position: absolute;" & vbcrlf & "     height:210mm;" & vbcrlf & "   width:16px;" & vbcrlf & "     z-index:10;" & vbcrlf & "     background:#fff;" & vbcrlf & "}" & vbcrlf & ".staff_Y{" & vbcrlf & "      position: absolute;" & vbcrlf & "     width:16px;" & vbcrlf & "        /*overflow: hidden;*/" & vbcrlf & "   z-index:15;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".staff_B{" & vbcrlf & "   background:#CDD1D6;" & vbcrlf & "     position:absolute;" & vbcrlf & "      height:10mm;" & vbcrlf & "    bottom:0px;" & vbcrlf & "     width:14px;" & vbcrlf & "     left:0px;" & vbcrlf & "       z-index:19;"& vbcrlf & "      border-left:1px solid #81878F;" & vbcrlf & "  border-right:1px solid #81878F;" & vbcrlf & " overflow:hidden;" & vbcrlf & "        filter:alpha(opacity=50);" & vbcrlf & "       text-align:left;" & vbcrlf & "}" & vbcrlf & ".staff_B span{" & vbcrlf & " width:14px;" & vbcrlf & "     padding-top:0.5cm;" & vbcrlf & "   border-Top:1px solid #81878F;" & vbcrlf & "   cursor: row-resize;" & vbcrlf & "     float:left;" & vbcrlf & "}" & vbcrlf & ".staff_Y .PageCursor{" & vbcrlf & "       width:14px;" & vbcrlf & "     border:1px solid #81878F;" & vbcrlf & "       font-size:12px;" & vbcrlf & " line-height:12px;" & vbcrlf & "       color:#585B5E;" & vbcrlf & "       overflow:hidden;" & vbcrlf & "        margin:0px;" & vbcrlf & "     padding:0px;" & vbcrlf & "    position:absolute;" & vbcrlf & "}" & vbcrlf & ".staff_Y .PageCursor dd,.PageCursor dt{" & vbcrlf & "      width:14px;" & vbcrlf & "     height:1cm;" & vbcrlf & "     line-height:14px;" & vbcrlf & "       margin:0px;"& vbcrlf & " padding : 0 px ; "& vbcrlf &  "text - align : Left ; "& vbcrlf & " position : relative ;" & vbcrlf & " } "& vbcrlf &".staff_Y dd span, .staff_Y dt span { "& vbcrlf & " position : absolute ; "& vbcrlf &  "bottom : 0 px ;" & vbcrlf & " } "& vbcrlf & ".staff_Y dd span.border { "& vbcrlf &  "border - bottom : 1 pxsolid #81878F;" & vbcrlf & "}" & vbcrlf & ".staff_Y .PageCursor dd{" & vbcrlf & "    background:#CDD1D6;" & vbcrlf & "     filter:alpha(opacity=50);" & vbcrlf & "}" & vbcrlf & ".staff_Y .cursor_L{" & vbcrlf & "   width:8px;" & vbcrlf & "      height:9px;" & vbcrlf & "     background:url(../../images/smico/Cursor_S.gif) no-repeat 0px 0px;" & vbcrlf & "      position:absolute;" & vbcrlf & "      left:0px;" & vbcrlf & "       top:-4px;" & vbcrlf & "       cursor:pointer;" & vbcrlf & " overflow:hidden;" & vbcrlf & "}" & vbcrlf & ".staff_Y .cursor_R{" & vbcrlf & "    width:8px;" & vbcrlf & "      height:9px;" & vbcrlf & "     background:url(../../images/smico/Cursor_S.gif) no-repeat -7px 0px;" & vbcrlf & "       position:absolute;" & vbcrlf & "      left:8px;" & vbcrlf & "       top:-4px;" & vbcrlf & "       cursor:pointer;" & vbcrlf & " overflow:hidden;" & vbcrlf & "}" & vbcrlf & ".cursor_LineX{" & vbcrlf & " height:0px;" & vbcrlf & "     width:1000px;" & vbcrlf & "   border-top:1px dashed #aaa;" & vbcrlf & "  position:absolute;" & vbcrlf & "      display:none;" & vbcrlf & "   z-index:50;" & vbcrlf & "}" & vbcrlf & "/* ==标尺【END】== */" & vbcrlf & "" & vbcrlf & "/*======线条弹出框======*/" & vbcrlf & ".ColorTool{" & vbcrlf & "  width:170px;" & vbcrlf & "    padding:1px;" & vbcrlf & "background:#fff;" & vbCrLf &    "     border:1px solid #A7ABB0; position:absolute; z-index:10001; "& vbCrLf & "}" & vbCrLf & ".ColorTool h3{" & vbCrLf &    "   margin:0px; padding:0px;" & vbCrLf &    "     background:#F0F2F5;" & vbCrLf &    "  height:22px; line-height:22px; font-size:12px; font-family:""宋体"";"_
		& "        color:#3B3B3B; padding-left:10px;" & vbcrlf & "}" & vbcrlf & ".ColorTool td{" & vbcrlf & "        text-align:center;" & vbcrlf & "      padding:3px 0px;" & vbcrlf & "}" & vbcrlf & ".ColorTool td span{" & vbcrlf & "    width:11px; height:13px;" & vbcrlf & "        display:block; overflow:hidden;" & vbcrlf & " margin:auto;" & vbcrlf & "}" & vbcrlf & ".ColorTool td  div{" & vbcrlf & "    width:13px; overflow:hidden;" & vbcrlf & "    background:#E2E4E7;" & vbcrlf & "     margin:auto; padding:1px 0px;" & vbcrlf & "}" & vbcrlf & ".ColorTool .hover{" & vbcrlf & "        background-image:url(../../images/CtrlsIco/ColorTool_Bg1.gif) no-repeat center;" & vbcrlf & "      width:13px; height:13px; overflow:hidden;" & vbcrlf & "}" & vbcrlf & ".ColorTool .ToolList{" & vbcrlf & " border-top:1px solid #E2E4E7;" & vbcrlf & "}" & vbcrlf & ".ColorTool .ToolList .ToolList_Text{" & vbcrlf & "      width:170px; height:25px; line-height:25px; overflow:hidden;" & vbcrlf & "        margin-top:3px;" & vbcrlf & "}" & vbcrlf & ".ColorTool .ToolList .ToolList_Text img{" & vbcrlf & "        float:left; display:inline; margin-right:15px; margin-left:10px;" & vbcrlf & "}" & vbcrlf & ".ColorTool .ToolList .hover{" & vbcrlf & "   background: url(../../images/CtrlsIco/ColorTool_Bg3.gif) no-repeat left top;" & vbcrlf & "}" & vbcrlf & ".ColorSub{" & vbcrlf & "   width:170px;padding:1px; max-height:300px;" & vbcrlf & "      background:#fff;border:1px solid #A7ABB0;" & vbcrlf & "       overflow:auto; display:none; position:absolute; z-index:10011;" & vbcrlf & "}" & vbcrlf & ".ColorSub div{" & vbcrlf & "  height:18px; width:auto; line-height:18px;" & vbcrlf & "      margin-top:3px; text-align:left; padding-left:5px;" & vbcrlf & "      overflow:hidden;" & vbcrlf & "}" & vbcrlf & ".ColorSub div span{" & vbcrlf & "    padding-left:100px;" & vbcrlf & "     display:block; float:right; margin-right:15px; height:0px; line-height:0px; font-size:0px;" & vbcrlf & "  overflow:hidden; margin-top:8px;" & vbcrlf & "}" & vbcrlf & ".ColorSub div.hover{" & vbcrlf & "   border:1px solid #F29536; height:16px; line-height:16px;" & vbcrlf & "        background:#FCF1C2;" & vbcrlf & "}" & vbcrlf & "/*=====================线条设置弹出框结束======================*/" & vbcrlf & "" & vbcrlf & "#divdlg_sadadad .dvt_closebar_out {display:none;}" & vbcrlf & "#divdlg_setCustom .dvt_closebar_out {display:none;}" & vbcrlf & "#divdlg_setSizeCustom .dvt_closebar_out {display:none;}" & vbcrlf & "" & vbcrlf & ".CtrlTextBody{" & vbcrlf & "   word-break:break-all;" & vbcrlf & "   word-wrap:break-word;" & vbcrlf & "   white-space:normal;" & vbcrlf & "     overflow:hidden;" & vbcrlf & "}" & vbcrlf & ".printerctlbody p{" & vbcrlf & "     word-break:break-all;" & vbcrlf & "   word-wrap:break-word;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".CtrlData{" & vbcrlf& "       border:1px solid #bbb;" & vbcrlf & "  background: #ddd;" & vbcrlf & "       overflow: hidden;" & vbcrlf & "       white-space: normal;" & vbcrlf & "    display:inline-block;" & vbcrlf & "   padding:0px 3px;" & vbcrlf & "        margin:0px 3px;" & vbcrlf & " font-size:12px;" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & ".TdSelected{" & vbcrlf & "    background:#ddd;" & vbcrlf & "}" & vbcrlf & "</style>" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "#ToolBarBody{" & vbcrlf & "     height:63px; background:url(../../../images/CtrlsIco/ToolBg1.gif) left top repeat-x #F1F4FB;" & vbcrlf & "    margin:0px; padding:0px;" & vbcrlf &" overflow:hidden;" & vbcrlf & "}" & vbcrlf & ".ToolBar{" & vbcrlf & "      height:25px; line-height:25px; overflow:hidden;" & vbcrlf & " float:left; display:inline;" & vbcrlf & "     padding-left:6px; background:url(../../../images/CtrlsIco/ToolBg.gif) no-repeat left top;" & vbcrlf & "       margin-top:3px;" & vbcrlf & "}" & vbcrlf & ".ToolBar dl,.ToolBar dt,.ToolBar dd{" & vbcrlf & "     height:25px; line-height:25px; overflow:hidden;" & vbcrlf & " margin:0px; padding:0px;" & vbcrlf & "        list-style:none;" & vbcrlf & "}" & vbcrlf & ".ToolBar dl{" & vbcrlf & "   background:url(../../../images/CtrlsIco/ToolBg.gif) no-repeat right -50px;      " & vbcrlf & "        padding-right:4px;" & vbcrlf & "}" & vbcrlf & ".ToolBar dd{" & vbcrlf & " width:25px; text-align:center;" & vbcrlf & "  background:url(../../../images/CtrlsIco/ToolBg.gif) repeat-x left -25px;" & vbcrlf & "        float:left; display:inline;" & vbcrlf & "     cursor:pointer;" & vbcrlf & "}" & vbcrlf & ".ToolBar dd div{" & vbcrlf & "  width:23px; height:23px; overflow:hidden;" & vbcrlf & "}" & vbcrlf & ".ToolBar dd select{" & vbcrlf & "   margin:0px; padding:0px;" & vbcrlf & "        height:22px; line-height:22px;" & vbcrlf & "}" & vbcrlf & ".ToolBar dd div.hover{" & vbcrlf & "   background:url(../../../images/CtrlsIco/touch.gif) 2px 2px no-repeat;" & vbcrlf & "}" & vbcrlf & ".ToolBar dt{" & vbcrlf & "  width:1px; overflow:hidden;" & vbcrlf & "     float:left;" & vbcrlf & "     height:25px; background:url(../../../images/CtrlsIco/ToolBg.gif) repeat-x left -25px;" & vbcrlf & "   display:inline; padding:0px 2px;" & vbcrlf & "}" & vbcrlf & ".clear{" & vbcrlf & "   height:0px; line-height:0px; font-size:0px;" & vbcrlf & "     clear:both; overflow:hidden;" & vbcrlf & "}" & vbcrlf & ".wordDirection{" & vbcrlf & "    writing-mode:tb-rl;" & vbcrlf & "     resize:none;" & vbcrlf & "}" & vbcrlf & "/**div.Container {position:relative;}**/" & vbcrlf & "</style>" & vbcrlf & "<link rel=""stylesheet"" type=""text/css"" href=""PrinterCreator.css?ver="
		Response.write Application("sys.info.jsver")
		Response.write """/>" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "$(document).ready(function(e) {" & vbcrlf & "   $(""#ToolBarBody .ToolBar div"").hover(function(e){" & vbcrlf & "         $(this).addClass(""hover"");" & vbcrlf & "        },function(e){" & vbcrlf & "          $(this).removeClass(""hover"");" & vbcrlf &" })" & vbcrlf & "});" & vbcrlf & "" & vbcrlf & "function reloadParent(){" & vbcrlf & "   if(opener){" & vbcrlf & "             opener.parent.window.mainFrame.window.location.href = ""../../Manufacture/PrinterList.asp?sort="
		Response.write ptr.ord
		Response.write """;" & vbcrlf & "        }else{" & vbcrlf & "          window.location.href = ""../../Manufacture/PrinterList.asp?sort="
		Response.write ptr.ord
		Response.write """;" & vbcrlf & "        }" & vbcrlf & "       self.close();" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "" & vbcrlf & "<body onselectstart='return false'>" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "//--页面默认设置" & vbcrlf & "window.pageSetting = {};" & vbcrlf & "window.pageSetting.XZ =""1"";//--页面高度修正值" & vbcrlf & "window.pageSetting.pageSize =""210,297"";" & vbcrlf & "window.pageSetting.pageHX = ""0"";" & vbcrlf & "window.pageSetting.pagePadding = ""10,10,10,10"";" & vbcrlf & "window.pageSetting.pageYM = ""$@tr@$$@tr@$"";" & vbcrlf & "window.pageSetting.pageYJ = ""$@tr@$第 &p 页$@tr@$"";" & vbcrlf & "window.pageSetting.T_pageSize =""210,297"";" & vbcrlf & "window.pageSetting.T_pageHX = ""0"";" & vbcrlf & "window.pageSetting.T_pagePadding = ""10,10,10,10"";" & vbcrlf & "window.pageSetting.T_pageYM = ""$@tr@$$@tr@$"";" & vbcrlf & "window.pageSetting.T_pageYJ = ""$@tr@$第 &p 页$@tr@$"";" & vbcrlf & "//--页面数据源" & vbcrlf & "var datafields = new Array();" & vbcrlf & "" & vbcrlf & "</script>" & vbcrlf & "<script type=""text/javascript"" src='printercreator.js?ver="
		Response.write ptr.ord
		Response.write Application("sys.info.jsver")
		Response.write "'></script>" & vbcrlf & "<script type=""text/javascript"" src='PrtDataCls.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write "'></script>" & vbcrlf & "<script type=""text/javascript"" src='contextmenu.js?ver="
		Response.write Application("sys.info.jsver")
		Response.write "'></script>" & vbcrlf & "<object  id=""wb"" style='display:none' classid=""CLSID:8856F961-340A-11D0-A96B-00C04FD705A2""> </object>" & vbcrlf & "<div id='notiemsg' style='display:none;position:fixed;z-index:100000;top:0px;bottom:0px;left:0px;right:0px;background-color:rgba(220,220,220,0.5)'>" &vbcrlf & "        <div style='height:20%'>&nbsp;</div>" & vbcrlf & "    <div style='border-radius:4px;width:600px;margin:0 auto;text-align:center;border:1px solid #d0dcec;color:white;background-color:rgba(0,0,0,0.8)'><br><br>" & vbcrlf & "               温馨提示：为了取得良好的使用效果，建议您在IE浏览器下使用打印模板功能。" & vbcrlf & "          <br><br><br>" & vbcrlf & "         <a href='javascript:void(0)' onclick='document.getElementById(""notiemsg"").style.display = ""none"";' style='color:#ffff00'>知道了，继续用用</a><br>" & vbcrlf & "           <br>" & vbcrlf & "    </div>" & vbcrlf & "</div>" & vbcrlf & "<script>" & vbcrlf & "    if(!window.ActiveXObject)" & vbcrlf & "       {" & vbcrlf & "             document.getElementById(""notiemsg"").style.display = ""block"";" & vbcrlf & "        }" & vbcrlf & "</script>" & vbcrlf & "<div  id='billtopbardiv' style='position:absolute;top:0px;height:32px;margin:0px;width:100%'>" & vbcrlf & " <table style='table-layout:fixed;width:100%' id='billtopbartable'>"& vbcrlf & "        <tr>" & vbcrlf & "          <td id=""billtitle"" style='width:210px;overflow:hidden'>"
		Response.write ptr.TemplateType
		Response.write "打印模板"
		if len([sort]) > 0 then
			Response.write("添加")
		else
			Response.write("修改")
		end if
		Response.write "</td>" & vbcrlf & "                <td style='width:auto'>&nbsp;</td>" & vbcrlf & "              <td align=right style=""white-space:nowrap;width:800px;"">" & vbcrlf & "                  <button onClick=""PrtData.ShowIn("
		Response.write("修改")
		Response.write ptr.ord
		Response.write ")"" class=""button"" style='width:60px'>导入</button>&nbsp;" & vbcrlf & "                    <button onClick=""if(confirm('确认导出为.dat文件？')){bodyPanelMsDown();dosave(1);}"" class=""button"" style='width:60px'>导出</button>&nbsp;" & vbcrlf & "                   <!--<button onClick=""ImgUploadWindow()"" class=""button"" style='width:60px'>tt</button>&nbsp;-->" & vbcrlf & "                  <button onClick=""addpage()"" class=""button"" style='width:60px'>增加页面</button>&nbsp;" & vbcrlf & "                       <button onClick=""delpage()"" class=""button"" style='width:60px'>删除页面</button>&nbsp;" & vbcrlf & "                       <!--<button onClick=""showview()"" class=""button"" style='width:60px'>预览</button>&nbsp;-->" & vbcrlf & "                    <button onClick=""doseting()"" class=""button"" style='width:60px'>设置</button>&nbsp;" & vbcrlf & "                  <button onClick=""bodyPanelMsDown();dosave();"" class=""button"" style='width:60px'>暂存</button>&nbsp;" & vbcrlf & "                 <button onClick=""bodyPanelMsDown();if(dosave()){reloadParent();}"" class=""button"" style='width:60px'>保存</button>&nbsp;" & vbcrlf & "             </td>" & vbcrlf & "           <td width=""3""><img src=""../../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "     </tr>" & vbcrlf & "  </table>" & vbcrlf & "</div>" & vbcrlf & ""
		response.Flush()
		Response.write "" & vbcrlf & "<div id=""pageinfo"">" & vbcrlf & "    <div style=""height:30px; overflow:hidden;"">" & vbcrlf & "       <table width=""100%"" id=""content2"" sizset=""1"" sizcache=""1"" style="" margin-top:-2px"">" & vbcrlf & "               <tr>" & vbcrlf & "                    <td width=""30%"" height=""26"" style=""width:440px;""><div><strong>模板名称：</strong>" & vbcrlf & "                   <input name=""t_title"" type=""text"" id=""t_title"" size=""30"" onselectstart='window.event.cancelBubble = true;' onpropertychange="""" maxlength=""50"" msg=""模板名称最多50个字"" value="""
		Response.write ptr.title
		Response.write """>" & vbcrlf & "                        <font style=""color:#f00;"">*</font></div></td>" & vbcrlf & "                     "
		Select Case ptr.ord
		Case 150
		Response.write "" & vbcrlf & "                     <td width=""11%"">重要指数:" & vbcrlf & "                         <input name=""t_gate1"" type=""text"" id=""t_gate1"" onpropertychange=""if(this.value.match(/\D/g)){this.value=this.value.replace(/\D/g,'')}"" value="""
		Response.write ptr.gate1
		Response.write """ size=""5"" maxlength=""4"" onkeypress=""return checkOnlyNum()"" onKeyUp=""checkNumDot('t_gate1','0')"">" & vbcrlf & "                 </td>" & vbcrlf & "                   "
		end Select
		if id <> 0 then
			Response.write "" & vbcrlf & "                     <td width=""10%""><label for=""t_default"">添加时默认:</label>" & vbcrlf & "                          <input name=""t_default"" type=""checkbox"" id=""t_default"" value=""1"""
			if ptr.isDefalut = 1 then Response.write(" checked") end if
			Response.write ">" & vbcrlf & "                    </td>" & vbcrlf & "                   "
		end if
		Response.write "" & vbcrlf & "                     <td width=""10%""><label for=""t_model"">加入模板:</label>" & vbcrlf & "                              <input name=""t_model"" type=""checkbox"" id=""t_model"" value=""1"""
		if ptr.isModel = 1 then Response.write(" checked") end if
		Response.write ">" & vbcrlf & "                    </td>" & vbcrlf & "                   <td width=""15%""><table><tr><td style=""padding:0px;border:0 none;"">引用模板：</td>" & vbcrlf & "                           <td style=""padding:0px;border:0 none;""><select name=""p_type"" id=""p_type"" onChange=""if(this.value.length > 0){self.window.location.href='PrinterCreator.asp?id="
		Response.write id
		Response.write "&sort="
		Response.write [sort]
		Response.write "&ModelType='+escape(this.value)}"" style=""width:120px;"">" & vbcrlf & "                                     <option value="""">--选择模板--</option>" & vbcrlf & "                                    <option value="""">+通用模板</option>" & vbcrlf & "                                       "
		'Response.write [sort]
		dim RsModel
		set A_cn = server.CreateObject("adodb.connection")
		A_cn.open "Driver={SQLite3 ODBC Driver};Database=" & server.mappath("../../update/db.asp") & ""
		set RsModel = A_cn.execute ("select * from PrintTemplates where isModel = 1 and (TemplateType = 0 or TemplateType = " & ptr.ord & ") order by TemplateType,id")
		while RsModel.eof = false
			if ModelType = RsModel("id") & ",public" then
				selected = " selected = true"
			else
				selected = ""
			end if
			Response.write("<option value='" & RsModel("id") & ",public' " & selected & ">&nbsp;&nbsp;|-" & RsModel("title") & "</option>")
			selected = ""
			RsModel.movenext
		wend
		RsModel.close
		set RsModel = nothing
		Response.write "" & vbcrlf & "                                     <option value="""">+专用模板</option>" & vbcrlf & "                                       "
		'set RsModel = nothing
		set RsModel = cn.execute ("select * from PrintTemplates where del = 1 and isModel = 1 and TemplateType = " & ptr.ord & " order by TemplateType,id")
		while RsModel.eof = false
			if ModelType = RsModel("id") & ",private" then
				selected = " selected = true"
			else
				selected = ""
			end if
			Response.write("<option value='" & RsModel("id") & ",private' " & selected & ">&nbsp;&nbsp;|-" & RsModel("title") & "</option>")
			selected = ""
			RsModel.movenext
		wend
		RsModel.close
		set RsModel = nothing
		Response.write "" & vbcrlf & "                     </select></td></tr></table></td>" & vbcrlf & "                        <td>" & vbcrlf & "                            <select name=""t_main"" id=""t_main"">" & vbcrlf & "                          <option value=""1"""
		if ptr.ismain = "1" then Response.write(" selected")
		Response.write ">主模板</option>" & vbcrlf & "                             <option value=""0"""
		if ptr.ismain = "0" then Response.write(" selected")
		Response.write ">副模板</option>" & vbcrlf & "                     </select>" & vbcrlf & "                       </td>" & vbcrlf & "           </tr>" & vbcrlf & "   </table>" & vbcrlf & "        </div>" & vbcrlf & "  <div style=""height:63px;"">" & vbcrlf & "                <div id=""ToolBarBody"" class=""resetBgE0"">" & vbcrlf & "                    <div class=""ToolBar"">" & vbcrlf & "                             <dl>" &vbcrlf & "                                        <!--<dd><div><img src=""../../images/CtrlsIco/Ctrl1.gif"" width=""23"" height=""23""></div></dd>-->"
'if ptr.ismain = "0" then Response.write(" selected")
		dim grp,ico
		grp = "asda--as32sd"
'dim grp,ico
		i = 0
		set rs = cn.execute("select title as name,ctrlico as ico,ctrltype as cls,remark,ResolveType from PrintTemplate_Ctrls a where isopen = 1 order by ctrltype,paixu")
		while not rs.eof
			if grp <> app.iif(len(rtrim(rs.fields("cls").value & ""))=0, "常规",rs.fields("cls").value) and i <> 0 then
				grp = app.iif(len(rtrim(rs.fields("cls").value & ""))=0, "常规",rs.fields("cls").value)
				Response.write "<dt><img src=""../../images/CtrlsIco/ToolBg_Line.gif"" width=""1"" height=""24""></dt>"
			end if
			ico = trim(rs.fields("ico").value & "")
			if len(ico) = 0 then ico = "control.gif"
			Response.write("<dd><div title='" & rs.fields("name").value & "' onmousedown='buildControl(""" & rs.fields("name").value & """,""" & rs.fields("ResolveType").value & """)'><img src=""../../images/CtrlsIco/"&ico&""" width=""23"" height=""23""></div></dd>")
			i = i + 1
			rs.movenext
		wend
		rs.close
		Response.write "" & vbcrlf & "                             </dl>" & vbcrlf & "                   </div>" & vbcrlf & "                  <div class=""ToolBar"" style=""margin-left:5px;"">" & vbcrlf & "                              <dl>" & vbcrlf & "                                    <dd style=""width:auto; padding-right:3px;"">" & vbcrlf & "                                               <select name=""select"" id=""select"" onChange=""fontFamily(this);this.selectedIndex=0"">" & vbcrlf & "                                                    <option selected="""">字体</option>" & vbcrlf & "                                                 <option value=""宋体"">宋体</option>" & vbcrlf & "                                                        <option value=""黑体"">黑体</option>" & vbcrlf & "                                                        <option value=""楷体"">楷体</option>" & vbcrlf & "                                                        <option value=""仿宋"">仿宋</option>" & vbcrlf & "                                                <option value=""隶书"">隶书</option>" & vbcrlf & "                                                        <option value=""幼圆"">幼圆</option>" & vbcrlf & "                                                        <option value=""微软雅黑"">微软雅黑</option>" & vbcrlf & "                                                        <option value=""Arial"">Arial</option>" & vbcrlf & "                                              </select>" & vbcrlf & "                                       </dd>" & vbcrlf & "                                   <dd style=""width:auto; padding-right:3px;"">" & vbcrlf & "                                               <select name=""select2"" id=""select2"" onChange=""fontSize(this);this.selectedIndex=0"">" & vbcrlf & "                                                   <option selected=""selected"">字号</option>" & vbcrlf & "                                                 <option value=""6pt"">6pt</option>" & vbcrlf & "                                                  <option value=""8pt"">8pt</option>"& vbcrlf & " < Option value = "" 10 pt "" > 10 pt < / Option >  "& vbcrlf & " < Option value = "" 11 pt "" > 11 pt < / Option > " & vbcrlf & " < Option value = "" 12 pt "" > 12 pt < / Option > " & vbcrlf & " < Option value = "" 13 pt "" > 13 pt < / Option >  "& vbcrlf & " < Option value = "" 14 pt "" > 14 pt < / Option > " & vbcrlf & "<option value=""16pt"">16pt</option>" & vbcrlf & "                                                        <option value=""18pt"">18pt</option>" & vbcrlf & "                                                        <option value=""20pt"">20pt</option>" & vbcrlf & "                                                        <option value=""24pt"">24pt</option>" & vbcrlf & "                                                        <option value=""28pt"">28pt</option>" & vbcrlf & "                                                        <option value=""36pt"">36pt</option>" & vbcrlf & "                                                     <option value=""48pt"">48pt</option>" & vbcrlf & "                                                        <option value=""72pt"">72pt</option>" & vbcrlf & "                                                </select>" & vbcrlf & "                                       </dd>" & vbcrlf & "                                   <dd style=""width:auto; padding-right:3px;"">" & vbcrlf & "                                               <select name=""select3"" id = "" select3 "" onChange = "" fontBlock(this) ;this.selectedIndex = 0 "" > " & vbcrlf & " < Option selected = "" selected "" > 段落样式 < / Option > " & vbcrlf &  "< Option value = "" & lt ;P & gt ;"" > 普通 < / Option > " & vbcrlf & " < Option value = "" & lt ;H1 & gt ;"" > 标题一 < / Option >  "& vbcrlf & " < Option value = "" & lt ;H2 & gt;"">标题二</option>" & vbcrlf & "                                                       <option value=""&lt;H3&gt;"">标题三</option>" & vbcrlf & "                                                        <option value=""&lt;H4&gt;"">标题四</option>" & vbcrlf & "                                                        <option value=""&lt;H5&gt;"">标题五</option>" & vbcrlf & "                                                        <option value=""&lt;H6&gt;"">标题六</option>" & vbcrlf & "                                                        <option value=""&lt;p&gt;"">段落</option> "& vbCrLf &                                   "             </select> "& vbCrLf &                               "         </dd> "& vbCrLf &                  "                 <dt><img src=""../../images/CtrlsIco/ToolBg_Line.gif"" width=""1"" height=""24""></dt> "& vbCrLf &                      "                 <dd><div title=""删除激活的控件【现未激活控件】"" onClick=""delcontrol()"" id=""CtrlDelButton2014"" style=""filter:gray"" disabled><img src=""../../images/CtrlsIco/Ctrl12.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                         </dl>" & vbcrlf & "                   </div>" & vbcrlf & "                  <div class=""clear""></div>" & vbcrlf & "                 <div class=""ToolBar"">" & vbcrlf & "                             <dl>" & vbcrlf & "                                    <dd><div onClick=""Undo()"" title=""撤销""><img src=""../../images/CtrlsIco/Ctrl13.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                 <dd><div onClick=""Redo()"" title=""重做""><img src=""../../images/CtrlsIco/Ctrl14.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                     <dd><div onClick=""RemoveFormat()"" title=""删除文字格式""><img src=""../../images/CtrlsIco/Ctrl15.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                     <dt><img src=""../../images/CtrlsIco/ToolBg_Line.gif"" width=""1"" height=""24""></dt>" & vbcrlf & "                                      <!--<dd><div title=""文字颜色""><img src=""../../images/CtrlsIco/Ctrl16.gif"" width=""23"" height=""23""></div></dd>-->" & vbcrlf & "                                        <dd><div onClick=""Bold()"" title=""粗体""><img src=""../../images/CtrlsIco/Ctrl17.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                     <dd><div onClick=""Italic()"" title=""斜体""><img src=""../../images/CtrlsIco/Ctrl18.gif"" width=""23""height=""23""></div></dd>" & vbcrlf & "                                      <dd><div onClick=""Underline()"" title=""下划线""><img src=""../../images/CtrlsIco/Ctrl19.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                      <dt><img src=""../../images/CtrlsIco/ToolBg_Line.gif"" width=""1"" height=""24""></dt>" & vbcrlf & "                                      <dd><div onClick=""sp()"" title=""上标""><img src=""../../images/CtrlsIco/Ctrl20.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                   <dd><div onClick=""sb()"" title=""下标""><img src=""../../images/CtrlsIco/Ctrl21.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                       <dd><div onClick=""StrikeThrough()"" title=""删除线""><img src=""../../images/CtrlsIco/Ctrl22.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                      <dt><img src=""../../images/CtrlsIco/ToolBg_Line.gif"" width=""1"" height=""24""></dt>" & vbcrlf & "                                      <!--<dd><div onClick=""LineHeight()"" title=""行间距""><img src=""../../images/CtrlsIco/Ctrl23.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                 <dd><div title=""字间距""><img src=""../../images/CtrlsIco/Ctrl24.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                  <dd><div title=""文字背景颜色""><img src=""../../images/CtrlsIco/Ctrl25.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                  <dt><img src=""../../images/CtrlsIco/ToolBg_Line.gif"" width=""1"" height=""24""></dt>-->" & vbcrlf & "                                   <dd><div onClick=""LText()"" title=""左对齐""><img src=""../../images/CtrlsIco/Ctrl26.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf &"                                 <dd><div onClick=""CText()"" title=""居中对齐""><img src=""../../images/CtrlsIco/Ctrl27.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                        <dd><div onClick=""RText()"" title=""右对齐""><img src=""../../images/CtrlsIco/Ctrl28.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                  <dd><div onClick=""FText()"" title=""两端对齐""><img src=""../../images/CtrlsIco/Ctrl29.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                    <dt><img src=""../../images/CtrlsIco/ToolBg_Line.gif"" width=""1"" height=""24""></dt>" & vbcrlf & "                                      <dd><div onClick=""Outdent()"" title=""减少缩进""><img src=""../../images/CtrlsIco/Ctrl30.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                      <dd><div onClick=""Indent()"" title=""增加缩进""><img src=""../../images/CtrlsIco/Ctrl31.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                       <dd><div onClick="" Olist()"" title=""编号""><img src=""../../images/CtrlsIco/Ctrl32.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                    <dd><div onClick=""Ulist()"" title=""项目符号""><img src=""../../images/CtrlsIco/Ctrl33.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                        <!--<dt><img src=""../../images/CtrlsIco/ToolBg_Line.gif""width=""1"" height=""24""></dt>" & vbcrlf & "                                    <dd><div><img src=""../../images/CtrlsIco/Ctrl34.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                       <dd><div><img src=""../../images/CtrlsIco/Ctrl35.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                       <dd><div><img src=""../../images/CtrlsIco/Ctrl36.gif"" width=""23"" height=""23""></div></dd>" & vbcrlf & "                                      <dd><div title=""文字方向""><img src=""../../images/CtrlsIco/Ctrl37.gif"" width=""23"" height=""23""></div></dd>-->" & vbcrlf & "                             </dl>" & vbcrlf & "                   </div>" & vbcrlf & "          </div>" & vbcrlf & "  </div>" & vbcrlf & "</div>" & vbCrLf & "<div id='divpage'> "& vbCrLf & "  <div id='tool'> "& vbCrLf &       "   <div class=""grpItem resetBgE0"" id='toolbar1000'>属性</div>" & vbCrLf &            "     <div id='grpchild1000'></div>" & vbCrLf & "   </div> "& vbCrLf &   "<div id=""List"" style='overflow:hidden'><iframe name=""leftFrame"" id=""leftFrame"" src=""../BujianList.asp?sort="
		Response.write ptr.ord
		Response.write """ frameBorder=""no"" noResize=""noresize"" scrolling=""no"" style=""width:100%; height:100%;"" onload =""tt1(this)""></iframe></div><script type=""text/javascript"">function tt1(obj){obj.style.height = obj.parentElement.offsetHeight}</script>" & vbcrlf & "        <div id='FramePage'  onselectstart='window.event.cancelBubble=true;return false' onkeydown='window.event.cancelBubble=true;return true' onkeypress='window.event.cancelBubble=true;return true' onkeyup='window.event.cancelBubble=true;return true'>" & vbcrlf & "           <div id='framemargintop'>"
		Response.write "<!--打印模板设计--></div>" & vbcrlf & "            <div id='FrameBorderPage'>" & vbcrlf & "                      "
		Response.write "" & vbcrlf & "             </div>" & vbcrlf & "          <div style='height:40px' id='bottomMargin'></div>" & vbcrlf & "       </div>" & vbcrlf & "</div>" & vbcrlf & ""
		'call App_printBody(id)
		Response.write "" & vbcrlf & "<div style='display:none;' id='pageconfig'>" & vbcrlf & "" & vbcrlf & "  <fieldset style='position:absolute;left:5px;top:8px;width:200px;height:124px;display:block;overflow:hidden;border: #acaccc 1px solid; color: #333388'><legend>纸张选项</legend>" & vbcrlf & "         <span style='line-height:24px'>" & vbcrlf & "          &nbsp;&nbsp;纸张大小(<u>Z</u>)：<br>" & vbcrlf & "            <select style='width:188px;margin-left:6px;border: #acaccc 1px solid; color: #333388;' id='pSizeType' onChange='pSizeChange(this)'>" & vbcrlf & "                     <option value='889,1194'>A0</option>" & vbcrlf & "                    <option value='597,840'>A1</option>" & vbcrlf & "                   <option value='420,597'>A2</option>" & vbcrlf & "                     <option value='297,420'>A3</option>" & vbcrlf & "                     <option value='210,297'>A4</option>" & vbcrlf & "                     <option value='148,210'>A5</option>" & vbcrlf & "                     <option value='105,148'>A6</option>" & vbcrlf & "                     <!--<option value='250,353'>B4(JIS)</option>" & vbcrlf & "                      <option value='176,250'>B5(JIS)</option>-->" & vbcrlf & "                     <option value='787,1092'>B0</option>" & vbcrlf & "                    <option value='520,740'>B1</option>" & vbcrlf & "                     <option value='370,520'>B2</option>" & vbcrlf & "                     <option value='260,370'>B3</option>"& vbcrlf & "                      <option value='185,260'>B4</option>" & vbcrlf & "                     <option value='130,185'>B5</option>" & vbcrlf & "                     <option value='自定义'>自定义</option>" & vbcrlf & "          </select><br>" & vbcrlf & "           </span>" & vbcrlf & "         <span style='display:block;height:24px;padding-top:10px;'>" & vbcrlf & "                      &nbsp;<input type=""radio"" name=""page_hx"" id='page_hx1' value=""0"" onClick=""pSizeChange(this)""><label for='page_hx1'>纵向</label> &nbsp;<input type=""radio"" name=""page_hx"" id='page_hx2' value=""1"" onClick=""pSizeChange(this)""><label for='page_hx2'>横向</label>" & vbcrlf & "          </span>" & vbcrlf & " " & vbcrlf & "        </fieldset>" & vbcrlf & "     <fieldset style='position:absolute;left:215px;top:8px;width:110px;height:124px;display:block;overflow:hidden;border: #acaccc 1px solid; color: #333388'><legend>页边距(毫米)</legend>" & vbcrlf & "           <table style='height:96px;margin-left:5px;width:100px'>" & vbcrlf & "                <tr>" & vbcrlf & "                    <td>左(<u>L</u>)：</td>" & vbcrlf & "                 <td><input type=text size=6 maxlength=6 onKeyUp=""pPaddingChange(this)"" onpropertychange='pPaddingChange(this)' style='font-size:12px;border: #acaccc 1px solid; color: #333388;' id='PagePadding1'></td>" & vbcrlf & "          </tr>" & vbcrlf & "<tr> "& vbCrLf &                "     <td>右(<u>R</u>)：</td> "& vbCrLf &                "  <td><input type=text size=6 maxlength=6 onKeyUp=""pPaddingChange(this)"" onpropertychange='pPaddingChange(this)'  style='font-size:12px;border: #acaccc 1px solid; color: #333388;' id='PagePadding2'></td>" & vbCrLf &       "  </tr> "& vbCrLf & "<tr>" & vbcrlf & "                    <td>上(<u>T</u>)：</td>" & vbcrlf & "                 <td><input type=text size=6 maxlength=6 onKeyUp=""pPaddingChange(this)"" onpropertychange='pPaddingChange(this)'  style='font-size:12px;border: #acaccc 1px solid; color: #333388;' id='PagePadding3'></td>" & vbcrlf & "         </tr>" & vbcrlf & "   <tr>" & vbcrlf & "                    <td>下(<u>B</u>)：</td>" & vbcrlf & "                 <td><input type=text size=6 maxlength=6 onKeyUp=""pPaddingChange(this)"" onpropertychange='pPaddingChange(this)'  style='font-size:12px;border: #acaccc 1px solid; color: #333388;' id='PagePadding4'></td>" & vbcrlf & "         </tr>" & vbcrlf & "           </table>" & vbcrlf & "    </fieldset>" & vbcrlf & "" & vbcrlf & "     <div style='position:absolute;left:345px;top:12px;width:140px;height:124px;display:block;overflow:hidden;text-align:center;'>" & vbcrlf & "           <div style='background-color:white;width:100px;height:116px;border:1px solid #acaccc;'>" & vbcrlf & "                      <img src='../../images/smico/printermdl.gif' style='width:90px;height:104px;border:0px dashed #444;margin:4px'>" & vbcrlf & "         </div>" & vbcrlf & "  </div>" & vbcrlf & "  " & vbcrlf & "        <fieldset style='position:absolute;left:5px;top:140px;width:480px;height:164px;display:block;overflow:hidden;border: #acaccc 1px solid; color: #333388'><legend>页眉和页脚</legend>" & vbcrlf & "             <table align='center' width='460px' style='table-layout:fixed;height:140px'>" & vbcrlf & "            <tr>" & vbcrlf & "                    <td style='width:225px'>页眉(<U>H</u>)：</td>" & vbcrlf & "                   <td rowspan=4 style='wdith:5px'></td>" & vbcrlf & "                      <td style='width:225px'>页脚(<U>F</u>)：</td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr><td id='ym1'>"
		'call headlist(ptr)
		Response.write "</td><td  id='yj1'>"
'call headlist(ptr)
		Response.write "</td></tr>" & vbcrlf & "           <tr><td id='ym2'>"
'call headlist(ptr)
		Response.write "</td><td  id='yj2'>"
'call headlist(ptr)
		Response.write "</td></tr>" & vbcrlf & "           <tr><td id='ym3'>"
'call headlist(ptr)
		Response.write "</td><td  id='yj3'>"
'call headlist(ptr)
		Response.write "</td></tr>" & vbcrlf & "           </table>" & vbcrlf & "        </fieldset>" & vbcrlf & "     <div style='position:absolute;left:330px;top:313px;width:300px'>" & vbcrlf & "                <button style='font-size:12px;width:70px' onClick=""SettingOK(this)"" class=""button"">确定</button>&nbsp;<button class=""button"" onClick=""SettingCancle(this)"" style='font-size:12px;width:70px'>取消</button>" & vbcrlf & "     </div>" & vbcrlf & "</div>" & vbcrlf & "" & vbcrlf & "<div style=""display:none; position:absolute; top:200px;"" id=""SettingCustom"">" & vbcrlf & "    <table width=""260"" border=""0"" align=""center"" cellpadding=""0"" cellspacing=""0"" style=""color: #333388"">" & vbcrlf & "         <tr>" & vbcrlf & "                    <td height=""34"" align=""left"" valign=""middle"">在此处输入自定义的页眉/页脚文本(I)</td>" & vbcrlf & "          </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td height=""34"" align=""left"" valign=""middle""><input name=""CustomStr"" type=""text"" id=""CustomStr"" size=""36"" maxlength=""34"" style=""border: #acaccc 1px solid; color: #333388""></td>" & vbcrlf & "               </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td height=""34"" align=""right"" valign=""middle""><button class=""button"" style='font-size:12px;width:70px' onClick=""CustomOK(this)>" & vbcrlf & "   <table width=""260"" border=""0"" align=""center"" cellpadding=""0"" cellspacing=""0"" style=""color: #333388"">" & vbcrlf & "                <tr>" & vbcrlf & "                    <td height=""34"" align=""left"" valign=""middle"">在此处输入自定义纸张大小(Z)</td>" & vbcrlf & "         </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td height=""34"" align=""left"" valign=""middle"">宽度：<input name=""CustomStr"" onKeyUp=""CheckSize(this)"" onpropertychange=""CheckSize(this)"" type=""text"" id=""CustomSize1"" size=""6"" maxlength=""6"" class=""button"" style=""border: #acaccc 1px solid; color: #333388"">(毫米)" & vbcrlf & "                               &nbsp;高度：<input name=""CustomStr"" onKeyUp=""CheckSize(this)"" onpropertychange=""CheckSize(this)"" type=""text"" id=""CustomSize2"" size=""6"" maxlength=""6"" class=""button"" style=""border: #acaccc 1px solid; color: #333388"">(毫米)</td>" & vbcrlf & "          </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td height=""34"" align=""right"" valign=""middle""><button style='font-size:12px;width:70px' onClick=""SizeCustomOK(this)"" class=""button"">确定</button>&nbsp;<button style='font-size:12px;width:70px' onClick=""SizeCustomCancle(this)"" class=""button"">取消</button></td>" & vbcrlf & "               </tr>" & vbcrlf & "   </table>"& vbcrlf & "</div>" & vbcrlf & "<div style=""display:none; position:absolute; top:200px; z-index:111111111"" id=""AttFontSet""><!--字体大小弹出框-->" & vbcrlf & "    <table width=""431"" border=""0"" cellspacing=""0"" cellpadding=""0"" style=""background:#F0F0F0;"">" & vbcrlf & "                <tr>" & vbcrlf & "                    <td align=""left"" valign=""center"" style=""padding-left:10px;width:146px;overflow:hidden;padding-top:10px;height:20px;"">字体(F):</td>" & vbcrlf & "                      <td align=""left"" valign=""center"" style=""padding-left:8px;width:110px;padding-top:8px;"">字形(Y):</td>" & vbcrlf & "                  <td align=""left"" valign=""center"" style = "" padding - Left : 8 px ;width : 55 px ;padding - top : 8 px ;"" > 大小(S) : < / td > " & vbcrlf & " < td align = "" Left "" valign = "" center "" style = "" padding - Left : 8 px ;padding - top : 8 px ;"" > & nbsp ; < / td >  "& vbcrlf & " < / tr > " & vbcrlf &"  < tr > " & vbcrlf & " < td align = "" Left "" valign = "" center "" style = "" padding - Left : 10 px ;width:146px;overflow:hidden;height:22px;""><input name=""AFS_FF"" type=""text"" id=""AFS_FF"" onKeyUp=""AFS_FFChange(this)"" size=""20"" maxlength=""20"" style=""width:146px;"" onpropertychange=""AFS_FFChange(this)""></td>" & vbcrlf & "                     <td align=""left"" valign=""center"" style=""padding-left:8px;width:110px;""><input name=""AFS_FY"" type=""text"" id=""AFS_FY"" onKeyUp=""AFS_FYChange(this)"" size=""15"" maxlength=""15"" style=""width:110px;"" onpropertychange=""AFS_FYChange(this)"" ></td>" & vbcrlf & "                       <td align=""left"" valign=""center"" style=""padding-left:8px;width:55px;""><input name="" AFS_FS "" type = "" text "" id = "" AFS_FS "" size = "" 8 "" maxlength = "" 8 "" onKeyUp = "" AFS_FSChange(this) "" onpropertychange = "" AFS_FSChange(this) "" > < / td > " & vbcrlf & " < td rowspan = "" 2 "" align = "" Left "" valign = "" center "" style = "" padding - Left : 8 px ;"" > < button style0px;' onClick=""DoAttFontSet(this)"">确定</button><br><br><button style='font-size:12px;width:68px; margin:0px; padding:0px;' onClick=""window.DivClose(this)"">取消</button></td>" & vbcrlf & "          </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td align=""left"" valign=""center"" style=""padding-left:10px;width:146px;overflow:hidden;"">" & vbcrlf & "                                <select name=""AFS_FF_S"" size=""4"" id=""AFS_FF_S"" style=""width:150px; height:80px;"" onChange=""AFS_FFChange(this)"">" & vbcrlf & "                                   <option value=""宋体"">宋体</option>" & vbcrlf & "                                        <option value=""黑体"">黑体</option>" & vbcrlf & "                                        <option value="" 隶书"" > 隶书 < / Option >  "& vbcrlf &"  < Option value = "" 新宋体"" > 新宋体 < / Option >  "& vbcrlf &  "< Option value = "" 幼圆"" > 幼圆 < / Option > " & vbcrlf & " < Option value = "" 微软雅黑"" > 微软雅黑 < / Option >  "& vbcrlf & " < Option value = "" 仿宋 _ UTF - 8 "" > 仿宋 _ UTF - 8 < / Option > " & vbcrlf & " < Option value = "" 方正舒体"" > 方正舒体 < / Option >  "& vbcrlf & "                                  <option value=""方正姚体"">方正姚体</option>" & vbcrlf & "                                        <option value=""华文彩云"">华文彩云</option>" & vbcrlf & "                                        <option value=""华文仿宋"">华文仿宋</option>" & vbcrlf & "                                        <option value=""华文琥珀"">华文琥珀</option>" & vbcrlf & "                                        <option value=""华文楷体"">华文楷体</option>" & vbcrlf & "                                        <option value=""华文隶书"">华文隶书</option>" & vbcrlf & "                                       <option value=""华文行楷"">华文行楷</option>" & vbcrlf & "                                        <option value=""arial"" selected>arial</option>" & vbcrlf & "                                     <option value=""Arial Black"">Arial Black</option>" & vbcrlf & "                                  <option value=""fixedsys"">fixedsys</option>" & vbcrlf & "<option value=""system"">system</option>" & vbcrlf & "                            </select>" & vbcrlf & "                       </td>" &_
		vbcrlf & "                   <td align=""left"" valign=""center"" style=""padding-left:8px;width:110px;"">" & vbcrlf & "                               <select name=""AFS_FY_S"" size=""4"" id=""AFS_FY_S"" style=""width:114px; height:80px;"" onChange=""AFS_FYChange(this)"">" & vbcrlf & "                                   <option value=""常规"" selected>常规</option>" & vbcrlf & "                                       <option value=""加粗"">粗体</option>" & vbcrlf & "                                        <option value=""斜体"">斜体</option>" & vbcrlf & "                                        <option value=""加粗 斜体"">粗体 斜体</option>" & vbcrlf & "                              </select>" & vbcrlf & "                       </td>" &vbcrlf & "                        <td align=""left"" valign=""center"" style=""padding-left:8px;width:55px;"">" & vbcrlf & "                                <select name=""AFS_FS_S"" size=""4"" id=""AFS_FS_S"" style=""width:66px; height:80px;"" onChange=""AFS_FSChange(this)"">" & vbcrlf & "                                    <option value=""8"">8</option>" & vbcrlf & "                                      <option value=""9"">9</option>" & vbcrlf & "                                      <option value=""10"">10</option>" & vbcrlf & "                                    <option value=""11"">11</option>" & vbcrlf & "                                    <option value=""12"">12</option>" & vbcrlf & "                                    <option value=""14"" selected>14</option>" & vbcrlf & "                                   <option value=""16"">16</option>" & vbcrlf& "                                       <option value=""18"">18</option>" & vbcrlf & "                                    <option value=""20"">20</option>" & vbcrlf & "                                    <option value=""22"">22</option>" & vbcrlf & "                                    <option value=""24"">24</option>" & vbcrlf & "                                    <option value=""26"">26</option>" & vbcrlf & "                                    <option value=""28"">28</option>" & vbcrlf & "                                 <option value=""36"">36</option>" & vbcrlf & "                                    <option value=""48"">48</option>" & vbcrlf & "                                    <option value=""72"">72</option>" & vbcrlf & "                                    <option value=""42pt"">初号</option>" & vbcrlf & "                                        <option value=""36pt"">小初</option>" & vbcrlf & "                                        <option value=""26pt"">一号</option>" & vbcrlf & "                                    <option value=""24pt"">小一</option>" & vbcrlf & "                                        <option value=""22pt"">二号</option>" & vbcrlf & "                                        <option value=""18pt"">小二</option>" & vbcrlf & "                                        <option value=""16pt"">三号</option>" & vbcrlf & "                                        <option value=""15pt"">小三</option>" & vbcrlf & "                                        <option value=""14pt"">四号</option>" & vbcrlf & "                                    <option value=""12pt"">小四</option>" & vbcrlf & "                                        <option value=""10.5pt"">五号</option>" & vbcrlf & "                                      <option value=""9pt"">小五</option>" & vbcrlf & "                                 <option value=""7.5pt"">六号</option>" & vbcrlf & "                                       <option value=""6.5pt"">小六</option>" & vbcrlf & "                                   <option value=""5.5pt"">七号</option>" & vbcrlf & "                                       <option value=""5pt"">八号</option>" & vbcrlf & "                         </select>" & vbcrlf & "                       </td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td align=""left"" valign=""center"" style=""padding:10px 0px 15px 10px;width:146px;overflow:hidden;"">" & vbcrlf & "                                <fieldset style='position:relative;width:146px;height:120px;display:block;overflow:hidden;'><legend>效果</legend>" & vbcrlf & "                                       <p>&nbsp;<input name=""AFS_FK"" type=""checkbox"" id=""AFS_FK"" onpropertychange=""AFS_FUChange(this)""><label for=""AFS_FK"">删除线(K)</label></p>" & vbcrlf & "                                  <p>&nbsp;<input type=""checkbox"" name=""AFS_FU"" id=""AFS_FU"" onpropertychange=""AFS_FUChange(this)""><label for=""AFS_FU"">下划线(U)</label></p>" & vbcrlf & "                         </fieldset>" & vbcrlf & "                     </td>" & vbcrlf & "                   <td colspan=""2"" align=""left"" valign=""center"" style=""padding:10px 0px 15px 8px;""><fieldset style='position:relative;width:186px;height:120px;display:block;overflow:hidden;'>" & vbcrlf & "                         <legend>示例</legend>" & vbcrlf & "                                   <div id=""AFS_SL"" style=""padding:10px;overflow:hidden;white-space:nowrap; color:#000;"">智邦国际</div>" & vbcrlf & "                                </fieldset>" & vbcrlf & "                       </td>" & vbcrlf & "                   <td align=""left"" valign=""center"" style=""padding:10px 0px 15px 8px;"">&nbsp;</td>" & vbcrlf & "               </tr>" & vbcrlf & "   </table>" & vbcrlf & "</div>" & vbcrlf & "" & vbcrlf & "<div style=""position:absolute;"" id=""CtrlLineToolBody""><!--线条样式设置框-->" & vbcrlf & "<div class=""ColorTool"" id=""CtrlLineTool"" style=""display:none;"">" & vbcrlf & "   <h3>主题颜色<input id=""CtrlLineTool_value"" type=""hidden"" value=""""><input id=""CtrlLineTool_att"" type=""hidden"" value=""""></h3>" & vbcrlf & " <div>" & vbcrlf & "           <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td><div><span style=""background:#ffffff; height:11px;""></span></div></td>" & vbcrlf & "                                <td><div><span style=""background:#000000; height:11px;""></span></div></td>" & vbcrlf & "                                <td><div><span style=""background:#EEECE1; height:11px;""></span></div></td>" & vbcrlf & "                         <td><div><span style=""background:#1F497D; height:11px;""></span></div></td>" & vbcrlf & "                                <td><div><span style=""background:#4F81BD; height:11px;""></span></div></td>" & vbcrlf & "                                <td><div><span style=""background:#C0504D; height:11px;""></span></div></td>" & vbcrlf & "                             <td><div><span style=""background:#9BBB59; height:11px;""></span></div></td>" & vbcrlf & "                                <td><div><span style=""background:#8064A2; height:11px;""></span></div></td>" & vbcrlf & "                                <td><div><span style=""background:#4BACC6; height:11px;""></span></div></td>" & vbcrlf & "                                <td><div><span style=""background:#F79646; height:11px;""></span></div></td>" & vbcrlf & "                        </tr>" & vbcrlf & "                   <tr>" & vbcrlf & "                            <td><div><span style=""background:#f2f2f2;""></span><span style=""background:#d8d8d8;""></span><span style=""background:#bfbfbf;""></span><span style=""background:#a5a5a5;""></span><span style=""background:#7f7f7f;""></span></div></td>" & vbcrlf & "                               <td><div><span style=""background:#7f7f7f;""></span><span style=""background:#595959;""></span><span style=""background:#3f3f3f;""></span><span style=""background:#363636;""></span><span style=""background:#0c0c0c;""></span></div></td>" & vbcrlf & "                          <td><div><span style=""background:#DDD9C3;""></span><span style=""background:#C4BD97;""></span><span style=""background:#938953;""></span><span style=""background:#494429;""></span><span style=""background:#1D1B10;""></span></div></td>" & vbcrlf & " <td><div><span style=""background:#C6D9F0;""></span><span style=""background:#8DB3E2;""></span><span style=""background:#548DD4;""></span><span style=""background:#17365D;""></span><span style=""background:#0F243E;""></span></div></td>" & vbcrlf & "                         <td><div><span style=""background:#DBE5F1;""></span><span style=""background:#B8CCE4;""></span><span style=""background:#95B3D7;""></span><span style=""background:#366092;""></span><span style=""background:#244061;""></span></div></td>" & vbcrlf & "                             <td><div><span style=""background:#F2DCDB;""></span><span style=""background:#E5B9B7;""></span><span style=""background:#D99694;""></span><span style=""background:#953734;""></span><span style=""background:#632423;""></span></div></td>" & vbcrlf & "                                <td><div><span style=""background:#EBF1DD;""></span><span style=""background:#D7E3BC;""></span><span style=""background:#C3D69B;""></span><span style=""background:#76923C;""></span><span style=""background:#4F6128;""></span></div></td>" & vbcrlf & "                           <td><div><span style=""background:#E5E0EC;""></span><span style=""background:#CCC1D9;""></span><span style=""background:#B2A2C7;""></span><span style=""background:#5F497A;""></span><span style=""background:#3F3151;""></span></div></td>" & vbcrlf & "                              <td><div><span style=""background:#DBEEF3;""></span><span style=""background:#B7DDE8;""></span><span style=""background:#92CDDC;""></span><span style=""background:#31859B;""></span><span style=""background:#205867;""></span></div></td>" & vbcrlf & "                         <td><div><span style=""background:#FDEADA;""></span><span style=""background:#FBD5B5;""></span><span style=""background:#FAC08F;""></span><span style=""background:#E36C09;""></span><span style=""background:#974806;""></span></div></td>" & vbcrlf & "                 </tr>" & vbcrlf & "           </table>" & vbcrlf & "  </div>" & vbcrlf & "  <h3>标准颜色</h3>" & vbcrlf & "       <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbcrlf & "         <tr>" & vbcrlf & "                    <td><div><span style=""background:#c00000; height:11px;""></span></div></td>" & vbcrlf & "                        <td><div><span style=""background:#ff0000; height:11px;""></span></div></td>" & vbcrlf & "                       <td><div><span style=""background:#ffc000; height:11px;""></span></div></td>" & vbcrlf & "                        <td><div><span style=""background:#ffff00; height:11px;""></span></div></td>" & vbcrlf & "                        <td><div><span style=""background:#92D050; height:11px;""></span></div></td>" & vbcrlf & "                    <td><div><span style=""background:#00B050; height:11px;""></span></div></td>" & vbcrlf & "                        <td><div><span style=""background:#00B0F0; height:11px;""></span></div></td>" & vbcrlf & "                        <td><div><span style=""background:#0070C0; height:11px;""></span></div></td>" & vbcrlf & "                   <td><div><span style=""background:#002060; height:11px;""></span></div></td>" & vbcrlf & "                        <td><div><span style=""background:#7030A0; height:11px;""></span></div></td>" & vbcrlf & "                </tr>" & vbcrlf & "   </table>" & vbcrlf & "        <div class=""ToolList"">" & vbcrlf & "      <div class=""ToolList_Text""><img src=""../../images/CtrlsIco/Ctrl34.gif"" width=""23"" height=""23"">边框粗细<input type=""hidden"" value=""Linesize""></div>" & vbcrlf & "       <div class=""ToolList_Text""><img src=""../../images/CtrlsIco/Ctrl36.gif"" width=""23"" height=""23"">边框样式<input type=""hidden"" value=""LineStyle""></div>" & vbcrlf & "     </div>" & vbcrlf & "</div>" & vbcrlf & "" & vbcrlf & "<div id=""Linesize"" class=""ColorSub"">" & vbcrlf & "    <div><input type=""hidden"" value=""0pt""><span style=""border-top:0pt solid #000; margin-top:8px;""></span>0pt</div>" & vbcrlf & "       <div><input type=""hidden"" value=""0.5pt""><span style=""border-top:0.5pt solid #000; margin-top:8px;""></span>0.5pt</div>" & vbcrlf & "        <div><input type=""hidden"" value=""1.5pt""><span style=""border-top:1.5pt solid #000; margin-top:8px;""></span>1.5pt</div>" & vbcrlf & " <div><input type=""hidden"" value=""2.25pt""><span style=""border-top:2.25pt solid #000; margin-top:8px;""></span>2.25pt</div>" & vbcrlf & " <div><input type=""hidden"" value=""3pt""><span style=""border-top:3pt solid #000; margin-top:7px;""></span>3pt</div>" & vbcrlf & "       <div><input type=""hidden"" value=""4pt""><span style=""border-top:4pt solid #000;margin-top:6px;""></span>4pt</div>" & vbcrlf & "       <div><input type=""hidden"" value=""5pt""><span style=""border-top:5pt solid #000; margin-top:5px;""></span>5pt</div>" & vbcrlf & "       <div><input type=""hidden"" value=""6pt""><span style=""border-top:6pt solid #000; margin-top:4px;""></span>6pt</div>"& vbcrlf & "</div>" & vbcrlf & "" & vbcrlf & "<div id=""LineStyle"" class=""ColorSub"">" & vbcrlf & "       <div><input type=""hidden"" value=""solid""><span style=""border-top:0.5pt solid #000;""></span>直线</div>" & vbcrlf & "  <div><input type=""hidden"" value=""dashed""><span style=""border-top:0.5pt dashed #000;""></span>虚线</div>" & vbcrlf & "    <div><input type=""hidden"" value=""dotted""><span style=""border-top:0.5pt dotted #000;""></span>点状线</div>" & vbcrlf & "      <div><input type=""hidden"" value=""double""><span style=""border-top:3px double #000;""></span>双线</div>" & vbcrlf & "</div>" & vbcrlf & "</div>" & vbcrlf & "" & vbcrlf & "" & vbcrlf & "<div class=""ColorTool"" id=""RightMenuBody"" style=""display:none;"" onMouseLeave=""this.style.display = 'none'"">" & vbcrlf & "       <div class=""ToolList"">" & vbcrlf & "            <!--右键菜单容器-->" & vbcrlf & "     </div>" & vbcrlf & "</div>" & vbcrlf & "" & vbcrlf & "<div id=""TdSplitBody"" style="" position:absolute; z-index:1111; left:300px; display:none;"">" & vbcrlf & "  <div style=""width:340px; height:120px; overflow:hidden; border:1px solid #aaaacc; background:#fff;color:#333388 !important"">" & vbcrlf & "              <div style=""width:240px; height:120px; overflow: hidden; float:left;"">" & vbcrlf & "                        <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"""
'else
'Response.write("false")
'end if
'else
'Response.write("false")
'end if
	end sub
	sub App_ChechMain
		dim sort, formid, rst, sql
		[sort] = request.Form("sort")
		formid = request.Form("id")
		set rst = server.CreateObject("adodb.recordset")
		sql = "select count(a.id) from PrintTemplates a left join PrintTemplate_Type b on a.TemplateType = b.id where a.isMain = 1 and a.del = 1 and b.ord = " & [sort] & " and a.id <>" & formid
		rst.open sql,cn,1,1
		Response.write(rst(0))
		rst.close
		set rst=nothing
	end sub
	Sub App_doSave
		dim id, [sort]
		id = request.form("id")
		[sort] = request.form("sort")
		if (len(id) = 0 or not isnumeric(id)) and (len([sort]) = 0 or not isnumeric([sort])) then
			app.alert "无效ID"
			exit sub
		end if
		on error resume next
		cn.begintrans
		dim JSON, pages, MyPage, pageCoding, PageCtrls, CtrlInfo, CtrlName, CtrlJson, CtrlCoding, PageTop, PageBottom, PagePadding, PagePageSize, PagePageHX
		dim title, p_type, t_main, t_remark, act, t_default, t_model,t_gate1,isOut
		act = "edit"
		title = request.Form("title")
		t_main = request.Form("t_main")
		t_default = request.Form("t_default")
		t_model = request.Form("t_model")
		t_gate1 = request.Form("t_gate1")
		isOut = request.Form("isOut")
		If t_gate1&"" = "" Then t_gate1 = 1
		if id = "0" then
			Set Info = new AppInfo
			cn.execute ("insert into PrintTemplates (title, ismain, templatetype, addid, adddate, isModel, gate1, stop) select '" & title &"', " & t_main & ", id, "& info.user &", '" & now() & "', " & t_model & ","& t_gate1 &",0 from PrintTemplate_Type where ord = " & [sort])
			id = GetIdentity("PrintTemplates","id","addid","")
			set Info = nothing
			act = "add"
		else
			cn.execute ("update PrintTemplates set title='" & title & "', ismain=" & t_main & ",isModel='" & t_Model & "',isDefault = " & t_default & ",gate1="& t_gate1 &",del=1  where id = " & id)
			if t_default = 1 then
				cn.execute ("update PrintTemplates set isDefault = 0  where id <> " & id )
			end if
		end if
		JSON = request.form("JSON")
		PageTop = request.Form("PageTop")
		PageBottom = request.Form("PageBottom")
		PagePadding = request.Form("PagePadding")
		[PageSize] = request.Form("PageSize")
		PageHX = request.Form("PageHX")
		pages = split(JSON,"&#9;")
		cn.execute ("delete from PrintTemplate_PageCtrls where TemplateID = "&id)
		cn.execute ("delete from PrintTemplate_Pages where TemplateID = " &id)
		for i = 0 to ubound(pages)
			MyPage = split(pages(i),"&#0;")
			pageCoding = MyPage(0)
			PageCtrls = MyPage(1)
			cn.execute ("insert into PrintTemplate_Pages (TemplateID ,PageCoding, PageTop, PageBottom, PagePadding, [PageSize], PageHX) values (" & id & ",'" & pageCoding & "','" & PageTop & "','" & PageBottom & "','" & PagePadding & "','" & [PageSize] & "'," & PageHX &")")
			if (len(PageCtrls) <> 0) then
				PageCtrls = split(PageCtrls,"&#1;")
				for ii = 0 to ubound(PageCtrls)
					CtrlInfo = split(PageCtrls(ii),"&#2;")
					CtrlName = CtrlInfo(0)
					CtrlJson = CtrlInfo(1)
					CtrlCoding = CtrlInfo(2)
					cn.execute ("insert into PrintTemplate_PageCtrls (CtrlID, JSON, TemplateID, CtrlJS, CtrlCoding, PageCoding) select id,'" & CtrlJson & "'," & id & ",JS,'" & CtrlCoding & "','" & pageCoding & "' from PrintTemplate_Ctrls where title='" & CtrlName & "'")
				next
			end if
		next
		Dim rs ,PrtType
		PrtType = ""
		Set rs = cn.execute("select title from PrintTemplate_Type where ord = (select TemplateType from PrintTemplates where id = " & id & ")")
		If rs.bof = False And rs.eof = False Then
			PrtType = rs(0)
		end if
		rs.close
		set rs = nothing
		if err.number <> 0 Then
			Errors.Clear
			objConn.RollBackTrans
			app.alert "保存失败"
		else
			cn.CommitTrans
			If isOut = "0" Then
				app.alert "保存成功"
				if act = "add" then
					Response.write("window.location.href='?id="&id&"'")
				end if
			else
				Response.write("PrtData.ShowOut({billID:'" & id & "',Title:'" & title & "',PrtType:'" & PrtType & "'})")
			end if
		end if
	end sub
	Function GetIdentity(byval tableName,byval fieldName,byval addPerson,byval connStr)
		dim rs, errmsg, errnum
		err.clear
		on error resume next
		Set Info = new AppInfo
		Set rs=cn.Execute("SELECT TOP 1 "&fieldName&" FROM "&tableName&" WHERE "&addPerson&"=" & info.user & " ORDER BY "&fieldName&" DESC")
		set Info = nothing
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
			conn.close
			Response.write  "GetIdentity函数执行错误:" & errmsg & "<br>tableName=[" &tableName& "]<br>fieldName=[" &fieldName& "]<br>addPerson=[" &addPerson& "] "
			Response.end
		end if
		rs.close
	end function
	Function GetModel(tplID,CnObj)
		set rs = CnObj.execute("select id,pagetop,pagebottom,PageCoding,PageSize,PageHX,PagePadding from  PrintTemplate_Pages  where Templateid=" & tplID)
		if rs.eof then
			Response.write "" & vbcrlf & "                     <script type=""text/javascript"">" & vbcrlf & "                   var page = addpage();" & vbcrlf & "                   ActivePage(page);" & vbcrlf & "                       page.parentElement.children[0].removeNode(true);//--删除第一页前面的分页符" & vbcrlf & "                      </script>" & vbcrlf & "       "
'if rs.eof then
		else
			i = 0
			while not rs.eof
				pagetop = trim(rs.fields("pagetop").value & "")
				pagebottom = trim(rs.fields("pagebottom").value & "")
				[PageSize] = trim(rs.fields("PageSize").value & "")
				PageHX = trim(rs.fields("PageHX").value & "")
				PagePadding = trim(rs.fields("PagePadding").value & "")
				PCode = rs.fields("PageCoding").value
				i=i+1
				PCode = rs.fields("PageCoding").value
				Response.write "" & vbcrlf & "                     <script type=""text/javascript"">" & vbcrlf & "                   "
				if i = 1 then
					Response.write "" & vbcrlf & "                     window.pageSetting.pageSize = """
					Response.write  [PageSize]
					Response.write """;" & vbcrlf & "                        window.pageSetting.pageHX = """
					Response.write  PageHX
					Response.write """;" & vbcrlf & "                        window.pageSetting.pagePadding = """
					Response.write  PagePadding
					Response.write """;" & vbcrlf & "                        window.pageSetting.pageYM = unescape("""
					Response.write  pagetop
					Response.write """);" & vbcrlf & "                       window.pageSetting.pageYJ = unescape("""
					Response.write  pagebottom
					Response.write """);" & vbcrlf & "                       window.pageSetting.T_pageSize = """
					Response.write  [PageSize]
					Response.write """;" & vbcrlf & "                        window.pageSetting.T_pageHX = """
					Response.write  PageHX
					Response.write """;" & vbcrlf & "                        window.pageSetting.T_pagePadding = """
					Response.write  PagePadding
					Response.write """;" & vbcrlf & "                        window.pageSetting.T_pageYM = unescape("""
					Response.write  pagetop
					Response.write """);" & vbcrlf & "                       window.pageSetting.T_pageYJ = unescape("""
					Response.write  pagebottom
					Response.write """);" & vbcrlf & "                       "
				end if
				Response.write "" & vbcrlf & "                     " & vbcrlf & "                        var page = addpage();" & vbcrlf & "                   ActivePage(page);" & vbcrlf & "                       "
				if i = 1 then
					Response.write "" & vbcrlf & "                     page.parentElement.children[0].removeNode(true);//--删除第一页前面的分页符" & vbcrlf & "                      "
'if i = 1 then
				end if
				set rs1 = CnObj.execute ("select id,JSON,CtrlJS from PrintTemplate_PageCtrls a where a.PageCoding='" & PCode & "' and TemplateID= " & tplID &" and del = 1")
				while rs1.eof = false
					Response.write "" & vbcrlf & "                             var json = eval("
					Response.write  rs1("json")
					Response.write ");//--将属性设置成JSON" & vbcrlf & "                               ajax.regEvent(""loadControl"");//读取原控件JSON" & vbcrlf & "                             ajax.addParam(""name"",json.name);" & vbcrlf & "                          var r = eval(ajax.send());" & vbcrlf & "                              json.initHTML = r.initHTML;//--获取对应控件的原始模板" & vbcrlf & "                           json.CtrlEvent = r.CtrlEvent;//alert(Serialize(r.CtrlEvent.getTableDate))//--获取对应控件的内置事件" & vbcrlf & "                             json.RightMenu = r.RightMenu;//--获取对应控件的内置事件" & vbcrlf & "                         json.attType = r.attType;//--获取对应控件的属性值类型" & vbcrlf & "                           json.action = """";" & vbcrlf & "                         ReBuildControl(json);//--重载并渲染控件" & vbcrlf & "                 "
					'Response.write  rs1("json")
					rs1.movenext
				wend
				rs1.close
				Response.write "" & vbcrlf & "                     </script>" & vbcrlf & "       "
				rs.movenext
				if rs.eof = true then
					Response.write "" & vbcrlf & "             <script type=""text/javascript"">" & vbcrlf & "                   ActivePage(page.parentElement.children[0]);//--所有模板页加载完成后，激活第一页" & vbcrlf & "                 bodyPanelMsDown();" & vbcrlf & "              </script>" & vbcrlf & "               "
'if rs.eof = true then
				end if
			wend
		end if
		rs.close
	end function
		
%>
