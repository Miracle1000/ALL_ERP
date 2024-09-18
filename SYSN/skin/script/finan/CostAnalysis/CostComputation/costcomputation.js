window.CostAnalysis = new Object();
CostAnalysis.TimerWatchHwnd = 0;
CostAnalysis.XmlHttp = new XMLHttpRequest();

//显示大对话框
CostAnalysis.ShowMainAnalysisDlg = function (date1) {
    $ID("CostMinAnalysisDlg")?$ID("CostMinAnalysisDlg").style.display="none":"";
	var div = $ID("CostMainAnalysisDlg"); 
	if (!div) {
		var div = document.createElement("div");
		div.id = "CostMainAnalysisDlg";
		div.onmousedown = function () {
		    CostCheckLayerDrag(event, this, this.id);
		}
		document.body.appendChild(div);
	}
	div.style.display = "block";
	div.className = (app.IeVer < 9 ? "CostMainAnalysisDlgOldIe" : "");
	var html =  "<div style='height:100%;width:180px;float:left;background-color:#F0F0F0'>" + CostAnalysis.CLeftMenuHtml() + "</div>"
					+ "<div style='height:100%;width:620px;float:left;'>"
					+ "<div class='TopTitleCss leftNavBg' id='CostAnalysisMainTitle'>开始成本核算</div>"
					+ "<div id='CostAnalysisMainBody' onmousedown='banPop()'>&nbsp;</div>"
					+  "</div>"
					+ "<div id='CostMainAnalysisDlg_topbtn'>";
	if(	window.SysConfig.IsDebugModel){
		html  = html + "<a href='javascript:void(0)' class='cmin' style='color:yellow;font-size:12px' onclick='CostAnalysis.ShowDebugObjectTree()'>查看对象</a>&nbsp;"
					+ "<a href='javascript:void(0)' class='cmin' style='color:yellow;font-size:12px'  onclick='CostAnalysis.Cmd(\"DoReset\");alert(\"重置成功\")'>过程重置</a>&nbsp;";
	
	}
	html  +="<a href='javascript:void(0)' class='cmin' onclick='CostAnalysis.ShowMinAnalysisDiv()'>—</a>&nbsp;"
			+ "<a href='javascript:void(0)' class='cclose' onclick='CostAnalysis.HiddenUIWin()'>×</a></div>"
	div.innerHTML = html;
	CostAnalysis.CurrMonth = date1;
	CostAnalysis.TimerWatchRequest(true);
}

CostAnalysis.GotoErrorUrl = function (box) {
	var url = box.getAttribute("_url");
	app.OpenUrl(window.SysConfig.VirPath + url);
}

//显示小对话框
CostAnalysis.ShowMinAnalysisDiv = function () {
    $ID("CostMainAnalysisDlg")?$ID("CostMainAnalysisDlg").style.display = "none":"";
	var div = $ID("CostMinAnalysisDlg");
	if (!div) {
		var div = document.createElement("div");
		div.id = "CostMinAnalysisDlg";
		div.onmousedown = function () {
		    CostCheckLayerDrag(event, this, this.id)
		}
		document.body.appendChild(div);
	}
	div.style.display = "block";
	div.className = (app.IeVer < 9 ? "CostMinAnalysisDlgOldIe" : "");
	div.innerHTML = "<table style='border-collapse:collapse;width:100%;height:100%'><tr>"
							+ "<td style='width:52%' id='CostAnalysisMinTitle'>成本核算中....</td>"
                            + "<td style='width:28%' id='CostAnalysisMinProgressRate'><div id='CostAnalysisMinProgressDiv' style='color:#fff'>0/100</div></td>"
							+ "<td style='width:20%' id='CostminAnalysisDlgtopbtn'><div id='CostMinWindowHandle'><a href='javascript:void(0)' class='cmin' onclick='CostAnalysis.ShowMainAnalysisDlg()'></a>&nbsp;"
							+ "<a href='javascript:void(0)' class='cclose' onclick='CostAnalysis.HiddenUIWin()'></a></div></td></tr>"
							+ "<tr><td colspan=3 style='background-color:white' id='CostAnalysisMinBody'><div id='CostMinAnalysisProgress'><div class='ProgressActiveBar' id='ProgressActiveBar' style=''></div></div></td></tr>"
							+ "</table>"
	CostAnalysis.TimerWatchRequest();
}

CostAnalysis.HiddenUIWin = function () {
	$("#CostMainAnalysisDlg").remove();
	$("#CostMinAnalysisDlg").remove();
}

//CostAnalysis.StepInfos = CostAnalysis.StepInfos&& CostAnalysis.StepInfos.length>0 ? CostAnalysis.StepInfos : ["开始成本核算", "核算数据获取", "核算数据检测", "BOM结构检查", "正式成本核算", "完成成本核算"];
CostAnalysis.CLeftMenuHtml = function () {
	var html = [];
	html.push("<div class='TopTitleCss topNavBg' >核算步骤</div>");
	html.push("<div onmousedown='banPop()' style='height:10px'>&nbsp;</div>");
	html.push("<div onmousedown='banPop()'>");
	for (var i = 0; i < CostAnalysis.StepInfos.length; i++) {
		var ihtml = "<div class='LeftMenuItemCss'  id='costanysteparea" + i + "'>"
						+ "<div class='LeftMenuSign'>▍</div>"
						+ "<div class='LeftMenuText'>" + (i + 1).toString() + ". " + CostAnalysis.StepInfos[i] + "</div>"
						+ "<div class='LeftMenuRSign'>▸</div>"
                        + "<div class='LeftMenuPSign costiconfont icon-duihao'></div>"
						+ "</div>";
		html.push(ihtml);
	}
	html.push("</div>");
	return html.join("");
}

