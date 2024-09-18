//主题链接
function showDetailByColumn(v, ord, canDetail, type) {
    var htmlStr = v;
    if (canDetail === "true" && v != "" && ord != "0") {
        var domain = "";
        var column = "";
        var page = "";
        var condition = "";
        if (type == "采购") {
            //合同
            domain = "SYSN";
            column = "view/store/caigou";
            page = "CaigouDetails.ashx";
            condition = "ord=" + app.pwurl(ord) + "&view=details";
        } else if (type == "退货") {
            //退货
            domain = "SYSN";
            column = "view/store/caigouth";
            page = "PurchaseReturn.ashx";
            condition = "&view=details&ord=" + app.pwurl(ord) + "";
        } 
        if (domain != "" && column != "" && page != "" && condition != "") {
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "" + domain + "/" + column + "/" + page + "?" + condition + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
    }
    return htmlStr;
}

//付款
function SkshowListByColumn(Skzt, paybacbalance, yh, Ml, CGid, type, ord, module_24001, module_25002, tkmoney, tkstatus) {
    var reg = new RegExp(",", "g");//g,表示全部替换。
    paybacbalance = parseFloat(paybacbalance.replace(reg, "")) == "0" ? "" : paybacbalance;
    Ml = parseFloat(Ml.replace(reg, "")) == "0" ? "" : Ml;
    if (tkmoney) tkmoney = parseFloat(tkmoney.replace(reg, "")) == "0" ? "" : tkmoney;
    if (paybacbalance != "") {
        paybacbalance = app.FormatNumber(paybacbalance.replace(reg, ""), "moneybox");
    }
    if (Ml != "") {
        Ml = app.FormatNumber(Ml.replace(reg, ""), "moneybox");
    }
    var htmlStr = "";
    if (type == "采购" && module_24001 == "1") {
        htmlStr = "<span>" + Skzt + "<br>";
        htmlStr += paybacbalance != "" ? "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSN/view/finan/payout/PayOutList.ashx?plans=666&stype=5&BH=" + CGid + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + paybacbalance + "</a>" : "";
        htmlStr += Ml != "" ? "<br>抹零：" + Ml : "";
        htmlStr += "</span>";

    } else if (type == "退货" && module_25002 == "1") {

        htmlStr = "" + Skzt + "<br>";
        htmlStr += paybacbalance != "" ? "<a style='color:red' href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/money4/planall2.asp?A=2&cgthord=" + app.pwurl(ord) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + paybacbalance + "</a>" : "";
    }
    if (module_25002 == "1" && module_24001 == "1" && tkstatus) {
        htmlStr += "<span style='color:red'>" + tkstatus + "：" + app.FormatNumber(tkmoney, "moneybox") + "<br>";
        htmlStr += "</span>";
    }
    return htmlStr;
}
function showColor(v, Type, contract, Ismode, CGORD) {
    var htmlStr = v;
    if (Ismode == "1") {
        if (Type == "退货") {
            htmlStr = "<span style='color:red'>" + v + "</span>"
        }
    }
    else {
        if (Type == "采购") {
            htmlStr = "<a  href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSN/view/sales/product/productPurchase.ashx?CGORD=" + CGORD + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>"
        } else {
        //预留
            //htmlStr = "<a style='color:red' href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/contractth/report_contractth_list.asp?CGORD=" + app.pwurl(CGORD) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>"

            //htmlStr = "<span style='color:red'>" + v + "</span>"
        }
    }
    return htmlStr;
}

function KpshowListByColumn(Kpzt, InvoiceMoneybalance, CGID) {
    var reg = new RegExp(",", "g");//g,表示全部替换。
    InvoiceMoneybalance = parseFloat(InvoiceMoneybalance.replace(reg, "")) == "0" ? "" : InvoiceMoneybalance;
    if (InvoiceMoneybalance != "") {
        InvoiceMoneybalance = app.FormatNumber(InvoiceMoneybalance.replace(reg, ""), "moneybox");
    }
    var htmlStr = "";
    htmlStr = "" + Kpzt + "<br>" + (InvoiceMoneybalance != "" ? "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSN/view/finan/payout/payoutInvoice_list.ashx?BH=" + CGID + "&isinvoice=1','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + InvoiceMoneybalance + "</a>" : "") + "";
    return htmlStr;
}

function OpenUrlBycloum(v, Status, Type, CGID, order1) {
    var htmlStr = Status;
    var ddid1 = "1"
    var ret = "";
    var ret2 = "";
    var domain = "";
    var column = "";
    var page = "";
    var condition = "";
        if (Type == "退货") {
            domain = "SYSN";
            column = "view/store/kuout";
            page = "Detaillist.ashx";
            condition = "ddid1=" + ddid1 + "&ret=" + ret + "&ret2=" + ret2 + "&order1=" + app.pwurl(order1) + "";
        } else {
            domain = "SYSA";
            column = "tongji";
            page = "hzkc2.asp";
            condition = "s1=1&ret=" + ret + "&ret2=" + ret2 + "&CGBH=" + CGID + "";
        }
    if (domain != "" && column != "" && page != "" && condition != "") {
        htmlStr = "" + Status + "" + (Status != "" ? "<br>" : "") + "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "" + domain + "/" + column + "/" + page + "?" + condition + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
    }
    return htmlStr;
}