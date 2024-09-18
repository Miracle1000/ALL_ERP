window.MyKQ = new Object();

//考勤记录页面打印
MyKQ.printForRecord = function () {
    window.print();
}

//考勤记录申诉弹层
MyKQ.appealForRecord = function (UserID, DateText, WeekName, StatusID, TimeArrangeID, hcdlid, FirstDate, LastDate, Title, AppealBeginDate, AppealEndDate, UnusualWorkType) {
    debugger;
    app.closeWindow("AddAppealID");
    var win = app.createWindow("AddAppealID", "申诉", { closeButton: true, height: 500, width: 624, bgShadow: 30, canMove: 1 });
    var options = "?ui_noscroll=1&UID=" + UserID + "&DAY=" + DateText + "&WEEK=" + WeekName + "&REASONID=" + StatusID + "&SHOULD=" + TimeArrangeID + "&CLOCKID=" + hcdlid + "&FIRST=" + FirstDate + "&LAST=" + LastDate + "&Title=" + Title + "&AppealBeginDate=" + AppealBeginDate + "&AppealEndDate=" + AppealEndDate + "&UnusualWorkType=" + UnusualWorkType;
    win.innerHTML = "<iframe frameborder='0' scrolling=0 src='" + window.SysConfig.VirPath + "SYSN/view/attendance/myattendance/AddAppeal.ashx" + options + "' width=\"600\" height=\"380\"> ";
    win.style.overflow = "hidden";
}

//考勤记录修订弹层
MyKQ.reviseForRecord = function (UserID, DateText, WeekName, StatusID, TimeArrangeID, hcdlid, FirstDate, LastDate, Title, AppealBeginDate, AppealEndDate, UnusualWorkType) {
    debugger;
    app.closeWindow("AddreviseID");
    var win = app.createWindow("AddreviseID", "修订", { closeButton: true, height: 300, width: 624, bgShadow: 30, canMove: 1 });
    var options = "?ui_noscroll=1&UID=" + UserID + "&DAY=" + DateText + "&WEEK=" + WeekName + "&REASONID=" + StatusID + "&SHOULD=" + TimeArrangeID + "&CLOCKID=" + hcdlid + "&FIRST=" + FirstDate + "&LAST=" + LastDate + "&Title=" + Title + "&AppealBeginDate=" + AppealBeginDate + "&AppealEndDate=" + AppealEndDate + "&UnusualWorkType=" + UnusualWorkType;
    win.innerHTML = "<iframe frameborder='0' scrolling=0 src='" + window.SysConfig.VirPath + "SYSN/view/attendance/myattendance/AddRevise.ashx" + options + "' width=\"600\" height=\"380\"> ";
    win.style.overflow = "hidden";
}

//关闭考勤记录申诉弹层
MyKQ.closeAppealForRecord = function () {
    parent.Report.Refresh();
    parent.app.closeWindow("AddAppealID");
}

//关闭考勤记录修订弹层
MyKQ.closeAddreviseForRecord = function () {
    parent.Report.Refresh();
    parent.app.closeWindow("AddreviseID");
}

//考勤记录中点击查看弹出打卡记录
MyKQ.showForLoginList = function (obj, date, beginDate, endDate, userid, e) {
    app.closeWindow("LoginDetailsID");
    e = e || window.event;
    var bodyheight = document.documentElement.clientHeight || document.body.clientHeight;
    var windowHeight = 0;
    if ((bodyheight - e.clientY) < 190) {
        windowHeight = 215;
    }
    var win = app.createWindow("LoginDetailsID", "登录明细", { closeButton: true, left: e.clientX - 480, top: e.clientY + 15 - windowHeight, height: 300, width: 500,canMove:1 });
    win.innerHTML = "<iframe frameborder='0' scrolling=0 src='" + window.SysConfig.VirPath + "SYSN/view/attendance/myattendance/HistoryRecord.ashx?date=&beginDate=" + beginDate + "&endDate=" + endDate + "&userid=" + userid + "' width=\"100%\" height=\"100%\"> ";
    win.style.overflow = "hidden";
}

window.onscroll = function () {
    app.closeWindow("LoginDetailsID");
}

//我的申诉页面打印
MyKQ.printForComplaint = function () {
    window.print();
}

//我的申诉-批量删除
MyKQ.deleteAllForComplaint = function () {
    var rowsID = Report.GetCheckedRows();
    if (rowsID.length > 0) {
        var arrIds = new Array();
        for (var i = 0; i < rowsID.length; i++) {
            if (rowsID[i].TreatmentStatus == "1") {
                alert("不能包含已处理的单据！");
                return;
            }
            arrIds.push(rowsID[i].ID);
        }
        if (confirm("是否确认删除？")) {
            app.ajax.regEvent("Delete");
            app.ajax.addParam("IDs", arrIds);
            app.ajax.send();
            Report.Refresh();
        }
    }
    else {
        alert("您没有选择数据，请选择后再删除！");
    }
}

//考勤记录切换日期
MyKQ.getdataForCalendar = function () {
    // $("#hidPageValue6").val("{PStartDate:'2016-09-1',PEndDate:'2016-10-1',PendTime:'2016-09-25'}");
    Report.SetSearchData(0)
    Report.ReportSubmit();
    // Bill.CallBack("", "GetData", true, "");
}

//考勤明细查看地址跳转到外勤管理
MyKQ.OpenFieldManage = function (name, address, coords) {
    if (address != "") {
        var re = /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/;
        if (re.test(address)) {
            if (RegExp.$1 < 256 && RegExp.$2 < 256 && RegExp.$3 < 256 && RegExp.$4 < 256)
                return false;
        }
        window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/attendancemanage/FieldManage.ashx?name=" + name + "&site=" + address + "&coords=" + coords + "", "", "width=800px,height:600px");
    }
}

MyKQ.getdataForMyTime = function () {
    Bill.CallBack("", "changeMonth_CallBack", true, "");
}