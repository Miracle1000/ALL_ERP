function ShowKuInfomation(box, typ) {
	var td = box.parentNode;
	while(td && (td.tagName!="TD" || (td.className.indexOf("lvw_cell")==-1 && td.className.indexOf("lvw_index")==-1) ) ) {
		td = td.parentNode;
	}
	if(!td) {return;}
	var tr = td.parentNode;
	var tb = tr.parentNode.parentNode;
	var lvwid = tb.id.replace("lvw_dbtable","lvw_JsonData");
	var jlvw = window[lvwid];
	var pos = tr.getAttribute("pos");
 	var productn =  box.getAttribute("productn");
	var unitn =  box.getAttribute("unitn");
	var pindex = app.GetItemByDBName(jlvw.headers, productn).i;
	var uindex = app.GetItemByDBName(jlvw.headers, unitn).i;
	app.ajax.regStaticSub("ZBServices.view.SYSN.mdl.store.KuInfomation.GetKuInfoMessage");
	app.ajax.addParam("product",  jlvw.rows[pos*1][pindex]);
	var un = jlvw.rows[pos*1][uindex];
	if (app.isObject(un))
	{
		un = un.fieldvalue;
	}
	app.ajax.addParam("unit", un);
	var r = app.ajax.send();
	var dlvw = eval("(" + r + ")");
	var flvw = ListView.Create("kuinfomsglvw", dlvw);
	var kuhtml = "<div style='background-color:white;border-radius: 8px;overflow:hidden'>"
						+ "<div class='lvwtooldiv' style='height:26px;line-height:24px;padding:0px 5px;font-weight:bold;border:0px;border-bottom:1px solid #c0ccdc'>库存信息(" + dlvw.ui.tag + ")</div>" 
						+ "<div style='padding:4px'>" +  flvw.GetHtml() + "</div></div>";
	 app.createFloatDiv("kuinfomsgdiv",{bindobj:box,width:560, html:kuhtml});
}