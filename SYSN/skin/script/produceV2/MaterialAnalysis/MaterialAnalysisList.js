var GrossNumChangeLog = function (obj, id) {
    app.ajax.regEvent("ChangeLogDialogData");
    app.ajax.addParam("id", id);
    var result = app.ajax.send();
    if (result == undefined || result == "") return;

    var e = e || window.event;
    app.showServerPopo(e, "ChangeLogDialog", eval("(" + result + ")"), 1, 500);
    $("#ChangeLogDialog").show();
}

var CalcRule = function (obj, id, pid) {
    app.ajax.regEvent("CalcRuleDialogData");
    app.ajax.addParam("id", id);
    app.ajax.addParam("pid", pid);
    var result = app.ajax.send();
    if (result == undefined || result == "") return;

    var e = e || window.event;
    app.showServerPopo(e, "CalcRuleDialogData", eval("(" + result + ")"), 1, 500);
    $("#CalcRuleDialogData").show();
}

var ShowSumInfo = function (obj, id) {
    app.ajax.regEvent("ShowSumInfoDialogData");
    app.ajax.addParam("id", id);
    var result = app.ajax.send();
    if (result == undefined || result == "") return;

    var e = e || window.event;
    app.showServerPopo(e, "ShowSumInfoDialogData", eval("(" + result + ")"), 1, 500);
}

var ShowCurrNumInfo = function (obj, id,CelueID) {
    app.ajax.regEvent("CurrNumInfoDialogData");
    app.ajax.addParam("id", id);
	app.ajax.addParam("CelueID",CelueID);
    var result = app.ajax.send();
    if (result == undefined || result == "") return;
    var e = e || window.event;
    app.showServerPopo(e, "CurrNumInfoDialog", eval("(" + result + ")"), 1, 350);
}