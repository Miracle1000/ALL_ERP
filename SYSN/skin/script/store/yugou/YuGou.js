window.onlvwUpdateCellValue = function (lvw, rowindex, cellindex, v, isztlr, isEof, disrefresh, oldvalue) {
    if (window.___Refreshinglvw == true) return;
    if (window.IsListviewAddRows == true) return;
    if (oldvalue == v) { return; }
    var header = lvw.headers[cellindex];
    var dbname = header.dbname;
    if (v == undefined || v == null || v == "") { v = 0 }
    if (lvw.id == "yugoulist") {
        var num1 = lvw.rows[rowindex][ListView.GetHeaderByDBName(lvw, "Num1").i];
        switch (dbname) {
            //数量
            case "Num1":
                CurrFormulaInfoHandle(lvw, rowindex, cellindex, "commUnitAttr", num1);
                break;
          
        }
    }
}