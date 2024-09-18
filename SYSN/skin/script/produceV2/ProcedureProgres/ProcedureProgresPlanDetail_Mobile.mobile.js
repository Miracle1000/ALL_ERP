//处理展开收缩按钮
window.clickmore = function (el) {
  
    var ismore = $(el).attr("ismore");
    if (ismore == "0") {
        $(el).attr("ismore", "1");
        $(".cg-btn-txt").html("收缩");
        $(".cg-arrow").removeClass("cg-down");
        $(".cg-arrow").addClass("cg-up");
        $ID("ismore").value = 1;
        bill.triggerFieldEvent($ID("ismore"), "change");
    } else {
        $(el).attr("ismore", "0");
        $(".cg-btn-txt").html("更多");
        $(".cg-arrow").addClass("cg-down");
        $(".cg-arrow").removeClass("cg-up");
        $ID("ismore").value = 0;
        bill.triggerFieldEvent($ID("ismore"), "change");
    }
}











