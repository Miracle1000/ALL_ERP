function showHtml(ord, canDetail, title , billType) {
    var htmlStr = title;
    if (title == "(已彻底删除)" || title == "(已删除)") { htmlStr = "<span style=color:red>" + title + "</span>"; }
    if (canDetail == "_url") {
        var typeName = "";
        switch (billType) {
            case "-1": typeName = "product"; break;//产品详情
            case "1":
                htmlStr = OnClickLinkUrl("SYSN/view/sales/contract/ContractDetails.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;//合同详情
            case "2": //收款计划
                htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "sysn/view/finan/payback/PayBack.ashx?view=details&ord=" + app.pwurl(ord) + "','newwin" + billType + "','width=1100,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + title + "</a>";
                break;
            case "3": //实际收款
                htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "sysn/view/finan/payback/PayBackSureDetail.ashx?view=details&ord=" + app.pwurl(ord) + "','newwin" + billType + "','width=1100,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + title + "</a>";
                break;
            case "4": typeName = "contractth"; break;//合同退货详情
            case "5"://退货退款详情
                htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSN/view/finan/payback/Payout2Detail.ashx?view=Details&ord=" + app.pwurl(ord) + "','newwin" + billType + "','width=1100,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + title + "</a>";
                break;
            case "6": //客户预收款详情
                htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSN/view/finan/payback/PaybackPre/BankIn2.ashx?view=Details&ord=" + app.pwurl(ord) + "','newwin" + billType + "','width=1100,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + title + "</a>";
                break;
            case "7": //客户退预收款详情
                htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "sysa/money/contentbackyfk.asp?ord=" + app.pwurl(ord) + "','newwin" + billType + "','width=1100,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + title + "</a>";
                break;
        }
        if (typeName.length > 0) {
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "sysa/" + typeName + "/content.asp?ord=" + app.pwurl(ord) + "','newwin" + billType + "','width=1100,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + title + "</a>";
        }
    }
    return htmlStr;
}

function modelPrint() {
    window.open('../../comm/TemplatePreview.ashx?sort=74&ord=0&isreport=true', '', 'scrollbars = 1, resizable = 1, width = 1100, height = 500, top = 200, left = 200');
}

function HandleCustomResult() {
    if ($("#reportintro").size() == 0) { $("#maingrid").after("<div id='reportintro'>&nbsp;※：日期范围内不包含全部关联单据。</div>"); }
}

function OnClickLinkUrl(url, billType, title) {
    var htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:app.OpenUrl('";
    htmlStr += window.SysConfig.VirPath;
    htmlStr += url;
    htmlStr += "','salesDetails',null,'company,topORD,date5,kuoutmoney,thmoney,sort1')\">" + title + "</a>";
    return htmlStr
}