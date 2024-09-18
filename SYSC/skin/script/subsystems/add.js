window.DoCreateWebSite = function (companyID) {
	var div = app.createWindow("createsitewin", "创建与维护", { bgShadow: 30, borderwidth: 5, width: 640, height: 400 });
	div.innerHTML = "<iframe style='width:100%;height:99%' frameborder=0 src='" + window.SysConfig.VirPath + "SYSC/view/subsystems/add.ashx?__msgid=ExecCreateSite&company=" + companyID + "'></iframe>"
}