function CSearchBarHTML(html) {
	html.push("<div id='clssearchbar'>");
	html.push("<div id='clssearchbarLabel'><span id='clssearchbarLabelT'>" + (SHome.Data.searchcls || SHome.Data.searchs[0]) + "</span> <img onclick='showclslist()' style='cursor:pointer;position:relative;top:-1px' src='" + (window.SysConfig.SystemType != 3 ? "../../../SYSA/images/i10.gif" : "../../../SYSA/skin/default/images/MoZihometop/content/r_down.png") + "' style='margin-top:-2px'>&nbsp;</div>");
	html.push("<div id='clssearchbarbox'><input id='clssrcbox'  value=\"" + (SHome.Data.searchkey || "").replace(/\"/g,"") + "\" onmousemove='setPointer(this, event)' onclick='if(this.style.cursor==\"pointer\"){gotoSearch(this)}'  onkeydown='if(event.keyCode==13){gotoSearch(this);}'></div>");
	html.push("<div id='clssearchbarlist'>");
	for (var i = 0; i < SHome.Data.searchs.length; i++) {
		html.push("<div  onclick='setsearchcls(this)' onmouseover='this.className=\"sell\"' onmouseout='this.className=\"\"'>" + SHome.Data.searchs[i] + "</div>");
	}
	html.push("</div>");
	html.push("</div>");
}

function gotoSearch(box) {
	var keyv = $ID("clssrcbox").value;
	keyv = keyv.replace(/\s/g,"").replace(/\r/g,"").replace(/\n/g,"");
	if(keyv.length==0) { alert("请输入要检索的导航关键字"); return false;}
	window.location.href = "default.ashx?MenuIndex=100&cls=" + $ID("clssearchbarLabelT").innerHTML + "&key=" + keyv;
}

function showclslist() {
	$ID("clssearchbarlist").style.display = "block";
}

function setPointer(box, e) {
	var r = box.getBoundingClientRect();
	box.style.cursor = (e.clientX > r.left + box.offsetWidth - 16) ? "pointer" : "text";
}

function setsearchcls(box) {
	$ID("clssearchbarlist").style.display = "none";
	$ID("clssearchbarLabelT").innerHTML = box.innerHTML;
}

function ViewScrollTo(boxid) {
    if (!boxid) { return; }
    var box = document.getElementById(boxid);
    if (!box) { return;}
	window.scrollTo(0, parseInt($(box).offset().top));
	//document.body.scrollTop =parseInt(t) + "px";
}

$(function () {
	var html = new Array();
	var links = document.getElementsByTagName("a");
	var x = 0;
	for (var i = 0; i < links.length; i++) {
		var lnk = links[i];
		if (lnk.getAttribute("isgroupobj") == 1) {
			if (x> 0) { html.push("<div class='splkitem'>&nbsp;</div>"); }
			var nm = lnk.id;
			var nmt = nm;
			if (nmt.length >= 5) {
				nmt = nmt.replace("栏目统计", "");
				nmt = nmt.replace("供应商", "");
			}
			html.push("<div class='item' onmouseover='this.className=\"itemsel\"' onmouseout='this.className=\"item\"'><a class='itemgrplnk' href='javascript:void(0)' onclick='ViewScrollTo(\"" + nm + "\")'>" + nmt + "</a></div>");
			x++;
		}
	}
	if (x == 0) { return; }
	var div = document.createElement("div");
	div.innerHTML = html.join("");
	div.id = "menugrouplink";
	document.body.appendChild(div);
})

window.onload = function () {
    var id = decodeURI(window.location.search).split('id=')[1];
    ViewScrollTo(id)
}