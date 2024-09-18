function paybackProgress(Ord, ContractID, Complete, CanPayback, PaybackPower, IsCompanyNoDel, ShowTc, CanTc, CanelTc) {
    var str = "";
    if (Complete == 1) {
        str += "未收款";
        if (CanPayback == 1 && PaybackPower == 1 && IsCompanyNoDel > 0) {
            str += "<img src='" + window.SysConfig.VirPath + "SYSA/images/jiantou.gif'>" + app.CLinkHtml('收款', '/SYSN/view/finan/payback/PayBackSure.ashx?paybackid=' + app.pwurl(Ord), 1, 1);
        }
    }
    else if (Complete == 2) {
        str += "底单"
    }
    else if (Complete == 3) {
        str += "收款<img src='" + window.SysConfig.VirPath + "/SYSA/images/ok.gif'>";
    }
    if (ShowTc == 1) {
        if (CanTc == 1) {
            str += "<img src='" + window.SysConfig.VirPath + "SYSA/images/jiantou.gif'><a href='" + window.SysConfig.VirPath + "SYSA/money/tc_contract.asp?ord=" + Ord + "&rd=" + ContractID + "' onclick='return confirm(\"确认提成？\")'><font class='blue2'>提成</font></a>";
        }
        else if (CanelTc == 1) {
            str += "提成<img src='" + window.SysConfig.VirPath + "/SYSA/images/ok.gif'> <img src='" + window.SysConfig.VirPath + "SYSA/images/jiantou.gif'><a href='" + window.SysConfig.VirPath + "SYSA/money/tc_contract_cancel.asp?ord=" + Ord + "&rd=" + ContractID + "' onclick='return confirm(\"确认取消吗？\")'><font class='blue2'>取消提成</font></a>";
        }
    }
    return str;
}

function paybackinvoiceProgress(id, isInvoiced, redJoinid, canKP, isInvoiceTH, isNoInvoiceTH, mc23004) {
    var str = "";
    switch (isInvoiced) {
        case "0":
            str = "未开票"; break;
        case "11":
            str = "已申请未开票"; break;
        case "1":
            str = "已申请已开票"; break;
        case "2":
            str = "预收款开票"; break;
        case "3":
            if (mc23004) {
                str = "已申请已作废"; break;
            } else {
                str = "已申请已废止"; break;
            }
    }
    if (redJoinid != "0") {
        str += "<font color='red'>(红冲)</font>";
    }
    if (canKP == "1") {
        if (isNoInvoiceTH == "1") {
            str += "<img src='" + window.SysConfig.VirPath + "SYSA/images/jiantou.gif'>" + app.CLinkHtml('开票', '/SYSN/view/finan/InvoiceManage/MakeOutInvoice/InvoiceApply.ashx?ids=' + app.pwurl(id), 1, 1);
        } else {
            if (isInvoiceTH != "0") {
                str += "含整单优惠";
            } else {
                str += "含退货";
            }
        }
    }
    return str;
}

function cancelCustomer(contractId, customerId) {
    $(function () {
        $.post(window.SysConfig.VirPath + "SYSA/contract/HandleCustomer.asp", { action: "cancel", contractID: contractId, customrID: customerId }, function (data) {
            if (data == '1') {
                window.location.reload();
            } else {
                alert('取消关联客户失败！');
                window.location.reload();
            }
        });

    });
}

function ajaxBillDelete(billtype, billord) {
    if (confirm('确定要删除吗？')) {
        var url = window.SysConfig.VirPath;
        switch (billtype) {
            case "kuout":
                url += "SYSN/view/sales/contract/ContractDetails.ashx?__msgid=ExecDelete&fromPage=ajax&delType=" + billtype + "&ord=" + billord;
                break;
            case "payback":
                url += "SYSN/view/sales/contract/ContractDetails.ashx?__msgid=ExecDelete&fromPage=ajax&delType=" + billtype + "&ord=" + billord;
                break;
            case "paybackInvoice":
                url += "SYSN/view/sales/contract/ContractDetails.ashx?__msgid=ExecDelete&fromPage=ajax&delType=" + billtype + "&ord=" + billord;
                break;
            case "payout2":
                url += "SYSN/view/sales/contract/ContractDetails.ashx?__msgid=ExecDelete&fromPage=ajax&delType=" + billtype + "&ord=" + billord;
                break;
        }
        $.ajax({
            url: url,
            success: function (r) {
                if (r == "1") {
                    window.location.reload();
                } else {
                    alert("删除失败！" + r);
                }
            }
        });

    }
}

function xmldata1(ord) {
    var left = parseInt(event.clientX) - 30;
    var top = event.clientY + 2; //鼠标的y坐标
    var htmlleft = document.body.offsetWidth; //所打开当前网页，办公区域的高度，网页的高度
    if (htmlleft - event.clientX < 924) {
        left = htmlleft - 924;
    }
    var htmlheight = document.body.offsetHeight; //所打开当前网页，办公区域的高度，网页的高度
    var scrollheight = window.screen.availHeight;//整个windows窗体的高度
    if (htmlheight - event.clientY < 200) {
        top = top - 20 * (4 - parseInt((htmlheight - event.clientY) / 100));
    }
    try { app.closeWindow('sys_comm_open_dlg', true); } catch (e) { }
    var url = window.SysConfig.VirPath + "SYSN/view/sales/contract/ContractRoyaltyList.ashx?contractid=" + ord;
    app.OpenDlg(url, "top:" + top + ",left:" + left + ",width:900,closeButton:1,canMove:1");
}

Bill.showunderline = function (obj, c) { obj.style.textDecoration = "underline"; if (c) { obj.style.color = c } };
Bill.hideunderline = function (obj, c) { obj.style.textDecoration = "none"; if (c) { c = c.toLowerCase(); if (c == "blue" || c == "#0000ff") { c = "#2F496E"; } obj.style.color = c } };
var ck = {};
ck.SpShowList = function (OrId, BlId, logId, wName) { var t = new Date(); var opener = window.open(window.SysConfig.VirPath + "SYSA/manufacture/inc/Readbill.asp?orderid=" + OrId + "&ID=" + BlId + "&SplogId=" + logId + "&vTime=" + t.getTime()); }
