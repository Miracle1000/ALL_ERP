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
				GetPowerIntro = r
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
							m = r(i).Value
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
							m = r(i).Value
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
							m = r(i).Value
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
			Response.write "" & vbcrlf & "//<!--" & vbcrlf & "window.location.href = ""../../index2.asp""" & vbcrlf & "//--><script>window.location.href = ""../../index2.asp""</script>" & vbcrlf & ""
			app.run
		end if
		app.ClearDB
		Set app = Nothing
		
		dim TreeView_autoIndex
		Class NodeCollection
			Public Item
			Public Length
			Public ParentNode
			Public  Sub  Class_Initialize
				ReDim Item(0)
				Length= 0
			end sub
			Public Function  Add()
				ReDim preserve Item(Length)
				set Item(Length) = new NodeClass
				Set Item(Length).ParentNode = ParentNode
				Item(Length).NodeIndex = Length
				item(length).depth = ParentNode.depth + 1
'Item(Length).NodeIndex = Length
				Set Add = Item(Length)
				Length = Length + 1
'Set Add = Item(Length)
			end function
			Public Sub Delete(index)
				Dim I
				If Length > index Then
					For I= index+1 To Length - 1
'If Length > index Then
						Set Item(I-1) = Item(I)
'If Length > index Then
						Item(I-1).NodeIndex = I
'If Length > index Then
					next
					Length = Length -1
'If Length > index Then
					ReDim preserve Item(Length-1)
'If Length > index Then
				end if
			end sub
			Public Function HTML(id)
				Dim I
				For I=0 To Length -1
'Dim I
					HTML = HTML & Item(I).HTML(id & I)
				next
			end function
			Public Sub AjaxReturn
				Response.write  "tvwChild=" & html("")
			end sub
		End Class
		Class NodeClass
			Public ImageUrl
			Public Text
			Public Tag
			Public NextNode
			Public PreviousNode
			Public ParentNode
			Public Nodes
			Public NodeIndex
			Public Expanded
			Public Selected
			Public depth
			public Eable
			Public ChildTest
			public vHasChild
			Private Sub  Class_Initialize
				Expanded = True
				Set Nodes = new NodeCollection
				Set Nodes.ParentNode = Me
				Selected = false
				Eable  = ""
				depth = 0
				ChildTest = 1
				vHasChild = false
			end sub
			Public Function HTML(id)
				on error resume next
				Dim htm ,display ,img,selectstyle,selectNodeId
				Dim myid, htmlarr
				myid = id & "_n" & TreeView_autoIndex
				c = request.Form(myid & "_status").count
				set ss = request.Form(myid & "_status")
				if c>1 then
					if TreeView_autoIndex >  ss.count then
						status = ""
					else
						status = ss(TreeView_autoIndex)
					end if
				else
					status = ss
				end if
				If Len(status) > 0 then
					itmstatus = Split(status,",")
					Expanded =CInt(itmstatus(0))
					Selected =CInt(itmstatus(1))
				else
					status = abs(CInt(Expanded)) & "," &  abs(CInt(Selected))
				end if
				If Expanded and not vHasChild Then
					display =""
					img = "../../images/smico/minus.gif"
				else
					display ="none"
					img ="../../images/smico/plus.gif"
				end if
				If Selected Then
					selectstyle ="border:1px dotted #aaaa00;background-color:#444499;color:white"
