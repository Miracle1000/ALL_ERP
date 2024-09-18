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
			Response.write "" & vbcrlf & "//<!--" & vbcrlf & "window.location.href = ""../../index2.asp""" & vbcrlf & "//--><script>window.location.href = ""../../index2.asp""</script>" & vbcrlf & ""
			app.run
		end if
		app.ClearDB
		Set app = Nothing
		
		Class TabItem
			Public Text
			Public ImageUrl
			Public Width
			Public Selected
			Public OverColor
			Public OutColor
			Public tag
		End Class
		Class TabControl
			Private mTabs
			Public id
			Public Indent
			Public offsetTop
			Public width
			Public cssText
			Public Function Tabs(index)
				Set Tabs = mTabs.items(index)
			end function
			Public Property Get Count
			count = mTabs.count
			End Property
			Public Function  Add (Text)
				Dim Item
				Set Item = new TabItem
				Item.Text = Text
				Item.ImageUrl = "../../images/smico/record.gif"
				Item.selected = False
				Item.OverColor = "#000000"
				item.outColor = "#000000"
				mTabs.add Item
				Set add = Item
			end function
			Public Sub  Class_Initialize
				Set mTabs = new Collection
				Indent = 18
				offsetTop = 3
			end sub
			Public Function HTML
				Dim i
				If Len(width) = 0 Then width = "auto"
				If isnumeric(width) Then  width = width & "px"
				If Len(cssText) = 0 Then cssText = "top:" & offsetTop & "px;width:" & width & ";overflow:hidden;margin-top:14px;*margin-top:13px;"
'If isnumeric(width) Then  width = width & "px"
				html   = "<div style='" & cssText & "'><Table id='TabCtl_" & id & "' cellPadding=0 class='TabCtl' style='margin-left:" & Indent & "px;'><tr>"
'If isnumeric(width) Then  width = width & "px"
				For i = 1 To mTabs.count
					Set item = Tabs(i)
					w = CInt(App.LenC(item.text)*7 +3)
