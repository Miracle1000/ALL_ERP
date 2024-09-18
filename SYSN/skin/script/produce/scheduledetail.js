
function showDetailByColumn(v, company, canDetail, type) {
    var htmlStr = v;
    if (canDetail === "true") {
        var column = "";
        var page = "";
        var condition = "";
        if (type === "ht") {
            column = "contract";
            page = "content.asp";
            condition = "ord=" + app.pwurl(company) + "";
        } else if (type === "xm") {
            column = "chance";
            page = "content.asp";
            condition = "ord=" + app.pwurl(company) + "";
        } else if (type === "ycd") {
            column = "manufacture";
            page = "inc/Readbill.asp";
            condition = "orderid=1&ID=" + company + "&SplogId=0&vTime=" + Date.parse(new Date());
        }
        else if (type === "kh") {
            column = "work";
            page = "content.asp";
            condition = "ord=" + app.pwurl(company) + "";
        }
        else if (type === "pgd") {
            column = "manufacture";
            page = "inc/Readbill.asp";
            condition = "orderid=8&ID=" + company + "&SplogId=0&vTime=" + Date.parse(new Date());
        }
        else if (type === "fgd") {
            column = "manufacture";
            page = "inc/Readbill.asp";
            condition = "orderid=20&ID=" + company + "&SplogId=0&vTime=" + Date.parse(new Date());
        }
        else if (type === "wwd") {
            column = "manufacture";
            page = "inc/Readbill.asp";
            condition = "orderid=25&ID=" + company + "&SplogId=0&vTime=" + Date.parse(new Date());
        }
        else if (type === "cp") {
            column = "product";
            page = "content.asp";
            condition = "ord=" + app.pwurl(company) + "";
        }
        if (column != "" && v != "") {
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/" + column + "/" + page + "?" + condition + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
    }

    return htmlStr;
}

function showForLayer(detailId, funName, e) {
    if (window.hasOnMouseIn == 1) { return; }
    if (!window.hasOnMouseIn) { window.hasOnMouseIn = 1; }
    app.ajax.regEvent(funName);
    app.ajax.addParam("ID", detailId);
    var result = app.ajax.send();
    if (result == "" || result == undefined)
    {
        app.closeWindow(funName);
        return;
    }
    e = e || window.event;
    app.showServerPopo(e, funName, eval("(" + result + ")"));

    $("#" + funName).bind("mouseover", function () {
        canclose = false;
        $("#" + funName).show();
    })

    $("#" + funName).bind("mouseout", function () {
        canclose = true;
        $("#" + funName).hide();
    })
}

var canclose = true;
function closeForLayer(winName, e) {
    window.hasOnMouseIn = null;
    setTimeout(function () {
        if (canclose) {
            $("#" + winName).hide();
        }
    },500)
    
}