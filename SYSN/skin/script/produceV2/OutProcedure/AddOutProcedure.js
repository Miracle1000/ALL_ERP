$(function () {
    $("body").on("click", "#lvw_outprocedurea .fielddel", function () {
        del_wwcpRow($(this));
        __lvw_je_btnhandle(this, 2)
    });

    $("body").on("change", ":input[id*='outprocedurea_num1_']", function () {
        change_outNum(this);
    });

    window.__lvw_je_batchDeleteAfter = batchDelAfter_wwcpRow;

    //点击左侧内容，触发右侧公式按照某一列计算
    window.ListView.OnAddRows = function (jlvw, rowindexs) {
        if (jlvw.id != "outprocedurea") { return; }
        var h = ListView.GetHeaderByDBName(jlvw, "num1");
        for (var i = 0; i < rowindexs.length; i++) {
            var rowindex = rowindexs[i];
            window.onlvwUpdateCellValue(jlvw, rowindex, h.i, jlvw.rows[rowindex][h.i], 0, 0, 0, "");
        }
        ListView.AutoExecLvwFormula(jlvw, 0);
        ListView.AutoExecLvwFormula(jlvw, 0);
    }
    window.ListView.OnRemoveRows = function (jlvw) {
        ListView.AutoExecLvwFormula(jlvw, 0);
    }
});

function SetOutprocedureaItem() {
    var jlvw = window['lvw_JsonData_outprocedurea'];
    var h = ListView.GetHeaderByDBName(jlvw, "num1");
    for (var i = 0; i < jlvw.rows.length; i++) {
        var rowindex = i;
        window.onlvwUpdateCellValue(jlvw, rowindex, h.i, jlvw.rows[rowindex][h.i], 0, 0, 0, "");
    }
    ListView.AutoExecLvwFormula(jlvw, 0);
    ___RefreshListViewByJson(lvw);
}

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

//删除委外产品列表行
var del_wwcpRow = function (_this) {
    var cellindex_WFPAID = 0;
    var headers = lvw_JsonData_outprocedurea.headers;
    var rows = lvw_JsonData_outprocedurea.rows;
    for (var i = 0; i < headers.length; i++) {
        if (headers[i].dbname == 'WFPAID') {
            cellindex_WFPAID = i;
            break;
        }
    }

    var rowindex = _this.parents("tr:first").attr("pos");
    var WFPAID = rows[rowindex][cellindex_WFPAID];

    del_sxwlRow(WFPAID);
}

//批量删除委外产品列表行后执行操作
var batchDelAfter_wwcpRow = function (lvw) {
    var lvw_wl = lvw_JsonData_OutOrderWLdata;
    var cellindex_wfpaid = 0;
    var headers = lvw_wl.headers;
    for (var i = 0; i < headers.length; i++) {
        if (headers[i].dbname == 'WFPAID') {
            cellindex_wfpaid = i;
            break;
        }
    }
    var rows = lvw_wl.rows;
    if (rows.length == 1 && rows[0][0].indexOf('NewRowSign') > 0) return;
    var isCanDel;
    var temp_molist = 0;
    var lvw_cellindex_wfpaid = 0;
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == 'WFPAID') {
            lvw_cellindex_wfpaid = i;
            break;
        }
    }

    for (var i = 0; i < rows.length; i++) {
        temp_molist = rows[i][cellindex_wfpaid];
        isCanDel = true;
        for (var ii = 0; ii < lvw.rows.length; ii++) {
            if (lvw.rows[ii][lvw_cellindex_wfpaid] == temp_molist) {
                isCanDel = false;
                break;
            }
        }

        if (isCanDel) {
            rows.splice(i, 1);
            i--;
            continue;
        }
    }

    ___RefreshListViewByJson(lvw_wl);
}

//根据订单明细ID,联动删除所需物料行
var del_sxwlRow = function (_WFPAID) {
    var lvw = lvw_JsonData_OutOrderWLdata;
    var cellindex_WFPAID = 0;
    var headers = lvw.headers;
    for (var i = 0; i < headers.length; i++) {
        if (headers[i].dbname == 'WFPAID') {
            cellindex_WFPAID = i;
            break;
        }
    }
    var rows = lvw.rows;
    if (rows.length == 1 && rows[0][0].indexOf('NewRowSign') > 0) return;
    for (var i = 0; i < rows.length; i++) {
        if (rows[i][cellindex_WFPAID] == _WFPAID) {
            rows.splice([i], 1);
            i--;
            continue;
        }
    }

    ___RefreshListViewByJson(lvw);
}

