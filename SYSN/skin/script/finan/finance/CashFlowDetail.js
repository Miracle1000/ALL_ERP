function RowsSetting() {
    var StateView = window.lvw_JsonData_MainList.viewstate;
    var CheckBoxDBName = window.lvw_JsonData_MainList.ui.checkboxdbname;
    app.OpenServerFloatDialog("LoadRowSettingPage", { width: 474, height: 222, EventType: "RowsSettingProc", PName: "列设置", IDs: "", __LvwStateView: StateView, __LvwCheckBoxDBName: CheckBoxDBName }, "", 1);
}


function ReductionHandle(EventType,  PName) {
    app.closeWindow("fldiv_LoadAbutmentVoucherDataPage");
    //var div = CreateDiv(EventType, PName);
    app.ajax.regEvent("SysReportCallBack");
    app.ajax.addParam("actionname", EventType);
    app.ajax.addParam("__cmdtag", EventType);
    var auto = $("#auto_1check").val();
    var nauto = $("#nauto_1check").val();
    app.ajax.addParam("auto", auto);
    app.ajax.addParam("nauto", nauto);

    var coutMonth = 1;
    var currInx = 1;
    var month = "";
    var isHistory = false;
    app.ajax.send(
        function (okmsg) {
            var intro = okmsg.replace("Status: ok ", "").replace("Status: ALLOK ", "");
            if (isHistory) { window.location.reload(); } else {
                try { window.DoRefresh(); } catch (e) {
                    if (intro.length == 0) { window.location.reload(); }
                }
            }
        }

    );
}

window.LoadSimpleBillBottomBtnsHtmls = function (obj, valign) {
    var cmdbuttons = obj.cmdbuttons || obj.commandbuttons;
    if (!cmdbuttons) { return ""; }
    var html = new Array();
    for (var i = 0; i < cmdbuttons.length; i++) {
        var btn = cmdbuttons[i];
        var str = "";
        if (btn.disable == true) {
            str = 'disabled="disabled"'
        }
        if ((valign == "top" && btn.visible == true) || (valign == "bottom" && btn.bottomvisible == true)) {
            btn.eventsignkey = ("Btn" + parseInt(Math.random() * 1000000));
            btn.cmdkey = (btn.cmdkey || "");
            btn.tag = (btn.tag || "");
            var urlattr = btn.openurlattrs || "";
            if (urlattr.length > 0) { urlattr = " openurlattrs=\"" + urlattr + "\" "; }
            html.push("<button " + urlattr + " servercbkasync=" + (btn.servercbkasync == true ? 1 : 0) + "  type='button' " + str + "  id='" + btn.dbname + "_btn' dbname='" + btn.dbname + "'  onclick='" + btn.cmdkey + "' class='" + (btn.uitype == "label" ? "zb-buttonlable" : "zb-button") + (btn.cssname ? " " + btn.cssname : "") + "'>" + btn.title + "</button>");
        }
    }
    return html.join("");
}

if (!window.assistlist) { window.assistlist = new Object(); }
assistlist.RowsSetting = function (nodeid, ptype) {
    app.closeWindow("AddAssistListNode");
    var win = app.createWindow("AddAssistListNode", "列设置", {
        width: 430,
        height: 235,
        closeButton: true,
        maxButton: false,
        minButton: false,
        canMove: true,
        sizeable: false
    });
    // result为json 格式是bill单据 包含主题和2个字段view\finan\finance\Assist
    win.innerHTML = "<iframe frameborder='0' scrolling=0 src='" + window.SysConfig.VirPath + "SYSN/view/finan/finance/AccountTables/RowSettingPage.ashx?userid=" + nodeid + "&pageType=" + ptype + "' width=\"400\" height=\"185\"> ";
}



