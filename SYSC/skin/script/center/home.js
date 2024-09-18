window.WriteHtml = function (html) {
	document.write(html);
}

window.createPage = function () {
	window.HomeObj = window.PageInitParams[0];
	//此处编写渲染代码
	window.CHeaderHtml();
	window.CBodyHtml();
	window.CBottomHtml();
	setTimeout(window.GetSession, 1000);
}


window.CBottomHtml = function () {
    var now = new Date();
    var m = (now.getMonth() * 1 + 1);
    var d = now.getDate();
    var ClineHtml = function () {
        WriteHtml("<div style='float:left;padding:2px 9px 0px 10px'><img class='resetElementHidden' src='" + window.SysConfig.VirPath + "SYSA/skin/default/images/ico_footer_02.gif'><div class='resetBorderLeft'></div></div>");
    }
    var ClineHtmlR = function () {
        WriteHtml("<div style='float:right;padding:2px 9px 0px 10px'><img class='resetElementHidden' src='" + window.SysConfig.VirPath + "SYSA/skin/default/images/ico_footer_02.gif'><div class='resetBorderLeft'></div></div>");
    }
    if (window.HomeObj.ewords == "" || window.HomeObj.ewords == undefined) {
        window.HomeObj.ewords = "未设置激励语";
    }
    WriteHtml("<div id=homebuttomdiv style='overflow:hidden;text-overflow:ellipsis'>");
    //左侧内容
    WriteHtml("<div style='padding-left:5px;float:left'><img class='resetElementHidden' src='" + window.SysConfig.VirPath + "SYSA/skin/default/images/ico_footer_01.gif'><img class='resetElementShow' style='display:none;' src='" + window.SysConfig.VirPath + "SYSC/skin/default.mozi/images/ico_footer_01.png'></div>");
    WriteHtml("<div style='float:left;padding-left:5px;max-width:150px'>");
    WriteHtml( " 用户：" + window.UserInfo.Name);
    WriteHtml("</div>");
    ClineHtml();
    WriteHtml("<div style='float:left;padding-left:5px;'>");
    WriteHtml("<a href='javascript:void(0)' onclick='showDatePanel();return false;' id='DateStWords' title='鼠标单击查看日历'>" + now.getFullYear() + "年" + (m < 10 ? ("0" + m) : m) + "月" + (d < 10 ? ("0" + d) : d) + "日</a>");
    WriteHtml("</div>");
    ClineHtml();
    WriteHtml("<div style='float:left;padding-left:5px;'>");
    WriteHtml(" 在线(<a id='usercount'></a>)");
    WriteHtml("</div>");
    ClineHtml();
    WriteHtml("<div style='float:left;padding-left:5px;max-width:480px;height:14px;padding-top:0px;text-overflow:ellipsis'>");
    WriteHtml("<a href='javascript:void(0)' onclick='setStimulusWords();return false;' title='鼠标单击设置您的激励语' id='ewordslabel'>" + window.HomeObj.ewords + "</a>");
    WriteHtml("</div>");
    //右侧内容
    WriteHtml("<div style='float:right;padding-right:10px'>");
    WriteHtml("V" + (window.SysConfig.BrandIndex != 3 ? "1.00" : window.SysConfig.AppVersion));//初始版是0.9.0，之后看变化的规律由前端修改版本号（后端变动太大）；
    WriteHtml("</div>");
    if (window.SysConfig.BrandIndex != 3) { ClineHtmlR(); }
	WriteHtml("<div style='float:right;padding-right:5px'>");
	WriteHtml("<a id='jylink' " + (window.SysConfig.BrandIndex == 3 ? "style='display:none'" : "") + " target=_blank href='javascript:void(0)' onclick=" + (window.SysConfig.BrandIndex == 3 ? "'alert(\"抱歉,该网页还在建设中\");return false'" : "'app.OpenUrl(\"http://www.zbintel.com/product-center/proposal.shtml?uid=" + window.HomeObj.uniquename + "\",\"sdaadxxx\",{width:1260, height:680, align:\"center\"})'") + ">提交建议</a>");
	WriteHtml("</div>");
	ClineHtmlR();
	WriteHtml("<div style='float:right;padding-right:5px'>");
	WriteHtml("	<a href='javascript:void(0);' onclick='toDesktop(document.title);return false;' class='bottomlink'>创建快捷方式</a>");
	WriteHtml("</div>");
	if (window.SysConfig.IsDebugModel == true) {
		ClineHtmlR();
		WriteHtml("<div style='float:right;padding-right:5px'>");
		WriteHtml("	<a href='../../../sysn/view/init/home.ashx'  target=_blank class='bottomlink' style='color:yellow'>打开业务系统首页</a>");
		WriteHtml("</div>");
	}
	WriteHtml("</div>");
}