CostAnalysis.OnXmlHttpReadyStateChange = function () {
	var xhttp = CostAnalysis.XmlHttp;
	if (xhttp.readyState == 4) {
		CostAnalysis.OnRequestIng = 0;
		if (xhttp.status == 200) {
			var json = eval("(" + xhttp.responseText + ")");
			CostAnalysis.RefreshRuntimeUI(json);
		} else {
			CostAnalysis.HiddenUIWin();
			var errdiv = app.createWindow("a", "xxx", "");
			errdiv.innerHTML = xhttp.responseText;
		}
	}
}

CostAnalysis.OnRequestIng = 0;
CostAnalysis.TimerWatchRequest = function (isshow) {
	if (CostAnalysis.OnRequestIng == 1) { return; }
	var xhttp = CostAnalysis.XmlHttp;
	xhttp.onreadystatechange = CostAnalysis.OnXmlHttpReadyStateChange;
	var url = window.SysConfig.VirPath + "SYSN/view/finan/CostAnalysis/CostComputation/CostAnalysisStatus.ashx?firstshow=" + (isshow?"1":"0") + "&month=" + encodeURI(CostAnalysis.CurrMonth) + "&t=" + (new Date()).getTime();
	xhttp.open("GET", url, true);
	CostAnalysis.OnRequestIng = 1;
	xhttp.send();
}


CostAnalysis.ShowDebugObjectTree = function () {
	var url = window.SysConfig.VirPath + "SYSN/view/finan/CostAnalysis/CostComputation/CostAnalysisStatus.ashx?month=" + encodeURI(CostAnalysis.CurrMonth) + "&ShowObjectTree=1&t=" + (new Date()).getTime();
	app.OpenUrl(url);
}

CostAnalysis.RefreshRuntimeUI = function (jsonobj) {
	jsonobj.StepIndex = (jsonobj.StepIndex || "_0_").split("_")[1] * 1-10;
	///var stepindex = jsonobj.StepIndex;
	var bigdiv1 = $ID("CostAnalysisMainBody");
	if (bigdiv1) { CostAnalysis.RefreshRuntimeBigDivUI(bigdiv1, jsonobj); }
	var bigdiv2 = $ID("CostAnalysisMinBody");
	if (bigdiv2) { CostAnalysis.RefreshRuntimeMinDivUI(bigdiv2, jsonobj); }
	if (!bigdiv1 && !bigdiv2) { return;}
	if (jsonobj.ContinueWatch == true) {
		window.clearTimeout(CostAnalysis.TimerWatchHwnd);
		CostAnalysis.TimerWatchHwnd = window.setTimeout(CostAnalysis.TimerWatchRequest, 600);
	}
}


CostAnalysis.SetActiveMenu = function (jsonobj) {
	var jsonstepindex = parseInt(jsonobj.StepIndex / 10);
	for (var i = 0; i < CostAnalysis.StepInfos.length; i++) {
		var menuobj = $ID("costanysteparea" + i);
		if (jsonstepindex == i) {
			if (menuobj.className.indexOf("CurrActiveMenu") == -1) {
				menuobj.className = "LeftMenuItemCss CurrActiveMenu baseFontColorAll";
			}
		} else {
		    if (i < jsonstepindex) {
				menuobj.className = "LeftMenuItemCss Accomplish baseFontColorAll";
		    } else {
		        menuobj.className = "LeftMenuItemCss";
		    }
		}
	}
}

//执行命令
CostAnalysis.Cmd = function (cmd, date1) {
	var url = window.SysConfig.VirPath + "SYSN/view/finan/CostAnalysis/CostComputation/CostAnalysisStatus.ashx?month=" + encodeURI(CostAnalysis.CurrMonth) + "&t=" + (new Date()).getTime();
	app.ajax.setUrl(url);
	app.ajax.regEvent(cmd);
	app.ajax.send(function (r) {
	    if (!r) { r = "{}";}
	    var json;
	    try { json = eval("(" + r + ")") } catch (e) { json = {};json.error = r };
		if (json.error) { alert(json.error); return; }
		if (cmd && (cmd.toLowerCase() == "docomplete" || cmd.toLowerCase()=="doreset"))
		{
		    CostAnalysis.CompleteRefreshListViewUI()
		} else if (cmd && cmd.toLowerCase() == "initleftnav") {
		    if (r == "{}") { json = [] };
		    json = json && json.length > 0 ? json : ["开始成本核算", "核算数据获取", "核算数据检测", "BOM结构检查", "正式成本核算", "完成成本核算"];
		    top.CostAnalysis.StepInfos = json;
		    top.CostAnalysis.ShowMainAnalysisDlg(date1);
		}
		else
		{
			CostAnalysis.RefreshRuntimeUI(json);
		}
	});
}

