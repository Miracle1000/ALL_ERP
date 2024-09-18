document.write("<" + "style" + ">");
document.write("tr.lvwnullrow {display:none}");
document.write("<" + "/style" + ">");
$(function () {
	$(document).bind("mousedown", function (e) {
		var obj = e.target;
		if (obj && (obj.className + "").indexOf("autocompleteico")>=0 ) {
			var tr = $(obj).parents("tr[pos]")[0];
			if (tr) {
				var tb = tr.parentNode.parentNode;
				var lvwid = tb.id.replace("lvw_dbtable_", "");
				var jlvw = window["lvw_JsonData_" + lvwid];
				var rowindex = tr.getAttribute("pos") * 1;
				var cells = jlvw.rows[rowindex * 1];
				if (rowindex < jlvw.rows.length - 1) {
					for (var i = 0 ; i < jlvw.headers.length; i++) {
						var h = jlvw.headers[i];
						if (h.dbname.indexOf("@") == -1) {
							h.defvalue = cells[i];
						}
					}
				}
			}
		}
	});
});

//捕获listview属性
window.listviewAttrsHook = function (lvw, value,  attrname,  tag) {
	switch (attrname) {
		case "caninsert":
		case "canadd":
			if (tag == "createnullrow") { return true;}
			return false;
		default:
			return value;
	}
}
