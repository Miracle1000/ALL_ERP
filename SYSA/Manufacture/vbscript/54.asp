<%
if sdk.power.ExistsManu(4) = false then
   dim dbi : set dbi=bill.GMBD("订单编号")
   dbi.ywname = "生产订单"
   dbi.state=1
   dbi.selid = 1104
   Bill.GMBD("MOIListID").RefreshChild =0
   bill.GMBD("MOIListID").defvalue = 0
   bill.GMBD("WABH").colspan=1
   bill.GMBD("下达单主题").state=5
   bill.GMBD("ddlistid").RefreshChild = 1
   bill.GMBD("xldno").defvalue = 0
end if
Bill.addCPZdyUIFields  "DateEnd", "MOIListID|ddlistid",  True

if sdk.Power.ExistsModel(18520) and app.power.ExistsPower(5031,13) then bill.addButtonsExtra ="gxhb;"

If InStr(1, Request.ServerVariables("url"), "readbill.asp", 1)>0 Then
   bill.GMBD("title").colspan=2
   bill.GMBD("zt").state=1
   if sdk.Power.ExistsModel(18520) then 
      bill.GMBD("WABH").colspan=1
      bill.GMBD("txm1").state=1
      bill.GMBD("txm2").state=1
      bill.GMBD("生产进度").Group =  "生产进度"
      bill.GMBD("生产进度").state=1
      bill.GMBD("生产进度").dtype="detail"
   end if 
end if
%>