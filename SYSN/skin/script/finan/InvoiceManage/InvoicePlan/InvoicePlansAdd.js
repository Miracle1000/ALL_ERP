var OnInvoiceTitleClick = function (_company) {
    app.ajax.regEvent("ShowInvoiceTitles");
    app.ajax.addParam("company", _company);
    var result = app.ajax.send();

    var e = window.event;
    app.showServerPopo(e, "InvoiceTitlesDialog", eval("(" + result + ")"), 1, 400);
};

var closeDialog = function () {
    $("#InvoiceTitlesDialog .closeBtn").trigger("click")
}

var updateInvoiceTitleInfo = function (title, taxno, phone, addr, bank, bankAcc) {
    $("#title_0").val(title);
    $("#taxno_0").val(taxno);
    $("#phone_0").val(phone);
    $("#addr_0").val(addr);
    $("#bank_0").val(bank);
    $("#account_0").val(bankAcc);
}