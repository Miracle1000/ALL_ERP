function showDetail(ord, title, billType) {
    var htmlStr = (title + "").replace(/\</g,"&lt;");//对尖括号进行转义
    if (title == "(已彻底删除)" || title == "(已删除)") { htmlStr = "<span style=color:red>" + title + "</span>"; }
    var typeName = "";
    switch (billType) {
        case "1"://客户发货详情
            htmlStr = OnClickLinkUrl("sysa/store/contentck.asp?ord=" + app.pwurl(ord) + "", billType, title);
            break;
        case "3": //退款详情
            htmlStr = OnClickLinkUrl("SYSA/contractth/content.asp?ord=" + app.pwurl(ord) + "", billType, title);
            break;
        case "5": //客户预收款详情
            htmlStr = OnClickLinkUrl("sysa/money/contentyfk.asp?ord=" + app.pwurl(ord) + "", billType, title);
            break;

        default: typeName = billType; break;
    }
    if (typeName.length > 0) {
        htmlStr = OnClickLinkUrl("sysa/" + typeName + "/content.asp?ord=" + app.pwurl(ord) + "", billType, title);
    }
    return htmlStr;
}

function OnClickLinkUrl(url, billType, title) {
    var htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:app.OpenUrl('";
    htmlStr += window.SysConfig.VirPath;
    htmlStr += url;
    htmlStr += "')\">" + title + "</a>";
    return htmlStr
}

function showDetailByColumn(v, company, canDetail, type, date1_0, date1_1, bztype, showBtn,billtype) {
    var zt = "1,2";
    var s = v;
    var column = "";
    var page = "";
    var condition = "";
    s = (s + "").replace(/\</g, "&lt;");//对尖括号进行转义
    if (s.indexOf("(已删除)") >= 0) { s = s.replace("(已删除)", "<span style='color:red'>(已删除)</span>") }

    var isNet = false;
    if (type == "cp" && canDetail == "true") {
        column = "product";
        page = "content.asp";
        condition = "ord=" + app.pwurl(company) + "&showBtn=" + showBtn;//穿透到产品详情，showBtn为1则不显示按钮
    }
    else if (type == "2" && canDetail == "true") { //出库
        column = "view/store/kuout";
        page = "kuoutdetails.ashx";
        condition = "ord=" + app.pwurl(company) + "&view=details";
        isNet = true;
    }
    else if ((type == "3" || type == "ht") && canDetail == "true" && billtype != "4" && billtype != "7" && billtype != "8") {
        //虚拟产品
        column = "view/sales/contract";
        page = "contractDetails.ashx";
        condition = "ord=" + app.pwurl(company) + "&view=details";
        isNet = true;
    }
    else if (type == "4" || billtype=="4") { //销售退货
        if (canDetail == "true") {
            column = "contractth";
            page = "content.asp";
            condition = "ord=" + app.pwurl(company) + "";
        }
        s = (type == 4 ? "<span style='color:red'>" + s + "</span>" : s);
    }
    else if (billtype == "7" ) { //付款
        column = "money";
        page = "payback.asp";
        condition = "ord=" + app.pwurl(company) + "";
    }
    else if (billtype == "8") { //实收
        column = "view/finan/payback";
        if (company > 0) {
            page = "PayBackSureDetail.ashx";
        } else {
            page = "PayBack.ashx";
            company = -parseInt(company)
        }
        condition = "ord=" + app.pwurl(company) + "&view=details";
        isNet = true;
    }
    else if (type.indexOf('money') >= 0) { //余额
        if (s.indexOf("-") > -1) s = "<span style='color:red'>" + s.replace("-", "") + "</span>";
        if (type == 'money' && canDetail == 'true') {
            column = "money";
            page = "planall2.asp";
            condition = "hkzt=" + zt + "&B=khmc&company=" + app.pwurl(company) + "&ret=" + date1_0 + "&ret2=" + date1_1 + "&bz=" + bztype + "";
        }
    }
    if (column != "" && v != "") {
        if (isNet == true && canDetail == "true") {
            s = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSN/" + column + "/" + page + "?" + condition + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + s + "</a>";
        }
        if (isNet==false && billtype != "8") {
            s = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/" + column + "/" + page + "?" + condition + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + s + "</a>";
        }   
    }
    return s;
}

function showFieldsColor(v, bType) {
    var s = v;
    if (bType == "1") {
        s = "<span style='color:red'>" + s + "</span>";
    }
    return s;
}

function overShow(value, e, id) {
    var showDiv = document.getElementById(id);
    var theEvent = window.event || e;
    showDiv.style.left = theEvent.clientX + "px";
    showDiv.style.top = theEvent.clientY + "px";
    showDiv.style.display = 'block';
    showDiv.innerHTML = value;
}

function outHide(id) {
    var showDiv = document.getElementById(id);
    showDiv.style.display = 'none';
    showDiv.innerHTML = '';
}

function modelPrint() {
    window.open('../../comm/TemplatePreview.ashx?sort=74&ord=0&isreport=true', '', 'scrollbars = 1, resizable = 1, width = 1100, height = 500, top = 200, left = 200');
}
function mxintroRender(value) {
    var showValue = value;
    var filtValue = value.replace(/<br\/>/g, "");
    if (filtValue.length >= 20) {
        showValue = filtValue.substr(0, 20) + (filtValue.length == 20 ? "" : "...");
    }
    return "<div id=\"showDetailDiv\" style=\"position: absolute; border: 1px solid black;display:none;background-color:#FFFFFF \"></div> <div class='content' onmouseover=\"overShow('" + value + "',event,'showDetailDiv')\" onmouseout=\"outHide('showDetailDiv')\"><span style='color:black'>" + showValue + "</span></div>";
}
function introRender(value) {
    var showValue = "";
    var strArr = value.split("</p>");
    var filtValue = "";
    for (var i = 0; i < strArr.length;i++)
    {
        if (strArr[i].indexOf("img") < 0)
        {
            filtValue +=strArr[i];
        }       
    }
    if (strArr.length == 0) { return ""; }
    filtValue = filtValue.replace(/<p>/g, "").replace(/<\/p>/g, "");

    showValue = filtValue
    return "<div id=\"showDiv\" style=\"position: absolute; border: 1px solid black;display:none;background-color:#FFFFFF \"></div> <div class='content' title='" + filtValue + "'><span style='color:black;'>" + showValue + "</span></div>";
}