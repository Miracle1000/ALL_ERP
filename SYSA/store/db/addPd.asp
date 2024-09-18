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
	call ProxyUserCheck()
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
			'Response.write "" & vbcrlf & "//<!--" & vbcrlf & "window.location.href = ""../../index2.asp""" & vbcrlf & "//--><script>window.location.href = ""../../index2.asp""</script>" & vbcrlf & ""
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
				"<span style='width:18px;text-align:center;display:inline-block'>" & _
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
					'cols.items(i).visible = 0
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
					"</td><td class='ctl_lvwaddrowlk' onmousemove='Bill.showunderline(this)' onmouseout='Bill.hideunderline(this)' nowrap>添加新行</td></tr></table>","") & "</td>")
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
					oid = oids(ubound(oids))
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
			Response.write xlstitle
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
					ywnames(i) = rs.fields(i).name
				end if
				If  Not visible(i) then
					fCount = fCount - 1
'If  Not visible(i) then
				end if
			next
			Response.write "" & vbcrlf & "                     <tr>" & vbcrlf & "                            <td>&nbsp;</td><td colspan='"
			Response.write fCount
			Response.write "' align=center class='title' style='border-bottom:1px solid #000'>"
			Response.write fCount
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
		
		ZBRLibDLLNameSN = "ZBRLib3205"
		Sub noCache
			Response.ExpiresAbsolute = #2000-01-01#
'Sub noCache
			Response.AddHeader "pragma", "no-cache"
'Sub noCache
			Response.AddHeader "cache-control", "private, no-cache, must-revalidate"
'Sub noCache
		end sub
		Sub echo(Byval str)
			Response.write(str)
			response.Flush()
		end sub
		Sub die(Byval str)
			if not isNul(str) then
				echo str
			end if
			call db_close : Response.end()
		end sub
		Function IsNum(Str)
			IsNum=False
			If Str<>"" then
				If RegTest(Str,"^[\d]+$")=True Then
'If Str<>"" then
					IsNum=True
				end if
			end if
		end function
		Function IsMoney(Str)
			IsMoney=False
			If Str<>"" then
				If RegTest(Str,"^[\d]+\.?[\d]+?$")=True Then
'If Str<>"" then
					IsMoney=True
				end if
			end if
		end function
		Function IsNegMoney(Str)
			IsNegMoney=False
			If Str<>"" then
				If RegTest(Str,"^\-[\d]+\.?[\d]+?$")=True Then
