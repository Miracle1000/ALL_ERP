function SubjectChangeCallBack(maxCount) {
    if (maxCount > 0)
    {
        for (var index = 0; index < maxCount; index++) {
            $('#serchkey' + index + '_0').val('').trigger('change')
        }
    }
    var EventType = "App_SubjectChange";
    var CelueID = document.all.KJKeMu[1].value;
    app.ajax.regEvent("SysReportCallBack");
    app.ajax.addParam("actionname", EventType);
    app.ajax.addParam("__cmdtag", EventType);
    app.ajax.addParam("AccountSubject", CelueID);
    var r = app.ajax.send();
    if (r) {
        var msg = r.split(";");
        if (msg.length > 0) {
            for (var i = 0; i < msg.length; i++) {
                var assistvalue = msg[i].split(',');
                $('#serchkey' + (assistvalue[0] - 1) + '_0').val(assistvalue[1]).trigger('change')
            }
        }
    }
}