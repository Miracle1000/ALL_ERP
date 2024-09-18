window.OnListViewFormualUpdateCell = function (lvw, rowindex, cellindex, newv) {
    if (lvw.headers[cellindex].dbname != "taxRate") { return; }
    window.onlvwUpdateCellValue(lvw, rowindex, cellindex, newv, 0, 0, 0);
}

window.onlvwUpdateCellValue = function (lvw, rowindex, cellindex, v, isztlr, isEof, disrefresh, oldvalue) {
    if (window.___Refreshinglvw == true) { return; }
    if (oldvalue == v) { return; }
    var header = lvw.headers[cellindex];
    var dbname = header.dbname;
    var taxRate = lvw.rows[rowindex][ListView.GetHeaderByDBName(lvw, "taxRate").i];
    var includeTax = lvw.rows[rowindex][ListView.GetHeaderByDBName(lvw, "includeTax").i];
    if (taxRate == undefined || taxRate == null || taxRate == "") { taxRate = 0 }
    var num1 = lvw.rows[rowindex][ListView.GetHeaderByDBName(lvw, "num1").i];
    taxRate = taxRate * 0.01;
    if (v == undefined || v == null || v == "") { v = 0 }
    switch (dbname) {
        case "num1":					//数量发生更改
            ListView.EvalCellFormula(lvw, rowindex, "tpricejy", "pricejy*num1");
            ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "priceAfterDiscount*num1");
            ListView.EvalCellFormula(lvw, rowindex, "money1", "priceAfterTax * num1");
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", " priceAfterDiscount * num1 * taxRate * 0.01");
            CurrFormulaInfoHandle(lvw, rowindex, cellindex, "commUnitAttr", num1);
            window.ListView.RefreshCellUI(lvw, rowindex, "tpricejy,moneyBeforeTax,money1,taxValue", 100);
            break;
        case "price1":					 // 未税单价发生更改
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", "price1*discount");
            ListView.EvalCellFormula(lvw, rowindex, "priceIncludeTax", "price1*(1+taxRate*0.01)");    //{未税单价}*(1+{税率})
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "price1*(1+taxRate*0.01)*discount");

            ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "price1*discount*num1");
            ListView.EvalCellFormula(lvw, rowindex, "money1", "price1*(1+taxRate*0.01)*discount*num1");
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", " price1*discount*num1 * taxRate * 0.01");
            window.ListView.RefreshCellUI(lvw, rowindex, "priceAfterDiscount,moneyBeforeTax,priceIncludeTax,priceAfterTax,money1,taxValue", 100);
            break;
        case "discount":				// 折扣发生改变
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", "price1 * discount");
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "priceIncludeTax * discount");

            ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "price1 * discount * num1");
            ListView.EvalCellFormula(lvw, rowindex, "money1", "priceIncludeTax * discount * num1");
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", " price1 * discount * num1 * taxRate * 0.01");
            window.ListView.RefreshCellUI(lvw, rowindex, "priceAfterDiscount,moneyBeforeTax,priceAfterTax,money1,taxValue", 100);
            break;
        case "priceIncludeTax"://含税单价
            ListView.EvalCellFormula(lvw, rowindex, "price1", "priceIncludeTax/(1+taxRate*0.01)");
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", "priceIncludeTax/(1+taxRate*0.01) * discount");
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "priceIncludeTax * discount");

            ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "priceIncludeTax/(1+taxRate*0.01) * discount * num1");
            ListView.EvalCellFormula(lvw, rowindex, "money1", "priceIncludeTax * discount * num1");
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", " priceIncludeTax/(1+taxRate*0.01) * discount * num1 * taxRate * 0.01");
            window.ListView.RefreshCellUI(lvw, rowindex, "price1,priceAfterDiscount,priceAfterTax,moneyBeforeTax,money1,taxValue", 100);
            break;
        case "taxRate":					//税率发生更改
            if (includeTax == 1) {
                ListView.EvalCellFormula(lvw, rowindex, "price1", "priceIncludeTax/(1+taxRate*0.01)");    //{含税单价}/(1+{税率})
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", "priceIncludeTax/(1+taxRate*0.01) * discount");

                ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "priceIncludeTax/(1+taxRate*0.01) * discount * num1");
                ListView.EvalCellFormula(lvw, rowindex, "money1", "priceAfterTax * num1");
                ListView.EvalCellFormula(lvw, rowindex, "taxValue", " priceIncludeTax/(1+taxRate*0.01) * discount * num1 * taxRate * 0.01");
                window.ListView.RefreshCellUI(lvw, rowindex, "price1,priceAfterDiscount,moneyBeforeTax,money1,taxValue", 100);
            } else {
                ListView.EvalCellFormula(lvw, rowindex, "priceIncludeTax", "price1*(1+taxRate*0.01)");    //{未税单价}*(1+{税率})
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "price1*(1+taxRate*0.01) * discount");

                ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "priceAfterDiscount * num1");
                ListView.EvalCellFormula(lvw, rowindex, "money1", "price1*(1+taxRate*0.01) * discount * num1");
                ListView.EvalCellFormula(lvw, rowindex, "taxValue", "priceAfterDiscount * num1 * taxRate * 0.01");
                window.ListView.RefreshCellUI(lvw, rowindex, "priceIncludeTax,priceAfterTax,moneyBeforeTax,money1,taxValue", 100);
            }
            break;
        case "moneyBeforeTax":		//税前总价发生更改
            ListView.EvalCellFormula(lvw, rowindex, "money1", " moneyBeforeTax * (1 + taxRate * 0.01)");
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", " moneyBeforeTax / num1");
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "moneyBeforeTax * (1 + taxRate * 0.01) / num1");
            ListView.EvalCellFormula(lvw, rowindex, "price1", "moneyBeforeTax / num1 / discount");
            ListView.EvalCellFormula(lvw, rowindex, "priceIncludeTax", "moneyBeforeTax * (1 + taxRate * 0.01) / num1 / discount");
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", " moneyBeforeTax * taxRate * 0.01");
            window.ListView.RefreshCellUI(lvw, rowindex, "money1,priceAfterDiscount,priceAfterTax,price1,priceIncludeTax,taxValue", 100);
            break;
        case "money1":				//税后总价发生更改
            ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "money1 / (1 + taxRate * 0.01)");
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", "money1 / (1 + taxRate * 0.01) / num1");
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "money1 / num1");
            ListView.EvalCellFormula(lvw, rowindex, "price1", "money1 / (1 + taxRate * 0.01) / num1 / discount");
            ListView.EvalCellFormula(lvw, rowindex, "priceIncludeTax", "money1 / num1 / discount");
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", " money1 / (1 + taxRate * 0.01) * taxRate * 0.01");
            window.ListView.RefreshCellUI(lvw, rowindex, "moneyBeforeTax,priceAfterDiscount,price1,priceAfterTax,priceIncludeTax,taxValue", 100);
            break;
    }
    ListView.ApplyCellSumsData(lvw, [ListView.GetHeaderByDBName(lvw,'money1').i]);
}



