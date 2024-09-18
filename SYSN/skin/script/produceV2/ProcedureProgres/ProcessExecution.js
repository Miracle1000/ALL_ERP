function showFunctionButton(WProce, oldNum, id, TaskId, sort, pStart, pReStart, qxdetail, pDistribute, pHuiBao) {
    var htmlStr = "<table style='border:0;*display: inline;display:inline-block;vertical-align:middle'><tr><td rowspan='2'>";
    if (oldNum > 0) {
        WProce += "<变更前" + app.FormatNumber(oldNum, 'numberbox') + ">"
    }
    if (qxdetail > 0) {
        htmlStr += OnHrefLinkUrl("SYSN/view/produceV2/ProcedureProgres/AddProcedureProgres.ashx?ord=" + app.pwurl(id) + "&view=details", WProce) + "</td>";;
    } else {
        htmlStr += WProce + "</td>";
    }
    if (sort == 0) {
        if (pDistribute > 0) {
            htmlStr += AddFunctionTd("SYSN/view/produceV2/ProcedureProgres/AddProcedureTask.ashx?WFPAID=" + app.pwurl(id), "分配");
        }
        if (pHuiBao > 0) {
            htmlStr += "<tr>" + AddFunctionTd("SYSN/view/produceV2/ProcedureProgres/ProcessReport.ashx?WFPAID=" + app.pwurl(id), "汇报");
        }
    } else {
        // 开始反开始的操作是修改状态和时间
        if (pStart > 0) {
            htmlStr += AddButtonTd(TaskId, "开始", 1);
        }
        if (pReStart > 0) {
            htmlStr += AddButtonTd(TaskId, "反开始", 0);
        }
        if (pHuiBao > 0) {
            var url = "SYSN/view/produceV2/ProcedureProgres/ProcessReport.ashx?WFPAID=" + app.pwurl(id) + "&TaskID=" + app.pwurl(TaskId)+"&isScanf=1";
            htmlStr += "<tr>" + AddFunctionTd(url, "汇报");
        }
    }
    htmlStr += "</table>";
    return htmlStr;
}

function OnHrefLinkUrl(url, title) {
    var htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:app.OpenUrl('";
    htmlStr += window.SysConfig.VirPath;
    htmlStr += url;
    htmlStr += "')\">" + title + "</a>";
    return htmlStr
}

function OnStartClick(id, title,status) {
    var htmlStr = "<a href = 'javascript:void(0);' onclick = 'SetStarted(" + id + ","+status+")' >" + title + " </a>";
    return htmlStr;
}

function SetStarted(id, status) {
    app.ajax.regEvent('SetStarted');
    app.ajax.addParam('id', id);
    app.ajax.addParam('status', status);
    app.ajax.send();
    Report.Refresh();
}

function AddFunctionTd(url, title) {
    var htmlStr = "<td style='text-align:left;min-width:60px;'><img src='" + window.SysConfig.VirPath + "sysa/images/jiantou.gif'>";
    htmlStr += OnHrefLinkUrl(url, title);
    htmlStr += "</td></tr>";
    return htmlStr
}

function AddButtonTd(id, title, status) {
    var htmlStr = "<td style='text-align:left;min-width:60px;'><img src='" + window.SysConfig.VirPath + "sysa/images/jiantou.gif'>";
    htmlStr += OnStartClick(id, title, status);
    htmlStr += "</td></tr>";
    return htmlStr
}


function refreshStartTaskUI(sort, exectask, wpstatus, taskstatus) {
    var statusTxt = wpstatus;
    if (sort == 0) {
        if (exectask > 0) {
            statusTxt += '<br/>' + taskstatus;
        }
    }
    return statusTxt;
}