window.flag=false

window.OnListViewFormualUpdateCell = function (lvw, rowindex, cellindex, newv) {
    if (lvw.headers[cellindex].dbname != "TaxRate") { return; }
    window.onlvwUpdateCellValue(lvw, rowindex, cellindex, newv, 0, 0, 0);
}

window.onlvwUpdateCellValue = function (lvw, rowindex, cellindex, v, isztlr, isEof, disrefresh, oldvalue) {
    if (window.___Refreshinglvw == true) return;
    if (window.IsListviewAddRows == true) return;
    if (oldvalue == v) { return; }
    var header = lvw.headers[cellindex];
    var dbname = header.dbname;
    if (v == undefined || v == null || v == "") { v = 0 }
    if (lvw.id == "caigoulist") {
        var taxRate = lvw.rows[rowindex][ListView.GetHeaderByDBName(lvw, "TaxRate").i];
        if (taxRate == undefined || taxRate == null || taxRate == "") { taxRate = 0 }
        var num1 = lvw.rows[rowindex][ListView.GetHeaderByDBName(lvw, "Num1").i];
        taxRate = taxRate * 0.01;
        switch (dbname) {
            //数量
            case "Num1":
                //税后总价=含税单价*折扣*数量	
                ListView.EvalCellFormula(lvw, rowindex, "TaxDstMoney", "PriceAfterTax * Discount * Num1");
                //优惠后总价=（含税单价*折扣*数量）-明细优惠	
                ListView.EvalCellFormula(lvw, rowindex, "Money1", "PriceAfterTax * Discount * Num1 - Concessions");
                //金额=（含税单价*折扣*数量-明细优惠）/（1+税率）。。。考虑误差直接取优惠后总价v32.01
                ListView.EvalCellFormula(lvw, rowindex, "MoneyAfterDiscount", "Money1/(1+TaxRate*0.01)");
                //税额=（含税单价*折扣*数量-明细优惠）-（含税单价*折扣*数量-明细优惠）/（1+税率）	
                ListView.EvalCellFormula(lvw, rowindex, "TaxValue", "(PriceAfterTax * Discount * Num1 - Concessions) - (PriceAfterTax * Discount * Num1 - Concessions)/(1+TaxRate*0.01)");
                //优惠后单价=（含税单价*折扣*数量-明细优惠）/数量	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscountTax", "(PriceAfterTax * Discount * Num1 - Concessions)/Num1");
                //更新字段
                window.ListView.RefreshCellUI(lvw, rowindex, "TaxDstMoney,Money1,MoneyAfterDiscount,TaxValue,PriceAfterDiscountTax", 100);

                CurrFormulaInfoHandle(lvw, rowindex, cellindex, "commUnitAttr", num1);
                ListView.ApplyCellSumsData(lvw, [ListView.GetHeaderByDBName(lvw, "TaxDstMoney").i]);
                break;
                //明细优惠
            case "Concessions":
                //税后总价	不变	
                //含税折后单价	不变
                //含税单价	不变
                //未税折后单价	不变
                //未税单价	不变	
                //优惠后总价=（格式化后含税单价*折扣*数量）-明细优惠	
                ListView.EvalCellFormula(lvw, rowindex, "Money1", "PriceAfterTax * Discount * Num1 - Concessions");
                //金额=（格式化后含税单价*折扣*数量-明细优惠）/（1+税率）。。。考虑误差直接取优惠后总价v32.01
                ListView.EvalCellFormula(lvw, rowindex, "MoneyAfterDiscount", "Money1/(1+TaxRate*0.01)");
                //税额=（格式化后含税单价*折扣*数量-明细优惠）-（格式化后含税单价*折扣*数量-明细优惠）/（1+税率）	
                ListView.EvalCellFormula(lvw, rowindex, "TaxValue", "(PriceAfterTax * Discount * Num1 - Concessions) - (PriceAfterTax * Discount * Num1 - Concessions)/(1+TaxRate*0.01)");
                //优惠后单价=（格式化后含税单价*折扣*数量-明细优惠）/数量	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscountTax", "(PriceAfterTax * Discount * Num1 - Concessions)/Num1");
                //更新字段
                window.ListView.RefreshCellUI(lvw, rowindex, "Money1,MoneyAfterDiscount,TaxValue,PriceAfterDiscountTax", 100);
                break;
                //未税单价
            case "Price1":
                //未税折后单价=未税单价*折扣	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscount", "Price1 * Discount");
                //含税单价=未税单价*（1+税率）	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterTax", "Price1 * (1+TaxRate*0.01)");
                //含税折后单价=格式化后含税单价*折扣	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscountTaxPre", "PriceAfterTax * Discount");
                //税后总价=格式化后含税单价*折扣*数量	
                ListView.EvalCellFormula(lvw, rowindex, "TaxDstMoney", "PriceAfterTax * Discount * Num1");
                //优惠后总价=（格式化后含税单价*折扣*数量）-明细优惠	
                ListView.EvalCellFormula(lvw, rowindex, "Money1", "PriceAfterTax * Discount * Num1 - Concessions");
                //金额=（格式化后含税单价*折扣*数量-明细优惠）/（1+税率）。。。考虑误差直接取优惠后总价v32.01	
                ListView.EvalCellFormula(lvw, rowindex, "MoneyAfterDiscount", "Money1/(1+TaxRate*0.01)");
                //税额=（格式化后含税单价*折扣*数量-明细优惠）-【格式化后含税单价*折扣*数量-明细优惠/（1+税率）】	
                ListView.EvalCellFormula(lvw, rowindex, "TaxValue", "(PriceAfterTax * Discount * Num1 - Concessions) - (PriceAfterTax * Discount * Num1 - Concessions)/(1+TaxRate*0.01)");
                //优惠后单价=格式化后含税单价*折扣*数量-明细优惠/数量	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscountTax", "(PriceAfterTax * Discount * Num1 - Concessions)/Num1");
                //更新字段
                window.ListView.RefreshCellUI(lvw, rowindex, "PriceAfterDiscount,PriceAfterTax,PriceAfterDiscountTaxPre,TaxDstMoney,Money1,MoneyAfterDiscount,PriceAfterDiscountTax,TaxValue", 100);
                ListView.ApplyCellSumsData(lvw, [ListView.GetHeaderByDBName(lvw, "TaxDstMoney").i]);
                break;
                //折扣
            case "Discount":
                //未税折后单价=含税单价/(1+税率)*折扣	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscount", "PriceAfterTax/(1+TaxRate*0.01) * Discount");
                //含税折后单价=含税单价*折扣	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscountTaxPre", "PriceAfterTax * Discount");
                //税后总价=含税单价*折扣*数量	
                ListView.EvalCellFormula(lvw, rowindex, "TaxDstMoney", "PriceAfterTax * Discount * Num1");
                //优惠后总价=（含税单价*折扣*数量）-明细优惠	
                ListView.EvalCellFormula(lvw, rowindex, "Money1", "PriceAfterTax * Discount * Num1 - Concessions");
                //金额=（含税单价*折扣*数量-明细优惠）/（1+税率）。。。考虑误差直接取优惠后总价v32.01	
                ListView.EvalCellFormula(lvw, rowindex, "MoneyAfterDiscount", "Money1/(1+TaxRate*0.01)");
                //税额=（含税单价*折扣*数量-明细优惠）-（含税单价*折扣*数量-明细优惠）/（1+税率）	
                ListView.EvalCellFormula(lvw, rowindex, "TaxValue", "(PriceAfterTax * Discount * Num1 - Concessions) - (PriceAfterTax * Discount * Num1 - Concessions)/(1+TaxRate*0.01)");
                //优惠后单价=（含税单价*折扣*数量-明细优惠）/数量	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscountTax", "(PriceAfterTax * Discount * Num1 - Concessions)/Num1");
                //更新字段
                window.ListView.RefreshCellUI(lvw, rowindex, "PriceAfterDiscount,PriceAfterDiscountTaxPre,TaxDstMoney,Money1,MoneyAfterDiscount,TaxValue,PriceAfterDiscountTax", 100);
                ListView.ApplyCellSumsData(lvw, [ListView.GetHeaderByDBName(lvw, "TaxDstMoney").i]);
                break;
                //含税单价
            case "PriceAfterTax":
                //含税折后单价=含税单价*折扣	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscountTaxPre", "PriceAfterTax * Discount");
                //未税单价=含税单价/（1+税率）
                ListView.EvalCellFormula(lvw, rowindex, "Price1", "PriceAfterTax/(1+TaxRate*0.01)");
                //未税折后单价=含税单价/（1+税率）*折扣	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscount", "PriceAfterTax/(1+TaxRate*0.01) * Discount");
                //税后总价=含税单价*折扣*数量	
                ListView.EvalCellFormula(lvw, rowindex, "TaxDstMoney", "PriceAfterTax * Discount * Num1");
                //优惠后总价=（含税单价*折扣*数量）-明细优惠	
                ListView.EvalCellFormula(lvw, rowindex, "Money1", "PriceAfterTax * Discount * Num1 - Concessions");
                //金额=（含税单价*折扣*数量-明细优惠）/（1+税率）。。。考虑误差直接取优惠后总价v32.01	
                ListView.EvalCellFormula(lvw, rowindex, "MoneyAfterDiscount", "Money1/(1+TaxRate*0.01)");
                //税额=（含税单价*折扣*数量-明细优惠）-（含税单价*折扣*数量-明细优惠）/（1+税率）	
                ListView.EvalCellFormula(lvw, rowindex, "TaxValue", "(PriceAfterTax * Discount * Num1 - Concessions) - (PriceAfterTax * Discount * Num1 - Concessions)/(1+TaxRate*0.01)");
                //优惠后单价=（含税单价*折扣*数量-明细优惠）/数量	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscountTax", "(PriceAfterTax * Discount * Num1 - Concessions)/Num1");
                //更新字段
                window.ListView.RefreshCellUI(lvw, rowindex, "PriceAfterDiscountTaxPre,Price1,PriceAfterDiscount,TaxDstMoney,Money1,MoneyAfterDiscount,PriceAfterDiscountTax,TaxValue", 100);
                ListView.ApplyCellSumsData(lvw, [ListView.GetHeaderByDBName(lvw, "TaxDstMoney").i]);
                break;
                //税率
            case "TaxRate":
                //税后总价	不变
                //含税折后单价	不变
                //明细优惠	手动录入
                //优惠后总价	不变
                //优惠后单价	不变	
                //金额=（含税单价*折扣*数量-明细优惠）/（1+税率）。。。考虑误差直接取优惠后总价v32.01	
                ListView.EvalCellFormula(lvw, rowindex, "MoneyAfterDiscount", "Money1/(1+TaxRate*0.01)");
                //税额=（含税单价*折扣*数量-明细优惠）-（含税单价*折扣*数量-明细优惠）/（1+税率）	
                ListView.EvalCellFormula(lvw, rowindex, "TaxValue", "(PriceAfterTax * Discount * Num1 - Concessions) - (PriceAfterTax * Discount * Num1 - Concessions)/(1+TaxRate*0.01)");
                //未税单价=含税单价/(1+税率)	
                ListView.EvalCellFormula(lvw, rowindex, "Price1", "PriceAfterTax/(1+TaxRate*0.01)");
                //未税折后单价=含税单价/(1+税率)*折扣	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscount", "PriceAfterTax/(1+TaxRate*0.01) * Discount");
                //更新字段
                window.ListView.RefreshCellUI(lvw, rowindex, "MoneyAfterDiscount,TaxValue,Price1,PriceAfterDiscount", 100);
                break;
                //税后总价
            case "TaxDstMoney":
                //优惠后总价=税后总价-明细优惠	
                ListView.EvalCellFormula(lvw, rowindex, "Money1", "TaxDstMoney-Concessions");
                //优惠后单价=（税后总价-明细优惠）/数量	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscountTax", "(TaxDstMoney-Concessions)/Num1");
                //金额=（税后总价-明细优惠）/（1+税率）
                ListView.EvalCellFormula(lvw, rowindex, "MoneyAfterDiscount", "(TaxDstMoney-Concessions)/(1+TaxRate*0.01)");
                //税额=（税后总价-明细优惠）-（税后总价-明细优惠）/（1+税率）	
                ListView.EvalCellFormula(lvw, rowindex, "TaxValue", "(TaxDstMoney-Concessions) - (TaxDstMoney-Concessions)/(1+TaxRate*0.01)");
                //含税折后单价=税后总价/数量	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscountTaxPre", "TaxDstMoney/ Num1");
                //含税单价=税后总价/数量/折扣
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterTax", "TaxDstMoney/ Num1 / Discount");
                //未税单价=税后总价/数量/折扣/(1+税率)	
                ListView.EvalCellFormula(lvw, rowindex, "Price1", "TaxDstMoney/ Num1 / Discount /(1+TaxRate*0.01)");
                //未税折后单价=税后总价/数量/(1+税率)	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscount", "TaxDstMoney/ Num1/(1+TaxRate*0.01)");
                //更新字段
                window.ListView.RefreshCellUI(lvw, rowindex, "Money1,PriceAfterDiscountTax,MoneyAfterDiscount,TaxValue,PriceAfterDiscountTaxPre,PriceAfterTax,Price1,PriceAfterDiscount", 100);
                break;
                //金额
            case "MoneyAfterDiscount":
                //优惠后总价=金额*(1+税率)	
                ListView.EvalCellFormula(lvw, rowindex, "Money1", "MoneyAfterDiscount*(1+TaxRate*0.01)");
                //优惠后单价=格式化后优惠后总价/数量	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscountTax", "Money1/Num1");
                //税额=格式化后优惠后总价-金额	
                ListView.EvalCellFormula(lvw, rowindex, "TaxValue", "Money1 - MoneyAfterDiscount");
                //税后总价=格式化后优惠后总价+明细优惠	
                ListView.EvalCellFormula(lvw, rowindex, "TaxDstMoney", "Money1+Concessions");
                //含税折后单价=（格式化后优惠后总价+明细优惠）/数量	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscountTaxPre", "(Money1+Concessions)/ Num1");
                //含税单价=（格式化后优惠后总价+明细优惠）/数量/折扣	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterTax", "(Money1+Concessions)/ Num1 / Discount");
                //未税单价=（格式化后优惠后总价+明细优惠）/数量/折扣/（1+税率）	
                ListView.EvalCellFormula(lvw, rowindex, "Price1", "(Money1+Concessions)/ Num1 / Discount /(1+TaxRate*0.01)");
                //未税折后单价=（格式化后优惠后总价+明细优惠）/数量/（1+税率）	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscount", "(Money1+Concessions)/ Num1/(1+TaxRate*0.01)");
                //更新字段
                window.ListView.RefreshCellUI(lvw, rowindex, "Money1,PriceAfterDiscountTax,TaxValue,TaxDstMoney,PriceAfterDiscountTaxPre,PriceAfterTax,Price1,PriceAfterDiscount", 100);
                ListView.ApplyCellSumsData(lvw, [ListView.GetHeaderByDBName(lvw, "TaxDstMoney").i]);
                break;
                //优惠后总价
            case "Money1":
                //优惠后单价=优惠后总价/数量	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscountTax", "Money1/Num1");
                //税后总价=优惠后总价+明细优惠	
                ListView.EvalCellFormula(lvw, rowindex, "TaxDstMoney", "Money1+Concessions");
                //含税折后单价=（优惠后总价+明细优惠）/数量	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscountTaxPre", "(Money1+Concessions)/ Num1");
                //含税单价=（优惠后总价+明细优惠）/数量/折扣	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterTax", "(Money1+Concessions)/ Num1 / Discount");
                //金额=优惠后总价/（1+税率）
                ListView.EvalCellFormula(lvw, rowindex, "MoneyAfterDiscount", "Money1/(1+TaxRate*0.01)");
                //税额=优惠后总价-优惠后总价/(1+税率)	
                ListView.EvalCellFormula(lvw, rowindex, "TaxValue", "Money1 - Money1/(1+TaxRate*0.01)");
                //未税折后单价=（优惠后总价+明细优惠）/数量/（1+税率）	
                ListView.EvalCellFormula(lvw, rowindex, "PriceAfterDiscount", "(Money1+Concessions)/ Num1/(1+TaxRate*0.01)");
                //未税单价=（优惠后总价+明细优惠）/数量/（1+税率）/折扣	
                ListView.EvalCellFormula(lvw, rowindex, "Price1", "(Money1+Concessions)/ Num1 / Discount /(1+TaxRate*0.01)");
                //更新字段
                window.ListView.RefreshCellUI(lvw, rowindex, "PriceAfterDiscountTax,TaxDstMoney,PriceAfterDiscountTaxPre,PriceAfterTax,MoneyAfterDiscount,TaxValue,PriceAfterDiscount,Price1", 100);
                ListView.ApplyCellSumsData(lvw, [ListView.GetHeaderByDBName(lvw, "TaxDstMoney").i]);
                break;
        }
    }
}