//初始化界面
CostAnalysis.CreateBigDivInitHtml = function (div, runtime) {
    if (runtime.StepIndex < 0 && CostAnalysis.InitCache) { return CostAnalysis.InitCache }
	var stepinfo = runtime.StepInfo;
	var datev = runtime.AnalysisMonth.split("-");
	var html="<div style='max-height:400px;'><table id='MainAnalysisinittb' align='center'>"
			+ "<col style='width:170px'><col style='width:370px'>"
			+ "<tr><td>核算月份</td><td>" + datev[0] + "-" + datev[1] + "</td></tr>"
			
	      if (stepinfo.ExsitsSCModel)
	      {
	          html += "<tr><td>核算方法</td><td>" + runtime.AnalysisMethod.replace("c_", "") + "</td></tr>"
	      }
			
	      html+= "<tr><td>核算人员</td><td>" + stepinfo.AnalysisUserName + "</td></tr>"
            +"<tr><td>核算时间</td><td>" + stepinfo.AnalysisBeginTime + "</td></tr>"
			+ "<tr><td colspan=2 style='color:#aaa'>温馨提示:成本核算过程比较耗时，建议在系统使用人数较少时操作</td></tr>"
			+ "</table></div>"
			+ "<div class='CAnalysisStartDiv' style='height:30px;'>"
			+ "<button  id='CAnalysisStartButton' class='leftNavBg' onclick='CostAnalysis.Cmd(\"DoStart\")'>开始核算</button>"
			+ "</div>";
	CostAnalysis.InitCache = html;
	return html;
}

//数据锁定过程
CostAnalysis.CreateBigLoadDataDivHtml = function (div,  runtime) {
	var stepinfo = runtime.StepInfo;
	var datev = runtime.AnalysisMonth.split("-");
	var dataArr = ["核算月份", "获取核算数据", "封存核算数据", "封存进度"];
	$ID("CostAnalysisMainTitle").innerHTML = "核算数据获取";
	var iscomplete = stepinfo.ExecStatus == "complete" ? true : false;
	var percentNum = stepinfo.SpeedCount > 0 ? Math.round(stepinfo.SpeedIndex * 1 / stepinfo.SpeedCount) * 100 : 0;
	percentNum = percentNum >= 100 ? (iscomplete ? 100 : 75) : percentNum;
	return "<div style='max-height:400px;'><table id='MainAnalysisinittb' align='center'>"
			+ "<col style='width:170px'><col style='width:370px'>"
			+ "<tr><td>核算月份</td><td>" + datev[0] + "-" + datev[1] + "</td></tr>"
			+ "<tr><td>获取核算数据</td><td>" + stepinfo.AllDataClsCount + "类</td></tr>"
			+ "<tr><td>封存核算数据</td><td>" + stepinfo.CurrDataClsCount + "类</td></tr>"
			+ "<tr><td>封存进度</td><td>" + (stepinfo.ExecStatus=="complete" ? "封存完毕" : "封存中") + "</td></tr>"
			+ "<tr><td colspan=2 style='color:#aaa'>温馨提示: 成本核算时，在核算月份内封存的单据类型将禁止增加/修改/删除等操作</td></tr>"
			+ "</table></div>"
			+ "<div  class='CAnalysisStartDiv'>"
            + "<div class='CAnalysisProgress'>"
            + "<div class='CAnalysisProgressInnerBar' style='width:" + percentNum + "%' id='CurrProgressBar1'></div>"
            + "<div class='CAnalysisProgresstxt'  id='CurrProgressText1'>" + (percentNum >= 100 ? "检测完成" : "正在" + (dataArr[stepinfo.SpeedIndex - 1] ? (dataArr[stepinfo.SpeedIndex - 1] + "...") : "核算月份...")) + "</div>"
            + "</div>"
            + "<button  id='CAnalysisCancleButton' class='leftNavBg' onclick='CostAnalysis.DoDoReset()'>取消核算</button>&nbsp;&nbsp;&nbsp;&nbsp;"
			+ "<button  id='CAnalysisStartButton' " + (iscomplete ? "class='leftNavBg'":"disabled class='bomCheckNoShow'"  ) + " onclick='CostAnalysis.Cmd(\"DoStart\")'>继续核算</button>"
			+ "</div>";
}