'If Selected Then
					Randomize
					selectNodeId = "tvw_selNode_" & replace(rnd(),".","")
				else
					selectstyle = ""
					selectNodeId = ""
				end if
				imgurl = ImageUrl
				If Len(ImageUrl) = 0 Then
					imgurl = "../../images/icon_file_c.gif"
				end if
				If len(Tag) = 0 Then
					Tag = Replace(text,"""","&quot;")
				end if
				Dim arri : arri = 0
				ReDim htmlarr(nodes.length+5)
'Dim arri : arri = 0
				If Len(text) = 0 Then text = "<i><空值></i>"
				htmlarr(arri) = "<li LiType='TextItem' id='" & selectNodeId  & "' vHasChild='" & abs(vHasChild) & "' ChildTest='" & ChildTest & "' class='tvw_item" & App.IIf(Selected," tvw_selitem","") & "'  " & _
				" tag=""" & Tag & """ " & _
				" nodeIndex='" & NodeIndex & "' style='white-space: nowrap;'>" & _
				" tag=""" & Tag & """ " & _
				"<span style='width:18px;text-align:center;display:inline-block'>" & _
				" tag=""" & Tag & """ " & _
				App.IIf(nodes.length > 0 or vHasChild,"<img src='" & img & "' onmousedown='tvw.expNode(this)'>","") & "</span>" & _
				"<span onmousedown='tvw.select(this.parentElement);tvw.tryexpNode(this.parentElement)' onmouseover='tvw.itemmouseover(this)' onmouseout='tvw.itemmouseout(this)'  class='tvw_itemtext'>"  & text &  "</span>"
				arri = arri + 1
				If nodes.length > 0 Then
					htmlarr(arri) = "<li class='tvw_item' LiType='ChildNodes' style='display:" & display & "'><ul class='tvw_child'>"
					arri = arri + 1
					For i = 0 To nodes.length - 1
						htmlarr(arri) = nodes.item(i).HTML(id)
						arri = arri + 1
'htmlarr(arri) = nodes.item(i).HTML(id)
					next
					htmlarr(arri) = "</ul>"
					arri = arri + 1
'htmlarr(arri) = "</ul>"
				else
					htmlarr(arri) = "<li class='tvw_item' LiType='ChildNodes' style='display:none'><ul class='tvw_child'></ul>"
					arri = arri + 1
'htmlarr(arri) = "<li class='tvw_item' LiType='ChildNodes' style='display:none'><ul class='tvw_child'></ul>"
				end if
				if len(selectNodeId ) > 0 then
					htmlarr(arri)  + "<script language=javascript>window.currTreeNode=document.getElementById('" & selectNodeId  & "');</script>"
'if len(selectNodeId ) > 0 then
				end if
				HTML = Join(htmlarr,"")
				Erase htmlarr
			end function
		End Class
		Class TreeView
			Public Root
			Public id
			Public cssText
			Public tag
			Private Sub  Class_Initialize
				Set Root = new NodeClass
				Set Root.ParentNode = Nothing
				Root.NodeIndex = 0
				root.depth = 0
				tag = ""
			end sub
			Public Function XML
			end function
			Public Function HTML
				if len(id)=0 then
					TreeView_autoIndex  = TreeView_autoIndex  + 1
'if len(id)=0 then
				end if
				If App.isSub("tvw_onCreate") Then
					Call tvw_onCreate(me)
				end if
				HTML ="<ul class='treeview'tag='" & tag & "' id='treeview_id" & id & "' onselectstart='return false' style='" & cssText & "'>" & vbcrlf & Root.HTML(id) & "</ul>"
			end function
			Public Function CreateChildNodes()
				Set pNode = new NodeClass
				pNode.depth = 0
				Set CreateChildNodes = new NodeCollection
				Set CreateChildNodes.ParentNode = pNode
			end function
			public function createNodePage(rcount , pindex  , psize )
				dim frmdat
				if rcount > psize  then
					frmdat = replace(request.form,"&sys_tvw_pindex=" & pindex , "",1,-1,1)
'if rcount > psize  then
					pscount = rcount\psize + abs(rcount mod psize > 0)
'if rcount > psize  then
					if pindex - pscount > 0 then  pindex =  pscount
'if rcount > psize  then
					createNodePage = "<li class='tvw_item' psize='1' style='line-height:16px;height:32px'><table><tr><td style='width:18px'></td><td><pre>共" & rcount & "条&nbsp;</td><td><pre>" & psize & "/页&nbsp;</td><td><pre>" & pindex & "/" & pscount & "页</td></tr><tr><td></td><td colspan=3 formdata=""" & replace(frmdat,"""","&#34;") & """><input type=text class=text style='width:30px;height:15px;line-height:15px' value='" & pindex  & "'>&nbsp;<a href='###' onclick='tvw.GoToPage()'>GO</a>&nbsp;<a href='###' onclick='tvw.GoToPage(1)'>首</a>&nbsp;<a href='###' onclick='tvw.GoToPage(" & (pindex*1-1) & ")'>上</a>&nbsp;<a href='###' onclick='tvw.GoToPage(" & (pindex*1+1) & ")'>下</a>&nbsp;<a href='###' onclick='tvw.GoToPage(" & pscount & ")'>尾</a></td></tr></table></li><ul class='tvw_child' psize='1'></ul>"
'if rcount > psize  then
				end if
			end function
		End Class
		
		Class GroupImage
			Public ImageType
			Public xName
			Public yName
			Public xType
			Public yType
			Public dataRecord
			Public width
			Public height
			Public offsetLeft
			Public offsetTop
			Private currZindex
			Private mMaxValue
			Private mMinValue
			Private mCount
			Private mgroups
			Private mgroupValues
			Private mGroupCount
			private htmobj
			Public Sub class_Initialize
				offsetleft   = 90
				offsettop    = 70
				width                = 580
				height               = 320
				currZindex = 1
				set htmobj = nothing
			end sub
			Public Sub Label(ByVal x0 , ByVal y0 , ByVal text , ByVal css)
				x0 = x0 + offsetLeft
'Public Sub Label(ByVal x0 , ByVal y0 , ByVal text , ByVal css)
				y0 = y0 + offsetTop
'Public Sub Label(ByVal x0 , ByVal y0 , ByVal text , ByVal css)
				Response.write "<div style='position:absolute;left:" & x0 & "px;top:" & y0 & "px;" & css & ";z-index:" & currZindex & "'>" & text & "</div>"
'Public Sub Label(ByVal x0 , ByVal y0 , ByVal text , ByVal css)
				currZindex = currZindex + 1
'Public Sub Label(ByVal x0 , ByVal y0 , ByVal text , ByVal css)
			end sub
			Public Sub line(ByVal x0,ByVal y0,ByVal x1, ByVal y1 , ByVal color , ByVal Size , byval lStyle)
				x0 = x0 + offsetLeft
'Public Sub line(ByVal x0,ByVal y0,ByVal x1, ByVal y1 , ByVal color , ByVal Size , byval lStyle)
				y0 = y0 + offsetTop
'Public Sub line(ByVal x0,ByVal y0,ByVal x1, ByVal y1 , ByVal color , ByVal Size , byval lStyle)
				x1 = x1 + offsetLeft
'Public Sub line(ByVal x0,ByVal y0,ByVal x1, ByVal y1 , ByVal color , ByVal Size , byval lStyle)
				y1 = y1 + offsetTop
'Public Sub line(ByVal x0,ByVal y0,ByVal x1, ByVal y1 , ByVal color , ByVal Size , byval lStyle)
				Response.write "<v:line style='left:0px;top:0px;color:#000;visibility:visible;display:block;position:absolute' strokeColor=""" & color & """ from='" & x0 & "," & y0 & "'  to='" & x1 & "," & y1 & "'>"
				Select Case lStyle
				Case 1: Response.write "<v:stroke EndArrow=""Classic"" />"
				Case 2: Response.write "<v:stroke EndArrow=""Oval"" />"
				Case 3: Response.write "<v:stroke StartArrow=""Oval""  EndArrow=""Oval"" />"
				End Select
				Response.write "</v:line>"
			end sub
			Public Sub line1(ByVal x0,ByVal y0,ByVal x1, ByVal y1 , ByVal color , ByVal Size , byval lStyle)
				Response.write "<v:line style='left:0px;top:0px;color:#000;visibility:visible;display:block;position:absolute' strokeColor=""" & color & """ from='" & x0 & "," & y0 & "'  to='" & x1 & "," & y1 & "'>"
				Select Case lStyle
				Case 1: Response.write "<v:stroke EndArrow=""Classic"" />"
				Case 2: Response.write "<v:stroke EndArrow=""Oval"" />"
				Case 3: Response.write "<v:stroke StartArrow=""Oval""  EndArrow=""Oval"" />"
				End Select
				Response.write "</v:line>"
			end sub
			Public Sub CCoordinates()
				Dim cindex , dh , yCount , minV , MaxV
				if mMinValue >= 0 Then
					minV = 0
				else
					minV = mMinValue
				end if
				If mMinValue  > 0 Then
					MaxV = mMaxValue * 1.05
				else
					MaxV = (mMaxValue - mMinValue)*1.05 + mMinValue
					MaxV = mMaxValue * 1.05
				end if
				yCount = 6
				If ImageType = 1 Then
					Response.write "" & vbcrlf & "" & vbcrlf & "              <v:polyline style=""left:"
					Response.write offsetleft
					Response.write "px;position:absolute;top:"
					Response.write offsettop+5
					Response.write "px;position:absolute;top:"
					Response.write "px;z-index:-1"" points=""0,0,20,-15,20,"
					Response.write "px;position:absolute;top:"
					Response.write height-20
					Response.write "px;position:absolute;top:"
					Response.write ",0,"
					Response.write height-5
					Response.write ",0,"
					Response.write ",0,0"" filled=""t""   strokeColor=""#aaaaee"">" & vbcrlf & "                      <v:fill type='gradient' color=""#d8dcff"" color2=""#c5cfff"" Angle=""90""/>" & vbcrlf & "         </v:polyline>" & vbcrlf & "           " & vbcrlf & "                <v:polyline style=""left:"
					Response.write offsetleft
					Response.write "px;position:absolute;top:"
					Response.write offsettop+height
					Response.write "px;position:absolute;top:"
					Response.write "px;z-index:-2"" points=""0,0,20,-15,"
					Response.write "px;position:absolute;top:"
					Response.write width+10
					Response.write "px;position:absolute;top:"
					Response.write ",-15,"
					Response.write "px;position:absolute;top:"
					Response.write width-10
					Response.write "px;position:absolute;top:"
					Response.write ",0,0,0"" filled=""t""   strokeColor=""#aaaaee"">" & vbcrlf & "                    <v:fill type='gradient' color=""#d8dcff"" color2=""#c5cfff"" Angle=""0""/>" & vbcrlf & "          </v:polyline>" & vbcrlf & "" & vbcrlf & "           <v:Rect style=""z-index:-5;left:"
					Response.write "px;position:absolute;top:"
					Response.write offsetleft+20
					Response.write "px;position:absolute;top:"
					Response.write "px;top:"
					Response.write offsetTop-10
					Response.write "px;top:"
					Response.write "px;position:relative;width:"
					Response.write width-10
					Response.write "px;position:relative;width:"
					Response.write "px;height:"
					Response.write height-5
					Response.write "px;height:"
					Response.write "px;position:absolute;"" strokeColor=""#f9f9ff"">" & vbcrlf & "                <v:fill type='gradient' color=""#b5beff"" color2=""#ffffff"" Angle=""315""/>" & vbcrlf & "                </v:Rect>" & vbcrlf & "               "
				else
					Response.write "" & vbcrlf & "              <v:Rect style=""z-index:-6;left:"
					Response.write offsetleft
					Response.write "px;top:"
					Response.write offsetTop
					Response.write "px;position:relative;width:"
					Response.write width
					Response.write "px;height:"
					Response.write height
					Response.write "px;position:absolute;"" strokeColor=""#f9f9ff"">" & vbcrlf & "               <v:fill type='gradient' color=""#e5eeff"" color2=""#ffffff"" Angle=""315""/>" & vbcrlf & "                </v:Rect>" & vbcrlf & "               "
				end if
				currZindex = currZindex + 1
				Call line(0,height,0,-10,"#000" , 1 , 1)
				Call line(0,height,width,height,"#000" , 1 , 1)
				cindex = currZindex
				currZindex = 10000
				Call Label(-10,-22,"<b>" & app.iif(yName=xName,"",yName) & "" & getGroupTypeText() & "</b>" & app.iif(yType = "count","","<span style='font-size:12px' class=c_c>&nbsp;(共<b style='color:red'>" & mCount & "</b>条记录)</span>") & "&nbsp;<span class=c_c></span>" ,"")
'currZindex = 10000
				currZindex = cindex
				Call Label(width+5,height-5,"<b>" & xName & "</b>","")
'currZindex = cindex
				dh = CInt(height / yCount)
				If ImageType = 1 Then
					For I = 0 To yCount
						h =  CInt(height - dh*i + 5)
'For I = 0 To yCount
						If i = 0 Then h = height
						v = maxv * (i/ycount)
						Call line(-6, h, 0 , h ,"#000",1,0)
'v = maxv * (i/ycount)
						If instr(v,".") > 0 Then v = FormatNumber(v,2,-1)
'v = maxv * (i/ycount)
						Call Label(-70,h-6,v,"text-align:right;width:60px;font-weight:bold;font-family:arial")
'v = maxv * (i/ycount)
						If i < yCount And i > 0 Then
							Call line(1, h, 20 , h -15 ,"white",1,0)
'If i < yCount And i > 0 Then
							Call line(20, h-15, width+10 , h -15 ,"#f4f4ff",1,0)
'If i < yCount And i > 0 Then
						end if
					next
				Else
					For I = 0 To yCount
						h =  CInt(height - dh*i + 5)
'For I = 0 To yCount
						If i = 0 Then h = height
'v = maxv * (i/ycount)
						Call line(-6, h, 0 , h ,"#000",1,0)
'v = maxv * (i/ycount)
						If instr(v,".") > 0 Then v = FormatNumber(v,2,-1)
'v = maxv * (i/ycount)
						Call Label(-70,h-6,v,"text-align:right;width:60px;font-weight:bold;font-family:arial")
'v = maxv * (i/ycount)
						If i> 0 Then Call line(1, h, width , h  ,"#e0e0f8",1,0)
					next
				end if
			end sub
			Private Function getGroupTypeText()
				Select Case yType
				Case "count" : getGroupTypeText = "数量" : Exit Function
				Case "sum" :   getGroupTypeText = "汇总" : Exit Function
				Case "max" :   getGroupTypeText = "最大值" : Exit Function
				Case "min" :   getGroupTypeText = "最小值" : Exit Function
				Case "avg" :   getGroupTypeText = "平均值" : Exit Function
				Case "var" :   getGroupTypeText = "方差" : Exit Function
				Case "stdev" :   getGroupTypeText = "标准偏差" : Exit Function
				Case "stdevp" :   getGroupTypeText = "总体标准偏差" : Exit function
				End Select
				getGroupTypeText = "其它"
			end function
			Private Sub DataInit
				Dim rs , v
				Set rs = dataRecord
				mMaxValue = -100000
'Set rs = dataRecord
				mMinValue = -100000
'Set rs = dataRecord
				mCount      = 0
				mGroupCount = -1
'mCount      = 0
				ReDim mgroups(0)
				ReDim mgroupValues(0)
				While not rs.eof
					v = rs.fields(1).value & ""
					If Len(v) = 0 Then v = 0
					If Not IsNumeric(v) Then v = 0
					v = v * 1
					mGroupCount = mGroupCount + 1
'v = v * 1
					ReDim preserve mgroups(mGroupCount)
					ReDim preserve mgroupvalues(mGroupCount)
					mgroups(mGroupCount) = rs.fields(0).value & ""
					mgroupvalues(mGroupCount) = v
					mCount = mCount + rs.fields(2).value
'mgroupvalues(mGroupCount) = v
					If mMaxValue =      -100000 Then
'mgroupvalues(mGroupCount) = v
						mMaxValue = v
					else
						If mMaxValue < v Then
							mMaxValue = v
						end if
					end if
					If mMinValue =      -100000 Then
						mMaxValue = v
						mMinValue = v
					else
						If mMinValue > v Then
							mMinValue = v
						end if
					end if
					rs.movenext
				wend
				If mMaxValue =      -100000 Then mMaxValue = 0
				mMinValue = v
			end sub
			Public Sub CreateHTML
				Call DataInit
				Select Case ImageType
				Case 1
				Call CCoordinates()
				Call DrawRectGroup
				Case 2
				Call DrawOvalGroup
				Case 3
				Call CCoordinates()
				Call DrawRectGroup
				End Select
			end sub
			Private Sub DrawRectGroup
				Dim dw , I , ox , minV , MaxV , ox1
				ox1 = 0
				if mMinValue >= 0 Then
					minV = 0
				else
					minV = mMinValue
				end if
				If mMinValue  > 0 Then
					MaxV = mMaxValue * 1.05
				else
					MaxV = (mMaxValue - mMinValue)*1.05 + mMinValue
					MaxV = mMaxValue * 1.05
				end if
				If mgroupcount >= 0 Then
					If imagetype = 1 then
						dw = CInt((width - 10) / cint((mGroupCount+1)*5))
'If imagetype = 1 then
					else
						If mGroupCount > 0 then
							dw = CInt((width - 10) / cint((mGroupCount)*5))
'If mGroupCount > 0 then
						else
							dw = width
						end if
					end if
					ox = dw
					For I = 0 To mGroupCount
						If  ImageType = 1 Then
							Call label(ox, height+2 , mgroups(i) , "width:" & CInt(dw*3) & "px;word-break:break-all;font-family:arial")
'If  ImageType = 1 Then
							Call DrawRectItem(mgroupvalues(i) , maxv , minv , ox , dw*3 , i)
						Else
							If I > 0 Then
								Call DrawNodeLine (mgroupvalues(i-1),mgroupvalues(i), maxv , minv , ox1, ox1 + 5*dw ,i , dw)
'If I > 0 Then
								ox1 = ox1 + 5*dw
'If I > 0 Then
							else
								ox1 = 0
								If mGroupCount =  0  Then
									Call DrawNodeLine (mgroupvalues(i),mgroupvalues(i), maxv , minv , width, ox1 ,i , dw)
								end if
							end if
							Call label(ox1-cint(dw*1.5), height+10 , mgroups(i) , "width:" & CInt(dw*3) & "px;word-break:break-all;font-family:arial;")
							Call DrawNodeLine (mgroupvalues(i),mgroupvalues(i), maxv , minv , width, ox1 ,i , dw)
							Call line (ox1,height+6,ox1,height,"#000",1,0)
'Call DrawNodeLine (mgroupvalues(i),mgroupvalues(i), maxv , minv , width, ox1 ,i , dw)
						end if
						ox = ox + dw*5
						Call DrawNodeLine (mgroupvalues(i),mgroupvalues(i), maxv , minv , width, ox1 ,i , dw)
					next
				end if
			end sub
			Private Sub DrawNodeLine (ByVal v1 , ByVal v2 , ByVal MaxV , ByVal MinV , ByVal x1 , ByVal x2 , ByVal index ,ByVal dw)
				Dim h1, h2
				If InStr(CStr(v1 & ""),".")>0 Then
					v1 = FormatNumber(v1,2,-1)
'If InStr(CStr(v1 & ""),".")>0 Then
				end if
				If InStr(CStr(vw & ""),".")>0 Then
					v2 = FormatNumber(vw,2,-1)
'If InStr(CStr(vw & ""),".")>0 Then
				end if
				If maxv-minv > 0 then
'If InStr(CStr(vw & ""),".")>0 Then
					h1 = CInt((v1-minv)*height / (maxv-minv))
'If InStr(CStr(vw & ""),".")>0 Then
					h2 = CInt((v2-minv)*height / (maxv-minv))
'If InStr(CStr(vw & ""),".")>0 Then
				else
					h1 = 0
					h2 = 0
				end if
				If index = 1 Then
					index = 1
					Call label(CInt(x1-dw),height-h1-15, v1,"width:" & dw*3 & "px;color:red;z-index:600;font-weight:bold")
'index = 1
				else
					index = 0
				end if
				Call line (x1,height-h1,x2,height-h2,"#000",1,(2+index))
				index = 0
				Call label (CInt(x2-dw*1.4),height-h2-16, v2,"width:" & dw*3 & "px;color:red;z-index:600;font-weight:bold")
'index = 0
			end sub
			Private Sub DrawRectItem(ByVal v, ByVal maxV ,ByVal  minV , ByVal mLeft ,ByVal  mWidth ,byval index)
				Dim h , c1 , c2 , c3, c4 , c5 , w1 , l1
				Dim cellMaxWidth
				cellMaxWidth = 42
				Call GetColor(c1 , c2 , c3 , c4, c5, index )
				If InStr(CStr(v & ""),".")>0 Then
					v = FormatNumber(v,2,-1)
'If InStr(CStr(v & ""),".")>0 Then
				end if
				If maxv-minv > 0 then
'If InStr(CStr(v & ""),".")>0 Then
					h = CInt((v-minv)*height / (maxv-minv))
'If InStr(CStr(v & ""),".")>0 Then
				else
					h = 0
				end if
				w1 = mWidth
				l1 = mleft
				If mWidth > cellMaxWidth Then
					mLeft = cint((mWidth - cellMaxWidth) / 2 + mLeft)
'If mWidth > cellMaxWidth Then
					mWidth = cellMaxWidth
				end if
				Response.write "" & vbcrlf & "                     <v:Rect style=""z-index:"
				mWidth = cellMaxWidth
				Response.write currZindex
				Response.write ";left:"
				Response.write offsetleft+mleft
				Response.write ";left:"
				Response.write "px;top:"
				Response.write offsetTop+height-h-1
				Response.write "px;top:"
				Response.write "px;position:relative;width:"
				Response.write mWidth
				Response.write "px;height:"
				Response.write h
				Response.write "px;position:absolute;"" strokeColor="""
				Response.write c5
				Response.write """>" & vbcrlf & "                        <v:fill type='gradient' color="""
				Response.write c1
				Response.write """ color2="""
				Response.write c2
				Response.write """ Angle=""0""/>" & vbcrlf & "                       </v:Rect>" & vbcrlf & "" & vbcrlf & "                       <v:polyline style=""left:"
				Response.write (offsetleft+mleft+mwidth)
				Response.write "px;position:absolute;top:"
				Response.write offsetTop+height-h
				Response.write "px;position:absolute;top:"
				Response.write "px;z-index:"
				Response.write "px;position:absolute;top:"
				Response.write currZindex
				Response.write """ points=""0,0,20,-15,20,"
				Response.write currZindex
				Response.write h-15
				Response.write currZindex
				Response.write ",0,"
				Response.write h
				Response.write ",0,0"" filled=""t""   strokeColor="""
				Response.write c5
				Response.write """>" & vbcrlf & "                        <v:fill type='gradient' color="""
				Response.write c3
				Response.write """ color2="""
				Response.write c4
				Response.write """ Angle=""0""/>" & vbcrlf & "                       </v:polyline>" & vbcrlf & "" & vbcrlf & "                   <v:polyline style=""left:"
				Response.write (offsetleft+mleft)
				Response.write "px;position:absolute;top:"
				Response.write offsetTop+height-h
				Response.write "px;position:absolute;top:"
				Response.write "px;z-index:"
				Response.write "px;position:absolute;top:"
				Response.write currZindex
				Response.write """ points=""0,0,20,-15,"
				Response.write currZindex
				Response.write mwidth+20
				Response.write currZindex
				Response.write ",-15,"
				Response.write currZindex
				Response.write mwidth
				Response.write ",0,0,0"" filled=""t""   strokeColor="""
				Response.write c1
				Response.write """>" & vbcrlf & "                        <v:fill type='gradient' color="""
				Response.write c1
				Response.write """ color2="""
				Response.write c1
				Response.write """ Angle=""315""/>" & vbcrlf & "                     </v:polyline>" & vbcrlf & "           "
				Call label(l1+10, height-h-16, v , "color:#ffffff;font-family:arial;font-weight:bold;width:" & CInt(w1) & "px;word-break:break-all")
				Response.write """ Angle=""315""/>" & vbcrlf & "                     </v:polyline>" & vbcrlf & "           "
				currZindex = currZindex + 1
				Response.write """ Angle=""315""/>" & vbcrlf & "                     </v:polyline>" & vbcrlf & "           "
			end sub
			Private Sub GetColor(ByRef color1,ByRef color2,ByRef color3,ByRef color4,ByRef color5,ByVal index)
				Dim sign
				sign = index Mod 7
				Select Case sign
				Case 0 :
				color1 = "#008800"
				color2 = "#ccffcc"
				color3 = "#008800"
				color4 = "#aaeeaa"
				color5 = "#77cc77"
				Case 1 :
				color1 = "#ff0000"
				color2 = "#ffeeee"
				color3 = "#ff3333"
				color4 = "#ffbbbb"
				color5 = "#ff8888"
				Case 2 :
				color1 = "#3333ee"
				color2 = "#eeeeff"
				color3 = "#4444ee"
				color4 = "#ccccff"
				color5 = "#ccccff"
				Case 3 :
				color1 = "#ee8800"
				color2 = "#ffeeaa"
				color3 = "#e07800"
				color4 = "#ffcc00"
				color5 = "#ffcc55"
				Case 4 :
				color1 = "#666688"
				color2 = "#aaaacc"
				color3 = "#777799"
				color4 = "#8888aa"
				color5 = "#777799"
				Case 5 :
				color1 = "#e433e4"
				color2 = "#f5eef5"
				color3 = "#e022e0"
				color4 = "#f5ddf5"
				color5 = "#faaaf5"
				Case 6 :
				color1 = "#888800"
				color2 = "#eeee33"
				color3 = "#777700"
				color4 = "#eeee77"
				color5 = "#bbbb77"
				End Select
			end sub
			Private Sub DrawOvalGroup
				Dim  i , s , r
				dim item_p
				dim item_q
				dim sum     :       sum=0
				r = CInt(width / 3)
				dim d : d = r*2
				dim  color1 :       color1 = split("#d1ffd1,#ffaaaa,#ffe3bb,#afeff3,#d9d9e5,#ffc7ab,#ecffb7", ",")
				dim  color2 :       color2 = split("#00ff00,#ee0000,#ff9900,#2244bb,#666699,#993300,#99cc00", ",")
				For i=0 To mGroupCount
					sum = sum + mgroupvalues(i)
'For i=0 To mGroupCount
				next
				If sum = 0 Then sum = 0.00001
				ReDim item_p(mGroupCount)
				ReDim item_q(mGroupCount)
				For i=0 To mGroupCount
					item_p(i)=mgroupvalues(i)/sum
					item_q(i)=FormatNumber(item_p(i)*100,1,-1)+"%"
'item_p(i)=mgroupvalues(i)/sum
				next
				s="<v:group style='width:"& (d+230) & "px;height:" & d & "px' coordsize='"& (d+230) & "," & d & "'>"
				item_p(i)=mgroupvalues(i)/sum
				s = ""
				s = s & "<v:rect style='left:-5;top:-5;width:" & (d+235) & ";height:" & (d+10) & "'>"
's = ""
				s = s & "<v:shadow on='t' type='single' color='silver' offset='5px,5px' />"
				s = s & "</v:rect>"
				dim  angle1 : angle1=0
				dim  angle2
				dim  zindex : zindex= 10000
				Dim  cindex
				For i = 0 To mGroupCount
					if angle1 < 90 Then zindex = zindex - 1
'For i = 0 To mGroupCount
					if angle1 > 90 And  angle1 < 180 Then zindex = zindex + 100
'For i = 0 To mGroupCount
					if angle1 > 180 And  angle1 < 270 Then  zindex = zindex + 200
'For i = 0 To mGroupCount
					if angle1 > 270 then zindex = zindex -50
'For i = 0 To mGroupCount
					angle2=CInt(360*item_p(i))
					If i=mGroupCount Then angle2 = 360-angle1
'angle2=CInt(360*item_p(i))
					cindex  = i Mod 7
					s = s & ("<v:shape title='" & getInnerText(mgroups(i)) & "：" & getInnerText(item_q(i)) & "'  style='position:absolute;z-index:"  &  zindex  &  ";width:" & d & ";height:" & d & "' coordsize='" & d & "," & d & "' strokeweight='1' strokecolor='#fff' fillcolor='" & color1(cindex) & "' path='m " & r & "," & r & " ae " & r & "," & r & "," & r & "," & r & "," & 65536*angle1 & "," & 65536*angle2 & " x e'>")
					s = s & "<v:fill color2='" & color2(cindex) & "' rotate='t' focus='100%' type='gradient' />"
					s = s & "<o:extrusion v:ext='view' on='t' backdepth='20' rotationangle='60' viewpoint='0,0'viewpointorigin='0,0' skewamt='0' lightposition='-50000,-50000' lightposition2='50000'/></v:shape>"
					s = s & "<v:fill color2='" & color2(cindex) & "' rotate='t' focus='100%' type='gradient' />"
					angle1 = angle1 + angle2
					s = s & "<v:fill color2='" & color2(cindex) & "' rotate='t' focus='100%' type='gradient' />"
				next
				s = s & "<v:group style='position:absolute;left:" & (d+25) & ";top:" & (d-(22*(mGroupCount+1)+12)) & ";width:200;height:" & (22*(mGroupCount+1)+4) & "' coordsize='200," & (22*(mGroupCount+1)+4) & "'>"
				s = s & "<v:fill color2='" & color2(cindex) & "' rotate='t' focus='100%' type='gradient' />"
				s = s & "<v:rect style='width:240;height:" & (22*(mGroupCount+1)+4) & "' strokecolor='#333' />"
				s = s & "<v:fill color2='" & color2(cindex) & "' rotate='t' focus='100%' type='gradient' />"
				For i = 0 To mGroupCount
					cindex  = i Mod 7
					If InStr(CStr(mgroupvalues(i)),".") > 0 Then mgroupvalues(i) = FormatNumber(mgroupvalues(i),2,-1)
'cindex  = i Mod 7
					
					s = s &"<v:rect style='left:4;top:" & (i*22+4) & ";width:25;height:18;' title=""" & replace(mgroups(i),"""","&quot;") & "：" & replace(item_q(i),"""","&quot;") & """ fillcolor='" & color1(cindex) & "'><v:fill color2='" & color2(cindex) & "' rotate='t' focus='100%' type='gradient' /></v:rect>"
					s = s & "<v:shape style='left:30;top:" & (i*22+4) & ";width:240;height:25;'><v:textbox inset='0,0,0,0'><table align=left style='" & app.iif(i Mod 2 = 1, "background-color:#ffffcc","" ) & ";width:208px;height:20px'><td style='font-size:12px' style='width:90px;text-align:right;table-layout:fixed;height:20px'><div style='padding:0px;height:14px;overflow:hidden'>" & mgroups(i) & "：</div></td><td style='width:120px;text-align:left;font-family:arial;padding-left:6px'><b>" & mgroupvalues(i) & "</b> (" & item_q(i) & ")</td></table></v:textbox></v:shape>"
				next
				s = s & "</v:group>"
				s = s & ""
				Response.write  "<div style='position:absolute;left:" & (offsetLeft-10) & "px;top:0px'>" & s & "</div>"
's = s & ""
			end sub
			Function getInnerText(html)
				Dim tArray, i
				tArray = Split(Replace(html, ">", "<"), "<")
				For i = 0 To UBound(tArray) Step 2
					getInnerText = getInnerText + tArray(i)
'For i = 0 To UBound(tArray) Step 2
				next
			end function
		End Class
		Class SelectBoxOption
			Public name
			Public value
		End Class
		Class ProxyOptionClass
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
		class DrConfigData
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
				set optionItems(optionCount) = new ProxyOptionClass
				set addOption = optionItems(optionCount)
			end function
		end class
		Class ListViewHeader
			Public ywName
			Public oldywname
			private mdbName
			Public width
			private mdtype
			Public ltype
			Public Save
			Public handerror
			Public defaultValue
			Public notnull
			Private mHTML
			Private mIsConst
			Public visible
			Public resize
			Public ColReplaceButton
			Public cookiewidth
			Public sortIndex
			private mhtmlvisible
			Private mhtmldisplay
			Private SelectModeArray
			private mselID
			Private isSelectBox
			public KeySelectBox
			Public syshide
			Public canExport
			public AutoProductLink
			public canGroup
			public align
			public disztlr
			public bill
			public swpAttr
			public maxsize
			Public lockFormat
			Public udefname
			Public cansort
			Public searchtype
			Public isInt
			Public BgColor
			Public isHtmlValue
			Private mEdit
			Public Property Get Edit
			Edit = mEdit
			End Property
			Public Property let Edit(nv)
			mEdit = nv
			End property
			Public Property Get dbName
			dbName = mdbName
			End Property
			Public Property let dbName(newv)
			mdbName = newv
			If InStr(newv, "#hide") > 0 Then
				htmlvisible = 0
			end if
			End Property
			Public Property Get dtype
			dtype = mdtype
			End property
			Public Property let dtype(newv)
			mdtype = lcase(newv)
			End Property
			Public Property Get selID
			selID = mselID
			End property
			Public Property let selID(newvalue)
			If mselID <> newvalue Then
				mselID = newvalue
				maxsize=8000
				Call tryLoadSelectBoxArray
			end if
			End Property
			Public Property Get htmldisplay
			htmldisplay = mhtmldisplay
			End property
			Public Property Get htmlvisible
			htmlvisible = mhtmlvisible
			End Property
			Public Function GetSelectBoxArrayText
				Dim dat , i , count
				If isSelectBox Then
					count = UBound(SelectModeArray) - 1
'If isSelectBox Then
					ReDim dat(count)
					For i = 0 To count
						dat(i) = SelectModeArray(i+1).name & "=" & SelectModeArray(i+1).value
'For i = 0 To count
					next
					GetSelectBoxArrayText = Join(dat,"|")
				else
					If dtype = "bit" Then
						GetSelectBoxArrayText = "是=1|否=0"
					else
						GetSelectBoxArrayText = ""
					end if
				end if
				GetSelectBoxArrayText = replace(replace(replace(GetSelectBoxArrayText,"""","&quot;"),"<","&lt;"),">","&gt;")
			end function
			Public Property let htmlvisible(v)
			If v = 0 Then
				edit = 0
				mhtmlvisible  = 0
				mhtmldisplay = "style='display:none'"
			else
				mhtmldisplay = ""
				mhtmlvisible  = 1
			end if
			End Property
			Public Property Get IsConst
			IsConst = mIsConst
			End Property
			Public Property Let HTML(ByVal vNewValue)
			mhtml = vNewValue
			mIsConst = Len(mhtml) > 0
			End Property
			Public Property Get HTML()
			html = mhtml
			End Property
			Public Sub  Class_Initialize
				Edit = 1
				selID = 0
				save = 1
				notnull = 0
				mIsConst = False
				visible = 1
				ColReplaceButton = True
				resize = 1
				cookiewidth = ""
				sortIndex = 0
				mhtmlvisible = 1
				isSelectBox = False
				defaultValue = ""
				canExport = 1
				AutoProductLink = 0
				cangroup = 1
				cansort = 1
				disztlr = 0
				isint = 0
				searchtype = 1
				isHtmlValue = 0
				set bill = Nothing
			end sub
			Public Sub tryLoadSelectBoxArray()
				Dim mmsql ,  i , ii ,items , olen , mfs
				ReDim SelectModeArray(0)
				isSelectBox = False
				If mselID > 0 Then
					Set rs = cn.execute("select sqlstring from M_CustomSQLStrings where ID = " & mselId)
					If Not rs.eof Then
						mmsql = rs.fields("sqlstring").value
						mmsql = app.handlePowerVar(mmsql)
						If Len(mmsql)>4 Then
							If Left(mmsql,4) = "sql=" Then
								mmsql = Right(mmsql,Len(mmsql)-4)
'If Left(mmsql,4) = "sql=" Then
								olen = len(mmsql)
								For i = 0 To 50
									if instr(1,mmsql,"@cell[" & i & "]",1)> 0 then
										me.swpAttr = me.swpAttr & "|||@cell[" & i & "]$!''"
										mmsql = Replace(mmsql,"@cell[" & i & "]" , "''")
									end if
								next
								if olen  <> len(mmsql) then disztlr = 1
								mmsql = Replace(mmsql,"@key","''",1,-1,1)
'if olen  <> len(mmsql) then disztlr = 1
								if lcase(typename(bill)) <> "nothing" then
									if instr(1,mmsql,"@bill_id",1)> 0 then
										mmsql = Replace(mmsql,"@bill_id",bill.sheetno,1,-1,1)
'if instr(1,mmsql,"@bill_id",1)> 0 then
										me.swpAttr = me.swpAttr & "|||@bill_id$!" & bill.sheetno
									end if
									if instr(1,mmsql,"@billid",1)> 0 then
										mmsql = Replace(mmsql,"@billid",bill.sheetno,1,-1,1)
'if instr(1,mmsql,"@billid",1)> 0 then
										me.swpAttr = me.swpAttr & "|||@billid$!" & bill.sheetno
									end if
								else
									if instr(1,mmsql,"@bill_id",1)> 0 then
										mmsql = Replace(mmsql,"@bill_id","''",1,-1,1)
'if instr(1,mmsql,"@bill_id",1)> 0 then
										me.swpAttr = me.swpAttr & "|||@bill_id$!''"
									end if
									if instr(1,mmsql,"@billid",1)> 0 then
										mmsql = Replace(mmsql,"@billid","''",1,-1,1)
'if instr(1,mmsql,"@billid",1)> 0 then
										me.swpAttr = me.swpAttr & "|||@billid$!''"
									end if
								end if
								Dim slist
								mmsql = Replace(mmsql,"@uid",app.info.user,1,-1,1)
'Dim slist
								If instr(1,mmsql,"@ProductDefFields[",1) > 0 Then
									slist = Split(mmsql,"@ProductDefFields[")
									mmsql = slist(0) & "0 as pdfsax" & Right(slist(1),Len(slist(1))-InStr(slist(1),"]"))
'slist = Split(mmsql,"@ProductDefFields[")
								end if
								if not bill is nothing then
									set mfs = bill.mainfields
									for i = 1 to  mfs.count
										if instr(1,mmsql,"@" + mfs.items(i).dbname,1)> 0 then
'for i = 1 to  mfs.count
											mmsql = Replace(mmsql,"@" + mfs.items(i).dbname,"''",1,-1,1)
'for i = 1 to  mfs.count
											me.swpAttr = me.swpAttr & "|||" & "@" & mfs.items(i).dbname & "$!''"
										end if
									next
								else
									dim swArray, itemsw
									swArray = split(me.swpAttr,"|||")
									for i = 1 to ubound(swArray)
										if instr( swArray(i) , "$!") > 0 then
											itemsw = split(swArray(i),"$!")
											mmsql = replace(mmsql, itemsw(0),itemsw(1),1,-1,1)
'itemsw = split(swArray(i),"$!")
										end if
									next
								end if
							else
								mmsql = ""
							end if
						else
							mmsql = ""
						end if
					else
						mmsql = ""
					end if
					rs.close
					set rs = nothing
				else
					mmsql = ""
				end if
				If Len(mmsql) > 0 And InStr(1,mmsql, "@@istreemode", 1)=0 Then
					i = 0
					on error resume next
					Set rs = app.getdatarecord(cn.execute(mmsql))
					if err.number <> 0 then
						app.showerr "获取ListView的关联检索错误。" , "SQL：" & mmsql & " 消息:" & Err.description & "&nbsp;Row=231。"
						cn.close
						call db_close : Response.end
					end if
					on error goto 0
					xxx=  rs.eof
					If InStr(rs.fields(0).name & "", "{keylistmodel}")>0 Then
						KeySelectBox= True
						isSelectBox = true
						If rs.eof Then
							i = i + 1
'If rs.eof Then
							ReDim preserve SelectModeArray(i)
							Set selectModeArray(i) = new SelectBoxOption
							selectModeArray(i).name = ""
							selectModeArray(i).value = "0"
						else
							While rs.eof = false
								i = i + 1
'While rs.eof = false
								ReDim preserve SelectModeArray(i)
								Set selectModeArray(i) = new SelectBoxOption
								Dim tmpvsss: tmpvsssx = Split( rs.fields(0).value & "^tag~", "^tag~")
								selectModeArray(i).name = tmpvsssx(0)
								selectModeArray(i).value = tmpvsssx(1)
								rs.movenext
							wend
						end if
					end if
					If rs.fields.count=2 And rs.fields(0).name = "billselectname" Then
						isSelectBox = True
						If rs.eof Then
							i = i + 1
'If rs.eof Then
							ReDim preserve SelectModeArray(i)
							Set selectModeArray(i) = new SelectBoxOption
							selectModeArray(i).name = ""
							selectModeArray(i).value = "0"
						else
							While rs.eof = false
								i = i + 1
'While rs.eof = false
								ReDim preserve SelectModeArray(i)
								Set selectModeArray(i) = new SelectBoxOption
								selectModeArray(i).name = rs.fields(0).value
								selectModeArray(i).value = rs.fields(1).value
								rs.movenext
							wend
						end if
					end if
					rs.close
				end if
			end sub
			Public Function value(v)
				Dim i,item
				err.clear
				If isSelectBox Then
					For i =  1 To UBound(SelectModeArray)
						If isnumeric(v) And isnumeric(SelectModeArray(i).value) Then
							If v*1=SelectModeArray(i).value*1 Then
								value = SelectModeArray(i).name
								Exit function
							end if
						ElseIf trim(v) = Trim(SelectModeArray(i).value) Then
							value = SelectModeArray(i).name
							Exit function
						end if
					next
					If isnumeric(v) then
						value = ""
					else
						value = v
					end if
				else
					If mdtype = "bit" Then
						If abs(v) = 1 Then
							value = "是"
						else
							value = "否"
						end if
					elseif dtype="number" and len(v) > 0 And selid=0 And mhtmlvisible = 1 then
						on error resume next
						If Right(ywname,1) = "价" Or Right(ywname,1) = "额" Or Right(ywname,2) = "成本" Or Right(ywname,2) = "工资" Or Right(ywname,2) = "薪水"  Then
							value = Replace(formatnumber(v,app.info.moneynumber,-1) & "", ",", "")
						else
							value = Replace(formatnumber(v,app.info.FloatNumber,-1) & "", ",", "")
						end if
						On Error GoTo 0
					elseif dtype="percent" and len(v) > 0 And selid=0 And mhtmlvisible = 1 then
						on error resume next
						v = (v * 100)
						If (Right(ywname,1) = "率" Or Right(ywname,1) = "比") And (instr(ywname,"价")>0 Or instr(ywname,"额")>0 or instr(ywname,"成本")>0 or instr(ywname,"工资")>0 ) Then
							value = Replace(formatnumber(v,app.info.moneynumber,-1) & "", ",", "")
						else
							value = Replace(formatnumber(v,app.info.FloatNumber,-1) & "", ",", "")
						end if
						value = value &"%"
						On Error GoTo 0
					ElseIf dtype = "autosigncol" Then
						If InStr(v,"@") = 0 Then
							value = "!@_SASC_" & v
						end if
					elseIf dtype = "commprice" then
						value = Replace(formatnumber(v,app.info.CommPriceNumber,-1) & "", ",", "")
'elseIf dtype = "commprice" then
					elseIf dtype = "salesprice" then
						value = Replace(formatnumber(v,app.info.SalesPriceNumber,-1) & "", ",", "")
'elseIf dtype = "salesprice" then
					elseIf dtype = "storeprice" then
						value = Replace(formatnumber(v,app.info.StorePriceNumber,-1) & "", ",", "")
'elseIf dtype = "storeprice" then
					elseIf dtype = "financeprice" then
						value = Replace(formatnumber(v,app.info.FinancePriceNumber,-1) & "", ",", "")
'elseIf dtype = "financeprice" then
					else
						If isHtmlValue = 0 Then
							If InStr(1,v, "<span ",1) > 0 Then
								isHtmlValue = 1
							end if
						end if
						If InStr(v,"^tag~")>0 And save=0 Then  v= Split(v, "^tag~")(0)
						value = v
					end if
				end if
				value = replace(value,chr(0),"")
			end function
			Public Function titlevalue(v)
				If dtype = "bit" Then
					titlevalue = abs(v)
				else
					titlevalue= app.iif(isSelectBox , v ,"")
				end if
			end function
			Public Function title(v)
				If dtype = "bit" then
					title = "title ='" & abs(v) & "'"
				else
					title = app.iif(isSelectBox ,"title ='" & v & "'","")
				end if
			end function
		End Class
		Class ListSumData
			Private dbnames
			Private values
			private mcount
			Public sub Class_Initialize
				ReDim dbnames(0)
				ReDim values(0)
				mcount = 0
			end sub
			Public Property Get Count
			Count = mcount
			End property
			Public Sub Add(ByVal dbname, ByVal value)
				ReDim Preserve dbnames(mcount)
				ReDim Preserve values(mcount)
				dbnames(mcount) = dbname
				values(mcount) = value
				mcount = mcount + 1
'values(mcount) = value
			end sub
			Public Function GetItem(ByVal dbname)
				Dim i
				For i = 0 To mcount -1
'Dim i
					If LCase(dbnames(i)) = LCase(dbname) Then
						GetItem = values(i)
						Exit function
					end if
				next
				getitem = ""
			end function
		End Class
		Class ListView
			Public cols
			Public HeadBold
			Public AutoIndex
			Public AutoRepeat
			Public CheckBox
			Public PageSize
			Private mPageType  '分页方式，是数据库级别的分页{"database"} , 还是JS级别的分页 {script} , 一般海量数据查询用db分页 , 添加大量数据用js分页（确保数据连续）
			Public PageIndex
			Public PageCount
			Public handerror
			Public autoSum
			Public id
			Public canAdd
			Public showAddButton
			Public canDelete
			Public delAlert
			Public canUpdate
			Public canSort
			Public canExcel
			Public canGroup
			Public filterText
			Public width
			Private msql
			Public showtool
			Public DataCol
			Public VisibleCol
			Private HideCols
			Private rs
			Public IsStateCallBack
			Public LeftFixCount
			Public Formula
			Public border
			Public FieldAttrButton
			Public FieldAttrSaveKey
			Public dbCheckBox
			public AutoProductLink
			public Bill
			public lefttopHTML
			public candr
			private mRecordCount
			private runtimemaxdeep
			public showheader
			public showpsbox
			public tmpTableSql
			public sums
			Public centercols
			Public hData
			Public SortText
			Public callBackSortText
			Public CommUICss
			Public lbBarHTML
			Public nodataMsg
			Public DisHideAutoSum
			Public xlsname
			Public IsDbPageSize
			Public dbSum
			Public sqlfiltermodel
			public property Get RecordCount
			if mRecordCount < 0 then
				mRecordCount = 0
				If not rs.bof then
					rs.movefirst
				end if
				While not rs.eof
					mRecordCount = mRecordCount + 1
'While not rs.eof
					rs.movenext
				wend
				If not rs.bof then
					rs.movefirst
				end if
			end if
			RecordCount = mRecordCount
			end property
			Public Property Get PageType
			PageType = mPageType
			End property
			Public Property let PageType(newValue)
			mPageType = newValue
			If newValue <> "script" And newValue <> "database" Then
				mPageType  = "script"
				Response.write "ListView的dataType属性赋值异常,不识别参数[" & newValue & "],已强制性转为[script];"
			end if
			End property
			public function getuploader
				set getuploader = new lvwUploaderClass
			end function
			Public Sub  Class_Initialize
				dim nv
				centercols = "人|部门|小组|单位|职位|参与MRP|单号|操作|用户|类型|质检员|当前进度|状态|损耗率|查看|人数"
				set bill = nothing
				candr = false
				AutoIndex = True
				canexcel = True
				canGroup = True
				showheader = true
				CheckBox = True
				canAdd = True
				canSort = false
				autoSum = True
				canDelete = false
				dbCheckBox = False
				sqlfiltermodel = false
				showpsbox = True
				DisHideAutoSum = true
				showAddButton = "-"
'DisHideAutoSum = true
				CommUICss = false
				Set cols = new collection
				showtool =  True
				nv = request.form("lvw_PageIndex")
				if len(nv) > 0 and isnumeric(nv) then
					PageIndex  = nv
					if pageindex < 1 then PageIndex = 1
				else
					PageIndex = 1
				end if
				nv = request.form("lvw_PageSize")
				if len(nv) > 0 and isnumeric(nv) then
					PageSize  = nv
					if PageSize  < 0 then PageSize = 15
				else
					PageSize = 15
				end if
				mPageType = "script"
				AutoRepeat= true
				delAlert= False
				canUpdate= true
				IsStateCallBack = false
				PageCount = 0
				LeftFixCount = 0
				border = 1
				FieldAttrButton = false
				AutoProductLink = False
				Set dbSum = New  ListSumData
				mRecordCount = -1
'Set dbSum = New  ListSumData
			end sub
			Private Sub Class_Terminate()
				on error resume next
				set cols =  nothing
				rs.close
				Err.clear
			end sub
			Public Function AddCol(colName)
				Dim newCol
				Set newCol = new ListViewHeader
				set newcol.bill = me.bill
				newcol.dtype = "text"
				newcol.ywname = colName
				newcol.dbname = colName
				newCol.edit =  0
				newCol.save = 0
				cols.add newCol
				Set AddCol = newCol
			end function
			Public Function GetHeadByName(name)
				Dim i
				name = lcase(name)
				For i = 1 To cols.count
					If LCase(cols.items(i).dbname) =  name Then
						Set GetHeadByName = cols.items(i)
						Exit Function
					end if
				next
				Set GetHeadByName = Nothing
			end function
			Private Function mGetCurrVColCount()
				Dim i
				GetCurrVColCount = 0
				For i = 1 To cols.count
					If cols.items(i).visible Then GetCurrVColCount = GetCurrVColCount + 1
'For i = 1 To cols.count
				next
			end function
			Private function GetVisibleCol
				Dim i , r , hs ,col
				hs = False
				For i = 1 To cols.count
					Set col =  cols.items(i)
					If col.visible > 0 Then
						If hs Then
							r = r & ";" & col.ywname
						else
							r = col.ywname
							hs = true
						end if
					end if
				next
				GetVisibleColl = r
			end function
			Private Sub LetVisibleCol(ByVal vNewValue)
				Dim i , c , noreplaceButton
				if cols.count =  0 Then
					App.showErr "运行时错误" , "<span class=c_g>设置ListView对象的VisibleCol属性时，需要先设置对应数据源。</span><span class=c_r>(注:即SQL属性)。</span><br>"
					call db_close : Response.end
				else
					If Len(vNewValue) = 0 Then vNewValue = cols.count
					If IsNumeric(vNewValue) Then
						vCols = ""
						II = 0
						For I = 1 To cols.count
							If Not cols.items(I).ColReplaceButton  Then
								vCols = vCols & "," & cols.items(I).dbname
							else
								If  II < vNewValue*1 Then
									vCols = vCols & "," &  cols.items(I).dbname
									II = II + 1
'vCols = vCols & "," &  cols.items(I).dbname
								end if
							end if
						next
						vNewValue = Replace("X#XX" & vCols,"X#XX,","")
					end if
					vNewValue = Replace(vNewValue,",",";")
					vNewValue = Split(vNewValue,";")
					For i = 1 To cols.count
						cols.items(i).visible = 0
					next
					noreplaceButton =  ( UBound(vNewValue) < (cols.count - 1))
					cols.items(i).visible = 0
					For i = 0 To UBound(vNewValue)
						Set col  = GetHeadByName(vNewValue(i))
						If Not col Is Nothing Then
							col.visible = 1
							If noreplaceButton  = False Then
								col.ColReplaceButton = False
							end if
						end if
					next
					For i = 1 To cols.count
						If cols.items(i).visible = 0  Then
							HideCols = HideCols & ";" & cols.items(i).ywname
						end if
					next
				end if
			end sub
			Public Property Get recordset()
			Set recordset = rs
			End Property
			Public Property Get sql()
			sql = msql
			End Property
			Public Property Let sql(ByVal vNewValue)
			Dim i
			msql = vNewValue
			If Len(CStr(me.handerror)) = 0 Then
				me.handerror = true
			end if
			on error resume next
			if len(me.tmpTableSql) > 0 then cn.execute me.tmpTableSql
			Set rs = server.CreateObject("adodb.recordset")
			If Len(filterText) > 0 Then
				rs.Filter = filterText
			end if
			On Error GoTo 0
			rs.CursorLocation = 3
			Dim rsql
			If LCase(TypeName(vNewValue))="command" Then
				If request("__msgid") = "sys_ListView_CreateExcel" Then
					If InStr(1,vNewValue, "@@istreemode", 1)>0 Then vNewValue =  Replace(vNewValue, "@@istreemode", "0")
					rsql = "set nocount on;set rowcount 255;" & vbcrlf & Replace(vNewValue, "&excelmode", "0") & vbcrlf & ";set rowcount 0;set nocount off"
				else
					rsql = "set nocount on;" & vbcrlf & Replace(vNewValue, "&excelmode", "0") & vbcrlf & ";set nocount off"
				end if
				msql = rs.Source
			else
				rsql = msql
				If InStr(1, msql, "&pagesize", 1) > 0 Then
					rs.Filter = ""
					IsDbPageSize = True
					rsql = Replace(rsql, "&pagesize", pagesize,1,-1,1)
'IsDbPageSize = True
					rsql = Replace(rsql, "&pageindex", pageindex,1,-1,1)
'IsDbPageSize = True
					sqlfiltermodel = (InStr(1, rsql,"&listfilter", 1) > 0)
					rsql = Replace(rsql, "&listfilter", "'" & Replace(filterText,"'","''") & "'",1,-1,1)
'sqlfiltermodel = (InStr(1, rsql,"&listfilter", 1) > 0)
					If Len(Me.callBackSortText) > 0 then
						rsql = Replace(rsql, "&listsort", "'" & Replace(Me.callBackSortText,"'","''") & "'",1,-1,1)
'If Len(Me.callBackSortText) > 0 then
					else
						rsql = Replace(rsql, "&listsort", "'" & Replace(Me.SortText,"'","''") & "'",1,-1,1)
'If Len(Me.callBackSortText) > 0 then
					end if
				else
					IsDbPageSize = False
				end if
				If request("__msgid") = "sys_ListView_CreateExcel" Then
					If InStr(1,rsql, "@@istreemode", 1)>0 Then rsql =  Replace(rsql, "@@istreemode", "0")
					rsql = "set nocount on;set rowcount 255; " & Replace(rsql, "&excelmode", "0") & ";set rowcount 0;set nocount off"
				else
					rsql = "set nocount on;" & App.SqlExtension(Replace(rsql, "&excelmode", "0")) & ";set nocount off"
				end if
			end if
			on error resume next
			Call rs.open(rsql,cn,1,3)
			If Abs(Err.number)  >0 Then
				If me.handerror = true then
					app.showerr "ListView属性无效。" , "属性名：sql<br><br>属性值：<span class=c_c>" & Replace(rsql,app.db.password,"********") & "</span></br><span class=c_r><br>SQL命令无效;[内部描述：" & Err.Description & "]</span>"
					call db_close : Response.end
				else
					msql = ""
				end if
				Exit Property
			end if
			Err.clear
			If IsDbPageSize = True Then
				For i =0  To rs.fields.count-1
'If IsDbPageSize = True Then
					If LCase(rs.fields(i).name & "") = "recordcount" Then
						mrecordcount = rs(i).value
					else
						dbSum.add rs.fields(i).name, rs(i).value
					end if
				next
				Set rs = rs.nextrecordset
			end if
			If rs.fields.count = 1 Then
				If Err.number =0 Then
					If rs.fields(0).name = "error" Then
						Response.clear
						Response.write rs.fields(0).value
						cn.close
						Response.end
					end if
				end if
			end if
			If Abs(Err.number)  >0 Then
				If me.handerror = true then
					app.showerr "ListView属性无效。" , "属性名：sql<br><br>属性值：<span class=c_c>" & Replace(rsql,app.db.password,"********") & "</span></br><span class=c_r><br>SQL命令无效导致其它错误;[内部描述：" & Err.Description & "]</span>"
					call db_close : Response.end
				else
					msql = ""
				end if
				Exit Property
			end if
			If Len(Me.callBackSortText) > 0 Then
				Me.SortText = Me.callBackSortText
			end if
			If Len(Me.SortText) > 0 And Err.number = 0 Then
				If  IsDbPageSize=False Then rs.sort = Me.SortText
				If Err.number <> 0 then
					Me.SortText = ""
					Me.callBackSortText = ""
					Err.clear
				end if
			end if
			nType = ""
			While rs.fields.count = 0 And i < 10000
				i = i + 1
'While rs.fields.count = 0 And i < 10000
				Set rs = rs.NextRecordset
				If abs(Err.number)>0 Then
					If me.handerror = true then
						app.showerr "ListView属性无效" , "属性名：sql<br><br>属性值：<span class=c_c>" & Replace(msql,app.db.password,"********") & "</span></br><span class=c_r><br>SQL命令无效;[内部描述：" & Err.Description & "]</span>"
						call db_close : Response.end
					else
						msql = ""
					end if
					Exit Property
				end if
			wend
			Call createColItemByRecord(rs)
			End Property
			Private  Sub createColItemByRecord(rs)
				Dim I , II , hs ,item , cmd , t
				Set cmd = new DBCommand
				For I = 0 To rs.fields.count -1
'Set cmd = new DBCommand
					hs = false
					For ii = 1 To Cols.count
						Set item = cols.items(ii)
						If item.dbname = rs.fields(i).name Then
							hs = True
							ii = Cols.count
							If item.selId = 0 Then
								Select Case item.dtype
								Case "bit" : item.selId = 10001
								Case "date": item.selId = 10002
								Case "time": item.selId = 10003
								End select
							end if
						end if
					next
					If Not hs then
						Set item = new ListViewHeader
						set item.bill = me.bill
						item.ywname = Trim(rs.fields(I).name)
						item.dbname = Trim(rs.fields(I).name)
						item.dtype = cmd.gettypebyid(rs.fields(i).type)
						If item.dtype = "int" Then
							item.ltype = "int"
							item.dtype = "number"
						else
							item.ltype = ""
						end if
						item.maxsize =  rs.fields(i).DefinedSize
						if  rs.fields(i).Name="辅助数量" then item.maxsize=25
						t = rs.fields(i).type
						if  t = 203 or t = 201 then
							item.cangroup = 0
							item.cansort = 0
							item.searchtype = 0
						else
							item.cangroup = 1
							item.cansort = 1
							item.searchtype = 1
						end if
						item.Isint = abs(t = 3)
						If item.selId = 0 Then
							Select Case item.dtype
							Case "bit" : item.selId = 10001
							Case "date": item.selId = 10002
							End select
						end if
						cols.add(item)
					end if
				next
			end sub
			Private Sub InitCellCookieWidth()
				Dim f , k , headtext , i ,ii , cwidth , uLen , ind
				f = Request.ServerVariables("SCRIPT_NAME") & ""
				f = Replace(Replace(Replace(LCase(f),".asp",""),"/","x#"),".","d#")
				For i = 1 To cols.count
					Set c = cols.items(i)
					If c.resize > 0 and c.visible > 0  Then
						headtext = headtext & c.ywname
					end if
				next
				If Len(headtext) > 10 Then
					headtext = "LvwColWidth_" &  f & Mid(headtext,6,5) & Len(headtext)
				else
					headtext = "LvwColWidth_" & f & headtext
				end if
				headtext = Replace(headtext," ","")
				headtext = request.cookies(headtext) & ""
				If Len(headtext) > 0 Then
					cwidth = Split(headtext,"|")
					ii = 0
					uLen = UBound(cwidth)
					For i = 1-abs(me.CheckBox) To cols.count - abs(me.CheckBox)
'uLen = UBound(cwidth)
						ind = i*1 + abs(me.CheckBox)
'uLen = UBound(cwidth)
						Set c = cols.items(ind)
						If  c.visible And ii<=uLen  Then
							If IsNumeric(cwidth(ii)) then
								if isnumeric(c.cookiewidth) and len(c.cookiewidth) >0 then
									if c.cookiewidth < 0 then
										c.cookiewidth = "width:" & abs(c.cookiewidth) & "px;"
									else
										c.cookiewidth = "width:" & abs((cwidth(ii)-2)) & "px;"
										c.cookiewidth = "width:" & abs(c.cookiewidth) & "px;"
									end if
								else
									c.cookiewidth = "width:" & abs((cwidth(ii)-2)) & "px;"
									c.cookiewidth = "width:" & abs(c.cookiewidth) & "px;"
								end if
							end if
							ii = ii + 1
							c.cookiewidth = "width:" & abs(c.cookiewidth) & "px;"
						end if
					next
				end if
			end sub
			Private Function GetDefWidth()
				Dim i , w
				GetDefWidth = 0
				For i = 1 To cols.count
					Set c = cols.items(i)
					If c.visible then
						If Len(c.cookiewidth) > 0 Then
							w = Replace(Replace(c.cookiewidth,"width:",""),"px;","")
							GetDefWidth = GetDefWidth + w*1
'w = Replace(Replace(c.cookiewidth,"width:",""),"px;","")
						else
							GetDefWidth = GetDefWidth*1 + 100
							w = Replace(Replace(c.cookiewidth,"width:",""),"px;","")
							c.cookiewidth = "100px"
						end if
					end if
				next
			end function
			private function CreateToolBar()
				Dim buttons(6) , lmp , i ,item , ptype
				Dim pages
				ptype = LCase(me.pagetype)="database"
				buttons(0)  = "数据列呈现属性设置|../../images/smico/attrib.gif|colattr|" &  app.iif(me.FieldAttrButton,"1","0") & "|列设置"
				buttons(1)  = "整体输入|../../images/smico/gzjh.gif|ztlr|" & app.iif( ptype,"0","1") & "|整体录入"
				buttons(2)  = "快速查找|../../images/smico/find.gif|find|" & app.iif( ptype,"0","1") & "|查找"
				buttons(3)  = "数据筛选|../../images/smico/filter.gif|filter|" & app.iif(ptype,"1","0") & "|高级检索"
				buttons(4)  = "统计图示|../../images/smico/41.gif|grouppic|" & abs(me.cangroup And (InStr(Request.ServerVariables("HTTP_USER_AGENT"),"MSIE")>0 Or InStr(Request.ServerVariables("HTTP_USER_AGENT"),"rv:11.")>0)) & "|统计"
				buttons(5)  = "导出表格(Excel)|../../images/smico/excel.gif|excel|" & abs(me.canexcel) & "|导出" '修改 "导出表格(Excel)" 文字 需要同步修该checkpage.asp 中 该部分文字
				buttons(6)  = "导入表格(Excel)|../../images/smico/inexcel.gif|drexcel|" & abs(me.candr) & "|导入"
				For i = 0 To UBound (buttons)
					item = split(buttons(i),"|")
					If item(3) = "1" Then
						If CommUICss Then
							Dim bntw
							Dim chrLen : ChrLen = len(item(4))
							If chrLen <=2 Then
								bntw = "45px"
							ElseIf chrLen <=3 Then
								bntw = "50px"
							else
								bntw = ""
							end if
							lmp = lmp & "<td><button style='width:" & bntw & ";' class='button' onclick=""this.blur();lvw.toolbarclick(" & i & ",'" & item(2) & "')"" onmouseover='lvw.toolbarmove(this)' onmouseout='lvw.toolbarout(this)' title='" &  item(0) & "'>" &  item(4) & "</button>&nbsp;</td>"
						else
							lmp = lmp & "<td><button title='" &  item(0) & "' onclick=""this.blur();lvw.toolbarclick(" & i & ",'" & item(2) & "')"" onmouseover='lvw.toolbarmove(this)' onmouseout='lvw.toolbarout(this)'><img src='" & item(1) & "'></button></td>"
						end if
					end if
				next
				If CommUICss Then
					pages = Split("10;20;30;50;100;200",";")
					lmp = lmp & "<td><select class='resetTextColor666' style='font-weight:bold;color:#2f496e;' onchange='lvw.dbPageSizeChange(this)' id='" & me.id & "_psize'><option value=''>-请选择-</option>"
'pages = Split("10;20;30;50;100;200",";")
					For i = 0 To ubound(pages)
						If CStr(pagesize) = CStr(pages(i)) Then
							lmp = lmp & "<option value='" & pages(i) & "' selected >每页显示" & pages(i) & "条</option>"
						else
							lmp = lmp & "<option value='" & pages(i) & "'>每页显示" & pages(i) & "条</option>"
						end if
					next
					lmp = lmp & "</select></td><td>&nbsp;</td>"
				end if
				CreateToolBar = "<div style='float:left;height:" & app.iif(CommUICss,"26", "20") & "px;overflow:hidden'>" & leftTopHTML & "</div><table align=right" & app.iif( CommUICss, " style='height:100%'" ," class='lvwtoolbartable'") & "><tr>" & lmp & "</tr></table>"
			end function
			Private Function GetCurrPgaeState()
				Dim state
				If Len(filterText) > 0 Then state = state & "if len(request.Form(""filterText""))=0 then l.filterText=""" & Replace(me.filterText,"""","""""") & """"  & vbcrlf
				if len(me.tmpTableSql) > 0 then
					state = "l.tmpTableSql=""" & Replace(Replace(Replace(Replace(me.tmpTableSql,"""",""""""),vbcrlf , " "),vbcr," "),vblf," ") & """" & vbcrlf
				end if
				If PageSize <> 15 then state = state & "if len(request.Form(""PageSize""))=0 then l.PageSize =" & me.Pagesize & vbcrlf
				If Len(SortText) > 0 Then state = state & "l.SortText=""" & Replace(me.SortText,"""","""""") & """"  & vbcrlf
				state = state  & "l.sql=""" & Replace(Replace(Replace(Replace(me.sql,"""",""""""),vbcrlf , " "),vbcr," "),vblf," ") & """" & vbcrlf
				If Not canAdd  Then state = state & "l.canadd =" & CStr(me.canadd) & vbcrlf
				If Not AutoIndex  Then state = state & "l.autoIndex=" &  me.autoindex & vbcrlf
				If PageType <> "script" then state = state & "l.PageType=""" &  me.pagetype & """" & vbcrlf
				If Not CheckBox Then state = state & "l.checkBox=" & me.checkbox  & vbcrlf
				If dbCheckBox Then state = state & "l.dbcheckBox=true" & vbcrlf
				If Me.Formula <> "" Then state = state & "l.Formula=""" & Replace(me.Formula,"""","""""") & """" & vbcrlf
				state = state & "l.AutoRepeat=" & me.AutoRepeat  & vbcrlf
				state = state &  "l.id=""" &  me.id & """" & vbcrlf
				If Not autoSum Then state = state & "l.autoSum=" & me.Autosum  & vbcrlf
				If Not DisHideAutoSum Then  state = state & "l.DisHideAutoSum=false" & vbcrlf
				if not showheader then state = state & "l.showheader =" & me.showheader  & vbcrlf
				if not showpsbox then state = state & "l.showpsbox =" & me.showpsbox  & vbcrlf
				If Len(id)>0 Then state = state & "l.id =""" & me.id & """"  & vbcrlf
				If showAddButton<> abs(Clng(canadd)) Then  state = state & "l.showAddButton=" & me.showAddButton  & vbcrlf
				If canDelete Then state = state & "l.canDelete=" & me.canDelete & vbcrlf
				If delAlert Then state = state & "l.delAlert=" & me.delAlert  & vbcrlf
				If Not canUpdate Then state = state & "l.canUpdate=" & me.canUpdate  & vbcrlf
				If Me.CommUICss Then  state = state & "l.CommUICss=true"  & vbcrlf
				If Len(Me.lbBarHTML) Then state = state & "l.lbBarHTML=""" & Replace(me.lbBarHTML,"""","""""") & """"  & vbcrlf
				If Len(Me.nodataMsg) Then state = state & "l.nodataMsg=""" & Replace(me.nodataMsg,"""","""""") & """"  & vbcrlf
				If Me.canSort   Then state = state & "l.canSort=true" & vbcrlf
				If Not Me.canexcel  Then state = state & "l.canexcel=false" & vbcrlf
				If Len(width) > 0 Then state = state & "l.width=""" & me.width & """" & vbcrlf
				If Not showtool Then state = state & "l.showtool=" & me.showtool  & vbcrlf
				If Len(DataCol)> 0 Then state = state & "l.DataCol=""" & Replace(me.DataCol,"""","""""") & """" & vbcrlf
				If Len(VisibleCol) > 0 Then state = state & "l.VisibleCol=""" & Replace(me.VisibleCol,"""","""""") & """" & vbcrlf
				If Len(HeadBold) > 0 Then state = state & "l.HeadBold=""" & Replace(me.HeadBold,"""","""""") & """" & vbcrlf
				If border <> 1 Then state = state & "l.border=""" & Replace(CStr(me.border),"""","""""") & """" & vbcrlf
				If Me.xlsname <> "" Then state = state & "l.xlsname=""" & Replace(me.xlsname,"""","""""") & """" & vbcrlf
				If AutoProductLink <> False  Then  state = state & "l.AutoProductLink=true" & vbcrlf
				state = state & "l.FieldAttrSaveKey=""" & Replace(CStr(me.FieldAttrSaveKey),"""","""""") & """" & vbcrlf
				For i = 1 To cols.count
					Set nCol = me.cols.items(i)
					If cols.items(i).IsConst Then
						state = state & "set n=l.AddCol(""" & nCol.ywname &  """)" & vbcrlf
						state = state & "n.html=""" & Replace(ncol.html,"""","""""") & """" & vbcrlf
					else
						state = state & "set n = l.getCol(""" & nCol.dbname & """)" & vbcrlf
						If ncol.dbname <> ncol.ywname then state = state & "n.ywname = """ & Replace(ncol.ywname,"""","""""") & """" & vbcrlf
						state = state & "n.dtype=""" & Replace(ncol.dtype,"""","""""") & """" & vbcrlf
					end if
					If ncol.canExport = 0 Then state = state & "n.canExport = false" & vbcrlf
					If abs(ncol.htmlvisible) < 1 Then state = state & "n.htmlvisible = false" & vbcrlf
					If Len(ncol.syshide) = 0 then state = state & "n.syshide = ""bk""" & vbcrlf
					If abs(ncol.edit)  < 1 Then state = state & "n.edit=""" & Replace(ncol.edit,"""","""""") & """" & vbcrlf
					If abs(ncol.resize) < 1 Then state = state & "n.resize = 0" & vbcrlf
					If abs(ncol.isint) = 1 Then state = state & "n.isint = 1" & vbcrlf
					If abs(ncol.save) < 1   Then state = state & "n.save=""" & Replace(CStr(abs(ncol.save)),"""","""""") & """" & vbcrlf
					If ncol.bgcolor <>""   Then state = state & "n.bgcolor=""" & Replace(ncol.bgcolor,"""","""""") & """" & vbcrlf
					If abs(ncol.disztlr) > 0   Then state = state & "n.disztlr=1" & vbcrlf
					If len(ncol.cookiewidth) >0  Then state = state & "n.cookiewidth=""" & Replace(CStr(ncol.cookiewidth),"""","""""") & """" & vbcrlf
					If Not ncol.ColReplaceButton Then state = state & "n.ColReplaceButton="  & ncol.ColReplaceButton  & vbcrlf
					if len(ncol.swpattr) > 0 then state = state & "n.swpattr=""" & Replace(CStr(ncol.swpattr),"""","""""") & """" & vbcrlf
					if len(ncol.lockformat) > 0 then state = state & "n.lockformat=""" & Replace(CStr(ncol.lockformat),"""","""""") & """" & vbcrlf
					If ncol.selid > 0 Then state = state & "n.selid=""" & Replace(ncol.selid,"""","""""") & """" & vbcrlf
				next
				state = Replace(state,"set n = l.getCol(""","#t1")
				state = Replace(state,"set n=l.AddCol(""","#t2")
				state = Replace(state,"n.dtype=""text""","#t3")
				state = Replace(state,"n.dtype=""number""","#t4")
				state = Replace(state,"n.dtype=""date""","#t5")
				state = Replace(state,"l.VisibleCol=""","#t6")
				state = Replace(state,"l.FieldAttrSaveKey=""","#t7")
				state = Replace(state,"{us999999}","#t8")
				state = Replace(state,"n.ywname = ""","#t9")
				state = Replace(state,"n.ColReplaceButton=","#tA")
				state = Replace(state,"n.syshide = ""","#tB")
				state = Replace(state,"l.canUpdate=","#tC")
				state = Replace(state,"[nVarChar](","#tD")
				state = Replace(state,"  [dateTime]  NULL","#tE")
				state = Replace(state,"  [money]  NULL","#tF")
				state = Replace(state,"  [int]  NULL","#tG")
				state = Replace(state,"n.save=""","#tH")
				state = Replace(state,"n.edit=""","#tI")
				state = Replace(state,"n.selid=""","#tJ")
				state = Replace(state,"  NULL","#tK")
				state = Replace(state,"n.cookiewidth=""","#tN")
				state = app.base64.encode(state)
				state = Replace(state,"UyMiUwRCUwQSUyM3R","#tL")
				GetCurrPgaeState = Replace(state,"BBJTIzd","#tM")
			end function
			Public Function getCol(ywname)
				Dim i
				For i = 1 To cols.count
					If cols.items(i).ywname = ywname Then
						Set getcol = cols.items(i)
						Exit function
					end if
				next
				Set getcol = nothing
			end function
			Public Sub InitUserDefColMessage
				Dim ikey , vs
				ikey = me.FieldAttrSaveKey
				If Len(ikey) = 0 Then
					vs = Split(Request.ServerVariables("url") & "_" & me.id ,"/")
					ikey = vs(UBound(vs))
				end if
				me.FieldAttrSaveKey = Replace(Replace(Replace(ikey,vbcr,""),vblf,""),"""","")
			end sub
			Private Sub SortColsByVisibleSetting
				Dim vc ,cs ,i ,nc
				If Len(visibleCol) > 0 And Not IsNumeric(visiblecol) Then
					cs = Split(visiblecol,",")
					For i = 0 To UBound(cs)
						For ii = 1 To cols.count
							If cols.items(ii).dbname = cs(i) Then
								cols.items(ii).sortindex = i+1
'If cols.items(ii).dbname = cs(i) Then
							end if
						next
					next
					For i = 1 To cols.count-1
'If cols.items(ii).dbname = cs(i) Then
						hs = False
						For ii = 1 To cols.count-1
'hs = False
							r = (cols.items(ii).sortindex - cols.items(ii+1).sortindex )
'hs = False
							If r > 0 Then
								Set nc = cols.items(ii+1)
'If r > 0 Then
								Set cols.items(ii+1) = cols.items(ii)
'If r > 0 Then
								Set cols.items(ii) = nc
								hs = true
							end if
						next
						If Not hs Then
							Exit for
						end if
					next
				end if
			end sub
			Private Sub SetFilter(rs , filterText)
				on error resume next
				rs.Filter = filterText
				If abs(Err.number) > 0 then
					app.showerr "设置过滤条件失败" , "ListView无法设置过滤条件,请确认数据字段都有名称。"
					call db_close : Response.end
				end if
			end sub
			private function autoCenter(fname)
				dim items , i
				items = split(centercols,"|")
				for i = 0 to ubound(items)
					if instr(fname,items(i)) > 0 then
						autoCenter = true
						exit function
					end if
				next
				autoCenter = false
			end function
			Private function AddHtml(ByRef htmlarray, ByVal html)
				Dim c : c = ubound(htmlarray)+1
'Private function AddHtml(ByRef htmlarray, ByVal html)
				ReDim Preserve htmlarray(c)
				htmlarray(c) = html
				AddHtml = c
			end function
			Public Function InnerHTML
				Dim html , showfedt , colCount , vCol , mMaxColCount , startIndex , endIndex ,rowData ,offsetc
				Dim i, ii ,index , c , v , selHTML ,edtCss ,nullRowHtml ,haseditcol ,item , deffArray
				Dim tmname , dbCheckboxHTML , treeMode
				treeMode = false
				runtimemaxdeep = 0
				If Len(Me.callBackSortText) > 0 Then
					Me.SortText = Me.callBackSortText
				end if
				If PageType = "database" Then
					canadd = false
					canupdate = False
					candelete = False
					checkbox = false
					For i = 1 To cols.count
						Set item = cols.items(i)
						item.edit = 0
					next
				end if
				For i = 1 To cols.count
					Set item = cols.items(i)
					If InStr(item.ywname,"{us")=1 And InStr(item.ywname,"}") > 0 Then
						item.oldywname = item.ywname
						deffArray = Split(item.ywname,"}")
						item.ywname = deffArray(UBound(deffArray))
					else
						If Len(item.oldywname) = 0 Then item.oldywname = item.ywname
					end if
					if lcase(item.ywname) = "lvw_treenodedeep" then
						treeMode  =  true
						item.edit = False
						pagesize = 10000
					end if
				next
				If Len(filterText) > 0 And Me.sqlfiltermodel = False Then
					SetFilter rs,filterText
				end if
				Call LetVisibleCol(VisibleCol)
				Call SortColsByVisibleSetting ()
				mMaxColCount  = 0
				hasEditcol = false
				ReDim vCol(0)
				Dim hasbgcolorset : hasbgcolorset = false
				For i = 1 To cols.count
					set c = cols.items(i)
					If c.bgcolor <> "" Then  hasbgcolorset = true
					if len(c.align) = 0 then
						if c.dtype = "bit" or c.dtype = "date" then
							c.align = "center"
						else
							if c.dtype <> "number" or len(c.selid) > 0 then
								if autoCenter(c.ywname)  then c.align = "center"
							end if
						end if
					end if
					if len(c.align) > 0 then c.align = " " & c.align
					If cols.items(i).visible = 1 Then
						mMaxColCount = mMaxColCount + 1
'If cols.items(i).visible = 1 Then
						ReDim preserve vCol(mMaxColCount)
						Set vCol(mMaxColCount) = cols.items(i)
					end if
					If abs(cols.items(i).edit) = 1 Then
						hasEditcol = true
					end if
					tmname = cols.items(i).dbname
					cols.items(i).AutoProductLink = 0
					if me.AutoProductLink then
						set rspower=cn.execute("select isnull(qx_open,0) from power where ord="&app.info.user&" and sort1=21 and sort2=14")
						if rspower.eof then
							me.AutoProductLink=false
						else
							if Clng(rspower(0).value) <> 1  then me.AutoProductLink=false
						end if
					end if
					if me.AutoProductLink and (tmname="物品编码" or tmname = "产品名称"  or tmname = "物品名称" or tmname = "物料名称" or tmname = "品名" or tmname = "名称" or tmname = "用料名称") then
						if i > 1 then
							tmname = cols.items(i-1).dbname
'if i > 1 then
							if UCase(tmname) = "产品ID" or UCase(tmname) = "原料ID" or tmname = "物品ID" or tmname = "物料ID" or tmname = "ord" then
								cols.items(i).AutoProductLink = -1
							end if
						end if
						if abs(cols.items(i).AutoProductLink) = 0 then
							if i > 2 then
								tmname = cols.items(i-2).dbname
'if i > 2 then
								if UCase(tmname) = "产品ID" or UCase(tmname) = "原料ID" or tmname = "物品ID" or tmname = "物料ID" or tmname = "ord" then
									cols.items(i).AutoProductLink = -2
								end if
							end if
						end if
						if abs(cols.items(i).AutoProductLink) = 0 then
							if i < cols.count then
								tmname = cols.items(i+1).dbname
'if i < cols.count then
								if UCase(tmname) = "产品ID" or tmname = "物品ID" or tmname = "物料ID" or tmname="ID" or tmname="ord" or tmname="ProductID" then
									cols.items(i).AutoProductLink = 1
								end if
							end if
						end if
						if abs(cols.items(i).AutoProductLink) = 0 then
							if i < cols.count - 1 then
'if abs(cols.items(i).AutoProductLink) = 0 then
								tmname = cols.items(i+2).dbname
'if abs(cols.items(i).AutoProductLink) = 0 then
								if UCase(tmname) = "产品ID" or tmname = "物品ID" or tmname = "物料ID" or tmname="ID" or tmname="ord" or tmname="ProductID" then
									cols.items(i).AutoProductLink = 2
								end if
							end if
						end if
					else
					end if
				next
				If hasEditcol = false Then
					checkbox = false
				end if
				Call InitCellCookieWidth()
				Call InitUserDefColMessage()
				colCount = mMaxColCount
				If Len(id)=0 Then
					Randomize
					id = "lvw" & Clng(rnd*1000)
				end if
				If instr(me.FieldAttrSaveKey, "_" & me.pagetype) = 0 then
					me.FieldAttrSaveKey = me.FieldAttrSaveKey & "_" & me.pagetype
				end if
				Call LoadUserDefColAttr
				me.Formula = Replace(Replace(Replace(me.Formula & "","""","$“"),"'","$‘"),vbcrlf,"")
				if pagetype = "database" and dbcheckbox then
					if autoindex then
						dbcheckBoxHTML = "<span class='dbcheck'><input type=checkbox onclick=""lvw.dbcheck(this,'" & id & "')""></span><span class=dbcheckboxindex>"
					else
						dbcheckBoxHTML = "<span><input type=checkbox onclick=""lvw.dbcheck(this,'" & id & "')""></span><span>"
					end if
				end if
				showfedt = 0
				Dim htmls
				ReDim htmls(0)
				htmls(0) = "<table  class='listviewframe lvwborder" & Abs(me.border) & "' style='border-width:" & me.border & "px'>"
'ReDim htmls(0)
				If showtool Then
					AddHtml htmls,"<tr><td colspan=2 id='listtoolbar_" & id & "'style='margin-bottom:0px;border-bottom:0px;height:" & app.iif(CommUICss,"30","24") & "px' class='ctl_listview ctl_listviewbgtable ctl_lvwadddiv'>" & CreateToolBar() & "</td></tr>"
'If showtool Then
				end if
				Dim stateIndex
				stateIndex = AddHtml(htmls , "<tr><td rowspan=2 id='ctl_llvwframe_" & id & "' style='padding:0px'><div id='listview_" & id & "' sqlfiltermodel='" & Abs(Me.sqlfiltermodel) & "'  treemode=" & abs(treemode) & " FieldAttrSaveKey='" & me.FieldAttrSaveKey & "' class='ctl_listview' state="""" delalert='"& abs(Int(delAlert)) & "'  autosum='" & abs(Int(autoSum)) & "' autoindex='" & abs(Int(autoindex)) & "' bgcolorExp='" & Abs(hasbgcolorset) & "' candel='" & abs(Int(canDelete)) & "' checkbox='" & abs(Int(CheckBox)) & "' PageSize='" & PageSize & "' PageType='" & PageType & "' centercols='" & centercols & "'><table LeftFixCount=" & LeftFixCount & " canadd='" & abs(Clng(canAdd)) & "'  class='full lvwcss' onmousedown = 'lvw.mousedown(this)' style='table-layout:fixed;' hideCol=""" & HideCols & """ ")
'Dim stateIndex
				If mPageType="script" then
					AddHtml htmls," onmousewheel='lvw.mousewheel(this)' formula=""" & me.Formula & """>"
				end if
				AddHtml htmls,"<tr" & app.iif(showheader,""," style='display:none'") & ">"
				commUICssckbox = false
				If AutoIndex Then
					if len(dbcheckBoxHTML) > 0 then
						AddHtml htmls, "<th class=lvc style='width:47px;padding-right:2px;overflow:hidden'><input type=checkbox style='height:15px;' onclick=""lvw.dbcheckall(this.checked,'" & id & "')"" title='全选'>序号</th>"
'if len(dbcheckBoxHTML) > 0 then
					else
						AddHtml htmls, "<th class=lvc style='width:40px;padding-right:2px;overflow:hidden'>序号</th>"
'if len(dbcheckBoxHTML) > 0 then
					end if
				else
					if len(dbcheckBoxHTML) > 0 Then
						If Not CommUICss then
							AddHtml htmls, "<th class=lvc style='width:47px;padding-right:2px;overflow:hidden'><input type=checkbox onclick=""lvw.dbcheckall(this.checked,'" & id & "')"" style='height:15px' title='全选'>&nbsp;&nbsp;&nbsp;&nbsp;</th>"
'If Not CommUICss then
						else
							AddHtml htmls, "<th class=lvc style='width:47px;text-align:center;padding-right:2px;overflow:hidden'>选择</th>"
'If Not CommUICss then
							commUICssckbox = true
						end if
					end if
				end if
				If CheckBox Then
					If Not CommUICss then
						AddHtml htmls, "<th  class='lvc' style='width:28px' nowrap><span style='display:none'>选择</span><button class=lvwReplaceCol onclick='lvw.ShowReplaceColList(this)' title='全选或取消全选' ></button></th>"
					else
						AddHtml htmls, "<th  class='lvc' style='width:28px' nowrap><span>选择</span></th>"
					end if
				end if
				Dim tmph
				ReDim sums(colCount)
				Dim colindexs
				ReDim colindexs(colCount)
				For i = 1 To colCount
					Set c = vCol(i)
					If Abs(c.htmlvisible)=0 Then c.resize= 0
					tmph = c.ywname
					If Len(c.udefname) > 0 Then tmph = c.udefname
					If IsNumeric(c.cookiewidth) Then c.cookiewidth = "width:" & abs(c.cookiewidth) & "px"
					Select Case c.dbname
					Case "操作" :  c.cansort = 0
					Case "下级关联单": c.cansort = 0
					End Select
					If canSort  And c.cansort Then
						Dim sortTypeV
						If Me.SortText = "[" + c.dbname + "]" Then
'Dim sortTypeV
							tmph = "↑" & tmph
							sortTypeV = 0
						elseIf Me.SortText = "[" + c.dbname + "] desc" Then
							sortTypeV = 0
							tmph = "↓" & tmph
							sortTypeV = 1
						else
							sortTypeV = 1
						end if
						colindexs(i) = AddHtml(htmls,("<th @ishtmlV int=" & c.isint & " lockExp=""" & c.lockformat & """ bgcolorExp=""" &c.BgColor& """ maxsize='" & c.maxsize & "' dbname=""" & c.dbname & """ disztlr=""" & c.disztlr  & """ sboxArray=""" & c.GetSelectBoxArrayText() & """ onmousemove='lvw.HeaderMouseMove(this)' onmousedown='lvw.HeaderMouseDown(this)' onmouseup='lvw.HeaderMouseUp(this)' ltype='" & c.ltype & "' notnull='"  & abs(c.notnull) & "' edit='" & c.Edit & "' resize='" & abs(Clng(c.resize)) & "' style='" & c.cookiewidth & ";" & app.iif(len(c.htmldisplay)>0,"display:none","") & "' save='" & abs(Clng(c.save)) & "' dtype='" & c.dType & "' class=lvc selid='" & c.selid & "' csrc='" & c.searchtype & "' cangroup='" & c.cangroup & "' oywname = '" & c.oldywname & "' syshide='" & c.syshide & "'><span onmouseover='Bill.showunderline(this,""#000"")'  onmouseout='Bill.hideunderline(this,""#000"")'  onclick='lvw.ColDataSort(this," & sortTypeV & ")' udefname='" & c.udefname & "' title='点击排序' htmlvisible='" & c.htmlvisible & "'>" & tmph & "</span>"))
					else
						colindexs(i) = AddHtml(htmls,("<th @ishtmlV int=" & c.isint & " lockExp=""" & c.lockformat & """ bgcolorExp=""" &c.BgColor& """ maxsize='" & c.maxsize & "' dbname=""" & c.dbname & """ disztlr=""" & c.disztlr  & """ sboxArray=""" & c.GetSelectBoxArrayText() & """ onmousemove='lvw.HeaderMouseMove(this)' selectbox onmousedown='lvw.HeaderMouseDown(this)' onmouseup='lvw.HeaderMouseUp(this)' ltype='" & c.ltype & "' onmousemove=''  resize='" & abs(Clng(c.resize)) & "' style='" & c.cookiewidth & ";" & app.iif(len(c.htmldisplay)>0,"display:none","") & "' notnull='"  & abs(c.notnull) & "' class=lvc edit='" & c.Edit & "' save='" & abs(Clng(c.save)) & "' dtype='" & c.dType & "' csrc='" & c.searchtype & "' cangroup='" & c.cangroup & "' selid='" & c.selid & "' oywname = '" & c.oldywname & "' syshide='" & c.syshide & "' udefname='" & c.udefname & "' htmlvisible='" & c.htmlvisible & "'>" & tmph))
					end if
					If c.ColReplaceButton Then
						AddHtml htmls,"&nbsp;<button class=lvwReplaceCol onclick='lvw.ShowReplaceColList(this)' title='选择其他隐藏列'></button>"
					end if
					AddHtml htmls,"</th>"
				next
				If canDelete Then AddHtml htmls,"<th class=lvc style='width:40px'>&nbsp;</th>"
				AddHtml htmls,"</tr>"
				index = 0
				dat = ""
				For i = 1 To colCount
					Set c = vCol(i)
					dat = dat & "<br>" & c.dbname & ".disztlr=" & c.disztlr
				next
				endIndex = 10000000
				If isnumeric(pageindex) = False Then pageindex = 1
				If pageindex*1<1 Then pageindex = 1
				If Len(pageindex & "") > 8 Then pageindex =1
				If PageType = "database" and  PageSize > 0 Then
					If IsDbPageSize = False then
						rs.PageSize = PageSize
						PageCount = int(Recordcount \ PageSize) + abs(Recordcount mod pagesize > 0)
'rs.PageSize = PageSize
						if Clng(pageindex) > PageCount then pageindex = PageCount
						index = PageSize * (PageIndex-1)
'if Clng(pageindex) > PageCount then pageindex = PageCount
						If PageIndex > 0 Then
							If Not rs.eof then
								rs.absolutePage = PageIndex
							end if
						end if
					else
						PageCount =  int(Recordcount \ PageSize) + abs(Recordcount mod pagesize > 0)
						rs.absolutePage = PageIndex
					end if
				else
					PageCount = 1
					PageIndex  = 1
				end if
				startIndex = (PageIndex - 1) * PageSize
				PageIndex  = 1
				endIndex = PageSize * PageIndex
				Dim IsonCellValueWrite : IsonCellValueWrite = app.isSub("App_OnCellValueWrite")
				Dim onCellExtraValue : onCellExtraValue = app.isSub("App_onCellExtraValue")
				dim tnodecss
				if len( dbcheckBoxHTML ) = 0 then  dbcheckBoxHTML = "<span>"
				While (not rs.eof) And (index < endIndex) And Response.IsClientConnected
					index = index + 1
'While (not rs.eof) And (index < endIndex) And Response.IsClientConnected
					AddHtml htmls, "<tr onmouseout='lvw.RowMouseOut(this)' onmouseover='lvw.RowMouseOver(this)'>"
					If AutoIndex Then
						AddHtml htmls, ("<td class=lvx>" & dbcheckBoxHTML & index & "</span></td>")
					elseif len(dbcheckBoxHTML) > 7 then
						AddHtml htmls, ("<td class=lvx>" & dbcheckBoxHTML & "</span></td>")
					end if
					If checkbox  Then AddHtml htmls, "<td class='lvc checkboxcell'><span><input type=checkbox onclick='lvw.setcheckvalue(this)'></span></td>"
					rowData = ""
					For i = 1 To colCount
						Set c = vCol(i)
						on error resume next
						If c.isConst Then
							v = c.html
						else
							v = rs.fields(c.dbname).value & ""
						end if
						on error goto 0
						if treemode and i = 1 then
							v = replace(getTreeMap(rs,html),"***",  v)
						end if
						If c.selID > 0  and pagetype <> "database"  Then
							selHTML = "<button class=smselButton KeySelectBox='" & lcase(c.KeySelectBox & "") & "' selid='" & c.selID & "' onfocus='this.blur()' onclick='lvw.focusEditCell(this);if(!lvw.IsLockRow(this)){lvw.focusSelButton();menu.showbtnlist(this,null," & app.iif(i>1,1,0) & ",event)}else{alert(""该单元格数据已经锁定，无法进行修改。"");}'><img src='../../images/11645.png'></button>"
						else
							selHTML = ""
						end if
						edtCss = "edt" & c.edit
						If c.edit = 1 And showfedt = 0 Then
							edtCss = "edtfocus"
							showfedt = 1
						end if
						tnodecss = app.iif(treemode and i=1," tnode","")
						If c.dtype = "text"  then
							if abs(c.AutoProductLink)>0 then
								set offsetc =  vCol(i*1 + c.AutoProductLink*1)
'if abs(c.AutoProductLink)>0 then
								tmname = rs.fields(offsetc.dbname).value & ""
								rowData = rowData & ("<td class='lvc " & edtCss & c.align & tnodecss & "' " & c.htmldisplay & " Const=" & abs(c.isConst) & "><table class='" & edtCss  & "tb'><tr> <td class=full " & c.title(v) & " nowrap><a target=_blank href='../../product/content.asp?ord=" &  NumEnCode(tmname)  & "'>" & c.value(v) & "</a></td><td>" & selHTML & "</td></tr></table></td>")
							else
								set offsetc2 =  vCol(i*1 + c.AutoProductLink*1)
'lue(v) & "</a></td><td>" & selHTML & "</td></tr></table></td>")
								If offsetc2.dbname="审批意见" then
									rowData = rowData & ("<td class='lvcr " & edtCss & c.align & tnodecss & "' " & c.htmldisplay & " Const=" & abs(c.isConst) & "><table class='" & edtCss  & "tb'><tr><td class=full " & c.title(v) & ">")
								else
									rowData = rowData & ("<td class='lvc " & edtCss & c.align & tnodecss & "' " & c.htmldisplay & " Const=" & abs(c.isConst) & "><table class='" & edtCss  & "tb'><tr><td class=full2 " & c.title(v) & ">")
								end if
								dim vvxv : vvxv = c.Value(v)
								If pagetype = "database" Or c.selid=0 Or c.save=0 Then
									If InStr(vvxv, "^tag~") > 0 Then
										vvxv = Split(vvxv,"^tag~")(0)
									end if
								end if
								If IsonCellValueWrite Then Call App_OnCellValueWrite(me, c,  rs, vvxv)
								rowData = rowData & vvxv
								Dim ev : ev = ""
								If onCellExtraValue Then Call App_onCellExtraValue(me, c,  rs, ev)
								rowData = rowData & ev
								rowData = rowData & ("</td><td>" & selHTML & "</td></tr></table></td>")
							end if
						else
							If c.dtype = "bit" Then
								v = app.iif(v = "True" Or v="1",1,0)
							end if
							if len(c.align) = 0 then
								rowData = rowData & ("<td class='lvcr " & edtCss &  tnodecss & "'" & c.htmldisplay & " Const=" & abs(c.isConst) & "><table class='" & edtCss  & "tb'><tr><td class=full2 " & c.title(v) & " nowrap>" & c.value(v) & "</td><td>" & selHTML & "</td></tr></table></td>")
							else
								rowData = rowData & ("<td class='lvc " & edtCss & c.align &  tnodecss & "'" & c.htmldisplay & " Const=" & abs(c.isConst) & "><table class='" & edtCss  & "tb'><tr><td class=full " & c.title(v) & " nowrap>" & c.value(v) & "</td><td>" & selHTML & "</td></tr></table></td>")
							end if
							If autoSum And c.dtype = "number"  Then
								If IsNumeric(v) And c.dtype<> "bit" and len(c.GetSelectBoxArrayText())=0 then
									sums(i) = sums(i)*1 + v*1
'If IsNumeric(v) And c.dtype<> "bit" and len(c.GetSelectBoxArrayText())=0 then
								end if
							end if
						end if
					next
					AddHtml htmls,rowData
					If canDelete Then AddHtml htmls,"<td class='lvcc edt0' style='width:50px' Const=1 nowrap><span class='ctldelspan'  onmouseover='Bill.showunderline(this,""red"")' onmouseout='Bill.hideunderline(this,""#cc9999"")' onmousedown='lvw.deleteRow(this)'>删除</span></td>"
					AddHtml htmls,"</tr>"
					rs.movenext
				wend
				nullRowHtml = "<tr onmouseout='lvw.RowMouseOut(this)' onmouseover='lvw.RowMouseOver(this)' id='listviewnullrow_" & me.id & "'>"
				If AutoIndex Then nullRowHtml = nullRowHtml &  "<td class=lvx><span></span></td>"
				If CheckBox Then nullRowHtml = nullRowHtml &  "<td class='lvc checkboxcell' style='width:28px;'><span><input type=checkbox onclick='lvw.setcheckvalue(this)'></span></td>"
				For i = 1 To colCount
					Set c = vCol(i)
					htmls(colindexs(i)) = Replace(htmls(colindexs(i)), "@ishtmlV", " ishtmlV=" & c.isHtmlValue & " ",1,1,1)
					If c.visible = 1 Then
						v = app.iif(c.isConst,c.HTML,c.defaultValue)
						If c.selID > 0 and pagetype<>"database" Then
							selHTML = "<button class=smselButton KeySelectBox='" & lcase(c.KeySelectBox & "") & "' selid='" & c.selID & "' onfocus='this.blur()' onclick='lvw.focusEditCell(this);if(!lvw.IsLockRow(this)){lvw.focusSelButton();menu.showbtnlist(this,null," & app.iif(i>1,1,0) & ",event)}else{alert(""该单元格数据已经锁定，无法进行修改。"");}'><img src='../../images/11645.png'></button>"
						else
							selHTML = ""
						end if
						edtCss = "edt" & c.edit
						if autoCenter(c.ywname) And c.ltype<>"int"  then c.align = "center"
						If c.dtype = "text"  then
							nullRowHtml = nullRowHtml & ("<td class='lvc " & edtCss & " " & c.align & "' " & c.htmldisplay & " Const=" & abs(c.isConst) & "><table class='" & edtCss  & "tb'><tr><td class=full nowrap>" & v & "</td><td>" & selHTML & "</td></tr></table></td>")
						else
							If c.align = "center" Then
								edtCss = "lvc edt" & c.edit & " center"
							else
								edtCss = "lvcr edt" & c.edit
							end if
							nullRowHtml = nullRowHtml & ("<td class='" & edtCss & "' " & c.htmldisplay & "  Const=" & abs(c.isConst) & "><table class='" & edtCss  & "tb'><tr><td class=full nowrap>" & v & "</td><td>" & selHTML & "</td></tr></table></td>")
						end if
					end if
				next
				If canDelete Then nullRowHtml = nullRowHtml & "<td class='lvcc edt0' style='width:50px' Const=1><span class='ctldelspan'  onmouseover='Bill.showunderline(this,""red"")' onmouseout='Bill.hideunderline(this,""#cc9999"")' onmousedown='lvw.deleteRow(this)' nowrap>删除</span></td>"
				nullRowHtml = nullRowHtml & "</tr>"
				Dim htmldisplay, discount
				If autoSum Then
					If abs(dbcheckbox) > 0 Then
						sIndex = 1
					else
						sIndex = 2 - abs(checkbox) - abs(autoindex)
						sIndex = 1
					end if
					Dim hassum : hassum = false
					For I = sIndex To UBound(sums)
						If Len(sums(i)) > 0 Then
							If InStr(1,vCol(i).htmldisplay, "display:none",1)=0 then
								hassum = True
							end if
						end if
					next
					Dim hidsum,hidsum2, hidsum3
					If DisHideAutoSum=true Then
						hassum = True
					else
						hidsum  = "style='display:none'"
						hidsum2 = "display:none"
						hidsum3 = "style='display:inline'"
					end if
					AddHtml htmls,"<tr id='listviewsumRow_" & id & "' " & hidsum3 & " class='lvwautosum'  onmouseout='lvw.RowMouseOut(this)' onmouseover='lvw.RowMouseOver(this)'>"
					AddHtml htmls, "<td class=lvx " & hidsum & ">合计</td>"
					For I = sIndex To UBound(sums)
						htmldisplay = ""
						If i > 0 Then
							htmldisplay = vCol(i).htmldisplay
						end if
						If IsDbPageSize Then
							sums(i) = dbsum.getItem(vCol(i).dbname)
						end if
						If Len(sums(i)) > 0 Then
							If instr(vCol(i).ywname,"率")>0 Then
								AddHtml htmls, ("<td class='lvcr edt0' " & hidsum & " " & htmldisplay  & "></td>")
							ElseIf Right(vCol(i).ywname,1) = "价" Or Right(vCol(i).ywname,1) = "额" Or Right(vCol(i).ywname,2) = "成本" Or Right(vCol(i).ywname,2) = "工资" Then
								AddHtml htmls, ("<td class='lvcr edt0' " & hidsum & " " & htmldisplay  & ">" & Formatnumber(sums(i),app.info.moneyNumber,-1) & "</td>")
							ElseIf  Right(vCol(i).ywname,2) = "单位" Then
								AddHtml htmls, ("<td class='lvcr edt0' " & hidsum & " " & htmldisplay  & ">&nbsp;</td>")
							else
								AddHtml htmls, ("<td class='lvcr edt0' " & hidsum & " " & htmldisplay  & ">"  & Formatnumber(sums(i),app.info.floatNumber,-1) & "</td>")
								AddHtml htmls, ("<td class='lvcr edt0' " & hidsum & " " & htmldisplay  & ">&nbsp;</td>")
							end if
						else
							AddHtml htmls, ("<td class='lvcr edt0' " & hidsum & " " & htmldisplay  & ">&nbsp;</td>")
						end if
					next
					If canDelete Then AddHtml htmls,"<td class='lvcc edt0' style='width:50px;" & hidsum2 & "'>&nbsp;</td>"
					AddHtml htmls,"</tr>"
				end if
				If recordcount = 0 Then
					discount = 1
					For I = sIndex To UBound(sums)
						htmldisplay = ""
						If i > 0 Then
							htmldisplay = vCol(i).htmldisplay
						end if
						If InStr(htmldisplay, "none") = 0 Then
							discount = discount + 1
'If InStr(htmldisplay, "none") = 0 Then
						end if
					next
					If Len(Me.nodataMsg) > 0 then
						AddHtml htmls,"<tr><td class='lvc' style='color:#2f496e;border-top:0px' colspan='" & discount & "'><center>" & Me.nodataMsg & "</center></td></tr>"
'If Len(Me.nodataMsg) > 0 then
					end if
				end if
				AddHtml htmls,"</table>"
				If Not IsNumeric(showAddButton) Then
					showAddButton = abs(Clng(canAdd))
				else
					showAddButton = abs(Clng(showAddButton))
				end if
				Dim ShowPageBar
				ShowPageBar =  ((index  - recordcount <= 0) and  (PageCount>1)) And (PageType = "database" )
'Dim ShowPageBar
				If True  Then '(canAdd Or PageType = "database")  Then
					AddHtml htmls,("<div class='ctl_lvwadddiv' "  & app.iif(CommUICss, "style='height:33px;'", "") & "><table style='width:100%;margin-top:4px;margin-bottom:4px'><tr>")
'If True  Then '(canAdd Or PageType = "database")  Then
					
					AddHtml htmls,("<td align='left'> " & app.iif(canadd And showAddButton, "<table id='lvw_add_" & id & "_tb' style='margin-left:15px' onclick='lvw.addRow(this.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.children[0])'><tr><td><img class='resetElementHidden' src='../../images/jiantou.gif'><img class='resetElementShow' style='display:none;vertical-align:-3px;' width='14' height='14' src='../../skin/default/images/MoZihometop/content/lvw_addrow_btn.png'>" & _
					"</td><td class='ctl_lvwaddrowlk' onmousemove='Bill.showunderline(this)' onmouseout='Bill.hideunderline(this)' nowrap>添加新行</td></tr></table>,") & "</td>")
					Dim PageSizeConst
					PageSizeConst =  Split("10,15,20,25,30,35,40,50,60,80,100,150,200,300,500",",")
					pSizeOpt = ""
					pSizeLen = UBound(PageSizeConst)
					For i = 0 To pSizeLen
						PageSizeConst(i) = Clng(PageSizeConst(i))
						pagesize  = Clng(pagesize)
						on error resume next
						If i = 0 And pagesize < PageSizeConst(i) Then
							pSizeOpt  = pSizeOpt  & "<option value='" & pagesize & "' selected>" &  pagesize & "</option>"
						ElseIf i = pSizeLen And pagesize > PageSizeConst(i) Then
							pSizeOpt  = pSizeOpt  & "<option value='" & pagesize & "' selected>" &  pagesize & "</option>"
						Elseif i > 0 And i < pSizeOpt  then
							If pagesize > PageSizeConst(i-1) And pagesize < PageSizeConst(i) Then
'Elseif i > 0 And i < pSizeOpt  then
								pSizeOpt  = pSizeOpt  & "<option value='" & pagesize & "' selected>" &  pagesize & "</option>"
							end if
						end if
						pSizeOpt  = pSizeOpt  & "<option value='" & PageSizeConst(i) & "' " & app.iif(pagesize-PageSizeConst(i)=0,"selected","") & ">" & PageSizeConst(i) & "</option>"
						pSizeOpt  = pSizeOpt  & "<option value='" & pagesize & "' selected>" &  pagesize & "</option>"
					next
					Dim tmplbBarHTML
					tmplbBarHTML = lbBarHTML
					if app.issub("lvw_leftBottomBar") then
						tmplbBarHTML = lvw_leftBottomBar(id)
					end if
					If commUICssckbox = True Then
						tmplbBarHTML = "<table style='margin-left:30px;color:#2f496e;table-layout:auto;'><tr><td valign='bottom'>全选</td><td>&nbsp;<input valign='bottom' style='margin-top:5px' type='checkbox' onclick=""lvw.dbcheckall(this.checked,'" & id & "')""></td><td valign='bottom'>" & tmplbBarHTML & "</td></tr></table>"
					end if
					If  PageType = "database"  Then
						Dim mhtml
						mhtml = mhtml & "<td style='text-align:right;'><div style='float:left'>" & tmplbBarHTML & "</div><table align='right' class=PageItemBar style='" & app.iif(treemode,"display:none","") & "'><tr> "
'Dim mhtml
						If CommUICss Then
							mhtml = mhtml &  "<td style='font-family:arial;cursor:default;color:#2f496e;font-family:宋体' nowrap>共" & recordcount & "条 " & _
							"&nbsp; & pagesize & /页  & pageindex & / & pagecount & 页&nbsp;"
							mhtml = mhtml &  "<input type=text size=3  maxvalue='" & pagecount & "' onblur='_lvw_pageindex_maxnumcheck(this)' value=""" & PageIndex & """ id='" & me.id & "_pindex'>&nbsp;&nbsp;<button class='button' onclick='lvw.toPage(document.getElementById(""" & me.id & "_pindex""))'>跳转</button>&nbsp;<button class='button' onclick='lvw.firstPage(this)'>&nbsp;首页&nbsp;</button>" & _
							"&nbsp;<button class='button' onclick='lvw.prePage(this,true)'>上一页</button>&nbsp;<button class='button' tag='" & pagecount & "' onclick='lvw.nextPage(this, true)'>下一页</button>&nbsp;" & _
							"<button class='button'  tag='" & pagecount & "' onclick='lvw.lastPage(this, true)'>&nbsp;尾页&nbsp;</button>&nbsp;<input id='" & Me.id & "_psize' value='" & pagesize & "' type='hidden'></td>"
						else
							If ShowPageBar Then
								mhtml = mhtml & "<td style='float:left'><button title='首页' style='padding-left:0px;padding-top:0px;' class=lvwpagebutton onclick='lvw.firstPage(this)'><img src='../../images/firstpage.png'></button></td>" & _
								"<td style='float:left'><button title='上一页' class=lvwpagebutton style='padding-left:0px;padding-top:0px;' onclick='lvw.prePage(this)'><img src='../../images/prepage.png"& _
								"<td style='float:left'><input type=text class='text' style='width:24px;*font-size:10px;*height:15px;' onkeydown='if(window.event.keyCode==13){lvw.toPage(this)}' value=" & PageIndex & " id=' & me.id & _pindex"& _
								"<td style='float:left'><span style='font-size:12px;height:13px;padding:3px"& _
								"<td style='float:left'><button title='下一页' style='padding-left:0px;padding-top:0px;'  class=lvwpagebutton onclick='lvw.nextPage(this)'><img src='../../images/nextpage.png"& _
								"<td style='float:left'><button title='尾页' style='padding-left:0px;padding-top:0px;'  class=lvwpagebutton onclick='lvw.lastPage(this)'><img src='../../images/endpage.png"
							end if
							mhtml = mhtml &  "<td style='font-family:arial;float:left;' nowrap >&nbsp;&nbsp;总记录:<b id='lvw_RowCount' style='color:red;'>" & recordcount & "</b>行</td>"
							if showpsbox then
								mhtml = mhtml & "<td nowrap style='float:left;'>&nbsp;&nbsp;每页:</td>" & _
								"<td style='float:left;'><select style='font-size:12px;*font-size:10px;'  onchange='lvw.dbPageSizeChange(this)' id='" & me.id & "_psize'> " & pSizeOpt & _
								"</select></td>" & _
								"<td style='font-family:arial;float:left;' >行&nbsp;</td>" & _
								"</select></td>" & _
								"</td> "
							end if
						end if
						mhtml = mhtml & "</tr></table></td>"
						AddHtml htmls,mhtml
					Elseif PageType = "script" Then
						AddHtml htmls,"<td style='text-align:right'><div style='float:left'>" & tmplbBarHTML & "</div><table align='right' class=PageItemBar style='float:right;" & app.iif(treemode,"display:none","") & "'><tr> " & _
						"<td style='float:left;'>共<b style='color:red' id='lvw_RowCount_B" & id & _
						"<td style='float:left;'><select style='font-size:12px;height:16px;line-height:16px;' onchange='lvw.JsPageSizeChange(this)'> " & pSizeOpt & _
						"      </select></td>" & _
						"<td style='font-family:arial;float:left;'>行&nbsp;</td>" & _
						"      </select></td>" & _
						"</tr> " & _
						"</table></td>"
					end if
					AddHtml htmls, "</tr></table></div>"
				end if
				htmls(stateIndex)  = Replace(htmls(stateIndex),"class='ctl_listview' state=""""", "class='ctl_listview' state=""" & GetCurrPgaeState() & """")
				AddHtml htmls, ("<Div style='display:none' name=lvwnullrowdiv><table>" & nullRowHtml & "</table></Div>")
				hData = ""
				If PageType = "script" Then
					If Not rs.bof then rs.movefirst
					While (not rs.eof)
						rowData = ""
						If checkbox Then rowData = ";0"
						For i = 1 To colCount
							Set c = vCol(i)
							If c.isConst Then
								v = c.html
							else
								v = rs.fields(c.dbname).value
								if len(c.titlevalue(v)) > 0 then
									v = c.value(v) & "^tag~" & c.titlevalue(v)
								else
									v = c.value(v) & ""
								end if
							end if
							if treemode and  i = 1 then
								v = replace(getTreeMap(rs, ""),"***",  v)
							end if
							rowData = rowData & (";" & Replace(replace(v & "",";","#；"),"|","#$"))
						next
						hData = hData & (rowData & "|")
						rs.movenext
					wend
				end if
				hData = replace(hdata & "",chr(0),"")
				AddHtml htmls, ("<input type='hidden' id='ctl_listview_spd_" & id & "' value=""" & replace(Replace(Replace(hData,"<","$＜"),">","$＞"),"""","&quot;") & """></div>" )
				AddHtml htmls, ("</td><td id='lvwscrollbgbar" & id & "' valign=top align=center class='lvwscrollbarbg'><div id='lvwscrollbar_" & id & "' class='lvwscrollbar' onmousedown='lvw.scrollbarmsdown(this)'></div></td></tr></table>")
				If IsStateCallBack Then
					html = Join(htmls, "")
					sIndex = InStr(html,"<div id='listview_" & id & "'")
					eIndex = InStr(html,"</td><td id='lvwscrollbgbar")
					If sIndex > 0 Then
						innerHTML = Mid(html,sindex,eindex - sindex)
'If sIndex > 0 Then
					else
						innerHTML = html
					end if
				else
					innerHTML = Join(htmls, "")
				end if
			end function
			private function getTreeMap(byval rs,byref html)
				dim deep , nextdeep , hschild
				deep = rs.fields("lvw_treenodedeep").value
				if len(deep & "") = 0 then deep = 0
				if len(runtimemaxdeep & "") = 0 then  runtimemaxdeep =0
				rs.movenext
				if not rs.eof then
					nextdeep = rs.fields("lvw_treenodedeep").value
				else
					nextdeep = -1
					nextdeep = rs.fields("lvw_treenodedeep").value
				end if
				if runtimemaxdeep < deep then runtimemaxdeep = deep
				html = replace(html,"gxlc4.gif lsp=" & deep,"gxlc10.gif ")
				if  deep > 0 then
					html = replace(html,"<span class='hidedeep'>" & deep & "</span>","<div class='lvwvline'></div>")
				end if
				for I=deep+1 to  runtimemaxdeep
					html = replace(html,"<span class='hidedeep'>" & deep & "</span>","<div class='lvwvline'></div>")
					html = replace(html,"<span class='hidedeep'>" & I & "</span>","")
					html = replace(html,"gxlc4.gif lsp=" & I,"gxlc4.gif ")
				next
				rs.movePrevious
				hschild  = false
				if deep = 0 then
					if nextdeep = -1 or  nextdeep < deep  then
'if deep = 0 then
						getTreeMap = getTreeMap & "<td style=width:13px>*</td>"
					elseif deep  = nextdeep  then
						for i = 0 to deep - 1
'elseif deep  = nextdeep  then
							getTreeMap = getTreeMap & "<td class=lvwtndident>*</td>"
						next
						getTreeMap = getTreeMap & "<td style=width:13px></td>"
					else
						for i = 0 to deep - 2
'else
							getTreeMap = getTreeMap & "<td class=lvwtndident>*</td>"
						next
						getTreeMap = getTreeMap & "<td style=width:13px><img onclick='lvw.expNode(this,0)'  src=../../images/smico/gxlc7.gif></td>"
						hschild = true
					end if
				else
					if nextdeep = -1 or  nextdeep < deep  then
'else
						for i = 0 to deep-1
'else
							getTreeMap = getTreeMap & "<td class=lvwtndident><span class='hidedeep'>" & i & "</span></td>"
						next
						getTreeMap = getTreeMap & "<td style=width:13px><img  src=../../images/smico/gxlc6.gif></td>"
					elseif deep  = nextdeep  then
						for i = 0 to deep - 1
'elseif deep  = nextdeep  then
							getTreeMap = getTreeMap & "<td class=lvwtndident><span class='hidedeep'>" & i & "</span></td>"
						next
						getTreeMap = getTreeMap & "<td class=lvwtreenode1></td>"
					else
						for i = 0 to deep - 1
'else
							getTreeMap = getTreeMap & "<td class=lvwtndident><span class='hidedeep'>" & i & "</span></td>"
						next
						getTreeMap = getTreeMap & "<td style=width:13px><img onclick='lvw.expNode(this,1)' src=../../images/smico/gxlc4.gif lsp=" & deep & "></td>"
						hschild = true
					end if
				end if
				if hschild then
					getTreeMap = "<table class = 'lvwtreenode' deep='" & deep & "' hschild=1><tr>" & getTreeMap & "<td class=lvwtreenode3></td><td nowrap>***</td></tr></table>"
				else
					getTreeMap = "<table class = 'lvwtreenode' deep='" & deep & "' hschild=0><tr>" & getTreeMap & "<td class=lvwtreenode2></td><td nowrap>***</td></tr></table>"
				end if
			end function
			private Function NumEnCode(theNumber)
				if isnull(theNumber) then theNumber = ""
				if theNumber = "" then theNumber = 0
				Dim n_url, szEnc_url, t_url, HiN_url, LoN_url, i_url,szEnc
				n_url = CDbl((theNumber + 1772570) ^ 2 - 7 * (theNumber + 1772570) - 450)
'Dim n_url, szEnc_url, t_url, HiN_url, LoN_url, i_url,szEnc
				If n_url < 0 Then szEnc = "R" Else szEnc = "A"
				n_url = CStr(abs(n_url))
				For i_url = 1 To Len(n_url) step 2
					t_url = Mid(n_url, i_url, 2)
					If Len(t_url) = 1 Then
						szEnc = szEnc & t_url
						Exit For
					end if
					HiN_url = (clng(t_url) And 240) / 16
					LoN_url = clng(t_url) And 15
					szEnc = szEnc & Chr(Asc("M") + HiN_url) & Chr(Asc("C") + LoN_url) & "智邦"
'LoN_url = clng(t_url) And 15
				next
				NumEnCode = Server.URLEncode(szEnc)
			end function
			private Sub LoadUserDefColAttr
				Dim rs , code , items , l
				If Len(me.FieldAttrSaveKey) = 0 Then Exit Sub
				Set rs = cn.execute("select ColNames from M_ListViewConfig where UniqueStr='" & me.FieldAttrSaveKey & "'")
				If Not rs.eof Then
					code = rs.fields(0).value & ""
				end if
				rs.close
				For i = 1 To cols.count
					Set l = me.cols.items(i)
					If abs(l.htmlvisible)=0 Then
						If l.syshide = "bk" Then
							l.syshide = ""
						else
							l.syshide = "1"
						end if
					else
						If l.syshide = "bk" Then
							l.syshide = ""
						end if
					end if
				next
				If Len(code) > 0 Then
					on error resume next
					code = Split(code,"$$")
					For i= 0 To UBound(code)
						items = Split(code(i),"#")
						If UBound(items) = 2 then
							Set l = me.getcol(items(0))
							if not l.visible is nothing Then
								If l.htmlvisible  = 1 Or request.form("sethtmlvisible")="1" Then
									l.htmlvisible = app.iif(items(2)="0",1,0)
								end if
								If Len(items(1)) > 0 then
									l.udefname = items(1)
								end if
							end if
						end if
					next
				end if
			end sub
		End Class
		Sub App_sys_ListView_CreateExcel
			Dim fCount, oid, oids, rs2, xlsname, isdbPagesize, autoSum
			Response.Charset= "UTF-8"
'Dim fCount, oid, oids, rs2, xlsname, isdbPagesize, autoSum
			Dim vbscript , l , newAttr
			vbscript = request.Form("State")
			vbscript = Replace(vbscript,"#tL","UyMiUwRCUwQSUyM3R")
			vbscript = Replace(vbscript,"#tM","BBJTIzd")
			vbscript = App.base64.deCode(vbscript)
			vbscript = Replace(vbscript,"#t1","set n = l.getCol(""")
			vbscript = Replace(vbscript,"#t2","set n=l.AddCol(""")
			vbscript = Replace(vbscript,"#t3","n.dtype=""text""")
			vbscript = Replace(vbscript,"#t4","n.dtype=""number""")
			vbscript = Replace(vbscript,"#t5","n.dtype=""date""")
			vbscript = Replace(vbscript,"#t6","l.VisibleCol=""")
			vbscript = Replace(vbscript,"#t7","l.FieldAttrSaveKey=""")
			vbscript = Replace(vbscript,"#t8","{us999999}")
			vbscript = Replace(vbscript,"#t9","n.ywname = """)
			vbscript = Replace(vbscript,"#tA","n.ColReplaceButton=")
			vbscript = Replace(vbscript,"#tB","n.syshide = """)
			vbscript = Replace(vbscript,"#tC","l.canUpdate=")
			vbscript = Replace(vbscript,"#tD","[nVarChar](")
			vbscript = Replace(vbscript,"#tE","  [dateTime]  NULL")
			vbscript = Replace(vbscript,"#tF","  [money]  NULL")
			vbscript = Replace(vbscript,"#tG","  [int]  NULL")
			vbscript = Replace(vbscript,"#tH","n.save=""")
			vbscript = Replace(vbscript,"#tI","n.edit=""")
			vbscript = Replace(vbscript,"#tJ","n.selid=""")
			vbscript = Replace(vbscript,"#tK","  NULL")
			vbscript = Replace(vbscript,"#tN","n.cookiewidth=""")
			Set l = new Listview
			l.IsStateCallBack = True
			execute "On Error Resume Next"  & vbcrlf & vbscript
			autoSum = l.autoSum
			If abs(Err.number)>0 Then
				Exit sub
			end if
			If app.isSub("App_OnLvwCreateExcel") Then
				Call App_OnLvwCreateExcel(l)
				Exit Sub
			else
				If app.isSub("App_OnLvwCreateExcelBefore") Then
					Call App_OnLvwCreateExcelBefore(l)
				end if
			end if
			xlsname  = l.xlsname
			If Len(xlsname) = 0 Then
				xlsname = "导出文件"
			end if
			Dim mFloatNumber,mMoneyNumber
			set rs = cn.execute("select num1 from ["& Application("_sys_sql_db") &"]..setjm3  where ord=88")
			if rs.eof = false then
				mFloatNumber = rs.fields(0).value
			else
				mFloatNumber = 3
			end if
			rs.close
			set rs = cn.execute("select num1 from ["& Application("_sys_sql_db") &"]..setjm3  where ord=1")
			if rs.eof = false then
				mMoneyNumber = rs.fields(0).value
			else
				mMoneyNumber = 2
			end if
			rs.close
			Call Response.AddHeader("content-type","application/msexcel")
			mMoneyNumber = 2
			Call Response.AddHeader("Content-Disposition","attachment;filename=" & xlsname & ".xls")
'mMoneyNumber = 2
			Call Response.AddHeader("Pragma","No-Cache")
'mMoneyNumber = 2
			newAttr = request.Form("SortText") & ""
			If Len(newAttr) > 0  Then
				l.callBackSortText = newAttr
				cn.CursorLocation = 3
			end if
			Dim sql : sql = l.sql
			sql = Replace(sql, "&excelmode", "1", 1, -1, 1)
'Dim sql : sql = l.sql
			If InStr(1,sql,"&pagesize",1) > 0 then
				sql = Replace(sql, "&pagesize", "10000000", 1, -1, 1)
'If InStr(1,sql,"&pagesize",1) > 0 then
				sql = Replace(sql, "&pageindex", "1", 1, -1, 1)
'If InStr(1,sql,"&pagesize",1) > 0 then
				sql = Replace(sql, "&listfilter", "'" & Replace(l.filterText,"'","''") & "'",1,-1,1)
'If InStr(1,sql,"&pagesize",1) > 0 then
				sql = Replace(sql, "&listsort", "'" & Replace(l.callBackSortText,"'","''") & "'",1,-1,1)
'If InStr(1,sql,"&pagesize",1) > 0 then
				isdbPagesize = True
			else
				isdbPagesize = false
			end if
			Set rs = cn.execute("set nocount on;" & sql & ";set nocount off")
			oids = Split(l.sql, ",")
			If ubound(oids)>0 Then
				If InStr(l.sql,"erp_nosp_createMainSql")>0 Then
					oid = oids(ubound(oids))
				else
					oid = oids(ubound(oids)-1)
					'oid = oids(ubound(oids))
				end if
			end if
			If isdbPagesize = False Then
				If Len(l.filterText) > 0 Then
					rs.Filter = l.filterText
				end if
			else
				Set rs = rs.nextrecordset
			end if
			If Len(newAttr) > 0  Then
				rs.sort = l.callBackSortText
			end if
			fCount = rs.fields.count
			Dim xlstitle : xlstitle = l.xlsname
			If Len(xlstitle) = 0 Then xlstitle = "系统导出的数据"
			If InStr(xlstitle,"_") > 0 And InStr(1,l.sql, "createMainSql",1)>0 Then
				xlstitle = Split(xlstitle, "_")(0) & "列表"
			end if
			Response.write "" & vbcrlf & "     <html xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns=""http://www.w3.org/TR/REC-html40"">" & vbcrlf & "             <head>" & vbcrlf & "                  <meta http-equiv=Content-Type content=""text/html; charset=UTF-8"">" & vbcrlf & "                 <metaname=ProgId content=""Excel.Sheet"">" & vbcrlf & "                   <meta name=Generator content=""Microsoft Excel 11"">" & vbcrlf & "                        <title>"
			Response.write xlstitle
			Response.write "</title>" & vbcrlf & "" & vbcrlf & "                     <style>" & vbcrlf & "                         table{" & vbcrlf & "                                  border-collapse:collapse;" & vbcrlf & "                               }" & vbcrlf & "                               td.title {" & vbcrlf & "                                      font-weight:bold;" & vbcrlf & "                                       height:50px;" & vbcrlf & "                            }" & vbcrlf & "                               td.head{" & vbcrlf & "                                        padding-top:1px;" & vbcrlf & "                                      padding-right:3px;" & vbcrlf & "                                      padding-left:3px;" & vbcrlf & "                                       mso-ignore:padding;" & vbcrlf & "                                     color:windowtext;" & vbcrlf & "                                       font-size:12px;" & vbcrlf & "                                 font-weight:bold;" & vbcrlf & "                                       font-style:normal;" & vbcrlf & "                                      text-decoration:none;" & vbcrlf & "                                    font-family:宋体;" & vbcrlf & "                                       mso-generic-font-family:auto;" & vbcrlf & "                                   mso-font-charset:134;" & vbcrlf & "                                   mso-number-format:General;" & vbcrlf & "                                      text-align:general;" & vbcrlf & "                                     vertical-align:bottom;" & vbcrlf & "                                  border-left:.5pt solid windowtext;" & vbcrlf & "                                     mso-background-source:auto;" & vbcrlf & "                                     mso-pattern:auto;" & vbcrlf & "                                       white-space:nowrap;" & vbcrlf & "                                     height:22px;" & vbcrlf & "                            }" & vbcrlf & "                               td.cell{" & vbcrlf & "                                        padding-top:1px;" & vbcrlf & "                                        padding-right:3px;" & vbcrlf & "                                      padding-left:3px;" & vbcrlf & "                                 mso-ignore:padding;" & vbcrlf & "                                     color:windowtext;" & vbcrlf & "                                       font-size:12px;" & vbcrlf & "                                 font-style:normal;" & vbcrlf & "                                      text-decoration:none;" & vbcrlf & "                                   font-family:宋体;" & vbcrlf & "                                       mso-generic-font-family:auto;" & vbcrlf & "                                   mso-font-charset:134;" & vbcrlf & "                                  text-align:general;" & vbcrlf & "                                     vertical-align:bottom;" & vbcrlf & "                                  border:.5pt solid windowtext;" & vbcrlf & "                                   mso-background-source:auto;" & vbcrlf & "                                     mso-pattern:auto;" & vbcrlf & "                                       white-space:nowrap;" & vbcrlf & "                                     height:22px;" & vbcrlf & "                         }" & vbcrlf & "" & vbcrlf & "                               td.cellstr{" & vbcrlf & "                                     padding-top:1px;" & vbcrlf & "                                        padding-right:3px;" & vbcrlf & "                                      padding-left:3px;" & vbcrlf & "                                       mso-ignore:padding;" & vbcrlf & "                                     color:windowtext;" & vbcrlf & "                                       font-size:12px;" & vbcrlf & "                                 font-style:normal;" & vbcrlf & "                                 text-decoration:none;" & vbcrlf & "                                   font-family:宋体;" & vbcrlf & "                                       mso-generic-font-family:auto;" & vbcrlf & "                                   mso-font-charset:134;" & vbcrlf & "                                   mso-number-format:""\@"";" & vbcrlf & "                                   text-align:general;" & vbcrlf & "                                     vertical-align:bottom;" & vbcrlf & "                                 border:.5pt solid windowtext;" & vbcrlf & "                                   mso-background-source:auto;" & vbcrlf & "                                     mso-pattern:auto;" & vbcrlf & "                                       white-space:nowrap;" & vbcrlf & "                                     height:22px;" & vbcrlf & "                            }" & vbcrlf & "" & vbcrlf & "                               td.cellnum{" & vbcrlf & "                                     padding-top:1px;" & vbcrlf & "                                     padding-right:3px;" & vbcrlf & "                                      padding-left:3px;" & vbcrlf & "                                       mso-ignore:padding;" & vbcrlf & "                                     color:windowtext;" & vbcrlf & "                                       font-size:12px;" & vbcrlf & "                                 font-style:normal;" & vbcrlf & "                                      text-decoration:none;" & vbcrlf & "                                   font-family:宋体;" & vbcrlf & "               mso-generic-font-family:auto;" & vbcrlf & "                                   mso-font-charset:134;" & vbcrlf & "                                   mso-number-format:""0"
			'Response.write xlstitle
			if mFloatNumber > 0 then Response.write("\." & string(mFloatNumber,"0"))
			Response.write "_ "";" & vbcrlf & "                                      text-align:general;" & vbcrlf & "                                     vertical-align:bottom;" & vbcrlf & "                                  border:.5pt solid windowtext;" & vbcrlf & "                                   mso-background-source:auto;" & vbcrlf & "                                     mso-pattern:auto;" & vbcrlf & "                                       white-space:nowrap;" & vbcrlf & "                                     height:22px;" & vbcrlf & "                                }" & vbcrlf & "" & vbcrlf & "                               td.cellmoney{" & vbcrlf & "                                   padding-top:1px;" & vbcrlf & "                                        padding-right:3px;" & vbcrlf & "                                      padding-left:3px;" & vbcrlf & "                                       mso-ignore:padding;" & vbcrlf & "                                     color:windowtext;" & vbcrlf & "                                       font-size:12px;" & vbcrlf & "                                 font-style:normal;" & vbcrlf & "                                      text-decoration:none;" & vbcrlf & "                                   font-family:宋体;" & vbcrlf & "                                       mso-generic-font-family:auto;" & vbcrlf & "                                   mso-font-charset:134;" & vbcrlf & "                                   mso-number-format:""0"
'if mFloatNumber > 0 then Response.write("\." & string(mFloatNumber,"0"))
			if mMoneyNumber > 0 then Response.write("\." & string(mMoneyNumber,"0"))
			Response.write "_ "";" & vbcrlf & "                                      text-align:general;" & vbcrlf & "                                     vertical-align:bottom;" & vbcrlf & "                                  border:.5pt solid windowtext;" & vbcrlf & "                                   mso-background-source:auto;" & vbcrlf & "                                     mso-pattern:auto;" & vbcrlf & "                                       white-space:nowrap;" & vbcrlf & "                                     height:22px;" & vbcrlf & "                                }" & vbcrlf & "" & vbcrlf & "                               td.foot{" & vbcrlf & "                                        border-top:1px solid #000;" & vbcrlf & "                                      text-align:right;" & vbcrlf & "                                       height:30px;" & vbcrlf & "                                    font-size:12px;" & vbcrlf & "                         }" & vbcrlf & "                       </style>" & vbcrlf & "                        <!--[if gte mso 9]><xml>" & vbcrlf & "                         <x:ExcelWorkbook>" & vbcrlf & "                        <x:ExcelWorksheets>" & vbcrlf & "                      <x:ExcelWorksheet>" & vbcrlf & "                           <x:Name>数据清单</x:Name>" & vbcrlf & "                               <x:WorksheetOptions>" & vbcrlf & "                             <x:DefaultRowHeight>285</x:DefaultRowHeight>" & vbcrlf & "                            <x:CodeName>Sheet1</x:CodeName>" & vbcrlf & "                                 <x:Selected/>" & vbcrlf & "                                </x:WorksheetOptions>" & vbcrlf & "                      </x:ExcelWorksheet>" & vbcrlf & "                    </x:ExcelWorksheets>" & vbcrlf & "                   </x:ExcelWorkbook>" & vbcrlf & "                     </xml><![endif]-->" & vbcrlf & "              </head>" & vbcrlf & "         <body>" & vbcrlf & "                  <table cellPadding=0 cellSpacing=0 class='frame'>" & vbcrlf & "                 <tr>" & vbcrlf & "                            <td>&nbsp;</td>" & vbcrlf & "                 </tr>" & vbcrlf & "                   "
			Dim visibles , ywnames , selid , selArray
			ReDim visible(rs.fields.count-1)
'Dim visibles , ywnames , selid , selArray
			ReDim ywnames(rs.fields.count-1)
'Dim visibles , ywnames , selid , selArray
			ReDim selArray(rs.fields.count-1)
'Dim visibles , ywnames , selid , selArray
			l.InitUserDefColMessage()
			For i = 0 To rs.fields.count - 1
'l.InitUserDefColMessage()
				If  l.cols.count > i Then
					visible(i) = (abs(l.cols.items(i+1).htmlvisible)=1)
'If  l.cols.count > i Then
					ywnames(i) = l.cols.items(i+1).ywname
'If  l.cols.count > i Then
					If abs(l.cols.items(i+1).canExport) = 0 Then
'If  l.cols.count > i Then
						visible(i) = false
					end if
					selid = l.cols.items(i+1).selid
					visible(i) = false
					If Len(selid) = 0 Or Not IsNumeric(selid) Then selid  =  0
					If selid > 0 Then
						selArray(i) = GetListArrayText(selid)
					end if
					ywnames(i) = rs.fields(i).name
				else
					visible(i) = True
					'ywnames(i) = rs.fields(i).name
				end if
				If  Not visible(i) then
					fCount = fCount - 1
'If  Not visible(i) then
				end if
			next
			Response.write "" & vbcrlf & "                     <tr>" & vbcrlf & "                            <td>&nbsp;</td><td colspan='"
			Response.write fCount
			Response.write "' align=center class='title' style='border-bottom:1px solid #000'>"
			'Response.write fCount
			Response.write xlstitle
			Response.write "</td>" & vbcrlf & "                        </tr>" & vbcrlf & "                   "
			Dim sItem , sLen
			Response.write "<tr><td style='border-right:1px solid #000'>&nbsp;</td>"
'Dim sItem , sLen
			For i = 0 To rs.fields.count - 1
'Dim sItem , sLen
				If  visible(i) then
					If InStr(rs.fields(i).name,"{us") = 1 And InStr(ywnames(i),"}")> 0 Then
						Response.write "<td class='head'>" & replace(Split(ywnames(i),"}")(1),"#Fixed_","") & "</td>"
					else
						Response.write "<td class='head'>" & replace(ywnames(i) & "","#Fixed_","") & "</td>"
					end if
				end if
			next
			Dim sums
			redim sums(rs.fields.count-1)
'Dim sums
			Response.write "<td style='border-left:1px solid #000'>&nbsp;</td></tr>"
'Dim sums
			While not rs.eof And response.isclientconnected
				Response.write "<tr><td  style='border-right:1px solid #000'>&nbsp;</td>"
'While not rs.eof And response.isclientconnected
				For i = 0 To rs.fields.count - 1
'While not rs.eof And response.isclientconnected
					Dim fs : Set fs = rs.fields(i)
					If  visible(i)  Then
						v = fs.value & ""
						If fs.type = 11 Then
							v = fs.value
							If Len(v) = 0  Then v = false
							If v Then
								v = "是"
							else
								v = "否"
							end if
						else
							If IsArray(selArray(i)) Then
								sLen = UBound(selArray(i))
								For ii = 0 To sLen
									sItem = Split(selArray(i)(ii)&"|||","|||")
									If UBound(sItem)>0 then
										If sItem(1) = v Then
											v = sItem(0)
											ii = sLen
										end if
									end if
								next
							else
								v = CStr(fs.value&"")
							end if
						end if
						If InStr(v,"proc.gif") > 0 Then
							Set rs2 = cn.execute("exec erp_bill_ChildBills " & oid & "," & rs.fields("ID").value & "," & app.Info.user)
							If rs2.eof = False Then
								v = rs2.fields("bname").value & ":" & rs2.fields("title").value
							else
								v = "&nbsp;"
							end if
							rs2.close
						else
							If InStr(v,"<")>0 And InStr(v,">")>0 Then
								v=replace(v,"<","<!--")
'If InStr(v,"<")>0 And InStr(v,">")>0 Then
								v=replace(v,">","-->")
'If InStr(v,"<")>0 And InStr(v,">")>0 Then
							end if
						end if
						If InStr(v,"^tag~") > 0 Then
							tempV = Split(v,"^tag~")
							v = tempV(0)
						end if
						If fs.type >= 200 And  fs.type<=203 and InStr(fs.name,"库存")=0 Then
							Response.write "<td class='cellstr'>" & v & "</td>"
						else
							If autoSum Then
								If IsNumeric(v) Then
									If ( (fs.type >=2 And fs.type<=6) or (fs.type >=16 And fs.type<=21) Or fs.type=131 Or fs.type=139) Then
										sums(i) = sums(i)+CDbl(v)
'If ( (fs.type >=2 And fs.type<=6) or (fs.type >=16 And fs.type<=21) Or fs.type=131 Or fs.type=139) Then
									end if
								end if
							end if
							If IsNumeric(v) Then
								If Right(fs.name,1) = "价" Or Right(fs.name,1) = "额" Or Right(fs.name,2) = "成本" Or Right(fs.name,2) = "工资" Then
									Response.write "<td class='cellmoney'>" & v & "</td>"
								else
									Response.write "<td class='cellnum'>" & v & "</td>"
								end if
							else
								Response.write "<td class='cellstr'>" & v & "</td>"
							end if
						end if
					end if
				next
				Response.write "<td style='border-left:1px solid #000'>&nbsp;</td></tr>"
				Response.write "<td class='cellstr'>" & v & "</td>"
				Response.flush
				rs.movenext
			wend
			If autoSum Then
				Dim hsx : hsx = false
				Response.write "<tr><td  style='border-right:1px solid #000'>&nbsp;</td>"
'Dim hsx : hsx = false
				For i = 0 To rs.fields.count - 1
'Dim hsx : hsx = false
					If  visible(i)  Then
						on error resume next
						If hsx = False Then
							Response.write "<td class='cell'>合计</td>"
							hsx = true
						else
							If InStr( rs.fields(i).name,"单价")>0 Or InStr(rs.fields(i).name,"率")>0 Then
								sums(i)  = ""
							end if
							If IsNumeric(sums(i)) Then
								If Right(rs.fields(i).name,1) = "价" Or Right(rs.fields(i).name,1) = "额" Or Right(rs.fields(i).name,2) = "成本" Or Right(rs.fields(i).name,2) = "工资" Then
									Response.write "<td class='cellmoney'>" & sums(i) & "</td>"
								else
									Response.write "<td class='cellnum'>" & sums(i) & "</td>"
								end if
							else
								Response.write "<td class='cell'>" & sums(i) & "</td>"
							end if
						end if
					end if
				next
				Response.write "<td style='border-left:1px solid #000'>&nbsp;</td></tr>"
				Response.write "<td class='cell'>" & sums(i) & "</td>"
			end if
			rs.close
			Response.write "" & vbcrlf & "                     <tr>" & vbcrlf & "                            <td>&nbsp;</td><td colspan='"
			Response.write fCount
			Response.write "' class='foot'>导出时间:"
			Response.write now
			Response.write "&nbsp;&nbsp;导出人:"
			Response.write app.info.username
			Response.write "</td>" & vbcrlf & "                        </tr>" & vbcrlf & "                   </table>" & vbcrlf & "                </body>" & vbcrlf & " </html>" & vbcrlf & " "
			Set l = Nothing
		end sub
		Function GetListArrayText(selid)
			Dim rs , sql , f1 , f2 , Arrs , slist
			on error resume next
			Set rs = cn.execute("select sqlString from  M_CustomSQLStrings where id=" & selid & " and charindex('sql',sqlstring) = 1")
			If abs(Err.number) >  0  Then
				GetListArrayText = ""
				Exit function
			end if
			On Error Goto 0
			If Not rs.eof Then
				sql = Replace("AA" & LTrim(rs.fields(0).value),"AAsql=","",1,-1,1)
'If Not rs.eof Then
				sql = Replace(sql , "@key" ,"''", 1, -1, 1)
'If Not rs.eof Then
				sql = Replace(sql , "@uid" ,app.info.user, 1, -1, 1)
'If Not rs.eof Then
				For i = 0 To  50
					sql = Replace(sql , "@cell[" & i & "]" , "''", 1, -1, 1)
'For i = 0 To  50
				next
				sql = app.ConverProcductDefSql(sql)
			end if
			rs.close
			If Len(sql) > 0 Then
				sql = Replace(sql, "@bill_ID", request.form("bill_id"), 1,-1, 1)
'If Len(sql) > 0 Then
				sql = Replace(sql, "@MOIListID", "0", 1,-1, 1)
'If Len(sql) > 0 Then
				sql = Replace(sql, "@WProcID", "0", 1, -1, 1)
'If Len(sql) > 0 Then
				sql = Replace(sql, "@ProductID", "0", 1, -1, 1)
'If Len(sql) > 0 Then
				If  InStr(1,sql,"@PowerIntro",1) > 0 Then Exit function
				If InStr(1,sql, "@@istreemode", 1)>0 Then sql =  Replace(sql, "@@istreemode", "0")
				Set rs = cn.execute(sql)
				If rs.fields.count = 2 Then
					If LCase(rs.fields(0).name) = "billselectname" Then
						i = 0
						ReDim Arrs(0)
						Set f1 = rs.fields(0)
						Set f2 = rs.fields(1)
						While Not rs.eof
							ReDim preserve Arrs (i)
							Arrs (i) = f1.value & "|||" & f2.value
							i = i + 1
'Arrs (i) = f1.value & "|||" & f2.value
							rs.movenext
						wend
						If i > 0 Then
							GetListArrayText = Arrs
						end if
					end if
				end if
				If rs.fields.count>0 Then
					If InStr(rs.fields(0).name & "", "{keylistmodel}")>0 Then
						i = 0
						ReDim Arrs(0)
						Set f1 = rs.fields(0)
						While Not rs.eof
							ReDim preserve Arrs (i)
							Arrs (i) = Replace((f1.value & ""), "^tag~","|||")
							i = i + 1
'Arrs (i) = Replace((f1.value & ""), "^tag~","|||")
							rs.movenext
						wend
						If i > 0 Then
							GetListArrayText = Arrs
						end if
					end if
				end if
				rs.close
			end if
		end function
		Sub App_Sys_lvw_GetGroupImageData
			Dim vbscript , l ,  newSql , groupCode , groupName ,groupName_n , i ,  countType , countName , caseSql , defCode , defItem , tmTable
			vbscript = request.Form("State")
			vbscript = Replace(vbscript,"#tL","UyMiUwRCUwQSUyM3R")
			vbscript = Replace(vbscript,"#tM","BBJTIzd")
			vbscript = App.base64.deCode(vbscript)
			vbscript = Replace(vbscript,"#t1","set n = l.getCol(""")
			vbscript = Replace(vbscript,"#t2","set n=l.AddCol(""")
			vbscript = Replace(vbscript,"#t3","n.dtype=""text""")
			vbscript = Replace(vbscript,"#t4","n.dtype=""number""")
			vbscript = Replace(vbscript,"#t5","n.dtype=""date""")
			vbscript = Replace(vbscript,"#t6","l.VisibleCol=""")
			vbscript = Replace(vbscript,"#t7","l.FieldAttrSaveKey=""")
			vbscript = Replace(vbscript,"#t8","{us999999}")
			vbscript = Replace(vbscript,"#t9","n.ywname = """)
			vbscript = Replace(vbscript,"#tA","n.ColReplaceButton=")
			vbscript = Replace(vbscript,"#tB","n.syshide = """)
			vbscript = Replace(vbscript,"#tC","l.canUpdate=")
			vbscript = Replace(vbscript,"#tD","[nVarChar](")
			vbscript = Replace(vbscript,"#tE","  [dateTime]  NULL")
			vbscript = Replace(vbscript,"#tF","  [money]  NULL")
			vbscript = Replace(vbscript,"#tG","  [int]  NULL")
			vbscript = Replace(vbscript,"#tH","n.save=""")
			vbscript = Replace(vbscript,"#tI","n.edit=""")
			vbscript = Replace(vbscript,"#tJ","n.selid=""")
			vbscript = Replace(vbscript,"#tK","  NULL")
			vbscript = Replace(vbscript,"#tN","n.cookiewidth=""")
			Set l = new Listview
			l.IsStateCallBack = True
			on error resume next
			execute  vbscript
			groupName_def = "[" & request.Form("GroupByName")  & "_def]"
			groupName = "[" & request.Form("GroupByName")  & "]"
			groupCode = request.Form("GroupCode")
			countType = request.Form("CountType")
			countName = "[" &request.Form("CountItem") & "]"
			Select Case  GroupCode
			Case ""
			newSql = "select " &  groupName  & " , " & CountType & "(" & countName & ") as " & countName & ",count(" & groupName & ") as lvw_gpcount from #gptemp group by " +  groupName
'Case ""
			Case "year"
			newSql = "select " &  groupName  & " , " & CountType & "(" & countName & ") as " & countName & ",count(" & groupName & ") as lvw_gpcount from " & _
			"(select year(" &  groupName  & ") as " & groupName & " ," & countName & "  from #gptemp) t group by " +  groupName
			Case "month"
			newSql = "select " &  groupName  & " , " & CountType & "(" & countName & ") as " & countName & ",count(" & groupName & ") as lvw_gpcount from " & _
			"(select month(" &  groupName  & ") as " & groupName & " ," & countName & "  from #gptemp) t group by " +  groupName
			Case "day"
			newSql = "select " &  groupName  & " , " & CountType & "(" & countName & ") as " & countName & ",count(" & groupName & ") as lvw_gpcount from " & _
			"(select day(" &  groupName  & ") as " & groupName & " ," & countName & "  from #gptemp) t group by " +  groupName
			Case "def"
			caseCode = request.Form("GroupCodeDef") & ""
			If Len(caseCode) = 0 Then
				Response.write "<span class=c_r>只要需要一组自定义分组设置。</span>"
				exit sub
			end if
			defCode = Split(caseCode, "#spt$")
			For i = 0 To UBound(defCode)
				defItem = Split(defCode(i),"#spc$")
				If defitem(1) = "=" then
					caseSql = caseSql & vbcrlf & " when (" & groupName & " " & defitem(1) & " '" & defitem(2) & "') then '" &  defItem(0) & "'"
				else
					caseSql = caseSql & vbcrlf & " when (cast(" & groupName & " as float) " & defitem(1) & " '" & defitem(2) & "') then '" &  defItem(0) & "'"
				end if
			next
			caseSql = "(case " & caseSql & " else '其他' end ) as " & groupName_def
			newSql = "select " &  groupName_def  & " as " & groupName & " , " & CountType & "(" & countName & ") as " & countName & ",count(" & groupName_def & ") as lvw_gpcount from (select  " & caseSql  & ",* from  #gptemp) t group by " & groupName_def
			Case Else
			Response.write "<span class=c_r>01.参数不正确。</span>"
			Exit Sub
			End Select
			tmTable = "gpImageTemp_U" & app.info.user
			If Len(l.filterText) > 0 Then
				l.recordset.Filter = l.filterText
			end if
			App.db.CreateDbTableByRecordSet tmTable , l.recordset
			newSql = Replace(newSql,"#gptemp",tmTable)
			on error resume next
			Set rs = app.GetDataRecord(cn.execute(newsql))
			If abs(Err.number) > 0 Then
				If InStr(err.Description," float ") > 0 Then
					Response.write "<div style='color:red;position:absolute;top:40px;left:30%;width:40%;text-align:center'>" & _
					"<b style=color:#000>无法完成统计</b><br><br>数据类型无法转换，如对文本字段进行大小比较或算术运算操作就会引发该错误。</div>"
					Exit sub
				end if
				Response.write "<span class=c_r style='position:absolute;top:10px;'>统计数据失败，" & err.Description & "</span>"
				Exit Sub
			end if
			if rs.eof Then
				Response.write "<span class=c_r>没有可统计的数据</span>"
			else
				On Error goto 0
				Set img = new GroupImage
				Set img.dataRecord  = rs
				img.imagetype = request.Form("mType")
				img.xName = Replace(Replace(groupName,"[",""),"]","")
				img.yName = Replace(Replace(countName,"[",""),"]","")
				img.xType = groupCode
				img.yType = countType
				Call img.CreateHTML
				Set img = Nothing
			end if
			rs.close
			Set l = Nothing
			on error resume next
			cn.execute "drop table " & tmTable
		end sub
		Sub App_sys_ListView_CallBack
			Dim vbscript , l , newAttr
			vbscript = request.Form("State")
			vbscript = Replace(vbscript,"#tL","UyMiUwRCUwQSUyM3R")
			vbscript = Replace(vbscript,"#tM","BBJTIzd")
			vbscript = App.base64.deCode(vbscript)
			vbscript = Replace(vbscript,"#t1","set n = l.getCol(""")
			vbscript = Replace(vbscript,"#t2","set n=l.AddCol(""")
			vbscript = Replace(vbscript,"#t3","n.dtype=""text""")
			vbscript = Replace(vbscript,"#t4","n.dtype=""number""")
			vbscript = Replace(vbscript,"#t5","n.dtype=""date""")
			vbscript = Replace(vbscript,"#t6","l.VisibleCol=""")
			vbscript = Replace(vbscript,"#t7","l.FieldAttrSaveKey=""")
			vbscript = Replace(vbscript,"#t8","{us999999}")
			vbscript = Replace(vbscript,"#t9","n.ywname = """)
			vbscript = Replace(vbscript,"#tA","n.ColReplaceButton=")
			vbscript = Replace(vbscript,"#tB","n.syshide = """)
			vbscript = Replace(vbscript,"#tC","l.canUpdate=")
			vbscript = Replace(vbscript,"#tD","[nVarChar](")
			vbscript = Replace(vbscript,"#tE","  [dateTime]  NULL")
			vbscript = Replace(vbscript,"#tF","  [money]  NULL")
			vbscript = Replace(vbscript,"#tG","  [int]  NULL")
			vbscript = Replace(vbscript,"#tH","n.save=""")
			vbscript = Replace(vbscript,"#tI","n.edit=""")
			vbscript = Replace(vbscript,"#tJ","n.selid=""")
			vbscript = Replace(vbscript,"#tK","  NULL")
			vbscript = Replace(vbscript,"#tN","n.cookiewidth=""")
			If request.form("cmdtxt") = "GetHiddeData" Then
				vbscript = Replace(vbscript, "l.PageType=""database""","l.PageType=""script""")
			end if
			Set l = new Listview
			l.IsStateCallBack = True
			newAttr = request.Form("SortText") & ""
			If Len(newAttr) > 0  Then
				l.callBackSortText = newAttr
			end if
			vbscript = "On Error Resume Next " & vbcrlf &  vbscript
			newAttr = request.Form("PageIndex") & ""
			If Len(newAttr) > 0 And IsNumeric(newAttr) Then
				l.pageindex = newAttr
			end if
			newAttr = request.Form("PageSize") & ""
			If Len(newAttr) > 0 And IsNumeric(newAttr) Then
				l.pagesize = newAttr
			end if
			newAttr = request.Form("filtertext") & ""
			If Len(newAttr) > 0  Then
				If  newAttr = "null" then
					l.filtertext = ""
				else
					l.filtertext = newAttr
				end if
			end if
			execute  vbscript
			newAttr = request.Form("VisibleCol") & ""
			If Len(newAttr) > 0  Then
				l.visiblecol = newAttr
			end if
			Response.write   l.innerHTML
			If request.form("cmdtxt") = "GetHiddeData" Then
				Response.clear
				Response.write l.hData
			end if
		end sub
		Sub App_sys_lvw_savecolwidth
			Dim ckname , ckvalue
			ckname = request.Form("cookiename")
			ckvalue = request.Form("cookievalue")
			Response.Cookies(ckname) = ckvalue
		end sub
		Sub App_sys_lvw_listviewcolattr_del
			key = request.Form("savekey")
			If Len(key)=0 Then
				app.alert "缺少配置标识符"
				Exit Sub
			end if
			cn.execute "delete from M_ListViewConfig where UniqueStr='" & key & "'"
			app.alert "还原成功，请刷新页面生效。"
		end sub
		Sub App_sys_lvw_listviewcolattr
			Dim dat , key , I , cell
			dat = request.Form("savedata")
			key = request.Form("savekey")
			If Len(key)=0 Then
				app.alert "缺少配置标识符"
				Exit Sub
			end if
			If Len(dat)=0 Then
				app.alert "缺少配置数据"
				Exit Sub
			end if
			Set rs = server.CreateObject("adodb.recordset")
			rs.open "select * from M_ListViewConfig where UniqueStr='" & key & "'",cn,1,3
			If rs.eof Then
				rs.addnew
				rs.fields("UniqueStr").value = key
			end if
			rs.fields("ColNames").value = dat
			rs.update
			rs.close
		end sub
		sub App_sys_lvwGetdrConfig
			set drdat = new DrConfigData
			drdat.title = "导入列表数据"
			drdat.fileName = "列表数据"
			drdat.filters = "xls|xlsx"
			drdat.smpFilePath = ""
			drdat.helpFilePath = ""
			drdat.remark = "请参考示例excel文件，确保导入的文件格式符合要求。"
			drdat.autosave = false
			drdat.allowSize = 25*1024*1024
			drdat.modelCls = "列表信息"
			if app.isSub("App_ListDrConfig") then
				App_ListDrConfig(drdat)
			end if
			Response.write Server.URLEncode(drdat.title) & chr(1)
			Response.write Server.URLEncode(drdat.fileName)  & chr(1)
			Response.write Server.URLEncode(drdat.filters) & chr(1)
			Response.write Server.URLEncode(drdat.smpFilePath)  & chr(1)
			Response.write Server.URLEncode(drdat.helpFilePath) & chr(1)
			Response.write Server.URLEncode(drdat.remark) & chr(1)
			Response.write abs(drdat.autosave) & chr(1)
			Response.write drdat.allowSize & chr(1)
			Response.write Server.URLEncode(drdat.modelCls)
			If Len(drdat.optionCount) > 0 And isnull(drdat.optionCount) = False Then
				Response.write chr(2)
				For i = 0 To drdat.optionCount
					Response.write Server.URLEncode(drdat.optionItems(i).name) & chr(1)
					Response.write Server.URLEncode(drdat.optionItems(i).selectIndex) & chr(1)
					Response.write Server.URLEncode(drdat.optionItems(i).key) & chr(1)
					For ii = 0 To drdat.optionItems(i).count
						Response.write Server.URLEncode(drdat.optionItems(i).options(ii)(0)) & Chr(4)
						Response.write Server.URLEncode(drdat.optionItems(i).options(ii)(1))
						If ii < drdat.optionItems(i).count Then
							Response.write Chr(5)
						end if
					next
					If i < drdat.optionCount Then
						Response.write  chr(3)
					end if
				next
			end if
		end sub
		class lvwUploaderClass
			public ReportTables
			public dbname
			public savefilename
			public filename
			Private REC_PER_SHEET_IN_IMPORT_REPORT
			Private HOW_MANY_REC_TO_USE_EXCEL
			public sub Class_Initialize
				dbname = replace(request.querystring("dbname"),"'","")
				savefilename = request.querystring("savefilename")
				filename = request.querystring("filename")
				REC_PER_SHEET_IN_IMPORT_REPORT = 10000
				HOW_MANY_REC_TO_USE_EXCEL = 200
			end sub
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
			function CheckFields(fields)
				dim rs , i , dy , items , item , rv
				items = split(replace(fields,",",";"),";")
				set rs = cn.execute("select top 0 * from " & dbname)
				for i = 0 to rs.fields.count - 1
'set rs = cn.execute("select top 0 * from " & dbname)
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
					Response.write "" & vbcrlf & "                     <script language='javascript'>" & vbcrlf & "                          var win = window.parent;" & vbcrlf & "                                while(win.parent &&  win!=window.top && win.parent.DivOpen){win = win.parent}" & vbcrlf & "                           var  div = win.DivOpen(""colerror"",""文档格式不符合预期要求："",420,260,'a','b',1,1);" & vbcrlf & "                          var  htm = """";" & vbcrlf & "                                "
					rv = split(rv,vbcrlf)
					for i = 0 to ubound(rv) -1
'rv = split(rv,vbcrlf)
						Response.write "htm = htm + '<div style=""letter-spacing:2px;border-bottom:1px dotted #ccc;color:#000;height:24px;line-height:24px"">&nbsp;" & rv(i) & "</div>';" & vbcrlf
'rv = split(rv,vbcrlf)
					next
					Response.write "" & vbcrlf & "                             htm = htm + '<div style=""letter-spacing:2px;border-bottom:1px dotted #ccc;color:#000;height:24px;line-height:24px"">&nbsp;共<b style=""color:red"">"
'rv = split(rv,vbcrlf)
					Response.write (i)
					Response.write "</b>项错误，该文档导入失败。</div>';" & vbcrlf & "                         div.innerHTML = ""<div style='wdith:380px;height:200px;overflow:auto'>"" +  htm + ""</div>"";" & vbcrlf & "                   </script>" & vbcrlf & "                       "
					Response.write (i)
				else
					CheckFields = true
				end if
			end function
			public sub showReport
				dim fn
				fn = replace(me.savefilename,".","")
				if isArray(ReportTables) Then
					for i = 0 to ubound(ReportTables)
						item = split(ReportTables(i),"|||")
						call WriteHTMLTable(item(0), fn & "_" & i, item(1))
					next
					Response.write "<script>window.parent.insertReport(document.getElementsByTagName('table'),'" & fn & "','" & me.filename & "')</script>"
				end if
			end sub
			private sub WriteHTMLTable(db, id, title)
				dim rs,i,allcount,rss,musername,ExName,MyFileObject,fName,folderPath
				if db = "#k_fail" then
					set rst=cn.execute("select count(*) from "& db)
					if not rst.eof then
						allcount=rst(0)
					end if
					rst.close
					set rs=nothing
					if allcount > HOW_MANY_REC_TO_USE_EXCEL then
						Set rss = cn.execute("select name from gate where ord=" & app.info.user)
						If rss.eof Then
							musername = "未知用户"
						else
							musername = rss.fields(0).value
						end if
						rss.close
						set rss=nothing
						folderPath = server.MapPath("../../out/HtmlExcel/")
						fName = "未导入数据报告_"&musername&"_"&session("personzbintel2007")&".xls"
						ExName = folderPath & "\" & fName
						set MyFileObject=server.CreateObject("Scripting.FileSystemObject")
						if MyFileObject.FileExists(ExName) then
							MyFileObject.DeleteFile(ExName)
						end if
						set MyFileObject=nothing
						ExName = CreateImportReport(cn,db,folderPath,fName)
						Response.write "<table id='" & id & "' style='display:none;width:auto;border-collapse:collapse'  title='" & title & "'>" & vbcrlf &_
						"<tr style="&_
						"<th nowrap width=100% style="&_
						"<p align="&_
						"<a href='../../../sysa/out/downfile.asp?fileSpec=" & ExName & "'>"&_
						"<font class='red'><strong><u>下载未导入数据报告</u></strong></font>"&_
						"</a>" & vbcrlf &_
						"</p>" & vbcrlf &_
						"</th>" & vbcrlf &_
						"</tr>" & vbcrlf &_
						"</table>"
					else
						set rs = cn.execute("select * from " & db & " order by 行号")
						Response.write "<table id='" & id & "' style='display:none;width:auto;border-collapse:collapse'  title='" & title & "'><tr style='background-color:f0f0ff'>"
'set rs = cn.execute("select * from " & db & " order by 行号")
						for i = 0 to rs.fields.count - 1
'set rs = cn.execute("select * from " & db & " order by 行号")
							Response.write "<th nowrap style='height:24px;border-right:1px dotted #ccccee'>&nbsp;" & rs.fields(i).name & "&nbsp;</th>"
'set rs = cn.execute("select * from " & db & " order by 行号")
						next
						Response.write "</tr>"
						while not rs.eof And response.isclientconnected
							Response.write "<tr >"
							for i = 0 to rs.fields.count - 1
								Response.write "<tr >"
								Response.write "<td style='border-bottom:1px dotted #ccc;height:24;padding-left:6px;border-right:1px dotted #ccc'>" & rs.fields(i).value & "</td>"
								Response.write "<tr >"
							next
							Response.write "</tr>"
							rs.movenext
						wend
						rs.close
						Response.write "</table>"
					end if
				else
					set rs = cn.execute("select * from " & db)
					Response.write "<table id='" & id & "' style='display:none;width:auto;border-collapse:collapse'  title='" & title & "'><tr style='background-color:f0f0ff'>"
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
							Response.write "<tr >"
							Response.write "<td style='border-bottom:1px dotted #ccc;height:24;padding-left:6px;border-right:1px dotted #ccc'>" & rs.fields(i).value & "</td>"
							Response.write "<tr >"
						next
						Response.write "</tr>"
						rs.movenext
					wend
					rs.close
					Response.write "</table>"
				end if
			end sub
			Private Function CreateImportReport(ByRef cn,ByVal db,ByVal folderPath,ByVal fName)
				Dim xApp,i,fso,rsInfo,fPath,outString
				fPath = folderPath & "\" & fName
				Set rsInfo = cn.execute("select * from "&db&" order by 行号")
				outString="" &_
				"MIME-Version: 1.0" & vbcrlf &_
				"X-Document-Type: Workbook" & vbcrlf &_
				"Content-Type: multipart/related; boundary=""##-#-#-##--""" & vbcrlf &_
				"--##-#-#-##--" & vbcrlf &_
				"Content-Location: file:///C:/zbintel/index.htm" & vbcrlf &_
				"Content-Transfer-Encoding: 8bit" & vbcrlf &_
				"Content-Type: text/html; charset=""UTF-8""" & vbcrlf &_
				"<html xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"">" & vbcrlf &_
				"<xml>" & vbcrlf &_
				"  <o:DocumentProperties>" & vbcrlf &_
				"          <o:Author></o:Author>" & vbcrlf &_
				"          <o:LastAuthor></o:LastAuthor>" & vbcrlf &_
				"          <o:Created></o:Created>" & vbcrlf &_
				"          <o:LastSaved></o:LastSaved>" & vbcrlf &_
				"          <o:Company>智邦国际</o:Company>" & vbcrlf &_
				"          <o:Version>11.5606</o:Version>" & vbcrlf &_
				"  </o:DocumentProperties>" & vbcrlf &_
				"</xml>" & vbcrlf &_
				"<xml>" & vbcrlf &_
				"  <x:ExcelWorkbook>" & vbcrlf &_
				"          <x:ExcelWorksheets>" & vbcrlf &_
				"                  <x:ExcelWorksheet>" & vbcrlf &_
				"                          <x:Name>导入报告</x:Name>" & vbcrlf &_
				"                          <x:WorksheetSource HRef=""files/sheet000.htm""/>" & vbcrlf &_
				"                  </x:ExcelWorksheet>" & vbcrlf &_
				"          </x:ExcelWorksheets>" & vbcrlf &_
				"          <x:WindowHeight>11250</x:WindowHeight>" & vbcrlf &_
				"          <x:WindowWidth>19260</x:WindowWidth>" & vbcrlf &_
				"          <x:WindowTopX>120</x:WindowTopX>" & vbcrlf &_
				"          <x:WindowTopY>105</x:WindowTopY>" & vbcrlf &_
				"          <x:ActiveSheet>0</x:ActiveSheet>" & vbcrlf &_
				"          <x:ProtectStructure>False</x:ProtectStructure>" & vbcrlf &_
				"          <x:ProtectWindows>False</x:ProtectWindows>" & vbcrlf &_
				"  </x:ExcelWorkbook>" & vbcrlf &_
				"</xml>" & vbcrlf &_
				"</html>" & vbcrlf &_
				"--##-#-#-##--" & vbcrlf &_
				"Content-Location: file:///C:/zbintel/files/stylesheet.css" & vbcrlf &_
				"Content-Transfer-Encoding: 8bit" & vbcrlf &_
				"Content-Type: text/css; charset=""UTF-8""" & vbcrlf &_
				"td{font-size:12px;}" & vbcrlf &_
				"table{mso-displayed-decimal-separator:""\.""; mso-displayed-thousand-separator:""\,"";}" & vbcrlf &_
				"--##-#-#-##--" & vbcrlf &_
				"Content-Location: file:///C:/zbintel/files/sheet000.htm" & vbcrlf &_
				"Content-Transfer-Encoding: 8bit" & vbcrlf &_
				"Content-Type: text/html; charset=""UTF-8""" & vbcrlf &_
				"<html xmlns:o=""urn:schemas-microsoft-com:office:office""" & vbcrlf &_
				"xmlns:x=""urn:schemas-microsoft-com:office:excel"">" & vbcrlf &_
				"<head><!--表格0-->" & vbcrlf &_
				"  <meta http-equiv=Content-Type content=""text/html; charset=UTF-8"">" & vbcrlf &_
				"  <meta name=ProgId content=Excel.Sheet>" & vbcrlf &_
				"  <meta name=Generator content=""Microsoft Excel 11"">" & vbcrlf &_
				"  <link id=Main-File rel=Main-File href=""../index.htm"">" & vbcrlf &_
				"  <meta name=Generator content=""Microsoft Excel 11"">" & vbcrlf &_
				"  <link rel=File-List href=filelist.xml>" & vbcrlf &_
				"  <meta name=Generator content=""Microsoft Excel 11"">" & vbcrlf &_
				"  <link rel=Edit-Time-Data href=editdata.mso>" & vbcrlf &_
				"  <meta name=Generator content=""Microsoft Excel 11"">" & vbcrlf &_
				"  <link rel=Stylesheet href=stylesheet.css>" & vbcrlf &_
				"  <xml>" & vbcrlf &_
				"          <x:WorksheetOptions>" & vbcrlf &_
				"                  <x:DefaultRowHeight>285</x:DefaultRowHeight>" & vbcrlf &_
				"                  <x:Panes>" & vbcrlf &_
				"                          <x:Pane>" & vbcrlf &_
				"                                  <x:Number>3</x:Number>" & vbcrlf &_
				"                                  <x:ActiveRow>1</x:ActiveRow>" & vbcrlf &_
				"                                  <x:ActiveCol>1</x:ActiveCol>" & vbcrlf &_
				"                          </x:Pane>" & vbcrlf &_
				"                  </x:Panes>" & vbcrlf &_
				"                  <x:ProtectContents>False</x:ProtectContents>" & vbcrlf &_
				"                  <x:ProtectObjects>False</x:ProtectObjects>" & vbcrlf &_
				"                  <x:ProtectScenarios>False</x:ProtectScenarios>" & vbcrlf &_
				"          </x:WorksheetOptions>" & vbcrlf &_
				"  </xml>" & vbcrlf &_
				"</head>" & vbcrlf &_
				"<body link=blue vlink=purple>" & vbcrlf &_
				"  <table>" & vbcrlf &_
				"          <tbody>" & vbcrlf &_
				"                  <tr>" & vbcrlf
				for i = 0 to rsInfo.fields.count - 1
'<tr> & vbcrlf
					outString=outString & "    <th align='center'><b>" & rsInfo.fields(i).name & "</b></th>"
				next
				outString=outString & "    </tr>" & vbcrlf &_
				"  <tr><td>" & vbcrlf &_
				"rsInfo.getString(,,""</td><td>"",""</td></tr><tr><td>"","""")" & vbcrlf &_
				"</tbody>" & vbcrlf &_
				"  </table>" & vbcrlf &_
				"</body>" & vbcrlf &_
				"</html>" & vbcrlf &_
				"--##-#-#-##----     "
				Set objStream = frk3_
				With objStream
				.Type = 2
				.Mode = 3
				.Open
				.Charset = "utf-8"
'.Open
				.WriteText= outString
				.SaveToFile fpath,1
				.Close
				End With
				Set objStream = NoThing
				rsInfo.close
				Set rsInfo = Nothing
				CreateImportReport = HexEncode(fpath)
			end function
			Public Function HexEncode(ByVal data)
				Dim s, c, i ,rnds, item
				c = Len(data) - 1
'Dim s, c, i ,rnds, item
				rnds = Split("g,h,i,j,k,l,m,n,o",",")
				If c = - 1 Then Exit function
'rnds = Split("g,h,i,j,k,l,m,n,o",",")
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
		end Class
		
		If request("remind") <> "" Then
			Response.write "" & vbcrlf & "<script language=""javascript"">" & vbcrlf & "try{" & vbcrlf & "       jQuery(function(){" & vbcrlf & "              jQuery('form').each(function(){" & vbcrlf & "                 jQuery('<input type=""hidden"" name=""remind"" value="""
			Response.write Request("remind")
			Response.write """/>').appendTo(this);" & vbcrlf & "               });" & vbcrlf & "     });" & vbcrlf & "}catch(e){}" & vbcrlf & "</script>" & vbcrlf & ""
		end if
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
		end class
		
		sub page_init
			if len(session("top1zbintel2007")) = 0 then
				Response.write "<center style='color:red;font-size:12px'><br>权限不够</center>"
'if len(session("top1zbintel2007")) = 0 then
				cn.close
				set cn = nothing
				call db_close : Response.end
			end if
		end sub
		sub page_load
			Response.write "" & vbcrlf & "      <body>" & vbcrlf & "          <style language='javascript'>" & vbcrlf & "                   #lefttree{" & vbcrlf & "                              float:left;" & vbcrlf & "                             width:180px;" & vbcrlf & "                            /*margin-left:10px;" & vbcrlf & "                             margin-top:10px;*/" & vbcrlf & "                              z-index:1000;" & vbcrlf & "                   }" & vbcrlf & "                       #ncbody{" & vbcrlf & "                                /*margin:10px;*/" & vbcrlf & "                                border-top:0px;" & vbcrlf & "                         padding-top:5px;" & vbcrlf & "                                background-image:url(../../images/smico/gpbg4.jpg);" & vbcrlf & "                             background-repeat:repeat-x;" & vbcrlf & "                             overflow:hidden;" & vbcrlf & "                                position:relative;" & vbcrlf& "                                top:0px;" & vbcrlf & "                                left:0px;" & vbcrlf & "                               z-index:3000;" & vbcrlf & "                   }" & vbcrlf & "                       ul.tvw_child{" & vbcrlf & "                           background-color:transparent;" & vbcrlf & "                   }" & vbcrlf & "                       li.tvw_item {" & vbcrlf & "                           background-color:transparent;" & vbcrlf & "                   }" & vbcrlf & "                       html {overflow:auto}" & vbcrlf & "                  span.tvw_itemtext{" & vbcrlf & "                              border:0!important;" & vbcrlf & "                     }" & vbcrlf & "               </style>" & vbcrlf & "                <script language=javascript src='listview.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "           <script language=javascript src='treeview.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "           <script language=javascript src='contextmenu.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "           <script language=javascript src='TabControl.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "           <script language=javascript src='check.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "           <script language=javascript src='bill.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "           <div id='billtopbardiv' style='overflow:hidden;width:100%'>" & vbcrlf & "                     <table class='full' style='table-layout:fixed;'>" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td id=""billtitle"" style='background-repeat:no-repeat'>单据回收站</td>" & vbcrlf & "                            <td id='billtopbar'style='width:50%'>" & vbcrlf & "                                  <div style='float:right'><button class=button onclick='deleteCurrPage()'>全部删除</button>&nbsp;</div>" & vbcrlf & "                          </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   </table>" & vbcrlf & "                </div>" & vbcrlf & "          <div id='lefttree'>" & vbcrlf & "                     <div id='ncbody'>" &vbcrlf & "                         <div style='margin-left:-8px;;margin-bottom:10px;'>" & vbcrlf & "                             "
			'Response.write Application("sys.info.jsver")
			dim fnum1 , fnum2, oid
			fnum1 = replace(request.querystring("o1"),"'","")
			fnum2 = replace(request.querystring("o2"),"'","")
			if len(fnum1) = 0 or not isnumeric(fnum1) then fnum1 = 0
			if len(fnum2) = 0 or not isnumeric(fnum1) then fnum2 = 0
			set rs = App.getdatarecord(cn.execute("exec erp_bill_Recyclist"))
			rs.filter = "id > " & fnum1 & " and id<" & fnum2
			set tvw = new treeview
			tvw.root.text = "<b id='roottit'>单据目录</b><br><div style='height:7px;background-color:#EFEFEF'><div style='width:5px;height:6px;margin-left:7px;'></div></div>"
			'set tvw = new treeview
			while not rs.eof
				oid = rs.fields("id").value
				If ( (oid >=1 And oid<=100 And sdk.power.existsManu(oid)=False)=false And (oid<>31 And oid<>1004) ) or (oid=1004 And sdk.power.ExistsModel(39001)) Then
					set nd = tvw.root.nodes.add
					nd.text =  rs.fields("ordername").value & app.iif(rs.fields("num").value >0 , "(<b title='目前位于回收站的单据数量' style='color:red'>" & rs.fields("num").value & "</b>)" ,"")
					nd.tag =  rs.fields("id").value
				end if
				rs.movenext
			wend
			rs.close
			Response.write tvw.html
			Response.write "" & vbcrlf & "                              </div>" & vbcrlf & "                  </div>" & vbcrlf & "          </div>" & vbcrlf & "          <div id='listbody' style='padding:22px 0;height:310px;position:absolute;left:180px;top:43px;min-width:600px'><!-- padding-top:20px;margin-right:15px'> --></div>" & vbcrlf & "                <div style='position:absolute;top:0px;left:0px'><div style='float:right;margin:15px;'><!-- <img src='../../images/smico/trashbox.gif'></div>  --></div>" & vbcrlf & "               <script type=""text/javascript"">" & vbcrlf & "           var currnode = null" & vbcrlf & "             var tit = document.getElementById(""roottit"")" & vbcrlf & "              var li= tit.parentElement.parentElement;" & vbcrlf & "         li.style.height = ""22px"";" & vbcrlf & "         li.children[0].innerHTML = """"" & vbcrlf & "             li.children[1].style.display = ""none""" & vbcrlf & "             li.children[2].style.border = ""0px""" & vbcrlf & "               li.children[2].onmouseover = function(){}" & vbcrlf & "               li.children[2].onmouseout = function(){}" & vbcrlf & "              li.children[2].onmousedown = function(){}" & vbcrlf & "               tvw.NodeClick = function(a){" & vbcrlf & "                    if(a){currnode = a}" & vbcrlf & "                     if(currnode){" & vbcrlf & "                           var count = 0" & vbcrlf & "                           ajax.regEvent(""clist"");" & vbcrlf & "                           ajax.addParam(""id"",currnode.tag)" & vbcrlf & "                         var r = ajax.send()" & vbcrlf & "                             var eindex = r.indexOf(""<rsCount>"")" & vbcrlf & "                               count = r.substr(eindex).replace(""<rsCount>"","""").replace(""</rsCount>"","""")" & vbcrlf & "                               var listbody = document.getElementById(""listbody"");" & vbcrlf & "listbody.innerHTML = r.substring(0,eindex);" & vbcrlf & "                             if(!window.ActiveXObject) {" & vbcrlf & "                                     listbody.children[0].style.width = ""auto"";" & vbcrlf & "                                        listbody.children[0].style.minWidth = ""800px"";" & vbcrlf & "                                    if(document.getElementById(""listview_list_"" + currnode.tag)) {" & vbcrlf & "                                                document.getElementById(""listview_list_"" + currnode.tag).style.minWidth = ""800px"";" & vbcrlf & "                                  }" & vbcrlf & "                               }" & vbcrlf & "                               lvw.UpdateAllScroll();" & vbcrlf & "                          var b = currnode.children[2].children[0]" & vbcrlf & "                                if(count.length==0){count=0}" & vbcrlf & "                            if(isNaN(count)){count=0}" & vbcrlf & "                               if(count*1>0){" & vbcrlf & "                                  if(b){" & vbcrlf & "                                          b.innerText = count" & vbcrlf & "                                     }" & vbcrlf & "                                       else{" & vbcrlf & "                                            currnode.children[2].innerHTML = currnode.children[2].innerHTML + ""(<b title='目前位于回收站的单据数量' style='color:red'>"" + count + ""</b>)""" & vbcrlf & "                                        }" & vbcrlf & "                               }" & vbcrlf & "                               else{" & vbcrlf & "                                   if(b){" & vbcrlf & "                                          b.innerText = """"" & vbcrlf & "                                          currnode.children[2].innerHTML = currnode.children[2].innerText.replace(""()"","""");" & vbcrlf & "                                   }" & vbcrlf & "                               }"& vbcrlf &                "      } "& vbcrlf &     "          } "& vbcrlf &    "          "   & vbcrlf &            "     function callRestore(o,i){ "& vbcrlf &                    "   if(window.confirm(""确定要恢复该单据吗？\n\n注意：恢复单据有可能与现有数据冲突，请谨慎操作。"")){ "& vbcrlf &              "              ajax.regEvent(""callRestore"");" & vbcrlf &       "                       ajax.addParam(""o"",o);" & vbcrlf &                    "          ajax.addParam(""i"",i);" & vbcrlf & "                         ajax.exec();" & vbcrlf & "                            if (o == 1004) {" & vbcrlf & "                                    $.ajax({" & vbcrlf & "                                    url: ""../../../SYSN/view/comm/RegAspBillMessage.ashx?BillType=24001&EventType=905&billids="" + i," & vbcrlf & "                                  success: function (r) {" & vbcrlf & "                                 }" & vbcrlf & "                                    });" & vbcrlf & "                         }" & vbcrlf & "                               tvw.NodeClick();" & vbcrlf & "                        }" & vbcrlf & "               }" & vbcrlf & "" & vbcrlf & "               function realdeletebill(o,i){" & vbcrlf & "                   if(window.confirm(""确定要彻底销毁该单据吗？\n\n注意：彻底销毁后，单据将不可再恢复。"")){" & vbcrlf & "                           ajax.regEvent(""realdel"");" & vbcrlf & "                               ajax.addParam(""o"",o);" & vbcrlf & "                             ajax.addParam(""i"",i);" & vbcrlf & "                             ajax.exec();" & vbcrlf & "                            tvw.NodeClick();" & vbcrlf & "                        }" & vbcrlf & "               }" & vbcrlf & "               function linkEvent(){" & vbcrlf & "                   if(window.event.srcElement.style.textDecoration!=""underline""){" & vbcrlf& "                                window.event.srcElement.style.textDecoration=""underline""" & vbcrlf & "                  }" & vbcrlf & "                       else{" & vbcrlf & "                           window.event.srcElement.style.textDecoration=""none""" & vbcrlf & "                       }" & vbcrlf & "               }" & vbcrlf & "               function deleteCurrPage(){" & vbcrlf & "                      var bidArray = new Array()" &vbcrlf & "                 var oid = 0" & vbcrlf & "                     if(window.confirm(""确定要删除当前页面的所有单据吗？"")){" & vbcrlf & "                           var Spans = document.getElementsByTagName(""Span"")" & vbcrlf & "                         for(var i = 0 ; i < Spans.length ; i ++){" & vbcrlf & "                                       if(Spans[i].title==""彻底删除""){" & vbcrlf & "                                           oid = Spans[i].oid" &vbcrlf & "                                         bidArray[bidArray.length] = Spans[i].bid" & vbcrlf & "                                        }" & vbcrlf & "                               }" & vbcrlf & "                       }" & vbcrlf & "                       else{" & vbcrlf & "                           return" & vbcrlf & "                  }" & vbcrlf & "                       ajax.regEvent(""realdel"")" & vbcrlf & "                  ajax.addParam(""o"",oid)" & vbcrlf & "                    ajax.addParam(""i"",bidArray.join(""|""))" & vbcrlf & "                     ajax.exec();" & vbcrlf & "                    tvw.NodeClick();" & vbcrlf & "                }" & vbcrlf & "               </script>" & vbcrlf & "       </body>" & vbcrlf & " "
		end sub
		function RestoreTest(byval o,byval id, ByVal hasalert)
			If o = 31 Then
				RestoreTest = True : Exit Function
			elseif o=1004 Then
				Dim tj1 : tj1 = cn.execute("SELECT 1 FROM (select a.*,ar.UserID from HrKQ_AttendanceApply a" & vbcrlf &_
				"INNER JOIN dbo.HrKQ_AttendanceApplyRange ar ON a.ID = ar.ApplyID WHERE a.isdel = 0 ) g " & vbcrlf &_
				"INNER JOIN (select * from HrKQ_AttendanceApply b " & vbcrlf &_
				"INNER JOIN dbo.HrKQ_AttendanceApplyRange br ON b.ID = br.ApplyID where b.isdel = 1) f ON g.UserID = f.UserID " & vbcrlf &_
				"AND ( ( g.StartDate BETWEEN f.StartDate AND f.EndDate) " & vbcrlf &_
				"OR ( f.StartDate BETWEEN g.StartDate AND g.EndDate )) WHERE  f.ID = "& id &" ").eof=False
				Dim tj2 : tj2 = cn.execute("SELECT top 1 1  FROM dbo.HrKQ_AttendanceApply WHERE applytype=10 and id = "& id &" ").eof=False
				Dim tj3:tj3=cn.execute("select top 1 1 from HrKQ_TimeArrangeAdjustmentList tal" & vbcrlf &_
				"inner join dbo.HrKQ_TimeArrangeAdjustment ta on tal.TAID=ta.ID and ta.Status<>0" & vbcrlf &_
				"inner join dbo.HrKQ_AttendanceApplyRange ar on tal.UserID=ar.UserID" & vbcrlf &_
				"inner join dbo.HrKQ_AttendanceApply ap on ar.ApplyID=ap.ID" & vbcrlf &_
				"inner join dbo.HrKQ_AttendanceType at on at.OnlyID=ap.ApplyType" & vbcrlf &_
				"where (tal.AttendanceDate between CONVERT(varchar(100),ap.StartDate,23) and CONVERT(varchar(100),ap.EndDate,23))" & vbcrlf &_
				"and ((tal.AfterTimeArrange=999999 and at.AttTypeCls in(1,3))" & vbcrlf &_
				" or (tal.AfterTimeArrange!=999999 and at.AttTypeCls=2)" & vbcrlf &_
				")and ap.ID= "& id &" ").eof=False
				If tj1 Or tj2 or tj3 Then
					RestoreTest = false
				else
					RestoreTest = True
				end if
				Exit Function
			end if
			dim c , rs , fs , fitem , pfield ,sql , tb , pk
			set rs = cn.execute("select columnsetting as s,Maintable as t ,PKColumn as k  from M_OrderSettings where id=" & o)
			if rs.eof Then
				If hasalert Then app.alert "无法找到单据配置"
				RestoreTest = false
				rs.close
				exit function
			else
				c = rs.fields(0).value
				tb = rs.fields(1).value
				pk = rs.fields(2).value
				rs.close
			end if
			fs = split(c,"|")
			for i = 0 to ubound(fs)
				fitem = split(replace(fs(i),",",";"),";")
				if ubound(fitem) >10 then
					if len(trim(fitem(11))) > 0 then
						pfield = fitem(1)
						exit for
					end if
				end if
			next
			if len(pfield) = 0 then
				RestoreTest = true
				exit function
			end if
			If o >=12 And o<=15 Then
				sql  = "select a." & pfield & " from " & tb & " a , (select " & pfield & ", ordertype from " & tb & " where " & pk & "=" & id & ") b where a." & pfield & "=b." & pfield  & " and a.ordertype=b.ordertype and a." & pk & " <> " & id & " and del=0"
			ElseIf o=17 Or o=27 Then
				sql  = "select a." & pfield & " from " & tb & " a , (select " & pfield & ", qtype from " & tb & " where " & pk & "=" & id & ") b where a." & pfield & "=b." & pfield  & " and a.qtype=b.qtype and a." & pk & " <> " & id & " and del=0"
			else
				sql  = "select a." & pfield & " from " & tb & " a , (select " & pfield & " from " & tb & " where " & pk & "=" & id & " and " & pfield & ">0) b where a." & pfield & "=b." & pfield  & " and a." & pk & " <> " & id & " and del=0"
			end if
			set rs = cn.execute(sql)
			RestoreTest =  rs.eof
			rs.close
			if RestoreTest = false then
				If hasalert Then  app.alert "提示您：该单据所对应的上级单据已经被占用，所以无法恢复。"
			end if
		end function
		sub App_callRestore
			dim o , id , rs
			o = rtrim(request.form("o"))
			id = rtrim(request.form("i"))
			if len(o) = 0 or len(id) = 0 then
				app.alert "没有要恢复的数据"
				exit sub
			end if
			if not isnumeric(o)  or not isnumeric(id) then
				app.alert "没有要恢复的数据。"
				exit sub
			end if
			if not RestoreTest(o,id, true) then
				exit sub
			end if
			Set rs = cn.execute("exec erp_bill_parentBill_All " &  o & "," & id & "," & app.Info.user)
			rs.Filter = "oid>0 and del=1"
			If rs.eof = False Then
				rs.close
				app.alert "该单据前面流程关联的单据已经删除，所以无法恢复。"
				Exit sub
			end if
			rs.close
			cn.cursorlocation = 3
			cn.begintrans
			set rs = cn.execute("exec erp_bill_restore " &  o & "," & id)
			if not rs.eof then
				app.alert rs.fields(0).value
				Call SendReminds("CHECK,NEW,WORKINGFLOW",o,id)
			else
				app.alert "没有找到要恢复的数据。"
			end if
			if o="" or isnull(o) then o=0
			If o = 31 Then
				ordername = "设计中心"
			elseIf o = 1004 Then
				ordername = "申请管理"
				Dim tj3:tj3=cn.execute("select top 1 1 from HrKQ_TimeArrangeAdjustmentList tal" & vbcrlf &_
				"inner join dbo.HrKQ_TimeArrangeAdjustment ta on tal.TAID=ta.ID and ta.Status<>0" & vbcrlf &_
				"inner join dbo.HrKQ_AttendanceApplyRange ar on tal.UserID=ar.UserID" & vbcrlf &_
				"inner join dbo.HrKQ_AttendanceApply ap on ar.ApplyID=ap.ID" & vbcrlf &_
				"inner join dbo.HrKQ_AttendanceType at on at.OnlyID=ap.ApplyType" & vbcrlf &_
				"where (tal.AttendanceDate between CONVERT(varchar(100),ap.StartDate,23) and CONVERT(varchar(100),ap.EndDate,23))" & vbcrlf &_
				"and ((tal.AfterTimeArrange=999999 and at.AttTypeCls in(1,3))" & vbcrlf &_
				" or (tal.AfterTimeArrange!=999999 and at.AttTypeCls=2)" & vbcrlf &_
				")and ap.ID= "& id &" ").eof=False
				If tj3 Then
					app.alert "申请当天已存在调班单"
				end if
			else
				sql7="SELECT ORDERname FROM M_OrderSettings WHERE id="&o
				set rs7=cn.execute(sql7)
				if not rs7.eof then
					ordername=rs7("ordername")
				end if
				set rs7=Nothing
			end if
			dim actinon1
			cn.committrans
			action1=ordername&"恢复"
			call app.add_log(2,action1)
		end sub
		Sub SendReminds(remindTypes,o_id,b_id)
			Dim sql,types,rs,i,helper
			types = Split(remindTypes,",")
			For i=0 To ubound(types)
				sql = "select * from reminderConfigs where MOrderSetting=" & o_id & " and MBusinessType='" & types(i) & "'"
				Set rs=cn.execute(sql)
				If rs.eof = False Then
					Set helper = CreateReminderHelper(cn,rs("id"),0)
					helper.dropRemindByOid(b_id)
					helper.appendRemind(b_id)
				end if
			next
		end sub
		sub App_realdel
			dim o , id , n
			o = rtrim(request.form("o"))
			id = rtrim(request.form("i"))
			if len(o) = 0 or len(id) = 0 then
				app.alert "没有要删除的数据"
				exit sub
			end if
			if not isnumeric(o)  or (not isnumeric(id) and instr(id,"|") =0) then
				app.alert "没有要删除的数据。"
				exit sub
			end if
			n = 0
			cn.execute "exec erp_bill_event_ondelete " &  o & ",'" & id & "'" , n
			if n > 0 then
				app.alert "删除成功。"
			else
				app.alert "没有找到要删除的数据。"
			end if
			if o="" or isnull(o) then o=0
			If o = 31 Then
				ordername = "设计中心"
			else
				sql7="SELECT ordername FROM M_OrderSettings WHERE id="&o
				set rs7=cn.execute(sql7)
				if not rs7.eof then
					ordername=rs7("ordername")
				end if
				set rs7=Nothing
			end if
			dim actinon1
			action1=ordername&"删除"
			call app.add_log(2,action1)
		end sub
		Sub App_Clist
			dim lvw , id  , rs , sql , keyfield , mtable , i,qxlb
			id = request.form("id")
			if len(id) = 0 or isnumeric(id) = 0 then
				Response.write "<center><span class=c_r style='font-size:12px'><br><br>请选择单据类型</span></center>"
'if len(id) = 0 or isnumeric(id) = 0 then
				exit sub
			end if
			set rs = cn.execute("select * from (select spsql,maintable,PKColumn,qxlb ,id from M_OrderSettings union all select 'select * from dbo.erp_list_design_fun(@uid,1)','design' , 'id' ,5029, 31 union all select 'select * from dbo.[erp_list_AttendanceApply_fun](@uid,0)','HrKQ_AttendanceApply' , 'id' ,80,1004) a where id=" & id)
			if rs.eof then
				Response.write "<center><span class=c_r style='font-size:12px'><br><br>请选择单据类型。</span></center>"
'if rs.eof then
				rs.close
				exit sub
			else
				sql = replace(trim(rs.fields("spsql").value & ""),"@uid,1","@uid,0")
				sql = replace(trim(sql & ""),"@now","'"& now() &"'")
				keyfield = rs.fields("PKColumn").value
				mtable = rs.fields("maintable").value
				qxlb = rs.fields("qxlb").value
				on error resume next
				Select Case id
				Case 31 :
				cn.execute "update " & mtable & " set tempsave=0 where del=2"
				Case 1004 :
				Case 5 :
				cn.execute "update " & mtable & " set tempsave=0 where del=1"
				sql = Replace(sql,"@indate_1","''")
				sql = Replace(sql,"@indate_2","''")
				sql = Replace(sql,"@title","''")
				sql = Replace(sql,"@BOMBH","''")
				sql = Replace(sql,"@cptitle","''")
				sql = Replace(sql,"@cpbh","''")
				sql = Replace(sql,"@cpxh","''")
				Case Else
				cn.execute "update " & mtable & " set tempsave=0 where del=1"
				End Select
				on error goto 0
				If id = "1001" Or id = "1002" or id = "1003" Then
					sql = "select a.* , (case when dbo.IsHrAppholiday_recovery(b.id)=0 then '&nbsp;<span onmouseover=linkEvent() onmouseout=linkEvent() class=link onclick=""callRestore(" & id & ",' + cast(b." & keyfield & " as varchar(20)) + ')"">恢复</span>' else '' end)+'<!--<a href=""readbill.asp?orderid=" & id & "&id=' + cast(b." & keyfield & " as varchar(20)) + '&distoolbutton=1"" target=""_blank"" >详情</a>-->&nbsp;<span onmouseover=linkEvent() onmouseout=linkEvent() class=link oid=" & id & " bid=' + cast(b." & keyfield & " as varchar(20)) +' onclick=""realdeletebill(" & id & ",' + cast(b." & keyfield & " as varchar(20)) + ')"" title=彻底删除>彻底删除</span>&nbsp;' as '操作' from (" & sql & ") a , " &   mtable & " b where a." &  keyfield & "=b." & keyfield & " and b.del = 1 order by b." & keyfield & " desc "
'If id = "1001" Or id = "1002" or id = "1003" Then
				else
					if len(sql) = 0 then  sql = "select " & keyfield & " , " & keyfield & " as 单号 from " & mtable
					sql = "select a.* , '&nbsp;<span onmouseover=linkEvent() onmouseout=linkEvent() class=link onclick=""callRestore(" & id & ",' + cast(b." & keyfield & " as varchar(20)) + ')"">恢复</span><!--<a href=""readbill.asp?orderid=" & id & "&id=' + cast(b." & keyfield & " as varchar(20)) + '"&"distoolbutton=1""target=""_blank"" >详情</a>-->&nbsp;<span onmouseover=linkEvent() onmouseout=linkEvent() class=link oid= & id &  bid=' + cast(b. & keyfield &  as varchar(20)) +' onclick=""realdeletebill( & id & ,' + cast(b. & keyfield &  as varchar(20)) + ')"" title=彻底删除>彻底删除</span>&nbsp;' as '操作' from ( &sql & """") a , " &   mtable & " b where a." &  keyfield & "=b." & keyfield & " "
					If id = 31 Then
						sql = sql & " and b.del = 2 "
					elseIf id = 1004 Then
						sql = sql & " and b.isdel = 1 "
					else
						sql = sql & " and b.del = 1 "
					end if
					sql = sql & " order by b." & keyfield & " desc "
				end if
				rs.close
			end if
			set lvw = new listview
			lvw.pagesize = 20
			lvw.sql = replace(replace(replace(sql,"@uid",app.info.user),"@oid",id),"@qxlb",qxlb)
			lvw.visiblecol = 7
			lvw.border = 0
			lvw.dbcheckbox = True
			lvw.id = "list_" & id
			Set cItem = lvw.GetHeadByName("操作")
			cItem.colReplaceButton  = False
			cItem.cookiewidth = "90"
			citem.resize = false
			for i = 1 to lvw.cols.count
				if instr(1,lvw.cols.items(i).dbname,"#hide_",1) = 1 then
					lvw.cols.items(i).htmlvisible = False
					lvw.cols.items(i).colReplaceButton  = False
					lvw.cols.items(i).ywname = replace(lvw.cols.items(i).dbname,"#hide_","",1,-1,1)
					lvw.cols.items(i).colReplaceButton  = False
				end if
				if instr(lvw.cols.items(i).dbname,"#Fixed_") = 1 then
					lvw.cols.items(i).colReplaceButton  = False
					lvw.cols.items(i).resize = false
					lvw.cols.items(i).ywname = replace(lvw.cols.items(i).dbname,"#Fixed_","",1,-1,1)
					lvw.cols.items(i).resize = false
				end if
			next
			Set cItem = lvw.GetHeadByName(keyfield)
			cItem.htmlvisible = false
			lvw.pagetype = "database"
			lvw.autosum = false
			Response.write lvw.innerHTML
			Response.write "<rsCount>" & lvw.RecordCount & "</rsCount>"
			if id="" or isnull(id) then id=0
			If id = 31 Then
				ordername = "设计中心"
			else
				sql7="SELECT ordername FROM M_OrderSettings WHERE id="&id
				set rs7=cn.execute(sql7)
				if not rs7.eof then
					ordername=rs7("ordername")
				end if
				set rs7=Nothing
			end if
			dim actinon1
			close_dbconn=1
			action1=ordername&"回收站"
			call app.add_log(1,action1)
		end sub
		Sub App_OnCellValueWrite(ByVal lvw, ByVal col, ByVal rs, ByRef vvv)
			if col.dbname = "操作" Then
				Dim oid, bid
				oid = Mid(lvw.id,6)
				bid = rs("ID").value
				If RestoreTest(oid, bid, false) = False Then
					vvv = Replace(vvv,"onclick=""callRestore","onclick=""return false;callRestore",1,1,1)
					vvv = Replace(vvv,"onmouseover=linkEvent() onmouseout=linkEvent() class=link","class=link style='color:#C0C0C0' disabled title='无法恢复' ",1,1,1)
				end if
			end if
		end sub
		Sub App_OnLvwCreateExcelBefore(ByRef lvw)
			Dim cItem
			Set cItem = lvw.GetHeadByName("操作")
			cItem.htmlvisible = false
		end sub
		
%>
