$(function () {
    //页面金额固定2位小数显示
    window.SysConfig.MoneyBit = 2;
    //绑定选择销售方下拉框改变事件
    $("#ChooseSales_0").change(function () {
        app.ajax.regEvent("chooseSales");
        app.ajax.addParam("ord", this.value);
        var arr = app.ajax.send();
        $("#InvoiceCode_0").empty();
        if ($("#SubentryType_0").val() == 2 || $("#SubentryType_0").val() == 3 || $("#SubentryType_0").val() == 4) {
            $("#InvoiceCode_0").append("<option value='-2'></option>");
        } else {
            if ($("#SubentryType_0").val() == 1) {
                $("#InvoiceCode_0").next().text("全部");
            } else {
                $("#InvoiceCode_0").next().text("发票类型");
            }
        }
        $("#InvoiceCode_0").append("<option value='-1'>全部</option>");
        var item = arr.split(",");
        for (var i = 0; i < item.length; i++) {
            $("#InvoiceCode_0").append("<option value='" + item[i] + "'>" + GetInvoiceTypeOptionsName(item[i]) + "</option>");
        }
    });
});

//获取发票类型名称
function GetInvoiceTypeOptionsName(id) {
    var name = "";
    switch (id) {
        case "2":
            name = "纸质普票";
            break;
        case "0":
            name = "纸质专票";
            break;
        case "51":
            name = "电子普票";
            break;
        case "220":
            name = "纸质农产品收购普票";
            break;
        case "200":
            name = "纸质农产品收购专票";
            break;
        case "251":
            name = "电子农产品收购普票";
            break;
        case "320":
            name = "纸质成品油普票";
            break;
        case "300":
            name = "纸质成品油专票";
            break;
        case "351":
            name = "电子成品油普票";
            break;
    }
    return name;
}

//分项统计检索条件切换
function subentryTypeChange() {
    if ($("#SubentryType_0").val() == 1) {
        //$("#InvoiceCode_0 option[value='-2']").remove();
        $("#InvoiceCode_0").parent().show();
        $("#InvoiceCode_0").get(0).selectedIndex = 0;
        $("#SearchValue_0").hide();
        $("#SearchValue_0").val("");
    } else {
        //$("#InvoiceCode_0").prepend("<option value='-2'></option>");
        $("#InvoiceCode_0").get(0).selectedIndex = 0;
        $("#InvoiceCode_0").next().text("全部");
        $("#InvoiceCode_0").parent().hide();
        $("#SearchValue_0").show();
    }
}

//切换报表
function statusChange(o) {
    var url = window.SysConfig.VirPath + "SYSN/view/finan/InvoiceManage/MakeOutInvoice/MakeOutInvoiceSummaryList.ashx"
    if (o.value == 2) {
        url = window.SysConfig.VirPath + "SYSN/view/finan/InvoiceManage/MakeOutInvoice/MakeOutInvoiceSummaryDetailList.ashx"
    }
    window.location.href = url;
}

//更新顶部汇总栏
function changeTopCount(zs, zf, fs, ff, csale, date1, date2, itype, path) {
    $('#summary_count_zs')[0].innerText = zs;
    noOpenDetailUrl("summary_count_zs", zs, 1, csale, date1, date2, itype, path);
    $('#summary_count_zf')[0].innerText = zf;
    noOpenDetailUrl("summary_count_zf", zf, 3, csale, date1, date2, itype, path);
    $('#summary_count_fs')[0].innerText = fs;
    noOpenDetailUrl("summary_count_fs", fs, 2, csale, date1, date2, itype, path);
    $('#summary_count_ff')[0].innerText = ff;
    noOpenDetailUrl("summary_count_ff", ff, 4, csale, date1, date2, itype, path);
}

//顶部汇总穿透
function noOpenDetailUrl(objName, num, type, csale, date1, date2, itype, path) {
    if (num == 0) {
        $("#" + objName).parent().attr("disabled", true).css("pointer-events", "none");
    } else {
        var url = "app.OpenUrl('" + path + "SYSN/view/finan/InvoiceManage/MakeOutInvoice/MakeOutInvoiceSummaryDetailList.ashx?lType=" + type + "&csale=" + csale + "&date1=" + date1 + "&date2=" + date2 + "&itype=" + itype + "','','','')";
        $("#" + objName).parent().attr("onclick", url);
        $("#" + objName).parent().attr("disabled", false).css("pointer-events", "auto");
    }
}

//明细金额穿透
function InitOpenDetailPage(path, ltype, money, rate, csale, date1, date2, itype) {
    if (money == "-") {
        return money;
    } else {
        if (parseFloat(money) == 0) {
            return "0.00";
        } else {
            var fh = "";
            if (parseFloat(money) < 0) {
                fh = "-";
                money = money.replace("-", "");
            }
            var html = "<a href='javascript:void(0)' style='cursor:pointer;' onclick='app.OpenUrl(&quot;" + path + "SYSN/view/finan/InvoiceManage/MakeOutInvoice/MakeOutInvoiceSummaryDetailList.ashx?lType=" + ltype + "&rate=" + rate + "&csale=" + csale + "&date1=" + date1 + "&date2=" + date2 + "&itype=" + itype + "&quot;,&quot;&quot;,&quot;&quot;,&quot;&quot;)'>" + fh + Str2Money(money) + "</a>";

            return html;
        }
    }
}

