//只针对批号启用，序列号启用使用
function SetWorkingFlowDowayByRowIndexlvw(rowIndex, cellIndex, dbname) {
    var lvw = window['lvw_JsonData_Doway'];
    var ordindex = -1;//加工次序
    var conversionBLindex = -1;//换算比例
    var serialNumberStartindex = -1;//序列号启用
    var batchNumberStartindex = -1;//批号启用
    var isRedConversionBLindex = -1;//换算比例是否只读
    var reportingExceptionStrategyindex = -1;//汇报例外策略
    var reportingRoundingindex = -1;//汇报取整
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == 'ord') { ordindex = i; }
        if (lvw.headers[i].dbname == 'ConversionBL') { conversionBLindex = i; }
        if (lvw.headers[i].dbname == 'IsRedConversionBL') { isRedConversionBLindex = i; }
        if (lvw.headers[i].dbname == 'ReportingExceptionStrategy') { reportingExceptionStrategyindex = i; }
        if (lvw.headers[i].dbname == 'ReportingRounding') { reportingRoundingindex = i; }
        if (lvw.headers[i].dbname == 'SerialNumberStart') { serialNumberStartindex = i; }
        if (lvw.headers[i].dbname == 'BatchNumberStart') { batchNumberStartindex = i; }
    }
    var thisord=lvw.rows[rowIndex][ordindex];//本次加工次序

    //循环更其它批号启用、序列号启用选项为未选中
    if (lvw.rows[rowIndex][cellIndex] == 1) {
        for (var i = 0; i < lvw.rows.length; i++) {

            //处理单选
            if (parseInt(lvw.rows[i][cellIndex]) == 1 && rowIndex != i) {
                __lvw_je_updateCellValue(lvw.id, i, cellIndex, 0);
            }
            //大于等于本加工次序的工序的换算比例为1(序列号启用)
            if (dbname == "SerialNumberStart") {
                if (parseInt(lvw.rows[i][ordindex]) >= thisord && thisord != undefined && thisord != "") {

                    if (parseInt(lvw.rows[i][reportingExceptionStrategyindex]) != 1) {
                        __lvw_je_updateCellValue(lvw.id, i, conversionBLindex, 1);
                        __lvw_je_updateCellValue(lvw.id, i, isRedConversionBLindex, 1);
                        __lvw_je_updateCellValue(lvw.id, i, reportingRoundingindex, 1);
                       
                    } else {
                        __lvw_je_updateCellValue(lvw.id, i, isRedConversionBLindex, 2);
                        __lvw_je_updateCellValue(lvw.id, i, batchNumberStartindex, 0);
                    }
                }
                else {
                    if (parseInt(lvw.rows[i][isRedConversionBLindex]) == 1 || parseInt(lvw.rows[i][isRedConversionBLindex]) == 2) {
                        __lvw_je_updateCellValue(lvw.id, i, isRedConversionBLindex, 0);
                    }
                }
            }
        }
    } else {
        if (dbname == "SerialNumberStart") {
            for (var i = 0; i < lvw.rows.length; i++) {
                if (parseInt(lvw.rows[i][isRedConversionBLindex]) == 1 || parseInt(lvw.rows[i][isRedConversionBLindex]) == 2) {
                    __lvw_je_updateCellValue(lvw.id, i, isRedConversionBLindex, 0);
                }
            }
        }
    }
    ___RefreshListViewByJson(lvw);
}

