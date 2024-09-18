var OnInvoiceTitleClick = function (_company) {
    app.ajax.regEvent("ShowInvoiceTitles");
    app.ajax.addParam("company", _company);
    var result = app.ajax.send();

    var e = window.event;
    app.showServerPopo(e, "InvoiceTitlesDialog", eval("(" + result + ")"), 1, 400);
};
window.OnListViewFormualUpdateCell = function (lvw, rowindex, cellindex, newv) {
    if (lvw.headers[cellindex].dbname != "taxRate") { return; }
    window.onlvwUpdateCellValue(lvw, rowindex, cellindex, newv, 0, 0, 0);
}

window.onlvwUpdateCellValue = function (lvw, rowindex, cellindex, v, isztlr, isEof, disrefresh, oldvalue) {
    if (window.___Refreshinglvw == true) { return; }
    if (oldvalue == v) { return; }
    var header = lvw.headers[cellindex];
    var dbname = header.dbname;
    switch (dbname) {
        case "TaxValue"://税额
            ListView.EvalCellFormula(lvw, rowindex, "MoneyBeforeTax", "TaxMoney - TaxValue", false, 1);//金额
            window.ListView.RefreshCellUI(lvw, rowindex, "MoneyBeforeTax", 100);
            break;
        case "Price1"://未税单价
            ListView.EvalCellFormula(lvw, rowindex, "MoneyBeforeTax", "TaxMoney - TaxValue", false, 1);//金额
            window.ListView.RefreshCellUI(lvw, rowindex, "MoneyBeforeTax", 100);
            break;
        case "TaxPrice"://含税单价
            ListView.EvalCellFormula(lvw, rowindex, "TaxMoney", "TaxPrice * Num1", false, 1); //本位币收票总额
            ListView.EvalCellFormula(lvw, rowindex, "MoneyBeforeTax", "TaxPrice * Num1 / (1 + TaxRate * 0.01)", false, 1);//金额
            ListView.EvalCellFormula(lvw, rowindex, "TaxValue", "TaxPrice * Num1 - TaxPrice * Num1 / (1 + TaxRate * 0.01)", false, 1);//税额
            ListView.EvalCellFormula(lvw, rowindex, "Price1", "TaxPrice / (1 + TaxRate * 0.01)", false, 1);//未税单价
            ListView.EvalCellFormula(lvw, rowindex, "Money1", "TaxPrice / HL * Num1", false, 1);//本次收票总额
            window.ListView.RefreshCellUI(lvw, rowindex, "TaxMoney,MoneyBeforeTax,TaxValue,Price1,Money1", 100);
            break;
    }
    FormualLib.HandleFieldFormul(1, "Money1", { "lvw": lvw, "updateCols": "", "rowindex": rowindex, "cellindex": cellindex });
}
var closeDialog = function () {
    $("#InvoiceTitlesDialog .closeBtn").trigger("click")
}

