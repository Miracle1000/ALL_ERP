window.ManageViews = new Object();

//视图添加
ManageViews.RedirctToAdd = function (onlyname) {
    if (onlyname != "1 = 2")
        window.open("" + window.SysConfig.VirPath + "SYSN/view/comm/ManageViewsAdd.ashx?onlyname=" + onlyname + "", "", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200");
}

//视图详情跳转
ManageViews.RedirctToDetail = function (rowData) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/comm/ManageViewsAdd.ashx?view=details&ord=" + rowData.ID + "", "", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200");
}

//视图修改跳转
ManageViews.RedirctToModify = function (rowData) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/comm/ManageViewsAdd.ashx?ord=" + rowData.ID + "", "", "scrollbars=1,resizable=1,width=1100,height=500,top=200,left=200");
}

//视图状态更改
ManageViews.RedirctToState = function (rowData) {
    app.ajax.regEvent("updateStatus");
    app.ajax.addParam("ID", rowData.ID);
    app.ajax.send();
    Report.Refresh();
}

//视图删除
ManageViews.RedirctToDelete = function (rowData) {
    if (confirm("是否确认删除？")) {
        app.ajax.regEvent("Delete");
        app.ajax.addParam("ID", rowData.ID);
        app.ajax.send();
        Report.Refresh();
    }
}

window.OnBillLoad = function () {
    var obj = $("#SortRule_0");
    var data = window.opener.opener.Report.Data.orderfields;
    if (data) {
        for (var i in data) {
            obj.append("<option value='" + i + " ASC'>" + data[i] + "排序（升）</option>");
            obj.append("<option value='" + i + " DESC'>" + data[i] + "排序（降）</option>");
        }
        var sortruleV = "";
        sortruleV = $("#HSortRule_0").val();
        if (window.PageInitParams[0].uistate == "details") {
            sortruleV = $("td[dbname=HSortRule] div").html();
            if (sortruleV) {
                for (var i in data) {
                    if ((i+ " ASC") == sortruleV) {
                        $("#SortRule").text(data[i]+ "排序（升）");
                    }
                    else if ((i + " DESC") == sortruleV) {
                        $("#SortRule").text(data[i]+ "排序（降）");
                    }
                }
            }   
        }
        else {
            obj.val(sortruleV);
        }
    }
    var columnobj = "";
    var conditionobj = "";
    columnobj = $("#ColumnsTxt_0").val();
    conditionobj = $("#ConditionTxt_0").val();
    if (window.PageInitParams[0].uistate == "details") {
        columnobj = "";
        conditionobj = "";
        var dicobj = $("div[dbname=ColumnsTxt] div");
        if (dicobj) {
            columnobj = dicobj.html();
            $("div[dbname=ColumnsTxt] div").hide();
        }
        var conobj = $("div[dbname=ConditionTxt] div");
        if (conobj) {
            conditionobj = conobj.html();
            $("div[dbname=ConditionTxt] div").hide();
        }
    }
    if (columnobj && columnobj != "") {
        var jsondata = JSON.parse(columnobj);
        var sColumns = "";
        for (var i in jsondata)
        {
            if (jsondata[i]) {
                if (jsondata[i].isShow == "1") {
                    sColumns += "【" + jsondata[i].Title + "】 ";
                }
            }
        }
        $("#showColumns").html(sColumns);
    }
    if (conditionobj && conditionobj != "") {
        var jsondata = JSON.parse(conditionobj);
        var sCondition = "";
        for (var i in jsondata) {
            if (jsondata[i]) {
                sCondition += "【" + jsondata[i].Title + "】 ";
            }
        }
        $("#showCondition").html(sCondition);
    }
    if (!window.opener.opener.Report.Data.isenabledadvancedsearch) {
        $('#ConditionBtn').attr("disabled", "disabled");
    }
}

ManageViews.SetColumns = function () {
    var fd = window.PageInitParams[0].groups[0].fields[0];
    var showC = "";
    var hidV = [];
    for (var i in fd.listview.rows) {
        var array =  new Array();
        array = fd.listview.rows[i];
        if (array[2] == "1") {
            showC += "【" + fd.listview.rows[i][0] + "】 ";
        }
        var json = {};
        json.Title = array[0];
        json.dbName = array[1];
        json.isShow = array[2];
        json.cwidth = array[3];
        json.gd = array[4];
        hidV.push(json);
    }
    if (showC) {
        $("#showColumns", window.opener.document).html(showC);
        $("#ColumnsTxt_0", window.opener.document).val(JSON.stringify(hidV));
        window.close();
    }
    else {
        alert("视图中至少要显示一列数据！");
    }
}
