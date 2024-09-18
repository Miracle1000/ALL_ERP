LeftPage.SsTableTDClick = function (id, index, len) {
    LeftPage.OnPageResizeExec();//切换时计算对应的树的高度避免出现纵向滚动条
    var title = $ID("reportlefttopbar_" + id + "_" + index).innerText;
    if (title.indexOf("生产派工") >= 0 && title.indexOf("生产返工") >= 0) {
        window.location.href = "?index=" + index;
    }
    if (title.indexOf("生产派工") >= 0 && title.indexOf("生产返工") < 0) {
        window.location.href = "?index=" + 0;
    }
    if (title.indexOf("生产派工") < 0 && title.indexOf("生产返工") >= 0) {
        window.location.href = "?index=" + 1;
    }
}

window.OnBillLoad = function () {
    var index = window.location.href.indexOf("&index=1") > 0 ? 1 : 0;
    var len = 2;
    var id = "sdksyscoreLeftpage";
    for (var i = 0; i < len; i++) {
        var dispay = index == i ? "" : "none";
        if ($ID("reportlefttopbar_" + id + "_" + i)) {
            $ID("reportlefttopbar_" + id + "_" + i).style.display = dispay;
            if ($ID("jsdiv_" + id + "_" + i)) { $ID("jsdiv_" + id + "_" + i).style.display = dispay; }
            $ID("leftpgtreebar_" + id + "_" + i).style.display = dispay;
            $ID("treebox_" + id + "_" + i).style.display = dispay;
            var daysbox = $ID("daysdiv_" + id + "_" + i);
            if (daysbox) { daysbox.style.display = dispay; }
        }
    }
}
