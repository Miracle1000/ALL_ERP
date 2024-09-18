var DATE_FORMAT = /^[0-9]{4}-[0-1]?[0-9]{1}-[0-3]?[0-9]{1}$/;

window.onlvwUpdateCellValue = function (lvw, rowindex, cellindex, v, isztlr, isEof, disrefresh, oldvalue) {
    if (window.___Refreshinglvw == true) return;
    if (window.IsListviewAddRows == true) return;
    if (oldvalue == v) { return; }
    var header = lvw.headers[cellindex];
    var dbname = header.dbname;
    if (v == undefined || v == null || v == "") { v = 0 }
    if (lvw.id == "contractlist") {
        var taxRate = lvw.rows[rowindex][ListView.GetHeaderByDBName(lvw, "taxRate").i];
        var includeTax = lvw.rows[rowindex][ListView.GetHeaderByDBName(lvw, "includeTax").i];
        if (taxRate == undefined || taxRate == null || taxRate == "") { taxRate = 0 }
        var num1 = lvw.rows[rowindex][ListView.GetHeaderByDBName(lvw, "num1").i];
        taxRate = taxRate * 0.01;
        switch (dbname) {
            case "num1":					//数量发生更改
                //含税总价
                ListView.EvalCellFormula(lvw, rowindex, "moneyAfterTax", "priceIncludeTax * discount * num1");
                //优惠后总价
                ListView.EvalCellFormula(lvw, rowindex, "money1", "priceIncludeTax * discount * num1 - concessions");
                //金额
                ListView.EvalCellFormula(lvw, rowindex, "moneyAfterConcessions", "(priceIncludeTax * discount * num1 - concessions)/(1+taxRate*0.01)");
                //税额
                ListView.EvalCellFormula(lvw, rowindex, "taxValue", "priceIncludeTax * discount * num1 - concessions - (priceIncludeTax * discount * num1 - concessions)/(1+taxRate*0.01)");
                //优惠后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "(priceIncludeTax * discount * num1 - concessions)/num1");
                //税前总价
                ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "price1 * discount * num1");

                window.ListView.RefreshCellUI(lvw, rowindex, "priceAfterTax,moneyBeforeTax,moneyAfterTax,money1,moneyAfterConcessions,taxValue", 100);

                CurrFormulaInfoHandle(lvw, rowindex, cellindex, "commUnitAttr", num1);

                break;
            case "concessions":
                //优惠后总价
                ListView.EvalCellFormula(lvw, rowindex, "money1", "priceIncludeTax * discount * num1 - concessions");
                //金额
                ListView.EvalCellFormula(lvw, rowindex, "moneyAfterConcessions", "(priceIncludeTax * discount * num1 - concessions)/(1+taxRate*0.01)");
                //税额
                ListView.EvalCellFormula(lvw, rowindex, "taxValue", "priceIncludeTax * discount * num1 - concessions - (priceIncludeTax * discount * num1 - concessions)/(1+taxRate*0.01)");
                //优惠后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "(priceIncludeTax * discount * num1 - concessions)/num1");

                window.ListView.RefreshCellUI(lvw, rowindex, "priceAfterTax,money1,moneyAfterConcessions,taxValue", 100);
                break;
            case "price1":					 // 未税单价发生更改
                //税前折后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", "price1 * discount");
                //含税单价
                ListView.EvalCellFormula(lvw, rowindex, "priceIncludeTax", "price1 * (1+taxRate*0.01)");
                //含税折后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTaxPre", "priceIncludeTax * discount");
                //含税总价
                ListView.EvalCellFormula(lvw, rowindex, "moneyAfterTax", "priceIncludeTax * discount * num1");
                //优惠后总价
                ListView.EvalCellFormula(lvw, rowindex, "money1", "priceIncludeTax * discount * num1 - concessions");
                //金额
                ListView.EvalCellFormula(lvw, rowindex, "moneyAfterConcessions", "(priceIncludeTax * discount * num1 - concessions)/(1+taxRate*0.01)");
                //税额
                ListView.EvalCellFormula(lvw, rowindex, "taxValue", "priceIncludeTax * discount * num1 - concessions - (priceIncludeTax * discount * num1 - concessions)/(1+taxRate*0.01)");
                //优惠后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "(priceIncludeTax * discount * num1 - concessions)/num1");
                //税前总价
                ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "price1 * discount * num1");

                window.ListView.RefreshCellUI(lvw, rowindex, "priceIncludeTax,priceAfterTaxPre,priceAfterDiscount,priceAfterTax,moneyBeforeTax,moneyAfterTax,money1,moneyAfterConcessions,taxValue", 100);
                break;
            case "discount":				// 折扣发生改变
                //含税折后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTaxPre", "priceIncludeTax * discount");
                //税前折后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", "priceIncludeTax/(1+taxRate*0.01) * discount");
                //含税总价
                ListView.EvalCellFormula(lvw, rowindex, "moneyAfterTax", "priceIncludeTax * discount * num1");
                //优惠后总价
                ListView.EvalCellFormula(lvw, rowindex, "money1", "priceIncludeTax * discount * num1 - concessions");
                //金额
                ListView.EvalCellFormula(lvw, rowindex, "moneyAfterConcessions", "(priceIncludeTax * discount * num1 - concessions)/(1+taxRate*0.01)");
                //税额
                ListView.EvalCellFormula(lvw, rowindex, "taxValue", "priceIncludeTax * discount * num1 - concessions - (priceIncludeTax * discount * num1 - concessions)/(1+taxRate*0.01)");
                //优惠后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "(priceIncludeTax * discount * num1 - concessions)/num1");
                //税前总价
                ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "price1 * discount * num1");

                window.ListView.RefreshCellUI(lvw, rowindex, "priceAfterTaxPre,priceAfterDiscount,priceAfterTax,moneyBeforeTax,moneyAfterTax,money1,moneyAfterConcessions,taxValue", 100);
                break;
            case "priceIncludeTax":         //含税单价
                //税前单价
                ListView.EvalCellFormula(lvw, rowindex, "price1", "priceIncludeTax/(1+taxRate*0.01)");
                //含税折后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTaxPre", "priceIncludeTax * discount");
                //税前折后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", "priceIncludeTax/(1+taxRate*0.01) * discount");
                //含税总价
                ListView.EvalCellFormula(lvw, rowindex, "moneyAfterTax", "priceIncludeTax * discount * num1");
                //优惠后总价
                ListView.EvalCellFormula(lvw, rowindex, "money1", "priceIncludeTax * discount * num1 - concessions");
                //金额
                ListView.EvalCellFormula(lvw, rowindex, "moneyAfterConcessions", "(priceIncludeTax * discount * num1 - concessions)/(1+taxRate*0.01)");
                //税额
                ListView.EvalCellFormula(lvw, rowindex, "taxValue", "priceIncludeTax * discount * num1 - concessions - (priceIncludeTax * discount * num1 - concessions)/(1+taxRate*0.01)");
                //优惠后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "(priceIncludeTax * discount * num1 - concessions)/num1");
                //税前总价
                ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "priceIncludeTax/(1+taxRate*0.01) * discount * num1");
                //更新字段
                window.ListView.RefreshCellUI(lvw, rowindex, "priceAfterTaxPre,price1,priceAfterDiscount,priceAfterTax,moneyBeforeTax,moneyAfterTax,money1,moneyAfterConcessions,taxValue", 100);
                break;
            case "taxRate":                 //税率发生更改
                //税前单价
                ListView.EvalCellFormula(lvw, rowindex, "price1", "priceIncludeTax/(1+taxRate*0.01)");
                //含税折后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTaxPre", "priceIncludeTax * discount");
                //税前折后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", "priceIncludeTax/(1+taxRate*0.01) * discount");
                //含税总价
                ListView.EvalCellFormula(lvw, rowindex, "moneyAfterTax", "priceIncludeTax * discount * num1");
                //优惠后总价
                ListView.EvalCellFormula(lvw, rowindex, "money1", "priceIncludeTax * discount * num1 - concessions");
                //金额
                ListView.EvalCellFormula(lvw, rowindex, "moneyAfterConcessions", "(priceIncludeTax * discount * num1 - concessions)/(1+taxRate*0.01)");
                //税额
                ListView.EvalCellFormula(lvw, rowindex, "taxValue", "priceIncludeTax * discount * num1 - concessions - (priceIncludeTax * discount * num1 - concessions)/(1+taxRate*0.01)");
                //优惠后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "(priceIncludeTax * discount * num1 - concessions)/num1");
                //税前总价
                ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "priceIncludeTax/(1+taxRate*0.01) * discount * num1");
                //更新字段
                window.ListView.RefreshCellUI(lvw, rowindex, "priceAfterTaxPre,price1,priceAfterDiscount,priceAfterTax,moneyBeforeTax,moneyAfterTax,money1,moneyAfterConcessions,taxValue", 100);
                break;
            case "moneyAfterTax":		//含税总价
                //优惠后总价
                ListView.EvalCellFormula(lvw, rowindex, "money1", "moneyAfterTax-concessions");
                //优惠后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "(moneyAfterTax-concessions)/num1");
                //金额
                ListView.EvalCellFormula(lvw, rowindex, "moneyAfterConcessions", "(moneyAfterTax-concessions)/(1+taxRate*0.01)");
                //税额
                ListView.EvalCellFormula(lvw, rowindex, "taxValue", "moneyAfterTax-concessions - (moneyAfterTax-concessions)/(1+taxRate*0.01)");
                //含税折后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTaxPre", "moneyAfterTax/ num1");
                //含税单价
                ListView.EvalCellFormula(lvw, rowindex, "priceIncludeTax", "moneyAfterTax/ num1 / discount");
                //税前单价
                ListView.EvalCellFormula(lvw, rowindex, "price1", "moneyAfterTax/ num1 / discount /(1+taxRate*0.01)");
                //税前折后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", "moneyAfterTax/ num1/(1+taxRate*0.01)");
                //税前总价
                ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "moneyAfterTax/(1+taxRate*0.01)");
                //更新字段
                window.ListView.RefreshCellUI(lvw, rowindex, "priceIncludeTax,priceAfterTaxPre,price1,priceAfterDiscount,priceAfterTax,moneyBeforeTax,money1,moneyAfterConcessions,taxValue", 100);
                break;
            case "moneyAfterConcessions":		//金额
                //优惠后总价
                ListView.EvalCellFormula(lvw, rowindex, "money1", "moneyAfterConcessions*(1+taxRate*0.01)");
                //优惠后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "money1/num1");
                //税额
                ListView.EvalCellFormula(lvw, rowindex, "taxValue", "money1 - moneyAfterConcessions");
                //含税总价
                ListView.EvalCellFormula(lvw, rowindex, "moneyAfterTax", "money1+concessions");
                //含税折后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTaxPre", "(money1+concessions)/ num1");
                //含税单价
                ListView.EvalCellFormula(lvw, rowindex, "priceIncludeTax", "(money1+concessions)/ num1 / discount");
                //税前单价
                ListView.EvalCellFormula(lvw, rowindex, "price1", "(money1+concessions)/ num1 / discount /(1+taxRate*0.01)");
                //税前折后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", "(money1+concessions)/ num1/(1+taxRate*0.01)");
                //税前总价
                ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "(money1+concessions)/(1+taxRate*0.01)");
                //更新字段
                window.ListView.RefreshCellUI(lvw, rowindex, "priceIncludeTax,priceAfterTaxPre,price1,priceAfterDiscount,priceAfterTax,moneyBeforeTax,moneyAfterTax,money1,taxValue", 100);
                break;
            case "money1":				//优惠后总价发生更改
                //金额
                ListView.EvalCellFormula(lvw, rowindex, "moneyAfterConcessions", "money1/(1+taxRate*0.01)");
                //税额
                ListView.EvalCellFormula(lvw, rowindex, "taxValue", "money1 - money1/(1+taxRate*0.01)");
                //优惠后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "money1/num1");
                //含税总价
                ListView.EvalCellFormula(lvw, rowindex, "moneyAfterTax", "money1+concessions");
                //含税折后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTaxPre", "(money1+concessions)/ num1");
                //含税单价
                ListView.EvalCellFormula(lvw, rowindex, "priceIncludeTax", "(money1+concessions)/ num1 / discount");
                //税前单价
                ListView.EvalCellFormula(lvw, rowindex, "price1", "(money1+concessions)/ num1 / discount /(1+taxRate*0.01)");
                //税前折后单价
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", "(money1+concessions)/ num1/(1+taxRate*0.01)");
                //税前总价
                ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "(money1+concessions)/(1+taxRate*0.01)");
                //更新字段
                window.ListView.RefreshCellUI(lvw, rowindex, "priceIncludeTax,priceAfterTaxPre,price1,priceAfterDiscount,priceAfterTax,moneyBeforeTax,moneyAfterTax,moneyAfterConcessions,taxValue", 100);
                break;

        }
        ListView.ApplyCellSumsData(lvw, [ListView.GetHeaderByDBName(lvw, 'moneyAfterTax').i]);
    }
}

