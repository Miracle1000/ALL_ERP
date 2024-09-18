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
			'Response.write "" & vbcrlf & "//<!--" & vbcrlf & "window.location.href = ""../../index2.asp""" & vbcrlf & "//--><script>window.location.href = ""../../index2.asp""</script>" & vbcrlf & ""
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
					"                                                                     ""<td class='TabItemText'  valign=middle><span onmouseout='tabs.itemout(this,""" & item.outColor & """)' onmouseover='tabs.itemover(this,""" & item.overcolor & """)' style='color:""" & item.outColor & """;width:" &  w  & "px;display:inline-block;text-align:center'>" & item.text & "</span></td>"&_
					"</tr>" &_
					"</table>" &_
					"</td>"
				next
				html = html + "</tr></Table></div>"
			end function
		End Class
		class AttrClass
			Private Sub Class_Initialize()
				visible = true
				fixed = false
			end sub
			private mWidth
			private mColor
			private malign
			private mdisplay
			private mBackColor
			private mstyle1
			private mstyle2
			public Property let Width(byval  value)
			if value = "默认" then  value = ""
			mWidth = value
			end Property
			public Property get Width()
			width = mWidth
			end Property
			public Property let Color(byval  value)
			if value = "默认" then  value = ""
			mColor = value
			end Property
			public Property get color()
			color = mcolor
			end Property
			public Property let align(byval  value)
			if value = "默认" then  value = ""
			malign = value
			end Property
			public Property get align()
			align = malign
			end Property
			public Property let display(byval  value)
			if value = "默认" then  value = ""
			mdisplay = value
			end Property
			public Property get display()
			display = mdisplay
			end Property
			public Property let BackColor(byval  value)
			if value = "默认" then  value = ""
			mBackColor = value
			end Property
			public Property get BackColor()
			backcolor = mbackcolor
			end Property
			private sub updateStyle
				mstyle = ""
			end sub
			Public Property Get styleHTML(t)
			if len(mstyle1) = 0 then
				if len(mcolor) > 0 then mstyle1 = mstyle1 & ";color:" & mcolor
				if len(mbackcolor) > 0 then mstyle1 = mstyle1 & ";background-color:" & backcolor
				if len(mcolor) > 0 then mstyle1 = mstyle1 & ";color:" & mcolor
				if len(mdisplay) > 0 then mstyle1 = mstyle1 & ";display:" & mdisplay
				if len(malign) > 0 then mstyle1 = mstyle1 & ";text-align:" & malign : mstyle2 = mstyle2 & ";text-align:center;"
				if len(mdisplay) > 0 then mstyle1 = mstyle1 & ";display:" & mdisplay
				if len(mwidth) > 0 then  mstyle2 = mstyle2 & ";width:" & mwidth
				if len(mheight) > 0 then mstyle1 = mstyle1 & ";height:" & mheight : mstyle2 = mstyle2 & ";height:" & mheight
				if len(mstyle1) > 0 then
					mstyle1 = " style=""" & mstyle1 & ";"" "
				else
					mstyle1 = " "
				end if
				if len(mstyle2) > 0 then
					mstyle2 = " style=""" & mstyle2 & ";"" "
				else
					mstyle2 = " "
				end if
			end if
			if t = 0 then
				styleHTML = mstyle1
			else
				styleHTML = mstyle2
			end if
			End property
			public sub read(byval code)
				dim cindex
				cindex = instr(code,"{")
				if  cindex > 0 then
					code = mid(code,cindex+1)
'if  cindex > 0 then
					code = left(code,len(code)-1)
