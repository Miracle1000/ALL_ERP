function showHtml(ord, canDetail, title) {
    var htmlStr = title;
    if (canDetail == "1") {
        htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "sysa/product/content.asp?ord=" + app.pwurl(ord) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + title + "</a>";
    }
    return htmlStr;
}
function showFieldsColor(v, bType, ord) {
    var s = v;
    if (bType == "3" || bType == "7" || bType == "10" || bType == "13") {
        s = "<span style='color:red'>" + s + "</span>";
    }
    return s;
}

function showDetailByColumn(v, ord, canDetail, type) {
    var htmlStr = v;
    ord = Math.abs(ord)
    if (canDetail === "true" && v != "" && ord != "0") {
        var domain = "";
        var column = "";
        var page = "";
        var condition = "";
        if (type == "2" || type == "9") {
            //采购
            domain = "SYSN";
            column = "view/store/caigou";
            page = "CaigouDetails.ashx";
            condition = "ord=" + app.pwurl(ord) + "&view=details";
        } 
        else if (type == "4") {
            //整单委外
            ord = Math.abs(ord)
            domain = "SYSN";
            column = "view/produceV2/ProductionOutsource";
            page = "ProOutsourceAdd.ashx";
            condition = "ord=" + app.pwurl(ord) + "&view=details";
        }
        else if (type == "10") {
            //采购退款
            domain = "SYSN";
            column = "view/finan/payout";
            page = "payrefund.ashx";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        else if (type == "11" || type == "12"||type == "8") {
            //实际付款
            domain = "SYSN";
            column = "view/finan/payout";
            page = "payoutsuredetail.ashx";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        else if (type == "14") {
            //应付抵应收
            domain = "SYSN";
            column = "view/finan/payout";
            page = "payout.ashx";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        else if (type == "3" || type == "13") {
            //采购退货
            domain = "SYSA";
            column = "caigouth";
            page = "content.asp";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        else if (type == "5") {
            //工序委外
            ord = Math.abs(ord)
            domain = "SYSN";
            column = "view/produceV2/OutProcedure";
            page = "AddOutProcedure.ashx";
            condition = "ord=" + app.pwurl(ord) + "&view=details";
        }
        else if (type == "6") {
            //预付款
            domain = "SYSN";
            column = "view/finan/payout/payoutpre";
            page = "AdvanceCharge.ashx";
            condition = "ord=" + app.pwurl(ord) + "&view=details";
        }
        else if (type == "7") {
            //退预付款
            domain = "SYSA";
            column = "money2";
            page = "contentbackyfk.asp";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        if (domain != "" && column != "" && page != "" && condition != "") {
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "" + domain + "/" + column + "/" + page + "?" + condition + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
    }

    return htmlStr;
}

function modelPrint() {
    window.open('../../comm/TemplatePreview.ashx?sort=75&ord=0&isreport=true', '', 'scrollbars = 1, resizable = 1, width = 1100, height = 500, top = 200, left = 200');
}