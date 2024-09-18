
function frameResize(){
	try
	{
		if(!document.getElementById("cFF").contentWindow.SaveFieldOrder)
		{
			document.getElementById("cFF").style.height=I1.document.body.scrollHeight+0+"px";
			if (parseInt(document.getElementById("cFF").style.height.split("px")[0])<700)
			{
				try
				{
					document.getElementById("cFF").style.height="700px";
				}
				catch(e){}
			}
		}
	}
	catch(e1){}
}
window.onunload = function()
	{
		var hr_xmlHttp = false;
		try
		{
			hr_xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch (e)
		{
			try
			{
				hr_xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
			}
			catch (e2)
			{
				hr_xmlHttp = false;
			}
		}
		if (!hr_xmlHttp && typeof XMLHttpRequest != 'undefined'){hr_xmlHttp = new XMLHttpRequest();}
		var url = "../hrm/AjaxLoinOut.asp?date1="+ Math.round(Math.random()*100);
		hr_xmlHttp.open("GET", url, false);
		hr_xmlHttp.onreadystatechange = function(){
		/*updatePage_cp();*/
		};
		hr_xmlHttp.send(null);
};


var xmlHttp = false;
try
{
  xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
}
catch (e)
{
  try
  {
    xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
  }
  catch (e2)
  {
    xmlHttp = false;
  }
}
if (!xmlHttp && typeof XMLHttpRequest != 'undefined')
{
  xmlHttp = new XMLHttpRequest();
}

var dhobj;
function callServer_dh(ord,sort1,sort2,title,linkurl)
{
	var sobj=event.srcElement;
	dhobj=sobj;
	var fobj=sobj.parentElement.getElementsByTagName("A")[0];
	var ltitle=title;
	if(ltitle==""){ltitle=fobj.innerText.replace(/\s+/g,'');}

	var lurl=linkurl;
	var tg="I1";
	if(lurl=="")
	{
		if(fobj.onclick)
		{
			var tmpurl=fobj.onclick.toString();
			lurl=tmpurl.split("openWin('")[1].split("','")[0];
			tg="_blank";
		}
		else
		{
			lurl=fobj.getAttribute("href");
		}
		var hostn = window.location.href.toLowerCase().split("?")[0].replace("/china/topsy.asp","");
		lurl="<A href=\""+lurl.toLowerCase().replace(hostn, "..")+"\" target=\""+tg+"\">";
	}
  var url = "cu_dh.asp?ord=" + escape(ord)+"&sort1="+escape(sort1)+"&sort2="+escape(sort2)+"&title="+escape(ltitle)+"&url="+escape(lurl)+"&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){updatePage_dh(sobj);};
  xmlHttp.send(null);  
}

function updatePage_dh(w2)
{
	if (xmlHttp.readyState == 4)
	{
		var x=w2.offsetLeft,y=w2.offsetTop;
		var obj2=w2;
		var offsetx=0;
		while(obj2=obj2.offsetParent)
		{
			x+=obj2.offsetLeft;  
			y+=obj2.offsetTop;
		}
		var dvobj=document.getElementById("CustomNavSetting");
		dvobj.style.left=offsetx+x;
		dvobj.style.top=y-5;
		dvobj.innerHTML=xmlHttp.responseText;
		dvobj.style.display="block";
		xmlHttp.abort();
	}
}

function dh_save(ord,sort1,sort2)
{
	var dh = document.getElementById("dh").value;
	var title2 = document.getElementById("title").value;
	var url = document.getElementById("url").value;
	if ((dh == null) || (dh == ""))
	{
		alert("请选择目录！")
		return false;
	}
	if ((title2 == null) || (title2 == ""))
	{
		alert("请填写名称！")
		return false;
	}
	var url = "cu_dhsave.asp?ord=" + escape(ord)+"&sort1="+escape(sort1)+"&sort2="+escape(sort2)+"&dh="+escape(dh)+"&title2="+escape(title2)+"&url="+escape(url)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
	updatePage_dhsave();
	};
	xmlHttp.send(null);
	xmlHttp.abort();
}