'if  cindex > 0 then
					code = replace(code,":" , ":me.")
					code = "me." & code
					on error resume next
					execute(code)
				end if
			end sub
		end class
		class setFieldClass
			public ywname
			public varname
			public dtype
			public value
			public selid
			public allownull
			public defvalue
			public description
		end class
		class ReportClass
			private mtitle
			private mremark
			private mdatefield
			private msql
			private HeadRows
			private HeadRowCount
			private cfid
			public cls
			private mHeader
			public footer
			private rs
			Public  mPageSize
			private mPageIndex
			private mRecordCount
			private mPageCount
			private mHasIndex
			private mFields
			public align
			public newfilterText
			public basefilterText
			public ExcelMode
			private mGroupID
			private productLinkPower
			public Property get header
			dim I , html , item
			html = mheader
			for I = 1 to me.fields.count
				set item = me.fields.items(i)
				html = replace(html,item.varname , item.value ,1,-1,1)
				set item = me.fields.items(i)
			next
			header = html
			end property
			public property get GroupID
			GroupID = cint(mgroupID)
			end property
			Public Property Get Fields
			set fields = mfields
			End property
			Public Property Get HasIndex
			HasIndex = mHasIndex
			End property
			Public Property Get PageIndex
			PageIndex = mPageIndex
			End property
			Public Property Get RecordCount
			RecordCount = mRecordCount
			End property
			Public Property Get PageCount
			PageCount = mPageCount
			End property
			Public Property Get PageSize
			PageSize = mPageSize
			End property
			Public Property Get recordset
			set recordset = rs
			End property
			Public Property Get title
			title = mtitle
			End property
			Public Property Get datefield
			datefield = mdatefield
			End property
			Public Property Get remark
			remark = mremark
			End property
			Public Property Get Sql
			sql = msql
			End property
			Public Property Get ID
			ID = cfid
			End property
			public sub LoadFieldInfo(fconfig)
				dim rows , i , ii , item , itemcode ,ndat
				rows = split(fconfig,"|")
				for i = 0 to ubound(rows)
					if len(rows(i)) > 0 then
						set item = new setFieldClass
						itemcode = split(rows(i),";")
						for ii = 0 to ubound(itemcode)
							select case ii
							case 0 : item.ywname = replace(itemcode(0),"；","")
							case 1 : item.varname = replace(itemcode(1),"；","")
							case 2 : item.dtype = itemcode(2)
							case 3 : item.selid = itemcode(3)
							case 4 : item.defvalue = replace(itemcode(4),"；","")
							case 5 : item.allownull = itemcode(5)<> "1"
							case 6 : item.description = itemcode(6)
							end select
						next
						if len(item.varname) > 0 then
							item.value = replace(request.form("rpt_info_fld_" & replace(item.varname,"@","")),"'","''")
							if len(item.value) = 0 then
								item.value = item.defvalue
								select case lcase(item.value)
								case "@uid" : item.value = app.info.user
								case "@user" : item.value = app.info.user
								case "@date" : item.value = date()
								case "@time" : item.value = time()
								case "@mdate1" : item.value =  year(date) & "-" & month(date) & "-1"
								case "@time" : item.value = time()
								case "@mdate2" : ndat = (date - day(date) + 35) : item.value =  cdate(ndat - day(ndat))
								case "@time" : item.value = time()
								end select
							end if
						end if
						mFields.add item
						msql = replace(msql,item.varname , "'" & item.value & "'")
					end if
				next
			end sub
			Private Sub Class_Initialize()
				dim fConfig
				set mFields = new Collection
				cfid = request.form("ReportID")
				mgroupID = request.form("GroupID")
				if len(mgroupid) = 0 then mgroupid = request.Form("rpt_info_groupid")
				if len(mgroupid) = 0  Then mgroupid = 0
				if not isnumeric(mgroupid) then mgroupid = 0
				ExcelMode  = (cstr(request.form("cexcel") & "") = "1")
				if len(cfid) = 0 then cfid = request.querystring("ReportID")
				if len(cfid) = 0 then cfid = 0
				if not isnumeric(cfid) then cfid = 0
				set rs = cn.execute("select * from M_ReportConfig where id=" & cfid)
				if not rs.eof then
					msql = rs.fields("sqltext").value
					mtitle = rs.fields("title").value
					mremark = rs.fields("remark").value
					mdatefield = rs.fields("datefield").value
					cls = rs.fields("class").value
					mheader = rs.fields("header").value
					footer = rs.fields("footer").value
					fConfig = rs.fields("conditions").value
				else
					mremark = ""
					msql = ""
					mtitle = ""
					mdatefield  = ""
					fConfig = ""
				end if
				rs.close
				call loadFieldInfo(fconfig)
				basefilterText = request.form("basefilterText")
				newfilterText = request.form("newfilterText")
				If Len(basefilterText) = 0 Then
					basefilterText = request.form("rpt_info_basefilterText")
				end if
				mPageSize = request.form("PageSize")
				if len(mPageSize) = 0 then mPageSize = 12
				if not isnumeric(mPageSize) then mPageSize = 12
				mPageIndex = request.form("PageIndex")
				if len(mPageIndex) = 0 then mPageIndex = 1
				if not isnumeric(mPageIndex) then mPageIndex = 1
				mHasIndex = request.form("HasIndex")
				if len(mHasIndex) = 0 then mHasIndex = 1
				if not isnumeric(mHasIndex) then mHasIndex = 1
				call InitReport
			end sub
			private function getRequestMessage(byval sql)
				dim msg , dat , n , v
				msg = split(request.querystring,"&")
				for i = 0 to ubound(msg)
					dat = split(msg(i),"=")
					if ubound(dat) > 0 then
						n = dat(0)
						v = right(msg(i) , len(msg(i))-len(n)-1)
						n = dat(0)
						v = replace(replace(replace(v,vbcr,""),vblf,""),"'","''")
						sql =  replace(sql,"@Query[" & n & "]", "'" & v & "'",1,-1,1)
'v = replace(replace(replace(v,vbcr,""),vblf,""),"'","''")
					end if
				next
				if Instr(1,sql,"@Query[",1)>0 then
					sql = replace(replace(sql,"@Query[","'"),"]","'")
				end if
				getRequestMessage = sql
			end function
			private sub InitReport
				Dim newsql
				if me.groupid = 0 Then
					If newfiltertext = "---" Then basefiltertext = "" : newfiltertext = ""