//加工次序变更触发
function SetordChangeClicklvw(rowIndex) {
    var lvw = window['lvw_JsonData_Doway'];
    var ordindex = -1;//加工次序
    var conversionBLindex = -1;//换算比例
    var serialNumberStartindex = -1;//序列号启用
    var batchNumberStartindex = -1;//批号启用
    var isRedConversionBLindex = -1;//换算比例是否只读
    var reportingExceptionStrategyindex = -1;//汇报例外策略
    var reportingRoundingindex = -1;//汇报取整
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == 'ord') { ordindex = i; }
        if (lvw.headers[i].dbname == 'ConversionBL') { conversionBLindex = i; }
        if (lvw.headers[i].dbname == 'SerialNumberStart') { serialNumberStartindex = i; }
        if (lvw.headers[i].dbname == 'BatchNumberStart') { batchNumberStartindex = i; }
        if (lvw.headers[i].dbname == 'IsRedConversionBL') { isRedConversionBLindex = i; }
        if (lvw.headers[i].dbname == 'ReportingExceptionStrategy') { reportingExceptionStrategyindex = i; }
        if (lvw.headers[i].dbname == 'ReportingRounding') { reportingRoundingindex = i; }
    }

    
    var thisord = lvw.rows[rowIndex][ordindex];//本次加工次序
    if (thisord != undefined && thisord != "") {
        var isSerialNumberStart = 0;//是否启用 1启用 0未启用
        for (var i = 0; i < lvw.rows.length; i++) {
            if (parseInt(lvw.rows[i][ordindex]) <= thisord) {
                if (lvw.rows[i][serialNumberStartindex] == 1) {
                    isSerialNumberStart = 1;
                }
            }
        }
        if (isSerialNumberStart == 1) {
           
            
            if (parseInt(lvw.rows[rowIndex][reportingExceptionStrategyindex]) != 1) {
                __lvw_je_updateCellValue(lvw.id, rowIndex, conversionBLindex, 1);
                __lvw_je_updateCellValue(lvw.id, rowIndex, isRedConversionBLindex, 1);
                __lvw_je_updateCellValue(lvw.id, rowIndex, reportingRoundingindex, 1);
            } else {
                __lvw_je_updateCellValue(lvw.id, rowIndex, isRedConversionBLindex, 2);
                __lvw_je_updateCellValue(lvw.id, rowIndex, batchNumberStartindex, 0);
            }
            if (lvw.rows[rowIndex][serialNumberStartindex] == 1) {
                SetWorkingFlowDowayByRowIndexlvw(rowIndex, serialNumberStartindex, "SerialNumberStart");
            }
        } else {
            __lvw_je_updateCellValue(lvw.id, rowIndex, isRedConversionBLindex, 0);
        }
    } else {
        //如果序列号启用但是加工次序为空
        if (lvw.rows[rowIndex][serialNumberStartindex] == 1) {
            SetWorkingFlowDowayByRowIndexlvw(rowIndex, serialNumberStartindex, "SerialNumberStart")
        } else {
            if (parseInt(lvw.rows[rowIndex][isRedConversionBLindex]) == 1 || parseInt(lvw.rows[rowIndex][isRedConversionBLindex]) == 2) {
                __lvw_je_updateCellValue(lvw.id, rowIndex, isRedConversionBLindex, 0);
            }
        }
    }
}


//所有工序序列号未启用时换算比例是否只读设置为0
function SetWorkingFlowDowaylvw() {
    var lvw = window['lvw_JsonData_Doway'];
    var serialNumberStartindex = -1;//序列号启用
    var isRedConversionBLindex = -1;//换算比例是否只读
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == 'IsRedConversionBL') { isRedConversionBLindex = i; }
        if (lvw.headers[i].dbname == 'SerialNumberStart') { serialNumberStartindex = i; }
    }
    var isSerialNumberStart = 0;//是否启用 1启用 0未启用
    var rowindex = -1;
    for (var i = 0; i < lvw.rows.length; i++) {
        if (lvw.rows[i][serialNumberStartindex] == 1) {
            isSerialNumberStart = 1;
            rowindex = i;
        }
    }
    if (isSerialNumberStart == 0) {
        for (var i = 0; i < lvw.rows.length; i++) {
            if (parseInt(lvw.rows[i][isRedConversionBLindex]) == 1 || parseInt(lvw.rows[i][isRedConversionBLindex]) == 2) {
                __lvw_je_updateCellValue(lvw.id, i, isRedConversionBLindex, 0);
            }
        }
        ___RefreshListViewByJson(lvw);
    }
    if (isSerialNumberStart == 1) {
        SetWorkingFlowDowayByRowIndexlvw(rowindex, serialNumberStartindex, "SerialNumberStart");
    }
}