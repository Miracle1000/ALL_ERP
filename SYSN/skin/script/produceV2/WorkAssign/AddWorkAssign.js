//___RefreshListViewByJson(lvw);
//根据数量更改listview根节点的值
function NumChangeFun(v) {
    if (v != "" && v != "0") {
        var obj = Bill.Data;
        var lvw;
        for (var i = 0; i < obj.groups.length; i++) {
            if (obj.groups[i].dbname == "childgp") {
                lvw = obj.groups[i].fields[0].listview;
            }
        }
        var cpindex = -1;
        var numindex = -1;
        var blindex = -1;
        for (var i = 0; i < lvw.headers.length; i++) {
            if (lvw.headers[i].dbname == "name") { cpindex = i; }
            if (lvw.headers[i].dbname == "num1") { numindex = i; }
            if (lvw.headers[i].dbname == "bl") { blindex = i; }
        }
        for (var i = 0; i < lvw.rows.length; i++) {
            if (lvw.rows[i][cpindex] && lvw.rows[i][cpindex].deepData.length == 0) {
                if (lvw.rows[i][blindex] != "" && lvw.rows[i][blindex] != undefined) {
                    __lvw_je_updateCellValue(lvw.id, i, numindex, (v * lvw.rows[i][blindex]))
                }
                else if (lvw.rows[i][numindex] != "" && lvw.rows[i][numindex] != undefined) {
                    __lvw_je_updateCellValue(lvw.id, i, blindex, (lvw.rows[i][numindex] / v))
                }
            }
        }
    }
}

function StopAndReset(billid, type) {
    //billid 派工ID
    //type=0 取消终止 type=1 终止派工
    if (window.confirm("确定要" + (type == 1 ? "终止" : "取消终止") + "吗？") == false) { return true; }
    app.ajax.regEvent("StopAndReset");
    app.ajax.addParam("id", billid);
    app.ajax.addParam("type", type);
    app.ajax.send(function () {
        window.location.reload();
    });
}

function calculateProcessingHours(NumMake, mNum, mtime, wtime, wNum, rptime) {
    ///@NumMake 本次派工数量
    ///@mNum 最大批量_搬运数量
    ///@mtime 最大批量_搬运工时
    ///@wtime 最大批量_加工工时
    ///@wNum 最大批量_加工数量
    ///@rptime 准备时间
    var result = 0;
    if (NumMake > mNum && NumMake > wNum) {
        result = (wNum == 0 ? 0 : Math.ceil(NumMake / wNum) * wtime) + (mNum == 0 ? 0 : Math.ceil(NumMake / mNum) * mtime) + rptime;
    }
    else if (NumMake < mNum && NumMake > wNum) {
        result = mtime + (mNum == 0 ? 0 : Math.ceil(NumMake / wNum) * wtime) + rptime;
    }
    else if (NumMake > mNum && NumMake < wNum) {
        result = (mNum == 0 ? 0 : Math.ceil(NumMake / mNum) * mtime) + wtime + rptime;
    }
    else {
        result = wtime + mtime + rptime;
    }
    return result;
}

function returnEmpty(value) {
    return "";
}

function Getxlh() {
    //获取数量
    var num = $('#NumMake_0')[0].value;
    //获取产品ID
    var ProductID = $('#ProductID_0')[0].value;
    //判断必要数据是否完整
    if (ProductID == "" || num == "") {
        alert("请选择产品后再进行此操作");
    }
    else {
        app.OpenUrl('' + window.SysConfig.VirPath + 'SYSN/view/produceV2/xlh/ChoiceList.ashx?num=' + num + '&productId=' + ProductID + '&viewStatus=Add')
    }
}

function GetxlhByModify(oldNum, uiStatus, ord) {
    //获取数量
    var Newnum = $('#NumMake_0')[0].value;
    //获取产品ID
    var ProductID = $('#ProductID_0')[0].value;
    //判断必要数据是否完整
    if (ProductID == "" || Newnum == "") {
        alert("必要数据未填写，无法打开绑定页面");
    }
    else {
        app.OpenUrl('' + window.SysConfig.VirPath + 'SYSN/view/produceV2/xlh/ChoiceList.ashx?num=' + (oldNum ? (oldNum - Newnum) : Newnum) + '&BussinessType=54002&BusinessID=' + ord + '&productId=' + ProductID + '&viewStatus=' + (uiStatus == 0 ? 'Add' : 'Modify'));
    }
}

