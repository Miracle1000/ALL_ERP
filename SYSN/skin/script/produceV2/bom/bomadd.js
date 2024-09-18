//listview单元格值更改
var currRow = -1;
window.onlvwUpdateCellValue = function (lvw, rowindex, cellindex, v, isztlr, islastrow, disrefresh) {
    if (window.event && window.event.type) { disrefresh = false; }
    var cpindex = -1;
    var numindex = -1;
    var blindex = -1;
    if (currRow >= rowindex && currRow != -1) { return; }
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == "protitle") { cpindex = i; }
        if (lvw.headers[i].dbname == "Num") { numindex = i; }
        if (lvw.headers[i].dbname == "bl") { blindex = i; }
    }
    if (cellindex != numindex && cellindex != blindex) { return; }
    var currdeep = lvw.rows[rowindex][cpindex].deepData.length;
    var isroot = currRow == -1;
    if (isroot) { currRow = rowindex; }
    //给当前行赋值
    if (isroot && lvw.id == "childlvw") {
        if (lvw.headers[cellindex].dbname == "Num") {
            var pnum = GetParentNodeNum(lvw, rowindex, cpindex, numindex, currdeep);
            if (pnum > 0)
                __lvw_je_updateCellValue(lvw.id, rowindex, blindex, v / pnum, disrefresh);
        }
        else if (lvw.headers[cellindex].dbname == "bl") {
            var pnum = GetParentNodeNum(lvw, rowindex, cpindex, numindex, currdeep);
            if (pnum > 0)
                __lvw_je_updateCellValue(lvw.id, rowindex, numindex, pnum * v, disrefresh)
        }
    }
    //算下级行
    pnum = lvw.rows[rowindex][numindex];
    for (var i = rowindex + 1; i < lvw.rows.length && lvw.rows[i][cpindex] && currdeep < lvw.rows[i][cpindex].deepData.length; i++) {
        if (lvw.rows[i][cpindex].deepData.length == currdeep + 1) {
            if (lvw.rows[i][blindex] != "" && lvw.rows[i][blindex] != undefined) {
                __lvw_je_updateCellValue(lvw.id, i, numindex, pnum * lvw.rows[i][blindex], disrefresh)
            }
        }
    }

    if (isroot) { currRow = -1; }
}

function GetParentNodeNum(lvw, rowindex, cpindex, numindex, currdeep) {
    for (var i = rowindex - 1; i >= 0; i--) {
        if (lvw.rows[i][cpindex].deepData.length == currdeep - 1) {
            return lvw.rows[i][numindex] || 0;
        }
    }
    var r = $ID("Num_0") ? $ID("Num_0").value : "";
    return r || 1;
}

//___RefreshListViewByJson(lvw);
//根据数量更改listview根节点的值
function NumChangeFun(v) {
    if (v != "" && v != "0") {
        var obj = Bill.Data;
        var lvw;
        for (var i = 0; i < obj.groups.length; i++) {
            if (obj.groups[i].dbname == "childgp") {
                lvw = obj.groups[i].fields[0].listview;
            }
        }
        var cpindex = -1;
        var numindex = -1;
        var blindex = -1;
        for (var i = 0; i < lvw.headers.length; i++) {
            if (lvw.headers[i].dbname == "protitle") { cpindex = i; }
            if (lvw.headers[i].dbname == "Num") { numindex = i; }
            if (lvw.headers[i].dbname == "bl") { blindex = i; }
        }
        for (var i = 0; i < lvw.rows.length; i++) {
            if (lvw.rows[i][cpindex] && lvw.rows[i][cpindex].deepData.length == 0) {
                if (lvw.rows[i][blindex] != "" && lvw.rows[i][blindex] != undefined) {
                    __lvw_je_updateCellValue(lvw.id, i, numindex, (v * lvw.rows[i][blindex]))
                }
                else if (lvw.rows[i][numindex] != "" && lvw.rows[i][numindex] != undefined) {
                    __lvw_je_updateCellValue(lvw.id, i, blindex, (lvw.rows[i][numindex] / v))
                }
            }
        }
    }
}