Bill.LoadEvents.htidload = function () {
    var FromType = document.getElementById("FromType").value
    var defaultT = document.getElementById("defaultT").value
    var isadd = Bill.Data.ord == 0;
    try {
        BillExtSN.AfterRefresh = function () {
            if (defaultT == 1 && FromType != "" && FromType != 6)
                return
            if (isadd || window.flag) {
                setTimeout(function () {
                    setDefaultTitle();
                }, 500);
            }
            window.flag = true
        }
    }
    catch (ex) {
        if (defaultT == 2 && (isadd || window.flag))
            setTimeout(function () {
                setDefaultTitle();
            }, 500);
    }
}

$(function () {
    $('#contractlist_fbg').attr("bill_field_notnull",0)
    $('#bomTreeList_btn').click(function () {
        bomlist(Bill.Data.ord);
    });
    //重写是为了提示先选择供应商
    //JSON模式编辑.插入新行
    __lvw_je_addNew = function (id, disrefresh) {
        var lvw = window["lvw_JsonData_" + id];
        var payFPMoney=0
        if (id == "paybacklist") {
            if (typeof ($("#htmoney1_0").val()) == "undefined") {               
                payFPMoney = $("#Money1_0").val();
            }
            else {
                payFPMoney = $("#htmoney1_0").val();
            }
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
        $('#paybacklist_fbg').attr("bill_field_notnull", 0)
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
                if (id == "paybacklist") {
                    var payFPMoney=0
                    if (typeof ($("#htmoney1_0").val()) == "undefined") {
                        payFPMoney = $("#Money1_0").val();
                    }
                    else {
                        payFPMoney = $("#htmoney1_0").val();
                    }
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
                for (var i = pos; i <= (rowspan * 1 + pos - 1) ; i++) {
                    __lvw_je_deleteCurRow(lvw, pos);
                    //删除完之后做特殊处理
                    if (id == "paybacklist") {
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
        if (lvwid == "caigoulist" && $("#Company_tit").val() == "" && (Bill.GetField("company").value == undefined || Bill.GetField("company").value == "0")) {
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
    if (id == "paybacklist") {
        var lvw = window["lvw_JsonData_" + id];
        var payFPMoney = 0
        if (typeof ($("#htmoney1_0").val()) == "undefined") {         
            payFPMoney = $("#Money1_0").val();
        }
        else {
            payFPMoney = $("#htmoney1_0").val();
        }
        payFPMoney=payFPMoney.replace(/,/g, '')
        var planDateType = 2;
        if ($("#PlanType_0check")[0].checked == true) {
            planDateType = 1;
        }
        else if ($("#PlanType_0check")[0].checked == true) {
            planDateType = 2;
        }
        var syFPMoney = parseFloat(payFPMoney);
        var prePlanDate = new Date();
        var bfb = 100;
        var curPlanDate = new Date();
        if (newpos > 0) {
            syFPMoney = parseFloat(payFPMoney) - parseFloat(lvw.currsums[1]);
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

function bomlist(ord) {
    var lvw = window["lvw_JsonData_contractlist"];
    var headers = lvw.headers;
    var _ord = -1;
    var _unit = -1;
    var _num1 = -1;
    var _intro = -1;
    var _date2 = -1;
    var _treeOrd = -1;
    var _ProductAttr1 = -1;
    var _ProductAttr2 = -1;
    var rows = lvw.rows;
    var lvw = window["lvw_JsonData_contractlist"];
    if(lvw.rows.length == 0 ||(lvw.rows.length>0 && lvw.rows[0][0] == window.ListView.NewRowSignKey)){
        app.PopMessage("请先选择明细！");
        return;
    }

    //获取选择列下标
    for (var i = 0; i < headers.length; i++) {
        var h = headers[i];
        if (h.dbname == "ord") {
            _ord = i;
        }
        if (h.dbname == "unit") {
            _unit = i;
        }
        if (h.dbname == "num1") {
            _num1 = i;
        }
        if (h.dbname == "intro") {
            _intro = i;
        }
        if (h.dbname == "date2") {
            _date2 = i;
        }
        if (h.dbname == "treeOrd") {
            _treeOrd = i;
        }
        if (h.dbname == "ProductAttr1") {
            _ProductAttr1 = i;
        }
        if (h.dbname == "ProductAttr2") {
            _ProductAttr2 = i;
        }
    }
    var sql = "select ROW_NUMBER() over(order by aa.xuhao) id,aa.* into #temp from (";
    for (var i = 0; i < rows.length; i++) {
        if (lvw.rows[i][0] == window.ListView.NewRowSignKey) { continue; }
        chooseLine = true;
        var rowindex = lvw.rows[i][0];
        var v5 = lvw.rows[i][_treeOrd] == "" ? 0 : lvw.rows[i][_treeOrd]
        var v = lvw.rows[i][_intro] == "" || lvw.rows[i][_intro] == null || typeof (lvw.rows[i][_intro]) === "undefined" ? "" : lvw.rows[i][_intro].replace(/\ +/g, "").replace(/[\r\n]/g, "")
        var v1 = lvw.rows[i][_date2] == "" || lvw.rows[i][_date2] == null || typeof (lvw.rows[i][_date2]) === "undefined" || !(lvw.rows[i][_date2] instanceof Date) ? "" : lvw.rows[i][_date2]
        var v2 = (lvw.rows[i][_ord] == "" || typeof (lvw.rows[i][_ord]) == "undefined") ? 0 : lvw.rows[i][_ord]
        var v3 = (typeof (lvw.rows[i][_unit].fieldvalue) != "undefined" && lvw.rows[i][_unit].fieldvalue != "") ? lvw.rows[i][_unit].fieldvalue : 0;
        var v4 = lvw.rows[i][_num1] == "" ? 0 : lvw.rows[i][_num1]
        var v6 = (typeof (lvw.rows[i][_ProductAttr1].fieldvalue) != "undefined" && lvw.rows[i][_ProductAttr1].fieldvalue != "") ? lvw.rows[i][_ProductAttr1].fieldvalue : 0;
        var v7 = (typeof (lvw.rows[i][_ProductAttr2].fieldvalue) != "undefined" && lvw.rows[i][_ProductAttr2].fieldvalue != "") ? lvw.rows[i][_ProductAttr2].fieldvalue : 0;
        sql += sql != "select ROW_NUMBER() over(order by aa.xuhao) id,aa.* into #temp from (" ? "   union all select " + i + " xuhao," + rowindex + "  mxindex, " + v2 + " ord," + v3 + " unit," + v4 + "   num1,'" + v + "' intro,'" + v1 + "'  date2," + v5 + " treeOrd," + v6 + " ProductAttr1," + v7 + " ProductAttr2 " : "select " + i +" xuhao," + rowindex + "  mxindex," + v2 + " ord," + v3 + " unit," + v4 + " num1 ,'" + v + "' intro,'" + v1 + "'  date2 ," + v5 + "  treeOrd," + v6 + " ProductAttr1," + v7 + " ProductAttr2 ";
    }
    sql += " )aa "
    app.OpenUrl("../../../SYSA/BomList/Bom_Trees_List.asp?treeType=2&top=" + app.pwurl(ord) + "&afv_existssql=" + sql, 'price', "", "afv_existssql");
}

function checkDate(data){

    if(DATE_FORMAT.test(data)){

        return true;

    } else {

        return false;
    }

}

function updatelvwtreord(inx, num1, intro, date2, treord, price1) {
    var rowindex = inx;
    var jlvw = window["lvw_JsonData_contractlist"];
    var treord_ = ListView.GetHeaderByDBName(jlvw, "treeOrd").i;
    var num1_ = ListView.GetHeaderByDBName(jlvw, "num1").i;
    var intro_ = ListView.GetHeaderByDBName(jlvw, "intro").i;
    var date2_ = ListView.GetHeaderByDBName(jlvw, "date2").i;
    var priceIncludeTax_ = ListView.GetHeaderByDBName(jlvw, "priceIncludeTax").i;
    for (var i = 0; i < jlvw.rows.length; i++) {
        if (jlvw.rows[i][0] == rowindex) {
            jlvw.rows[i][treord_] = treord;
            jlvw.rows[i][num1_] = num1;
            jlvw.rows[i][intro_] = intro;
            jlvw.rows[i][date2_] = date2;
            jlvw.rows[i][priceIncludeTax_] = price1;
            __lvw_je_redrawCell(jlvw, jlvw.headers[date2_], i, jlvw.headers[date2_].showindex);
            __lvw_je_redrawCell(jlvw, jlvw.headers[num1_], i, jlvw.headers[num1_].showindex);
            __lvw_je_redrawCell(jlvw, jlvw.headers[intro_], i, jlvw.headers[intro_].showindex);
            __lvw_je_redrawCell(jlvw, jlvw.headers[priceIncludeTax_], i, jlvw.headers[priceIncludeTax_].showindex);
            onlvwUpdateCellValue(jlvw, i, num1_, num1)
            onlvwUpdateCellValue(jlvw, i, priceIncludeTax_, price1)
            $ID("lvw_dbtable_contractlist").click();
        }
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

function Reset() {
    $('#paybacklist_fbg').attr("bill_field_notnull", 0)
    var lvw = window['lvw_JsonData_paybacklist'];
    var Inx = ListView.GetHeaderByDBName(lvw, "Inx").i;//期次
    var paybackSureMoneyi = ListView.GetHeaderByDBName(lvw, "paybackSureMoney").i;//已收金额
    var clouminx = ListView.GetHeaderByDBName(lvw, "PayPlanMoney1").i;//金额
    var PayBFBinx = ListView.GetHeaderByDBName(lvw, "PayBFB").i;//百分比
    var Ismodeinx = ListView.GetHeaderByDBName(lvw, "Ismode").i;//判断能不能编辑
    var SurplusPayFPMoney1_0 = $("#SurplusPayFPMoney1_0").val().replace(",", "");;//待分配
    if (SurplusPayFPMoney1_0 == 0) return;
    var absSurplusPayFPMoney1 = Math.abs(SurplusPayFPMoney1_0);
    var sumpaymoney1 = 0;//已分配的总额
    var Add =SurplusPayFPMoney1_0 > 0;
    for (var i = lvw.rows.length - 1; i >= 0; i--) {
        var obj = $($ID("@paybacklist_PayPlanMoney1_" + (parseInt(i)) + "_" + clouminx + "_0"))[0];
        if (SurplusPayFPMoney1_0 < 0) {
            if (lvw.rows[i][Ismodeinx] == "0" || lvw.rows[i][Ismodeinx] == undefined) continue;//收款金额=计划金额不分配
            var money1 = parseFloat(app.FormatNumber(lvw.rows[i][clouminx], "moneybox")) - parseFloat(app.FormatNumber(lvw.rows[i][paybackSureMoneyi], "moneybox"))
            sumpaymoney1 += money1;
            if (sumpaymoney1 < absSurplusPayFPMoney1) {
                if (parseFloat(app.FormatNumber(lvw.rows[i][paybackSureMoneyi], "moneybox")) == 0) {
                    __lvw_je_deleteCurRow(lvw, i);
                }
                else {
                    var cellmoney1 = (parseFloat(app.FormatNumber(lvw.rows[i][clouminx], "moneybox")) - money1);
                    lvw.rows[i][clouminx] = cellmoney1
                    ListView._DCBack(obj, 'PayPlanMoney_CallBack', 1, 0, '');
                }
            }
            else {
                var cellmoney1 = (sumpaymoney1 - absSurplusPayFPMoney1);
                lvw.rows[i][clouminx] = cellmoney1             
                if (cellmoney1 == 0)
                    __lvw_je_deleteCurRow(lvw, i);
                ListView._DCBack(obj, 'PayPlanMoney_CallBack', 1, 0, '');
                break;
            }

        }
        else {
            if (lvw.rows[i][Ismodeinx]==0||lvw.rows[i][Ismodeinx] == undefined) continue;
            lvw.rows[i][clouminx] = parseFloat(app.FormatNumber(lvw.rows[i][clouminx], "moneybox")) + parseFloat(SurplusPayFPMoney1_0)
            ListView._DCBack(obj, 'PayPlanMoney_CallBack', 1, 0, '');
            SurplusPayFPMoney1_0=0
            break;
        }
    }
    if (SurplusPayFPMoney1_0 > 0) {
        __lvw_je_addNew("paybacklist")
    }
    ___ReSumListViewByJsonData(lvw)
    ___RefreshListViewByJson(lvw);
    ___RefreshListViewselPos(lvw);
    FormualLib.HandleFieldFormul(1, "SurplusPayFPMoney1", lvw);
}
//老数据优惠处理
function DiscountClearance(type)
{
    if (type == 0)//清0
        $("#yhmoney1_0").val(0);
    Bill._DCBack($("#yhmoney1_0"), 'YhMoney_CallBack', 2, 0, '');
}

function setDefaultTitle() {
    var defTitle = ($("#company").attr("texts") == "" ? $("#company").prev().text() : $("#company").attr("texts")) + document.getElementById("htid_0").value;
    document.getElementById("httitle_0").value = defTitle;
    document.getElementById("httitle_0").title = defTitle;
}