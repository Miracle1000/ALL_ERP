<%@ language=VBScript %>
<%
	Response.Buffer = True
	Dim StarTime, EndTime
	Dim Conn, DBPath, DB, ConnStr, MyRootPath, QQWryPath
	Dim SqlNowString
	Const IsDeBug = 1
	Const ServerObject_001 = "ADODB.Connection"
	Const ServerObject_002 = "ADODB.RecordSet"
	Const ServerObject_003 = "ADODB.Stream"
	Const ServerObject_004 = "Scripting.Dictionary"
	Const ServerObject_005 = "Scripting.FileSystemObject"
	Const ServerObject_006 = "JMail.Message"
	Const ServerObject_007 = "CDONTS.NewMail"
	Const ServerObject_008 = "Persits.MailSender"
	Const ServerObject_009 = "CDO.Message"
	Const ServerObject_010 = "CDO.Configuration"
	Const ServerObject_011 = "Persits.Upload"
	Const ServerObject_012 = "Persits.UploadProgress"
	Const ServerObject_013 = "SoftArtisans.FileUp"
	Const ServerObject_014 = "DvFile.Upload"
	Const ServerObject_015 = "CreatePreviewImage.cGvbox"
	Const ServerObject_016 = "Persits.Jpeg"
	Const ServerObject_017 = "SoftArtisans.ImageGen"
	Const ServerObject_018 = "MSXML2.XMLHTTP"
	Const ServerObject_019 = "JRO.JetEngIne"
	StarTime = Timer()
	MyRootPath = ""
	Const IsSqlDataBase = 1
	If IsSqlDataBase = 1 Then
		Const SqlDatabaseName        = "xiangmu"
		Const SqlUsername            = "sa"
		Const SqlPassword            = "zbintel"
		Const SqlLocalName           = "(local)"
		SqlNowString = "GetDate()"
	else
		DBPath = "../lst/"
		DB = DBPath & "#df9l er43d.mdb"
		SqlNowString = "Now()"
	end if
	Function ConnectionDatabase()
		on error resume next
		If IsSqlDataBase = 1 Then
			ConnStr = "Provider = Sqloledb; User ID = " & SqlUsername & "; Password = " & SqlPassword & "; Initial Catalog = " & SqlDatabaseName & "; Data Source = " & SqlLocalName & ";"
		else
			ConnStr = "Provider = Microsoft.Jet.OLEDB.4.0;Data Source = " & Server.MapPath(MyRootPath & DB)
		end if
		Set Conn = Server.CreateObject(ServerObject_001)
		Conn.Open ConnStr
		If Err Then
			Err.Clear
			Set Conn = Nothing
			Response.write("数据库连接错误，请检查连接字符串。")
			Response.end()
		end if
	end function
	Function CloseDB()
		Conn.Close
		Set Conn = Nothing
	end function
	Dim iXs
	Set iXs = New iXuEr_Core
	Class iXuEr_Core
		Public UpFileObject
		Private Sub Class_Initialize
			UpFileObject         = 0 ' UpFileObject = 1
		end sub
		Public Function Execute(Command)
			If Not IsObject(Conn) Then ConnectionDatabase()
			on error resume next
			Set Execute = Conn.Execute(Command)
			If Err Then
				If IsDeBug = 0 Then
					Response.write("刚才执行的查询出现错误,请认真检查您的语句。")
				else
					Response.write("查询语句为：" & Command & "<br>")
					Response.write("错误信息为：" & Err.Description & "<br>")
				end if
				Err.Clear
				Set Execute = Nothing
				Response.end()
			end if
		end function
		Public Function GetRs(Command, Num1, Num2)
			on error resume next
			If Not IsObject(Conn) Then ConnectionDatabase()
			Set GetRs = Server.CreateObject(ServerObject_002)
			GetRs.Open Command, Conn, Num1, Num2
			If Err Then
				If IsDeBug = 0 Then
					Response.write("创建 Recordset 对象失败,请认真检查您的语句。")
				else
					Response.write("查询语句为：" & Command & "<br>")
					Response.write("错误信息为：" & Err.Description & "<br>")
				end if
				Err.Clear
				Response.end
			end if
		end function
		Public Function ReqNum(StrName, DefaultValue)
			ReqNum = Trim(Request(StrName))
			If ReqNum <> "" And Not IsNull(ReqNum) Then
				If Not IsNumeric(ReqNum) Then
					Response.write("参数  " & StrName & "  必须为数字！\n\n请重新输入！")
				else
					ReqNum = CLng(ReqNum)
				end if
			else
				ReqNum = DefaultValue
			end if
		end function
		Public Function ReqStr(StrName, DefaultValue)
			Dim Str, i
			For i = 1 To Request(StrName).Count
				Str = Str & Request(StrName)(i)
			next
			Str = Replace(Trim(Request(StrName)), Chr(0), "")
			Str = Replace(Str, "'", "''")
			If Str = "" Or IsNull(Str) Then Str = DefaultValue
			ReqStr = Str
		end function
		Public Sub Redirect(Url, p_Time)
			on error resume next
			If Url = "" Or IsNull(Url) Then Exit Sub
			If p_Time = 0 Then Response.redirect(Url)
			Response.write("<script language=""javascript1.2"">window.setTimeout(""location.href='" & Url & "';"", " & p_Time & ");</script>")
		end sub
		Public Property Get ReqIP()
		ReqIP = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
		If ReqIP = "" Or IsNull(ReqIP) Then ReqIP = Request.ServerVariables("REMOTE_ADDR")
		If InStr(ReqIP, ",") Then ReqIP = Split(ReqIP, ",")(0)
		ReqIP = CStr(ReqIP)
		End Property
		Public Function ReFilter(p_Patrn, p_Str, p_Type, ReplaceWith)
			Dim RegEx
			Set RegEx = New RegExp
			If p_Type = 1 Then
				RegEx.Global = True
			else
				RegEx.Global = False
			end if
			RegEx.Pattern = p_Patrn
			RegEx.IgnoreCase = True
			ReFilter = RegEx.Replace(p_Str, ReplaceWith)
		end function
		Public Function ReSearch(p_Patrn, p_Str, p_Type, Spacer)
			Dim RegEx, Match, Matches , RetStr, i
			i = 0
			Set RegEx = New RegExp
			RegEx.Pattern = p_Patrn
			RegEx.IgnoreCase = True
			RegEx.Global = True
			Set Matches = RegEx.Execute(p_Str)
			For Each Match In Matches
				i = i + 1
'For Each Match In Matches
				If p_Type = 0 Then
					RetStr = RetStr & Match.Value
					If i < Matches.Count Then RetStr = RetStr & Spacer
				else
					RetStr = RetStr & Match.Value
					If i < Matches.Count Then RetStr = RetStr & Spacer
					If p_Type = i Then Exit For
				end if
			next
			ReSearch = RetStr
		end function
	End Class
	
	If Session("personzbintel2007") & "" =  "" Then Response.end
	Class iXs_ClsUp
		Private p_MaxSize, p_TotalSize, p_FileType, p_SavePath, p_AutoSave, p_Error
		Private ObjForm, BinForm, BinItem, LngTime
		Public        FormItem, FileItem, StrDate, p_UpLoadPID
		Public Property Get Version
		Version = "智邦国际"
		End Property
		Public Property Get Error
		Error = p_Error
		End Property
		Public Property Get MaxSize
		MaxSize = p_MaxSize
		End Property
		Public Property Let MaxSize(LngSize)
		If IsNumeric(LngSize) Then
			p_MaxSize = Clng(LngSize)
		end if
		End Property
		Public Property Get TotalSize
		TotalSize = p_TotalSize
		End Property
		Public Property Let TotalSize(LngSize)
		If IsNumeric(LngSize) Then
			p_TotalSize = Clng(LngSize)
		end if
		End Property
		Public Property Get FileType
		FileType = p_FileType
		End Property
		Public Property Let FileType(strType)
		p_FileType = strType
		End Property
		Public Property Get SavePath
		SavePath = p_SavePath
		End Property
		Public Property Let SavePath(StrPath)
		p_SavePath = Replace(StrPath, chr(0), "")
		End Property
		Public Property Get AutoSave
		AutoSave = p_AutoSave
		End Property
		Public Property Let UpLoadPID(PID)
		p_UpLoadPID = PID
		End Property
		Public Property Get UpLoadPID()
		UpLoadPID = p_UpLoadPID
		End Property
		Public Property Let AutoSave(byVal Flag)
		Select Case Flag
		Case 0
		Case 1
		Case 2
		Case False Flag = 2
		Case Else Flag = 0
		End Select
		p_AutoSave = Flag
		End Property
		Private Sub Class_Initialize
			p_Error          = -1
'Private Sub Class_Initialize
			p_MaxSize   = 1536000
			p_FileType  = "gif/jpg/jpeg/bmp/png/rar/txt/zip/mid"
			p_SavePath  = "UploadFile/"
			p_AutoSave  = 0
			p_TotalSize = 536870912
			StrDate          = FormatTime(Now(), 1)
			Randomize Timer()
			LngTime          = Clng(10000 + Rnd() * 89999)
			Randomize Timer()
			p_UpLoadPID = StrDate & LngTime
			Set BinForm = Server.CreateObject(ServerObject_003)
			Set BinItem = Server.CreateObject(ServerObject_003)
			Set ObjForm = Server.CreateObject(ServerObject_004)
			ObjForm.CompareMode = 1
		end sub
		Private Sub Class_Terminate
			on error resume next
			ObjForm.RemoveAll
			Set ObjForm = Nothing
			Set BinItem = Nothing
			If p_Error <> 4 Then BinForm.Close()
			Set BinForm = Nothing
		end sub
		Public Sub Open()
			If p_Error = -1 Then