var updateInvoiceTitleInfo = function (title, taxno, phone, addr, bank, bankAcc) {
    $("#InvoiceTitle_0").val(title);
    $("#InvoiceTaxno_0").val(taxno);
    $("#InvoicePhone_0").val(phone);
    $("#InvoiceAddr_0").val(addr);
    $("#InvoiceBank_0").val(bank);
    $("#InvoiceBankAcc_0").val(bankAcc);
}
window.RedInkPlansTik = 0;
var OnRedInkPlansBHChange = function () {
    if (window.tickHwnd > 0) { window.clearTimeout(window.RedInkPlansTik) }
    window.RedInkPlansTik = setTimeout(function () {
        var lvw = lvw_JsonData_RedInkPlansLvw;
        var inx = 2;
        for (var i = 0; i < lvw.headers.length; i++) {
            if (lvw.headers[i] == "Id") {
                inx = i;
                break;
            }
        }

        var Ids = "";
        for (var i = 0; i < lvw.rows.length; i++) {
            if (lvw.rows[i].length == 1)
                continue;

            Ids += lvw.rows[i][inx].toString() + ",";
        }
        if (Ids.length > 0) {
            Ids = Ids.substr(0, Ids.length - 1);
            Bill.CallBackParams("", "App_OnRedInkPlansBHChange", false, "App_OnRedInkPlansBHChange");
            app.ajax.addParam("ids", Ids);
            app.ajax.send();
        }
    }, 1000);
}
$(function () {
    //修改数量触发是否需要显示下次收票日期
    $(document).on("change", "input[uitype='numberbox']", function (e) {
        var invoiceModel = $("#InvoiceMode_0").val();
        if (invoiceModel != "2") {
            return;
        }
        var numcolindex = -1;
        var ynumcolindex = -1;
        var visible = 0;
        var lvw = window["lvw_JsonData_ApplyListDetails"];
        var headers = lvw.headers;
        for (var i = 0; i < headers.length; i++) {
            if (headers[i].dbname == "ynum1") {
                ynumcolindex = i;
            }
            if (headers[i].dbname == "Num1") {
                numcolindex = i;
            }
        }
        for (var j = 0; j < lvw.rows.length; j++) {
            if (lvw.rows[j][numcolindex] < lvw.rows[j][ynumcolindex]) {
                visible = 1;
            }
        }
        Bill.CallBackParams("", "App_OnSetSurplusVisible", false, "App_OnSetSurplusVisible");
        app.ajax.addParam("visible", visible);
        app.ajax.send();
    });
    window.PlusTimer = 0
    //修改计划收票总额触发是否显示下次收票日期
    $(document).on("change", "input[uitype$='moneybox']", function (e) {
        clearInterval(PlusTimer)
        PlusTimer = setInterval(function () {
            var visible = 0;
            var invoiceModel = $("#InvoiceMode_0").val();
            //汇总收票用钱判断
            if (invoiceModel == "1") {
                var surplusMoney = $("#surplusMoney1_0").val();
                if (isNaN(surplusMoney)) {
                    return;
                }
                else {
                    visible = surplusMoney > 0 ? 1 : 0;
                }
            }
                //明细收票用数量判断
            else if (invoiceModel == "2") {
                var numcolindex = -1;
                var ynumcolindex = -1;
                var visible = 0;
                var lvw = window["lvw_JsonData_ApplyListDetails"];
                var headers = lvw.headers;
                for (var i = 0; i < headers.length; i++) {
                    if (headers[i].dbname == "ynum1") {
                        ynumcolindex = i;
                    }
                    if (headers[i].dbname == "Num1") {
                        numcolindex = i;
                    }
                }
                for (var j = 0; j < lvw.rows.length; j++) {
                    if (lvw.rows[j][numcolindex] < lvw.rows[j][ynumcolindex]) {
                        visible = 1;
                    }
                }
                if (visible == 0 && e.target.id == "Money1_0") {
                    var surplusMoney = $("#surplusMoney1_0").val();
                    if (isNaN(surplusMoney)) {
                        return;
                    }
                    else {
                        visible = surplusMoney > 0 ? 1 : 0;
                    }
                }
            }
            if (visible) { $("tr[dbname='surplusGroup']").removeClass("hiderow").css("display", "") } else { $("tr[dbname='surplusGroup']").removeClass("hiderow").css("display", "none") }
        }, 200)
        //Bill.CallBackParams("", "App_OnSetSurplusVisible", false, "App_OnSetSurplusVisible");
        //app.ajax.addParam("visible", visible);
        //app.ajax.send();
    });

    window.onListViewRowAfterDelete = function () {
        setTimeout(function () {
            Bill.CallBackParams("", "App_OnSetSurplusVisible", false, "App_OnSetSurplusVisible");
            app.ajax.addParam("visible", 1);
            app.ajax.send();
        }, 100);
    }
});

