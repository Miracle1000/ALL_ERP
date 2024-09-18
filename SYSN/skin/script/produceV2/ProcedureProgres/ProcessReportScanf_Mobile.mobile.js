window.onBeforePageInit = function () {
    var currweb = plus.webview.currentWebview();
    var zsml = currweb.zsml;
    var jbill = zsml.body.bill;

    var vendor = plus.device.vendor == "alps";    //判断PDA标识
    var isStart = window.IsStart;
    var scanfbtn = bill.NetVerGetFieldByDBName(jbill, "ScanfButtonHtml");
    scanfbtn.formathtml = "<div style='width:80%;margin:0 auto;text-align:center;'>"
        + (vendor ? "" : "<div id='ScanfButtonBody' class='sales_lvw_btmbtn' onclick='getIntoScanfPage(this)' target='_blank' action='_url'><dl></dl></div>")
        + (isStart == 1 ? "" : "<div id='AddButtonBody' class='sales_lvw_btmbtn' onclick='getIntoChooseProcPage(this)' target='_blank' action='_url'><dl></dl></div>")
        + "</div>";
    setTimeout(function () {
        var h = document.documentElement.offsetHeight;
        $("#page-content").css("height", h - 100);
    }, 300)
}

//扫描添加按钮
window.getIntoScanfPage = function (el) {
    var cateid = "";
    var wpid = "";
    var machineID = "";
    var scanfType = "";
    app.getPostDatas(function (dbname, v) {
        if (dbname == "Cateid") { cateid = v; }
        if (dbname == "Wpid") { wpid = v; }
        if (dbname == "MachineID") { machineID = v; }
        if (dbname == "ScanfType") { scanfType = v; }
    }, "post");
    if (cateid == "") cateid = "0";
    el.setAttribute("url", "ProcessReportScanfStart_Mobile.ashx?cateid=" + cateid + "&wpid=" + wpid + "&machineID=" + machineID + "&isStart=" + scanfType);
    ui.CZSMLPage(el);
}

//触发手动选择
window.getIntoChooseProcPage = function (el) {
    document.getElementById("WpName").click()
}

//工序扫描添加按钮
window.getIntoGXScanfPage = function (el) {
    el.setAttribute("url", "GXScan.ashx");
    ui.CZSMLPage(el);
}

//人员扫描添加按钮
window.getIntoRYScanfPage = function (el) {
    el.setAttribute("url", "RYScan.ashx");
    ui.CZSMLPage(el);
}

//工序扫描数据回调
app.addMessageEvent("returnCkData", function (data, closeWinhwnd) {
    if (data) {
        $ID("Wpid").value = data.WPName;
        $ID("Wpid_h").value = data.id;
    }
});

//人员扫描数据回调
app.addMessageEvent("returnRYData", function (data, closeWinhwnd) {
    if (data) {
        $ID("Cateid").value = data.name;
        $ID("Cateid_h").value = data.id;
    }
});