function toDesktop(n) {
	var url = window.location.href.split("?")[0].toLowerCase();
	url = url.replace("/sysc/view/center/home.ashx", "");
	if (app.getIEVer() > 11) {
		alert("抱歉，此功能目前只支持IE浏览器。");
		return;
	}
	if (n.length == 0) {
		alert("缺少必要的参数!");
	} else {
		try {
			var wsh = new ActiveXObject("WScript.Shell");
			var fso = new ActiveXObject("Scripting.FileSystemObject");
			var f = fso.CreateTextFile(wsh.SpecialFolders("desktop").replace(/\\/g, "\\\\") + "\\" + n + ".url", true);
			f.writeline("[{000214A0-0000-0000-C000-000000000046}]");
			f.writeline("Prop3=19,2");
			f.writeline("[InternetShortcut]");
			f.writeline("URL=" + url + "/sysn/view/init/login.ashx");
			f.writeline("IDList=");
			f.writeline("IconFile=" + url + "/favicon.ico");
			f.writeline("IconIndex=0");
			f.close();
			var f = null;
			var fso = null;
			var wsh = null;
			alert('快捷方式创建成功！');
		} catch (e) {
			alert('当前IE安全级别不允许操作！请按以下设置后重试.\nIE设置步骤：\nInternet选项》安全》自定义级别》对未标记为可安全执行的脚本 ActiveX控件初始化并执行脚本\n设置为：启用');
		}
	}
}

window.CHeaderHtml = function () {
	WriteHtml('<img src="' + window.HomeObj.logourl + '?t=' + (new Date()).getTime() + '" id="logoBox">')
	//创建顶部导航
	WriteHtml("<div id='righttopbar'>");
	CRightTopBarHtml();
	CRightTopSiteListHtml();
	WriteHtml("</div>");
}

window.CBodyHtml = function () {
	WriteHtml("<div  id='BodyContent' >")
	WriteHtml("<iframe src='main.ashx'  id='mainframe' name='mainframe' style='width:100%;height:100%' frameborder=0>");
	WriteHtml("</iframe>");
	WriteHtml("</div>");
}

window.CRightTopBarHtml = function () {
	var obj = window.PageInitParams[0];
	WriteHtml("<table id='toprightbartb'><tr>")
	WriteItemTopRightBar("工作台", "p18.png", "main.ashx");
	WriteItemTopRightBar("|");
	for (var i = 0; i < obj.subsystems.length; i++) {
		if (obj.subsystems[i].canview) {
			WriteItemTopRightBar("子公司", "p16.png", "../subsystems/childrencompany.ashx");
			WriteItemTopRightBar("|");
			break;
		}
	}
	if (obj.existschildsystempower == true) {
		WriteItemTopRightBar("子系统", "p17.png", "../subsystems/list.ashx");
		WriteItemTopRightBar("|");
	}
	if (obj.existsaccountpower == true) {
		WriteItemTopRightBar("集团账号", "p14.png", "../../../SYSN/view/magr/Accountlist.ashx");
	} else {
		WriteItemTopRightBar("集团账号", "p14.png", "../../../SYSA/manager/pw.asp");
	}
	WriteItemTopRightBar("|");
	if (obj.existsaccountpower == true) {
		WriteItemTopRightBar("系统设置", "p9.png", "../setting/setting.ashx");
		WriteItemTopRightBar("|");
	}
	WriteItemTopRightBar("退出", "p11.png", "?__msgid=LoginOut");
	WriteHtml("</tr></table>")
}

window.CRightTopSiteListHtml = function () {
	WriteHtml("<div id='stopsitelistsb' onclick='ShowSubSystemsList()'>请选择登录子系统</div>");
}

