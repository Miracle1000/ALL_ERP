window.PBManage = new Object();

//班次列表添加页面跳转
PBManage.dialogForSetting = function () {
    //window.location.href = "TimeArrangeSetting.ashx";
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/workforcemanage/TimeArrangeSetting.ashx", "", "scrollbars=1,resizable=1,width=1200,height=600,top=150,left=150");
}

//班次列表页面打印
PBManage.printForSetting = function () {
    window.print();
}

//班次列表详情页面跳转
PBManage.detailForSetting = function (rowData) {
    //window.location.href = "TimeArrangeSetting.ashx?ord=" + rowData.ID + "&view=details";
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/workforcemanage/TimeArrangeSetting.ashx?ord=" + rowData.ID + "&view=details", "", "scrollbars=1,resizable=1,width=1200,height=600,top=150,left=150");
};

//班次列表复制页面跳转
PBManage.copyForSetting = function (rowData) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/workforcemanage/TimeArrangeSetting.ashx?__syscopyord=" + rowData.ID + "&view=copy", "", "scrollbars=1,resizable=1,width=1200,height=600,top=150,left=150");
};

//班次列表修改页面跳转
PBManage.modifyForSetting = function (rowData) {
    //window.location.href = "TimeArrangeSetting.ashx?ord=" + rowData.ID;
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/workforcemanage/TimeArrangeSetting.ashx?ord=" + rowData.ID + "", "", "scrollbars=1,resizable=1,width=1200,height=600,top=150,left=150");
};

//班次列表删除操作
PBManage.deleteForSetting = function (rowData) {
    if (confirm("是否确认删除？")) {
        app.ajax.regEvent("Delete");
        app.ajax.addParam("ID", rowData.ID);
        app.ajax.send();
        Report.Refresh();
    }
};

//人员分组添加跳转
PBManage.dialogForGroup = function () {
    //window.location.href = "AddPersonGroup.ashx";
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/workforcemanage/AddPersonGroup.ashx", "", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200");
}

//人员分组修改跳转
PBManage.updateForGroup = function (rowData) {
    //window.location.href = "AddPersonGroup.ashx?ord=" + rowData.ID;
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/workforcemanage/AddPersonGroup.ashx?ord=" + rowData.ID + "", "", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200");
}

//人员分组删除
PBManage.deleteForGroup = function (rowData) {
    if (confirm("是否确认删除？")) {
        app.ajax.regEvent("Delete");
        app.ajax.addParam("ID", rowData.ID);
        app.ajax.send();
        Report.Refresh();
    }
}

//人员分组停用启用
PBManage.disableForGroup = function (rowData) {
    app.ajax.regEvent("Disable");
    app.ajax.addParam("ID", rowData.ID);
    app.ajax.addParam("Disable", rowData.Disable);
    app.ajax.addParam("RangeType", rowData.RangeType);
    app.ajax.send();
    Report.Refresh();
}

//开始排班添加跳转
PBManage.dialogForAddScheduling = function () {
    //window.location.href = "AddScheduling.ashx";
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/workforcemanage/AddScheduling.ashx", "", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200");
}

//开始排班页面数据填充完毕后显示日历填充控件
PBManage.showDateForAddScheduling = function () {
    if (app.DataVerification(document.body)) {
        window.clanderPalnRowsObj = "";
        Bill.CallBack("", "ShowCalendarPlan", true, "");
    }
};

//开始排班页面数据非空校验
PBManage.checkNullForAddScheduling = function (value) {
    if (value != "" && value != null && value != undefined) {
        return false;
    }
    else {
        return true;
    }
}

//开始排班列表详情跳转
PBManage.detailForScheduling = function (rowData) {
    //window.location.href = 'AddScheduling.ashx?view=details&ord=' + rowData.ID;
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/workforcemanage/AddScheduling.ashx?view=details&ord=" + rowData.ID + "", "", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200");
}

