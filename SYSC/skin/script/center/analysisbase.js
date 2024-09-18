Bill.OnBeforeLoad = function () {
	Bill.BorderSpaceW = 20;
	if (Bill.Data.SystemErrorSign == true) { return; }
	CreateYearFilterBarHtml();
	CreateCompanyFilterBarHtml();
}


window.SetPreYear = function (yeardt) {
	var yBox = $ID("curryearVbox");
	var newYear = yBox.value * 1 + yeardt*1;
	var year1 = (new Date()).getFullYear();
	var year2 = year1 - 10;
	if (newYear > year1) { alert('提示信息： 最多只能查到' + year1 + "年"); return; }
	if (newYear > year1) { alert('提示信息： 最少只能查到' + year2 + "年"); return; }
	yBox.value = newYear;
	window.SetYear(newYear)
}

//年份过滤区域
function CreateYearFilterBarHtml() {
	var fd = Bill.GetField("baseyeardiv");
	if (!fd || fd.formathtml != "*") { return; }

	var curryear = window.AnalysisFilter.CurrYear;
	var optionshtml = "";
	var nowYear = (new Date()).getFullYear();
	for (var i = nowYear ; i >= (nowYear - 10); i--) {
		optionshtml += "<option  " + (i == curryear ? "selected" : "") + " value='" + i + "'>&nbsp;&nbsp;&nbsp;&nbsp;" + i + "年</option>";
	}
	var exthtml = "";
	var yearselecthtml = "	<table id='yearboxtb'><tr>\n" +
	"	<td><a href='javascript:void(0)' onclick='window.SetPreYear(-1)'>上一年</a>&nbsp;&nbsp;</td>\n" +
	"	<td><select onchange='window.SetYear(this.value)' id='curryearVbox'>" + optionshtml + "</select></td>\n" +
	"	<td>&nbsp;&nbsp;<a href='javascript:void(0)'  onclick='window.SetPreYear(1)'>下一年</a></td>\n" +
	"	</tr></table>";

	switch (document.documentElement.id) {
		case "zbservices_centers_view_home_analysis_profitanalysis":
			exthtml = "<span id='SaleDataTypebg'><input onclick='SetSaleVType(0)' type=radio checked name='SaleDataType' id='SaleDataType1'><label for='SaleDataType1'>按合同金额</label>"
			+ "<input onclick='SetSaleVType(1)'  type=radio name='SaleDataType' id='SaleDataType2'><label for='SaleDataType2'>按回款金额</label></span>&nbsp;&nbsp;"
			break;
		case "zbservices_centers_view_home_analysis_payinandpayoutanalysis":
			yearselecthtml ="<div>@CurrDateTime1</div>"
			break;
	}

	fd.formathtml = "<table id='yearboxtbbg'><tr>\n" +
	"<td id='yearboxcell0' align=left valign=bottom ><div>➨&nbsp;&nbsp;&nbsp;&nbsp;" + Bill.Data.ui.title + "</div></td>\n" +
	"<td  id='yearboxcell1'  align=left  valign=bottom  >" + yearselecthtml +
	"</td>\n" + 
	"<td  id='yearboxcell2'  align=right valign=bottom  >" + exthtml +
	"单位：万元 &nbsp; </td>\n" +
	"</tr></table>\n"
}


//显示公司过滤区域
function CreateCompanyFilterBarHtml() {
	var fd = Bill.GetField("basecompanydiv");
	if (!fd || fd.formathtml != "*") { return; }
	var ops = window.AnalysisFilter.EnableCompanys;
	var currid = window.AnalysisFilter.CurrCompanyId;
	var opthtmls = "";
	for (var i = 0; i < ops.length; i++) {
		opthtmls = opthtmls + "<input  " + (currid == ops[i].CompanyId ? "checked" : "") + " onclick='SetCompany(this.value)'  type=radio  name='CurrCompanyID'    id='CurrCompanyID" + ops[i].CompanyId + "'  value='" + ops[i].CompanyId + "'>"
		opthtmls = opthtmls + "<label for='CurrCompanyID" + ops[i].CompanyId + "'>" + ops[i].CompanyName + "</label>"
	}
	fd.formathtml = "<table id='companyboxbg'><tr>"
		+ "<td id='split1' valign=middle align=center>"
		+ "<td id='companyboxbgcell0' valign=middle align=center>"
		+ "<input  " + (currid == 0 ? "checked" : "") + "  type=radio name='CurrCompanyID'  onclick='SetCompany(this.value)'   id='CurrCompanyID0' value=0> <label for='CurrCompanyID0'>全集团</label>"
	    + "</td>"
		+ "<td id='split2'>&nbsp;</td>"
		+ "<td id='companyboxbgcell1'  valign=middle>" + opthtmls + "</td>"
		+ "</tr></table>";
}

