window.KQmanage = new Object();

//添加申请
KQmanage.dialogForAddApply = function () {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/attendancemanage/AddApply.ashx", "", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200");
}

//申请列表打印
KQmanage.printForApply = function () {
    window.print();
}

//跳转审批页面
KQmanage.approvalForApplyList = function (rowData, InstanceID, CreateID) {
    if (rowData != null)
        window.open("" + window.SysConfig.VirPath + "SYSN/view/comm/ApprovalExecute.ashx?workflowid=" + rowData.InstanceID + "&userid=" + rowData.CreateID + "&submitType=byadder&billAmount=0&r="+Math.random(), "approvalexcute", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200")
    else
        window.open("" + window.SysConfig.VirPath + "SYSN/view/comm/ApprovalExecute.ashx?workflowid=" + InstanceID + "&userid=" + CreateID + "&submitType=byadder&billAmount=0&r=" + Math.random(), "approvalexcute", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200")
}

//考勤申请列表归档+取消归档
KQmanage.fileForApplyList = function (rowData,ID,isFile) {
    app.ajax.regEvent("DocumentFiling");
    app.ajax.addParam("ID", rowData == null ? ID :rowData.ID);
    app.ajax.addParam("isFile", rowData == null ? isFile :rowData.isFile);
    app.ajax.send();
    if (rowData != null) {
        Report.Refresh();
    }
    else {
        location.reload();
        if(opener.Report)opener.Report.Refresh(); 
    }
}

//申请详情跳转
KQmanage.detailForApplyList = function (rowData) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/attendancemanage/AddApply.ashx?view=details&ord=" + app.pwurl(rowData.ID) + "", "", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200");
}

//申请标题详情跳转
KQmanage.detailForTitle = function (ID) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/attendancemanage/AddApply.ashx?view=details&ord=" + app.pwurl(ID) + "", "", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200");
}

//申请列表修改
KQmanage.modifyForApplyList = function (ID) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/attendancemanage/AddApply.ashx?ord=" + app.pwurl(ID) + "", "", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200");
}

//考勤申请列表删除单据
KQmanage.deleteForApplyList = function (rowData,ID) {
    if (confirm("是否确认删除？")) {
        app.ajax.regEvent("Delete");
        app.ajax.addParam("ID", rowData == null ? ID : rowData.ID);
        app.ajax.send();
        if (rowData != null) {
            Report.Refresh();
        }
        else {
            opener.Report.Refresh();
            window.close();
        }
    }
}

//考勤申请列表批量删除单据
KQmanage.deleteAllForApplyList = function () {
    var rowsID = Report.GetCheckedRows();
    if (rowsID.length > 0) {
        if (confirm("是否确认删除？")) {
            var arrIds = new Array();
            for (var i = 0; i < rowsID.length; i++) {
                if (rowsID[i].deleteBtn == "false") {
                    alert("不能删除审批中及已归档的单据！");
                    return;
                }
                arrIds.push(rowsID[i].ID);
            }
            app.ajax.regEvent("Delete");
            app.ajax.addParam("ID", arrIds);
            app.ajax.send();
            Report.Refresh();
        }
    }
    else {
        alert("请选择后再进行操作！");
    }
}

//考勤申请列表批量归档
KQmanage.fileAllForApplyList = function () {
    var rowsID = Report.GetCheckedRows();
    if (rowsID.length > 0) {
        if (confirm("是否确认全部归档？")) {
            var arrIds = new Array();
            var tipIds = new Array();
            for (var i = 0; i < rowsID.length; i++) {
                if (rowsID[i].isFileBtn == "true" && rowsID[i].isFile != "1") {
                    arrIds.push(rowsID[i].ID);
                }
                else {
                    tipIds.push(rowsID[i].ID);
                }
            }
            app.ajax.regEvent("AllDocumentFiling");
            app.ajax.addParam("IDs", arrIds);
            app.ajax.send();
            var tipsStr = "";
            for (var i = 0; i < tipIds.length; i++) {
                tipsStr += "id@" + tipIds[i] + "@Title@不允许归档|";
            }
            tipsStr = tipsStr.substring(0, tipsStr.length - 1);
            //Report.GenerateExcValues(tipsStr);  新的report已没有该方法，此处会报错
            Report.Refresh();
        }
    }
    else {
        alert("请选择后再进行操作！");
    }
}