function updatePage_dhsave()
{
	if(xmlHttp.readyState == 4)
	{
    var response = xmlHttp.responseText;
    if(response=="1")
    {
    	dhobj.innerHTML="√";
    	dhobj.style.color="red";
    }
		dh_close();
		var url = "cu_dhsave2.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = function()
		{
			updatePage_dhsave2();
		};
		xmlHttp.send(null);
		xmlHttp.abort();
	}
}

function updatePage_dhsave2()
{
	if(xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		leftmenu3.innerHTML=response;
		xmlHttp.abort();
	}
}

function dh_close(ord,sort1,sort2)
{
	var dvobj=document.getElementById("CustomNavSetting");
	dvobj.innerHTML="";
	dvobj.style.display="none";
}


function callServer_dhml(){
	var url = "cu_dhml.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
	updatePage_dhml();
	};
	xmlHttp.send(null);
}

function updatePage_dhml(){
	if(xmlHttp.readyState == 4){
		var response = xmlHttp.responseText;
		add_ml.innerHTML=response;
		xmlHttp.abort();
	}
}

function dhml_save(ord,sort1,sort2) {
	var name = document.getElementById("name").value;
	if ((name == null) || (name == ""))  {
		alert("请填写目录！");
		return false;
	}
	var url = "cu_dhmlsave.asp?name=" + escape(name)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_dhmlsave(name);};
	xmlHttp.send(null);  
}

function updatePage_dhmlsave(name) {
	if(xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		add_ml.innerHTML="";
		var url = "cu_dhmlsave2.asp?name=" + escape(name)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = function(){updatePage_dhmlsave2();};
		xmlHttp.send(null);  
		xmlHttp.abort();
	}
}

function updatePage_dhmlsave2() {
	if(xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		dhml.innerHTML=response;
		var url = "cu_dhsave2.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = function(){updatePage_dhsave2();};
		xmlHttp.send(null);  
		xmlHttp.abort();
	}
}

function dhml_close()
{
	add_ml.innerHTML="";
	xmlHttp.abort();
}

function dhml_top(id){
	var url = "cu_dhml_top.asp?id=" + id + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_dhsave2();};
	xmlHttp.send(null); 
	xmlHttp.abort();
}

function dhml_down(id){
	var url = "cu_dhml_down.asp?id=" + id + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_dhsave2();};
	xmlHttp.send(null); 
	xmlHttp.abort();
}

function dhml_del(id) {
	var url = "cu_dhml_del.asp?id=" + id + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_dhsave2();};
	xmlHttp.send(null); 
	xmlHttp.abort();
}

function dh_top(id,id2) {
	var url = "cu_dh_top.asp?id=" + id + "&id2=" + id2 + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_dh_lb_save2(id2);};
	xmlHttp.send(null); 
	xmlHttp.abort();
}

function dh_down(id,id2) {
	var url = "cu_dh_down.asp?id=" + id + "&id2=" + id2 + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_dh_lb_save2(id2);};
	xmlHttp.send(null); 
	xmlHttp.abort();
}

function dh_del(id,id2) {
	var url = "cu_dh_del.asp?id=" + id + "&id2=" + id2 + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_dh_lb_save2(id2);};
	xmlHttp.send(null); 
	xmlHttp.abort();
}

function updatePage_dh_lb_save2(id) {
	var w  = "dhWa"+id;
	w=document.all[w];
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		w.innerHTML=response;
		xmlHttp.abort();
	}
}

function alt_close() {
	var url = "cu_close.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.send(null);  
}

function alt_href() {
	var url = "cu_alt_href.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_alt_href();};
  xmlHttp.send(null);  
}

function updatePage_alt_href() {
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		alt_url.innerHTML=response;
		Myopen(alt_url);
		xmlHttp.abort();
	}
}

function alt_url_close() {
	alt_url.innerHTML="";
	alt_url.style.display="none";
	xmlHttp.abort();
}