//数据检测、BOM检测 过程执行
CostAnalysis.CreateBigDataCheckDivHtml = function (div,  runtime) {
	var html = [];
	var existerror = false,isbomcheck=false;
	html.push("<div style='max-height:400px;'><table id='MainAnalysisinittb' align='center'>");
	html.push("<col style='width:220px'><col style='width:120px'><col style='width:200px'>");
	html.push("<tr><td>核算月内检测项</td><td>检测结果</td><td>待处理单据数</td></tr>");
	if (parseInt(runtime.StepIndex / 10) == 3) { isbomcheck = true }
	if (isbomcheck) { $ID("CostAnalysisMainTitle").innerHTML = "BOM结构检测" } else { $ID("CostAnalysisMainTitle").innerHTML = "核算数据检测" }
	var stepinfo = runtime.StepInfo;
	var iscomplete = stepinfo.ExecStatus == "complete" ? true : false;
	for (var i = 0; i < stepinfo.CheckResults.length; i++) {
		var resultinfo = stepinfo.CheckResults[i];
		html.push("<tr class='h25'>");
		html.push("<td style='text-align:left;padding-left:5px'>" + resultinfo.Name + "</td>");
		html.push("<td>");
		switch (resultinfo.Result) {
		    case "未通过": html.push("<span class='testResult fault'><span class='costiconfont icon-right-copy' style='color:red'></span>" + resultinfo.Result + "</span>"); existerror = true; break;
		    case "通过": html.push("<span class='testResult pass'><span class='costiconfont icon-duihao' style='color:#000000;'></span>" + resultinfo.Result + "</span>"); break;
		    case "警告": html.push("<span class='testResult warn'><span class='costiconfont icon-jinggao' style='color:#FF9400;'></span>" + resultinfo.Result + "</span>"); break;
		}
		html.push("</td><td><div class='waittingHandle'><span class='num'>" + resultinfo.ErrCount+"</span>");
		if (resultinfo.ErrCount > 0 && resultinfo.Url.length > 0) {
		    var url = resultinfo.Url;
		    if (url.indexOf("/") == 0) { url = url.replace("/", "") }
			var linkHtm = "<a class='goHandleBill' href='javascript:void(0);' onclick='handleLongParam(\"" + url + "\")'" +
				"style='color:#0052c2;'>" + ((isbomcheck || resultinfo.Result == "警告" || url.indexOf("logfiles")>0) ? "去查看" : "去处理") +
            "<span class='handleIcon costiconfont icon-jinru'></span></a>"
            html.push(linkHtm);
		}
		html.push("</div></td></tr>");
	}
	if (isbomcheck) {
	    var bomstr="<tr>"
                +"<td colspan=3 style='color:#aaa;text-align:left;padding:8px;'>温馨提示:父子件嵌套（如:A=B+C,B=A+C）时,全月平均法成本计算的先后顺序不明确。<br>已检测出存在"
                +"<span class='baseFontColor'>【" + stepinfo.WeightedAverageNum + "】</span>个产品的计价方式为全月平均法" + (stepinfo.WeightedAverageNum > 0 ? "，请更换后再继续核算。"
                +"<span class='baseFontColor'><input type='checkbox'onclick='checkBtnShowHandle(this)' id='bomCheckTrunMethod'>转为先进先出法</span>" : "。") 
                + "</td>"
                +"</tr>";
	    html.push(bomstr); 
	}
	html.push("</table></div>");
	var progressTxti = stepinfo.CheckResults[stepinfo.SpeedIndex-1] && stepinfo.CheckResults[stepinfo.SpeedIndex-1]["Name"] ? (stepinfo.CheckResults[stepinfo.SpeedIndex-1]["Name"]+"...") : "...";
	var progressTxt0 = stepinfo.CheckResults[0] && stepinfo.CheckResults[0]["Name"] ? (stepinfo.CheckResults[0]["Name"] + "...") : "..."
	var percentNum = stepinfo.SpeedCount > 0 ? Math.round(stepinfo.SpeedIndex * 1 / stepinfo.SpeedCount * 100) : 0;
	percentNum = percentNum >= 100 ? (iscomplete ? 100 : 75) : percentNum;
	var str = "<div class='CAnalysisStartDiv'>";
	str += "<div class='CAnalysisProgress'>"
    + "<div class='CAnalysisProgressInnerBar' style='width:" + percentNum + "%' id='CurrProgressBar1'></div>"
    + "<div class='CAnalysisProgresstxt' id='CurrProgressText1'>" + (percentNum >= 100 ? "检测完成" : "正在检测" + (isbomcheck ? progressTxt0 : progressTxti)) + "</div></div>"
	html.push(str);
	html.push("<button  id='CAnalysisCancleButton' class='leftNavBg'  onclick='CostAnalysis.DoDoReset()'>取消核算</button>&nbsp;&nbsp;&nbsp;&nbsp;")
	var disabled = isbomcheck && stepinfo.WeightedAverageNum > 0 || !iscomplete;
	if (existerror && !isbomcheck) {
		html.push("<button  id='CAnalysisStartButton' class='leftNavBg' onclick='CostAnalysis.Cmd(\"ReStart\")'>重新检测</button>")
	} else {
		html.push("<button " + (disabled ? "disabled" : "") + " id='CAnalysisStartButton' class='" + (disabled ? "bomCheckNoShow" : "leftNavBg") + "' onclick='CostAnalysis.Cmd(\"DoStart\")'>继续核算</button>")
	}
	if (window.SysConfig.IsDebugModel == true) {
		html.push("&nbsp;&nbsp;&nbsp;&nbsp;<button  id='CAnalysisStartButton' class='leftNavBg' onclick='CostAnalysis.Cmd(\"DoStart\")'>强行继续</button>");
	}
	html.push("</div>");
	return html.join("");
}

