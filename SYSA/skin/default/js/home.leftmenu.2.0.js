var skin ="default";
var pic = new Image();
pic.src="../skin/" +  skin + "/images/btn_left_top.gif";
window.lastMenuVistId = "ccc"
window.mainpageload = 0;   //左侧导航是否加载完成
function body_load(){
	//if(app.IeVer==6) {window.onresize();}
	try{
		if(document.getElementById("firstTab"))
		{
			app.fireEvent(document.getElementById("firstTab"),"onmousedown");
		}
	} catch(e){}
	window.mainpageload = 1;
	if(window.location.href.indexOf("aPower=1")>0) {
		$ID("menu_bodyFrame").className = "aPower";
	}
	if (top.SysConfig && top.SysConfig.IsDebugModel == true) {
		window.loadSearchFun();
	}
}

//显示.隐藏左侧导航菜单
function toggleMenu()
{
  var frmBody = parent.document.getElementById('frame-body');
  var imgArrow = document.getElementById('img');
  var imgArrow2 = parent.document.getElementById('spliter').contentWindow.document.getElementById('img');
  var width = frmBody.rows[0].cells[0].style.width.replace("px");
  if (width=="0")
  {
    frmBody.rows[0].cells[0].style.width="200px";
    imgArrow.src = skin + "/images/btn_left_top.gif";
	imgArrow2.src = skin + "/images/btn_left.gif";
  }
  else
  {
    frmBody.rows[0].cells[0].style.width="0px";
    imgArrow.src = skin + "/images/btn_left_top.gif";
	imgArrow2.src = skin + "/images/btn_right.gif";
  }
}


//鼠标移动替换图标
function MM_SwapGif(img){
	img.src = img.src.indexOf("s.gif")>0 ? img.src.replace("s.gif",".gif") : img.src.replace(".gif","s.gif"); 
}

//选项卡选择
window.setTab = function(id) {
	try{parent.setChildMenuFrame(0);}catch(ex){}
	var tb = document.getElementById("mt_" + id);
	var obj = window.event.srcElement;
	if(obj.parentNode.rowIndex==2)
	{
		var x = window.event.offsetX;
		var y = window.event.offsetY;
		var w =  obj.offsetWidth;
		var h = obj.offsetHeight;
		if(x<y && (x <w && y <h)) 
		{	
			//再右下角点击，触发下一个选项卡点击事件
			var obj = tb.nextSibling;
			if(obj)
			{
				app.fireEvent(obj.rows[1].cells[0],"onmousedown");
			}
			return;
		}
	}
	var tbs = tb.parentNode.children;
	for (var i = 0; i < tbs.length ;i++ )
	{
		var item =  tbs[i];
		if(item.style.zIndex>=1000)
		{
			if (item != tb)
			{
				item.style.zIndex = item.getAttribute("oindex");
				item.className = "menuitem";
			}
		}
	}
	tb.style.zIndex = 1000;
	tb.className = "menuitemSel";

	document.getElementById("treebg" + id).style.display = "block";
	try{document.getElementById("treebg" + id).style.zoom = "1"}catch(e){} //防止IE7样式出现错误
	if(window.preActivetb) {
		if(window.preActivetb!=document.getElementById("treebg" + id))
		{
			window.preActivetb.style.display = "none";
		}
	}
	window.preActivetb = document.getElementById("treebg" + id);
	if (window.DisGotoChildrenUrl == true) {  //此标记用于防止内容页打开左侧导航，反过来被二级首页冲掉（案例参见右上角设置页面）
		window.DisGotoChildrenUrl = false;
		return;
	}
	if(parent.frames["mainFrame"])
	{
		var key = tb.innerText.replace(/\n/g,"").replace(/\r/g,"");
		if("销售,营销,库存,财务,办公,人资,生产,参数设置".indexOf(key) >= 0)
		{
			if(window.mainpageload==1)
			{
				//加载完成以后才能做2级导航跳转
				var setMsg = top.document.getElementById("sd0003");
				if(!setMsg || setMsg.style.display!="block") 
				{
				   parent.frames["mainFrame"].location.href = "childhome.asp?key=" + escape(key);
				}
			}
		}else if (key=="统计"){
			if(window.mainpageload==1)
			{
				//加载完成以后才能做2级导航跳转
				var setMsg = top.document.getElementById("sd0003");
				if(!setMsg || setMsg.style.display!="block") 
				{
				   parent.frames["mainFrame"].location.href = "../../SYSN/view/Statistics/default.ashx";
				}
			}
		}
	}
}


