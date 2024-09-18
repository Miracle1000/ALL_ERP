
window.TopLinks = [
		{ url: "SalesPerformanceAnalysis", title: "销售业绩分析" },
		{ url: "ProfitAnalysis", title: "利润分析" },
		{ url: "CashFlowAnalysis", title: "现金流分析" },
		{ url: "PayInAndPayOutAnalysis", title: "应收应付分析" },
		{ url: "CostAnalysis", title: "费用分析" },
		{ url: "SubsidiaryPKAnalysis", title: "子公司对比" }
];
window.CurrHomeIndex = 0;

window.createPage = function () {
	var htmls = [];
	htmls.push("<div id='headerbar'>");
	for (var i = 0; i < window.TopLinks.length; i++) {
		htmls.push("<div class='topMenuItem" + (window.CurrHomeIndex==i?" s" : "") + "' id='topmmm" + i + "' ");
		htmls.push("onclick='gotourl(this," +i + ")' ");
		htmls.push("onmouseover='app.CssSwapTo1(this)' ");
		htmls.push("onmouseout='app.CssSwapTo0(this)' ");
		htmls.push(">" + window.TopLinks[i].title + "</div>");
	}
	htmls.push("</div>");
	htmls.push("<div style='height:10px'>&nbsp;</div>");
	htmls.push("<iframe style='background-color:#fff' src='../home/analysis/SalesPerformanceAnalysis.ashx' frameborder=0  id='bodyframe'/></iframe>")
	document.write(htmls.join(""));
	setTimeout(window.onbodyResize, 10);
}

app.CssSwapTo1 = function (box) {
	if (box.id.replace("topmmm", "") * 1 == window.CurrHomeIndex) { return; }
	box.className = box.className.replace(" s","") + " s";
}
app.CssSwapTo0 = function (box) {
	if (box.id.replace("topmmm", "") * 1 == window.CurrHomeIndex) { return; }
	box.className = box.className.replace(" s","");
}

window.gotourl = function (currbox, urlindex) {
	var box = $ID("topmmm" + window.CurrHomeIndex);
	box.className = box.className.replace(" s", "");
	currbox.className = box.className.replace(" s", "") + " s";
	window.CurrHomeIndex = urlindex;
	$ID("bodyframe").contentWindow.location.href = "../home/analysis/" + window.TopLinks[urlindex].url + ".ashx";
}

window.onbodyResize = function () {
	var frmbox = $ID("bodyframe");
	var headbox = $ID("headerbar");
	if (frmbox) {
		frmbox.style.height = ($(window).height() - headbox.offsetHeight - 10*3) + "px"
	}
}

$(window).resize(window.onbodyResize);