function check_kh2(ord) {
    var url = "../sent/search_lxr.asp?ord=" + escape(ord) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        if (xmlHttp.readyState == 4) {
            $("#sh_0").html(xmlHttp.responseText);
        }
    };
    xmlHttp.send(null);
}


//主题链接
function showDetailByColumn(v, ord, canDetail, type) {
    var htmlStr = v;
    if (canDetail === "1" && v != "" && ord != "0") {
        var domain = "";
        var column = "";
        var page = "";
        var condition = "";
        switch (type) {
            case "1":
            case "4":
                domain = "SYSN";
                column = "view/sales/contract";
                page = "ContractDetails.ashx";
                condition = "ord=" + app.pwurl(ord) + "&view=details";
                break;
            case "2":
                domain = "SYSN";
                column = "view/store/caigouth";
                page = "PurchaseReturn.ashx";
                condition = "&view=details&ord=" + app.pwurl(ord) + "";
                break;
            case "6":
                domain = "SYSA";
                column = "store";
                page = "contentjh.asp";
                condition = "ord=" + app.pwurl(ord) + "";
                break;
            case "3":
                domain = "SYSN";
                column = "view/produceV2/Material";
                page = "OrdersAdd.ashx";
                condition = "&view=details&ord=" + app.pwurl(ord) + "";
                break;
            case "7":
                domain = "SYSA";
                column = "store";
                page = "contentdb.asp";
                condition = "ord=" + app.pwurl(ord) + "";
                break;
            case "9":
                domain = "SYSA";
                column = "store";
                page = "contentzz.asp";
                condition = "ord=" + app.pwurl(ord) + "";
                break;
            case "12":
                domain = "SYSN";
                column = "view/produceV2/Material";
                page = "SupplementsAdd.ashx";
                condition = "ord=" + app.pwurl(ord) + "&view=details";
                break;
        }
        if (domain != "" && column != "" && page != "" && condition != "") {
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "" + domain + "/" + column + "/" + page + "?" + condition + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
    }
    return htmlStr;
}

window.SerialNumberBoxHtml = function (field, datas, numbers) {
    var htm = [];
    htm.push("<span dbname='" + field.dbname + "' uitype='" + field.uitype + "' name='" + field.dbname + "' id='" + field.dbname + "' value='" + datas.SerialNumbers + "'>" + numbers[0]);
    field.typejson = field.typejson.replace("editable", "readonly");
    htm.push("<img name='serial' src='" + window.SysConfig.VirPath + "SYSN/skin/default/img/percent100.png' onclick='Bill.openSerialNumberPage(" + field.typejson + ",$(this)," + datas.CreateType + ",\"" + encodeURIComponent(field.dbname) + "\"," + datas.SerialNumbers.split(',').length + "," + JSON.stringify(datas) + ")' alt='点击显示更多' style='margin-left:5px;width:12px;height:18px;cursor:pointer;' >");
    htm.push("</span>");
    return htm.join("");
}