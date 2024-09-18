function ALLAbutmentDataHandle() {
    app.OpenServerFloatDialog("LoadAbutmentVoucherDataPage", { width: 300, height: 200, EventType: "ALLAbutmentDataHandleProc", PName: "全部生成", IDs: "" }, "", 1);
}
window.ReportProcBatchBtn = function (result, btn) {
    var __BatCommandTitle = btn.innerHTML;
    var vals = app.GetJSON(result.keyvalues);
    vals = vals.replace(/\"/g, '').replace(/\[|\]/g, '');
    var val = vals.split(",");
    var idInx = 0;
    var clsInx = -1;
    var inx = -1;
    if (ListView.GetHeaderByDBName(window.lvw_JsonData_MainList, window.lvw_JsonData_MainList.keyfield) != null)
        idInx = ListView.GetHeaderByDBName(window.lvw_JsonData_MainList, window.lvw_JsonData_MainList.keyfield).i;
    if (ListView.GetHeaderByDBName(window.lvw_JsonData_MainList, "clsid") != null)
        clsInx = ListView.GetHeaderByDBName(window.lvw_JsonData_MainList, "clsid").i;
    if (ListView.GetHeaderByDBName(window.lvw_JsonData_MainList, "clstype") != null)
        inx = ListView.GetHeaderByDBName(window.lvw_JsonData_MainList, "clstype").i;
    var ids = "";
    var clsid = "";
    var clstype = "";
    
    if (result.keyvalues.length == result.rows.length) {//如果有keyfield值相同的行会自动被去重
        for (var i = 0; i < val.length; i++) {
            var x = val[i].split(".");
            ids += (x[0] + ",");
            if (x.length > 1)
                clsid += (x[1] + ",");

            clstype += (inx >= 0 ? result.rows[i][inx] : "") + ",";

        }
    } else {
        for (var i = 0; i < result.rows.length; i++) {
            ids += result.rows[i][idInx] + ",";
            clsInx += (inx >= 0 ? result.rows[i][clsInx] : "") + ",";
            clstype += (inx >= 0 ? result.rows[i][inx] : "") + ",";
        }
    }
    ids = ids.substring(0, ids.lastIndexOf(','));
    clsid = clsid.substring(0, clsid.lastIndexOf(','));
    clstype = clstype.substring(0, clstype.lastIndexOf(','));

    switch (__BatCommandTitle) {
        case "批量生成":
            app.OpenServerFloatDialog("LoadAbutmentVoucherDataPage", { width: 300, height: 200, EventType: "BatchAbutmentDataHandleProc", PName: "批量生成", IDs: ids, clsid: clsid, clstype: clstype }, "", 1);
            return true;
        case "批量删除":
            app.ajax.regEvent("ReportBatchHandle");
            app.ajax.addParam("__SelectKeyValues", app.GetJSON(result.keyvalues));
            app.ajax.addParam("__BatCommandKey", btn.getAttribute("buttonname"));
            app.ajax.addParam("__BatCommandTitle", btn.innerHTML);
            app.ajax.addParam("__LvwStateView", window.lvw_JsonData_MainList.viewstate);
            app.ajax.addParam("__LvwCheckBoxDBName", window.lvw_JsonData_MainList.ui.checkboxdbname);
            app.ajax.addParam("ids", ids);
            app.ajax.addParam("clsid", clsid);
            app.ajax.addParam("clstype", clstype);
            app.ajax.send(Report.ReportBatchHandleProc);
            return true;
    }
    return false;
}

function AbutmentDateModeClick(mode) {
    if (mode == 0) {
        $("#nauto_0check")[0].checked = false;
        $('#btcode').hide();
        $('#btcodetext').text("");
    } else {
        $("#auto_0check")[0].checked = false;
        $('#btcode').show();
    }
}


function AbutmentHandle(EventType, ids, clsid, PName, clstype) {
    var auto = $("#auto_0check")[0].checked;
    var date1 = "";
    if (auto == false) {
        date1 = $("#voucherdate").val();
        if (date1.length == 0) date1 = $("#voucherdate")[0].value;
        if (date1.length == 0) {
            $('#btcodetext').text("必填");
            return;
        }
    }
    var intro = $("#intro_0").val();
    if ($("#btintro").text().length > 0) {
        76
        if (intro.length == 0) {
            $('#btintrotext').text("必填");
            return;
        }
    }
    app.closeWindow("fldiv_LoadAbutmentVoucherDataPage");
    var div = CreateDiv(EventType, PName);
    app.ajax.regEvent("SysReportCallBack");
    app.ajax.addParam("actionname", EventType);
    app.ajax.addParam("__cmdtag", EventType);
    if (EventType == "ALLAbutmentDataHandleProc") {
        var StateView = window.lvw_JsonData_MainList.viewstate;
        var CheckBoxDBName = window.lvw_JsonData_MainList.keyfield;
        app.ajax.addParam("__LvwStateView", StateView);
        app.ajax.addParam("__LvwCheckBoxDBName", CheckBoxDBName);
    } else {
        /*var headers = window.lvw_JsonData_MainList.headers;
        var clsid = "";
        for (var i = 0; i < headers.length ; i++) {
            if (headers[i].dbname == "clsid") {
                clsid = "clsid";
                var StateView = window.lvw_JsonData_MainList.viewstate;
                var CheckBoxDBName = window.lvw_JsonData_MainList.keyfield;
                app.ajax.addParam("__LvwStateView", StateView);
                app.ajax.addParam("__LvwCheckBoxDBName", CheckBoxDBName);
            }
        }*/
        app.ajax.addParam("ids", ids);
        app.ajax.addParam("clsid", clsid);
        app.ajax.addParam("clstype", clstype);
    }

    app.ajax.addParam("auto", auto ? "1" : "0");
    app.ajax.addParam("date1", date1);
    app.ajax.addParam("intro", intro);

    var coutMonth = 1;
    var currInx = 1;
    var month = "";
    var isHistory = false;
    app.ajax.send(
        function (okmsg) {
            var intro = okmsg.replace("Status: ok ", "").replace("Status: ALLOK ", "");
            showProcMessage(div, 300, intro.length == 0 ? "恭喜您，" + PName + "完成！" : PName + "完毕", 100, intro);
            if (isHistory) { window.location.reload(); } else {
                try { window.DoRefresh(); } catch (e) {
                    if (intro.length == 0) { window.location.reload(); }
                }
            }
        },
        function (procmsg) {
            if (procmsg.indexOf("Status: ") >= 0) {
                var msg = procmsg.split("Status: ")[1].replace(/\s/g, "").split(".");
                if (msg[0] == "ALL") {
                    isHistory = true;
                    coutMonth = parseInt(msg[1]);
                    return;
                } else if (msg[0] == "CURR") {
                    currInx = msg[1];
                    month = msg[2] + ".";
                    return;
                }
                var ext = 0;
                if (coutMonth > 1) {
                    if (msg[0] == "ok") { return; }
                    ext = parseInt((currInx - 1) / coutMonth * 100);
                }

                var pv = parseInt(msg[0]);
                var pmsg = msg[1];
                var intro = pv + ". " + pmsg;
                var persent = 0;
                if (pv < 10) {
                    pv = (ext + parseInt(pv * 7 / coutMonth)) * 3;
                    persent = ext + parseInt(pv / 3 / coutMonth);
                    pmsg = month + "正在进行" + PName + "，时间可能较长，请稍后 ......"
                } else if (pv == 10) {
                    intro = pv + ". " + msg[1];
                    //var pvs = pmsg.replace("Speed(", "").replace(")", "").split(",");
                    //pv = (ext + parseInt(pv * 7 / coutMonth) + parseInt((pvs[1] / pvs[0]) * 24 / coutMonth)) * 3;
                    pv = (ext + parseInt(pv * 7 / coutMonth)) * 3;
                    persent = ext + parseInt(pv / 3 / coutMonth);
                    pmsg = month + "正在进行" + PName + "，时间可能较长，请稍后 ......"
                } else {
                    pv = ext * 3 + 300 / coutMonth;
                    persent = ext + parseInt(pv / 3 / coutMonth);
                    pmsg = month + "正在进行" + PName + "，时间可能较长，请稍后 ......"
                }
                showProcMessage(div, pv, pmsg, persent, intro);
            }
            else { }
        },
        function (failmsg) {
            alert(failmsg);
        }
    );
}

function CreateDiv(handleType, PName) {
    var div = app.createWindow("Do" + handleType, PName, { width: 400, height: 160, bgShadow: 15, toolbar: true, closeButton: true, canMove: true, bgcolor: "#f3f3f3" },
		function () {
		    try { window.DoRefresh(); } catch (e) {
		        if (intro.length == 0) { window.location.reload(); }
		    }
		}
	);
    if (app.IeVer != 7) div.style.paddingTop = "20px";
    div.style.textAlign = "center";
    return div;
}


function showProcMessage(div, pv, pmsg, persent, intro) {
    div.innerHTML = "<div style='float:left;margin:0 auto;margin-left:20px;width:300px;height:16px;padding-top:0px;border:1px solid #aaa;" + (app.IeVer == 7 ? "margin-top:20px;" : "") + "background-color:white'>"
                        + "<div style='background-color:#2d8dd9;height:100%;overflow:hidden;width:" + pv + "px'>&nbsp;</div>"
                        + "</div>"
                        + "<div style='float:left;padding-left:5px;" + (app.IeVer == 7 ? "margin-top:20px;" : "") + "padding-top:2px;'>(" + persent + "%)</div>"
                        + "<div style='clear:both;margin:0 auto;width:300px;text-align:left;padding-top:6px'>" + pmsg + "</div>"
                        + "<div style='clear:both;margin:0 auto;width:300px;text-align:left;padding-top:6px'>" + intro + "</div>";
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

function WarningMessageDialog(wm) {
    if (!window.Init0001) {
        window.Init0001 = 1;
        var div = app.createWindow('warningMessage', '请注意', { height: 200, bgShadow: 50 });
        var htm = "<div id='costmessage' style='margin:30px 50px 20px 50px'>" + wm + "</div>" +
                   "<div style='margin-left:50px;display:none'>&nbsp;</div>" +
                   "<div style='margin-top:10px' align='center'><button class='zb-button' id='close_btn' onclick=\"app.closeWindow('warningMessage')\">我知道了</button></div>";
        div.innerHTML = htm;
    }
}

function AbutmentMergerRulesHandle() {
    app.OpenServerFloatDialog("LoadAbutmentMergerRulesPage", { width: 500, height: 300 }, "", 1);
}

function SaveMergerRulesHandle(EventType) {
    var data = "{ headers: ["
    var len = window.lvw_JsonData_MergerRulesLvw.headers.length;
    for (var i = 0; i < len; i++) {
        var h = window.lvw_JsonData_MergerRulesLvw.headers[i];
        data += "{name:'" + h.dbname + "', dbtype: '" + h.dbtype.replace('int', 'Int32').replace("text", 'String') + "'} "
        if (i < len - 1) { data += ","; }
    }
    data += "],rows:" + app.GetJSON(window.lvw_JsonData_MergerRulesLvw.rows) + "}";
    app.ajax.regEvent(EventType);
    app.ajax.addParam("listdata", data);
    app.ajax.send(function (r) { app.closeWindow('fldiv_LoadAbutmentMergerRulesPage', true); });
}

function UpdateIsOpenChecked(Merger) {
    var isopenindex = -1;
    for (var i = 0; i < lvw_JsonData_MergerRulesLvw.headers.length; i++) {
        if (lvw_JsonData_MergerRulesLvw.headers[i].dbname == "IsOpen") { isopenindex = i; break; }
    }
    $("#lvw_dbtable_MergerRulesLvw input[type=checkbox]").each(function (i, item) {
        if (i == 0 || Merger == 1)
            $(item).attr("disabled", false);
        else {
            if (lvw_JsonData_MergerRulesLvw.rows[i][4] != "科目分录合并") {
                $(item).attr("disabled", true);
                $(item).attr("checked", false);
                lvw_JsonData_MergerRulesLvw.rows[i][isopenindex] = "";
            }
        }
    })
}