function GetxlhBydetails() {
    //获取派工数量
    var fields = Bill.Data.groups[1].fields;
    var num = 0;
    for (var i = 0; i < fields.length; i++) {
        if (fields[i].dbname == "NumMake") { num = fields[i].value; break; }
    }
    var ProductID = 0;
    //获取产品ID
    for (var i = 0; i < fields.length; i++) {
        if (fields[i].dbname == "productID") { ProductID = fields[i].value; break; }
    }
    app.ajax.regEvent("GetNumCallBack");
    app.ajax.addParam("proID", ProductID);
    app.ajax.addParam("Num", num);
    r = app.ajax.send();
    var obj = eval("(" + r + ")");
    var neednum = obj[0];
    var billtype = obj[1];
    var billord = obj[2];
    if (neednum <= 0) {
        alert("序列号数量不能超出派工数量");
        return;
    }
    app.OpenUrl('' + window.SysConfig.VirPath + 'SYSN/view/produceV2/xlh/ChoiceList.ashx?num=' + neednum + '&productId=' + ProductID + '&BusinessID=' + billord + '&BussinessType=' + billtype + '&viewStatus=details');
}

function OnIsHasChange(_this, tableId) {
    var obj = $("#" + tableId + " tr td a").last();
    if (_this.checked || _this.prop("checked")) {
        obj.show();
        return;
    }
    obj.hide();

    //清空对应内容
    if (tableId == 'xlhInfo_table') {
        $("#XlhInfo_0,#xlhid_0").val("");
        return;
    }

    $("#PhInfo_0").val("");
}

function OnSaveBtnClick() {
    var rows = lvw_JsonData_batchNumber.rows;
    if (!rows) {
        $('.createWindow_popoBox').remove();
        return;
    }

    var phs = "";
    for (var i = 0; i < rows.length; i++) {
        if (rows[i][0].indexOf('NewRowSign') >= 0)
            continue;

        if (rows[i][0] == '') {
            alert("批号不允许为空");
            return false;
        }

        phs += rows[i][0] + ",";
    }

    $("#PhInfo_0").val(phs.substring(0, phs.length - 1));
    $('.createWindow_popoBox').remove();
}