'Set item = Tabs(i)
					html = html + "<td onclick='tabs.ITEMClick(this)' tag='" & item.tag & "' class='ssTabItem" & App.iif(item.Selected,"_select","") & "' style='left:"  & (-1*Indent*i) & "px;z-index:" & ((50-i) + 100*abs(item.selected)) & "'>" &_
					"<table onmouseout='tabs.itembgout(this)' onmouseover='tabs.itembgover(this)' onselectstart='return false' style="""""&_
					"<tr>"&_
					"<td class='TabItemSlash'>&nbsp;</td>" &_
					"<td class='TabItemImage' >" & App.iif(Len(item.imageurl)>1,"<img src=""" & item.imageurl & """>","") &  "</td>" &_
					"<td class='TabItemText'  valign=middle><span onmouseout='tabs.itemout(this,""" & item.outColor & """)' onmouseover='tabs.itemover(this,""" & item.overcolor & """)' style='color:""" & item.outColor & """;width:" &  w  & "px;display:inline-block;text-align:center'>" & item.text & "</span></td>"&_
					"</tr>" &_
					"</table>" &_
					"</td>"
				next
				html = html + "</tr></Table></div>"
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
		
		Sub Page_load
			Dim Id , oname
			Id = request.querystring("id") & ""
			If Len(id)=0 Or Not IsNumeric(id) Then
				app.showerr "参数无效" , "<span class=c_r>ID无效。</span><span style='width:200px;display:inline-block'>&nbsp;</span>"
'If Len(id)=0 Or Not IsNumeric(id) Then
				Exit sub
			end if
			If id > 0 then
				Set rs = cn.execute("select orderName from dbo.M_OrderSettings where id=" & id & " and disuserdef=0")
				if rs.eof Then
					app.showerr "参数无效" , "<span class=c_r>ID不识别，或者该内容不允许用户自定义。</span><span style='width:200px;display:inline-block'>&nbsp;</span>"
'if rs.eof Then
					Exit Sub
				else
					oname = rs.fields(0).value
				end if
				rs.close
			else
				oname = request("title")
			end if
			Response.write "" & vbcrlf & "<body>" & vbcrlf & "        <script language=javascript src='TabControl.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <script language=javascript src='bill.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <script language=javascript src='listview.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <script language=javascript src='automenu.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script><!-- 自动下拉选择组件 -->" & vbcrlf & "  <script language=javascript src='contextmenu.js?ver="
			Response.write Application("sys.info.jsver")
			'Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <script language=javascript src='fdconfig.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script><!-- 自动下拉选择组件 -->" & vbcrlf & "  <input type=""hidden"" id=""info_orderid"" value='"
			'Response.write Application("sys.info.jsver")
			Response.write id
			Response.write "'>" & vbcrlf & "    <div id='billtopbardiv'>" & vbcrlf & "                        <table class='full' style='table-layout:fixed;'>" & vbcrlf & "                        <tr>" & vbcrlf & "                            <td id=""billtitle""><span class=""resetTextColor333"" style='font-size:14px;letter-spacing:3px'>"
			'Response.write id
			Response.write oname
			Response.write "字段自定义</span></td>" & vbcrlf & "                                <td class='billtopbar' style='width:6px'>&nbsp;</td>" & vbcrlf & "                            <td id='billtopbar1' class='billtopbar'>" & vbcrlf & "                                        "
			Dim sql, selindex
			selindex = CLng("0" & request.querystring("selindex"))
			Set TabCtl = new TabControl
			TabCtl.id = "topMenu"
			tabCtl.offsetTop = 4
			If id > 0 then
				Set item = TabCtl.add("基本项")
				sql = "select ID,PKColumnName from dbo.M_OrderlistSettings where orderid=" & id & " and disuserdef=0"
			else
				Set item = TabCtl.add(request("item1"))
			end if
			item.selected = true
			item.imageurl = "../../images/smico/record.gif"
			If id > 0 then
				Set rs = cn.execute("select ID,PKColumnName from dbo.M_OrderlistSettings where orderid=" & id & " and disuserdef=0")
				If id = 2 Then
					If sdk.power.existsManu(3) Then rs.Filter = "PKColumnName<>'生产计划单明细'"
				end if
				while Not rs.eof
					with TabCtl.add(rs.fields(1).value)
					.imageurl = "../../images/smico/item.gif"
					.tag = rs.fields(0).value
					End with
					rs.movenext
				wend
				rs.close
				If id = 5 Then
					with TabCtl.add("产品信息")
					.imageurl = "../../images/smico/item.gif"
					.tag = ""
					End With
					Set rs = cn.execute("select ID,PKColumnName from dbo.M_OrderlistSettings where orderid=6 and disuserdef=0")
					while Not rs.eof
						with TabCtl.add(rs.fields(1).value)
						.imageurl = "../../images/smico/item.gif"
						.tag = rs.fields(0).value
						End with
						rs.movenext
					wend
					rs.close
				end if
			else
				Dim items
				items =  Split(Replace(request("items") & "", " " , ""), "|")
				For i = 0 To ubound(items)
					Dim idata
					idata = Split(items(i), "@")
					with TabCtl.add(idata(0))
					.imageurl = "../../images/smico/item.gif"
					.tag = idata(1)
					End with
				next
			end if
			TabCtl.width = "500"
			Response.write TabCtl.HTML
			Response.write "" & vbcrlf & "                              </td>" & vbcrlf & "                           <td id='billtopbar'>" & vbcrlf & "                                    <table align=right style='position:relative;top:2px'>" & vbcrlf & "                                   <tr>" & vbcrlf & "                                            <td>" & vbcrlf & "                                                    <button class='button' onclick='fSet.addField()'>添加字段</button>" & vbcrlf & "                                              </td>" & vbcrlf & "                                            <td>&nbsp;</td>" & vbcrlf & "                                         <td>" & vbcrlf & "                                                    <button class='button' onclick='fSet.SaveField()'>保存配置</button>" & vbcrlf & "                                             </td>" & vbcrlf & "                                           <td>" & vbcrlf & "                                                    <span id=topmsg>&nbsp;</span>" & vbcrlf & "                                           </td>" & vbcrlf & "                                   </tr>" & vbcrlf & "   </table>" & vbcrlf & "                                </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   </table>" & vbcrlf & "        </div>" & vbcrlf & "  <script type=""text/javascript"" language=""javascript"">" & vbcrlf & "               Tabs.ItemClick = function(index,id,tag){" & vbcrlf & "                        for (var i = 0; i < "
			Response.write TabCtl.count
			Response.write "; i ++ )" & vbcrlf & "                      {" & vbcrlf & "                               if (index==i)" & vbcrlf & "                                   document.getElementById(""F_TableItem"" + i).style.display = """";" & vbcrlf & "                              else" & vbcrlf & "                                    document.getElementById(""F_TableItem"" + i).style.display = ""none"";" & vbcrlf & "                  }" & vbcrlf & "               }" & vbcrlf & "    </script>" & vbcrlf & "       <div id='billBodyDiv' style='width:100%;overflow-x:hidden;overflow-y:auto;margin:0px'>" & vbcrlf & "                          "
			'Response.write TabCtl.count
			Dim i, hsp
			Call CFieldItemPage ( id , 0 , 0 )
			If id > 0 then
				Set rs = cn.execute("select ID, SubKeyName from dbo.M_OrderlistSettings where orderid=" & id & " and disuserdef=0")
				If id = 2 Then
					If sdk.power.existsManu(3) Then rs.Filter = "SubKeyName<>'MPSID'"
				end if
				while Not rs.eof
					i = i + 1