window.SetCompany = function (companyId) {
	$ID("CompanyId_0").value = companyId;
	setTimeout(function(){
		app.FireEvent($ID("CompanyId_0"), "blur");
	},100);
}

window.SetYear = function (yearvalue) {
	$ID("CurrYear_0").value = yearvalue;
	setTimeout(function () {
		app.FireEvent($ID("CompanyId_0"), "blur");
	}, 100);
}

window.SetSaleVType = function (saletype) {
	$ID("SaleMoneyValueType_0").value = saletype;
	setTimeout(function () {
		app.FireEvent($ID("CompanyId_0"), "blur");
	}, 100);
}

$(window).bind("resize", function () {
	return;
	var w = document.documentElement.offsetWidth;
	var zoom = (w > 1600 ? (w / 1600) : 1).toFixed(4) * 1;
	if (document.body && document.body.style.zoom != zoom) {
		document.body.style.zoom = zoom;
	}
});


window.ShowTypeInfo = function (id, type) {
	app.ajax.setUrl("showlabelinfo.ashx");
	app.ajax.addParam("showtype", type);
	app.ajax.addParam("id", id);
	app.ajax.addParam("companyid", $ID("CompanyId_0").value);
	var html = app.ajax.send();
	if (html.indexOf("<table") == -1) { return; }
	var eobj = window.event.srcElement;
	var div = app.createFloatDiv("usermsginfo", { width: 360, height: "auto", bindobj:  eobj});
	div.innerHTML = html.replace("@value",  eobj.getAttribute("infotitle") + ":" +  eobj.parentElement.innerHTML.split("</a>:")[1] );
}

window.ShowUserLabel = function (id) {
	window.ShowTypeInfo(id, 1);
}

window.ShowCompanyLabel = function (id) {
	window.ShowTypeInfo(id, 2);
}

window.ShowProductLabel = function (id) {
	window.ShowTypeInfo(id, 3);
}

window.OnAnysValueDisplayScritpSub = function (nodeobj) {
	if (nodeobj.chart.type != "pie") {
		if (nodeobj.text * 1 == 0) { nodeobj.text = ""; return; }
	}
	if (nodeobj.chart.type == "bar_line_pk" && nodeobj.groupindex == 1) {
		nodeobj.text = app.NumberFormat((nodeobj.text * 1).toFixed(2)) + "%";
	} else {
		nodeobj.text = app.NumberFormat((nodeobj.text * 1).toFixed(2));
	}
	switch (nodeobj.chart.fieldobject.title) {
		case "毛利分析（人员）_002":
		case "毛利分析（品类）_002":
		case "毛利分析（单品）_002":
			nodeobj.text = "<b style='font-size:12px;color:red;word-break:keep-all'>" + nodeobj.text + "%</b>";
			break;
		case "现金银行金额_002":
		case "应收分析子公司占比":
		case "应付分析子公司占比":
		case "应收分析客户占比":
		case "应付分析客户占比":
		case "费用占比_002":
		case "费用占比_003":
		case "费用占比_004":
		case "费用占比_005":
		case "费用占比_006":
		case "工资占比_001":
		case "工资占比_002":
			var bl = getbfb(nodeobj);
			nodeobj.text = "<b style='color:#333388;font-size:12px;word-break:keep-all' >" + nodeobj.text + "</b> <b style='font-size:12px;color:red;word-break:keep-all'>" + app.NumberFormat(bl) + "%</b>";
			break;
		default:
			if (nodeobj.chart.type == "pie") {
				nodeobj.text = "<b style='color:#333388;font-size:12px;word-break:keep-all' >" + nodeobj.text + "</b>";
			}
			// nodeobj.text = nodeobj.text  + "|" + nodeobj.chart.fieldobject.title
			break;
	}
}

function getbfb(obj) {
	var sumv = 0;
	for (var i = 0; i < obj.chart.Datas.length; i++) {
		sumv = sumv + obj.chart.Datas[i].value * 1;
	}
	if (sumv == 0) { return "0.00"; }
	return (obj.node.value * 100 / sumv).toFixed(2);
}

window.OnBillchartGraphLoad = function () {
	window.ChartImages.YCount = 7;
}

window.OnChartCYLabelHtml = function (obj, txt, unit) {
	if (!unit) {
		if (isNaN(txt) == false) {
			return app.NumberFormat((txt*1).toFixed(2))
		}
	}
	return txt;
}