//分析过程div
CostAnalysis.RefreshAnalysisSpeed = function (div, runtime) {
	var stepinfo = runtime.StepInfo;
	var html = [];
	var existerror = false;
	$ID("CostAnalysisMainTitle").innerHTML = "正式成本核算";
	html.push("<div id='MainAnalysisTable' style='max-height:400px;'>")
	html.push("<div id='MainAnalysisSpeedBody' style=''>")
	html.push("<table id='MainAnalysisSpeedBodyTb' align='center'>");
	html.push("<col style='width:220px'><col style='width:120px'><col style='width:200px'>");
	html.push("<tr><td>成本核算项</td><td>核算结果</td><td>待处理数据</td></tr>");
	var messagelen = stepinfo.Exsits18500Model ? stepinfo.Messages.length : (stepinfo.Messages.length ? 1 : 0);//显示内容受18500模块化控制；
	CostAnalysis.AnysMessageLen = stepinfo.Messages.length;
	for (var i = 0; i < messagelen; i++) {
		var msg = stepinfo.Messages[i];
        html.push("<tr>")
        html.push("<td  style='text-align:left;'>" + (msg.Name ? msg.Name : "") + (msg.ExtMsg ? "<span style='color:#ccc;margin-left:4px;'>[" + msg.ExtMsg + "]</span>" : "") + "</td>");
        RefreshAnaySpeedUpdateHtml(html, msg, runtime)
        html.push("</tr>")
        if (msg.Status == "待分摊") { existerror = true; }
	}
	html.push("</table>");
	html.push("</div></div>");
	html.push("<div  class='CAnalysisStartDiv'></div>");
	var allcount = stepinfo.SpeedCount;
	var sindex = stepinfo.SpeedIndex;
	var str = "<div  class='CAnalysisStartDiv'>"
		+"<div class='CAnalysisProgress'>"
		+ "<div class='CAnalysisProgressInnerBar' style='width:" + (allcount > 0 ? sindex * 1 / allcount * 100 : 0) + "%'  id='CurrProgressBar1'></div>"
		+ "<div class='CAnalysisProgresstxt'  id='CurrProgressText1'>" + (sindex >= allcount && allcount > 0 ? "检测完成" : ("正在核算" + (stepinfo.SpeedMessage || "") + "...")) + "</div>"
		+"</div>"
	if (runtime.StepIndex % 10 > 0 && stepinfo.ExecStatus != "execing") {
		str += "<button  id='CAnalysisCancleButton' class='leftNavBg' onclick='CostAnalysis.DoDoReset()'>取消核算</button>&nbsp;&nbsp;&nbsp;&nbsp;"
		if (window.SysConfig.IsDebugModel != true) {
		    str += existerror ? "<button  id='CAnalysisStartButton' class='leftNavBg' onclick='CostAnalysis.TimerWatchRequest(true);CostAnalysis.Cmd(\"ReStart\")'>重新核算</button>&nbsp;&nbsp;&nbsp;&nbsp;" : "";
		}
		str += "<button " + (existerror ? "disabled" : "") + " id='CAnalysisStartButton' " + "class='" + (existerror ? "bomCheckNoShow" : "leftNavBg") + "' onclick='CostAnalysis.Cmd(\"ReStart\")'>继续核算</button>";
	    if (window.SysConfig.IsDebugModel == true) {
			str += "&nbsp;&nbsp;&nbsp;&nbsp;<button  id='CAnalysisStartButton' class='leftNavBg' onclick='CostAnalysis.Cmd(\"ReStartNoFee\")'>强制继续</button>";
	    }
	}
	str += "</div>";
    html.push(str);
	div.innerHTML = html.join("");
}

CostAnalysis.CreateBigCompleteDivHtml = function (div, jsonobj)
{
    $("div.CAnalysisProgressInnerBar")[0] ? $("div.CAnalysisProgressInnerBar")[0].style.width = "100%" : "";
    var stepinfo = jsonobj.StepInfo||"";
    var dateArr =stepinfo? stepinfo.NewMonth.split("-"):[],
        method = jsonobj.AnalysisMethod ? jsonobj.AnalysisMethod.split("_")[1] : "",
        costtype;
    var rightControl = stepinfo.ExsitsCostAnalysis;//去查看跳转受权限控制
    var model17001 = stepinfo.ExsitsModel && stepinfo.ExsitsModel.indexOf("17001") >= 0;//库存成本变动汇总表受模块号17001控制
    var model18500 = stepinfo.ExsitsModel && stepinfo.ExsitsModel.indexOf("18500") >= 0;
    $ID("CostAnalysisMainTitle").innerHTML = "恭喜您，完成成本核算！";
    switch(method){
        case "订单法":
            costtype=2;break;
        case "品种法":
            costtype=1;break;
        case "分步法":
            costtype=3;break;
    }
	var str= "<div style='max-height:400px;'><table id='MainAnalysisinittb' align='center'>"
			+ "<col style='width:390px'><col style='width:150px'>"
			+ "<tr><td>成本核算报表</td><td>详情</td></tr>"
	str +=  model17001 ? 
                  ("<tr><td style='text-align:left;'>&nbsp;库存成本变动汇总表</td>"
                 + "<td>"
                 + (rightControl ?("<a class='goHandleBill' href='javascript:void(0)' onclick='app.OpenUrl(\"/SYSN/view/finan/CostAnalysis/CostReport/InventoryCostChangeSummary.ashx?month=" +jsonobj.AnalysisMonth.split(" ")[0] + "\")'>去查看"
                 + "<span class='handleIcon costiconfont  icon-jinru' style='color:#0052c2'></span>"
                 + "</a>") : "")
                 + "</td></tr>") : "";
	str +=  model18500 ?
                  ("<tr><td style='text-align:left;'>&nbsp;产品成本汇总表</td>"
                 + "<td>"
                 + (rightControl ?("<a class='goHandleBill' href='javascript:void(0)' onclick='app.OpenUrl(\"/SYSN/view/finan/CostAnalysis/CostReport/ProductedSummaryList.ashx?month=" + jsonobj.AnalysisMonth.split(" ")[0] + "&costtype=" + costtype + "\")'>去查看"
                 + "<span class='handleIcon costiconfont  icon-jinru' style='color:#0052c2'></span>"
                 + "</a>"):"")
                 +"</td></tr>"
			     + "<tr><td style='text-align:left;'>&nbsp;在产品成本汇总表</td>"
                 + "<td>"
                 + (rightControl ?("<a class='goHandleBill' href='javascript:void(0)' onclick='app.OpenUrl(\"/SYSN/view/finan/CostAnalysis/CostReport/ProductingSummaryList.ashx?month=" + jsonobj.AnalysisMonth.split(" ")[0] + "&costtype=" + costtype + "\")'>去查看"
                 + "<span class='handleIcon costiconfont  icon-jinru' style='color:#0052c2'></span>"
                 + "</a>"):"")
                 +"</td>"
                 + "</tr>") : "";
	str += "<tr><td colspan=2 style='color:#000'>核算期已自动结转至" + dateArr[0] + "-" + dateArr[1] + "</td></tr>"
			+ "</table></div>"
			+ "<div  class='CAnalysisStartDiv' style='height:30px;'>"
			+ "<button  id='CAnalysisStartButton' class='leftNavBg' onclick='CostAnalysis.Cmd(\"DoComplete\")'>关闭核算窗口</button>"
			+ "</div>";
    return str
}

