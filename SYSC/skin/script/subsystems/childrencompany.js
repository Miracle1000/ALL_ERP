window.createPage = function () {
	var csstext = "<style>"
		+ "#topHeaderBar {margin:10px;height:45px;\nbackground-color:white;}\n"
		+ "#poslabel {float:left;line-height:45px;padding:0px;padding-left:60px;font-family:微软雅黑,黑体;font-size:16px;color:#333;background:white url(../../skin/default/images/p12.png) no-repeat;background-position:  18px  center;}\n"
		+ "</style>";
	document.write(csstext);
	window.CHeaderHtml();
	window.CBodyHtml();
	window.LoadCurrCompanyPage();
}

window.CHeaderHtml = function () {
	var obj = window.PageInitParams[0];
	document.body.style.backgroundColor = "#e9edf1";
	var html = [];
	html.push("<div id='topHeaderBar'>");
	html.push("<div id='poslabel'>选择子公司: </div>");
	html.push("<div style='float:left;padding:0px;padding-left:10px;overflow:hidden;padding-top:7px'>");
	html.push("<select id='companyIdBox' onchange='window.LoadCurrCompanyPage()' style='font:14px 微软雅黑,黑体;line-height:30px;height:30px;background-color:#F0F0F0;min-width:180px;border:1px solid #cccccc'>");
	if (obj.length == 0) {
		html.push("<option value='0' style='font:bold 16px 微软雅黑,黑体;line-height:30px;height:30px;'>==没有子公司==</option>")
	} else {
		for (var i = 0; i < obj.length; i++) {
			html.push("<option value ='" + obj[i].CompanyID + "' style='font:14px 微软雅黑,黑体;line-height:30px;height:30px;'>&nbsp;&nbsp;" + obj[i].CompanyName + "</option>")
		}
	}
	html.push("</select>");
	html.push("</div>");
	html.push("</div>");
	document.write(html.join(""));
}

window.CBodyHtml = function () {
	var html = [];
	html.push("<div id='topBody'  style='position:absolute;top:65px;left:10px;right:10px;bottom:10px;background-color:white;'>");
	html.push("</div>")
	document.write(html.join(""));
}

window.LoadCurrCompanyPage = function () {
	var v = $ID("companyIdBox").value;
	if (v == "0") {
		$ID("topBody").innerHTML = "<center style='font-size:16px;font-family:微软雅黑;color:red;'><br><br><br><br><br>温馨提示：当前没有分配子系统，无法查看对应的公司信息。</center>";
	} else {
		$ID("topBody").innerHTML = "<iframe src='?__msgid=GoToChildrenCompany&ID=" + v + "' style='width:100%;height:100%;' frameborder=0></iframe>";
	}
}