var SHome = new Object;
var menusindex;
var rootUrl;

function CHeaderHtml() {
    var html = new Array();    
	html.push("<div class='HeadBg'>&nbsp;</div>");
	html.push("<div class='HeadTabCaption'><a href='default.ashx'>" + SHome.Data.title + "</a> > " + SHome.Data.description + "</div>");
	CSearchBarHTML(html);
	document.write(html.join(""));

	var currUrl = window.location.href.toLowerCase();
	var arr_url = currUrl.split("/sys");
	rootUrl = arr_url[0];
}


function CBodyHtml() {    
	switch (menusindex){
	    case 0:
	        CBodyHtml_TotalNavigation();
	        break;
	    case 1:
	        CBodyHtml_TotalNavigation();
	        break;
	}
	
}



//统计报表总导航
function CBodyHtml_TotalNavigation() {
    var html = new Array();
    var data = SHome.Data;
    var linkV = 0;
    var linkhref = "";    
    html.push("<div style='height:5px'></div>");
    html.push("<div id='linkbody' style='width:900px;margin:0 auto'>");
    for (var i = 0; i < data.groups.length; i++) {
        var gp = data.groups[i];
        html.push("<div class='lnkgp_nav'>");        
        html.push("<div class='lnkgptit" + (i == (data.groups.length - 1) ? "last" : "") + "_nav'><a href='javascript:void(0)' id='" + gp.name + "' isgroupobj=1 ></a>" + gp.name + "</div>");
        //html.push("<div class='lnkgpspliter'>&nbsp;</div>");
        if (gp.groups){
            for (var ii = 0; ii < gp.groups.length; ii++) {
                var gp2 = gp.groups[ii];
                //html.push("<div class='lnkgpspliter'>&nbsp;</div>");            
                if (gp2.links.length % 5 == 0) {
                    linkV = gp2.links.length / 5;
                } else {
                    linkV = gp2.links.length / 5 + 1;
                }
                html.push("<div class='lnkgplnks' >");
                for (var iii = 0; iii < gp2.links.length; iii++) {
                    linkhref = "";
                    var lnk = gp2.links[iii];
                    if (lnk.url) {
                        linkhref = lnk.url;
                    }                
                   
                    if (linkhref == "object:controltable") {
                    	html.push("<div class='objectdiv'>");
                    	LoadControlTable(html);  //加载控制台
                    }
                    else if (linkhref == "object:moneychart") {
                    	html.push("<div class='objectdiv'>");
                    	LoadMoneyChart(html);  //加载控制台
                    }
                    else if (linkhref != "") {
                    	html.push("<div class='lnk'>");
                    	html.push("<a href='javascript:openStatWin(\"" + rootUrl + linkhref + "\")'>" + lnk.title + "</a>");
                    } else {
                    	html.push("<div class='lnk'>");
                    	html.push(lnk.title);
                    }
                    html.push("</div>");
                }            
                html.push("</div>");
            }
        }
        html.push("<div class='lnkgpspliter'>&nbsp;</div>");
        html.push("</div>");
    }
    html.push("<div class='lnkgpspliter'>&nbsp;</div>")
    html.push("</div>");
    document.write(html.join(""));
}

function LoadMoneyChart(htm) {
	var d1 = (new Date());
	var d1str = d1.getFullYear() + "-" + (d1.getMonth() >9 ? "" : "0") + (d1.getMonth() + 1) + "-01";
	var d2str = d1.getFullYear() + "-" + (d1.getMonth() >9 ? "" : "0") + (d1.getMonth() + 1) + "-" + (d1.getDate()>10?"":"0") + d1.getDate();
	htm.push("<div class='mchartsearchbar'><div style='float:right'>");
	htm.push("<div class='seritem pointer' onclick='gomonth(\"mc\",-1)'>上一月</div>");
	htm.push("<div class='seritem'><input value='" + d1str + "' id='mc_d1' onchange='return LoadMoneyChartData()'><img class='pointer' src='../../skin/default/img/dateico.gif' onclick='datedlg.show()'></div>");
	htm.push("<div class='seritem' style='border:0px;background-color:white;cursor:default'>至</div>");
	htm.push("<div class='seritem'><input value='" + d2str + "' id='mc_d2' onchange='return LoadMoneyChartData()'><img class='pointer' src='../../skin/default/img/dateico.gif' onclick='datedlg.show()'></div>");
	htm.push("<div class='seritem pointer' onclick='gomonth(\"mc\",1)'>下一月</div>");
	htm.push("<div class='seritem pointer' id='mc_mtlist' onclick='showmcmList(this)'>一键检索 <span><img src='../../../SYSA/images/i10.gif' style='margin-top:-2px'></span></div>");
	htm.push("</div></div>");
	htm.push("<div class='moneychartbody'>");
	htm.push("<img id='moneychartImg'>");
	htm.push("<div id='moneyinv'></div>");
	htm.push("<div id='line1'>&nbsp;</div>");
	htm.push("<div id='line2'>&nbsp;</div>");
	htm.push("<div id='linelabel1'></div>");
	htm.push("<div id='linelabel2'></div>");
	htm.push("</div>");
	setTimeout(function () {
		LoadMoneyChartData();
	}, 10);
}

