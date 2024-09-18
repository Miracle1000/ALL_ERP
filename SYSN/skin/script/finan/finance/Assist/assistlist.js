if (!window.assistlist) { window.assistlist = new Object(); }

assistlist.addAssistListNode = function (nodeid, ptype) {
    app.closeWindow("AddAssistListNode");
    var win = app.createWindow("AddAssistListNode", "添加", {
        width: 430,
        height: ptype >= 1 ? 256 : 175,
        closeButton: true,
        maxButton: false,
        minButton: false,
        canMove: true,
        sizeable: false
    });
    // result为json 格式是bill单据 包含主题和2个字段view\finan\finance\Assist
    if (ptype == 0)
    {
        win.innerHTML = "<iframe frameborder='0' scrolling=0 src='" + window.SysConfig.VirPath + "SYSN/view/finan/finance/Assist/AssistAdd.ashx?pid=" + nodeid + "&ptype=" + ptype + "' width=\"400\" height=\"" + (app.IeVer == 7 ? 108 : 105) + "\"> ";
    }
    else
    {
        win.innerHTML = "<iframe frameborder='0' scrolling=0 src='" + window.SysConfig.VirPath + "SYSN/view/finan/finance/Assist/AssistAdd.ashx?pid=" + nodeid + "&ptype=" + ptype + "' width=\"400\" height=\"185\"> ";
    }
}

assistlist.modifyAssistListNode = function (nodeid, ptype) {
    app.closeWindow("ModifyAssistListNode");
    var win = app.createWindow("ModifyAssistListNode", "修改", {
        width: 430,
        height: ptype>=1?256:175,
        closeButton: true,
        maxButton: false,
        minButton: false,
        canMove: true,
        sizeable: false
    });
    // result为json 格式是bill单据 包含主题和2个字段view\finan\finance\Assist
    if (ptype > 0)
    {
        win.innerHTML = "<iframe frameborder='0' scrolling=0 src='" + window.SysConfig.VirPath + "SYSN/view/finan/finance/Assist/AssistAdd.ashx?ord=" + nodeid + "&ptype=" + ptype + "' width=\"400\"  height=\"185\"> ";
    }
    else
    {
        win.innerHTML = "<iframe frameborder='0' scrolling=0 src='" + window.SysConfig.VirPath + "SYSN/view/finan/finance/Assist/AssistAdd.ashx?ord=" + nodeid + "&ptype=" + ptype + "' width=\"400\"  height=\""+ (app.IeVer==7?108:105) +"\"> ";
    }
    //win.innerHTML = "<iframe frameborder='0' scrolling=0 src='" + window.SysConfig.VirPath + "SYSN/view/finan/finance/Assist/AssistAdd.ashx?ord=" + nodeid + "&ptype=" + ptype + "' width=\"400\" height=\"105\"> ";
}
