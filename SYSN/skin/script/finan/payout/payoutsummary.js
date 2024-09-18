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
            domain = "SYSA";
            column = "caigou";
            page = "content.asp";
            condition = "ord=" + app.pwurl(ord) + "";
        } else if (type == "8") {
            //付款计划
            domain = "SYSN";
            column = "view/finan/payout";
            page = "contentOut.ashx";
            condition = "ord=" + app.pwurl(ord) + "";
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
            //整单委外
            domain = "SYSA";
            column = "money4";
            page = "payback.asp";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        else if (type == "11" || type == "12") {
            //实际付款
            domain = "SYSN";
            column = "view/finan/payout";
            page = "payoutsuredetail.ashx";
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