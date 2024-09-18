function showHtml(ord, canDetail, title) {
    var htmlStr = title;
    if (canDetail == "_url") {
        htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "sysa/product/content.asp?ord=" + app.pwurl(ord) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + title + "</a>";
    }
    return htmlStr;
}

function modelPrint() {
    window.open('../../comm/TemplatePreview.ashx?sort=75&ord=0&isreport=true', '', 'scrollbars = 1, resizable = 1, width = 1100, height = 500, top = 200, left = 200');
}

function HandleCustomResult() {
    if ($("#reportintro").size() == 0) { $("#maingrid").after("<div id='reportintro'>&nbsp;※：日期范围内不包含全部关联单据。</div>"); }
}

function showDetailByColumn(v, ord, canDetail, type) {
    var htmlStr = v;
    if (canDetail === "true" && v != "" && ord != "0" ) {
        var domain = "";
        var column = "";
        var page = "";
        var condition = "";
        if (type == "1") {
            //采购
            return "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSN/view/store/caigou/CaigouDetails.ashx?view=details&ord=" + app.pwurl(ord) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        } else if (type == "2" || type == "8") {
            //付款计划
            domain = "SYSN";
            column = "view/finan/payout";
            page = "payout.ashx";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        else if (type == "3") {
            //实际付款
            domain = "SYSN";
            column = "view/finan/payout";
            page = "payoutsuredetail.ashx";
            condition = "view=details&ord=" + app.pwurl(ord) + "";
        }
        else if (type == "4") {
            //采购退货
            domain = "SYSA";
            column = "caigouth";
            page = "content.asp";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        else if (type == "5") {
            //采购退款,退款转预付款
            domain = "SYSN";
            column = "view/finan/payout";
            page = "PayRefund.ashx";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        else if (type == "6") {
            //预付款
            domain = "SYSA";
            column = "money2";
            page = "contentyfk.asp";
            condition = "ord=" + app.pwurl(ord) + "";
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