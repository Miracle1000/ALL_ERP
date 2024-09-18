window.__lvw_btnhandle_override = function (lvw, pos, ht) {
    if (lvw.id == "sjcpList") {
        if (ht == 1) {
            var fromid = 0;
            var dtype = 0;
            for (var i = 0; i < lvw.headers.length; i++) {
                if (lvw.headers[i].dbname == "FromId") { fromid = i; }
                if (lvw.headers[i].dbname == "Dtype") { dtype = i; }
            }
            if (lvw.rows[pos][dtype] == -1) {
                return false;
            }
            else {
                app.ajax.addParam("RowIndex", pos);
                app.ajax.addParam("FromId", lvw.rows[pos][fromid]);
                Bill.CallBack("BindSJ", "BindSJDataCallBack", false, "");
                SJNumChangeFun(pos, 0);
                return true;
            }
        }
        else if (ht == 2) {
            SJNumChangeFun(pos,1);
            return false;
        }
    }
    return false;
}

function SJNumChangeFun(rowindex, isdel) {
    var obj = Bill.Data;
    var lvw;
    for (var i = 0; i < obj.groups.length; i++) {
        if (obj.groups[i].dbname == "ProductGroup") {
            lvw = obj.groups[i].fields[0].listview;
        }
    }
    var fromid = -1;
    var dtype = -1;
    var sjnum = -1;
    var sjbl = -1;
    var shbl = -1;
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == "FromId") { fromid = i; }
        if (lvw.headers[i].dbname == "Dtype") { dtype = i; }
        if (lvw.headers[i].dbname == "SJNum") { sjnum = i; }
        if (lvw.headers[i].dbname == "sjbl") { sjbl = i; }
        if (lvw.headers[i].dbname == "shbl") { shbl = i; }
    }
    var currfromid = lvw.rows[rowindex][fromid];
    var parentridx = -1;
    var sumnum = 0;
    for (var i = 0; i < lvw.rows.length; i++) {
        if (lvw.rows[i][fromid] == currfromid) {
            if (lvw.rows[i][dtype] == 1 && isdel != 1) {
                sumnum += lvw.rows[i][sjnum] * 1 * lvw.rows[i][sjbl] / lvw.rows[i][shbl];
            }
            else if (lvw.rows[i][dtype] == 0) {
                parentridx = i;
            }
        }
    }
    if (parentridx != -1) {
        __lvw_je_updateCellValue(lvw.id, parentridx, sjnum, sumnum);
    }
}

function SetOpenerLvwData(srcid) {
    var rows = [];
    var data = lvw_JsonData_sjList.rows;
    for (var ii = 0; ii < data.length; ii++) {
        rows[ii] = {};
        for (var i = 0; i < lvw_JsonData_sjList.headers.length ; i++) {
            var h = lvw_JsonData_sjList.headers[i]
            rows[ii][h.dbname] = data[ii][h.i];
        }
    }
    if (opener && opener.Bill) {
        opener.Bill.SendDataFromAutoTable(srcid, rows);
        window.close();
        return;
    }
}

function ShowSJNumDialog(obj,billord) {
    var lvw = lvw_JsonData_sjcpList;
    var ID = obj.parentNode.parentNode.getAttribute("id");
    rowIndex = ID.split("_")[ID.split("_").length - 3];
    var FromId2 = -1;
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == "FromId2") { FromId2 = i; }
    }
    var oolid = lvw.rows[rowIndex][FromId2];
    app.OpenServerFloatDiv('ZBServices.view.SYSN.view.produceV2.OutsourceInspection.AddInspection.GetInspectionItemInfo', { DivWidth: 300, billord: billord, wwmxid: oolid }, '', 1);
}