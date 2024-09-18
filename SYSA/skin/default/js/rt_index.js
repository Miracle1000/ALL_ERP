
function cNumLink(td) {
	ajax.regEvent("cNumberLink");
	var cell = td.parentNode.parentNode.parentNode.parentNode.parentNode;
	var tr = cell.parentNode;
	var spans = tr.getElementsByTagName("span");
	var rowv = new Array();
	for (var i = 0; i<spans.length ; i ++)
	{
		var span = spans[i];
		if(span.className=="hidekeyv") {
			rowv[rowv.length] = span.getAttribute("value");
		}
	}
	
	var cindex = cell.cellIndex*1 + 1
	var header = null;
	var tb = document.getElementById("lvw_dbtable_mlistvw");
	var maxheaders = tb.getAttribute("maxheads");
	for (var i = 0; i <  maxheaders*1; i ++ )
	{
		var tr = tb.rows[i];
		for (var ii = 0 ; ii < tr.cells.length; ii++)
		{
			var td = tr.cells[ii];
			if(td.getAttribute("cindex") && td.getAttribute("cindex") ==cindex) {
				header = td;
			}
		}
	}
	if(header) {
		td =  header.children[0].rows[0].cells[1];
		var dbnm = td.getAttribute("dbname");
		var dbs = dbnm.split("#X#");
		var colv = dbs[1] ? dbs[1] : "";
		ajax.addParam("ReportId", app.getUrlItem("ID"))
		ajax.addParam("rowvalue", rowv.join(","));
		ajax.addParam("colvalue", colv);
		ajax.addParam("exitords", document.getElementById("ExitOrds").value);
		LoadSearchAttrs(ajax);
		var r = ajax.send();
		if (r.length > 0)
		{
			app.msgbox("链接过程出现错误", "<div>" + r + "</div>");
			return;
		}
		//此处暂时不区分ID，下一步扩展按ID不同进行不同的跳转
		var op = window.open("../work/telhy.asp?H=1011","reportlinktel" , "width=1000,height=500,fullscreen=no,scrollbars=1,toolbar=0, status=no,resizable=1,location=no,menubar=no,menubar=no,left=200,top=100");
		op.focus();
	}
}

function showgrouperrSql(id) {
	if(window.location.href.indexOf("//127.0.0.1")>0) {
		var div = app.createWindow("errgroupsql", "错误的统计SQL","");
		div.innerHTML = "<div style='padding:10px'><pre style='color:#000'>"  + document.getElementById("GroupErrSql" + id).value + "</pre></div>"
	}
}