//只针对批号启用，序列号启用使用
function SetWorkingFlowDowayByRowIndexlvw(rowIndex, cellIndex, dbname) {
    var lvw = window['lvw_JsonData_workflowf'];
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
    var thisord = lvw.rows[rowIndex][ordindex];//本次加工次序

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
    var lvw = window['lvw_JsonData_workflowf'];
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
                __lvw_je_updateCellValue(lvw.id, rowIndex, reportingRoundingindex, 1);
                __lvw_je_updateCellValue(lvw.id, rowIndex, isRedConversionBLindex, 1);
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
    var lvw = window['lvw_JsonData_workflowf'];
    if (lvw.rows.length == 0) {
        return;
    }
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


function UpdateAutocomplete(lvwDbname, title, nlvw) {
    var cpindex = -1;
    var lvw = window[lvwDbname];
    if (lvw.rows.length == 0) {
        return;
    }
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == title) { cpindex = i; break; }
    }
    lvw.headers[cpindex].autocomplete = (nlvw.headers[0].autocomplete);
}
//执行工序发生变化执行
$(function () {
    if (window.__lvw_addEvent) {
        var addEventnum = 0;
        //设置所需物料工序
        window.__lvw_addEvent(function (obj) {
            if (obj.id == "workflowf") {
                if (addEventnum<=3) {
                    SetWorkingProcedure();
                    addEventnum++;
                }
            }
           
        }
		);
    };

    $(document).on("keyup",
        "#BOMTxt_0",
        function() {
            if ($("#BOMTxt_0").val() == '') {
                $("#BOM_0").val($("#BOMTxt_0").val());
                $("#BOMTxt_0").prop('title', '');
                $("#BOMTxt_0").attr('value', '');
                $("#BOMTxt_0").attr('autorelateval', '');
            }
        });
});
//处理执行工序与所需物料的关系
function SetWorkingProcedure() {
    var lvw = window['lvw_JsonData_workflowf'];
    var lvwWL = window['lvw_JsonData_MaterialRegister'];
    if (lvwWL.rows.length == 0) {
        return;
    }
    var WorkingProcedureIDIndex = -1;
    var WorkingProcedureNameIndex = -1;
    var IDIndex = -1;
    var WFPRowIndexIndex = -1;
    var indexcolIndex=-1;
	var tempID=-1;
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == 'WPID') {
            WorkingProcedureIDIndex = i;
        } else if (lvw.headers[i].dbname == 'WPName' || lvw.headers[i].dbname == 'WPname') {
            WorkingProcedureNameIndex = i;
        } else if (lvw.headers[i].dbname == 'ID') {
            IDIndex = i;
        } else if (lvw.headers[i].dbname == 'WFPRowIndex') {
            WFPRowIndexIndex = i;
        } else if (lvw.headers[i].dbname == '@indexcol') {
            indexcolIndex = i;
        }
		if (lvw.headers[i].dbname == 'TempID') {
            tempID = i;
        }
    }

    var options = new Array();
    options.push({ "n": "", "v": "0" });
    var optionshtml = [];
    optionshtml.push("<option value='0' title=''></option>");

    var minRowindex = 0;
    for (var i = 0; i < lvw.rows.length; i++) {
        var WFPRow = lvw.rows[i][WFPRowIndexIndex];
        if (WFPRow != undefined && WFPRow != "" && parseInt(WFPRow)<0) {
            if (minRowindex > parseInt(WFPRow)) {
                minRowindex = parseInt(WFPRow);
            }
        }
    }

    for (var i = 0; i < lvw.rows.length; i++) {
        if (lvw.rows[i][WorkingProcedureIDIndex] != undefined && lvw.rows[i][WorkingProcedureNameIndex] != undefined) {

            var rowindex = i + 1;
            var rowindex2 = i + 1;
            if (lvw.rows[i][indexcolIndex] != undefined) {
                rowindex = lvw.rows[i][indexcolIndex] + 1;
            }
            var ID = -rowindex;
            var WFPRow = lvw.rows[i][WFPRowIndexIndex];
            if (lvw.rows[i][IDIndex] != undefined && parseInt(lvw.rows[i][IDIndex]) > 0) {
                ID = parseInt(lvw.rows[i][IDIndex]);
            } else {
                if (WFPRow != undefined) {
                    if (WFPRow == "" || parseInt(WFPRow) == 0) {
                        if (minRowindex < 0) {
                            ID = minRowindex - 1;
                            minRowindex = ID;
                        }
                    } else {
                        ID = parseInt(WFPRow);
                    }
                }
            }

            var ProcedureName = lvw.rows[i][WorkingProcedureNameIndex];
            if (ProcedureName != undefined && ProcedureName != null) {
                if (ProcedureName.indexOf('<font') > 0) {
                    ProcedureName = ProcedureName.substr(0,ProcedureName.indexOf('<font'));
                }
            }

            var newname = rowindex2 + "-" + ProcedureName;
            options.push({ "n": "" + newname + "", "v": "" + ID + "" });
            var WorkingProcedureIDIndex22 = -1;
				 for (var v = 0; v < lvwWL.headers.length; v++) {
					 if (lvwWL.headers[v].dbname == 'WFPAID') {
					 WorkingProcedureIDIndex22 = v;
				 }
			 }
		      var TID = -rowindex;
			 if (lvw.rows[i][tempID] != undefined && parseInt(lvw.rows[i][tempID]) > 0 && (lvw.rows[i][IDIndex]==undefined || lvw.rows[i][IDIndex].length==0) ) {
                 TID = parseInt(lvw.rows[i][tempID]);
				 for (var h = 0; h < lvwWL.rows.length; h++) {
							if (lvwWL.rows[h][WorkingProcedureIDIndex22]==TID) {
								 lvwWL.rows[h][WorkingProcedureIDIndex22]=ID;
							  }
				 }
				  
            } 
			optionshtml.push("<option value='" + ID + "' title='" + newname + "'> " + newname + " </option>");

            if (WFPRow != undefined) {
                __lvw_je_updateCellValue(lvw.id, i, WFPRowIndexIndex, ID);
            }

        }
       
    }
    var sourceData = { "options": options, "structtype": "default", "title": "" };
    var WorkingProcedureIDIndex2 = -1;
    for (var i = 0; i < lvwWL.headers.length; i++) {
        if (lvwWL.headers[i].dbname == 'WFPAID') {
            WorkingProcedureIDIndex2 = i;
            lvwWL.headers[i].source = sourceData;
        }
    }
    $("select[name='@MaterialRegister_WFPAID_-1_" + WorkingProcedureIDIndex2 + "']").empty();
    $("select[name='@MaterialRegister_WFPAID_-1_" + WorkingProcedureIDIndex2 + "']").next(".select_dom").text("");
    $("select[name='@MaterialRegister_WFPAID_-1_" + WorkingProcedureIDIndex2 + "']").append(optionshtml.join(''));

    for (var i = 0; i < lvwWL.rows.length; i++) {
        var WorkingProcedureID = lvwWL.rows[i][WorkingProcedureIDIndex2];
        if (WorkingProcedureID != undefined) {
            lvwWL.rows[i][WorkingProcedureIDIndex2] = { "fieldvalue": WorkingProcedureID, "source": sourceData };
            __lvw_je_updateCellValue(lvwWL.id, i, WorkingProcedureIDIndex2, WorkingProcedureID);
        }
    }
    ___RefreshListViewByJson(lvwWL);

}

