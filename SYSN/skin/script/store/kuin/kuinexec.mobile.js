//仓库扫描添加按钮
window.getIntoCkScanfPage = function (el) {
    el.setAttribute("url", "../CkScan.ashx?Billtype=kuin");
    ui.CZSMLPage(el);
}
//仓库扫描数据回调
app.addMessageEvent("returnCkData", function (data, closeWinhwnd) {
    if (data) {
        $ID("ck").value = data.ckName;
        $ID("ck_h").value = data.id;
    }
});