function OnScanfHandle(ord, unit) {
    var lvw = window["lvw_JsonData_contractlist"];
    var hd = lvw.headers;
    var rows = lvw.rows;
    var h_ord = -1;
    var h_unit = -1;
    var h_num1 = -1;
    for (var i = 0; i < hd.length; i++) {
        if (hd[i].dbname == "ord") { h_ord = i; }
        if (hd[i].dbname == "unit") { h_unit = i; }
        if (hd[i].dbname == "num1") { h_num1 = i; }

    }
    if (h_ord < 0) return;
    var HasThis = false;
    for (var i = 0 ; i < rows.length; i++) {
        var mord = rows[i][h_ord];
        var munit = rows[i][h_unit];
        if (unit == 0 && mord.length > 0) {
            if (parseInt(mord) == parseInt(ord)) {
                var num1 = rows[i][h_num1];
                if (num1 == 0) num1 = 0;
                num1 = parseFloat(num1) + 1;
                __lvw_je_updateCellValue(lvw.id, i, h_num1, num1);
                HasThis = true;
                break;
            }
        } else if (unit > 0 && mord.length > 0 && munit > 0) {
            if (parseInt(mord) == parseInt(ord) && parseInt(munit) == parseInt(unit)) {
                var num1 = rows[i][h_num1];
                if (num1 == 0) num1 = 0;
                num1 = parseFloat(num1) + 1;
                __lvw_je_updateCellValue(lvw.id, i, h_num1, num1);
                HasThis = true;
                break;
            }
        }
    }
    if (HasThis == false) {
        var r = rows.length;
        __lvw_je_addNew(lvw.id);
        __lvw_je_updateCellValue(lvw.id, r, h_num1, 1);
    }
}

