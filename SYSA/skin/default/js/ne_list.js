window.__ShowImgBigToSmall= true

window.onReportExtraHandle = function(btnText , values){
	if (window.confirm("您确定要" + btnText + "吗？")==false) { return; }
	ajax.regEvent("__doBatHandle")
	ajax.addParam("command", btnText);
	ajax.addParam("checkvalues", values.join(","));
	ajax.exec();
}

function delNotice(ord){
	var values = new Array();
	values[0] = ord;
	window.onReportExtraHandle("删除",values);
}