//委外数量变更联动
var change_outNum = function (_this) {
    var uiState = Bill.Data.uistate;

    if (uiState != "add" && uiState != "modify")
        return;

    //批量录入操作
    if (_this.id.indexOf("_num1_-1_") > -1) {
        update_needNum($(_this).val(), null);
        return;
    }

    var cellindex_WFPAID = 0;
    var headers = lvw_JsonData_outprocedurea.headers;
    var rows = lvw_JsonData_outprocedurea.rows;
    for (var i = 0; i < headers.length; i++) {
        if (headers[i].dbname == 'WFPAID') {
            cellindex_WFPAID = i;
            break;
        }
    }

    var rowindex = $(_this).parents("tr:first").attr("pos");
    var WFPAID = rows[rowindex][cellindex_WFPAID];

    if (!isNaN(WFPAID) && WFPAID > 0)
        update_needNum($(_this).val(), WFPAID);
}

//根据委外数量变动联动变更所需物料的所需数量
//_WFPAID为null时为批量处理
var update_needNum = function (_num1, _WFPAID) {
    var lvw = lvw_JsonData_OutOrderWLdata;
    var cellindex_bl = 0;
    var cellindex_num = 0;
    var cellindex_WFPAID = 0;
    var headers = lvw.headers;
    for (var i = 0; i < headers.length; i++) {
        if (headers[i].dbname == 'num') {
            cellindex_num = i;
            continue;
        }
        if (headers[i].dbname == 'bl') {
            cellindex_bl = i;
            continue;
        }
        if (headers[i].dbname == 'WFPAID') {
            cellindex_WFPAID = i;
            continue;
        }
    }

    var rows = lvw.rows;
    if (rows.length == 1 && rows[0][0].indexOf('NewRowSign') > 0) return;
    for (var i = 0; i < rows.length; i++) {
        if (_WFPAID == null || rows[i][cellindex_WFPAID] == _WFPAID) {
            rows[i][cellindex_num] = _num1 * rows[i][cellindex_bl];
        }
    }

    ___RefreshListViewByJson(lvw);
}

//历史数据整单优惠金额清零
function DiscountClearance() {
    if (confirm("整单优惠金额清零并保存后不可恢复，确认清零？")) {
        $("div.sub-field-childparent[dbname='yhmoney']  input").val(app.FormatNumber(0, "moneybox"));
        //找个字段更新下，为了刷新listview触发公式联动运算，弊端是没有明细时会产生一个空行
        var lvw = lvw_JsonData_outprocedurea;
        var deltitleidx = -1;
        for (var i = 0; i < lvw.headers.length; i++) {
            if (lvw.headers[i].dbname == "deltitle") { deltitleidx = i; break; }
        }
        __lvw_je_updateCellValue(lvw.id, 0, deltitleidx, lvw.rows[0][deltitleidx], false);
        $("#ClearingBtn").attr("disabled", "disabled");
        $("#ShareToConcessionsBtn").attr("disabled", "disabled");
    }
}

//历史数据整单优惠金额分摊
function PreferentialAllocation() {
    var yhShare = $("div.sub-field-childparent[dbname='yhmoney']  input").val();
    if (yhShare && yhShare > 0) {
        if (confirm("整单优惠金额将按总价比例分配至各明细优惠中，确认分摊？")) {
            var premoney = $("div.sub-field[dbname='premoney']  input").val().replace(/\,/g, "");
            var lvw = lvw_JsonData_outprocedurea;
            var concessionsidx = -1;
            var moneyAfterTaxidx = -1;
            for (var i = 0; i < lvw.headers.length; i++) {
                if (lvw.headers[i].dbname == "Concessions") { concessionsidx = i;}
                else if (lvw.headers[i].dbname == "moneyAfterTax") { moneyAfterTaxidx = i; }
                if (concessionsidx > 0 && moneyAfterTaxidx > 0) { break;}
            }
            $("div.sub-field-childparent[dbname='yhmoney']  input").val(app.FormatNumber(0, "moneybox"));
            var agvM = new Number(0);
            var agvS = new Number(0);
            for (var i = 0; i < lvw.rows.length; i++) {
                agvM = app.FormatNumber(lvw.rows[i][moneyAfterTaxidx] / premoney * yhShare, "moneybox");
                if (i == lvw.rows.length - 1) {
                    //最后一行分摊用减法
                    agvM = yhShare - agvS
                }
                else {
                    agvS += new Number(agvM);
                }
                __lvw_je_updateCellValue(lvw.id, i, concessionsidx, new Number(lvw.rows[i][concessionsidx]) + new Number(agvM), false);
            }
            $("#ClearingBtn").attr("disabled", "disabled");
            $("#ShareToConcessionsBtn").attr("disabled", "disabled");
        }
    }
}

