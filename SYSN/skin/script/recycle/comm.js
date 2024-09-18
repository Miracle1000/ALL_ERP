function showBtnHtml(id, canReset) {
    var htmlStr = "";
    var disabled = " ";
    if (canReset != "_url") { disabled = " disabled "; }
    htmlStr += "<button class='zb-button' onclick=\"handleBill('" + id + "',1)\" type='button' " + disabled + ">恢复</button>";
    htmlStr += "<button class='zb-button' onclick=\"handleBill('" + id + "',0)\" type='button'>彻底删除</button> ";
    return htmlStr;
}

function handleAllBill() {   
    if (confirm("确定要全部清空吗？")) {
        app.ajax.regEvent("DeleteAll");
        app.ajax.addParam("ID", 0);
        app.ajax.send();
        Report.Refresh();
    }
}

function handleBill(id, hid) {
    if (hid == 1) {
        if (confirm("确定要恢复该单据吗？")) {
            app.ajax.regEvent("Reset");
            app.ajax.addParam("ID", id);
            var r = app.ajax.send();
            if (r.length > 0) { alert(r); }
            Report.Refresh();
        }
    } else {
        if (confirm("彻底删除后不能再恢复，确定要彻底删除吗？")) {
            app.ajax.regEvent("Delete");
            app.ajax.addParam("ID", id);
            app.ajax.send();
            Report.Refresh();
        }
    }
}

function handleAll(hType) {
    var arrIds = new Array();
    var rowsID = Report.GetCheckedRows();
    if (rowsID.length > 0) {
        for (var i = 0; i < rowsID.length; i++) {
            arrIds.push(rowsID[i].id);
        }
    } else {
        alert("您没有选择任何信息，请选择后再批量处理！");
        return;
    }
    handleBill(arrIds, hType);
}