//金额格式化处理
var Str2Money = function (s) {
    if (/[^0-9\.]/.test(s))
        return "-";
    s = s.replace(/^(\d*)$/, "$1.");
    s = (s + "00").replace(/(\d*\.\d\d)\d*/, "$1");
    s = s.replace(".", ",");
    var re = /(\d)(\d{3},)/;
    while (re.test(s)) {
        s = s.replace(re, "$1,$2");
    }
    s = s.replace(/,(\d\d)$/, ".$1");
    return s.replace(/^\./, "0.");
}

var isFinish = false;
//同步数据
function SyncMakeOutInoiceProc(EventType) {
    isFinish = false;
    var handleType = "SysReportCallBack";
    var pName = "同步数据";
    var div = CreateDiv(handleType, pName);
    var ext = 0;
    var coutMonth = 1;
    app.ajax.regEvent(EventType);
    app.ajax.addParam("actionname", handleType);
    app.ajax.addParam("__cmdtag", handleType);
    showProcMessage(div, 0, "正在准备" + pName + "，时间可能较长，请稍后 ......", 100, "");
    app.ajax.send(
        function (okmsg) {
            if (okmsg.indexOf("Status:ok") >= 0) {
                showProcMessage(div, 300, "恭喜您，" + pName + "完成！", 100, "");
                app.closeWindow("Do" + handleType, true);
                var msg = okmsg.replace("Status:ok", "").split("|");
                isFinish = true;
                alert(msg[1]);
                window.location.reload();
            } else if (okmsg.indexOf("Status:proc") >= 0) {
                var msg = okmsg.replace("Status:proc", "").split("|");
                var procIndex = parseInt(msg[0]);//当前进度
                var procCount = parseInt(msg[1]);//总进度
                var procMessage = msg[2];//当前进度信息
                var pv = (procIndex / procCount) * 100;
                var pmsg = "正在进行" + pName + "，时间可能较长，请稍后 ......";
                var intro = procIndex + ". " + procMessage;
                pv = (ext + parseInt(pv * 1 / coutMonth)) * 3;
                persent = ext + parseInt(pv / 3 / coutMonth);
                setTimeout(function () { showProcMessage(div, pv, pmsg, persent, intro); }, 1)
            } else {
                showProcMessage(div, 300, okmsg, 100, "");
            }
        },
        function (procmsg) {
            if (procmsg.indexOf("Status:proc") >= 0) {
                var msg = okmsg.replace("Status:proc", "").split("|");
                var procIndex = parseInt(msg[0]);//当前进度
                var procCount = parseInt(msg[1]);//总进度
                var procMessage = msg[2];//当前进度信息
                var pv = (procIndex / procCount) * 100;
                var pmsg = "正在进行" + pName + "，时间可能较长，请稍后 ......";
                var intro = procIndex + ". " + procMessage;
                pv = (ext + parseInt(pv * 1 / coutMonth)) * 3;
                persent = ext + parseInt(pv / 3 / coutMonth);
                setTimeout(function () { showProcMessage(div, pv, pmsg, persent, intro); }, 1)
            }
        },
        function (failmsg) {
            alert(failmsg);
        }
    );
}

function CreateDiv(handleType, PName) {
    var div = app.createWindow("Do" + handleType, PName, { width: 400, height: 140, bgShadow: 15, toolbar: true, closeButton: false, canMove: true, bgcolor: "#f3f3f3" });
    if (app.IeVer != 7) div.style.paddingTop = "20px";
    div.style.textAlign = "center";
    return div;
}

//进度条
function showProcMessage(div, pv, pmsg, persent, intro) {
    if (isFinish) return;
    div.innerHTML = "<div style='float:left;margin:0 auto;margin-left:20px;width:300px;height:16px;padding-top:0px;border:1px solid #aaa;" + (app.IeVer == 7 ? "margin-top:20px;" : "") + "background-color:white'>"
                        + "<div style='background-color:#2d8dd9;height:100%;overflow:hidden;width:" + pv + "px'>&nbsp;</div>"
                        + "</div>"
                        + "<div style='float:left;padding-left:5px;" + (app.IeVer == 7 ? "margin-top:20px;" : "") + "padding-top:2px;'>(" + persent + "%)</div>"
                        + "<div style='clear:both;margin:0 auto;width:300px;text-align:left;padding-top:6px'>" + pmsg + "</div>"
                        + "<div style='clear:both;margin:0 auto;width:300px;text-align:left;padding-top:6px'>" + intro + "</div>";
}