window.onReportExtraHandle = function(text , arrValue){
	if (text=="批量删除"){
		window.open('delcgconfirm.asp?fromtype=list&selectid='+arrValue.join(","),'newwin','width=' + 900 + ',height=' + 520 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150');
	}else{
		window.open('orderallhy.asp?selectid='+arrValue.join(","),'newwin','width=' + 900 + ',height=' + 520 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150');
	}
}

window.onReportRefresh=function(){
	var strh=$ID("commfieldsBox").getAttribute("connHTML");
	if (strh!=null && strh!=""){
		$("#searchitemsbutton2").click();
	}
}

window.__ShowImgBigToSmall = true ;

function setOldCaigouMxInvoiceType(){
	app.easyui.CAjaxWindow("setOldCaigouMxInvoiceType",function(){
		ajax.addParam2("status","0");
	});
}

function saveSetInvoiceType(){
	ajax.regEvent("saveSetInvoiceType");
	ajax.addParam("invoiceType",$('#invoiceType').children(':selected').val());
	ajax.addParam("taxRate",$('#taxRate').val());
	var r =ajax.send();
	app.Alert(r);
	app.easyui.closeWindow("setOldCaigouMxInvoiceType");
	$("#handleOldData").hide();
}