'If Str<>"" then
					IsNegMoney=True
				end if
			end if
		end function
		Function isNul(Byval str)
			if isnull(str) then
				isNul = true : exit function
			else
				if isarray(str) then isNul = false : exit function
				if str= "" then
					isNul = true : exit function
				else
					isNul = false : exit function
				end if
			end if
		end function
		Sub closers(byval rsobj)
			if isobject(rsobj) then
				rsobj.close
				set rsobj =nothing
			end if
		end sub
		Function getrsval(Byval sqlstr)
			dim rs
			set rs = conn.execute (sqlstr)
			if rs.eof then
				getrsval = ""
			else
				If isnumeric(rs(0)) Then
					getrsval = zbcdbl(rs(0))
				else
					getrsval = rs(0)
				end if
			end if
			call closers(rs)
		end function
		Function getrs(Byval sqlstr)
			set getrs = server.CreateObject("adodb.recordset")
			getrs.open sqlstr ,conn,1,3
		end function
		Function getrsArray(Byval sqlstr)
			set rsobj = getrs(sqlstr)
			if not rsobj.eof then
				getrsArray = rsobj.getrows
			end if
			call closers(rsobj)
		end function
		Function closeconn
			if isobject(conn) then
				conn.close
				set conn =nothing
			end if
		end function
		Function jsStr(Byval str)
			jsStr = "<script language=""JavaScript"" type=""text/javascript"">"&str&"</script>"
		end function
		Function alert(Byval str)
			alert = jsStr("alert("""&str&""")")
		end function
		Function alertgo(Byval str,Byval url)
			alertgo = alert(str)&jsStr("location.href="""&url&"""")
		end function
		Function confirm(Byval str,Byval url1,Byval url2)
			confirm = jsstr("if(confirm("""&str&""")){location.href="""&url1&"""}else{location.href="""&url2&"""}")
		end function
		Function jsPageGo(Byval page)
			if isnumeric(page) then
				jsPageGo = jsStr("history.go("&page&")")
			else
				jsPageGo = jsStr("location.href="""&page&"""")
			end if
		end function
		Function Historyback(msg)
			Historyback=JavaScriptSet("alert('"& msg &"');history.go(-1)")
'Function Historyback(msg)
		end function
		Function jspageback
			jspageback = jsPageGo(-1)
'Function jspageback
		end function
		Function JavaScriptSet(str)
			JavaScriptSet = "<script language=""JavaScript"" type=""text/javascript"">"&str&"</script>"
		end function
		function CloseSelf(msg)
			CloseSelf=JavaScriptSet("try{alert('"&Replace(msg,"'","")&"'); window.opener=null;window.open('','_self');window.close();}catch(e){}")
		end function
		function ReloadCloseSelf(msg)
			ReloadCloseSelf=JavaScriptSet("alert('"&Replace(msg,"'","")&"'); try{window.opener.location.reload();}catch(e1){} try{window.opener=null;window.open('','_self');window.close();}catch(e){}")
		end function
		function strLength(str)
			on error resume next
			dim WINNT_CHINESE
			WINNT_CHINESE    = (len("中国")=2)
			if WINNT_CHINESE then
				dim l,t,c
				dim i
				l=len(str)
				t=l
				for i=1 to l
					c=asc(mid(str,i,1))
					if c<0 then c=c+65536
'c=asc(mid(str,i,1))
					if c>255 then
						t=t+1
'if c>255 then
					end if
				next
				strLength=t
			else
				strLength=len(str)
			end if
			if err.number<>0 then err.clear
		end function
		function checkphone(str,num_code)
			dim arr_num,tmpnum,tmparr,areacode
			dim i
			if trim(str)="" or isnull(str) then exit function
			str=replace(replace(str,"/","-"),"\","-")
'if trim(str)="" or isnull(str) then exit function
			arr_num=split(str,"-")
'if trim(str)="" or isnull(str) then exit function
			tmpnum=""
			for i=0 to ubound(arr_num)
				tmparr=arr_num(i)
				if i=0 then
					if left(tmparr,1)="0" and (len(tmparr)=3 or len(tmparr)=4) then
						areacode=tmparr
					else
						tmpnum=tmparr
					end if
				else
					if left(tmparr,3)="400" or left(tmparr,3)="800" then
						areacode=""
					elseif left(str,1)="1" and len(str)=11 then
						areacode=""
					end if
					if tmpnum="" then
						tmpnum=tmparr
					else
						tmpnum=tmpnum & "-" & tmparr
					end if
				end if
			next
			if areacode=num_code then areacode=""
			checkphone=areacode & tmpnum
		end function
		function strFreMobil(strMobil)
			strFreMobil=""
			Set rs = server.CreateObject("adodb.recordset")
			for i=4 to 11
				sql="select areacode  from MOBILEAREA where shortno like ''+substring('"&strMobil&"', 1, "&i&")+'%'"
'for i=4 to 11
				rs.open sql,conn,3,1
				if not rs.eof then
					if rs.recordcount=1 then
						strFreMobil=rs("areacode")
						rs.close
						exit for
					else
						strFreMobil=""
					end if
				else
					strFreMobil=""
				end if
				rs.close
			next
			set rs=nothing
		end function
		function fenjiNum(StrNum)
			StrNum=replace(StrNum,"-",",,,,,,,,,,")
'function fenjiNum(StrNum)
			fenjiNum=StrNum
		end function
		function unfenjiNum(StrNum)
			StrNum=replace(StrNum,",,,,,,,,,,","-")
'function unfenjiNum(StrNum)
			unfenjiNum=StrNum
		end function
		Function RegTest(a,p)
			Dim reg
			RegTest=false
			Set reg = New RegExp
			reg.pattern=p
			reg.IgnoreCase = True
			If reg.test(a)Then
				RegTest=true
			else
				RegTest=false
			end if
		end function
		Function RegReplace(s,p,strReplace)
			Dim r
			Set r =New RegExp
			r.Pattern = p
			r.IgnoreCase = True
			r.Global = True
			RegReplace=r.replace(s,strReplace)
		end function
		Function GetRegExpCon(strng,patrn)
			Dim regEx, Match, Matches,RetStr
			RetStr=""
			Set regEx = New RegExp
			regEx.Pattern = patrn          ' 设置模式。'"\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
'Set regEx = New RegExp
			regEx.IgnoreCase = True
			regEx.Global = True
			Set Matches = regEx.Execute(strng)
			For Each Match In Matches
				if RetStr="" then
					RetStr=Match.Value
				else
					RetStr=RetStr&"$"&Match.Value
				end if
			next
			GetRegExpCon = RetStr
		end function
		function unPhone(StrNum)
			sqlci = "select callPreNum from gate where ord="&session("personzbintel2007")&""
			Set Rsci = server.CreateObject("adodb.recordset")
			Rsci.open sqlci,conn,1,1
			num_pre1=rsci("callPreNum")
			rsci.close
			set rsci=nothing
			if num_pre1<>"" then
				StrNum=RegReplace(StrNum,"^"&num_pre1&",","")
			end if
			if  RegTest(StrNum,"^0(13[0-9]|14[0-9]|15[^4]|17[0-9]|18[0-9])\d{8}$") then
				StrNum=RegReplace(StrNum,"^"&num_pre1&",","")
				StrNum=RegReplace(StrNum,"^0","")
			end if
			StrNum=unfenjiNum(StrNum)
			unPhone=StrNum
		end function
		sub strCheckBH(bhid,table,strBhID,str)
			if strBhID<>"" then
				Err.Clear
				set rs=server.CreateObject("adodb.recordset")
				sqlStr="select "&bhid&" from "&table&" where del<>7 and "&bhid&"='"&strBhID&"'"
				rs.open sqlStr,conn,1,1
				if not rs.eof then
					Response.write"<script language=javascript>alert('该"&str&"编号已存在！请返回重试');window.history.back(-1);</script>"
'if not rs.eof then
					call db_close : Response.end
				end if
				rs.close
				set rs=nothing
			end if
		end sub
		function getPersonSex(nameX,sexX)
			getPersonSex=""
			if nameX<>"" and sexX<>"" then
				if sexX="男" then
					getPersonSex=left(nameX,1)&"先生"
				elseif sexX="女" then
					getPersonSex=left(nameX,1)&"小姐"
				else
					getPersonSex=nameX
				end if
			else
				getPersonSex=nameX
			end if
		end function
		function getPersonJob(nameX,jobX)
			getPersonJob=""
			if nameX<>"" and jobX<>"" then
				if jobX<>"" then
					getPersonJob=left(nameX,1)&jobX
				else
					getPersonJob=nameX
				end if
			else
				getPersonJob=nameX
			end if
		end function
		function getNameJob(nameX,jobX)
			getNameJob=""
			if nameX<>"" and jobX<>"" then
				if jobX<>"" then
					getNameJob=nameX&jobX
				else
					getNameJob=nameX
				end if
			else
				getNameJob=nameX
			end if
		end function
		function isMobile(num1)
			isMobile=false
			if num1<>"" then
				isMobile=RegTest(num1,"^(13[0-9]|14[0-9]|15[^4]|16[0-9]|17[0-9]|18[0-9]|19[0-9])\d{8}$")
'if num1<>"" then
			else
				isMobile=false
			end if
		end function
		function myReplace(fString)
			myString=""
			if fString<>"" then
				myString=Replace(fString,"&","&amp;")
				myString=Replace(myString,"<","&lt;")
				myString=Replace(myString,">","&gt;")
				myString=Replace(myString,"&nbsp;","")
				myString=Replace(myString,chr(13),"")
				myString=Replace(myString,chr(10),"")
				myString=Replace(myString,chr(32),"&nbsp")
				myString=Replace(myString,chr(9),"")
				myString=Replace(myString,chr(39),"")
				myString=Replace(myString,chr(34),"&quot;")
				myString=Replace(myString,chr(8),"")
				myString=Replace(myString,chr(11),"")
				myString=Replace(myString,chr(12),"")
				myString=Replace(myString,Chr(32),"")
				myString=Replace(myString,Chr(26),"")
				myString=Replace(myString,Chr(27),"")
			end if
			myReplace=myString
		end function
		Function RemoveHTML(strHTML)
			Dim objRegExp, Match, Matches
			Set objRegExp = New Regexp
			objRegExp.IgnoreCase = True
			objRegExp.Global = True
			objRegExp.Pattern = "<.+?>"
'objRegExp.Global = True
			Set Matches = objRegExp.Execute(strHTML)
			For Each Match in Matches
				strHtml=Replace(strHTML,Match.Value,"")
			next
			RemoveHTML=strHTML
			Set objRegExp = Nothing
		end function
		Function getTitle(str,byVal lens)
			if isnull(str) then getTitle="":exit function
			if str="" then
				getTitle="":exit function
			else
				dim str1
				str1=str
				str1=RemoveHTML(str1)
				if len(str1)=0 and len(str)>0 then str1="."
				if str1<>"" then
					str1=myReplace(str1)
					if str1<>"" then str1=replace(replace(replace(replace(replace(replace(str1,"&amp;nbsp;",""),"&amp;quot;",""),"&amp;amp;",""),"&amp;lt;",""),"&amp;gt;",""),"&nbsp","")
					if len(str)>lens then
						str1=left(str1,lens)&"."
					else
						str1=left(str1,lens)
					end if
				end if
				getTitle=str1
			end if
		end function
		Function getFirstName(str)
			getFirstName=""
			if str<>"" then
				strXing="欧阳|太史|端木|上官|司马|东方|独孤|南宫|万俟|闻人|夏侯|诸葛|尉迟|公羊|赫连|澹台|皇甫|宗政|濮阳|公冶|太叔|申屠|公孙|慕容|仲孙|钟离|长孙|宇文|司徒|鲜于|司空|闾丘|子车|亓官|司寇|巫马|公西|颛孙|壤驷|公良|漆雕|乐正|宰父|谷梁|拓跋|夹谷|轩辕|令狐|段干|百里|呼延|东郭|南门|羊舌|微生|公户|公玉|公仪|梁丘|公仲|公上|公门|公山|公坚|左丘|公伯|西门|公祖|第五|公乘|贯丘|公皙|南荣|东里|东宫|仲长|子书|子桑|即墨|达奚|褚师|吴铭"
				if instr(strXing,left(str,2))>0 then
					getFirstName=left(str,2)
				else
					getFirstName=left(str,1)
				end if
			else
				getFirstName=""
			end if
		end function
		Function NongliMonth(m)
			If m>=1 And m<=12 Then
				MonthStr=",正,二,三,四,五,六,七,八,九,十,十一,腊"
				MonthStr=Split(MonthStr,",")
				NongliMonth=MonthStr(m)
			else
				NongliMonth=m
			end if
		end function
		Function NongliDay(d)
			If d>=1 And d<=30 Then
				DayStr=",初一,初二,初三,初四,初五,初六,初七,初八,初九,初十,十一,十二,十三,十四,十五,十六,十七,十八,十九,二十,廿一,廿二,廿三,廿四,廿五,廿六,廿七,廿八,廿九,三十"
				DayStr=Split(DayStr,",")
				NongliDay=DayStr(d)
			else
				NongliDay=d
			end if
		end function
		Function htmlspecialchars(str)
			if len(str&"") = 0 then
				exit function
			end if
			str = Replace(str, "&", "&amp;")
			str = Replace(str, "&amp;#", "&#")
			str = Replace(str, "<", "&lt;")
			str = Replace(str, ">", "&gt;")
			str = Replace(str, """", "&quot;")
			htmlspecialchars = str
		end function
		function isEmail(num1)
			isEmail=false
			if num1<>"" then
				isEmail=RegTest(num1,"^$|^(\w{0,10}\[)?\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*(\])?$")
'if num1<>"" then
				if isEmail=false then
					isEmail=RegTest(num1,"^$|^([a-zA-Z0-9_\u4e00-\u9fa5]+\[)?\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*(\])?\;(([a-zA-Z0-9_\u4e00-\u9fa5]+\[)?\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*(\])?)*$")
				end if
			else
				isEmail=false
			end if
		end function
		function isobjinstalled(strclassstring)
			on error resume next
			isobjinstalled = false
			err = 0
			dim xtestobj
			set xtestobj = server.createobject(strclassstring)
			if 0 = err then isobjinstalled = true
			set xtestobj = nothing
			err = 0
		end function
		function DelAttach(sql_at)
			set rs_At=server.CreateObject("adodb.recordset")
			rs_At.open sql_at, conn,1,1
			if not rs_At.eof then
				FileName_At=server.MapPath(rs_At(0))
				set fso_At=server.CreateObject("scripting.filesystemobject")
				if fso_At.FileExists(FileName_At) then
					fso_At.DeleteFile FileName_At
				end if
				set fso_At=nothing
			end if
			rs_At.close
			set rs_At=nothing
		end function
		function DelAllAttach(sql_at)
			set rs_At=server.CreateObject("adodb.recordset")
			rs_At.open sql_at, conn,1,1
			if not rs_At.eof then
				do while not rs_At.eof
					FileName_At=server.MapPath(rs_At(0))
					set fso_At=server.CreateObject("scripting.filesystemobject")
					if fso_At.FileExists(FileName_At) then
						fso_At.DeleteFile FileName_At
					end if
					set fso_At=nothing
					rs_At.movenext
				loop
			end if
			rs_At.close
			set rs_At=nothing
		end function
		function getGateName(id)
			getGateName=""
			if id<>"" and isnumeric(id) then
				set rs_Gate=server.CreateObject("adodb.recordset")
				sql_Gate="select name from gate where  ord="&id&""
				rs_Gate.open sql_Gate,conn,1,1
				if not rs_Gate.eof then
					getGateName=rs_Gate("name")
				end if
				rs_Gate.close
				set rs_Gate=nothing
			end if
		end function
		function getSorceName(id)
			getSorceName="无"
			if id<>"" and isnumeric(id) then
				set rs_Gate=server.CreateObject("adodb.recordset")
				sql_Gate="select sort1 from gate1 where  ord="&id&""
				rs_Gate.open sql_Gate,conn,1,1
				if not rs_Gate.eof then
					getSorceName=rs_Gate("sort1")
				end if
				rs_Gate.close
				set rs_Gate=nothing
			end if
		end function
		function getSorce2Name(id)
			getSorce2Name="无"
			if id<>"" and isnumeric(id) then
				set rs_Gate=server.CreateObject("adodb.recordset")
				sql_Gate="select sort2 from gate2 where  ord="&id&""
				rs_Gate.open sql_Gate,conn,1,1
				if not rs_Gate.eof then
					getSorce2Name=rs_Gate("sort1")
				end if
				rs_Gate.close
				set rs_Gate=nothing
			end if
		end function
		function getUidSorceName(id)
			getUidSorceName="无"
			if id<>"" and isnumeric(id) then
				set rs_Gate=server.CreateObject("adodb.recordset")
				sql_Gate="select a.sort1 from gate1 a inner join gate b on a.ord=b.sorce where  b.ord="&id&" "
				rs_Gate.open sql_Gate,conn,1,1
				if not rs_Gate.eof then
					getUidSorceName=rs_Gate("sort1")
				end if
				rs_Gate.close
				set rs_Gate=nothing
			end if
		end function
		function getUidSorce2Name(id)
			getUidSorce2Name="无"
			if id<>"" and isnumeric(id) then
				set rs_Gate=server.CreateObject("adodb.recordset")
				sql_Gate="select a.sort2 from gate2 a inner join gate b on a.ord=b.sorce2 where  b.ord="&id&" "
				rs_Gate.open sql_Gate,conn,1,1
				if not rs_Gate.eof then
					getUidSorce2Name=rs_Gate("sort2")
				end if
				rs_Gate.close
				set rs_Gate=nothing
			end if
		end function
		function TbCompanyName(id)
			TbCompanyName=""
			if id<>"" and isnumeric(id) then
				set rs_Gate=server.CreateObject("adodb.recordset")
				sql_Gate="select name from tel where  ord="&id&""
				rs_Gate.open sql_Gate,conn,1,1
				if not rs_Gate.eof then
					TbCompanyName=rs_Gate("name")
				end if
				rs_Gate.close
				set rs_Gate=nothing
			end if
		end function
		function TbPersonName(id)
			TbPersonName=""
			if id<>"" and isnumeric(id) then
				set rs_Gate=server.CreateObject("adodb.recordset")
				sql_Gate="select name from person where  ord="&id&""
				rs_Gate.open sql_Gate,conn,1,1
				if not rs_Gate.eof then
					TbPersonName=rs_Gate("name")
				end if
				rs_Gate.close
				set rs_Gate=nothing
			end if
		end function
		function zbintelEmailEncode(inputstr,inputtype,rdNum)
			tmpstr=""
			if inputtype=1 then
				for i=1 to len(inputstr)
					tmpstr=tmpstr&emailgetChar(mid(inputstr,i,1),inputtype,rdNum)
				next
			else
				inputstr=replace(inputstr,"%","$")
				inputstr=replace(inputstr,"*","$")
				inputstr=replace(inputstr,"#","$")
				inputstr=replace(inputstr,"@","$")
				inputstr=replace(inputstr,"a","$")
				inputstr=replace(inputstr,"b","$")
				inputstr=replace(inputstr,"c","$")
				inputstr=replace(inputstr,"d","$")
				inputstr=replace(inputstr,"e","$")
				inputstr=replace(inputstr,"f","$")
				inputstr=replace(inputstr,"g","$")
				inputstr=replace(inputstr,"h","$")
				inputstr=replace(inputstr,"i","$")
				inputstr=replace(inputstr,"j","$")
				inputstr=replace(inputstr,"k","$")
				inputstr=replace(inputstr,"l","$")
				inputstr=replace(inputstr,"m","$")
				inputstr=replace(inputstr,"n","$")
				if instr(inputstr,"$")>0 then
					arrStr=split(inputstr,"$")
					for i=0 to Ubound(arrStr)-1
						arrStr=split(inputstr,"$")
						Response.write(arrStr(i)&"<br/>")
						tmpstr=tmpstr&Chr(arrStr(i)-rdNum)
						Response.write(arrStr(i)&"<br/>")
					next
				end if
			end if
			zbintelEmailEncode=tmpstr
		end function
		function emailgetChar(inputchar,chartype,rdNum)
			if inputchar<>"" then
				emailgetChar=(asc(inputchar)+rdNum)&randomStr(1)
'if inputchar<>"" then
			else
				emailgetChar=""
			end if
		end function
		Function randomStr(intLength)
			strSeed = "$%*#@abcdefghijklmn"
			seedLength = Len(strSeed)
			Str = ""
			Randomize
			For i = 1 To intLength
				Str = Str + Mid(strSeed, Int(seedLength * Rnd) + 1, 1)
'For i = 1 To intLength
			next
			randomStr = Str
		end function
		function urldecode(encodestr)
			newstr=""
			havechar=false
			lastchar=""
			for i=1 to len(encodestr)
'char_c=mid(encodestr,i,1)
				if char_c="+" then
					char_c=mid(encodestr,i,1)
					newstr=newstr & " "
				elseif char_c="%" then
					next_1_c=mid(encodestr,i+1,2)
'elseif char_c="%" then
					next_1_num=cint("&H" & next_1_c)
					if havechar then
						havechar=false
						newstr=newstr & chr(cint("&H" & lastchar & next_1_c))
					else
						if abs(next_1_num)<=127 then
							newstr=newstr & chr(next_1_num)
						else
							havechar=true
							lastchar=next_1_c
						end if
					end if
					i=i+2
					lastchar=next_1_c
				else
					newstr=newstr & char_c
				end if
			next
			urldecode=newstr
		end function
		function UTF2GB(UTFStr)
			if instr(UTFStr,"%")>0 then
				for Dig=1 to len(UTFStr)
					if mid(UTFStr,Dig,1)="%" then
						if len(UTFStr) >= Dig+8 then
'if mid(UTFStr,Dig,1)="%" then
							GBStr=GBStr & ConvChinese(mid(UTFStr,Dig,9))
							Dig=Dig+8
							GBStr=GBStr & ConvChinese(mid(UTFStr,Dig,9))
						else
							GBStr=GBStr & mid(UTFStr,Dig,1)
						end if
					else
						GBStr=GBStr & mid(UTFStr,Dig,1)
					end if
				next
				UTF2GB=GBStr
			else
				UTF2GB=UTFStr
			end if
			if UTF2GB="" then UTF2GB=UTFStr
		end function
		function ConvChinese(x)
			A=split(mid(x,2),"%")
			i=0
			j=0
			for i=0 to ubound(A)
				A(i)=c16to2(A(i))
			next
			for i=0 to ubound(A)-1
				A(i)=c16to2(A(i))
				DigS=instr(A(i),"0")
				Unicode=""
				for j=1 to DigS-1
					Unicode=""
					if j=1 then
						A(i)=right(A(i),len(A(i))-DigS)
'if j=1 then
						Unicode=Unicode & A(i)
					else
						i=i+1
						Unicode=Unicode & A(i)
						A(i)=right(A(i),len(A(i))-2)
'Unicode=Unicode & A(i)
'Unicode=Unicode & A(i)
					end if
				next
				if len(c2to16(Unicode))=4 then
					ConvChinese=ConvChinese & chrw(int("&H" & c2to16(Unicode)))
				else
					ConvChinese=ConvChinese & chr(int("&H" & c2to16(Unicode)))
				end if
			next
		end function
		function c2to16(x)
			i=1
			for i=1 to len(x) step 4
				c2to16=c2to16 & hex(c2to10(mid(x,i,4)))
			next
		end function
		function c2to10(x)
			c2to10=0
			if x="0" then exit function
			i=0
			for i= 0 to len(x) -1
				i=0
				if mid(x,len(x)-i,1)="1" then c2to10=c2to10+2^(i)
				i=0
			next
		end function
		function c16to2(x)
			i=0
			for i=1 to len(trim(x))
				tempstr= c10to2(cint(int("&h" & mid(x,i,1))))
				do while len(tempstr)<4
					tempstr="0" & tempstr
				loop
				c16to2=c16to2 & tempstr
			next
		end function
		function c10to2(x)
			mysign=sgn(x)
			x=abs(x)
			DigS=1
			do
				if x<2^DigS then
					exit do
				else
					DigS=DigS+1
					exit do
				end if
			loop
			tempnum=x
			i=0
			for i=DigS to 1 step-1
				i=0
				if tempnum>=2^(i-1) then
					i=0
					tempnum=tempnum-2^(i-1)
					i=0
					c10to2=c10to2 & "1"
				else
					c10to2=c10to2 & "0"
				end if
			next
			if mysign=-1 then c10to2="-" & c10to2
			c10to2=c10to2 & "0"
		end function
		Function checkFolder(folderpath)
			If CheckDir(folderpath) = false Then
				MakeNewsDir(folderpath)
			end if
		end function
		Function CheckDir(FolderPath)
			folderpath=Server.MapPath(".")&"\"&folderpath
			Set fso= CreateObject("Scripting.FileSystemObject")
			If fso.FolderExists(FolderPath) then
				CheckDir = True
			else
				CheckDir = False
			end if
			Set fso= nothing
		end function
		Function MakeNewsDir(foldername)
			dim fs0
			Set fso= CreateObject("Scripting.FileSystemObject")
			Set fs0= fso.CreateFolder(foldername)
			Set fso = nothing
		end function
		sub jsBack(str)
			Response.write("<script language='javascript' type='text/javascript'>alert('"&str&"');history.back()</script>")
			call db_close : Response.end
		end sub
		sub jsLocat(str,url)
			Response.write("<script language='javascript' type='text/javascript'>alert('"&str&"');window.location.href='"&url&"';</script>")
			call db_close : Response.end
		end sub
		sub jsLocat2(str,url)
			Response.write("<script language='javascript' type='text/javascript'>alert('"&str&"');window.parent.location.href='"&url&"';</script>")
			call db_close : Response.end
		end sub
		sub jsAlert(msg)
			Response.write("<script language='javascript' type='text/javascript'>alert('"& replace(msg,"'","\'") &"');</script>")
			on error resume next
			conn.close
			call db_close : Response.end
		end sub
		function DateZeros(str)
			if isnumeric(str) then
				if str<10 then
					DateZeros="0"&str
				else
					DateZeros=str
				end if
			else
				DateZeros=str
			end if
		end function
		Function CLngIP1(asNewIP)
			Dim lnResults
			Dim lnIndex
			Dim lnIpAry
			lnIpAry = Split(asNewIP, ".", 4)
			For lnIndex = 0 To 3
				If Not lnIndex = 3 Then lnIpAry(lnIndex) = lnIpAry(lnIndex) * (256 ^ (3 - lnIndex))
'For lnIndex = 0 To 3
				lnResults = lnResults * 1 + lnIpAry(lnIndex)
'For lnIndex = 0 To 3
			next
			if lnResults="" then lnResults=0
			CLngIP1 = lnResults
		end function
		Function CWebHost()
			serverUrl=Request.ServerVariables("Http_Host")
			CWebHost=false
			if RegTest(serverUrl,"^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*(\:[0-9]*)?\/*[0-9]*$") then
				CWebHost=false
				if instr(serverUrl,":")>0 then serverUrl=split(serverUrl,":")(0)
				if (CLngIP1(serverUrl)>=3232235520 and CLngIP1(serverUrl)<=3232301055) or (CLngIP1(serverUrl)>=167772160 and CLngIP1(serverUrl)<=184549375) or (CLngIP1(serverUrl)>=2130706432 and CLngIP1(serverUrl)<=2147483647) or CLngIP1(serverUrl)=0  then
					CWebHost=false
				else
					CWebHost=true
				end if
			else
				CWebHost=true
			end if
		end function
		sub checkMod(table,dataid,id,val)
			set rs9=server.CreateObject("adodb.recordset")
			sql="select "&dataid&" from "&table&" where  "&dataid&"="&id&" and ModifyStamp='"&val&"'"
			rs9.open sql,conn,1,1
			if  rs9.eof then
				call jsBack("此单据在您编辑过程中已有其他人进行了操作，请返回刷新重试！")
				call db_close : Response.end
			end if
			rs9.close
			set rs9=nothing
		end sub
		Function CheckLocalFileExist(ByVal file_dir)
			If Len(file_dir)=0 Then CheckLocalFileExist = False : Exit Function
			Dim fs : Set fs = Server.createobject(ZBRLibDLLNameSN & ".CommFileClass")
			CheckLocalFileExist = fs.ExistsFile(server.mappath(file_dir))
			Set fs = Nothing
		end function
		Function FormatTime(s_Time)
			Dim y, m, d
			FormatTime = ""
			if s_Time="" then Exit Function
			s_Time=replace(s_Time," ","")
			if instr(s_Time,"$")>0 then
				arr_time=split(s_Time,"$")
				for i=0 to ubound(arr_time)
					If IsDate(arr_time(i)) = False Then arr_time(i) = Date
					y = cstr(year(arr_time(i)))
					m = cstr(month(arr_time(i)))
					d = cstr(day(arr_time(i)))
					if timeList="" then
						timeList=y&"-"&m & "-" & d
'if timeList="" then
					else
						timeList=timeList&"$"&y&"-"&m & "-" & d
'if timeList="" then
					end if
				next
				FormatTime =timeList
			else
				If IsDate(s_Time) = False Then Exit Function
				y = cstr(year(s_Time))
				m = cstr(month(s_Time))
				d = cstr(day(s_Time))
				FormatTime =y&"-"&m & "-" & d
				d = cstr(day(s_Time))
			end if
		end function
		Function HrGetDateUnit(id)
			If id="" Then
				HrGetDateUnit =""
				Exit Function
			else
				select case id
				case 1
				HrGetDateUnit ="年"
				case 2
				HrGetDateUnit ="季"
				case 3
				HrGetDateUnit ="月"
				case 4
				HrGetDateUnit ="周"
				case 5
				HrGetDateUnit ="日"
				case else
				HrGetDateUnit =""
				end select
			end if
		end function
		function ReplaceSQL(str)
			if str<>"" and isnull(str)=false then
				str=trim(replace(str,"'","&#39"))
				str=trim(replace(str,"""","&#34"))
			end if
			ReplaceSQL=str
		end function
		function SaveRequestUrl(str)
			SaveRequestUrl=ReplaceSQL(request.QueryString(str))
		end function
		function SaveRequestForm(str)
			SaveRequestForm=ReplaceSQL(request.form(str))
		end function
		function SaveRequest(str)
			SaveRequest=ReplaceSQL(request(str))
		end function
		Function SaveRequestUrlNum(Str)
			Dim Num
			Num=ReplaceSQL(Request.QueryString(Str))
			If IsNum(Num)=False Then Num=0
			SaveRequestUrlNum=Num
		end function
		function RandomName()
			randomize
			RandomName=chr(int(rnd*26)+65)&chr(int(rnd*26)+65)&chr(int(rnd*26)+65)&chr(int(rnd*26)+65)&year(now)&month(now)&day(now)&second(now)&int(second(now)*rnd)+100
			randomize
		end function
		function GetFileEx(str)
			if instr(str,".")>0 then
				ArrStr=split(str,".")
				GetFileEx=ArrStr(ubound(ArrStr))
			else
				GetFileEx=""
			end if
		end function
		function TodayFolderName()
			TodayFolderName=year(now)&month(now)&day(now)
		end function
		function getGateBH(id)
			getGateBH=""
			if id<>"" and isnumeric(id) then
				set rsbh=server.CreateObject("adodb.recordset")
				sql="select  userbh  from hr_person where userID="&id&""
				rsbh.open sql,conn,1,1
				if not rsbh.eof then
					getGateBH=rsbh("userbh")
				end if
				rsbh.close
				set rsbh=nothing
			end if
		end function
		function GetFullSort(theTable,sortID,filed_id1, filed_sort1, filed_keyId, mark)
			if theTable&""<>"" then
				If sortID&"" = "" Then sortID = 0
				if filed_id1&"" = "" then filed_id1 = "id1"
				if filed_sort1&"" = "" then filed_sort1 = "sort1"
				if filed_keyId&"" = "" then filed_keyId = "id"
				if mark&"" = "" then mark = "-"
'if filed_keyId&"" = "" then filed_keyId = "id"
				dim rsf, rst, sortStr, id1, sort1
				sortStr=""
				Set rsf = conn.execute("select "& filed_id1 &","& filed_sort1 &" from "& theTable &" where "& filed_keyId &"=" & sortID)
				If rsf.Eof = False Then
					id1 = rsf(0)
					sort1 = TRIM(rsf(1))
					sortStr = sort1
					Dim sort_i
					For sort_i = 1 To 20
						Set rst=conn.execute("select "& filed_id1 &","& filed_sort1 &" from "& theTable &" where "& filed_keyId &"=" & id1)
						If rst.eof = true Then Exit For
						sortStr = TRIM(rst(1))& mark & sortStr
						id1 = rst(0)
						rst.Close
						Set rst = Nothing
					next
				end if
				rsf.Close
				Set rsf = Nothing
				GetFullSort = sortStr
			end if
		end function
		function formatNumB(numf,num1)
			if numf&""<>"" then
				if numf>1 then
					formatNumB = round(numf,num1)
				elseif numf>0 and numf<1 then
					numf2 = cstr(round(numf,num1))
					if left(numf2,1)="." then
						formatNumB = "0"& round(numf,num1)
					elseif left(numf2,2)="-." then
						formatNumB = "0"& round(numf,num1)
						formatNumB = "-0"& round(numf,num1)
						formatNumB = "0"& round(numf,num1)
					else
						formatNumB = round(numf,num1)
					end if
				else
					formatNumB = round(numf,num1)
				end if
			end if
		end function
		Function HTMLEncode(fString)
			if not isnull(fString) Then
				fString = replace(fString, ">", "&gt;")
				fString = replace(fString, "<", "&lt;")
				fString = Replace(fString, CHR(32), "&nbsp;")
				fString = Replace(fString, CHR(34), "&quot;")
				fString = Replace(fString, CHR(39), "&#39;")
				fString = Replace(fString, CHR(13) & CHR(10), "<br>")
				fString = Replace(fString, CHR(13), "<br>")
				fString = Replace(fString, CHR(10), "<br>")
				HTMLEncode = fString
			end if
		end function
		Function HTMLEncode2(fString)
			if not isnull(fString) Then
				fString = Replace(fString, CHR(32), "&nbsp;")
				fString = Replace(fString, CHR(34), "&quot;")
				fString = Replace(fString, CHR(39), "&#39;")
				fString = Replace(fString, CHR(13) & CHR(10), "<br>")
				fString = Replace(fString, CHR(13), "<br>")
				fString = Replace(fString, CHR(10), "<br>")
				HTMLEncode2 = fString
			end if
		end function
		Function HTMLDecode(fString)
			if not isnull(fString) Then
				fString = replace(fString, "&gt;", ">")
				fString = replace(fString, "&lt;", "<")
				fString = Replace(fString, "&nbsp;",CHR(32) )
				fString = Replace(fString, "&quot;",CHR(34) )
				fString = Replace(fString, "&#39;",CHR(39) )
				fString = Replace(fString, "<br>",CHR(13) & CHR(10))
				fString = Replace(fString, "<br>",CHR(13))
				fString = Replace(fString, "<br>",CHR(10))
				HTMLDecode = fString
			end if
		end function
		Function getKindsOfPrices(m_includeTax,priceValue,invoiceType)
			Dim pricesFun(2),rsFun,sqlFun
			pricesFun(0) = priceValue
			pricesFun(1) = priceValue
			pricesFun(2) = priceValue
			getKindsOfPrices = pricesFun
			If Len(Trim(invoiceType)&"")="0" Or invoiceType = 0 then
				sqlFun = "select b.* from sortonehy a,invoiceConfig b where b.typeid=a.id and a.gate2=34 and a.id1=-65535"
'If Len(Trim(invoiceType)&"")="0" Or invoiceType = 0 then
			else
				sqlFun = "select b.* from sortonehy a,invoiceConfig b where b.typeid=a.id and a.id =" & invoiceType
			end if
			Set rsFun = conn.execute(sqlFun)
			If rsFun.eof Then
				Exit Function
			else
				Err.clear
				on error resume next
				If m_includeTax = 1 Then
					pricesFun(1) = CDbl(priceValue)
					pricesFun(0) = CDbl(priceValue)/(1+ cdbl(rsFun("taxRate"))*0.01)
					pricesFun(1) = CDbl(priceValue)
					If Err.number <> 0 Then  pricesFun(0) = pricesFun(1)
				Else
					pricesFun(0) = CDbl(priceValue)
					pricesFun(1) = CDbl(priceValue) * (1  + cdbl(rsFun("taxRate"))* 0.01 )
					pricesFun(0) = CDbl(priceValue)
					If Err.number <> 0 Then  pricesFun(1) = pricesFun(0)
				end if
				On Error GoTo 0
				pricesFun(2) = CDbl(rsFun("taxRate"))
			end if
			rsFun.close
			getKindsOfPrices = pricesFun
		end function
		Function getGateLTable(sql2)
			Dim rs2
			If sql2&""<>"" Then
				Set rs2 = conn.execute("exec erp_comm_UsersTreeBase '"& sql2 &"',0")
				If rs2.eof = False Then
					conn.execute("if exists(select top 1 1 from tempdb..sysobjects where name='tempdb..#gate') drop table #gate; create table #gate(id int identity(1,1) not null, ord int, name nvarchar(200), orgstype int, deep int) ")
					While rs2.eof = False
						if rs2("NodeText")&"" = "" then
							t_NodeText=""
						else
							t_NodeText=rs2("NodeText")
							t_NodeText=Replace(t_NodeText,"'","''")
						end if
						conn.execute("insert into #gate(ord, name, orgstype, deep) values("& rs2("NodeId") &",'"& t_NodeText &"',"& rs2("orgstype") &","& rs2("NodeDeep") &")")
						rs2.movenext
					wend
				end if
				rs2.close
				Set rs2 = Nothing
			end if
		end function
		Function GetProductPic(proID)
			Dim rs,sql,temp
			If Len(proID&"") = 0 Then proID = 0
			sql = "SELECT TOP 1 fpath FROM sys_upload_res WHERE source = 'productPic' AND id1 = "& proID &" AND id2 = 1"
			set rs = conn.execute(sql)
			If Not rs.Eof Then
				temp = "<div align='center'><a  href='../edit/upimages/product/"& rs(0) &"' target='_blank'><img style='vertical-align: middle;' border='0' src=""../edit/upimages/product/"& Replace(rs(0),".","_s.") &"""></a></div>"
'If Not rs.Eof Then
			else
				temp = ""
			end if
			rs.close
			set rs = nothing
			GetProductPic = temp
		end function
		Function showImageBarCode(stype ,v , code,title)
			Dim s ,imgurl
			If stype=2 Then
				imgurl = "../code2/view.asp?sn=view&ct=46&data=CLDJ:"& v &"&width=120&errorh=3"
				s = "<a href='javascript:void(0)' onclick=""javascript:window.open('../code2/viewImage.asp?title="& server.urlencode(code) &"&imgurl=" & server.urlencode(imgurl) & "','imgurl_2','width=' + 320 + ',height=' + 320 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')""><img width='30' title='合同编号二维码' src='"& imgurl &"' style='padding-top:10px;cursor:pointer'></a>"
				imgurl = "../code2/view.asp?sn=view&ct=46&data=CLDJ:"& v &"&width=120&errorh=3"
			else
				imgurl = "../code2/viewCode.asp?codeType=128&data=HTID:"& v &"&height=60"
				s = "<div style='width:auto; display:inline-block !important; *zoom:1; display:inline; '><div style='text-align:center'><a href='javascript:void(0)' onclick=""javascript:window.open('../code2/viewImage.asp?codeType=128&title="& server.urlencode(code) &"&imgurl=" & server.urlencode(imgurl) & "&t="&now()&"','imgurl_1','width=' + 320 + ',height=' + 320 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')""><img  height='30' title='"&title&"' src='"& imgurl &"' style='cursor:pointer;'></a></div><div style='text-align:center'>"&v&"</div></div>"
				imgurl = "../code2/viewCode.asp?codeType=128&data=HTID:"& v &"&height=60"
			end if
			showImageBarCode = s
		end function
		function GetCpimg()
			sql = "select num1 from setjm3 where ord=20190823"
			set rs=conn.execute(sql)
			if not rs.eof then
				GetCpimg=rs(0)
			else
				conn.execute "insert into setjm3(ord,num1) values(20190823,0)"
				GetCpimg=0
			end if
			rs.close
			set rs=Nothing
		end function
		function GetAssistUnitTactics()
			sql = "select nvalue from home_usConfig where name='AssistUnitTactics' "
			set rsGetAssistUnitTactics=conn.execute(sql)
			if not rsGetAssistUnitTactics.eof then
				GetAssistUnitTactics=rsGetAssistUnitTactics(0)
			else
				conn.execute "insert into home_usConfig(name,nvalue,uid) values('AssistUnitTactics',0,0) "
				GetAssistUnitTactics=0
			end if
			rsGetAssistUnitTactics.close
			set rsGetAssistUnitTactics=Nothing
		end function
		function GetConversionUnitTactics()
			sql = "select nvalue from home_usConfig where name='ConversionUnitTactics' "
			set rsGetConversionUnitTactics=conn.execute(sql)
			if not rsGetConversionUnitTactics.eof then
				GetConversionUnitTactics=rsGetConversionUnitTactics(0)
			else
				conn.execute "insert into home_usConfig(name,nvalue,uid) values('ConversionUnitTactics',0,0) "
				GetConversionUnitTactics=0
			end if
			rsGetConversionUnitTactics.close
			set rsGetConversionUnitTactics=Nothing
		end function
		function ConvertUnitData(ProductID,OldUnit,NewUnit,Num)
			sql = "select (cast(" & Num & " as decimal(25,12)) * cast(a.bl/b.bl as decimal(25,12))  ) as num "&_
			"          from erp_comm_unitRelation a  "&_
			"          inner join erp_comm_unitRelation b on a.ord=b.ord and b.unit = " & NewUnit &_
			"          where a.ord =" & ProductID & " and a.unit = " & OldUnit
			if OldUnit = 0 then sql = "select " & Num & " as num "
			set rsConvertUnitData=conn.execute(sql)
			if not rsConvertUnitData.eof then
				ConvertUnitData=rsConvertUnitData(0)
			else
				ConvertUnitData=0
			end if
			rsConvertUnitData.close
			set rsConvertUnitData=Nothing
		end function
		function GetHistoryAssistUnit(ord)
			set rsGetHistoryAssistUnit= conn.execute("select nvalue from home_usConfig where  name='productDefaultAssistUnit_"&ord&"'  and isnull(uid, 0) =0")
			if rsGetHistoryAssistUnit.eof=false then
				if not rsGetHistoryAssistUnit(0)&"" = "" then
					GetHistoryAssistUnit = rsGetHistoryAssistUnit(0)
				else
					GetHistoryAssistUnit=0
				end if
				rsGetHistoryAssistUnit.close
				set rsGetHistoryAssistUnit=Nothing
			end if
		end function
		Sub SetHistoryAssistUnit(ord,assistUnit)
			if GetAssistUnitTactics()=1 then
				set rsSetHistoryAssistUnit = conn.execute("select * from home_usConfig where name='productDefaultAssistUnit_"&ord&"'")
				if rsSetHistoryAssistUnit.eof then
					conn.execute("insert into home_usConfig(nvalue,name,uid) values('"&assistUnit&"','productDefaultAssistUnit_"&ord&"',0)")
				else
					conn.execute("update home_usConfig set nvalue ='"&assistUnit&"' where name = 'productDefaultAssistUnit_"&ord&"'")
				end if
				rsSetHistoryAssistUnit.close
				set rsSetHistoryAssistUnit=Nothing
			end if
		end sub
		function IsDeletePayout2(ords)
			sql = "select top 1 1 from payout2 where CompleteType=8 and ord in ("&ords&") "
			set rs11=conn.execute(sql)
			IsDeletePayout2=rs11.eof
			rs11.close
			set rs11=Nothing
		end function
		function IsDeletePayout2Bybankin2(payout2)
			sql = "select top 1 1 from bankin2 where Payout2 in ("&payout2&") and money_left<money1"
			set rs11=conn.execute(sql)
			IsDeletePayout2Bybankin2=rs11.eof
			rs11.close
			set rs11=Nothing
		end function
		function IsOpenVoucherCForSKInvoice
			IsOpenVoucherCForSKInvoice = (sdk.GetSqlValue("select 1 from home_usConfig where name='Payback_Invoice_Voucher_Constraint' and nvalue=1" ,"0")="1")
		end function
		function IsOpenVoucherCForFKInvoice
			IsOpenVoucherCForFKInvoice = (sdk.GetSqlValue("select 1 from home_usConfig where name='Payout_Invoice_Voucher_Constraint' and nvalue=1" ,"0")="1")
		end function
		function IsOpenVoucherCForXTK
			IsOpenVoucherCForXTK = (sdk.GetSqlValue("select 1 from home_usConfig where name='Payout2_ContractTH_Voucher_Constraint' and nvalue=1" ,"0")="1")
		end function
		function IsOpenVoucherCForCTK
			IsOpenVoucherCForCTK = (sdk.GetSqlValue("select 1 from home_usConfig where name='Payout3_CaigouTH_Voucher_Constraint' and nvalue=1" ,"0")="1")
		end function
		
		dim CurrProductAttrsHandler
		Function isOpenProductAttr
			isOpenProductAttr = (ZBRuntime.MC(213104) and conn.execute("select nvalue from home_usConfig where name='ProductAttributeTactics' and nvalue=1 ").eof=false)
		end function
		function IsApplyProductAttr(ord, AttrID)
			dim SearchText: SearchText = "(ProductAttr1>0 or ProductAttr2>0)"
			if AttrID > 0 then SearchText = "(ProductAttr1="& AttrID & " or ProductAttr2="& AttrID & ")"
			dim cmdtext
			cmdtext = "select top 1 1 x from contractlist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
			"     union all   "&_
			"     select top 1 1 from kuoutlist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
			"     union all   "&_
			"     select top 1 1 from kuoutlist2 where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
			"     union all   "&_
			"     select top 1 1 from kuinlist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
			"     union all   "&_
			"     select top 1 1 from contractthlist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
			"     union all   "&_
			"     select top 1 1 from kumovelist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
			"     union all   "&_
			"     select top 1 1 from caigoulist where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
			"     union all   "&_
			"     select top 1 1 from ku where " & SearchText & " and (ord=" & ord & " or "& ord &" = 0)" &_
			"     union all   "&_
			"     select top 1 1 from bomlist where " & SearchText & " and (Product=" & ord & " or "& ord &" = 0) " &_
			"     union all   "&_
			"     select top 1 1 from bom where " & SearchText & " and (Product=" & ord & " or "& ord &" = 0) " &_
			"     union all   "&_
			"     select top 1 1 from BOM_Structure_List where " & SearchText & " and (ProOrd=" & ord & " or "& ord &" = 0) "
			IsApplyProductAttr =  (conn.execute(cmdtext).eof=false)
		end function
		function ProductAttrsCmdText(ord , loadmodel)
			dim CmdText, cmdwhere
			if loadmodel = "by_fields" then cmdwhere = " and st.pid = 0 "
			if loadmodel = "by_config" then cmdwhere = " and st.isstop = 0 "
			CmdText = "select 1 from product p  with(nolock) inner join menu m  with(nolock) on m.id = p.sort1 inner join Shop_GoodsAttr st  with(nolock) on st.proCategory = m.RootId and st.pid = 0 where p.ord = " & ord
			if conn.execute(CmdText).eof=false then
				CmdText = "select st.id ,st.pid ,st.title , st.sort ,st.isstop,  isnull(st.isTiled,0)isTiled "&_
				"   from product p  with(nolock)  "&_
				"   inner join menu m  with(nolock) on m.id = p.sort1 "&_
				"   inner join Shop_GoodsAttr st  with(nolock) on st.proCategory = m.RootId " & cmdwhere &"   "&_
				"   where p.ord = " & ord &" "&_
				"   order by st.isTiled desc,st.pid ,st.sort desc , st.id desc"
			else
				CmdText ="select st.id ,st.pid , st.title , st.sort ,st.isstop, isnull(st.isTiled,0)isTiled "&_
				"   from Shop_GoodsAttr st  with(nolock) "&_
				"   where st.proCategory = -1 "& cmdwhere &" "&_
				"   from Shop_GoodsAttr st  with(nolock) "&_
				"   order by st.isTiled desc,st.pid ,st.sort desc , st.id desc"
			end if
			ProductAttrsCmdText = CmdText
		end function
		function ProductAttrsByOrd(ord)
			dim attrs , CmdText
			CmdText = ProductAttrsCmdText(ord , "by_fields")
			set ProductAttrsByOrd = conn.execute(CmdText)
		end function
		Function GetProductAttr1Title(ord)
			Dim attrs ,s : s= "产品属性1"
			set attrs =ProductAttrsByOrd(ord)
			while attrs.eof=false
				if attrs("isTiled").value=1 then s = attrs("title").value
				attrs.movenext
			wend
			attrs.close
			GetProductAttr1Title = s
		end function
		Function GetProductAttr2Title(ord)
			Dim attrs ,s : s= "产品属性2"
			set attrs =ProductAttrsByOrd(ord)
			while attrs.eof=false
				if attrs("isTiled").value&""<>"1" then s = attrs("title").value
				attrs.movenext
			wend
			attrs.close
			GetProductAttr2Title = s
		end function
		function GetProductAttrNameById(productAttrId)
			if productAttrId<>"" and productAttrId<>"0" then
				dim rs7
				set rs7=server.CreateObject("adodb.recordset")
				sql7="select title from Shop_GoodsAttr where id="&productAttrId&""
				rs7.open sql7,conn,1,1
				if rs7.eof then
					GetProductAttrNameById=""
				else
					GetProductAttrNameById=rs7("title")
				end if
				rs7.close
				set rs7=nothing
			else
				GetProductAttrNameById=""
			end if
		end function
		function GetProductAttrOption(ord,isTiled)
			dim rs7 , hasAttr
			hasAttr = false
			set rs7 = ProductAttrsByOrd(ord)
			while rs7.eof=false
				if rs7("isTiled").value &""= isTiled&"" then
					set GetProductAttrOption = conn.execute(" select title,id from (select '' as title, 0 as id,999999 sort union all select title, id ,sort from Shop_GoodsAttr where isstop = 0 and pid = "&rs7("id").value  &") a order by  sort desc , id desc ")
					hasAttr = true
				end if
				rs7.movenext
			wend
			rs7.close
			if hasAttr=false then set GetProductAttrOption = conn.execute("select top  0 '' title , 0 id ")
		end function
		class ProductAttrCellClass
			public Attr1
			public Num
			public BillListId
			Public ParentListId
			public  function  GetJSON
				GetJSON = "{num:" &  Num & ",billistid:" & BillListId & ",attr1:" &  clng("0" & Attr1) & ",parentbilllistid:" & ParentListId & "}"
			end function
			public  sub  SetJson(byval  json)
				dim i, ks
				dim s : s = mid(json,2, len(json)-2)
'dim i, ks
				dim items :  items =  split(s, ",")
				for i = 0 to  ubound(items)
					ks = split(items(i), ":")
					select case ks(0)
					case "attr1" :   Attr1 = clng("0" & ks(1))
					case "num" :   Num = cdbl(ks(1))
					case "billistid" :   me.BillListId = clng(ks(1))
					case "parentbilllistid" :
					If ks(1)&"" = "" Then me.ParentListId = 0 Else me.ParentListId = CDBL(ks(1))
					end select
				next
				if err.number<>0 then
					Response.write "【" & json & "|" &  ubound(items) & "|"  & BillListId& "】"
				end if
			end sub
		end class
		class ProductAttrConfigCollection
			public id
			public title
			public options
			public sub Class_Initialize
				options = split("",",")
			end sub
			public sub Addtem(byval title,  byval id,  byval istop)
				dim c: c =ubound(options) + 1
'public sub Addtem(byval title,  byval id,  byval istop)
				redim preserve  options(c)
				options(c) = split( id & chr(1) & title & chr(1) & istop,   chr(1))
				options(c)(0) = clng( options(c)(0) )
				options(c)(2) = clng( "0" & options(c)(2) )
			end sub
			public sub RemoveAt(index)
				dim         j , i, c
				j = -1
'dim         j , i, c
				c = UBound(options)
				For i = 0 To c
					If i <> index Then
						j = j + 1
'If i <> index Then
						options(j) =options(i)
					end if
				next
				if j >=0 then
					redim preserve options(j)
				else
					options = split("",",")
				end if
			end sub
		end class
		class ProductAttrCellCollection
			public Cells
			public Attr2
			public SumNum
			public BatchId
			public Attr1Configs
			public Attr2Configs
			private currrs
			public  LoadModel
			public MxpxId
			public OldListData
			private isOpened
			private currlistrs
			public  StrongInherit
			public sub Class_Initialize
				set Attr1Configs =  nothing
				set Attr2Configs =  nothing
				LoadModel = "by_config"
				Cells = split("",",")
				isOpened = true
				StrongInherit = false
				set currlistrs = nothing
			end sub
			public function InitByNoOpened (byref rs)
				isOpened = false
				set currlistrs= rs
			end function
			public function Items(byval itemname)
				dim i, ns
				if isOpened = false then
					on error resume next
					if  not currlistrs is nothing then
						Items = currlistrs(itemname).value
					end if
					exit function
				end if
				if isarray(OldListData) then
					for i = 0 to ubound(OldListData)
						ns = split(OldListData(i), chr(1))
						if lcase(ns(0)) = lcase(itemname) then
							Items = ns(1)
							exit function
						end if
					next
				end if
				Items = ""
			end function
			public sub Bind(byval rs)
				SumNum =   0
				BatchId = rs("ProductAttrBatchId").value
				Attr2 = clng("0" & rs("ProductAttr2").value)
				Cells = split("",",")
				set currrs =  rs
			end sub
			public sub AddCell(ByRef listid,ByRef attr1Id, ByRef numv, ByRef parentlistid)
				dim obj
				set obj = new ProductAttrCellClass
				numv = cdbl(numv & "")
				obj.BillListId =  listid
				obj.ParentListId =  parentlistid
				obj.Num =  numv
				obj.Attr1 =  attr1Id
				SumNum = SumNum + numv
'obj.Attr1 =  attr1Id
				dim c : c =ubound(cells) + 1
'obj.Attr1 =  attr1Id
				redim preserve cells(c)
				set  cells(c) =  obj
				call  Update
			end sub
			public  function  GetJSON
				dim json, c,  i
				json = "{batchid:" & BatchId & "," &_
				"attr2:" & Attr2 & "," &_
				"sumnum:" & sumnum & "," &_
				"cells:["
				c = ubound(cells)
				for i = 0 to c
					if i>0 then json = json & ","
					json = json  & cells(i).GetJson
				next
				json = json & "]"
				GetJSON = json
			end function
			public  function  LoadJSON (byval jsondata)
				dim s : s = split(jsondata,  ",cells:")
				dim baseinfo:  baseinfo = mid(s(0), 2,  len(s(0))-1)
'dim s : s = split(jsondata,  ",cells:")
				dim cellsinfo :  cellsinfo = mid(s(1), 2,  len(s(1))-2)
'dim s : s = split(jsondata,  ",cells:")
				dim i, bi,  bs :  bs = split(baseinfo, ",")
				for i = 0 to ubound(bs)
					bi = split(bs(i), ":")
					select case bi(0)
					case "attr2" :  attr2 =  clng("0" & bi(1))
					case "batchid" :  batchid =  clng("0" & bi(1))
					case "sumnum" :  sumnum =  cdbl(bi(1))
					end select
				next
				dim cellsinfos :  cellsinfos = split(cellsinfo, "},{")
				dim  c : c = ubound(cellsinfos)
				if c = -1 then
'dim  c : c = ubound(cellsinfos)
					cells =  split("",",")
				else
					dim cjson
					redim cells(c)
					for i = 0 to c
						cjson = cellsinfos(i)
						if i <> 0 then  cjson = "{" & cjson
						if i <> c  then cjson =  cjson & "}"
						set cells(i) = new ProductAttrCellClass
						cells(i).SetJson cjson
					next
				end if
			end function
			private  sub Update
				currrs("ProductAttrsJson").value  = GetJSON()
				currrs.update
			end sub
			public sub  DelNullDataConfig
				dim i, ii,  exists
				if Attr2 =0 then set Attr2Configs =  nothing
				if not Attr1Configs is nothing then
					for i = ubound(Attr1Configs.options) to 0 step -1
'if not Attr1Configs is nothing then
						exists = false
						for ii = 0 to ubound(Cells)
							if Cells(ii).Attr1  =  Attr1Configs.options(i)(0) then
								exists  = true :  exit for
							end if
						next
						if exists = false then
							Attr1Configs.RemoveAt(i)
						end if
					next
					if ubound(Attr1Configs.options) = - 1 then  set Attr1Configs =  nothing
					Attr1Configs.RemoveAt(i)
				end if
				if not Attr2Configs is nothing then
					for i = ubound(Attr2Configs.options) to 0 step -1
'if not Attr2Configs is nothing then
						exists = false
						for ii = 0 to ubound(Cells)
							if attr2  =  Attr2Configs.options(i)(0) then
								exists  = true :  exit for
							end if
						next
						if exists = false and Attr2Configs.options(i)(2)=1 then
							Attr2Configs.RemoveAt(i)
						end if
					next
					if ubound(Attr2Configs.options) = - 1 then  set Attr2Configs =  nothing
					Attr2Configs.RemoveAt(i)
				end if
			end sub
			public sub  DelNullDataStopConfig
				dim i, ii,  exists
				if not Attr1Configs is nothing then
					for i = ubound(Attr1Configs.options) to 0 step -1
'if not Attr1Configs is nothing then
						exists = false
						for ii = 0 to ubound(Cells)
							if Cells(ii).Attr1  =  Attr1Configs.options(i)(0) then
								exists  = true :  exit for
							end if
						next
						if exists = false and Attr1Configs.options(i)(2)=1 then
							Attr1Configs.RemoveAt(i)
						end if
					next
					if ubound(Attr1Configs.options) = - 1 then
						Attr1Configs.RemoveAt(i)
						set Attr1Configs =  nothing
					end if
				end if
				if not Attr2Configs is nothing then
					for i = ubound(Attr2Configs.options) to 0 step -1
'if not Attr2Configs is nothing then
						exists = false
						for ii = 0 to ubound(Cells)
							if attr2  =  Attr2Configs.options(i)(0) then
								exists  = true :  exit for
							end if
						next
						if exists = false and Attr2Configs.options(i)(2)=1 then
							Attr2Configs.RemoveAt(i)
						end if
					next
					if ubound(Attr2Configs.options) = - 1 then
						Attr2Configs.RemoveAt(i)
						set Attr2Configs =  nothing
					end if
				end if
			end sub
			public sub AddConfig(byval id, byval pid, byval title, byval istop,  byval isNumAttr)
				if pid = 0 then
					if isNumAttr then
						set Attr1Configs = new  ProductAttrConfigCollection
						Attr1Configs.id = id
						Attr1Configs.title = title
					else
						set Attr2Configs = new  ProductAttrConfigCollection
						Attr2Configs.id = id
						Attr2Configs.title = title
					end if
				else
					if not Attr1Configs is nothing then
						if pid = Attr1Configs.id then
							Attr1Configs.Addtem title,  id,  istop
						else
							Attr2Configs.Addtem title,  id,  istop
						end if
					else
						Attr2Configs.Addtem title,  id,  istop
					end if
				end if
			end sub
			public function GetEachCount()
				if Attr1Configs is nothing then GetEachCount = 0 : exit function
				select case LoadModel
				case "by_data" :  GetEachCount =  ubound(Attr1Configs.options)+1
'select case LoadModel
				case "by_config" :  GetEachCount =  ubound(Attr1Configs.options)+1
'select case LoadModel
				case "by_config_or_data" : GetEachCount =  ubound(Attr1Configs.options)+1
'select case LoadModel
				case else
				err.Raise 1000, 1, "GetEachCount 暂不支持【" & loadmodel & "】模式"
				end select
			end function
			private eachdataindex
			public sub  GetEachData(byval eindex,  byref attr1,  byref numv,  byref  billlistid,  byref mxpx)
				dim i
				eachdataindex = -1
'dim i
				if LoadModel  = "by_config" or  LoadModel  = "by_data" or LoadModel  = "by_config_or_data" then
					attr1 = 0:  numv = "":  billlistid = 0
					if not Attr1Configs is nothing then
						if eindex <= ubound(Attr1Configs.options) then
							attr1 = clng(Attr1Configs.options(eindex)(0))
						end if
					end if
					if attr1>0 then
						for i = 0 to ubound(cells)
							if cells(i).Attr1 = attr1 then
								numv = cells(i).num
								billlistid = cells(i).BillListId
								mxpx = "AttrsBatch_Attr1_" & mxpxid & "_" &  attr1 & "_" &  cells(i).BillListId & "_" &  cells(i).ParentListId
								eachdataindex =  i
								exit sub
							end if
						next
						billlistid = 0
						if ubound(cells) = 0 then
							mxpx = "AttrsBatch_Attr1_" & mxpxid & "_" &  attr1 & "_0_" &  cells(0).ParentListId
						else
							mxpx = "AttrsBatch_Attr1_" & mxpxid & "_" &  attr1 & "_0_0"
						end if
					else
						billlistid =  BatchId
						numv = SumNum
						mxpx = mxpxid
						eachdataindex = -1
'mxpx = mxpxid
					end if
				else
					err.Raise 1000, 1, "GetEachData 暂不支持【" & loadmodel & "】模式"
				end if
			end sub
			public sub SetOldListData(datas)
				if EachDataIndex <0 then
					OldListData = split("",",")
				else
					OldListData = split( split(datas, chr(3))(EachDataIndex), chr(2))
				end if
			end sub
			public function GetEachNumValue(byval eindex)
				select case LoadModel
				case "by_config" :
				dim i,  attrid :  attrid =  Attr1Configs.options(eindex)(0)
				for i = 0 to ubound(cells)
					if cells(i).Attr1 = attrid then
						exit function
					end if
				next
				case else
				err.Raise 1000, 1, "GetEachNumValue 暂不支持【" & loadmodel & "】模式"
				end select
			end function
		end Class
		class ProductAttrsHelperClass
			private CurrNumField
			private CurrPrimaryKeyField
			Private CurrParentPrimaryKeyField
			private CurrJoinnumFields
			private ListRecordset
			private ProductField
			public ForEachIndex
			public EachObject
			private ForEachListId
			private CurrLoadModel
			private CurrEditDispaly
			private IsAddModel
			public StrongInheritModel
			private IsOpened
			private mbit
			public sub Class_Initialize
				ForEachListId = "**"
				CurrLoadModel = "by_config"
				CurrEditDispaly = "editable"
				IsAddModel = false
				BufferModel= false
				StrongInheritModel = false
				IsOpened =  isOpenProductAttr
				set CurrProductAttrsHandler =  me
				mbit= sdk.GetSqlValue("select num1 from setjm3 where ord in (1)",6)
			end sub
			public sub InitAsAddNew(byval  productid,  byval initnum1)
				dim proxyrs  :  set proxyrs = nothing
				if IsOpened then
					set proxyrs = server.CreateObject("adodb.recordset")
					proxyrs.fields.Append  "Attrf_Productid",  3,  4,  120
					proxyrs.fields.Append  "Attrf_Num1",  5,  19,  120
					proxyrs.fields.Append  "Attrf_billlist",  3,  4,  120
					proxyrs.fields.Append  "Attrf_money1",  5,  19,  120
					proxyrs.fields.Append  "ProductAttr1",  3,  4,  120
					proxyrs.fields.Append  "ProductAttr2",  3,  4,  120
					proxyrs.fields.Append  "ProductAttrBatchId",  3,  4,  120
					proxyrs.Open
					proxyrs.AddNew
					proxyrs("Attrf_Productid").Value =  productid
					proxyrs("Attrf_Num1").Value =  cdbl(initnum1)
					proxyrs("Attrf_billlist").Value =  0
					proxyrs("Attrf_money1").Value =  0
					proxyrs.Update
					IsAddModel = true
				end if
				HandleRecordSet proxyrs,  "Attrf_billlist" , "",  "Attrf_Productid",  "Attrf_Num1",  "Attrf_money1"
			end sub
			public sub InitAsAddNewByAttrs(byval  productid,  byval initnum1Str, ByVal ProductAttr1Str, ByVal ProductAttr2, ByVal AttrBatchId, ByVal billListIdStr, ByVal parentListIdStr)
				dim proxyrs  :  set proxyrs = nothing
				dim initnum1, i, arr_cpord, arr_num1, arr_attr1, arr_billListId, arr_parentListId
				if IsOpened then
					set proxyrs = server.CreateObject("adodb.recordset")
					proxyrs.fields.Append  "Attrf_Productid",  3,  4,  120
					proxyrs.fields.Append  "Attrf_Num1",  5,  19,  120
					proxyrs.fields.Append  "Attrf_billlist",  3,  4,  120
					proxyrs.fields.Append  "Attrf_money1",  5,  19,  120
					proxyrs.fields.Append  "ProductAttr1",  3,  4,  120
					proxyrs.fields.Append  "ProductAttr2",  3,  4,  120
					proxyrs.fields.Append  "ProductAttrBatchId",  3,  4,  120
					proxyrs.fields.Append  "parentListId",  3,  4,  120
					proxyrs.Open
					if ProductAttr1Str&"" = "" then
						If parentListIdStr&""="" Then
							parentListIdStr = "0"
						else
							parentListIdStr = split(parentListIdStr&"",",")(0)
						end if
						proxyrs.AddNew
						proxyrs("Attrf_Productid").Value =  productid
						proxyrs("Attrf_Num1").Value =  zbcdbl(initnum1Str)
						proxyrs("ProductAttr2").Value =  ProductAttr2
						proxyrs("ProductAttrBatchId").Value =  AttrBatchId
						proxyrs("Attrf_billlist").Value =  billListIdStr
						proxyrs("Attrf_money1").Value =  0
						proxyrs("parentListId").Value =  parentListIdStr
						proxyrs.Update
					else
						arr_num1 = split(initnum1Str&"",",")
						arr_attr1 = split(ProductAttr1Str&"",",")
						arr_billListId = split(billListIdStr&"",",")
						arr_parentListId = split(parentListIdStr&"",",")
						for i=0 to ubound(arr_num1)
							if arr_num1(i)&""<>"" then
								proxyrs.AddNew
								proxyrs("Attrf_Productid").Value =  productid
								proxyrs("ProductAttr1").Value =  arr_attr1(i)
								proxyrs("Attrf_Num1").Value =  cdbl(arr_num1(i))
								proxyrs("ProductAttr2").Value =  ProductAttr2
								proxyrs("ProductAttrBatchId").Value =  AttrBatchId
								proxyrs("Attrf_billlist").Value =  arr_billListId(i)
								proxyrs("Attrf_money1").Value =  0
								proxyrs("parentListId").Value =  arr_parentListId(i)
								proxyrs.Update
							end if
						next
					end if
					IsAddModel = true
				end if
				HandleRecordSet proxyrs,  "Attrf_billlist" , "parentListId",  "Attrf_Productid",  "Attrf_Num1",  "Attrf_money1"
			end sub
			private function existsRsField(byref rs, byref fieldname)
				dim i, c
				for i = 0 to rs.fields.count - 1
'dim i, c
					set c = rs.fields(i)
					if lcase(c.name) = lcase(fieldname) then
						existsRsField = true
						exit function
					end if
				next
				existsRsField = false
			end function
			public sub HandleRecordSet(byref rs,  byval billlistf,   ByVal parentbilllistf,   byval pfield,   byval numfield,  byval joinnumFields)
				dim i,  ii,  newrs ,  c,  newc,  colhas,  parentlistid, rowindexkey
				dim attrbatchid,  signkeys,  soruce,  ctype
				if IsOpened = false then
					set ListRecordset = rs
					exit sub
				end if
				CurrNumField = numfield
				dim JoinnumField : JoinnumField = numfield
				if len(joinnumFields)>0 then JoinnumField = joinnumFields & "," & numfield
				CurrJoinnumFields  =  split(JoinnumField ,",")
				CurrPrimaryKeyField = billlistf
				CurrParentPrimaryKeyField = parentbilllistf
				ProductField = pfield
				signkeys = split("ProductAttr1,ProductAttr2,ProductAttrBatchId," & numfield & "," & joinnumFields,",")
				soruce = rs.Source
				set  rs.ActiveConnection = nothing
				rs.Sort = "ProductAttrBatchId, " & billlistf
				for ii=0 to ubound(signkeys)
					if len(signkeys(ii))>0 and existsRsField(rs, signkeys(ii)) = false then
						err.Raise 1000,1000, "<div style='color:red;padding:20px;margin:5px 0px;background-color:#ffffaa;font-size:14px;font-family:微软雅黑;line-height:18px'>ProductAttrsClass.HandleRecordSet 转换失败! " &_
						"<br>请确认要处理的明细数据源中是否提供了【 & join(signkeys, 】、【) & 】 列.  <br> 数据源命令：   & soruce & </div>"
					end if
				next
				dim fieldmap : fieldmap = "|"
				set newrs = server.CreateObject("adodb.recordset")
				for i = 0 to rs.fields.count - 1
'set newrs = server.CreateObject("adodb.recordset")
					set c = rs.fields(i)
					if instr(fieldmap, "|" & lcase(c.name) & "|") = 0 then
						newrs.fields.Append c.Name,  c.type,  c.DefinedSize, c.Attributes
						set newc = newrs.Fields(c.Name)
						newc.DataFormat = c.DataFormat
						newc.NumericScale = c.NumericScale
						newc.Precision = c.Precision
						fieldmap=  fieldmap & lcase(c.name) & "|"
					end if
				next
				newrs.fields.Append  "ProductAttrsJson",  202, 4000
				newrs.fields.Append  "ProductAttrsOldDatas",  202, 8000
				newrs.open
				dim  attrs,  PreAttrbatchid :  PreAttrbatchid  = -1
'newrs.open
				while rs.eof = False
					parentlistid = 0
					attrbatchid = clng("0" & rs("ProductAttrBatchId").value)
					If Len(CurrParentPrimaryKeyField) > 0 Then  parentlistid = rs(CurrParentPrimaryKeyField).value
					if PreAttrbatchid = attrbatchid  and  attrbatchid <>0  then
						call attrs.AddCell ( rs(CurrPrimaryKeyField).value ,  rs("ProductAttr1").value ,  rs(numfield).value,  parentlistid)
						call AddNeedSumFields(newrs,  rs)
						call AddOldListFieldDatas(newrs, rs)
					else
						newrs.AddNew
						for i = 0 to rs.fields.count - 1
'newrs.AddNew
							set c = rs.fields(i)
							on error resume next
							newrs.Fields(c.name).Value = c.value
							on error goto 0
						next
						set attrs= new ProductAttrCellCollection
						call attrs.Bind( newrs )
						call attrs.AddCell (rs(CurrPrimaryKeyField).value ,  rs("ProductAttr1").value ,  rs(numfield).value,  parentlistid)
						call AddOldListFieldDatas(newrs, rs)
						PreAttrbatchid = attrbatchid
					end if
					rs.movenext
				wend
				rs.close
				set rs = newrs
				if  existsRsField(rs, "rowindex") then
					rs.sort = "rowindex," &  billlistf
				else
					rs.sort =  billlistf
				end if
				if rs.eof = false then rs.movefirst
				set ListRecordset = rs
			end sub
			private sub AddNeedSumFields(byval newrs,  byval oldrs)
				dim i,  f,  newv, oldv
				for i = 0 to ubound(CurrJoinnumFields)
					f = CurrJoinnumFields(i)
					oldv =  oldrs(f).Value :  if len(oldv & "") = 0 then oldv = 0
					newv =  newrs(f).Value :  if len(newv & "") = 0 then newv = 0
					newrs(f).Value = cdbl(oldv) + cdbl(newv)
'newv =  newrs(f).Value :  if len(newv & "") = 0 then newv = 0
					newrs.Update
				next
			end sub
			public sub  AddOldListFieldDatas(byval newrs, byval oldrs)
				dim i,  n, v,  attrs,  itemc
				attrs =newrs("ProductAttrsOldDatas").Value & ""
				itemc = ""
				for i = 0 to oldrs.fields.count - 1
'itemc = ""
					v =  oldrs(i).value & ""
					if len(v)>0 and isnumeric(v) then
						if len(itemc) > 0 then  itemc =  itemc & chr(2)
						itemc =  itemc & oldrs(i).name & chr(1) & v
					end if
				next
				if len(attrs) > 0 then attrs = attrs & chr(3)
				attrs = attrs & itemc
				newrs("ProductAttrsOldDatas").Value  =  attrs
			end sub
			public function GetForEachAttrObject (byval json ,  byval  productid,  byval loadmodel)
				dim i,  existsids,  attrobj, rs,  onlynostop
				set attrobj = new  ProductAttrCellCollection
				attrobj.loadmodel = loadmodel
				attrobj.LoadJSON  json
				dim  sql : sql = ProductAttrsCmdText(productid , loadmodel)
				set rs = conn.execute(sql)
				dim existspid : existspid =  false
				while rs.eof = false
					if existspid = false then existspid =  clng("0" &  rs("pid").value)
					attrobj.AddConfig  rs("id").value ,   rs("pid").value,  rs("title").value,  rs("isstop").value,  (rs("isTiled").value & "")="1"
					rs.movenext
				wend
				rs.close
				set rs =  nothing
				attrobj.StrongInherit =   (StrongInheritModel=true and  existspid )
				if loadmodel = "by_data"  or  attrobj.StrongInherit  then
					attrobj.DelNullDataConfig
				elseif loadmodel = "by_config_or_data" then
					attrobj.DelNullDataStopConfig
				end if
				set GetForEachAttrObject = attrobj
			end function
			private function GetExistsDataIdsSql(attrobj)
				dim i
				dim attr2id : attr2id = attrobj.Attr2
				dim attr2parentids :   attr2parentids =  "0"
				if attr2id>0 then attr2parentids = attr2id & "," & conn.execute("select pid  from Shop_GoodsAttr where id=" & attr2id).value
				dim attrs1ids :  attrs1ids = "0"
				for i = 0 to ubound(attrobj.Cells)
					attrs1ids = attrs1ids
				next
			end function
			public sub SetLoadModel(byval loadmodel, byval display)
				loadmodel = lcase(loadmodel)
				if loadmodel <> "by_config" and  loadmodel <> "by_data" and loadmodel<>"by_config_or_data" then
					err.Raise 1000,1000, "产品属性 loadmodel参数只支持：  by_config（仅按配置加区域）  by_data (仅按数据加载区域) 和  by_config_or_data（按配置和数据加载区域，取并集）"
				end if
				if display <> "editable" and  display <> "readonly"  then
					err.Raise 1000,1000, "产品属性display 参数只支持：  editable（编辑模式）  readonly (只读模式) "
				end if
				CurrLoadModel = loadmodel
				CurrEditDispaly= display
			end sub
			public BufferModel
			public BuffterModelHtml
			public function WriteHtml(byval html)
				response_Write html
			end function
			public function getBufferHtml()
				getBufferHtml = BuffterModelHtml
				BuffterModelHtml = ""
			end function
			private currnumtext
			public function ForEach(byref mxid, byref billistid ,  byref  attr1id, byref  attr2id,  byref num1, byref  inputattrs)
				if ForEachIndex = -100 then
					inputattrs = ""
					attr1id = 0  :  attr2id = 0
					ForEachIndex=0 :  ForEach = false
					exit function
				end if
				if IsOpened = false then
					set EachObject = new ProductAttrCellCollection
					EachObject.InitByNoOpened ListRecordset
					attr1id = 0  :  attr2id = 0
					ForEachIndex=-100  :  ForEach = true
'attr1id = 0  :  attr2id = 0
					exit function
				end if
				dim rs : set rs = ListRecordset
				if ForEachListId <>  rs(CurrPrimaryKeyField).value then
					ForEachIndex = 0
					ForEachListId = rs(CurrPrimaryKeyField).value
					set EachObject = GetForEachAttrObject( rs("ProductAttrsJson").value,  rs(ProductField).value ,  CurrLoadModel)
					EachObject.MxpxId = mxid
					if  EachObject.Attr1Configs is nothing  and   EachObject.Attr2Configs is nothing  then
						ForEachIndex = - 100
'if  EachObject.Attr1Configs is nothing  and   EachObject.Attr2Configs is nothing  then
						set EachObject = nothing
						ForEach = true
						exit function
					else
						if (EachObject.batchid & "") = ""  or  (EachObject.batchid & "")  = "0" then
							EachObject.batchid =  ForEachListId
						end if
					end if
				else
					ForEachIndex = ForEachIndex + 1
					EachObject.batchid =  ForEachListId
				end if
				if ForEachIndex = 0 then
					currnumtext = ""
					CStartAttrTableHtml  loadmodel
				end if
				if  ForEachIndex > EachObject.GetEachCount() then
					CEndAttrTableHtml
					ForEach = false
				else
					call EachObject.GetEachData( ForEachIndex,   attr1id,   num1,    billistid,  mxid)
					call EachObject.SetOldListData (rs("ProductAttrsOldDatas").value)
					attr2id = EachObject.attr2
					inputattrs = GetNewInputHtmlAttrs(mxid)
					CItemAttrTableHtml mxid
					currnumtext = currnumtext & num1
					ForEach = true
				end if
			end function
			public RowIndexTick
			public sub UpdateFieldValue(byval  rs,   byval mxid)
				dim v1, v2, v3
				v1= request.Form("AttrsBatch_Attr1_" & mxid)
				v2 = request.Form("AttrsBatch_Attr2_" & mxid)
				v3 = request.Form("AttrsBatch_BatchId_" & mxid)
				if len(v1 & "")=0 then v1 = 0
				rs("ProductAttr1").value = v1
				if len(v2 & "")=0 then v2 = 0
				rs("ProductAttr2").value =  v2
				if len(v3 & "")>0 then rs("ProductAttrBatchId").value = v3
				RowIndexTick = RowIndexTick + 1
'if len(v3 & "")>0 then rs("ProductAttrBatchId").value = v3
				on error resume next
				rs("rowindex").value = RowIndexTick
				on error goto 0
			end sub
			public function  InitScript()
				Response.write "<script src='" & sdk.GetVirPath  & "inc/ProductAttrhelper.js'></script>"
				Response.write "<style>.attrreadsum input, .attrreadNumInput{background-color:#e0e0e0; color:#666;}</style>"
				Response.write "<script src='" & sdk.GetVirPath  & "inc/ProductAttrhelper.js'></script>"
			end function
			private  function  GetNewInputHtmlAttrs(mxid)
				dim itemhtml
				if instr(mxid & "","AttrsBatch_Attr1")>0 then
					if IsAddModel then
						itemhtml = " min='' "
					end if
					GetNewInputHtmlAttrs = " IsAttrCellBox=1 onblur='void(0)'  onkeyup='void(0)'  onpropertychange=""formatData(this,'number');""  "  & itemhtml
				else
					GetNewInputHtmlAttrs = " IsAttrSumBox=1 "
					if IsReadSumCell(mxid) then GetNewInputHtmlAttrs =  GetNewInputHtmlAttrs & " readonly "
				end if
			end function
			private function IsReadSumCell(byval mxid)
				IsReadSumCell = len(currnumtext & "")>0 and instr(mxid & "","AttrsBatch_Attr1")=0  and  ForEachIndex>0
			end function
			private sub CItemAttrTableHtml(byval mxid)
				if ForEachIndex>0 then Response.write "</td>"
				if IsReadSumCell(mxid) then
					response_Write "<td align=center isattrcell=1 class='attrreadsum' >"
				else
					response_Write "<td align=center isattrcell=1 >"
				end if
			end sub
			private sub response_Write(byval html)
				if BufferModel = false then
					Response.write html
				else
					BuffterModelHtml = BuffterModelHtml & html
				end if
			end sub
			private sub  CStartAttrTableHtml(byval loadmodel)
				dim oitems, i
				dim attr1 :  set attr1 =  EachObject.Attr1Configs
				dim attr2 :  set attr2 =  EachObject.Attr2Configs
				response_Write "<input type='hidden'  name='__sys_productattrs_batchid' value='" & EachObject.mxpxid & "'>"
				response_Write "<input type='hidden'  id='__sy_pa_fs_" &   EachObject.mxpxid & "' name='__sys_productattrs_fields_" &   EachObject.mxpxid & "' value=''>"
				response_Write "<table class='productattrstable'><tr class='header'>"
				if not attr2 is nothing then
					response_Write "<td>" & attr2.title & "</td>"
				end if
				if not attr1 is nothing then
					for i = 0 to ubound(attr1.options)
						oitems = attr1.options(i)
						response_Write "<td>" & oitems(1)  & "</td>"
					next
				end if
				response_Write "<td>小计</td></tr>"
				response_Write "<tr class=data>"
				dim IsEdit :  IsEdit =CurrEditDispaly = "editable"
				if not attr2 is nothing then
					response_Write "<td align=center>"
					if IsEdit then
						response_Write "<select name='AttrsBatch_Attr2_" & EachObject.mxpxid & "'>"
						if EachObject.StrongInherit = false then  response_Write "<option value=0 selected ></option>"
					end if
					for i = 0 to ubound(attr2.options)
						dim oid : oid= attr2.options(i)(0)
						dim otit : otit = attr2.options(i)(1)
						if (oid & "")=  (EachObject.Attr2 & "") then
							if IsEdit then
								response_Write "<option value=" & oid &" selected >" & otit & "</option>"
							else
								response_Write otit & "<input type='hidden' name='AttrsBatch_Attr2_" & EachObject.mxpxid & "' value='" & oid & "'>"
							end if
						else
							if IsEdit and EachObject.StrongInherit= false then  response_Write "<option value=" & oid &" >" & otit & "</option>"
						end if
					next
					if IsEdit then response_Write "</select>"
					response_Write "</td>"
				end if
			end sub
			private sub CEndAttrTableHtml
				response_Write "</td></tr></table>"
			end sub
			private CurrMaxMXPXID
			Public Function  CreateProxyRequest(ByVal  mxidname,  ByVal  billlistidname,  ByVal  parentbilllistidname,  ByVal numname,  ByVal joinfilednames)
				if isOpened = false then exit Function
				Dim mxid, n, i
				ExecuteGlobal "public Request"
				Set Request =  new ProductAttrProxyRequst
				For Each n In SystemRequestObject.form
					Request.AddFormValue n, CStr( SystemRequestObject.form(n))
				next
				CurrMaxMXPXID = 0
				dim rs : set rs = conn.execute("select max(id) from mxpx")
				if rs.eof = false then CurrMaxMXPXID = rs(0).value
				rs.close
				dim  mxids :  mxids =  split(SystemRequestObject.Form("__sys_productattrs_batchid"), ",")
				for i = 0 to ubound(mxids)
					mxid = clng(mxids(i))
					HanleFormBatchItemData mxid,  mxidname,  billlistidname,  parentbilllistidname,  numname,  joinfilednames
				next
			end function
			private sub HanleFormBatchItemData(byval  batchid,  ByVal  mxidname,  ByVal  billlistidname,  ByVal  parentbilllistidname,  ByVal numname,  ByVal joinfilednames)
				dim n, v, c, joinfs, i, ii,  attsns
				dim  isallmodel : isallmodel = false
				dim attr1s :  attr1s= split("", ",")
				for each n in SystemRequestObject.Form
					if  instr(n,  numname  & "AttrsBatch_Attr1_" & batchid & "_" ) = 1 then
						v  = SystemRequestObject.Form(n)
						if len(v & "")>0 then
							ArrayAppend attr1s,  array(n, v)
						end if
					end if
				next
				if ubound(attr1s)  <0  then exit sub
				joinfs = split(joinfilednames, ",")
				ArrayAppend joinfs,  numname
				dim  sumvalues, usedvalues, sumsize
				sumsize = ubound(joinfs)
				redim usedvalues(sumsize)
				dim item_batchid,  item_attr1_id,  item_billlistid ,   item_parentbilllistid
				dim currbilllistid :  currbilllistid = CStr(SystemRequestObject.Form( billlistidname & batchid ))
				currbilllistid = clng("0" & currbilllistid)
				dim isdeleted : isdeleted = cellcount>=0
				dim sumnum : sumnum =  cdbl(replace(CStr(SystemRequestObject.Form( numname & batchid )) ,",",""))
				dim cellcount :  cellcount = ubound(attr1s)
				for i = 0 to cellcount
					n  = attr1s(i)(0)
					v =  cdbl(replace(attr1s(i)(1), ",",""))
					attsns = split( split(n, "AttrsBatch_Attr1_")(1) , "_")
					item_batchid = clng(attsns(0))
					item_attr1_id = clng(attsns(1))
					item_billlistid = clng(attsns(2))
					item_parentbilllistid = clng(attsns(3))
					if isdeleted then
						if  item_billlistid = currbilllistid  and currbilllistid> 0 then  isdeleted = false
					end if
					if item_billlistid = 0  or item_billlistid<>currbilllistid  then
						CurrMaxMXPXID = CurrMaxMXPXID+1
'if item_billlistid = 0  or item_billlistid<>currbilllistid  then
						dim currformv : currformv = Request.Form(mxidname)
						if len(currformv & "") > 0 then  currformv = currformv & ","
						Request.SetFormValue mxidname,  InsertMxIdAfter(currformv ,  CurrMaxMXPXID, batchid)
						AddNewFormItem  batchid,  CurrMaxMXPXID,  item_billlistid, item_attr1_id,  billlistidname,  parentbilllistidname,  item_parentbilllistid,  numname,  joinfs ,   usedvalues,  sumnum,  v ,  i=cellcount
					else
						UpdateFormItem  batchid,   item_attr1_id,  billlistidname,  parentbilllistidname,  numname,  joinfs ,   usedvalues,  sumnum,  v ,   i=cellcount
					end if
				next
				if isdeleted then
					currformv = replace(Request.Form(mxidname), " ", "")
					currformv  = replace("," & currformv & ",", "," &  batchid & ",", ",")
					currformv =  replace(currformv, ",,", ",")
					currformv =  replace(currformv, ",,", ",")
					currformv =  replace(currformv, ",,", ",")
					currformv =  replace(currformv, ",,", ",")
					if left(currformv, 1) = "," then currformv = mid(currformv, 2)
					if right(currformv, 1) = "," then currformv = mid(currformv, 1, len(currformv)-1)
'if left(currformv, 1) = "," then currformv = mid(currformv, 2)
					Request.setFormValue mxidname,  currformv
					dim  fms :  fms = split(request.Form("__sys_productattrs_fields_" &  batchid), "|")
					for i = 0 to ubound(fms)
						Request.SetFormValue fms(i) & batchid ,  ""
					next
				end if
			end sub
			private function InsertMxIdAfter(byval  mxliststr,  byval newmxid,  byval beforemxid)
				mxliststr = "," & replace(mxliststr, " ", "") & ","
				mxliststr = replace(mxliststr, ("," & beforemxid & ",") ,  ("," & beforemxid & "," & newmxid & ","))
				mxliststr = ClearArrayStr(mxliststr, ",")
				InsertMxIdAfter =mxliststr
			end function
			private function ClearArrayStr(byval arrtxt, byval splitkey)
				dim arr1 :  arr1 = split(arrtxt, splitkey)
				dim i,  j,  arr2 : j = 0
				arr2 = split("", ",")
				for i=0 to ubound(arr1)
					if len(arr1(i))>0 then
						redim preserve arr2(j)
						arr2(j) = arr1(i)
						j=j+1
'arr2(j) = arr1(i)
					end if
				next
				ClearArrayStr = join(arr2,  splitkey)
			end function
			private sub  AddNewFormItem(byval copybatchid, byval newmxid,  byval itembilllistid, byval attr1id, byval billlistidname,  byval parentbilllistidname, byval item_parentbilllistid, byval numf,  byval joinfs ,  byref useds,  byval  allnum,  byval  itemnum ,  byval iseof)
				Request.AddFormValue billlistidname & newmxid,  itembilllistid
				if len(parentbilllistidname) >0 then  Request.AddFormValue parentbilllistidname & newmxid,  item_parentbilllistid
				Request.AddFormValue "AttrsBatch_Attr2_" & newmxid,  Request.Form("AttrsBatch_Attr2_" & copybatchid)
				Request.AddFormValue "AttrsBatch_Attr1_" & newmxid,  attr1id
				Request.AddFormValue "AttrsBatch_BatchId_" & newmxid,  copybatchid
				dim allfs : allfs = split(request.Form("__sys_productattrs_fields_" & copybatchid), "|")
				dim joinftxt : joinftxt = "|" & lcase( join(joinfs, "|") ) & "|"
				dim i, ii, iii
				for ii = 0 to ubound(allfs)
					dim itemn : itemn =  allfs(ii)
					dim litemn:  litemn = lcase(itemn)
					if litemn = lcase(billlistidname) or litemn = lcase(parentbilllistidname)  then
					else
						if  instr( joinftxt,  "|" &  litemn & "|") >0  then
							dim newjoinitemv
							newjoinitemv = 0
							if litemn =  lcase(numf) then
								newjoinitemv =  itemnum
							else
								dim oldsumv :  oldsumv = CStr(SystemRequestObject.Form(itemn & copybatchid))
								if len(oldsumv & "")=0 then  oldsumv = 0
								if isnumeric(oldsumv) = false then oldsumv = 0
								oldsumv = cdbl(replace(oldsumv & "",",",""))
								if  oldsumv <> 0 and  allnum<>0 then
									dim ji : ji = ArrayIndexOf(joinfs,  itemn)
									if ji>=0 then
										if iseof then
											newjoinitemv =  cdbl(oldsumv)*1  -  cdbl(useds(ji))
'if iseof then
										else
											newjoinitemv = cdbl(oldsumv)*cdbl(itemnum/allnum)
											newjoinitemv = sdk.getsqlvalue("select round("& newjoinitemv &","& mbit &")",0)
											useds(ji) = cdbl(useds(ji)) + cdbl(newjoinitemv)
'newjoinitemv = sdk.getsqlvalue("select round("& newjoinitemv &","& mbit &")",0)
										end if
									end if
								end if
							end if
							Request.AddFormValue itemn & newmxid,  newjoinitemv
						else
							Request.AddFormValue itemn & newmxid,  CStr(SystemRequestObject.Form(itemn & copybatchid))
						end if
					end if
				next
			end sub
			private sub  UpdateFormItem(byval currmxid,  byval attr1id,  byval billlistidname,  byval parentbilllistidname, byval numf,   byval joinfs ,   byref useds,  byval  allnum,  byval  itemnum ,  byval iseof)
				Request.AddFormValue "AttrsBatch_Attr1_" & currmxid,  attr1id
				Request.AddFormValue "AttrsBatch_BatchId_" & currmxid,  currmxid
				dim allfs : allfs = split(request.Form("__sys_productattrs_fields_" & currmxid), "|")
				dim joinftxt : joinftxt = "|" & lcase( join(joinfs, "|") ) & "|"
				dim i, ii, iii
				for ii = 0 to ubound(allfs)
					dim itemn : itemn =  allfs(ii)
					dim litemn:  litemn = lcase(itemn)
					if litemn = lcase(billlistidname) or litemn = lcase(parentbilllistidname)  then
					else
						if  instr( joinftxt,  "|" &  litemn & "|") >0  then
							dim newjoinitemv
							newjoinitemv = 0
							if litemn =  lcase(numf) then
								newjoinitemv =  itemnum
							else
								dim oldsumv :  oldsumv = CStr(SystemRequestObject.Form(itemn & currmxid))
								if len(oldsumv & "")=0 then  oldsumv = 0
								oldsumv = cdbl(replace(oldsumv & "",",",""))
								if  oldsumv <> 0 and  allnum<>0 then
									dim ji : ji = ArrayIndexOf(joinfs,  itemn)
									if ji>=0 then
										if iseof then
											newjoinitemv = oldsumv*1  -  cdbl(useds(ji))
'if iseof then
										else
											newjoinitemv = oldsumv *  cdbl(itemnum/allnum)
											newjoinitemv = sdk.getsqlvalue("select round("& newjoinitemv &","& mbit &")",0)
											useds(ji) = cdbl(useds(ji)) + newjoinitemv
'newjoinitemv = sdk.getsqlvalue("select round("& newjoinitemv &","& mbit &")",0)
										end if
									end if
								end if
							end if
							Request.SetFormValue litemn & currmxid,  newjoinitemv
						end if
					end if
				next
			end sub
			public sub ShowFormValues
				dim i
				for i = 0 to ubound(request.FormValues)
					Response.write  request.FormValues(i)(0) & "===" & request.FormValues(i)(1) & "<br>"
				next
				Response.end
			end sub
			public sub ArrayAppend(byref arr,  byref v)
				dim c :  c = ubound(arr)+1
'public sub ArrayAppend(byref arr,  byref v)
				redim preserve arr(c)
				arr(c) =  v
			end sub
			private function ArrayIndexOf(byref arr,  byref v)
				dim i
				for i = 0 to  ubound(arr)
					if lcase(arr(i)) = lcase(v) then ArrayIndexOf = i : exit function
				next
				ArrayIndexOf =  -1
				if lcase(arr(i)) = lcase(v) then ArrayIndexOf = i : exit function
			end function
		end Class
		Public  SystemRequestObject :  Set SystemRequestObject = Request
		Class  ProductAttrProxyRequst
			Public QueryString
			Public ServerVariables
			Public Cookies
			Public  TotalBytes
			Public  FormValues
			Public Function BinaryRead(ByVal count)
				BinaryRead = SystemRequestObject.BinaryRead(count)
			end function
			Public Function AddFormValue(name,  value)
				Dim c: c = ubound(FormValues) + 1
'Public Function AddFormValue(name,  value)
				ReDim Preserve FormValues(c)
				FormValues(c) =  Array(name, value)
			end function
			Public Function SetFormValue(name,  value)
				name = LCase(name)
				For i = 0 To  ubound(FormValues)
					If LCase(FormValues(i)(0)) = name  Then
						FormValues(i)(1) =  value
						Exit Function
					end if
				next
				AddFormValue name, value
			end function
			Public Function Form(byval name)
				dim i
				name = LCase(name)
				For i = 0 To  ubound(FormValues)
					If LCase(FormValues(i)(0)) = name  Then
						Form = FormValues(i)(1)
						Exit Function
					end if
				next
			end function
			Public  Default Function  items(ByVal name)
				Dim r : r = QueryString(name)
				If Len(r & "") = 0 Then r = Form(name)
				items = r
			end function
			public sub Class_Initialize
				FormValues = Split("",",")
				TotalBytes = SystemRequestObject.TotalBytes
				Set QueryString = SystemRequestObject.QueryString
				Set ServerVariables = SystemRequestObject.ServerVariables
				Set Cookies = SystemRequestObject.Cookies
			end sub
		End Class
		
		function WriteStoreChangeLog(iOpType,sTableName,iProductId,iMXID,iStoreId,iInOrOut,iNumChg,iMoneyChg,iKuId)
			Dim sql, funcrs, insTitle, insOrder, insType, kuFieldName, insUnit
			Dim rsuname, insOrderId, insNumChg, insKuId, insMoneyNow, insNumNew
			Dim userip, insUnitName, insMoneyChg, insNumNow, insMoneyNew
			sql="select title,type1,order1 from product where ord=" & iProductId
			set funcrs=conn.execute(sql)
			if not funcrs.eof then
				insTitle=funcrs(0)
				insOrder=funcrs(2)
				insType=funcrs(1)
			else
				insTitle="【产品已删除】"
				insOrder=""
				insType=""
			end if
			funcrs.close
			kuFieldName=replace(replace(sTableName,"list2",""),"list","")
			sql="select * from " & sTableName & " with(nolock) where id=" & iMXID
			set funcrs=conn.execute(sql)
			insUnit=funcrs("unit")
			set rsuname=conn.execute("select sort1 from sortonehy where ord=" & insUnit)
			if rsuname.eof then
				insUnitName="已删除单位"
			else
				insUnitName=rsuname(0)
			end if
			rsuname.close
			insOrderId=funcrs(kuFieldName)
			funcrs.close
			insNumChg=cdbl(iNumChg)
			if Len(iKuId&"")=0 then
				insKuId=0
			else
				insKuId=clng(iKuid)
			end if
			insMoneyChg=cdbl(replace(iMoneyChg,",",""))
			if Len(iStoreId&"")=0 then
				iStoreId=0
			end if
			sql="select isnull(sum(num2),0) from ku where ord="&iProductId&" and unit='"&insUnit&"' and ck="&iStoreId
			insNumNow=cdbl(conn.execute(sql)(0))
			sql="select isnull(sum(case when num1>0 then cast(isnull(money1,0)*isnull(num2,0)/isnull(num1,1) as decimal(25,12)) else 0 end),0) from ku where ord="&iProductId&" and unit='"&insUnit&"' and ck="&iStoreId
			insMoneyNow=cdbl(conn.execute(sql)(0))
			if iInOrOut=1 then
				insNumNew=insNumNow+insNumChg
'if iInOrOut=1 then
				insMoneyNew=insMoneyNow+insMoneyChg
'if iInOrOut=1 then
			elseif iInOrOut=2 then
				insNumNew=insNumNow-insNumChg
'elseif iInOrOut=2 then
				insMoneyNew=insMoneyNow-insMoneyChg
'elseif iInOrOut=2 then
			else
				Response.write "参数错误！"
				call db_close : Response.end
			end if
			userip=getIP()
			sql="insert into Store_ChangeLog(OpDate,OperatorID,OperatorIP,OpType,OrderID,ProductID,ProductName,ProductOrder,ProductType,ProductUnit,ProductUnitName,KuId,StoreID,StoreInOrOut,StoreMoneyChange,StoreMoneyNew,StoreMoneyNow,StoreNumChange,StoreNumNew,StoreNumNow,TableName) values("&_
			getdate()&"','"&_
			session("personzbintel2007")&"','"&_
			userip&"','"&_
			iOpType&"','"&_
			insOrderId&"','"&_
			iProductId&"','"&_
			replace(insTitle & "","'","''")&"','"&_
			replace(insOrder & "","'","''")&"','"&_
			replace(insType & "","'","''")&"','"&_
			insUnit&"','"&_
			insUnitName&"','"&_
			insKuId&"','"&_
			iStoreId&"','"&_
			iInOrOut&"',"&_
			insMoneyChg&","&_
			insMoneyNew&","&_
			insMoneyNow&","&_
			insNumChg&","&_
			insNumNew&","&_
			insNumNow&",'"&_
			sTableName&"')"
			conn.execute sql
		end function
		function SaveReceiptsBeforeDel(sTableName,iReceiptsId)
			dim tmpFieldList,tmpMXFieldList
			select case sTableName
			case "kuhh"
			tmpFieldList=""
			tmpMXFieldList=""
			case "kuin"
			case "kujh"
			case "kumove"
			case "kuout"
			case "kupd"
			case "kuzz"
			case else
			end select
		end function
		Function CopyBillBeforChange(ByVal cn , ByVal dataType , ByVal dataId , ByVal remark, ByVal Creator)
			Dim Rs ,sql,ord, id : id= 0
			Set Rs = server.CreateObject("adodb.recordset")
			Rs.open "select * from erp_bill_ChangeLog where 1=2 ",cn,1,3
			Rs.addnew
			Rs("oid") = dataType
			Rs("bid") = dataId
			Rs("remark") = remark
			Rs("Creator") = Creator
			Rs("indate") = now()
			rs.update
			id=Rs("id")
			rs.close
			set rs = nothing
			dim cols1, cols2
			Select Case dataType
			Case -1:
'Select Case dataType
			sql="insert into contract_his([ord],[title],[htid],[sort],[complete1],[area],[trade],[premoney],[yhtype],[zk],[Inverse],[yhmoney],[money1],[money2],[bz],[date3],[date1],[date2],[person1],[person2],[pay],[intro],[addcate],[addcate2],[addcate3],[cateid],[cateid2],[cateid3],"&_
			"   [company],[person],[event1],[option1],[chance],[date7],[del],[delcate],[deldate],[zt1],[zt2],[contract],[cateid_sp],[sp],[del2],[alt],[money_tc1],[money_tc2],[tc],[price],[zdy1],[zdy2],[zdy3],[zdy4],[zdy5],[zdy6],[alt2],[person2id],[fqhk],[paybacktype],[share],"&_
			"                ""   [addshare],[ModifyStamp],[kujh],[sort1],[customerArr],[isTerminated],[paybackMode],[invoiceMode],[repairOrderId],[extras],[invoicePlan],[invoicePlanType],[taxRate],[op],[ip],[opdate],[receiver],[mobile],[phone],[address],[zip],[areaId],[AutoCreateType] ,[ChangeLog],DataVersion) """&_
			" select [ord],[title],[htid],[sort],[complete1],[area],[trade],[premoney],[yhtype],[zk],[Inverse],[yhmoney],[money1],[money2],[bz],[date3],[date1],[date2],[person1],[person2],[pay],[intro],[addcate],[addcate2],[addcate3],[cateid],[cateid2],[cateid3],"&_
			"   [company],[person],[event1],[option1],[chance],[date7],[del],[delcate],[deldate],[zt1],[zt2],[contract],[cateid_sp],[sp],[del2],[alt],[money_tc1],[money_tc2],[tc],[price],[zdy1],[zdy2],[zdy3],[zdy4],[zdy5],[zdy6],[alt2],[person2id],[fqhk],[paybacktype],[share],"&_
			"                ""   [addshare],[ModifyStamp],[kujh],[sort1],[customerArr],[isTerminated],[paybackMode],[invoiceMode],[repairOrderId],[extras],[invoicePlan],[invoicePlanType],[taxRate],"" & Creator & "",'"" & sdk.Info.IP() & ""',getdate(),[receiver],[mobile],[phone],[address],[zip],[areaId] ,[AutoCreateType] , "& id &",DataVersion "&_
			" from contract where ord = " & dataId
			cn.execute(sql)
			ord = sdk.setup.GetIdentity("contract_his","id", "op")
			sql = " insert into contractlist_his([his_id],[listid],[op_type],[ord],[unit],[num1],[price1],[money1],[pricejy],[tpricejy],[invoiceType],[taxRate],[extras],[concessions],[discount],[priceAfterDiscount],[taxValue],[priceAfterTaxPre],[priceAfterTax],[moneyBeforeTax],[moneyAfterTax],[moneyAfterConcessions],"&_
			"   [intro],[zdy1],[zdy2],[zdy3],[zdy4],[zdy5],[zdy6],[date1],[date2],[jf],ProductAttr1,ProductAttr2,ProductAttrBatchId ,commUnitAttr)" &_
			" select "& ord &",id,'MODIFY',[ord],[unit],[num1],[price1],[money1],[pricejy],[tpricejy],[invoiceType],[taxRate],[extras],[concessions],[discount],[priceAfterDiscount],[taxValue],[priceAfterTaxPre],[priceAfterTax],[moneyBeforeTax],[moneyAfterTax],[moneyAfterConcessions],"&_
			"   [intro],[zdy1],[zdy2],[zdy3],[zdy4],[zdy5],[zdy6],[date1],[date2],[jf],ProductAttr1,ProductAttr2,ProductAttrBatchId,commUnitAttr from contractlist where contract =" & dataId &" order by id "
			cn.execute(sql)
			Case -8:
			cn.execute(sql)
			sql="insert into chance_his([ord],[title],[xmid],[area],[trade],[complete1],[complete2],[sorce],[premoney],[yhtype],[zk],[Inverse],[yhmoney],[money1],[money2],[money3],[bz],[pay1],[intro],[date1],[date2],[date3],[cateid],[cateid2],[cateid3],[company],[person],[person_list],[contract],[product],[date7],[del],[delcate],[deldate],[order1],[cateid4],[cateorder1],[date5],[share],[zdy1],[zdy2],[zdy3],[zdy4],[zdy5],[zdy6],[bj],[num1],[addcate],[cateidfq],[sortfq],[datefq],[cateid_sp],[sp],[alt],[alt2],[del2],[chance],[ProcId],[ProcName],[op],[ip],[opdate],[ChangeLog]) "&_
			"            "" select [ord],[title],[xmid],[area],[trade],[complete1],[complete2],[sorce],[premoney],[yhtype],[zk],[Inverse],[yhmoney],[money1],[money2],[money3],[bz],[pay1],[intro],[date1],[date2],[date3],[cateid],[cateid2],[cateid3],[company],[person],[person_list],[contract],[product],[date7],[del],[delcate],[deldate],[order1],[cateid4],[cateorder1],[date5],[share],[zdy1],[zdy2],[zdy3],[zdy4],[zdy5],[zdy6],[bj],[num1],[addcate],[cateidfq],[sortfq],[datefq],[cateid_sp],[sp],[alt],[alt2],[del2],[chance],[ProcId],[ProcName]," & Creator & ",'" & sdk.Info.IP() & "',getdate(), "& id &" from chance where ord= " & dataId
			cn.execute(sql)
			ord = sdk.setup.GetIdentity("chance_his","id", "op")
			sql = " insert into chancelist_his([his_id],[listid],[ord],[price1],[num1],[money2],[date1],[chance],[del],[addcate],[bz],[date2],[date7],[zdy1],[zdy2],[zdy3],[zdy4],[zdy5],[zdy6],[unit],[intro],[pricejy],[tpricejy])" &_
			" select "& ord &",id,[ord],[price1],[num1],[money2],[date1],[chance],[del],[addcate],[bz],[date2],[date7],[zdy1],[zdy2],[zdy3],[zdy4],[zdy5],[zdy6],[unit],[intro],[pricejy],[tpricejy] from chancelist where chance =" & dataId
			cn.execute(sql)
			Case -11:
			cn.execute(sql)
			sql="insert into M_ProcedureProgres_his([chg_log],[chg_time],[chg_createby],[chg_ip],[id],[PrefixCode],[M_WorkAssigns],[Procedure],[bh],[title],[codeProduct],[cateid],[num1],[result],[intro],[creator],[inDate],[del]) "&_
			" select "& id &", getdate()," & Creator & ",'" & sdk.Info.IP() & "', [id],[PrefixCode],[M_WorkAssigns],[Procedure],[bh],[title],[codeProduct],[cateid],[num1],[result],[intro],[creator],[inDate],[del] from [M_ProcedureProgres] where id = " & dataId
			cn.execute(sql)
			Case -12:
			cn.execute(sql)
			cols1 = GetSameCol(cn, "caigou",  "caigou_his")
			cols2 = GetSameCol(cn, "caigoulist",  "caigoulist_his")
			cn.execute("INSERT INTO [dbo].[caigou_his](" & cols1 & ",[op],[ip],[opdate],[ChangeLog]) select " & cols1 & "," & Creator & ",'" & sdk.Info.IP() & "',getdate(), "& id &" from caigou where ord = " & dataId)
			ord = sdk.setup.GetIdentity("caigou_his","id", "op")
			cn.execute("insert into caigoulist_his([his_id],[listid]," & cols2 & ") select "& ord &",id," & cols2 & " from caigoulist where caigou =" & dataId)
			Case -31:
			sql="insert into design_his([ord],[PrefixCode],[title],[DesignBH],[designer],[date3],[apply],[applytime],[appoint],[date4],[abandon],[abandontime],[abandonintro],[sort1],[level],[plandate1],[plandate2],[startDate],[endDate],[zdy1],[zdy2],[zdy3],[zdy4],[zdy5],[zdy6],[intro],[designtype],[chance],[contract],[price],[M_PredictOrders],[M_ManuPlans],[designstatus],[id_sp],[cateid_sp],[status],[share_op],[share],[Creator],[indate],[del],[tempsave],[op],[ip],[opdate],[ChangeLog]) "&_
			"            "" select [id],[PrefixCode],[title],[DesignBH],[designer],[date3],[apply],[applytime],[appoint],[date4],[abandon],[abandontime],[abandonintro],[sort1],[level],[plandate1],[plandate2],[startDate],[endDate],[zdy1],[zdy2],[zdy3],[zdy4],[zdy5],[zdy6],[intro],[designtype],[chance],[contract],[price],[M_PredictOrders],[M_ManuPlans],[designstatus],[id_sp],[cateid_sp],[status],[share_op],[share],[Creator],[indate],[del],[tempsave]," & Creator & ",'" & sdk.Info.IP() & "',getdate(), "& id &" from Design where id = " & dataId
			cn.execute(sql)
			ord = sdk.setup.GetIdentity("design_his","id", "op")
			sql = " insert into Designlist_his([his_id],[Dlistid],[topid],[PrefixCode],[Design],[ProductID],[unit],[Date_DH],[DateStrat],[DateEnd],[date1],[date2],[zdy1],[zdy2],[zdy3],[zdy4],[zdy5],[zdy6],[intro],[listid],[del])" &_
			" select "& ord &",id,[topid],[PrefixCode],[Design],[ProductID],[unit],[Date_DH],[DateStrat],[DateEnd],[date1],[date2],[zdy1],[zdy2],[zdy3],[zdy4],[zdy5],[zdy6],[intro],[listid],[del] from Designlist where Design =" & dataId
			cn.execute(sql)
			Case Else :
			End Select
		end function
		function GetSameCol(byval cn, byval dbname1,  byval dbname2)
			dim rs ,  r: r =""
			set rs = cn.execute("select  a.name from sys.columns a inner join sys.columns  b on a.object_id=object_id('" & dbname1 & "') and b.object_id=object_id('" & dbname2 & "') and a.name=b.name and a.name<>'id'  ")
			while rs.eof = false
				if len(r)>0 then r = r & ","
				r = r & "[" & rs(0).Value & "]"
				rs.movenext
			wend
			rs.close
			set rs = nothing
			GetSameCol = r
		end function
		Function UpdateContractStatus(contractOrd , myConn)
			myConn.execute "exec [erp_contract_UpdateStatus] '" & contractOrd &"'"
		end function
		Function UpdateUserStore(conn ,uid ,sort, product , unit , ck)
			Dim sql ,rsuck
			sql="select * from UserStoreBinding where ProductID="& product &" and unit="&unit&" and Sort="& sort &" and UserID="& uid
			set rsuck=server.CreateObject("adodb.recordset")
			rsuck.open sql,conn,3,3
			if rsuck.eof then
				rsuck.addnew
				rsuck("ProductID")=product
				rsuck("unit")=unit
				rsuck("StoreID")=ck
				rsuck("Sort")=sort
				rsuck("UserID")=uid
			else
				rsuck("StoreID")=ck
			end if
			rsuck.update
			rsuck.close
			set rsuck=nothing
		end function
		Function GetFullStoreCode(conn, ck)
			Dim s ,rssort , sql ,ckParentID ,rstmp , tmpParent
			s = ""
			sql="select isnull(a.ParentID,0) as ParentID , a.StoreCode,b.StoreCode as ckCode from sortck1 a inner join sortck b on a.id=b.sort and b.id=" & ck
			set rssort=conn.execute(sql)
			if not rssort.eof then
				s = rssort("StoreCode")&"-"&rssort("ckCode")
'if not rssort.eof then
				ckParentID = rssort("ParentID").value & ""
				if len(ckParentID) = 0 then ckParentID = 0
				set rstmp=conn.execute("select isnull(ParentID,0) as ParentID from sortck1 where id=" & ckParentID)
				do while not rstmp.eof
					s = rstmp("StoreCode") & "-" & s
'do while not rstmp.eof
					tmpParent=rstmp("ParentID").value
					rstmp.close
					set rstmp=conn.execute("select * from sortck1 where id="& tmpParent)
				loop
				rstmp.close
				set rstmp=nothing
			end if
			rssort.close
			set rssort=Nothing
			GetFullStoreCode = s
		end function
		Function CheckStoreCapacity(conn , ck , product , unit , newNum , ByRef CapacityLeft)
			Dim sqlStore ,rsStore , FillPercent , StoreCapacity
			Dim isPassStoreCapacity : isPassStoreCapacity = False
			sqlStore= "SELECt sum(r) AS FillPercent FROM ("&_
			"          select isnull(sum(num2/StoreCapacity*100),0) as r FROM ( "&_
			"                  SELECT distinct a.num2,b.StoreCapacity,a.ord FROM ku a "&_
			"                  INNER JOIN (select distinct product,bm,unit,mainstore,StoreCapacity from jiage) b ON a.ord=b.Product AND a.unit=b.unit AND a.ck=b.MainStore AND b.bm=0 and isnull(StoreCapacity,0)<>0 "&_
			"                  AND a.ck="& ck &_
			"          ) x" &_
			"          UNION all" &_
			"          SELECT  isnull(sum(num2/StoreCapacity*100),0) as r  FROM ku a "&_
			"          INNER JOIN ProductStoreBinding b ON a.ord=b.ProductID AND a.unit=b.unit AND a.ck=b.StoreID and isnull(b.StoreCapacity,0)<>0 "&_
			"          AND a.ck="& ck &_
			"  ) y"
			set rsStore=conn.execute(sqlStore)
			FillPercent=cdbl(rsStore(0).value)
			rsStore.close
			CapacityLeft = 0
			sqlStore="SELECT isnull(StoreCapacity,0) FROM "&_
			"( "&_
			"SELECT distinct product,StoreCapacity FROM jiage WHERE product="& product &" AND unit="& unit &" AND bm=0 AND MainStore="& ck &_
			"UNION ALL "&_
			"SELECT distinct productid,StoreCapacity FROM ProductStoreBinding WHERE productid="& product &" AND unit="& unit &" AND storeid="& ck &_
			") a"
			set rsStore=conn.execute(sqlStore)
			if not rsStore.eof then
				StoreCapacity=cdbl(rsStore(0).value)
				if StoreCapacity>0 then
					CapacityLeft=StoreCapacity*(100-FillPercent)/100
'if StoreCapacity>0 then
					if cdbl(newNum)>CapacityLeft Then isPassStoreCapacity = True
				end if
			end if
			CheckStoreCapacity = isPassStoreCapacity
		end function
		
		function AutoKuinKuout(conn, BillType , BillID , uid, ishz)
			if BillType<>63001 then AutoKuinKuout="" : exit function
			dim rs,sql
			set rs = conn.execute("exec [erp_store_PanDian_AutoKuin] " & uid &"," &BillID & ",'"& getIP() &"',"& ishz )
			if rs.eof=false then
				if rs("r").value="false" then
					AutoKuinKuout = rs("msg").value
					exit function
				elseif rs("r").value<>"true" then
					rdrk =  rs("r").value
				end if
			end if
			rs.close
			dim rdck : rdck = 0
			set rs = conn.execute("exec [erp_store_PanDian_AutoKuout] " & uid &"," &BillID & ",'"& getIP() &"'" )
			if rs.eof=false then
				if rs("r").value="false" then
					AutoKuinKuout = rs("msg").value
					exit function
				elseif rs("r").value<>"true" then
					rdck =  rs("r").value
				end if
			end if
			rs.close
			if rdck<>"0" then
				Set rs = conn.execute("exec [erp_store_KuoutProc] " & uid & ",'" & rdck & "',0")
				If rs.eof = False Then
					while rs.eof = False
						msg = rs("msg")
						AutoKuinKuout = ""& msg&""
						exit function
						rs.movenext
					wend
				end if
				rs.close
				Set rs=Nothing
				conn.execute("select id as kuoutlist2, ck, ku as ID ,num1 as num2, isnull(datesc,'')  as datesc ,isnull(datesc,'') Daterk,isnull(dateyx,'')  as dateyx into #ku_kuout from kuoutlist2 where kuout in ( "& rdck &")")
				sql = "select top 1 p.title ,s.sort1 "&_
				"   from ku b  "&_
				"   inner join (select sum(num2) num2 ,ID from #ku_kuout group by ID ) a on a.ID=b.id "&_
				"   left join product p on p.ord= b.ord "&_
				"   left join sortck s on s.id = b.ck "&_
				"   where b.num2 < a.num2 "
				set rs = conn.execute(sql)
				If rs.eof = False Then
					AutoKuinKuout = rs("sort1") & " 【"& rs("title") &"】库存不足"
					exit function
				end if
				rs.close
				set rs = nothing
				conn.execute("update a set a.num1 = a.num1 + b.num1 "&_
				"from kuoutlist a  "&_
				"   inner join ( "&_
				"       select sum(num1) num1,kuoutlist from kuoutlist2 where kuout="& rdck &" group by kuoutlist  "&_
				"   ) b on a.id=b.kuoutlist")
				if ishz = 0 then
					conn.execute("exec [erp_comm_store_ChangeLog] 200,'" & rdck & "'," & uid & ",'" & getIP() & "'")
				else
					conn.execute("exec [erp_comm_store_ChangeLog] 211,'" & rdck & "'," & uid & ",'" & getIP() & "'")
				end if
				conn.execute("update b set b.num2 = b.num2 - a.num2 from ku b inner join (select sum(num2) num2 ,ID from #ku_kuout group by ID ) a on a.ID=b.id")
				conn.execute("exec [erp_comm_store_ChangeLog] 211,'" & rdck & "'," & uid & ",'" & getIP() & "'")
				conn.execute("drop table #ku_kuout")
			end if
			sql="Update kupd set complete1=3 where ord="& BillID &""
			conn.execute(sql)
			AutoKuinKuout = ""
		end function
		function AutoKuinKuoutHzPd(conn, BillType , BillID , uid)
			AutoKuinKuoutHzPd = AutoKuinKuout(conn, BillType , BillID , uid, 3)
		end function
		
		sub page_init
			app.vPath = "../../Manufacture/inc/"
		end sub
		sub page_load
			Response.write "<style>html{padding:0px}</style>"
			Response.write "" & vbcrlf & "<script language=""javascript"" src='/inc/dateid.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "<script type=""text/javascript"">      " & vbcrlf & "        function fMove(obj){" & vbcrlf & "            if(obj.offsetWidth<197){" & vbcrlf & "                        obj.style.width = 197;" & vbcrlf & "          }" & vbcrlf & "       }" & vbcrlf & "       try{" & vbcrlf & "            window.parent.document.getElementsByName(""I1"")[0].style.height = ""1100px"";" & vbcrlf & "        }catch(e){}" & vbcrlf & "</script>" & vbcrlf & "<frameset cols='197,*' border=""10"" frameSpacing=10 frameborder=1 style='border:4px solid white'>" & vbcrlf & "              <frame src='?__msgId=ckcptreelist&musthasnum=2' frameborder=0 bordercolor=""#fefeff"" style='min-width:197px' onresizex='return fMove(this)'></frame>" & vbcrlf & "          <frame src='?__msgId=addpdPage&"
			Response.write request.querystring
			Response.write "'  frameborder=0></frame>" & vbcrlf & "</frameset>" & vbcrlf & ""
		end sub
		Sub App_ckcptreelist
			Response.write app.headhtml
			Response.write "<style>html{padding:0px}</style>"
			Response.write "" & vbcrlf & "<body class='areaGrid' style='margin-top:0px;padding-top:0px;margin-right:0px;width:100%;'>" & vbcrlf & "   <style> " & vbcrlf & "                        li.tvw_item {" & vbcrlf & "                           list-style-type:none;" & vbcrlf & "                           cursor:default;" & vbcrlf & "                         font-size:12px;" & vbcrlf & "                         font-family:宋体;" & vbcrlf & "                          width:100%;" & vbcrlf & "                             line-height:16px;" & vbcrlf & "                               color:#2F496E;" & vbcrlf & "                  }" & vbcrlf & "                       ul.tvw_child{" & vbcrlf & "                           margin-left:6px;" & vbcrlf & "                            background-color:transparent;" & vbcrlf & "                           text-indent:0px;" & vbcrlf & "                        }" & vbcrlf & "                       .treebg{" & vbcrlf & "                                _width:99%;" & vbcrlf & "                             overflow-x:hidden;      " & vbcrlf & "                        }" & vbcrlf & "                       html {padding-top:0px}" & vbcrlf & "                  #divdlg_xsaadax{" & vbcrlf & "                                left:0px!important;" & vbcrlf & "                   }" & vbcrlf & "       </style>        " & vbcrlf & "        <script language=javascript src='../../Manufacture/inc/treeview.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <script type=""text/javascript"">" & vbcrlf & "           window.onresizeTime = 0" & vbcrlf & "         document.body.style.cssText=""padding-top:0px;padding-left:0px;padding-right:0px;margin-top:0px;width:100%""" & vbcrlf & "                function onlistsize(){" & vbcrlf & "                  var d = new Date();" & vbcrlf & "                   if(d.getTime()-window.onresizeTime<1){ return false;} //限制连续触发该操作" & vbcrlf & "                      window.onresizeTime = d.getTime()" & vbcrlf & "                       var dv = document.getElementById(""listdata"")" & vbcrlf & "                      if(dv.children.length==0){return;}" & vbcrlf & "                      //if(dv.children[0].offsetHeight > document.body.offsetHeight-105){" & vbcrlf & "                     //      dv.style.height = (document.body.offsetHeight-105) + ""px""" & vbcrlf & "                 //}" & vbcrlf & "                     //else{" & vbcrlf & "                 //      dv.style.height = ""auto""" & vbcrlf & "                  //}" & vbcrlf & "             }" & vbcrlf & "               function showGroup(){ //只显示分类，其他全部收缩" & vbcrlf& "                        var bg = document.getElementById(""listdata"")" & vbcrlf & "                      if(bg.treeHTML && bg.treeHTML.length>0){" & vbcrlf & "                                bg.innerHTML = bg.treeHTML" & vbcrlf & "                              bg.treeHTML = """"" & vbcrlf & "                          document.getElementById(""listdatakeyarea"").style.display = ""none"";" & vbcrlf & "                  }" & vbcrlf & "                  var imgs = bg.getElementsByTagName(""img"")" & vbcrlf & "                 for(var i = 0 ; i <imgs.length ; i++) {" & vbcrlf & "                         if(imgs[i].src.indexOf(""minus.gif"")>0){" & vbcrlf & "                                   var t = imgs[i].parentElement.parentElement.innerText.replace(/\s/g,"""");" & vbcrlf & "                                  if(t!=""仓库产品""){ "& vbcrlf &                          "                    tvw.expNode(imgs[i]) "& vbcrlf &                 "                    } "& vbcrlf &                            "    } "& vbcrlf &           "             } "& vbcrlf &            "            onlistsize() "& vbcrlf &         "    } "& vbcrlf & vbcrlf &      "          function showAll(){ //只显示分类，其他全部收缩 "& vbcrlf &               "    var bg = document.getElementById(""listdata"") "& vbcrlf &         "              if(bg.treeHTML && bg.treeHTML.length>0){" & vbcrlf & "                          bg.innerHTML = bg.treeHTML" & vbcrlf & "                              bg.treeHTML = """"" & vbcrlf & "                          document.getElementById(""listdatakeyarea"").style.display = ""none"";" & vbcrlf & "                  }" & vbcrlf & "                       var imgs = bg.getElementsByTagName(""img"")" & vbcrlf & "                 for(var i = 0 ; i <imgs.length ; i++) {" & vbcrlf & "                                if(imgs[i].src.indexOf(""plus.gif"")>0){" & vbcrlf & "                                    //if(imgs[i+2].id==""nokuimg"")" & vbcrlf & "                                     //{" & vbcrlf & "                                     //      break;" & vbcrlf & "                                  //}" & vbcrlf & "                                     var t = imgs[i].parentElement.parentElement.innerText.replace(/\s/g,"""");" & vbcrlf & "                                   if(t!=""仓库产品""){ " & vbcrlf & "                                               tvw.expNode(imgs[i])" & vbcrlf & "                                    }" & vbcrlf & "                               }" & vbcrlf & "                       }" & vbcrlf & "                       onlistsize()" & vbcrlf & "            }" & vbcrlf & "" & vbcrlf & "               function Searchkeylist(ajCode){" & vbcrlf & "                 var keyName = document.getElementById(""sType"").value;" & vbcrlf & "                     var keyv = document.getElementById(""keyValue"").value;                     " & vbcrlf & "                        ajax.regEvent(""SearchList"");" & vbcrlf & "                      ajax.addParam(""hasnum"","""
			Response.write request.querystring("musthasnum")
			Response.write """);" & vbcrlf & "                        ajax.addParam(""kn"",keyName);" & vbcrlf & "                      if(ajCode){" & vbcrlf & "                             ajax.addParam(""ajCode"", ajCode);" & vbcrlf & "                          ajax.addParam(""kv"","""");" & vbcrlf & "                     }" & vbcrlf & "                       else{" & vbcrlf & "                           ajax.addParam(""kv"",keyv);" & vbcrlf & "                 }" & vbcrlf & "       ajax.send(keylistdataadriver);" & vbcrlf & "          }" & vbcrlf & "               " & vbcrlf & "                function stopPropagation(e) {" & vbcrlf & "                   e = e || window.event;" & vbcrlf & "                  if(e.stopPropagation) { //W3C阻止冒泡方法" & vbcrlf & "                               e.stopPropagation();" & vbcrlf & "                    } else {" & vbcrlf & "                                e.cancelBubble = true; //IE阻止冒泡方法" & vbcrlf & "                        }" & vbcrlf & "               }" & vbcrlf & "" & vbcrlf & "               function keylistdataadriver(r){" & vbcrlf & "                 var bg = document.getElementById(""listdata"")" & vbcrlf & "                      if(!bg.treeHTML || bg.treeHTML.length==0){" & vbcrlf & "                              bg.treeHTML = bg.innerHTML" & vbcrlf & "                              document.getElementById(""listdatakeyarea"").style.display = ""block"";" & vbcrlf & "                   }" & vbcrlf & "                       try{" & vbcrlf & "                            bg.innerHTML = r;" & vbcrlf & "                       }" & vbcrlf & "                       catch(e){}" & vbcrlf & "                      //onlistsize()" & vbcrlf & "          }" & vbcrlf & "" & vbcrlf & "               function showuline(o){" & vbcrlf & "  o.style.textDecoration = ""underline""" & vbcrlf & "              }" & vbcrlf & "               " & vbcrlf & "                function hideuline(o){" & vbcrlf & "                  o.style.textDecoration = ""none""" & vbcrlf & "           }" & vbcrlf & "               " & vbcrlf & "                function ItemSelect(cpID,ckID , xlh){" & vbcrlf & "                   var dat = new Array;" & vbcrlf & "  if(xlh==undefined) xlh = """";" & vbcrlf & "                 dat[0] = cpID + ""|"" + ckID + ""|"" + xlh;" & vbcrlf & "                     if(window.top.TreeDataSelect){" & vbcrlf & "                          window.top.TreeDataSelect(dat);" & vbcrlf & "                 }" & vbcrlf & "               }" & vbcrlf & "               " & vbcrlf & "                tvw.ongetChildren = function(li){  //更新节点" & vbcrlf & "                     var v = li.getAttribute(""tag"").split(""-"")" & vbcrlf & "                   if(v[2] < 3){" & vbcrlf & "                           if(li.nextSibling.children[0].innerHTML==""""){" & vbcrlf & "                                     ajax.addParam(""ord"",v[1]);" & vbcrlf & "                                        ajax.addParam(""type"",v[2]);" & vbcrlf & "                                       ajax.addParam(""musthasnum"","""
			'Response.write request.querystring("musthasnum")
			Response.write """);" & vbcrlf & "                                        ajax.addParam(""update"",""1"")" & vbcrlf & "                         }" & vbcrlf & "                       }" & vbcrlf & "               }" & vbcrlf & "               //-----新增产品展开------" & vbcrlf & "               var bing = 0" & vbcrlf & "            function resulthandle(li) {" & vbcrlf & "                     return function (r)" & vbcrlf & "                     {" & vbcrlf & "                               r = r.split(""\1!$\1"");" & vbcrlf & "                         bing = 0" & vbcrlf & "                                li.setAttribute(""ords"", r[0]);" & vbcrlf & "                            li.nextSibling.children[0].innerHTML = r[1];" & vbcrlf & "                            tvw.expNode(li.getElementsByTagName(""img"")[0]);" & vbcrlf & "                           if(r[0].length>0)" & vbcrlf & "                               {" & vbcrlf & "                                       if(r[0]) {" & vbcrlf & "                                         var ids = r[0].split("","");" & vbcrlf & "                                                for (var i = 0; i< ids.length; i++ )" & vbcrlf & "                                            {" & vbcrlf & "                                                       ids[i] = ids[i] + ""|0""" & vbcrlf & "                                            }" & vbcrlf & "                                               //window.top.TreeDataSelect(ids);" & vbcrlf & "                                       }" & vbcrlf & "                               }" & vbcrlf & "} "& vbcrlf &     "           } "& vbcrlf &      "          tvw.itemClick = function(li){ "& vbcrlf &              "      var id = li.getAttribute(""tag"")//ie8910无法通过“.属性名”方法获取属性 "& vbcrlf &              "       if(id&&id.indexOf(""sys_pdm_"")==0){ "& vbcrlf &                            "     addcptreenode(li) "& vbcrlf &                     "           return; "& vbcrlf &        "          } "& vbcrlf &      "          }"& vbcrlf &"         function addcptreenode(li){" & vbcrlf & "                     if (bing == 1) { return }" & vbcrlf & "                       var id = li.getAttribute(""tag"").replace(""sys_pdm_"","""")" & vbcrlf & "                        ajax.url = window.location.href.split(""?"")[0]" & vbcrlf & "                     ajax.regEvent(""AddCPTreeItem"");" & vbcrlf & "                   ajax.addParam(""key"",id);" & vbcrlf & "                   ajax.addParam(""selID"",""-4"");" & vbcrlf & "                        ajax.addParam(""sql"", '');" & vbcrlf & "                 li.nextSibling.style.display = ""block"";" & vbcrlf & "                   bing = 1" & vbcrlf & "                        li.nextSibling.children[0].innerHTML = ""<span style='color:blue'>&nbsp;&nbsp;&nbsp;&nbsp;正在加载,请稍等...</span>""" & vbcrlf & "                        ajax.send(resulthandle(li));" & vbcrlf & "            }" & vbcrlf & "               " & vbcrlf & "                tvw.NodeClick = function(li){" & vbcrlf & "                   if(li.getAttribute(""tag"")==""仓库产品""){" & vbcrlf & "                             return " & vbcrlf & "                 }" & vbcrlf & "                       " & vbcrlf & "                        if((li.getAttribute(""tag"") + """").indexOf(""node-"") ==0){" & vbcrlf &                      "      var dat = new Array "& vbcrlf &                        "      var v = li.getAttribute(""tag"").split(""-"")" & vbcrlf &                 "           if(v[2] >=2){ " & vbcrlf &              "                     if(v[2]==3){ dat[0] = v[1];} "& vbcrlf &         "                            else{//选择的是仓库" & vbcrlf &                              "                var nextchilds = li.nextSibling.children[0];" & vbcrlf & "                                          for(var i = 0;i<nextchilds.children.length;i=i+2){" & vbcrlf & "                                                  dat[i/2] = nextchilds.children[i].getAttribute(""tag"").split(""-"")[1] " & vbcrlf & "                                            }" & vbcrlf & "                                       }" & vbcrlf & "                                       if(window.top.TreeDataSelect){" & vbcrlf & "                                          //返回产品ID, 仓库ID" & vbcrlf & "                                             window.top.TreeDataSelect(dat);" & vbcrlf & "                                 }" & vbcrlf & "                               }" & vbcrlf & "                               return" & vbcrlf & "                  }" & vbcrlf & "                       else{" & vbcrlf & "                           if(isNaN(li.getAttribute(""tag""))==false)" & vbcrlf & "                          {" & vbcrlf & "                                       //只返回产品ID" & vbcrlf & "                                  var r = new Array()" & vbcrlf & "                                      r[0] = li.getAttribute(""tag"") + ""|0""" & vbcrlf & "                                        window.top.TreeDataSelect(r);" & vbcrlf & "                           }" & vbcrlf & "                               else" & vbcrlf & "                            {" & vbcrlf & "                                       var ids = li.getAttribute(""ords"");" & vbcrlf & "                                        if(ids) {" & vbcrlf & "                                               ids = ids.split("","");" & vbcrlf & "     for (var i = 0; i< ids.length; i++ )" & vbcrlf & "                                            {" & vbcrlf & "                                                       ids[i] = ids[i] + ""|0""" & vbcrlf & "                                            }" & vbcrlf & "                                               window.top.TreeDataSelect(ids);" & vbcrlf & "                                 }" & vbcrlf & "                               }" & vbcrlf & "                       }" & vbcrlf & "               }" & vbcrlf & "" & vbcrlf & "               function ShowAdvance(button){ //显示高级搜索" & vbcrlf & "                  var ie6 = false;" & vbcrlf & "                        if (window.ActiveXObject) {" & vbcrlf & "                             var ua = navigator.userAgent.toLowerCase();" & vbcrlf & "                             var ie=ua.match(/msie ([\d.]+)/)[1];" & vbcrlf & "                            ie6 = (ie == 6.0);" & vbcrlf & "                      }" & vbcrlf & "                       if(ie6 && window.parent) {" & vbcrlf & "                           var div = window.parent.document.getElementById(""divdlg_sasd"");" & vbcrlf & "                           if(div) {" & vbcrlf & "                                       try{" & vbcrlf & "                                            if(div.bgDiv) { div.bgDiv.outerHTML="""";}" & vbcrlf & "                                          div.outerHTML = """";       " & vbcrlf & "                                        }catch(e){}" & vbcrlf & "                             }" & vbcrlf & "                  }" & vbcrlf & "                       div = window.parent.DivOpen(""sasd"",""高级检索"",400,570,70,document.getElementById(""jsdiv"").offsetWidth-2,true,10);" & vbcrlf & "                     if(!window.apageHTML ) {" & vbcrlf & "                                var url = ajax.url;" & vbcrlf & "                             ajax.url = ""addPd.asp"";" & vbcrlf & "                           ajax.regEvent(""ShowAdvance""); "& vbcrlf &                  "         window.apageHTML = ajax.send(); "& vbcrlf & "                         div.innerHTML = window.apageHTML; "& vbcrlf &             "                   ajax.url = url; "& vbcrlf &       "           }" & vbcrlf &                "        else{ "& vbcrlf &           "                 div.innerHTML = window.apageHTML; "& vbcrlf &        "                } "& vbcrlf &          "              var height2 = window.parent.document.getElementById(""adsIF"").offsetHeight;" & vbcrlf & "            if (height2>510)" & vbcrlf & "            {" & vbcrlf & "                height2 = Number(height2);" & vbcrlf & "                div.style.height =556;" & vbcrlf & "                window.parent.document.getElementById(""divdlg_sasd"").style.height=(height2+70) + ""px"";" & vbcrlf & "            }" & vbcrlf & "          }" & vbcrlf & "" & vbcrlf & "               window.parent.expNode = function(img){" & vbcrlf & "                  var isCollapsed = img.src.indexOf(""plus.gif"")>0;" & vbcrlf & "                  var $img = $(img);" & vbcrlf & "                      var $tr = $img.parent().parent();" & vbcrlf & "                 var $box = $tr.next();" & vbcrlf & "                  var id = $tr.find(':checkbox').attr('tag');" & vbcrlf & "                     if (isCollapsed){" & vbcrlf & "                               if (!$img.attr('loaded')){" & vbcrlf & "                                      $.ajax({" & vbcrlf & "                                                url:'?__msgId=getNode&id=' + id," & vbcrlf & "                                                async:false,"& vbcrlf &                               "               cache:false, "& vbcrlf &                               "              success:function(html){ "& vbcrlf &                                       "           $box.show().children().eq(1).html"& vbcrlf & "                               }" & vbcrlf & "                       })}else{" & vbcrlf & "                          $box.hide();" & vbcrlf & "                    }" & vbcrlf & "                       $img.attr('src',isCollapsed?""../../images/smico/minus.gif"":""../../images/smico/plus.gif"")" & vbcrlf & "           }" & vbcrlf & "" & vbcrlf & "               function getckInputs(div){" & vbcrlf & "                      var cs = new Array();" & vbcrlf & "                   var elms = div.getElementsByTagName(""input"")" & vbcrlf & "                      for(var i = 0 ;  i < elms.length ; i ++){" & vbcrlf & "                               if(elms[i].checked==true && !elms[i].getAttribute(""isAll"")){" & vbcrlf & "                                      cs[cs.length] = elms[i].tag;" & vbcrlf & "                            }" & vbcrlf & "                       }                       " & vbcrlf & "                        return cs.join("","");" & vbcrlf & "              }" & vbcrlf & "" & vbcrlf & "               window.parent.doASearch = function(si, asvsi){                  " & vbcrlf & "                        var doc = window.parent.document;" & vbcrlf & "                       var code = new Array();" & vbcrlf & "                 for(var i = 1; i <= si ; i++){" & vbcrlf & "                          var elem = doc.getElementById(""a_s"" + i);                          " & vbcrlf & "                                if (elem.tagName == ""INPUT"" && !elem.getAttribute(""iscpfl"")){" & vbcrlf & "                                   code[code.length] =  elem.id + ""\1\2"" + elem.getAttribute(""db"") + ""\1\2"" + elem.value;                                    " & vbcrlf & "                                }else if (elem.tagName == ""SELECT""){" & vbcrlf & "                                 code[code.length] =  elem.id + ""\1\2"" + elem.getAttribute(""db"") + ""\1\2"" + elem.options[elem.selectedIndex].value;        " & vbcrlf & "                                }else{" & vbcrlf & "                              code[code.length] =  elem.id + ""\1\2"" + elem.getAttribute(""db"") + ""\1\2"" + getckInputs(elem);" & vbcrlf & "                             }" & vbcrlf & "                        }" & vbcrlf & "                       Searchkeylist(code.join(""\3\4""));" & vbcrlf & "         }" & vbcrlf & "" & vbcrlf & "               window.parent.kdown = function(txt)" & vbcrlf & "             {" & vbcrlf & "                       if(window.parent.event.keyCode==13) " & vbcrlf & "                    {" & vbcrlf & "                               window.parent.document.getElementById(""doAsButton"").click(); "& vbcrlf &                        "  txt.focus(); "& vbcrlf &                            " txt.select(); "& vbcrlf &                       "     window.parent.event.returnValue=false; "& vbcrlf &                    "       return false" & vbcrlf &   "                  } "& vbcrlf &         "       } "& vbcrlf & vbcrlf &         "       window.parent.ckcpflall = function(obj) {" & vbcrlf &          "              var box = parent.document.getElementsByName(""cpfl"");" & vbcrlf & "                 var checked = obj.checked;" & vbcrlf & "                      for (var i = 0; i < box.length ; i++)" & vbcrlf & "                   {" & vbcrlf & "                               box[i].checked =  checked;" & vbcrlf & "                      }" & vbcrlf & "               }" & vbcrlf & "" & vbcrlf & "               window.srcckckall = function(obj) {" & vbcrlf & "                      var box = document.getElementsByName(""srcck"");" & vbcrlf & "                    var checked = obj.checked;" & vbcrlf & "                      for (var i = 0; i < box.length ; i++)" & vbcrlf & "                   {" & vbcrlf & "                               box[i].checked =  checked;" & vbcrlf & "                      }" & vbcrlf & "               }" & vbcrlf & "" & vbcrlf & "               function addsrcclick() {" & vbcrlf & "                 var box = document.getElementsByName(""srcck"");" & vbcrlf & "                    var data = new Array();" & vbcrlf & "                 for (var i = 0; i < box.length ; i++)" & vbcrlf & "                   {" & vbcrlf & "                               if(box[i].checked == true) {" & vbcrlf & "                                    data[data.length] = box[i].getAttribute(""value"").replace("","",""|"").replace("","",""|"");" & vbcrlf & "                          }" & vbcrlf & "                       }" & vbcrlf & "                       if(data.length > 0){" & vbcrlf & "                            if(window.top.TreeDataSelect) {" & vbcrlf & "                                 window.top.TreeDataSelect(data);" & vbcrlf & "                                }" & vbcrlf & "                       }" & vbcrlf & "        }" & vbcrlf & " }"& vbcrlf &"</script>" & vbcrlf & "       " & vbcrlf & "" & vbcrlf & "        <div class=""leftPageBgPd"" style='height:43px;background-image:url(../../images/smico/tree_st_c.gif);overflow:hidden'>" & vbcrlf & "             <div class=""resetElementHidden"" style='float:left;background-image:url(../../images/smico/tree_st_l.gif);width:15px;height:40px'></div>" & vbcrlf & "                <div class=""resetElementHidden"" style='float:right;background-image:url(../../images/smico/tree_st_r.gif);width:8px;height:40px'></div>" & vbcrlf & "           <div class=""resetTransparent"" style='height:40px;overflow:hidden'>" & vbcrlf & "                        <div class=""resetTransparent resetTextColor333"" style='margin-top:13px;margin-left:1px;font-weight:bold;font-size:14px;color:#5555aa;white-space:nowrap;'>首页 > 仓库产品选择</div>" & vbcrlf & "               </div>" & vbcrlf & "  </div>" & vbcrlf & "  " & vbcrlf & "        <div style='height:2px;overflow:hidden'></div>" & vbcrlf & "  " & vbcrlf& "        <div style='background-image:url(../../images/smico/tree_js_c.gif);height:26px;overflow:hidden;white-space:nowrap;' id='jsdiv'>" & vbcrlf & "         <div style='float:left;background-image:url(../../images/smico/tree_js_l.gif);width:4px;height:40px'></div>" & vbcrlf & "             <div style='float:right;background-image:url(../../images/smico/tree_js_r.gif);width:4px;height:40px'></div>" & vbcrlf & "              <div style='margin-top:5px;height:25px;overflow:hidden'>" & vbcrlf & "                        <table style='width:99%;table-layout:auto'>" & vbcrlf & "                     <tr>" & vbcrlf & "                            <td style='width:auto;padding-left:2px'>" & vbcrlf& "                                        "
			set rs5=server.CreateObject("adodb.recordset")
			sql5="select intro from setopen  where sort1=17 "
			rs5.open sql5,cn,1,1
			if rs5.eof then
				optV=1 = 0
			else
				optV=rs5("intro")
			end if
			rs5.close
			set rs5=Nothing
			Select Case optV
			Case 1
			optV = "proName"
			Case 2
			optV = "proOrder"
			Case 3
			optV = "proModel"
			Case 4
			optV = "proBarcode"
			Case 5
			optV = "proPINYIN"
			case 7
			optV = "xlh"
			Case Else
			optV= ""
			End Select
			Response.write "" & vbcrlf & "                                     <select id='sType' onchange=""Searchkeylist()"" style='padding:1px;'>" & vbcrlf & "                                               <option value=1 "
			If optV = "proName" Then
				Response.write "selected=""selected"""
			end if
			Response.write ">产品名称</option>" & vbcrlf & "                                           <option value=2 "
			If optV = "proOrder" Then
				Response.write "selected=""selected"""
			end if
			Response.write ">产品编号</option>" & vbcrlf & "                                           <option value=3 "
			If optV = "proModel" Then
				Response.write "selected=""selected"""
			end if
			Response.write ">产品型号</option>" & vbcrlf & "                                           <option value=4 "
			If optV = "proBarcode" Then
				Response.write "selected=""selected"""
			end if
			Response.write ">条形码</option>" & vbcrlf & "                                             <option value=5 "
			If optV = "proPINYIN" Then
				Response.write "selected=""selected"""
			end if
			Response.write ">拼音码</option>" & vbcrlf & "                        <option value=7 "
			If optV = "xlh" Then
				Response.write "selected=""selected"""
			end if
			Response.write ">序列号</option>" & vbcrlf & "                                             <option value=6 >仓库名称</option>" & vbcrlf & "                                      </select>" & vbcrlf & "                               </td>" & vbcrlf & "                           <td style='width:2px'></td>" & vbcrlf & "                             <td><input type=text style='text-align:center;color:#ccc;width:100%;font-size:12px;height:16px;line-height:16px;*height:18px;;padding:0px;overflow:hidden' value='输入后按回车搜索' init=1 onclick='if(this.getAttribute(""init"")==1&&this.value==""输入后按回车搜索""){this.value="""";this.style.color=""#000""}' id='keyValue' maxlength=100 onblur='if(this.value.length==0){this.setAttribute(""init"",""1"");this.value=""输入后按回车搜索"";this.style.color=""#ccc""}' onkeyup='Searchkeylist();' onkeypress='stopPropagation(event)'></td>" & vbcrlf & "                             <td style='width:2px'></td>" & vbcrlf & "                             <td style='width:auto'><button class='button'style='height:20px;width:34px;margin-left:0' onclick='ShowAdvance(this)'>高级</button></td>" & vbcrlf &"                 </tr>" & vbcrlf & "                   </table>" & vbcrlf & "                </div>" & vbcrlf & "  </div>" & vbcrlf & "  <div class=""resetBorderColor"" style='height:3px;border:1px solid #a7bbd6;border-top:0px;border-bottom:0px;overflow:hidden'></div>" & vbcrlf & " <div class=""resetBgF5 resetBorderColor"" style='border:1px solid #a7bbd6;border-top:0px;background-image:url(../../images/smico/lmeuntab_bg_c.gif);height:23px;overflow:hidden;position:relative;z-index:100'>" & vbcrlf & "          <div style='float:left'><img class=""resetElementShow""src='../../skin/default/images/MoZihometop/leftNav/expand.png' style='margin-top:7px;margin-left:4px;display:none'></div>" & vbcrlf & "              <div style='float:right;margin-top:6px'>" & vbcrlf & "                        <table>" & vbcrlf & "                 <tr>" & vbcrlf & "                            <td style='text-align:right'><span class=link style='color:red' onmouseover='this.style.textDecoration=""underline""' onmouseout='this.style.textDecoration=""none""' onclick='showGroup()'>显示分类</span>&nbsp;" & vbcrlf & "                              <span class=link  style='color:red' onmouseover='this.style.textDecoration=""underline""' onmouseout='this.style.textDecoration=""none""' onclick='showAll()'>" & vbcrlf & "                          "
			If request.querystring("musthasnum")=2 Then
				Response.write "展开库存"
			else
				Response.write "全部展开"
			end if
			Response.write "</span>&nbsp;</td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   </table>" & vbcrlf & "                </div>" & vbcrlf & "          <div style='margin-top:6px;'>" & vbcrlf & "                   <table>" & vbcrlf & "                 <tr>" & vbcrlf & "                            <td style='width:3px'></td>" & vbcrlf & "                             <td><span class='link resetTextColor333' style='font-size:12px'><b>产品分类</b></span></td>" & vbcrlf & "                       </tr>" & vbcrlf & "                   </table>" & vbcrlf & "                </div>" & vbcrlf & "  </div>" & vbcrlf & "  <div  id='listdata' class=""resetBorderColor"" style='border:1px solid #a7bbd6;border-top:0px;border-bottom:0px;overflow-x:hidden;overflow-y:auto;position:absolute;top:95px;left:0px;right:0px;bottom:40px;'>" & vbcrlf & "                <div class='treebg'>" & vbcrlf & "            <div onmousedown='onlistsize()' style='margin-top:6px;margin-left:12px;'>" & vbcrlf & "                       "
			'Response.write "全部展开"
			call App_datalist
			Response.write "" & vbcrlf & "             </div>" & vbcrlf & "          </div>" & vbcrlf & "  </div>" & vbcrlf & "" & vbcrlf & "  <div id='listdatab' style='width:100%;position:absolute;height:8px;bottom:22px;background-image:url(../../images/smico/tree_js_bc.gif);overflow:hidden'>" & vbcrlf & "                <div style='float:left;background-image:url(../../images/smico/tree_js_bl.gif);width:8px;height:8px'></div>" & vbcrlf & "         <div style='float:right;background-image:url(../../images/smico/tree_js_br.gif);width:8px;height:8px'></div>" & vbcrlf & "    </div>" & vbcrlf & "  <div  style='position:absolute;height:40px;left:0px;right:0px;bottom:0px;overflow:hidden;display:none;background-image: url(""../../images/m_table_b.jpg"");' id='listdatakeyarea'>" & vbcrlf & "              <div style='height:4px;overflow:hidden'></div>" & vbcrlf & "          &nbsp;<input type='checkbox' id='srcckall' onclick='srcckckall(this)'><label for='srcckall' style='color:#2f496e'>全选</label>" & vbcrlf & "          &nbsp;&nbsp;" & vbcrlf & "            <button class='button' onclick='addsrcclick()'>加入</button>" & vbcrlf & "    </div>" & vbcrlf & "  <script>" & vbcrlf & "                function bodyresize() {" & vbcrlf & "                 var o1 = document.getElementById(""listdata"");" & vbcrlf & "                     var o2 = document.getElementById(""listdatab"");" & vbcrlf & "                  var o3 = document.getElementById(""listdatakeyarea"");" & vbcrlf & "                      o1.style.height = (document.documentElement.clientHeight - 120) + ""px"";" & vbcrlf & "                   o1.style.width = (document.documentElement.clientWidth-2) + ""px"";" & vbcrlf & "         }" & vbcrlf & "     </script>" & vbcrlf & "       <!--[if IE 6]>" & vbcrlf & "  <script language='javascript'>" & vbcrlf & "  window.onresize = bodyresize;" & vbcrlf & "   bodyresize()" & vbcrlf & "    </script>" & vbcrlf & "       <![endif]-->" & vbcrlf & "</body>" & vbcrlf & ""
			'call App_datalist
		end sub
		sub App_ShowAdvance
			dim bText
			bText = "font-size:12px;height:20px;line-height:18px;font-family:arial;font-weight:bold"
'dim bText
			Response.write "" & vbcrlf & "<table style='width:100%; position:relative;' id=""adsIF"">" & vbcrlf & "<tr>" & vbcrlf & "  <th class='c_b' style='padding-top:5px;text-align:left' colspan='2'>&nbsp;仓库</th>" & vbcrlf & "</tr>" & vbcrlf & "<tr><td></td><td>" & vbcrlf & "               <table style='height:50px'>" & vbcrlf & "<tr>" & vbcrlf & "                    <td class='c_c'>仓库条码：</td>" & vbcrlf & "                 <td><input type=text class='text' style='"
			Response.write bText
			Response.write ";width:148px;' id='a_s1' db='c.storecode' onkeydown='window.kdown(this);'></td>" & vbcrlf & "              </tr><tr>" & vbcrlf & "                       <td class='c_c'>仓库名称：</td>" & vbcrlf & "                 <td><input type=text class='text' style='"
			'Response.write bText
			Response.write ";width:245px'  id='a_s2' db='c.title' onkeydown='window.kdown(this);'></td>" & vbcrlf & "          </tr>" & vbcrlf & "           </table>" & vbcrlf & "        </td>" & vbcrlf & "</tr>" & vbcrlf & "<tr><td colspan=2 style='height:5px'></td></tr>" & vbcrlf & "<tr><td colspan=2 style='height:5px'></td></tr>" & vbcrlf & "<tr>" & vbcrlf &      " <th class='c_b' style='padding-top:5px;text-align:left' colspan='2'>&nbsp;产品</th> "& vbcrlf &" </tr> "& vbcrlf &" <tr><td></td>" & vbcrlf &  "  <td>" & vbcrlf &    "         <table> "& vbcrlf &    "      <tr> "& vbcrlf &         "            <td class='c_c' align='right'>产品条码：</td> "& vbcrlf &          "          <td colspan=3><input type=text class='text' style='"
			'Response.write bText
			Response.write ";width:148px;' id='a_s3' db='j.txm' onkeydown='window.kdown(this);'></td>" & vbcrlf & "            </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td class='c_c' align='right'>产品名称：</td>" & vbcrlf & "                   <td colspan=3><input type=text class='text' style='"
			'Response.write bText
			Response.write ";width:245px' id='a_s4' db='p.title' onkeydown='window.kdown(this);'></td>" & vbcrlf & "           </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td class='c_c' style='text-align:right'>拼音码：</td>" & vbcrlf & "                  <td><input type=text class='text' style='"
			'Response.write bText
			Response.write bText
			Response.write ";width:78px' id='a_s5' db='pym' onkeydown='window.kdown(this);'></td>" & vbcrlf & "                        <td class='c_c' style='width:63px;text-align:right'>型号：</td>" & vbcrlf & "                 <td><input type=text class='text' style='"
			'Response.write bText
			Response.write bText
			Response.write ";width:100px' id='a_s6' db='type1' onkeydown='window.kdown(this);'>&nbsp;</td>" & vbcrlf & "               </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td class='c_c' align='right'>产品编号：</td>" & vbcrlf & "                   <td><input type=text class='text' style='"
			'Response.write bText
			Response.write ";width:78px;' id='a_s7' db='order1' onkeydown='window.kdown(this);'></td>" & vbcrlf & "                    <td class='c_c' style='width:63px;text-align:right'>序列号：</td>" & vbcrlf & "                       <td><input type=text class='text' style='"
			Response.write bText
			'Response.write bText
			Response.write ";width:100px' id='a_s8' db='type1' onkeydown='window.kdown(this);'>&nbsp;</td>" & vbcrlf & "               </tr>" & vbcrlf & "           <tr>" & vbcrlf & "                    <td class='c_c' valign='top' align='right'>产品分类：</td>" & vbcrlf & "                      <td colspan=3 style='height:180px;width:237px'>" & vbcrlf & "                         <div ondblclick='this.style.position=(this.style.position==""absolute""?""static"":""absolute"")' style='background-color:white;left:0px;top:0px;width:100%;height:100%;overflow:auto;padding:5px;border:1px solid #e0e0e0;margin-top:3px;margin-bottom:3px' id='a_s9' db='p.sort1'>" & vbcrlf & "                           <input type='checkbox' id='cpflall' onclick='ckcpflall(this)' isAll='1'><label for='cpflall'>全选</label>" & vbcrlf & "                                <table>" & vbcrlf & "                         "
			Response.write cpClassNode(0)
			Response.write "" & vbcrlf & "                             </table>" & vbcrlf & "                                </div>" & vbcrlf & "                  </td>" & vbcrlf & "           </tr>" & vbcrlf & "           "
			dim i , t , ii
			i = 0  : ii= 9
			set rs = cn.execute("select title,name,sort,gl from zdy where sort1=21 and set_open = 1 order by gate1")
			while not rs.eof
				ii = ii + 1
'while not rs.eof
				t = rs.fields("title").value
				tname = rs.fields("name").value
				tsort = rs.fields("sort").value
				tgl = rs.fields("gl").value
				If tgl&""="" Then tgl=0
				if i = 0 then
					Response.write "<tr>"
					Response.write "<td class='c_c'  style='text-align:right'>" & t & "：</td><td>"
					Response.write "<tr>"
				else
					Response.write "<td class='c_c' style='width:63px;text-align:right'>" & t & "：</td><td>"
					Response.write "<tr>"
				end if
				If tsort=2 Then
					if i = 0 then
						Response.write "<input type=text db='" & tname & "_2' id='a_s" & ii & "' class='text' style='" & bText & ";width:78px' onkeydown='window.kdown(this)'>"
					else
						Response.write "<input type=text db='" & tname & "_2' id='a_s" & ii & "' class='text' style='" & bText & ";width:100px' onkeydown='window.kdown(this)'>&nbsp;"
					end if
				ElseIf tsort=1 Then
					Response.write "" & vbcrlf & "                                             <select db='"
					Response.write tname
					Response.write "_1' id='a_s"
					Response.write ii
					Response.write "'>" & vbcrlf & "                                                           <option value="""">请选择</option>" & vbcrlf & "                                          "
					sqlzdy="select id,sort1 from sortonehy where gate2="& tgl &" order by gate1"
					set rszdy=cn.execute(sqlzdy)
					while not rszdy.eof
						Response.write "<option value='"&rszdy(0)&"'>"&rszdy(1)&"</option>"
						rszdy.movenext
					wend
					rszdy.close
					set rszdy=nothing
					Response.write "" & vbcrlf & "                                                     </select>" & vbcrlf & "                       "
				end if
				Response.write "</td>"
				if i = 0 then
					i=i +1
'if i = 0 then
				else
					i = 0
				end if
				rs.movenext
			wend
			rs.close
			if i = 1 then Response.write "</tr>"
			set rs2=server.CreateObject("adodb.recordset")
			sql2="select id,FType,FName from ERP_CustomFields where TName=21 and IsUsing=1 and CanSearch=1 order by FOrder desc "
			rs2.open sql2,cn,1,1
			if rs2.eof then
			else
				do until rs2.eof
					ii=ii+1
'do until rs2.eof
					Response.write "" & vbcrlf & "     <tr>" & vbcrlf & "        <td class='c_c' align=""right"" height=""28"">"
					Response.write rs2("FName")
					Response.write "：</td>" & vbcrlf & "              <td colspan=""3""> " & vbcrlf & ""
					If rs2("FType")="1" then
						Response.write "" & vbcrlf & "             <input db=""advs_"
						Response.write rs2("id")
						Response.write "_2"" id='a_s"
						Response.write ii
						Response.write "' type=""text"" class='text' style='"
						Response.write bText
						Response.write ";width:148px' onkeydown='window.kdown(this)'>" & vbcrlf & ""
					ElseIf rs2("FType")="2" Then
						Response.write "" & vbcrlf & "             <input db=""advs_"
						Response.write rs2("id")
						Response.write "_2"" id='a_s"
						Response.write ii
						Response.write "' type=""text"" class='text' style='"
						Response.write bText
						Response.write ";width:148px' onkeydown='window.kdown(this)'>" & vbcrlf & ""
					ElseIf rs2("FType")="3" then
						Response.write "" & vbcrlf & "             <INPUT db=""advs_"
						Response.write rs2("id")
						Response.write "_1"" class=""text"" style="""
						Response.write bText
						Response.write ";width:78px;"" id=""a_s"
						Response.write ii
						Response.write """ onclick=""datedlg.show();"" readonly>&nbsp;-"
						Response.write ii
						ii=ii+1
						Response.write ii
						Response.write "&nbsp;<INPUT db=""advs_"
						Response.write rs2("id")
						Response.write "_2"" class='text' style='"
						Response.write bText
						Response.write ";width:78px;' id='a_s"
						Response.write ii
						Response.write "' onclick=""datedlg.show();"" readonly>" & vbcrlf & ""
					ElseIf rs2("FType")="4" then
						Response.write "" & vbcrlf & "             <input db=""advs_"
						Response.write rs2("id")
						Response.write "_2"" id='a_s"
						Response.write ii
						Response.write "' type=""text"" class='text' style='"
						Response.write bText
						Response.write ";width:148px' onkeydown='window.kdown(this)'>" & vbcrlf & ""
					ElseIf rs2("FType")="5" then
						Response.write "" & vbcrlf & "             <input db=""advs_"
						Response.write rs2("id")
						Response.write "_2"" id='a_s"
						Response.write ii
						Response.write "' type=""text"" class='text' style='"
						Response.write bText
						Response.write ";width:148px' onkeydown='window.kdown(this)'>" & vbcrlf & ""
					ElseIf rs2("FType")="6" then
						Response.write "" & vbcrlf & "             <select db=""advs_"
						Response.write rs2("id")
						Response.write "_1"" id='a_s"
						Response.write ii
						Response.write "'>" & vbcrlf & "                   <option value="""">选择</option>" & vbcrlf & "                    <option value=""是"">是</option>" & vbcrlf & "                    <option value=""否"">否</option>" & vbcrlf & "            </select>" & vbcrlf & ""
					else
						Response.write "" & vbcrlf & "             <select db=""advs_"
						Response.write rs2("id")
						Response.write "_1"" id='a_s"
						Response.write ii
						Response.write "'>" & vbcrlf & "                   <option value="""">选择</option>" & vbcrlf & ""
						Set rs8=server.CreateObject("adodb.recordset")
						rs8.open "select CValue from ERP_CustomOptions where CFID="&rs2("id")&" ",cn,1,1
						If Not rs8.eof Then
							Do While Not rs8.eof
								Response.write "" & vbcrlf & "                     <option value="""
								Response.write rs8("CValue")
								Response.write """>"
								Response.write rs8("CValue")
								Response.write "</option>" & vbcrlf & ""
								rs8.movenext
							Loop
						end if
						rs8.close
						Set rs8=nothing
						Response.write "" & vbcrlf & "             </select>" & vbcrlf & ""
					end if
					Response.write "" & vbcrlf & "             </td>" & vbcrlf & "   </tr>" & vbcrlf & ""
					rs2.movenext
				loop
			end if
			rs2.close
			set rs2=Nothing
			Response.write "" & vbcrlf & "             </table>" & vbcrlf & "        </td>" & vbcrlf & "</tr>" & vbcrlf & "<tr><td colspan=2>&nbsp;</td></tr>" & vbcrlf & "<tr><td colspan=2 align='center'>" & vbcrlf & "<input type=""hidden"" name=""cpfl"" value=""""/><button class='wavbutton' style='width:50px' id='doAsButton' onclick='window.doASearch("
			Response.write ii
			Response.write ");'>搜索</button>&nbsp;" & vbcrlf & "<button class='wavbutton' style='width:50px' onclick='window.DivClose(this)'>取消</button>" & vbcrlf & "<div style=""position:absolute; top:0px; right:10px;"">" & vbcrlf & "<button class='wavbutton' style='width:50px' id='doAsButton' onclick='window.doASearch("
			Response.write ii
			Response.write ");'>搜索</button>&nbsp;<button class='wavbutton' style='width:50px' onclick='window.DivClose(this)'>取消</button></div>" & vbcrlf & "</td></tr>" & vbcrlf & "</table>" & vbcrlf & ""
		end sub
		function cpClassNode(id)
			dim id1 , html ,c
			set rs = cn.execute("select menuname,id,(select count(*) from menu where id1=a.id) childCnt from menu a where id1=" & id & " order by gate1 desc,id")
			if rs.eof = false then
				while rs.eof = false
					id1 = rs.fields(1).value
					html = html & "<tr value='" & id1 & "'>" & _
					"<td style='width:14px'>" & app.iif(rs("childCnt")>0,"<input type=image src='../../images/smico/plus.gif' onclick='window.expNode(this)'>","") & "</td>" & _
					"<td><input type=checkbox name='cpfl' iscpfl='1' id='cx_" & id1 & "' tag='" & id1 & "'><label for='cx_" & id1 & "'>" & rs.fields(0).value & "</label></td>" & _
					"</tr>"
					html = html & "<tr><td style='width:14px'></td><td></td></tr>"
					rs.movenext
				wend
			end if
			rs.close
			set rs = nothing
			cpClassNode = html
		end function
		Sub App_getNode()
			Response.write cpClassNode(request("id"))
		end sub
		sub App_SearchList
			dim key , hasnum , aCode
			aCode = request.form("ajCode")
			key = trim(request.form("kv"))
			Response.write "<ul style='font-size:12px;margin-left:3px;cursor:default'>"
			key = trim(request.form("kv"))
			hasnum = request.form("hasnum")
			if len(hasnum)=0 then hasnum = 0
			dim aCodeArray ,items , xlh
			if  len(aCode) > 0 Then
				aCodeArray = split(aCode,chr(3) & chr(4))
				items = split(aCodeArray(7),chr(1) & chr(2))
				if len(items(2)) > 0 then
					xlh =  replace(items(2),"'","''")
				end if
			elseif replace(request.form("kn"),"'","")="7" then
				xlh = replace(key,"'","''")
			end if
			if  len(aCode) = 0 Then
				set rs = cn.execute("exec erp_ckpd_cpsearch " & replace(request.form("kn"),"'","") & ",'" & replace(key,"'","''") & "'," & app.info.user & "," & hasnum)
			else
				dim sql
				sql=sql & "set nocount on" & vbcrlf
				sql=sql & "create table #tmb(cpname varchar(5000) , cpId int, ckId int , pck int , cktm varchar(100) , sn int NOT NULL IDENTITY (1, 1)) " & vbcrlf
				sql=sql & "insert into #tmb(cpname,cpid,ckid)" & vbcrlf
				sql=sql & "exec erp_ckpd_cpsearch " & replace(request.form("kn"),"'","") & ",'" & replace(key,"'","''") & "'," & app.info.user & "," & hasnum & vbcrlf
				sql=sql &  GetAcodeSql(aCode) & vbcrlf
				sql=sql & "select * from #tmb" & vbcrlf
				sql=sql & "set nocount off" & vbcrlf
				set rs = cn.execute(sql)
			end if
			while not rs.eof
				strTEXT=rs.fields(0).value&""
				strTEXT=Replace(strTEXT,"<br>",Chr(1))
				strTEXT=Replace(strTEXT,"&nbsp;",Chr(2))
				strTEXT=replace(strTEXT & "",LCase(key),Chr(3) & LCase(key) & Chr(4))
				strTEXT=replace(strTEXT & "",UCase(key),Chr(3) & UCase(key) & Chr(4))
				strTEXT=Replace(strTEXT,Chr(1),"<br>")
				strTEXT=Replace(strTEXT,Chr(2),"&nbsp;")
				strTEXT=Replace(strTEXT,Chr(3),"<span class=c_red><b>")
				strTEXT=Replace(strTEXT,Chr(4),"</b></span>")
				Response.write "<li><input type='checkbox' value='" & rs.fields(1).value & "," & rs.fields(2).value & "," & xlh &"' name='srcck'><img src='../../images/icon_sanjiao.gif'><span onclick=ItemSelect(" & rs.fields(1).value & "," & rs.fields(2).value & ",'"& xlh &"') onmouseout='hideuline(this)' onmouseover='showuline(this)' class=link>&nbsp;" & strTEXT & "</span></li>"
				rs.movenext
			wend
			rs.close
			Response.write "</ul>"
		end sub
		function GetAcodeSql(cd)
			dim aCodeArray ,item , v
			aCodeArray = split(cd,chr(3) & chr(4))
			items = split(aCodeArray(7),chr(1) & chr(2))
			if len(items(2)) > 0 then
				v =  replace(items(2),"'","''")
				GetAcodeSql = GetAcodeSql & "delete #tmb where sn not in (select b.sn from ku a inner join #tmb b on a.ck = b.ckid and a.ord = b.cpid and a.xlh like '%" & v & "%' and a.num2 > 0)" & vbcrlf
			end if
			items = split(aCodeArray(0),chr(1) & chr(2))
			if len(items(2)) > 0 then
				GetAcodeSql = GetAcodeSql & "update #tmb set pck = x.sort ,cktm= isnull(x.StoreCode,'')  from sortck x where x.ord = ckid" & vbcrlf & _
				"while exists(select 1 from #tmb a , sortck1 b where a.pck = b.id)" & vbcrlf & _
				"begin" & vbcrlf & _
				"  update #tmb set pck = a.parentID, cktm = cktm + isnull(a.StoreCode,'')  from sortck1 a where a.id=pck" & vbcrlf & _
				"begin" & vbcrlf & _
				"end"  & vbcrlf
				GetAcodeSql = GetAcodeSql & "delete #tmb where isnull(cktm,'') not like '%" & replace(items(2),"'","''") & "%'"
			end if
			items = split(aCodeArray(2),chr(1) & chr(2))
			if len(items(2)) > 0 then
				v =  replace(items(2),"'","''")
				GetAcodeSql = GetAcodeSql & "delete #tmb where sn not in (select b.sn from jiage a inner join #tmb b on a.product = b.cpid and a.txm like '%" & v & "%')" & vbcrlf
			end if
			items = split(aCodeArray(3),chr(1) & chr(2))
			if len(items(2)) > 0 then
				v =  replace(items(2),"'","''")
				GetAcodeSql = GetAcodeSql & "delete #tmb where sn not in (select b.sn from product a inner join #tmb b on a.ord = b.cpid and a.title like '%" & v & "%')"
			end if
			items = split(aCodeArray(1),chr(1) & chr(2))
			if len(items(2)) > 0 then
				v =  replace(items(2),"'","''")
				GetAcodeSql = GetAcodeSql & "delete #tmb where sn not in (select b.sn from sortck a inner join #tmb b on a.ord = b.ckid and a.sort1 like '%" & v & "%')"
			end if
			items = split(aCodeArray(4),chr(1) & chr(2))
			if len(items(2)) > 0 then
				v =  replace(items(2),"'","''")
				GetAcodeSql = GetAcodeSql & "delete #tmb where sn not in (select b.sn from product a inner join #tmb b on a.ord = b.cpid and a.pym like '%" & v & "%')"
			end if
			items = split(aCodeArray(5),chr(1) & chr(2))
			if len(items(2)) > 0 then
				v =  replace(items(2),"'","''")
				GetAcodeSql = GetAcodeSql & "delete #tmb where sn not in (select b.sn from product a inner join #tmb b on a.ord = b.cpid and a.type1 like '%" & v & "%')"
			end if
			items = split(aCodeArray(6),chr(1) & chr(2))
			if len(items(2)) > 0 then
				v =  replace(items(2),"'","''")
				GetAcodeSql = GetAcodeSql & "delete #tmb where sn not in (select b.sn from product a inner join #tmb b on a.ord = b.cpid and a.order1 like '%" & v & "%')"
			end if
			items = split(aCodeArray(8),chr(1) & chr(2))
			if len(items(2)) > 0 then
				v =  replace(items(2),"'","''")
				Set rsf = cn.Execute("SELECT khqy = dbo.GetMenuArea('"& v &"','menu')")
				If Not rsf.eof Then
					w = rsf(0)
				end if
				rsf.Close
				Set rsf = Nothing
				If Len(w&"") <> 0 Then v = w
				GetAcodeSql = GetAcodeSql & "delete #tmb where sn not in (select b.sn from product a inner join #tmb b on a.ord = b.cpid and a.sort1  in (" & v & "))"
			end if
			for i = 9 to  ubound(aCodeArray)
				items = split(aCodeArray(i),chr(1) & chr(2))
				if len(items(2)) > 0 then
					v =  replace(items(2),"'","''")
					If InStr(items(1), "advs_") > 0 Then
						id1 = items(1)
						id2 = ""
						arr_id1 = Split(id1,"_")
						id2 = arr_id1(1)
						If id2&""<>"" Then
							Set rs2 = cn.execute("select id,FType from ERP_CustomFields where TName=21 and IsUsing=1 and del=1 and CanSearch=1 and id="& id2)
							If rs2.eof=False Then
								kzType = rs2("FType")
								Select Case kzType&""
								Case "1","2","4","5"
								GetAcodeSql = GetAcodeSql & "delete #tmb where sn not in (select b.sn from product a inner join #tmb b on a.ord = b.cpid and a.ord in(select OrderID from ERP_CustomValues where FieldsID="& id2 &" and FValue like '%" & v & "%'))"
								Case "3"
								If InStr(id1,"_"& id2 &"_1")>0 Then
									GetAcodeSql = GetAcodeSql & "delete #tmb where sn not in (select b.sn from product a inner join #tmb b on a.ord = b.cpid and a.ord in(select OrderID from ERP_CustomValues where FieldsID="& id2 &" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime)end)>=cast('"& v &"'as datetime)))"
								end if
								If InStr(id1,"_"& id2 &"_2")>0 Then
									GetAcodeSql = GetAcodeSql & "delete #tmb where sn not in (select b.sn from product a inner join #tmb b on a.ord = b.cpid and a.ord in(select OrderID from ERP_CustomValues where FieldsID="& id2 &" and (case isDate(FValue) when 1 then  cast(FValue as datetime) else cast('1950-1-1' as datetime)end)<=cast('"& v &"' as datetime)))"
								end if
								Case "6"
								GetAcodeSql = GetAcodeSql & "delete #tmb where sn not in (select b.sn from product a inner join #tmb b on a.ord = b.cpid and a.ord in(select OrderID from ERP_CustomValues where FieldsID="& id2 &" and FValue = '" & v & "'))"
								Case Else
								GetAcodeSql = GetAcodeSql & "delete #tmb where sn not in (select b.sn from product a inner join #tmb b on a.ord = b.cpid and a.ord in(select OrderID from ERP_CustomValues where FieldsID="& id2 &" and FValue = '" & v & "'))"
								End Select
							end if
							rs2.close
							Set rs2 = Nothing
						end if
					Else
						id1 = items(1)
						id2 = ""
						arr_id1 = Split(id1,"_")
						zdyn1 = arr_id1(0)
						zdyn2 = arr_id1(1)
						If zdyn2&""="2" then
							GetAcodeSql = GetAcodeSql & "delete #tmb where sn not in (select b.sn from product a inner join #tmb b on a.ord = b.cpid and a." & zdyn1 & "  like '%" & v & "%')"
						elseIf zdyn2&""="1" Then
							GetAcodeSql = GetAcodeSql & "delete #tmb where sn not in (select b.sn from product a inner join #tmb b on a.ord = b.cpid and a." & zdyn1 & "  = " & v & ")"
						end if
					end if
				end if
			next
		end function
		sub App_AddCPTreeItem
			dim rs , id , key , nd , tvw, sql
			Dim idlist, idcount
			set tvw = new treeview
			id = replace(request.form("selID"),"'","")
			key = replace(request.form("key"),"'","")
			sql = request.form("sql")
			If Len(sql) > 0 Then
				sql = app.base64.decode(sql)
			end if
			ReDim idlist(0)
			idcount = 0
			set rs = cn.execute("exec erp_sel_ProductGetNode " & key & "," & app.info.user & "," & id & ",'" &  Replace(sql,"'","''") & "'")
			while not rs.eof
				If rs.fields("typ")=1 Then
					set nd = tvw.root.nodes.add
					nd.text = rs.fields("nm").value
					nd.childtest = false
					nd.imageurl = "../../images/icon_sanjiao.gif"
					nd.tag = rs.fields("id").value
					ReDim Preserve idlist(idcount)
					idlist(idcount) = rs.fields("id").value
					idcount = idcount + 1
					idlist(idcount) = rs.fields("id").value
				else
					Set nd = tvw.root.nodes.add
					nd.text = rs.fields("nm").value
					nd.childtest = true
					nd.tag = "sys_pdm_" & rs.fields("id").value
					nd.imageurl = "../../images/smico/c_f.gif"
					nd.vHasChild = true
				end if
				rs.movenext
			wend
			rs.close
			Response.write Join(idlist,",") & Chr(1) & "!$" & Chr(1)  & tvw.root.nodes.HTML("tvw_" & id)
		end sub
		sub App_tvwExpand
			dim tvw , musthasnum , nd , pnode
			musthasnum = request.form("musthasnum")
			if request.form("update") <> "1" then exit sub
			pnode =  request.form("ord")
			ptype =  request.form("type")
			if len(musthasnum) = 0 or not isnumeric(musthasnum) then musthasnum = 0
			if len(pnode) = 0 or not isnumeric(pnode) then pnode = 0
			if len(ptype) = 0 or not isnumeric(ptype) then ptype = 0
			set tvw = new treeview
			set rs = cn.execute("exec erp_ckpd_getNode " & app.info.user & " ," & musthasnum & ", " & pnode & " , " & ptype )
			while not rs.eof
				set nd = tvw.root.nodes.add
				nd.text = rs.fields(2).value
				nd.tag = "node-" & rs.fields(0).value & "-" & rs.fields(1).value
				nd.text = rs.fields(2).value
				nd.vHasChild = true
				if rs.fields(1).value = 3 then
					nd.imageurl = "../../images/icon_sanjiao.gif"
					nd.vHasChild = false
				elseif rs.fields(1).value = 2 then
					nd.imageurl = "../../images/smico/folder.gif"
				else
					nd.imageurl = "../../images/smico/c_f.gif"
				end if
				rs.movenext
			wend
			rs.close
			Response.write "tvwChild=" & tvw.root.nodes.HTML(tvw.id)
		end sub
		sub CreateTreeHTMLfile
			dim tvw , musthasnum , nd
			musthasnum = request.querystring("musthasnum")
			if len(musthasnum) = 0 or not isnumeric(musthasnum) then musthasnum = 0
			set tvw = new treeview
			tvw.root.text = "仓库产品"
			set rs = cn.execute("exec erp_ckpd_getNode " & app.info.user & " ," & musthasnum & ", 0 , 0" )
			while not rs.eof
				set nd = tvw.root.nodes.add
				nd.text = rs.fields(2).value
				nd.tag = "node-" & rs.fields(0).value & "-" & rs.fields(1).value
				nd.text = rs.fields(2).value
				if rs.fields(1).value = 3 then
					nd.imageurl = "../../images/icon_sanjiao.gif"
				elseif rs.fields(1).value = 2 then
					nd.imageurl = "../../images/smico/folder.gif"
				else
					nd.imageurl = "../../images/smico/c_f.gif"
				end if
				nd.vHasChild = true
				rs.movenext
			wend
			rs.close
			Dim Nullnd
			If musthasnum = 2 Then
				Call addNoKuProductNodes(tvw)
			end if
			Response.write tvw.HTML
		end sub
		Sub addNoKuProductNodes(tvw)
			Set Nullnd =nothing
			cn.execute "delete M_selTempProduct where uid=" & app.info.user & " and selid=-4 and exists(select 1 from ku x where x.num2<> 0 and x.ord=M_selTempProduct.ord)"
'Set Nullnd =nothing
			cn.execute "insert into M_selTempProduct (ord,uid,selid) select ord," & app.Info.User & ",-4 from product x where not exists(select 1 from M_selTempProduct y where y.ord=x.ord and y.selid=-4 and y.uid=" & app.Info.user & ") and not exists(select 1 from ku y where y.ord=x.ord and y.num2<>0 and y.ck in (select ord from sortck where del=1 and (charindex( ',"&app.Info.user&",' ,','+replace(cast(intro as varchar(4000)),' ','')+',')>0 or replace(cast(intro as varchar(10)),' ','')='0') ))"
'Set Nullnd =nothing
			If cn.execute("select top 1 1 from M_selTempProduct where selid=-4 and uid=" & app.Info.user).eof = False then
'Set Nullnd =nothing
				set pnd = tvw.root.nodes.add
				pnd.text = "无库存产品<img style='width:1px;height:1px;border:0;outline:none' src='../../images/11655.png' id='nokuimg'>"
				pnd.imageurl = "../../images/smico/c_f.gif"
				pnd.tag = "node-N-N"
				pnd.imageurl = "../../images/smico/c_f.gif"
				pnd.expanded = False
				set rs = cn.execute("exec erp_sel_ProductGetNode 0," & app.info.user & ",-4,''")
				pnd.expanded = False
				while not rs.eof
					If rs.fields("typ")=1 Then
						if Nullnd is nothing then
							set Nullnd = pnd.nodes.add
							Nullnd.text = "<i>无分类产品</i>"
							Nullnd.imageurl = "../../images/smico/c_f.gif"
							Nullnd.expanded = false
						end if
						Set nd = Nullnd.nodes.add
						nd.text = rs.fields("nm").value
						nd.childtest = false
						nd.imageurl = "../../images/icon_sanjiao.gif"
						nd.tag = rs.fields("id").value
					else
						Set nd = pnd.nodes.add
						nd.text = rs.fields("nm").value
						nd.tag = "sys_pdm_" & rs.fields("id").value
						nd.imageurl = "../../images/smico/c_f.gif"
						nd.vHasChild = True
						nd.childtest = true
					end if
					rs.movenext
				wend
				rs.close
			end if
		end sub
		sub App_dataList
			dim clsType , clsText
			clsText = request.form("clsText")
			clsType = request.form("clsType")
			if len(clsText) = 0 then
				call CreateTreeHTMLfile
			end if
		end sub
		Sub App_addpdPage
			dim sql , rs  ,  top , bs
			top = request.querystring("top")
			if len(top) > 0 then
				set bs = new Base64Class
				top = bs.deurl(top)
				set bs = nothing
			end if
			if not isnumeric(top) or len(top) = 0 then
				top = 0
			end if
			dim tit , pdno , pddate , bz
			set rs = cn.execute("select *,convert(varchar(19),date3,121) pddate from kupd where ord=" & top)
			if not rs.eof then
				tit = rs.fields("title").value
				pdno = rs.fields("pdbh").value
				pddate = rs.fields("pddate").value
				bz = rs.fields("intro").value
			else
				tit = ""
				set rss = app.getdatarecord(cn.execute("EXEC erp_getdjbh 35,"&session("personzbintel2007")))
				pdno  = rss.fields(0).value
				rss.close
				pddate = Now()
				If cn.execute("select 1 from inventoryCost WHERE datediff(mm,'"& date &"',date1)=0 and complete1 >= 1").eof=False Then
					pddate = cn.execute("select convert(varchar(10),dateadd(mm,1,max(date1)), 120)+' '+convert(varchar,GETDATE(),108) from inventoryCost where complete1 >= 1")(0)
				end if
				bz = ""
			end if
			rs.close
			session("zbintel_hzpdresubmit")=now()
			Response.write app.headhtml()
			Response.write "<style>html{padding:0px}textarea{ border:1px solid #b6c0c9; }textarea:focus{ outline:none;box-shadow: 0px 0px 2px 1px #4fa1e5; }</style>"
			Response.write app.headhtml()
			Response.write "" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "function TexTxmFocus(event){" & vbcrlf & "    event = event? event: window.event" & vbcrlf & "      if(!event) return;" & vbcrlf & "      var obj = event.srcElement ? event.srcElement:event.target; " & vbcrlf & "    if(!obj) return ;" & vbcrlf & "       if(obj.name==undefined){" & vbcrlf & "             var eo = null;" & vbcrlf & "          try{" & vbcrlf & "                    eo = document.getElementsByName(""txm"")[0];" & vbcrlf & "                        eo.focus();" & vbcrlf & "             }catch(e1){" & vbcrlf & "                     try{" & vbcrlf & "                            eo = parent.document.getElementsByName(""txm"")[0];" & vbcrlf & "                         eo.focus();" & vbcrlf & "                    }catch(e1){}" & vbcrlf & "            }" & vbcrlf & "       }" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "function txmAjaxSubmit(obj){" & vbcrlf & "  var TxmID=obj.value;" & vbcrlf & "    if (TxmID.length ==0){return;}" & vbcrlf & "  if (TxmID.indexOf(""："")>=0)" & vbcrlf & "       {" & vbcrlf & "               //多行文本内容，二维码文本编码" & vbcrlf & "            if( TxmID.indexOf(""流水号："")!=0) {return;}" & vbcrlf & "       }" & vbcrlf & "       else if (TxmID.toLowerCase().indexOf(""view.asp?v"")>0)" & vbcrlf & "     {" & vbcrlf & "               //网址信息，可能是二维码URL编码" & vbcrlf & "         TxmID = ""QrUrl="" + TxmID.split(""view.asp?"")[1];" & vbcrlf & "     }" & vbcrlf &"" & vbcrlf & " ajax.regEvent(""onScanComplete"");" & vbcrlf & "  ajax.addParam(""data"",TxmID);" & vbcrlf & "      var r = ajax.send();" & vbcrlf & "    if (r.length==0){return;}" & vbcrlf & "       var dat = r.split("","");" & vbcrlf & "   if(window.top.TreeDataSelect){" & vbcrlf & "          window.top.TreeDataSelect(dat);" & vbcrlf & " }" & vbcrlf & "       obj.value = """";" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "ScanBill = {Scanf:{lastTime:0}};" & vbcrlf & "ScanBill.Scanf.KeyRecSub = function(e){" & vbcrlf & "    var currt = (new Date()).getTime();" & vbcrlf & "    var dt = (currt - ScanBill.Scanf.lastTime);" & vbcrlf & "    ScanBill.Scanf.lastTime = currt;" & vbcrlf & "    if (dt > 80) {" & vbcrlf & "        if (e.keyCode != 13 && e.keyCode != 10) {" & vbcrlf & "            ScanBill.Scanf.CurrCode = String.fromCharCode(e.keyCode);" & vbcrlf & "        }" & vbcrlf & "        return;" & vbcrlf & "    }" & vbcrlf & "    if (e.keyCode == 13 || e.keyCode == 10) {" & vbcrlf & "        if(ScanBill.Scanf.CurrCode.length>0) { ScanBill.Scanf.RecEndSub();   }" & vbcrlf & "        ScanBill.Scanf.CurrCode = """";" & vbcrlf & "        return;" & vbcrlf & "    }" & vbcrlf & "    ScanBill.Scanf.CurrCode +=String.fromCharCode(e.keyCode);" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "ScanBill.Scanf.RecEndSub = function(){" & vbcrlf & "    if(ScanBill.Scanf.CurrCode){" & vbcrlf & "        var obj = document.getElementsByName(""txm"")[0];" & vbcrlf & "        obj.value = ScanBill.Scanf.CurrCode;" & vbcrlf & "        txmAjaxSubmit(obj);" & vbcrlf & "    }" & vbcrlf & "    ScanBill.Scanf.CurrCode  = """";" & vbcrlf & "}" & vbcrlf & "" & vbcrlf & "setTimeout(function(){" & vbcrlf & "$(document).bind(""keypress"", ScanBill.Scanf.KeyRecSub);" & vbcrlf & "if (window.top != window) { $(top.document).bind(""keypress"", ScanBill.Scanf.KeyRecSub);}" & vbcrlf & "if (window.parent != window && window.parent != window.top) { $(parent.document).bind(""keypress"", ScanBill.Scanf.KeyRecSub); }" & vbcrlf & "},300)" & vbcrlf & "</script>" & vbcrlf & "<body style='margin-top:0px;padding-top:0px' onclick=''>" & vbcrlf & "        <script type=""text/javascript"">" & vbcrlf & "            document.body.style.paddingTop=""0px"";" & vbcrlf & "     </script>" & vbcrlf & "       <style>" & vbcrlf & "         html {overflow:auto;}" & vbcrlf & "   </style>" & vbcrlf & "        <script language=javascript src='../../Manufacture/inc/Bill.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "  <script language=javascript src='../../Manufacture/inc/listview.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "  <script language=javascript src='../../Manufacture/inc/automenu.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script><!-- 自动下拉选择组件 -->" & vbcrlf & " <script language=javascript src='../../Manufacture/inc/contextmenu.js?ver="
			'Response.write Application("sys.info.jsver")
			Response.write Application("sys.info.jsver")
			Response.write "'></script><!-- office/.net样式菜单 -->" & vbcrlf & "      <script language=javascript src='../../inc/jquery-autobh.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "  <div style='float:right;padding-top:8px'>" & vbcrlf & "               <input name=""txm"" autocomplete=""off"" type=""text"" style=""width:1px; height:1px;opacity:0; border:0;margin: 0px;padding: 0px;"" onkeypress=""if(event.keyCode==13){txmAjaxSubmit(this);this.value='';}"" onFocus=""this.value=''"" size=""10"">" & vbcrlf & "   </div>" & vbcrlf & "  <div id='head' class=""resetHeadBgImg"" style='margin:0px;padding:0px;background-image:url(../images/m_mpbg.gif)'>" & vbcrlf & "          <div class=""resetTransparent"" style='float:left;background-image:url(../../images/content_tab.png);width:277px;height:32px'>" & vbcrlf & "                   <div class=""resetTransparent resetTextColor333 billTitle"" style='margin-top:10px;*margin-top:14px;margin-left:65px;font-weight:bold;font-size:14px;color:#444499;letter-spacing:3px;'>汇总盘点记录添加</div>" & vbcrlf & "                      "
			'Response.write Application("sys.info.jsver")
			action1="汇总盘点记录添加"
			call app.add_log(2,action1)
			Response.write "" & vbcrlf & "             </div><div class=""resetTransparent"" style='float:right;background-image:url(../../images/m_mpr.gif);width:3px;height:32px'></div><div class=""resetTransparent"" style='background-image:url(../../images/m_mpbg.gif);height:32px'></div>" & vbcrlf & "     </div>" & vbcrlf & "  <input type=hidden value='"
			Response.write top
			Response.write "' id='pdID'>" & vbcrlf & " <table class=""resetBorderColor"" style='table-layout:fixed;border:1px solid #A7BBD7;border-top:0px;width:100%'>" & vbcrlf & "    <tr>" & vbcrlf & "            <td class='billfieldleft' style='width:70px;border-left:1px solid #ccc'><pre style='display:inline'>  盘点主题： </pre></td>"& vbcrlf & "              <td class='billfieldright'>" & vbcrlf & "                     <table>" & vbcrlf & "                 <tr>" & vbcrlf & "                            <td><input type=text class=text style='height:17px' id='MT1' value='"
			Response.write tit
			Response.write "'></td>" & vbcrlf & "                              <td>&nbsp;<span class=c_red>*</span></td>" & vbcrlf & "                               <td  id='MT1_msg'></td>" & vbcrlf & "                 </tr>" & vbcrlf & "                   </table>" & vbcrlf & "                </td>" & vbcrlf & "           <td class='billfieldleft'  style='width:70px'><pre style='display:inline'>  盘点编号： </pre></td>" & vbcrlf& "               <td class='billfieldright'>" & vbcrlf & "                     <table>" & vbcrlf & "                 <tr>" & vbcrlf & "                            <td>" & vbcrlf & "                                    <input type=text class=""text jquery-auto-bh"" style='height:17px' value="""
			'Response.write tit
			Response.write pdno
			Response.write """ id='MT2'" & vbcrlf & "                                                autobh-options=""cfgId:35,autoCreate:false,eventMode:'onclick',submitBtn:'.save-btn',rootPath:'../../',recId:"
			'Response.write pdno
			Response.write top
			Response.write """" & vbcrlf & "                                 >" & vbcrlf & "                               </td>" & vbcrlf & "                           <td>&nbsp;<span class=c_red>*</span></td>" & vbcrlf & "                               <td  id='MT2_msg'></td>" & vbcrlf & "                 </tr>" & vbcrlf & "                   </table>" & vbcrlf & "                </td>" & vbcrlf & "           <td class='billfieldleft'  style='width:70px'><pre style='display:inline'>  盘点日期： </pre></td>" & vbcrlf & "           <td class='billfieldright'>" & vbcrlf & "                     <table class=textitemtable><tr><td>" & vbcrlf & "                     <input  id='MT3' class=text style= 'border-right:0px;height:17px;width:144px;' type=text readonly value='"
			'Response.write top
			Response.write pddate
			Response.write "'></td><td><button class=InselButton   value='0' onclick='Bill.showDateTimeDlg()'><img class=""resetElementHidden"" src='../../images/datePicker.gif'><img class=""resetElementShow"" style=""display:none;"" width=""12"" height=""14"" src='../../skin/default/images/MoZihometop/content/datePicker.png'></button></td><td>&nbsp;<span class=c_red>*</span></td><td  id='MT3_msg'></td></tr></table>" & vbcrlf & "           </td>" & vbcrlf & "   </tr>" & vbcrlf & "   <tr>" & vbcrlf & "            <td class='billfieldleft'><pre style='display:inline'>  盘点备注： </td>" & vbcrlf & "                <td class='billfieldright' colspan=5>" & vbcrlf & "                    <textarea name=""intro""  type=""text"" id='MT4' class='text' rows=""4"" onpropertychange=""this.style.posHeight=this.scrollHeight>64?this.scrollHeight:64;"" style=""width:80%;height:64px;vertical-align:middle;margin:4px 0;"">"
			'Response.write pddate
			Response.write HTMLDecode(bz)
			Response.write "</textarea><span id=""MT4_msg""></span>" & vbcrlf & "          </td>" & vbcrlf & "   </tr>" & vbcrlf & "   <tr>" & vbcrlf & "            <td class='billfieldleft'><pre style='display:inline'>  盘点明细： </td>" & vbcrlf & "                <td class='billfieldright' colspan=5>" & vbcrlf & "                   <div style='width:100%;overflow-y:hidden;overflow-x:auto'>" & vbcrlf & "                    "
			'Response.write HTMLDecode(bz)
			fzunit=GetAssistUnitTactics()
			fzunitShow=fzunit=1
			isFixAssRat = (GetConversionUnitTactics()=1)
			assInx=2
			set lvw = new listview
			lvw.id = "pdlist"
			lvw.border=0
			lvw.checkbox = 1
			lvw.candelete = true
			lvw.pagesize = 16
			lvw.canadd = False
			lvw.candr = true
			lvw.sql =   "select " & vbcrlf & _
			"  b.title as 产品名称,a.ord as 产品ID,b.order1 as 编号,b.type1 as 型号, " & vbcrlf & _
			"  (select sort1 from sortonehy c where gate2=61 and c.ord=a.unit) + '^tag~' + cast(a.unit as varchar(12)) as 单位, " & vbcrlf & _
			"  b.title as 产品名称,a.ord as 产品ID,b.order1 as 编号,b.type1 as 型号, " & vbcrlf & _
			"  a.unit as 单位ID, " & vbcrlf & _
			"   s1.title + '^tag~' + cast(a.ProductAttr1 as varchar(12)) 产品属性1, " & vbcrlf & _
			"  a.unit as 单位ID, " & vbcrlf & _
			"   s2.title + '^tag~' + cast(a.ProductAttr2 as varchar(12)) 产品属性2, " & vbcrlf & _
			"  a.unit as 单位ID, " & vbcrlf & _
			"  num1 as 账面数量, " & vbcrlf & _
			"  num2 as 实盘数量, " & vbcrlf & _
			"  num3 as 盈亏数量, " & vbcrlf & _
			"  case when num3>0 then (select sort1 from sortonehy c where gate2=61 and c.ord=a.AssistUnit) + '^tag~' + cast(a.AssistUnit as varchar(12)) else '' end  as 辅助单位, " & vbcrlf & _
			"  num3 as 盈亏数量, " & vbcrlf & _
			"  case when num3>0 then cast(a.AssistNum as varchar(50)) else '0' end as 辅助数量, " & vbcrlf & _
			"  intro as 单价, " & vbcrlf & _
			"  money1 as 盈亏金额, " & vbcrlf & _
			"  (select top 1 sort1 from sortck c where c.ord=a.ku) as 仓库名称, " & vbcrlf & _
			"  a.ku as 仓库ID, " & vbcrlf & _
			"  a.price1 as 备注, " & vbcrlf & _
			"  a.IsNoKu, " & vbcrlf & _
			"  1 bl " & vbcrlf & _
			"from kupdlist a " & vbcrlf & _
			"left join product b on b.ord=a.ord "& vbcrlf & _
			"left join Shop_GoodsAttr s1 on s1.id = a.ProductAttr1  "& vbcrlf & _
			"left join Shop_GoodsAttr s2 on s2.id = a.ProductAttr2  "& vbcrlf & _
			"where a.pd =" & top & " and a.ord = b.ord" & vbcrlf & _
			"order by  a.id"
			lvw.cols.items(1).edit = 0
			lvw.cols.items(1).save = 0
			lvw.cols.items(2).htmlvisible = false
			lvw.cols.items(2).save = 1
			lvw.cols.items(2).resize = 0
			lvw.cols.items(3).edit = 0
			lvw.cols.items(3).save = 0
			lvw.cols.items(4).edit = 0
			lvw.cols.items(4).save = 0
			lvw.cols.items(5).edit = 1
			lvw.cols.items(5).save = 0
			lvw.cols.items(5).selid =18
			lvw.cols.items(5).lockformat = "【IsNoKu】==0"
			lvw.cols.items(5).edit = 0
			lvw.cols.items(6).htmlvisible = False
			lvw.cols.items(6).lockformat = "【IsNoKu】==0"
			lvw.cols.items(6).save = 1
			lvw.cols.items(6).resize = 0
			attrInx = 2
			lvw.cols.items(5+attrInx).htmlvisible = isOpenProductAttr
'attrInx = 2
			lvw.cols.items(5+attrInx).save = 1
'attrInx = 2
			lvw.cols.items(5+attrInx).edit = 0
'attrInx = 2
			lvw.cols.items(5+attrInx).align ="center"
'attrInx = 2
			lvw.cols.items(6+attrInx).htmlvisible = isOpenProductAttr
'attrInx = 2
			lvw.cols.items(6+attrInx).edit = 0
'attrInx = 2
			lvw.cols.items(6+attrInx).save = 1
'attrInx = 2
			lvw.cols.items(6+attrInx).align ="center"
'attrInx = 2
			lvw.cols.items(7+attrInx).edit = 0
'attrInx = 2
			lvw.cols.items(7+attrInx).save = 1
'attrInx = 2
			lvw.cols.items(8+attrInx).edit = 1
'attrInx = 2
			lvw.cols.items(8+attrInx).BgColor = "【盈亏数量】==0?'':(【盈亏数量】>0?'#ff9933':'#cc3333')"
'attrInx = 2
			lvw.cols.items(8+attrInx).save = 1
'attrInx = 2
			lvw.cols.items(9+attrInx).edit = 0
'attrInx = 2
			lvw.cols.items(9+attrInx).save = 1
'attrInx = 2
			lvw.cols.items(10+attrInx).save = 1
'attrInx = 2
			lvw.cols.items(10+attrInx).selid =18
'attrInx = 2
			lvw.cols.items(10+attrInx).lockformat = "【盈亏数量】<=0"
'attrInx = 2
			lvw.cols.items(10+attrInx).htmlvisible = fzunitShow
'attrInx = 2
			lvw.cols.items(11+attrInx).edit = 1
'attrInx = 2
			lvw.cols.items(11+attrInx).save = 1
'attrInx = 2
			lvw.cols.items(11+attrInx).htmlvisible = fzunitShow
'attrInx = 2
			lvw.cols.items(11+attrInx).dtype = "number"
'attrInx = 2
			if isFixAssRat then
				lvw.cols.items(11+attrInx).Edit= 0
'if isFixAssRat then
			else
				lvw.cols.items(11+attrInx).Edit= 1
'if isFixAssRat then
			end if
			lvw.cols.items(12+attrInx).edit = 1
'if isFixAssRat then
			lvw.cols.items(12+attrInx).save = 1
'if isFixAssRat then
			lvw.cols.items(12+attrInx).dtype = "storeprice"
'if isFixAssRat then
			lvw.cols.items(12+attrInx).lockformat = "【盈亏数量】<=0"
'if isFixAssRat then
			lvw.cols.items(13+attrInx).edit = 0
'if isFixAssRat then
			lvw.cols.items(13+attrInx).save = 1
'if isFixAssRat then
			If cn.execute("select top 1 1 from power where ord=" & app.Info.User & " and sort1=35 and sort2=21 and qx_open=1").eof Then
				lvw.cols.items(12+attrInx).htmlvisible = false
				lvw.cols.items(13+attrInx).htmlvisible = false
			end if
			lvw.cols.items(14+attrInx).edit = 1
			lvw.cols.items(14+attrInx).save = 0
			lvw.cols.items(14+attrInx).selid = 1064
			lvw.cols.items(14+attrInx).lockformat = "【IsNoKu】==0"
			Set rsl = cn.Execute("Select num1 from setjm3 Where ord=5430")
			If rsl.eof = False then
				If rsl("num1").value = 1 Then
					lvw.cols.items(14+attrInx).disztlr = 1
'If rsl("num1").value = 1 Then
				else
					lvw.cols.items(14+attrInx).disztlr = 0
'If rsl("num1").value = 1 Then
				end if
			else
				lvw.cols.items(14+attrInx).disztlr = 1
'If rsl("num1").value = 1 Then
			end if
			rsl.close
			lvw.cols.items(15+attrInx).htmlvisible = false
			'rsl.close
			lvw.cols.items(15+attrInx).save = 1
			'rsl.close
			lvw.cols.items(15+attrInx).resize = 0
			'rsl.close
			lvw.cols.items(16+attrInx).edit = 1
			'rsl.close
			lvw.cols.items(16+attrInx).save = 1
			'rsl.close
			lvw.cols.items(17+attrInx).save = 1
			'rsl.close
			lvw.cols.items(17+attrInx).edit = 0
			'rsl.close
			lvw.cols.items(17+attrInx).htmlvisible = false
			'rsl.close
			lvw.cols.items(18+attrInx).htmlvisible = false
			'rsl.close
			lvw.formula = "【实盘数量】=【实盘数量】;【盈亏数量】=【实盘数量】-【账面数量】;【盈亏金额】=【盈亏数量】*【单价】;【单位ID】=【单位】;【单价】=【单价】;"
			'rsl.close
			Response.write lvw.innerHTML
			Response.write "<br>" & vbcrlf & "                 </div>" & vbcrlf & "          </td>" & vbcrlf & "   </tr>" & vbcrlf & "   </table>" & vbcrlf & "        <table style='table-layout:fixed; width: 100%'>" & vbcrlf & " <tr>" & vbcrlf & "            <td class=""resetTransparent"" style='background-image:url(../../images/tb_top_td_bg.gif);padding-top:0px;height:40px;line-height:40px'>" & vbcrlf & "                      <table align=center style='width:300px;text-align:center;margin:0 auto;'>" & vbcrlf & "                       <tr>" & vbcrlf & "                            <td><button class=""button save-btn"" onclick='savepd(1)'>暂存盘点</button></td>" & vbcrlf & "                            <td><button class=""button save-btn"" onclick='savepd(3)'>结束盘点</button></td>" & vbcrlf & "                           <!-- <td><button class=button>打印明细</button></td> -->" & vbcrlf & "                                <td><button class=button onclick='window.location.href=window.location.href'>重新填写</button></td>" & vbcrlf & "                     </tr>" & vbcrlf & "                   </table>" & vbcrlf & "                </td>" & vbcrlf & "   </tr>"& vbcrlf & "    </table>" & vbcrlf &   "  <div style=""color:red"">温馨提示：盘亏出库，盘点的账面数量按同一个产品、单位和仓库自动求和，所以汇总盘亏出库成本无需手动录入，按照先进先出法扣减匹配库存和成本；<br> "& vbcrlf &      "     &nbsp&nbsp&nbsp&nbsp&nbsp盘盈入库，以手动录入的单价作为盘点入库的成本单价；</div> "& vbcrlf &     "   <br><br><br><br> "& vbcrlf &     "    <script language=javascript src../Manufacture/inc/dateCalender.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script><!-- 日期选择组件 -->" & vbcrlf & "     <script language=javascript>" & vbcrlf & "            ListViewInit();" & vbcrlf & "         function savepd(sType){" & vbcrlf & "                 ajax.regEvent("""")" & vbcrlf & "                 for(var i=1;i<5;i++){" & vbcrlf & "                           if(i<4){document.getElementById(""MT"" + i + ""_msg"").innerHTML = """"}" & vbcrlf & "                               ajax.addParam(""MT"" + i,document.getElementById(""MT"" + i).value)" & vbcrlf & "                     }" & vbcrlf & "                       ajax.addParam(""tempsave"",sType)" & vbcrlf & "                   ajax.addParam(""dat"",lvw.GetSaveDetailData(document.getElementById('listview_pdlist')));" & vbcrlf & "                   ajax.addParam(""ID"","
			Response.write top
			Response.write ");" & vbcrlf & "            if (!window.ajaxbaseurl) { window.ajaxbaseurl = ajax.url; }" & vbcrlf & "            ajax.url = window.ajaxbaseurl.split(""/SYSA/"")[0] + ""/SYSN/view/store/kupd/addpd.save.ashx"";" & vbcrlf & "                 r = ajax.send();" & vbcrlf & "            if (r.replace(/(^\s*)|(\s*$)/g, """")==""ok""){" & vbcrlf & "                                try{window.parent.location.href=""../planall4.asp"";}" & vbcrlf & "                               catch(e){};" & vbcrlf & "                     }       " & vbcrlf & "                        else{" & vbcrlf & "                           try{" & vbcrlf & "                                    eval(r)" & vbcrlf & "                         }catch(e){" & vbcrlf & "                                      alert(r)" & vbcrlf & "                                }" & vbcrlf & "                       }" & vbcrlf & "            ajax.url = window.ajaxbaseurl;" & vbcrlf & "         }" & vbcrlf & "               " & vbcrlf & "        function GetHasDataArray() {" & vbcrlf & "                    var r = """"" & vbcrlf & "                        var div = document.getElementById('listview_pdlist')" & vbcrlf & "                    for(var i=0;i<div.hdataArray.length;i++){" & vbcrlf & "                         var row = div.hdataArray[i]" & vbcrlf & "                             if (row!=undefined)" & vbcrlf & "                             {                       " & vbcrlf & "                                    r = r + ""|"" + lvwCellValue(row[3]) + "","" + lvwCellValue(row[7]) + "","" + lvwCellValue(row[14 +"
			'Response.write top
			Response.write  assInx
			Response.write " + "
			'Response.write  assInx
			Response.write attrInx
			Response.write "]) + "","" + lvwCellValue(row[16 +"
			'Response.write attrInx
			Response.write  assInx
			Response.write "+ "
			'Response.write  assInx
			Response.write attrInx
			Response.write "])//ku" & vbcrlf & "                               }" & vbcrlf & "                       }" & vbcrlf & "                       return r" & vbcrlf & "                } " & vbcrlf & "              function GetHasDataArray1(){" & vbcrlf & "                    var r = """"" & vbcrlf & "                        var div = document.getElementById('listview_pdlist')" & vbcrlf & "                    for(var i=0;i<div.hdataArray.length;i++){" & vbcrlf & "                             var row = div.hdataArray[i]" & vbcrlf & "                             r = r + ""|"" + lvwCellValue(row[3]) + "","" + lvwCellValue(row[7]) + "",""+ lvwCellValue(row[8]) + "",""+ lvwCellValue(row[9]) + "","" + lvwCellValue(row[14 +"
			'Response.write attrInx
			Response.write  assInx
			Response.write "+ "
			'Response.write  assInx
			Response.write attrInx
			Response.write "]) + "","" + lvwCellValue(row[16 +"
			'Response.write attrInx
			Response.write  assInx
			Response.write "+ "
			'Response.write  assInx
			Response.write attrInx
			Response.write "]) + "","" + lvwCellValue(row[7+"
			'Response.write attrInx
			Response.write  assInx
			Response.write "+ "
			'Response.write  assInx
			Response.write attrInx
			Response.write "]) + "","" + lvwCellValue(row[15 +"
			'Response.write attrInx
			Response.write  assInx
			Response.write "+ "
			'Response.write  assInx
			Response.write attrInx
			Response.write "])//ku" & vbcrlf & "                       }" & vbcrlf & "                       return r" & vbcrlf & "                } " & vbcrlf & "" & vbcrlf & "              window.top.TreeDataSelect = function(dat){" & vbcrlf & "                      var dats = dat.join(""$"")" & vbcrlf & "                  ajax.regEvent(""addChild"");" & vbcrlf & "                        ajax.addParam(""datArray"",dats);" & vbcrlf & "                   ajax.addParam(""hasKuArray"",GetHasDataArray())" & vbcrlf & "                 ajax.send(getnewlist)" & vbcrlf & "                   ajax.showprocc();" & vbcrlf & "               }" & vbcrlf & "               " & vbcrlf & "        window.lvwCellValue = function (v) {" & vbcrlf & "                    v = v.split(lvw.sBoxSpr)" & vbcrlf & "                        if(v.length==2){" & vbcrlf & "                return v[1].length>0 ? v[1] : v[0]" & vbcrlf & "                      }" & vbcrlf & "                       else{" & vbcrlf & "                           return v[0];" & vbcrlf & "                    }" & vbcrlf & "               }" & vbcrlf & "" & vbcrlf & "               window.isRepeat = function(div,cells){ //判断是否充分" & vbcrlf & "                   " & vbcrlf & "                        for(var i=0;i<div.hdataArray.length;i++){" & vbcrlf & "                            var row = div.hdataArray[i]" & vbcrlf & "                             var ord = row[3] //产品编号" & vbcrlf & "                             var unt = row[7] //单位" & vbcrlf & "                         var ku  = row[14] //所在仓库" & vbcrlf & "                            var ok1 = (cells[12] == lvwCellValue(ku));" & vbcrlf & "                              var ok2 = (cells[1] == lvwCellValue(ord));" & vbcrlf & "                              var ok3 = (cells[5] == lvwCellValue(unt));" & vbcrlf & "                            //window.top.document.title = (ok1 + ' - ' + ok2 + ' - ' + ok3 + ' - ' + ok4 + ' - ' + ok5) +  "" ["" + cells[10] + ""] - ["" + cells[11] + ""] - ["" +  ph + ""]""" & vbcrlf & "                             if(ok1 == true && ok2 ==true && ok3 ==true){" & vbcrlf & "                    return i" & vbcrlf & "                                }" & vbcrlf & "                       }" & vbcrlf & "                       return -1;" & vbcrlf & "              }" & vbcrlf & "               window.getnewlist = function(r){" & vbcrlf & "                        var rowIndex = 0;" & vbcrlf & "                       var hsCount = 0 , addCount = 0" & vbcrlf & "                  var div = document.getElementById('listview_pdlist')" & vbcrlf & "                        var rows = r.split(""$="")" & vbcrlf & "                  for(var i = 0 ; i < rows.length ; i++){" & vbcrlf & "                         if(rows[i].length>1){" & vbcrlf & "                                   var cells = rows[i].split(""|-"")" & vbcrlf & "                                   addCount = addCount + 1" & vbcrlf & "                                 div.hdataArray[div.hdataArray.length] = (""+%;$++%;$+"" + cells.join(""+%;$+"")).split(""+%;$+"") //lvw.addDataRow(div,cells);" & vbcrlf & "                          }" & vbcrlf & "                       }" & vbcrlf & "                       div.PageStartIndex = div.hdataArray.length - div.PageSize + 1" & vbcrlf & "                   div.PageStartIndex = div.PageStartIndex > 0 ? div.PageStartIndex : 1" & vbcrlf & "                    div.PageEndIndex = div.hdataArray.length" & vbcrlf & "                     lvw.UpdateScrollBar(div);" & vbcrlf & "                       lvw.Refresh(div)" & vbcrlf & "                        if(hsCount > 0){" & vbcrlf & "                                alert(""有"" + hsCount + ""条记录已经存在，不能重复添加。"")" & vbcrlf & "                    }" & vbcrlf & "               }" & vbcrlf & "" & vbcrlf & "               window.getnewlist1 = function(r){" & vbcrlf & "                      var rowIndex = 0;" & vbcrlf & "                       var hsCount = 0 , addCount = 0" & vbcrlf & "                  var div = document.getElementById('listview_pdlist')" & vbcrlf & "                    div.hdataArray =[];" & vbcrlf & "                     var rows = r.split(""$="")" & vbcrlf & "                  for(var i = 0 ; i < rows.length ; i++){" & vbcrlf & "                         if(rows[i].length>1){" & vbcrlf & "                                     var cells = rows[i].split(""|-"")" & vbcrlf & "                                   //var rpt = isRepeat(div,cells)" & vbcrlf & "                                 //if(rpt>=0)" & vbcrlf & "                                    //{" & vbcrlf & "                                     //      hsCount = hsCount + 1" & vbcrlf & "                                           //div.hdataArray.splice(rpt,1)" & vbcrlf & "                                  //}" & vbcrlf & "     //else{" & vbcrlf & "                                         addCount = addCount + 1" & vbcrlf & "                                         div.hdataArray[div.hdataArray.length] = (""+%;$++%;$+"" + cells.join(""+%;$+"")).split(""+%;$+"") //lvw.addDataRow(div,cells);" & vbcrlf & "                                      ///}" & vbcrlf & "                            }" & vbcrlf & "                       }" & vbcrlf & "                       div.PageStartIndex = div.hdataArray.length - div.PageSize + 1" & vbcrlf & "                      div.PageStartIndex = div.PageStartIndex > 0 ? div.PageStartIndex : 1" & vbcrlf & "                    div.PageEndIndex = div.hdataArray.length" & vbcrlf & "                        lvw.UpdateScrollBar(div);" & vbcrlf & "                       lvw.Refresh(div)" & vbcrlf & "                        if(hsCount > 0){" & vbcrlf &"                         alert(""有"" + hsCount + ""条记录已经存在，不能重复添加。"")" & vbcrlf & "                    }" & vbcrlf & "               }" & vbcrlf & "" & vbcrlf & "               document.body.onload = function(){" & vbcrlf & "                      var buttons = document.getElementById(""listtoolbar_pdlist"").getElementsByTagName(""button"")" & vbcrlf & "                  for(var i = 0 ; i < buttons.length ; i ++){" & vbcrlf & "                                if(buttons[i].title==""导出表格(Excel)"" || buttons[i].title==""统计图示""){" & vbcrlf & "                                    buttons[i].style.display = ""none""" & vbcrlf & "                         }" & vbcrlf & "                       }" & vbcrlf & "               }" & vbcrlf & "" & vbcrlf & "               window.onExcelDrSetTag = function() {" & vbcrlf & "                   return GetHasDataArray1();" & vbcrlf & "            }" & vbcrlf & "               //document.getElementById(""MT4"").fireEvent(""onpropertychange"")" & vbcrlf & "        $(document.getElementById(""MT4"")).trigger(""change"");" & vbcrlf & "" & vbcrlf & "        lvw.onformulaApply = function (div, input) {" & vbcrlf & "     if (window.InputDBName == ""辅助数量"") {" & vbcrlf & "" & vbcrlf & "                return false" & vbcrlf & "            };" & vbcrlf & "            var rowIndex = lvw.getDataRowIndexByTR(input.tr);" & vbcrlf & "            var row = div.hdataArray[rowIndex]" & vbcrlf & "            if (row[12]> 0) {" & vbcrlf & "                var pord = row[3];" & vbcrlf & "                var unit = row[7];" & vbcrlf & "                var AssistUnit = row[13].split(""^tag~"")[1];" & vbcrlf & "                var Num = row[12];" & vbcrlf & "                if (pord && unit && AssistUnit && Num) {" & vbcrlf & "                    ajax.regEvent(""GetAssistNum"");" & vbcrlf & "                    ajax.addParam(""pord"", row[3]);" & vbcrlf & "                    ajax.addParam(""unit"", row[7]);" & vbcrlf & "                    ajax.addParam(""AssistUnit"", row[13].split(""^tag~"")[1]);" & vbcrlf &" ajax.addParam(""Num"", Num);" & vbcrlf &                  "   var r = ajax.send(); "& vbcrlf &                "     if (Number(r) == 0) { "& vbcrlf &                "         lvw.updateDataCell(input.tr.cells[14],"""");" & vbcrlf &               "          lvw.setCellValue(input.tr.cells[14],"""");" & vbcrlf & "                    } else {" & vbcrlf & "                        lvw.updateDataCell(input.tr.cells[14], Number(r).toFixed("
			Response.write app.Info.FloatNumber
			Response.write "));" & vbcrlf & "                        lvw.setCellValue(input.tr.cells[14], Number(r).toFixed("
			Response.write app.Info.FloatNumber
			Response.write "));" & vbcrlf & "                    }" & vbcrlf & "                }" & vbcrlf & "            } else {" & vbcrlf & "                lvw.setCellValue(input.tr.cells[13], """");" & vbcrlf & "                lvw.setCellValue(input.tr.cells[14], """");" & vbcrlf & "            }" & vbcrlf & "    lvw.updateColSum(div, lvw.cellIndex(input.tr.cells[14]));" & vbcrlf & "            //div.hdataArray[rowIndex - 1][12] = r" & vbcrlf & "            //lvw.formulaApply(div.children[0], input.tr)" & vbcrlf & "        }" & vbcrlf & "    </script>" & vbcrlf & "</body>" & vbcrlf & ""
			'Response.write app.Info.FloatNumber
		end sub
		dim conn
		Sub app_GetAssistNum
			set conn = cn
			dim ProductID,Num,NewUnit,OldUnit
			ProductID = request.form("pord")
			OldUnit = request.form("unit")
			NewUnit = request.form("AssistUnit")
			if isnumeric(NewUnit)=false then NewUnit = 0
			Num = request.form("Num")
			resultNum= ConvertUnitData(ProductID,OldUnit,NewUnit,Num)
			Response.write(resultNum&"")
		end sub
		Function getFieldName(findex)
			isOpenAssUnit = (GetAssistUnitTactics()&""="1")
			assInx=0
			if isOpenAssUnit then assInx=2
			AttrInx = 2
			Select Case findex
			Case 4: getFieldName = "账面数量"
			Case 5: getFieldName = "实盘数量"
			Case 6: getFieldName = "盈亏数量"
			case 5+assInx: getFieldName = "辅助单位"
'Case 6: getFieldName = "盈亏数量"
			Case 7+assInx: getFieldName = "单价"
'Case 6: getFieldName = "盈亏数量"
			Case 8+assInx: getFieldName = "盈亏金额"
'Case 6: getFieldName = "盈亏数量"
			CASE 9+assInx: getFieldName = "仓库名称"
'Case 6: getFieldName = "盈亏数量"
			Case Else
			getFieldName = "第" & findex & "列"
			End Select
		end function
		sub App_Save
			dim I , II ,  MF , f , rows  , ID, bid,allnum
			Dim alerttxt, ccc
			assInx=0
			blinx=0
			isOpenAssUnit = (GetAssistUnitTactics()&""="1")
			assInx=2
			blinx=1
			ccc = 0
			bid = request.form("ID")
			if len(bid) = 0 then bid  = 0
			if not isnumeric(bid) then bid = 0
			redim MF(4)
			f = false
			for i = 1 to 4
				MF(i) = request.form("MT" & I)
				if I < 4  then
					if  I =1 then
						if len(MF(I))>100 Or len(MF(i)) = 0 then
							Response.write "document.getElementById(""MT" & I & "_msg"").innerHTML=""<span class=c_red>&nbsp;长度必须在1至100个字之间</span>"";"
							exit sub
						end if
					end if
					if len(MF(i)) = 0 then
						Response.write "document.getElementById(""MT" & I & "_msg"").innerHTML=""<span class=c_red>&nbsp;不能为空</span>"";"
						f = true
					end if
				end if
				If I = 4 Then
					if len(MF(I))>1000 then
						Response.write "document.getElementById(""MT" & I & "_msg"").innerHTML=""<span class=c_red>&nbsp;长度必须在0-1000个字之间</span>"";"
'if len(MF(I))>1000 then
						exit sub
					end if
				end if
			next
			if not isdate(MF(3)) then
				f = true
				Response.write "document.getElementById(""MT3_msg"").innerHTML=""<span class=c_red>&nbsp;日期不正确</span>"";"
			end if
			rows = split(request.form("dat"),"#or")
			if ubound(rows) < 0 then
				app.alert "没有选择要盘点的产品资料"
				exit sub
			end if
			attrInx = 2
			cn.execute "select 0 ord,0 unit,0 ck,0 ProductAttr1,0 ProductAttr2,cast(0 as decimal(25,12)) num1 into #tempCheckNum"&vbCrLf&_
			"CREATE NONCLUSTERED INDEX [_dta_index_tempCheckNum_11_1678717938__K1_K2_K3_K5_K6_K4] ON [dbo].[#tempCheckNum]"&_
			"([ord] ASC,[unit] ASC,[ck] ASC,[ProductAttr2] ASC,[num1] ASC,[ProductAttr1] ASC)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]"
			dim CheckSql:CheckSql="insert into #tempCheckNum(ord,unit,ck,ProductAttr1,ProductAttr2,num1)values"
			dim ords:ords="0"
			dim units:units="0"
			dim cks:cks="0"
			for I = 0 to ubound(rows)
				rows(i) = split(rows(i),"#oc")
				if IsNumeric(rows(i)(0)) = false or len(rows(i)(0)&"") = 0 then exit for
				if IsNumeric(rows(i)(7+assInx+ cdbl(attrInx))) then
'if IsNumeric(rows(i)(0)) = false or len(rows(i)(0)&"") = 0 then exit for
					if cdbl(rows(i)(7+assInx+ cdbl(attrInx)))>0 and instr(","&cks&",",","&rows(i)(7+assInx+ cdbl(attrInx))&",")=0 then
'if IsNumeric(rows(i)(0)) = false or len(rows(i)(0)&"") = 0 then exit for
						cks =cks & "," & rows(i)(7+assInx+ cdbl(attrInx))
'if IsNumeric(rows(i)(0)) = false or len(rows(i)(0)&"") = 0 then exit for
					end if
				end if
				if cdbl(rows(i)(0))>0 and instr(","&ords&",",","&rows(i)(0)&",")=0 then
					ords =ords & "," & rows(i)(0)
				end if
				if cdbl(rows(i)(1))>0 and instr(","&units&",",","&rows(i)(1)&",")=0  then
					units =units & "," & rows(i)(1)
				end if
				if ubound(rows(i)) <> 9+cdbl(assInx) + cdbl(attrInx)+cdbl(blinx) then
					units =units & "," & rows(i)(1)
					alerttxt = alerttxt & vbcrlf & "明细资料超出预期。" & ubound(rows(i))
					f = true
				end if
				ProductAttr1 = rows(i)(2)
				if ProductAttr1&""="" then ProductAttr1 = "0"
				ProductAttr2 = rows(i)(3)
				if ProductAttr2&""="" then ProductAttr2 = "0"
				if i>0 and i Mod 1000=0 then
					cn.execute Left(CheckSql, Len(CheckSql) - 1)
'if i>0 and i Mod 1000=0 then
					CheckSql="insert into #tempCheckNum(ord,unit,ck,ProductAttr1,ProductAttr2,num1)values"
				end if
				CheckSql=CheckSql&vbCrLf&"("&rows(i)(0)&","&rows(i)(1)&","&rows(i)(7+assInx+ cdbl(attrInx))&","&ProductAttr1&","&ProductAttr2&","&rows(i)(2+ cdbl(attrInx))&"),"
				CheckSql="insert into #tempCheckNum(ord,unit,ck,ProductAttr1,ProductAttr2,num1)values"
				If cdbl(rows(i)(5)) < 0  Then
					app.alert "第" & (I+1) & "行，实盘数量不能为负数!"
'If cdbl(rows(i)(5)) < 0  Then
					call db_close : Response.end
				end if
				If Len(Trim(rows(i)(1)&""))=0  Then
					rows(i)(1)=0
					app.alert "第" & (I+1) & "行单位不能为空。"
					rows(i)(1)=0
					f = True
					exit sub
				end if
				If len(rows(i)(5+assInx+ cdbl(attrInx))&"")=0 Or isnumeric(rows(i)(5+assInx+ cdbl(attrInx))&"") = 0 then
					exit sub
					app.alert "第" & (I+1) & "行，单价不能为空或非数值型的内容!"
					exit sub
					call db_close : Response.end
				end if
				If cdbl(rows(i)(5+assInx+ cdbl(attrInx))&"")<0 then
					call db_close : Response.end
					app.alert "第" & (I+1) & "行，单价不能为负数!"
					call db_close : Response.end
					call db_close : Response.end
				end if
				If Len(rows(i)(7+assInx+ cdbl(attrInx))&"") = 0 or rows(i)(7+ cdbl(assInx)+ cdbl(attrInx))="0" Then
					call db_close : Response.end
					app.alert "第" & (I+1) & "行，仓库不能为空!"
					call db_close : Response.end
					call db_close : Response.end
				end if
				if rows(i)(7+ cdbl(attrInx))&""="0" and isOpenAssUnit then
					call db_close : Response.end
					app.alert "第" & (I+1) & "行，辅助数量不能为0!"
					call db_close : Response.end
					call db_close : Response.end
				end if
				if rows(i)(2)&""="" then rows(i)(2)=0  end if
				if rows(i)(3)&""="" then rows(i)(3)=0  end if
				if rows(i)(5+ cdbl(attrInx))&""="" then rows(i)(5+ cdbl(attrInx))=0  end if
'if rows(i)(3)&""="" then rows(i)(3)=0  end if
				if rows(i)(6+ cdbl(attrInx))&""="" then rows(i)(6+ cdbl(attrInx))=0  end if
'if rows(i)(3)&""="" then rows(i)(3)=0  end if
				for II = 0 to ubound(rows(i)) - (2+cdbl(blinx)+ cdbl(attrInx))
'if rows(i)(3)&""="" then rows(i)(3)=0  end if
					If not isnumeric(rows(i)(II)) Or (isnumeric(rows(i)(II)) And Len(rows(i)(II))>0 And Len(Split(rows(i)(II)&" ",".")(0))-1>12 + cdbl(attrInx)) Then
'if rows(i)(3)&""="" then rows(i)(3)=0  end if
						If ccc < 20+ cdbl(attrInx) then
'if rows(i)(3)&""="" then rows(i)(3)=0  end if
							alerttxt = alerttxt & vbcrlf &  "第" & (I+1) & "行，" & getFieldName(ii) & "不正确。"
'if rows(i)(3)&""="" then rows(i)(3)=0  end if
						end if
						ccc = ccc + 1
'if rows(i)(3)&""="" then rows(i)(3)=0  end if
						f = true
					end if
				next
				If Len(Trim(rows(i)(9+ cdbl(assInx)+ cdbl(attrInx))&""))=0  Then
					f = true
					alerttxt = alerttxt & vbcrlf &  "第" & (I+1) & "行，" & getFieldName(9+ cdbl(assInx)+ cdbl(attrInx)) & "数据不能为空。"
					f = true
					f = True
				ElseIf Not isnumeric(rows(i)(9+ cdbl(assInx)+ cdbl(attrInx))) Or InStr(rows(i)(9+ cdbl(assInx)+ cdbl(attrInx)),".")>0 Then
					f = True
					alerttxt = alerttxt & vbcrlf &  "第" & (I+1) & "行，" & getFieldName(9+ cdbl(assInx)+ cdbl(attrInx)) & "数据类型必须为整型。"
					f = True
					f = True
				ELSEIF Trim(rows(i)(7+ cdbl(assInx)+ cdbl(attrInx))&"")="0" Then
					f = True
					alerttxt = alerttxt & vbcrlf &  "第" & (I+1) & "行，" & getFieldName(7+ cdbl(assInx)+ cdbl(attrInx)) & "不能为空。"
					f = True
					f = True
				end if
				If Len(rows(i)(8+ cdbl(attrInx))) > 200 Then
					f = True
					app.alert "第" & (i+1) & "行，备注内容不能超过200个字符。"
					f = True
					Exit Sub
				end if
			next
			cn.execute Left(CheckSql, Len(CheckSql) - 1)
			Exit Sub
			pCheck="0"
			set ckrs = server.CreateObject("adodb.recordset")
			ckrs.open "select id from sortck where id in ("&cks&") and (CHARINDEX(',' + CAST('"&session("personzbintel2007")&"' as varchar(12)) + ',', ',' +cast(sortck.intro as varchar(max))+',' )>0 or cast(sortck.intro as nvarchar(max))='0')" , cn , 1, 1
			set ckrs = server.CreateObject("adodb.recordset")
			if cks<>"0" and not ckrs.eof Then
				do while not ckrs.EOF
					ckid=ckrs("id")&""
					pCheck=pCheck+","+ckid
					ckid=ckrs("id")&""
					ckrs.MoveNext
				loop
			end if
			ckrs.close
			Set ckrs = nothing
			dim checknumds
			set checknumds = server.CreateObject("adodb.recordset")
			checknumds.open "select top 1 a.ord,a.unit,a.ck,a.ProductAttr1,a.ProductAttr2,a.allnum  from (select ord,unit,ck,ProductAttr1,ProductAttr2,SUM(allnum) as allnum from (select ord,unit,ck,isnull(ProductAttr1,0)ProductAttr1,isnull(ProductAttr2,0)ProductAttr2,isnull(num2,0)+(case when num2=0 then isnull(locknum,0) else 0 end) allnum from ku where ord in ("&ords&") and unit in ("&units&") and num2<>0 and ck in ("&cks&")) t group by ord,unit,ck,ProductAttr1,ProductAttr2)a "&_
			"inner join #tempCheckNum b on a.ord=b.ord and a.unit=b.unit and a.ck=b.ck and isnull(a.ProductAttr1,0)=b.ProductAttr1 and isnull(a.ProductAttr2,0)=b.ProductAttr2 and b.num1<>a.allnum", cn , 1, 1
			if not checknumds.eof then
				allnum=checknumds("allnum")
				ordTempCheck=checknumds("ord")
				unitTempCheck=checknumds("unit")
				ckTempCheck=checknumds("ck")
				ProductAttr1TempCheck=checknumds("ProductAttr1")
				ProductAttr2TempCheck=checknumds("ProductAttr2")
			else
				allnum=0
				ordTempCheck=0
				unitTempCheck=0
				ckTempCheck=0
				ProductAttr1TempCheck=0
				ProductAttr2TempCheck=0
			end if
			for i = 0 to ubound(rows)
				if Instr(pCheck, rows(i)(7+assInx+ cdbl(attrInx))&"")=0 then
'for i = 0 to ubound(rows)
					app.alert "第" & (i+1) & "行，仓库没有调用权限!"
'for i = 0 to ubound(rows)
					call db_close : Response.end
					allnumds.close
					Set allnumds = nothing
					exit sub
				end if
				if cdbl(ordTempCheck)>0 and rows(i)(0)=ordTempCheck&"" and rows(i)(1)=unitTempCheck&"" and rows(i)(7+assInx+ cdbl(attrInx))=ckTempCheck&"" then
					exit sub
					If FormatNumber(CDbl(allnum),app.Info.FloatNumber,-1,0,0) <> FormatNumber(CDbl(rows(i)(2+ cdbl(attrInx))),app.Info.FloatNumber,-1,0,0) Then
						exit sub
						app.alert alerttxt & vbcrlf & "第" & (i+1) & "行，仓库数量"& FormatNumber(CDbl(allnum),app.Info.FloatNumber,-1,0,0) &"与账面数量"&  FormatNumber(CDbl(rows(i)(2+ cdbl(attrInx))),app.Info.FloatNumber,-1,0,0) &"不符。"
						exit sub
						f = True
						checknumds.close
						Set checknumds = nothing
						exit sub
					end if
				end if
			next
			checknumds.close
			Set checknumds = nothing
			If Len(alerttxt) > 0 Then
				If ccc > 20+ cdbl(attrInx) Then
'If Len(alerttxt) > 0 Then
					alerttxt = alerttxt & vbcrlf & "…………"
				end if
				app.alert alerttxt
			end if
			if f then exit sub
			cn.BeginTrans
			set rs = server.CreateObject("adodb.recordset")
			rs.open "select * from kupd where ord=" & bid , cn , 1, 3
			if rs.eof then
				rs.addnew
				rs.fields("cateid").value = app.info.user
			end if
			rs.fields("title").value = MF(1)
			rs.fields("complete1").value = 1
			rs.fields("pdbh").value = MF(2)
			rs.fields("date3").value = MF(3)
			rs.fields("date7").value = now
			rs.fields("sort1").value = 1
			rs.fields("cateid2").value = 0
			rs.fields("cateid3").value = 0
			rs.fields("intro").value = LTrim(HTMLEncode(MF(4)))
			rs.fields("del").value = 1
			rs.update
			ID = rs("ord").value
			rs.close
			if bid <>0 then
				ID = bid
				cn.execute "delete  from kupdlist where pd=" & bid & " and sort1 = 1"
			end if
			rs.open "select top 0 * from kupdlist",cn,3,2
			for I = 0 to ubound(rows)
				cells = rows(i)
				rs.addnew
				rs.fields("ord").value = cells(0)
				rs.fields("unit").value = cells(1)
				rs.fields("ProductAttr1").value = cells(2)
				rs.fields("ProductAttr2").value = cells(3)
				rs.fields("num1").value = cells(2+ cdbl(attrInx))
'rs.fields("ProductAttr2").value = cells(3) '
				rs.fields("num2").value = cells(3+ cdbl(attrInx))
'rs.fields("ProductAttr2").value = cells(3) '
				rs.fields("num3").value = cells(4+ cdbl(attrInx))
'rs.fields("ProductAttr2").value = cells(3) '
				if isOpenAssUnit then
					rs.fields("AssistUnit").value = cells(5+ cdbl(attrInx))
'if isOpenAssUnit then
					rs.fields("AssistNum").value = cells(6+ cdbl(attrInx))
'if isOpenAssUnit then
					assistUnit=cdbl(cells(5+ cdbl(attrInx)))
'if isOpenAssUnit then
					unit=cdbl(cells(1))
					assistNum=cdbl(cells(6+ cdbl(attrInx)))
					unit=cdbl(cells(1))
					if assistUnit=unit then
						alterText="第"&(i+1)&"行的单位和辅助单位不能相同"
'if assistUnit=unit then
					end if
					if assistNum=0 and assistUnit>0 then
						alterText="第"&(i+1)&"行的辅助数量不能为0"
'if assistNum=0 and assistUnit>0 then
					end if
					if (assistUnit&""="" or assistUnit=0) and assistNum>0 then
						if Len(assistNum)>0 then alterText="请填写第"&(i+1)&"行的辅助单位"
'if (assistUnit&""="" or assistUnit=0) and assistNum>0 then
					else
						if Len(assistNum)=0 then alterText="请填写第"&(i+1)&"行的辅助数量"
'if (assistUnit&""="" or assistUnit=0) and assistNum>0 then
					end if
					if Len(alterText)>0 then
						cn.rollbacktrans
						app.alert alterText
						exit sub
					end if
				end if
				rs.fields("intro").value = cells(5+assInx+ cdbl(attrInx))
				exit sub
				rs.fields("money1").value = cells(6+assInx+ cdbl(attrInx))
				exit sub
				rs.fields("ku").value = cells(7+assInx+ cdbl(attrInx))
				exit sub
				rs.fields("price1").value = cells(8+assInx+ cdbl(attrInx))
				exit sub
				rs.fields("sort1").value = 1
				rs.fields("dateadd").value = MF(3)
				rs.fields("date7").value = now
				rs.fields("del").value = 1
				rs.fields("addcate").value = app.info.user
				rs.fields("pd").value = ID
				rs.fields("isNoKu").value = cells(9+assInx+ cdbl(attrInx))
				rs.fields("pd").value = ID
				rs.update
			next
			rs.close
			If cn.execute("select 1 from kupdlist where  pd =" & ID &" and num3<>0 ").eof=False Then
				If Len(MF(3))>0 and cn.execute("select 1 from inventoryCost WHERE datediff(mm,date1,'"&  MF(3) &"')=0 and complete1 >= 1").eof=false Then
					cn.rollbacktrans
					app.alert "盘点日期对应的成本核算月已核算，请重新选择日期！"
					exit sub
				end if
			end if
			if request.form("tempsave") = "3" then
				dim kuoutkuins : kuoutkuins = ""
				dim maxkuout : maxkuout = sdk.getSqlValue("select isnull(max(ord),0) as maxid from kuout",0)
				dim maxkuin : maxkuin = sdk.getSqlValue("select isnull(max(ord),0) as maxid from kuin",0)
				dim r : r=  AutoKuinKuoutHzPd(cn, 63001 ,id , app.info.user) 'Response.redirect "../savelist5_1.asp?top="& id &"&sort3=2"
				if len(r)>0 then
					cn.rollbacktrans
					app.alert r
					exit sub
				end if
				kuoutkuins = sdk.getsqldata("select distinct k2.kuout,kl.kuin from kuout k inner join kuoutlist2 k2 on k2.kuout=k.ord inner join kuinlist kl on kl.kuoutlist2=k2.id inner join kuin kn on kn.ord = kl.kuin and kn.sort1 in(9,10) and kn.ord>"& maxkuin &" where k.sort1 in(9,10) and k.ord>"& maxkuout , "|")
				if kuoutkuins<>"-1" then
'ut , "|")
					kuoutkuins = kuoutkuins &"|"
				else
					kuoutkuins = ""
				end if
				Response.write "window.parent.AutoHandleToNet(63001, '"& kuoutkuins & ID &"', 'KuPd_InventoryCost_AddPd');"
			end if
			cn.CommitTrans
			Response.write "window.parent.location.href='../planall4.asp'"
		end sub
		Sub App_onScanComplete
			Response.clear
			dim dat :dat = request.form("data")
			If Len(dat)=0 Then Exit Sub
			Dim rs, sql ,i , productOrd
			productOrd=0
			If InStr(dat, "流水号：")=1 Then
				If InStr(Replace(dat, "流水号：", ""), "B")=1 Then
					productOrd=mid(Replace(dat, "流水号：", ""),7,len(Replace(dat, "流水号：", ""))-6)
'If InStr(Replace(dat, "流水号：", ""), "B")=1 Then
				else
					If isnumeric(Replace(dat, "流水号：", "")) = true Then
						productOrd = CLng("0" & Replace(dat, "流水号：", ""))
					end if
				end if
				sql = "select distinct p.ord as product ,  isnull(a.ck,0) ck " &_
				"  from product p left join ku a on a.ord = p.ord where p.ord= " & productOrd & " "
				Set rs = cn.execute(sql)
			ElseIf InStr(dat, "QrUrl=V") = 1 Then
				dat = Replace(dat, "QrUrl=V", "")
				Set rs = cn.execute("select sourceID from C2_CodeItems  where id=" & clng("0" & dat))
				If rs.eof = False Then
					productOrd = rs(0).value
				end if
				rs.close
				sql = "select distinct p.ord as product ,  isnull(a.ck,0) ck " &_
				"  from product p left join ku a on a.ord = p.ord where p.ord=  " &  CLng("0" & productOrd) & " "
				Set rs = cn.execute(sql)
			else
				sql = "select distinct j.product , isnull(a.ck,0) ck "&_
				"  from product p left join jiage j on j.product= p.ord "&_
				"  left join ku a on a.ord=j.product "&_
				"  where j.txm = '" & dat &"'"
				Set rs = cn.execute(sql)
				If rs.eof=True Then
					rs.close
					sql = "select distinct j.product , 0 as ck "&_
					"  from product p left join jiage j on j.product= p.ord  "&_
					"  where j.txm = '" & dat &"' "
					Set rs = cn.execute(sql)
				end if
			end if
			If rs.eof=False Then
				Dim DynArray()
				i = 0
				While rs.eof=False
					REDIM Preserve DynArray(i)
					DynArray(i) = rs("product").value &"|" & rs("ck")
					i = i+1
'DynArray(i) = rs("product").value &"|" & rs("ck")
					rs.movenext
				wend
				Response.write Join(DynArray,",")
			end if
			rs.close
		end sub
		sub App_addChild
			dim dat , dats , cell , sql
			dat = request.form("datArray")
			cn.cursorLocation = 3
			cn.execute("select top 0  10000 as cpID , 10000 as ckID, 1 as isNoku into #ttt;select top 0 10000 as ord, 10000 as unit , 10000 as ku, 1 as isNoku into #ttt2")
			set rs = server.CreateObject("adodb.recordset")
			dats = split(dat,"$")
			rs.open "select * from #ttt" , cn , 1 ,3
			for i = 0 to ubound(dats)
				cell = split(dats(i),"|")
				if isnumeric(replace(cell(0) , "B16001","")) then
					rs.addnew
					rs.fields(0).value = replace(cell(0) , "B16001","")
					rs.fields(1).value = cell(1)
					rs.fields(2).value = Abs(cell(1) = "0")
					rs.update
				end if
			next
			rs.close
			dat = request.form("hasKuArray")
			dats = split(dat,"|")
			rs.open "select * from #ttt2" , cn , 1 ,3
			for i = 0 to ubound(dats)
				if len(dats(i)) > 1 then
					cells = split(dats(i),",")
					on error resume next
					rs.addnew
					rs.fields(0).value = cells(0)
					rs.fields(1).value = app.iif(Len(cells(1))=0, 0, cells(1))
					rs.fields(2).value = app.iif(Len(cells(2))=0, 0, cells(2))
					rs.fields(3).value = cells(3)
					rs.update
					On Error GoTo 0
				end if
			next
			rs.close
			Set rs_s = server.CreateObject("adodb.recordset")
			sql_s = "Select num1 from setjm3 Where ord=5430 and num1=1"
			rs_s.open sql_s,cn,1,1
			If Not rs_s.eof Then
				sql2 = "   isnull(d.sort1,(select top 1 sort1 from sortck where id = (select top 1 MainStore from jiage where product = b.ord and unit = b.unitjb))) as 仓库名称,  "
				sql2 = sql2&"      isnull(a.ck,(select top 1 id from sortck where id = (select top 1 MainStore from jiage where product = b.ord and unit = b.unitjb))) as 仓库ID,"
			else
				sql2 = "   d.sort1 as 仓库名称,  "
				sql2 = sql2&"      a.ck as 仓库ID,"
			end if
			rs_s.close
			sql =       "select  " & vbcrlf & _
			"  b.title as 产品名称,  " & vbcrlf & _
			"  b.ord as 产品ID,  " & vbcrlf & _
			"  b.order1 as 产品编号,  " & vbcrlf & _
			"  b.type1 as 型号,  " & vbcrlf & _
			"  (select sort1 from sortonehy c where gate2=61 and c.ord=isnull(a.unit,b.unitjb)) + '^tag~' + cast(isnull(a.unit,b.unitjb) as varchar(12)) as 单位,  " & vbcrlf & _
			"  b.type1 as 型号,  " & vbcrlf & _
			"  isnull(a.unit,b.unitjb) as 单位ID," & vbcrlf & _
			"   isnull(s1.title,'') + '^tag~' + cast(isnull(a.ProductAttr1,0) as varchar(12)) 产品属性1, " & vbcrlf & _
			"  isnull(a.unit,b.unitjb) as 单位ID," & vbcrlf & _
			"   isnull(s2.title,'') + '^tag~' + cast(isnull(a.ProductAttr2,0) as varchar(12)) 产品属性2, " & vbcrlf & _
			"  isnull(a.unit,b.unitjb) as 单位ID," & vbcrlf & _
			"  isnull(sum((a.num2+isnull(locknum,0))),0) as 账面数量,  " & vbcrlf & _
			"  isnull(a.unit,b.unitjb) as 单位ID," & vbcrlf & _
			"  isnull(sum((a.num2+isnull(locknum,0))),0) as 实盘数量,  " & vbcrlf & _
			"  isnull(a.unit,b.unitjb) as 单位ID," & vbcrlf & _
			"  0 as 盈亏数量 ," & vbcrlf & _
			"   '' 辅助单位, " & vbcrlf & _
			"   null as 辅助数量,  " & vbcrlf & _
			"  isnull((select top 1 y.price1 from ku y inner join kuinlist zz on y.kuinlist=zz.id and zz.sort1=1 where y.ord=b.ord  and y.unit=a.unit and y.ck=a.ck order by y.id desc),dbo.erp_getProductPrice(b.ord,isnull(a.unit,b.unitjb)," & app.info.user & ")) as 单价,  " & vbcrlf & _
			"  0 as 盈亏金额,  " & vbcrlf & _
			"   "&sql2&" " & vbcrlf & _
			"  '' as 备注,  " & vbcrlf & _
			"  (case when sign(isnull(a.ck,0))<>1 then isnull(e.isNoku,0) else 1 end) as isNoku " & vbcrlf & _
			"from #ttt e  " & vbcrlf & _
			"inner join product b on e.cpId=b.ord and b.del=1  " & vbcrlf & _
			"left join ku a on a.unit > 0 and (a.num2+isnull(locknum,0))<>0 and a.ord=e.cpid and e.ckid=a.ck  " & vbcrlf & _
			"inner join product b on e.cpId=b.ord and b.del=1  " & vbcrlf & _
			"left join sortck d on d.ord=a.ck  " & vbcrlf & _
			"left join Shop_GoodsAttr s1 on s1.id = a.ProductAttr1  "& vbcrlf & _
			"left join Shop_GoodsAttr s2 on s2.id = a.ProductAttr2  "& vbcrlf & _
			"where not exists(select * from #ttt2 x where x.ord = isnull(b.ord,0) and x.unit = isnull(a.unit,b.unitjb) and x.ku=isnull(a.ck,0)) " & vbcrlf & _
			"group by b.title ,b.ord,b.order1,b.type1,a.unit,a.ck,d.sort1,e.isNoku,b.unitjb,isnull(s1.title,'') , isnull(a.ProductAttr1,0),isnull(s2.title,'') , isnull(a.ProductAttr2,0) "
			set rs = cn.execute(sql)
			Dim sValue
			while not rs.eof
				for i = 0 to rs.fields.count-1
'while not rs.eof
					sValue=rs.fields(i).value
					If i=8 Or i=9 Or i=10 Then
						sValue = FormatNumber(sValue,app.Info.FloatNumber,-1,0,0)
'If i=8 Or i=9 Or i=10 Then
					ElseIf i=13 Then
						sValue = FormatNumber(sValue,app.Info.StorePriceNumber,-1,0,0)
'ElseIf i=13 Then
					ElseIf i=14 Then
						sValue = FormatNumber(sValue,app.Info.MoneyNumber,-1,0,0)
'ElseIf i=14 Then
					end if
					Response.write sValue & "|-"
'ElseIf i=14 Then
				next
				Response.write "$="
				rs.movenext
			wend
			rs.close
		end sub
		sub App_ListDrConfig(drdat)
			dim mFilePath
			mFilePath = "范例1=../../in/example_hzpddr1.xls|范例2=../../in/example_hzpddr2.xls"
			if isOpenProductAttr then mFilePath = "范例1=../../in/example_hzpddr3.xls|范例2=../../in/example_hzpddr2.xls"
			with drdat
			.title = "汇总盘点导入"
			.fileName = "汇总盘点数据"
			.filters = "xls|xlsx"
			.smpFilePath = mFilePath
			.helpFilePath = "../../in/hzpddr.doc"
			.remark = "请参考示例excel文件，确保导入的文件格式符合要求。"
			.autosave = true
			.allowSize = 25*1024*1024
			.modelCls = "盘点信息"
			end With
			Dim opt
			set opt = drdat.addOption()
			opt.selectindex = 0
			opt.key = "datatype"
			opt.name = "应用范例格式"
			call opt.add("范例1" , 0)
			call opt.add("范例2" , 1)
		end sub
		Sub App_lvw_InExcel
			Dim drmodel,f_Num, s_Num, a_Num
			drmodel = 1
			If request("sysoption0") = 0 Then
				drmodel = 1
			else
				drmodel = 2
			end if
			Dim sValue,sValue1
			If drmodel = 1 Then
				dim mFields : mFields = ""
				if isOpenProductAttr then mFields = "产品属性1,产品属性2,"
				set lvw = new listview
				set uploader = lvw.getuploader()
				db  = uploader.dbname
				if not uploader.CheckFields("产品名称,产品编号,产品型号,单位,"&mFields&"实盘数量,仓库名称,备注") then
					exit sub
				end if
				call uploader.RegRptItem("#k_all","导入报告")
				call uploader.RegRptItem("#k_fail","未导入报告")
				cn.execute "SET ANSI_WARNINGS OFF"
				cn.execute "create table #k_fail (行号 int, 失败原因 varchar(300))"
				cn.execute "create table #k_all (序号 int  IDENTITY(1,1) not null,内容 varchar(300), 说明 varchar(300))"
				cn.execute "select up_index, ('产品名称:<b style=""color:#000088"">' + isnull(cast(产品名称 as nvarchar(500)),'') + '</b>;产品型号:<b style=""color:#000088"">' + isnull(cast(产品型号 as nvarchar(500)),'') + '</b>;产品编号:<b style=""color:#000088"">'+ isnull(cast(产品编号 as nvarchar(500)),'') + '</b>') as 产品信息 into #pname from " & db,a_Num
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '此产品单位不可为空' from " & db & " where datalength(isnull(单位,'')) = 0"
				cn.execute "delete from " & db & " where datalength(isnull(单位,'')) = 0" , n
				f_Num = f_Num + n
				cn.execute "delete from " & db & " where datalength(isnull(单位,'')) = 0" , n
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '此产品单位长度不可超过500' from " & db & " where datalength(isnull(单位,'')) >1000"
				cn.execute "delete from " & db & " where datalength(isnull(单位,'')) >1000" , n2
				f_Num = f_Num + n2
				cn.execute "delete from " & db & " where datalength(isnull(单位,'')) >1000" , n2
				cn.execute "update " & db & " set 单位 = cast(u.ord as nvarchar(500)) from sortonehy u where u.gate2=61 and u.sort1 = cast(单位 as nvarchar(500))"
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '此产品单位不存在' from " & db & " where isnumeric(cast(单位 as nvarchar(500)))=0"
				cn.execute "delete from " & db & " where isnumeric(cast(单位 as nvarchar(500)))=0" , n1
				f_Num = f_Num + n1
				cn.execute "delete from " & db & " where isnumeric(cast(单位 as nvarchar(500)))=0" , n1
				cn.execute "insert into #k_all (内容,说明) values ('检测单位正确性','" & app.iif(n1+n+n2 > 0 ,"共<b style=""color:red"">" & (n1+n+n2) & "</b>条记录单位不正确。","") & "')"
				cn.execute "delete from " & db & " where isnumeric(cast(单位 as nvarchar(500)))=0" , n1
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '产品名称不可为空' from " & db & " where datalength(rtrim(isnull(cast(产品名称 as nvarchar(500)),''))) = 0"
				cn.execute "delete from " & db & " where datalength(rtrim(isnull(cast(产品名称 as nvarchar(500)),''))) = 0" , n
				f_Num = f_Num + n
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '产品名称不可超过500' from " & db & " where datalength(isnull(产品名称,'')) > 1000"
				cn.execute "delete from " & db & " where datalength(isnull(产品名称,'')) > 1000" , n2
				f_Num = f_Num + n2
				cn.execute "delete from " & db & " where datalength(isnull(产品名称,'')) > 1000" , n2
				cn.execute "update " & db & " set 产品名称=cast(ord as nvarchar(500)), 产品型号='#s_xx_tok' from product x where x.del=1 and x.title = isnull(cast(产品名称 as nvarchar(500)),'') and x.order1 = isnull(cast(产品编号 as nvarchar(500)),'') and x.type1=isnull(cast(产品型号 as nvarchar(500)),'')"
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '此产品不存在' from " & db & " where isnull(cast(产品型号 as nvarchar(500)),'') <> '#s_xx_tok'"
				cn.execute "delete from " & db & " where isnull(cast(产品型号 as nvarchar(500)),'') <> '#s_xx_tok'" , n1
				f_Num = f_Num + n1
				cn.execute "delete from " & db & " where isnull(cast(产品型号 as nvarchar(500)),'') <> '#s_xx_tok'" , n1
				cn.execute "update " & db & " set 产品型号='' where cast(单位 as nvarchar(15)) not in (select unit from jiage where cast(product as nvarchar(15)) = cast(产品名称 as nvarchar(15))) "
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '此产品单位不匹配' from " & db & " where isnull(cast(产品型号 as nvarchar(500)),'') <> '#s_xx_tok'"
				cn.execute "delete from " & db & " where isnull(cast(产品型号 as nvarchar(500)),'') <> '#s_xx_tok'" , n3
				f_Num = f_Num + n3
				cn.execute "delete from " & db & " where isnull(cast(产品型号 as nvarchar(500)),'') <> '#s_xx_tok'" , n3
				cn.execute "insert into #k_all (内容,说明) values ('检测产品正确性','" & app.iif(n1+n+n2+n3  > 0 ,"共<b style=""color:red"">" & (n1+n+n2+n3) & "</b>条记录产品资料不正确。","") & "')"
				cn.execute "delete from " & db & " where isnull(cast(产品型号 as nvarchar(500)),'') <> '#s_xx_tok'" , n3
				cn.execute  "declare @I int" & vbcrlf & _
				"set @I = 1 " & vbcrlf & _
				"select ord ,sort1 ,sort , cast(sort1 as varchar(7000)) as ckname,del,case when (charindex( ',"&app.Info.user&",',','+replace(cast(d.intro as varchar(4000)),' ','')+',')>0 or replace(cast(d.intro as varchar(10)),' ','')='0') then 1 else 0 end as qx into  #tmp from sortck d " & vbcrlf & _
				"set @I = 1 " & vbcrlf & _
				"while @I<100 and exists(select * from #tmp a inner join sortck1 b on a.sort=b.id and isnull(b.parentID,0) > 0 )" & vbcrlf & _
				"begin" & vbcrlf & _
				"   update  #tmp set sort=isnull(b.parentID,0), ckname = b.sort1 + '->' +  ckname from sortck1 b where #tmp.sort=b.id and isnull(b.parentID,0) > 0 " & vbcrlf & _
				"begin" & vbcrlf & _
				"   set @I = I + 1" & vbcrlf & _
				"begin" & vbcrlf & _
				"end" & vbcrlf & _
				"update  #tmp set sort=isnull(b.parentID,0), ckname = b.sort1 + '->' +  ckname from sortck1 b where #tmp.sort=b.id"
				cn.execute "update " & db & " set 仓库名称=cast(ord as nvarchar(500)) , 产品型号=case del when 0 then '#s_ckck_tok_del' else case qx when 1 then '#s_ckck_tok' else '#s_ckck_tok_qx' end end  from #tmp x where x.ckname = isnull(cast(仓库名称 as nvarchar(500)),'')"
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '此仓库不存在，请重新选择' from " & db & " where isnull(cast(产品型号 as nvarchar(500)),'') <> '#s_ckck_tok' and isnull(cast(产品型号 as nvarchar(500)),'') <> '#s_ckck_tok_del' and isnull(cast(产品型号 as nvarchar(500)),'') <> '#s_ckck_tok_qx' "
				cn.execute "delete from " & db & " where isnull(cast(产品型号 as nvarchar(500)),'') <> '#s_ckck_tok' and isnull(cast(产品型号 as nvarchar(500)),'') <> '#s_ckck_tok_del' and isnull(cast(产品型号 as nvarchar(500)),'') <> '#s_ckck_tok_qx'" , n
				f_Num = f_Num + n
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '仓库处于暂停状态，请联系仓库管理员！' from " & db & " where isnull(cast(产品型号 as nvarchar(500)),'') = '#s_ckck_tok_del'  "
				cn.execute "delete from " & db & " where  isnull(cast(产品型号 as nvarchar(500)),'') = '#s_ckck_tok_del'" , n1
				f_Num = f_Num + n1
				cn.execute "delete from " & db & " where  isnull(cast(产品型号 as nvarchar(500)),'') = '#s_ckck_tok_del'" , n1
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '您无权查看此仓库' from " & db & " where isnull(cast(产品型号 as nvarchar(500)),'') = '#s_ckck_tok_qx' "
				cn.execute "delete from " & db & " where isnull(cast(产品型号 as nvarchar(500)),'') = '#s_ckck_tok_qx' " , n2
				f_Num = f_Num + n2
				cn.execute "delete from " & db & " where isnull(cast(产品型号 as nvarchar(500)),'') = '#s_ckck_tok_qx' " , n2
				cn.execute "insert into #k_all (内容,说明) values ('检测仓库名称正确性','" & app.iif(n2+n1+n > 0 ,"共<b style=""color:red"">" & n & "</b>条记录仓库不存在，<b style=""color:red"">" & n1 & "</b>条记录仓库暂停，<b style=""color:red"">" & n2 & "</b>条记录仓库无权限","") & "')"
				cn.execute "delete from " & db & " where isnull(cast(产品型号 as nvarchar(500)),'') = '#s_ckck_tok_qx' " , n2
				num_dot_xs=2
				set rs=cn.execute("select num1 from setjm3  where ord=88")
				if Not rs.eof Then num_dot_xs=rs("num1")
				rs.close
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '实盘数量超过15位长度' from " & db & " where  datalength(实盘数量)>30"
				cn.execute "delete from " & db & " where  datalength(实盘数量)>30" , n
				f_Num = f_Num + n
				cn.execute "delete from " & db & " where  datalength(实盘数量)>30" , n
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '实盘数量不是数字' from " & db & " where isnumeric(isnull(cast(实盘数量 as nvarchar(15)),'xx')) = 0 "
				cn.execute "update " & db & " set 实盘数量=replace(cast(实盘数量 as nvarchar(15)),',','') where 实盘数量 is not null "
				cn.execute "delete from " & db & " where isnumeric(isnull(cast(实盘数量 as nvarchar(15)),'xx')) = 0 " , n
				cn.execute "delete from " & db & " where cast(cast(实盘数量 as nvarchar(15)) as float) < 0" , n1
				f_Num = f_Num + n
				cn.execute "delete from " & db & " where cast(cast(实盘数量 as nvarchar(15)) as float) < 0" , n1
				f_Num = f_Num + n1
				cn.execute "delete from " & db & " where cast(cast(实盘数量 as nvarchar(15)) as float) < 0" , n1
				cn.execute "insert into #k_all (内容,说明) values ('检测实盘数量正确性','" & app.iif((n +n1)> 0 ,"共<b style=""color:red"">" & (n+n1) & "</b>条记录实盘数量不正确","") & "')"
				cn.execute "delete from " & db & " where cast(cast(实盘数量 as nvarchar(15)) as float) < 0" , n1
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '小数位数超过"&num_dot_xs&"位，请修改后再导入' from " & db & " where  (cast(cast(实盘数量 as nvarchar(15)) as numeric(20,8))-cast(cast(实盘数量 as nvarchar(15)) as numeric(20,"&num_dot_xs&")) <> 0)"
				cn.execute "delete from " & db & " where cast(cast(实盘数量 as nvarchar(15)) as float) < 0" , n1
				cn.execute "delete from " & db & " where  (cast(cast(实盘数量 as nvarchar(15)) as numeric(20,8))-cast(cast(实盘数量 as nvarchar(15)) as numeric(20,"&num_dot_xs&")) <> 0)" , n
				cn.execute "delete from " & db & " where cast(cast(实盘数量 as nvarchar(15)) as float) < 0" , n1
				f_Num = f_Num + n
				cn.execute "delete from " & db & " where cast(cast(实盘数量 as nvarchar(15)) as float) < 0" , n1
				cn.execute "insert into #k_all (内容,说明) values ('检测实盘数量小数位数','" & app.iif( n> 0 ,"共<b style=""color:red"">" & n & "</b>条记录实盘数量小数位数不正确","") & "')"
				cn.execute "insert into #k_all (内容,说明) values ('检测实盘数量长度','" & app.iif( n> 0 ,"共<b style=""color:red"">" & n & "</b>条记录实盘数量超过15位长度","") & "')"
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '备注必须在1-500字之间' from " & db & " where  datalength(备注)>1000"
				cn.execute "delete from " & db & " where  datalength(备注)>1000" , n
				f_Num = f_Num + n
				cn.execute "delete from " & db & " where  datalength(备注)>1000" , n
				cn.execute "insert into #k_all (内容,说明) values ('检测备注长度','" & app.iif( n> 0 ,"共<b style=""color:red"">" & n & "</b>条记录备注超过500字","") & "')"
				dim attrText,attrInx,attrText2 , attrText3,attrText4
				attrText = ""
				attrInx = 2
				attrText2 = ""
				attrText3 = ""
				attrText4 = ""
				if isOpenProductAttr then
					cn.execute " update x set x.产品型号= (case when exists(select 1 from Shop_GoodsAttr st where st.proCategory = m.RootId and st.pid = 0) then m.RootId else -1 end) from "&db&" x inner join  product p on p.ord = x.ord inner join menu m on m.id = p.sort1 "
'if isOpenProductAttr then
					cn.execute " update x set x.产品属性1 = (case when len(ISNULL(x.产品属性1,''))=0 then 0 else (case isnull(s1.id,-1) when -1 then -1 else (case isnull(s1.isStop,0) when 1 then -2 else s1.id end) end) end) , x.产品属性2=(case when len(ISNULL(x.产品属性2,''))=0 then 0 else (case isnull(s2.id,-1) when -1 then -1 else (case isnull(s2.isStop,0) when 1 then -2 else s2.id end) end) end) "&_
					"from "&db&" x  "&_
					" left join Shop_GoodsAttr s1 on s1.pid = (SELECT top 1 id FROM Shop_GoodsAttr WHERE isTiled=1 AND pid=0 AND proCategory=x.产品型号 order by id desc) and s1.title=x.产品属性1 "&_
					" left join Shop_GoodsAttr s2 on s2.pid = (SELECT top 1 id FROM Shop_GoodsAttr WHERE isTiled=0 AND pid=0 AND proCategory=x.产品型号 order by id desc) and s2.title=x.产品属性2 "
					cn.execute "insert into #k_fail (行号,失败原因) select up_index, (case 产品属性1  when '-1' then '产品属性1不正确' when '-2' then '产品属性1属性项已停用' else  '' end)+ (case when 产品属性1 in('-1','-2') then '、' else '' end) +(case 产品属性2 when '-1' then '产品属性2不正确' when '-2' then '产品属性2属性项已停用' else '' end) from " & db & " where 产品属性1 in('-1','-2') or 产品属性2 in('-1','-2')  "
					cn.execute "delete from " & db & " where 产品属性1 in('-1','-2') or 产品属性2 in('-1','-2') " , n
					f_Num = f_Num + n
					attrText  = " and cast(x.产品属性1 as nvarchar(20)) = cast(y.产品属性1 as nvarchar(20)) and cast(x.产品属性2 as nvarchar(20)) = cast(y.产品属性2 as nvarchar(20)) "
					attrText2 = " and cast(a.产品属性1 as nvarchar(20)) = cast(b.ProductAttr1 as nvarchar(20)) and cast(a.产品属性2 as nvarchar(20)) = cast(b.ProductAttr2 as nvarchar(20)) "
					attrText3 = " and cast(e.产品属性1 as nvarchar(20)) = cast(a.ProductAttr1 as nvarchar(20)) and cast(e.产品属性2 as nvarchar(20)) = cast(a.ProductAttr2 as nvarchar(20)) "
					attrText4 = " and cast(e.ProductAttr1 as nvarchar(20)) = cast(a.ProductAttr1 as nvarchar(20)) and cast(e.ProductAttr2 as nvarchar(20)) = cast(a.ProductAttr2 as nvarchar(20)) "
				end if
				cn.execute "select x.up_index into #overlist "&_
				"from "&db&" x "&_
				"left join "&db&" y on cast(x.产品名称 as nvarchar(500)) = cast(y.产品名称 as nvarchar(500)) "&_
				"                       and isnull(cast(x.产品编号 as nvarchar(500)),'') = isnull(cast(y.产品编号 as nvarchar(500)),'') "&_
				"                       and isnull(cast(x.产品型号 as nvarchar(500)),'') = isnull(cast(y.产品型号 as nvarchar(500)),'') "&_
				"                       and isnull(cast(x.仓库名称 as nvarchar(500)),'') = isnull(cast(y.仓库名称 as nvarchar(500)),'') "&_
				"                       and cast(x.单位 as nvarchar(500)) = cast(y.单位 as nvarchar(500)) "& attrText &" and x.up_index<>y.up_index "&_
				"where  y.up_index>0 "
				cn.execute "insert into #k_fail (行号,失败原因) select y.up_index, '产品重复' from (select distinct up_index from #overlist ) y "
				cn.execute "delete from " & db & " where up_index in (select distinct up_index from #overlist)" , n
				f_Num = f_Num + n
				cn.execute "delete from " & db & " where up_index in (select distinct up_index from #overlist)" , n
				cn.execute "insert into #k_all (内容,说明) values ('检测产品是否重复','" & app.iif( n> 0 ,"共<b style=""color:red"">" & n & "</b>条记录产品重复导入","") & "')"
				cn.execute("drop table #overlist")
				cn.execute "update #k_fail set 失败原因 = 失败原因 + '(' + 产品信息 + ')' from #pname where up_index=行号"
				cn.execute("drop table #overlist")
				s_Num = a_Num - f_Num
				cn.execute("drop table #overlist")
				cn.execute "insert into #k_all (内容,说明) values ('导入结果','共<b style=""color:red"">" & s_Num & "</b>条记录产品导入成功，共<b style=""color:red"">" & f_Num & "</b>条记录产品导入失败')"
				cn.execute("select top 0 10000 as ord, 10000 as unit ,10000 as ProductAttr1, 10000 as ProductAttr2, 10000 as ku, 1 as isNoku, cast(100000 as numeric(20,"&num_dot_xs&")) as num, cast('' as nvarchar(500)) as remark, 10000 as px1 into #ttt1")
				cn.cursorLocation = 3
				set rs = server.CreateObject("adodb.recordset")
				dat = request.form("tagData")
				dats = split(dat,"|")
				rs.open "select * from #ttt1" , cn , 1, 3
				for i = 0 to ubound(dats)
					if len(dats(i)) > 1 then
						cells = split(dats(i),",")
						rs.addnew
						rs.fields(0).value = cells(0)
						rs.fields(1).value = app.iif(Len(cells(1))=0, 0, cells(1))
						rs.fields(2).value = app.iif(Len(cells(2))=0, 0, cells(2))
'rs.fields(3).value = app.iif(Len(cells(3))=0, 0, cells(3))
						rs.fields(2+ attrInx).value = app.iif(Len(cells(2+ attrInx))=0, 0, cells(2+ attrInx))
'rs.fields(3).value = app.iif(Len(cells(3))=0, 0, cells(3))
						rs.fields(3+ attrInx).value = cells(3+ attrInx)
'rs.fields(3).value = app.iif(Len(cells(3))=0, 0, cells(3))
						rs.fields(4+ attrInx).value = cells(4+ attrInx)
'rs.fields(3).value = app.iif(Len(cells(3))=0, 0, cells(3))
						rs.fields(5+ attrInx).value = cells(5+ attrInx)
'rs.fields(3).value = app.iif(Len(cells(3))=0, 0, cells(3))
						rs.fields(6+ attrInx).value = i+1
'rs.fields(3).value = app.iif(Len(cells(3))=0, 0, cells(3))
						rs.update
					end if
				next
				rs.close
				cn.execute "select ord as ord,unit as unit,ProductAttr1,ProductAttr2,ku as ku,isNoku as isNoku,sum(num) as num,remark as remark,min(px1) as px1 into  #ttt2 from #ttt1 group by ord,unit,ProductAttr1,ProductAttr2,ku,isNoku,remark"
				cn.execute "update b set num = num + cast(cast(a.实盘数量 as nvarchar(15)) as numeric(20,"&num_dot_xs&")),remark=cast(a.备注 as nvarchar(500)) "&_
				"   from "&db&" a "&_
				"   inner join #ttt2 b where cast(a.产品名称 as nvarchar(500)) = cast(b.ord as nvarchar(500)) and cast(a.单位 as nvarchar(500)) = cast(b.unit as nvarchar(500)) and cast(a.仓库名称 as nvarchar(500)) = cast(b.ku as nvarchar(500)) " & attrText2
				cn.execute "delete from "&db&" where up_index in (select up_index from "&db&" a inner join #ttt2 b on cast(a.产品名称 as nvarchar(500)) = cast(ord as nvarchar(500)) and cast(a.单位 as nvarchar(500)) = cast(unit as nvarchar(500)) "& attrText2 &" and cast(a.仓库名称 as nvarchar(500)) = cast(ku as nvarchar(500))) "
				cn.execute "alter table #ttt2 add px2 int"
				cn.execute "insert into #ttt2 (ord,unit,ProductAttr1,ProductAttr2,ku,isNoku,num,remark,px2,px1) "&_
				"                ""   select cast(e.产品名称 as nvarchar(500)),cast(e.单位 as  nvarchar(500)),cast(e.产品属性1 as  nvarchar(20)),cast(e.产品属性2 as  nvarchar(20)), cast(e.仓库名称 as  nvarchar(500)),case when a.ord is null then 1 else 0 end,cast(e.实盘数量 as nvarchar(15)),isnull(cast(e.备注 as nvarchar(500)),''),up_index,0"&_
				"   from "&db&" e "&_
				"   left join ku a on a.unit > 0 and (a.num2+isnull(locknum,0))<>0 and a.ord=cast(e.产品名称 as  nvarchar(500)) and cast(e.仓库名称 as  nvarchar(500))=a.ck and a.unit=cast(e.单位 as  nvarchar(500)) "& attrText3 &_
				"   from "&db&" e "&_
				"   group by cast(e.单位 as  nvarchar(500)),cast(e.实盘数量 as nvarchar(15)) ,cast(e.仓库名称 as  nvarchar(500)),cast(e.产品名称 as  nvarchar(500)),a.ord,isnull(cast(e.备注 as nvarchar(500)),''),up_index "
				Set rs_s = server.CreateObject("adodb.recordset")
				sql_s = "Select num1 from setjm3 Where ord=5430 and num1=1"
				rs_s.open sql_s,cn,1,1
				If Not rs_s.eof Then
					sql2 = "   isnull(d.sort1,(select top 1 sort1 from sortck where id = (select top 1 MainStore from jiage where product = b.ord and unit = b.unitjb))) as 仓库名称,  "
					sql2 = sql2&"      isnull(a.ck,(select top 1 id from sortck where id = (select top 1 MainStore from jiage where product = b.ord and unit = b.unitjb))) as 仓库ID,"
					sql3 = " ,仓库名称 = isnull((select top 1 sort1 from sortck where ord = ku and ord in(select top 1 MainStore from jiage where product = 产品ID and unit = 单位ID ) or ord in(select top 1 StoreID from ProductStoreBinding where ProductID = 产品ID and Unit = 单位ID )),'') "
				else
					sql2 = "   d.sort1 as 仓库名称,  "
					sql2 = sql2&"      a.ck as 仓库ID,"
					sql3 = " ,仓库名称 = isnull((select top 1 sort1 from sortck where ord = ku),'') "
				end if
				rs_s.close
				sql =       "select  " & vbcrlf & _
				"  b.title as 产品名称,  " & vbcrlf & _
				"  b.ord as 产品ID,  " & vbcrlf & _
				"  b.order1 as 产品编号,  " & vbcrlf & _
				"  b.type1 as 型号,  " & vbcrlf & _
				"  (select sort1 from sortonehy c where gate2=61 and c.ord=isnull(a.unit,e.unit)) + '^tag~' + cast(isnull(a.unit,e.unit) as varchar(12)) as 单位,  " & vbcrlf & _
				"  b.type1 as 型号,  " & vbcrlf & _
				"  isnull(a.unit,e.unit) as 单位ID," & vbcrlf & _
				"   s1.title + '^tag~' + cast(e.ProductAttr1 as varchar(20)) 产品属性1,"&_
				"  isnull(a.unit,e.unit) as 单位ID," & vbcrlf & _
				"   s2.title + '^tag~' + cast(e.ProductAttr2 as varchar(20)) 产品属性2,"&_
				"  isnull(a.unit,e.unit) as 单位ID," & vbcrlf & _
				"  isnull(sum((a.num2+isnull(locknum,0))),0) as 账面数量,  " & vbcrlf & _
				"  isnull(a.unit,e.unit) as 单位ID," & vbcrlf & _
				"  isnull(e.num,0) as 实盘数量,  " & vbcrlf & _
				"  cast(0 as decimal(24,8)) as 盈亏数量 ," & vbcrlf & _
				"  '' as 辅助单位,  " & vbcrlf & _
				"   null 辅助数量, "& vbcrlf & _
				"  isnull((select top 1 y.price1 from ku y inner join kuinlist zz on y.kuinlist=zz.id and zz.sort1=1 where y.ord=b.ord  and y.unit=a.unit and y.ck=a.ck order by y.id desc),dbo.erp_getProductPrice(b.ord,isnull(a.unit,e.unit)," & app.info.user & ")) as 单价,  " & vbcrlf & _
				"  cast(0 as decimal(38,8)) as 盈亏金额,  " & vbcrlf & _
				"   "&sql2&" " & vbcrlf & _
				"  e.remark as 备注,  " & vbcrlf & _
				"  (case when sign(isnull(a.ck,0))<>1 then isnull(e.isNoku,0) else 1 end) as isNoku,e.ku,isnull(max(e.px2),0) px2,isnull(max(e.px1),0) px1 " & vbcrlf & _
				"  into #ttt3 " & vbcrlf & _
				"from #ttt2 e "&_
				"inner join product b on e.ord=b.ord and b.del=1 "&_
				"left join ku a on a.unit > 0 and a.unit = e.unit and (a.num2+isnull(locknum,0))<>0 and a.ord=e.ord and e.ku=a.ck "& attrText4 &_
				"inner join product b on e.ord=b.ord and b.del=1 "&_
				"left join sortck d on d.ord=a.ck  " & vbcrlf & _
				" left join Shop_GoodsAttr s1 on s1.id = e.ProductAttr1  "&_
				" left join Shop_GoodsAttr s2 on s2.id = e.ProductAttr2  "&_
				"group by b.title ,b.ord,b.order1,b.type1,a.unit, e.ProductAttr1,s1.title , e.ProductAttr2,s2.title ,a.ck,d.sort1,e.isNoku,b.unitjb,e.num,e.remark,e.ku,e.unit"
				cn.execute(sql)
				cn.execute  "update #ttt3 set 盈亏数量 = cast(实盘数量 as decimal(24,8))-账面数量,盈亏金额=(cast(实盘数量 as decimal(24,8))-账面数量)*单价"
				cn.execute(sql)
				cn.execute " update #ttt3 set 仓库ID=ku "& sql3 &" where isNoku = 1"
				Set rs = cn.execute ("select 产品名称,产品ID,产品编号,型号,单位,单位ID,产品属性1,产品属性2,账面数量,实盘数量,盈亏数量,单价,盈亏金额,仓库名称,仓库ID,备注,isNoku from #ttt3 order by px2,px1")
				while not rs.eof
					for i = 0 to rs.fields.count-1
'while not rs.eof
						sValue=rs.fields(i).value
						If i=8 Or i=9 Or i=10 Then
							sValue = FormatNumber(sValue,app.Info.FloatNumber,-1,0,0)
'If i=8 Or i=9 Or i=10 Then
						ElseIf i=11 Or i=12 Then
							sValue = FormatNumber(sValue,app.Info.MoneyNumber,-1,0,0)
'ElseIf i=11 Or i=12 Then
						end if
						sValue1 = sValue1 & sValue & "|-"
'ElseIf i=11 Or i=12 Then
					next
					sValue1 = sValue1 & "$="
					rs.movenext
				wend
				rs.close
				Response.write "" & vbcrlf & "        <script>" & vbcrlf & "        try{" & vbcrlf & "        parent.parent.window.getnewlist1("""
				Response.write replace(replace(sValue1,"""","\"""),vbcrlf,"")
				Response.write """);" & vbcrlf & "        }catch(e){}" & vbcrlf & "        </script>" & vbcrlf & "        "
				uploader.showReport
				set uploader = nothing
				set lvw = nothing
			end if
			If drmodel = 2 Then
				set lvw = new listview
				set uploader = lvw.getuploader()
				db  = uploader.dbname
				if not uploader.CheckFields("条形码,实盘数量,仓库名称,备注") then
					exit sub
				end if
				call uploader.RegRptItem("#k_all","导入报告")
				call uploader.RegRptItem("#k_fail","未导入报告")
				cn.execute "SET ANSI_WARNINGS OFF"
				cn.execute "create table #k_fail (行号 int, 失败原因 varchar(300))"
				cn.execute "create table #k_all (序号 int  IDENTITY(1,1) not null,内容 varchar(300), 说明 varchar(300))"
				cn.execute "select up_index, ('条形码:<b style=""color:#000088"">' + isnull(cast(条形码 as nvarchar(500)),'') + '</b>') as 产品信息 into #pname from " & db,a_Num
				cn.execute "create table #k_all (序号 int  IDENTITY(1,1) not null,内容 varchar(300), 说明 varchar(300))"
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '条形码超长，请修改' from " & db & " where len(rtrim(isnull(cast(条形码 as nvarchar(100)),''))) > 50"
				cn.execute "delete from " & db & " where  len(rtrim(isnull(cast(条形码 as nvarchar(100)),''))) > 50" , n1
				f_Num = f_Num + n1
				cn.execute "delete from " & db & " where  len(rtrim(isnull(cast(条形码 as nvarchar(100)),''))) > 50" , n1
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '条形码不可为空' from " & db & " where datalength(rtrim(isnull(cast(条形码 as nvarchar(50)),''))) = 0"
				cn.execute "delete from " & db & " where datalength(rtrim(isnull(cast(条形码 as nvarchar(50)),''))) = 0" , n
				f_Num = f_Num + n
				cn.execute "delete from " & db & " where datalength(rtrim(isnull(cast(条形码 as nvarchar(50)),''))) = 0" , n
				cn.execute "insert into #k_all (内容,说明) values ('检测条形码长度','" & app.iif(n1+n > 0 ,"共<b style=""color:red"">" & n & "</b>条记录条形码为空，<b style=""color:red"">" & n1 & "</b>条记录条形码长度超过50。","") & "')"
				cn.execute "delete from " & db & " where datalength(rtrim(isnull(cast(条形码 as nvarchar(50)),''))) = 0" , n
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '此产品有多条，请核查' from " & db & " x where (select count(*) from (select unit,txm,product from jiage group by unit,txm,product having txm=cast(x.条形码 as nvarchar(50))) a) >1 "
				cn.execute "delete from " & db & " where (select count(*) from (select unit,txm,product from jiage group by unit,txm,product having txm=cast(条形码 as nvarchar(50))) a) >1" , n
				f_Num = f_Num + n
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '此产品不存在' from " & db & " x where (select count(*) from (select unit,txm,product from jiage group by unit,txm,product having txm=cast(x.条形码 as nvarchar(50))) a) =0 "
				cn.execute "delete from " & db & " where (select count(*) from (select unit,txm,product from jiage group by unit,txm,product having txm=cast(条形码 as nvarchar(50))) a) =0" , n1
				f_Num = f_Num + n1
				cn.execute "insert into #k_all (内容,说明) values ('检测条形码正确性','" & app.iif(n1+n > 0 ,"共<b style=""color:red"">" & n1 & "</b>条记录对应产品不存在，<b style=""color:red"">" & n & "</b>条记录对应产品有多条。","") & "')"
				cn.execute "alter table "&db&" add 产品名称 nvarchar(500),产品编号 nvarchar(500),产品型号 nvarchar(500),单位 nvarchar(500)"
				cn.execute "update " & db & " set 产品名称=product, 产品型号='',产品编号='',单位=unit from (select unit,txm,product from jiage group by unit,txm,product) a  where txm=cast(条形码 as nvarchar(50))"
				cn.execute  "declare @I int" & vbcrlf & _
				"set @I = 1 " & vbcrlf & _
				"select ord ,sort1 ,sort , cast(sort1 as varchar(7000)) as ckname,del,case when (charindex( ',"&app.Info.user&",',','+replace(cast(d.intro as varchar(4000)),' ','')+',')>0 or replace(cast(d.intro as varchar(10)),' ','')='0') then 1 else 0 end as qx into  #tmp from sortck d " & vbcrlf & _
				"set @I = 1 " & vbcrlf & _
				"while @I<100 and exists(select * from #tmp a inner join sortck1 b on a.sort=b.id and isnull(b.parentID,0) > 0 )" & vbcrlf & _
				"begin" & vbcrlf & _
				"  update  #tmp set sort=isnull(b.parentID,0), ckname = b.sort1 + '->' +  ckname from sortck1 b where #tmp.sort=b.id and isnull(b.parentID,0) > 0 " & vbcrlf & _
				"begin" & vbcrlf & _
				"  set @I = I + 1" & vbcrlf & _
				"begin" & vbcrlf & _
				"end" & vbcrlf & _
				"update  #tmp set sort=isnull(b.parentID,0), ckname = b.sort1 + '->' +  ckname from sortck1 b where #tmp.sort=b.id"
				cn.execute "update " & db & " set 仓库名称=cast(ord as nvarchar(50)) , 产品型号=case del when 0 then '#s_ckck_tok_del' else case qx when 1 then '#s_ckck_tok' else '#s_ckck_tok_qx' end end  from #tmp x where x.ckname = isnull(cast(仓库名称 as nvarchar(500)),'')"
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '此仓库不存在，请重新选择' from " & db & " where isnull(产品型号,'') <> '#s_ckck_tok' and isnull(产品型号,'') <> '#s_ckck_tok_del' and isnull(产品型号,'') <> '#s_ckck_tok_qx' "
				cn.execute "delete from " & db & " where isnull(产品型号,'') <> '#s_ckck_tok' and isnull(产品型号,'') <> '#s_ckck_tok_del' and isnull(产品型号,'') <> '#s_ckck_tok_qx'" , n
				f_Num = f_Num + n
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '仓库处于暂停状态，请联系仓库管理员！' from " & db & " where isnull(产品型号,'') = '#s_ckck_tok_del'  "
				cn.execute "delete from " & db & " where  isnull(产品型号,'') = '#s_ckck_tok_del'" , n1
				f_Num = f_Num + n1
				cn.execute "delete from " & db & " where  isnull(产品型号,'') = '#s_ckck_tok_del'" , n1
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '您无权查看此仓库' from " & db & " where isnull(产品型号,'') = '#s_ckck_tok_qx' "
				cn.execute "delete from " & db & " where isnull(产品型号,'') = '#s_ckck_tok_qx' " , n2
				f_Num = f_Num + n2
				cn.execute "delete from " & db & " where isnull(产品型号,'') = '#s_ckck_tok_qx' " , n2
				cn.execute "insert into #k_all (内容,说明) values ('检测仓库名称正确性','" & app.iif(n2+n1+n > 0 ,"共<b style=""color:red"">" & n & "</b>条记录仓库不存在，<b style=""color:red"">" & n1 & "</b>条记录仓库暂停，<b style=""color:red"">" & n2 & "</b>条记录仓库无权限","") & "')"
				cn.execute "delete from " & db & " where isnull(产品型号,'') = '#s_ckck_tok_qx' " , n2
				set rs=cn.execute("select num1 from setjm3  where ord=88")
				if Not rs.eof Then
					num_dot_xs=rs("num1")
				else
					num_dot_xs=2
				end if
				rs.close
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '实盘数量不是数字' from " & db & " where isnumeric(isnull(实盘数量,'xx')) = 0 "
				cn.execute "delete from " & db & " where isnumeric(isnull(实盘数量,'xx')) = 0 " , n
				f_Num = f_Num + n
				cn.execute "delete from " & db & " where isnumeric(isnull(实盘数量,'xx')) = 0 " , n
				cn.execute "delete from " & db & " where cast(实盘数量 as float) < 0" , n1
				f_Num = f_Num + n1
				cn.execute "delete from " & db & " where cast(实盘数量 as float) < 0" , n1
				cn.execute "insert into #k_all (内容,说明) values ('检测实盘数量正确性','" & app.iif((n +n1)> 0 ,"共<b style=""color:red"">" & (n+n1) & "</b>条记录实盘数量不正确","") & "')"
				cn.execute "delete from " & db & " where cast(实盘数量 as float) < 0" , n1
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '小数位数超过"&num_dot_xs&"位，请修改后再导入' from " & db & " where  (cast(实盘数量 as numeric(20,8))-cast(实盘数量 as numeric(20,"&num_dot_xs&")) <> 0)"
				cn.execute "delete from " & db & " where cast(实盘数量 as float) < 0" , n1
				cn.execute "delete from " & db & " where  (cast(实盘数量 as numeric(20,8))-cast(实盘数量 as numeric(20,"&num_dot_xs&")) <> 0)" , n
				cn.execute "delete from " & db & " where cast(实盘数量 as float) < 0" , n1
				f_Num = f_Num + n
				cn.execute "delete from " & db & " where cast(实盘数量 as float) < 0" , n1
				cn.execute "insert into #k_all (内容,说明) values ('检测实盘数量小数位数','" & app.iif( n> 0 ,"共<b style=""color:red"">" & n & "</b>条记录实盘数量小数位数不正确","") & "')"
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '实盘数量超过18位长度' from " & db & " where  len(实盘数量)>18"
				cn.execute "delete from " & db & " where  len(实盘数量)>18" , n
				f_Num = f_Num + n
				cn.execute "delete from " & db & " where  len(实盘数量)>18" , n
				cn.execute "insert into #k_all (内容,说明) values ('检测实盘数量长度','" & app.iif( n> 0 ,"共<b style=""color:red"">" & n & "</b>条记录实盘数量超过18位长度","") & "')"
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '备注必须在1-500字之间' from " & db & " where  datalength(备注)>1000"
				cn.execute "delete from " & db & " where  datalength(备注)>1000" , n
				f_Num = f_Num + n
				cn.execute "delete from " & db & " where  datalength(备注)>1000" , n
				cn.execute "insert into #k_all (内容,说明) values ('检测备注长度','" & app.iif( n> 0 ,"共<b style=""color:red"">" & n & "</b>条记录备注超过500字","") & "')"
				cn.execute "insert into #k_fail (行号,失败原因) select up_index, '产品重复' from ( select 产品名称,产品编号,产品型号,cast(仓库名称 as nvarchar(500)) 仓库名称,cast(单位 as nvarchar(500)) 单位 from "&db&" group by 产品名称,产品编号,产品型号,cast(仓库名称 as nvarchar(500)),cast(单位 as nvarchar(500)) having COUNT(up_index) > 1) x inner join "&db&" y on x.产品名称 = y.产品名称 and x.产品编号 = y.产品编号 and x.产品型号 = y.产品型号 and cast(x.仓库名称 as nvarchar(500)) = cast(y.仓库名称 as nvarchar(500)) and cast(x.单位 as nvarchar(500)) = cast(y.单位 as nvarchar(500)) "
				cn.execute "delete from " & db & " where up_index in (select up_index from ( select 产品名称,产品编号,产品型号,cast(仓库名称 as nvarchar(500)) 仓库名称,cast(单位 as nvarchar(500)) 单位 from "&db&" group by 产品名称,产品编号,产品型号,cast(仓库名称 as nvarchar(500)),cast(单位 as nvarchar(500)) having COUNT(up_index) > 1) x inner join "&db&"y on x.产品名称 = y.产品名称 and x.产品编号 = y.产品编号 and x.产品型号 = y.产品型号 and cast(x.仓库名称 as nvarchar(500)) = cast(y.仓库名称 as nvarchar(500)) and cast(x.单位 as nvarchar(500)) = cast(y.单位 as nvarchar(500)) )" , n
				f_Num = f_Num + n
				cn.execute "insert into #k_all (内容,说明) values ('检测产品是否重复','" & app.iif( n> 0 ,"共<b style=""color:red"">" & n & "</b>条记录产品重复导入","") & "')"
				cn.execute "update #k_fail set 失败原因 = 失败原因 + '(' + 产品信息 + ')' from #pname where up_index=行号"
				s_Num = a_Num - f_Num
				cn.execute "insert into #k_all (内容,说明) values ('导入结果','共<b style=""color:red"">" & s_Num & "</b>条记录产品导入成功，共<b style=""color:red"">" & f_Num & "</b>条记录产品导入失败')"
				cn.execute("select top 0 10000 as ord, 10000 as unit , 10000 as ku, 1 as isNoku, cast(100000 as numeric(20,"&num_dot_xs&")) as num, cast('' as nvarchar(500)) as remark, 10000 as px1 into #ttt1")
				cn.cursorLocation = 3
				set rs = server.CreateObject("adodb.recordset")
				dat = request.form("tagData")
				dats = split(dat,"|")
				rs.open "select * from #ttt1" , cn , 1 ,3
				for i = 0 to ubound(dats)
					if len(dats(i)) > 1 then
						cells = split(dats(i),",")
						rs.addnew
						rs.fields(0).value = cells(0)
						rs.fields(1).value = app.iif(Len(cells(1))=0, 0, cells(1))
						rs.fields(2).value = app.iif(Len(cells(2))=0, 0, cells(2))
						rs.fields(3).value = cells(3)
						rs.fields(4).value = cells(4)
						rs.fields(5).value = cells(5)
						rs.fields(6).value = i+1
						rs.fields(5).value = cells(5)
						rs.update
					end if
				next
				rs.close
				cn.execute "select ord as ord,unit as unit,ku as ku,isNoku as isNoku,sum(num) as num,remark as remark,min(px1) as px1 into  #ttt2 from #ttt1 group by ord,unit,ku,isNoku,remark"
				cn.execute "update #ttt2 set num = num + cast(cast(实盘数量 as nvarchar(15)) as numeric(20,"&num_dot_xs&")),remark=cast(x.备注 as nvarchar(500)) from "&db&" x where x.产品名称 = ord and cast( x.单位 as nvarchar(50)) = cast(unit as nvarchar(50)) and cast(x.仓库名称 as nvarchar(50)) = cast(ku as nvarchar(50))"
				cn.execute "delete from "&db&" where up_index in (select up_index from "&db&" x inner join #ttt2 on x.产品名称 = ord and cast(x.单位 as nvarchar(50)) = cast(unit as nvarchar(50)) and cast(x.仓库名称 as nvarchar(50)) = cast(ku as nvarchar(50))) "
				cn.execute "alter table #ttt2 add px2 int"
				cn.execute "insert into #ttt2 (ord,unit,ku,isNoku,num,remark,px2) select e.产品名称,cast(e.单位 as nvarchar(50)),cast(e.仓库名称 as nvarchar(50)),case when a.ord is null then 1 else 0 end,cast(e.实盘数量 as nvarchar(15)),isnull(cast(e.备注 as nvarchar(500)),''),up_index from "&db&" e left join ku a on a.unit > 0 and (a.num2+isnull(locknum,0))<>0 and a.ord=e.产品名称 and cast(e.仓库名称 as nvarchar(50))=cast(a.ck as nvarchar(50)) and cast(a.unit as nvarchar(50))=cast(e.单位 as nvarchar(50)) group by cast(e.单位 as nvarchar(50)),cast(e.实盘数量 as nvarchar(15)),cast(e.仓库名称 as nvarchar(50)),e.产品名称,a.ord,isnull(cast(e.备注 as nvarchar(500)),''),up_index"
				Set rs_s = server.CreateObject("adodb.recordset")
				sql_s = "Select num1 from setjm3 Where ord=5430 and num1=1"
				rs_s.open sql_s,cn,1,1
				If Not rs_s.eof Then
					sql2 = "   isnull(d.sort1,(select top 1 sort1 from sortck where id = (select top 1 MainStore from jiage where product = b.ord and unit = b.unitjb))) as 仓库名称,  "
					sql2 = sql2&"      isnull(a.ck,(select top 1 id from sortck where id = (select top 1 MainStore from jiage where product = b.ord and unit = b.unitjb))) as 仓库ID,"
					sql3 = " ,仓库名称 = isnull((select top 1 sort1 from sortck where ord = ku and ord in(select top 1 MainStore from jiage where product = 产品ID and unit = 单位ID ) or ord in(select top 1 StoreID from ProductStoreBinding where ProductID = 产品ID and Unit = 单位ID )),'') "
				else
					sql2 = "   d.sort1 as 仓库名称,  "
					sql2 = sql2&"      a.ck as 仓库ID,"
					sql3 = " ,仓库名称 = isnull((select top 1 sort1 from sortck where ord = ku),'') "
				end if
				rs_s.close
				sql =       "select  " & vbcrlf & _
				"  b.title as 产品名称,  " & vbcrlf & _
				"  b.ord as 产品ID,  " & vbcrlf & _
				"  b.order1 as 产品编号,  " & vbcrlf & _
				"  b.type1 as 型号,  " & vbcrlf & _
				"  (select sort1 from sortonehy c where gate2=61 and c.ord=isnull(a.unit,e.unit)) + '^tag~' + cast(isnull(a.unit,e.unit) as varchar(12)) as 单位,  " & vbcrlf & _
				"  b.type1 as 型号,  " & vbcrlf & _
				"  isnull(a.unit,e.unit) as 单位ID," & vbcrlf & _
				"   s1.title + '^tag~' + cast(a.ProductAttr1 as varchar(20)) 产品属性1,"&_
				"  isnull(a.unit,e.unit) as 单位ID," & vbcrlf & _
				"   s2.title + '^tag~' + cast(a.ProductAttr2 as varchar(20)) 产品属性2,"&_
				"  isnull(a.unit,e.unit) as 单位ID," & vbcrlf & _
				"  isnull(sum((a.num2+isnull(locknum,0))),0) as 账面数量,  " & vbcrlf & _
				"  isnull(a.unit,e.unit) as 单位ID," & vbcrlf & _
				"  isnull(e.num,0) as 实盘数量,  " & vbcrlf & _
				"  cast(0 as decimal(24,8)) as 盈亏数量 ," & vbcrlf & _
				"  '' as 辅助单位,  " & vbcrlf & _
				"   null 辅助数量, "& vbcrlf & _
				"  isnull((select top 1 y.price1 from ku y inner join kuinlist zz on y.kuinlist=zz.id and zz.sort1=1 where y.ord=b.ord  and y.unit=a.unit and y.ck=a.ck order by y.id desc),dbo.erp_getProductPrice(b.ord,isnull(a.unit,e.unit)," & app.info.user & ")) as 单价,  " & vbcrlf & _
				"  cast(0 as decimal(38,8)) as 盈亏金额, " & vbcrlf & _
				"   "&sql2&" " & vbcrlf & _
				"  e.remark as 备注,  " & vbcrlf & _
				"  (case when sign(isnull(a.ck,0))<>1 then isnull(e.isNoku,0) else 1 end) as isNoku,e.ku,isnull(max(e.px2),0) px2,isnull(max(e.px1),0) px1 " & vbcrlf & _
				"  into #ttt3 " & vbcrlf & _
				" from #ttt2 e inner join product b on e.ord=b.ord and b.del=1 "&_
				" left join ku a on a.unit > 0 and a.unit = e.unit and (a.num2+isnull(locknum,0))<>0 and a.ord=e.ord and e.ku=a.ck "&_
				" from #ttt2 e inner join product b on e.ord=b.ord and b.del=1 "&_
				" left join sortck d on d.ord=a.ck  " & vbcrlf & _
				" left join Shop_GoodsAttr s1 on s1.id = a.ProductAttr1 "&_
				" left join Shop_GoodsAttr s2 on s2.id = a.ProductAttr2 "&_
				"group by b.title ,b.ord,b.order1,b.type1,a.unit,a.ProductAttr1,s1.title,a.ProductAttr2,s2.title,a.ck,d.sort1,e.isNoku,b.unitjb,e.num,e.remark,e.ku,e.unit"
				cn.execute(sql)
				cn.execute  "update #ttt3 set 盈亏数量 = cast(实盘数量 as decimal(24,8))-账面数量,盈亏金额=(cast(实盘数量 as decimal(24,8))-账面数量)*单价"
				cn.execute(sql)
				cn.execute " update #ttt3 set 仓库ID=ku"&sql3&" where isNoku = 1"
				Set rs = cn.execute ("select 产品名称,产品ID,产品编号,型号,单位,单位ID,产品属性1,产品属性2,账面数量,实盘数量,盈亏数量,单价,盈亏金额,仓库名称,仓库ID,备注,isNoku from #ttt3 order by px2,px1")
				while not rs.eof
					for i = 0 to rs.fields.count-1
'while not rs.eof
						sValue=rs.fields(i).value
						If i=8 Or i=9 Or i=10 Then
							sValue = FormatNumber(sValue,app.Info.FloatNumber,-1,0,0)
'If i=8 Or i=9 Or i=10 Then
						ElseIf i=13 Or i=14 Then
							sValue = FormatNumber(sValue,app.Info.MoneyNumber,-1,0,0)
'ElseIf i=13 Or i=14 Then
						end if
						sValue1 = sValue1 & sValue & "|-"
'ElseIf i=13 Or i=14 Then
					next
					sValue1 = sValue1 & "$="
					rs.movenext
				wend
				rs.close
				Response.write "" & vbcrlf & "        <script>" & vbcrlf & "        try{" & vbcrlf & "        parent.parent.window.getnewlist1("""
				Response.write replace(replace(sValue1,"""","\"""),vbcrlf,"")
				Response.write """);" & vbcrlf & "        }catch(e){}" & vbcrlf & "        </script>" & vbcrlf & "        "
				uploader.showReport
				set uploader = nothing
				set lvw = nothing
			end if
		end sub
		Function HTMLEncode(fString)
			if not isnull(fString) Then
				fString = replace(fString, ">", "&gt;")
				fString = replace(fString, "<", "&lt;")
				fString = Replace(fString, CHR(32), "&nbsp;")
				fString = Replace(fString, CHR(34), "&quot;")
				fString = Replace(fString, CHR(39), "&#39;")
				fString = Replace(fString, CHR(13), "")
				fString = Replace(fString, CHR(10) & CHR(10), "</P><P> ")
				fString = Replace(fString, CHR(10), "<br>")
				HTMLEncode = fString
			end if
		end function
		Function HTMLDecode(fString)
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
		
%>