'if me.groupid = 0 Then
					If Len(newfiltertext) >0 Then basefiltertext = newfiltertext
					msql = getRequestMessage(msql)
					set rs = app.getrecord(cn,msql)
					if len(rtrim(basefiltertext)) > 0 Then
						on error resume next
						rs.filter = basefiltertext
						On Error goto 0
					end if
				else
					If newfiltertext = "---" Then  newfiltertext = ""
					On Error goto 0
					set rs = cn.execute("select * from M_ReportGroups where id=" & me.GroupID)
					if rs.eof then
						newsql = ""
					else
						newsql = rs.fields("sqltext").value
						mtitle = rs.fields("title").value
					end if
					rs.close
					If Len(newsql) >0 then
						if len(basefiltertext) = 0 then
							call App.db.CreateDbTableBySql("erp_report_temp" ,  msql)
						else
							set rs = App.getdatarecord(app.getrecord(cn,msql))
							rs.filter = basefiltertext
							app.db.CreateDbTableByRecordSet "erp_report_temp", rs
							rs.close
						end if
						msql = newsql
					else
						msql = "select '统计配置无效.' as 提示"
					end if
					set rs = cn.execute(msql)
					if len(rtrim(newfilterText)) > 0 Then
						on error resume next
						rs.filter = me.newfilterText
						Response.write Err.description
						On Error goto  0
					end if
				end if
				mRecordCount = 0
				Dim eof
				on error resume next
				eof = rs.eof
				If Abs(Err.number) > 0 Then
					Response.clear
					Response.write "获取数据失败。<textarea style='display:none'>" & msql & "</textarea>"
					Response.end
				end if
				while not rs.eof
					mRecordCount = mRecordCount + 1
'while not rs.eof
					rs.movenext
				wend
				if not rs.bof then
					rs.movefirst
					if mPageSize*1 < 0 then mPageSize = mRecordCount
					mPageCount = mRecordCount \ mPageSize + app.iif((mRecordCount mod mPageSize > 0),1,0)*1
'if mPageSize*1 < 0 then mPageSize = mRecordCount
					mPageCount = App.iif(mPageCount < 1 , 1 , mPageCount)
					if mPageIndex*1 > mPageCount*1 then mPageIndex = mPageCount
				else
					mPageIndex = 1
					mPageSize = 10
					mRecordCount = 0
				end if
			end sub
			private sub CHead
				dim i ,  t , t1 , t2 , hRow
				set HeadRows = new collection
				HeadRowCount = 1
				for i = 0 to rs.fields.count-1
					HeadRowCount = 1
					t = rs.fields(i).name
					if instr(t,"{") >0 then
						t1 = split(t,"{")(0)
					else
						t1 = t
					end if
					t2 = split(t1,"_")
					hRow = ubound(t2)+1
					t2 = split(t1,"_")
					if HeadRowCount < hRow then  HeadRowCount = hRow
					call HeadRows.add(t2)
				next
			end sub
			private function ColSpan(RowIndex , colIndex)
				dim i , ii , currText , Span
				Span = 1
				currText = HeadRows.items(colIndex)(RowIndex)
				for i = colIndex+1 to HeadRows.count
					currText = HeadRows.items(colIndex)(RowIndex)
					if  ubound(HeadRows.items(i)) >= RowIndex then
						if trim(HeadRows.items(i)(Rowindex)) = trim(currText) then
							Span = Span + 1
