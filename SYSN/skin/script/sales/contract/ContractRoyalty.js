function EquallyDistributed(e) {
    if (e.checked) {
        var billFields = Bill.GetAllFields("", 0);//单据字段集合
        var lvw = window["lvw_JsonData_ContractRoyaltyList"];//明细列表
        var count = lvw.rows.length - 1;//需要改变的值的条数
        var commission = 0;//实际提成
        //billFields.forEach(c => {
        //    if (c.title == "实际提成") {
        //        commission = parseFloat(c.defvalue);
        //    }
        //});
        for (var i = 0; i < billFields.length; i++) {
            if (billFields[i].title == "实际提成") {
                commission = parseFloat(billFields[i].defvalue);
            }
        }
        var blNumbit = window.SysConfig.RateBit;//百分号保留小数位数 
        var moneyNumbit = -1;//金额保留小数位数
        for (var i = 0; i < lvw.headers.length; i++) {
            if (lvw.headers[i].dbname == "RoyaltyMoney") {
                moneyNumbit = parseInt(lvw.headers[i].numbit);
                break;
            }
        }
        //lvw.headers.some(c => {
        //    if (c.dbname == "RoyaltyMoney") {
        //        moneyNumbit = parseInt(c.numbit);
        //        return true;
        //    }
        //});
        var result = commission / count;//查看是否能整除，能整除直接分配 
        var x = result.toString().indexOf('.') + 1; //小数点的位置
        var y = result.toString().length - x; //小数的位数
        var bl = (100 / count).toFixed(blNumbit);//平均分配比例
        var totalMoney = 0;//已分配金额 
        var totalBL = 0;//已分配金额 
        for (var i = 0; i < lvw.rows.length - 1; i++) {
            var moneyNum = 0;
            if (moneyNumbit >= y || x == 0) {//如果计算后的小数位数和系统小数位数相同或没有小数，说明为整除
                moneyNum = result;
                lvw.rows[i][4] = result;//将比例放入listview中
                if (i == lvw.rows.length - 2) {
                    lvw.rows[i][3] = 100 - totalBL;
                }
                else {
                    lvw.rows[i][3] = parseFloat(bl);
                    totalBL += parseFloat(bl);
                }
            } else {
                if (i == lvw.rows.length - 2) {//最后一位用总和减去已分配额 
                    lvw.rows[i][4] = commission - totalMoney;
                    lvw.rows[i][3] = 100 - totalBL;
                } else {
                    moneyNum = parseFloat((commission * parseFloat(bl) * 0.01).toFixed(moneyNumbit));
                    lvw.rows[i][3] = parseFloat(bl);
                    lvw.rows[i][4] = moneyNum;
                    totalMoney += moneyNum;
                    totalBL += parseFloat(bl);
                }
            }
            //__lvw_je_updateCellValue(lvw.id, i, 3, parseFloat(bl), 4, false);
            //__lvw_je_updateCellValue(lvw.id, i, 4, moneyNum, 3, false);
        }
        ___ReSumListViewByJsonData(lvw);
        ___RefreshListViewByJson(lvw);
        for (var n in window.FormualLib.__r_dat) {
            if (n == "Unallocated") {
                var obj = window.FormualLib.__r_dat[n];
                var cell = Bill.GetFieldCellByDbName(obj.dn);
                if (cell != null && obj.v != "抛弃我吧!" && obj.v != "__discard!!!!!") {
                    obj.srcfield.value = 0;
                    obj.srcfield.defvalue = 0;
                    cell.innerHTML = Bill.GetFieldHtml(obj.srcfield);
                    Bill.BindFieldsEvents(cell);
                }
            }
        }
    }
}
function getBL(money, commission, BLnumbit, rowindex) {
    var lvw = window["lvw_JsonData_ContractRoyaltyList"];//明细列表 
    var totalBL = 0;
    for (var i = 0; i < lvw.rows.length - 1; i++) {
        if (i != rowindex) {
            totalBL += parseInt(lvw.rows[i][3]);
        }
    }
    var moneyFloat = money.v;
    var commission = parseFloat(commission);
    var result = parseFloat((moneyFloat / commission * 100).toFixed(BLnumbit)) * 0.01;//不四舍五入
    if (totalBL * 0.01 + result > 1) {
        result = 1 - (totalBL * 0.01);
    }
    return result;
}
function getMoney(bl, commission, Moneynumbit, rowindex) {
    var result = 0;
    var blFloat = bl.v;
    var commission = parseFloat(commission);
    var BLnumbit = window.SysConfig.RateBit;//百分号保留小数位数
    var lvw = window["lvw_JsonData_ContractRoyaltyList"];//明细列表 
    result = (blFloat * commission * 0.01).toFixed(Moneynumbit);//四舍五入
    return result;
}