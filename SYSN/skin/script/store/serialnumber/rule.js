Bill.onDelGroup = function () {
    Bill.CallBack("", "DeleteRuleGroup", false, "DeleteRuleGroup")
}

window.SelectRulePart = function (inx ,SType , dbname , v) {
    $("#SType" + inx+ "_0").val(SType);
    $("#NValue" + inx).val(dbname);
    $("#NValue" + inx).attr("texts", v);
    $("#NValue" + inx + "_tit").val(v);
    app.closeWindow("RulePartSystemField", true);
    $("#NValue" + inx).change();
}

window.DateLayoutSet = function () {
    app.OpenServerFloatDialog("DateLayoutSet", { width: 453, height: 252, YearType: $("#YearType").val(), YearInx: $("#YearInx").val(), YearOpen: $("#YearOpen").val(), MonthInx: $("#MonthInx").val(), MonthOpen: $("#MonthOpen").val(), DayInx: $("#DayInx").val(), DayOpen: $("#DayOpen").val() });
}

window.SureDateLayoutSet = function () {
    $("#YearType").val($("select[id*='@datetype_stype_0_2_0']").val())
    $("#YearInx").val($("select[id*='@datetype_inx_0_3_0']").val());
    $("#YearOpen").val($("input[id*='@datetype_isopen_0_4_0check']:checked").val());

    $("#MonthInx").val($("select[id*='@datetype_inx_1_3_0']").val());
    $("#MonthOpen").val($("input[id*='@datetype_isopen_1_4_0check']:checked").val());

    $("#DayInx").val($("select[id*='@datetype_inx_2_3_0']").val());
    $("#DayOpen").val($("input[id*='@datetype_isopen_2_4_0check']:checked").val());
    app.closeWindow("fldiv_DateLayoutSet", true);
}

window.procSpecPageForClockState = function () {
    $("tr[dbname='addgroup']").css("display", "none");
}