'while Not rs.eof
					Call CFieldItemPage ( id , rs.fields(0).value , i )
					rs.movenext
				wend
				rs.close
				If id = 5 Then
					Call CFieldItemPage ( 6, 0 , 1 )
					Call CFieldItemPage ( 6 ,4 , 2 )
				end if
			else
				For i = 0 To ubound(items)
					idata = Split(items(i), "@")
					Call CFieldItemPage ( id , idata(1), i+1 )
					idata = Split(items(i), "@")
				next
			end if
			Response.write "" & vbcrlf & "     </div>" & vbcrlf & "  "
			Set rs = cn.execute("select 0 as ID, 1 as forder,'' as fname,1 as ftype,0 as MustFillin,0 as OptionID,'' as FStyle,1 as isUsing,1 as CanExport,1 as CanSearch,1 as CanStat")
			If id > 0 then
				Response.write "<div id='nullField' style='display:none'>"
				CFieldItem rs , 1, 1, id
				Response.write "</div>"
			else
				For i = 0 To  ubound(Split(Replace(request("items") & "", " " , ""), "|")) + 1
					'Response.write "</div>"
					Response.write "<div id='nullField" & i & "' style='display:none'>"
					CFieldItem rs , 1, i, id
					Response.write "</div>"
				next
			end if
			rs.close
			If selindex > 0 Then
				Response.write "" & vbcrlf & "<script>" & vbcrlf & "     tabs.ITEMClick(document.getElementById(""TabCtl_topMenu"").rows[0].cells["
				Response.write selindex
				Response.write "]);" & vbcrlf & "</script>" & vbcrlf & " "
			end if
			Response.write "" & vbcrlf & "</body>" & vbcrlf & ""
		end sub
		Sub CFieldItemPage(orderid, ChildId, index)
			Dim i
			Response.write "<div id='F_TableItem" & index & "' " & app.iif(index>0,"style='display:none;'","style=''") &  " class=full orderid='" & orderid & "' childid='" & childid & "'>"
			If ChildId = 0 Then
				Set rs = cn.execute("select * from M_CustomFields where del=0 and isMaster=1 and OID=" & orderid)
			else
				Set rs = cn.execute("select * from M_CustomFields where del=0 and isMaster=0 and OID=" & ChildId)
			end if
			While Not rs.eof
				i = i + 1