//开始排班列表修改跳转
PBManage.modifyForScheduling = function (rowData) {
    //window.location.href = 'AddScheduling.ashx?ord=' + rowData.ID;
    window.open("" + window.SysConfig.VirPath + "SYSN/view/attendance/workforcemanage/AddScheduling.ashx?ord=" + rowData.ID + "", "", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200");
}

//开始排班列表删除
PBManage.deleteForScheduling = function (rowData) {
    if (confirm("是否确认删除？")) {
        app.ajax.regEvent("Delete");
        app.ajax.addParam("ID", rowData.ID);
        app.ajax.send();
        Report.Refresh();
    }
}

//添加多个班次时弹性时间不允许输入
PBManage.onListChane = function () {
    setTimeout(function () {
        var domTime = $("input[name=ElasticTimeMinute]");
        if (domTime.length > 1) {
            domTime.attr("readonly", "readonly");
            domTime.attr("style", "background-color:#c0c0c0");
            domTime.val(0);
        }
        else {
            domTime.removeAttr("readonly");
            domTime.removeAttr("style");
            domTime.val(0);
        }
    }, 10);
}
Bill.onDelListGroup = PBManage.onListChane;
Bill.onAddListGroup = PBManage.onListChane;

//假日日历获取日期
PBManage.getdataForCalendar = function () {
    Bill.CallBack("", "GetData", true, "");
}

//获取弹窗中选中的分组ID
PBManage.getCheckedGroupIDsForScheduling = function () {
    var rowsID = Report.GetCheckedRows();
    if (rowsID.length > 0) {
        var arrIds = new Array();
        var arrNames = new Array();
        for (var i = 0; i < rowsID.length; i++) {
            arrIds.push(rowsID[i].ID);
            arrNames.push(rowsID[i].GroupName);
        }
    }

    var urlatts = window.location.href.split("?")[1].split("&");
    var result = { "value": "", "text": "", keys: {}, "tag": null };
    for (var i = 0; i < urlatts.length; i++) {
        var item = urlatts[i].split("=");
        result.keys[item[0]] = encodeURI(item[1]);
    }
    result.text = arrNames.join(",");
    result.value = arrIds.join(",");

    if (opener && opener.OnFieldAutoCompleteCallBack) {
        opener.OnFieldAutoCompleteCallBack(result);
        setTimeout("window.close()", 50);  //加定时器，防止谷歌死锁

    }
}

//开始排班选择分组，自动赋值
function HandleCustomResult(Rows, title) {
    if (title == "人员分组") {
        if (opener && opener.AutoCompleteShowUrlPageCurrDefaultValue) {
            if (Rows && Rows.length > 0) {
                for (var i = 0, len = Rows.length; i < len; i++) {
                    if (("," + opener.AutoCompleteShowUrlPageCurrDefaultValue + ",").indexOf("," + Rows[i].ID + ",") > -1) {
                        var index = Rows[i].__id;
                        manager.select(index);
                    }
                }
            }
        }
    }
}

//老数据迁移
PBManage.OldDataMigration = function () {
    if (confirm("是否确认迁移旧考勤数据至新考勤系统？")) {
        var div = document.createElement("div"), html = [];
        document.body.appendChild(div);
        div.className = "nexloading";
        div.style.cssText = "width:100%;height:100%;top:0;left:0;border-radius:0;";
        var wid = parseFloat(document.documentElement.clientWidth || document.body.clientWidth) / 2 - 175 + "px";
        var hei = parseFloat(document.documentElement.clientHeight || document.body.clientHeight) / 2 - 160 + "px";
        html.push("<div class='dialog_div_inner' style='left:" + wid + ";top:" + hei + "'>");
        html.push("<img  src='" + (window.SysConfig.VirPath + "sysn/skin/default/img/loadperson.gif") + "' />");
        html.push("<div style='font-size: 14px;'>数据正在迁移中……</div><div style='padding-top: 20px;'>迁移过程中切勿切换页面及关闭浏览器。</div>");
        html.push("</div>");
        div.innerHTML = html.join("");
        app.ajax.regEvent("OldDataMigration");
        app.ajax.send(function (r) {
            if (r != "" && r != undefined && r != null) {
                alert(r);
            }
            document.body.removeChild(div);
            Report.Refresh();
        });
    }
}

PBManage.showForMapWindow = function (obj, e) {
    app.closeWindow("MapWindow");
    e = e || window.event;
    var bodyheight = document.documentElement.clientHeight || document.body.clientHeight;
    var windowHeight = 0;
    if ((bodyheight - e.clientY) < 190) {
        windowHeight = 215;
    }
    var rowindex = obj.parentNode.parentNode.parentNode.parentNode.getAttribute("pos");
    var win = app.createWindow("MapWindow", "地址选择", { closeButton: true, bgShadow: 30, left: e.clientX - 550, top: (e.clientY - 200 - windowHeight) < 0 ? 0 : (e.clientY - 200 - windowHeight), height: 500, width: 755 });
    win.innerHTML = "<iframe frameborder='0' scrolling=0  src='chooseAddress.html?rowindex=" + rowindex + "' width=\"100%\" height=\"100%\"> ";
    win.style.overflow = "hidden";
}
