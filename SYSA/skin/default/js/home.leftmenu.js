var skin = document.getElementById("cssskin").value;
var pic = new Image();
pic.src="../skin/" +  skin + "/images/btn_left_top.gif";

function toggleMenu()
{
  var frmBody = parent.document.getElementById('frame-body');
  var imgArrow = document.getElementById('img');
  var imgArrow2 = parent.document.getElementById('spliter').contentWindow.document.getElementById('img');

  if (frmBody.cols=="0,5,*")
  {
    frmBody.cols="190,5,*";
    imgArrow.src="../skin/" +  skin + "/images/btn_left_top.gif";
	imgArrow2.src="../skin/" +  skin + "/images/btn_left.gif";
  }
  else
  {
    frmBody.cols="0,5,*";
    imgArrow.src="../skin/" +  skin + "/images/btn_left_top.gif";
	imgArrow2.src="../skin/" +  skin + "/images/btn_right.gif";
  }
}


var Browser = new Object();

Browser.isMozilla = (typeof document.implementation != 'undefined') && (typeof document.implementation.createDocument != 'undefined') && (typeof HTMLDocument != 'undefined');
Browser.isIE = window.ActiveXObject ? true : false;
Browser.isFirefox = (navigator.userAgent.toLowerCase().indexOf("firefox") != - 1);
Browser.isSafari = (navigator.userAgent.toLowerCase().indexOf("safari") != - 1);
Browser.isOpera = (navigator.userAgent.toLowerCase().indexOf("opera") != - 1);

var Utils = new Object();

Utils.fixEvent = function(e)
{
  var evt = (typeof e == "undefined") ? window.event : e;
  return evt;
}

function MM_SwapGif(img){
	img.src = img.src.indexOf("s.gif")>0 ? img.src.replace("s.gif",".gif") : img.src.replace(".gif","s.gif"); 
}

var oldmenuId = 0;
function cMenuTab(id) {
	var ids = "0,1,2".split(",");
	for(var i=0;i<ids.length;i++) 
	{
		if(id==ids[i])
		{
			document.getElementById("mtop_p" + ids[i]).style.display = "block";
			document.getElementById("mtop_t" + ids[i]).style.display = "none";
			document.getElementById("mtop_s" + ids[i]).style.display = "block";
		}
		else
		{
			document.getElementById("mtop_p" + ids[i]).style.display = "none";
			document.getElementById("mtop_t" + ids[i]).style.display = "block";
			document.getElementById("mtop_s" + ids[i]).style.display = "none";
		}
	}
	if(id == oldmenuId) { return; }
	var mlbar = document.getElementById("menu_leftFrame");
	var firstbar = document.getElementById("firstTab");
	mlbar.setAttribute("html" + oldmenuId,mlbar.innerHTML);
	oldmenuId = id;
	var html = mlbar.getAttribute("html" + id);
	if(!html) {
		ajax.regEvent("cBtn")
		ajax.addParam("type",id)
		var r = ajax.send();
		mlbar.innerHTML = r;
		if(id<2){
			app.fireEvent(document.getElementById("firstTab"),"onmousedown");
		}
		else{
			addMyMenuTree();
		}
	}
	else{
		mlbar.innerHTML = html;
		var tbs = mlbar.getElementsByTagName("table")
		for (var i = 0 ; i < tbs.length ; i++ )
		{
			if(tbs[i].style.zIndex>=1000) {
				tbs[i].setAttribute("doRepeat",1);
				var cell = tbs[i].rows[1].cells[0];
				app.fireEvent(cell,"onmousedown");
				tbs[i].setAttribute("doRepeat",0);
				break;
			}
		}
		if(id==2){
			addMyMenuTree();
		}
	}
}

function addMyMenuTree()
{
	var treePanel = document.getElementById("menu_mainFrame");
	var currhtmlid = treePanel.getAttribute("currhtmlId"); //当前内容id号
	if(currhtmlid) { treePanel.setAttribute("html_" + currhtmlid, treePanel.innerHTML) };  //如果存在id号，则页面缓存html内容，增加显示速度
	var html = treePanel.getAttribute("html_mymenu");
	if(!html){
		ajax.regEvent("myMenuList")
		html = ajax.send();
	}
	treePanel.innerHTML = html;
	treePanel.setAttribute("currhtmlId","mymenu");
}

