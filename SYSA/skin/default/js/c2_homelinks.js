function changeModel(box)
{
	var ivw = document.getElementById("icoview_h")
	ivw.className = ivw.className == "icoview" ? "icoviewedit" : "icoview";
	box.value = ivw.className == "icoview" ? "进入设置" : "返回浏览";
}

//修改导航图标事件
function h_onicoitemsetAttr(item){
	var id = item.parentNode.parentNode.getAttribute("tag");
	attrIcoItem(id);
}

//弹出修改菜单界面
function attrIcoItem(id)
{
	var div = app.createWindow("linksedit","修改导航","002.gif", "", 20 + document.documentElement.scrollTop, 700, 520, 1, 9, "#e3e7f0","",1);
	div.className = "groupEditDiv";
	ajax.regEvent("editLinkItem");
	ajax.addParam("gpname", "");
	ajax.addParam("linkId",id);
	div.innerHTML = ajax.send();
}

//删除图标链接事件
function h_onicoitemDel(item){
	var id = item.parentNode.parentNode.getAttribute("tag");
	delIcoItem(id);
}

//删除图标链接
function delIcoItem(id)
{
	if(!window.confirm("确定删除该链接？")){ return false; }
	ajax.regEvent("delLinkItem");
	ajax.addParam("id", id);
	var r = ajax.send();
	if(r.length>0) {
		app.Alert(r)
	}
	DoRefresh();
}

//还原系统图标
function hyIcoItem(id)
{
	ajax.regEvent("hyLinkItem");
	ajax.addParam("id", id);
	var r = ajax.send();
	if(r.length>0) {
		app.Alert(r)
	}
	DoRefresh();
}


//弹出添加导航分类界面
function h_onAddGroup(id) {
	var div = app.createWindow("addasxc","添加导航分类","1.gif", "", "", 600, 400, 1, 9, "#e3e7f0");
	div.className = "groupEditDiv";
	ajax.regEvent("editgroup");
	ajax.addParam("nm", "");
	div.innerHTML = ajax.send();
}

function h_groupEditItem(n, tag)
{
	n = tag.length > 0 ? tag : n;
	UpdateGroup(n);
	window.event.cancelBubble = true;
	return false;
}

function UpdateGroup(nm) {
	var div = app.createWindow("addasxc","修改导航分类","1.gif", "", "", 600, 400, 1, 9, "#e3e7f0");
	div.className = "groupEditDiv";
	ajax.regEvent("editgroup");
	ajax.addParam("nm", nm);
	div.innerHTML = ajax.send();
}

function savecls(){
	var v = document.getElementById("g_v1").value
	if (v.replace(/\s/g,"")=="")
	{
		app.Alert("分类名称不能为空");
		return false;
	}
	if(existsWChar(v)) {
		app.Alert("分类名称中有特殊字符（\" \' & ! %），无法保存。")
		return false;
	}
	else
	{
		v = v.replace(/\s/g,"");
	}

	ajax.regEvent("savecls")
	ajax.addParam("gn", v);
	ajax.addParam("ga", document.getElementById("g_v2").value);
	ajax.addParam("gs", document.getElementById("g_v3").value);
	ajax.addParam("gr", document.getElementById("g_v4").value);
	ajax.addParam("gi", document.getElementById("g_v5").value);
	app.Alert(ajax.send());
	DoRefresh();
}

function DoRefresh()
{
	var ivw = document.getElementById("icoview_h")
	var editmode = (ivw.className == "icoview" ? 0 : 1);
	ajax.regEvent("DoRefresh");
	ajax.addParam("editmode", editmode);  //是否为编辑模式
	document.getElementById("icosbody").innerHTML  = ajax.send() + "<br>";
}

function h_IcoItemAddClick(n, tag)
{
	n = tag.length > 0 ? tag : n;
	var div = app.createWindow("linksedit","添加导航","002.gif", "", 20 + document.documentElement.scrollTop, 700, 520, 1, 9, "#e3e7f0","",1);
	div.className = "groupEditDiv";
	ajax.regEvent("editLinkItem");
	ajax.addParam("gpname", n);
	ajax.addParam("linkId",0);
	div.innerHTML = ajax.send()
}

function usbuttonClick(index) 
{
	var s1 = document.getElementById("usbutton" + index).style;
	var s2 = document.getElementById("usbutton" + (index==1?2:1)).style;
	s1.backgroundColor = "white";
	s1.zIndex = 100;
	s2.backgroundColor = "#f2f2f2";
	s2.zIndex = 98;
	if (index == 1) { document.getElementById("usifrm").src = "?__msgid=urlsorce&t=1"; return }
	if (index == 2) { document.getElementById("usifrm").src = "./leftTreeNav.html?h=1"; return }
}

