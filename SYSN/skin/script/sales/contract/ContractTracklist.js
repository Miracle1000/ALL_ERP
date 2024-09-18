function showDetailByColumn(v, ord, canDetail, type) {
    var htmlStr = v;
    if (canDetail === "true" && v != "" && ord != "0") {
        var domain = "";
        var column = "";
        var page = "";
        var condition = "";
        if (type == "合同") {
            //合同
            domain = "SYSN";
            column = "view/sales/contract";
            page = "ContractDetails.ashx";
            condition = "ord=" + app.pwurl(ord) + "&view=details";
        } else if (type == "退货") {
            //退货
            domain = "SYSA";
            column = "contractth";
            page = "content.asp";
            condition = "ord=" + app.pwurl(ord) + "";
        } else {
            domain = "SYSN";
            column = "view/produceV2/ManuPlansPre";
            page = "ManuPlansPreList.ashx";
            condition = "HtTitle=" + ord + "";
            
        }
        if (domain != "" && column != "" && page != "" && condition != "") {
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "" + domain + "/" + column + "/" + page + "?" + condition + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
    }
    return htmlStr;
}


function showScByColumn(v,type,ord) {
    var htmlStr = v;
        var domain = "";
        var column = "";
        var page = "";
        var condition = "";
        if (type == "退货") {
            //合同
            htmlStr = "---";
            //退货
        } else if (type == "合同") {
            domain = "SYSN";
            column = "view/produceV2/ManuPlansPre";
            page = "ManuPlansPreList.ashx";
            condition = "HtTitle=" + ord + "";

        }
        if (domain != "" && column != "" && page != "" && condition != "") {
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "" + domain + "/" + column + "/" + page + "?" + condition + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
    return htmlStr;
}


function SkshowListByColumn(Skzt, paybacbalance, yh, Ml, htid, type,qx) {
    var ret = "";
    var ret2 = "";
    paybacbalance = parseFloat(paybacbalance.replace(/,/g, '')) == "0" ? "" : app.FormatNumber(paybacbalance.replace(/,/g, ''), "moneybox");
    var htmlStr = "";
    paybacbalance = Skzt == "收款完毕" || Skzt == "退款完毕" ? "" : paybacbalance;
    Ml = Skzt == "收款完毕" ? 0 : app.FormatNumber(Ml.replace(",", ""), "moneybox");
    yh = app.FormatNumber(yh.replace(",", ""), "moneybox");
    if (type == "合同") {
        htmlStr = Skzt + (parseFloat(paybacbalance) > 0 && qx == 1 && paybacbalance != "" ? "<br><a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/money/planall2.asp?s1=1&A=3&contractord=" + app.pwurl(htid) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + app.NumberFormat(paybacbalance) + "</a>" : parseFloat(paybacbalance) > 0 ? "<br>" + paybacbalance : paybacbalance) + "" + (parseFloat(Ml) > 0 ? "<br>抹零：" + yh + Ml : "") + "";

    } else {

        htmlStr = Skzt + (parseFloat(paybacbalance) > 0 && qx == 1 && paybacbalance != "" ? "<a style='color:red' href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/money3/planall2.asp?ctord=" + app.pwurl(htid) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + app.NumberFormat(paybacbalance) + "</a>" : parseFloat(paybacbalance) > 0 ? "<br>" + paybacbalance : paybacbalance) + "";

    }


    return htmlStr;
}
function showColor(v, Type, contract, Ismode, contractthOrd)
{
    var htmlStr = v;
    if (Ismode == "1") {
        if (Type == "退货") {
            htmlStr = "<span style='color:red'>" + v + "</span>"
        }
    } else {
        if (Type == "合同") {
            htmlStr = "<a  href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSN/view/statistics/sale/product/ProductSaleDetail.ashx?Htord=" + app.pwurl(contractthOrd) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>"
        } else {

            htmlStr = "<a  href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/contractth/report_contractth_list.asp?contractthOrd=" + app.pwurl(contractthOrd) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>"
        }
    }
    return htmlStr;
}

function KpshowListByColumn(Kpzt, InvoiceMoneybalance, contract, type, qx1) {
    InvoiceMoneybalance = Kpzt == "开票完毕" || Kpzt == "开票完毕" ? "" : InvoiceMoneybalance.replace(/,/g, '');
    InvoiceMoneybalance = app.FormatNumber(InvoiceMoneybalance, "moneybox");
    InvoiceMoneybalance=parseFloat(InvoiceMoneybalance) == "0" ? "" : app.FormatNumber(InvoiceMoneybalance, "moneybox");
    var htmlStr = "";
    htmlStr = "" + Kpzt + "<br>" + (parseFloat(InvoiceMoneybalance) > 0 && qx1 == 1 ? "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/money/paybackInvoice_List.asp?" + (type == "合同" ? "contract" : "contractthOrd") + "=" + (type == "合同" ? app.pwurl(contract) : contract) + "&A=5','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + app.NumberFormat(InvoiceMoneybalance) + "</a>" : parseFloat(InvoiceMoneybalance) > 0 ? InvoiceMoneybalance : InvoiceMoneybalance) + "";
    return htmlStr;
}

function OpenUrlBycloum(v, Status, Type, Ismode, Title, contract) {
        var htmlStr = Status;
        var ddid1="1"
        var ret = "";
        var ret2 = "";
        var domain = "";
        var column = "";
        var page = "";
        var condition = "";
        if (Ismode == "1") {//出入库穿透
            if (Type == "合同") {
                //合同
                domain = "SYSN";
                column = "view/store/kuout";
                page = "Detaillist.ashx";
                condition = "order1=" + app.pwurl(contract) + "&ddid1=" + ddid1 + "&ret=" + ret + "&ret2=" + ret2 + "&HtTitle=" + Title + "";
            } else {
                //退货
                domain = "SYSA";
                column = "tongji";
                page = "hzkc2.asp";
                condition = "ContractthNO=" + Title + "";
            }
        } else {//发货穿透
            if (Type == "合同") {
                //合同
                domain = "SYSA";
                column = "tongji";
                page = "hzkc6.asp";
                condition = "order1=" + app.pwurl(contract) + "&ret=" + ret + "&ret2=" + ret2 + "&s1=1&type=2";
            }

        }
        if (domain != "" && column != "" && page != "" && condition != "") {
            htmlStr = "" + Status + "" + (Status != "" ? "<br>" : "") + "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "" + domain + "/" + column + "/" + page + "?" + condition + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
    return htmlStr;
}