'if trim(HeadRows.items(i)(Rowindex)) = trim(currText) then
						else
							exit for
						end if
					else
						exit for
					end if
				next
				ColSpan = Span
			end function
			Private Function cFieldStr(Byval v)
				v = replace(v,"""","&quot;")
				v = Replace(v,vbcr,"&#13;")
				v = Replace(v,vblf,"&#10;")
				v = Replace(v,"<","&#60;")
				v = Replace(v,">","&#62;")
				cFieldStr = v
			end function
			public sub CreateDataTable
				dim sql, col , cols ,  colUbound , i , ii , HeadCount , c1 , hsTR , currText,item,rss
				dim w
				productlinkpower = (cn.execute("select qx_open from power where sort1=21 and sort2=14 and ord=" & app.Info.user & " and qx_open=1").eof = false)
				redim col(rs.fields.count-1)
				redim att(rs.fields.count-1)
				colUbound  =  rs.fields.count-1
				for I = 0 to rs.fields.count - 1
					set col(i) =  rs.fields(i)
					set att(i) = new AttrClass
					call att(i).read(col(i).name)
					cols  = cols & "[" & col(i).name & "]"
					set rss = cn.execute("exec  erp_report_getColAttr " & me.id & "," & app.info.user & ",'" &  replace(col(i).name,"'","''") & "'" )
					if not rss.eof then
						with att(i)
						.display = rss.fields("display").value
						.width = rss.fields("width").value
						.align = rss.fields("align").value
						.color = rss.fields("color").value
						.backcolor = rss.fields("backcolor").value
						if len(.width & "") = 0 then
							w = w + 50 + len(col(i).name)*5
'if len(.width & "") = 0 then
						else
							w = w + replace(.width & "","px","")
'if len(.width & "") = 0 then
						end if
						end with
					else
						att(i).width = "70px"
						w = w + 50 + len(col(i).name)*5
						att(i).width = "70px"
					end if
					rss.close
				next
				Call CHead
				Response.write "<form action='report.asp?id="&request("id")&"' method='post' target='callbackframe' id='rpt_into_frm' style='display:inline;position:absolute;top:-1px'>"
'Call CHead
				Response.write "<input type='hidden' name='__msgid' id='__msgId' value=''>"
				Response.write "<input type='hidden' name='rpt_info_cols'  id='rpt_info_cols' value='" & replace(cols,"'","&dyh") & "'>"
				Response.write "<input type='hidden' name='rpt_info_recordCount' id='rpt_info_recordCount' value='" & me.recordcount & "'>"
				Response.write "<input type='hidden' name='rpt_info_PageCount' id='rpt_info_PageCount' value='" & me.pagecount & "'>"
				Response.write "<input type='hidden' name='rpt_info_PageIndex' id='rpt_info_PageIndex' value='" & me.pageindex & "'>"
				Response.write "<input type='hidden' name='rpt_info_GroupID' id='rpt_info_GroupID' value='" & me.groupid & "'>"
				Response.write "<input type='hidden' name='rpt_info_title' id='rpt_info_title' value=""" &  cFieldStr(me.title) & """>"
				Response.write "<input type='hidden' name='rpt_info_newfilterText' id='rpt_info_newfilterText' value=""" & cFieldStr(me.newfilterText) & """>"
				Response.write "<input type='hidden' name='rpt_info_basefilterText' id='rpt_info_basefilterText' value=""" & cFieldStr(me.basefilterText) & """>"
				Response.write "<input type='hidden' name='rpt_info_header' id='rpt_info_header' value=""" & cFieldStr(me.header) & """>"
				Response.write "<input type='hidden' name='rpt_info_footer' id='rpt_info_footer' value=""" & cFieldStr(me.footer) & """>"
				Response.write "<input type='hidden' name='ReportId' id='ReportId' value=""" & me.id & """>"
				for I = 1 to me.fields.count
					set item = me.fields.items(i)
					Response.write "<input type='hidden' name='rpt_info_fld_" & replace(item.varname,"@","") & "' id='rpt_info_fld_" &  replace(item.varname,"@","") & "' value=""" & cFieldStr(item.value) & """>"
				next
				Response.write "</form>"
				Response.write "<table id=""datatable"" align=""left""  style='table-layout:fixed;width:" & app.iif(w < 800, "800" & "px" , w & "px") & "'>"
				Response.write "</form>"
				Response.write "<tr class='Head" & HeadRowCount & "'>"
				currText = "%%$#@"
				if mHasIndex = 1 then Response.write "<th rowspan=" & HeadRowCount & " style='width:40px' onmousemove='relshmove(this)'>序号</th>"
				for i = 0 to HeadRowCount-1
					hsTR = (i = 0)
					for ii = 1 to colUbound + 1
						hsTR = (i = 0)
						c1 = HeadRows.items(ii)
						if ubound(c1) >= i then
							if  c1(i) <> currText then
								if not hsTR then Response.write "<tr class='Head" & HeadRowCount & "'>" & vbcrlf : hsTR = true
								cspan =  ColSpan(i,ii)
								cspanHTML = app.iif(cspan > 1 , "colspan=" & cspan , "")
								for iii = 1 to  cspan - 1
									cspanHTML = app.iif(cspan > 1 , "colspan=" & cspan , "")
									att(ii-1).width = att(ii-1).width + att(ii-1 + iii).width
									cspanHTML = app.iif(cspan > 1 , "colspan=" & cspan , "")
								next
								if i <  ubound(c1) then
									Response.write "<th " & att(ii-1).styleHTML(1) & "  onmousemove='relshmove(this)' " & cspanHTML & " >" & c1(i) & "</th>"
'if i <  ubound(c1) then
								else
									Response.write "<th " & att(ii-1).styleHTML(1) & "  onmousemove='relshmove(this)' " & cspanHTML & " rowspan='" & (HeadRowCount - i)  & "'>" & c1(i) & "</th>"
'if i <  ubound(c1) then
								end if
								currText = c1(i)
							end if
						end if
					next
					Response.write "</tr>"
				next
				ii = 0
				do while(not rs.eof)
					ii = ii + 1
'do while(not rs.eof)
					if (ii > mPageSize*(mPageIndex-1) and II <= mPageSize*(mPageIndex)) Or ExcelMode = True  then
'do while(not rs.eof)
						Response.write "<tr class='DR" & (ii mod 2) & "'>"
						if mHasIndex = 1 then Response.write "<td class=indexdcell>" & ii & "</td>"
						for i = 0 to colubound
							Response.write "<td class=dcell " & att(i).styleHTML(0) & ">" & replace(replace(GetLink(col(i).value) & "",chr(0),""),"@user",app.info.user) & "</td>"
						next
						Response.write "</tr>"
					end if
					rs.movenext
				loop
				rs.close
				Response.write "</table>"
			end sub
			public sub creategrouplist
				dim rs , i
				set rs  = cn.execute("select id,title,isnull(GroupCreator,0) as  creator from M_ReportConfig where Parent=" & me.id & " and (isnull(GroupCreator,0)=0 or isnull(GroupCreator,0)=" & app.info.user & ") order by ID")
				if rs.eof then
					Response.write "<option value='0'>==无==</option>"
				end if
				while not rs.eof
					Response.write "<option value='" & rs.fields("ID").value & "' style='color:" & app.iif(rs.fields("creator").value=0,"#006600","#666") & "'>" & rs.fields("title").value & "</option>"
					rs.movenext
				wend
				rs.close
			end sub
			Function GetLink(v)
				Dim arr
				If excelmode = false then
					If InStr(1,v,"<span link_",1) = 1 Then
						If productlinkpower And InStr(1,v,"<span link_p",1) = 1 Then
							arr = Replace(Replace(Split(v, ">")(0), "<span link_p=""",""),"""","")
							GetLink = "<a href='../../product/content.asp?ord=" & app.base64.pwurl(arr) & "' target='_blank'>" & v & "</a>"
							Exit function
						end if
					end if
				end if
				GetLink = v
			end function
		end class
		sub App_DataListCallBack
			set rpt = new ReportClass
			rpt.CreateDataTable
			set rpt = nothing
		end sub
		sub page_init
			app.autohead = false
		end sub
		Sub page_load
			dim rpt , i , firstover , endover
			set rpt = new ReportClass
			if rpt.id = 0 then
				exit sub
			end if
			if rpt.pageindex = 1 then firstover = "disabled"
			if rpt.pageindex = rpt.pagecount then endover = "disabled"
			Response.write "" & vbcrlf & "<!doctype html>" & vbcrlf & "<html>" & vbcrlf & "<head>" & vbcrlf & "   <meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">" & vbcrlf & " <meta http-equiv=""X-UA-Compatible"" content=""IE=EmulateIE7"" />" & vbcrlf & "       <title>"
'if rpt.pageindex = rpt.pagecount then endover = "disabled"
			Response.write app.info.title
			Response.write "</title>" & vbcrlf & "      <link href=""report.css?ver="
			Response.write Application("sys.info.jsver")
			Response.write """ rel=""stylesheet"" type=""text/css""/>" & vbcrlf & "   <script language=javascript src='../../inc/jQuery-1.6.2.min.js?ver="
			'Response.write Application("sys.info.jsver")
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <script language=javascript src='base.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <script language=javascript src='TabControl.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <style>" & vbcrlf & "         .ssTabItem_select, ssTabItem {float:left}" & vbcrlf & "               table.TabCtl {width:300px}" & vbcrlf & "      </style>" & vbcrlf & "</head>" & vbcrlf & "<body style='margin:0px;padding:0px;position:absolute;top:0px;left:0px;'>" & vbcrlf & "        <script language=javascript src='dateCalender.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <script language=javascript src='listview.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <script language=javascript src='report.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <div style='height:91px'></div>" & vbcrlf & " <div class='fixDiv'>" & vbcrlf & "    <div id='header'>" & vbcrlf & "               <div style='float:right;'>" & vbcrlf & "                              <div id=""report_tool_left"" style='clear:both;width:150px;padding-top:5px;display:none'>" & vbcrlf & "                           <input type='radio' checked id='md1' onclick='Tabs.ItemClick(0)' name='rptmode'><label for=md1>数据</label>&nbsp;<input type='radio' name='rptmode' id='md2'  onclick='Tabs.ItemClick(1)'><label for=md2>统计</label>" & vbcrlf & "                           </div>" & vbcrlf & "          </div>" & vbcrlf & "          <div id='headertext'>统计分析</div>"& vbcrlf & "       </div>" & vbcrlf & "  <input type=""hidden"" name=""ReportID"" value="""
			Response.write rpt.ID
			Response.write """>" & vbcrlf & " <div id='toolbar' style=""padding-top:5px;padding-bottom:5px;"">" & vbcrlf & "            <div style='width:100%;height:2px;overflow:hidden'></div>" & vbcrlf & "               <div id='toolitems1'>" & vbcrlf & "                   <div style='float:right;width:auto;padding-right:4px'>" & vbcrlf & "                          <div style='float:left;width:65px;height:22px;cursor:default;overflow:hidden'>" & vbcrlf & "                                    <span style='font-familiy:arial;*top: 6px;*position: relative;'>共<b style='color:red' id='jlCount'>"
			Response.write rpt.ID
			Response.write rpt.recordcount
			Response.write "</b>条记录</span>" & vbcrlf & "                             </div>" & vbcrlf & "                          <div class='toolitem' id='firstpage' title='首页' onmouseover='tm(this)' onmouseout='tu(this)' "
			Response.write firstover
			Response.write "><div><img src='../../images/smico/pg5"
			Response.write firstover
			Response.write ".gif' style=""*position:relative;*top:3px;""></div></div>" & vbcrlf & "                         <div class='toolitem' id='prepage' title='上一页' onmouseover='tm(this)' onmouseout='tu(this)' "
			Response.write firstover
			Response.write "><div><img src='../../images/smico/pg3"
			Response.write firstover
			Response.write ".gif' style=""*position:relative;*top:3px;""></div></div>" & vbcrlf & "                         <div style='float:left;width:92px;height:22px;cursor:default;overflow:hidden' title='页面数据行数' >" & vbcrlf & "                                    <div><span style='width:90px;*top: 1px; *position: relative;'>第</span><select style='width:40px;margin:0px5px;height:18px;*top:3px; *position: relative;' id='PageIndex' onchange='UpdateList()'>" & vbcrlf & "                                             "
			for i = 1 to rpt.pagecount
				Response.write "<option value=" & i & " " & app.iif(rpt.PageIndex=i,"selected","") & ">" & i & "</option>"
			next
			Response.write "" & vbcrlf & "                                              </select><span style=""*top: 1px; *position: relative;"">页</span>" & vbcrlf & "                                  </div>" & vbcrlf & "                          </div>" & vbcrlf & "                          <div class='toolitem' id='nextpage' title='下一页' onmouseover='tm(this)' onmouseout='tu(this)' "
			Response.write endover
			Response.write "><div><img src='../../images/smico/pg2"
			Response.write endover
			Response.write ".gif' style=""*position:relative;*top:3px;""></div></div>" & vbcrlf & "                         <div class='toolitem' id='lastpage' title='尾页' onmouseover='tm(this)' onmouseout='tu(this)'  "
			Response.write endover
			Response.write "><div><img src='../../images/smico/pg4"
			Response.write endover
			Response.write ".gif' style=""*position:relative;*top:3px;""></div></div>" & vbcrlf & "                         <div style='float:left;width:112px;height:22px;cursor:default;overflow:hidden' title='页面数据行数' >" & vbcrlf & "                                   <div style='width:120px;*top:3px; *position: relative;'><span>每页行数:</span><select style='width:50px;height:18px; style=""*position:relative;*top:3px;""' id='PageSize' onchange='UpdateList()'>" & vbcrlf & "                                           "
			dim RowArray  , hIndex
			RowArray = split("10,12,20,30,40,50,60,80,100,120,150,200,300",",")
			hIndex = false
			for I = 0 to ubound(RowArray)
				if RowArray(i)*1 = rpt.PageSize*1 then
					hIndex = true
					Response.write "<option value=" & RowArray(i) & " selected>" & RowArray(i) & "</option>"
				else
					Response.write "<option value=" & RowArray(i) & ">" & RowArray(i) & "</option>"
				end if
			next
			if not hIndex  and rpt.PageSize > 0 then
				Response.write "<option value=-1 selected>全部</option>"
'if not hIndex  and rpt.PageSize > 0 then
			else
				Response.write "<option value=-1>全部</option>"
'if not hIndex  and rpt.PageSize > 0 then
			end if
			Response.write "" & vbcrlf & "                                              </select>" & vbcrlf & "                                       </div>" & vbcrlf & "                          </div>" & vbcrlf & "                          <div class='toolitemspace'></div>" & vbcrlf & "                               <div class='toolitemspliter'></div>" & vbcrlf & "                             <div class='toolitemspace'></div>" & vbcrlf & "                               <div class='toolitem' id='sxbutton' title='数据筛选' onmouseover='tm(this)' onmouseout='tu(this)'><div><img src='../../images/smico/filter.gif'></div></div>" & vbcrlf & "                            <div class='toolitemspace'></div>" & vbcrlf & "                               <div class='toolitem' title='导出excel' id='cexcel' onmouseover='tm(this)' onmouseout='tu(this)'><div><img src='../../images/smico/excel.gif'></div></div>" & vbcrlf & "                               <!-- <div class='toolitemspace'></div>" & vbcrlf & "                          <div class='toolitem' id='msbutton' title='报表模式' onmouseover='tm(this)' onmouseout='tu(this)'><div><img src='../../images/smico/Q2.gif'></div></div> -->"
'if not hIndex  and rpt.PageSize > 0 then
			if app.IsAdmin And false then
				Response.write "<div class='toolitemspace'></div><div class=toolitem title='配置统计报表' id='tjconfig'  onmouseover='tm(this)' onmouseout='tu(this)'><div><img src='../../images/smico/50.gif'></div></div>"
			end if
			Response.write "" & vbcrlf & "                     </div>" & vbcrlf & "                  <div class=""spliterdiv""><img src='../../images/smico/spliter.gif'></div>" & vbcrlf & "                  <div style='margin-top:5px'>&nbsp;"
			Response.write rpt.cls
			Response.write " >> "
			Response.write rpt.title
			Response.write "</div>" & vbcrlf & "                  </div>" & vbcrlf & "       </div>" & vbcrlf & "  <div id='FieldArea'>" & vbcrlf & "            <div style='float:right;overflow:hidden;display:none' id='groupPanel'>" & vbcrlf & "                  <div style='float:left'>统计汇总：<select id='GroupID' onchange='GroupChange(this.value)'>"
			call rpt.creategrouplist()
			Response.write "</select></div>&nbsp;" & vbcrlf & "                        <button class=button style='width:40px;height:19px;line-height:18px'>配置</button>&nbsp;" & vbcrlf & "                </div>" & vbcrlf & "          <span><img style='vertical-align:middle' src='../../images/smico/spliter.gif'></span>" & vbcrlf & "           "
'call rpt.creategrouplist()
			dim item
			for I = 1 to rpt.fields.count
				set item = rpt.fields.items(i)
				Response.write "<span class=""fldItemdiv"">"
				Response.write "<span class='flditemcell'>" + rpt.fields.items(i).ywname + "：</span>"
				Response.write "<span class=""fldItemdiv"">"
				Response.write "<span class='flditemcell' style='background-color:white;white-space:nowrap'>"
				Response.write "<span class=""fldItemdiv"">"
				select case item.dtype
				case "date"
				Response.write "<input style='width:65px;height:16px'onkeydown='if(event.keyCode==13)UpdateField(this);' readonly onchange='UpdateField(this)' type=text class=text value='" & item.value & "' id='f_" & replace(item.varname,"@","") & "'><button class=datesel onfocus='this.blur()' style='height:20px;top:2px;*top:-1px' onclick='datedlg.show();'><img src='../../images/datePicker.gif'></button>"
'case "date"
				case else
				Response.write "<input style='height:16px;border-right:1px solid #ccccee' onkeydown='if(event.keyCode==13)UpdateField(this);'onchange='UpdateField(this)' type=text class=text value='" & item.value & "' id='f_" & replace(item.varname,"@","") & "'>"
'case else
				end select
				Response.write "</span>"
				Response.write "<span class='flditemcell'></span>"
				Response.write "</span>"
				if i <  rpt.fields.count then
					Response.write "&nbsp;<span class='flditemsplit'>&nbsp;</span>"
				end if
			next
			Response.write "" & vbcrlf & "     </div>" & vbcrlf & "  </div>" & vbcrlf & "  <div id='PageBody' class='listmodel'>" & vbcrlf & "           <div style='height:15px;overflow:hidden' class='spaceline'></div>" & vbcrlf & "               <div id='PageTitle'><span id='PageTitleSpan'>"
			Response.write rpt.title
			Response.write "</span></div>" & vbcrlf & "                <div style='height:5px' class='spaceline'></div>" & vbcrlf & "                <div id='PageHeader'>"
			Response.write rpt.header
			Response.write "</div>" & vbcrlf & "               <div style='height:5px' class='spaceline'></div>" & vbcrlf & "                <div id='PageTable'>"
			call Rpt.CreateDataTable()
			Response.write "</div>" & vbcrlf & "               <div style='height:10px' class='spaceline'></div>" & vbcrlf & "               <div id='PageFooter'>"
			Response.write rpt.footer
			Response.write "</div>" & vbcrlf & "       </div>" & vbcrlf & "" & vbcrlf & "  <iframe name='callbackframe' style='width:1px;height:1px;position:absolute;top:-200px;left:-100px'></iframe>" & vbcrlf & "    <div style='display:none;position:absolute;left:40%;width:20%;top:240px;border:1px solid #eeeeff;background:#fefeff;padding:20px;filter:alpha(opacity=85)' id='xxx_proc'>" & vbcrlf & "      <img src='../../images/smico/proc.gif' style='width:20px'> <span style='position:relative;top:-5px;color:red'>正在加载 ...</span>" & vbcrlf & "       </div>" & vbcrlf & "</body>" & vbcrlf & "</html>"
			Response.write rpt.footer
			set rpt = nothing
		end sub
		Sub App_CExcel
			dim rs , ID , title
			Response.Charset= "UTF-8"
'dim rs , ID , title
			id = abs(request.form("reportID"))
			set rs =  cn.execute("select * from M_reportconfig where ID=" & id)
			if rs.eof  then
				Response.write "<script>alert(""参数不正确,报表ID值无效"")</script>"
				rs.close
				exit sub
			else
				title = rs.fields("title").value
			end if
			rs.close
			Call Response.AddHeader("content-type","application/msexcel")
			'title = rs.fields("title").value
			Call Response.AddHeader("Content-Disposition","attachment;filename=" & title & ".xls")
			'title = rs.fields("title").value
			Call Response.AddHeader("Pragma","No-Cache")
			'title = rs.fields("title").value
			Response.write "<html xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns=""http://www.w3.org/TR/REC-html40"">" & vbcrlf & "          <head>" & vbcrlf & "                  <meta http-equiv=Content-Type content=""text/html; charset=UTF-8"">" & vbcrlf & "                 <meta name=ProgId content=""Excel.Sheet"">" & vbcrlf & "                  <meta name=Generator content=""Microsoft Excel 11"">" & vbcrlf & "                        <title>系统导出的数据</title>" & vbcrlf & "" & vbcrlf & "                   <style>" & vbcrlf & "                         table{" & vbcrlf & "                                  border-collapse:collapse;" & vbcrlf & "                               }" & vbcrlf & "                               #datatable{" & vbcrlf & "             border:1px solid #000;" & vbcrlf & "                          }" & vbcrlf & "                               .Head2 th, .Head1 th{" & vbcrlf & "                                   padding-top:1px;" & vbcrlf & "                                        padding-right:3px;" & vbcrlf & "                                      padding-left:3px;" & vbcrlf & "                                       mso-ignore:padding;" & vbcrlf & "                                     color:windowtext;" & vbcrlf & "                                       font-size:12px;"& vbcrlf & "                                      font-weight:bold;" & vbcrlf & "                                       font-style:normal;" & vbcrlf & "                                      text-decoration:none;" & vbcrlf & "                                   font-family:宋体;" & vbcrlf & "                                       mso-generic-font-family:auto;" & vbcrlf & "                                   mso-font-charset:134;" & vbcrlf & "                                   mso-number-format:General;" & vbcrlf & "                                      text-align:general;" & vbcrlf & "                                   vertical-align:bottom;" & vbcrlf & "                                  border:.5pt solid windowtext;" & vbcrlf & "                                   mso-background-source:auto;" & vbcrlf & "                                     mso-pattern:auto;" & vbcrlf & "                                       white-space:nowrap;" & vbcrlf & "                                     height:22px;" & vbcrlf & "                                    text-align:center;" & vbcrlf & "                           }" & vbcrlf & "                               td.indexdcell, td.dcell{" & vbcrlf & "                                        padding-top:1px;" & vbcrlf & "                                        padding-right:3px;" & vbcrlf & "                                      padding-left:3px;" & vbcrlf & "                                       mso-ignore:padding;" & vbcrlf & "                                     color:windowtext;" & vbcrlf & "                                       font-size:12px;" & vbcrlf & "                                 font-style:normal;" & vbcrlf & "                                    text-decoration:none;" & vbcrlf & "                                   font-family:宋体;" & vbcrlf & "                                       mso-generic-font-family:auto;" & vbcrlf & "                                   mso-font-charset:134;" & vbcrlf & "                                   mso-number-format:""\@"";" & vbcrlf & "                                   text-align:general;" & vbcrlf & "                                     vertical-align:bottom;" & vbcrlf & "                                    border:.5pt solid windowtext;" & vbcrlf & "                                   mso-background-source:auto;" & vbcrlf & "                                     mso-pattern:auto;" & vbcrlf & "                                       white-space:nowrap;" & vbcrlf & "                                     height:22px;" & vbcrlf & "                            }" & vbcrlf & "                       </style>" & vbcrlf & "                        <!--[if gte mso 9]><xml>" & vbcrlf & "                         <x:ExcelWorkbook>" & vbcrlf & "                          <x:ExcelWorksheets>" & vbcrlf & "                      <x:ExcelWorksheet>" & vbcrlf & "                           <x:Name>"
			Response.write title
			Response.write "</x:Name>" & vbcrlf & "                            <x:WorksheetOptions>" & vbcrlf & "                             <x:DefaultRowHeight>285</x:DefaultRowHeight>" & vbcrlf & "                            <x:CodeName>Sheet1</x:CodeName>" & vbcrlf & "                                 <x:Selected/>" & vbcrlf & "                          </x:WorksheetOptions>" & vbcrlf & "                      </x:ExcelWorksheet>" & vbcrlf & "                    </x:ExcelWorksheets>" & vbcrlf & "                      </x:ExcelWorkbook>" & vbcrlf & "                     </xml><![endif]-->" & vbcrlf & "              </head>" & vbcrlf & "         <body>" & vbcrlf & "          <center style='font-size:18px'>"
			'Response.write title
			Response.write title
			Response.write "</center>" & vbcrlf & "    "
			set rpt = new ReportClass
			rpt.ExcelMode=True
			rpt.CreateDataTable
			set rpt = nothing
			Response.write "" & vbcrlf & "             </body>" & vbcrlf & "         </html>" & vbcrlf & " "
		end sub
		sub App_showconfig
			if request.form("key") = "zbintel" & day(now) then
				session("configcode") = "1"
				app.print "OpenConfig('ReportConfig.asp');"
			end if
		end sub
		
%>
