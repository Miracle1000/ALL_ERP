function CMoney2Html(id, value, rowindex, cellindex, billtype) {
    var lvw = lvw_JsonData_payBackSureList;
    var headers = lvw.headers;
    var moneyNowInx = -1;
    var date1Inx = -1;
    for (var i = 0; i < headers.length; i++) {
        if (headers[i].dbname == "MoneyNow") { moneyNowInx = i; }
        if (headers[i].dbname == "Date1") { date1Inx = i; }
    }
    var yvalue = value;
    value = lvw.rows[rowindex][moneyNowInx].toString();
    var date1 = lvw.rows[rowindex][date1Inx].substring(0, 10);
    var uhtml = "";
    value = value.toString().replace(/,/g, "");
    if (isNaN(value)) {
        var vs = (value + "").split("|");
        if (vs.length == 2) {
            value = vs[0] * 1;
            var uhtml = "下次：<input class='billfieldbox' dvc='1' nul='1' readonly='' isfield='1' " +
                "style='width:80px' uitype='moneybox' name='nextmoney' id='nextmoney_" + id + "' value='" + (vs[1] * 1).toFixed(window.SysConfig.MoneyBit) + "' type='text'>" +
                "<br><div>日期：<input dateui='date' class='billfieldbox' readonly='' dvc='1' nul='1' verifalerttext='请输入下次收票日期' " +
                " isfield='1'  value='" + date1 + "'  style='width:80px' uitype='datebox' name='nextdate' onclick='datedlg.show()' onchange='DateChange(" + id + ",this,\"" + rowindex + "\",\"" + cellindex + "\");'  type='text'>";
        } else {
            value = 0;
        }
    } else {
        value = Number(value);
    }

    var fieldHtml = "<div class='moneycls'><input isfield='1'" + (value < 0 ? " disabled " : "") + " style='width:112px;' uitype='moneybox' name='moneymx' id='moneymx_" + id + "' value='" + value.toFixed(window.SysConfig.MoneyBit) + "' " +
        "  verifalerttext='本次收款金额必须大于0'  type='text' class='billfieldbox' dvc='1' nul='1' " + (value < 0 ? "" : " min='0'") + " max='" + yvalue + "' ";
    if (id != "") {
        fieldHtml += "    onkeyup=\"Money2Change(" + id + ",this,'" + rowindex + "','" + cellindex + "' ,'" + yvalue + "')\"     onchange=\"$('#ShouldMoney_0').blur(); \"  ";
        if (billtype == '43010') { fieldHtml += " disabled "; }
    } else {
        fieldHtml += " readonly ";
    }
    fieldHtml += " ></div><div  class='moneycls' style='padding-top:2px;line-height:23px;'>" + uhtml + "</div>";
    return fieldHtml;
}

function Money2Change(id, box, rowindex, cellindex, maxValue) {
    if (box.value.length == 0) { return; }
    var lvw = lvw_JsonData_payBackSureList;
    var headers = lvw.headers;
    var moneyNowInx = -1;
    var date1Inx = -1;
    for (var i = 0; i < headers.length; i++) {
        if (headers[i].dbname == "MoneyNow") { moneyNowInx = i; }
        if (headers[i].dbname == "Date1") { date1Inx = i; }
    }
    var vs = lvw.rows[rowindex][moneyNowInx].toString().split("|");
    var date1 = lvw.rows[rowindex][date1Inx].substring(0, 10);
    if (box.value * 1 < maxValue * 1) {
        var v = maxValue * 1 - box.value * 1;
        __lvw_je_updateCellValue("payBackSureList", rowindex * 1, cellindex * 1, $("#moneymx_" + id).val() + "|" + v + (vs.length > 2 ? "|" + vs[2] : ""), true);
        var fieldHtml = "下次：<input class='billfieldbox' dvc='1' nul='1' readonly='' isfield='1' " +
            "style='width:80px' uitype='moneybox' name='nextmoney' id='nextmoney_" + id + "' value='" + v.toFixed(window.SysConfig.MoneyBit) + "' type='text'>" +
            "<br><div style='display: inline;'>日期：<input dateui='date' class='billfieldbox' readonly='' dvc='1' nul='1' verifalerttext='请输入下次收票日期' " +
            " isfield='1' value='" + (vs.length > 2 ? vs[2] : date1) +
            "'  style='width:80px' uitype='datebox' name='nextdate' onclick='datedlg.show()' onchange='DateChange(" + id + ",this,\"" + rowindex + "\",\"" + cellindex + "\");' type='text'></div>";
        box.parentNode.parentNode.children[1].innerHTML = fieldHtml;
    }
    else {
        __lvw_je_updateCellValue("payBackSureList", rowindex * 1, cellindex * 1, box.value, true);
        box.parentNode.parentNode.children[1].innerHTML = "";
    }
    DoSumSub(cellindex);
}
function DoSumSub(cellindex) {
    var allMoney = 0;
    $("input[name=moneymx]").each(function () {
        var m = $(this).val();
        if (m.length == 0) { m = 0; }
        allMoney += parseFloat(m);
    });
    var gp = Bill.GetGroup("base", 0);

    var json = Bill.GetField("ShouldMoney", 0);
    json.value = allMoney;
    Bill.GetFieldCellByDbName("ShouldMoney").innerHTML = Bill.GetFieldHtml(json, gp);
    $("td.lvw_index.lvw_sum[dbcolindex='" + cellindex + "']").text(app.NumberFormat(allMoney.toFixed(window.SysConfig.MoneyBit)));
    $("td.lvw_index.lvw_sum[dbcolindex='" + cellindex + "']").css("text-align", "right");
}

