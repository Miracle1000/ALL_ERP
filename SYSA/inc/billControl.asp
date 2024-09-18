<%
Response.charset = "UTF-8"
Call messagePost( request("__msgId") )
sub messagePost(id)
	Dim cStatus
	if id="setThreathControl" then
        if request.Cookies("sys_isutimeout") = "1" then 
            exit sub '超时模式下已经屏蔽窗口，所以不再做多人操作检测
		end If
		cStatus = request.form("controlStatus")
		If isnumeric(cStatus) = False Then cStatus = 0
		cStatus = CLng(cStatus)
		If cStatus >= 10 Then  '启用多人同时修改某个资料页控制
			call handleThreathControl
		End If
		If  cStatus mod 2 = 1 Then '启用同账号操作多个冲突页控制
			Call handleConflictPage
		End if
	end If
	If id = "statusView" Then
		Call App_statusView
	End If
	
	If id = "unRegConflictPage" Then  '冲突页解锁
		Call unRegConflictPage
	End if
end Sub
'冲突页解锁
Sub unRegConflictPage
	session("__sys_ConflictPage") = ""
	session("__sys_ConflictPageTime") = ""
	session("__sys_ConflictPagetitle") = ""
	'session("xxx") = session("xxx")  + 1
End sub

'防止用户同时打开多个冲突页
Sub handleConflictPage
	session("__sys_ConflictPage") = Request.form("url")
	session("__sys_ConflictPageTime") = now 
	session("__sys_ConflictPagetitle") = request.form("currtitle")
End sub

'判断编辑或修改页面是否重复打开（现在存在sqlserver中，频繁操作队列会导致数据库日志增加，新改动存放在内存中）
'handleThreathControl_old是存sql版
'实现思路：
'1、公共队列(application对象)中存放结构体（uid, rdata, ldate）={用户，页面数据，最后操作时间}
'2、删除最后通讯时间小于10s的（算作超时处理）
'3、从队列中判断是否有相同页面的其它用户在操作。有则提示他人正在操作，没有则注册当前用户正在使用页面
sub handleThreathControl
	dim fdat , url , rs ,uid , gid , appdata , hasreg, freeIndex , item , t
	Dim i
	uid = session("personzbintel2007")
	If Len(uid) = 0 Then uid = "0"
	uid = CLng(uid)
	url = Request.form("url")
	fdat = url & "$#@" & request.form("formdata") & "T$%" & request.form("queryData")
	if len(fdat) > 500 then fdat = right(fdat,500)  '原来是900
	
	hasreg = False  '当前页面是否有他人操作
	t = now
	Application.Lock
	appdata = Application("__sys_billcontrolData") '队列数组
	If Not isArray(appdata) Then  ReDim appdata(0)
	freeIndex = -1
	For i = 0 To ubound(appdata)
		If Not isArray(appdata(i)) then 
			If freeIndex = -1 Then freeIndex = i	'获取空闲位置
		Else
			item = appdata(i)
			If Abs(datediff("s",item(2),t)) > 10 Then '超过10s的记录清除
				appdata(i) = ""
			Else
				If item(1) =  fdat  Then '如果已经存在他人操作页面
					If item(0) <> uid then
						gid = item(0)
                        if gid = 0 or len(replace(gid," ","")&"")=0 then
						    appdata(i)(2) = now
						    response.write ""
                        else
						    Dim cn 
						    Set cn = server.createobject("adodb.connection")
						    cn.open Application("_sys_connection")
						    cn.cursorlocation = 3
						    set rs = cn.execute("select name from gate with(nolock) where ord=" & gid)
						    if rs.eof = false then
							    gid= rs.fields("name").value
						    else
							    gid = "用户【" & gid & "】"
						    end If
						    rs.close
						    cn.close
						    Set rs =nothing
						    Set cn = nothing
						    response.write gid
                        end if
					Else
						appdata(i)(2) = now
						response.write ""
					End If
					Application("__sys_billcontrolData")  =  appdata
					Application.unLock
					Exit sub
				End if
			End if
		End If
	Next
	If freeIndex < 0 Then 
		freeIndex = ubound(appdata) + 1  
		ReDim Preserve appdata(freeIndex)
	End if
	ReDim item(2)
	item(0) = uid
	item(1) = fdat
	item(2) = now
	appdata(freeIndex) = item
	Application("__sys_billcontrolData")  =  appdata
	Application.unLock
end sub

Sub App_statusView
	Dim dat, n, item, uid
	uid = session("personzbintel2007")
	If Len(uid) = 0 Then uid = "0"
	uid = CLng(uid)
	If uid = 0 Then Exit Sub
	dat = Application("__sys_billcontrolData")
	Response.write "<table border=1 cellspacing=0 style='border-collapse:collapse;font-size:12px;' cellpadding=5><tr><td>序号</td><td>用户</td><td>数据</td><td>最后访问时间</td></tr>"
	If isarray(dat) Then
		For n = 0 To ubound(dat)
			item = dat(n)
			If isArray(item) Then
				Response.write "<tr><td>" & n & "</td><td>" & item(0) & "</td><td>" & item(1) & "</td><td>" & item(2) & "</td></tr>"
			Else
				Response.write "<tr><td colspan=4>已销毁</td></tr>"
			End If
		next
	End If
	Response.write "</table>"
End sub
%>