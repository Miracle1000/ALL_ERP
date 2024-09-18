$(function() {
    $(document).on("change", ":checked[name='Type']", function () {
        OnTypeChange();
    })
})

OnTypeChange = function (_this) {
    var type = $(":checked[name='Type']").val();
    app.ajax.regEvent("TypeChange");
    app.ajax.addParam("type1", type);
    app.ajax.send(function () {
        //window.location.reload();
        window.location.href = window.location.href.replace('type=0&', '');
    });
}