window.onlvwUpdateCellValue = function (lvw, rowindex, cellindex, v, isztlr, isEof, disrefresh, oldvalue) {
    if (lvw.id != "outprocedurea") { return; }
    if (window.___Refreshinglvw == true) return;
    if (window.IsListviewAddRows == true) return;
    if (oldvalue == v) { return; }
    var header = lvw.headers[cellindex];
    var dbname = header.dbname;
    switch (dbname) {
        case "num1":    //数量
            //税后总价
            ListView.EvalCellFormula(lvw, rowindex, "moneyAfterTax", "app.FormatNumber(priceAfterTax * num1,'moneybox')");
            //优惠后总价
            ListView.EvalCellFormula(lvw, rowindex, "TaxDstYhMoney", "priceAfterTax * num1 - Concessions");
            //金额
            ListView.EvalCellFormula(lvw, rowindex, "money1", "(priceAfterTax * num1 - Concessions)/(1+taxRate*0.01)");
            //税额
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", "priceAfterTax * num1 - Concessions - (priceAfterTax * num1 - Concessions)/(1+taxRate*0.01)");
            //优惠后单价
            ListView.EvalCellFormula(lvw, rowindex, "TaxDstYhPrice", "app.FormatNumber(((priceAfterTax * num1 - Concessions)/num1),'moneybox')");
            //更新字段
            window.ListView.RefreshCellUI(lvw, rowindex, "moneyAfterTax,TaxDstYhMoney,money1,taxValue,TaxDstYhPrice,Concessions", 100);
            break;
        case "price1":  //未税单价
            //含税单价
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "price1 * (1+taxRate*0.01)");
            //税后总价
            ListView.EvalCellFormula(lvw, rowindex, "moneyAfterTax", "app.FormatNumber(priceAfterTax * num1,'moneybox')");
            //优惠后总价
            ListView.EvalCellFormula(lvw, rowindex, "TaxDstYhMoney", "priceAfterTax * num1 - Concessions");
            //金额
            ListView.EvalCellFormula(lvw, rowindex, "money1", "(priceAfterTax * num1 - Concessions)/(1+taxRate*0.01)");
            //税额
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", "priceAfterTax * num1 - Concessions - (priceAfterTax * num1 - Concessions)/(1+taxRate*0.01)");
            //优惠后单价
            ListView.EvalCellFormula(lvw, rowindex, "TaxDstYhPrice", "app.FormatNumber(((priceAfterTax * num1 - Concessions)/num1),'moneybox')");
            //更新字段
            window.ListView.RefreshCellUI(lvw, rowindex, "priceAfterTax,moneyAfterTax,TaxDstYhMoney,money1,taxValue,TaxDstYhPrice", 100);
            break;
        case "priceAfterTax": //含税单价
            //未税单价
            ListView.EvalCellFormula(lvw, rowindex, "price1", "priceAfterTax/(1+taxRate*0.01)");
            //税后总价
            ListView.EvalCellFormula(lvw, rowindex, "moneyAfterTax", "app.FormatNumber(priceAfterTax * num1,'moneybox')");
            //优惠后总价
            ListView.EvalCellFormula(lvw, rowindex, "TaxDstYhMoney", "priceAfterTax * num1 - Concessions");
            //金额
            ListView.EvalCellFormula(lvw, rowindex, "money1", "(priceAfterTax * num1 - Concessions)/(1+taxRate*0.01)");
            //税额
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", "priceAfterTax * num1 - Concessions - (priceAfterTax * num1 - Concessions)/(1+taxRate*0.01)");
            //优惠后单价
            ListView.EvalCellFormula(lvw, rowindex, "TaxDstYhPrice", "app.FormatNumber(((priceAfterTax * num1 - Concessions)/num1),'moneybox')");
            //更新字段
            window.ListView.RefreshCellUI(lvw, rowindex, "price1,moneyAfterTax,TaxDstYhMoney,money1,taxValue,TaxDstYhPrice", 100);
            break;
        case "taxRate": //税率
            //金额
            ListView.EvalCellFormula(lvw, rowindex, "money1", "(priceAfterTax * num1 - Concessions)/(1+taxRate*0.01)");
            //税额
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", "priceAfterTax * num1 - Concessions - (priceAfterTax * num1 - Concessions)/(1+taxRate*0.01)");
            //未税单价
            ListView.EvalCellFormula(lvw, rowindex, "price1", "priceAfterTax/(1+taxRate*0.01)");
            //更新字段
            window.ListView.RefreshCellUI(lvw, rowindex, "money1,taxValue,price1", 100);
            break;
        case "moneyAfterTax":   //税后总价
            //优惠后总价
            ListView.EvalCellFormula(lvw, rowindex, "TaxDstYhMoney", "moneyAfterTax-Concessions");
            //优惠后单价
            ListView.EvalCellFormula(lvw, rowindex, "TaxDstYhPrice", "(moneyAfterTax-Concessions)/num1");
            //金额
            ListView.EvalCellFormula(lvw, rowindex, "money1", "(moneyAfterTax-Concessions)/(1+taxRate*0.01)");
            //税额
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", "moneyAfterTax-Concessions - (moneyAfterTax-Concessions)/(1+taxRate*0.01)");
            //未税单价
            ListView.EvalCellFormula(lvw, rowindex, "price1", "moneyAfterTax / num1 /(1+taxRate*0.01)");
            //含税单价
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "moneyAfterTax/ num1");
            //更新字段
            window.ListView.RefreshCellUI(lvw, rowindex, "TaxDstYhMoney,TaxDstYhPrice,money1,taxValue,price1,priceAfterTax", 100);
            break;
        case "money1":   //金额
            //优惠后总价
            ListView.EvalCellFormula(lvw, rowindex, "TaxDstYhMoney", "money1*(1+taxRate*0.01)");
            //优惠后单价
            ListView.EvalCellFormula(lvw, rowindex, "TaxDstYhPrice", "TaxDstYhMoney/num1");
            //税额
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", "TaxDstYhMoney - money1");
            //税后总价
            ListView.EvalCellFormula(lvw, rowindex, "moneyAfterTax", "app.FormatNumber(TaxDstYhMoney+Concessions,'moneybox')");
            //含税单价
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "(TaxDstYhMoney+Concessions)/ num1");
            //未税单价
            ListView.EvalCellFormula(lvw, rowindex, "price1", "(TaxDstYhMoney+Concessions)/ num1 /(1+taxRate*0.01)");
            //更新字段
            window.ListView.RefreshCellUI(lvw, rowindex, "TaxDstYhMoney,TaxDstYhPrice,taxValue,moneyAfterTax,priceAfterTax,price1", 100);
            break;
        case "Concessions": //明细优惠
            //优惠后总价
            ListView.EvalCellFormula(lvw, rowindex, "TaxDstYhMoney", "priceAfterTax * num1 - Concessions");
            //优惠后单价
            ListView.EvalCellFormula(lvw, rowindex, "TaxDstYhPrice", "(priceAfterTax * num1 - Concessions)/num1");
            //金额
            ListView.EvalCellFormula(lvw, rowindex, "money1", "(priceAfterTax * num1 - Concessions)/(1+taxRate*0.01)");
            //税额
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", "priceAfterTax * num1 - Concessions - (priceAfterTax * num1 - Concessions)/(1+taxRate*0.01)");
            //更新字段
            window.ListView.RefreshCellUI(lvw, rowindex, "TaxDstYhMoney,TaxDstYhPrice,money1,taxValue", 100);
            break;
        case "TaxDstYhMoney":  //优惠后总价
            //优惠后单价
            ListView.EvalCellFormula(lvw, rowindex, "TaxDstYhPrice", "TaxDstYhMoney/num1");
            //税后总价
            ListView.EvalCellFormula(lvw, rowindex, "moneyAfterTax", "app.FormatNumber(TaxDstYhMoney+Concessions,'moneybox')");
            //含税单价
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "(TaxDstYhMoney+Concessions)/ num1");
            //金额
            ListView.EvalCellFormula(lvw, rowindex, "money1", "TaxDstYhMoney/(1+taxRate*0.01)");
            //税额
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", "TaxDstYhMoney - TaxDstYhMoney/(1+taxRate*0.01)");
            //未税单价
            ListView.EvalCellFormula(lvw, rowindex, "price1", "(TaxDstYhMoney+Concessions)/ num1 /(1+taxRate*0.01)");
            //更新字段
            window.ListView.RefreshCellUI(lvw, rowindex, "TaxDstYhPrice,moneyAfterTax,priceAfterTax,money1,taxValue,price1", 100);
            break;
    }
    ListView.ApplyCellSumsData(lvw, [ListView.GetHeaderByDBName(lvw, "moneyAfterTax").i]);
}