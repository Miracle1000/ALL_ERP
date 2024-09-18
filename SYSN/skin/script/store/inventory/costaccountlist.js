function showContentInfo(dataRow, v, dataType, id) {
    var htmlStr = v;
    var url = "";
    var h = "500";
    if (dataRow.date1 == "{@@SubTalRow@@}") { dataType = "10"; }
    switch (dataType) {
        case "1":
            //入库
            if (id != "0" && parseFloat(v) != 0) {
                url = "../../../../sysa/tongji/hzkc2.asp?kuid=" + app.pwurl(id) + "&datemonth=" + dataRow.date1;
            }
            break;
        case "2":
            //出库
            if (id != "0" && parseFloat(v) != 0) {
                url = "../../../../SYSN/view/store/kuout/Detaillist.ashx?kuid=" + app.pwurl(id) + "&datemonth=" + dataRow.date1;
            }
            break;
        case "3":
            if (id != "0" && parseFloat(v) != 0 && $("#pricemode_0").val()=="2") {
                url = "costAccountPrice.ashx?ord=" + app.pwurl(id) + "&datemonth=" + dataRow.date1;
                h = "600";
            }
            break;
    }
    if (url.length > 0) {
        htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + url + "','newwin" + dataType + "','width=' + 960 + ',height=' + " + h + " + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
    } else if (id == "0" || parseFloat(v) == 0) {
        htmlStr = "<span style='color:#ccc'>" + v + "</span>";
    }
    return htmlStr;
}