'Public Sub Open()
				p_Error = 0
			else
				Exit Sub
			end if
			Dim LngRequestSize, LngReadSize, BinRequestData, StrFormItem, StrFileItem ,p_ChunkByte, IntTemp, StrTemp
			Const StrSplit = "'"">"
			LngRequestSize = Request.TotalBytes
			If (LngRequestSize < 1) Or ((LngRequestSize > p_TotalSize) And p_TotalSize <> 0) Then
				p_Error = 4
				Exit Sub
			end if
			BinForm.Type = 1
			BinForm.Open
			LngReadSize = 0
			p_ChunkByte = 102400
			BinItem.Type = 2
			BinItem.Charset = "UTF-8"
			BinItem.Type = 2
			BinItem.Open
			Response.Flush()
			Do
				on error resume next
				BinForm.Write Request.BinaryRead(p_ChunkByte)
				LngReadSize = LngReadSize + p_ChunkByte
				BinForm.Write Request.BinaryRead(p_ChunkByte)
				If  LngReadSize >= LngRequestSize Then Exit Do
				BinItem.WriteText "lngTotalSize=" & LngRequestSize & ";lngReadSize=" & LngReadSize & ";"
				BinItem.SaveToFile Server.MapPath("UpLoadData/" & p_UpLoadPID & ".js"), 2
				Response.flush()
			Loop
			BinItem.WriteText "lngTotalSize=" & LngRequestSize & ";lngReadSize=" & LngReadSize & ";"
			BinItem.SaveToFile Server.MapPath("UpLoadData/" & p_UpLoadPID & ".js"), 2
			BinItem.Close()
			Response.Flush()
			BinForm.Position = 0
			BinRequestData = BinForm.Read()
			Dim bCrLf, StrSeparator, IntSeparator
			bCrLf = ChrB(13) & ChrB(10)
			IntSeparator = InStrB(1, BinRequestData, bCrLf)-1
			bCrLf = ChrB(13) & ChrB(10)
			StrSeparator = LeftB(BinRequestData, IntSeparator)
			Dim p_Start, p_End, StrItem, StrInam
			Dim StrFtyp, StrFnam, StrFext, LngFsiz
			p_Start = IntSeparator + 2
'Dim StrFtyp, StrFnam, StrFext, LngFsiz
			Do
				p_End  = InStrB(p_Start, BinRequestData, bCrLf & bCrLf) + 3