//选项页选择
window.cMenuPag = function (index)
{
	var ids = "0,1,2".split(",");
	if(index == window.oldmenuPageId) { return; }
	window.oldmenuPageId = index;
	var bg1 = document.getElementById("tabpage1");
	var bg2 = document.getElementById("tabpage2");
	var bg3 = document.getElementById("tabpage3");
	if(bg1){ bg1.style.display = (index == 0 ? "block" : "none"); }
	if(bg2){ bg2.style.display = (index == 1 ? "block" : "none"); }
	if(bg3){ bg3.style.display = (index == 2 ? "block" : "none"); }
	var bg = (index == 0 ? bg1 : (index==1 ? bg2 : null));
	if(bg){ setFocusTabItem(bg); }
	document.getElementById("MenuPage0").style.display = (index==0 ? "block" : "none")
	document.getElementById("MenuPage1").style.display = (index==1 ? "block" : "none")
	document.getElementById("MenuPage2").style.display = (index==2 ? "block" : "none")
	window.lastMenuVistId = -index;
	if(window.mainpageload==0) {
		window.mainpageload==1
	}
}

function closeLoadProc()
{
	if(parent.closeproc) {
		try{ parent.closeproc();} catch(e) { }
		parent.closeproc = function() {}
	}
}

function setFocusTabItem(box)
{
	var fid = "";
	var hsfocus = false;
	for (var i = 0 ; i < box.children.length ; i++)
	{
		var item = box.children[i];
		fid = (fid.length == 0 ? item.id : fid);
		if(item.className.toLowerCase().indexOf("sel")>=0)
		{
			hsfocus = true;
			app.fireEvent(item.rows[1].cells[0],"onmousedown");
			return ;
		}
	}
	if(hsfocus==false && fid.length > 0)
	{
		var item = document.getElementById(fid).rows[1].cells[0];
		app.fireEvent(item,"onmousedown");
	}
}

tvw.onitemclick = function(a) {
	var url = a.value.split("\1");
	if(a.value=="@menu2link") {
			//显示二级导航
			var id = a.srcElement.parentNode.parentNode.id.replace("_n","_bg");
			var div = document.getElementById(id);
			if(parent.setChildMenuFrame) {
					parent.setChildMenuFrame(1, a.text, div.outerHTML);
			}
			return;
	}
	if(url[0].length==0) {
		return false;
	}
	if(top.LeftMenuFun) {
		var t = a.text.replace("<span","<SPAN");
		top.LeftMenuFun(t.split("<S")[0],url[0],url[1]);
		return false;
	}
	switch(url[1].toLowerCase()){
		case "超链接":
			window.open(url[0]);
			//if(app.IeVer<8) {setTimeout(function(){window.open(url[0])},10);}  //加定时器防止闪屏
			//else{window.open(url[0]);}
			break;
	    case "js":
	        var winnameArr = url[0].split("?")[0].split("/");
	        var winname = winnameArr[winnameArr.length - 1].replace(".", "");
	        app.PageOpen(url[0], screen.availWidth * 0.96, screen.availHeight * 0.90, 'sadfsdd' + winname);
			//if(app.IeVer<8) {setTimeout(function(){app.PageOpen(url[0],screen.availWidth*0.96,screen.availHeight*0.90,'sadfsdd');},10);}
			//else{app.PageOpen(url[0],screen.availWidth*0.96,screen.availHeight*0.90,'sadfsdd');}
			break;
		default:
			parent.frames[2].location.href = url[0];
			var bodyFrame = top.document.getElementById("frmbody");	
			if(parent.setChildMenuFrame && window.location.href.toLowerCase().indexOf("btn-border.asp")==-1) { 
				//隐藏二级导航
				parent.setChildMenuFrame(0);
			}
	}
	if (window.lastMenuVistId != url[2]) {
		window.lastMenuVistId = url[2];
		saveMenuHistory();
	}
}

function mylistclick(div){
	app.fireEvent(div.parentNode,"onclick");
}

//添加我的导航
function addMyMenu(id, obj) {
	if(!obj){obj = window.event.srcElement;}
	obj = obj.parentNode;
	var value = obj.getAttribute("value");
	var txt = obj.innerText.replace("≌","");
	var value = value.split("\1");
	var div = top.app.createWindow("addmymen","<span style='position:relative;left:-20px'>加入我的导航</span>","s.gif",(window.event.clientX+5),(window.event.clientY+50),280,210,0,0)
	var url = ajax.url;
	ajax.url = url.toLowerCase().replace("btn-border.asp","menu.asp");
	ajax.regEvent("addMyMenu")
	ajax.addParam("url",value[0]);
	ajax.addParam("otype",value[1]);
	ajax.addParam("menuId", id);
	ajax.addParam("title",txt);
	div.innerHTML = ajax.send();
	ajax.url = url;
	return false;
}

function dh_top(tag, id) {
    var url = "../china/cu_dh_top.asp?id=" + id + "&id2=" + tag + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    ajax.regEvent("", url);
    var r = ajax.send();
    window.onMyMenuUpdate();
}

