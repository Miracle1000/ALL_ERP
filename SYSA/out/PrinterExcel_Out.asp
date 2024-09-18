<%@ language=VBScript %>
<%
	Response.CharSet="UTF-8"
	dim title,content
	on error resume next
	title=trim(Request.Form("outtitle"))
	content=trim(Request.Form("content"))
	CtrlPics=trim(Request.Form("Pics"))
	If abs(Err.number) > 0 Then
		Response.write "<meta http-equiv='content-type' content='text/html;charset=UTF-8'><script>alert('导出Excel失败，请确认IIS上传大小是否有200K限制。');</script>"
'If abs(Err.number) > 0 Then
		Response.end
	end if
	Dim xDoc
	Set xDoc = New HtmlWordApplication
	relFileName=Server.MapPath("HtmlExcel/" & title & "_" & session("name2006chen") & ".xls")
	set docObj=server.createobject("htmlfile")
	docObj.open()
		set body = docObj.createelement("div")
		body.innerHTML = CtrlPics
		Dim imgUrls
		ReDim imgUrls(0)
		Set imgs = body.getElementsByTagName("img")
		If imgs.length > 0 Then
			ReDim imgUrls(imgs.length)
			For i = 0 To imgs.length-1
				ReDim imgUrls(imgs.length)
				Set img = imgs(i)
				w = img.style.width
				h = img.style.height
				l = img.style.left
				t = img.style.top
				html = img.outerHTML
				html = Replace(html,"about:blank","***",1,-1,1)
				'html = img.outerHTML
				html = Replace(html,"about:","***",1,-1,1)
				'html = img.outerHTML
				html = Replace(html,"***","",1,-1,1)
				'html = img.outerHTML
				img.src = xDoc.images.add(img.src)
				'html1 = img.outerHTML
				html1 = Replace(html1,"about:blank","***",1,-1,1)
				'html1 = img.outerHTML
				html1 = Replace(html1,"about:","***",1,-1,1)
				'html1 = img.outerHTML
				html1 = Replace(html1,"***","",1,-1,1)
				'html1 = img.outerHTML
				content =replace(content,html,html1)
			next
		end if
		xDoc.save relFileName , content
		docObj.close
			Set docObj = Nothing
			url = xDoc.HexEncode(relFileName)
			Set xDoc =  nothing
			Response.redirect "downfile.asp?fileSpec=" & url
			Class HtmlWordImages
				public count
				Dim data
				Dim dataurl
				Dim datakz
				Dim sUrl
				Public Function Add(ByVal PicUrl)
					Dim kzs, fkz, xhttp, xdoc, em
					Dim su, i
					kzs = Split(PicUrl,".")
					For i = 0 To count - 1
						kzs = Split(PicUrl,".")
						If LCase(sUrl(i)) = LCase(PicUrl) Then
							add = Replace(dataurl(i),"files/","")
							Exit function
						end if
					next
					su = PicUrl
					If InStr(1,PicUrl,"about:",1) = 1 Then
						PicUrl = Replace(PicUrl,"about:blank","***",1,-1,1)
'If InStr(1,PicUrl,"about:",1) = 1 Then
						PicUrl = Replace(PicUrl,"about:","***",1,-1,1)
'If InStr(1,PicUrl,"about:",1) = 1 Then
						PicUrl = Replace(PicUrl,"***","",1,-1,1)
