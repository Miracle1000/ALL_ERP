function lvwchangekuinfo(inx) {
    window.opener.lvwchangekuinfobyck(inx);
}
//改序列号不刷新数量
window.NoNeedRefreshNum = true;
function GetUnit(value, MoreUnit_IsEditMode) {
    if (value.length == "" || value.length == 0) return "";
    var r = "";
    //value = "{formula:'123',v:{\"长_1_a\":\"G100\",\"宽1_b\":\"G200\",\"高1_c\":\"300\"}}";
    var s = eval("(" + value + ")");
    var formula = s.formula;
    var o = s.v
    var canEditAttr = "";
    var editDefV = "0";

    var jspnstr = "";
    for (var k in o) {
        var v = o[k] + "";
        var s = k.replace(/_/, ",");
        var ss = s.split(",");
        var attrName = ss[ss.length - 1];
        var formulaAttr = ss.splice(0, ss.length - 1).join("_");
        var canEdit = v.indexOf("G") < 0;
        var defv = v.replace("G", "") * 1;
        if (defv == 0) {
            if (k == canEditAttr) {
                defv = editDefV;
            } else {
                defv = MoreUnit_IsEditMode == "1" ? 1 : 0;
            }
        }
        defv = defv.length == 0 || parseFloat(defv) == 0 ? (MoreUnit_IsEditMode == "1" ? 1 : 0) : defv;
        defv = defv * 1;
        defv = defv.toFixed(window.SysConfig.NumberBit)


        if (MoreUnit_IsEditMode == "1") {
            var vttr = canEdit ? "" : "G";
            r += r.length > 0 ? "<br>" : "";
            r += "<span style='float:left;height:20px;line-height:20px;'>" + formulaAttr + "：</span><input uitype='numberbox' formula='" + formula + "' vttk='" + k + "' vttn='" + attrName + "' " + (canEdit ? " vttr='' " : " disabled  vttr='G' ") +
                "   class='billfieldbox cell_" + rowindex + "_" + cellindex + "' dvc='1' nul='1' " +                          
                "   isfield='1' style='width:55%;color:#aaa  name='UnitFormula_" + attrName + "_" + rowindex + "_" + cellindex + "' " +
                "    value='" + defv + "' type='text'>";
        } else {
            r += r.length > 0 ? "<br>" : "";
            r += formulaAttr + "：" + defv;
        }
    }


    r = "<div class='sub-field gray f_numberbox editable' canedit='" + (MoreUnit_IsEditMode == "1" ? "editable" : "") + "' islvw='1' uitype='numberbox'  nul='1'>" + r + "</div>"
    return r;
}
function RkunumChange(rowindex, num3)
{
    var lvw = window['lvw_JsonData_ku'];
    var CKcellindex = ListView.GetHeaderByDBName(lvw, "num3").i;
    window.ListView.ApplyCellUIUpdate(lvw, [rowindex], CKcellindex, 0, num3, "");
    var h = lvw.headers[CKcellindex];
    __lvw_je_redrawCell(lvw, h, rowindex, h.showindex);
    var obj = $($ID("@" + lvw.id + "_num3_" + (parseInt(rowindex)) + "_" + CKcellindex + "_0"))[0];
    __lvw_je_updateCellValue('ku', rowindex, CKcellindex, __lvw_je_getcellAsBF(obj, 'numberbox', 'ku', CKcellindex), true, undefined, true);
    ListView._DCBack(obj, 'ZBServices.view.SYSN.mdl.sales.UnitsHelper.ChangeAssistUnit', 1, 0, '');
    ListView._DCBack(obj, 'client:SetCurrFormulaInfoValue(box,\'commUnitAttr\')', 1, 0, '');
}

window.lvwRedrawCellAfterEvent = function (lvw, h, rowindex, cellIndex) {
    var obj = $($ID("@" + lvw.id + "_" + h.dbname + "_" + (parseInt(rowindex)) + "_" + cellIndex + "_0"))[0]
    ListView._DCBack(obj, 'ZBServices.view.SYSN.mdl.sales.UnitsHelper.ChangeAssistUnit', 1, 0, '')
}