function getWebIcoUrl()
{
	var div = app.createWindow("addweblink","选择网络图标","s.gif", "", 100 + document.documentElement.scrollTop, 400, 170, 1, 9, "#e3e7f0");
	div.innerHTML = "<div style='color:#000;padding-left:10px;'>图标网络地址(http://)：</div><div style='padding-left:30px;margin-top:10px;'><input type=text id='webIcoUrlbox' style='width:300px'></div>"
					+ "<center><div style='margin-top:10px;'><input type='button' value='确定' class='oldbutton' onclick='setWebIcoUrl()'> <input onclick='app.closeWindow(\"addweblink\")' type='button' value='取消' class='oldbutton'></div></center>"
}

function setWebIcoUrl()
{
	var url = document.getElementById("webIcoUrlbox").value;
	if (url.length == 0)
	{
		app.Alert("请输入网址：");
	}
	else {
		document.getElementById("v_icourl").value = url;
		document.getElementById("v_icoid").value = 0;
		document.getElementById("img_url").src = url;
		document.getElementById("icoupfrm").reset();
		app.closeWindow("addweblink");
	}
}


//显示图片
function IcoTempUrlChange(url, icotype){
	document.getElementById("v_icourl").value = "";
	document.getElementById("v_icoid").value = 0;
	document.getElementById("img_url").src = url;
	window.upicotype =  icotype; 
}

//同步更新网址
function updateUrlText() {
	var box = document.getElementById("v_url_txt");
	if (box.value!="系统路径,不可编辑")
	{
		document.getElementById("v_url").value = box.value;
	}
}

function existsWChar(v) {
	return v.indexOf("\"") > -1 ||  v.indexOf("\'") > -1 || v.indexOf("&") > -1 || v.indexOf("!") > -1 || v.indexOf("%") > -1
}

//添加或保存图标
function saveLinkItem()
{
	var v = document.getElementById("v_title").value
	if(existsWChar(v)) {
		app.Alert("导航名称中有特殊字符（\" \' & ! %），无法保存。")
		return false;
	}
	else
	{
		v = v.replace(/\s/g,"");
	}
	if(v.length==0) {
		app.Alert("导航名称不能为空。")
		return ;
	}
	ajax.regEvent("saveLinkItem");
	ajax.addParam("v_id",document.getElementById("v_id").value);
	ajax.addParam("v_title",v);
	ajax.addParam("v_url",document.getElementById("v_url").value);
	ajax.addParam("v_url_txt",document.getElementById("v_url_txt").value);
	ajax.addParam("v_sort",document.getElementById("v_sort").value);
	ajax.addParam("v_gpname",document.getElementById("v_gpname").value);
	ajax.addParam("v_icourl",document.getElementById("v_icourl").value);
	ajax.addParam("v_icoid",document.getElementById("v_icoid").value);
	ajax.addParam("v_powerCode",document.getElementById("v_powerCode").value);
	ajax.addParam("v_icotype", window.upicotype ? window.upicotype : "");
	var r = ajax.send();
	app.Alert(r);
	DoRefresh();
}

//更改文字
function h_onicoitemsetText(td, t)
{
	var id = td.parentNode.parentNode.parentNode.parentNode.parentNode.getAttribute("tag");
	if(isNaN(id)){return;} 
	ajax.regEvent("saveLinkItemText");
	ajax.addParam("newText",t);
	ajax.addParam("id", id);
	ajax.send(function(r){if(r!=""){app.Alert(r);}});
}

//链接拖动
function h_onicoitemDragEnd(newObj, movObj)
{
	var nid, ngp, sid, sgp
	nid = newObj.getAttribute("islast")==1 ? -1 : newObj.getAttribute("tag");  //新位置的id
	ngp = newObj.parentNode.getAttribute("db");
	sid = movObj.getAttribute("tag");
	sgp = window.oldIvwItemParent.getAttribute("db");
	ajax.regEvent("updateIcoPos");
	ajax.addParam("nid",nid);
	ajax.addParam("ngp",ngp);
	ajax.addParam("sid",sid);
	ajax.addParam("sgp",sgp);
	ajax.send(function(r){if(r!=""){app.Alert(r);}});
}

function h_onivwGroupMv(o, i)
{
	var gn = o.parentNode.parentNode;
	var ivw =  gn.parentNode;
	var id = ivw.id.replace("icoview_","")
	var t = gn.getAttribute("t")
	var d = gn.getAttribute("d")
	var no = document.getElementById("ivw_" + id + "_g_" + i);
	var nt = no.getAttribute("t")
	var nd = no.getAttribute("d")
	t = d.length > 0 ? d : t;
	nt = nd.length > 0 ? nd : nt;
	ajax.regEvent("updateGroupPos");
	ajax.addParam("gp1", t);
	ajax.addParam("gp2", nt);
	var r = ajax.send();
	if(r=="") {
		DoRefresh();
	}
	else{
		app.Alert(r);
	}
	window.event.cancelBubble = true;
	return false;
}

function h_onivwGroupDel(o, i)
{
	var gn = o.parentNode.parentNode;
	var t = gn.getAttribute("t")
	var d = gn.getAttribute("d")
	t = d.length > 0 ? d : t;
	groupHide(t, 1, 1);
	window.event.cancelBubble = true;
	return false;
}

