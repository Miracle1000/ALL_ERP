if (!window.approval) { window.approval = new Object(); }
approval.target = function (obj) {
    window.location.href = window.SysConfig.VirPath+"SYSN/view/comm/ApprovalSetting.ashx?billType=" + $("#hidbilltype").val() + "&billCategory=" + $(obj).val() + "&billRight=" + $("#hidbillright").val();
};
approval.addRules = function (billtype, billcategory,billright) {
    window.location.href = window.SysConfig.VirPath+"SYSN/view/comm/ApprovalRuleAdd.ashx?billType=" + billtype + "&billCategory=" + billcategory + "&billRight=" + billright;
};
approval.targetApprovalSetting = function (billtype, billcategory,billright) {
    window.location.href = window.SysConfig.VirPath+"SYSN/view/comm/ApprovalSetting.ashx?billType=" + billtype + "&billCategory=" + billcategory + "&billRight=" + billright;
};
approval.targetApprovalSetting2 = function (billtype, billcategory, billright,addnew) {
    window.location.href = window.SysConfig.VirPath + "SYSN/view/comm/ApprovalSetting.ashx?billType=" + billtype + "&billCategory=" + billcategory + "&billRight=" + billright + "&addnew=" + addnew;
    app.closeWindow("chooseApprovalCategory");
};
approval.targetApprovalFlowModify = function (workflowid,handletype,userid) {
    window.location.href = window.SysConfig.VirPath+"SYSN/view/comm/ApprovalflowModify.ashx?workflowid=" + workflowid + "&handleType=" + handletype + "&userid=" + userid;
};
approval.targetApprovalSelect = function (workflowid, userid, url, addPageUrl) {
    var targetUrl = window.SysConfig.VirPath+"SYSN/view/comm/ApprovalSelect.ashx?workflowid=" + workflowid + "&userid=" + userid;
    if (typeof url != "undefined" && url != "") {
        targetUrl += "&url=" + encodeURIComponent(url);
    }
    if (typeof addPageUrl != "undefined" && addPageUrl != "") {
        targetUrl += "&addPageUrl=" + encodeURIComponent(addPageUrl);
    }
    window.location.href = targetUrl;
};
approval.targetApprovalDelegate = function () {
    window.location.href = window.SysConfig.VirPath+"SYSN/view/comm/ApprovalDelegateRecord.ashx?&userid=" + $("#hiduserid").val();
};
approval.updateRules = function (ruleid,billright) {
    window.location.href = window.SysConfig.VirPath+"SYSN/view/comm/ApprovalRuleModify.ashx?ruleid=" + ruleid + "&billRight=" + billright;
};
approval.redirectTo = function (url) {
    try {
        if (window.opener.opener) {
            if(navigator.userAgent.indexOf("MSIE")>0){
                window.opener.location.reload();
                window.opener.opener.location.reload();
                if( window.opener.opener.Report){
                    window.opener.opener.Report.Refresh();
                }
                window.opener.close(); window.close();
            }else{
                window.opener.location.reload();
                window.opener.opener.location.reload();
                window.opener.opener.Report.Refresh();
                window.opener.close(); window.close();
            }

        }
        else {
            if(window.opener.Report){  window.opener.Report.Refresh();}
           window.close()
        }
    }
    catch (e) {
        window.close();
    }
};
approval.deleteRules = function (ruleid, dbname, sign) {
    var msg = sign == 1 ? "有正在执行的单据，确定删除吗？" : "确定删除吗？";
    if (confirm(msg)) {
        app.ajax.regEvent("SysBillCallBack");
        app.ajax.addParam("__uilayout", Bill.getFiledsLayout());
        app.ajax.addParam("__maxspan", $ID("editbody").getAttribute("maxspan"));
        app.ajax.addParam("actionname", dbname);
        app.ajax.addParam("ruleid", ruleid);
        Bill.getBillData(function (key, value) {
            app.ajax.addParam("b_f_sv_" + key, value);
        });
        app.ajax.send(function (r) { });
    }
}
approval.addRuleNode = function (ruleid, billType, billCategory,billright) {
    window.location.href = window.SysConfig.VirPath+"SYSN/view/comm/ApprovalRuleNodeAdd.ashx?ruleid=" + ruleid + "&billtype=" + billType + "&billCategory=" + billCategory + "&billRight=" + billright;
};
approval.addRuleNodeRelation = function (ruleid, billType, billCategory, billright) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/comm/ApprovalRuleNodeAddRelation.ashx?ruleid=" + ruleid + "&billtype=" + billType + "&billCategory=" + billCategory + "&billRight=" + billright + "", "", "scrollbars=1,resizable=1,width=700,height=400,top=250,left=350");
}
approval.generateHandle = function (data,ruleid) {
    var html = "";
    //html += "<button onclick=\"approval.updateApprovalNode(this,'" + data + "','" + ruleid + "')\" title=\"不影响关联单据\">修改</button> ";
    html += "<button class=\"zb-button\" onclick=\"approval.updateApprovalNodeAndHisChildren(this,'" + data + "','" + ruleid + "')\" title=\"影响关联单据\">修改</button> ";
    //html += "<button onclick=\"approval.deleteApprovalNode('" + data + "')\" title=\"不影响关联单据\">删除</button> ";
    html += "<button class=\"zb-button\" onclick=\"approval.deleteApprovalNodeAndHisChildren('" + data + "')\" title=\"影响关联单据\">删除</button>";
    return html;
}
approval.updateApprovalNode = function (obj, data, ruleid) {
    window.location.href = window.SysConfig.VirPath+"SYSN/view/comm/ApprovalRuleNodeModify.ashx?ruleid=" + ruleid + "&nodeid=" + data + "&billtype=" + $("#hidbilltype").val() + "&billCategory=" + $("#hidbillcategory").val() + "&billRight=" + $("#hidbillright").val();
}
approval.updateApprovalNodeAndHisChildren = function (obj, data, ruleid) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/comm/ApprovalRuleNodeModifyRelation.ashx?ruleid=" + ruleid + "&nodeid=" + data + "&billtype=" + $("#hidbilltype").val() + "&billCategory=" + $("#hidbillcategory").val() + "&billRight=" + $("#hidbillright").val() + "", "", "scrollbars=1,resizable=1,width=700,height=400,top=250,left=350");
}
approval.deleteApprovalNode = function (nodeid) {
    if (confirm("确定删除吗？")) {
        app.ajax.regEvent("SysBillCallBack");
        app.ajax.addParam("__uilayout", Bill.getFiledsLayout());
        app.ajax.addParam("__maxspan", $ID("editbody").getAttribute("maxspan"));
        app.ajax.addParam("actionname", 'DeleteNodeClick');
        app.ajax.addParam("nodeid", nodeid);
        Bill.getBillData(function (key, value) {
            app.ajax.addParam("b_f_sv_" + key, value);
        });
        app.ajax.send(function (r) { });
    }
}
approval.deleteApprovalNodeAndHisChildren = function (nodeid) {
    if (confirm("确定删除吗？如果删除会影响关联单据的审批流程。")) {
        app.closeWindow("DeleteApprovalRuleNode");
        var url = window.SysConfig.VirPath + "SYSN/view/comm/ApprovalNodeDeleteRelation.ashx?nodeid=" + nodeid + "&billtype=" + $("#hidbilltype").val() + "&billCategory=" + $("#hidbillcategory").val() + "&billRight=" + $("#hidbillright").val();
        var win = app.createWindow("DeleteApprovalRuleNode", "删除审批流程", { closeButton: true, height: 500, width: 700 });
        win.innerHTML = "<iframe frameborder='0' scrolling=0  src='" + url + "' width=\"700\" height=\"500\"> ";
        win.style.overflow = "hidden";
    }
}
approval.generateUpdateWorkflowButton = function (data,instanceid) {
    var html = "";
    html += "<button class=\"zb-button\" onclick=\"approval.deleteworkflowitem('" + data + "','" + instanceid + "')\">删除</button>";
    return html;
}
approval.generateDelegateControl = function (index, isAgree, startDate, endDate) {
    var html = [];
    html.push("<table><tr style='background:none;'>");
    html.push("<td style='width:80px;'><div class=\"sub-field gray\" style='text-align: left'><input uitype=\"radioboxs\" dvc=\"1\" onclick=\"changeDelegateControl(1," + index + ")\" style=\"vertical-align:middle\" checked=\"\" name=\"IsNecessary" + index + "\" id=\"IsNecessary_0" + index + "\" type=\"radio\" value=\"1\" " + (isAgree == 1 ? "checked" : "") + "><label style=\"vertical-align:middle\" for=\"IsNecessary_0" + index + "\">是</label><input uitype=\"radioboxs\" dvc=\"1\" onclick=\"changeDelegateControl(0," + index + ")\" style=\"vertical-align:middle\" name=\"IsNecessary" + index + "\" id=\"IsNecessary_1" + index + "\" type=\"radio\" value=\"0\" " + (isAgree == 0 ? "checked" : "") + "><label style=\"vertical-align:middle\" for=\"IsNecessary_1" + index + "\">否</label></div></td>");
    html.push("<td id=\"tdDelegateControl0" + index + "\" width=\"20px\" style=\"" + (isAgree == 1 ? "display:none":"") + "\"></td>");
    html.push("<td id=\"tdDelegateControl1" + index + "\" style=\"width:110px;padding:0;" + (isAgree == 1 ? "display:none" : "") + "\"><div style='position:relative;top:4px;' class=\"sub-field gray\" style='margin: 0;padding:0'><div class=\"sub-field gray\" style='margin: 0;padding:0;width: 100px;height:28px;'><input dateui=\"\" uiskin=\"date\" class=\"billfieldbox\" dvc=\"1\" isfield=\"1\" type=\"text\" style=\"width:100px\" uitype=\"rangefield\" name=\"CreateDate\" id=\"CreateDate_0" + index + "\" value=\"" + startDate + "\"><span type=\"button\" undefined=\"\" unselectable=\"on\" readonly=\"\" class=\"fieldDateBtn chrome\"  style='position: absolute;top:1px!important;left:101px;*left:101px!important;width: 18px;height:18px;' onclick=\"datedlg.show()\"></span></div></td>");
    html.push("<td id=\"tdDelegateControl2" + index + "\" style=\"width:10px;text-align:right;" + (isAgree == 1 ? "display:none" : "") + "\">-</td>");
    html.push("<td id=\"tdDelegateControl3" + index + "\" style=\"padding:0;" + (isAgree == 1 ? "display:none" : "") + "\"><div class=\"sub-field gray\" style='margin: 0;padding:0;position: relative;'><input dateui=\"\" uiskin=\"date\" class=\"billfieldbox\" dvc=\"1\" isfield=\"1\" type=\"text\" style=\"width:100px;float: left\" uitype=\"rangefield\" name=\"CreateDate\" id=\"CreateDate_0" + index + "\" value=\"" + endDate + "\"><span type=\"button\" unselectable=\"on\" readonly=\"\" class=\"fieldDateBtn chrome\" onclick=\"datedlg.show()\" style='position: absolute;top:1px!important;left:101px;*left:101px;width: 18px;height:18px;'></span></div></div></td>");
    html.push("</tr></table>");
    return html.join("");
}
function changeDelegateControl(sign,index)
{
    if (sign == 0) {
        $("#tdDelegateControl0"+index).show();
        $("#tdDelegateControl1"+index).show();
        $("#tdDelegateControl2"+index).show();
        $("#tdDelegateControl3" + index).show();
    }
    else {
        $("#tdDelegateControl0"+index).hide();
        $("#tdDelegateControl1"+index).hide();
        $("#tdDelegateControl2"+index).hide();
        $("#tdDelegateControl3" + index).hide();
    }
}
approval.SaveApprovalDelegateRecord = function () {
    if (app.DataVerification(document.body,null,1) == false)  //单据数据校验
    {
        return false; //校验失败
    }
    var data = [];
    $("#lvw_dbtable_delegateApproval tbody tr.lr_je_sel").each(function (index, element) {
        var item = [];
        var isEnabled = $(element).children("td:eq(1)").find("input[name^='@delegateApproval_是否启用']:checked").val();
        var isForEver = $(element).children("td:eq(2)").find("input[name^='IsNecessary']:checked").val();
        var startDate = "";
        var endDate = "";
        if (isForEver == 0)
        {
            startDate = $(element).children("td:eq(2)").find("input.billfieldbox:eq(0)").val();
            endDate = $(element).children("td:eq(2)").find("input.billfieldbox:eq(1)").val();
        }
        var weituoren = $(element).children("td:eq(3)").find("input:eq(0)").val();
        var tempIndex = index + 1;
        var recordid = $("#hidrecord" + tempIndex).val();
        var userid = $("#hiduserid").val();
        var billtype = $("#hidbilltype" + tempIndex).val();

        item.push("\"isEnabled\"" + ":\"" + isEnabled+"\"");
        item.push("\"isForEver\"" + ":\"" + isForEver + "\"");
        item.push("\"startDate\"" + ":\"" + startDate + "\"");
        item.push("\"endDate\"" + ":\"" + endDate + "\"");
        item.push("\"weituoren\"" + ":\"" + weituoren + "\"");
        item.push("\"recordid\"" + ":\"" + recordid + "\"");
        item.push("\"userid\"" + ":\"" + userid + "\"");
        item.push("\"billtype\"" + ":\"" + billtype + "\"");
        data.push("{" + item.join(",") + "}");
    });
    app.ajax.regEvent("SysBillCallBack");
    app.ajax.addParam("__uilayout", Bill.getFiledsLayout());
    app.ajax.addParam("__maxspan", $ID("editbody").getAttribute("maxspan"));
    app.ajax.addParam("actionname", 'SaveApprovalDelegateClick');
    app.ajax.addParam("data", "[" + data.join(",") + "]");
    app.ajax.send(function (r) {});
}
approval.deleteworkflowitem = function (nodeid,instanceid) {
    if (confirm("确定删除吗？")) {
        app.ajax.regEvent("SysBillCallBack");
        app.ajax.addParam("__uilayout", Bill.getFiledsLayout());
        app.ajax.addParam("__maxspan", $ID("editbody").getAttribute("maxspan"));
        app.ajax.addParam("actionname", 'DeleteInstanceNodeClick');
        app.ajax.addParam("nodeid", nodeid);
        app.ajax.addParam("instanceid", instanceid);
        Bill.getBillData(function (key, value) {
            app.ajax.addParam("b_f_sv_" + key, value);
        });
        app.ajax.send(function (r) { });
    }
}
approval.SetEnabledDelegate = function (recordid) {
    app.ajax.regEvent("SysBillCallBack");
    app.ajax.addParam("__uilayout", Bill.getFiledsLayout());
    app.ajax.addParam("__maxspan", $ID("editbody").getAttribute("maxspan"));
    app.ajax.addParam("actionname", 'SetEnabledDelegateClick');
    app.ajax.addParam("recordid", recordid);
    app.ajax.send(function (r) { });
}