$(function () {
    //重写是为了提示先选择供应商
    //JSON模式编辑.插入新行
    __lvw_je_addNew = function (id, disrefresh) {
        if (id == "caigoulist" && $("#Company_tit").val() == "" && (Bill.GetField("Company").value == undefined || Bill.GetField("Company").value == "0")) {
            alert("请先选择供应商");
            return;
        }
        var lvw = window["lvw_JsonData_" + id];
        if (id == "payoutlist") {
            var payFPMoney = $("#Money1_0").val();
            if (parseFloat(payFPMoney.replace(/,/g, '')) <= parseFloat(lvw.currsums[1])) {
                alert("没有需要分配的金额，无法增加新的期次");
                return;
            }
        }
        var lastrow = lvw.rows[lvw.rows.length - 1];
        var isnullrow = lastrow[0] == window.ListView.NewRowSignKey;
        var newpos = lvw.rows.length - (isnullrow ? 1 : 0);
        lvw.rows[newpos] = new Array();
        lvw.page.recordcount++;
        var headers = lvw.headers;
        var colidx = -1;
        for (var i = 0; i < headers.length; i++) {
            var jheader = headers[i];
            if (jheader.dbname == "@indexcol") { colidx = i; }
            if (jheader.display == "space") { jheader.defvalue = ""; jheader.value = ""; }
            var defdata = "";
            if (jheader.uitype == "selectbox" || jheader.uitype == "selectcheckbox") { //更新值数据层option中value的取值
                var _source = Bill.HandleSelectSource(jheader, jheader.defvalue || "");
                var ops = _source.options;
                if (jheader.uitype == "selectbox") {
                    defdata = (!jheader.defvalue ? (ops && ops[0] ? ops[0].v : "") : jheader.defvalue);
                } else {
                    defdata = (!jheader.defvalue ? "" : jheader.defvalue);
                }
                if (jheader.dbname === "FromUnit") {
                    defdata = 0;
                    if (jheader.source.options) {
                        var nullSource = { n: "", v: 0 };
                        jheader.source.options.push(nullSource)
                    }
                }
            } else {
                defdata = (jheader.defvalue == undefined ? "" : jheader.defvalue);
            }
            if (lvw.existsFiltered == true) {
                if (jheader.filterinfo && jheader.filterinfo.keys) {
                    defdata = jheader.filterinfo.keys[0].v;
                }
            }
            if (app.isObject(defdata)) {
                defdata = app.CloneObject(defdata, 2, "parentNode,lvwobject");
            }
            __lvw_je_setcelldatav(lvw, newpos, i, defdata);
            if (jheader.ztlrV) { jheader.ztlrV = null; }//添加行后清空整体录入
            if (jheader.uitype == "treenode") {		//维护树节点关系
                var obj = __lvw_tn_computeTreeNodeDeepDate(lvw, newpos, i);
                __lvw_tn_SortNodesDeep(obj, "", obj, lvw, i);
                lvw.currTreeOperateState = "";				//清空当前状态标识
                lvw.currRemTreeRowIndx = [];				//清空对于树节点对应行标识记录
                lvw.copyTreePosIndex = 0;					//清空存放移动前节点的起始idx
            }
        }
        AddFyhk(id, newpos);
        if (window.OnListViewInsertNewRow) {
            window.OnListViewInsertNewRow(lvw, newpos, "__lvw_je_addNew");
        }
        for (var i = 0; i < lvw.rows.length; i++) { lvw.rows[i][colidx] = i; }
        lvw.page.selpos = newpos;
        if ((newpos + 1) >= lvw.page.pagesize) { lvw.page.startpos = (newpos + 2) - lvw.page.pagesize }
        if (isnullrow == true) {
            lvw.rows.push([window.ListView.NewRowSignKey]);
            lvw.VRows.push(newpos + 1);
        }
        lvw.page.IsApplyFormuled = 0;
        if (disrefresh != true) {
            ___ReSumListViewByJsonData(lvw);
            ___RefreshListViewByJson(lvw);
            var result = ___RefreshListViewselPos(lvw);
            if (window.onListViewRowAfterAdd) { window.onListViewRowAfterAdd(lvw, newpos + 1); }
            return result;
        }
    }

    //JSON模式编辑.每行功能按钮
    __lvw_je_btnhandle = function (btn, ht) {
        var tr = $(btn).parents('tr').first()[0]//app.getParent(btn, 2);
        var tb = $(tr).parents('table').first()[0]//app.getParent(tr, 2);
        var id = tb.id.replace("lvw_dbtable_", "");
        var lvw = window["lvw_JsonData_" + id];
        var pos = tr.getAttribute("pos") * 1;
        var td = $(btn).parents('td').first()[0];
        var rowspan = td.getAttribute("rowspan") ? td.getAttribute("rowspan") : 1;
        /*********** lvw:listview Object   pos:当前行index   ht:按钮标识  */
        /*********** window.__lvw_btnhandle_override 该方法返回值为Boolean类型  为true时，属于完全接管，以下框架代码将不会执行 */
        if (window.__lvw_btnhandle_override) { if (window.__lvw_btnhandle_override(lvw, pos, ht)) { return; } }
        switch (ht) {
            case 1: //在当前行之前插入新纪录
                if (id == "payoutlist") {
                    var payFPMoney = $("#Money1_0").val();
                    if (parseFloat(payFPMoney.replace(/,/g, '')) <= parseFloat(lvw.currsums[1])) {
                        alert("没有需要分配的金额，无法增加新的期次");
                        return;
                    }
                    var lastrow = lvw.rows[lvw.rows.length - 1];
                    var isnullrow = lastrow[0] == window.ListView.NewRowSignKey;
                    var newpos = lvw.rows.length - (isnullrow ? 1 : 0);
                    AddFyhk(id, newpos);
                }
                else {
                    __lvw_je_insertNewRow(lvw, pos + 1)
                }
                ___ReSumListViewByJsonData(lvw);
                ___RefreshListViewselPos(lvw);
                lvw.page.IsApplyFormuled = 0; //Tan:此处可能存在性能问题，只需计算新增行即可，后期优化
                ___RefreshListViewByJson(lvw);
                if (window.onListViewRowAfterAdd) { window.onListViewRowAfterAdd(lvw, pos + 1); }
                break;
            case 2: //删除当前行
                if (window.onListViewRowBeforeDelete) {
                    if (window.onListViewRowBeforeDelete(lvw, pos) == true) return;
                }
                for (var i = pos; i <= (rowspan * 1 + pos - 1); i++) {
                    __lvw_je_deleteCurRow(lvw, pos);
                    //删除完之后做特殊处理
                    if (id == "payoutlist") {
                        for (var i = 0; i < lvw.rows.length - 1; i++) {
                            lvw.rows[i][0] = "第" + (i + 1) + "期";
                        }
                    }
                    ___ReSumListViewByJsonData(lvw);
                    ___RefreshListViewselPos(lvw);
                    lvw.page.IsApplyFormuled = 0;
                    ___RefreshListViewByJson(lvw);
                    __lvw_clearAllCheckedState(lvw.id);
                    ListView.AutoExecLvwFormula(lvw, 0);
                    if (window.onListViewRowAfterDelete) { window.onListViewRowAfterDelete(lvw, pos); }
                    if (lvw.ui && lvw.ui.rowsmergesstyle == "merge" && lvw.ui.rowmerges && lvw.ui.rowmerges.length) { continue } else { break; }
                }
                break;
            case 3: //上移
                __lvw_je_rowmove(lvw, pos, -1); break;
            case 4:	//下移
                __lvw_je_rowmove(lvw, pos, 1); break;
        }
    }


    ListView.nulldataRowClickEvent = function (lvwid, DBName, cellIndex, type) {
        if (lvwid == "caigoulist" && $("#Company_tit").val() == "" && (Bill.GetField("Company").value == undefined || Bill.GetField("Company").value == "0")) {
            alert("请先选择供应商");
            return;
        }
        __lvw_je_addNew(lvwid);
        var lvw = window["lvw_JsonData_" + lvwid];
        var srcId = "@" + lvwid + "_" + DBName + "_" + (type == "addrow" ? lvw.rows.length - 2 : 0) + "_" + cellIndex;
        setTimeout(function () {
            var srcDom = $("div[fordbname='" + srcId + "']")[0];
            Bill.TiggerAutoComplete(srcDom, 1);
        }, 300);
    }

    Date.prototype.format = function (fmt) {
        var o = {
            "M+": this.getMonth() + 1, //月份
            "d+": this.getDate(), //日
            "h+": this.getHours(), //小时
            "m+": this.getMinutes(), //分
            "s+": this.getSeconds(), //秒
            "q+": Math.floor((this.getMonth() + 3) / 3), //季度
            "S": this.getMilliseconds() //毫秒
        };
        if (/(y+)/.test(fmt)) {
            fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
        }
        for (var k in o) {
            if (new RegExp("(" + k + ")").test(fmt)) {
                fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
            }
        }
        return fmt;
    }
});