window.onlvwUpdateCellValue = function (lvw, rowindex, cellindex, v, isztlr, isEof, disrefresh, oldvalue) {
    if (oldvalue == v) { return; }
    if (isztlr == 0) return;
    var header = lvw.headers[cellindex];
    var dbname = header.dbname;
    if (v == undefined || v == null || v == "") { v = 0 }
    switch (dbname) {
        case "num3":
            window.ListView.ApplyCellUIUpdate(lvw, [rowindex], cellindex, 0, v, "");
            __lvw_je_redrawCell(lvw, header, rowindex, header.showindex);
            var obj = $($ID("@" + lvw.id + "_num3_" + (parseInt(rowindex)) + "_" + cellindex + "_0"))[0];
            __lvw_je_updateCellValue('ku', rowindex, cellindex, __lvw_je_getcellAsBF(obj, 'numberbox', 'ku', cellindex), true, undefined, true);
            ListView._DCBack(obj, 'client:SetCurrFormulaInfoValue(box,\'commUnitAttr\')', 1, 0, '')
            break;
    }
}
//输入拆出辅助数量
function CfAssinumChange(rowindex, num2) {
    var lvw = window['lvw_JsonData_ku'];
    var CKcellindex = ListView.GetHeaderByDBName(lvw, "num1").i;
    window.ListView.ApplyCellUIUpdate(lvw, [rowindex], CKcellindex, 0, num2, "");
    var h = lvw.headers[CKcellindex];
    __lvw_je_redrawCell(lvw, h, rowindex, h.showindex);
    var obj = $($ID("@" + lvw.id + "_num1_" + (parseInt(rowindex)) + "_" + CKcellindex + "_0"))[0];
    __lvw_je_updateCellValue('ku', rowindex, CKcellindex, __lvw_je_getcellAsBF(obj, 'numberbox', 'ku', CKcellindex), true, undefined, true);
    ListView._DCBack(obj, 'ZBServices.view.SYSN.view.store.kuout.KuAppointSplit.checknum3', 1, 0, '');
    ListView._DCBack(obj, 'client:SetCurrFormulaInfoValue(box,\'commUnitAttr\')', 1, 0, '');
}
//输入拆入数量,计算拆出数量，拆出辅助数量,拆入辅助数量
function Cfnum3Change(rowindex, num1, cfAssinum, AssistNum) {
    var lvw = window['lvw_JsonData_ku'];
    var CKcellindex = ListView.GetHeaderByDBName(lvw, "num1").i;
    var num1cellindex = ListView.GetHeaderByDBName(lvw, "num1").i;//出库数量
    var cfAssinumcellindex = ListView.GetHeaderByDBName(lvw, "cfAssinum").i;//出库辅助数量
    var AssistNumcellindex = ListView.GetHeaderByDBName(lvw, "AssistNum").i;//入库辅助数量
    var h = lvw.headers[num1cellindex];
    var h1 = lvw.headers[cfAssinumcellindex];
    var h2 = lvw.headers[AssistNumcellindex];
    window.ListView.ApplyCellUIUpdate(lvw, [rowindex], num1cellindex, 0, num1, "");
    window.ListView.ApplyCellUIUpdate(lvw, [rowindex], cfAssinumcellindex, 0, cfAssinum, "");
    window.ListView.ApplyCellUIUpdate(lvw, [rowindex], AssistNumcellindex, 0, AssistNum, "");
    __lvw_je_redrawCell(lvw, h, rowindex, h.showindex);
    __lvw_je_redrawCell(lvw, h1, rowindex, h1.showindex);
    __lvw_je_redrawCell(lvw, h2, rowindex, h2.showindex);
    var obj = $($ID("@" + lvw.id + "_num1_" + (parseInt(rowindex)) + "_" + CKcellindex + "_0"))[0];
    ListView._DCBack(obj, 'ZBServices.view.SYSN.view.store.kuout.KuAppointSplit.checknum3', 1, 0, '');
    ___ReSumListViewByJsonData(lvw)
    ___RefreshListViewByJson(lvw);
    ___RefreshListViewselPos(lvw);
}

$(function () {

    $("#lvw_dbtable_ku").find("tr").eq(1).css('height', '40px');
})