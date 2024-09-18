
function showDetailByColumn(v, company, canDetail, type) {
    var htmlStr = v;
    if (canDetail === "true") {
        var column = "";
        var page = "";
        var condition = "";
        if (type === "1" || type === "2") {
            if (type == "1") {
                column = "work";
                page = "content.asp";
                condition = "ord=" + app.pwurl(company) + "";
            }
            if (type == "2") {
                column = "work2";
                page = "content.asp";
                condition = "ord=" + app.pwurl(company) + "";
            }
        } else if (type === "cp") {
            column = "product";
            page = "content.asp";
            condition = "ord=" + app.pwurl(company) + "";
        }
        if (type === "zt") {
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSN/view/store/caigou/CaigouDetails.ashx?view=details&ord=" + app.pwurl(company) + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
        else if (column != "" && v != "") {
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/" + column + "/" + page + "?" + condition + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
    }

    return htmlStr;
}