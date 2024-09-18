var ShowDbInfo = function (obj, id) {
    app.ajax.regEvent("DbInfoDialogData");
    app.ajax.addParam("id", id);
    var result = app.ajax.send();
    if (result == undefined || result == "") return;
    var e = e || window.event;
    app.showServerPopo(e, "DbInfoDialog", eval("(" + result + ")"), 1, 750);
}