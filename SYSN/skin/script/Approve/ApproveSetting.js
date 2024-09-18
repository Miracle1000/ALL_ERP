if (!window.approve) { window.approve = new Object(); }
approve.deleteApproveNodeAndHisChildren = function (nodeid) {
    //if (confirm("确定删除吗？如果删除会影响关联单据的审批流程。")) {
		app.closeWindow("DeleteApproveRuleNode");
		var win = app.createWindow("DeleteApproveRuleNode", "删除审批流程" , {
			width: 800,
			height: 480,
			closeButton: true,
			maxButton: true,
			minButton: true,
			canMove: true,
			sizeable: true
		}); 
		// result为json 格式是bill单据 包含主题和2个字段
		win.innerHTML = "<div id='SysBillApproveDlgDiv' style='height:99%'>"
			+"<iframe name='__sys_approve' id='__sys_approve' src='?__sys_msgid=sdk_sys_ApproveDeleteCallBack&nodeid="+nodeid+"'  recsize='-1' style='height:100%;width:100%' frameborder=0></iframe>"
			+"</div>";
	//}
}
//添加页面
approve.dialogForAddApprovalCode = function(ApproveSort,SortType){
	window.open("?__sys_msgid=sdk_sys_ApproveRulePage&ApproveSort=" + ApproveSort + "&SortType=" + SortType + "", "", "scrollbars=1,resizable=1,width=700,height=400,top=250,left=350");
}
//修改页面
approve.ModifyApproveCode = function(RuleID){
	window.open("?__sys_msgid=sdk_sys_ApproveRulePage&ord=" + RuleID + "", "", "scrollbars=1,resizable=1,width=700,height=400,top=250,left=350");
}
//删除规则
approve.DeleteRules = function (RuleID, dbname, sign) {
    //var msg = sign == 1 ? "有正在执行的单据，确定删除吗？" : "确定删除吗？";
    //if (confirm(msg)) {
        app.ajax.regEvent("SysBillCallBack");
        app.ajax.addParam("__uilayout", Bill.getFiledsLayout());
        app.ajax.addParam("__maxspan", $ID("editbody").getAttribute("maxspan"));
        app.ajax.addParam("actionname", dbname);
        app.ajax.addParam("ruleid", RuleID);
        Bill.getBillData(function (key, value) {
            app.ajax.addParam("b_f_sv_" + key, value);
        });
        app.ajax.send(function (r) { });
    //}
}
//添加阶段
approve.AddRuleNodeRelation = function(RuleID){
	window.open("?__sys_msgid=sdk_sys_ApproveRuleNodePage&ruleid=" + RuleID + "", "", "scrollbars=1,resizable=1,width=700,height=400,top=250,left=350");
}
//修改阶段
approve.ModifyRuleNodeRelation = function(NodeID){
	window.open("?__sys_msgid=sdk_sys_ApproveRuleNodePage&ord=" + NodeID + "", "", "scrollbars=1,resizable=1,width=700,height=400,top=250,left=350");
}


window.DoRefreshListByID = function (ListID) {
    // ___RefreshListviewByServer(window["lvw_JsonData_rule_" + ListID]);
    //window.DoRefresh();
    window.location.reload();
}