CostAnalysis.CreateErrorHtml = function (div, jsonobj, title) {
	var stepinfo = jsonobj.StepInfo ? jsonobj.StepInfo : jsonobj;
	return "<div style='width:100%;height:440px;overflow:auto'>"
			+ "<div style='text-align:center;color:red;font-weight:bold;font-family:微软雅黑;font-size:20px;height:20px'>" + title +"</div>"
			+ "<div style='text-align:left;color:red;font-family:微软雅黑;font-size:14px;margin-left:20px'>" + stepinfo.ErrorMessage + "</div>"
			+ "<div style='text-align:left;font-family:微软雅黑;font-size:12px;margin-left:20px'>" + stepinfo.ErrorStackTrace + "</div>"
			+ "</div>"
			+ "<div style='text-align:center;margin-top:10px'>"
			+ "<button  id='CAnalysisStartButton' class='leftNavBg' onclick='CostAnalysis.DoDoReset()'>确定</button>"
			+ "</div>";
}

CostAnalysis.DoDoReset = function ()
{
    if (confirm("您确定要取消本次核算吗？"))
	{
		CostAnalysis.Cmd("DoReset");
		CostAnalysis.HiddenUIWin();
	}
}

CostAnalysis.RefreshRuntimeBigDivUI = function (div, jsonobj) {
	if (jsonobj.error) {
		jsonobj.ErrorMessage = jsonobj.error;
		jsonobj.ErrorStackTrace = jsonobj.stacktrace;
		div.innerHTML = CostAnalysis.CreateErrorHtml(div, jsonobj, "");
		return;
	}
	var needcreatediv = !( jsonobj.StepInfo && jsonobj.StepInfo.OnlyProgressInfo && $ID('CurrProgressText1'));
	CostAnalysis.SetActiveMenu(jsonobj);
	var sindex = parseInt(jsonobj.StepIndex / 10);
	if (sindex == 4)
	{
		if (CostAnalysis.AnysMessageLen !=( jsonobj.StepInfo.Messages || []).length)
		{
			needcreatediv = true;
		}
	}
	if(needcreatediv)
	{
		switch (sindex)
		{
			case 0: div.innerHTML = CostAnalysis.CreateBigDivInitHtml(div, jsonobj); break;
			case 1: div.innerHTML = CostAnalysis.CreateBigLoadDataDivHtml(div, jsonobj); break;
			case 2:
			case 3: div.innerHTML = CostAnalysis.CreateBigDataCheckDivHtml(div, jsonobj); break;
			case 4: CostAnalysis.RefreshAnalysisSpeed(div, jsonobj); break;
			case 5: div.innerHTML = CostAnalysis.CreateBigCompleteDivHtml(div, jsonobj); break;
			case 6: div.innerHTML = CostAnalysis.CreateErrorHtml(div, jsonobj,  "" ); break;
		}
	}
	CostAnalysis.UpdateProgressInfo(jsonobj.StepInfo);
}

CostAnalysis.UpdateProgressInfo=function(info)
{
	if (!$ID('CurrProgressText1')) { return;}
	var bl = info.SpeedCount == 0 ? 0 : parseInt(info.SpeedIndex * 100 / info.SpeedCount);
	if (bl == 100) { info.SpeedMessage = "完成"; }
	$ID('CurrProgressBar1').style.width = bl + "%";
	$ID('CurrProgressText1').innerHTML = info.SpeedMessage || "";
}

CostAnalysis.RefreshRuntimeMinDivUI = function (div, jsonobj) {
    if (!div || !div.children[0]) { return; }
    var activeBar = div.children[0].children[0];
    var proNuw = Math.round((jsonobj.StepIndex >= 50 ? 50 : jsonobj.StepIndex) / 50 * 100);
    if (!proNuw) { return; }
    activeBar.style.width = proNuw + "%";
    $ID("CostAnalysisMinProgressDiv").innerHTML = proNuw + "/100";
    if (jsonobj.error) { $ID("CostAnalysisMinTitle").innerHTML = "成本核算终止"; $("#CostMinAnalysisDlg").addClass("CostCheckexcept"); } else {
        if (proNuw == 100) { $ID("CostAnalysisMinTitle").innerHTML = "成本核算完毕" } else {
            $ID("CostAnalysisMinTitle").innerHTML = "成本核算中...";
        }
        $("#CostMinAnalysisDlg").removeClass("CostCheckexcept");
    }
}

CostAnalysis.CompleteRefreshListViewUI = function () {
    if (CostAnalysis.listViewid) {
        var home = window.location.href.indexOf("/home.ashx") >= 0;
        if (home) {
            var iframe = document.getElementsByTagName("iframe")[0];
            var iframeChil =iframe? iframe.contentWindow.document.getElementsByTagName("iframe")[2]:"";
            if (iframeChil && iframeChil.contentWindow.document.getElementById(CostAnalysis.listViewid))
            {
            	iframeChil.contentWindow.location.reload();
            	CostAnalysis.HiddenUIWin();
            }
        } else {
			if ($ID(CostAnalysis.listViewid)) { window.location.reload(); CostAnalysis.HiddenUIWin()}
        }
    }
}



