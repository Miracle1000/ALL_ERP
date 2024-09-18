//库存信息列选择仓库
function KuinfoChooseck(ck, obj) {
    var lvwid = getlvwid();

    var jlvw = window['lvw_JsonData_' + lvwid];
    var cellindex = ListView.GetHeaderByDBName(jlvw, "rowindex").i;
    var CKcellindex = ListView.GetHeaderByDBName(jlvw, "ck").i;
    var td = $(obj).parents('td[dbcolindex]:eq(0)')[0];
    var tr = td.parentNode;
    var rowindex = parseInt(tr.getAttribute('pos'));
    jlvw.rows[rowindex][CKcellindex].fieldvalue = ck;
    __lvw_je_redrawCell(jlvw, jlvw.headers[CKcellindex], rowindex, jlvw.headers[CKcellindex].showindex);
    $($ID("@" + lvwid + "_ck_" + rowindex + "_" + CKcellindex + "_0")).change();
}

//手动拆分
function OpenUrlSplit(ord, unit, ck, inx, moreunit, attr1, attr2, obj) {
    var td = $(obj).parents('td[dbcolindex]:eq(0)')[0];
    var tr = td.parentNode;
    var rowindex = parseInt(tr.getAttribute('pos'));

    var lvwid = getlvwid();
    var jlvw = window['lvw_JsonData_' + lvwid];
    var num1cellindex = ListView.GetHeaderByDBName(jlvw, "num1").i;
    var attr1inx = ListView.GetHeaderByDBName(jlvw, "ProductAttr1").i;
    var attr2inx = ListView.GetHeaderByDBName(jlvw, "ProductAttr2").i;
    attr1 = jlvw.rows[rowindex][attr1inx];
    attr2 = jlvw.rows[rowindex][attr2inx];
    var num1 = jlvw.rows[rowindex][num1cellindex]
    app.OpenUrl(window.SysConfig.VirPath+"SYSN/view/store/kuout/KuAppointSplit.ashx?productid=" + app.pwurl(ord) + "&unit=" + app.pwurl(unit) + "&ck=" + ck + "&inx=" + rowindex + "&moreunit=" + moreunit + "&attr1=" + attr1 + "&attr2=" + attr2 + "&cfnum1=" + num1 + "", 'cf');
}

window.CheckCK = function (lvwid, ck, inx) {
    lvwid = getlvwid();
    var jlvw = window['lvw_JsonData_' + lvwid];
    var rowindex = inx;
    var CKcellindex = ListView.GetHeaderByDBName(jlvw, "ck").i;
    jlvw.rows[rowindex][CKcellindex].fieldvalue = ck;
    __lvw_je_redrawCell(jlvw, jlvw.headers[CKcellindex], rowindex, jlvw.headers[CKcellindex].showindex);
    $($ID("@" + lvwid + "_ck_" + rowindex + "_" + CKcellindex + "_0")).change();
    $(".createWindow_popoBox").remove()
}
//超3行库存 查看更多
function iframchoosck(ord, unit, attr1, attr2, obj) {
    var lvwid = getlvwid();
    var jlvw = window['lvw_JsonData_' + lvwid];
    var cellindex = ListView.GetHeaderByDBName(jlvw, "rowindex").i;
    var CKcellindex = ListView.GetHeaderByDBName(jlvw, "ck").i;
    var td = $(obj).parents('td[dbcolindex]:eq(0)')[0];
    var tr = td.parentNode;
    var rowindex = parseInt(tr.getAttribute('pos'));
    app.OpenServerFloatDiv("ZBServices.view.SYSN.mdl.sales.ProductModule.ShowStoreInfo", { DivWidth: 765, productid: ord, inx: rowindex, unit: unit, ProductAttr1: attr1, ProductAttr2: attr2 }, "", 1);
}

//查看更多库存信息点击拆分
function OpenUrlToKuAppointSplit(ck, unit, moreunit, ord, inx) {
    var lvwid = getlvwid();
    var jlvw = window['lvw_JsonData_' + lvwid];
    var num1cellindex = ListView.GetHeaderByDBName(jlvw, "num1").i;
    var attr1inx = ListView.GetHeaderByDBName(jlvw, "ProductAttr1").i;
    var attr2inx = ListView.GetHeaderByDBName(jlvw, "ProductAttr2").i;
    attr1 = jlvw.rows[inx][attr1inx];
    attr2 = jlvw.rows[inx][attr2inx];
    var num1 = jlvw.rows[inx][num1cellindex]
    app.OpenUrl("../../../SYSN/view/store/kuout/KuAppointSplit.ashx?productid=" + app.pwurl(ord) + "&unit=" + app.pwurl(unit) + "&ck=" + ck + "&inx=" + inx + "&moreunit=" + moreunit + "&attr1=" + attr1 + "&attr2=" + attr2 + "&cfnum1=" + num1 + "", 'cf');
}

function lvwchangekuinfobyck(inx) {
    //加载行库存
    var rowindex = inx;
    var lvwid = getlvwid();
    var jlvw = window['lvw_JsonData_' + lvwid];
    var cellindex = ListView.GetHeaderByDBName(jlvw, "rowindex").i;
    var CKcellindex = ListView.GetHeaderByDBName(jlvw, "ck").i;
    $($ID("@" + lvwid + "_ck_" + rowindex + "_" + CKcellindex + "_0")).change();
    $(".createWindow_popoBox").remove();
    try {
        var date5 = $("#date5").val();
        if (date5.length >= 10) {
            date5 = date5.substring(0, 10) + " " + ((new Date()).toTimeString()).substring(0, 8);
            $("#date5").val(date5);
        }
    } catch (e) { }
}