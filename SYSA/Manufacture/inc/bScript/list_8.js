function machineExport() {
	var div = document.getElementById("listview_spmain");
	var t = new Date()
	var form = document.getElementById("lvw_excel_sendform_mc") 
	if (!form)
	{
		form =  document.createElement("form");
		form.method = "post"
		form.target = ""
		form.action = "../../out/xls_WA_MachineList.asp";
		form.id = "lvw_excel_sendform_mc"
		form.style.cssText = "display:inline"
		form.innerHTML = "<input type='hidden' name='__msgId' value='sys_ListView_CreateExcel'>"
						 + "<input type='hidden' id='lvw_excel_State'  name='State' value='" + div.state + "'>"
						 + "<input type='hidden' name='sendtime' value='" + t.getTime() + "'>"
		document.body.appendChild(form);
	}
	else{
		document.getElementById("lvw_excel_State").value = div.state;
	}
	form.submit();
}