function dh_down(tag, id) {
    var url = "../china/cu_dh_down.asp?id=" + id + "&id2=" + tag + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    ajax.regEvent("", url);
    var r = ajax.send();
    window.onMyMenuUpdate();
}
//删除我的导航
function delMyMenu(tag,id)
{
	var t = tag.parentNode.innerText.replace("×","").replace("↓","").replace("↑","");
	if(window.confirm("确定要删除导航菜单 “"  + t + "” 吗？"))
	{
		ajax.regEvent("delMyMenu");
		ajax.addParam("id", id);
		var r =  ajax.send();
		if (r.replace(/\s/g,"")=="ok")
		{
			window.onMyMenuUpdate();
		}
		else{
			alert("删除导航菜单失败.",r);
		}
	}
}

//局部刷新我的导航区域
window.onMyMenuUpdate = function()
{
	ajax.regEvent("myMenuList")
	document.getElementById("MenuPage2").innerHTML = ajax.send();
}

function _so(id) {
    var span = window.event.srcElement;
    $(span).bind('click', function (event) {
        event.stopPropagation();
    });
	if(span.title.length > 0 )
	{
		return;
	}
	span.title = '加入我的导航';
	if(span.attachEvent){ span.attachEvent("onmousedown",function() {return addMyMenu(id,span)});}
	else { span.addEventListener("mousedown", function () { return addMyMenu(id, span) }, false); }

}

function saveMenuHistory()
{
	if(window.lastMenuVistId && window.lastMenuVistId!="ccc")
	{
		var ax = new xmlHttp();
		ax.url = "SaveFocusItem.asp"
		ax.regEvent("SaveFocusItem");
		ax.addParam("vistMenu", window.lastMenuVistId);
		ax.send(function () { });
		var ax = null;
	}
}
top.saveMenuHistory = this.saveMenuHistory;
tvw.canrepeatClick = true
window.onerror = function(){return true;};

$(function(){
    $("div.treeRoot a").bind("click", function () { parent.setChildMenuFrame(0); })
})

$(window).resize(function(){
	setTimeout(function(){
		if(parent && parent.ywtest){
			parent.ywtest();
		}
	},10);
})


window.loadSearchFun = function () {
	var topmenbar = $ID("m-title");
	var childrens = topmenbar.children;
	$("<div class='lm_im'>&nbsp;</div><div class='lm_search' onclick='window.showsearchDiv()'>🔍</div>").insertBefore(childrens[childrens.length - 1]);
}

window.showsearchDiv = function () {
	var div1 = document.getElementById("searchdiv1");
	if (!div1) {
		div1 = document.createElement("div");
		div1.id = "searchdiv1";
		document.body.appendChild(div1);
	}
	div1.style.cssText = "background-color:#eef4ff;position:absolute;top:43px;left:6px;right:2px;border:0px solid #aaa;z-index:100000;bottom:5px;";
	div1.innerHTML = "<div style='padding:16px;'><div>菜单搜索：<a style='float:right;margin-right:20px;color:red' href='javascript:void(0)' onclick='closesearchmenu()'>关闭</a></div>"
						+ "<div><input type='text' style='width:95%'  onkeyup='dosearchlist(this.value)'></div>"
						+ "<div id='searchlist' style='height:" + (div1.offsetHeight - 80) + "px;overflow:auto'></div>"
						+ "</div>";
}

window.closesearchmenu = function () {
	$("#searchdiv1").remove();
}


window.dosearchlist = function (searchkey) {
	window.currMenuSearchKey = searchkey;
	if (window.exechwnd) { window.clearTimeout(window.exechwnd); }
	window.exechwnd = setTimeout(window.dosearchlistExec, 500);
}
window.dosearchlistExec = function () {
	var searchkey = window.currMenuSearchKey;
	var links = $("a.tvw_txt");
	var lnks = [];
	for (var i = 0; i < links.length; i++) {
		if (searchkey.length > 0 && links[i].innerText.indexOf(searchkey) >= 0) {
			var lnk = links[i];
			var url = (lnk.getAttribute("value") + "").split("\1")[0];
			if (url) {
				lnks.push("<a href='" + url + "' style='color:#333388' target='mainFrame'>" + lnk.innerText.replace("≌","") + "</a>");
			}
		}
	}
	var jsons = $("div[datajosn]");
	for (var i = 0; i<jsons.length; i++) {
		try {
			var jarr = eval("(" + jsons[i].getAttribute("datajosn") + ")");
			window.fillSearchList(lnks, jarr, searchkey);
		} catch (ex) { }
	}
	$ID("searchlist").innerHTML = "<li>" + lnks.join("</li><li>") + "</li>";
}

window.fillSearchList = function (lnks, arrs, searckey) {
	try {
		if (searckey.length == 0) { return; }
		for (var i = 0; i < arrs.length; i++) {
			var nd = arrs[i];
			if (nd.nodes == 0) {
				if (nd.text.indexOf(searckey) >= 0 && nd.value.length > 0) {
					lnks.push("<a style='color:#333388' href='" + nd.value.split("\1")[0] + "' target='mainFrame'>" + nd.text.replace("≌", "") + "</a>");
				}
			} else {
				window.fillSearchList(lnks, nd.nodeobjs, searckey);
			}
		}
	} catch (ex) { }
}