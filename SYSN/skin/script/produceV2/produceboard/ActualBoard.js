var object = new Object;
var MenuInx = 1;//派工/产线
var Page = 1;//当前页
var Interval = 1;//刷新间隔（分钟）
var Line = 1;//每页行数
var PageTotal = 1;//总数据行数
var P = 0;

function abc() {
    Page++;
    if (Page > PageTotal) Page = 1;
    window.location.href = window.SysConfig.VirPath + "SYSN/view/produceV2/ProduceBoard/ActualBoard.ashx?MenuInx=" + MenuInx + "&Page=" + Page;
}

$(function () {
    window.onload = function () {
        var h = document.body.scrollHeight;
        var div = $("#Body_div");
        var hei = div.height();
        if (hei <= h) {
            div.height(h)
        } else {
            div.height("auto")
        }
        if (MenuInx == 1)
            $("#pg").attr("checked", "checked");
        else
            $("#cx").attr("checked", "checked");
        $("#pg").click(function () {
            window.location.href = window.SysConfig.VirPath + "SYSN/view/produceV2/ProduceBoard/ActualBoard.ashx?MenuInx=1&Page=1";
        });
        $("#cx").click(function () {
            window.location.href = window.SysConfig.VirPath + "SYSN/view/produceV2/ProduceBoard/ActualBoard.ashx?MenuInx=2&Page=1";
        });
        $("#lineField").val(Line);
    }

})
window.createPage = function () {
    object.Data = window.PageInitParams[0];
    //加载内容 
    CBodyHtml();
    setInterval("abc()", Interval * 60 * 1000);
}