function LoadMoneyChartData() {
	var d1 = new Date($ID("mc_d1").value.replace("-","/").replace("-","/"));
	var d2 = new Date($ID("mc_d2").value.replace("-","/").replace("-","/"));
	var dt  = ((d2-d1)/1000/3600/24);
	if(dt>10*365) { 
		if(window.oldchatd1) { $ID("mc_d1").value =  window.oldchatd1; }
		if(window.oldchatd2) { $ID("mc_d2").value =  window.oldchatd2; }
		alert("显示的数据最多不能超过10年"); 
		return false;
	}
	window.oldchatd1 = $ID("mc_d1").value;
	window.oldchatd2 = $ID("mc_d2").value;
	app.ajax.GetResult("../../../SYSA/tongji/cash_y.asp?ret=" + $ID("mc_d1").value + "&ret2=" + $ID("mc_d2").value + "&datatype=json", null, function (r) {
		var arr = eval("(" + r + ")");
		var img = $ID("moneychartImg");
		img.src = "MnyChartImg.ashx?v1=" + arr[1] + "&v2=" + arr[2];
		var arr2 = arr[2];
		arr[2] = Math.abs(arr[2]);
		var linkhtml = "<a href='javascript:openStatWin(\"../../../SYSA/tongji/cash_y.asp?ret=" + $ID("mc_d1").value + "&ret2=" + $ID("mc_d2").value + "\")'>"
		$ID("moneyinv").innerHTML = "收入<br>" + linkhtml + "<span class='mnychartnum'>" + arr[0] + "</span></a>";
		var sm = arr[1] * 1 + arr[2] * 1;
		var btop = img.offsetTop;
		var bleft = img.offsetLeft;
		var bheight =img.offsetHeight;
		var top1 = parseInt(arr[1] * bheight / sm / 2 + btop) || btop;
		var top2 = parseInt(btop + (arr[1] * bheight / sm) + (arr[2] * bheight / sm / 2)) || (btop + bheight);
		var a = bleft + bheight / 2, b = btop + bheight / 2;
		var r = bheight / 2;
		var left1 = parseInt(Math.pow((r * r - Math.pow(top1 - b, 2)), 0.5) + a) || parseInt(bleft + bheight / 2);
		var left2 = parseInt(Math.pow((r * r - Math.pow(top2 - b, 2)), 0.5) + a) || parseInt(bleft + bheight / 2) ;
		var w1 = bleft + bheight + 60 - left1;
		var w2 = bleft + bheight + 60 - left2;
		$ID("line1").style.cssText = "display:block;top:" + top1 + "px;left:" + left1 + "px;width:" + w1 +"px;border-top:1px solid #bbb;height:1px;overflow:hidden";
		$ID("line2").style.cssText = "display:block;top:" + top2 + "px;left:" + left2 + "px;width:" + w2 + "px;border-top:1px solid #bbb;height:1px;overflow:hidden";
		$ID("linelabel1").style.cssText = "display:block;top:" + (top1-10) + "px;left:" + (bleft + bheight + 63) + "px;";
		$ID("linelabel2").style.cssText = "display:block;top:" + (top2-10) + "px;left:" + (bleft + bheight + 63) + "px;";
		$ID("linelabel1").innerHTML = "支出：" + linkhtml + "<span class='mnychartnum'>" + arr[1] + "</span></a>";
		$ID("linelabel2").innerHTML = "结余：" + linkhtml + "<span class='mnychartnum'>" + arr2 + "</span></a>";
	});
	return true;
}

function mcmListClick(e) {
	if(e.target.getAttribute("ov")==1){
		return;
	}
	if ($ID("mc_mtlist_list")) {
		document.body.removeChild($ID("mc_mtlist_list"));
	}
}

function showmcmList(box) {
	var div = document.getElementById( box.id + "_list");
	if (!div) {
		div = document.createElement("div");
		div.id = (box.id + "_list");
		div.innerHTML = "<div ov=1 onmouseover='this.className=\"sell\"' onmouseout='this.className=\"\"' onclick='mc_ct_ck(0)'>最近三天</div>"
					+ "<div ov=1 onmouseover='this.className=\"sell\"' onmouseout='this.className=\"\"' onclick='mc_ct_ck(1)'>最近一周</div>"
					+ "<div ov=1 onmouseover='this.className=\"sell\"' onmouseout='this.className=\"\"' onclick='mc_ct_ck(2)'>最近一月</div>";
		document.body.appendChild(div);
	}
	var rc = box.getBoundingClientRect();
	var t = $(box).offset().top;
	div.style.cssText = "left:" + rc.left + "px;top:" + (t + box.offsetHeight + 2) + "px;";
	$(document).unbind("mousedown", mcmListClick).bind("mousedown", mcmListClick);
}

