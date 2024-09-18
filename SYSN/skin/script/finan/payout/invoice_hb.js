function CMoney2Html(id, value, rowindex, cellindex, taxRate, mxsp) {
    var uhtml = "";
    value = value.toString().replace(/,/g, "");
    if(isNaN(value)){
		var vs = (value + "").split("|");
		if(vs.length==3) {
			value = vs[0]*1;
		   var uhtml = "下次：<input class='billfieldbox' dvc='1' nul='1' readonly='' isfield='1' " +
            "style='width:80px' uitype='moneybox' name='nextmoney' id='nextmoney_" + id + "' value='" +  (vs[1]*1).toFixed(window.SysConfig.MoneyBit) + "' type='text'>" +
            "<br>日期：<input dateui='date' class='billfieldbox' readonly='' dvc='1' nul='1' verifalerttext='请输入下次收票日期' " +
            " isfield='1'  value='" + vs[2] + "'  style='width:80px' uitype='datebox' name='nextdate' onclick='datedlg.show()' onchange='DateChange(" + id + ",this,\"" + rowindex + "\",\"" + cellindex + "\")'  type='text'>";
		} else {
			value = 0;
		}
	}else{
		value = Number(value);
	}
	var fieldHtml = "<input isfield='1' style='width:112px;' uitype='moneybox' name='moneymx' id='moneymx_" + id + "' value='" + value.toFixed(window.SysConfig.MoneyBit) + "' " +
            "    type='text' class='billfieldbox' dvc='1' nul='1' max='" + value + "' " ;
	if (id != "") {
	    fieldHtml += "    onkeyup=\"Money2Change(" + id + ",this,'" + rowindex + "','" + cellindex + "' ,'" + value + "','" + taxRate + "')\"";
	    if (mxsp == '1') { fieldHtml += " readonly "; }
	}else{
		fieldHtml += " readonly ";
	}
    fieldHtml +=  " ><div style='padding-top:2px;line-height:23px;'>" + uhtml + "</div>";
    return fieldHtml;
}

function Money2Change(id, box, rowindex, cellindex, maxValue, taxRate) {
    if (box.value.length == 0) { return;}
    if (box.value * 1 < maxValue * 1) {
        var v = maxValue * 1 - box.value * 1;
        __lvw_je_updateCellValue("currList", rowindex * 1, cellindex * 1, box.value + "|" + v + "|", true);
        var fieldHtml = "下次：<input class='billfieldbox' dvc='1' nul='1' readonly='' isfield='1' " +
            "style='width:80px' uitype='moneybox' name='nextmoney' id='nextmoney_" + id + "' value='" + v.toFixed(window.SysConfig.MoneyBit) + "' type='text'>" +
            "<br>日期：<input dateui='date' class='billfieldbox' readonly='' dvc='1' nul='1' verifalerttext='请输入下次收票日期' " +
            " isfield='1' style='width:80px' uitype='datebox' name='nextdate' onclick='datedlg.show()' onchange='DateChange(" + id + ",this,\"" + rowindex + "\",\"" + cellindex + "\")' value='' type='text'>";
        box.parentNode.children[1].innerHTML = fieldHtml;
    }
    else {
        __lvw_je_updateCellValue("currList", rowindex * 1, cellindex * 1, box.value, true);
        box.parentNode.children[1].innerHTML = "";
    }
    DoSumSub();
}

function CMoneyXHtml(id, dbname, value, rowindex, cellindex, mxsp) {
    var uhtml = "";
    if (isNaN(value)) {
        var vs = (value + "").split("|");
        if (vs.length == 3) {
            value = vs[0] * 1;           
        } else {
            value = 0;
        }
    } else {
        value = Number(value);
    }
    var fieldHtml = "<input isfield='1' style='width:112px;' uitype='moneybox' name='" + dbname + "' id='" + dbname + "_" + id + "' value='" + value.toFixed(window.SysConfig.MoneyBit) + "' " +
            "    type='text' class='billfieldbox' dvc='1' nul='1' max='" + value + "' ";
    if (id != "") {
        if (mxsp == '1') { fieldHtml += " readonly "; }
    } else {
        fieldHtml += " readonly ";
    }
    fieldHtml += " >";
    return fieldHtml;
}

//明细收票按钮
function LoadPayoutInvoiceList(billID) {
    var lvwData = "";
    var callback = function (dbname, value) {
        if (dbname == "invoicelist") { lvwData = value; }
    }
    var td = $("td[dbname='invoicelist']")[0];
    Bill.getBillDataItem(td, callback);
    app.OpenServerFloatDialog('LoadPayoutInvoiceListPage', { width: 1000, height: 500, billID: billID, lvwData: lvwData }, '', 1);
}