var fsload = true;
var disTabSwp = 1; //当菜单切换太快时，用该参数判断是否切换完毕， 0=表示正在切换中，1表示已经切换完毕
function setTab(tbname, id) {
	var tb = document.getElementById(tbname);
	var obj = window.event.srcElement;
	var Days = 30;
	var exp = new Date();
	exp.setTime(exp.getTime() + Days * 24 * 60 * 60 * 1000);
	if("销售,库存,财务,办公,人资,生产".indexOf(tb.innerText.replace(/\n/g, "").replace(/\s/g, "")) > -1){
	    document.cookie = "leftTabid" + window.currUserId + "=" + escape(id) + ";expires=" + exp.toGMTString();
    }
	if(obj.parentNode.rowIndex==2)
	{
		var x = window.event.offsetX;
		var y = window.event.offsetY;
		var w =  obj.offsetWidth;
		var h = obj.offsetHeight;
		if(x<y && (x <w && y <h)) 
		{	
			//再右下角点击，触发下一个选项卡点击事件
			var obj = document.getElementById("menuitem" + (tb.id.replace("menuitem","")*1+1));
			if(obj)
			{
				app.fireEvent(obj.rows[1].cells[0],"onmousedown");
			}
			return;
		}
	}
	var rpt = tb.getAttribute("doRepeat") == 1;   //是否直接加载html后提交
	if(rpt==false) {
		var tbs = tb.parentNode.children;
		var tbslen = tbs.length
		for (var i = 0; i < tbslen ;i++ )
		{
			var item =  tbs[i];
			if(item.style.zIndex>=1000)
			{
				if (item == tb){return;}
				item.style.zIndex = item.style.zIndex - 1000;
				item.className = "menuitem";
			}
		}
		tb.style.zIndex = tb.style.zIndex*1 + 1000;
	}
	var treePanel = document.getElementById("menu_mainFrame");
	var currhtmlid = treePanel.getAttribute("currhtmlId"); //当前内容id号
	if(currhtmlid && disTabSwp==1) { mTabHtml[currhtmlid] = treePanel.innerHTML; };  //如果存在id号，则页面缓存html内容，增加显示速度
	if(!mTabHtml[id])
	{
		ajax.regEvent("cTreeData");
		ajax.addParam("id",id);
		mTabHtml[id] = ajax.send();
	}
	treePanel.innerHTML = mTabHtml[id];
	tb.className = "menuitemSel";
	treePanel.setAttribute("currhtmlId",id);
	if(fsload==true) {fsload = false; return;}
	if("销售,库存,财务,办公,人资,生产".indexOf(tb.innerText.replace(/\n/g,"").replace(/\s/g,""))>=0)
	{
		parent.frames["mainFrame"].location.href = "childhome.asp?key=" + tb.innerText.replace(/\n/g,"");
	}else if (tb.innerText.replace(/\n/g,"").replace(/\s/g,"")=="统计")
	{
		parent.frames["mainFrame"].location.href = "../../SYSN/view/Statistics/default.ashx";
	}
	
}

function loadAllMenuCacheResult(pc)
{
	return function(r) {
		try{
			eval(r);
			loadAllMenuCache(pc);
		}catch(e){
			alert("加载导航数据失败。", e.message)
		}
	}
}

//加载某个选项卡对应的TreeView数据库缓存
function loadAllMenuCache(pc)
{
	if(pc<window.menuClsID.length-1) //数组首位元素无效，所以减去1
	{ 
		ajax.regEvent("loadAllMenuCache");
		ajax.addParam("handles", window.menuClsID[pc])
		ajax.send(loadAllMenuCacheResult(pc*1 + 1));
	}
	else{
		ajax.regEvent("clsTempMenuNode");
		ajax.send(function(){return;});
	}
}

function body_load(){
	if(app.IeVer==6) {window.onresize();}
	app.fireEvent(document.getElementById("firstTab"),"onmousedown");
	loadAllMenuCache(1);
}
//-->

if(app.IeVer==6)
{
	window.onresize = function(){
		document.getElementById("menu_bodyFrame").style.height =(document.documentElement.offsetHeight - 28) + "px";
		document.getElementById("menu_mainFrame").style.width = (document.documentElement.offsetWidth - 32) + "px";
	}
}


function addMyMenu(id, obj){
	if(!obj){obj = window.event.srcElement;}
	obj = obj.parentNode;
	var value = obj.getAttribute("value");
	var txt = obj.innerText.replace("≌","");
	var value = value.split("?$?")
	var div = top.app.createWindow("addmymen","<span style='position:relative;left:-20px'>加入我的导航</span>","s.gif",(window.event.clientX+5),(window.event.clientY+50),280,210,0,0)
	ajax.regEvent("addMyMenu")
	ajax.addParam("url",value[0]);
	ajax.addParam("otype",value[1]);
	ajax.addParam("menuId", id);
	ajax.addParam("title",txt);
	div.innerHTML = ajax.send();
	window.event.cancelBubble = true;
	window.event.returnValue = false;
	return false;
	
}

