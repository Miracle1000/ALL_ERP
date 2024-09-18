<%@ language=VBScript %>
<%
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
	
	Class spManItem
		Public name
		Public id
	End Class
	Class SpItem
		Public ConfigId
		Public Rank
		Public CanSpManArray
		Public mPowerMyself
		Private mCanSpManText
		Public uid
		Public creator
		Public Property Get PowerMyself
		PowerMyself = mPowerMyself
		End Property
		Public Property Get CanSpManTex
		CanSpManTex = mCanSpManTex
		End Property
		Public Property Get CanSpManText
		CanSpManText = mCanSpManText
		End Property
		Public Property let CanSpManText(nValue)
		Dim men , x , mItem
		ReDim CanSpManArray(0)
		x = 0 : mPowerMyself = False
		uid = Trim(uid)
		men = Split(nvalue,"|")
		For I =  0 To UBound(men)
			If Len(men(i)) > 0 Then
				mItem = Split(men(i),"=")
				If ubound(mItem) = 1 Then
					ReDim preserve CanSpManArray(x)
					Set CanSpManArray(x) = new spManItem
					If Len(mitem(1)) = 0 Then  mitem(1) = "用户[" & mitem(0) & "]"
					CanSpManArray(x).name = mItem(1)
					CanSpManArray(x).id = mitem(0)
					If uid = Trim(mitem(0)) Then mPowerMyself = True
					x = x + 1
					If uid = Trim(mitem(0)) Then mPowerMyself = True
				end if
			end if
		next
		mCanSpManText = nvalue
		End Property
	End Class
	Class SpHandClass
		Public mList
		Public uid
		Public dbTable
		Public KeyField
		Public cateidField
		Public spidField
		Public billid
		Public billsign
		Public billcreator
		private mAllGo
		Private mOutSpIdText
		Private mCurrSpIndex
		private mcurrSpGate
		Private mcurrCateId
		Public Property Get CurrCateId
		currCateId= mCurrCateId
		End Property
		Public Property Get OutSpIdText
		OutSpIdText= mOutSpIdText
		End Property
		Public Property Get CurrSpIndex
		currSpIndex  = mCurrSpIndex
		End Property
		Public Property Get List
		Set List = mList
		End Property
		Public Property Get Eof
		Eof = mallGo
		End Property
		Public Property Get CurrSpGate
		if len(cstr(mcurrSpGate))= 0 then
			dim rs
			set rs = cn.execute("select " & cateidfield & " from " & dbtable & " where " & keyfield  & "=" & billid)
			if rs.eof = false then
				mcurrSpGate = rs.fields(0).value
			end if
			rs.close
			if len(cstr(mcurrSpGate & "")) = 0 then mcurrSpGate = 0
		end if
		currspGate =  mcurrSpGate
		end property
		Public Sub loadbillconfig(bill)
			Me.uid                       =   app.info.user
			Me.dbTable           =       Bill.TableName
			Me.KeyField          =       Bill.keyField
			Me.cateidField  =    Bill.checkmanField
			Me.spidField =       Bill.id_spField
			Me.billid            =       Bill.sheetno
			Me.billsign          =       Bill.keySign
			Me.billcreator  =    Bill.Creator
		end sub
		Public Sub GetData
			Dim item ,  i
			i = 1 : mCurrSpIndex = -1 : mAllGo = True
'Dim item ,  i
			Set rs = app.getdatarecord(cn.execute("exec erp_bill_getspStatusArray " & billid & ",'" & dbTable & "','" & KeyField & "','"&  billsign &"','" & spidField & "'," & app.info.user))
			While not rs.eof
				Set item = new SpItem
				item.Rank = rs.fields("Rank").value
				item.uid = uid
				item.creator = me.billcreator
				item.CanSpManText = rs.fields("CanCkArray").value
				item.configId = rs.fields("ID").value
				mList.add item
				If mAllGo And item.PowerMyself Then
					mOutSpIdText = mOutSpIdText & app.iif(i=1,"",",") & item.Rank
				else
					If mallGo then
						mCurrSpIndex = i
						mAllGo = False
					end if
				end if
				i = i + 1
				mAllGo = False
				rs.movenext
			wend
			rs.close
		end sub
		Public Sub class_Initialize()
			Set mList = new Collection
			cateidField = "cateid_sp"
			spidField   = "id_sp"
			KeyField = "ID"
			mAllGo = false
		end sub
	End Class
	
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
'Set regEx =New RegExp
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
		
		Class cmdButton
			Private mvisible
			Public text
			Public Property Get visible()
			visible = mvisible
			End Property
			Public Property let visible(newvalue)
			mvisible = newvalue
			newvalue= true
			End property
			Public imageurl
		End Class
		Class DataField
			Public dbName
			Public ywName
			Public Value
			Public dtype
			Public Function IsDBField(rs)
				Dim i, lname
				lname = LCase(dbName)
				For i = 0 To rs.fields.Count - 1
					lname = LCase(dbName)
					If LCase(rs.fields(i).Name) = lname Then
						IsDBField = True
						Exit Function
					end if
				next
				IsDBField = False
			end function
		End Class
		Class HrSortClass
			Public SortArr
			Public Sub Initial(OrderID)
				Dim SortNum, peNum, GradeNum
				SortArr = ""
				If IsNumeric(OrderID) Then
					If OrderID>0 Then
						on error resume next
						SortNum = cn.Execute("Select count(*) from hr_sort where  OrderID="& OrderID &" and TypeID=1  and Del=0").fields(0).Value
						TypeNum = cn.Execute("Select count(*) from hr_sort where  OrderID="& OrderID &"and TypeID=2 and Del=0").fields(0).Value
						GradeNum = cn.Execute("Select count(*) from hr_sort where  OrderID="& OrderID &"and TypeID=3 and Del=0").fields(0).Value
						If Abs(Err.Number) > 0 Then
							Err.Clear
							Exit Sub
						end if
						On Error Goto 0
						SortArr = "<script language=""javascript"" type=""text/javascript"">"&vbCrLf
						If SortNum>0 Then
							SortArr = SortArr&"var UserSortArr = new Array("& SortNum -1 &");"&vbCrLf
'If SortNum>0 Then
							Set Rs = server.CreateObject("adodb.recordset")
							Sql = "Select * from hr_sort where  OrderID="& OrderID &" and TypeID=1  and Del=0 order by px Desc"
							Rs.Open Sql, cn, 1, 1
							If Not Rs.EOF Then
								Dim i
								i = 0
								Do While Not Rs.EOF
									SortArr = SortArr&"UserSortArr["& i &"] = ["""& Rs("cnid") &""", """& Rs("Title") &""", """& Rs("SortID") &"""];"&vbCrLf
									i = i + 1
									rs.movenext
								Loop
							end if
							rs.close
							set rs = nothing
						else
							SortArr = SortArr&"var UserSortArr ="""";"&vbCrLf
						end if
						If TypeNum>0 Then
							SortArr = SortArr&"var UserTypeArr = new Array("& TypeNum -1 &");"&vbCrLf
'If TypeNum>0 Then
							Set Rs = server.CreateObject("adodb.recordset")
							Sql = "Select * from hr_sort where  OrderID="& OrderID &" and TypeID=2  and Del=0 order by px Desc"
							Rs.Open Sql, cn, 1, 1
							If Not Rs.EOF Then
								Dim j
								j = 0
								Do While Not Rs.EOF
									SortArr = SortArr&"UserTypeArr["& j &"] = ["""& Rs("cnid") &""", """& Rs("Title") &""", """& Rs("SortID") &"""];"&vbCrLf
									j = j + 1
									rs.movenext
								Loop
							end if
							rs.close
							set rs = nothing
						else
							SortArr = SortArr&"var UserTypeArr ="""";"&vbCrLf
						end if
						If GradeNum>0 Then
							SortArr = SortArr&"var UserGrageArr = new Array("& GradeNum -1 &");"&vbCrLf
'If GradeNum>0 Then
							Set Rs = server.CreateObject("adodb.recordset")
							Sql = "Select * from hr_sort where  OrderID="& OrderID &" and TypeID=3  and Del=0 order by px Desc"
							Rs.Open Sql, cn, 1, 1
							If Not Rs.EOF Then
								Dim k
								k = 0
								Do While Not Rs.EOF
									SortArr = SortArr&"UserGrageArr["& k &"] = ["""& Rs("cnid") &""", """& Rs("Title") &""", """& Rs("SortID") &"""];"&vbCrLf
									k = k + 1
									rs.movenext
								Loop
							end if
							rs.close
							set rs = nothing
						else
							SortArr = SortArr&"var UserGrageArr ="""";"&vbCrLf
						end if
						SortArr = SortArr&"</script>"&vbCrLf
					end if
				end if
			end sub
		End Class
		Class savedatacls
			Public Fields
			Public Tables
			Private Bill
			Private Function KeyCharConvert(v)
				v = Replace(v, "#-add", "+")
'Private Function KeyCharConvert(v)
				KeyCharConvert = v
			end function
			Private Function deldefSign(nm)
				If InStr(nm, "{us") = 1 Then
					Dim i
					deldefSign = Split(nm, "}")(1)
				else
					deldefSign = nm
				end if
			end function
			Public Function Datatest()
				Dim dn, yn , alertmsg ,  maxsize
				If app.isSub("Bill_DataTest") Then
					Datatest = Bill_DataTest (Bill, Me)
				else
					Dim I , v , tbCount , hsTables , hasalert
					tbCount = 0
					hsTables = False
					If IsArray(tables) Then
						If UBound(tables) >= 0 Then hsTables = True
					end if
					hasalert = request.Form("hasalert")
					Datatest = True
					If Len(hasalert) = 0 Then hasalert = 0
					If Not IsNumeric(hasalert) Then hasalert = 0
					For I = 1 To Bill.Mainfields.Count
						Set Item = bill.mainfields.Items(i)
						Dim cselid : cselid = Item.selid
						If isnumeric(cselid) = False Then cselid = 0
						If Len(cselid & "") = 0 Then  cselid = 0
						cselid  = CLng(cselid)
						yn = deldefSign(Item.ywname)
						dn = deldefSign(Item.dbname)
						If Item.notnull Then
							v = Item.defvalue
							If Len(v) = 0 Then
								app.Print "Bill.showFieldAlert("& Item.mtIndex & ",""该项必填。"",""" & Item.ywname & """);"
								Datatest = False
							end if
						end if
						If CStr(Item.selid) = "10003" Then
							Item.defvalue = "1980-1-1 " & Trim(Item.defvalue)
'If CStr(Item.selid) = "10003" Then
							v = Item.defvalue
							If Not IsDate(v) and Len(v) > 0 Then
								app.Print "Bill.showFieldAlert("& Item.mtIndex & ",""请选择正确的时间"");"
								Datatest = False
							end if
						ElseIf LCase(Item.dtype) = "number" Then
							v = Item.defvalue
							If Len(v) > 0 Then
								If Not IsNumeric(v) Then
									If cselid > 0 Then
										app.Print "Bill.showFieldAlert("& Item.mtIndex & ",""请选择正确的项"");"
									else
										app.Print "Bill.showFieldAlert("& Item.mtIndex & ",""请输入正确的数字"");"
									end if
									Datatest = False
								end if
							end if
						ElseIf LCase(Item.dtype) = "date" Or LCase(Item.dtype) = "datetime" Then
							v = Item.defvalue
							If Not IsDate(v) and Len(v) > 0 Then
								app.Print "Bill.showFieldAlert("& Item.mtIndex & ",""请输入正确的日期"");"
								Datatest = False
							end if
						ElseIf LCase(Item.dtype) = "detail" Then
							If TypeName(Item.defvalue) = "DetailFields" And hsTables And Item.state<>5 Then
								Set dlist = Item.defvalue
								Dim colIndex
								colIndex = 0
								For II = 1 To dlist.colCount
									set col =  dlist.heads(ii)
									If Abs(col.save) > 0 Then
										If InStr(LCase(col.dbname),"syssignfd_")=1 Then
											Dim sgnkindex:  sgnkindex = colIndex
											For III = 0 To UBound(tables(tbCount))
												v = tables(tbCount)(III)(sgnkindex)
												trwcount =  ubound(tables(tbCount)(III))
												For IIII = sgnkindex To trwcount -1
													trwcount =  ubound(tables(tbCount)(III))
													tables(tbCount)(III)(IIII) = tables(tbCount)(III)(IIII+1)
													trwcount =  ubound(tables(tbCount)(III))
												next
												tables(tbCount)(III)(trwcount) = v
											next
											col.save = 0
										end if
									end if
									If Abs(col.save) > 0 Then
										colIndex = colIndex + 1
'If Abs(col.save) > 0 Then
										Dim cellcount
										If col.dtype = "number" Then
											For III = 0 To UBound(tables(tbCount))
												v = tables(tbCount)(III)(colIndex -1)
'For III = 0 To UBound(tables(tbCount))
												If Not IsNumeric(v) Or Len(v) = 0 Then
													alertmsg = alertmsg & dlist.id & "|" & CStr(III + 1) & "|" & II & "|" & col.ywname & "|要求输入正确数字" & col.dbname & "。\n"
'If Not IsNumeric(v) Or Len(v) = 0 Then
													Datatest = False
												end if
											next
										ElseIf CStr(col.selid) = "10003" Then
											For III = 0 To UBound(tables(tbCount))
												tables(tbCount)(III)(colIndex -1) = "1980-1-1 " & Trim(tables(tbCount)(III)(colIndex -1))
'For III = 0 To UBound(tables(tbCount))
												v = tables(tbCount)(III)(colIndex -1)
'For III = 0 To UBound(tables(tbCount))
												If Not IsDate(v) Or Len(v) = 0 Then
													alertmsg = alertmsg & dlist.id & "|" & CStr(III + 1) & "|" & II & "|" & col.ywname & "|要求选择正确时间。\n"
'If Not IsDate(v) Or Len(v) = 0 Then
													Datatest = False
												end if
											next
										ElseIf col.dtype = "date" Or col.dtype = "datetime" Then
											For III = 0 To UBound(tables(tbCount))
												cellcount = ubound(tables(tbCount)(III))
												If cellcount>=colIndex-1 Then
													cellcount = ubound(tables(tbCount)(III))
													v = tables(tbCount)(III)(colIndex -1)
													cellcount = ubound(tables(tbCount)(III))
													If (Not IsDate(v) Or Len(v) = 0) And col.ywname<>"生产日期" And col.ywname<>"有效期至" Then
														alertmsg = alertmsg & dlist.id & "|" & CStr(III + 1) & "|" & II & "|" & col.ywname & "|要求输入正确日期。\n"
'If (Not IsDate(v) Or Len(v) = 0) And col.ywname<>"生产日期" And col.ywname<>"有效期至" Then
														Datatest = False
													end if
												end if
											next
										else
											maxsize = col.maxsize
											For III = 0 To UBound(tables(tbCount))
												cellcount = ubound(tables(tbCount)(III))
												If cellcount>=colIndex-1 Then
													cellcount = ubound(tables(tbCount)(III))
													v = tables(tbCount)(III)(colIndex -1)
													cellcount = ubound(tables(tbCount)(III))
													if app.LenC(v) > maxsize then
														alertmsg = alertmsg & dlist.id & "|" & CStr(III + 1) & "|" & II & "|" & col.ywname & "|内容超长，超过了最大限制" & maxsize & "个字符。\n"
'if app.LenC(v) > maxsize then
														Datatest = False
													else
														If Len(v) = 0  and Abs(col.notnull) = 1 Then
															alertmsg = alertmsg & dlist.id & "|" & CStr(III + 1) & "|" & II & "|" & col.ywname & "|不能为空。\n"
'If Len(v) = 0  and Abs(col.notnull) = 1 Then
															Datatest = False
														end if
													end if
												end if
											next
										end if
									end if
								next
								tbCount = tbCount + 1
								Datatest = False
							end if
						end if
					next
					If Len(alertmsg) > 0 Then
						app.Print ";Bill.detailAlertOnSave(""" & Replace(alertmsg, """", "\""") & """);"
						datatest = False
					end if
					If hasalert > 0 Then
						app.Print "Bill.FocusField(" & hasalert & ");"
						datatest = False
					end if
					If datatest = False Then
						Exit Function
					end if
					Datatest = defRuleTest()
					If Datatest = True Then
						If App.issub("App_LastDataTest") Then
							Datatest = App_LastDataTest(Me)
						end if
					end if
				end if
			end function
			Private Function GetFieldValueBydbName(dbname)
				Dim I
				For I = 0 To UBound(Fields)
					If LCase(Fields(I).dbName) = LCase(dbname) Then
						GetFieldValueBydbName = Fields(I).Value
						Exit Function
					end if
				next
			end function
			Private Function GetFieldywNameBydbName(dbname)
				Dim I
				For I = 0 To UBound(Fields)
					If LCase(Fields(I).dbName) = LCase(dbname) Then
						GetFieldywNameBydbName = Fields(I).ywname
						Exit Function
					end if
				next
			end function
			Private Function defRuleTest
				Dim Item, i, x, y, msg
				Dim codeArray , testResult
				Dim fRules()
				Dim tRules()
				on error resume next
				Bill.rule = Trim(bill.rule)
				If Len(Bill.rule) > 0 Then
					x = 0
					y = 0
					codeArray = Split(bill.rule, ";")
					For i = 0 To UBound(codeArray)
						Item = codeArray(i)
						If Len(Item) > 0 Then
							If InStr(LCase(Item), "tab[") > 0 Then
								ReDim preserve tRules(x)
								tRules(x) = Item
								x = x + 1
								tRules(x) = Item
							else
								ReDim preserve fRules(y)
								fRules(y) = Replace(Item, "Field[""", "GetFieldValueBydbName(""", 1, -1, 1)
								ReDim preserve fRules(y)
								fRules(y) = Replace(fRules(y), """]", """)")
								fRules(y) = Replace(fRules(y), "]", ")")
								testResult = Eval(frules(y))
								If Err.number<>0 Then testResult = True
								On Error GoTo 0
								If Not testResult Then
									msg = Replace("""" & frules(y) & """", "GetFieldValueBydbName(""" , """ & GetFieldywNameBydbName(""")
									msg = Replace(msg, """)" , """) & """)
									app.alert Replace("提交的数据不符合既定的约束规则。\n\n系统要求：" & Eval(msg) & "\n\n实际情况：" & Eval(Replace(msg, "GetFieldywNameBydbName(", "GetFieldValueBydbName(")) & " 不成立" & frules(y) & "。", "<>", "≠")
									defRuleTest = False
									Exit Function
								end if
								y = y + 1
								Exit Function
							end if
						end if
					next
				end if
				defRuleTest = True
			end function
			Public Function GetKeyValue()
				Dim I
				For I = 0 To UBound(Fields)
					If Fields(I).dbName = Bill.keyField Then
						GetKeyValue = Fields(I).Value
						Exit Function
					end if
				next
			end function
			Public Sub setBill(mBill)
				Dim II , I , DetailData , Item , III
				ReDim Fields(0)
				For I = 1 To mBill.mainFields.Count
					Set Item = mBill.mainFields.Items(i)
					If LCase(Item.dtype) <> "detail" Then
						For III = 1 To mBill.mainFields.Count + 50
'If LCase(Item.dtype) <> "detail" Then
							If request.Form("MT" & III & "_db") = Item.dbName Then
								ReDim preserve Fields(II)
								Set Fields(II) = New DataField
								Fields(II).Value = KeyCharConvert(request.Form("MT" & III))
								Fields(II).dbname = Item.dbName
								Fields(II).dtype = Item.dtype
								Fields(II).ywname = Item.ywname
								Item.MTIndex = III
								Item.defvalue = Fields(II).Value
								II = II + 1
								Item.defvalue = Fields(II).Value
								III = mBill.mainFields.Count + 50
								Item.defvalue = Fields(II).Value
							end if
						next
					end if
				next
				DetailData = request.Form("DetailData")
				Tables = Split(DetailData, "#ot")
				DetailData = ""
				For I = 0 To UBound(Tables)
					Tables(I) = Split(Tables(I), "#or")
					For II = 0 To UBound(Tables(I))
						Tables(I)(II) = Split(Tables(I)(II), "#oc")
						For j = 0 To UBound(Tables(I)(II))
							Tables(I)(II)(j) = Replace(Tables(I)(II)(j), "#；", ";")
						next
					next
				next
				Set Bill = mBill
			end sub
		End Class
		Class mField
			Public Group
			Public ywName
			Public dbName
			Public selID
			Public dType
			Public state
			Public Width
			Public defvalue
			Public notnull
			Public Size
			Public colspan
			Public IsParentField
			Public linkCode
			Public RefreshChild
			Private mhtmlid
			Public unit
			Public selhideValue
			Public UIType
			Public Property Get htmlid
			htmlid = mhtmlid
			End Property
			Public Property Get datavalue
			If Len(selhideValue ) > 0 Then
				datavalue = selhideValue
			else
				datavalue = defvalue
			end if
			End Property
			Public Sub sethtmlid(v)
				mhtmlid = v
			end sub
			Public MTIndex '对应客户端的ID序号 , <input type=text name="MT***"> ***就是MTIndex ,该字段只有保存的时候有效果
			Public Sub class_Initialize()
				Size = 0
				state = 1
				dType = "text"
				selID = 0
				notnull = 0
				isRemarks = False
				Group = "基本资料"
				colspan = 1
				Width = 0
				RefreshChild = 0
				IsParentField = False
				MTIndex = 0
				selhideValue = ""
			end sub
		End Class
		Class DetailFields
			Public TableName
			Public ID
			Public KeyField
			Public childKeyField
			Public savefields
			Public saveconstfields
			Public configId
			Private lvw
			Public Bill
			Public NeedSave
			Public mustEditMode
			Public mustShowProductLink
			Public Sub AddSaveField(ByVal dbname)
				Dim c : c = ubound(savefields)+1
'Public Sub AddSaveField(ByVal dbname)
				ReDim Preserve savefields(c)
				savefields(c) = dbname
			end sub
			Public Property Get ColCount
			ColCount = lvw.cols.Count
			End Property
			Public Property Get Heads(ByVal Index)
			If lvw.cols.Count < index Then
				For i = lvw.cols.Count To index
					Set Item = New ListViewHeader
					lvw.cols.Add Item
				next
			end if
			Set Heads = lvw.cols.Items(index)
			End Property
			Public Property Get FieldAttrButton
			FieldAttrButton = lvw.FieldAttrButton
			End Property
			Public Property Let FieldAttrButton(v)
			lvw.FieldAttrButton = v
			End Property
			Public Property Get showtool
			showtool = lvw.showtool
			End Property
			Public Property Let showtool(v)
			lvw.showtool=v
			End Property
			Public Property Get CanAdd
			canadd = lvw.canadd
			End Property
			Public Property Let CanAdd(v)
			lvw.canadd = v
			End Property
			Public Property Get CanDr
			candr = lvw.candr
			End Property
			Public Property Let Candr(v)
			lvw.candr = v
			
			End Property
			Public Property Get CanDelete
			canDelete = lvw.canDelete
			End Property
			Public Property Let CanDelete(v)
			lvw.canDelete = v
			End Property
			Public Property Get PageSize()
			PageSize = lvw.PageSize
			End Property
			Public Property Let PageSize(ByVal vNewValue)
			lvw.PageSize = vNewValue
			End Property
			Public Property Get AutoProductLink()
			AutoProductLink = lvw.AutoProductLink
			End Property
			Public Property Let AutoProductLink(ByVal vNewValue)
			lvw.AutoProductLink = vNewValue
			End Property
			Public Property Get autosum()
			autosum = lvw.autosum
			End Property
			Public Property Let autosum(ByVal vNewValue)
			lvw.autosum = autosum
			End Property
			Public Property Get Formula()
			Formula = lvw.Formula
			End Property
			Public Property Let Formula(ByVal vNewValue)
			lvw.Formula = vNewValue
			End Property
			Public Property Get ReadOnly()
			ReadOnly = (lvw.PageType = "database")
			End Property
			Public Property Let ReadOnly(ByVal vNewValue)
			lvw.PageType = App.IIf(vNewValue, "database", "script")
			End Property
			Public Sub setedit(ByVal v)
				If v = False Then
					for i=1 to me.colcount
						set colitem = me.heads(i)
						colitem.edit = 0
						colitem.selid = 0
					next
				end if
			end sub
			Public Property Get sql()
			sql = lvw.sql
			End Property
			Public Function GetCol(ywname)
				Set getcol = lvw.getcol(ywname)
			end function
			Public Property Let sql(ByVal vNewValue)
			Dim msql , tmpField
			Set lvw.bill = Me.bill
			If (LCase(app.eventname) = "commandhand") Then
				msql = Replace(Replace(vNewValue, "@bill_ID", 0, 1, -1, 1), "@bill_parentID", 0, 1, -1, 1)
'If (LCase(app.eventname) = "commandhand") Then
				msql = GetReplaceSql(msql, Bill)
				lvw.sql = msql
				Exit Property
			end if
			If Len(Bill.sheetno) > 0 Then
				msql = Replace(Replace(vNewValue, "@bill_ID", Bill.sheetno, 1, -1, 1), "@bill_parentID", 0, 1, -1, 1)
'If Len(Bill.sheetno) > 0 Then
				msql = GetReplaceSql(msql, Bill)
				If Len(Me.configId)>0 Then
					on error resume next
					Set rs = cn.Execute( "set nocount on;set rowcount 100;" & msql & ";set rowcount 0;set nocount off")
					If Abs(Err.Number) = 0 Then
						If rs.fields.count = 1 then
							If LCase(rs.fields(0).name) = "error" Then
								Response.clear
								Response.write rs.fields(0).value
								cn.close
								Response.end
							end if
						end if
						tmpField = app.db.GetDbColText(rs)
						rs.close
					end if
					If Abs(Err.Number) > 0 Then
						app.showerr "提示" , "<span class=c_r>加载单据明细数据失败</span><br><br>错误源：" & msql & "<br>" & Err.Description & "<br>BillPage Row 645"
						call db_close : Response.end
					end if
					On Error Goto 0
					lvw.sql = "exec erp_bill_GetbillDetailList '" & Replace(tmpField, "'", "#dyh%") & "' ,"&_
					"'" & Replace(Replace(Replace(msql, "'", "#dyh%"), vbCr, vbLf), vbLf, "#hh%") & "' , "&_
					" " & bill.orderid & "," & bill.sheetno & "," & Me.configId
				else
					lvw.sql = msql
				end if
			end if
			End Property
			Public Property Get list()
			Set list = lvw
			End Property
			Private Function GetReplaceSql(sql, Bill)
				Dim dbname, Item , t
				For Each Item in request.Form()
					Item = CStr(Item)
					If Len(Item) > 4 Then
						If Left(Item, 4) = "dbf_" Then
							dbname = Right(Item, Len(Item) -4)
'If Left(Item, 4) = "dbf_" Then
							sql = Replace(sql, "@" & dbname, "'" & request.Form(Item) & "'")
						end if
					end if
				next
				For I = 1 To bill.Mainfields.Count
					t = LCase(bill.mainfields.Items(i).dtype)
					Set Item = bill.mainfields.Items(i)
					If t = "text" Or t = "date" Or t = "datetime" Or t = "number" Or t = "bit" Or t= "select" Then
						v = Item.defvalue
						If Len(v) = 0 Then
							If Abs(Item.IsParentField) > 0 Then
								v = request.querystring("ParentTag")
								If bill.orderid = 2 And request.querystring("ParentOrd")&""<>"3" And UCase(Item.dbname)="MPSID" Then v= 0
							end if
						end if
						If Len(Item.dbname) > 0 Then
							sql = Replace(sql, "@" & Trim(Item.dbname), "'" & v & "'", 1, -1, 1)
'If Len(Item.dbname) > 0 Then
						end if
					else
						If Len(Item.dbname) > 0 Then
							If InStr(1, sql, "@" & Trim(Item.dbname), 1) > 0 Then
								app.showerr "单据字段配置错误" , "<span class=c_r>不支持字段【 " & Item.ywname & " | " & Item.dbname & " 】的数据类型。</span><br><br><span style='float:left;display:block;padding-left:60px;color:#666'>当前配置类型：" & t & "。</span>"
'If InStr(1, sql, "@" & Trim(Item.dbname), 1) > 0 Then
								call db_close : Response.end
							end if
						end if
					end if
				next
				sql = Replace(sql, "@uname", "'" & app.info.username & "'", 1, -1, 1)
'call db_close : Response.end
				sql = Replace(sql, "@uid", app.info.user, 1, -1, 1)
'call db_close : Response.end
				GetReplaceSql = App.SqlExtension(sql)
			end function
			Public Sub Class_Initialize()
				Set Items = New Collection
				ID = CInt(Rnd * 100)
				Set lvw = New ListView
				lvw.candelete = True
				lvw.PageSize = 10
				NeedSave = True
				mustShowProductLink = False
			end sub
			Public Function getHTML
				Dim i, f
				lvw.ID = ID
				lvw.FieldAttrSaveKey = "billCreatorPage_" & bill.orderid & "_" & ID
				lvw.AutoProductLink = bill.getappreadonly Or mustShowProductLink
				lvw.border = 1
				For i = 1 To lvw.cols.count
					Set f = lvw.cols.items(i)
					If instr(LCase(f.dbname) ,"syssignfd_")=1 Then
						f.htmlvisible  = False
						f.cookiewidth = 110
						f.save = 1
						f.ltype = ""
						f.isint = 0
						f.maxsize = 40
						f.dtype = "autosigncol"
					end if
				next
				getHTML = lvw.InnerHTML()
			end function
			Private Function MyTrim(v)
				Dim i, ii
				ii = 1
				For i = 1 To Len(v)
					ak = Asc(Mid(v, i, 1))
					If ak = 32 Or (ak < 20 And ak > 0) Then
						ii = ii + 1
'If ak = 32 Or (ak < 20 And ak > 0) Then
					else
						MyTrim = Mid(v, ii)
						Exit Function
					end if
				next
				MyTrim = Mid(v, ii)
			end function
			Public Sub setSVFields(FieldConfig)
				Dim allfields , Item , svCount , scCount , pos , sItem
				FieldConfig = Replace(FieldConfig, ",", "|")
				FieldConfig = Replace(FieldConfig, ";", "|")
				svCount = 0
				scCount = 0
				ReDim savefields (0)
				ReDim saveconstfields (0)
				allfields = Split(FieldConfig , "|")
				For I = 0 To UBound(allfields)
					Item = MyTrim(allfields(i))
					pos = InStr(Item, "=")
					If pos = 0 Then
						ReDim preserve savefields(svCount)
						savefields(svCount) = Trim(Replace(Replace(Item, Chr(13), ""), Chr(10), ""))
						svCount = svCount + 1
'savefields(svCount) = Trim(Replace(Replace(Item, Chr(13), ""), Chr(10), ""))
					else
						ReDim preserve saveconstfields(scCount)
						Set saveconstfields(scCount) = New DataField
						Set sItem = saveconstfields(scCount)
						sItem.Value = Right(Item, Len(Item) - pos)
						Set sItem = saveconstfields(scCount)
						sItem.dbname = Left(Item, pos -1)
						Set sItem = saveconstfields(scCount)
						sItem.ywname = "常量隐藏字段(" & sItem.dbname & ")"
						scCount = scCount + 1
'sItem.ywname = "常量隐藏字段(" & sItem.dbname & ")"
					end if
				next
			end sub
			Public Sub SetUIFields(FieldConfig)
				Dim fields , v
				fields = Split(Replace(FieldConfig, ",", ";"), "|")
				For I = 0 To UBound(fields)
					Items = Split(fields(i), ";")
					If IsArray(Items) Then
						If UBound(Items) > 0 Then
							If Not ( ( LCase(Items(0)) = "id" And LCase(Items(1)) = "id" ) Or ( LCase(Items(0)) = "prefixcode" Or LCase(Items(1)) = "prefixcode" ) ) Then
								Set fd = New cField
								For II = 0 To UBound(Items)
									If Len(Items(ii) & "") >0 Then
										v = Replace(Replace(Replace(Replace(Items(ii), "[]", ""), "；", ";"), "，", ","), Chr(0), "")
										Select Case II
										Case 0
										fd.state = v
										Case 1
										fd.dType = v
										Case 2
										fd.selID = v
										Case 3
										fd.defvalue = v
										Case 4
										fd.notnull = (v = "1")
										Case 5
										fd.Width = v
										End Select
									end if
								next
								Items.Add(fd)
							end if
						end if
					end if
				next
			end sub
		End Class
		Class SignFiled
			Public Items
			Public Count
			Public Sub class_Initialize
				Dim I
				ReDim Items(7)
				Set Items(0) = New DataField
				Items(0).dbname = "del"
				Items(0).Value = 0
				Set Items(1) = New DataField
				Items(1).dbname = "id_sp"
				Items(1).Value = 0
				Set Items(2) = New DataField
				Items(2).dbname = "status"
				Items(2).Value = 0
				Set Items(3) = New DataField
				Items(3).dbname = "tempsave"
				Items(3).Value = 0
				Set Items(4) = New DataField
				Items(4).dbname = "creator"
				Items(4).Value = app.info.user
				If Not IsNumeric(Items(4).Value) Or Len(Items(4).Value) = 0 Then
					Items(4).Value = "1001"
				end if
				Set Items(5) = New DataField
				Items(5).dbname = "indate"
				Items(5).Value = Now
				Set Items(6) = New DataField
				Items(6).dbname = "cateid_sp"
				Items(6).Value = 0
				For i = 0 To 6
					Items(i).ywname = "单据标识字段[" & Items(i).dbname & "]"
				next
				Count = 7
			end sub
		End Class
		Class LeftGroupTreeData
			Public sql 'sql = "select stat * from ss"
			Public group
			Public Sub Add(grouptext)
				Dim r
				group = Split(grouptext, "|")
			end sub
			Public Sub Class_Initialize()
				ReDim group(0)
			end sub
		End Class
		Class BillPage
			Private mstatus
			Public OrderId
			Public parSheets
			Public billName
			Public mType
			Public cmdButtons
			Public keySign
			Public TableName
			Public mainFields
			Public SaveFields
			Public hsAutoCode
			Public SQL
			Public showGroup
			Public savedata
			Public sheetno
			Public parentsheetno
			Public status
			Public SignFields
			Private mkeyField
			Private mid_spValue
			Public HasLeftPanel
			Public Cancel
			Public lfData
			Private mNeedCheck
			Public checkmanField
			Public id_spField
			Public checkHiddenField
			Public Sp
			Public RankCodeField
			Public canAdd
			Private mCreator
			Private mReadOnly
			Private AppReadOnly
			Public rule
			Public HasUserDef
			Public canRefreshList
			Public POConfigID
			Public SplogID
			Public power_canadd
			Public power_canupdate
			Public power_candelete
			Public power_canprint
			Public canCopy
			Public canScan
			Public pasteAlert
			Public HasSpRank
			Private statusTag
			Public readModeHasChild
			Public readModeHasChild2
			Public visibleRfListButton
			Public disuserdef
			Public mDebugText
			Public cantextcopy
			Public mustCanAdd
			Public hasList
			Public xlsout
			Public canReply
			Public qxlb
			Public BHFieldName
			Public BHexCondition
			Public addButtonsExtra
			Public cpZdyIDKey
			Public Sub AddDebug(itemname , itemvalue)
				mDebugText = mDebugText & "<li>" & itemname & " = 【" & itemvalue & "】</li>"
			end sub
			Public Property Get DebugText
			DebugText = mDebugText
			End Property
			Public Sub AddTag (v)
				statusTag = statusTag & "|" & v & "|"
			end sub
			Public Function GetTag(v)
				GetTag = InStr(1, statusTag , v, 1) > 0
			end function
			Public Property Get ReadOnly
			ReadOnly = mReadOnly
			End Property
			Public Property Get GetAppReadOnly
			GetAppReadOnly = AppReadOnly
			End Property
			Public Sub SetAppReadState(newState)
				AppReadOnly = newState
			end sub
			Public Function GetCurrAutoCode()
				Dim Oid
				Oid = Me.OrderID
				on error resume next
				Set rs = cn.Execute("exec erp_getUniqueOrderBH " & Oid & "," & app.info.User)
				If Abs(Err.Number) > 0 Then
					app.ShowYellowAlert "生成自动编号失败。" & _
					"                ""<div style='height:5px'></div><span class=link><a href=### style='color:blue' onclick='xxxxMsg.style.display=xxxxMsg.style.display==""""inline""""?""""none"""":""""inline""""'>详情</a></span>&nbsp;&nbsp;&nbsp;<span id='xxxxMsg'  style=""""color:red;display:none;"""" onselectstart='return true'>源:execerp_getUniqueOrderBH " & Oid & "," & app.Info.User & ";&nbsp;&nbsp;错误提示:" & Err.Description & "</span>"
					Exit Function
				end if
				On Error Goto 0
				If rs.EOF Then
					GetCurrAutoCode = ""
				else
					GetCurrAutoCode = rs.fields(0).Value
				end if
				rs.close
				If Abs(Err.Number) > 0 Then
					GetCurrAutoCode = "自动生成编号错误" & Err.Description
				end if
			end function
			Public Property Get Creator
			Dim frs
			If Len(mCreator) = 0 Then
				On Error Resume Next
				Set frs = cn.Execute("select " & SignFields.Items(4).dbname & " from " & Me.tablename & " where " & Me.keyField & " = " & Me.sheetno)
				If Abs(Err.Number) > 0 Then
					mCreator = 0
					Creator = mCreator
					Exit Property
				end if
				On Error Goto 0
				If Not frs.EOF Then
					mCreator = frs.fields(0).Value
				end if
				If Len(mCreator) = 0 Then
					mCreator = 0
				end if
				frs.Close
			end if
			Creator = mCreator
			End Property
			Public Property Get Deleted
			Dim frs
			On Error Resume Next
			deleted = -2
'On Error Resume Next
			Set frs = cn.Execute("select del from " & Me.tablename & " where " & Me.keyField & " = " & Me.sheetno)
			If Not frs.EOF Then
				Deleted = frs.fields(0).Value
			end if
			If Len(mCreator) = 0 Then
				Deleted = 0
			end if
			frs.Close
			Set frs = nothing
			End Property
			Public Property Get NeedCheck
			NeedCheck = mNeedCheck
			End Property
			Public Property Let NeedCheck(nvalue)
			mNeedCheck = nvalue
			End Property
			Public Property Get id_spValue
			Dim I , mf , rs
			mid_spValue = mid_spValue & ""
			If Len(mid_spValue) = 0 Then
				For i = 1 To mainFields.Count
					Set mf = mainfields.Items(i)
					If mf.dbname = id_spField Then
						mid_spValue = mf.defvalue
					end if
				next
				If Len(mid_spValue) = 0 Or Trim(mid_spValue) = "0" Then
					on error resume next
					Set rs = cn.Execute("select isnull(" & id_spField & ",0) from " & TableName & " where " & keyField & "=" & Me.sheetno)
					If Not rs.EOF Then
						mid_spValue = rs.fields(0).Value
					end if
					rs.close
					On Error Goto 0
				end if
				If Len(mid_spValue) = 0 Or Trim(mid_spValue) = "0" Then
					Set rs = cn.Execute("select min(rank) from M_FlowSettings where orderID=" & Me.orderid )
					If Not rs.EOF Then
						mid_spValue = rs.fields(0).Value
					end if
					rs.close
				end if
				Set rs = cn.Execute("select top 1 backrank,sp_id from M_FlowLogs a inner join M_OrderSettings b on a.prefixcode=b.prefixcode where b.ID=" & Me.orderid & " and a.orderID = " & Me.sheetno & " order by indate desc")
				If rs.EOF Then
					HasSpRank = 0
				else
					If Len(rs.fields(0).Value & "") = 0 Then
						HasSpRank = 1
					else
						If rs.fields(0).Value = 0 Then
							HasSpRank = 0
						else
							HasSpRank = rs.fields(0).Value
							rs.close
							Set rs = cn.Execute("select min(rank) from M_FlowSettings where orderID=" & Me.orderid )
							If rs.EOF = False Then
								If HasSpRank <= rs.fields(0).Value Then
									HasSpRank = 0
								else
									HasSpRank = 1
								end if
							else
								HasSpRank = 0
							end if
						end if
					end if
				end if
				rs.close
			end if
			If Len(Trim(mid_spValue & "")) = 0 Then
				mid_spValue = 0
			end if
			
			id_spValue = mid_spValue
			End Property
			Public Property Get keyField()
			keyField = mkeyField
			End Property
			Public Property Let keyField(ByVal vNewValue)
			mkeyField = vNewValue
			If Not IsNumeric(Me.sheetno) Or Len(Me.sheetno) = 0 Then Me.sheetno = Me.GetNewIDNumber()
			If Abs(Me.sheetno) < 1 Then Me.sheetno = Me.GetNewIDNumber()
			End Property
			Public Function CreateDetail
				Set CreateDetail = New DetailFields
				Set CreateDetail.Bill = Me
			end function
			Public Function getspStatus()
				on error resume next
				If Len(mstatus) = 0 Then
					getspStatus = -1
'If Len(mstatus) = 0 Then
					Set rs = cn.Execute("select status  from " & Me.tablename & " where " & mkeyfield & " = " & sheetno)
					If Not rs.EOF Then
						getspStatus = rs.fields(0).Value
					else
						getspStatus = -1
						getspStatus = rs.fields(0).Value
					end if
					mstatus = getspStatus
				else
					getspStatus = mstatus
				end if
				On Error GoTo 0
			end function
			Public Sub Class_Initialize()
				Dim cmdButtonTexts , i , bn , itm
				Set SignFields = New SignFiled
				cmdButtonTexts = Split("新建,1;暂存,1;保存,1;删除,1;审批,1;打印,1;导出,1;导入,0;变更,1", ";")
				billName = "未知单"
				mType = "添加"
				Set cmdButtons = New Collection
				Set mainFields = New Collection
				For i = 0 To UBound(cmdButtonTexts)
					Set bn = New cmdButton
					itm = Split(cmdButtonTexts(i), ",")
					bn.text = itm(0)
					bn.visible = CInt(itm(1)) > 0
					cmdButtons.Add(bn)
				next
				tmpSaveField = "TempSave"
				delSignField = "del"
				statusField = "status"
				id_spField = "id_sp"
				HasLeftPanel = False
				checkmanField = "cateid_sp"
				RankCodeField = "RankCode"
				visibleRfListButton = True
				mNeedCheck = True
				showGroup = True
				sheetno = 0
				mReadOnly = False
				canAdd = True
				canCopy = True
				canScan = False
				cantextcopy = True
				canrefreshlist = True
				power_candelete = True
				readModeHasChild = False
				readModeHasChild2 = False
				hsAutoCode = False
				mustcanadd = False
				haslist = 0
				xlsout = 0
				canReply = 0
				addButtonsExtra = ""
				power_canupdate = True
				Set lfData = New LeftGroupTreeData
				If Not AppReadOnly Then
					If request.Form("readmode") = "1" Then
						AppReadOnly = True
					end if
				end if
				If Not AppReadOnly Then
					If request.querystring("readmode") = "1" Then
						AppReadOnly = True
					end if
				end if
				parentsheetno = request.Form("parentID")
				If Not IsNumeric(parentsheetno) Or Len(parentsheetno) = 0 Then
					parentsheetno = 0
				end if
				If IsNumeric(request.Form("Bill_info_id")) And Len(request.Form("Bill_info_id"))>0 Then
					sheetno = request.Form("Bill_info_id")
				end if
				hasdelete = 0
			end sub
			Public Function getTreeBillRank(id)
				Set rs = cn.Execute("select isnull(max(" & Me.rankcodefield & "),0) from " & Me.tablename & "  where  " & keyField & "=" & id)
				If rs.EOF Then
					getTreeBillRank = 0
				else
					getTreeBillRank = rs.fields(0).Value
				end if
				rs.close
			end function
			Public Function GetGroups()
				Dim gps , hs , Item , gCount , spGpIndex
				ReDim gps(0)
				gCount = 0
				spGpIndex = 0
				For I = 1 To mainFields.Count
					hs = False
					Set Item = mainFields.Items(i)
					For II = 1 To gCount
						If LCase(gps(ii)) = LCase(Item.group) Then
							hs = True
							II = gCount
						end if
					next
					If Not hs Then
						gcount = gcount + 1
'If Not hs Then
						ReDim preserve gps(gcount)
						gps(gcount) = Item.group
						If Item.group = "审批设置" Then
							spGpIndex = gcount
						end if
					end if
				next
				If spGpIndex > 0 Then
					For i = spGpIndex To ubound(gps)-1
'If spGpIndex > 0 Then
						gps(i) = gps(i + 1)
'If spGpIndex > 0 Then
					next
					gps(UBound(gps)) = "审批设置"
				end if
				GetGroups = gps
			end function
			Private Function getDesignRecordHTML()
				Dim lvw1 , rs , html
				Set rs = cn.Execute("select  spName , rank from M_FlowSettings where orderid=" & Me.orderid & " order by rank ")
				While Not rs.EOF
					html = html & "<span title="& rs.fields("rank").Value & " style='border:1px solid #aaaacc;background-color:#f8f7f6;padding:4px'>" & rs.fields("spName").Value & "</span>"
'While Not rs.EOF
					rs.movenext
					If Not rs.EOF Then
						html = html & " → "
					end if
				wend
				rs.close
				Set lvw1 = New listview
				lvw1.id = "design"
				lvw1.pagetype = "database"
				lvw1.sql = "exec erp_bill_extraDesign "& app.Info.user &", " & Me.orderid & " , " & Me.sheetno & " "
				lvw1.showtool = False
				lvw1.autosum = False
				lvw1.border = 0
				if sdk.Power.ExistsManu(3) and sdk.Power.ExistsModel(18200) Then
					If Me.orderid=3 And sdk.power.existsPowerIntro(Me.qxlb , 21 , Me.Creator) then
						lvw1.lbBarHTML = "<a href='javascript:void(0);' onclick='menu.showSourceList(1108 , ""dbf_orderid="& Me.orderid &"&dbf_bill_ID="& Me.sheetno &""" , 0 , "& Me.orderid &" ,"& Me.sheetno &" )' style='color:red'><img src='../../images/jiantou.gif'>关联设计方案</a>"
					end if
				else
					If Me.orderid=2 And sdk.power.existsPowerIntro(Me.qxlb , 21 , Me.Creator) Then
						lvw1.lbBarHTML = "<a href='javascript:void(0);' onclick='menu.showSourceList(1108 , ""dbf_orderid="& Me.orderid &"&dbf_bill_ID="& Me.sheetno &""" , 0 , "& Me.orderid &" ,"& Me.sheetno &" )' style='color:red'><img src='../../images/jiantou.gif'>关联设计方案</a>"
					end if
				end if
				If Me.orderid=8 And sdk.power.existsPowerIntro(Me.qxlb , 21 , Me.Creator) Then
					lvw1.lbBarHTML = "<a href='javascript:void(0);' onclick='menu.showSourceList(1108 , ""dbf_orderid="& Me.orderid &"&dbf_bill_ID="& Me.sheetno &""" , 0 , "& Me.orderid &" ,"& Me.sheetno &" )' style='color:red'><img src='../../images/jiantou.gif'>关联设计方案</a>"
				end if
				getDesignRecordHTML = "<div style='padding:5px' id='div_design'>"& Replace(lvw1.innerhtml, "class='listviewframe'", "")&"</div>"
				Set lvw1 = Nothing
			end function
			Private Function GetSpRecordHTML()
				Dim lvw1 , rs , html
				Set rs = cn.Execute("select  spName , rank from M_FlowSettings where orderid=" & Me.orderid & " order by rank ")
				While Not rs.EOF
					html = html & "<span title="& rs.fields("rank").Value & " style='border:1px solid #aaaacc;background-color:#f8f7f6;padding:4px'>" & rs.fields("spName").Value & "</span>"