'While Not rs.eof
				Call CFieldItem (rs.fields , i, index, orderid)
				rs.movenext
			wend
			rs.close
			Response.write "</div>"
		end sub
		Sub CFieldItem(fields , i, index, oid)
			Dim nm , v , display
			display = app.iif(i=1,"","")
			nm =  "fd_" & fields("ID").value
			Response.write "" & vbcrlf & "     <table ConfigId='"
			Response.write fields("ID").value
			Response.write "' style='width:100%;ackground-color:white;border-bottom:1px solid #c0ccdd;border-right:1px solid #c0ccdd;border-left:1px solid #e0e0ef;table-layout:fixed' id="""
			Response.write fields("ID").value
			Response.write nm
			Response.write """>" & vbcrlf & "        <col style='width:12%'><col style='width:20%'><col style='width:12%'><col style='width:56%'>" & vbcrlf & "    <tr>" & vbcrlf & "            <td class='billgrouptool' colspan=4 style='border-right:1px solid #ccccdd;border-top:0px'>" & vbcrlf & "                              <span style='float:right;width:95px'>" & vbcrlf & "                                 <table>" & vbcrlf & "                                 <tr>" & vbcrlf & "                                            <td><img src='../../images/smico/del.gif' width=12></td>" & vbcrlf & "                                                <td onmouseout='Bill.hideunderline(this,""blue"")' style='cursor:pointer' class='c_b' onmouseover='Bill.showunderline(this,""red"")' onclick='fSet.delField(this)'>删除该字段</td>" & vbcrlf & "                                         <td></td>" & vbcrlf & "                                       </tr>" & vbcrlf & "                                   </table>" & vbcrlf & "                                </span>" & vbcrlf & "                         <span class='billgrouptitle' hidden=0 onmouseout='Bill.hideunderline(this)' onclick='Bill.GroupHide(this)' onmouseover='Bill.showunderline(this)' style='font-weight:normal;color:#000088'>" & vbcrlf & "                                    <img src='../../images/jiantou.gif'>自定义字段"
			Response.write i
			Response.write "-["
			'Response.write i
			Response.write fields("fname").value
			Response.write "]" & vbcrlf & "                            </span>" & vbcrlf & "                         " & vbcrlf & "                </td>" & vbcrlf & "   </tr>" & vbcrlf & "   <tr style='display:"
			Response.write display
			Response.write "'>" & vbcrlf & "           <td class='billfieldleft'>字段名称：</td>" & vbcrlf & "               <td class='billfieldright'><input type=text class=text value='"
			Response.write fields("fname").value
			Response.write "'></td>" & vbcrlf & "              <td class='billfieldleft'>" & vbcrlf & "              "
			If CLng(request("id")) > 0 Then
				Response.write "字段样式："
			else
				Response.write Request("ziname") & "："
			end if
			Response.write "" & vbcrlf & "             </td>" & vbcrlf & "           <td class='billfieldright''>" & vbcrlf & "                    "
			Dim optionsdata, items, isurldy
			optionsdata = request("ops" & index)
			If Len(optionsdata) = 0 Then
				isurldy = 0
				optionsdata = "单行文本@1|多行文本@2|日期@3|数字@4|备注@5|是/否@6|自定义列表@7"
				Response.write "<select onchange='fSet.dataTypeChange(this)'>"
			else
				isurldy = 1
				Response.write "<select>"
			end if
			Dim ii
			opts = Split(optionsdata, "|")
			For ii= 0 To ubound(opts)
				items = Split(opts(ii), "@")
				If fields("ftype").value = items(1)*1 Then
					Response.write "<option value=" & items(1) & " selected>" & items(0) & "</option>"
				else
					Response.write "<option value=" & items(1) & ">" & items(0) & "</option>"
				end if
			next
			Response.write "" & vbcrlf & "                     </select>" & vbcrlf & "               </td>" & vbcrlf & "   </tr>" & vbcrlf & "   <tr style='display:"
			Response.write display
			Response.write "'>" & vbcrlf & "           <td class='billfieldleft'>是否启用：</td>" & vbcrlf & "               <td class='billfieldright'>" & vbcrlf & "                     <table style='width:110px;margin-left:10px'>" & vbcrlf & "                    <tr>" & vbcrlf & "                            <td><input type='radio' name="""
			'Response.write display
			Response.write nm
			Response.write "_rdo"" id="""
			Response.write nm
			Response.write "_rdo1"" "
			Response.write app.iif(fields("isUsing").value=0,"","checked")
			Response.write "></td>" & vbcrlf & "                               <td><label for='"
			Response.write nm
			Response.write "_rdo1'>启用</label></td>" & vbcrlf & "                             <td>&nbsp;</td>" & vbcrlf & "                         <td><input type='radio' name="""
			Response.write nm
			Response.write "_rdo"" id="""
			Response.write nm
			Response.write "_rdo2"" "
			Response.write app.iif(fields("isUsing").value=0,"checked","")
			Response.write "></td>" & vbcrlf & "                               <td><label for='"
			Response.write nm
			Response.write "_rdo2'>不启用</label></td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   </table>" & vbcrlf & "                </td>" & vbcrlf & "           <td class='billfieldleft'>排列顺序：</td>" & vbcrlf & "               <td class='billfieldright' >" & vbcrlf & "                    <select>" & vbcrlf & "                                "
			v = fields("FOrder").value
			For ii = 1 To 40
				Response.write "<option value='" & ii & "' "  & app.iif(v=ii,"selected","") & ">" & ii & "</option>"
			next
			Response.write "" & vbcrlf & "                     </select>" & vbcrlf & "               </td>" & vbcrlf & "   </tr>" & vbcrlf & "   <tr style='display:"
			If isurldy = 0 then
				Response.write display
			else
				Response.write "none"
			end if
			Response.write "'>" & vbcrlf & "           <td class='billfieldleft'>增强功能：</td>" & vbcrlf & "               <td colspan=3 class='billfieldright'>" & vbcrlf & "                   <table style=';margin-left:10px'>" & vbcrlf & "                       <tr>" & vbcrlf & "                            "
			'Response.write "none"
			dim notnullvisible
			notnullvisible = (fields("ftype").value> 2 and fields("ftype").value <> 5)
			notnullvisible = app.iif(notnullvisible,"visibility:hidden","")
			Response.write "" & vbcrlf & "                             <td style='display:none'><input type='checkbox' name="""
			Response.write nm
			Response.write "_ck1"" id="""
			Response.write nm
			Response.write "_ck1"" "
			Response.write app.iif(abs(fields("CanSearch").value)=1,"checked","")
			Response.write "></td>" & vbcrlf & "                               <td style='display:none'><label for='"
			Response.write nm
			Response.write "_ck1'>检索</label></td>" & vbcrlf & "                              <td style='display:none'>&nbsp;</td>" & vbcrlf & "                            <td style='display:none'><input type='checkbox' name="""
			Response.write nm
			Response.write "_ch2"" id="""
			Response.write nm
			Response.write "_ck2"" "
			Response.write app.iif(abs(fields("CanExport").value)=1,"checked","")
			Response.write "></td>" & vbcrlf & "                               <td style='display:none'><label for='"
			Response.write nm
			Response.write "_ck2'>导出</label></td>" & vbcrlf & "                              <td style='display:none'>&nbsp;</td>" & vbcrlf & "                            <td style='"
			Response.write notnullvisible
			Response.write "'><input type='checkbox' name="""
			Response.write nm
			Response.write "_ch3"" id="""
			Response.write nm
			Response.write "_ck3"" "
			Response.write app.iif(abs(fields("MustFillIn").value)=1,"checked","")
			Response.write "></td>" & vbcrlf & "                               <td style='"
			Response.write notnullvisible
			Response.write "'><label for='"
			Response.write nm
			Response.write "_ck3'>必填</label></td>" & vbcrlf & "                              <td style='display:none'>&nbsp;</td>" & vbcrlf & "                            <td style='display:none'><input type='checkbox' name="""
			Response.write nm
			Response.write "_ch4"" id="""
			Response.write nm
			Response.write "_ck4"" "
			Response.write app.iif(abs(fields("CanStat").value)=1,"checked","")
			Response.write "></td>" & vbcrlf & "                               <td style='display:none'><label for='"
			Response.write nm
			Response.write "_ck4'>参与统计</label></td>" & vbcrlf & "                  </tr>" & vbcrlf & "                   </table>" & vbcrlf & "                </td>" & vbcrlf & "   </tr>" & vbcrlf & "   <tr style='display:"
			Response.write app.iif(fields("ftype").value=7 And isurldy=0 ,display,"none")
			Response.write "'>" & vbcrlf & "           <td class='billfieldleft'>枚举内容：</td>" & vbcrlf & "               <td colspan=3 class='billfieldright'>" & vbcrlf & "           "
			selId = fields("OptionID").value
			If selId > 0 Then
				Set lvw = new listview
				lvw.sql = "select CValue as 字段内容 from M_CustomOptions where CFID=" & selId
				lvw.id = nm & "_lvw"
				lvw.CheckBox = False
				lvw.showtool = False
				lvw.autosum = False
				lvw.candelete =true
				lvw.border = 0
				lvw.pagesize = 5
				lvw.cols.items(1).resize = false
				Response.write "<div name='MyDefList' style='width:300px;padding:5px' selid='" & selId & "'>" & lvw.innerHTML & "<span class=link  onmouseover='Bill.showunderline(this,""red"")' onmouseout='Bill.hideunderline(this,""blue"")' onclick='fSet.CleardefList(this)'>清除</span></div>"
			ElseIf selId < 0 Then
				Call  CSysList(selId)
			else
				Response.write "" & vbcrlf & "                             <span class=link style='position:static;left:10px' onmouseover='Bill.showunderline(this,""red"")' onmouseout='Bill.hideunderline(this,""blue"")' onclick='fSet.CreatedefList(this)'>创建内容</span>" & vbcrlf & "                             <span class=link style='position:static;left:10px;display:none;' onmouseover='Bill.showunderline(this,""red"")' onmouseout='Bill.hideunderline(this,""blue"")' onclick='fSet.SelectSysList(this)'>内置内容</span>" & vbcrlf & "                              "
			end if
			Response.write "" & vbcrlf & "             </td>" & vbcrlf & "   </tr>" & vbcrlf & "   </table>" & vbcrlf & "        "
		end sub
		Sub App_CdefList
			Set lvw = new listview
			lvw.sql = "select top 0 CValue as 字段内容 from M_CustomOptions"
			lvw.id = nm & "_lvwtt#$"
			lvw.CheckBox = False
			lvw.showtool = False
			lvw.autosum = False
			lvw.candelete =true
			lvw.border = 0
			lvw.pagesize = 5
			lvw.cols.items(1).resize = false
			Response.write "<div style='width:300px;padding:5px' name='MyDefList'>" & vbcrlf & "               "
			Response.write lvw.innerHTML
			Response.write "" & vbcrlf & "             <span class=link onmouseover='Bill.showunderline(this,""red"")' onmouseout='Bill.hideunderline(this,""blue"")' onclick='fSet.CleardefList(this)'>" & vbcrlf & "               清除" & vbcrlf & "            </span>" & vbcrlf & " </div>"
		end sub
		Sub App_getSysList
			Call  CSysList(0)
		end sub
		Sub CSysList(defId)
			Dim html , i , id , lin
			defId = abs(defId)
			Response.write "" & vbcrlf & "     <table name='SysDefList' style='background-color:#ccccee;margin:2px;border:1px solid #aaaacc;width:400px'>" & vbcrlf & "                      <tr>" & vbcrlf & "                            <td style='height:30px;' nowrap>&nbsp;系统内置可选项目" & vbcrlf & "                                  <select name='SysDefList' onchange='fSet.ShowSysListBody(this)'>" & vbcrlf & "                                  "
			Set rs = cn.execute("select ID,title from M_CustomSQLStrings where  charindex('@',replace(replace(sqlstring,'@key',''),'@uid',''))=0 and charindex(',',sColumns)=0")
			while Not rs.eof
				i = i + 1