window.ShowSubSystemsList = function () {
	var div = $ID("ShowSubSystemsListbg");
	if (!div) {
		var obj = window.PageInitParams[0];
		div = document.createElement("div");
		div.id = "ShowSubSystemsListbg";
		div.style.cssText = "position:fixed;_position:absolute;width:100%;height:100%;top:0px;left:0px;z-index:100";
		var listHtml = "";
		for (var i = 0; i < obj.subsystems.length; i++) {
			var iobj = obj.subsystems[i];
			var clientuserid = iobj.clientuserid;
			var title = clientuserid == 0 ? "点击绑定子系统" : "点击访问子系统";
			var imgsrc = clientuserid == 0 ? "p4.png" : "p5.png";
			listHtml += "<div  onclick='app.OpenUrl(\"?__msgid=VisitSubSystem&companyId=" + app.pwurl(iobj.companyid) + "\",\"subsystemwin\",{width:1200,height:600})' title='" + title + "' style='width:218px;height:34;overflow:hidden;line-height:34px;cursor:pointer;border-top:1px solid #eee'>"
								+ "<div style='width:38px;float:right;overflow:hidden;box-sizing:border-box;background:transparent url(../../skin/default/images/" + imgsrc + ")  no-repeat center center'>&nbsp;</div>"
								+ "<div style='font-family:微软雅黑;overflow:hidden;text-align:left;box-sizing:border-box;padding-left:23px;white-space:nowrap'>" + iobj.companyname + "</div>"
								+"</div>";
		}
		if (obj.subsystems.length == 0) {
			listHtml = "<div style='width:218px;height:34;overflow:hidden;line-height:34px;cursor:pointer;border-top:1px solid #eee'>"
								+ "<div style='font-family:微软雅黑;overflow:hidden;text-align:left;box-sizing:border-box;padding-left:23px;white-space:nowrap;color:#aaa'>您的账号还没有绑定子系统</div>"
								+ "</div>";
		}
		div.innerHTML = "<div id='ShowSubSystemsListbox'  style='box-shadow: -3px 10px 20px #dcdce6;position:absolute;right:6px;top:88px;background-color:white;'>"
						+ listHtml + "</div>";
		document.body.appendChild(div);
		$(div).click(function () {
			$("#ShowSubSystemsListbg").remove();
		});
	}
}

window.currSelectLinkIndex = "工作台";
window.homeurl = function (url, title) {
	if (title == "退出") {
		if (window.confirm("您确定要退出吗？") == false) {
			return;
		}
	}
	$ID("mainframe").src = url;
	window.currSelectLinkIndex = title;
	var tb = $ID("toprightbartb");
	for (var i = 0; i < tb.rows[0].cells.length; i++) {
		var cell = tb.rows[0].cells[i];
		if (cell.getAttribute("curtitle") != title) {
			cell.style.backgroundColor = "transparent";
		} else if (window.SysConfig.BrandIndex == 3) {
		    cell.style.backgroundColor = "#141414";
		} else {
			cell.style.backgroundColor = "#225D8E";
		}
	}
}

window.toplinkms = function (box, stype, title) {
	if (stype == 1) {
		box.style.backgroundColor = "#225D8E";
		$(box).unbind("mouseleave").bind("mouseleave", function (ex) {
			window.toplinkms(ex.target, 2, ex.target.getAttribute("curtitle"));
		})
		return;
	}
	if (title == window.currSelectLinkIndex) { return; 	}
	box.style.backgroundColor = "transparent"
}

window.WriteItemTopRightBar = function (title, ico, url) {
	if (title == "|") {
		WriteHtml("<td><div class='resetBgfff' style='height:20px;width:1px;background-color:#74AADB;overflow:hidden;margin:0px 4px'></div></td>");
	} else {
		var bgcolor = (window.currSelectLinkIndex == title) ? (window.SysConfig.BrandIndex !=3 ? "#225D8E":"#141414"): "";
		WriteHtml("<td class='toplink'  style='background-color:" + bgcolor + "'  curtitle='" + title + "'  onclick='homeurl(\"" + url + "\",\"" + title + "\")'><table border=0><tr>"
			+ "<td style='background:transparent url(../../skin/default/images/" + ico + ") no-repeat center center;width:16px;height:14px'></td>"
			+ "<td style='color:white;padding-top:0px;line-height:13px'>" + title + "</td></table></td>");
	}
}

function showDatePanel() //显示日历
{
	var div = app.createWindow("szczxcdate", "系统日历", { width: 550, height: 425, canMove: true, closeButton: true, bgShadow:10 });
	div.style.overflow = "hidden";
	div.innerHTML = "<iframe style='width:100%;height:100%' scrolling='no' src='' frameborder='0'></iframe>";
	div.children[0].src = window.SysConfig.VirPath + "SYSA/ATools/wnl/index.htm";
}

