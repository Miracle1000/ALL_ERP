function setMorePay() {
    var morepay = $('#morepay_0').val();
    if (morepay == '0') {
        $('#morepay_0').val('1');
        $('#morepay_0').blur();
        $('#morepay_0').change();
    } 
}

String.prototype.replaceAll = function (s1, s2) {
    return this.replace(new RegExp(s1, "gm"), s2);
}

window.OnListViewFormualUpdateCell = function (lvw, rowindex, cellindex, newv) {
	if (lvw.headers[cellindex].dbname != "taxRate") { return; }
	window.onlvwUpdateCellValue(lvw, rowindex, cellindex, newv, 0, 0, 0);
}

window.onlvwUpdateCellValue = function (lvw, rowindex, cellindex, v, isztlr, isEof, disrefresh, oldvalue) {
    if (window.___Refreshinglvw == true) return; 
    if (window.IsListviewAddRows ==true) return;
	if (oldvalue == v) { return;}
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
        var mord =rows[i][h_ord];
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




function getHtId(billType) {
    var data = [];
    data.push("__BillTypeId=" + 11001);
    var catchFieldsStr = "htcateid";//多参数的话|分割
    var catchFields = catchFieldsStr.split("|");
    for (var i = 0; i < catchFields.length; i++) {
        var catchField = catchFields[i];
        data.push(catchField + "=" + $("#" + catchField).val())
    }
    //data.push("sort=销售开单")

    data.push("__CatchFields=" + encodeURIComponent(catchFieldsStr));
    if (window.setCatchFieldData) { window.setCatchFieldData(); }

    var xhttp = window.XMLHttpRequest ? (new XMLHttpRequest()) : (new ActiveXObject("Microsoft.XMLHTTP"));
    xhttp.open("POST", ((window.sysCurrPath ? (window.sysCurrPath + "../") : window.SysConfig.VirPath) + "SYSN/view/comm/GetBHValue.ashx?GB2312=1"), false);
    xhttp.setRequestHeader("content-type", "application/x-www-form-urlencoded");
    xhttp.send(data.join("&"));
    var obj = eval("(" + xhttp.responseText + ")");

    document.getElementById("htid_0").value = "" + obj.code + "";
}
function KuinfoChooseck(ck, obj) {
    var jlvw = window['lvw_JsonData_contractlist'];
    var CKcellindex = ListView.GetHeaderByDBName(jlvw, "ck").i;
    var td = $(obj).parents('td[dbcolindex]:eq(0)')[0];
    var tr = td.parentNode;
    var rowindex = parseInt(tr.getAttribute('pos'));
    var data = { title: $(obj).text().split("->")[$(obj).text().split("->").length-1], url: "" }
    jlvw.rows[rowindex][CKcellindex].fieldvalue = ck;
    jlvw.rows[rowindex][CKcellindex].links = [data];
    __lvw_je_redrawCell(jlvw, jlvw.headers[CKcellindex], rowindex, jlvw.headers[CKcellindex].showindex);
    if (!jlvw.autoChgTip ||! jlvw.autoChgTip[rowindex]) {
        jlvw.autoChgTip = [];
        jlvw.autoChgTip[rowindex] = [];
    }
        jlvw.autoChgTip[rowindex][CKcellindex] = "hsChange"
    $($ID("@" + "contractlist" + "_ck_" + rowindex + "_" + CKcellindex + "_tit")).change();
}
function updatelvwcellzd(num1, inx) {
    var data = getinx(-1, inx)
    var ModifyStamp = $("#ModifyStamp_0").val();
    var jlvw = window['lvw_JsonData_contractlist'];
    var CKcellindex = ListView.GetHeaderByDBName(jlvw, "cktype").i;
    var zdnumindex = ListView.GetHeaderByDBName(jlvw, "zdnum").i;
    var zdnumv = "已指定：" + app.FormatNumber(num1, "numberbox") + "";
    zdnumv = num1 == "" ? "" : zdnumv;
    if (num1 === "") {
        //点击随机inx就是当前行号
        app.ajax.regEvent("deletekuoutlit2");
        app.ajax.addParam("rowindex", data.inx);
        app.ajax.addParam("ModifyStamp", ModifyStamp);
        var r = app.ajax.send();
    }
    $($ID("@" + "contractlist" + "_cktype_" + data.rowindex + "_" + CKcellindex + "_div")).nextAll('div').text(zdnumv)
    jlvw.rows[data.rowindex][zdnumindex] = zdnumv;
}


window.onListViewRowBeforeDelete = function (lvw, pos) {

    var data =getinx(pos);
    var ModifyStamp = $("#ModifyStamp_0").val();
    app.ajax.regEvent("deletekuoutlit2");
    app.ajax.addParam("rowindex", data.inx);
    app.ajax.addParam("ModifyStamp", ModifyStamp);
    var r = app.ajax.send();
}
//获取指定出库唯一指定标识
function getinx(pos,inxs) {

    var jlvw = window['lvw_JsonData_contractlist'];
    var hds = jlvw.headers;
    var hearderinx = -1//列的下标
    var rowindex=pos//行的下标
    for (var i = 0; i < hds.length; i++) {
        switch (hds[i].dbname.toLowerCase()) {
            case 'rowindex': hearderinx = i; break;
        }
    }
    if (pos==-1) {
        for (var i = 0; i < jlvw.rows.length; i++) {
            if (jlvw.rows[i][hearderinx] == inxs) rowindex = i;
        }
    }
    //返回当前操作行的出库指定标识行、列
    var item = { hearderinx: hearderinx, rowindex: rowindex, inx: jlvw.rows[rowindex][hearderinx] };
    return item;
}