//产品角色控制
var controlInsert = [];
function DelChildByRole(rowindex, cellindex, wproct, wproctv) {
    var obj = Bill.Data;
    var lvw = window["lvw_JsonData_childlvw"];
    for (var i = 0; i < obj.groups.length; i++) {
        if (obj.groups[i].dbname == "childgp") {
            lvw = obj.groups[i].fields[0].listview;
        }
    }
    if (lvw.rows[rowindex][cellindex] == undefined) { return; }
    var cpindex = -1;
    var cpidindex = -1;
    var wproctxt = -1;
    var wproc = -1;
    var roleidx = -1;
    var childidx = -1;
    var childTxtidx = -1;
    var hroleidx = -1;
    var bomtype = -1;
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == "protitle") { cpindex = i; }
        if (lvw.headers[i].dbname == "ProductID") { cpidindex = i; }
        if (lvw.headers[i].dbname == "WPROCTxt") { wproctxt = i; }
        if (lvw.headers[i].dbname == "WPROC") { wproc = i; }
        if (lvw.headers[i].dbname == "Role") { roleidx = i; }
        if (lvw.headers[i].dbname == "ChildTxt") { childTxtidx = i; }
        if (lvw.headers[i].dbname == "ChildID") { childidx = i; }
        if (lvw.headers[i].dbname == "HRole") { hroleidx = i; }
        if (lvw.headers[i].dbname == "bomtype") { bomtype = i; }
    }
    var RoleVal = "";
    if (app.isObject(lvw.rows[rowindex][roleidx])) {
        RoleVal = parseInt(lvw.rows[rowindex][roleidx].fieldvalue.toString());
    } else {
        RoleVal = parseInt(lvw.rows[rowindex][roleidx].toString())
    }
    if (lvw.rows[rowindex][childidx] != undefined && RoleVal != 2 && ((lvw.rows[rowindex][childidx].toString() == "0" || lvw.rows[rowindex][childidx] == null) || lvw.rows[rowindex][bomtype].toString() != "0")) {
        lvw.rows[rowindex][hroleidx] = lvw.rows[rowindex][roleidx];
        controlInsert[rowindex] = 0;
        lvw.ui.caninsert = true;
        if (lvw.updateProcDisrefresh != true) { ___RefreshListViewByJson(lvw); }
        return;
    }
    var selconfirm = "";
    var comfirm_a = "选择外购件会清除产品下方所有子件信息，是否确定？";
    var confirm_b = "引用虚拟BOM会清除产品下方所有子件信息，是否确定？";
    if (lvw.headers[cellindex].dbname == "ChildTxt")
        selconfirm = confirm_b;
    else if (RoleVal == 2)
        selconfirm = comfirm_a;
    var currdeep = lvw.rows[rowindex][cpindex].deepData.length;
    var count = lvw.rows[rowindex][cpindex].count;
    var rows = lvw.rows;
    var VRows = lvw.VRows;
    var obj = lvw.rows[rowindex][cpindex];
    if (lvw.rows[rowindex + 1][cpindex] && currdeep < lvw.rows[rowindex + 1][cpindex].deepData.length && selconfirm != "") {
        if (confirm(selconfirm)) {
            controlInsert[rowindex] = 1;
            lvw.rows[rowindex][hroleidx] = lvw.rows[rowindex][roleidx];
            if (count > 0) {
                var cpindex = -1;
                for (var i = 0; i < lvw.headers.length; i++) {
                    if (lvw.headers[i].dbname == "protitle") { cpindex = i; }
                }
                var deleteRow = [];//记录所要删除的节点index,并记录下当前节点
                var count = 0;
                for (var i = rowindex + 1; i < rows.length; i++) {
                    if (rows[i][0] == "\1\1\1NewRowSign\1\1\1") { break; }
                    var son = rows[i][cpindex];
                    if (son.deepData && son.deepData.length > obj.deepData.length) {
                        if (son.deepData.length == obj.deepData.length + 1) {
                            count += 1;
                        }
                        deleteRow.push(i);
                    } else {
                        break;
                    }
                }
                var Ishas = [];//构建与rows是否显示的标识数组
                for (var i = 0; i < rows.length; i++) {
                    var _is = false;
                    for (var ii = 0; ii < VRows.length; ii++) {
                        if (i == VRows[ii]) { _is = true; break; }
                    }
                    if (_is) {
                        Ishas.push(1)
                    } else {
                        Ishas.push(0);
                    }
                }
                //rows
                for (var i = rows.length - 1; i >= 0; i--) {
                    for (var j = 0; j < deleteRow.length; j++) {
                        if (i == deleteRow[j]) {
                            rows.splice(i, 1);
                            Ishas.splice(i, 1);
                        }
                    }
                }

                //重构建VRows
                VRows = [];
                lvw.page.recordcount = 0;
                for (var i = 0; i < rows.length; i++) {
                    if (Ishas[i] == 1) {
                        VRows.push(i);
                        lvw.page.recordcount++;
                    }
                }
                //维护本级节点
                obj.count -= count;
                lvw.VRows = VRows;
                lvw.rows = rows;
            }
            __lvw_je_updateCellValue(lvw.id, rowindex, wproctxt, wproctv, lvw.updateProcDisrefresh);
            __lvw_je_setcelldatav(lvw, rowindex, wproc, wproct);
        } else {
            controlInsert[rowindex] = 0;
            //产品角色改回原值
            __lvw_je_setcelldatav(lvw, rowindex, roleidx, lvw.rows[rowindex][hroleidx]);
            //应用BOM改回原值
            __lvw_je_setcelldatav(lvw, rowindex, childidx, "");
            __lvw_je_setcelldatav(lvw, rowindex, childTxtidx, "");
        }
    } else {
        controlInsert[rowindex] = 1;
        lvw.ui.caninsert = false;
        __lvw_je_updateCellValue(lvw.id, rowindex, wproctxt, wproctv, lvw.updateProcDisrefresh);
        __lvw_je_setcelldatav(lvw, rowindex, wproc, wproct);
    }
    if (lvw.updateProcDisrefresh != true) { ___RefreshListViewByJson(lvw); }
}

