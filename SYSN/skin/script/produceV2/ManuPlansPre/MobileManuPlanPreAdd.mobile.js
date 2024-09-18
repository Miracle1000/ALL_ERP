//处理展开收缩按钮
window.clickmore = function (el) {
    var ismore = $(el).attr("ismore");
    if (ismore == "0") {
        $(el).attr("ismore", "1");
        $(".cg-btn-txt").html("收缩");
        $(".cg-arrow").removeClass("cg-down");
        $(".cg-arrow").addClass("cg-up");
        $ID("ismore").value = 1;
        bill.triggerFieldEvent($ID("ismore"), "change");
    } else {
        $(el).attr("ismore", "0");
        $(".cg-btn-txt").html("更多");
        $(".cg-arrow").addClass("cg-down");
        $(".cg-arrow").removeClass("cg-up");
        $ID("ismore").value = 0;
        bill.triggerFieldEvent($ID("ismore"), "change");
    }
}

function curPageDatesSave() {
    $ID("childrefreshEventbox").value = 1;
    bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
}

window.SaveDatesBeforeAtuoCom = function () {
    curPageDatesSave();
}

//手动添加产品按钮
window.getIntoChooseProcPage = function (el) {
    $ID("childrefreshEventbox").value = 1;
    bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
    el.setAttribute("url", info.hosturl + "/mobilephone/salesManage/product/billlist.asp?fromtype=ManuPlanPrebill");
    ui.CZSMLPage(el);
}
////扫描添加按钮
window.getIntoScanfPage = function (el) {
    $ID("childrefreshEventbox").value = 1;
    bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
    el.setAttribute("url", "MobileManuPlanPreBillScan.ashx?fromtype=ManuPlanPreBill");
    setTimeout(function () { ui.CZSMLPage(el); }, 300);
}
//明细单行明细删除按钮回调事件
window.deleteListviewRowForServer = function (lvw, pos) {
    var len = lvw.headers.length;
    var rowData = {};
    var rows = lvw.rows;
    var keyfieldvalue = "";
    for (var i = 0; i < len; i++) {
        if (lvw.headers[i].dbname != "") {
            rowData[lvw.headers[i].dbname] = (lvw.rows[pos][i] != null ? lvw.rows[pos][i] : null);
            if (lvw.headers[i].dbname.toLowerCase() == ("" + lvw.keyfield || "").toLowerCase()) {
                keyfieldvalue = rowData[lvw.headers[i].dbname];
            }
        }
    }
    var parms = new Object();
    parms["buttontext"] = "删除";
    parms["listviewid"] = lvw.id;
    parms["currrowdata"] = app.GetJSON(rowData);
    parms["keyfieldvalue"] = keyfieldvalue;
    app.RegEvent("sys.listview.handlebtnclick", parms);
}
//清空按钮
window.createBtnForSpecGroup = function (btn) {
    return "<div class='bill_txt' onclick='window.clearBtn(this);' action='SysBillCallBack' url='ClearAllPlanMxList'  target='" + (btn.target || "") + "' >" + btn.title + "</div>"
}
window.clearBtn = function (el) {
    var ev = window.event;
    ev.stopPropagation();
    ui.confirm("您确定要清空预生产计划明细?", function (e) {
        if (e.index == 1) {
            var parms = new Object();
            ui.CZSMLPage(el);
        }
    }, info.alertTitle, ["取消", "确定"])
}
window.clearLvwForManuPlanPre = function () {
    var dbsign = $("#MobListView_yujihualist").attr("dbsign");
    bill.clearListViewRows(dbsign, true);
}
//页面绑定回调呈现方式
app.addMessageEvent("childpageclose", function (data, closeWinhwnd) {
    if (closeWinhwnd.indexOf("_mobilemanuplanprebillscan") == -1 && closeWinhwnd.indexOf("geproductbilllistasp") == -1 && closeWinhwnd.indexOf("_mobilemanuplanpreedit") == -1) { return; }
    $ID("childrefreshEventbox").value = 0;
    bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
});
function curPageDatesSave() {
    $ID("childrefreshEventbox").value = 1;
    bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
}
//扫码、手动添加按钮加载函数
window.onBeforePageInit = function () {
    var currweb = plus.webview.currentWebview();
    var zsml = currweb.zsml;
    var jbill = zsml.body.bill;
    var scanfbtn = bill.NetVerGetFieldByDBName(jbill, "ScanfButtonBG");
    if (scanfbtn) {
        if (__currwin.url.indexOf("&view=details") > -1) return;
        scanfbtn.formathtml = "<div style='width:80%;margin:0 auto;'><div id='ScanfButtonBody' class='sales_lvw_btmbtn' onclick='getIntoScanfPage(this)' target='_blank' action='_url'><dl></dl></div>"
            + "<div id='AddButtonBody' class='sales_lvw_btmbtn' onclick='getIntoChooseProcPage(this)' target='_blank' action='_url'><dl></dl></div></div>";
        setTimeout(function () {
            var h = document.documentElement.offsetHeight;
            $("#page-content").css("height", h - 100);
        }, 300)
    }
}

$(function () {
    try {
        var moneybit = __currwin.zsml.header.moneybit;
    } catch (e) { }

    //点击改变chengenum的值 
    window.AfterCChangeNumValue = function (numbox, val) {
        HandleFieldFormul("NumPlan", __currwin.zsml.header.moneybit, null);
    }
})

window.HandleFieldFormul = function (currDBName, mBit, formula) {
    var v = $("#" + currDBName).val() * 1;
    var num1 = $("#NumPlan").val() * 1;
    switch (currDBName) {
      
        case "NumPlan":
            if (formula) {
                var domv = formula.split("=")[0].replace("@", "");
                var backv = formula.split("=")[1];
                var fs = $("input[dbname*='formula_']");
                backv = backv.replace("@NumPlan", num1 * 1);
                for (var i = 0; i < fs.length; i++) {
                    var dbname = new RegExp("\@" + $(fs[i]).attr("dbname"), "g");
                    backv = backv.replace(dbname, ($(fs[i]).val() == "" ? 0 : $(fs[i]).val()));
                }
                $("#" + domv).val(bill.FormatNumber(eval(backv) + "", __currwin.zsml.header.numberbit));
            }
            break;
        default:
            if (formula) {
                var domv = formula.split("=")[0].replace("@", "");
                var backv = formula.split("=")[1];
                var fs = $("input[dbname*='formula_']");
                for (var i = 0; i < fs.length; i++) {
                    $("#copy" + $(fs[i]).attr("dbname")).val(bill.FormatNumber($(fs[i]).val(), __currwin.zsml.header.numberbit));
                    var dbname = new RegExp("\@" + $(fs[i]).attr("dbname"), "g");
                    backv = backv.replace(dbname, ($(fs[i]).val() == "" ? 0 : $(fs[i]).val()));
                }
                if (backv.indexOf("NumPlan") > 0) {
                    var dbname = new RegExp("\@NumPlan", "g");
                    backv = backv.replace(dbname, num1);
                }
                $("#" + domv).val(bill.FormatNumber(eval(backv) + "", __currwin.zsml.header.numberbit));
                HandleFieldFormul(domv, mBit);
            }
            break;
    }
}