function Myopen(divID){ //根据传递的参数确定显示的层	
	divID.style.left=0;
	divID.style.top=0;
	divID.style.right=0;
	divID.style.bottem=0;
}

function left_xs(id) {
	var url = "../setjm/updateleft.asp?id=" + id + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){};
	xmlHttp.send(null);
	xmlHttp.abort(); 
}

function left_mldh(id,num1) {
	var url = "cu_dhml_left.asp?id=" + id + "&num1=" + num1 + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){};
	xmlHttp.send(null);
	xmlHttp.abort(); 
}

//--> 

//delect link dotted line
function $(name){
	return document.getElementById(name);
}
function Switchmenu(obj,name)
{
	if (document.getElementById)
	{
		var el = document.getElementById(name + "_" + obj);
		var ar = document.getElementById(name).getElementsByTagName("ul");
		if (el.style.display != "block")
		{
			for (var i = 0; i < ar.length; i++)
			{
				ar[i].style.display = "none";
				document.getElementById(name+ar[i].id.toString().replace(name+"_","")).className = "nav_tab";
			}
			el.style.display = "block";
			document.getElementById(name + obj).className = "navtab_hover"
		}
		else
		{
				el.style.display = "none";
				document.getElementById(name + obj).className = "nav_tab"
		}
	}
}

function LinkOver()
{
	var lkobj=event.srcElement.tagName=="A"?event.srcElement.parentElement.getElementsByTagName("a"):event.srcElement.getElementsByTagName("a");
	if(lkobj.length>0) lkobj[0].style.backgroundColor='ecf5ff';
	if(lkobj.length>1)
	{
		lkobj[1].title="加入我的导航";
		lkobj[1].style.display='inline';
	}
}

function LinkOut()
{
	var lkobj=event.srcElement.tagName=="A"?event.srcElement.parentElement.getElementsByTagName("a"):event.srcElement.getElementsByTagName("a");
	if(lkobj.length>0) lkobj[0].style.backgroundColor='';
	if(lkobj.length>1) lkobj[1].style.display='none';
}

function openWin(u,n,w,h,t,l)
{
	window.open(u,(n==""?"newwin":n),'width='+w+',height='+h+',fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left='+l+',top='+t);
}

function initphonectl(){
	var url = window.location.href
	var si  = url.toLowerCase().indexOf("china/topsy.asp")
	var div = document.createElement("div")
	url = url.substr(0,si-1)
	div.style.cssText = "position:absolute;left:1px;height:1px;top:1px;width:1px;background-color:white"
	document.body.appendChild(div)
	xmlHttp.open("GET", "../ocx/ctlevent.asp?__msgId=getObjectHTML&date1="+ Math.round(Math.random()*100), false);
	xmlHttp.send(null);
	var html = xmlHttp.responseText
	xmlHttp.abort(); 
	html = html.replace("#defserverurl",url)
	div.innerHTML =	html
	try{
		if(!document.getElementById("PhoneCtl").version){
			//alert("加载组件失败，可能需要降低浏览器安全设置，然后启动浏览器。")
		}
		else{
			var txt = "<span style='color:#007700;font-size:12px;font-family:宋体;position:relative;top:4px;left:2px;line-height:15px'>电话录音组件启动正常。<br>" 
					 + "组件版本:<span style='color:red'>" + document.getElementById("PhoneCtl").version + "</span></span>"
			document.getElementById("PhoneCtl").showtext(txt)
		}
	}catch(e){
		//alert("加载组件失败，可能需要降低浏览器安全设置，然后启动浏览器。")
	}
}

function alt_SetDisPromp() {//--设置今日不再提醒session
	var url = "../inc/ReminderDisPromp.asp?act=SetDisPromp&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.send(null);  
}

function alt_GettDisPromp() {//--获取今日不再提醒session
	var DisPromp;
	var url = "../inc/ReminderDisPromp.asp?act=GetDisPromp&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function()
	{
		if(xmlHttp.readyState == 4)
		{
			DisPromp = xmlHttp.responseText;
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null);
	return DisPromp;
}

var cs_dh = callServer_dh;