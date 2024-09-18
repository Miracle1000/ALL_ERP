<%
'生成产品分类
Function GetProductClsHtml(con)
    Dim rsmenu, rs_menu
    Dim sql, rHtml()
    Dim len_rs_menu, i, j
    Dim tempStr
    Dim deep, ChildCount, id, id1, ydeep, menuname, clickStr
    sql = "set nocount on;" & _
    "       declare @i int " & _
    "       set @i = 0 " & _
    "       select id,id1,menuname,  " & _
    "       cast((case id1 when 0 then " & _
    "       cast(right('0000000' + cast(1000000-gate1%1000000 as varchar(12)),7)+ ',' + right('0000000' + cast(id as varchar(12)),7) as varchar(8000)) else '' end) as varchar(8000)) as sk, gate1, 0 deep,isnull((select count(1) from menu where id1=mm.id),0) as ChildCount into #t from menu mm " & _
    "       where (isnull(mm.user_list1,'')='' or mm.user_list1='' or mm.user_list1='0' " & _
    "       	or charindex(',"&session("personzbintel2007")&",',','+replace(mm.user_list1,' ','')+',')>0  " & _
    "       ) " & _
    "       while exists(select 1 from #t where len(sk)=0) and @i < 10 " & _
    "       begin " & _
    "           update y  " & _
    "           set y.sk = x.sk + ',' + right('0000000' + cast(1000000-y.gate1%1000000 as varchar(12)),7) + ',' + right('0000000' + cast(y.id as varchar(12)),7), y.deep = x.deep + 1 " & _
    "           from #t x inner join #t y on x.id = y.id1 and len(x.sk) > 0 and y.sk = '' " & _
    "           set @i = @i + 1 " & _
    "       end " & _
    "       select * from #t where sk<>'' order by sk; drop table #t; set nocount off;"
	Set rsmenu = con.Execute(sql)
    If rsmenu.EOF = False Then
        rs_menu = rsmenu.GetRows()
    End If
    rsmenu.Close
    Set rsmenu = Nothing
    If IsArray(rs_menu) Then
        len_rs_menu = UBound(rs_menu, 2)
    Else
        len_rs_menu = -1
    End If
    ydeep = 0
    ReDim rHtml(len_rs_menu)
    Dim ihtml
    For i = 0 To len_rs_menu
        tempStr = ""
        ihtml = ""
        id = rs_menu(0, i): id1 = rs_menu(1, i): menuname = rs_menu(2, i): deep = rs_menu(5, i): ChildCount = rs_menu(6, i)
        If i > 0 Then
            ydeep = rs_menu(5, i - 1)
        End If
        If ChildCount = 0 Then
            clickStr = ""
        Else
            'BUG:1321 客户购买明细 高级检索 产品分类不能展开 xieyanhui2014.2.7 （此处生成的ID在某种条件下会和上面生成的区域ID重复导致无法展开）
            clickStr = "onClick=""document.getElementById('" & Chr(60) & "%=dynStr%" & Chr(62) & "cp_t_s_" & id & "').style.display=(this.checked==1?'':'none');" & _
             "document.getElementById('" & Chr(60) & "%=dynStr%" & Chr(62) & "cp_s_s_" & id & "').style.display=(this.checked==1?'':'none');"""
        End If
        If deep = ydeep And i > 0 Then
            ihtml = "</div>" & vbCrlf
        ElseIf deep < ydeep Then
            For j = deep To ydeep
               ihtml = ihtml & "</div>" & vbCrlf
            Next
        End If
        tempStr = tempStr & "<div id=""" & Chr(60) & "%=dynStr%" & Chr(62) & "cp_s_s_" & id & """ style=""border:0px;display:none;padding-left:20px;""></div><input name=""A2"" type=""checkbox"" value=""" & id & """ id=""" & Chr(60) & "%=dynStr%" & Chr(62) & "cp_d_s_" & id & """" & clickStr & ">" & menuname & vbCrlf
        tempStr = tempStr & "<div id=""" & Chr(60) & "%=dynStr%" & Chr(62) & "cp_t_s_" & id & """ style=""border:0px;display:none;padding-left:40px;"">" & vbCrlf
        ihtml = ihtml & tempStr
        If i = len_rs_menu Then
           ihtml = ihtml & "</div>" & vbCrlf
        End If
        rHtml(i) = ihtml
    Next
    GetProductClsHtml = Join(rHtml, "")
    Set con = Nothing
End Function

Dim con
On Error Resume Next
Set con = conn : if err.number <> 0 Then set con = cn
Response.write GetProductClsHtml(con)
set con = nothing
%>