//确定保存按钮
function SavePayoutInvoiceList(billID) {
    var temRows = app.CloneObject(window.lvw_JsonData_templist.rows, 2);
    if (temRows.length == 0) {
        alert("没有产品明细信息，请重新录入");
        return;
    }
    var i = 0;
    var verfy = 0;
    var money1 = 0;
    var sumTaxMoney = 0;
    var sumTaxValue = 0;
    for (i = 0; i < temRows.length; i++) {
        var caigoulist = temRows[i][1];
        var tmpNum1 = temRows[i][8];
        var tmpNum3 = temRows[i][10];
        var taxMoney1 = temRows[i][11];
        var taxValue = temRows[i][13];
        var tmpMoney1 = temRows[i][17];
        var tmpMoney2 = temRows[i][15];
        var bs = temRows[i][18];
        if (caigoulist != "0") {
            if (tmpNum1 == "") { tmpNum1 = 0; }
            //if (tmpNum1 == "") {
            //    verfy = 1;
            //    window.ListView.SVR_ShowCellsVerifyInfo("templist", i.toString(), "num1", "不允许为空！");
            //} else {            
                if (Number(tmpNum1) > Number(tmpNum3)) {
                    verfy = 1;
                    window.ListView.SVR_ShowCellsVerifyInfo("templist", i.toString(), "num1", "不能超过" + (Number(tmpNum3)).toFixed(window.SysConfig.NumberBit));
                }
            //}
        }
        //if (tmpMoney1 == "") {
        //    verfy = 1;
        //    window.ListView.SVR_ShowCellsVerifyInfo("templist", i.toString(), "money1", "不允许为空！");
        //}
        if (tmpMoney1 == "") { tmpMoney1 = 0; }
        if (taxMoney1 == "") { taxMoney1 = 0; }
        if (taxValue == "") { taxValue = 0; }
        if (Number(tmpMoney1) > Number(bs) * Number(tmpMoney2)) {
            verfy = 1;
            window.ListView.SVR_ShowCellsVerifyInfo("templist", i.toString(), "money1", "不能超过" + (Number(bs) * Number(tmpMoney2)).toFixed(window.SysConfig.MoneyBit));
        }
        var money2 = temRows[i][23];
        if (money2 == "") { money2 = 0;}
        money1 += Number(money2);
        sumTaxMoney += Number(taxMoney1);
        sumTaxValue += Number(taxValue);
    }      
    if (verfy == 1) { return; }

    if (money1 <= 0) {
        alert("本次收票金额必须大于0！");
        return;
    }
    var maxMoney = Number($("#moneymx_" + billID).attr("max"));
    if (money1 > maxMoney) {
        alert("剩余优惠金额不能超过未收票金额！");
        return;
    }
    var payoutInvoice = temRows[0][2];
    var listRows = window.lvw_JsonData_invoicelist.rows;
    for (i = listRows.length-1; i >= 0; i--) {
        if (listRows[i][2] == payoutInvoice) {
            listRows.splice(i,1);
        }
    }
    listRows = listRows.concat(temRows);
    window.lvw_JsonData_invoicelist.rows = listRows;    

    var arrCellIndex = $("#moneymx_" + billID).parent().attr("dbname").split("_");
    var rowindex = arrCellIndex[arrCellIndex.length - 2];
    var arrCellIndex2 = $("input[name^='@currList_money3_" + rowindex + "_']").attr("dbname").split("_");
    var cellindex1 = arrCellIndex2[arrCellIndex.length - 1];

    __lvw_je_updateCellValue("currList", rowindex * 1, cellindex1 * 1, sumTaxMoney.toFixed(window.SysConfig.MoneyBit), true);
    __lvw_je_updateCellValue("currList", rowindex * 1, cellindex1 * 1+1, sumTaxValue.toFixed(window.SysConfig.MoneyBit), true);
    window.ListView.RefreshCellUI(window.lvw_JsonData_currList, rowindex, "money3,taxvalue", 100);

    $("#moneymx_" + billID).val(money1.toFixed(window.SysConfig.MoneyBit));
    $("#moneymx_" + billID).keyup();
    app.closeWindow("fldiv_LoadPayoutInvoiceListPage", true);
}

function DoSumSub() {
	var allMoney = 0;
    $("input[name=moneymx]").each(function(){
        var m = $(this).val();
        if (m.length == 0) { m = 0; }
        allMoney += parseFloat(m);
    });
    var gp = Bill.GetGroup("base", 0);

    var json = Bill.GetField("money1", 0);
    json.value = allMoney;
    Bill.GetFieldCellByDbName("money1").innerHTML = Bill.GetFieldHtml(json, gp);
    //if (typeof (taxRate) == "undefined") {
    //   var taxRate = $("input[id=taxRate]").val();
    //} else {
    //   if (taxRate && taxRate.tagName && taxRate.tagName == "INPUT") { taxRate = taxRate.value; }
    //}
    //if (typeof (taxRate) == "undefined") { taxRate = 0; }
    //if (taxRate == "") { taxRate = 0 };
    //var taxValue = parseFloat(allMoney) / (1 + parseFloat(taxRate) / 100) * parseFloat(taxRate) / 100;
    //json = Bill.GetField("taxValue", 0);
    //json.value = taxValue;
    //Bill.GetFieldCellByDbName("taxValue").innerHTML = Bill.GetFieldHtml(json, gp);

    //var money3 = parseFloat(allMoney) - parseFloat(taxValue);
    //json = Bill.GetField("money3", 0);
    //json.value = money3;
    //Bill.GetFieldCellByDbName("money3").innerHTML = Bill.GetFieldHtml(json, gp);
}

$(function(){
	$(document.body).click(DoSumSub);
})

function DateChange(id,datebox, rowindex, cellindex) {
    __lvw_je_updateCellValue("currList", rowindex * 1, cellindex * 1, $("#moneymx_" + id).val() + "|" + $("#nextmoney_"+id).val() + "|" + datebox.value, true);
}
/*
window.onDisplayListViewCell = function (lvw, header, rowindex, cellindex) {
	if(rowindex>=0){
		header.max = lvw.rows[rowindex][cellindex];
		header.min = 0;
	}
}
*/
window.onListViewRowAfterDelete = function (lvw, pos) {
    if (lvw.id != "currList") { return; }
    for (var i = 0; i < lvw.rows.length; i++) {
        var billID = lvw.rows[i][1];
        var money1 = lvw.rows[i][5].toString().split("|")[0];
        $("#moneymx_" + billID).val(money1);
        $("#moneymx_" + billID).keyup();
    }
}