//考勤申请列表批量打印单据
KQmanage.printAllForApplyList = function () {
    var rowsID = Report.GetCheckedRows();
    if (rowsID.length > 0) {
        var arrIds = new Array();
        for (var i = 0; i < rowsID.length; i++) {
            arrIds.push(rowsID[i].ID);
        }
        window.open("" + window.SysConfig.VirPath + "SYSN/view/comm/TemplatePreview.ashx?sort=80&ord=" + arrIds.toString().replace(/,/g, "|") + "", "", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200");
    }
    else {
        alert("请选择后再进行操作！");
    }
}

//打开考勤处理弹窗
KQmanage.disposeForComplaint = function (rowData) {
    app.closeWindow("DisposeID");
    var win = app.createWindow("DisposeID", rowData.btnValue, { closeButton: true, height: 250, width: 424, bgShadow: 30, canMove: 1 });
    win.innerHTML = "<iframe frameborder='0' scrolling=0 src='" + window.SysConfig.VirPath + "SYSN/view/attendance/attendancemanage/DisposeComplaint.ashx?ord=" + rowData.ID + "' width=\"400\" height=\"240\"> ";
    win.style.overflow = "hidden";
}


//取消提醒
KQmanage.CalcleForComplaint = function (rowData) {
    if (confirm("是否确认取消提醒？")) {
        app.ajax.regEvent("Cancle");
        app.ajax.addParam("ID",rowData.ID);
        app.ajax.send();
        Report.Refresh();
       
    }
}

//关闭考勤处理弹窗
KQmanage.closeForComplaint = function () {
    parent.Report.Refresh();
    parent.app.closeWindow("DisposeID");
}

//考勤处理-批量删除
KQmanage.deleteAllForComplaint = function () {
    var rowsID = Report.GetCheckedRows();
    if (rowsID.length > 0) {
        var arrIds = new Array();
        for (var i = 0; i < rowsID.length; i++) {
            if (rowsID[i].TreatmentStatus == "1") {
                alert("不能包含已处理的单据！");
                return;
            }
            if (rowsID[i].DisBtn == "false") {
                alert("不能包含没有操作权限的单据！");
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
        alert("请选择后再进行操作！");
    }
}

//考勤处理-批量处理
KQmanage.disposeAllForComplaint = function () {
    var rowsID = Report.GetCheckedRows();
    if (rowsID.length > 0) {
        var arrIds = new Array();
        for (var i = 0; i < rowsID.length; i++) {
            if (rowsID[i].TreatmentStatus == "1") {
                alert("不能包含已处理的单据！");
                return;
            }
            if (rowsID[i].DisBtn == "false") {
                alert("不能包含没有操作权限的单据！");
                return;
            }
            arrIds.push(rowsID[i].ID);
        }
        app.closeWindow("DisposeID");
        var win = app.createWindow("DisposeID", "批量处理", { closeButton: true, height: 240, width: 424, bgShadow: 30, canMove: 1 });
        win.innerHTML = "<iframe frameborder='0' scrolling=0 src='" + window.SysConfig.VirPath + "SYSN/view/attendance/attendancemanage/DisposeComplaint.ashx?ord=" + arrIds.join('|') + "' width=\"400\" height=\"240\"> ";
        win.style.overflow = "hidden";
    }
    else {
        alert("请选择后再进行操作！");
    }
}

//外勤管理点击人名刷新地图
KQmanage.RefershForFieldManage = function () {
    Bill.CallBack("", "Refersh_CallBack", true, "");
}

//待提交单据提交按钮触发
KQmanage.postForApplyList = function (rowData) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/comm/ApprovalSelect.ashx?workflowid=" + rowData.InstanceID + "&userid=" + rowData.CreateID + "&url=/SYSN/view/attendance/attendancemanage/ApplyManagement.ashx&addPageUrl=/SYSN/view/attendance/attendancemanage/ApplyManagement.ashx", "", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200")
}

//待提交单据提交按钮触发
KQmanage.postForApplyDetail = function (InstanceID, CreateID) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/comm/ApprovalSelect.ashx?workflowid=" + InstanceID + "&userid=" + CreateID + "&url=/SYSN/view/attendance/attendancemanage/ApplyManagement.ashx&addPageUrl=/SYSN/view/attendance/attendancemanage/ApplyManagement.ashx", "", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200")
}

//改审按钮
KQmanage.changeApprovalForApplyList = function (InstanceID) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/comm/ApprovalflowModify.ashx?workflowid=" + InstanceID + "", "approvalmodify", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200")
}

//考勤导入，查看说明按钮
KQmanage.dialogExplainForImport = function () {
    var win = app.createWindow("DisposeID", "导入说明", { closeButton: true, height: 280, width: 410, bgShadow: 30, canMove: 1 });
    var html = "<div style='padding:10px;'><h3 style='margin-left:130px;'>考勤记录导入说明</h3>";
    html += "<p style='line-height:20px;'>1、请严格按照范例的格式调整好要导入的EXCEL文件，列的顺序要与范例文档完全一致，列名不能为空。列内容不能为空。<p>";
    html += "<p style='line-height:20px;'>2、员工编号对应员工档案中的员工编号，签到时间和签退时间必须是【日期+时间】格式。<p>";
    html += "<p style='line-height:20px;'>3、请在导入前做好数据库的备份，以备导入错误的时候可以随时恢复系统数据到导入前的状态。<p></div>";
    win.innerHTML = html;
}

//Bill.OnFieldCallBack = function () {
//    return app.DataVerification(document.body);
//}