window.KQSetting = new Object();

//添加考勤类型弹窗
KQSetting.dialogForAddType = function () {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/setting/AddAttendanceType.ashx", "", "scrollbars=1,resizable=1,width=700,height=400,top=250,left=350");
}

//考勤类型停用启用修改状态
KQSetting.updateStatusForType = function (rowData) {
    app.ajax.regEvent("updateStatus");
    app.ajax.addParam("ID", rowData.ID);
    app.ajax.addParam("Status", status);
    app.ajax.send();
    Report.Refresh(); 
}

//修改考勤类型弹窗
KQSetting.updateForType = function (rowData) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/setting/AddAttendanceType.ashx?ord=" + rowData.ID + "", "", "scrollbars=1,resizable=1,width=832,height=630,top=250,left=350");
}
//复制内容
KQSetting.copyForType = function (rowData) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/setting/AddAttendanceType.ashx?__syscopyord=" + app.pwurl(rowData.ID) + "", "", "scrollbars=1,resizable=1,width=832,height=630,top=250,left=350");
}

//删除考勤类型
KQSetting.deleteForType = function (rowData) {
    if (confirm("是否确认删除？")) {
        app.ajax.regEvent("Delete");
        app.ajax.addParam("ID", rowData.OnlyID);
        app.ajax.send();
        Report.Refresh();
    }
}

//添加打卡设置弹层
KQSetting.dialogForCard = function () {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/setting/AddCardSetting.ashx", "", "scrollbars=1,resizable=1,width=700,height=400,top=250,left=350");
}

//修改打卡设置弹层
KQSetting.updateForCard = function (rowData) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/setting/AddCardSetting.ashx?ord=" + rowData.RangeID + "", "", "scrollbars=1,resizable=1,width=700,height=400,top=250,left=350");
}

//删除打卡设置
KQSetting.deleteForCard = function (rowData) {
    if (confirm("是否确认删除？")) {
        app.ajax.regEvent("Delete");
        app.ajax.addParam("RangeID", rowData.RangeID);
        app.ajax.send();
        Report.Refresh();
    }
}

//listview添加重写
window.OnListViewInsertNewRow = function (lvw, rowindex, srcfrom) {
    var posi = rowindex - 1;
    if (posi < 0) { return; }
    if (lvw.id == "NewYearCountModeList") {
        var NewYearDayNumindex = 0;
        var Yearindex = 0;
        var IsMaxRowIndex = 0;
        for (var i = 0; i < lvw.headers.length; i++) {
            if (lvw.headers[i].dbname == "NewYearDayNum") { NewYearDayNumindex = i; }
            if (lvw.headers[i].dbname == "YearInt") { Yearindex = i; }
            if (lvw.headers[i].dbname == "IsMaxRowIndex") { IsMaxRowIndex = i; }
        }
        if (lvw.rows[posi][Yearindex]>=0) {
            var YearInt= parseInt(lvw.rows[posi][Yearindex]) + 1;
            __lvw_je_updateCellValue(lvw.id, rowindex, Yearindex, YearInt);
            __lvw_je_updateCellValue(lvw.id, rowindex, NewYearDayNumindex, parseInt(lvw.rows[posi][NewYearDayNumindex]) + 1);
            __lvw_je_updateCellValue(lvw.id, posi, IsMaxRowIndex, 0);
            __lvw_je_updateCellValue(lvw.id, rowindex, IsMaxRowIndex,1);
            
        }
    }

    if (lvw.id == "ProductionInspectionList") {
        var NewYearDayNumindex = 0;
        var IsMaxRowIndex = 0;
        var RowIndexNumIndex = 0;
        for (var i = 0; i < lvw.headers.length; i++) {
            if (lvw.headers[i].dbname == "NewYearDayNum") { NewYearDayNumindex = i; }
            if (lvw.headers[i].dbname == "IsMaxRowIndex") { IsMaxRowIndex = i; }
            if (lvw.headers[i].dbname == "RowIndexNum") { RowIndexNumIndex = i; }
        }
        if (rowindex >= 0) {
            __lvw_je_updateCellValue(lvw.id, rowindex, RowIndexNumIndex, rowindex);
            __lvw_je_updateCellValue(lvw.id, rowindex, NewYearDayNumindex,1);
            __lvw_je_updateCellValue(lvw.id, posi, IsMaxRowIndex, 0);
            __lvw_je_updateCellValue(lvw.id, rowindex, IsMaxRowIndex, 1);
        }
    }
    if (lvw.id == "OverTimeRemindList") {
        var RemindUnitindex = 0;
        var IsMaxRowIndex = 0;
        var RowIndexNumIndex = 0;
        for (var i = 0; i < lvw.headers.length; i++) {
            if (lvw.headers[i].dbname == "RemindUnit") { RemindUnitindex = i; }
            if (lvw.headers[i].dbname == "IsMaxRowIndex") { IsMaxRowIndex = i; }
            if (lvw.headers[i].dbname == "RowIndexNum") { RowIndexNumIndex = i; }
        }
        if (rowindex >= 0) {
            __lvw_je_updateCellValue(lvw.id, rowindex, RowIndexNumIndex, rowindex);
            __lvw_je_updateCellValue(lvw.id, rowindex, RemindUnitindex, 2);
            __lvw_je_updateCellValue(lvw.id, posi, IsMaxRowIndex, 0);
            __lvw_je_updateCellValue(lvw.id, rowindex, IsMaxRowIndex, 1);
        }
    }

    if (lvw.id == "RestTimeRangesList") {
        var IsMaxRowIndex = 0;
        var RowIndexNumIndex = 0;
        var ShortStringIndex = 0;
        for (var i = 0; i < lvw.headers.length; i++) {

            if (lvw.headers[i].dbname == "IsMaxRowIndex") { IsMaxRowIndex = i; }
            if (lvw.headers[i].dbname == "RowIndexNum") { RowIndexNumIndex = i; }
            if (lvw.headers[i].dbname == "ShortString") { ShortStringIndex = i; }
        }
        if (rowindex >= 0) {
            __lvw_je_updateCellValue(lvw.id, rowindex, ShortStringIndex, "------");
            __lvw_je_updateCellValue(lvw.id, rowindex, RowIndexNumIndex, rowindex);
            __lvw_je_updateCellValue(lvw.id, posi, IsMaxRowIndex, 0);
            __lvw_je_updateCellValue(lvw.id, rowindex, IsMaxRowIndex, 1);
        }
    }
    
}
//删除年假重写
window.onListViewRowAfterDelete = function (lvw, pos) {
    if (lvw.id == "NewYearCountModeList" || lvw.id == "ProductionInspectionList"
        || lvw.id == "OverTimeRemindList" || lvw.id == "RestTimeRangesList") {
        var IsMaxRowIndex = 0;
        for (var i = 0; i < lvw.headers.length; i++) {
            if (lvw.headers[i].dbname == "IsMaxRowIndex") { IsMaxRowIndex = i; }
        }
        __lvw_je_updateCellValue(lvw.id, pos - 1, IsMaxRowIndex, 1);
    }
}







    