window.onDisplayListViewCell = function (lvw, h, rowindex, cellindex) {
    if ((h.dbname == "protitle") && lvw.id == "childlvw") {
        var roleindex = -1;
        var bomindex = -1;
        for (var i = 0; i < lvw.headers.length; i++) {
            if (lvw.headers[i].dbname == "Role") { roleindex = i; }
            if (lvw.headers[i].dbname == "ChildID") { bomindex = i; }
        }
        var sel = "";
        if (app.isObject(lvw.rows[rowindex][roleindex])) {
            sel = lvw.rows[rowindex][roleindex].fieldvalue;
        } else {
            sel = lvw.rows[rowindex][roleindex];
        }
        var bom = 0;
        if (app.isObject(lvw.rows[rowindex][bomindex])) {
            bom = lvw.rows[rowindex][bomindex].fieldvalue;
        } else {
            bom = lvw.rows[rowindex][bomindex];
        }
        if (controlInsert[rowindex] == undefined) { //初次进入根据信息给标识附初始值
            controlInsert[rowindex] = (sel == "2" || bom > 0 ? 1 : 0);
        }
        if ((controlInsert[rowindex] == 1 && (sel == "2" || bom > 0)) || sel == "3") {
            lvw.ui.caninsert = false
        } else {
            lvw.ui.caninsert = true;
            lvw.ui.canadd = true;
        }
    }
}

function GetChildBtnCallBack(v) {
    $("#BLID_0").val(v);
    Bill.CallBack("AAAAA", "GetChildCallBack", false, "");
}

function UpdateAutocomplete(lvwDbname, title, nlvw) {
    var cpindex = -1;
    var lvw = window[lvwDbname];
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == title) { cpindex = i; break; }
    }
    lvw.headers[cpindex].autocomplete = (nlvw.headers[0].autocomplete);
}