function AddFyhk(id, newpos) {
    if (id == "payoutlist") {
        var lvw = window["lvw_JsonData_" + id];
        var payFPMoney = $("#Money1_0").val().replace(/,/g, '');
        var planDateType = 2;
        if ($("#PlanType_0check")[0].checked == true) {
            planDateType = 1;
        }
        else if ($("#PlanType_0check")[0].checked == true) {
            planDateType = 2;
        }
        var syFPMoney = app.FormatNumber(parseFloat(payFPMoney),"moneybox");
        var prePlanDate = new Date();
        var bfb = 100;
        var curPlanDate = new Date();
        if (newpos > 0) {
            syFPMoney = app.FormatNumber(parseFloat(payFPMoney) - parseFloat(lvw.currsums[1]), "moneybox");
            bfb -= parseFloat(lvw.currsums[2]);
            prePlanDate = lvw.rows[newpos - 1][3];
        }
        if (planDateType == 1) {
            prePlanDate = new Date(prePlanDate);
            curPlanDate = prePlanDate.setYear(prePlanDate.getFullYear() + 1);
        }
        else if (planDateType == 2) {
            prePlanDate = new Date(prePlanDate);
            curPlanDate = prePlanDate.setMonth(prePlanDate.getMonth() + 1);
        }
        lvw.rows[newpos][0] = "第" + (newpos + 1) + "期";
        lvw.rows[newpos][1] = syFPMoney;
        lvw.rows[newpos][2] = bfb;
        lvw.rows[newpos][3] = new Date(curPlanDate).format("yyyy-MM-dd");
        lvw.rows[newpos][4] = "";
    }
}
function getHtId(billType) {
    var data = [];
    data.push("__BillTypeId=" + 73001);
    var catchFieldsStr = "cateid";//多参数的话|分割
    var catchFields = catchFieldsStr.split("|");
    for (var i = 0; i < catchFields.length; i++) {
        var catchField = catchFields[i];
        data.push(catchField + "=" + $("#" + catchField).val())
    }
    data.push("__CatchFields=" + encodeURIComponent(catchFieldsStr));
    if (window.setCatchFieldData) { window.setCatchFieldData(); }
    var xhttp = window.XMLHttpRequest ? (new XMLHttpRequest()) : (new ActiveXObject("Microsoft.XMLHTTP"));
    xhttp.open("POST", ((window.sysCurrPath ? (window.sysCurrPath + "../") : window.SysConfig.VirPath) + "SYSN/view/comm/GetBHValue.ashx?GB2312=1"), false);
    xhttp.setRequestHeader("content-type", "application/x-www-form-urlencoded");
    xhttp.send(data.join("&"));
    var obj = eval("(" + xhttp.responseText + ")");
    document.getElementById("cgid_0").value = "" + obj.code + "";
}

