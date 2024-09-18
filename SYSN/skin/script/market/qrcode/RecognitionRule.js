window.onPictureUploadSuccess = function (field) {
    $("#changeurl_0").val(field.value);
    var event = document.createEvent("HTMLEvents");
    event.initEvent("change", true, true);
    document.querySelector("#changeurl_0").dispatchEvent(event);
}