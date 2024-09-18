function __w(str) { document.write(str); }
window.createPage = function () {
	__w("<a name=toplink style='display:block;height:1px;width:1px'>&nbsp; </a>")
	__w("<div id='bigtitle'>业务场景设置</div>");
	__w("<div id='smltitle'>按照业务场景设置，快速定位业务范围， 让系统启用更加快捷</div>");
	var dat = window.PageInitParams[0];
	for (var i = 0 ; i < dat.BigGroups.length; i++) {
		CBigGroupItem(dat.BigGroups[i], i);
	}
	CFixedMenu(dat);
	__w("<a id='gotoTopLink' href='#toplink'>&nbsp;</a>")
	$(window).on("scroll", window.SetToTopBarCss);
	window.SetToTopBarCss();
}

window.SetToTopBarCss = function () {
	var topbar = $ID("bigindex0");
	var box = $ID("gotoTopLink");
	var newdisplay = topbar.getBoundingClientRect().top > 0 ? "none" : "block";
	if (box.style.display != newdisplay) {
		box.style.display = newdisplay;
	}
}

window.CFixedMenu = function(dat) {
	__w("<div id='fixedmenubody' style='margin-top:-" + parseInt((dat.BigGroups.length*35)/2) + "px'>");
	for (var i = 0 ; i < dat.BigGroups.length; i++) {
		__w("<a href='#bgp" + i + "'  class='fixedmenuitem" + (i == (dat.BigGroups.length-1)? " isend" : "") + "'>" + (dat.BigGroups[i].Title + "").substr(0, 2) + "</a>")
	}
	__w("</div>");
}

window.CBigGroupItem = function (gp, bigindex) {
	__w("<a name='bgp" + bigindex + "'  href='javascript:void(0)' class='mmmlink'></a>")
	__w("<div class='BigGroupTitle' id='bigindex" + bigindex + "'>" + gp.Title + "</div>");
	for (var i = 0; i < gp.Groups.length; i++) {
		window.CCommGroupItem(gp.Groups[i], bigindex, i);
	}
}

window.CCommGroupItem = function (gp, bigindex, gpindex) {
	__w("<div class='GPItem'>");
	__w("<div class='grouptitletb'>");
	__w("<table align='center'><tr><td>" + gp.Title + "</td><td><img  onclick='window.showHelpExplan(this,event)' helperindex='" + bigindex + "," + gpindex + "'  class=qu src='" + window.SysConfig.VirPath + "SYSN/skin/default/img/guide/qu.png'></td></tr></table>");
	__w("</div><div class='linkitembg'>");
	for (var i = 0; i < gp.Links.length; i++) {
		var link = gp.Links[i];
		var visitedcss = "";
		var firstcss = "";
		var cstyle = "";
		if (i == 0) {
			visitedcss = (link.Visited ? "v11" : "v00");
		}
		else {
			visitedcss = "v" + (gp.Links[i - 1].Visited ? "1" : "0") + (link.Visited ? "1" : "0");
		}
		if (i % 5 == 0) {
			firstcss = "isfirst";
		} else {
			firstcss = ( (i+1)%5==0 ) ? "isend" : "iscomm"
		}
		__w("<div class='linkitem " + visitedcss + " " + firstcss + "'>");
		if (firstcss == "isfirst") { __w("<div class='rpadding'></div>"); }
		if (link.Title.length > 10) { cstyle=" style='font-size:13px' " }
		__w("<a href='javascript:void(0)'  " + cstyle + " onclick=\"window.DoOpenUrl('" + gp.Title + "|" + link.Title  + "','" + window.SysConfig.VirPath + link.Url + "')\">" + link.Title + "</a>");
		if (firstcss == "isend") { __w("<div class='lpadding'></div>"); }
		__w("</div>");
	}
	__w("</div></div>");
}


window.DoOpenUrl = function (signtitle, url) {
	var win = app.OpenUrl(url);
	win.onload = function () {
		app.ajax.regEvent("saveItem");
		app.ajax.addParam("titlesign", signtitle);
		app.ajax.send(function () { });
	}
}

window.closeHelpExplan = function () {
	setTimeout(function () {
		$($ID("bill_help_expaln")).remove();
	}, 10);
}

window.showHelpExplan = function (ele, e) {
	e = e || window.event;
	var div = $ID("bill_help_expaln");
	var wid = document.documentElement.clientWidth || document.body.clientWidth;
	var wHei = document.documentElement.clientHeight || document.body.clientHeight;
	var maxw = parseInt(wid * 0.8) > 700 ? 700 : parseInt(wid * 0.8);
	var maxh = parseInt(wHei * 0.8) > 600 ? 600 : parseInt(wHei * 0.8);
	if (div) { $(div).remove(); div = null; }
	if (!div) {
		div = document.createElement("div");
		div.id = "bill_help_expaln";
		div.className = "resetBorderColorDc"
		var indexs = (ele.getAttribute('helperindex') || "").split(",");
		var txt = window.PageInitParams[0].BigGroups[indexs[0] * 1].Groups[indexs[1] * 1].Remark;
		if (txt.length < 500) { if (maxw > 250) { maxw = 250; } }
		div.innerHTML = "<div id='bill_help_expaln_text' class='bill_help_expaln_text resetBgf5 reseetTextColor666'  style='max-height:" + maxh + "px;overflow-y:auto;'>"
			+ "<div class='bill_help_expaln_top'><a title='关闭' href='javascript:;' onclick='window.closeHelpExplan()' class='bill_help_expaln_close'>×</a></div>"
			+ txt + "</div>";
		document.body.appendChild(div)
	} else {
		$ID("bill_help_expaln_text").innerHTML = ele.getAttribute('text') || ""
	}
	div.style.maxWidth = maxw + "px";
	var os = $(ele)[0].getBoundingClientRect();
	var hei = $(div).height();
	var myw = $(div).width();
	var otop = os.top + 20;
	if (otop + hei > wHei) { otop = wHei - hei - 10 }
	var oLeft = os.left + 20;
	if ((myw * 1 + oLeft * 1) > (wid - 20)) {
		oLeft = oLeft - myw;
	}
	div.style.top = otop + "px";
	div.style.left = oLeft + "px";
	div.style.display = "block";
	$(window).off("scroll", window.closeHelpExplan).on("scroll", window.closeHelpExplan);
};