Bill.DoSave = function (cmdtag, buttonjson) {
    var lvw = window["lvw_JsonData_caigoulistmx"]

    if (typeof (lvw) != "undefined")
    {
        if (lvw.rows.length == 0 || (lvw.rows.length > 0 && lvw.rows[0][0] == window.ListView.NewRowSignKey)) {
            alert("不允许重复采购！");
            return;
        }
    }
    if (window.ListView) { ListView.ClearVerification() }
    if (Bill.BeforeGetDataHandleFormulaProc) { Bill.BeforeGetDataHandleFormulaProc(); }
    //获取文本框字段数据
    if (Bill.DataVerification(document.body) == false)  //单据数据校验
    {
        return false; //校验失败
    }
    if (Bill.Data.ord > 0 && $("#Money1_0").val() != $("#oldMoney1_0").val() && $("#newApprovers_0").length == 0 && $("#meetingApprove_0check").length == 0 && $("#UpdatePlan").val() == "") {
        if (!window.confirm("保存后更新[入库],[付款计划],[收票计划]单据中的价格，确认保存？"))
            return false;
    }
    Bill.DoSaveSub(cmdtag, "SysBillSave", buttonjson);
};

Bill.LoadEvents.cgidload = function () {
    BillExtSN.AfterRefresh = function () {
        var defaultT = document.getElementById("defaultT").value
        if (defaultT==1)
        return
        var isadd = Bill.Data.ord == 0;
        if (isadd || window.flag)
        {
            document.getElementById("Title_0").value = $("#Company").attr("texts") + document.getElementById("Cgid_0").value;
        }
        window.flag = true
    }
}
