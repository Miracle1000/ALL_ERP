window.stock = new Object();
stock.deleteAllForInventory = function () {
    var rowsID = Report.GetCheckedRows();
    if (rowsID.length > 0) {
        if (confirm("是否确认删除？")) {
            var arrIds = new Array();
            for (var i = 0; i < rowsID.length; i++) {
                if (rowsID[i].scright == "true") {
                    arrIds.push(rowsID[i].id);
                }
            }
            app.ajax.regEvent("Delete");
            app.ajax.addParam("ID", arrIds);
            app.ajax.send(function (r) {
                try { Report.Refresh(); }
                catch (e) { };
            });
        }
    }
    else {
        alert("请选择后再进行操作！");
    }
}

stock.deleteSingleForInventory = function (id) {
    if (confirm("是否确认删除？")) {
        app.ajax.regEvent("Delete");
        app.ajax.addParam("ID", id);
        app.ajax.send(function (r) {
            try { Report.Refresh(); }
            catch (e) { };
        });
    }
}

stock.showProductDetail = function (ord, name, pdright) {
    var htmlStr = name;
    if (pdright === 'true')
    {
        htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSA/product/content.asp?ord=" + app.pwurl(ord) + "','newwin1','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + name + "</a>";
    }
    return htmlStr;
}

stock.showGXDetail = function (ord) {
    return "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "SYSN/view/produce/ProductionOrderProcessList.ashx?ord=" + ord + "','newwin1','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">详情</a>";
}

stock.showDocumentDetailButtons = function (id, archive) {
    var html = "<button class=\"zb-button\" onclick=\"stock.DownloadDocument('" + id + "')\" title=\"下载\">下载</button>";
    html += "<button class=\"zb-button\" onclick=\"stock.PreviewDocument('" + id + "')\" title=\"预览\">预览</button>";
    if (archive == 0)
        html += "<button class=\"zb-button\" onclick=\"stock.FileDocument('" + id + "')\" title=\"归档\">归档</button>";
    return html;
}

stock.DownloadDocument = function (id) {
    app.ajax.regEvent("SysBillCallBack");
    app.ajax.addParam("__uilayout", Bill.getFiledsLayout());
    app.ajax.addParam("__maxspan", $ID("editbody").getAttribute("maxspan"));
    app.ajax.addParam("actionname", "DownloadDocument");
    app.ajax.addParam("ord", id);
    Bill.getBillData(function (key, value) {
        app.ajax.addParam("b_f_sv_" + key, value);
    });
    app.ajax.send(function (r) {});
}

stock.PreviewDocument = function (id) {
    app.ajax.regEvent("SysBillCallBack");
    app.ajax.addParam("__uilayout", Bill.getFiledsLayout());
    app.ajax.addParam("__maxspan", $ID("editbody").getAttribute("maxspan"));
    app.ajax.addParam("actionname", "PreviewDocument");
    app.ajax.addParam("ord", id);
    Bill.getBillData(function (key, value) {
        app.ajax.addParam("b_f_sv_" + key, value);
    });
    app.ajax.send(function (r) { });
}

stock.archieveDocument = function (ord) {
    if (confirm("确认归档吗？"))
    {
        app.ajax.regEvent("SysBillCallBack");
        app.ajax.addParam("__uilayout", Bill.getFiledsLayout());
        app.ajax.addParam("__maxspan", $ID("editbody").getAttribute("maxspan"));
        app.ajax.addParam("actionname", "DocumentArchive");
        app.ajax.addParam("ord", ord);
        Bill.getBillData(function (key, value) {
            app.ajax.addParam("b_f_sv_" + key, value);
        });
        app.ajax.send(function (r) { });
    }
}

stock.FileDocument = function (id) {
    if (confirm("确认归档吗？")) {
        app.ajax.regEvent("SysBillCallBack");
        app.ajax.addParam("__uilayout", Bill.getFiledsLayout());
        app.ajax.addParam("__maxspan", $ID("editbody").getAttribute("maxspan"));
        app.ajax.addParam("actionname", "DocumentArchiveDetail");
        app.ajax.addParam("id", id);
        Bill.getBillData(function (key, value) {
            app.ajax.addParam("b_f_sv_" + key, value);
        });
        app.ajax.send(function (r) { });
    }
}

stock.deleteDocument = function (ord) {
    if (confirm("确认删除吗？")) {
        app.ajax.regEvent("SysBillCallBack");
        app.ajax.addParam("__uilayout", Bill.getFiledsLayout());
        app.ajax.addParam("__maxspan", $ID("editbody").getAttribute("maxspan"));
        app.ajax.addParam("actionname", "DeleteDocument");
        app.ajax.addParam("ord", ord);
        Bill.getBillData(function (key, value) {
            app.ajax.addParam("b_f_sv_" + key, value);
        });
        app.ajax.send(function (r) { });
    }
}

stock.executeApproval = function (ord) {
    window.open('set.asp?ord=' + app.pwurl(ord), 'neww3win', 'width=' + 600 + ',height=' + 350 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
}