function DownLoadRedInvoiceInfo() {

    app.OpenServerFloatDialog("LoadDownLoadRedInvoice", { width: 400, height: 200 }, "", 1);
}

function ResendInvoiceInfo() {

    app.OpenServerFloatDialog("ResendInvoiceInfo", { width: 400, height: 200 }, "", 1);
}


function CancleClick() {
    app.closeWindow('fldiv_LoadDownLoadRedInvoice', true);
    app.closeWindow('fldiv_ResendInvoiceInfo', true);
}

function SureDownload() {
    app.ajax.regEvent('SureDownload');
    app.ajax.send();
    Report.Refresh();
}

Bill.cmdButtonClick = function (btn, cmdKey, verfi, cmdtag, buttonjson) {
    cmdKey = cmdKey.replace(/\#\*\^\*0010\#\(\*/g, "\\");
    cmdKey = cmdKey.replace(/\#\*\^\*0020\#\(\*/g, "\"");
    cmdKey = cmdKey.replace(/\#\*\^\*0030\#\(\*/g, "\'");
    switch (cmdKey) {
        case "bill.modifyapprove":
            var billid = Bill.Data.ord;
            app.ShowApproveModify(billid);
            break;
        case "bill.updateapprove":
            var billid = Bill.Data.ord;
            app.ShowApproveMessage(billid, "单据改批", cmdtag)
            break;
        case "bill.approve":
            var billid = Bill.Data.ord;
            app.ShowApproveMessage(billid, "", cmdtag)
            break;
        case "bill.change":
            var href = window.location.href;
            app.OpenUrl(Bill.ReplaceUrl(href, "view=details", "view=change"));
            break;
        case "bill.increase":
            Bill.DoSave(cmdtag, buttonjson);
            break;
        case "bill.dotempsave":
            Bill.DoSaveSub(cmdtag, "SysBillTempSave");
            break;
        case "bill.Import":
            Bill.Import(cmdtag);
            break;
        case "bill.dosave":
            if (Bill.Data.uistate == "change") { cmdtag = "__cmd_change"; }
            Bill.DoSave(cmdtag, buttonjson);
            break;
        case "bill.reset":
            if (Bill.onReset) { Bill.onReset(); return; }
            setTimeout(function () { window.location.reload() }, 10);
            break;
        case "bill.doupdate":
            var updateurl = Bill.Data.signurlinfo.modifyurl;
            var href = updateurl ? (updateurl + (updateurl.indexOf("?") > 0 ? "&" : "?") + "ord=" + app.pwurl(Bill.Data.ord)) : window.location.href;
            app.OpenUrl(Bill.ReplaceUrl(href, "view=details"));
            break;
        case "bill.docopy":
            if (Bill.Data.uistate == "add" || Bill.Data.uistate == "modify" || Bill.Data.uistate == "copy") {
                Bill.DoSave("__cmd_copy", buttonjson);
                return;
            }
            if (Bill.Data.uistate == "details") { Bill.ShowCopyPage(); }
            break;
        case "bill.callback":
            Bill.CallBack(btn.innerText, btn.getAttribute("dbname"), verfi, cmdtag, btn.getAttribute("servercbkasync") * 1);
            break;
        case "bill.dodelete":
            Bill.DoDelete(cmdtag);
            break;
        case "bill.fullScreen":
            Bill.fullScreen(btn);
            break;
        case "bill.doexport":
            Bill.DoExport(btn);
            break;
        default:
            eval(cmdKey);
    }
};

function OpenInvoiceAbutment() {
    window.location.href = window.SysConfig.VirPath+"SYSN/view/finan/InvoiceManage/HtmlView/OpenInvoiceAbutment.html";
}

function showFunctionButton(title, id,predinfo,vector,blueinvoicing, status, invoiceManual, invoiceAbutment, needsignature) {
    var htmlStr = "<table style='border:0;*display: inline;display:inline-block;vertical-align:middle'><tr><td rowspan='2'>" + title+"</td>";
    if (status == 11||status==4) {//已申请未开票
        if (invoiceManual > 0) {
            var makeoutTxt = "开票";
            if (invoiceManual == 2) makeoutTxt = "手工开票";
            if (vector == 1) {
                htmlStr += AddFunctionTd("SYSN/view/finan/InvoiceManage/MakeOutInvoice/InvoiceConfirm.ashx?suretype=0&ord=" + app.pwurl(id), makeoutTxt);
            }
            else {
                htmlStr += AddFunctionTd("SYSN/view/finan/InvoiceManage/MakeOutInvoice/RedInkInvoiceOffset.ashx?suretype=0&suresave=1&ord=" + app.pwurl(id), makeoutTxt);
            }
            if (invoiceAbutment > 0 && (vector == 1 || blueinvoicing == 1)) {
                var invoiceTxt = "对接开票";
                var retry = 0;
                if (status == 4) {
                    invoiceTxt = "再次开票";
                    retry = 1;
                }
                if (vector == 1) {
                    htmlStr += "<tr>" + AddFunctionTd("SYSN/view/finan/InvoiceManage/MakeOutInvoice/InvoiceConfirm.ashx?suretype=1&retry=" + retry + "&ord=" + app.pwurl(id), invoiceTxt);
                }
                else if (predinfo == 0) {
                    htmlStr += AddFunctionTd("SYSN/view/finan/InvoiceManage/MakeOutInvoice/RedInkInvoiceOffset.ashx?suretype=1&suresave=1&retry=" + retry + "&ord=" + app.pwurl(id), invoiceTxt);
                }
               
            }
        }
    }
    else if (status == 1) {//已开票
        if (needsignature > 0) {
            htmlStr += AddButtonTd(id, "签章", "SendSignature");
        }
    }
    else if (status == 5) {//开票中，需要获取状态
        htmlStr += AddButtonTd(id, "获取状态", "GetInvoiceStatus");
    }
    htmlStr += "</table>";
    return htmlStr;
}

function OnHrefLinkUrl(url, title) {
    var htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:app.OpenUrl('";
    htmlStr += window.SysConfig.VirPath;
    htmlStr += url;
    htmlStr += "')\">" + title + "</a>";
    return htmlStr
}

function AddFunctionTd(url, title) {
    var htmlStr = "<td style='text-align:left;min-width:60px;'><img src='" + window.SysConfig.VirPath + "sysa/images/jiantou.gif'>";
    htmlStr += OnHrefLinkUrl(url, title);
    htmlStr += "</td></tr>";
    return htmlStr
}

function AddButtonTd(id,title,funname ) {
    var htmlStr = "<td style='text-align:left;min-width:60px;'><img src='" + window.SysConfig.VirPath + "sysa/images/jiantou.gif'>";
    htmlStr += "<a href = 'javascript:void(0);' onclick = 'BtnClickFunction(" + id + ",\""+funname+"\")' >" + title + " </a>";
    htmlStr += "</td></tr>";
    return htmlStr
}

function BtnClickFunction(id, funname) {
    app.ajax.regEvent(funname);
    app.ajax.addParam('id', id);
    app.ajax.send();
    Report.Refresh();
}

window.getLenByOtherCalculaMethod = function (obj) {
    var l=0;
    if (obj.name == "InfoNotes") {
        var i;
        var objvalue = obj.value;
        var length = objvalue.length;
        for (i = 0; i < length; i++) {
            if ((objvalue.charCodeAt(i) >= 0) && (objvalue.charCodeAt(i) <= 255)) {
                l = l + 1;
            } else {
                l = l + 2;
            }
        }
    }
    else {
        l = (obj.tagName == "INPUT" ? obj.value.trim().length : obj.value.replace(/\n/g, "a").replace(/(\s*$)/g, "").length);        
    }
    if (l == 0) { $("#systextlengthlayer").remove(); return; }
    return l;
}