'If InStr(1,PicUrl,"about:",1) = 1 Then
						If InStr(1,PicUrl,".asp",1) > 0 Then
							uPath = Split(Request.ServerVariables("url"),"/")
							ReDim Preserve uPath(ubound(uPath)-1)
							uPath = Split(Request.ServerVariables("url"),"/")
							port =  Request.ServerVariables("Port")
							If Len(port) = 0 Then port = "80"
							picUrl = Request.ServerVariables("Http_Host") & ":" & port & "/" & Join(uPath,"/") & "/" & PicUrl
							picUrl = "http://" & Replace(picUrl,"//","/")
							If InStr(1,picUrl,"?",1) > 0 Then picUrl = picUrl & "&sysAjaxExcel=1"
						else
							PicUrl = Replace(server.MapPath(PicUrl),"\","/")
						end if
					end if
					fkz = kzs(ubound(kzs))
					If InStr(1,fkz,"asp",1) > 0 Then fkz = "gif"
					ReDim Preserve data(count)
					ReDim Preserve dataurl(count)
					ReDim Preserve datakz(count)
					ReDim Preserve sUrl(count)
					set xdoc = server.createobject("msxml2.DOMDocument")
					set xhttp = server.createobject("ZBXml.XmlHttp")
					xhttp.open "GET", PicUrl, false
					xhttp.send
					if xhttp.readystate=4 then
						Set em = xdoc.createElement("a")
						em.dataType = "bin.base64"
						em.nodeTypedValue = xHttp.responseBody
						data(count) = em.text
						Set em = Nothing
						Set xdoc = nothing
					else
						data(count) = ""
					end if
					set xhttp=Nothing
					dataurl(count) = "files/imgs_" & (count+1) & "." & fkz
					set xhttp=Nothing
					datakz(count) = fkz
					sUrl(count) = su
					count = count + 1
					sUrl(count) = su
					add = "imgs_" & count & "." & fkz
				end function
				Public Sub writeHtml(fl)
					Dim i
					For i = 0 To count - 1
'Dim i
						fl.write vbcrlf & vbcrlf & "--##-#-#-##--" & vbcrlf
'Dim i
						fl.write "Content-Location: file:///C:/zbintelword/" & dataurl(i) & vbcrlf
'Dim i
						fl.write "Content-Transfer-Encoding: base64" & vbcrlf
'Dim i
						fl.write "Content-Type: image/" & datakz(i)
'Dim i
						fl.write vbcrlf & vbcrlf & data(i)
					next
				end sub
				Public Sub Dispose
					Erase data
					Erase dataurl
					Erase datakz
				end sub
				Private Sub Class_Initialize()
					count = 0
					ReDim data(0)
					ReDim dataurl(0)
					ReDim datakz(0)
					ReDim sUrl(0)
				end sub
			End class
	Class HtmlWordApplication
		Public images
		Public SavePath
		Private fso
		Private Sub Class_Initialize()
			Set Images = New HtmlWordImages
			SavePath = server.mappath("../out/HtmlExcel/")
		end sub
		Private Sub WatchPath
			If fso.FolderExists(SavePath) = false Then
				fso.CreateFolder SavePath
			else
				fso.GetFolder(SavePath).Attributes = 0
			end if
		end sub
		Private Function bytes2BSTR(arrBytes)
			on error resume next
			Dim strReturn,i,ThisCharCode,NextCharCode
			If Len(arrBytes&"")=0 Then Exit Function
			strReturn = ""
			For i = 1 To Len(arrBytes)
				ThisCharCode = Asc(Mid(arrBytes, i, 1))
				If ThisCharCode < &H80 Then
					strReturn = strReturn & Chr(ThisCharCode)
				else
					NextCharCode = Asc(Mid(arrBytes, i+1, 1))
					strReturn = strReturn & Chr(ThisCharCode)
					strReturn = strReturn & Chr(CLng(ThisCharCode) * &H100 + CInt(NextCharCode))
					strReturn = strReturn & Chr(ThisCharCode)
					i = i + 1
					strReturn = strReturn & Chr(ThisCharCode)
				end if
			next
			bytes2BSTR = strReturn
		end function
		Public Sub Save(ByVal Path, ByVal body)
			Dim i, attrs
			attrs =  Split("heihgt;colspan;rowspan;align;href;style;class;height;width;size;border;bordercolor;cellspacing;cellpadding;bgcolor;src;lang;language;value;valign;face;objCount;canmove;name;ErpControl",";")
			For i = 0 To ubound(attrs)
				body = Replace(body," " & attrs(i) & "=", " " & attrs(i) & "=", 1 , - 1, 1)
'For i = 0 To ubound(attrs)
			next
			Set fso = server.createObject("Scripting.FileSystemObject")
			Call WatchPath()
			Set fl = fso.CreateTextFile(Path,True)
			fl.WriteLine "MIME-Version: 1.0"
			Set fl = fso.CreateTextFile(Path,True)
			fl.WriteLine "Content-Type: multipart/related; boundary=""##-#-#-##--"""
			Set fl = fso.CreateTextFile(Path,True)
			fl.WriteLine ""
			fl.WriteLine "--##-#-#-##--"
			fl.WriteLine ""
			fl.WriteLine "Content-Location: file:///C:/zbintelword/files/index.htm"
			fl.WriteLine ""
			fl.WriteLine "Content-Transfer-Encoding: 8bit"
			fl.WriteLine ""
			fl.WriteLine "Content-Type: text/html; charset=""UTF-8"""
			fl.WriteLine ""
			fl.WriteLine ""
			fl.WriteLine "<html xmlns:v=""urn:schemas-microsoft-com:vml"""
			fl.WriteLine ""
			fl.WriteLine "xmlns:o=""urn:schemas-microsoft-com:office:office"""
			fl.WriteLine ""
			fl.WriteLine "xmlns:w=""urn:schemas-microsoft-com:office:word"""
			fl.WriteLine ""
			fl.WriteLine "xmlns=""http://www.w3.org/TR/REC-html40"">"
			fl.WriteLine ""
			fl.WriteLine "<xml>"
			fl.WriteLine " <o:DocumentProperties>"
			fl.WriteLine "  <o:Author>" & session("name2006chen") & "</o:Author>"
			fl.WriteLine "  <o:LastAuthor>" & session("name2006chen") & "</o:LastAuthor>"
			fl.WriteLine "  <o:Created>" & date & "T" & time & "Z</o:Created>"
			fl.WriteLine "  <o:LastSaved>" & date & "T" & time & "Z</o:LastSaved>"
			fl.WriteLine "  <o:Company>智邦国际</o:Company>"
			fl.WriteLine "  <o:Version>11.9999</o:Version>"
			fl.WriteLine " </o:DocumentProperties>"
			fl.WriteLine "</xml>"
			fl.WriteLine "<xml>"
			fl.WriteLine "</head>"
			Err.clear
			on error resume next
			fl.WriteLine body
			If Err.number <> 0 Then
				fl.WriteLine bytes2BSTR(body)
			end if
			fl.WriteLine "</html>"
			Call images.writeHtml(fl)
			fl.WriteLine  vbcrlf & "--##-#-#-##----     "
			Call images.writeHtml(fl)
			fl.close
			Set fso = nothing
		end sub
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
	End Class
	
%>