'While Not rs.EOF
					rs.movenext
					If Not rs.EOF Then
						html = html & " → "
					end if
				wend
				rs.close
				Set lvw1 = New listview
				lvw1.id = "splog_2"
				lvw1.pagetype = "database"
				lvw1.sql = "exec erp_sp_spLogs " & Me.orderid & " , " & Me.sheetno & " , 0"
				lvw1.showtool = False
				lvw1.autosum = False
				lvw1.border = 0
				GetSpRecordHTML = "<div style='padding:4px;margin-top:10px'><b>当前审批流程：</b>" & html & "</div><div id='sprecordlist' style='padding:5px'>" & Replace(lvw1.innerhtml, "class='listviewframe'", "") & "</div>"
				lvw1.border = 0
				Set lvw1 = Nothing
			end function
			Private Function getNoticeRecordHTML()
				Dim rs , s , idx , linkHTML
				s= ""
				Set rs =  cn.execute("exec [erp_notice_List] "& app.info.user &","& Me.orderid &","& Me.sheetno &",'' ,'','' ,'' ,'' ,'' , 0 ,0,4 ,1, '-indate' ")
				s= ""
				Set rs = rs.nextrecordset
				If rs.eof = False Then
					idx = 0
					s = "<div style='padding:5px'><table class='full lvwcss'><tr><th class='lvc'>通知时间</th><th class='lvc'>通知主题</th><th class='lvc'>通知内容</th><th class='lvc'>发布人</th><th class='lvc'>详情</th></tr>"
					Do While rs.eof = False
						idx=idx+1
'Do While rs.eof = False
						If idx > 3 Then Exit Do
						linkHTML = ""
						If rs("url").value = "url" Then
						end if
						s =  s & "<tr><td class='lvc'  align='center' style='width: 230px'>" & rs("indate").value & "</td>"&_
						"<td class='lvc'   style='width: 235px'>" & Replace(rs("title").value,";","；") & "</td>"&_
						"<td class='lvc' >" & Replace(rs("intro").value & "",";","；") & "</td>"&_
						"<td class='lvc' align='center' style='width: 60px'>" & Replace(rs("addname").value & "",";","；")  & "</td>"&_
						"<td class='lvc' align='center' style='width: 60px'><a href='javascript:void(0)' onclick=""Bill.openWindowDialog('../../notice/content.asp?ord=" & sdk.base64.pwurl(rs("id")) & "', 'newwincontent',1100,600)"">查看</a></td></tr>"
						rs.movenext
					Loop
					If idx>3 Then
						s = s & "<tr><td colspan='5' style='height:24px' align='right'> <a href=""javascript:void(0)"" onclick=""Bill.openWindowDialog('../../notice/list.asp?datatype="& me.orderid&"&fromid=" & sdk.base64.pwurl(Me.sheetno) & "','newwinnotice', 1100,600)""><font style='color:red'>更多通知信息..&gt;&gt;&gt;</font></a></td></tr>"
					end if
					s = s & "</table></div>"
				end if
				rs.close
				getNoticeRecordHTML = s
			end function
			Private Function getMBOMPlanRecordHTML()
				Dim rs , s , idx , linkHTML , datatype
				if sdk.Power.ExistsManu(3) and sdk.Power.ExistsModel(18200) Then
					datatype = 3
				else
					datatype = 2
				end if
				s = "<div style='padding:5px'><table class='full lvwcss'><tr><th class='lvc'><input type='checkbox' value='0' name='bill_gl_allid' onclick=""$('input[name=bill_gl_id]').attr('checked', this.checked)""> 选择</th><th class='lvc'>主题</th><th class='lvc'>编号</th><th class='lvc'>添加人</th><th class='lvc'>添加时间</th><th class='lvc'>详情</th></tr>"
				Set rs =  cn.execute("exec [erp_bill_MBOMPlan] "& app.info.user &","& datatype &","& Me.sheetno &"  ")
				If rs.eof = False Then
					idx = 0
					Do While rs.eof = False
						idx=idx+1
