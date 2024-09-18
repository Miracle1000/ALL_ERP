function iframchoosck(ord, unit,attr1,attr2, obj) {
    var jlvw = window['lvw_JsonData_kuoutlist'];
    var cellindex = ListView.GetHeaderByDBName(jlvw, "@indexcol").i;
    var CKcellindex = ListView.GetHeaderByDBName(jlvw, 'ck').i;
    var td = $(obj).parents('td[dbcolindex]:eq(0)')[0];
    var tr = td.parentNode;
    var rowindex = parseInt(tr.getAttribute('pos'));

    app.OpenServerFloatDiv('ZBServices.view.SYSN.mdl.sales.ProductModule.ShowStoreInfo', { DivWidth: 765, productid: ord, inx: rowindex, unit: unit,ProductAttr1:attr1,ProductAttr2:attr2, noOperate:1 }, '', 1);
}

function getlvwid() {
    return "kuoutlist";
}

function updatelvwcellzd(num1, inx) {
    var rowindex = inx;
    var lvwid = getlvwid();

    var jlvw = window['lvw_JsonData_' + lvwid];
    var idindex = ListView.GetHeaderByDBName(jlvw, "id").i;
    var cellindex = ListView.GetHeaderByDBName(jlvw, "rowindex").i;
    var CKcellindex = ListView.GetHeaderByDBName(jlvw, "cktype").i;
    var zdnumindex = ListView.GetHeaderByDBName(jlvw, "zdnum").i;
    var zdnumv = "已指定：" + app.FormatNumber(num1, "numberbox") + "";
    zdnumv = num1 == "" ? "" : zdnumv;
    if (num1 === "") {
        //点击随机inx就是当前行号
        app.ajax.regEvent("deletekuoutlit2");
        app.ajax.addParam("rowindex", jlvw.rows[inx][cellindex]);
        app.ajax.addParam("kuoutlistID", jlvw.rows[inx][idindex]);
        var r = app.ajax.send();
    }
    else {
        for (var i = 0; i < jlvw.rows.length; i++) {
            if (jlvw.rows[i][cellindex] == inx) rowindex = i;
        }
    }
    $($ID("@" + lvwid + "_cktype_" + rowindex + "_" + CKcellindex + "_div")).nextAll('div').text(zdnumv)
    jlvw.rows[rowindex][zdnumindex] = zdnumv;
}

window.onlvwUpdateCellValue = function (lvw, rowindex, cellindex, v, isztlr, isEof, disrefresh, oldvalue) {
    if (window.___Refreshinglvw == true || isztlr == 0) { return; }
    var header = lvw.headers[cellindex];
    var dbname = header.dbname;
    if (dbname == "num1") {
        window.ListViewUnitAttrEdit = false;
        CurrFormulaInfoHandle(lvw, rowindex, cellindex, "commUnitAttr", v, true);
    }
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