//隐藏或还原组
function groupHide(gpname, t, ng)
{
	if(t==1)
	{
		if(!window.confirm("您确定要删除该分组以及分组下的所有链接吗？"))
		{
			window.event.cancelBubble = true;
			return false;
		}
	}
	ajax.regEvent("groupHide");
	ajax.addParam("gn",gpname);
	ajax.addParam("t",t);
	var r = ajax.send();
	if(r!="") {
		app.Alert(r)
	}
	else{
		DoRefresh();
		if(ng!=1)
		{
			UpdateGroup(gpname);
		}
	}
	window.event.cancelBubble = true;
	return false;
}

//恢复系统菜单
function hfSysIcoItem(id)
{
	var v = document.getElementById("v_title").value
	if(existsWChar(v)) {
		app.Alert("导航名称中有特殊字符（\" \' & ! %），无法保存。")
		return false;
	}
	else
	{
		v = v.replace(/\s/g,"");
	}
	if(v.length==0) {
		app.Alert("导航名称不能为空。")
		return ;
	}
	ajax.regEvent("hfSysIcoItem");
	ajax.addParam("id",id);
	ajax.addParam("v_id",id);
	ajax.addParam("v_title",v);
	ajax.addParam("v_url",document.getElementById("v_url").value);
	ajax.addParam("v_url_txt",document.getElementById("v_url_txt").value);
	ajax.addParam("v_sort",document.getElementById("v_sort").value);
	ajax.addParam("v_gpname",document.getElementById("v_gpname").value);
	ajax.addParam("v_icourl",document.getElementById("v_icourl").value);
	ajax.addParam("v_icoid",document.getElementById("v_icoid").value);
	ajax.addParam("v_powerCode",document.getElementById("v_powerCode").value);
	ajax.addParam("v_icotype", window.upicotype ? window.upicotype : "");

	var r = ajax.send();
	if(r!="") {
		app.Alert(r)
	}
	DoRefresh();
}

//框架加载
function urlsorceiframeLoad()
{
	var win = document.getElementById("usifrm").contentWindow;
	if(win.location.href.indexOf("menu.asp")>0)
	{
		win.tvw.onitemclick = menutvwnodeclick
		win.document.getElementById("menu_mainFrame").onclick = function()
		{
			if (win.event && win.event.srcElement.tagName == "B") {
				return false;
			}
		}
		win.document.documentElement.style.overflow = "hidden"
		win.addMyMenu = function(){}
		if(win.document.getElementById("tvw_menumy"))
		{
			win.document.getElementById("tvw_menumy").onclick = function()
			{
				var a = win.event.srcElement;
				if(a && a.tagName=="A" && a.className=="m_txt")
				{
					document.getElementById("v_title").value = a.innerText;
					document.getElementById("v_url_txt").value = "系统路径,不可编辑";
					document.getElementById("v_url_txt").style.color="#666"
					document.getElementById("v_url").value = a.href;
				}
				return false;
			}
		}
	}
}

function menutvwnodeclick(a)
{
	var win = document.getElementById("usifrm").contentWindow;
	var url = a.value.split("\1");
	if(url[0].length==0) {
		return false;
	}
	var u = url[0];
	var t = a.text.replace("<span","<SPAN").split("<SPAN")[0];
	document.getElementById("v_title").value = t;
	document.getElementById("v_url_txt").value = "系统路径,不可编辑";
	document.getElementById("v_url_txt").style.color="#666";
	document.getElementById("v_url").value = "sys:" + u;
    //控制导航权限，目前没有控制住，后期要改
	//var obj = a.srcElement.parentNode;
	//var dp = a.deep;
	//var ii = 0;
	//var power = "";
	//var ids = (obj.id + "_n").split("_");
	//for (var i = dp; i > 0 ; i--)
	//{
	//	ii ++;
	//	var id = ids.slice(0,-ii).join("_");
	//	var n = win.document.getElementById(id);
	//	if(n) {
	//		var ibox = n.getElementsByTagName("input");
	//		for (var x = 0; x< ibox.length; x++)
	//		{
	//			var bx = ibox[x];
	//			if(bx.type=="hidden" && bx.getAttribute("tg")=="power")
	//			{
	//				power = power + ";;" + bx.value;
	//			}
	//		}
	//	}
	//}
	//try
	//{
	//	var tid = win.preActivetb.id.replace("treebg","mt_");
	//	if(win.document.getElementById(tid).innerText.indexOf("回收站")>=0)
	//	{
	//		power = power + ";;***"; //*号表示回收站
	//	}
	//}
	//catch (e){}
	//document.getElementById("v_powerCode").value = "LM:" + power;
}

function h_onicoitemGDragEnd(sObj, oObj)
{
	var nT = sObj.getAttribute("db");
	var oT = oObj.getAttribute("d");
	if(nT==null) {nT="\1\1\1";}
	ajax.regEvent("dragGroupEnd")
	ajax.addParam("nT",nT);
	ajax.addParam("oT",oT);
	var r = ajax.send();
	if(r!="ok"){
		app.Alert(r);
	}
	else
	{
		DoRefresh();
	}
}