function addDate(date, days) {
	var d = new Date(date);
	d.setDate(d.getDate() + days);
	var m = d.getMonth() + 1;
	return new Date(d.getFullYear() + '/' + m + '/' + d.getDate());
}

function mc_ct_ck(t) {
	document.body.removeChild($ID("mc_mtlist_list"));
	var d2 = new Date();
	var d1 = addDate(d2, -(t == 0 ? 3 : (t == 1 ? 7 : 30)));
	var d1str = d1.getFullYear() + "-" + (d1.getMonth() > 9 ? "" : "0") + (d1.getMonth() + 1) + "-" + (d1.getDate() > 10 ? "" : "0") + d1.getDate();
	var d2str = d2.getFullYear() + "-" + (d2.getMonth() > 9 ? "" : "0") + (d2.getMonth() + 1) + "-" + (d2.getDate() > 10 ? "" : "0") + d2.getDate();
	$ID("mc_d1").value = d1str;
	$ID("mc_d2").value = d2str;
	LoadMoneyChartData();
}

function gomonth(idsgn, t) {
	var d1 = $ID(idsgn + "_d1");
	var d2 = $ID(idsgn + "_d2");
	var d0 = new Date(d1.value.replace("-", "/"));
	var d0_y = d0.getFullYear();
	var d0_m = d0.getMonth() + 1;
	var d0_d = d0.getDate();
	var nd1, nd2, nd2d;
	d0_m = d0_m + t;
	if (d0_m == 0) { d0_m = 12; d0_y--; }
	if (d0_m == 13) { d0_m = 1; d0_y++; }
	if (d0_m == 1 || d0_m == 3 || d0_m == 5 || d0_m == 7 || d0_m == 8 || d0_m == 10 || d0_m == 12) {
		nd2d = 31;
	} else if (d0_m == 4 || d0_m == 6 || d0_m == 9 || d0_m == 11) {
		nd2d = 30;
	} else {
		nd2d = (d0_y % 400 == 0 || d0_y % 4 == 0 && d0_y % 100!= 0) ? 29 : 28;
	}
	nd1 = d0_y + "-" + (d0_m >9 ? "" : "0") + d0_m + "-01";
	nd2 = d0_y + "-" + (d0_m > 9 ? "" : "0") + d0_m + "-" + nd2d;
	$ID(idsgn + "_d1").value = nd1;
	$ID(idsgn + "_d2").value = nd2;
	LoadMoneyChartData();
}

function LoadControlTable(htm) {
	var data = window.ControlTable;
	var cols0 = [], cols1 = [];
	var h1 = false, h2 = false;
	if (data.length == 0) { return; }
	for(var i = 0;  i<data.length; i++ ){
		if( data[i][0]==0){
			cols0.push(data[i]);
		}else{
			cols1.push(data[i]);
		}
	}
	htm.push("<table class='controltable'><tr>");
	if (cols0.length > 0) { h1 = true; htm.push("<th>分类</th><th>本月统计</th><th>上月同期</th><th>比较</th>"); }
	if (cols1.length > 0) { h2 = true; htm.push("<th>分类</th><th>本月统计</th><th>上月同期</th><th>比较</th>"); }
	htm.push("</tr>");
	for (var i = 0; i < (cols0.length > cols1.length ? cols0.length : cols1.length) ; i++) {
		htm.push("<tr>");
		if (h1) {
			showControlTableItem(htm,cols0[i]);
		}
		if (h2) {
			showControlTableItem(htm,cols1[i]);
		}
		htm.push("</tr>");
	}
	htm.push("</table>");
}

Number.prototype.toFixedCZ = function (bit) {
	if (this == 0) { return "<span class=zore>" + (0).toFixed(bit) + "</span>"; }
	return this.toFixed(bit);
}

function showControlTableItem(htm, coldata) {
	if (coldata) {
		var v1 = coldata[2];
		var v2 = coldata[3];
		var n = coldata[4];
		var v3 = v1 > v2 ? ("<span style='color:red'>↑</span>" + (v1 - v2).toFixedCZ(n)) : (v1 < v2 ? ("<span style='color:#990000'>↓</span>" + (v1 - v2).toFixedCZ(n)) : (0).toFixedCZ(n));
		htm.push("<td class='ct_label'>" + coldata[1] + "</td><td>" + v1.toFixedCZ(n) + "</td><td>" + v2.toFixedCZ(n) + "</td><td>" + v3 + "</td>");
	} else {
		htm.push("<td class='ct_label'>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>");
	}
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
}


function openStatWin(url){
	window.open(url,'newstat'+(Math.round(Math.random()*100))+'win','width=' + 1000 + ',height=' + 700 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')
}
