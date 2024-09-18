var ShowDetails = function (obj, id, type) {
    app.ajax.regEvent("ShowDetails");
    app.ajax.addParam("id", id);
    app.ajax.addParam("type", type);
    var result = app.ajax.send();
    if (result == undefined || result == "") return;

    var e = e || window.event;
    app.showServerPopo(e, "ShowDetailsDialogData", eval("(" + result + ")"), 1, 500);
    $("#ShowDetailsDialogData").show();
}

function SetWorkingProcedure() {
    var lvw = window['lvw_JsonData_workflowf'];
    var lvwWL = window['lvw_JsonData_MaterialRegister'];
    if (lvw==undefined ||lvw.rows.length == 0) {
        return;
    }
    if (lvwWL == undefined || lvwWL.rows.length == 0) {
        return;
    }
    var WorkingProcedureIDIndex = -1;
    var WorkingProcedureNameIndex = -1;
    var IDIndex = -1;
    var WFPRowIndexIndex = -1;
    var indexcolIndex = -1;
    for (var i = 0; i < lvw.headers.length; i++) {
       if (lvw.headers[i].dbname == 'WPName' || lvw.headers[i].dbname == 'WPname') {
            WorkingProcedureNameIndex = i;
        } else if (lvw.headers[i].dbname == 'ID') {
            IDIndex = i;
        } else if (lvw.headers[i].dbname == 'WFPRowIndex') {
            WFPRowIndexIndex = i;
        } else if (lvw.headers[i].dbname == '@indexcol') {
            indexcolIndex = i;
        }
    }

    var options = new Array();
    options.push({ "n": "", "v": "0" });

    for (var i = 0; i < lvw.rows.length; i++) {
        if (lvw.rows[i][WorkingProcedureNameIndex] != undefined) {

            var rowindex = i + 1;
            if (lvw.rows[i][indexcolIndex] != undefined) {
                rowindex = lvw.rows[i][indexcolIndex] + 1;
            }
            var ID = -rowindex;
            var WFPRow = lvw.rows[i][WFPRowIndexIndex];
            if (lvw.rows[i][IDIndex] != undefined && parseInt(lvw.rows[i][IDIndex]) > 0) {
                ID = parseInt(lvw.rows[i][IDIndex]);
            } else {
                if (WFPRow != undefined) {
                    if (WFPRow == "" || parseInt(WFPRow) == 0) {
                        if (minRowindex < 0) {
                            ID = minRowindex - 1;
                            minRowindex = ID;
                        }
                    } else {
                        ID = parseInt(WFPRow);
                    }
                }
            }
            var ProcedureName = lvw.rows[i][WorkingProcedureNameIndex];
            if (ProcedureName != undefined && ProcedureName != null) {
                if (ProcedureName.indexOf('<font') > 0) {
                    ProcedureName = ProcedureName.substr(0, ProcedureName.indexOf('<font'));
                }
            }
            var newname = rowindex + "-" + ProcedureName;
            options.push({ "n": "" + newname + "", "v": "" + ID + "" });
            if (WFPRow != undefined) {
                __lvw_je_updateCellValue(lvw.id, i, WFPRowIndexIndex, ID);
            }

        }

    }
    var sourceData = { "options": options, "structtype": "default", "title": "" };
    var WorkingProcedureIDIndex2 = -1;
    for (var i = 0; i < lvwWL.headers.length; i++) {
        if (lvwWL.headers[i].dbname == 'WFPAID') {
            WorkingProcedureIDIndex2 = i;
            lvwWL.headers[i].source = sourceData;
        }
    }
    for (var i = 0; i < lvwWL.rows.length; i++) {
        var WorkingProcedureID = lvwWL.rows[i][WorkingProcedureIDIndex2];
        if (WorkingProcedureID != undefined) {
            lvwWL.rows[i][WorkingProcedureIDIndex2] = { "fieldvalue": WorkingProcedureID, "source": sourceData };
            __lvw_je_updateCellValue(lvwWL.id, i, WorkingProcedureIDIndex2, WorkingProcedureID);
        }
    }
    ___RefreshListViewByJson(lvwWL);

}