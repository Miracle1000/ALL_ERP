<%
if request.querystring("ParentOrd")="-1" then
	bill.GetMainFieldByDBname("CreateFrom").defvalue=1
end if

if request.querystring("ParentOrd")="-8" then
	bill.GetMainFieldByDBname("CreateFrom").defvalue=3
end If

dim rs, btns, evf, obj, hsmx
set btns = bill.cmdbuttons
set rs = cn.execute("select complete,status from M_ManuOrders where id=" & bill.sheetno)
if not rs.eof then
    evf = (rs.fields(0).value=0)
    btns.items(2).visible=evf
    btns.items(3).visible=evf
    btns.items(4).visible=evf
    btns.items(5).visible=evf
end if
rs.close

set v1 = bill.GMBD("SingleCosts")
set v2 = bill.GMBD("TotalCosts")
if app.power.ExistsPower(51,18) = false then
    v1.state = 5
    v2.state = 5
end if

if Bill.ReadOnly = false  then
   bill.GMBD("CompleteStatus").state=5
end If

hsmx = false
if sdk.Power.ExistsManu(3) and sdk.Power.ExistsModel(18200) then
   bill.GMBD("生产计划").state=2
   bill.GMBD("CreateFrom").defValue=0
   bill.GMBD("FromID").defValue= 0
   bill.GMBD("CreateFrom").state=5
   bill.GMBD("FromID").state=5
   set obj = bill.GMBD("生产计划单明细")
   obj.state=5
   obj.dtype = "text"
Else
   Set obj = bill.GMBD("生产订单明细")
   obj.Group = "物料分析"
   hsmx = True
end if 

If Len(request.querystring("__msgId") & "") = 0 And Len(request.form("__msgId") & "") = 0 And Len(request.form("ID")&"")=0 Then
	If cn.execute("select 1 from M_manuorders where ID=" & bill.sheetno).eof Then 
		cn.execute "delete M_ManuPlanLists  where MPSID  in ( select ID from M_ManuPlans where del=7 and Creator =" & app.Info.User & " and isnull(fromChild,0)>0 and fromChild not in (select ID from M_manuorders))"
		cn.execute "delete M_ManuPlans where isnull(fromChild,0)>0 and fromChild not in (select ID from M_manuorders) and del=7 and Creator=" & app.Info.User
	End if
End If

if Not sdk.Power.ExistsManu(3)  Then '没有生产计划
	If not cn.execute("select 1 from M_manuorders where ID=" & bill.sheetno).eof And Not cn.execute("select 1 from M_manuorderlists where MorderID=" & bill.sheetno).eof Then
	   bill.GMBD("CreateFrom").state = 2
	   bill.GMBD("FromID").state = 2
	   bill.GMBD("FromID").RefreshChild = False
	Else
	   bill.GMBD("FromID").isparentField = True
	   bill.GMBD("FromID").RefreshChild = true
	End If
End If

If InStr(1, Request.ServerVariables("url"), "/bill.asp", 1)>0 Then
   bill.GMBD("SingleCosts").state=5
   bill.GMBD("TotalCosts").state=5
end If

if sdk.Power.ExistsModel(14000) and app.power.CheckPower(25,13,bill.Creator) And app.power.ExistsPower(25,19)=False then bill.addButtonsExtra ="yugou;"
%>