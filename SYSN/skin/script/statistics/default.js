var SHome = new Object;
var menusindex;
var rootUrl;

function CHeaderHtml() {
	document.body.className = "mi_" + (menusindex  || 0);
	var html = new Array();
	html.push("<div class='HeadBg'>&nbsp;</div>");
	html.push("<div class='HeadTabCaption' title='点击跳转到首页' style='cursor:pointer' onclick='window.location.href=\"default.ashx\"'>" + SHome.Data.title + "</div>");
	html.push("<div class='HeadBg2'>");
	if (menusindex == 100) {
		html.push("<div id='searcmsg'>搜索结果：找到“" + (SHome.Data.searchkey||"") + "”相关内容 <b>" + SHome.Data.groups[0].links.length + "</b> 个</div>");
	}
	else {
		for (var i = 0; i < SHome.Data.menus.length; i++) {
			if (i > 0) { html.push("<div class='HeadSplit'>&nbsp;</div>") }
			if (i == menusindex) {
				html.push("<div class='HeadTabCaption2sel' id='currseldiv'>" + SHome.Data.menus[i] + "</div>");
			} else {
				html.push("<div class='HeadTabCaption2'><a href='?MenuIndex=" + i + "'>" + SHome.Data.menus[i] + "</a></div>");
			}
		}
	}
	html.push("</div>");
	html.push("<div id='currseldivsign' style='left:" + parseInt(130 * (menusindex + 0.5)) + "px'></div>");
	CSearchBarHTML(html);
	document.write(html.join(""));

	var currUrl = window.location.href.toLowerCase();
	var arr_url = currUrl.split("/sys");
	rootUrl = arr_url[0];
}

function CBodyHtml() {
	switch (menusindex) {
		case 0:
			//多维度
			CBodyHtml_MultiDimension();
			break;
		case 1:
			//综合页
			CBodyHtml_TotalNavigation();
			break;
		case 100:
			//检索页
			CBodyHtml_SearchResult();
			break;
	}
}

function CBodyHtml_SearchResult() {
	var html = new Array();
	var gp = SHome.Data.groups[0];
	html.push("<div id='linkbody' style='width:920px;margin-left:10px'>");
	for (var ii = 0; ii < gp.links.length; ii++) {
		var lnk = gp.links[ii];
		html.push("<div class='serlnk'><a name='" + lnk.title + "' href='javascript:openStatWin(\"" + (window.SysConfig.VirPath +  lnk.url).replace(/\/\//g,"/") + "\")' >" + lnk.title + "</a></div>");
	}
	html.push("</div>");
	document.write(html.join(""));
}

//多维度统计分析
function CBodyHtml_MultiDimension() {
    var html = new Array();
    var data = SHome.Data;
    var linkhref = "";
    html.push("<div id='bodytitle'>" + data.menus[data.menusindex || 0] + "</div>");
    html.push("<div id='bodydescription'>" + data.description + "</div>");
    html.push("<div style='height:25px'></div>");
    html.push("<div id='linkbody' style='width:" + (203 * data.groups.length) + "px'>");
    for (var i = 0; i < data.groups.length; i++) {
        var gp = data.groups[i];
        linkhref = "";
        if (gp.url) {
            linkhref = gp.url;
        }
        html.push("<div class='lnkgp bg" + (i % 2) + "'>");
        html.push("<div class='lnkgptit" + (i == (data.groups.length - 1) ? "last" : "") + "'>");
        if (linkhref != "") {
            html.push("<a href='" + rootUrl + linkhref + "'>" + gp.name + "</a>");
        } else {
            html.push(gp.name);
        }
        html.push("</div>");
        html.push("<div class='lnkgpspliter'>&nbsp;</div>");
        for (var ii = 0; ii < gp.links.length; ii++) {
            var lnk = gp.links[ii];
            html.push("<div class='lnk'><a name='" + lnk.title + "' href='" + rootUrl + linkhref + "#" + lnk.title + "'>" + lnk.title + "</a></div>");
        }
        html.push("<div class='lnkgpspliter'>&nbsp;</div>");
        html.push("</div>");
    }
    html.push("</div>");
    document.write(html.join(""));
}

//统计报表总导航
function CBodyHtml_TotalNavigation() {
    var html = new Array();
    var data = SHome.Data;
    var linkV = 0;
    var linkhref = "";    
    html.push("<div id='bodytitle'>" + data.menus[data.menusindex || 0] + "</div>");
    html.push("<div id='bodydescription'>" + data.description + "</div>");
    html.push("<div style='height:25px'></div>");
    html.push("<div id='linkbody' style='width:900px'>");
    for (var i = 0; i < data.groups.length; i++) {
        var gp = data.groups[i];
        html.push("<div class='lnkgp_nav bg1'>");        
        html.push("<div class='lnkgptit" + (i == (data.groups.length - 1) ? "last" : "") + "_nav'><a href='javascript:void(0)' id='" + gp.name + "' isgroupobj=1 ></a>" + gp.name + "</div>");
        html.push("<div class='lnkgpspliter'>&nbsp;</div>");
        for (var ii = 0; ii < gp.groups.length; ii++) {
            var gp2 = gp.groups[ii];
            html.push("<div class='lnkgpspliter clear'>&nbsp;</div>");
            html.push("<div class='lnkgpheader'>" + gp2.name + "</div>");
            html.push("<div class='lnkgpspliter'>&nbsp;</div>");            
            if (gp2.links.length % 5 == 0 ) {
                linkV = gp2.links.length / 5;
            } else {
                linkV = parseInt(gp2.links.length / 5) + 1;
            }
            html.push("<div class='lnkgplnks' style='height:" + (29 * linkV) + "px;'>");
            for (var iii = 0; iii < gp2.links.length; iii++) {
                linkhref = "";
                var lnk = gp2.links[iii];
                if (lnk.url) {
                    linkhref = lnk.url;
                }                
                html.push("<div class='lnk'>");
                if (linkhref != "") {
                    html.push("<a href='javascript:openStatWin(\"" + rootUrl + linkhref + "\")'>" + lnk.title + "</a>");
                } else {
                    html.push(lnk.title);
                }
                html.push("</div>");
            }            
            html.push("</div>");
        }
        html.push("<div class='lnkgpspliter'>&nbsp;</div>");
        html.push("</div>");
    }
    html.push("<div class='lnkgpspliter'>&nbsp;</div>")
    html.push("</div>");
    document.write(html.join(""));
}

function AutoGroupHeightSize() {
    var gps = $ID("linkbody").children;
    var gps2;
	var maxh = 0;
	var maxh2 = 0;
	for (var i = 0; i < gps.length; i++) {
		maxh = maxh > gps[i].offsetHeight ? maxh : gps[i].offsetHeight;
	}
	if (maxh > 0) {
	    for (var i = 0; i < gps.length; i++) {
	        gps[i].style.height = maxh + "px";
		}
	}
}

window.createPage = function () {
    SHome.Data = window.PageInitParams[0];
    menusindex = SHome.Data.menusindex || 0;
	CHeaderHtml();
	CBodyHtml();
	document.write("<div style='height:10px;clear:both'>&nbsp;</div>");
	if (menusindex == 0) {
	    AutoGroupHeightSize();
	    setTimeout(AutoGroupHeightSize, 1);
	}	
}

function openStatWin(url){
	window.open(url,'newstat'+(Math.round(Math.random()*100))+'win','width=' + 1210 + ',height=' + 700 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')
}