function DateChange(id, datebox, rowindex, cellindex) {
    __lvw_je_updateCellValue("payBackSureList", rowindex * 1, cellindex * 1, $("#moneymx_" + id).val() + "|" + $("#nextmoney_" + id).val() + "|" + datebox.value, true);
}
//自动分配收款方式中收款的金额
function autoAllotMoney() {
    if (!confirm("确定自动分配吗？")) return;
    var wipeMoney = $("#WipeMoney_0").val();
    var cashBalanc = $("#CashBalance_0").val();
    var advancesRecBalance = $("#AdvancesRecBalance_0").val();
    var bABalance = $("#BABalance_0").val();
    var detailInx = $("#DetailInx_0").val();
    var directMoneySum = 0;
    for (var i = 0; i <= detailInx; i++) {
        var directMoney = $("#DirectMoney_" + detailInx + "_0").val();
        directMoneySum += isNaN(directMoney) ? 0 : Number(directMoney);
    }
    var refMoney = 0;
    $("input[name=moneymx]").each(function () {
        var m = $(this).val();
        if (m.length == 0) { m = 0; }
        if (m < 0) {
            refMoney += Math.abs(m);
        }
    });
    var backMoneySum = (isNaN(wipeMoney) ? 0 : Number(wipeMoney)) + (isNaN(cashBalanc) ? 0 : Number(cashBalanc)) + (isNaN(advancesRecBalance) ? 0 : Number(advancesRecBalance)) + (isNaN(bABalance) ? 0 : Number(bABalance)) + directMoneySum + refMoney;
    $("input[name=moneymx]").each(function () {
        var m = $(this).attr("value");
        if (m.length == 0) { m = 0; } else { m = parseFloat(m); }
        if (m > 0) {
            if (m > backMoneySum) {
                $(this).val(backMoneySum.toFixed(window.SysConfig.MoneyBit));
                this.onkeyup();
                backMoneySum = 0;
            } else {
                $(this).val(Number(m).toFixed(window.SysConfig.MoneyBit));
                backMoneySum -= Number(m).toFixed(window.SysConfig.MoneyBit);
                this.onkeyup();
            }
        }
    });
}

$(function () {
    var moneyNowInx = -1;//本次收款金额
    if (typeof lvw_JsonData_payBackSureList !== "undefined") {
        var lvw = lvw_JsonData_payBackSureList;
        for (var i = 0; i < lvw.headers.length; i++) {
            if (lvw.headers[i].dbname == "MoneyNow") { moneyNowInx = i; break; }
        }
    }
    $("td.lvw_index.lvw_sum[dbcolindex='" + moneyNowInx + "']").css("text-align", "right");

    window.onListViewRowAfterDelete = function (lvw, pos) {
        DoSumSub(moneyNowInx);
        var h = lvw.headers;
        var r = lvw.rows;
        var moneyAll = 0;
        var money1Inx = -1;//money1应收金额  销售退款为负数
        for (var i = 0; i < h.length; i++) {
            if (h[i].dbname == "Money1") { money1Inx = i; break; }
            if (h[i].dbname == "MoneyNow") { moneyNowInx = i; break; }
        }
        for (var i = 0; i < r.length; i++) {
            var m = r[i][moneyNowInx].toString().split("|")[0];
            if (m.length == 0) { m = 0; }
            moneyAll += parseFloat(m);
        }
        var gp = Bill.GetGroup("base", 0);
        var json = Bill.GetField("ShouldMoney", 0);
        json.value = moneyAll;
        Bill.GetFieldCellByDbName("ShouldMoney").innerHTML = Bill.GetFieldHtml(json, gp);
        var money1json = Bill.GetField("Money1", 0);
        money1json.value = moneyAll;
        Bill.GetFieldCellByDbName("Money1").innerHTML = Bill.GetFieldHtml(money1json, gp);
        $("[name='Money1']").blur();
    }

    $('#autoAllotMoney_btn').click(function () {
        autoAllotMoney();
    });

    Bill.OnFieldCallBack = function (box, dbname) {
        //列表中抹零一列，失焦时，记录最后的焦点，页面刷新完后让元素重新获得焦点
        if (box && (box.tagName == "INPUT") && $(box).attr("uitype") == "moneybox") {
            window.LastFocusInputBoxId = box.id;
            //如果修改前后值不变，则不调用服务端
            if ($(box).val() == $(box).attr("value")) { return false }
            else { $(box).attr("value", $(box).val()); }
        } else {
            window.LastFocusInputBoxId = "";
        }
    };
    //当前焦点在input框，并且划过直接收款账户、下次收款日期、收款方式时，让input框失焦
    $(".fcell[id^='DirectBank_'],[id='NextDate_fbg'],[id=PaybackType_fbg]").mousemove(function (e) {
        //console.log(e.pageX + ", " + e.pageY);
        if ($(":focus").prop("tagName") == "INPUT") {
            $(":focus").blur();
        }
    });

})