'Do
				BinItem.Type=1
				BinItem.Open
				BinForm.Position = p_Start
				BinForm.CopyTo BinItem, p_End - p_Start
				BinForm.Position = p_Start
				BinItem.Position = 0
				BinItem.Type = 2
				BinItem.Charset = "UTF-8"
				BinItem.Type = 2
				StrItem = BinItem.ReadText
				BinItem.Close()
				p_Start = p_End
				p_End  = InStrB(p_Start, BinRequestData, StrSeparator)-1
				p_Start = p_End
				BinItem.Type = 1
				BinItem.Open
				BinForm.Position = p_Start
				LngFsiz = p_End-p_Start-2
				BinForm.Position = p_Start
				BinForm.CopyTo BinItem, LngFsiz
				IntTemp = InStr(39, StrItem, """")
				StrInam = Mid(StrItem, 39, IntTemp-39)
				IntTemp = InStr(39, StrItem, """")
				If InStr(IntTemp, StrItem, "filename=""") <> 0 Then
					If Not ObjForm.Exists(StrInam & "_From") Then
						StrFileItem = StrFileItem & StrSplit & StrInam
						If BinItem.Size <> 0 Then
							IntTemp = IntTemp + 13
'If BinItem.Size <> 0 Then
							StrFtyp = Mid(StrItem, InStr(IntTemp, StrItem, "Content-Type: ") + 14)
'If BinItem.Size <> 0 Then
							StrTemp = Mid(StrItem, IntTemp, InStr(IntTemp, StrItem, """") - IntTemp)
'If BinItem.Size <> 0 Then
							IntTemp = InStrRev(StrTemp, "\")
							StrFnam = Mid(StrTemp, IntTemp + 1)
							IntTemp = InStrRev(StrTemp, "\")
							ObjForm.Add StrInam & "_Type", Replace(StrFtyp, vbCrLF, "")
							ObjForm.Add StrInam & "_Name", StrFnam
							ObjForm.Add StrInam & "_Path", Left(StrTemp, IntTemp)
							ObjForm.Add StrInam & "_Size", LngFsiz
							If InStr(IntTemp, StrTemp, ".") <> 0 Then
								StrFext = Mid(StrTemp, InStrRev(StrTemp, ".") + 1)
'If InStr(IntTemp, StrTemp, ".") <> 0 Then
							else
								StrFext = ""
							end if
							If Left(StrFtyp, 6) = "image/" Then
								BinItem.Position = 0
								BinItem.Type = 1
								StrTemp = BinItem.Read(10)
								If InStr(StrFtyp, "jpeg") > 0 Then
									If LCase(StrFext) <> "jpg" Then StrFext = "jpg"
									BinItem.Position = 3
									Do While Not BinItem.EOS
										Do
											IntTemp = AscB(BinItem.Read(1))
											Loop While IntTemp = 255 And Not BinItem.EOS
											If IntTemp < 192 Or IntTemp > 195 Then
												BinItem.Read(Bin2Val(BinItem.Read(2))-2)
'If IntTemp < 192 Or IntTemp > 195 Then
											else
												Exit Do
											end if
											Do
												IntTemp = AscB(BinItem.Read(1))
												Loop While IntTemp < 255 And Not BinItem.EOS
											Loop
											BinItem.Read(3)
											ObjForm.Add StrInam & "_Height", Bin2Val(BinItem.Read(2))
											ObjForm.Add StrInam & "_Width", Bin2Val(BinItem.Read(2))
										ElseIf InStr(StrFtyp, "/png") > 0 Then
											If LCase(StrFext) <> "png" Then StrFext = "png"
											BinItem.Position = 18
											ObjForm.Add StrInam & "_Width", Bin2Val(BinItem.Read(2))
											BinItem.Read(2)
											ObjForm.Add StrInam & "_Height", Bin2Val(BinItem.Read(2))
										ElseIf InStr(StrFtyp, "/gif") > 0 Then
											If LCase(StrFext) <> "gif" Then StrFext = "gif"
											BinItem.Position = 6
											ObjForm.Add StrInam & "_Width", BinVal2(BinItem.Read(2))
											ObjForm.Add StrInam & "_Height", BinVal2(BinItem.Read(2))
										ElseIf InStr(StrFtyp, "/bmp") > 0 Then
											If LCase(StrFext) <> "bmp" Then StrFext = "bmp"
											BinItem.Position = 18
											ObjForm.Add StrInam & "_Width", BinVal2(BinItem.Read(4))
											ObjForm.Add StrInam & "_Height", BinVal2(BinItem.Read(4))
										else
											ObjForm.Add StrInam & "_Width", 200
											ObjForm.Add StrInam & "_Height", 150
										end if
									ElseIf InStr(StrFtyp, "shockwave-flash") > 0 Then
										ObjForm.Add StrInam & "_Height", 150
										If LCase(StrFext) <> "swf" Then StrFext = "swf"
										Dim BinData, sConv, nBits
										BinItem.Position = 0
										BinItem.Type = 1
										BinItem.Read(8)
										BinData = BinItem.Read(1)
										sConv = Num2Str(AscB(BinData), 2 ,8)
										nBits = Str2Num(Left(sConv, 5), 2)
										sConv = Mid(sConv, 6)
										While (Len(sConv) < nBits * 4)
											BinData = BinItem.Read(1)
											sConv = sConv & Num2Str(AscB(BinData), 2 ,8)
										wend
										ObjForm.Add StrInam & "_Width", Int(Abs(Str2Num(Mid(sConv, 1 * nBits + 1, nBits), 2) - Str2Num(Mid(sConv, 0 * nBits + 1, nBits), 2)) / 20)
										sConv = sConv & Num2Str(AscB(BinData), 2 ,8)
										ObjForm.Add StrInam & "_Height", Int(Abs(Str2Num(Mid(sConv, 3 * nBits + 1, nBits), 2) - Str2Num(Mid(sConv, 2 * nBits + 1, nBits), 2)) / 20)
										sConv = sConv & Num2Str(AscB(BinData), 2 ,8)
									else
										ObjForm.Add StrInam & "_Width", 0
										ObjForm.Add StrInam & "_Height", 0
									end if
									ObjForm.Add StrInam & "_Ext", StrFext
									ObjForm.Add StrInam & "_From", p_Start
									IntTemp = GetFerr(LngFsiz, StrFext)
									If p_AutoSave <> 2 Then
										ObjForm.Add StrInam & "_Err", IntTemp
										If IntTemp = 0 Then
											If p_AutoSave = 0 Then
												StrFnam = GetTimeStr()
												If StrFext <> "" Then StrFnam = StrFnam & "." & StrFext
											end if
											BinItem.SaveToFile Server.MapPath(p_SavePath & StrFnam), 2
											ObjForm.Add StrInam, StrFnam
										end if
									end if
								else
									ObjForm.Add StrInam & "_Err", -1
									ObjForm.Add StrInam, StrFnam
								end if
							end if
						else
							BinItem.Position = 0
							BinItem.Type = 2
							BinItem.Charset = "UTF-8"
							BinItem.Type = 2
							StrTemp = BinItem.ReadText
							If ObjForm.Exists(StrInam) Then
								ObjForm(StrInam) = ObjForm(StrInam) & "," & StrTemp
							else
								StrFormItem = StrFormItem & StrSplit & StrInam
								ObjForm.Add StrInam, StrTemp
							end if
						end if
						BinItem.Close()
						p_Start = p_End + IntSeparator + 2
'BinItem.Close()
						Loop Until p_Start + 3 > LngRequestSize
'BinItem.Close()
						FormItem = split(StrFormItem, StrSplit)
						FileItem = split(StrFileItem, StrSplit)
					end sub
					Private Function GetTimeStr()
						LngTime = LngTime + 1
'Private Function GetTimeStr()
						GetTimeStr = StrDate & LngTime
					end function
		Private Function GetFerr(LngFsiz, StrFext)
			Dim IntFerr
			IntFerr = 0
			If LngFsiz > p_MaxSize And p_MaxSize > 0 Then
				If p_Error = 0 Or p_Error = 2 Then p_Error = p_Error + 1
'If LngFsiz > p_MaxSize And p_MaxSize > 0 Then
				IntFerr = IntFerr + 1
'If LngFsiz > p_MaxSize And p_MaxSize > 0 Then
			end if
			If InStr(1, LCase("/" & p_FileType & "/"), LCase("/" & StrFext & "/")) = 0 And p_FileType <> "" Then
				If p_Error < 2 Then p_Error = p_Error + 2
'If InStr(1, LCase("/" & p_FileType & "/"), LCase("/" & StrFext & "/")) = 0 And p_FileType <> "" Then
				IntFerr = IntFerr + 2
'If InStr(1, LCase("/" & p_FileType & "/"), LCase("/" & StrFext & "/")) = 0 And p_FileType <> "" Then
			end if
			GetFerr = IntFerr
		end function
		Public Function Save(Item, StrFnam)
			Rem ******************************************
			Rem Item是表单中file元素
			Rem StrFnam是保存的文件名，可选值：
			Rem 　　０：自动取无重复的服务器时间字符串为文件名
			Rem 　　１：自动取源文件名
			Rem ******************************************
			Save = False
			If ObjForm.Exists(Item & "_From") Then
				Dim IntFerr, StrFext
				StrFext = ObjForm(Item & "_Ext")
				IntFerr = GetFerr(ObjForm(Item & "_Size"), StrFext)
				If ObjForm.Exists(Item & "_Err") Then
					If IntFerr = 0 Then
						ObjForm(Item & "_Err") = 0
					end if
				else
					ObjForm.Add Item & "_Err", IntFerr
				end if
				If IntFerr <> 0 Then Exit Function
				If VarType(StrFnam) = 2 Then
					Select Case StrFnam
					Case 0
					StrFnam = GetTimeStr()
					If StrFext <> "" Then StrFnam = StrFnam & "." & StrFext
					Case 1
					StrFnam = ObjForm(Item & "_Name")
					End Select
				end if
				BinItem.Type = 1
				BinItem.Open
				BinForm.Position = ObjForm(Item & "_From")
				BinForm.CopyTo BinItem,ObjForm(Item & "_Size")
				BinItem.SaveToFile Server.MapPath(p_SavePath & StrFnam), 2
				BinItem.Close()
				If ObjForm.Exists(Item) Then
					ObjForm(Item) = StrFnam
				else
					ObjForm.Add Item, StrFnam
				end if
				Save = True
			end if
		end function
		Public Function GetData(Item)
			GetData = ""
			If ObjForm.Exists(Item & "_From") Then
				If GetFerr(ObjForm(Item & "_Size"), ObjForm(Item & "_Ext")) <> 0 Then Exit Function
				BinForm.Position = ObjForm(Item & "_From")
				GetData = BinFormStream.Read(ObjForm(Item & "_Size"))
			end if
		end function
		Public Function Form(Item)
			If ObjForm.Exists(Item) Then
				Form = ObjForm(Item)
			else
				Form = ""
			end if
		end function
		Private Function BinVal2(Bin)
			Dim LngValue,i
			LngValue = 0
			For i = LenB(Bin) to 1 Step -1
				LngValue = 0
				LngValue = LngValue * 256 + AscB(MidB(Bin, i, 1))
				LngValue = 0
			next
			BinVal2 = LngValue
		end function
		Private Function Bin2Val(Bin)
			Dim LngValue, i
			LngValue = 0
			For i = 1 To LenB(Bin)
				LngValue = LngValue * 256 + AscB(MidB(Bin, i, 1))
'For i = 1 To LenB(Bin)
			next
			Bin2Val = LngValue
		end function
		Private Function Num2Str(Num, Base, Lens)
			Dim Ret
			Ret = ""
			While(Num >= Base)
			Ret = (Num Mod Base) & Ret
			Num = (Num - Num Mod Base) / Base
			Ret = (Num Mod Base) & Ret
		wend
		Num2Str = Right(String(Lens, "0") & Num & Ret, Lens)
	end function
	Private Function Str2Num(Str, Base)
		Dim Ret, I
		Ret = 0
		For I = 1 To Len(Str)
			Ret = Ret * base + Cint(Mid(Str, I, 1))
'For I = 1 To Len(Str)
		next
		Str2Num = Ret
	end function
	End Class
	Class iXuEr_UpFile
		Private UploadObj, ImageObj
		Private FilePath, InceptFile, FileMaxSize, MaxFile, Upload_Type, FileInfo, IsBinary, SessionName
		Private Preview_Type, View_ImageWidth, View_ImageHeight, Draw_ImageWidth, Draw_ImageHeight, Draw_Graph
		Private Draw_FontColor, Draw_FontFamily, Draw_FontSize, Draw_FontBold, Draw_Info, Draw_Type, Draw_XYType, Draw_SizeType
		Private RName_Str, Transition_Color
		Public ErrCodes, ObjName, UploadFiles, UploadForms, Count, CountSize
		Public p_UpLoadPID, OldFileName, DiyFileName, FormatType, AutoDir
		Public FileExt_1, FileExt_2, FileExt_3, FileExt_4, FileExt_5, FileExt_6
		Public Property Get Version
		Version = "智邦国际"
		End Property
		Private Sub Class_Initialize
			SessionName = Empty
			IsBinary = False
			ErrCodes = 0
			Count = 0
			AutoDir = 0
			CountSize = 0
			FilePath = "./"
			InceptFile = ""
			OldFileName = ""
			FormatType  = 0
			FileMaxSize = -1
			FormatType  = 0
			MaxFile = 1
			Upload_Type = -1
			MaxFile = 1
			Preview_Type = 999
			ObjName = "未知组件"
			View_ImageWidth = 0
			View_ImageHeight = 0
			Draw_FontColor       = &H000000
			Draw_FontFamily      = "Arial"
			Draw_FontSize        = 10
			Draw_FontBold        = False
			Draw_Info            = "BBS.IXUER.NET"
			Draw_Type            = -1
			Draw_Info            = "BBS.IXUER.NET"
			FileExt_1            = "jpg|jpeg|gif|bmp|png|tif|iff"
			FileExt_2            = "swf|swi"
			FileExt_3            = "mp3|m3u|wav|wma|wax|asx|asf|mp2|au|aif|aiff|mid|midi|rmi"
			FileExt_4            = "rm|rmvb|ram|ra|mov"
			FileExt_5            = "mpg|mpeg|mpv|mps|m2v|m1v|mpe|mpa|avi|wmv|wm|wmx|wvx"
			FileExt_6            = "asa|asp|bat|cmd|code|com|db|dll|doc|exe|fla|ftp|h|hlp|htm|html|inc|info|ini|js|log|mdb|pdf|php|pic|ppt|rar|real|torrent|txt|xls|xml|zip"
			Set UploadFiles = Server.CreateObject(ServerObject_004)
			Set UploadForms = Server.CreateObject(ServerObject_004)
			UploadFiles.CompareMode = 1
			UploadForms.CompareMode = 1
		end sub
		Private Sub Class_Terminate
			If IsObject(UploadObj) Then
				Set UploadObj = Nothing
			end if
			If IsObject(ImageObj) Then
				Set ImageObj = Nothing
			end if
			UploadFiles.RemoveAll
			UploadForms.RemoveAll
			Set UploadForms = Nothing
			Set UploadFiles = Nothing
		end sub
		Public Property Let GetBinary(Byval Values)
		IsBinary = Values
		End Property
		Public Property Let InceptFileType(Byval Values)
		InceptFile = LCase(Values)
		End Property
		Public Property Let ChkSessionName(Byval Values)
		SessionName = Values
		End Property
		Public Property Let MaxSize(Byval Values)
		FileMaxSize = ChkNumeric(Values) * 1024
		End Property
		Public Property Get MaxSize
		MaxSize = FileMaxSize
		End Property
		Public Property Let InceptMaxFile(Byval Values)
		MaxFile = ChkNumeric(Values)
		End Property
		Public Property Let UploadPath(Byval Path)
		FilePath = Replace(Path, Chr(0), "")
		If Right(FilePath,1) <> "/" Then FilePath = FilePath & "/"
		End Property
		Public Property Get UploadPath
		UploadPath = FilePath
		End Property
		Public Property Let UpLoadPID(Byval ID)
		p_UpLoadPID = ID
		End Property
		Public Property Get UpLoadPID()
		UpLoadPID = p_UpLoadPID
		End Property
		Public Property Get Description
		Select Case ErrCodes
		Case 1 : Description = "不支持 " & ObjName & " 上传，服务器可能未安装该组件。"
		Case 2 : Description = "暂未选择上传组件！"
		Case 3 : Description = "请先选择你要上传的文件!"
		Case 4 : Description = "文件大小超过了限制 " & (FileMaxSize\1024) & "KB!"
		Case 5 : Description = "文件类型不正确!"
		Case 6 : Description = "已达到上传数的上限！"
		Case 7 : Description = "请不要重复提交！"
		Case 8 : Description = "数据大小超过限制，并包含非法文件类型，上传失败！"
		Case 9 : Description = "数据总数量超过限制，上传失败！"
		Case Else
		Description = Empty
		End Select
		End Property
		Public Property Let RName(Byval Values)
		RName_Str = Values
		End Property
		Public Property Let UploadType(Byval Types)
		Upload_Type = Types
		If Upload_Type = "" or Not IsNumeric(Upload_Type) Then
			Upload_Type = -1
'If Upload_Type = "" or Not IsNumeric(Upload_Type) Then
		end if
		End Property
		Public Property Let PreviewType(Byval Types)
		Preview_Type = Types
		on error resume next
		If Preview_Type = "" or Not IsNumeric(Preview_Type) Then
			Preview_Type = 999
		else
			If PreviewType <> 999 Then
				Select Case Preview_Type
				Case 0
				ObjName = "CreatePreviewImage组件"
				Set ImageObj = Server.CreateObject(ServerObject_015)
				Case 1
				ObjName = "AspJpegV1.2组件"
				Set ImageObj = Server.CreateObject(ServerObject_016)
				Case 2
				ObjName = "SoftArtisans ImgWriter V1.21组件"
				Set ImageObj = Server.CreateObject(ServerObject_017)
				Case Else
				Preview_Type = 999
				End Select
				If Err.Number<>0 Then
					ErrCodes = 1
				end if
			end if
		end if
		End Property
		Public Property Get PreviewType
		PreviewType = Preview_Type
		End Property
		Public Property Let PreviewImageWidth(Byval Values)
		View_ImageWidth = ChkNumeric(Values)
		End Property
		Public Property Let PreviewImageHeight(Byval Values)
		View_ImageHeight = ChkNumeric(Values)
		End Property
		Public Property Let DrawImageWidth(Byval Values)
		Draw_ImageWidth = ChkNumeric(Values)
		End Property
		Public Property Let DrawImageHeight(Byval Values)
		Draw_ImageHeight = ChkNumeric(Values)
		End Property
		Public Property Let DrawGraph(Byval Values)
		If IsNumeric(Values) Then
			Draw_Graph = Formatnumber(Values, 2)
		else
			Draw_Graph = 1
		end if
		End Property
		Public Property Let TransitionColor(Byval Values)
		If Values <> "" Or Values <> "0" Then
			Transition_Color = Replace(Values, "#", "&h")
		end if
		End Property
		Public Property Let DrawFontColor(Byval Values)
		If Values<>"" or Values<>"0" Then
			Draw_FontColor = Replace(Values,"#","&h")
		end if
		End Property
		Public Property Let DrawFontFamily(Byval Values)
		Draw_FontFamily = Values
		End Property
		Public Property Let DrawFontSize(Byval Values)
		Draw_FontSize = Values
		End Property
		Public Property Let DrawFontBold(Byval Values)
		Draw_FontBold = ChkBoolean(Values)
		End Property
		Public Property Let DrawInfo(Byval Values)
		Draw_Info = Values
		End Property
		Public Property Let DrawType(Byval Values)
		Draw_Type = ChkNumeric(Values)
		End Property
		Public Property Let DrawXYType(Byval Values)
		Draw_XYType = Values
		End Property
		Public Property Let DrawSizeType(Byval Values)
		Draw_SizeType = Values
		End Property
		Private Function ChkNumeric(Byval Values)
			If Values<>"" And IsNumeric(Values) Then
				ChkNumeric = Int(Values)
			else
				ChkNumeric = 0
			end if
		end function
		Private Function ChkBoolean(Byval Values)
			If Typename(Values)="Boolean" or IsNumeric(Values) or LCase(Values)="false" or LCase(Values)="true" Then
				ChkBoolean = CBool(Values)
			else
				ChkBoolean = False
			end if
		end function
		Private Function FormatName(Byval FileExt)
			Dim RanNum, TempStr
			Select Case FormatType
			Case 1
			TempStr = OldFileName
			Case Else
			Randomize
			RanNum = Int(90000 * Rnd) + 10000
			Randomize
			TempStr = FormatTime(Now, 1) & RanNum
			End Select
			If RName_Str <> "" Then TempStr = RName_Str & TempStr
			FormatName = TempStr & "." & FileExt
		end function
		Private Function FixName(Byval UpFileExt)
			If IsEmpty(UpFileExt) Then Exit Function
			FixName = LCase(UpFileExt)
			FixName = Replace(FixName, Chr(0), "")
			FixName = Replace(FixName, ".", "")
			FixName = Replace(FixName, "'", "")
			FixName = Replace(FixName, "asp", "")
			FixName = Replace(FixName, "asa", "")
			FixName = Replace(FixName, "aspx", "")
			FixName = Replace(FixName, "cer", "")
			FixName = Replace(FixName, "cdx", "")
			FixName = Replace(FixName, "htr", "")
		end function
		Private Function CheckFileExt(FileExt)
			Dim Forumupload,i
			CheckFileExt = False
			If FileExt = "" Or IsEmpty(FileExt) Then
				CheckFileExt = False
				Exit Function
			end if
			If FileExt = "asp" or FileExt = "asa" or FileExt = "aspx" Then
				CheckFileExt = False
				Exit Function
			end if
			Forumupload = Split(InceptFile, ",")
			For i = 0 To UBound(Forumupload)
				If FileExt = Trim(Forumupload(i)) Then
					CheckFileExt = True
					Exit Function
				else
					CheckFileExt = False
				end if
			next
		end function
		Private Function CheckFiletype(Byval FileExt)
			FileExt = "|" & LCase(Replace(FileExt, ".", "")) & "|"
			FileExt_1 = "|" & LCase(FileExt_1) & "|"
			FileExt_2 = "|" & LCase(FileExt_2) & "|"
			FileExt_3 = "|" & LCase(FileExt_3) & "|"
			FileExt_4 = "|" & LCase(FileExt_4) & "|"
			FileExt_5 = "|" & LCase(FileExt_5) & "|"
			FileExt_6 = "|" & LCase(FileExt_6) & "|"
			If InStr(FileExt_1, FileExt) > 0 Then
				CheckFiletype = 1
				Exit Function
			ElseIf InStr(FileExt_2, FileExt) > 0 Then
				CheckFiletype = 2
				Exit Function
			ElseIf InStr(FileExt_3, FileExt) > 0 Then
				CheckFiletype = 3
				Exit Function
			ElseIf InStr(FileExt_4, FileExt) > 0 Then
				CheckFiletype = 4
				Exit Function
			ElseIf InStr(FileExt_5, FileExt) > 0 Then
				CheckFiletype = 5
				Exit Function
			ElseIf InStr(FileExt_6, FileExt) > 0 Then
				CheckFiletype = 6
				Exit Function
			else
				CheckFiletype = 0
				Exit Function
			end if
		end function
		Public Sub SaveUpFile()
			on error resume next
			Select Case CInt(Upload_Type)
			Case 0
			ObjName = "智邦国际"
			Set UploadObj = New iXs_ClsUp
			If Err.Number<>0 Then
				ErrCodes = 1
			else
				SaveFile_0
			end if
			Case 1
			ObjName = "Aspupload3.0组件"
			Set UploadObj = Server.CreateObject(ServerObject_011)
			If Err.Number<>0 Then
				ErrCodes = 1
			else
				SaveFile_1
			end if
			Case 2
			ObjName = "SA-FileUp 4.0组件"
'Case 2
			Set UploadObj = Server.CreateObject(ServerObject_013)
			If Err.Number<>0 Then
				ErrCodes = 1
			else
				SaveFile_2
			end if
			Case 3
			ObjName = "DvFile.Upload V1.0组件"
			Set UploadObj = Server.CreateObject(ServerObject_014)
			If Err.Number<>0 Then
				ErrCodes = 1
			else
				SaveFile_3
			end if
			Case Else
			ErrCodes = 2
			End Select
		end sub
		Private Sub SaveFile_0()
			Dim i
			Dim FormName,Item, File
			Dim FileExt, FileName, FileType, FileToBinary, FileSize
			UploadObj.MaxSize   = FileMaxSize
			UploadObj.FileType  = Replace(InceptFile, ",", "/")
			UploadObj.SavePath  = FilePath
			UploadObj.UpLoadPID = p_UpLoadPID
			UploadObj.AutoSave  = 2
			UploadObj.Open()
			FileToBinary = Null
			If Not IsEmpty(SessionName) Then
				If Session(SessionName) <> UploadObj.Form(SessionName) Or Session(SessionName) = Empty Then
					ErrCodes = 7
					Exit Sub
				end if
			end if
			If UploadObj.Error > 0 then
				Select Case UploadObj.Error
				Case 1 : ErrCodes = 4
				Case 2 : ErrCodes = 5
				Case 3 : ErrCodes = 8
				Case 4 : ErrCodes = 9
				End Select
				Exit Sub
			else
				For i = 1 To UBound(UploadObj.FileItem)             '
					FormName = UploadObj.FileItem(i)
					If Count > MaxFile Then
						ErrCodes = 6
						Exit Sub
					end if
					OldFileName = UploadObj.Form(FormName & "_Name")
					FileExt = LCase(UploadObj.Form(FormName & "_Ext"))
					FileName = FormatName(FileExt)
					FileType = CheckFiletype(FileExt)
					If IsBinary Then
						FileToBinary = UploadObj.GetData(FormName)
					end if
					FileSize = ChkNumeric(UploadObj.Form(FormName & "_Size"))
					If FileSize > 0 Then
						UploadObj.Save FormName, FileName
'AddData FormName , _
'FileName , _
'FilePath , _
'FileSize , _
'UploadObj.Form(FormName & "_Type") , _
'FileType , _
'FileToBinary , _
'FileExt , _
'UploadObj.Form(FormName & "_Width") , _
'UploadObj.Form(FormName & "_Height")
						Count = Count + 1
'UploadObj.Form(FormName & "_Height")
						CountSize = CountSize + UploadObj.Form(FormName & "_Size")
'UploadObj.Form(FormName & "_Height")
					end if
				next
				For i = 0 To UBound(UploadObj.FormItem)
					If UploadForms.Exists(UploadObj.FormItem(i)) Then
						UploadForms(i) = UploadObj.FormItem(i) & ", " & UploadObj.FormItem(i)
					else
						UploadForms.Add i, UploadObj.FormItem(i)
					end if
				next
				Call DeleteUpDateFile("UpLoadData/")
				If Not IsEmpty(SessionName) Then Session(SessionName) = Empty
			end if
		end sub
		Private Sub SaveFile_1()
			Dim FileCount
			Dim FormName,Item,File
			Dim FileExt,FileName,FileType,FileToBinary
			UploadObj.ProgressID = p_UploadPID
			UploadObj.OverwriteFiles = False
			UploadObj.IgnoreNoPost = True
			UploadObj.SetMaxSize FileMaxSize, True
			FileCount = UploadObj.Save
			FileToBinary = Null
			If Not IsEmpty(SessionName) Then
				If Session(SessionName) <> UploadObj.Form(SessionName) or Session(SessionName) = Empty Then
					ErrCodes = 7
					Exit Sub
				end if
			end if
			If Err.Number = 8 Then
				ErrCodes = 4
				Exit Sub
			else
				If Err <> 0 Then
					ErrCodes = -1
'If Err <> 0 Then
					Response.write "错误信息: " & Err.Description
					Exit Sub
				end if
				If FileCount < 1 Then
					ErrCodes = 3
					Exit Sub
				end if
				For Each File In UploadObj.Files
					If Count>MaxFile Then
						ErrCodes = 6
						Exit Sub
					end if
					FileExt = FixName(Replace(File.Ext,".",""))
					If CheckFileExt(FileExt) = False then
						ErrCodes = 5
						Exit Sub
					end if
					OldFileName = File.FileName
					FileName = FormatName(FileExt)
					FileType = CheckFiletype(FileExt)
					If IsBinary Then
						FileToBinary = File.Binary
					end if
					If File.Size>0 Then
						File.SaveAs Server.Mappath(FilePath & FileName)
'AddData File.Name , _
'FileName , _
'FilePath , _
'File.Size , _
'File.ContentType , _
'FileType , _
'FileToBinary , _
'FileExt , _
'File.ImageWidth , _
'File.ImageHeight
						Count = Count + 1
						File.ImageHeight
						CountSize = CountSize + File.Size
						File.ImageHeight
					end if
				next
				For Each Item in UploadObj.Form
					If UploadForms.Exists (Item) Then _
					UploadForms(Item) = UploadForms(Item) & ", " & Item.Value _
				Else _
					UploadForms.Add Item.Name , Item.Value
				next
				If Not IsEmpty(SessionName) Then Session(SessionName) = Empty
			end if
		end sub
		Private Sub SaveFile_2()
			Dim FormName,Item,File,FormNames
			Dim FileExt,FileName,FileType,FileToBinary
			Dim Filesize
			FileToBinary = Null
			If Not IsEmpty(SessionName) Then
				If Session(SessionName) <> UploadObj.Form(SessionName) or Session(SessionName) = Empty Then
					ErrCodes = 7
					Exit Sub
				end if
			end if
			For Each FormName In UploadObj.Form
				FormNames = ""
				If IsObject(UploadObj.Form(FormName)) Then
					If Not UploadObj.Form(FormName).IsEmpty Then
						UploadObj.Form(FormName).Maxbytes = FileMaxSize
						UploadObj.OverWriteFiles = False
						Filesize = UploadObj.Form(FormName).TotalBytes
						If Err.Number<>0 Then
							ErrCodes = -1
'If Err.Number<>0 Then
							Response.write "错误信息: " & Err.Description
							Exit Sub
						end if
						If Filesize>FileMaxSize then
							ErrCodes = 4
							Exit Sub
						end if
						FileName    = UploadObj.Form(FormName).ShortFileName
						OldFileName = FileName
						FileExt             = Mid(Filename, InStrRev(Filename, ".")+1)
						OldFileName = FileName
						FileExt             = FixName(FileExt)
						If CheckFileExt(FileExt) = False then
							ErrCodes = 5
							Exit Sub
						end if
						FileName = FormatName(FileExt)
						FileType = CheckFiletype(FileExt)
						If Filesize>0 Then
							UploadObj.Form(FormName).SaveAs Server.MapPath(FilePath & FileName)
'AddData FormName , _
'FileName , _
'FilePath , _
'FileSize , _
'UploadObj.Form(FormName).ContentType , _
'FileType , _
'FileToBinary , _
'FileExt , _
'-1 , _
'FileExt , _
'-1
'FileExt , _
							Count = Count + 1
'FileExt , _
							CountSize = CountSize + Filesize
'FileExt , _
						end if
					else
						ErrCodes = 3
						Exit Sub
					end if
				else
					If UploadObj.FormEx(FormName).Count > 1 Then
						For Each FormNames In UploadObj.FormEx(FormName)
							FormNames = FormNames & ", " & FormNames
						next
						UploadForms.Add FormName , FormNames
					else
						UploadForms.Add FormName , UploadObj.Form(FormName)
					end if
				end if
			next
			If Not IsEmpty(SessionName) Then Session(SessionName) = Empty
		end sub
		Private Sub SaveFile_3()
			Dim FormName, Item, File
			Dim FileExt, FileName, FileType, FileToBinary
			UploadObj.InceptFileType = InceptFile
			UploadObj.MaxSize = FileMaxSize
			UploadObj.Install
			FileToBinary = Null
			If Not IsEmpty(SessionName) Then
				If Session(SessionName) <> UploadObj.Form(SessionName) Or Session(SessionName) = Empty Then
					ErrCodes = 7
					Exit Sub
				end if
			end if
			If UploadObj.Err > 0 then
				Select Case UploadObj.Err
				Case 1 : ErrCodes = 3
				Case 2 : ErrCodes = 4
				Case 3 : ErrCodes = 5
				Case 4 : ErrCodes = 5
				Case 5 : ErrCodes = -1
'Case 4 : ErrCodes = 5
				End Select
				Exit Sub
			else
				For Each FormName In UploadObj.File         '
					If Count>MaxFile Then
						ErrCodes = 6
						Exit Sub
					end if
					Set File = UploadObj.File(FormName)
					FileExt = FixName(File.FileExt)
					If CheckFileExt(FileExt) = False then
						ErrCodes = 5
						Exit Sub
					end if
					FileName = FormatName(FileExt)
					OldFileName = File.FileName
					FileType = CheckFiletype(FileExt)
					If IsBinary Then
						FileToBinary = File.FileData
					end if
					If File.FileSize>0 Then
						UploadObj.SaveToFile Server.mappath(FilePath & FileName), FormName
'AddData FormName , _
'FileName , _
'FilePath , _
'File.FileSize , _
'File.FileType , _
'FileType , _
'FileToBinary , _
'FileExt , _
'File.FileWidth , _
'File.FileHeight
						Count = Count + 1
'File.FileHeight
						CountSize = CountSize + File.FileSize
'File.FileHeight
					end if
					Set File=Nothing
				next
				For Each Item in UploadObj.Form
					UploadForms.Add Item.Name , Item.Value
				next
				If Not IsEmpty(SessionName) Then Session(SessionName) = Empty
			end if
		end sub
		Private Sub AddData( Form_Name, File_Name, File_Path, File_Size, File_ContentType, File_Type, File_Data, File_Ext, File_Width, File_Height )
			Set FileInfo = New FileInfo_Cls
			FileInfo.FormName = Form_Name
			FileInfo.FileName = File_Name
			FileInfo.FilePath = File_Path
			FileInfo.FileSize = File_Size
			FileInfo.FileType = File_Type
			FileInfo.FileContentType = File_ContentType
			FileInfo.FileExt = File_Ext
			FileInfo.FileData = File_Data
			FileInfo.FileHeight = File_Height
			FileInfo.FileWidth = File_Width
			UploadFiles.Add Form_Name , FileInfo
			Set FileInfo = Nothing
		end sub
		Public Sub CreateView(Imagename, TempFilename, FileExt)
			If ErrCodes <>0 Then Exit Sub
			Select Case Preview_Type
			Case 0
			Image_Obj_0 Imagename, TempFilename, FileExt
			Case 1
			Image_Obj_1 Imagename, TempFilename, FileExt
			Case 2
			Image_Obj_2 Imagename, TempFilename, FileExt
			Case Else
			Preview_Type = 999
			End Select
		end sub
		Sub Image_Obj_0(Imagename,TempFilename,FileExt)
			ImageObj.SetSavePreviewImagePath = Server.MapPath(TempFilename)
			ImageObj.SetPreviewImageSize = SetPreviewImageSize
			ImageObj.SetImageFile = Trim(Server.MapPath(Imagename))
			If ImageObj.DoImageProcess = False Then
				ErrCodes = -1
'If ImageObj.DoImageProcess = False Then
				Response.write "生成预览图错误: " & ImageObj.GetErrString
			end if
		end sub
		Sub Image_Obj_1(Imagename,TempFilename,FileExt)
			Dim Draw_X,Draw_Y,Logobox
			Draw_X = 0
			Draw_Y = 0
			FileExt = LCase(FileExt)
			ImageObj.Open Trim(Server.MapPath(Imagename))
			If ImageObj.OriginalWidth<View_ImageWidth or ImageObj.Originalheight<View_ImageHeight Then
				TempFilename = ""
				Exit Sub
			else
				If FileExt<>"gif" and ImageObj.OriginalWidth > Draw_ImageWidth * 2 and Draw_Type >0 Then
					Draw_X = DrawImage_X(ImageObj.OriginalWidth,Draw_ImageWidth,2)
					Draw_Y = DrawImage_y(ImageObj.Originalheight,Draw_ImageHeight,2)
					If Draw_Type=2 Then
						Set Logobox = Server.CreateObject(ServerObject_016)
						Logobox.Open Server.MapPath(Draw_Info)
						Logobox.Width = Draw_ImageWidth
						Logobox.Height = Draw_ImageHeight
						ImageObj.DrawImage Draw_X, Draw_Y, Logobox, Draw_Graph,Transition_Color,90
						ImageObj.Save Server.MapPath(Imagename)
						Set Logobox=Nothing
					else
						ImageObj.Canvas.Font.Color          = Draw_FontColor
						ImageObj.Canvas.Font.Family         = Draw_FontFamily
						ImageObj.Canvas.Font.Bold           = Draw_FontBold
						ImageObj.Canvas.Font.Size           = Draw_FontSize
						ImageObj.Canvas.Print Draw_X, Draw_Y, Draw_Info
						ImageObj.Canvas.Pen.Color           = &H000000
						ImageObj.Canvas.Pen.Width           = 1
						ImageObj.Canvas.Brush.Solid = False
						ImageObj.Save Server.MapPath(Imagename)
					end if
				end if
				If ImageObj.Width > ImageObj.height Then
					ImageObj.Width = View_ImageWidth
					ImageObj.Height = ViewImage_Height(ImageObj.OriginalWidth,ImageObj.Originalheight,View_ImageWidth,View_ImageHeight)
				else
					ImageObj.Width = ViewImage_Width(ImageObj.OriginalWidth,ImageObj.Originalheight,View_ImageWidth,View_ImageHeight)
					ImageObj.Height = View_ImageHeight
				end if
				ImageObj.Sharpen 1, 120
				ImageObj.Save Server.MapPath(TempFilename)
			end if
		end sub
		Public Sub Image_Obj_2(Imagename,TempFilename,FileExt)
			Dim Draw_X,Draw_Y
			FileExt = LCase(FileExt)
			Draw_X = 0
			Draw_Y = 0
			ImageObj.LoadImage Trim(Server.MapPath(Imagename))
			If ImageObj.ErrorDescription <> "" Then
				TempFilename = ""
				ErrCodes = -1
				TempFilename = ""
				Response.write "生成预览图错误: " &ImageObj.ErrorDescription
				Exit Sub
			end if
			If ImageObj.Width<Cint(View_ImageWidth) or ImageObj.Height<Cint(View_ImageHeight) Then
				TempFilename=""
				Exit Sub
			else
				IF FileExt<>"gif" and ImageObj.Width > Draw_ImageWidth * 2 and Draw_Type>0 Then
					Draw_X = DrawImage_X(ImageObj.Width,Draw_ImageWidth,2)
					Draw_Y = DrawImage_y(ImageObj.Height,Draw_ImageHeight,2)
					Dim saiTopMiddle
					Select Case Draw_XYType
					Case "0"
					saiTopMiddle = 3
					Case "1"
					saiTopMiddle = 5
					Case "2"
					saiTopMiddle = 1
					Case "3"
					saiTopMiddle = 6
					Case "4"
					saiTopMiddle = 8
					Case Else
					saiTopMiddle = 0
					End Select
					If Draw_Type=2 Then
						ImageObj.AddWatermark Server.MapPath(Draw_Info), saiTopMiddle, Draw_Graph,Transition_Color,True
					else
						ImageObj.Font.Italic        = False
						ImageObj.Font.height        = Draw_FontSize
						ImageObj.Font.name          = Draw_FontFamily
						ImageObj.Font.Color         = Draw_FontColor
						ImageObj.Text                       = Draw_Info
						ImageObj.DrawTextOnImage Draw_X, Draw_Y, ImageObj.TextWidth, ImageObj.TextHeight
					end if
					ImageObj.SaveImage 0, ImageObj.ImageFormat, Server.MapPath(Imagename)
				end if
				ImageObj.ColorResolution = 24
				ImageObj.ResizeImage View_ImageWidth,View_ImageHeight,0,0
				ImageObj.SaveImage 0, 3, Server.MapPath(TempFilename)
			end if
		end sub
		Private Function ViewImage_Width(Image_W,Image_H,xView_W,xView_H)
			If Draw_SizeType = "1" Then
				ViewImage_Width = Image_W * xView_H / Image_H
			else
				ViewImage_Width = xView_W
			end if
		end function
		Private Function ViewImage_Height(Image_W,Image_H,xView_W,xView_H)
			If Draw_SizeType = "1" Then
				ViewImage_Height = xView_W * Image_H / Image_W
			else
				ViewImage_Height = xView_H
			end if
		end function
		Private Function DrawImage_X(xImage_W,xLogo_W,SpaceVal)
			Select Case Draw_XYType
			Case "0"
			DrawImage_X = SpaceVal
			Case "1"
			DrawImage_X = SpaceVal
			Case "2"
			DrawImage_X = (xImage_W + xLogo_W) / 2 - xLogo_W
'Case "2" '
			Case "3"
			DrawImage_X = xImage_W - xLogo_W - SpaceVal
'Case "3" '
			Case "4"
			DrawImage_X = xImage_W - xLogo_W - SpaceVal
'Case "4" '
			Case Else
			DrawImage_X = 0
			End Select
		end function
		Private Function DrawImage_Y(yImage_H,yLogo_H,SpaceVal)
			Select Case Draw_XYType
			Case "0"
			DrawImage_Y = SpaceVal
			Case "1"
			DrawImage_Y = yImage_H - yLogo_H - SpaceVal
'Case "1" '
			Case "2"
			DrawImage_Y = (yImage_H + yLogo_H) / 2 - yLogo_H
'Case "2" '
			Case "3"
			DrawImage_Y = SpaceVal
			Case "4"
			DrawImage_Y = yImage_H - yLogo_H - SpaceVal
'Case "4" '
			Case Else
			DrawImage_Y = 0
			End Select
		end function
		Function CreatePath(StrPath)
			Dim ObjFSO, Fsofolder, UpLoadPath
			UpLoadPath = FormatTime(Now(), AutoDir)
			on error resume next
			If Right(StrPath, 1) <> "/" Then StrPath = StrPath & "/"
			Set ObjFSO = Server.CreateObject(ServerObject_005)
			If ObjFSO.FolderExists(Server.MapPath(StrPath & UpLoadPath)) = False Then
				ObjFSO.CreateFolder Server.MapPath(StrPath & UpLoadPath)
			end if
			If Err.Number = 0 Then
				CreatePath = StrPath & UpLoadPath & "/"
			else
				Err.Clear
				CreatePath = StrPath
			end if
			Set ObjFSO = Nothing
		end function
	End Class
	Class FileInfo_Cls
		Public FormName, FileName, FilePath, FileSize, FileContentType, FileType, FileData, FileExt, FileWidth, FileHeight
		Private Sub Class_Initialize
			FileWidth = -1
'Private Sub Class_Initialize
			FileHeight = -1
'Private Sub Class_Initialize
		end sub
	End Class
	Function DeleteUpDateFile(FilePath)
		on error resume next
		If Right(FilePath, 1) <> "/" Then FilePath = FilePath & "/"
		DeleteUpDateFile = False
		Dim Fso, F, F1, Fc, S
		Set Fso = CreateObject(ServerObject_005)
		If Err Then Err.Clear : Exit Function
		Set F = Fso.GetFolder(Server.MapPath(FilePath))
		Set Fc = F.Files
		For Each F1 In Fc
			Fso.DeleteFile(Server.MapPath(FilePath & F1.Name))
		next
		Set Fc = Nothing
		Set Fso = Nothing
		DeleteUpDateFile = True
	end function
	Public Function FormatTime(s_Time, n_Flag)
		If Not IsDate(s_Time) Then Exit Function
		Dim y, m, d, h, mi, s, w
		FormatTime = ""
		y = CStr(Year(s_Time))
		m = CStr(Month(s_Time))
		If Len(m) = 1 Then m = "0" & m
		d = CStr(Day(s_Time))
		If Len(d) = 1 Then d = "0" & d
		h = CStr(Hour(s_Time))
		If Len(h) = 1 Then h = "0" & h
		mi = CStr(Minute(s_Time))
		If Len(mi) = 1 Then mi = "0" & mi
		s = CStr(Second(s_Time))
		If Len(s) = 1 Then s = "0" & s
		Select Case n_Flag
		Case 1
		FormatTime = y & m & d & h & mi & s
		Case 2
		FormatTime = y & "-" & m & "-" & d
'Case 2 '
		Case 3
		FormatTime = Y & "-" & m
'Case 3 '
		Case Else
		FormatTime = Y & "-" & m
'Case Else '
		End Select
	end function
	
	function CheckPower2010(strori,strsub)
		if instr(1,","&cstr(strori&"")&",",","&cstr(trim(strsub&""))&",",1)>0 then
			CheckPower2010=true
		else
			CheckPower2010=false
		end if
	end function
	function powerdetail(sort1,sort2)
		set rs7=server.CreateObject("adodb.recordset")
		sql7="select * from power where ord="&session("personzbintel2007")&" and sort1="&sort1&" and sort2="&sort2
		rs7.open sql7,conn,1,1
		if not rs7.eof then
			if rs7("qx_open")=0 then
				tp=false
			else
				tp=true
			end if
		end if
		rs7.close
		set rs7=nothing
		powerdetail=tp
	end function
	function openPower(x1,x2)
		if x1<>"" and x2<>"" then
			set rs1=server.CreateObject("adodb.recordset")
			sql1="select qx_open from power  where ord="&session("personzbintel2007")&" and sort1="&x1&" and sort2="&x2&""
			rs1.open sql1,conn,1,1
			if rs1.eof then
				openPower=0
			else
				openPower=rs1("qx_open")
			end if
			rs1.close
			set rs1=nothing
		else
			openPower=0
		end if
	end function
	function introPower(x1,x2)
		if x1<>"" and x2<>"" then
			set rs1=server.CreateObject("adodb.recordset")
			sql1="select qx_intro from power  where ord="&session("personzbintel2007")&" and sort1="&x1&" and sort2="&x2&""
			rs1.open sql1,conn,1,1
			if rs1.eof then
				introPower=0
			else
				introPower=rs1("qx_intro")
			end if
			rs1.close
			set rs1=nothing
		else
			introPower=0
		end if
	end function
	function PurviewPower(AllPurviews,strPurview)
		if isNull(AllPurviews) or AllPurviews="" or strPurview="" then
			PurviewPower=False
			exit function
		end if
		PurviewPower=False
		if instr(AllPurviews,",")>0 then
			dim arrPurviews,i77
			arrPurviews=split(AllPurviews,",")
			for i77=0 to ubound(arrPurviews)
				if trim(arrPurviews(i77))=strPurview then
					PurviewPower=True
					exit for
				end if
			next
		else
			if AllPurviews=strPurview then
				PurviewPower=True
			end if
		end if
	end function
	function PowerStr(x1,x2)
		if x1<>"" and x2<>"" then
			if openPower(x1,x2)=3 or PurviewPower(introPower(x1,x2),trim(session("personzbintel2007")))=True then
				PowerStr=true
			else
				PowerStr=false
			end if
		else
			PowerStr=false
		end if
	end function
	function PowerAllPerson(x1,x2)
		PowerAllPerson=false
		if x1<>"" and x2<>"" then
			set rs1=server.CreateObject("adodb.recordset")
			sql1="select qx_open from power  where ord="&session("personzbintel2007")&" and sort1="&x1&" and sort2="&x2&""
			rs1.open sql1,conn,1,1
			if rs1.eof then
				PowerAllPerson=false
			else
				if rs1("qx_open")=3 then
					PowerAllPerson=true
				else
					PowerAllPerson=false
				end if
			end if
			rs1.close
			set rs1=nothing
		else
			PowerAllPerson=false
		end if
	end function
	function getPowerIntro(s1, s2)
		dim sql ,r , rs
		sql = "select case a.qx_open when 3 then '' when 1 then (case ql.sort when 3 then qx_intro when 1 then '' end) else '-222' end from power a inner join qxlblist ql on ql.sort1=" & s1 & " and ql.sort2=" & s2 & " where a.sort1 = " & s1 & " and a.sort2 = " & s2 & " and ord=" & session("personzbintel2007")
		set rs = conn.execute(sql)
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
	
	dim MODULES
	MODULES=session("zbintel2010ms")
	on error resume next
	Response.ExpiresAbsolute = Now() - 1
	MODULES=session("zbintel2010ms")
	Response.Expires = -1
	MODULES=session("zbintel2010ms")
	Response.CacheControl = "no-cache"
	MODULES=session("zbintel2010ms")
	Server.ScriptTimeout = 999999
	Dim Temp, TempHtml, Templates
	Dim Action, HaveErr
	Dim ObjUpType, ObjUpClass, bgColor, Wid
	Dim n, Self_Referer
	Dim UpLoadPID, CreatPreview
	Action = iXs.ReqNum("Action", 0)
	bgColor = iXs.ReqStr("bgColor", "")
	Wid = iXs.ReqNum("Wid", 0)
	Self_Referer = Request.ServerVariables("HTTP_REFERER")
	CreatPreview = True
	Dim FileSavePath, FileUpMaxNum, FileAllowExt, FileMaxSize, FilePrevPath
	iXs.UpFileObject     = 0 ' UpFileObject = 1
	FileSavePath                 = "../in/"
	FileUpMaxNum                 = 100
	FileAllowExt                 = "xls"
	FileMaxSize                  = 409600
	FilePrevPath                 = "PreviewImage/"
	Response.write "<?xml version=""1.0"" encoding=""UTF-8""?>" & vbcrlf & "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">" & vbcrlf & "<html xmlns=""http://www.w3.org/1999/xhtml"">" & vbcrlf & "<head>" & vbcrlf & "<meta http-equiv=""Content-Type""content=""text/html; charset=UTF-8"" /> "& vbcrlf & "<link rel=""icon"" href=""/favicon.ico"" type=""image/x-icon"" /> "& vbcrlf & "<link href=""../inc/cskt.css?ver="
	FilePrevPath                 = "PreviewImage/"
	Response.write Application("sys.info.jsver")
	Response.write """ rel=""stylesheet"" type=""text/css"">" & vbcrlf & "<meta content=""all"" name=""robots"" />" & vbcrlf & "<meta name=""author"" content="""" />" & vbcrlf & "<meta name=""generator"" content=""Microsoft FrontPage 5.0"" />" & vbcrlf & "<meta name=""Copyright"" content="""" />" & vbcrlf & "<meta name=""Keywords"" content="""" />" & vbcrlf & "<meta name=""Description"" content="""" />" & vbcrlf & "<meta name=""MSSmartTagsPreventParsing"" content=""TRUE"" />" & vbcrlf & "<meta http-equiv=""MSThemeCompatible"" content=""Yes"" />" & vbcrlf & "<meta http-equiv=""html"" content=""no-cache"" />"& vbcrlf & "<title>图书登记资料导入</title>" & vbcrlf & "<!--iXs_UpLoadPost.asp##上传接口页面代码开始-->" & vbcrlf & "<style type=""text/css"">" & vbcrlf & "    body, td, th {color: #000000;font: 12px Tahoma, ""宋体"";}" & vbcrlf & "  body{margin:0px; background-color:{$UpLoadBackGroundColor};}" & vbcrlf & "    form{margin:0px;}" & vbcrlf & " input{Border: 1px solid #000000;BackGround-Color: buttonface;Color: #000000;height:17px;font: 12px Tahoma, ""宋体"";}" & vbcrlf & "       .red{color:#FF0000;}" & vbcrlf & "</style>" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "<!--" & vbcrlf & "   if(top.location == self.location){" & vbcrlf & "                alert(""请不要非法调用此文件！"");" & vbcrlf & "          top.location=""Index.asp"";" & vbcrlf & " }" & vbcrlf & "-->" & vbcrlf & "</script>" & vbcrlf & "</head>" & vbcrlf & "<body>" & vbcrlf & "<table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"" background=""../images/m_mpbg.gif"">" & vbcrlf & "          <tr>" & vbcrlf & "            <td class=""place"">图书登记资料导入</td>" & vbcrlf & "            <td class=""name""><font class=""name"">待传文件必须是EXCEL格式，请确认字段格式与数据库字段完全对应。</font>" & vbcrlf & "              <input type=""button"" name=""Submit422"" value=""导入说明""  onclick=""window.location.href='../in/caption_bookData.doc'"" class=""anniu""/>" & vbcrlf & "                          <input type=""button"" name=""Submit42"" value=""查看范例""  onclick=""window.location.href='../in/example_bookData.xls'"" class=""anniu""/>" & vbcrlf & "                      </td>" & vbcrlf & "            <td width=""3""><img src=""../images/m_mpr.gif"" width=""3"" height=""32"" /></td>" & vbcrlf & "          </tr>" & vbcrlf & "      </table>  " & vbcrlf & ""
	Select Case Action
	Case 1
	Dim UpLoad, UpForm
	Dim FileID, FormName, FileName, FilePath, PreviewPath
	Set UpLoad = New iXuEr_UpFile
	Set UpForm = New FileInfo_Cls
	UpLoadPID = iXs.ReqStr("UpLoadPID", 0)
	UpLoad.AutoDir = 0
	PreviewPath  = UpLoad.CreatePath(FilePrevPath)
	FilePath     = UpLoad.CreatePath(FileSavePath)
	UpLoad.UpLoadPID                     = UpLoadPID
	UpLoad.UpLoadPath                    = FilePath
	UpLoad.UpLoadType                    = iXs.UpFileObject
	UpLoad.InceptMaxFile         = FileUpMaxNum
	UpLoad.InceptFileType                = Replace(FileAllowExt, "|", ",")
	UpLoad.MaxSize                               = FileMaxSize
	UpLoad.FormatType                    = 0
	UpLoad.RName                         = "zbintel_"
	UpLoad.FileExt_1                     = "jpg|jpeg|gif|bmp|png|tif|iff"
	UpLoad.FileExt_2                     = "swf|swi"
	UpLoad.FileExt_3                     = "mp3|m3u|wav|wma|wax|asx|asf|mp2|au|aif|aiff|mid|midi|rmi"
	UpLoad.FileExt_4                     = "rm|rmvb|ram|ra|mov"
	UpLoad.FileExt_5                     = "dat|mpg|mpeg|mpv|mps|m2v|m1v|mpe|mpa|avi|wmv|wm|wmx|wvx"
	UpLoad.FileExt_6                     = "xls"
	UpLoad.PreviewType                   = 1
	UpLoad.PreviewImageWidth     = 180
	UpLoad.PreviewImageHeight    = 150
	UpLoad.DrawImageWidth                = 180
	UpLoad.DrawImageHeight               = 60
	UpLoad.DrawGraph                     = 1
	UpLoad.DrawFontColor         = "#FF0000"
	UpLoad.DrawFontFamily                = "Arial"
	UpLoad.DrawFontSize                  = 12
	UpLoad.DrawFontBold                  = True
	UpLoad.DrawInfo                              = "Images/WaterMap_4.gif"
	UpLoad.DrawType                              = 2
	UpLoad.DrawXYType                    = 4                                                                     ' "0"=左上，"1"=左下,"2"=居中,"3"=右上,"4"=右下
	UpLoad.DrawSizeType                  = 1                                                                     ' "0"=固定缩小，"1"=等比例缩小
	UpLoad.TransitionColor               = "#F0F0F0"
	UpLoad.SaveUpFile
	Dim File, F_FileName, F_Viewname
	If UpLoad.Count > 0 Then
		Response.write "<!--上传后返回的代码-->" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "<!--" & vbcrlf & "      try{" & vbcrlf & "            // 插入文件" & vbcrlf & "             <!--返回代码循环部分 开始-->"
'If UpLoad.Count > 0 Then
		TempHtml = ""
		For Each FormName In UpLoad.UpLoadFiles
			Set File = UpLoad.UpLoadFiles(FormName)
			F_FileName = FilePath & File.FileName
			F_Viewname = ""
			If CreatPreview = True Then
				If UpLoad.PreviewType <> 999 And File.FileType = 1 Then
					F_Viewname = PreviewPath & "pre" & Replace(File.FileName, File.FileExt, "") & "jpg"
					Call UpLoad.CreateView(F_FileName, F_Viewname, File.FileExt)
				end if
			end if
			Call UpLoadSave(File.FileName, File.FilePath, File.FileSize, File.FileContentType, File.FileType, File.FileExt, File.FileWidth, File.FileHeight, F_Viewname)
			Set File = Nothing
		next
		Response.write "" & vbcrlf & "              <!--返回代码循环部分 结束-->" & vbcrlf & "    }" & vbcrlf & "       catch(e){};" & vbcrlf & "//-->" & vbcrlf & "</script>"
		Set File = Nothing
		Response.write(Templates)
		Call iXs.Redirect("../in/save_bookData.asp", 500)
	else
		Response.write("请正确选择要上传的文件,只能是EXCEL文件。[<a href=""" & Self_Referer & """>重新上传</a>]")
	end if
	Set UpForm = Nothing
	Set UpLoad = Nothing
	Case Else
	Dim OpenUpLoadProgress
	OpenUpLoadProgress = "false"
	If iXs.UpFileObject = 0 Then
		Randomize Timer()
		UpLoadPID = FormatTime(Now(), 1) & Clng(1000 + Rnd()*8999)
		Randomize Timer()
		OpenUpLoadProgress = "true"
	ElseIf iXs.UpFileObject = 1 Then
		on error resume next
		Dim UpLoadProgress
		Set UpLoadProgress = Server.CreateObject(ServerObject_012)
		UpLoadPID = UpLoadProgress.CreateProgressID()
		Set UpLoadProgress = Nothing
		OpenUpLoadProgress = "true"
		If Err Then
			Err.Clear
			OpenUpLoadProgress = "false"
		end if
	end if
	Response.write "<!--上传接口-->" & vbcrlf & " <table width=""100%"" border=""0"" cellpadding=""6"" cellspacing=""1"" bgcolor=""#C0CCDD"" id=""content"">" & vbcrlf & "        <tr><td><fieldset>" & vbcrlf & "                 <legend>上传需要导入的档案资料</legend>" & vbcrlf & "                 <form action=""UpLoad_bookData.asp?bgColor="
	OpenUpLoadProgress = "false"
	Response.write  bgColor
	Response.write "&Action=1&Wid="
	Response.write  Wid
	Response.write "&UpLoadPID="
	Response.write  UpLoadPID
	Response.write """ method=""post"" enctype=""multipart/form-data"" id=""UpLoad_Form"" onSubmit=""return apply()"">" & vbcrlf & "                         <input type=""hidden"" id=""upcount"" name=""upcount"" value=""1"" />" & vbcrlf & "                           <table width=""50%"" border=""0"" align=""center"" cellpadding=""2"" cellspacing=""0"">" & vbcrlf & "                                 <tr>" & vbcrlf & "                                            <td align=""left"">" & vbcrlf & "                                                 " & vbcrlf & "                                                        <input name=""Files"" type=""hidden"" id=""Files"" value="""" /></td>" & vbcrlf & "                                           <td align=""right"">&nbsp;</td>" & vbcrlf & "                                     </tr>" & vbcrlf & "                                   <tr>" & vbcrlf & "                                            <td align=""left"" id=""upid"">文件：" & vbcrlf & "                                                <input name=""strFile1"" type=""file"" id=""strFile1"" style=""width:200px;"" onChange=""return CheckUploadForm();"" size=""20"" /></td>" & vbcrlf & "                                          <td align=""left"" id=""upid""><input type=""submit"" id=""submit"" name=""submit"" value="" 导入 ""class=""page""  onclick=""return CheckUploadForm();"" /></td>" & vbcrlf & "                                     </tr>" & vbcrlf & "                                   <tr>" & vbcrlf & "                                            <td align=""left"">" & vbcrlf & "                                                 " & vbcrlf & "                                                        <input name=""Files"" type=""hidden"" id=""Files"" value="""" /></td>" & vbcrlf & "                                           <td align=""right"">&nbsp;</td>" & vbcrlf & "                                 </tr>" & vbcrlf & "                     </table>" & vbcrlf & "                      </form>" & vbcrlf & "                 </fieldset>" & vbcrlf & "                     </td>" & vbcrlf & "   </tr>" & vbcrlf & "</table>" & vbcrlf & "   <table width=""100%"" border=""0"" align=""left"" >" & vbcrlf & "  <tr>" & vbcrlf & "    <td height=""100"" class=""page""><div align=""center""></div></td> "& vbcrlf &   "  </tr> "& vbcrlf &" </table> "& vbcrlf & "<script type=""text/javascript""> "& vbcrlf &" <!-- "& vbcrlf &   "   var iframeids = [""UpLoad_Ad""]; "& vbcrlf &   "  var iframehide = ""yes""; "& vbcrlf &  "  var sAllowExt = "
	Response.write  UpLoadPID
	Response.write  FileAllowExt
	Response.write """;" & vbcrlf & "        var OpenUpLoadProgress = "
	Response.write  OpenUpLoadProgress
	Response.write "; // 是否开启上传进度条" & vbcrlf & "      var i = 0;" & vbcrlf & "      var n = 0;" & vbcrlf & "      var Obj01 = window.UpLoad_Form.upcount;" & vbcrlf & " var Obj02 = document.getElementById(""Files"");" & vbcrlf & "     function dyniframesize(){" & vbcrlf & "               var dyniframe=new Array();" & vbcrlf & "              for (i=0; i<iframeids.length; i++){" & vbcrlf & "                 if (parent.document.getElementById){" & vbcrlf & "                            dyniframe[dyniframe.length] = parent.document.getElementById(iframeids[i]);" & vbcrlf & "                             if (dyniframe[i] && !window.opera){" & vbcrlf & "                                     dyniframe[i].style.display=""block"";" & vbcrlf & "                                       if (dyniframe[i].contentDocument && dyniframe[i].contentDocument.body.offsetHeight){" & vbcrlf & "                                               dyniframe[i].height = dyniframe[i].contentDocument.body.offsetHeight;" & vbcrlf & "                                   }else if (dyniframe[i].Document && dyniframe[i].Document.body.scrollHeight){" & vbcrlf & "                                            dyniframe[i].height= dyniframe[i].Document.body.scrollHeight;" & vbcrlf & "                                 }" & vbcrlf & "                               }" & vbcrlf & "                       }" & vbcrlf & "                       if ((parent.document.all || parent.document.getElementById) && iframehide==""no""){" & vbcrlf & "                         var tempobj=parent.document.all? parent.document.all[iframeids[i]] : parent.document.getElementById(iframeids[i]);" & vbcrlf & "                            tempobj.style.display=""block"";" & vbcrlf & "                    }" & vbcrlf & "               }" & vbcrlf & "       }" & vbcrlf & "       " & vbcrlf & "        function setid(){" & vbcrlf & "               str='';" & vbcrlf & "         var MaxNum = "
	Response.write  FileUpMaxNum
	Response.write ";" & vbcrlf & "            if(!Obj01.value){Obj01.value = 1;}" & vbcrlf & "              if(Obj01.value == 0){Obj01.value = 1;}" & vbcrlf & "          if(Obj01.value > MaxNum){" & vbcrlf & "                       alert(""您最多只能同时上传 "" + MaxNum + "" 个文件!"");" & vbcrlf & "                 Obj01.value = MaxNum;" & vbcrlf & "                   setid();" & vbcrlf & "                }" & vbcrlf & "             else{" & vbcrlf & "                   for(n=1;n<=Obj01.value;n++){" & vbcrlf & "                            str += '文件';" & vbcrlf & "                          if(n < 10)(str += 0)" & vbcrlf & "                            str += n+'：<input type=""file"" name=""strFile' + n + '"" id=""strFile' + n + '"" style=""width:200px;"" onChange=""return CheckUploadForm();"" /><br>';" & vbcrlf & "                         window.upid.innerHTML = str;" & vbcrlf & "                    }" & vbcrlf & "                       dyniframesize();" & vbcrlf & "                }" & vbcrlf & "       }" & vbcrlf & "       function apply(){" & vbcrlf & "               try{" & vbcrlf & "                    // 检测并禁用文件域表单" & vbcrlf & "                 for(n = 1;n <= Obj01.value;n ++){" & vbcrlf & "                               document.getElementById(""strFile"" + n).readOnly = true;" & vbcrlf &       "                 } "& vbcrlf &         "              // 禁用提交表单 "& vbcrlf &            "      document.getElementById(""submit"").disabled = true; "& vbcrlf &                  "       // 禁用数目设置和按钮 "& vbcrlf &                "    document.getElementById(""upcount"").disabled = true; "& vbcrlf &                 "       document.getElementById(""setids"").disabled = true;" & vbcrlf & "                      // 打开进度条对话框" & vbcrlf & "                     if(OpenUpLoadProgress==true){" & vbcrlf & "                           return WinPop(""iXs_UpLoadProgress.asp?UpLoadPID="
	Response.write  UpLoadPID
	Response.write "&Files="" + Obj02.value, 430, 165);" & vbcrlf & "                        }" & vbcrlf & "               }" & vbcrlf & "               catch(e){};" & vbcrlf & "     }" & vbcrlf & "       // 生成弹出窗口" & vbcrlf & " function WinPop(url, width, height){" & vbcrlf & "            window.showModelessDialog(url, ""UpLoadProgress"",'dialogWidth=' + width + 'px; dialogHeight=' + height + 'px; resizable=no; help=no; scroll=no; status=no;') " & vbcrlf & "        }" & vbcrlf & "       // 是否有效的扩展名" & vbcrlf & "     function IsExt(url, opt){" & vbcrlf & "               var sTemp;" & vbcrlf & "              var b=false;" & vbcrlf & "            var s=opt.toUpperCase().split(""|"");" & vbcrlf & "               for (var i=0;i<s.length ;i++ ){" & vbcrlf & "                        sTemp=url.substr(url.length-s[i].length-1);" & vbcrlf & "                     sTemp=sTemp.toUpperCase();" & vbcrlf & "                      s[i]="".""+s[i];" & vbcrlf & "                    if (s[i]==sTemp){" & vbcrlf & "                               b=true;" & vbcrlf & "                         break;" & vbcrlf & "                  }" & vbcrlf & "               }" & vbcrlf & "               return b;" & vbcrlf & "       }"& vbcrlf & "      // 检测上传表单 检测扩展名是否有效" & vbcrlf & "      function CheckUploadForm() {" & vbcrlf & "            var Obj;" & vbcrlf & "                var tempstr;" & vbcrlf & "            Obj02.value = """"" & vbcrlf & "          for(n=1;n<=Obj01.value;n++){" & vbcrlf & "                    Obj = document.getElementById(""strFile"" + n);" & vbcrlf & "                     if(!IsExt(Obj.value, sAllowExt) && Obj.value!=""""){" & vbcrlf & "                         alert(""提示：\n\n第 【"" + n + ""】 个文件无效！\n\n请选择一个有效的文件，\n支持的格式有：\n"" + sAllowExt);" & vbcrlf & "                           Obj.style.border = ""2px solid #FF0000"";" & vbcrlf & "                           return false;" & vbcrlf & "                   }" & vbcrlf & "                       tempstr = Obj.value.replace(/.+?\\/gi, """"); "& vbcrlf &             "      if(Obj02.value==""""){ "& vbcrlf &               "                Obj02.value = tempstr; "& vbcrlf &       "            }else{ "& vbcrlf &               "            Obj02.value += ""|"" + tempstr; "& vbcrlf &          "            } "& vbcrlf &                 "       Obj.style.border = ""1px solid #000000""; "& vbcrlf &       "     } "& vbcrlf &            "    return true "& vbcrlf &  "    }" & vbcrlf & "    // 初始化框架高度" & vbcrlf & "       dyniframesize();" & vbcrlf & "//-->" & vbcrlf & "</script>"
	'Response.write  UpLoadPID
	End Select
	Function UpLoadSave(p_FileName, p_FilePath, p_FileSize, p_FileContentType, p_FileType, p_FileExt, p_FileWidth, p_FileHeight, p_PreviewPath)
		p_FilePath = Replace(p_FilePath, FileSavePath, "")
		p_FilePath = p_FilePath & p_FileName
		p_PreviewPath = Replace(p_PreviewPath, FilePrevPath, "")
		session("indatenamezbintel2007")=p_FilePath
		TempHtml = TempHtml & vbCRLF & "           parent.InsertFile(""{$UpLoadFileID}"", ""{$UpLoadFileName}"", ""{$UpLoadFilePath}"", {$UpLoadFileSize}, ""{$UpLoadFileContentType}"", {$UpLoadFileType}, ""{$UpLoadFileExt}"", {$UpLoadFileWidth}, {$UpLoadFileHeight}, ""{$UpLoadPreviewPath}"");"
		TempHtml = Replace(TempHtml, "{$UpLoadFileID}", FileID)
		TempHtml = Replace(TempHtml, "{$UpLoadFileName}", p_FileName)
		TempHtml = Replace(TempHtml, "{$UpLoadFilePath}", p_FilePath)
		TempHtml = Replace(TempHtml, "{$UpLoadFileSize}", p_FileSize)
		TempHtml = Replace(TempHtml, "{$UpLoadFileContentType}", p_FileContentType)
		TempHtml = Replace(TempHtml, "{$UpLoadFileType}", p_FileType)
		TempHtml = Replace(TempHtml, "{$UpLoadFileExt}", p_FileExt)
		TempHtml = Replace(TempHtml, "{$UpLoadFileWidth}", p_FileWidth)
		TempHtml = Replace(TempHtml, "{$UpLoadFileHeight}", p_FileHeight)
		TempHtml = Replace(TempHtml, "{$UpLoadPreviewPath}", p_PreviewPath)
	end function
	Response.write "<!--页脚代码-->" & vbcrlf & "</body>" & vbcrlf & "</html>"
	TempHtml = Replace(TempHtml, "{$UpLoadPreviewPath}", p_PreviewPath)
	
%>
