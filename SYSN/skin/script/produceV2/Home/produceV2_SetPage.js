﻿var SHome = new Object;
var menusindex;
var rootUrl;

function CHeaderHtml() {
    document.body.className = "mi_" + (menusindex || 0);
    var html = new Array();
    html.push("<div id='comm_itembarbg' " + (window.SysConfig.SystemType==3?"":"style='border-bottom:1px solid #c0ccdc'")+">\n");
	html.push("<div id='comm_itembarICO'></div><div id='comm_itembarText' title='点击跳转到首页' style='cursor:pointer' onclick='window.location.href=\"produceV2_SetPage.ashx\"'><span>" +  SHome.Data.title  + "</span></div>\n");
	html.push("<div id='comm_itembarspc'></div>\n");
	html.push("</div>");
	if (SHome.Data.menus.length > 0) {
	    html.push("<div class='sstab_line'>");
	    for (var i = 0; i < SHome.Data.menus.length; i++) {
	        var str = "";
	        if (i == menusindex) { str = " sstab_sle" } else { str = "" }
	        html.push("<div class='sstab_div" + str + "' ><a title='" + SHome.Data.menus[i] + "' class='sstab_a' href='?MenuIndex=" + i + "' >" + SHome.Data.menus[i] + "</a></div>")
	    }
	    html.push("</div>");
	}
    var menuslength = 0;
    document.write(html.join(""));

    var currUrl = window.location.href.toLowerCase();
    var arr_url = currUrl.split("/sys");
    rootUrl = arr_url[0];
}

function CBodyHtml() {
     //基础设置与自定义页面
     CBodyHtml_BaseAndUserDefinedSetting();        
}

//基础设置与自定义页面导航
function CBodyHtml_BaseAndUserDefinedSetting() {
    var html = new Array();
    var data = SHome.Data;
    var linkV = 0;
    var linkhref = "";
    html.push("<div class='lnkgp_nav'>");
    html.push("<div class='lnkgp_hidden' style='height:10px;width:100%;'></div>");
    if(data.groups.length>0){
    	for (var i = 0; i < data.groups.length; i++) {
	        var gp = data.groups[i];
	        html.push("<div class='lnkgp_cont'>");
	        html.push("<div class='lnkgpheader' " + (window.SysConfig.SystemType==3?"style='background:#f5f5f5;border:1px solid #dcdcdc'":"") + ">");
            html.push("<div class='group-title' " + (window.SysConfig.SystemType == 3 ? "style='color:#333'" : "") + ">" + gp.name + "</div>");
            html.push("<div class='group-fold'><img class='bill_group_eximg' id='bill_group_eximg_" + i + "' height='15' chang_flod='true' onclick='foldGroup(this)' title='点击折叠' src='" + window.SysConfig.VirPath + (window.SysConfig.SystemType == 3 ? "SYSA/skin/default/images/MoZihometop/content/r_down.png'" : "SYSA/images/r_down.png'") + "></div>");
	        html.push("</div>");
	        if(gp.links.length>0){
	            html.push("<div class='lnkgplnks' "+(window.SysConfig.SystemType==3?"style='border:1px solid #dcdcdc;border-top:0px;'":"")+">")
		        for (var iii = 0; iii < gp.links.length; iii++) {
		            linkhref = "";
		            var lnk = gp.links[iii];
		            if (lnk.url) {
		                linkhref = lnk.url;
		            }
		            html.push("<div class='lnk'>");
		            if (linkhref != "") {
		                html.push("<a href='javascript:;' onclick='javascript:app.OpenUrl(\"" + rootUrl + linkhref + "\",\"" + i + "_" + menusindex + "_" + iii + "\")'>" + lnk.title + "</a>");
		            } else {
		                html.push(lnk.title);
		            }
		            html.push("</div>");
		        }
		        html.push("</div>"); 
	        }
	        html.push("</div>");     
	    }
    }
    html.push("</div>");
    document.write(html.join(""));
}

function BindOnResize(){
	var _w = $('#comm_itembarbg').width();
	$('.lnkgp_hidden').css("display","none")
	$('.lnkgp_cont').css({"width":_w-20,"margin-top":10,"margin-left":10});
}

$(window).on("resize",BindOnResize);


function openStatWin(url,sign) {
    window.open(url, 'newstat' + sign + 'win', 'width=' + 1000 + ',height=' + 700 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')
}

//单据折叠
function foldGroup(box) {
    var c = 1;
    if (box.src.indexOf("r_down.png") > 0) {
        box.src = box.src.replace("r_down.png", "r_up.png");
        box.title = "点击展开";
        c = 1;
    } else {
        box.src = box.src.replace("r_up.png", "r_down.png");
        box.title = "点击折叠";
        c = 2;
    }
    var h = box.parentNode.parentNode;
   	var cont = $(h).next('.lnkgplnks');
   	if(c == 1){
   		$(cont).css("display","none");
   	}else{
   		$(cont).css("display","block");
   	}
};

window.createPage = function () {
    SHome.Data = window.PageInitParams[0];
    menusindex = SHome.Data.menusindex || 0;
    CHeaderHtml();
    CBodyHtml();
    BindOnResize();
}