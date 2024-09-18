window.GetUnitGroupFormulaInfo = function (value, UnitDBName, OldUnitDBName, NumberDBName, MoreUnit_IsEditMode, lvwName, rowindex, cellindex,numberBit) {
    var lvw = window["lvw_JsonData_" + lvwName];
    //请前端设计字段固定字段UI 存储为json
    if (lvwName.length > 0 && lvw) {

        var OldUnitIndex = -1;
        var UnitIndex = -1;
        for (var i = 0; i < lvw.headers.length ; i++) {
            var h = lvw.headers[i];
            if (h.dbname == OldUnitDBName) {
                OldUnitIndex = i;
            } else if (h.dbname == UnitDBName) {
                UnitIndex = i;
            }
        }
        if (lvw.rows[rowindex][0] != window.ListView.NewRowSignKey && OldUnitIndex >= 0 && UnitIndex >= 0 && lvw.rows[rowindex][OldUnitIndex].length == 0) {
            //更新旧单位值
            window.ListView.ApplyCellUIUpdate(lvw, [rowindex], OldUnitIndex, 0, app.CloneObject(lvw.rows[rowindex][UnitIndex]), "");
        }
    }
    if (value==null || value.length == "" || lvwName.length == 0) return "";
    var r = "";
    //value = "{formula:'123',v:{\"长_1_a\":\"G100\",\"宽1_b\":\"G200\",\"高1_c\":\"300\"}}";
    var value = JSON.stringify(value);
    var s = eval("(" + value + ")");
    var formula = s.formula;
    var o = s.v
    var canEditAttr = "";
    var editDefV = "0";
    if (lvwName.length > 0 && lvw) {
        var NumberIndex = -1;
        for (var i = 0; i < lvw.headers.length ; i++) {
            var h = lvw.headers[i];
            if (h.dbname == NumberDBName) {
                NumberIndex = i;
            }
        }
        for (var k in o) {
            var v = o[k] + "";
            var canEdit = v.indexOf("G") < 0;
            if (canEdit) {
                canEditAttr = k;
            }
        }
        var tmpformula = formula.replace("π", "3.140000");
        tmpformula = tmpformula.split("=")[1];
        var mAttrName = "";
        for (var k in o) {
            var v = o[k] + "";
            var s = k.replace(/_/g, ",");
            var ss = s.split(",");
            var attrName = ss[ss.length - 1];
            var defv = v.replace("G", "") * 1;
            var canEdit = v.indexOf("G") < 0;
            if (k != canEditAttr) {
                defv = defv.length == 0 || parseFloat(defv) == 0 ? "1" : defv;
                tmpformula = tmpformula.replace(new RegExp(attrName, "g"), defv);
            } else {
                mAttrName = attrName;
            }
        }

        var NumberValue = 1;
        if (NumberIndex > 0) {
            NumberValue = lvw.rows[rowindex][NumberIndex];
            NumberValue = NumberValue.length == 0 ? "1" : NumberValue;
            editDefV = GetFormulaAttrValue(formula, mAttrName, tmpformula, NumberValue);
        }
    }

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
        defv = defv.toFixed(numberBit);


        if (MoreUnit_IsEditMode == "1") {
            var vttr = canEdit ? "" : "G";
            jspnstr += jspnstr.length > 0 ? "," : "";
            jspnstr += "'" + k + "':'" + vttr + defv + "'";

            r += r.length > 0 ? "<br>" : "";
            r += "<span style='float:left;height:20px;line-height:20px;'>" + formulaAttr + "：</span><input uitype='numberbox' formula='" + formula + "' vttk='" + k + "' vttn='" + attrName + "' " + (canEdit ? " vttr='' " : " disabled  vttr='G' ") +
                "   class='billfieldbox cell_" + rowindex + "_" + cellindex + "' dvc='1' nul='1' " +
                "   onchange=\"__lvw_je_updateCellValue('" + lvwName + "'," + rowindex + "," + cellindex + ", GetCurrFormulaInfoValue('" + lvwName + "',this," + rowindex + "," + cellindex + ",'" + NumberDBName + "'), true)\" " +
                "   onkeyup=\"__lvw_je_updateCellValue('" + lvwName + "'," + rowindex + "," + cellindex + ",  GetCurrFormulaInfoValue('" + lvwName + "',this," + rowindex + "," + cellindex + ",'" + NumberDBName + "'), true)\" " +
                "   onblur=\"__lvw_je_updateCellValue('" + lvwName + "'," + rowindex + "," + cellindex + ",  GetCurrFormulaInfoValue('" + lvwName + "',this," + rowindex + "," + cellindex + ",'" + NumberDBName + "'), true)\" " +
                "   onclick=\"__lvw_je_updateCellValue('" + lvwName + "'," + rowindex + "," + cellindex + ", GetCurrFormulaInfoValue('" + lvwName + "',this," + rowindex + "," + cellindex + ",'" + NumberDBName + "'), true)\" " +
                "   isfield='1' style='width:55%;color:#aaa  name='UnitFormula_" + attrName + "_" + rowindex + "_" + cellindex + "' " +
                "   id='UnitFormula_" + attrName + "_" + rowindex + "_" + cellindex + "_0' value='" + defv + "' type='text'>";
        } else {
            r += r.length > 0 ? "<br>" : "";
            r += formulaAttr + "：" + defv;
        }
    }

    if (MoreUnit_IsEditMode == "1") {
        if (jspnstr.length > 0) {
            jspnstr = "{'formula':'" + formula + "','v':{" + jspnstr + "}}";
        }
        window.ListView.ApplyCellUIUpdate(lvw, [rowindex], cellindex, 0, jspnstr, "");
    }

    r = "<div class='sub-field gray f_numberbox editable' canedit='" + (MoreUnit_IsEditMode == "1" ? "editable" : "") + "' islvw='1' uitype='numberbox' dbname='@" + lvwName + "_UnitFormula_" + rowindex + "_" + cellindex + "' nul='1'>" + r + "</div>"
    return r;
}