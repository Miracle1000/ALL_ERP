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
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", " moneyBeforeTax * taxRate * 0.01");
            CurrFormulaInfoHandle(lvw, rowindex, cellindex, "commUnitAttr", num1);
            window.ListView.RefreshCellUI(lvw, rowindex, "tpricejy,moneyBeforeTax,money1,taxValue", 100);
            break;
        case "price1":					 // 未税单价发生更改
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", "price1*discount");
            ListView.EvalCellFormula(lvw, rowindex, "priceIncludeTax", "price1*(1+taxRate*0.01)");    //{未税单价}*(1+{税率})
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "priceIncludeTax*discount");

            ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "priceAfterDiscount*num1");
            ListView.EvalCellFormula(lvw, rowindex, "money1", "priceAfterTax*num1");
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", " moneyBeforeTax * taxRate * 0.01");
            window.ListView.RefreshCellUI(lvw, rowindex, "priceAfterDiscount,moneyBeforeTax,priceIncludeTax,priceAfterTax,money1,taxValue", 100);
            break;
        case "discount":				// 折扣发生改变
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", "price1 * discount");
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "priceIncludeTax * discount");

            ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "priceAfterDiscount * num1");
            ListView.EvalCellFormula(lvw, rowindex, "money1", "priceAfterTax * num1");
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", " moneyBeforeTax * taxRate * 0.01");
            window.ListView.RefreshCellUI(lvw, rowindex, "priceAfterDiscount,moneyBeforeTax,priceAfterTax,money1,taxValue", 100);
            break;
        case "priceIncludeTax"://含税单价
            ListView.EvalCellFormula(lvw, rowindex, "price1", "priceIncludeTax/(1+taxRate*0.01)");
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", "price1 * discount");
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "priceIncludeTax * discount");

            ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", "priceAfterDiscount * num1");
            ListView.EvalCellFormula(lvw, rowindex, "money1", "priceAfterTax * num1");
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", " moneyBeforeTax * taxRate * 0.01");
            window.ListView.RefreshCellUI(lvw, rowindex, "price1,priceAfterDiscount,priceAfterTax,moneyBeforeTax,money1,taxValue", 100);
            break;
        case "taxRate":					//税率发生更改
            if (includeTax == 1) {
                ListView.EvalCellFormula(lvw, rowindex, "price1", "priceIncludeTax/(1+taxRate*0.01)");    //{含税单价}/(1+{税率})
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", " price1 * discount");

                ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", " priceAfterDiscount * num1");
                ListView.EvalCellFormula(lvw, rowindex, "money1", "priceAfterTax * num1");
                ListView.EvalCellFormula(lvw, rowindex, "taxValue", " moneyBeforeTax * taxRate * 0.01");
                window.ListView.RefreshCellUI(lvw, rowindex, "price1,priceAfterDiscount,moneyBeforeTax,money1,taxValue", 100);
            } else {
                ListView.EvalCellFormula(lvw, rowindex, "priceIncludeTax", "price1*(1+taxRate*0.01)");    //{未税单价}*(1+{税率})
                ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", "priceIncludeTax * discount");

                ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", " priceAfterDiscount * num1");
                ListView.EvalCellFormula(lvw, rowindex, "money1", "priceAfterTax * num1");
                ListView.EvalCellFormula(lvw, rowindex, "taxValue", "moneyBeforeTax * taxRate * 0.01");
                window.ListView.RefreshCellUI(lvw, rowindex, "priceIncludeTax,priceAfterTax,moneyBeforeTax,money1,taxValue", 100);
            }
            break;
        case "moneyBeforeTax":		//税前总价发生更改
            ListView.EvalCellFormula(lvw, rowindex, "money1", " moneyBeforeTax * (1 + taxRate * 0.01)");
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", " moneyBeforeTax / num1");
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", " money1 / num1");
            ListView.EvalCellFormula(lvw, rowindex, "price1", "priceAfterDiscount / discount");
            ListView.EvalCellFormula(lvw, rowindex, "priceIncludeTax", "priceAfterTax / discount");
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", " moneyBeforeTax * taxRate * 0.01");
            window.ListView.RefreshCellUI(lvw, rowindex, "money1,priceAfterDiscount,priceAfterTax,price1,priceIncludeTax,taxValue", 100);
            break;
        case "money1":				//产品总价发生更改
            ListView.EvalCellFormula(lvw, rowindex, "moneyBeforeTax", " money1 / (1 + taxRate * 0.01)");
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterDiscount", " moneyBeforeTax / num1");
            ListView.EvalCellFormula(lvw, rowindex, "priceAfterTax", " money1 / num1");
            ListView.EvalCellFormula(lvw, rowindex, "price1", "priceAfterDiscount / discount");
            ListView.EvalCellFormula(lvw, rowindex, "priceIncludeTax", "priceAfterTax / discount");
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", " moneyBeforeTax * taxRate * 0.01");
            window.ListView.RefreshCellUI(lvw, rowindex, "moneyBeforeTax,priceAfterDiscount,price1,priceAfterTax,priceIncludeTax,taxValue", 100);
            break;
    }
}

function PriceEvent(ord,type)
{
    app.OpenUrl("../../../SYSA/product/add_list.asp?top=" + app.pwurl(ord) + "", 'price');
}

function cptj(ord, top) {

    var event = document.createEvent("HTMLEvents");
    event.initEvent("change", true, true);
    $("#cpid_0").val(ord);
    document.querySelector("#addcpEvent_0").dispatchEvent(event);
}

function redioclick(obj) {
    $("#meessg_0").text("优惠金额大于报价总额时，优惠金额取0");
    var v = $(obj).val();
    $("#yhtype_0").val(v);
        if (v == '0') {
            $("#yh_0").val(app.FormatNumber(0, "moneybox"));
            $("#yh_0").attr("max", 1000000000000);
            $("#yh_0").attr("msg", "");
        } else if (v == '1') {
           
            $("#yh_0").val(app.FormatNumber(1, "discntbitbox"));
            $("#yh_0").attr("max", 1.5);
            $("#yh_0").attr("msg", "折扣必须控制在0-1.5之间");
        }
};

function yhchange(obj)
{
    $("#yhvalue_0").val($(obj).val());
}

function mesage()
{
    $("#meessg_0").text("折扣必须控制在0-1.5之间");
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
    if (rows.length<=1) {
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

function updatelvwtreord(inx,num1,intro,date2,treord)
{
    var rowindex = inx;
    var jlvw = window["lvw_JsonData_pricelist"];
    var treord_ = ListView.GetHeaderByDBName(jlvw, "treeOrd").i;
    var num1_ = ListView.GetHeaderByDBName(jlvw, "num1").i;
    var intro_ = ListView.GetHeaderByDBName(jlvw, "intro").i;
    var date2_ = ListView.GetHeaderByDBName(jlvw, "date2").i;
    jlvw.rows[rowindex][treord_] = treord;
    jlvw.rows[rowindex][num1_] = num1;
    jlvw.rows[rowindex][intro_] = intro;
    jlvw.rows[rowindex][date2_] = date2;
    __lvw_je_redrawCell(jlvw, jlvw.headers[date2_], rowindex, jlvw.headers[date2_].showindex);
    __lvw_je_redrawCell(jlvw, jlvw.headers[num1_], rowindex, jlvw.headers[num1_].showindex);
    __lvw_je_redrawCell(jlvw, jlvw.headers[intro_], rowindex, jlvw.headers[intro_].showindex);
}
