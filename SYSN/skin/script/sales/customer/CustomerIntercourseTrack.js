//主题链接
function showDetailByColumn(v, ord, canDetail, type) {
    var htmlStr = v;
    if (canDetail === "1" && v != "" && ord != "0") {
        var domain = "";
        var column = "";
        var page = "";
        var condition = "";
        if (type == "1" || type == "6" || type == "9") {
            //合同
            domain = "SYSN";
            column = "view/sales/contract";
            page = "contractDetails.ashx";
            condition = "ord=" + app.pwurl(ord) + "&view=details";
        } else if (type == "2") {
            //出库
            domain = "SYSN";
            column = "view/store/kuout";
            //column = "store";
            page = "kuoutdetails.ashx";
            condition = "view=details&ord=" + app.pwurl(ord) + "";
            //condition = "ord=" + app.pwurl(ord) + "";
        } else if (type == "3") {
            //发货
            domain = "SYSN";
            column = "view/store/sent";
            page = "Sent.ashx";
            condition = "view=details&ord=" + app.pwurl(ord) + "";
        } else if (type == "4" || type == "7" || type == "26" || type == "10") {
            //销售退货
            domain = "SYSA";
            column = "contractth";
            page = "content.asp";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        else if (type == "5") {
            //销售对账
            domain = "SYSN";
            column = "view/finan/Checks";
            page = "Bill.ashx";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        else if (type == "8") {
            //实收
            domain = "SYSN";
            column = "view/finan/payback";
            page = "PayBackSureDetail.ashx";
            condition = "view=details&ord=" + app.pwurl(ord) + "";
        }
        else if (type == "25") {
            //实开
            domain = "SYSN";
            column = "view/finan/InvoiceManage/MakeOutInvoice";
            page = "MakeOutInvoiceDetail.ashx";
            condition = "view=details&ord=" + app.pwurl(ord) + "";
        }
        else if (type == "11") {
            //预收款
            domain = "SYSA";
            column = "money";
            page = "contentyfk.asp";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        else if (type == "12") {
            //退预收款
            domain = "SYSA";
            column = "money";
            page = "contentbackyfk.asp";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        else if (type == "13" || type == "16" || type == "20") {
            //采购
            domain = "SYSN";
            column = "view/store/caigou";
            page = "caigoudetails.ashx";
            condition = "view=details&ord=" + app.pwurl(ord) + "";
        }
        else if (type == "14") {
            //入库
            domain = "SYSN";
            column = "view/store/kuin";
            page = "kuin.ashx";
            condition = "view=details&ord=" + app.pwurl(ord) + "";
        }
        else if (type == "15" || type == "18" || type == "19" || type == "27") {
            //采购退货
            domain = "SYSN";
            column = "view/store/caigouth";
            page = "PurchaseReturn.ashx";
            condition = "view=details&ord=" + app.pwurl(ord) + "";
        }
        else if (type == "22") {
            //预付款
            domain = "SYSA";
            column = "money2";
            page = "contentyfk.asp";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        else if (type == "23") {
            //退预付款
            domain = "SYSA";
            column = "money2";
            page = "contentbackyfk.asp";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        else if (type == "24") {
            //整单委外
            domain = "SYSN";
            column = "view/produceV2/ProductionOutsource";
            page = "ProOutsourceAdd.ashx";
            condition = "&view=details&ord=" + app.pwurl(ord) + "";
        }
        else if (type == "30") {
            //工序委外
            domain = "SYSN";
            column = "view/produceV2/OutProcedure";
            page = "AddOutProcedure.ashx";
            condition = "&view=details&ord=" + app.pwurl(ord) + "";
        }
        else if (type == "17") {
            //实付
            domain = "SYSN";
            column = "view/finan/payout";
            page = "PayoutSureDetail.ashx";
            condition = "&view=details&ord=" + app.pwurl(ord) + "";
        }
        else if (type == "21") {
            //实收
            domain = "SYSN";
            column = "view/finan/InvoiceManage/ReceivedInvoice";
            page = "ReceivedInvoiceDetail.ashx";
            condition = "&view=details&ord=" + app.pwurl(ord) + "";
        }
        if (domain != "" && column != "" && page != "" && condition != "") {
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "" + domain + "/" + column + "/" + page + "?" + condition + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
    }
    return htmlStr;
}



//编号链接
function showDetailByNO(v, ord, canDetail, type) {
    var htmlStr = v;
    if (canDetail === "1" && v != "" && ord != "0") {
        var domain = "";
        var column = "";
        var page = "";
        var condition = "";
        if (type == "6") {
            //收款计划
            domain = "SYSN";
            column = "view/finan/payback";
            page = "PayBack.ashx";
            condition = "view=details&ord=" + app.pwurl(ord) + "";
        } 
        else if (type == "7" || type == "26") {
            //销售退款计划
            domain = "SYSN";
            column = "view/finan/payback";
            page = "Payout2Detail.ashx";
            condition = "view=details&ord=" + app.pwurl(ord) + "";
        }
        else if (type == "8") {
            //实收
            domain = "SYSN";
            column = "view/finan/payback";
            page = "Payout2Detail.ashx";
            condition = "view=details&ord=" + app.pwurl(ord) + "";
        }
        else if (type == "9" || type == "10") {
            //开票计划
            domain = "SYSN";
            column = "view/finan/InvoiceManage/InvoicePlan";
            page = "InvoicePlansDetail.ashx";
            condition = "view=details&ord=" + app.pwurl(ord) + "";
        }
        else if (type == "16") {
            //付款计划
            domain = "SYSN";
            column = "view/finan/payout";
            page = "Payout.ashx";
            condition = "view=details&ord=" + app.pwurl(ord) + "";
        }
        else if (type == "18" || type == "19") {
            //付款计划
            domain = "SYSN";
            column = "view/finan/payout";
            page = "PayRefund.ashx";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        else if (type == "20" || type == "27") {
            //付款计划
            domain = "SYSN";
            column = "view/finan/payout";
            page = "contentInvoice.ashx";
            condition = "ord=" + app.pwurl(ord) + "";
        }
        if (domain != "" && column != "" && page != "" && condition != "") {
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "" + domain + "/" + column + "/" + page + "?" + condition + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
    }
    return htmlStr;
}

function AbsMoney(v,Type)
{
    return v.replace("-","") ;
}