window.OpenNewFP = function () {
	var v = window.event.srcElement.innerText;
	if (v == "新增") {
		window.showLinkZbintelDiv();
	} else {
		window.OpenUrlCC("add.ashx");
	}
}

window.OpenUrlCC = function (url) {
	app.OpenUrl(url, "syswin", { width: 760, height: 600, align: "center" });
}

//改写生成标题
Bill.CHeaderHtml = function () {
	document.body.style.backgroundColor = "#e9edf1";
	var html = [];
	html.push("<div id='topHeaderBar'>");
	html.push("<div id='poslabel'>您当前的位置: </div>");
	html.push("<div style='float:left;line-height:45px;padding:0px;padding-left:10px;font-family:微软雅黑;font-size:17px;color:#333;font-weight:bold'>子系统分配</div>");
	html.push("</div>");
	document.write(html.join(""));
}

window.CSubSystemTitleLink = function (obj) {
	return "<a  title='点击查看详情'  href='javascript:void(0)' onclick='window.OpenUrlCC(\"add.ashx?ord=" + app.pwurl(obj["companyId"]) + "&view=details\");return false'>" + obj.companyName + "</a>";
}

window.CVersionInfoCell = function (obj) {
	return "<div style='text-align:left;padding-left:10px;color:#333'>" + obj["version"] + "<br>"
		+ "<span style='color:#aaa;'>SN：" + obj["cdkey"] + "</span></div>";
}

window.JoinErrorVars = [];
window.CSubSystemSiteUrl = function (obj) {
	var bindtxts = obj["hostBind"].split("statuserror:");
	var defurl = obj["defaultUrl"];
	var hostbind = bindtxts[0].split(",");
	var defhost =  defurl.split("//")[1].split("/")[0].split(":")[0];
	for (var i = 0; i < hostbind.length; i++) {
		var item = hostbind[i].split(":");
		var port = item[1] == "80" ? "" : (":" + item[1]);
		var host = (item[2] == "" || item[2] == "*") ? defhost : item[2];
		var u = "http://" + host + port
		hostbind[i] = "<a title='点击访问子系统' href='" + u + "' target=_blank >" + u + "</a>";
		if (i == 0) {
			if (bindtxts.length == 1) {
				hostbind[i] = hostbind[i] + "<span class='joinstatusok'>联机正常</span>";
			} else {
				window.JoinErrorVars.push(bindtxts[1]);
				hostbind[i] = hostbind[i] + "<span class='joinstatusfail' onclick='showJoinErr(" + (window.JoinErrorVars.length - 1) + ")'>联机异常</span>";
			}
		}
	}
	if (hostbind.length == 1) { return hostbind.join(""); }
	return "<table align=center><tr><td style='text-align:left'>" + hostbind.join("</td></tr><tr><td style='text-align:left'>") + "</td></tr></table>";

}

window.showJoinErr = function (index) {
	app.createWindow("lllerrinfo", "联机错误信息",{closeButton:true}).innerHTML = "<div style='padding:15px'>" +  window.JoinErrorVars[index] + "</div>";
}

window.CAccNumberCell = function (obj) {
	return "<table align=center style='width:90px;border-collapse:collapse'>"
				+ "<tr><td style='text-align:right'>PC：</td>"
				+ "<td style='text-align:left'>" + GetCountN(obj["PCUserCount"]) + "</td></tr>"
				+ "<tr><td  style='text-align:right'>移动：</td>"
				+ "<td style='text-align:left'>" + GetCountN(obj["MobUserCount"]) + "</td>"
				+ "</tr></table>";
}


window.GetCountN = function (n) {
	n = n + "";
	if (n == "-1") { return "未开通"; }
	if (n == "0") { return "不限"; }
	return n;
}

window.CZhTNumberCell = function (obj) {
	return window.GetCountN(obj["FincCount"]);
}

window.CJMSNumberCell = function (obj) {
	var n1 = obj["ServerJMG"] + "";
	var n2 = obj["ClientJMGCount"] + "";
	if (n1 == "" || n1 == "0") { n1 = "未开通"; }
	if (n2 == "" || n2 == "0") { n2 = "未开通"; }
	return "<table align=center style='width:110px;border-collapse:collapse'>"
			+ "<tr><td style='text-align:right'>服务端：</td>"
			+ "<td style='text-align:left'>" + n1+ "</td></tr>"
			+ "<tr><td  style='text-align:right'>客户端：</td>"
			+ "<td style='text-align:left'>" + n2+ "</td>"
			+ "</tr></table>";
}

window.CPhoneNumberCell = function (obj) {
	var n = window.GetCountN(obj["phoneBoxCount"]);
	if (n == "不限") { return "已开通：不限"; }
	if (isNaN(n)) { return n; }
	return "已开通：" + n;
}

window.CHandleCell = function (obj) {
	return "<button class=zb-button onclick='window.OpenUrlCC(\"add.ashx?ord=" + app.pwurl(obj["companyId"]) + "&view=details\");return false'>详情</button>"
			+ "<button class=zb-button onclick='window.OpenUrlCC(\"add.ashx?ord=" + app.pwurl(obj["companyId"]) + "\");return false'>修改</button>"
}


window.showLinkZbintelDiv = function () {
	var div = $ID("linkmeMaskdivbg")
	var pos = app.GetObjectPos(window.event.srcElement);
	if (!div) {
		div = document.createElement("div");
		div.id = "linkmeMaskdivbg";
		document.body.appendChild(div);
		$(div).bind("mousedown", function () {
			$("#linkmeMaskdivbg").remove();
		});
		div.innerHTML = "<div id='linkMeContentDiv'  onmousedown='app.stopDomEvent();return false;' style='top:" + (pos.top + pos.height) + "px;left:" + (pos.left - 260 + pos.width) + "px'>"
		+ "<div><div style='float:right;width:1px;height:1px;margin-right:38px;"
		+ "border-bottom:8px solid rgba(0,0,0,0.65);"
		+ "border-left:8px solid transparent;"
		+ "border-right:8px solid transparent;"
		+ "'></div></div>"
		+ "<div style='clear:both;background-color:#333;background-color:rgba(0,0,0,0.65);height:132px;color:white;padding:20px;font-size:16px; font-family:微软雅黑'>"
		+ "新增子系统"
		+ "<div style='color:white;font-size:15px; font-family:微软雅黑;padding-top:12px;margin-top:10px;border-top:1px solid #9D9D9D;line-height:25px'>请联系您的专属客服<br>"
		+ "或直接拨打：" + ( window.SysConfig.BrandIndex ==3 ? "400-039-0088" : "400-650-8060") + "</div>"
		+"</div></div>"
	}
}