window.setStimulusWords = function () {
	var div = app.createWindow("ewordsdlg", "自我激励语设置", { width: 400, height: 220, bgShadow: 10, closeButton: true});
	div.innerHTML = "<div style='padding:15px;padding-bottom:8px'>"
							+ "<textarea id=ewordeditbox  maxlength=100 style='width:340px;height:90px;border:1px solid #ccc' >" + window.HomeObj.ewords + "</textarea></div>"
							+ "<div style='text-align:center'>"
							+ "<button class=zb-button onclick='saveStimulusWords()'>确定</button> &nbsp; "
							+ "<button class=zb-button onclick='app.closeWindow(\"ewordsdlg\")'>取消</button></div>";
}

window.saveStimulusWords = function () {
	var v = $ID("ewordeditbox").value;
	if (v.length > 100) { window.alert("内容太长"); return;}
	window.HomeObj.ewords = v;
	if (window.HomeObj.ewords == "" || window.HomeObj.ewords == undefined) {
		window.HomeObj.ewords = "未设置激励语";
	}
	app.ajax.regEvent("SaveEWords");
	app.ajax.addParam("value", v);
	app.ajax.send();
	$ID("ewordslabel").innerHTML = window.HomeObj.ewords;
	app.closeWindow('ewordsdlg');
}


window.sessionTimeroutId = 0;

window.GetSession = function () {
	var url = window.SysConfig.VirPath + "SYSN/view/init/keeper.ashx?stamp=" + (new Date()).getTime();
	window.CurrSessionXmlHttp = new XMLHttpRequest();
	var xmlhttp = window.CurrSessionXmlHttp;
	xmlhttp.open("GET", url, true);
	xmlhttp.onreadystatechange = window.GetSessionHandle;
	if (window.sessionTimeroutId > 0) { window.clearTimeout(window.sessionTimeroutId); }
	window.sessionTimeroutId = setTimeout(window.OnSessionTimerout , 20000);
	xmlhttp.send(null);
};

window.GetSessionHandleNULL = function () { }

window.GetSessionHandle = function () {
	if (CurrSessionXmlHttp == null) { return; }  // Timeout 时 status = 0
	window.clearTimeout(window.sessionTimeroutId);
	if (CurrSessionXmlHttp.readyState != 4) {
		return;
	}
	var response = CurrSessionXmlHttp.responseText;
	window.CurrSessionXmlHttp = null;
	if (response.indexOf("{result:") >= 0) {
		var res = eval("(" + response + ")");
		if (res.result != "1") {
			window.ShowReLoginDlg(res.result, 0);
		} else {
			$ID("usercount").innerHTML =  res.usercount + "";
			setTimeout(window.GetSession, 8000);
		}
	} else {
		window.ShowReLoginDlg(0, 1);
	}
}

window.OnSessionTimerout = function () {
	var obj = window.CurrSessionXmlHttp;
	window.CurrSessionXmlHttp = null;
	obj.abort();
	obj = null;
	setTimeout(window.GetSession, 3000); //超时重试
}

window.reLoginOK = function () {
    window.SysConfig.BrandIndex == 3 ? app.closeWindow("_sys_log_out_win") : app.closeWindow("__sys_rlg_win");
	setTimeout(window.GetSession, 1000); //超时重试
}

window.ShowReLoginDlg = function (status,  srctype) {
	try { window.focus(); } catch (e) { }
	var t = new Date();
	var title = window.SysConfig.BrandIndex == 3 ? "_sys_log_out_win" : "__sys_rlg_win"
	var attr = window.SysConfig.BrandIndex == 3 ? { width: 482, height: 542, align: "center", bgShadow: 0 } : { width: 620, height: 468, align: "center", bgShadow: 50 };
	var win = app.createWindow(title, "重新登录", attr);
	win.innerHTML = "<iframe scrolling=no frameborder=0 style='border-radius:2px;border:1px solid #909aaa;display:block;width:600px;height:438px;margin:0px auto' "
							+ "src='" + window.SysConfig.VirPath + "SYSN/view/init/relogin.ashx?sver=" + window.SysConfig.ProductVersion
							+ "&dlg=" + t.getTime() + "&res=-" + status + "&unique=" + window.UserInfo.Id + "'></iframe>";
	win.style.overflow = "hidden";

}

window.PageBodyResize = function () {
	var h = document.documentElement.offsetHeight;
	$ID("mainframe").style.height = (h - 135) + "px";
}

if (app.getIEVer() == 7) {
	$(window).resize(window.PageBodyResize);
	$(window.PageBodyResize);
}