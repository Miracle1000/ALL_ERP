function GetUnitGroupFormulaInfo(value,UnitDBName,OldUnitDBName ,NumberDBName , MoreUnit_IsEditMode, lvwName, rowindex, cellindex) {
	 var lvw = window["lvw_JsonData_" + lvwName];
    //请前端设计字段固定字段UI 存储为json
     if (lvwName.length > 0 && lvw) {
     	
		var OldUnitIndex = -1;
		var UnitIndex = -1;
        for (var i = 0; i < lvw.headers.length ; i++) {
            var h = lvw.headers[i];
            if(h.dbname == OldUnitDBName)
            {
				OldUnitIndex = i;
            }else if(h.dbname == UnitDBName)
            {
				UnitIndex = i;
            }
        }
        if (lvw.rows[rowindex][0] != window.ListView.NewRowSignKey && OldUnitIndex >= 0 && UnitIndex >= 0) {
            var objv =  lvw.rows[rowindex][OldUnitIndex];
            if(objv && objv.fieldvalue) { 
                objv = objv.fieldvalue 
            }
            if ((objv + "").length == 0) {
                //更新旧单位值
                window.ListView.ApplyCellUIUpdate(lvw, [rowindex], OldUnitIndex, 0, app.CloneObject(lvw.rows[rowindex][UnitIndex]), "");
            }
		}
     }
    if(value.trim().length=="" || lvwName.length== 0) return "";
    var r = "";
    //value = "{formula:'123',v:{\"长_1_a\":\"G100\",\"宽1_b\":\"G200\",\"高1_c\":\"300\"}}";
    var s = eval("(" + value + ")");
    var formula = s.formula;
    var o = s.v
    var canEditAttr = "";
    var editDefV = "0";
    var NumberValue = 1;
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
        if (NumberIndex > 0) {
            NumberValue = lvw.rows[rowindex][NumberIndex];
            NumberValue = (NumberValue==undefined || NumberValue.length == 0 )? "1" : NumberValue;
            editDefV = GetFormulaAttrValue(formula, mAttrName, tmpformula, NumberValue);
        }
    }

    var jspnstr = "";
    var fzunitflag = "";
    for (var k in o) {
        var v = o[k] + "";
        var s = k.replace(/_/, ",");
        var ss = s.split(",");
        var attrName = ss[ss.length - 1];
        var formulaAttr = ss.splice(0, ss.length - 1).join("_");
        var canEdit = v.indexOf("G") < 0;
        var defv = v.replace("G", "")*1;
        if (defv == 0) {
            if (k == canEditAttr) {
                defv = editDefV;
            } else {
                defv = MoreUnit_IsEditMode == "1" && parseFloat(NumberValue) > 0 ? 1 : 0;
            }
        }
        defv = defv.length == 0 || parseFloat(defv) == 0 ? (MoreUnit_IsEditMode == "1" && parseFloat(NumberValue) > 0 ? 1 : 0) : defv;
        defv = defv * 1;
		defv = defv.toFixed(window.SysConfig.NumberBit)

		
		if (MoreUnit_IsEditMode == "1") {
		    if ($("#moreunitopen_0"))
		    {
		        if ($("#moreunitopen_0").val() == "0") {
		            fzunitflag = "disabled";
		        } else {
		            if ($("#blchange_0"))
		            {
		                if ($("#blchange_0").val() == "1")
		                {
		                    fzunitflag = "disabled";
		                }
		            }
		        }
		    }
			var vttr = canEdit ? "" : "G" ;
			jspnstr += jspnstr.length > 0 ? "," : "";
			jspnstr += "'" + k + "':'" + vttr + defv + "'";

            r += r.length > 0 ? "<br>" : "";
            r += "<span style='float:left;height:20px;line-height:20px;'>" + formulaAttr + "：</span><input " + fzunitflag + " uitype='numberbox' formula='" + formula + "' vttk='" + k + "' vttn='" + attrName + "' " + (canEdit ? " vttr='' " : " disabled  vttr='G' ") +
                "   class='billfieldbox cell_" + rowindex + "_" + cellindex + "' dvc='1' nul='1' disnegative=1 " +
                "   onchange=\"window.ChangeUnitEvent=1;__lvw_je_updateCellValue('" + lvwName + "'," + rowindex + "," + cellindex + ", GetCurrFormulaInfoValue('" + lvwName + "',this," + rowindex + "," + cellindex + ",'" + NumberDBName + "'), true)\" " +
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

    r = "<div class='sub-field gray f_numberbox editable' canedit='" + (MoreUnit_IsEditMode=="1" ? "editable":"")+"' islvw='1' uitype='numberbox' dbname='@" + lvwName + "_UnitFormula_" + rowindex + "_" + cellindex + "' nul='1'>" + r + "</div>"
    return r;
}
//明细编辑标记是否单位属性编辑
window.ListViewUnitAttrEdit = false;
//计算公式 π = 3.14
function GetCurrFormulaInfoValue(lvwName, box, rowindex, cellindex, NumberDBName) {
    var formulAttrs = $(".cell_" + rowindex + "_" + cellindex);
    var canEditID = "";//最后一个可编辑ID
    var formula = "";
    formulAttrs.each(function () {    
        var vttr = this.getAttribute("vttr");
        if (vttr != "G") {
            canEditID = this.id;
        }
        if (formula.length == 0) {
            formula = this.getAttribute("formula");
        }
    });
    var lvw = window["lvw_JsonData_" + lvwName];

    var NumberIndex = -1;
    for (var i = 0; i < lvw.headers.length ; i++) {
        var h = lvw.headers[i];
        if (h.dbname == NumberDBName) {
            NumberIndex = i;
        }
    }
    var tmpformula = formula.replace("π", "3.140000");
    tmpformula = tmpformula.split("=")[1];

    if (NumberIndex >= 0) {
        try {
            var NumberValue = 0;
            //如果当前是最后可编辑属性 则变化数量
            if (box.id == canEditID) {
                formulAttrs.each(function () {
                    var vttn = this.getAttribute("vttn");
                    var mv = this.value;
                    //mv = mv.length == 0 || parseFloat(mv) == 0 ? "1" : mv;

                    tmpformula = tmpformula.replace(new RegExp(vttn, "g"), mv);
                });
                NumberValue = eval(tmpformula);
                //__lvw_je_updateCellValue(lvwName, rowindex, NumberIndex, NumberValue, true);
                window.ListViewUnitAttrEdit = true;
                var h = lvw.headers[NumberIndex];
                window.ListView.ApplyCellUIUpdate(lvw, [rowindex], NumberIndex, 0, NumberValue, "");
                __lvw_je_redrawCell(lvw, h, rowindex, h.showindex);
                var updateCols = window.ListView.GetNeedReChangeCols(lvw, NumberIndex);
                window.ListView.ApplyCellSumsData(lvw, updateCols);
                __lvw_je_redrawCellSumRow(lvw);
                if (window.ChangeUnitEvent == 1 && window.lvwRedrawCellAfterEvent) {
                    window.lvwRedrawCellAfterEvent(lvw, h, rowindex, NumberIndex);
                    window.ChangeUnitEvent = 0;
                }
            } else {
                var mvttn = "";
                NumberValue = lvw.rows[rowindex][NumberIndex];
                formulAttrs.each(function () {
                    var vttn = this.getAttribute("vttn");
                    if (this.id != canEditID) {             
                        var mv = this.value;
                        mv = mv.length == 0 || parseFloat(mv) == 0 ? "1" : mv;
                        tmpformula = tmpformula.replace(new RegExp(vttn, "g"), mv);
                    }else{
                        mvttn =  vttn;
                    }
                });
                var ev = GetFormulaAttrValue(formula ,mvttn , tmpformula, NumberValue);
                $("#" + canEditID).val(ev);
            }
        } catch (e) { }
     }

    var v = "";
    formulAttrs.each(function () {
        var vttr = this.getAttribute("vttr");
        v += v.length > 0 ? "," : "";
        v += "'" + this.getAttribute("vttk") + "':'" + vttr + this.value + "'";
    });
    if (v.length > 0) {
        v = "{'formula':'" + formula + "','v':{" + v + "}}";
    }
    return v;
}

function GetFormulaAttrValue(formula,mvttn, tmpformula, NumberValue) {	
	var num = 0;
	tmpformula = tmpformula.replace(new RegExp(mvttn,'g'), function(){ num++ ; return "1"});
    var r =eval(tmpformula);
    var mv = parseFloat(r) == 0 ? 0 : parseFloat(NumberValue) / parseFloat(r);
	if(num>0){mv = Math.pow(mv, 1/num);}
    return mv.toFixed(window.SysConfig.NumberBit)
    /*
    15=1*b*3
    V=π*r*r*h
    V=s*h
    V=s*h/3
    S=a*b
    S=a*h/2
    S=π*r
    */
}

function SetCurrFormulaInfoValue(box, UnitAttrDBName) {
    window.ListViewUnitAttrEdit = false;
    var NumberValue = $(box).val();
    if (NumberValue == "") NumberValue = 0;
    var td = $(box).parents("td.lvw_cell[dbcolindex]")[0];
    var tr = td.parentNode;
    var tb = tr.parentNode.parentNode;
    var pos = tr.getAttribute("pos");
    var lvwName = tb.id.replace("lvw_dbtable_", "");
    var rowindex = tr.getAttribute("pos");
    var cellindex = td.getAttribute("dbcolindex");
    var lvw = window["lvw_JsonData_" + lvwName];
    CurrFormulaInfoHandle(lvw, rowindex, cellindex,UnitAttrDBName, NumberValue);
}

function CurrFormulaInfoHandle(lvw, rowindex, cellindex, UnitAttrDBName, NumberValue, unRefresh) {
    if (window.ListViewUnitAttrEdit == true) {
        window.ListViewUnitAttrEdit = false;
        return;
    }
    var UnitAttrIndex = -1;
    for (var i = 0; i < lvw.headers.length ; i++) {
        var h = lvw.headers[i];
        if (h.dbname == UnitAttrDBName) {
            UnitAttrIndex = i;
        }
    }
    var mformulAttrs = "";
    var canEditAttr = "";
    var o = null;

    var canEditID = "";//最后一个可编辑ID
    var formula = "";
    var formulAttrs = $(".cell_" + rowindex + "_" + UnitAttrIndex);
    //是否开启单位属性
    if (formulAttrs.length == 0) {
        mformulAttrs = lvw.rows[rowindex][UnitAttrIndex];
        if (mformulAttrs==undefined || mformulAttrs.length == "" || mformulAttrs.length == 0) return;
        var s = eval("(" + mformulAttrs + ")");
        formula = s.formula;
        o = s.v;
        for (var k in o) {
            var v = o[k] + "";
            var canEdit = v.indexOf("G") < 0;
            if (canEdit) canEditAttr = k;
        }
    } else {
        formulAttrs.each(function () {
            var vttr = this.getAttribute("vttr");
            if (vttr != "G") canEditID = this.id;
            if (formula.length == 0) formula = this.getAttribute("formula");
        });
    }
    var tmpformula = formula.replace("π", "3.140000");
    tmpformula = tmpformula.split("=")[1];
    var mvttn = "";
    
    //是否开启单位属性
    if (formulAttrs.length == 0) {
        for (var k in o) {
            var s = k.replace(/_/g, ",");
            var ss = s.split(",");
            var attrName = ss[ss.length - 1];

            var mv = o[k] + "";
            var defv = mv.replace("G", "") * 1;
            if (k != canEditAttr) {
                defv = defv.length == 0 || parseFloat(defv) == 0 ? "1" : defv;
                tmpformula = tmpformula.replace(new RegExp(attrName, "g"), defv);
            } else {
                mvttn = attrName;
            }
        }
    }else{
        formulAttrs.each(function () {
            var vttn = this.getAttribute("vttn");
            if (this.id != canEditID) {
                var mv = this.value;
                mv = mv.length == 0 || parseFloat(mv) == 0 ? "1" : mv;
                tmpformula = tmpformula.replace(new RegExp(vttn, "g"), mv);
            } else {
                mvttn = vttn;
            }
        });
    }
    var ev = GetFormulaAttrValue(formula, mvttn, tmpformula, NumberValue);
    if (canEditID.length > 0) $("#" + canEditID).val(ev);

    var v = "";
    //是否开启单位属性
    if (formulAttrs.length == 0) {
        o[canEditAttr] = ev;
        for (var k in o) {
            v += v.length > 0 ? "," : "";
            v += "'" + k + "':'" + o[k] + "'";
        }
    }else{
        formulAttrs.each(function () {
            var vttr = this.getAttribute("vttr");
            v += v.length > 0 ? "," : "";
            v += "'" + this.getAttribute("vttk") + "':'" + vttr + this.value + "'";
        });
    }

    if (v.length > 0) v = "{'formula':'" + formula + "','v':{" + v + "}}";

    var h = lvw.headers[UnitAttrIndex];
    __lvw_je_setcelldatav(lvw, rowindex, UnitAttrIndex, v);
    if (unRefresh) return;
    window.ListView.ApplyCellUIUpdate(lvw, [rowindex], UnitAttrIndex, 0, v, "");
    __lvw_je_redrawCell(lvw, h, rowindex, h.showindex);    
}