function ShowMainAnalysisDlg(date1) {
    var event = window.event;
    var srcElement =event?(event.target||event.srcElement):"";
    var id = srcElement && srcElement.parentNode ? srcElement.parentNode.getAttribute("lvw_id") : ""
    top.CostAnalysis.listViewid = id ? ("lvw_" + id) : "";
    if (CostAnalysis.Cmd) {//左侧导航模块化控制;
        CostAnalysis.Cmd("InitLeftNav", date1)
    }
    //top.CostAnalysis.ShowMainAnalysisDlg(date1);
}

function checkBtnShowHandle(dom) {
    var checked = $(dom)[0].checked;
    if (!checked) { $("#CAnalysisStartButton").addClass("bomCheckNoShow")[0].disabled= true } else { $("#CAnalysisStartButton").removeClass("bomCheckNoShow")[0].disabled= false }
}

function RefreshAnaySpeedUpdateHtml(htmArr, info,json) {
    if (!info || !info.Status) { return; }
    var m = json.AnalysisMethod?json.AnalysisMethod.split("_")[1]:""
    switch (info.Status) {
        case "已完成":
            htmArr.push("<td><span class='' style='color:#000;'><span class='costiconfont icon-duihao' style='color:#000;'></span>" + info.Status + "</span></td><td>&nbsp;</td>")
            break;
        case "待分摊":
            if (!info.WaitMsg.length) { break;}
            var apportionInfo =eval("("+info.WaitMsg+")");
            UpdateCostApportionHandelUrl(apportionInfo, m)
            var tdStr = "<td>"
                    + "<span class='' style='color:#FF9400;'>"
                    + "<span class='costiconfont icon-shijianlishijilujishizhongbiaoxianxing' style='color:#FF9400;font-size:14px;margin-right:4px'></span>" + info.Status
                    + "</span>"
                    + "</td>"
                    + "<td>"
                    + getHandleHtmlByCheckCostMethod(m, apportionInfo)
                    + "</td>";
            htmArr.push(tdStr)
            break;
        case "核算中":
            htmArr.push("<td><span style='color:#000;'><span class='costiconfont icon-duihao' style='color:#fff;'></span>核算中</span></td><td>&nbsp;</td>")
            break;
        case "未开始"://规避服务端未修改的"未开始"
        case "未核算":
            htmArr.push("<td><span style='color:#000;'><span class='costiconfont icon-duihao' style='color:#fff;'></span>未核算</span></td><td>&nbsp;</td>")
            break;
    }
}

//根据分摊方法获取分摊处理html
function getHandleHtmlByCheckCostMethod(method, info) {
    var html = "";
    switch (method) {
        case "订单法":
            var orderInNum=info.items["m_订单内"];
            var orderBtwNum=info.items["m_订单间"];
            if (orderInNum > 0) { html += CostApportionLinkHtml(info.items["m_订单内"], info.itemurl["m_orderIn"]) };
            if (orderBtwNum > 0) { html += CostApportionLinkHtml(info.items["m_订单间"], info.itemurl["m_orderBtw"]) }
            break;
        case "品种法":
            var deptBtwNum = info.items["m_部门间品种法"];
            if (deptBtwNum > 0) { html += CostApportionLinkHtml(info.items["m_部门间品种法"], info.itemurl["m_deptBtw"]) }
            break;
        case "分步法":
            var fdeptInNum =  info.items["m_部门内分步法"];
            var fdeptBtwNum = info.items["m_部门间分步法"];
            if (fdeptInNum > 0) { html += CostApportionLinkHtml(info.items["m_部门内分步法"], info.itemurl["m_deptIn"]) }
            if (fdeptBtwNum > 0) { html += CostApportionLinkHtml(info.items["m_部门间分步法"], info.itemurl["m_deptBtw"]) }
            break;
    }
    return html;
}

//待分摊数量以及链接Html；
function CostApportionLinkHtml(num, url)
{
	var htm = "<table style='border-collapse:collapse' align=center><tr>"
					+ "<td style='border:0px'><span class='num'>" + num + "</span>&nbsp;</td>"
    if (url) {
		htm += "<td style='border:0px'><a class='goHandleBill'  href='" + url + "' target='_blank'>去处理</a>"
			+"<span class='handleIcon costiconfont  icon-jinru' style='color:#0052c2'></span></td>"
			+ "<td style='border:0px'>&nbsp;<a href='javascript:void(0)' onclick='CostAnalysis.ShowMainAnalysisDlg()'>刷新</a></td>"
    }
    htm += "</tr></table>"
    return htm;
}

//根据分摊方法确定分摊处理链接地址；
function UpdateCostApportionHandelUrl(apportionInfo, method) {
    if (!app.isObject(apportionInfo)) { return;}
    apportionInfo["itemurl"]={}
    switch (method) {
        case "订单法":
            apportionInfo["itemurl"]["m_orderIn"] = window.SysConfig.VirPath + "SYSN/view/finan/CostAnalysis/CostShare/OrderInCostShareList.ashx";
            apportionInfo["itemurl"]["m_orderBtw"] = window.SysConfig.VirPath + "SYSN/view/finan/CostAnalysis/CostShare/CostShareList.ashx?pmode=1";
            break;
        case "品种法":
            apportionInfo["itemurl"]["m_deptBtw"] = window.SysConfig.VirPath + "SYSN/view/finan/CostAnalysis/CostShare/CostShareList.ashx?pmode=3";
            break;
        case "分步法":
            apportionInfo["itemurl"]["m_deptIn"] = window.SysConfig.VirPath + "SYSN/view/finan/CostAnalysis/CostShare/DeptInCostByStepShareList.ashx";
            apportionInfo["itemurl"]["m_deptBtw"] = window.SysConfig.VirPath + "SYSN/view/finan/CostAnalysis/CostShare/CostShareList.ashx?pmode=4";
            break;
    }
}

