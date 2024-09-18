function showDetailByColumn(v, company, canDetail, type) {
    var htmlStr = v;
    if (canDetail === "true") {
        var column = "";
        if (type === "cu") {
            column = "work";
        } else if (type === "ag") {
            column = "contract";
        } else if (type === "pd") {
            column = "product";
        } else if (type == "prj")
        {
            column = "chance";
        } else if (type == "ycd") {
            column = "";
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/manufacture/inc/Readbill.asp?orderid=1&ID=" + company + "&SplogId=0&vTime=" + Math.random() + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        } else if (type == "scjh") {
            column = "";
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/manufacture/inc/Readbill.asp?orderid=3&ID=" + company + "&SplogId=0&vTime=" + Math.random() + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
        else if (type == "sc") {
            column = "";
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/manufacture/inc/Readbill.asp?orderid=2&ID=" + company + "&SplogId=0&vTime=" + Math.random() + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
        if (column != "") {
            if (column == "contract") {
                htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSN/view/sales/contract/ContractDetails.ashx?ord=" + app.pwurl(company) + "&view=details','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
            } else {
                htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/" + column + "/content.asp?ord=" + app.pwurl(company) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
            }
        }
    }
    return htmlStr;
}
function showFormatCellContent(remaindays) {
    if (remaindays.replace(/,/g, '') < 0)
    {
        return "<font color='red'>" + remaindays + "</font>";
    }
    return remaindays;
}
function showrkmxdetail(instorecount, productid, contractid, rkright) {
    if (instorecount.replace(/,/g, '') > 0 && rkright === "true") {
        htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/tongji/hzkc2.asp?pdid=" + app.pwurl(productid) + "&contractid=" + app.pwurl(contractid) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + instorecount + "</a>";
        return htmlStr;
    }
    return instorecount;
}
function showckmxdetail(outstorecount, productid, id, ckright) {
    if (outstorecount.replace(/,/g, '') > 0 && ckright === "true") {
        htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/tongji/hzkc3.asp?pdid=" + app.pwurl(productid) + "&contractlistid=" + app.pwurl(id) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + outstorecount + "</a>";
        return htmlStr;
    }
    return outstorecount;
}
function showll(picking, ID, ckright) {
    if (picking.replace(/,/g, '') > 0 && ckright === "true") {
        htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/tongji/hzkc3.asp?ddid=" + app.pwurl(ID) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + picking + "</a>";
        return htmlStr;
    }
    return picking;
}
function showRelationBill(billid, orderid) {
    var htmlStr = "<a href='javascript:void(0);' onclick=\"openRelationBill('" + billid + "','" + orderid + "')\">关联单据</a>";
    return htmlStr;
}
function openRelationBill(billid) {
    var url = window.SysConfig.VirPath + 'SYSA/manufacture/inc/billpage.asp?__msgId=getChildBillTree&t=' + (new Date()).getTime() + '&oid=2&bid=' + billid;
    app.closeWindow("relationBillWindow");
    var win = app.createWindow("relationBillWindow", "关联单据", { closeButton: true, height: 400, width: 850 });
    win.innerHTML = "<iframe frameborder='0' scrolling=0  src='" + url + "' width=\"840\" height=\"380\" onLoad=\"setHeight(this)\"></iframe> ";
    win.style.overflow = "hidden";
}
function setHeight(obj) {
    var win = obj;
    if (document.getElementById) {
        if (win && !window.opera) {
            if (win.contentDocument && win.contentDocument.body.offsetHeight)
                win.height = win.contentDocument.body.offsetHeight;
            else if (win.Document && win.Document.body.scrollHeight)
                win.height = win.Document.body.scrollHeight;
        }
    }
}