//处理所需物料数量变小拆分新的行
function SetNeedNumChangeClick(rowIndex, cellIndex, isBatch) {
   
    var lvw = window['lvw_JsonData_MaterialRegister'];
    if (lvw.rows.length == 0) {
        return;
    }
    var maxnumIndex = -1,idIndex=-1,blIndex=-1;
    for (var i = 0; i < lvw.headers.length; i++) {
        switch (lvw.headers[i].dbname.toLowerCase()) {
            case 'id': idIndex = i; break;
            case 'maxnum': maxnumIndex = i; break;
            case 'bl': blIndex = i; break;
                
        }
    }
    var num =parseFloat(lvw.rows[rowIndex][cellIndex]);
    var maxnum = parseFloat(lvw.rows[rowIndex][maxnumIndex]);
    if (num == undefined || maxnum == undefined || num < 0 || maxnum<0) {
        return;
    }
    if (isBatch == 1) {
        __lvw_je_updateCellValue(lvw.id, rowindex, maxnumIndex, app.FormatNumber(num));
        ___RefreshListViewByJson(lvw);
        return;
    }

    if (maxnum > num)
    {
        chnum = maxnum - num;
        var newrow = app.CloneObject(lvw.rows[rowIndex]);
        newrow[cellIndex] = chnum;
        newrow[maxnumIndex] = chnum;
        var numMake = $("#NumMake_0").val();
        newrow[idIndex]=0;
        newrow[blIndex]=app.FormatNumber(chnum/numMake, "numberbox");
        lvw.rows.splice(rowIndex + 1, 0, newrow);
        window.ListView.ReCreateVRows(false, lvw, null);
        var updateCols = window.ListView.GetNeedReChangeCols(lvw, cellIndex);
        window.ListView.ApplyCellSumsData(lvw, updateCols);
    }
    __lvw_je_updateCellValue(lvw.id, rowIndex, maxnumIndex, app.FormatNumber(num));
    ___RefreshListViewByJson(lvw);

    //$($ID("@" + lvwid + "_num1_" + (parseInt(rowindex) + 1) + "_" + sjnumpos + "_0")).keyup();

}
//补废按copy功能实现，派工数量赋值报废数量后更新下级加工数量及所需数量
function SetWorkAssignbfNumRef() {

    var lvw = window['lvw_JsonData_MaterialRegister'];
    if (lvw.rows.length == 0) {
        return;
    }
    var wastageIndex = -1,blIndex = -1, num1Index=-1;
    for (var i = 0; i < lvw.headers.length; i++) {
        switch (lvw.headers[i].dbname.toLowerCase()) {
            case 'wastage': wastageIndex = i; break;
            case 'bl': blIndex = i; break;
            case 'num1': num1Index = i; break;
        }
    }
    var numMake = $("#NumMake_0").val();
    for (var i = 0; i < lvw.rows.length-1; i++) {
        if (lvw.rows[i][blIndex] != undefined && lvw.rows[i][blIndex] != null 
            &&lvw.rows[i][num1Index]!=null &&lvw.rows[i][num1Index]!=undefined) {
            var num1val = numMake * parseFloat(lvw.rows[i][blIndex]) * (1 + parseFloat(lvw.rows[i][wastageIndex]) / 100);
            __lvw_je_updateCellValue(lvw.id, i, num1Index, app.FormatNumber(num1val));
        }
    }

    var lvwwf = window['lvw_JsonData_workflowf'];
    if (lvwwf.rows.length == 0) {
        return;
    }
    var  ConversionBLIndex = -1, NumMakeIndex = -1;
    for (var i = 0; i < lvwwf.headers.length; i++) {
        switch (lvwwf.headers[i].dbname.toLowerCase()) {
            case 'conversionbl': ConversionBLIndex = i; break;
            case 'nummake': NumMakeIndex = i; break;
        }
    }
    for (var i = 0; i < (lvwwf.rows.length - 1); i++) {
        if (lvwwf.rows[i][NumMakeIndex] != undefined && lvwwf.rows[i][NumMakeIndex] != null
            && lvwwf.rows[i][ConversionBLIndex] != null && lvwwf.rows[i][ConversionBLIndex] != undefined) {
            var numval = numMake * parseFloat(lvwwf.rows[i][ConversionBLIndex]);
            __lvw_je_updateCellValue(lvwwf.id, i, NumMakeIndex, app.FormatNumber(numval));
        }
    }


}