try{
	top.app.closeWindow("addmymen");
}catch(e){}

tvw.canrepeatClick = true;
tvw.onitemexpnode = function (id, expand, adiv) {
    var jid = adiv.split("?$?");
    if (jid[2]) {
        var expandIds = getCookie("expandIds" + window.currUserId);
        var Days = 7;
        var exp = new Date();
        exp.setTime(exp.getTime() + Days * 24 * 60 * 60 * 1000);
        var str = "," + expandIds + ",";
        if (expand ==1) {
            if (expandIds == "" || expandIds == null) {
                expandIds = jid[2];
            }
            else if (str.lastIndexOf("," + jid[2] + ",") == -1) {
                expandIds = expandIds + "," + jid[2];
            }
        }
        else {
            expandIds = str.replace("," + jid[2] + ",", ",");
            expandIds = expandIds.substring(1, expandIds.length - 1);
        }
        document.cookie = "expandIds" + window.currUserId + "=" + escape(expandIds) + ";expires=" + exp.toGMTString();
    }
}
tvw.onitemclick = function(a) {
	var url = a.value.split("?$?");
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
			app.PageOpen(url[0],screen.availWidth*0.96,screen.availHeight*0.90,'sadfsdd');
			//if(app.IeVer<8) {setTimeout(function(){app.PageOpen(url[0],screen.availWidth*0.96,screen.availHeight*0.90,'sadfsdd');},10);}
			//else{app.PageOpen(url[0],screen.availWidth*0.96,screen.availHeight*0.90,'sadfsdd');}
			break;
		default:
			parent.frames[2].location.href = url[0];
			//if(app.IeVer<8) {setTimeout(function(){parent.frames[2].location.href = url[0]},10);}
			//else{parent.frames[2].location.href = url[0];}
			
	}
}

//读取cookies
function getCookie(name) {
    var arr, reg = new RegExp("(^| )" + name + "=([^;]*)(;|$)");
    if (arr = document.cookie.match(reg)) return unescape(arr[2]);
    else return null;
}

//删除我的导航
function delMyMenu(tag,id)
{
	var t = tag.parentNode.innerText.replace("×","");
	if(window.confirm("确定要删除导航菜单 “"  + t + "” 吗？"))
	{
		ajax.regEvent("delMyMenu");
		ajax.addParam("id", id);
		var r =  ajax.send();
		if (r=="ok")
		{
			ajax.regEvent("myMenuList")
			document.getElementById("menu_mainFrame").innerHTML = ajax.send();
		}
		else{
			alert("删除导航菜单失败.",r);
		}
	}
}

function Ie6MenuItemOut() { 
     var obj = window.event.srcElement;
     var tobj = window.event.toElement;
     if (tobj && tobj.parentNode == obj && tobj.tagName == "SPAN") {
         var p = obj.children[0];
         if (p) { p.style.display = "inline"; }
     }
     else {
         var p = obj.children[0];
         if (p) { p.style.display = "none"; }
         else {
             if (obj.className == "m_sc") {
                 obj.style.display = "none";
             } 
         }
     }
}

if (app.IeVer == 6) { //针对IE6特殊处理
    document.onmouseover = function () {
        var obj = window.event.srcElement;
        if (obj.tagName == "A" && obj.className.indexOf("tvw_txt") >= 0) {
            var p = obj.children[0];
            if (p) {
                p.style.display = "inline";
                obj.onmouseout =  Ie6MenuItemOut;
            }
        }
    }
}

function dh_top(tag, id) {
    var url = "../china/cu_dh_top.asp?id=" + id + "&id2=" + tag + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    ajax.regEvent("", url);
    var r = ajax.send();
    var treePanel = document.getElementById("menu_mainFrame");
    ajax.regEvent("myMenuList")
    html = ajax.send();
    treePanel.innerHTML = html;
    treePanel.setAttribute("currhtmlId", "mymenu");
}

function dh_down(tag, id) {
    var url = "../china/cu_dh_down.asp?id=" + id + "&id2=" + tag + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    ajax.regEvent("", url);
    var r = ajax.send();
    var treePanel = document.getElementById("menu_mainFrame");
    ajax.regEvent("myMenuList")
	html = ajax.send();
	treePanel.innerHTML = html;
	treePanel.setAttribute("currhtmlId","mymenu");
}

var mTabHtml = new Array();
