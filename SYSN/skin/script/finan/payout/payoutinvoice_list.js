function openBeginInvoice() {  
    app.OpenUrl(window.SysConfig.VirPath + "sysa/money2/begin_invoice.asp");
}

function invoiceAdd(v, fromType, ord, canAdd) {
    var htmlStr = v;
    if (canAdd == "_url") {
        htmlStr += " <img src='" + window.SysConfig.VirPath + "sysa/images/jiantou.gif'><a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "sysn/view/finan/InvoiceManage/ReceiptInvoicePlan/ReceiptInvoicePlanAdd.ashx?fromtype=" + fromType + "&fromid=" + app.pwurl(ord) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">生成收票计划</a>";
    }
    return htmlStr;
}

function showGysInfo(v, company, canGysDetail,sort3) {
    var htmlStr = v;
    if (canGysDetail == "_url") {
        if (sort3=="2") {
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "sysa/work2/content.asp?ord=" + app.pwurl(company) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
        else {//跳转至客户详情页面
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "sysa/work/content.asp?ord=" + app.pwurl(company) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        } 
    }
    return htmlStr;
}

function showBillInfo(v, fromType, fromId, canBillDetail) {
    var htmlStr = v;
    if (canBillDetail == "_url") {
        var url = "";
        switch (fromType) {
            case "WWFK":
                url = window.SysConfig.VirPath + "sysa/manufacture/inc/Readbill.asp?orderid=25&ID=" + fromId + "&SplogId=0";
                break;
            case "ZDWW":
                url = window.SysConfig.VirPath + "sysn/view/produceV2/ProductionOutsource/ProOutsourceAdd.ashx?ord=" + app.pwurl(fromId) + "&view=details";
                break;
            case "GXWW":
                url = window.SysConfig.VirPath + "sysn/view/produceV2/OutProcedure/AddOutProcedure.ashx?ord=" + app.pwurl(fromId) + "&view=details";
                break;
            case "CAIGOU":
                url = window.SysConfig.VirPath + "SYSN/view/store/caigou/caigoudetails.ashx?ord=" + app.pwurl(fromId)+"&view=details";
                break;
            case "CAIGOUTH":
                url = window.SysConfig.VirPath + "SYSN/view/store/caigouth/PurchaseReturn.ashx?ord=" + app.pwurl(fromId) + "&view=details";
                break;
            case "PREOUT":
                url = window.SysConfig.VirPath + "sysa/money2/contentyfk.asp?ord=" + app.pwurl(fromId);
                break;
        }
        if (url.length>0) {
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('"+ url + "','newwin','width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
    }
    return htmlStr;
}

function showMoneyInfo(v, bzcode) {
    return bzcode + " " + v;
}

function showInvoiceInfo(v,isInvoiced, id, canInvoice) {
    var htmlStr = (v =="undefined"? "":v);
    if (isInvoiced=="0" && canInvoice=="_url"){
        htmlStr += " <img src='" + window.SysConfig.VirPath + "sysa/images/jiantou.gif'><a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "sysn/view/finan/InvoiceManage/ReceivedInvoice/ReceivedInvoiceApply.ashx?ids=" + app.pwurl(id) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">申请收票</a>";
    }
    return htmlStr;
}

function showBtnHtml(id, canDetail, canUpdate, canDel, remind) {
    var htmlStr = "";
    if (remind == 212) { htmlStr += "<img src='"+ window.SysConfig.VirPath +"sysa/images/alt3.gif' style='cursor:pointer;' onclick='remidCancel("+ id +")' alt='取消提醒' border='0'>";}
    if (canDetail == "_url") { htmlStr += "<button onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "sysn/view/finan/InvoiceManage/ReceiptInvoicePlan/ReceiptInvoicePlanDetail.ashx?ord=" + app.pwurl(id) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">详情</button>"; }
    if (canUpdate == "_url") { htmlStr += "<button onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "sysn/view/finan/InvoiceManage/ReceiptInvoicePlan/ReceiptInvoicePlanAdd.ashx?ord=" + app.pwurl(id) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">修改</button>"; }
    if (canDel == "_url") { htmlStr += "<button onclick=\"deleteInvoice(" + id + ")\">删除</button> "; }
    return htmlStr;
}

function remidCancel(id) {
    if (!confirm('确定要取消该提醒吗？')) {return;}
    app.ajax.regEvent("RemiderCancel");
    app.ajax.addParam("ID", id);
    app.ajax.send();
    Report.Refresh();
}

function allInvoice(rowsID) {
    //var rowsID = Report.GetCheckedRows();
    if (rowsID.length > 0) {
        app.OpenUrl("invoice_hb.ashx?ids=" + rowsID);
    }
    else {
        alert("您没有选择任何信息，请选择后再收票！");
    }
}

function deleteInvoice(id) {
    if (confirm("确认删除吗？")) {
        app.ajax.regEvent("Delete");
        app.ajax.addParam("ID", id);
        app.ajax.send();
        Report.Refresh();
    }
}

function deleteAllInvoice(rowsID) {
   // var rowsID = Report.GetCheckedRows();
    if (rowsID.length > 0) {
		var arrIds = new Array();
		app.ajax.regEvent("Delete");
		app.ajax.addParam("ID", rowsID);
		app.ajax.send();
		Report.Refresh();
    }
    else {
        alert("您没有选择任何信息，请选择后再删除！");
    }
}

function DoRefresh(){
	Report.Refresh();
}