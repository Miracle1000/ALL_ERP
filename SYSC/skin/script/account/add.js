window.CBindSettingHtml = function (row) {
	var subuserid = row["subUserId"] || 0;
	var rowindex = row["@indexcol"];
	var companyId =  row["companyId"];
	return subuserid == 0
			? ("<span style='color:#aaa'>未绑定---></span> <a href='javascript:void(0)' onclick='window.ShowUserBindDlg(" + companyId + "," + rowindex + ")'>绑定</a>")
			: (row["subUserName"] + "---> <a href='javascript:void(0)' onclick='window.ShowUserBindDlg(" + companyId + "," + rowindex + ")'>绑定</a>&nbsp;"
				+ "<a href='javascript:void(0)' onclick='window.CancelUserBind(" + companyId + "," + rowindex + ")' href='javascript:void(0)'>取消绑定</a>");
}

window.ShowUserBindDlg = function (companyId, rowindex) {
	app.OpenUrl("ChildrenTree.ashx?companyId=" + companyId + "&returntag=" + companyId, "aaaaaxx", { width: 600, height: 600, align: "center" });
};

window.OnSubSystemGatesSelected = function (e, tag) {
	app.ajax.regEvent("doSubSystemsUserBind");
	app.ajax.addParam("comid", tag);
	app.ajax.addParam("curruid", Bill.Data.ord);
	app.ajax.addParam("userid", e.node.value);
	app.ajax.addParam("username", e.node.text);
	app.ajax.send();
}

window.CancelUserBind = function (companyId) {
	if (window.confirm("您确定要取消绑定吗？") == false) { return;}
	app.ajax.regEvent("doCancelSystemsUserBind");
	app.ajax.addParam("comid", companyId);
	app.ajax.addParam("curruid", Bill.Data.ord);
	app.ajax.send();
}