function CBodyHtml() {
    var html = new Array();
    var myDate = new Date();
    var colCount = MenuInx == 1 ? 9 : 8;//实际数据列个数
    //var h = document.documentElement.clientHeight || document.body.clientHeight;
    html.push("<div id='Body_div' style='width:100%;'>")
    html.push("<div id='Content_div'>");
    html.push("<div id='Top_DateArea_div'>");
    if (P == 1) {
        html.push("<div id='Top_SettingArea'>每屏显示行数：<select id='lineField'><option value='10'>10</option><option value='20'>20</option><option value='30'>30</option><option value='50'>50</option><option value='100'>100</option><option value='200'>200</option></select>&nbsp;");
        html.push("翻屏间隔时间：<input id='IntervalField' style='width:35px;text-align:center;' type='text' value='" + Interval + "'/>分钟&nbsp;");
        html.push("<button style='line-height:15px;' onclick='SaveSetting()'>保存</button>&nbsp;<span id='resultTxt' style='color:red;'></span></div>");
    }
    if (object.Data[0]) {
        html.push("<div id='Top_DateArea' style='font-size:13px;color:white;font-weight:bold'><input id='pg' name='sex' value='1' type='radio' checked='checked'/><label for='pg'>派工</label><input id='cx' name='sex' value='2' type='radio'/><label for='cx'>产线</label>&nbsp;&nbsp;最近刷新：" + object.Data[0] + "</div>");
    }
    html.push("</div>")
    html.push("<table id ='Main_tb' style='width:100%;line-height:48px;'><tbody>");
    //构造表头
    html.push("<tr>");
    for (var i = 0; i < object.Data[1].headers.length && i < colCount; i++) {
        html.push("<th style='font-size:13px;color:#00ff8e;'>" + object.Data[1].headers[i].name + "</th>");
    }
    html.push("</tr>");
    if (MenuInx == 1) {
        for (var i = 0; i < object.Data[1].rows.length ; i++) {
            html.push("<tr id='Main_tr'>");
            for (var j = 0; j < object.Data[1].rows[i].length && j < colCount; j++) {
                if (j < 2) {
                    if (i == 0 || object.Data[1].rows[i][colCount] != object.Data[1].rows[i - 1][colCount]) {
                        var ahtml = "<span style='font-size:13px;color:#00ff8e;font-weight:bold;'>" + object.Data[1].rows[i][j] + "</span>";
                        if (j == 0 && object.Data[1].rows[i][13] == 1) {
                            ahtml = "<a style='font-size:13px;color:#00ff8e;font-weight:bold' href='javascript:;' onclick='javascript:app.OpenUrl(\"" + window.SysConfig.VirPath + "sysn/view/producev2/WorkAssign/WorkAssignDetail.ashx?ord=" + object.Data[1].rows[i][colCount] + "&view=details\")'>" + object.Data[1].rows[i][j] + "</a>";
                        }
                        var button = "";
                        if (j == 0) {
                            if (object.Data[1].rows[i][14] == 1)
                                button += "<span style='color:red'>[加急]</span>";
                            button += "<button style='background-color:#111E38; border:0px; color:white; cursor:pointer;' title='" + (object.Data[1].rows[i][14] == 1 ? "取消" : "") + "加急' onclick='SetUrgent(" + object.Data[1].rows[i][colCount] + ")'>♝</button>";
                        }
                        html.push("<td id='Main_td' align='left' style='padding-left:10px;' rowspan='" + object.Data[1].rows[i][10] + "'>" + ahtml + button + "</td>");
                    }
                }
                else {
                    debugger;
                    var color = "#00ff8e";
                    if (object.Data[1].rows[i][11] == 1) color = "#ff9966";
                    var tempv = object.Data[1].rows[i][j];
                    var ahtml = "<span style='font-size:13px;color:" + color + ";font-weight:bold'>" + (isNaN(tempv) || tempv == "" ? tempv : app.NumberFormat(app.FormatNumber(tempv, "numberbox"))) + "</span>";
                    if (j == 2 && object.Data[1].rows[i][12] > 0) {
                        ahtml = "<a style='font-size:13px;color:" + color + ";font-weight:bold' href='javascript:;' onclick='javascript:app.OpenUrl(\"ActualMDBoard03.ashx?WFPAid=" + object.Data[1].rows[i][12] + "\")'>" + object.Data[1].rows[i][j] + "</a>";
                    }
                    html.push("<td id='Main_td'>" + ahtml + "</td>");
                }
            }
            html.push("</tr>");
        }
    }
    else if (MenuInx == 2) {
        for (var i = 0; i < object.Data[1].rows.length ; i++) {
            html.push("<tr id='Main_tr'>");
            for (var j = 0; j < object.Data[1].rows[i].length && j < colCount; j++) {
                if (j < 2) {
                    if (i == 0 || (j == 0 && object.Data[1].rows[i][colCount] != object.Data[1].rows[i - 1][colCount]) || (j == 1 && (object.Data[1].rows[i][colCount] != object.Data[1].rows[i - 1][colCount] || object.Data[1].rows[i][9] != object.Data[1].rows[i - 1][9]))) {
                        var ahtml = "<span style='font-size:13px;color:#00ff8e;font-weight:bold'>" + object.Data[1].rows[i][j] + "</span>";
                        html.push("<td id='Main_td' " + (j == 0 ? "align='left' style='padding-left:10px;'" : "") + " rowspan='" + object.Data[1].rows[i][10 + j] + "'>" + ahtml + "</td>");
                    }
                }
                else {
                    var color = "#00ff8e";
                    if (object.Data[1].rows[i][12] == 1) color = "#ff9966";
                    var tempv = object.Data[1].rows[i][j];
                    var ahtml = "<span style='font-size:13px;color:" + color + ";font-weight:bold'>" + (isNaN(tempv) || tempv == "" ? tempv : app.NumberFormat(app.FormatNumber(tempv, "numberbox"))) + "</span>";
                    if (j == 2 && object.Data[1].rows[i][15] > 0) {
                        ahtml = "<a style='font-size:13px;color:#00ff8e;font-weight:bold' href='javascript:;' onclick='javascript:app.OpenUrl(\"" + window.SysConfig.VirPath + "sysn/view/producev2/WorkAssign/WorkAssignDetail.ashx?ord=" + object.Data[1].rows[i][14] + "&view=details\")'>" + object.Data[1].rows[i][j] + "</a>";
                    }
                    else if (j == 2) {
                        ahtml = "<span style='font-size:13px;color:#00ff8e;font-weight:bold'>" + object.Data[1].rows[i][j] + "</span>";
                    }
                    html.push("<td id='Main_td' " + (j == 2 ? "align='left' style='padding-left:10px;'" : "") + ">" + ahtml + "</td>");
                }
            }
            html.push("</tr>");
        }
    }
    html.push("</tbody></table>");
    if (object.Data[1].rows.length == 0) {
        html.push("<div style='background:transparent url(../../../../sysa/skin/default/images/ico_kb_nodate.png) no-repeat;background-position:center center;height:200px; max-width:1280px;margin: 0 auto;'></div>");
    }
    html.push("</div>");
    document.write(html.join(""));
}

function SetUrgent(waid) {
    app.ajax.regEvent("SetUrgent");
    app.ajax.addParam("waid", waid);
    app.ajax.send();
    window.location.href = window.SysConfig.VirPath + "SYSN/view/produceV2/ProduceBoard/ActualBoard.ashx?MenuInx=" + MenuInx + "&Page=1";
}

function SaveSetting() {
    var line = $("#lineField").val();
    var Interval = $("#IntervalField").val();
    app.ajax.regEvent("SaveSetting");
    app.ajax.addParam("line", line);
    app.ajax.addParam("Interval", Interval);
    var result = app.ajax.send();
    if (result == "1") {
        $("#resultTxt").text("保存成功！");
        setTimeout(function () {
            window.location.href = window.SysConfig.VirPath + "SYSN/view/produceV2/ProduceBoard/ActualBoard.ashx?MenuInx=" + MenuInx + "&Page=1";
        }, 500);
    }
    else {
        $("#resultTxt").text(result);
        setTimeout(function () {
            $("#resultTxt").text("");
        }, 1000);
    }

}