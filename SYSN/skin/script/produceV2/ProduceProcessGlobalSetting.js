window.__PHelp = {
    sczx_pggl_qzll: ("没有领料出库确认，派工/返工单不允许工序汇报、派工送检、入库；"),
}
Bill.LoadEvents.setProdtctExeHeight = function () {
    var h = $("#procdureProgress_sczx_fbg .p3_item_left")[0].style.height.replace("px","");
    $("#subchildparent_sczx_htm .p3_item_cont").height(h - 15);//15-右边容器与左边容器高度差
}