'while Not rs.eof
				If i = 1 Then
					id = rs.fields(0).value
				end if
				If  defId =  rs.fields(0).value then
					Response.write "<option value='-" & rs.fields(0).value & "' selected>" & rs.fields(1).value & "</option>"
'If  defId =  rs.fields(0).value then
					id = defId
				else
					Response.write "<option value='-" & rs.fields(0).value & "'>" & rs.fields(1).value & "</option>"
					id = defId
				end if
				rs.movenext
			wend
			rs.close
			Response.write "" & vbcrlf & "                                     </select>" & vbcrlf & "                               </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   <tr>" & vbcrlf & "                            <td style='background-color:#eeeeff;padding:3px'><span class=c_r style='float:right'>系统内置内容无法编辑</span>以下为包含内容&nbsp;<td>" & vbcrlf & "                        </tr>" & vbcrlf & "                   <tr>" & vbcrlf & "                            <td style='background-color:white;padding:3px;width:auto'>" & vbcrlf & "                                            "
			id = defId
			If isnumeric(id) And Len(id) > 0 then
				Response.write GetSysListBody(id)
			end if
			Response.write "" & vbcrlf & "                             </td>" & vbcrlf & "                   </tr>" & vbcrlf & "   </table>" & vbcrlf & "        <span tag='此span不能删，用于套格式'>" & vbcrlf & "                   <span class=link onmouseover='Bill.showunderline(this,""red"")' onmouseout='Bill.hideunderline(this,""blue"")' onclick='fSet.CleardefList(this)'>" & vbcrlf & "                       清除" &vbcrlf & "                        </span>" & vbcrlf & " </span>" & vbcrlf & " "
		end sub
		function GetSysListBody(id)
			Dim sql
			Set rs = cn.execute("select sqlstring from M_CustomSQLStrings where id=" & abs(id))
			If not rs.eof then
				sql = Replace(Replace(Replace(rs.fields(0).value,"@key","''"),"@uid",app.info.user),"sql=","")
			else
				rs.close
				Exit function
			end if
			rs.close
			Set lvw = new listview
			lvw.id = "l" & Replace(CStr(CDbl(now)) ,".","") & CInt(Rnd()*1000)
			lvw.pagetype = "database"
			lvw.sql = sql
			lvw.showtool = False
			lvw.pagesize = 4
			lvw.autosum = False
			lvw.border = 0
			lvw.visiblecol = 4
			if lvw.cols.count = 2 Then
				If LCase(lvw.cols.items(1).ywname) = "billselectname" Then
					lvw.cols.items(1).ywname = "显示信息"
					lvw.cols.items(2).ywname = "对应值"
				end if
			end if
			GetSysListBody = lvw.innerHTML
		end function
		Sub App_ShowSysListBody
			Response.write GetSysListBody(abs(request.Form("SelectId")))
		end sub
		Sub App_Save
			Dim oIDs , oIDC, pord, dat , tbs , trs , tds , mtime, dats
			ReDim oIDs(0)
			oIDC = 0
			cn.BeginTrans
			dat = request.Form("data")
			tbs = Split(dat,"<#page#>")
			mtime = Now
			For i = 0 To UBound(tbs)
				If instr(tbs(i),Chr(2)) > 0 Then
					dats = Split(tbs(i), Chr(2))
					If pord <> dats(0) Then
						pord = dats(0)
						ReDim Preserve oIDs(oIDC)
						oIDs(oIDC) = pord
						oIDC = oIDC + 1
						oIDs(oIDC) = pord
					end if
					If Len(dats(1))>0 Then
						trs = Split(dats(1),"<#field#>")
						For ii = 0 To UBound(trs)
							Call SaveField (pord , Split(trs(ii),"<#item#>"), mTime)
						next
					end if
				end if
			next
			For i = 0 To oIDC - 1
				Call SaveField (pord , Split(trs(ii),"<#item#>"), mTime)
				oid = oIDs(i)
				cn.execute "update M_CustomFields set del=1 where  ((oid = " & oid & " and isMaster=1) or (oid in (select id from M_OrderListSettings where OrderId=" & oid & ") and isMaster=0))  and abs(datediff(s,LastModify,'" & mtime & "'))>0"
				cn.execute "delete from M_CustomOptions where CFID not in (select optionid from  M_CustomFields where del=0)"
				cn.execute "delete from M_CustomFields where del=1"
				Set rs = cn.execute("select b.PKColumnName as n,count(b.PKColumnName) as c from  M_CustomFields a, M_OrderListSettings b where b.id=a.oid and b.orderid=" &  oid & " and a.ismaster = 0 and del=0 group by b.PKColumnName")
				While  Not rs.eof
					If rs.fields(1).value > 15 Then
						MsgBox "【" & rs.fields(0).value & "】自定义字段数量过多，目前系统最多支持定义15个自定义字段。"
						rs.close
						cn.RollbackTrans
						Exit sub
					end if
					rs.movenext
				wend
				rs.close
			next
			cn.CommitTrans
			app.alert "保存成功"
			Response.write "window.location.href='" & sdk.ClearUrl("fdConfig.asp?" & Replace(request.form("url"),"selindex=","") & "&selindex=" & request.form("selindex")) & "'"
		end sub
		Sub SaveField (OrderId , cells , mtime)
			Dim cf_id , ismaster
			cf_id = cells(1)
			Set rs = server.CreateObject("adodb.recordset")
			rs.open "select OID,isMaster,fname,Forder,ftype,optionid,fstyle,isUsing,CanExport,CanSearch,canstat,LastModify,mustfillin, del from M_CustomFields where ID=" & cf_id , cn , 1 , 3
			If rs.eof Then
				rs.addnew
				ismaster = abs(cells(0) = 0)
				If ismaster Then
					rs.fields("OID").value = orderID
				else
					rs.fields("OID").value = cells(0)
				end if
				rs.fields("isMaster").value = abs(ismaster)
			end if
			rs.fields("fname").value = cells(2)
			rs.fields("ftype").value = cells(3)
			rs.fields("isUsing").value = cells(4)
			rs.fields("forder").value = cells(5)
			rs.fields("canSearch").value = cells(6)
			rs.fields("CanExport").value = cells(7)
			rs.fields("mustfillin").value = cells(8)
			rs.fields("canstat").value = cells(9)
			Call SaveListData (rs.fields("optionid"),cells(10),orderid)
			rs.fields("del").value = 0
			rs.fields("LastModify").value = mtime
			rs.update
			rs.close
		end sub
		Sub SaveListData (field,v,oid)
			Dim list, rs , listdata
			If Len(v) = 0 Then
				field.value = 0
			else
				If  IsNumeric(v) Then
					field.value = v
				else
					list = Split(v,"===")
					If UBound(list) = 1 And IsNumeric(list(0)) then
						listdata = Split(list(1),"#or")
						cn.execute "delete from M_CustomOptions where CFID=" & list(0)
						If list(0) = 0 Then
							Set rs = cn.execute("select isnull(max(CFID),0)+1 from M_CustomOptions")
'If list(0) = 0 Then
							If rs.eof Then
								list(0) = 1
							else
								list(0) = rs.fields(0).value
							end if
							rs.close
						end if
						Set rs = server.CreateObject("adodb.recordset")
						rs.open "select CFID,CValue,del from M_CustomOptions where 1=0",cn,1,3
						For i = 0 To UBound(listdata)
							rs.addnew
							rs.fields("CFID").value = list(0)
							rs.fields("CValue").value = listdata(i)
							rs.fields("del").value = 0
							rs.update
						next
						rs.close
						field.value = list(0)
					else
						field.value = 0
					end if
				end if
			end if
		end sub
		
%>
