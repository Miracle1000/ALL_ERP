window.onReportExtraHandle = function(btnText , values , pword , canAddNotice){
	switch(btnText){
		case "指派" :
			window.open('order.asp?selectid='+values,'newwin','width=' + 900 + ',height=' + 520 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150');
			break;
		case "批量指派" :
			//if (window.confirm("您确定要进行" + btnText + "吗？")==false) { return; }
			window.open('order.asp?selectid='+values.join(","),'newwin','width=' + 900 + ',height=' + 520 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150');
			break;
		case "共享" :
			window.open('share.asp?selectid='+values,'newwin','width=' + 900 + ',height=' + 520 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150');
			break;
		case "批量共享" :
			//if (window.confirm("您确定要进行" + btnText + "吗？")==false) { return; }
			window.open('share.asp?selectid='+values.join(","),'newwin','width=' + 900 + ',height=' + 520 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150');
			break;
		default :
			if (window.confirm("您确定要" + btnText + "吗？")==false) { return; }
			ajax.regEvent("__doBatHandle")
			ajax.addParam("command", btnText);
			ajax.addParam("checkvalues", values.join(","));
			ajax.exec();
			if (btnText=="删除" && canAddNotice==1){
				window.open('../notice/add.asp?datatype=-31&fromid='+pword,'newwinAddNotice','width=' + 1200 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
			}	
	}
}

function delDesign(ord, pword ,canAddNotice){
	var values = new Array();
	values[0] = ord;
	window.onReportExtraHandle("删除",values ,pword , canAddNotice);
}

function setDesignShare(ord){
	window.onReportExtraHandle("共享",ord);
}

function setDesignAppoint(ord){
	window.onReportExtraHandle("指派",ord);
}

function setDesignBack(ord){
	var values = new Array();
	values[0] = ord;
	window.onReportExtraHandle("收回",values);
}

function setDesigner(ord){
	ajax.regEvent("doApply")
	ajax.addParam("command", "申请");
	ajax.addParam("ord", ord);
	ajax.exec();
	window.DoRefresh();
}

function setDesignerSp(ord,stype){
	ajax.regEvent("doDesignerSp")
	ajax.addParam("command", "同意或否决");
	ajax.addParam("stype", stype);
	ajax.addParam("ord", ord);
	ajax.exec();
	window.DoRefresh();
}

function setAbandon(ord){
	app.easyui.CAjaxWindow("setAbandon",function(){
		ajax.addParam2("ord",ord);
	});
}
function saveAbandon(ord){
	var reson = $("#reson").val();
	ajax.regEvent("__doBatHandle")
	ajax.addParam("command", "放弃");
	ajax.addParam("checkvalues", ord);
	ajax.addParam("reson", reson);
	ajax.exec();
	app.easyui.closeWindow("setAbandon");
	window.DoRefresh();
}

function setSpProc(ord , sptype , designer , isback){
	spclient.GetNextSP('Design',ord,0,sptype,designer,isback ,document.body);
}

window.spclient.onProcComplete=function(ord, spid ,spuser , obj){
	ajax.regEvent("doSpHandle")
	ajax.addParam("id", ord);
	ajax.addParam("@__sp_level_id", spid);
	ajax.addParam("@__sp_cateid", spuser);
	ajax.exec();
	window.DoRefresh();
}



window.onReportRefresh=function(){
	var strh=$ID("commfieldsBox").getAttribute("connHTML");
	if (strh!=null && strh!="")
	{
		$("#searchitemsbutton2").click();
	}
}