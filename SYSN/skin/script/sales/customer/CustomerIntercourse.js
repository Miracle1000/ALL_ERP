function OpenUrlByLink(v, t1,t2,E,type,c,FromType,companyid)
{
    //FromType:1?'来源客户'：'供应商'
    var t = 1;
    if (type == "所有") {
        t1 = "",
        t2 = "",
        t=2
        
    }
    var htmlStr = v;
    //采购单数
    if (c == "1") {      
        domain = "SYSA";
        column = "caigou";
        page = "planall.asp";
        condition = "telord="+app.pwurl(companyid)+"&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";
    }
    //入库单数
    else if (c == "2")
    {
        domain = "SYSN";
        column = "view/store/kuin";
        page = "List.ashx";
        condition = "sort1=1&companyid=" + app.pwurl(companyid) + "&t1=" + t1 + "&t2=" + t2 + "&type=" + t + "";
    }
    else if (c == "3") {
        domain = "SYSA";
        column = "tongji";
        page = "hzkc2.asp";
        condition = "ret=" + t1 + "&ret2=" + t2 + "&companyid=" + app.pwurl(companyid) + "&type=" + t + "&D=1";
    }
    //退货
    else if (c == "4") {
        domain = "SYSN";
        column = "view/store/caigouth";
        page = "PurchaseReturnList.ashx";
        condition = "company=" + app.pwurl(companyid) + "&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";
    } //整单委外
    else if (c == "5") {
        domain = "SYSN";
        column = "view/produceV2/ProductionOutsource";
        page = "ProOutsourceList.ashx";
        condition = "gys=" + app.pwurl(companyid) + "&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";
    }//工序委外
    else if (c == "6") {
        domain = "SYSN";
        column = "view/produceV2/OutProcedure";
        page = "OutProcedureList.ashx";
        condition = "company=" + app.pwurl(companyid) + "&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";
    }
    //已付金额
    else if (c == "7") {
        domain = "SYSN";
        column = "view/finan/payout";
        page = "PayOutList.ashx";
        condition = "pagefrom=jhhz&plans=666&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "&ord=" + app.pwurl(companyid) + "";
    }
    //已退金额
    else if (c == "8") {
        domain = "SYSA";
        column = "money4";
        page = "planall2.asp";
        condition = "gysord=" + app.pwurl(companyid) + "&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";
    }
    //预付款金额
    else if (c == "9") {
        domain = "SYSA";
        column = "money2";
        page = "planall_yfk.asp";
        condition = "company=" + app.pwurl(companyid) + "&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";
    }
    //退预付款金额
    else if (c == "10") {
        domain = "SYSA";
        column = "money2";
        page = "planall_backyfk.asp";
        condition = "B=khmc&C=" + E + "&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";
    }
    //已收发票
    else if (c == "11") {
        domain = "SYSN";
        column = "view/finan/InvoiceManage/ReceivedInvoice";
        page = "ReceivedInvoiceList.ashx";
        condition = "companyid=" + app.pwurl(companyid) + "&DateType=SureDate1&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";

    }
    //已收金额
    else if (c == "12") {
        domain = "SYSA";
        column = "money";
        page = "planall2.asp";
        condition = "A=3&B=khmc&C=" + E + "&paydate1=" + t1 + "&paydate2=" + t2 + "&type=" + t + "&From=1";
    }
    //已退金额
    else if (c == "13") {
        domain = "SYSA";
        column = "money3";
        page = "planall2.asp";
        condition = "A=2&B=khmc&C=" + E + "&paydate1=" + t1 + "&paydate1=" + t2 + "&type=" + t + "";
    }
    //预收金额
    else if (c == "14") {
        domain = "SYSN";
        column = "view/finan/payback/PaybackPre";
        page = "BankList.ashx";
        condition = "B=khname&C=" + E + "&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";
    }
    //退预收金额
    else if (c == "15") {
        domain = "SYSA";
        column = "money";
        page = "planall_backyfk.asp";
        condition = "B=khmc&C=" + E + "&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";
    } 
    //已开金额
    else if (c == "16") {
        domain = "SYSN";
        column = "view/finan/InvoiceManage/MakeOutInvoice";
        page = "MakeOutInvoiceList.ashx";
        condition = "KpStatus=666&SearchValue=" + E + "&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";
    }
    //合同单数
    else if (c == "17") {
        domain = "SYSA";
        column = "contract";
        page = "planall.asp";
        condition = "companyid=" + app.pwurl(companyid) + "&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";
    }
    //出库单数
    else if (c == "18") {
        domain = "SYSN";
        column = "view/store/kuout";
        page = "list.ashx";
        condition = "ckzt=3&sclx=1,4&serchkey=company&serchkeyTxt=" + E + "&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";
    }
    //出库数量
    else if (c == "19") {
        domain = "SYSN";
        column = "view/store/kuout";
        page = "Detaillist.ashx";
        condition = "companyid=" + app.pwurl(companyid) + "&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";
    }
    //发货单数
    else if (c == "20") {
        domain = "SYSA";
        column = "tongji";
        page = "hzkc6.asp";
        condition = "s1=1&B=glkh&C=" + E + "&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";
    }
    //生产入库
    else if (c == "21") {
        domain = "SYSA";
        column = "tongji";
        page = "hzkc2.asp";
        condition = "companyid=" + app.pwurl(companyid)+"&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "&fromsc=sc";
    }
    //销售退货单
    else if (c == "22") {
        domain = "SYSA";
        column = "contractth";
        page = "planall.asp";
        condition = "khmc=" + E + "&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "";
    }
    //发货单
    else if (c == "23") {
        domain = "SYSA";
        column = "sent";
        page = "planall.asp";
        condition = "datetype=sfrq&a=1&ksjs=khmc&ksjs2=" + E + "&ksjs3=" + t1 + "&ksjs4=" + t2 + "&type=" + t + "&SearchType=0";
    }
    //生产定单
    else if (c == "24") {
        domain = "SYSN";
        column = "view/produceV2/ManuOrders";
        page = "ManuOrdersList.ashx";
        condition = "gys=" + app.pwurl(companyid) + "&ret=" + t1 + "&ret2=" + t2 + "&type=" + t + "&Ismode=1";//包含入库完毕的
    }
    if (domain != "" && column != "" && page != "" && condition != "") {
        htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "" + domain + "/" + column + "/" + page + "?" + condition + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
    }
    return htmlStr;

}