//处理长参
function handleLongParam(url) {
    var adUrl = app.GetLongAttrUrl(window.SysConfig.VirPath + url, "paraids");
    app.OpenUrl(adUrl);
}
//弹层拖动；
function CostCheckLayerDrag(ev ,scobj,id)
{
	var div=document.getElementById(id);
	if(div)
	{
		if(scobj){scobj.style.cursor="move";}
		if(app.IeVer<100){  IeDivDrag(div, scobj)}else
		{
			document.captureEvents(Event.MOUSEMOVE);
			div.mv_x=div.offsetLeft;
			div.mv_y=div.offsetTop;
			div.preX=null;
			div.dtTop=null;
			var currwin = window;
			var doc = currwin.document;
			if(currwin.currdlg_doc_onmousemove){
				$(doc).unbind("mousemove",currwin.currdlg_doc_onmousemove);
			}
			currwin.currdlg_doc_onmousemove = function () {
                if(div){$(div).addClass("noselect")}
				if(!div.preX)
				{
					div.preX=window.event.screenX
					div.preY=window.event.screenY
					div.dtTop=window.event.clientY-div.offsetTop;
				}
				else{
					x0=div.preX-window.event.screenX
					y0 = div.preY - window.event.screenY
                    //左右定位及边界规避;
					var divLeft = div.offsetLeft - x0;
					if (divLeft < 30 - div.offsetWidth) {
					    div.style.left = (30 - div.offsetWidth) + "px";
					} else {
					    if (divLeft > window.innerWidth - 30) {
					        div.style.left = (window.innerWidth - 30) + "px";
					    } else { div.style.left = divLeft + "px"; }
					}
				    //高度定位以及边界规避;
					var divTop = div.offsetTop - y0;
					if (divTop < 0)
					{div.style.top="0px";}
					else {
					    if (window.innerHeight - 30 < divTop) {
					        div.style.top = window.innerHeight - 30+"px"
					    } else {
					        div.style.top = divTop + "px";
					    }					    
					}
					div.preX = window.event.screenX;
					div.preY = window.event.screenY;
					div.style.margin = "0px";
				}
			}
			currwin.currdlg_doc_onmouseup = function(){
				div.preX=null;
				scobj.style.cursor = "default";
				if (div) { $(div).removeClass("noselect") }
				$(doc).unbind("mousemove",currwin.currdlg_doc_onmousemove);
				$(doc).unbind("mouseup",currwin.currdlg_doc_onmouseup);
				if(doc.releaseCapture){doc.releaseCapture();}
			}
			$(doc).bind("mousemove",currwin.currdlg_doc_onmousemove);
			$(doc).bind("mouseup", currwin.currdlg_doc_onmouseup);
			$(doc).bind("mouseleave", function () {
				if(window.event.clientY<=0)
				{currwin.currdlg_doc_onmouseup&&currwin.currdlg_doc_onmouseup();}
			});
		}
	}
}
function IeDivDrag(div, scobj) {
    scobj.setCapture();
    div.mv_x = div.offsetLeft;
    div.mv_y = div.offsetTop;
    div.preX = null;
    div.dtTop = null;
    scobj.onmousemove = function () {
        if (!div.preX) {
            div.preX = window.event.screenX;
            div.preY = window.event.screenY;
            div.dtTop = window.event.clientY - div.offsetTop;
        }
        else {
            x0 = div.preX - window.event.screenX
            y0 = div.preY - window.event.screenY
            var divLeft = div.offsetLeft - x0;
            var winWidth = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth;
            if (divLeft < 30 - div.offsetWidth) {
                div.style.left = (30 - div.offsetWidth) + "px";
            } else {
                if (divLeft > winWidth - 30) {
                    div.style.left = (winWidth - 30) + "px";
                } else { div.style.left = divLeft + "px"; }
            }
            var divTop = div.offsetTop - y0;
            var winHeight = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight;
            if (divTop < 0)
            { div.style.top = "0px"; }
            else {
                if (winHeight - 30 < divTop) {
                    div.style.top = winHeight - 30 + "px"
                } else {
                    div.style.top = divTop + "px";
                }
            }
            div.preX = window.event.screenX;
            div.preY = window.event.screenY;
            div.style.margin = "0px";
        }
    }
    scobj.onmouseup = function () {
        div.preX = null;
        scobj.onmousemove = function () { }
        scobj.releaseCapture();
        scobj.style.cursor = "default";
    }

}
function banPop() {
    var e = window.event;
    if (e.stopPropagation) { e.stopPropagation() } else { e.cancelBubble = true }
}

function CCompleteStatus(row) {
	switch (row.complete1)
	{
		case 0: return "未核算";
		case 1: return "核算中";
		case 2: return "已核算" + (row.id<0 ? "<span style='color:red;ont-family:微软雅黑'>(仅存货)</span>" : "");
		default: return row.complete1;
	}
}