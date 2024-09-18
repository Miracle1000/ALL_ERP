<%@ language=VBScript %>
<%
	Response.charset = "UTF-8"
	Dim oid, bid , sctype , Lock , uid, scUid, datas, newdatas , i, ii, hasv, items, t, nm, rs
	oid = Abs(request.Form("oid"))
	bid = Abs(request.Form("bid"))
	sctype = Abs(request.Form("sctype"))
	Lock = Abs(request.Form("lock"))
	uid =  CLng("0" & session("personzbintel2007"))
	If uid = 0 Then Response.redirect "../../index2.asp"
	scUid = 0 : t = now
	Application.lock
	datas = Application("M_billThreadControl")
	ii = 0
	hasv = false
	ReDim newdatas(0)
	If sctype = 1 Then
		If isArray(datas) Then
			For i = 0 To ubound(datas)
				If isarray(datas(i)) Then
					items = datas(i)
					If ( (items(0)=oid And items(1)=bid And items(3)=1 And Abs(datediff("s",items(4),t)) > 20) Or  Abs(datediff("s",items(4),t)) > 120  ) = false Then
						ReDim Preserve newdatas(ii)
						newdatas(ii) = items
						If Lock = 1 Then
							If items(0) = oid And items(1) = bid And items(3)=sctype Then
								If  items(2)<>uid then
									scUid = items(2)
								else
									newdatas(ii)(4)=t
									hasv = true
								end if
							end if
						end if
						ii=ii+1
						hasv = true
					end if
				end if
			next
		end if
	end if
	If scUid > 0 Then
		If request.form("ca_cid") = scUid & "" Then
			Response.write oid & "|" & request.form("ca_nm") & "|" & scUid
		else
			Dim cn : Set cn = server.CreateObject("adodb.connection")
			cn.open Application("_sys_connection")
			Set rs = cn.execute("select top 1 name from gate where ord=" & scuid)
			If rs.eof = False Then
				nm = rs(0).value
			else
				nm = "未知用户(" & scUid & ")"
			end if
			rs.close
			set rs = nothing
			Set cn = Nothing
			Response.write oid & "|" & nm & "|" & scUid
		end if
	else
		If Lock = 1 Then
			If hasv = False Then
				ReDim Preserve newdatas(ii)
				newdatas(ii) =  array(oid, bid, uid, sctype,t)
				ii=ii+1
				'newdatas(ii) =  array(oid, bid, uid, sctype,t)
			end if
		end if
	end if
	If ii>0 Then
		Application("M_billThreadControl")  = newdatas
	else
		Application("M_billThreadControl")  = ""
	end if
	Application.unlock
	
%>
