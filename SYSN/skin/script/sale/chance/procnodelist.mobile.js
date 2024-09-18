window.InitRunLog = function (logid) {
	ui.confirm("确定启动此工作？", function (e) {
		if (e.index == 1) {
			app.RegEvent("InitLog", {
				"logid": logid
			}, function () { });
		}
	}, "温馨提示",["取消","确定"]);
}

window.doRunLog = function (logid) {
	app.OpenUrl("ProcNode.ashx?ord=" + logid + "&jhtype=0");
}

window.doSpLog = function (logid) {
	app.OpenUrl("ProcNode.ashx?ord=" + logid + "&jhtype=1");
}