'Do While rs.eof = False
						linkHTML = ""
						If sdk.power.existsPowerIntro(rs("powerid"),14,rs("creator")) Then
							linkHTML = "<a href='javascript:void(0)' onclick=""Bill.openWindowDialog('Readbill.asp?orderid="& rs("oid") &"&id=" & rs("bid") & "&SplogId=0&vTime=1468309998263','newwincontent',1100,600)"">查看</a>"
						end if
						s =  s & "<tr><td class='lvc'  align='center' style='width: 60px'><input type='checkbox' value='"& rs("oid")&"_"& rs("bid") &"' name='bill_gl_id'></td>"&_
						"<td class='lvc' align='center'>" & rs("title").value & "</td>"&_
						"<td class='lvc' align='center'>" & Replace(rs("bh").value,";","；") & "</td>"&_
						"<td class='lvc' align='center'>" & Replace(rs("addname").value & "",";","；")  & "</td>"&_
						"<td class='lvc' align='center'>" & Replace(rs("indate").value & "",";","；") & "</td>"&_
						"<td class='lvc' align='center' style='width: 60px'>"& linkHTML &"</td></tr>"
						rs.movenext
					Loop
				else
					s = s & "<tr><td colspan=6 class='lvc' align='center' style='height:27px'>暂不需要同步更新!</td></tr>"
				end if
				rs.close
				s = s & "</table></div>"
				getMBOMPlanRecordHTML = s
			end function
			Private Function CRadioList(TArray, VArray, ID, field)
				Dim I, nm, selectvalue
				nm = ID & "_MFRadio"
				CRadioList = "<table><tr>"
				selectvalue = field.defvalue
				SelectValue = Trim(CStr(SelectValue & ""))
				For I = 0 To UBound(TArray)
					If mreadonly Then
						If CStr(VArray(i)) = SelectValue Then
							CRadioList = CRadioList & "<td>" & TArray(i) & "</td>"
						end if
					else
						If Len(RTrim(VArray(i))) > 0 Then
							CRadioList = CRadioList & "<td><input forid=""" & ID & """ RefreshChild='" & field.RefreshChild & "' " & app.IIf(CStr(VArray(i)) = SelectValue, "checked", "") & " onclick='Bill.radioFieldClick(""" & VArray(i) & """, this);' type='Radio' name='" & nm & "' id='"& nm & I & "'></td><td><label for='" & nm & i & "'>" & TArray(i) & "</label></td><td>&nbsp;</td>"
						end if
					end if
				next
				CRadioList = CRadioList & "</tr></table>"
			end function
			Public Function GetItemHTML(Item, index)
				Dim selHtml , pHtml , selCount , rCount , Width , InputId , borderStyle , lvw1 , autoCode
				Dim aReadOnly
				Dim FreshChildEvent
				autoCode = 0
				If isnumeric(Item.Width)=false Then Item.Width = 0
				If Item.Width > 0 Then Width = "style='width:" & Item.Width & "px'"
				borderStyle = ""
				aReadOnly = False
				If Len(AppReadOnly) > 0 Then
					If AppReadOnly Then
						aReadOnly = True
						borderStyle = "border:0px;overflow:hidden;"
					end if
				end if
				If LCase(Item.dtype) <> "detail" Then
					Select Case LCase(Trim(Item.defvalue))
					Case "@uid"
					Item.defvalue = app.info.user
					Case "@uname"
					Item.defvalue = app.info.username
					Case "@bill_id"
					Item.defvalue = Me.sheetno
					Case "@bill_parentid"
					Item.defvalue = Me.parentsheetno
					Case "@bsign"
					Item.defvalue = Me.keysign
					Case "@now"
					Item.defvalue = Now
					Case "@date"
					Item.defvalue = Date
					Case "@autocode"
					Item.defvalue = Me.GetCurrAutoCode
					autoCode = 1
					Me.hsAutoCode = 1
					End Select
				end if
				on error resume next
				If Abs(Item.RefreshChild) > 0 Then
					FreshChildEvent = " onchange='Bill.RefreshDetail(true);' RefreshChild=1 "
				end if
				On Error GoTo 0
				If InStr(Item.dbname, "{us") = 1 Then
					InputId = "MT" & index
				else
					InputId = "MT" & index
				end if
				Dim a
				If LCase(Item.dType) = "number" Then
					If Len(CStr(Item.defvalue)) > 0 Then
						If Right(Item.ywname,2) = "工资" or Right(Item.ywname,2) = "费用" or Item.ywname="注册资本" Then
							Item.defvalue = Replace(FormatNumber(Item.defvalue,app.info.moneynumber,-1) & "", ",", "")
'If Right(Item.ywname,2) = "工资" or Right(Item.ywname,2) = "费用" or Item.ywname="注册资本" Then
						else
							Item.defvalue = app.formatnum(Item.defvalue)
						end if
					end if
				end if
				Select Case LCase(Item.dType)
				Case "hdtime"
				Dim oldYearStr, oldTimeStr
				oldYearStr = ""
				oldTimeStr = ""
				For i = 1901 To Year(Date)
					oldYearStr = oldYearStr&"<option value="""&i&""">"&i&"年</option>"
				next
				oldTimeStr = "<select name=""HddayType"" id=""HddayType"" onChange=""getHdYear()"">"
				oldTimeStr = oldTimeStr&" <option value=""1"">公历</option>"
				oldTimeStr = oldTimeStr&"<option value=""2"">农历</option>"
				oldTimeStr = oldTimeStr&" </select>"
				oldTimeStr = oldTimeStr&"<select name=""HdYear"" id=""HdYear"" onChange=""getHdMonth()"">"
				oldTimeStr = oldTimeStr&"<option value="""" selected>每年</option>"
				oldTimeStr = oldTimeStr&oldYearStr
				oldTimeStr = oldTimeStr&"</select>"
				oldTimeStr = oldTimeStr&"<select name=""HdMonth"" id=""HdMonth"" onChange=""getHdDay()"">"
				oldTimeStr = oldTimeStr&"  <option value="""">选择月</option>"
				oldTimeStr = oldTimeStr&" </select>"
				oldTimeStr = oldTimeStr&"<select name=""HdDay"" id=""HdDay"">"
				oldTimeStr = oldTimeStr&"  <option value="""">选择日</option>"
				oldTimeStr = oldTimeStr&" </select>"
				GetItemHTML = oldTimeStr
				Case "bit"
				selCount = 0
				If Not IsNumeric(Item.defvalue) Then Item.defvalue = 0
				Dim TArray , VArray
				TArray = Split("是|否", "|")
				VArray = Split("1|0", "|")
				Item.defvalue = CStr(Abs(Item.defvalue))
				If Item.defvalue <> "0" Then Item.defvalue = "1"
				GetItemHTML = "<input type=hidden  dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "' autoCode=" & autoCode & " value='" & Item.defvalue & "'>"
				If mreadonly Then
					If Item.defvalue = "1" Then
						GetItemHTML = GetItemHTML & "<img src='../../images/smico/ok.gif'>"
					else
						GetItemHTML = GetItemHTML & "<img src='../../images/smico/del3.gif'>"
					end if
				else
					GetItemHTML = GetItemHTML & "<input dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ type=checkbox onclick='document.getElementsByName(""" & InputId & """)[0].value=this.checked*1' " & App.IIf(Item.defvalue = "1", "checked", "") & " />"
				end if
				Case "textarea"
				pHtml = ""
				If mreadonly Then
					pHtml = "<textarea" & FreshChildEvent & "  style='display:none;" & borderStyle & "' autoCode=" & autoCode & " dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "' class='billfieldtextarea' " & app.IIf(mreadonly, "readonly", "") & ">" & Item.defvalue & "</textarea>" & Replace(Item.defvalue,vbcrlf,"<br>")
				else
					pHtml = "<textarea" & FreshChildEvent & " notnull=" & Abs(item.notnull) &" defHeight='58' style='" & borderStyle & "'  autoCode=" & autoCode & " dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "' class='billfieldtextarea' " & app.IIf(mreadonly, "readonly", "") & ">" & Item.defvalue & "</textarea>"
				end if
				If Item.notnull And Not mreadonly Then
					pHtml = pHtml & "&nbsp;<span class=c_red>*</span>"
				end if
				GetItemHTML = pHtml
				Case "html"
				If mreadonly Then
					GetItemHTML = "<textarea dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "' style='display:none' cols=1 rows=1>" & Item.defvalue & "</textarea>" & _
					"<div class='ewebeditorImg' style='width:95%;padding:5px;overflow:auto;margin:2px;" & app.IIf(Len(borderStyle)>0, "border:0px", "border:2px inset") & "'>" & Item.defvalue & "</div>"
				else
					GetItemHTML = "<textarea class='editorArea' dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "' style='display:none' cols=1 rows=1>" & Item.defvalue & "</textarea>" & _
					"                                  ""<IFRAME tag='billlist' style='margin:4px 0px 4px 0px;display:block' ID='eWebEditor_MT"" & index & ""' SRC='../../edit/ewebeditor.asp?id=MT"" & index & ""&style=news' FRAMEBORDER='0' SCROLLING='no' width='99%' height=300 marginwidth=1 marginheight=1 name='eWebEditor_MTnm" & index & "'></IFRAME>"
					If Item.notnull And Not mreadonly Then
						GetItemHTML = GetItemHTML & "&nbsp;<span class=c_red>*</span>&nbsp;&nbsp;<span class=c_red id='fms_" & Item.dbname &"'></span>"
					end if
				end if
				Case "code1":
				Dim codetitle1 , codeData1
				codetitle1 =""
				codeData1 = Item.defvalue
				If InStr(Item.defvalue,"=@code=")>0 Then
					codetitle1=Split(Item.defvalue , "=@code=")(0)
					codeData1 =Split(Item.defvalue , "=@code=")(1)
				end if
				Dim imgurl1 : imgurl1 = "../code2/viewCode.asp?codeType=128&data="& server.urlencode(codeData1) &"&height=60"
				GetItemHTML = "<img width='100' height='25px' title='此单据一维码' src='../"& imgurl1 &"' style='padding-top:2.5px;cursor:pointer' onclick=""javascript:window.open('../../code2/viewImage.asp?codeType=128&title="& server.urlencode(codetitle1) &"&imgurl=" & server.urlencode(imgurl1) & "&t="&now()&"','imgurl_1','width=' + 320 + ',height=' + 320 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')"">"
				Case "code2":
				Dim codetitle , codeData
				codetitle =""
				codeData = Item.defvalue
				If InStr(Item.defvalue,"=@code=")>0 Then
					codetitle=Split(Item.defvalue , "=@code=")(0)
					codeData =Split(Item.defvalue , "=@code=")(1)
				end if
				Dim imgurl2 : imgurl2 = "../code2/view.asp?sn=view&ct=46&data="& server.urlencode(codeData) &"&width=120&errorh=3"
				GetItemHTML = "<img width='25px' title='此单据二维码' src='../"& imgurl2 &"' style='padding-top:2.5px;cursor:pointer' onclick=""javascript:window.open('../../code2/viewImage.asp?title=" & server.urlencode(codetitle) & "&imgurl="& server.urlencode(imgurl2) &"&t="&now()&"','imgurl_2','width=' + 320 + ',height=' + 320 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')"">"
				Case "reply"
				If mreadonly Then
					GetItemHTML = GetReplyHtml()
				end if
				Case "treebox" :
				Dim t_value : t_value = Item.defvalue
				Dim t_UI_text : t_UI_text = convertTreeBox(t_value, Item.selid)
				If mreadonly Then
					Width = " style='width:100%' "
					GetItemHTML = t_UI_text& "&nbsp;" & Item.unit
				else
					pHtml = "<table class=textitemtable><tr><td>"
					pHtml = pHtml & "<input type='hidden' name='" & InputId & "'dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ value='" &  t_value & "'><input " & FreshChildEvent & " autoCode=" & autoCode & "  style= 'border-right:0px;line-height:19px;height:19px;" & borderStyle & "'  " & app.IIf(mreadonly, "readonly", "onkeydown = 'Bill.ItemKeyDown(this)' onkeyup='Bill.ItemKeyUp(this)'") & " type=text " & Width & " value=""" & Replace(t_UI_text & "", """", "&#34;") & """ id='s_" & InputId & "_txt' notnull=""" & Item.notnull & """ dType=""" & Item.dType & """"
					Select Case Item.state
					Case 3
					pHtml = pHtml & " readonly class=" & app.IIf(Item.selid>0, "text", "billreadonlytext") & "></td>"
					Case 2
					pHtml = pHtml & " readonly class=" & app.IIf(Item.selid>0, "text", "billreadonlytext") & "></td>"
					Case 1
					pHtml = pHtml & " class=text></td>"
					End Select
					If Item.selId > 0 Then
						pHtml = pHtml & "<td><button onfocus='this.blur()' " & app.IIf(mreadonly, app.IIf(areadonly, "style='display:none'", "disabled"), "") & " class=InselButton  Mfield=1 selid='" & Item.selID & "' onclick='Bill.showTreeBoxDlg(" & Item.selId & ",0,"""  & Item.defvalue & ""","""&InputId&""")'><img src='../../images/11645.png' height=13></button></td>"
					end if
					If Item.notnull And Not mreadonly Then
						pHtml = pHtml & "<td>&nbsp;<span class=c_red>*</span></td>"
					end if
					GetItemHTML = pHtml & "<td>&nbsp;" & Item.unit & "</td></tr></table>"
				end if
				Case "search":
				Dim s_value : s_value = Item.defvalue
				Dim s_UI_text : s_UI_text = convertSearch(s_value, Item.selid)
				If mreadonly Then
					Width = " style='width:100%' "
					GetItemHTML = "&nbsp;" & s_UI_text& "&nbsp;" & Item.unit &  "<input type='hidden' name='" & InputId & "'dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ value='" &  s_value & "' type='hidden'>"
				else
					Dim hideselbtn
					hideselbtn = (mreadonly or item.state=3) And (areadonly or Item.state = 2 or item.state=3)
					pHtml = "<table class=textitemtable><tr><td>"
					pHtml = pHtml & "<input type='hidden' name='" & InputId & "'dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ value='" &  s_value & "'><input " & FreshChildEvent & " autoCode=" & autoCode & "  style= '" + app.iif(hideselbtn,"","border-right:0px;") + "line-height:19px;height:19px;" & borderStyle & "'  " & app.IIf(mreadonly or item.state=3, "readonly", "onkeydown = 'Bill.ItemKeyDown(this)' onclick='window.open(""searchProxy.asp?stype=" & Item.selId & "&fieldID="&InputId&""",""newwin"",""width=1000,height=600,fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=200,top=100"")' onkeyup='Bill.ItemKeyUp(this)'") & " type=text " & Width & " value=""" & Replace(s_UI_text & "", """", "&#34;") & """ id='s_" & InputId & "_txt' notnull=""" & Item.notnull & """ dType=""" & Item.dType & """"
					Select Case Item.state
					Case 3
					pHtml = pHtml & " readonly class=" & app.IIf(Item.selid>0, "text", "billreadonlytext") & "></td>"
					Case 2
					pHtml = pHtml & " readonly class=" & app.IIf(Item.selid>0, "text", "billreadonlytext") & "></td>"
					Case 1
					pHtml = pHtml & " class=text></td>"
					End Select
					If Item.selId > 0 Then
						pHtml = pHtml & "<td><button onfocus='this.blur()' " & app.IIf(mreadonly or item.state=3, app.IIf(areadonly or Item.state = 2 or item.state=3, "style='display:none'", "disabled"), "") & " class=InselButton  Mfield=1 selid='" & Item.selID & "' onclick='window.open(""searchProxy.asp?stype=" & Item.selId & "&fieldID="&InputId&""",""newwin"",""width=1000,height=600,fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=200,top=100"")'><img src='../../images/11655.png'></button></td>"
					end if
					If Item.notnull And Not mreadonly Then
						pHtml = pHtml & "<td>&nbsp;<span class=c_red>*</span></td>"
					end if
					GetItemHTML = pHtml & "<td>&nbsp;" & Item.unit & "</td></tr></table>"
				end if
				Case "sort"
				Dim sortTitle, SortValue
				sortTitle = "无"
				If Item.defvalue<>"" And IsNumeric(Item.defvalue) Then
					Set sortRs = cn.Execute("select title from hr_sort where del=0 and cnID="&Item.defvalue&" order by px,cnID desc")
					If Not sortRs.EOF Then
						sortTitle = sortRs(0)
					end if
					sortRs.Close
					Set sortRs = Nothing
				end if
				SortValue = Item.defvalue
				If IsNumeric(SortValue) = False Or SortValue = "" Then SortValue = 0
				If mreadonly Then
					GetItemHTML = sortTitle
				else
					GetItemHTML = "<p id=""SortP"">&nbsp;</P><input type=hidden dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ value="""&SortValue&""" name='" & InputId & "' " & app.IIf(mreadonly, "readonly", "")&">"&_
					"<script language=""javascript"">"&_
					"var SortClass=new sortMenu("""&InputId&""",""SortP"",UserSortArr);"&_
					"SortClass.newInit("& SortValue &",SortClass);"&_
					"</script>"
				end if
				Case "type"
				Dim typeTitle, typeValue
				
				typeTitle = "无"
				If Item.defvalue<>"" And IsNumeric(Item.defvalue) Then
					Set sortRs = cn.Execute("select title from hr_sort where del=0 and cnID="&Item.defvalue&" order by px,cnID desc")
					If Not sortRs.EOF Then
						typeTitle = sortRs(0)
					end if
					sortRs.Close
					Set sortRs = Nothing
				end if
				typeValue = Item.defvalue
				If IsNumeric(typeValue) = False Or typeValue = "" Then typeValue = 0
				If mreadonly Then
					GetItemHTML = typeTitle
				else
					GetItemHTML = "<p id=""TypeP"">&nbsp;</P><input type=hidden dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ value="""&typeValue&""" name='" & InputId & "' " & app.IIf(mreadonly, "readonly", "")&">"&_
					"<script language=""javascript"">"&_
					"var TypeClass=new sortMenu("""&InputId&""",""TypeP"",UserTypeArr);"&_
					"TypeClass.newInit("& typeValue &",TypeClass);"&_
					"</script>"
				end if
				Case "grade"
				Dim gradeTitle, gradeValue
				gradeTitle = "无"
				If Item.defvalue<>"" And IsNumeric(Item.defvalue) Then
					Set sortRs = cn.Execute("select title from hr_sort where del=0 and cnID="&Item.defvalue&" order by px,cnID desc")
					If Not sortRs.EOF Then
						gradeTitle = sortRs(0)
					end if
					sortRs.Close
					Set sortRs = Nothing
				end if
				gradeValue = Item.defvalue
				If IsNumeric(gradeValue) = False Or gradeValue = "" Then gradeValue = 0
				If mreadonly Then
					GetItemHTML = gradeTitle
				else
					GetItemHTML = "<p id=""TypeP"">&nbsp;</P><input type=hidden dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ value="""&gradeValue&""" name='" & InputId & "' " & app.IIf(mreadonly, "readonly", "")&">"&_
					"<script language=""javascript"">"&_
					"var GrageClass=new sortMenu("""&InputId&""",""TypeP"",UserGrageArr);"&_
					"GrageClass.newInit("& gradeValue &",GrageClass);"&_
					"</script>"
				end if
				Case "gate"
				GetItemHTML = getGateField(item, InputId, false)
				Case "allgate"
				GetItemHTML = getGateField(item, InputId, true)
				Case "gateradio"
				If mreadonly Then
					Set gateRs = cn.Execute("select name from gate_person where del=1 and ord in("&Item.defvalue&") order by cateid,ord asc")
					If Not gateRs.EOF Then
						StrDialog = gateRs(0)
					else
						StrDialog = ""
					end if
					gateRs.Close
					Set gateRs = Nothing
					GetItemHTML = StrDialog
				else
					StrDialog = "点击选择"
					ClassName = "HiddenDialog"
					Valuse = Item.defvalue
					If IsNumeric(Valuse) = False Or Valuse = "" Or IsNull(Valuse) Then Valuse = app.info.user
					If IsNumeric(Valuse) = False Or Valuse = "" Or IsNull(Valuse) Then Valuse = 0
					If Valuse>0 Then
						ClassName = "ShowDialog"
						Set gateRs = cn.Execute("select username from hr_person where del=0 and userid in("&Valuse&") order by userid asc")
						If Not gateRs.EOF Then
							StrDialog = gateRs(0)
						end if
						gateRs.Close
						Set gateRs = Nothing
					end if
					GetItemHTML = "<input type=hidden value="""& Valuse &""" dbname='" & Item.dbname & "'  ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "' >"&_
					"<input name=""Dialog_gateRadion"" type=""text"" id=""Dialog_gateRadion"" Class=""text"" onclick=""gatePerson.showGateRadioDiv(this,"& Valuse &");""    value="""& StrDialog &"""  size=""8"" >"
				end if
				Case "radiogate"
				If mreadonly Then
					Set gateRs = cn.Execute("select name from gate where del=1 and ord in("& CLng("0" & Item.defvalue) &") order by cateid,ord asc")
					If Not gateRs.EOF Then
						StrDialog = gateRs(0)
					else
						StrDialog = ""
					end if
					gateRs.Close
					Set gateRs = Nothing
					GetItemHTML = StrDialog
				else
					ClassName = "HiddenDialog"
					Valuse = Item.defvalue
					If Item.notnull= False Then
						If IsNumeric(Valuse) = False Or Valuse = "" Or IsNull(Valuse) Then Valuse = app.info.user
						If IsNumeric(Valuse) = False Or Valuse = "" Or IsNull(Valuse) Then Valuse = 0
					end if
					If Valuse>0 And Len(Valuse)>0 Then
						ClassName = "ShowDialog"
						Set gateRs = cn.Execute("select name from gate where del=1 and ord in("&Valuse&") order by ord asc")
						If Not gateRs.EOF Then
							StrDialog = gateRs(0)
						end if
						gateRs.Close
						Set gateRs = Nothing
					end if
					GetItemHTML = "<table><tr><td>"&_
					"                    ""<input "" & FreshChildEvent & ""  name=""""Dialog_gateRadion""&item.selid&"""""" type=""""text"""" id=""""Dialog_gateRadion""&item.selid&"""""" Class=""""text""""  onclick=""""gatePerson.gateShowRadioDiv(this,'""& Valuse &""',""&item.selid&"");"""" ywname="""""" & Replace(Item.ywname, """""""", ""&quot;"") & """"""  value="""& StrDialog &"""  size=""8"" "
					Select Case Item.state
					Case 3
					GetItemHTML = GetItemHTML & " readonly class=" & app.IIf(Item.selid>0, "text", "billreadonlytext") & " >"
					Case 2
					GetItemHTML = GetItemHTML & " readonly class=" & app.IIf(Item.selid>0, "text", "billreadonlytext") & " >"
					Case 1
					GetItemHTML = GetItemHTML & " class=text >"
					End Select
					GetItemHTML = GetItemHTML & "<input type=hidden value="""& Valuse &""" dbname='" & Item.dbname & "'  ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "'></td>"
					If Item.notnull And Not mreadonly Then
						GetItemHTML = GetItemHTML & "<td>&nbsp;<span class=c_red>*</span></td>"
					end if
					GetItemHTML = GetItemHTML & "</tr></table>"
				end if
				Case "process"
				Dim procDiv, procTitle, ProcCnID, processID
				pxID = 0
				procDiv = "<table class='ProcessShow'><tr><td>未设置状态</td></tr></table>"
				If Item.defvalue<>"" And IsNumeric(Item.defvalue) Then
					Set procRs = server.CreateObject("adodb.recordset")
					proSql = "select title,cnID,px from hr_process where orderID="&Me.orderid&" and  del=0 order by px,cnID desc"
					procRs.Open proSql, cn, 1, 1
					If Not procRs.EOF Then
						procDiv = "<table class='ProcessStatus'>"
						procTitle = ""
						procIndateList = ""
						il = 1
						Do While Not procRs.EOF
							Set procLog = server.CreateObject("adodb.recordset")
							sqlLog = "select id,indate,creator,processID  from hr_process_log where orderID="&Me.orderid&" and processID="&procRs(1)&" and billID="&Me.sheetno&" and del=0"
							procLog.Open sqlLog, cn, 1, 1
							If Not procLog.EOF Then
								noneProc = False
								procIndate = procLog("indate")
								pxID = procRs("px")
							else
								noneProc = True
								procIndate = "未执行"
							end if
							procLog.Close
							Set procLog = Nothing
							If il = procRs.recordCount Then
								If noneProc = True Then
									isFirstCss = "LastCssNone"
								else
									isFirstCss = "LastCssHas"
								end if
							else
								If noneProc = True Then
									isFirstCss = "processNone"
								else
									isFirstCss = "processHas"
								end if
							end if
							procNote = procNote&"<td title='状态："&procRs(0)&"&#10执行时间："&procIndate&"' class='"&isFirstCss&"'>"&ss&"</td>"
							procTitle = procTitle&"<td class='ProcessTile'>"&procRs(0)&"</td>"
							il = il + 1
							procTitle = procTitle&"<td class='ProcessTile'>"&procRs(0)&"</td>"
							procRs.movenext
						Loop
						procSpace = ""
						If il>1 Then
							For si = 1 To il -1
'If il>1 Then
								procSpace = procSpace&"<td>&nbsp;</td>"
							next
						end if
						Set rs3 = cn.Execute("select top 1 px,title from hr_process where  orderID=" & Me.orderid &" and px>"&pxID&"  and  del=0 order by px,cnID desc")
						If Not rs3.EOF Then
							nextPxID = rs3("px")
						else
							nextPxID = 0
						end if
						rs3.Close
						Set rs3 = Nothing
						procHasSp = cn.Execute("select count(*) from "&Me.tablename&" where id="&Me.sheetno&" and status=3 and del=0")(0)
						If nextPxID<>0 And mreadonly And procHasSp>0 Then
							procSpace = "<tr>"&procSpace&"<td rowspan='3' align='center' valign='middle'><button id='processButton' class='button' onclick='process.showProcessDiv("&Me.orderid&","&Me.sheetno&","&nextPxID&","""&Item.dbname &""")'>执行</button></td></tr>"
						else
							procSpace = ""
						end if
						procDiv = procDiv&""&procSpace&"<tr>"&procNote&"</tr>"&"<tr>"&procTitle&"</tr>"&"</table><input type=hidden value="""&Item.defvalue&""" dbname='" & Item.dbname & "'  ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "' " & app.IIf(mreadonly, "readonly", "")&">"
					end if
					procRs.Close
					Set procRs = Nothing
				end if
				GetItemHTML = procDiv
				Case "sptable"
				GetItemHTML = getSpRecordHTML()
				Case "noticetable"
				GetItemHTML = getNoticeRecordHTML()
				Case "mbomplan"
				GetItemHTML = getMBOMPlanRecordHTML()
				Case "designtable"
				GetItemHTML = getDesignRecordHTML()
				Case "detail"
				If TypeName(Item.defvalue) = "DetailFields" Then
					If Len(Item.defvalue.mustEditMode) = 0 Then
						Item.defvalue.ReadOnly = mreadonly
					else
						Item.defvalue.ReadOnly = Not Item.defvalue.mustEditMode
					end if
					GetItemHTML = "<div onresize=ListFrameResize(this)  class='xDiatelScroll' id='xDiatelScroll" & index & "' onscroll='Bill.UIFixCell(this)'>" & Replace(Item.defvalue.getHTML(),"<table","<table onresize=ListFrameResize(this.parentNode) ",1,1,1) & "</div>"
				else
					GetItemHTML = "没有明细项目的定义信息。"
				end if
				Case "select"
				sql = "exec billcls_getfieldselect " & Item.selId & "," & app.info.user & ",'" & keySign & "'," & sheetno & "," & Abs(mreadonly) & ",'" &  ZBRuntime.ModulesText & "'"
				Set rs = server.CreateObject("adodb.recordset")
				Set rs = App.GetDataRecord(cn.Execute(App.SqlExtension(sql)))
				If Abs(Err.Number) > 0 Then
					Response.write "select类型检索sql错误：" & sql
				end if
				selCount = 0
				Set f1 = rs.fields(0)
				If rs.fields.Count = 2 Then
					Set f2 = rs.fields(1)
				else
					Set f2 = rs.fields(0)
				end if
				If mreadonly Then
					GetItemHTML = "<input autoCode=" & autoCode & " type=hidden  dbname='" & Item.dbname & "' name='" & InputId & "' value=""" & Replace(Replace(Item.defvalue & "", """", "&quot;"), vbCrLf, "&#13;&#10;") & """>"
					Dim isok
					isok=False
					While Not rs.EOF And isok=False
						If (f2.Value & "") = (Item.defvalue & "") Then
							GetItemHTML = GetItemHTML & "<span>" & f1.Value & "</span>"
							isok=True
							rs.movelast
						else
							rs.movenext
						end if
					wend
				else
					selHtml = "<select " & FreshChildEvent & "  autoCode=" & autoCode & " onkeydown = 'Bill.ItemKeyDown(this)' dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "' notnull=""" & Item.notnull & """ " & Width & ">"
					While Not rs.EOF
						If (f2.Value & "") = (Item.defvalue & "") Then
							selHtml = selHtml & "<option value=""" & f2.Value & """ selected>" & f1.Value & "</option>"
							selCount = selCount + 1
							selHtml = selHtml & "<option value=""" & f2.Value & """ selected>" & f1.Value & "</option>"
						else
							If Item.state = 1 Then
								selHtml = selHtml & "<option value=""" & f2.Value & """>" & f1.Value & "</option>"
								selCount = selCount + 1
								selHtml = selHtml & "<option value=""" & f2.Value & """>" & f1.Value & "</option>"
							end if
						end if
						rs.movenext
					wend
					If selCount = 0 Then selHtml = selHtml & "<option value=""" & Item.defvalue & """ selected>&nbsp;</option>"
					selHtml = selHtml & "</select>"
					If Item.notnull And Not mreadonly Then
						selHtml = selHtml & "&nbsp;<span class=c_red>*</span>"
					end if
					GetItemHTML =selHtml
				end if
				rs.close
				Case "date"
				pHtml = "<table class=textitemtable><tr><td>"
				pHtml = pHtml & "<input " & FreshChildEvent & "  dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ class=text style= 'border-right:0px;line-height:19px;height:19px;" & borderStyle & "' name='" & InputId & "' " & app.IIf(mreadonly, "readonly", "") & "onkeydown = 'Bill.ItemKeyDown(this)' type=text  & Width &   value=" & Item.defvalue & " notnull=" & Item.notnull & " dType=" & Item.dType & ""
				Select Case Item.state
				Case 3
				pHtml = pHtml & " readonly class=billreadonlytext></td>"
				Case 2
				pHtml = pHtml & " readonly class=billreadonlytext></td>"
				Case 1
				pHtml = pHtml & " class=billtext></td>"
				End Select
				pHtml = pHtml & "<td><button class=InselButton " & app.IIf(mreadonly, app.IIf(aReadOnly, "style='display:none'", "disabled"), "") & "  value='" & Item.selID & "' onclick='Bill.showDateDlg()' onfocus='this.blur()'><img class='resetElementHidden' src='../../images/datePicker.gif'><img class='resetElementShow' style='display:none' width='12' height='14' src='../../skin/default/images/MoZihometop/content/datePicker.png'></button></td>"
				If Item.notnull And Not mreadonly Then
					pHtml = pHtml & "<td>&nbsp;<span class=c_red>*</span></td>"
				end if
				GetItemHTML = pHtml & "</tr></table>"
				Case "sortonehy"
				Set rs = cn.execute("select sort1, ord from sortonehy where gate2=" & item.selid)
				selHtml = "<select " & FreshChildEvent & "  autoCode=" & autoCode & " onkeydown = 'Bill.ItemKeyDown(this)'"&_
				"dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "' " & Width & ">"
				While rs.EOF = false
					Set f1 = rs.fields(0)
					Set f2 = rs.fields(1)
					If (f2.Value & "") = (Item.defvalue & "") Then
						selHtml = selHtml & "<option value=""" & f2.Value & """ selected>" & f1.Value & "</option>"
						selCount = selCount + 1
						selHtml = selHtml & "<option value=""" & f2.Value & """ selected>" & f1.Value & "</option>"
					else
						If Item.state = 1 Then
							selHtml = selHtml & "<option value=""" & f2.Value & """>" & f1.Value & "</option>"
							selCount = selCount + 1
							selHtml = selHtml & "<option value=""" & f2.Value & """>" & f1.Value & "</option>"
						end if
					end if
					rs.movenext
				wend
				If selCount = 0 Then selHtml = selHtml & "<option value=""" & Item.defvalue & """ selected>" & Item.defvalue & "</option>"
				GetItemHTML = selHtml & "</select>"
				rs.close
				Case "datetime"
				pHtml = "<table class=textitemtable><tr><td>"
				pHtml = pHtml & "<input " & FreshChildEvent & "  dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ class=text style= 'border-right:0px;line-height:19px;height:19px;width:120px;" & borderStyle & "' name='" & InputId & "' " & app.IIf(mreadonly, "readonly", "") & " onkeydown = 'Bill.ItemKeyDown(this)' type=text " & Width & "  value=""" & Item.defvalue & """ notnull=""" & Item.notnull & """ dType=""" & Item.dType & """"
				Select Case Item.state
				Case 3
				pHtml = pHtml & " readonly class=billreadonlytext></td>"
				Case 2
				pHtml = pHtml & " readonly class=billreadonlytext></td>"
				Case 1
				pHtml = pHtml & " class=billtext></td>"
				End Select
				pHtml = pHtml & "<td><button class=InselButton " & app.IIf(mreadonly, app.IIf(aReadOnly, "style='display:none'", "disabled"), "") & "  value='" & Item.selID & "' onclick='Bill.showDateTimeDlg()' onfocus='this.blur()'><img class='resetElementHidden' src='../../images/datePicker.gif'><img class='resetElementShow' style='display:none' width='12' height='14' src='../../skin/default/images/MoZihometop/content/datePicker.png'></button></td>"
				If Item.notnull And Not mreadonly Then
					pHtml = pHtml & "<td>&nbsp;<span class=c_red>*</span></td>"
				end if
				GetItemHTML = pHtml & "</tr></table>"
				Case "space"
				GetItemHTML = Item.defvalue
				Case "treelist"
				Set rs = cn.Execute("select " & Me.keyfield & " from " & Me.tablename & " where " & Me.keyfield & "=" & Me.sheetno)
				If Not rs.EOF Then
					GetItemHTML = "<iframe src='treeedit.asp?orderid=" & Item.defvalue & "&parentid=" & Me.sheetno & "&PowerReadOnly=" & Abs(Me.ReadOnly) & "&readmode=" & Abs(aReadOnly * 1) & "' style='position:relative;width:100%;height:550px;top:-1px;left:-2px;z-index:5000' frameborder=no></iframe>" & vbCrLf & _
					"<script langauge=javascript>if(Bill.cmdClickEvent){Bill.cmdButtonClick = Bill.cmdClickEvent;Bill.cmdClickEvent=null;}</script>"
				else
					GetItemHTML = "&nbsp;提示：<span class=c_r id='tree_" & Item.dbname & "'>该项资料需要先完成基本资料并且保存后才能编辑。</span><script langauge=javascript>Bill.TreeEditSaveHook(" & Me.sheetno & ",""tree_" & Item.dbname & """," & Item.defvalue & ");</script>"
				end if
				rs.close
				Case "splist"
				selHtml = "<select" & FreshChildEvent & " dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "' " & Width & " id='next_sp_cateid' tag='splist' " & app.IIf(mreadonly, "disabled", "") & ">"
				If Sp.EOF Then
					selHtml = selHtml & "<option value=" & app.info.user & ">审批结束</option>"
				else
					selHtml = selHtml & "<option value=''>---请选择---</option>"
					selHtml = selHtml & "<option value=" & app.info.user & ">审批结束</option>"
					Set nextSp = Sp.List.Items(sp.currSpIndex)
					For I = 0 To UBound(nextSp.CanSpManArray)
						If TypeName(nextSp.CanSpManArray(i)) = "spManItem" Then
							Set man = nextSp.CanSpManArray(i)
							If (man.id & "") = (Item.defvalue & "") Then
								selHtml = selHtml & "<option value=""" & man.id & """ selected>" & man.Name & "</option>"
								selCount = selCount + 1
								selHtml = selHtml & "<option value=""" & man.id & """ selected>" & man.Name & "</option>"
							else
								If Item.state = 1 Then
									selHtml = selHtml & "<option value=""" & man.id & """>" & man.Name & "</option>"
									selCount = selCount + 1
									selHtml = selHtml & "<option value=""" & man.id & """>" & man.Name & "</option>"
								end if
							end if
						end if
					next
				end if
				GetItemHTML = selHtml & "</select>"
				Case Else
				If mreadonly Then Width = " style='width:100%' "
				If (Me.orderid = 1022 Or Me.orderid = 1043) And mreadonly Then
					If RegTest(Item.defvalue, "http://([\w-]+\.)+[\w-]+(/[\w-   ./?%&=]*)?") Then
'If (Me.orderid = 1022 Or Me.orderid = 1043) And mreadonly Then
						GetItemHTML = "<a href="& Item.defvalue &" title='点击链接到此网址' target='_blank'>"& Item.defvalue &"</a>"
					else
						GetItemHTML = Item.defvalue & "&nbsp;" & Item.unit
					end if
				else
					ConvertItemSelId(Item)
					If Item.selId > 0 Then
						If Item.dType<> "text" Then
							sql = "exec billcls_getfieldselect " & Item.selId & "," & app.info.user & ",'" & keySign & "'," & sheetno & "," & Abs(mreadonly) & ",'" & ZBRuntime.ModulesText & "'"
						else
							sql = "select 1 as a,2 as b, 3 as c"
						end if
						Set rs = server.CreateObject("adodb.recordset")
						Set rs = App.GetDataRecord(cn.Execute(App.SqlExtension(sql)))
						If Abs(Err.Number) > 0 And app.info.debugmode Then
							Response.write sql
						end if
						If rs.fields.Count = 1 Then
							If Not rs.EOF Then
								ReDim TArray(4) , VArray(4)
								selCount = 0
								selHtml = "<select " & FreshChildEvent & " autoCode=" & autoCode & " onkeydown = 'Bill.ItemKeyDown(this)' dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "' " & Width & app.IIf(mreadonly, "disabled", "") & ">"
								Set f1 = rs.fields(0)
								While Not rs.EOF
									If selCount<5 Then
										TArray(selCount) = f1.Value
										VArray(selCount) = f1.Value
									end if
									If f1.Value = Item.defvalue Then
										selHtml = selHtml & "<option value=""" & f1.Value & """ selected>" & f1.Value & "</option>"
										selCount = selCount + 1
										selHtml = selHtml & "<option value=""" & f1.Value & """ selected>" & f1.Value & "</option>"
									else
										If Item.state = 1 Then
											selHtml = selHtml & "<option value=""" & f1.Value & """>" & f1.Value & "</option>"
											selCount = selCount + 1
											selHtml = selHtml & "<option value=""" & f1.Value & """>" & f1.Value & "</option>"
										end if
									end if
									rs.movenext
								wend
								If selCount = 0 Then selHtml = selHtml & "<option value=""" & Item.defvalue & """ selected>" & Item.defvalue & "</option>"
								If selCount <= 3 Then
									GetItemHTML = "<input type=hidden dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "' value='" & Item.defvalue & "'>" & CRadioList(TArray , VArray, InputId , Item)
								else
									GetItemHTML = selHtml & "</select>"
								end if
							else
								Dim sBoxArray , sTitle, hs
								hs = true
								If Item.selID > 0 Then
									Dim selectv
									hs = False
									selectv = Item.defvalue
									sBoxArray = getbillselectlist(Item.selId, selectv, hs)
									If selectv = Item.defvalue Then
									end if
									If selectv <> Item.defvalue Then
										sTitle = " title=""" & Item.defvalue & """ "
										Item.selhidevalue = Item.defvalue
										Item.defvalue = selectv
									end if
									If Len( sBoxArray ) > 0 Then
										sBoxArray = "  sBoxArray=""" & sBoxArray & """ onchange='Bill.getbillselectv(this)'"
									end if
								end if
								pHtml = "<table class=textitemtable ><tr><td>"
								pHtml = pHtml & "<input autoCode=" & autoCode & " style= 'border-right:0px;line-height:19px;height:19px;" & borderStyle & "' " & FreshChildEvent & " " & sBoxArray & " " & sTitle & " dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ "& app.IIf(mreadonly, "readonly", "onkeydown = 'Bill.ItemKeyDown(this)' onkeyup='Bill.ItemKeyUp(this)'") & "  name='" & InputId & "' type=text " & Width & " hsdeleted=" & Abs(hs) & " value=""" & Replace(Item.defvalue & "", """", "&#34;") & """ notnull=""" & Item.notnull & """ dType=""" & Item.dType & """ "
								Select Case Item.state
								Case 3
								pHtml = pHtml & " readonly class=" & app.IIf(Item.selid>0, "text", "billreadonlytext") & "></td>"
								Case 2
								pHtml = pHtml & " readonly class=" & app.IIf(Item.selid>0, "text", "billreadonlytext") & "></td>"
								Case 1
								pHtml = pHtml & " class=text></td>"
								End Select
								If Item.selId > 0 Then
									pHtml = pHtml & "<td><button  onfocus='this.blur()' " & app.IIf(mreadonly, app.IIf(aReadOnly, "style='display:none'", "disabled"), "") & " class=InselButton selid='" & Item.selID & "' onclick='menu.showbtnlist(this)' Mfield=1><img src='../../images/11645.png' height=13></button></td>"
								end if
								If Item.notnull And Not mreadonly Then
									pHtml = pHtml & "<td>&nbsp;<span class=c_red>*</span></td>"
								end if
								GetItemHTML = pHtml & "<td>&nbsp;" & Item.unit & "</td></tr></table>"
							end if
						ElseIf rs.fields(0).Name = "billselectname" And rs.fields.Count = 2 Then
							Dim selText
							selText = ""
							selCount = 0
							selHtml = "<select " & FreshChildEvent & " autoCode=" & autoCode & " onkeydown = 'Bill.ItemKeyDown(this)' dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "' " & Width & app.IIf(mreadonly, "disabled", "") & ">"
							Set f1 = rs.fields(0)
							Set f2 = rs.fields(1)
							ReDim TArray(4) , VArray(4)
							While Not rs.EOF
								If selCount<5 Then
									TArray(selCount) = f1.Value
									VArray(selCount) = f2.Value
								end if
								If (f2.Value & "") = (Item.defvalue & "") Then
									selHtml = selHtml & "<option value=""" & f2.Value & """ selected>" & f1.Value & "</option>"
									selText = f1.Value
									selCount = selCount + 1
									selText = f1.Value
								else
									If Item.state = 1 Then
										selHtml = selHtml & "<option value=""" & f2.Value & """>" & f1.Value & "</option>"
										selCount = selCount + 1
										selHtml = selHtml & "<option value=""" & f2.Value & """>" & f1.Value & "</option>"
									end if
								end if
								rs.movenext
							wend
							If selCount = 0 Then selHtml = selHtml & "<option value=""" & Item.defvalue & """ selected>" & Item.defvalue & "</option>"
							If selCount <= 4 Then
								GetItemHTML = "<input type=hidden dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "' value='" & Item.defvalue & "'>" & CRadioList(TArray , VArray, InputId , Item)
							else
								If mreadonly Then
									GetItemHTML = "<input type=hidden name='" & InputId & "' value=""" & Replace(Replace(Item.defvalue & "", """", "&quot;"), vbCrLf, "&#13;&#10;") & """>"
									GetItemHTML = GetItemHTML & "<span>" & selText & "</span>"
								else
									GetItemHTML = selHtml & "</select>"
								end if
							end if
						else
							pHtml = "<table class=textitemtable><tr><td>"
							pHtml = pHtml & "<input " & FreshChildEvent & " autoCode=" & autoCode & "  style= 'border-right:0px;line-height:19px;height:19px;" & borderStyle & "' dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """ " & app.IIf(mreadonly, "readonly", "onkeydown = 'Bill.ItemKeyDown(this)' onkeyup='Bill.ItemKeyUp(this)'") & "   name='" & InputId & "'  type=text " & Width & " value=""" & Replace(Item.defvalue & "", """", "&#34;") & """ notnull=""" & Item.notnull & """ dType=""" & Item.dType & """"
							Select Case Item.state
							Case 3
							pHtml = pHtml & " readonly class=" & app.IIf(Item.selid>0, "text", "billreadonlytext") & "></td>"
							Case 2
							pHtml = pHtml & " readonly class=" & app.IIf(Item.selid>0, "text", "billreadonlytext") & "></td>"
							Case 1
							pHtml = pHtml & " class=text></td>"
							End Select
							If Item.selId > 0 Then
								pHtml = pHtml & "<td><button onfocus='this.blur()' " & app.IIf(mreadonly, app.IIf(areadonly, "style='display:none'", "disabled"), "") & " class=InselButton  Mfield=1 selid='" & Item.selID & "' onclick='menu.showbtnlist(this)'><img src='../../images/11645.png' height=13></button></td>"
							end if
							If Item.notnull And Not mreadonly Then
								pHtml = pHtml & "<td>&nbsp;<span class=c_red>*</span></td>"
							end if
							GetItemHTML = pHtml & "<td>&nbsp;" & Item.unit & "</td></tr></table>"
						end if
						rs.close
					else
						
						
						if request("orderid")&"" = "1029" And mreadonly then
							GetItemHTML  = Replace(Item.defvalue & "", """", "&#34;")
						else
							pHtml = "<table class=textitemtable><tr><td>"
							pHtml = pHtml & "<input style= 'line-height:19px;height:19px;" & borderStyle & "' " & FreshChildEvent & " autoCode=" & autoCode & " dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname, """", "&quot;") & """  name='" & InputId & "' " & app.IIf(mreadonly, "readonly", "onkeydown = 'Bill.ItemKeyDown(this)'") & " type=text " & Width & " value=""" & Replace(Item.defvalue & "", """", "&#34;") & """  notnull=""" & Item.notnull & """ dType=""" & Item.dType & """"
							Select Case Item.state
							Case 3
							pHtml = pHtml & " readonly class=" & app.IIf(Item.selid>0, "text", "billreadonlytext") & "></td>"
							Case 2
							pHtml = pHtml & " readonly class=" & app.IIf(Item.selid>0, "text", "billreadonlytext") & "></td>"
							Case 1
							pHtml = pHtml & " class=text></td>"
							End Select
							If Item.notnull And Not mreadonly Then
								pHtml = pHtml & app.IIf(areadonly, "", "<td>&nbsp;<span class=c_red>*</span></td>")
							end if
							GetItemHTML = pHtml & "<td>&nbsp;" & Item.unit & "</td></tr></table>"
						end if
					end if
				end if
				End Select
			end function
			Private Function GetReplyHtml
				Dim rs, sort1, sql, qx_intro, htmls, rcount
				Dim itemhtml, mydata, fw, idurl, id, css
				ReDim htmls(5)
				id = sheetno
				sort1 = CLng(OrderId + 100000)
				id = sheetno
				qx_intro = "0"
				Set rs = cn.execute("select case qx_open when 3 then '' when 1 then qx_intro else '0' end from power x where x.ord=" & app.Info.user & " and sort1='" & qxlb & "' and sort2=5")
				If rs.eof = False Then
					qx_intro = rs.fields(0).value
				end if
				rs.close
				If Len(qx_intro) > 0 Then
					qx_intro = " and cateid in (" & qx_intro & ")"
				end if
				htmls(0) = "<table style='width:100%'><col width='95px'><col width='95px'><col style='word-break:break-all'>"
				qx_intro = " and cateid in (" & qx_intro & ")"
				sql = "select top 4 convert(varchar(10), date7, 120) as ShortD," & _
				" isnull((select top 1 sort1 from sortonehy where ord=r.sort98),'') as rType, " & _
				" intro, id, cateid, date7, name, name2, uploadfile " & _
				"from reply r where ord2="& ID &" and sort1=" & sort1 & " and del=1 " & qx_intro & " order by date7 desc"
				Set rs = cn.execute(sql)
				If rs.eof Then
					htmls(1) = "<tr><td height='25' style='border:0px' colspan=3><div align='center'>暂无接洽！</div></td></tr>"
				else
					rcount = 0
					while rs.eof = False
						rcount = rcount + 1
'while rs.eof = False
						If rcount < 4 Then
							mydata = (CLng(rs("cateid")) = CLng(app.Info.user))
							fw     = rs("date7")>dateadd("d",-1,now)
							mydata = (CLng(rs("cateid")) = CLng(app.Info.user))
							idurl  = app.base64.pwurl(rs("id").value)
							uploadfile=rs("uploadfile")
							css = ""
							If rcount = 1 Then
								css = " style='border-top:0px' "
'If rcount = 1 Then
							end if
							itemhtml = "<tr><td class='billfieldleft'" & css & "><div align='center'>" & rs("ShortD").value & "</div></td>" & _
							"<td class='billfieldleft'" & css & "><div align='center'>" & rs("rType").value & "</div></td>" & _
							"<td class='billfieldleft'" & css & "><div align='left' style='padding:4px;line-height:22px;'>" & rs("intro").value
							If Len(uploadfile&"""")>0 Then  itemhtml = itemhtml & Getuploadfile(uploadfile)
							itemhtml = itemhtml & "(跟进："& rs("name").value & "&nbsp;&nbsp;"
							if rs("name2")<>"" Then
								itemhtml = itemhtml & "对方联系人：" & rs("name2") & "&nbsp;&nbsp;"
							end if
							itemhtml = itemhtml & rs("date7") & ")"
							if IsAllowHandle(rs("cateid"),rs("date7"),0)  Then
								itemhtml = itemhtml & "&nbsp;<button onClick=""javascript:window.open('correctreply.asp?ord="& idurl & "','newwin22','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=150,top=150')""  class='button'>修改</button>"
'if IsAllowHandle(rs("cateid"),rs("date7"),0)  Then
							end if
							if IsAllowHandle(rs("cateid"),rs("date7"),1)  Then
								itemhtml = itemhtml &  "&nbsp;<button onClick=""if(confirm('确认删除？')){window.location.href='delreply.asp?ord="& app.base64.pwurl(ID) &"&id="& idurl &"&url1=" & server.urlencode(request.servervariables("url") & "?" & request.querystring) & "'}"" class='button'>删除</button>"
							end if
							if session("cateidzbintel")<>"4" Then
								itemhtml = itemhtml & "&nbsp;<button onClick=""javascript:window.open('../../contract/dianpin.asp?ord="& idurl &"&sortreply="&app.base64.pwurl(4)&"','newwin22','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=150,top=150')""  class='button'>点评</button>"
							end if
							Dim rs7
							set rs7 =cn.execute("select id,intro,name,cateid,date7 from dianping where ord="& rs("id") &"  and sort=4 order by date7 desc")
							do until rs7.eof
								itemhtml = itemhtml &  "<br><font style='color:red'>&nbsp;点评："&rs7("intro")&"(点评人："&rs7("name")&"&nbsp;&nbsp;"&rs7("date7")&")</font>"
								if CLng(rs7("cateid"))= CLng(app.Info.User) and rs7("date7")>dateadd("d",-1,now) Then
									itemhtml = itemhtml &  "&nbsp;<button onClick=""javascript:window.open('../../contract/correctdp.asp?ord="& app.base64.pwurl(rs7("id"))&"','newwin22','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=150,top=150')""  class='button'>修改</button>"
									itemhtml = itemhtml & "&nbsp;<button onClick=""if(confirm('确认删除？')){window.location.href='deldp.asp?ord="&app.base64.pwurl(ID)&"&id="& app.base64.pwurl(rs7("id"))&"&url1=" & server.urlencode(request.servervariables("url") & "?" & request.querystring) & "'}"" class='button'>删除</button>"
								end if
								rs7.movenext
							loop
							rs7.close
							itemhtml = itemhtml & "</div></td></tr>"
							htmls(rcount) = itemhtml
						end if
						rs.movenext
					wend
				end if
				rs.close
				set rs = nothing
				If rcount > 3 Then
					htmls(4) = "<tr><td colspan=3 class='billfieldleft'><div align='right'><a href=""javascript:void(0)"" onclick=""javascript:window.open('reply_list.asp?ord=" & ID & "&sort1=" & CStr(orderid+100000) & "&mtype=all','newwins3d3','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=150,top=150')"" title='点击查看更多进展' ><font style='color:red'>查看更多洽谈进展..&gt;&gt;&gt;</font></a></div></td></tr>"
				end if
				htmls(5) = "</table>"
				GetReplyHtml = Join(htmls,"")
			end function
			Private Function getbillselectlist(byval sid, ByRef v, ByRef hsdeleted)
				Dim sql , vv
				If sID > 10000000 Then
					sql = "sql=select CValue as billselectname from M_CustomOptions where del = 0 and CFID= " & (sID - 10000000) & ""
'If sID > 10000000 Then
				else
					Set rs = cn.Execute("select  SQLString from M_CustomSQLStrings where ID=" & sID)
					sql = Replace(rs.fields(0).Value & "", Chr(0), "")
					rs.close
				end if
				If InStr(1, sql, "sql=", 1) = 1 Then
					sql = Right(sql, Len(sql) -4)
'If InStr(1, sql, "sql=", 1) = 1 Then
					hsdeleted = true
					sql = Replace(sql, "@key", "''", 1, -1, 1)
					hsdeleted = true
					sql = Replace(sql, "@uid", app.info.user , 1, -1, 1)
					hsdeleted = true
					sql = Replace(sql, "@bill_id", Me.sheetno, 1, -1, 1)
					hsdeleted = true
					sql = Replace(sql, "@bill_cls", Me.OrderId, 1, -1, 1)
					hsdeleted = true
					sql = Replace(sql, "@PrefixCode", "'" & Me.keysign & "'", 1, -1, 1)
					hsdeleted = true
					sql = Replace(sql, "@PrefixCode", "'" & Me.keysign & "'", 1, -1, 1)
					hsdeleted = true
					sql = Replace(sql, "@@istreemode", "-1111217", 1, -1, 1)
					hsdeleted = true
					sql = Replace(sql, "@@readonly", Abs(mreadonly), 1, -1, 1)
					hsdeleted = true
					sql =replace(sql,"@models","'" & ZBRuntime.ModulesText & "'")
					For i = 1 To mainfields.Count
						If IsObject(mainfields.Items(i).defvalue) = False Then
							vv = mainfields.Items(i).selhideValue
							If Len(vv) = 0 Then
								vv = mainfields.Items(i).defvalue
							end if
							sql = Replace(sql , "@" & mainfields.Items(i).dbname, "'" & vv & "'", 1, -1, 1)
							vv = mainfields.Items(i).defvalue
						end if
					next
					sql = App.SqlExtension(sql)
					If InStr(sql, "@") = 0 Then
						Set rs = App.GetDataRecord(cn.Execute(sql))
						If LCase(rs.fields(0).Name) = "billselectname" And rs.fields.Count = 2 Then
							While Not rs.EOF
								getbillselectlist = getbillselectlist & _
								"(Replace(Replace(Replace(Replace(rs.fields(1).Value & """", Chr(0), """"), """""""", ""$“""), "";"", ""$；""), ""="", ""$-"") & ""="" & Replace(Replace(Replace(Replace(rs.fields(0).Value & """", Chr(0), """"), """""""", ""$“""), "";"", ""$；""), ""="", ""$-"") & "";"")"
								If RTrim(rs.fields(1).Value) & """" = RTrim(v) Then
									v = Replace(rs.fields(0).Value, Chr(0), "")
									hsdeleted = false
								end if
								rs.movenext
							wend
						end if
						rs.close
					end if
					If hsdeleted = true Then
						v = ""
					end if
				end if
			end function
			Function convertTreeBox(value , selid)
				Dim sql, rs
				Set rs =  cn.execute("select SqlString from dbo.M_CustomSQLStrings where id=" & selid)
				If rs.eof = False Then
					sql = rs.fields(0).value & ""
					rs.close
					If Len(value & "") = 0 Then value = 0
					Set rs = cn.execute(Replace(Replace(Replace(sql, "@id", value),"@parentid","-1"),"sql=",""))
					If Len(value & "") = 0 Then value = 0
					If rs.eof = False Then
						convertTreeBox = convertTreeBox(rs.fields("parentID").value,selid) & "&nbsp;" & rs.fields("title").value
					end if
				else
				end if
				rs.close
				set rs = nothing
			end function
			Function convertSearch(value , selid)
				If Len(value & "") = 0 Then exit Function
				If selid=1068 And value=0 then session("companyzbintel")=""
				Dim sql, rs
				Set rs =  cn.execute("select SqlString from dbo.M_CustomSQLStrings where id=" & selid)
				If rs.eof = False Then
					sql = rs.fields(0).value & ""
					rs.close
					Set rs = cn.execute(Replace(Replace(Replace(sql,"@uid",app.Info.user), "@id", value),"sql=",""))
					If rs.eof = False Then
						convertSearch = rs.fields(0).value
						If selid=1068 then session("companyzbintel")=value
					else
						convertSearch = ""
					end if
				else
				end if
				rs.close
				set rs = nothing
			end function
			function getGateField(item , InputId, IsAll)
				Dim orderid, i
				orderid = request.querystring("orderid")
				Dim gateRs, gateStrList , fullGateStrList
				gateStrList = ""
				fullGateStrList = ""
				If InStr(","&Item.defvalue&",", ",0,")>0 Then
					gateStrList = "所有用户"
					fullGateStrList = gateStrList
				else
					If Item.defvalue<>"" Then
						Set gateRs = cn.Execute("select name from " & app.iif(IsAll,"sys_gate_view where ","gate  where del=1 and ") & "ord in("& Item.defvalue &") order by cateid,ord asc")
						If Not gateRs.EOF Then
							Do While Not gateRs.EOF
								If gateStrList = "" Then
									gateStrList = gateRs(0).value
								else
									gateStrList = gateStrList &"+"& gateRs(0).value
									gateStrList = gateRs(0).value
								end if
								gateRs.movenext
							Loop
							fullGateStrList = gateStrList
							If Len(gateStrList)>10 Then gateStrList = Left(gateStrList, 8)&"..."
						else
							gateStrList = "请选择"
							fullGateStrList = gateStrList
						end if
						gateRs.Close
						Set gateRs = Nothing
					else
						gateStrList = "请选择"
						fullGateStrList = gateStrList
					end if
				end if
				Select Case orderid
				Case 1030
				i = 1
				Case Else
				i = 0
				End Select
				If mreadonly Then
					getGateField = fullGateStrList
				else
					getGateField = "<input class=sortBtn onclick=""Bill.currSortBoxName='" & InputId & "';gatePerson.showGatePersonDiv(document.getElementsByName('"& InputId &"')[0].value,"&i&")"" value="""&gateStrList&""" title="""&fullGateStrList&""" type=button> <input type=hidden value="""&Item.defvalue&""" dbname='" & Item.dbname & "'  ywname=""" & Replace(Item.ywname, """", "&quot;") & """ name='" & InputId & "' " & app.IIf(mreadonly, "readonly", "")&">"
				end if
			end function
			Public Function GMBD(ByVal dbname)
				Set GMBD = GetMainFieldByDBname(dbname)
			end function
			Public Function GetMainFieldByDBname(dbname)
				Dim I
				dbname = LCase(dbname)
				For I = 1 To mainfields.Count
					If LCase(mainfields.Items(i).dbname) = dbname Then
						Set GetMainFieldByDBname = mainfields.Items(i)
						Exit Function
					end if
				next
				Set GetMainFieldByDBname = Nothing
			end function
			Private Function GetDefSpMan()
				Set rs = cn.Execute("select top 1 isnull(DefaultID,0) from M_FlowDefault where sp_id >=" & Me.id_spValue & " and PrefixCode='" & keySign & "' and cateid=" & app.info.user & " order by sp_id")
				If rs.EOF Then
					GetDefSpMan = 0
				else
					GetDefSpMan = rs.fields(0).Value
				end if
				rs.close
				set rs = nothing
			end function
			Public Function LoadChangeRemarkMsg
				Dim chgremark
				If request.querystring("changelogid") <> "" Then
					Dim rs : Set rs = cn.execute("select remark, indate, (select top 1 name from gate where ord=x.creator) as cname from erp_bill_ChangeLog x where id=" & CLng("0" & request.querystring("changelogid") ))
					If rs.eof = False Then
						chgremark = Replace(rs(0).value & "",";","；")
						Me.SetUIFields "变更时间;sys_change_time;1;textarea;0;" & rs("indate").value & ";1;变更信息;3;100"
						Me.SetUIFields "变更人员;sys_change_gate;1;textarea;0;" & rs("cname").value & ";1;变更信息;3;100"
					end if
					rs.close
				ElseIf me.OrderId = 5 Then
					if sdk.Power.ExistsManu(3) and sdk.Power.ExistsModel(18200) Then
						Me.SetUIFields ";;1;MBOMPlan;0;0;0;同步更新关联生产计划;3;100"
					else
						Me.SetUIFields ";;1;MBOMPlan;0;0;0;同步更新关联生产订单;3;100"
					end if
				end if
				Me.SetUIFields "变更原因;sys_change_remark;1;textarea;0;" & chgremark & ";1;变更信息;3;100"
				Me.SetUIFields "审批人;" & checkmanField & ";5;splist;0;0;1;变更信息;1;100"
			end function
			Public Function LoaddefCheckField
				Dim v , hasdefspm , defspm , defhtml
				Set Sp = New SpHandClass
				Sp.loadbillconfig Me
				Sp.getdata
				defspm = Abs(GetDefSpMan)
				Me.splogID = request.Form("splogID")
				If Len(Me.splogID) = 0 Then Me.splogID = request.querystring("splogid")
				If Len(Me.splogID) = 0 Then Me.splogID = 0
				If Not IsNumeric(Me.splogID) = 0 Then Me.splogID = 0
				Me.splogID = CLng(Me.splogID)
				If Me.splogID = 0 Then
					Set rs = cn.Execute("select top 1 ID,cateid_sp,result_sp,isnull(backrank,0) as backrank from M_flowlogs where prefixcode = '" & Me.keysign & "' and orderid=" & Me.sheetno & " order by id desc")
					If Not rs.EOF Then
						If CInt(rs.fields(1).Value) = CInt(app.info.user) And (rs.fields(2).Value=1 Or (rs.fields(2).Value=0 and ( sp.CurrSpIndex=-1 Or rs.fields(3).Value>0) ) ) Then
'If Not rs.EOF Then
							Me.splogID = rs.fields(0).Value
							If getCanSpUpdate(OrderId, keySign, sheetno) = 1 then
								Me.cmdbuttons.Items(5).text = "改批"
							else
								Me.cmdbuttons.Items(5).visible = False
							end if
						else
							if sp.CurrSpGate - app.info.user <> 0 then
								Me.cmdbuttons.Items(5).visible = False
								Me.cmdbuttons.Items(5).visible = False
							end if
						end if
					else
						if sp.CurrSpGate - app.info.user <> 0 then
							Me.cmdbuttons.Items(5).visible = False
							Me.cmdbuttons.Items(5).visible = False
						else
							If cn.execute("select 1 from M_FlowSettings where prefixcode = '" & Me.keysign & "' ").eof Then
								Me.cmdbuttons.Items(5).visible = False
							else
								Me.cmdbuttons.Items(5).text = "审批"
							end if
						end if
					end if
					rs.close
				else
					Me.cmdbuttons.Items(5).text = "改批"
				end if
				If app.power.CheckPower(Me.qxlb,16,Me.Creator) = false Then
					Me.cmdbuttons.Items(5).visible = False
				end if
				If defspm > 0 Then
					If Not getappreadonly Then
						defhtml = ";#spaaas;1;space;0;&nbsp；<input type=checkbox checked id=spselbox onclick=Bill.setDefCheckMan(this)><label for=spselbox id=spselboxlabel>默认该审批人</label>&nbsp；<span class=c_g>选择单据对应的审核人</span>;0;审批设置;2;"
						Me.SetUIFields "审批人;" & checkmanField & ";1;splist;0;0;1;审批设置;1;100|" & defhtml
					else
						defhtml = ""
						Me.SetUIFields "审批人;" & checkmanField & ";5;splist;0;0;1;审批详情;1;100|" & defhtml
					end if
				else
					If Not getappreadonly Then
						defhtml = ";#spaaas;1;space;0;&nbsp；<input type=checkbox  id=spselbox onclick=Bill.setDefCheckMan(this)><label for=spselbox id=spselboxlabel>默认该审批人</label>&nbsp；<span class=c_g>选择单据对应的审核人</span>;0;审批设置;2;"
					else
						defhtml = ""
					end if
					If Me.getappreadonly Then
						Me.SetUIFields "审批人;" & checkmanField & ";5;splist;0;0;1;审批详情;1;100|"
					else
						Me.SetUIFields "审批人;" & checkmanField & ";1;splist;0;0;1;审批设置;1;100|" & defhtml
					end if
				end if
				If Not Sp.EOF Then
					Set Item = GetMainFieldByDBname(checkmanField)
					Set NextItem = Sp.List.Items(Sp.CurrSpIndex)
					Set rs = cn.Execute("select " & checkmanField & " from " & TableName & " where " & keyField & "=" & Me.sheetno)
					If rs.EOF Then
						Item.defvalue = GetDefSpMan()
					else
						v = rs.fields(0).Value & ""
						If Len(v) = 0 Or Not IsNumeric(v) Then
							v = GetDefSpMan()
						else
							If Abs(v) < 1 Then
								v = GetDefSpMan()
							end if
						end if
						Item.defvalue = v
					end if
					on error resume next
					rs.close
					set rs = nothing
					Me.checkHiddenField = "    <input type=hidden id='Bill_Info_nextspid' value='" & NextItem.Rank & "'>" & vbCrLf & "     <input type=hidden id='Bill_Info_outspid' value='" & Sp.OutSpIdText & "'>"
				else
					Me.checkHiddenField = "    <input type=hidden id='Bill_Info_nextspid' value='-1'>" & vbCrLf & "  <input type=hidden id='Bill_Info_outspid' value='" & Sp.OutSpIdText & "'>"
				end if
			end function
			Public Sub addCPZdyUIFields(ByVal afterField, ByVal cpIDKey, ByVal hasParentRemark)
				Dim i, ii, nitem, rs
				me.cpZdyIDKey = cpIDKey
				Dim fd : Set fd = GetMainFieldByDBname(afterField)
				For I = 1 To mainfields.Count
					If LCase(mainfields.Items(i).dbname) = LCase(afterField) Then
						Set afitem = mainfields.Items(i)
						Set rs = cn.execute("select title, name, set_open from zdy where sort1=21 order by gate1 desc, id desc")
						While rs.eof = False
							Set nitem =  New mField
							nitem.Group = afitem.Group
							nitem.dbname = "sys_cp_" & rs("name").value
							nitem.ywname = rs("title").value
							If rs("set_open").value = 1 then
								nitem.state = 3
							else
								nitem.state = 5
							end if
							nitem.selid = ProductField
							nitem.dtype = "text"
							mainfields.InsertAfter nitem,i
							rs.movenext
						wend
						rs.close
						If hasParentRemark Then
							Set nitem =  New mField
							nitem.Group =  "备注"
							nitem.dbname = "sys_parent_remark"
							nitem.ywname = "订单备注"
							nitem.colspan = 3
							nitem.state = 3
							nitem.defvalue = ""
							nitem.dtype = "text"
							mainfields.add nitem
						end if
						Exit sub
					end if
				next
			end sub
			Public Sub SetUIFields(FieldConfig)
				Dim fields , v
				fields = Split(Replace(FieldConfig, ",", ";"), "|")
				For I = 0 To UBound(fields)
					Items = Split(fields(i), ";")
					If IsArray(Items) Then
						If UBound(Items) > 0 Then
							Set fd = New mField
							For II = 0 To UBound(Items)
								If Len(Items(ii) & "") >0 Then
									v = Replace(Replace(Replace(Items(ii), "[]", ""), "；", ";"), "，", ",")
									v = Replace(v, "@uid", app.info.user)
									v = Replace(v, "@bill_parentID", Me.ParentSheetNo)
									Select Case II
									Case 0
									fd.ywName = v
									Case 1
									fd.dbName = v
									Case 2
									fd.state = v
									Case 3
									fd.dType = v
									Case 4
									fd.selID = v
									Case 5
									fd.defvalue = v
									Case 6
									fd.notnull = (v = "1")
									Case 7
									fd.group = v
									Case 8
									fd.colspan = v
									Case 9
									fd.Width = v
									Case 10
									fd.RefreshChild = v
									Case 11
									fd.IsParentField = (v = "1")
									Case 12
									fd.linkCode = v
									Case 13
									fd.unit = v
									Case 15
									fd.UIType = v
									End Select
								end if
							next
							mainfields.Add(fd)
						end if
					end if
				next
			end sub
			Public Function GetNewIDNumber()
				Dim mGetNewIDNumber
				If Len(Me.OrderId) = 0 Then Me.OrderId = 0
				Set rs = App.GetRecord(cn, "select max(" & keyfield & ")+1 from (select " & keyfield & " from " & tablename & " union all select bid from M_billThreadControl where oid=" & Me.OrderId & " and uid<>" & app.info.user & " and sctype=0) x")
				If Len(Me.OrderId) = 0 Then Me.OrderId = 0
				If rs.EOF Then
					mGetNewIDNumber = 1
				else
					mGetNewIDNumber = rs.fields(0).Value & ""
					If Len(mGetNewIDNumber) = 0 Then
						mGetNewIDNumber = 1
					end if
				end if
				rs.close
				sql = "if not exists(select 1 from M_billThreadControl where oid=@oid and uid=@uid and sctype=0 and bid=@bid) " & vbCrLf & _
				"begin" & vbCrLf & _
				" insert into  M_billThreadControl (oid, bid, uid,sctype, date) values (@oid,@bid,@uid,0,getdate())" & vbCrLf & _
				"end"
				sql = Replace(Replace(Replace(sql, "@oid", Me.OrderId), "@bid", mGetNewIDNumber), "@uid", app.info.user)
				cn.Execute sql
				GetNewIDNumber = mGetNewIDNumber
			end function
			Public Sub createJsInfoField
				Dim sql, sp_id
				
				on error resume next
				sql = "select xx2.bid,min(xx1.rank) as sp__id , cast(xx3.creator as nvarchar(20)) as cr" & vbCrLf &_
				" from M_Flowsettings xx1, @TableName xx3," & vbCrLf &_
				" (" & vbCrLf &_
				"    select isnull(sp_id,0) as sp_id,bid from(" & vbCrLf &_
				"            select" & vbCrLf &_
				"            (case a.result_sp when 1 then (case sign(isnull(a.backrank,0)) when 0 then a.sp_id  else a.backrank-1 end) else  0 end) as sp_id,  --当前最大流程状态" & vbCrLf &_
				"            select" & vbCrLf &_
				"            b.@keyField as bid" & vbCrLf &_
				"            from  M_FlowLogs a, @TableName b" & vbCrLf &_
				"            where  a.orderid = b.ID and a.PrefixCode = '@bSign'" & vbCrLf &_
				"           and exists(select max(e.id) from m_flowlogs e where PrefixCode = '@bSign' group by orderid having max(e.id)=a.id)" & vbCrLf &_
				"    ) dssdas" & vbCrLf &_
				"    union all" & vbCrLf &_
				"    select  0,id from @TableName a where not exists (select OrderID from M_FlowLogs b where b.OrderID =a.@keyField and b.prefixcode='@bSign')" & vbCrLf &_
				"  ) xx2" & vbCrLf &_
				"  where xx1.PreFixCode = '@bSign' and xx2.bid= " & sheetno & vbCrLf &_
				"  and xx1.rank >= xx2.sp_id and xx3.@keyField=xx2.bid " & vbCrLf &_
				"group by xx2.bid , xx3.creator"
				sql = Replace(sql, "@TableName", Me.TableName,1,-1,1)
				sql = Replace(sql, "@bSign", Me.keySign,1,-1,1)
				sql = Replace(sql, "@keyField", Me.keyField,1,-1,1)
				Set rs = cn.execute(sql)
				If Err.number = 0 then
					If rs.eof =False Then
						sp_id = rs("sp__id").value
					else
						sp_id = 0
					end if
					rs.close
				end if
				On Error GoTo  0
				app.printl "<div id='Bill_Info_div'>"
				app.printl "        <input type=hidden id='Bill_Info_type' value='" & OrderId & "'>"
				app.printl "        <input type=hidden id='Bill_Info_id' value='" & sheetno & "'>"
				app.printl "        <input type=hidden id='Bill_Info_pid' value='" & parentsheetno & "'>"
				app.printl "        <input type=hidden id='Bill_Info_sign' value='" & keySign & "'>"
				app.printl "        <input type=hidden id='Bill_Info_curridsp' value='" & id_spValue & "'>"
				app.printl "        <input type=hidden id='Bill_Info_sp__id' value='" & sp_id & "'>"
				app.printl "        <input type=hidden id='Bill_Info_user' value='" & app.info.user & "'>"
				app.printl "        <input type=hidden id='Bill_Info_readonly' value='" & Abs(mreadonly) & "'>"
				app.printl "        <input type=hidden id='Bill_Info_SplogId' value='" & Me.splogID & "'>"
				app.printl "        <input type=hidden id='Bill_Info_readonly' value='" & Abs(Me.ReadOnly * 1) & "'>"
				app.printl "        <input type=hidden id='Bill_Info_readbillmode' value='" & Abs(Me.getappreadonly * 1) & "'>"
				app.printl "        <input type=hidden id='Bill_Info_creator' value='" & Me.Creator & "'>"
				app.printl "        <input type=hidden id='Bill_Info_del' value='" & Me.Deleted & "'>"
				app.printl "        <input type=hidden id='Bill_Info_HasSpRank' value='" & Me.HasSpRank & "'>"
				app.printl "        <input type=hidden id='Bill_Info_ChangeModel' value='" & abs( request.querystring("ChangeModel") = "1" Or  request.form("ChangeModel") = "1") & "'>"
				app.printl "        <input type=hidden id='Bill_Info_canupdatesp' value='" & getCanSpUpdate(OrderId, keySign, sheetno) & "'>"
				app.printl Me.checkHiddenField
				app.printl "</div>"
			end sub
			Private function getCanSpUpdate(ByVal OrderId, ByVal signkey, ByVal sheetno)
				Dim rs
				getCanSpUpdate = 0
				Set rs = cn.execute("select top 1 cateid_sp from M_FlowLogs where PrefixCode = '" & signkey & "' and  OrderID=" & sheetno & " order by ID desc")
				If rs.eof = False Then
					If rs("cateid_sp").value - app.Info.User  <> 0 Then
'If rs.eof = False Then
						rs.close
						Exit function
					end if
				else
					rs.close
					Exit function
				end if
				rs.close
				Set rs = cn.execute("exec erp_bill_ChildBills " & OrderId & "," & sheetno & "," & app.Info.User & " ")
				rs.Filter = "del=0"
				If rs.eof = True  then
					getCanSpUpdate = 1
				end if
				rs.close
			end function
			Public Sub LoadCmdButtonsState
				Dim c
				c = Me.Creator & ""
				If Len(c) = 0 Then c = 0
				Dim CreatorId
				CreatorId = cdbl(c)
				If CreatorId > 0 And CreatorId <> cdbl(app.info.user) Then
					mReadonly = True
				else
					If TypeName(Me.Sp) = "Empty" Then
						mReadonly = False
					else
						Set rs = cn.Execute("select OrderId  from M_FlowLogs where cateid_sp <> " & app.info.user & " and orderid=" & sheetno & " and PrefixCode='" & keySign & "'  and id in (select max(id) from M_FlowLogs group by PrefixCode,orderID,sp_id)")
						mReadonly = Not rs.EOF
						rs.close
					end if
				end if
				If request.querystring("PowerReadOnly") = "1" Then
					mReadonly = True
					For i = 1 To mainfields.Count
						If LCase(mainfields.Items(i).dtype) = "detail" Then
							mainfields.Items(i).defvalue.ReadOnly = True
						end if
					next
				end if
				If request.Form("PowerReadOnly") = "1" Then
					mReadonly = True
					For i = 1 To mainfields.Count
						If LCase(mainfields.Items(i).dtype) = "detail" Then
							mainfields.Items(i).defvalue.ReadOnly = True
						end if
					next
				end if
				If Len(AppReadOnly)> 0 Then
					mReadonly = AppReadOnly
				end if
				If Not Me.needcheck Then
					cmdbuttons.Items(5).visible = False
					Exit Sub
				end if
				Dim psql , plg
				If IsNumeric(Me.orderid) And Len(Me.orderid) > 0 and len(request.Form("ID") & request.QueryString("ID")) > 0 Then
					cmdbuttons.Items(5).visible = not me.readModeHasChild
				else
					cmdbuttons.Items(5).visible = False
				end if
			end sub
			Public Function hasDialogItem
				If Not canrefreshlist Then
					hasDialogItem = False
					Exit Function
				end if
				For i = 1 To mainfields.Count
					If LCase(mainfields.Items(i).dtype) = "detail" Then
						hasDialogItem = True
						Exit Function
					end if
				next
				hasDialogItem = False
			end function
			Public Sub DelTempMainTable
				Dim tmp
				tmp = "billmtmp_" & app.info.user & "_" & Me.orderid
				cn.Execute "if exists (select * from dbo.sysobjects where id = object_id(N'" & tmp & "')) drop table " & tmp & vbCrLf & vbCrLf
			end sub
			Public Function LoadSqlWidthDefField(basesql, sheetno)
				Dim sql , i , tmp, v
				Me.HasUserDef = False
				If Len(Me.orderid) = 0 Then
					LoadSqlWidthDefField = basesql
					Exit Function
				end if
				tmp = "billmtmp_" & app.info.user & "_" & Me.orderid
				on error resume next
				Set rs = App.GetDataRecord(cn.Execute(basesql))
				If Abs(Err.Number) > 0 Then
					app.showerr "提示" , "<span class=c_r>加载自定义字段失败</span><br><br>错误源:" & basesql & "<br><br>BillPage,Row=1442&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
					call db_close : Response.end
				end if
				app.db.CreateDbTableByRecordSet tmp , rs
				rs.close
				On Error Goto 0
				sql = "select *,"
				Set rs = cn.Execute("exec erp_bill_getdefdatalist " & Me.orderid & "," & sheetno)
				If Not rs.EOF Then
					While Not rs.EOF
						v = Replace(rs.fields("v").Value, "'", "''")
						If Len(v) = 0 Then
							v = " cast(Null as " & rs.fields("ftypetext").Value & ") "
						else
							v = " cast('" & v & "' as " & rs.fields("ftypetext").Value & ") "
						end if
						sql = sql & " " & v & " as [{us" & rs.fields("id").Value &"}" & rs.fields("fname") & "]"
						rs.movenext
						If Not rs.EOF Then sql = sql & ","
					wend
					LoadSqlWidthDefField = sql & " from " & tmp
					Me.HasUserDef = True
				else
					LoadSqlWidthDefField = basesql
				end if
				rs.close
			end function
			Public Sub handuserdeffield(ByRef Item)
				Dim ds , rs
				If InStr(Item.ywname, "{us") = 1 Then
					ds = Split(Replace(Item.ywname, "{us", ""), "}")
					Item.ywname = ds(1)
					Set rs = cn.Execute("select mustfillin,OptionID,ftype from M_CustomFields  where id=" & ds(0) & " and IsUsing=1")
					If Not rs.EOF Then
						If Abs(rs.fields("mustfillin").Value) > 0 Then
							Item.notnull = 1
						end if
						If rs.fields("OptionID").Value < 0 Then
							Item.selid = Abs(rs.fields("OptionID").Value)
						ElseIf rs.fields("OptionID").Value > 0 Then
							Item.selid = 10000000 + Abs(rs.fields("OptionID").Value)
'ElseIf rs.fields("OptionID").Value > 0 Then
						end if
						Select Case rs.fields("ftype").Value
						Case 2
						Item.dType = "textarea"
						Case 5
						Item.dType = "html"
						Item.colspan = 3
						Item.Group = "扩展说明"
						End Select
					end if
					rs.close
				end if
			end sub
			Public Sub UnloadUserDefOnSave
				Dim Item
				If Len(Me.orderid) = 0 Then Exit Sub
				Set rs = cn.Execute("select ID,fname,ftype,mustfillin from M_CustomFields where del=0 and oid = " & Me.orderid & " and ismaster=1 and  IsUsing=1 order by forder")
				While Not rs.EOF
					Set Item = New mField
					Item.ywname = "{us" & rs.fields("ID").Value & "}" & rs.fields("fname").Value
					Item.dbname = "{us" & rs.fields("ID").Value & "}" & rs.fields("fname").Value
					Select Case rs.fields("ftype").Value
					Case 2
					Item.dType = "textarea"
					Case 5
					Item.dType = "html"
					Item.colspan = 3
					Item.Group = "扩展说明"
					Case 4
					Item.dType = "number"
					Case 3
					Item.dType = "date"
					End Select
					If Abs(rs.fields("mustfillin").Value) > 0 Then
						Item.notnull = 1
					end if
					Me.mainfields.Add Item
					rs.movenext
				wend
				rs.close
			end sub
			Public Sub UpdateAjaxLeftTree
				App.Print "<ajaxvar>"
				If App.isSub("Bill_LeftPanel") Then
					Call Bill_LeftPanel(Me)
				else
					Call def_Bill_LeftPanel(Me)
				end if
				App.Print "<ajaxvar>"
				App.Print ";if(document.getElementById('LeftTreeArea')){;document.getElementById('LeftTreeArea').innerHTML=_sys_ajaxvar;window.RegObjectScript(document.getElementById('LeftTreeArea'));}"
			end sub
			Public Sub LoadCallBackMessage
				Dim rs , html
				Set rs = App.GetDataRecord(cn.Execute("exec erp_bill_getBackMsg " & Me.orderid & "," & Me.sheetno))
				If Not rs.EOF Then
					Me.SetUIFields "退回人;bbthrxadas;2;space;0;" & rs.fields(0).Value & ";0;退回信息;1;100|"
					Me.SetUIFields "批示;" & checkmanField & ";1;space;0;<span class=c_red>" & Replace(Replace(rs.fields(1).Value, ",", "，"), ";", "；") & "</span>;0;退回信息;2;100|"
				end if
				rs.close
			end sub
			Public Sub ConvertItemSelId(byref Item)
				If Not IsNumeric(Item.selId) And Len(Item.selId) > 0 Then
					Item.selId = Replace(Item.selId, "，", ",")
					Item.selId = Replace(Item.selId, "[", "getMainFieldByDBname(""")
					Item.selId = Replace(Item.selId, "]", """).defvalue")
					Item.selId = Replace(Item.selId, "iif(", "app.iif(")
					Item.selId = Eval(Item.selId)
					If Not IsNumeric(Item.selId) Or Len(Item.selId) = 0 Then
						Item.selId = 0
					end if
				end if
			end sub
		End Class
		Sub App_BillGetZdyMsg
			Dim bid , oid, sql
			oid = request.form("bill_info_type")
			bid = request.form("bill_info_id")
			Select Case oid
			Case 8 :
			Dim MOIListID, ddlistid
			MOIListID = CLng("0" & request.form("MOIListID"))
			ddlistid =  CLng("0" & request.form("ddlistid"))
			If MOIListID > 0 Then
				sql =  "select a.zdy1, a.zdy2, a.zdy3, a.zdy4, (select sort1 from sortonehy where ord=a.zdy5) as zdy5, (select sort1 from sortonehy where ord=a.zdy6) as zdy6, a.remark from M_manuorderlists a where id=(select top 1 MOrderListID  from M_ManuOrderIssuedLists  where ID=" & MOIListID & ") "
			ElseIf ddlistid > 0 Then
				sql =  "select a.zdy1, a.zdy2, a.zdy3, a.zdy4, (select sort1 from sortonehy where ord=a.zdy5) as zdy5, (select sort1 from sortonehy where ord=a.zdy6) as zdy6, a.remark from M_manuorderlists a where id=" &  ddlistid
			else
				Exit sub
			end if
			Case 11:
			Dim waid: waid = CLng("0" & request.form("WAID"))
			sql =  "select a.zdy1, a.zdy2, a.zdy3, a.zdy4, (select sort1 from sortonehy where ord=a.zdy5) as zdy5, (select sort1 from sortonehy where ord=a.zdy6) as zdy6, a.remark from M_manuorderlists a inner join M_ManuOrderIssuedLists b on a.id=b.morderlistid inner join M_WorkAssigns c on c.moilistid=b.idand c.id=" & waid
			Case 17
			Dim MPID: MPID = CLng("0" & request.form("MPID"))
			sql =  "select a.zdy1, a.zdy2, a.zdy3, a.zdy4, (select sort1 from sortonehy where ord=a.zdy5) as zdy5, (select sort1 from sortonehy where ord=a.zdy6) as zdy6, a.remark from M_manuorderlists a inner join M_ManuOrderIssuedLists b on a.id=b.morderlistid inner join M_WorkAssigns c on c.moilistid=b.idinner join M_MaterialProgres e on e.waid=c.id and e.id=" &  MPID
			Case 19
			waid = CLng("0" & request.form("WAID"))
			sql =  "select a.zdy1, a.zdy2, a.zdy3, a.zdy4, (select sort1 from sortonehy where ord=a.zdy5) as zdy5, (select sort1 from sortonehy where ord=a.zdy6) as zdy6, a.remark from M_manuorderlists a inner join M_ManuOrderIssuedLists b on a.id=b.morderlistid inner join M_WorkAssigns c on c.moilistid=b.idand c.id=" & waid
			Case 12, 13, 14, 15
			Dim protype : protype = CLng("0" & request.form("poType"))
			waid = CLng("0" & request.form("WAID"))
			If protype = 0 Then
				sql = "select  a.zdy1, a.zdy2, a.zdy3, a.zdy4, (select sort1 from sortonehy where ord=a.zdy5) as zdy5, (select sort1 from sortonehy where ord=a.zdy6) as zdy6, a.remark from M_manuorderlists a inner join M_ManuOrderIssuedLists b on a.id=b.morderlistid inner join M_WorkAssigns c on c.moilistid=b.id and c.id=" & waid & " union all select ' ' as zdy1, ' ' as zdy2, ' ' as zdy3, ' ' as zdy4,  '' as zdy5, ' ' as zdy6, ' ' as remark"
			else
				sql = "select ' ' as zdy1, ' ' as zdy2, ' ' as zdy3, ' ' as zdy4, ' ' as zdy5, ' ' as zdy6, ' ' as remark"
			end if
			End Select
			If Len(sql & "") = 0 Then Exit sub
			Dim v : v = ""
			Set rs = cn.execute(sql)
			While rs.eof = False
				For i = 0 To rs.fields.count-1
'While rs.eof = False
					v = rs(i).value
					If InStr(v,"!@_SASC_")>0 Then v = ""
					Response.write v & Chr(1) & Chr(1)
				next
				rs.movenext
			wend
			rs.close
			sql = ""
			Select Case oid
			Case 17 :
			sql =   "select " & vbcrlf &_
			"  z.title as proName, z.type1 as proType, z.order1 as prono, " & vbcrlf &_
			"  (select sort1 from sortonehy where ord=y.unit) as proUnit " & vbcrlf &_
			"from M_MaterialProgres x  " & vbcrlf &_
			"inner join M_WorkAssigns y on x.WAID = y.ID and x.ID =" & MPID & vbcrlf &_
			"inner join product z on y.ProductID = z.ord "
			End Select
			If Len(sql)>0 Then
				Set rs = cn.execute(sql)
				If rs.eof = False Then
					Response.write Chr(3) & Chr(3)
					For i = 0 To rs.fields.count -1
						Response.write Chr(3) & Chr(3)
						Response.write rs(i).name & Chr(1) & Chr(1) & rs(i).value & Chr(2) & Chr(2)
					next
				end if
				rs.close
			end if
		end sub
		Sub loadparentmsg(bill)
			Dim fItem , I , pTag , sql
			For i = 1 To bill.mainfields.Count
				Set fd = bill.mainfields.Items(i)
				If fd.IsParentField Then
					pTag = request.querystring("ParentTag")
					If Len(pTag) = 0 Then pTag = 0
					If Not IsNumeric(pTag) Then pTag = 0
					If pTag > 0 Then
						fd.defvalue = pTag
						If i > 1 Then
							Bill.ConvertItemSelId(bill.mainfields.Items(i -1))
'If i > 1 Then
							Bill.ConvertItemSelId(bill.mainfields.Items(i))
							If bill.mainfields.Items(i -1).selid > 0 And (bill.mainfields.Items(i).selid = 0 or bill.orderid=3) Then
								Bill.ConvertItemSelId(bill.mainfields.Items(i))
								Dim pOrd
								pOrd = request.querystring("ParentOrd")
								If Len(pOrd) > 0 Then
									If IsNumeric(pOrd) Then
										if bill.orderid = 3 Then
											Dim ptb
											dim pfd : set pfd = bill.GetMainFieldByDBname("CreateFrom")
											select case pOrd*1
											case 1: pfd.defvalue = 2 : ptb = "M_PredictOrders"
											case -1: pfd.defvalue = 1 : ptb = "contract"
											case 1: pfd.defvalue = 2 : ptb = "M_PredictOrders"
											case -8: pfd.defvalue = 3  : ptb = "chance"
											case 1: pfd.defvalue = 2 : ptb = "M_PredictOrders"
											end Select
											Dim pfid : pfid = bill.GetMainFieldByDBname("FromID").defvalue
											Set rs = cn.Execute("set nocount on;exec erp_bill_getBillTitle " & pOrd & "," & CLng("0" & pfid) & ";set nocount off")
											If rs.eof = False then
												bill.GetMainFieldByDBname("title").defvalue = rs(0).value
											end if
											rs.close
										else
											If Len(request.querystring("PKeyID")) > 0 Then
												sql = "exec erp_bill_getBillTitle " & pOrd & "," & request.querystring("PKeyID")
											else
												sql = "exec erp_bill_getBillTitle " & pOrd & "," & pTag
											end if
											Set rs = app.getdatarecord(cn.Execute(sql))
											If Not rs.EOF Then
												bill.mainfields.Items(i -1).defvalue = rs.fields(0).Value
'If Not rs.EOF Then
												For iii = 1 To Bill.mainfields.count
													Set fitem = Bill.mainfields.items(iii)
													If Len(fitem.ywname) >= 2 And Right(fitem.ywname,2) = "主题" Then
														If fitem.defvalue = "" Then fitem.defvalue = rs.fields(0).Value
													end if
												next
											end if
											rs.close
										end if
										sql = "exec erp_bill_initByParent " & bill.orderid & "," & pord & "," & pTag & ",'" & request.querystring("PKeyID") & "'," & App.info.user & ",''"
										Set rs = cn.Execute(sql)
										If Not rs.EOF Then
											For III = 0 To rs.fields.Count -1
'If Not rs.EOF Then
												Set fItem = Bill.GetMainFieldByDBname(rs.fields(iii).Name)
												If Not fItem Is Nothing Then
													fitem.defvalue = rs.fields(iii).Value
												end if
											next
										end if
										rs.close
									end if
								end if
							end if
						end if
					end if
				end if
			next
		end sub
		Dim offsety : offsety = 0
		Sub TestWrite(msg)
			Response.write "<div style='position:absolute;z-index:10000;left:10px;top:"&(10+offsety)&"px;background-color:white;padding:10px;border:1px solid #000'>" & msg & "</div>"
'Sub TestWrite(msg)
			offsety = offsety + 35
'Sub TestWrite(msg)
		end sub
		Sub Page_init
			app.vpath = "../inc/"
		end sub
		Private Sub ConvertBillHisDataToCurr(oid, bid, chglogid)
			If isnumeric(oid) = False Then oid = 0
			Dim rs, tbs, i, item, tb,  fk,  te, fields, ii
			i = 0
			ReDim tbs(0)
			cn.cursorlocation = 3
			Set rs = cn.execute("select MainTable, PKColumn , 1 as ismain from M_OrderSettings where ID=" & oid & " union all select SubTable , SubKeyName , 0 from M_OrderListSettings where  SubTable<>'@dissave' and OrderID =" & oid)
			While rs.eof = False
				ReDim Preserve tbs(i)
				tbs(i) = split(rs(0).value & "|" & rs(1).value & "|" & rs(2).value,"|")
				i = i + 1
				tbs(i) = split(rs(0).value & "|" & rs(1).value & "|" & rs(2).value,"|")
				rs.movenext
			wend
			cn.begintrans
			For i = 0 To ubound(tbs)
				item = tbs(i)
				tb =  item(0)
				fk =  item(1)
				te = item(2)
				fields = ""
				Set rs = cn.execute("select top 0 * from " & tb)
				For ii=0 To rs.fields.count-1
'Set rs = cn.execute("select top 0 * from " & tb)
					If ii = 0 Then
						fields = "[" & rs(ii).name & "]"
					else
						fields = fields & ",[" & rs(ii).name & "]"
					end if
				next
				rs.close
				Dim n1,n2, hassign
				hassign = Not cn.execute("select top 1 1 from syscolumns where id=object_id(N'" & tb & "') and status=0x80").eof
				If hassign Then cn.execute "set IDENTITY_INSERT [" & tb & "] ON"
				cn.execute "delete " & tb & " where " & fk & "=" & bid, n1
				cn.execute "insert into [" & tb & "](" & fields & ") select " & fields & " from [" & tb & "_his] where chg_log=" & chglogid , n2
				If hassign Then  cn.execute "set IDENTITY_INSERT [" & tb & "] OFF"
				If i = 0 Then
				end if
			next
		end sub
		Dim conn
		Sub Page_Load
			Dim I , II, sheetno , rs , v, changelogid , ischangemode
			Set Bill = New BillPage
			sheetno = request.querystring("ID") & ""
			If Len(sheetno) = 0 Then sheetno = request.Form("ID")
			bill.ParentSheetNo = request.querystring("parentID") & ""
			If Len(bill.ParentSheetNo) = 0 Then bill.ParentSheetNo = request.Form("parentID")
			changelogid = CLng("0" & request.querystring("changelogid"))
			Set conn = cn
			If App.isSub("Bill_Init") Then
				If changelogid > 0 Then
					Call ConvertBillHisDataToCurr(request.querystring("orderid"),  sheetno, changelogid)
				end if
				If Len(sheetno) > 0 Then bill.sheetno = sheetno
				Bill.Cancel = False
				Call Bill_Init(Bill)
				if app.isSub("LoadParentMsgFor_" & Bill.orderid ) then
					on error resume next
					execute "LoadParentMsgFor_" &Bill.orderid & " Bill"
					if err.number <> 0 then testwrite "加载上级单据信息失败：" & err.Description
					on error goto 0
				else
					Call LoadParentMsg(Bill)
				end if
				If Bill.Cancel Then Exit Sub
				sheetno = Bill.sheetno
			else
				showhelp Bill
				Exit Sub
			end if
			ischangemode = ((request.querystring("ChangeModel") & "") = "1")
			If ischangemode then
				if app.power.canchange(bill.qxlb,bill.creator) = False Then
					app.showerr "无法对此单据进行变更，请联系系统管理员。", "权限验证失败，访问被拒绝。"
				end if
			end if
			If ischangemode=false And request.querystring("changelogid") = "" Then
				If Bill.NeedCheck Then
					
					Bill.LoaddefCheckField
					Bill.LoadCallBackMessage
				end if
			else
				Bill.LoadChangeRemarkMsg
				bill.visibleRfListButton = False
				bill.cmdbuttons.items(1).visible = False
				bill.cmdbuttons.items(2).visible = False
				bill.cmdbuttons.items(4).visible = False
				bill.cmdbuttons.items(5).visible = False
				bill.cmdbuttons.items(6).visible = False
				bill.cmdbuttons.items(7).visible = False
				bill.cmdbuttons.items(8).visible = False
				bill.cmdbuttons.items(9).visible = False
			end if
			Response.write "" & vbcrlf & "<style>div.divdlgBody{" & vbcrlf & "    overflow:auto!important;padding-bottom:0px!important}" & vbcrlf & "input.anybutton[type=button]{" & vbcrlf & "    padding-top:0px!important;" & vbcrlf & "}" & vbcrlf & "</style>" & vbcrlf & "<body onload=""loadBillPage('bill');FilePreviewAndDownload();setFrameSizeHandle();"" onresize=""setFrameSize()"" "
			if bill.getAppreadonly Then
				Response.write " id=""readbillbody"" "
			end if
			if bill.canscan Then
				Response.write " onclick=""Bill.TexTxmFocus(event);"" "
			end if
			Response.write " >" & vbcrlf & "    <script language=javascript src='"
			Response.write app.vpath
			Response.write "bill.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <script language=javascript src='"
			Response.write app.vpath
			Response.write "listview.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <script language=javascript src='"
			Response.write app.vpath
			Response.write "automenu.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script><!-- 自动下拉选择组件 -->" & vbcrlf & "  <script language=javascript src='"
			'Response.write Application("sys.info.jsver")
			Response.write app.vpath
			Response.write "treeview.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <script language=javascript src='"
			Response.write app.vpath
			Response.write "contextmenu.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script><!-- office/.net样式菜单 -->" & vbcrlf & "       <script language=javascript src='"
			'Response.write Application("sys.info.jsver")
			Response.write app.vpath
			Response.write "TabControl.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <script language=javascript src='"
			Response.write app.vpath
			Response.write "check.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script><!-- 审批部分 -->"
'Response.write Application("sys.info.jsver")
			If Bill.OrderId = 22 Then
				Response.write "<script language=javascript src='" & app.vpath & "nldate.js'></script>"
			end if
			If Len(Bill.OrderId & "") > 0 Then
				Response.write "<script language=javascript src='" & app.vpath & "bScript/" & Bill.OrderId & ".js'></script>"
			end if
			Set Get_Sort = New HrSortClass
			Call Get_Sort.Initial(Bill.OrderId)
			Response.write Get_Sort.SortArr
			Set Get_Sort = Nothing
			Response.write "" & vbcrlf & "      <script language=javascript src='sort.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   <script language=javascript src='processSatus.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script>" & vbcrlf & "   "
			If Len(bill.getAppreadonly) > 0 Then
				If bill.getAppreadonly Then
					Response.write "<script language=javascript src='ReadBill.js'></script>" & vbcrlf
					Response.write "<style>table.textitemtable{width:100%;}</style>"
				end if
			end if
			If bill.Deleted=1 Or request.querystring("changelogid")<>"" Then
				Response.write "<style>#billtopbar button.button {display:none;}  #billtopbar  {visibility:hidden}</style>"
				If request.querystring("changelogid")<>"" Then
					Response.write "<div style='position:absolute;top:10px;right:20px;z-index:1000;color:red'>温馨提示：当前页面是变更前备份数据，请勿当正常数据使用。</div>"
'If request.querystring("changelogid")<>"" Then
				end if
			end if
			If bill.canscan Then
				Response.write "<input name=""txm"" autocomplete=""off"" type=""text"" style=""width:0px; height:0px; border:0 0 0 0;margin: 0px;padding: 0px;position:absolute;"" onkeypress=""if(event.keyCode==13){Bill.txmAjaxSubmit(this);this.value='';}"" onFocus=""this.value=''"" size=""10"">"
			end if
			Response.write "" & vbcrlf & "      <script language=javascript type=""text/javascript"">" & vbcrlf & "               window.sysCurrPath = """
			Response.write sdk.getvirpath()
			Response.write """;" & vbcrlf & "         Bill.ControlMenu();//控制右键菜单" & vbcrlf & "               Bill.OrderId = """
			Response.write Bill.OrderId
			Response.write """;" & vbcrlf & "         Bill.ParentID = """
			Response.write Bill.parentsheetno
			Response.write """;" & vbcrlf & "         Bill.haschild = """
			Response.write abs(Bill.readModeHasChild*1)
			Response.write """;  //表示是否包含子单据（含删除）" & vbcrlf & "         Bill.haschild2 = """
			Response.write abs(Bill.readModeHasChild2*1)
			Response.write """; //表示是否包含子单据（不含删除）" & vbcrlf & "                Bill.disUserDef = """
			Response.write abs(bill.disuserdef*1)
			Response.write """;" & vbcrlf & "         Bill.queryItem_ParentTag = """
			Response.write request.querystring("ParentTag")
			Response.write """;" & vbcrlf & "         Bill.attrtop1 = "
			Response.write lcase(cstr(App.info.isAdmin))
			Response.write ";" & vbcrlf & "             Bill.hasList  = "
			Response.write bill.haslist
			Response.write ";" & vbcrlf & "            Bill.needsp= "
			Response.write abs(bill.needcheck)
			Response.write ";" & vbcrlf & "            Bill.canupdate = "
			Response.write abs(Bill.power_canupdate)
			Response.write ";" & vbcrlf & "            Bill.canconfig = "
			Response.write abs(app.power.canconfig(app.power.GetBillQXID(bill.orderID)))
			Response.write ";" & vbcrlf & "            Bill.cpZdyIDKey = """
			Response.write Bill.cpZdyIDKey
			Response.write """;" & vbcrlf & "                tvw.ItemClick = function (li) {" & vbcrlf & "                 Bill.AddBill(li.getAttribute(""tag""))" & vbcrlf & "                      if (Bill.OnItemClick)" & vbcrlf & "                   {return Bill.OnItemClick(li);}" & vbcrlf & "          }" & vbcrlf & "               function showEditPage(){return false;var d = new Date();if(!window.ew){window.ew=0};if(!window.ewt){window.ewt=d.getTime()};if(d.getTime()-window.ewt < 2000){window.ewt = d.getTime();window.ew ++;if(window.ew>4){window.open((""bill.asp"").replace(""."",""creator."") + ""?id="" + document.getElementById(""Bill_Info_type"").value)}}else{window.ewt = null;window.ew = 0;}}"& vbcrlf &"             function setFrameSizeHandle(){ "& vbcrlf &"                   setTimeout"& "        <div id='billtopbardiv'><!--单据顶部区域开始-->" & vbcrlf & "         <table class='full' style='table-layout:fixed;'>" & vbcrlf & "                <tr>" & vbcrlf & "                    <td id=""billtitle"" class=""resetTextColor333"" style='width:22%;min-width:200px;background-repeat:no-repeat' onclick='showEditPage()'>"
'Response.write Bill.cpZdyIDKey
			Response.write Bill.billName
			Response.write "</td>" & vbcrlf & "                        <td id='billtopbar' style='width:70%'>" & vbcrlf & "                          <table align=right>" & vbcrlf & "                             <tr>" & vbcrlf & "                                    <td><span id=topmsg></span></td>" & vbcrlf & "                                        "
			If Bill.hasDialogItem And Bill.visibleRfListButton Then
				Response.write "" & vbcrlf & "                                             <td style='width:80px;display:block' valign=""bottom"" id='refreshdetailtd'>" & vbcrlf & "                                                <button  onclick='Bill.RefreshDetail()' title='根据当前页面的新输入记录，重新刷新或者生成明细资料。' class='billcmdButton' style='width:73px;cursor:default;'>刷新明细</button></td>" & vbcrlf & "                                            "
			end if
			If IsNumeric(bill.orderid) Then
				bill.orderid = CInt(bill.orderid)
			else
				bill.orderid = 0
			end if
			Select Case bill.orderid
			Case 2
			Set rsComplete = cn.Execute("select Complete from M_ManuOrders where id="&bill.sheetno)
			If Not rsComplete.EOF Then
				If rsComplete(0) = 0 And ischangemode = false Then
					If app.power.CheckPower(6, 13, 0) And app.ExistsModel(27000) Then
						Set objEncode = New Base64Class
						app.Print "<td><button  onclick=""window.open('../../pay/add2.asp?qttype=ManuOrder&qtord="&objEncode.pwurl(bill.sheetno)&"','fee','width=1000,height=900,fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')"" class='billcmdButton' id='fyButton'>费用</button>&nbsp;</td>"
					end if
				end if
				rsComplete.Close
				Set rsComplete = Nothing
			end if
			End Select
			Dim cmdHiddenImage
			For I = 1 To Bill.cmdButtons.Count
				Set Item = Bill.cmdButtons.Items(i)
				If item.visible = true Then
					Select Case item.Text
					Case "审批" : If bill.orderid=23 then item.visible = True
					End Select
				end if
				If item.visible = true Then
					Select Case Item.text
					Case "打印"
					cmdHiddenImage = "<img src='../../images/smico/print.gif' style='display:none'>"
					If bill.orderid=2 Or bill.orderid=8 Or bill.orderid=12 Or bill.orderid=13 Or bill.orderid=17 Then
						app.Print "<td><button  onclick='Bill.cmdButtonClick(this)' class='billcmdButton' style='width:80px' id='bcButtonPrint'>模板打印"& cmdHiddenImage & "</button>&nbsp;</td>"
					end if
					Case "保存"
					If Bill.readModeHasChild2 Then Item.visible = False
					cmdHiddenImage = "<img src='../../images/smico/save.gif' style='display:none'>"
					Case "删除"
					If Bill.readModeHasChild2 Then Item.visible = False
					cmdHiddenImage = "<img src='../../images/smico/del3.gif' style='display:none'>"
					Case Else
					cmdHiddenImage = ""
					End Select
					dim deepcolor
					if Item.text = "检索" or Item.text="保存" or Item.text="确认" or Item.text="关闭" or Item.text="添加" then
						deepcolor = "deepcolor"
					else deepcolor = ""
					end if
					app.Print "<td class='" & deepcolor & "'><button  onclick='Bill.cmdButtonClick(this)' class='billcmdButton' id='bcButton" & i & "'>" & Item.text & cmdHiddenImage & "</button>&nbsp;</td>"
				else
				end if
			next
			Response.write "" & vbcrlf & "                                                     <td style='width:24px;display:none'><input type=image src='../../images/smico/sHome.gif' title='将本系统设置为可信任站点。以便实现更好的用户体验' onmousedown='this.down=1' onclick='if(this.down!=1){return};this.down=0;document.getElementById(""sconfigfrm"").contentWindow.location.href=""../../manufacture/inc/safeConfig.asp""'><iframe id='sconfigfrm' style='width:0px;height:0px'></iframe></td>" & vbcrlf & "                                                </tr>" & vbcrlf & "                                           </table>" & vbcrlf & "                                        </td>" & vbcrlf & "                           </tr>" & vbcrlf & "                           </table>" & vbcrlf & "                <!--单据顶部区域结束-->" & vbcrlf & "         </div>" & vbcrlf & "" & vbcrlf & "              <div id='billBodyDiv'>"
			Dim topsyle, topDiv : topsyle = "" : topDiv = ""
			If Bill.HasLeftPanel And request.querystring("hiddenleftpanel") <> "1" Then
				defLWidth = request.cookies("bleftWidth_" & bill.orderid)
				If bill.orderid = 0 Then
					defLWidth = 250
				end if
				If Len(defLWidth) = 0 Or Not IsNumeric(defLWidth) Then
					defLWidth = 130
				else
					defLWidth = defLWidth - 20
					defLWidth = 130
				end if
				Response.write "<div id='LeftTreeArea' style='width:" & defLWidth & "px'>"
				If App.isSub("Bill_LeftPanel") Then
					Call Bill_LeftPanel(Bill)
				else
					Call def_Bill_LeftPanel(Bill)
				end if
				Response.write "</div>"
				Response.write "<div id=SpliterBar onmousedown='Bill.SpliterBarEvent(this,3)' onmouseup='Bill.SpliterBarEvent(this,5)'><table style='height:100%'><tr><td valign=middle><div id=""sptBar"" oldWidth=""0"" onclick='Bill.SpliterBarEvent(this,2)' onmouseup='this.parentElement.dm=0' onmousedown='this.parentElement.dm=1' ></div><br><br></td></tr></table></div>"
				Response.write "<div id='billbody' onresize='billbodyResize()'><table id='billBodyTable'><tr><td id='BillMainInfo' valign='top'><!--单据编辑区域开始-->"
			else
				If app.isSub("App_OnReadBill_Notice") Then Call App_OnReadBill_Notice(bill , topsyle ,topDiv)
				Response.write "<div id='billbody'  style='background:none'  style='left:0px;"& topsyle &"' onresize='billbodyResize()'><table id='billBodyTable'><tr><td id='BillMainInfo' valign='top'><!--单据编辑区域开始-->"
'If app.isSub("App_OnReadBill_Notice") Then Call App_OnReadBill_Notice(bill , topsyle ,topDiv)
			end if
			Call Bill.LoadCmdButtonsState()
			Dim fcount , groups , hs , nItem , cmd
			If Bill.mainFields.Count > 0 Then
				Bill.mainFields.Items(1).defValue = sheetno
			else
				app.Print "没有设置单号列。"
			end if
			Dim readOnlyFlag:readOnlyFlag = 0
			If bill.ReadOnly Then readOnlyFlag = 1
			sql = Bill.LoadSqlWidthDefField(Replace(Replace(Replace(bill.SQL,"@ReadOnly",readOnlyFlag), "@bill_ID", Bill.sheetno), "@bill_parentID", bill.parentsheetno), Bill.sheetno)
			Err.Clear
			on error resume next
			cn.CursorLocation=3
			Set rs = cn.Execute(sql)
			If Err.Number <> 0 Then
				Set rs = cn.Execute(Replace(Replace(bill.SQL, "@bill_ID", Bill.sheetno), "@bill_parentID", bill.parentsheetno))
				app.ShowYellowAlert "加载自定义字段数据失败，引发该问题可能是由于当前的自定义字段配置中所要求的数据类型与该单据目前包含的自定义字段数据不匹配。" & _
				"<div style='height:5px'></div><span class=link><a href=### style='color:blue' onclick='xxxxMsg.style.display=""inline""'>详情</a></span>&nbsp;&nbsp;&nbsp;<span id='xxxxMsg'  style=""color:red;display:none"">" & Err.Description & "</span>"
			end if
			On Error GoTo 0
			Set rs = App.GetDataRecord(rs)
			Bill.DelTempMainTable
			fcount = rs.fields.Count
			Set cmd = New DBcommand
			For I = 0 To rs.fields.Count - 1
'Set cmd = New DBcommand
				hs = False
				For II = 1 To Bill.mainFields.Count
					Set fItem = Bill.mainFields.Items(II)
					If LCase(rs.fields(i).Name) = LCase(fItem.dbName) Then
						II = Bill.mainFields.Count
						If Not rs.EOF Then
							v = rs.fields(i).Value
							If IsNumeric(v) Then
								fItem.defvalue = v
							else
								fItem.defvalue = Replace(v & "", Chr(0), "")
							end if
							If fItem.isParentField Then
								bill.parentsheetno = fItem.defvalue
							end if
						end if
						hs = True
					end if
				next
				If Not hs Then
					Set nItem = New mField
					nItem.ywName = rs.fields(i).Name
					nItem.dbName = rs.fields(i).Name
					nItem.dType = cmd.getTypebyId(rs.fields(i).Type)
					If Not rs.EOF Then
						If nItem.dType = "bit" Then
							v = rs.fields(i).Value
							If Not IsNumeric(v) Then v = 0
							nItem.defvalue = Abs(v)
						else
							nItem.defvalue = Replace(rs.fields(i).Value & "", Chr(0), "")
						end if
					end if
					Dim defgp
					If Len(defgp & "")=0 Then defgp =  Bill.mainFields.items(1).group
					nItem.Group = defgp
					Bill.mainFields.Add nItem
					If InStr(nItem.ywName, "{us") = 1 Then Call Bill.handuserdeffield(nItem)
				end if
			next
			Set cmd = Nothing
			For I = 1 To Bill.mainFields.Count
				Set Item = bill.mainfields.Items(i)
				If Item.state = 5 Then
					If Not isobject(Item.defvalue) Then
						Select Case LCase(Trim(Item.defvalue & ""))
						Case "@uid"
						Item.defvalue = app.info.user
						Case "@uname"
						Item.defvalue = app.info.username
						Case "@bill_id"
						Item.defvalue = bill.sheetno
						Case "@bill_parentid"
						Item.defvalue = bill.parentsheetno
						Case "@bsign"
						Item.defvalue = bill.keysign
						Case "@now"
						Item.defvalue = Now
						Case "@date"
						Item.defvalue = Date
						End Select
					else
						Item.defvalue = ""
					end if
					app.Print "<input dbname='" & Item.dbname & "' ywname=""" & Replace(Item.ywname & "", """", "&quot;") & """  type=hidden name=""MT" & I & """ value=""" & Replace(Item.defvalue & "", """", "&quot;") & """" & app.IIf(Abs(Item.RefreshChild)>0, " onchange='Bill.RefreshDetail(true);' RefreshChild=1 ", "") & ">"
				end if
			next
			app.Print vbCrLf & vbCrLf & vbCrLf & "<table id=MainTable><col style='width:11%'><col style='width:22%'><col style='width:11%'><col style='width:22%'><col style='width:11%'><col style='width:22%'>"
			fcount = 0
			If Bill.showGroup Then
				groups = bill.getgroups
				For II = 1 To UBound(groups)
					app.Print "<tr><td colspan=6 class='billgrouptool'>" & _
					"            ""<div style='float:left;padding:0px;padding-left:6px' hidden=0 ><img onclick='Bill.GroupHide(this);' style='height:5px;cursor:pointer;margin-top:5px;' src='../../images/r_down.png'></div><div style='float:left;padding-top:2px'><span class='billgrouptitle' style='cursor:default;padding-top:0'>&nbsp;" & groups(II) & "</span></div></td></tr>"
					For I = 1 To Bill.mainFields.Count
						Set Item = bill.mainfields.Items(i)
						If groups(II) = Item.group Then
							If Item.state <> 5 Then
								If fcount = 0 Then app.Print "<tr>"
								If Not IsNumeric(Item.colspan) Then Item.colspan = 1
								If Item.colspan + fcount > 3 Then Item.colspan = 3 - fcount
'If Not IsNumeric(Item.colspan) Then Item.colspan = 1
								Item.sethtmlid "M_Field_" & I & "_" & II
								If Item.state = 2 And (Item.isparentfield = True Or InStr(Item.ywname, "{hide}")> 0) Then
									app.Print "<td class=billfieldleft vTag='" & Item.dbname & "' style='visibility:hidden'>" & Item.ywName & "：</td><td style='visibility:hidden' class=billfieldright colspan='" & (Item.colspan * 2 -1) & "' id='" & Item.htmlid & "'  linkcode='" & Item.linkcode & "'>"
'If Item.state = 2 And (Item.isparentfield = True Or InStr(Item.ywname, "{hide}")> 0) Then
									app.Print Bill.GetItemHTML(Item, I)
									app.Print "</td>"
								else
									If Len(Item.ywName) = 0 Then 'And item.dtype = "space" Then
										app.Print "<td class=billfieldright colspan=" & Item.colspan * 2 & ">"
										app.Print Bill.GetItemHTML(Item, I)
										app.Print "</td></td>"
									else
										app.Print "<td class=billfieldleft vTag='" & Item.dbname & "'>" & Item.ywName & "：</td><td class=billfieldright colspan='" & (Item.colspan * 2 -1) & "' id='" & Item.htmlid & "'  linkcode='" & Item.linkcode & "'>"
										app.Print "</td></td>"
										app.Print Bill.GetItemHTML(Item, I)
										app.Print "</td>"
									end if
								end if
								fcount = fcount + Item.colspan
								app.Print "</td>"
								If fcount = 3 Then
									fcount = 0
									app.Print "</tr>"
								end if
							end if
						end if
					next
					If fcount > 0 Then
						For I = 1 To 3 - fcount
'If fcount > 0 Then
							app.Print "<td class=billfieldleft>&nbsp;</td><td class=billfieldright>&nbsp;</td>"
						next
						app.Print "</tr>"
						fcount = 0
					end if
				next
			Else
				app.Print "<table id=MainTable>"
				For I = 1 To Bill.mainFields.Count
					Set Item = bill.mainfields.Items(i)
					If Item.state <> 5 Then
						If fcount = 0 Then app.Print "<tr>"
						If Not IsNumeric(Item.colspan) Then Item.colspan = 1
						If Item.colspan + fcount > 3 Then Item.colspan = 3 - fcount
'If Not IsNumeric(Item.colspan) Then Item.colspan = 1
						app.Print "<td class=billfieldleft >" & Item.ywName & ":</td><td class=billfieldright colspan='" & (Item.colspan * 2 -1) & "'>" & Bill.GetItemHTML(Item, I) & "</td>"
'If Not IsNumeric(Item.colspan) Then Item.colspan = 1
						fcount = fcount + Item.colspan
'If Not IsNumeric(Item.colspan) Then Item.colspan = 1
						If fcount = 3 Then
							fcount = 0
							app.Print "</tr>"
						end if
					end if
				next
				If fcount > 0 Then
					For I = 1 To 3 - fcount
'If fcount > 0 Then
						app.Print "<td class=billfieldleft>&nbsp;</td><td class=billfieldright>&nbsp;</td>"
					next
					app.Print "</tr>"
					fcount = 0
				end if
			end if
			app.Print "</table>"
			Bill.createJsInfoField
			Response.write "" & vbcrlf & "                             <script language='javascript'>" & vbcrlf & "                                  Bill.IsReadOnly("
			Response.write LCase(CStr(bill.readonly))
			Response.write ","
			Response.write LCase(CStr(bill.canadd))
			Response.write ");" & vbcrlf & "                                   Bill.spButtonStatus("
			Response.write app.info.user
			Response.write ");" & vbcrlf & "                                   Bill.autoTextAreaHeight();" & vbcrlf & "                                      Bill.cantextCopy = "
			Response.write abs(bill.cantextcopy)
			Response.write ";" & vbcrlf & "                                    window.setTimeout(""Bill.autoIframePos()"",500);" & vbcrlf & "                                    "
			For I = 1 To bill.cmdButtons.Count
				Response.write vbTab & ";if(document.getElementById(""bcButton" & i & """)){document.getElementById(""bcButton" & i & """).style.display=""" & app.IIf(bill.cmdButtons.Items(i).visible, "", "none") & """;document.getElementById(""bcButton" & i & """).parentElement.style.display=document.getElementById(""bcButton" & i & """).style.display;}" & vbCrLf
			next
			Dim linkitem , qx , oid , bid,qx_list
			For I = 1 To bill.mainfields.Count
				Set fitem = bill.mainfields.Items(i)
				qx_list = true
				If Len(fitem.linkcode) > 0 Then
					linkitem = Split(fitem.linkcode, "@")
					Select Case CInt(linkitem(0))
					Case 1
					qx = False
					If UBound(linkitem) < 1 Then
						qx = False
						qx_list = False
					else
						on error resume next
						oid = Eval(GetLinksValue(linkitem(1)))
						If Abs(Err.Number) > 0 Then
							app.alert "注意：单据上下级链接配置错误。"
							oid = 0
						end if
						On Error GoTo 0
						If UBound(linkitem) = 2 Then
							bid = Eval(GetLinksValue(linkitem(2)))
						else
							bid = bill.mainfields.Items(i).datavalue
						end if
						bid = Trim(bid & "")
						If oid > 0 Then
							qx = app.power.CanReadBill(oid, bid)
						else
							if bid = "" then bid="0"
							Select Case CInt(oid)
							Case -1:
'Select Case CInt(oid)
							Dim prs
							Set prs = cn.Execute("select cateid from contract where ord=" & bid)
							If Not prs.EOF Then
								qx = app.power.CanRead(5, prs.fields(0).Value)
								qx_list = app.power.CheckPower(5,1,prs.fields(0).Value)
							else
								qx = false
								qx_list = false
							end if
							prs.Close
							Case -8:
							prs.Close
							Dim prs2
							Set prs2 = cn.Execute("select addcate from contract where ord=" & bid)
							If Not prs2.EOF Then
								qx = app.power.CanRead(3, prs2.fields(0).Value)
								qx_list = app.power.CheckPower(3,1,prs2.fields(0).Value)
							else
								qx = false
								qx_list = false
							end if
							prs2.Close
							Case -9 :
							prs2.Close
							Dim prs3
							Set prs3 = cn.Execute("select cateid,share,sharecontact from tel where ord=" & bid)
							If Not prs3.EOF Then
								qx = app.power.CanRead(1, prs3.fields(0).Value)
								qx_list = app.power.CheckPower(1,1,prs3.fields(0).Value) _
								Or (prs3("sharecontact") = "1" and instr("," & prs3("share") & "," , "," & app.info.user & ",") > 0) _
								Or prs3("share") = "1"
							else
								qx = false
								qx_list = false
							end if
							prs3.Close
							Case -10 :
							prs3.Close
							Dim prs4
							Set prs4 = cn.Execute("select " & vbcrlf &_
							"(select cateid from tel where ord=person.company) as cateid," & vbcrlf &_
							"(select share from tel where ord=person.company) as share," & vbcrlf &_
							"(select sharecontact from tel where ord=person.company) as sharecontact " & vbcrlf &_
							"from person WHERE ord=" & bid)
							If Not prs4.EOF Then
								qx = app.power.CanRead(2, prs4.fields(0).Value)
								qx_list = app.power.CheckPower(2,1,prs4.fields(0).Value) _
								Or (prs4("sharecontact") = "1" and instr("," & prs4("share") & "," , "," & app.info.user & ",") > 0) _
								Or prs4("share") = "1"
							else
								qx = false
								qx_list = false
							end if
							prs4.Close
							End Select
						end if
					end if
					If qx Then
						Response.write "Bill.setMainFieldsLink(""" & fitem.htmlid & """,""" & replace(fitem.linkcode,"app.iif","") & """,""" & bill.ReadOnly & """,""" & fitem.uiType & """,true);" & vbCrLf
					elseif qx_list = false then
						Response.write "Bill.setMainFieldsLink(""" & fitem.htmlid & """,""" & replace(fitem.linkcode,"app.iif","") & """,""" & bill.ReadOnly & """,""" & fitem.uiType & """,false);" & vbCrLf
					end if
					Case 3
					qx = app.power.existsPower(21,14)
					qx_list = app.power.existsPower(21,1)
					If qx Then
						Response.write "Bill.setMainFieldsLink(""" & fitem.htmlid & """,""" & replace(fitem.linkcode,"app.iif","") & """,""" & bill.ReadOnly & """,""" & fitem.uiType & """,true);" & vbCrLf
					elseif qx_list = false then
						Response.write "Bill.setMainFieldsLink(""" & fitem.htmlid & """,""" & replace(fitem.linkcode,"app.iif","") & """,""" & bill.ReadOnly & """,""" & fitem.uiType & """,false);" & vbCrLf
					end if
					Case Else
					Response.write "Bill.setMainFieldsLink(""" & fitem.htmlid & """,""" & replace(fitem.linkcode,"app.iif","") & """,""" & bill.ReadOnly & """,""" & fitem.uiType & """);" & vbCrLf
					End Select
				end if
			next
			Response.write "" & vbcrlf & "                                     var $div = $('#linkOrderDiv');" & vbcrlf & "                                  if($div && $div.size()>0){" & vbcrlf & "                                              var billid = $div.attr('billid');" & vbcrlf & "                                               var orderid = $div.attr('orderid');" & vbcrlf & "                                             $.ajax({" & vbcrlf & "                                                        url:'../inc/billpage.asp?ajax=1&__msgId=getChildBillTree&t=' + (new Date()).getTime() + '&oid='+billid+'&bid='+orderid," & vbcrlf & "                                                        success:function(html){" & vbcrlf & "                                                         $div.get(0).innerHTML=html.substring(html.indexOf(""<table""));" & vbcrlf & "                                                             lvw.UpdateScrollBar($(""#listview_lists"").get(0));" & vbcrlf & "                                                 }," & vbcrlf & "                                                   error:function(XMLHttpRequest,str,errObj){" & vbcrlf & "                                                              try" & vbcrlf & "                                                             {" & vbcrlf & "                                                                       if(XMLHttpRequest.responseText.indexOf(""zbintel.error.message"") > 0) {" & vbcrlf & "                                                                            document.write(XMLHttpRequest.responseText);" & vbcrlf & "                                                                    }"& vbcrlf & "                                                              }" & vbcrlf & "                                                               catch (e){}" & vbcrlf & "                                                     }" & vbcrlf & "                                               });" & vbcrlf & "                                     }" & vbcrlf & "                                       " & vbcrlf & "                                        if(window.bill_onLoad){" & vbcrlf & "                                         window.bill_onLoad();" & vbcrlf & "                                   }" & vbcrlf & "                                       setTimeout(function(){" & vbcrlf & "                  var sbox = document.getElementsByTagName(""select"");" & vbcrlf & "                                               for(var x = 0;  x < sbox.length; x++) {" & vbcrlf & "                                                 if(sbox[x].offsetWidth>140) { sbox[x].style.width = ""140px""; }" & vbcrlf & "                                            }}" & vbcrlf & "                                      ,50);" & vbcrlf & "   " & vbcrlf & "                                        if(Bill.cantextCopy==0){" & vbcrlf & "                                                document.onselectstart = function(){" & vbcrlf & "                                                    var o = window.event.srcElement" & vbcrlf & "                                                 if((o.tagName==""INPUT"" || o.tagName==""TEXTAREA"" ) && o.readOnly==false){" & vbcrlf & "                                                            return true" & vbcrlf & "                                                     }" & vbcrlf & "                                                       return false" &vbcrlf & "                                                }" & vbcrlf & "                                       }" & vbcrlf & "                                       else{" & vbcrlf & "                                           document.onselectstart = null;" & vbcrlf & "                                  }" & vbcrlf & "" & vbcrlf & "                                       //try{document.title = document.getElementById(""billtitle"").innerText + ""-"
'End Select
			Response.write app.info.title
			Response.write """;}catch(e){}" & vbcrlf & "                             </script>" & vbcrlf & "                               "
			If App.isSub("Bill_AfterLoad") Then
				Call Bill_AfterLoad(bill)
			end if
			Response.write "" & vbcrlf & "                             <!--单据编辑区域结束-->" & vbcrlf & "                 </td>" & vbcrlf & "                   </tr>" & vbcrlf & "                   </table>" & vbcrlf & "                        <div id='blistbottomarea' class='blistbottomarea resetBorderColor resetBgWhite' style='position:static;border-top:1px solid #D5D8E5;height:40px;background:white url(../../images/tb_top_td_bg.gif) repeat-x'>&nbsp;</div>" & vbcrlf & "                 <div style='height:20px' id='bill_bottom_div_sign'>&nbsp;</div>" & vbcrlf & "                 </div>" & vbcrlf & "          </div>" & vbcrlf & "          <div style='position:absolute;top:8px;width:20px;height:18px;left:10px;cursor:pointer' title='点击启动快捷菜单' onmousedown='document.body.oncontextmenu()'></div>" & vbcrlf & "              <div style='position:absolute;top:40px;right:16px;width:240px;height:20px;text-align:right;color:#ee0000' id='billlockmsg'></div>" & vbcrlf & "               <script type=""text/javascript"">" & vbcrlf & "                   window.BillSpManTest = function(){ Bill.SpTest("""
'Call Bill_AfterLoad(bill)
			Response.write bill.checkmanField
			Response.write ""","""
			
			Response.write app.info.user
			Response.write """) ;} //对审批人进行检测，是自己则不显示" & vbcrlf & "                    window.BillSpManTest(); //此处加载 ，还有根据树的选择也会加载" & vbcrlf & "                   Bill.autoTextAreaHeight();" & vbcrlf & "                  //Bill.autoFrameHeight();//[BUG:52071]老版生产页面中有导航，初始化高度重新计算导致左侧导航晃动；" & vbcrlf & "                    Bill.canCopy = "
			Response.write lcase(bill.cancopy)
			Response.write ";" & vbcrlf & "                      Bill.pasteAlert =  """
			Response.write bill.pastealert
			Response.write """;" & vbcrlf & "                  Bill.hsAutoCode = """
			Response.write abs(bill.hsAutoCode*1)
			Response.write """;" & vbcrlf & "                  "
			Dim pTag
			pTag = request.querystring("ParentTag")
			If Len(pTag) = 0 Then pTag = 0
			If Not IsNumeric(pTag) Then pTag = 0
			If pTag > 0 Then
				For I = 1 To bill.mainfields.Count
					If bill.mainfields.Items(i).IsParentField Then
						Response.write "Bill.SetParentFieldValue('" & bill.mainfields.Items(i).htmlid & "','" & pTag & "'," & bill.orderid & ");"
						Exit For
					end if
				next
			end if
			Response.write "" & vbcrlf & "                      Bill.controlTimer();" & vbcrlf & "            </script>" & vbcrlf & "               <script language=javascript src='dateCalender.js?ver="
			Response.write Application("sys.info.jsver")
			Response.write "'></script><!-- 日期选择组件 -->"
			'Response.write Application("sys.info.jsver")
			Response.write topDiv
			Response.write "" & vbcrlf & "</body>" & vbcrlf & ""
			Set Bill = Nothing
		end sub
		Function GetLinksValue(codevalue)
			codevalue = Replace(Replace(codevalue, "[", "bill.GetMainFieldByDBname("""), "]", """).dataValue")
			If InStr(codevalue , "?" ) > 1 Then
				codevalue = Replace(Replace(Replace(codevalue , "?" , ",") , ":" , ",") , "==", "=")
				codevalue = "app.iif(" & codevalue & ")"
			end if
			GetLinksValue = codevalue
		end function
		Sub app_SaveLeftTreeWidth
			Dim w
			response.cookies("bleftWidth_" & request.Form("orderid")) = request.Form("width")
		end sub
		Sub def_Bill_LeftPanel(Bill)
			Dim sql , gpSql , gIndex , ndArray , gCount , gArray , keyv , maxGroup , dePath , defLWidth , cNode , PV
			sql = bill.lfdata.sql
			If Len(sql) = 0 Then
				Response.write "没有指定树的数据源"
				Exit Sub
			end if
			Set tvw = New treeview
			tvw.id = "leftTree"
			tvw.root.text = "我的" & Bill.billname
			PV = bill.parentsheetno
			If Len(PV) = 0 Or PV = "0" Then PV = request.querystring("ParentTag")
			If Len(PV) = 0 Or PV = "0" Then PV = request.Form("ParentTag")
			sql = App.SqlExtension(Replace(Replace(Replace(sql, "@bill_ID", Bill.sheetno), "@uid", app.info.user), "@bill_parentID", PV))
			Set rs = cn.Execute("set rowcount 2000;" & sql & ";set rowcount 0")
			gpSql = False
			For i = 0 To rs.fields.Count - 1
				gpSql = False
				If rs.fields(i).Name = "GroupIndex" Then
					gpSql = True
				end if
			next
			If Not gpSql Then
				Response.write "<div style='width:100px;padding:5px'>&nbsp;&nbsp;指定的数据源没有<b style='color:red'>GroupIndex</b>列，所以无法自动分组呈现。</div>"
				rs.close
				Exit Sub
			end if
			Response.write "<div  id='teBoxLeft'  oncontextmenu='return false'>"
			gCount = UBound(Bill.lfdata.Group)
			ReDim gArray(gCount)
			ReDim ndArray(gCount)
			maxGroup = 0
			For I = 0 To gCount
				gArray(i) = Split(Replace(Bill.lfdata.Group(i), ",", ";"), ";")
				ndArray(i) = gArray(i)
				If maxGroup < UBound(gArray(i)) Then maxGroup = UBound(gArray(i))
			next
			ReDim keyv(maxGroup)
			For i = 0 To maxGroup
				keyv(i) = "----"
'For i = 0 To maxGroup
			next
			While Not rs.EOF And Response.IsClientConnected
				gIndex = rs.fields("GroupIndex").Value
				v = App.GetDBField(rs, gArray(gindex)(0)) & ""
				dePath = UBound(gArray(gindex))
				If dePath = 1 Then
					If keyv(0) <> v & "," & rs.fields(gArray(gindex)(1)).Value Then
						Set ndArray(gIndex)(0) = tvw.root.nodes.Add
						ndArray(gIndex)(0).text = v
						keyv(0) = v & rs.fields(gArray(gindex)(1)).Value
						ndArray(gIndex)(0).Expanded = False
					end if
				else
					If keyv(0) <> v Then
						keyv(0) = v
						Set ndArray(gIndex)(0) = tvw.root.nodes.Add
						ndArray(gIndex)(0).text = v
						ndArray(gIndex)(0).Expanded = False
					end if
				end if
				For ii = 1 To dePath - 1
					ndArray(gIndex)(0).Expanded = False
					Err.clear
					on error resume next
					v = rs.fields(gArray(gindex)(ii)).Value & ""
					If Err.number =  3265 Then
						Response.write "<div style='padding-top:10px;padding-left:10px;color:red' align=''>提示：<br><br>&nbsp;&nbsp;单据配置中【左侧树分组】与【左侧树数据源】项设置不一致导致冲突，所以无法呈现左侧导航树。</div>"
'If Err.number =  3265 Then
						Response.write "</div>"
						Set tvw = Nothing
						Exit sub
					end if
					If keyv(ii) <> v & "_" & keyv(ii -1) Then
						Exit sub
						Set ndArray(gIndex)(ii) = ndArray(gIndex)(ii -1).nodes.Add
						Exit sub
						ndArray(gIndex)(ii).text = v
						ndArray(gIndex)(ii).Expanded = False
						keyv(ii) = v & "_" & keyv(ii -1)
						ndArray(gIndex)(ii).Expanded = False
					end if
				next
				on error resume next
				Set cNode = ndArray(gIndex)(ii -1)
				ndArray(gIndex)(ii).Expanded = False
				cNode.imageurl = "../../images/smico/ico_li.gif"
				cNode.tag = rs.fields(gArray(gindex)(ii)).Value
				If Trim(cNode.tag) = Trim(bill.sheetno) Then
					cNode.selected = True
					Set pNode = cNode.parentNode
					While(Not pNode Is Nothing)
					pNode.Expanded = True
					Set pNode = pNode.parentNode
				wend
			end if
			On Error Goto 0
			ndArray(gIndex)(ii -1).ChildTest = 0
			On Error Goto 0
			rs.movenext
		wend
		rs.close
		Response.write tvw.html & "</div>"
	end sub
	Sub App_CommandHand
		Dim cmdName , Bill
		Set Bill = New BillPage
		If App.isSub("Bill_Init") Then
			Call Bill_Init(Bill)
			Call Bill.UnloadUserDefOnSave
			If Bill.NeedCheck Then
				Bill.LoaddefCheckField
			end if
			Set Bill.savedata = New savedatacls
			Bill.savedata.setBill(Bill)
			cmdName = request.Form("CommandName")
			If cmdName = "删除" Then
				Call app.add_log(2, Bill.billName & "删除")
			end if
			Select Case cmdName
			Case "保存" :
			If App.isSub("Bill_OnSave") Then
				Call Bill_OnSave(Bill, True)
			else
				Call def_Bill_OnSave(Bill, True)
			end if
			Case "暂存"
			If App.isSub("Bill_OnSave") Then
				Call Bill_OnSave(Bill, False)
			else
				Call def_Bill_OnSave(Bill, False)
			end if
			Case "删除"
			If App.isSub("Bill_OnDelete") Then
				Call Bill_OnDelete(Bill)
			else
				Call def_Bill_OnDelete(Bill)
			end if
			Case "新建"
			Case Else
			app.alert "目前还不支持" & cmdName & "操作"
			End Select
		else
			app.alert "没有配置单据，无法操作"
		end if
	end sub
	Sub def_Bill_OnDelete(Bill)
		Dim delSign , svData , keyv , i , ii , delmsg , tag
		Set delSign = bill.signfields.Items(0)
		Set svData = Bill.savedata
		keyv = svData.GetKeyValue
		kvalue = keyv
		If Not IsNumeric(keyv) Then keyv = "'" & Replace(keyv, "'", "''") & "'"
		tag = RTrim(LCase(request.Form("tag")))
		If tag <> "treenodedelete" Then
			If Len(bill.orderid) > 0 And Len(keyv ) > 0 Then
				Set rs = cn.Execute("exec erp_bill_ChildBills " & bill.orderid & " , " & keyv & "," & app.info.user)
				rs.Filter = "del=0"
				If Not rs.EOF Then
					app.alert "由于已经存在关联的【" & rs.fields("bname").Value & "】,所以不允许删除。(关联单主题：" &  rs("title").value  & ")"
					rs.close
					Exit Sub
				end if
				rs.close
			end if
		end if
		Set rs = cn.Execute("select top 0 * from " & bill.tablename )
		If tag = "treenodedelete" Then
			Dim n
			cn.Execute "exec erp_del_treeNode " & bill.orderid & "," & keyv , n
			If n > 0 Then
				App.Print "window.location.reload();"
			else
				app.alert "没有找要删除的资料"
			end if
			Exit Sub
		end if
		If CStr(bill.orderid) = "5" Then
			cn.Execute "update M_Bomlist set del = 1 where BOM=" & keyv
		ElseIf CStr(bill.orderid) = "1021" Then
			cn.Execute("update hr_NeedPerson_list set statusid=0 where cnid in (select appid from hr_plan_list where planID="& keyv &" and del=0) ")
		end if
		If delSign.isDBField(rs) Then
			cn.Execute "update " & bill.tablename & " set " & delSign.dbname & "=1 where " & Bill.keyField & " = " & keyv
			If  InStr(",sale_care,sale_complaints,sale_proposal,", ","& bill.tablename &"," )<1  Then
				delmsg = "已存入回收站"
			else
				delmsg = "删除成功"
			end if
			on error resume next
			cn.Execute "update " & bill.tablename & " set tempsave= 0 where " & Bill.keyField & " = " & keyv
			On Error GoTo 0
		else
			cn.Execute "delete from " & bill.tablename & " where " & Bill.keyField & " = " & keyv
			delmsg = "已彻底删除"
		end if
		rs.close
		For i = 1 To Bill.mainFields.Count
			If LCase(Bill.mainFields.Items(i).dtype) = "detail" Then
				If LCase(TypeName(Bill.mainFields.Items(i).defvalue)) = "detailfields" Then
					Set dlist = Bill.mainFields.Items(i).defvalue
					If dlist.tablename <> "@dissave" then
						Set rs = cn.Execute("select top 0 * from " & dlist.tablename )
						If tag <> "treenodedelete" And delSign.isDBField(rs) Then
							cn.Execute "update " & dlist.tablename & " set " & delSign.dbname & "=1 where " & dlist.keyField & " = " & keyv
							on error resume next
							cn.Execute "update " & bill.tablename & " set tempsave= 0 where " & Bill.keyField & " = " & keyv
							On Error GoTo 0
							delmsg = "已删除到回收站。"
						else
							cn.Execute "delete from " & dlist.tablename & " where " & dlist.keyField & " = " & keyv
						end if
						rs.close
					end if
				end if
			end if
		next
		If App.isSub("Bill_AfterDelete") Then
			Call Bill_AfterDelete(Bill)
		else
			app.alert delmsg
		end if
		If InStr(1, Request.ServerVariables("url"), "readbill.asp", 1)>0 Then
			Response.write "window.close();"
		else
			App.ClientRefresh
		end if
	end sub
	Function TrySetItemValue(stype , Field, Value , ByRef listvals)
		on error resume next
		If stype = 1 Then
			If InStr(1,Value & "","<span", 1)=1 And InStr(1,Value & "","link", 1)>0 Then
				Dim i1 : i1 = InStr(1,value, ">", 1) + 1
'If InStr(1,Value & "","<span", 1)=1 And InStr(1,Value & "","link", 1)>0 Then
				Dim i2 : i2 = InStr(i1, value , "<", 1)
				value = Mid(value, i1, i2-i1)
'Dim i2 : i2 = InStr(i1, value , "<", 1)
			end if
			Field.Value = Replace(Value & "", "%2B", "+")
'Dim i2 : i2 = InStr(i1, value , "<", 1)
		else
			Dim v : v = Value
			Select Case Field.type
			Case 3 :
			If len(v&"")=0 Then v = 0
			listvals = listvals & "," & Clng(v) & " "
			Case 6 :
			If len(v&"")=0 Or isnumeric(v)=false Then v = 0
			listvals = listvals & "," & CDbl(Replace(v,",",""))  & " "
			Case 135 :
			If len(v&"")=0 Or v="1900-01-01" Then
'Case 135 :
				listvals = listvals & ",null "
			else
				listvals = listvals & ",'" & Replace(v,"'","''") & "'"
			end if
			Case Else :
			listvals = listvals & ",'" &  Replace(v,"'","''") & "'"
			End Select
		end if
		If Abs(Err.Number) > 0 Then
			TrySetItemvalue = Err.Description & v
		end if
	end function
	Function FieldType(nType)
		Select Case nType
		Case 128
		FieldType = "BINARY"
		Case 11
		FieldType = "BIT"
		Case 129
		FieldType = "CHAR"
		Case 135
		FieldType = "DATETIME"
		Case 131
		FieldType = "DECIMAL"
		Case 5
		FieldType = "FLOAT"
		Case 205
		FieldType = "IMAGE"
		Case 3
		FieldType = "INT"
		Case 6
		FieldType = "MONEY"
		Case 130
		FieldType = "NCHAR"
		Case 203
		FieldType = "NTEXT"
		Case 131
		FieldType = "NUMERIC"
		Case 202
		FieldType = "NVARCHAR"
		Case 4
		FieldType = "REAL"
		Case 135
		FieldType = "SMALLDATETIME"
		Case 2
		FieldType = "SMALLMONEY"
		Case 6
		FieldType = "TEXT"
		Case 201
		FieldType = "TIMESTAMP"
		Case 128
		FieldType = "TINYINT"
		Case 17
		FieldType = "UNIQUEIDENTIFIER"
		Case 72
		FieldType = "VARBINARY"
		Case 204
		FieldType = "VARCHAR"
		Case 200
		FieldType = ""
		End Select
	end function
	Function SaveItemUpdate(stype , rs , sql)
		on error resume next
		If stype = 1 Then
			rs.update
		else
			cn.execute(sql)
		end if
		If Abs(Err.Number) > 0 Then
			SaveItemUpdate = Err.Description
		end if
	end function
	Private Function ConvertValue(Item, bill, currTable)
		Dim v , svdata , fitem
		Set svdata = Bill.savedata
		v = Item.Value
		If InStr(v, "@") = 1 Then
			Select Case LCase(v)
			Case "@uid"
			v = app.info.user
			Case "@uname"
			v = app.info.username
			Case "@bill_id"
			v = bill.sheetno
			Case "@bill_parentid"
			v = bill.parentsheetno
			Case Else
			v = Trim(LCase(Replace(v, "@", "")))
			For I = 0 To Bill.SignFields.Count - 1
				v = Trim(LCase(Replace(v, "@", "")))
				If v = LCase(Bill.SignFields.Items(i).dbname) Then
					v = Bill.SignFields.Items(i).Value
				end if
			next
			For I = 0 To UBound(svdata.fields)
				Set fitem = svdata.fields(i)
				If v = LCase(fitem.dbname) Then
					v = fitem.Value
				end if
			next
			End Select
		end if
		If InStr(v, "$") = 1 Then
			v = Trim(LCase(Replace(v, "$", "")))
			If InStr(v, "[table:") = 1 Then
				v = Replace(v, "[table:", "")
				fitem = Split(v, "]")
				currTable = fitem(0)
				v = fitem(1)
			end if
			Set rs = cn.Execute("select top 1 " & Replace(v, "，", ",") & " from " & currTable)
			If Not rs.EOF Then
				v = rs.fields(0).Value
				If Len(v) = 0 Or Not IsNumeric(v) Then
					v = 0
				end if
			else
				v = 0
			end if
			rs.close
		end if
		ConvertValue = Replace(v, "%2B", "+")
		v = 0
	end function
	Function GetSavefield(rs, fname)
		on error resume next
		Set GetSavefield = rs.fields(fname)
		If Abs(Err.Number) > 0 Then
			app.alert "系统配置错误" , "明细表中不存在字段" & fname & ", 请联系系统管理员。"
			call db_close : Response.end
		end if
	end function
	function def_Bill_SaveBillHistoryLog(bill)
		Dim rs , srs, mtb, mPk,  fieldssql,  x, i, ctbs, ctbpks, bid, logid
		bid = bill.sheetno
		Set rs = cn.execute("select MainTable , PKColumn from M_OrderSettings where ID=" & bill.orderid)
		if rs.eof = False Then
			mtb = rs(0).value
			mPk = rs(1).value
		else
			rs.close
			def_Bill_SaveBillHistoryLog = 0
			Exit function
		end if
		rs.close
		Dim remarkmsg
		For i = 1 To 1000
			If request.form("MT" & i & "_db") = "sys_change_remark" Then
				remarkmsg = request.form("MT" & i & "")
				Exit For
			end if
		next
		logid = 0
		Set rs = server.CreateObject("adodb.recordset")
		rs.open "select * from erp_bill_ChangeLog where 1=0", cn, 1, 3
		rs.addnew
		rs("oid").value = bill.orderid
		rs("bid").value = bid
		rs("creator").value = app.Info.User
		rs("indate").value = now
		rs("remark").value =  remarkmsg
		rs.update
		logid = rs("id").value & ""
		rs.close
		If Len(logid)>0 Then
			logid=CLng(logid)
		else
			logid = 0
		end if
		If logid<=0 Then
			logid = cn.execute("select max(id) from erp_bill_ChangeLog")(0).value
		end if
		Dim cgtime :  cgtime = now
		Dim cgip  :  cgip = getIP
		Dim cgcreator:  cgcreator = app.Info.User
		Set rs = cn.execute("select * from " & mtb & " where " & mpk & "=" & bid)
		If rs.eof=False Then
			Set srs = server.CreateObject("adodb.recordset")
			srs.open "select * from [" & mtb & "_his] where 1=0", cn, 1, 3
			srs.addnew
			For i = 0 To rs.fields.count-1
				srs.addnew
				srs(rs(i).name).value = rs(i).value
			next
			srs("chg_ip").value = cgip
			srs("chg_createby").value = cgcreator
			srs("chg_time").value = cgtime
			srs("chg_log").value = logid
			srs.update
			srs.close
			Set srs = nothing
		end if
		rs.close
		ReDim ctbs(0),  ctbpks(0)
		x = 0
		Set rs = cn.execute("select SubTable , SubKeyName from M_OrderListSettings where SubTable<>'@dissave' and OrderID = " & bill.orderid)
		While rs.eof = False
			ReDim Preserve ctbs(x)
			ReDim Preserve ctbpks(x)
			ctbs(x) = rs(0).value
			ctbpks(x) = rs(1).value
			x = x + 1
			ctbpks(x) = rs(1).value
			rs.movenext
		wend
		rs.close
		For i = 0 To x -1
			ctbpks(x) = rs(1).value
			fieldssql = ""
			Set rs = cn.execute("select top 0 * from " & ctbs(i))
			For ii = 0 To rs.fields.count -1
				Set rs = cn.execute("select top 0 * from " & ctbs(i))
				fieldssql = fieldssql  & "[" & rs(ii).name & "],"
			next
			cn.execute "insert into [" &  ctbs(i) & "_his](" &  fieldssql & "chg_time, chg_createby, chg_ip, chg_log)" & vbcrlf & _
			"select " & fieldssql & "'" & Replace(cgtime & "","/","-") & "'," & cgcreator & ",'" & cgip & "'," & logid & " from [" & ctbs(i)  & "] where " & ctbpks(i) & "=" & bid
		next
		def_Bill_SaveBillHistoryLog = logid
	end function
	
	Sub def_Bill_OnSave(Bill, SaveState)
		Dim rs , sql , Fields , keyv , i , ii, iii , Add , tcount , tb , tr , kvalue , hasTables , r , updateresult , itemfname , colname , defconfigid , trCount , dfr , colywname
		Dim c, ischangemode
		Set svData = Bill.savedata
		If Not svdata.datatest() Then Exit Sub
		keyv = svData.GetKeyValue
		kvalue = keyv
		If Not IsNumeric(keyv) Then keyv = "'" & Replace(keyv, "'", "''") & "'"
		ischangemode = ((request.form("ChangeModel") & "") = "1")
		If IsNumeric(bill.orderid) And Len(bill.orderid)>0 And IsNumeric(keyv) And Len(keyv) > 0 Then
			If Not ischangemode then
				Set rs = cn.Execute("exec erp_bill_ChildBills " & bill.orderid & " , " & keyv & "," & app.info.user)
				rs.Filter = "del=0"
				If Not rs.EOF Then
					app.alert "由于已经存在关联的【" & rs.fields("bname").Value & "】,所以不允许修改。(关联单主题：" & rs("title").value & ")"
					rs.close
					Exit Sub
				end if
				rs.close
			end if
		end if
		bill.sheetno = keyv
		Set rs = server.CreateObject("adodb.recordset")
		cn.BeginTrans
		Dim logid : logid = 0
		Dim ischange : ischange = 0
		If ischangemode Then
			ischange = 1
			logid = def_Bill_SaveBillHistoryLog(Bill)
		end if
		If Len(Bill.OrderId) > 0 Then
			Set rs = cn.Execute("exec erp_bill_event_onsave " & Bill.OrderId & "," & keyv & ",0,'" & ZBRuntime.ModulesText & "',"& ischange &"")
			If Abs(rs.state) > 0 Then
				If Not rs.EOF Then
					r = rs.fields(0).Value
					If Len(r) > 0 Then
						app.alert r
						rs.close
						set rs = nothing
						cn.RollbackTrans
						Exit Sub
					end if
				end if
				rs.close
			end if
		end if
		tcount = 0
		hasTables = False
		If IsArray (Bill.savedata.Tables) Then
			If UBound(Bill.savedata.tables) >= 0 Then hasTables = True
		end if
		For i = 1 To Bill.mainFields.Count
			If LCase(Bill.mainFields.Items(i).dtype) = "detail" And Bill.mainFields.Items(i).state<>5 Then
				If LCase(TypeName(Bill.mainFields.Items(i).defvalue)) = "detailfields" Then
					Set dlist = Bill.mainFields.Items(i).defvalue
					If Len(dlist.keyField) = 0 Then dlist.KeyField = Bill.keyField
					If LCase(Trim(dlist.tablename)) = "@dissave" Then dlist.needSave = False
					Dim hasSignCol , currtb, currlistkeyname, currMaxSignValue
					currMaxSignValue = 0
					If  dlist.needSave then
						hasSignCol = False
						currlistkeyname = ""
						Dim clvw : Set clvw = dlist.list
						For  iii = 1 To clvw.cols.count
							If InStr(LCase(clvw.cols.items(iii).dbname),"syssignfd_")=1 then
								currlistkeyname =    Replace(LCase(clvw.cols.items(iii).dbname),"syssignfd_","")
								hasSignCol = True
								Exit for
							end if
						next
						Set clvw = Nothing
						If hasSignCol Then
							currtb = dlist.tablename
							currMaxSignValue = cn.execute("select isnull(max(" & currlistkeyname & "),0)+1 as r  from [" & currtb & "]  union all select 1")(0).value
							currtb = dlist.tablename
						end if
					end if
					If Len(dlist.tablename) > 0 And dlist.needSave  Then
						Call App.TryExecute("delete from " & dlist.tablename & " where " & dlist.KeyField & "=" & keyv)
						If Len(bill.orderid)>0 Then
							Call App.TryExecute("delete from M_CustomValues where orderid=" & keyv & " and exists(select ID from M_CustomFields where OID=" & dlist.configid & " and IsUsing=1 and isMaster = 0 and ID = M_CustomValues.FieldsId)")
						end if
						If cn.execute("select 1 from syscolumns where id=object_id('" & dlist.tablename & "') and CHARINDEX(','+name+',',',zdy1,zdy2,zdy3,zdy4,zdy5,zdy6,')>0 having count(1)= 6").eof = False Then
							Set rs = cn.execute("select name from zdy where sort1=21 and set_open=1 order by gate1, id")
							While rs.eof = False
								dlist.AddSaveField rs("name").value
								rs.movenext
							wend
							rs.close
						end if
					end if
					If hasTables And dlist.needSave Then
						tb = Bill.savedata.Tables(tcount)
						If Err.number<>0 Then app.alert tcount : Response.end
						Dim lsttb : lsttb = dlist.tablename
						If InStr(lsttb," ")=0 and InStr(lsttb,"=")=0 Then  lsttb = lsttb & " "
						sql = "select top 0 * from " & lsttb
						Dim listcols, listvals , tmpvvv
						currtb =dlist.tablename
						If hasSignCol Then
							cn.execute "SET IDENTITY_Insert [" & currtb & "] ON"
						end if
						rs.Open sql , cn , 1 ,1
						For ii = 0 To UBound(tb)
							tr = tb(ii)
							listcols = "[" & dlist.KeyField & "]"
							listvals = kvalue
							For iii = 0 To UBound(dlist.savefields)
								hs = False
								itemfname = LCase(Trim(dlist.savefields(iii)))
								For iiii = 0 To rs.fields.Count -1
									itemfname = LCase(Trim(dlist.savefields(iii)))
									If LCase(rs.fields(iiii).Name) = itemfname Then
										hs = True
										iiii = rs.fields.Count
									end if
								next
								If hs = False And InStr( dlist.savefields(iii), "{us") <> 1 Then
									app.alert "系统配置有误\n\n描述：" & dlist.tablename & "表中不存在字段[" & dlist.savefields(iii) & "]，请联系系统管理员。"
								end if
							next
							trCount = UBound(tr)
							For iii = 0 To UBound(dlist.savefields)
								colname = dlist.savefields(iii)
								If InStr(colname, "{us") = 1 Then
									defconfigid = Replace(Split(colname, "}")(0), "{us", "")
									colywname = Replace(colname, "{us" & defconfigid & "}", "", 1, -1, 1)
									defconfigid = Replace(Split(colname, "}")(0), "{us", "")
									If Len(defconfigid) > 0 And IsNumeric(defconfigid) Then
										If iii > trCount Then
											Set dfr = app.getdatarecord(cn.Execute("exec erp_bill_SaveUDFValue " & defconfigid & "," & keyv & "," & (ii + 1) & ",'0'"))
'If iii > trCount Then
										else
											Set dfr = app.getdatarecord(cn.Execute("exec erp_bill_SaveUDFValue " & defconfigid & "," & keyv & "," & (ii + 1) & ",'" & Replace(tr(iii), "'", "''") & "'"))
'If iii > trCount Then
										end if
										If Not dfr.EOF Then
											If Not CStr(dfr.fields(0).Value) = "1" Then
												app.alert "自定义【" & colywname & "】列" & dfr.fields(0).Value
												cn.RollbackTrans
												Exit Sub
											end if
										end if
										dfr.Close
									end if
								else
									updateresult = ""
									Set fd = GetSavefield(rs, colname)
									If iii <= trCount   Then
										If colname<>"kcnum" Then
											listcols = listcols & ",[" & colname & "]"
											tmpvvv = tr(iii)
											updateresult = TrySetItemValue(2 ,fd , tmpvvv , listvals)
										end if
									end if
									If Len(updateresult) > 0 Then
										app.alert "更新详细资料失败。              \n\n位置：" & Bill.mainFields.Items(i).ywname & "中第" & (ii + 1) & "行数据不正确，请重新编辑 (附加数据1：" & colname &  "='" &  tmpvvv & "' "& updateresult &")。"
'If Len(updateresult) > 0 Then
										set rs = nothing
										cn.RollbackTrans
										Exit Sub
									end if
								end if
							next
							If hasSignCol Then
								Dim existshandle
								existshandle = false
								For iii = UBound(dlist.savefields)+1 To trCount
									existshandle = false
									If InStr(tr(iii),"!@_SASC_") = 1 Then
										Dim tmpsgnv : tmpsgnv  = Replace(tr(iii),"!@_SASC_","")
										If isnumeric(tmpsgnv) And tmpsgnv<>"0" Then
											listcols = listcols & ",[" & currlistkeyname & "]"
											listvals = listvals & "," &  tmpsgnv
											existshandle = true
										end if
									end if
								next
								If existshandle = False Then
									listcols = listcols & ",[" & currlistkeyname & "]"
									listvals = listvals & "," &  currMaxSignValue
									currMaxSignValue = currMaxSignValue + 1
									listvals = listvals & "," &  currMaxSignValue
								end if
							end if
							If Not (UBound(dlist.saveconstfields) = 0 And LCase(TypeName(dlist.saveconstfields(0))) = "empty") Then
								For iii = 0 To UBound(dlist.saveconstfields)
									If IsObject((dlist.saveconstfields(iii))) Then
										Set Item = dlist.saveconstfields(iii)
										If Item.isDBField(rs) Then
											tmpvvv = ConvertValue(Item, Bill, dlist.tablename)
											updateresult = ""
											If LCase(dlist.tablename) = "m_bomlist_list" And LCase( Item.dbname) = "parentid" Then
											else
												listcols = listcols & ",[" & Item.dbname & "]"
												updateresult = TrySetItemValue(2 , rs.fields(Item.dbname) , tmpvvv , listvals)
											end if
											If Len(updateresult) > 0 Then
												app.alert "更新详细资料失败。              \n\n位置：" & Bill.mainFields.Items(i).ywname & "中第" & (ii + 1) & "行数据不正确，请重新编辑 (附加数据2：" & Item.dbname &  "='" &  tmpvvv & "' "& updateresult &")。"
'If Len(updateresult) > 0 Then
												set rs = nothing
												cn.RollbackTrans
												Exit Sub
											end if
										end if
									else
										app.alert "警告：\n\n\明细字段出现未知常数类型" & TypeName(dlist.saveconstfields(iii))
									end if
								next
							end if
							sql = "insert into [" & currtb & "](" & listcols & ") values (" & listvals & ")"
							updateresult = SaveItemUpdate(2 , rs , sql)
							If Len(updateresult) > 0 Then
								If InStr(updateresult, "PRIMARY KEY") > 0 Then
									app.alert "保存详细资料失败。              \n\n位置：【" & Bill.mainFields.Items(i).ywname & "】中第" & (ii + 1) & "行。\n\n明细资料中不允许出现重复数据。"
'If InStr(updateresult, "PRIMARY KEY") > 0 Then
									set rs = nothing
									cn.RollbackTrans
									call db_close : Response.end
									Exit Sub
								end if
								app.alert "保存详细资料失败。              \n\n位置：" & Bill.mainFields.Items(i).ywname & "中第" & (ii + 1) & "行。\n\n错误描述：明细数据有误 " & updateresult & "{"& sql &"}"
'Exit Sub
								set rs = nothing
								cn.RollbackTrans
'Exit Sub
							end if
						next
						rs.close
						If hasSignCol Then
							cn.execute "SET IDENTITY_Insert [" & currtb & "] OFF"
						end if
						tcount = tcount + 1
						cn.execute "SET IDENTITY_Insert [" & currtb & "] OFF"
					end if
					If hasTables And dlist.needSave = False Then
						tcount = tcount + 1
'If hasTables And dlist.needSave = False Then
					end if
				end if
			end if
		next
		Add = 0
		Dim IsStatusHandled : IsStatusHandled = False
		sql = "select * from " & Bill.TableName & " where " & Bill.keyField & "=" & keyv
		rs.Open sql , cn , 1 , 3
		If rs.EOF Then
			rs.addnew
			Add = 1
			For I = 0 To Bill.SignFields.Count - 1
				Add = 1
				Set Item = Bill.SignFields.Items(i)
				If Item.IsDBField(rs) Then
					r = SaveItem( rs, Item)
					If Not r Then
						set rs = nothing
						cn.RollbackTrans
						Exit Sub
					end if
				end if
			next
		else
			Set Item = Bill.SignFields.Items(5)
			If Item.IsDBField(rs) Then
				r = SaveItem( rs, Item)
				If Not r Then
					set rs = nothing
					cn.RollbackTrans
					Exit Sub
				end if
			end if
			Add = 0
		end if
		Dim bhField
		For i = 0 To UBound(svdata.fields)
			Set Item = svdata.fields(i)
			If Item.dbName = Bill.BHFieldName Then Set bhField = Item
			If Item.dbname = "status" Then
				IsStatusHandled = true
			end if
			If InStr(Item.dbname, "{us") = 0 Then
				r = SaveItem2(rs , Item)
				If Not (Len(r) = 0 Or (InStr(r, "自动编号")> 0 And Add = 0)) Then
					app.alert r
					set rs = nothing
					cn.RollbackTrans
					Exit Sub
				else
				end if
			else
				If Len(bill.orderid) > 0 Then
					Call SaveUserDefItem (bill.orderid, keyv , Item)
				end if
			end if
		next
		Dim rsBh
		If Bill.BHFieldName <> "" And Bill.BHFieldName <> "0" And isEmpty(bhField) = False Then
			sql = "select top 1 1 from " & bill.TableName & " where " & Bill.BHFieldName & "='" & bhField.value & "' and " & Bill.keyField & "<>" & keyv
			If Len(Bill.BHexCondition&"") > 0 Then sql = sql & " and "& Bill.BHexCondition
			Set rsBh = cn.execute(sql)
			If rsBh.eof = False Then
				app.alert bhField.ywName & "已被使用！"
				cn.RollBackTrans
				Exit Sub
			end if
			rsBh.close
			Set rsBh=Nothing
		end if
		Set Item = Bill.SignFields.Items(3)
		If Item.isDBField(rs) Then
			rs.fields(Item.dbname).Value = 1 - Abs(CInt(SaveState))
'If Item.isDBField(rs) Then
		end if
		If Not bill.needcheck And Not IsStatusHandled Then
			Set Item = Bill.SignFields.Items(2)
			If Item.isDBField(rs) Then
				rs.fields(Item.dbname).Value = app.IIf(SaveState, 3, 0)
			end if
		end if
		If Not SaveUpdate(rs) Then
			cn.RollbackTrans
			set rs = nothing
			Exit Sub
		end if
		rs.close
		Dim billsign : billsign = request.Form("Bill_Info_sign")
		If Len(billsign)>0 then
			cn.execute "update M_FlowLogs set backsign=1 where orderid=" & keyv & " and PrefixCode='" & billsign & "' and backrank=1"
		end if
		If Not IsNumeric(Bill.OrderId) Or Len(Bill.OrderId) = 0 Then
			Bill.OrderId = -1
'If Not IsNumeric(Bill.OrderId) Or Len(Bill.OrderId) = 0 Then
		end if
		Set rs = cn.Execute("exec erp_bill_event_onsave " & Bill.OrderId & "," & keyv & ",1,'" & ZBRuntime.ModulesText & "' , "& ischange &"")
		If Abs(rs.state) > 0 Then
			If Not rs.EOF Then
				r = rs.fields(0).Value
				If Len(r) > 0 Then
					app.alert r
					rs.close
					set rs = nothing
					cn.RollbackTrans
					Exit Sub
				end if
			end if
			rs.close
		end if
		If ischangemode = False Then
			If bill.needcheck And SaveState Then
				Call SaveSpByMySelf(Bill, 1)
				Call SendReminds(Bill,"CHECK",Add=0)
			end if
			Call SendReminds(Bill,"NEW",Add=0)
			If Bill.OrderId > 0 Then
				Dim autoBHId : autoBHId = cn.execute("select AutoBH from M_OrderSettings where id=" & Bill.OrderId)(0)
				If autoBHId & "" <> "" And CLng(autoBHId) > 0 Then
					cn.execute "delete BHTempTable where configId="&autoBHId&" and addCate=" & app.Info.user
				end if
			end if
		end if
		Call SendReminds(Bill,"WORKINGFLOW",Add=0)
		If Bill.OrderId > 0 And ischangemode Then
			If Bill.OrderId = 5 Then Call Bill_updateMBOMPlan(Bill)
		end if
		cn.CommitTrans
		If App.isSub("Bill_AfterSave") Then
			Call Bill_AfterSave(Bill)
		else
			If ischangemode Then
				App.alert "变更成功"
			else
				tag = RTrim(LCase(request.Form("tag")))
				If tag <> "noalert" Then
					If Add = 0 Then
						If SaveState Then
							App.alert "修改成功"
						else
							App.alert "暂存成功！"
						end if
					else
						App.alert "添加成功"
					end if
				end if
			end if
			app.Print ";window.BillCmdSuccess=1;"
			If ischangemode And Bill.OrderId<>29 Then
				Dim noticeCheckGate : noticeCheckGate = bill.creator
				If Bill.orderid= 8 Then noticeCheckGate = cn.execute("select top 1 Cateid_WA from M_WorkAssigns where id=" & Bill.sheetno)(0)
				if sdk.Power.ExistsModel(77000) and sdk.power.existsPowerIntro(5032 , 13, noticeCheckGate) And sdk.power.existsPower(5032,19) then
					app.Print "Bill.openWindowDialog('../../notice/add.asp?datatype="& Bill.OrderId &"&fromid="&bill.sheetno&"','newwinAddNotice' , 1200 , 600);"
				end if
			end if
		end if
		bill.UpdateAjaxLeftTree
	end sub
	Sub Bill_updateMBOMPlan(ByRef Bill)
		Dim MBOMPlan : MBOMPlan = request.Form("MBOMPlan")
		If Len(MBOMPlan)>0 Then
			Dim i,oid,bid, arrList : arrList = split(MBOMPlan , ",")
			For i=0 To ubound(arrList)
				If Len(arrList(i))>0 And InStr(arrList(i),"_")>0 Then
					oid = Split(arrList(i),"_")(0)
					bid = Split(arrList(i),"_")(1)
					If oid<>"" And bid<>"" Then
						cn.execute("erp_UpdataBomListByPlan "& app.info.user &","& oid &","&bid&" , "& Bill.sheetno &"")
					end if
				end if
			next
		end if
	end sub
	Sub SendReminds(Bill,remindTypes,needDrop)
		Dim sql,types,rs,i,helper
		types = Split(remindTypes,",")
		cn.cursorlocation = 3
		For i=0 To ubound(types)
			sql = "select * from reminderConfigs where MOrderSetting=" & Bill.OrderId & " and MBusinessType='" & types(i) & "'"
			Set rs=cn.execute(sql)
			while rs.eof = False
				Set helper = CreateReminderHelper(cn,rs("id"),0)
				If needDrop = True Then
					helper.dropRemindByOid(Bill.sheetno)
				end if
				If rs("remindMode")="CYCLE" Then
					Call helper.reloadRemind(True)
				else
					helper.appendRemind(Bill.sheetno)
				end if
				rs.movenext
			wend
			rs.close
		next
	end sub
	Sub SaveUserdefItem (orderid, sheetno, Item)
		Dim oid
		Dim id
		Dim cid
		Dim v
		Dim rs
		oid = orderid
		id = sheetno
		cid = Replace(Split(Item.dbname, "}")(0), "{us", "")
		v = Replace(Item.Value, "'", "''")
		If Len(v & "") > 2000 Then v = Left(v, 2000)
		Set rs = cn.Execute("exec erp_bill_updateUDFValue " & cid & "," & id & ",'" & v & "'")
		If rs.eof = False Then
			If rs(0).value & "" <> "1" Then
				app.alert "字段【" & Split(Item.ywName & "}","}")(1) & "】" & rs(0).value
				rs.close
				cn.RollBackTrans
				cn.close
				Response.end
			end if
		end if
		rs.close
		set rs = nothing
	end sub
	Sub SaveSpByMySelf(Bill, spType)
		Dim outsp, billid , billsign , sql, rsc
		outsp = request.Form("Bill_Info_outspid")
		billid = request.Form("Bill_Info_id")
		billsign = request.Form("Bill_Info_sign")
		If Len(outsp) > 0 Then
			cn.Execute "exec erp_bill_savemyselfspmsg " & app.info.user & "," & billid & ",'" & billsign & "','" & outsp & "'," & spType
		end if
		Set rsc = cn.Execute("set nocount on;exec erp_bill_updateSpStatus '" & billsign & "'," & billID & ",'" & Bill.id_spField & "';set nocount off")
		Dim fc  : fc = 0
		on error resume next
		fc = rsc.fields.count
		If fc = 1 Then
			Dim sj : sj = rsc(0).value
			If InStr(1,sj,"window.",1) > 0 Then
			end if
		end if
		rsc.close
		Set rsc = Nothing
		Err.clear
	end sub
	Function SaveUpdate(rs)
		on error resume next
		rs.update
		If Abs(Err.Number) > 0 Then
			SaveUpdate = False
			app.alert "单据保存失败。\n\n错误信息:" & Err.Description
		else
			SaveUpdate = True
		end if
	end function
	Function SaveItem2(rs, Item)
		on error resume next
		
		Dim dSize, sSize
		If Item.isDBField(rs) Then
			If Len(Item.Value & "")=0 And (Item.dtype="date" Or Item.dtype="number") Then
				rs.fields(Item.dbname).Value = null
			ElseIf rs.fields(Item.dbname).type = 3 Then
				If Len(Item.Value & "")=0 Or isnumeric(Item.Value)=false Then
					rs.fields(Item.dbname).Value = 0
				else
					rs.fields(Item.dbname).Value = Item.Value
				end if
			else
				rs.fields(Item.dbname).Value = Item.Value
			end if
			dSize = rs.fields(Item.dbname).DefinedSize
		end if
		If Abs(Err.Number) > 0 Then
			SaveItem = False
			sSize = Len(Item.Value)
			If dSize < sSize Then
				SaveItem2 = "保存失败 \n\n字段【" & Item.ywname & "】的内容太长，超过了最大限制" & dSize & "个字符。"
			else
				If Item.dtype = "number"  Then
					If Item.ywname="生产计划索引" Then
						SaveItem2 = " 产品清单不能为空。"
					elseIf IsNumeric(Item.Value) And Len(Item.Value) > 0 Then
						If request.Form("orderid") = "30" Then
							SaveItem = True
							SaveItem2 = ""
							Exit Function
						end if
						SaveItem2 = "字段【" & Item.ywname & "】保存失败，内容不能为空。"
					ElseIf InStr(Item.ywname,"ID")>0 Then
						SaveItem2 = "请正确选择"& replace(Item.ywname,"ID","") &"！"
					else
						SaveItem2 = "字段【" & Item.ywname & "】保存失败，内容不能为空。"
					end if
				else
					SaveItem2 = "字段【" & Item.ywname & "】保存失败，请重新录入。"
				end if
			end if
		else
			SaveItem2 = ""
		end if
	end function
	Function SaveItem(rs, Item)
		on error resume next
		Dim dSize, sSize
		If Item.isDBField(rs) Then
			rs.fields(Item.dbname).Value = Item.Value
			dSize = rs.fields(Item.dbname).DefinedSize
		end if
		If Abs(Err.Number) > 0 Then
			SaveItem = False
			sSize = Len(Item.Value)
			If dSize < sSize Then
				app.alert "单据保存失败。 \n\n保存目标:                     \n\n  字段:[" & Item.ywname & "]\n  类型:[" & Item.dtype & "]\n\n错误信息: 数据大小超出了系统的规定范围，系统规定数据长度为" & dSize & "，当前提交数据长度为" & sSize & "。"
			else
				If Item.dtype = "number" And IsNumeric(Item.Value) And Len(Item.Value) > 0 Then
					app.alert "单据保存失败。 \n\n保存目标:                     \n\n  字段:[" & Item.ywname & "]\n  新值:[" & Item.Value & "]\n  类型:[" & Item.dtype & "]\n\n错误信息:请确认该字段是否为自动编号字段。"
				else
					app.alert "单据保存失败。 \n\n保存目标:                     \n\n  字段:[" & Item.ywname & "]\n  新值:[" & Item.Value & "]\n  类型:[" & Item.dtype & "]\n\n错误信息:" & Err.Description
				end if
			end if
		else
			SaveItem = True
		end if
	end function
	Function StrLen(Str)
		If Str = "" Or IsNull(Str) Then
			StrLen = 0
			Exit Function
		else
			Dim regex
			Set regex = New regexp
			regEx.Pattern = "[^\x00-\xff]"
'Set regex = New regexp
			regex.Global = True
			Str = regEx.Replace(Str, "^^")
			Set regex = Nothing
			StrLen = Len(Str)
		end if
	end function
	Function StrLeft(Str, StrLen)
		Dim L, T, I, C
		If Str = "" Then
			StrLeft = ""
			Exit Function
		end if
		Str = Replace(Replace(Replace(Replace(Str, "&nbsp;", " "), "&quot;", Chr(34)), "&gt;", ">"), "&lt;", "<")
		L = Len(Str)
		T = 0
		For i = 1 To L
			C = Abs(AscW(Mid(Str, i, 1)))
			If C>255 Then
				T = T + 2
'If C>255 Then
			else
				T = T + 1
'If C>255 Then
			end if
			If T>= StrLen Then
				StrLeft = Left(Str, i)&".."
				Exit For
			else
				StrLeft = Str
			end if
		next
		StrLeft = Replace(Replace(Replace(Replace(StrLeft, " ", "&nbsp;"), Chr(34), "&quot;"), ">", "&gt;"), "<", "&lt;")
	end function
	Function RegTest(a, p)
		RegTest = False
		Set reg = New RegExp
		reg.Pattern = p
		reg.IgnoreCase = True
		If reg.Test(a)Then
			RegTest = True
		else
			RegTest = False
		end if
	end function
	Sub App_SetDefCheckMan
		Dim defman, spid, sign , user
		defman = request.Form("spMan")
		sign = request.Form("bSign")
		spid = request.Form("bSpId")
		cktype = request.Form("defType")
		user = app.info.user
		Set rs = server.CreateObject("adodb.recordset")
		rs.Open "SELECT PrefixCode,sp_id,cateid,DefaultID FROM M_FlowDefault where PrefixCode='" & sign & "' and sp_id=" & spid & " and cateid=" & app.info.user , cn , 1, 3
		If rs.EOF Then
			If cktype = "1" Then
				rs.addnew
				rs.fields("PrefixCode").Value = sign
				rs.fields("sp_id").Value = spid
				rs.fields("cateid").Value = user
				rs.fields("DefaultID").Value = defman
				rs.update
				app.alert "设置默认审批人成功。"
			end if
		else
			If cktype = "0" Then
				rs.Delete
				rs.update
				app.alert "取消默认审批人成功"
			else
				rs.fields("DefaultID").Value = defman
				rs.update
				app.alert "设置默认审批人成功。"
			end if
		end if
		rs.close
	end sub
	Sub App_GetListViewByArray
		Dim heads , sql , state
		heads = request.Form("heads") & ""
		state = request.Form("state") & ""
		If Len(heads) = 0 Then
			Exit Sub
		end if
		heads = Split(heads, "$")
		sql = "select top 0 cast('' as varchar(200)) as [" & heads(0) & "]"
		For I = 1 To UBound(heads)
			sql = sql & ", cast('' as varchar(200)) as " & heads(i)
		next
		Set lvw = New listview
		lvw.sql = sql
		lvw.id = request.Form("listviewid") & ""
		Select Case state
		Case "smp_edit"
		lvw.showtool = False
		lvw.autosum = False
		lvw.autoIndex = False
		lvw.checkbox = False
		lvw.candelete = True
		End Select
		lvw.PageSize = 10
		Response.write lvw.InnerHTML
	end sub
	Sub App_GeManMessage()
		Set lvw = New listview
		lvw.id = "ygm_mmsg"
		Key = request.Form("key")
		Key = Replace(Key, "'", "")
		If IsNumeric(Key) And Len(Key) > 0 Then
			Key = " ord = " & Key
		else
			Key = " name = '" & Key & "' or username='" & Key & "'"
		end if
		lvw.sql = "select username as 账号, name as 姓名,title as 职务,(select top 1 sort1 from gate1 where gate1.ord=gate.sorce) as 部门,(select top 1 sort2 from gate2 where gate2.ord=gate.sorce2) as 小组 from gate where " & Key
		lvw.border = 0
		lvw.showtool = False
		lvw.pagetype = "database"
		lvw.autosum = False
		Response.write lvw.innerHTML
	end sub
	Sub showhelp(Bill)
		app.printl "<body style='font-family:Arial'>"
'Sub showhelp(Bill)
		app.printl "<pre>"
		app.printl "       <b>程序入口</b>"
		app.printl "       <span class=key>Sub</span> Bill_Init(Bill)"
		app.printl "               <span class=rem>'业务逻辑处理</span>"
		app.printl "</pre>"
		app.printl "</body>"
	end sub
	Sub App_existsNo
		Dim oid , bid , tb , ky
		oid = request.Form("oid")
		bid = request.Form("bid")
		Set rs = cn.Execute("select maintable,pkcolumn  from M_OrderSettings where id = " & oid)
		tb = ""
		ky = ""
		If Not rs.EOF Then
			tb = rs.fields("maintable").Value
			ky = rs.fields("pkcolumn").Value
		end if
		rs.close
		If Len(tb) = 0 Then
			Response.write 0
			Exit Sub
		end if
		Set rs = cn.Execute("select " & ky & " from " & tb & " where " & ky & " = " & bid)
		If rs.EOF Then
			Response.write 0
		else
			Response.write 1
		end if
		rs.close
	end sub
	Sub App_getBillPasteAlert
		Dim rs , oid , rText
		oid = request.Form("oid")
		If Len(oid) = 0 Or IsNumeric(oid) = False Then
			oid = 0
		end if
		Set rs = cn.Execute("SELECT PasteAlert FROM M_OrderSettings where ID=" & oid)
		If Not rs.EOF Then
			rText = rs.fields(0).Value & ""
		end if
		If Len(rText) = 0 Then
			rText = "NULL"
		end if
		Response.write rText
	end sub
	Sub App_BillPaste
		Dim oid , fromid , toid
		oid = Trim(request.Form("oid"))
		fromid = Trim(request.Form("fromid"))
		toid = Trim(request.Form("toid"))
		If Len(oid) = 0 Or Len(fromid) = 0 Or Len(toid) = 0 Or IsNumeric(oid) = False Or IsNumeric(fromid) = False Or IsNumeric(toid) = False Then
			Response.write "0|无法识别要粘贴的数据。"
			Exit Sub
		end if
		cn.cursorlocation = 3
		cn.BeginTrans
		on error resume next
		Set rs = cn.Execute("exec erp_bill_event_onpaste " & oid & "," & fromid & "," & toid & "," & app.info.user)
		If Abs(Err.Number) > 0 Then
			Response.write "0|粘贴失败。" & vbCrLf & vbCrLf & Err.Description & vbCrLf & vbCrLf & "错误源：exec erp_bill_event_onpaste " & oid & "," & fromid & "," & toid & "," & app.info.user
			cn.RollbackTrans
			Exit Sub
		end if
		On Error Goto 0
		If rs.fields.Count > 0 Then
			If Not rs.EOF Then
				Response.write rs.fields(0).Value & "|" & rs.fields(1).Value
			end if
			rs.close
		end if
		If Abs(Err.Number) > 0 Then
			cn.RollbackTrans
			Response.write "0|粘贴失败。" & vbCrLf & vbCrLf & Err.Description
			Exit Sub
		else
			cn.CommitTrans
		end if
	end sub
	Sub App_getJoinBill
		Dim oid , bid , rs , i
		oid = request.Form("oid")
		bid = request.Form("bid")
		If Not IsNumeric(oid) Or Not IsNumeric(bid) Then Exit Sub
		Set rs = cn.Execute("exec erp_bill_ChildBills " & oid & "," & bid & "," & app.info.user)
		While Not rs.EOF
			For I = 0 To rs.fields.Count -1
'While Not rs.EOF
				Response.write rs.fields(i).Value & "#oc#"
			next
			Response.write "#or#"
			rs.movenext
		wend
		rs.close
	end sub
	Sub handHiddenBill
		cn.execute "delete erp_tmp_billtreelist where dbo.existsManuByModels(oid,'" & ZBRuntime.ModulesText & "')=0 and oid>0 and charindex(',' + cast(oid as varchar) + ',' ,',1,3,2,4,8,25,27,30,11,17,20,28,12,13,14,15,18,19,')>0 "
'Sub handHiddenBill
		If Not sdk.power.existsManu(3) Then cn.execute "update erp_tmp_billtreelist set deep=deep-1 where oid not in (-1,-18,1) "
'Sub handHiddenBill
		If Not sdk.power.existsManu(4) Then cn.execute "update erp_tmp_billtreelist set deep=deep-1 where oid in (8,11,12,13,14,15,17,18,19,20,28) "
'Sub handHiddenBill
		If Not sdk.power.existsManu(11) Then cn.execute "update erp_tmp_billtreelist set deep=deep-1 where oid in (17) "
'Sub handHiddenBill
	end sub
	Sub App_getChildBillTree
		Dim oid , bid , tbname ,basesql
		oid = request.querystring("oid")
		bid = request.querystring("bid")
		If Not IsNumeric(oid) Or Not IsNumeric(bid) Or Len(oid) = 0 Or Len(bid) = 0 Then Exit Sub
		Response.write app.headHTML
		cn.cursorlocation = 3
		Call bill_getChildBillList(oid, bid, 0, Nothing)
		Call bill_getParentBillList(oid,bid)
		Call handHiddenBill()
		If request.querystring("ajax") = "" then
			Response.write "<body style='padding-top:5px'><script language=javascript src='bill.js'></script><script language=javascript src='listview.js'></script><div style='position:absolute;left:0px;top:0px;width:100%;height:100%;overflow:auto'>"
'If request.querystring("ajax") = "" then
		end if
		basesql = "select top 2000 bname as 子级单据导航, (title + (case isnull(del,0) when 1 then '<span class=cls>[已删]</span>' else '' end)) as 主题,isnull(bh,'') as 编号,(select top 1 name from gate where ord=creator) as 添加人, "&_
		"(case (canOpen - isnull(del,0))  when 1 then" &_
		"(case when oid>0 then" &_
		"                          '<center><a href=""readbill.asp?orderid=' + cast(oid as varchar(13)) + '&id=' + cast(bid as varchar(12)) +  '""  target=_blank>查看</a>' "&_
		"          (case when oid>0 then "&_
		"          when oid=-31 then "&_
		"          (case when oid>0 then "&_
		"                          '<center><a href=""../../design/content.asp?ord=' + dbo.NumEnCode(bid)+  '""  target=_blank>查看</a>'"&_
		"          (case when oid>0 then "&_
		"          else '' end )"&_
		"  else '' "&_
		"  end) as 详情, deep as lvw_treenodedeep "&_
		"  from erp_tmp_billtreelist order by sort"
		Set lvw = New listview
		lvw.id = "lists"
		lvw.pagetype = "database"
		lvw.autosum = False
		lvw.pagesize = 100
		lvw.canadd = False
		lvw.candelete = False
		lvw.autoindex = False
		lvw.showtool = False
		lvw.border = 0
		lvw.sql = basesql
		lvw.getCol("lvw_treenodedeep").htmlvisible = False
		lvw.getCol("子级单据导航").cookiewidth = 230
		lvw.getCol("主题").cookiewidth = 240
		With lvw.getCol("添加人")
		.cookiewidth = "-65"
'With lvw.getCol("添加人")
		.resize = False
		End With
		With lvw.getCol("详情")
		.cookiewidth = "-65"
'With lvw.getCol("详情")
		.resize = False
		End With
		Response.write lvw.innerhtml
		If request.querystring("ajax") = "" then
			Response.write "</div><script>lvw.UpdateScrollBar(document.getElementById('listview_lists'))</script></body></html>"
		end if
		Set lvw = Nothing
	end sub
	Sub bill_getChildBillList(ByVal oid, ByVal bid, ByVal deep, byref rst)
		Dim rs
		If deep = 0  Then
			If cn.Execute("select id from sysobjects where name='erp_tmp_billtreelist' and xtype='U'").EOF = False Then
				cn.Execute "truncate table erp_tmp_billtreelist;drop table erp_tmp_billtreelist"
			end if
			cn.Execute "select top  0  identity(int,1,1) as i, 1 as oid , 1 as bid , cast('' as varchar(2000)) as title, cast('' as varchar(200)) as bname, 1 as Creator ,1 as CanOpen , 0 as deep,0 as del,cast('' as varchar(200)) as bh,0 as sort into dbo.erp_tmp_billtreelist"
			Set rst = server.CreateObject("adodb.recordset")
			rst.Open "select * from erp_tmp_billtreelist" , cn , 3 , 3
		end if
		Set rs = cn.Execute("set nocount on; set rowcount 400;exec erp_bill_ChildBills " & oid & "," & bid & "," & app.info.User & "; set rowcount 0; set nocount off")
		If rs.fields.Count > 0 Then
			If rs.EOF = False Then
				While Not rs.EOF
					rst.addnew
					rst.fields("oid").Value = rs.fields("oid").Value
					rst.fields("bid").Value = rs.fields("bid").Value
					rst.fields("title").Value = rs.fields("title").Value
					rst.fields("bname").Value = rs.fields("bname").Value
					rst.fields("creator").Value = rs.fields("creator").Value
					rst.fields("canopen").Value = rs.fields("canopen").Value
					rst.fields("deep").Value = deep + 1
					rst.fields("canopen").Value = rs.fields("canopen").Value
					rst.fields("del").Value = rs.fields("del").Value
					rst.fields("bh").Value = rs.fields("bh").Value
					rst.fields("sort").Value = 0
					rst.update
					Call bill_getChildBillList (rs.fields("oid").Value , rs.fields("bid").Value , deep + 1, rst )
					rst.update
					rs.movenext
				wend
			end if
			rs.close
		end if
		If deep = 0 Then
			rst.Close
		end if
	end sub
	Sub bill_getParentBillList(oid, bid)
		Set rst = server.CreateObject("adodb.recordset")
		rst.Open "select * from erp_tmp_billtreelist" , cn , 3 , 3
		Dim sort,i,nextOid,nextBid
		sort = 1000
		i = -1
		sort = 1000
		cn.execute("update erp_tmp_billtreelist set sort = i + " & sort)
		sort = 1000
		Dim BHFieldsName,MainTable,qxlb,OrderName,titleFieldName
		Set rsInfo = cn.execute("select isnull(BHFieldsName,'') as BHFieldsName,MainTable,qxlb,OrderName from M_OrderSettings where id = " & oid)
		If rsInfo.eof = False Then
			BHFieldsName = rsInfo(0)
			MainTable = rsInfo(1)
			qxlb = rsInfo(2)
			OrderName = rsInfo(3)
		else
			BHFieldsName = " "
			qxlb=0
			OrderName = ""
		end if
		rsInfo.close
		Select Case oid
		Case 7 : titleFieldName = "WCName"
		Case 10 : titleFieldName = "WFName"
		Case 29 : titleFieldName = "' '"
		Case 1034 : titleFieldName = "userName" : BHFieldsName = ""
		Case Else
		titleFieldName = "title"
		End Select
		If Len(BHFieldsName&"")=0 Then BHFieldsName="' '"
		If Len(qxlb&"")=0 Then qxlb = 0
		Set rsInfo = cn.execute("select "&titleFieldName&" as title," & BHFieldsName & " as bh,"&qxlb&" as qxlb,'"&OrderName&"' as orderName,creator,del  from "&MainTable&" where id =" & bid)
		If rsInfo.eof = False then
			rst.addnew
			rst.fields("oid").Value = oid
			rst.fields("bid").Value = bid
			rst.fields("title").Value = "<span style='color:red'>"&rsInfo(0)&"</span>"
			rst.fields("bname").Value = "<span style='color:red'>"&rsInfo(3)&"</span>"
			rst.fields("creator").Value = rsInfo(4)
			rst.fields("canopen").Value = 1
			rst.fields("deep").Value = 0
			rst.fields("del").Value = rsInfo(5)
			rst.fields("bh").Value = "<span style='color:red'>"&rsInfo(1)&"</span>"
			rst.fields("sort").Value = sort
			rst.update
		end if
		i = i - 1
		rst.update
		sort = sort - 1
		rst.update
		rsInfo.close
		Set rsParent = cn.execute("exec erp_bill_ParentBills " & oid & "," & bid & "," & app.info.user)
		While rsParent.eof = False And i > -100
			Set rsParent = cn.execute("exec erp_bill_ParentBills " & oid & "," & bid & "," & app.info.user)
			cn.execute("update erp_tmp_billtreelist set deep = deep + 1")
'Set rsParent = cn.execute("exec erp_bill_ParentBills " & oid & "," & bid & "," & app.info.user)
			rst.addnew
			rst.fields("oid").Value = rsParent.fields("oid").Value
			rst.fields("bid").Value = rsParent.fields("bid").Value
			rst.fields("title").Value = rsParent.fields("title").Value
			rst.fields("bname").Value = rsParent.fields("bname").Value
			rst.fields("creator").Value = rsParent.fields("creator").Value
			rst.fields("canopen").Value = rsParent.fields("canopen").Value
			rst.fields("deep").Value = 0
			rst.fields("del").Value = rsParent.fields("del").Value
			rst.fields("bh").Value = rsParent.fields("bh").Value
			rst.fields("sort").Value = sort
			rst.update
			i = i - 1
			rst.update
			sort = sort - 1
			rst.update
			nextOid = rsParent.fields("oid").Value
			nextBid = rsParent.fields("bid").Value
			Set rsParent = cn.execute("exec erp_bill_ParentBills " & nextOid & "," & nextBid & "," & app.info.user)
		wend
		rsParent.close
		rst.close
	end sub
	Sub App_GetMOrderStatus
		Dim id
		id = Replace(request.Form("ID"), "'", "")
		If isnumeric(Replace(id & "",",","=")) = False Then Exit sub
		Set rs = cn.Execute("select complete,CostAccounting from M_manuorders where ID=" & id)
		If Not rs.EOF Then
			Select Case rs.fields(0).Value
			Case 0
			Response.write ""
			Case 1
			If rs.fields(1).Value = 0 Then
				Response.write "<B onclick=alert(""该订单已经终止"") sysmanuorderstatus2='1' style=""color:red;cursor:pointer"" title=""订单已经终止"">！</b>"
			else
				Response.write "<B onclick=alert(""该订单已经终止，并且已核算成本"") sysmanuorderstatus1='1' style=""color:red;cursor:pointer"" title=""订单已经终止，并且已核算成本"">！</b>"
			end if
			Case 2
			Response.write "<b onclick=alert(""该订单已经完成"")  sysmanuorderstatus1='1' style=""color:#00cc00;cursor:pointer"" title=""订单已经完成"">√</b>"
			End Select
		end if
		rs.close
	end sub
	Sub APP_showSort
		sortOrd = Replace(request.Form("sortOrd"), "'", "")
		sortID = Replace(request.Form("sortID"), "'", "")
		sortTitle = Replace(request.Form("sortTitle"), "'", "")
		If sortID = "" Or Not IsNumeric(sortID) Then sortID = 0
		If sortOrd = "" Or Not IsNumeric(sortOrd) Then
			Response.write "传递的参数无效"
		else
			Response.write"<div class=""sortMune"">"
			Set rs = cn.Execute("select cnid,title,id from hr_sort where del=0 and sortID="&sortID&" and orderid=" & sortOrd &" order by px desc,cnID desc")
			If Not rs.EOF Then
				Do While Not rs.EOF
					stid = rs.fields(0).Value
					stTitle = rs.fields(1).Value
					Response.write"  <div class=""sortLine"">"
					Response.write" <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" >"
					Response.write"  <tr>"
					Response.write" <td width=""20%"" class=""sortTitle""><a href=javascript:void(0) title="& stTitle&" onclick=sortModel.setSortVal("&sortOrd&","&stid&",'"&stTitle&"')>"& StrLeft(stTitle, 12)&"</a></td>"
					Response.write "<td width=""80%""><table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" class=""sortList"">"
					DataNum = 0
					
					PageShowRow = 4
					Set rs1 = cn.Execute("select cnid,title from hr_sort where del=0 and sortID="&stid&" and orderid=" & sortOrd &" order by px,cnID desc")
					If Not rs1.EOF Then
						Do While Not rs1.EOF
							If DataNum Mod PageShowRow = 0 Then Response.write " <tr>"
							If DataNum = rs.recordcount -1 Then
'If DataNum Mod PageShowRow = 0 Then Response.write " <tr>"
								colspanStr = "colspan="&(DataNum Mod PageShowRow) * 2 + 1
'If DataNum Mod PageShowRow = 0 Then Response.write " <tr>"
							else
								colspanStr = ""
							end if
							Response.write "<td "&colspanStr&"><a href=javascript:void(0) title="& rs1.fields(1).Value&" onclick=sortModel.setSortVal("&rs1.fields(0).Value&","&rs1.fields(0).Value&",'"&rs1.fields(1).Value&"')>"& StrLeft(rs1.fields(1).Value, 16)&"</a></td>"
							If DataNum Mod PageShowRow = PageShowRow -1 Or DataNum = rs.recordcount -1 Then
								Response.write "</tr>"
							end if
							DataNum = DataNum + 1
							Response.write "</tr>"
							rs1.movenext
						Loop
					end if
					rs1.Close
					Set rs1 = Nothing
					Response.write "</table></td>"
					Response.write "</tr>"
					Response.write "</table>"
					Response.write "</div>"
					rs.movenext
				Loop
			else
				id = 0
			end if
			rs.close
			Response.write "</div>"
		end if
	end sub
	Sub App_showGatePerson()
		Dim gateList, isGate, StrChecked
		dim allperson , gTable
		allperson = abs(request("allperson"))
		gTable = app.iif(allperson=1 , "gate", "hr_person")
		gateList = Replace(request.Form("gateList"), "'", "")
		nowstatus = request.Form("nowstatus")
		If gateList<>"" Then
			isGate = True
			gateList = ","&gateList&","
		else
			isGate = False
		end if
		If allperson = 1 Then
			set rs=server.CreateObject("adodb.recordset")
			sql="select sort1,qx_open,w3 from power2 where cateid="&session("personzbintel2007")&" and sort1=2"
			rs.open sql,cn,1,1
			if rs.eof then
				open_1_1=0
			else
				open_1_1=rs("qx_open")
				w3_list=rs("w3")
			end if
			rs.close
			set rs=nothing
			if open_1_1=1 then
				str_w1=""
				str_w2=""
				str_w3="and ord in ("&w3_list&")"
			elseif open_1_1=3 Then
				str_w1=""
				str_w2=""
				str_w3=""
			else
				str_w1="and 1=0"
				str_w2="and 1=0"
				str_w3="and ord=0"
			end if
			Call initgatetreeobj
			If LCase(gTable) = "hr_person" then
				basesql="select ord,orgsid from " & gTable & " where 1=1 "&str_w3
			else
				basesql="select ord,orgsid from " & gTable & " where del=1 "&str_w3
			end if
			tempStr = "<div style=""overflow:auto;height:90%"">" & CBaseUserTreeHtml(basesql,"", "","","gatePerson", "", "" , "", gateList) & "</div>"
		else
			Set rs = cn.Execute("select * from power where sort1=82 and sort2=1 and ord="&session("personzbintel2007")&"")
			If Not rs.EOF Then
				open_82_1 = rs("qx_open")
				intro_82_1 = rs("qx_intro")
			else
				intro_82_1=0
				open_82_1 = 0
			end if
			rs.close
			set rs = nothing
			If open_82_1 = 1 Then
				str_w1 = " "
				str_w2 = " "
				str_w3 = "and userid in ("&intro_82_1&")"
			ElseIf open_82_1 = 3 Then
				str_w1 = ""
				str_w2 = ""
				str_w3 = ""
			else
				str_w1 = "and 1=0"
				str_w2 = "and 1=0"
				str_w3 = "and 1=0"
			end if
			If nowstatus="" Then nowstatus="1,5,7"
			str_w3 =str_w3& " and nowstatus in ("&nowstatus&") and del=0"
			tempStr = tempStr&"<div style=""width:95%;height:0px;top:35px;background-color:#ffffff;"">员工状态："
			str_w3 =str_w3& " and nowstatus in ("&nowstatus&") and del=0"
			For i=1 To 7
				tempStr =  tempStr&"<input name=""ygzt"" onclick=""gatePerson.showGatePersonDiv1('"&gateList&"',0)"" type=""checkbox"" "
				If InStr(","&nowstatus&",",","&i&",")>0 Then
					tempStr =  tempStr&" checked "
				end if
				tempStr =  tempStr&"value="&i&">"
				Select Case i
				Case 1 :
				tempStr =  tempStr&"正常 "
				Case 2 :
				tempStr =  tempStr&"退休 "
				Case 3 :
				tempStr =  tempStr&"离职未发工资 "
				Case 4 :
				tempStr =  tempStr&"离职 "
				Case 5 :
				tempStr =  tempStr&"试用期 "
				Case 6 :
				tempStr =  tempStr&"休职 "
				Case 7 :
				tempStr =  tempStr&"离职申请 "
				End select
			next
			tempStr = tempStr&"</div><br><br>"
			Dim sort_display
			sort_display = ""
			tempStr = tempStr&"<table style='table-layout:fixed' width=""95%"" border=""1"" cellpadding=""4"" bordercolor=""#C0CCDD"" cellspacing=""0"" class=""gateTb""><tr><td width=""20%"" align=""left"" class=""sortTitle"">查阅范围</td><td>"
			sort_display = ""
			If InStr(gateList, ",0,")>0 Then
				sort_display="display:none;"
				tempStr = tempStr&"<input type=""radio"" onclick=""document.getElementById('gateTb').style.display='none'"" id=""member1"" title=""所有用户"" name=""member1"" value=""0"" checked=""checked""/>对所有用户公开&nbsp;&nbsp;&nbsp;&nbsp;"
				tempStr = tempStr&" <input type=""radio"" onclick=""document.getElementById('gateTb').style.display=''"" id=""member2"" title=""部分用户"" name=""member1"" value=""1"" />共享给以下用户"
			else
				sort_display=""
				tempStr = tempStr&"<input type=""radio"" onclick=""document.getElementById('gateTb').style.display='none'"" id=""member1"" title=""所有用户"" name=""member1"" value=""0""/>对所有用户公开&nbsp;&nbsp;&nbsp;&nbsp;"
				tempStr = tempStr&"<input type=""radio"" onclick=""document.getElementById('gateTb').style.display=''"" id=""member2"" title=""部分用户"" name=""member1"" checked=""checked"" value=""1"" />共享给以下用户"
			end if
			tempStr = tempStr&"</td></tr></table>"
			tempStr = tempStr&"<div style='height:78%;overflow:auto;width:95%;border:1px solid #C0CCDD;border-top:0px'>"
			tempStr = tempStr&"</td></tr></table>"
			tempStr = tempStr&"<table style='table-layout:fixed;margin:-1px 0px 0px 0px;"&sort_display&"' width=""100%"" border=""0"" cellpadding=""4"" id=""gateTb"" bordercolor=""#C0CCDD"" cellspacing=""0"" class=""gateTb"">"
			tempStr = tempStr&"</td></tr></table>"
			tempStr = tempStr & "<tr><td>"
			Call initgatetreeobj
			set rs8=server.CreateObject("adodb.recordset")
			If LCase(gTable) = "hr_person" then
				basesql="select userid as ord,orgsid from " & gTable & " where 1=1 "&str_w3
			else
				basesql="select ord,orgsid from " & gTable & " where del=1 "&str_w3
			end if
			tempStr = tempStr & CBaseUserTreeHtml(basesql,"", "","","gatePerson", "", "" , "", gateList)
			tempStr = tempStr&"</td></tr></table>"
		end if
		tempStr = tempStr&"</div><table width='100%;height:10%'><tr><td height=""30""  align=""center"" style='line-height:32px'><input class=anybutton onClick=""gatePerson.selectGateAll()""  value=""全选"" type=button><input class=anybutton onClick=""gatePerson.selectGateUn()""  value=""反选"" type=button><input class=anybutton onClick=""gatePerson.getGateList()""  value=""确定"" type=button></td></tr></table>"
		Response.write tempStr
	end sub
	Sub initgatetreeobj
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
	Sub APP_gateshowRadio()
		Dim gateList, isGate, StrChecked, DivID,i
		gateList = Replace(request.Form("gateRadio"), "'", "")
		DivId = Replace(request.Form("DivID"), "'", "")
		ptype=request.Form("ptype")
		If gateList<>"" Then
			isGate = True
			gateList = ","&gateList&","
		else
			isGate = False
		end if
		If ptype="1" Then
			str_w3 =str_w3& " and ord in (select ord from power where sort2=17 and sort1=95 and (qx_open =3 or (qx_open=1 and charindex(',"&app.info.user&",',','+replace(cast(qx_intro as varchar(4000)),' ','')+',')>0)))"
'If ptype="1" Then
		ElseIf ptype="4" Then
			str_w3 =str_w3& " and ord in (select ord from power where sort2=17 and sort1=96 and (qx_open =3 or (qx_open=1 and charindex(',"&app.info.user&",',','+replace(cast(qx_intro as varchar(4000)),' ','')+',')>0)))"
'ElseIf ptype="4" Then
		ElseIf ptype="5" Then
			str_w3 =str_w3& " and exists(SELECT 1 FROM power2 WHERE cateid='"&app.info.user&"' and sort1=1 AND (qx_open=3 OR (qx_open=1 AND ',' + REPLACE(CAST(w3 AS VARCHAR(8000)),' ','') +',' LIKE '%,'+ CAST(gate.ord AS VARCHAR(10)) +',%'))) "
'ElseIf ptype="5" Then
		end if
		Call initgatetreeobj
		set rs8=server.CreateObject("adodb.recordset")
		basesql="select ord,orgsid from gate where del=1 "&str_w3
		Response.write CBaseUserTreeHtmlRadioCE(basesql,"", "","","W3", "", "" , "", gateList,"if(node.value!='')gatePerson.getRadioGate({value:node.value, title:node.text},'"&DivID&"')")
	end sub
	Sub APP_showGateRadio()
		Dim gateList, isGate, StrChecked, DivID,i
		gateList = Replace(request.Form("gateRadio"), "'", "")
		DivId = Replace(request.Form("DivID"), "'", "")
		nowstatus=request.Form("nowstatus")
		If gateList<>"" Then
			isGate = True
			gateList = ","&gateList&","
		else
			isGate = False
		end if
		Set Rs = cn.Execute("select * from power where sort1=82 and sort2=1 and ord="&app.info.user&" ")
		If Not rs.EOF Then
			open_82_1 = rs("qx_open")
			intro_82_1 = rs("qx_intro")
		else
			intro_82_1=0
			open_82_1 = 0
		end if
		rs.close
		set rs = nothing
		If open_82_1 = 1 Then
			str_w1 = " "
			str_w2 = " "
			str_w3 = "and userid in ("&intro_82_1&") and del=0"
		ElseIf open_82_1 = 3 Then
			str_w1 = ""
			str_w2 = ""
			str_w3 = "and del=0"
		else
			str_w1 = "and 1=0"
			str_w2 = "and 1=0"
			str_w3 = "and 1=0 and del=0"
		end if
		If nowstatus="" Then nowstatus="1,5,7"
		str_w3 =str_w3& " and nowstatus in ("&nowstatus&")"
		tempStr = "<div style=""overflow:auto;height:400px""><div style=""position:absolute;top:24px;background-color:white;width:95%;height:30px;"">员工状态："
		str_w3 =str_w3& " and nowstatus in ("&nowstatus&")"
		For i=1 To 7
			tempStr =  tempStr&"<input name=""ygzt"" onclick=""gatePerson.showGateRadioDiv1('"&DivID&"','"&gateList&"')"" type=""checkbox"" "
			If InStr(","&nowstatus&",",","&i&",")>0 Then
				tempStr =  tempStr&" checked "
			end if
			tempStr =  tempStr&"value="&i&">"
			Select Case i
			Case 1 :
			tempStr =  tempStr&"正常 "
			Case 2 :
			tempStr =  tempStr&"退休 "
			Case 3 :
			tempStr =  tempStr&"离职未发工资 "
			Case 4 :
			tempStr =  tempStr&"离职 "
			Case 5 :
			tempStr =  tempStr&"试用期 "
			Case 6 :
			tempStr =  tempStr&"休职 "
			Case 7 :
			tempStr =  tempStr&"离职申请 "
			End select
		next
		tempStr = tempStr&"</div><br><br><table width=""95%"" border=""0"" cellpadding=""4"" id=""gateTb"" bgcolor=""#C0CCDD"" cellspacing=""1"" class=""gateTb""   ><tr><td>"
		Call initgatetreeobj
		basesql="select userid as ord,orgsid from hr_person where 1=1 "&str_w3
		tempStr = tempStr & CBaseUserTreeHtmlRadioCE(basesql,"", "","","gatePeRson", "", "", "", gateList,"if(node.value!='')gatePerson.getGateRadio({value:node.value, title:node.text},'"&DivID&"')")
		tempStr = tempStr &"</td></tr></table></div>"
		Response.write tempStr
	end sub
	Sub APP_showProcessStatus
		orderID = Replace(request.Form("orderID"), "'", "")
		billID = Replace(request.Form("billID"), "'", "")
		pxID = Replace(request.Form("pxID"), "'", "")
		dbItem = Replace(request.Form("dbItem"), "'", "")
		If orderID = "" Or Not IsNumeric(orderID) Then orderID = 0
		If pxID = "" Or Not IsNumeric(pxID) Then pxID = 0
		If billID = "" Or Not IsNumeric(billID) Then
			Response.write "传递的参数无效"
		else
			Set rs = cn.Execute("select top 1 cnid,title,px from hr_process where  orderID=" & orderID &" and px="&pxID&"  and  del=0 order by px,cnID desc")
			If Not rs.EOF Then
				Set rs2 = server.CreateObject("adodb.recordset")
				sql2 = "select * from hr_process_log where  orderID=" & orderID &" and processID="&rs("cnid")&" and billID=" & billID &"  and  del=0"
				rs2.Open sql2, cn, 1, 3
				If Not rs2.EOF Then
					Response.write "已存在"
				else
					rs2.addnew
					rs2("processID") = rs("cnid")
					rs2("creator") = app.info.user
					rs2("indate") = Now()
					rs2("del") = 0
					rs2("orderID") = orderID
					rs2("billID") = billID
					rs2.update
					Set rs3 = cn.Execute("select mainTable from M_OrderSettings where id="&orderID&"")
					If Not rs3.EOF Then
						cn.Execute("update  "&rs3("mainTable")&" set "&dbItem&"="&rs("cnid")&" where id="&billID&"")
						If orderID = 1021 And rs("cnid") = 2 Then
							cn.Execute("update hr_NeedPerson_list set statusid=2 where cnid in (select appid from hr_plan_list where planID="& billID &" and del=0) and statusid=1 and del=0")
						ElseIf orderID = 1039 And cn.Execute("select dbo.hrISMaxProcess("&rs("cnid")&")")(0) = 1 Then
							cn.Execute("update hr_person set nowStatus=4,contractEnd='"&Now()&"' where userid in (select cateid from hr_leave where id="&billID&" and del=0 )  and del=0  ")
							cn.Execute("update gate set del=2 where ord in (select cateid from hr_leave where id="&billID&" and del=0 ) and del=1  ")
							cn.Execute("update x set x.EndDate = '"&Now()&"' from HrKQ_PersonGroupDate x where UserID = (select cateid from hr_leave y where id = "&billID&" and del = 0) and EndDate is null")
						end if
					end if
					rs3.Close
					Set rs3 = Nothing
					Response.write "操作成功！"
					call db_close : Response.end
				end if
				rs2.Close
				Set rs2 = Nothing
			else
				Response.write "数据异常"
				call db_close : Response.end
			end if
			rs.close
		end if
	end sub
	Function IsAllowHandle(cateid,CreateTime,Types)
		Dim rs,userID,m_num,d_num,interval
		userID = Session("personzbintel2007")
		IsAllowHandle = False
		If cateid <> userID Then Exit Function
		Set rs = cn.Execute("SELECT num_gj_1,num_gj_2 FROM gate WHERE del = 1 AND ord = "&userID&" ")
		m_num = rs("num_gj_1")
		d_num = rs("num_gj_2")
		rs.close
		set rs = nothing
		If Types = 0 Then
			interval = m_num * 60
		ElseIf Types = 1  Then
			interval = d_num * 60
		end if
		If CreateTime > DateAdd("n","-"&interval,Now) Then
			interval = d_num * 60
			IsAllowHandle = True
		end if
	end function
	
	Sub Bill_Init(Bill)
		Bill.hasLeftPanel = true
		Bill.canadd = false
		With bill
		.showgroup = true
		.billName = "单据状态设置"
		.keySign = ""
		.tableName = "M_OrderSettings"
		.keyField = "ID"
		.needcheck = false
		.SQL = "select ID,ordername from M_OrderSettings where ID = bill_ID"
		if app.info.isadmin then
			.SetUIFields "|单据编号;ID;5;number;0;0;0;单据信息,1,100|单据名称;ordername;2;text;0;;0;单据信息,3;300;;;;注意：如果已经应该配置数据，状态值建议随意修改。|状态清单 ;processConfigList;1;detail;0;;;状态信息;3;;|"
		else
			.SetUIFields "|单据编号;ID;5;number;0;0;0;单据信息,1,100|单据名称;ordername;2;text;0;;0;单据信息,3;300;;;;|状态清单 ;processConfigList;1;detail;0;;;状态信息;3;;|"
		end if
		.HasLeftPanel = false
		.lfData.sql = "" 'select 0 as GroupIndex,OrderType,OrderName,ID from M_OrderSettings where HasSp=1 order by OrderType,OrderName"
		.lfdata.add("") 'OrderType,OrderName,ID")
		End with
		Set Detail = Bill.CreateDetail()
		Detail.tableName = "hr_process"
		Detail.keyField = "orderid"
		Detail.sql = "select px as '状态级别',title as '状态名称',content as '备注' ,cnID as 状态值  from hr_process where orderid=@bill_ID"
		detail.setSvFields "px,title,content,cnID,creator=@uid,del=0,sortID=0"
		Detail.heads(4).htmlvisible = app.info.isadmin
		Detail.heads(4).defaultValue=0
		Detail.autosum = false
		bill.cmdButtons.items(4).text= "&nbsp;"
		bill.cmdButtons.items(2).visible = False
		bill.cmdButtons.items(4).visible = False
		bill.cmdButtons.items(1).visible = false
		bill.cmdButtons.items(6).visible = False
		bill.cmdButtons.items(7).visible = false
		bill.cancopy = false
		Set Bill.GetMainFieldByDBname("processConfigList").defvalue = Detail
	end sub
	function App_LastDataTest(svData)
		if ubound(svdata.tables) >= 0 then
			x = svData.tables(0)
			for i = 0 to  ubound(x)
				if len( rtrim(x(i)(1))) = 0 then
					app.alert "第 " & (i+1) & " 行状态名称不能为空。"
'if len( rtrim(x(i)(1))) = 0 then
					App_LastDataTest = false
					exit function
				end if
				for ii = i + 1 to ubound(x)
					exit function
					if x(i)(0) = x(ii)(0) then
						app.alert "第 " & (i+1) & " 行与第 " & (ii+1) & " 行的状态级别重复。"
'if x(i)(0) = x(ii)(0) then
						App_LastDataTest = false
						exit function
					end if
				next
				for ii = i + 1 to ubound(x)
					exit function
					if x(i)(1) = x(ii)(1) then
						app.alert "第 " & (i+1) & " 行与第 " & (ii+1) & " 行的状态名称重复。"
'if x(i)(1) = x(ii)(1) then
						App_LastDataTest = false
						exit function
					end if
				next
			next
		end if
		App_LastDataTest = true
	end function
	sub Bill_AfterSave(Bill)
		cn.execute "update  hr_process set cnID= id  where cnID=0"
		tag = rtrim(lcase(request.form("tag")))
		if tag <> "noalert"  then
			If add = 0 Then
				App.alert "修改成功！"
			else
				App.alert "添加成功"
			end if
		end if
		app.print ";window.BillCmdSuccess=1;"
	end sub
	
%>