approval.dialogForAddApprovalCode = function (billType, billCategory, billRight) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/comm/ApprovalRuleAdd.ashx?billType=" + billType + "&billCategory=" + billCategory + "&billRight=" + billRight + "", "", "scrollbars=1,resizable=1,width=700,height=400,top=250,left=350");
}
approval.dialogForAddApprovalCode2 = function (billType,billCategory, billRight) {
    app.closeWindow("chooseApprovalCategory");
    var url = window.SysConfig.VirPath + "SYSN/view/comm/ApprovalSelectCategory.ashx?billType=" + billType + "&billRight=" + billRight + "&billCategory=" + billCategory;
    var win = app.createWindow("chooseApprovalCategory", "选择审批分类", { closeButton: true, height: 150, width: 400 });
    win.innerHTML = "<iframe frameborder='0' scrolling=0  src='" + url + "' width=\"400\" height=\"150\"> ";
    win.style.overflow = "hidden";
}
approval.dialogForModifyApprovalCode = function (ruleid, billright) {
    window.open("" + window.SysConfig.VirPath + "SYSN/view/comm/ApprovalRuleModify.ashx?ruleid=" + ruleid + "&billRight=" + billright + "", "", "scrollbars=1,resizable=1,width=700,height=400,top=250,left=350");
}
approval.showApproveUpdateRecord = function (ord, billtype)
{
    app.closeWindow("ApproveUpdateRecord");
    var url = window.SysConfig.VirPath + "SYSN/view/comm/ApprovalUpdateRecord.ashx?ord=" + ord + "&billtype=" + billtype;
    var win = app.createWindow("ApproveUpdateRecord", "审批流程变动记录", { closeButton: true, height: 400, width: 700 });
    win.innerHTML = "<iframe frameborder='0' scrolling=0  src='" + url + "' width=\"700\" height=\"400\"> ";
    win.style.overflow = "hidden";
}
approval.showHistoryApproveRecord = function (ord, billtype)
{
    app.closeWindow("ApproveHistoryRecord");
    var url = window.SysConfig.VirPath + "SYSN/view/comm/ApprovalHistoryRecord.ashx?ord=" + ord + "&billtype=" + billtype;
    var win = app.createWindow("ApproveHistoryRecord", "历史审批记录", { closeButton: true, height: 400, width: 700 });
    win.innerHTML = "<iframe frameborder='0' scrolling=0  src='" + url + "' width=\"700\" height=\"400\"> ";
    win.style.overflow = "hidden";
}
$(function () {
    if ($("#hidbillnotcontainreturnnode").length > 0 && $("#hidbillnotcontainreturnnode").val() != "")
    {
        $("td[dbname='lastnode'] select:eq(0) option").each(function () {
            if (("," + $("#hidbillnotcontainreturnnode").val() + ",").indexOf("," + $(this).val() + ",") > -1)
            {
                $(this).attr("disabled", "disabled");
            }
        })
    }
})