function bomlist(ord) {
    var lvw = window["lvw_JsonData_pricelist"];
    var headers = lvw.headers;
    var _ord = -1;
    var _unit = -1;
    var _num1 = -1;
    var _intro = -1;
    var _date2 = -1;
    var _treeOrd = -1;
    var rows = lvw.rows;
    if (rows.length <= 1) {
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
        var v3 = (typeof (lvw.rows[i][_unit].fieldvalue) != "undefined" && lvw.rows[i][_unit].fieldvalue != "") ? lvw.rows[i][_unit].fieldvalue : lvw.rows[i][_unit] != "" ? lvw.rows[i][_unit] : 0;
        var v4 = lvw.rows[i][_num1] == "" ? 0 : lvw.rows[i][_num1]
        sql += sql != "select ROW_NUMBER() over(order by aa.xuhao) id,aa.* into #temp from (" ? "   union all select " + i + " xuhao," + rowindex + "  mxindex, " + v2 + " ord," + v3 + " unit," + v4 + "   num1,'" + v + "' intro,'" + v1 + "'  date2," + v5 + " treeOrd,0 ProductAttr1,0 ProductAttr2" : "select " + i + " xuhao," + rowindex + "  mxindex," + v2 + " ord," + v3 + " unit," + v4 + " num1 ,'" + v + "' intro,'" + v1 + "'  date2 ," + v5 + "  treeOrd,0 ProductAttr1,0 ProductAttr2";
    }
    sql += " )aa "
    app.OpenUrl("../../../SYSA/BomList/Bom_Trees_List_Price.asp?treeType=3&top=" + ord + "&afv_existssql=" + sql, 'price', "", "afv_existssql");
}

$(function () {
    $('#bomTreeList_btn').click(function () {
        bomlist(Bill.Data.ord);
    });
})

function updatelvwtreord(inx, num1, intro, date2, treord, price1) {
    var rowindex = inx;
    var jlvw = window["lvw_JsonData_pricelist"];
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
            $ID("lvw_dbtable_pricelist").click();
        }
    }
}

function ConvertToFailedPrice() {
    app.ajax.regEvent("ConvertToFailedPrice");
    app.ajax.addParam('ord', Bill.Data.ord);
    var ret = app.ajax.send();
    if (ret != "") {
        if (ret.indexOf("Err:") > -1) {
            alert(ret.replace("Err:",""));
        }
    }
    location.reload()
    
}


function showSubPro(obj, ord, id) {
    var cls = obj.className;
    if (cls == "ico5") {
        app.OpenServerFloatDiv("ZBServices.flib.Sales.Price.PriceHelper.ShowBomlistInfo", { DivWidth: 1000, pricelist: id, cpid: ord }, "", 1);
    }
    else {
        obj.className = "ico5";
        $(".subPro_" + id).css({ "display": "none" });
    }
    subHtml(1);
}


function show5Ico(virPath, title, ord, treeOrd, id,candetail) {
    var treeSpan = "";
    if (treeOrd != "" && treeOrd != 0) {
        treeSpan = "<span class='ico5' onclick='showSubPro(this," + ord + "," + id + ")'></span> ";
    }
    return "<table><tr><td>" + treeSpan + " </td>  <td>" + (candetail == 1 ? "<a target=_blank style='cursor:pointer' onclick=\"javascript:window.open('" + virPath + "SYSA/product/content.asp?ord='+ app.pwurl(" + ord + "))\">" + title + "</a>" : "" + title + "") + "</td></tr></table>"
}

function subHtml(id) {
    var newdiv = document.createElement("div");
    newdiv.setAttribute("id", "maskDiv");//给元素加id
    newdiv.style.float = "right";//js设置样式
}

function setbkgc(isSet) {
    if (isSet == 1) {
        debugger;
    }
}


