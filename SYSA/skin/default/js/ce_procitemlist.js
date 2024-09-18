function InitRunLog(logid) {
	if (window.confirm("确定启动此工作？"))
	{
		ajax.regEvent("InitLog");
		ajax.addParam("logid", logid);
		ajax.send();
		if($ID("lvw_tablebg_mlistvw")) {
			lvw_refresh("mlistvw");
		}
		else{
			window.location.reload();
		}
	}
}

function doRunLog(id) {
	window.open("ChanceitemExecPage.asp?ord=" + id, "citemexec","width=1100,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=50");
}

function ChangeRunLog(id, parentok) {
	window.open("ChanceitemChangePage.asp?parentok=" +  parentok + "&ord=" + id, "citemexec","width=1100,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=50");
}

function doSpLog(id) {
	window.open("ChanceitemReviewPage.asp?ord=" + id, "citemexec","width=1000,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=100");
}

function ReadLogPage(id) {
	window.open("ChanceLogPage.asp?ord=" + id, "citemexec","width=1100,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=100");
}

function DelRunLog(logid) {
	if (window.confirm("确定删除此工作？"))
	{
		ajax.regEvent("DelLog");
		ajax.addParam("logid", logid);
		ajax.send();
		if($ID("lvw_tablebg_mlistvw")) {
			lvw_refresh("mlistvw");
		}
		else{
			window.location.reload();
		}
	}
}


window.onReportRefresh=function(){
	var strh=$ID("commfieldsBox").getAttribute("connHTML");
	if (strh!=null && strh!="")
	{
		$("#searchitemsbutton2").click();
	}
}